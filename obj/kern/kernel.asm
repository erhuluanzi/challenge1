
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
f010005f:	e8 10 67 00 00       	call   f0106774 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 40 6e 10 f0 	movl   $0xf0106e40,(%esp)
f010007d:	e8 70 41 00 00       	call   f01041f2 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 31 41 00 00       	call   f01041bf <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 b5 82 10 f0 	movl   $0xf01082b5,(%esp)
f0100095:	e8 58 41 00 00       	call   f01041f2 <cprintf>
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
f01000be:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 ab 6e 10 f0 	movl   $0xf0106eab,(%esp)
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
f01000e2:	e8 8d 66 00 00       	call   f0106774 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 b7 6e 10 f0 	movl   $0xf0106eb7,(%esp)
f01000f2:	e8 fb 40 00 00       	call   f01041f2 <cprintf>

	lapic_init();
f01000f7:	e8 93 66 00 00       	call   f010678f <lapic_init>
	env_init_percpu();
f01000fc:	e8 1f 38 00 00       	call   f0103920 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 06 41 00 00       	call   f010420c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 69 66 00 00       	call   f0106774 <cpunum>
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
f0100124:	e8 0a 69 00 00       	call   f0106a33 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100129:	e8 03 4b 00 00       	call   f0104c31 <sched_yield>

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
f0100152:	e8 ef 5f 00 00       	call   f0106146 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 6b 05 00 00       	call   f01006c7 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010015c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 cd 6e 10 f0 	movl   $0xf0106ecd,(%esp)
f010016b:	e8 82 40 00 00       	call   f01041f2 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100170:	e8 2e 15 00 00       	call   f01016a3 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100175:	e8 d0 37 00 00       	call   f010394a <env_init>
	trap_init();
f010017a:	e8 8a 41 00 00       	call   f0104309 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010017f:	e8 08 63 00 00       	call   f010648c <mp_init>
	lapic_init();
f0100184:	e8 06 66 00 00       	call   f010678f <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100189:	e8 ba 3f 00 00       	call   f0104148 <pic_init>
f010018e:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f0100195:	e8 99 68 00 00       	call   f0106a33 <spin_lock>
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
f01001ab:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01001b2:	f0 
f01001b3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01001ba:	00 
f01001bb:	c7 04 24 ab 6e 10 f0 	movl   $0xf0106eab,(%esp)
f01001c2:	e8 79 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001c7:	b8 b6 63 10 f0       	mov    $0xf01063b6,%eax
f01001cc:	2d 3c 63 10 f0       	sub    $0xf010633c,%eax
f01001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001d5:	c7 44 24 04 3c 63 10 	movl   $0xf010633c,0x4(%esp)
f01001dc:	f0 
f01001dd:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001e4:	e8 a7 5f 00 00       	call   f0106190 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e9:	bb 20 30 33 f0       	mov    $0xf0333020,%ebx
f01001ee:	eb 6f                	jmp    f010025f <i386_init+0x131>
		if (c == cpus + cpunum())  // We've started already.
f01001f0:	e8 7f 65 00 00       	call   f0106774 <cpunum>
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
f010024f:	e8 94 66 00 00       	call   f01068e8 <lapic_startap>
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
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f010027f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100286:	00 
f0100287:	c7 04 24 65 bd 2e f0 	movl   $0xf02ebd65,(%esp)
f010028e:	e8 d8 38 00 00       	call   f0103b6b <env_create>
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f0100293:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010029a:	00 
f010029b:	c7 04 24 65 bd 2e f0 	movl   $0xf02ebd65,(%esp)
f01002a2:	e8 c4 38 00 00       	call   f0103b6b <env_create>
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f01002a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01002ae:	00 
f01002af:	c7 04 24 65 bd 2e f0 	movl   $0xf02ebd65,(%esp)
f01002b6:	e8 b0 38 00 00       	call   f0103b6b <env_create>
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f01002bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01002c2:	00 
f01002c3:	c7 04 24 65 bd 2e f0 	movl   $0xf02ebd65,(%esp)
f01002ca:	e8 9c 38 00 00       	call   f0103b6b <env_create>
	ENV_CREATE(user_fairness, ENV_TYPE_USER);
f01002cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01002d6:	00 
f01002d7:	c7 04 24 65 bd 2e f0 	movl   $0xf02ebd65,(%esp)
f01002de:	e8 88 38 00 00       	call   f0103b6b <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002e3:	e8 49 49 00 00       	call   f0104c31 <sched_yield>

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
f0100300:	c7 04 24 e8 6e 10 f0 	movl   $0xf0106ee8,(%esp)
f0100307:	e8 e6 3e 00 00       	call   f01041f2 <cprintf>
	vcprintf(fmt, ap);
f010030c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100310:	8b 45 10             	mov    0x10(%ebp),%eax
f0100313:	89 04 24             	mov    %eax,(%esp)
f0100316:	e8 a4 3e 00 00       	call   f01041bf <vcprintf>
	cprintf("\n");
f010031b:	c7 04 24 b5 82 10 f0 	movl   $0xf01082b5,(%esp)
f0100322:	e8 cb 3e 00 00       	call   f01041f2 <cprintf>
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
f0100369:	8b 15 24 22 33 f0    	mov    0xf0332224,%edx
f010036f:	88 82 20 20 33 f0    	mov    %al,-0xfccdfe0(%edx)
f0100375:	8d 42 01             	lea    0x1(%edx),%eax
f0100378:	a3 24 22 33 f0       	mov    %eax,0xf0332224
		if (cons.wpos == CONSBUFSIZE)
f010037d:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100382:	75 0a                	jne    f010038e <cons_intr+0x34>
			cons.wpos = 0;
f0100384:	c7 05 24 22 33 f0 00 	movl   $0x0,0xf0332224
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
f0100402:	a1 48 a4 12 f0       	mov    0xf012a448,%eax
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
f0100438:	66 a1 34 22 33 f0    	mov    0xf0332234,%ax
f010043e:	66 85 c0             	test   %ax,%ax
f0100441:	0f 84 e2 00 00 00    	je     f0100529 <cons_putc+0x18e>
			crt_pos--;
f0100447:	48                   	dec    %eax
f0100448:	66 a3 34 22 33 f0    	mov    %ax,0xf0332234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010044e:	0f b7 c0             	movzwl %ax,%eax
f0100451:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100457:	83 ce 20             	or     $0x20,%esi
f010045a:	8b 15 30 22 33 f0    	mov    0xf0332230,%edx
f0100460:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100464:	eb 78                	jmp    f01004de <cons_putc+0x143>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100466:	66 83 05 34 22 33 f0 	addw   $0x50,0xf0332234
f010046d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010046e:	66 8b 0d 34 22 33 f0 	mov    0xf0332234,%cx
f0100475:	bb 50 00 00 00       	mov    $0x50,%ebx
f010047a:	89 c8                	mov    %ecx,%eax
f010047c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100481:	66 f7 f3             	div    %bx
f0100484:	66 29 d1             	sub    %dx,%cx
f0100487:	66 89 0d 34 22 33 f0 	mov    %cx,0xf0332234
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
f01004c4:	66 a1 34 22 33 f0    	mov    0xf0332234,%ax
f01004ca:	0f b7 c8             	movzwl %ax,%ecx
f01004cd:	8b 15 30 22 33 f0    	mov    0xf0332230,%edx
f01004d3:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01004d7:	40                   	inc    %eax
f01004d8:	66 a3 34 22 33 f0    	mov    %ax,0xf0332234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004de:	66 81 3d 34 22 33 f0 	cmpw   $0x7cf,0xf0332234
f01004e5:	cf 07 
f01004e7:	76 40                	jbe    f0100529 <cons_putc+0x18e>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004e9:	a1 30 22 33 f0       	mov    0xf0332230,%eax
f01004ee:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004f5:	00 
f01004f6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004fc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100500:	89 04 24             	mov    %eax,(%esp)
f0100503:	e8 88 5c 00 00       	call   f0106190 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100508:	8b 15 30 22 33 f0    	mov    0xf0332230,%edx
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
f0100521:	66 83 2d 34 22 33 f0 	subw   $0x50,0xf0332234
f0100528:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100529:	8b 0d 2c 22 33 f0    	mov    0xf033222c,%ecx
f010052f:	b0 0e                	mov    $0xe,%al
f0100531:	89 ca                	mov    %ecx,%edx
f0100533:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100534:	66 8b 35 34 22 33 f0 	mov    0xf0332234,%si
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
f0100577:	83 0d 28 22 33 f0 40 	orl    $0x40,0xf0332228
		return 0;
f010057e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100583:	e9 c3 00 00 00       	jmp    f010064b <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f0100588:	84 c0                	test   %al,%al
f010058a:	79 33                	jns    f01005bf <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010058c:	8b 0d 28 22 33 f0    	mov    0xf0332228,%ecx
f0100592:	f6 c1 40             	test   $0x40,%cl
f0100595:	75 05                	jne    f010059c <kbd_proc_data+0x43>
f0100597:	88 c2                	mov    %al,%dl
f0100599:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010059c:	0f b6 d2             	movzbl %dl,%edx
f010059f:	8a 82 40 6f 10 f0    	mov    -0xfef90c0(%edx),%al
f01005a5:	83 c8 40             	or     $0x40,%eax
f01005a8:	0f b6 c0             	movzbl %al,%eax
f01005ab:	f7 d0                	not    %eax
f01005ad:	21 c1                	and    %eax,%ecx
f01005af:	89 0d 28 22 33 f0    	mov    %ecx,0xf0332228
		return 0;
f01005b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005ba:	e9 8c 00 00 00       	jmp    f010064b <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f01005bf:	8b 0d 28 22 33 f0    	mov    0xf0332228,%ecx
f01005c5:	f6 c1 40             	test   $0x40,%cl
f01005c8:	74 0e                	je     f01005d8 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005ca:	88 c2                	mov    %al,%dl
f01005cc:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01005cf:	83 e1 bf             	and    $0xffffffbf,%ecx
f01005d2:	89 0d 28 22 33 f0    	mov    %ecx,0xf0332228
	}

	shift |= shiftcode[data];
f01005d8:	0f b6 d2             	movzbl %dl,%edx
f01005db:	0f b6 82 40 6f 10 f0 	movzbl -0xfef90c0(%edx),%eax
f01005e2:	0b 05 28 22 33 f0    	or     0xf0332228,%eax
	shift ^= togglecode[data];
f01005e8:	0f b6 8a 40 70 10 f0 	movzbl -0xfef8fc0(%edx),%ecx
f01005ef:	31 c8                	xor    %ecx,%eax
f01005f1:	a3 28 22 33 f0       	mov    %eax,0xf0332228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005f6:	89 c1                	mov    %eax,%ecx
f01005f8:	83 e1 03             	and    $0x3,%ecx
f01005fb:	8b 0c 8d 40 71 10 f0 	mov    -0xfef8ec0(,%ecx,4),%ecx
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
f0100630:	c7 04 24 02 6f 10 f0 	movl   $0xf0106f02,(%esp)
f0100637:	e8 b6 3b 00 00       	call   f01041f2 <cprintf>
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
f0100659:	80 3d 00 20 33 f0 00 	cmpb   $0x0,0xf0332000
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
f0100690:	8b 15 20 22 33 f0    	mov    0xf0332220,%edx
f0100696:	3b 15 24 22 33 f0    	cmp    0xf0332224,%edx
f010069c:	74 22                	je     f01006c0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010069e:	0f b6 82 20 20 33 f0 	movzbl -0xfccdfe0(%edx),%eax
f01006a5:	42                   	inc    %edx
f01006a6:	89 15 20 22 33 f0    	mov    %edx,0xf0332220
		if (cons.rpos == CONSBUFSIZE)
f01006ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006b2:	75 11                	jne    f01006c5 <cons_getc+0x45>
			cons.rpos = 0;
f01006b4:	c7 05 20 22 33 f0 00 	movl   $0x0,0xf0332220
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
f01006ec:	c7 05 2c 22 33 f0 b4 	movl   $0x3b4,0xf033222c
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
f0100704:	c7 05 2c 22 33 f0 d4 	movl   $0x3d4,0xf033222c
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
f0100713:	8b 0d 2c 22 33 f0    	mov    0xf033222c,%ecx
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
f0100732:	89 35 30 22 33 f0    	mov    %esi,0xf0332230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100738:	0f b6 d8             	movzbl %al,%ebx
f010073b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010073d:	66 89 3d 34 22 33 f0 	mov    %di,0xf0332234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100744:	e8 25 ff ff ff       	call   f010066e <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100749:	0f b7 05 a8 a3 12 f0 	movzwl 0xf012a3a8,%eax
f0100750:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100755:	89 04 24             	mov    %eax,(%esp)
f0100758:	e8 77 39 00 00       	call   f01040d4 <irq_setmask_8259A>
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
f0100796:	a2 00 20 33 f0       	mov    %al,0xf0332000
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
f01007a7:	c7 04 24 0e 6f 10 f0 	movl   $0xf0106f0e,(%esp)
f01007ae:	e8 3f 3a 00 00       	call   f01041f2 <cprintf>
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
f01007ee:	c7 04 24 50 71 10 f0 	movl   $0xf0107150,(%esp)
f01007f5:	e8 f8 39 00 00       	call   f01041f2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007fa:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100801:	00 
f0100802:	c7 04 24 ac 72 10 f0 	movl   $0xf01072ac,(%esp)
f0100809:	e8 e4 39 00 00       	call   f01041f2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010080e:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100815:	00 
f0100816:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010081d:	f0 
f010081e:	c7 04 24 d4 72 10 f0 	movl   $0xf01072d4,(%esp)
f0100825:	e8 c8 39 00 00       	call   f01041f2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010082a:	c7 44 24 08 32 6e 10 	movl   $0x106e32,0x8(%esp)
f0100831:	00 
f0100832:	c7 44 24 04 32 6e 10 	movl   $0xf0106e32,0x4(%esp)
f0100839:	f0 
f010083a:	c7 04 24 f8 72 10 f0 	movl   $0xf01072f8,(%esp)
f0100841:	e8 ac 39 00 00       	call   f01041f2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100846:	c7 44 24 08 b5 17 33 	movl   $0x3317b5,0x8(%esp)
f010084d:	00 
f010084e:	c7 44 24 04 b5 17 33 	movl   $0xf03317b5,0x4(%esp)
f0100855:	f0 
f0100856:	c7 04 24 1c 73 10 f0 	movl   $0xf010731c,(%esp)
f010085d:	e8 90 39 00 00       	call   f01041f2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100862:	c7 44 24 08 08 40 37 	movl   $0x374008,0x8(%esp)
f0100869:	00 
f010086a:	c7 44 24 04 08 40 37 	movl   $0xf0374008,0x4(%esp)
f0100871:	f0 
f0100872:	c7 04 24 40 73 10 f0 	movl   $0xf0107340,(%esp)
f0100879:	e8 74 39 00 00       	call   f01041f2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010087e:	b8 07 44 37 f0       	mov    $0xf0374407,%eax
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
f01008a0:	c7 04 24 64 73 10 f0 	movl   $0xf0107364,(%esp)
f01008a7:	e8 46 39 00 00       	call   f01041f2 <cprintf>
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
f01008bf:	8b 83 04 76 10 f0    	mov    -0xfef89fc(%ebx),%eax
f01008c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008c9:	8b 83 00 76 10 f0    	mov    -0xfef8a00(%ebx),%eax
f01008cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d3:	c7 04 24 69 71 10 f0 	movl   $0xf0107169,(%esp)
f01008da:	e8 13 39 00 00       	call   f01041f2 <cprintf>
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
f01008fd:	c7 04 24 72 71 10 f0 	movl   $0xf0107172,(%esp)
f0100904:	e8 e9 38 00 00       	call   f01041f2 <cprintf>
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
f0100931:	c7 04 24 90 73 10 f0 	movl   $0xf0107390,(%esp)
f0100938:	e8 b5 38 00 00       	call   f01041f2 <cprintf>
		for (i = 0; i < 5; i++) {
f010093d:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf(" %08x", *(ebp + i + 2));
f0100942:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100946:	89 44 24 04          	mov    %eax,0x4(%esp)
f010094a:	c7 04 24 84 71 10 f0 	movl   $0xf0107184,(%esp)
f0100951:	e8 9c 38 00 00       	call   f01041f2 <cprintf>
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
f0100964:	c7 04 24 8a 71 10 f0 	movl   $0xf010718a,(%esp)
f010096b:	e8 82 38 00 00       	call   f01041f2 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f0100970:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100973:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100977:	89 3c 24             	mov    %edi,(%esp)
f010097a:	e8 fe 4c 00 00       	call   f010567d <debuginfo_eip>
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
f01009a2:	c7 04 24 8e 71 10 f0 	movl   $0xf010718e,(%esp)
f01009a9:	e8 44 38 00 00       	call   f01041f2 <cprintf>
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
f0100a19:	c7 44 24 08 a7 71 10 	movl   $0xf01071a7,0x8(%esp)
f0100a20:	f0 
f0100a21:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0100a28:	00 
f0100a29:	c7 04 24 c0 71 10 f0 	movl   $0xf01071c0,(%esp)
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
f0100a73:	c7 04 24 b4 73 10 f0 	movl   $0xf01073b4,(%esp)
f0100a7a:	e8 73 37 00 00       	call   f01041f2 <cprintf>
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
f0100a93:	c7 04 24 ec 73 10 f0 	movl   $0xf01073ec,(%esp)
f0100a9a:	e8 53 37 00 00       	call   f01041f2 <cprintf>
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
f0100abd:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
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
f0100b27:	c7 04 24 34 74 10 f0 	movl   $0xf0107434,(%esp)
f0100b2e:	e8 bf 36 00 00       	call   f01041f2 <cprintf>
			return 0;
f0100b33:	eb 18                	jmp    f0100b4d <setperm+0xcc>
		}
	}
	cprintf("setperm success.\npage of 0x%x: ", addr);
f0100b35:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100b39:	c7 04 24 8c 74 10 f0 	movl   $0xf010748c,(%esp)
f0100b40:	e8 ad 36 00 00       	call   f01041f2 <cprintf>
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
f0100b6c:	c7 04 24 ac 74 10 f0 	movl   $0xf01074ac,(%esp)
f0100b73:	e8 7a 36 00 00       	call   f01041f2 <cprintf>
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
f0100b9f:	c7 04 24 cf 71 10 f0 	movl   $0xf01071cf,(%esp)
f0100ba6:	e8 47 36 00 00       	call   f01041f2 <cprintf>
	for (; va <= vend; va += PGSIZE) {
f0100bab:	eb 70                	jmp    f0100c1d <showmappings+0xc3>
		pte_t *ppte = pgdir_walk(kern_pgdir, (void *)va, 1);
f0100bad:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100bb4:	00 
f0100bb5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bb9:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0100bbe:	89 04 24             	mov    %eax,(%esp)
f0100bc1:	e8 c3 07 00 00       	call   f0101389 <pgdir_walk>
f0100bc6:	89 c3                	mov    %eax,%ebx
		if (!ppte) panic("showmappings: creating page error!");
f0100bc8:	85 c0                	test   %eax,%eax
f0100bca:	75 1c                	jne    f0100be8 <showmappings+0x8e>
f0100bcc:	c7 44 24 08 f8 74 10 	movl   $0xf01074f8,0x8(%esp)
f0100bd3:	f0 
f0100bd4:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0100bdb:	00 
f0100bdc:	c7 04 24 c0 71 10 f0 	movl   $0xf01071c0,(%esp)
f0100be3:	e8 58 f4 ff ff       	call   f0100040 <_panic>
		if (*ppte & PTE_P) {
f0100be8:	f6 00 01             	testb  $0x1,(%eax)
f0100beb:	74 1a                	je     f0100c07 <showmappings+0xad>
			cprintf("page of 0x%x: ", va);
f0100bed:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bf1:	c7 04 24 e3 71 10 f0 	movl   $0xf01071e3,(%esp)
f0100bf8:	e8 f5 35 00 00       	call   f01041f2 <cprintf>
			print_pte_info(ppte);
f0100bfd:	89 1c 24             	mov    %ebx,(%esp)
f0100c00:	e8 3f fe ff ff       	call   f0100a44 <print_pte_info>
f0100c05:	eb 10                	jmp    f0100c17 <showmappings+0xbd>
		} else cprintf("page not exist: %x\n", va);
f0100c07:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c0b:	c7 04 24 f2 71 10 f0 	movl   $0xf01071f2,(%esp)
f0100c12:	e8 db 35 00 00       	call   f01041f2 <cprintf>
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
f0100c37:	c7 04 24 1c 75 10 f0 	movl   $0xf010751c,(%esp)
f0100c3e:	e8 af 35 00 00       	call   f01041f2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100c43:	c7 04 24 40 75 10 f0 	movl   $0xf0107540,(%esp)
f0100c4a:	e8 a3 35 00 00       	call   f01041f2 <cprintf>
	if (tf != NULL)
f0100c4f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100c53:	74 0b                	je     f0100c60 <monitor+0x32>
		print_trapframe(tf);
f0100c55:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c58:	89 04 24             	mov    %eax,(%esp)
f0100c5b:	e8 5a 38 00 00       	call   f01044ba <print_trapframe>
	while (1) {
		buf = readline("K> ");
f0100c60:	c7 04 24 06 72 10 f0 	movl   $0xf0107206,(%esp)
f0100c67:	e8 b0 52 00 00       	call   f0105f1c <readline>
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
f0100c91:	c7 04 24 0a 72 10 f0 	movl   $0xf010720a,(%esp)
f0100c98:	e8 74 54 00 00       	call   f0106111 <strchr>
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
f0100cb3:	c7 04 24 0f 72 10 f0 	movl   $0xf010720f,(%esp)
f0100cba:	e8 33 35 00 00       	call   f01041f2 <cprintf>
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
f0100cd6:	c7 04 24 0a 72 10 f0 	movl   $0xf010720a,(%esp)
f0100cdd:	e8 2f 54 00 00       	call   f0106111 <strchr>
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
f0100cf8:	bb 00 76 10 f0       	mov    $0xf0107600,%ebx
f0100cfd:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100d02:	8b 03                	mov    (%ebx),%eax
f0100d04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d08:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100d0b:	89 04 24             	mov    %eax,(%esp)
f0100d0e:	e8 ab 53 00 00       	call   f01060be <strcmp>
f0100d13:	85 c0                	test   %eax,%eax
f0100d15:	75 24                	jne    f0100d3b <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100d17:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100d1a:	8b 55 08             	mov    0x8(%ebp),%edx
f0100d1d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d21:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100d24:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d28:	89 34 24             	mov    %esi,(%esp)
f0100d2b:	ff 14 85 08 76 10 f0 	call   *-0xfef89f8(,%eax,4)
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
f0100d4b:	c7 04 24 2c 72 10 f0 	movl   $0xf010722c,(%esp)
f0100d52:	e8 9b 34 00 00       	call   f01041f2 <cprintf>
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
f0100d69:	83 3d 3c 22 33 f0 00 	cmpl   $0x0,0xf033223c
f0100d70:	75 0f                	jne    f0100d81 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d72:	b8 07 50 37 f0       	mov    $0xf0375007,%eax
f0100d77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d7c:	a3 3c 22 33 f0       	mov    %eax,0xf033223c
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n != 0) {
f0100d81:	85 d2                	test   %edx,%edx
f0100d83:	74 26                	je     f0100dab <boot_alloc+0x47>
		result = ROUNDUP((char *) nextfree, PGSIZE);
f0100d85:	8b 0d 3c 22 33 f0    	mov    0xf033223c,%ecx
f0100d8b:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0100d91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		nextfree = ROUNDUP((char *) (nextfree + n), PGSIZE);
f0100d96:	8d 94 11 ff 0f 00 00 	lea    0xfff(%ecx,%edx,1),%edx
f0100d9d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100da3:	89 15 3c 22 33 f0    	mov    %edx,0xf033223c
		return result;
f0100da9:	eb 05                	jmp    f0100db0 <boot_alloc+0x4c>
	}
	else return nextfree;
f0100dab:	a1 3c 22 33 f0       	mov    0xf033223c,%eax
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
f0100dce:	3b 0d 88 2e 33 f0    	cmp    0xf0332e88,%ecx
f0100dd4:	72 20                	jb     f0100df6 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dda:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f0100de1:	f0 
f0100de2:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0100de9:	00 
f0100dea:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0100e2c:	e8 7b 32 00 00       	call   f01040ac <mc146818_read>
f0100e31:	89 c6                	mov    %eax,%esi
f0100e33:	43                   	inc    %ebx
f0100e34:	89 1c 24             	mov    %ebx,(%esp)
f0100e37:	e8 70 32 00 00       	call   f01040ac <mc146818_read>
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
f0100e5c:	8b 15 40 22 33 f0    	mov    0xf0332240,%edx
f0100e62:	85 d2                	test   %edx,%edx
f0100e64:	75 1c                	jne    f0100e82 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100e66:	c7 44 24 08 3c 76 10 	movl   $0xf010763c,0x8(%esp)
f0100e6d:	f0 
f0100e6e:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f0100e75:	00 
f0100e76:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0100e94:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
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
f0100ecc:	a3 40 22 33 f0       	mov    %eax,0xf0332240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ed1:	8b 1d 40 22 33 f0    	mov    0xf0332240,%ebx
f0100ed7:	eb 63                	jmp    f0100f3c <check_page_free_list+0xf4>
f0100ed9:	89 d8                	mov    %ebx,%eax
f0100edb:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
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
f0100ef5:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f0100efb:	72 20                	jb     f0100f1d <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100efd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f01:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f0100f08:	f0 
f0100f09:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f10:	00 
f0100f11:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f0100f18:	e8 23 f1 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100f1d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100f24:	00 
f0100f25:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100f2c:	00 
	return (void *)(pa + KERNBASE);
f0100f2d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f32:	89 04 24             	mov    %eax,(%esp)
f0100f35:	e8 0c 52 00 00       	call   f0106146 <memset>
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
f0100f4d:	8b 15 40 22 33 f0    	mov    0xf0332240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100f53:	8b 0d 90 2e 33 f0    	mov    0xf0332e90,%ecx
		assert(pp < pages + npages);
f0100f59:	a1 88 2e 33 f0       	mov    0xf0332e88,%eax
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
f0100f7c:	c7 44 24 0c ef 7f 10 	movl   $0xf0107fef,0xc(%esp)
f0100f83:	f0 
f0100f84:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0100f8b:	f0 
f0100f8c:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f0100f93:	00 
f0100f94:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0100f9b:	e8 a0 f0 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100fa0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100fa3:	72 24                	jb     f0100fc9 <check_page_free_list+0x181>
f0100fa5:	c7 44 24 0c 10 80 10 	movl   $0xf0108010,0xc(%esp)
f0100fac:	f0 
f0100fad:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0100fb4:	f0 
f0100fb5:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f0100fbc:	00 
f0100fbd:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0100fc4:	e8 77 f0 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100fc9:	89 d0                	mov    %edx,%eax
f0100fcb:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100fce:	a8 07                	test   $0x7,%al
f0100fd0:	74 24                	je     f0100ff6 <check_page_free_list+0x1ae>
f0100fd2:	c7 44 24 0c 60 76 10 	movl   $0xf0107660,0xc(%esp)
f0100fd9:	f0 
f0100fda:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0100fe1:	f0 
f0100fe2:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f0100fe9:	00 
f0100fea:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0100ffe:	c7 44 24 0c 24 80 10 	movl   $0xf0108024,0xc(%esp)
f0101005:	f0 
f0101006:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010100d:	f0 
f010100e:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f0101015:	00 
f0101016:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010101d:	e8 1e f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101022:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101027:	75 24                	jne    f010104d <check_page_free_list+0x205>
f0101029:	c7 44 24 0c 35 80 10 	movl   $0xf0108035,0xc(%esp)
f0101030:	f0 
f0101031:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101038:	f0 
f0101039:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0101040:	00 
f0101041:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101048:	e8 f3 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010104d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101052:	75 24                	jne    f0101078 <check_page_free_list+0x230>
f0101054:	c7 44 24 0c 94 76 10 	movl   $0xf0107694,0xc(%esp)
f010105b:	f0 
f010105c:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101063:	f0 
f0101064:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f010106b:	00 
f010106c:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101073:	e8 c8 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101078:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010107d:	75 24                	jne    f01010a3 <check_page_free_list+0x25b>
f010107f:	c7 44 24 0c 4e 80 10 	movl   $0xf010804e,0xc(%esp)
f0101086:	f0 
f0101087:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010108e:	f0 
f010108f:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101096:	00 
f0101097:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f01010b8:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01010bf:	f0 
f01010c0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01010c7:	00 
f01010c8:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f01010cf:	e8 6c ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01010d4:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f01010da:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f01010dd:	76 24                	jbe    f0101103 <check_page_free_list+0x2bb>
f01010df:	c7 44 24 0c b8 76 10 	movl   $0xf01076b8,0xc(%esp)
f01010e6:	f0 
f01010e7:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01010ee:	f0 
f01010ef:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f01010f6:	00 
f01010f7:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01010fe:	e8 3d ef ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101103:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101108:	75 24                	jne    f010112e <check_page_free_list+0x2e6>
f010110a:	c7 44 24 0c 68 80 10 	movl   $0xf0108068,0xc(%esp)
f0101111:	f0 
f0101112:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101119:	f0 
f010111a:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f0101121:	00 
f0101122:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0101147:	c7 44 24 0c 85 80 10 	movl   $0xf0108085,0xc(%esp)
f010114e:	f0 
f010114f:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101156:	f0 
f0101157:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f010115e:	00 
f010115f:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101166:	e8 d5 ee ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f010116b:	85 db                	test   %ebx,%ebx
f010116d:	7f 24                	jg     f0101193 <check_page_free_list+0x34b>
f010116f:	c7 44 24 0c 97 80 10 	movl   $0xf0108097,0xc(%esp)
f0101176:	f0 
f0101177:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010117e:	f0 
f010117f:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f0101186:	00 
f0101187:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f01011a2:	8b 1d 40 22 33 f0    	mov    0xf0332240,%ebx
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
f01011b8:	03 0d 90 2e 33 f0    	add    0xf0332e90,%ecx
f01011be:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01011c4:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01011c6:	89 d3                	mov    %edx,%ebx
f01011c8:	03 1d 90 2e 33 f0    	add    0xf0332e90,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01011ce:	40                   	inc    %eax
f01011cf:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f01011d5:	72 d8                	jb     f01011af <page_init+0x14>
f01011d7:	89 1d 40 22 33 f0    	mov    %ebx,0xf0332240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	uint32_t index = MPENTRY_PADDR/PGSIZE;
	pages[index].pp_ref = 1;
f01011dd:	a1 90 2e 33 f0       	mov    0xf0332e90,%eax
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
f0101201:	a1 90 2e 33 f0       	mov    0xf0332e90,%eax
f0101206:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	// 3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//    never be allocated.
	char *first_free_page;
	first_free_page = (char *) boot_alloc(0);
f010120d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101212:	e8 4d fb ff ff       	call   f0100d64 <boot_alloc>
	struct PageInfo *tmp = pages[PGNUM(IOPHYSMEM)].pp_link;
f0101217:	8b 15 90 2e 33 f0    	mov    0xf0332e90,%edx
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
f0101241:	03 15 90 2e 33 f0    	add    0xf0332e90,%edx
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
f010125a:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0101261:	f0 
f0101262:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
f0101269:	00 
f010126a:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101271:	e8 ca ed ff ff       	call   f0100040 <_panic>
f0101276:	39 c8                	cmp    %ecx,%eax
f0101278:	72 c0                	jb     f010123a <page_init+0x9f>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	pages[i].pp_link = tmp;
f010127a:	8b 15 90 2e 33 f0    	mov    0xf0332e90,%edx
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
f0101290:	8b 1d 40 22 33 f0    	mov    0xf0332240,%ebx
f0101296:	85 db                	test   %ebx,%ebx
f0101298:	74 6b                	je     f0101305 <page_alloc+0x7c>
	struct PageInfo *result;
	result = page_free_list;
	page_free_list = result->pp_link;
f010129a:	8b 03                	mov    (%ebx),%eax
f010129c:	a3 40 22 33 f0       	mov    %eax,0xf0332240
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
f01012af:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f01012b5:	c1 f8 03             	sar    $0x3,%eax
f01012b8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012bb:	89 c2                	mov    %eax,%edx
f01012bd:	c1 ea 0c             	shr    $0xc,%edx
f01012c0:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f01012c6:	72 20                	jb     f01012e8 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012cc:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01012d3:	f0 
f01012d4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012db:	00 
f01012dc:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f01012e3:	e8 58 ed ff ff       	call   f0100040 <_panic>
f01012e8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01012ef:	00 
f01012f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012f7:	00 
	return (void *)(pa + KERNBASE);
f01012f8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012fd:	89 04 24             	mov    %eax,(%esp)
f0101300:	e8 41 4e 00 00       	call   f0106146 <memset>
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
f010131d:	c7 44 24 08 00 77 10 	movl   $0xf0107700,0x8(%esp)
f0101324:	f0 
f0101325:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f010132c:	00 
f010132d:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101334:	e8 07 ed ff ff       	call   f0100040 <_panic>
	if (pp->pp_link != NULL) panic("page_free: pp->pp_link is not NULL!");
f0101339:	83 38 00             	cmpl   $0x0,(%eax)
f010133c:	74 1c                	je     f010135a <page_free+0x4d>
f010133e:	c7 44 24 08 24 77 10 	movl   $0xf0107724,0x8(%esp)
f0101345:	f0 
f0101346:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f010134d:	00 
f010134e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101355:	e8 e6 ec ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010135a:	8b 15 40 22 33 f0    	mov    0xf0332240,%edx
f0101360:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101362:	a3 40 22 33 f0       	mov    %eax,0xf0332240
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
f01013be:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
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
f01013db:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f01013e1:	72 20                	jb     f0101403 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013e7:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01013ee:	f0 
f01013ef:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
f01013f6:	00 
f01013f7:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f010146e:	c7 44 24 08 48 77 10 	movl   $0xf0107748,0x8(%esp)
f0101475:	f0 
f0101476:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
f010147d:	00 
f010147e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f01014e7:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f01014ed:	72 1c                	jb     f010150b <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01014ef:	c7 44 24 08 74 77 10 	movl   $0xf0107774,0x8(%esp)
f01014f6:	f0 
f01014f7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01014fe:	00 
f01014ff:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f0101506:	e8 35 eb ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010150b:	c1 e0 03             	shl    $0x3,%eax
f010150e:	03 05 90 2e 33 f0    	add    0xf0332e90,%eax
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
f010152e:	e8 41 52 00 00       	call   f0106774 <cpunum>
f0101533:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010153a:	29 c2                	sub    %eax,%edx
f010153c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010153f:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0101546:	00 
f0101547:	74 20                	je     f0101569 <tlb_invalidate+0x41>
f0101549:	e8 26 52 00 00       	call   f0106774 <cpunum>
f010154e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101555:	29 c2                	sub    %eax,%edx
f0101557:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010155a:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
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
f010160c:	2b 35 90 2e 33 f0    	sub    0xf0332e90,%esi
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
f010163e:	8b 15 00 a3 12 f0    	mov    0xf012a300,%edx
f0101644:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101647:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010164c:	76 1c                	jbe    f010166a <mmio_map_region+0x36>
		panic("mmio_map_region: too big for MMIOLIM!");
f010164e:	c7 44 24 08 94 77 10 	movl   $0xf0107794,0x8(%esp)
f0101655:	f0 
f0101656:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
f010165d:	00 
f010165e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101665:	e8 d6 e9 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, ROUNDUP(size, PGSIZE), pa, PTE_PCD | PTE_PWT | PTE_W);
f010166a:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0101670:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101676:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f010167d:	00 
f010167e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101681:	89 04 24             	mov    %eax,(%esp)
f0101684:	89 d9                	mov    %ebx,%ecx
f0101686:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010168b:	e8 98 fd ff ff       	call   f0101428 <boot_map_region>
	base += ROUNDUP(size, PGSIZE);
f0101690:	a1 00 a3 12 f0       	mov    0xf012a300,%eax
f0101695:	01 c3                	add    %eax,%ebx
f0101697:	89 1d 00 a3 12 f0    	mov    %ebx,0xf012a300
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
f01016c8:	89 15 38 22 33 f0    	mov    %edx,0xf0332238
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
f01016f4:	89 15 88 2e 33 f0    	mov    %edx,0xf0332e88
f01016fa:	eb 0c                	jmp    f0101708 <mem_init+0x65>
	else
		npages = npages_basemem;
f01016fc:	8b 15 38 22 33 f0    	mov    0xf0332238,%edx
f0101702:	89 15 88 2e 33 f0    	mov    %edx,0xf0332e88

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
f0101712:	a1 38 22 33 f0       	mov    0xf0332238,%eax
f0101717:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010171a:	c1 e8 0a             	shr    $0xa,%eax
f010171d:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101721:	a1 88 2e 33 f0       	mov    0xf0332e88,%eax
f0101726:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101729:	c1 e8 0a             	shr    $0xa,%eax
f010172c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101730:	c7 04 24 bc 77 10 f0 	movl   $0xf01077bc,(%esp)
f0101737:	e8 b6 2a 00 00       	call   f01041f2 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010173c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101741:	e8 1e f6 ff ff       	call   f0100d64 <boot_alloc>
f0101746:	a3 8c 2e 33 f0       	mov    %eax,0xf0332e8c
	memset(kern_pgdir, 0, PGSIZE);
f010174b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101752:	00 
f0101753:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010175a:	00 
f010175b:	89 04 24             	mov    %eax,(%esp)
f010175e:	e8 e3 49 00 00       	call   f0106146 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101763:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101768:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010176d:	77 20                	ja     f010178f <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010176f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101773:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f010177a:	f0 
f010177b:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
f0101782:	00 
f0101783:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f010179e:	a1 88 2e 33 f0       	mov    0xf0332e88,%eax
f01017a3:	c1 e0 03             	shl    $0x3,%eax
f01017a6:	e8 b9 f5 ff ff       	call   f0100d64 <boot_alloc>
f01017ab:	a3 90 2e 33 f0       	mov    %eax,0xf0332e90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f01017b0:	8b 15 88 2e 33 f0    	mov    0xf0332e88,%edx
f01017b6:	c1 e2 03             	shl    $0x3,%edx
f01017b9:	89 54 24 08          	mov    %edx,0x8(%esp)
f01017bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01017c4:	00 
f01017c5:	89 04 24             	mov    %eax,(%esp)
f01017c8:	e8 79 49 00 00       	call   f0106146 <memset>


	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f01017cd:	b8 00 b0 02 00       	mov    $0x2b000,%eax
f01017d2:	e8 8d f5 ff ff       	call   f0100d64 <boot_alloc>
f01017d7:	a3 48 22 33 f0       	mov    %eax,0xf0332248
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
f01017eb:	83 3d 90 2e 33 f0 00 	cmpl   $0x0,0xf0332e90
f01017f2:	75 1c                	jne    f0101810 <mem_init+0x16d>
		panic("'pages' is a null pointer!");
f01017f4:	c7 44 24 08 a8 80 10 	movl   $0xf01080a8,0x8(%esp)
f01017fb:	f0 
f01017fc:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101803:	00 
f0101804:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010180b:	e8 30 e8 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101810:	a1 40 22 33 f0       	mov    0xf0332240,%eax
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
f0101835:	c7 44 24 0c c3 80 10 	movl   $0xf01080c3,0xc(%esp)
f010183c:	f0 
f010183d:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101844:	f0 
f0101845:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f010184c:	00 
f010184d:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101854:	e8 e7 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101859:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101860:	e8 24 fa ff ff       	call   f0101289 <page_alloc>
f0101865:	89 c7                	mov    %eax,%edi
f0101867:	85 c0                	test   %eax,%eax
f0101869:	75 24                	jne    f010188f <mem_init+0x1ec>
f010186b:	c7 44 24 0c d9 80 10 	movl   $0xf01080d9,0xc(%esp)
f0101872:	f0 
f0101873:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010187a:	f0 
f010187b:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f0101882:	00 
f0101883:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010188a:	e8 b1 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010188f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101896:	e8 ee f9 ff ff       	call   f0101289 <page_alloc>
f010189b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010189e:	85 c0                	test   %eax,%eax
f01018a0:	75 24                	jne    f01018c6 <mem_init+0x223>
f01018a2:	c7 44 24 0c ef 80 10 	movl   $0xf01080ef,0xc(%esp)
f01018a9:	f0 
f01018aa:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01018b1:	f0 
f01018b2:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f01018b9:	00 
f01018ba:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01018c1:	e8 7a e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018c6:	39 fe                	cmp    %edi,%esi
f01018c8:	75 24                	jne    f01018ee <mem_init+0x24b>
f01018ca:	c7 44 24 0c 05 81 10 	movl   $0xf0108105,0xc(%esp)
f01018d1:	f0 
f01018d2:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01018d9:	f0 
f01018da:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f01018e1:	00 
f01018e2:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01018e9:	e8 52 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018ee:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01018f1:	74 05                	je     f01018f8 <mem_init+0x255>
f01018f3:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018f6:	75 24                	jne    f010191c <mem_init+0x279>
f01018f8:	c7 44 24 0c f8 77 10 	movl   $0xf01077f8,0xc(%esp)
f01018ff:	f0 
f0101900:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101907:	f0 
f0101908:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f010190f:	00 
f0101910:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101917:	e8 24 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010191c:	8b 15 90 2e 33 f0    	mov    0xf0332e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101922:	a1 88 2e 33 f0       	mov    0xf0332e88,%eax
f0101927:	c1 e0 0c             	shl    $0xc,%eax
f010192a:	89 f1                	mov    %esi,%ecx
f010192c:	29 d1                	sub    %edx,%ecx
f010192e:	c1 f9 03             	sar    $0x3,%ecx
f0101931:	c1 e1 0c             	shl    $0xc,%ecx
f0101934:	39 c1                	cmp    %eax,%ecx
f0101936:	72 24                	jb     f010195c <mem_init+0x2b9>
f0101938:	c7 44 24 0c 17 81 10 	movl   $0xf0108117,0xc(%esp)
f010193f:	f0 
f0101940:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101947:	f0 
f0101948:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f010194f:	00 
f0101950:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101957:	e8 e4 e6 ff ff       	call   f0100040 <_panic>
f010195c:	89 f9                	mov    %edi,%ecx
f010195e:	29 d1                	sub    %edx,%ecx
f0101960:	c1 f9 03             	sar    $0x3,%ecx
f0101963:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101966:	39 c8                	cmp    %ecx,%eax
f0101968:	77 24                	ja     f010198e <mem_init+0x2eb>
f010196a:	c7 44 24 0c 34 81 10 	movl   $0xf0108134,0xc(%esp)
f0101971:	f0 
f0101972:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101979:	f0 
f010197a:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0101981:	00 
f0101982:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101989:	e8 b2 e6 ff ff       	call   f0100040 <_panic>
f010198e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101991:	29 d1                	sub    %edx,%ecx
f0101993:	89 ca                	mov    %ecx,%edx
f0101995:	c1 fa 03             	sar    $0x3,%edx
f0101998:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010199b:	39 d0                	cmp    %edx,%eax
f010199d:	77 24                	ja     f01019c3 <mem_init+0x320>
f010199f:	c7 44 24 0c 51 81 10 	movl   $0xf0108151,0xc(%esp)
f01019a6:	f0 
f01019a7:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01019ae:	f0 
f01019af:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f01019b6:	00 
f01019b7:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01019be:	e8 7d e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019c3:	a1 40 22 33 f0       	mov    0xf0332240,%eax
f01019c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019cb:	c7 05 40 22 33 f0 00 	movl   $0x0,0xf0332240
f01019d2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019dc:	e8 a8 f8 ff ff       	call   f0101289 <page_alloc>
f01019e1:	85 c0                	test   %eax,%eax
f01019e3:	74 24                	je     f0101a09 <mem_init+0x366>
f01019e5:	c7 44 24 0c 6e 81 10 	movl   $0xf010816e,0xc(%esp)
f01019ec:	f0 
f01019ed:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01019f4:	f0 
f01019f5:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f01019fc:	00 
f01019fd:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0101a36:	c7 44 24 0c c3 80 10 	movl   $0xf01080c3,0xc(%esp)
f0101a3d:	f0 
f0101a3e:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101a45:	f0 
f0101a46:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f0101a4d:	00 
f0101a4e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101a55:	e8 e6 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a61:	e8 23 f8 ff ff       	call   f0101289 <page_alloc>
f0101a66:	89 c7                	mov    %eax,%edi
f0101a68:	85 c0                	test   %eax,%eax
f0101a6a:	75 24                	jne    f0101a90 <mem_init+0x3ed>
f0101a6c:	c7 44 24 0c d9 80 10 	movl   $0xf01080d9,0xc(%esp)
f0101a73:	f0 
f0101a74:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101a7b:	f0 
f0101a7c:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f0101a83:	00 
f0101a84:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101a8b:	e8 b0 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a97:	e8 ed f7 ff ff       	call   f0101289 <page_alloc>
f0101a9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a9f:	85 c0                	test   %eax,%eax
f0101aa1:	75 24                	jne    f0101ac7 <mem_init+0x424>
f0101aa3:	c7 44 24 0c ef 80 10 	movl   $0xf01080ef,0xc(%esp)
f0101aaa:	f0 
f0101aab:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101ab2:	f0 
f0101ab3:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f0101aba:	00 
f0101abb:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101ac2:	e8 79 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ac7:	39 fe                	cmp    %edi,%esi
f0101ac9:	75 24                	jne    f0101aef <mem_init+0x44c>
f0101acb:	c7 44 24 0c 05 81 10 	movl   $0xf0108105,0xc(%esp)
f0101ad2:	f0 
f0101ad3:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101ada:	f0 
f0101adb:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0101ae2:	00 
f0101ae3:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101aea:	e8 51 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101aef:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101af2:	74 05                	je     f0101af9 <mem_init+0x456>
f0101af4:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101af7:	75 24                	jne    f0101b1d <mem_init+0x47a>
f0101af9:	c7 44 24 0c f8 77 10 	movl   $0xf01077f8,0xc(%esp)
f0101b00:	f0 
f0101b01:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101b08:	f0 
f0101b09:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f0101b10:	00 
f0101b11:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101b18:	e8 23 e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101b1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b24:	e8 60 f7 ff ff       	call   f0101289 <page_alloc>
f0101b29:	85 c0                	test   %eax,%eax
f0101b2b:	74 24                	je     f0101b51 <mem_init+0x4ae>
f0101b2d:	c7 44 24 0c 6e 81 10 	movl   $0xf010816e,0xc(%esp)
f0101b34:	f0 
f0101b35:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101b3c:	f0 
f0101b3d:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0101b44:	00 
f0101b45:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101b4c:	e8 ef e4 ff ff       	call   f0100040 <_panic>
f0101b51:	89 f0                	mov    %esi,%eax
f0101b53:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f0101b59:	c1 f8 03             	sar    $0x3,%eax
f0101b5c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b5f:	89 c2                	mov    %eax,%edx
f0101b61:	c1 ea 0c             	shr    $0xc,%edx
f0101b64:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f0101b6a:	72 20                	jb     f0101b8c <mem_init+0x4e9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b70:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f0101b77:	f0 
f0101b78:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101b7f:	00 
f0101b80:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
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
f0101ba4:	e8 9d 45 00 00       	call   f0106146 <memset>
	page_free(pp0);
f0101ba9:	89 34 24             	mov    %esi,(%esp)
f0101bac:	e8 5c f7 ff ff       	call   f010130d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101bb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101bb8:	e8 cc f6 ff ff       	call   f0101289 <page_alloc>
f0101bbd:	85 c0                	test   %eax,%eax
f0101bbf:	75 24                	jne    f0101be5 <mem_init+0x542>
f0101bc1:	c7 44 24 0c 7d 81 10 	movl   $0xf010817d,0xc(%esp)
f0101bc8:	f0 
f0101bc9:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101bd0:	f0 
f0101bd1:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0101bd8:	00 
f0101bd9:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101be0:	e8 5b e4 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101be5:	39 c6                	cmp    %eax,%esi
f0101be7:	74 24                	je     f0101c0d <mem_init+0x56a>
f0101be9:	c7 44 24 0c 9b 81 10 	movl   $0xf010819b,0xc(%esp)
f0101bf0:	f0 
f0101bf1:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101bf8:	f0 
f0101bf9:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0101c00:	00 
f0101c01:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101c08:	e8 33 e4 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c0d:	89 f2                	mov    %esi,%edx
f0101c0f:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0101c15:	c1 fa 03             	sar    $0x3,%edx
f0101c18:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c1b:	89 d0                	mov    %edx,%eax
f0101c1d:	c1 e8 0c             	shr    $0xc,%eax
f0101c20:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0101c26:	72 20                	jb     f0101c48 <mem_init+0x5a5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c28:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101c2c:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f0101c33:	f0 
f0101c34:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101c3b:	00 
f0101c3c:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
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
f0101c59:	c7 44 24 0c ab 81 10 	movl   $0xf01081ab,0xc(%esp)
f0101c60:	f0 
f0101c61:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101c68:	f0 
f0101c69:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101c70:	00 
f0101c71:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0101c85:	89 15 40 22 33 f0    	mov    %edx,0xf0332240

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
f0101ca6:	a1 40 22 33 f0       	mov    0xf0332240,%eax
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
f0101cb8:	c7 44 24 0c b5 81 10 	movl   $0xf01081b5,0xc(%esp)
f0101cbf:	f0 
f0101cc0:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101cc7:	f0 
f0101cc8:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101ccf:	00 
f0101cd0:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101cd7:	e8 64 e3 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101cdc:	c7 04 24 18 78 10 f0 	movl   $0xf0107818,(%esp)
f0101ce3:	e8 0a 25 00 00       	call   f01041f2 <cprintf>
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
f0101cfa:	c7 44 24 0c c3 80 10 	movl   $0xf01080c3,0xc(%esp)
f0101d01:	f0 
f0101d02:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101d09:	f0 
f0101d0a:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101d11:	00 
f0101d12:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101d19:	e8 22 e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d25:	e8 5f f5 ff ff       	call   f0101289 <page_alloc>
f0101d2a:	89 c6                	mov    %eax,%esi
f0101d2c:	85 c0                	test   %eax,%eax
f0101d2e:	75 24                	jne    f0101d54 <mem_init+0x6b1>
f0101d30:	c7 44 24 0c d9 80 10 	movl   $0xf01080d9,0xc(%esp)
f0101d37:	f0 
f0101d38:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101d3f:	f0 
f0101d40:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101d47:	00 
f0101d48:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101d4f:	e8 ec e2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d5b:	e8 29 f5 ff ff       	call   f0101289 <page_alloc>
f0101d60:	89 c3                	mov    %eax,%ebx
f0101d62:	85 c0                	test   %eax,%eax
f0101d64:	75 24                	jne    f0101d8a <mem_init+0x6e7>
f0101d66:	c7 44 24 0c ef 80 10 	movl   $0xf01080ef,0xc(%esp)
f0101d6d:	f0 
f0101d6e:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101d75:	f0 
f0101d76:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101d7d:	00 
f0101d7e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101d85:	e8 b6 e2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d8a:	39 f7                	cmp    %esi,%edi
f0101d8c:	75 24                	jne    f0101db2 <mem_init+0x70f>
f0101d8e:	c7 44 24 0c 05 81 10 	movl   $0xf0108105,0xc(%esp)
f0101d95:	f0 
f0101d96:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101d9d:	f0 
f0101d9e:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101da5:	00 
f0101da6:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101dad:	e8 8e e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101db2:	39 c6                	cmp    %eax,%esi
f0101db4:	74 04                	je     f0101dba <mem_init+0x717>
f0101db6:	39 c7                	cmp    %eax,%edi
f0101db8:	75 24                	jne    f0101dde <mem_init+0x73b>
f0101dba:	c7 44 24 0c f8 77 10 	movl   $0xf01077f8,0xc(%esp)
f0101dc1:	f0 
f0101dc2:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101dc9:	f0 
f0101dca:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101dd1:	00 
f0101dd2:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101dd9:	e8 62 e2 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101dde:	8b 15 40 22 33 f0    	mov    0xf0332240,%edx
f0101de4:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101de7:	c7 05 40 22 33 f0 00 	movl   $0x0,0xf0332240
f0101dee:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101df1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101df8:	e8 8c f4 ff ff       	call   f0101289 <page_alloc>
f0101dfd:	85 c0                	test   %eax,%eax
f0101dff:	74 24                	je     f0101e25 <mem_init+0x782>
f0101e01:	c7 44 24 0c 6e 81 10 	movl   $0xf010816e,0xc(%esp)
f0101e08:	f0 
f0101e09:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101e10:	f0 
f0101e11:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101e18:	00 
f0101e19:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101e20:	e8 1b e2 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e28:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101e2c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101e33:	00 
f0101e34:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0101e39:	89 04 24             	mov    %eax,(%esp)
f0101e3c:	e8 6f f6 ff ff       	call   f01014b0 <page_lookup>
f0101e41:	85 c0                	test   %eax,%eax
f0101e43:	74 24                	je     f0101e69 <mem_init+0x7c6>
f0101e45:	c7 44 24 0c 38 78 10 	movl   $0xf0107838,0xc(%esp)
f0101e4c:	f0 
f0101e4d:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101e54:	f0 
f0101e55:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101e5c:	00 
f0101e5d:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101e64:	e8 d7 e1 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e69:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e70:	00 
f0101e71:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e78:	00 
f0101e79:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e7d:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0101e82:	89 04 24             	mov    %eax,(%esp)
f0101e85:	e8 38 f7 ff ff       	call   f01015c2 <page_insert>
f0101e8a:	85 c0                	test   %eax,%eax
f0101e8c:	78 24                	js     f0101eb2 <mem_init+0x80f>
f0101e8e:	c7 44 24 0c 70 78 10 	movl   $0xf0107870,0xc(%esp)
f0101e95:	f0 
f0101e96:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101e9d:	f0 
f0101e9e:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0101ea5:	00 
f0101ea6:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0101ece:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0101ed3:	89 04 24             	mov    %eax,(%esp)
f0101ed6:	e8 e7 f6 ff ff       	call   f01015c2 <page_insert>
f0101edb:	85 c0                	test   %eax,%eax
f0101edd:	74 24                	je     f0101f03 <mem_init+0x860>
f0101edf:	c7 44 24 0c a0 78 10 	movl   $0xf01078a0,0xc(%esp)
f0101ee6:	f0 
f0101ee7:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101eee:	f0 
f0101eef:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101ef6:	00 
f0101ef7:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101efe:	e8 3d e1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f03:	8b 0d 8c 2e 33 f0    	mov    0xf0332e8c,%ecx
f0101f09:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f0c:	a1 90 2e 33 f0       	mov    0xf0332e90,%eax
f0101f11:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101f14:	8b 11                	mov    (%ecx),%edx
f0101f16:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f1c:	89 f8                	mov    %edi,%eax
f0101f1e:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101f21:	c1 f8 03             	sar    $0x3,%eax
f0101f24:	c1 e0 0c             	shl    $0xc,%eax
f0101f27:	39 c2                	cmp    %eax,%edx
f0101f29:	74 24                	je     f0101f4f <mem_init+0x8ac>
f0101f2b:	c7 44 24 0c d0 78 10 	movl   $0xf01078d0,0xc(%esp)
f0101f32:	f0 
f0101f33:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101f3a:	f0 
f0101f3b:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101f42:	00 
f0101f43:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0101f6b:	c7 44 24 0c f8 78 10 	movl   $0xf01078f8,0xc(%esp)
f0101f72:	f0 
f0101f73:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101f82:	00 
f0101f83:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101f8a:	e8 b1 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101f8f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f94:	74 24                	je     f0101fba <mem_init+0x917>
f0101f96:	c7 44 24 0c c0 81 10 	movl   $0xf01081c0,0xc(%esp)
f0101f9d:	f0 
f0101f9e:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101fad:	00 
f0101fae:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0101fb5:	e8 86 e0 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101fba:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101fbf:	74 24                	je     f0101fe5 <mem_init+0x942>
f0101fc1:	c7 44 24 0c d1 81 10 	movl   $0xf01081d1,0xc(%esp)
f0101fc8:	f0 
f0101fc9:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0101fd0:	f0 
f0101fd1:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101fd8:	00 
f0101fd9:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102008:	c7 44 24 0c 28 79 10 	movl   $0xf0107928,0xc(%esp)
f010200f:	f0 
f0102010:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102017:	f0 
f0102018:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f010201f:	00 
f0102020:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102027:	e8 14 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010202c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102031:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102036:	e8 77 ed ff ff       	call   f0100db2 <check_va2pa>
f010203b:	89 da                	mov    %ebx,%edx
f010203d:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0102043:	c1 fa 03             	sar    $0x3,%edx
f0102046:	c1 e2 0c             	shl    $0xc,%edx
f0102049:	39 d0                	cmp    %edx,%eax
f010204b:	74 24                	je     f0102071 <mem_init+0x9ce>
f010204d:	c7 44 24 0c 64 79 10 	movl   $0xf0107964,0xc(%esp)
f0102054:	f0 
f0102055:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010205c:	f0 
f010205d:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102064:	00 
f0102065:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010206c:	e8 cf df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102071:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102076:	74 24                	je     f010209c <mem_init+0x9f9>
f0102078:	c7 44 24 0c e2 81 10 	movl   $0xf01081e2,0xc(%esp)
f010207f:	f0 
f0102080:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102087:	f0 
f0102088:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f010208f:	00 
f0102090:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102097:	e8 a4 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010209c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020a3:	e8 e1 f1 ff ff       	call   f0101289 <page_alloc>
f01020a8:	85 c0                	test   %eax,%eax
f01020aa:	74 24                	je     f01020d0 <mem_init+0xa2d>
f01020ac:	c7 44 24 0c 6e 81 10 	movl   $0xf010816e,0xc(%esp)
f01020b3:	f0 
f01020b4:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01020bb:	f0 
f01020bc:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f01020c3:	00 
f01020c4:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01020cb:	e8 70 df ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020d0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020d7:	00 
f01020d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020df:	00 
f01020e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020e4:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01020e9:	89 04 24             	mov    %eax,(%esp)
f01020ec:	e8 d1 f4 ff ff       	call   f01015c2 <page_insert>
f01020f1:	85 c0                	test   %eax,%eax
f01020f3:	74 24                	je     f0102119 <mem_init+0xa76>
f01020f5:	c7 44 24 0c 28 79 10 	movl   $0xf0107928,0xc(%esp)
f01020fc:	f0 
f01020fd:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102104:	f0 
f0102105:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f010210c:	00 
f010210d:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102114:	e8 27 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102119:	ba 00 10 00 00       	mov    $0x1000,%edx
f010211e:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102123:	e8 8a ec ff ff       	call   f0100db2 <check_va2pa>
f0102128:	89 da                	mov    %ebx,%edx
f010212a:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0102130:	c1 fa 03             	sar    $0x3,%edx
f0102133:	c1 e2 0c             	shl    $0xc,%edx
f0102136:	39 d0                	cmp    %edx,%eax
f0102138:	74 24                	je     f010215e <mem_init+0xabb>
f010213a:	c7 44 24 0c 64 79 10 	movl   $0xf0107964,0xc(%esp)
f0102141:	f0 
f0102142:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102149:	f0 
f010214a:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102151:	00 
f0102152:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102159:	e8 e2 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010215e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102163:	74 24                	je     f0102189 <mem_init+0xae6>
f0102165:	c7 44 24 0c e2 81 10 	movl   $0xf01081e2,0xc(%esp)
f010216c:	f0 
f010216d:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102174:	f0 
f0102175:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f010217c:	00 
f010217d:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102184:	e8 b7 de ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102190:	e8 f4 f0 ff ff       	call   f0101289 <page_alloc>
f0102195:	85 c0                	test   %eax,%eax
f0102197:	74 24                	je     f01021bd <mem_init+0xb1a>
f0102199:	c7 44 24 0c 6e 81 10 	movl   $0xf010816e,0xc(%esp)
f01021a0:	f0 
f01021a1:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01021a8:	f0 
f01021a9:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f01021b0:	00 
f01021b1:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01021b8:	e8 83 de ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01021bd:	8b 15 8c 2e 33 f0    	mov    0xf0332e8c,%edx
f01021c3:	8b 02                	mov    (%edx),%eax
f01021c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021ca:	89 c1                	mov    %eax,%ecx
f01021cc:	c1 e9 0c             	shr    $0xc,%ecx
f01021cf:	3b 0d 88 2e 33 f0    	cmp    0xf0332e88,%ecx
f01021d5:	72 20                	jb     f01021f7 <mem_init+0xb54>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01021db:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f01021ea:	00 
f01021eb:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102221:	c7 44 24 0c 94 79 10 	movl   $0xf0107994,0xc(%esp)
f0102228:	f0 
f0102229:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102230:	f0 
f0102231:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102238:	00 
f0102239:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102240:	e8 fb dd ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102245:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010224c:	00 
f010224d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102254:	00 
f0102255:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102259:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010225e:	89 04 24             	mov    %eax,(%esp)
f0102261:	e8 5c f3 ff ff       	call   f01015c2 <page_insert>
f0102266:	85 c0                	test   %eax,%eax
f0102268:	74 24                	je     f010228e <mem_init+0xbeb>
f010226a:	c7 44 24 0c d4 79 10 	movl   $0xf01079d4,0xc(%esp)
f0102271:	f0 
f0102272:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102279:	f0 
f010227a:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0102281:	00 
f0102282:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102289:	e8 b2 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010228e:	8b 0d 8c 2e 33 f0    	mov    0xf0332e8c,%ecx
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
f01022a5:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f01022ab:	c1 fa 03             	sar    $0x3,%edx
f01022ae:	c1 e2 0c             	shl    $0xc,%edx
f01022b1:	39 d0                	cmp    %edx,%eax
f01022b3:	74 24                	je     f01022d9 <mem_init+0xc36>
f01022b5:	c7 44 24 0c 64 79 10 	movl   $0xf0107964,0xc(%esp)
f01022bc:	f0 
f01022bd:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01022c4:	f0 
f01022c5:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f01022cc:	00 
f01022cd:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01022d4:	e8 67 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01022d9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01022de:	74 24                	je     f0102304 <mem_init+0xc61>
f01022e0:	c7 44 24 0c e2 81 10 	movl   $0xf01081e2,0xc(%esp)
f01022e7:	f0 
f01022e8:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01022ef:	f0 
f01022f0:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f01022f7:	00 
f01022f8:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102324:	c7 44 24 0c 14 7a 10 	movl   $0xf0107a14,0xc(%esp)
f010232b:	f0 
f010232c:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102333:	f0 
f0102334:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f010233b:	00 
f010233c:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102343:	e8 f8 dc ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102348:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010234d:	f6 00 04             	testb  $0x4,(%eax)
f0102350:	75 24                	jne    f0102376 <mem_init+0xcd3>
f0102352:	c7 44 24 0c f3 81 10 	movl   $0xf01081f3,0xc(%esp)
f0102359:	f0 
f010235a:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102361:	f0 
f0102362:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102369:	00 
f010236a:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102396:	c7 44 24 0c 28 79 10 	movl   $0xf0107928,0xc(%esp)
f010239d:	f0 
f010239e:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01023a5:	f0 
f01023a6:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f01023ad:	00 
f01023ae:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01023b5:	e8 86 dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01023ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023c1:	00 
f01023c2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023c9:	00 
f01023ca:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01023cf:	89 04 24             	mov    %eax,(%esp)
f01023d2:	e8 b2 ef ff ff       	call   f0101389 <pgdir_walk>
f01023d7:	f6 00 02             	testb  $0x2,(%eax)
f01023da:	75 24                	jne    f0102400 <mem_init+0xd5d>
f01023dc:	c7 44 24 0c 48 7a 10 	movl   $0xf0107a48,0xc(%esp)
f01023e3:	f0 
f01023e4:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01023eb:	f0 
f01023ec:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01023f3:	00 
f01023f4:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01023fb:	e8 40 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102400:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102407:	00 
f0102408:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010240f:	00 
f0102410:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102415:	89 04 24             	mov    %eax,(%esp)
f0102418:	e8 6c ef ff ff       	call   f0101389 <pgdir_walk>
f010241d:	f6 00 04             	testb  $0x4,(%eax)
f0102420:	74 24                	je     f0102446 <mem_init+0xda3>
f0102422:	c7 44 24 0c 7c 7a 10 	movl   $0xf0107a7c,0xc(%esp)
f0102429:	f0 
f010242a:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102431:	f0 
f0102432:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0102439:	00 
f010243a:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102441:	e8 fa db ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102446:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010244d:	00 
f010244e:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102455:	00 
f0102456:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010245a:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010245f:	89 04 24             	mov    %eax,(%esp)
f0102462:	e8 5b f1 ff ff       	call   f01015c2 <page_insert>
f0102467:	85 c0                	test   %eax,%eax
f0102469:	78 24                	js     f010248f <mem_init+0xdec>
f010246b:	c7 44 24 0c b4 7a 10 	movl   $0xf0107ab4,0xc(%esp)
f0102472:	f0 
f0102473:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010247a:	f0 
f010247b:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102482:	00 
f0102483:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010248a:	e8 b1 db ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010248f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102496:	00 
f0102497:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010249e:	00 
f010249f:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024a3:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01024a8:	89 04 24             	mov    %eax,(%esp)
f01024ab:	e8 12 f1 ff ff       	call   f01015c2 <page_insert>
f01024b0:	85 c0                	test   %eax,%eax
f01024b2:	74 24                	je     f01024d8 <mem_init+0xe35>
f01024b4:	c7 44 24 0c ec 7a 10 	movl   $0xf0107aec,0xc(%esp)
f01024bb:	f0 
f01024bc:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01024c3:	f0 
f01024c4:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f01024cb:	00 
f01024cc:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01024d3:	e8 68 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024df:	00 
f01024e0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024e7:	00 
f01024e8:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01024ed:	89 04 24             	mov    %eax,(%esp)
f01024f0:	e8 94 ee ff ff       	call   f0101389 <pgdir_walk>
f01024f5:	f6 00 04             	testb  $0x4,(%eax)
f01024f8:	74 24                	je     f010251e <mem_init+0xe7b>
f01024fa:	c7 44 24 0c 7c 7a 10 	movl   $0xf0107a7c,0xc(%esp)
f0102501:	f0 
f0102502:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102509:	f0 
f010250a:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0102511:	00 
f0102512:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102519:	e8 22 db ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010251e:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102523:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102526:	ba 00 00 00 00       	mov    $0x0,%edx
f010252b:	e8 82 e8 ff ff       	call   f0100db2 <check_va2pa>
f0102530:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102533:	89 f0                	mov    %esi,%eax
f0102535:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f010253b:	c1 f8 03             	sar    $0x3,%eax
f010253e:	c1 e0 0c             	shl    $0xc,%eax
f0102541:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102544:	74 24                	je     f010256a <mem_init+0xec7>
f0102546:	c7 44 24 0c 28 7b 10 	movl   $0xf0107b28,0xc(%esp)
f010254d:	f0 
f010254e:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102555:	f0 
f0102556:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f010255d:	00 
f010255e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102565:	e8 d6 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010256a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010256f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102572:	e8 3b e8 ff ff       	call   f0100db2 <check_va2pa>
f0102577:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010257a:	74 24                	je     f01025a0 <mem_init+0xefd>
f010257c:	c7 44 24 0c 54 7b 10 	movl   $0xf0107b54,0xc(%esp)
f0102583:	f0 
f0102584:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010258b:	f0 
f010258c:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102593:	00 
f0102594:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010259b:	e8 a0 da ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01025a0:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f01025a5:	74 24                	je     f01025cb <mem_init+0xf28>
f01025a7:	c7 44 24 0c 09 82 10 	movl   $0xf0108209,0xc(%esp)
f01025ae:	f0 
f01025af:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01025b6:	f0 
f01025b7:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f01025be:	00 
f01025bf:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01025c6:	e8 75 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025cb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025d0:	74 24                	je     f01025f6 <mem_init+0xf53>
f01025d2:	c7 44 24 0c 1a 82 10 	movl   $0xf010821a,0xc(%esp)
f01025d9:	f0 
f01025da:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01025e1:	f0 
f01025e2:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f01025e9:	00 
f01025ea:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01025f1:	e8 4a da ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01025f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01025fd:	e8 87 ec ff ff       	call   f0101289 <page_alloc>
f0102602:	85 c0                	test   %eax,%eax
f0102604:	74 04                	je     f010260a <mem_init+0xf67>
f0102606:	39 c3                	cmp    %eax,%ebx
f0102608:	74 24                	je     f010262e <mem_init+0xf8b>
f010260a:	c7 44 24 0c 84 7b 10 	movl   $0xf0107b84,0xc(%esp)
f0102611:	f0 
f0102612:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102619:	f0 
f010261a:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0102621:	00 
f0102622:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102629:	e8 12 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010262e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102635:	00 
f0102636:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010263b:	89 04 24             	mov    %eax,(%esp)
f010263e:	e8 2e ef ff ff       	call   f0101571 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102643:	8b 15 8c 2e 33 f0    	mov    0xf0332e8c,%edx
f0102649:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010264c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102651:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102654:	e8 59 e7 ff ff       	call   f0100db2 <check_va2pa>
f0102659:	83 f8 ff             	cmp    $0xffffffff,%eax
f010265c:	74 24                	je     f0102682 <mem_init+0xfdf>
f010265e:	c7 44 24 0c a8 7b 10 	movl   $0xf0107ba8,0xc(%esp)
f0102665:	f0 
f0102666:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010266d:	f0 
f010266e:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102675:	00 
f0102676:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010267d:	e8 be d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102682:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102687:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010268a:	e8 23 e7 ff ff       	call   f0100db2 <check_va2pa>
f010268f:	89 f2                	mov    %esi,%edx
f0102691:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0102697:	c1 fa 03             	sar    $0x3,%edx
f010269a:	c1 e2 0c             	shl    $0xc,%edx
f010269d:	39 d0                	cmp    %edx,%eax
f010269f:	74 24                	je     f01026c5 <mem_init+0x1022>
f01026a1:	c7 44 24 0c 54 7b 10 	movl   $0xf0107b54,0xc(%esp)
f01026a8:	f0 
f01026a9:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01026b0:	f0 
f01026b1:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01026b8:	00 
f01026b9:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01026c0:	e8 7b d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01026c5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026ca:	74 24                	je     f01026f0 <mem_init+0x104d>
f01026cc:	c7 44 24 0c c0 81 10 	movl   $0xf01081c0,0xc(%esp)
f01026d3:	f0 
f01026d4:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01026db:	f0 
f01026dc:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f01026e3:	00 
f01026e4:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01026eb:	e8 50 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026f0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026f5:	74 24                	je     f010271b <mem_init+0x1078>
f01026f7:	c7 44 24 0c 1a 82 10 	movl   $0xf010821a,0xc(%esp)
f01026fe:	f0 
f01026ff:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102706:	f0 
f0102707:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f010270e:	00 
f010270f:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f010273e:	c7 44 24 0c cc 7b 10 	movl   $0xf0107bcc,0xc(%esp)
f0102745:	f0 
f0102746:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010274d:	f0 
f010274e:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0102755:	00 
f0102756:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010275d:	e8 de d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102762:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102767:	75 24                	jne    f010278d <mem_init+0x10ea>
f0102769:	c7 44 24 0c 2b 82 10 	movl   $0xf010822b,0xc(%esp)
f0102770:	f0 
f0102771:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102778:	f0 
f0102779:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0102780:	00 
f0102781:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102788:	e8 b3 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010278d:	83 3e 00             	cmpl   $0x0,(%esi)
f0102790:	74 24                	je     f01027b6 <mem_init+0x1113>
f0102792:	c7 44 24 0c 37 82 10 	movl   $0xf0108237,0xc(%esp)
f0102799:	f0 
f010279a:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01027a1:	f0 
f01027a2:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f01027a9:	00 
f01027aa:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01027b1:	e8 8a d8 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01027b6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027bd:	00 
f01027be:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01027c3:	89 04 24             	mov    %eax,(%esp)
f01027c6:	e8 a6 ed ff ff       	call   f0101571 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027cb:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f01027d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01027d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01027d8:	e8 d5 e5 ff ff       	call   f0100db2 <check_va2pa>
f01027dd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027e0:	74 24                	je     f0102806 <mem_init+0x1163>
f01027e2:	c7 44 24 0c a8 7b 10 	movl   $0xf0107ba8,0xc(%esp)
f01027e9:	f0 
f01027ea:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01027f1:	f0 
f01027f2:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f01027f9:	00 
f01027fa:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102801:	e8 3a d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102806:	ba 00 10 00 00       	mov    $0x1000,%edx
f010280b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010280e:	e8 9f e5 ff ff       	call   f0100db2 <check_va2pa>
f0102813:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102816:	74 24                	je     f010283c <mem_init+0x1199>
f0102818:	c7 44 24 0c 04 7c 10 	movl   $0xf0107c04,0xc(%esp)
f010281f:	f0 
f0102820:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102827:	f0 
f0102828:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f010282f:	00 
f0102830:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102837:	e8 04 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010283c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102841:	74 24                	je     f0102867 <mem_init+0x11c4>
f0102843:	c7 44 24 0c 4c 82 10 	movl   $0xf010824c,0xc(%esp)
f010284a:	f0 
f010284b:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102852:	f0 
f0102853:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f010285a:	00 
f010285b:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102862:	e8 d9 d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102867:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010286c:	74 24                	je     f0102892 <mem_init+0x11ef>
f010286e:	c7 44 24 0c 1a 82 10 	movl   $0xf010821a,0xc(%esp)
f0102875:	f0 
f0102876:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010287d:	f0 
f010287e:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0102885:	00 
f0102886:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010288d:	e8 ae d7 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102892:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102899:	e8 eb e9 ff ff       	call   f0101289 <page_alloc>
f010289e:	85 c0                	test   %eax,%eax
f01028a0:	74 04                	je     f01028a6 <mem_init+0x1203>
f01028a2:	39 c6                	cmp    %eax,%esi
f01028a4:	74 24                	je     f01028ca <mem_init+0x1227>
f01028a6:	c7 44 24 0c 2c 7c 10 	movl   $0xf0107c2c,0xc(%esp)
f01028ad:	f0 
f01028ae:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01028b5:	f0 
f01028b6:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f01028bd:	00 
f01028be:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01028c5:	e8 76 d7 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01028ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028d1:	e8 b3 e9 ff ff       	call   f0101289 <page_alloc>
f01028d6:	85 c0                	test   %eax,%eax
f01028d8:	74 24                	je     f01028fe <mem_init+0x125b>
f01028da:	c7 44 24 0c 6e 81 10 	movl   $0xf010816e,0xc(%esp)
f01028e1:	f0 
f01028e2:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01028e9:	f0 
f01028ea:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01028f1:	00 
f01028f2:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01028f9:	e8 42 d7 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028fe:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102903:	8b 08                	mov    (%eax),%ecx
f0102905:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010290b:	89 fa                	mov    %edi,%edx
f010290d:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0102913:	c1 fa 03             	sar    $0x3,%edx
f0102916:	c1 e2 0c             	shl    $0xc,%edx
f0102919:	39 d1                	cmp    %edx,%ecx
f010291b:	74 24                	je     f0102941 <mem_init+0x129e>
f010291d:	c7 44 24 0c d0 78 10 	movl   $0xf01078d0,0xc(%esp)
f0102924:	f0 
f0102925:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010292c:	f0 
f010292d:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102934:	00 
f0102935:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010293c:	e8 ff d6 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102941:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102947:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010294c:	74 24                	je     f0102972 <mem_init+0x12cf>
f010294e:	c7 44 24 0c d1 81 10 	movl   $0xf01081d1,0xc(%esp)
f0102955:	f0 
f0102956:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010295d:	f0 
f010295e:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102965:	00 
f0102966:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102990:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102995:	89 04 24             	mov    %eax,(%esp)
f0102998:	e8 ec e9 ff ff       	call   f0101389 <pgdir_walk>
f010299d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01029a0:	8b 0d 8c 2e 33 f0    	mov    0xf0332e8c,%ecx
f01029a6:	8b 51 04             	mov    0x4(%ecx),%edx
f01029a9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01029af:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029b2:	8b 15 88 2e 33 f0    	mov    0xf0332e88,%edx
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
f01029d3:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01029da:	f0 
f01029db:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01029e2:	00 
f01029e3:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01029ea:	e8 51 d6 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01029ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01029f2:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01029f8:	39 d0                	cmp    %edx,%eax
f01029fa:	74 24                	je     f0102a20 <mem_init+0x137d>
f01029fc:	c7 44 24 0c 5d 82 10 	movl   $0xf010825d,0xc(%esp)
f0102a03:	f0 
f0102a04:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102a0b:	f0 
f0102a0c:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102a13:	00 
f0102a14:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102a2f:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
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
f0102a49:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f0102a50:	f0 
f0102a51:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102a58:	00 
f0102a59:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
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
f0102a7d:	e8 c4 36 00 00       	call   f0106146 <memset>
	page_free(pp0);
f0102a82:	89 3c 24             	mov    %edi,(%esp)
f0102a85:	e8 83 e8 ff ff       	call   f010130d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102a8a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102a91:	00 
f0102a92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a99:	00 
f0102a9a:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102a9f:	89 04 24             	mov    %eax,(%esp)
f0102aa2:	e8 e2 e8 ff ff       	call   f0101389 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102aa7:	89 fa                	mov    %edi,%edx
f0102aa9:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f0102aaf:	c1 fa 03             	sar    $0x3,%edx
f0102ab2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ab5:	89 d0                	mov    %edx,%eax
f0102ab7:	c1 e8 0c             	shr    $0xc,%eax
f0102aba:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0102ac0:	72 20                	jb     f0102ae2 <mem_init+0x143f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ac2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ac6:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f0102acd:	f0 
f0102ace:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102ad5:	00 
f0102ad6:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
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
f0102af6:	c7 44 24 0c 75 82 10 	movl   $0xf0108275,0xc(%esp)
f0102afd:	f0 
f0102afe:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102b05:	f0 
f0102b06:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102b0d:	00 
f0102b0e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102b21:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102b26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102b2c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102b32:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102b35:	89 0d 40 22 33 f0    	mov    %ecx,0xf0332240

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
f0102b94:	c7 44 24 0c 50 7c 10 	movl   $0xf0107c50,0xc(%esp)
f0102b9b:	f0 
f0102b9c:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102ba3:	f0 
f0102ba4:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102bab:	00 
f0102bac:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102bb3:	e8 88 d4 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102bb8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102bbe:	76 0e                	jbe    f0102bce <mem_init+0x152b>
f0102bc0:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102bc6:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102bcc:	76 24                	jbe    f0102bf2 <mem_init+0x154f>
f0102bce:	c7 44 24 0c 78 7c 10 	movl   $0xf0107c78,0xc(%esp)
f0102bd5:	f0 
f0102bd6:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102bdd:	f0 
f0102bde:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102be5:	00 
f0102be6:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102bfe:	c7 44 24 0c a0 7c 10 	movl   $0xf0107ca0,0xc(%esp)
f0102c05:	f0 
f0102c06:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102c0d:	f0 
f0102c0e:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102c15:	00 
f0102c16:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102c1d:	e8 1e d4 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102c22:	39 c6                	cmp    %eax,%esi
f0102c24:	73 24                	jae    f0102c4a <mem_init+0x15a7>
f0102c26:	c7 44 24 0c 8c 82 10 	movl   $0xf010828c,0xc(%esp)
f0102c2d:	f0 
f0102c2e:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102c35:	f0 
f0102c36:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f0102c3d:	00 
f0102c3e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102c45:	e8 f6 d3 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102c4a:	8b 3d 8c 2e 33 f0    	mov    0xf0332e8c,%edi
f0102c50:	89 da                	mov    %ebx,%edx
f0102c52:	89 f8                	mov    %edi,%eax
f0102c54:	e8 59 e1 ff ff       	call   f0100db2 <check_va2pa>
f0102c59:	85 c0                	test   %eax,%eax
f0102c5b:	74 24                	je     f0102c81 <mem_init+0x15de>
f0102c5d:	c7 44 24 0c c8 7c 10 	movl   $0xf0107cc8,0xc(%esp)
f0102c64:	f0 
f0102c65:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102c6c:	f0 
f0102c6d:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102c74:	00 
f0102c75:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102c7c:	e8 bf d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102c81:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102c87:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c8a:	89 c2                	mov    %eax,%edx
f0102c8c:	89 f8                	mov    %edi,%eax
f0102c8e:	e8 1f e1 ff ff       	call   f0100db2 <check_va2pa>
f0102c93:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102c98:	74 24                	je     f0102cbe <mem_init+0x161b>
f0102c9a:	c7 44 24 0c ec 7c 10 	movl   $0xf0107cec,0xc(%esp)
f0102ca1:	f0 
f0102ca2:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102ca9:	f0 
f0102caa:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102cb1:	00 
f0102cb2:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102cb9:	e8 82 d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102cbe:	89 f2                	mov    %esi,%edx
f0102cc0:	89 f8                	mov    %edi,%eax
f0102cc2:	e8 eb e0 ff ff       	call   f0100db2 <check_va2pa>
f0102cc7:	85 c0                	test   %eax,%eax
f0102cc9:	74 24                	je     f0102cef <mem_init+0x164c>
f0102ccb:	c7 44 24 0c 1c 7d 10 	movl   $0xf0107d1c,0xc(%esp)
f0102cd2:	f0 
f0102cd3:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102cda:	f0 
f0102cdb:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102ce2:	00 
f0102ce3:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102cea:	e8 51 d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102cef:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102cf5:	89 f8                	mov    %edi,%eax
f0102cf7:	e8 b6 e0 ff ff       	call   f0100db2 <check_va2pa>
f0102cfc:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102cff:	74 24                	je     f0102d25 <mem_init+0x1682>
f0102d01:	c7 44 24 0c 40 7d 10 	movl   $0xf0107d40,0xc(%esp)
f0102d08:	f0 
f0102d09:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102d10:	f0 
f0102d11:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102d18:	00 
f0102d19:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102d3e:	c7 44 24 0c 6c 7d 10 	movl   $0xf0107d6c,0xc(%esp)
f0102d45:	f0 
f0102d46:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102d4d:	f0 
f0102d4e:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102d55:	00 
f0102d56:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102d5d:	e8 de d2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102d62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102d69:	00 
f0102d6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d6e:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102d73:	89 04 24             	mov    %eax,(%esp)
f0102d76:	e8 0e e6 ff ff       	call   f0101389 <pgdir_walk>
f0102d7b:	f6 00 04             	testb  $0x4,(%eax)
f0102d7e:	74 24                	je     f0102da4 <mem_init+0x1701>
f0102d80:	c7 44 24 0c b0 7d 10 	movl   $0xf0107db0,0xc(%esp)
f0102d87:	f0 
f0102d88:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0102d8f:	f0 
f0102d90:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f0102d97:	00 
f0102d98:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102d9f:	e8 9c d2 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102da4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102dab:	00 
f0102dac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102db0:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102db5:	89 04 24             	mov    %eax,(%esp)
f0102db8:	e8 cc e5 ff ff       	call   f0101389 <pgdir_walk>
f0102dbd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102dc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102dca:	00 
f0102dcb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102dce:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102dd2:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102dd7:	89 04 24             	mov    %eax,(%esp)
f0102dda:	e8 aa e5 ff ff       	call   f0101389 <pgdir_walk>
f0102ddf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102de5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102dec:	00 
f0102ded:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102df1:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102df6:	89 04 24             	mov    %eax,(%esp)
f0102df9:	e8 8b e5 ff ff       	call   f0101389 <pgdir_walk>
f0102dfe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102e04:	c7 04 24 9e 82 10 f0 	movl   $0xf010829e,(%esp)
f0102e0b:	e8 e2 13 00 00       	call   f01041f2 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_U);
f0102e10:	a1 90 2e 33 f0       	mov    0xf0332e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e15:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e1a:	77 20                	ja     f0102e3c <mem_init+0x1799>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e20:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0102e27:	f0 
f0102e28:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f0102e2f:	00 
f0102e30:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102e37:	e8 04 d2 ff ff       	call   f0100040 <_panic>
f0102e3c:	8b 15 88 2e 33 f0    	mov    0xf0332e88,%edx
f0102e42:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102e49:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102e4f:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102e56:	00 
	return (physaddr_t)kva - KERNBASE;
f0102e57:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e5c:	89 04 24             	mov    %eax,(%esp)
f0102e5f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102e64:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102e69:	e8 ba e5 ff ff       	call   f0101428 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102e6e:	a1 48 22 33 f0       	mov    0xf0332248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e73:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e78:	77 20                	ja     f0102e9a <mem_init+0x17f7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e7e:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0102e85:	f0 
f0102e86:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0102e8d:	00 
f0102e8e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102e95:	e8 a6 d1 ff ff       	call   f0100040 <_panic>
f0102e9a:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102ea1:	00 
	return (physaddr_t)kva - KERNBASE;
f0102ea2:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ea7:	89 04 24             	mov    %eax,(%esp)
f0102eaa:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102eaf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102eb4:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102eb9:	e8 6a e5 ff ff       	call   f0101428 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ebe:	b8 00 00 12 f0       	mov    $0xf0120000,%eax
f0102ec3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ec8:	77 20                	ja     f0102eea <mem_init+0x1847>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ece:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0102ed5:	f0 
f0102ed6:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0102edd:	00 
f0102ede:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102ee5:	e8 56 d1 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102eea:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ef1:	00 
f0102ef2:	c7 04 24 00 00 12 00 	movl   $0x120000,(%esp)
f0102ef9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102efe:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102f03:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
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
f0102f26:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0102f2b:	e8 f8 e4 ff ff       	call   f0101428 <boot_map_region>
f0102f30:	c7 45 cc 00 40 33 f0 	movl   $0xf0334000,-0x34(%ebp)
f0102f37:	bb 00 40 33 f0       	mov    $0xf0334000,%ebx
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
f0102f4d:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0102f54:	f0 
f0102f55:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
f0102f5c:	00 
f0102f5d:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0102f81:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
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
f0102f9f:	8b 1d 8c 2e 33 f0    	mov    0xf0332e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102fa5:	8b 0d 88 2e 33 f0    	mov    0xf0332e88,%ecx
f0102fab:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102fae:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102fb5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102fbb:	be 00 00 00 00       	mov    $0x0,%esi
f0102fc0:	eb 70                	jmp    f0103032 <mem_init+0x198f>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102fc2:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102fc8:	89 d8                	mov    %ebx,%eax
f0102fca:	e8 e3 dd ff ff       	call   f0100db2 <check_va2pa>
f0102fcf:	8b 15 90 2e 33 f0    	mov    0xf0332e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fd5:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102fdb:	77 20                	ja     f0102ffd <mem_init+0x195a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fdd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102fe1:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0102fe8:	f0 
f0102fe9:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0102ff0:	00 
f0102ff1:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0102ff8:	e8 43 d0 ff ff       	call   f0100040 <_panic>
f0102ffd:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0103004:	39 d0                	cmp    %edx,%eax
f0103006:	74 24                	je     f010302c <mem_init+0x1989>
f0103008:	c7 44 24 0c e4 7d 10 	movl   $0xf0107de4,0xc(%esp)
f010300f:	f0 
f0103010:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103017:	f0 
f0103018:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f010301f:	00 
f0103020:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103027:	e8 14 d0 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010302c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103032:	39 f7                	cmp    %esi,%edi
f0103034:	77 8c                	ja     f0102fc2 <mem_init+0x191f>
f0103036:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010303b:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103041:	89 d8                	mov    %ebx,%eax
f0103043:	e8 6a dd ff ff       	call   f0100db2 <check_va2pa>
f0103048:	8b 15 48 22 33 f0    	mov    0xf0332248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010304e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103054:	77 20                	ja     f0103076 <mem_init+0x19d3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103056:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010305a:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0103061:	f0 
f0103062:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0103069:	00 
f010306a:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103071:	e8 ca cf ff ff       	call   f0100040 <_panic>
f0103076:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010307d:	39 d0                	cmp    %edx,%eax
f010307f:	74 24                	je     f01030a5 <mem_init+0x1a02>
f0103081:	c7 44 24 0c 18 7e 10 	movl   $0xf0107e18,0xc(%esp)
f0103088:	f0 
f0103089:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103090:	f0 
f0103091:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0103098:	00 
f0103099:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01030a0:	e8 9b cf ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01030a5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01030ab:	81 fe 00 b0 02 00    	cmp    $0x2b000,%esi
f01030b1:	75 88                	jne    f010303b <mem_init+0x1998>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01030b3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01030b6:	c1 e7 0c             	shl    $0xc,%edi
f01030b9:	be 00 00 00 00       	mov    $0x0,%esi
f01030be:	eb 3b                	jmp    f01030fb <mem_init+0x1a58>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01030c0:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01030c6:	89 d8                	mov    %ebx,%eax
f01030c8:	e8 e5 dc ff ff       	call   f0100db2 <check_va2pa>
f01030cd:	39 c6                	cmp    %eax,%esi
f01030cf:	74 24                	je     f01030f5 <mem_init+0x1a52>
f01030d1:	c7 44 24 0c 4c 7e 10 	movl   $0xf0107e4c,0xc(%esp)
f01030d8:	f0 
f01030d9:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01030e0:	f0 
f01030e1:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f01030e8:	00 
f01030e9:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01030f0:	e8 4b cf ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01030f5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01030fb:	39 fe                	cmp    %edi,%esi
f01030fd:	72 c1                	jb     f01030c0 <mem_init+0x1a1d>
f01030ff:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0103104:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
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
f010313e:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0103145:	f0 
f0103146:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f010314d:	00 
f010314e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103155:	e8 e6 ce ff ff       	call   f0100040 <_panic>
f010315a:	39 f0                	cmp    %esi,%eax
f010315c:	74 24                	je     f0103182 <mem_init+0x1adf>
f010315e:	c7 44 24 0c 74 7e 10 	movl   $0xf0107e74,0xc(%esp)
f0103165:	f0 
f0103166:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010316d:	f0 
f010316e:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0103175:	00 
f0103176:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f01031ae:	c7 44 24 0c bc 7e 10 	movl   $0xf0107ebc,0xc(%esp)
f01031b5:	f0 
f01031b6:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01031bd:	f0 
f01031be:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f01031c5:	00 
f01031c6:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f01031f9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
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
f010320c:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0103210:	0f 85 aa 00 00 00    	jne    f01032c0 <mem_init+0x1c1d>
f0103216:	c7 44 24 0c b7 82 10 	movl   $0xf01082b7,0xc(%esp)
f010321d:	f0 
f010321e:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103225:	f0 
f0103226:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f010322d:	00 
f010322e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103235:	e8 06 ce ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010323a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010323f:	76 55                	jbe    f0103296 <mem_init+0x1bf3>
				assert(pgdir[i] & PTE_P);
f0103241:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0103244:	f6 c2 01             	test   $0x1,%dl
f0103247:	75 24                	jne    f010326d <mem_init+0x1bca>
f0103249:	c7 44 24 0c b7 82 10 	movl   $0xf01082b7,0xc(%esp)
f0103250:	f0 
f0103251:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103258:	f0 
f0103259:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0103260:	00 
f0103261:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103268:	e8 d3 cd ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010326d:	f6 c2 02             	test   $0x2,%dl
f0103270:	75 4e                	jne    f01032c0 <mem_init+0x1c1d>
f0103272:	c7 44 24 0c c8 82 10 	movl   $0xf01082c8,0xc(%esp)
f0103279:	f0 
f010327a:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103281:	f0 
f0103282:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0103289:	00 
f010328a:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103291:	e8 aa cd ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103296:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010329a:	74 24                	je     f01032c0 <mem_init+0x1c1d>
f010329c:	c7 44 24 0c d9 82 10 	movl   $0xf01082d9,0xc(%esp)
f01032a3:	f0 
f01032a4:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01032ab:	f0 
f01032ac:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01032b3:	00 
f01032b4:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f01032cc:	c7 04 24 e0 7e 10 f0 	movl   $0xf0107ee0,(%esp)
f01032d3:	e8 1a 0f 00 00       	call   f01041f2 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01032d8:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032e2:	77 20                	ja     f0103304 <mem_init+0x1c61>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032e8:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f01032ef:	f0 
f01032f0:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
f01032f7:	00 
f01032f8:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f0103336:	c7 44 24 0c c3 80 10 	movl   $0xf01080c3,0xc(%esp)
f010333d:	f0 
f010333e:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103345:	f0 
f0103346:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f010334d:	00 
f010334e:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103355:	e8 e6 cc ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010335a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103361:	e8 23 df ff ff       	call   f0101289 <page_alloc>
f0103366:	89 c7                	mov    %eax,%edi
f0103368:	85 c0                	test   %eax,%eax
f010336a:	75 24                	jne    f0103390 <mem_init+0x1ced>
f010336c:	c7 44 24 0c d9 80 10 	movl   $0xf01080d9,0xc(%esp)
f0103373:	f0 
f0103374:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010337b:	f0 
f010337c:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0103383:	00 
f0103384:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f010338b:	e8 b0 cc ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103390:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103397:	e8 ed de ff ff       	call   f0101289 <page_alloc>
f010339c:	89 c3                	mov    %eax,%ebx
f010339e:	85 c0                	test   %eax,%eax
f01033a0:	75 24                	jne    f01033c6 <mem_init+0x1d23>
f01033a2:	c7 44 24 0c ef 80 10 	movl   $0xf01080ef,0xc(%esp)
f01033a9:	f0 
f01033aa:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01033b1:	f0 
f01033b2:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f01033b9:	00 
f01033ba:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f01033d0:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f01033d6:	c1 f8 03             	sar    $0x3,%eax
f01033d9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033dc:	89 c2                	mov    %eax,%edx
f01033de:	c1 ea 0c             	shr    $0xc,%edx
f01033e1:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f01033e7:	72 20                	jb     f0103409 <mem_init+0x1d66>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033ed:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01033f4:	f0 
f01033f5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01033fc:	00 
f01033fd:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f0103404:	e8 37 cc ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103409:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103410:	00 
f0103411:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103418:	00 
	return (void *)(pa + KERNBASE);
f0103419:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010341e:	89 04 24             	mov    %eax,(%esp)
f0103421:	e8 20 2d 00 00       	call   f0106146 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103426:	89 d8                	mov    %ebx,%eax
f0103428:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f010342e:	c1 f8 03             	sar    $0x3,%eax
f0103431:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103434:	89 c2                	mov    %eax,%edx
f0103436:	c1 ea 0c             	shr    $0xc,%edx
f0103439:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f010343f:	72 20                	jb     f0103461 <mem_init+0x1dbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103441:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103445:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f010344c:	f0 
f010344d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103454:	00 
f0103455:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f010345c:	e8 df cb ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103461:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103468:	00 
f0103469:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103470:	00 
	return (void *)(pa + KERNBASE);
f0103471:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103476:	89 04 24             	mov    %eax,(%esp)
f0103479:	e8 c8 2c 00 00       	call   f0106146 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010347e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103485:	00 
f0103486:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010348d:	00 
f010348e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103492:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0103497:	89 04 24             	mov    %eax,(%esp)
f010349a:	e8 23 e1 ff ff       	call   f01015c2 <page_insert>
	assert(pp1->pp_ref == 1);
f010349f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01034a4:	74 24                	je     f01034ca <mem_init+0x1e27>
f01034a6:	c7 44 24 0c c0 81 10 	movl   $0xf01081c0,0xc(%esp)
f01034ad:	f0 
f01034ae:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01034b5:	f0 
f01034b6:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f01034bd:	00 
f01034be:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01034c5:	e8 76 cb ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01034ca:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01034d1:	01 01 01 
f01034d4:	74 24                	je     f01034fa <mem_init+0x1e57>
f01034d6:	c7 44 24 0c 00 7f 10 	movl   $0xf0107f00,0xc(%esp)
f01034dd:	f0 
f01034de:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01034e5:	f0 
f01034e6:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f01034ed:	00 
f01034ee:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01034f5:	e8 46 cb ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01034fa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103501:	00 
f0103502:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103509:	00 
f010350a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010350e:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0103513:	89 04 24             	mov    %eax,(%esp)
f0103516:	e8 a7 e0 ff ff       	call   f01015c2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010351b:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103522:	02 02 02 
f0103525:	74 24                	je     f010354b <mem_init+0x1ea8>
f0103527:	c7 44 24 0c 24 7f 10 	movl   $0xf0107f24,0xc(%esp)
f010352e:	f0 
f010352f:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103536:	f0 
f0103537:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f010353e:	00 
f010353f:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103546:	e8 f5 ca ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010354b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103550:	74 24                	je     f0103576 <mem_init+0x1ed3>
f0103552:	c7 44 24 0c e2 81 10 	movl   $0xf01081e2,0xc(%esp)
f0103559:	f0 
f010355a:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103561:	f0 
f0103562:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0103569:	00 
f010356a:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103571:	e8 ca ca ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103576:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010357b:	74 24                	je     f01035a1 <mem_init+0x1efe>
f010357d:	c7 44 24 0c 4c 82 10 	movl   $0xf010824c,0xc(%esp)
f0103584:	f0 
f0103585:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010358c:	f0 
f010358d:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0103594:	00 
f0103595:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
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
f01035ad:	2b 05 90 2e 33 f0    	sub    0xf0332e90,%eax
f01035b3:	c1 f8 03             	sar    $0x3,%eax
f01035b6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035b9:	89 c2                	mov    %eax,%edx
f01035bb:	c1 ea 0c             	shr    $0xc,%edx
f01035be:	3b 15 88 2e 33 f0    	cmp    0xf0332e88,%edx
f01035c4:	72 20                	jb     f01035e6 <mem_init+0x1f43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ca:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01035d1:	f0 
f01035d2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01035d9:	00 
f01035da:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f01035e1:	e8 5a ca ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01035e6:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01035ed:	03 03 03 
f01035f0:	74 24                	je     f0103616 <mem_init+0x1f73>
f01035f2:	c7 44 24 0c 48 7f 10 	movl   $0xf0107f48,0xc(%esp)
f01035f9:	f0 
f01035fa:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103601:	f0 
f0103602:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0103609:	00 
f010360a:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103611:	e8 2a ca ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103616:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010361d:	00 
f010361e:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0103623:	89 04 24             	mov    %eax,(%esp)
f0103626:	e8 46 df ff ff       	call   f0101571 <page_remove>
	assert(pp2->pp_ref == 0);
f010362b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103630:	74 24                	je     f0103656 <mem_init+0x1fb3>
f0103632:	c7 44 24 0c 1a 82 10 	movl   $0xf010821a,0xc(%esp)
f0103639:	f0 
f010363a:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103641:	f0 
f0103642:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0103649:	00 
f010364a:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103651:	e8 ea c9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103656:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f010365b:	8b 08                	mov    (%eax),%ecx
f010365d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103663:	89 f2                	mov    %esi,%edx
f0103665:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f010366b:	c1 fa 03             	sar    $0x3,%edx
f010366e:	c1 e2 0c             	shl    $0xc,%edx
f0103671:	39 d1                	cmp    %edx,%ecx
f0103673:	74 24                	je     f0103699 <mem_init+0x1ff6>
f0103675:	c7 44 24 0c d0 78 10 	movl   $0xf01078d0,0xc(%esp)
f010367c:	f0 
f010367d:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0103684:	f0 
f0103685:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f010368c:	00 
f010368d:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0103694:	e8 a7 c9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103699:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010369f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01036a4:	74 24                	je     f01036ca <mem_init+0x2027>
f01036a6:	c7 44 24 0c d1 81 10 	movl   $0xf01081d1,0xc(%esp)
f01036ad:	f0 
f01036ae:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f01036b5:	f0 
f01036b6:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f01036bd:	00 
f01036be:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f01036c5:	e8 76 c9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01036ca:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01036d0:	89 34 24             	mov    %esi,(%esp)
f01036d3:	e8 35 dc ff ff       	call   f010130d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01036d8:	c7 04 24 74 7f 10 f0 	movl   $0xf0107f74,(%esp)
f01036df:	e8 0e 0b 00 00       	call   f01041f2 <cprintf>
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
f0103761:	a3 44 22 33 f0       	mov    %eax,0xf0332244
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
f01037b3:	a1 44 22 33 f0       	mov    0xf0332244,%eax
f01037b8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01037bc:	8b 43 48             	mov    0x48(%ebx),%eax
f01037bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037c3:	c7 04 24 a0 7f 10 f0 	movl   $0xf0107fa0,(%esp)
f01037ca:	e8 23 0a 00 00       	call   f01041f2 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01037cf:	89 1c 24             	mov    %ebx,(%esp)
f01037d2:	e8 0d 07 00 00       	call   f0103ee4 <env_destroy>
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
f0103812:	c7 44 24 08 e8 82 10 	movl   $0xf01082e8,0x8(%esp)
f0103819:	f0 
f010381a:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
f0103821:	00 
f0103822:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
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
f0103864:	8b 55 08             	mov    0x8(%ebp),%edx
f0103867:	8b 75 0c             	mov    0xc(%ebp),%esi
f010386a:	8a 4d 10             	mov    0x10(%ebp),%cl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010386d:	85 d2                	test   %edx,%edx
f010386f:	75 24                	jne    f0103895 <envid2env+0x3a>
		*env_store = curenv;
f0103871:	e8 fe 2e 00 00       	call   f0106774 <cpunum>
f0103876:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010387d:	29 c2                	sub    %eax,%edx
f010387f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103882:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0103889:	89 06                	mov    %eax,(%esi)
		return 0;
f010388b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103890:	e9 83 00 00 00       	jmp    f0103918 <envid2env+0xbd>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103895:	89 d0                	mov    %edx,%eax
f0103897:	25 ff 03 00 00       	and    $0x3ff,%eax
f010389c:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
f010389f:	8d 1c 98             	lea    (%eax,%ebx,4),%ebx
f01038a2:	8d 1c 58             	lea    (%eax,%ebx,2),%ebx
f01038a5:	c1 e3 02             	shl    $0x2,%ebx
f01038a8:	03 1d 48 22 33 f0    	add    0xf0332248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01038ae:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01038b2:	74 05                	je     f01038b9 <envid2env+0x5e>
f01038b4:	39 53 48             	cmp    %edx,0x48(%ebx)
f01038b7:	74 0d                	je     f01038c6 <envid2env+0x6b>
		*env_store = 0;
f01038b9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01038bf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01038c4:	eb 52                	jmp    f0103918 <envid2env+0xbd>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01038c6:	84 c9                	test   %cl,%cl
f01038c8:	74 47                	je     f0103911 <envid2env+0xb6>
f01038ca:	e8 a5 2e 00 00       	call   f0106774 <cpunum>
f01038cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01038d6:	29 c2                	sub    %eax,%edx
f01038d8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038db:	39 1c 85 28 30 33 f0 	cmp    %ebx,-0xfcccfd8(,%eax,4)
f01038e2:	74 2d                	je     f0103911 <envid2env+0xb6>
f01038e4:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01038e7:	e8 88 2e 00 00       	call   f0106774 <cpunum>
f01038ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01038f3:	29 c2                	sub    %eax,%edx
f01038f5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038f8:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01038ff:	3b 78 48             	cmp    0x48(%eax),%edi
f0103902:	74 0d                	je     f0103911 <envid2env+0xb6>
		*env_store = 0;
f0103904:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f010390a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010390f:	eb 07                	jmp    f0103918 <envid2env+0xbd>
	}

	*env_store = e;
f0103911:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0103913:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103918:	83 c4 0c             	add    $0xc,%esp
f010391b:	5b                   	pop    %ebx
f010391c:	5e                   	pop    %esi
f010391d:	5f                   	pop    %edi
f010391e:	5d                   	pop    %ebp
f010391f:	c3                   	ret    

f0103920 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103920:	55                   	push   %ebp
f0103921:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103923:	b8 20 a3 12 f0       	mov    $0xf012a320,%eax
f0103928:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010392b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103930:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103932:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103934:	b0 10                	mov    $0x10,%al
f0103936:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103938:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010393a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010393c:	ea 43 39 10 f0 08 00 	ljmp   $0x8,$0xf0103943
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103943:	b0 00                	mov    $0x0,%al
f0103945:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103948:	5d                   	pop    %ebp
f0103949:	c3                   	ret    

f010394a <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010394a:	55                   	push   %ebp
f010394b:	89 e5                	mov    %esp,%ebp
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f010394d:	a1 48 22 33 f0       	mov    0xf0332248,%eax
f0103952:	05 ac 00 00 00       	add    $0xac,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = 0; i < NENV; i++) {
f0103957:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_id = 0;
f010395c:	c7 40 9c 00 00 00 00 	movl   $0x0,-0x64(%eax)
		envs[i].env_link = &envs[i+1];
f0103963:	89 40 98             	mov    %eax,-0x68(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = 0; i < NENV; i++) {
f0103966:	42                   	inc    %edx
f0103967:	05 ac 00 00 00       	add    $0xac,%eax
f010396c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103972:	75 e8                	jne    f010395c <env_init+0x12>
		envs[i].env_id = 0;
		envs[i].env_link = &envs[i+1];
	}
	// point env_free_list to the first free env
	env_free_list = envs;
f0103974:	a1 48 22 33 f0       	mov    0xf0332248,%eax
f0103979:	a3 4c 22 33 f0       	mov    %eax,0xf033224c
	// Per-CPU part of the initialization
	env_init_percpu();
f010397e:	e8 9d ff ff ff       	call   f0103920 <env_init_percpu>
}
f0103983:	5d                   	pop    %ebp
f0103984:	c3                   	ret    

f0103985 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103985:	55                   	push   %ebp
f0103986:	89 e5                	mov    %esp,%ebp
f0103988:	56                   	push   %esi
f0103989:	53                   	push   %ebx
f010398a:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010398d:	8b 1d 4c 22 33 f0    	mov    0xf033224c,%ebx
f0103993:	85 db                	test   %ebx,%ebx
f0103995:	0f 84 bd 01 00 00    	je     f0103b58 <env_alloc+0x1d3>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010399b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01039a2:	e8 e2 d8 ff ff       	call   f0101289 <page_alloc>
f01039a7:	85 c0                	test   %eax,%eax
f01039a9:	0f 84 b0 01 00 00    	je     f0103b5f <env_alloc+0x1da>
f01039af:	89 c2                	mov    %eax,%edx
f01039b1:	2b 15 90 2e 33 f0    	sub    0xf0332e90,%edx
f01039b7:	c1 fa 03             	sar    $0x3,%edx
f01039ba:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039bd:	89 d1                	mov    %edx,%ecx
f01039bf:	c1 e9 0c             	shr    $0xc,%ecx
f01039c2:	3b 0d 88 2e 33 f0    	cmp    0xf0332e88,%ecx
f01039c8:	72 20                	jb     f01039ea <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01039ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01039ce:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01039d5:	f0 
f01039d6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01039dd:	00 
f01039de:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f01039e5:	e8 56 c6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01039ea:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01039f0:	89 53 60             	mov    %edx,0x60(%ebx)
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
	p->pp_ref++;
f01039f3:	66 ff 40 04          	incw   0x4(%eax)
	// use kern_pgdir as a template
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01039f7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01039fe:	00 
f01039ff:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
f0103a04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a08:	8b 43 60             	mov    0x60(%ebx),%eax
f0103a0b:	89 04 24             	mov    %eax,(%esp)
f0103a0e:	e8 e7 27 00 00       	call   f01061fa <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103a13:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a16:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a1b:	77 20                	ja     f0103a3d <env_alloc+0xb8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a21:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0103a28:	f0 
f0103a29:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f0103a30:	00 
f0103a31:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0103a38:	e8 03 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a3d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103a43:	83 ca 05             	or     $0x5,%edx
f0103a46:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103a4c:	8b 43 48             	mov    0x48(%ebx),%eax
f0103a4f:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103a54:	89 c6                	mov    %eax,%esi
f0103a56:	81 e6 00 fc ff ff    	and    $0xfffffc00,%esi
f0103a5c:	7f 05                	jg     f0103a63 <env_alloc+0xde>
		generation = 1 << ENVGENSHIFT;
f0103a5e:	be 00 10 00 00       	mov    $0x1000,%esi
	e->env_id = generation | (e - envs);
f0103a63:	89 d8                	mov    %ebx,%eax
f0103a65:	2b 05 48 22 33 f0    	sub    0xf0332248,%eax
f0103a6b:	c1 f8 02             	sar    $0x2,%eax
f0103a6e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103a71:	c1 e1 06             	shl    $0x6,%ecx
f0103a74:	89 ca                	mov    %ecx,%edx
f0103a76:	c1 e2 07             	shl    $0x7,%edx
f0103a79:	29 ca                	sub    %ecx,%edx
f0103a7b:	89 d1                	mov    %edx,%ecx
f0103a7d:	c1 e1 0e             	shl    $0xe,%ecx
f0103a80:	01 ca                	add    %ecx,%edx
f0103a82:	01 c2                	add    %eax,%edx
f0103a84:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0103a87:	09 c6                	or     %eax,%esi
f0103a89:	89 73 48             	mov    %esi,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a8f:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103a92:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103a99:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103aa0:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103aa7:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103aae:	00 
f0103aaf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103ab6:	00 
f0103ab7:	89 1c 24             	mov    %ebx,(%esp)
f0103aba:	e8 87 26 00 00       	call   f0106146 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103abf:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103ac5:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103acb:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103ad1:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103ad8:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103ade:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103ae5:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103aec:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103af0:	8b 43 44             	mov    0x44(%ebx),%eax
f0103af3:	a3 4c 22 33 f0       	mov    %eax,0xf033224c
	*newenv_store = e;
f0103af8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103afb:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103afd:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103b00:	e8 6f 2c 00 00       	call   f0106774 <cpunum>
f0103b05:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b0c:	29 c2                	sub    %eax,%edx
f0103b0e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b11:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0103b18:	00 
f0103b19:	74 1d                	je     f0103b38 <env_alloc+0x1b3>
f0103b1b:	e8 54 2c 00 00       	call   f0106774 <cpunum>
f0103b20:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b27:	29 c2                	sub    %eax,%edx
f0103b29:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b2c:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0103b33:	8b 40 48             	mov    0x48(%eax),%eax
f0103b36:	eb 05                	jmp    f0103b3d <env_alloc+0x1b8>
f0103b38:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b3d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b45:	c7 04 24 4c 83 10 f0 	movl   $0xf010834c,(%esp)
f0103b4c:	e8 a1 06 00 00       	call   f01041f2 <cprintf>
	return 0;
f0103b51:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b56:	eb 0c                	jmp    f0103b64 <env_alloc+0x1df>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103b58:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103b5d:	eb 05                	jmp    f0103b64 <env_alloc+0x1df>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103b5f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103b64:	83 c4 10             	add    $0x10,%esp
f0103b67:	5b                   	pop    %ebx
f0103b68:	5e                   	pop    %esi
f0103b69:	5d                   	pop    %ebp
f0103b6a:	c3                   	ret    

f0103b6b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103b6b:	55                   	push   %ebp
f0103b6c:	89 e5                	mov    %esp,%ebp
f0103b6e:	57                   	push   %edi
f0103b6f:	56                   	push   %esi
f0103b70:	53                   	push   %ebx
f0103b71:	83 ec 3c             	sub    $0x3c,%esp
f0103b74:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	// new env's parent ID is set to 0
	env_alloc(&penv, 0);
f0103b77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103b7e:	00 
f0103b7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103b82:	89 04 24             	mov    %eax,(%esp)
f0103b85:	e8 fb fd ff ff       	call   f0103985 <env_alloc>
	load_icode(penv, binary);
f0103b8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b8d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *ELFHDR = (struct Elf *)binary;

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
f0103b90:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103b96:	74 1c                	je     f0103bb4 <env_create+0x49>
		panic("load_icode: invalid ELF file!");
f0103b98:	c7 44 24 08 61 83 10 	movl   $0xf0108361,0x8(%esp)
f0103b9f:	f0 
f0103ba0:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0103ba7:	00 
f0103ba8:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0103baf:	e8 8c c4 ff ff       	call   f0100040 <_panic>

	// load each program segment
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103bb4:	89 fb                	mov    %edi,%ebx
f0103bb6:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103bb9:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103bbd:	c1 e6 05             	shl    $0x5,%esi
f0103bc0:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f0103bc2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103bc5:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bc8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bcd:	77 20                	ja     f0103bef <env_create+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bd3:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0103bda:	f0 
f0103bdb:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
f0103be2:	00 
f0103be3:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0103bea:	e8 51 c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103bef:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103bf4:	0f 22 d8             	mov    %eax,%cr3
f0103bf7:	eb 6c                	jmp    f0103c65 <env_create+0xfa>
	for (; ph < eph; ph++) {
		if (ph->p_filesz > ph->p_memsz) panic("load_icode: ph->p_filesz is larger than ph->p_memsz!");
f0103bf9:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103bfc:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103bff:	76 1c                	jbe    f0103c1d <env_create+0xb2>
f0103c01:	c7 44 24 08 0c 83 10 	movl   $0xf010830c,0x8(%esp)
f0103c08:	f0 
f0103c09:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0103c10:	00 
f0103c11:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0103c18:	e8 23 c4 ff ff       	call   f0100040 <_panic>
		if (ph->p_type == ELF_PROG_LOAD){
f0103c1d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103c20:	75 40                	jne    f0103c62 <env_create+0xf7>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103c22:	8b 53 08             	mov    0x8(%ebx),%edx
f0103c25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c28:	e8 b3 fb ff ff       	call   f01037e0 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103c2d:	8b 43 14             	mov    0x14(%ebx),%eax
f0103c30:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c34:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c3b:	00 
f0103c3c:	8b 43 08             	mov    0x8(%ebx),%eax
f0103c3f:	89 04 24             	mov    %eax,(%esp)
f0103c42:	e8 ff 24 00 00       	call   f0106146 <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0103c47:	8b 43 10             	mov    0x10(%ebx),%eax
f0103c4a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c4e:	89 f8                	mov    %edi,%eax
f0103c50:	03 43 04             	add    0x4(%ebx),%eax
f0103c53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c57:	8b 43 08             	mov    0x8(%ebx),%eax
f0103c5a:	89 04 24             	mov    %eax,(%esp)
f0103c5d:	e8 98 25 00 00       	call   f01061fa <memcpy>
	// load each program segment
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++) {
f0103c62:	83 c3 20             	add    $0x20,%ebx
f0103c65:	39 de                	cmp    %ebx,%esi
f0103c67:	77 90                	ja     f0103bf9 <env_create+0x8e>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memset((void *)ph->p_va, 0, ph->p_memsz);
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
		}
	}
	lcr3(PADDR(kern_pgdir));
f0103c69:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c6e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c73:	77 20                	ja     f0103c95 <env_create+0x12a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c75:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c79:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0103c80:	f0 
f0103c81:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
f0103c88:	00 
f0103c89:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0103c90:	e8 ab c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103c95:	05 00 00 00 10       	add    $0x10000000,%eax
f0103c9a:	0f 22 d8             	mov    %eax,%cr3

	// set eip to the program's entry point
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103c9d:	8b 47 18             	mov    0x18(%edi),%eax
f0103ca0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103ca3:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103ca6:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103cab:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103cb0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103cb3:	e8 28 fb ff ff       	call   f01037e0 <region_alloc>
	// LAB 3: Your code here.
	struct Env *penv;
	// new env's parent ID is set to 0
	env_alloc(&penv, 0);
	load_icode(penv, binary);
}
f0103cb8:	83 c4 3c             	add    $0x3c,%esp
f0103cbb:	5b                   	pop    %ebx
f0103cbc:	5e                   	pop    %esi
f0103cbd:	5f                   	pop    %edi
f0103cbe:	5d                   	pop    %ebp
f0103cbf:	c3                   	ret    

f0103cc0 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103cc0:	55                   	push   %ebp
f0103cc1:	89 e5                	mov    %esp,%ebp
f0103cc3:	57                   	push   %edi
f0103cc4:	56                   	push   %esi
f0103cc5:	53                   	push   %ebx
f0103cc6:	83 ec 2c             	sub    $0x2c,%esp
f0103cc9:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ccc:	e8 a3 2a 00 00       	call   f0106774 <cpunum>
f0103cd1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cd8:	29 c2                	sub    %eax,%edx
f0103cda:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cdd:	39 3c 85 28 30 33 f0 	cmp    %edi,-0xfcccfd8(,%eax,4)
f0103ce4:	75 34                	jne    f0103d1a <env_free+0x5a>
		lcr3(PADDR(kern_pgdir));
f0103ce6:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ceb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cf0:	77 20                	ja     f0103d12 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cf6:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0103cfd:	f0 
f0103cfe:	c7 44 24 04 a3 01 00 	movl   $0x1a3,0x4(%esp)
f0103d05:	00 
f0103d06:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0103d0d:	e8 2e c3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d12:	05 00 00 00 10       	add    $0x10000000,%eax
f0103d17:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103d1a:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103d1d:	e8 52 2a 00 00       	call   f0106774 <cpunum>
f0103d22:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d29:	29 c2                	sub    %eax,%edx
f0103d2b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d2e:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0103d35:	00 
f0103d36:	74 1d                	je     f0103d55 <env_free+0x95>
f0103d38:	e8 37 2a 00 00       	call   f0106774 <cpunum>
f0103d3d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d44:	29 c2                	sub    %eax,%edx
f0103d46:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d49:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0103d50:	8b 40 48             	mov    0x48(%eax),%eax
f0103d53:	eb 05                	jmp    f0103d5a <env_free+0x9a>
f0103d55:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d5a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d62:	c7 04 24 7f 83 10 f0 	movl   $0xf010837f,(%esp)
f0103d69:	e8 84 04 00 00       	call   f01041f2 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103d6e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103d75:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d78:	c1 e0 02             	shl    $0x2,%eax
f0103d7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103d7e:	8b 47 60             	mov    0x60(%edi),%eax
f0103d81:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103d84:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103d87:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103d8d:	0f 84 b6 00 00 00    	je     f0103e49 <env_free+0x189>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103d93:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103d99:	89 f0                	mov    %esi,%eax
f0103d9b:	c1 e8 0c             	shr    $0xc,%eax
f0103d9e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103da1:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0103da7:	72 20                	jb     f0103dc9 <env_free+0x109>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103da9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103dad:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f0103db4:	f0 
f0103db5:	c7 44 24 04 b2 01 00 	movl   $0x1b2,0x4(%esp)
f0103dbc:	00 
f0103dbd:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0103dc4:	e8 77 c2 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103dc9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103dcc:	c1 e2 16             	shl    $0x16,%edx
f0103dcf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103dd2:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103dd7:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103dde:	01 
f0103ddf:	74 17                	je     f0103df8 <env_free+0x138>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103de1:	89 d8                	mov    %ebx,%eax
f0103de3:	c1 e0 0c             	shl    $0xc,%eax
f0103de6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103de9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ded:	8b 47 60             	mov    0x60(%edi),%eax
f0103df0:	89 04 24             	mov    %eax,(%esp)
f0103df3:	e8 79 d7 ff ff       	call   f0101571 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103df8:	43                   	inc    %ebx
f0103df9:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103dff:	75 d6                	jne    f0103dd7 <env_free+0x117>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103e01:	8b 47 60             	mov    0x60(%edi),%eax
f0103e04:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103e07:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e0e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103e11:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0103e17:	72 1c                	jb     f0103e35 <env_free+0x175>
		panic("pa2page called with invalid pa");
f0103e19:	c7 44 24 08 74 77 10 	movl   $0xf0107774,0x8(%esp)
f0103e20:	f0 
f0103e21:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103e28:	00 
f0103e29:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f0103e30:	e8 0b c2 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103e35:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103e38:	c1 e0 03             	shl    $0x3,%eax
f0103e3b:	03 05 90 2e 33 f0    	add    0xf0332e90,%eax
		page_decref(pa2page(pa));
f0103e41:	89 04 24             	mov    %eax,(%esp)
f0103e44:	e8 20 d5 ff ff       	call   f0101369 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103e49:	ff 45 e0             	incl   -0x20(%ebp)
f0103e4c:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103e53:	0f 85 1c ff ff ff    	jne    f0103d75 <env_free+0xb5>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103e59:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e5c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e61:	77 20                	ja     f0103e83 <env_free+0x1c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e63:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e67:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0103e6e:	f0 
f0103e6f:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
f0103e76:	00 
f0103e77:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0103e7e:	e8 bd c1 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103e83:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103e8a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e8f:	c1 e8 0c             	shr    $0xc,%eax
f0103e92:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0103e98:	72 1c                	jb     f0103eb6 <env_free+0x1f6>
		panic("pa2page called with invalid pa");
f0103e9a:	c7 44 24 08 74 77 10 	movl   $0xf0107774,0x8(%esp)
f0103ea1:	f0 
f0103ea2:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103ea9:	00 
f0103eaa:	c7 04 24 e1 7f 10 f0 	movl   $0xf0107fe1,(%esp)
f0103eb1:	e8 8a c1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103eb6:	c1 e0 03             	shl    $0x3,%eax
f0103eb9:	03 05 90 2e 33 f0    	add    0xf0332e90,%eax
	page_decref(pa2page(pa));
f0103ebf:	89 04 24             	mov    %eax,(%esp)
f0103ec2:	e8 a2 d4 ff ff       	call   f0101369 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103ec7:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103ece:	a1 4c 22 33 f0       	mov    0xf033224c,%eax
f0103ed3:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103ed6:	89 3d 4c 22 33 f0    	mov    %edi,0xf033224c
}
f0103edc:	83 c4 2c             	add    $0x2c,%esp
f0103edf:	5b                   	pop    %ebx
f0103ee0:	5e                   	pop    %esi
f0103ee1:	5f                   	pop    %edi
f0103ee2:	5d                   	pop    %ebp
f0103ee3:	c3                   	ret    

f0103ee4 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103ee4:	55                   	push   %ebp
f0103ee5:	89 e5                	mov    %esp,%ebp
f0103ee7:	53                   	push   %ebx
f0103ee8:	83 ec 14             	sub    $0x14,%esp
f0103eeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103eee:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103ef2:	75 23                	jne    f0103f17 <env_destroy+0x33>
f0103ef4:	e8 7b 28 00 00       	call   f0106774 <cpunum>
f0103ef9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f00:	29 c2                	sub    %eax,%edx
f0103f02:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f05:	39 1c 85 28 30 33 f0 	cmp    %ebx,-0xfcccfd8(,%eax,4)
f0103f0c:	74 09                	je     f0103f17 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103f0e:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103f15:	eb 39                	jmp    f0103f50 <env_destroy+0x6c>
	}

	env_free(e);
f0103f17:	89 1c 24             	mov    %ebx,(%esp)
f0103f1a:	e8 a1 fd ff ff       	call   f0103cc0 <env_free>

	if (curenv == e) {
f0103f1f:	e8 50 28 00 00       	call   f0106774 <cpunum>
f0103f24:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f2b:	29 c2                	sub    %eax,%edx
f0103f2d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f30:	39 1c 85 28 30 33 f0 	cmp    %ebx,-0xfcccfd8(,%eax,4)
f0103f37:	75 17                	jne    f0103f50 <env_destroy+0x6c>
		curenv = NULL;
f0103f39:	e8 36 28 00 00       	call   f0106774 <cpunum>
f0103f3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f41:	c7 80 28 30 33 f0 00 	movl   $0x0,-0xfcccfd8(%eax)
f0103f48:	00 00 00 
		sched_yield();
f0103f4b:	e8 e1 0c 00 00       	call   f0104c31 <sched_yield>
	}
}
f0103f50:	83 c4 14             	add    $0x14,%esp
f0103f53:	5b                   	pop    %ebx
f0103f54:	5d                   	pop    %ebp
f0103f55:	c3                   	ret    

f0103f56 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103f56:	55                   	push   %ebp
f0103f57:	89 e5                	mov    %esp,%ebp
f0103f59:	53                   	push   %ebx
f0103f5a:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103f5d:	e8 12 28 00 00       	call   f0106774 <cpunum>
f0103f62:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f69:	29 c2                	sub    %eax,%edx
f0103f6b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f6e:	8b 1c 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%ebx
f0103f75:	e8 fa 27 00 00       	call   f0106774 <cpunum>
f0103f7a:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103f7d:	8b 65 08             	mov    0x8(%ebp),%esp
f0103f80:	61                   	popa   
f0103f81:	07                   	pop    %es
f0103f82:	1f                   	pop    %ds
f0103f83:	83 c4 08             	add    $0x8,%esp
f0103f86:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103f87:	c7 44 24 08 95 83 10 	movl   $0xf0108395,0x8(%esp)
f0103f8e:	f0 
f0103f8f:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
f0103f96:	00 
f0103f97:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0103f9e:	e8 9d c0 ff ff       	call   f0100040 <_panic>

f0103fa3 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103fa3:	55                   	push   %ebp
f0103fa4:	89 e5                	mov    %esp,%ebp
f0103fa6:	53                   	push   %ebx
f0103fa7:	83 ec 14             	sub    $0x14,%esp
f0103faa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) {
f0103fad:	e8 c2 27 00 00       	call   f0106774 <cpunum>
f0103fb2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fb9:	29 c2                	sub    %eax,%edx
f0103fbb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fbe:	39 1c 85 28 30 33 f0 	cmp    %ebx,-0xfcccfd8(,%eax,4)
f0103fc5:	0f 84 c8 00 00 00    	je     f0104093 <env_run+0xf0>
		if (curenv && curenv->env_status == ENV_RUNNING)
f0103fcb:	e8 a4 27 00 00       	call   f0106774 <cpunum>
f0103fd0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fd7:	29 c2                	sub    %eax,%edx
f0103fd9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fdc:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0103fe3:	00 
f0103fe4:	74 29                	je     f010400f <env_run+0x6c>
f0103fe6:	e8 89 27 00 00       	call   f0106774 <cpunum>
f0103feb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fee:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0103ff4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103ff8:	75 15                	jne    f010400f <env_run+0x6c>
			curenv->env_status = ENV_RUNNABLE;
f0103ffa:	e8 75 27 00 00       	call   f0106774 <cpunum>
f0103fff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104002:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0104008:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f010400f:	e8 60 27 00 00       	call   f0106774 <cpunum>
f0104014:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010401b:	29 c2                	sub    %eax,%edx
f010401d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104020:	89 1c 85 28 30 33 f0 	mov    %ebx,-0xfcccfd8(,%eax,4)
		curenv->env_status = ENV_RUNNING;
f0104027:	e8 48 27 00 00       	call   f0106774 <cpunum>
f010402c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104033:	29 c2                	sub    %eax,%edx
f0104035:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104038:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010403f:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0104046:	e8 29 27 00 00       	call   f0106774 <cpunum>
f010404b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104052:	29 c2                	sub    %eax,%edx
f0104054:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104057:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010405e:	ff 40 58             	incl   0x58(%eax)
		lcr3(PADDR(e->env_pgdir));
f0104061:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104064:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104069:	77 20                	ja     f010408b <env_run+0xe8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010406b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010406f:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0104076:	f0 
f0104077:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
f010407e:	00 
f010407f:	c7 04 24 41 83 10 f0 	movl   $0xf0108341,(%esp)
f0104086:	e8 b5 bf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010408b:	05 00 00 00 10       	add    $0x10000000,%eax
f0104090:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104093:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f010409a:	e8 37 2a 00 00       	call   f0106ad6 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010409f:	f3 90                	pause  
	}
	unlock_kernel();
	env_pop_tf(&e->env_tf);
f01040a1:	89 1c 24             	mov    %ebx,(%esp)
f01040a4:	e8 ad fe ff ff       	call   f0103f56 <env_pop_tf>
f01040a9:	00 00                	add    %al,(%eax)
	...

f01040ac <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01040ac:	55                   	push   %ebp
f01040ad:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01040af:	ba 70 00 00 00       	mov    $0x70,%edx
f01040b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01040b7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01040b8:	b2 71                	mov    $0x71,%dl
f01040ba:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01040bb:	0f b6 c0             	movzbl %al,%eax
}
f01040be:	5d                   	pop    %ebp
f01040bf:	c3                   	ret    

f01040c0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01040c0:	55                   	push   %ebp
f01040c1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01040c3:	ba 70 00 00 00       	mov    $0x70,%edx
f01040c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01040cb:	ee                   	out    %al,(%dx)
f01040cc:	b2 71                	mov    $0x71,%dl
f01040ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01040d1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01040d2:	5d                   	pop    %ebp
f01040d3:	c3                   	ret    

f01040d4 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01040d4:	55                   	push   %ebp
f01040d5:	89 e5                	mov    %esp,%ebp
f01040d7:	56                   	push   %esi
f01040d8:	53                   	push   %ebx
f01040d9:	83 ec 10             	sub    $0x10,%esp
f01040dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01040df:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01040e1:	66 a3 a8 a3 12 f0    	mov    %ax,0xf012a3a8
	if (!didinit)
f01040e7:	80 3d 50 22 33 f0 00 	cmpb   $0x0,0xf0332250
f01040ee:	74 51                	je     f0104141 <irq_setmask_8259A+0x6d>
f01040f0:	ba 21 00 00 00       	mov    $0x21,%edx
f01040f5:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01040f6:	89 f0                	mov    %esi,%eax
f01040f8:	66 c1 e8 08          	shr    $0x8,%ax
f01040fc:	b2 a1                	mov    $0xa1,%dl
f01040fe:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01040ff:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0104106:	e8 e7 00 00 00       	call   f01041f2 <cprintf>
	for (i = 0; i < 16; i++)
f010410b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0104110:	0f b7 f6             	movzwl %si,%esi
f0104113:	f7 d6                	not    %esi
f0104115:	89 f0                	mov    %esi,%eax
f0104117:	88 d9                	mov    %bl,%cl
f0104119:	d3 f8                	sar    %cl,%eax
f010411b:	a8 01                	test   $0x1,%al
f010411d:	74 10                	je     f010412f <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f010411f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104123:	c7 04 24 cb 88 10 f0 	movl   $0xf01088cb,(%esp)
f010412a:	e8 c3 00 00 00       	call   f01041f2 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010412f:	43                   	inc    %ebx
f0104130:	83 fb 10             	cmp    $0x10,%ebx
f0104133:	75 e0                	jne    f0104115 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104135:	c7 04 24 b5 82 10 f0 	movl   $0xf01082b5,(%esp)
f010413c:	e8 b1 00 00 00       	call   f01041f2 <cprintf>
}
f0104141:	83 c4 10             	add    $0x10,%esp
f0104144:	5b                   	pop    %ebx
f0104145:	5e                   	pop    %esi
f0104146:	5d                   	pop    %ebp
f0104147:	c3                   	ret    

f0104148 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104148:	55                   	push   %ebp
f0104149:	89 e5                	mov    %esp,%ebp
f010414b:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010414e:	c6 05 50 22 33 f0 01 	movb   $0x1,0xf0332250
f0104155:	ba 21 00 00 00       	mov    $0x21,%edx
f010415a:	b0 ff                	mov    $0xff,%al
f010415c:	ee                   	out    %al,(%dx)
f010415d:	b2 a1                	mov    $0xa1,%dl
f010415f:	ee                   	out    %al,(%dx)
f0104160:	b2 20                	mov    $0x20,%dl
f0104162:	b0 11                	mov    $0x11,%al
f0104164:	ee                   	out    %al,(%dx)
f0104165:	b2 21                	mov    $0x21,%dl
f0104167:	b0 20                	mov    $0x20,%al
f0104169:	ee                   	out    %al,(%dx)
f010416a:	b0 04                	mov    $0x4,%al
f010416c:	ee                   	out    %al,(%dx)
f010416d:	b0 03                	mov    $0x3,%al
f010416f:	ee                   	out    %al,(%dx)
f0104170:	b2 a0                	mov    $0xa0,%dl
f0104172:	b0 11                	mov    $0x11,%al
f0104174:	ee                   	out    %al,(%dx)
f0104175:	b2 a1                	mov    $0xa1,%dl
f0104177:	b0 28                	mov    $0x28,%al
f0104179:	ee                   	out    %al,(%dx)
f010417a:	b0 02                	mov    $0x2,%al
f010417c:	ee                   	out    %al,(%dx)
f010417d:	b0 01                	mov    $0x1,%al
f010417f:	ee                   	out    %al,(%dx)
f0104180:	b2 20                	mov    $0x20,%dl
f0104182:	b0 68                	mov    $0x68,%al
f0104184:	ee                   	out    %al,(%dx)
f0104185:	b0 0a                	mov    $0xa,%al
f0104187:	ee                   	out    %al,(%dx)
f0104188:	b2 a0                	mov    $0xa0,%dl
f010418a:	b0 68                	mov    $0x68,%al
f010418c:	ee                   	out    %al,(%dx)
f010418d:	b0 0a                	mov    $0xa,%al
f010418f:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104190:	66 a1 a8 a3 12 f0    	mov    0xf012a3a8,%ax
f0104196:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f010419a:	74 0b                	je     f01041a7 <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f010419c:	0f b7 c0             	movzwl %ax,%eax
f010419f:	89 04 24             	mov    %eax,(%esp)
f01041a2:	e8 2d ff ff ff       	call   f01040d4 <irq_setmask_8259A>
}
f01041a7:	c9                   	leave  
f01041a8:	c3                   	ret    
f01041a9:	00 00                	add    %al,(%eax)
	...

f01041ac <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01041ac:	55                   	push   %ebp
f01041ad:	89 e5                	mov    %esp,%ebp
f01041af:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01041b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01041b5:	89 04 24             	mov    %eax,(%esp)
f01041b8:	e8 fe c5 ff ff       	call   f01007bb <cputchar>
	*cnt++;
}
f01041bd:	c9                   	leave  
f01041be:	c3                   	ret    

f01041bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01041bf:	55                   	push   %ebp
f01041c0:	89 e5                	mov    %esp,%ebp
f01041c2:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01041c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01041cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01041d6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01041da:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01041dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041e1:	c7 04 24 ac 41 10 f0 	movl   $0xf01041ac,(%esp)
f01041e8:	e8 47 19 00 00       	call   f0105b34 <vprintfmt>
	return cnt;
}
f01041ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01041f0:	c9                   	leave  
f01041f1:	c3                   	ret    

f01041f2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01041f2:	55                   	push   %ebp
f01041f3:	89 e5                	mov    %esp,%ebp
f01041f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01041f8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01041fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0104202:	89 04 24             	mov    %eax,(%esp)
f0104205:	e8 b5 ff ff ff       	call   f01041bf <vcprintf>
	va_end(ap);

	return cnt;
}
f010420a:	c9                   	leave  
f010420b:	c3                   	ret    

f010420c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010420c:	55                   	push   %ebp
f010420d:	89 e5                	mov    %esp,%ebp
f010420f:	57                   	push   %edi
f0104210:	56                   	push   %esi
f0104211:	53                   	push   %ebx
f0104212:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f0104215:	e8 5a 25 00 00       	call   f0106774 <cpunum>
f010421a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104221:	29 c2                	sub    %eax,%edx
f0104223:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104226:	0f b6 1c 85 20 30 33 	movzbl -0xfcccfe0(,%eax,4),%ebx
f010422d:	f0 

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f010422e:	e8 41 25 00 00       	call   f0106774 <cpunum>
f0104233:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010423a:	29 c2                	sub    %eax,%edx
f010423c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010423f:	89 da                	mov    %ebx,%edx
f0104241:	f7 da                	neg    %edx
f0104243:	c1 e2 10             	shl    $0x10,%edx
f0104246:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010424c:	89 14 85 30 30 33 f0 	mov    %edx,-0xfcccfd0(,%eax,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104253:	e8 1c 25 00 00       	call   f0106774 <cpunum>
f0104258:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010425f:	29 c2                	sub    %eax,%edx
f0104261:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104264:	66 c7 04 85 34 30 33 	movw   $0x10,-0xfcccfcc(,%eax,4)
f010426b:	f0 10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f010426e:	83 c3 05             	add    $0x5,%ebx
f0104271:	e8 fe 24 00 00       	call   f0106774 <cpunum>
f0104276:	89 c6                	mov    %eax,%esi
f0104278:	e8 f7 24 00 00       	call   f0106774 <cpunum>
f010427d:	89 c7                	mov    %eax,%edi
f010427f:	e8 f0 24 00 00       	call   f0106774 <cpunum>
f0104284:	66 c7 04 dd 40 a3 12 	movw   $0x67,-0xfed5cc0(,%ebx,8)
f010428b:	f0 67 00 
f010428e:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0104295:	29 f2                	sub    %esi,%edx
f0104297:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010429a:	8d 14 95 2c 30 33 f0 	lea    -0xfcccfd4(,%edx,4),%edx
f01042a1:	66 89 14 dd 42 a3 12 	mov    %dx,-0xfed5cbe(,%ebx,8)
f01042a8:	f0 
f01042a9:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01042b0:	29 fa                	sub    %edi,%edx
f01042b2:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01042b5:	8d 14 95 2c 30 33 f0 	lea    -0xfcccfd4(,%edx,4),%edx
f01042bc:	c1 ea 10             	shr    $0x10,%edx
f01042bf:	88 14 dd 44 a3 12 f0 	mov    %dl,-0xfed5cbc(,%ebx,8)
f01042c6:	c6 04 dd 46 a3 12 f0 	movb   $0x40,-0xfed5cba(,%ebx,8)
f01042cd:	40 
f01042ce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042d5:	29 c2                	sub    %eax,%edx
f01042d7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01042da:	8d 04 85 2c 30 33 f0 	lea    -0xfcccfd4(,%eax,4),%eax
f01042e1:	c1 e8 18             	shr    $0x18,%eax
f01042e4:	88 04 dd 47 a3 12 f0 	mov    %al,-0xfed5cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f01042eb:	c6 04 dd 45 a3 12 f0 	movb   $0x89,-0xfed5cbb(,%ebx,8)
f01042f2:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cid);
f01042f3:	c1 e3 03             	shl    $0x3,%ebx
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01042f6:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01042f9:	b8 ac a3 12 f0       	mov    $0xf012a3ac,%eax
f01042fe:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0104301:	83 c4 0c             	add    $0xc,%esp
f0104304:	5b                   	pop    %ebx
f0104305:	5e                   	pop    %esi
f0104306:	5f                   	pop    %edi
f0104307:	5d                   	pop    %ebp
f0104308:	c3                   	ret    

f0104309 <trap_init>:
}


void
trap_init(void)
{
f0104309:	55                   	push   %ebp
f010430a:	89 e5                	mov    %esp,%ebp
f010430c:	83 ec 08             	sub    $0x8,%esp

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall_handler, 3);
*/
	extern void (*t_handler[])();
	int i;
	for (i = 0; i < 20; i++) {
f010430f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (i == T_BRKPT) {
f0104314:	83 f8 03             	cmp    $0x3,%eax
f0104317:	75 33                	jne    f010434c <trap_init+0x43>
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 3);
f0104319:	8b 15 c0 a3 12 f0    	mov    0xf012a3c0,%edx
f010431f:	66 89 15 78 22 33 f0 	mov    %dx,0xf0332278
f0104326:	66 c7 05 7a 22 33 f0 	movw   $0x8,0xf033227a
f010432d:	08 00 
f010432f:	c6 05 7c 22 33 f0 00 	movb   $0x0,0xf033227c
f0104336:	c6 05 7d 22 33 f0 ee 	movb   $0xee,0xf033227d
f010433d:	c1 ea 10             	shr    $0x10,%edx
f0104340:	66 89 15 7e 22 33 f0 	mov    %dx,0xf033227e
f0104347:	e9 c1 00 00 00       	jmp    f010440d <trap_init+0x104>
		}
		else if (i !=9 && i != 15) {
f010434c:	83 f8 09             	cmp    $0x9,%eax
f010434f:	0f 84 b8 00 00 00    	je     f010440d <trap_init+0x104>
f0104355:	83 f8 0f             	cmp    $0xf,%eax
f0104358:	0f 84 af 00 00 00    	je     f010440d <trap_init+0x104>
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 0);
f010435e:	8b 14 85 b4 a3 12 f0 	mov    -0xfed5c4c(,%eax,4),%edx
f0104365:	66 89 14 c5 60 22 33 	mov    %dx,-0xfccdda0(,%eax,8)
f010436c:	f0 
f010436d:	66 c7 04 c5 62 22 33 	movw   $0x8,-0xfccdd9e(,%eax,8)
f0104374:	f0 08 00 
f0104377:	c6 04 c5 64 22 33 f0 	movb   $0x0,-0xfccdd9c(,%eax,8)
f010437e:	00 
f010437f:	c6 04 c5 65 22 33 f0 	movb   $0x8e,-0xfccdd9b(,%eax,8)
f0104386:	8e 
f0104387:	c1 ea 10             	shr    $0x10,%edx
f010438a:	66 89 14 c5 66 22 33 	mov    %dx,-0xfccdd9a(,%eax,8)
f0104391:	f0 

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall_handler, 3);
*/
	extern void (*t_handler[])();
	int i;
	for (i = 0; i < 20; i++) {
f0104392:	40                   	inc    %eax
f0104393:	83 f8 14             	cmp    $0x14,%eax
f0104396:	0f 85 78 ff ff ff    	jne    f0104314 <trap_init+0xb>
		}
		else if (i !=9 && i != 15) {
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 0);
		}
	}
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_handler[20], 3);
f010439c:	a1 04 a4 12 f0       	mov    0xf012a404,%eax
f01043a1:	66 a3 e0 23 33 f0    	mov    %ax,0xf03323e0
f01043a7:	66 c7 05 e2 23 33 f0 	movw   $0x8,0xf03323e2
f01043ae:	08 00 
f01043b0:	c6 05 e4 23 33 f0 00 	movb   $0x0,0xf03323e4
f01043b7:	c6 05 e5 23 33 f0 ee 	movb   $0xee,0xf03323e5
f01043be:	c1 e8 10             	shr    $0x10,%eax
f01043c1:	66 a3 e6 23 33 f0    	mov    %ax,0xf03323e6
f01043c7:	b8 20 00 00 00       	mov    $0x20,%eax
	for (i = 0; i < 16; i++) {
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, t_handler[21 + i], 0);
f01043cc:	8b 14 85 88 a3 12 f0 	mov    -0xfed5c78(,%eax,4),%edx
f01043d3:	66 89 14 c5 60 22 33 	mov    %dx,-0xfccdda0(,%eax,8)
f01043da:	f0 
f01043db:	66 c7 04 c5 62 22 33 	movw   $0x8,-0xfccdd9e(,%eax,8)
f01043e2:	f0 08 00 
f01043e5:	c6 04 c5 64 22 33 f0 	movb   $0x0,-0xfccdd9c(,%eax,8)
f01043ec:	00 
f01043ed:	c6 04 c5 65 22 33 f0 	movb   $0x8e,-0xfccdd9b(,%eax,8)
f01043f4:	8e 
f01043f5:	c1 ea 10             	shr    $0x10,%edx
f01043f8:	66 89 14 c5 66 22 33 	mov    %dx,-0xfccdd9a(,%eax,8)
f01043ff:	f0 
f0104400:	40                   	inc    %eax
		else if (i !=9 && i != 15) {
			SETGATE(idt[i], 0, GD_KT, t_handler[i], 0);
		}
	}
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_handler[20], 3);
	for (i = 0; i < 16; i++) {
f0104401:	83 f8 30             	cmp    $0x30,%eax
f0104404:	75 c6                	jne    f01043cc <trap_init+0xc3>
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, t_handler[21 + i], 0);
	}
	// Per-CPU setup
	trap_init_percpu();
f0104406:	e8 01 fe ff ff       	call   f010420c <trap_init_percpu>
}
f010440b:	c9                   	leave  
f010440c:	c3                   	ret    

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall_handler, 3);
*/
	extern void (*t_handler[])();
	int i;
	for (i = 0; i < 20; i++) {
f010440d:	40                   	inc    %eax
f010440e:	e9 01 ff ff ff       	jmp    f0104314 <trap_init+0xb>

f0104413 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104413:	55                   	push   %ebp
f0104414:	89 e5                	mov    %esp,%ebp
f0104416:	53                   	push   %ebx
f0104417:	83 ec 14             	sub    $0x14,%esp
f010441a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010441d:	8b 03                	mov    (%ebx),%eax
f010441f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104423:	c7 04 24 b5 83 10 f0 	movl   $0xf01083b5,(%esp)
f010442a:	e8 c3 fd ff ff       	call   f01041f2 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010442f:	8b 43 04             	mov    0x4(%ebx),%eax
f0104432:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104436:	c7 04 24 c4 83 10 f0 	movl   $0xf01083c4,(%esp)
f010443d:	e8 b0 fd ff ff       	call   f01041f2 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104442:	8b 43 08             	mov    0x8(%ebx),%eax
f0104445:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104449:	c7 04 24 d3 83 10 f0 	movl   $0xf01083d3,(%esp)
f0104450:	e8 9d fd ff ff       	call   f01041f2 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104455:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104458:	89 44 24 04          	mov    %eax,0x4(%esp)
f010445c:	c7 04 24 e2 83 10 f0 	movl   $0xf01083e2,(%esp)
f0104463:	e8 8a fd ff ff       	call   f01041f2 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104468:	8b 43 10             	mov    0x10(%ebx),%eax
f010446b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010446f:	c7 04 24 f1 83 10 f0 	movl   $0xf01083f1,(%esp)
f0104476:	e8 77 fd ff ff       	call   f01041f2 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010447b:	8b 43 14             	mov    0x14(%ebx),%eax
f010447e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104482:	c7 04 24 00 84 10 f0 	movl   $0xf0108400,(%esp)
f0104489:	e8 64 fd ff ff       	call   f01041f2 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010448e:	8b 43 18             	mov    0x18(%ebx),%eax
f0104491:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104495:	c7 04 24 0f 84 10 f0 	movl   $0xf010840f,(%esp)
f010449c:	e8 51 fd ff ff       	call   f01041f2 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01044a1:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01044a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044a8:	c7 04 24 1e 84 10 f0 	movl   $0xf010841e,(%esp)
f01044af:	e8 3e fd ff ff       	call   f01041f2 <cprintf>
}
f01044b4:	83 c4 14             	add    $0x14,%esp
f01044b7:	5b                   	pop    %ebx
f01044b8:	5d                   	pop    %ebp
f01044b9:	c3                   	ret    

f01044ba <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01044ba:	55                   	push   %ebp
f01044bb:	89 e5                	mov    %esp,%ebp
f01044bd:	53                   	push   %ebx
f01044be:	83 ec 14             	sub    $0x14,%esp
f01044c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01044c4:	e8 ab 22 00 00       	call   f0106774 <cpunum>
f01044c9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044d1:	c7 04 24 82 84 10 f0 	movl   $0xf0108482,(%esp)
f01044d8:	e8 15 fd ff ff       	call   f01041f2 <cprintf>
	print_regs(&tf->tf_regs);
f01044dd:	89 1c 24             	mov    %ebx,(%esp)
f01044e0:	e8 2e ff ff ff       	call   f0104413 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01044e5:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01044e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ed:	c7 04 24 a0 84 10 f0 	movl   $0xf01084a0,(%esp)
f01044f4:	e8 f9 fc ff ff       	call   f01041f2 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044f9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01044fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104501:	c7 04 24 b3 84 10 f0 	movl   $0xf01084b3,(%esp)
f0104508:	e8 e5 fc ff ff       	call   f01041f2 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010450d:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104510:	83 f8 13             	cmp    $0x13,%eax
f0104513:	77 09                	ja     f010451e <print_trapframe+0x64>
		return excnames[trapno];
f0104515:	8b 14 85 40 87 10 f0 	mov    -0xfef78c0(,%eax,4),%edx
f010451c:	eb 20                	jmp    f010453e <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f010451e:	83 f8 30             	cmp    $0x30,%eax
f0104521:	74 0f                	je     f0104532 <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104523:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104526:	83 fa 0f             	cmp    $0xf,%edx
f0104529:	77 0e                	ja     f0104539 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f010452b:	ba 39 84 10 f0       	mov    $0xf0108439,%edx
f0104530:	eb 0c                	jmp    f010453e <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104532:	ba 2d 84 10 f0       	mov    $0xf010842d,%edx
f0104537:	eb 05                	jmp    f010453e <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104539:	ba 4c 84 10 f0       	mov    $0xf010844c,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010453e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104542:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104546:	c7 04 24 c6 84 10 f0 	movl   $0xf01084c6,(%esp)
f010454d:	e8 a0 fc ff ff       	call   f01041f2 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104552:	3b 1d 60 2a 33 f0    	cmp    0xf0332a60,%ebx
f0104558:	75 19                	jne    f0104573 <print_trapframe+0xb9>
f010455a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010455e:	75 13                	jne    f0104573 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104560:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104563:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104567:	c7 04 24 d8 84 10 f0 	movl   $0xf01084d8,(%esp)
f010456e:	e8 7f fc ff ff       	call   f01041f2 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104573:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104576:	89 44 24 04          	mov    %eax,0x4(%esp)
f010457a:	c7 04 24 e7 84 10 f0 	movl   $0xf01084e7,(%esp)
f0104581:	e8 6c fc ff ff       	call   f01041f2 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104586:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010458a:	75 4d                	jne    f01045d9 <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010458c:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010458f:	a8 01                	test   $0x1,%al
f0104591:	74 07                	je     f010459a <print_trapframe+0xe0>
f0104593:	b9 5b 84 10 f0       	mov    $0xf010845b,%ecx
f0104598:	eb 05                	jmp    f010459f <print_trapframe+0xe5>
f010459a:	b9 66 84 10 f0       	mov    $0xf0108466,%ecx
f010459f:	a8 02                	test   $0x2,%al
f01045a1:	74 07                	je     f01045aa <print_trapframe+0xf0>
f01045a3:	ba 72 84 10 f0       	mov    $0xf0108472,%edx
f01045a8:	eb 05                	jmp    f01045af <print_trapframe+0xf5>
f01045aa:	ba 78 84 10 f0       	mov    $0xf0108478,%edx
f01045af:	a8 04                	test   $0x4,%al
f01045b1:	74 07                	je     f01045ba <print_trapframe+0x100>
f01045b3:	b8 7d 84 10 f0       	mov    $0xf010847d,%eax
f01045b8:	eb 05                	jmp    f01045bf <print_trapframe+0x105>
f01045ba:	b8 cd 85 10 f0       	mov    $0xf01085cd,%eax
f01045bf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01045c3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045cb:	c7 04 24 f5 84 10 f0 	movl   $0xf01084f5,(%esp)
f01045d2:	e8 1b fc ff ff       	call   f01041f2 <cprintf>
f01045d7:	eb 0c                	jmp    f01045e5 <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01045d9:	c7 04 24 b5 82 10 f0 	movl   $0xf01082b5,(%esp)
f01045e0:	e8 0d fc ff ff       	call   f01041f2 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01045e5:	8b 43 30             	mov    0x30(%ebx),%eax
f01045e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ec:	c7 04 24 04 85 10 f0 	movl   $0xf0108504,(%esp)
f01045f3:	e8 fa fb ff ff       	call   f01041f2 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01045f8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01045fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104600:	c7 04 24 13 85 10 f0 	movl   $0xf0108513,(%esp)
f0104607:	e8 e6 fb ff ff       	call   f01041f2 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010460c:	8b 43 38             	mov    0x38(%ebx),%eax
f010460f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104613:	c7 04 24 26 85 10 f0 	movl   $0xf0108526,(%esp)
f010461a:	e8 d3 fb ff ff       	call   f01041f2 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010461f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104623:	74 27                	je     f010464c <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104625:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104628:	89 44 24 04          	mov    %eax,0x4(%esp)
f010462c:	c7 04 24 35 85 10 f0 	movl   $0xf0108535,(%esp)
f0104633:	e8 ba fb ff ff       	call   f01041f2 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104638:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010463c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104640:	c7 04 24 44 85 10 f0 	movl   $0xf0108544,(%esp)
f0104647:	e8 a6 fb ff ff       	call   f01041f2 <cprintf>
	}
}
f010464c:	83 c4 14             	add    $0x14,%esp
f010464f:	5b                   	pop    %ebx
f0104650:	5d                   	pop    %ebp
f0104651:	c3                   	ret    

f0104652 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104652:	55                   	push   %ebp
f0104653:	89 e5                	mov    %esp,%ebp
f0104655:	57                   	push   %edi
f0104656:	56                   	push   %esi
f0104657:	53                   	push   %ebx
f0104658:	83 ec 2c             	sub    $0x2c,%esp
f010465b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010465e:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0104661:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104665:	75 1c                	jne    f0104683 <page_fault_handler+0x31>
		panic("page fault in kernel mode!");
f0104667:	c7 44 24 08 57 85 10 	movl   $0xf0108557,0x8(%esp)
f010466e:	f0 
f010466f:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0104676:	00 
f0104677:	c7 04 24 72 85 10 f0 	movl   $0xf0108572,(%esp)
f010467e:	e8 bd b9 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0104683:	e8 ec 20 00 00       	call   f0106774 <cpunum>
f0104688:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010468f:	29 c2                	sub    %eax,%edx
f0104691:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104694:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010469b:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010469f:	0f 84 f0 00 00 00    	je     f0104795 <page_fault_handler+0x143>
		struct UTrapframe *utf = tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP ?
f01046a5:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046a8:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
							(struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4) :
f01046ae:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)
f01046b5:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01046bb:	77 06                	ja     f01046c3 <page_fault_handler+0x71>
f01046bd:	83 e8 38             	sub    $0x38,%eax
f01046c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
							(struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe)) ;
		// this is a totally wrong statement!
		// struct UTrapframe *utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
		user_mem_assert(curenv, (void *)utf, 1, PTE_W);
f01046c3:	e8 ac 20 00 00       	call   f0106774 <cpunum>
f01046c8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01046cf:	00 
f01046d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01046d7:	00 
f01046d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046db:	89 54 24 04          	mov    %edx,0x4(%esp)
f01046df:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e2:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f01046e8:	89 04 24             	mov    %eax,(%esp)
f01046eb:	e8 95 f0 ff ff       	call   f0103785 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f01046f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046f3:	89 30                	mov    %esi,(%eax)
		utf->utf_err = tf->tf_err;
f01046f5:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01046f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046fb:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs = tf->tf_regs;
f01046fe:	89 d7                	mov    %edx,%edi
f0104700:	83 c7 08             	add    $0x8,%edi
f0104703:	89 de                	mov    %ebx,%esi
f0104705:	b8 20 00 00 00       	mov    $0x20,%eax
f010470a:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104710:	74 03                	je     f0104715 <page_fault_handler+0xc3>
f0104712:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104713:	b0 1f                	mov    $0x1f,%al
f0104715:	f7 c7 02 00 00 00    	test   $0x2,%edi
f010471b:	74 05                	je     f0104722 <page_fault_handler+0xd0>
f010471d:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010471f:	83 e8 02             	sub    $0x2,%eax
f0104722:	89 c1                	mov    %eax,%ecx
f0104724:	c1 e9 02             	shr    $0x2,%ecx
f0104727:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104729:	a8 02                	test   $0x2,%al
f010472b:	74 02                	je     f010472f <page_fault_handler+0xdd>
f010472d:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010472f:	a8 01                	test   $0x1,%al
f0104731:	74 01                	je     f0104734 <page_fault_handler+0xe2>
f0104733:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0104734:	8b 43 30             	mov    0x30(%ebx),%eax
f0104737:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010473a:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f010473d:	8b 43 38             	mov    0x38(%ebx),%eax
f0104740:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104743:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104746:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104749:	e8 26 20 00 00       	call   f0106774 <cpunum>
f010474e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104751:	8b 98 28 30 33 f0    	mov    -0xfcccfd8(%eax),%ebx
f0104757:	e8 18 20 00 00       	call   f0106774 <cpunum>
f010475c:	6b c0 74             	imul   $0x74,%eax,%eax
f010475f:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0104765:	8b 40 64             	mov    0x64(%eax),%eax
f0104768:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uintptr_t)utf;
f010476b:	e8 04 20 00 00       	call   f0106774 <cpunum>
f0104770:	6b c0 74             	imul   $0x74,%eax,%eax
f0104773:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0104779:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010477c:	89 50 3c             	mov    %edx,0x3c(%eax)
		env_run(curenv);
f010477f:	e8 f0 1f 00 00       	call   f0106774 <cpunum>
f0104784:	6b c0 74             	imul   $0x74,%eax,%eax
f0104787:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f010478d:	89 04 24             	mov    %eax,(%esp)
f0104790:	e8 0e f8 ff ff       	call   f0103fa3 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104795:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104798:	e8 d7 1f 00 00       	call   f0106774 <cpunum>
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010479d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01047a1:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01047a5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047ac:	29 c2                	sub    %eax,%edx
f01047ae:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01047b1:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01047b8:	8b 40 48             	mov    0x48(%eax),%eax
f01047bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01047bf:	c7 04 24 18 87 10 f0 	movl   $0xf0108718,(%esp)
f01047c6:	e8 27 fa ff ff       	call   f01041f2 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01047cb:	89 1c 24             	mov    %ebx,(%esp)
f01047ce:	e8 e7 fc ff ff       	call   f01044ba <print_trapframe>
	env_destroy(curenv);
f01047d3:	e8 9c 1f 00 00       	call   f0106774 <cpunum>
f01047d8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047df:	29 c2                	sub    %eax,%edx
f01047e1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01047e4:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01047eb:	89 04 24             	mov    %eax,(%esp)
f01047ee:	e8 f1 f6 ff ff       	call   f0103ee4 <env_destroy>
}
f01047f3:	83 c4 2c             	add    $0x2c,%esp
f01047f6:	5b                   	pop    %ebx
f01047f7:	5e                   	pop    %esi
f01047f8:	5f                   	pop    %edi
f01047f9:	5d                   	pop    %ebp
f01047fa:	c3                   	ret    

f01047fb <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01047fb:	55                   	push   %ebp
f01047fc:	89 e5                	mov    %esp,%ebp
f01047fe:	57                   	push   %edi
f01047ff:	56                   	push   %esi
f0104800:	83 ec 20             	sub    $0x20,%esp
f0104803:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104806:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104807:	83 3d 80 2e 33 f0 00 	cmpl   $0x0,0xf0332e80
f010480e:	74 01                	je     f0104811 <trap+0x16>
		asm volatile("hlt");
f0104810:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104811:	e8 5e 1f 00 00       	call   f0106774 <cpunum>
f0104816:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010481d:	29 c2                	sub    %eax,%edx
f010481f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104822:	8d 14 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104829:	b8 01 00 00 00       	mov    $0x1,%eax
f010482e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104832:	83 f8 02             	cmp    $0x2,%eax
f0104835:	75 0c                	jne    f0104843 <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104837:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f010483e:	e8 f0 21 00 00       	call   f0106a33 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104843:	9c                   	pushf  
f0104844:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104845:	f6 c4 02             	test   $0x2,%ah
f0104848:	74 24                	je     f010486e <trap+0x73>
f010484a:	c7 44 24 0c 7e 85 10 	movl   $0xf010857e,0xc(%esp)
f0104851:	f0 
f0104852:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f0104859:	f0 
f010485a:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
f0104861:	00 
f0104862:	c7 04 24 72 85 10 f0 	movl   $0xf0108572,(%esp)
f0104869:	e8 d2 b7 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010486e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104872:	83 e0 03             	and    $0x3,%eax
f0104875:	83 f8 03             	cmp    $0x3,%eax
f0104878:	0f 85 a7 00 00 00    	jne    f0104925 <trap+0x12a>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f010487e:	e8 f1 1e 00 00       	call   f0106774 <cpunum>
f0104883:	6b c0 74             	imul   $0x74,%eax,%eax
f0104886:	83 b8 28 30 33 f0 00 	cmpl   $0x0,-0xfcccfd8(%eax)
f010488d:	75 24                	jne    f01048b3 <trap+0xb8>
f010488f:	c7 44 24 0c 97 85 10 	movl   $0xf0108597,0xc(%esp)
f0104896:	f0 
f0104897:	c7 44 24 08 fb 7f 10 	movl   $0xf0107ffb,0x8(%esp)
f010489e:	f0 
f010489f:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f01048a6:	00 
f01048a7:	c7 04 24 72 85 10 f0 	movl   $0xf0108572,(%esp)
f01048ae:	e8 8d b7 ff ff       	call   f0100040 <_panic>
f01048b3:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f01048ba:	e8 74 21 00 00       	call   f0106a33 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01048bf:	e8 b0 1e 00 00       	call   f0106774 <cpunum>
f01048c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c7:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f01048cd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01048d1:	75 2d                	jne    f0104900 <trap+0x105>
			env_free(curenv);
f01048d3:	e8 9c 1e 00 00       	call   f0106774 <cpunum>
f01048d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01048db:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f01048e1:	89 04 24             	mov    %eax,(%esp)
f01048e4:	e8 d7 f3 ff ff       	call   f0103cc0 <env_free>
			curenv = NULL;
f01048e9:	e8 86 1e 00 00       	call   f0106774 <cpunum>
f01048ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01048f1:	c7 80 28 30 33 f0 00 	movl   $0x0,-0xfcccfd8(%eax)
f01048f8:	00 00 00 
			sched_yield();
f01048fb:	e8 31 03 00 00       	call   f0104c31 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104900:	e8 6f 1e 00 00       	call   f0106774 <cpunum>
f0104905:	6b c0 74             	imul   $0x74,%eax,%eax
f0104908:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f010490e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104913:	89 c7                	mov    %eax,%edi
f0104915:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104917:	e8 58 1e 00 00       	call   f0106774 <cpunum>
f010491c:	6b c0 74             	imul   $0x74,%eax,%eax
f010491f:	8b b0 28 30 33 f0    	mov    -0xfcccfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104925:	89 35 60 2a 33 f0    	mov    %esi,0xf0332a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	switch (tf->tf_trapno) {
f010492b:	8b 46 28             	mov    0x28(%esi),%eax
f010492e:	83 f8 0e             	cmp    $0xe,%eax
f0104931:	74 0c                	je     f010493f <trap+0x144>
f0104933:	83 f8 30             	cmp    $0x30,%eax
f0104936:	74 21                	je     f0104959 <trap+0x15e>
f0104938:	83 f8 03             	cmp    $0x3,%eax
f010493b:	75 4e                	jne    f010498b <trap+0x190>
f010493d:	eb 0d                	jmp    f010494c <trap+0x151>
	case T_PGFLT:
		page_fault_handler(tf);
f010493f:	89 34 24             	mov    %esi,(%esp)
f0104942:	e8 0b fd ff ff       	call   f0104652 <page_fault_handler>
f0104947:	e9 aa 00 00 00       	jmp    f01049f6 <trap+0x1fb>
		return;
	case T_BRKPT:
		monitor(tf);
f010494c:	89 34 24             	mov    %esi,(%esp)
f010494f:	e8 da c2 ff ff       	call   f0100c2e <monitor>
f0104954:	e9 9d 00 00 00       	jmp    f01049f6 <trap+0x1fb>
		return;
	case T_SYSCALL:
		// we should put the return value in %eax
		tf->tf_regs.reg_eax =
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104959:	8b 46 04             	mov    0x4(%esi),%eax
f010495c:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104960:	8b 06                	mov    (%esi),%eax
f0104962:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104966:	8b 46 10             	mov    0x10(%esi),%eax
f0104969:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010496d:	8b 46 18             	mov    0x18(%esi),%eax
f0104970:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104974:	8b 46 14             	mov    0x14(%esi),%eax
f0104977:	89 44 24 04          	mov    %eax,0x4(%esp)
f010497b:	8b 46 1c             	mov    0x1c(%esi),%eax
f010497e:	89 04 24             	mov    %eax,(%esp)
f0104981:	e8 a5 03 00 00       	call   f0104d2b <syscall>
	case T_BRKPT:
		monitor(tf);
		return;
	case T_SYSCALL:
		// we should put the return value in %eax
		tf->tf_regs.reg_eax =
f0104986:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104989:	eb 6b                	jmp    f01049f6 <trap+0x1fb>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010498b:	83 f8 27             	cmp    $0x27,%eax
f010498e:	75 16                	jne    f01049a6 <trap+0x1ab>
		cprintf("Spurious interrupt on irq 7\n");
f0104990:	c7 04 24 9e 85 10 f0 	movl   $0xf010859e,(%esp)
f0104997:	e8 56 f8 ff ff       	call   f01041f2 <cprintf>
		print_trapframe(tf);
f010499c:	89 34 24             	mov    %esi,(%esp)
f010499f:	e8 16 fb ff ff       	call   f01044ba <print_trapframe>
f01049a4:	eb 50                	jmp    f01049f6 <trap+0x1fb>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01049a6:	83 f8 20             	cmp    $0x20,%eax
f01049a9:	75 0a                	jne    f01049b5 <trap+0x1ba>
		lapic_eoi();
f01049ab:	e8 1b 1f 00 00       	call   f01068cb <lapic_eoi>
		sched_yield();
f01049b0:	e8 7c 02 00 00       	call   f0104c31 <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01049b5:	89 34 24             	mov    %esi,(%esp)
f01049b8:	e8 fd fa ff ff       	call   f01044ba <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01049bd:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01049c2:	75 1c                	jne    f01049e0 <trap+0x1e5>
		panic("unhandled trap in kernel");
f01049c4:	c7 44 24 08 bb 85 10 	movl   $0xf01085bb,0x8(%esp)
f01049cb:	f0 
f01049cc:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
f01049d3:	00 
f01049d4:	c7 04 24 72 85 10 f0 	movl   $0xf0108572,(%esp)
f01049db:	e8 60 b6 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01049e0:	e8 8f 1d 00 00       	call   f0106774 <cpunum>
f01049e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e8:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f01049ee:	89 04 24             	mov    %eax,(%esp)
f01049f1:	e8 ee f4 ff ff       	call   f0103ee4 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01049f6:	e8 79 1d 00 00       	call   f0106774 <cpunum>
f01049fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01049fe:	83 b8 28 30 33 f0 00 	cmpl   $0x0,-0xfcccfd8(%eax)
f0104a05:	74 2a                	je     f0104a31 <trap+0x236>
f0104a07:	e8 68 1d 00 00       	call   f0106774 <cpunum>
f0104a0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0f:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0104a15:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104a19:	75 16                	jne    f0104a31 <trap+0x236>
		env_run(curenv);
f0104a1b:	e8 54 1d 00 00       	call   f0106774 <cpunum>
f0104a20:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a23:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0104a29:	89 04 24             	mov    %eax,(%esp)
f0104a2c:	e8 72 f5 ff ff       	call   f0103fa3 <env_run>
	else
		sched_yield();
f0104a31:	e8 fb 01 00 00       	call   f0104c31 <sched_yield>
	...

f0104a38 <t_divide_handler>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC_AUTO(t_divide_handler, T_DIVIDE)
f0104a38:	6a 00                	push   $0x0
f0104a3a:	6a 00                	push   $0x0
f0104a3c:	e9 e7 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a41:	90                   	nop

f0104a42 <t_debug_handler>:
TRAPHANDLER_NOEC_AUTO(t_debug_handler, T_DEBUG)
f0104a42:	6a 00                	push   $0x0
f0104a44:	6a 01                	push   $0x1
f0104a46:	e9 dd 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a4b:	90                   	nop

f0104a4c <t_nmi_handler>:
TRAPHANDLER_NOEC_AUTO(t_nmi_handler, T_NMI)
f0104a4c:	6a 00                	push   $0x0
f0104a4e:	6a 02                	push   $0x2
f0104a50:	e9 d3 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a55:	90                   	nop

f0104a56 <t_brkpt_handler>:
TRAPHANDLER_NOEC_AUTO(t_brkpt_handler, T_BRKPT)
f0104a56:	6a 00                	push   $0x0
f0104a58:	6a 03                	push   $0x3
f0104a5a:	e9 c9 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a5f:	90                   	nop

f0104a60 <t_oflow_handler>:
TRAPHANDLER_NOEC_AUTO(t_oflow_handler, T_OFLOW)
f0104a60:	6a 00                	push   $0x0
f0104a62:	6a 04                	push   $0x4
f0104a64:	e9 bf 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a69:	90                   	nop

f0104a6a <t_bound_handler>:
TRAPHANDLER_NOEC_AUTO(t_bound_handler, T_BOUND)
f0104a6a:	6a 00                	push   $0x0
f0104a6c:	6a 05                	push   $0x5
f0104a6e:	e9 b5 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a73:	90                   	nop

f0104a74 <t_illop_handler>:
TRAPHANDLER_NOEC_AUTO(t_illop_handler, T_ILLOP)
f0104a74:	6a 00                	push   $0x0
f0104a76:	6a 06                	push   $0x6
f0104a78:	e9 ab 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a7d:	90                   	nop

f0104a7e <t_device_handler>:
TRAPHANDLER_NOEC_AUTO(t_device_handler, T_DEVICE)
f0104a7e:	6a 00                	push   $0x0
f0104a80:	6a 07                	push   $0x7
f0104a82:	e9 a1 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a87:	90                   	nop

f0104a88 <t_dblflt_handler>:
TRAPHANDLER_AUTO(t_dblflt_handler, T_DBLFLT)
f0104a88:	6a 08                	push   $0x8
f0104a8a:	e9 99 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a8f:	90                   	nop

f0104a90 <t_tss_handler>:
PADDING()/* #define T_COPROC  9 */	// reserved (not generated by recent processors)
TRAPHANDLER_AUTO(t_tss_handler, T_TSS)
f0104a90:	6a 0a                	push   $0xa
f0104a92:	e9 91 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a97:	90                   	nop

f0104a98 <t_segnp_handler>:
TRAPHANDLER_AUTO(t_segnp_handler, T_SEGNP)
f0104a98:	6a 0b                	push   $0xb
f0104a9a:	e9 89 00 00 00       	jmp    f0104b28 <_alltraps>
f0104a9f:	90                   	nop

f0104aa0 <t_stack_handler>:
TRAPHANDLER_AUTO(t_stack_handler, T_STACK)
f0104aa0:	6a 0c                	push   $0xc
f0104aa2:	e9 81 00 00 00       	jmp    f0104b28 <_alltraps>
f0104aa7:	90                   	nop

f0104aa8 <t_gpflt_handler>:
TRAPHANDLER_AUTO(t_gpflt_handler, T_GPFLT)
f0104aa8:	6a 0d                	push   $0xd
f0104aaa:	eb 7c                	jmp    f0104b28 <_alltraps>

f0104aac <t_pgflt_handler>:
TRAPHANDLER_AUTO(t_pgflt_handler, T_PGFLT)
f0104aac:	6a 0e                	push   $0xe
f0104aae:	eb 78                	jmp    f0104b28 <_alltraps>

f0104ab0 <t_fperr_handler>:
PADDING()/* #define T_RES    15 */	// reserved
TRAPHANDLER_NOEC_AUTO(t_fperr_handler, T_FPERR)
f0104ab0:	6a 00                	push   $0x0
f0104ab2:	6a 10                	push   $0x10
f0104ab4:	eb 72                	jmp    f0104b28 <_alltraps>

f0104ab6 <t_align_handler>:
TRAPHANDLER_AUTO(t_align_handler, T_ALIGN)
f0104ab6:	6a 11                	push   $0x11
f0104ab8:	eb 6e                	jmp    f0104b28 <_alltraps>

f0104aba <t_mchk_handler>:
TRAPHANDLER_AUTO(t_mchk_handler, T_MCHK)
f0104aba:	6a 12                	push   $0x12
f0104abc:	eb 6a                	jmp    f0104b28 <_alltraps>

f0104abe <t_simderr_handler>:
TRAPHANDLER_AUTO(t_simderr_handler, T_SIMDERR)
f0104abe:	6a 13                	push   $0x13
f0104ac0:	eb 66                	jmp    f0104b28 <_alltraps>

f0104ac2 <t_syscall_handler>:
TRAPHANDLER_NOEC_AUTO(t_syscall_handler, T_SYSCALL)
f0104ac2:	6a 00                	push   $0x0
f0104ac4:	6a 30                	push   $0x30
f0104ac6:	eb 60                	jmp    f0104b28 <_alltraps>

f0104ac8 <irq_handler_0>:

/*
 * Lab 4: For IRQs
 */

TRAPHANDLER_NOEC_AUTO(irq_handler_0, 32)
f0104ac8:	6a 00                	push   $0x0
f0104aca:	6a 20                	push   $0x20
f0104acc:	eb 5a                	jmp    f0104b28 <_alltraps>

f0104ace <irq_handler_1>:
TRAPHANDLER_NOEC_AUTO(irq_handler_1, 33)
f0104ace:	6a 00                	push   $0x0
f0104ad0:	6a 21                	push   $0x21
f0104ad2:	eb 54                	jmp    f0104b28 <_alltraps>

f0104ad4 <irq_handler_2>:
TRAPHANDLER_NOEC_AUTO(irq_handler_2, 34)
f0104ad4:	6a 00                	push   $0x0
f0104ad6:	6a 22                	push   $0x22
f0104ad8:	eb 4e                	jmp    f0104b28 <_alltraps>

f0104ada <irq_handler_3>:
TRAPHANDLER_NOEC_AUTO(irq_handler_3, 35)
f0104ada:	6a 00                	push   $0x0
f0104adc:	6a 23                	push   $0x23
f0104ade:	eb 48                	jmp    f0104b28 <_alltraps>

f0104ae0 <irq_handler_4>:
TRAPHANDLER_NOEC_AUTO(irq_handler_4, 36)
f0104ae0:	6a 00                	push   $0x0
f0104ae2:	6a 24                	push   $0x24
f0104ae4:	eb 42                	jmp    f0104b28 <_alltraps>

f0104ae6 <irq_handler_5>:
TRAPHANDLER_NOEC_AUTO(irq_handler_5, 37)
f0104ae6:	6a 00                	push   $0x0
f0104ae8:	6a 25                	push   $0x25
f0104aea:	eb 3c                	jmp    f0104b28 <_alltraps>

f0104aec <irq_handler_6>:
TRAPHANDLER_NOEC_AUTO(irq_handler_6, 38)
f0104aec:	6a 00                	push   $0x0
f0104aee:	6a 26                	push   $0x26
f0104af0:	eb 36                	jmp    f0104b28 <_alltraps>

f0104af2 <irq_handler_7>:
TRAPHANDLER_NOEC_AUTO(irq_handler_7, 39)
f0104af2:	6a 00                	push   $0x0
f0104af4:	6a 27                	push   $0x27
f0104af6:	eb 30                	jmp    f0104b28 <_alltraps>

f0104af8 <irq_handler_8>:
TRAPHANDLER_NOEC_AUTO(irq_handler_8, 40)
f0104af8:	6a 00                	push   $0x0
f0104afa:	6a 28                	push   $0x28
f0104afc:	eb 2a                	jmp    f0104b28 <_alltraps>

f0104afe <irq_handler_9>:
TRAPHANDLER_NOEC_AUTO(irq_handler_9, 41)
f0104afe:	6a 00                	push   $0x0
f0104b00:	6a 29                	push   $0x29
f0104b02:	eb 24                	jmp    f0104b28 <_alltraps>

f0104b04 <irq_handler_10>:
TRAPHANDLER_NOEC_AUTO(irq_handler_10, 42)
f0104b04:	6a 00                	push   $0x0
f0104b06:	6a 2a                	push   $0x2a
f0104b08:	eb 1e                	jmp    f0104b28 <_alltraps>

f0104b0a <irq_handler_11>:
TRAPHANDLER_NOEC_AUTO(irq_handler_11, 43)
f0104b0a:	6a 00                	push   $0x0
f0104b0c:	6a 2b                	push   $0x2b
f0104b0e:	eb 18                	jmp    f0104b28 <_alltraps>

f0104b10 <irq_handler_12>:
TRAPHANDLER_NOEC_AUTO(irq_handler_12, 44)
f0104b10:	6a 00                	push   $0x0
f0104b12:	6a 2c                	push   $0x2c
f0104b14:	eb 12                	jmp    f0104b28 <_alltraps>

f0104b16 <irq_handler_13>:
TRAPHANDLER_NOEC_AUTO(irq_handler_13, 45)
f0104b16:	6a 00                	push   $0x0
f0104b18:	6a 2d                	push   $0x2d
f0104b1a:	eb 0c                	jmp    f0104b28 <_alltraps>

f0104b1c <irq_handler_14>:
TRAPHANDLER_NOEC_AUTO(irq_handler_14, 46)
f0104b1c:	6a 00                	push   $0x0
f0104b1e:	6a 2e                	push   $0x2e
f0104b20:	eb 06                	jmp    f0104b28 <_alltraps>

f0104b22 <irq_handler_15>:
TRAPHANDLER_NOEC_AUTO(irq_handler_15, 47)
f0104b22:	6a 00                	push   $0x0
f0104b24:	6a 2f                	push   $0x2f
f0104b26:	eb 00                	jmp    f0104b28 <_alltraps>

f0104b28 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
f0104b28:	1e                   	push   %ds
	pushl %es
f0104b29:	06                   	push   %es
	pushal
f0104b2a:	60                   	pusha  
	movl $GD_KD, %eax
f0104b2b:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f0104b30:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f0104b32:	8e c0                	mov    %eax,%es
	pushl %esp
f0104b34:	54                   	push   %esp
	call trap
f0104b35:	e8 c1 fc ff ff       	call   f01047fb <trap>
	...

f0104b3c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104b3c:	55                   	push   %ebp
f0104b3d:	89 e5                	mov    %esp,%ebp
f0104b3f:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104b42:	8b 15 48 22 33 f0    	mov    0xf0332248,%edx
f0104b48:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104b4b:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104b50:	8b 0a                	mov    (%edx),%ecx
f0104b52:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104b53:	83 f9 02             	cmp    $0x2,%ecx
f0104b56:	76 10                	jbe    f0104b68 <sched_halt+0x2c>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104b58:	40                   	inc    %eax
f0104b59:	81 c2 ac 00 00 00    	add    $0xac,%edx
f0104b5f:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b64:	75 ea                	jne    f0104b50 <sched_halt+0x14>
f0104b66:	eb 07                	jmp    f0104b6f <sched_halt+0x33>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104b68:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b6d:	75 1a                	jne    f0104b89 <sched_halt+0x4d>
		cprintf("No runnable environments in the system!\n");
f0104b6f:	c7 04 24 90 87 10 f0 	movl   $0xf0108790,(%esp)
f0104b76:	e8 77 f6 ff ff       	call   f01041f2 <cprintf>
		while (1)
			monitor(NULL);
f0104b7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104b82:	e8 a7 c0 ff ff       	call   f0100c2e <monitor>
f0104b87:	eb f2                	jmp    f0104b7b <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104b89:	e8 e6 1b 00 00       	call   f0106774 <cpunum>
f0104b8e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b95:	29 c2                	sub    %eax,%edx
f0104b97:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b9a:	c7 04 85 28 30 33 f0 	movl   $0x0,-0xfcccfd8(,%eax,4)
f0104ba1:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104ba5:	a1 8c 2e 33 f0       	mov    0xf0332e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104baa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104baf:	77 20                	ja     f0104bd1 <sched_halt+0x95>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104bb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104bb5:	c7 44 24 08 64 6e 10 	movl   $0xf0106e64,0x8(%esp)
f0104bbc:	f0 
f0104bbd:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
f0104bc4:	00 
f0104bc5:	c7 04 24 b9 87 10 f0 	movl   $0xf01087b9,(%esp)
f0104bcc:	e8 6f b4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104bd1:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104bd6:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104bd9:	e8 96 1b 00 00       	call   f0106774 <cpunum>
f0104bde:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104be5:	29 c2                	sub    %eax,%edx
f0104be7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bea:	8d 14 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104bf1:	b8 02 00 00 00       	mov    $0x2,%eax
f0104bf6:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104bfa:	c7 04 24 60 a4 12 f0 	movl   $0xf012a460,(%esp)
f0104c01:	e8 d0 1e 00 00       	call   f0106ad6 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104c06:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104c08:	e8 67 1b 00 00       	call   f0106774 <cpunum>
f0104c0d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c14:	29 c2                	sub    %eax,%edx
f0104c16:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104c19:	8b 04 85 30 30 33 f0 	mov    -0xfcccfd0(,%eax,4),%eax
f0104c20:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104c25:	89 c4                	mov    %eax,%esp
f0104c27:	6a 00                	push   $0x0
f0104c29:	6a 00                	push   $0x0
f0104c2b:	fb                   	sti    
f0104c2c:	f4                   	hlt    
f0104c2d:	eb fd                	jmp    f0104c2c <sched_halt+0xf0>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104c2f:	c9                   	leave  
f0104c30:	c3                   	ret    

f0104c31 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104c31:	55                   	push   %ebp
f0104c32:	89 e5                	mov    %esp,%ebp
f0104c34:	56                   	push   %esi
f0104c35:	53                   	push   %ebx
f0104c36:	83 ec 10             	sub    $0x10,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
f0104c39:	e8 36 1b 00 00       	call   f0106774 <cpunum>
f0104c3e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c45:	29 c2                	sub    %eax,%edx
f0104c47:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c4a:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0104c51:	00 
f0104c52:	74 23                	je     f0104c77 <sched_yield+0x46>
f0104c54:	e8 1b 1b 00 00       	call   f0106774 <cpunum>
f0104c59:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c60:	29 c2                	sub    %eax,%edx
f0104c62:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c65:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104c6c:	8b 58 48             	mov    0x48(%eax),%ebx
f0104c6f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0104c75:	eb 05                	jmp    f0104c7c <sched_yield+0x4b>
f0104c77:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < NENV; i++) {
		int id = (i + offset) % NENV;
		if (envs[id].env_status == ENV_RUNNABLE)
f0104c7c:	8b 0d 48 22 33 f0    	mov    0xf0332248,%ecx
	// below to halt the cpu.

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++) {
f0104c82:	ba 00 00 00 00       	mov    $0x0,%edx

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
f0104c87:	8d 04 1a             	lea    (%edx,%ebx,1),%eax

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++) {
		int id = (i + offset) % NENV;
f0104c8a:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104c8f:	79 07                	jns    f0104c98 <sched_yield+0x67>
f0104c91:	48                   	dec    %eax
f0104c92:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104c97:	40                   	inc    %eax
		if (envs[id].env_status == ENV_RUNNABLE)
f0104c98:	8d 34 80             	lea    (%eax,%eax,4),%esi
f0104c9b:	8d 34 b0             	lea    (%eax,%esi,4),%esi
f0104c9e:	8d 04 70             	lea    (%eax,%esi,2),%eax
f0104ca1:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104ca4:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104ca8:	75 08                	jne    f0104cb2 <sched_yield+0x81>
			env_run(&envs[id]);
f0104caa:	89 04 24             	mov    %eax,(%esp)
f0104cad:	e8 f1 f2 ff ff       	call   f0103fa3 <env_run>
	// below to halt the cpu.

	// LAB 4: Your code here.
	int offset = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++) {
f0104cb2:	42                   	inc    %edx
f0104cb3:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104cb9:	75 cc                	jne    f0104c87 <sched_yield+0x56>
		int id = (i + offset) % NENV;
		if (envs[id].env_status == ENV_RUNNABLE)
			env_run(&envs[id]);
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104cbb:	e8 b4 1a 00 00       	call   f0106774 <cpunum>
f0104cc0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cc7:	29 c2                	sub    %eax,%edx
f0104cc9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ccc:	83 3c 85 28 30 33 f0 	cmpl   $0x0,-0xfcccfd8(,%eax,4)
f0104cd3:	00 
f0104cd4:	74 3e                	je     f0104d14 <sched_yield+0xe3>
f0104cd6:	e8 99 1a 00 00       	call   f0106774 <cpunum>
f0104cdb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ce2:	29 c2                	sub    %eax,%edx
f0104ce4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ce7:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104cee:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104cf2:	75 20                	jne    f0104d14 <sched_yield+0xe3>
		env_run(curenv);
f0104cf4:	e8 7b 1a 00 00       	call   f0106774 <cpunum>
f0104cf9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d00:	29 c2                	sub    %eax,%edx
f0104d02:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d05:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104d0c:	89 04 24             	mov    %eax,(%esp)
f0104d0f:	e8 8f f2 ff ff       	call   f0103fa3 <env_run>

	// sched_halt never returns
	sched_halt();
f0104d14:	e8 23 fe ff ff       	call   f0104b3c <sched_halt>
}
f0104d19:	83 c4 10             	add    $0x10,%esp
f0104d1c:	5b                   	pop    %ebx
f0104d1d:	5e                   	pop    %esi
f0104d1e:	5d                   	pop    %ebp
f0104d1f:	c3                   	ret    

f0104d20 <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0104d20:	55                   	push   %ebp
f0104d21:	89 e5                	mov    %esp,%ebp
f0104d23:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104d26:	e8 06 ff ff ff       	call   f0104c31 <sched_yield>

f0104d2b <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d2b:	55                   	push   %ebp
f0104d2c:	89 e5                	mov    %esp,%ebp
f0104d2e:	57                   	push   %edi
f0104d2f:	56                   	push   %esi
f0104d30:	53                   	push   %ebx
f0104d31:	83 ec 3c             	sub    $0x3c,%esp
f0104d34:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d37:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104d3a:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104d3d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f0104d40:	83 f8 0c             	cmp    $0xc,%eax
f0104d43:	0f 87 22 08 00 00    	ja     f010556b <syscall+0x840>
f0104d49:	ff 24 85 70 88 10 f0 	jmp    *-0xfef7790(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104d50:	e8 1f 1a 00 00       	call   f0106774 <cpunum>
f0104d55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104d5c:	00 
f0104d5d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104d61:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d65:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d6c:	29 c2                	sub    %eax,%edx
f0104d6e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d71:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104d78:	89 04 24             	mov    %eax,(%esp)
f0104d7b:	e8 05 ea ff ff       	call   f0103785 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104d80:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104d84:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104d88:	c7 04 24 c6 87 10 f0 	movl   $0xf01087c6,(%esp)
f0104d8f:	e8 5e f4 ff ff       	call   f01041f2 <cprintf>
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, a2);
		return 0;
f0104d94:	be 00 00 00 00       	mov    $0x0,%esi
f0104d99:	e9 d9 07 00 00       	jmp    f0105577 <syscall+0x84c>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d9e:	e8 dd b8 ff ff       	call   f0100680 <cons_getc>
f0104da3:	89 c6                	mov    %eax,%esi
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f0104da5:	e9 cd 07 00 00       	jmp    f0105577 <syscall+0x84c>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104daa:	e8 c5 19 00 00       	call   f0106774 <cpunum>
f0104daf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104db6:	29 c2                	sub    %eax,%edx
f0104db8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dbb:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104dc2:	8b 70 48             	mov    0x48(%eax),%esi
		sys_cputs((char *)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
f0104dc5:	e9 ad 07 00 00       	jmp    f0105577 <syscall+0x84c>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104dca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104dd1:	00 
f0104dd2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dd9:	89 34 24             	mov    %esi,(%esp)
f0104ddc:	e8 7a ea ff ff       	call   f010385b <envid2env>
f0104de1:	85 c0                	test   %eax,%eax
f0104de3:	0f 88 89 07 00 00    	js     f0105572 <syscall+0x847>
		return r;
	if (e == curenv)
f0104de9:	e8 86 19 00 00       	call   f0106774 <cpunum>
f0104dee:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104df1:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0104df8:	29 c1                	sub    %eax,%ecx
f0104dfa:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0104dfd:	39 14 85 28 30 33 f0 	cmp    %edx,-0xfcccfd8(,%eax,4)
f0104e04:	75 2d                	jne    f0104e33 <syscall+0x108>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104e06:	e8 69 19 00 00       	call   f0106774 <cpunum>
f0104e0b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e12:	29 c2                	sub    %eax,%edx
f0104e14:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e17:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104e1e:	8b 40 48             	mov    0x48(%eax),%eax
f0104e21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e25:	c7 04 24 cb 87 10 f0 	movl   $0xf01087cb,(%esp)
f0104e2c:	e8 c1 f3 ff ff       	call   f01041f2 <cprintf>
f0104e31:	eb 32                	jmp    f0104e65 <syscall+0x13a>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104e33:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104e36:	e8 39 19 00 00       	call   f0106774 <cpunum>
f0104e3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104e3f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e46:	29 c2                	sub    %eax,%edx
f0104e48:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e4b:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104e52:	8b 40 48             	mov    0x48(%eax),%eax
f0104e55:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e59:	c7 04 24 e6 87 10 f0 	movl   $0xf01087e6,(%esp)
f0104e60:	e8 8d f3 ff ff       	call   f01041f2 <cprintf>
	env_destroy(e);
f0104e65:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e68:	89 04 24             	mov    %eax,(%esp)
f0104e6b:	e8 74 f0 ff ff       	call   f0103ee4 <env_destroy>
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		sys_env_destroy(a1);
		return 0;
f0104e70:	be 00 00 00 00       	mov    $0x0,%esi
f0104e75:	e9 fd 06 00 00       	jmp    f0105577 <syscall+0x84c>
	case SYS_yield:
		sys_yield();
f0104e7a:	e8 a1 fe ff ff       	call   f0104d20 <sys_yield>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_NO_FREE_ENV and -E_NO_MEM from env_alloc()
	if ((r = env_alloc(&e, curenv->env_id)) < 0)
f0104e7f:	e8 f0 18 00 00       	call   f0106774 <cpunum>
f0104e84:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e8b:	29 c2                	sub    %eax,%edx
f0104e8d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e90:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0104e97:	8b 40 48             	mov    0x48(%eax),%eax
f0104e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e9e:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ea1:	89 04 24             	mov    %eax,(%esp)
f0104ea4:	e8 dc ea ff ff       	call   f0103985 <env_alloc>
f0104ea9:	89 c6                	mov    %eax,%esi
f0104eab:	85 c0                	test   %eax,%eax
f0104ead:	0f 88 c4 06 00 00    	js     f0105577 <syscall+0x84c>
		return r;
	e->env_status = ENV_NOT_RUNNABLE;
f0104eb3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104eb6:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0104ebd:	e8 b2 18 00 00       	call   f0106774 <cpunum>
f0104ec2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ec9:	29 c2                	sub    %eax,%edx
f0104ecb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ece:	8b 34 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%esi
f0104ed5:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104eda:	89 df                	mov    %ebx,%edi
f0104edc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// set return value for child process
	e->env_tf.tf_regs.reg_eax = 0;
f0104ede:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ee1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104ee8:	8b 70 48             	mov    0x48(%eax),%esi
		return 0;
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
f0104eeb:	e9 87 06 00 00       	jmp    f0105577 <syscall+0x84c>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f0104ef0:	83 ff 02             	cmp    $0x2,%edi
f0104ef3:	74 05                	je     f0104efa <syscall+0x1cf>
f0104ef5:	83 ff 04             	cmp    $0x4,%edi
f0104ef8:	75 31                	jne    f0104f2b <syscall+0x200>
		return -E_INVAL;
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104efa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f01:	00 
f0104f02:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f05:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f09:	89 34 24             	mov    %esi,(%esp)
f0104f0c:	e8 4a e9 ff ff       	call   f010385b <envid2env>
f0104f11:	89 c6                	mov    %eax,%esi
f0104f13:	85 c0                	test   %eax,%eax
f0104f15:	0f 88 5c 06 00 00    	js     f0105577 <syscall+0x84c>
		return r;
	e->env_status = status;
f0104f1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f1e:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0104f21:	be 00 00 00 00       	mov    $0x0,%esi
f0104f26:	e9 4c 06 00 00       	jmp    f0105577 <syscall+0x84c>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f0104f2b:	be fd ff ff ff       	mov    $0xfffffffd,%esi
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
f0104f30:	e9 42 06 00 00       	jmp    f0105577 <syscall+0x84c>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104f35:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f3c:	00 
f0104f3d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f44:	89 34 24             	mov    %esi,(%esp)
f0104f47:	e8 0f e9 ff ff       	call   f010385b <envid2env>
f0104f4c:	89 c6                	mov    %eax,%esi
f0104f4e:	85 c0                	test   %eax,%eax
f0104f50:	0f 88 21 06 00 00    	js     f0105577 <syscall+0x84c>
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104f56:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104f5c:	77 60                	ja     f0104fbe <syscall+0x293>
f0104f5e:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f0104f64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104f69:	39 c7                	cmp    %eax,%edi
f0104f6b:	75 5b                	jne    f0104fc8 <syscall+0x29d>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f0104f6d:	89 d8                	mov    %ebx,%eax
f0104f6f:	83 e0 05             	and    $0x5,%eax
f0104f72:	83 f8 05             	cmp    $0x5,%eax
f0104f75:	75 5b                	jne    f0104fd2 <syscall+0x2a7>
	struct PageInfo *pp = page_alloc(1);
f0104f77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104f7e:	e8 06 c3 ff ff       	call   f0101289 <page_alloc>
f0104f83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (!pp) return E_NO_MEM;
f0104f86:	85 c0                	test   %eax,%eax
f0104f88:	74 52                	je     f0104fdc <syscall+0x2b1>
	pp->pp_ref++;
f0104f8a:	66 ff 40 04          	incw   0x4(%eax)
	if ((r = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
f0104f8e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104f92:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104f96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f9d:	8b 40 60             	mov    0x60(%eax),%eax
f0104fa0:	89 04 24             	mov    %eax,(%esp)
f0104fa3:	e8 1a c6 ff ff       	call   f01015c2 <page_insert>
f0104fa8:	89 c6                	mov    %eax,%esi
f0104faa:	85 c0                	test   %eax,%eax
f0104fac:	79 38                	jns    f0104fe6 <syscall+0x2bb>
		page_free(pp);
f0104fae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104fb1:	89 04 24             	mov    %eax,(%esp)
f0104fb4:	e8 54 c3 ff ff       	call   f010130d <page_free>
f0104fb9:	e9 b9 05 00 00       	jmp    f0105577 <syscall+0x84c>
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0104fbe:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104fc3:	e9 af 05 00 00       	jmp    f0105577 <syscall+0x84c>
f0104fc8:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104fcd:	e9 a5 05 00 00       	jmp    f0105577 <syscall+0x84c>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f0104fd2:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104fd7:	e9 9b 05 00 00       	jmp    f0105577 <syscall+0x84c>
	struct PageInfo *pp = page_alloc(1);
	if (!pp) return E_NO_MEM;
f0104fdc:	be 04 00 00 00       	mov    $0x4,%esi
f0104fe1:	e9 91 05 00 00       	jmp    f0105577 <syscall+0x84c>
	pp->pp_ref++;
	if ((r = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
		page_free(pp);
		return r;
	}
	return 0;
f0104fe6:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
f0104feb:	e9 87 05 00 00       	jmp    f0105577 <syscall+0x84c>

	// LAB 4: Your code here.
	int r;
	struct Env *srce, *dste;
	// catch -E_BAD_ENV
	if ((r = envid2env(srcenvid, &srce, 1)) < 0)
f0104ff0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ff7:	00 
f0104ff8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fff:	89 34 24             	mov    %esi,(%esp)
f0105002:	e8 54 e8 ff ff       	call   f010385b <envid2env>
f0105007:	89 c6                	mov    %eax,%esi
f0105009:	85 c0                	test   %eax,%eax
f010500b:	0f 88 66 05 00 00    	js     f0105577 <syscall+0x84c>
		return r;
	if ((r = envid2env(dstenvid, &dste, 1)) < 0)
f0105011:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105018:	00 
f0105019:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010501c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105020:	89 1c 24             	mov    %ebx,(%esp)
f0105023:	e8 33 e8 ff ff       	call   f010385b <envid2env>
f0105028:	89 c6                	mov    %eax,%esi
f010502a:	85 c0                	test   %eax,%eax
f010502c:	0f 88 45 05 00 00    	js     f0105577 <syscall+0x84c>
		return r;
	if ((uintptr_t)srcva>=UTOP || ROUNDUP(srcva, PGSIZE) != srcva ||
f0105032:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105038:	0f 87 8f 00 00 00    	ja     f01050cd <syscall+0x3a2>
f010503e:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f0105044:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105049:	39 c7                	cmp    %eax,%edi
f010504b:	0f 85 86 00 00 00    	jne    f01050d7 <syscall+0x3ac>
f0105051:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105058:	0f 87 83 00 00 00    	ja     f01050e1 <syscall+0x3b6>
		(uintptr_t)dstva>=UTOP || ROUNDUP(dstva, PGSIZE) != dstva)
f010505e:	8b 45 18             	mov    0x18(%ebp),%eax
f0105061:	05 ff 0f 00 00       	add    $0xfff,%eax
f0105066:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010506b:	39 45 18             	cmp    %eax,0x18(%ebp)
f010506e:	75 7b                	jne    f01050eb <syscall+0x3c0>
		return -E_INVAL;
	pte_t *ppte;
	struct PageInfo *pp = page_lookup(srce->env_pgdir, srcva, &ppte);
f0105070:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105073:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105077:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010507b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010507e:	8b 40 60             	mov    0x60(%eax),%eax
f0105081:	89 04 24             	mov    %eax,(%esp)
f0105084:	e8 27 c4 ff ff       	call   f01014b0 <page_lookup>
	if (!pp) return -E_INVAL;
f0105089:	85 c0                	test   %eax,%eax
f010508b:	74 68                	je     f01050f5 <syscall+0x3ca>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f010508d:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105090:	83 e2 05             	and    $0x5,%edx
f0105093:	83 fa 05             	cmp    $0x5,%edx
f0105096:	75 67                	jne    f01050ff <syscall+0x3d4>
	if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f0105098:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010509c:	74 08                	je     f01050a6 <syscall+0x37b>
f010509e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01050a1:	f6 02 02             	testb  $0x2,(%edx)
f01050a4:	74 63                	je     f0105109 <syscall+0x3de>
	// catch -E_NO_MEM
	return page_insert(dste->env_pgdir, pp, dstva, perm);
f01050a6:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01050a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01050ad:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01050b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01050b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050bb:	8b 40 60             	mov    0x60(%eax),%eax
f01050be:	89 04 24             	mov    %eax,(%esp)
f01050c1:	e8 fc c4 ff ff       	call   f01015c2 <page_insert>
f01050c6:	89 c6                	mov    %eax,%esi
f01050c8:	e9 aa 04 00 00       	jmp    f0105577 <syscall+0x84c>
		return r;
	if ((r = envid2env(dstenvid, &dste, 1)) < 0)
		return r;
	if ((uintptr_t)srcva>=UTOP || ROUNDUP(srcva, PGSIZE) != srcva ||
		(uintptr_t)dstva>=UTOP || ROUNDUP(dstva, PGSIZE) != dstva)
		return -E_INVAL;
f01050cd:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050d2:	e9 a0 04 00 00       	jmp    f0105577 <syscall+0x84c>
f01050d7:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050dc:	e9 96 04 00 00       	jmp    f0105577 <syscall+0x84c>
f01050e1:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050e6:	e9 8c 04 00 00       	jmp    f0105577 <syscall+0x84c>
f01050eb:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050f0:	e9 82 04 00 00       	jmp    f0105577 <syscall+0x84c>
	pte_t *ppte;
	struct PageInfo *pp = page_lookup(srce->env_pgdir, srcva, &ppte);
	if (!pp) return -E_INVAL;
f01050f5:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050fa:	e9 78 04 00 00       	jmp    f0105577 <syscall+0x84c>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) return -E_INVAL;
f01050ff:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105104:	e9 6e 04 00 00       	jmp    f0105577 <syscall+0x84c>
	if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f0105109:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f010510e:	e9 64 04 00 00       	jmp    f0105577 <syscall+0x84c>

	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 0)) < 0)
f0105113:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010511a:	00 
f010511b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010511e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105122:	89 34 24             	mov    %esi,(%esp)
f0105125:	e8 31 e7 ff ff       	call   f010385b <envid2env>
f010512a:	89 c6                	mov    %eax,%esi
f010512c:	85 c0                	test   %eax,%eax
f010512e:	0f 88 43 04 00 00    	js     f0105577 <syscall+0x84c>
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0105134:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f010513a:	77 2b                	ja     f0105167 <syscall+0x43c>
f010513c:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f0105142:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105147:	39 c7                	cmp    %eax,%edi
f0105149:	75 26                	jne    f0105171 <syscall+0x446>
	page_remove(e->env_pgdir, va);
f010514b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010514f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105152:	8b 40 60             	mov    0x60(%eax),%eax
f0105155:	89 04 24             	mov    %eax,(%esp)
f0105158:	e8 14 c4 ff ff       	call   f0101571 <page_remove>
	return 0;
f010515d:	be 00 00 00 00       	mov    $0x0,%esi
f0105162:	e9 10 04 00 00       	jmp    f0105577 <syscall+0x84c>
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 0)) < 0)
		return r;
	if ((uintptr_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va) return -E_INVAL;
f0105167:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010516c:	e9 06 04 00 00       	jmp    f0105577 <syscall+0x84c>
f0105171:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
f0105176:	e9 fc 03 00 00       	jmp    f0105577 <syscall+0x84c>
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 1)) < 0)
f010517b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105182:	00 
f0105183:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105186:	89 44 24 04          	mov    %eax,0x4(%esp)
f010518a:	89 34 24             	mov    %esi,(%esp)
f010518d:	e8 c9 e6 ff ff       	call   f010385b <envid2env>
f0105192:	89 c6                	mov    %eax,%esi
f0105194:	85 c0                	test   %eax,%eax
f0105196:	0f 88 db 03 00 00    	js     f0105577 <syscall+0x84c>
		return r;
	e->env_pgfault_upcall = func;
f010519c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010519f:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f01051a2:	be 00 00 00 00       	mov    $0x0,%esi
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
f01051a7:	e9 cb 03 00 00       	jmp    f0105577 <syscall+0x84c>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && ROUNDUP(dstva, PGSIZE) != dstva)
f01051ac:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01051b2:	77 13                	ja     f01051c7 <syscall+0x49c>
f01051b4:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f01051ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01051bf:	39 c6                	cmp    %eax,%esi
f01051c1:	0f 85 55 01 00 00    	jne    f010531c <syscall+0x5f1>
		return -E_INVAL;
	curenv->env_ipc_recving = 1;
f01051c7:	e8 a8 15 00 00       	call   f0106774 <cpunum>
f01051cc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01051d3:	29 c2                	sub    %eax,%edx
f01051d5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01051d8:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01051df:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f01051e3:	e8 8c 15 00 00       	call   f0106774 <cpunum>
f01051e8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01051ef:	29 c2                	sub    %eax,%edx
f01051f1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01051f4:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01051fb:	89 70 6c             	mov    %esi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01051fe:	e8 71 15 00 00       	call   f0106774 <cpunum>
f0105203:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010520a:	29 c2                	sub    %eax,%edx
f010520c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010520f:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0105216:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	// If waiting queue is not empty, wake up one
	if (curenv->env_ipc_waiting_head != curenv->env_ipc_waiting_tail) {
f010521d:	e8 52 15 00 00       	call   f0106774 <cpunum>
f0105222:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105229:	29 c2                	sub    %eax,%edx
f010522b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010522e:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0105235:	8b 70 7c             	mov    0x7c(%eax),%esi
f0105238:	e8 37 15 00 00       	call   f0106774 <cpunum>
f010523d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105244:	29 c2                	sub    %eax,%edx
f0105246:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105249:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f0105250:	3b b0 80 00 00 00    	cmp    0x80(%eax),%esi
f0105256:	0f 84 bb 00 00 00    	je     f0105317 <syscall+0x5ec>
		int r;
		struct Env *e;
		envid_t envid = curenv->env_ipc_waiting[curenv->env_ipc_waiting_head];
f010525c:	e8 13 15 00 00       	call   f0106774 <cpunum>
f0105261:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105268:	29 c2                	sub    %eax,%edx
f010526a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010526d:	8b 34 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%esi
f0105274:	e8 fb 14 00 00       	call   f0106774 <cpunum>
f0105279:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105280:	29 c2                	sub    %eax,%edx
f0105282:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105285:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010528c:	8b 40 7c             	mov    0x7c(%eax),%eax
f010528f:	8b 9c 86 84 00 00 00 	mov    0x84(%esi,%eax,4),%ebx
		curenv->env_ipc_waiting_head = (curenv->env_ipc_waiting_head + 1) % MAXIPCWAITING;
f0105296:	e8 d9 14 00 00       	call   f0106774 <cpunum>
f010529b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01052a2:	29 c2                	sub    %eax,%edx
f01052a4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052a7:	8b 34 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%esi
f01052ae:	e8 c1 14 00 00       	call   f0106774 <cpunum>
f01052b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01052ba:	29 c2                	sub    %eax,%edx
f01052bc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052bf:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01052c6:	8b 40 7c             	mov    0x7c(%eax),%eax
f01052c9:	40                   	inc    %eax
f01052ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01052cf:	ba 00 00 00 00       	mov    $0x0,%edx
f01052d4:	f7 f1                	div    %ecx
f01052d6:	89 56 7c             	mov    %edx,0x7c(%esi)
		if ((r = envid2env(envid, &e, 0)) < 0)
f01052d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01052e0:	00 
f01052e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01052e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052e8:	89 1c 24             	mov    %ebx,(%esp)
f01052eb:	e8 6b e5 ff ff       	call   f010385b <envid2env>
f01052f0:	89 c6                	mov    %eax,%esi
f01052f2:	85 c0                	test   %eax,%eax
f01052f4:	0f 88 7d 02 00 00    	js     f0105577 <syscall+0x84c>
			return r;
		e->env_status = ENV_RUNNABLE;
f01052fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052fd:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		cprintf("Wake up env %x.\n", e->env_id);
f0105304:	8b 40 48             	mov    0x48(%eax),%eax
f0105307:	89 44 24 04          	mov    %eax,0x4(%esp)
f010530b:	c7 04 24 fe 87 10 f0 	movl   $0xf01087fe,(%esp)
f0105312:	e8 db ee ff ff       	call   f01041f2 <cprintf>
	}
	sys_yield();
f0105317:	e8 04 fa ff ff       	call   f0104d20 <sys_yield>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && ROUNDUP(dstva, PGSIZE) != dstva)
		return -E_INVAL;
f010531c:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
f0105321:	e9 51 02 00 00       	jmp    f0105577 <syscall+0x84c>
{
	// LAB 4: Your code here.
	int r;
	struct Env *e;
	// catch -E_BAD_ENV
	if ((r = envid2env(envid, &e, 0)) < 0)
f0105326:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010532d:	00 
f010532e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105331:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105335:	89 34 24             	mov    %esi,(%esp)
f0105338:	e8 1e e5 ff ff       	call   f010385b <envid2env>
f010533d:	89 c6                	mov    %eax,%esi
f010533f:	85 c0                	test   %eax,%eax
f0105341:	0f 88 30 02 00 00    	js     f0105577 <syscall+0x84c>
		return r;
	if (!e->env_ipc_recving) {
f0105347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010534a:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010534e:	0f 85 07 01 00 00    	jne    f010545b <syscall+0x730>
		// If waiting queue is not full
		cprintf("env %x is busy: ", e->env_id);
f0105354:	8b 40 48             	mov    0x48(%eax),%eax
f0105357:	89 44 24 04          	mov    %eax,0x4(%esp)
f010535b:	c7 04 24 0f 88 10 f0 	movl   $0xf010880f,(%esp)
f0105362:	e8 8b ee ff ff       	call   f01041f2 <cprintf>
		if ((e->env_ipc_waiting_tail + 1) % MAXIPCWAITING != e->env_ipc_waiting_head) {
f0105367:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010536a:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
f0105370:	40                   	inc    %eax
f0105371:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105376:	ba 00 00 00 00       	mov    $0x0,%edx
f010537b:	f7 f3                	div    %ebx
f010537d:	3b 51 7c             	cmp    0x7c(%ecx),%edx
f0105380:	74 75                	je     f01053f7 <syscall+0x6cc>
			// Block the sender
			cprintf("env %x is put in waiting queue.\n", curenv->env_id);
f0105382:	e8 ed 13 00 00       	call   f0106774 <cpunum>
f0105387:	6b c0 74             	imul   $0x74,%eax,%eax
f010538a:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f0105390:	8b 40 48             	mov    0x48(%eax),%eax
f0105393:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105397:	c7 04 24 4c 88 10 f0 	movl   $0xf010884c,(%esp)
f010539e:	e8 4f ee ff ff       	call   f01041f2 <cprintf>
			curenv->env_status = ENV_NOT_RUNNABLE;
f01053a3:	e8 cc 13 00 00       	call   f0106774 <cpunum>
f01053a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01053ab:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f01053b1:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
			e->env_ipc_waiting[e->env_ipc_waiting_tail] = curenv->env_id;
f01053b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01053bb:	8b b3 80 00 00 00    	mov    0x80(%ebx),%esi
f01053c1:	e8 ae 13 00 00       	call   f0106774 <cpunum>
f01053c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01053c9:	8b 80 28 30 33 f0    	mov    -0xfcccfd8(%eax),%eax
f01053cf:	8b 40 48             	mov    0x48(%eax),%eax
f01053d2:	89 84 b3 84 00 00 00 	mov    %eax,0x84(%ebx,%esi,4)
			e->env_ipc_waiting_tail = (e->env_ipc_waiting_tail + 1) % MAXIPCWAITING;
f01053d9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01053dc:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
f01053e2:	40                   	inc    %eax
f01053e3:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01053e8:	ba 00 00 00 00       	mov    $0x0,%edx
f01053ed:	f7 f3                	div    %ebx
f01053ef:	89 91 80 00 00 00    	mov    %edx,0x80(%ecx)
f01053f5:	eb 0c                	jmp    f0105403 <syscall+0x6d8>
		}
		else
			cprintf("waiting queue is full.\n");
f01053f7:	c7 04 24 20 88 10 f0 	movl   $0xf0108820,(%esp)
f01053fe:	e8 ef ed ff ff       	call   f01041f2 <cprintf>
		cprintf("Waiting envs: ");
f0105403:	c7 04 24 38 88 10 f0 	movl   $0xf0108838,(%esp)
f010540a:	e8 e3 ed ff ff       	call   f01041f2 <cprintf>
		int i;
		for (i = 0; i < MAXIPCWAITING; i++)
f010540f:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf("%x ", e->env_ipc_waiting[(i + e->env_ipc_waiting_head) % MAXIPCWAITING]);
f0105414:	be 0a 00 00 00       	mov    $0xa,%esi
f0105419:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010541c:	89 d8                	mov    %ebx,%eax
f010541e:	03 41 7c             	add    0x7c(%ecx),%eax
f0105421:	ba 00 00 00 00       	mov    $0x0,%edx
f0105426:	f7 f6                	div    %esi
f0105428:	8b 84 91 84 00 00 00 	mov    0x84(%ecx,%edx,4),%eax
f010542f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105433:	c7 04 24 47 88 10 f0 	movl   $0xf0108847,(%esp)
f010543a:	e8 b3 ed ff ff       	call   f01041f2 <cprintf>
		}
		else
			cprintf("waiting queue is full.\n");
		cprintf("Waiting envs: ");
		int i;
		for (i = 0; i < MAXIPCWAITING; i++)
f010543f:	43                   	inc    %ebx
f0105440:	83 fb 0a             	cmp    $0xa,%ebx
f0105443:	75 d4                	jne    f0105419 <syscall+0x6ee>
			cprintf("%x ", e->env_ipc_waiting[(i + e->env_ipc_waiting_head) % MAXIPCWAITING]);
		cprintf("\n");
f0105445:	c7 04 24 b5 82 10 f0 	movl   $0xf01082b5,(%esp)
f010544c:	e8 a1 ed ff ff       	call   f01041f2 <cprintf>
		return -E_IPC_NOT_RECV;
f0105451:	be f8 ff ff ff       	mov    $0xfffffff8,%esi
f0105456:	e9 1c 01 00 00       	jmp    f0105577 <syscall+0x84c>
	}
	if ((uintptr_t)srcva < UTOP) {
f010545b:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105461:	0f 87 a1 00 00 00    	ja     f0105508 <syscall+0x7dd>
		if (ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f0105467:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f010546d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105472:	39 c3                	cmp    %eax,%ebx
f0105474:	0f 85 d5 00 00 00    	jne    f010554f <syscall+0x824>
		pte_t *ppte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &ppte);
f010547a:	e8 f5 12 00 00       	call   f0106774 <cpunum>
f010547f:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105482:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105486:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010548a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105491:	29 c2                	sub    %eax,%edx
f0105493:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105496:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010549d:	8b 40 60             	mov    0x60(%eax),%eax
f01054a0:	89 04 24             	mov    %eax,(%esp)
f01054a3:	e8 08 c0 ff ff       	call   f01014b0 <page_lookup>
		//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
		//		address space.
		if (!pp) return -E_INVAL;
f01054a8:	85 c0                	test   %eax,%eax
f01054aa:	0f 84 a6 00 00 00    	je     f0105556 <syscall+0x82b>
		//	-E_INVAL if srcva < UTOP and perm is inappropriate
		if ((perm & *ppte) != perm) return -E_INVAL;
f01054b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01054b3:	8b 12                	mov    (%edx),%edx
f01054b5:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01054b8:	21 d1                	and    %edx,%ecx
f01054ba:	39 4d 18             	cmp    %ecx,0x18(%ebp)
f01054bd:	0f 85 9a 00 00 00    	jne    f010555d <syscall+0x832>
		//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
		//		current environment's address space.
		if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f01054c3:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01054c7:	74 09                	je     f01054d2 <syscall+0x7a7>
f01054c9:	f6 c2 02             	test   $0x2,%dl
f01054cc:	0f 84 92 00 00 00    	je     f0105564 <syscall+0x839>
		if ((uintptr_t)e->env_ipc_dstva < UTOP) {
f01054d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01054d5:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f01054d8:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f01054de:	77 2f                	ja     f010550f <syscall+0x7e4>
			if ((r = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0)
f01054e0:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01054e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01054e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01054eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054ef:	8b 42 60             	mov    0x60(%edx),%eax
f01054f2:	89 04 24             	mov    %eax,(%esp)
f01054f5:	e8 c8 c0 ff ff       	call   f01015c2 <page_insert>
f01054fa:	89 c6                	mov    %eax,%esi
f01054fc:	85 c0                	test   %eax,%eax
f01054fe:	78 77                	js     f0105577 <syscall+0x84c>
				return r;
			e->env_ipc_perm = perm;
f0105500:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105503:	89 58 78             	mov    %ebx,0x78(%eax)
f0105506:	eb 07                	jmp    f010550f <syscall+0x7e4>
		}
	}
	else e->env_ipc_perm = 0;
f0105508:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	e->env_ipc_recving = 0;
f010550f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105512:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	e->env_ipc_from = curenv->env_id;
f0105516:	e8 59 12 00 00       	call   f0106774 <cpunum>
f010551b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105522:	29 c2                	sub    %eax,%edx
f0105524:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105527:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010552e:	8b 40 48             	mov    0x48(%eax),%eax
f0105531:	89 46 74             	mov    %eax,0x74(%esi)
	e->env_ipc_value = value;
f0105534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105537:	89 78 70             	mov    %edi,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f010553a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0105541:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0105548:	be 00 00 00 00       	mov    $0x0,%esi
f010554d:	eb 28                	jmp    f0105577 <syscall+0x84c>
			cprintf("%x ", e->env_ipc_waiting[(i + e->env_ipc_waiting_head) % MAXIPCWAITING]);
		cprintf("\n");
		return -E_IPC_NOT_RECV;
	}
	if ((uintptr_t)srcva < UTOP) {
		if (ROUNDUP(srcva, PGSIZE) != srcva) return -E_INVAL;
f010554f:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105554:	eb 21                	jmp    f0105577 <syscall+0x84c>
		pte_t *ppte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &ppte);
		//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
		//		address space.
		if (!pp) return -E_INVAL;
f0105556:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010555b:	eb 1a                	jmp    f0105577 <syscall+0x84c>
		//	-E_INVAL if srcva < UTOP and perm is inappropriate
		if ((perm & *ppte) != perm) return -E_INVAL;
f010555d:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105562:	eb 13                	jmp    f0105577 <syscall+0x84c>
		//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
		//		current environment's address space.
		if ((perm & PTE_W) && !(*ppte & PTE_W)) return -E_INVAL;
f0105564:	be fd ff ff ff       	mov    $0xfffffffd,%esi
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0105569:	eb 0c                	jmp    f0105577 <syscall+0x84c>
	default:
		// should I change it into -E_INVAL?
		return -E_NO_SYS;
f010556b:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f0105570:	eb 05                	jmp    f0105577 <syscall+0x84c>
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		sys_env_destroy(a1);
		return 0;
f0105572:	be 00 00 00 00       	mov    $0x0,%esi
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
	default:
		// should I change it into -E_INVAL?
		return -E_NO_SYS;
	}
}
f0105577:	89 f0                	mov    %esi,%eax
f0105579:	83 c4 3c             	add    $0x3c,%esp
f010557c:	5b                   	pop    %ebx
f010557d:	5e                   	pop    %esi
f010557e:	5f                   	pop    %edi
f010557f:	5d                   	pop    %ebp
f0105580:	c3                   	ret    
f0105581:	00 00                	add    %al,(%eax)
	...

f0105584 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105584:	55                   	push   %ebp
f0105585:	89 e5                	mov    %esp,%ebp
f0105587:	57                   	push   %edi
f0105588:	56                   	push   %esi
f0105589:	53                   	push   %ebx
f010558a:	83 ec 14             	sub    $0x14,%esp
f010558d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105590:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105593:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105596:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105599:	8b 1a                	mov    (%edx),%ebx
f010559b:	8b 01                	mov    (%ecx),%eax
f010559d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01055a0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f01055a7:	e9 83 00 00 00       	jmp    f010562f <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f01055ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01055af:	01 d8                	add    %ebx,%eax
f01055b1:	89 c7                	mov    %eax,%edi
f01055b3:	c1 ef 1f             	shr    $0x1f,%edi
f01055b6:	01 c7                	add    %eax,%edi
f01055b8:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01055ba:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01055bd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01055c0:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01055c4:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01055c6:	eb 01                	jmp    f01055c9 <stab_binsearch+0x45>
			m--;
f01055c8:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01055c9:	39 c3                	cmp    %eax,%ebx
f01055cb:	7f 1e                	jg     f01055eb <stab_binsearch+0x67>
f01055cd:	0f b6 0a             	movzbl (%edx),%ecx
f01055d0:	83 ea 0c             	sub    $0xc,%edx
f01055d3:	39 f1                	cmp    %esi,%ecx
f01055d5:	75 f1                	jne    f01055c8 <stab_binsearch+0x44>
f01055d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01055da:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01055dd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01055e0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01055e4:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01055e7:	76 18                	jbe    f0105601 <stab_binsearch+0x7d>
f01055e9:	eb 05                	jmp    f01055f0 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01055eb:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01055ee:	eb 3f                	jmp    f010562f <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01055f0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01055f3:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01055f5:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01055f8:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01055ff:	eb 2e                	jmp    f010562f <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105601:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105604:	73 15                	jae    f010561b <stab_binsearch+0x97>
			*region_right = m - 1;
f0105606:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105609:	49                   	dec    %ecx
f010560a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010560d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105610:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105612:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105619:	eb 14                	jmp    f010562f <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010561b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010561e:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105621:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f0105623:	ff 45 0c             	incl   0xc(%ebp)
f0105626:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105628:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010562f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105632:	0f 8e 74 ff ff ff    	jle    f01055ac <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105638:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010563c:	75 0d                	jne    f010564b <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010563e:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105641:	8b 02                	mov    (%edx),%eax
f0105643:	48                   	dec    %eax
f0105644:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105647:	89 01                	mov    %eax,(%ecx)
f0105649:	eb 2a                	jmp    f0105675 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010564b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010564e:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105650:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105653:	8b 0a                	mov    (%edx),%ecx
f0105655:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105658:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010565b:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010565f:	eb 01                	jmp    f0105662 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105661:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105662:	39 c8                	cmp    %ecx,%eax
f0105664:	7e 0a                	jle    f0105670 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f0105666:	0f b6 1a             	movzbl (%edx),%ebx
f0105669:	83 ea 0c             	sub    $0xc,%edx
f010566c:	39 f3                	cmp    %esi,%ebx
f010566e:	75 f1                	jne    f0105661 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105670:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105673:	89 02                	mov    %eax,(%edx)
	}
}
f0105675:	83 c4 14             	add    $0x14,%esp
f0105678:	5b                   	pop    %ebx
f0105679:	5e                   	pop    %esi
f010567a:	5f                   	pop    %edi
f010567b:	5d                   	pop    %ebp
f010567c:	c3                   	ret    

f010567d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010567d:	55                   	push   %ebp
f010567e:	89 e5                	mov    %esp,%ebp
f0105680:	57                   	push   %edi
f0105681:	56                   	push   %esi
f0105682:	53                   	push   %ebx
f0105683:	83 ec 5c             	sub    $0x5c,%esp
f0105686:	8b 75 08             	mov    0x8(%ebp),%esi
f0105689:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010568c:	c7 03 a4 88 10 f0    	movl   $0xf01088a4,(%ebx)
	info->eip_line = 0;
f0105692:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105699:	c7 43 08 a4 88 10 f0 	movl   $0xf01088a4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01056a0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01056a7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01056aa:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01056b1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01056b7:	0f 87 e1 00 00 00    	ja     f010579e <debuginfo_eip+0x121>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01056bd:	e8 b2 10 00 00       	call   f0106774 <cpunum>
f01056c2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01056c9:	00 
f01056ca:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01056d1:	00 
f01056d2:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01056d9:	00 
f01056da:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01056e1:	29 c2                	sub    %eax,%edx
f01056e3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01056e6:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f01056ed:	89 04 24             	mov    %eax,(%esp)
f01056f0:	e8 06 e0 ff ff       	call   f01036fb <user_mem_check>
f01056f5:	85 c0                	test   %eax,%eax
f01056f7:	0f 85 5d 02 00 00    	jne    f010595a <debuginfo_eip+0x2dd>
			return -1;

		stabs = usd->stabs;
f01056fd:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0105703:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105706:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f010570c:	a1 08 00 20 00       	mov    0x200008,%eax
f0105711:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105714:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010571a:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010571d:	e8 52 10 00 00       	call   f0106774 <cpunum>
f0105722:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105729:	00 
f010572a:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0105731:	00 
f0105732:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105735:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105739:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105740:	29 c2                	sub    %eax,%edx
f0105742:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105745:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010574c:	89 04 24             	mov    %eax,(%esp)
f010574f:	e8 a7 df ff ff       	call   f01036fb <user_mem_check>
f0105754:	85 c0                	test   %eax,%eax
f0105756:	0f 85 05 02 00 00    	jne    f0105961 <debuginfo_eip+0x2e4>
			return -1;
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f010575c:	e8 13 10 00 00       	call   f0106774 <cpunum>
f0105761:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105768:	00 
f0105769:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010576c:	2b 55 bc             	sub    -0x44(%ebp),%edx
f010576f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105773:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105776:	89 54 24 04          	mov    %edx,0x4(%esp)
f010577a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105781:	29 c2                	sub    %eax,%edx
f0105783:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105786:	8b 04 85 28 30 33 f0 	mov    -0xfcccfd8(,%eax,4),%eax
f010578d:	89 04 24             	mov    %eax,(%esp)
f0105790:	e8 66 df ff ff       	call   f01036fb <user_mem_check>
f0105795:	85 c0                	test   %eax,%eax
f0105797:	74 1f                	je     f01057b8 <debuginfo_eip+0x13b>
f0105799:	e9 ca 01 00 00       	jmp    f0105968 <debuginfo_eip+0x2eb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010579e:	c7 45 c0 6c f8 11 f0 	movl   $0xf011f86c,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01057a5:	c7 45 bc a9 46 11 f0 	movl   $0xf01146a9,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01057ac:	bf a8 46 11 f0       	mov    $0xf01146a8,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01057b1:	c7 45 c4 98 8d 10 f0 	movl   $0xf0108d98,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01057b8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01057bb:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01057be:	0f 83 ab 01 00 00    	jae    f010596f <debuginfo_eip+0x2f2>
f01057c4:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01057c8:	0f 85 a8 01 00 00    	jne    f0105976 <debuginfo_eip+0x2f9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01057ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01057d5:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01057d8:	c1 ff 02             	sar    $0x2,%edi
f01057db:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f01057de:	8d 04 87             	lea    (%edi,%eax,4),%eax
f01057e1:	8d 04 87             	lea    (%edi,%eax,4),%eax
f01057e4:	89 c2                	mov    %eax,%edx
f01057e6:	c1 e2 08             	shl    $0x8,%edx
f01057e9:	01 d0                	add    %edx,%eax
f01057eb:	89 c2                	mov    %eax,%edx
f01057ed:	c1 e2 10             	shl    $0x10,%edx
f01057f0:	01 d0                	add    %edx,%eax
f01057f2:	8d 44 47 ff          	lea    -0x1(%edi,%eax,2),%eax
f01057f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01057f9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057fd:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105804:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105807:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010580a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010580d:	e8 72 fd ff ff       	call   f0105584 <stab_binsearch>
	if (lfile == 0)
f0105812:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105815:	85 c0                	test   %eax,%eax
f0105817:	0f 84 60 01 00 00    	je     f010597d <debuginfo_eip+0x300>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010581d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105820:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105823:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105826:	89 74 24 04          	mov    %esi,0x4(%esp)
f010582a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105831:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105834:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105837:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010583a:	e8 45 fd ff ff       	call   f0105584 <stab_binsearch>

	if (lfun <= rfun) {
f010583f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105842:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105845:	39 d0                	cmp    %edx,%eax
f0105847:	7f 32                	jg     f010587b <debuginfo_eip+0x1fe>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105849:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010584c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010584f:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0105852:	8b 39                	mov    (%ecx),%edi
f0105854:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105857:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010585a:	2b 7d bc             	sub    -0x44(%ebp),%edi
f010585d:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0105860:	73 09                	jae    f010586b <debuginfo_eip+0x1ee>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105862:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105865:	03 7d bc             	add    -0x44(%ebp),%edi
f0105868:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010586b:	8b 49 08             	mov    0x8(%ecx),%ecx
f010586e:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105871:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105873:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105876:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105879:	eb 0f                	jmp    f010588a <debuginfo_eip+0x20d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010587b:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010587e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105881:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105884:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105887:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010588a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105891:	00 
f0105892:	8b 43 08             	mov    0x8(%ebx),%eax
f0105895:	89 04 24             	mov    %eax,(%esp)
f0105898:	e8 91 08 00 00       	call   f010612e <strfind>
f010589d:	2b 43 08             	sub    0x8(%ebx),%eax
f01058a0:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01058a3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01058a7:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01058ae:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01058b1:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01058b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01058b7:	e8 c8 fc ff ff       	call   f0105584 <stab_binsearch>
	if (lline <= rline)
f01058bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01058bf:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01058c2:	7f 10                	jg     f01058d4 <debuginfo_eip+0x257>
		info->eip_line = stabs[rline].n_desc;
f01058c4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01058c7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01058ca:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f01058cf:	89 43 04             	mov    %eax,0x4(%ebx)
f01058d2:	eb 07                	jmp    f01058db <debuginfo_eip+0x25e>
	else
		info->eip_line = -1;
f01058d4:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01058db:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01058de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01058e1:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01058e4:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01058e7:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f01058eb:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f01058ee:	eb 04                	jmp    f01058f4 <debuginfo_eip+0x277>
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01058f0:	48                   	dec    %eax
f01058f1:	83 ea 0c             	sub    $0xc,%edx
f01058f4:	89 c7                	mov    %eax,%edi
f01058f6:	39 c6                	cmp    %eax,%esi
f01058f8:	7f 28                	jg     f0105922 <debuginfo_eip+0x2a5>
	       && stabs[lline].n_type != N_SOL
f01058fa:	8a 4a fc             	mov    -0x4(%edx),%cl
f01058fd:	80 f9 84             	cmp    $0x84,%cl
f0105900:	0f 84 92 00 00 00    	je     f0105998 <debuginfo_eip+0x31b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105906:	80 f9 64             	cmp    $0x64,%cl
f0105909:	75 e5                	jne    f01058f0 <debuginfo_eip+0x273>
f010590b:	83 3a 00             	cmpl   $0x0,(%edx)
f010590e:	74 e0                	je     f01058f0 <debuginfo_eip+0x273>
f0105910:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105913:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105916:	e9 83 00 00 00       	jmp    f010599e <debuginfo_eip+0x321>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010591b:	03 45 bc             	add    -0x44(%ebp),%eax
f010591e:	89 03                	mov    %eax,(%ebx)
f0105920:	eb 03                	jmp    f0105925 <debuginfo_eip+0x2a8>
f0105922:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105925:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105928:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010592b:	39 f2                	cmp    %esi,%edx
f010592d:	7d 55                	jge    f0105984 <debuginfo_eip+0x307>
		for (lline = lfun + 1;
f010592f:	42                   	inc    %edx
f0105930:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105933:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105935:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105938:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010593b:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010593f:	eb 03                	jmp    f0105944 <debuginfo_eip+0x2c7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105941:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105944:	39 f0                	cmp    %esi,%eax
f0105946:	7d 43                	jge    f010598b <debuginfo_eip+0x30e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105948:	8a 0a                	mov    (%edx),%cl
f010594a:	40                   	inc    %eax
f010594b:	83 c2 0c             	add    $0xc,%edx
f010594e:	80 f9 a0             	cmp    $0xa0,%cl
f0105951:	74 ee                	je     f0105941 <debuginfo_eip+0x2c4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105953:	b8 00 00 00 00       	mov    $0x0,%eax
f0105958:	eb 36                	jmp    f0105990 <debuginfo_eip+0x313>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f010595a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010595f:	eb 2f                	jmp    f0105990 <debuginfo_eip+0x313>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0105961:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105966:	eb 28                	jmp    f0105990 <debuginfo_eip+0x313>
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
f0105968:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010596d:	eb 21                	jmp    f0105990 <debuginfo_eip+0x313>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010596f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105974:	eb 1a                	jmp    f0105990 <debuginfo_eip+0x313>
f0105976:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010597b:	eb 13                	jmp    f0105990 <debuginfo_eip+0x313>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010597d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105982:	eb 0c                	jmp    f0105990 <debuginfo_eip+0x313>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105984:	b8 00 00 00 00       	mov    $0x0,%eax
f0105989:	eb 05                	jmp    f0105990 <debuginfo_eip+0x313>
f010598b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105990:	83 c4 5c             	add    $0x5c,%esp
f0105993:	5b                   	pop    %ebx
f0105994:	5e                   	pop    %esi
f0105995:	5f                   	pop    %edi
f0105996:	5d                   	pop    %ebp
f0105997:	c3                   	ret    
f0105998:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010599b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010599e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01059a1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01059a4:	8b 04 87             	mov    (%edi,%eax,4),%eax
f01059a7:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01059aa:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01059ad:	39 d0                	cmp    %edx,%eax
f01059af:	0f 82 66 ff ff ff    	jb     f010591b <debuginfo_eip+0x29e>
f01059b5:	e9 6b ff ff ff       	jmp    f0105925 <debuginfo_eip+0x2a8>
	...

f01059bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01059bc:	55                   	push   %ebp
f01059bd:	89 e5                	mov    %esp,%ebp
f01059bf:	57                   	push   %edi
f01059c0:	56                   	push   %esi
f01059c1:	53                   	push   %ebx
f01059c2:	83 ec 3c             	sub    $0x3c,%esp
f01059c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01059c8:	89 d7                	mov    %edx,%edi
f01059ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01059cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01059d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01059d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01059d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01059d9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01059dc:	85 c0                	test   %eax,%eax
f01059de:	75 08                	jne    f01059e8 <printnum+0x2c>
f01059e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059e3:	39 45 10             	cmp    %eax,0x10(%ebp)
f01059e6:	77 57                	ja     f0105a3f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01059e8:	89 74 24 10          	mov    %esi,0x10(%esp)
f01059ec:	4b                   	dec    %ebx
f01059ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01059f1:	8b 45 10             	mov    0x10(%ebp),%eax
f01059f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01059f8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01059fc:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105a00:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105a07:	00 
f0105a08:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105a0b:	89 04 24             	mov    %eax,(%esp)
f0105a0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a15:	e8 ca 11 00 00       	call   f0106be4 <__udivdi3>
f0105a1a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105a1e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105a22:	89 04 24             	mov    %eax,(%esp)
f0105a25:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a29:	89 fa                	mov    %edi,%edx
f0105a2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a2e:	e8 89 ff ff ff       	call   f01059bc <printnum>
f0105a33:	eb 0f                	jmp    f0105a44 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105a35:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a39:	89 34 24             	mov    %esi,(%esp)
f0105a3c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105a3f:	4b                   	dec    %ebx
f0105a40:	85 db                	test   %ebx,%ebx
f0105a42:	7f f1                	jg     f0105a35 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105a44:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a48:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105a4c:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a4f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a53:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105a5a:	00 
f0105a5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105a5e:	89 04 24             	mov    %eax,(%esp)
f0105a61:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a68:	e8 97 12 00 00       	call   f0106d04 <__umoddi3>
f0105a6d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a71:	0f be 80 ae 88 10 f0 	movsbl -0xfef7752(%eax),%eax
f0105a78:	89 04 24             	mov    %eax,(%esp)
f0105a7b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105a7e:	83 c4 3c             	add    $0x3c,%esp
f0105a81:	5b                   	pop    %ebx
f0105a82:	5e                   	pop    %esi
f0105a83:	5f                   	pop    %edi
f0105a84:	5d                   	pop    %ebp
f0105a85:	c3                   	ret    

f0105a86 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105a86:	55                   	push   %ebp
f0105a87:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105a89:	83 fa 01             	cmp    $0x1,%edx
f0105a8c:	7e 0e                	jle    f0105a9c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105a8e:	8b 10                	mov    (%eax),%edx
f0105a90:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105a93:	89 08                	mov    %ecx,(%eax)
f0105a95:	8b 02                	mov    (%edx),%eax
f0105a97:	8b 52 04             	mov    0x4(%edx),%edx
f0105a9a:	eb 22                	jmp    f0105abe <getuint+0x38>
	else if (lflag)
f0105a9c:	85 d2                	test   %edx,%edx
f0105a9e:	74 10                	je     f0105ab0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105aa0:	8b 10                	mov    (%eax),%edx
f0105aa2:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105aa5:	89 08                	mov    %ecx,(%eax)
f0105aa7:	8b 02                	mov    (%edx),%eax
f0105aa9:	ba 00 00 00 00       	mov    $0x0,%edx
f0105aae:	eb 0e                	jmp    f0105abe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105ab0:	8b 10                	mov    (%eax),%edx
f0105ab2:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105ab5:	89 08                	mov    %ecx,(%eax)
f0105ab7:	8b 02                	mov    (%edx),%eax
f0105ab9:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105abe:	5d                   	pop    %ebp
f0105abf:	c3                   	ret    

f0105ac0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0105ac0:	55                   	push   %ebp
f0105ac1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105ac3:	83 fa 01             	cmp    $0x1,%edx
f0105ac6:	7e 0e                	jle    f0105ad6 <getint+0x16>
		return va_arg(*ap, long long);
f0105ac8:	8b 10                	mov    (%eax),%edx
f0105aca:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105acd:	89 08                	mov    %ecx,(%eax)
f0105acf:	8b 02                	mov    (%edx),%eax
f0105ad1:	8b 52 04             	mov    0x4(%edx),%edx
f0105ad4:	eb 1a                	jmp    f0105af0 <getint+0x30>
	else if (lflag)
f0105ad6:	85 d2                	test   %edx,%edx
f0105ad8:	74 0c                	je     f0105ae6 <getint+0x26>
		return va_arg(*ap, long);
f0105ada:	8b 10                	mov    (%eax),%edx
f0105adc:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105adf:	89 08                	mov    %ecx,(%eax)
f0105ae1:	8b 02                	mov    (%edx),%eax
f0105ae3:	99                   	cltd   
f0105ae4:	eb 0a                	jmp    f0105af0 <getint+0x30>
	else
		return va_arg(*ap, int);
f0105ae6:	8b 10                	mov    (%eax),%edx
f0105ae8:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105aeb:	89 08                	mov    %ecx,(%eax)
f0105aed:	8b 02                	mov    (%edx),%eax
f0105aef:	99                   	cltd   
}
f0105af0:	5d                   	pop    %ebp
f0105af1:	c3                   	ret    

f0105af2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105af2:	55                   	push   %ebp
f0105af3:	89 e5                	mov    %esp,%ebp
f0105af5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105af8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105afb:	8b 10                	mov    (%eax),%edx
f0105afd:	3b 50 04             	cmp    0x4(%eax),%edx
f0105b00:	73 08                	jae    f0105b0a <sprintputch+0x18>
		*b->buf++ = ch;
f0105b02:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b05:	88 0a                	mov    %cl,(%edx)
f0105b07:	42                   	inc    %edx
f0105b08:	89 10                	mov    %edx,(%eax)
}
f0105b0a:	5d                   	pop    %ebp
f0105b0b:	c3                   	ret    

f0105b0c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105b0c:	55                   	push   %ebp
f0105b0d:	89 e5                	mov    %esp,%ebp
f0105b0f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105b12:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105b15:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b19:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b1c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b20:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b23:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b27:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b2a:	89 04 24             	mov    %eax,(%esp)
f0105b2d:	e8 02 00 00 00       	call   f0105b34 <vprintfmt>
	va_end(ap);
}
f0105b32:	c9                   	leave  
f0105b33:	c3                   	ret    

f0105b34 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105b34:	55                   	push   %ebp
f0105b35:	89 e5                	mov    %esp,%ebp
f0105b37:	57                   	push   %edi
f0105b38:	56                   	push   %esi
f0105b39:	53                   	push   %ebx
f0105b3a:	83 ec 4c             	sub    $0x4c,%esp
f0105b3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105b40:	8b 75 10             	mov    0x10(%ebp),%esi
f0105b43:	eb 12                	jmp    f0105b57 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105b45:	85 c0                	test   %eax,%eax
f0105b47:	0f 84 40 03 00 00    	je     f0105e8d <vprintfmt+0x359>
				return;
			putch(ch, putdat);
f0105b4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b51:	89 04 24             	mov    %eax,(%esp)
f0105b54:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105b57:	0f b6 06             	movzbl (%esi),%eax
f0105b5a:	46                   	inc    %esi
f0105b5b:	83 f8 25             	cmp    $0x25,%eax
f0105b5e:	75 e5                	jne    f0105b45 <vprintfmt+0x11>
f0105b60:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105b64:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105b6b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105b70:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105b77:	ba 00 00 00 00       	mov    $0x0,%edx
f0105b7c:	eb 26                	jmp    f0105ba4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b7e:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105b81:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105b85:	eb 1d                	jmp    f0105ba4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b87:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105b8a:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105b8e:	eb 14                	jmp    f0105ba4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b90:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105b93:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105b9a:	eb 08                	jmp    f0105ba4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105b9c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105b9f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ba4:	0f b6 06             	movzbl (%esi),%eax
f0105ba7:	8d 4e 01             	lea    0x1(%esi),%ecx
f0105baa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105bad:	8a 0e                	mov    (%esi),%cl
f0105baf:	83 e9 23             	sub    $0x23,%ecx
f0105bb2:	80 f9 55             	cmp    $0x55,%cl
f0105bb5:	0f 87 b6 02 00 00    	ja     f0105e71 <vprintfmt+0x33d>
f0105bbb:	0f b6 c9             	movzbl %cl,%ecx
f0105bbe:	ff 24 8d 80 89 10 f0 	jmp    *-0xfef7680(,%ecx,4)
f0105bc5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105bc8:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105bcd:	8d 0c bf             	lea    (%edi,%edi,4),%ecx
f0105bd0:	8d 7c 48 d0          	lea    -0x30(%eax,%ecx,2),%edi
				ch = *fmt;
f0105bd4:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105bd7:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0105bda:	83 f9 09             	cmp    $0x9,%ecx
f0105bdd:	77 2a                	ja     f0105c09 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105bdf:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105be0:	eb eb                	jmp    f0105bcd <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105be2:	8b 45 14             	mov    0x14(%ebp),%eax
f0105be5:	8d 48 04             	lea    0x4(%eax),%ecx
f0105be8:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105beb:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105bed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105bf0:	eb 17                	jmp    f0105c09 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0105bf2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105bf6:	78 98                	js     f0105b90 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105bf8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105bfb:	eb a7                	jmp    f0105ba4 <vprintfmt+0x70>
f0105bfd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105c00:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105c07:	eb 9b                	jmp    f0105ba4 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105c09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105c0d:	79 95                	jns    f0105ba4 <vprintfmt+0x70>
f0105c0f:	eb 8b                	jmp    f0105b9c <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105c11:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c12:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105c15:	eb 8d                	jmp    f0105ba4 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105c17:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c1a:	8d 50 04             	lea    0x4(%eax),%edx
f0105c1d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c24:	8b 00                	mov    (%eax),%eax
f0105c26:	89 04 24             	mov    %eax,(%esp)
f0105c29:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c2c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105c2f:	e9 23 ff ff ff       	jmp    f0105b57 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105c34:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c37:	8d 50 04             	lea    0x4(%eax),%edx
f0105c3a:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c3d:	8b 00                	mov    (%eax),%eax
f0105c3f:	85 c0                	test   %eax,%eax
f0105c41:	79 02                	jns    f0105c45 <vprintfmt+0x111>
f0105c43:	f7 d8                	neg    %eax
f0105c45:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105c47:	83 f8 09             	cmp    $0x9,%eax
f0105c4a:	7f 0b                	jg     f0105c57 <vprintfmt+0x123>
f0105c4c:	8b 04 85 e0 8a 10 f0 	mov    -0xfef7520(,%eax,4),%eax
f0105c53:	85 c0                	test   %eax,%eax
f0105c55:	75 23                	jne    f0105c7a <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0105c57:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105c5b:	c7 44 24 08 c6 88 10 	movl   $0xf01088c6,0x8(%esp)
f0105c62:	f0 
f0105c63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c67:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c6a:	89 04 24             	mov    %eax,(%esp)
f0105c6d:	e8 9a fe ff ff       	call   f0105b0c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c72:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105c75:	e9 dd fe ff ff       	jmp    f0105b57 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105c7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c7e:	c7 44 24 08 0d 80 10 	movl   $0xf010800d,0x8(%esp)
f0105c85:	f0 
f0105c86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c8a:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c8d:	89 14 24             	mov    %edx,(%esp)
f0105c90:	e8 77 fe ff ff       	call   f0105b0c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c95:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105c98:	e9 ba fe ff ff       	jmp    f0105b57 <vprintfmt+0x23>
f0105c9d:	89 f9                	mov    %edi,%ecx
f0105c9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ca2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105ca5:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ca8:	8d 50 04             	lea    0x4(%eax),%edx
f0105cab:	89 55 14             	mov    %edx,0x14(%ebp)
f0105cae:	8b 30                	mov    (%eax),%esi
f0105cb0:	85 f6                	test   %esi,%esi
f0105cb2:	75 05                	jne    f0105cb9 <vprintfmt+0x185>
				p = "(null)";
f0105cb4:	be bf 88 10 f0       	mov    $0xf01088bf,%esi
			if (width > 0 && padc != '-')
f0105cb9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105cbd:	0f 8e 84 00 00 00    	jle    f0105d47 <vprintfmt+0x213>
f0105cc3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105cc7:	74 7e                	je     f0105d47 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105cc9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105ccd:	89 34 24             	mov    %esi,(%esp)
f0105cd0:	e8 25 03 00 00       	call   f0105ffa <strnlen>
f0105cd5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105cd8:	29 c2                	sub    %eax,%edx
f0105cda:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105cdd:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
f0105ce1:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105ce4:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105ce7:	89 de                	mov    %ebx,%esi
f0105ce9:	89 d3                	mov    %edx,%ebx
f0105ceb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ced:	eb 0b                	jmp    f0105cfa <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105cef:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105cf3:	89 3c 24             	mov    %edi,(%esp)
f0105cf6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105cf9:	4b                   	dec    %ebx
f0105cfa:	85 db                	test   %ebx,%ebx
f0105cfc:	7f f1                	jg     f0105cef <vprintfmt+0x1bb>
f0105cfe:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105d01:	89 f3                	mov    %esi,%ebx
f0105d03:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105d06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d09:	85 c0                	test   %eax,%eax
f0105d0b:	79 05                	jns    f0105d12 <vprintfmt+0x1de>
f0105d0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105d15:	29 c2                	sub    %eax,%edx
f0105d17:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105d1a:	eb 2b                	jmp    f0105d47 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105d1c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105d20:	74 18                	je     f0105d3a <vprintfmt+0x206>
f0105d22:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105d25:	83 fa 5e             	cmp    $0x5e,%edx
f0105d28:	76 10                	jbe    f0105d3a <vprintfmt+0x206>
					putch('?', putdat);
f0105d2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d2e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105d35:	ff 55 08             	call   *0x8(%ebp)
f0105d38:	eb 0a                	jmp    f0105d44 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105d3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d3e:	89 04 24             	mov    %eax,(%esp)
f0105d41:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105d44:	ff 4d e4             	decl   -0x1c(%ebp)
f0105d47:	0f be 06             	movsbl (%esi),%eax
f0105d4a:	46                   	inc    %esi
f0105d4b:	85 c0                	test   %eax,%eax
f0105d4d:	74 21                	je     f0105d70 <vprintfmt+0x23c>
f0105d4f:	85 ff                	test   %edi,%edi
f0105d51:	78 c9                	js     f0105d1c <vprintfmt+0x1e8>
f0105d53:	4f                   	dec    %edi
f0105d54:	79 c6                	jns    f0105d1c <vprintfmt+0x1e8>
f0105d56:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d59:	89 de                	mov    %ebx,%esi
f0105d5b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105d5e:	eb 18                	jmp    f0105d78 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105d60:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105d64:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105d6b:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105d6d:	4b                   	dec    %ebx
f0105d6e:	eb 08                	jmp    f0105d78 <vprintfmt+0x244>
f0105d70:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d73:	89 de                	mov    %ebx,%esi
f0105d75:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105d78:	85 db                	test   %ebx,%ebx
f0105d7a:	7f e4                	jg     f0105d60 <vprintfmt+0x22c>
f0105d7c:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105d7f:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d81:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105d84:	e9 ce fd ff ff       	jmp    f0105b57 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105d89:	8d 45 14             	lea    0x14(%ebp),%eax
f0105d8c:	e8 2f fd ff ff       	call   f0105ac0 <getint>
f0105d91:	89 c6                	mov    %eax,%esi
f0105d93:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
f0105d95:	85 d2                	test   %edx,%edx
f0105d97:	78 07                	js     f0105da0 <vprintfmt+0x26c>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105d99:	be 0a 00 00 00       	mov    $0xa,%esi
f0105d9e:	eb 7e                	jmp    f0105e1e <vprintfmt+0x2ea>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105da0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105da4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105dab:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105dae:	89 f0                	mov    %esi,%eax
f0105db0:	89 fa                	mov    %edi,%edx
f0105db2:	f7 d8                	neg    %eax
f0105db4:	83 d2 00             	adc    $0x0,%edx
f0105db7:	f7 da                	neg    %edx
			}
			base = 10;
f0105db9:	be 0a 00 00 00       	mov    $0xa,%esi
f0105dbe:	eb 5e                	jmp    f0105e1e <vprintfmt+0x2ea>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105dc0:	8d 45 14             	lea    0x14(%ebp),%eax
f0105dc3:	e8 be fc ff ff       	call   f0105a86 <getuint>
			base = 10;
f0105dc8:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0105dcd:	eb 4f                	jmp    f0105e1e <vprintfmt+0x2ea>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0105dcf:	8d 45 14             	lea    0x14(%ebp),%eax
f0105dd2:	e8 af fc ff ff       	call   f0105a86 <getuint>
			base = 8;
f0105dd7:	be 08 00 00 00       	mov    $0x8,%esi
			goto number;
f0105ddc:	eb 40                	jmp    f0105e1e <vprintfmt+0x2ea>

		// pointer
		case 'p':
			putch('0', putdat);
f0105dde:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105de2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105de9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105dec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105df0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105df7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105dfa:	8b 45 14             	mov    0x14(%ebp),%eax
f0105dfd:	8d 50 04             	lea    0x4(%eax),%edx
f0105e00:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105e03:	8b 00                	mov    (%eax),%eax
f0105e05:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105e0a:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0105e0f:	eb 0d                	jmp    f0105e1e <vprintfmt+0x2ea>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105e11:	8d 45 14             	lea    0x14(%ebp),%eax
f0105e14:	e8 6d fc ff ff       	call   f0105a86 <getuint>
			base = 16;
f0105e19:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105e1e:	0f be 4d d8          	movsbl -0x28(%ebp),%ecx
f0105e22:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105e26:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105e29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105e2d:	89 74 24 08          	mov    %esi,0x8(%esp)
f0105e31:	89 04 24             	mov    %eax,(%esp)
f0105e34:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e38:	89 da                	mov    %ebx,%edx
f0105e3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e3d:	e8 7a fb ff ff       	call   f01059bc <printnum>
			break;
f0105e42:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105e45:	e9 0d fd ff ff       	jmp    f0105b57 <vprintfmt+0x23>

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
f0105e4a:	8d 45 14             	lea    0x14(%ebp),%eax
f0105e4d:	e8 6e fc ff ff       	call   f0105ac0 <getint>
f0105e52:	a3 48 a4 12 f0       	mov    %eax,0xf012a448
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e57:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// color info
		case 'r':
			console_color = getint(&ap, lflag);
			break;
f0105e5a:	e9 f8 fc ff ff       	jmp    f0105b57 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105e5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e63:	89 04 24             	mov    %eax,(%esp)
f0105e66:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e69:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105e6c:	e9 e6 fc ff ff       	jmp    f0105b57 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105e71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e75:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105e7c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105e7f:	eb 01                	jmp    f0105e82 <vprintfmt+0x34e>
f0105e81:	4e                   	dec    %esi
f0105e82:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105e86:	75 f9                	jne    f0105e81 <vprintfmt+0x34d>
f0105e88:	e9 ca fc ff ff       	jmp    f0105b57 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105e8d:	83 c4 4c             	add    $0x4c,%esp
f0105e90:	5b                   	pop    %ebx
f0105e91:	5e                   	pop    %esi
f0105e92:	5f                   	pop    %edi
f0105e93:	5d                   	pop    %ebp
f0105e94:	c3                   	ret    

f0105e95 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105e95:	55                   	push   %ebp
f0105e96:	89 e5                	mov    %esp,%ebp
f0105e98:	83 ec 28             	sub    $0x28,%esp
f0105e9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105ea1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105ea4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105ea8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105eab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105eb2:	85 c0                	test   %eax,%eax
f0105eb4:	74 30                	je     f0105ee6 <vsnprintf+0x51>
f0105eb6:	85 d2                	test   %edx,%edx
f0105eb8:	7e 33                	jle    f0105eed <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105eba:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ebd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ec1:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ec4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ec8:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ecf:	c7 04 24 f2 5a 10 f0 	movl   $0xf0105af2,(%esp)
f0105ed6:	e8 59 fc ff ff       	call   f0105b34 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105edb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105ede:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105ee4:	eb 0c                	jmp    f0105ef2 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105eeb:	eb 05                	jmp    f0105ef2 <vsnprintf+0x5d>
f0105eed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105ef2:	c9                   	leave  
f0105ef3:	c3                   	ret    

f0105ef4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105ef4:	55                   	push   %ebp
f0105ef5:	89 e5                	mov    %esp,%ebp
f0105ef7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105efa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105efd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f01:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f04:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f08:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f12:	89 04 24             	mov    %eax,(%esp)
f0105f15:	e8 7b ff ff ff       	call   f0105e95 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105f1a:	c9                   	leave  
f0105f1b:	c3                   	ret    

f0105f1c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105f1c:	55                   	push   %ebp
f0105f1d:	89 e5                	mov    %esp,%ebp
f0105f1f:	57                   	push   %edi
f0105f20:	56                   	push   %esi
f0105f21:	53                   	push   %ebx
f0105f22:	83 ec 1c             	sub    $0x1c,%esp
f0105f25:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105f28:	85 c0                	test   %eax,%eax
f0105f2a:	74 10                	je     f0105f3c <readline+0x20>
		cprintf("%s", prompt);
f0105f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f30:	c7 04 24 0d 80 10 f0 	movl   $0xf010800d,(%esp)
f0105f37:	e8 b6 e2 ff ff       	call   f01041f2 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105f3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105f43:	e8 94 a8 ff ff       	call   f01007dc <iscons>
f0105f48:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105f4a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105f4f:	e8 77 a8 ff ff       	call   f01007cb <getchar>
f0105f54:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105f56:	85 c0                	test   %eax,%eax
f0105f58:	79 17                	jns    f0105f71 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f5e:	c7 04 24 08 8b 10 f0 	movl   $0xf0108b08,(%esp)
f0105f65:	e8 88 e2 ff ff       	call   f01041f2 <cprintf>
			return NULL;
f0105f6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f6f:	eb 69                	jmp    f0105fda <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105f71:	83 f8 08             	cmp    $0x8,%eax
f0105f74:	74 05                	je     f0105f7b <readline+0x5f>
f0105f76:	83 f8 7f             	cmp    $0x7f,%eax
f0105f79:	75 17                	jne    f0105f92 <readline+0x76>
f0105f7b:	85 f6                	test   %esi,%esi
f0105f7d:	7e 13                	jle    f0105f92 <readline+0x76>
			if (echoing)
f0105f7f:	85 ff                	test   %edi,%edi
f0105f81:	74 0c                	je     f0105f8f <readline+0x73>
				cputchar('\b');
f0105f83:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105f8a:	e8 2c a8 ff ff       	call   f01007bb <cputchar>
			i--;
f0105f8f:	4e                   	dec    %esi
f0105f90:	eb bd                	jmp    f0105f4f <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105f92:	83 fb 1f             	cmp    $0x1f,%ebx
f0105f95:	7e 1d                	jle    f0105fb4 <readline+0x98>
f0105f97:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105f9d:	7f 15                	jg     f0105fb4 <readline+0x98>
			if (echoing)
f0105f9f:	85 ff                	test   %edi,%edi
f0105fa1:	74 08                	je     f0105fab <readline+0x8f>
				cputchar(c);
f0105fa3:	89 1c 24             	mov    %ebx,(%esp)
f0105fa6:	e8 10 a8 ff ff       	call   f01007bb <cputchar>
			buf[i++] = c;
f0105fab:	88 9e 80 2a 33 f0    	mov    %bl,-0xfccd580(%esi)
f0105fb1:	46                   	inc    %esi
f0105fb2:	eb 9b                	jmp    f0105f4f <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105fb4:	83 fb 0a             	cmp    $0xa,%ebx
f0105fb7:	74 05                	je     f0105fbe <readline+0xa2>
f0105fb9:	83 fb 0d             	cmp    $0xd,%ebx
f0105fbc:	75 91                	jne    f0105f4f <readline+0x33>
			if (echoing)
f0105fbe:	85 ff                	test   %edi,%edi
f0105fc0:	74 0c                	je     f0105fce <readline+0xb2>
				cputchar('\n');
f0105fc2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105fc9:	e8 ed a7 ff ff       	call   f01007bb <cputchar>
			buf[i] = 0;
f0105fce:	c6 86 80 2a 33 f0 00 	movb   $0x0,-0xfccd580(%esi)
			return buf;
f0105fd5:	b8 80 2a 33 f0       	mov    $0xf0332a80,%eax
		}
	}
}
f0105fda:	83 c4 1c             	add    $0x1c,%esp
f0105fdd:	5b                   	pop    %ebx
f0105fde:	5e                   	pop    %esi
f0105fdf:	5f                   	pop    %edi
f0105fe0:	5d                   	pop    %ebp
f0105fe1:	c3                   	ret    
	...

f0105fe4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105fe4:	55                   	push   %ebp
f0105fe5:	89 e5                	mov    %esp,%ebp
f0105fe7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105fea:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fef:	eb 01                	jmp    f0105ff2 <strlen+0xe>
		n++;
f0105ff1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105ff2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105ff6:	75 f9                	jne    f0105ff1 <strlen+0xd>
		n++;
	return n;
}
f0105ff8:	5d                   	pop    %ebp
f0105ff9:	c3                   	ret    

f0105ffa <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105ffa:	55                   	push   %ebp
f0105ffb:	89 e5                	mov    %esp,%ebp
f0105ffd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0106000:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106003:	b8 00 00 00 00       	mov    $0x0,%eax
f0106008:	eb 01                	jmp    f010600b <strnlen+0x11>
		n++;
f010600a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010600b:	39 d0                	cmp    %edx,%eax
f010600d:	74 06                	je     f0106015 <strnlen+0x1b>
f010600f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0106013:	75 f5                	jne    f010600a <strnlen+0x10>
		n++;
	return n;
}
f0106015:	5d                   	pop    %ebp
f0106016:	c3                   	ret    

f0106017 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0106017:	55                   	push   %ebp
f0106018:	89 e5                	mov    %esp,%ebp
f010601a:	53                   	push   %ebx
f010601b:	8b 45 08             	mov    0x8(%ebp),%eax
f010601e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106021:	ba 00 00 00 00       	mov    $0x0,%edx
f0106026:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0106029:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010602c:	42                   	inc    %edx
f010602d:	84 c9                	test   %cl,%cl
f010602f:	75 f5                	jne    f0106026 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0106031:	5b                   	pop    %ebx
f0106032:	5d                   	pop    %ebp
f0106033:	c3                   	ret    

f0106034 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0106034:	55                   	push   %ebp
f0106035:	89 e5                	mov    %esp,%ebp
f0106037:	53                   	push   %ebx
f0106038:	83 ec 08             	sub    $0x8,%esp
f010603b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010603e:	89 1c 24             	mov    %ebx,(%esp)
f0106041:	e8 9e ff ff ff       	call   f0105fe4 <strlen>
	strcpy(dst + len, src);
f0106046:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106049:	89 54 24 04          	mov    %edx,0x4(%esp)
f010604d:	01 d8                	add    %ebx,%eax
f010604f:	89 04 24             	mov    %eax,(%esp)
f0106052:	e8 c0 ff ff ff       	call   f0106017 <strcpy>
	return dst;
}
f0106057:	89 d8                	mov    %ebx,%eax
f0106059:	83 c4 08             	add    $0x8,%esp
f010605c:	5b                   	pop    %ebx
f010605d:	5d                   	pop    %ebp
f010605e:	c3                   	ret    

f010605f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010605f:	55                   	push   %ebp
f0106060:	89 e5                	mov    %esp,%ebp
f0106062:	56                   	push   %esi
f0106063:	53                   	push   %ebx
f0106064:	8b 45 08             	mov    0x8(%ebp),%eax
f0106067:	8b 55 0c             	mov    0xc(%ebp),%edx
f010606a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010606d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106072:	eb 0c                	jmp    f0106080 <strncpy+0x21>
		*dst++ = *src;
f0106074:	8a 1a                	mov    (%edx),%bl
f0106076:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106079:	80 3a 01             	cmpb   $0x1,(%edx)
f010607c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010607f:	41                   	inc    %ecx
f0106080:	39 f1                	cmp    %esi,%ecx
f0106082:	75 f0                	jne    f0106074 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106084:	5b                   	pop    %ebx
f0106085:	5e                   	pop    %esi
f0106086:	5d                   	pop    %ebp
f0106087:	c3                   	ret    

f0106088 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0106088:	55                   	push   %ebp
f0106089:	89 e5                	mov    %esp,%ebp
f010608b:	56                   	push   %esi
f010608c:	53                   	push   %ebx
f010608d:	8b 75 08             	mov    0x8(%ebp),%esi
f0106090:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106093:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106096:	85 d2                	test   %edx,%edx
f0106098:	75 0a                	jne    f01060a4 <strlcpy+0x1c>
f010609a:	89 f0                	mov    %esi,%eax
f010609c:	eb 1a                	jmp    f01060b8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010609e:	88 18                	mov    %bl,(%eax)
f01060a0:	40                   	inc    %eax
f01060a1:	41                   	inc    %ecx
f01060a2:	eb 02                	jmp    f01060a6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01060a4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f01060a6:	4a                   	dec    %edx
f01060a7:	74 0a                	je     f01060b3 <strlcpy+0x2b>
f01060a9:	8a 19                	mov    (%ecx),%bl
f01060ab:	84 db                	test   %bl,%bl
f01060ad:	75 ef                	jne    f010609e <strlcpy+0x16>
f01060af:	89 c2                	mov    %eax,%edx
f01060b1:	eb 02                	jmp    f01060b5 <strlcpy+0x2d>
f01060b3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01060b5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01060b8:	29 f0                	sub    %esi,%eax
}
f01060ba:	5b                   	pop    %ebx
f01060bb:	5e                   	pop    %esi
f01060bc:	5d                   	pop    %ebp
f01060bd:	c3                   	ret    

f01060be <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01060be:	55                   	push   %ebp
f01060bf:	89 e5                	mov    %esp,%ebp
f01060c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01060c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01060c7:	eb 02                	jmp    f01060cb <strcmp+0xd>
		p++, q++;
f01060c9:	41                   	inc    %ecx
f01060ca:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01060cb:	8a 01                	mov    (%ecx),%al
f01060cd:	84 c0                	test   %al,%al
f01060cf:	74 04                	je     f01060d5 <strcmp+0x17>
f01060d1:	3a 02                	cmp    (%edx),%al
f01060d3:	74 f4                	je     f01060c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01060d5:	0f b6 c0             	movzbl %al,%eax
f01060d8:	0f b6 12             	movzbl (%edx),%edx
f01060db:	29 d0                	sub    %edx,%eax
}
f01060dd:	5d                   	pop    %ebp
f01060de:	c3                   	ret    

f01060df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01060df:	55                   	push   %ebp
f01060e0:	89 e5                	mov    %esp,%ebp
f01060e2:	53                   	push   %ebx
f01060e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01060e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01060e9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01060ec:	eb 03                	jmp    f01060f1 <strncmp+0x12>
		n--, p++, q++;
f01060ee:	4a                   	dec    %edx
f01060ef:	40                   	inc    %eax
f01060f0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01060f1:	85 d2                	test   %edx,%edx
f01060f3:	74 14                	je     f0106109 <strncmp+0x2a>
f01060f5:	8a 18                	mov    (%eax),%bl
f01060f7:	84 db                	test   %bl,%bl
f01060f9:	74 04                	je     f01060ff <strncmp+0x20>
f01060fb:	3a 19                	cmp    (%ecx),%bl
f01060fd:	74 ef                	je     f01060ee <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01060ff:	0f b6 00             	movzbl (%eax),%eax
f0106102:	0f b6 11             	movzbl (%ecx),%edx
f0106105:	29 d0                	sub    %edx,%eax
f0106107:	eb 05                	jmp    f010610e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106109:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010610e:	5b                   	pop    %ebx
f010610f:	5d                   	pop    %ebp
f0106110:	c3                   	ret    

f0106111 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106111:	55                   	push   %ebp
f0106112:	89 e5                	mov    %esp,%ebp
f0106114:	8b 45 08             	mov    0x8(%ebp),%eax
f0106117:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010611a:	eb 05                	jmp    f0106121 <strchr+0x10>
		if (*s == c)
f010611c:	38 ca                	cmp    %cl,%dl
f010611e:	74 0c                	je     f010612c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106120:	40                   	inc    %eax
f0106121:	8a 10                	mov    (%eax),%dl
f0106123:	84 d2                	test   %dl,%dl
f0106125:	75 f5                	jne    f010611c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0106127:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010612c:	5d                   	pop    %ebp
f010612d:	c3                   	ret    

f010612e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010612e:	55                   	push   %ebp
f010612f:	89 e5                	mov    %esp,%ebp
f0106131:	8b 45 08             	mov    0x8(%ebp),%eax
f0106134:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0106137:	eb 05                	jmp    f010613e <strfind+0x10>
		if (*s == c)
f0106139:	38 ca                	cmp    %cl,%dl
f010613b:	74 07                	je     f0106144 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010613d:	40                   	inc    %eax
f010613e:	8a 10                	mov    (%eax),%dl
f0106140:	84 d2                	test   %dl,%dl
f0106142:	75 f5                	jne    f0106139 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0106144:	5d                   	pop    %ebp
f0106145:	c3                   	ret    

f0106146 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106146:	55                   	push   %ebp
f0106147:	89 e5                	mov    %esp,%ebp
f0106149:	57                   	push   %edi
f010614a:	56                   	push   %esi
f010614b:	53                   	push   %ebx
f010614c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010614f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106152:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106155:	85 c9                	test   %ecx,%ecx
f0106157:	74 30                	je     f0106189 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106159:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010615f:	75 25                	jne    f0106186 <memset+0x40>
f0106161:	f6 c1 03             	test   $0x3,%cl
f0106164:	75 20                	jne    f0106186 <memset+0x40>
		c &= 0xFF;
f0106166:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106169:	89 d3                	mov    %edx,%ebx
f010616b:	c1 e3 08             	shl    $0x8,%ebx
f010616e:	89 d6                	mov    %edx,%esi
f0106170:	c1 e6 18             	shl    $0x18,%esi
f0106173:	89 d0                	mov    %edx,%eax
f0106175:	c1 e0 10             	shl    $0x10,%eax
f0106178:	09 f0                	or     %esi,%eax
f010617a:	09 d0                	or     %edx,%eax
f010617c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010617e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106181:	fc                   	cld    
f0106182:	f3 ab                	rep stos %eax,%es:(%edi)
f0106184:	eb 03                	jmp    f0106189 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106186:	fc                   	cld    
f0106187:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0106189:	89 f8                	mov    %edi,%eax
f010618b:	5b                   	pop    %ebx
f010618c:	5e                   	pop    %esi
f010618d:	5f                   	pop    %edi
f010618e:	5d                   	pop    %ebp
f010618f:	c3                   	ret    

f0106190 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106190:	55                   	push   %ebp
f0106191:	89 e5                	mov    %esp,%ebp
f0106193:	57                   	push   %edi
f0106194:	56                   	push   %esi
f0106195:	8b 45 08             	mov    0x8(%ebp),%eax
f0106198:	8b 75 0c             	mov    0xc(%ebp),%esi
f010619b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010619e:	39 c6                	cmp    %eax,%esi
f01061a0:	73 34                	jae    f01061d6 <memmove+0x46>
f01061a2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01061a5:	39 d0                	cmp    %edx,%eax
f01061a7:	73 2d                	jae    f01061d6 <memmove+0x46>
		s += n;
		d += n;
f01061a9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01061ac:	f6 c2 03             	test   $0x3,%dl
f01061af:	75 1b                	jne    f01061cc <memmove+0x3c>
f01061b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01061b7:	75 13                	jne    f01061cc <memmove+0x3c>
f01061b9:	f6 c1 03             	test   $0x3,%cl
f01061bc:	75 0e                	jne    f01061cc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01061be:	83 ef 04             	sub    $0x4,%edi
f01061c1:	8d 72 fc             	lea    -0x4(%edx),%esi
f01061c4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01061c7:	fd                   	std    
f01061c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01061ca:	eb 07                	jmp    f01061d3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01061cc:	4f                   	dec    %edi
f01061cd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01061d0:	fd                   	std    
f01061d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01061d3:	fc                   	cld    
f01061d4:	eb 20                	jmp    f01061f6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01061d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01061dc:	75 13                	jne    f01061f1 <memmove+0x61>
f01061de:	a8 03                	test   $0x3,%al
f01061e0:	75 0f                	jne    f01061f1 <memmove+0x61>
f01061e2:	f6 c1 03             	test   $0x3,%cl
f01061e5:	75 0a                	jne    f01061f1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01061e7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01061ea:	89 c7                	mov    %eax,%edi
f01061ec:	fc                   	cld    
f01061ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01061ef:	eb 05                	jmp    f01061f6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01061f1:	89 c7                	mov    %eax,%edi
f01061f3:	fc                   	cld    
f01061f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01061f6:	5e                   	pop    %esi
f01061f7:	5f                   	pop    %edi
f01061f8:	5d                   	pop    %ebp
f01061f9:	c3                   	ret    

f01061fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01061fa:	55                   	push   %ebp
f01061fb:	89 e5                	mov    %esp,%ebp
f01061fd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106200:	8b 45 10             	mov    0x10(%ebp),%eax
f0106203:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106207:	8b 45 0c             	mov    0xc(%ebp),%eax
f010620a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010620e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106211:	89 04 24             	mov    %eax,(%esp)
f0106214:	e8 77 ff ff ff       	call   f0106190 <memmove>
}
f0106219:	c9                   	leave  
f010621a:	c3                   	ret    

f010621b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010621b:	55                   	push   %ebp
f010621c:	89 e5                	mov    %esp,%ebp
f010621e:	57                   	push   %edi
f010621f:	56                   	push   %esi
f0106220:	53                   	push   %ebx
f0106221:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106224:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106227:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010622a:	ba 00 00 00 00       	mov    $0x0,%edx
f010622f:	eb 16                	jmp    f0106247 <memcmp+0x2c>
		if (*s1 != *s2)
f0106231:	8a 04 17             	mov    (%edi,%edx,1),%al
f0106234:	42                   	inc    %edx
f0106235:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0106239:	38 c8                	cmp    %cl,%al
f010623b:	74 0a                	je     f0106247 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f010623d:	0f b6 c0             	movzbl %al,%eax
f0106240:	0f b6 c9             	movzbl %cl,%ecx
f0106243:	29 c8                	sub    %ecx,%eax
f0106245:	eb 09                	jmp    f0106250 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106247:	39 da                	cmp    %ebx,%edx
f0106249:	75 e6                	jne    f0106231 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010624b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106250:	5b                   	pop    %ebx
f0106251:	5e                   	pop    %esi
f0106252:	5f                   	pop    %edi
f0106253:	5d                   	pop    %ebp
f0106254:	c3                   	ret    

f0106255 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106255:	55                   	push   %ebp
f0106256:	89 e5                	mov    %esp,%ebp
f0106258:	8b 45 08             	mov    0x8(%ebp),%eax
f010625b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010625e:	89 c2                	mov    %eax,%edx
f0106260:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106263:	eb 05                	jmp    f010626a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106265:	38 08                	cmp    %cl,(%eax)
f0106267:	74 05                	je     f010626e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106269:	40                   	inc    %eax
f010626a:	39 d0                	cmp    %edx,%eax
f010626c:	72 f7                	jb     f0106265 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010626e:	5d                   	pop    %ebp
f010626f:	c3                   	ret    

f0106270 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106270:	55                   	push   %ebp
f0106271:	89 e5                	mov    %esp,%ebp
f0106273:	57                   	push   %edi
f0106274:	56                   	push   %esi
f0106275:	53                   	push   %ebx
f0106276:	8b 55 08             	mov    0x8(%ebp),%edx
f0106279:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010627c:	eb 01                	jmp    f010627f <strtol+0xf>
		s++;
f010627e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010627f:	8a 02                	mov    (%edx),%al
f0106281:	3c 20                	cmp    $0x20,%al
f0106283:	74 f9                	je     f010627e <strtol+0xe>
f0106285:	3c 09                	cmp    $0x9,%al
f0106287:	74 f5                	je     f010627e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106289:	3c 2b                	cmp    $0x2b,%al
f010628b:	75 08                	jne    f0106295 <strtol+0x25>
		s++;
f010628d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010628e:	bf 00 00 00 00       	mov    $0x0,%edi
f0106293:	eb 13                	jmp    f01062a8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106295:	3c 2d                	cmp    $0x2d,%al
f0106297:	75 0a                	jne    f01062a3 <strtol+0x33>
		s++, neg = 1;
f0106299:	8d 52 01             	lea    0x1(%edx),%edx
f010629c:	bf 01 00 00 00       	mov    $0x1,%edi
f01062a1:	eb 05                	jmp    f01062a8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01062a3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01062a8:	85 db                	test   %ebx,%ebx
f01062aa:	74 05                	je     f01062b1 <strtol+0x41>
f01062ac:	83 fb 10             	cmp    $0x10,%ebx
f01062af:	75 28                	jne    f01062d9 <strtol+0x69>
f01062b1:	8a 02                	mov    (%edx),%al
f01062b3:	3c 30                	cmp    $0x30,%al
f01062b5:	75 10                	jne    f01062c7 <strtol+0x57>
f01062b7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01062bb:	75 0a                	jne    f01062c7 <strtol+0x57>
		s += 2, base = 16;
f01062bd:	83 c2 02             	add    $0x2,%edx
f01062c0:	bb 10 00 00 00       	mov    $0x10,%ebx
f01062c5:	eb 12                	jmp    f01062d9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01062c7:	85 db                	test   %ebx,%ebx
f01062c9:	75 0e                	jne    f01062d9 <strtol+0x69>
f01062cb:	3c 30                	cmp    $0x30,%al
f01062cd:	75 05                	jne    f01062d4 <strtol+0x64>
		s++, base = 8;
f01062cf:	42                   	inc    %edx
f01062d0:	b3 08                	mov    $0x8,%bl
f01062d2:	eb 05                	jmp    f01062d9 <strtol+0x69>
	else if (base == 0)
		base = 10;
f01062d4:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01062d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01062de:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01062e0:	8a 0a                	mov    (%edx),%cl
f01062e2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01062e5:	80 fb 09             	cmp    $0x9,%bl
f01062e8:	77 08                	ja     f01062f2 <strtol+0x82>
			dig = *s - '0';
f01062ea:	0f be c9             	movsbl %cl,%ecx
f01062ed:	83 e9 30             	sub    $0x30,%ecx
f01062f0:	eb 1e                	jmp    f0106310 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01062f2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01062f5:	80 fb 19             	cmp    $0x19,%bl
f01062f8:	77 08                	ja     f0106302 <strtol+0x92>
			dig = *s - 'a' + 10;
f01062fa:	0f be c9             	movsbl %cl,%ecx
f01062fd:	83 e9 57             	sub    $0x57,%ecx
f0106300:	eb 0e                	jmp    f0106310 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0106302:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0106305:	80 fb 19             	cmp    $0x19,%bl
f0106308:	77 12                	ja     f010631c <strtol+0xac>
			dig = *s - 'A' + 10;
f010630a:	0f be c9             	movsbl %cl,%ecx
f010630d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106310:	39 f1                	cmp    %esi,%ecx
f0106312:	7d 0c                	jge    f0106320 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0106314:	42                   	inc    %edx
f0106315:	0f af c6             	imul   %esi,%eax
f0106318:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010631a:	eb c4                	jmp    f01062e0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010631c:	89 c1                	mov    %eax,%ecx
f010631e:	eb 02                	jmp    f0106322 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0106320:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0106322:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106326:	74 05                	je     f010632d <strtol+0xbd>
		*endptr = (char *) s;
f0106328:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010632b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010632d:	85 ff                	test   %edi,%edi
f010632f:	74 04                	je     f0106335 <strtol+0xc5>
f0106331:	89 c8                	mov    %ecx,%eax
f0106333:	f7 d8                	neg    %eax
}
f0106335:	5b                   	pop    %ebx
f0106336:	5e                   	pop    %esi
f0106337:	5f                   	pop    %edi
f0106338:	5d                   	pop    %ebp
f0106339:	c3                   	ret    
	...

f010633c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010633c:	fa                   	cli    

	xorw    %ax, %ax
f010633d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010633f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106341:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106343:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106345:	0f 01 16             	lgdtl  (%esi)
f0106348:	74 70                	je     f01063ba <sum+0x2>
	movl    %cr0, %eax
f010634a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010634d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106351:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106354:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010635a:	08 00                	or     %al,(%eax)

f010635c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010635c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106360:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106362:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106364:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106366:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010636a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010636c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010636e:	b8 00 80 12 00       	mov    $0x128000,%eax
	movl    %eax, %cr3
f0106373:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106376:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106379:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010637e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106381:	8b 25 84 2e 33 f0    	mov    0xf0332e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106387:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010638c:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106391:	ff d0                	call   *%eax

f0106393 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106393:	eb fe                	jmp    f0106393 <spin>
f0106395:	8d 76 00             	lea    0x0(%esi),%esi

f0106398 <gdt>:
	...
f01063a0:	ff                   	(bad)  
f01063a1:	ff 00                	incl   (%eax)
f01063a3:	00 00                	add    %al,(%eax)
f01063a5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01063ac:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01063b0 <gdtdesc>:
f01063b0:	17                   	pop    %ss
f01063b1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01063b6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01063b6:	90                   	nop
	...

f01063b8 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f01063b8:	55                   	push   %ebp
f01063b9:	89 e5                	mov    %esp,%ebp
f01063bb:	56                   	push   %esi
f01063bc:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f01063bd:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f01063c2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01063c7:	eb 07                	jmp    f01063d0 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f01063c9:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f01063cd:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01063cf:	41                   	inc    %ecx
f01063d0:	39 d1                	cmp    %edx,%ecx
f01063d2:	7c f5                	jl     f01063c9 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f01063d4:	88 d8                	mov    %bl,%al
f01063d6:	5b                   	pop    %ebx
f01063d7:	5e                   	pop    %esi
f01063d8:	5d                   	pop    %ebp
f01063d9:	c3                   	ret    

f01063da <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01063da:	55                   	push   %ebp
f01063db:	89 e5                	mov    %esp,%ebp
f01063dd:	56                   	push   %esi
f01063de:	53                   	push   %ebx
f01063df:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063e2:	8b 0d 88 2e 33 f0    	mov    0xf0332e88,%ecx
f01063e8:	89 c3                	mov    %eax,%ebx
f01063ea:	c1 eb 0c             	shr    $0xc,%ebx
f01063ed:	39 cb                	cmp    %ecx,%ebx
f01063ef:	72 20                	jb     f0106411 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01063f5:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01063fc:	f0 
f01063fd:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106404:	00 
f0106405:	c7 04 24 a5 8c 10 f0 	movl   $0xf0108ca5,(%esp)
f010640c:	e8 2f 9c ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106411:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106414:	89 f2                	mov    %esi,%edx
f0106416:	c1 ea 0c             	shr    $0xc,%edx
f0106419:	39 d1                	cmp    %edx,%ecx
f010641b:	77 20                	ja     f010643d <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010641d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106421:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f0106428:	f0 
f0106429:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106430:	00 
f0106431:	c7 04 24 a5 8c 10 f0 	movl   $0xf0108ca5,(%esp)
f0106438:	e8 03 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010643d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0106443:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106449:	eb 2f                	jmp    f010647a <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010644b:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106452:	00 
f0106453:	c7 44 24 04 b5 8c 10 	movl   $0xf0108cb5,0x4(%esp)
f010645a:	f0 
f010645b:	89 1c 24             	mov    %ebx,(%esp)
f010645e:	e8 b8 fd ff ff       	call   f010621b <memcmp>
f0106463:	85 c0                	test   %eax,%eax
f0106465:	75 10                	jne    f0106477 <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f0106467:	ba 10 00 00 00       	mov    $0x10,%edx
f010646c:	89 d8                	mov    %ebx,%eax
f010646e:	e8 45 ff ff ff       	call   f01063b8 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106473:	84 c0                	test   %al,%al
f0106475:	74 0c                	je     f0106483 <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106477:	83 c3 10             	add    $0x10,%ebx
f010647a:	39 f3                	cmp    %esi,%ebx
f010647c:	72 cd                	jb     f010644b <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010647e:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106483:	89 d8                	mov    %ebx,%eax
f0106485:	83 c4 10             	add    $0x10,%esp
f0106488:	5b                   	pop    %ebx
f0106489:	5e                   	pop    %esi
f010648a:	5d                   	pop    %ebp
f010648b:	c3                   	ret    

f010648c <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010648c:	55                   	push   %ebp
f010648d:	89 e5                	mov    %esp,%ebp
f010648f:	57                   	push   %edi
f0106490:	56                   	push   %esi
f0106491:	53                   	push   %ebx
f0106492:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106495:	c7 05 c0 33 33 f0 20 	movl   $0xf0333020,0xf03333c0
f010649c:	30 33 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010649f:	83 3d 88 2e 33 f0 00 	cmpl   $0x0,0xf0332e88
f01064a6:	75 24                	jne    f01064cc <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064a8:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01064af:	00 
f01064b0:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f01064b7:	f0 
f01064b8:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01064bf:	00 
f01064c0:	c7 04 24 a5 8c 10 f0 	movl   $0xf0108ca5,(%esp)
f01064c7:	e8 74 9b ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01064cc:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01064d3:	85 c0                	test   %eax,%eax
f01064d5:	74 16                	je     f01064ed <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01064d7:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01064da:	ba 00 04 00 00       	mov    $0x400,%edx
f01064df:	e8 f6 fe ff ff       	call   f01063da <mpsearch1>
f01064e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064e7:	85 c0                	test   %eax,%eax
f01064e9:	75 3c                	jne    f0106527 <mp_init+0x9b>
f01064eb:	eb 20                	jmp    f010650d <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01064ed:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01064f4:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01064f7:	2d 00 04 00 00       	sub    $0x400,%eax
f01064fc:	ba 00 04 00 00       	mov    $0x400,%edx
f0106501:	e8 d4 fe ff ff       	call   f01063da <mpsearch1>
f0106506:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106509:	85 c0                	test   %eax,%eax
f010650b:	75 1a                	jne    f0106527 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010650d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106512:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106517:	e8 be fe ff ff       	call   f01063da <mpsearch1>
f010651c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010651f:	85 c0                	test   %eax,%eax
f0106521:	0f 84 2c 02 00 00    	je     f0106753 <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106527:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010652a:	8b 58 04             	mov    0x4(%eax),%ebx
f010652d:	85 db                	test   %ebx,%ebx
f010652f:	74 06                	je     f0106537 <mp_init+0xab>
f0106531:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106535:	74 11                	je     f0106548 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106537:	c7 04 24 18 8b 10 f0 	movl   $0xf0108b18,(%esp)
f010653e:	e8 af dc ff ff       	call   f01041f2 <cprintf>
f0106543:	e9 0b 02 00 00       	jmp    f0106753 <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106548:	89 d8                	mov    %ebx,%eax
f010654a:	c1 e8 0c             	shr    $0xc,%eax
f010654d:	3b 05 88 2e 33 f0    	cmp    0xf0332e88,%eax
f0106553:	72 20                	jb     f0106575 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106555:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106559:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f0106560:	f0 
f0106561:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106568:	00 
f0106569:	c7 04 24 a5 8c 10 f0 	movl   $0xf0108ca5,(%esp)
f0106570:	e8 cb 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106575:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010657b:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106582:	00 
f0106583:	c7 44 24 04 ba 8c 10 	movl   $0xf0108cba,0x4(%esp)
f010658a:	f0 
f010658b:	89 1c 24             	mov    %ebx,(%esp)
f010658e:	e8 88 fc ff ff       	call   f010621b <memcmp>
f0106593:	85 c0                	test   %eax,%eax
f0106595:	74 11                	je     f01065a8 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106597:	c7 04 24 48 8b 10 f0 	movl   $0xf0108b48,(%esp)
f010659e:	e8 4f dc ff ff       	call   f01041f2 <cprintf>
f01065a3:	e9 ab 01 00 00       	jmp    f0106753 <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01065a8:	66 8b 73 04          	mov    0x4(%ebx),%si
f01065ac:	0f b7 d6             	movzwl %si,%edx
f01065af:	89 d8                	mov    %ebx,%eax
f01065b1:	e8 02 fe ff ff       	call   f01063b8 <sum>
f01065b6:	84 c0                	test   %al,%al
f01065b8:	74 11                	je     f01065cb <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f01065ba:	c7 04 24 7c 8b 10 f0 	movl   $0xf0108b7c,(%esp)
f01065c1:	e8 2c dc ff ff       	call   f01041f2 <cprintf>
f01065c6:	e9 88 01 00 00       	jmp    f0106753 <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01065cb:	8a 43 06             	mov    0x6(%ebx),%al
f01065ce:	3c 01                	cmp    $0x1,%al
f01065d0:	74 1c                	je     f01065ee <mp_init+0x162>
f01065d2:	3c 04                	cmp    $0x4,%al
f01065d4:	74 18                	je     f01065ee <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01065d6:	0f b6 c0             	movzbl %al,%eax
f01065d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065dd:	c7 04 24 a0 8b 10 f0 	movl   $0xf0108ba0,(%esp)
f01065e4:	e8 09 dc ff ff       	call   f01041f2 <cprintf>
f01065e9:	e9 65 01 00 00       	jmp    f0106753 <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01065ee:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f01065f2:	0f b7 c6             	movzwl %si,%eax
f01065f5:	01 d8                	add    %ebx,%eax
f01065f7:	e8 bc fd ff ff       	call   f01063b8 <sum>
f01065fc:	02 43 2a             	add    0x2a(%ebx),%al
f01065ff:	84 c0                	test   %al,%al
f0106601:	74 11                	je     f0106614 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106603:	c7 04 24 c0 8b 10 f0 	movl   $0xf0108bc0,(%esp)
f010660a:	e8 e3 db ff ff       	call   f01041f2 <cprintf>
f010660f:	e9 3f 01 00 00       	jmp    f0106753 <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106614:	85 db                	test   %ebx,%ebx
f0106616:	0f 84 37 01 00 00    	je     f0106753 <mp_init+0x2c7>
		return;
	ismp = 1;
f010661c:	c7 05 00 30 33 f0 01 	movl   $0x1,0xf0333000
f0106623:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106626:	8b 43 24             	mov    0x24(%ebx),%eax
f0106629:	a3 00 40 37 f0       	mov    %eax,0xf0374000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010662e:	8d 73 2c             	lea    0x2c(%ebx),%esi
f0106631:	bf 00 00 00 00       	mov    $0x0,%edi
f0106636:	e9 94 00 00 00       	jmp    f01066cf <mp_init+0x243>
		switch (*p) {
f010663b:	8a 06                	mov    (%esi),%al
f010663d:	84 c0                	test   %al,%al
f010663f:	74 06                	je     f0106647 <mp_init+0x1bb>
f0106641:	3c 04                	cmp    $0x4,%al
f0106643:	77 68                	ja     f01066ad <mp_init+0x221>
f0106645:	eb 61                	jmp    f01066a8 <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106647:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f010664b:	74 1d                	je     f010666a <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f010664d:	a1 c4 33 33 f0       	mov    0xf03333c4,%eax
f0106652:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106659:	29 c2                	sub    %eax,%edx
f010665b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010665e:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
f0106665:	a3 c0 33 33 f0       	mov    %eax,0xf03333c0
			if (ncpu < NCPU) {
f010666a:	a1 c4 33 33 f0       	mov    0xf03333c4,%eax
f010666f:	83 f8 07             	cmp    $0x7,%eax
f0106672:	7f 1b                	jg     f010668f <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f0106674:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010667b:	29 c2                	sub    %eax,%edx
f010667d:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106680:	88 04 95 20 30 33 f0 	mov    %al,-0xfcccfe0(,%edx,4)
				ncpu++;
f0106687:	40                   	inc    %eax
f0106688:	a3 c4 33 33 f0       	mov    %eax,0xf03333c4
f010668d:	eb 14                	jmp    f01066a3 <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010668f:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106693:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106697:	c7 04 24 f0 8b 10 f0 	movl   $0xf0108bf0,(%esp)
f010669e:	e8 4f db ff ff       	call   f01041f2 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01066a3:	83 c6 14             	add    $0x14,%esi
			continue;
f01066a6:	eb 26                	jmp    f01066ce <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01066a8:	83 c6 08             	add    $0x8,%esi
			continue;
f01066ab:	eb 21                	jmp    f01066ce <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01066ad:	0f b6 c0             	movzbl %al,%eax
f01066b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066b4:	c7 04 24 18 8c 10 f0 	movl   $0xf0108c18,(%esp)
f01066bb:	e8 32 db ff ff       	call   f01041f2 <cprintf>
			ismp = 0;
f01066c0:	c7 05 00 30 33 f0 00 	movl   $0x0,0xf0333000
f01066c7:	00 00 00 
			i = conf->entry;
f01066ca:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01066ce:	47                   	inc    %edi
f01066cf:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01066d3:	39 c7                	cmp    %eax,%edi
f01066d5:	0f 82 60 ff ff ff    	jb     f010663b <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01066db:	a1 c0 33 33 f0       	mov    0xf03333c0,%eax
f01066e0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01066e7:	83 3d 00 30 33 f0 00 	cmpl   $0x0,0xf0333000
f01066ee:	75 22                	jne    f0106712 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01066f0:	c7 05 c4 33 33 f0 01 	movl   $0x1,0xf03333c4
f01066f7:	00 00 00 
		lapicaddr = 0;
f01066fa:	c7 05 00 40 37 f0 00 	movl   $0x0,0xf0374000
f0106701:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106704:	c7 04 24 38 8c 10 f0 	movl   $0xf0108c38,(%esp)
f010670b:	e8 e2 da ff ff       	call   f01041f2 <cprintf>
		return;
f0106710:	eb 41                	jmp    f0106753 <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106712:	8b 15 c4 33 33 f0    	mov    0xf03333c4,%edx
f0106718:	89 54 24 08          	mov    %edx,0x8(%esp)
f010671c:	0f b6 00             	movzbl (%eax),%eax
f010671f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106723:	c7 04 24 bf 8c 10 f0 	movl   $0xf0108cbf,(%esp)
f010672a:	e8 c3 da ff ff       	call   f01041f2 <cprintf>

	if (mp->imcrp) {
f010672f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106732:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106736:	74 1b                	je     f0106753 <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106738:	c7 04 24 64 8c 10 f0 	movl   $0xf0108c64,(%esp)
f010673f:	e8 ae da ff ff       	call   f01041f2 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106744:	ba 22 00 00 00       	mov    $0x22,%edx
f0106749:	b0 70                	mov    $0x70,%al
f010674b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010674c:	b2 23                	mov    $0x23,%dl
f010674e:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010674f:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106752:	ee                   	out    %al,(%dx)
	}
}
f0106753:	83 c4 2c             	add    $0x2c,%esp
f0106756:	5b                   	pop    %ebx
f0106757:	5e                   	pop    %esi
f0106758:	5f                   	pop    %edi
f0106759:	5d                   	pop    %ebp
f010675a:	c3                   	ret    
	...

f010675c <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010675c:	55                   	push   %ebp
f010675d:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010675f:	c1 e0 02             	shl    $0x2,%eax
f0106762:	03 05 04 40 37 f0    	add    0xf0374004,%eax
f0106768:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010676a:	a1 04 40 37 f0       	mov    0xf0374004,%eax
f010676f:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106772:	5d                   	pop    %ebp
f0106773:	c3                   	ret    

f0106774 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106774:	55                   	push   %ebp
f0106775:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106777:	a1 04 40 37 f0       	mov    0xf0374004,%eax
f010677c:	85 c0                	test   %eax,%eax
f010677e:	74 08                	je     f0106788 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106780:	8b 40 20             	mov    0x20(%eax),%eax
f0106783:	c1 e8 18             	shr    $0x18,%eax
f0106786:	eb 05                	jmp    f010678d <cpunum+0x19>
	return 0;
f0106788:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010678d:	5d                   	pop    %ebp
f010678e:	c3                   	ret    

f010678f <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010678f:	55                   	push   %ebp
f0106790:	89 e5                	mov    %esp,%ebp
f0106792:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106795:	a1 00 40 37 f0       	mov    0xf0374000,%eax
f010679a:	85 c0                	test   %eax,%eax
f010679c:	0f 84 27 01 00 00    	je     f01068c9 <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01067a2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01067a9:	00 
f01067aa:	89 04 24             	mov    %eax,(%esp)
f01067ad:	e8 82 ae ff ff       	call   f0101634 <mmio_map_region>
f01067b2:	a3 04 40 37 f0       	mov    %eax,0xf0374004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01067b7:	ba 27 01 00 00       	mov    $0x127,%edx
f01067bc:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01067c1:	e8 96 ff ff ff       	call   f010675c <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01067c6:	ba 0b 00 00 00       	mov    $0xb,%edx
f01067cb:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01067d0:	e8 87 ff ff ff       	call   f010675c <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01067d5:	ba 20 00 02 00       	mov    $0x20020,%edx
f01067da:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01067df:	e8 78 ff ff ff       	call   f010675c <lapicw>
	lapicw(TICR, 10000000); 
f01067e4:	ba 80 96 98 00       	mov    $0x989680,%edx
f01067e9:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01067ee:	e8 69 ff ff ff       	call   f010675c <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01067f3:	e8 7c ff ff ff       	call   f0106774 <cpunum>
f01067f8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01067ff:	29 c2                	sub    %eax,%edx
f0106801:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106804:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
f010680b:	39 05 c0 33 33 f0    	cmp    %eax,0xf03333c0
f0106811:	74 0f                	je     f0106822 <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f0106813:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106818:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010681d:	e8 3a ff ff ff       	call   f010675c <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106822:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106827:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010682c:	e8 2b ff ff ff       	call   f010675c <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106831:	a1 04 40 37 f0       	mov    0xf0374004,%eax
f0106836:	8b 40 30             	mov    0x30(%eax),%eax
f0106839:	c1 e8 10             	shr    $0x10,%eax
f010683c:	3c 03                	cmp    $0x3,%al
f010683e:	76 0f                	jbe    f010684f <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f0106840:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106845:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010684a:	e8 0d ff ff ff       	call   f010675c <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010684f:	ba 33 00 00 00       	mov    $0x33,%edx
f0106854:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106859:	e8 fe fe ff ff       	call   f010675c <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010685e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106863:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106868:	e8 ef fe ff ff       	call   f010675c <lapicw>
	lapicw(ESR, 0);
f010686d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106872:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106877:	e8 e0 fe ff ff       	call   f010675c <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010687c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106881:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106886:	e8 d1 fe ff ff       	call   f010675c <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010688b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106890:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106895:	e8 c2 fe ff ff       	call   f010675c <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010689a:	ba 00 85 08 00       	mov    $0x88500,%edx
f010689f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068a4:	e8 b3 fe ff ff       	call   f010675c <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01068a9:	8b 15 04 40 37 f0    	mov    0xf0374004,%edx
f01068af:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01068b5:	f6 c4 10             	test   $0x10,%ah
f01068b8:	75 f5                	jne    f01068af <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01068ba:	ba 00 00 00 00       	mov    $0x0,%edx
f01068bf:	b8 20 00 00 00       	mov    $0x20,%eax
f01068c4:	e8 93 fe ff ff       	call   f010675c <lapicw>
}
f01068c9:	c9                   	leave  
f01068ca:	c3                   	ret    

f01068cb <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01068cb:	55                   	push   %ebp
f01068cc:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01068ce:	83 3d 04 40 37 f0 00 	cmpl   $0x0,0xf0374004
f01068d5:	74 0f                	je     f01068e6 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01068d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01068dc:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01068e1:	e8 76 fe ff ff       	call   f010675c <lapicw>
}
f01068e6:	5d                   	pop    %ebp
f01068e7:	c3                   	ret    

f01068e8 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01068e8:	55                   	push   %ebp
f01068e9:	89 e5                	mov    %esp,%ebp
f01068eb:	56                   	push   %esi
f01068ec:	53                   	push   %ebx
f01068ed:	83 ec 10             	sub    $0x10,%esp
f01068f0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01068f3:	8a 5d 08             	mov    0x8(%ebp),%bl
f01068f6:	ba 70 00 00 00       	mov    $0x70,%edx
f01068fb:	b0 0f                	mov    $0xf,%al
f01068fd:	ee                   	out    %al,(%dx)
f01068fe:	b2 71                	mov    $0x71,%dl
f0106900:	b0 0a                	mov    $0xa,%al
f0106902:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106903:	83 3d 88 2e 33 f0 00 	cmpl   $0x0,0xf0332e88
f010690a:	75 24                	jne    f0106930 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010690c:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106913:	00 
f0106914:	c7 44 24 08 88 6e 10 	movl   $0xf0106e88,0x8(%esp)
f010691b:	f0 
f010691c:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106923:	00 
f0106924:	c7 04 24 dc 8c 10 f0 	movl   $0xf0108cdc,(%esp)
f010692b:	e8 10 97 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106930:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106937:	00 00 
	wrv[1] = addr >> 4;
f0106939:	89 f0                	mov    %esi,%eax
f010693b:	c1 e8 04             	shr    $0x4,%eax
f010693e:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106944:	c1 e3 18             	shl    $0x18,%ebx
f0106947:	89 da                	mov    %ebx,%edx
f0106949:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010694e:	e8 09 fe ff ff       	call   f010675c <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106953:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106958:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010695d:	e8 fa fd ff ff       	call   f010675c <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106962:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106967:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010696c:	e8 eb fd ff ff       	call   f010675c <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106971:	c1 ee 0c             	shr    $0xc,%esi
f0106974:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010697a:	89 da                	mov    %ebx,%edx
f010697c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106981:	e8 d6 fd ff ff       	call   f010675c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106986:	89 f2                	mov    %esi,%edx
f0106988:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010698d:	e8 ca fd ff ff       	call   f010675c <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106992:	89 da                	mov    %ebx,%edx
f0106994:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106999:	e8 be fd ff ff       	call   f010675c <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010699e:	89 f2                	mov    %esi,%edx
f01069a0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069a5:	e8 b2 fd ff ff       	call   f010675c <lapicw>
		microdelay(200);
	}
}
f01069aa:	83 c4 10             	add    $0x10,%esp
f01069ad:	5b                   	pop    %ebx
f01069ae:	5e                   	pop    %esi
f01069af:	5d                   	pop    %ebp
f01069b0:	c3                   	ret    

f01069b1 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01069b1:	55                   	push   %ebp
f01069b2:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01069b4:	8b 55 08             	mov    0x8(%ebp),%edx
f01069b7:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01069bd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069c2:	e8 95 fd ff ff       	call   f010675c <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01069c7:	8b 15 04 40 37 f0    	mov    0xf0374004,%edx
f01069cd:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01069d3:	f6 c4 10             	test   $0x10,%ah
f01069d6:	75 f5                	jne    f01069cd <lapic_ipi+0x1c>
		;
}
f01069d8:	5d                   	pop    %ebp
f01069d9:	c3                   	ret    
	...

f01069dc <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01069dc:	55                   	push   %ebp
f01069dd:	89 e5                	mov    %esp,%ebp
f01069df:	53                   	push   %ebx
f01069e0:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01069e3:	83 38 00             	cmpl   $0x0,(%eax)
f01069e6:	74 25                	je     f0106a0d <holding+0x31>
f01069e8:	8b 58 08             	mov    0x8(%eax),%ebx
f01069eb:	e8 84 fd ff ff       	call   f0106774 <cpunum>
f01069f0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01069f7:	29 c2                	sub    %eax,%edx
f01069f9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01069fc:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106a03:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106a05:	0f 94 c0             	sete   %al
f0106a08:	0f b6 c0             	movzbl %al,%eax
f0106a0b:	eb 05                	jmp    f0106a12 <holding+0x36>
f0106a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106a12:	83 c4 04             	add    $0x4,%esp
f0106a15:	5b                   	pop    %ebx
f0106a16:	5d                   	pop    %ebp
f0106a17:	c3                   	ret    

f0106a18 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106a18:	55                   	push   %ebp
f0106a19:	89 e5                	mov    %esp,%ebp
f0106a1b:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106a1e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106a24:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106a27:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106a2a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106a31:	5d                   	pop    %ebp
f0106a32:	c3                   	ret    

f0106a33 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106a33:	55                   	push   %ebp
f0106a34:	89 e5                	mov    %esp,%ebp
f0106a36:	53                   	push   %ebx
f0106a37:	83 ec 24             	sub    $0x24,%esp
f0106a3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106a3d:	89 d8                	mov    %ebx,%eax
f0106a3f:	e8 98 ff ff ff       	call   f01069dc <holding>
f0106a44:	85 c0                	test   %eax,%eax
f0106a46:	74 30                	je     f0106a78 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106a48:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106a4b:	e8 24 fd ff ff       	call   f0106774 <cpunum>
f0106a50:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106a54:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a58:	c7 44 24 08 ec 8c 10 	movl   $0xf0108cec,0x8(%esp)
f0106a5f:	f0 
f0106a60:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106a67:	00 
f0106a68:	c7 04 24 50 8d 10 f0 	movl   $0xf0108d50,(%esp)
f0106a6f:	e8 cc 95 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106a74:	f3 90                	pause  
f0106a76:	eb 05                	jmp    f0106a7d <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106a78:	ba 01 00 00 00       	mov    $0x1,%edx
f0106a7d:	89 d0                	mov    %edx,%eax
f0106a7f:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106a82:	85 c0                	test   %eax,%eax
f0106a84:	75 ee                	jne    f0106a74 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106a86:	e8 e9 fc ff ff       	call   f0106774 <cpunum>
f0106a8b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106a92:	29 c2                	sub    %eax,%edx
f0106a94:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a97:	8d 04 85 20 30 33 f0 	lea    -0xfcccfe0(,%eax,4),%eax
f0106a9e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106aa1:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106aa4:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106aa6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106aab:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106ab1:	76 10                	jbe    f0106ac3 <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106ab3:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106ab6:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106ab9:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106abb:	40                   	inc    %eax
f0106abc:	83 f8 0a             	cmp    $0xa,%eax
f0106abf:	75 ea                	jne    f0106aab <spin_lock+0x78>
f0106ac1:	eb 0d                	jmp    f0106ad0 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106ac3:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106aca:	40                   	inc    %eax
f0106acb:	83 f8 09             	cmp    $0x9,%eax
f0106ace:	7e f3                	jle    f0106ac3 <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106ad0:	83 c4 24             	add    $0x24,%esp
f0106ad3:	5b                   	pop    %ebx
f0106ad4:	5d                   	pop    %ebp
f0106ad5:	c3                   	ret    

f0106ad6 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106ad6:	55                   	push   %ebp
f0106ad7:	89 e5                	mov    %esp,%ebp
f0106ad9:	57                   	push   %edi
f0106ada:	56                   	push   %esi
f0106adb:	53                   	push   %ebx
f0106adc:	83 ec 7c             	sub    $0x7c,%esp
f0106adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106ae2:	89 d8                	mov    %ebx,%eax
f0106ae4:	e8 f3 fe ff ff       	call   f01069dc <holding>
f0106ae9:	85 c0                	test   %eax,%eax
f0106aeb:	0f 85 d3 00 00 00    	jne    f0106bc4 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106af1:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106af8:	00 
f0106af9:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106afc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b00:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106b03:	89 34 24             	mov    %esi,(%esp)
f0106b06:	e8 85 f6 ff ff       	call   f0106190 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106b0b:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106b0e:	0f b6 38             	movzbl (%eax),%edi
f0106b11:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106b14:	e8 5b fc ff ff       	call   f0106774 <cpunum>
f0106b19:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106b1d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106b21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b25:	c7 04 24 18 8d 10 f0 	movl   $0xf0108d18,(%esp)
f0106b2c:	e8 c1 d6 ff ff       	call   f01041f2 <cprintf>
f0106b31:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106b33:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106b36:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106b39:	89 c7                	mov    %eax,%edi
f0106b3b:	eb 63                	jmp    f0106ba0 <spin_unlock+0xca>
f0106b3d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106b41:	89 04 24             	mov    %eax,(%esp)
f0106b44:	e8 34 eb ff ff       	call   f010567d <debuginfo_eip>
f0106b49:	85 c0                	test   %eax,%eax
f0106b4b:	78 39                	js     f0106b86 <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106b4d:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106b4f:	89 c2                	mov    %eax,%edx
f0106b51:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106b54:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106b58:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106b5b:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106b5f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106b62:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106b66:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106b69:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106b6d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106b70:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b78:	c7 04 24 60 8d 10 f0 	movl   $0xf0108d60,(%esp)
f0106b7f:	e8 6e d6 ff ff       	call   f01041f2 <cprintf>
f0106b84:	eb 12                	jmp    f0106b98 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106b86:	8b 06                	mov    (%esi),%eax
f0106b88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b8c:	c7 04 24 77 8d 10 f0 	movl   $0xf0108d77,(%esp)
f0106b93:	e8 5a d6 ff ff       	call   f01041f2 <cprintf>
f0106b98:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b9b:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106b9e:	74 08                	je     f0106ba8 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106ba0:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106ba2:	8b 03                	mov    (%ebx),%eax
f0106ba4:	85 c0                	test   %eax,%eax
f0106ba6:	75 95                	jne    f0106b3d <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106ba8:	c7 44 24 08 7f 8d 10 	movl   $0xf0108d7f,0x8(%esp)
f0106baf:	f0 
f0106bb0:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106bb7:	00 
f0106bb8:	c7 04 24 50 8d 10 f0 	movl   $0xf0108d50,(%esp)
f0106bbf:	e8 7c 94 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106bc4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106bcb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0106bd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0106bd7:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106bda:	83 c4 7c             	add    $0x7c,%esp
f0106bdd:	5b                   	pop    %ebx
f0106bde:	5e                   	pop    %esi
f0106bdf:	5f                   	pop    %edi
f0106be0:	5d                   	pop    %ebp
f0106be1:	c3                   	ret    
	...

f0106be4 <__udivdi3>:
f0106be4:	55                   	push   %ebp
f0106be5:	57                   	push   %edi
f0106be6:	56                   	push   %esi
f0106be7:	83 ec 10             	sub    $0x10,%esp
f0106bea:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106bee:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106bf2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106bf6:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0106bfa:	89 cd                	mov    %ecx,%ebp
f0106bfc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0106c00:	85 c0                	test   %eax,%eax
f0106c02:	75 2c                	jne    f0106c30 <__udivdi3+0x4c>
f0106c04:	39 f9                	cmp    %edi,%ecx
f0106c06:	77 68                	ja     f0106c70 <__udivdi3+0x8c>
f0106c08:	85 c9                	test   %ecx,%ecx
f0106c0a:	75 0b                	jne    f0106c17 <__udivdi3+0x33>
f0106c0c:	b8 01 00 00 00       	mov    $0x1,%eax
f0106c11:	31 d2                	xor    %edx,%edx
f0106c13:	f7 f1                	div    %ecx
f0106c15:	89 c1                	mov    %eax,%ecx
f0106c17:	31 d2                	xor    %edx,%edx
f0106c19:	89 f8                	mov    %edi,%eax
f0106c1b:	f7 f1                	div    %ecx
f0106c1d:	89 c7                	mov    %eax,%edi
f0106c1f:	89 f0                	mov    %esi,%eax
f0106c21:	f7 f1                	div    %ecx
f0106c23:	89 c6                	mov    %eax,%esi
f0106c25:	89 f0                	mov    %esi,%eax
f0106c27:	89 fa                	mov    %edi,%edx
f0106c29:	83 c4 10             	add    $0x10,%esp
f0106c2c:	5e                   	pop    %esi
f0106c2d:	5f                   	pop    %edi
f0106c2e:	5d                   	pop    %ebp
f0106c2f:	c3                   	ret    
f0106c30:	39 f8                	cmp    %edi,%eax
f0106c32:	77 2c                	ja     f0106c60 <__udivdi3+0x7c>
f0106c34:	0f bd f0             	bsr    %eax,%esi
f0106c37:	83 f6 1f             	xor    $0x1f,%esi
f0106c3a:	75 4c                	jne    f0106c88 <__udivdi3+0xa4>
f0106c3c:	39 f8                	cmp    %edi,%eax
f0106c3e:	bf 00 00 00 00       	mov    $0x0,%edi
f0106c43:	72 0a                	jb     f0106c4f <__udivdi3+0x6b>
f0106c45:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106c49:	0f 87 ad 00 00 00    	ja     f0106cfc <__udivdi3+0x118>
f0106c4f:	be 01 00 00 00       	mov    $0x1,%esi
f0106c54:	89 f0                	mov    %esi,%eax
f0106c56:	89 fa                	mov    %edi,%edx
f0106c58:	83 c4 10             	add    $0x10,%esp
f0106c5b:	5e                   	pop    %esi
f0106c5c:	5f                   	pop    %edi
f0106c5d:	5d                   	pop    %ebp
f0106c5e:	c3                   	ret    
f0106c5f:	90                   	nop
f0106c60:	31 ff                	xor    %edi,%edi
f0106c62:	31 f6                	xor    %esi,%esi
f0106c64:	89 f0                	mov    %esi,%eax
f0106c66:	89 fa                	mov    %edi,%edx
f0106c68:	83 c4 10             	add    $0x10,%esp
f0106c6b:	5e                   	pop    %esi
f0106c6c:	5f                   	pop    %edi
f0106c6d:	5d                   	pop    %ebp
f0106c6e:	c3                   	ret    
f0106c6f:	90                   	nop
f0106c70:	89 fa                	mov    %edi,%edx
f0106c72:	89 f0                	mov    %esi,%eax
f0106c74:	f7 f1                	div    %ecx
f0106c76:	89 c6                	mov    %eax,%esi
f0106c78:	31 ff                	xor    %edi,%edi
f0106c7a:	89 f0                	mov    %esi,%eax
f0106c7c:	89 fa                	mov    %edi,%edx
f0106c7e:	83 c4 10             	add    $0x10,%esp
f0106c81:	5e                   	pop    %esi
f0106c82:	5f                   	pop    %edi
f0106c83:	5d                   	pop    %ebp
f0106c84:	c3                   	ret    
f0106c85:	8d 76 00             	lea    0x0(%esi),%esi
f0106c88:	89 f1                	mov    %esi,%ecx
f0106c8a:	d3 e0                	shl    %cl,%eax
f0106c8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106c90:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c95:	29 f0                	sub    %esi,%eax
f0106c97:	89 ea                	mov    %ebp,%edx
f0106c99:	88 c1                	mov    %al,%cl
f0106c9b:	d3 ea                	shr    %cl,%edx
f0106c9d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0106ca1:	09 ca                	or     %ecx,%edx
f0106ca3:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106ca7:	89 f1                	mov    %esi,%ecx
f0106ca9:	d3 e5                	shl    %cl,%ebp
f0106cab:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0106caf:	89 fd                	mov    %edi,%ebp
f0106cb1:	88 c1                	mov    %al,%cl
f0106cb3:	d3 ed                	shr    %cl,%ebp
f0106cb5:	89 fa                	mov    %edi,%edx
f0106cb7:	89 f1                	mov    %esi,%ecx
f0106cb9:	d3 e2                	shl    %cl,%edx
f0106cbb:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106cbf:	88 c1                	mov    %al,%cl
f0106cc1:	d3 ef                	shr    %cl,%edi
f0106cc3:	09 d7                	or     %edx,%edi
f0106cc5:	89 f8                	mov    %edi,%eax
f0106cc7:	89 ea                	mov    %ebp,%edx
f0106cc9:	f7 74 24 08          	divl   0x8(%esp)
f0106ccd:	89 d1                	mov    %edx,%ecx
f0106ccf:	89 c7                	mov    %eax,%edi
f0106cd1:	f7 64 24 0c          	mull   0xc(%esp)
f0106cd5:	39 d1                	cmp    %edx,%ecx
f0106cd7:	72 17                	jb     f0106cf0 <__udivdi3+0x10c>
f0106cd9:	74 09                	je     f0106ce4 <__udivdi3+0x100>
f0106cdb:	89 fe                	mov    %edi,%esi
f0106cdd:	31 ff                	xor    %edi,%edi
f0106cdf:	e9 41 ff ff ff       	jmp    f0106c25 <__udivdi3+0x41>
f0106ce4:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106ce8:	89 f1                	mov    %esi,%ecx
f0106cea:	d3 e2                	shl    %cl,%edx
f0106cec:	39 c2                	cmp    %eax,%edx
f0106cee:	73 eb                	jae    f0106cdb <__udivdi3+0xf7>
f0106cf0:	8d 77 ff             	lea    -0x1(%edi),%esi
f0106cf3:	31 ff                	xor    %edi,%edi
f0106cf5:	e9 2b ff ff ff       	jmp    f0106c25 <__udivdi3+0x41>
f0106cfa:	66 90                	xchg   %ax,%ax
f0106cfc:	31 f6                	xor    %esi,%esi
f0106cfe:	e9 22 ff ff ff       	jmp    f0106c25 <__udivdi3+0x41>
	...

f0106d04 <__umoddi3>:
f0106d04:	55                   	push   %ebp
f0106d05:	57                   	push   %edi
f0106d06:	56                   	push   %esi
f0106d07:	83 ec 20             	sub    $0x20,%esp
f0106d0a:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106d0e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f0106d12:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106d16:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106d1a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106d1e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0106d22:	89 c7                	mov    %eax,%edi
f0106d24:	89 f2                	mov    %esi,%edx
f0106d26:	85 ed                	test   %ebp,%ebp
f0106d28:	75 16                	jne    f0106d40 <__umoddi3+0x3c>
f0106d2a:	39 f1                	cmp    %esi,%ecx
f0106d2c:	0f 86 a6 00 00 00    	jbe    f0106dd8 <__umoddi3+0xd4>
f0106d32:	f7 f1                	div    %ecx
f0106d34:	89 d0                	mov    %edx,%eax
f0106d36:	31 d2                	xor    %edx,%edx
f0106d38:	83 c4 20             	add    $0x20,%esp
f0106d3b:	5e                   	pop    %esi
f0106d3c:	5f                   	pop    %edi
f0106d3d:	5d                   	pop    %ebp
f0106d3e:	c3                   	ret    
f0106d3f:	90                   	nop
f0106d40:	39 f5                	cmp    %esi,%ebp
f0106d42:	0f 87 ac 00 00 00    	ja     f0106df4 <__umoddi3+0xf0>
f0106d48:	0f bd c5             	bsr    %ebp,%eax
f0106d4b:	83 f0 1f             	xor    $0x1f,%eax
f0106d4e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106d52:	0f 84 a8 00 00 00    	je     f0106e00 <__umoddi3+0xfc>
f0106d58:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d5c:	d3 e5                	shl    %cl,%ebp
f0106d5e:	bf 20 00 00 00       	mov    $0x20,%edi
f0106d63:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0106d67:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106d6b:	89 f9                	mov    %edi,%ecx
f0106d6d:	d3 e8                	shr    %cl,%eax
f0106d6f:	09 e8                	or     %ebp,%eax
f0106d71:	89 44 24 18          	mov    %eax,0x18(%esp)
f0106d75:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106d79:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d7d:	d3 e0                	shl    %cl,%eax
f0106d7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106d83:	89 f2                	mov    %esi,%edx
f0106d85:	d3 e2                	shl    %cl,%edx
f0106d87:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106d8b:	d3 e0                	shl    %cl,%eax
f0106d8d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0106d91:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106d95:	89 f9                	mov    %edi,%ecx
f0106d97:	d3 e8                	shr    %cl,%eax
f0106d99:	09 d0                	or     %edx,%eax
f0106d9b:	d3 ee                	shr    %cl,%esi
f0106d9d:	89 f2                	mov    %esi,%edx
f0106d9f:	f7 74 24 18          	divl   0x18(%esp)
f0106da3:	89 d6                	mov    %edx,%esi
f0106da5:	f7 64 24 0c          	mull   0xc(%esp)
f0106da9:	89 c5                	mov    %eax,%ebp
f0106dab:	89 d1                	mov    %edx,%ecx
f0106dad:	39 d6                	cmp    %edx,%esi
f0106daf:	72 67                	jb     f0106e18 <__umoddi3+0x114>
f0106db1:	74 75                	je     f0106e28 <__umoddi3+0x124>
f0106db3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106db7:	29 e8                	sub    %ebp,%eax
f0106db9:	19 ce                	sbb    %ecx,%esi
f0106dbb:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106dbf:	d3 e8                	shr    %cl,%eax
f0106dc1:	89 f2                	mov    %esi,%edx
f0106dc3:	89 f9                	mov    %edi,%ecx
f0106dc5:	d3 e2                	shl    %cl,%edx
f0106dc7:	09 d0                	or     %edx,%eax
f0106dc9:	89 f2                	mov    %esi,%edx
f0106dcb:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106dcf:	d3 ea                	shr    %cl,%edx
f0106dd1:	83 c4 20             	add    $0x20,%esp
f0106dd4:	5e                   	pop    %esi
f0106dd5:	5f                   	pop    %edi
f0106dd6:	5d                   	pop    %ebp
f0106dd7:	c3                   	ret    
f0106dd8:	85 c9                	test   %ecx,%ecx
f0106dda:	75 0b                	jne    f0106de7 <__umoddi3+0xe3>
f0106ddc:	b8 01 00 00 00       	mov    $0x1,%eax
f0106de1:	31 d2                	xor    %edx,%edx
f0106de3:	f7 f1                	div    %ecx
f0106de5:	89 c1                	mov    %eax,%ecx
f0106de7:	89 f0                	mov    %esi,%eax
f0106de9:	31 d2                	xor    %edx,%edx
f0106deb:	f7 f1                	div    %ecx
f0106ded:	89 f8                	mov    %edi,%eax
f0106def:	e9 3e ff ff ff       	jmp    f0106d32 <__umoddi3+0x2e>
f0106df4:	89 f2                	mov    %esi,%edx
f0106df6:	83 c4 20             	add    $0x20,%esp
f0106df9:	5e                   	pop    %esi
f0106dfa:	5f                   	pop    %edi
f0106dfb:	5d                   	pop    %ebp
f0106dfc:	c3                   	ret    
f0106dfd:	8d 76 00             	lea    0x0(%esi),%esi
f0106e00:	39 f5                	cmp    %esi,%ebp
f0106e02:	72 04                	jb     f0106e08 <__umoddi3+0x104>
f0106e04:	39 f9                	cmp    %edi,%ecx
f0106e06:	77 06                	ja     f0106e0e <__umoddi3+0x10a>
f0106e08:	89 f2                	mov    %esi,%edx
f0106e0a:	29 cf                	sub    %ecx,%edi
f0106e0c:	19 ea                	sbb    %ebp,%edx
f0106e0e:	89 f8                	mov    %edi,%eax
f0106e10:	83 c4 20             	add    $0x20,%esp
f0106e13:	5e                   	pop    %esi
f0106e14:	5f                   	pop    %edi
f0106e15:	5d                   	pop    %ebp
f0106e16:	c3                   	ret    
f0106e17:	90                   	nop
f0106e18:	89 d1                	mov    %edx,%ecx
f0106e1a:	89 c5                	mov    %eax,%ebp
f0106e1c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0106e20:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0106e24:	eb 8d                	jmp    f0106db3 <__umoddi3+0xaf>
f0106e26:	66 90                	xchg   %ax,%ax
f0106e28:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0106e2c:	72 ea                	jb     f0106e18 <__umoddi3+0x114>
f0106e2e:	89 f1                	mov    %esi,%ecx
f0106e30:	eb 81                	jmp    f0106db3 <__umoddi3+0xaf>
