
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	04013103          	ld	sp,64(sp) # 8000a040 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	0000b617          	auipc	a2,0xb
    8000004e:	fb660613          	addi	a2,a2,-74 # 8000b000 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	49478793          	addi	a5,a5,1172 # 800064f0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd0753>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	2c278793          	addi	a5,a5,706 # 80001368 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(struct file *f, int user_dst, uint64 dst, int n)
{
    800000ec:	7159                	addi	sp,sp,-112
    800000ee:	f486                	sd	ra,104(sp)
    800000f0:	f0a2                	sd	s0,96(sp)
    800000f2:	eca6                	sd	s1,88(sp)
    800000f4:	e8ca                	sd	s2,80(sp)
    800000f6:	e4ce                	sd	s3,72(sp)
    800000f8:	e0d2                	sd	s4,64(sp)
    800000fa:	fc56                	sd	s5,56(sp)
    800000fc:	f85a                	sd	s6,48(sp)
    800000fe:	f45e                	sd	s7,40(sp)
    80000100:	f062                	sd	s8,32(sp)
    80000102:	ec66                	sd	s9,24(sp)
    80000104:	e86a                	sd	s10,16(sp)
    80000106:	1880                	addi	s0,sp,112
    80000108:	84aa                	mv	s1,a0
    8000010a:	8b2e                	mv	s6,a1
    8000010c:	8ab2                	mv	s5,a2
    8000010e:	89b6                	mv	s3,a3
  uint target;
  int c;
  char cbuf;

  target = n;
    80000110:	00068b9b          	sext.w	s7,a3
  struct cons_t* cons = &consoles[f->minor-1];
    80000114:	02651a03          	lh	s4,38(a0) # 1026 <_entry-0x7fffefda>
    80000118:	3a7d                	addiw	s4,s4,-1
    8000011a:	001a1d13          	slli	s10,s4,0x1
    8000011e:	9d52                	add	s10,s10,s4
    80000120:	0d1a                	slli	s10,s10,0x6
    80000122:	00013917          	auipc	s2,0x13
    80000126:	6de90913          	addi	s2,s2,1758 # 80013800 <consoles>
    8000012a:	996a                	add	s2,s2,s10
  acquire(&console_number_lock);
    8000012c:	00014517          	auipc	a0,0x14
    80000130:	91450513          	addi	a0,a0,-1772 # 80013a40 <console_number_lock>
    80000134:	00001097          	auipc	ra,0x1
    80000138:	b54080e7          	jalr	-1196(ra) # 80000c88 <acquire>
  while(console_number != f->minor - 1){
    8000013c:	02649783          	lh	a5,38(s1)
    80000140:	37fd                	addiw	a5,a5,-1
    80000142:	0002e717          	auipc	a4,0x2e
    80000146:	f2672703          	lw	a4,-218(a4) # 8002e068 <console_number>
    8000014a:	02e78763          	beq	a5,a4,80000178 <consoleread+0x8c>
    sleep(cons, &console_number_lock);
    8000014e:	00014c97          	auipc	s9,0x14
    80000152:	8f2c8c93          	addi	s9,s9,-1806 # 80013a40 <console_number_lock>
  while(console_number != f->minor - 1){
    80000156:	0002ec17          	auipc	s8,0x2e
    8000015a:	f12c0c13          	addi	s8,s8,-238 # 8002e068 <console_number>
    sleep(cons, &console_number_lock);
    8000015e:	85e6                	mv	a1,s9
    80000160:	854a                	mv	a0,s2
    80000162:	00002097          	auipc	ra,0x2
    80000166:	71a080e7          	jalr	1818(ra) # 8000287c <sleep>
  while(console_number != f->minor - 1){
    8000016a:	02649783          	lh	a5,38(s1)
    8000016e:	37fd                	addiw	a5,a5,-1
    80000170:	000c2703          	lw	a4,0(s8)
    80000174:	fee795e3          	bne	a5,a4,8000015e <consoleread+0x72>
  }
  release(&console_number_lock);
    80000178:	00014517          	auipc	a0,0x14
    8000017c:	8c850513          	addi	a0,a0,-1848 # 80013a40 <console_number_lock>
    80000180:	00001097          	auipc	ra,0x1
    80000184:	d54080e7          	jalr	-684(ra) # 80000ed4 <release>
  acquire(&cons->lock);
    80000188:	854a                	mv	a0,s2
    8000018a:	00001097          	auipc	ra,0x1
    8000018e:	afe080e7          	jalr	-1282(ra) # 80000c88 <acquire>
    while(cons->r == cons->w){
      if(myproc()->killed){
        release(&cons->lock);
        return -1;
      }
      sleep(&cons->r, &cons->lock);
    80000192:	00013797          	auipc	a5,0x13
    80000196:	71e78793          	addi	a5,a5,1822 # 800138b0 <consoles+0xb0>
    8000019a:	9d3e                	add	s10,s10,a5
    while(cons->r == cons->w){
    8000019c:	001a1493          	slli	s1,s4,0x1
    800001a0:	94d2                	add	s1,s1,s4
    800001a2:	00649793          	slli	a5,s1,0x6
    800001a6:	00013497          	auipc	s1,0x13
    800001aa:	65a48493          	addi	s1,s1,1626 # 80013800 <consoles>
    800001ae:	94be                	add	s1,s1,a5
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0x13a>
    while(cons->r == cons->w){
    800001b4:	0b04a783          	lw	a5,176(s1)
    800001b8:	0b44a703          	lw	a4,180(s1)
    800001bc:	02f71463          	bne	a4,a5,800001e4 <consoleread+0xf8>
      if(myproc()->killed){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	ddc080e7          	jalr	-548(ra) # 80001f9c <myproc>
    800001c8:	453c                	lw	a5,72(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0x14a>
      sleep(&cons->r, &cons->lock);
    800001cc:	85ca                	mv	a1,s2
    800001ce:	856a                	mv	a0,s10
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	6ac080e7          	jalr	1708(ra) # 8000287c <sleep>
    while(cons->r == cons->w){
    800001d8:	0b04a783          	lw	a5,176(s1)
    800001dc:	0b44a703          	lw	a4,180(s1)
    800001e0:	fef700e3          	beq	a4,a5,800001c0 <consoleread+0xd4>
    }

    c = cons->buf[cons->r++ % INPUT_BUF];
    800001e4:	0017871b          	addiw	a4,a5,1
    800001e8:	0ae4a823          	sw	a4,176(s1)
    800001ec:	07f7f713          	andi	a4,a5,127
    800001f0:	9726                	add	a4,a4,s1
    800001f2:	03074703          	lbu	a4,48(a4)
    800001f6:	00070c1b          	sext.w	s8,a4

    if(c == C('D')){  // end-of-file
    800001fa:	4691                	li	a3,4
    800001fc:	06dc0163          	beq	s8,a3,8000025e <consoleread+0x172>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000200:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000204:	4685                	li	a3,1
    80000206:	f9f40613          	addi	a2,s0,-97
    8000020a:	85d6                	mv	a1,s5
    8000020c:	855a                	mv	a0,s6
    8000020e:	00003097          	auipc	ra,0x3
    80000212:	8d0080e7          	jalr	-1840(ra) # 80002ade <either_copyout>
    80000216:	57fd                	li	a5,-1
    80000218:	00f50763          	beq	a0,a5,80000226 <consoleread+0x13a>
      break;

    dst++;
    8000021c:	0a85                	addi	s5,s5,1
    --n;
    8000021e:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000220:	47a9                	li	a5,10
    80000222:	f8fc17e3          	bne	s8,a5,800001b0 <consoleread+0xc4>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons->lock);
    80000226:	854a                	mv	a0,s2
    80000228:	00001097          	auipc	ra,0x1
    8000022c:	cac080e7          	jalr	-852(ra) # 80000ed4 <release>

  return target - n;
    80000230:	413b853b          	subw	a0,s7,s3
    80000234:	a039                	j	80000242 <consoleread+0x156>
        release(&cons->lock);
    80000236:	854a                	mv	a0,s2
    80000238:	00001097          	auipc	ra,0x1
    8000023c:	c9c080e7          	jalr	-868(ra) # 80000ed4 <release>
        return -1;
    80000240:	557d                	li	a0,-1
}
    80000242:	70a6                	ld	ra,104(sp)
    80000244:	7406                	ld	s0,96(sp)
    80000246:	64e6                	ld	s1,88(sp)
    80000248:	6946                	ld	s2,80(sp)
    8000024a:	69a6                	ld	s3,72(sp)
    8000024c:	6a06                	ld	s4,64(sp)
    8000024e:	7ae2                	ld	s5,56(sp)
    80000250:	7b42                	ld	s6,48(sp)
    80000252:	7ba2                	ld	s7,40(sp)
    80000254:	7c02                	ld	s8,32(sp)
    80000256:	6ce2                	ld	s9,24(sp)
    80000258:	6d42                	ld	s10,16(sp)
    8000025a:	6165                	addi	sp,sp,112
    8000025c:	8082                	ret
      if(n < target){
    8000025e:	0009871b          	sext.w	a4,s3
    80000262:	fd7772e3          	bgeu	a4,s7,80000226 <consoleread+0x13a>
        cons->r--;
    80000266:	001a1713          	slli	a4,s4,0x1
    8000026a:	9752                	add	a4,a4,s4
    8000026c:	071a                	slli	a4,a4,0x6
    8000026e:	00013697          	auipc	a3,0x13
    80000272:	59268693          	addi	a3,a3,1426 # 80013800 <consoles>
    80000276:	9736                	add	a4,a4,a3
    80000278:	0af72823          	sw	a5,176(a4)
    8000027c:	b76d                	j	80000226 <consoleread+0x13a>

000000008000027e <consputc>:
  if(panicked){
    8000027e:	0002e797          	auipc	a5,0x2e
    80000282:	dee7a783          	lw	a5,-530(a5) # 8002e06c <panicked>
    80000286:	c391                	beqz	a5,8000028a <consputc+0xc>
    for(;;)
    80000288:	a001                	j	80000288 <consputc+0xa>
{
    8000028a:	1141                	addi	sp,sp,-16
    8000028c:	e406                	sd	ra,8(sp)
    8000028e:	e022                	sd	s0,0(sp)
    80000290:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000292:	10000793          	li	a5,256
    80000296:	00f50a63          	beq	a0,a5,800002aa <consputc+0x2c>
    uartputc(c);
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	7ac080e7          	jalr	1964(ra) # 80000a46 <uartputc>
}
    800002a2:	60a2                	ld	ra,8(sp)
    800002a4:	6402                	ld	s0,0(sp)
    800002a6:	0141                	addi	sp,sp,16
    800002a8:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    800002aa:	4521                	li	a0,8
    800002ac:	00000097          	auipc	ra,0x0
    800002b0:	79a080e7          	jalr	1946(ra) # 80000a46 <uartputc>
    800002b4:	02000513          	li	a0,32
    800002b8:	00000097          	auipc	ra,0x0
    800002bc:	78e080e7          	jalr	1934(ra) # 80000a46 <uartputc>
    800002c0:	4521                	li	a0,8
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	784080e7          	jalr	1924(ra) # 80000a46 <uartputc>
    800002ca:	bfe1                	j	800002a2 <consputc+0x24>

00000000800002cc <consolewrite>:
{
    800002cc:	711d                	addi	sp,sp,-96
    800002ce:	ec86                	sd	ra,88(sp)
    800002d0:	e8a2                	sd	s0,80(sp)
    800002d2:	e4a6                	sd	s1,72(sp)
    800002d4:	e0ca                	sd	s2,64(sp)
    800002d6:	fc4e                	sd	s3,56(sp)
    800002d8:	f852                	sd	s4,48(sp)
    800002da:	f456                	sd	s5,40(sp)
    800002dc:	f05a                	sd	s6,32(sp)
    800002de:	ec5e                	sd	s7,24(sp)
    800002e0:	1080                	addi	s0,sp,96
    800002e2:	89aa                	mv	s3,a0
    800002e4:	8a2e                	mv	s4,a1
    800002e6:	84b2                	mv	s1,a2
    800002e8:	8ab6                	mv	s5,a3
  struct cons_t* cons = &consoles[f->minor-1];
    800002ea:	02651783          	lh	a5,38(a0)
    800002ee:	37fd                	addiw	a5,a5,-1
    800002f0:	00179913          	slli	s2,a5,0x1
    800002f4:	993e                	add	s2,s2,a5
    800002f6:	00691793          	slli	a5,s2,0x6
    800002fa:	00013917          	auipc	s2,0x13
    800002fe:	50690913          	addi	s2,s2,1286 # 80013800 <consoles>
    80000302:	993e                	add	s2,s2,a5
  acquire(&console_number_lock);
    80000304:	00013517          	auipc	a0,0x13
    80000308:	73c50513          	addi	a0,a0,1852 # 80013a40 <console_number_lock>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	97c080e7          	jalr	-1668(ra) # 80000c88 <acquire>
  while(console_number != f->minor - 1){
    80000314:	02699783          	lh	a5,38(s3)
    80000318:	37fd                	addiw	a5,a5,-1
    8000031a:	0002e717          	auipc	a4,0x2e
    8000031e:	d4e72703          	lw	a4,-690(a4) # 8002e068 <console_number>
    80000322:	02e78763          	beq	a5,a4,80000350 <consolewrite+0x84>
    sleep(cons, &console_number_lock);
    80000326:	00013b97          	auipc	s7,0x13
    8000032a:	71ab8b93          	addi	s7,s7,1818 # 80013a40 <console_number_lock>
  while(console_number != f->minor - 1){
    8000032e:	0002eb17          	auipc	s6,0x2e
    80000332:	d3ab0b13          	addi	s6,s6,-710 # 8002e068 <console_number>
    sleep(cons, &console_number_lock);
    80000336:	85de                	mv	a1,s7
    80000338:	854a                	mv	a0,s2
    8000033a:	00002097          	auipc	ra,0x2
    8000033e:	542080e7          	jalr	1346(ra) # 8000287c <sleep>
  while(console_number != f->minor - 1){
    80000342:	02699783          	lh	a5,38(s3)
    80000346:	37fd                	addiw	a5,a5,-1
    80000348:	000b2703          	lw	a4,0(s6)
    8000034c:	fee795e3          	bne	a5,a4,80000336 <consolewrite+0x6a>
  release(&console_number_lock);
    80000350:	00013517          	auipc	a0,0x13
    80000354:	6f050513          	addi	a0,a0,1776 # 80013a40 <console_number_lock>
    80000358:	00001097          	auipc	ra,0x1
    8000035c:	b7c080e7          	jalr	-1156(ra) # 80000ed4 <release>
  acquire(&cons->lock);
    80000360:	854a                	mv	a0,s2
    80000362:	00001097          	auipc	ra,0x1
    80000366:	926080e7          	jalr	-1754(ra) # 80000c88 <acquire>
  for(i = 0; i < n; i++){
    8000036a:	03505e63          	blez	s5,800003a6 <consolewrite+0xda>
    8000036e:	00148993          	addi	s3,s1,1
    80000372:	fffa879b          	addiw	a5,s5,-1
    80000376:	1782                	slli	a5,a5,0x20
    80000378:	9381                	srli	a5,a5,0x20
    8000037a:	99be                	add	s3,s3,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000037c:	5b7d                	li	s6,-1
    8000037e:	4685                	li	a3,1
    80000380:	8626                	mv	a2,s1
    80000382:	85d2                	mv	a1,s4
    80000384:	faf40513          	addi	a0,s0,-81
    80000388:	00002097          	auipc	ra,0x2
    8000038c:	7ac080e7          	jalr	1964(ra) # 80002b34 <either_copyin>
    80000390:	01650b63          	beq	a0,s6,800003a6 <consolewrite+0xda>
    consputc(c);
    80000394:	faf44503          	lbu	a0,-81(s0)
    80000398:	00000097          	auipc	ra,0x0
    8000039c:	ee6080e7          	jalr	-282(ra) # 8000027e <consputc>
  for(i = 0; i < n; i++){
    800003a0:	0485                	addi	s1,s1,1
    800003a2:	fd349ee3          	bne	s1,s3,8000037e <consolewrite+0xb2>
  release(&cons->lock);
    800003a6:	854a                	mv	a0,s2
    800003a8:	00001097          	auipc	ra,0x1
    800003ac:	b2c080e7          	jalr	-1236(ra) # 80000ed4 <release>
}
    800003b0:	8556                	mv	a0,s5
    800003b2:	60e6                	ld	ra,88(sp)
    800003b4:	6446                	ld	s0,80(sp)
    800003b6:	64a6                	ld	s1,72(sp)
    800003b8:	6906                	ld	s2,64(sp)
    800003ba:	79e2                	ld	s3,56(sp)
    800003bc:	7a42                	ld	s4,48(sp)
    800003be:	7aa2                	ld	s5,40(sp)
    800003c0:	7b02                	ld	s6,32(sp)
    800003c2:	6be2                	ld	s7,24(sp)
    800003c4:	6125                	addi	sp,sp,96
    800003c6:	8082                	ret

00000000800003c8 <consoleintr>:
// do erase/kill processing, append to cons->buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800003c8:	7179                	addi	sp,sp,-48
    800003ca:	f406                	sd	ra,40(sp)
    800003cc:	f022                	sd	s0,32(sp)
    800003ce:	ec26                	sd	s1,24(sp)
    800003d0:	e84a                	sd	s2,16(sp)
    800003d2:	e44e                	sd	s3,8(sp)
    800003d4:	e052                	sd	s4,0(sp)
    800003d6:	1800                	addi	s0,sp,48
    800003d8:	84aa                	mv	s1,a0
  acquire(&cons->lock);
    800003da:	0002e517          	auipc	a0,0x2e
    800003de:	c8653503          	ld	a0,-890(a0) # 8002e060 <cons>
    800003e2:	00001097          	auipc	ra,0x1
    800003e6:	8a6080e7          	jalr	-1882(ra) # 80000c88 <acquire>

  switch(c){
    800003ea:	47d5                	li	a5,21
    800003ec:	0297c763          	blt	a5,s1,8000041a <consoleintr+0x52>
    800003f0:	479d                	li	a5,7
    800003f2:	1c97da63          	bge	a5,s1,800005c6 <consoleintr+0x1fe>
    800003f6:	ff84879b          	addiw	a5,s1,-8
    800003fa:	0007869b          	sext.w	a3,a5
    800003fe:	4735                	li	a4,13
    80000400:	1cd76363          	bltu	a4,a3,800005c6 <consoleintr+0x1fe>
    80000404:	1782                	slli	a5,a5,0x20
    80000406:	9381                	srli	a5,a5,0x20
    80000408:	078a                	slli	a5,a5,0x2
    8000040a:	00009717          	auipc	a4,0x9
    8000040e:	ae670713          	addi	a4,a4,-1306 # 80008ef0 <userret+0xe60>
    80000412:	97ba                	add	a5,a5,a4
    80000414:	439c                	lw	a5,0(a5)
    80000416:	97ba                	add	a5,a5,a4
    80000418:	8782                	jr	a5
    8000041a:	07f00793          	li	a5,127
    8000041e:	18f48063          	beq	s1,a5,8000059e <consoleintr+0x1d6>
      cons->e--;
      consputc(BACKSPACE);
    }
    break;
  default:
    if(c != 0 && cons->e-cons->r < INPUT_BUF){
    80000422:	0002e717          	auipc	a4,0x2e
    80000426:	c3e73703          	ld	a4,-962(a4) # 8002e060 <cons>
    8000042a:	0b872783          	lw	a5,184(a4)
    8000042e:	0b072703          	lw	a4,176(a4)
    80000432:	9f99                	subw	a5,a5,a4
    80000434:	07f00713          	li	a4,127
    80000438:	0af76563          	bltu	a4,a5,800004e2 <consoleintr+0x11a>
      c = (c == '\r') ? '\n' : c;
    8000043c:	47b5                	li	a5,13
    8000043e:	18f48663          	beq	s1,a5,800005ca <consoleintr+0x202>

      // echo back to the user.
      consputc(c);
    80000442:	8526                	mv	a0,s1
    80000444:	00000097          	auipc	ra,0x0
    80000448:	e3a080e7          	jalr	-454(ra) # 8000027e <consputc>

      // store for consumption by consoleread().
      cons->buf[cons->e++ % INPUT_BUF] = c;
    8000044c:	0002e517          	auipc	a0,0x2e
    80000450:	c1453503          	ld	a0,-1004(a0) # 8002e060 <cons>
    80000454:	0b852783          	lw	a5,184(a0)
    80000458:	0017871b          	addiw	a4,a5,1
    8000045c:	0007069b          	sext.w	a3,a4
    80000460:	0ae52c23          	sw	a4,184(a0)
    80000464:	07f7f793          	andi	a5,a5,127
    80000468:	97aa                	add	a5,a5,a0
    8000046a:	02978823          	sb	s1,48(a5)

      if(c == '\n' || c == C('D') || cons->e == cons->r+INPUT_BUF){
    8000046e:	47a9                	li	a5,10
    80000470:	18f48463          	beq	s1,a5,800005f8 <consoleintr+0x230>
    80000474:	4791                	li	a5,4
    80000476:	18f48163          	beq	s1,a5,800005f8 <consoleintr+0x230>
    8000047a:	0b052783          	lw	a5,176(a0)
    8000047e:	0807879b          	addiw	a5,a5,128
    80000482:	06f69063          	bne	a3,a5,800004e2 <consoleintr+0x11a>
      cons->buf[cons->e++ % INPUT_BUF] = c;
    80000486:	86be                	mv	a3,a5
    80000488:	aa85                	j	800005f8 <consoleintr+0x230>
    while(cons->e != cons->w &&
    8000048a:	0002e717          	auipc	a4,0x2e
    8000048e:	bd673703          	ld	a4,-1066(a4) # 8002e060 <cons>
    80000492:	0b872783          	lw	a5,184(a4)
    80000496:	0b472683          	lw	a3,180(a4)
    8000049a:	44a9                	li	s1,10
    8000049c:	0002e917          	auipc	s2,0x2e
    800004a0:	bc490913          	addi	s2,s2,-1084 # 8002e060 <cons>
    800004a4:	02f68f63          	beq	a3,a5,800004e2 <consoleintr+0x11a>
          cons->buf[(cons->e-1) % INPUT_BUF] != '\n'){
    800004a8:	37fd                	addiw	a5,a5,-1
    800004aa:	07f7f693          	andi	a3,a5,127
    800004ae:	96ba                	add	a3,a3,a4
    while(cons->e != cons->w &&
    800004b0:	0306c683          	lbu	a3,48(a3)
    800004b4:	02968763          	beq	a3,s1,800004e2 <consoleintr+0x11a>
      cons->e--;
    800004b8:	0af72c23          	sw	a5,184(a4)
      consputc(BACKSPACE);
    800004bc:	10000513          	li	a0,256
    800004c0:	00000097          	auipc	ra,0x0
    800004c4:	dbe080e7          	jalr	-578(ra) # 8000027e <consputc>
    while(cons->e != cons->w &&
    800004c8:	00093703          	ld	a4,0(s2)
    800004cc:	0b872783          	lw	a5,184(a4)
    800004d0:	0b472683          	lw	a3,180(a4)
    800004d4:	fcf69ae3          	bne	a3,a5,800004a8 <consoleintr+0xe0>
    800004d8:	a029                	j	800004e2 <consoleintr+0x11a>
    procdump();
    800004da:	00002097          	auipc	ra,0x2
    800004de:	6b0080e7          	jalr	1712(ra) # 80002b8a <procdump>
      }
    }
    break;
  }
  
  release(&cons->lock);
    800004e2:	0002e517          	auipc	a0,0x2e
    800004e6:	b7e53503          	ld	a0,-1154(a0) # 8002e060 <cons>
    800004ea:	00001097          	auipc	ra,0x1
    800004ee:	9ea080e7          	jalr	-1558(ra) # 80000ed4 <release>
}
    800004f2:	70a2                	ld	ra,40(sp)
    800004f4:	7402                	ld	s0,32(sp)
    800004f6:	64e2                	ld	s1,24(sp)
    800004f8:	6942                	ld	s2,16(sp)
    800004fa:	69a2                	ld	s3,8(sp)
    800004fc:	6a02                	ld	s4,0(sp)
    800004fe:	6145                	addi	sp,sp,48
    80000500:	8082                	ret
    priodump();
    80000502:	00002097          	auipc	ra,0x2
    80000506:	744080e7          	jalr	1860(ra) # 80002c46 <priodump>
    break;
    8000050a:	bfe1                	j	800004e2 <consoleintr+0x11a>
    dump_locks();
    8000050c:	00000097          	auipc	ra,0x0
    80000510:	668080e7          	jalr	1640(ra) # 80000b74 <dump_locks>
    break;
    80000514:	b7f9                	j	800004e2 <consoleintr+0x11a>
    acquire(&console_number_lock);
    80000516:	00013997          	auipc	s3,0x13
    8000051a:	52a98993          	addi	s3,s3,1322 # 80013a40 <console_number_lock>
    8000051e:	854e                	mv	a0,s3
    80000520:	00000097          	auipc	ra,0x0
    80000524:	768080e7          	jalr	1896(ra) # 80000c88 <acquire>
    struct spinlock* old = &cons->lock;
    80000528:	0002e917          	auipc	s2,0x2e
    8000052c:	b3890913          	addi	s2,s2,-1224 # 8002e060 <cons>
    80000530:	00093a03          	ld	s4,0(s2)
    console_number = (console_number + 1) % NBCONSOLES;
    80000534:	0002e497          	auipc	s1,0x2e
    80000538:	b3448493          	addi	s1,s1,-1228 # 8002e068 <console_number>
    8000053c:	409c                	lw	a5,0(s1)
    8000053e:	2785                	addiw	a5,a5,1
    80000540:	470d                	li	a4,3
    80000542:	02e7e7bb          	remw	a5,a5,a4
    80000546:	0007871b          	sext.w	a4,a5
    8000054a:	c09c                	sw	a5,0(s1)
    cons = &consoles[console_number];
    8000054c:	00171513          	slli	a0,a4,0x1
    80000550:	953a                	add	a0,a0,a4
    80000552:	051a                	slli	a0,a0,0x6
    80000554:	00013797          	auipc	a5,0x13
    80000558:	2ac78793          	addi	a5,a5,684 # 80013800 <consoles>
    8000055c:	953e                	add	a0,a0,a5
    8000055e:	00a93023          	sd	a0,0(s2)
    acquire(&cons->lock);
    80000562:	00000097          	auipc	ra,0x0
    80000566:	726080e7          	jalr	1830(ra) # 80000c88 <acquire>
    release(old);
    8000056a:	8552                	mv	a0,s4
    8000056c:	00001097          	auipc	ra,0x1
    80000570:	968080e7          	jalr	-1688(ra) # 80000ed4 <release>
    wakeup(cons);
    80000574:	00093503          	ld	a0,0(s2)
    80000578:	00002097          	auipc	ra,0x2
    8000057c:	48a080e7          	jalr	1162(ra) # 80002a02 <wakeup>
    printf("Switched to console number %d\n", console_number);
    80000580:	408c                	lw	a1,0(s1)
    80000582:	00008517          	auipc	a0,0x8
    80000586:	b9650513          	addi	a0,a0,-1130 # 80008118 <userret+0x88>
    8000058a:	00000097          	auipc	ra,0x0
    8000058e:	3e2080e7          	jalr	994(ra) # 8000096c <printf>
    release(&console_number_lock);
    80000592:	854e                	mv	a0,s3
    80000594:	00001097          	auipc	ra,0x1
    80000598:	940080e7          	jalr	-1728(ra) # 80000ed4 <release>
    break;
    8000059c:	b799                	j	800004e2 <consoleintr+0x11a>
    if(cons->e != cons->w){
    8000059e:	0002e797          	auipc	a5,0x2e
    800005a2:	ac27b783          	ld	a5,-1342(a5) # 8002e060 <cons>
    800005a6:	0b87a703          	lw	a4,184(a5)
    800005aa:	0b47a683          	lw	a3,180(a5)
    800005ae:	f2e68ae3          	beq	a3,a4,800004e2 <consoleintr+0x11a>
      cons->e--;
    800005b2:	377d                	addiw	a4,a4,-1
    800005b4:	0ae7ac23          	sw	a4,184(a5)
      consputc(BACKSPACE);
    800005b8:	10000513          	li	a0,256
    800005bc:	00000097          	auipc	ra,0x0
    800005c0:	cc2080e7          	jalr	-830(ra) # 8000027e <consputc>
    800005c4:	bf39                	j	800004e2 <consoleintr+0x11a>
    if(c != 0 && cons->e-cons->r < INPUT_BUF){
    800005c6:	dc91                	beqz	s1,800004e2 <consoleintr+0x11a>
    800005c8:	bda9                	j	80000422 <consoleintr+0x5a>
      consputc(c);
    800005ca:	4529                	li	a0,10
    800005cc:	00000097          	auipc	ra,0x0
    800005d0:	cb2080e7          	jalr	-846(ra) # 8000027e <consputc>
      cons->buf[cons->e++ % INPUT_BUF] = c;
    800005d4:	0002e517          	auipc	a0,0x2e
    800005d8:	a8c53503          	ld	a0,-1396(a0) # 8002e060 <cons>
    800005dc:	0b852783          	lw	a5,184(a0)
    800005e0:	0017871b          	addiw	a4,a5,1
    800005e4:	0007069b          	sext.w	a3,a4
    800005e8:	0ae52c23          	sw	a4,184(a0)
    800005ec:	07f7f793          	andi	a5,a5,127
    800005f0:	97aa                	add	a5,a5,a0
    800005f2:	4729                	li	a4,10
    800005f4:	02e78823          	sb	a4,48(a5)
        cons->w = cons->e;
    800005f8:	0ad52a23          	sw	a3,180(a0)
        wakeup(&cons->r);
    800005fc:	0b050513          	addi	a0,a0,176
    80000600:	00002097          	auipc	ra,0x2
    80000604:	402080e7          	jalr	1026(ra) # 80002a02 <wakeup>
    80000608:	bde9                	j	800004e2 <consoleintr+0x11a>

000000008000060a <consoleinit>:

void
consoleinit(void)
{
    8000060a:	1101                	addi	sp,sp,-32
    8000060c:	ec06                	sd	ra,24(sp)
    8000060e:	e822                	sd	s0,16(sp)
    80000610:	e426                	sd	s1,8(sp)
    80000612:	1000                	addi	s0,sp,32
  initlock(&console_number_lock, "console_number_lock");
    80000614:	00013497          	auipc	s1,0x13
    80000618:	1ec48493          	addi	s1,s1,492 # 80013800 <consoles>
    8000061c:	00008597          	auipc	a1,0x8
    80000620:	b1c58593          	addi	a1,a1,-1252 # 80008138 <userret+0xa8>
    80000624:	00013517          	auipc	a0,0x13
    80000628:	41c50513          	addi	a0,a0,1052 # 80013a40 <console_number_lock>
    8000062c:	00000097          	auipc	ra,0x0
    80000630:	4f2080e7          	jalr	1266(ra) # 80000b1e <initlock>
  console_number = 0;
    80000634:	0002e797          	auipc	a5,0x2e
    80000638:	a207aa23          	sw	zero,-1484(a5) # 8002e068 <console_number>
  cons = &consoles[console_number];
    8000063c:	0002e797          	auipc	a5,0x2e
    80000640:	a297b223          	sd	s1,-1500(a5) # 8002e060 <cons>
  for(int i = 0; i < NBCONSOLES; i++){
    initlock(&consoles[i].lock, "cons");
    80000644:	00008597          	auipc	a1,0x8
    80000648:	b0c58593          	addi	a1,a1,-1268 # 80008150 <userret+0xc0>
    8000064c:	8526                	mv	a0,s1
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	4d0080e7          	jalr	1232(ra) # 80000b1e <initlock>
    80000656:	00008597          	auipc	a1,0x8
    8000065a:	afa58593          	addi	a1,a1,-1286 # 80008150 <userret+0xc0>
    8000065e:	00013517          	auipc	a0,0x13
    80000662:	26250513          	addi	a0,a0,610 # 800138c0 <consoles+0xc0>
    80000666:	00000097          	auipc	ra,0x0
    8000066a:	4b8080e7          	jalr	1208(ra) # 80000b1e <initlock>
    8000066e:	00008597          	auipc	a1,0x8
    80000672:	ae258593          	addi	a1,a1,-1310 # 80008150 <userret+0xc0>
    80000676:	00013517          	auipc	a0,0x13
    8000067a:	30a50513          	addi	a0,a0,778 # 80013980 <consoles+0x180>
    8000067e:	00000097          	auipc	ra,0x0
    80000682:	4a0080e7          	jalr	1184(ra) # 80000b1e <initlock>
  }

  uartinit();
    80000686:	00000097          	auipc	ra,0x0
    8000068a:	38a080e7          	jalr	906(ra) # 80000a10 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000068e:	00026797          	auipc	a5,0x26
    80000692:	50a78793          	addi	a5,a5,1290 # 80026b98 <devsw>
    80000696:	00000717          	auipc	a4,0x0
    8000069a:	a5670713          	addi	a4,a4,-1450 # 800000ec <consoleread>
    8000069e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800006a0:	00000717          	auipc	a4,0x0
    800006a4:	c2c70713          	addi	a4,a4,-980 # 800002cc <consolewrite>
    800006a8:	ef98                	sd	a4,24(a5)
}
    800006aa:	60e2                	ld	ra,24(sp)
    800006ac:	6442                	ld	s0,16(sp)
    800006ae:	64a2                	ld	s1,8(sp)
    800006b0:	6105                	addi	sp,sp,32
    800006b2:	8082                	ret

00000000800006b4 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800006b4:	7179                	addi	sp,sp,-48
    800006b6:	f406                	sd	ra,40(sp)
    800006b8:	f022                	sd	s0,32(sp)
    800006ba:	ec26                	sd	s1,24(sp)
    800006bc:	e84a                	sd	s2,16(sp)
    800006be:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800006c0:	c219                	beqz	a2,800006c6 <printint+0x12>
    800006c2:	08054663          	bltz	a0,8000074e <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800006c6:	2501                	sext.w	a0,a0
    800006c8:	4881                	li	a7,0
    800006ca:	fd040693          	addi	a3,s0,-48

  i = 0;
    800006ce:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800006d0:	2581                	sext.w	a1,a1
    800006d2:	00009617          	auipc	a2,0x9
    800006d6:	85660613          	addi	a2,a2,-1962 # 80008f28 <digits>
    800006da:	883a                	mv	a6,a4
    800006dc:	2705                	addiw	a4,a4,1
    800006de:	02b577bb          	remuw	a5,a0,a1
    800006e2:	1782                	slli	a5,a5,0x20
    800006e4:	9381                	srli	a5,a5,0x20
    800006e6:	97b2                	add	a5,a5,a2
    800006e8:	0007c783          	lbu	a5,0(a5)
    800006ec:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800006f0:	0005079b          	sext.w	a5,a0
    800006f4:	02b5553b          	divuw	a0,a0,a1
    800006f8:	0685                	addi	a3,a3,1
    800006fa:	feb7f0e3          	bgeu	a5,a1,800006da <printint+0x26>

  if(sign)
    800006fe:	00088b63          	beqz	a7,80000714 <printint+0x60>
    buf[i++] = '-';
    80000702:	fe040793          	addi	a5,s0,-32
    80000706:	973e                	add	a4,a4,a5
    80000708:	02d00793          	li	a5,45
    8000070c:	fef70823          	sb	a5,-16(a4)
    80000710:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000714:	02e05763          	blez	a4,80000742 <printint+0x8e>
    80000718:	fd040793          	addi	a5,s0,-48
    8000071c:	00e784b3          	add	s1,a5,a4
    80000720:	fff78913          	addi	s2,a5,-1
    80000724:	993a                	add	s2,s2,a4
    80000726:	377d                	addiw	a4,a4,-1
    80000728:	1702                	slli	a4,a4,0x20
    8000072a:	9301                	srli	a4,a4,0x20
    8000072c:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000730:	fff4c503          	lbu	a0,-1(s1)
    80000734:	00000097          	auipc	ra,0x0
    80000738:	b4a080e7          	jalr	-1206(ra) # 8000027e <consputc>
  while(--i >= 0)
    8000073c:	14fd                	addi	s1,s1,-1
    8000073e:	ff2499e3          	bne	s1,s2,80000730 <printint+0x7c>
}
    80000742:	70a2                	ld	ra,40(sp)
    80000744:	7402                	ld	s0,32(sp)
    80000746:	64e2                	ld	s1,24(sp)
    80000748:	6942                	ld	s2,16(sp)
    8000074a:	6145                	addi	sp,sp,48
    8000074c:	8082                	ret
    x = -xx;
    8000074e:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000752:	4885                	li	a7,1
    x = -xx;
    80000754:	bf9d                	j	800006ca <printint+0x16>

0000000080000756 <panic>:
  printf_locking(0, fmt, ap);
}

void
panic(char *s)
{
    80000756:	1101                	addi	sp,sp,-32
    80000758:	ec06                	sd	ra,24(sp)
    8000075a:	e822                	sd	s0,16(sp)
    8000075c:	e426                	sd	s1,8(sp)
    8000075e:	1000                	addi	s0,sp,32
    80000760:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000762:	00013797          	auipc	a5,0x13
    80000766:	3207af23          	sw	zero,830(a5) # 80013aa0 <pr+0x30>
  printf("PANIC: ");
    8000076a:	00008517          	auipc	a0,0x8
    8000076e:	9ee50513          	addi	a0,a0,-1554 # 80008158 <userret+0xc8>
    80000772:	00000097          	auipc	ra,0x0
    80000776:	1fa080e7          	jalr	506(ra) # 8000096c <printf>
  printf(s);
    8000077a:	8526                	mv	a0,s1
    8000077c:	00000097          	auipc	ra,0x0
    80000780:	1f0080e7          	jalr	496(ra) # 8000096c <printf>
  printf("\n");
    80000784:	00008517          	auipc	a0,0x8
    80000788:	ec450513          	addi	a0,a0,-316 # 80008648 <userret+0x5b8>
    8000078c:	00000097          	auipc	ra,0x0
    80000790:	1e0080e7          	jalr	480(ra) # 8000096c <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000794:	00008517          	auipc	a0,0x8
    80000798:	9cc50513          	addi	a0,a0,-1588 # 80008160 <userret+0xd0>
    8000079c:	00000097          	auipc	ra,0x0
    800007a0:	1d0080e7          	jalr	464(ra) # 8000096c <printf>
  panicked = 1; // freeze other CPUs
    800007a4:	4785                	li	a5,1
    800007a6:	0002e717          	auipc	a4,0x2e
    800007aa:	8cf72323          	sw	a5,-1850(a4) # 8002e06c <panicked>
  for(;;)
    800007ae:	a001                	j	800007ae <panic+0x58>

00000000800007b0 <printf_locking>:
{
    800007b0:	7119                	addi	sp,sp,-128
    800007b2:	fc86                	sd	ra,120(sp)
    800007b4:	f8a2                	sd	s0,112(sp)
    800007b6:	f4a6                	sd	s1,104(sp)
    800007b8:	f0ca                	sd	s2,96(sp)
    800007ba:	ecce                	sd	s3,88(sp)
    800007bc:	e8d2                	sd	s4,80(sp)
    800007be:	e4d6                	sd	s5,72(sp)
    800007c0:	e0da                	sd	s6,64(sp)
    800007c2:	fc5e                	sd	s7,56(sp)
    800007c4:	f862                	sd	s8,48(sp)
    800007c6:	f466                	sd	s9,40(sp)
    800007c8:	f06a                	sd	s10,32(sp)
    800007ca:	ec6e                	sd	s11,24(sp)
    800007cc:	0100                	addi	s0,sp,128
    800007ce:	8d2a                	mv	s10,a0
    800007d0:	8a2e                	mv	s4,a1
    800007d2:	8932                	mv	s2,a2
  if(locking)
    800007d4:	e515                	bnez	a0,80000800 <printf_locking+0x50>
  if (fmt == 0)
    800007d6:	020a0e63          	beqz	s4,80000812 <printf_locking+0x62>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800007da:	000a4503          	lbu	a0,0(s4)
    800007de:	4481                	li	s1,0
    800007e0:	14050c63          	beqz	a0,80000938 <printf_locking+0x188>
    if(c != '%'){
    800007e4:	02500a93          	li	s5,37
    switch(c){
    800007e8:	07000b13          	li	s6,112
  consputc('x');
    800007ec:	4dc1                	li	s11,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800007ee:	00008b97          	auipc	s7,0x8
    800007f2:	73ab8b93          	addi	s7,s7,1850 # 80008f28 <digits>
    switch(c){
    800007f6:	07300c93          	li	s9,115
    800007fa:	06400c13          	li	s8,100
    800007fe:	a82d                	j	80000838 <printf_locking+0x88>
    acquire(&pr.lock);
    80000800:	00013517          	auipc	a0,0x13
    80000804:	27050513          	addi	a0,a0,624 # 80013a70 <pr>
    80000808:	00000097          	auipc	ra,0x0
    8000080c:	480080e7          	jalr	1152(ra) # 80000c88 <acquire>
    80000810:	b7d9                	j	800007d6 <printf_locking+0x26>
    panic("null fmt");
    80000812:	00008517          	auipc	a0,0x8
    80000816:	a2650513          	addi	a0,a0,-1498 # 80008238 <userret+0x1a8>
    8000081a:	00000097          	auipc	ra,0x0
    8000081e:	f3c080e7          	jalr	-196(ra) # 80000756 <panic>
      consputc(c);
    80000822:	00000097          	auipc	ra,0x0
    80000826:	a5c080e7          	jalr	-1444(ra) # 8000027e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000082a:	2485                	addiw	s1,s1,1
    8000082c:	009a07b3          	add	a5,s4,s1
    80000830:	0007c503          	lbu	a0,0(a5)
    80000834:	10050263          	beqz	a0,80000938 <printf_locking+0x188>
    if(c != '%'){
    80000838:	ff5515e3          	bne	a0,s5,80000822 <printf_locking+0x72>
    c = fmt[++i] & 0xff;
    8000083c:	2485                	addiw	s1,s1,1
    8000083e:	009a07b3          	add	a5,s4,s1
    80000842:	0007c783          	lbu	a5,0(a5)
    80000846:	0007899b          	sext.w	s3,a5
    if(c == 0)
    8000084a:	c7fd                	beqz	a5,80000938 <printf_locking+0x188>
    switch(c){
    8000084c:	05678663          	beq	a5,s6,80000898 <printf_locking+0xe8>
    80000850:	02fb7463          	bgeu	s6,a5,80000878 <printf_locking+0xc8>
    80000854:	09978563          	beq	a5,s9,800008de <printf_locking+0x12e>
    80000858:	07800713          	li	a4,120
    8000085c:	0ce79163          	bne	a5,a4,8000091e <printf_locking+0x16e>
      printint(va_arg(ap, int), 16, 1);
    80000860:	00890993          	addi	s3,s2,8
    80000864:	4605                	li	a2,1
    80000866:	85ee                	mv	a1,s11
    80000868:	00092503          	lw	a0,0(s2)
    8000086c:	00000097          	auipc	ra,0x0
    80000870:	e48080e7          	jalr	-440(ra) # 800006b4 <printint>
    80000874:	894e                	mv	s2,s3
      break;
    80000876:	bf55                	j	8000082a <printf_locking+0x7a>
    switch(c){
    80000878:	09578d63          	beq	a5,s5,80000912 <printf_locking+0x162>
    8000087c:	0b879163          	bne	a5,s8,8000091e <printf_locking+0x16e>
      printint(va_arg(ap, int), 10, 1);
    80000880:	00890993          	addi	s3,s2,8
    80000884:	4605                	li	a2,1
    80000886:	45a9                	li	a1,10
    80000888:	00092503          	lw	a0,0(s2)
    8000088c:	00000097          	auipc	ra,0x0
    80000890:	e28080e7          	jalr	-472(ra) # 800006b4 <printint>
    80000894:	894e                	mv	s2,s3
      break;
    80000896:	bf51                	j	8000082a <printf_locking+0x7a>
      printptr(va_arg(ap, uint64));
    80000898:	00890793          	addi	a5,s2,8
    8000089c:	f8f43423          	sd	a5,-120(s0)
    800008a0:	00093983          	ld	s3,0(s2)
  consputc('0');
    800008a4:	03000513          	li	a0,48
    800008a8:	00000097          	auipc	ra,0x0
    800008ac:	9d6080e7          	jalr	-1578(ra) # 8000027e <consputc>
  consputc('x');
    800008b0:	07800513          	li	a0,120
    800008b4:	00000097          	auipc	ra,0x0
    800008b8:	9ca080e7          	jalr	-1590(ra) # 8000027e <consputc>
    800008bc:	896e                	mv	s2,s11
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800008be:	03c9d793          	srli	a5,s3,0x3c
    800008c2:	97de                	add	a5,a5,s7
    800008c4:	0007c503          	lbu	a0,0(a5)
    800008c8:	00000097          	auipc	ra,0x0
    800008cc:	9b6080e7          	jalr	-1610(ra) # 8000027e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800008d0:	0992                	slli	s3,s3,0x4
    800008d2:	397d                	addiw	s2,s2,-1
    800008d4:	fe0915e3          	bnez	s2,800008be <printf_locking+0x10e>
      printptr(va_arg(ap, uint64));
    800008d8:	f8843903          	ld	s2,-120(s0)
    800008dc:	b7b9                	j	8000082a <printf_locking+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    800008de:	00890993          	addi	s3,s2,8
    800008e2:	00093903          	ld	s2,0(s2)
    800008e6:	00090f63          	beqz	s2,80000904 <printf_locking+0x154>
      for(; *s; s++)
    800008ea:	00094503          	lbu	a0,0(s2)
    800008ee:	c139                	beqz	a0,80000934 <printf_locking+0x184>
        consputc(*s);
    800008f0:	00000097          	auipc	ra,0x0
    800008f4:	98e080e7          	jalr	-1650(ra) # 8000027e <consputc>
      for(; *s; s++)
    800008f8:	0905                	addi	s2,s2,1
    800008fa:	00094503          	lbu	a0,0(s2)
    800008fe:	f96d                	bnez	a0,800008f0 <printf_locking+0x140>
      if((s = va_arg(ap, char*)) == 0)
    80000900:	894e                	mv	s2,s3
    80000902:	b725                	j	8000082a <printf_locking+0x7a>
        s = "(null)";
    80000904:	00008917          	auipc	s2,0x8
    80000908:	92c90913          	addi	s2,s2,-1748 # 80008230 <userret+0x1a0>
      for(; *s; s++)
    8000090c:	02800513          	li	a0,40
    80000910:	b7c5                	j	800008f0 <printf_locking+0x140>
      consputc('%');
    80000912:	8556                	mv	a0,s5
    80000914:	00000097          	auipc	ra,0x0
    80000918:	96a080e7          	jalr	-1686(ra) # 8000027e <consputc>
      break;
    8000091c:	b739                	j	8000082a <printf_locking+0x7a>
      consputc('%');
    8000091e:	8556                	mv	a0,s5
    80000920:	00000097          	auipc	ra,0x0
    80000924:	95e080e7          	jalr	-1698(ra) # 8000027e <consputc>
      consputc(c);
    80000928:	854e                	mv	a0,s3
    8000092a:	00000097          	auipc	ra,0x0
    8000092e:	954080e7          	jalr	-1708(ra) # 8000027e <consputc>
      break;
    80000932:	bde5                	j	8000082a <printf_locking+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    80000934:	894e                	mv	s2,s3
    80000936:	bdd5                	j	8000082a <printf_locking+0x7a>
  if(locking)
    80000938:	020d1163          	bnez	s10,8000095a <printf_locking+0x1aa>
}
    8000093c:	70e6                	ld	ra,120(sp)
    8000093e:	7446                	ld	s0,112(sp)
    80000940:	74a6                	ld	s1,104(sp)
    80000942:	7906                	ld	s2,96(sp)
    80000944:	69e6                	ld	s3,88(sp)
    80000946:	6a46                	ld	s4,80(sp)
    80000948:	6aa6                	ld	s5,72(sp)
    8000094a:	6b06                	ld	s6,64(sp)
    8000094c:	7be2                	ld	s7,56(sp)
    8000094e:	7c42                	ld	s8,48(sp)
    80000950:	7ca2                	ld	s9,40(sp)
    80000952:	7d02                	ld	s10,32(sp)
    80000954:	6de2                	ld	s11,24(sp)
    80000956:	6109                	addi	sp,sp,128
    80000958:	8082                	ret
    release(&pr.lock);
    8000095a:	00013517          	auipc	a0,0x13
    8000095e:	11650513          	addi	a0,a0,278 # 80013a70 <pr>
    80000962:	00000097          	auipc	ra,0x0
    80000966:	572080e7          	jalr	1394(ra) # 80000ed4 <release>
}
    8000096a:	bfc9                	j	8000093c <printf_locking+0x18c>

000000008000096c <printf>:
printf(char *fmt, ...){
    8000096c:	711d                	addi	sp,sp,-96
    8000096e:	ec06                	sd	ra,24(sp)
    80000970:	e822                	sd	s0,16(sp)
    80000972:	1000                	addi	s0,sp,32
    80000974:	e40c                	sd	a1,8(s0)
    80000976:	e810                	sd	a2,16(s0)
    80000978:	ec14                	sd	a3,24(s0)
    8000097a:	f018                	sd	a4,32(s0)
    8000097c:	f41c                	sd	a5,40(s0)
    8000097e:	03043823          	sd	a6,48(s0)
    80000982:	03143c23          	sd	a7,56(s0)
  va_start(ap, fmt);
    80000986:	00840613          	addi	a2,s0,8
    8000098a:	fec43423          	sd	a2,-24(s0)
  printf_locking(pr.locking, fmt, ap);
    8000098e:	85aa                	mv	a1,a0
    80000990:	00013517          	auipc	a0,0x13
    80000994:	11052503          	lw	a0,272(a0) # 80013aa0 <pr+0x30>
    80000998:	00000097          	auipc	ra,0x0
    8000099c:	e18080e7          	jalr	-488(ra) # 800007b0 <printf_locking>
}
    800009a0:	60e2                	ld	ra,24(sp)
    800009a2:	6442                	ld	s0,16(sp)
    800009a4:	6125                	addi	sp,sp,96
    800009a6:	8082                	ret

00000000800009a8 <printf_no_lock>:
printf_no_lock(char *fmt, ...){
    800009a8:	711d                	addi	sp,sp,-96
    800009aa:	ec06                	sd	ra,24(sp)
    800009ac:	e822                	sd	s0,16(sp)
    800009ae:	1000                	addi	s0,sp,32
    800009b0:	e40c                	sd	a1,8(s0)
    800009b2:	e810                	sd	a2,16(s0)
    800009b4:	ec14                	sd	a3,24(s0)
    800009b6:	f018                	sd	a4,32(s0)
    800009b8:	f41c                	sd	a5,40(s0)
    800009ba:	03043823          	sd	a6,48(s0)
    800009be:	03143c23          	sd	a7,56(s0)
  va_start(ap, fmt);
    800009c2:	00840613          	addi	a2,s0,8
    800009c6:	fec43423          	sd	a2,-24(s0)
  printf_locking(0, fmt, ap);
    800009ca:	85aa                	mv	a1,a0
    800009cc:	4501                	li	a0,0
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	de2080e7          	jalr	-542(ra) # 800007b0 <printf_locking>
}
    800009d6:	60e2                	ld	ra,24(sp)
    800009d8:	6442                	ld	s0,16(sp)
    800009da:	6125                	addi	sp,sp,96
    800009dc:	8082                	ret

00000000800009de <printfinit>:
    ;
}

void
printfinit(void)
{
    800009de:	1101                	addi	sp,sp,-32
    800009e0:	ec06                	sd	ra,24(sp)
    800009e2:	e822                	sd	s0,16(sp)
    800009e4:	e426                	sd	s1,8(sp)
    800009e6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800009e8:	00013497          	auipc	s1,0x13
    800009ec:	08848493          	addi	s1,s1,136 # 80013a70 <pr>
    800009f0:	00008597          	auipc	a1,0x8
    800009f4:	85858593          	addi	a1,a1,-1960 # 80008248 <userret+0x1b8>
    800009f8:	8526                	mv	a0,s1
    800009fa:	00000097          	auipc	ra,0x0
    800009fe:	124080e7          	jalr	292(ra) # 80000b1e <initlock>
  pr.locking = 1;
    80000a02:	4785                	li	a5,1
    80000a04:	d89c                	sw	a5,48(s1)
}
    80000a06:	60e2                	ld	ra,24(sp)
    80000a08:	6442                	ld	s0,16(sp)
    80000a0a:	64a2                	ld	s1,8(sp)
    80000a0c:	6105                	addi	sp,sp,32
    80000a0e:	8082                	ret

0000000080000a10 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    80000a10:	1141                	addi	sp,sp,-16
    80000a12:	e422                	sd	s0,8(sp)
    80000a14:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000a16:	100007b7          	lui	a5,0x10000
    80000a1a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    80000a1e:	f8000713          	li	a4,-128
    80000a22:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000a26:	470d                	li	a4,3
    80000a28:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000a2c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    80000a30:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    80000a34:	471d                	li	a4,7
    80000a36:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    80000a3a:	4705                	li	a4,1
    80000a3c:	00e780a3          	sb	a4,1(a5)
}
    80000a40:	6422                	ld	s0,8(sp)
    80000a42:	0141                	addi	sp,sp,16
    80000a44:	8082                	ret

0000000080000a46 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    80000a46:	1141                	addi	sp,sp,-16
    80000a48:	e422                	sd	s0,8(sp)
    80000a4a:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    80000a4c:	10000737          	lui	a4,0x10000
    80000a50:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000a54:	0ff7f793          	andi	a5,a5,255
    80000a58:	0207f793          	andi	a5,a5,32
    80000a5c:	dbf5                	beqz	a5,80000a50 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    80000a5e:	0ff57513          	andi	a0,a0,255
    80000a62:	100007b7          	lui	a5,0x10000
    80000a66:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    80000a6a:	6422                	ld	s0,8(sp)
    80000a6c:	0141                	addi	sp,sp,16
    80000a6e:	8082                	ret

0000000080000a70 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000a70:	1141                	addi	sp,sp,-16
    80000a72:	e422                	sd	s0,8(sp)
    80000a74:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a76:	100007b7          	lui	a5,0x10000
    80000a7a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a7e:	8b85                	andi	a5,a5,1
    80000a80:	cb91                	beqz	a5,80000a94 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a82:	100007b7          	lui	a5,0x10000
    80000a86:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a8a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a8e:	6422                	ld	s0,8(sp)
    80000a90:	0141                	addi	sp,sp,16
    80000a92:	8082                	ret
    return -1;
    80000a94:	557d                	li	a0,-1
    80000a96:	bfe5                	j	80000a8e <uartgetc+0x1e>

0000000080000a98 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000a98:	1101                	addi	sp,sp,-32
    80000a9a:	ec06                	sd	ra,24(sp)
    80000a9c:	e822                	sd	s0,16(sp)
    80000a9e:	e426                	sd	s1,8(sp)
    80000aa0:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000aa2:	54fd                	li	s1,-1
    int c = uartgetc();
    80000aa4:	00000097          	auipc	ra,0x0
    80000aa8:	fcc080e7          	jalr	-52(ra) # 80000a70 <uartgetc>
    if(c == -1)
    80000aac:	00950763          	beq	a0,s1,80000aba <uartintr+0x22>
      break;
    consoleintr(c);
    80000ab0:	00000097          	auipc	ra,0x0
    80000ab4:	918080e7          	jalr	-1768(ra) # 800003c8 <consoleintr>
  while(1){
    80000ab8:	b7f5                	j	80000aa4 <uartintr+0xc>
  }
}
    80000aba:	60e2                	ld	ra,24(sp)
    80000abc:	6442                	ld	s0,16(sp)
    80000abe:	64a2                	ld	s1,8(sp)
    80000ac0:	6105                	addi	sp,sp,32
    80000ac2:	8082                	ret

0000000080000ac4 <kinit>:
extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

void
kinit()
{
    80000ac4:	1141                	addi	sp,sp,-16
    80000ac6:	e406                	sd	ra,8(sp)
    80000ac8:	e022                	sd	s0,0(sp)
    80000aca:	0800                	addi	s0,sp,16
  char *p = (char *) PGROUNDUP((uint64) end);
  bd_init(p, (void*)PHYSTOP);
    80000acc:	45c5                	li	a1,17
    80000ace:	05ee                	slli	a1,a1,0x1b
    80000ad0:	0002e517          	auipc	a0,0x2e
    80000ad4:	5db50513          	addi	a0,a0,1499 # 8002f0ab <end+0xfff>
    80000ad8:	77fd                	lui	a5,0xfffff
    80000ada:	8d7d                	and	a0,a0,a5
    80000adc:	00007097          	auipc	ra,0x7
    80000ae0:	abe080e7          	jalr	-1346(ra) # 8000759a <bd_init>
}
    80000ae4:	60a2                	ld	ra,8(sp)
    80000ae6:	6402                	ld	s0,0(sp)
    80000ae8:	0141                	addi	sp,sp,16
    80000aea:	8082                	ret

0000000080000aec <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000aec:	1141                	addi	sp,sp,-16
    80000aee:	e406                	sd	ra,8(sp)
    80000af0:	e022                	sd	s0,0(sp)
    80000af2:	0800                	addi	s0,sp,16
  bd_free(pa);
    80000af4:	00006097          	auipc	ra,0x6
    80000af8:	5e8080e7          	jalr	1512(ra) # 800070dc <bd_free>
}
    80000afc:	60a2                	ld	ra,8(sp)
    80000afe:	6402                	ld	s0,0(sp)
    80000b00:	0141                	addi	sp,sp,16
    80000b02:	8082                	ret

0000000080000b04 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b04:	1141                	addi	sp,sp,-16
    80000b06:	e406                	sd	ra,8(sp)
    80000b08:	e022                	sd	s0,0(sp)
    80000b0a:	0800                	addi	s0,sp,16
  return bd_malloc(PGSIZE);
    80000b0c:	6505                	lui	a0,0x1
    80000b0e:	00006097          	auipc	ra,0x6
    80000b12:	3e2080e7          	jalr	994(ra) # 80006ef0 <bd_malloc>
}
    80000b16:	60a2                	ld	ra,8(sp)
    80000b18:	6402                	ld	s0,0(sp)
    80000b1a:	0141                	addi	sp,sp,16
    80000b1c:	8082                	ret

0000000080000b1e <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    80000b1e:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b20:	00052023          	sw	zero,0(a0) # 1000 <_entry-0x7ffff000>
  lk->cpu = 0;
    80000b24:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000b28:	02052423          	sw	zero,40(a0)
  lk->n = 0;
    80000b2c:	02052223          	sw	zero,36(a0)
  if(nlock >= NLOCK)
    80000b30:	0002d797          	auipc	a5,0x2d
    80000b34:	5407a783          	lw	a5,1344(a5) # 8002e070 <nlock>
    80000b38:	3e700713          	li	a4,999
    80000b3c:	02f74063          	blt	a4,a5,80000b5c <initlock+0x3e>
    panic("initlock");
  locks[nlock] = lk;
    80000b40:	00379693          	slli	a3,a5,0x3
    80000b44:	00013717          	auipc	a4,0x13
    80000b48:	f6470713          	addi	a4,a4,-156 # 80013aa8 <locks>
    80000b4c:	9736                	add	a4,a4,a3
    80000b4e:	e308                	sd	a0,0(a4)
  nlock++;
    80000b50:	2785                	addiw	a5,a5,1
    80000b52:	0002d717          	auipc	a4,0x2d
    80000b56:	50f72f23          	sw	a5,1310(a4) # 8002e070 <nlock>
    80000b5a:	8082                	ret
{
    80000b5c:	1141                	addi	sp,sp,-16
    80000b5e:	e406                	sd	ra,8(sp)
    80000b60:	e022                	sd	s0,0(sp)
    80000b62:	0800                	addi	s0,sp,16
    panic("initlock");
    80000b64:	00007517          	auipc	a0,0x7
    80000b68:	6ec50513          	addi	a0,a0,1772 # 80008250 <userret+0x1c0>
    80000b6c:	00000097          	auipc	ra,0x0
    80000b70:	bea080e7          	jalr	-1046(ra) # 80000756 <panic>

0000000080000b74 <dump_locks>:
}

void dump_locks(void){
    80000b74:	7139                	addi	sp,sp,-64
    80000b76:	fc06                	sd	ra,56(sp)
    80000b78:	f822                	sd	s0,48(sp)
    80000b7a:	f426                	sd	s1,40(sp)
    80000b7c:	f04a                	sd	s2,32(sp)
    80000b7e:	ec4e                	sd	s3,24(sp)
    80000b80:	e852                	sd	s4,16(sp)
    80000b82:	e456                	sd	s5,8(sp)
    80000b84:	0080                	addi	s0,sp,64
  printf_no_lock("LID\tLOCKED\tCPU\tPID\tNAME\t\tPC\n");
    80000b86:	00007517          	auipc	a0,0x7
    80000b8a:	6da50513          	addi	a0,a0,1754 # 80008260 <userret+0x1d0>
    80000b8e:	00000097          	auipc	ra,0x0
    80000b92:	e1a080e7          	jalr	-486(ra) # 800009a8 <printf_no_lock>
  for(int i = 0; i < nlock; i++){
    80000b96:	0002d797          	auipc	a5,0x2d
    80000b9a:	4da7a783          	lw	a5,1242(a5) # 8002e070 <nlock>
    80000b9e:	04f05d63          	blez	a5,80000bf8 <dump_locks+0x84>
    80000ba2:	00013917          	auipc	s2,0x13
    80000ba6:	f0690913          	addi	s2,s2,-250 # 80013aa8 <locks>
    80000baa:	4481                	li	s1,0
    if(locks[i]->locked)
      printf_no_lock("%d\t%d\t%d\t%d\t%s\t\t%p\n",
                     i,
                     locks[i]->locked,
                     locks[i]->cpu - cpus,
    80000bac:	00015a97          	auipc	s5,0x15
    80000bb0:	eeca8a93          	addi	s5,s5,-276 # 80015a98 <cpus>
      printf_no_lock("%d\t%d\t%d\t%d\t%s\t\t%p\n",
    80000bb4:	00007a17          	auipc	s4,0x7
    80000bb8:	6cca0a13          	addi	s4,s4,1740 # 80008280 <userret+0x1f0>
  for(int i = 0; i < nlock; i++){
    80000bbc:	0002d997          	auipc	s3,0x2d
    80000bc0:	4b498993          	addi	s3,s3,1204 # 8002e070 <nlock>
    80000bc4:	a02d                	j	80000bee <dump_locks+0x7a>
                     locks[i]->cpu - cpus,
    80000bc6:	6b14                	ld	a3,16(a4)
    80000bc8:	415686b3          	sub	a3,a3,s5
      printf_no_lock("%d\t%d\t%d\t%d\t%s\t\t%p\n",
    80000bcc:	01873803          	ld	a6,24(a4)
    80000bd0:	671c                	ld	a5,8(a4)
    80000bd2:	5318                	lw	a4,32(a4)
    80000bd4:	869d                	srai	a3,a3,0x7
    80000bd6:	85a6                	mv	a1,s1
    80000bd8:	8552                	mv	a0,s4
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	dce080e7          	jalr	-562(ra) # 800009a8 <printf_no_lock>
  for(int i = 0; i < nlock; i++){
    80000be2:	2485                	addiw	s1,s1,1
    80000be4:	0921                	addi	s2,s2,8
    80000be6:	0009a783          	lw	a5,0(s3)
    80000bea:	00f4d763          	bge	s1,a5,80000bf8 <dump_locks+0x84>
    if(locks[i]->locked)
    80000bee:	00093703          	ld	a4,0(s2)
    80000bf2:	4310                	lw	a2,0(a4)
    80000bf4:	d67d                	beqz	a2,80000be2 <dump_locks+0x6e>
    80000bf6:	bfc1                	j	80000bc6 <dump_locks+0x52>
                     locks[i]->pid,
                     locks[i]->name,
                     locks[i]->pc
        );
  }
}
    80000bf8:	70e2                	ld	ra,56(sp)
    80000bfa:	7442                	ld	s0,48(sp)
    80000bfc:	74a2                	ld	s1,40(sp)
    80000bfe:	7902                	ld	s2,32(sp)
    80000c00:	69e2                	ld	s3,24(sp)
    80000c02:	6a42                	ld	s4,16(sp)
    80000c04:	6aa2                	ld	s5,8(sp)
    80000c06:	6121                	addi	sp,sp,64
    80000c08:	8082                	ret

0000000080000c0a <holding>:
// Must be called with interrupts off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c0a:	411c                	lw	a5,0(a0)
    80000c0c:	e399                	bnez	a5,80000c12 <holding+0x8>
    80000c0e:	4501                	li	a0,0
  return r;
}
    80000c10:	8082                	ret
{
    80000c12:	1101                	addi	sp,sp,-32
    80000c14:	ec06                	sd	ra,24(sp)
    80000c16:	e822                	sd	s0,16(sp)
    80000c18:	e426                	sd	s1,8(sp)
    80000c1a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c1c:	6904                	ld	s1,16(a0)
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	362080e7          	jalr	866(ra) # 80001f80 <mycpu>
    80000c26:	40a48533          	sub	a0,s1,a0
    80000c2a:	00153513          	seqz	a0,a0
}
    80000c2e:	60e2                	ld	ra,24(sp)
    80000c30:	6442                	ld	s0,16(sp)
    80000c32:	64a2                	ld	s1,8(sp)
    80000c34:	6105                	addi	sp,sp,32
    80000c36:	8082                	ret

0000000080000c38 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c38:	1101                	addi	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100024f3          	csrr	s1,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c46:	8889                	andi	s1,s1,2
  int old = intr_get();
  if(old)
    80000c48:	c491                	beqz	s1,80000c54 <push_off+0x1c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c4e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c50:	10079073          	csrw	sstatus,a5
    intr_off();
  if(mycpu()->noff == 0)
    80000c54:	00001097          	auipc	ra,0x1
    80000c58:	32c080e7          	jalr	812(ra) # 80001f80 <mycpu>
    80000c5c:	5d3c                	lw	a5,120(a0)
    80000c5e:	cf89                	beqz	a5,80000c78 <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c60:	00001097          	auipc	ra,0x1
    80000c64:	320080e7          	jalr	800(ra) # 80001f80 <mycpu>
    80000c68:	5d3c                	lw	a5,120(a0)
    80000c6a:	2785                	addiw	a5,a5,1
    80000c6c:	dd3c                	sw	a5,120(a0)
}
    80000c6e:	60e2                	ld	ra,24(sp)
    80000c70:	6442                	ld	s0,16(sp)
    80000c72:	64a2                	ld	s1,8(sp)
    80000c74:	6105                	addi	sp,sp,32
    80000c76:	8082                	ret
    mycpu()->intena = old;
    80000c78:	00001097          	auipc	ra,0x1
    80000c7c:	308080e7          	jalr	776(ra) # 80001f80 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c80:	009034b3          	snez	s1,s1
    80000c84:	dd64                	sw	s1,124(a0)
    80000c86:	bfe9                	j	80000c60 <push_off+0x28>

0000000080000c88 <acquire>:
{
    80000c88:	7159                	addi	sp,sp,-112
    80000c8a:	f486                	sd	ra,104(sp)
    80000c8c:	f0a2                	sd	s0,96(sp)
    80000c8e:	eca6                	sd	s1,88(sp)
    80000c90:	e8ca                	sd	s2,80(sp)
    80000c92:	e4ce                	sd	s3,72(sp)
    80000c94:	e0d2                	sd	s4,64(sp)
    80000c96:	fc56                	sd	s5,56(sp)
    80000c98:	f85a                	sd	s6,48(sp)
    80000c9a:	f45e                	sd	s7,40(sp)
    80000c9c:	f062                	sd	s8,32(sp)
    80000c9e:	ec66                	sd	s9,24(sp)
    80000ca0:	e86a                	sd	s10,16(sp)
    80000ca2:	e46e                	sd	s11,8(sp)
    80000ca4:	1880                	addi	s0,sp,112
    80000ca6:	84aa                	mv	s1,a0
  asm volatile("mv %0, ra" : "=r" (ra));
    80000ca8:	8a86                	mv	s5,ra
  ra -= 4;
    80000caa:	1af1                	addi	s5,s5,-4
  push_off(); // disable interrupts to avoid deadlock.
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f8c080e7          	jalr	-116(ra) # 80000c38 <push_off>
  if(holding(lk)){
    80000cb4:	8526                	mv	a0,s1
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	f54080e7          	jalr	-172(ra) # 80000c0a <holding>
    80000cbe:	e121                	bnez	a0,80000cfe <acquire+0x76>
    80000cc0:	892a                	mv	s2,a0
  __sync_fetch_and_add(&(lk->n), 1);
    80000cc2:	4785                	li	a5,1
    80000cc4:	02448713          	addi	a4,s1,36
    80000cc8:	0f50000f          	fence	iorw,ow
    80000ccc:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  int warned = 0;
    80000cd0:	872a                	mv	a4,a0
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000cd2:	4985                	li	s3,1
    if(nbtries > MAXTRIES && !warned){
    80000cd4:	6a61                	lui	s4,0x18
    80000cd6:	6a0a0a13          	addi	s4,s4,1696 # 186a0 <_entry-0x7ffe7960>
      printf_no_lock("CPU %d: Blocked while acquiring %s (%p)\n", cpuid(), lk->name, lk);
    80000cda:	00007d17          	auipc	s10,0x7
    80000cde:	646d0d13          	addi	s10,s10,1606 # 80008320 <userret+0x290>
                     lk->cpu - cpus,
    80000ce2:	00015c97          	auipc	s9,0x15
    80000ce6:	db6c8c93          	addi	s9,s9,-586 # 80015a98 <cpus>
      printf_no_lock("process %d (CPU %d) took it at pc=%p \n", lk->pid,
    80000cea:	00007c17          	auipc	s8,0x7
    80000cee:	5d6c0c13          	addi	s8,s8,1494 # 800082c0 <userret+0x230>
      printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000cf2:	5bfd                	li	s7,-1
    80000cf4:	00007b17          	auipc	s6,0x7
    80000cf8:	5f4b0b13          	addi	s6,s6,1524 # 800082e8 <userret+0x258>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000cfc:	a84d                	j	80000dae <acquire+0x126>
    printf_no_lock("requesting %s (%p) but already have it\n", lk->name, lk);
    80000cfe:	8626                	mv	a2,s1
    80000d00:	648c                	ld	a1,8(s1)
    80000d02:	00007517          	auipc	a0,0x7
    80000d06:	59650513          	addi	a0,a0,1430 # 80008298 <userret+0x208>
    80000d0a:	00000097          	auipc	ra,0x0
    80000d0e:	c9e080e7          	jalr	-866(ra) # 800009a8 <printf_no_lock>
                   lk->cpu - cpus,
    80000d12:	6890                	ld	a2,16(s1)
    80000d14:	00015797          	auipc	a5,0x15
    80000d18:	d8478793          	addi	a5,a5,-636 # 80015a98 <cpus>
    80000d1c:	8e1d                	sub	a2,a2,a5
    printf_no_lock("process %d (CPU %d) took it at pc=%p \n", lk->pid,
    80000d1e:	6c94                	ld	a3,24(s1)
    80000d20:	861d                	srai	a2,a2,0x7
    80000d22:	508c                	lw	a1,32(s1)
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	59c50513          	addi	a0,a0,1436 # 800082c0 <userret+0x230>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	c7c080e7          	jalr	-900(ra) # 800009a8 <printf_no_lock>
                   myproc() ? myproc()->pid : -1,
    80000d34:	00001097          	auipc	ra,0x1
    80000d38:	268080e7          	jalr	616(ra) # 80001f9c <myproc>
    printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000d3c:	54fd                	li	s1,-1
    80000d3e:	c511                	beqz	a0,80000d4a <acquire+0xc2>
                   myproc() ? myproc()->pid : -1,
    80000d40:	00001097          	auipc	ra,0x1
    80000d44:	25c080e7          	jalr	604(ra) # 80001f9c <myproc>
    printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000d48:	4924                	lw	s1,80(a0)
    80000d4a:	00001097          	auipc	ra,0x1
    80000d4e:	226080e7          	jalr	550(ra) # 80001f70 <cpuid>
    80000d52:	86aa                	mv	a3,a0
    80000d54:	8626                	mv	a2,s1
    80000d56:	85d6                	mv	a1,s5
    80000d58:	00007517          	auipc	a0,0x7
    80000d5c:	59050513          	addi	a0,a0,1424 # 800082e8 <userret+0x258>
    80000d60:	00000097          	auipc	ra,0x0
    80000d64:	c48080e7          	jalr	-952(ra) # 800009a8 <printf_no_lock>
    procdump();
    80000d68:	00002097          	auipc	ra,0x2
    80000d6c:	e22080e7          	jalr	-478(ra) # 80002b8a <procdump>
    panic("acquire");
    80000d70:	00007517          	auipc	a0,0x7
    80000d74:	5a850513          	addi	a0,a0,1448 # 80008318 <userret+0x288>
    80000d78:	00000097          	auipc	ra,0x0
    80000d7c:	9de080e7          	jalr	-1570(ra) # 80000756 <panic>
      printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000d80:	00001097          	auipc	ra,0x1
    80000d84:	1f0080e7          	jalr	496(ra) # 80001f70 <cpuid>
    80000d88:	86aa                	mv	a3,a0
    80000d8a:	866e                	mv	a2,s11
    80000d8c:	85d6                	mv	a1,s5
    80000d8e:	855a                	mv	a0,s6
    80000d90:	00000097          	auipc	ra,0x0
    80000d94:	c18080e7          	jalr	-1000(ra) # 800009a8 <printf_no_lock>
      procdump();
    80000d98:	00002097          	auipc	ra,0x2
    80000d9c:	df2080e7          	jalr	-526(ra) # 80002b8a <procdump>
      warned = 1;
    80000da0:	4705                	li	a4,1
     __sync_fetch_and_add(&lk->nts, 1);
    80000da2:	02848793          	addi	a5,s1,40
    80000da6:	0f50000f          	fence	iorw,ow
    80000daa:	0537a02f          	amoadd.w.aq	zero,s3,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000dae:	87ce                	mv	a5,s3
    80000db0:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000db4:	2781                	sext.w	a5,a5
    80000db6:	cba9                	beqz	a5,80000e08 <acquire+0x180>
    nbtries++;
    80000db8:	2905                	addiw	s2,s2,1
    if(nbtries > MAXTRIES && !warned){
    80000dba:	ff2a54e3          	bge	s4,s2,80000da2 <acquire+0x11a>
    80000dbe:	f375                	bnez	a4,80000da2 <acquire+0x11a>
      printf_no_lock("CPU %d: Blocked while acquiring %s (%p)\n", cpuid(), lk->name, lk);
    80000dc0:	00001097          	auipc	ra,0x1
    80000dc4:	1b0080e7          	jalr	432(ra) # 80001f70 <cpuid>
    80000dc8:	85aa                	mv	a1,a0
    80000dca:	86a6                	mv	a3,s1
    80000dcc:	6490                	ld	a2,8(s1)
    80000dce:	856a                	mv	a0,s10
    80000dd0:	00000097          	auipc	ra,0x0
    80000dd4:	bd8080e7          	jalr	-1064(ra) # 800009a8 <printf_no_lock>
                     lk->cpu - cpus,
    80000dd8:	6890                	ld	a2,16(s1)
    80000dda:	41960633          	sub	a2,a2,s9
      printf_no_lock("process %d (CPU %d) took it at pc=%p \n", lk->pid,
    80000dde:	6c94                	ld	a3,24(s1)
    80000de0:	861d                	srai	a2,a2,0x7
    80000de2:	508c                	lw	a1,32(s1)
    80000de4:	8562                	mv	a0,s8
    80000de6:	00000097          	auipc	ra,0x0
    80000dea:	bc2080e7          	jalr	-1086(ra) # 800009a8 <printf_no_lock>
                     myproc() ? myproc()->pid : -1,
    80000dee:	00001097          	auipc	ra,0x1
    80000df2:	1ae080e7          	jalr	430(ra) # 80001f9c <myproc>
      printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000df6:	8dde                	mv	s11,s7
    80000df8:	d541                	beqz	a0,80000d80 <acquire+0xf8>
                     myproc() ? myproc()->pid : -1,
    80000dfa:	00001097          	auipc	ra,0x1
    80000dfe:	1a2080e7          	jalr	418(ra) # 80001f9c <myproc>
      printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000e02:	05052d83          	lw	s11,80(a0)
    80000e06:	bfad                	j	80000d80 <acquire+0xf8>
  if(warned){
    80000e08:	e729                	bnez	a4,80000e52 <acquire+0x1ca>
  __sync_synchronize();
    80000e0a:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000e0e:	00001097          	auipc	ra,0x1
    80000e12:	172080e7          	jalr	370(ra) # 80001f80 <mycpu>
    80000e16:	e888                	sd	a0,16(s1)
  lk->pc = ra;
    80000e18:	0154bc23          	sd	s5,24(s1)
  lk->pid = myproc() ? myproc()->pid : -1;
    80000e1c:	00001097          	auipc	ra,0x1
    80000e20:	180080e7          	jalr	384(ra) # 80001f9c <myproc>
    80000e24:	57fd                	li	a5,-1
    80000e26:	c511                	beqz	a0,80000e32 <acquire+0x1aa>
    80000e28:	00001097          	auipc	ra,0x1
    80000e2c:	174080e7          	jalr	372(ra) # 80001f9c <myproc>
    80000e30:	493c                	lw	a5,80(a0)
    80000e32:	d09c                	sw	a5,32(s1)
}
    80000e34:	70a6                	ld	ra,104(sp)
    80000e36:	7406                	ld	s0,96(sp)
    80000e38:	64e6                	ld	s1,88(sp)
    80000e3a:	6946                	ld	s2,80(sp)
    80000e3c:	69a6                	ld	s3,72(sp)
    80000e3e:	6a06                	ld	s4,64(sp)
    80000e40:	7ae2                	ld	s5,56(sp)
    80000e42:	7b42                	ld	s6,48(sp)
    80000e44:	7ba2                	ld	s7,40(sp)
    80000e46:	7c02                	ld	s8,32(sp)
    80000e48:	6ce2                	ld	s9,24(sp)
    80000e4a:	6d42                	ld	s10,16(sp)
    80000e4c:	6da2                	ld	s11,8(sp)
    80000e4e:	6165                	addi	sp,sp,112
    80000e50:	8082                	ret
    printf_no_lock("CPU %d: Finally acquired %s (%p) after %d tries\n", cpuid(), lk->name, lk, nbtries);
    80000e52:	00001097          	auipc	ra,0x1
    80000e56:	11e080e7          	jalr	286(ra) # 80001f70 <cpuid>
    80000e5a:	85aa                	mv	a1,a0
    80000e5c:	874a                	mv	a4,s2
    80000e5e:	86a6                	mv	a3,s1
    80000e60:	6490                	ld	a2,8(s1)
    80000e62:	00007517          	auipc	a0,0x7
    80000e66:	4ee50513          	addi	a0,a0,1262 # 80008350 <userret+0x2c0>
    80000e6a:	00000097          	auipc	ra,0x0
    80000e6e:	b3e080e7          	jalr	-1218(ra) # 800009a8 <printf_no_lock>
    80000e72:	bf61                	j	80000e0a <acquire+0x182>

0000000080000e74 <pop_off>:

void
pop_off(void)
{
    80000e74:	1141                	addi	sp,sp,-16
    80000e76:	e406                	sd	ra,8(sp)
    80000e78:	e022                	sd	s0,0(sp)
    80000e7a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e7c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e80:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e82:	eb8d                	bnez	a5,80000eb4 <pop_off+0x40>
    panic("pop_off - interruptible");
  struct cpu *c = mycpu();
    80000e84:	00001097          	auipc	ra,0x1
    80000e88:	0fc080e7          	jalr	252(ra) # 80001f80 <mycpu>
  if(c->noff < 1)
    80000e8c:	5d3c                	lw	a5,120(a0)
    80000e8e:	02f05b63          	blez	a5,80000ec4 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e92:	37fd                	addiw	a5,a5,-1
    80000e94:	0007871b          	sext.w	a4,a5
    80000e98:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e9a:	eb09                	bnez	a4,80000eac <pop_off+0x38>
    80000e9c:	5d7c                	lw	a5,124(a0)
    80000e9e:	c799                	beqz	a5,80000eac <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ea0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ea4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ea8:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000eac:	60a2                	ld	ra,8(sp)
    80000eae:	6402                	ld	s0,0(sp)
    80000eb0:	0141                	addi	sp,sp,16
    80000eb2:	8082                	ret
    panic("pop_off - interruptible");
    80000eb4:	00007517          	auipc	a0,0x7
    80000eb8:	4d450513          	addi	a0,a0,1236 # 80008388 <userret+0x2f8>
    80000ebc:	00000097          	auipc	ra,0x0
    80000ec0:	89a080e7          	jalr	-1894(ra) # 80000756 <panic>
    panic("pop_off");
    80000ec4:	00007517          	auipc	a0,0x7
    80000ec8:	4dc50513          	addi	a0,a0,1244 # 800083a0 <userret+0x310>
    80000ecc:	00000097          	auipc	ra,0x0
    80000ed0:	88a080e7          	jalr	-1910(ra) # 80000756 <panic>

0000000080000ed4 <release>:
{
    80000ed4:	1101                	addi	sp,sp,-32
    80000ed6:	ec06                	sd	ra,24(sp)
    80000ed8:	e822                	sd	s0,16(sp)
    80000eda:	e426                	sd	s1,8(sp)
    80000edc:	1000                	addi	s0,sp,32
    80000ede:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ee0:	00000097          	auipc	ra,0x0
    80000ee4:	d2a080e7          	jalr	-726(ra) # 80000c0a <holding>
    80000ee8:	c115                	beqz	a0,80000f0c <release+0x38>
  lk->cpu = 0;
    80000eea:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000eee:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ef2:	0f50000f          	fence	iorw,ow
    80000ef6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	f7a080e7          	jalr	-134(ra) # 80000e74 <pop_off>
}
    80000f02:	60e2                	ld	ra,24(sp)
    80000f04:	6442                	ld	s0,16(sp)
    80000f06:	64a2                	ld	s1,8(sp)
    80000f08:	6105                	addi	sp,sp,32
    80000f0a:	8082                	ret
    panic("release");
    80000f0c:	00007517          	auipc	a0,0x7
    80000f10:	49c50513          	addi	a0,a0,1180 # 800083a8 <userret+0x318>
    80000f14:	00000097          	auipc	ra,0x0
    80000f18:	842080e7          	jalr	-1982(ra) # 80000756 <panic>

0000000080000f1c <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000f1c:	5154                	lw	a3,36(a0)
    80000f1e:	e291                	bnez	a3,80000f22 <print_lock+0x6>
    80000f20:	8082                	ret
{
    80000f22:	1141                	addi	sp,sp,-16
    80000f24:	e406                	sd	ra,8(sp)
    80000f26:	e022                	sd	s0,0(sp)
    80000f28:	0800                	addi	s0,sp,16
    printf("lock: %s: #test-and-set %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000f2a:	5510                	lw	a2,40(a0)
    80000f2c:	650c                	ld	a1,8(a0)
    80000f2e:	00007517          	auipc	a0,0x7
    80000f32:	48250513          	addi	a0,a0,1154 # 800083b0 <userret+0x320>
    80000f36:	00000097          	auipc	ra,0x0
    80000f3a:	a36080e7          	jalr	-1482(ra) # 8000096c <printf>
}
    80000f3e:	60a2                	ld	ra,8(sp)
    80000f40:	6402                	ld	s0,0(sp)
    80000f42:	0141                	addi	sp,sp,16
    80000f44:	8082                	ret

0000000080000f46 <sys_ntas>:

uint64
sys_ntas(void)
{
    80000f46:	711d                	addi	sp,sp,-96
    80000f48:	ec86                	sd	ra,88(sp)
    80000f4a:	e8a2                	sd	s0,80(sp)
    80000f4c:	e4a6                	sd	s1,72(sp)
    80000f4e:	e0ca                	sd	s2,64(sp)
    80000f50:	fc4e                	sd	s3,56(sp)
    80000f52:	f852                	sd	s4,48(sp)
    80000f54:	f456                	sd	s5,40(sp)
    80000f56:	f05a                	sd	s6,32(sp)
    80000f58:	ec5e                	sd	s7,24(sp)
    80000f5a:	e862                	sd	s8,16(sp)
    80000f5c:	1080                	addi	s0,sp,96
  int zero = 0;
    80000f5e:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000f62:	fac40593          	addi	a1,s0,-84
    80000f66:	4501                	li	a0,0
    80000f68:	00002097          	auipc	ra,0x2
    80000f6c:	35a080e7          	jalr	858(ra) # 800032c2 <argint>
    80000f70:	14054e63          	bltz	a0,800010cc <sys_ntas+0x186>
    return -1;
  }
  if(zero == 0) {
    80000f74:	fac42783          	lw	a5,-84(s0)
    80000f78:	e795                	bnez	a5,80000fa4 <sys_ntas+0x5e>
    80000f7a:	00013797          	auipc	a5,0x13
    80000f7e:	b2e78793          	addi	a5,a5,-1234 # 80013aa8 <locks>
    80000f82:	00015697          	auipc	a3,0x15
    80000f86:	a6668693          	addi	a3,a3,-1434 # 800159e8 <prio>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000f8a:	6398                	ld	a4,0(a5)
    80000f8c:	14070263          	beqz	a4,800010d0 <sys_ntas+0x18a>
        break;
      locks[i]->nts = 0;
    80000f90:	02072423          	sw	zero,40(a4)
      locks[i]->n = 0;
    80000f94:	6398                	ld	a4,0(a5)
    80000f96:	02072223          	sw	zero,36(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000f9a:	07a1                	addi	a5,a5,8
    80000f9c:	fed797e3          	bne	a5,a3,80000f8a <sys_ntas+0x44>
    }
    return 0;
    80000fa0:	4501                	li	a0,0
    80000fa2:	aa09                	j	800010b4 <sys_ntas+0x16e>
  }

  printf("=== lock kmem/bcache stats\n");
    80000fa4:	00007517          	auipc	a0,0x7
    80000fa8:	43c50513          	addi	a0,a0,1084 # 800083e0 <userret+0x350>
    80000fac:	00000097          	auipc	ra,0x0
    80000fb0:	9c0080e7          	jalr	-1600(ra) # 8000096c <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000fb4:	00013b17          	auipc	s6,0x13
    80000fb8:	af4b0b13          	addi	s6,s6,-1292 # 80013aa8 <locks>
    80000fbc:	00015b97          	auipc	s7,0x15
    80000fc0:	a2cb8b93          	addi	s7,s7,-1492 # 800159e8 <prio>
  printf("=== lock kmem/bcache stats\n");
    80000fc4:	84da                	mv	s1,s6
  int tot = 0;
    80000fc6:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000fc8:	00007a17          	auipc	s4,0x7
    80000fcc:	438a0a13          	addi	s4,s4,1080 # 80008400 <userret+0x370>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000fd0:	00007c17          	auipc	s8,0x7
    80000fd4:	438c0c13          	addi	s8,s8,1080 # 80008408 <userret+0x378>
    80000fd8:	a829                	j	80000ff2 <sys_ntas+0xac>
      tot += locks[i]->nts;
    80000fda:	00093503          	ld	a0,0(s2)
    80000fde:	551c                	lw	a5,40(a0)
    80000fe0:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000fe4:	00000097          	auipc	ra,0x0
    80000fe8:	f38080e7          	jalr	-200(ra) # 80000f1c <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80000fec:	04a1                	addi	s1,s1,8
    80000fee:	05748763          	beq	s1,s7,8000103c <sys_ntas+0xf6>
    if(locks[i] == 0)
    80000ff2:	8926                	mv	s2,s1
    80000ff4:	609c                	ld	a5,0(s1)
    80000ff6:	c3b9                	beqz	a5,8000103c <sys_ntas+0xf6>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000ff8:	0087ba83          	ld	s5,8(a5)
    80000ffc:	8552                	mv	a0,s4
    80000ffe:	00000097          	auipc	ra,0x0
    80001002:	25e080e7          	jalr	606(ra) # 8000125c <strlen>
    80001006:	0005061b          	sext.w	a2,a0
    8000100a:	85d2                	mv	a1,s4
    8000100c:	8556                	mv	a0,s5
    8000100e:	00000097          	auipc	ra,0x0
    80001012:	1a2080e7          	jalr	418(ra) # 800011b0 <strncmp>
    80001016:	d171                	beqz	a0,80000fda <sys_ntas+0x94>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80001018:	609c                	ld	a5,0(s1)
    8000101a:	0087ba83          	ld	s5,8(a5)
    8000101e:	8562                	mv	a0,s8
    80001020:	00000097          	auipc	ra,0x0
    80001024:	23c080e7          	jalr	572(ra) # 8000125c <strlen>
    80001028:	0005061b          	sext.w	a2,a0
    8000102c:	85e2                	mv	a1,s8
    8000102e:	8556                	mv	a0,s5
    80001030:	00000097          	auipc	ra,0x0
    80001034:	180080e7          	jalr	384(ra) # 800011b0 <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80001038:	f955                	bnez	a0,80000fec <sys_ntas+0xa6>
    8000103a:	b745                	j	80000fda <sys_ntas+0x94>
    }
  }

  printf("=== top 5 contended locks:\n");
    8000103c:	00007517          	auipc	a0,0x7
    80001040:	3d450513          	addi	a0,a0,980 # 80008410 <userret+0x380>
    80001044:	00000097          	auipc	ra,0x0
    80001048:	928080e7          	jalr	-1752(ra) # 8000096c <printf>
    8000104c:	4a15                	li	s4,5
  int last = 100000000;
    8000104e:	05f5e537          	lui	a0,0x5f5e
    80001052:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80001056:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80001058:	00013497          	auipc	s1,0x13
    8000105c:	a5048493          	addi	s1,s1,-1456 # 80013aa8 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80001060:	3e800913          	li	s2,1000
    80001064:	a091                	j	800010a8 <sys_ntas+0x162>
    80001066:	2705                	addiw	a4,a4,1
    80001068:	06a1                	addi	a3,a3,8
    8000106a:	03270063          	beq	a4,s2,8000108a <sys_ntas+0x144>
      if(locks[i] == 0)
    8000106e:	629c                	ld	a5,0(a3)
    80001070:	cf89                	beqz	a5,8000108a <sys_ntas+0x144>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80001072:	5790                	lw	a2,40(a5)
    80001074:	00359793          	slli	a5,a1,0x3
    80001078:	97a6                	add	a5,a5,s1
    8000107a:	639c                	ld	a5,0(a5)
    8000107c:	579c                	lw	a5,40(a5)
    8000107e:	fec7f4e3          	bgeu	a5,a2,80001066 <sys_ntas+0x120>
    80001082:	fea672e3          	bgeu	a2,a0,80001066 <sys_ntas+0x120>
    80001086:	85ba                	mv	a1,a4
    80001088:	bff9                	j	80001066 <sys_ntas+0x120>
        top = i;
      }
    }
    print_lock(locks[top]);
    8000108a:	058e                	slli	a1,a1,0x3
    8000108c:	00b48bb3          	add	s7,s1,a1
    80001090:	000bb503          	ld	a0,0(s7)
    80001094:	00000097          	auipc	ra,0x0
    80001098:	e88080e7          	jalr	-376(ra) # 80000f1c <print_lock>
    last = locks[top]->nts;
    8000109c:	000bb783          	ld	a5,0(s7)
    800010a0:	5788                	lw	a0,40(a5)
  for(int t= 0; t < 5; t++) {
    800010a2:	3a7d                	addiw	s4,s4,-1
    800010a4:	000a0763          	beqz	s4,800010b2 <sys_ntas+0x16c>
  int tot = 0;
    800010a8:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    800010aa:	8756                	mv	a4,s5
    int top = 0;
    800010ac:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    800010ae:	2501                	sext.w	a0,a0
    800010b0:	bf7d                	j	8000106e <sys_ntas+0x128>
  }
  return tot;
    800010b2:	854e                	mv	a0,s3
}
    800010b4:	60e6                	ld	ra,88(sp)
    800010b6:	6446                	ld	s0,80(sp)
    800010b8:	64a6                	ld	s1,72(sp)
    800010ba:	6906                	ld	s2,64(sp)
    800010bc:	79e2                	ld	s3,56(sp)
    800010be:	7a42                	ld	s4,48(sp)
    800010c0:	7aa2                	ld	s5,40(sp)
    800010c2:	7b02                	ld	s6,32(sp)
    800010c4:	6be2                	ld	s7,24(sp)
    800010c6:	6c42                	ld	s8,16(sp)
    800010c8:	6125                	addi	sp,sp,96
    800010ca:	8082                	ret
    return -1;
    800010cc:	557d                	li	a0,-1
    800010ce:	b7dd                	j	800010b4 <sys_ntas+0x16e>
    return 0;
    800010d0:	4501                	li	a0,0
    800010d2:	b7cd                	j	800010b4 <sys_ntas+0x16e>

00000000800010d4 <memset>:
#include "types.h"
#include "defs.h"

void*
memset(void *dst, int c, uint n)
{
    800010d4:	1141                	addi	sp,sp,-16
    800010d6:	e422                	sd	s0,8(sp)
    800010d8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800010da:	ce09                	beqz	a2,800010f4 <memset+0x20>
    800010dc:	87aa                	mv	a5,a0
    800010de:	fff6071b          	addiw	a4,a2,-1
    800010e2:	1702                	slli	a4,a4,0x20
    800010e4:	9301                	srli	a4,a4,0x20
    800010e6:	0705                	addi	a4,a4,1
    800010e8:	972a                	add	a4,a4,a0
    cdst[i] = c;
    800010ea:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800010ee:	0785                	addi	a5,a5,1
    800010f0:	fee79de3          	bne	a5,a4,800010ea <memset+0x16>
  }
  return dst;
}
    800010f4:	6422                	ld	s0,8(sp)
    800010f6:	0141                	addi	sp,sp,16
    800010f8:	8082                	ret

00000000800010fa <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800010fa:	1141                	addi	sp,sp,-16
    800010fc:	e422                	sd	s0,8(sp)
    800010fe:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80001100:	ca05                	beqz	a2,80001130 <memcmp+0x36>
    80001102:	fff6069b          	addiw	a3,a2,-1
    80001106:	1682                	slli	a3,a3,0x20
    80001108:	9281                	srli	a3,a3,0x20
    8000110a:	0685                	addi	a3,a3,1
    8000110c:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    8000110e:	00054783          	lbu	a5,0(a0)
    80001112:	0005c703          	lbu	a4,0(a1)
    80001116:	00e79863          	bne	a5,a4,80001126 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    8000111a:	0505                	addi	a0,a0,1
    8000111c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000111e:	fed518e3          	bne	a0,a3,8000110e <memcmp+0x14>
  }

  return 0;
    80001122:	4501                	li	a0,0
    80001124:	a019                	j	8000112a <memcmp+0x30>
      return *s1 - *s2;
    80001126:	40e7853b          	subw	a0,a5,a4
}
    8000112a:	6422                	ld	s0,8(sp)
    8000112c:	0141                	addi	sp,sp,16
    8000112e:	8082                	ret
  return 0;
    80001130:	4501                	li	a0,0
    80001132:	bfe5                	j	8000112a <memcmp+0x30>

0000000080001134 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80001134:	1141                	addi	sp,sp,-16
    80001136:	e422                	sd	s0,8(sp)
    80001138:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    8000113a:	00a5f963          	bgeu	a1,a0,8000114c <memmove+0x18>
    8000113e:	02061713          	slli	a4,a2,0x20
    80001142:	9301                	srli	a4,a4,0x20
    80001144:	00e587b3          	add	a5,a1,a4
    80001148:	02f56563          	bltu	a0,a5,80001172 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000114c:	fff6069b          	addiw	a3,a2,-1
    80001150:	ce11                	beqz	a2,8000116c <memmove+0x38>
    80001152:	1682                	slli	a3,a3,0x20
    80001154:	9281                	srli	a3,a3,0x20
    80001156:	0685                	addi	a3,a3,1
    80001158:	96ae                	add	a3,a3,a1
    8000115a:	87aa                	mv	a5,a0
      *d++ = *s++;
    8000115c:	0585                	addi	a1,a1,1
    8000115e:	0785                	addi	a5,a5,1
    80001160:	fff5c703          	lbu	a4,-1(a1)
    80001164:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80001168:	fed59ae3          	bne	a1,a3,8000115c <memmove+0x28>

  return dst;
}
    8000116c:	6422                	ld	s0,8(sp)
    8000116e:	0141                	addi	sp,sp,16
    80001170:	8082                	ret
    d += n;
    80001172:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80001174:	fff6069b          	addiw	a3,a2,-1
    80001178:	da75                	beqz	a2,8000116c <memmove+0x38>
    8000117a:	02069613          	slli	a2,a3,0x20
    8000117e:	9201                	srli	a2,a2,0x20
    80001180:	fff64613          	not	a2,a2
    80001184:	963e                	add	a2,a2,a5
      *--d = *--s;
    80001186:	17fd                	addi	a5,a5,-1
    80001188:	177d                	addi	a4,a4,-1
    8000118a:	0007c683          	lbu	a3,0(a5)
    8000118e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80001192:	fec79ae3          	bne	a5,a2,80001186 <memmove+0x52>
    80001196:	bfd9                	j	8000116c <memmove+0x38>

0000000080001198 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80001198:	1141                	addi	sp,sp,-16
    8000119a:	e406                	sd	ra,8(sp)
    8000119c:	e022                	sd	s0,0(sp)
    8000119e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800011a0:	00000097          	auipc	ra,0x0
    800011a4:	f94080e7          	jalr	-108(ra) # 80001134 <memmove>
}
    800011a8:	60a2                	ld	ra,8(sp)
    800011aa:	6402                	ld	s0,0(sp)
    800011ac:	0141                	addi	sp,sp,16
    800011ae:	8082                	ret

00000000800011b0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800011b0:	1141                	addi	sp,sp,-16
    800011b2:	e422                	sd	s0,8(sp)
    800011b4:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    800011b6:	ce11                	beqz	a2,800011d2 <strncmp+0x22>
    800011b8:	00054783          	lbu	a5,0(a0)
    800011bc:	cf89                	beqz	a5,800011d6 <strncmp+0x26>
    800011be:	0005c703          	lbu	a4,0(a1)
    800011c2:	00f71a63          	bne	a4,a5,800011d6 <strncmp+0x26>
    n--, p++, q++;
    800011c6:	367d                	addiw	a2,a2,-1
    800011c8:	0505                	addi	a0,a0,1
    800011ca:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800011cc:	f675                	bnez	a2,800011b8 <strncmp+0x8>
  if(n == 0)
    return 0;
    800011ce:	4501                	li	a0,0
    800011d0:	a809                	j	800011e2 <strncmp+0x32>
    800011d2:	4501                	li	a0,0
    800011d4:	a039                	j	800011e2 <strncmp+0x32>
  if(n == 0)
    800011d6:	ca09                	beqz	a2,800011e8 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800011d8:	00054503          	lbu	a0,0(a0)
    800011dc:	0005c783          	lbu	a5,0(a1)
    800011e0:	9d1d                	subw	a0,a0,a5
}
    800011e2:	6422                	ld	s0,8(sp)
    800011e4:	0141                	addi	sp,sp,16
    800011e6:	8082                	ret
    return 0;
    800011e8:	4501                	li	a0,0
    800011ea:	bfe5                	j	800011e2 <strncmp+0x32>

00000000800011ec <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800011ec:	1141                	addi	sp,sp,-16
    800011ee:	e422                	sd	s0,8(sp)
    800011f0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800011f2:	872a                	mv	a4,a0
    800011f4:	8832                	mv	a6,a2
    800011f6:	367d                	addiw	a2,a2,-1
    800011f8:	01005963          	blez	a6,8000120a <strncpy+0x1e>
    800011fc:	0705                	addi	a4,a4,1
    800011fe:	0005c783          	lbu	a5,0(a1)
    80001202:	fef70fa3          	sb	a5,-1(a4)
    80001206:	0585                	addi	a1,a1,1
    80001208:	f7f5                	bnez	a5,800011f4 <strncpy+0x8>
    ;
  while(n-- > 0)
    8000120a:	00c05d63          	blez	a2,80001224 <strncpy+0x38>
    8000120e:	86ba                	mv	a3,a4
    *s++ = 0;
    80001210:	0685                	addi	a3,a3,1
    80001212:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001216:	fff6c793          	not	a5,a3
    8000121a:	9fb9                	addw	a5,a5,a4
    8000121c:	010787bb          	addw	a5,a5,a6
    80001220:	fef048e3          	bgtz	a5,80001210 <strncpy+0x24>
  return os;
}
    80001224:	6422                	ld	s0,8(sp)
    80001226:	0141                	addi	sp,sp,16
    80001228:	8082                	ret

000000008000122a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000122a:	1141                	addi	sp,sp,-16
    8000122c:	e422                	sd	s0,8(sp)
    8000122e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001230:	02c05363          	blez	a2,80001256 <safestrcpy+0x2c>
    80001234:	fff6069b          	addiw	a3,a2,-1
    80001238:	1682                	slli	a3,a3,0x20
    8000123a:	9281                	srli	a3,a3,0x20
    8000123c:	96ae                	add	a3,a3,a1
    8000123e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001240:	00d58963          	beq	a1,a3,80001252 <safestrcpy+0x28>
    80001244:	0585                	addi	a1,a1,1
    80001246:	0785                	addi	a5,a5,1
    80001248:	fff5c703          	lbu	a4,-1(a1)
    8000124c:	fee78fa3          	sb	a4,-1(a5)
    80001250:	fb65                	bnez	a4,80001240 <safestrcpy+0x16>
    ;
  *s = 0;
    80001252:	00078023          	sb	zero,0(a5)
  return os;
}
    80001256:	6422                	ld	s0,8(sp)
    80001258:	0141                	addi	sp,sp,16
    8000125a:	8082                	ret

000000008000125c <strlen>:

int
strlen(const char *s)
{
    8000125c:	1141                	addi	sp,sp,-16
    8000125e:	e422                	sd	s0,8(sp)
    80001260:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001262:	00054783          	lbu	a5,0(a0)
    80001266:	cf91                	beqz	a5,80001282 <strlen+0x26>
    80001268:	0505                	addi	a0,a0,1
    8000126a:	87aa                	mv	a5,a0
    8000126c:	4685                	li	a3,1
    8000126e:	9e89                	subw	a3,a3,a0
    80001270:	00f6853b          	addw	a0,a3,a5
    80001274:	0785                	addi	a5,a5,1
    80001276:	fff7c703          	lbu	a4,-1(a5)
    8000127a:	fb7d                	bnez	a4,80001270 <strlen+0x14>
    ;
  return n;
}
    8000127c:	6422                	ld	s0,8(sp)
    8000127e:	0141                	addi	sp,sp,16
    80001280:	8082                	ret
  for(n = 0; s[n]; n++)
    80001282:	4501                	li	a0,0
    80001284:	bfe5                	j	8000127c <strlen+0x20>

0000000080001286 <strjoin>:


char* strjoin(char **s){
    80001286:	7139                	addi	sp,sp,-64
    80001288:	fc06                	sd	ra,56(sp)
    8000128a:	f822                	sd	s0,48(sp)
    8000128c:	f426                	sd	s1,40(sp)
    8000128e:	f04a                	sd	s2,32(sp)
    80001290:	ec4e                	sd	s3,24(sp)
    80001292:	e852                	sd	s4,16(sp)
    80001294:	e456                	sd	s5,8(sp)
    80001296:	e05a                	sd	s6,0(sp)
    80001298:	0080                	addi	s0,sp,64
    8000129a:	89aa                	mv	s3,a0
  int n = 0;
  char** os = s;
  while(*s){
    8000129c:	6108                	ld	a0,0(a0)
    8000129e:	cd3d                	beqz	a0,8000131c <strjoin+0x96>
    800012a0:	84ce                	mv	s1,s3
  int n = 0;
    800012a2:	4901                	li	s2,0
    n += strlen(*s) + 1;
    800012a4:	00000097          	auipc	ra,0x0
    800012a8:	fb8080e7          	jalr	-72(ra) # 8000125c <strlen>
    800012ac:	2505                	addiw	a0,a0,1
    800012ae:	0125093b          	addw	s2,a0,s2
    s++;
    800012b2:	04a1                	addi	s1,s1,8
  while(*s){
    800012b4:	6088                	ld	a0,0(s1)
    800012b6:	f57d                	bnez	a0,800012a4 <strjoin+0x1e>
  }
  char* d = bd_malloc(n);
    800012b8:	854a                	mv	a0,s2
    800012ba:	00006097          	auipc	ra,0x6
    800012be:	c36080e7          	jalr	-970(ra) # 80006ef0 <bd_malloc>
    800012c2:	8b2a                	mv	s6,a0
  s = os;
  char* od = d;
  while(*s){
    800012c4:	0009b903          	ld	s2,0(s3)
    800012c8:	04090c63          	beqz	s2,80001320 <strjoin+0x9a>
  char* d = bd_malloc(n);
    800012cc:	8a2a                	mv	s4,a0
    n = strlen(*s);
    safestrcpy(d, *s, n+1);
    d+=n;
    *d++ = ' ';
    800012ce:	02000a93          	li	s5,32
    n = strlen(*s);
    800012d2:	854a                	mv	a0,s2
    800012d4:	00000097          	auipc	ra,0x0
    800012d8:	f88080e7          	jalr	-120(ra) # 8000125c <strlen>
    800012dc:	84aa                	mv	s1,a0
    safestrcpy(d, *s, n+1);
    800012de:	0015061b          	addiw	a2,a0,1
    800012e2:	85ca                	mv	a1,s2
    800012e4:	8552                	mv	a0,s4
    800012e6:	00000097          	auipc	ra,0x0
    800012ea:	f44080e7          	jalr	-188(ra) # 8000122a <safestrcpy>
    d+=n;
    800012ee:	94d2                	add	s1,s1,s4
    *d++ = ' ';
    800012f0:	00148a13          	addi	s4,s1,1
    800012f4:	01548023          	sb	s5,0(s1)
    s++;
    800012f8:	09a1                	addi	s3,s3,8
  while(*s){
    800012fa:	0009b903          	ld	s2,0(s3)
    800012fe:	fc091ae3          	bnez	s2,800012d2 <strjoin+0x4c>
  }
  d[-1] = 0;
    80001302:	fe0a0fa3          	sb	zero,-1(s4)
  return od;
}
    80001306:	855a                	mv	a0,s6
    80001308:	70e2                	ld	ra,56(sp)
    8000130a:	7442                	ld	s0,48(sp)
    8000130c:	74a2                	ld	s1,40(sp)
    8000130e:	7902                	ld	s2,32(sp)
    80001310:	69e2                	ld	s3,24(sp)
    80001312:	6a42                	ld	s4,16(sp)
    80001314:	6aa2                	ld	s5,8(sp)
    80001316:	6b02                	ld	s6,0(sp)
    80001318:	6121                	addi	sp,sp,64
    8000131a:	8082                	ret
  int n = 0;
    8000131c:	4901                	li	s2,0
    8000131e:	bf69                	j	800012b8 <strjoin+0x32>
  char* d = bd_malloc(n);
    80001320:	8a2a                	mv	s4,a0
    80001322:	b7c5                	j	80001302 <strjoin+0x7c>

0000000080001324 <strdup>:


char* strdup(char *s){
    80001324:	7179                	addi	sp,sp,-48
    80001326:	f406                	sd	ra,40(sp)
    80001328:	f022                	sd	s0,32(sp)
    8000132a:	ec26                	sd	s1,24(sp)
    8000132c:	e84a                	sd	s2,16(sp)
    8000132e:	e44e                	sd	s3,8(sp)
    80001330:	1800                	addi	s0,sp,48
    80001332:	89aa                	mv	s3,a0
  int n = 0;
  n = strlen(s) + 1;
    80001334:	00000097          	auipc	ra,0x0
    80001338:	f28080e7          	jalr	-216(ra) # 8000125c <strlen>
    8000133c:	0015049b          	addiw	s1,a0,1
  char* d = bd_malloc(n);
    80001340:	8526                	mv	a0,s1
    80001342:	00006097          	auipc	ra,0x6
    80001346:	bae080e7          	jalr	-1106(ra) # 80006ef0 <bd_malloc>
    8000134a:	892a                	mv	s2,a0
  safestrcpy(d, s, n);
    8000134c:	8626                	mv	a2,s1
    8000134e:	85ce                	mv	a1,s3
    80001350:	00000097          	auipc	ra,0x0
    80001354:	eda080e7          	jalr	-294(ra) # 8000122a <safestrcpy>
  return d;
}
    80001358:	854a                	mv	a0,s2
    8000135a:	70a2                	ld	ra,40(sp)
    8000135c:	7402                	ld	s0,32(sp)
    8000135e:	64e2                	ld	s1,24(sp)
    80001360:	6942                	ld	s2,16(sp)
    80001362:	69a2                	ld	s3,8(sp)
    80001364:	6145                	addi	sp,sp,48
    80001366:	8082                	ret

0000000080001368 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001368:	1141                	addi	sp,sp,-16
    8000136a:	e406                	sd	ra,8(sp)
    8000136c:	e022                	sd	s0,0(sp)
    8000136e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001370:	00001097          	auipc	ra,0x1
    80001374:	c00080e7          	jalr	-1024(ra) # 80001f70 <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001378:	0002d717          	auipc	a4,0x2d
    8000137c:	cfc70713          	addi	a4,a4,-772 # 8002e074 <started>
  if(cpuid() == 0){
    80001380:	c139                	beqz	a0,800013c6 <main+0x5e>
    while(started == 0)
    80001382:	431c                	lw	a5,0(a4)
    80001384:	2781                	sext.w	a5,a5
    80001386:	dff5                	beqz	a5,80001382 <main+0x1a>
      ;
    __sync_synchronize();
    80001388:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000138c:	00001097          	auipc	ra,0x1
    80001390:	be4080e7          	jalr	-1052(ra) # 80001f70 <cpuid>
    80001394:	85aa                	mv	a1,a0
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	0b250513          	addi	a0,a0,178 # 80008448 <userret+0x3b8>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	5ce080e7          	jalr	1486(ra) # 8000096c <printf>
    kvminithart();    // turn on paging
    800013a6:	00000097          	auipc	ra,0x0
    800013aa:	1f2080e7          	jalr	498(ra) # 80001598 <kvminithart>
    trapinithart();   // install kernel trap vector
    800013ae:	00002097          	auipc	ra,0x2
    800013b2:	a4e080e7          	jalr	-1458(ra) # 80002dfc <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800013b6:	00005097          	auipc	ra,0x5
    800013ba:	17a080e7          	jalr	378(ra) # 80006530 <plicinithart>
  }

  scheduler();        
    800013be:	00001097          	auipc	ra,0x1
    800013c2:	1ae080e7          	jalr	430(ra) # 8000256c <scheduler>
    consoleinit();
    800013c6:	fffff097          	auipc	ra,0xfffff
    800013ca:	244080e7          	jalr	580(ra) # 8000060a <consoleinit>
    watchdoginit();
    800013ce:	00006097          	auipc	ra,0x6
    800013d2:	5a2080e7          	jalr	1442(ra) # 80007970 <watchdoginit>
    printfinit();
    800013d6:	fffff097          	auipc	ra,0xfffff
    800013da:	608080e7          	jalr	1544(ra) # 800009de <printfinit>
    printf("\n");
    800013de:	00007517          	auipc	a0,0x7
    800013e2:	26a50513          	addi	a0,a0,618 # 80008648 <userret+0x5b8>
    800013e6:	fffff097          	auipc	ra,0xfffff
    800013ea:	586080e7          	jalr	1414(ra) # 8000096c <printf>
    printf("xv6 kernel is booting\n");
    800013ee:	00007517          	auipc	a0,0x7
    800013f2:	04250513          	addi	a0,a0,66 # 80008430 <userret+0x3a0>
    800013f6:	fffff097          	auipc	ra,0xfffff
    800013fa:	576080e7          	jalr	1398(ra) # 8000096c <printf>
    printf("\n");
    800013fe:	00007517          	auipc	a0,0x7
    80001402:	24a50513          	addi	a0,a0,586 # 80008648 <userret+0x5b8>
    80001406:	fffff097          	auipc	ra,0xfffff
    8000140a:	566080e7          	jalr	1382(ra) # 8000096c <printf>
    kinit();         // physical page allocator
    8000140e:	fffff097          	auipc	ra,0xfffff
    80001412:	6b6080e7          	jalr	1718(ra) # 80000ac4 <kinit>
    kvminit();       // create kernel page table
    80001416:	00000097          	auipc	ra,0x0
    8000141a:	30c080e7          	jalr	780(ra) # 80001722 <kvminit>
    kvminithart();   // turn on paging
    8000141e:	00000097          	auipc	ra,0x0
    80001422:	17a080e7          	jalr	378(ra) # 80001598 <kvminithart>
    procinit();      // process table
    80001426:	00001097          	auipc	ra,0x1
    8000142a:	a4c080e7          	jalr	-1460(ra) # 80001e72 <procinit>
    trapinit();      // trap vectors
    8000142e:	00002097          	auipc	ra,0x2
    80001432:	9a6080e7          	jalr	-1626(ra) # 80002dd4 <trapinit>
    trapinithart();  // install kernel trap vector
    80001436:	00002097          	auipc	ra,0x2
    8000143a:	9c6080e7          	jalr	-1594(ra) # 80002dfc <trapinithart>
    plicinit();      // set up interrupt controller
    8000143e:	00005097          	auipc	ra,0x5
    80001442:	0dc080e7          	jalr	220(ra) # 8000651a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001446:	00005097          	auipc	ra,0x5
    8000144a:	0ea080e7          	jalr	234(ra) # 80006530 <plicinithart>
    binit();         // buffer cache
    8000144e:	00002097          	auipc	ra,0x2
    80001452:	164080e7          	jalr	356(ra) # 800035b2 <binit>
    iinit();         // inode cache
    80001456:	00002097          	auipc	ra,0x2
    8000145a:	7f8080e7          	jalr	2040(ra) # 80003c4e <iinit>
    fileinit();      // file table
    8000145e:	00004097          	auipc	ra,0x4
    80001462:	85e080e7          	jalr	-1954(ra) # 80004cbc <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80001466:	4501                	li	a0,0
    80001468:	00005097          	auipc	ra,0x5
    8000146c:	1ea080e7          	jalr	490(ra) # 80006652 <virtio_disk_init>
    userinit();      // first user process
    80001470:	00001097          	auipc	ra,0x1
    80001474:	dba080e7          	jalr	-582(ra) # 8000222a <userinit>
    __sync_synchronize();
    80001478:	0ff0000f          	fence
    started = 1;
    8000147c:	4785                	li	a5,1
    8000147e:	0002d717          	auipc	a4,0x2d
    80001482:	bef72b23          	sw	a5,-1034(a4) # 8002e074 <started>
    80001486:	bf25                	j	800013be <main+0x56>

0000000080001488 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001488:	7139                	addi	sp,sp,-64
    8000148a:	fc06                	sd	ra,56(sp)
    8000148c:	f822                	sd	s0,48(sp)
    8000148e:	f426                	sd	s1,40(sp)
    80001490:	f04a                	sd	s2,32(sp)
    80001492:	ec4e                	sd	s3,24(sp)
    80001494:	e852                	sd	s4,16(sp)
    80001496:	e456                	sd	s5,8(sp)
    80001498:	e05a                	sd	s6,0(sp)
    8000149a:	0080                	addi	s0,sp,64
    8000149c:	84aa                	mv	s1,a0
    8000149e:	89ae                	mv	s3,a1
    800014a0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800014a2:	57fd                	li	a5,-1
    800014a4:	83e9                	srli	a5,a5,0x1a
    800014a6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800014a8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800014aa:	04b7f263          	bgeu	a5,a1,800014ee <walk+0x66>
    panic("walk");
    800014ae:	00007517          	auipc	a0,0x7
    800014b2:	fb250513          	addi	a0,a0,-78 # 80008460 <userret+0x3d0>
    800014b6:	fffff097          	auipc	ra,0xfffff
    800014ba:	2a0080e7          	jalr	672(ra) # 80000756 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800014be:	060a8663          	beqz	s5,8000152a <walk+0xa2>
    800014c2:	fffff097          	auipc	ra,0xfffff
    800014c6:	642080e7          	jalr	1602(ra) # 80000b04 <kalloc>
    800014ca:	84aa                	mv	s1,a0
    800014cc:	c529                	beqz	a0,80001516 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800014ce:	6605                	lui	a2,0x1
    800014d0:	4581                	li	a1,0
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	c02080e7          	jalr	-1022(ra) # 800010d4 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800014da:	00c4d793          	srli	a5,s1,0xc
    800014de:	07aa                	slli	a5,a5,0xa
    800014e0:	0017e793          	ori	a5,a5,1
    800014e4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800014e8:	3a5d                	addiw	s4,s4,-9
    800014ea:	036a0063          	beq	s4,s6,8000150a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800014ee:	0149d933          	srl	s2,s3,s4
    800014f2:	1ff97913          	andi	s2,s2,511
    800014f6:	090e                	slli	s2,s2,0x3
    800014f8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800014fa:	00093483          	ld	s1,0(s2)
    800014fe:	0014f793          	andi	a5,s1,1
    80001502:	dfd5                	beqz	a5,800014be <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001504:	80a9                	srli	s1,s1,0xa
    80001506:	04b2                	slli	s1,s1,0xc
    80001508:	b7c5                	j	800014e8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000150a:	00c9d513          	srli	a0,s3,0xc
    8000150e:	1ff57513          	andi	a0,a0,511
    80001512:	050e                	slli	a0,a0,0x3
    80001514:	9526                	add	a0,a0,s1
}
    80001516:	70e2                	ld	ra,56(sp)
    80001518:	7442                	ld	s0,48(sp)
    8000151a:	74a2                	ld	s1,40(sp)
    8000151c:	7902                	ld	s2,32(sp)
    8000151e:	69e2                	ld	s3,24(sp)
    80001520:	6a42                	ld	s4,16(sp)
    80001522:	6aa2                	ld	s5,8(sp)
    80001524:	6b02                	ld	s6,0(sp)
    80001526:	6121                	addi	sp,sp,64
    80001528:	8082                	ret
        return 0;
    8000152a:	4501                	li	a0,0
    8000152c:	b7ed                	j	80001516 <walk+0x8e>

000000008000152e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    8000152e:	7179                	addi	sp,sp,-48
    80001530:	f406                	sd	ra,40(sp)
    80001532:	f022                	sd	s0,32(sp)
    80001534:	ec26                	sd	s1,24(sp)
    80001536:	e84a                	sd	s2,16(sp)
    80001538:	e44e                	sd	s3,8(sp)
    8000153a:	e052                	sd	s4,0(sp)
    8000153c:	1800                	addi	s0,sp,48
    8000153e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001540:	84aa                	mv	s1,a0
    80001542:	6905                	lui	s2,0x1
    80001544:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001546:	4985                	li	s3,1
    80001548:	a821                	j	80001560 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000154a:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000154c:	0532                	slli	a0,a0,0xc
    8000154e:	00000097          	auipc	ra,0x0
    80001552:	fe0080e7          	jalr	-32(ra) # 8000152e <freewalk>
      pagetable[i] = 0;
    80001556:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000155a:	04a1                	addi	s1,s1,8
    8000155c:	03248163          	beq	s1,s2,8000157e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001560:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001562:	00f57793          	andi	a5,a0,15
    80001566:	ff3782e3          	beq	a5,s3,8000154a <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000156a:	8905                	andi	a0,a0,1
    8000156c:	d57d                	beqz	a0,8000155a <freewalk+0x2c>
      panic("freewalk: leaf");
    8000156e:	00007517          	auipc	a0,0x7
    80001572:	efa50513          	addi	a0,a0,-262 # 80008468 <userret+0x3d8>
    80001576:	fffff097          	auipc	ra,0xfffff
    8000157a:	1e0080e7          	jalr	480(ra) # 80000756 <panic>
    }
  }
  kfree((void*)pagetable);
    8000157e:	8552                	mv	a0,s4
    80001580:	fffff097          	auipc	ra,0xfffff
    80001584:	56c080e7          	jalr	1388(ra) # 80000aec <kfree>
}
    80001588:	70a2                	ld	ra,40(sp)
    8000158a:	7402                	ld	s0,32(sp)
    8000158c:	64e2                	ld	s1,24(sp)
    8000158e:	6942                	ld	s2,16(sp)
    80001590:	69a2                	ld	s3,8(sp)
    80001592:	6a02                	ld	s4,0(sp)
    80001594:	6145                	addi	sp,sp,48
    80001596:	8082                	ret

0000000080001598 <kvminithart>:
{
    80001598:	1141                	addi	sp,sp,-16
    8000159a:	e422                	sd	s0,8(sp)
    8000159c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000159e:	0002d797          	auipc	a5,0x2d
    800015a2:	ada7b783          	ld	a5,-1318(a5) # 8002e078 <kernel_pagetable>
    800015a6:	83b1                	srli	a5,a5,0xc
    800015a8:	577d                	li	a4,-1
    800015aa:	177e                	slli	a4,a4,0x3f
    800015ac:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800015ae:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800015b2:	12000073          	sfence.vma
}
    800015b6:	6422                	ld	s0,8(sp)
    800015b8:	0141                	addi	sp,sp,16
    800015ba:	8082                	ret

00000000800015bc <walkaddr>:
  if(va >= MAXVA)
    800015bc:	57fd                	li	a5,-1
    800015be:	83e9                	srli	a5,a5,0x1a
    800015c0:	00b7f463          	bgeu	a5,a1,800015c8 <walkaddr+0xc>
    return 0;
    800015c4:	4501                	li	a0,0
}
    800015c6:	8082                	ret
{
    800015c8:	1141                	addi	sp,sp,-16
    800015ca:	e406                	sd	ra,8(sp)
    800015cc:	e022                	sd	s0,0(sp)
    800015ce:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800015d0:	4601                	li	a2,0
    800015d2:	00000097          	auipc	ra,0x0
    800015d6:	eb6080e7          	jalr	-330(ra) # 80001488 <walk>
  if(pte == 0)
    800015da:	c105                	beqz	a0,800015fa <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800015dc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800015de:	0117f693          	andi	a3,a5,17
    800015e2:	4745                	li	a4,17
    return 0;
    800015e4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800015e6:	00e68663          	beq	a3,a4,800015f2 <walkaddr+0x36>
}
    800015ea:	60a2                	ld	ra,8(sp)
    800015ec:	6402                	ld	s0,0(sp)
    800015ee:	0141                	addi	sp,sp,16
    800015f0:	8082                	ret
  pa = PTE2PA(*pte);
    800015f2:	00a7d513          	srli	a0,a5,0xa
    800015f6:	0532                	slli	a0,a0,0xc
  return pa;
    800015f8:	bfcd                	j	800015ea <walkaddr+0x2e>
    return 0;
    800015fa:	4501                	li	a0,0
    800015fc:	b7fd                	j	800015ea <walkaddr+0x2e>

00000000800015fe <kvmpa>:
{
    800015fe:	1101                	addi	sp,sp,-32
    80001600:	ec06                	sd	ra,24(sp)
    80001602:	e822                	sd	s0,16(sp)
    80001604:	e426                	sd	s1,8(sp)
    80001606:	1000                	addi	s0,sp,32
    80001608:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    8000160a:	1552                	slli	a0,a0,0x34
    8000160c:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    80001610:	4601                	li	a2,0
    80001612:	0002d517          	auipc	a0,0x2d
    80001616:	a6653503          	ld	a0,-1434(a0) # 8002e078 <kernel_pagetable>
    8000161a:	00000097          	auipc	ra,0x0
    8000161e:	e6e080e7          	jalr	-402(ra) # 80001488 <walk>
  if(pte == 0)
    80001622:	cd09                	beqz	a0,8000163c <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    80001624:	6108                	ld	a0,0(a0)
    80001626:	00157793          	andi	a5,a0,1
    8000162a:	c38d                	beqz	a5,8000164c <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    8000162c:	8129                	srli	a0,a0,0xa
    8000162e:	0532                	slli	a0,a0,0xc
}
    80001630:	9526                	add	a0,a0,s1
    80001632:	60e2                	ld	ra,24(sp)
    80001634:	6442                	ld	s0,16(sp)
    80001636:	64a2                	ld	s1,8(sp)
    80001638:	6105                	addi	sp,sp,32
    8000163a:	8082                	ret
    panic("kvmpa");
    8000163c:	00007517          	auipc	a0,0x7
    80001640:	e3c50513          	addi	a0,a0,-452 # 80008478 <userret+0x3e8>
    80001644:	fffff097          	auipc	ra,0xfffff
    80001648:	112080e7          	jalr	274(ra) # 80000756 <panic>
    panic("kvmpa");
    8000164c:	00007517          	auipc	a0,0x7
    80001650:	e2c50513          	addi	a0,a0,-468 # 80008478 <userret+0x3e8>
    80001654:	fffff097          	auipc	ra,0xfffff
    80001658:	102080e7          	jalr	258(ra) # 80000756 <panic>

000000008000165c <mappages>:
{
    8000165c:	715d                	addi	sp,sp,-80
    8000165e:	e486                	sd	ra,72(sp)
    80001660:	e0a2                	sd	s0,64(sp)
    80001662:	fc26                	sd	s1,56(sp)
    80001664:	f84a                	sd	s2,48(sp)
    80001666:	f44e                	sd	s3,40(sp)
    80001668:	f052                	sd	s4,32(sp)
    8000166a:	ec56                	sd	s5,24(sp)
    8000166c:	e85a                	sd	s6,16(sp)
    8000166e:	e45e                	sd	s7,8(sp)
    80001670:	0880                	addi	s0,sp,80
    80001672:	8aaa                	mv	s5,a0
    80001674:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80001676:	777d                	lui	a4,0xfffff
    80001678:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000167c:	167d                	addi	a2,a2,-1
    8000167e:	00b609b3          	add	s3,a2,a1
    80001682:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001686:	893e                	mv	s2,a5
    80001688:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    8000168c:	6b85                	lui	s7,0x1
    8000168e:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001692:	4605                	li	a2,1
    80001694:	85ca                	mv	a1,s2
    80001696:	8556                	mv	a0,s5
    80001698:	00000097          	auipc	ra,0x0
    8000169c:	df0080e7          	jalr	-528(ra) # 80001488 <walk>
    800016a0:	c51d                	beqz	a0,800016ce <mappages+0x72>
    if(*pte & PTE_V)
    800016a2:	611c                	ld	a5,0(a0)
    800016a4:	8b85                	andi	a5,a5,1
    800016a6:	ef81                	bnez	a5,800016be <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800016a8:	80b1                	srli	s1,s1,0xc
    800016aa:	04aa                	slli	s1,s1,0xa
    800016ac:	0164e4b3          	or	s1,s1,s6
    800016b0:	0014e493          	ori	s1,s1,1
    800016b4:	e104                	sd	s1,0(a0)
    if(a == last)
    800016b6:	03390863          	beq	s2,s3,800016e6 <mappages+0x8a>
    a += PGSIZE;
    800016ba:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800016bc:	bfc9                	j	8000168e <mappages+0x32>
      panic("remap");
    800016be:	00007517          	auipc	a0,0x7
    800016c2:	dc250513          	addi	a0,a0,-574 # 80008480 <userret+0x3f0>
    800016c6:	fffff097          	auipc	ra,0xfffff
    800016ca:	090080e7          	jalr	144(ra) # 80000756 <panic>
      return -1;
    800016ce:	557d                	li	a0,-1
}
    800016d0:	60a6                	ld	ra,72(sp)
    800016d2:	6406                	ld	s0,64(sp)
    800016d4:	74e2                	ld	s1,56(sp)
    800016d6:	7942                	ld	s2,48(sp)
    800016d8:	79a2                	ld	s3,40(sp)
    800016da:	7a02                	ld	s4,32(sp)
    800016dc:	6ae2                	ld	s5,24(sp)
    800016de:	6b42                	ld	s6,16(sp)
    800016e0:	6ba2                	ld	s7,8(sp)
    800016e2:	6161                	addi	sp,sp,80
    800016e4:	8082                	ret
  return 0;
    800016e6:	4501                	li	a0,0
    800016e8:	b7e5                	j	800016d0 <mappages+0x74>

00000000800016ea <kvmmap>:
{
    800016ea:	1141                	addi	sp,sp,-16
    800016ec:	e406                	sd	ra,8(sp)
    800016ee:	e022                	sd	s0,0(sp)
    800016f0:	0800                	addi	s0,sp,16
    800016f2:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800016f4:	86ae                	mv	a3,a1
    800016f6:	85aa                	mv	a1,a0
    800016f8:	0002d517          	auipc	a0,0x2d
    800016fc:	98053503          	ld	a0,-1664(a0) # 8002e078 <kernel_pagetable>
    80001700:	00000097          	auipc	ra,0x0
    80001704:	f5c080e7          	jalr	-164(ra) # 8000165c <mappages>
    80001708:	e509                	bnez	a0,80001712 <kvmmap+0x28>
}
    8000170a:	60a2                	ld	ra,8(sp)
    8000170c:	6402                	ld	s0,0(sp)
    8000170e:	0141                	addi	sp,sp,16
    80001710:	8082                	ret
    panic("kvmmap");
    80001712:	00007517          	auipc	a0,0x7
    80001716:	d7650513          	addi	a0,a0,-650 # 80008488 <userret+0x3f8>
    8000171a:	fffff097          	auipc	ra,0xfffff
    8000171e:	03c080e7          	jalr	60(ra) # 80000756 <panic>

0000000080001722 <kvminit>:
{
    80001722:	1101                	addi	sp,sp,-32
    80001724:	ec06                	sd	ra,24(sp)
    80001726:	e822                	sd	s0,16(sp)
    80001728:	e426                	sd	s1,8(sp)
    8000172a:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    8000172c:	fffff097          	auipc	ra,0xfffff
    80001730:	3d8080e7          	jalr	984(ra) # 80000b04 <kalloc>
    80001734:	0002d797          	auipc	a5,0x2d
    80001738:	94a7b223          	sd	a0,-1724(a5) # 8002e078 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000173c:	6605                	lui	a2,0x1
    8000173e:	4581                	li	a1,0
    80001740:	00000097          	auipc	ra,0x0
    80001744:	994080e7          	jalr	-1644(ra) # 800010d4 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001748:	4699                	li	a3,6
    8000174a:	6605                	lui	a2,0x1
    8000174c:	100005b7          	lui	a1,0x10000
    80001750:	10000537          	lui	a0,0x10000
    80001754:	00000097          	auipc	ra,0x0
    80001758:	f96080e7          	jalr	-106(ra) # 800016ea <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    8000175c:	4699                	li	a3,6
    8000175e:	6605                	lui	a2,0x1
    80001760:	100015b7          	lui	a1,0x10001
    80001764:	10001537          	lui	a0,0x10001
    80001768:	00000097          	auipc	ra,0x0
    8000176c:	f82080e7          	jalr	-126(ra) # 800016ea <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    80001770:	4699                	li	a3,6
    80001772:	6605                	lui	a2,0x1
    80001774:	100025b7          	lui	a1,0x10002
    80001778:	10002537          	lui	a0,0x10002
    8000177c:	00000097          	auipc	ra,0x0
    80001780:	f6e080e7          	jalr	-146(ra) # 800016ea <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001784:	4699                	li	a3,6
    80001786:	6641                	lui	a2,0x10
    80001788:	020005b7          	lui	a1,0x2000
    8000178c:	02000537          	lui	a0,0x2000
    80001790:	00000097          	auipc	ra,0x0
    80001794:	f5a080e7          	jalr	-166(ra) # 800016ea <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001798:	4699                	li	a3,6
    8000179a:	00400637          	lui	a2,0x400
    8000179e:	0c0005b7          	lui	a1,0xc000
    800017a2:	0c000537          	lui	a0,0xc000
    800017a6:	00000097          	auipc	ra,0x0
    800017aa:	f44080e7          	jalr	-188(ra) # 800016ea <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800017ae:	00009497          	auipc	s1,0x9
    800017b2:	85248493          	addi	s1,s1,-1966 # 8000a000 <initcode>
    800017b6:	46a9                	li	a3,10
    800017b8:	80009617          	auipc	a2,0x80009
    800017bc:	84860613          	addi	a2,a2,-1976 # a000 <_entry-0x7fff6000>
    800017c0:	4585                	li	a1,1
    800017c2:	05fe                	slli	a1,a1,0x1f
    800017c4:	852e                	mv	a0,a1
    800017c6:	00000097          	auipc	ra,0x0
    800017ca:	f24080e7          	jalr	-220(ra) # 800016ea <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800017ce:	4699                	li	a3,6
    800017d0:	4645                	li	a2,17
    800017d2:	066e                	slli	a2,a2,0x1b
    800017d4:	8e05                	sub	a2,a2,s1
    800017d6:	85a6                	mv	a1,s1
    800017d8:	8526                	mv	a0,s1
    800017da:	00000097          	auipc	ra,0x0
    800017de:	f10080e7          	jalr	-240(ra) # 800016ea <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800017e2:	46a9                	li	a3,10
    800017e4:	6605                	lui	a2,0x1
    800017e6:	00007597          	auipc	a1,0x7
    800017ea:	81a58593          	addi	a1,a1,-2022 # 80008000 <trampoline>
    800017ee:	04000537          	lui	a0,0x4000
    800017f2:	157d                	addi	a0,a0,-1
    800017f4:	0532                	slli	a0,a0,0xc
    800017f6:	00000097          	auipc	ra,0x0
    800017fa:	ef4080e7          	jalr	-268(ra) # 800016ea <kvmmap>
}
    800017fe:	60e2                	ld	ra,24(sp)
    80001800:	6442                	ld	s0,16(sp)
    80001802:	64a2                	ld	s1,8(sp)
    80001804:	6105                	addi	sp,sp,32
    80001806:	8082                	ret

0000000080001808 <uvmunmap>:
{
    80001808:	715d                	addi	sp,sp,-80
    8000180a:	e486                	sd	ra,72(sp)
    8000180c:	e0a2                	sd	s0,64(sp)
    8000180e:	fc26                	sd	s1,56(sp)
    80001810:	f84a                	sd	s2,48(sp)
    80001812:	f44e                	sd	s3,40(sp)
    80001814:	f052                	sd	s4,32(sp)
    80001816:	ec56                	sd	s5,24(sp)
    80001818:	e85a                	sd	s6,16(sp)
    8000181a:	e45e                	sd	s7,8(sp)
    8000181c:	0880                	addi	s0,sp,80
    8000181e:	8a2a                	mv	s4,a0
    80001820:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    80001822:	77fd                	lui	a5,0xfffff
    80001824:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80001828:	167d                	addi	a2,a2,-1
    8000182a:	00b609b3          	add	s3,a2,a1
    8000182e:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    80001832:	4b05                	li	s6,1
    a += PGSIZE;
    80001834:	6b85                	lui	s7,0x1
    80001836:	a8b1                	j	80001892 <uvmunmap+0x8a>
      panic("uvmunmap: walk");
    80001838:	00007517          	auipc	a0,0x7
    8000183c:	c5850513          	addi	a0,a0,-936 # 80008490 <userret+0x400>
    80001840:	fffff097          	auipc	ra,0xfffff
    80001844:	f16080e7          	jalr	-234(ra) # 80000756 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    80001848:	862a                	mv	a2,a0
    8000184a:	85ca                	mv	a1,s2
    8000184c:	00007517          	auipc	a0,0x7
    80001850:	c5450513          	addi	a0,a0,-940 # 800084a0 <userret+0x410>
    80001854:	fffff097          	auipc	ra,0xfffff
    80001858:	118080e7          	jalr	280(ra) # 8000096c <printf>
      panic("uvmunmap: not mapped");
    8000185c:	00007517          	auipc	a0,0x7
    80001860:	c5450513          	addi	a0,a0,-940 # 800084b0 <userret+0x420>
    80001864:	fffff097          	auipc	ra,0xfffff
    80001868:	ef2080e7          	jalr	-270(ra) # 80000756 <panic>
      panic("uvmunmap: not a leaf");
    8000186c:	00007517          	auipc	a0,0x7
    80001870:	c5c50513          	addi	a0,a0,-932 # 800084c8 <userret+0x438>
    80001874:	fffff097          	auipc	ra,0xfffff
    80001878:	ee2080e7          	jalr	-286(ra) # 80000756 <panic>
      pa = PTE2PA(*pte);
    8000187c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000187e:	0532                	slli	a0,a0,0xc
    80001880:	fffff097          	auipc	ra,0xfffff
    80001884:	26c080e7          	jalr	620(ra) # 80000aec <kfree>
    *pte = 0;
    80001888:	0004b023          	sd	zero,0(s1)
    if(a == last)
    8000188c:	03390763          	beq	s2,s3,800018ba <uvmunmap+0xb2>
    a += PGSIZE;
    80001890:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    80001892:	4601                	li	a2,0
    80001894:	85ca                	mv	a1,s2
    80001896:	8552                	mv	a0,s4
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	bf0080e7          	jalr	-1040(ra) # 80001488 <walk>
    800018a0:	84aa                	mv	s1,a0
    800018a2:	d959                	beqz	a0,80001838 <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    800018a4:	6108                	ld	a0,0(a0)
    800018a6:	00157793          	andi	a5,a0,1
    800018aa:	dfd9                	beqz	a5,80001848 <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    800018ac:	3ff57793          	andi	a5,a0,1023
    800018b0:	fb678ee3          	beq	a5,s6,8000186c <uvmunmap+0x64>
    if(do_free){
    800018b4:	fc0a8ae3          	beqz	s5,80001888 <uvmunmap+0x80>
    800018b8:	b7d1                	j	8000187c <uvmunmap+0x74>
}
    800018ba:	60a6                	ld	ra,72(sp)
    800018bc:	6406                	ld	s0,64(sp)
    800018be:	74e2                	ld	s1,56(sp)
    800018c0:	7942                	ld	s2,48(sp)
    800018c2:	79a2                	ld	s3,40(sp)
    800018c4:	7a02                	ld	s4,32(sp)
    800018c6:	6ae2                	ld	s5,24(sp)
    800018c8:	6b42                	ld	s6,16(sp)
    800018ca:	6ba2                	ld	s7,8(sp)
    800018cc:	6161                	addi	sp,sp,80
    800018ce:	8082                	ret

00000000800018d0 <uvmcreate>:
{
    800018d0:	1101                	addi	sp,sp,-32
    800018d2:	ec06                	sd	ra,24(sp)
    800018d4:	e822                	sd	s0,16(sp)
    800018d6:	e426                	sd	s1,8(sp)
    800018d8:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    800018da:	fffff097          	auipc	ra,0xfffff
    800018de:	22a080e7          	jalr	554(ra) # 80000b04 <kalloc>
  if(pagetable == 0)
    800018e2:	cd11                	beqz	a0,800018fe <uvmcreate+0x2e>
    800018e4:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    800018e6:	6605                	lui	a2,0x1
    800018e8:	4581                	li	a1,0
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	7ea080e7          	jalr	2026(ra) # 800010d4 <memset>
}
    800018f2:	8526                	mv	a0,s1
    800018f4:	60e2                	ld	ra,24(sp)
    800018f6:	6442                	ld	s0,16(sp)
    800018f8:	64a2                	ld	s1,8(sp)
    800018fa:	6105                	addi	sp,sp,32
    800018fc:	8082                	ret
    panic("uvmcreate: out of memory");
    800018fe:	00007517          	auipc	a0,0x7
    80001902:	be250513          	addi	a0,a0,-1054 # 800084e0 <userret+0x450>
    80001906:	fffff097          	auipc	ra,0xfffff
    8000190a:	e50080e7          	jalr	-432(ra) # 80000756 <panic>

000000008000190e <uvminit>:
{
    8000190e:	7179                	addi	sp,sp,-48
    80001910:	f406                	sd	ra,40(sp)
    80001912:	f022                	sd	s0,32(sp)
    80001914:	ec26                	sd	s1,24(sp)
    80001916:	e84a                	sd	s2,16(sp)
    80001918:	e44e                	sd	s3,8(sp)
    8000191a:	e052                	sd	s4,0(sp)
    8000191c:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    8000191e:	6785                	lui	a5,0x1
    80001920:	04f67863          	bgeu	a2,a5,80001970 <uvminit+0x62>
    80001924:	8a2a                	mv	s4,a0
    80001926:	89ae                	mv	s3,a1
    80001928:	84b2                	mv	s1,a2
  mem = kalloc();
    8000192a:	fffff097          	auipc	ra,0xfffff
    8000192e:	1da080e7          	jalr	474(ra) # 80000b04 <kalloc>
    80001932:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001934:	6605                	lui	a2,0x1
    80001936:	4581                	li	a1,0
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	79c080e7          	jalr	1948(ra) # 800010d4 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001940:	4779                	li	a4,30
    80001942:	86ca                	mv	a3,s2
    80001944:	6605                	lui	a2,0x1
    80001946:	4581                	li	a1,0
    80001948:	8552                	mv	a0,s4
    8000194a:	00000097          	auipc	ra,0x0
    8000194e:	d12080e7          	jalr	-750(ra) # 8000165c <mappages>
  memmove(mem, src, sz);
    80001952:	8626                	mv	a2,s1
    80001954:	85ce                	mv	a1,s3
    80001956:	854a                	mv	a0,s2
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	7dc080e7          	jalr	2012(ra) # 80001134 <memmove>
}
    80001960:	70a2                	ld	ra,40(sp)
    80001962:	7402                	ld	s0,32(sp)
    80001964:	64e2                	ld	s1,24(sp)
    80001966:	6942                	ld	s2,16(sp)
    80001968:	69a2                	ld	s3,8(sp)
    8000196a:	6a02                	ld	s4,0(sp)
    8000196c:	6145                	addi	sp,sp,48
    8000196e:	8082                	ret
    panic("inituvm: more than a page");
    80001970:	00007517          	auipc	a0,0x7
    80001974:	b9050513          	addi	a0,a0,-1136 # 80008500 <userret+0x470>
    80001978:	fffff097          	auipc	ra,0xfffff
    8000197c:	dde080e7          	jalr	-546(ra) # 80000756 <panic>

0000000080001980 <uvmdealloc>:
{
    80001980:	1101                	addi	sp,sp,-32
    80001982:	ec06                	sd	ra,24(sp)
    80001984:	e822                	sd	s0,16(sp)
    80001986:	e426                	sd	s1,8(sp)
    80001988:	1000                	addi	s0,sp,32
    return oldsz;
    8000198a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000198c:	00b67d63          	bgeu	a2,a1,800019a6 <uvmdealloc+0x26>
    80001990:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    80001992:	6785                	lui	a5,0x1
    80001994:	17fd                	addi	a5,a5,-1
    80001996:	00f60733          	add	a4,a2,a5
    8000199a:	76fd                	lui	a3,0xfffff
    8000199c:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    8000199e:	97ae                	add	a5,a5,a1
    800019a0:	8ff5                	and	a5,a5,a3
    800019a2:	00f76863          	bltu	a4,a5,800019b2 <uvmdealloc+0x32>
}
    800019a6:	8526                	mv	a0,s1
    800019a8:	60e2                	ld	ra,24(sp)
    800019aa:	6442                	ld	s0,16(sp)
    800019ac:	64a2                	ld	s1,8(sp)
    800019ae:	6105                	addi	sp,sp,32
    800019b0:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    800019b2:	4685                	li	a3,1
    800019b4:	40e58633          	sub	a2,a1,a4
    800019b8:	85ba                	mv	a1,a4
    800019ba:	00000097          	auipc	ra,0x0
    800019be:	e4e080e7          	jalr	-434(ra) # 80001808 <uvmunmap>
    800019c2:	b7d5                	j	800019a6 <uvmdealloc+0x26>

00000000800019c4 <uvmalloc>:
  if(newsz < oldsz)
    800019c4:	0ab66163          	bltu	a2,a1,80001a66 <uvmalloc+0xa2>
{
    800019c8:	7139                	addi	sp,sp,-64
    800019ca:	fc06                	sd	ra,56(sp)
    800019cc:	f822                	sd	s0,48(sp)
    800019ce:	f426                	sd	s1,40(sp)
    800019d0:	f04a                	sd	s2,32(sp)
    800019d2:	ec4e                	sd	s3,24(sp)
    800019d4:	e852                	sd	s4,16(sp)
    800019d6:	e456                	sd	s5,8(sp)
    800019d8:	0080                	addi	s0,sp,64
    800019da:	8aaa                	mv	s5,a0
    800019dc:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800019de:	6985                	lui	s3,0x1
    800019e0:	19fd                	addi	s3,s3,-1
    800019e2:	95ce                	add	a1,a1,s3
    800019e4:	79fd                	lui	s3,0xfffff
    800019e6:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    800019ea:	08c9f063          	bgeu	s3,a2,80001a6a <uvmalloc+0xa6>
  a = oldsz;
    800019ee:	894e                	mv	s2,s3
    mem = kalloc();
    800019f0:	fffff097          	auipc	ra,0xfffff
    800019f4:	114080e7          	jalr	276(ra) # 80000b04 <kalloc>
    800019f8:	84aa                	mv	s1,a0
    if(mem == 0){
    800019fa:	c51d                	beqz	a0,80001a28 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800019fc:	6605                	lui	a2,0x1
    800019fe:	4581                	li	a1,0
    80001a00:	fffff097          	auipc	ra,0xfffff
    80001a04:	6d4080e7          	jalr	1748(ra) # 800010d4 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001a08:	4779                	li	a4,30
    80001a0a:	86a6                	mv	a3,s1
    80001a0c:	6605                	lui	a2,0x1
    80001a0e:	85ca                	mv	a1,s2
    80001a10:	8556                	mv	a0,s5
    80001a12:	00000097          	auipc	ra,0x0
    80001a16:	c4a080e7          	jalr	-950(ra) # 8000165c <mappages>
    80001a1a:	e905                	bnez	a0,80001a4a <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    80001a1c:	6785                	lui	a5,0x1
    80001a1e:	993e                	add	s2,s2,a5
    80001a20:	fd4968e3          	bltu	s2,s4,800019f0 <uvmalloc+0x2c>
  return newsz;
    80001a24:	8552                	mv	a0,s4
    80001a26:	a809                	j	80001a38 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001a28:	864e                	mv	a2,s3
    80001a2a:	85ca                	mv	a1,s2
    80001a2c:	8556                	mv	a0,s5
    80001a2e:	00000097          	auipc	ra,0x0
    80001a32:	f52080e7          	jalr	-174(ra) # 80001980 <uvmdealloc>
      return 0;
    80001a36:	4501                	li	a0,0
}
    80001a38:	70e2                	ld	ra,56(sp)
    80001a3a:	7442                	ld	s0,48(sp)
    80001a3c:	74a2                	ld	s1,40(sp)
    80001a3e:	7902                	ld	s2,32(sp)
    80001a40:	69e2                	ld	s3,24(sp)
    80001a42:	6a42                	ld	s4,16(sp)
    80001a44:	6aa2                	ld	s5,8(sp)
    80001a46:	6121                	addi	sp,sp,64
    80001a48:	8082                	ret
      kfree(mem);
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	0a0080e7          	jalr	160(ra) # 80000aec <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001a54:	864e                	mv	a2,s3
    80001a56:	85ca                	mv	a1,s2
    80001a58:	8556                	mv	a0,s5
    80001a5a:	00000097          	auipc	ra,0x0
    80001a5e:	f26080e7          	jalr	-218(ra) # 80001980 <uvmdealloc>
      return 0;
    80001a62:	4501                	li	a0,0
    80001a64:	bfd1                	j	80001a38 <uvmalloc+0x74>
    return oldsz;
    80001a66:	852e                	mv	a0,a1
}
    80001a68:	8082                	ret
  return newsz;
    80001a6a:	8532                	mv	a0,a2
    80001a6c:	b7f1                	j	80001a38 <uvmalloc+0x74>

0000000080001a6e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001a6e:	1101                	addi	sp,sp,-32
    80001a70:	ec06                	sd	ra,24(sp)
    80001a72:	e822                	sd	s0,16(sp)
    80001a74:	e426                	sd	s1,8(sp)
    80001a76:	1000                	addi	s0,sp,32
    80001a78:	84aa                	mv	s1,a0
    80001a7a:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001a7c:	4685                	li	a3,1
    80001a7e:	4581                	li	a1,0
    80001a80:	00000097          	auipc	ra,0x0
    80001a84:	d88080e7          	jalr	-632(ra) # 80001808 <uvmunmap>
  freewalk(pagetable);
    80001a88:	8526                	mv	a0,s1
    80001a8a:	00000097          	auipc	ra,0x0
    80001a8e:	aa4080e7          	jalr	-1372(ra) # 8000152e <freewalk>
}
    80001a92:	60e2                	ld	ra,24(sp)
    80001a94:	6442                	ld	s0,16(sp)
    80001a96:	64a2                	ld	s1,8(sp)
    80001a98:	6105                	addi	sp,sp,32
    80001a9a:	8082                	ret

0000000080001a9c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001a9c:	c671                	beqz	a2,80001b68 <uvmcopy+0xcc>
{
    80001a9e:	715d                	addi	sp,sp,-80
    80001aa0:	e486                	sd	ra,72(sp)
    80001aa2:	e0a2                	sd	s0,64(sp)
    80001aa4:	fc26                	sd	s1,56(sp)
    80001aa6:	f84a                	sd	s2,48(sp)
    80001aa8:	f44e                	sd	s3,40(sp)
    80001aaa:	f052                	sd	s4,32(sp)
    80001aac:	ec56                	sd	s5,24(sp)
    80001aae:	e85a                	sd	s6,16(sp)
    80001ab0:	e45e                	sd	s7,8(sp)
    80001ab2:	0880                	addi	s0,sp,80
    80001ab4:	8b2a                	mv	s6,a0
    80001ab6:	8aae                	mv	s5,a1
    80001ab8:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001aba:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001abc:	4601                	li	a2,0
    80001abe:	85ce                	mv	a1,s3
    80001ac0:	855a                	mv	a0,s6
    80001ac2:	00000097          	auipc	ra,0x0
    80001ac6:	9c6080e7          	jalr	-1594(ra) # 80001488 <walk>
    80001aca:	c531                	beqz	a0,80001b16 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001acc:	6118                	ld	a4,0(a0)
    80001ace:	00177793          	andi	a5,a4,1
    80001ad2:	cbb1                	beqz	a5,80001b26 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001ad4:	00a75593          	srli	a1,a4,0xa
    80001ad8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001adc:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001ae0:	fffff097          	auipc	ra,0xfffff
    80001ae4:	024080e7          	jalr	36(ra) # 80000b04 <kalloc>
    80001ae8:	892a                	mv	s2,a0
    80001aea:	c939                	beqz	a0,80001b40 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001aec:	6605                	lui	a2,0x1
    80001aee:	85de                	mv	a1,s7
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	644080e7          	jalr	1604(ra) # 80001134 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001af8:	8726                	mv	a4,s1
    80001afa:	86ca                	mv	a3,s2
    80001afc:	6605                	lui	a2,0x1
    80001afe:	85ce                	mv	a1,s3
    80001b00:	8556                	mv	a0,s5
    80001b02:	00000097          	auipc	ra,0x0
    80001b06:	b5a080e7          	jalr	-1190(ra) # 8000165c <mappages>
    80001b0a:	e515                	bnez	a0,80001b36 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001b0c:	6785                	lui	a5,0x1
    80001b0e:	99be                	add	s3,s3,a5
    80001b10:	fb49e6e3          	bltu	s3,s4,80001abc <uvmcopy+0x20>
    80001b14:	a83d                	j	80001b52 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    80001b16:	00007517          	auipc	a0,0x7
    80001b1a:	a0a50513          	addi	a0,a0,-1526 # 80008520 <userret+0x490>
    80001b1e:	fffff097          	auipc	ra,0xfffff
    80001b22:	c38080e7          	jalr	-968(ra) # 80000756 <panic>
      panic("uvmcopy: page not present");
    80001b26:	00007517          	auipc	a0,0x7
    80001b2a:	a1a50513          	addi	a0,a0,-1510 # 80008540 <userret+0x4b0>
    80001b2e:	fffff097          	auipc	ra,0xfffff
    80001b32:	c28080e7          	jalr	-984(ra) # 80000756 <panic>
      kfree(mem);
    80001b36:	854a                	mv	a0,s2
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	fb4080e7          	jalr	-76(ra) # 80000aec <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    80001b40:	4685                	li	a3,1
    80001b42:	864e                	mv	a2,s3
    80001b44:	4581                	li	a1,0
    80001b46:	8556                	mv	a0,s5
    80001b48:	00000097          	auipc	ra,0x0
    80001b4c:	cc0080e7          	jalr	-832(ra) # 80001808 <uvmunmap>
  return -1;
    80001b50:	557d                	li	a0,-1
}
    80001b52:	60a6                	ld	ra,72(sp)
    80001b54:	6406                	ld	s0,64(sp)
    80001b56:	74e2                	ld	s1,56(sp)
    80001b58:	7942                	ld	s2,48(sp)
    80001b5a:	79a2                	ld	s3,40(sp)
    80001b5c:	7a02                	ld	s4,32(sp)
    80001b5e:	6ae2                	ld	s5,24(sp)
    80001b60:	6b42                	ld	s6,16(sp)
    80001b62:	6ba2                	ld	s7,8(sp)
    80001b64:	6161                	addi	sp,sp,80
    80001b66:	8082                	ret
  return 0;
    80001b68:	4501                	li	a0,0
}
    80001b6a:	8082                	ret

0000000080001b6c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001b6c:	1141                	addi	sp,sp,-16
    80001b6e:	e406                	sd	ra,8(sp)
    80001b70:	e022                	sd	s0,0(sp)
    80001b72:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001b74:	4601                	li	a2,0
    80001b76:	00000097          	auipc	ra,0x0
    80001b7a:	912080e7          	jalr	-1774(ra) # 80001488 <walk>
  if(pte == 0)
    80001b7e:	c901                	beqz	a0,80001b8e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001b80:	611c                	ld	a5,0(a0)
    80001b82:	9bbd                	andi	a5,a5,-17
    80001b84:	e11c                	sd	a5,0(a0)
}
    80001b86:	60a2                	ld	ra,8(sp)
    80001b88:	6402                	ld	s0,0(sp)
    80001b8a:	0141                	addi	sp,sp,16
    80001b8c:	8082                	ret
    panic("uvmclear");
    80001b8e:	00007517          	auipc	a0,0x7
    80001b92:	9d250513          	addi	a0,a0,-1582 # 80008560 <userret+0x4d0>
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	bc0080e7          	jalr	-1088(ra) # 80000756 <panic>

0000000080001b9e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001b9e:	c6bd                	beqz	a3,80001c0c <copyout+0x6e>
{
    80001ba0:	715d                	addi	sp,sp,-80
    80001ba2:	e486                	sd	ra,72(sp)
    80001ba4:	e0a2                	sd	s0,64(sp)
    80001ba6:	fc26                	sd	s1,56(sp)
    80001ba8:	f84a                	sd	s2,48(sp)
    80001baa:	f44e                	sd	s3,40(sp)
    80001bac:	f052                	sd	s4,32(sp)
    80001bae:	ec56                	sd	s5,24(sp)
    80001bb0:	e85a                	sd	s6,16(sp)
    80001bb2:	e45e                	sd	s7,8(sp)
    80001bb4:	e062                	sd	s8,0(sp)
    80001bb6:	0880                	addi	s0,sp,80
    80001bb8:	8b2a                	mv	s6,a0
    80001bba:	8c2e                	mv	s8,a1
    80001bbc:	8a32                	mv	s4,a2
    80001bbe:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001bc0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001bc2:	6a85                	lui	s5,0x1
    80001bc4:	a015                	j	80001be8 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001bc6:	9562                	add	a0,a0,s8
    80001bc8:	0004861b          	sext.w	a2,s1
    80001bcc:	85d2                	mv	a1,s4
    80001bce:	41250533          	sub	a0,a0,s2
    80001bd2:	fffff097          	auipc	ra,0xfffff
    80001bd6:	562080e7          	jalr	1378(ra) # 80001134 <memmove>

    len -= n;
    80001bda:	409989b3          	sub	s3,s3,s1
    src += n;
    80001bde:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001be0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001be4:	02098263          	beqz	s3,80001c08 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001be8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001bec:	85ca                	mv	a1,s2
    80001bee:	855a                	mv	a0,s6
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	9cc080e7          	jalr	-1588(ra) # 800015bc <walkaddr>
    if(pa0 == 0)
    80001bf8:	cd01                	beqz	a0,80001c10 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001bfa:	418904b3          	sub	s1,s2,s8
    80001bfe:	94d6                	add	s1,s1,s5
    if(n > len)
    80001c00:	fc99f3e3          	bgeu	s3,s1,80001bc6 <copyout+0x28>
    80001c04:	84ce                	mv	s1,s3
    80001c06:	b7c1                	j	80001bc6 <copyout+0x28>
  }
  return 0;
    80001c08:	4501                	li	a0,0
    80001c0a:	a021                	j	80001c12 <copyout+0x74>
    80001c0c:	4501                	li	a0,0
}
    80001c0e:	8082                	ret
      return -1;
    80001c10:	557d                	li	a0,-1
}
    80001c12:	60a6                	ld	ra,72(sp)
    80001c14:	6406                	ld	s0,64(sp)
    80001c16:	74e2                	ld	s1,56(sp)
    80001c18:	7942                	ld	s2,48(sp)
    80001c1a:	79a2                	ld	s3,40(sp)
    80001c1c:	7a02                	ld	s4,32(sp)
    80001c1e:	6ae2                	ld	s5,24(sp)
    80001c20:	6b42                	ld	s6,16(sp)
    80001c22:	6ba2                	ld	s7,8(sp)
    80001c24:	6c02                	ld	s8,0(sp)
    80001c26:	6161                	addi	sp,sp,80
    80001c28:	8082                	ret

0000000080001c2a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001c2a:	c6bd                	beqz	a3,80001c98 <copyin+0x6e>
{
    80001c2c:	715d                	addi	sp,sp,-80
    80001c2e:	e486                	sd	ra,72(sp)
    80001c30:	e0a2                	sd	s0,64(sp)
    80001c32:	fc26                	sd	s1,56(sp)
    80001c34:	f84a                	sd	s2,48(sp)
    80001c36:	f44e                	sd	s3,40(sp)
    80001c38:	f052                	sd	s4,32(sp)
    80001c3a:	ec56                	sd	s5,24(sp)
    80001c3c:	e85a                	sd	s6,16(sp)
    80001c3e:	e45e                	sd	s7,8(sp)
    80001c40:	e062                	sd	s8,0(sp)
    80001c42:	0880                	addi	s0,sp,80
    80001c44:	8b2a                	mv	s6,a0
    80001c46:	8a2e                	mv	s4,a1
    80001c48:	8c32                	mv	s8,a2
    80001c4a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001c4c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001c4e:	6a85                	lui	s5,0x1
    80001c50:	a015                	j	80001c74 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001c52:	9562                	add	a0,a0,s8
    80001c54:	0004861b          	sext.w	a2,s1
    80001c58:	412505b3          	sub	a1,a0,s2
    80001c5c:	8552                	mv	a0,s4
    80001c5e:	fffff097          	auipc	ra,0xfffff
    80001c62:	4d6080e7          	jalr	1238(ra) # 80001134 <memmove>

    len -= n;
    80001c66:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001c6a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001c6c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001c70:	02098263          	beqz	s3,80001c94 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001c74:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001c78:	85ca                	mv	a1,s2
    80001c7a:	855a                	mv	a0,s6
    80001c7c:	00000097          	auipc	ra,0x0
    80001c80:	940080e7          	jalr	-1728(ra) # 800015bc <walkaddr>
    if(pa0 == 0)
    80001c84:	cd01                	beqz	a0,80001c9c <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001c86:	418904b3          	sub	s1,s2,s8
    80001c8a:	94d6                	add	s1,s1,s5
    if(n > len)
    80001c8c:	fc99f3e3          	bgeu	s3,s1,80001c52 <copyin+0x28>
    80001c90:	84ce                	mv	s1,s3
    80001c92:	b7c1                	j	80001c52 <copyin+0x28>
  }
  return 0;
    80001c94:	4501                	li	a0,0
    80001c96:	a021                	j	80001c9e <copyin+0x74>
    80001c98:	4501                	li	a0,0
}
    80001c9a:	8082                	ret
      return -1;
    80001c9c:	557d                	li	a0,-1
}
    80001c9e:	60a6                	ld	ra,72(sp)
    80001ca0:	6406                	ld	s0,64(sp)
    80001ca2:	74e2                	ld	s1,56(sp)
    80001ca4:	7942                	ld	s2,48(sp)
    80001ca6:	79a2                	ld	s3,40(sp)
    80001ca8:	7a02                	ld	s4,32(sp)
    80001caa:	6ae2                	ld	s5,24(sp)
    80001cac:	6b42                	ld	s6,16(sp)
    80001cae:	6ba2                	ld	s7,8(sp)
    80001cb0:	6c02                	ld	s8,0(sp)
    80001cb2:	6161                	addi	sp,sp,80
    80001cb4:	8082                	ret

0000000080001cb6 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001cb6:	c6c5                	beqz	a3,80001d5e <copyinstr+0xa8>
{
    80001cb8:	715d                	addi	sp,sp,-80
    80001cba:	e486                	sd	ra,72(sp)
    80001cbc:	e0a2                	sd	s0,64(sp)
    80001cbe:	fc26                	sd	s1,56(sp)
    80001cc0:	f84a                	sd	s2,48(sp)
    80001cc2:	f44e                	sd	s3,40(sp)
    80001cc4:	f052                	sd	s4,32(sp)
    80001cc6:	ec56                	sd	s5,24(sp)
    80001cc8:	e85a                	sd	s6,16(sp)
    80001cca:	e45e                	sd	s7,8(sp)
    80001ccc:	0880                	addi	s0,sp,80
    80001cce:	8a2a                	mv	s4,a0
    80001cd0:	8b2e                	mv	s6,a1
    80001cd2:	8bb2                	mv	s7,a2
    80001cd4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001cd6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001cd8:	6985                	lui	s3,0x1
    80001cda:	a035                	j	80001d06 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001cdc:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001ce0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001ce2:	0017b793          	seqz	a5,a5
    80001ce6:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001cea:	60a6                	ld	ra,72(sp)
    80001cec:	6406                	ld	s0,64(sp)
    80001cee:	74e2                	ld	s1,56(sp)
    80001cf0:	7942                	ld	s2,48(sp)
    80001cf2:	79a2                	ld	s3,40(sp)
    80001cf4:	7a02                	ld	s4,32(sp)
    80001cf6:	6ae2                	ld	s5,24(sp)
    80001cf8:	6b42                	ld	s6,16(sp)
    80001cfa:	6ba2                	ld	s7,8(sp)
    80001cfc:	6161                	addi	sp,sp,80
    80001cfe:	8082                	ret
    srcva = va0 + PGSIZE;
    80001d00:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001d04:	c8a9                	beqz	s1,80001d56 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001d06:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001d0a:	85ca                	mv	a1,s2
    80001d0c:	8552                	mv	a0,s4
    80001d0e:	00000097          	auipc	ra,0x0
    80001d12:	8ae080e7          	jalr	-1874(ra) # 800015bc <walkaddr>
    if(pa0 == 0)
    80001d16:	c131                	beqz	a0,80001d5a <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001d18:	41790833          	sub	a6,s2,s7
    80001d1c:	984e                	add	a6,a6,s3
    if(n > max)
    80001d1e:	0104f363          	bgeu	s1,a6,80001d24 <copyinstr+0x6e>
    80001d22:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001d24:	955e                	add	a0,a0,s7
    80001d26:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001d2a:	fc080be3          	beqz	a6,80001d00 <copyinstr+0x4a>
    80001d2e:	985a                	add	a6,a6,s6
    80001d30:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001d32:	41650633          	sub	a2,a0,s6
    80001d36:	14fd                	addi	s1,s1,-1
    80001d38:	9b26                	add	s6,s6,s1
    80001d3a:	00f60733          	add	a4,a2,a5
    80001d3e:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd0f54>
    80001d42:	df49                	beqz	a4,80001cdc <copyinstr+0x26>
        *dst = *p;
    80001d44:	00e78023          	sb	a4,0(a5)
      --max;
    80001d48:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001d4c:	0785                	addi	a5,a5,1
    while(n > 0){
    80001d4e:	ff0796e3          	bne	a5,a6,80001d3a <copyinstr+0x84>
      dst++;
    80001d52:	8b42                	mv	s6,a6
    80001d54:	b775                	j	80001d00 <copyinstr+0x4a>
    80001d56:	4781                	li	a5,0
    80001d58:	b769                	j	80001ce2 <copyinstr+0x2c>
      return -1;
    80001d5a:	557d                	li	a0,-1
    80001d5c:	b779                	j	80001cea <copyinstr+0x34>
  int got_null = 0;
    80001d5e:	4781                	li	a5,0
  if(got_null){
    80001d60:	0017b793          	seqz	a5,a5
    80001d64:	40f00533          	neg	a0,a5
}
    80001d68:	8082                	ret

0000000080001d6a <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001d6a:	1101                	addi	sp,sp,-32
    80001d6c:	ec06                	sd	ra,24(sp)
    80001d6e:	e822                	sd	s0,16(sp)
    80001d70:	e426                	sd	s1,8(sp)
    80001d72:	1000                	addi	s0,sp,32
    80001d74:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d76:	fffff097          	auipc	ra,0xfffff
    80001d7a:	e94080e7          	jalr	-364(ra) # 80000c0a <holding>
    80001d7e:	c909                	beqz	a0,80001d90 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001d80:	60bc                	ld	a5,64(s1)
    80001d82:	00978f63          	beq	a5,s1,80001da0 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001d86:	60e2                	ld	ra,24(sp)
    80001d88:	6442                	ld	s0,16(sp)
    80001d8a:	64a2                	ld	s1,8(sp)
    80001d8c:	6105                	addi	sp,sp,32
    80001d8e:	8082                	ret
    panic("wakeup1");
    80001d90:	00006517          	auipc	a0,0x6
    80001d94:	7e050513          	addi	a0,a0,2016 # 80008570 <userret+0x4e0>
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	9be080e7          	jalr	-1602(ra) # 80000756 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001da0:	5898                	lw	a4,48(s1)
    80001da2:	4785                	li	a5,1
    80001da4:	fef711e3          	bne	a4,a5,80001d86 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001da8:	4789                	li	a5,2
    80001daa:	d89c                	sw	a5,48(s1)
}
    80001dac:	bfe9                	j	80001d86 <wakeup1+0x1c>

0000000080001dae <insert_into_prio_queue>:
void insert_into_prio_queue(struct proc* p){
    80001dae:	1101                	addi	sp,sp,-32
    80001db0:	ec06                	sd	ra,24(sp)
    80001db2:	e822                	sd	s0,16(sp)
    80001db4:	e426                	sd	s1,8(sp)
    80001db6:	1000                	addi	s0,sp,32
    80001db8:	84aa                	mv	s1,a0
  struct list_proc* new = bd_malloc(sizeof(struct list_proc));
    80001dba:	4541                	li	a0,16
    80001dbc:	00005097          	auipc	ra,0x5
    80001dc0:	134080e7          	jalr	308(ra) # 80006ef0 <bd_malloc>
  new->next = 0;
    80001dc4:	00053423          	sd	zero,8(a0)
  new->p = p;
    80001dc8:	e104                	sd	s1,0(a0)
  if(!prio[p->priority]){
    80001dca:	48f8                	lw	a4,84(s1)
    80001dcc:	00371693          	slli	a3,a4,0x3
    80001dd0:	00014797          	auipc	a5,0x14
    80001dd4:	c1878793          	addi	a5,a5,-1000 # 800159e8 <prio>
    80001dd8:	97b6                	add	a5,a5,a3
    80001dda:	639c                	ld	a5,0(a5)
    80001ddc:	cb91                	beqz	a5,80001df0 <insert_into_prio_queue+0x42>
    80001dde:	873e                	mv	a4,a5
    while(last && last->next){
    80001de0:	679c                	ld	a5,8(a5)
    80001de2:	fff5                	bnez	a5,80001dde <insert_into_prio_queue+0x30>
    last->next = new;
    80001de4:	e708                	sd	a0,8(a4)
}
    80001de6:	60e2                	ld	ra,24(sp)
    80001de8:	6442                	ld	s0,16(sp)
    80001dea:	64a2                	ld	s1,8(sp)
    80001dec:	6105                	addi	sp,sp,32
    80001dee:	8082                	ret
    prio[p->priority] = new;
    80001df0:	00014797          	auipc	a5,0x14
    80001df4:	bf878793          	addi	a5,a5,-1032 # 800159e8 <prio>
    80001df8:	00d78733          	add	a4,a5,a3
    80001dfc:	e308                	sd	a0,0(a4)
    80001dfe:	b7e5                	j	80001de6 <insert_into_prio_queue+0x38>

0000000080001e00 <remove_from_prio_queue>:
void remove_from_prio_queue(struct proc* p){
    80001e00:	1101                	addi	sp,sp,-32
    80001e02:	ec06                	sd	ra,24(sp)
    80001e04:	e822                	sd	s0,16(sp)
    80001e06:	e426                	sd	s1,8(sp)
    80001e08:	e04a                	sd	s2,0(sp)
    80001e0a:	1000                	addi	s0,sp,32
    80001e0c:	84aa                	mv	s1,a0
  struct list_proc* old = prio[p->priority];
    80001e0e:	497c                	lw	a5,84(a0)
    80001e10:	00379713          	slli	a4,a5,0x3
    80001e14:	00014797          	auipc	a5,0x14
    80001e18:	bd478793          	addi	a5,a5,-1068 # 800159e8 <prio>
    80001e1c:	97ba                	add	a5,a5,a4
    80001e1e:	0007b903          	ld	s2,0(a5)
  while(old){
    80001e22:	02090563          	beqz	s2,80001e4c <remove_from_prio_queue+0x4c>
  struct list_proc* old = prio[p->priority];
    80001e26:	854a                	mv	a0,s2
  struct list_proc* prev = 0;
    80001e28:	4701                	li	a4,0
    80001e2a:	a011                	j	80001e2e <remove_from_prio_queue+0x2e>
    old = old->next;
    80001e2c:	853e                	mv	a0,a5
    if(old->p == p) {
    80001e2e:	611c                	ld	a5,0(a0)
    80001e30:	00978663          	beq	a5,s1,80001e3c <remove_from_prio_queue+0x3c>
    old = old->next;
    80001e34:	651c                	ld	a5,8(a0)
  while(old){
    80001e36:	872a                	mv	a4,a0
    80001e38:	fbf5                	bnez	a5,80001e2c <remove_from_prio_queue+0x2c>
    80001e3a:	a809                	j	80001e4c <remove_from_prio_queue+0x4c>
      if(old == head){
    80001e3c:	02a90863          	beq	s2,a0,80001e6c <remove_from_prio_queue+0x6c>
        prev->next = old->next;
    80001e40:	651c                	ld	a5,8(a0)
    80001e42:	e71c                	sd	a5,8(a4)
      bd_free(old);
    80001e44:	00005097          	auipc	ra,0x5
    80001e48:	298080e7          	jalr	664(ra) # 800070dc <bd_free>
  prio[p->priority] = head;
    80001e4c:	48fc                	lw	a5,84(s1)
    80001e4e:	00379713          	slli	a4,a5,0x3
    80001e52:	00014797          	auipc	a5,0x14
    80001e56:	b9678793          	addi	a5,a5,-1130 # 800159e8 <prio>
    80001e5a:	97ba                	add	a5,a5,a4
    80001e5c:	0127b023          	sd	s2,0(a5)
}
    80001e60:	60e2                	ld	ra,24(sp)
    80001e62:	6442                	ld	s0,16(sp)
    80001e64:	64a2                	ld	s1,8(sp)
    80001e66:	6902                	ld	s2,0(sp)
    80001e68:	6105                	addi	sp,sp,32
    80001e6a:	8082                	ret
        head = old->next;
    80001e6c:	00853903          	ld	s2,8(a0)
    80001e70:	bfd1                	j	80001e44 <remove_from_prio_queue+0x44>

0000000080001e72 <procinit>:
{
    80001e72:	715d                	addi	sp,sp,-80
    80001e74:	e486                	sd	ra,72(sp)
    80001e76:	e0a2                	sd	s0,64(sp)
    80001e78:	fc26                	sd	s1,56(sp)
    80001e7a:	f84a                	sd	s2,48(sp)
    80001e7c:	f44e                	sd	s3,40(sp)
    80001e7e:	f052                	sd	s4,32(sp)
    80001e80:	ec56                	sd	s5,24(sp)
    80001e82:	e85a                	sd	s6,16(sp)
    80001e84:	e45e                	sd	s7,8(sp)
    80001e86:	0880                	addi	s0,sp,80
  initlock(&prio_lock, "priolock");
    80001e88:	00014497          	auipc	s1,0x14
    80001e8c:	bb048493          	addi	s1,s1,-1104 # 80015a38 <prio_lock>
    80001e90:	00006597          	auipc	a1,0x6
    80001e94:	6e858593          	addi	a1,a1,1768 # 80008578 <userret+0x4e8>
    80001e98:	8526                	mv	a0,s1
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	c84080e7          	jalr	-892(ra) # 80000b1e <initlock>
  for(int i = 0; i < NPRIO; i++){
    80001ea2:	00014797          	auipc	a5,0x14
    80001ea6:	b4678793          	addi	a5,a5,-1210 # 800159e8 <prio>
    80001eaa:	8526                	mv	a0,s1
    prio[i] = 0;
    80001eac:	0007b023          	sd	zero,0(a5)
  for(int i = 0; i < NPRIO; i++){
    80001eb0:	07a1                	addi	a5,a5,8
    80001eb2:	fea79de3          	bne	a5,a0,80001eac <procinit+0x3a>
  initlock(&pid_lock, "nextpid");
    80001eb6:	00006597          	auipc	a1,0x6
    80001eba:	6d258593          	addi	a1,a1,1746 # 80008588 <userret+0x4f8>
    80001ebe:	00014517          	auipc	a0,0x14
    80001ec2:	baa50513          	addi	a0,a0,-1110 # 80015a68 <pid_lock>
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	c58080e7          	jalr	-936(ra) # 80000b1e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ece:	00014917          	auipc	s2,0x14
    80001ed2:	fca90913          	addi	s2,s2,-54 # 80015e98 <proc>
      initlock(&p->lock, "proc");
    80001ed6:	00006b97          	auipc	s7,0x6
    80001eda:	6bab8b93          	addi	s7,s7,1722 # 80008590 <userret+0x500>
      uint64 va = KSTACK((int) (p - proc));
    80001ede:	8b4a                	mv	s6,s2
    80001ee0:	00007a97          	auipc	s5,0x7
    80001ee4:	278a8a93          	addi	s5,s5,632 # 80009158 <syscalls+0xd8>
    80001ee8:	040009b7          	lui	s3,0x4000
    80001eec:	19fd                	addi	s3,s3,-1
    80001eee:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ef0:	0001aa17          	auipc	s4,0x1a
    80001ef4:	1a8a0a13          	addi	s4,s4,424 # 8001c098 <tickslock>
      initlock(&p->lock, "proc");
    80001ef8:	85de                	mv	a1,s7
    80001efa:	854a                	mv	a0,s2
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	c22080e7          	jalr	-990(ra) # 80000b1e <initlock>
      char *pa = kalloc();
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	c00080e7          	jalr	-1024(ra) # 80000b04 <kalloc>
    80001f0c:	85aa                	mv	a1,a0
      if(pa == 0)
    80001f0e:	c929                	beqz	a0,80001f60 <procinit+0xee>
      uint64 va = KSTACK((int) (p - proc));
    80001f10:	416904b3          	sub	s1,s2,s6
    80001f14:	848d                	srai	s1,s1,0x3
    80001f16:	000ab783          	ld	a5,0(s5)
    80001f1a:	02f484b3          	mul	s1,s1,a5
    80001f1e:	2485                	addiw	s1,s1,1
    80001f20:	00d4949b          	slliw	s1,s1,0xd
    80001f24:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001f28:	4699                	li	a3,6
    80001f2a:	6605                	lui	a2,0x1
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	fffff097          	auipc	ra,0xfffff
    80001f32:	7bc080e7          	jalr	1980(ra) # 800016ea <kvmmap>
      p->kstack = va;
    80001f36:	04993c23          	sd	s1,88(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f3a:	18890913          	addi	s2,s2,392
    80001f3e:	fb491de3          	bne	s2,s4,80001ef8 <procinit+0x86>
  kvminithart();
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	656080e7          	jalr	1622(ra) # 80001598 <kvminithart>
}
    80001f4a:	60a6                	ld	ra,72(sp)
    80001f4c:	6406                	ld	s0,64(sp)
    80001f4e:	74e2                	ld	s1,56(sp)
    80001f50:	7942                	ld	s2,48(sp)
    80001f52:	79a2                	ld	s3,40(sp)
    80001f54:	7a02                	ld	s4,32(sp)
    80001f56:	6ae2                	ld	s5,24(sp)
    80001f58:	6b42                	ld	s6,16(sp)
    80001f5a:	6ba2                	ld	s7,8(sp)
    80001f5c:	6161                	addi	sp,sp,80
    80001f5e:	8082                	ret
        panic("kalloc");
    80001f60:	00006517          	auipc	a0,0x6
    80001f64:	63850513          	addi	a0,a0,1592 # 80008598 <userret+0x508>
    80001f68:	ffffe097          	auipc	ra,0xffffe
    80001f6c:	7ee080e7          	jalr	2030(ra) # 80000756 <panic>

0000000080001f70 <cpuid>:
{
    80001f70:	1141                	addi	sp,sp,-16
    80001f72:	e422                	sd	s0,8(sp)
    80001f74:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f76:	8512                	mv	a0,tp
}
    80001f78:	2501                	sext.w	a0,a0
    80001f7a:	6422                	ld	s0,8(sp)
    80001f7c:	0141                	addi	sp,sp,16
    80001f7e:	8082                	ret

0000000080001f80 <mycpu>:
mycpu(void) {
    80001f80:	1141                	addi	sp,sp,-16
    80001f82:	e422                	sd	s0,8(sp)
    80001f84:	0800                	addi	s0,sp,16
    80001f86:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001f88:	2781                	sext.w	a5,a5
    80001f8a:	079e                	slli	a5,a5,0x7
}
    80001f8c:	00014517          	auipc	a0,0x14
    80001f90:	b0c50513          	addi	a0,a0,-1268 # 80015a98 <cpus>
    80001f94:	953e                	add	a0,a0,a5
    80001f96:	6422                	ld	s0,8(sp)
    80001f98:	0141                	addi	sp,sp,16
    80001f9a:	8082                	ret

0000000080001f9c <myproc>:
myproc(void) {
    80001f9c:	1101                	addi	sp,sp,-32
    80001f9e:	ec06                	sd	ra,24(sp)
    80001fa0:	e822                	sd	s0,16(sp)
    80001fa2:	e426                	sd	s1,8(sp)
    80001fa4:	1000                	addi	s0,sp,32
  push_off();
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	c92080e7          	jalr	-878(ra) # 80000c38 <push_off>
    80001fae:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001fb0:	2781                	sext.w	a5,a5
    80001fb2:	079e                	slli	a5,a5,0x7
    80001fb4:	00014717          	auipc	a4,0x14
    80001fb8:	a3470713          	addi	a4,a4,-1484 # 800159e8 <prio>
    80001fbc:	97ba                	add	a5,a5,a4
    80001fbe:	7bc4                	ld	s1,176(a5)
  pop_off();
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	eb4080e7          	jalr	-332(ra) # 80000e74 <pop_off>
}
    80001fc8:	8526                	mv	a0,s1
    80001fca:	60e2                	ld	ra,24(sp)
    80001fcc:	6442                	ld	s0,16(sp)
    80001fce:	64a2                	ld	s1,8(sp)
    80001fd0:	6105                	addi	sp,sp,32
    80001fd2:	8082                	ret

0000000080001fd4 <forkret>:
{
    80001fd4:	1141                	addi	sp,sp,-16
    80001fd6:	e406                	sd	ra,8(sp)
    80001fd8:	e022                	sd	s0,0(sp)
    80001fda:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	fc0080e7          	jalr	-64(ra) # 80001f9c <myproc>
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	ef0080e7          	jalr	-272(ra) # 80000ed4 <release>
  if (first) {
    80001fec:	00008797          	auipc	a5,0x8
    80001ff0:	06c7a783          	lw	a5,108(a5) # 8000a058 <first.1793>
    80001ff4:	eb89                	bnez	a5,80002006 <forkret+0x32>
  usertrapret();
    80001ff6:	00001097          	auipc	ra,0x1
    80001ffa:	e1e080e7          	jalr	-482(ra) # 80002e14 <usertrapret>
}
    80001ffe:	60a2                	ld	ra,8(sp)
    80002000:	6402                	ld	s0,0(sp)
    80002002:	0141                	addi	sp,sp,16
    80002004:	8082                	ret
    first = 0;
    80002006:	00008797          	auipc	a5,0x8
    8000200a:	0407a923          	sw	zero,82(a5) # 8000a058 <first.1793>
    fsinit(minor(ROOTDEV));
    8000200e:	4501                	li	a0,0
    80002010:	00002097          	auipc	ra,0x2
    80002014:	bbe080e7          	jalr	-1090(ra) # 80003bce <fsinit>
    80002018:	bff9                	j	80001ff6 <forkret+0x22>

000000008000201a <allocpid>:
allocpid() {
    8000201a:	1101                	addi	sp,sp,-32
    8000201c:	ec06                	sd	ra,24(sp)
    8000201e:	e822                	sd	s0,16(sp)
    80002020:	e426                	sd	s1,8(sp)
    80002022:	e04a                	sd	s2,0(sp)
    80002024:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80002026:	00014917          	auipc	s2,0x14
    8000202a:	a4290913          	addi	s2,s2,-1470 # 80015a68 <pid_lock>
    8000202e:	854a                	mv	a0,s2
    80002030:	fffff097          	auipc	ra,0xfffff
    80002034:	c58080e7          	jalr	-936(ra) # 80000c88 <acquire>
  pid = nextpid;
    80002038:	00008797          	auipc	a5,0x8
    8000203c:	02478793          	addi	a5,a5,36 # 8000a05c <nextpid>
    80002040:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80002042:	0014871b          	addiw	a4,s1,1
    80002046:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80002048:	854a                	mv	a0,s2
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	e8a080e7          	jalr	-374(ra) # 80000ed4 <release>
}
    80002052:	8526                	mv	a0,s1
    80002054:	60e2                	ld	ra,24(sp)
    80002056:	6442                	ld	s0,16(sp)
    80002058:	64a2                	ld	s1,8(sp)
    8000205a:	6902                	ld	s2,0(sp)
    8000205c:	6105                	addi	sp,sp,32
    8000205e:	8082                	ret

0000000080002060 <proc_pagetable>:
{
    80002060:	1101                	addi	sp,sp,-32
    80002062:	ec06                	sd	ra,24(sp)
    80002064:	e822                	sd	s0,16(sp)
    80002066:	e426                	sd	s1,8(sp)
    80002068:	e04a                	sd	s2,0(sp)
    8000206a:	1000                	addi	s0,sp,32
    8000206c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000206e:	00000097          	auipc	ra,0x0
    80002072:	862080e7          	jalr	-1950(ra) # 800018d0 <uvmcreate>
    80002076:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80002078:	4729                	li	a4,10
    8000207a:	00006697          	auipc	a3,0x6
    8000207e:	f8668693          	addi	a3,a3,-122 # 80008000 <trampoline>
    80002082:	6605                	lui	a2,0x1
    80002084:	040005b7          	lui	a1,0x4000
    80002088:	15fd                	addi	a1,a1,-1
    8000208a:	05b2                	slli	a1,a1,0xc
    8000208c:	fffff097          	auipc	ra,0xfffff
    80002090:	5d0080e7          	jalr	1488(ra) # 8000165c <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80002094:	4719                	li	a4,6
    80002096:	07093683          	ld	a3,112(s2)
    8000209a:	6605                	lui	a2,0x1
    8000209c:	020005b7          	lui	a1,0x2000
    800020a0:	15fd                	addi	a1,a1,-1
    800020a2:	05b6                	slli	a1,a1,0xd
    800020a4:	8526                	mv	a0,s1
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	5b6080e7          	jalr	1462(ra) # 8000165c <mappages>
}
    800020ae:	8526                	mv	a0,s1
    800020b0:	60e2                	ld	ra,24(sp)
    800020b2:	6442                	ld	s0,16(sp)
    800020b4:	64a2                	ld	s1,8(sp)
    800020b6:	6902                	ld	s2,0(sp)
    800020b8:	6105                	addi	sp,sp,32
    800020ba:	8082                	ret

00000000800020bc <allocproc>:
{
    800020bc:	1101                	addi	sp,sp,-32
    800020be:	ec06                	sd	ra,24(sp)
    800020c0:	e822                	sd	s0,16(sp)
    800020c2:	e426                	sd	s1,8(sp)
    800020c4:	e04a                	sd	s2,0(sp)
    800020c6:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800020c8:	00014497          	auipc	s1,0x14
    800020cc:	dd048493          	addi	s1,s1,-560 # 80015e98 <proc>
    800020d0:	0001a917          	auipc	s2,0x1a
    800020d4:	fc890913          	addi	s2,s2,-56 # 8001c098 <tickslock>
    acquire(&p->lock);
    800020d8:	8526                	mv	a0,s1
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	bae080e7          	jalr	-1106(ra) # 80000c88 <acquire>
    if(p->state == UNUSED) {
    800020e2:	589c                	lw	a5,48(s1)
    800020e4:	cf81                	beqz	a5,800020fc <allocproc+0x40>
      release(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	dec080e7          	jalr	-532(ra) # 80000ed4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020f0:	18848493          	addi	s1,s1,392
    800020f4:	ff2492e3          	bne	s1,s2,800020d8 <allocproc+0x1c>
  return 0;
    800020f8:	4481                	li	s1,0
    800020fa:	a0b9                	j	80002148 <allocproc+0x8c>
  p->pid = allocpid();
    800020fc:	00000097          	auipc	ra,0x0
    80002100:	f1e080e7          	jalr	-226(ra) # 8000201a <allocpid>
    80002104:	c8a8                	sw	a0,80(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	9fe080e7          	jalr	-1538(ra) # 80000b04 <kalloc>
    8000210e:	892a                	mv	s2,a0
    80002110:	f8a8                	sd	a0,112(s1)
    80002112:	c131                	beqz	a0,80002156 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80002114:	8526                	mv	a0,s1
    80002116:	00000097          	auipc	ra,0x0
    8000211a:	f4a080e7          	jalr	-182(ra) # 80002060 <proc_pagetable>
    8000211e:	f4a8                	sd	a0,104(s1)
  p->priority = DEF_PRIO;
    80002120:	4795                	li	a5,5
    80002122:	c8fc                	sw	a5,84(s1)
  memset(&p->context, 0, sizeof p->context);
    80002124:	07000613          	li	a2,112
    80002128:	4581                	li	a1,0
    8000212a:	07848513          	addi	a0,s1,120
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	fa6080e7          	jalr	-90(ra) # 800010d4 <memset>
  p->context.ra = (uint64)forkret;
    80002136:	00000797          	auipc	a5,0x0
    8000213a:	e9e78793          	addi	a5,a5,-354 # 80001fd4 <forkret>
    8000213e:	fcbc                	sd	a5,120(s1)
  p->context.sp = p->kstack + PGSIZE;
    80002140:	6cbc                	ld	a5,88(s1)
    80002142:	6705                	lui	a4,0x1
    80002144:	97ba                	add	a5,a5,a4
    80002146:	e0dc                	sd	a5,128(s1)
}
    80002148:	8526                	mv	a0,s1
    8000214a:	60e2                	ld	ra,24(sp)
    8000214c:	6442                	ld	s0,16(sp)
    8000214e:	64a2                	ld	s1,8(sp)
    80002150:	6902                	ld	s2,0(sp)
    80002152:	6105                	addi	sp,sp,32
    80002154:	8082                	ret
    release(&p->lock);
    80002156:	8526                	mv	a0,s1
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	d7c080e7          	jalr	-644(ra) # 80000ed4 <release>
    return 0;
    80002160:	84ca                	mv	s1,s2
    80002162:	b7dd                	j	80002148 <allocproc+0x8c>

0000000080002164 <proc_freepagetable>:
{
    80002164:	1101                	addi	sp,sp,-32
    80002166:	ec06                	sd	ra,24(sp)
    80002168:	e822                	sd	s0,16(sp)
    8000216a:	e426                	sd	s1,8(sp)
    8000216c:	e04a                	sd	s2,0(sp)
    8000216e:	1000                	addi	s0,sp,32
    80002170:	84aa                	mv	s1,a0
    80002172:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80002174:	4681                	li	a3,0
    80002176:	6605                	lui	a2,0x1
    80002178:	040005b7          	lui	a1,0x4000
    8000217c:	15fd                	addi	a1,a1,-1
    8000217e:	05b2                	slli	a1,a1,0xc
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	688080e7          	jalr	1672(ra) # 80001808 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80002188:	4681                	li	a3,0
    8000218a:	6605                	lui	a2,0x1
    8000218c:	020005b7          	lui	a1,0x2000
    80002190:	15fd                	addi	a1,a1,-1
    80002192:	05b6                	slli	a1,a1,0xd
    80002194:	8526                	mv	a0,s1
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	672080e7          	jalr	1650(ra) # 80001808 <uvmunmap>
  if(sz > 0)
    8000219e:	00091863          	bnez	s2,800021ae <proc_freepagetable+0x4a>
}
    800021a2:	60e2                	ld	ra,24(sp)
    800021a4:	6442                	ld	s0,16(sp)
    800021a6:	64a2                	ld	s1,8(sp)
    800021a8:	6902                	ld	s2,0(sp)
    800021aa:	6105                	addi	sp,sp,32
    800021ac:	8082                	ret
    uvmfree(pagetable, sz);
    800021ae:	85ca                	mv	a1,s2
    800021b0:	8526                	mv	a0,s1
    800021b2:	00000097          	auipc	ra,0x0
    800021b6:	8bc080e7          	jalr	-1860(ra) # 80001a6e <uvmfree>
}
    800021ba:	b7e5                	j	800021a2 <proc_freepagetable+0x3e>

00000000800021bc <freeproc>:
{
    800021bc:	1101                	addi	sp,sp,-32
    800021be:	ec06                	sd	ra,24(sp)
    800021c0:	e822                	sd	s0,16(sp)
    800021c2:	e426                	sd	s1,8(sp)
    800021c4:	1000                	addi	s0,sp,32
    800021c6:	84aa                	mv	s1,a0
  if(p->tf)
    800021c8:	7928                	ld	a0,112(a0)
    800021ca:	c509                	beqz	a0,800021d4 <freeproc+0x18>
    kfree((void*)p->tf);
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	920080e7          	jalr	-1760(ra) # 80000aec <kfree>
  p->tf = 0;
    800021d4:	0604b823          	sd	zero,112(s1)
  if(p->pagetable)
    800021d8:	74a8                	ld	a0,104(s1)
    800021da:	c511                	beqz	a0,800021e6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    800021dc:	70ac                	ld	a1,96(s1)
    800021de:	00000097          	auipc	ra,0x0
    800021e2:	f86080e7          	jalr	-122(ra) # 80002164 <proc_freepagetable>
  if(p->cmd)
    800021e6:	1804b503          	ld	a0,384(s1)
    800021ea:	c509                	beqz	a0,800021f4 <freeproc+0x38>
    bd_free(p->cmd);
    800021ec:	00005097          	auipc	ra,0x5
    800021f0:	ef0080e7          	jalr	-272(ra) # 800070dc <bd_free>
  p->cmd = 0;
    800021f4:	1804b023          	sd	zero,384(s1)
  p->priority = 0;
    800021f8:	0404aa23          	sw	zero,84(s1)
  p->pagetable = 0;
    800021fc:	0604b423          	sd	zero,104(s1)
  p->sz = 0;
    80002200:	0604b023          	sd	zero,96(s1)
  p->pid = 0;
    80002204:	0404a823          	sw	zero,80(s1)
  p->parent = 0;
    80002208:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000220c:	16048823          	sb	zero,368(s1)
  p->chan = 0;
    80002210:	0404b023          	sd	zero,64(s1)
  p->killed = 0;
    80002214:	0404a423          	sw	zero,72(s1)
  p->xstate = 0;
    80002218:	0404a623          	sw	zero,76(s1)
  p->state = UNUSED;
    8000221c:	0204a823          	sw	zero,48(s1)
}
    80002220:	60e2                	ld	ra,24(sp)
    80002222:	6442                	ld	s0,16(sp)
    80002224:	64a2                	ld	s1,8(sp)
    80002226:	6105                	addi	sp,sp,32
    80002228:	8082                	ret

000000008000222a <userinit>:
{
    8000222a:	1101                	addi	sp,sp,-32
    8000222c:	ec06                	sd	ra,24(sp)
    8000222e:	e822                	sd	s0,16(sp)
    80002230:	e426                	sd	s1,8(sp)
    80002232:	e04a                	sd	s2,0(sp)
    80002234:	1000                	addi	s0,sp,32
  p = allocproc();
    80002236:	00000097          	auipc	ra,0x0
    8000223a:	e86080e7          	jalr	-378(ra) # 800020bc <allocproc>
    8000223e:	84aa                	mv	s1,a0
  initproc = p;
    80002240:	0002c797          	auipc	a5,0x2c
    80002244:	e4a7b023          	sd	a0,-448(a5) # 8002e080 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80002248:	03300613          	li	a2,51
    8000224c:	00008597          	auipc	a1,0x8
    80002250:	db458593          	addi	a1,a1,-588 # 8000a000 <initcode>
    80002254:	7528                	ld	a0,104(a0)
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	6b8080e7          	jalr	1720(ra) # 8000190e <uvminit>
  p->sz = PGSIZE;
    8000225e:	6785                	lui	a5,0x1
    80002260:	f0bc                	sd	a5,96(s1)
  p->tf->epc = 0;      // user program counter
    80002262:	78b8                	ld	a4,112(s1)
    80002264:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80002268:	78b8                	ld	a4,112(s1)
    8000226a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    8000226c:	4641                	li	a2,16
    8000226e:	00006597          	auipc	a1,0x6
    80002272:	33258593          	addi	a1,a1,818 # 800085a0 <userret+0x510>
    80002276:	17048513          	addi	a0,s1,368
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	fb0080e7          	jalr	-80(ra) # 8000122a <safestrcpy>
  p->cmd = strdup("init");
    80002282:	00006517          	auipc	a0,0x6
    80002286:	32e50513          	addi	a0,a0,814 # 800085b0 <userret+0x520>
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	09a080e7          	jalr	154(ra) # 80001324 <strdup>
    80002292:	18a4b023          	sd	a0,384(s1)
  p->cwd = namei("/");
    80002296:	00006517          	auipc	a0,0x6
    8000229a:	32250513          	addi	a0,a0,802 # 800085b8 <userret+0x528>
    8000229e:	00002097          	auipc	ra,0x2
    800022a2:	332080e7          	jalr	818(ra) # 800045d0 <namei>
    800022a6:	16a4b423          	sd	a0,360(s1)
  p->state = RUNNABLE;
    800022aa:	4789                	li	a5,2
    800022ac:	d89c                	sw	a5,48(s1)
  acquire(&prio_lock);
    800022ae:	00013917          	auipc	s2,0x13
    800022b2:	78a90913          	addi	s2,s2,1930 # 80015a38 <prio_lock>
    800022b6:	854a                	mv	a0,s2
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	9d0080e7          	jalr	-1584(ra) # 80000c88 <acquire>
  insert_into_prio_queue(p);
    800022c0:	8526                	mv	a0,s1
    800022c2:	00000097          	auipc	ra,0x0
    800022c6:	aec080e7          	jalr	-1300(ra) # 80001dae <insert_into_prio_queue>
  release(&p->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	c08080e7          	jalr	-1016(ra) # 80000ed4 <release>
  release(&prio_lock);
    800022d4:	854a                	mv	a0,s2
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	bfe080e7          	jalr	-1026(ra) # 80000ed4 <release>
}
    800022de:	60e2                	ld	ra,24(sp)
    800022e0:	6442                	ld	s0,16(sp)
    800022e2:	64a2                	ld	s1,8(sp)
    800022e4:	6902                	ld	s2,0(sp)
    800022e6:	6105                	addi	sp,sp,32
    800022e8:	8082                	ret

00000000800022ea <growproc>:
{
    800022ea:	1101                	addi	sp,sp,-32
    800022ec:	ec06                	sd	ra,24(sp)
    800022ee:	e822                	sd	s0,16(sp)
    800022f0:	e426                	sd	s1,8(sp)
    800022f2:	e04a                	sd	s2,0(sp)
    800022f4:	1000                	addi	s0,sp,32
    800022f6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800022f8:	00000097          	auipc	ra,0x0
    800022fc:	ca4080e7          	jalr	-860(ra) # 80001f9c <myproc>
    80002300:	892a                	mv	s2,a0
  sz = p->sz;
    80002302:	712c                	ld	a1,96(a0)
    80002304:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002308:	00904f63          	bgtz	s1,80002326 <growproc+0x3c>
  } else if(n < 0){
    8000230c:	0204cc63          	bltz	s1,80002344 <growproc+0x5a>
  p->sz = sz;
    80002310:	1602                	slli	a2,a2,0x20
    80002312:	9201                	srli	a2,a2,0x20
    80002314:	06c93023          	sd	a2,96(s2)
  return 0;
    80002318:	4501                	li	a0,0
}
    8000231a:	60e2                	ld	ra,24(sp)
    8000231c:	6442                	ld	s0,16(sp)
    8000231e:	64a2                	ld	s1,8(sp)
    80002320:	6902                	ld	s2,0(sp)
    80002322:	6105                	addi	sp,sp,32
    80002324:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002326:	9e25                	addw	a2,a2,s1
    80002328:	1602                	slli	a2,a2,0x20
    8000232a:	9201                	srli	a2,a2,0x20
    8000232c:	1582                	slli	a1,a1,0x20
    8000232e:	9181                	srli	a1,a1,0x20
    80002330:	7528                	ld	a0,104(a0)
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	692080e7          	jalr	1682(ra) # 800019c4 <uvmalloc>
    8000233a:	0005061b          	sext.w	a2,a0
    8000233e:	fa69                	bnez	a2,80002310 <growproc+0x26>
      return -1;
    80002340:	557d                	li	a0,-1
    80002342:	bfe1                	j	8000231a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002344:	9e25                	addw	a2,a2,s1
    80002346:	1602                	slli	a2,a2,0x20
    80002348:	9201                	srli	a2,a2,0x20
    8000234a:	1582                	slli	a1,a1,0x20
    8000234c:	9181                	srli	a1,a1,0x20
    8000234e:	7528                	ld	a0,104(a0)
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	630080e7          	jalr	1584(ra) # 80001980 <uvmdealloc>
    80002358:	0005061b          	sext.w	a2,a0
    8000235c:	bf55                	j	80002310 <growproc+0x26>

000000008000235e <fork>:
{
    8000235e:	7179                	addi	sp,sp,-48
    80002360:	f406                	sd	ra,40(sp)
    80002362:	f022                	sd	s0,32(sp)
    80002364:	ec26                	sd	s1,24(sp)
    80002366:	e84a                	sd	s2,16(sp)
    80002368:	e44e                	sd	s3,8(sp)
    8000236a:	e052                	sd	s4,0(sp)
    8000236c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000236e:	00000097          	auipc	ra,0x0
    80002372:	c2e080e7          	jalr	-978(ra) # 80001f9c <myproc>
    80002376:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80002378:	00000097          	auipc	ra,0x0
    8000237c:	d44080e7          	jalr	-700(ra) # 800020bc <allocproc>
    80002380:	10050e63          	beqz	a0,8000249c <fork+0x13e>
    80002384:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002386:	06093603          	ld	a2,96(s2)
    8000238a:	752c                	ld	a1,104(a0)
    8000238c:	06893503          	ld	a0,104(s2)
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	70c080e7          	jalr	1804(ra) # 80001a9c <uvmcopy>
    80002398:	04054863          	bltz	a0,800023e8 <fork+0x8a>
  np->sz = p->sz;
    8000239c:	06093783          	ld	a5,96(s2)
    800023a0:	06f9b023          	sd	a5,96(s3) # 4000060 <_entry-0x7bffffa0>
  np->parent = p;
    800023a4:	0329bc23          	sd	s2,56(s3)
  *(np->tf) = *(p->tf);
    800023a8:	07093683          	ld	a3,112(s2)
    800023ac:	87b6                	mv	a5,a3
    800023ae:	0709b703          	ld	a4,112(s3)
    800023b2:	12068693          	addi	a3,a3,288
    800023b6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800023ba:	6788                	ld	a0,8(a5)
    800023bc:	6b8c                	ld	a1,16(a5)
    800023be:	6f90                	ld	a2,24(a5)
    800023c0:	01073023          	sd	a6,0(a4)
    800023c4:	e708                	sd	a0,8(a4)
    800023c6:	eb0c                	sd	a1,16(a4)
    800023c8:	ef10                	sd	a2,24(a4)
    800023ca:	02078793          	addi	a5,a5,32
    800023ce:	02070713          	addi	a4,a4,32
    800023d2:	fed792e3          	bne	a5,a3,800023b6 <fork+0x58>
  np->tf->a0 = 0;
    800023d6:	0709b783          	ld	a5,112(s3)
    800023da:	0607b823          	sd	zero,112(a5)
    800023de:	0e800493          	li	s1,232
  for(i = 0; i < NOFILE; i++)
    800023e2:	16800a13          	li	s4,360
    800023e6:	a03d                	j	80002414 <fork+0xb6>
    freeproc(np);
    800023e8:	854e                	mv	a0,s3
    800023ea:	00000097          	auipc	ra,0x0
    800023ee:	dd2080e7          	jalr	-558(ra) # 800021bc <freeproc>
    release(&np->lock);
    800023f2:	854e                	mv	a0,s3
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	ae0080e7          	jalr	-1312(ra) # 80000ed4 <release>
    return -1;
    800023fc:	597d                	li	s2,-1
    800023fe:	a071                	j	8000248a <fork+0x12c>
      np->ofile[i] = filedup(p->ofile[i]);
    80002400:	00003097          	auipc	ra,0x3
    80002404:	94e080e7          	jalr	-1714(ra) # 80004d4e <filedup>
    80002408:	009987b3          	add	a5,s3,s1
    8000240c:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000240e:	04a1                	addi	s1,s1,8
    80002410:	01448763          	beq	s1,s4,8000241e <fork+0xc0>
    if(p->ofile[i])
    80002414:	009907b3          	add	a5,s2,s1
    80002418:	6388                	ld	a0,0(a5)
    8000241a:	f17d                	bnez	a0,80002400 <fork+0xa2>
    8000241c:	bfcd                	j	8000240e <fork+0xb0>
  np->cwd = idup(p->cwd);
    8000241e:	16893503          	ld	a0,360(s2)
    80002422:	00002097          	auipc	ra,0x2
    80002426:	9e6080e7          	jalr	-1562(ra) # 80003e08 <idup>
    8000242a:	16a9b423          	sd	a0,360(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000242e:	4641                	li	a2,16
    80002430:	17090593          	addi	a1,s2,368
    80002434:	17098513          	addi	a0,s3,368
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	df2080e7          	jalr	-526(ra) # 8000122a <safestrcpy>
  np->cmd = strdup(p->cmd);
    80002440:	18093503          	ld	a0,384(s2)
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	ee0080e7          	jalr	-288(ra) # 80001324 <strdup>
    8000244c:	18a9b023          	sd	a0,384(s3)
  pid = np->pid;
    80002450:	0509a903          	lw	s2,80(s3)
  np->state = RUNNABLE;
    80002454:	4789                	li	a5,2
    80002456:	02f9a823          	sw	a5,48(s3)
  acquire(&prio_lock);
    8000245a:	00013497          	auipc	s1,0x13
    8000245e:	5de48493          	addi	s1,s1,1502 # 80015a38 <prio_lock>
    80002462:	8526                	mv	a0,s1
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	824080e7          	jalr	-2012(ra) # 80000c88 <acquire>
  insert_into_prio_queue(np);
    8000246c:	854e                	mv	a0,s3
    8000246e:	00000097          	auipc	ra,0x0
    80002472:	940080e7          	jalr	-1728(ra) # 80001dae <insert_into_prio_queue>
  release(&prio_lock);
    80002476:	8526                	mv	a0,s1
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	a5c080e7          	jalr	-1444(ra) # 80000ed4 <release>
  release(&np->lock);
    80002480:	854e                	mv	a0,s3
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	a52080e7          	jalr	-1454(ra) # 80000ed4 <release>
}
    8000248a:	854a                	mv	a0,s2
    8000248c:	70a2                	ld	ra,40(sp)
    8000248e:	7402                	ld	s0,32(sp)
    80002490:	64e2                	ld	s1,24(sp)
    80002492:	6942                	ld	s2,16(sp)
    80002494:	69a2                	ld	s3,8(sp)
    80002496:	6a02                	ld	s4,0(sp)
    80002498:	6145                	addi	sp,sp,48
    8000249a:	8082                	ret
    return -1;
    8000249c:	597d                	li	s2,-1
    8000249e:	b7f5                	j	8000248a <fork+0x12c>

00000000800024a0 <reparent>:
{
    800024a0:	7179                	addi	sp,sp,-48
    800024a2:	f406                	sd	ra,40(sp)
    800024a4:	f022                	sd	s0,32(sp)
    800024a6:	ec26                	sd	s1,24(sp)
    800024a8:	e84a                	sd	s2,16(sp)
    800024aa:	e44e                	sd	s3,8(sp)
    800024ac:	e052                	sd	s4,0(sp)
    800024ae:	1800                	addi	s0,sp,48
    800024b0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b2:	00014497          	auipc	s1,0x14
    800024b6:	9e648493          	addi	s1,s1,-1562 # 80015e98 <proc>
      pp->parent = initproc;
    800024ba:	0002ca17          	auipc	s4,0x2c
    800024be:	bc6a0a13          	addi	s4,s4,-1082 # 8002e080 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024c2:	0001a997          	auipc	s3,0x1a
    800024c6:	bd698993          	addi	s3,s3,-1066 # 8001c098 <tickslock>
    800024ca:	a029                	j	800024d4 <reparent+0x34>
    800024cc:	18848493          	addi	s1,s1,392
    800024d0:	03348363          	beq	s1,s3,800024f6 <reparent+0x56>
    if(pp->parent == p){
    800024d4:	7c9c                	ld	a5,56(s1)
    800024d6:	ff279be3          	bne	a5,s2,800024cc <reparent+0x2c>
      acquire(&pp->lock);
    800024da:	8526                	mv	a0,s1
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	7ac080e7          	jalr	1964(ra) # 80000c88 <acquire>
      pp->parent = initproc;
    800024e4:	000a3783          	ld	a5,0(s4)
    800024e8:	fc9c                	sd	a5,56(s1)
      release(&pp->lock);
    800024ea:	8526                	mv	a0,s1
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	9e8080e7          	jalr	-1560(ra) # 80000ed4 <release>
    800024f4:	bfe1                	j	800024cc <reparent+0x2c>
}
    800024f6:	70a2                	ld	ra,40(sp)
    800024f8:	7402                	ld	s0,32(sp)
    800024fa:	64e2                	ld	s1,24(sp)
    800024fc:	6942                	ld	s2,16(sp)
    800024fe:	69a2                	ld	s3,8(sp)
    80002500:	6a02                	ld	s4,0(sp)
    80002502:	6145                	addi	sp,sp,48
    80002504:	8082                	ret

0000000080002506 <pick_highest_priority_runnable_proc>:
proc* pick_highest_priority_runnable_proc() {
    80002506:	1101                	addi	sp,sp,-32
    80002508:	ec06                	sd	ra,24(sp)
    8000250a:	e822                	sd	s0,16(sp)
    8000250c:	e426                	sd	s1,8(sp)
    8000250e:	1000                	addi	s0,sp,32
  acquire(&prio_lock);
    80002510:	00013497          	auipc	s1,0x13
    80002514:	52848493          	addi	s1,s1,1320 # 80015a38 <prio_lock>
    80002518:	8526                	mv	a0,s1
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	76e080e7          	jalr	1902(ra) # 80000c88 <acquire>
  for (int i = 0; i<NPRIO; i++) {
    80002522:	00013697          	auipc	a3,0x13
    80002526:	4c668693          	addi	a3,a3,1222 # 800159e8 <prio>
    8000252a:	8626                	mv	a2,s1
      if (p_liste_actuelle->p->state == RUNNABLE) {
    8000252c:	4709                	li	a4,2
    struct list_proc* p_liste_actuelle = prio[i];
    8000252e:	6284                	ld	s1,0(a3)
    while (p_liste_actuelle) {
    80002530:	c499                	beqz	s1,8000253e <pick_highest_priority_runnable_proc+0x38>
      if (p_liste_actuelle->p->state == RUNNABLE) {
    80002532:	6088                	ld	a0,0(s1)
    80002534:	591c                	lw	a5,48(a0)
    80002536:	02e78163          	beq	a5,a4,80002558 <pick_highest_priority_runnable_proc+0x52>
      p_liste_actuelle = p_liste_actuelle->next;
    8000253a:	6484                	ld	s1,8(s1)
    while (p_liste_actuelle) {
    8000253c:	f8fd                	bnez	s1,80002532 <pick_highest_priority_runnable_proc+0x2c>
  for (int i = 0; i<NPRIO; i++) {
    8000253e:	06a1                	addi	a3,a3,8
    80002540:	fec697e3          	bne	a3,a2,8000252e <pick_highest_priority_runnable_proc+0x28>
  release(&prio_lock);
    80002544:	00013517          	auipc	a0,0x13
    80002548:	4f450513          	addi	a0,a0,1268 # 80015a38 <prio_lock>
    8000254c:	fffff097          	auipc	ra,0xfffff
    80002550:	988080e7          	jalr	-1656(ra) # 80000ed4 <release>
  return 0;
    80002554:	4501                	li	a0,0
    80002556:	a031                	j	80002562 <pick_highest_priority_runnable_proc+0x5c>
        acquire(&p_liste_actuelle->p->lock);
    80002558:	ffffe097          	auipc	ra,0xffffe
    8000255c:	730080e7          	jalr	1840(ra) # 80000c88 <acquire>
        return p_liste_actuelle->p;
    80002560:	6088                	ld	a0,0(s1)
}
    80002562:	60e2                	ld	ra,24(sp)
    80002564:	6442                	ld	s0,16(sp)
    80002566:	64a2                	ld	s1,8(sp)
    80002568:	6105                	addi	sp,sp,32
    8000256a:	8082                	ret

000000008000256c <scheduler>:
{
    8000256c:	7139                	addi	sp,sp,-64
    8000256e:	fc06                	sd	ra,56(sp)
    80002570:	f822                	sd	s0,48(sp)
    80002572:	f426                	sd	s1,40(sp)
    80002574:	f04a                	sd	s2,32(sp)
    80002576:	ec4e                	sd	s3,24(sp)
    80002578:	e852                	sd	s4,16(sp)
    8000257a:	e456                	sd	s5,8(sp)
    8000257c:	0080                	addi	s0,sp,64
    8000257e:	8792                	mv	a5,tp
  int id = r_tp();
    80002580:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002582:	00779993          	slli	s3,a5,0x7
    80002586:	00013717          	auipc	a4,0x13
    8000258a:	46270713          	addi	a4,a4,1122 # 800159e8 <prio>
    8000258e:	974e                	add	a4,a4,s3
    80002590:	0a073823          	sd	zero,176(a4)
      swtch(&c->scheduler, &p->context);
    80002594:	00013717          	auipc	a4,0x13
    80002598:	50c70713          	addi	a4,a4,1292 # 80015aa0 <cpus+0x8>
    8000259c:	99ba                	add	s3,s3,a4
      p->state = RUNNING;
    8000259e:	4a8d                	li	s5,3
      c->proc = p;
    800025a0:	079e                	slli	a5,a5,0x7
    800025a2:	00013917          	auipc	s2,0x13
    800025a6:	44690913          	addi	s2,s2,1094 # 800159e8 <prio>
    800025aa:	993e                	add	s2,s2,a5
      release(&prio_lock);
    800025ac:	00013a17          	auipc	s4,0x13
    800025b0:	48ca0a13          	addi	s4,s4,1164 # 80015a38 <prio_lock>
    800025b4:	a019                	j	800025ba <scheduler+0x4e>
      asm volatile("wfi");
    800025b6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025ba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025be:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025c2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025c6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800025ca:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025cc:	10079073          	csrw	sstatus,a5
    struct proc* p = pick_highest_priority_runnable_proc();
    800025d0:	00000097          	auipc	ra,0x0
    800025d4:	f36080e7          	jalr	-202(ra) # 80002506 <pick_highest_priority_runnable_proc>
    800025d8:	84aa                	mv	s1,a0
    if (p) {
    800025da:	dd71                	beqz	a0,800025b6 <scheduler+0x4a>
      p->state = RUNNING;
    800025dc:	03552823          	sw	s5,48(a0)
      c->proc = p;
    800025e0:	0aa93823          	sd	a0,176(s2)
      remove_from_prio_queue(p);
    800025e4:	00000097          	auipc	ra,0x0
    800025e8:	81c080e7          	jalr	-2020(ra) # 80001e00 <remove_from_prio_queue>
      insert_into_prio_queue(p);
    800025ec:	8526                	mv	a0,s1
    800025ee:	fffff097          	auipc	ra,0xfffff
    800025f2:	7c0080e7          	jalr	1984(ra) # 80001dae <insert_into_prio_queue>
      release(&prio_lock);
    800025f6:	8552                	mv	a0,s4
    800025f8:	fffff097          	auipc	ra,0xfffff
    800025fc:	8dc080e7          	jalr	-1828(ra) # 80000ed4 <release>
      swtch(&c->scheduler, &p->context);
    80002600:	07848593          	addi	a1,s1,120
    80002604:	854e                	mv	a0,s3
    80002606:	00000097          	auipc	ra,0x0
    8000260a:	6ca080e7          	jalr	1738(ra) # 80002cd0 <swtch>
       c->proc = 0;
    8000260e:	0a093823          	sd	zero,176(s2)
      c->intena = 0;
    80002612:	12092623          	sw	zero,300(s2)
      release(&p->lock);
    80002616:	8526                	mv	a0,s1
    80002618:	fffff097          	auipc	ra,0xfffff
    8000261c:	8bc080e7          	jalr	-1860(ra) # 80000ed4 <release>
    80002620:	bf69                	j	800025ba <scheduler+0x4e>

0000000080002622 <sched>:
{
    80002622:	7179                	addi	sp,sp,-48
    80002624:	f406                	sd	ra,40(sp)
    80002626:	f022                	sd	s0,32(sp)
    80002628:	ec26                	sd	s1,24(sp)
    8000262a:	e84a                	sd	s2,16(sp)
    8000262c:	e44e                	sd	s3,8(sp)
    8000262e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002630:	00000097          	auipc	ra,0x0
    80002634:	96c080e7          	jalr	-1684(ra) # 80001f9c <myproc>
    80002638:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	5d0080e7          	jalr	1488(ra) # 80000c0a <holding>
    80002642:	c93d                	beqz	a0,800026b8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002644:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002646:	2781                	sext.w	a5,a5
    80002648:	079e                	slli	a5,a5,0x7
    8000264a:	00013717          	auipc	a4,0x13
    8000264e:	39e70713          	addi	a4,a4,926 # 800159e8 <prio>
    80002652:	97ba                	add	a5,a5,a4
    80002654:	1287a703          	lw	a4,296(a5)
    80002658:	4785                	li	a5,1
    8000265a:	06f71763          	bne	a4,a5,800026c8 <sched+0xa6>
  if(p->state == RUNNING)
    8000265e:	5898                	lw	a4,48(s1)
    80002660:	478d                	li	a5,3
    80002662:	06f70b63          	beq	a4,a5,800026d8 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002666:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000266a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000266c:	efb5                	bnez	a5,800026e8 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000266e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002670:	00013917          	auipc	s2,0x13
    80002674:	37890913          	addi	s2,s2,888 # 800159e8 <prio>
    80002678:	2781                	sext.w	a5,a5
    8000267a:	079e                	slli	a5,a5,0x7
    8000267c:	97ca                	add	a5,a5,s2
    8000267e:	12c7a983          	lw	s3,300(a5)
    80002682:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80002684:	2781                	sext.w	a5,a5
    80002686:	079e                	slli	a5,a5,0x7
    80002688:	00013597          	auipc	a1,0x13
    8000268c:	41858593          	addi	a1,a1,1048 # 80015aa0 <cpus+0x8>
    80002690:	95be                	add	a1,a1,a5
    80002692:	07848513          	addi	a0,s1,120
    80002696:	00000097          	auipc	ra,0x0
    8000269a:	63a080e7          	jalr	1594(ra) # 80002cd0 <swtch>
    8000269e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800026a0:	2781                	sext.w	a5,a5
    800026a2:	079e                	slli	a5,a5,0x7
    800026a4:	97ca                	add	a5,a5,s2
    800026a6:	1337a623          	sw	s3,300(a5)
}
    800026aa:	70a2                	ld	ra,40(sp)
    800026ac:	7402                	ld	s0,32(sp)
    800026ae:	64e2                	ld	s1,24(sp)
    800026b0:	6942                	ld	s2,16(sp)
    800026b2:	69a2                	ld	s3,8(sp)
    800026b4:	6145                	addi	sp,sp,48
    800026b6:	8082                	ret
    panic("sched p->lock");
    800026b8:	00006517          	auipc	a0,0x6
    800026bc:	f0850513          	addi	a0,a0,-248 # 800085c0 <userret+0x530>
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	096080e7          	jalr	150(ra) # 80000756 <panic>
    panic("sched locks");
    800026c8:	00006517          	auipc	a0,0x6
    800026cc:	f0850513          	addi	a0,a0,-248 # 800085d0 <userret+0x540>
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	086080e7          	jalr	134(ra) # 80000756 <panic>
    panic("sched running");
    800026d8:	00006517          	auipc	a0,0x6
    800026dc:	f0850513          	addi	a0,a0,-248 # 800085e0 <userret+0x550>
    800026e0:	ffffe097          	auipc	ra,0xffffe
    800026e4:	076080e7          	jalr	118(ra) # 80000756 <panic>
    panic("sched interruptible");
    800026e8:	00006517          	auipc	a0,0x6
    800026ec:	f0850513          	addi	a0,a0,-248 # 800085f0 <userret+0x560>
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	066080e7          	jalr	102(ra) # 80000756 <panic>

00000000800026f8 <exit>:
{
    800026f8:	7179                	addi	sp,sp,-48
    800026fa:	f406                	sd	ra,40(sp)
    800026fc:	f022                	sd	s0,32(sp)
    800026fe:	ec26                	sd	s1,24(sp)
    80002700:	e84a                	sd	s2,16(sp)
    80002702:	e44e                	sd	s3,8(sp)
    80002704:	e052                	sd	s4,0(sp)
    80002706:	1800                	addi	s0,sp,48
    80002708:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000270a:	00000097          	auipc	ra,0x0
    8000270e:	892080e7          	jalr	-1902(ra) # 80001f9c <myproc>
    80002712:	892a                	mv	s2,a0
  if(p == initproc)
    80002714:	0002c797          	auipc	a5,0x2c
    80002718:	96c7b783          	ld	a5,-1684(a5) # 8002e080 <initproc>
    8000271c:	0e850493          	addi	s1,a0,232
    80002720:	16850993          	addi	s3,a0,360
    80002724:	02a79363          	bne	a5,a0,8000274a <exit+0x52>
    panic("init exiting");
    80002728:	00006517          	auipc	a0,0x6
    8000272c:	ee050513          	addi	a0,a0,-288 # 80008608 <userret+0x578>
    80002730:	ffffe097          	auipc	ra,0xffffe
    80002734:	026080e7          	jalr	38(ra) # 80000756 <panic>
      fileclose(f);
    80002738:	00002097          	auipc	ra,0x2
    8000273c:	668080e7          	jalr	1640(ra) # 80004da0 <fileclose>
      p->ofile[fd] = 0;
    80002740:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002744:	04a1                	addi	s1,s1,8
    80002746:	01348563          	beq	s1,s3,80002750 <exit+0x58>
    if(p->ofile[fd]){
    8000274a:	6088                	ld	a0,0(s1)
    8000274c:	f575                	bnez	a0,80002738 <exit+0x40>
    8000274e:	bfdd                	j	80002744 <exit+0x4c>
  begin_op(ROOTDEV);
    80002750:	4501                	li	a0,0
    80002752:	00002097          	auipc	ra,0x2
    80002756:	0c4080e7          	jalr	196(ra) # 80004816 <begin_op>
  iput(p->cwd);
    8000275a:	16893503          	ld	a0,360(s2)
    8000275e:	00001097          	auipc	ra,0x1
    80002762:	7f6080e7          	jalr	2038(ra) # 80003f54 <iput>
  end_op(ROOTDEV);
    80002766:	4501                	li	a0,0
    80002768:	00002097          	auipc	ra,0x2
    8000276c:	15a080e7          	jalr	346(ra) # 800048c2 <end_op>
  p->cwd = 0;
    80002770:	16093423          	sd	zero,360(s2)
  acquire(&initproc->lock);
    80002774:	0002c497          	auipc	s1,0x2c
    80002778:	90c48493          	addi	s1,s1,-1780 # 8002e080 <initproc>
    8000277c:	6088                	ld	a0,0(s1)
    8000277e:	ffffe097          	auipc	ra,0xffffe
    80002782:	50a080e7          	jalr	1290(ra) # 80000c88 <acquire>
  wakeup1(initproc);
    80002786:	6088                	ld	a0,0(s1)
    80002788:	fffff097          	auipc	ra,0xfffff
    8000278c:	5e2080e7          	jalr	1506(ra) # 80001d6a <wakeup1>
  release(&initproc->lock);
    80002790:	6088                	ld	a0,0(s1)
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	742080e7          	jalr	1858(ra) # 80000ed4 <release>
  acquire(&prio_lock);
    8000279a:	00013497          	auipc	s1,0x13
    8000279e:	29e48493          	addi	s1,s1,670 # 80015a38 <prio_lock>
    800027a2:	8526                	mv	a0,s1
    800027a4:	ffffe097          	auipc	ra,0xffffe
    800027a8:	4e4080e7          	jalr	1252(ra) # 80000c88 <acquire>
  acquire(&p->lock);
    800027ac:	854a                	mv	a0,s2
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	4da080e7          	jalr	1242(ra) # 80000c88 <acquire>
  remove_from_prio_queue(p);
    800027b6:	854a                	mv	a0,s2
    800027b8:	fffff097          	auipc	ra,0xfffff
    800027bc:	648080e7          	jalr	1608(ra) # 80001e00 <remove_from_prio_queue>
  release(&p->lock);
    800027c0:	854a                	mv	a0,s2
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	712080e7          	jalr	1810(ra) # 80000ed4 <release>
  release(&prio_lock);
    800027ca:	8526                	mv	a0,s1
    800027cc:	ffffe097          	auipc	ra,0xffffe
    800027d0:	708080e7          	jalr	1800(ra) # 80000ed4 <release>
  acquire(&p->lock);
    800027d4:	854a                	mv	a0,s2
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	4b2080e7          	jalr	1202(ra) # 80000c88 <acquire>
  struct proc *original_parent = p->parent;
    800027de:	03893483          	ld	s1,56(s2)
  release(&p->lock);
    800027e2:	854a                	mv	a0,s2
    800027e4:	ffffe097          	auipc	ra,0xffffe
    800027e8:	6f0080e7          	jalr	1776(ra) # 80000ed4 <release>
  acquire(&original_parent->lock);
    800027ec:	8526                	mv	a0,s1
    800027ee:	ffffe097          	auipc	ra,0xffffe
    800027f2:	49a080e7          	jalr	1178(ra) # 80000c88 <acquire>
  acquire(&p->lock);
    800027f6:	854a                	mv	a0,s2
    800027f8:	ffffe097          	auipc	ra,0xffffe
    800027fc:	490080e7          	jalr	1168(ra) # 80000c88 <acquire>
  reparent(p);
    80002800:	854a                	mv	a0,s2
    80002802:	00000097          	auipc	ra,0x0
    80002806:	c9e080e7          	jalr	-866(ra) # 800024a0 <reparent>
  wakeup1(original_parent);
    8000280a:	8526                	mv	a0,s1
    8000280c:	fffff097          	auipc	ra,0xfffff
    80002810:	55e080e7          	jalr	1374(ra) # 80001d6a <wakeup1>
  p->xstate = status;
    80002814:	05492623          	sw	s4,76(s2)
  p->state = ZOMBIE;
    80002818:	4791                	li	a5,4
    8000281a:	02f92823          	sw	a5,48(s2)
  release(&original_parent->lock);
    8000281e:	8526                	mv	a0,s1
    80002820:	ffffe097          	auipc	ra,0xffffe
    80002824:	6b4080e7          	jalr	1716(ra) # 80000ed4 <release>
  sched();
    80002828:	00000097          	auipc	ra,0x0
    8000282c:	dfa080e7          	jalr	-518(ra) # 80002622 <sched>
  panic("zombie exit");
    80002830:	00006517          	auipc	a0,0x6
    80002834:	de850513          	addi	a0,a0,-536 # 80008618 <userret+0x588>
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	f1e080e7          	jalr	-226(ra) # 80000756 <panic>

0000000080002840 <yield>:
{
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	e426                	sd	s1,8(sp)
    80002848:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000284a:	fffff097          	auipc	ra,0xfffff
    8000284e:	752080e7          	jalr	1874(ra) # 80001f9c <myproc>
    80002852:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	434080e7          	jalr	1076(ra) # 80000c88 <acquire>
  p->state = RUNNABLE;
    8000285c:	4789                	li	a5,2
    8000285e:	d89c                	sw	a5,48(s1)
  sched();
    80002860:	00000097          	auipc	ra,0x0
    80002864:	dc2080e7          	jalr	-574(ra) # 80002622 <sched>
  release(&p->lock);
    80002868:	8526                	mv	a0,s1
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	66a080e7          	jalr	1642(ra) # 80000ed4 <release>
}
    80002872:	60e2                	ld	ra,24(sp)
    80002874:	6442                	ld	s0,16(sp)
    80002876:	64a2                	ld	s1,8(sp)
    80002878:	6105                	addi	sp,sp,32
    8000287a:	8082                	ret

000000008000287c <sleep>:
{
    8000287c:	7179                	addi	sp,sp,-48
    8000287e:	f406                	sd	ra,40(sp)
    80002880:	f022                	sd	s0,32(sp)
    80002882:	ec26                	sd	s1,24(sp)
    80002884:	e84a                	sd	s2,16(sp)
    80002886:	e44e                	sd	s3,8(sp)
    80002888:	1800                	addi	s0,sp,48
    8000288a:	89aa                	mv	s3,a0
    8000288c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000288e:	fffff097          	auipc	ra,0xfffff
    80002892:	70e080e7          	jalr	1806(ra) # 80001f9c <myproc>
    80002896:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002898:	05250663          	beq	a0,s2,800028e4 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000289c:	ffffe097          	auipc	ra,0xffffe
    800028a0:	3ec080e7          	jalr	1004(ra) # 80000c88 <acquire>
    release(lk);
    800028a4:	854a                	mv	a0,s2
    800028a6:	ffffe097          	auipc	ra,0xffffe
    800028aa:	62e080e7          	jalr	1582(ra) # 80000ed4 <release>
  p->chan = chan;
    800028ae:	0534b023          	sd	s3,64(s1)
  p->state = SLEEPING;
    800028b2:	4785                	li	a5,1
    800028b4:	d89c                	sw	a5,48(s1)
  sched();
    800028b6:	00000097          	auipc	ra,0x0
    800028ba:	d6c080e7          	jalr	-660(ra) # 80002622 <sched>
  p->chan = 0;
    800028be:	0404b023          	sd	zero,64(s1)
    release(&p->lock);
    800028c2:	8526                	mv	a0,s1
    800028c4:	ffffe097          	auipc	ra,0xffffe
    800028c8:	610080e7          	jalr	1552(ra) # 80000ed4 <release>
    acquire(lk);
    800028cc:	854a                	mv	a0,s2
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	3ba080e7          	jalr	954(ra) # 80000c88 <acquire>
}
    800028d6:	70a2                	ld	ra,40(sp)
    800028d8:	7402                	ld	s0,32(sp)
    800028da:	64e2                	ld	s1,24(sp)
    800028dc:	6942                	ld	s2,16(sp)
    800028de:	69a2                	ld	s3,8(sp)
    800028e0:	6145                	addi	sp,sp,48
    800028e2:	8082                	ret
  p->chan = chan;
    800028e4:	05353023          	sd	s3,64(a0)
  p->state = SLEEPING;
    800028e8:	4785                	li	a5,1
    800028ea:	d91c                	sw	a5,48(a0)
  sched();
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	d36080e7          	jalr	-714(ra) # 80002622 <sched>
  p->chan = 0;
    800028f4:	0404b023          	sd	zero,64(s1)
  if(lk != &p->lock){
    800028f8:	bff9                	j	800028d6 <sleep+0x5a>

00000000800028fa <wait>:
{
    800028fa:	715d                	addi	sp,sp,-80
    800028fc:	e486                	sd	ra,72(sp)
    800028fe:	e0a2                	sd	s0,64(sp)
    80002900:	fc26                	sd	s1,56(sp)
    80002902:	f84a                	sd	s2,48(sp)
    80002904:	f44e                	sd	s3,40(sp)
    80002906:	f052                	sd	s4,32(sp)
    80002908:	ec56                	sd	s5,24(sp)
    8000290a:	e85a                	sd	s6,16(sp)
    8000290c:	e45e                	sd	s7,8(sp)
    8000290e:	e062                	sd	s8,0(sp)
    80002910:	0880                	addi	s0,sp,80
    80002912:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002914:	fffff097          	auipc	ra,0xfffff
    80002918:	688080e7          	jalr	1672(ra) # 80001f9c <myproc>
    8000291c:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000291e:	8c2a                	mv	s8,a0
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	368080e7          	jalr	872(ra) # 80000c88 <acquire>
    havekids = 0;
    80002928:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000292a:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000292c:	00019997          	auipc	s3,0x19
    80002930:	76c98993          	addi	s3,s3,1900 # 8001c098 <tickslock>
        havekids = 1;
    80002934:	4a85                	li	s5,1
    havekids = 0;
    80002936:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002938:	00013497          	auipc	s1,0x13
    8000293c:	56048493          	addi	s1,s1,1376 # 80015e98 <proc>
    80002940:	a08d                	j	800029a2 <wait+0xa8>
          pid = np->pid;
    80002942:	0504a983          	lw	s3,80(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002946:	000b0e63          	beqz	s6,80002962 <wait+0x68>
    8000294a:	4691                	li	a3,4
    8000294c:	04c48613          	addi	a2,s1,76
    80002950:	85da                	mv	a1,s6
    80002952:	06893503          	ld	a0,104(s2)
    80002956:	fffff097          	auipc	ra,0xfffff
    8000295a:	248080e7          	jalr	584(ra) # 80001b9e <copyout>
    8000295e:	02054263          	bltz	a0,80002982 <wait+0x88>
          freeproc(np);
    80002962:	8526                	mv	a0,s1
    80002964:	00000097          	auipc	ra,0x0
    80002968:	858080e7          	jalr	-1960(ra) # 800021bc <freeproc>
          release(&np->lock);
    8000296c:	8526                	mv	a0,s1
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	566080e7          	jalr	1382(ra) # 80000ed4 <release>
          release(&p->lock);
    80002976:	854a                	mv	a0,s2
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	55c080e7          	jalr	1372(ra) # 80000ed4 <release>
          return pid;
    80002980:	a8a9                	j	800029da <wait+0xe0>
            release(&np->lock);
    80002982:	8526                	mv	a0,s1
    80002984:	ffffe097          	auipc	ra,0xffffe
    80002988:	550080e7          	jalr	1360(ra) # 80000ed4 <release>
            release(&p->lock);
    8000298c:	854a                	mv	a0,s2
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	546080e7          	jalr	1350(ra) # 80000ed4 <release>
            return -1;
    80002996:	59fd                	li	s3,-1
    80002998:	a089                	j	800029da <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    8000299a:	18848493          	addi	s1,s1,392
    8000299e:	03348463          	beq	s1,s3,800029c6 <wait+0xcc>
      if(np->parent == p){
    800029a2:	7c9c                	ld	a5,56(s1)
    800029a4:	ff279be3          	bne	a5,s2,8000299a <wait+0xa0>
        acquire(&np->lock);
    800029a8:	8526                	mv	a0,s1
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	2de080e7          	jalr	734(ra) # 80000c88 <acquire>
        if(np->state == ZOMBIE){
    800029b2:	589c                	lw	a5,48(s1)
    800029b4:	f94787e3          	beq	a5,s4,80002942 <wait+0x48>
        release(&np->lock);
    800029b8:	8526                	mv	a0,s1
    800029ba:	ffffe097          	auipc	ra,0xffffe
    800029be:	51a080e7          	jalr	1306(ra) # 80000ed4 <release>
        havekids = 1;
    800029c2:	8756                	mv	a4,s5
    800029c4:	bfd9                	j	8000299a <wait+0xa0>
    if(!havekids || p->killed){
    800029c6:	c701                	beqz	a4,800029ce <wait+0xd4>
    800029c8:	04892783          	lw	a5,72(s2)
    800029cc:	c785                	beqz	a5,800029f4 <wait+0xfa>
      release(&p->lock);
    800029ce:	854a                	mv	a0,s2
    800029d0:	ffffe097          	auipc	ra,0xffffe
    800029d4:	504080e7          	jalr	1284(ra) # 80000ed4 <release>
      return -1;
    800029d8:	59fd                	li	s3,-1
}
    800029da:	854e                	mv	a0,s3
    800029dc:	60a6                	ld	ra,72(sp)
    800029de:	6406                	ld	s0,64(sp)
    800029e0:	74e2                	ld	s1,56(sp)
    800029e2:	7942                	ld	s2,48(sp)
    800029e4:	79a2                	ld	s3,40(sp)
    800029e6:	7a02                	ld	s4,32(sp)
    800029e8:	6ae2                	ld	s5,24(sp)
    800029ea:	6b42                	ld	s6,16(sp)
    800029ec:	6ba2                	ld	s7,8(sp)
    800029ee:	6c02                	ld	s8,0(sp)
    800029f0:	6161                	addi	sp,sp,80
    800029f2:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800029f4:	85e2                	mv	a1,s8
    800029f6:	854a                	mv	a0,s2
    800029f8:	00000097          	auipc	ra,0x0
    800029fc:	e84080e7          	jalr	-380(ra) # 8000287c <sleep>
    havekids = 0;
    80002a00:	bf1d                	j	80002936 <wait+0x3c>

0000000080002a02 <wakeup>:
{
    80002a02:	7139                	addi	sp,sp,-64
    80002a04:	fc06                	sd	ra,56(sp)
    80002a06:	f822                	sd	s0,48(sp)
    80002a08:	f426                	sd	s1,40(sp)
    80002a0a:	f04a                	sd	s2,32(sp)
    80002a0c:	ec4e                	sd	s3,24(sp)
    80002a0e:	e852                	sd	s4,16(sp)
    80002a10:	e456                	sd	s5,8(sp)
    80002a12:	0080                	addi	s0,sp,64
    80002a14:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002a16:	00013497          	auipc	s1,0x13
    80002a1a:	48248493          	addi	s1,s1,1154 # 80015e98 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002a1e:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002a20:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002a22:	00019917          	auipc	s2,0x19
    80002a26:	67690913          	addi	s2,s2,1654 # 8001c098 <tickslock>
    80002a2a:	a821                	j	80002a42 <wakeup+0x40>
      p->state = RUNNABLE;
    80002a2c:	0354a823          	sw	s5,48(s1)
    release(&p->lock);
    80002a30:	8526                	mv	a0,s1
    80002a32:	ffffe097          	auipc	ra,0xffffe
    80002a36:	4a2080e7          	jalr	1186(ra) # 80000ed4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002a3a:	18848493          	addi	s1,s1,392
    80002a3e:	01248e63          	beq	s1,s2,80002a5a <wakeup+0x58>
    acquire(&p->lock);
    80002a42:	8526                	mv	a0,s1
    80002a44:	ffffe097          	auipc	ra,0xffffe
    80002a48:	244080e7          	jalr	580(ra) # 80000c88 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002a4c:	589c                	lw	a5,48(s1)
    80002a4e:	ff3791e3          	bne	a5,s3,80002a30 <wakeup+0x2e>
    80002a52:	60bc                	ld	a5,64(s1)
    80002a54:	fd479ee3          	bne	a5,s4,80002a30 <wakeup+0x2e>
    80002a58:	bfd1                	j	80002a2c <wakeup+0x2a>
}
    80002a5a:	70e2                	ld	ra,56(sp)
    80002a5c:	7442                	ld	s0,48(sp)
    80002a5e:	74a2                	ld	s1,40(sp)
    80002a60:	7902                	ld	s2,32(sp)
    80002a62:	69e2                	ld	s3,24(sp)
    80002a64:	6a42                	ld	s4,16(sp)
    80002a66:	6aa2                	ld	s5,8(sp)
    80002a68:	6121                	addi	sp,sp,64
    80002a6a:	8082                	ret

0000000080002a6c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002a6c:	7179                	addi	sp,sp,-48
    80002a6e:	f406                	sd	ra,40(sp)
    80002a70:	f022                	sd	s0,32(sp)
    80002a72:	ec26                	sd	s1,24(sp)
    80002a74:	e84a                	sd	s2,16(sp)
    80002a76:	e44e                	sd	s3,8(sp)
    80002a78:	1800                	addi	s0,sp,48
    80002a7a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002a7c:	00013497          	auipc	s1,0x13
    80002a80:	41c48493          	addi	s1,s1,1052 # 80015e98 <proc>
    80002a84:	00019997          	auipc	s3,0x19
    80002a88:	61498993          	addi	s3,s3,1556 # 8001c098 <tickslock>
    acquire(&p->lock);
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	ffffe097          	auipc	ra,0xffffe
    80002a92:	1fa080e7          	jalr	506(ra) # 80000c88 <acquire>
    if(p->pid == pid){
    80002a96:	48bc                	lw	a5,80(s1)
    80002a98:	01278d63          	beq	a5,s2,80002ab2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002a9c:	8526                	mv	a0,s1
    80002a9e:	ffffe097          	auipc	ra,0xffffe
    80002aa2:	436080e7          	jalr	1078(ra) # 80000ed4 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002aa6:	18848493          	addi	s1,s1,392
    80002aaa:	ff3491e3          	bne	s1,s3,80002a8c <kill+0x20>
  }
  return -1;
    80002aae:	557d                	li	a0,-1
    80002ab0:	a829                	j	80002aca <kill+0x5e>
      p->killed = 1;
    80002ab2:	4785                	li	a5,1
    80002ab4:	c4bc                	sw	a5,72(s1)
      if(p->state == SLEEPING){
    80002ab6:	5898                	lw	a4,48(s1)
    80002ab8:	4785                	li	a5,1
    80002aba:	00f70f63          	beq	a4,a5,80002ad8 <kill+0x6c>
      release(&p->lock);
    80002abe:	8526                	mv	a0,s1
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	414080e7          	jalr	1044(ra) # 80000ed4 <release>
      return 0;
    80002ac8:	4501                	li	a0,0
}
    80002aca:	70a2                	ld	ra,40(sp)
    80002acc:	7402                	ld	s0,32(sp)
    80002ace:	64e2                	ld	s1,24(sp)
    80002ad0:	6942                	ld	s2,16(sp)
    80002ad2:	69a2                	ld	s3,8(sp)
    80002ad4:	6145                	addi	sp,sp,48
    80002ad6:	8082                	ret
        p->state = RUNNABLE;
    80002ad8:	4789                	li	a5,2
    80002ada:	d89c                	sw	a5,48(s1)
    80002adc:	b7cd                	j	80002abe <kill+0x52>

0000000080002ade <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002ade:	7179                	addi	sp,sp,-48
    80002ae0:	f406                	sd	ra,40(sp)
    80002ae2:	f022                	sd	s0,32(sp)
    80002ae4:	ec26                	sd	s1,24(sp)
    80002ae6:	e84a                	sd	s2,16(sp)
    80002ae8:	e44e                	sd	s3,8(sp)
    80002aea:	e052                	sd	s4,0(sp)
    80002aec:	1800                	addi	s0,sp,48
    80002aee:	84aa                	mv	s1,a0
    80002af0:	892e                	mv	s2,a1
    80002af2:	89b2                	mv	s3,a2
    80002af4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	4a6080e7          	jalr	1190(ra) # 80001f9c <myproc>
  if(user_dst){
    80002afe:	c08d                	beqz	s1,80002b20 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002b00:	86d2                	mv	a3,s4
    80002b02:	864e                	mv	a2,s3
    80002b04:	85ca                	mv	a1,s2
    80002b06:	7528                	ld	a0,104(a0)
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	096080e7          	jalr	150(ra) # 80001b9e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002b10:	70a2                	ld	ra,40(sp)
    80002b12:	7402                	ld	s0,32(sp)
    80002b14:	64e2                	ld	s1,24(sp)
    80002b16:	6942                	ld	s2,16(sp)
    80002b18:	69a2                	ld	s3,8(sp)
    80002b1a:	6a02                	ld	s4,0(sp)
    80002b1c:	6145                	addi	sp,sp,48
    80002b1e:	8082                	ret
    memmove((char *)dst, src, len);
    80002b20:	000a061b          	sext.w	a2,s4
    80002b24:	85ce                	mv	a1,s3
    80002b26:	854a                	mv	a0,s2
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	60c080e7          	jalr	1548(ra) # 80001134 <memmove>
    return 0;
    80002b30:	8526                	mv	a0,s1
    80002b32:	bff9                	j	80002b10 <either_copyout+0x32>

0000000080002b34 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002b34:	7179                	addi	sp,sp,-48
    80002b36:	f406                	sd	ra,40(sp)
    80002b38:	f022                	sd	s0,32(sp)
    80002b3a:	ec26                	sd	s1,24(sp)
    80002b3c:	e84a                	sd	s2,16(sp)
    80002b3e:	e44e                	sd	s3,8(sp)
    80002b40:	e052                	sd	s4,0(sp)
    80002b42:	1800                	addi	s0,sp,48
    80002b44:	892a                	mv	s2,a0
    80002b46:	84ae                	mv	s1,a1
    80002b48:	89b2                	mv	s3,a2
    80002b4a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	450080e7          	jalr	1104(ra) # 80001f9c <myproc>
  if(user_src){
    80002b54:	c08d                	beqz	s1,80002b76 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002b56:	86d2                	mv	a3,s4
    80002b58:	864e                	mv	a2,s3
    80002b5a:	85ca                	mv	a1,s2
    80002b5c:	7528                	ld	a0,104(a0)
    80002b5e:	fffff097          	auipc	ra,0xfffff
    80002b62:	0cc080e7          	jalr	204(ra) # 80001c2a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002b66:	70a2                	ld	ra,40(sp)
    80002b68:	7402                	ld	s0,32(sp)
    80002b6a:	64e2                	ld	s1,24(sp)
    80002b6c:	6942                	ld	s2,16(sp)
    80002b6e:	69a2                	ld	s3,8(sp)
    80002b70:	6a02                	ld	s4,0(sp)
    80002b72:	6145                	addi	sp,sp,48
    80002b74:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b76:	000a061b          	sext.w	a2,s4
    80002b7a:	85ce                	mv	a1,s3
    80002b7c:	854a                	mv	a0,s2
    80002b7e:	ffffe097          	auipc	ra,0xffffe
    80002b82:	5b6080e7          	jalr	1462(ra) # 80001134 <memmove>
    return 0;
    80002b86:	8526                	mv	a0,s1
    80002b88:	bff9                	j	80002b66 <either_copyin+0x32>

0000000080002b8a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b8a:	715d                	addi	sp,sp,-80
    80002b8c:	e486                	sd	ra,72(sp)
    80002b8e:	e0a2                	sd	s0,64(sp)
    80002b90:	fc26                	sd	s1,56(sp)
    80002b92:	f84a                	sd	s2,48(sp)
    80002b94:	f44e                	sd	s3,40(sp)
    80002b96:	f052                	sd	s4,32(sp)
    80002b98:	ec56                	sd	s5,24(sp)
    80002b9a:	e85a                	sd	s6,16(sp)
    80002b9c:	e45e                	sd	s7,8(sp)
    80002b9e:	e062                	sd	s8,0(sp)
    80002ba0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\nPID\tPPID\tPRIO\tSTATE\tCMD\n");
    80002ba2:	00006517          	auipc	a0,0x6
    80002ba6:	a8e50513          	addi	a0,a0,-1394 # 80008630 <userret+0x5a0>
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	dc2080e7          	jalr	-574(ra) # 8000096c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002bb2:	00013497          	auipc	s1,0x13
    80002bb6:	2e648493          	addi	s1,s1,742 # 80015e98 <proc>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bba:	4b91                	li	s7,4
      state = states[p->state];
    else
      state = "???";
    80002bbc:	00006997          	auipc	s3,0x6
    80002bc0:	a6c98993          	addi	s3,s3,-1428 # 80008628 <userret+0x598>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002bc4:	5b7d                	li	s6,-1
    80002bc6:	00006a97          	auipc	s5,0x6
    80002bca:	a8aa8a93          	addi	s5,s5,-1398 # 80008650 <userret+0x5c0>
           p->parent ? p->parent->pid : -1,
           p->priority,
           state,
           p->cmd
           );
    printf("\n");
    80002bce:	00006a17          	auipc	s4,0x6
    80002bd2:	a7aa0a13          	addi	s4,s4,-1414 # 80008648 <userret+0x5b8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bd6:	00006c17          	auipc	s8,0x6
    80002bda:	36ac0c13          	addi	s8,s8,874 # 80008f40 <states.1833>
  for(p = proc; p < &proc[NPROC]; p++){
    80002bde:	00019917          	auipc	s2,0x19
    80002be2:	4ba90913          	addi	s2,s2,1210 # 8001c098 <tickslock>
    80002be6:	a03d                	j	80002c14 <procdump+0x8a>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002be8:	48ac                	lw	a1,80(s1)
           p->parent ? p->parent->pid : -1,
    80002bea:	7c9c                	ld	a5,56(s1)
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002bec:	865a                	mv	a2,s6
    80002bee:	c391                	beqz	a5,80002bf2 <procdump+0x68>
    80002bf0:	4bb0                	lw	a2,80(a5)
    80002bf2:	1804b783          	ld	a5,384(s1)
    80002bf6:	48f4                	lw	a3,84(s1)
    80002bf8:	8556                	mv	a0,s5
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	d72080e7          	jalr	-654(ra) # 8000096c <printf>
    printf("\n");
    80002c02:	8552                	mv	a0,s4
    80002c04:	ffffe097          	auipc	ra,0xffffe
    80002c08:	d68080e7          	jalr	-664(ra) # 8000096c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c0c:	18848493          	addi	s1,s1,392
    80002c10:	01248f63          	beq	s1,s2,80002c2e <procdump+0xa4>
    if(p->state == UNUSED)
    80002c14:	589c                	lw	a5,48(s1)
    80002c16:	dbfd                	beqz	a5,80002c0c <procdump+0x82>
      state = "???";
    80002c18:	874e                	mv	a4,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c1a:	fcfbe7e3          	bltu	s7,a5,80002be8 <procdump+0x5e>
    80002c1e:	1782                	slli	a5,a5,0x20
    80002c20:	9381                	srli	a5,a5,0x20
    80002c22:	078e                	slli	a5,a5,0x3
    80002c24:	97e2                	add	a5,a5,s8
    80002c26:	6398                	ld	a4,0(a5)
    80002c28:	f361                	bnez	a4,80002be8 <procdump+0x5e>
      state = "???";
    80002c2a:	874e                	mv	a4,s3
    80002c2c:	bf75                	j	80002be8 <procdump+0x5e>
  }
}
    80002c2e:	60a6                	ld	ra,72(sp)
    80002c30:	6406                	ld	s0,64(sp)
    80002c32:	74e2                	ld	s1,56(sp)
    80002c34:	7942                	ld	s2,48(sp)
    80002c36:	79a2                	ld	s3,40(sp)
    80002c38:	7a02                	ld	s4,32(sp)
    80002c3a:	6ae2                	ld	s5,24(sp)
    80002c3c:	6b42                	ld	s6,16(sp)
    80002c3e:	6ba2                	ld	s7,8(sp)
    80002c40:	6c02                	ld	s8,0(sp)
    80002c42:	6161                	addi	sp,sp,80
    80002c44:	8082                	ret

0000000080002c46 <priodump>:

// No lock to avoid wedging a stuck machine further.
void priodump(void){
    80002c46:	715d                	addi	sp,sp,-80
    80002c48:	e486                	sd	ra,72(sp)
    80002c4a:	e0a2                	sd	s0,64(sp)
    80002c4c:	fc26                	sd	s1,56(sp)
    80002c4e:	f84a                	sd	s2,48(sp)
    80002c50:	f44e                	sd	s3,40(sp)
    80002c52:	f052                	sd	s4,32(sp)
    80002c54:	ec56                	sd	s5,24(sp)
    80002c56:	e85a                	sd	s6,16(sp)
    80002c58:	e45e                	sd	s7,8(sp)
    80002c5a:	0880                	addi	s0,sp,80
  for (int i = 0; i < NPRIO; i++){
    80002c5c:	00013a17          	auipc	s4,0x13
    80002c60:	d8ca0a13          	addi	s4,s4,-628 # 800159e8 <prio>
    80002c64:	4981                	li	s3,0
    struct list_proc* l = prio[i];
    printf("Priority queue for priority = %d: ", i);
    80002c66:	00006b97          	auipc	s7,0x6
    80002c6a:	a02b8b93          	addi	s7,s7,-1534 # 80008668 <userret+0x5d8>
    while(l){
      printf("%d ", l->p->pid);
    80002c6e:	00006917          	auipc	s2,0x6
    80002c72:	a2290913          	addi	s2,s2,-1502 # 80008690 <userret+0x600>
      l = l->next;
    }
    printf("\n");
    80002c76:	00006b17          	auipc	s6,0x6
    80002c7a:	9d2b0b13          	addi	s6,s6,-1582 # 80008648 <userret+0x5b8>
  for (int i = 0; i < NPRIO; i++){
    80002c7e:	4aa9                	li	s5,10
    80002c80:	a811                	j	80002c94 <priodump+0x4e>
    printf("\n");
    80002c82:	855a                	mv	a0,s6
    80002c84:	ffffe097          	auipc	ra,0xffffe
    80002c88:	ce8080e7          	jalr	-792(ra) # 8000096c <printf>
  for (int i = 0; i < NPRIO; i++){
    80002c8c:	2985                	addiw	s3,s3,1
    80002c8e:	0a21                	addi	s4,s4,8
    80002c90:	03598563          	beq	s3,s5,80002cba <priodump+0x74>
    struct list_proc* l = prio[i];
    80002c94:	000a3483          	ld	s1,0(s4)
    printf("Priority queue for priority = %d: ", i);
    80002c98:	85ce                	mv	a1,s3
    80002c9a:	855e                	mv	a0,s7
    80002c9c:	ffffe097          	auipc	ra,0xffffe
    80002ca0:	cd0080e7          	jalr	-816(ra) # 8000096c <printf>
    while(l){
    80002ca4:	dcf9                	beqz	s1,80002c82 <priodump+0x3c>
      printf("%d ", l->p->pid);
    80002ca6:	609c                	ld	a5,0(s1)
    80002ca8:	4bac                	lw	a1,80(a5)
    80002caa:	854a                	mv	a0,s2
    80002cac:	ffffe097          	auipc	ra,0xffffe
    80002cb0:	cc0080e7          	jalr	-832(ra) # 8000096c <printf>
      l = l->next;
    80002cb4:	6484                	ld	s1,8(s1)
    while(l){
    80002cb6:	f8e5                	bnez	s1,80002ca6 <priodump+0x60>
    80002cb8:	b7e9                	j	80002c82 <priodump+0x3c>
  }
}
    80002cba:	60a6                	ld	ra,72(sp)
    80002cbc:	6406                	ld	s0,64(sp)
    80002cbe:	74e2                	ld	s1,56(sp)
    80002cc0:	7942                	ld	s2,48(sp)
    80002cc2:	79a2                	ld	s3,40(sp)
    80002cc4:	7a02                	ld	s4,32(sp)
    80002cc6:	6ae2                	ld	s5,24(sp)
    80002cc8:	6b42                	ld	s6,16(sp)
    80002cca:	6ba2                	ld	s7,8(sp)
    80002ccc:	6161                	addi	sp,sp,80
    80002cce:	8082                	ret

0000000080002cd0 <swtch>:
    80002cd0:	00153023          	sd	ra,0(a0)
    80002cd4:	00253423          	sd	sp,8(a0)
    80002cd8:	e900                	sd	s0,16(a0)
    80002cda:	ed04                	sd	s1,24(a0)
    80002cdc:	03253023          	sd	s2,32(a0)
    80002ce0:	03353423          	sd	s3,40(a0)
    80002ce4:	03453823          	sd	s4,48(a0)
    80002ce8:	03553c23          	sd	s5,56(a0)
    80002cec:	05653023          	sd	s6,64(a0)
    80002cf0:	05753423          	sd	s7,72(a0)
    80002cf4:	05853823          	sd	s8,80(a0)
    80002cf8:	05953c23          	sd	s9,88(a0)
    80002cfc:	07a53023          	sd	s10,96(a0)
    80002d00:	07b53423          	sd	s11,104(a0)
    80002d04:	0005b083          	ld	ra,0(a1)
    80002d08:	0085b103          	ld	sp,8(a1)
    80002d0c:	6980                	ld	s0,16(a1)
    80002d0e:	6d84                	ld	s1,24(a1)
    80002d10:	0205b903          	ld	s2,32(a1)
    80002d14:	0285b983          	ld	s3,40(a1)
    80002d18:	0305ba03          	ld	s4,48(a1)
    80002d1c:	0385ba83          	ld	s5,56(a1)
    80002d20:	0405bb03          	ld	s6,64(a1)
    80002d24:	0485bb83          	ld	s7,72(a1)
    80002d28:	0505bc03          	ld	s8,80(a1)
    80002d2c:	0585bc83          	ld	s9,88(a1)
    80002d30:	0605bd03          	ld	s10,96(a1)
    80002d34:	0685bd83          	ld	s11,104(a1)
    80002d38:	8082                	ret

0000000080002d3a <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002d3a:	1141                	addi	sp,sp,-16
    80002d3c:	e422                	sd	s0,8(sp)
    80002d3e:	0800                	addi	s0,sp,16
    80002d40:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002d42:	00151713          	slli	a4,a0,0x1
    80002d46:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    80002d48:	04054c63          	bltz	a0,80002da0 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002d4c:	5685                	li	a3,-31
    80002d4e:	8285                	srli	a3,a3,0x1
    80002d50:	8ee9                	and	a3,a3,a0
    80002d52:	caad                	beqz	a3,80002dc4 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002d54:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002d56:	00006517          	auipc	a0,0x6
    80002d5a:	96a50513          	addi	a0,a0,-1686 # 800086c0 <userret+0x630>
    } else if (code <= 23) {
    80002d5e:	06e6f063          	bgeu	a3,a4,80002dbe <scause_desc+0x84>
    } else if (code <= 31) {
    80002d62:	fc100693          	li	a3,-63
    80002d66:	8285                	srli	a3,a3,0x1
    80002d68:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    80002d6a:	00006517          	auipc	a0,0x6
    80002d6e:	97e50513          	addi	a0,a0,-1666 # 800086e8 <userret+0x658>
    } else if (code <= 31) {
    80002d72:	c6b1                	beqz	a3,80002dbe <scause_desc+0x84>
    } else if (code <= 47) {
    80002d74:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    80002d78:	00006517          	auipc	a0,0x6
    80002d7c:	94850513          	addi	a0,a0,-1720 # 800086c0 <userret+0x630>
    } else if (code <= 47) {
    80002d80:	02e6ff63          	bgeu	a3,a4,80002dbe <scause_desc+0x84>
    } else if (code <= 63) {
    80002d84:	f8100513          	li	a0,-127
    80002d88:	8105                	srli	a0,a0,0x1
    80002d8a:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    80002d8c:	00006517          	auipc	a0,0x6
    80002d90:	95c50513          	addi	a0,a0,-1700 # 800086e8 <userret+0x658>
    } else if (code <= 63) {
    80002d94:	c78d                	beqz	a5,80002dbe <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    80002d96:	00006517          	auipc	a0,0x6
    80002d9a:	92a50513          	addi	a0,a0,-1750 # 800086c0 <userret+0x630>
    80002d9e:	a005                	j	80002dbe <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    80002da0:	5505                	li	a0,-31
    80002da2:	8105                	srli	a0,a0,0x1
    80002da4:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    80002da6:	00006517          	auipc	a0,0x6
    80002daa:	96250513          	addi	a0,a0,-1694 # 80008708 <userret+0x678>
    if (code < NELEM(intr_desc)) {
    80002dae:	eb81                	bnez	a5,80002dbe <scause_desc+0x84>
      return intr_desc[code];
    80002db0:	070e                	slli	a4,a4,0x3
    80002db2:	00006797          	auipc	a5,0x6
    80002db6:	1b678793          	addi	a5,a5,438 # 80008f68 <intr_desc.1629>
    80002dba:	973e                	add	a4,a4,a5
    80002dbc:	6308                	ld	a0,0(a4)
    }
  }
}
    80002dbe:	6422                	ld	s0,8(sp)
    80002dc0:	0141                	addi	sp,sp,16
    80002dc2:	8082                	ret
      return nointr_desc[code];
    80002dc4:	070e                	slli	a4,a4,0x3
    80002dc6:	00006797          	auipc	a5,0x6
    80002dca:	1a278793          	addi	a5,a5,418 # 80008f68 <intr_desc.1629>
    80002dce:	973e                	add	a4,a4,a5
    80002dd0:	6348                	ld	a0,128(a4)
    80002dd2:	b7f5                	j	80002dbe <scause_desc+0x84>

0000000080002dd4 <trapinit>:
{
    80002dd4:	1141                	addi	sp,sp,-16
    80002dd6:	e406                	sd	ra,8(sp)
    80002dd8:	e022                	sd	s0,0(sp)
    80002dda:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ddc:	00006597          	auipc	a1,0x6
    80002de0:	94c58593          	addi	a1,a1,-1716 # 80008728 <userret+0x698>
    80002de4:	00019517          	auipc	a0,0x19
    80002de8:	2b450513          	addi	a0,a0,692 # 8001c098 <tickslock>
    80002dec:	ffffe097          	auipc	ra,0xffffe
    80002df0:	d32080e7          	jalr	-718(ra) # 80000b1e <initlock>
}
    80002df4:	60a2                	ld	ra,8(sp)
    80002df6:	6402                	ld	s0,0(sp)
    80002df8:	0141                	addi	sp,sp,16
    80002dfa:	8082                	ret

0000000080002dfc <trapinithart>:
{
    80002dfc:	1141                	addi	sp,sp,-16
    80002dfe:	e422                	sd	s0,8(sp)
    80002e00:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e02:	00003797          	auipc	a5,0x3
    80002e06:	65e78793          	addi	a5,a5,1630 # 80006460 <kernelvec>
    80002e0a:	10579073          	csrw	stvec,a5
}
    80002e0e:	6422                	ld	s0,8(sp)
    80002e10:	0141                	addi	sp,sp,16
    80002e12:	8082                	ret

0000000080002e14 <usertrapret>:
{
    80002e14:	1141                	addi	sp,sp,-16
    80002e16:	e406                	sd	ra,8(sp)
    80002e18:	e022                	sd	s0,0(sp)
    80002e1a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002e1c:	fffff097          	auipc	ra,0xfffff
    80002e20:	180080e7          	jalr	384(ra) # 80001f9c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e24:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002e28:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e2a:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002e2e:	00005617          	auipc	a2,0x5
    80002e32:	1d260613          	addi	a2,a2,466 # 80008000 <trampoline>
    80002e36:	00005697          	auipc	a3,0x5
    80002e3a:	1ca68693          	addi	a3,a3,458 # 80008000 <trampoline>
    80002e3e:	8e91                	sub	a3,a3,a2
    80002e40:	040007b7          	lui	a5,0x4000
    80002e44:	17fd                	addi	a5,a5,-1
    80002e46:	07b2                	slli	a5,a5,0xc
    80002e48:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e4a:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002e4e:	7938                	ld	a4,112(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002e50:	180026f3          	csrr	a3,satp
    80002e54:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002e56:	7938                	ld	a4,112(a0)
    80002e58:	6d34                	ld	a3,88(a0)
    80002e5a:	6585                	lui	a1,0x1
    80002e5c:	96ae                	add	a3,a3,a1
    80002e5e:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002e60:	7938                	ld	a4,112(a0)
    80002e62:	00000697          	auipc	a3,0x0
    80002e66:	17e68693          	addi	a3,a3,382 # 80002fe0 <usertrap>
    80002e6a:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    80002e6c:	7938                	ld	a4,112(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002e6e:	8692                	mv	a3,tp
    80002e70:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e72:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002e76:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002e7a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e7e:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    80002e82:	7938                	ld	a4,112(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e84:	6f18                	ld	a4,24(a4)
    80002e86:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002e8a:	752c                	ld	a1,104(a0)
    80002e8c:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002e8e:	00005717          	auipc	a4,0x5
    80002e92:	20270713          	addi	a4,a4,514 # 80008090 <userret>
    80002e96:	8f11                	sub	a4,a4,a2
    80002e98:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002e9a:	577d                	li	a4,-1
    80002e9c:	177e                	slli	a4,a4,0x3f
    80002e9e:	8dd9                	or	a1,a1,a4
    80002ea0:	02000537          	lui	a0,0x2000
    80002ea4:	157d                	addi	a0,a0,-1
    80002ea6:	0536                	slli	a0,a0,0xd
    80002ea8:	9782                	jalr	a5
}
    80002eaa:	60a2                	ld	ra,8(sp)
    80002eac:	6402                	ld	s0,0(sp)
    80002eae:	0141                	addi	sp,sp,16
    80002eb0:	8082                	ret

0000000080002eb2 <clockintr>:
{
    80002eb2:	1141                	addi	sp,sp,-16
    80002eb4:	e406                	sd	ra,8(sp)
    80002eb6:	e022                	sd	s0,0(sp)
    80002eb8:	0800                	addi	s0,sp,16
  acquire(&watchdog_lock);
    80002eba:	0002b517          	auipc	a0,0x2b
    80002ebe:	17650513          	addi	a0,a0,374 # 8002e030 <watchdog_lock>
    80002ec2:	ffffe097          	auipc	ra,0xffffe
    80002ec6:	dc6080e7          	jalr	-570(ra) # 80000c88 <acquire>
  acquire(&tickslock);
    80002eca:	00019517          	auipc	a0,0x19
    80002ece:	1ce50513          	addi	a0,a0,462 # 8001c098 <tickslock>
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	db6080e7          	jalr	-586(ra) # 80000c88 <acquire>
  if (watchdog_time && ticks - watchdog_value > watchdog_time){
    80002eda:	0002b797          	auipc	a5,0x2b
    80002ede:	1ca7a783          	lw	a5,458(a5) # 8002e0a4 <watchdog_time>
    80002ee2:	cf89                	beqz	a5,80002efc <clockintr+0x4a>
    80002ee4:	0002b717          	auipc	a4,0x2b
    80002ee8:	1a472703          	lw	a4,420(a4) # 8002e088 <ticks>
    80002eec:	0002b697          	auipc	a3,0x2b
    80002ef0:	1bc6a683          	lw	a3,444(a3) # 8002e0a8 <watchdog_value>
    80002ef4:	9f15                	subw	a4,a4,a3
    80002ef6:	2781                	sext.w	a5,a5
    80002ef8:	04e7e163          	bltu	a5,a4,80002f3a <clockintr+0x88>
  ticks++;
    80002efc:	0002b517          	auipc	a0,0x2b
    80002f00:	18c50513          	addi	a0,a0,396 # 8002e088 <ticks>
    80002f04:	411c                	lw	a5,0(a0)
    80002f06:	2785                	addiw	a5,a5,1
    80002f08:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002f0a:	00000097          	auipc	ra,0x0
    80002f0e:	af8080e7          	jalr	-1288(ra) # 80002a02 <wakeup>
  release(&tickslock);
    80002f12:	00019517          	auipc	a0,0x19
    80002f16:	18650513          	addi	a0,a0,390 # 8001c098 <tickslock>
    80002f1a:	ffffe097          	auipc	ra,0xffffe
    80002f1e:	fba080e7          	jalr	-70(ra) # 80000ed4 <release>
  release(&watchdog_lock);
    80002f22:	0002b517          	auipc	a0,0x2b
    80002f26:	10e50513          	addi	a0,a0,270 # 8002e030 <watchdog_lock>
    80002f2a:	ffffe097          	auipc	ra,0xffffe
    80002f2e:	faa080e7          	jalr	-86(ra) # 80000ed4 <release>
}
    80002f32:	60a2                	ld	ra,8(sp)
    80002f34:	6402                	ld	s0,0(sp)
    80002f36:	0141                	addi	sp,sp,16
    80002f38:	8082                	ret
    panic("watchdog !!!");
    80002f3a:	00005517          	auipc	a0,0x5
    80002f3e:	7f650513          	addi	a0,a0,2038 # 80008730 <userret+0x6a0>
    80002f42:	ffffe097          	auipc	ra,0xffffe
    80002f46:	814080e7          	jalr	-2028(ra) # 80000756 <panic>

0000000080002f4a <devintr>:
{
    80002f4a:	1101                	addi	sp,sp,-32
    80002f4c:	ec06                	sd	ra,24(sp)
    80002f4e:	e822                	sd	s0,16(sp)
    80002f50:	e426                	sd	s1,8(sp)
    80002f52:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f54:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002f58:	00074d63          	bltz	a4,80002f72 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002f5c:	57fd                	li	a5,-1
    80002f5e:	17fe                	slli	a5,a5,0x3f
    80002f60:	0785                	addi	a5,a5,1
    return 0;
    80002f62:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002f64:	04f70d63          	beq	a4,a5,80002fbe <devintr+0x74>
}
    80002f68:	60e2                	ld	ra,24(sp)
    80002f6a:	6442                	ld	s0,16(sp)
    80002f6c:	64a2                	ld	s1,8(sp)
    80002f6e:	6105                	addi	sp,sp,32
    80002f70:	8082                	ret
     (scause & 0xff) == 9){
    80002f72:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002f76:	46a5                	li	a3,9
    80002f78:	fed792e3          	bne	a5,a3,80002f5c <devintr+0x12>
    int irq = plic_claim();
    80002f7c:	00003097          	auipc	ra,0x3
    80002f80:	5ec080e7          	jalr	1516(ra) # 80006568 <plic_claim>
    80002f84:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002f86:	47a9                	li	a5,10
    80002f88:	00f50a63          	beq	a0,a5,80002f9c <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80002f8c:	fff5079b          	addiw	a5,a0,-1
    80002f90:	4705                	li	a4,1
    80002f92:	00f77a63          	bgeu	a4,a5,80002fa6 <devintr+0x5c>
    return 1;
    80002f96:	4505                	li	a0,1
    if(irq)
    80002f98:	d8e1                	beqz	s1,80002f68 <devintr+0x1e>
    80002f9a:	a819                	j	80002fb0 <devintr+0x66>
      uartintr();
    80002f9c:	ffffe097          	auipc	ra,0xffffe
    80002fa0:	afc080e7          	jalr	-1284(ra) # 80000a98 <uartintr>
    80002fa4:	a031                	j	80002fb0 <devintr+0x66>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    80002fa6:	853e                	mv	a0,a5
    80002fa8:	00004097          	auipc	ra,0x4
    80002fac:	bae080e7          	jalr	-1106(ra) # 80006b56 <virtio_disk_intr>
      plic_complete(irq);
    80002fb0:	8526                	mv	a0,s1
    80002fb2:	00003097          	auipc	ra,0x3
    80002fb6:	5da080e7          	jalr	1498(ra) # 8000658c <plic_complete>
    return 1;
    80002fba:	4505                	li	a0,1
    80002fbc:	b775                	j	80002f68 <devintr+0x1e>
    if(cpuid() == 0){
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	fb2080e7          	jalr	-78(ra) # 80001f70 <cpuid>
    80002fc6:	c901                	beqz	a0,80002fd6 <devintr+0x8c>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002fc8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002fcc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002fce:	14479073          	csrw	sip,a5
    return 2;
    80002fd2:	4509                	li	a0,2
    80002fd4:	bf51                	j	80002f68 <devintr+0x1e>
      clockintr();
    80002fd6:	00000097          	auipc	ra,0x0
    80002fda:	edc080e7          	jalr	-292(ra) # 80002eb2 <clockintr>
    80002fde:	b7ed                	j	80002fc8 <devintr+0x7e>

0000000080002fe0 <usertrap>:
{
    80002fe0:	7179                	addi	sp,sp,-48
    80002fe2:	f406                	sd	ra,40(sp)
    80002fe4:	f022                	sd	s0,32(sp)
    80002fe6:	ec26                	sd	s1,24(sp)
    80002fe8:	e84a                	sd	s2,16(sp)
    80002fea:	e44e                	sd	s3,8(sp)
    80002fec:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fee:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ff2:	1007f793          	andi	a5,a5,256
    80002ff6:	e3b5                	bnez	a5,8000305a <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ff8:	00003797          	auipc	a5,0x3
    80002ffc:	46878793          	addi	a5,a5,1128 # 80006460 <kernelvec>
    80003000:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	f98080e7          	jalr	-104(ra) # 80001f9c <myproc>
    8000300c:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    8000300e:	793c                	ld	a5,112(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003010:	14102773          	csrr	a4,sepc
    80003014:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003016:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000301a:	47a1                	li	a5,8
    8000301c:	04f71d63          	bne	a4,a5,80003076 <usertrap+0x96>
    if(p->killed)
    80003020:	453c                	lw	a5,72(a0)
    80003022:	e7a1                	bnez	a5,8000306a <usertrap+0x8a>
    p->tf->epc += 4;
    80003024:	78b8                	ld	a4,112(s1)
    80003026:	6f1c                	ld	a5,24(a4)
    80003028:	0791                	addi	a5,a5,4
    8000302a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000302c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003030:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003034:	10079073          	csrw	sstatus,a5
    syscall();
    80003038:	00000097          	auipc	ra,0x0
    8000303c:	2fe080e7          	jalr	766(ra) # 80003336 <syscall>
  if(p->killed)
    80003040:	44bc                	lw	a5,72(s1)
    80003042:	e3cd                	bnez	a5,800030e4 <usertrap+0x104>
  usertrapret();
    80003044:	00000097          	auipc	ra,0x0
    80003048:	dd0080e7          	jalr	-560(ra) # 80002e14 <usertrapret>
}
    8000304c:	70a2                	ld	ra,40(sp)
    8000304e:	7402                	ld	s0,32(sp)
    80003050:	64e2                	ld	s1,24(sp)
    80003052:	6942                	ld	s2,16(sp)
    80003054:	69a2                	ld	s3,8(sp)
    80003056:	6145                	addi	sp,sp,48
    80003058:	8082                	ret
    panic("usertrap: not from user mode");
    8000305a:	00005517          	auipc	a0,0x5
    8000305e:	6e650513          	addi	a0,a0,1766 # 80008740 <userret+0x6b0>
    80003062:	ffffd097          	auipc	ra,0xffffd
    80003066:	6f4080e7          	jalr	1780(ra) # 80000756 <panic>
      exit(-1);
    8000306a:	557d                	li	a0,-1
    8000306c:	fffff097          	auipc	ra,0xfffff
    80003070:	68c080e7          	jalr	1676(ra) # 800026f8 <exit>
    80003074:	bf45                	j	80003024 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80003076:	00000097          	auipc	ra,0x0
    8000307a:	ed4080e7          	jalr	-300(ra) # 80002f4a <devintr>
    8000307e:	892a                	mv	s2,a0
    80003080:	c501                	beqz	a0,80003088 <usertrap+0xa8>
  if(p->killed)
    80003082:	44bc                	lw	a5,72(s1)
    80003084:	cba1                	beqz	a5,800030d4 <usertrap+0xf4>
    80003086:	a091                	j	800030ca <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003088:	142029f3          	csrr	s3,scause
    8000308c:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80003090:	00000097          	auipc	ra,0x0
    80003094:	caa080e7          	jalr	-854(ra) # 80002d3a <scause_desc>
    80003098:	862a                	mv	a2,a0
    8000309a:	48b4                	lw	a3,80(s1)
    8000309c:	85ce                	mv	a1,s3
    8000309e:	00005517          	auipc	a0,0x5
    800030a2:	6c250513          	addi	a0,a0,1730 # 80008760 <userret+0x6d0>
    800030a6:	ffffe097          	auipc	ra,0xffffe
    800030aa:	8c6080e7          	jalr	-1850(ra) # 8000096c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030ae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030b2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030b6:	00005517          	auipc	a0,0x5
    800030ba:	6da50513          	addi	a0,a0,1754 # 80008790 <userret+0x700>
    800030be:	ffffe097          	auipc	ra,0xffffe
    800030c2:	8ae080e7          	jalr	-1874(ra) # 8000096c <printf>
    p->killed = 1;
    800030c6:	4785                	li	a5,1
    800030c8:	c4bc                	sw	a5,72(s1)
    exit(-1);
    800030ca:	557d                	li	a0,-1
    800030cc:	fffff097          	auipc	ra,0xfffff
    800030d0:	62c080e7          	jalr	1580(ra) # 800026f8 <exit>
  if(which_dev == 2)
    800030d4:	4789                	li	a5,2
    800030d6:	f6f917e3          	bne	s2,a5,80003044 <usertrap+0x64>
    yield();
    800030da:	fffff097          	auipc	ra,0xfffff
    800030de:	766080e7          	jalr	1894(ra) # 80002840 <yield>
    800030e2:	b78d                	j	80003044 <usertrap+0x64>
  int which_dev = 0;
    800030e4:	4901                	li	s2,0
    800030e6:	b7d5                	j	800030ca <usertrap+0xea>

00000000800030e8 <kerneltrap>:
{
    800030e8:	7179                	addi	sp,sp,-48
    800030ea:	f406                	sd	ra,40(sp)
    800030ec:	f022                	sd	s0,32(sp)
    800030ee:	ec26                	sd	s1,24(sp)
    800030f0:	e84a                	sd	s2,16(sp)
    800030f2:	e44e                	sd	s3,8(sp)
    800030f4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030f6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030fa:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030fe:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003102:	1004f793          	andi	a5,s1,256
    80003106:	cb85                	beqz	a5,80003136 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003108:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000310c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000310e:	ef85                	bnez	a5,80003146 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003110:	00000097          	auipc	ra,0x0
    80003114:	e3a080e7          	jalr	-454(ra) # 80002f4a <devintr>
    80003118:	cd1d                	beqz	a0,80003156 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000311a:	4789                	li	a5,2
    8000311c:	08f50063          	beq	a0,a5,8000319c <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003120:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003124:	10049073          	csrw	sstatus,s1
}
    80003128:	70a2                	ld	ra,40(sp)
    8000312a:	7402                	ld	s0,32(sp)
    8000312c:	64e2                	ld	s1,24(sp)
    8000312e:	6942                	ld	s2,16(sp)
    80003130:	69a2                	ld	s3,8(sp)
    80003132:	6145                	addi	sp,sp,48
    80003134:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003136:	00005517          	auipc	a0,0x5
    8000313a:	67a50513          	addi	a0,a0,1658 # 800087b0 <userret+0x720>
    8000313e:	ffffd097          	auipc	ra,0xffffd
    80003142:	618080e7          	jalr	1560(ra) # 80000756 <panic>
    panic("kerneltrap: interrupts enabled");
    80003146:	00005517          	auipc	a0,0x5
    8000314a:	69250513          	addi	a0,a0,1682 # 800087d8 <userret+0x748>
    8000314e:	ffffd097          	auipc	ra,0xffffd
    80003152:	608080e7          	jalr	1544(ra) # 80000756 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80003156:	854e                	mv	a0,s3
    80003158:	00000097          	auipc	ra,0x0
    8000315c:	be2080e7          	jalr	-1054(ra) # 80002d3a <scause_desc>
    80003160:	862a                	mv	a2,a0
    80003162:	85ce                	mv	a1,s3
    80003164:	00005517          	auipc	a0,0x5
    80003168:	69450513          	addi	a0,a0,1684 # 800087f8 <userret+0x768>
    8000316c:	ffffe097          	auipc	ra,0xffffe
    80003170:	800080e7          	jalr	-2048(ra) # 8000096c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003174:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003178:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000317c:	00005517          	auipc	a0,0x5
    80003180:	68c50513          	addi	a0,a0,1676 # 80008808 <userret+0x778>
    80003184:	ffffd097          	auipc	ra,0xffffd
    80003188:	7e8080e7          	jalr	2024(ra) # 8000096c <printf>
    panic("kerneltrap");
    8000318c:	00005517          	auipc	a0,0x5
    80003190:	69450513          	addi	a0,a0,1684 # 80008820 <userret+0x790>
    80003194:	ffffd097          	auipc	ra,0xffffd
    80003198:	5c2080e7          	jalr	1474(ra) # 80000756 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000319c:	fffff097          	auipc	ra,0xfffff
    800031a0:	e00080e7          	jalr	-512(ra) # 80001f9c <myproc>
    800031a4:	dd35                	beqz	a0,80003120 <kerneltrap+0x38>
    800031a6:	fffff097          	auipc	ra,0xfffff
    800031aa:	df6080e7          	jalr	-522(ra) # 80001f9c <myproc>
    800031ae:	5918                	lw	a4,48(a0)
    800031b0:	478d                	li	a5,3
    800031b2:	f6f717e3          	bne	a4,a5,80003120 <kerneltrap+0x38>
    yield();
    800031b6:	fffff097          	auipc	ra,0xfffff
    800031ba:	68a080e7          	jalr	1674(ra) # 80002840 <yield>
    800031be:	b78d                	j	80003120 <kerneltrap+0x38>

00000000800031c0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800031c0:	1101                	addi	sp,sp,-32
    800031c2:	ec06                	sd	ra,24(sp)
    800031c4:	e822                	sd	s0,16(sp)
    800031c6:	e426                	sd	s1,8(sp)
    800031c8:	1000                	addi	s0,sp,32
    800031ca:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800031cc:	fffff097          	auipc	ra,0xfffff
    800031d0:	dd0080e7          	jalr	-560(ra) # 80001f9c <myproc>
  switch (n) {
    800031d4:	4795                	li	a5,5
    800031d6:	0497e163          	bltu	a5,s1,80003218 <argraw+0x58>
    800031da:	048a                	slli	s1,s1,0x2
    800031dc:	00006717          	auipc	a4,0x6
    800031e0:	e8c70713          	addi	a4,a4,-372 # 80009068 <nointr_desc.1630+0x80>
    800031e4:	94ba                	add	s1,s1,a4
    800031e6:	409c                	lw	a5,0(s1)
    800031e8:	97ba                	add	a5,a5,a4
    800031ea:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    800031ec:	793c                	ld	a5,112(a0)
    800031ee:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    800031f0:	60e2                	ld	ra,24(sp)
    800031f2:	6442                	ld	s0,16(sp)
    800031f4:	64a2                	ld	s1,8(sp)
    800031f6:	6105                	addi	sp,sp,32
    800031f8:	8082                	ret
    return p->tf->a1;
    800031fa:	793c                	ld	a5,112(a0)
    800031fc:	7fa8                	ld	a0,120(a5)
    800031fe:	bfcd                	j	800031f0 <argraw+0x30>
    return p->tf->a2;
    80003200:	793c                	ld	a5,112(a0)
    80003202:	63c8                	ld	a0,128(a5)
    80003204:	b7f5                	j	800031f0 <argraw+0x30>
    return p->tf->a3;
    80003206:	793c                	ld	a5,112(a0)
    80003208:	67c8                	ld	a0,136(a5)
    8000320a:	b7dd                	j	800031f0 <argraw+0x30>
    return p->tf->a4;
    8000320c:	793c                	ld	a5,112(a0)
    8000320e:	6bc8                	ld	a0,144(a5)
    80003210:	b7c5                	j	800031f0 <argraw+0x30>
    return p->tf->a5;
    80003212:	793c                	ld	a5,112(a0)
    80003214:	6fc8                	ld	a0,152(a5)
    80003216:	bfe9                	j	800031f0 <argraw+0x30>
  panic("argraw");
    80003218:	00006517          	auipc	a0,0x6
    8000321c:	81050513          	addi	a0,a0,-2032 # 80008a28 <userret+0x998>
    80003220:	ffffd097          	auipc	ra,0xffffd
    80003224:	536080e7          	jalr	1334(ra) # 80000756 <panic>

0000000080003228 <fetchaddr>:
{
    80003228:	1101                	addi	sp,sp,-32
    8000322a:	ec06                	sd	ra,24(sp)
    8000322c:	e822                	sd	s0,16(sp)
    8000322e:	e426                	sd	s1,8(sp)
    80003230:	e04a                	sd	s2,0(sp)
    80003232:	1000                	addi	s0,sp,32
    80003234:	84aa                	mv	s1,a0
    80003236:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003238:	fffff097          	auipc	ra,0xfffff
    8000323c:	d64080e7          	jalr	-668(ra) # 80001f9c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003240:	713c                	ld	a5,96(a0)
    80003242:	02f4f863          	bgeu	s1,a5,80003272 <fetchaddr+0x4a>
    80003246:	00848713          	addi	a4,s1,8
    8000324a:	02e7e663          	bltu	a5,a4,80003276 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000324e:	46a1                	li	a3,8
    80003250:	8626                	mv	a2,s1
    80003252:	85ca                	mv	a1,s2
    80003254:	7528                	ld	a0,104(a0)
    80003256:	fffff097          	auipc	ra,0xfffff
    8000325a:	9d4080e7          	jalr	-1580(ra) # 80001c2a <copyin>
    8000325e:	00a03533          	snez	a0,a0
    80003262:	40a00533          	neg	a0,a0
}
    80003266:	60e2                	ld	ra,24(sp)
    80003268:	6442                	ld	s0,16(sp)
    8000326a:	64a2                	ld	s1,8(sp)
    8000326c:	6902                	ld	s2,0(sp)
    8000326e:	6105                	addi	sp,sp,32
    80003270:	8082                	ret
    return -1;
    80003272:	557d                	li	a0,-1
    80003274:	bfcd                	j	80003266 <fetchaddr+0x3e>
    80003276:	557d                	li	a0,-1
    80003278:	b7fd                	j	80003266 <fetchaddr+0x3e>

000000008000327a <fetchstr>:
{
    8000327a:	7179                	addi	sp,sp,-48
    8000327c:	f406                	sd	ra,40(sp)
    8000327e:	f022                	sd	s0,32(sp)
    80003280:	ec26                	sd	s1,24(sp)
    80003282:	e84a                	sd	s2,16(sp)
    80003284:	e44e                	sd	s3,8(sp)
    80003286:	1800                	addi	s0,sp,48
    80003288:	892a                	mv	s2,a0
    8000328a:	84ae                	mv	s1,a1
    8000328c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000328e:	fffff097          	auipc	ra,0xfffff
    80003292:	d0e080e7          	jalr	-754(ra) # 80001f9c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003296:	86ce                	mv	a3,s3
    80003298:	864a                	mv	a2,s2
    8000329a:	85a6                	mv	a1,s1
    8000329c:	7528                	ld	a0,104(a0)
    8000329e:	fffff097          	auipc	ra,0xfffff
    800032a2:	a18080e7          	jalr	-1512(ra) # 80001cb6 <copyinstr>
  if(err < 0)
    800032a6:	00054763          	bltz	a0,800032b4 <fetchstr+0x3a>
  return strlen(buf);
    800032aa:	8526                	mv	a0,s1
    800032ac:	ffffe097          	auipc	ra,0xffffe
    800032b0:	fb0080e7          	jalr	-80(ra) # 8000125c <strlen>
}
    800032b4:	70a2                	ld	ra,40(sp)
    800032b6:	7402                	ld	s0,32(sp)
    800032b8:	64e2                	ld	s1,24(sp)
    800032ba:	6942                	ld	s2,16(sp)
    800032bc:	69a2                	ld	s3,8(sp)
    800032be:	6145                	addi	sp,sp,48
    800032c0:	8082                	ret

00000000800032c2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800032c2:	1101                	addi	sp,sp,-32
    800032c4:	ec06                	sd	ra,24(sp)
    800032c6:	e822                	sd	s0,16(sp)
    800032c8:	e426                	sd	s1,8(sp)
    800032ca:	1000                	addi	s0,sp,32
    800032cc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032ce:	00000097          	auipc	ra,0x0
    800032d2:	ef2080e7          	jalr	-270(ra) # 800031c0 <argraw>
    800032d6:	c088                	sw	a0,0(s1)
  return 0;
}
    800032d8:	4501                	li	a0,0
    800032da:	60e2                	ld	ra,24(sp)
    800032dc:	6442                	ld	s0,16(sp)
    800032de:	64a2                	ld	s1,8(sp)
    800032e0:	6105                	addi	sp,sp,32
    800032e2:	8082                	ret

00000000800032e4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800032e4:	1101                	addi	sp,sp,-32
    800032e6:	ec06                	sd	ra,24(sp)
    800032e8:	e822                	sd	s0,16(sp)
    800032ea:	e426                	sd	s1,8(sp)
    800032ec:	1000                	addi	s0,sp,32
    800032ee:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	ed0080e7          	jalr	-304(ra) # 800031c0 <argraw>
    800032f8:	e088                	sd	a0,0(s1)
  return 0;
}
    800032fa:	4501                	li	a0,0
    800032fc:	60e2                	ld	ra,24(sp)
    800032fe:	6442                	ld	s0,16(sp)
    80003300:	64a2                	ld	s1,8(sp)
    80003302:	6105                	addi	sp,sp,32
    80003304:	8082                	ret

0000000080003306 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003306:	1101                	addi	sp,sp,-32
    80003308:	ec06                	sd	ra,24(sp)
    8000330a:	e822                	sd	s0,16(sp)
    8000330c:	e426                	sd	s1,8(sp)
    8000330e:	e04a                	sd	s2,0(sp)
    80003310:	1000                	addi	s0,sp,32
    80003312:	84ae                	mv	s1,a1
    80003314:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003316:	00000097          	auipc	ra,0x0
    8000331a:	eaa080e7          	jalr	-342(ra) # 800031c0 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000331e:	864a                	mv	a2,s2
    80003320:	85a6                	mv	a1,s1
    80003322:	00000097          	auipc	ra,0x0
    80003326:	f58080e7          	jalr	-168(ra) # 8000327a <fetchstr>
}
    8000332a:	60e2                	ld	ra,24(sp)
    8000332c:	6442                	ld	s0,16(sp)
    8000332e:	64a2                	ld	s1,8(sp)
    80003330:	6902                	ld	s2,0(sp)
    80003332:	6105                	addi	sp,sp,32
    80003334:	8082                	ret

0000000080003336 <syscall>:
[SYS_release_mutex]  sys_release_mutex,
};

void
syscall(void)
{
    80003336:	1101                	addi	sp,sp,-32
    80003338:	ec06                	sd	ra,24(sp)
    8000333a:	e822                	sd	s0,16(sp)
    8000333c:	e426                	sd	s1,8(sp)
    8000333e:	e04a                	sd	s2,0(sp)
    80003340:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003342:	fffff097          	auipc	ra,0xfffff
    80003346:	c5a080e7          	jalr	-934(ra) # 80001f9c <myproc>
    8000334a:	84aa                	mv	s1,a0

  num = p->tf->a7;
    8000334c:	07053903          	ld	s2,112(a0)
    80003350:	0a893783          	ld	a5,168(s2)
    80003354:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003358:	37fd                	addiw	a5,a5,-1
    8000335a:	4765                	li	a4,25
    8000335c:	00f76f63          	bltu	a4,a5,8000337a <syscall+0x44>
    80003360:	00369713          	slli	a4,a3,0x3
    80003364:	00006797          	auipc	a5,0x6
    80003368:	d1c78793          	addi	a5,a5,-740 # 80009080 <syscalls>
    8000336c:	97ba                	add	a5,a5,a4
    8000336e:	639c                	ld	a5,0(a5)
    80003370:	c789                	beqz	a5,8000337a <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80003372:	9782                	jalr	a5
    80003374:	06a93823          	sd	a0,112(s2)
    80003378:	a839                	j	80003396 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000337a:	17048613          	addi	a2,s1,368
    8000337e:	48ac                	lw	a1,80(s1)
    80003380:	00005517          	auipc	a0,0x5
    80003384:	6b050513          	addi	a0,a0,1712 # 80008a30 <userret+0x9a0>
    80003388:	ffffd097          	auipc	ra,0xffffd
    8000338c:	5e4080e7          	jalr	1508(ra) # 8000096c <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80003390:	78bc                	ld	a5,112(s1)
    80003392:	577d                	li	a4,-1
    80003394:	fbb8                	sd	a4,112(a5)
  }
}
    80003396:	60e2                	ld	ra,24(sp)
    80003398:	6442                	ld	s0,16(sp)
    8000339a:	64a2                	ld	s1,8(sp)
    8000339c:	6902                	ld	s2,0(sp)
    8000339e:	6105                	addi	sp,sp,32
    800033a0:	8082                	ret

00000000800033a2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800033a2:	1101                	addi	sp,sp,-32
    800033a4:	ec06                	sd	ra,24(sp)
    800033a6:	e822                	sd	s0,16(sp)
    800033a8:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800033aa:	fec40593          	addi	a1,s0,-20
    800033ae:	4501                	li	a0,0
    800033b0:	00000097          	auipc	ra,0x0
    800033b4:	f12080e7          	jalr	-238(ra) # 800032c2 <argint>
    return -1;
    800033b8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800033ba:	00054963          	bltz	a0,800033cc <sys_exit+0x2a>
  exit(n);
    800033be:	fec42503          	lw	a0,-20(s0)
    800033c2:	fffff097          	auipc	ra,0xfffff
    800033c6:	336080e7          	jalr	822(ra) # 800026f8 <exit>
  return 0;  // not reached
    800033ca:	4781                	li	a5,0
}
    800033cc:	853e                	mv	a0,a5
    800033ce:	60e2                	ld	ra,24(sp)
    800033d0:	6442                	ld	s0,16(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret

00000000800033d6 <sys_getpid>:

uint64
sys_getpid(void)
{
    800033d6:	1141                	addi	sp,sp,-16
    800033d8:	e406                	sd	ra,8(sp)
    800033da:	e022                	sd	s0,0(sp)
    800033dc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800033de:	fffff097          	auipc	ra,0xfffff
    800033e2:	bbe080e7          	jalr	-1090(ra) # 80001f9c <myproc>
}
    800033e6:	4928                	lw	a0,80(a0)
    800033e8:	60a2                	ld	ra,8(sp)
    800033ea:	6402                	ld	s0,0(sp)
    800033ec:	0141                	addi	sp,sp,16
    800033ee:	8082                	ret

00000000800033f0 <sys_fork>:

uint64
sys_fork(void)
{
    800033f0:	1141                	addi	sp,sp,-16
    800033f2:	e406                	sd	ra,8(sp)
    800033f4:	e022                	sd	s0,0(sp)
    800033f6:	0800                	addi	s0,sp,16
  return fork();
    800033f8:	fffff097          	auipc	ra,0xfffff
    800033fc:	f66080e7          	jalr	-154(ra) # 8000235e <fork>
}
    80003400:	60a2                	ld	ra,8(sp)
    80003402:	6402                	ld	s0,0(sp)
    80003404:	0141                	addi	sp,sp,16
    80003406:	8082                	ret

0000000080003408 <sys_wait>:

uint64
sys_wait(void)
{
    80003408:	1101                	addi	sp,sp,-32
    8000340a:	ec06                	sd	ra,24(sp)
    8000340c:	e822                	sd	s0,16(sp)
    8000340e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003410:	fe840593          	addi	a1,s0,-24
    80003414:	4501                	li	a0,0
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	ece080e7          	jalr	-306(ra) # 800032e4 <argaddr>
    8000341e:	87aa                	mv	a5,a0
    return -1;
    80003420:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003422:	0007c863          	bltz	a5,80003432 <sys_wait+0x2a>
  return wait(p);
    80003426:	fe843503          	ld	a0,-24(s0)
    8000342a:	fffff097          	auipc	ra,0xfffff
    8000342e:	4d0080e7          	jalr	1232(ra) # 800028fa <wait>
}
    80003432:	60e2                	ld	ra,24(sp)
    80003434:	6442                	ld	s0,16(sp)
    80003436:	6105                	addi	sp,sp,32
    80003438:	8082                	ret

000000008000343a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000343a:	7179                	addi	sp,sp,-48
    8000343c:	f406                	sd	ra,40(sp)
    8000343e:	f022                	sd	s0,32(sp)
    80003440:	ec26                	sd	s1,24(sp)
    80003442:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003444:	fdc40593          	addi	a1,s0,-36
    80003448:	4501                	li	a0,0
    8000344a:	00000097          	auipc	ra,0x0
    8000344e:	e78080e7          	jalr	-392(ra) # 800032c2 <argint>
    80003452:	87aa                	mv	a5,a0
    return -1;
    80003454:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003456:	0207c063          	bltz	a5,80003476 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    8000345a:	fffff097          	auipc	ra,0xfffff
    8000345e:	b42080e7          	jalr	-1214(ra) # 80001f9c <myproc>
    80003462:	5124                	lw	s1,96(a0)
  if(growproc(n) < 0)
    80003464:	fdc42503          	lw	a0,-36(s0)
    80003468:	fffff097          	auipc	ra,0xfffff
    8000346c:	e82080e7          	jalr	-382(ra) # 800022ea <growproc>
    80003470:	00054863          	bltz	a0,80003480 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003474:	8526                	mv	a0,s1
}
    80003476:	70a2                	ld	ra,40(sp)
    80003478:	7402                	ld	s0,32(sp)
    8000347a:	64e2                	ld	s1,24(sp)
    8000347c:	6145                	addi	sp,sp,48
    8000347e:	8082                	ret
    return -1;
    80003480:	557d                	li	a0,-1
    80003482:	bfd5                	j	80003476 <sys_sbrk+0x3c>

0000000080003484 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003484:	7139                	addi	sp,sp,-64
    80003486:	fc06                	sd	ra,56(sp)
    80003488:	f822                	sd	s0,48(sp)
    8000348a:	f426                	sd	s1,40(sp)
    8000348c:	f04a                	sd	s2,32(sp)
    8000348e:	ec4e                	sd	s3,24(sp)
    80003490:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003492:	fcc40593          	addi	a1,s0,-52
    80003496:	4501                	li	a0,0
    80003498:	00000097          	auipc	ra,0x0
    8000349c:	e2a080e7          	jalr	-470(ra) # 800032c2 <argint>
    return -1;
    800034a0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800034a2:	06054563          	bltz	a0,8000350c <sys_sleep+0x88>
  acquire(&tickslock);
    800034a6:	00019517          	auipc	a0,0x19
    800034aa:	bf250513          	addi	a0,a0,-1038 # 8001c098 <tickslock>
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	7da080e7          	jalr	2010(ra) # 80000c88 <acquire>
  ticks0 = ticks;
    800034b6:	0002b917          	auipc	s2,0x2b
    800034ba:	bd292903          	lw	s2,-1070(s2) # 8002e088 <ticks>
  while(ticks - ticks0 < n){
    800034be:	fcc42783          	lw	a5,-52(s0)
    800034c2:	cf85                	beqz	a5,800034fa <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800034c4:	00019997          	auipc	s3,0x19
    800034c8:	bd498993          	addi	s3,s3,-1068 # 8001c098 <tickslock>
    800034cc:	0002b497          	auipc	s1,0x2b
    800034d0:	bbc48493          	addi	s1,s1,-1092 # 8002e088 <ticks>
    if(myproc()->killed){
    800034d4:	fffff097          	auipc	ra,0xfffff
    800034d8:	ac8080e7          	jalr	-1336(ra) # 80001f9c <myproc>
    800034dc:	453c                	lw	a5,72(a0)
    800034de:	ef9d                	bnez	a5,8000351c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800034e0:	85ce                	mv	a1,s3
    800034e2:	8526                	mv	a0,s1
    800034e4:	fffff097          	auipc	ra,0xfffff
    800034e8:	398080e7          	jalr	920(ra) # 8000287c <sleep>
  while(ticks - ticks0 < n){
    800034ec:	409c                	lw	a5,0(s1)
    800034ee:	412787bb          	subw	a5,a5,s2
    800034f2:	fcc42703          	lw	a4,-52(s0)
    800034f6:	fce7efe3          	bltu	a5,a4,800034d4 <sys_sleep+0x50>
  }
  release(&tickslock);
    800034fa:	00019517          	auipc	a0,0x19
    800034fe:	b9e50513          	addi	a0,a0,-1122 # 8001c098 <tickslock>
    80003502:	ffffe097          	auipc	ra,0xffffe
    80003506:	9d2080e7          	jalr	-1582(ra) # 80000ed4 <release>
  return 0;
    8000350a:	4781                	li	a5,0
}
    8000350c:	853e                	mv	a0,a5
    8000350e:	70e2                	ld	ra,56(sp)
    80003510:	7442                	ld	s0,48(sp)
    80003512:	74a2                	ld	s1,40(sp)
    80003514:	7902                	ld	s2,32(sp)
    80003516:	69e2                	ld	s3,24(sp)
    80003518:	6121                	addi	sp,sp,64
    8000351a:	8082                	ret
      release(&tickslock);
    8000351c:	00019517          	auipc	a0,0x19
    80003520:	b7c50513          	addi	a0,a0,-1156 # 8001c098 <tickslock>
    80003524:	ffffe097          	auipc	ra,0xffffe
    80003528:	9b0080e7          	jalr	-1616(ra) # 80000ed4 <release>
      return -1;
    8000352c:	57fd                	li	a5,-1
    8000352e:	bff9                	j	8000350c <sys_sleep+0x88>

0000000080003530 <sys_nice>:

uint64
sys_nice(void){
    80003530:	1141                	addi	sp,sp,-16
    80003532:	e422                	sd	s0,8(sp)
    80003534:	0800                	addi	s0,sp,16
  return 0;
}
    80003536:	4501                	li	a0,0
    80003538:	6422                	ld	s0,8(sp)
    8000353a:	0141                	addi	sp,sp,16
    8000353c:	8082                	ret

000000008000353e <sys_kill>:

uint64
sys_kill(void)
{
    8000353e:	1101                	addi	sp,sp,-32
    80003540:	ec06                	sd	ra,24(sp)
    80003542:	e822                	sd	s0,16(sp)
    80003544:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003546:	fec40593          	addi	a1,s0,-20
    8000354a:	4501                	li	a0,0
    8000354c:	00000097          	auipc	ra,0x0
    80003550:	d76080e7          	jalr	-650(ra) # 800032c2 <argint>
    80003554:	87aa                	mv	a5,a0
    return -1;
    80003556:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003558:	0007c863          	bltz	a5,80003568 <sys_kill+0x2a>
  return kill(pid);
    8000355c:	fec42503          	lw	a0,-20(s0)
    80003560:	fffff097          	auipc	ra,0xfffff
    80003564:	50c080e7          	jalr	1292(ra) # 80002a6c <kill>
}
    80003568:	60e2                	ld	ra,24(sp)
    8000356a:	6442                	ld	s0,16(sp)
    8000356c:	6105                	addi	sp,sp,32
    8000356e:	8082                	ret

0000000080003570 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003570:	1101                	addi	sp,sp,-32
    80003572:	ec06                	sd	ra,24(sp)
    80003574:	e822                	sd	s0,16(sp)
    80003576:	e426                	sd	s1,8(sp)
    80003578:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000357a:	00019517          	auipc	a0,0x19
    8000357e:	b1e50513          	addi	a0,a0,-1250 # 8001c098 <tickslock>
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	706080e7          	jalr	1798(ra) # 80000c88 <acquire>
  xticks = ticks;
    8000358a:	0002b497          	auipc	s1,0x2b
    8000358e:	afe4a483          	lw	s1,-1282(s1) # 8002e088 <ticks>
  release(&tickslock);
    80003592:	00019517          	auipc	a0,0x19
    80003596:	b0650513          	addi	a0,a0,-1274 # 8001c098 <tickslock>
    8000359a:	ffffe097          	auipc	ra,0xffffe
    8000359e:	93a080e7          	jalr	-1734(ra) # 80000ed4 <release>
  return xticks;
}
    800035a2:	02049513          	slli	a0,s1,0x20
    800035a6:	9101                	srli	a0,a0,0x20
    800035a8:	60e2                	ld	ra,24(sp)
    800035aa:	6442                	ld	s0,16(sp)
    800035ac:	64a2                	ld	s1,8(sp)
    800035ae:	6105                	addi	sp,sp,32
    800035b0:	8082                	ret

00000000800035b2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800035b2:	7179                	addi	sp,sp,-48
    800035b4:	f406                	sd	ra,40(sp)
    800035b6:	f022                	sd	s0,32(sp)
    800035b8:	ec26                	sd	s1,24(sp)
    800035ba:	e84a                	sd	s2,16(sp)
    800035bc:	e44e                	sd	s3,8(sp)
    800035be:	e052                	sd	s4,0(sp)
    800035c0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800035c2:	00005597          	auipc	a1,0x5
    800035c6:	e3e58593          	addi	a1,a1,-450 # 80008400 <userret+0x370>
    800035ca:	00019517          	auipc	a0,0x19
    800035ce:	afe50513          	addi	a0,a0,-1282 # 8001c0c8 <bcache>
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	54c080e7          	jalr	1356(ra) # 80000b1e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800035da:	00021797          	auipc	a5,0x21
    800035de:	aee78793          	addi	a5,a5,-1298 # 800240c8 <bcache+0x8000>
    800035e2:	00021717          	auipc	a4,0x21
    800035e6:	03670713          	addi	a4,a4,54 # 80024618 <bcache+0x8550>
    800035ea:	5ae7b823          	sd	a4,1456(a5)
  bcache.head.next = &bcache.head;
    800035ee:	5ae7bc23          	sd	a4,1464(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035f2:	00019497          	auipc	s1,0x19
    800035f6:	b0648493          	addi	s1,s1,-1274 # 8001c0f8 <bcache+0x30>
    b->next = bcache.head.next;
    800035fa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800035fc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800035fe:	00005a17          	auipc	s4,0x5
    80003602:	452a0a13          	addi	s4,s4,1106 # 80008a50 <userret+0x9c0>
    b->next = bcache.head.next;
    80003606:	5b893783          	ld	a5,1464(s2)
    8000360a:	f4bc                	sd	a5,104(s1)
    b->prev = &bcache.head;
    8000360c:	0734b023          	sd	s3,96(s1)
    initsleeplock(&b->lock, "buffer");
    80003610:	85d2                	mv	a1,s4
    80003612:	01048513          	addi	a0,s1,16
    80003616:	00001097          	auipc	ra,0x1
    8000361a:	57c080e7          	jalr	1404(ra) # 80004b92 <initsleeplock>
    bcache.head.next->prev = b;
    8000361e:	5b893783          	ld	a5,1464(s2)
    80003622:	f3a4                	sd	s1,96(a5)
    bcache.head.next = b;
    80003624:	5a993c23          	sd	s1,1464(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003628:	47048493          	addi	s1,s1,1136
    8000362c:	fd349de3          	bne	s1,s3,80003606 <binit+0x54>
  }
}
    80003630:	70a2                	ld	ra,40(sp)
    80003632:	7402                	ld	s0,32(sp)
    80003634:	64e2                	ld	s1,24(sp)
    80003636:	6942                	ld	s2,16(sp)
    80003638:	69a2                	ld	s3,8(sp)
    8000363a:	6a02                	ld	s4,0(sp)
    8000363c:	6145                	addi	sp,sp,48
    8000363e:	8082                	ret

0000000080003640 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003640:	7179                	addi	sp,sp,-48
    80003642:	f406                	sd	ra,40(sp)
    80003644:	f022                	sd	s0,32(sp)
    80003646:	ec26                	sd	s1,24(sp)
    80003648:	e84a                	sd	s2,16(sp)
    8000364a:	e44e                	sd	s3,8(sp)
    8000364c:	1800                	addi	s0,sp,48
    8000364e:	89aa                	mv	s3,a0
    80003650:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003652:	00019517          	auipc	a0,0x19
    80003656:	a7650513          	addi	a0,a0,-1418 # 8001c0c8 <bcache>
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	62e080e7          	jalr	1582(ra) # 80000c88 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003662:	00021497          	auipc	s1,0x21
    80003666:	01e4b483          	ld	s1,30(s1) # 80024680 <bcache+0x85b8>
    8000366a:	00021797          	auipc	a5,0x21
    8000366e:	fae78793          	addi	a5,a5,-82 # 80024618 <bcache+0x8550>
    80003672:	02f48f63          	beq	s1,a5,800036b0 <bread+0x70>
    80003676:	873e                	mv	a4,a5
    80003678:	a021                	j	80003680 <bread+0x40>
    8000367a:	74a4                	ld	s1,104(s1)
    8000367c:	02e48a63          	beq	s1,a4,800036b0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003680:	449c                	lw	a5,8(s1)
    80003682:	ff379ce3          	bne	a5,s3,8000367a <bread+0x3a>
    80003686:	44dc                	lw	a5,12(s1)
    80003688:	ff2799e3          	bne	a5,s2,8000367a <bread+0x3a>
      b->refcnt++;
    8000368c:	4cbc                	lw	a5,88(s1)
    8000368e:	2785                	addiw	a5,a5,1
    80003690:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    80003692:	00019517          	auipc	a0,0x19
    80003696:	a3650513          	addi	a0,a0,-1482 # 8001c0c8 <bcache>
    8000369a:	ffffe097          	auipc	ra,0xffffe
    8000369e:	83a080e7          	jalr	-1990(ra) # 80000ed4 <release>
      acquiresleep(&b->lock);
    800036a2:	01048513          	addi	a0,s1,16
    800036a6:	00001097          	auipc	ra,0x1
    800036aa:	526080e7          	jalr	1318(ra) # 80004bcc <acquiresleep>
      return b;
    800036ae:	a8b9                	j	8000370c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036b0:	00021497          	auipc	s1,0x21
    800036b4:	fc84b483          	ld	s1,-56(s1) # 80024678 <bcache+0x85b0>
    800036b8:	00021797          	auipc	a5,0x21
    800036bc:	f6078793          	addi	a5,a5,-160 # 80024618 <bcache+0x8550>
    800036c0:	00f48863          	beq	s1,a5,800036d0 <bread+0x90>
    800036c4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800036c6:	4cbc                	lw	a5,88(s1)
    800036c8:	cf81                	beqz	a5,800036e0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036ca:	70a4                	ld	s1,96(s1)
    800036cc:	fee49de3          	bne	s1,a4,800036c6 <bread+0x86>
  panic("bget: no buffers");
    800036d0:	00005517          	auipc	a0,0x5
    800036d4:	38850513          	addi	a0,a0,904 # 80008a58 <userret+0x9c8>
    800036d8:	ffffd097          	auipc	ra,0xffffd
    800036dc:	07e080e7          	jalr	126(ra) # 80000756 <panic>
      b->dev = dev;
    800036e0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800036e4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800036e8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800036ec:	4785                	li	a5,1
    800036ee:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    800036f0:	00019517          	auipc	a0,0x19
    800036f4:	9d850513          	addi	a0,a0,-1576 # 8001c0c8 <bcache>
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	7dc080e7          	jalr	2012(ra) # 80000ed4 <release>
      acquiresleep(&b->lock);
    80003700:	01048513          	addi	a0,s1,16
    80003704:	00001097          	auipc	ra,0x1
    80003708:	4c8080e7          	jalr	1224(ra) # 80004bcc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000370c:	409c                	lw	a5,0(s1)
    8000370e:	cb89                	beqz	a5,80003720 <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80003710:	8526                	mv	a0,s1
    80003712:	70a2                	ld	ra,40(sp)
    80003714:	7402                	ld	s0,32(sp)
    80003716:	64e2                	ld	s1,24(sp)
    80003718:	6942                	ld	s2,16(sp)
    8000371a:	69a2                	ld	s3,8(sp)
    8000371c:	6145                	addi	sp,sp,48
    8000371e:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80003720:	4601                	li	a2,0
    80003722:	85a6                	mv	a1,s1
    80003724:	4488                	lw	a0,8(s1)
    80003726:	00003097          	auipc	ra,0x3
    8000372a:	118080e7          	jalr	280(ra) # 8000683e <virtio_disk_rw>
    b->valid = 1;
    8000372e:	4785                	li	a5,1
    80003730:	c09c                	sw	a5,0(s1)
  return b;
    80003732:	bff9                	j	80003710 <bread+0xd0>

0000000080003734 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003734:	1101                	addi	sp,sp,-32
    80003736:	ec06                	sd	ra,24(sp)
    80003738:	e822                	sd	s0,16(sp)
    8000373a:	e426                	sd	s1,8(sp)
    8000373c:	1000                	addi	s0,sp,32
    8000373e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003740:	0541                	addi	a0,a0,16
    80003742:	00001097          	auipc	ra,0x1
    80003746:	524080e7          	jalr	1316(ra) # 80004c66 <holdingsleep>
    8000374a:	cd09                	beqz	a0,80003764 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    8000374c:	4605                	li	a2,1
    8000374e:	85a6                	mv	a1,s1
    80003750:	4488                	lw	a0,8(s1)
    80003752:	00003097          	auipc	ra,0x3
    80003756:	0ec080e7          	jalr	236(ra) # 8000683e <virtio_disk_rw>
}
    8000375a:	60e2                	ld	ra,24(sp)
    8000375c:	6442                	ld	s0,16(sp)
    8000375e:	64a2                	ld	s1,8(sp)
    80003760:	6105                	addi	sp,sp,32
    80003762:	8082                	ret
    panic("bwrite");
    80003764:	00005517          	auipc	a0,0x5
    80003768:	30c50513          	addi	a0,a0,780 # 80008a70 <userret+0x9e0>
    8000376c:	ffffd097          	auipc	ra,0xffffd
    80003770:	fea080e7          	jalr	-22(ra) # 80000756 <panic>

0000000080003774 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003774:	1101                	addi	sp,sp,-32
    80003776:	ec06                	sd	ra,24(sp)
    80003778:	e822                	sd	s0,16(sp)
    8000377a:	e426                	sd	s1,8(sp)
    8000377c:	e04a                	sd	s2,0(sp)
    8000377e:	1000                	addi	s0,sp,32
    80003780:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003782:	01050913          	addi	s2,a0,16
    80003786:	854a                	mv	a0,s2
    80003788:	00001097          	auipc	ra,0x1
    8000378c:	4de080e7          	jalr	1246(ra) # 80004c66 <holdingsleep>
    80003790:	c92d                	beqz	a0,80003802 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003792:	854a                	mv	a0,s2
    80003794:	00001097          	auipc	ra,0x1
    80003798:	48e080e7          	jalr	1166(ra) # 80004c22 <releasesleep>

  acquire(&bcache.lock);
    8000379c:	00019517          	auipc	a0,0x19
    800037a0:	92c50513          	addi	a0,a0,-1748 # 8001c0c8 <bcache>
    800037a4:	ffffd097          	auipc	ra,0xffffd
    800037a8:	4e4080e7          	jalr	1252(ra) # 80000c88 <acquire>
  b->refcnt--;
    800037ac:	4cbc                	lw	a5,88(s1)
    800037ae:	37fd                	addiw	a5,a5,-1
    800037b0:	0007871b          	sext.w	a4,a5
    800037b4:	ccbc                	sw	a5,88(s1)
  if (b->refcnt == 0) {
    800037b6:	eb05                	bnez	a4,800037e6 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800037b8:	74bc                	ld	a5,104(s1)
    800037ba:	70b8                	ld	a4,96(s1)
    800037bc:	f3b8                	sd	a4,96(a5)
    b->prev->next = b->next;
    800037be:	70bc                	ld	a5,96(s1)
    800037c0:	74b8                	ld	a4,104(s1)
    800037c2:	f7b8                	sd	a4,104(a5)
    b->next = bcache.head.next;
    800037c4:	00021797          	auipc	a5,0x21
    800037c8:	90478793          	addi	a5,a5,-1788 # 800240c8 <bcache+0x8000>
    800037cc:	5b87b703          	ld	a4,1464(a5)
    800037d0:	f4b8                	sd	a4,104(s1)
    b->prev = &bcache.head;
    800037d2:	00021717          	auipc	a4,0x21
    800037d6:	e4670713          	addi	a4,a4,-442 # 80024618 <bcache+0x8550>
    800037da:	f0b8                	sd	a4,96(s1)
    bcache.head.next->prev = b;
    800037dc:	5b87b703          	ld	a4,1464(a5)
    800037e0:	f324                	sd	s1,96(a4)
    bcache.head.next = b;
    800037e2:	5a97bc23          	sd	s1,1464(a5)
  }
  
  release(&bcache.lock);
    800037e6:	00019517          	auipc	a0,0x19
    800037ea:	8e250513          	addi	a0,a0,-1822 # 8001c0c8 <bcache>
    800037ee:	ffffd097          	auipc	ra,0xffffd
    800037f2:	6e6080e7          	jalr	1766(ra) # 80000ed4 <release>
}
    800037f6:	60e2                	ld	ra,24(sp)
    800037f8:	6442                	ld	s0,16(sp)
    800037fa:	64a2                	ld	s1,8(sp)
    800037fc:	6902                	ld	s2,0(sp)
    800037fe:	6105                	addi	sp,sp,32
    80003800:	8082                	ret
    panic("brelse");
    80003802:	00005517          	auipc	a0,0x5
    80003806:	27650513          	addi	a0,a0,630 # 80008a78 <userret+0x9e8>
    8000380a:	ffffd097          	auipc	ra,0xffffd
    8000380e:	f4c080e7          	jalr	-180(ra) # 80000756 <panic>

0000000080003812 <bpin>:

void
bpin(struct buf *b) {
    80003812:	1101                	addi	sp,sp,-32
    80003814:	ec06                	sd	ra,24(sp)
    80003816:	e822                	sd	s0,16(sp)
    80003818:	e426                	sd	s1,8(sp)
    8000381a:	1000                	addi	s0,sp,32
    8000381c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000381e:	00019517          	auipc	a0,0x19
    80003822:	8aa50513          	addi	a0,a0,-1878 # 8001c0c8 <bcache>
    80003826:	ffffd097          	auipc	ra,0xffffd
    8000382a:	462080e7          	jalr	1122(ra) # 80000c88 <acquire>
  b->refcnt++;
    8000382e:	4cbc                	lw	a5,88(s1)
    80003830:	2785                	addiw	a5,a5,1
    80003832:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    80003834:	00019517          	auipc	a0,0x19
    80003838:	89450513          	addi	a0,a0,-1900 # 8001c0c8 <bcache>
    8000383c:	ffffd097          	auipc	ra,0xffffd
    80003840:	698080e7          	jalr	1688(ra) # 80000ed4 <release>
}
    80003844:	60e2                	ld	ra,24(sp)
    80003846:	6442                	ld	s0,16(sp)
    80003848:	64a2                	ld	s1,8(sp)
    8000384a:	6105                	addi	sp,sp,32
    8000384c:	8082                	ret

000000008000384e <bunpin>:

void
bunpin(struct buf *b) {
    8000384e:	1101                	addi	sp,sp,-32
    80003850:	ec06                	sd	ra,24(sp)
    80003852:	e822                	sd	s0,16(sp)
    80003854:	e426                	sd	s1,8(sp)
    80003856:	1000                	addi	s0,sp,32
    80003858:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000385a:	00019517          	auipc	a0,0x19
    8000385e:	86e50513          	addi	a0,a0,-1938 # 8001c0c8 <bcache>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	426080e7          	jalr	1062(ra) # 80000c88 <acquire>
  b->refcnt--;
    8000386a:	4cbc                	lw	a5,88(s1)
    8000386c:	37fd                	addiw	a5,a5,-1
    8000386e:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    80003870:	00019517          	auipc	a0,0x19
    80003874:	85850513          	addi	a0,a0,-1960 # 8001c0c8 <bcache>
    80003878:	ffffd097          	auipc	ra,0xffffd
    8000387c:	65c080e7          	jalr	1628(ra) # 80000ed4 <release>
}
    80003880:	60e2                	ld	ra,24(sp)
    80003882:	6442                	ld	s0,16(sp)
    80003884:	64a2                	ld	s1,8(sp)
    80003886:	6105                	addi	sp,sp,32
    80003888:	8082                	ret

000000008000388a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000388a:	1101                	addi	sp,sp,-32
    8000388c:	ec06                	sd	ra,24(sp)
    8000388e:	e822                	sd	s0,16(sp)
    80003890:	e426                	sd	s1,8(sp)
    80003892:	e04a                	sd	s2,0(sp)
    80003894:	1000                	addi	s0,sp,32
    80003896:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003898:	00d5d59b          	srliw	a1,a1,0xd
    8000389c:	00021797          	auipc	a5,0x21
    800038a0:	2087a783          	lw	a5,520(a5) # 80024aa4 <sb+0x1c>
    800038a4:	9dbd                	addw	a1,a1,a5
    800038a6:	00000097          	auipc	ra,0x0
    800038aa:	d9a080e7          	jalr	-614(ra) # 80003640 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800038ae:	0074f713          	andi	a4,s1,7
    800038b2:	4785                	li	a5,1
    800038b4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800038b8:	14ce                	slli	s1,s1,0x33
    800038ba:	90d9                	srli	s1,s1,0x36
    800038bc:	00950733          	add	a4,a0,s1
    800038c0:	07074703          	lbu	a4,112(a4)
    800038c4:	00e7f6b3          	and	a3,a5,a4
    800038c8:	c69d                	beqz	a3,800038f6 <bfree+0x6c>
    800038ca:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800038cc:	94aa                	add	s1,s1,a0
    800038ce:	fff7c793          	not	a5,a5
    800038d2:	8ff9                	and	a5,a5,a4
    800038d4:	06f48823          	sb	a5,112(s1)
  log_write(bp);
    800038d8:	00001097          	auipc	ra,0x1
    800038dc:	188080e7          	jalr	392(ra) # 80004a60 <log_write>
  brelse(bp);
    800038e0:	854a                	mv	a0,s2
    800038e2:	00000097          	auipc	ra,0x0
    800038e6:	e92080e7          	jalr	-366(ra) # 80003774 <brelse>
}
    800038ea:	60e2                	ld	ra,24(sp)
    800038ec:	6442                	ld	s0,16(sp)
    800038ee:	64a2                	ld	s1,8(sp)
    800038f0:	6902                	ld	s2,0(sp)
    800038f2:	6105                	addi	sp,sp,32
    800038f4:	8082                	ret
    panic("freeing free block");
    800038f6:	00005517          	auipc	a0,0x5
    800038fa:	18a50513          	addi	a0,a0,394 # 80008a80 <userret+0x9f0>
    800038fe:	ffffd097          	auipc	ra,0xffffd
    80003902:	e58080e7          	jalr	-424(ra) # 80000756 <panic>

0000000080003906 <balloc>:
{
    80003906:	711d                	addi	sp,sp,-96
    80003908:	ec86                	sd	ra,88(sp)
    8000390a:	e8a2                	sd	s0,80(sp)
    8000390c:	e4a6                	sd	s1,72(sp)
    8000390e:	e0ca                	sd	s2,64(sp)
    80003910:	fc4e                	sd	s3,56(sp)
    80003912:	f852                	sd	s4,48(sp)
    80003914:	f456                	sd	s5,40(sp)
    80003916:	f05a                	sd	s6,32(sp)
    80003918:	ec5e                	sd	s7,24(sp)
    8000391a:	e862                	sd	s8,16(sp)
    8000391c:	e466                	sd	s9,8(sp)
    8000391e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003920:	00021797          	auipc	a5,0x21
    80003924:	16c7a783          	lw	a5,364(a5) # 80024a8c <sb+0x4>
    80003928:	cbd1                	beqz	a5,800039bc <balloc+0xb6>
    8000392a:	8baa                	mv	s7,a0
    8000392c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000392e:	00021b17          	auipc	s6,0x21
    80003932:	15ab0b13          	addi	s6,s6,346 # 80024a88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003936:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003938:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000393a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000393c:	6c89                	lui	s9,0x2
    8000393e:	a831                	j	8000395a <balloc+0x54>
    brelse(bp);
    80003940:	854a                	mv	a0,s2
    80003942:	00000097          	auipc	ra,0x0
    80003946:	e32080e7          	jalr	-462(ra) # 80003774 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000394a:	015c87bb          	addw	a5,s9,s5
    8000394e:	00078a9b          	sext.w	s5,a5
    80003952:	004b2703          	lw	a4,4(s6)
    80003956:	06eaf363          	bgeu	s5,a4,800039bc <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000395a:	41fad79b          	sraiw	a5,s5,0x1f
    8000395e:	0137d79b          	srliw	a5,a5,0x13
    80003962:	015787bb          	addw	a5,a5,s5
    80003966:	40d7d79b          	sraiw	a5,a5,0xd
    8000396a:	01cb2583          	lw	a1,28(s6)
    8000396e:	9dbd                	addw	a1,a1,a5
    80003970:	855e                	mv	a0,s7
    80003972:	00000097          	auipc	ra,0x0
    80003976:	cce080e7          	jalr	-818(ra) # 80003640 <bread>
    8000397a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000397c:	004b2503          	lw	a0,4(s6)
    80003980:	000a849b          	sext.w	s1,s5
    80003984:	8662                	mv	a2,s8
    80003986:	faa4fde3          	bgeu	s1,a0,80003940 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000398a:	41f6579b          	sraiw	a5,a2,0x1f
    8000398e:	01d7d69b          	srliw	a3,a5,0x1d
    80003992:	00c6873b          	addw	a4,a3,a2
    80003996:	00777793          	andi	a5,a4,7
    8000399a:	9f95                	subw	a5,a5,a3
    8000399c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800039a0:	4037571b          	sraiw	a4,a4,0x3
    800039a4:	00e906b3          	add	a3,s2,a4
    800039a8:	0706c683          	lbu	a3,112(a3)
    800039ac:	00d7f5b3          	and	a1,a5,a3
    800039b0:	cd91                	beqz	a1,800039cc <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039b2:	2605                	addiw	a2,a2,1
    800039b4:	2485                	addiw	s1,s1,1
    800039b6:	fd4618e3          	bne	a2,s4,80003986 <balloc+0x80>
    800039ba:	b759                	j	80003940 <balloc+0x3a>
  panic("balloc: out of blocks");
    800039bc:	00005517          	auipc	a0,0x5
    800039c0:	0dc50513          	addi	a0,a0,220 # 80008a98 <userret+0xa08>
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	d92080e7          	jalr	-622(ra) # 80000756 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800039cc:	974a                	add	a4,a4,s2
    800039ce:	8fd5                	or	a5,a5,a3
    800039d0:	06f70823          	sb	a5,112(a4)
        log_write(bp);
    800039d4:	854a                	mv	a0,s2
    800039d6:	00001097          	auipc	ra,0x1
    800039da:	08a080e7          	jalr	138(ra) # 80004a60 <log_write>
        brelse(bp);
    800039de:	854a                	mv	a0,s2
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	d94080e7          	jalr	-620(ra) # 80003774 <brelse>
  bp = bread(dev, bno);
    800039e8:	85a6                	mv	a1,s1
    800039ea:	855e                	mv	a0,s7
    800039ec:	00000097          	auipc	ra,0x0
    800039f0:	c54080e7          	jalr	-940(ra) # 80003640 <bread>
    800039f4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800039f6:	40000613          	li	a2,1024
    800039fa:	4581                	li	a1,0
    800039fc:	07050513          	addi	a0,a0,112
    80003a00:	ffffd097          	auipc	ra,0xffffd
    80003a04:	6d4080e7          	jalr	1748(ra) # 800010d4 <memset>
  log_write(bp);
    80003a08:	854a                	mv	a0,s2
    80003a0a:	00001097          	auipc	ra,0x1
    80003a0e:	056080e7          	jalr	86(ra) # 80004a60 <log_write>
  brelse(bp);
    80003a12:	854a                	mv	a0,s2
    80003a14:	00000097          	auipc	ra,0x0
    80003a18:	d60080e7          	jalr	-672(ra) # 80003774 <brelse>
}
    80003a1c:	8526                	mv	a0,s1
    80003a1e:	60e6                	ld	ra,88(sp)
    80003a20:	6446                	ld	s0,80(sp)
    80003a22:	64a6                	ld	s1,72(sp)
    80003a24:	6906                	ld	s2,64(sp)
    80003a26:	79e2                	ld	s3,56(sp)
    80003a28:	7a42                	ld	s4,48(sp)
    80003a2a:	7aa2                	ld	s5,40(sp)
    80003a2c:	7b02                	ld	s6,32(sp)
    80003a2e:	6be2                	ld	s7,24(sp)
    80003a30:	6c42                	ld	s8,16(sp)
    80003a32:	6ca2                	ld	s9,8(sp)
    80003a34:	6125                	addi	sp,sp,96
    80003a36:	8082                	ret

0000000080003a38 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a38:	7179                	addi	sp,sp,-48
    80003a3a:	f406                	sd	ra,40(sp)
    80003a3c:	f022                	sd	s0,32(sp)
    80003a3e:	ec26                	sd	s1,24(sp)
    80003a40:	e84a                	sd	s2,16(sp)
    80003a42:	e44e                	sd	s3,8(sp)
    80003a44:	e052                	sd	s4,0(sp)
    80003a46:	1800                	addi	s0,sp,48
    80003a48:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003a4a:	47ad                	li	a5,11
    80003a4c:	04b7fe63          	bgeu	a5,a1,80003aa8 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003a50:	ff45849b          	addiw	s1,a1,-12
    80003a54:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003a58:	0ff00793          	li	a5,255
    80003a5c:	0ae7e363          	bltu	a5,a4,80003b02 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003a60:	09852583          	lw	a1,152(a0)
    80003a64:	c5ad                	beqz	a1,80003ace <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003a66:	00092503          	lw	a0,0(s2)
    80003a6a:	00000097          	auipc	ra,0x0
    80003a6e:	bd6080e7          	jalr	-1066(ra) # 80003640 <bread>
    80003a72:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a74:	07050793          	addi	a5,a0,112
    if((addr = a[bn]) == 0){
    80003a78:	02049593          	slli	a1,s1,0x20
    80003a7c:	9181                	srli	a1,a1,0x20
    80003a7e:	058a                	slli	a1,a1,0x2
    80003a80:	00b784b3          	add	s1,a5,a1
    80003a84:	0004a983          	lw	s3,0(s1)
    80003a88:	04098d63          	beqz	s3,80003ae2 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003a8c:	8552                	mv	a0,s4
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	ce6080e7          	jalr	-794(ra) # 80003774 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003a96:	854e                	mv	a0,s3
    80003a98:	70a2                	ld	ra,40(sp)
    80003a9a:	7402                	ld	s0,32(sp)
    80003a9c:	64e2                	ld	s1,24(sp)
    80003a9e:	6942                	ld	s2,16(sp)
    80003aa0:	69a2                	ld	s3,8(sp)
    80003aa2:	6a02                	ld	s4,0(sp)
    80003aa4:	6145                	addi	sp,sp,48
    80003aa6:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003aa8:	02059493          	slli	s1,a1,0x20
    80003aac:	9081                	srli	s1,s1,0x20
    80003aae:	048a                	slli	s1,s1,0x2
    80003ab0:	94aa                	add	s1,s1,a0
    80003ab2:	0684a983          	lw	s3,104(s1)
    80003ab6:	fe0990e3          	bnez	s3,80003a96 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003aba:	4108                	lw	a0,0(a0)
    80003abc:	00000097          	auipc	ra,0x0
    80003ac0:	e4a080e7          	jalr	-438(ra) # 80003906 <balloc>
    80003ac4:	0005099b          	sext.w	s3,a0
    80003ac8:	0734a423          	sw	s3,104(s1)
    80003acc:	b7e9                	j	80003a96 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003ace:	4108                	lw	a0,0(a0)
    80003ad0:	00000097          	auipc	ra,0x0
    80003ad4:	e36080e7          	jalr	-458(ra) # 80003906 <balloc>
    80003ad8:	0005059b          	sext.w	a1,a0
    80003adc:	08b92c23          	sw	a1,152(s2)
    80003ae0:	b759                	j	80003a66 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003ae2:	00092503          	lw	a0,0(s2)
    80003ae6:	00000097          	auipc	ra,0x0
    80003aea:	e20080e7          	jalr	-480(ra) # 80003906 <balloc>
    80003aee:	0005099b          	sext.w	s3,a0
    80003af2:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003af6:	8552                	mv	a0,s4
    80003af8:	00001097          	auipc	ra,0x1
    80003afc:	f68080e7          	jalr	-152(ra) # 80004a60 <log_write>
    80003b00:	b771                	j	80003a8c <bmap+0x54>
  panic("bmap: out of range");
    80003b02:	00005517          	auipc	a0,0x5
    80003b06:	fae50513          	addi	a0,a0,-82 # 80008ab0 <userret+0xa20>
    80003b0a:	ffffd097          	auipc	ra,0xffffd
    80003b0e:	c4c080e7          	jalr	-948(ra) # 80000756 <panic>

0000000080003b12 <iget>:
{
    80003b12:	7179                	addi	sp,sp,-48
    80003b14:	f406                	sd	ra,40(sp)
    80003b16:	f022                	sd	s0,32(sp)
    80003b18:	ec26                	sd	s1,24(sp)
    80003b1a:	e84a                	sd	s2,16(sp)
    80003b1c:	e44e                	sd	s3,8(sp)
    80003b1e:	e052                	sd	s4,0(sp)
    80003b20:	1800                	addi	s0,sp,48
    80003b22:	89aa                	mv	s3,a0
    80003b24:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003b26:	00021517          	auipc	a0,0x21
    80003b2a:	f8250513          	addi	a0,a0,-126 # 80024aa8 <icache>
    80003b2e:	ffffd097          	auipc	ra,0xffffd
    80003b32:	15a080e7          	jalr	346(ra) # 80000c88 <acquire>
  empty = 0;
    80003b36:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003b38:	00021497          	auipc	s1,0x21
    80003b3c:	fa048493          	addi	s1,s1,-96 # 80024ad8 <icache+0x30>
    80003b40:	00023697          	auipc	a3,0x23
    80003b44:	ed868693          	addi	a3,a3,-296 # 80026a18 <log>
    80003b48:	a039                	j	80003b56 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b4a:	02090b63          	beqz	s2,80003b80 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003b4e:	0a048493          	addi	s1,s1,160
    80003b52:	02d48a63          	beq	s1,a3,80003b86 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003b56:	449c                	lw	a5,8(s1)
    80003b58:	fef059e3          	blez	a5,80003b4a <iget+0x38>
    80003b5c:	4098                	lw	a4,0(s1)
    80003b5e:	ff3716e3          	bne	a4,s3,80003b4a <iget+0x38>
    80003b62:	40d8                	lw	a4,4(s1)
    80003b64:	ff4713e3          	bne	a4,s4,80003b4a <iget+0x38>
      ip->ref++;
    80003b68:	2785                	addiw	a5,a5,1
    80003b6a:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003b6c:	00021517          	auipc	a0,0x21
    80003b70:	f3c50513          	addi	a0,a0,-196 # 80024aa8 <icache>
    80003b74:	ffffd097          	auipc	ra,0xffffd
    80003b78:	360080e7          	jalr	864(ra) # 80000ed4 <release>
      return ip;
    80003b7c:	8926                	mv	s2,s1
    80003b7e:	a03d                	j	80003bac <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b80:	f7f9                	bnez	a5,80003b4e <iget+0x3c>
    80003b82:	8926                	mv	s2,s1
    80003b84:	b7e9                	j	80003b4e <iget+0x3c>
  if(empty == 0)
    80003b86:	02090c63          	beqz	s2,80003bbe <iget+0xac>
  ip->dev = dev;
    80003b8a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b8e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b92:	4785                	li	a5,1
    80003b94:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b98:	04092c23          	sw	zero,88(s2)
  release(&icache.lock);
    80003b9c:	00021517          	auipc	a0,0x21
    80003ba0:	f0c50513          	addi	a0,a0,-244 # 80024aa8 <icache>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	330080e7          	jalr	816(ra) # 80000ed4 <release>
}
    80003bac:	854a                	mv	a0,s2
    80003bae:	70a2                	ld	ra,40(sp)
    80003bb0:	7402                	ld	s0,32(sp)
    80003bb2:	64e2                	ld	s1,24(sp)
    80003bb4:	6942                	ld	s2,16(sp)
    80003bb6:	69a2                	ld	s3,8(sp)
    80003bb8:	6a02                	ld	s4,0(sp)
    80003bba:	6145                	addi	sp,sp,48
    80003bbc:	8082                	ret
    panic("iget: no inodes");
    80003bbe:	00005517          	auipc	a0,0x5
    80003bc2:	f0a50513          	addi	a0,a0,-246 # 80008ac8 <userret+0xa38>
    80003bc6:	ffffd097          	auipc	ra,0xffffd
    80003bca:	b90080e7          	jalr	-1136(ra) # 80000756 <panic>

0000000080003bce <fsinit>:
fsinit(int dev) {
    80003bce:	7179                	addi	sp,sp,-48
    80003bd0:	f406                	sd	ra,40(sp)
    80003bd2:	f022                	sd	s0,32(sp)
    80003bd4:	ec26                	sd	s1,24(sp)
    80003bd6:	e84a                	sd	s2,16(sp)
    80003bd8:	e44e                	sd	s3,8(sp)
    80003bda:	1800                	addi	s0,sp,48
    80003bdc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003bde:	4585                	li	a1,1
    80003be0:	00000097          	auipc	ra,0x0
    80003be4:	a60080e7          	jalr	-1440(ra) # 80003640 <bread>
    80003be8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003bea:	00021997          	auipc	s3,0x21
    80003bee:	e9e98993          	addi	s3,s3,-354 # 80024a88 <sb>
    80003bf2:	02000613          	li	a2,32
    80003bf6:	07050593          	addi	a1,a0,112
    80003bfa:	854e                	mv	a0,s3
    80003bfc:	ffffd097          	auipc	ra,0xffffd
    80003c00:	538080e7          	jalr	1336(ra) # 80001134 <memmove>
  brelse(bp);
    80003c04:	8526                	mv	a0,s1
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	b6e080e7          	jalr	-1170(ra) # 80003774 <brelse>
  if(sb.magic != FSMAGIC)
    80003c0e:	0009a703          	lw	a4,0(s3)
    80003c12:	102037b7          	lui	a5,0x10203
    80003c16:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c1a:	02f71263          	bne	a4,a5,80003c3e <fsinit+0x70>
  initlog(dev, &sb);
    80003c1e:	00021597          	auipc	a1,0x21
    80003c22:	e6a58593          	addi	a1,a1,-406 # 80024a88 <sb>
    80003c26:	854a                	mv	a0,s2
    80003c28:	00001097          	auipc	ra,0x1
    80003c2c:	b22080e7          	jalr	-1246(ra) # 8000474a <initlog>
}
    80003c30:	70a2                	ld	ra,40(sp)
    80003c32:	7402                	ld	s0,32(sp)
    80003c34:	64e2                	ld	s1,24(sp)
    80003c36:	6942                	ld	s2,16(sp)
    80003c38:	69a2                	ld	s3,8(sp)
    80003c3a:	6145                	addi	sp,sp,48
    80003c3c:	8082                	ret
    panic("invalid file system");
    80003c3e:	00005517          	auipc	a0,0x5
    80003c42:	e9a50513          	addi	a0,a0,-358 # 80008ad8 <userret+0xa48>
    80003c46:	ffffd097          	auipc	ra,0xffffd
    80003c4a:	b10080e7          	jalr	-1264(ra) # 80000756 <panic>

0000000080003c4e <iinit>:
{
    80003c4e:	7179                	addi	sp,sp,-48
    80003c50:	f406                	sd	ra,40(sp)
    80003c52:	f022                	sd	s0,32(sp)
    80003c54:	ec26                	sd	s1,24(sp)
    80003c56:	e84a                	sd	s2,16(sp)
    80003c58:	e44e                	sd	s3,8(sp)
    80003c5a:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003c5c:	00005597          	auipc	a1,0x5
    80003c60:	e9458593          	addi	a1,a1,-364 # 80008af0 <userret+0xa60>
    80003c64:	00021517          	auipc	a0,0x21
    80003c68:	e4450513          	addi	a0,a0,-444 # 80024aa8 <icache>
    80003c6c:	ffffd097          	auipc	ra,0xffffd
    80003c70:	eb2080e7          	jalr	-334(ra) # 80000b1e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003c74:	00021497          	auipc	s1,0x21
    80003c78:	e7448493          	addi	s1,s1,-396 # 80024ae8 <icache+0x40>
    80003c7c:	00023997          	auipc	s3,0x23
    80003c80:	dac98993          	addi	s3,s3,-596 # 80026a28 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003c84:	00005917          	auipc	s2,0x5
    80003c88:	e7490913          	addi	s2,s2,-396 # 80008af8 <userret+0xa68>
    80003c8c:	85ca                	mv	a1,s2
    80003c8e:	8526                	mv	a0,s1
    80003c90:	00001097          	auipc	ra,0x1
    80003c94:	f02080e7          	jalr	-254(ra) # 80004b92 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c98:	0a048493          	addi	s1,s1,160
    80003c9c:	ff3498e3          	bne	s1,s3,80003c8c <iinit+0x3e>
}
    80003ca0:	70a2                	ld	ra,40(sp)
    80003ca2:	7402                	ld	s0,32(sp)
    80003ca4:	64e2                	ld	s1,24(sp)
    80003ca6:	6942                	ld	s2,16(sp)
    80003ca8:	69a2                	ld	s3,8(sp)
    80003caa:	6145                	addi	sp,sp,48
    80003cac:	8082                	ret

0000000080003cae <ialloc>:
{
    80003cae:	715d                	addi	sp,sp,-80
    80003cb0:	e486                	sd	ra,72(sp)
    80003cb2:	e0a2                	sd	s0,64(sp)
    80003cb4:	fc26                	sd	s1,56(sp)
    80003cb6:	f84a                	sd	s2,48(sp)
    80003cb8:	f44e                	sd	s3,40(sp)
    80003cba:	f052                	sd	s4,32(sp)
    80003cbc:	ec56                	sd	s5,24(sp)
    80003cbe:	e85a                	sd	s6,16(sp)
    80003cc0:	e45e                	sd	s7,8(sp)
    80003cc2:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003cc4:	00021717          	auipc	a4,0x21
    80003cc8:	dd072703          	lw	a4,-560(a4) # 80024a94 <sb+0xc>
    80003ccc:	4785                	li	a5,1
    80003cce:	04e7fa63          	bgeu	a5,a4,80003d22 <ialloc+0x74>
    80003cd2:	8aaa                	mv	s5,a0
    80003cd4:	8bae                	mv	s7,a1
    80003cd6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003cd8:	00021a17          	auipc	s4,0x21
    80003cdc:	db0a0a13          	addi	s4,s4,-592 # 80024a88 <sb>
    80003ce0:	00048b1b          	sext.w	s6,s1
    80003ce4:	0044d593          	srli	a1,s1,0x4
    80003ce8:	018a2783          	lw	a5,24(s4)
    80003cec:	9dbd                	addw	a1,a1,a5
    80003cee:	8556                	mv	a0,s5
    80003cf0:	00000097          	auipc	ra,0x0
    80003cf4:	950080e7          	jalr	-1712(ra) # 80003640 <bread>
    80003cf8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003cfa:	07050993          	addi	s3,a0,112
    80003cfe:	00f4f793          	andi	a5,s1,15
    80003d02:	079a                	slli	a5,a5,0x6
    80003d04:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d06:	00099783          	lh	a5,0(s3)
    80003d0a:	c785                	beqz	a5,80003d32 <ialloc+0x84>
    brelse(bp);
    80003d0c:	00000097          	auipc	ra,0x0
    80003d10:	a68080e7          	jalr	-1432(ra) # 80003774 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d14:	0485                	addi	s1,s1,1
    80003d16:	00ca2703          	lw	a4,12(s4)
    80003d1a:	0004879b          	sext.w	a5,s1
    80003d1e:	fce7e1e3          	bltu	a5,a4,80003ce0 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003d22:	00005517          	auipc	a0,0x5
    80003d26:	dde50513          	addi	a0,a0,-546 # 80008b00 <userret+0xa70>
    80003d2a:	ffffd097          	auipc	ra,0xffffd
    80003d2e:	a2c080e7          	jalr	-1492(ra) # 80000756 <panic>
      memset(dip, 0, sizeof(*dip));
    80003d32:	04000613          	li	a2,64
    80003d36:	4581                	li	a1,0
    80003d38:	854e                	mv	a0,s3
    80003d3a:	ffffd097          	auipc	ra,0xffffd
    80003d3e:	39a080e7          	jalr	922(ra) # 800010d4 <memset>
      dip->type = type;
    80003d42:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003d46:	854a                	mv	a0,s2
    80003d48:	00001097          	auipc	ra,0x1
    80003d4c:	d18080e7          	jalr	-744(ra) # 80004a60 <log_write>
      brelse(bp);
    80003d50:	854a                	mv	a0,s2
    80003d52:	00000097          	auipc	ra,0x0
    80003d56:	a22080e7          	jalr	-1502(ra) # 80003774 <brelse>
      return iget(dev, inum);
    80003d5a:	85da                	mv	a1,s6
    80003d5c:	8556                	mv	a0,s5
    80003d5e:	00000097          	auipc	ra,0x0
    80003d62:	db4080e7          	jalr	-588(ra) # 80003b12 <iget>
}
    80003d66:	60a6                	ld	ra,72(sp)
    80003d68:	6406                	ld	s0,64(sp)
    80003d6a:	74e2                	ld	s1,56(sp)
    80003d6c:	7942                	ld	s2,48(sp)
    80003d6e:	79a2                	ld	s3,40(sp)
    80003d70:	7a02                	ld	s4,32(sp)
    80003d72:	6ae2                	ld	s5,24(sp)
    80003d74:	6b42                	ld	s6,16(sp)
    80003d76:	6ba2                	ld	s7,8(sp)
    80003d78:	6161                	addi	sp,sp,80
    80003d7a:	8082                	ret

0000000080003d7c <iupdate>:
{
    80003d7c:	1101                	addi	sp,sp,-32
    80003d7e:	ec06                	sd	ra,24(sp)
    80003d80:	e822                	sd	s0,16(sp)
    80003d82:	e426                	sd	s1,8(sp)
    80003d84:	e04a                	sd	s2,0(sp)
    80003d86:	1000                	addi	s0,sp,32
    80003d88:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d8a:	415c                	lw	a5,4(a0)
    80003d8c:	0047d79b          	srliw	a5,a5,0x4
    80003d90:	00021597          	auipc	a1,0x21
    80003d94:	d105a583          	lw	a1,-752(a1) # 80024aa0 <sb+0x18>
    80003d98:	9dbd                	addw	a1,a1,a5
    80003d9a:	4108                	lw	a0,0(a0)
    80003d9c:	00000097          	auipc	ra,0x0
    80003da0:	8a4080e7          	jalr	-1884(ra) # 80003640 <bread>
    80003da4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003da6:	07050793          	addi	a5,a0,112
    80003daa:	40c8                	lw	a0,4(s1)
    80003dac:	893d                	andi	a0,a0,15
    80003dae:	051a                	slli	a0,a0,0x6
    80003db0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003db2:	05c49703          	lh	a4,92(s1)
    80003db6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003dba:	05e49703          	lh	a4,94(s1)
    80003dbe:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003dc2:	06049703          	lh	a4,96(s1)
    80003dc6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003dca:	06249703          	lh	a4,98(s1)
    80003dce:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003dd2:	50f8                	lw	a4,100(s1)
    80003dd4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003dd6:	03400613          	li	a2,52
    80003dda:	06848593          	addi	a1,s1,104
    80003dde:	0531                	addi	a0,a0,12
    80003de0:	ffffd097          	auipc	ra,0xffffd
    80003de4:	354080e7          	jalr	852(ra) # 80001134 <memmove>
  log_write(bp);
    80003de8:	854a                	mv	a0,s2
    80003dea:	00001097          	auipc	ra,0x1
    80003dee:	c76080e7          	jalr	-906(ra) # 80004a60 <log_write>
  brelse(bp);
    80003df2:	854a                	mv	a0,s2
    80003df4:	00000097          	auipc	ra,0x0
    80003df8:	980080e7          	jalr	-1664(ra) # 80003774 <brelse>
}
    80003dfc:	60e2                	ld	ra,24(sp)
    80003dfe:	6442                	ld	s0,16(sp)
    80003e00:	64a2                	ld	s1,8(sp)
    80003e02:	6902                	ld	s2,0(sp)
    80003e04:	6105                	addi	sp,sp,32
    80003e06:	8082                	ret

0000000080003e08 <idup>:
{
    80003e08:	1101                	addi	sp,sp,-32
    80003e0a:	ec06                	sd	ra,24(sp)
    80003e0c:	e822                	sd	s0,16(sp)
    80003e0e:	e426                	sd	s1,8(sp)
    80003e10:	1000                	addi	s0,sp,32
    80003e12:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003e14:	00021517          	auipc	a0,0x21
    80003e18:	c9450513          	addi	a0,a0,-876 # 80024aa8 <icache>
    80003e1c:	ffffd097          	auipc	ra,0xffffd
    80003e20:	e6c080e7          	jalr	-404(ra) # 80000c88 <acquire>
  ip->ref++;
    80003e24:	449c                	lw	a5,8(s1)
    80003e26:	2785                	addiw	a5,a5,1
    80003e28:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003e2a:	00021517          	auipc	a0,0x21
    80003e2e:	c7e50513          	addi	a0,a0,-898 # 80024aa8 <icache>
    80003e32:	ffffd097          	auipc	ra,0xffffd
    80003e36:	0a2080e7          	jalr	162(ra) # 80000ed4 <release>
}
    80003e3a:	8526                	mv	a0,s1
    80003e3c:	60e2                	ld	ra,24(sp)
    80003e3e:	6442                	ld	s0,16(sp)
    80003e40:	64a2                	ld	s1,8(sp)
    80003e42:	6105                	addi	sp,sp,32
    80003e44:	8082                	ret

0000000080003e46 <ilock>:
{
    80003e46:	1101                	addi	sp,sp,-32
    80003e48:	ec06                	sd	ra,24(sp)
    80003e4a:	e822                	sd	s0,16(sp)
    80003e4c:	e426                	sd	s1,8(sp)
    80003e4e:	e04a                	sd	s2,0(sp)
    80003e50:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003e52:	c115                	beqz	a0,80003e76 <ilock+0x30>
    80003e54:	84aa                	mv	s1,a0
    80003e56:	451c                	lw	a5,8(a0)
    80003e58:	00f05f63          	blez	a5,80003e76 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003e5c:	0541                	addi	a0,a0,16
    80003e5e:	00001097          	auipc	ra,0x1
    80003e62:	d6e080e7          	jalr	-658(ra) # 80004bcc <acquiresleep>
  if(ip->valid == 0){
    80003e66:	4cbc                	lw	a5,88(s1)
    80003e68:	cf99                	beqz	a5,80003e86 <ilock+0x40>
}
    80003e6a:	60e2                	ld	ra,24(sp)
    80003e6c:	6442                	ld	s0,16(sp)
    80003e6e:	64a2                	ld	s1,8(sp)
    80003e70:	6902                	ld	s2,0(sp)
    80003e72:	6105                	addi	sp,sp,32
    80003e74:	8082                	ret
    panic("ilock");
    80003e76:	00005517          	auipc	a0,0x5
    80003e7a:	ca250513          	addi	a0,a0,-862 # 80008b18 <userret+0xa88>
    80003e7e:	ffffd097          	auipc	ra,0xffffd
    80003e82:	8d8080e7          	jalr	-1832(ra) # 80000756 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e86:	40dc                	lw	a5,4(s1)
    80003e88:	0047d79b          	srliw	a5,a5,0x4
    80003e8c:	00021597          	auipc	a1,0x21
    80003e90:	c145a583          	lw	a1,-1004(a1) # 80024aa0 <sb+0x18>
    80003e94:	9dbd                	addw	a1,a1,a5
    80003e96:	4088                	lw	a0,0(s1)
    80003e98:	fffff097          	auipc	ra,0xfffff
    80003e9c:	7a8080e7          	jalr	1960(ra) # 80003640 <bread>
    80003ea0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ea2:	07050593          	addi	a1,a0,112
    80003ea6:	40dc                	lw	a5,4(s1)
    80003ea8:	8bbd                	andi	a5,a5,15
    80003eaa:	079a                	slli	a5,a5,0x6
    80003eac:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003eae:	00059783          	lh	a5,0(a1)
    80003eb2:	04f49e23          	sh	a5,92(s1)
    ip->major = dip->major;
    80003eb6:	00259783          	lh	a5,2(a1)
    80003eba:	04f49f23          	sh	a5,94(s1)
    ip->minor = dip->minor;
    80003ebe:	00459783          	lh	a5,4(a1)
    80003ec2:	06f49023          	sh	a5,96(s1)
    ip->nlink = dip->nlink;
    80003ec6:	00659783          	lh	a5,6(a1)
    80003eca:	06f49123          	sh	a5,98(s1)
    ip->size = dip->size;
    80003ece:	459c                	lw	a5,8(a1)
    80003ed0:	d0fc                	sw	a5,100(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ed2:	03400613          	li	a2,52
    80003ed6:	05b1                	addi	a1,a1,12
    80003ed8:	06848513          	addi	a0,s1,104
    80003edc:	ffffd097          	auipc	ra,0xffffd
    80003ee0:	258080e7          	jalr	600(ra) # 80001134 <memmove>
    brelse(bp);
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	00000097          	auipc	ra,0x0
    80003eea:	88e080e7          	jalr	-1906(ra) # 80003774 <brelse>
    ip->valid = 1;
    80003eee:	4785                	li	a5,1
    80003ef0:	ccbc                	sw	a5,88(s1)
    if(ip->type == 0)
    80003ef2:	05c49783          	lh	a5,92(s1)
    80003ef6:	fbb5                	bnez	a5,80003e6a <ilock+0x24>
      panic("ilock: no type");
    80003ef8:	00005517          	auipc	a0,0x5
    80003efc:	c2850513          	addi	a0,a0,-984 # 80008b20 <userret+0xa90>
    80003f00:	ffffd097          	auipc	ra,0xffffd
    80003f04:	856080e7          	jalr	-1962(ra) # 80000756 <panic>

0000000080003f08 <iunlock>:
{
    80003f08:	1101                	addi	sp,sp,-32
    80003f0a:	ec06                	sd	ra,24(sp)
    80003f0c:	e822                	sd	s0,16(sp)
    80003f0e:	e426                	sd	s1,8(sp)
    80003f10:	e04a                	sd	s2,0(sp)
    80003f12:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f14:	c905                	beqz	a0,80003f44 <iunlock+0x3c>
    80003f16:	84aa                	mv	s1,a0
    80003f18:	01050913          	addi	s2,a0,16
    80003f1c:	854a                	mv	a0,s2
    80003f1e:	00001097          	auipc	ra,0x1
    80003f22:	d48080e7          	jalr	-696(ra) # 80004c66 <holdingsleep>
    80003f26:	cd19                	beqz	a0,80003f44 <iunlock+0x3c>
    80003f28:	449c                	lw	a5,8(s1)
    80003f2a:	00f05d63          	blez	a5,80003f44 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f2e:	854a                	mv	a0,s2
    80003f30:	00001097          	auipc	ra,0x1
    80003f34:	cf2080e7          	jalr	-782(ra) # 80004c22 <releasesleep>
}
    80003f38:	60e2                	ld	ra,24(sp)
    80003f3a:	6442                	ld	s0,16(sp)
    80003f3c:	64a2                	ld	s1,8(sp)
    80003f3e:	6902                	ld	s2,0(sp)
    80003f40:	6105                	addi	sp,sp,32
    80003f42:	8082                	ret
    panic("iunlock");
    80003f44:	00005517          	auipc	a0,0x5
    80003f48:	bec50513          	addi	a0,a0,-1044 # 80008b30 <userret+0xaa0>
    80003f4c:	ffffd097          	auipc	ra,0xffffd
    80003f50:	80a080e7          	jalr	-2038(ra) # 80000756 <panic>

0000000080003f54 <iput>:
{
    80003f54:	7139                	addi	sp,sp,-64
    80003f56:	fc06                	sd	ra,56(sp)
    80003f58:	f822                	sd	s0,48(sp)
    80003f5a:	f426                	sd	s1,40(sp)
    80003f5c:	f04a                	sd	s2,32(sp)
    80003f5e:	ec4e                	sd	s3,24(sp)
    80003f60:	e852                	sd	s4,16(sp)
    80003f62:	e456                	sd	s5,8(sp)
    80003f64:	0080                	addi	s0,sp,64
    80003f66:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003f68:	00021517          	auipc	a0,0x21
    80003f6c:	b4050513          	addi	a0,a0,-1216 # 80024aa8 <icache>
    80003f70:	ffffd097          	auipc	ra,0xffffd
    80003f74:	d18080e7          	jalr	-744(ra) # 80000c88 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f78:	4498                	lw	a4,8(s1)
    80003f7a:	4785                	li	a5,1
    80003f7c:	02f70663          	beq	a4,a5,80003fa8 <iput+0x54>
  ip->ref--;
    80003f80:	449c                	lw	a5,8(s1)
    80003f82:	37fd                	addiw	a5,a5,-1
    80003f84:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003f86:	00021517          	auipc	a0,0x21
    80003f8a:	b2250513          	addi	a0,a0,-1246 # 80024aa8 <icache>
    80003f8e:	ffffd097          	auipc	ra,0xffffd
    80003f92:	f46080e7          	jalr	-186(ra) # 80000ed4 <release>
}
    80003f96:	70e2                	ld	ra,56(sp)
    80003f98:	7442                	ld	s0,48(sp)
    80003f9a:	74a2                	ld	s1,40(sp)
    80003f9c:	7902                	ld	s2,32(sp)
    80003f9e:	69e2                	ld	s3,24(sp)
    80003fa0:	6a42                	ld	s4,16(sp)
    80003fa2:	6aa2                	ld	s5,8(sp)
    80003fa4:	6121                	addi	sp,sp,64
    80003fa6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fa8:	4cbc                	lw	a5,88(s1)
    80003faa:	dbf9                	beqz	a5,80003f80 <iput+0x2c>
    80003fac:	06249783          	lh	a5,98(s1)
    80003fb0:	fbe1                	bnez	a5,80003f80 <iput+0x2c>
    acquiresleep(&ip->lock);
    80003fb2:	01048a13          	addi	s4,s1,16
    80003fb6:	8552                	mv	a0,s4
    80003fb8:	00001097          	auipc	ra,0x1
    80003fbc:	c14080e7          	jalr	-1004(ra) # 80004bcc <acquiresleep>
    release(&icache.lock);
    80003fc0:	00021517          	auipc	a0,0x21
    80003fc4:	ae850513          	addi	a0,a0,-1304 # 80024aa8 <icache>
    80003fc8:	ffffd097          	auipc	ra,0xffffd
    80003fcc:	f0c080e7          	jalr	-244(ra) # 80000ed4 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003fd0:	06848913          	addi	s2,s1,104
    80003fd4:	09848993          	addi	s3,s1,152
    80003fd8:	a819                	j	80003fee <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003fda:	4088                	lw	a0,0(s1)
    80003fdc:	00000097          	auipc	ra,0x0
    80003fe0:	8ae080e7          	jalr	-1874(ra) # 8000388a <bfree>
      ip->addrs[i] = 0;
    80003fe4:	00092023          	sw	zero,0(s2)
  for(i = 0; i < NDIRECT; i++){
    80003fe8:	0911                	addi	s2,s2,4
    80003fea:	01390663          	beq	s2,s3,80003ff6 <iput+0xa2>
    if(ip->addrs[i]){
    80003fee:	00092583          	lw	a1,0(s2)
    80003ff2:	d9fd                	beqz	a1,80003fe8 <iput+0x94>
    80003ff4:	b7dd                	j	80003fda <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ff6:	0984a583          	lw	a1,152(s1)
    80003ffa:	ed9d                	bnez	a1,80004038 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ffc:	0604a223          	sw	zero,100(s1)
  iupdate(ip);
    80004000:	8526                	mv	a0,s1
    80004002:	00000097          	auipc	ra,0x0
    80004006:	d7a080e7          	jalr	-646(ra) # 80003d7c <iupdate>
    ip->type = 0;
    8000400a:	04049e23          	sh	zero,92(s1)
    iupdate(ip);
    8000400e:	8526                	mv	a0,s1
    80004010:	00000097          	auipc	ra,0x0
    80004014:	d6c080e7          	jalr	-660(ra) # 80003d7c <iupdate>
    ip->valid = 0;
    80004018:	0404ac23          	sw	zero,88(s1)
    releasesleep(&ip->lock);
    8000401c:	8552                	mv	a0,s4
    8000401e:	00001097          	auipc	ra,0x1
    80004022:	c04080e7          	jalr	-1020(ra) # 80004c22 <releasesleep>
    acquire(&icache.lock);
    80004026:	00021517          	auipc	a0,0x21
    8000402a:	a8250513          	addi	a0,a0,-1406 # 80024aa8 <icache>
    8000402e:	ffffd097          	auipc	ra,0xffffd
    80004032:	c5a080e7          	jalr	-934(ra) # 80000c88 <acquire>
    80004036:	b7a9                	j	80003f80 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004038:	4088                	lw	a0,0(s1)
    8000403a:	fffff097          	auipc	ra,0xfffff
    8000403e:	606080e7          	jalr	1542(ra) # 80003640 <bread>
    80004042:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80004044:	07050913          	addi	s2,a0,112
    80004048:	47050993          	addi	s3,a0,1136
    8000404c:	a809                	j	8000405e <iput+0x10a>
        bfree(ip->dev, a[j]);
    8000404e:	4088                	lw	a0,0(s1)
    80004050:	00000097          	auipc	ra,0x0
    80004054:	83a080e7          	jalr	-1990(ra) # 8000388a <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80004058:	0911                	addi	s2,s2,4
    8000405a:	01390663          	beq	s2,s3,80004066 <iput+0x112>
      if(a[j])
    8000405e:	00092583          	lw	a1,0(s2)
    80004062:	d9fd                	beqz	a1,80004058 <iput+0x104>
    80004064:	b7ed                	j	8000404e <iput+0xfa>
    brelse(bp);
    80004066:	8556                	mv	a0,s5
    80004068:	fffff097          	auipc	ra,0xfffff
    8000406c:	70c080e7          	jalr	1804(ra) # 80003774 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004070:	0984a583          	lw	a1,152(s1)
    80004074:	4088                	lw	a0,0(s1)
    80004076:	00000097          	auipc	ra,0x0
    8000407a:	814080e7          	jalr	-2028(ra) # 8000388a <bfree>
    ip->addrs[NDIRECT] = 0;
    8000407e:	0804ac23          	sw	zero,152(s1)
    80004082:	bfad                	j	80003ffc <iput+0xa8>

0000000080004084 <iunlockput>:
{
    80004084:	1101                	addi	sp,sp,-32
    80004086:	ec06                	sd	ra,24(sp)
    80004088:	e822                	sd	s0,16(sp)
    8000408a:	e426                	sd	s1,8(sp)
    8000408c:	1000                	addi	s0,sp,32
    8000408e:	84aa                	mv	s1,a0
  iunlock(ip);
    80004090:	00000097          	auipc	ra,0x0
    80004094:	e78080e7          	jalr	-392(ra) # 80003f08 <iunlock>
  iput(ip);
    80004098:	8526                	mv	a0,s1
    8000409a:	00000097          	auipc	ra,0x0
    8000409e:	eba080e7          	jalr	-326(ra) # 80003f54 <iput>
}
    800040a2:	60e2                	ld	ra,24(sp)
    800040a4:	6442                	ld	s0,16(sp)
    800040a6:	64a2                	ld	s1,8(sp)
    800040a8:	6105                	addi	sp,sp,32
    800040aa:	8082                	ret

00000000800040ac <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800040ac:	1141                	addi	sp,sp,-16
    800040ae:	e422                	sd	s0,8(sp)
    800040b0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800040b2:	411c                	lw	a5,0(a0)
    800040b4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800040b6:	415c                	lw	a5,4(a0)
    800040b8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800040ba:	05c51783          	lh	a5,92(a0)
    800040be:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800040c2:	06251783          	lh	a5,98(a0)
    800040c6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800040ca:	06456783          	lwu	a5,100(a0)
    800040ce:	e99c                	sd	a5,16(a1)
}
    800040d0:	6422                	ld	s0,8(sp)
    800040d2:	0141                	addi	sp,sp,16
    800040d4:	8082                	ret

00000000800040d6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040d6:	517c                	lw	a5,100(a0)
    800040d8:	0ed7e563          	bltu	a5,a3,800041c2 <readi+0xec>
{
    800040dc:	7159                	addi	sp,sp,-112
    800040de:	f486                	sd	ra,104(sp)
    800040e0:	f0a2                	sd	s0,96(sp)
    800040e2:	eca6                	sd	s1,88(sp)
    800040e4:	e8ca                	sd	s2,80(sp)
    800040e6:	e4ce                	sd	s3,72(sp)
    800040e8:	e0d2                	sd	s4,64(sp)
    800040ea:	fc56                	sd	s5,56(sp)
    800040ec:	f85a                	sd	s6,48(sp)
    800040ee:	f45e                	sd	s7,40(sp)
    800040f0:	f062                	sd	s8,32(sp)
    800040f2:	ec66                	sd	s9,24(sp)
    800040f4:	e86a                	sd	s10,16(sp)
    800040f6:	e46e                	sd	s11,8(sp)
    800040f8:	1880                	addi	s0,sp,112
    800040fa:	8baa                	mv	s7,a0
    800040fc:	8c2e                	mv	s8,a1
    800040fe:	8ab2                	mv	s5,a2
    80004100:	8936                	mv	s2,a3
    80004102:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004104:	9f35                	addw	a4,a4,a3
    80004106:	0cd76063          	bltu	a4,a3,800041c6 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    8000410a:	00e7f463          	bgeu	a5,a4,80004112 <readi+0x3c>
    n = ip->size - off;
    8000410e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004112:	080b0763          	beqz	s6,800041a0 <readi+0xca>
    80004116:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004118:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000411c:	5cfd                	li	s9,-1
    8000411e:	a82d                	j	80004158 <readi+0x82>
    80004120:	02099d93          	slli	s11,s3,0x20
    80004124:	020ddd93          	srli	s11,s11,0x20
    80004128:	07048613          	addi	a2,s1,112
    8000412c:	86ee                	mv	a3,s11
    8000412e:	963a                	add	a2,a2,a4
    80004130:	85d6                	mv	a1,s5
    80004132:	8562                	mv	a0,s8
    80004134:	fffff097          	auipc	ra,0xfffff
    80004138:	9aa080e7          	jalr	-1622(ra) # 80002ade <either_copyout>
    8000413c:	05950d63          	beq	a0,s9,80004196 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80004140:	8526                	mv	a0,s1
    80004142:	fffff097          	auipc	ra,0xfffff
    80004146:	632080e7          	jalr	1586(ra) # 80003774 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000414a:	01498a3b          	addw	s4,s3,s4
    8000414e:	0129893b          	addw	s2,s3,s2
    80004152:	9aee                	add	s5,s5,s11
    80004154:	056a7663          	bgeu	s4,s6,800041a0 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004158:	000ba483          	lw	s1,0(s7)
    8000415c:	00a9559b          	srliw	a1,s2,0xa
    80004160:	855e                	mv	a0,s7
    80004162:	00000097          	auipc	ra,0x0
    80004166:	8d6080e7          	jalr	-1834(ra) # 80003a38 <bmap>
    8000416a:	0005059b          	sext.w	a1,a0
    8000416e:	8526                	mv	a0,s1
    80004170:	fffff097          	auipc	ra,0xfffff
    80004174:	4d0080e7          	jalr	1232(ra) # 80003640 <bread>
    80004178:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000417a:	3ff97713          	andi	a4,s2,1023
    8000417e:	40ed07bb          	subw	a5,s10,a4
    80004182:	414b06bb          	subw	a3,s6,s4
    80004186:	89be                	mv	s3,a5
    80004188:	2781                	sext.w	a5,a5
    8000418a:	0006861b          	sext.w	a2,a3
    8000418e:	f8f679e3          	bgeu	a2,a5,80004120 <readi+0x4a>
    80004192:	89b6                	mv	s3,a3
    80004194:	b771                	j	80004120 <readi+0x4a>
      brelse(bp);
    80004196:	8526                	mv	a0,s1
    80004198:	fffff097          	auipc	ra,0xfffff
    8000419c:	5dc080e7          	jalr	1500(ra) # 80003774 <brelse>
  }
  return n;
    800041a0:	000b051b          	sext.w	a0,s6
}
    800041a4:	70a6                	ld	ra,104(sp)
    800041a6:	7406                	ld	s0,96(sp)
    800041a8:	64e6                	ld	s1,88(sp)
    800041aa:	6946                	ld	s2,80(sp)
    800041ac:	69a6                	ld	s3,72(sp)
    800041ae:	6a06                	ld	s4,64(sp)
    800041b0:	7ae2                	ld	s5,56(sp)
    800041b2:	7b42                	ld	s6,48(sp)
    800041b4:	7ba2                	ld	s7,40(sp)
    800041b6:	7c02                	ld	s8,32(sp)
    800041b8:	6ce2                	ld	s9,24(sp)
    800041ba:	6d42                	ld	s10,16(sp)
    800041bc:	6da2                	ld	s11,8(sp)
    800041be:	6165                	addi	sp,sp,112
    800041c0:	8082                	ret
    return -1;
    800041c2:	557d                	li	a0,-1
}
    800041c4:	8082                	ret
    return -1;
    800041c6:	557d                	li	a0,-1
    800041c8:	bff1                	j	800041a4 <readi+0xce>

00000000800041ca <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041ca:	517c                	lw	a5,100(a0)
    800041cc:	10d7e663          	bltu	a5,a3,800042d8 <writei+0x10e>
{
    800041d0:	7159                	addi	sp,sp,-112
    800041d2:	f486                	sd	ra,104(sp)
    800041d4:	f0a2                	sd	s0,96(sp)
    800041d6:	eca6                	sd	s1,88(sp)
    800041d8:	e8ca                	sd	s2,80(sp)
    800041da:	e4ce                	sd	s3,72(sp)
    800041dc:	e0d2                	sd	s4,64(sp)
    800041de:	fc56                	sd	s5,56(sp)
    800041e0:	f85a                	sd	s6,48(sp)
    800041e2:	f45e                	sd	s7,40(sp)
    800041e4:	f062                	sd	s8,32(sp)
    800041e6:	ec66                	sd	s9,24(sp)
    800041e8:	e86a                	sd	s10,16(sp)
    800041ea:	e46e                	sd	s11,8(sp)
    800041ec:	1880                	addi	s0,sp,112
    800041ee:	8baa                	mv	s7,a0
    800041f0:	8c2e                	mv	s8,a1
    800041f2:	8ab2                	mv	s5,a2
    800041f4:	8936                	mv	s2,a3
    800041f6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800041f8:	00e687bb          	addw	a5,a3,a4
    800041fc:	0ed7e063          	bltu	a5,a3,800042dc <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004200:	00043737          	lui	a4,0x43
    80004204:	0cf76e63          	bltu	a4,a5,800042e0 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004208:	0a0b0763          	beqz	s6,800042b6 <writei+0xec>
    8000420c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000420e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004212:	5cfd                	li	s9,-1
    80004214:	a091                	j	80004258 <writei+0x8e>
    80004216:	02099d93          	slli	s11,s3,0x20
    8000421a:	020ddd93          	srli	s11,s11,0x20
    8000421e:	07048513          	addi	a0,s1,112
    80004222:	86ee                	mv	a3,s11
    80004224:	8656                	mv	a2,s5
    80004226:	85e2                	mv	a1,s8
    80004228:	953a                	add	a0,a0,a4
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	90a080e7          	jalr	-1782(ra) # 80002b34 <either_copyin>
    80004232:	07950263          	beq	a0,s9,80004296 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004236:	8526                	mv	a0,s1
    80004238:	00001097          	auipc	ra,0x1
    8000423c:	828080e7          	jalr	-2008(ra) # 80004a60 <log_write>
    brelse(bp);
    80004240:	8526                	mv	a0,s1
    80004242:	fffff097          	auipc	ra,0xfffff
    80004246:	532080e7          	jalr	1330(ra) # 80003774 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000424a:	01498a3b          	addw	s4,s3,s4
    8000424e:	0129893b          	addw	s2,s3,s2
    80004252:	9aee                	add	s5,s5,s11
    80004254:	056a7663          	bgeu	s4,s6,800042a0 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004258:	000ba483          	lw	s1,0(s7)
    8000425c:	00a9559b          	srliw	a1,s2,0xa
    80004260:	855e                	mv	a0,s7
    80004262:	fffff097          	auipc	ra,0xfffff
    80004266:	7d6080e7          	jalr	2006(ra) # 80003a38 <bmap>
    8000426a:	0005059b          	sext.w	a1,a0
    8000426e:	8526                	mv	a0,s1
    80004270:	fffff097          	auipc	ra,0xfffff
    80004274:	3d0080e7          	jalr	976(ra) # 80003640 <bread>
    80004278:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000427a:	3ff97713          	andi	a4,s2,1023
    8000427e:	40ed07bb          	subw	a5,s10,a4
    80004282:	414b06bb          	subw	a3,s6,s4
    80004286:	89be                	mv	s3,a5
    80004288:	2781                	sext.w	a5,a5
    8000428a:	0006861b          	sext.w	a2,a3
    8000428e:	f8f674e3          	bgeu	a2,a5,80004216 <writei+0x4c>
    80004292:	89b6                	mv	s3,a3
    80004294:	b749                	j	80004216 <writei+0x4c>
      brelse(bp);
    80004296:	8526                	mv	a0,s1
    80004298:	fffff097          	auipc	ra,0xfffff
    8000429c:	4dc080e7          	jalr	1244(ra) # 80003774 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    800042a0:	064ba783          	lw	a5,100(s7)
    800042a4:	0127f463          	bgeu	a5,s2,800042ac <writei+0xe2>
      ip->size = off;
    800042a8:	072ba223          	sw	s2,100(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    800042ac:	855e                	mv	a0,s7
    800042ae:	00000097          	auipc	ra,0x0
    800042b2:	ace080e7          	jalr	-1330(ra) # 80003d7c <iupdate>
  }

  return n;
    800042b6:	000b051b          	sext.w	a0,s6
}
    800042ba:	70a6                	ld	ra,104(sp)
    800042bc:	7406                	ld	s0,96(sp)
    800042be:	64e6                	ld	s1,88(sp)
    800042c0:	6946                	ld	s2,80(sp)
    800042c2:	69a6                	ld	s3,72(sp)
    800042c4:	6a06                	ld	s4,64(sp)
    800042c6:	7ae2                	ld	s5,56(sp)
    800042c8:	7b42                	ld	s6,48(sp)
    800042ca:	7ba2                	ld	s7,40(sp)
    800042cc:	7c02                	ld	s8,32(sp)
    800042ce:	6ce2                	ld	s9,24(sp)
    800042d0:	6d42                	ld	s10,16(sp)
    800042d2:	6da2                	ld	s11,8(sp)
    800042d4:	6165                	addi	sp,sp,112
    800042d6:	8082                	ret
    return -1;
    800042d8:	557d                	li	a0,-1
}
    800042da:	8082                	ret
    return -1;
    800042dc:	557d                	li	a0,-1
    800042de:	bff1                	j	800042ba <writei+0xf0>
    return -1;
    800042e0:	557d                	li	a0,-1
    800042e2:	bfe1                	j	800042ba <writei+0xf0>

00000000800042e4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800042e4:	1141                	addi	sp,sp,-16
    800042e6:	e406                	sd	ra,8(sp)
    800042e8:	e022                	sd	s0,0(sp)
    800042ea:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800042ec:	4639                	li	a2,14
    800042ee:	ffffd097          	auipc	ra,0xffffd
    800042f2:	ec2080e7          	jalr	-318(ra) # 800011b0 <strncmp>
}
    800042f6:	60a2                	ld	ra,8(sp)
    800042f8:	6402                	ld	s0,0(sp)
    800042fa:	0141                	addi	sp,sp,16
    800042fc:	8082                	ret

00000000800042fe <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800042fe:	7139                	addi	sp,sp,-64
    80004300:	fc06                	sd	ra,56(sp)
    80004302:	f822                	sd	s0,48(sp)
    80004304:	f426                	sd	s1,40(sp)
    80004306:	f04a                	sd	s2,32(sp)
    80004308:	ec4e                	sd	s3,24(sp)
    8000430a:	e852                	sd	s4,16(sp)
    8000430c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000430e:	05c51703          	lh	a4,92(a0)
    80004312:	4785                	li	a5,1
    80004314:	00f71a63          	bne	a4,a5,80004328 <dirlookup+0x2a>
    80004318:	892a                	mv	s2,a0
    8000431a:	89ae                	mv	s3,a1
    8000431c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000431e:	517c                	lw	a5,100(a0)
    80004320:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004322:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004324:	e79d                	bnez	a5,80004352 <dirlookup+0x54>
    80004326:	a8a5                	j	8000439e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004328:	00005517          	auipc	a0,0x5
    8000432c:	81050513          	addi	a0,a0,-2032 # 80008b38 <userret+0xaa8>
    80004330:	ffffc097          	auipc	ra,0xffffc
    80004334:	426080e7          	jalr	1062(ra) # 80000756 <panic>
      panic("dirlookup read");
    80004338:	00005517          	auipc	a0,0x5
    8000433c:	81850513          	addi	a0,a0,-2024 # 80008b50 <userret+0xac0>
    80004340:	ffffc097          	auipc	ra,0xffffc
    80004344:	416080e7          	jalr	1046(ra) # 80000756 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004348:	24c1                	addiw	s1,s1,16
    8000434a:	06492783          	lw	a5,100(s2)
    8000434e:	04f4f763          	bgeu	s1,a5,8000439c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004352:	4741                	li	a4,16
    80004354:	86a6                	mv	a3,s1
    80004356:	fc040613          	addi	a2,s0,-64
    8000435a:	4581                	li	a1,0
    8000435c:	854a                	mv	a0,s2
    8000435e:	00000097          	auipc	ra,0x0
    80004362:	d78080e7          	jalr	-648(ra) # 800040d6 <readi>
    80004366:	47c1                	li	a5,16
    80004368:	fcf518e3          	bne	a0,a5,80004338 <dirlookup+0x3a>
    if(de.inum == 0)
    8000436c:	fc045783          	lhu	a5,-64(s0)
    80004370:	dfe1                	beqz	a5,80004348 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004372:	fc240593          	addi	a1,s0,-62
    80004376:	854e                	mv	a0,s3
    80004378:	00000097          	auipc	ra,0x0
    8000437c:	f6c080e7          	jalr	-148(ra) # 800042e4 <namecmp>
    80004380:	f561                	bnez	a0,80004348 <dirlookup+0x4a>
      if(poff)
    80004382:	000a0463          	beqz	s4,8000438a <dirlookup+0x8c>
        *poff = off;
    80004386:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000438a:	fc045583          	lhu	a1,-64(s0)
    8000438e:	00092503          	lw	a0,0(s2)
    80004392:	fffff097          	auipc	ra,0xfffff
    80004396:	780080e7          	jalr	1920(ra) # 80003b12 <iget>
    8000439a:	a011                	j	8000439e <dirlookup+0xa0>
  return 0;
    8000439c:	4501                	li	a0,0
}
    8000439e:	70e2                	ld	ra,56(sp)
    800043a0:	7442                	ld	s0,48(sp)
    800043a2:	74a2                	ld	s1,40(sp)
    800043a4:	7902                	ld	s2,32(sp)
    800043a6:	69e2                	ld	s3,24(sp)
    800043a8:	6a42                	ld	s4,16(sp)
    800043aa:	6121                	addi	sp,sp,64
    800043ac:	8082                	ret

00000000800043ae <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800043ae:	711d                	addi	sp,sp,-96
    800043b0:	ec86                	sd	ra,88(sp)
    800043b2:	e8a2                	sd	s0,80(sp)
    800043b4:	e4a6                	sd	s1,72(sp)
    800043b6:	e0ca                	sd	s2,64(sp)
    800043b8:	fc4e                	sd	s3,56(sp)
    800043ba:	f852                	sd	s4,48(sp)
    800043bc:	f456                	sd	s5,40(sp)
    800043be:	f05a                	sd	s6,32(sp)
    800043c0:	ec5e                	sd	s7,24(sp)
    800043c2:	e862                	sd	s8,16(sp)
    800043c4:	e466                	sd	s9,8(sp)
    800043c6:	1080                	addi	s0,sp,96
    800043c8:	84aa                	mv	s1,a0
    800043ca:	8b2e                	mv	s6,a1
    800043cc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800043ce:	00054703          	lbu	a4,0(a0)
    800043d2:	02f00793          	li	a5,47
    800043d6:	02f70363          	beq	a4,a5,800043fc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800043da:	ffffe097          	auipc	ra,0xffffe
    800043de:	bc2080e7          	jalr	-1086(ra) # 80001f9c <myproc>
    800043e2:	16853503          	ld	a0,360(a0)
    800043e6:	00000097          	auipc	ra,0x0
    800043ea:	a22080e7          	jalr	-1502(ra) # 80003e08 <idup>
    800043ee:	89aa                	mv	s3,a0
  while(*path == '/')
    800043f0:	02f00913          	li	s2,47
  len = path - s;
    800043f4:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800043f6:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800043f8:	4c05                	li	s8,1
    800043fa:	a865                	j	800044b2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800043fc:	4585                	li	a1,1
    800043fe:	4501                	li	a0,0
    80004400:	fffff097          	auipc	ra,0xfffff
    80004404:	712080e7          	jalr	1810(ra) # 80003b12 <iget>
    80004408:	89aa                	mv	s3,a0
    8000440a:	b7dd                	j	800043f0 <namex+0x42>
      iunlockput(ip);
    8000440c:	854e                	mv	a0,s3
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	c76080e7          	jalr	-906(ra) # 80004084 <iunlockput>
      return 0;
    80004416:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004418:	854e                	mv	a0,s3
    8000441a:	60e6                	ld	ra,88(sp)
    8000441c:	6446                	ld	s0,80(sp)
    8000441e:	64a6                	ld	s1,72(sp)
    80004420:	6906                	ld	s2,64(sp)
    80004422:	79e2                	ld	s3,56(sp)
    80004424:	7a42                	ld	s4,48(sp)
    80004426:	7aa2                	ld	s5,40(sp)
    80004428:	7b02                	ld	s6,32(sp)
    8000442a:	6be2                	ld	s7,24(sp)
    8000442c:	6c42                	ld	s8,16(sp)
    8000442e:	6ca2                	ld	s9,8(sp)
    80004430:	6125                	addi	sp,sp,96
    80004432:	8082                	ret
      iunlock(ip);
    80004434:	854e                	mv	a0,s3
    80004436:	00000097          	auipc	ra,0x0
    8000443a:	ad2080e7          	jalr	-1326(ra) # 80003f08 <iunlock>
      return ip;
    8000443e:	bfe9                	j	80004418 <namex+0x6a>
      iunlockput(ip);
    80004440:	854e                	mv	a0,s3
    80004442:	00000097          	auipc	ra,0x0
    80004446:	c42080e7          	jalr	-958(ra) # 80004084 <iunlockput>
      return 0;
    8000444a:	89d2                	mv	s3,s4
    8000444c:	b7f1                	j	80004418 <namex+0x6a>
  len = path - s;
    8000444e:	40b48633          	sub	a2,s1,a1
    80004452:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004456:	094cd463          	bge	s9,s4,800044de <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000445a:	4639                	li	a2,14
    8000445c:	8556                	mv	a0,s5
    8000445e:	ffffd097          	auipc	ra,0xffffd
    80004462:	cd6080e7          	jalr	-810(ra) # 80001134 <memmove>
  while(*path == '/')
    80004466:	0004c783          	lbu	a5,0(s1)
    8000446a:	01279763          	bne	a5,s2,80004478 <namex+0xca>
    path++;
    8000446e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004470:	0004c783          	lbu	a5,0(s1)
    80004474:	ff278de3          	beq	a5,s2,8000446e <namex+0xc0>
    ilock(ip);
    80004478:	854e                	mv	a0,s3
    8000447a:	00000097          	auipc	ra,0x0
    8000447e:	9cc080e7          	jalr	-1588(ra) # 80003e46 <ilock>
    if(ip->type != T_DIR){
    80004482:	05c99783          	lh	a5,92(s3)
    80004486:	f98793e3          	bne	a5,s8,8000440c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000448a:	000b0563          	beqz	s6,80004494 <namex+0xe6>
    8000448e:	0004c783          	lbu	a5,0(s1)
    80004492:	d3cd                	beqz	a5,80004434 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004494:	865e                	mv	a2,s7
    80004496:	85d6                	mv	a1,s5
    80004498:	854e                	mv	a0,s3
    8000449a:	00000097          	auipc	ra,0x0
    8000449e:	e64080e7          	jalr	-412(ra) # 800042fe <dirlookup>
    800044a2:	8a2a                	mv	s4,a0
    800044a4:	dd51                	beqz	a0,80004440 <namex+0x92>
    iunlockput(ip);
    800044a6:	854e                	mv	a0,s3
    800044a8:	00000097          	auipc	ra,0x0
    800044ac:	bdc080e7          	jalr	-1060(ra) # 80004084 <iunlockput>
    ip = next;
    800044b0:	89d2                	mv	s3,s4
  while(*path == '/')
    800044b2:	0004c783          	lbu	a5,0(s1)
    800044b6:	05279763          	bne	a5,s2,80004504 <namex+0x156>
    path++;
    800044ba:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044bc:	0004c783          	lbu	a5,0(s1)
    800044c0:	ff278de3          	beq	a5,s2,800044ba <namex+0x10c>
  if(*path == 0)
    800044c4:	c79d                	beqz	a5,800044f2 <namex+0x144>
    path++;
    800044c6:	85a6                	mv	a1,s1
  len = path - s;
    800044c8:	8a5e                	mv	s4,s7
    800044ca:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800044cc:	01278963          	beq	a5,s2,800044de <namex+0x130>
    800044d0:	dfbd                	beqz	a5,8000444e <namex+0xa0>
    path++;
    800044d2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800044d4:	0004c783          	lbu	a5,0(s1)
    800044d8:	ff279ce3          	bne	a5,s2,800044d0 <namex+0x122>
    800044dc:	bf8d                	j	8000444e <namex+0xa0>
    memmove(name, s, len);
    800044de:	2601                	sext.w	a2,a2
    800044e0:	8556                	mv	a0,s5
    800044e2:	ffffd097          	auipc	ra,0xffffd
    800044e6:	c52080e7          	jalr	-942(ra) # 80001134 <memmove>
    name[len] = 0;
    800044ea:	9a56                	add	s4,s4,s5
    800044ec:	000a0023          	sb	zero,0(s4)
    800044f0:	bf9d                	j	80004466 <namex+0xb8>
  if(nameiparent){
    800044f2:	f20b03e3          	beqz	s6,80004418 <namex+0x6a>
    iput(ip);
    800044f6:	854e                	mv	a0,s3
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	a5c080e7          	jalr	-1444(ra) # 80003f54 <iput>
    return 0;
    80004500:	4981                	li	s3,0
    80004502:	bf19                	j	80004418 <namex+0x6a>
  if(*path == 0)
    80004504:	d7fd                	beqz	a5,800044f2 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004506:	0004c783          	lbu	a5,0(s1)
    8000450a:	85a6                	mv	a1,s1
    8000450c:	b7d1                	j	800044d0 <namex+0x122>

000000008000450e <dirlink>:
{
    8000450e:	7139                	addi	sp,sp,-64
    80004510:	fc06                	sd	ra,56(sp)
    80004512:	f822                	sd	s0,48(sp)
    80004514:	f426                	sd	s1,40(sp)
    80004516:	f04a                	sd	s2,32(sp)
    80004518:	ec4e                	sd	s3,24(sp)
    8000451a:	e852                	sd	s4,16(sp)
    8000451c:	0080                	addi	s0,sp,64
    8000451e:	892a                	mv	s2,a0
    80004520:	8a2e                	mv	s4,a1
    80004522:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004524:	4601                	li	a2,0
    80004526:	00000097          	auipc	ra,0x0
    8000452a:	dd8080e7          	jalr	-552(ra) # 800042fe <dirlookup>
    8000452e:	e93d                	bnez	a0,800045a4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004530:	06492483          	lw	s1,100(s2)
    80004534:	c49d                	beqz	s1,80004562 <dirlink+0x54>
    80004536:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004538:	4741                	li	a4,16
    8000453a:	86a6                	mv	a3,s1
    8000453c:	fc040613          	addi	a2,s0,-64
    80004540:	4581                	li	a1,0
    80004542:	854a                	mv	a0,s2
    80004544:	00000097          	auipc	ra,0x0
    80004548:	b92080e7          	jalr	-1134(ra) # 800040d6 <readi>
    8000454c:	47c1                	li	a5,16
    8000454e:	06f51163          	bne	a0,a5,800045b0 <dirlink+0xa2>
    if(de.inum == 0)
    80004552:	fc045783          	lhu	a5,-64(s0)
    80004556:	c791                	beqz	a5,80004562 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004558:	24c1                	addiw	s1,s1,16
    8000455a:	06492783          	lw	a5,100(s2)
    8000455e:	fcf4ede3          	bltu	s1,a5,80004538 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004562:	4639                	li	a2,14
    80004564:	85d2                	mv	a1,s4
    80004566:	fc240513          	addi	a0,s0,-62
    8000456a:	ffffd097          	auipc	ra,0xffffd
    8000456e:	c82080e7          	jalr	-894(ra) # 800011ec <strncpy>
  de.inum = inum;
    80004572:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004576:	4741                	li	a4,16
    80004578:	86a6                	mv	a3,s1
    8000457a:	fc040613          	addi	a2,s0,-64
    8000457e:	4581                	li	a1,0
    80004580:	854a                	mv	a0,s2
    80004582:	00000097          	auipc	ra,0x0
    80004586:	c48080e7          	jalr	-952(ra) # 800041ca <writei>
    8000458a:	872a                	mv	a4,a0
    8000458c:	47c1                	li	a5,16
  return 0;
    8000458e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004590:	02f71863          	bne	a4,a5,800045c0 <dirlink+0xb2>
}
    80004594:	70e2                	ld	ra,56(sp)
    80004596:	7442                	ld	s0,48(sp)
    80004598:	74a2                	ld	s1,40(sp)
    8000459a:	7902                	ld	s2,32(sp)
    8000459c:	69e2                	ld	s3,24(sp)
    8000459e:	6a42                	ld	s4,16(sp)
    800045a0:	6121                	addi	sp,sp,64
    800045a2:	8082                	ret
    iput(ip);
    800045a4:	00000097          	auipc	ra,0x0
    800045a8:	9b0080e7          	jalr	-1616(ra) # 80003f54 <iput>
    return -1;
    800045ac:	557d                	li	a0,-1
    800045ae:	b7dd                	j	80004594 <dirlink+0x86>
      panic("dirlink read");
    800045b0:	00004517          	auipc	a0,0x4
    800045b4:	5b050513          	addi	a0,a0,1456 # 80008b60 <userret+0xad0>
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	19e080e7          	jalr	414(ra) # 80000756 <panic>
    panic("dirlink");
    800045c0:	00004517          	auipc	a0,0x4
    800045c4:	6c050513          	addi	a0,a0,1728 # 80008c80 <userret+0xbf0>
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	18e080e7          	jalr	398(ra) # 80000756 <panic>

00000000800045d0 <namei>:

struct inode*
namei(char *path)
{
    800045d0:	1101                	addi	sp,sp,-32
    800045d2:	ec06                	sd	ra,24(sp)
    800045d4:	e822                	sd	s0,16(sp)
    800045d6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800045d8:	fe040613          	addi	a2,s0,-32
    800045dc:	4581                	li	a1,0
    800045de:	00000097          	auipc	ra,0x0
    800045e2:	dd0080e7          	jalr	-560(ra) # 800043ae <namex>
}
    800045e6:	60e2                	ld	ra,24(sp)
    800045e8:	6442                	ld	s0,16(sp)
    800045ea:	6105                	addi	sp,sp,32
    800045ec:	8082                	ret

00000000800045ee <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800045ee:	1141                	addi	sp,sp,-16
    800045f0:	e406                	sd	ra,8(sp)
    800045f2:	e022                	sd	s0,0(sp)
    800045f4:	0800                	addi	s0,sp,16
    800045f6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800045f8:	4585                	li	a1,1
    800045fa:	00000097          	auipc	ra,0x0
    800045fe:	db4080e7          	jalr	-588(ra) # 800043ae <namex>
}
    80004602:	60a2                	ld	ra,8(sp)
    80004604:	6402                	ld	s0,0(sp)
    80004606:	0141                	addi	sp,sp,16
    80004608:	8082                	ret

000000008000460a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    8000460a:	7179                	addi	sp,sp,-48
    8000460c:	f406                	sd	ra,40(sp)
    8000460e:	f022                	sd	s0,32(sp)
    80004610:	ec26                	sd	s1,24(sp)
    80004612:	e84a                	sd	s2,16(sp)
    80004614:	e44e                	sd	s3,8(sp)
    80004616:	1800                	addi	s0,sp,48
  struct buf *buf = bread(dev, log[dev].start);
    80004618:	00151993          	slli	s3,a0,0x1
    8000461c:	99aa                	add	s3,s3,a0
    8000461e:	00699793          	slli	a5,s3,0x6
    80004622:	00022997          	auipc	s3,0x22
    80004626:	3f698993          	addi	s3,s3,1014 # 80026a18 <log>
    8000462a:	99be                	add	s3,s3,a5
    8000462c:	0309a583          	lw	a1,48(s3)
    80004630:	fffff097          	auipc	ra,0xfffff
    80004634:	010080e7          	jalr	16(ra) # 80003640 <bread>
    80004638:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    8000463a:	0449a783          	lw	a5,68(s3)
    8000463e:	d93c                	sw	a5,112(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004640:	0449a783          	lw	a5,68(s3)
    80004644:	00f05f63          	blez	a5,80004662 <write_head+0x58>
    80004648:	87ce                	mv	a5,s3
    8000464a:	07450693          	addi	a3,a0,116
    8000464e:	4701                	li	a4,0
    80004650:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80004652:	47b0                	lw	a2,72(a5)
    80004654:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004656:	2705                	addiw	a4,a4,1
    80004658:	0791                	addi	a5,a5,4
    8000465a:	0691                	addi	a3,a3,4
    8000465c:	41f0                	lw	a2,68(a1)
    8000465e:	fec74ae3          	blt	a4,a2,80004652 <write_head+0x48>
  }
  bwrite(buf);
    80004662:	854a                	mv	a0,s2
    80004664:	fffff097          	auipc	ra,0xfffff
    80004668:	0d0080e7          	jalr	208(ra) # 80003734 <bwrite>
  brelse(buf);
    8000466c:	854a                	mv	a0,s2
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	106080e7          	jalr	262(ra) # 80003774 <brelse>
}
    80004676:	70a2                	ld	ra,40(sp)
    80004678:	7402                	ld	s0,32(sp)
    8000467a:	64e2                	ld	s1,24(sp)
    8000467c:	6942                	ld	s2,16(sp)
    8000467e:	69a2                	ld	s3,8(sp)
    80004680:	6145                	addi	sp,sp,48
    80004682:	8082                	ret

0000000080004684 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004684:	00151793          	slli	a5,a0,0x1
    80004688:	97aa                	add	a5,a5,a0
    8000468a:	079a                	slli	a5,a5,0x6
    8000468c:	00022717          	auipc	a4,0x22
    80004690:	38c70713          	addi	a4,a4,908 # 80026a18 <log>
    80004694:	97ba                	add	a5,a5,a4
    80004696:	43fc                	lw	a5,68(a5)
    80004698:	0af05863          	blez	a5,80004748 <install_trans+0xc4>
{
    8000469c:	7139                	addi	sp,sp,-64
    8000469e:	fc06                	sd	ra,56(sp)
    800046a0:	f822                	sd	s0,48(sp)
    800046a2:	f426                	sd	s1,40(sp)
    800046a4:	f04a                	sd	s2,32(sp)
    800046a6:	ec4e                	sd	s3,24(sp)
    800046a8:	e852                	sd	s4,16(sp)
    800046aa:	e456                	sd	s5,8(sp)
    800046ac:	e05a                	sd	s6,0(sp)
    800046ae:	0080                	addi	s0,sp,64
    800046b0:	00151a13          	slli	s4,a0,0x1
    800046b4:	9a2a                	add	s4,s4,a0
    800046b6:	006a1793          	slli	a5,s4,0x6
    800046ba:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800046be:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    800046c0:	00050b1b          	sext.w	s6,a0
    800046c4:	8ad2                	mv	s5,s4
    800046c6:	030aa583          	lw	a1,48(s5)
    800046ca:	013585bb          	addw	a1,a1,s3
    800046ce:	2585                	addiw	a1,a1,1
    800046d0:	855a                	mv	a0,s6
    800046d2:	fffff097          	auipc	ra,0xfffff
    800046d6:	f6e080e7          	jalr	-146(ra) # 80003640 <bread>
    800046da:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    800046dc:	048a2583          	lw	a1,72(s4)
    800046e0:	855a                	mv	a0,s6
    800046e2:	fffff097          	auipc	ra,0xfffff
    800046e6:	f5e080e7          	jalr	-162(ra) # 80003640 <bread>
    800046ea:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800046ec:	40000613          	li	a2,1024
    800046f0:	07090593          	addi	a1,s2,112
    800046f4:	07050513          	addi	a0,a0,112
    800046f8:	ffffd097          	auipc	ra,0xffffd
    800046fc:	a3c080e7          	jalr	-1476(ra) # 80001134 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004700:	8526                	mv	a0,s1
    80004702:	fffff097          	auipc	ra,0xfffff
    80004706:	032080e7          	jalr	50(ra) # 80003734 <bwrite>
    bunpin(dbuf);
    8000470a:	8526                	mv	a0,s1
    8000470c:	fffff097          	auipc	ra,0xfffff
    80004710:	142080e7          	jalr	322(ra) # 8000384e <bunpin>
    brelse(lbuf);
    80004714:	854a                	mv	a0,s2
    80004716:	fffff097          	auipc	ra,0xfffff
    8000471a:	05e080e7          	jalr	94(ra) # 80003774 <brelse>
    brelse(dbuf);
    8000471e:	8526                	mv	a0,s1
    80004720:	fffff097          	auipc	ra,0xfffff
    80004724:	054080e7          	jalr	84(ra) # 80003774 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004728:	2985                	addiw	s3,s3,1
    8000472a:	0a11                	addi	s4,s4,4
    8000472c:	044aa783          	lw	a5,68(s5)
    80004730:	f8f9cbe3          	blt	s3,a5,800046c6 <install_trans+0x42>
}
    80004734:	70e2                	ld	ra,56(sp)
    80004736:	7442                	ld	s0,48(sp)
    80004738:	74a2                	ld	s1,40(sp)
    8000473a:	7902                	ld	s2,32(sp)
    8000473c:	69e2                	ld	s3,24(sp)
    8000473e:	6a42                	ld	s4,16(sp)
    80004740:	6aa2                	ld	s5,8(sp)
    80004742:	6b02                	ld	s6,0(sp)
    80004744:	6121                	addi	sp,sp,64
    80004746:	8082                	ret
    80004748:	8082                	ret

000000008000474a <initlog>:
{
    8000474a:	7179                	addi	sp,sp,-48
    8000474c:	f406                	sd	ra,40(sp)
    8000474e:	f022                	sd	s0,32(sp)
    80004750:	ec26                	sd	s1,24(sp)
    80004752:	e84a                	sd	s2,16(sp)
    80004754:	e44e                	sd	s3,8(sp)
    80004756:	e052                	sd	s4,0(sp)
    80004758:	1800                	addi	s0,sp,48
    8000475a:	84aa                	mv	s1,a0
    8000475c:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    8000475e:	00151713          	slli	a4,a0,0x1
    80004762:	972a                	add	a4,a4,a0
    80004764:	00671993          	slli	s3,a4,0x6
    80004768:	00022917          	auipc	s2,0x22
    8000476c:	2b090913          	addi	s2,s2,688 # 80026a18 <log>
    80004770:	994e                	add	s2,s2,s3
    80004772:	00004597          	auipc	a1,0x4
    80004776:	3fe58593          	addi	a1,a1,1022 # 80008b70 <userret+0xae0>
    8000477a:	854a                	mv	a0,s2
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	3a2080e7          	jalr	930(ra) # 80000b1e <initlock>
  log[dev].start = sb->logstart;
    80004784:	014a2583          	lw	a1,20(s4)
    80004788:	02b92823          	sw	a1,48(s2)
  log[dev].size = sb->nlog;
    8000478c:	010a2783          	lw	a5,16(s4)
    80004790:	02f92a23          	sw	a5,52(s2)
  log[dev].dev = dev;
    80004794:	04992023          	sw	s1,64(s2)
  struct buf *buf = bread(dev, log[dev].start);
    80004798:	8526                	mv	a0,s1
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	ea6080e7          	jalr	-346(ra) # 80003640 <bread>
  log[dev].lh.n = lh->n;
    800047a2:	593c                	lw	a5,112(a0)
    800047a4:	04f92223          	sw	a5,68(s2)
  for (i = 0; i < log[dev].lh.n; i++) {
    800047a8:	02f05663          	blez	a5,800047d4 <initlog+0x8a>
    800047ac:	07450693          	addi	a3,a0,116
    800047b0:	00022717          	auipc	a4,0x22
    800047b4:	2b070713          	addi	a4,a4,688 # 80026a60 <log+0x48>
    800047b8:	974e                	add	a4,a4,s3
    800047ba:	37fd                	addiw	a5,a5,-1
    800047bc:	1782                	slli	a5,a5,0x20
    800047be:	9381                	srli	a5,a5,0x20
    800047c0:	078a                	slli	a5,a5,0x2
    800047c2:	07850613          	addi	a2,a0,120
    800047c6:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    800047c8:	4290                	lw	a2,0(a3)
    800047ca:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    800047cc:	0691                	addi	a3,a3,4
    800047ce:	0711                	addi	a4,a4,4
    800047d0:	fef69ce3          	bne	a3,a5,800047c8 <initlog+0x7e>
  brelse(buf);
    800047d4:	fffff097          	auipc	ra,0xfffff
    800047d8:	fa0080e7          	jalr	-96(ra) # 80003774 <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    800047dc:	8526                	mv	a0,s1
    800047de:	00000097          	auipc	ra,0x0
    800047e2:	ea6080e7          	jalr	-346(ra) # 80004684 <install_trans>
  log[dev].lh.n = 0;
    800047e6:	00149793          	slli	a5,s1,0x1
    800047ea:	97a6                	add	a5,a5,s1
    800047ec:	079a                	slli	a5,a5,0x6
    800047ee:	00022717          	auipc	a4,0x22
    800047f2:	22a70713          	addi	a4,a4,554 # 80026a18 <log>
    800047f6:	97ba                	add	a5,a5,a4
    800047f8:	0407a223          	sw	zero,68(a5)
  write_head(dev); // clear the log
    800047fc:	8526                	mv	a0,s1
    800047fe:	00000097          	auipc	ra,0x0
    80004802:	e0c080e7          	jalr	-500(ra) # 8000460a <write_head>
}
    80004806:	70a2                	ld	ra,40(sp)
    80004808:	7402                	ld	s0,32(sp)
    8000480a:	64e2                	ld	s1,24(sp)
    8000480c:	6942                	ld	s2,16(sp)
    8000480e:	69a2                	ld	s3,8(sp)
    80004810:	6a02                	ld	s4,0(sp)
    80004812:	6145                	addi	sp,sp,48
    80004814:	8082                	ret

0000000080004816 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    80004816:	7139                	addi	sp,sp,-64
    80004818:	fc06                	sd	ra,56(sp)
    8000481a:	f822                	sd	s0,48(sp)
    8000481c:	f426                	sd	s1,40(sp)
    8000481e:	f04a                	sd	s2,32(sp)
    80004820:	ec4e                	sd	s3,24(sp)
    80004822:	e852                	sd	s4,16(sp)
    80004824:	e456                	sd	s5,8(sp)
    80004826:	0080                	addi	s0,sp,64
    80004828:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    8000482a:	00151913          	slli	s2,a0,0x1
    8000482e:	992a                	add	s2,s2,a0
    80004830:	00691793          	slli	a5,s2,0x6
    80004834:	00022917          	auipc	s2,0x22
    80004838:	1e490913          	addi	s2,s2,484 # 80026a18 <log>
    8000483c:	993e                	add	s2,s2,a5
    8000483e:	854a                	mv	a0,s2
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	448080e7          	jalr	1096(ra) # 80000c88 <acquire>
  while(1){
    if(log[dev].committing){
    80004848:	00022997          	auipc	s3,0x22
    8000484c:	1d098993          	addi	s3,s3,464 # 80026a18 <log>
    80004850:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004852:	4a79                	li	s4,30
    80004854:	a039                	j	80004862 <begin_op+0x4c>
      sleep(&log, &log[dev].lock);
    80004856:	85ca                	mv	a1,s2
    80004858:	854e                	mv	a0,s3
    8000485a:	ffffe097          	auipc	ra,0xffffe
    8000485e:	022080e7          	jalr	34(ra) # 8000287c <sleep>
    if(log[dev].committing){
    80004862:	5cdc                	lw	a5,60(s1)
    80004864:	fbed                	bnez	a5,80004856 <begin_op+0x40>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004866:	5c9c                	lw	a5,56(s1)
    80004868:	0017871b          	addiw	a4,a5,1
    8000486c:	0007069b          	sext.w	a3,a4
    80004870:	0027179b          	slliw	a5,a4,0x2
    80004874:	9fb9                	addw	a5,a5,a4
    80004876:	0017979b          	slliw	a5,a5,0x1
    8000487a:	40f8                	lw	a4,68(s1)
    8000487c:	9fb9                	addw	a5,a5,a4
    8000487e:	00fa5963          	bge	s4,a5,80004890 <begin_op+0x7a>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    80004882:	85ca                	mv	a1,s2
    80004884:	854e                	mv	a0,s3
    80004886:	ffffe097          	auipc	ra,0xffffe
    8000488a:	ff6080e7          	jalr	-10(ra) # 8000287c <sleep>
    8000488e:	bfd1                	j	80004862 <begin_op+0x4c>
    } else {
      log[dev].outstanding += 1;
    80004890:	001a9513          	slli	a0,s5,0x1
    80004894:	9aaa                	add	s5,s5,a0
    80004896:	0a9a                	slli	s5,s5,0x6
    80004898:	00022797          	auipc	a5,0x22
    8000489c:	18078793          	addi	a5,a5,384 # 80026a18 <log>
    800048a0:	9abe                	add	s5,s5,a5
    800048a2:	02daac23          	sw	a3,56(s5)
      release(&log[dev].lock);
    800048a6:	854a                	mv	a0,s2
    800048a8:	ffffc097          	auipc	ra,0xffffc
    800048ac:	62c080e7          	jalr	1580(ra) # 80000ed4 <release>
      break;
    }
  }
}
    800048b0:	70e2                	ld	ra,56(sp)
    800048b2:	7442                	ld	s0,48(sp)
    800048b4:	74a2                	ld	s1,40(sp)
    800048b6:	7902                	ld	s2,32(sp)
    800048b8:	69e2                	ld	s3,24(sp)
    800048ba:	6a42                	ld	s4,16(sp)
    800048bc:	6aa2                	ld	s5,8(sp)
    800048be:	6121                	addi	sp,sp,64
    800048c0:	8082                	ret

00000000800048c2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    800048c2:	715d                	addi	sp,sp,-80
    800048c4:	e486                	sd	ra,72(sp)
    800048c6:	e0a2                	sd	s0,64(sp)
    800048c8:	fc26                	sd	s1,56(sp)
    800048ca:	f84a                	sd	s2,48(sp)
    800048cc:	f44e                	sd	s3,40(sp)
    800048ce:	f052                	sd	s4,32(sp)
    800048d0:	ec56                	sd	s5,24(sp)
    800048d2:	e85a                	sd	s6,16(sp)
    800048d4:	e45e                	sd	s7,8(sp)
    800048d6:	e062                	sd	s8,0(sp)
    800048d8:	0880                	addi	s0,sp,80
    800048da:	892a                	mv	s2,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    800048dc:	00151493          	slli	s1,a0,0x1
    800048e0:	94aa                	add	s1,s1,a0
    800048e2:	00649793          	slli	a5,s1,0x6
    800048e6:	00022497          	auipc	s1,0x22
    800048ea:	13248493          	addi	s1,s1,306 # 80026a18 <log>
    800048ee:	94be                	add	s1,s1,a5
    800048f0:	8526                	mv	a0,s1
    800048f2:	ffffc097          	auipc	ra,0xffffc
    800048f6:	396080e7          	jalr	918(ra) # 80000c88 <acquire>
  log[dev].outstanding -= 1;
    800048fa:	5c9c                	lw	a5,56(s1)
    800048fc:	37fd                	addiw	a5,a5,-1
    800048fe:	00078a1b          	sext.w	s4,a5
    80004902:	dc9c                	sw	a5,56(s1)
  if(log[dev].committing)
    80004904:	5cdc                	lw	a5,60(s1)
    80004906:	efad                	bnez	a5,80004980 <end_op+0xbe>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004908:	080a1463          	bnez	s4,80004990 <end_op+0xce>
    do_commit = 1;
    log[dev].committing = 1;
    8000490c:	00191793          	slli	a5,s2,0x1
    80004910:	97ca                	add	a5,a5,s2
    80004912:	079a                	slli	a5,a5,0x6
    80004914:	00022997          	auipc	s3,0x22
    80004918:	10498993          	addi	s3,s3,260 # 80026a18 <log>
    8000491c:	99be                	add	s3,s3,a5
    8000491e:	4785                	li	a5,1
    80004920:	02f9ae23          	sw	a5,60(s3)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    80004924:	8526                	mv	a0,s1
    80004926:	ffffc097          	auipc	ra,0xffffc
    8000492a:	5ae080e7          	jalr	1454(ra) # 80000ed4 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    8000492e:	0449a783          	lw	a5,68(s3)
    80004932:	06f04d63          	bgtz	a5,800049ac <end_op+0xea>
    acquire(&log[dev].lock);
    80004936:	8526                	mv	a0,s1
    80004938:	ffffc097          	auipc	ra,0xffffc
    8000493c:	350080e7          	jalr	848(ra) # 80000c88 <acquire>
    log[dev].committing = 0;
    80004940:	00022517          	auipc	a0,0x22
    80004944:	0d850513          	addi	a0,a0,216 # 80026a18 <log>
    80004948:	00191793          	slli	a5,s2,0x1
    8000494c:	993e                	add	s2,s2,a5
    8000494e:	091a                	slli	s2,s2,0x6
    80004950:	992a                	add	s2,s2,a0
    80004952:	02092e23          	sw	zero,60(s2)
    wakeup(&log);
    80004956:	ffffe097          	auipc	ra,0xffffe
    8000495a:	0ac080e7          	jalr	172(ra) # 80002a02 <wakeup>
    release(&log[dev].lock);
    8000495e:	8526                	mv	a0,s1
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	574080e7          	jalr	1396(ra) # 80000ed4 <release>
}
    80004968:	60a6                	ld	ra,72(sp)
    8000496a:	6406                	ld	s0,64(sp)
    8000496c:	74e2                	ld	s1,56(sp)
    8000496e:	7942                	ld	s2,48(sp)
    80004970:	79a2                	ld	s3,40(sp)
    80004972:	7a02                	ld	s4,32(sp)
    80004974:	6ae2                	ld	s5,24(sp)
    80004976:	6b42                	ld	s6,16(sp)
    80004978:	6ba2                	ld	s7,8(sp)
    8000497a:	6c02                	ld	s8,0(sp)
    8000497c:	6161                	addi	sp,sp,80
    8000497e:	8082                	ret
    panic("log[dev].committing");
    80004980:	00004517          	auipc	a0,0x4
    80004984:	1f850513          	addi	a0,a0,504 # 80008b78 <userret+0xae8>
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	dce080e7          	jalr	-562(ra) # 80000756 <panic>
    wakeup(&log);
    80004990:	00022517          	auipc	a0,0x22
    80004994:	08850513          	addi	a0,a0,136 # 80026a18 <log>
    80004998:	ffffe097          	auipc	ra,0xffffe
    8000499c:	06a080e7          	jalr	106(ra) # 80002a02 <wakeup>
  release(&log[dev].lock);
    800049a0:	8526                	mv	a0,s1
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	532080e7          	jalr	1330(ra) # 80000ed4 <release>
  if(do_commit){
    800049aa:	bf7d                	j	80004968 <end_op+0xa6>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800049ac:	8b26                	mv	s6,s1
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    800049ae:	00090c1b          	sext.w	s8,s2
    800049b2:	00191b93          	slli	s7,s2,0x1
    800049b6:	9bca                	add	s7,s7,s2
    800049b8:	006b9793          	slli	a5,s7,0x6
    800049bc:	00022b97          	auipc	s7,0x22
    800049c0:	05cb8b93          	addi	s7,s7,92 # 80026a18 <log>
    800049c4:	9bbe                	add	s7,s7,a5
    800049c6:	030ba583          	lw	a1,48(s7)
    800049ca:	014585bb          	addw	a1,a1,s4
    800049ce:	2585                	addiw	a1,a1,1
    800049d0:	8562                	mv	a0,s8
    800049d2:	fffff097          	auipc	ra,0xfffff
    800049d6:	c6e080e7          	jalr	-914(ra) # 80003640 <bread>
    800049da:	89aa                	mv	s3,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    800049dc:	048b2583          	lw	a1,72(s6)
    800049e0:	8562                	mv	a0,s8
    800049e2:	fffff097          	auipc	ra,0xfffff
    800049e6:	c5e080e7          	jalr	-930(ra) # 80003640 <bread>
    800049ea:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    800049ec:	40000613          	li	a2,1024
    800049f0:	07050593          	addi	a1,a0,112
    800049f4:	07098513          	addi	a0,s3,112
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	73c080e7          	jalr	1852(ra) # 80001134 <memmove>
    bwrite(to);  // write the log
    80004a00:	854e                	mv	a0,s3
    80004a02:	fffff097          	auipc	ra,0xfffff
    80004a06:	d32080e7          	jalr	-718(ra) # 80003734 <bwrite>
    brelse(from);
    80004a0a:	8556                	mv	a0,s5
    80004a0c:	fffff097          	auipc	ra,0xfffff
    80004a10:	d68080e7          	jalr	-664(ra) # 80003774 <brelse>
    brelse(to);
    80004a14:	854e                	mv	a0,s3
    80004a16:	fffff097          	auipc	ra,0xfffff
    80004a1a:	d5e080e7          	jalr	-674(ra) # 80003774 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004a1e:	2a05                	addiw	s4,s4,1
    80004a20:	0b11                	addi	s6,s6,4
    80004a22:	044ba783          	lw	a5,68(s7)
    80004a26:	fafa40e3          	blt	s4,a5,800049c6 <end_op+0x104>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    80004a2a:	854a                	mv	a0,s2
    80004a2c:	00000097          	auipc	ra,0x0
    80004a30:	bde080e7          	jalr	-1058(ra) # 8000460a <write_head>
    install_trans(dev); // Now install writes to home locations
    80004a34:	854a                	mv	a0,s2
    80004a36:	00000097          	auipc	ra,0x0
    80004a3a:	c4e080e7          	jalr	-946(ra) # 80004684 <install_trans>
    log[dev].lh.n = 0;
    80004a3e:	00191793          	slli	a5,s2,0x1
    80004a42:	97ca                	add	a5,a5,s2
    80004a44:	079a                	slli	a5,a5,0x6
    80004a46:	00022717          	auipc	a4,0x22
    80004a4a:	fd270713          	addi	a4,a4,-46 # 80026a18 <log>
    80004a4e:	97ba                	add	a5,a5,a4
    80004a50:	0407a223          	sw	zero,68(a5)
    write_head(dev);    // Erase the transaction from the log
    80004a54:	854a                	mv	a0,s2
    80004a56:	00000097          	auipc	ra,0x0
    80004a5a:	bb4080e7          	jalr	-1100(ra) # 8000460a <write_head>
    80004a5e:	bde1                	j	80004936 <end_op+0x74>

0000000080004a60 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a60:	7179                	addi	sp,sp,-48
    80004a62:	f406                	sd	ra,40(sp)
    80004a64:	f022                	sd	s0,32(sp)
    80004a66:	ec26                	sd	s1,24(sp)
    80004a68:	e84a                	sd	s2,16(sp)
    80004a6a:	e44e                	sd	s3,8(sp)
    80004a6c:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004a6e:	4504                	lw	s1,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004a70:	00149793          	slli	a5,s1,0x1
    80004a74:	97a6                	add	a5,a5,s1
    80004a76:	079a                	slli	a5,a5,0x6
    80004a78:	00022717          	auipc	a4,0x22
    80004a7c:	fa070713          	addi	a4,a4,-96 # 80026a18 <log>
    80004a80:	97ba                	add	a5,a5,a4
    80004a82:	43f4                	lw	a3,68(a5)
    80004a84:	47f5                	li	a5,29
    80004a86:	0ad7c863          	blt	a5,a3,80004b36 <log_write+0xd6>
    80004a8a:	89aa                	mv	s3,a0
    80004a8c:	00149793          	slli	a5,s1,0x1
    80004a90:	97a6                	add	a5,a5,s1
    80004a92:	079a                	slli	a5,a5,0x6
    80004a94:	97ba                	add	a5,a5,a4
    80004a96:	5bdc                	lw	a5,52(a5)
    80004a98:	37fd                	addiw	a5,a5,-1
    80004a9a:	08f6de63          	bge	a3,a5,80004b36 <log_write+0xd6>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004a9e:	00149793          	slli	a5,s1,0x1
    80004aa2:	97a6                	add	a5,a5,s1
    80004aa4:	079a                	slli	a5,a5,0x6
    80004aa6:	00022717          	auipc	a4,0x22
    80004aaa:	f7270713          	addi	a4,a4,-142 # 80026a18 <log>
    80004aae:	97ba                	add	a5,a5,a4
    80004ab0:	5f9c                	lw	a5,56(a5)
    80004ab2:	08f05a63          	blez	a5,80004b46 <log_write+0xe6>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004ab6:	00149913          	slli	s2,s1,0x1
    80004aba:	9926                	add	s2,s2,s1
    80004abc:	00691793          	slli	a5,s2,0x6
    80004ac0:	00022917          	auipc	s2,0x22
    80004ac4:	f5890913          	addi	s2,s2,-168 # 80026a18 <log>
    80004ac8:	993e                	add	s2,s2,a5
    80004aca:	854a                	mv	a0,s2
    80004acc:	ffffc097          	auipc	ra,0xffffc
    80004ad0:	1bc080e7          	jalr	444(ra) # 80000c88 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004ad4:	04492603          	lw	a2,68(s2)
    80004ad8:	06c05f63          	blez	a2,80004b56 <log_write+0xf6>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004adc:	00c9a583          	lw	a1,12(s3)
    80004ae0:	874a                	mv	a4,s2
  for (i = 0; i < log[dev].lh.n; i++) {
    80004ae2:	4781                	li	a5,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004ae4:	4734                	lw	a3,72(a4)
    80004ae6:	06b68963          	beq	a3,a1,80004b58 <log_write+0xf8>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004aea:	2785                	addiw	a5,a5,1
    80004aec:	0711                	addi	a4,a4,4
    80004aee:	fec79be3          	bne	a5,a2,80004ae4 <log_write+0x84>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004af2:	00149793          	slli	a5,s1,0x1
    80004af6:	97a6                	add	a5,a5,s1
    80004af8:	0792                	slli	a5,a5,0x4
    80004afa:	97b2                	add	a5,a5,a2
    80004afc:	07c1                	addi	a5,a5,16
    80004afe:	078a                	slli	a5,a5,0x2
    80004b00:	00022717          	auipc	a4,0x22
    80004b04:	f1870713          	addi	a4,a4,-232 # 80026a18 <log>
    80004b08:	97ba                	add	a5,a5,a4
    80004b0a:	00c9a703          	lw	a4,12(s3)
    80004b0e:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    80004b10:	854e                	mv	a0,s3
    80004b12:	fffff097          	auipc	ra,0xfffff
    80004b16:	d00080e7          	jalr	-768(ra) # 80003812 <bpin>
    log[dev].lh.n++;
    80004b1a:	00022697          	auipc	a3,0x22
    80004b1e:	efe68693          	addi	a3,a3,-258 # 80026a18 <log>
    80004b22:	00149793          	slli	a5,s1,0x1
    80004b26:	00978733          	add	a4,a5,s1
    80004b2a:	071a                	slli	a4,a4,0x6
    80004b2c:	9736                	add	a4,a4,a3
    80004b2e:	437c                	lw	a5,68(a4)
    80004b30:	2785                	addiw	a5,a5,1
    80004b32:	c37c                	sw	a5,68(a4)
    80004b34:	a099                	j	80004b7a <log_write+0x11a>
    panic("too big a transaction");
    80004b36:	00004517          	auipc	a0,0x4
    80004b3a:	05a50513          	addi	a0,a0,90 # 80008b90 <userret+0xb00>
    80004b3e:	ffffc097          	auipc	ra,0xffffc
    80004b42:	c18080e7          	jalr	-1000(ra) # 80000756 <panic>
    panic("log_write outside of trans");
    80004b46:	00004517          	auipc	a0,0x4
    80004b4a:	06250513          	addi	a0,a0,98 # 80008ba8 <userret+0xb18>
    80004b4e:	ffffc097          	auipc	ra,0xffffc
    80004b52:	c08080e7          	jalr	-1016(ra) # 80000756 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004b56:	4781                	li	a5,0
  log[dev].lh.block[i] = b->blockno;
    80004b58:	00149713          	slli	a4,s1,0x1
    80004b5c:	9726                	add	a4,a4,s1
    80004b5e:	0712                	slli	a4,a4,0x4
    80004b60:	973e                	add	a4,a4,a5
    80004b62:	0741                	addi	a4,a4,16
    80004b64:	070a                	slli	a4,a4,0x2
    80004b66:	00022697          	auipc	a3,0x22
    80004b6a:	eb268693          	addi	a3,a3,-334 # 80026a18 <log>
    80004b6e:	9736                	add	a4,a4,a3
    80004b70:	00c9a683          	lw	a3,12(s3)
    80004b74:	c714                	sw	a3,8(a4)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004b76:	f8f60de3          	beq	a2,a5,80004b10 <log_write+0xb0>
  }
  release(&log[dev].lock);
    80004b7a:	854a                	mv	a0,s2
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	358080e7          	jalr	856(ra) # 80000ed4 <release>
}
    80004b84:	70a2                	ld	ra,40(sp)
    80004b86:	7402                	ld	s0,32(sp)
    80004b88:	64e2                	ld	s1,24(sp)
    80004b8a:	6942                	ld	s2,16(sp)
    80004b8c:	69a2                	ld	s3,8(sp)
    80004b8e:	6145                	addi	sp,sp,48
    80004b90:	8082                	ret

0000000080004b92 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b92:	1101                	addi	sp,sp,-32
    80004b94:	ec06                	sd	ra,24(sp)
    80004b96:	e822                	sd	s0,16(sp)
    80004b98:	e426                	sd	s1,8(sp)
    80004b9a:	e04a                	sd	s2,0(sp)
    80004b9c:	1000                	addi	s0,sp,32
    80004b9e:	84aa                	mv	s1,a0
    80004ba0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004ba2:	00004597          	auipc	a1,0x4
    80004ba6:	02658593          	addi	a1,a1,38 # 80008bc8 <userret+0xb38>
    80004baa:	0521                	addi	a0,a0,8
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	f72080e7          	jalr	-142(ra) # 80000b1e <initlock>
  lk->name = name;
    80004bb4:	0324bc23          	sd	s2,56(s1)
  lk->locked = 0;
    80004bb8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bbc:	0404a023          	sw	zero,64(s1)
}
    80004bc0:	60e2                	ld	ra,24(sp)
    80004bc2:	6442                	ld	s0,16(sp)
    80004bc4:	64a2                	ld	s1,8(sp)
    80004bc6:	6902                	ld	s2,0(sp)
    80004bc8:	6105                	addi	sp,sp,32
    80004bca:	8082                	ret

0000000080004bcc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004bcc:	1101                	addi	sp,sp,-32
    80004bce:	ec06                	sd	ra,24(sp)
    80004bd0:	e822                	sd	s0,16(sp)
    80004bd2:	e426                	sd	s1,8(sp)
    80004bd4:	e04a                	sd	s2,0(sp)
    80004bd6:	1000                	addi	s0,sp,32
    80004bd8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bda:	00850913          	addi	s2,a0,8
    80004bde:	854a                	mv	a0,s2
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	0a8080e7          	jalr	168(ra) # 80000c88 <acquire>
  while (lk->locked) {
    80004be8:	409c                	lw	a5,0(s1)
    80004bea:	cb89                	beqz	a5,80004bfc <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004bec:	85ca                	mv	a1,s2
    80004bee:	8526                	mv	a0,s1
    80004bf0:	ffffe097          	auipc	ra,0xffffe
    80004bf4:	c8c080e7          	jalr	-884(ra) # 8000287c <sleep>
  while (lk->locked) {
    80004bf8:	409c                	lw	a5,0(s1)
    80004bfa:	fbed                	bnez	a5,80004bec <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004bfc:	4785                	li	a5,1
    80004bfe:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c00:	ffffd097          	auipc	ra,0xffffd
    80004c04:	39c080e7          	jalr	924(ra) # 80001f9c <myproc>
    80004c08:	493c                	lw	a5,80(a0)
    80004c0a:	c0bc                	sw	a5,64(s1)
  release(&lk->lk);
    80004c0c:	854a                	mv	a0,s2
    80004c0e:	ffffc097          	auipc	ra,0xffffc
    80004c12:	2c6080e7          	jalr	710(ra) # 80000ed4 <release>
}
    80004c16:	60e2                	ld	ra,24(sp)
    80004c18:	6442                	ld	s0,16(sp)
    80004c1a:	64a2                	ld	s1,8(sp)
    80004c1c:	6902                	ld	s2,0(sp)
    80004c1e:	6105                	addi	sp,sp,32
    80004c20:	8082                	ret

0000000080004c22 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c22:	1101                	addi	sp,sp,-32
    80004c24:	ec06                	sd	ra,24(sp)
    80004c26:	e822                	sd	s0,16(sp)
    80004c28:	e426                	sd	s1,8(sp)
    80004c2a:	e04a                	sd	s2,0(sp)
    80004c2c:	1000                	addi	s0,sp,32
    80004c2e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c30:	00850913          	addi	s2,a0,8
    80004c34:	854a                	mv	a0,s2
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	052080e7          	jalr	82(ra) # 80000c88 <acquire>
  lk->locked = 0;
    80004c3e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c42:	0404a023          	sw	zero,64(s1)
  wakeup(lk);
    80004c46:	8526                	mv	a0,s1
    80004c48:	ffffe097          	auipc	ra,0xffffe
    80004c4c:	dba080e7          	jalr	-582(ra) # 80002a02 <wakeup>
  release(&lk->lk);
    80004c50:	854a                	mv	a0,s2
    80004c52:	ffffc097          	auipc	ra,0xffffc
    80004c56:	282080e7          	jalr	642(ra) # 80000ed4 <release>
}
    80004c5a:	60e2                	ld	ra,24(sp)
    80004c5c:	6442                	ld	s0,16(sp)
    80004c5e:	64a2                	ld	s1,8(sp)
    80004c60:	6902                	ld	s2,0(sp)
    80004c62:	6105                	addi	sp,sp,32
    80004c64:	8082                	ret

0000000080004c66 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c66:	7179                	addi	sp,sp,-48
    80004c68:	f406                	sd	ra,40(sp)
    80004c6a:	f022                	sd	s0,32(sp)
    80004c6c:	ec26                	sd	s1,24(sp)
    80004c6e:	e84a                	sd	s2,16(sp)
    80004c70:	e44e                	sd	s3,8(sp)
    80004c72:	1800                	addi	s0,sp,48
    80004c74:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c76:	00850913          	addi	s2,a0,8
    80004c7a:	854a                	mv	a0,s2
    80004c7c:	ffffc097          	auipc	ra,0xffffc
    80004c80:	00c080e7          	jalr	12(ra) # 80000c88 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c84:	409c                	lw	a5,0(s1)
    80004c86:	ef99                	bnez	a5,80004ca4 <holdingsleep+0x3e>
    80004c88:	4481                	li	s1,0
  release(&lk->lk);
    80004c8a:	854a                	mv	a0,s2
    80004c8c:	ffffc097          	auipc	ra,0xffffc
    80004c90:	248080e7          	jalr	584(ra) # 80000ed4 <release>
  return r;
}
    80004c94:	8526                	mv	a0,s1
    80004c96:	70a2                	ld	ra,40(sp)
    80004c98:	7402                	ld	s0,32(sp)
    80004c9a:	64e2                	ld	s1,24(sp)
    80004c9c:	6942                	ld	s2,16(sp)
    80004c9e:	69a2                	ld	s3,8(sp)
    80004ca0:	6145                	addi	sp,sp,48
    80004ca2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ca4:	0404a983          	lw	s3,64(s1)
    80004ca8:	ffffd097          	auipc	ra,0xffffd
    80004cac:	2f4080e7          	jalr	756(ra) # 80001f9c <myproc>
    80004cb0:	4924                	lw	s1,80(a0)
    80004cb2:	413484b3          	sub	s1,s1,s3
    80004cb6:	0014b493          	seqz	s1,s1
    80004cba:	bfc1                	j	80004c8a <holdingsleep+0x24>

0000000080004cbc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004cbc:	1141                	addi	sp,sp,-16
    80004cbe:	e406                	sd	ra,8(sp)
    80004cc0:	e022                	sd	s0,0(sp)
    80004cc2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004cc4:	00004597          	auipc	a1,0x4
    80004cc8:	f1458593          	addi	a1,a1,-236 # 80008bd8 <userret+0xb48>
    80004ccc:	00022517          	auipc	a0,0x22
    80004cd0:	f6c50513          	addi	a0,a0,-148 # 80026c38 <ftable>
    80004cd4:	ffffc097          	auipc	ra,0xffffc
    80004cd8:	e4a080e7          	jalr	-438(ra) # 80000b1e <initlock>
}
    80004cdc:	60a2                	ld	ra,8(sp)
    80004cde:	6402                	ld	s0,0(sp)
    80004ce0:	0141                	addi	sp,sp,16
    80004ce2:	8082                	ret

0000000080004ce4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004ce4:	1101                	addi	sp,sp,-32
    80004ce6:	ec06                	sd	ra,24(sp)
    80004ce8:	e822                	sd	s0,16(sp)
    80004cea:	e426                	sd	s1,8(sp)
    80004cec:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004cee:	00022517          	auipc	a0,0x22
    80004cf2:	f4a50513          	addi	a0,a0,-182 # 80026c38 <ftable>
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	f92080e7          	jalr	-110(ra) # 80000c88 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004cfe:	00022497          	auipc	s1,0x22
    80004d02:	f6a48493          	addi	s1,s1,-150 # 80026c68 <ftable+0x30>
    80004d06:	00023717          	auipc	a4,0x23
    80004d0a:	f0270713          	addi	a4,a4,-254 # 80027c08 <ftable+0xfd0>
    if(f->ref == 0){
    80004d0e:	40dc                	lw	a5,4(s1)
    80004d10:	cf99                	beqz	a5,80004d2e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d12:	02848493          	addi	s1,s1,40
    80004d16:	fee49ce3          	bne	s1,a4,80004d0e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004d1a:	00022517          	auipc	a0,0x22
    80004d1e:	f1e50513          	addi	a0,a0,-226 # 80026c38 <ftable>
    80004d22:	ffffc097          	auipc	ra,0xffffc
    80004d26:	1b2080e7          	jalr	434(ra) # 80000ed4 <release>
  return 0;
    80004d2a:	4481                	li	s1,0
    80004d2c:	a819                	j	80004d42 <filealloc+0x5e>
      f->ref = 1;
    80004d2e:	4785                	li	a5,1
    80004d30:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004d32:	00022517          	auipc	a0,0x22
    80004d36:	f0650513          	addi	a0,a0,-250 # 80026c38 <ftable>
    80004d3a:	ffffc097          	auipc	ra,0xffffc
    80004d3e:	19a080e7          	jalr	410(ra) # 80000ed4 <release>
}
    80004d42:	8526                	mv	a0,s1
    80004d44:	60e2                	ld	ra,24(sp)
    80004d46:	6442                	ld	s0,16(sp)
    80004d48:	64a2                	ld	s1,8(sp)
    80004d4a:	6105                	addi	sp,sp,32
    80004d4c:	8082                	ret

0000000080004d4e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004d4e:	1101                	addi	sp,sp,-32
    80004d50:	ec06                	sd	ra,24(sp)
    80004d52:	e822                	sd	s0,16(sp)
    80004d54:	e426                	sd	s1,8(sp)
    80004d56:	1000                	addi	s0,sp,32
    80004d58:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004d5a:	00022517          	auipc	a0,0x22
    80004d5e:	ede50513          	addi	a0,a0,-290 # 80026c38 <ftable>
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	f26080e7          	jalr	-218(ra) # 80000c88 <acquire>
  if(f->ref < 1)
    80004d6a:	40dc                	lw	a5,4(s1)
    80004d6c:	02f05263          	blez	a5,80004d90 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d70:	2785                	addiw	a5,a5,1
    80004d72:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d74:	00022517          	auipc	a0,0x22
    80004d78:	ec450513          	addi	a0,a0,-316 # 80026c38 <ftable>
    80004d7c:	ffffc097          	auipc	ra,0xffffc
    80004d80:	158080e7          	jalr	344(ra) # 80000ed4 <release>
  return f;
}
    80004d84:	8526                	mv	a0,s1
    80004d86:	60e2                	ld	ra,24(sp)
    80004d88:	6442                	ld	s0,16(sp)
    80004d8a:	64a2                	ld	s1,8(sp)
    80004d8c:	6105                	addi	sp,sp,32
    80004d8e:	8082                	ret
    panic("filedup");
    80004d90:	00004517          	auipc	a0,0x4
    80004d94:	e5050513          	addi	a0,a0,-432 # 80008be0 <userret+0xb50>
    80004d98:	ffffc097          	auipc	ra,0xffffc
    80004d9c:	9be080e7          	jalr	-1602(ra) # 80000756 <panic>

0000000080004da0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004da0:	7139                	addi	sp,sp,-64
    80004da2:	fc06                	sd	ra,56(sp)
    80004da4:	f822                	sd	s0,48(sp)
    80004da6:	f426                	sd	s1,40(sp)
    80004da8:	f04a                	sd	s2,32(sp)
    80004daa:	ec4e                	sd	s3,24(sp)
    80004dac:	e852                	sd	s4,16(sp)
    80004dae:	e456                	sd	s5,8(sp)
    80004db0:	0080                	addi	s0,sp,64
    80004db2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004db4:	00022517          	auipc	a0,0x22
    80004db8:	e8450513          	addi	a0,a0,-380 # 80026c38 <ftable>
    80004dbc:	ffffc097          	auipc	ra,0xffffc
    80004dc0:	ecc080e7          	jalr	-308(ra) # 80000c88 <acquire>
  if(f->ref < 1)
    80004dc4:	40dc                	lw	a5,4(s1)
    80004dc6:	06f05563          	blez	a5,80004e30 <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004dca:	37fd                	addiw	a5,a5,-1
    80004dcc:	0007871b          	sext.w	a4,a5
    80004dd0:	c0dc                	sw	a5,4(s1)
    80004dd2:	06e04763          	bgtz	a4,80004e40 <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004dd6:	0004a903          	lw	s2,0(s1)
    80004dda:	0094ca83          	lbu	s5,9(s1)
    80004dde:	0104ba03          	ld	s4,16(s1)
    80004de2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004de6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004dea:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004dee:	00022517          	auipc	a0,0x22
    80004df2:	e4a50513          	addi	a0,a0,-438 # 80026c38 <ftable>
    80004df6:	ffffc097          	auipc	ra,0xffffc
    80004dfa:	0de080e7          	jalr	222(ra) # 80000ed4 <release>

  if(ff.type == FD_PIPE){
    80004dfe:	4785                	li	a5,1
    80004e00:	06f90163          	beq	s2,a5,80004e62 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e04:	3979                	addiw	s2,s2,-2
    80004e06:	4785                	li	a5,1
    80004e08:	0527e463          	bltu	a5,s2,80004e50 <fileclose+0xb0>
    begin_op(ff.ip->dev);
    80004e0c:	0009a503          	lw	a0,0(s3)
    80004e10:	00000097          	auipc	ra,0x0
    80004e14:	a06080e7          	jalr	-1530(ra) # 80004816 <begin_op>
    iput(ff.ip);
    80004e18:	854e                	mv	a0,s3
    80004e1a:	fffff097          	auipc	ra,0xfffff
    80004e1e:	13a080e7          	jalr	314(ra) # 80003f54 <iput>
    end_op(ff.ip->dev);
    80004e22:	0009a503          	lw	a0,0(s3)
    80004e26:	00000097          	auipc	ra,0x0
    80004e2a:	a9c080e7          	jalr	-1380(ra) # 800048c2 <end_op>
    80004e2e:	a00d                	j	80004e50 <fileclose+0xb0>
    panic("fileclose");
    80004e30:	00004517          	auipc	a0,0x4
    80004e34:	db850513          	addi	a0,a0,-584 # 80008be8 <userret+0xb58>
    80004e38:	ffffc097          	auipc	ra,0xffffc
    80004e3c:	91e080e7          	jalr	-1762(ra) # 80000756 <panic>
    release(&ftable.lock);
    80004e40:	00022517          	auipc	a0,0x22
    80004e44:	df850513          	addi	a0,a0,-520 # 80026c38 <ftable>
    80004e48:	ffffc097          	auipc	ra,0xffffc
    80004e4c:	08c080e7          	jalr	140(ra) # 80000ed4 <release>
  }
}
    80004e50:	70e2                	ld	ra,56(sp)
    80004e52:	7442                	ld	s0,48(sp)
    80004e54:	74a2                	ld	s1,40(sp)
    80004e56:	7902                	ld	s2,32(sp)
    80004e58:	69e2                	ld	s3,24(sp)
    80004e5a:	6a42                	ld	s4,16(sp)
    80004e5c:	6aa2                	ld	s5,8(sp)
    80004e5e:	6121                	addi	sp,sp,64
    80004e60:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004e62:	85d6                	mv	a1,s5
    80004e64:	8552                	mv	a0,s4
    80004e66:	00000097          	auipc	ra,0x0
    80004e6a:	376080e7          	jalr	886(ra) # 800051dc <pipeclose>
    80004e6e:	b7cd                	j	80004e50 <fileclose+0xb0>

0000000080004e70 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004e70:	715d                	addi	sp,sp,-80
    80004e72:	e486                	sd	ra,72(sp)
    80004e74:	e0a2                	sd	s0,64(sp)
    80004e76:	fc26                	sd	s1,56(sp)
    80004e78:	f84a                	sd	s2,48(sp)
    80004e7a:	f44e                	sd	s3,40(sp)
    80004e7c:	0880                	addi	s0,sp,80
    80004e7e:	84aa                	mv	s1,a0
    80004e80:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	11a080e7          	jalr	282(ra) # 80001f9c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e8a:	409c                	lw	a5,0(s1)
    80004e8c:	37f9                	addiw	a5,a5,-2
    80004e8e:	4705                	li	a4,1
    80004e90:	04f76763          	bltu	a4,a5,80004ede <filestat+0x6e>
    80004e94:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e96:	6c88                	ld	a0,24(s1)
    80004e98:	fffff097          	auipc	ra,0xfffff
    80004e9c:	fae080e7          	jalr	-82(ra) # 80003e46 <ilock>
    stati(f->ip, &st);
    80004ea0:	fb840593          	addi	a1,s0,-72
    80004ea4:	6c88                	ld	a0,24(s1)
    80004ea6:	fffff097          	auipc	ra,0xfffff
    80004eaa:	206080e7          	jalr	518(ra) # 800040ac <stati>
    iunlock(f->ip);
    80004eae:	6c88                	ld	a0,24(s1)
    80004eb0:	fffff097          	auipc	ra,0xfffff
    80004eb4:	058080e7          	jalr	88(ra) # 80003f08 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004eb8:	46e1                	li	a3,24
    80004eba:	fb840613          	addi	a2,s0,-72
    80004ebe:	85ce                	mv	a1,s3
    80004ec0:	06893503          	ld	a0,104(s2)
    80004ec4:	ffffd097          	auipc	ra,0xffffd
    80004ec8:	cda080e7          	jalr	-806(ra) # 80001b9e <copyout>
    80004ecc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ed0:	60a6                	ld	ra,72(sp)
    80004ed2:	6406                	ld	s0,64(sp)
    80004ed4:	74e2                	ld	s1,56(sp)
    80004ed6:	7942                	ld	s2,48(sp)
    80004ed8:	79a2                	ld	s3,40(sp)
    80004eda:	6161                	addi	sp,sp,80
    80004edc:	8082                	ret
  return -1;
    80004ede:	557d                	li	a0,-1
    80004ee0:	bfc5                	j	80004ed0 <filestat+0x60>

0000000080004ee2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ee2:	7179                	addi	sp,sp,-48
    80004ee4:	f406                	sd	ra,40(sp)
    80004ee6:	f022                	sd	s0,32(sp)
    80004ee8:	ec26                	sd	s1,24(sp)
    80004eea:	e84a                	sd	s2,16(sp)
    80004eec:	e44e                	sd	s3,8(sp)
    80004eee:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004ef0:	00854783          	lbu	a5,8(a0)
    80004ef4:	c7c5                	beqz	a5,80004f9c <fileread+0xba>
    80004ef6:	84aa                	mv	s1,a0
    80004ef8:	89ae                	mv	s3,a1
    80004efa:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004efc:	411c                	lw	a5,0(a0)
    80004efe:	4705                	li	a4,1
    80004f00:	04e78963          	beq	a5,a4,80004f52 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f04:	470d                	li	a4,3
    80004f06:	04e78d63          	beq	a5,a4,80004f60 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004f0a:	4709                	li	a4,2
    80004f0c:	08e79063          	bne	a5,a4,80004f8c <fileread+0xaa>
    ilock(f->ip);
    80004f10:	6d08                	ld	a0,24(a0)
    80004f12:	fffff097          	auipc	ra,0xfffff
    80004f16:	f34080e7          	jalr	-204(ra) # 80003e46 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f1a:	874a                	mv	a4,s2
    80004f1c:	5094                	lw	a3,32(s1)
    80004f1e:	864e                	mv	a2,s3
    80004f20:	4585                	li	a1,1
    80004f22:	6c88                	ld	a0,24(s1)
    80004f24:	fffff097          	auipc	ra,0xfffff
    80004f28:	1b2080e7          	jalr	434(ra) # 800040d6 <readi>
    80004f2c:	892a                	mv	s2,a0
    80004f2e:	00a05563          	blez	a0,80004f38 <fileread+0x56>
      f->off += r;
    80004f32:	509c                	lw	a5,32(s1)
    80004f34:	9fa9                	addw	a5,a5,a0
    80004f36:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004f38:	6c88                	ld	a0,24(s1)
    80004f3a:	fffff097          	auipc	ra,0xfffff
    80004f3e:	fce080e7          	jalr	-50(ra) # 80003f08 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004f42:	854a                	mv	a0,s2
    80004f44:	70a2                	ld	ra,40(sp)
    80004f46:	7402                	ld	s0,32(sp)
    80004f48:	64e2                	ld	s1,24(sp)
    80004f4a:	6942                	ld	s2,16(sp)
    80004f4c:	69a2                	ld	s3,8(sp)
    80004f4e:	6145                	addi	sp,sp,48
    80004f50:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004f52:	6908                	ld	a0,16(a0)
    80004f54:	00000097          	auipc	ra,0x0
    80004f58:	40c080e7          	jalr	1036(ra) # 80005360 <piperead>
    80004f5c:	892a                	mv	s2,a0
    80004f5e:	b7d5                	j	80004f42 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004f60:	02451783          	lh	a5,36(a0)
    80004f64:	03079693          	slli	a3,a5,0x30
    80004f68:	92c1                	srli	a3,a3,0x30
    80004f6a:	4725                	li	a4,9
    80004f6c:	02d76a63          	bltu	a4,a3,80004fa0 <fileread+0xbe>
    80004f70:	0792                	slli	a5,a5,0x4
    80004f72:	00022717          	auipc	a4,0x22
    80004f76:	c2670713          	addi	a4,a4,-986 # 80026b98 <devsw>
    80004f7a:	97ba                	add	a5,a5,a4
    80004f7c:	639c                	ld	a5,0(a5)
    80004f7e:	c39d                	beqz	a5,80004fa4 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004f80:	86b2                	mv	a3,a2
    80004f82:	862e                	mv	a2,a1
    80004f84:	4585                	li	a1,1
    80004f86:	9782                	jalr	a5
    80004f88:	892a                	mv	s2,a0
    80004f8a:	bf65                	j	80004f42 <fileread+0x60>
    panic("fileread");
    80004f8c:	00004517          	auipc	a0,0x4
    80004f90:	c6c50513          	addi	a0,a0,-916 # 80008bf8 <userret+0xb68>
    80004f94:	ffffb097          	auipc	ra,0xffffb
    80004f98:	7c2080e7          	jalr	1986(ra) # 80000756 <panic>
    return -1;
    80004f9c:	597d                	li	s2,-1
    80004f9e:	b755                	j	80004f42 <fileread+0x60>
      return -1;
    80004fa0:	597d                	li	s2,-1
    80004fa2:	b745                	j	80004f42 <fileread+0x60>
    80004fa4:	597d                	li	s2,-1
    80004fa6:	bf71                	j	80004f42 <fileread+0x60>

0000000080004fa8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004fa8:	00954783          	lbu	a5,9(a0)
    80004fac:	14078663          	beqz	a5,800050f8 <filewrite+0x150>
{
    80004fb0:	715d                	addi	sp,sp,-80
    80004fb2:	e486                	sd	ra,72(sp)
    80004fb4:	e0a2                	sd	s0,64(sp)
    80004fb6:	fc26                	sd	s1,56(sp)
    80004fb8:	f84a                	sd	s2,48(sp)
    80004fba:	f44e                	sd	s3,40(sp)
    80004fbc:	f052                	sd	s4,32(sp)
    80004fbe:	ec56                	sd	s5,24(sp)
    80004fc0:	e85a                	sd	s6,16(sp)
    80004fc2:	e45e                	sd	s7,8(sp)
    80004fc4:	e062                	sd	s8,0(sp)
    80004fc6:	0880                	addi	s0,sp,80
    80004fc8:	84aa                	mv	s1,a0
    80004fca:	8aae                	mv	s5,a1
    80004fcc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004fce:	411c                	lw	a5,0(a0)
    80004fd0:	4705                	li	a4,1
    80004fd2:	02e78263          	beq	a5,a4,80004ff6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004fd6:	470d                	li	a4,3
    80004fd8:	02e78563          	beq	a5,a4,80005002 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004fdc:	4709                	li	a4,2
    80004fde:	10e79563          	bne	a5,a4,800050e8 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004fe2:	0ec05f63          	blez	a2,800050e0 <filewrite+0x138>
    int i = 0;
    80004fe6:	4981                	li	s3,0
    80004fe8:	6b05                	lui	s6,0x1
    80004fea:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004fee:	6b85                	lui	s7,0x1
    80004ff0:	c00b8b9b          	addiw	s7,s7,-1024
    80004ff4:	a851                	j	80005088 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004ff6:	6908                	ld	a0,16(a0)
    80004ff8:	00000097          	auipc	ra,0x0
    80004ffc:	254080e7          	jalr	596(ra) # 8000524c <pipewrite>
    80005000:	a865                	j	800050b8 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005002:	02451783          	lh	a5,36(a0)
    80005006:	03079693          	slli	a3,a5,0x30
    8000500a:	92c1                	srli	a3,a3,0x30
    8000500c:	4725                	li	a4,9
    8000500e:	0ed76763          	bltu	a4,a3,800050fc <filewrite+0x154>
    80005012:	0792                	slli	a5,a5,0x4
    80005014:	00022717          	auipc	a4,0x22
    80005018:	b8470713          	addi	a4,a4,-1148 # 80026b98 <devsw>
    8000501c:	97ba                	add	a5,a5,a4
    8000501e:	679c                	ld	a5,8(a5)
    80005020:	c3e5                	beqz	a5,80005100 <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    80005022:	86b2                	mv	a3,a2
    80005024:	862e                	mv	a2,a1
    80005026:	4585                	li	a1,1
    80005028:	9782                	jalr	a5
    8000502a:	a079                	j	800050b8 <filewrite+0x110>
    8000502c:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80005030:	6c9c                	ld	a5,24(s1)
    80005032:	4388                	lw	a0,0(a5)
    80005034:	fffff097          	auipc	ra,0xfffff
    80005038:	7e2080e7          	jalr	2018(ra) # 80004816 <begin_op>
      ilock(f->ip);
    8000503c:	6c88                	ld	a0,24(s1)
    8000503e:	fffff097          	auipc	ra,0xfffff
    80005042:	e08080e7          	jalr	-504(ra) # 80003e46 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005046:	8762                	mv	a4,s8
    80005048:	5094                	lw	a3,32(s1)
    8000504a:	01598633          	add	a2,s3,s5
    8000504e:	4585                	li	a1,1
    80005050:	6c88                	ld	a0,24(s1)
    80005052:	fffff097          	auipc	ra,0xfffff
    80005056:	178080e7          	jalr	376(ra) # 800041ca <writei>
    8000505a:	892a                	mv	s2,a0
    8000505c:	02a05e63          	blez	a0,80005098 <filewrite+0xf0>
        f->off += r;
    80005060:	509c                	lw	a5,32(s1)
    80005062:	9fa9                	addw	a5,a5,a0
    80005064:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80005066:	6c88                	ld	a0,24(s1)
    80005068:	fffff097          	auipc	ra,0xfffff
    8000506c:	ea0080e7          	jalr	-352(ra) # 80003f08 <iunlock>
      end_op(f->ip->dev);
    80005070:	6c9c                	ld	a5,24(s1)
    80005072:	4388                	lw	a0,0(a5)
    80005074:	00000097          	auipc	ra,0x0
    80005078:	84e080e7          	jalr	-1970(ra) # 800048c2 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    8000507c:	052c1a63          	bne	s8,s2,800050d0 <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80005080:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80005084:	0349d763          	bge	s3,s4,800050b2 <filewrite+0x10a>
      int n1 = n - i;
    80005088:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000508c:	893e                	mv	s2,a5
    8000508e:	2781                	sext.w	a5,a5
    80005090:	f8fb5ee3          	bge	s6,a5,8000502c <filewrite+0x84>
    80005094:	895e                	mv	s2,s7
    80005096:	bf59                	j	8000502c <filewrite+0x84>
      iunlock(f->ip);
    80005098:	6c88                	ld	a0,24(s1)
    8000509a:	fffff097          	auipc	ra,0xfffff
    8000509e:	e6e080e7          	jalr	-402(ra) # 80003f08 <iunlock>
      end_op(f->ip->dev);
    800050a2:	6c9c                	ld	a5,24(s1)
    800050a4:	4388                	lw	a0,0(a5)
    800050a6:	00000097          	auipc	ra,0x0
    800050aa:	81c080e7          	jalr	-2020(ra) # 800048c2 <end_op>
      if(r < 0)
    800050ae:	fc0957e3          	bgez	s2,8000507c <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800050b2:	8552                	mv	a0,s4
    800050b4:	033a1863          	bne	s4,s3,800050e4 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800050b8:	60a6                	ld	ra,72(sp)
    800050ba:	6406                	ld	s0,64(sp)
    800050bc:	74e2                	ld	s1,56(sp)
    800050be:	7942                	ld	s2,48(sp)
    800050c0:	79a2                	ld	s3,40(sp)
    800050c2:	7a02                	ld	s4,32(sp)
    800050c4:	6ae2                	ld	s5,24(sp)
    800050c6:	6b42                	ld	s6,16(sp)
    800050c8:	6ba2                	ld	s7,8(sp)
    800050ca:	6c02                	ld	s8,0(sp)
    800050cc:	6161                	addi	sp,sp,80
    800050ce:	8082                	ret
        panic("short filewrite");
    800050d0:	00004517          	auipc	a0,0x4
    800050d4:	b3850513          	addi	a0,a0,-1224 # 80008c08 <userret+0xb78>
    800050d8:	ffffb097          	auipc	ra,0xffffb
    800050dc:	67e080e7          	jalr	1662(ra) # 80000756 <panic>
    int i = 0;
    800050e0:	4981                	li	s3,0
    800050e2:	bfc1                	j	800050b2 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    800050e4:	557d                	li	a0,-1
    800050e6:	bfc9                	j	800050b8 <filewrite+0x110>
    panic("filewrite");
    800050e8:	00004517          	auipc	a0,0x4
    800050ec:	b3050513          	addi	a0,a0,-1232 # 80008c18 <userret+0xb88>
    800050f0:	ffffb097          	auipc	ra,0xffffb
    800050f4:	666080e7          	jalr	1638(ra) # 80000756 <panic>
    return -1;
    800050f8:	557d                	li	a0,-1
}
    800050fa:	8082                	ret
      return -1;
    800050fc:	557d                	li	a0,-1
    800050fe:	bf6d                	j	800050b8 <filewrite+0x110>
    80005100:	557d                	li	a0,-1
    80005102:	bf5d                	j	800050b8 <filewrite+0x110>

0000000080005104 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005104:	7179                	addi	sp,sp,-48
    80005106:	f406                	sd	ra,40(sp)
    80005108:	f022                	sd	s0,32(sp)
    8000510a:	ec26                	sd	s1,24(sp)
    8000510c:	e84a                	sd	s2,16(sp)
    8000510e:	e44e                	sd	s3,8(sp)
    80005110:	e052                	sd	s4,0(sp)
    80005112:	1800                	addi	s0,sp,48
    80005114:	84aa                	mv	s1,a0
    80005116:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005118:	0005b023          	sd	zero,0(a1)
    8000511c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005120:	00000097          	auipc	ra,0x0
    80005124:	bc4080e7          	jalr	-1084(ra) # 80004ce4 <filealloc>
    80005128:	e088                	sd	a0,0(s1)
    8000512a:	c549                	beqz	a0,800051b4 <pipealloc+0xb0>
    8000512c:	00000097          	auipc	ra,0x0
    80005130:	bb8080e7          	jalr	-1096(ra) # 80004ce4 <filealloc>
    80005134:	00aa3023          	sd	a0,0(s4)
    80005138:	c925                	beqz	a0,800051a8 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000513a:	ffffc097          	auipc	ra,0xffffc
    8000513e:	9ca080e7          	jalr	-1590(ra) # 80000b04 <kalloc>
    80005142:	892a                	mv	s2,a0
    80005144:	cd39                	beqz	a0,800051a2 <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80005146:	4985                	li	s3,1
    80005148:	23352c23          	sw	s3,568(a0)
  pi->writeopen = 1;
    8000514c:	23352e23          	sw	s3,572(a0)
  pi->nwrite = 0;
    80005150:	22052a23          	sw	zero,564(a0)
  pi->nread = 0;
    80005154:	22052823          	sw	zero,560(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80005158:	03000613          	li	a2,48
    8000515c:	4581                	li	a1,0
    8000515e:	ffffc097          	auipc	ra,0xffffc
    80005162:	f76080e7          	jalr	-138(ra) # 800010d4 <memset>
  (*f0)->type = FD_PIPE;
    80005166:	609c                	ld	a5,0(s1)
    80005168:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000516c:	609c                	ld	a5,0(s1)
    8000516e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005172:	609c                	ld	a5,0(s1)
    80005174:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005178:	609c                	ld	a5,0(s1)
    8000517a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000517e:	000a3783          	ld	a5,0(s4)
    80005182:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005186:	000a3783          	ld	a5,0(s4)
    8000518a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000518e:	000a3783          	ld	a5,0(s4)
    80005192:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005196:	000a3783          	ld	a5,0(s4)
    8000519a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000519e:	4501                	li	a0,0
    800051a0:	a025                	j	800051c8 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800051a2:	6088                	ld	a0,0(s1)
    800051a4:	e501                	bnez	a0,800051ac <pipealloc+0xa8>
    800051a6:	a039                	j	800051b4 <pipealloc+0xb0>
    800051a8:	6088                	ld	a0,0(s1)
    800051aa:	c51d                	beqz	a0,800051d8 <pipealloc+0xd4>
    fileclose(*f0);
    800051ac:	00000097          	auipc	ra,0x0
    800051b0:	bf4080e7          	jalr	-1036(ra) # 80004da0 <fileclose>
  if(*f1)
    800051b4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800051b8:	557d                	li	a0,-1
  if(*f1)
    800051ba:	c799                	beqz	a5,800051c8 <pipealloc+0xc4>
    fileclose(*f1);
    800051bc:	853e                	mv	a0,a5
    800051be:	00000097          	auipc	ra,0x0
    800051c2:	be2080e7          	jalr	-1054(ra) # 80004da0 <fileclose>
  return -1;
    800051c6:	557d                	li	a0,-1
}
    800051c8:	70a2                	ld	ra,40(sp)
    800051ca:	7402                	ld	s0,32(sp)
    800051cc:	64e2                	ld	s1,24(sp)
    800051ce:	6942                	ld	s2,16(sp)
    800051d0:	69a2                	ld	s3,8(sp)
    800051d2:	6a02                	ld	s4,0(sp)
    800051d4:	6145                	addi	sp,sp,48
    800051d6:	8082                	ret
  return -1;
    800051d8:	557d                	li	a0,-1
    800051da:	b7fd                	j	800051c8 <pipealloc+0xc4>

00000000800051dc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800051dc:	1101                	addi	sp,sp,-32
    800051de:	ec06                	sd	ra,24(sp)
    800051e0:	e822                	sd	s0,16(sp)
    800051e2:	e426                	sd	s1,8(sp)
    800051e4:	e04a                	sd	s2,0(sp)
    800051e6:	1000                	addi	s0,sp,32
    800051e8:	84aa                	mv	s1,a0
    800051ea:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800051ec:	ffffc097          	auipc	ra,0xffffc
    800051f0:	a9c080e7          	jalr	-1380(ra) # 80000c88 <acquire>
  if(writable){
    800051f4:	02090d63          	beqz	s2,8000522e <pipeclose+0x52>
    pi->writeopen = 0;
    800051f8:	2204ae23          	sw	zero,572(s1)
    wakeup(&pi->nread);
    800051fc:	23048513          	addi	a0,s1,560
    80005200:	ffffe097          	auipc	ra,0xffffe
    80005204:	802080e7          	jalr	-2046(ra) # 80002a02 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005208:	2384b783          	ld	a5,568(s1)
    8000520c:	eb95                	bnez	a5,80005240 <pipeclose+0x64>
    release(&pi->lock);
    8000520e:	8526                	mv	a0,s1
    80005210:	ffffc097          	auipc	ra,0xffffc
    80005214:	cc4080e7          	jalr	-828(ra) # 80000ed4 <release>
    kfree((char*)pi);
    80005218:	8526                	mv	a0,s1
    8000521a:	ffffc097          	auipc	ra,0xffffc
    8000521e:	8d2080e7          	jalr	-1838(ra) # 80000aec <kfree>
  } else
    release(&pi->lock);
}
    80005222:	60e2                	ld	ra,24(sp)
    80005224:	6442                	ld	s0,16(sp)
    80005226:	64a2                	ld	s1,8(sp)
    80005228:	6902                	ld	s2,0(sp)
    8000522a:	6105                	addi	sp,sp,32
    8000522c:	8082                	ret
    pi->readopen = 0;
    8000522e:	2204ac23          	sw	zero,568(s1)
    wakeup(&pi->nwrite);
    80005232:	23448513          	addi	a0,s1,564
    80005236:	ffffd097          	auipc	ra,0xffffd
    8000523a:	7cc080e7          	jalr	1996(ra) # 80002a02 <wakeup>
    8000523e:	b7e9                	j	80005208 <pipeclose+0x2c>
    release(&pi->lock);
    80005240:	8526                	mv	a0,s1
    80005242:	ffffc097          	auipc	ra,0xffffc
    80005246:	c92080e7          	jalr	-878(ra) # 80000ed4 <release>
}
    8000524a:	bfe1                	j	80005222 <pipeclose+0x46>

000000008000524c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000524c:	7159                	addi	sp,sp,-112
    8000524e:	f486                	sd	ra,104(sp)
    80005250:	f0a2                	sd	s0,96(sp)
    80005252:	eca6                	sd	s1,88(sp)
    80005254:	e8ca                	sd	s2,80(sp)
    80005256:	e4ce                	sd	s3,72(sp)
    80005258:	e0d2                	sd	s4,64(sp)
    8000525a:	fc56                	sd	s5,56(sp)
    8000525c:	f85a                	sd	s6,48(sp)
    8000525e:	f45e                	sd	s7,40(sp)
    80005260:	f062                	sd	s8,32(sp)
    80005262:	ec66                	sd	s9,24(sp)
    80005264:	1880                	addi	s0,sp,112
    80005266:	84aa                	mv	s1,a0
    80005268:	8b2e                	mv	s6,a1
    8000526a:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    8000526c:	ffffd097          	auipc	ra,0xffffd
    80005270:	d30080e7          	jalr	-720(ra) # 80001f9c <myproc>
    80005274:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    80005276:	8526                	mv	a0,s1
    80005278:	ffffc097          	auipc	ra,0xffffc
    8000527c:	a10080e7          	jalr	-1520(ra) # 80000c88 <acquire>
  for(i = 0; i < n; i++){
    80005280:	0b505063          	blez	s5,80005320 <pipewrite+0xd4>
    80005284:	8926                	mv	s2,s1
    80005286:	fffa8b9b          	addiw	s7,s5,-1
    8000528a:	1b82                	slli	s7,s7,0x20
    8000528c:	020bdb93          	srli	s7,s7,0x20
    80005290:	001b0793          	addi	a5,s6,1
    80005294:	9bbe                	add	s7,s7,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80005296:	23048a13          	addi	s4,s1,560
      sleep(&pi->nwrite, &pi->lock);
    8000529a:	23448993          	addi	s3,s1,564
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000529e:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800052a0:	2304a783          	lw	a5,560(s1)
    800052a4:	2344a703          	lw	a4,564(s1)
    800052a8:	2007879b          	addiw	a5,a5,512
    800052ac:	02f71e63          	bne	a4,a5,800052e8 <pipewrite+0x9c>
      if(pi->readopen == 0 || myproc()->killed){
    800052b0:	2384a783          	lw	a5,568(s1)
    800052b4:	c3d9                	beqz	a5,8000533a <pipewrite+0xee>
    800052b6:	ffffd097          	auipc	ra,0xffffd
    800052ba:	ce6080e7          	jalr	-794(ra) # 80001f9c <myproc>
    800052be:	453c                	lw	a5,72(a0)
    800052c0:	efad                	bnez	a5,8000533a <pipewrite+0xee>
      wakeup(&pi->nread);
    800052c2:	8552                	mv	a0,s4
    800052c4:	ffffd097          	auipc	ra,0xffffd
    800052c8:	73e080e7          	jalr	1854(ra) # 80002a02 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800052cc:	85ca                	mv	a1,s2
    800052ce:	854e                	mv	a0,s3
    800052d0:	ffffd097          	auipc	ra,0xffffd
    800052d4:	5ac080e7          	jalr	1452(ra) # 8000287c <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800052d8:	2304a783          	lw	a5,560(s1)
    800052dc:	2344a703          	lw	a4,564(s1)
    800052e0:	2007879b          	addiw	a5,a5,512
    800052e4:	fcf706e3          	beq	a4,a5,800052b0 <pipewrite+0x64>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052e8:	4685                	li	a3,1
    800052ea:	865a                	mv	a2,s6
    800052ec:	f9f40593          	addi	a1,s0,-97
    800052f0:	068c3503          	ld	a0,104(s8)
    800052f4:	ffffd097          	auipc	ra,0xffffd
    800052f8:	936080e7          	jalr	-1738(ra) # 80001c2a <copyin>
    800052fc:	03950263          	beq	a0,s9,80005320 <pipewrite+0xd4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005300:	2344a783          	lw	a5,564(s1)
    80005304:	0017871b          	addiw	a4,a5,1
    80005308:	22e4aa23          	sw	a4,564(s1)
    8000530c:	1ff7f793          	andi	a5,a5,511
    80005310:	97a6                	add	a5,a5,s1
    80005312:	f9f44703          	lbu	a4,-97(s0)
    80005316:	02e78823          	sb	a4,48(a5)
  for(i = 0; i < n; i++){
    8000531a:	0b05                	addi	s6,s6,1
    8000531c:	f97b12e3          	bne	s6,s7,800052a0 <pipewrite+0x54>
  }
  wakeup(&pi->nread);
    80005320:	23048513          	addi	a0,s1,560
    80005324:	ffffd097          	auipc	ra,0xffffd
    80005328:	6de080e7          	jalr	1758(ra) # 80002a02 <wakeup>
  release(&pi->lock);
    8000532c:	8526                	mv	a0,s1
    8000532e:	ffffc097          	auipc	ra,0xffffc
    80005332:	ba6080e7          	jalr	-1114(ra) # 80000ed4 <release>
  return n;
    80005336:	8556                	mv	a0,s5
    80005338:	a039                	j	80005346 <pipewrite+0xfa>
        release(&pi->lock);
    8000533a:	8526                	mv	a0,s1
    8000533c:	ffffc097          	auipc	ra,0xffffc
    80005340:	b98080e7          	jalr	-1128(ra) # 80000ed4 <release>
        return -1;
    80005344:	557d                	li	a0,-1
}
    80005346:	70a6                	ld	ra,104(sp)
    80005348:	7406                	ld	s0,96(sp)
    8000534a:	64e6                	ld	s1,88(sp)
    8000534c:	6946                	ld	s2,80(sp)
    8000534e:	69a6                	ld	s3,72(sp)
    80005350:	6a06                	ld	s4,64(sp)
    80005352:	7ae2                	ld	s5,56(sp)
    80005354:	7b42                	ld	s6,48(sp)
    80005356:	7ba2                	ld	s7,40(sp)
    80005358:	7c02                	ld	s8,32(sp)
    8000535a:	6ce2                	ld	s9,24(sp)
    8000535c:	6165                	addi	sp,sp,112
    8000535e:	8082                	ret

0000000080005360 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005360:	715d                	addi	sp,sp,-80
    80005362:	e486                	sd	ra,72(sp)
    80005364:	e0a2                	sd	s0,64(sp)
    80005366:	fc26                	sd	s1,56(sp)
    80005368:	f84a                	sd	s2,48(sp)
    8000536a:	f44e                	sd	s3,40(sp)
    8000536c:	f052                	sd	s4,32(sp)
    8000536e:	ec56                	sd	s5,24(sp)
    80005370:	e85a                	sd	s6,16(sp)
    80005372:	0880                	addi	s0,sp,80
    80005374:	84aa                	mv	s1,a0
    80005376:	892e                	mv	s2,a1
    80005378:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    8000537a:	ffffd097          	auipc	ra,0xffffd
    8000537e:	c22080e7          	jalr	-990(ra) # 80001f9c <myproc>
    80005382:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80005384:	8b26                	mv	s6,s1
    80005386:	8526                	mv	a0,s1
    80005388:	ffffc097          	auipc	ra,0xffffc
    8000538c:	900080e7          	jalr	-1792(ra) # 80000c88 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005390:	2304a703          	lw	a4,560(s1)
    80005394:	2344a783          	lw	a5,564(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005398:	23048993          	addi	s3,s1,560
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000539c:	02f71763          	bne	a4,a5,800053ca <piperead+0x6a>
    800053a0:	23c4a783          	lw	a5,572(s1)
    800053a4:	c39d                	beqz	a5,800053ca <piperead+0x6a>
    if(myproc()->killed){
    800053a6:	ffffd097          	auipc	ra,0xffffd
    800053aa:	bf6080e7          	jalr	-1034(ra) # 80001f9c <myproc>
    800053ae:	453c                	lw	a5,72(a0)
    800053b0:	ebc1                	bnez	a5,80005440 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053b2:	85da                	mv	a1,s6
    800053b4:	854e                	mv	a0,s3
    800053b6:	ffffd097          	auipc	ra,0xffffd
    800053ba:	4c6080e7          	jalr	1222(ra) # 8000287c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053be:	2304a703          	lw	a4,560(s1)
    800053c2:	2344a783          	lw	a5,564(s1)
    800053c6:	fcf70de3          	beq	a4,a5,800053a0 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053ca:	09405263          	blez	s4,8000544e <piperead+0xee>
    800053ce:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053d0:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    800053d2:	2304a783          	lw	a5,560(s1)
    800053d6:	2344a703          	lw	a4,564(s1)
    800053da:	02f70d63          	beq	a4,a5,80005414 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800053de:	0017871b          	addiw	a4,a5,1
    800053e2:	22e4a823          	sw	a4,560(s1)
    800053e6:	1ff7f793          	andi	a5,a5,511
    800053ea:	97a6                	add	a5,a5,s1
    800053ec:	0307c783          	lbu	a5,48(a5)
    800053f0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053f4:	4685                	li	a3,1
    800053f6:	fbf40613          	addi	a2,s0,-65
    800053fa:	85ca                	mv	a1,s2
    800053fc:	068ab503          	ld	a0,104(s5)
    80005400:	ffffc097          	auipc	ra,0xffffc
    80005404:	79e080e7          	jalr	1950(ra) # 80001b9e <copyout>
    80005408:	01650663          	beq	a0,s6,80005414 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000540c:	2985                	addiw	s3,s3,1
    8000540e:	0905                	addi	s2,s2,1
    80005410:	fd3a11e3          	bne	s4,s3,800053d2 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005414:	23448513          	addi	a0,s1,564
    80005418:	ffffd097          	auipc	ra,0xffffd
    8000541c:	5ea080e7          	jalr	1514(ra) # 80002a02 <wakeup>
  release(&pi->lock);
    80005420:	8526                	mv	a0,s1
    80005422:	ffffc097          	auipc	ra,0xffffc
    80005426:	ab2080e7          	jalr	-1358(ra) # 80000ed4 <release>
  return i;
}
    8000542a:	854e                	mv	a0,s3
    8000542c:	60a6                	ld	ra,72(sp)
    8000542e:	6406                	ld	s0,64(sp)
    80005430:	74e2                	ld	s1,56(sp)
    80005432:	7942                	ld	s2,48(sp)
    80005434:	79a2                	ld	s3,40(sp)
    80005436:	7a02                	ld	s4,32(sp)
    80005438:	6ae2                	ld	s5,24(sp)
    8000543a:	6b42                	ld	s6,16(sp)
    8000543c:	6161                	addi	sp,sp,80
    8000543e:	8082                	ret
      release(&pi->lock);
    80005440:	8526                	mv	a0,s1
    80005442:	ffffc097          	auipc	ra,0xffffc
    80005446:	a92080e7          	jalr	-1390(ra) # 80000ed4 <release>
      return -1;
    8000544a:	59fd                	li	s3,-1
    8000544c:	bff9                	j	8000542a <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000544e:	4981                	li	s3,0
    80005450:	b7d1                	j	80005414 <piperead+0xb4>

0000000080005452 <exec>:



int
exec(char *path, char **argv)
{
    80005452:	df010113          	addi	sp,sp,-528
    80005456:	20113423          	sd	ra,520(sp)
    8000545a:	20813023          	sd	s0,512(sp)
    8000545e:	ffa6                	sd	s1,504(sp)
    80005460:	fbca                	sd	s2,496(sp)
    80005462:	f7ce                	sd	s3,488(sp)
    80005464:	f3d2                	sd	s4,480(sp)
    80005466:	efd6                	sd	s5,472(sp)
    80005468:	ebda                	sd	s6,464(sp)
    8000546a:	e7de                	sd	s7,456(sp)
    8000546c:	e3e2                	sd	s8,448(sp)
    8000546e:	ff66                	sd	s9,440(sp)
    80005470:	fb6a                	sd	s10,432(sp)
    80005472:	f76e                	sd	s11,424(sp)
    80005474:	0c00                	addi	s0,sp,528
    80005476:	84aa                	mv	s1,a0
    80005478:	dea43c23          	sd	a0,-520(s0)
    8000547c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005480:	ffffd097          	auipc	ra,0xffffd
    80005484:	b1c080e7          	jalr	-1252(ra) # 80001f9c <myproc>
    80005488:	892a                	mv	s2,a0

  begin_op(ROOTDEV);
    8000548a:	4501                	li	a0,0
    8000548c:	fffff097          	auipc	ra,0xfffff
    80005490:	38a080e7          	jalr	906(ra) # 80004816 <begin_op>

  if((ip = namei(path)) == 0){
    80005494:	8526                	mv	a0,s1
    80005496:	fffff097          	auipc	ra,0xfffff
    8000549a:	13a080e7          	jalr	314(ra) # 800045d0 <namei>
    8000549e:	c935                	beqz	a0,80005512 <exec+0xc0>
    800054a0:	84aa                	mv	s1,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    800054a2:	fffff097          	auipc	ra,0xfffff
    800054a6:	9a4080e7          	jalr	-1628(ra) # 80003e46 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800054aa:	04000713          	li	a4,64
    800054ae:	4681                	li	a3,0
    800054b0:	e4840613          	addi	a2,s0,-440
    800054b4:	4581                	li	a1,0
    800054b6:	8526                	mv	a0,s1
    800054b8:	fffff097          	auipc	ra,0xfffff
    800054bc:	c1e080e7          	jalr	-994(ra) # 800040d6 <readi>
    800054c0:	04000793          	li	a5,64
    800054c4:	00f51a63          	bne	a0,a5,800054d8 <exec+0x86>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800054c8:	e4842703          	lw	a4,-440(s0)
    800054cc:	464c47b7          	lui	a5,0x464c4
    800054d0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800054d4:	04f70663          	beq	a4,a5,80005520 <exec+0xce>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800054d8:	8526                	mv	a0,s1
    800054da:	fffff097          	auipc	ra,0xfffff
    800054de:	baa080e7          	jalr	-1110(ra) # 80004084 <iunlockput>
    end_op(ROOTDEV);
    800054e2:	4501                	li	a0,0
    800054e4:	fffff097          	auipc	ra,0xfffff
    800054e8:	3de080e7          	jalr	990(ra) # 800048c2 <end_op>
  }
  return -1;
    800054ec:	557d                	li	a0,-1
}
    800054ee:	20813083          	ld	ra,520(sp)
    800054f2:	20013403          	ld	s0,512(sp)
    800054f6:	74fe                	ld	s1,504(sp)
    800054f8:	795e                	ld	s2,496(sp)
    800054fa:	79be                	ld	s3,488(sp)
    800054fc:	7a1e                	ld	s4,480(sp)
    800054fe:	6afe                	ld	s5,472(sp)
    80005500:	6b5e                	ld	s6,464(sp)
    80005502:	6bbe                	ld	s7,456(sp)
    80005504:	6c1e                	ld	s8,448(sp)
    80005506:	7cfa                	ld	s9,440(sp)
    80005508:	7d5a                	ld	s10,432(sp)
    8000550a:	7dba                	ld	s11,424(sp)
    8000550c:	21010113          	addi	sp,sp,528
    80005510:	8082                	ret
    end_op(ROOTDEV);
    80005512:	4501                	li	a0,0
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	3ae080e7          	jalr	942(ra) # 800048c2 <end_op>
    return -1;
    8000551c:	557d                	li	a0,-1
    8000551e:	bfc1                	j	800054ee <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005520:	854a                	mv	a0,s2
    80005522:	ffffd097          	auipc	ra,0xffffd
    80005526:	b3e080e7          	jalr	-1218(ra) # 80002060 <proc_pagetable>
    8000552a:	8c2a                	mv	s8,a0
    8000552c:	d555                	beqz	a0,800054d8 <exec+0x86>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000552e:	e6842983          	lw	s3,-408(s0)
    80005532:	e8045783          	lhu	a5,-384(s0)
    80005536:	c7fd                	beqz	a5,80005624 <exec+0x1d2>
  sz = 0;
    80005538:	e0043423          	sd	zero,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000553c:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    8000553e:	6b05                	lui	s6,0x1
    80005540:	fffb0793          	addi	a5,s6,-1 # fff <_entry-0x7ffff001>
    80005544:	def43823          	sd	a5,-528(s0)
    80005548:	a0a5                	j	800055b0 <exec+0x15e>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000554a:	00003517          	auipc	a0,0x3
    8000554e:	6de50513          	addi	a0,a0,1758 # 80008c28 <userret+0xb98>
    80005552:	ffffb097          	auipc	ra,0xffffb
    80005556:	204080e7          	jalr	516(ra) # 80000756 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000555a:	8756                	mv	a4,s5
    8000555c:	012d86bb          	addw	a3,s11,s2
    80005560:	4581                	li	a1,0
    80005562:	8526                	mv	a0,s1
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	b72080e7          	jalr	-1166(ra) # 800040d6 <readi>
    8000556c:	2501                	sext.w	a0,a0
    8000556e:	10aa9263          	bne	s5,a0,80005672 <exec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    80005572:	6785                	lui	a5,0x1
    80005574:	0127893b          	addw	s2,a5,s2
    80005578:	77fd                	lui	a5,0xfffff
    8000557a:	01478a3b          	addw	s4,a5,s4
    8000557e:	03997263          	bgeu	s2,s9,800055a2 <exec+0x150>
    pa = walkaddr(pagetable, va + i);
    80005582:	02091593          	slli	a1,s2,0x20
    80005586:	9181                	srli	a1,a1,0x20
    80005588:	95ea                	add	a1,a1,s10
    8000558a:	8562                	mv	a0,s8
    8000558c:	ffffc097          	auipc	ra,0xffffc
    80005590:	030080e7          	jalr	48(ra) # 800015bc <walkaddr>
    80005594:	862a                	mv	a2,a0
    if(pa == 0)
    80005596:	d955                	beqz	a0,8000554a <exec+0xf8>
      n = PGSIZE;
    80005598:	8ada                	mv	s5,s6
    if(sz - i < PGSIZE)
    8000559a:	fd6a70e3          	bgeu	s4,s6,8000555a <exec+0x108>
      n = sz - i;
    8000559e:	8ad2                	mv	s5,s4
    800055a0:	bf6d                	j	8000555a <exec+0x108>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055a2:	2b85                	addiw	s7,s7,1
    800055a4:	0389899b          	addiw	s3,s3,56
    800055a8:	e8045783          	lhu	a5,-384(s0)
    800055ac:	06fbde63          	bge	s7,a5,80005628 <exec+0x1d6>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800055b0:	2981                	sext.w	s3,s3
    800055b2:	03800713          	li	a4,56
    800055b6:	86ce                	mv	a3,s3
    800055b8:	e1040613          	addi	a2,s0,-496
    800055bc:	4581                	li	a1,0
    800055be:	8526                	mv	a0,s1
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	b16080e7          	jalr	-1258(ra) # 800040d6 <readi>
    800055c8:	03800793          	li	a5,56
    800055cc:	0af51363          	bne	a0,a5,80005672 <exec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    800055d0:	e1042783          	lw	a5,-496(s0)
    800055d4:	4705                	li	a4,1
    800055d6:	fce796e3          	bne	a5,a4,800055a2 <exec+0x150>
    if(ph.memsz < ph.filesz)
    800055da:	e3843603          	ld	a2,-456(s0)
    800055de:	e3043783          	ld	a5,-464(s0)
    800055e2:	08f66863          	bltu	a2,a5,80005672 <exec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800055e6:	e2043783          	ld	a5,-480(s0)
    800055ea:	963e                	add	a2,a2,a5
    800055ec:	08f66363          	bltu	a2,a5,80005672 <exec+0x220>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800055f0:	e0843583          	ld	a1,-504(s0)
    800055f4:	8562                	mv	a0,s8
    800055f6:	ffffc097          	auipc	ra,0xffffc
    800055fa:	3ce080e7          	jalr	974(ra) # 800019c4 <uvmalloc>
    800055fe:	e0a43423          	sd	a0,-504(s0)
    80005602:	c925                	beqz	a0,80005672 <exec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80005604:	e2043d03          	ld	s10,-480(s0)
    80005608:	df043783          	ld	a5,-528(s0)
    8000560c:	00fd77b3          	and	a5,s10,a5
    80005610:	e3ad                	bnez	a5,80005672 <exec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005612:	e1842d83          	lw	s11,-488(s0)
    80005616:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000561a:	f80c84e3          	beqz	s9,800055a2 <exec+0x150>
    8000561e:	8a66                	mv	s4,s9
    80005620:	4901                	li	s2,0
    80005622:	b785                	j	80005582 <exec+0x130>
  sz = 0;
    80005624:	e0043423          	sd	zero,-504(s0)
  iunlockput(ip);
    80005628:	8526                	mv	a0,s1
    8000562a:	fffff097          	auipc	ra,0xfffff
    8000562e:	a5a080e7          	jalr	-1446(ra) # 80004084 <iunlockput>
  end_op(ROOTDEV);
    80005632:	4501                	li	a0,0
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	28e080e7          	jalr	654(ra) # 800048c2 <end_op>
  p = myproc();
    8000563c:	ffffd097          	auipc	ra,0xffffd
    80005640:	960080e7          	jalr	-1696(ra) # 80001f9c <myproc>
    80005644:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80005646:	06053d83          	ld	s11,96(a0)
  sz = PGROUNDUP(sz);
    8000564a:	6585                	lui	a1,0x1
    8000564c:	15fd                	addi	a1,a1,-1
    8000564e:	e0843783          	ld	a5,-504(s0)
    80005652:	00b78b33          	add	s6,a5,a1
    80005656:	75fd                	lui	a1,0xfffff
    80005658:	00bb75b3          	and	a1,s6,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000565c:	6609                	lui	a2,0x2
    8000565e:	962e                	add	a2,a2,a1
    80005660:	8562                	mv	a0,s8
    80005662:	ffffc097          	auipc	ra,0xffffc
    80005666:	362080e7          	jalr	866(ra) # 800019c4 <uvmalloc>
    8000566a:	e0a43423          	sd	a0,-504(s0)
  ip = 0;
    8000566e:	4481                	li	s1,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005670:	ed01                	bnez	a0,80005688 <exec+0x236>
    proc_freepagetable(pagetable, sz);
    80005672:	e0843583          	ld	a1,-504(s0)
    80005676:	8562                	mv	a0,s8
    80005678:	ffffd097          	auipc	ra,0xffffd
    8000567c:	aec080e7          	jalr	-1300(ra) # 80002164 <proc_freepagetable>
  if(ip){
    80005680:	e4049ce3          	bnez	s1,800054d8 <exec+0x86>
  return -1;
    80005684:	557d                	li	a0,-1
    80005686:	b5a5                	j	800054ee <exec+0x9c>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005688:	75f9                	lui	a1,0xffffe
    8000568a:	84aa                	mv	s1,a0
    8000568c:	95aa                	add	a1,a1,a0
    8000568e:	8562                	mv	a0,s8
    80005690:	ffffc097          	auipc	ra,0xffffc
    80005694:	4dc080e7          	jalr	1244(ra) # 80001b6c <uvmclear>
  stackbase = sp - PGSIZE;
    80005698:	7bfd                	lui	s7,0xfffff
    8000569a:	9ba6                	add	s7,s7,s1
  for(argc = 0; argv[argc]; argc++) {
    8000569c:	e0043983          	ld	s3,-512(s0)
    800056a0:	0009b503          	ld	a0,0(s3)
    800056a4:	cd29                	beqz	a0,800056fe <exec+0x2ac>
    800056a6:	e8840a13          	addi	s4,s0,-376
    800056aa:	f8840c93          	addi	s9,s0,-120
    800056ae:	4901                	li	s2,0
    sp -= strlen(argv[argc]) + 1;
    800056b0:	ffffc097          	auipc	ra,0xffffc
    800056b4:	bac080e7          	jalr	-1108(ra) # 8000125c <strlen>
    800056b8:	2505                	addiw	a0,a0,1
    800056ba:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800056bc:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    800056be:	1174e463          	bltu	s1,s7,800057c6 <exec+0x374>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800056c2:	0009ba83          	ld	s5,0(s3)
    800056c6:	8556                	mv	a0,s5
    800056c8:	ffffc097          	auipc	ra,0xffffc
    800056cc:	b94080e7          	jalr	-1132(ra) # 8000125c <strlen>
    800056d0:	0015069b          	addiw	a3,a0,1
    800056d4:	8656                	mv	a2,s5
    800056d6:	85a6                	mv	a1,s1
    800056d8:	8562                	mv	a0,s8
    800056da:	ffffc097          	auipc	ra,0xffffc
    800056de:	4c4080e7          	jalr	1220(ra) # 80001b9e <copyout>
    800056e2:	0e054463          	bltz	a0,800057ca <exec+0x378>
    ustack[argc] = sp;
    800056e6:	009a3023          	sd	s1,0(s4)
  for(argc = 0; argv[argc]; argc++) {
    800056ea:	0905                	addi	s2,s2,1
    800056ec:	09a1                	addi	s3,s3,8
    800056ee:	0009b503          	ld	a0,0(s3)
    800056f2:	c909                	beqz	a0,80005704 <exec+0x2b2>
    if(argc >= MAXARG)
    800056f4:	0a21                	addi	s4,s4,8
    800056f6:	fb4c9de3          	bne	s9,s4,800056b0 <exec+0x25e>
  ip = 0;
    800056fa:	4481                	li	s1,0
    800056fc:	bf9d                	j	80005672 <exec+0x220>
  sp = sz;
    800056fe:	e0843483          	ld	s1,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005702:	4901                	li	s2,0
  ustack[argc] = 0;
    80005704:	00391793          	slli	a5,s2,0x3
    80005708:	f9040713          	addi	a4,s0,-112
    8000570c:	97ba                	add	a5,a5,a4
    8000570e:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd0e4c>
  sp -= (argc+1) * sizeof(uint64);
    80005712:	00190693          	addi	a3,s2,1
    80005716:	068e                	slli	a3,a3,0x3
    80005718:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    8000571a:	ff04f993          	andi	s3,s1,-16
  ip = 0;
    8000571e:	4481                	li	s1,0
  if(sp < stackbase)
    80005720:	f579e9e3          	bltu	s3,s7,80005672 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005724:	e8840613          	addi	a2,s0,-376
    80005728:	85ce                	mv	a1,s3
    8000572a:	8562                	mv	a0,s8
    8000572c:	ffffc097          	auipc	ra,0xffffc
    80005730:	472080e7          	jalr	1138(ra) # 80001b9e <copyout>
    80005734:	08054d63          	bltz	a0,800057ce <exec+0x37c>
  p->tf->a1 = sp;
    80005738:	070d3783          	ld	a5,112(s10)
    8000573c:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    80005740:	df843783          	ld	a5,-520(s0)
    80005744:	0007c703          	lbu	a4,0(a5)
    80005748:	cf11                	beqz	a4,80005764 <exec+0x312>
    8000574a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000574c:	02f00693          	li	a3,47
    80005750:	a029                	j	8000575a <exec+0x308>
  for(last=s=path; *s; s++)
    80005752:	0785                	addi	a5,a5,1
    80005754:	fff7c703          	lbu	a4,-1(a5)
    80005758:	c711                	beqz	a4,80005764 <exec+0x312>
    if(*s == '/')
    8000575a:	fed71ce3          	bne	a4,a3,80005752 <exec+0x300>
      last = s+1;
    8000575e:	def43c23          	sd	a5,-520(s0)
    80005762:	bfc5                	j	80005752 <exec+0x300>
  safestrcpy(p->name, last, sizeof(p->name));
    80005764:	4641                	li	a2,16
    80005766:	df843583          	ld	a1,-520(s0)
    8000576a:	170d0513          	addi	a0,s10,368
    8000576e:	ffffc097          	auipc	ra,0xffffc
    80005772:	abc080e7          	jalr	-1348(ra) # 8000122a <safestrcpy>
  if(p->cmd) bd_free(p->cmd);
    80005776:	180d3503          	ld	a0,384(s10)
    8000577a:	c509                	beqz	a0,80005784 <exec+0x332>
    8000577c:	00002097          	auipc	ra,0x2
    80005780:	960080e7          	jalr	-1696(ra) # 800070dc <bd_free>
  p->cmd = strjoin(argv);
    80005784:	e0043503          	ld	a0,-512(s0)
    80005788:	ffffc097          	auipc	ra,0xffffc
    8000578c:	afe080e7          	jalr	-1282(ra) # 80001286 <strjoin>
    80005790:	18ad3023          	sd	a0,384(s10)
  oldpagetable = p->pagetable;
    80005794:	068d3503          	ld	a0,104(s10)
  p->pagetable = pagetable;
    80005798:	078d3423          	sd	s8,104(s10)
  p->sz = sz;
    8000579c:	e0843783          	ld	a5,-504(s0)
    800057a0:	06fd3023          	sd	a5,96(s10)
  p->tf->epc = elf.entry;  // initial program counter = main
    800057a4:	070d3783          	ld	a5,112(s10)
    800057a8:	e6043703          	ld	a4,-416(s0)
    800057ac:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    800057ae:	070d3783          	ld	a5,112(s10)
    800057b2:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800057b6:	85ee                	mv	a1,s11
    800057b8:	ffffd097          	auipc	ra,0xffffd
    800057bc:	9ac080e7          	jalr	-1620(ra) # 80002164 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800057c0:	0009051b          	sext.w	a0,s2
    800057c4:	b32d                	j	800054ee <exec+0x9c>
  ip = 0;
    800057c6:	4481                	li	s1,0
    800057c8:	b56d                	j	80005672 <exec+0x220>
    800057ca:	4481                	li	s1,0
    800057cc:	b55d                	j	80005672 <exec+0x220>
    800057ce:	4481                	li	s1,0
    800057d0:	b54d                	j	80005672 <exec+0x220>

00000000800057d2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800057d2:	7179                	addi	sp,sp,-48
    800057d4:	f406                	sd	ra,40(sp)
    800057d6:	f022                	sd	s0,32(sp)
    800057d8:	ec26                	sd	s1,24(sp)
    800057da:	e84a                	sd	s2,16(sp)
    800057dc:	1800                	addi	s0,sp,48
    800057de:	892e                	mv	s2,a1
    800057e0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800057e2:	fdc40593          	addi	a1,s0,-36
    800057e6:	ffffe097          	auipc	ra,0xffffe
    800057ea:	adc080e7          	jalr	-1316(ra) # 800032c2 <argint>
    800057ee:	04054063          	bltz	a0,8000582e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800057f2:	fdc42703          	lw	a4,-36(s0)
    800057f6:	47bd                	li	a5,15
    800057f8:	02e7ed63          	bltu	a5,a4,80005832 <argfd+0x60>
    800057fc:	ffffc097          	auipc	ra,0xffffc
    80005800:	7a0080e7          	jalr	1952(ra) # 80001f9c <myproc>
    80005804:	fdc42703          	lw	a4,-36(s0)
    80005808:	01c70793          	addi	a5,a4,28
    8000580c:	078e                	slli	a5,a5,0x3
    8000580e:	953e                	add	a0,a0,a5
    80005810:	651c                	ld	a5,8(a0)
    80005812:	c395                	beqz	a5,80005836 <argfd+0x64>
    return -1;
  if(pfd)
    80005814:	00090463          	beqz	s2,8000581c <argfd+0x4a>
    *pfd = fd;
    80005818:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000581c:	4501                	li	a0,0
  if(pf)
    8000581e:	c091                	beqz	s1,80005822 <argfd+0x50>
    *pf = f;
    80005820:	e09c                	sd	a5,0(s1)
}
    80005822:	70a2                	ld	ra,40(sp)
    80005824:	7402                	ld	s0,32(sp)
    80005826:	64e2                	ld	s1,24(sp)
    80005828:	6942                	ld	s2,16(sp)
    8000582a:	6145                	addi	sp,sp,48
    8000582c:	8082                	ret
    return -1;
    8000582e:	557d                	li	a0,-1
    80005830:	bfcd                	j	80005822 <argfd+0x50>
    return -1;
    80005832:	557d                	li	a0,-1
    80005834:	b7fd                	j	80005822 <argfd+0x50>
    80005836:	557d                	li	a0,-1
    80005838:	b7ed                	j	80005822 <argfd+0x50>

000000008000583a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000583a:	1101                	addi	sp,sp,-32
    8000583c:	ec06                	sd	ra,24(sp)
    8000583e:	e822                	sd	s0,16(sp)
    80005840:	e426                	sd	s1,8(sp)
    80005842:	1000                	addi	s0,sp,32
    80005844:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005846:	ffffc097          	auipc	ra,0xffffc
    8000584a:	756080e7          	jalr	1878(ra) # 80001f9c <myproc>
    8000584e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005850:	0e850793          	addi	a5,a0,232
    80005854:	4501                	li	a0,0
    80005856:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005858:	6398                	ld	a4,0(a5)
    8000585a:	cb19                	beqz	a4,80005870 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000585c:	2505                	addiw	a0,a0,1
    8000585e:	07a1                	addi	a5,a5,8
    80005860:	fed51ce3          	bne	a0,a3,80005858 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005864:	557d                	li	a0,-1
}
    80005866:	60e2                	ld	ra,24(sp)
    80005868:	6442                	ld	s0,16(sp)
    8000586a:	64a2                	ld	s1,8(sp)
    8000586c:	6105                	addi	sp,sp,32
    8000586e:	8082                	ret
      p->ofile[fd] = f;
    80005870:	01c50793          	addi	a5,a0,28
    80005874:	078e                	slli	a5,a5,0x3
    80005876:	963e                	add	a2,a2,a5
    80005878:	e604                	sd	s1,8(a2)
      return fd;
    8000587a:	b7f5                	j	80005866 <fdalloc+0x2c>

000000008000587c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000587c:	715d                	addi	sp,sp,-80
    8000587e:	e486                	sd	ra,72(sp)
    80005880:	e0a2                	sd	s0,64(sp)
    80005882:	fc26                	sd	s1,56(sp)
    80005884:	f84a                	sd	s2,48(sp)
    80005886:	f44e                	sd	s3,40(sp)
    80005888:	f052                	sd	s4,32(sp)
    8000588a:	ec56                	sd	s5,24(sp)
    8000588c:	0880                	addi	s0,sp,80
    8000588e:	89ae                	mv	s3,a1
    80005890:	8ab2                	mv	s5,a2
    80005892:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005894:	fb040593          	addi	a1,s0,-80
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	d56080e7          	jalr	-682(ra) # 800045ee <nameiparent>
    800058a0:	892a                	mv	s2,a0
    800058a2:	12050f63          	beqz	a0,800059e0 <create+0x164>
    return 0;

  ilock(dp);
    800058a6:	ffffe097          	auipc	ra,0xffffe
    800058aa:	5a0080e7          	jalr	1440(ra) # 80003e46 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800058ae:	4601                	li	a2,0
    800058b0:	fb040593          	addi	a1,s0,-80
    800058b4:	854a                	mv	a0,s2
    800058b6:	fffff097          	auipc	ra,0xfffff
    800058ba:	a48080e7          	jalr	-1464(ra) # 800042fe <dirlookup>
    800058be:	84aa                	mv	s1,a0
    800058c0:	c921                	beqz	a0,80005910 <create+0x94>
    iunlockput(dp);
    800058c2:	854a                	mv	a0,s2
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	7c0080e7          	jalr	1984(ra) # 80004084 <iunlockput>
    ilock(ip);
    800058cc:	8526                	mv	a0,s1
    800058ce:	ffffe097          	auipc	ra,0xffffe
    800058d2:	578080e7          	jalr	1400(ra) # 80003e46 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800058d6:	2981                	sext.w	s3,s3
    800058d8:	4789                	li	a5,2
    800058da:	02f99463          	bne	s3,a5,80005902 <create+0x86>
    800058de:	05c4d783          	lhu	a5,92(s1)
    800058e2:	37f9                	addiw	a5,a5,-2
    800058e4:	17c2                	slli	a5,a5,0x30
    800058e6:	93c1                	srli	a5,a5,0x30
    800058e8:	4705                	li	a4,1
    800058ea:	00f76c63          	bltu	a4,a5,80005902 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800058ee:	8526                	mv	a0,s1
    800058f0:	60a6                	ld	ra,72(sp)
    800058f2:	6406                	ld	s0,64(sp)
    800058f4:	74e2                	ld	s1,56(sp)
    800058f6:	7942                	ld	s2,48(sp)
    800058f8:	79a2                	ld	s3,40(sp)
    800058fa:	7a02                	ld	s4,32(sp)
    800058fc:	6ae2                	ld	s5,24(sp)
    800058fe:	6161                	addi	sp,sp,80
    80005900:	8082                	ret
    iunlockput(ip);
    80005902:	8526                	mv	a0,s1
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	780080e7          	jalr	1920(ra) # 80004084 <iunlockput>
    return 0;
    8000590c:	4481                	li	s1,0
    8000590e:	b7c5                	j	800058ee <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005910:	85ce                	mv	a1,s3
    80005912:	00092503          	lw	a0,0(s2)
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	398080e7          	jalr	920(ra) # 80003cae <ialloc>
    8000591e:	84aa                	mv	s1,a0
    80005920:	c529                	beqz	a0,8000596a <create+0xee>
  ilock(ip);
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	524080e7          	jalr	1316(ra) # 80003e46 <ilock>
  ip->major = major;
    8000592a:	05549f23          	sh	s5,94(s1)
  ip->minor = minor;
    8000592e:	07449023          	sh	s4,96(s1)
  ip->nlink = 1;
    80005932:	4785                	li	a5,1
    80005934:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005938:	8526                	mv	a0,s1
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	442080e7          	jalr	1090(ra) # 80003d7c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005942:	2981                	sext.w	s3,s3
    80005944:	4785                	li	a5,1
    80005946:	02f98a63          	beq	s3,a5,8000597a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000594a:	40d0                	lw	a2,4(s1)
    8000594c:	fb040593          	addi	a1,s0,-80
    80005950:	854a                	mv	a0,s2
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	bbc080e7          	jalr	-1092(ra) # 8000450e <dirlink>
    8000595a:	06054b63          	bltz	a0,800059d0 <create+0x154>
  iunlockput(dp);
    8000595e:	854a                	mv	a0,s2
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	724080e7          	jalr	1828(ra) # 80004084 <iunlockput>
  return ip;
    80005968:	b759                	j	800058ee <create+0x72>
    panic("create: ialloc");
    8000596a:	00003517          	auipc	a0,0x3
    8000596e:	2de50513          	addi	a0,a0,734 # 80008c48 <userret+0xbb8>
    80005972:	ffffb097          	auipc	ra,0xffffb
    80005976:	de4080e7          	jalr	-540(ra) # 80000756 <panic>
    dp->nlink++;  // for ".."
    8000597a:	06295783          	lhu	a5,98(s2)
    8000597e:	2785                	addiw	a5,a5,1
    80005980:	06f91123          	sh	a5,98(s2)
    iupdate(dp);
    80005984:	854a                	mv	a0,s2
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	3f6080e7          	jalr	1014(ra) # 80003d7c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000598e:	40d0                	lw	a2,4(s1)
    80005990:	00003597          	auipc	a1,0x3
    80005994:	2c858593          	addi	a1,a1,712 # 80008c58 <userret+0xbc8>
    80005998:	8526                	mv	a0,s1
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	b74080e7          	jalr	-1164(ra) # 8000450e <dirlink>
    800059a2:	00054f63          	bltz	a0,800059c0 <create+0x144>
    800059a6:	00492603          	lw	a2,4(s2)
    800059aa:	00003597          	auipc	a1,0x3
    800059ae:	2b658593          	addi	a1,a1,694 # 80008c60 <userret+0xbd0>
    800059b2:	8526                	mv	a0,s1
    800059b4:	fffff097          	auipc	ra,0xfffff
    800059b8:	b5a080e7          	jalr	-1190(ra) # 8000450e <dirlink>
    800059bc:	f80557e3          	bgez	a0,8000594a <create+0xce>
      panic("create dots");
    800059c0:	00003517          	auipc	a0,0x3
    800059c4:	2a850513          	addi	a0,a0,680 # 80008c68 <userret+0xbd8>
    800059c8:	ffffb097          	auipc	ra,0xffffb
    800059cc:	d8e080e7          	jalr	-626(ra) # 80000756 <panic>
    panic("create: dirlink");
    800059d0:	00003517          	auipc	a0,0x3
    800059d4:	2a850513          	addi	a0,a0,680 # 80008c78 <userret+0xbe8>
    800059d8:	ffffb097          	auipc	ra,0xffffb
    800059dc:	d7e080e7          	jalr	-642(ra) # 80000756 <panic>
    return 0;
    800059e0:	84aa                	mv	s1,a0
    800059e2:	b731                	j	800058ee <create+0x72>

00000000800059e4 <sys_dup>:
{
    800059e4:	7179                	addi	sp,sp,-48
    800059e6:	f406                	sd	ra,40(sp)
    800059e8:	f022                	sd	s0,32(sp)
    800059ea:	ec26                	sd	s1,24(sp)
    800059ec:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800059ee:	fd840613          	addi	a2,s0,-40
    800059f2:	4581                	li	a1,0
    800059f4:	4501                	li	a0,0
    800059f6:	00000097          	auipc	ra,0x0
    800059fa:	ddc080e7          	jalr	-548(ra) # 800057d2 <argfd>
    return -1;
    800059fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005a00:	02054363          	bltz	a0,80005a26 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005a04:	fd843503          	ld	a0,-40(s0)
    80005a08:	00000097          	auipc	ra,0x0
    80005a0c:	e32080e7          	jalr	-462(ra) # 8000583a <fdalloc>
    80005a10:	84aa                	mv	s1,a0
    return -1;
    80005a12:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005a14:	00054963          	bltz	a0,80005a26 <sys_dup+0x42>
  filedup(f);
    80005a18:	fd843503          	ld	a0,-40(s0)
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	332080e7          	jalr	818(ra) # 80004d4e <filedup>
  return fd;
    80005a24:	87a6                	mv	a5,s1
}
    80005a26:	853e                	mv	a0,a5
    80005a28:	70a2                	ld	ra,40(sp)
    80005a2a:	7402                	ld	s0,32(sp)
    80005a2c:	64e2                	ld	s1,24(sp)
    80005a2e:	6145                	addi	sp,sp,48
    80005a30:	8082                	ret

0000000080005a32 <sys_read>:
{
    80005a32:	7179                	addi	sp,sp,-48
    80005a34:	f406                	sd	ra,40(sp)
    80005a36:	f022                	sd	s0,32(sp)
    80005a38:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a3a:	fe840613          	addi	a2,s0,-24
    80005a3e:	4581                	li	a1,0
    80005a40:	4501                	li	a0,0
    80005a42:	00000097          	auipc	ra,0x0
    80005a46:	d90080e7          	jalr	-624(ra) # 800057d2 <argfd>
    return -1;
    80005a4a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a4c:	04054163          	bltz	a0,80005a8e <sys_read+0x5c>
    80005a50:	fe440593          	addi	a1,s0,-28
    80005a54:	4509                	li	a0,2
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	86c080e7          	jalr	-1940(ra) # 800032c2 <argint>
    return -1;
    80005a5e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a60:	02054763          	bltz	a0,80005a8e <sys_read+0x5c>
    80005a64:	fd840593          	addi	a1,s0,-40
    80005a68:	4505                	li	a0,1
    80005a6a:	ffffe097          	auipc	ra,0xffffe
    80005a6e:	87a080e7          	jalr	-1926(ra) # 800032e4 <argaddr>
    return -1;
    80005a72:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a74:	00054d63          	bltz	a0,80005a8e <sys_read+0x5c>
  return fileread(f, p, n);
    80005a78:	fe442603          	lw	a2,-28(s0)
    80005a7c:	fd843583          	ld	a1,-40(s0)
    80005a80:	fe843503          	ld	a0,-24(s0)
    80005a84:	fffff097          	auipc	ra,0xfffff
    80005a88:	45e080e7          	jalr	1118(ra) # 80004ee2 <fileread>
    80005a8c:	87aa                	mv	a5,a0
}
    80005a8e:	853e                	mv	a0,a5
    80005a90:	70a2                	ld	ra,40(sp)
    80005a92:	7402                	ld	s0,32(sp)
    80005a94:	6145                	addi	sp,sp,48
    80005a96:	8082                	ret

0000000080005a98 <sys_write>:
{
    80005a98:	7179                	addi	sp,sp,-48
    80005a9a:	f406                	sd	ra,40(sp)
    80005a9c:	f022                	sd	s0,32(sp)
    80005a9e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005aa0:	fe840613          	addi	a2,s0,-24
    80005aa4:	4581                	li	a1,0
    80005aa6:	4501                	li	a0,0
    80005aa8:	00000097          	auipc	ra,0x0
    80005aac:	d2a080e7          	jalr	-726(ra) # 800057d2 <argfd>
    return -1;
    80005ab0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ab2:	04054163          	bltz	a0,80005af4 <sys_write+0x5c>
    80005ab6:	fe440593          	addi	a1,s0,-28
    80005aba:	4509                	li	a0,2
    80005abc:	ffffe097          	auipc	ra,0xffffe
    80005ac0:	806080e7          	jalr	-2042(ra) # 800032c2 <argint>
    return -1;
    80005ac4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ac6:	02054763          	bltz	a0,80005af4 <sys_write+0x5c>
    80005aca:	fd840593          	addi	a1,s0,-40
    80005ace:	4505                	li	a0,1
    80005ad0:	ffffe097          	auipc	ra,0xffffe
    80005ad4:	814080e7          	jalr	-2028(ra) # 800032e4 <argaddr>
    return -1;
    80005ad8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ada:	00054d63          	bltz	a0,80005af4 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005ade:	fe442603          	lw	a2,-28(s0)
    80005ae2:	fd843583          	ld	a1,-40(s0)
    80005ae6:	fe843503          	ld	a0,-24(s0)
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	4be080e7          	jalr	1214(ra) # 80004fa8 <filewrite>
    80005af2:	87aa                	mv	a5,a0
}
    80005af4:	853e                	mv	a0,a5
    80005af6:	70a2                	ld	ra,40(sp)
    80005af8:	7402                	ld	s0,32(sp)
    80005afa:	6145                	addi	sp,sp,48
    80005afc:	8082                	ret

0000000080005afe <sys_close>:
{
    80005afe:	1101                	addi	sp,sp,-32
    80005b00:	ec06                	sd	ra,24(sp)
    80005b02:	e822                	sd	s0,16(sp)
    80005b04:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005b06:	fe040613          	addi	a2,s0,-32
    80005b0a:	fec40593          	addi	a1,s0,-20
    80005b0e:	4501                	li	a0,0
    80005b10:	00000097          	auipc	ra,0x0
    80005b14:	cc2080e7          	jalr	-830(ra) # 800057d2 <argfd>
    return -1;
    80005b18:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005b1a:	02054463          	bltz	a0,80005b42 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005b1e:	ffffc097          	auipc	ra,0xffffc
    80005b22:	47e080e7          	jalr	1150(ra) # 80001f9c <myproc>
    80005b26:	fec42783          	lw	a5,-20(s0)
    80005b2a:	07f1                	addi	a5,a5,28
    80005b2c:	078e                	slli	a5,a5,0x3
    80005b2e:	97aa                	add	a5,a5,a0
    80005b30:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005b34:	fe043503          	ld	a0,-32(s0)
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	268080e7          	jalr	616(ra) # 80004da0 <fileclose>
  return 0;
    80005b40:	4781                	li	a5,0
}
    80005b42:	853e                	mv	a0,a5
    80005b44:	60e2                	ld	ra,24(sp)
    80005b46:	6442                	ld	s0,16(sp)
    80005b48:	6105                	addi	sp,sp,32
    80005b4a:	8082                	ret

0000000080005b4c <sys_fstat>:
{
    80005b4c:	1101                	addi	sp,sp,-32
    80005b4e:	ec06                	sd	ra,24(sp)
    80005b50:	e822                	sd	s0,16(sp)
    80005b52:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005b54:	fe840613          	addi	a2,s0,-24
    80005b58:	4581                	li	a1,0
    80005b5a:	4501                	li	a0,0
    80005b5c:	00000097          	auipc	ra,0x0
    80005b60:	c76080e7          	jalr	-906(ra) # 800057d2 <argfd>
    return -1;
    80005b64:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005b66:	02054563          	bltz	a0,80005b90 <sys_fstat+0x44>
    80005b6a:	fe040593          	addi	a1,s0,-32
    80005b6e:	4505                	li	a0,1
    80005b70:	ffffd097          	auipc	ra,0xffffd
    80005b74:	774080e7          	jalr	1908(ra) # 800032e4 <argaddr>
    return -1;
    80005b78:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005b7a:	00054b63          	bltz	a0,80005b90 <sys_fstat+0x44>
  return filestat(f, st);
    80005b7e:	fe043583          	ld	a1,-32(s0)
    80005b82:	fe843503          	ld	a0,-24(s0)
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	2ea080e7          	jalr	746(ra) # 80004e70 <filestat>
    80005b8e:	87aa                	mv	a5,a0
}
    80005b90:	853e                	mv	a0,a5
    80005b92:	60e2                	ld	ra,24(sp)
    80005b94:	6442                	ld	s0,16(sp)
    80005b96:	6105                	addi	sp,sp,32
    80005b98:	8082                	ret

0000000080005b9a <sys_link>:
{
    80005b9a:	7169                	addi	sp,sp,-304
    80005b9c:	f606                	sd	ra,296(sp)
    80005b9e:	f222                	sd	s0,288(sp)
    80005ba0:	ee26                	sd	s1,280(sp)
    80005ba2:	ea4a                	sd	s2,272(sp)
    80005ba4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005ba6:	08000613          	li	a2,128
    80005baa:	ed040593          	addi	a1,s0,-304
    80005bae:	4501                	li	a0,0
    80005bb0:	ffffd097          	auipc	ra,0xffffd
    80005bb4:	756080e7          	jalr	1878(ra) # 80003306 <argstr>
    return -1;
    80005bb8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bba:	12054363          	bltz	a0,80005ce0 <sys_link+0x146>
    80005bbe:	08000613          	li	a2,128
    80005bc2:	f5040593          	addi	a1,s0,-176
    80005bc6:	4505                	li	a0,1
    80005bc8:	ffffd097          	auipc	ra,0xffffd
    80005bcc:	73e080e7          	jalr	1854(ra) # 80003306 <argstr>
    return -1;
    80005bd0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bd2:	10054763          	bltz	a0,80005ce0 <sys_link+0x146>
  begin_op(ROOTDEV);
    80005bd6:	4501                	li	a0,0
    80005bd8:	fffff097          	auipc	ra,0xfffff
    80005bdc:	c3e080e7          	jalr	-962(ra) # 80004816 <begin_op>
  if((ip = namei(old)) == 0){
    80005be0:	ed040513          	addi	a0,s0,-304
    80005be4:	fffff097          	auipc	ra,0xfffff
    80005be8:	9ec080e7          	jalr	-1556(ra) # 800045d0 <namei>
    80005bec:	84aa                	mv	s1,a0
    80005bee:	c559                	beqz	a0,80005c7c <sys_link+0xe2>
  ilock(ip);
    80005bf0:	ffffe097          	auipc	ra,0xffffe
    80005bf4:	256080e7          	jalr	598(ra) # 80003e46 <ilock>
  if(ip->type == T_DIR){
    80005bf8:	05c49703          	lh	a4,92(s1)
    80005bfc:	4785                	li	a5,1
    80005bfe:	08f70663          	beq	a4,a5,80005c8a <sys_link+0xf0>
  ip->nlink++;
    80005c02:	0624d783          	lhu	a5,98(s1)
    80005c06:	2785                	addiw	a5,a5,1
    80005c08:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005c0c:	8526                	mv	a0,s1
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	16e080e7          	jalr	366(ra) # 80003d7c <iupdate>
  iunlock(ip);
    80005c16:	8526                	mv	a0,s1
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	2f0080e7          	jalr	752(ra) # 80003f08 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005c20:	fd040593          	addi	a1,s0,-48
    80005c24:	f5040513          	addi	a0,s0,-176
    80005c28:	fffff097          	auipc	ra,0xfffff
    80005c2c:	9c6080e7          	jalr	-1594(ra) # 800045ee <nameiparent>
    80005c30:	892a                	mv	s2,a0
    80005c32:	cd2d                	beqz	a0,80005cac <sys_link+0x112>
  ilock(dp);
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	212080e7          	jalr	530(ra) # 80003e46 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005c3c:	00092703          	lw	a4,0(s2)
    80005c40:	409c                	lw	a5,0(s1)
    80005c42:	06f71063          	bne	a4,a5,80005ca2 <sys_link+0x108>
    80005c46:	40d0                	lw	a2,4(s1)
    80005c48:	fd040593          	addi	a1,s0,-48
    80005c4c:	854a                	mv	a0,s2
    80005c4e:	fffff097          	auipc	ra,0xfffff
    80005c52:	8c0080e7          	jalr	-1856(ra) # 8000450e <dirlink>
    80005c56:	04054663          	bltz	a0,80005ca2 <sys_link+0x108>
  iunlockput(dp);
    80005c5a:	854a                	mv	a0,s2
    80005c5c:	ffffe097          	auipc	ra,0xffffe
    80005c60:	428080e7          	jalr	1064(ra) # 80004084 <iunlockput>
  iput(ip);
    80005c64:	8526                	mv	a0,s1
    80005c66:	ffffe097          	auipc	ra,0xffffe
    80005c6a:	2ee080e7          	jalr	750(ra) # 80003f54 <iput>
  end_op(ROOTDEV);
    80005c6e:	4501                	li	a0,0
    80005c70:	fffff097          	auipc	ra,0xfffff
    80005c74:	c52080e7          	jalr	-942(ra) # 800048c2 <end_op>
  return 0;
    80005c78:	4781                	li	a5,0
    80005c7a:	a09d                	j	80005ce0 <sys_link+0x146>
    end_op(ROOTDEV);
    80005c7c:	4501                	li	a0,0
    80005c7e:	fffff097          	auipc	ra,0xfffff
    80005c82:	c44080e7          	jalr	-956(ra) # 800048c2 <end_op>
    return -1;
    80005c86:	57fd                	li	a5,-1
    80005c88:	a8a1                	j	80005ce0 <sys_link+0x146>
    iunlockput(ip);
    80005c8a:	8526                	mv	a0,s1
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	3f8080e7          	jalr	1016(ra) # 80004084 <iunlockput>
    end_op(ROOTDEV);
    80005c94:	4501                	li	a0,0
    80005c96:	fffff097          	auipc	ra,0xfffff
    80005c9a:	c2c080e7          	jalr	-980(ra) # 800048c2 <end_op>
    return -1;
    80005c9e:	57fd                	li	a5,-1
    80005ca0:	a081                	j	80005ce0 <sys_link+0x146>
    iunlockput(dp);
    80005ca2:	854a                	mv	a0,s2
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	3e0080e7          	jalr	992(ra) # 80004084 <iunlockput>
  ilock(ip);
    80005cac:	8526                	mv	a0,s1
    80005cae:	ffffe097          	auipc	ra,0xffffe
    80005cb2:	198080e7          	jalr	408(ra) # 80003e46 <ilock>
  ip->nlink--;
    80005cb6:	0624d783          	lhu	a5,98(s1)
    80005cba:	37fd                	addiw	a5,a5,-1
    80005cbc:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005cc0:	8526                	mv	a0,s1
    80005cc2:	ffffe097          	auipc	ra,0xffffe
    80005cc6:	0ba080e7          	jalr	186(ra) # 80003d7c <iupdate>
  iunlockput(ip);
    80005cca:	8526                	mv	a0,s1
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	3b8080e7          	jalr	952(ra) # 80004084 <iunlockput>
  end_op(ROOTDEV);
    80005cd4:	4501                	li	a0,0
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	bec080e7          	jalr	-1044(ra) # 800048c2 <end_op>
  return -1;
    80005cde:	57fd                	li	a5,-1
}
    80005ce0:	853e                	mv	a0,a5
    80005ce2:	70b2                	ld	ra,296(sp)
    80005ce4:	7412                	ld	s0,288(sp)
    80005ce6:	64f2                	ld	s1,280(sp)
    80005ce8:	6952                	ld	s2,272(sp)
    80005cea:	6155                	addi	sp,sp,304
    80005cec:	8082                	ret

0000000080005cee <sys_unlink>:
{
    80005cee:	7151                	addi	sp,sp,-240
    80005cf0:	f586                	sd	ra,232(sp)
    80005cf2:	f1a2                	sd	s0,224(sp)
    80005cf4:	eda6                	sd	s1,216(sp)
    80005cf6:	e9ca                	sd	s2,208(sp)
    80005cf8:	e5ce                	sd	s3,200(sp)
    80005cfa:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005cfc:	08000613          	li	a2,128
    80005d00:	f3040593          	addi	a1,s0,-208
    80005d04:	4501                	li	a0,0
    80005d06:	ffffd097          	auipc	ra,0xffffd
    80005d0a:	600080e7          	jalr	1536(ra) # 80003306 <argstr>
    80005d0e:	18054463          	bltz	a0,80005e96 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    80005d12:	4501                	li	a0,0
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	b02080e7          	jalr	-1278(ra) # 80004816 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005d1c:	fb040593          	addi	a1,s0,-80
    80005d20:	f3040513          	addi	a0,s0,-208
    80005d24:	fffff097          	auipc	ra,0xfffff
    80005d28:	8ca080e7          	jalr	-1846(ra) # 800045ee <nameiparent>
    80005d2c:	84aa                	mv	s1,a0
    80005d2e:	cd61                	beqz	a0,80005e06 <sys_unlink+0x118>
  ilock(dp);
    80005d30:	ffffe097          	auipc	ra,0xffffe
    80005d34:	116080e7          	jalr	278(ra) # 80003e46 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005d38:	00003597          	auipc	a1,0x3
    80005d3c:	f2058593          	addi	a1,a1,-224 # 80008c58 <userret+0xbc8>
    80005d40:	fb040513          	addi	a0,s0,-80
    80005d44:	ffffe097          	auipc	ra,0xffffe
    80005d48:	5a0080e7          	jalr	1440(ra) # 800042e4 <namecmp>
    80005d4c:	14050c63          	beqz	a0,80005ea4 <sys_unlink+0x1b6>
    80005d50:	00003597          	auipc	a1,0x3
    80005d54:	f1058593          	addi	a1,a1,-240 # 80008c60 <userret+0xbd0>
    80005d58:	fb040513          	addi	a0,s0,-80
    80005d5c:	ffffe097          	auipc	ra,0xffffe
    80005d60:	588080e7          	jalr	1416(ra) # 800042e4 <namecmp>
    80005d64:	14050063          	beqz	a0,80005ea4 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005d68:	f2c40613          	addi	a2,s0,-212
    80005d6c:	fb040593          	addi	a1,s0,-80
    80005d70:	8526                	mv	a0,s1
    80005d72:	ffffe097          	auipc	ra,0xffffe
    80005d76:	58c080e7          	jalr	1420(ra) # 800042fe <dirlookup>
    80005d7a:	892a                	mv	s2,a0
    80005d7c:	12050463          	beqz	a0,80005ea4 <sys_unlink+0x1b6>
  ilock(ip);
    80005d80:	ffffe097          	auipc	ra,0xffffe
    80005d84:	0c6080e7          	jalr	198(ra) # 80003e46 <ilock>
  if(ip->nlink < 1)
    80005d88:	06291783          	lh	a5,98(s2)
    80005d8c:	08f05463          	blez	a5,80005e14 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005d90:	05c91703          	lh	a4,92(s2)
    80005d94:	4785                	li	a5,1
    80005d96:	08f70763          	beq	a4,a5,80005e24 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005d9a:	4641                	li	a2,16
    80005d9c:	4581                	li	a1,0
    80005d9e:	fc040513          	addi	a0,s0,-64
    80005da2:	ffffb097          	auipc	ra,0xffffb
    80005da6:	332080e7          	jalr	818(ra) # 800010d4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005daa:	4741                	li	a4,16
    80005dac:	f2c42683          	lw	a3,-212(s0)
    80005db0:	fc040613          	addi	a2,s0,-64
    80005db4:	4581                	li	a1,0
    80005db6:	8526                	mv	a0,s1
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	412080e7          	jalr	1042(ra) # 800041ca <writei>
    80005dc0:	47c1                	li	a5,16
    80005dc2:	0af51763          	bne	a0,a5,80005e70 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005dc6:	05c91703          	lh	a4,92(s2)
    80005dca:	4785                	li	a5,1
    80005dcc:	0af70a63          	beq	a4,a5,80005e80 <sys_unlink+0x192>
  iunlockput(dp);
    80005dd0:	8526                	mv	a0,s1
    80005dd2:	ffffe097          	auipc	ra,0xffffe
    80005dd6:	2b2080e7          	jalr	690(ra) # 80004084 <iunlockput>
  ip->nlink--;
    80005dda:	06295783          	lhu	a5,98(s2)
    80005dde:	37fd                	addiw	a5,a5,-1
    80005de0:	06f91123          	sh	a5,98(s2)
  iupdate(ip);
    80005de4:	854a                	mv	a0,s2
    80005de6:	ffffe097          	auipc	ra,0xffffe
    80005dea:	f96080e7          	jalr	-106(ra) # 80003d7c <iupdate>
  iunlockput(ip);
    80005dee:	854a                	mv	a0,s2
    80005df0:	ffffe097          	auipc	ra,0xffffe
    80005df4:	294080e7          	jalr	660(ra) # 80004084 <iunlockput>
  end_op(ROOTDEV);
    80005df8:	4501                	li	a0,0
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	ac8080e7          	jalr	-1336(ra) # 800048c2 <end_op>
  return 0;
    80005e02:	4501                	li	a0,0
    80005e04:	a85d                	j	80005eba <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    80005e06:	4501                	li	a0,0
    80005e08:	fffff097          	auipc	ra,0xfffff
    80005e0c:	aba080e7          	jalr	-1350(ra) # 800048c2 <end_op>
    return -1;
    80005e10:	557d                	li	a0,-1
    80005e12:	a065                	j	80005eba <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    80005e14:	00003517          	auipc	a0,0x3
    80005e18:	e7450513          	addi	a0,a0,-396 # 80008c88 <userret+0xbf8>
    80005e1c:	ffffb097          	auipc	ra,0xffffb
    80005e20:	93a080e7          	jalr	-1734(ra) # 80000756 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e24:	06492703          	lw	a4,100(s2)
    80005e28:	02000793          	li	a5,32
    80005e2c:	f6e7f7e3          	bgeu	a5,a4,80005d9a <sys_unlink+0xac>
    80005e30:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e34:	4741                	li	a4,16
    80005e36:	86ce                	mv	a3,s3
    80005e38:	f1840613          	addi	a2,s0,-232
    80005e3c:	4581                	li	a1,0
    80005e3e:	854a                	mv	a0,s2
    80005e40:	ffffe097          	auipc	ra,0xffffe
    80005e44:	296080e7          	jalr	662(ra) # 800040d6 <readi>
    80005e48:	47c1                	li	a5,16
    80005e4a:	00f51b63          	bne	a0,a5,80005e60 <sys_unlink+0x172>
    if(de.inum != 0)
    80005e4e:	f1845783          	lhu	a5,-232(s0)
    80005e52:	e7a1                	bnez	a5,80005e9a <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e54:	29c1                	addiw	s3,s3,16
    80005e56:	06492783          	lw	a5,100(s2)
    80005e5a:	fcf9ede3          	bltu	s3,a5,80005e34 <sys_unlink+0x146>
    80005e5e:	bf35                	j	80005d9a <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005e60:	00003517          	auipc	a0,0x3
    80005e64:	e4050513          	addi	a0,a0,-448 # 80008ca0 <userret+0xc10>
    80005e68:	ffffb097          	auipc	ra,0xffffb
    80005e6c:	8ee080e7          	jalr	-1810(ra) # 80000756 <panic>
    panic("unlink: writei");
    80005e70:	00003517          	auipc	a0,0x3
    80005e74:	e4850513          	addi	a0,a0,-440 # 80008cb8 <userret+0xc28>
    80005e78:	ffffb097          	auipc	ra,0xffffb
    80005e7c:	8de080e7          	jalr	-1826(ra) # 80000756 <panic>
    dp->nlink--;
    80005e80:	0624d783          	lhu	a5,98(s1)
    80005e84:	37fd                	addiw	a5,a5,-1
    80005e86:	06f49123          	sh	a5,98(s1)
    iupdate(dp);
    80005e8a:	8526                	mv	a0,s1
    80005e8c:	ffffe097          	auipc	ra,0xffffe
    80005e90:	ef0080e7          	jalr	-272(ra) # 80003d7c <iupdate>
    80005e94:	bf35                	j	80005dd0 <sys_unlink+0xe2>
    return -1;
    80005e96:	557d                	li	a0,-1
    80005e98:	a00d                	j	80005eba <sys_unlink+0x1cc>
    iunlockput(ip);
    80005e9a:	854a                	mv	a0,s2
    80005e9c:	ffffe097          	auipc	ra,0xffffe
    80005ea0:	1e8080e7          	jalr	488(ra) # 80004084 <iunlockput>
  iunlockput(dp);
    80005ea4:	8526                	mv	a0,s1
    80005ea6:	ffffe097          	auipc	ra,0xffffe
    80005eaa:	1de080e7          	jalr	478(ra) # 80004084 <iunlockput>
  end_op(ROOTDEV);
    80005eae:	4501                	li	a0,0
    80005eb0:	fffff097          	auipc	ra,0xfffff
    80005eb4:	a12080e7          	jalr	-1518(ra) # 800048c2 <end_op>
  return -1;
    80005eb8:	557d                	li	a0,-1
}
    80005eba:	70ae                	ld	ra,232(sp)
    80005ebc:	740e                	ld	s0,224(sp)
    80005ebe:	64ee                	ld	s1,216(sp)
    80005ec0:	694e                	ld	s2,208(sp)
    80005ec2:	69ae                	ld	s3,200(sp)
    80005ec4:	616d                	addi	sp,sp,240
    80005ec6:	8082                	ret

0000000080005ec8 <sys_open>:

uint64
sys_open(void)
{
    80005ec8:	7131                	addi	sp,sp,-192
    80005eca:	fd06                	sd	ra,184(sp)
    80005ecc:	f922                	sd	s0,176(sp)
    80005ece:	f526                	sd	s1,168(sp)
    80005ed0:	f14a                	sd	s2,160(sp)
    80005ed2:	ed4e                	sd	s3,152(sp)
    80005ed4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005ed6:	08000613          	li	a2,128
    80005eda:	f5040593          	addi	a1,s0,-176
    80005ede:	4501                	li	a0,0
    80005ee0:	ffffd097          	auipc	ra,0xffffd
    80005ee4:	426080e7          	jalr	1062(ra) # 80003306 <argstr>
    return -1;
    80005ee8:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005eea:	0a054963          	bltz	a0,80005f9c <sys_open+0xd4>
    80005eee:	f4c40593          	addi	a1,s0,-180
    80005ef2:	4505                	li	a0,1
    80005ef4:	ffffd097          	auipc	ra,0xffffd
    80005ef8:	3ce080e7          	jalr	974(ra) # 800032c2 <argint>
    80005efc:	0a054063          	bltz	a0,80005f9c <sys_open+0xd4>

  begin_op(ROOTDEV);
    80005f00:	4501                	li	a0,0
    80005f02:	fffff097          	auipc	ra,0xfffff
    80005f06:	914080e7          	jalr	-1772(ra) # 80004816 <begin_op>

  if(omode & O_CREATE){
    80005f0a:	f4c42783          	lw	a5,-180(s0)
    80005f0e:	2007f793          	andi	a5,a5,512
    80005f12:	c3dd                	beqz	a5,80005fb8 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80005f14:	4681                	li	a3,0
    80005f16:	4601                	li	a2,0
    80005f18:	4589                	li	a1,2
    80005f1a:	f5040513          	addi	a0,s0,-176
    80005f1e:	00000097          	auipc	ra,0x0
    80005f22:	95e080e7          	jalr	-1698(ra) # 8000587c <create>
    80005f26:	892a                	mv	s2,a0
    if(ip == 0){
    80005f28:	c151                	beqz	a0,80005fac <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005f2a:	05c91703          	lh	a4,92(s2)
    80005f2e:	478d                	li	a5,3
    80005f30:	00f71763          	bne	a4,a5,80005f3e <sys_open+0x76>
    80005f34:	05e95703          	lhu	a4,94(s2)
    80005f38:	47a5                	li	a5,9
    80005f3a:	0ce7e663          	bltu	a5,a4,80006006 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005f3e:	fffff097          	auipc	ra,0xfffff
    80005f42:	da6080e7          	jalr	-602(ra) # 80004ce4 <filealloc>
    80005f46:	89aa                	mv	s3,a0
    80005f48:	c97d                	beqz	a0,8000603e <sys_open+0x176>
    80005f4a:	00000097          	auipc	ra,0x0
    80005f4e:	8f0080e7          	jalr	-1808(ra) # 8000583a <fdalloc>
    80005f52:	84aa                	mv	s1,a0
    80005f54:	0e054063          	bltz	a0,80006034 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005f58:	05c91703          	lh	a4,92(s2)
    80005f5c:	478d                	li	a5,3
    80005f5e:	0cf70063          	beq	a4,a5,8000601e <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005f62:	4789                	li	a5,2
    80005f64:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005f68:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005f6c:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005f70:	f4c42783          	lw	a5,-180(s0)
    80005f74:	0017c713          	xori	a4,a5,1
    80005f78:	8b05                	andi	a4,a4,1
    80005f7a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f7e:	8b8d                	andi	a5,a5,3
    80005f80:	00f037b3          	snez	a5,a5
    80005f84:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005f88:	854a                	mv	a0,s2
    80005f8a:	ffffe097          	auipc	ra,0xffffe
    80005f8e:	f7e080e7          	jalr	-130(ra) # 80003f08 <iunlock>
  end_op(ROOTDEV);
    80005f92:	4501                	li	a0,0
    80005f94:	fffff097          	auipc	ra,0xfffff
    80005f98:	92e080e7          	jalr	-1746(ra) # 800048c2 <end_op>

  return fd;
}
    80005f9c:	8526                	mv	a0,s1
    80005f9e:	70ea                	ld	ra,184(sp)
    80005fa0:	744a                	ld	s0,176(sp)
    80005fa2:	74aa                	ld	s1,168(sp)
    80005fa4:	790a                	ld	s2,160(sp)
    80005fa6:	69ea                	ld	s3,152(sp)
    80005fa8:	6129                	addi	sp,sp,192
    80005faa:	8082                	ret
      end_op(ROOTDEV);
    80005fac:	4501                	li	a0,0
    80005fae:	fffff097          	auipc	ra,0xfffff
    80005fb2:	914080e7          	jalr	-1772(ra) # 800048c2 <end_op>
      return -1;
    80005fb6:	b7dd                	j	80005f9c <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005fb8:	f5040513          	addi	a0,s0,-176
    80005fbc:	ffffe097          	auipc	ra,0xffffe
    80005fc0:	614080e7          	jalr	1556(ra) # 800045d0 <namei>
    80005fc4:	892a                	mv	s2,a0
    80005fc6:	c90d                	beqz	a0,80005ff8 <sys_open+0x130>
    ilock(ip);
    80005fc8:	ffffe097          	auipc	ra,0xffffe
    80005fcc:	e7e080e7          	jalr	-386(ra) # 80003e46 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005fd0:	05c91703          	lh	a4,92(s2)
    80005fd4:	4785                	li	a5,1
    80005fd6:	f4f71ae3          	bne	a4,a5,80005f2a <sys_open+0x62>
    80005fda:	f4c42783          	lw	a5,-180(s0)
    80005fde:	d3a5                	beqz	a5,80005f3e <sys_open+0x76>
      iunlockput(ip);
    80005fe0:	854a                	mv	a0,s2
    80005fe2:	ffffe097          	auipc	ra,0xffffe
    80005fe6:	0a2080e7          	jalr	162(ra) # 80004084 <iunlockput>
      end_op(ROOTDEV);
    80005fea:	4501                	li	a0,0
    80005fec:	fffff097          	auipc	ra,0xfffff
    80005ff0:	8d6080e7          	jalr	-1834(ra) # 800048c2 <end_op>
      return -1;
    80005ff4:	54fd                	li	s1,-1
    80005ff6:	b75d                	j	80005f9c <sys_open+0xd4>
      end_op(ROOTDEV);
    80005ff8:	4501                	li	a0,0
    80005ffa:	fffff097          	auipc	ra,0xfffff
    80005ffe:	8c8080e7          	jalr	-1848(ra) # 800048c2 <end_op>
      return -1;
    80006002:	54fd                	li	s1,-1
    80006004:	bf61                	j	80005f9c <sys_open+0xd4>
    iunlockput(ip);
    80006006:	854a                	mv	a0,s2
    80006008:	ffffe097          	auipc	ra,0xffffe
    8000600c:	07c080e7          	jalr	124(ra) # 80004084 <iunlockput>
    end_op(ROOTDEV);
    80006010:	4501                	li	a0,0
    80006012:	fffff097          	auipc	ra,0xfffff
    80006016:	8b0080e7          	jalr	-1872(ra) # 800048c2 <end_op>
    return -1;
    8000601a:	54fd                	li	s1,-1
    8000601c:	b741                	j	80005f9c <sys_open+0xd4>
    f->type = FD_DEVICE;
    8000601e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006022:	05e91783          	lh	a5,94(s2)
    80006026:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    8000602a:	06091783          	lh	a5,96(s2)
    8000602e:	02f99323          	sh	a5,38(s3)
    80006032:	bf1d                	j	80005f68 <sys_open+0xa0>
      fileclose(f);
    80006034:	854e                	mv	a0,s3
    80006036:	fffff097          	auipc	ra,0xfffff
    8000603a:	d6a080e7          	jalr	-662(ra) # 80004da0 <fileclose>
    iunlockput(ip);
    8000603e:	854a                	mv	a0,s2
    80006040:	ffffe097          	auipc	ra,0xffffe
    80006044:	044080e7          	jalr	68(ra) # 80004084 <iunlockput>
    end_op(ROOTDEV);
    80006048:	4501                	li	a0,0
    8000604a:	fffff097          	auipc	ra,0xfffff
    8000604e:	878080e7          	jalr	-1928(ra) # 800048c2 <end_op>
    return -1;
    80006052:	54fd                	li	s1,-1
    80006054:	b7a1                	j	80005f9c <sys_open+0xd4>

0000000080006056 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006056:	7175                	addi	sp,sp,-144
    80006058:	e506                	sd	ra,136(sp)
    8000605a:	e122                	sd	s0,128(sp)
    8000605c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    8000605e:	4501                	li	a0,0
    80006060:	ffffe097          	auipc	ra,0xffffe
    80006064:	7b6080e7          	jalr	1974(ra) # 80004816 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006068:	08000613          	li	a2,128
    8000606c:	f7040593          	addi	a1,s0,-144
    80006070:	4501                	li	a0,0
    80006072:	ffffd097          	auipc	ra,0xffffd
    80006076:	294080e7          	jalr	660(ra) # 80003306 <argstr>
    8000607a:	02054a63          	bltz	a0,800060ae <sys_mkdir+0x58>
    8000607e:	4681                	li	a3,0
    80006080:	4601                	li	a2,0
    80006082:	4585                	li	a1,1
    80006084:	f7040513          	addi	a0,s0,-144
    80006088:	fffff097          	auipc	ra,0xfffff
    8000608c:	7f4080e7          	jalr	2036(ra) # 8000587c <create>
    80006090:	cd19                	beqz	a0,800060ae <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80006092:	ffffe097          	auipc	ra,0xffffe
    80006096:	ff2080e7          	jalr	-14(ra) # 80004084 <iunlockput>
  end_op(ROOTDEV);
    8000609a:	4501                	li	a0,0
    8000609c:	fffff097          	auipc	ra,0xfffff
    800060a0:	826080e7          	jalr	-2010(ra) # 800048c2 <end_op>
  return 0;
    800060a4:	4501                	li	a0,0
}
    800060a6:	60aa                	ld	ra,136(sp)
    800060a8:	640a                	ld	s0,128(sp)
    800060aa:	6149                	addi	sp,sp,144
    800060ac:	8082                	ret
    end_op(ROOTDEV);
    800060ae:	4501                	li	a0,0
    800060b0:	fffff097          	auipc	ra,0xfffff
    800060b4:	812080e7          	jalr	-2030(ra) # 800048c2 <end_op>
    return -1;
    800060b8:	557d                	li	a0,-1
    800060ba:	b7f5                	j	800060a6 <sys_mkdir+0x50>

00000000800060bc <sys_mknod>:

uint64
sys_mknod(void)
{
    800060bc:	7135                	addi	sp,sp,-160
    800060be:	ed06                	sd	ra,152(sp)
    800060c0:	e922                	sd	s0,144(sp)
    800060c2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    800060c4:	4501                	li	a0,0
    800060c6:	ffffe097          	auipc	ra,0xffffe
    800060ca:	750080e7          	jalr	1872(ra) # 80004816 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800060ce:	08000613          	li	a2,128
    800060d2:	f7040593          	addi	a1,s0,-144
    800060d6:	4501                	li	a0,0
    800060d8:	ffffd097          	auipc	ra,0xffffd
    800060dc:	22e080e7          	jalr	558(ra) # 80003306 <argstr>
    800060e0:	04054b63          	bltz	a0,80006136 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    800060e4:	f6c40593          	addi	a1,s0,-148
    800060e8:	4505                	li	a0,1
    800060ea:	ffffd097          	auipc	ra,0xffffd
    800060ee:	1d8080e7          	jalr	472(ra) # 800032c2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800060f2:	04054263          	bltz	a0,80006136 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    800060f6:	f6840593          	addi	a1,s0,-152
    800060fa:	4509                	li	a0,2
    800060fc:	ffffd097          	auipc	ra,0xffffd
    80006100:	1c6080e7          	jalr	454(ra) # 800032c2 <argint>
     argint(1, &major) < 0 ||
    80006104:	02054963          	bltz	a0,80006136 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006108:	f6841683          	lh	a3,-152(s0)
    8000610c:	f6c41603          	lh	a2,-148(s0)
    80006110:	458d                	li	a1,3
    80006112:	f7040513          	addi	a0,s0,-144
    80006116:	fffff097          	auipc	ra,0xfffff
    8000611a:	766080e7          	jalr	1894(ra) # 8000587c <create>
     argint(2, &minor) < 0 ||
    8000611e:	cd01                	beqz	a0,80006136 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80006120:	ffffe097          	auipc	ra,0xffffe
    80006124:	f64080e7          	jalr	-156(ra) # 80004084 <iunlockput>
  end_op(ROOTDEV);
    80006128:	4501                	li	a0,0
    8000612a:	ffffe097          	auipc	ra,0xffffe
    8000612e:	798080e7          	jalr	1944(ra) # 800048c2 <end_op>
  return 0;
    80006132:	4501                	li	a0,0
    80006134:	a039                	j	80006142 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80006136:	4501                	li	a0,0
    80006138:	ffffe097          	auipc	ra,0xffffe
    8000613c:	78a080e7          	jalr	1930(ra) # 800048c2 <end_op>
    return -1;
    80006140:	557d                	li	a0,-1
}
    80006142:	60ea                	ld	ra,152(sp)
    80006144:	644a                	ld	s0,144(sp)
    80006146:	610d                	addi	sp,sp,160
    80006148:	8082                	ret

000000008000614a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000614a:	7135                	addi	sp,sp,-160
    8000614c:	ed06                	sd	ra,152(sp)
    8000614e:	e922                	sd	s0,144(sp)
    80006150:	e526                	sd	s1,136(sp)
    80006152:	e14a                	sd	s2,128(sp)
    80006154:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006156:	ffffc097          	auipc	ra,0xffffc
    8000615a:	e46080e7          	jalr	-442(ra) # 80001f9c <myproc>
    8000615e:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80006160:	4501                	li	a0,0
    80006162:	ffffe097          	auipc	ra,0xffffe
    80006166:	6b4080e7          	jalr	1716(ra) # 80004816 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000616a:	08000613          	li	a2,128
    8000616e:	f6040593          	addi	a1,s0,-160
    80006172:	4501                	li	a0,0
    80006174:	ffffd097          	auipc	ra,0xffffd
    80006178:	192080e7          	jalr	402(ra) # 80003306 <argstr>
    8000617c:	04054c63          	bltz	a0,800061d4 <sys_chdir+0x8a>
    80006180:	f6040513          	addi	a0,s0,-160
    80006184:	ffffe097          	auipc	ra,0xffffe
    80006188:	44c080e7          	jalr	1100(ra) # 800045d0 <namei>
    8000618c:	84aa                	mv	s1,a0
    8000618e:	c139                	beqz	a0,800061d4 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80006190:	ffffe097          	auipc	ra,0xffffe
    80006194:	cb6080e7          	jalr	-842(ra) # 80003e46 <ilock>
  if(ip->type != T_DIR){
    80006198:	05c49703          	lh	a4,92(s1)
    8000619c:	4785                	li	a5,1
    8000619e:	04f71263          	bne	a4,a5,800061e2 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    800061a2:	8526                	mv	a0,s1
    800061a4:	ffffe097          	auipc	ra,0xffffe
    800061a8:	d64080e7          	jalr	-668(ra) # 80003f08 <iunlock>
  iput(p->cwd);
    800061ac:	16893503          	ld	a0,360(s2)
    800061b0:	ffffe097          	auipc	ra,0xffffe
    800061b4:	da4080e7          	jalr	-604(ra) # 80003f54 <iput>
  end_op(ROOTDEV);
    800061b8:	4501                	li	a0,0
    800061ba:	ffffe097          	auipc	ra,0xffffe
    800061be:	708080e7          	jalr	1800(ra) # 800048c2 <end_op>
  p->cwd = ip;
    800061c2:	16993423          	sd	s1,360(s2)
  return 0;
    800061c6:	4501                	li	a0,0
}
    800061c8:	60ea                	ld	ra,152(sp)
    800061ca:	644a                	ld	s0,144(sp)
    800061cc:	64aa                	ld	s1,136(sp)
    800061ce:	690a                	ld	s2,128(sp)
    800061d0:	610d                	addi	sp,sp,160
    800061d2:	8082                	ret
    end_op(ROOTDEV);
    800061d4:	4501                	li	a0,0
    800061d6:	ffffe097          	auipc	ra,0xffffe
    800061da:	6ec080e7          	jalr	1772(ra) # 800048c2 <end_op>
    return -1;
    800061de:	557d                	li	a0,-1
    800061e0:	b7e5                	j	800061c8 <sys_chdir+0x7e>
    iunlockput(ip);
    800061e2:	8526                	mv	a0,s1
    800061e4:	ffffe097          	auipc	ra,0xffffe
    800061e8:	ea0080e7          	jalr	-352(ra) # 80004084 <iunlockput>
    end_op(ROOTDEV);
    800061ec:	4501                	li	a0,0
    800061ee:	ffffe097          	auipc	ra,0xffffe
    800061f2:	6d4080e7          	jalr	1748(ra) # 800048c2 <end_op>
    return -1;
    800061f6:	557d                	li	a0,-1
    800061f8:	bfc1                	j	800061c8 <sys_chdir+0x7e>

00000000800061fa <sys_exec>:

uint64
sys_exec(void)
{
    800061fa:	7145                	addi	sp,sp,-464
    800061fc:	e786                	sd	ra,456(sp)
    800061fe:	e3a2                	sd	s0,448(sp)
    80006200:	ff26                	sd	s1,440(sp)
    80006202:	fb4a                	sd	s2,432(sp)
    80006204:	f74e                	sd	s3,424(sp)
    80006206:	f352                	sd	s4,416(sp)
    80006208:	ef56                	sd	s5,408(sp)
    8000620a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000620c:	08000613          	li	a2,128
    80006210:	f4040593          	addi	a1,s0,-192
    80006214:	4501                	li	a0,0
    80006216:	ffffd097          	auipc	ra,0xffffd
    8000621a:	0f0080e7          	jalr	240(ra) # 80003306 <argstr>
    8000621e:	0e054663          	bltz	a0,8000630a <sys_exec+0x110>
    80006222:	e3840593          	addi	a1,s0,-456
    80006226:	4505                	li	a0,1
    80006228:	ffffd097          	auipc	ra,0xffffd
    8000622c:	0bc080e7          	jalr	188(ra) # 800032e4 <argaddr>
    80006230:	0e054763          	bltz	a0,8000631e <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80006234:	10000613          	li	a2,256
    80006238:	4581                	li	a1,0
    8000623a:	e4040513          	addi	a0,s0,-448
    8000623e:	ffffb097          	auipc	ra,0xffffb
    80006242:	e96080e7          	jalr	-362(ra) # 800010d4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006246:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    8000624a:	89ca                	mv	s3,s2
    8000624c:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    8000624e:	02000a13          	li	s4,32
    80006252:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006256:	00349513          	slli	a0,s1,0x3
    8000625a:	e3040593          	addi	a1,s0,-464
    8000625e:	e3843783          	ld	a5,-456(s0)
    80006262:	953e                	add	a0,a0,a5
    80006264:	ffffd097          	auipc	ra,0xffffd
    80006268:	fc4080e7          	jalr	-60(ra) # 80003228 <fetchaddr>
    8000626c:	02054a63          	bltz	a0,800062a0 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80006270:	e3043783          	ld	a5,-464(s0)
    80006274:	c7a1                	beqz	a5,800062bc <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006276:	ffffb097          	auipc	ra,0xffffb
    8000627a:	88e080e7          	jalr	-1906(ra) # 80000b04 <kalloc>
    8000627e:	85aa                	mv	a1,a0
    80006280:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006284:	c92d                	beqz	a0,800062f6 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80006286:	6605                	lui	a2,0x1
    80006288:	e3043503          	ld	a0,-464(s0)
    8000628c:	ffffd097          	auipc	ra,0xffffd
    80006290:	fee080e7          	jalr	-18(ra) # 8000327a <fetchstr>
    80006294:	00054663          	bltz	a0,800062a0 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006298:	0485                	addi	s1,s1,1
    8000629a:	09a1                	addi	s3,s3,8
    8000629c:	fb449be3          	bne	s1,s4,80006252 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062a0:	10090493          	addi	s1,s2,256
    800062a4:	00093503          	ld	a0,0(s2)
    800062a8:	cd39                	beqz	a0,80006306 <sys_exec+0x10c>
    kfree(argv[i]);
    800062aa:	ffffb097          	auipc	ra,0xffffb
    800062ae:	842080e7          	jalr	-1982(ra) # 80000aec <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062b2:	0921                	addi	s2,s2,8
    800062b4:	fe9918e3          	bne	s2,s1,800062a4 <sys_exec+0xaa>
  return -1;
    800062b8:	557d                	li	a0,-1
    800062ba:	a889                	j	8000630c <sys_exec+0x112>
      argv[i] = 0;
    800062bc:	0a8e                	slli	s5,s5,0x3
    800062be:	fc040793          	addi	a5,s0,-64
    800062c2:	9abe                	add	s5,s5,a5
    800062c4:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800062c8:	e4040593          	addi	a1,s0,-448
    800062cc:	f4040513          	addi	a0,s0,-192
    800062d0:	fffff097          	auipc	ra,0xfffff
    800062d4:	182080e7          	jalr	386(ra) # 80005452 <exec>
    800062d8:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062da:	10090993          	addi	s3,s2,256
    800062de:	00093503          	ld	a0,0(s2)
    800062e2:	c901                	beqz	a0,800062f2 <sys_exec+0xf8>
    kfree(argv[i]);
    800062e4:	ffffb097          	auipc	ra,0xffffb
    800062e8:	808080e7          	jalr	-2040(ra) # 80000aec <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062ec:	0921                	addi	s2,s2,8
    800062ee:	ff3918e3          	bne	s2,s3,800062de <sys_exec+0xe4>
  return ret;
    800062f2:	8526                	mv	a0,s1
    800062f4:	a821                	j	8000630c <sys_exec+0x112>
      panic("sys_exec kalloc");
    800062f6:	00003517          	auipc	a0,0x3
    800062fa:	9d250513          	addi	a0,a0,-1582 # 80008cc8 <userret+0xc38>
    800062fe:	ffffa097          	auipc	ra,0xffffa
    80006302:	458080e7          	jalr	1112(ra) # 80000756 <panic>
  return -1;
    80006306:	557d                	li	a0,-1
    80006308:	a011                	j	8000630c <sys_exec+0x112>
    return -1;
    8000630a:	557d                	li	a0,-1
}
    8000630c:	60be                	ld	ra,456(sp)
    8000630e:	641e                	ld	s0,448(sp)
    80006310:	74fa                	ld	s1,440(sp)
    80006312:	795a                	ld	s2,432(sp)
    80006314:	79ba                	ld	s3,424(sp)
    80006316:	7a1a                	ld	s4,416(sp)
    80006318:	6afa                	ld	s5,408(sp)
    8000631a:	6179                	addi	sp,sp,464
    8000631c:	8082                	ret
    return -1;
    8000631e:	557d                	li	a0,-1
    80006320:	b7f5                	j	8000630c <sys_exec+0x112>

0000000080006322 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006322:	7139                	addi	sp,sp,-64
    80006324:	fc06                	sd	ra,56(sp)
    80006326:	f822                	sd	s0,48(sp)
    80006328:	f426                	sd	s1,40(sp)
    8000632a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000632c:	ffffc097          	auipc	ra,0xffffc
    80006330:	c70080e7          	jalr	-912(ra) # 80001f9c <myproc>
    80006334:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006336:	fd840593          	addi	a1,s0,-40
    8000633a:	4501                	li	a0,0
    8000633c:	ffffd097          	auipc	ra,0xffffd
    80006340:	fa8080e7          	jalr	-88(ra) # 800032e4 <argaddr>
    return -1;
    80006344:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006346:	0e054063          	bltz	a0,80006426 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000634a:	fc840593          	addi	a1,s0,-56
    8000634e:	fd040513          	addi	a0,s0,-48
    80006352:	fffff097          	auipc	ra,0xfffff
    80006356:	db2080e7          	jalr	-590(ra) # 80005104 <pipealloc>
    return -1;
    8000635a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000635c:	0c054563          	bltz	a0,80006426 <sys_pipe+0x104>
  fd0 = -1;
    80006360:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006364:	fd043503          	ld	a0,-48(s0)
    80006368:	fffff097          	auipc	ra,0xfffff
    8000636c:	4d2080e7          	jalr	1234(ra) # 8000583a <fdalloc>
    80006370:	fca42223          	sw	a0,-60(s0)
    80006374:	08054c63          	bltz	a0,8000640c <sys_pipe+0xea>
    80006378:	fc843503          	ld	a0,-56(s0)
    8000637c:	fffff097          	auipc	ra,0xfffff
    80006380:	4be080e7          	jalr	1214(ra) # 8000583a <fdalloc>
    80006384:	fca42023          	sw	a0,-64(s0)
    80006388:	06054863          	bltz	a0,800063f8 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000638c:	4691                	li	a3,4
    8000638e:	fc440613          	addi	a2,s0,-60
    80006392:	fd843583          	ld	a1,-40(s0)
    80006396:	74a8                	ld	a0,104(s1)
    80006398:	ffffc097          	auipc	ra,0xffffc
    8000639c:	806080e7          	jalr	-2042(ra) # 80001b9e <copyout>
    800063a0:	02054063          	bltz	a0,800063c0 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800063a4:	4691                	li	a3,4
    800063a6:	fc040613          	addi	a2,s0,-64
    800063aa:	fd843583          	ld	a1,-40(s0)
    800063ae:	0591                	addi	a1,a1,4
    800063b0:	74a8                	ld	a0,104(s1)
    800063b2:	ffffb097          	auipc	ra,0xffffb
    800063b6:	7ec080e7          	jalr	2028(ra) # 80001b9e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800063ba:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063bc:	06055563          	bgez	a0,80006426 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800063c0:	fc442783          	lw	a5,-60(s0)
    800063c4:	07f1                	addi	a5,a5,28
    800063c6:	078e                	slli	a5,a5,0x3
    800063c8:	97a6                	add	a5,a5,s1
    800063ca:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800063ce:	fc042503          	lw	a0,-64(s0)
    800063d2:	0571                	addi	a0,a0,28
    800063d4:	050e                	slli	a0,a0,0x3
    800063d6:	9526                	add	a0,a0,s1
    800063d8:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    800063dc:	fd043503          	ld	a0,-48(s0)
    800063e0:	fffff097          	auipc	ra,0xfffff
    800063e4:	9c0080e7          	jalr	-1600(ra) # 80004da0 <fileclose>
    fileclose(wf);
    800063e8:	fc843503          	ld	a0,-56(s0)
    800063ec:	fffff097          	auipc	ra,0xfffff
    800063f0:	9b4080e7          	jalr	-1612(ra) # 80004da0 <fileclose>
    return -1;
    800063f4:	57fd                	li	a5,-1
    800063f6:	a805                	j	80006426 <sys_pipe+0x104>
    if(fd0 >= 0)
    800063f8:	fc442783          	lw	a5,-60(s0)
    800063fc:	0007c863          	bltz	a5,8000640c <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006400:	01c78513          	addi	a0,a5,28
    80006404:	050e                	slli	a0,a0,0x3
    80006406:	9526                	add	a0,a0,s1
    80006408:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000640c:	fd043503          	ld	a0,-48(s0)
    80006410:	fffff097          	auipc	ra,0xfffff
    80006414:	990080e7          	jalr	-1648(ra) # 80004da0 <fileclose>
    fileclose(wf);
    80006418:	fc843503          	ld	a0,-56(s0)
    8000641c:	fffff097          	auipc	ra,0xfffff
    80006420:	984080e7          	jalr	-1660(ra) # 80004da0 <fileclose>
    return -1;
    80006424:	57fd                	li	a5,-1
}
    80006426:	853e                	mv	a0,a5
    80006428:	70e2                	ld	ra,56(sp)
    8000642a:	7442                	ld	s0,48(sp)
    8000642c:	74a2                	ld	s1,40(sp)
    8000642e:	6121                	addi	sp,sp,64
    80006430:	8082                	ret

0000000080006432 <sys_create_mutex>:

uint64
sys_create_mutex(void)
{
    80006432:	1141                	addi	sp,sp,-16
    80006434:	e422                	sd	s0,8(sp)
    80006436:	0800                	addi	s0,sp,16
  return -1;
}
    80006438:	557d                	li	a0,-1
    8000643a:	6422                	ld	s0,8(sp)
    8000643c:	0141                	addi	sp,sp,16
    8000643e:	8082                	ret

0000000080006440 <sys_acquire_mutex>:

uint64
sys_acquire_mutex(void)
{
    80006440:	1141                	addi	sp,sp,-16
    80006442:	e422                	sd	s0,8(sp)
    80006444:	0800                	addi	s0,sp,16
  return 0;
}
    80006446:	4501                	li	a0,0
    80006448:	6422                	ld	s0,8(sp)
    8000644a:	0141                	addi	sp,sp,16
    8000644c:	8082                	ret

000000008000644e <sys_release_mutex>:

uint64
sys_release_mutex(void)
{
    8000644e:	1141                	addi	sp,sp,-16
    80006450:	e422                	sd	s0,8(sp)
    80006452:	0800                	addi	s0,sp,16

  return 0;
}
    80006454:	4501                	li	a0,0
    80006456:	6422                	ld	s0,8(sp)
    80006458:	0141                	addi	sp,sp,16
    8000645a:	8082                	ret
    8000645c:	0000                	unimp
	...

0000000080006460 <kernelvec>:
    80006460:	7111                	addi	sp,sp,-256
    80006462:	e006                	sd	ra,0(sp)
    80006464:	e40a                	sd	sp,8(sp)
    80006466:	e80e                	sd	gp,16(sp)
    80006468:	ec12                	sd	tp,24(sp)
    8000646a:	f016                	sd	t0,32(sp)
    8000646c:	f41a                	sd	t1,40(sp)
    8000646e:	f81e                	sd	t2,48(sp)
    80006470:	fc22                	sd	s0,56(sp)
    80006472:	e0a6                	sd	s1,64(sp)
    80006474:	e4aa                	sd	a0,72(sp)
    80006476:	e8ae                	sd	a1,80(sp)
    80006478:	ecb2                	sd	a2,88(sp)
    8000647a:	f0b6                	sd	a3,96(sp)
    8000647c:	f4ba                	sd	a4,104(sp)
    8000647e:	f8be                	sd	a5,112(sp)
    80006480:	fcc2                	sd	a6,120(sp)
    80006482:	e146                	sd	a7,128(sp)
    80006484:	e54a                	sd	s2,136(sp)
    80006486:	e94e                	sd	s3,144(sp)
    80006488:	ed52                	sd	s4,152(sp)
    8000648a:	f156                	sd	s5,160(sp)
    8000648c:	f55a                	sd	s6,168(sp)
    8000648e:	f95e                	sd	s7,176(sp)
    80006490:	fd62                	sd	s8,184(sp)
    80006492:	e1e6                	sd	s9,192(sp)
    80006494:	e5ea                	sd	s10,200(sp)
    80006496:	e9ee                	sd	s11,208(sp)
    80006498:	edf2                	sd	t3,216(sp)
    8000649a:	f1f6                	sd	t4,224(sp)
    8000649c:	f5fa                	sd	t5,232(sp)
    8000649e:	f9fe                	sd	t6,240(sp)
    800064a0:	c49fc0ef          	jal	ra,800030e8 <kerneltrap>
    800064a4:	6082                	ld	ra,0(sp)
    800064a6:	6122                	ld	sp,8(sp)
    800064a8:	61c2                	ld	gp,16(sp)
    800064aa:	7282                	ld	t0,32(sp)
    800064ac:	7322                	ld	t1,40(sp)
    800064ae:	73c2                	ld	t2,48(sp)
    800064b0:	7462                	ld	s0,56(sp)
    800064b2:	6486                	ld	s1,64(sp)
    800064b4:	6526                	ld	a0,72(sp)
    800064b6:	65c6                	ld	a1,80(sp)
    800064b8:	6666                	ld	a2,88(sp)
    800064ba:	7686                	ld	a3,96(sp)
    800064bc:	7726                	ld	a4,104(sp)
    800064be:	77c6                	ld	a5,112(sp)
    800064c0:	7866                	ld	a6,120(sp)
    800064c2:	688a                	ld	a7,128(sp)
    800064c4:	692a                	ld	s2,136(sp)
    800064c6:	69ca                	ld	s3,144(sp)
    800064c8:	6a6a                	ld	s4,152(sp)
    800064ca:	7a8a                	ld	s5,160(sp)
    800064cc:	7b2a                	ld	s6,168(sp)
    800064ce:	7bca                	ld	s7,176(sp)
    800064d0:	7c6a                	ld	s8,184(sp)
    800064d2:	6c8e                	ld	s9,192(sp)
    800064d4:	6d2e                	ld	s10,200(sp)
    800064d6:	6dce                	ld	s11,208(sp)
    800064d8:	6e6e                	ld	t3,216(sp)
    800064da:	7e8e                	ld	t4,224(sp)
    800064dc:	7f2e                	ld	t5,232(sp)
    800064de:	7fce                	ld	t6,240(sp)
    800064e0:	6111                	addi	sp,sp,256
    800064e2:	10200073          	sret
    800064e6:	00000013          	nop
    800064ea:	00000013          	nop
    800064ee:	0001                	nop

00000000800064f0 <timervec>:
    800064f0:	34051573          	csrrw	a0,mscratch,a0
    800064f4:	e10c                	sd	a1,0(a0)
    800064f6:	e510                	sd	a2,8(a0)
    800064f8:	e914                	sd	a3,16(a0)
    800064fa:	710c                	ld	a1,32(a0)
    800064fc:	7510                	ld	a2,40(a0)
    800064fe:	6194                	ld	a3,0(a1)
    80006500:	96b2                	add	a3,a3,a2
    80006502:	e194                	sd	a3,0(a1)
    80006504:	4589                	li	a1,2
    80006506:	14459073          	csrw	sip,a1
    8000650a:	6914                	ld	a3,16(a0)
    8000650c:	6510                	ld	a2,8(a0)
    8000650e:	610c                	ld	a1,0(a0)
    80006510:	34051573          	csrrw	a0,mscratch,a0
    80006514:	30200073          	mret
	...

000000008000651a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000651a:	1141                	addi	sp,sp,-16
    8000651c:	e422                	sd	s0,8(sp)
    8000651e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006520:	0c0007b7          	lui	a5,0xc000
    80006524:	4705                	li	a4,1
    80006526:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006528:	c3d8                	sw	a4,4(a5)
}
    8000652a:	6422                	ld	s0,8(sp)
    8000652c:	0141                	addi	sp,sp,16
    8000652e:	8082                	ret

0000000080006530 <plicinithart>:

void
plicinithart(void)
{
    80006530:	1141                	addi	sp,sp,-16
    80006532:	e406                	sd	ra,8(sp)
    80006534:	e022                	sd	s0,0(sp)
    80006536:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006538:	ffffc097          	auipc	ra,0xffffc
    8000653c:	a38080e7          	jalr	-1480(ra) # 80001f70 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006540:	0085171b          	slliw	a4,a0,0x8
    80006544:	0c0027b7          	lui	a5,0xc002
    80006548:	97ba                	add	a5,a5,a4
    8000654a:	40200713          	li	a4,1026
    8000654e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006552:	00d5151b          	slliw	a0,a0,0xd
    80006556:	0c2017b7          	lui	a5,0xc201
    8000655a:	953e                	add	a0,a0,a5
    8000655c:	00052023          	sw	zero,0(a0)
}
    80006560:	60a2                	ld	ra,8(sp)
    80006562:	6402                	ld	s0,0(sp)
    80006564:	0141                	addi	sp,sp,16
    80006566:	8082                	ret

0000000080006568 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006568:	1141                	addi	sp,sp,-16
    8000656a:	e406                	sd	ra,8(sp)
    8000656c:	e022                	sd	s0,0(sp)
    8000656e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006570:	ffffc097          	auipc	ra,0xffffc
    80006574:	a00080e7          	jalr	-1536(ra) # 80001f70 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006578:	00d5179b          	slliw	a5,a0,0xd
    8000657c:	0c201537          	lui	a0,0xc201
    80006580:	953e                	add	a0,a0,a5
  return irq;
}
    80006582:	4148                	lw	a0,4(a0)
    80006584:	60a2                	ld	ra,8(sp)
    80006586:	6402                	ld	s0,0(sp)
    80006588:	0141                	addi	sp,sp,16
    8000658a:	8082                	ret

000000008000658c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000658c:	1101                	addi	sp,sp,-32
    8000658e:	ec06                	sd	ra,24(sp)
    80006590:	e822                	sd	s0,16(sp)
    80006592:	e426                	sd	s1,8(sp)
    80006594:	1000                	addi	s0,sp,32
    80006596:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006598:	ffffc097          	auipc	ra,0xffffc
    8000659c:	9d8080e7          	jalr	-1576(ra) # 80001f70 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800065a0:	00d5151b          	slliw	a0,a0,0xd
    800065a4:	0c2017b7          	lui	a5,0xc201
    800065a8:	97aa                	add	a5,a5,a0
    800065aa:	c3c4                	sw	s1,4(a5)
}
    800065ac:	60e2                	ld	ra,24(sp)
    800065ae:	6442                	ld	s0,16(sp)
    800065b0:	64a2                	ld	s1,8(sp)
    800065b2:	6105                	addi	sp,sp,32
    800065b4:	8082                	ret

00000000800065b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    800065b6:	1141                	addi	sp,sp,-16
    800065b8:	e406                	sd	ra,8(sp)
    800065ba:	e022                	sd	s0,0(sp)
    800065bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800065be:	479d                	li	a5,7
    800065c0:	06b7c963          	blt	a5,a1,80006632 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    800065c4:	00151793          	slli	a5,a0,0x1
    800065c8:	97aa                	add	a5,a5,a0
    800065ca:	00c79713          	slli	a4,a5,0xc
    800065ce:	00022797          	auipc	a5,0x22
    800065d2:	a3278793          	addi	a5,a5,-1486 # 80028000 <disk>
    800065d6:	97ba                	add	a5,a5,a4
    800065d8:	97ae                	add	a5,a5,a1
    800065da:	6709                	lui	a4,0x2
    800065dc:	97ba                	add	a5,a5,a4
    800065de:	0187c783          	lbu	a5,24(a5)
    800065e2:	e3a5                	bnez	a5,80006642 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    800065e4:	00022817          	auipc	a6,0x22
    800065e8:	a1c80813          	addi	a6,a6,-1508 # 80028000 <disk>
    800065ec:	00151693          	slli	a3,a0,0x1
    800065f0:	00a68733          	add	a4,a3,a0
    800065f4:	0732                	slli	a4,a4,0xc
    800065f6:	00e807b3          	add	a5,a6,a4
    800065fa:	6709                	lui	a4,0x2
    800065fc:	00f70633          	add	a2,a4,a5
    80006600:	6210                	ld	a2,0(a2)
    80006602:	00459893          	slli	a7,a1,0x4
    80006606:	9646                	add	a2,a2,a7
    80006608:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    8000660c:	97ae                	add	a5,a5,a1
    8000660e:	97ba                	add	a5,a5,a4
    80006610:	4605                	li	a2,1
    80006612:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80006616:	96aa                	add	a3,a3,a0
    80006618:	06b2                	slli	a3,a3,0xc
    8000661a:	0761                	addi	a4,a4,24
    8000661c:	96ba                	add	a3,a3,a4
    8000661e:	00d80533          	add	a0,a6,a3
    80006622:	ffffc097          	auipc	ra,0xffffc
    80006626:	3e0080e7          	jalr	992(ra) # 80002a02 <wakeup>
}
    8000662a:	60a2                	ld	ra,8(sp)
    8000662c:	6402                	ld	s0,0(sp)
    8000662e:	0141                	addi	sp,sp,16
    80006630:	8082                	ret
    panic("virtio_disk_intr 1");
    80006632:	00002517          	auipc	a0,0x2
    80006636:	6a650513          	addi	a0,a0,1702 # 80008cd8 <userret+0xc48>
    8000663a:	ffffa097          	auipc	ra,0xffffa
    8000663e:	11c080e7          	jalr	284(ra) # 80000756 <panic>
    panic("virtio_disk_intr 2");
    80006642:	00002517          	auipc	a0,0x2
    80006646:	6ae50513          	addi	a0,a0,1710 # 80008cf0 <userret+0xc60>
    8000664a:	ffffa097          	auipc	ra,0xffffa
    8000664e:	10c080e7          	jalr	268(ra) # 80000756 <panic>

0000000080006652 <virtio_disk_init>:
  __sync_synchronize();
    80006652:	0ff0000f          	fence
  if(disk[n].init)
    80006656:	00151793          	slli	a5,a0,0x1
    8000665a:	97aa                	add	a5,a5,a0
    8000665c:	07b2                	slli	a5,a5,0xc
    8000665e:	00022717          	auipc	a4,0x22
    80006662:	9a270713          	addi	a4,a4,-1630 # 80028000 <disk>
    80006666:	973e                	add	a4,a4,a5
    80006668:	6789                	lui	a5,0x2
    8000666a:	97ba                	add	a5,a5,a4
    8000666c:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80006670:	c391                	beqz	a5,80006674 <virtio_disk_init+0x22>
    80006672:	8082                	ret
{
    80006674:	7139                	addi	sp,sp,-64
    80006676:	fc06                	sd	ra,56(sp)
    80006678:	f822                	sd	s0,48(sp)
    8000667a:	f426                	sd	s1,40(sp)
    8000667c:	f04a                	sd	s2,32(sp)
    8000667e:	ec4e                	sd	s3,24(sp)
    80006680:	e852                	sd	s4,16(sp)
    80006682:	e456                	sd	s5,8(sp)
    80006684:	0080                	addi	s0,sp,64
    80006686:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80006688:	85aa                	mv	a1,a0
    8000668a:	00002517          	auipc	a0,0x2
    8000668e:	67e50513          	addi	a0,a0,1662 # 80008d08 <userret+0xc78>
    80006692:	ffffa097          	auipc	ra,0xffffa
    80006696:	2da080e7          	jalr	730(ra) # 8000096c <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    8000669a:	00149993          	slli	s3,s1,0x1
    8000669e:	99a6                	add	s3,s3,s1
    800066a0:	09b2                	slli	s3,s3,0xc
    800066a2:	6789                	lui	a5,0x2
    800066a4:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    800066a8:	97ce                	add	a5,a5,s3
    800066aa:	00002597          	auipc	a1,0x2
    800066ae:	67658593          	addi	a1,a1,1654 # 80008d20 <userret+0xc90>
    800066b2:	00022517          	auipc	a0,0x22
    800066b6:	94e50513          	addi	a0,a0,-1714 # 80028000 <disk>
    800066ba:	953e                	add	a0,a0,a5
    800066bc:	ffffa097          	auipc	ra,0xffffa
    800066c0:	462080e7          	jalr	1122(ra) # 80000b1e <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800066c4:	0014891b          	addiw	s2,s1,1
    800066c8:	00c9191b          	slliw	s2,s2,0xc
    800066cc:	100007b7          	lui	a5,0x10000
    800066d0:	97ca                	add	a5,a5,s2
    800066d2:	4398                	lw	a4,0(a5)
    800066d4:	2701                	sext.w	a4,a4
    800066d6:	747277b7          	lui	a5,0x74727
    800066da:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800066de:	12f71863          	bne	a4,a5,8000680e <virtio_disk_init+0x1bc>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800066e2:	100007b7          	lui	a5,0x10000
    800066e6:	0791                	addi	a5,a5,4
    800066e8:	97ca                	add	a5,a5,s2
    800066ea:	439c                	lw	a5,0(a5)
    800066ec:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800066ee:	4705                	li	a4,1
    800066f0:	10e79f63          	bne	a5,a4,8000680e <virtio_disk_init+0x1bc>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066f4:	100007b7          	lui	a5,0x10000
    800066f8:	07a1                	addi	a5,a5,8
    800066fa:	97ca                	add	a5,a5,s2
    800066fc:	439c                	lw	a5,0(a5)
    800066fe:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006700:	4709                	li	a4,2
    80006702:	10e79663          	bne	a5,a4,8000680e <virtio_disk_init+0x1bc>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006706:	100007b7          	lui	a5,0x10000
    8000670a:	07b1                	addi	a5,a5,12
    8000670c:	97ca                	add	a5,a5,s2
    8000670e:	4398                	lw	a4,0(a5)
    80006710:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006712:	554d47b7          	lui	a5,0x554d4
    80006716:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000671a:	0ef71a63          	bne	a4,a5,8000680e <virtio_disk_init+0x1bc>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000671e:	100007b7          	lui	a5,0x10000
    80006722:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80006726:	96ca                	add	a3,a3,s2
    80006728:	4705                	li	a4,1
    8000672a:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000672c:	470d                	li	a4,3
    8000672e:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80006730:	01078713          	addi	a4,a5,16
    80006734:	974a                	add	a4,a4,s2
    80006736:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006738:	02078613          	addi	a2,a5,32
    8000673c:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000673e:	c7ffe737          	lui	a4,0xc7ffe
    80006742:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd06b3>
    80006746:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006748:	2701                	sext.w	a4,a4
    8000674a:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000674c:	472d                	li	a4,11
    8000674e:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006750:	473d                	li	a4,15
    80006752:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006754:	02878713          	addi	a4,a5,40
    80006758:	974a                	add	a4,a4,s2
    8000675a:	6685                	lui	a3,0x1
    8000675c:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000675e:	03078713          	addi	a4,a5,48
    80006762:	974a                	add	a4,a4,s2
    80006764:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006768:	03478793          	addi	a5,a5,52
    8000676c:	97ca                	add	a5,a5,s2
    8000676e:	439c                	lw	a5,0(a5)
    80006770:	2781                	sext.w	a5,a5
  if(max == 0)
    80006772:	c7d5                	beqz	a5,8000681e <virtio_disk_init+0x1cc>
  if(max < NUM)
    80006774:	471d                	li	a4,7
    80006776:	0af77c63          	bgeu	a4,a5,8000682e <virtio_disk_init+0x1dc>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000677a:	10000ab7          	lui	s5,0x10000
    8000677e:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006782:	97ca                	add	a5,a5,s2
    80006784:	4721                	li	a4,8
    80006786:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006788:	00022a17          	auipc	s4,0x22
    8000678c:	878a0a13          	addi	s4,s4,-1928 # 80028000 <disk>
    80006790:	99d2                	add	s3,s3,s4
    80006792:	6609                	lui	a2,0x2
    80006794:	4581                	li	a1,0
    80006796:	854e                	mv	a0,s3
    80006798:	ffffb097          	auipc	ra,0xffffb
    8000679c:	93c080e7          	jalr	-1732(ra) # 800010d4 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    800067a0:	040a8a93          	addi	s5,s5,64
    800067a4:	9956                	add	s2,s2,s5
    800067a6:	00c9d793          	srli	a5,s3,0xc
    800067aa:	2781                	sext.w	a5,a5
    800067ac:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    800067b0:	00149513          	slli	a0,s1,0x1
    800067b4:	009507b3          	add	a5,a0,s1
    800067b8:	07b2                	slli	a5,a5,0xc
    800067ba:	97d2                	add	a5,a5,s4
    800067bc:	6689                	lui	a3,0x2
    800067be:	97b6                	add	a5,a5,a3
    800067c0:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    800067c4:	08098713          	addi	a4,s3,128
    800067c8:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    800067ca:	6705                	lui	a4,0x1
    800067cc:	99ba                	add	s3,s3,a4
    800067ce:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    800067d2:	4705                	li	a4,1
    800067d4:	00e78c23          	sb	a4,24(a5)
    800067d8:	00e78ca3          	sb	a4,25(a5)
    800067dc:	00e78d23          	sb	a4,26(a5)
    800067e0:	00e78da3          	sb	a4,27(a5)
    800067e4:	00e78e23          	sb	a4,28(a5)
    800067e8:	00e78ea3          	sb	a4,29(a5)
    800067ec:	00e78f23          	sb	a4,30(a5)
    800067f0:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    800067f4:	853e                	mv	a0,a5
    800067f6:	4785                	li	a5,1
    800067f8:	0af52423          	sw	a5,168(a0)
}
    800067fc:	70e2                	ld	ra,56(sp)
    800067fe:	7442                	ld	s0,48(sp)
    80006800:	74a2                	ld	s1,40(sp)
    80006802:	7902                	ld	s2,32(sp)
    80006804:	69e2                	ld	s3,24(sp)
    80006806:	6a42                	ld	s4,16(sp)
    80006808:	6aa2                	ld	s5,8(sp)
    8000680a:	6121                	addi	sp,sp,64
    8000680c:	8082                	ret
    panic("could not find virtio disk");
    8000680e:	00002517          	auipc	a0,0x2
    80006812:	52250513          	addi	a0,a0,1314 # 80008d30 <userret+0xca0>
    80006816:	ffffa097          	auipc	ra,0xffffa
    8000681a:	f40080e7          	jalr	-192(ra) # 80000756 <panic>
    panic("virtio disk has no queue 0");
    8000681e:	00002517          	auipc	a0,0x2
    80006822:	53250513          	addi	a0,a0,1330 # 80008d50 <userret+0xcc0>
    80006826:	ffffa097          	auipc	ra,0xffffa
    8000682a:	f30080e7          	jalr	-208(ra) # 80000756 <panic>
    panic("virtio disk max queue too short");
    8000682e:	00002517          	auipc	a0,0x2
    80006832:	54250513          	addi	a0,a0,1346 # 80008d70 <userret+0xce0>
    80006836:	ffffa097          	auipc	ra,0xffffa
    8000683a:	f20080e7          	jalr	-224(ra) # 80000756 <panic>

000000008000683e <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    8000683e:	7135                	addi	sp,sp,-160
    80006840:	ed06                	sd	ra,152(sp)
    80006842:	e922                	sd	s0,144(sp)
    80006844:	e526                	sd	s1,136(sp)
    80006846:	e14a                	sd	s2,128(sp)
    80006848:	fcce                	sd	s3,120(sp)
    8000684a:	f8d2                	sd	s4,112(sp)
    8000684c:	f4d6                	sd	s5,104(sp)
    8000684e:	f0da                	sd	s6,96(sp)
    80006850:	ecde                	sd	s7,88(sp)
    80006852:	e8e2                	sd	s8,80(sp)
    80006854:	e4e6                	sd	s9,72(sp)
    80006856:	e0ea                	sd	s10,64(sp)
    80006858:	fc6e                	sd	s11,56(sp)
    8000685a:	1100                	addi	s0,sp,160
    8000685c:	892a                	mv	s2,a0
    8000685e:	89ae                	mv	s3,a1
    80006860:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80006862:	45dc                	lw	a5,12(a1)
    80006864:	0017979b          	slliw	a5,a5,0x1
    80006868:	1782                	slli	a5,a5,0x20
    8000686a:	9381                	srli	a5,a5,0x20
    8000686c:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    80006870:	00151493          	slli	s1,a0,0x1
    80006874:	94aa                	add	s1,s1,a0
    80006876:	04b2                	slli	s1,s1,0xc
    80006878:	6a89                	lui	s5,0x2
    8000687a:	0b0a8a13          	addi	s4,s5,176 # 20b0 <_entry-0x7fffdf50>
    8000687e:	9a26                	add	s4,s4,s1
    80006880:	00021b97          	auipc	s7,0x21
    80006884:	780b8b93          	addi	s7,s7,1920 # 80028000 <disk>
    80006888:	9a5e                	add	s4,s4,s7
    8000688a:	8552                	mv	a0,s4
    8000688c:	ffffa097          	auipc	ra,0xffffa
    80006890:	3fc080e7          	jalr	1020(ra) # 80000c88 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006894:	0ae1                	addi	s5,s5,24
    80006896:	94d6                	add	s1,s1,s5
    80006898:	01748ab3          	add	s5,s1,s7
    8000689c:	8d56                	mv	s10,s5
  for(int i = 0; i < 3; i++){
    8000689e:	4b81                	li	s7,0
  for(int i = 0; i < NUM; i++){
    800068a0:	4ca1                	li	s9,8
      disk[n].free[i] = 0;
    800068a2:	00191b13          	slli	s6,s2,0x1
    800068a6:	9b4a                	add	s6,s6,s2
    800068a8:	00cb1793          	slli	a5,s6,0xc
    800068ac:	00021b17          	auipc	s6,0x21
    800068b0:	754b0b13          	addi	s6,s6,1876 # 80028000 <disk>
    800068b4:	9b3e                	add	s6,s6,a5
  for(int i = 0; i < NUM; i++){
    800068b6:	8c5e                	mv	s8,s7
    800068b8:	a8ad                	j	80006932 <virtio_disk_rw+0xf4>
      disk[n].free[i] = 0;
    800068ba:	00fb06b3          	add	a3,s6,a5
    800068be:	96aa                	add	a3,a3,a0
    800068c0:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    800068c4:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800068c6:	0207c363          	bltz	a5,800068ec <virtio_disk_rw+0xae>
  for(int i = 0; i < 3; i++){
    800068ca:	2485                	addiw	s1,s1,1
    800068cc:	0711                	addi	a4,a4,4
    800068ce:	26b48f63          	beq	s1,a1,80006b4c <virtio_disk_rw+0x30e>
    idx[i] = alloc_desc(n);
    800068d2:	863a                	mv	a2,a4
    800068d4:	86ea                	mv	a3,s10
  for(int i = 0; i < NUM; i++){
    800068d6:	87e2                	mv	a5,s8
    if(disk[n].free[i]){
    800068d8:	0006c803          	lbu	a6,0(a3)
    800068dc:	fc081fe3          	bnez	a6,800068ba <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    800068e0:	2785                	addiw	a5,a5,1
    800068e2:	0685                	addi	a3,a3,1
    800068e4:	ff979ae3          	bne	a5,s9,800068d8 <virtio_disk_rw+0x9a>
    idx[i] = alloc_desc(n);
    800068e8:	57fd                	li	a5,-1
    800068ea:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800068ec:	02905d63          	blez	s1,80006926 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800068f0:	f8042583          	lw	a1,-128(s0)
    800068f4:	854a                	mv	a0,s2
    800068f6:	00000097          	auipc	ra,0x0
    800068fa:	cc0080e7          	jalr	-832(ra) # 800065b6 <free_desc>
      for(int j = 0; j < i; j++)
    800068fe:	4785                	li	a5,1
    80006900:	0297d363          	bge	a5,s1,80006926 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006904:	f8442583          	lw	a1,-124(s0)
    80006908:	854a                	mv	a0,s2
    8000690a:	00000097          	auipc	ra,0x0
    8000690e:	cac080e7          	jalr	-852(ra) # 800065b6 <free_desc>
      for(int j = 0; j < i; j++)
    80006912:	4789                	li	a5,2
    80006914:	0097d963          	bge	a5,s1,80006926 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006918:	f8842583          	lw	a1,-120(s0)
    8000691c:	854a                	mv	a0,s2
    8000691e:	00000097          	auipc	ra,0x0
    80006922:	c98080e7          	jalr	-872(ra) # 800065b6 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006926:	85d2                	mv	a1,s4
    80006928:	8556                	mv	a0,s5
    8000692a:	ffffc097          	auipc	ra,0xffffc
    8000692e:	f52080e7          	jalr	-174(ra) # 8000287c <sleep>
  for(int i = 0; i < 3; i++){
    80006932:	f8040713          	addi	a4,s0,-128
    80006936:	84de                	mv	s1,s7
      disk[n].free[i] = 0;
    80006938:	6509                	lui	a0,0x2
  for(int i = 0; i < 3; i++){
    8000693a:	458d                	li	a1,3
    8000693c:	bf59                	j	800068d2 <virtio_disk_rw+0x94>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    8000693e:	4785                	li	a5,1
    80006940:	f6f42823          	sw	a5,-144(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    80006944:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006948:	f6843783          	ld	a5,-152(s0)
    8000694c:	f6f43c23          	sd	a5,-136(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006950:	f8042483          	lw	s1,-128(s0)
    80006954:	00449b13          	slli	s6,s1,0x4
    80006958:	00191793          	slli	a5,s2,0x1
    8000695c:	97ca                	add	a5,a5,s2
    8000695e:	07b2                	slli	a5,a5,0xc
    80006960:	00021a97          	auipc	s5,0x21
    80006964:	6a0a8a93          	addi	s5,s5,1696 # 80028000 <disk>
    80006968:	97d6                	add	a5,a5,s5
    8000696a:	6a89                	lui	s5,0x2
    8000696c:	9abe                	add	s5,s5,a5
    8000696e:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    80006972:	9bda                	add	s7,s7,s6
    80006974:	f7040513          	addi	a0,s0,-144
    80006978:	ffffb097          	auipc	ra,0xffffb
    8000697c:	c86080e7          	jalr	-890(ra) # 800015fe <kvmpa>
    80006980:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006984:	000ab783          	ld	a5,0(s5)
    80006988:	97da                	add	a5,a5,s6
    8000698a:	4741                	li	a4,16
    8000698c:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000698e:	000ab783          	ld	a5,0(s5)
    80006992:	97da                	add	a5,a5,s6
    80006994:	4705                	li	a4,1
    80006996:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    8000699a:	f8442683          	lw	a3,-124(s0)
    8000699e:	000ab783          	ld	a5,0(s5)
    800069a2:	9b3e                	add	s6,s6,a5
    800069a4:	00db1723          	sh	a3,14(s6)

  disk[n].desc[idx[1]].addr = (uint64) b->data;
    800069a8:	0692                	slli	a3,a3,0x4
    800069aa:	000ab783          	ld	a5,0(s5)
    800069ae:	97b6                	add	a5,a5,a3
    800069b0:	07098713          	addi	a4,s3,112
    800069b4:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    800069b6:	000ab783          	ld	a5,0(s5)
    800069ba:	97b6                	add	a5,a5,a3
    800069bc:	40000713          	li	a4,1024
    800069c0:	c798                	sw	a4,8(a5)
  if(write)
    800069c2:	140d8063          	beqz	s11,80006b02 <virtio_disk_rw+0x2c4>
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    800069c6:	000ab783          	ld	a5,0(s5)
    800069ca:	97b6                	add	a5,a5,a3
    800069cc:	00079623          	sh	zero,12(a5)
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800069d0:	00021517          	auipc	a0,0x21
    800069d4:	63050513          	addi	a0,a0,1584 # 80028000 <disk>
    800069d8:	00191793          	slli	a5,s2,0x1
    800069dc:	01278733          	add	a4,a5,s2
    800069e0:	0732                	slli	a4,a4,0xc
    800069e2:	972a                	add	a4,a4,a0
    800069e4:	6609                	lui	a2,0x2
    800069e6:	9732                	add	a4,a4,a2
    800069e8:	630c                	ld	a1,0(a4)
    800069ea:	95b6                	add	a1,a1,a3
    800069ec:	00c5d603          	lhu	a2,12(a1)
    800069f0:	00166613          	ori	a2,a2,1
    800069f4:	00c59623          	sh	a2,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    800069f8:	f8842603          	lw	a2,-120(s0)
    800069fc:	630c                	ld	a1,0(a4)
    800069fe:	96ae                	add	a3,a3,a1
    80006a00:	00c69723          	sh	a2,14(a3)

  disk[n].info[idx[0]].status = 0;
    80006a04:	97ca                	add	a5,a5,s2
    80006a06:	07a2                	slli	a5,a5,0x8
    80006a08:	97a6                	add	a5,a5,s1
    80006a0a:	20078793          	addi	a5,a5,512
    80006a0e:	0792                	slli	a5,a5,0x4
    80006a10:	97aa                	add	a5,a5,a0
    80006a12:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006a16:	00461693          	slli	a3,a2,0x4
    80006a1a:	00073803          	ld	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80006a1e:	9836                	add	a6,a6,a3
    80006a20:	20348613          	addi	a2,s1,515
    80006a24:	00191593          	slli	a1,s2,0x1
    80006a28:	95ca                	add	a1,a1,s2
    80006a2a:	05a2                	slli	a1,a1,0x8
    80006a2c:	962e                	add	a2,a2,a1
    80006a2e:	0612                	slli	a2,a2,0x4
    80006a30:	962a                	add	a2,a2,a0
    80006a32:	00c83023          	sd	a2,0(a6)
  disk[n].desc[idx[2]].len = 1;
    80006a36:	6310                	ld	a2,0(a4)
    80006a38:	9636                	add	a2,a2,a3
    80006a3a:	4585                	li	a1,1
    80006a3c:	c60c                	sw	a1,8(a2)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006a3e:	6310                	ld	a2,0(a4)
    80006a40:	9636                	add	a2,a2,a3
    80006a42:	4509                	li	a0,2
    80006a44:	00a61623          	sh	a0,12(a2) # 200c <_entry-0x7fffdff4>
  disk[n].desc[idx[2]].next = 0;
    80006a48:	6310                	ld	a2,0(a4)
    80006a4a:	96b2                	add	a3,a3,a2
    80006a4c:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006a50:	00b9a223          	sw	a1,4(s3)
  disk[n].info[idx[0]].b = b;
    80006a54:	0337b423          	sd	s3,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    80006a58:	6714                	ld	a3,8(a4)
    80006a5a:	0026d783          	lhu	a5,2(a3)
    80006a5e:	8b9d                	andi	a5,a5,7
    80006a60:	2789                	addiw	a5,a5,2
    80006a62:	0786                	slli	a5,a5,0x1
    80006a64:	97b6                	add	a5,a5,a3
    80006a66:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80006a6a:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006a6e:	6718                	ld	a4,8(a4)
    80006a70:	00275783          	lhu	a5,2(a4)
    80006a74:	2785                	addiw	a5,a5,1
    80006a76:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006a7a:	0019079b          	addiw	a5,s2,1
    80006a7e:	00c7979b          	slliw	a5,a5,0xc
    80006a82:	10000737          	lui	a4,0x10000
    80006a86:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    80006a8a:	97ba                	add	a5,a5,a4
    80006a8c:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006a90:	0049a703          	lw	a4,4(s3)
    80006a94:	4785                	li	a5,1
    80006a96:	00f71d63          	bne	a4,a5,80006ab0 <virtio_disk_rw+0x272>
    80006a9a:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    80006a9c:	85d2                	mv	a1,s4
    80006a9e:	854e                	mv	a0,s3
    80006aa0:	ffffc097          	auipc	ra,0xffffc
    80006aa4:	ddc080e7          	jalr	-548(ra) # 8000287c <sleep>
  while(b->disk == 1) {
    80006aa8:	0049a783          	lw	a5,4(s3)
    80006aac:	fe9788e3          	beq	a5,s1,80006a9c <virtio_disk_rw+0x25e>
  }

  disk[n].info[idx[0]].b = 0;
    80006ab0:	f8042483          	lw	s1,-128(s0)
    80006ab4:	00191793          	slli	a5,s2,0x1
    80006ab8:	97ca                	add	a5,a5,s2
    80006aba:	07a2                	slli	a5,a5,0x8
    80006abc:	97a6                	add	a5,a5,s1
    80006abe:	20078793          	addi	a5,a5,512
    80006ac2:	0792                	slli	a5,a5,0x4
    80006ac4:	00021717          	auipc	a4,0x21
    80006ac8:	53c70713          	addi	a4,a4,1340 # 80028000 <disk>
    80006acc:	97ba                	add	a5,a5,a4
    80006ace:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006ad2:	00191793          	slli	a5,s2,0x1
    80006ad6:	97ca                	add	a5,a5,s2
    80006ad8:	07b2                	slli	a5,a5,0xc
    80006ada:	97ba                	add	a5,a5,a4
    80006adc:	6989                	lui	s3,0x2
    80006ade:	99be                	add	s3,s3,a5
    free_desc(n, i);
    80006ae0:	85a6                	mv	a1,s1
    80006ae2:	854a                	mv	a0,s2
    80006ae4:	00000097          	auipc	ra,0x0
    80006ae8:	ad2080e7          	jalr	-1326(ra) # 800065b6 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006aec:	0492                	slli	s1,s1,0x4
    80006aee:	0009b783          	ld	a5,0(s3) # 2000 <_entry-0x7fffe000>
    80006af2:	94be                	add	s1,s1,a5
    80006af4:	00c4d783          	lhu	a5,12(s1)
    80006af8:	8b85                	andi	a5,a5,1
    80006afa:	c78d                	beqz	a5,80006b24 <virtio_disk_rw+0x2e6>
      i = disk[n].desc[i].next;
    80006afc:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006b00:	b7c5                	j	80006ae0 <virtio_disk_rw+0x2a2>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006b02:	00191793          	slli	a5,s2,0x1
    80006b06:	97ca                	add	a5,a5,s2
    80006b08:	07b2                	slli	a5,a5,0xc
    80006b0a:	00021717          	auipc	a4,0x21
    80006b0e:	4f670713          	addi	a4,a4,1270 # 80028000 <disk>
    80006b12:	973e                	add	a4,a4,a5
    80006b14:	6789                	lui	a5,0x2
    80006b16:	97ba                	add	a5,a5,a4
    80006b18:	639c                	ld	a5,0(a5)
    80006b1a:	97b6                	add	a5,a5,a3
    80006b1c:	4709                	li	a4,2
    80006b1e:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006b22:	b57d                	j	800069d0 <virtio_disk_rw+0x192>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006b24:	8552                	mv	a0,s4
    80006b26:	ffffa097          	auipc	ra,0xffffa
    80006b2a:	3ae080e7          	jalr	942(ra) # 80000ed4 <release>
}
    80006b2e:	60ea                	ld	ra,152(sp)
    80006b30:	644a                	ld	s0,144(sp)
    80006b32:	64aa                	ld	s1,136(sp)
    80006b34:	690a                	ld	s2,128(sp)
    80006b36:	79e6                	ld	s3,120(sp)
    80006b38:	7a46                	ld	s4,112(sp)
    80006b3a:	7aa6                	ld	s5,104(sp)
    80006b3c:	7b06                	ld	s6,96(sp)
    80006b3e:	6be6                	ld	s7,88(sp)
    80006b40:	6c46                	ld	s8,80(sp)
    80006b42:	6ca6                	ld	s9,72(sp)
    80006b44:	6d06                	ld	s10,64(sp)
    80006b46:	7de2                	ld	s11,56(sp)
    80006b48:	610d                	addi	sp,sp,160
    80006b4a:	8082                	ret
  if(write)
    80006b4c:	de0d99e3          	bnez	s11,8000693e <virtio_disk_rw+0x100>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006b50:	f6042823          	sw	zero,-144(s0)
    80006b54:	bbc5                	j	80006944 <virtio_disk_rw+0x106>

0000000080006b56 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006b56:	7139                	addi	sp,sp,-64
    80006b58:	fc06                	sd	ra,56(sp)
    80006b5a:	f822                	sd	s0,48(sp)
    80006b5c:	f426                	sd	s1,40(sp)
    80006b5e:	f04a                	sd	s2,32(sp)
    80006b60:	ec4e                	sd	s3,24(sp)
    80006b62:	e852                	sd	s4,16(sp)
    80006b64:	e456                	sd	s5,8(sp)
    80006b66:	0080                	addi	s0,sp,64
    80006b68:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006b6a:	00151913          	slli	s2,a0,0x1
    80006b6e:	00a90a33          	add	s4,s2,a0
    80006b72:	0a32                	slli	s4,s4,0xc
    80006b74:	6989                	lui	s3,0x2
    80006b76:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006b7a:	9a3e                	add	s4,s4,a5
    80006b7c:	00021a97          	auipc	s5,0x21
    80006b80:	484a8a93          	addi	s5,s5,1156 # 80028000 <disk>
    80006b84:	9a56                	add	s4,s4,s5
    80006b86:	8552                	mv	a0,s4
    80006b88:	ffffa097          	auipc	ra,0xffffa
    80006b8c:	100080e7          	jalr	256(ra) # 80000c88 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006b90:	9926                	add	s2,s2,s1
    80006b92:	0932                	slli	s2,s2,0xc
    80006b94:	9956                	add	s2,s2,s5
    80006b96:	99ca                	add	s3,s3,s2
    80006b98:	0209d783          	lhu	a5,32(s3)
    80006b9c:	0109b703          	ld	a4,16(s3)
    80006ba0:	00275683          	lhu	a3,2(a4)
    80006ba4:	8ebd                	xor	a3,a3,a5
    80006ba6:	8a9d                	andi	a3,a3,7
    80006ba8:	c2a5                	beqz	a3,80006c08 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    80006baa:	8956                	mv	s2,s5
    80006bac:	00149693          	slli	a3,s1,0x1
    80006bb0:	96a6                	add	a3,a3,s1
    80006bb2:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006bb6:	06b2                	slli	a3,a3,0xc
    80006bb8:	96d6                	add	a3,a3,s5
    80006bba:	6489                	lui	s1,0x2
    80006bbc:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006bbe:	078e                	slli	a5,a5,0x3
    80006bc0:	97ba                	add	a5,a5,a4
    80006bc2:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006bc4:	00f98733          	add	a4,s3,a5
    80006bc8:	20070713          	addi	a4,a4,512
    80006bcc:	0712                	slli	a4,a4,0x4
    80006bce:	974a                	add	a4,a4,s2
    80006bd0:	03074703          	lbu	a4,48(a4)
    80006bd4:	eb21                	bnez	a4,80006c24 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006bd6:	97ce                	add	a5,a5,s3
    80006bd8:	20078793          	addi	a5,a5,512
    80006bdc:	0792                	slli	a5,a5,0x4
    80006bde:	97ca                	add	a5,a5,s2
    80006be0:	7798                	ld	a4,40(a5)
    80006be2:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006be6:	7788                	ld	a0,40(a5)
    80006be8:	ffffc097          	auipc	ra,0xffffc
    80006bec:	e1a080e7          	jalr	-486(ra) # 80002a02 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006bf0:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006bf4:	2785                	addiw	a5,a5,1
    80006bf6:	8b9d                	andi	a5,a5,7
    80006bf8:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006bfc:	6898                	ld	a4,16(s1)
    80006bfe:	00275683          	lhu	a3,2(a4)
    80006c02:	8a9d                	andi	a3,a3,7
    80006c04:	faf69de3          	bne	a3,a5,80006bbe <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006c08:	8552                	mv	a0,s4
    80006c0a:	ffffa097          	auipc	ra,0xffffa
    80006c0e:	2ca080e7          	jalr	714(ra) # 80000ed4 <release>
}
    80006c12:	70e2                	ld	ra,56(sp)
    80006c14:	7442                	ld	s0,48(sp)
    80006c16:	74a2                	ld	s1,40(sp)
    80006c18:	7902                	ld	s2,32(sp)
    80006c1a:	69e2                	ld	s3,24(sp)
    80006c1c:	6a42                	ld	s4,16(sp)
    80006c1e:	6aa2                	ld	s5,8(sp)
    80006c20:	6121                	addi	sp,sp,64
    80006c22:	8082                	ret
      panic("virtio_disk_intr status");
    80006c24:	00002517          	auipc	a0,0x2
    80006c28:	16c50513          	addi	a0,a0,364 # 80008d90 <userret+0xd00>
    80006c2c:	ffffa097          	auipc	ra,0xffffa
    80006c30:	b2a080e7          	jalr	-1238(ra) # 80000756 <panic>

0000000080006c34 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006c34:	1141                	addi	sp,sp,-16
    80006c36:	e422                	sd	s0,8(sp)
    80006c38:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80006c3a:	41f5d79b          	sraiw	a5,a1,0x1f
    80006c3e:	01d7d79b          	srliw	a5,a5,0x1d
    80006c42:	9dbd                	addw	a1,a1,a5
    80006c44:	0075f713          	andi	a4,a1,7
    80006c48:	9f1d                	subw	a4,a4,a5
    80006c4a:	4785                	li	a5,1
    80006c4c:	00e797bb          	sllw	a5,a5,a4
    80006c50:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80006c54:	4035d59b          	sraiw	a1,a1,0x3
    80006c58:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006c5a:	0005c503          	lbu	a0,0(a1)
    80006c5e:	8d7d                	and	a0,a0,a5
    80006c60:	8d1d                	sub	a0,a0,a5
}
    80006c62:	00153513          	seqz	a0,a0
    80006c66:	6422                	ld	s0,8(sp)
    80006c68:	0141                	addi	sp,sp,16
    80006c6a:	8082                	ret

0000000080006c6c <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006c6c:	1141                	addi	sp,sp,-16
    80006c6e:	e422                	sd	s0,8(sp)
    80006c70:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006c72:	41f5d79b          	sraiw	a5,a1,0x1f
    80006c76:	01d7d79b          	srliw	a5,a5,0x1d
    80006c7a:	9dbd                	addw	a1,a1,a5
    80006c7c:	4035d71b          	sraiw	a4,a1,0x3
    80006c80:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006c82:	899d                	andi	a1,a1,7
    80006c84:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    80006c86:	4785                	li	a5,1
    80006c88:	00b795bb          	sllw	a1,a5,a1
    80006c8c:	00054783          	lbu	a5,0(a0)
    80006c90:	8ddd                	or	a1,a1,a5
    80006c92:	00b50023          	sb	a1,0(a0)
}
    80006c96:	6422                	ld	s0,8(sp)
    80006c98:	0141                	addi	sp,sp,16
    80006c9a:	8082                	ret

0000000080006c9c <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006c9c:	1141                	addi	sp,sp,-16
    80006c9e:	e422                	sd	s0,8(sp)
    80006ca0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006ca2:	41f5d79b          	sraiw	a5,a1,0x1f
    80006ca6:	01d7d79b          	srliw	a5,a5,0x1d
    80006caa:	9dbd                	addw	a1,a1,a5
    80006cac:	4035d71b          	sraiw	a4,a1,0x3
    80006cb0:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006cb2:	899d                	andi	a1,a1,7
    80006cb4:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    80006cb6:	4785                	li	a5,1
    80006cb8:	00b795bb          	sllw	a1,a5,a1
    80006cbc:	fff5c593          	not	a1,a1
    80006cc0:	00054783          	lbu	a5,0(a0)
    80006cc4:	8dfd                	and	a1,a1,a5
    80006cc6:	00b50023          	sb	a1,0(a0)
}
    80006cca:	6422                	ld	s0,8(sp)
    80006ccc:	0141                	addi	sp,sp,16
    80006cce:	8082                	ret

0000000080006cd0 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006cd0:	715d                	addi	sp,sp,-80
    80006cd2:	e486                	sd	ra,72(sp)
    80006cd4:	e0a2                	sd	s0,64(sp)
    80006cd6:	fc26                	sd	s1,56(sp)
    80006cd8:	f84a                	sd	s2,48(sp)
    80006cda:	f44e                	sd	s3,40(sp)
    80006cdc:	f052                	sd	s4,32(sp)
    80006cde:	ec56                	sd	s5,24(sp)
    80006ce0:	e85a                	sd	s6,16(sp)
    80006ce2:	e45e                	sd	s7,8(sp)
    80006ce4:	0880                	addi	s0,sp,80
    80006ce6:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006ce8:	08b05b63          	blez	a1,80006d7e <bd_print_vector+0xae>
    80006cec:	89aa                	mv	s3,a0
    80006cee:	4481                	li	s1,0
  lb = 0;
    80006cf0:	4a81                	li	s5,0
  last = 1;
    80006cf2:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006cf4:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006cf6:	00002b97          	auipc	s7,0x2
    80006cfa:	0b2b8b93          	addi	s7,s7,178 # 80008da8 <userret+0xd18>
    80006cfe:	a01d                	j	80006d24 <bd_print_vector+0x54>
    80006d00:	8626                	mv	a2,s1
    80006d02:	85d6                	mv	a1,s5
    80006d04:	855e                	mv	a0,s7
    80006d06:	ffffa097          	auipc	ra,0xffffa
    80006d0a:	c66080e7          	jalr	-922(ra) # 8000096c <printf>
    lb = b;
    last = bit_isset(vector, b);
    80006d0e:	85a6                	mv	a1,s1
    80006d10:	854e                	mv	a0,s3
    80006d12:	00000097          	auipc	ra,0x0
    80006d16:	f22080e7          	jalr	-222(ra) # 80006c34 <bit_isset>
    80006d1a:	892a                	mv	s2,a0
    80006d1c:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006d1e:	2485                	addiw	s1,s1,1
    80006d20:	009a0d63          	beq	s4,s1,80006d3a <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006d24:	85a6                	mv	a1,s1
    80006d26:	854e                	mv	a0,s3
    80006d28:	00000097          	auipc	ra,0x0
    80006d2c:	f0c080e7          	jalr	-244(ra) # 80006c34 <bit_isset>
    80006d30:	ff2507e3          	beq	a0,s2,80006d1e <bd_print_vector+0x4e>
    if(last == 1)
    80006d34:	fd691de3          	bne	s2,s6,80006d0e <bd_print_vector+0x3e>
    80006d38:	b7e1                	j	80006d00 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80006d3a:	000a8563          	beqz	s5,80006d44 <bd_print_vector+0x74>
    80006d3e:	4785                	li	a5,1
    80006d40:	00f91c63          	bne	s2,a5,80006d58 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006d44:	8652                	mv	a2,s4
    80006d46:	85d6                	mv	a1,s5
    80006d48:	00002517          	auipc	a0,0x2
    80006d4c:	06050513          	addi	a0,a0,96 # 80008da8 <userret+0xd18>
    80006d50:	ffffa097          	auipc	ra,0xffffa
    80006d54:	c1c080e7          	jalr	-996(ra) # 8000096c <printf>
  }
  printf("\n");
    80006d58:	00002517          	auipc	a0,0x2
    80006d5c:	8f050513          	addi	a0,a0,-1808 # 80008648 <userret+0x5b8>
    80006d60:	ffffa097          	auipc	ra,0xffffa
    80006d64:	c0c080e7          	jalr	-1012(ra) # 8000096c <printf>
}
    80006d68:	60a6                	ld	ra,72(sp)
    80006d6a:	6406                	ld	s0,64(sp)
    80006d6c:	74e2                	ld	s1,56(sp)
    80006d6e:	7942                	ld	s2,48(sp)
    80006d70:	79a2                	ld	s3,40(sp)
    80006d72:	7a02                	ld	s4,32(sp)
    80006d74:	6ae2                	ld	s5,24(sp)
    80006d76:	6b42                	ld	s6,16(sp)
    80006d78:	6ba2                	ld	s7,8(sp)
    80006d7a:	6161                	addi	sp,sp,80
    80006d7c:	8082                	ret
  lb = 0;
    80006d7e:	4a81                	li	s5,0
    80006d80:	b7d1                	j	80006d44 <bd_print_vector+0x74>

0000000080006d82 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006d82:	00027697          	auipc	a3,0x27
    80006d86:	31e6a683          	lw	a3,798(a3) # 8002e0a0 <nsizes>
    80006d8a:	10d05063          	blez	a3,80006e8a <bd_print+0x108>
bd_print() {
    80006d8e:	711d                	addi	sp,sp,-96
    80006d90:	ec86                	sd	ra,88(sp)
    80006d92:	e8a2                	sd	s0,80(sp)
    80006d94:	e4a6                	sd	s1,72(sp)
    80006d96:	e0ca                	sd	s2,64(sp)
    80006d98:	fc4e                	sd	s3,56(sp)
    80006d9a:	f852                	sd	s4,48(sp)
    80006d9c:	f456                	sd	s5,40(sp)
    80006d9e:	f05a                	sd	s6,32(sp)
    80006da0:	ec5e                	sd	s7,24(sp)
    80006da2:	e862                	sd	s8,16(sp)
    80006da4:	e466                	sd	s9,8(sp)
    80006da6:	e06a                	sd	s10,0(sp)
    80006da8:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80006daa:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006dac:	4a85                	li	s5,1
    80006dae:	4c41                	li	s8,16
    80006db0:	00002b97          	auipc	s7,0x2
    80006db4:	008b8b93          	addi	s7,s7,8 # 80008db8 <userret+0xd28>
    lst_print(&bd_sizes[k].free);
    80006db8:	00027a17          	auipc	s4,0x27
    80006dbc:	2e0a0a13          	addi	s4,s4,736 # 8002e098 <bd_sizes>
    printf("  alloc:");
    80006dc0:	00002b17          	auipc	s6,0x2
    80006dc4:	020b0b13          	addi	s6,s6,32 # 80008de0 <userret+0xd50>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006dc8:	00027997          	auipc	s3,0x27
    80006dcc:	2d898993          	addi	s3,s3,728 # 8002e0a0 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006dd0:	00002c97          	auipc	s9,0x2
    80006dd4:	020c8c93          	addi	s9,s9,32 # 80008df0 <userret+0xd60>
    80006dd8:	a801                	j	80006de8 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80006dda:	0009a683          	lw	a3,0(s3)
    80006dde:	0485                	addi	s1,s1,1
    80006de0:	0004879b          	sext.w	a5,s1
    80006de4:	08d7d563          	bge	a5,a3,80006e6e <bd_print+0xec>
    80006de8:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006dec:	36fd                	addiw	a3,a3,-1
    80006dee:	9e85                	subw	a3,a3,s1
    80006df0:	00da96bb          	sllw	a3,s5,a3
    80006df4:	009c1633          	sll	a2,s8,s1
    80006df8:	85ca                	mv	a1,s2
    80006dfa:	855e                	mv	a0,s7
    80006dfc:	ffffa097          	auipc	ra,0xffffa
    80006e00:	b70080e7          	jalr	-1168(ra) # 8000096c <printf>
    lst_print(&bd_sizes[k].free);
    80006e04:	00549d13          	slli	s10,s1,0x5
    80006e08:	000a3503          	ld	a0,0(s4)
    80006e0c:	956a                	add	a0,a0,s10
    80006e0e:	00001097          	auipc	ra,0x1
    80006e12:	a4e080e7          	jalr	-1458(ra) # 8000785c <lst_print>
    printf("  alloc:");
    80006e16:	855a                	mv	a0,s6
    80006e18:	ffffa097          	auipc	ra,0xffffa
    80006e1c:	b54080e7          	jalr	-1196(ra) # 8000096c <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006e20:	0009a583          	lw	a1,0(s3)
    80006e24:	35fd                	addiw	a1,a1,-1
    80006e26:	412585bb          	subw	a1,a1,s2
    80006e2a:	000a3783          	ld	a5,0(s4)
    80006e2e:	97ea                	add	a5,a5,s10
    80006e30:	00ba95bb          	sllw	a1,s5,a1
    80006e34:	6b88                	ld	a0,16(a5)
    80006e36:	00000097          	auipc	ra,0x0
    80006e3a:	e9a080e7          	jalr	-358(ra) # 80006cd0 <bd_print_vector>
    if(k > 0) {
    80006e3e:	f9205ee3          	blez	s2,80006dda <bd_print+0x58>
      printf("  split:");
    80006e42:	8566                	mv	a0,s9
    80006e44:	ffffa097          	auipc	ra,0xffffa
    80006e48:	b28080e7          	jalr	-1240(ra) # 8000096c <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006e4c:	0009a583          	lw	a1,0(s3)
    80006e50:	35fd                	addiw	a1,a1,-1
    80006e52:	412585bb          	subw	a1,a1,s2
    80006e56:	000a3783          	ld	a5,0(s4)
    80006e5a:	9d3e                	add	s10,s10,a5
    80006e5c:	00ba95bb          	sllw	a1,s5,a1
    80006e60:	018d3503          	ld	a0,24(s10)
    80006e64:	00000097          	auipc	ra,0x0
    80006e68:	e6c080e7          	jalr	-404(ra) # 80006cd0 <bd_print_vector>
    80006e6c:	b7bd                	j	80006dda <bd_print+0x58>
    }
  }
}
    80006e6e:	60e6                	ld	ra,88(sp)
    80006e70:	6446                	ld	s0,80(sp)
    80006e72:	64a6                	ld	s1,72(sp)
    80006e74:	6906                	ld	s2,64(sp)
    80006e76:	79e2                	ld	s3,56(sp)
    80006e78:	7a42                	ld	s4,48(sp)
    80006e7a:	7aa2                	ld	s5,40(sp)
    80006e7c:	7b02                	ld	s6,32(sp)
    80006e7e:	6be2                	ld	s7,24(sp)
    80006e80:	6c42                	ld	s8,16(sp)
    80006e82:	6ca2                	ld	s9,8(sp)
    80006e84:	6d02                	ld	s10,0(sp)
    80006e86:	6125                	addi	sp,sp,96
    80006e88:	8082                	ret
    80006e8a:	8082                	ret

0000000080006e8c <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006e8c:	1141                	addi	sp,sp,-16
    80006e8e:	e422                	sd	s0,8(sp)
    80006e90:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006e92:	47c1                	li	a5,16
    80006e94:	00a7fb63          	bgeu	a5,a0,80006eaa <firstk+0x1e>
    80006e98:	872a                	mv	a4,a0
  int k = 0;
    80006e9a:	4501                	li	a0,0
    k++;
    80006e9c:	2505                	addiw	a0,a0,1
    size *= 2;
    80006e9e:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006ea0:	fee7eee3          	bltu	a5,a4,80006e9c <firstk+0x10>
  }
  return k;
}
    80006ea4:	6422                	ld	s0,8(sp)
    80006ea6:	0141                	addi	sp,sp,16
    80006ea8:	8082                	ret
  int k = 0;
    80006eaa:	4501                	li	a0,0
    80006eac:	bfe5                	j	80006ea4 <firstk+0x18>

0000000080006eae <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006eae:	1141                	addi	sp,sp,-16
    80006eb0:	e422                	sd	s0,8(sp)
    80006eb2:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006eb4:	00027797          	auipc	a5,0x27
    80006eb8:	1dc7b783          	ld	a5,476(a5) # 8002e090 <bd_base>
    80006ebc:	9d9d                	subw	a1,a1,a5
    80006ebe:	47c1                	li	a5,16
    80006ec0:	00a79533          	sll	a0,a5,a0
    80006ec4:	02a5c533          	div	a0,a1,a0
}
    80006ec8:	2501                	sext.w	a0,a0
    80006eca:	6422                	ld	s0,8(sp)
    80006ecc:	0141                	addi	sp,sp,16
    80006ece:	8082                	ret

0000000080006ed0 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006ed0:	1141                	addi	sp,sp,-16
    80006ed2:	e422                	sd	s0,8(sp)
    80006ed4:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006ed6:	47c1                	li	a5,16
    80006ed8:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006edc:	02b787bb          	mulw	a5,a5,a1
}
    80006ee0:	00027517          	auipc	a0,0x27
    80006ee4:	1b053503          	ld	a0,432(a0) # 8002e090 <bd_base>
    80006ee8:	953e                	add	a0,a0,a5
    80006eea:	6422                	ld	s0,8(sp)
    80006eec:	0141                	addi	sp,sp,16
    80006eee:	8082                	ret

0000000080006ef0 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006ef0:	7159                	addi	sp,sp,-112
    80006ef2:	f486                	sd	ra,104(sp)
    80006ef4:	f0a2                	sd	s0,96(sp)
    80006ef6:	eca6                	sd	s1,88(sp)
    80006ef8:	e8ca                	sd	s2,80(sp)
    80006efa:	e4ce                	sd	s3,72(sp)
    80006efc:	e0d2                	sd	s4,64(sp)
    80006efe:	fc56                	sd	s5,56(sp)
    80006f00:	f85a                	sd	s6,48(sp)
    80006f02:	f45e                	sd	s7,40(sp)
    80006f04:	f062                	sd	s8,32(sp)
    80006f06:	ec66                	sd	s9,24(sp)
    80006f08:	e86a                	sd	s10,16(sp)
    80006f0a:	e46e                	sd	s11,8(sp)
    80006f0c:	1880                	addi	s0,sp,112
    80006f0e:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006f10:	00027517          	auipc	a0,0x27
    80006f14:	0f050513          	addi	a0,a0,240 # 8002e000 <lock>
    80006f18:	ffffa097          	auipc	ra,0xffffa
    80006f1c:	d70080e7          	jalr	-656(ra) # 80000c88 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006f20:	8526                	mv	a0,s1
    80006f22:	00000097          	auipc	ra,0x0
    80006f26:	f6a080e7          	jalr	-150(ra) # 80006e8c <firstk>
  for (k = fk; k < nsizes; k++) {
    80006f2a:	00027797          	auipc	a5,0x27
    80006f2e:	1767a783          	lw	a5,374(a5) # 8002e0a0 <nsizes>
    80006f32:	02f55d63          	bge	a0,a5,80006f6c <bd_malloc+0x7c>
    80006f36:	8c2a                	mv	s8,a0
    80006f38:	00551913          	slli	s2,a0,0x5
    80006f3c:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006f3e:	00027997          	auipc	s3,0x27
    80006f42:	15a98993          	addi	s3,s3,346 # 8002e098 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006f46:	00027a17          	auipc	s4,0x27
    80006f4a:	15aa0a13          	addi	s4,s4,346 # 8002e0a0 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006f4e:	0009b503          	ld	a0,0(s3)
    80006f52:	954a                	add	a0,a0,s2
    80006f54:	00001097          	auipc	ra,0x1
    80006f58:	88e080e7          	jalr	-1906(ra) # 800077e2 <lst_empty>
    80006f5c:	c115                	beqz	a0,80006f80 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006f5e:	2485                	addiw	s1,s1,1
    80006f60:	02090913          	addi	s2,s2,32
    80006f64:	000a2783          	lw	a5,0(s4)
    80006f68:	fef4c3e3          	blt	s1,a5,80006f4e <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006f6c:	00027517          	auipc	a0,0x27
    80006f70:	09450513          	addi	a0,a0,148 # 8002e000 <lock>
    80006f74:	ffffa097          	auipc	ra,0xffffa
    80006f78:	f60080e7          	jalr	-160(ra) # 80000ed4 <release>
    return 0;
    80006f7c:	4b01                	li	s6,0
    80006f7e:	a0e1                	j	80007046 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006f80:	00027797          	auipc	a5,0x27
    80006f84:	1207a783          	lw	a5,288(a5) # 8002e0a0 <nsizes>
    80006f88:	fef4d2e3          	bge	s1,a5,80006f6c <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006f8c:	00549993          	slli	s3,s1,0x5
    80006f90:	00027917          	auipc	s2,0x27
    80006f94:	10890913          	addi	s2,s2,264 # 8002e098 <bd_sizes>
    80006f98:	00093503          	ld	a0,0(s2)
    80006f9c:	954e                	add	a0,a0,s3
    80006f9e:	00001097          	auipc	ra,0x1
    80006fa2:	870080e7          	jalr	-1936(ra) # 8000780e <lst_pop>
    80006fa6:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006fa8:	00027597          	auipc	a1,0x27
    80006fac:	0e85b583          	ld	a1,232(a1) # 8002e090 <bd_base>
    80006fb0:	40b505bb          	subw	a1,a0,a1
    80006fb4:	47c1                	li	a5,16
    80006fb6:	009797b3          	sll	a5,a5,s1
    80006fba:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006fbe:	00093783          	ld	a5,0(s2)
    80006fc2:	97ce                	add	a5,a5,s3
    80006fc4:	2581                	sext.w	a1,a1
    80006fc6:	6b88                	ld	a0,16(a5)
    80006fc8:	00000097          	auipc	ra,0x0
    80006fcc:	ca4080e7          	jalr	-860(ra) # 80006c6c <bit_set>
  for(; k > fk; k--) {
    80006fd0:	069c5363          	bge	s8,s1,80007036 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006fd4:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006fd6:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006fd8:	00027d17          	auipc	s10,0x27
    80006fdc:	0b8d0d13          	addi	s10,s10,184 # 8002e090 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006fe0:	85a6                	mv	a1,s1
    80006fe2:	34fd                	addiw	s1,s1,-1
    80006fe4:	009b9ab3          	sll	s5,s7,s1
    80006fe8:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006fec:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    80006ff0:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006ff4:	412b093b          	subw	s2,s6,s2
    80006ff8:	00bb95b3          	sll	a1,s7,a1
    80006ffc:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80007000:	013a07b3          	add	a5,s4,s3
    80007004:	2581                	sext.w	a1,a1
    80007006:	6f88                	ld	a0,24(a5)
    80007008:	00000097          	auipc	ra,0x0
    8000700c:	c64080e7          	jalr	-924(ra) # 80006c6c <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80007010:	1981                	addi	s3,s3,-32
    80007012:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80007014:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80007018:	2581                	sext.w	a1,a1
    8000701a:	010a3503          	ld	a0,16(s4)
    8000701e:	00000097          	auipc	ra,0x0
    80007022:	c4e080e7          	jalr	-946(ra) # 80006c6c <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80007026:	85e6                	mv	a1,s9
    80007028:	8552                	mv	a0,s4
    8000702a:	00001097          	auipc	ra,0x1
    8000702e:	81a080e7          	jalr	-2022(ra) # 80007844 <lst_push>
  for(; k > fk; k--) {
    80007032:	fb8497e3          	bne	s1,s8,80006fe0 <bd_malloc+0xf0>
  }
  release(&lock);
    80007036:	00027517          	auipc	a0,0x27
    8000703a:	fca50513          	addi	a0,a0,-54 # 8002e000 <lock>
    8000703e:	ffffa097          	auipc	ra,0xffffa
    80007042:	e96080e7          	jalr	-362(ra) # 80000ed4 <release>

  return p;
}
    80007046:	855a                	mv	a0,s6
    80007048:	70a6                	ld	ra,104(sp)
    8000704a:	7406                	ld	s0,96(sp)
    8000704c:	64e6                	ld	s1,88(sp)
    8000704e:	6946                	ld	s2,80(sp)
    80007050:	69a6                	ld	s3,72(sp)
    80007052:	6a06                	ld	s4,64(sp)
    80007054:	7ae2                	ld	s5,56(sp)
    80007056:	7b42                	ld	s6,48(sp)
    80007058:	7ba2                	ld	s7,40(sp)
    8000705a:	7c02                	ld	s8,32(sp)
    8000705c:	6ce2                	ld	s9,24(sp)
    8000705e:	6d42                	ld	s10,16(sp)
    80007060:	6da2                	ld	s11,8(sp)
    80007062:	6165                	addi	sp,sp,112
    80007064:	8082                	ret

0000000080007066 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80007066:	7139                	addi	sp,sp,-64
    80007068:	fc06                	sd	ra,56(sp)
    8000706a:	f822                	sd	s0,48(sp)
    8000706c:	f426                	sd	s1,40(sp)
    8000706e:	f04a                	sd	s2,32(sp)
    80007070:	ec4e                	sd	s3,24(sp)
    80007072:	e852                	sd	s4,16(sp)
    80007074:	e456                	sd	s5,8(sp)
    80007076:	e05a                	sd	s6,0(sp)
    80007078:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    8000707a:	00027a97          	auipc	s5,0x27
    8000707e:	026aaa83          	lw	s5,38(s5) # 8002e0a0 <nsizes>
  return n / BLK_SIZE(k);
    80007082:	00027a17          	auipc	s4,0x27
    80007086:	00ea3a03          	ld	s4,14(s4) # 8002e090 <bd_base>
    8000708a:	41450a3b          	subw	s4,a0,s4
    8000708e:	00027497          	auipc	s1,0x27
    80007092:	00a4b483          	ld	s1,10(s1) # 8002e098 <bd_sizes>
    80007096:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    8000709a:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    8000709c:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    8000709e:	03595363          	bge	s2,s5,800070c4 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800070a2:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    800070a6:	013b15b3          	sll	a1,s6,s3
    800070aa:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800070ae:	2581                	sext.w	a1,a1
    800070b0:	6088                	ld	a0,0(s1)
    800070b2:	00000097          	auipc	ra,0x0
    800070b6:	b82080e7          	jalr	-1150(ra) # 80006c34 <bit_isset>
    800070ba:	02048493          	addi	s1,s1,32
    800070be:	e501                	bnez	a0,800070c6 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    800070c0:	894e                	mv	s2,s3
    800070c2:	bff1                	j	8000709e <size+0x38>
      return k;
    }
  }
  return 0;
    800070c4:	4901                	li	s2,0
}
    800070c6:	854a                	mv	a0,s2
    800070c8:	70e2                	ld	ra,56(sp)
    800070ca:	7442                	ld	s0,48(sp)
    800070cc:	74a2                	ld	s1,40(sp)
    800070ce:	7902                	ld	s2,32(sp)
    800070d0:	69e2                	ld	s3,24(sp)
    800070d2:	6a42                	ld	s4,16(sp)
    800070d4:	6aa2                	ld	s5,8(sp)
    800070d6:	6b02                	ld	s6,0(sp)
    800070d8:	6121                	addi	sp,sp,64
    800070da:	8082                	ret

00000000800070dc <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    800070dc:	7159                	addi	sp,sp,-112
    800070de:	f486                	sd	ra,104(sp)
    800070e0:	f0a2                	sd	s0,96(sp)
    800070e2:	eca6                	sd	s1,88(sp)
    800070e4:	e8ca                	sd	s2,80(sp)
    800070e6:	e4ce                	sd	s3,72(sp)
    800070e8:	e0d2                	sd	s4,64(sp)
    800070ea:	fc56                	sd	s5,56(sp)
    800070ec:	f85a                	sd	s6,48(sp)
    800070ee:	f45e                	sd	s7,40(sp)
    800070f0:	f062                	sd	s8,32(sp)
    800070f2:	ec66                	sd	s9,24(sp)
    800070f4:	e86a                	sd	s10,16(sp)
    800070f6:	e46e                	sd	s11,8(sp)
    800070f8:	1880                	addi	s0,sp,112
    800070fa:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    800070fc:	00027517          	auipc	a0,0x27
    80007100:	f0450513          	addi	a0,a0,-252 # 8002e000 <lock>
    80007104:	ffffa097          	auipc	ra,0xffffa
    80007108:	b84080e7          	jalr	-1148(ra) # 80000c88 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    8000710c:	8556                	mv	a0,s5
    8000710e:	00000097          	auipc	ra,0x0
    80007112:	f58080e7          	jalr	-168(ra) # 80007066 <size>
    80007116:	84aa                	mv	s1,a0
    80007118:	00027797          	auipc	a5,0x27
    8000711c:	f887a783          	lw	a5,-120(a5) # 8002e0a0 <nsizes>
    80007120:	37fd                	addiw	a5,a5,-1
    80007122:	0af55d63          	bge	a0,a5,800071dc <bd_free+0x100>
    80007126:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    8000712a:	00027c17          	auipc	s8,0x27
    8000712e:	f66c0c13          	addi	s8,s8,-154 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    80007132:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007134:	00027b17          	auipc	s6,0x27
    80007138:	f64b0b13          	addi	s6,s6,-156 # 8002e098 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    8000713c:	00027c97          	auipc	s9,0x27
    80007140:	f64c8c93          	addi	s9,s9,-156 # 8002e0a0 <nsizes>
    80007144:	a82d                	j	8000717e <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007146:	fff58d9b          	addiw	s11,a1,-1
    8000714a:	a881                	j	8000719a <bd_free+0xbe>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    8000714c:	020a0a13          	addi	s4,s4,32
    80007150:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80007152:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80007156:	40ba85bb          	subw	a1,s5,a1
    8000715a:	009b97b3          	sll	a5,s7,s1
    8000715e:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007162:	000b3783          	ld	a5,0(s6)
    80007166:	97d2                	add	a5,a5,s4
    80007168:	2581                	sext.w	a1,a1
    8000716a:	6f88                	ld	a0,24(a5)
    8000716c:	00000097          	auipc	ra,0x0
    80007170:	b30080e7          	jalr	-1232(ra) # 80006c9c <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80007174:	000ca783          	lw	a5,0(s9)
    80007178:	37fd                	addiw	a5,a5,-1
    8000717a:	06f4d163          	bge	s1,a5,800071dc <bd_free+0x100>
  int n = p - (char *) bd_base;
    8000717e:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80007182:	009b99b3          	sll	s3,s7,s1
    80007186:	412a87bb          	subw	a5,s5,s2
    8000718a:	0337c7b3          	div	a5,a5,s3
    8000718e:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007192:	8b85                	andi	a5,a5,1
    80007194:	fbcd                	bnez	a5,80007146 <bd_free+0x6a>
    80007196:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    8000719a:	000b3d03          	ld	s10,0(s6)
    8000719e:	9d52                	add	s10,s10,s4
    800071a0:	010d3503          	ld	a0,16(s10)
    800071a4:	00000097          	auipc	ra,0x0
    800071a8:	af8080e7          	jalr	-1288(ra) # 80006c9c <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    800071ac:	85ee                	mv	a1,s11
    800071ae:	010d3503          	ld	a0,16(s10)
    800071b2:	00000097          	auipc	ra,0x0
    800071b6:	a82080e7          	jalr	-1406(ra) # 80006c34 <bit_isset>
    800071ba:	e10d                	bnez	a0,800071dc <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    800071bc:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    800071c0:	03b989bb          	mulw	s3,s3,s11
    800071c4:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    800071c6:	854a                	mv	a0,s2
    800071c8:	00000097          	auipc	ra,0x0
    800071cc:	630080e7          	jalr	1584(ra) # 800077f8 <lst_remove>
    if(buddy % 2 == 0) {
    800071d0:	001d7d13          	andi	s10,s10,1
    800071d4:	f60d1ce3          	bnez	s10,8000714c <bd_free+0x70>
      p = q;
    800071d8:	8aca                	mv	s5,s2
    800071da:	bf8d                	j	8000714c <bd_free+0x70>
  }
  lst_push(&bd_sizes[k].free, p);
    800071dc:	0496                	slli	s1,s1,0x5
    800071de:	85d6                	mv	a1,s5
    800071e0:	00027517          	auipc	a0,0x27
    800071e4:	eb853503          	ld	a0,-328(a0) # 8002e098 <bd_sizes>
    800071e8:	9526                	add	a0,a0,s1
    800071ea:	00000097          	auipc	ra,0x0
    800071ee:	65a080e7          	jalr	1626(ra) # 80007844 <lst_push>
  release(&lock);
    800071f2:	00027517          	auipc	a0,0x27
    800071f6:	e0e50513          	addi	a0,a0,-498 # 8002e000 <lock>
    800071fa:	ffffa097          	auipc	ra,0xffffa
    800071fe:	cda080e7          	jalr	-806(ra) # 80000ed4 <release>
}
    80007202:	70a6                	ld	ra,104(sp)
    80007204:	7406                	ld	s0,96(sp)
    80007206:	64e6                	ld	s1,88(sp)
    80007208:	6946                	ld	s2,80(sp)
    8000720a:	69a6                	ld	s3,72(sp)
    8000720c:	6a06                	ld	s4,64(sp)
    8000720e:	7ae2                	ld	s5,56(sp)
    80007210:	7b42                	ld	s6,48(sp)
    80007212:	7ba2                	ld	s7,40(sp)
    80007214:	7c02                	ld	s8,32(sp)
    80007216:	6ce2                	ld	s9,24(sp)
    80007218:	6d42                	ld	s10,16(sp)
    8000721a:	6da2                	ld	s11,8(sp)
    8000721c:	6165                	addi	sp,sp,112
    8000721e:	8082                	ret

0000000080007220 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80007220:	1141                	addi	sp,sp,-16
    80007222:	e422                	sd	s0,8(sp)
    80007224:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80007226:	00027797          	auipc	a5,0x27
    8000722a:	e6a7b783          	ld	a5,-406(a5) # 8002e090 <bd_base>
    8000722e:	8d9d                	sub	a1,a1,a5
    80007230:	47c1                	li	a5,16
    80007232:	00a797b3          	sll	a5,a5,a0
    80007236:	02f5c533          	div	a0,a1,a5
    8000723a:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    8000723c:	02f5e5b3          	rem	a1,a1,a5
    80007240:	c191                	beqz	a1,80007244 <blk_index_next+0x24>
      n++;
    80007242:	2505                	addiw	a0,a0,1
  return n ;
}
    80007244:	6422                	ld	s0,8(sp)
    80007246:	0141                	addi	sp,sp,16
    80007248:	8082                	ret

000000008000724a <log2>:

int
log2(uint64 n) {
    8000724a:	1141                	addi	sp,sp,-16
    8000724c:	e422                	sd	s0,8(sp)
    8000724e:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80007250:	4705                	li	a4,1
    80007252:	00a77b63          	bgeu	a4,a0,80007268 <log2+0x1e>
    80007256:	87aa                	mv	a5,a0
  int k = 0;
    80007258:	4501                	li	a0,0
    k++;
    8000725a:	2505                	addiw	a0,a0,1
    n = n >> 1;
    8000725c:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    8000725e:	fef76ee3          	bltu	a4,a5,8000725a <log2+0x10>
  }
  return k;
}
    80007262:	6422                	ld	s0,8(sp)
    80007264:	0141                	addi	sp,sp,16
    80007266:	8082                	ret
  int k = 0;
    80007268:	4501                	li	a0,0
    8000726a:	bfe5                	j	80007262 <log2+0x18>

000000008000726c <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    8000726c:	711d                	addi	sp,sp,-96
    8000726e:	ec86                	sd	ra,88(sp)
    80007270:	e8a2                	sd	s0,80(sp)
    80007272:	e4a6                	sd	s1,72(sp)
    80007274:	e0ca                	sd	s2,64(sp)
    80007276:	fc4e                	sd	s3,56(sp)
    80007278:	f852                	sd	s4,48(sp)
    8000727a:	f456                	sd	s5,40(sp)
    8000727c:	f05a                	sd	s6,32(sp)
    8000727e:	ec5e                	sd	s7,24(sp)
    80007280:	e862                	sd	s8,16(sp)
    80007282:	e466                	sd	s9,8(sp)
    80007284:	e06a                	sd	s10,0(sp)
    80007286:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80007288:	00b56933          	or	s2,a0,a1
    8000728c:	00f97913          	andi	s2,s2,15
    80007290:	04091263          	bnez	s2,800072d4 <bd_mark+0x68>
    80007294:	8b2a                	mv	s6,a0
    80007296:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80007298:	00027c17          	auipc	s8,0x27
    8000729c:	e08c2c03          	lw	s8,-504(s8) # 8002e0a0 <nsizes>
    800072a0:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    800072a2:	00027d17          	auipc	s10,0x27
    800072a6:	deed0d13          	addi	s10,s10,-530 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    800072aa:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    800072ac:	00027a97          	auipc	s5,0x27
    800072b0:	deca8a93          	addi	s5,s5,-532 # 8002e098 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    800072b4:	07804563          	bgtz	s8,8000731e <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    800072b8:	60e6                	ld	ra,88(sp)
    800072ba:	6446                	ld	s0,80(sp)
    800072bc:	64a6                	ld	s1,72(sp)
    800072be:	6906                	ld	s2,64(sp)
    800072c0:	79e2                	ld	s3,56(sp)
    800072c2:	7a42                	ld	s4,48(sp)
    800072c4:	7aa2                	ld	s5,40(sp)
    800072c6:	7b02                	ld	s6,32(sp)
    800072c8:	6be2                	ld	s7,24(sp)
    800072ca:	6c42                	ld	s8,16(sp)
    800072cc:	6ca2                	ld	s9,8(sp)
    800072ce:	6d02                	ld	s10,0(sp)
    800072d0:	6125                	addi	sp,sp,96
    800072d2:	8082                	ret
    panic("bd_mark");
    800072d4:	00002517          	auipc	a0,0x2
    800072d8:	b2c50513          	addi	a0,a0,-1236 # 80008e00 <userret+0xd70>
    800072dc:	ffff9097          	auipc	ra,0xffff9
    800072e0:	47a080e7          	jalr	1146(ra) # 80000756 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    800072e4:	000ab783          	ld	a5,0(s5)
    800072e8:	97ca                	add	a5,a5,s2
    800072ea:	85a6                	mv	a1,s1
    800072ec:	6b88                	ld	a0,16(a5)
    800072ee:	00000097          	auipc	ra,0x0
    800072f2:	97e080e7          	jalr	-1666(ra) # 80006c6c <bit_set>
    for(; bi < bj; bi++) {
    800072f6:	2485                	addiw	s1,s1,1
    800072f8:	009a0e63          	beq	s4,s1,80007314 <bd_mark+0xa8>
      if(k > 0) {
    800072fc:	ff3054e3          	blez	s3,800072e4 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80007300:	000ab783          	ld	a5,0(s5)
    80007304:	97ca                	add	a5,a5,s2
    80007306:	85a6                	mv	a1,s1
    80007308:	6f88                	ld	a0,24(a5)
    8000730a:	00000097          	auipc	ra,0x0
    8000730e:	962080e7          	jalr	-1694(ra) # 80006c6c <bit_set>
    80007312:	bfc9                	j	800072e4 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80007314:	2985                	addiw	s3,s3,1
    80007316:	02090913          	addi	s2,s2,32
    8000731a:	f9898fe3          	beq	s3,s8,800072b8 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    8000731e:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80007322:	409b04bb          	subw	s1,s6,s1
    80007326:	013c97b3          	sll	a5,s9,s3
    8000732a:	02f4c4b3          	div	s1,s1,a5
    8000732e:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80007330:	85de                	mv	a1,s7
    80007332:	854e                	mv	a0,s3
    80007334:	00000097          	auipc	ra,0x0
    80007338:	eec080e7          	jalr	-276(ra) # 80007220 <blk_index_next>
    8000733c:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    8000733e:	faa4cfe3          	blt	s1,a0,800072fc <bd_mark+0x90>
    80007342:	bfc9                	j	80007314 <bd_mark+0xa8>

0000000080007344 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80007344:	7139                	addi	sp,sp,-64
    80007346:	fc06                	sd	ra,56(sp)
    80007348:	f822                	sd	s0,48(sp)
    8000734a:	f426                	sd	s1,40(sp)
    8000734c:	f04a                	sd	s2,32(sp)
    8000734e:	ec4e                	sd	s3,24(sp)
    80007350:	e852                	sd	s4,16(sp)
    80007352:	e456                	sd	s5,8(sp)
    80007354:	e05a                	sd	s6,0(sp)
    80007356:	0080                	addi	s0,sp,64
    80007358:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000735a:	00058a9b          	sext.w	s5,a1
    8000735e:	0015f793          	andi	a5,a1,1
    80007362:	ebad                	bnez	a5,800073d4 <bd_initfree_pair+0x90>
    80007364:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007368:	00599493          	slli	s1,s3,0x5
    8000736c:	00027797          	auipc	a5,0x27
    80007370:	d2c7b783          	ld	a5,-724(a5) # 8002e098 <bd_sizes>
    80007374:	94be                	add	s1,s1,a5
    80007376:	0104bb03          	ld	s6,16(s1)
    8000737a:	855a                	mv	a0,s6
    8000737c:	00000097          	auipc	ra,0x0
    80007380:	8b8080e7          	jalr	-1864(ra) # 80006c34 <bit_isset>
    80007384:	892a                	mv	s2,a0
    80007386:	85d2                	mv	a1,s4
    80007388:	855a                	mv	a0,s6
    8000738a:	00000097          	auipc	ra,0x0
    8000738e:	8aa080e7          	jalr	-1878(ra) # 80006c34 <bit_isset>
  int free = 0;
    80007392:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007394:	02a90563          	beq	s2,a0,800073be <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80007398:	45c1                	li	a1,16
    8000739a:	013599b3          	sll	s3,a1,s3
    8000739e:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    800073a2:	02090c63          	beqz	s2,800073da <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    800073a6:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    800073aa:	00027597          	auipc	a1,0x27
    800073ae:	ce65b583          	ld	a1,-794(a1) # 8002e090 <bd_base>
    800073b2:	95ce                	add	a1,a1,s3
    800073b4:	8526                	mv	a0,s1
    800073b6:	00000097          	auipc	ra,0x0
    800073ba:	48e080e7          	jalr	1166(ra) # 80007844 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    800073be:	855a                	mv	a0,s6
    800073c0:	70e2                	ld	ra,56(sp)
    800073c2:	7442                	ld	s0,48(sp)
    800073c4:	74a2                	ld	s1,40(sp)
    800073c6:	7902                	ld	s2,32(sp)
    800073c8:	69e2                	ld	s3,24(sp)
    800073ca:	6a42                	ld	s4,16(sp)
    800073cc:	6aa2                	ld	s5,8(sp)
    800073ce:	6b02                	ld	s6,0(sp)
    800073d0:	6121                	addi	sp,sp,64
    800073d2:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800073d4:	fff58a1b          	addiw	s4,a1,-1
    800073d8:	bf41                	j	80007368 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    800073da:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    800073de:	00027597          	auipc	a1,0x27
    800073e2:	cb25b583          	ld	a1,-846(a1) # 8002e090 <bd_base>
    800073e6:	95ce                	add	a1,a1,s3
    800073e8:	8526                	mv	a0,s1
    800073ea:	00000097          	auipc	ra,0x0
    800073ee:	45a080e7          	jalr	1114(ra) # 80007844 <lst_push>
    800073f2:	b7f1                	j	800073be <bd_initfree_pair+0x7a>

00000000800073f4 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    800073f4:	711d                	addi	sp,sp,-96
    800073f6:	ec86                	sd	ra,88(sp)
    800073f8:	e8a2                	sd	s0,80(sp)
    800073fa:	e4a6                	sd	s1,72(sp)
    800073fc:	e0ca                	sd	s2,64(sp)
    800073fe:	fc4e                	sd	s3,56(sp)
    80007400:	f852                	sd	s4,48(sp)
    80007402:	f456                	sd	s5,40(sp)
    80007404:	f05a                	sd	s6,32(sp)
    80007406:	ec5e                	sd	s7,24(sp)
    80007408:	e862                	sd	s8,16(sp)
    8000740a:	e466                	sd	s9,8(sp)
    8000740c:	e06a                	sd	s10,0(sp)
    8000740e:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007410:	00027717          	auipc	a4,0x27
    80007414:	c9072703          	lw	a4,-880(a4) # 8002e0a0 <nsizes>
    80007418:	4785                	li	a5,1
    8000741a:	06e7db63          	bge	a5,a4,80007490 <bd_initfree+0x9c>
    8000741e:	8aaa                	mv	s5,a0
    80007420:	8b2e                	mv	s6,a1
    80007422:	4901                	li	s2,0
  int free = 0;
    80007424:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80007426:	00027c97          	auipc	s9,0x27
    8000742a:	c6ac8c93          	addi	s9,s9,-918 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    8000742e:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007430:	00027b97          	auipc	s7,0x27
    80007434:	c70b8b93          	addi	s7,s7,-912 # 8002e0a0 <nsizes>
    80007438:	a039                	j	80007446 <bd_initfree+0x52>
    8000743a:	2905                	addiw	s2,s2,1
    8000743c:	000ba783          	lw	a5,0(s7)
    80007440:	37fd                	addiw	a5,a5,-1
    80007442:	04f95863          	bge	s2,a5,80007492 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80007446:	85d6                	mv	a1,s5
    80007448:	854a                	mv	a0,s2
    8000744a:	00000097          	auipc	ra,0x0
    8000744e:	dd6080e7          	jalr	-554(ra) # 80007220 <blk_index_next>
    80007452:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80007454:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80007458:	409b04bb          	subw	s1,s6,s1
    8000745c:	012c17b3          	sll	a5,s8,s2
    80007460:	02f4c4b3          	div	s1,s1,a5
    80007464:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80007466:	85aa                	mv	a1,a0
    80007468:	854a                	mv	a0,s2
    8000746a:	00000097          	auipc	ra,0x0
    8000746e:	eda080e7          	jalr	-294(ra) # 80007344 <bd_initfree_pair>
    80007472:	01450d3b          	addw	s10,a0,s4
    80007476:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    8000747a:	fc99d0e3          	bge	s3,s1,8000743a <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    8000747e:	85a6                	mv	a1,s1
    80007480:	854a                	mv	a0,s2
    80007482:	00000097          	auipc	ra,0x0
    80007486:	ec2080e7          	jalr	-318(ra) # 80007344 <bd_initfree_pair>
    8000748a:	00ad0a3b          	addw	s4,s10,a0
    8000748e:	b775                	j	8000743a <bd_initfree+0x46>
  int free = 0;
    80007490:	4a01                	li	s4,0
  }
  return free;
}
    80007492:	8552                	mv	a0,s4
    80007494:	60e6                	ld	ra,88(sp)
    80007496:	6446                	ld	s0,80(sp)
    80007498:	64a6                	ld	s1,72(sp)
    8000749a:	6906                	ld	s2,64(sp)
    8000749c:	79e2                	ld	s3,56(sp)
    8000749e:	7a42                	ld	s4,48(sp)
    800074a0:	7aa2                	ld	s5,40(sp)
    800074a2:	7b02                	ld	s6,32(sp)
    800074a4:	6be2                	ld	s7,24(sp)
    800074a6:	6c42                	ld	s8,16(sp)
    800074a8:	6ca2                	ld	s9,8(sp)
    800074aa:	6d02                	ld	s10,0(sp)
    800074ac:	6125                	addi	sp,sp,96
    800074ae:	8082                	ret

00000000800074b0 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    800074b0:	7179                	addi	sp,sp,-48
    800074b2:	f406                	sd	ra,40(sp)
    800074b4:	f022                	sd	s0,32(sp)
    800074b6:	ec26                	sd	s1,24(sp)
    800074b8:	e84a                	sd	s2,16(sp)
    800074ba:	e44e                	sd	s3,8(sp)
    800074bc:	1800                	addi	s0,sp,48
    800074be:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    800074c0:	00027997          	auipc	s3,0x27
    800074c4:	bd098993          	addi	s3,s3,-1072 # 8002e090 <bd_base>
    800074c8:	0009b483          	ld	s1,0(s3)
    800074cc:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    800074d0:	00027797          	auipc	a5,0x27
    800074d4:	bd07a783          	lw	a5,-1072(a5) # 8002e0a0 <nsizes>
    800074d8:	37fd                	addiw	a5,a5,-1
    800074da:	4641                	li	a2,16
    800074dc:	00f61633          	sll	a2,a2,a5
    800074e0:	85a6                	mv	a1,s1
    800074e2:	00002517          	auipc	a0,0x2
    800074e6:	92650513          	addi	a0,a0,-1754 # 80008e08 <userret+0xd78>
    800074ea:	ffff9097          	auipc	ra,0xffff9
    800074ee:	482080e7          	jalr	1154(ra) # 8000096c <printf>
  bd_mark(bd_base, p);
    800074f2:	85ca                	mv	a1,s2
    800074f4:	0009b503          	ld	a0,0(s3)
    800074f8:	00000097          	auipc	ra,0x0
    800074fc:	d74080e7          	jalr	-652(ra) # 8000726c <bd_mark>
  return meta;
}
    80007500:	8526                	mv	a0,s1
    80007502:	70a2                	ld	ra,40(sp)
    80007504:	7402                	ld	s0,32(sp)
    80007506:	64e2                	ld	s1,24(sp)
    80007508:	6942                	ld	s2,16(sp)
    8000750a:	69a2                	ld	s3,8(sp)
    8000750c:	6145                	addi	sp,sp,48
    8000750e:	8082                	ret

0000000080007510 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80007510:	1101                	addi	sp,sp,-32
    80007512:	ec06                	sd	ra,24(sp)
    80007514:	e822                	sd	s0,16(sp)
    80007516:	e426                	sd	s1,8(sp)
    80007518:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    8000751a:	00027497          	auipc	s1,0x27
    8000751e:	b864a483          	lw	s1,-1146(s1) # 8002e0a0 <nsizes>
    80007522:	fff4879b          	addiw	a5,s1,-1
    80007526:	44c1                	li	s1,16
    80007528:	00f494b3          	sll	s1,s1,a5
    8000752c:	00027797          	auipc	a5,0x27
    80007530:	b647b783          	ld	a5,-1180(a5) # 8002e090 <bd_base>
    80007534:	8d1d                	sub	a0,a0,a5
    80007536:	40a4853b          	subw	a0,s1,a0
    8000753a:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    8000753e:	00905a63          	blez	s1,80007552 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80007542:	357d                	addiw	a0,a0,-1
    80007544:	41f5549b          	sraiw	s1,a0,0x1f
    80007548:	01c4d49b          	srliw	s1,s1,0x1c
    8000754c:	9ca9                	addw	s1,s1,a0
    8000754e:	98c1                	andi	s1,s1,-16
    80007550:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80007552:	85a6                	mv	a1,s1
    80007554:	00002517          	auipc	a0,0x2
    80007558:	8ec50513          	addi	a0,a0,-1812 # 80008e40 <userret+0xdb0>
    8000755c:	ffff9097          	auipc	ra,0xffff9
    80007560:	410080e7          	jalr	1040(ra) # 8000096c <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007564:	00027717          	auipc	a4,0x27
    80007568:	b2c73703          	ld	a4,-1236(a4) # 8002e090 <bd_base>
    8000756c:	00027597          	auipc	a1,0x27
    80007570:	b345a583          	lw	a1,-1228(a1) # 8002e0a0 <nsizes>
    80007574:	fff5879b          	addiw	a5,a1,-1
    80007578:	45c1                	li	a1,16
    8000757a:	00f595b3          	sll	a1,a1,a5
    8000757e:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80007582:	95ba                	add	a1,a1,a4
    80007584:	953a                	add	a0,a0,a4
    80007586:	00000097          	auipc	ra,0x0
    8000758a:	ce6080e7          	jalr	-794(ra) # 8000726c <bd_mark>
  return unavailable;
}
    8000758e:	8526                	mv	a0,s1
    80007590:	60e2                	ld	ra,24(sp)
    80007592:	6442                	ld	s0,16(sp)
    80007594:	64a2                	ld	s1,8(sp)
    80007596:	6105                	addi	sp,sp,32
    80007598:	8082                	ret

000000008000759a <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    8000759a:	715d                	addi	sp,sp,-80
    8000759c:	e486                	sd	ra,72(sp)
    8000759e:	e0a2                	sd	s0,64(sp)
    800075a0:	fc26                	sd	s1,56(sp)
    800075a2:	f84a                	sd	s2,48(sp)
    800075a4:	f44e                	sd	s3,40(sp)
    800075a6:	f052                	sd	s4,32(sp)
    800075a8:	ec56                	sd	s5,24(sp)
    800075aa:	e85a                	sd	s6,16(sp)
    800075ac:	e45e                	sd	s7,8(sp)
    800075ae:	e062                	sd	s8,0(sp)
    800075b0:	0880                	addi	s0,sp,80
    800075b2:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    800075b4:	fff50493          	addi	s1,a0,-1
    800075b8:	98c1                	andi	s1,s1,-16
    800075ba:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    800075bc:	00002597          	auipc	a1,0x2
    800075c0:	8a458593          	addi	a1,a1,-1884 # 80008e60 <userret+0xdd0>
    800075c4:	00027517          	auipc	a0,0x27
    800075c8:	a3c50513          	addi	a0,a0,-1476 # 8002e000 <lock>
    800075cc:	ffff9097          	auipc	ra,0xffff9
    800075d0:	552080e7          	jalr	1362(ra) # 80000b1e <initlock>
  bd_base = (void *) p;
    800075d4:	00027797          	auipc	a5,0x27
    800075d8:	aa97be23          	sd	s1,-1348(a5) # 8002e090 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    800075dc:	409c0933          	sub	s2,s8,s1
    800075e0:	43f95513          	srai	a0,s2,0x3f
    800075e4:	893d                	andi	a0,a0,15
    800075e6:	954a                	add	a0,a0,s2
    800075e8:	8511                	srai	a0,a0,0x4
    800075ea:	00000097          	auipc	ra,0x0
    800075ee:	c60080e7          	jalr	-928(ra) # 8000724a <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    800075f2:	47c1                	li	a5,16
    800075f4:	00a797b3          	sll	a5,a5,a0
    800075f8:	1b27c663          	blt	a5,s2,800077a4 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    800075fc:	2505                	addiw	a0,a0,1
    800075fe:	00027797          	auipc	a5,0x27
    80007602:	aaa7a123          	sw	a0,-1374(a5) # 8002e0a0 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80007606:	00027997          	auipc	s3,0x27
    8000760a:	a9a98993          	addi	s3,s3,-1382 # 8002e0a0 <nsizes>
    8000760e:	0009a603          	lw	a2,0(s3)
    80007612:	85ca                	mv	a1,s2
    80007614:	00002517          	auipc	a0,0x2
    80007618:	85450513          	addi	a0,a0,-1964 # 80008e68 <userret+0xdd8>
    8000761c:	ffff9097          	auipc	ra,0xffff9
    80007620:	350080e7          	jalr	848(ra) # 8000096c <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80007624:	00027797          	auipc	a5,0x27
    80007628:	a697ba23          	sd	s1,-1420(a5) # 8002e098 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    8000762c:	0009a603          	lw	a2,0(s3)
    80007630:	00561913          	slli	s2,a2,0x5
    80007634:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80007636:	0056161b          	slliw	a2,a2,0x5
    8000763a:	4581                	li	a1,0
    8000763c:	8526                	mv	a0,s1
    8000763e:	ffffa097          	auipc	ra,0xffffa
    80007642:	a96080e7          	jalr	-1386(ra) # 800010d4 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80007646:	0009a783          	lw	a5,0(s3)
    8000764a:	06f05a63          	blez	a5,800076be <bd_init+0x124>
    8000764e:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80007650:	00027a97          	auipc	s5,0x27
    80007654:	a48a8a93          	addi	s5,s5,-1464 # 8002e098 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007658:	00027a17          	auipc	s4,0x27
    8000765c:	a48a0a13          	addi	s4,s4,-1464 # 8002e0a0 <nsizes>
    80007660:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80007662:	00599b93          	slli	s7,s3,0x5
    80007666:	000ab503          	ld	a0,0(s5)
    8000766a:	955e                	add	a0,a0,s7
    8000766c:	00000097          	auipc	ra,0x0
    80007670:	166080e7          	jalr	358(ra) # 800077d2 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007674:	000a2483          	lw	s1,0(s4)
    80007678:	34fd                	addiw	s1,s1,-1
    8000767a:	413484bb          	subw	s1,s1,s3
    8000767e:	009b14bb          	sllw	s1,s6,s1
    80007682:	fff4879b          	addiw	a5,s1,-1
    80007686:	41f7d49b          	sraiw	s1,a5,0x1f
    8000768a:	01d4d49b          	srliw	s1,s1,0x1d
    8000768e:	9cbd                	addw	s1,s1,a5
    80007690:	98e1                	andi	s1,s1,-8
    80007692:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80007694:	000ab783          	ld	a5,0(s5)
    80007698:	9bbe                	add	s7,s7,a5
    8000769a:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    8000769e:	848d                	srai	s1,s1,0x3
    800076a0:	8626                	mv	a2,s1
    800076a2:	4581                	li	a1,0
    800076a4:	854a                	mv	a0,s2
    800076a6:	ffffa097          	auipc	ra,0xffffa
    800076aa:	a2e080e7          	jalr	-1490(ra) # 800010d4 <memset>
    p += sz;
    800076ae:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    800076b0:	0985                	addi	s3,s3,1
    800076b2:	000a2703          	lw	a4,0(s4)
    800076b6:	0009879b          	sext.w	a5,s3
    800076ba:	fae7c4e3          	blt	a5,a4,80007662 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    800076be:	00027797          	auipc	a5,0x27
    800076c2:	9e27a783          	lw	a5,-1566(a5) # 8002e0a0 <nsizes>
    800076c6:	4705                	li	a4,1
    800076c8:	06f75163          	bge	a4,a5,8000772a <bd_init+0x190>
    800076cc:	02000a13          	li	s4,32
    800076d0:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    800076d2:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    800076d4:	00027b17          	auipc	s6,0x27
    800076d8:	9c4b0b13          	addi	s6,s6,-1596 # 8002e098 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    800076dc:	00027a97          	auipc	s5,0x27
    800076e0:	9c4a8a93          	addi	s5,s5,-1596 # 8002e0a0 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    800076e4:	37fd                	addiw	a5,a5,-1
    800076e6:	413787bb          	subw	a5,a5,s3
    800076ea:	00fb94bb          	sllw	s1,s7,a5
    800076ee:	fff4879b          	addiw	a5,s1,-1
    800076f2:	41f7d49b          	sraiw	s1,a5,0x1f
    800076f6:	01d4d49b          	srliw	s1,s1,0x1d
    800076fa:	9cbd                	addw	s1,s1,a5
    800076fc:	98e1                	andi	s1,s1,-8
    800076fe:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007700:	000b3783          	ld	a5,0(s6)
    80007704:	97d2                	add	a5,a5,s4
    80007706:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    8000770a:	848d                	srai	s1,s1,0x3
    8000770c:	8626                	mv	a2,s1
    8000770e:	4581                	li	a1,0
    80007710:	854a                	mv	a0,s2
    80007712:	ffffa097          	auipc	ra,0xffffa
    80007716:	9c2080e7          	jalr	-1598(ra) # 800010d4 <memset>
    p += sz;
    8000771a:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    8000771c:	2985                	addiw	s3,s3,1
    8000771e:	000aa783          	lw	a5,0(s5)
    80007722:	020a0a13          	addi	s4,s4,32
    80007726:	faf9cfe3          	blt	s3,a5,800076e4 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    8000772a:	197d                	addi	s2,s2,-1
    8000772c:	ff097913          	andi	s2,s2,-16
    80007730:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80007732:	854a                	mv	a0,s2
    80007734:	00000097          	auipc	ra,0x0
    80007738:	d7c080e7          	jalr	-644(ra) # 800074b0 <bd_mark_data_structures>
    8000773c:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    8000773e:	85ca                	mv	a1,s2
    80007740:	8562                	mv	a0,s8
    80007742:	00000097          	auipc	ra,0x0
    80007746:	dce080e7          	jalr	-562(ra) # 80007510 <bd_mark_unavailable>
    8000774a:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    8000774c:	00027a97          	auipc	s5,0x27
    80007750:	954a8a93          	addi	s5,s5,-1708 # 8002e0a0 <nsizes>
    80007754:	000aa783          	lw	a5,0(s5)
    80007758:	37fd                	addiw	a5,a5,-1
    8000775a:	44c1                	li	s1,16
    8000775c:	00f497b3          	sll	a5,s1,a5
    80007760:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80007762:	00027597          	auipc	a1,0x27
    80007766:	92e5b583          	ld	a1,-1746(a1) # 8002e090 <bd_base>
    8000776a:	95be                	add	a1,a1,a5
    8000776c:	854a                	mv	a0,s2
    8000776e:	00000097          	auipc	ra,0x0
    80007772:	c86080e7          	jalr	-890(ra) # 800073f4 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80007776:	000aa603          	lw	a2,0(s5)
    8000777a:	367d                	addiw	a2,a2,-1
    8000777c:	00c49633          	sll	a2,s1,a2
    80007780:	41460633          	sub	a2,a2,s4
    80007784:	41360633          	sub	a2,a2,s3
    80007788:	02c51463          	bne	a0,a2,800077b0 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    8000778c:	60a6                	ld	ra,72(sp)
    8000778e:	6406                	ld	s0,64(sp)
    80007790:	74e2                	ld	s1,56(sp)
    80007792:	7942                	ld	s2,48(sp)
    80007794:	79a2                	ld	s3,40(sp)
    80007796:	7a02                	ld	s4,32(sp)
    80007798:	6ae2                	ld	s5,24(sp)
    8000779a:	6b42                	ld	s6,16(sp)
    8000779c:	6ba2                	ld	s7,8(sp)
    8000779e:	6c02                	ld	s8,0(sp)
    800077a0:	6161                	addi	sp,sp,80
    800077a2:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800077a4:	2509                	addiw	a0,a0,2
    800077a6:	00027797          	auipc	a5,0x27
    800077aa:	8ea7ad23          	sw	a0,-1798(a5) # 8002e0a0 <nsizes>
    800077ae:	bda1                	j	80007606 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    800077b0:	85aa                	mv	a1,a0
    800077b2:	00001517          	auipc	a0,0x1
    800077b6:	6f650513          	addi	a0,a0,1782 # 80008ea8 <userret+0xe18>
    800077ba:	ffff9097          	auipc	ra,0xffff9
    800077be:	1b2080e7          	jalr	434(ra) # 8000096c <printf>
    panic("bd_init: free mem");
    800077c2:	00001517          	auipc	a0,0x1
    800077c6:	6f650513          	addi	a0,a0,1782 # 80008eb8 <userret+0xe28>
    800077ca:	ffff9097          	auipc	ra,0xffff9
    800077ce:	f8c080e7          	jalr	-116(ra) # 80000756 <panic>

00000000800077d2 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    800077d2:	1141                	addi	sp,sp,-16
    800077d4:	e422                	sd	s0,8(sp)
    800077d6:	0800                	addi	s0,sp,16
  lst->next = lst;
    800077d8:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    800077da:	e508                	sd	a0,8(a0)
}
    800077dc:	6422                	ld	s0,8(sp)
    800077de:	0141                	addi	sp,sp,16
    800077e0:	8082                	ret

00000000800077e2 <lst_empty>:

int
lst_empty(struct list *lst) {
    800077e2:	1141                	addi	sp,sp,-16
    800077e4:	e422                	sd	s0,8(sp)
    800077e6:	0800                	addi	s0,sp,16
  return lst->next == lst;
    800077e8:	611c                	ld	a5,0(a0)
    800077ea:	40a78533          	sub	a0,a5,a0
}
    800077ee:	00153513          	seqz	a0,a0
    800077f2:	6422                	ld	s0,8(sp)
    800077f4:	0141                	addi	sp,sp,16
    800077f6:	8082                	ret

00000000800077f8 <lst_remove>:

void
lst_remove(struct list *e) {
    800077f8:	1141                	addi	sp,sp,-16
    800077fa:	e422                	sd	s0,8(sp)
    800077fc:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    800077fe:	6518                	ld	a4,8(a0)
    80007800:	611c                	ld	a5,0(a0)
    80007802:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80007804:	6518                	ld	a4,8(a0)
    80007806:	e798                	sd	a4,8(a5)
}
    80007808:	6422                	ld	s0,8(sp)
    8000780a:	0141                	addi	sp,sp,16
    8000780c:	8082                	ret

000000008000780e <lst_pop>:

void*
lst_pop(struct list *lst) {
    8000780e:	1101                	addi	sp,sp,-32
    80007810:	ec06                	sd	ra,24(sp)
    80007812:	e822                	sd	s0,16(sp)
    80007814:	e426                	sd	s1,8(sp)
    80007816:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007818:	6104                	ld	s1,0(a0)
    8000781a:	00a48d63          	beq	s1,a0,80007834 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    8000781e:	8526                	mv	a0,s1
    80007820:	00000097          	auipc	ra,0x0
    80007824:	fd8080e7          	jalr	-40(ra) # 800077f8 <lst_remove>
  return (void *)p;
}
    80007828:	8526                	mv	a0,s1
    8000782a:	60e2                	ld	ra,24(sp)
    8000782c:	6442                	ld	s0,16(sp)
    8000782e:	64a2                	ld	s1,8(sp)
    80007830:	6105                	addi	sp,sp,32
    80007832:	8082                	ret
    panic("lst_pop");
    80007834:	00001517          	auipc	a0,0x1
    80007838:	69c50513          	addi	a0,a0,1692 # 80008ed0 <userret+0xe40>
    8000783c:	ffff9097          	auipc	ra,0xffff9
    80007840:	f1a080e7          	jalr	-230(ra) # 80000756 <panic>

0000000080007844 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80007844:	1141                	addi	sp,sp,-16
    80007846:	e422                	sd	s0,8(sp)
    80007848:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    8000784a:	611c                	ld	a5,0(a0)
    8000784c:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    8000784e:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007850:	611c                	ld	a5,0(a0)
    80007852:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80007854:	e10c                	sd	a1,0(a0)
}
    80007856:	6422                	ld	s0,8(sp)
    80007858:	0141                	addi	sp,sp,16
    8000785a:	8082                	ret

000000008000785c <lst_print>:

void
lst_print(struct list *lst)
{
    8000785c:	7179                	addi	sp,sp,-48
    8000785e:	f406                	sd	ra,40(sp)
    80007860:	f022                	sd	s0,32(sp)
    80007862:	ec26                	sd	s1,24(sp)
    80007864:	e84a                	sd	s2,16(sp)
    80007866:	e44e                	sd	s3,8(sp)
    80007868:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000786a:	6104                	ld	s1,0(a0)
    8000786c:	02950063          	beq	a0,s1,8000788c <lst_print+0x30>
    80007870:	892a                	mv	s2,a0
    printf(" %p", p);
    80007872:	00001997          	auipc	s3,0x1
    80007876:	66698993          	addi	s3,s3,1638 # 80008ed8 <userret+0xe48>
    8000787a:	85a6                	mv	a1,s1
    8000787c:	854e                	mv	a0,s3
    8000787e:	ffff9097          	auipc	ra,0xffff9
    80007882:	0ee080e7          	jalr	238(ra) # 8000096c <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007886:	6084                	ld	s1,0(s1)
    80007888:	fe9919e3          	bne	s2,s1,8000787a <lst_print+0x1e>
  }
  printf("\n");
    8000788c:	00001517          	auipc	a0,0x1
    80007890:	dbc50513          	addi	a0,a0,-580 # 80008648 <userret+0x5b8>
    80007894:	ffff9097          	auipc	ra,0xffff9
    80007898:	0d8080e7          	jalr	216(ra) # 8000096c <printf>
}
    8000789c:	70a2                	ld	ra,40(sp)
    8000789e:	7402                	ld	s0,32(sp)
    800078a0:	64e2                	ld	s1,24(sp)
    800078a2:	6942                	ld	s2,16(sp)
    800078a4:	69a2                	ld	s3,8(sp)
    800078a6:	6145                	addi	sp,sp,48
    800078a8:	8082                	ret

00000000800078aa <watchdogwrite>:
int watchdog_time;
struct spinlock watchdog_lock;

int
watchdogwrite(struct file *f, int user_src, uint64 src, int n)
{
    800078aa:	715d                	addi	sp,sp,-80
    800078ac:	e486                	sd	ra,72(sp)
    800078ae:	e0a2                	sd	s0,64(sp)
    800078b0:	fc26                	sd	s1,56(sp)
    800078b2:	f84a                	sd	s2,48(sp)
    800078b4:	f44e                	sd	s3,40(sp)
    800078b6:	f052                	sd	s4,32(sp)
    800078b8:	ec56                	sd	s5,24(sp)
    800078ba:	0880                	addi	s0,sp,80
    800078bc:	89ae                	mv	s3,a1
    800078be:	84b2                	mv	s1,a2
    800078c0:	8a36                	mv	s4,a3
  acquire(&watchdog_lock);
    800078c2:	00026517          	auipc	a0,0x26
    800078c6:	76e50513          	addi	a0,a0,1902 # 8002e030 <watchdog_lock>
    800078ca:	ffff9097          	auipc	ra,0xffff9
    800078ce:	3be080e7          	jalr	958(ra) # 80000c88 <acquire>

  int time = 0;
  for(int i = 0; i < n; i++){
    800078d2:	09405d63          	blez	s4,8000796c <watchdogwrite+0xc2>
    800078d6:	00148913          	addi	s2,s1,1
    800078da:	3a7d                	addiw	s4,s4,-1
    800078dc:	1a02                	slli	s4,s4,0x20
    800078de:	020a5a13          	srli	s4,s4,0x20
    800078e2:	9952                	add	s2,s2,s4
  int time = 0;
    800078e4:	4a01                	li	s4,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800078e6:	5afd                	li	s5,-1
    800078e8:	4685                	li	a3,1
    800078ea:	8626                	mv	a2,s1
    800078ec:	85ce                	mv	a1,s3
    800078ee:	fbf40513          	addi	a0,s0,-65
    800078f2:	ffffb097          	auipc	ra,0xffffb
    800078f6:	242080e7          	jalr	578(ra) # 80002b34 <either_copyin>
    800078fa:	01550763          	beq	a0,s5,80007908 <watchdogwrite+0x5e>
      break;
    time = c;
    800078fe:	fbf44a03          	lbu	s4,-65(s0)
  for(int i = 0; i < n; i++){
    80007902:	0485                	addi	s1,s1,1
    80007904:	ff2492e3          	bne	s1,s2,800078e8 <watchdogwrite+0x3e>
  }

  acquire(&tickslock);
    80007908:	00014517          	auipc	a0,0x14
    8000790c:	79050513          	addi	a0,a0,1936 # 8001c098 <tickslock>
    80007910:	ffff9097          	auipc	ra,0xffff9
    80007914:	378080e7          	jalr	888(ra) # 80000c88 <acquire>
  n = ticks - watchdog_value;
    80007918:	00026717          	auipc	a4,0x26
    8000791c:	77072703          	lw	a4,1904(a4) # 8002e088 <ticks>
    80007920:	00026797          	auipc	a5,0x26
    80007924:	78878793          	addi	a5,a5,1928 # 8002e0a8 <watchdog_value>
    80007928:	4384                	lw	s1,0(a5)
    8000792a:	409704bb          	subw	s1,a4,s1
  watchdog_value = ticks;
    8000792e:	c398                	sw	a4,0(a5)
  watchdog_time = time;
    80007930:	00026797          	auipc	a5,0x26
    80007934:	7747aa23          	sw	s4,1908(a5) # 8002e0a4 <watchdog_time>
  release(&tickslock);
    80007938:	00014517          	auipc	a0,0x14
    8000793c:	76050513          	addi	a0,a0,1888 # 8001c098 <tickslock>
    80007940:	ffff9097          	auipc	ra,0xffff9
    80007944:	594080e7          	jalr	1428(ra) # 80000ed4 <release>

  release(&watchdog_lock);
    80007948:	00026517          	auipc	a0,0x26
    8000794c:	6e850513          	addi	a0,a0,1768 # 8002e030 <watchdog_lock>
    80007950:	ffff9097          	auipc	ra,0xffff9
    80007954:	584080e7          	jalr	1412(ra) # 80000ed4 <release>
  return n;
}
    80007958:	8526                	mv	a0,s1
    8000795a:	60a6                	ld	ra,72(sp)
    8000795c:	6406                	ld	s0,64(sp)
    8000795e:	74e2                	ld	s1,56(sp)
    80007960:	7942                	ld	s2,48(sp)
    80007962:	79a2                	ld	s3,40(sp)
    80007964:	7a02                	ld	s4,32(sp)
    80007966:	6ae2                	ld	s5,24(sp)
    80007968:	6161                	addi	sp,sp,80
    8000796a:	8082                	ret
  int time = 0;
    8000796c:	4a01                	li	s4,0
    8000796e:	bf69                	j	80007908 <watchdogwrite+0x5e>

0000000080007970 <watchdoginit>:

void watchdoginit(){
    80007970:	1141                	addi	sp,sp,-16
    80007972:	e406                	sd	ra,8(sp)
    80007974:	e022                	sd	s0,0(sp)
    80007976:	0800                	addi	s0,sp,16
  initlock(&watchdog_lock, "watchdog_lock");
    80007978:	00001597          	auipc	a1,0x1
    8000797c:	56858593          	addi	a1,a1,1384 # 80008ee0 <userret+0xe50>
    80007980:	00026517          	auipc	a0,0x26
    80007984:	6b050513          	addi	a0,a0,1712 # 8002e030 <watchdog_lock>
    80007988:	ffff9097          	auipc	ra,0xffff9
    8000798c:	196080e7          	jalr	406(ra) # 80000b1e <initlock>
  watchdog_time = 0;
    80007990:	00026797          	auipc	a5,0x26
    80007994:	7007aa23          	sw	zero,1812(a5) # 8002e0a4 <watchdog_time>


  devsw[WATCHDOG].read = 0;
    80007998:	0001f797          	auipc	a5,0x1f
    8000799c:	20078793          	addi	a5,a5,512 # 80026b98 <devsw>
    800079a0:	0207b023          	sd	zero,32(a5)
  devsw[WATCHDOG].write = watchdogwrite;
    800079a4:	00000717          	auipc	a4,0x0
    800079a8:	f0670713          	addi	a4,a4,-250 # 800078aa <watchdogwrite>
    800079ac:	f798                	sd	a4,40(a5)
}
    800079ae:	60a2                	ld	ra,8(sp)
    800079b0:	6402                	ld	s0,0(sp)
    800079b2:	0141                	addi	sp,sp,16
    800079b4:	8082                	ret
	...

0000000080008000 <trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
