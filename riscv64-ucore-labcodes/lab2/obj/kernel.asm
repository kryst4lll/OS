
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	1b3010ef          	jal	ra,ffffffffc02019fc <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	9be50513          	addi	a0,a0,-1602 # ffffffffc0201a10 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	2c0010ef          	jal	ra,ffffffffc0201326 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	480010ef          	jal	ra,ffffffffc0201526 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	44a010ef          	jal	ra,ffffffffc0201526 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201a30 <etext+0x22>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0201a50 <etext+0x42>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	8b058593          	addi	a1,a1,-1872 # ffffffffc0201a0e <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201a70 <etext+0x62>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	91650513          	addi	a0,a0,-1770 # ffffffffc0201a90 <etext+0x82>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	92250513          	addi	a0,a0,-1758 # ffffffffc0201ab0 <etext+0xa2>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6d558593          	addi	a1,a1,1749 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	91450513          	addi	a0,a0,-1772 # ffffffffc0201ad0 <etext+0xc2>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	93660613          	addi	a2,a2,-1738 # ffffffffc0201b00 <etext+0xf2>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	94250513          	addi	a0,a0,-1726 # ffffffffc0201b18 <etext+0x10a>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	94a60613          	addi	a2,a2,-1718 # ffffffffc0201b30 <etext+0x122>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	96258593          	addi	a1,a1,-1694 # ffffffffc0201b50 <etext+0x142>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	96250513          	addi	a0,a0,-1694 # ffffffffc0201b58 <etext+0x14a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	96460613          	addi	a2,a2,-1692 # ffffffffc0201b68 <etext+0x15a>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	98458593          	addi	a1,a1,-1660 # ffffffffc0201b90 <etext+0x182>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	94450513          	addi	a0,a0,-1724 # ffffffffc0201b58 <etext+0x14a>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	98060613          	addi	a2,a2,-1664 # ffffffffc0201ba0 <etext+0x192>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	99858593          	addi	a1,a1,-1640 # ffffffffc0201bc0 <etext+0x1b2>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	92850513          	addi	a0,a0,-1752 # ffffffffc0201b58 <etext+0x14a>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	96650513          	addi	a0,a0,-1690 # ffffffffc0201bd0 <etext+0x1c2>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	96c50513          	addi	a0,a0,-1684 # ffffffffc0201bf8 <etext+0x1ea>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	9c6c0c13          	addi	s8,s8,-1594 # ffffffffc0201c68 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	97690913          	addi	s2,s2,-1674 # ffffffffc0201c20 <etext+0x212>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	97648493          	addi	s1,s1,-1674 # ffffffffc0201c28 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	974b0b13          	addi	s6,s6,-1676 # ffffffffc0201c30 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	88ca0a13          	addi	s4,s4,-1908 # ffffffffc0201b50 <etext+0x142>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	5d8010ef          	jal	ra,ffffffffc02018a8 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	982d0d13          	addi	s10,s10,-1662 # ffffffffc0201c68 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	6d4010ef          	jal	ra,ffffffffc02019c8 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	6c0010ef          	jal	ra,ffffffffc02019c8 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	6a0010ef          	jal	ra,ffffffffc02019e6 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	662010ef          	jal	ra,ffffffffc02019e6 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	8b250513          	addi	a0,a0,-1870 # ffffffffc0201c50 <etext+0x242>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201cb0 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	70850513          	addi	a0,a0,1800 # ffffffffc0201af8 <etext+0xea>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	556010ef          	jal	ra,ffffffffc0201976 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	8a250513          	addi	a0,a0,-1886 # ffffffffc0201cd0 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	5300106f          	j	ffffffffc0201976 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	50c0106f          	j	ffffffffc020195c <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	53c0106f          	j	ffffffffc0201990 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	36478793          	addi	a5,a5,868 # ffffffffc02007cc <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	87250513          	addi	a0,a0,-1934 # ffffffffc0201cf0 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	87a50513          	addi	a0,a0,-1926 # ffffffffc0201d08 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	88450513          	addi	a0,a0,-1916 # ffffffffc0201d20 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	88e50513          	addi	a0,a0,-1906 # ffffffffc0201d38 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	89850513          	addi	a0,a0,-1896 # ffffffffc0201d50 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	8a250513          	addi	a0,a0,-1886 # ffffffffc0201d68 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0201d80 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	8b650513          	addi	a0,a0,-1866 # ffffffffc0201d98 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	8c050513          	addi	a0,a0,-1856 # ffffffffc0201db0 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0201dc8 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	8d450513          	addi	a0,a0,-1836 # ffffffffc0201de0 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	8de50513          	addi	a0,a0,-1826 # ffffffffc0201df8 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0201e10 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	8f250513          	addi	a0,a0,-1806 # ffffffffc0201e28 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0201e40 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	90650513          	addi	a0,a0,-1786 # ffffffffc0201e58 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	91050513          	addi	a0,a0,-1776 # ffffffffc0201e70 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	91a50513          	addi	a0,a0,-1766 # ffffffffc0201e88 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	92450513          	addi	a0,a0,-1756 # ffffffffc0201ea0 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201eb8 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	93850513          	addi	a0,a0,-1736 # ffffffffc0201ed0 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	94250513          	addi	a0,a0,-1726 # ffffffffc0201ee8 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	94c50513          	addi	a0,a0,-1716 # ffffffffc0201f00 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	95650513          	addi	a0,a0,-1706 # ffffffffc0201f18 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	96050513          	addi	a0,a0,-1696 # ffffffffc0201f30 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	96a50513          	addi	a0,a0,-1686 # ffffffffc0201f48 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	97450513          	addi	a0,a0,-1676 # ffffffffc0201f60 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	97e50513          	addi	a0,a0,-1666 # ffffffffc0201f78 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	98850513          	addi	a0,a0,-1656 # ffffffffc0201f90 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	99250513          	addi	a0,a0,-1646 # ffffffffc0201fa8 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	99c50513          	addi	a0,a0,-1636 # ffffffffc0201fc0 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201fd8 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	9a650513          	addi	a0,a0,-1626 # ffffffffc0201ff0 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	9a650513          	addi	a0,a0,-1626 # ffffffffc0202008 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0202020 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	9b650513          	addi	a0,a0,-1610 # ffffffffc0202038 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0202050 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	a8070713          	addi	a4,a4,-1408 # ffffffffc0202130 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	a0650513          	addi	a0,a0,-1530 # ffffffffc02020c8 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02020a8 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	99250513          	addi	a0,a0,-1646 # ffffffffc0202068 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	a0850513          	addi	a0,a0,-1528 # ffffffffc02020e8 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	a0050513          	addi	a0,a0,-1536 # ffffffffc0202110 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	96e50513          	addi	a0,a0,-1682 # ffffffffc0202088 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	9d450513          	addi	a0,a0,-1580 # ffffffffc0202100 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020073c:	1141                	addi	sp,sp,-16
ffffffffc020073e:	e022                	sd	s0,0(sp)
ffffffffc0200740:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
ffffffffc0200742:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200744:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200746:	04e78663          	beq	a5,a4,ffffffffc0200792 <exception_handler+0x5a>
ffffffffc020074a:	02f76c63          	bltu	a4,a5,ffffffffc0200782 <exception_handler+0x4a>
ffffffffc020074e:	4709                	li	a4,2
ffffffffc0200750:	02e79563          	bne	a5,a4,ffffffffc020077a <exception_handler+0x42>
             /* LAB1 CHALLENGE3   2213211,2211871 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type:Illegal instruction\n");
ffffffffc0200754:	00002517          	auipc	a0,0x2
ffffffffc0200758:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0202160 <commands+0x4f8>
ffffffffc020075c:	957ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("Illegal instruction caught at 0x%x\n", tf->epc);    
ffffffffc0200760:	10843583          	ld	a1,264(s0)
ffffffffc0200764:	00002517          	auipc	a0,0x2
ffffffffc0200768:	a2450513          	addi	a0,a0,-1500 # ffffffffc0202188 <commands+0x520>
ffffffffc020076c:	947ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            tf->epc += 4; // 指令宽度为4字节           
ffffffffc0200770:	10843783          	ld	a5,264(s0)
ffffffffc0200774:	0791                	addi	a5,a5,4
ffffffffc0200776:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020077a:	60a2                	ld	ra,8(sp)
ffffffffc020077c:	6402                	ld	s0,0(sp)
ffffffffc020077e:	0141                	addi	sp,sp,16
ffffffffc0200780:	8082                	ret
    switch (tf->cause) {
ffffffffc0200782:	17f1                	addi	a5,a5,-4
ffffffffc0200784:	471d                	li	a4,7
ffffffffc0200786:	fef77ae3          	bgeu	a4,a5,ffffffffc020077a <exception_handler+0x42>
}
ffffffffc020078a:	6402                	ld	s0,0(sp)
ffffffffc020078c:	60a2                	ld	ra,8(sp)
ffffffffc020078e:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc0200790:	bd4d                	j	ffffffffc0200642 <print_trapframe>
            cprintf("Exception type: breakpoint\n");            
ffffffffc0200792:	00002517          	auipc	a0,0x2
ffffffffc0200796:	a1e50513          	addi	a0,a0,-1506 # ffffffffc02021b0 <commands+0x548>
ffffffffc020079a:	919ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at 0x%x\n", tf->epc);
ffffffffc020079e:	10843583          	ld	a1,264(s0)
ffffffffc02007a2:	00002517          	auipc	a0,0x2
ffffffffc02007a6:	a2e50513          	addi	a0,a0,-1490 # ffffffffc02021d0 <commands+0x568>
ffffffffc02007aa:	909ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
	        tf->epc += 2; // 指令宽度为2字节         
ffffffffc02007ae:	10843783          	ld	a5,264(s0)
}
ffffffffc02007b2:	60a2                	ld	ra,8(sp)
	        tf->epc += 2; // 指令宽度为2字节         
ffffffffc02007b4:	0789                	addi	a5,a5,2
ffffffffc02007b6:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007ba:	6402                	ld	s0,0(sp)
ffffffffc02007bc:	0141                	addi	sp,sp,16
ffffffffc02007be:	8082                	ret

ffffffffc02007c0 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	0007c363          	bltz	a5,ffffffffc02007ca <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02007c8:	bf85                	j	ffffffffc0200738 <exception_handler>
        interrupt_handler(tf);
ffffffffc02007ca:	bde1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc02007cc <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc02007cc:	14011073          	csrw	sscratch,sp
ffffffffc02007d0:	712d                	addi	sp,sp,-288
ffffffffc02007d2:	e002                	sd	zero,0(sp)
ffffffffc02007d4:	e406                	sd	ra,8(sp)
ffffffffc02007d6:	ec0e                	sd	gp,24(sp)
ffffffffc02007d8:	f012                	sd	tp,32(sp)
ffffffffc02007da:	f416                	sd	t0,40(sp)
ffffffffc02007dc:	f81a                	sd	t1,48(sp)
ffffffffc02007de:	fc1e                	sd	t2,56(sp)
ffffffffc02007e0:	e0a2                	sd	s0,64(sp)
ffffffffc02007e2:	e4a6                	sd	s1,72(sp)
ffffffffc02007e4:	e8aa                	sd	a0,80(sp)
ffffffffc02007e6:	ecae                	sd	a1,88(sp)
ffffffffc02007e8:	f0b2                	sd	a2,96(sp)
ffffffffc02007ea:	f4b6                	sd	a3,104(sp)
ffffffffc02007ec:	f8ba                	sd	a4,112(sp)
ffffffffc02007ee:	fcbe                	sd	a5,120(sp)
ffffffffc02007f0:	e142                	sd	a6,128(sp)
ffffffffc02007f2:	e546                	sd	a7,136(sp)
ffffffffc02007f4:	e94a                	sd	s2,144(sp)
ffffffffc02007f6:	ed4e                	sd	s3,152(sp)
ffffffffc02007f8:	f152                	sd	s4,160(sp)
ffffffffc02007fa:	f556                	sd	s5,168(sp)
ffffffffc02007fc:	f95a                	sd	s6,176(sp)
ffffffffc02007fe:	fd5e                	sd	s7,184(sp)
ffffffffc0200800:	e1e2                	sd	s8,192(sp)
ffffffffc0200802:	e5e6                	sd	s9,200(sp)
ffffffffc0200804:	e9ea                	sd	s10,208(sp)
ffffffffc0200806:	edee                	sd	s11,216(sp)
ffffffffc0200808:	f1f2                	sd	t3,224(sp)
ffffffffc020080a:	f5f6                	sd	t4,232(sp)
ffffffffc020080c:	f9fa                	sd	t5,240(sp)
ffffffffc020080e:	fdfe                	sd	t6,248(sp)
ffffffffc0200810:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200814:	100024f3          	csrr	s1,sstatus
ffffffffc0200818:	14102973          	csrr	s2,sepc
ffffffffc020081c:	143029f3          	csrr	s3,stval
ffffffffc0200820:	14202a73          	csrr	s4,scause
ffffffffc0200824:	e822                	sd	s0,16(sp)
ffffffffc0200826:	e226                	sd	s1,256(sp)
ffffffffc0200828:	e64a                	sd	s2,264(sp)
ffffffffc020082a:	ea4e                	sd	s3,272(sp)
ffffffffc020082c:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc020082e:	850a                	mv	a0,sp
    jal trap
ffffffffc0200830:	f91ff0ef          	jal	ra,ffffffffc02007c0 <trap>

ffffffffc0200834 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200834:	6492                	ld	s1,256(sp)
ffffffffc0200836:	6932                	ld	s2,264(sp)
ffffffffc0200838:	10049073          	csrw	sstatus,s1
ffffffffc020083c:	14191073          	csrw	sepc,s2
ffffffffc0200840:	60a2                	ld	ra,8(sp)
ffffffffc0200842:	61e2                	ld	gp,24(sp)
ffffffffc0200844:	7202                	ld	tp,32(sp)
ffffffffc0200846:	72a2                	ld	t0,40(sp)
ffffffffc0200848:	7342                	ld	t1,48(sp)
ffffffffc020084a:	73e2                	ld	t2,56(sp)
ffffffffc020084c:	6406                	ld	s0,64(sp)
ffffffffc020084e:	64a6                	ld	s1,72(sp)
ffffffffc0200850:	6546                	ld	a0,80(sp)
ffffffffc0200852:	65e6                	ld	a1,88(sp)
ffffffffc0200854:	7606                	ld	a2,96(sp)
ffffffffc0200856:	76a6                	ld	a3,104(sp)
ffffffffc0200858:	7746                	ld	a4,112(sp)
ffffffffc020085a:	77e6                	ld	a5,120(sp)
ffffffffc020085c:	680a                	ld	a6,128(sp)
ffffffffc020085e:	68aa                	ld	a7,136(sp)
ffffffffc0200860:	694a                	ld	s2,144(sp)
ffffffffc0200862:	69ea                	ld	s3,152(sp)
ffffffffc0200864:	7a0a                	ld	s4,160(sp)
ffffffffc0200866:	7aaa                	ld	s5,168(sp)
ffffffffc0200868:	7b4a                	ld	s6,176(sp)
ffffffffc020086a:	7bea                	ld	s7,184(sp)
ffffffffc020086c:	6c0e                	ld	s8,192(sp)
ffffffffc020086e:	6cae                	ld	s9,200(sp)
ffffffffc0200870:	6d4e                	ld	s10,208(sp)
ffffffffc0200872:	6dee                	ld	s11,216(sp)
ffffffffc0200874:	7e0e                	ld	t3,224(sp)
ffffffffc0200876:	7eae                	ld	t4,232(sp)
ffffffffc0200878:	7f4e                	ld	t5,240(sp)
ffffffffc020087a:	7fee                	ld	t6,248(sp)
ffffffffc020087c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020087e:	10200073          	sret

ffffffffc0200882 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200882:	00005797          	auipc	a5,0x5
ffffffffc0200886:	78e78793          	addi	a5,a5,1934 # ffffffffc0206010 <free_area>
ffffffffc020088a:	e79c                	sd	a5,8(a5)
ffffffffc020088c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020088e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200892:	8082                	ret

ffffffffc0200894 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200894:	00005517          	auipc	a0,0x5
ffffffffc0200898:	78c56503          	lwu	a0,1932(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020089c:	8082                	ret

ffffffffc020089e <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020089e:	c14d                	beqz	a0,ffffffffc0200940 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc02008a0:	00005617          	auipc	a2,0x5
ffffffffc02008a4:	77060613          	addi	a2,a2,1904 # ffffffffc0206010 <free_area>
ffffffffc02008a8:	01062803          	lw	a6,16(a2)
ffffffffc02008ac:	86aa                	mv	a3,a0
ffffffffc02008ae:	02081793          	slli	a5,a6,0x20
ffffffffc02008b2:	9381                	srli	a5,a5,0x20
ffffffffc02008b4:	08a7e463          	bltu	a5,a0,ffffffffc020093c <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02008b8:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc02008ba:	0018059b          	addiw	a1,a6,1
ffffffffc02008be:	1582                	slli	a1,a1,0x20
ffffffffc02008c0:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc02008c2:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008c4:	06c78b63          	beq	a5,a2,ffffffffc020093a <best_fit_alloc_pages+0x9c>
        if (p->property >= n) {
ffffffffc02008c8:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02008cc:	00d76763          	bltu	a4,a3,ffffffffc02008da <best_fit_alloc_pages+0x3c>
            if(p->property<min_size){
ffffffffc02008d0:	00b77563          	bgeu	a4,a1,ffffffffc02008da <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc02008d4:	fe878513          	addi	a0,a5,-24
ffffffffc02008d8:	85ba                	mv	a1,a4
ffffffffc02008da:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008dc:	fec796e3          	bne	a5,a2,ffffffffc02008c8 <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc02008e0:	cd29                	beqz	a0,ffffffffc020093a <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02008e2:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc02008e4:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc02008e6:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc02008e8:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02008ec:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02008ee:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc02008f0:	02059793          	slli	a5,a1,0x20
ffffffffc02008f4:	9381                	srli	a5,a5,0x20
ffffffffc02008f6:	02f6f863          	bgeu	a3,a5,ffffffffc0200926 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc02008fa:	00269793          	slli	a5,a3,0x2
ffffffffc02008fe:	97b6                	add	a5,a5,a3
ffffffffc0200900:	078e                	slli	a5,a5,0x3
ffffffffc0200902:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200904:	411585bb          	subw	a1,a1,a7
ffffffffc0200908:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020090a:	4689                	li	a3,2
ffffffffc020090c:	00878593          	addi	a1,a5,8
ffffffffc0200910:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200914:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200916:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc020091a:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc020091e:	e28c                	sd	a1,0(a3)
ffffffffc0200920:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200922:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200924:	ef98                	sd	a4,24(a5)
ffffffffc0200926:	4118083b          	subw	a6,a6,a7
ffffffffc020092a:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020092e:	57f5                	li	a5,-3
ffffffffc0200930:	00850713          	addi	a4,a0,8
ffffffffc0200934:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200938:	8082                	ret
}
ffffffffc020093a:	8082                	ret
        return NULL;
ffffffffc020093c:	4501                	li	a0,0
ffffffffc020093e:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200940:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200942:	00002697          	auipc	a3,0x2
ffffffffc0200946:	8a668693          	addi	a3,a3,-1882 # ffffffffc02021e8 <commands+0x580>
ffffffffc020094a:	00002617          	auipc	a2,0x2
ffffffffc020094e:	8a660613          	addi	a2,a2,-1882 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200952:	06a00593          	li	a1,106
ffffffffc0200956:	00002517          	auipc	a0,0x2
ffffffffc020095a:	8b250513          	addi	a0,a0,-1870 # ffffffffc0202208 <commands+0x5a0>
best_fit_alloc_pages(size_t n) {
ffffffffc020095e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200960:	a4dff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200964 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200964:	715d                	addi	sp,sp,-80
ffffffffc0200966:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200968:	00005417          	auipc	s0,0x5
ffffffffc020096c:	6a840413          	addi	s0,s0,1704 # ffffffffc0206010 <free_area>
ffffffffc0200970:	641c                	ld	a5,8(s0)
ffffffffc0200972:	e486                	sd	ra,72(sp)
ffffffffc0200974:	fc26                	sd	s1,56(sp)
ffffffffc0200976:	f84a                	sd	s2,48(sp)
ffffffffc0200978:	f44e                	sd	s3,40(sp)
ffffffffc020097a:	f052                	sd	s4,32(sp)
ffffffffc020097c:	ec56                	sd	s5,24(sp)
ffffffffc020097e:	e85a                	sd	s6,16(sp)
ffffffffc0200980:	e45e                	sd	s7,8(sp)
ffffffffc0200982:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200984:	26878b63          	beq	a5,s0,ffffffffc0200bfa <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200988:	4481                	li	s1,0
ffffffffc020098a:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020098c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200990:	8b09                	andi	a4,a4,2
ffffffffc0200992:	26070863          	beqz	a4,ffffffffc0200c02 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200996:	ff87a703          	lw	a4,-8(a5)
ffffffffc020099a:	679c                	ld	a5,8(a5)
ffffffffc020099c:	2905                	addiw	s2,s2,1
ffffffffc020099e:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009a0:	fe8796e3          	bne	a5,s0,ffffffffc020098c <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02009a4:	89a6                	mv	s3,s1
ffffffffc02009a6:	147000ef          	jal	ra,ffffffffc02012ec <nr_free_pages>
ffffffffc02009aa:	33351c63          	bne	a0,s3,ffffffffc0200ce2 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02009ae:	4505                	li	a0,1
ffffffffc02009b0:	0bf000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc02009b4:	8a2a                	mv	s4,a0
ffffffffc02009b6:	36050663          	beqz	a0,ffffffffc0200d22 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02009ba:	4505                	li	a0,1
ffffffffc02009bc:	0b3000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc02009c0:	89aa                	mv	s3,a0
ffffffffc02009c2:	34050063          	beqz	a0,ffffffffc0200d02 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009c6:	4505                	li	a0,1
ffffffffc02009c8:	0a7000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc02009cc:	8aaa                	mv	s5,a0
ffffffffc02009ce:	2c050a63          	beqz	a0,ffffffffc0200ca2 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02009d2:	253a0863          	beq	s4,s3,ffffffffc0200c22 <best_fit_check+0x2be>
ffffffffc02009d6:	24aa0663          	beq	s4,a0,ffffffffc0200c22 <best_fit_check+0x2be>
ffffffffc02009da:	24a98463          	beq	s3,a0,ffffffffc0200c22 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02009de:	000a2783          	lw	a5,0(s4)
ffffffffc02009e2:	26079063          	bnez	a5,ffffffffc0200c42 <best_fit_check+0x2de>
ffffffffc02009e6:	0009a783          	lw	a5,0(s3)
ffffffffc02009ea:	24079c63          	bnez	a5,ffffffffc0200c42 <best_fit_check+0x2de>
ffffffffc02009ee:	411c                	lw	a5,0(a0)
ffffffffc02009f0:	24079963          	bnez	a5,ffffffffc0200c42 <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009f4:	00006797          	auipc	a5,0x6
ffffffffc02009f8:	a4c7b783          	ld	a5,-1460(a5) # ffffffffc0206440 <pages>
ffffffffc02009fc:	40fa0733          	sub	a4,s4,a5
ffffffffc0200a00:	870d                	srai	a4,a4,0x3
ffffffffc0200a02:	00002597          	auipc	a1,0x2
ffffffffc0200a06:	ed65b583          	ld	a1,-298(a1) # ffffffffc02028d8 <error_string+0x38>
ffffffffc0200a0a:	02b70733          	mul	a4,a4,a1
ffffffffc0200a0e:	00002617          	auipc	a2,0x2
ffffffffc0200a12:	ed263603          	ld	a2,-302(a2) # ffffffffc02028e0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200a16:	00006697          	auipc	a3,0x6
ffffffffc0200a1a:	a226b683          	ld	a3,-1502(a3) # ffffffffc0206438 <npage>
ffffffffc0200a1e:	06b2                	slli	a3,a3,0xc
ffffffffc0200a20:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a22:	0732                	slli	a4,a4,0xc
ffffffffc0200a24:	22d77f63          	bgeu	a4,a3,ffffffffc0200c62 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a28:	40f98733          	sub	a4,s3,a5
ffffffffc0200a2c:	870d                	srai	a4,a4,0x3
ffffffffc0200a2e:	02b70733          	mul	a4,a4,a1
ffffffffc0200a32:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a34:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200a36:	3ed77663          	bgeu	a4,a3,ffffffffc0200e22 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a3a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a3e:	878d                	srai	a5,a5,0x3
ffffffffc0200a40:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a44:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a46:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a48:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200e02 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200a4c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a4e:	00043c03          	ld	s8,0(s0)
ffffffffc0200a52:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a56:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200a5a:	e400                	sd	s0,8(s0)
ffffffffc0200a5c:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200a5e:	00005797          	auipc	a5,0x5
ffffffffc0200a62:	5c07a123          	sw	zero,1474(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a66:	009000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200a6a:	36051c63          	bnez	a0,ffffffffc0200de2 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200a6e:	4585                	li	a1,1
ffffffffc0200a70:	8552                	mv	a0,s4
ffffffffc0200a72:	03b000ef          	jal	ra,ffffffffc02012ac <free_pages>
    free_page(p1);
ffffffffc0200a76:	4585                	li	a1,1
ffffffffc0200a78:	854e                	mv	a0,s3
ffffffffc0200a7a:	033000ef          	jal	ra,ffffffffc02012ac <free_pages>
    free_page(p2);
ffffffffc0200a7e:	4585                	li	a1,1
ffffffffc0200a80:	8556                	mv	a0,s5
ffffffffc0200a82:	02b000ef          	jal	ra,ffffffffc02012ac <free_pages>
    assert(nr_free == 3);
ffffffffc0200a86:	4818                	lw	a4,16(s0)
ffffffffc0200a88:	478d                	li	a5,3
ffffffffc0200a8a:	32f71c63          	bne	a4,a5,ffffffffc0200dc2 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a8e:	4505                	li	a0,1
ffffffffc0200a90:	7de000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200a94:	89aa                	mv	s3,a0
ffffffffc0200a96:	30050663          	beqz	a0,ffffffffc0200da2 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a9a:	4505                	li	a0,1
ffffffffc0200a9c:	7d2000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200aa0:	8aaa                	mv	s5,a0
ffffffffc0200aa2:	2e050063          	beqz	a0,ffffffffc0200d82 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200aa6:	4505                	li	a0,1
ffffffffc0200aa8:	7c6000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200aac:	8a2a                	mv	s4,a0
ffffffffc0200aae:	2a050a63          	beqz	a0,ffffffffc0200d62 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc0200ab2:	4505                	li	a0,1
ffffffffc0200ab4:	7ba000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200ab8:	28051563          	bnez	a0,ffffffffc0200d42 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200abc:	4585                	li	a1,1
ffffffffc0200abe:	854e                	mv	a0,s3
ffffffffc0200ac0:	7ec000ef          	jal	ra,ffffffffc02012ac <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ac4:	641c                	ld	a5,8(s0)
ffffffffc0200ac6:	1a878e63          	beq	a5,s0,ffffffffc0200c82 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200aca:	4505                	li	a0,1
ffffffffc0200acc:	7a2000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200ad0:	52a99963          	bne	s3,a0,ffffffffc0201002 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0200ad4:	4505                	li	a0,1
ffffffffc0200ad6:	798000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200ada:	50051463          	bnez	a0,ffffffffc0200fe2 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200ade:	481c                	lw	a5,16(s0)
ffffffffc0200ae0:	4e079163          	bnez	a5,ffffffffc0200fc2 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0200ae4:	854e                	mv	a0,s3
ffffffffc0200ae6:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ae8:	01843023          	sd	s8,0(s0)
ffffffffc0200aec:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200af0:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200af4:	7b8000ef          	jal	ra,ffffffffc02012ac <free_pages>
    free_page(p1);
ffffffffc0200af8:	4585                	li	a1,1
ffffffffc0200afa:	8556                	mv	a0,s5
ffffffffc0200afc:	7b0000ef          	jal	ra,ffffffffc02012ac <free_pages>
    free_page(p2);
ffffffffc0200b00:	4585                	li	a1,1
ffffffffc0200b02:	8552                	mv	a0,s4
ffffffffc0200b04:	7a8000ef          	jal	ra,ffffffffc02012ac <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200b08:	4515                	li	a0,5
ffffffffc0200b0a:	764000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200b0e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200b10:	48050963          	beqz	a0,ffffffffc0200fa2 <best_fit_check+0x63e>
ffffffffc0200b14:	651c                	ld	a5,8(a0)
ffffffffc0200b16:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200b18:	8b85                	andi	a5,a5,1
ffffffffc0200b1a:	46079463          	bnez	a5,ffffffffc0200f82 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200b1e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b20:	00043a83          	ld	s5,0(s0)
ffffffffc0200b24:	00843a03          	ld	s4,8(s0)
ffffffffc0200b28:	e000                	sd	s0,0(s0)
ffffffffc0200b2a:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200b2c:	742000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200b30:	42051963          	bnez	a0,ffffffffc0200f62 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b34:	4589                	li	a1,2
ffffffffc0200b36:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b3a:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200b3e:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b42:	00005797          	auipc	a5,0x5
ffffffffc0200b46:	4c07af23          	sw	zero,1246(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b4a:	762000ef          	jal	ra,ffffffffc02012ac <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b4e:	8562                	mv	a0,s8
ffffffffc0200b50:	4585                	li	a1,1
ffffffffc0200b52:	75a000ef          	jal	ra,ffffffffc02012ac <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b56:	4511                	li	a0,4
ffffffffc0200b58:	716000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200b5c:	3e051363          	bnez	a0,ffffffffc0200f42 <best_fit_check+0x5de>
ffffffffc0200b60:	0309b783          	ld	a5,48(s3)
ffffffffc0200b64:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b66:	8b85                	andi	a5,a5,1
ffffffffc0200b68:	3a078d63          	beqz	a5,ffffffffc0200f22 <best_fit_check+0x5be>
ffffffffc0200b6c:	0389a703          	lw	a4,56(s3)
ffffffffc0200b70:	4789                	li	a5,2
ffffffffc0200b72:	3af71863          	bne	a4,a5,ffffffffc0200f22 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b76:	4505                	li	a0,1
ffffffffc0200b78:	6f6000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200b7c:	8baa                	mv	s7,a0
ffffffffc0200b7e:	38050263          	beqz	a0,ffffffffc0200f02 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b82:	4509                	li	a0,2
ffffffffc0200b84:	6ea000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200b88:	34050d63          	beqz	a0,ffffffffc0200ee2 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200b8c:	337c1b63          	bne	s8,s7,ffffffffc0200ec2 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b90:	854e                	mv	a0,s3
ffffffffc0200b92:	4595                	li	a1,5
ffffffffc0200b94:	718000ef          	jal	ra,ffffffffc02012ac <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b98:	4515                	li	a0,5
ffffffffc0200b9a:	6d4000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200b9e:	89aa                	mv	s3,a0
ffffffffc0200ba0:	30050163          	beqz	a0,ffffffffc0200ea2 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200ba4:	4505                	li	a0,1
ffffffffc0200ba6:	6c8000ef          	jal	ra,ffffffffc020126e <alloc_pages>
ffffffffc0200baa:	2c051c63          	bnez	a0,ffffffffc0200e82 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200bae:	481c                	lw	a5,16(s0)
ffffffffc0200bb0:	2a079963          	bnez	a5,ffffffffc0200e62 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200bb4:	4595                	li	a1,5
ffffffffc0200bb6:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200bb8:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200bbc:	01543023          	sd	s5,0(s0)
ffffffffc0200bc0:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200bc4:	6e8000ef          	jal	ra,ffffffffc02012ac <free_pages>
    return listelm->next;
ffffffffc0200bc8:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bca:	00878963          	beq	a5,s0,ffffffffc0200bdc <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200bce:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bd2:	679c                	ld	a5,8(a5)
ffffffffc0200bd4:	397d                	addiw	s2,s2,-1
ffffffffc0200bd6:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bd8:	fe879be3          	bne	a5,s0,ffffffffc0200bce <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200bdc:	26091363          	bnez	s2,ffffffffc0200e42 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200be0:	e0ed                	bnez	s1,ffffffffc0200cc2 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200be2:	60a6                	ld	ra,72(sp)
ffffffffc0200be4:	6406                	ld	s0,64(sp)
ffffffffc0200be6:	74e2                	ld	s1,56(sp)
ffffffffc0200be8:	7942                	ld	s2,48(sp)
ffffffffc0200bea:	79a2                	ld	s3,40(sp)
ffffffffc0200bec:	7a02                	ld	s4,32(sp)
ffffffffc0200bee:	6ae2                	ld	s5,24(sp)
ffffffffc0200bf0:	6b42                	ld	s6,16(sp)
ffffffffc0200bf2:	6ba2                	ld	s7,8(sp)
ffffffffc0200bf4:	6c02                	ld	s8,0(sp)
ffffffffc0200bf6:	6161                	addi	sp,sp,80
ffffffffc0200bf8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bfa:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200bfc:	4481                	li	s1,0
ffffffffc0200bfe:	4901                	li	s2,0
ffffffffc0200c00:	b35d                	j	ffffffffc02009a6 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200c02:	00001697          	auipc	a3,0x1
ffffffffc0200c06:	61e68693          	addi	a3,a3,1566 # ffffffffc0202220 <commands+0x5b8>
ffffffffc0200c0a:	00001617          	auipc	a2,0x1
ffffffffc0200c0e:	5e660613          	addi	a2,a2,1510 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200c12:	10c00593          	li	a1,268
ffffffffc0200c16:	00001517          	auipc	a0,0x1
ffffffffc0200c1a:	5f250513          	addi	a0,a0,1522 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200c1e:	f8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c22:	00001697          	auipc	a3,0x1
ffffffffc0200c26:	68e68693          	addi	a3,a3,1678 # ffffffffc02022b0 <commands+0x648>
ffffffffc0200c2a:	00001617          	auipc	a2,0x1
ffffffffc0200c2e:	5c660613          	addi	a2,a2,1478 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200c32:	0d800593          	li	a1,216
ffffffffc0200c36:	00001517          	auipc	a0,0x1
ffffffffc0200c3a:	5d250513          	addi	a0,a0,1490 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200c3e:	f6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c42:	00001697          	auipc	a3,0x1
ffffffffc0200c46:	69668693          	addi	a3,a3,1686 # ffffffffc02022d8 <commands+0x670>
ffffffffc0200c4a:	00001617          	auipc	a2,0x1
ffffffffc0200c4e:	5a660613          	addi	a2,a2,1446 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200c52:	0d900593          	li	a1,217
ffffffffc0200c56:	00001517          	auipc	a0,0x1
ffffffffc0200c5a:	5b250513          	addi	a0,a0,1458 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200c5e:	f4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c62:	00001697          	auipc	a3,0x1
ffffffffc0200c66:	6b668693          	addi	a3,a3,1718 # ffffffffc0202318 <commands+0x6b0>
ffffffffc0200c6a:	00001617          	auipc	a2,0x1
ffffffffc0200c6e:	58660613          	addi	a2,a2,1414 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200c72:	0db00593          	li	a1,219
ffffffffc0200c76:	00001517          	auipc	a0,0x1
ffffffffc0200c7a:	59250513          	addi	a0,a0,1426 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200c7e:	f2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c82:	00001697          	auipc	a3,0x1
ffffffffc0200c86:	71e68693          	addi	a3,a3,1822 # ffffffffc02023a0 <commands+0x738>
ffffffffc0200c8a:	00001617          	auipc	a2,0x1
ffffffffc0200c8e:	56660613          	addi	a2,a2,1382 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200c92:	0f400593          	li	a1,244
ffffffffc0200c96:	00001517          	auipc	a0,0x1
ffffffffc0200c9a:	57250513          	addi	a0,a0,1394 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200c9e:	f0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ca2:	00001697          	auipc	a3,0x1
ffffffffc0200ca6:	5ee68693          	addi	a3,a3,1518 # ffffffffc0202290 <commands+0x628>
ffffffffc0200caa:	00001617          	auipc	a2,0x1
ffffffffc0200cae:	54660613          	addi	a2,a2,1350 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200cb2:	0d600593          	li	a1,214
ffffffffc0200cb6:	00001517          	auipc	a0,0x1
ffffffffc0200cba:	55250513          	addi	a0,a0,1362 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200cbe:	eeeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200cc2:	00002697          	auipc	a3,0x2
ffffffffc0200cc6:	80e68693          	addi	a3,a3,-2034 # ffffffffc02024d0 <commands+0x868>
ffffffffc0200cca:	00001617          	auipc	a2,0x1
ffffffffc0200cce:	52660613          	addi	a2,a2,1318 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200cd2:	14e00593          	li	a1,334
ffffffffc0200cd6:	00001517          	auipc	a0,0x1
ffffffffc0200cda:	53250513          	addi	a0,a0,1330 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200cde:	eceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200ce2:	00001697          	auipc	a3,0x1
ffffffffc0200ce6:	54e68693          	addi	a3,a3,1358 # ffffffffc0202230 <commands+0x5c8>
ffffffffc0200cea:	00001617          	auipc	a2,0x1
ffffffffc0200cee:	50660613          	addi	a2,a2,1286 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200cf2:	10f00593          	li	a1,271
ffffffffc0200cf6:	00001517          	auipc	a0,0x1
ffffffffc0200cfa:	51250513          	addi	a0,a0,1298 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200cfe:	eaeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d02:	00001697          	auipc	a3,0x1
ffffffffc0200d06:	56e68693          	addi	a3,a3,1390 # ffffffffc0202270 <commands+0x608>
ffffffffc0200d0a:	00001617          	auipc	a2,0x1
ffffffffc0200d0e:	4e660613          	addi	a2,a2,1254 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200d12:	0d500593          	li	a1,213
ffffffffc0200d16:	00001517          	auipc	a0,0x1
ffffffffc0200d1a:	4f250513          	addi	a0,a0,1266 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200d1e:	e8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d22:	00001697          	auipc	a3,0x1
ffffffffc0200d26:	52e68693          	addi	a3,a3,1326 # ffffffffc0202250 <commands+0x5e8>
ffffffffc0200d2a:	00001617          	auipc	a2,0x1
ffffffffc0200d2e:	4c660613          	addi	a2,a2,1222 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200d32:	0d400593          	li	a1,212
ffffffffc0200d36:	00001517          	auipc	a0,0x1
ffffffffc0200d3a:	4d250513          	addi	a0,a0,1234 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200d3e:	e6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d42:	00001697          	auipc	a3,0x1
ffffffffc0200d46:	63668693          	addi	a3,a3,1590 # ffffffffc0202378 <commands+0x710>
ffffffffc0200d4a:	00001617          	auipc	a2,0x1
ffffffffc0200d4e:	4a660613          	addi	a2,a2,1190 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200d52:	0f100593          	li	a1,241
ffffffffc0200d56:	00001517          	auipc	a0,0x1
ffffffffc0200d5a:	4b250513          	addi	a0,a0,1202 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200d5e:	e4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d62:	00001697          	auipc	a3,0x1
ffffffffc0200d66:	52e68693          	addi	a3,a3,1326 # ffffffffc0202290 <commands+0x628>
ffffffffc0200d6a:	00001617          	auipc	a2,0x1
ffffffffc0200d6e:	48660613          	addi	a2,a2,1158 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200d72:	0ef00593          	li	a1,239
ffffffffc0200d76:	00001517          	auipc	a0,0x1
ffffffffc0200d7a:	49250513          	addi	a0,a0,1170 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200d7e:	e2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d82:	00001697          	auipc	a3,0x1
ffffffffc0200d86:	4ee68693          	addi	a3,a3,1262 # ffffffffc0202270 <commands+0x608>
ffffffffc0200d8a:	00001617          	auipc	a2,0x1
ffffffffc0200d8e:	46660613          	addi	a2,a2,1126 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200d92:	0ee00593          	li	a1,238
ffffffffc0200d96:	00001517          	auipc	a0,0x1
ffffffffc0200d9a:	47250513          	addi	a0,a0,1138 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200d9e:	e0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200da2:	00001697          	auipc	a3,0x1
ffffffffc0200da6:	4ae68693          	addi	a3,a3,1198 # ffffffffc0202250 <commands+0x5e8>
ffffffffc0200daa:	00001617          	auipc	a2,0x1
ffffffffc0200dae:	44660613          	addi	a2,a2,1094 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200db2:	0ed00593          	li	a1,237
ffffffffc0200db6:	00001517          	auipc	a0,0x1
ffffffffc0200dba:	45250513          	addi	a0,a0,1106 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200dbe:	deeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200dc2:	00001697          	auipc	a3,0x1
ffffffffc0200dc6:	5ce68693          	addi	a3,a3,1486 # ffffffffc0202390 <commands+0x728>
ffffffffc0200dca:	00001617          	auipc	a2,0x1
ffffffffc0200dce:	42660613          	addi	a2,a2,1062 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200dd2:	0eb00593          	li	a1,235
ffffffffc0200dd6:	00001517          	auipc	a0,0x1
ffffffffc0200dda:	43250513          	addi	a0,a0,1074 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200dde:	dceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200de2:	00001697          	auipc	a3,0x1
ffffffffc0200de6:	59668693          	addi	a3,a3,1430 # ffffffffc0202378 <commands+0x710>
ffffffffc0200dea:	00001617          	auipc	a2,0x1
ffffffffc0200dee:	40660613          	addi	a2,a2,1030 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200df2:	0e600593          	li	a1,230
ffffffffc0200df6:	00001517          	auipc	a0,0x1
ffffffffc0200dfa:	41250513          	addi	a0,a0,1042 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200dfe:	daeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e02:	00001697          	auipc	a3,0x1
ffffffffc0200e06:	55668693          	addi	a3,a3,1366 # ffffffffc0202358 <commands+0x6f0>
ffffffffc0200e0a:	00001617          	auipc	a2,0x1
ffffffffc0200e0e:	3e660613          	addi	a2,a2,998 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200e12:	0dd00593          	li	a1,221
ffffffffc0200e16:	00001517          	auipc	a0,0x1
ffffffffc0200e1a:	3f250513          	addi	a0,a0,1010 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200e1e:	d8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e22:	00001697          	auipc	a3,0x1
ffffffffc0200e26:	51668693          	addi	a3,a3,1302 # ffffffffc0202338 <commands+0x6d0>
ffffffffc0200e2a:	00001617          	auipc	a2,0x1
ffffffffc0200e2e:	3c660613          	addi	a2,a2,966 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200e32:	0dc00593          	li	a1,220
ffffffffc0200e36:	00001517          	auipc	a0,0x1
ffffffffc0200e3a:	3d250513          	addi	a0,a0,978 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200e3e:	d6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200e42:	00001697          	auipc	a3,0x1
ffffffffc0200e46:	67e68693          	addi	a3,a3,1662 # ffffffffc02024c0 <commands+0x858>
ffffffffc0200e4a:	00001617          	auipc	a2,0x1
ffffffffc0200e4e:	3a660613          	addi	a2,a2,934 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200e52:	14d00593          	li	a1,333
ffffffffc0200e56:	00001517          	auipc	a0,0x1
ffffffffc0200e5a:	3b250513          	addi	a0,a0,946 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200e5e:	d4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e62:	00001697          	auipc	a3,0x1
ffffffffc0200e66:	57668693          	addi	a3,a3,1398 # ffffffffc02023d8 <commands+0x770>
ffffffffc0200e6a:	00001617          	auipc	a2,0x1
ffffffffc0200e6e:	38660613          	addi	a2,a2,902 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200e72:	14200593          	li	a1,322
ffffffffc0200e76:	00001517          	auipc	a0,0x1
ffffffffc0200e7a:	39250513          	addi	a0,a0,914 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200e7e:	d2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e82:	00001697          	auipc	a3,0x1
ffffffffc0200e86:	4f668693          	addi	a3,a3,1270 # ffffffffc0202378 <commands+0x710>
ffffffffc0200e8a:	00001617          	auipc	a2,0x1
ffffffffc0200e8e:	36660613          	addi	a2,a2,870 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200e92:	13c00593          	li	a1,316
ffffffffc0200e96:	00001517          	auipc	a0,0x1
ffffffffc0200e9a:	37250513          	addi	a0,a0,882 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200e9e:	d0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ea2:	00001697          	auipc	a3,0x1
ffffffffc0200ea6:	5fe68693          	addi	a3,a3,1534 # ffffffffc02024a0 <commands+0x838>
ffffffffc0200eaa:	00001617          	auipc	a2,0x1
ffffffffc0200eae:	34660613          	addi	a2,a2,838 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200eb2:	13b00593          	li	a1,315
ffffffffc0200eb6:	00001517          	auipc	a0,0x1
ffffffffc0200eba:	35250513          	addi	a0,a0,850 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200ebe:	ceeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200ec2:	00001697          	auipc	a3,0x1
ffffffffc0200ec6:	5ce68693          	addi	a3,a3,1486 # ffffffffc0202490 <commands+0x828>
ffffffffc0200eca:	00001617          	auipc	a2,0x1
ffffffffc0200ece:	32660613          	addi	a2,a2,806 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200ed2:	13300593          	li	a1,307
ffffffffc0200ed6:	00001517          	auipc	a0,0x1
ffffffffc0200eda:	33250513          	addi	a0,a0,818 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200ede:	cceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ee2:	00001697          	auipc	a3,0x1
ffffffffc0200ee6:	59668693          	addi	a3,a3,1430 # ffffffffc0202478 <commands+0x810>
ffffffffc0200eea:	00001617          	auipc	a2,0x1
ffffffffc0200eee:	30660613          	addi	a2,a2,774 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200ef2:	13200593          	li	a1,306
ffffffffc0200ef6:	00001517          	auipc	a0,0x1
ffffffffc0200efa:	31250513          	addi	a0,a0,786 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200efe:	caeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f02:	00001697          	auipc	a3,0x1
ffffffffc0200f06:	55668693          	addi	a3,a3,1366 # ffffffffc0202458 <commands+0x7f0>
ffffffffc0200f0a:	00001617          	auipc	a2,0x1
ffffffffc0200f0e:	2e660613          	addi	a2,a2,742 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200f12:	13100593          	li	a1,305
ffffffffc0200f16:	00001517          	auipc	a0,0x1
ffffffffc0200f1a:	2f250513          	addi	a0,a0,754 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200f1e:	c8eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f22:	00001697          	auipc	a3,0x1
ffffffffc0200f26:	50668693          	addi	a3,a3,1286 # ffffffffc0202428 <commands+0x7c0>
ffffffffc0200f2a:	00001617          	auipc	a2,0x1
ffffffffc0200f2e:	2c660613          	addi	a2,a2,710 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200f32:	12f00593          	li	a1,303
ffffffffc0200f36:	00001517          	auipc	a0,0x1
ffffffffc0200f3a:	2d250513          	addi	a0,a0,722 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200f3e:	c6eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f42:	00001697          	auipc	a3,0x1
ffffffffc0200f46:	4ce68693          	addi	a3,a3,1230 # ffffffffc0202410 <commands+0x7a8>
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	2a660613          	addi	a2,a2,678 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200f52:	12e00593          	li	a1,302
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	2b250513          	addi	a0,a0,690 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200f5e:	c4eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f62:	00001697          	auipc	a3,0x1
ffffffffc0200f66:	41668693          	addi	a3,a3,1046 # ffffffffc0202378 <commands+0x710>
ffffffffc0200f6a:	00001617          	auipc	a2,0x1
ffffffffc0200f6e:	28660613          	addi	a2,a2,646 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200f72:	12200593          	li	a1,290
ffffffffc0200f76:	00001517          	auipc	a0,0x1
ffffffffc0200f7a:	29250513          	addi	a0,a0,658 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200f7e:	c2eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f82:	00001697          	auipc	a3,0x1
ffffffffc0200f86:	47668693          	addi	a3,a3,1142 # ffffffffc02023f8 <commands+0x790>
ffffffffc0200f8a:	00001617          	auipc	a2,0x1
ffffffffc0200f8e:	26660613          	addi	a2,a2,614 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200f92:	11900593          	li	a1,281
ffffffffc0200f96:	00001517          	auipc	a0,0x1
ffffffffc0200f9a:	27250513          	addi	a0,a0,626 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200f9e:	c0eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200fa2:	00001697          	auipc	a3,0x1
ffffffffc0200fa6:	44668693          	addi	a3,a3,1094 # ffffffffc02023e8 <commands+0x780>
ffffffffc0200faa:	00001617          	auipc	a2,0x1
ffffffffc0200fae:	24660613          	addi	a2,a2,582 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200fb2:	11800593          	li	a1,280
ffffffffc0200fb6:	00001517          	auipc	a0,0x1
ffffffffc0200fba:	25250513          	addi	a0,a0,594 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200fbe:	beeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200fc2:	00001697          	auipc	a3,0x1
ffffffffc0200fc6:	41668693          	addi	a3,a3,1046 # ffffffffc02023d8 <commands+0x770>
ffffffffc0200fca:	00001617          	auipc	a2,0x1
ffffffffc0200fce:	22660613          	addi	a2,a2,550 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200fd2:	0fa00593          	li	a1,250
ffffffffc0200fd6:	00001517          	auipc	a0,0x1
ffffffffc0200fda:	23250513          	addi	a0,a0,562 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200fde:	bceff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fe2:	00001697          	auipc	a3,0x1
ffffffffc0200fe6:	39668693          	addi	a3,a3,918 # ffffffffc0202378 <commands+0x710>
ffffffffc0200fea:	00001617          	auipc	a2,0x1
ffffffffc0200fee:	20660613          	addi	a2,a2,518 # ffffffffc02021f0 <commands+0x588>
ffffffffc0200ff2:	0f800593          	li	a1,248
ffffffffc0200ff6:	00001517          	auipc	a0,0x1
ffffffffc0200ffa:	21250513          	addi	a0,a0,530 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0200ffe:	baeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201002:	00001697          	auipc	a3,0x1
ffffffffc0201006:	3b668693          	addi	a3,a3,950 # ffffffffc02023b8 <commands+0x750>
ffffffffc020100a:	00001617          	auipc	a2,0x1
ffffffffc020100e:	1e660613          	addi	a2,a2,486 # ffffffffc02021f0 <commands+0x588>
ffffffffc0201012:	0f700593          	li	a1,247
ffffffffc0201016:	00001517          	auipc	a0,0x1
ffffffffc020101a:	1f250513          	addi	a0,a0,498 # ffffffffc0202208 <commands+0x5a0>
ffffffffc020101e:	b8eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201022 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201022:	1141                	addi	sp,sp,-16
ffffffffc0201024:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201026:	14058a63          	beqz	a1,ffffffffc020117a <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020102a:	00259693          	slli	a3,a1,0x2
ffffffffc020102e:	96ae                	add	a3,a3,a1
ffffffffc0201030:	068e                	slli	a3,a3,0x3
ffffffffc0201032:	96aa                	add	a3,a3,a0
ffffffffc0201034:	87aa                	mv	a5,a0
ffffffffc0201036:	02d50263          	beq	a0,a3,ffffffffc020105a <best_fit_free_pages+0x38>
ffffffffc020103a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020103c:	8b05                	andi	a4,a4,1
ffffffffc020103e:	10071e63          	bnez	a4,ffffffffc020115a <best_fit_free_pages+0x138>
ffffffffc0201042:	6798                	ld	a4,8(a5)
ffffffffc0201044:	8b09                	andi	a4,a4,2
ffffffffc0201046:	10071a63          	bnez	a4,ffffffffc020115a <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc020104a:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020104e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201052:	02878793          	addi	a5,a5,40
ffffffffc0201056:	fed792e3          	bne	a5,a3,ffffffffc020103a <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc020105a:	2581                	sext.w	a1,a1
ffffffffc020105c:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020105e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201062:	4789                	li	a5,2
ffffffffc0201064:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201068:	00005697          	auipc	a3,0x5
ffffffffc020106c:	fa868693          	addi	a3,a3,-88 # ffffffffc0206010 <free_area>
ffffffffc0201070:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201072:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201074:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201078:	9db9                	addw	a1,a1,a4
ffffffffc020107a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020107c:	0ad78863          	beq	a5,a3,ffffffffc020112c <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201080:	fe878713          	addi	a4,a5,-24
ffffffffc0201084:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201088:	4581                	li	a1,0
            if (base < page) {
ffffffffc020108a:	00e56a63          	bltu	a0,a4,ffffffffc020109e <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc020108e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201090:	06d70263          	beq	a4,a3,ffffffffc02010f4 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201094:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201096:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020109a:	fee57ae3          	bgeu	a0,a4,ffffffffc020108e <best_fit_free_pages+0x6c>
ffffffffc020109e:	c199                	beqz	a1,ffffffffc02010a4 <best_fit_free_pages+0x82>
ffffffffc02010a0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010a4:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010a6:	e390                	sd	a2,0(a5)
ffffffffc02010a8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02010aa:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010ac:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02010ae:	02d70063          	beq	a4,a3,ffffffffc02010ce <best_fit_free_pages+0xac>
        if(p + p->property == base){
ffffffffc02010b2:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02010b6:	fe870593          	addi	a1,a4,-24
        if(p + p->property == base){
ffffffffc02010ba:	02081613          	slli	a2,a6,0x20
ffffffffc02010be:	9201                	srli	a2,a2,0x20
ffffffffc02010c0:	00261793          	slli	a5,a2,0x2
ffffffffc02010c4:	97b2                	add	a5,a5,a2
ffffffffc02010c6:	078e                	slli	a5,a5,0x3
ffffffffc02010c8:	97ae                	add	a5,a5,a1
ffffffffc02010ca:	02f50f63          	beq	a0,a5,ffffffffc0201108 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc02010ce:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc02010d0:	00d70f63          	beq	a4,a3,ffffffffc02010ee <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02010d4:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02010d6:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc02010da:	02059613          	slli	a2,a1,0x20
ffffffffc02010de:	9201                	srli	a2,a2,0x20
ffffffffc02010e0:	00261793          	slli	a5,a2,0x2
ffffffffc02010e4:	97b2                	add	a5,a5,a2
ffffffffc02010e6:	078e                	slli	a5,a5,0x3
ffffffffc02010e8:	97aa                	add	a5,a5,a0
ffffffffc02010ea:	04f68863          	beq	a3,a5,ffffffffc020113a <best_fit_free_pages+0x118>
}
ffffffffc02010ee:	60a2                	ld	ra,8(sp)
ffffffffc02010f0:	0141                	addi	sp,sp,16
ffffffffc02010f2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02010f4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010f6:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02010f8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010fa:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010fc:	02d70563          	beq	a4,a3,ffffffffc0201126 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201100:	8832                	mv	a6,a2
ffffffffc0201102:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201104:	87ba                	mv	a5,a4
ffffffffc0201106:	bf41                	j	ffffffffc0201096 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc0201108:	491c                	lw	a5,16(a0)
ffffffffc020110a:	0107883b          	addw	a6,a5,a6
ffffffffc020110e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201112:	57f5                	li	a5,-3
ffffffffc0201114:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201118:	6d10                	ld	a2,24(a0)
ffffffffc020111a:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc020111c:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc020111e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201120:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201122:	e390                	sd	a2,0(a5)
ffffffffc0201124:	b775                	j	ffffffffc02010d0 <best_fit_free_pages+0xae>
ffffffffc0201126:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201128:	873e                	mv	a4,a5
ffffffffc020112a:	b761                	j	ffffffffc02010b2 <best_fit_free_pages+0x90>
}
ffffffffc020112c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020112e:	e390                	sd	a2,0(a5)
ffffffffc0201130:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201132:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201134:	ed1c                	sd	a5,24(a0)
ffffffffc0201136:	0141                	addi	sp,sp,16
ffffffffc0201138:	8082                	ret
            base->property += p->property;
ffffffffc020113a:	ff872783          	lw	a5,-8(a4)
ffffffffc020113e:	ff070693          	addi	a3,a4,-16
ffffffffc0201142:	9dbd                	addw	a1,a1,a5
ffffffffc0201144:	c90c                	sw	a1,16(a0)
ffffffffc0201146:	57f5                	li	a5,-3
ffffffffc0201148:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020114c:	6314                	ld	a3,0(a4)
ffffffffc020114e:	671c                	ld	a5,8(a4)
}
ffffffffc0201150:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201152:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201154:	e394                	sd	a3,0(a5)
ffffffffc0201156:	0141                	addi	sp,sp,16
ffffffffc0201158:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020115a:	00001697          	auipc	a3,0x1
ffffffffc020115e:	38668693          	addi	a3,a3,902 # ffffffffc02024e0 <commands+0x878>
ffffffffc0201162:	00001617          	auipc	a2,0x1
ffffffffc0201166:	08e60613          	addi	a2,a2,142 # ffffffffc02021f0 <commands+0x588>
ffffffffc020116a:	09400593          	li	a1,148
ffffffffc020116e:	00001517          	auipc	a0,0x1
ffffffffc0201172:	09a50513          	addi	a0,a0,154 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0201176:	a36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020117a:	00001697          	auipc	a3,0x1
ffffffffc020117e:	06e68693          	addi	a3,a3,110 # ffffffffc02021e8 <commands+0x580>
ffffffffc0201182:	00001617          	auipc	a2,0x1
ffffffffc0201186:	06e60613          	addi	a2,a2,110 # ffffffffc02021f0 <commands+0x588>
ffffffffc020118a:	09100593          	li	a1,145
ffffffffc020118e:	00001517          	auipc	a0,0x1
ffffffffc0201192:	07a50513          	addi	a0,a0,122 # ffffffffc0202208 <commands+0x5a0>
ffffffffc0201196:	a16ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020119a <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020119a:	1141                	addi	sp,sp,-16
ffffffffc020119c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020119e:	c9c5                	beqz	a1,ffffffffc020124e <best_fit_init_memmap+0xb4>
    for (; p != base + n; p ++) {
ffffffffc02011a0:	00259693          	slli	a3,a1,0x2
ffffffffc02011a4:	96ae                	add	a3,a3,a1
ffffffffc02011a6:	068e                	slli	a3,a3,0x3
ffffffffc02011a8:	96aa                	add	a3,a3,a0
ffffffffc02011aa:	87aa                	mv	a5,a0
ffffffffc02011ac:	00d50f63          	beq	a0,a3,ffffffffc02011ca <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011b0:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02011b2:	8b05                	andi	a4,a4,1
ffffffffc02011b4:	cf2d                	beqz	a4,ffffffffc020122e <best_fit_init_memmap+0x94>
        p->flags = p->property = 0;
ffffffffc02011b6:	0007a823          	sw	zero,16(a5)
ffffffffc02011ba:	0007b423          	sd	zero,8(a5)
ffffffffc02011be:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011c2:	02878793          	addi	a5,a5,40
ffffffffc02011c6:	fef695e3          	bne	a3,a5,ffffffffc02011b0 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc02011ca:	2581                	sext.w	a1,a1
ffffffffc02011cc:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02011ce:	4789                	li	a5,2
ffffffffc02011d0:	00850713          	addi	a4,a0,8
ffffffffc02011d4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02011d8:	00005697          	auipc	a3,0x5
ffffffffc02011dc:	e3868693          	addi	a3,a3,-456 # ffffffffc0206010 <free_area>
ffffffffc02011e0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02011e2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02011e4:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02011e8:	9db9                	addw	a1,a1,a4
ffffffffc02011ea:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02011ec:	02d78a63          	beq	a5,a3,ffffffffc0201220 <best_fit_init_memmap+0x86>
            struct Page* page = le2page(le, page_link);
ffffffffc02011f0:	fe878713          	addi	a4,a5,-24
            if(base < page){
ffffffffc02011f4:	00e57763          	bgeu	a0,a4,ffffffffc0201202 <best_fit_init_memmap+0x68>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011f8:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02011fa:	e390                	sd	a2,0(a5)
ffffffffc02011fc:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02011fe:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201200:	ed18                	sd	a4,24(a0)
    return listelm->next;
ffffffffc0201202:	6798                	ld	a4,8(a5)
            if(list_next(le) == &free_list){
ffffffffc0201204:	00d70463          	beq	a4,a3,ffffffffc020120c <best_fit_init_memmap+0x72>
    for (; p != base + n; p ++) {
ffffffffc0201208:	87ba                	mv	a5,a4
ffffffffc020120a:	b7dd                	j	ffffffffc02011f0 <best_fit_init_memmap+0x56>
    prev->next = next->prev = elm;
ffffffffc020120c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020120e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201210:	6798                	ld	a4,8(a5)
    prev->next = next->prev = elm;
ffffffffc0201212:	e290                	sd	a2,0(a3)
    elm->prev = prev;
ffffffffc0201214:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201216:	fed719e3          	bne	a4,a3,ffffffffc0201208 <best_fit_init_memmap+0x6e>
}
ffffffffc020121a:	60a2                	ld	ra,8(sp)
ffffffffc020121c:	0141                	addi	sp,sp,16
ffffffffc020121e:	8082                	ret
ffffffffc0201220:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201222:	e390                	sd	a2,0(a5)
ffffffffc0201224:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201226:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201228:	ed1c                	sd	a5,24(a0)
ffffffffc020122a:	0141                	addi	sp,sp,16
ffffffffc020122c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020122e:	00001697          	auipc	a3,0x1
ffffffffc0201232:	2da68693          	addi	a3,a3,730 # ffffffffc0202508 <commands+0x8a0>
ffffffffc0201236:	00001617          	auipc	a2,0x1
ffffffffc020123a:	fba60613          	addi	a2,a2,-70 # ffffffffc02021f0 <commands+0x588>
ffffffffc020123e:	04a00593          	li	a1,74
ffffffffc0201242:	00001517          	auipc	a0,0x1
ffffffffc0201246:	fc650513          	addi	a0,a0,-58 # ffffffffc0202208 <commands+0x5a0>
ffffffffc020124a:	962ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020124e:	00001697          	auipc	a3,0x1
ffffffffc0201252:	f9a68693          	addi	a3,a3,-102 # ffffffffc02021e8 <commands+0x580>
ffffffffc0201256:	00001617          	auipc	a2,0x1
ffffffffc020125a:	f9a60613          	addi	a2,a2,-102 # ffffffffc02021f0 <commands+0x588>
ffffffffc020125e:	04700593          	li	a1,71
ffffffffc0201262:	00001517          	auipc	a0,0x1
ffffffffc0201266:	fa650513          	addi	a0,a0,-90 # ffffffffc0202208 <commands+0x5a0>
ffffffffc020126a:	942ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020126e <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020126e:	100027f3          	csrr	a5,sstatus
ffffffffc0201272:	8b89                	andi	a5,a5,2
ffffffffc0201274:	e799                	bnez	a5,ffffffffc0201282 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201276:	00005797          	auipc	a5,0x5
ffffffffc020127a:	1d27b783          	ld	a5,466(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020127e:	6f9c                	ld	a5,24(a5)
ffffffffc0201280:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201282:	1141                	addi	sp,sp,-16
ffffffffc0201284:	e406                	sd	ra,8(sp)
ffffffffc0201286:	e022                	sd	s0,0(sp)
ffffffffc0201288:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020128a:	9d4ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020128e:	00005797          	auipc	a5,0x5
ffffffffc0201292:	1ba7b783          	ld	a5,442(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201296:	6f9c                	ld	a5,24(a5)
ffffffffc0201298:	8522                	mv	a0,s0
ffffffffc020129a:	9782                	jalr	a5
ffffffffc020129c:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020129e:	9baff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02012a2:	60a2                	ld	ra,8(sp)
ffffffffc02012a4:	8522                	mv	a0,s0
ffffffffc02012a6:	6402                	ld	s0,0(sp)
ffffffffc02012a8:	0141                	addi	sp,sp,16
ffffffffc02012aa:	8082                	ret

ffffffffc02012ac <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012ac:	100027f3          	csrr	a5,sstatus
ffffffffc02012b0:	8b89                	andi	a5,a5,2
ffffffffc02012b2:	e799                	bnez	a5,ffffffffc02012c0 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02012b4:	00005797          	auipc	a5,0x5
ffffffffc02012b8:	1947b783          	ld	a5,404(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012bc:	739c                	ld	a5,32(a5)
ffffffffc02012be:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02012c0:	1101                	addi	sp,sp,-32
ffffffffc02012c2:	ec06                	sd	ra,24(sp)
ffffffffc02012c4:	e822                	sd	s0,16(sp)
ffffffffc02012c6:	e426                	sd	s1,8(sp)
ffffffffc02012c8:	842a                	mv	s0,a0
ffffffffc02012ca:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02012cc:	992ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02012d0:	00005797          	auipc	a5,0x5
ffffffffc02012d4:	1787b783          	ld	a5,376(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012d8:	739c                	ld	a5,32(a5)
ffffffffc02012da:	85a6                	mv	a1,s1
ffffffffc02012dc:	8522                	mv	a0,s0
ffffffffc02012de:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02012e0:	6442                	ld	s0,16(sp)
ffffffffc02012e2:	60e2                	ld	ra,24(sp)
ffffffffc02012e4:	64a2                	ld	s1,8(sp)
ffffffffc02012e6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02012e8:	970ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02012ec <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012ec:	100027f3          	csrr	a5,sstatus
ffffffffc02012f0:	8b89                	andi	a5,a5,2
ffffffffc02012f2:	e799                	bnez	a5,ffffffffc0201300 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02012f4:	00005797          	auipc	a5,0x5
ffffffffc02012f8:	1547b783          	ld	a5,340(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012fc:	779c                	ld	a5,40(a5)
ffffffffc02012fe:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201300:	1141                	addi	sp,sp,-16
ffffffffc0201302:	e406                	sd	ra,8(sp)
ffffffffc0201304:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201306:	958ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020130a:	00005797          	auipc	a5,0x5
ffffffffc020130e:	13e7b783          	ld	a5,318(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201312:	779c                	ld	a5,40(a5)
ffffffffc0201314:	9782                	jalr	a5
ffffffffc0201316:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201318:	940ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020131c:	60a2                	ld	ra,8(sp)
ffffffffc020131e:	8522                	mv	a0,s0
ffffffffc0201320:	6402                	ld	s0,0(sp)
ffffffffc0201322:	0141                	addi	sp,sp,16
ffffffffc0201324:	8082                	ret

ffffffffc0201326 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201326:	00001797          	auipc	a5,0x1
ffffffffc020132a:	20a78793          	addi	a5,a5,522 # ffffffffc0202530 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020132e:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201330:	1101                	addi	sp,sp,-32
ffffffffc0201332:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201334:	00001517          	auipc	a0,0x1
ffffffffc0201338:	23450513          	addi	a0,a0,564 # ffffffffc0202568 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020133c:	00005497          	auipc	s1,0x5
ffffffffc0201340:	10c48493          	addi	s1,s1,268 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc0201344:	ec06                	sd	ra,24(sp)
ffffffffc0201346:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201348:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020134a:	d69fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc020134e:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201350:	00005417          	auipc	s0,0x5
ffffffffc0201354:	11040413          	addi	s0,s0,272 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201358:	679c                	ld	a5,8(a5)
ffffffffc020135a:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020135c:	57f5                	li	a5,-3
ffffffffc020135e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201360:	00001517          	auipc	a0,0x1
ffffffffc0201364:	22050513          	addi	a0,a0,544 # ffffffffc0202580 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201368:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc020136a:	d49fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020136e:	46c5                	li	a3,17
ffffffffc0201370:	06ee                	slli	a3,a3,0x1b
ffffffffc0201372:	40100613          	li	a2,1025
ffffffffc0201376:	16fd                	addi	a3,a3,-1
ffffffffc0201378:	07e005b7          	lui	a1,0x7e00
ffffffffc020137c:	0656                	slli	a2,a2,0x15
ffffffffc020137e:	00001517          	auipc	a0,0x1
ffffffffc0201382:	21a50513          	addi	a0,a0,538 # ffffffffc0202598 <best_fit_pmm_manager+0x68>
ffffffffc0201386:	d2dfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020138a:	777d                	lui	a4,0xfffff
ffffffffc020138c:	00006797          	auipc	a5,0x6
ffffffffc0201390:	0e378793          	addi	a5,a5,227 # ffffffffc020746f <end+0xfff>
ffffffffc0201394:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201396:	00005517          	auipc	a0,0x5
ffffffffc020139a:	0a250513          	addi	a0,a0,162 # ffffffffc0206438 <npage>
ffffffffc020139e:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013a2:	00005597          	auipc	a1,0x5
ffffffffc02013a6:	09e58593          	addi	a1,a1,158 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02013aa:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013ac:	e19c                	sd	a5,0(a1)
ffffffffc02013ae:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02013b0:	4701                	li	a4,0
ffffffffc02013b2:	4885                	li	a7,1
ffffffffc02013b4:	fff80837          	lui	a6,0xfff80
ffffffffc02013b8:	a011                	j	ffffffffc02013bc <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02013ba:	619c                	ld	a5,0(a1)
ffffffffc02013bc:	97b6                	add	a5,a5,a3
ffffffffc02013be:	07a1                	addi	a5,a5,8
ffffffffc02013c0:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02013c4:	611c                	ld	a5,0(a0)
ffffffffc02013c6:	0705                	addi	a4,a4,1
ffffffffc02013c8:	02868693          	addi	a3,a3,40
ffffffffc02013cc:	01078633          	add	a2,a5,a6
ffffffffc02013d0:	fec765e3          	bltu	a4,a2,ffffffffc02013ba <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02013d4:	6190                	ld	a2,0(a1)
ffffffffc02013d6:	00279713          	slli	a4,a5,0x2
ffffffffc02013da:	973e                	add	a4,a4,a5
ffffffffc02013dc:	fec006b7          	lui	a3,0xfec00
ffffffffc02013e0:	070e                	slli	a4,a4,0x3
ffffffffc02013e2:	96b2                	add	a3,a3,a2
ffffffffc02013e4:	96ba                	add	a3,a3,a4
ffffffffc02013e6:	c0200737          	lui	a4,0xc0200
ffffffffc02013ea:	08e6ef63          	bltu	a3,a4,ffffffffc0201488 <pmm_init+0x162>
ffffffffc02013ee:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02013f0:	45c5                	li	a1,17
ffffffffc02013f2:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02013f4:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02013f6:	04b6e863          	bltu	a3,a1,ffffffffc0201446 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02013fa:	609c                	ld	a5,0(s1)
ffffffffc02013fc:	7b9c                	ld	a5,48(a5)
ffffffffc02013fe:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201400:	00001517          	auipc	a0,0x1
ffffffffc0201404:	23050513          	addi	a0,a0,560 # ffffffffc0202630 <best_fit_pmm_manager+0x100>
ffffffffc0201408:	cabfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020140c:	00004597          	auipc	a1,0x4
ffffffffc0201410:	bf458593          	addi	a1,a1,-1036 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201414:	00005797          	auipc	a5,0x5
ffffffffc0201418:	04b7b223          	sd	a1,68(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020141c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201420:	08f5e063          	bltu	a1,a5,ffffffffc02014a0 <pmm_init+0x17a>
ffffffffc0201424:	6010                	ld	a2,0(s0)
}
ffffffffc0201426:	6442                	ld	s0,16(sp)
ffffffffc0201428:	60e2                	ld	ra,24(sp)
ffffffffc020142a:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc020142c:	40c58633          	sub	a2,a1,a2
ffffffffc0201430:	00005797          	auipc	a5,0x5
ffffffffc0201434:	02c7b023          	sd	a2,32(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201438:	00001517          	auipc	a0,0x1
ffffffffc020143c:	21850513          	addi	a0,a0,536 # ffffffffc0202650 <best_fit_pmm_manager+0x120>
}
ffffffffc0201440:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201442:	c71fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201446:	6705                	lui	a4,0x1
ffffffffc0201448:	177d                	addi	a4,a4,-1
ffffffffc020144a:	96ba                	add	a3,a3,a4
ffffffffc020144c:	777d                	lui	a4,0xfffff
ffffffffc020144e:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201450:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201454:	00f57e63          	bgeu	a0,a5,ffffffffc0201470 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201458:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020145a:	982a                	add	a6,a6,a0
ffffffffc020145c:	00281513          	slli	a0,a6,0x2
ffffffffc0201460:	9542                	add	a0,a0,a6
ffffffffc0201462:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201464:	8d95                	sub	a1,a1,a3
ffffffffc0201466:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201468:	81b1                	srli	a1,a1,0xc
ffffffffc020146a:	9532                	add	a0,a0,a2
ffffffffc020146c:	9782                	jalr	a5
}
ffffffffc020146e:	b771                	j	ffffffffc02013fa <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201470:	00001617          	auipc	a2,0x1
ffffffffc0201474:	19060613          	addi	a2,a2,400 # ffffffffc0202600 <best_fit_pmm_manager+0xd0>
ffffffffc0201478:	06b00593          	li	a1,107
ffffffffc020147c:	00001517          	auipc	a0,0x1
ffffffffc0201480:	1a450513          	addi	a0,a0,420 # ffffffffc0202620 <best_fit_pmm_manager+0xf0>
ffffffffc0201484:	f29fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201488:	00001617          	auipc	a2,0x1
ffffffffc020148c:	14060613          	addi	a2,a2,320 # ffffffffc02025c8 <best_fit_pmm_manager+0x98>
ffffffffc0201490:	06e00593          	li	a1,110
ffffffffc0201494:	00001517          	auipc	a0,0x1
ffffffffc0201498:	15c50513          	addi	a0,a0,348 # ffffffffc02025f0 <best_fit_pmm_manager+0xc0>
ffffffffc020149c:	f11fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014a0:	86ae                	mv	a3,a1
ffffffffc02014a2:	00001617          	auipc	a2,0x1
ffffffffc02014a6:	12660613          	addi	a2,a2,294 # ffffffffc02025c8 <best_fit_pmm_manager+0x98>
ffffffffc02014aa:	08900593          	li	a1,137
ffffffffc02014ae:	00001517          	auipc	a0,0x1
ffffffffc02014b2:	14250513          	addi	a0,a0,322 # ffffffffc02025f0 <best_fit_pmm_manager+0xc0>
ffffffffc02014b6:	ef7fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02014ba <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02014ba:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014be:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02014c0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014c4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02014c6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014ca:	f022                	sd	s0,32(sp)
ffffffffc02014cc:	ec26                	sd	s1,24(sp)
ffffffffc02014ce:	e84a                	sd	s2,16(sp)
ffffffffc02014d0:	f406                	sd	ra,40(sp)
ffffffffc02014d2:	e44e                	sd	s3,8(sp)
ffffffffc02014d4:	84aa                	mv	s1,a0
ffffffffc02014d6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02014d8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02014dc:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02014de:	03067e63          	bgeu	a2,a6,ffffffffc020151a <printnum+0x60>
ffffffffc02014e2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02014e4:	00805763          	blez	s0,ffffffffc02014f2 <printnum+0x38>
ffffffffc02014e8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02014ea:	85ca                	mv	a1,s2
ffffffffc02014ec:	854e                	mv	a0,s3
ffffffffc02014ee:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02014f0:	fc65                	bnez	s0,ffffffffc02014e8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014f2:	1a02                	slli	s4,s4,0x20
ffffffffc02014f4:	00001797          	auipc	a5,0x1
ffffffffc02014f8:	19c78793          	addi	a5,a5,412 # ffffffffc0202690 <best_fit_pmm_manager+0x160>
ffffffffc02014fc:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201500:	9a3e                	add	s4,s4,a5
}
ffffffffc0201502:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201504:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201508:	70a2                	ld	ra,40(sp)
ffffffffc020150a:	69a2                	ld	s3,8(sp)
ffffffffc020150c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020150e:	85ca                	mv	a1,s2
ffffffffc0201510:	87a6                	mv	a5,s1
}
ffffffffc0201512:	6942                	ld	s2,16(sp)
ffffffffc0201514:	64e2                	ld	s1,24(sp)
ffffffffc0201516:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201518:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020151a:	03065633          	divu	a2,a2,a6
ffffffffc020151e:	8722                	mv	a4,s0
ffffffffc0201520:	f9bff0ef          	jal	ra,ffffffffc02014ba <printnum>
ffffffffc0201524:	b7f9                	j	ffffffffc02014f2 <printnum+0x38>

ffffffffc0201526 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201526:	7119                	addi	sp,sp,-128
ffffffffc0201528:	f4a6                	sd	s1,104(sp)
ffffffffc020152a:	f0ca                	sd	s2,96(sp)
ffffffffc020152c:	ecce                	sd	s3,88(sp)
ffffffffc020152e:	e8d2                	sd	s4,80(sp)
ffffffffc0201530:	e4d6                	sd	s5,72(sp)
ffffffffc0201532:	e0da                	sd	s6,64(sp)
ffffffffc0201534:	fc5e                	sd	s7,56(sp)
ffffffffc0201536:	f06a                	sd	s10,32(sp)
ffffffffc0201538:	fc86                	sd	ra,120(sp)
ffffffffc020153a:	f8a2                	sd	s0,112(sp)
ffffffffc020153c:	f862                	sd	s8,48(sp)
ffffffffc020153e:	f466                	sd	s9,40(sp)
ffffffffc0201540:	ec6e                	sd	s11,24(sp)
ffffffffc0201542:	892a                	mv	s2,a0
ffffffffc0201544:	84ae                	mv	s1,a1
ffffffffc0201546:	8d32                	mv	s10,a2
ffffffffc0201548:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020154a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020154e:	5b7d                	li	s6,-1
ffffffffc0201550:	00001a97          	auipc	s5,0x1
ffffffffc0201554:	174a8a93          	addi	s5,s5,372 # ffffffffc02026c4 <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201558:	00001b97          	auipc	s7,0x1
ffffffffc020155c:	348b8b93          	addi	s7,s7,840 # ffffffffc02028a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201560:	000d4503          	lbu	a0,0(s10)
ffffffffc0201564:	001d0413          	addi	s0,s10,1
ffffffffc0201568:	01350a63          	beq	a0,s3,ffffffffc020157c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020156c:	c121                	beqz	a0,ffffffffc02015ac <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020156e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201570:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201572:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201574:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201578:	ff351ae3          	bne	a0,s3,ffffffffc020156c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020157c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201580:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201584:	4c81                	li	s9,0
ffffffffc0201586:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201588:	5c7d                	li	s8,-1
ffffffffc020158a:	5dfd                	li	s11,-1
ffffffffc020158c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201590:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201592:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201596:	0ff5f593          	zext.b	a1,a1
ffffffffc020159a:	00140d13          	addi	s10,s0,1
ffffffffc020159e:	04b56263          	bltu	a0,a1,ffffffffc02015e2 <vprintfmt+0xbc>
ffffffffc02015a2:	058a                	slli	a1,a1,0x2
ffffffffc02015a4:	95d6                	add	a1,a1,s5
ffffffffc02015a6:	4194                	lw	a3,0(a1)
ffffffffc02015a8:	96d6                	add	a3,a3,s5
ffffffffc02015aa:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02015ac:	70e6                	ld	ra,120(sp)
ffffffffc02015ae:	7446                	ld	s0,112(sp)
ffffffffc02015b0:	74a6                	ld	s1,104(sp)
ffffffffc02015b2:	7906                	ld	s2,96(sp)
ffffffffc02015b4:	69e6                	ld	s3,88(sp)
ffffffffc02015b6:	6a46                	ld	s4,80(sp)
ffffffffc02015b8:	6aa6                	ld	s5,72(sp)
ffffffffc02015ba:	6b06                	ld	s6,64(sp)
ffffffffc02015bc:	7be2                	ld	s7,56(sp)
ffffffffc02015be:	7c42                	ld	s8,48(sp)
ffffffffc02015c0:	7ca2                	ld	s9,40(sp)
ffffffffc02015c2:	7d02                	ld	s10,32(sp)
ffffffffc02015c4:	6de2                	ld	s11,24(sp)
ffffffffc02015c6:	6109                	addi	sp,sp,128
ffffffffc02015c8:	8082                	ret
            padc = '0';
ffffffffc02015ca:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02015cc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015d0:	846a                	mv	s0,s10
ffffffffc02015d2:	00140d13          	addi	s10,s0,1
ffffffffc02015d6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02015da:	0ff5f593          	zext.b	a1,a1
ffffffffc02015de:	fcb572e3          	bgeu	a0,a1,ffffffffc02015a2 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02015e2:	85a6                	mv	a1,s1
ffffffffc02015e4:	02500513          	li	a0,37
ffffffffc02015e8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02015ea:	fff44783          	lbu	a5,-1(s0)
ffffffffc02015ee:	8d22                	mv	s10,s0
ffffffffc02015f0:	f73788e3          	beq	a5,s3,ffffffffc0201560 <vprintfmt+0x3a>
ffffffffc02015f4:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02015f8:	1d7d                	addi	s10,s10,-1
ffffffffc02015fa:	ff379de3          	bne	a5,s3,ffffffffc02015f4 <vprintfmt+0xce>
ffffffffc02015fe:	b78d                	j	ffffffffc0201560 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201600:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201604:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201608:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020160a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020160e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201612:	02d86463          	bltu	a6,a3,ffffffffc020163a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201616:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020161a:	002c169b          	slliw	a3,s8,0x2
ffffffffc020161e:	0186873b          	addw	a4,a3,s8
ffffffffc0201622:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201626:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201628:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020162c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020162e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201632:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201636:	fed870e3          	bgeu	a6,a3,ffffffffc0201616 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020163a:	f40ddce3          	bgez	s11,ffffffffc0201592 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020163e:	8de2                	mv	s11,s8
ffffffffc0201640:	5c7d                	li	s8,-1
ffffffffc0201642:	bf81                	j	ffffffffc0201592 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201644:	fffdc693          	not	a3,s11
ffffffffc0201648:	96fd                	srai	a3,a3,0x3f
ffffffffc020164a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020164e:	00144603          	lbu	a2,1(s0)
ffffffffc0201652:	2d81                	sext.w	s11,s11
ffffffffc0201654:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201656:	bf35                	j	ffffffffc0201592 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201658:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020165c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201660:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201662:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201664:	bfd9                	j	ffffffffc020163a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201666:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201668:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020166c:	01174463          	blt	a4,a7,ffffffffc0201674 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201670:	1a088e63          	beqz	a7,ffffffffc020182c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201674:	000a3603          	ld	a2,0(s4)
ffffffffc0201678:	46c1                	li	a3,16
ffffffffc020167a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020167c:	2781                	sext.w	a5,a5
ffffffffc020167e:	876e                	mv	a4,s11
ffffffffc0201680:	85a6                	mv	a1,s1
ffffffffc0201682:	854a                	mv	a0,s2
ffffffffc0201684:	e37ff0ef          	jal	ra,ffffffffc02014ba <printnum>
            break;
ffffffffc0201688:	bde1                	j	ffffffffc0201560 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020168a:	000a2503          	lw	a0,0(s4)
ffffffffc020168e:	85a6                	mv	a1,s1
ffffffffc0201690:	0a21                	addi	s4,s4,8
ffffffffc0201692:	9902                	jalr	s2
            break;
ffffffffc0201694:	b5f1                	j	ffffffffc0201560 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201696:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201698:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020169c:	01174463          	blt	a4,a7,ffffffffc02016a4 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02016a0:	18088163          	beqz	a7,ffffffffc0201822 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02016a4:	000a3603          	ld	a2,0(s4)
ffffffffc02016a8:	46a9                	li	a3,10
ffffffffc02016aa:	8a2e                	mv	s4,a1
ffffffffc02016ac:	bfc1                	j	ffffffffc020167c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ae:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02016b2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016b4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016b6:	bdf1                	j	ffffffffc0201592 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02016b8:	85a6                	mv	a1,s1
ffffffffc02016ba:	02500513          	li	a0,37
ffffffffc02016be:	9902                	jalr	s2
            break;
ffffffffc02016c0:	b545                	j	ffffffffc0201560 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016c2:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02016c6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016c8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016ca:	b5e1                	j	ffffffffc0201592 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02016cc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016ce:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016d2:	01174463          	blt	a4,a7,ffffffffc02016da <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02016d6:	14088163          	beqz	a7,ffffffffc0201818 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02016da:	000a3603          	ld	a2,0(s4)
ffffffffc02016de:	46a1                	li	a3,8
ffffffffc02016e0:	8a2e                	mv	s4,a1
ffffffffc02016e2:	bf69                	j	ffffffffc020167c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02016e4:	03000513          	li	a0,48
ffffffffc02016e8:	85a6                	mv	a1,s1
ffffffffc02016ea:	e03e                	sd	a5,0(sp)
ffffffffc02016ec:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02016ee:	85a6                	mv	a1,s1
ffffffffc02016f0:	07800513          	li	a0,120
ffffffffc02016f4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016f6:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02016f8:	6782                	ld	a5,0(sp)
ffffffffc02016fa:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016fc:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201700:	bfb5                	j	ffffffffc020167c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201702:	000a3403          	ld	s0,0(s4)
ffffffffc0201706:	008a0713          	addi	a4,s4,8
ffffffffc020170a:	e03a                	sd	a4,0(sp)
ffffffffc020170c:	14040263          	beqz	s0,ffffffffc0201850 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201710:	0fb05763          	blez	s11,ffffffffc02017fe <vprintfmt+0x2d8>
ffffffffc0201714:	02d00693          	li	a3,45
ffffffffc0201718:	0cd79163          	bne	a5,a3,ffffffffc02017da <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020171c:	00044783          	lbu	a5,0(s0)
ffffffffc0201720:	0007851b          	sext.w	a0,a5
ffffffffc0201724:	cf85                	beqz	a5,ffffffffc020175c <vprintfmt+0x236>
ffffffffc0201726:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020172a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020172e:	000c4563          	bltz	s8,ffffffffc0201738 <vprintfmt+0x212>
ffffffffc0201732:	3c7d                	addiw	s8,s8,-1
ffffffffc0201734:	036c0263          	beq	s8,s6,ffffffffc0201758 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201738:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020173a:	0e0c8e63          	beqz	s9,ffffffffc0201836 <vprintfmt+0x310>
ffffffffc020173e:	3781                	addiw	a5,a5,-32
ffffffffc0201740:	0ef47b63          	bgeu	s0,a5,ffffffffc0201836 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201744:	03f00513          	li	a0,63
ffffffffc0201748:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020174a:	000a4783          	lbu	a5,0(s4)
ffffffffc020174e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201750:	0a05                	addi	s4,s4,1
ffffffffc0201752:	0007851b          	sext.w	a0,a5
ffffffffc0201756:	ffe1                	bnez	a5,ffffffffc020172e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201758:	01b05963          	blez	s11,ffffffffc020176a <vprintfmt+0x244>
ffffffffc020175c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020175e:	85a6                	mv	a1,s1
ffffffffc0201760:	02000513          	li	a0,32
ffffffffc0201764:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201766:	fe0d9be3          	bnez	s11,ffffffffc020175c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020176a:	6a02                	ld	s4,0(sp)
ffffffffc020176c:	bbd5                	j	ffffffffc0201560 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020176e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201770:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201774:	01174463          	blt	a4,a7,ffffffffc020177c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201778:	08088d63          	beqz	a7,ffffffffc0201812 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020177c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201780:	0a044d63          	bltz	s0,ffffffffc020183a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201784:	8622                	mv	a2,s0
ffffffffc0201786:	8a66                	mv	s4,s9
ffffffffc0201788:	46a9                	li	a3,10
ffffffffc020178a:	bdcd                	j	ffffffffc020167c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020178c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201790:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201792:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201794:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201798:	8fb5                	xor	a5,a5,a3
ffffffffc020179a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020179e:	02d74163          	blt	a4,a3,ffffffffc02017c0 <vprintfmt+0x29a>
ffffffffc02017a2:	00369793          	slli	a5,a3,0x3
ffffffffc02017a6:	97de                	add	a5,a5,s7
ffffffffc02017a8:	639c                	ld	a5,0(a5)
ffffffffc02017aa:	cb99                	beqz	a5,ffffffffc02017c0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02017ac:	86be                	mv	a3,a5
ffffffffc02017ae:	00001617          	auipc	a2,0x1
ffffffffc02017b2:	f1260613          	addi	a2,a2,-238 # ffffffffc02026c0 <best_fit_pmm_manager+0x190>
ffffffffc02017b6:	85a6                	mv	a1,s1
ffffffffc02017b8:	854a                	mv	a0,s2
ffffffffc02017ba:	0ce000ef          	jal	ra,ffffffffc0201888 <printfmt>
ffffffffc02017be:	b34d                	j	ffffffffc0201560 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02017c0:	00001617          	auipc	a2,0x1
ffffffffc02017c4:	ef060613          	addi	a2,a2,-272 # ffffffffc02026b0 <best_fit_pmm_manager+0x180>
ffffffffc02017c8:	85a6                	mv	a1,s1
ffffffffc02017ca:	854a                	mv	a0,s2
ffffffffc02017cc:	0bc000ef          	jal	ra,ffffffffc0201888 <printfmt>
ffffffffc02017d0:	bb41                	j	ffffffffc0201560 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02017d2:	00001417          	auipc	s0,0x1
ffffffffc02017d6:	ed640413          	addi	s0,s0,-298 # ffffffffc02026a8 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017da:	85e2                	mv	a1,s8
ffffffffc02017dc:	8522                	mv	a0,s0
ffffffffc02017de:	e43e                	sd	a5,8(sp)
ffffffffc02017e0:	1cc000ef          	jal	ra,ffffffffc02019ac <strnlen>
ffffffffc02017e4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02017e8:	01b05b63          	blez	s11,ffffffffc02017fe <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02017ec:	67a2                	ld	a5,8(sp)
ffffffffc02017ee:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017f2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02017f4:	85a6                	mv	a1,s1
ffffffffc02017f6:	8552                	mv	a0,s4
ffffffffc02017f8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017fa:	fe0d9ce3          	bnez	s11,ffffffffc02017f2 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017fe:	00044783          	lbu	a5,0(s0)
ffffffffc0201802:	00140a13          	addi	s4,s0,1
ffffffffc0201806:	0007851b          	sext.w	a0,a5
ffffffffc020180a:	d3a5                	beqz	a5,ffffffffc020176a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020180c:	05e00413          	li	s0,94
ffffffffc0201810:	bf39                	j	ffffffffc020172e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201812:	000a2403          	lw	s0,0(s4)
ffffffffc0201816:	b7ad                	j	ffffffffc0201780 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201818:	000a6603          	lwu	a2,0(s4)
ffffffffc020181c:	46a1                	li	a3,8
ffffffffc020181e:	8a2e                	mv	s4,a1
ffffffffc0201820:	bdb1                	j	ffffffffc020167c <vprintfmt+0x156>
ffffffffc0201822:	000a6603          	lwu	a2,0(s4)
ffffffffc0201826:	46a9                	li	a3,10
ffffffffc0201828:	8a2e                	mv	s4,a1
ffffffffc020182a:	bd89                	j	ffffffffc020167c <vprintfmt+0x156>
ffffffffc020182c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201830:	46c1                	li	a3,16
ffffffffc0201832:	8a2e                	mv	s4,a1
ffffffffc0201834:	b5a1                	j	ffffffffc020167c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201836:	9902                	jalr	s2
ffffffffc0201838:	bf09                	j	ffffffffc020174a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020183a:	85a6                	mv	a1,s1
ffffffffc020183c:	02d00513          	li	a0,45
ffffffffc0201840:	e03e                	sd	a5,0(sp)
ffffffffc0201842:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201844:	6782                	ld	a5,0(sp)
ffffffffc0201846:	8a66                	mv	s4,s9
ffffffffc0201848:	40800633          	neg	a2,s0
ffffffffc020184c:	46a9                	li	a3,10
ffffffffc020184e:	b53d                	j	ffffffffc020167c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201850:	03b05163          	blez	s11,ffffffffc0201872 <vprintfmt+0x34c>
ffffffffc0201854:	02d00693          	li	a3,45
ffffffffc0201858:	f6d79de3          	bne	a5,a3,ffffffffc02017d2 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020185c:	00001417          	auipc	s0,0x1
ffffffffc0201860:	e4c40413          	addi	s0,s0,-436 # ffffffffc02026a8 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201864:	02800793          	li	a5,40
ffffffffc0201868:	02800513          	li	a0,40
ffffffffc020186c:	00140a13          	addi	s4,s0,1
ffffffffc0201870:	bd6d                	j	ffffffffc020172a <vprintfmt+0x204>
ffffffffc0201872:	00001a17          	auipc	s4,0x1
ffffffffc0201876:	e37a0a13          	addi	s4,s4,-457 # ffffffffc02026a9 <best_fit_pmm_manager+0x179>
ffffffffc020187a:	02800513          	li	a0,40
ffffffffc020187e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201882:	05e00413          	li	s0,94
ffffffffc0201886:	b565                	j	ffffffffc020172e <vprintfmt+0x208>

ffffffffc0201888 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201888:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020188a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020188e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201890:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201892:	ec06                	sd	ra,24(sp)
ffffffffc0201894:	f83a                	sd	a4,48(sp)
ffffffffc0201896:	fc3e                	sd	a5,56(sp)
ffffffffc0201898:	e0c2                	sd	a6,64(sp)
ffffffffc020189a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020189c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020189e:	c89ff0ef          	jal	ra,ffffffffc0201526 <vprintfmt>
}
ffffffffc02018a2:	60e2                	ld	ra,24(sp)
ffffffffc02018a4:	6161                	addi	sp,sp,80
ffffffffc02018a6:	8082                	ret

ffffffffc02018a8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02018a8:	715d                	addi	sp,sp,-80
ffffffffc02018aa:	e486                	sd	ra,72(sp)
ffffffffc02018ac:	e0a6                	sd	s1,64(sp)
ffffffffc02018ae:	fc4a                	sd	s2,56(sp)
ffffffffc02018b0:	f84e                	sd	s3,48(sp)
ffffffffc02018b2:	f452                	sd	s4,40(sp)
ffffffffc02018b4:	f056                	sd	s5,32(sp)
ffffffffc02018b6:	ec5a                	sd	s6,24(sp)
ffffffffc02018b8:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02018ba:	c901                	beqz	a0,ffffffffc02018ca <readline+0x22>
ffffffffc02018bc:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02018be:	00001517          	auipc	a0,0x1
ffffffffc02018c2:	e0250513          	addi	a0,a0,-510 # ffffffffc02026c0 <best_fit_pmm_manager+0x190>
ffffffffc02018c6:	fecfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc02018ca:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018cc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02018ce:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02018d0:	4aa9                	li	s5,10
ffffffffc02018d2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02018d4:	00004b97          	auipc	s7,0x4
ffffffffc02018d8:	754b8b93          	addi	s7,s7,1876 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018dc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02018e0:	84bfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018e4:	00054a63          	bltz	a0,ffffffffc02018f8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018e8:	00a95a63          	bge	s2,a0,ffffffffc02018fc <readline+0x54>
ffffffffc02018ec:	029a5263          	bge	s4,s1,ffffffffc0201910 <readline+0x68>
        c = getchar();
ffffffffc02018f0:	83bfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018f4:	fe055ae3          	bgez	a0,ffffffffc02018e8 <readline+0x40>
            return NULL;
ffffffffc02018f8:	4501                	li	a0,0
ffffffffc02018fa:	a091                	j	ffffffffc020193e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02018fc:	03351463          	bne	a0,s3,ffffffffc0201924 <readline+0x7c>
ffffffffc0201900:	e8a9                	bnez	s1,ffffffffc0201952 <readline+0xaa>
        c = getchar();
ffffffffc0201902:	829fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201906:	fe0549e3          	bltz	a0,ffffffffc02018f8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020190a:	fea959e3          	bge	s2,a0,ffffffffc02018fc <readline+0x54>
ffffffffc020190e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201910:	e42a                	sd	a0,8(sp)
ffffffffc0201912:	fd6fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201916:	6522                	ld	a0,8(sp)
ffffffffc0201918:	009b87b3          	add	a5,s7,s1
ffffffffc020191c:	2485                	addiw	s1,s1,1
ffffffffc020191e:	00a78023          	sb	a0,0(a5)
ffffffffc0201922:	bf7d                	j	ffffffffc02018e0 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201924:	01550463          	beq	a0,s5,ffffffffc020192c <readline+0x84>
ffffffffc0201928:	fb651ce3          	bne	a0,s6,ffffffffc02018e0 <readline+0x38>
            cputchar(c);
ffffffffc020192c:	fbcfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201930:	00004517          	auipc	a0,0x4
ffffffffc0201934:	6f850513          	addi	a0,a0,1784 # ffffffffc0206028 <buf>
ffffffffc0201938:	94aa                	add	s1,s1,a0
ffffffffc020193a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020193e:	60a6                	ld	ra,72(sp)
ffffffffc0201940:	6486                	ld	s1,64(sp)
ffffffffc0201942:	7962                	ld	s2,56(sp)
ffffffffc0201944:	79c2                	ld	s3,48(sp)
ffffffffc0201946:	7a22                	ld	s4,40(sp)
ffffffffc0201948:	7a82                	ld	s5,32(sp)
ffffffffc020194a:	6b62                	ld	s6,24(sp)
ffffffffc020194c:	6bc2                	ld	s7,16(sp)
ffffffffc020194e:	6161                	addi	sp,sp,80
ffffffffc0201950:	8082                	ret
            cputchar(c);
ffffffffc0201952:	4521                	li	a0,8
ffffffffc0201954:	f94fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201958:	34fd                	addiw	s1,s1,-1
ffffffffc020195a:	b759                	j	ffffffffc02018e0 <readline+0x38>

ffffffffc020195c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020195c:	4781                	li	a5,0
ffffffffc020195e:	00004717          	auipc	a4,0x4
ffffffffc0201962:	6aa73703          	ld	a4,1706(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201966:	88ba                	mv	a7,a4
ffffffffc0201968:	852a                	mv	a0,a0
ffffffffc020196a:	85be                	mv	a1,a5
ffffffffc020196c:	863e                	mv	a2,a5
ffffffffc020196e:	00000073          	ecall
ffffffffc0201972:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201974:	8082                	ret

ffffffffc0201976 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201976:	4781                	li	a5,0
ffffffffc0201978:	00005717          	auipc	a4,0x5
ffffffffc020197c:	af073703          	ld	a4,-1296(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc0201980:	88ba                	mv	a7,a4
ffffffffc0201982:	852a                	mv	a0,a0
ffffffffc0201984:	85be                	mv	a1,a5
ffffffffc0201986:	863e                	mv	a2,a5
ffffffffc0201988:	00000073          	ecall
ffffffffc020198c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020198e:	8082                	ret

ffffffffc0201990 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201990:	4501                	li	a0,0
ffffffffc0201992:	00004797          	auipc	a5,0x4
ffffffffc0201996:	66e7b783          	ld	a5,1646(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc020199a:	88be                	mv	a7,a5
ffffffffc020199c:	852a                	mv	a0,a0
ffffffffc020199e:	85aa                	mv	a1,a0
ffffffffc02019a0:	862a                	mv	a2,a0
ffffffffc02019a2:	00000073          	ecall
ffffffffc02019a6:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02019a8:	2501                	sext.w	a0,a0
ffffffffc02019aa:	8082                	ret

ffffffffc02019ac <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02019ac:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02019ae:	e589                	bnez	a1,ffffffffc02019b8 <strnlen+0xc>
ffffffffc02019b0:	a811                	j	ffffffffc02019c4 <strnlen+0x18>
        cnt ++;
ffffffffc02019b2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02019b4:	00f58863          	beq	a1,a5,ffffffffc02019c4 <strnlen+0x18>
ffffffffc02019b8:	00f50733          	add	a4,a0,a5
ffffffffc02019bc:	00074703          	lbu	a4,0(a4)
ffffffffc02019c0:	fb6d                	bnez	a4,ffffffffc02019b2 <strnlen+0x6>
ffffffffc02019c2:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02019c4:	852e                	mv	a0,a1
ffffffffc02019c6:	8082                	ret

ffffffffc02019c8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019c8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019cc:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019d0:	cb89                	beqz	a5,ffffffffc02019e2 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02019d2:	0505                	addi	a0,a0,1
ffffffffc02019d4:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019d6:	fee789e3          	beq	a5,a4,ffffffffc02019c8 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019da:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02019de:	9d19                	subw	a0,a0,a4
ffffffffc02019e0:	8082                	ret
ffffffffc02019e2:	4501                	li	a0,0
ffffffffc02019e4:	bfed                	j	ffffffffc02019de <strcmp+0x16>

ffffffffc02019e6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02019e6:	00054783          	lbu	a5,0(a0)
ffffffffc02019ea:	c799                	beqz	a5,ffffffffc02019f8 <strchr+0x12>
        if (*s == c) {
ffffffffc02019ec:	00f58763          	beq	a1,a5,ffffffffc02019fa <strchr+0x14>
    while (*s != '\0') {
ffffffffc02019f0:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02019f4:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019f6:	fbfd                	bnez	a5,ffffffffc02019ec <strchr+0x6>
    }
    return NULL;
ffffffffc02019f8:	4501                	li	a0,0
}
ffffffffc02019fa:	8082                	ret

ffffffffc02019fc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019fc:	ca01                	beqz	a2,ffffffffc0201a0c <memset+0x10>
ffffffffc02019fe:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201a00:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201a02:	0785                	addi	a5,a5,1
ffffffffc0201a04:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201a08:	fec79de3          	bne	a5,a2,ffffffffc0201a02 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201a0c:	8082                	ret
