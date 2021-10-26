
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
    80000060:	44478793          	addi	a5,a5,1092 # 800064a0 <timervec>
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
    80000166:	6c0080e7          	jalr	1728(ra) # 80002822 <sleep>
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
    800001d4:	652080e7          	jalr	1618(ra) # 80002822 <sleep>
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
    80000212:	876080e7          	jalr	-1930(ra) # 80002a84 <either_copyout>
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
    8000033e:	4e8080e7          	jalr	1256(ra) # 80002822 <sleep>
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
    8000038c:	752080e7          	jalr	1874(ra) # 80002ada <either_copyin>
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
    800004de:	656080e7          	jalr	1622(ra) # 80002b30 <procdump>
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
    80000506:	6ea080e7          	jalr	1770(ra) # 80002bec <priodump>
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
    8000057c:	430080e7          	jalr	1072(ra) # 800029a8 <wakeup>
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
    80000604:	3a8080e7          	jalr	936(ra) # 800029a8 <wakeup>
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
    80000ae0:	a6e080e7          	jalr	-1426(ra) # 8000754a <bd_init>
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
    80000af8:	598080e7          	jalr	1432(ra) # 8000708c <bd_free>
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
    80000b12:	392080e7          	jalr	914(ra) # 80006ea0 <bd_malloc>
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
    80000d6c:	dc8080e7          	jalr	-568(ra) # 80002b30 <procdump>
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
    80000d9c:	d98080e7          	jalr	-616(ra) # 80002b30 <procdump>
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
    80000f6c:	300080e7          	jalr	768(ra) # 80003268 <argint>
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
    800012be:	be6080e7          	jalr	-1050(ra) # 80006ea0 <bd_malloc>
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
    80001346:	b5e080e7          	jalr	-1186(ra) # 80006ea0 <bd_malloc>
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
    800013b2:	9f4080e7          	jalr	-1548(ra) # 80002da2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800013b6:	00005097          	auipc	ra,0x5
    800013ba:	12a080e7          	jalr	298(ra) # 800064e0 <plicinithart>
  }

  scheduler();        
    800013be:	00001097          	auipc	ra,0x1
    800013c2:	148080e7          	jalr	328(ra) # 80002506 <scheduler>
    consoleinit();
    800013c6:	fffff097          	auipc	ra,0xfffff
    800013ca:	244080e7          	jalr	580(ra) # 8000060a <consoleinit>
    watchdoginit();
    800013ce:	00006097          	auipc	ra,0x6
    800013d2:	552080e7          	jalr	1362(ra) # 80007920 <watchdoginit>
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
    80001432:	94c080e7          	jalr	-1716(ra) # 80002d7a <trapinit>
    trapinithart();  // install kernel trap vector
    80001436:	00002097          	auipc	ra,0x2
    8000143a:	96c080e7          	jalr	-1684(ra) # 80002da2 <trapinithart>
    plicinit();      // set up interrupt controller
    8000143e:	00005097          	auipc	ra,0x5
    80001442:	08c080e7          	jalr	140(ra) # 800064ca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001446:	00005097          	auipc	ra,0x5
    8000144a:	09a080e7          	jalr	154(ra) # 800064e0 <plicinithart>
    binit();         // buffer cache
    8000144e:	00002097          	auipc	ra,0x2
    80001452:	10a080e7          	jalr	266(ra) # 80003558 <binit>
    iinit();         // inode cache
    80001456:	00002097          	auipc	ra,0x2
    8000145a:	79e080e7          	jalr	1950(ra) # 80003bf4 <iinit>
    fileinit();      // file table
    8000145e:	00004097          	auipc	ra,0x4
    80001462:	804080e7          	jalr	-2044(ra) # 80004c62 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80001466:	4501                	li	a0,0
    80001468:	00005097          	auipc	ra,0x5
    8000146c:	19a080e7          	jalr	410(ra) # 80006602 <virtio_disk_init>
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
    80001dc0:	0e4080e7          	jalr	228(ra) # 80006ea0 <bd_malloc>
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
    80001e48:	248080e7          	jalr	584(ra) # 8000708c <bd_free>
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
    80001ff0:	06c7a783          	lw	a5,108(a5) # 8000a058 <first.1787>
    80001ff4:	eb89                	bnez	a5,80002006 <forkret+0x32>
  usertrapret();
    80001ff6:	00001097          	auipc	ra,0x1
    80001ffa:	dc4080e7          	jalr	-572(ra) # 80002dba <usertrapret>
}
    80001ffe:	60a2                	ld	ra,8(sp)
    80002000:	6402                	ld	s0,0(sp)
    80002002:	0141                	addi	sp,sp,16
    80002004:	8082                	ret
    first = 0;
    80002006:	00008797          	auipc	a5,0x8
    8000200a:	0407a923          	sw	zero,82(a5) # 8000a058 <first.1787>
    fsinit(minor(ROOTDEV));
    8000200e:	4501                	li	a0,0
    80002010:	00002097          	auipc	ra,0x2
    80002014:	b64080e7          	jalr	-1180(ra) # 80003b74 <fsinit>
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
    800021f0:	ea0080e7          	jalr	-352(ra) # 8000708c <bd_free>
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
    800022a2:	2d8080e7          	jalr	728(ra) # 80004576 <namei>
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
    80002404:	8f4080e7          	jalr	-1804(ra) # 80004cf4 <filedup>
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
    80002426:	98c080e7          	jalr	-1652(ra) # 80003dae <idup>
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

0000000080002506 <scheduler>:
{
    80002506:	715d                	addi	sp,sp,-80
    80002508:	e486                	sd	ra,72(sp)
    8000250a:	e0a2                	sd	s0,64(sp)
    8000250c:	fc26                	sd	s1,56(sp)
    8000250e:	f84a                	sd	s2,48(sp)
    80002510:	f44e                	sd	s3,40(sp)
    80002512:	f052                	sd	s4,32(sp)
    80002514:	ec56                	sd	s5,24(sp)
    80002516:	e85a                	sd	s6,16(sp)
    80002518:	e45e                	sd	s7,8(sp)
    8000251a:	e062                	sd	s8,0(sp)
    8000251c:	0880                	addi	s0,sp,80
    8000251e:	8792                	mv	a5,tp
  int id = r_tp();
    80002520:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002522:	00779b93          	slli	s7,a5,0x7
    80002526:	00013717          	auipc	a4,0x13
    8000252a:	4c270713          	addi	a4,a4,1218 # 800159e8 <prio>
    8000252e:	975e                	add	a4,a4,s7
    80002530:	0a073823          	sd	zero,176(a4)
        swtch(&c->scheduler, &p->context);
    80002534:	00013717          	auipc	a4,0x13
    80002538:	56c70713          	addi	a4,a4,1388 # 80015aa0 <cpus+0x8>
    8000253c:	9bba                	add	s7,s7,a4
        p->state = RUNNING;
    8000253e:	4c0d                	li	s8,3
        c->proc = p;
    80002540:	079e                	slli	a5,a5,0x7
    80002542:	00013917          	auipc	s2,0x13
    80002546:	4a690913          	addi	s2,s2,1190 # 800159e8 <prio>
    8000254a:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000254c:	0001aa17          	auipc	s4,0x1a
    80002550:	b4ca0a13          	addi	s4,s4,-1204 # 8001c098 <tickslock>
    80002554:	a0b9                	j	800025a2 <scheduler+0x9c>
        p->state = RUNNING;
    80002556:	0384a823          	sw	s8,48(s1)
        c->proc = p;
    8000255a:	0a993823          	sd	s1,176(s2)
        swtch(&c->scheduler, &p->context);
    8000255e:	07848593          	addi	a1,s1,120
    80002562:	855e                	mv	a0,s7
    80002564:	00000097          	auipc	ra,0x0
    80002568:	712080e7          	jalr	1810(ra) # 80002c76 <swtch>
        c->proc = 0;
    8000256c:	0a093823          	sd	zero,176(s2)
        found = 1;
    80002570:	8ada                	mv	s5,s6
      c->intena = 0;
    80002572:	12092623          	sw	zero,300(s2)
      release(&p->lock);
    80002576:	8526                	mv	a0,s1
    80002578:	fffff097          	auipc	ra,0xfffff
    8000257c:	95c080e7          	jalr	-1700(ra) # 80000ed4 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002580:	18848493          	addi	s1,s1,392
    80002584:	01448b63          	beq	s1,s4,8000259a <scheduler+0x94>
      acquire(&p->lock);
    80002588:	8526                	mv	a0,s1
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	6fe080e7          	jalr	1790(ra) # 80000c88 <acquire>
      if(p->state == RUNNABLE) {
    80002592:	589c                	lw	a5,48(s1)
    80002594:	fd379fe3          	bne	a5,s3,80002572 <scheduler+0x6c>
    80002598:	bf7d                	j	80002556 <scheduler+0x50>
    if(found == 0){
    8000259a:	000a9463          	bnez	s5,800025a2 <scheduler+0x9c>
      asm volatile("wfi");
    8000259e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025aa:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025ae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800025b2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025b4:	10079073          	csrw	sstatus,a5
    int found = 0;
    800025b8:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800025ba:	00014497          	auipc	s1,0x14
    800025be:	8de48493          	addi	s1,s1,-1826 # 80015e98 <proc>
      if(p->state == RUNNABLE) {
    800025c2:	4989                	li	s3,2
        found = 1;
    800025c4:	4b05                	li	s6,1
    800025c6:	b7c9                	j	80002588 <scheduler+0x82>

00000000800025c8 <sched>:
{
    800025c8:	7179                	addi	sp,sp,-48
    800025ca:	f406                	sd	ra,40(sp)
    800025cc:	f022                	sd	s0,32(sp)
    800025ce:	ec26                	sd	s1,24(sp)
    800025d0:	e84a                	sd	s2,16(sp)
    800025d2:	e44e                	sd	s3,8(sp)
    800025d4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800025d6:	00000097          	auipc	ra,0x0
    800025da:	9c6080e7          	jalr	-1594(ra) # 80001f9c <myproc>
    800025de:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800025e0:	ffffe097          	auipc	ra,0xffffe
    800025e4:	62a080e7          	jalr	1578(ra) # 80000c0a <holding>
    800025e8:	c93d                	beqz	a0,8000265e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025ea:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800025ec:	2781                	sext.w	a5,a5
    800025ee:	079e                	slli	a5,a5,0x7
    800025f0:	00013717          	auipc	a4,0x13
    800025f4:	3f870713          	addi	a4,a4,1016 # 800159e8 <prio>
    800025f8:	97ba                	add	a5,a5,a4
    800025fa:	1287a703          	lw	a4,296(a5)
    800025fe:	4785                	li	a5,1
    80002600:	06f71763          	bne	a4,a5,8000266e <sched+0xa6>
  if(p->state == RUNNING)
    80002604:	5898                	lw	a4,48(s1)
    80002606:	478d                	li	a5,3
    80002608:	06f70b63          	beq	a4,a5,8000267e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000260c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002610:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002612:	efb5                	bnez	a5,8000268e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002614:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002616:	00013917          	auipc	s2,0x13
    8000261a:	3d290913          	addi	s2,s2,978 # 800159e8 <prio>
    8000261e:	2781                	sext.w	a5,a5
    80002620:	079e                	slli	a5,a5,0x7
    80002622:	97ca                	add	a5,a5,s2
    80002624:	12c7a983          	lw	s3,300(a5)
    80002628:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    8000262a:	2781                	sext.w	a5,a5
    8000262c:	079e                	slli	a5,a5,0x7
    8000262e:	00013597          	auipc	a1,0x13
    80002632:	47258593          	addi	a1,a1,1138 # 80015aa0 <cpus+0x8>
    80002636:	95be                	add	a1,a1,a5
    80002638:	07848513          	addi	a0,s1,120
    8000263c:	00000097          	auipc	ra,0x0
    80002640:	63a080e7          	jalr	1594(ra) # 80002c76 <swtch>
    80002644:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002646:	2781                	sext.w	a5,a5
    80002648:	079e                	slli	a5,a5,0x7
    8000264a:	97ca                	add	a5,a5,s2
    8000264c:	1337a623          	sw	s3,300(a5)
}
    80002650:	70a2                	ld	ra,40(sp)
    80002652:	7402                	ld	s0,32(sp)
    80002654:	64e2                	ld	s1,24(sp)
    80002656:	6942                	ld	s2,16(sp)
    80002658:	69a2                	ld	s3,8(sp)
    8000265a:	6145                	addi	sp,sp,48
    8000265c:	8082                	ret
    panic("sched p->lock");
    8000265e:	00006517          	auipc	a0,0x6
    80002662:	f6250513          	addi	a0,a0,-158 # 800085c0 <userret+0x530>
    80002666:	ffffe097          	auipc	ra,0xffffe
    8000266a:	0f0080e7          	jalr	240(ra) # 80000756 <panic>
    panic("sched locks");
    8000266e:	00006517          	auipc	a0,0x6
    80002672:	f6250513          	addi	a0,a0,-158 # 800085d0 <userret+0x540>
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	0e0080e7          	jalr	224(ra) # 80000756 <panic>
    panic("sched running");
    8000267e:	00006517          	auipc	a0,0x6
    80002682:	f6250513          	addi	a0,a0,-158 # 800085e0 <userret+0x550>
    80002686:	ffffe097          	auipc	ra,0xffffe
    8000268a:	0d0080e7          	jalr	208(ra) # 80000756 <panic>
    panic("sched interruptible");
    8000268e:	00006517          	auipc	a0,0x6
    80002692:	f6250513          	addi	a0,a0,-158 # 800085f0 <userret+0x560>
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	0c0080e7          	jalr	192(ra) # 80000756 <panic>

000000008000269e <exit>:
{
    8000269e:	7179                	addi	sp,sp,-48
    800026a0:	f406                	sd	ra,40(sp)
    800026a2:	f022                	sd	s0,32(sp)
    800026a4:	ec26                	sd	s1,24(sp)
    800026a6:	e84a                	sd	s2,16(sp)
    800026a8:	e44e                	sd	s3,8(sp)
    800026aa:	e052                	sd	s4,0(sp)
    800026ac:	1800                	addi	s0,sp,48
    800026ae:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800026b0:	00000097          	auipc	ra,0x0
    800026b4:	8ec080e7          	jalr	-1812(ra) # 80001f9c <myproc>
    800026b8:	892a                	mv	s2,a0
  if(p == initproc)
    800026ba:	0002c797          	auipc	a5,0x2c
    800026be:	9c67b783          	ld	a5,-1594(a5) # 8002e080 <initproc>
    800026c2:	0e850493          	addi	s1,a0,232
    800026c6:	16850993          	addi	s3,a0,360
    800026ca:	02a79363          	bne	a5,a0,800026f0 <exit+0x52>
    panic("init exiting");
    800026ce:	00006517          	auipc	a0,0x6
    800026d2:	f3a50513          	addi	a0,a0,-198 # 80008608 <userret+0x578>
    800026d6:	ffffe097          	auipc	ra,0xffffe
    800026da:	080080e7          	jalr	128(ra) # 80000756 <panic>
      fileclose(f);
    800026de:	00002097          	auipc	ra,0x2
    800026e2:	668080e7          	jalr	1640(ra) # 80004d46 <fileclose>
      p->ofile[fd] = 0;
    800026e6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800026ea:	04a1                	addi	s1,s1,8
    800026ec:	01348563          	beq	s1,s3,800026f6 <exit+0x58>
    if(p->ofile[fd]){
    800026f0:	6088                	ld	a0,0(s1)
    800026f2:	f575                	bnez	a0,800026de <exit+0x40>
    800026f4:	bfdd                	j	800026ea <exit+0x4c>
  begin_op(ROOTDEV);
    800026f6:	4501                	li	a0,0
    800026f8:	00002097          	auipc	ra,0x2
    800026fc:	0c4080e7          	jalr	196(ra) # 800047bc <begin_op>
  iput(p->cwd);
    80002700:	16893503          	ld	a0,360(s2)
    80002704:	00001097          	auipc	ra,0x1
    80002708:	7f6080e7          	jalr	2038(ra) # 80003efa <iput>
  end_op(ROOTDEV);
    8000270c:	4501                	li	a0,0
    8000270e:	00002097          	auipc	ra,0x2
    80002712:	15a080e7          	jalr	346(ra) # 80004868 <end_op>
  p->cwd = 0;
    80002716:	16093423          	sd	zero,360(s2)
  acquire(&initproc->lock);
    8000271a:	0002c497          	auipc	s1,0x2c
    8000271e:	96648493          	addi	s1,s1,-1690 # 8002e080 <initproc>
    80002722:	6088                	ld	a0,0(s1)
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	564080e7          	jalr	1380(ra) # 80000c88 <acquire>
  wakeup1(initproc);
    8000272c:	6088                	ld	a0,0(s1)
    8000272e:	fffff097          	auipc	ra,0xfffff
    80002732:	63c080e7          	jalr	1596(ra) # 80001d6a <wakeup1>
  release(&initproc->lock);
    80002736:	6088                	ld	a0,0(s1)
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	79c080e7          	jalr	1948(ra) # 80000ed4 <release>
  acquire(&prio_lock);
    80002740:	00013497          	auipc	s1,0x13
    80002744:	2f848493          	addi	s1,s1,760 # 80015a38 <prio_lock>
    80002748:	8526                	mv	a0,s1
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	53e080e7          	jalr	1342(ra) # 80000c88 <acquire>
  acquire(&p->lock);
    80002752:	854a                	mv	a0,s2
    80002754:	ffffe097          	auipc	ra,0xffffe
    80002758:	534080e7          	jalr	1332(ra) # 80000c88 <acquire>
  remove_from_prio_queue(p);
    8000275c:	854a                	mv	a0,s2
    8000275e:	fffff097          	auipc	ra,0xfffff
    80002762:	6a2080e7          	jalr	1698(ra) # 80001e00 <remove_from_prio_queue>
  release(&p->lock);
    80002766:	854a                	mv	a0,s2
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	76c080e7          	jalr	1900(ra) # 80000ed4 <release>
  release(&prio_lock);
    80002770:	8526                	mv	a0,s1
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	762080e7          	jalr	1890(ra) # 80000ed4 <release>
  acquire(&p->lock);
    8000277a:	854a                	mv	a0,s2
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	50c080e7          	jalr	1292(ra) # 80000c88 <acquire>
  struct proc *original_parent = p->parent;
    80002784:	03893483          	ld	s1,56(s2)
  release(&p->lock);
    80002788:	854a                	mv	a0,s2
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	74a080e7          	jalr	1866(ra) # 80000ed4 <release>
  acquire(&original_parent->lock);
    80002792:	8526                	mv	a0,s1
    80002794:	ffffe097          	auipc	ra,0xffffe
    80002798:	4f4080e7          	jalr	1268(ra) # 80000c88 <acquire>
  acquire(&p->lock);
    8000279c:	854a                	mv	a0,s2
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	4ea080e7          	jalr	1258(ra) # 80000c88 <acquire>
  reparent(p);
    800027a6:	854a                	mv	a0,s2
    800027a8:	00000097          	auipc	ra,0x0
    800027ac:	cf8080e7          	jalr	-776(ra) # 800024a0 <reparent>
  wakeup1(original_parent);
    800027b0:	8526                	mv	a0,s1
    800027b2:	fffff097          	auipc	ra,0xfffff
    800027b6:	5b8080e7          	jalr	1464(ra) # 80001d6a <wakeup1>
  p->xstate = status;
    800027ba:	05492623          	sw	s4,76(s2)
  p->state = ZOMBIE;
    800027be:	4791                	li	a5,4
    800027c0:	02f92823          	sw	a5,48(s2)
  release(&original_parent->lock);
    800027c4:	8526                	mv	a0,s1
    800027c6:	ffffe097          	auipc	ra,0xffffe
    800027ca:	70e080e7          	jalr	1806(ra) # 80000ed4 <release>
  sched();
    800027ce:	00000097          	auipc	ra,0x0
    800027d2:	dfa080e7          	jalr	-518(ra) # 800025c8 <sched>
  panic("zombie exit");
    800027d6:	00006517          	auipc	a0,0x6
    800027da:	e4250513          	addi	a0,a0,-446 # 80008618 <userret+0x588>
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	f78080e7          	jalr	-136(ra) # 80000756 <panic>

00000000800027e6 <yield>:
{
    800027e6:	1101                	addi	sp,sp,-32
    800027e8:	ec06                	sd	ra,24(sp)
    800027ea:	e822                	sd	s0,16(sp)
    800027ec:	e426                	sd	s1,8(sp)
    800027ee:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800027f0:	fffff097          	auipc	ra,0xfffff
    800027f4:	7ac080e7          	jalr	1964(ra) # 80001f9c <myproc>
    800027f8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	48e080e7          	jalr	1166(ra) # 80000c88 <acquire>
  p->state = RUNNABLE;
    80002802:	4789                	li	a5,2
    80002804:	d89c                	sw	a5,48(s1)
  sched();
    80002806:	00000097          	auipc	ra,0x0
    8000280a:	dc2080e7          	jalr	-574(ra) # 800025c8 <sched>
  release(&p->lock);
    8000280e:	8526                	mv	a0,s1
    80002810:	ffffe097          	auipc	ra,0xffffe
    80002814:	6c4080e7          	jalr	1732(ra) # 80000ed4 <release>
}
    80002818:	60e2                	ld	ra,24(sp)
    8000281a:	6442                	ld	s0,16(sp)
    8000281c:	64a2                	ld	s1,8(sp)
    8000281e:	6105                	addi	sp,sp,32
    80002820:	8082                	ret

0000000080002822 <sleep>:
{
    80002822:	7179                	addi	sp,sp,-48
    80002824:	f406                	sd	ra,40(sp)
    80002826:	f022                	sd	s0,32(sp)
    80002828:	ec26                	sd	s1,24(sp)
    8000282a:	e84a                	sd	s2,16(sp)
    8000282c:	e44e                	sd	s3,8(sp)
    8000282e:	1800                	addi	s0,sp,48
    80002830:	89aa                	mv	s3,a0
    80002832:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002834:	fffff097          	auipc	ra,0xfffff
    80002838:	768080e7          	jalr	1896(ra) # 80001f9c <myproc>
    8000283c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000283e:	05250663          	beq	a0,s2,8000288a <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002842:	ffffe097          	auipc	ra,0xffffe
    80002846:	446080e7          	jalr	1094(ra) # 80000c88 <acquire>
    release(lk);
    8000284a:	854a                	mv	a0,s2
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	688080e7          	jalr	1672(ra) # 80000ed4 <release>
  p->chan = chan;
    80002854:	0534b023          	sd	s3,64(s1)
  p->state = SLEEPING;
    80002858:	4785                	li	a5,1
    8000285a:	d89c                	sw	a5,48(s1)
  sched();
    8000285c:	00000097          	auipc	ra,0x0
    80002860:	d6c080e7          	jalr	-660(ra) # 800025c8 <sched>
  p->chan = 0;
    80002864:	0404b023          	sd	zero,64(s1)
    release(&p->lock);
    80002868:	8526                	mv	a0,s1
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	66a080e7          	jalr	1642(ra) # 80000ed4 <release>
    acquire(lk);
    80002872:	854a                	mv	a0,s2
    80002874:	ffffe097          	auipc	ra,0xffffe
    80002878:	414080e7          	jalr	1044(ra) # 80000c88 <acquire>
}
    8000287c:	70a2                	ld	ra,40(sp)
    8000287e:	7402                	ld	s0,32(sp)
    80002880:	64e2                	ld	s1,24(sp)
    80002882:	6942                	ld	s2,16(sp)
    80002884:	69a2                	ld	s3,8(sp)
    80002886:	6145                	addi	sp,sp,48
    80002888:	8082                	ret
  p->chan = chan;
    8000288a:	05353023          	sd	s3,64(a0)
  p->state = SLEEPING;
    8000288e:	4785                	li	a5,1
    80002890:	d91c                	sw	a5,48(a0)
  sched();
    80002892:	00000097          	auipc	ra,0x0
    80002896:	d36080e7          	jalr	-714(ra) # 800025c8 <sched>
  p->chan = 0;
    8000289a:	0404b023          	sd	zero,64(s1)
  if(lk != &p->lock){
    8000289e:	bff9                	j	8000287c <sleep+0x5a>

00000000800028a0 <wait>:
{
    800028a0:	715d                	addi	sp,sp,-80
    800028a2:	e486                	sd	ra,72(sp)
    800028a4:	e0a2                	sd	s0,64(sp)
    800028a6:	fc26                	sd	s1,56(sp)
    800028a8:	f84a                	sd	s2,48(sp)
    800028aa:	f44e                	sd	s3,40(sp)
    800028ac:	f052                	sd	s4,32(sp)
    800028ae:	ec56                	sd	s5,24(sp)
    800028b0:	e85a                	sd	s6,16(sp)
    800028b2:	e45e                	sd	s7,8(sp)
    800028b4:	e062                	sd	s8,0(sp)
    800028b6:	0880                	addi	s0,sp,80
    800028b8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800028ba:	fffff097          	auipc	ra,0xfffff
    800028be:	6e2080e7          	jalr	1762(ra) # 80001f9c <myproc>
    800028c2:	892a                	mv	s2,a0
  acquire(&p->lock);
    800028c4:	8c2a                	mv	s8,a0
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	3c2080e7          	jalr	962(ra) # 80000c88 <acquire>
    havekids = 0;
    800028ce:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800028d0:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800028d2:	00019997          	auipc	s3,0x19
    800028d6:	7c698993          	addi	s3,s3,1990 # 8001c098 <tickslock>
        havekids = 1;
    800028da:	4a85                	li	s5,1
    havekids = 0;
    800028dc:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800028de:	00013497          	auipc	s1,0x13
    800028e2:	5ba48493          	addi	s1,s1,1466 # 80015e98 <proc>
    800028e6:	a08d                	j	80002948 <wait+0xa8>
          pid = np->pid;
    800028e8:	0504a983          	lw	s3,80(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800028ec:	000b0e63          	beqz	s6,80002908 <wait+0x68>
    800028f0:	4691                	li	a3,4
    800028f2:	04c48613          	addi	a2,s1,76
    800028f6:	85da                	mv	a1,s6
    800028f8:	06893503          	ld	a0,104(s2)
    800028fc:	fffff097          	auipc	ra,0xfffff
    80002900:	2a2080e7          	jalr	674(ra) # 80001b9e <copyout>
    80002904:	02054263          	bltz	a0,80002928 <wait+0x88>
          freeproc(np);
    80002908:	8526                	mv	a0,s1
    8000290a:	00000097          	auipc	ra,0x0
    8000290e:	8b2080e7          	jalr	-1870(ra) # 800021bc <freeproc>
          release(&np->lock);
    80002912:	8526                	mv	a0,s1
    80002914:	ffffe097          	auipc	ra,0xffffe
    80002918:	5c0080e7          	jalr	1472(ra) # 80000ed4 <release>
          release(&p->lock);
    8000291c:	854a                	mv	a0,s2
    8000291e:	ffffe097          	auipc	ra,0xffffe
    80002922:	5b6080e7          	jalr	1462(ra) # 80000ed4 <release>
          return pid;
    80002926:	a8a9                	j	80002980 <wait+0xe0>
            release(&np->lock);
    80002928:	8526                	mv	a0,s1
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	5aa080e7          	jalr	1450(ra) # 80000ed4 <release>
            release(&p->lock);
    80002932:	854a                	mv	a0,s2
    80002934:	ffffe097          	auipc	ra,0xffffe
    80002938:	5a0080e7          	jalr	1440(ra) # 80000ed4 <release>
            return -1;
    8000293c:	59fd                	li	s3,-1
    8000293e:	a089                	j	80002980 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002940:	18848493          	addi	s1,s1,392
    80002944:	03348463          	beq	s1,s3,8000296c <wait+0xcc>
      if(np->parent == p){
    80002948:	7c9c                	ld	a5,56(s1)
    8000294a:	ff279be3          	bne	a5,s2,80002940 <wait+0xa0>
        acquire(&np->lock);
    8000294e:	8526                	mv	a0,s1
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	338080e7          	jalr	824(ra) # 80000c88 <acquire>
        if(np->state == ZOMBIE){
    80002958:	589c                	lw	a5,48(s1)
    8000295a:	f94787e3          	beq	a5,s4,800028e8 <wait+0x48>
        release(&np->lock);
    8000295e:	8526                	mv	a0,s1
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	574080e7          	jalr	1396(ra) # 80000ed4 <release>
        havekids = 1;
    80002968:	8756                	mv	a4,s5
    8000296a:	bfd9                	j	80002940 <wait+0xa0>
    if(!havekids || p->killed){
    8000296c:	c701                	beqz	a4,80002974 <wait+0xd4>
    8000296e:	04892783          	lw	a5,72(s2)
    80002972:	c785                	beqz	a5,8000299a <wait+0xfa>
      release(&p->lock);
    80002974:	854a                	mv	a0,s2
    80002976:	ffffe097          	auipc	ra,0xffffe
    8000297a:	55e080e7          	jalr	1374(ra) # 80000ed4 <release>
      return -1;
    8000297e:	59fd                	li	s3,-1
}
    80002980:	854e                	mv	a0,s3
    80002982:	60a6                	ld	ra,72(sp)
    80002984:	6406                	ld	s0,64(sp)
    80002986:	74e2                	ld	s1,56(sp)
    80002988:	7942                	ld	s2,48(sp)
    8000298a:	79a2                	ld	s3,40(sp)
    8000298c:	7a02                	ld	s4,32(sp)
    8000298e:	6ae2                	ld	s5,24(sp)
    80002990:	6b42                	ld	s6,16(sp)
    80002992:	6ba2                	ld	s7,8(sp)
    80002994:	6c02                	ld	s8,0(sp)
    80002996:	6161                	addi	sp,sp,80
    80002998:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000299a:	85e2                	mv	a1,s8
    8000299c:	854a                	mv	a0,s2
    8000299e:	00000097          	auipc	ra,0x0
    800029a2:	e84080e7          	jalr	-380(ra) # 80002822 <sleep>
    havekids = 0;
    800029a6:	bf1d                	j	800028dc <wait+0x3c>

00000000800029a8 <wakeup>:
{
    800029a8:	7139                	addi	sp,sp,-64
    800029aa:	fc06                	sd	ra,56(sp)
    800029ac:	f822                	sd	s0,48(sp)
    800029ae:	f426                	sd	s1,40(sp)
    800029b0:	f04a                	sd	s2,32(sp)
    800029b2:	ec4e                	sd	s3,24(sp)
    800029b4:	e852                	sd	s4,16(sp)
    800029b6:	e456                	sd	s5,8(sp)
    800029b8:	0080                	addi	s0,sp,64
    800029ba:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800029bc:	00013497          	auipc	s1,0x13
    800029c0:	4dc48493          	addi	s1,s1,1244 # 80015e98 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800029c4:	4985                	li	s3,1
      p->state = RUNNABLE;
    800029c6:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800029c8:	00019917          	auipc	s2,0x19
    800029cc:	6d090913          	addi	s2,s2,1744 # 8001c098 <tickslock>
    800029d0:	a821                	j	800029e8 <wakeup+0x40>
      p->state = RUNNABLE;
    800029d2:	0354a823          	sw	s5,48(s1)
    release(&p->lock);
    800029d6:	8526                	mv	a0,s1
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	4fc080e7          	jalr	1276(ra) # 80000ed4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800029e0:	18848493          	addi	s1,s1,392
    800029e4:	01248e63          	beq	s1,s2,80002a00 <wakeup+0x58>
    acquire(&p->lock);
    800029e8:	8526                	mv	a0,s1
    800029ea:	ffffe097          	auipc	ra,0xffffe
    800029ee:	29e080e7          	jalr	670(ra) # 80000c88 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800029f2:	589c                	lw	a5,48(s1)
    800029f4:	ff3791e3          	bne	a5,s3,800029d6 <wakeup+0x2e>
    800029f8:	60bc                	ld	a5,64(s1)
    800029fa:	fd479ee3          	bne	a5,s4,800029d6 <wakeup+0x2e>
    800029fe:	bfd1                	j	800029d2 <wakeup+0x2a>
}
    80002a00:	70e2                	ld	ra,56(sp)
    80002a02:	7442                	ld	s0,48(sp)
    80002a04:	74a2                	ld	s1,40(sp)
    80002a06:	7902                	ld	s2,32(sp)
    80002a08:	69e2                	ld	s3,24(sp)
    80002a0a:	6a42                	ld	s4,16(sp)
    80002a0c:	6aa2                	ld	s5,8(sp)
    80002a0e:	6121                	addi	sp,sp,64
    80002a10:	8082                	ret

0000000080002a12 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002a12:	7179                	addi	sp,sp,-48
    80002a14:	f406                	sd	ra,40(sp)
    80002a16:	f022                	sd	s0,32(sp)
    80002a18:	ec26                	sd	s1,24(sp)
    80002a1a:	e84a                	sd	s2,16(sp)
    80002a1c:	e44e                	sd	s3,8(sp)
    80002a1e:	1800                	addi	s0,sp,48
    80002a20:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002a22:	00013497          	auipc	s1,0x13
    80002a26:	47648493          	addi	s1,s1,1142 # 80015e98 <proc>
    80002a2a:	00019997          	auipc	s3,0x19
    80002a2e:	66e98993          	addi	s3,s3,1646 # 8001c098 <tickslock>
    acquire(&p->lock);
    80002a32:	8526                	mv	a0,s1
    80002a34:	ffffe097          	auipc	ra,0xffffe
    80002a38:	254080e7          	jalr	596(ra) # 80000c88 <acquire>
    if(p->pid == pid){
    80002a3c:	48bc                	lw	a5,80(s1)
    80002a3e:	01278d63          	beq	a5,s2,80002a58 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002a42:	8526                	mv	a0,s1
    80002a44:	ffffe097          	auipc	ra,0xffffe
    80002a48:	490080e7          	jalr	1168(ra) # 80000ed4 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a4c:	18848493          	addi	s1,s1,392
    80002a50:	ff3491e3          	bne	s1,s3,80002a32 <kill+0x20>
  }
  return -1;
    80002a54:	557d                	li	a0,-1
    80002a56:	a829                	j	80002a70 <kill+0x5e>
      p->killed = 1;
    80002a58:	4785                	li	a5,1
    80002a5a:	c4bc                	sw	a5,72(s1)
      if(p->state == SLEEPING){
    80002a5c:	5898                	lw	a4,48(s1)
    80002a5e:	4785                	li	a5,1
    80002a60:	00f70f63          	beq	a4,a5,80002a7e <kill+0x6c>
      release(&p->lock);
    80002a64:	8526                	mv	a0,s1
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	46e080e7          	jalr	1134(ra) # 80000ed4 <release>
      return 0;
    80002a6e:	4501                	li	a0,0
}
    80002a70:	70a2                	ld	ra,40(sp)
    80002a72:	7402                	ld	s0,32(sp)
    80002a74:	64e2                	ld	s1,24(sp)
    80002a76:	6942                	ld	s2,16(sp)
    80002a78:	69a2                	ld	s3,8(sp)
    80002a7a:	6145                	addi	sp,sp,48
    80002a7c:	8082                	ret
        p->state = RUNNABLE;
    80002a7e:	4789                	li	a5,2
    80002a80:	d89c                	sw	a5,48(s1)
    80002a82:	b7cd                	j	80002a64 <kill+0x52>

0000000080002a84 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a84:	7179                	addi	sp,sp,-48
    80002a86:	f406                	sd	ra,40(sp)
    80002a88:	f022                	sd	s0,32(sp)
    80002a8a:	ec26                	sd	s1,24(sp)
    80002a8c:	e84a                	sd	s2,16(sp)
    80002a8e:	e44e                	sd	s3,8(sp)
    80002a90:	e052                	sd	s4,0(sp)
    80002a92:	1800                	addi	s0,sp,48
    80002a94:	84aa                	mv	s1,a0
    80002a96:	892e                	mv	s2,a1
    80002a98:	89b2                	mv	s3,a2
    80002a9a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a9c:	fffff097          	auipc	ra,0xfffff
    80002aa0:	500080e7          	jalr	1280(ra) # 80001f9c <myproc>
  if(user_dst){
    80002aa4:	c08d                	beqz	s1,80002ac6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002aa6:	86d2                	mv	a3,s4
    80002aa8:	864e                	mv	a2,s3
    80002aaa:	85ca                	mv	a1,s2
    80002aac:	7528                	ld	a0,104(a0)
    80002aae:	fffff097          	auipc	ra,0xfffff
    80002ab2:	0f0080e7          	jalr	240(ra) # 80001b9e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002ab6:	70a2                	ld	ra,40(sp)
    80002ab8:	7402                	ld	s0,32(sp)
    80002aba:	64e2                	ld	s1,24(sp)
    80002abc:	6942                	ld	s2,16(sp)
    80002abe:	69a2                	ld	s3,8(sp)
    80002ac0:	6a02                	ld	s4,0(sp)
    80002ac2:	6145                	addi	sp,sp,48
    80002ac4:	8082                	ret
    memmove((char *)dst, src, len);
    80002ac6:	000a061b          	sext.w	a2,s4
    80002aca:	85ce                	mv	a1,s3
    80002acc:	854a                	mv	a0,s2
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	666080e7          	jalr	1638(ra) # 80001134 <memmove>
    return 0;
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	bff9                	j	80002ab6 <either_copyout+0x32>

0000000080002ada <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002ada:	7179                	addi	sp,sp,-48
    80002adc:	f406                	sd	ra,40(sp)
    80002ade:	f022                	sd	s0,32(sp)
    80002ae0:	ec26                	sd	s1,24(sp)
    80002ae2:	e84a                	sd	s2,16(sp)
    80002ae4:	e44e                	sd	s3,8(sp)
    80002ae6:	e052                	sd	s4,0(sp)
    80002ae8:	1800                	addi	s0,sp,48
    80002aea:	892a                	mv	s2,a0
    80002aec:	84ae                	mv	s1,a1
    80002aee:	89b2                	mv	s3,a2
    80002af0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002af2:	fffff097          	auipc	ra,0xfffff
    80002af6:	4aa080e7          	jalr	1194(ra) # 80001f9c <myproc>
  if(user_src){
    80002afa:	c08d                	beqz	s1,80002b1c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002afc:	86d2                	mv	a3,s4
    80002afe:	864e                	mv	a2,s3
    80002b00:	85ca                	mv	a1,s2
    80002b02:	7528                	ld	a0,104(a0)
    80002b04:	fffff097          	auipc	ra,0xfffff
    80002b08:	126080e7          	jalr	294(ra) # 80001c2a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002b0c:	70a2                	ld	ra,40(sp)
    80002b0e:	7402                	ld	s0,32(sp)
    80002b10:	64e2                	ld	s1,24(sp)
    80002b12:	6942                	ld	s2,16(sp)
    80002b14:	69a2                	ld	s3,8(sp)
    80002b16:	6a02                	ld	s4,0(sp)
    80002b18:	6145                	addi	sp,sp,48
    80002b1a:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b1c:	000a061b          	sext.w	a2,s4
    80002b20:	85ce                	mv	a1,s3
    80002b22:	854a                	mv	a0,s2
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	610080e7          	jalr	1552(ra) # 80001134 <memmove>
    return 0;
    80002b2c:	8526                	mv	a0,s1
    80002b2e:	bff9                	j	80002b0c <either_copyin+0x32>

0000000080002b30 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b30:	715d                	addi	sp,sp,-80
    80002b32:	e486                	sd	ra,72(sp)
    80002b34:	e0a2                	sd	s0,64(sp)
    80002b36:	fc26                	sd	s1,56(sp)
    80002b38:	f84a                	sd	s2,48(sp)
    80002b3a:	f44e                	sd	s3,40(sp)
    80002b3c:	f052                	sd	s4,32(sp)
    80002b3e:	ec56                	sd	s5,24(sp)
    80002b40:	e85a                	sd	s6,16(sp)
    80002b42:	e45e                	sd	s7,8(sp)
    80002b44:	e062                	sd	s8,0(sp)
    80002b46:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\nPID\tPPID\tPRIO\tSTATE\tCMD\n");
    80002b48:	00006517          	auipc	a0,0x6
    80002b4c:	ae850513          	addi	a0,a0,-1304 # 80008630 <userret+0x5a0>
    80002b50:	ffffe097          	auipc	ra,0xffffe
    80002b54:	e1c080e7          	jalr	-484(ra) # 8000096c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b58:	00013497          	auipc	s1,0x13
    80002b5c:	34048493          	addi	s1,s1,832 # 80015e98 <proc>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b60:	4b91                	li	s7,4
      state = states[p->state];
    else
      state = "???";
    80002b62:	00006997          	auipc	s3,0x6
    80002b66:	ac698993          	addi	s3,s3,-1338 # 80008628 <userret+0x598>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002b6a:	5b7d                	li	s6,-1
    80002b6c:	00006a97          	auipc	s5,0x6
    80002b70:	ae4a8a93          	addi	s5,s5,-1308 # 80008650 <userret+0x5c0>
           p->parent ? p->parent->pid : -1,
           p->priority,
           state,
           p->cmd
           );
    printf("\n");
    80002b74:	00006a17          	auipc	s4,0x6
    80002b78:	ad4a0a13          	addi	s4,s4,-1324 # 80008648 <userret+0x5b8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b7c:	00006c17          	auipc	s8,0x6
    80002b80:	3c4c0c13          	addi	s8,s8,964 # 80008f40 <states.1827>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b84:	00019917          	auipc	s2,0x19
    80002b88:	51490913          	addi	s2,s2,1300 # 8001c098 <tickslock>
    80002b8c:	a03d                	j	80002bba <procdump+0x8a>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002b8e:	48ac                	lw	a1,80(s1)
           p->parent ? p->parent->pid : -1,
    80002b90:	7c9c                	ld	a5,56(s1)
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002b92:	865a                	mv	a2,s6
    80002b94:	c391                	beqz	a5,80002b98 <procdump+0x68>
    80002b96:	4bb0                	lw	a2,80(a5)
    80002b98:	1804b783          	ld	a5,384(s1)
    80002b9c:	48f4                	lw	a3,84(s1)
    80002b9e:	8556                	mv	a0,s5
    80002ba0:	ffffe097          	auipc	ra,0xffffe
    80002ba4:	dcc080e7          	jalr	-564(ra) # 8000096c <printf>
    printf("\n");
    80002ba8:	8552                	mv	a0,s4
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	dc2080e7          	jalr	-574(ra) # 8000096c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002bb2:	18848493          	addi	s1,s1,392
    80002bb6:	01248f63          	beq	s1,s2,80002bd4 <procdump+0xa4>
    if(p->state == UNUSED)
    80002bba:	589c                	lw	a5,48(s1)
    80002bbc:	dbfd                	beqz	a5,80002bb2 <procdump+0x82>
      state = "???";
    80002bbe:	874e                	mv	a4,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bc0:	fcfbe7e3          	bltu	s7,a5,80002b8e <procdump+0x5e>
    80002bc4:	1782                	slli	a5,a5,0x20
    80002bc6:	9381                	srli	a5,a5,0x20
    80002bc8:	078e                	slli	a5,a5,0x3
    80002bca:	97e2                	add	a5,a5,s8
    80002bcc:	6398                	ld	a4,0(a5)
    80002bce:	f361                	bnez	a4,80002b8e <procdump+0x5e>
      state = "???";
    80002bd0:	874e                	mv	a4,s3
    80002bd2:	bf75                	j	80002b8e <procdump+0x5e>
  }
}
    80002bd4:	60a6                	ld	ra,72(sp)
    80002bd6:	6406                	ld	s0,64(sp)
    80002bd8:	74e2                	ld	s1,56(sp)
    80002bda:	7942                	ld	s2,48(sp)
    80002bdc:	79a2                	ld	s3,40(sp)
    80002bde:	7a02                	ld	s4,32(sp)
    80002be0:	6ae2                	ld	s5,24(sp)
    80002be2:	6b42                	ld	s6,16(sp)
    80002be4:	6ba2                	ld	s7,8(sp)
    80002be6:	6c02                	ld	s8,0(sp)
    80002be8:	6161                	addi	sp,sp,80
    80002bea:	8082                	ret

0000000080002bec <priodump>:

// No lock to avoid wedging a stuck machine further.
void priodump(void){
    80002bec:	715d                	addi	sp,sp,-80
    80002bee:	e486                	sd	ra,72(sp)
    80002bf0:	e0a2                	sd	s0,64(sp)
    80002bf2:	fc26                	sd	s1,56(sp)
    80002bf4:	f84a                	sd	s2,48(sp)
    80002bf6:	f44e                	sd	s3,40(sp)
    80002bf8:	f052                	sd	s4,32(sp)
    80002bfa:	ec56                	sd	s5,24(sp)
    80002bfc:	e85a                	sd	s6,16(sp)
    80002bfe:	e45e                	sd	s7,8(sp)
    80002c00:	0880                	addi	s0,sp,80
  for (int i = 0; i < NPRIO; i++){
    80002c02:	00013a17          	auipc	s4,0x13
    80002c06:	de6a0a13          	addi	s4,s4,-538 # 800159e8 <prio>
    80002c0a:	4981                	li	s3,0
    struct list_proc* l = prio[i];
    printf("Priority queue for priority = %d: ", i);
    80002c0c:	00006b97          	auipc	s7,0x6
    80002c10:	a5cb8b93          	addi	s7,s7,-1444 # 80008668 <userret+0x5d8>
    while(l){
      printf("%d ", l->p->pid);
    80002c14:	00006917          	auipc	s2,0x6
    80002c18:	a7c90913          	addi	s2,s2,-1412 # 80008690 <userret+0x600>
      l = l->next;
    }
    printf("\n");
    80002c1c:	00006b17          	auipc	s6,0x6
    80002c20:	a2cb0b13          	addi	s6,s6,-1492 # 80008648 <userret+0x5b8>
  for (int i = 0; i < NPRIO; i++){
    80002c24:	4aa9                	li	s5,10
    80002c26:	a811                	j	80002c3a <priodump+0x4e>
    printf("\n");
    80002c28:	855a                	mv	a0,s6
    80002c2a:	ffffe097          	auipc	ra,0xffffe
    80002c2e:	d42080e7          	jalr	-702(ra) # 8000096c <printf>
  for (int i = 0; i < NPRIO; i++){
    80002c32:	2985                	addiw	s3,s3,1
    80002c34:	0a21                	addi	s4,s4,8
    80002c36:	03598563          	beq	s3,s5,80002c60 <priodump+0x74>
    struct list_proc* l = prio[i];
    80002c3a:	000a3483          	ld	s1,0(s4)
    printf("Priority queue for priority = %d: ", i);
    80002c3e:	85ce                	mv	a1,s3
    80002c40:	855e                	mv	a0,s7
    80002c42:	ffffe097          	auipc	ra,0xffffe
    80002c46:	d2a080e7          	jalr	-726(ra) # 8000096c <printf>
    while(l){
    80002c4a:	dcf9                	beqz	s1,80002c28 <priodump+0x3c>
      printf("%d ", l->p->pid);
    80002c4c:	609c                	ld	a5,0(s1)
    80002c4e:	4bac                	lw	a1,80(a5)
    80002c50:	854a                	mv	a0,s2
    80002c52:	ffffe097          	auipc	ra,0xffffe
    80002c56:	d1a080e7          	jalr	-742(ra) # 8000096c <printf>
      l = l->next;
    80002c5a:	6484                	ld	s1,8(s1)
    while(l){
    80002c5c:	f8e5                	bnez	s1,80002c4c <priodump+0x60>
    80002c5e:	b7e9                	j	80002c28 <priodump+0x3c>
  }
}
    80002c60:	60a6                	ld	ra,72(sp)
    80002c62:	6406                	ld	s0,64(sp)
    80002c64:	74e2                	ld	s1,56(sp)
    80002c66:	7942                	ld	s2,48(sp)
    80002c68:	79a2                	ld	s3,40(sp)
    80002c6a:	7a02                	ld	s4,32(sp)
    80002c6c:	6ae2                	ld	s5,24(sp)
    80002c6e:	6b42                	ld	s6,16(sp)
    80002c70:	6ba2                	ld	s7,8(sp)
    80002c72:	6161                	addi	sp,sp,80
    80002c74:	8082                	ret

0000000080002c76 <swtch>:
    80002c76:	00153023          	sd	ra,0(a0)
    80002c7a:	00253423          	sd	sp,8(a0)
    80002c7e:	e900                	sd	s0,16(a0)
    80002c80:	ed04                	sd	s1,24(a0)
    80002c82:	03253023          	sd	s2,32(a0)
    80002c86:	03353423          	sd	s3,40(a0)
    80002c8a:	03453823          	sd	s4,48(a0)
    80002c8e:	03553c23          	sd	s5,56(a0)
    80002c92:	05653023          	sd	s6,64(a0)
    80002c96:	05753423          	sd	s7,72(a0)
    80002c9a:	05853823          	sd	s8,80(a0)
    80002c9e:	05953c23          	sd	s9,88(a0)
    80002ca2:	07a53023          	sd	s10,96(a0)
    80002ca6:	07b53423          	sd	s11,104(a0)
    80002caa:	0005b083          	ld	ra,0(a1)
    80002cae:	0085b103          	ld	sp,8(a1)
    80002cb2:	6980                	ld	s0,16(a1)
    80002cb4:	6d84                	ld	s1,24(a1)
    80002cb6:	0205b903          	ld	s2,32(a1)
    80002cba:	0285b983          	ld	s3,40(a1)
    80002cbe:	0305ba03          	ld	s4,48(a1)
    80002cc2:	0385ba83          	ld	s5,56(a1)
    80002cc6:	0405bb03          	ld	s6,64(a1)
    80002cca:	0485bb83          	ld	s7,72(a1)
    80002cce:	0505bc03          	ld	s8,80(a1)
    80002cd2:	0585bc83          	ld	s9,88(a1)
    80002cd6:	0605bd03          	ld	s10,96(a1)
    80002cda:	0685bd83          	ld	s11,104(a1)
    80002cde:	8082                	ret

0000000080002ce0 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002ce0:	1141                	addi	sp,sp,-16
    80002ce2:	e422                	sd	s0,8(sp)
    80002ce4:	0800                	addi	s0,sp,16
    80002ce6:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002ce8:	00151713          	slli	a4,a0,0x1
    80002cec:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    80002cee:	04054c63          	bltz	a0,80002d46 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002cf2:	5685                	li	a3,-31
    80002cf4:	8285                	srli	a3,a3,0x1
    80002cf6:	8ee9                	and	a3,a3,a0
    80002cf8:	caad                	beqz	a3,80002d6a <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002cfa:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002cfc:	00006517          	auipc	a0,0x6
    80002d00:	9c450513          	addi	a0,a0,-1596 # 800086c0 <userret+0x630>
    } else if (code <= 23) {
    80002d04:	06e6f063          	bgeu	a3,a4,80002d64 <scause_desc+0x84>
    } else if (code <= 31) {
    80002d08:	fc100693          	li	a3,-63
    80002d0c:	8285                	srli	a3,a3,0x1
    80002d0e:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    80002d10:	00006517          	auipc	a0,0x6
    80002d14:	9d850513          	addi	a0,a0,-1576 # 800086e8 <userret+0x658>
    } else if (code <= 31) {
    80002d18:	c6b1                	beqz	a3,80002d64 <scause_desc+0x84>
    } else if (code <= 47) {
    80002d1a:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    80002d1e:	00006517          	auipc	a0,0x6
    80002d22:	9a250513          	addi	a0,a0,-1630 # 800086c0 <userret+0x630>
    } else if (code <= 47) {
    80002d26:	02e6ff63          	bgeu	a3,a4,80002d64 <scause_desc+0x84>
    } else if (code <= 63) {
    80002d2a:	f8100513          	li	a0,-127
    80002d2e:	8105                	srli	a0,a0,0x1
    80002d30:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    80002d32:	00006517          	auipc	a0,0x6
    80002d36:	9b650513          	addi	a0,a0,-1610 # 800086e8 <userret+0x658>
    } else if (code <= 63) {
    80002d3a:	c78d                	beqz	a5,80002d64 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    80002d3c:	00006517          	auipc	a0,0x6
    80002d40:	98450513          	addi	a0,a0,-1660 # 800086c0 <userret+0x630>
    80002d44:	a005                	j	80002d64 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    80002d46:	5505                	li	a0,-31
    80002d48:	8105                	srli	a0,a0,0x1
    80002d4a:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    80002d4c:	00006517          	auipc	a0,0x6
    80002d50:	9bc50513          	addi	a0,a0,-1604 # 80008708 <userret+0x678>
    if (code < NELEM(intr_desc)) {
    80002d54:	eb81                	bnez	a5,80002d64 <scause_desc+0x84>
      return intr_desc[code];
    80002d56:	070e                	slli	a4,a4,0x3
    80002d58:	00006797          	auipc	a5,0x6
    80002d5c:	21078793          	addi	a5,a5,528 # 80008f68 <intr_desc.1629>
    80002d60:	973e                	add	a4,a4,a5
    80002d62:	6308                	ld	a0,0(a4)
    }
  }
}
    80002d64:	6422                	ld	s0,8(sp)
    80002d66:	0141                	addi	sp,sp,16
    80002d68:	8082                	ret
      return nointr_desc[code];
    80002d6a:	070e                	slli	a4,a4,0x3
    80002d6c:	00006797          	auipc	a5,0x6
    80002d70:	1fc78793          	addi	a5,a5,508 # 80008f68 <intr_desc.1629>
    80002d74:	973e                	add	a4,a4,a5
    80002d76:	6348                	ld	a0,128(a4)
    80002d78:	b7f5                	j	80002d64 <scause_desc+0x84>

0000000080002d7a <trapinit>:
{
    80002d7a:	1141                	addi	sp,sp,-16
    80002d7c:	e406                	sd	ra,8(sp)
    80002d7e:	e022                	sd	s0,0(sp)
    80002d80:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002d82:	00006597          	auipc	a1,0x6
    80002d86:	9a658593          	addi	a1,a1,-1626 # 80008728 <userret+0x698>
    80002d8a:	00019517          	auipc	a0,0x19
    80002d8e:	30e50513          	addi	a0,a0,782 # 8001c098 <tickslock>
    80002d92:	ffffe097          	auipc	ra,0xffffe
    80002d96:	d8c080e7          	jalr	-628(ra) # 80000b1e <initlock>
}
    80002d9a:	60a2                	ld	ra,8(sp)
    80002d9c:	6402                	ld	s0,0(sp)
    80002d9e:	0141                	addi	sp,sp,16
    80002da0:	8082                	ret

0000000080002da2 <trapinithart>:
{
    80002da2:	1141                	addi	sp,sp,-16
    80002da4:	e422                	sd	s0,8(sp)
    80002da6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002da8:	00003797          	auipc	a5,0x3
    80002dac:	66878793          	addi	a5,a5,1640 # 80006410 <kernelvec>
    80002db0:	10579073          	csrw	stvec,a5
}
    80002db4:	6422                	ld	s0,8(sp)
    80002db6:	0141                	addi	sp,sp,16
    80002db8:	8082                	ret

0000000080002dba <usertrapret>:
{
    80002dba:	1141                	addi	sp,sp,-16
    80002dbc:	e406                	sd	ra,8(sp)
    80002dbe:	e022                	sd	s0,0(sp)
    80002dc0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002dc2:	fffff097          	auipc	ra,0xfffff
    80002dc6:	1da080e7          	jalr	474(ra) # 80001f9c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002dce:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dd0:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002dd4:	00005617          	auipc	a2,0x5
    80002dd8:	22c60613          	addi	a2,a2,556 # 80008000 <trampoline>
    80002ddc:	00005697          	auipc	a3,0x5
    80002de0:	22468693          	addi	a3,a3,548 # 80008000 <trampoline>
    80002de4:	8e91                	sub	a3,a3,a2
    80002de6:	040007b7          	lui	a5,0x4000
    80002dea:	17fd                	addi	a5,a5,-1
    80002dec:	07b2                	slli	a5,a5,0xc
    80002dee:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002df0:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002df4:	7938                	ld	a4,112(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002df6:	180026f3          	csrr	a3,satp
    80002dfa:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002dfc:	7938                	ld	a4,112(a0)
    80002dfe:	6d34                	ld	a3,88(a0)
    80002e00:	6585                	lui	a1,0x1
    80002e02:	96ae                	add	a3,a3,a1
    80002e04:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002e06:	7938                	ld	a4,112(a0)
    80002e08:	00000697          	auipc	a3,0x0
    80002e0c:	17e68693          	addi	a3,a3,382 # 80002f86 <usertrap>
    80002e10:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    80002e12:	7938                	ld	a4,112(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002e14:	8692                	mv	a3,tp
    80002e16:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e18:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002e1c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002e20:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e24:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    80002e28:	7938                	ld	a4,112(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e2a:	6f18                	ld	a4,24(a4)
    80002e2c:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002e30:	752c                	ld	a1,104(a0)
    80002e32:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002e34:	00005717          	auipc	a4,0x5
    80002e38:	25c70713          	addi	a4,a4,604 # 80008090 <userret>
    80002e3c:	8f11                	sub	a4,a4,a2
    80002e3e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002e40:	577d                	li	a4,-1
    80002e42:	177e                	slli	a4,a4,0x3f
    80002e44:	8dd9                	or	a1,a1,a4
    80002e46:	02000537          	lui	a0,0x2000
    80002e4a:	157d                	addi	a0,a0,-1
    80002e4c:	0536                	slli	a0,a0,0xd
    80002e4e:	9782                	jalr	a5
}
    80002e50:	60a2                	ld	ra,8(sp)
    80002e52:	6402                	ld	s0,0(sp)
    80002e54:	0141                	addi	sp,sp,16
    80002e56:	8082                	ret

0000000080002e58 <clockintr>:
{
    80002e58:	1141                	addi	sp,sp,-16
    80002e5a:	e406                	sd	ra,8(sp)
    80002e5c:	e022                	sd	s0,0(sp)
    80002e5e:	0800                	addi	s0,sp,16
  acquire(&watchdog_lock);
    80002e60:	0002b517          	auipc	a0,0x2b
    80002e64:	1d050513          	addi	a0,a0,464 # 8002e030 <watchdog_lock>
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	e20080e7          	jalr	-480(ra) # 80000c88 <acquire>
  acquire(&tickslock);
    80002e70:	00019517          	auipc	a0,0x19
    80002e74:	22850513          	addi	a0,a0,552 # 8001c098 <tickslock>
    80002e78:	ffffe097          	auipc	ra,0xffffe
    80002e7c:	e10080e7          	jalr	-496(ra) # 80000c88 <acquire>
  if (watchdog_time && ticks - watchdog_value > watchdog_time){
    80002e80:	0002b797          	auipc	a5,0x2b
    80002e84:	2247a783          	lw	a5,548(a5) # 8002e0a4 <watchdog_time>
    80002e88:	cf89                	beqz	a5,80002ea2 <clockintr+0x4a>
    80002e8a:	0002b717          	auipc	a4,0x2b
    80002e8e:	1fe72703          	lw	a4,510(a4) # 8002e088 <ticks>
    80002e92:	0002b697          	auipc	a3,0x2b
    80002e96:	2166a683          	lw	a3,534(a3) # 8002e0a8 <watchdog_value>
    80002e9a:	9f15                	subw	a4,a4,a3
    80002e9c:	2781                	sext.w	a5,a5
    80002e9e:	04e7e163          	bltu	a5,a4,80002ee0 <clockintr+0x88>
  ticks++;
    80002ea2:	0002b517          	auipc	a0,0x2b
    80002ea6:	1e650513          	addi	a0,a0,486 # 8002e088 <ticks>
    80002eaa:	411c                	lw	a5,0(a0)
    80002eac:	2785                	addiw	a5,a5,1
    80002eae:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002eb0:	00000097          	auipc	ra,0x0
    80002eb4:	af8080e7          	jalr	-1288(ra) # 800029a8 <wakeup>
  release(&tickslock);
    80002eb8:	00019517          	auipc	a0,0x19
    80002ebc:	1e050513          	addi	a0,a0,480 # 8001c098 <tickslock>
    80002ec0:	ffffe097          	auipc	ra,0xffffe
    80002ec4:	014080e7          	jalr	20(ra) # 80000ed4 <release>
  release(&watchdog_lock);
    80002ec8:	0002b517          	auipc	a0,0x2b
    80002ecc:	16850513          	addi	a0,a0,360 # 8002e030 <watchdog_lock>
    80002ed0:	ffffe097          	auipc	ra,0xffffe
    80002ed4:	004080e7          	jalr	4(ra) # 80000ed4 <release>
}
    80002ed8:	60a2                	ld	ra,8(sp)
    80002eda:	6402                	ld	s0,0(sp)
    80002edc:	0141                	addi	sp,sp,16
    80002ede:	8082                	ret
    panic("watchdog !!!");
    80002ee0:	00006517          	auipc	a0,0x6
    80002ee4:	85050513          	addi	a0,a0,-1968 # 80008730 <userret+0x6a0>
    80002ee8:	ffffe097          	auipc	ra,0xffffe
    80002eec:	86e080e7          	jalr	-1938(ra) # 80000756 <panic>

0000000080002ef0 <devintr>:
{
    80002ef0:	1101                	addi	sp,sp,-32
    80002ef2:	ec06                	sd	ra,24(sp)
    80002ef4:	e822                	sd	s0,16(sp)
    80002ef6:	e426                	sd	s1,8(sp)
    80002ef8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002efa:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002efe:	00074d63          	bltz	a4,80002f18 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002f02:	57fd                	li	a5,-1
    80002f04:	17fe                	slli	a5,a5,0x3f
    80002f06:	0785                	addi	a5,a5,1
    return 0;
    80002f08:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002f0a:	04f70d63          	beq	a4,a5,80002f64 <devintr+0x74>
}
    80002f0e:	60e2                	ld	ra,24(sp)
    80002f10:	6442                	ld	s0,16(sp)
    80002f12:	64a2                	ld	s1,8(sp)
    80002f14:	6105                	addi	sp,sp,32
    80002f16:	8082                	ret
     (scause & 0xff) == 9){
    80002f18:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002f1c:	46a5                	li	a3,9
    80002f1e:	fed792e3          	bne	a5,a3,80002f02 <devintr+0x12>
    int irq = plic_claim();
    80002f22:	00003097          	auipc	ra,0x3
    80002f26:	5f6080e7          	jalr	1526(ra) # 80006518 <plic_claim>
    80002f2a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002f2c:	47a9                	li	a5,10
    80002f2e:	00f50a63          	beq	a0,a5,80002f42 <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80002f32:	fff5079b          	addiw	a5,a0,-1
    80002f36:	4705                	li	a4,1
    80002f38:	00f77a63          	bgeu	a4,a5,80002f4c <devintr+0x5c>
    return 1;
    80002f3c:	4505                	li	a0,1
    if(irq)
    80002f3e:	d8e1                	beqz	s1,80002f0e <devintr+0x1e>
    80002f40:	a819                	j	80002f56 <devintr+0x66>
      uartintr();
    80002f42:	ffffe097          	auipc	ra,0xffffe
    80002f46:	b56080e7          	jalr	-1194(ra) # 80000a98 <uartintr>
    80002f4a:	a031                	j	80002f56 <devintr+0x66>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    80002f4c:	853e                	mv	a0,a5
    80002f4e:	00004097          	auipc	ra,0x4
    80002f52:	bb8080e7          	jalr	-1096(ra) # 80006b06 <virtio_disk_intr>
      plic_complete(irq);
    80002f56:	8526                	mv	a0,s1
    80002f58:	00003097          	auipc	ra,0x3
    80002f5c:	5e4080e7          	jalr	1508(ra) # 8000653c <plic_complete>
    return 1;
    80002f60:	4505                	li	a0,1
    80002f62:	b775                	j	80002f0e <devintr+0x1e>
    if(cpuid() == 0){
    80002f64:	fffff097          	auipc	ra,0xfffff
    80002f68:	00c080e7          	jalr	12(ra) # 80001f70 <cpuid>
    80002f6c:	c901                	beqz	a0,80002f7c <devintr+0x8c>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002f6e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002f72:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002f74:	14479073          	csrw	sip,a5
    return 2;
    80002f78:	4509                	li	a0,2
    80002f7a:	bf51                	j	80002f0e <devintr+0x1e>
      clockintr();
    80002f7c:	00000097          	auipc	ra,0x0
    80002f80:	edc080e7          	jalr	-292(ra) # 80002e58 <clockintr>
    80002f84:	b7ed                	j	80002f6e <devintr+0x7e>

0000000080002f86 <usertrap>:
{
    80002f86:	7179                	addi	sp,sp,-48
    80002f88:	f406                	sd	ra,40(sp)
    80002f8a:	f022                	sd	s0,32(sp)
    80002f8c:	ec26                	sd	s1,24(sp)
    80002f8e:	e84a                	sd	s2,16(sp)
    80002f90:	e44e                	sd	s3,8(sp)
    80002f92:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f94:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002f98:	1007f793          	andi	a5,a5,256
    80002f9c:	e3b5                	bnez	a5,80003000 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f9e:	00003797          	auipc	a5,0x3
    80002fa2:	47278793          	addi	a5,a5,1138 # 80006410 <kernelvec>
    80002fa6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002faa:	fffff097          	auipc	ra,0xfffff
    80002fae:	ff2080e7          	jalr	-14(ra) # 80001f9c <myproc>
    80002fb2:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002fb4:	793c                	ld	a5,112(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fb6:	14102773          	csrr	a4,sepc
    80002fba:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fbc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002fc0:	47a1                	li	a5,8
    80002fc2:	04f71d63          	bne	a4,a5,8000301c <usertrap+0x96>
    if(p->killed)
    80002fc6:	453c                	lw	a5,72(a0)
    80002fc8:	e7a1                	bnez	a5,80003010 <usertrap+0x8a>
    p->tf->epc += 4;
    80002fca:	78b8                	ld	a4,112(s1)
    80002fcc:	6f1c                	ld	a5,24(a4)
    80002fce:	0791                	addi	a5,a5,4
    80002fd0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fd2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002fd6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fda:	10079073          	csrw	sstatus,a5
    syscall();
    80002fde:	00000097          	auipc	ra,0x0
    80002fe2:	2fe080e7          	jalr	766(ra) # 800032dc <syscall>
  if(p->killed)
    80002fe6:	44bc                	lw	a5,72(s1)
    80002fe8:	e3cd                	bnez	a5,8000308a <usertrap+0x104>
  usertrapret();
    80002fea:	00000097          	auipc	ra,0x0
    80002fee:	dd0080e7          	jalr	-560(ra) # 80002dba <usertrapret>
}
    80002ff2:	70a2                	ld	ra,40(sp)
    80002ff4:	7402                	ld	s0,32(sp)
    80002ff6:	64e2                	ld	s1,24(sp)
    80002ff8:	6942                	ld	s2,16(sp)
    80002ffa:	69a2                	ld	s3,8(sp)
    80002ffc:	6145                	addi	sp,sp,48
    80002ffe:	8082                	ret
    panic("usertrap: not from user mode");
    80003000:	00005517          	auipc	a0,0x5
    80003004:	74050513          	addi	a0,a0,1856 # 80008740 <userret+0x6b0>
    80003008:	ffffd097          	auipc	ra,0xffffd
    8000300c:	74e080e7          	jalr	1870(ra) # 80000756 <panic>
      exit(-1);
    80003010:	557d                	li	a0,-1
    80003012:	fffff097          	auipc	ra,0xfffff
    80003016:	68c080e7          	jalr	1676(ra) # 8000269e <exit>
    8000301a:	bf45                	j	80002fca <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    8000301c:	00000097          	auipc	ra,0x0
    80003020:	ed4080e7          	jalr	-300(ra) # 80002ef0 <devintr>
    80003024:	892a                	mv	s2,a0
    80003026:	c501                	beqz	a0,8000302e <usertrap+0xa8>
  if(p->killed)
    80003028:	44bc                	lw	a5,72(s1)
    8000302a:	cba1                	beqz	a5,8000307a <usertrap+0xf4>
    8000302c:	a091                	j	80003070 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000302e:	142029f3          	csrr	s3,scause
    80003032:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80003036:	00000097          	auipc	ra,0x0
    8000303a:	caa080e7          	jalr	-854(ra) # 80002ce0 <scause_desc>
    8000303e:	862a                	mv	a2,a0
    80003040:	48b4                	lw	a3,80(s1)
    80003042:	85ce                	mv	a1,s3
    80003044:	00005517          	auipc	a0,0x5
    80003048:	71c50513          	addi	a0,a0,1820 # 80008760 <userret+0x6d0>
    8000304c:	ffffe097          	auipc	ra,0xffffe
    80003050:	920080e7          	jalr	-1760(ra) # 8000096c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003054:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003058:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000305c:	00005517          	auipc	a0,0x5
    80003060:	73450513          	addi	a0,a0,1844 # 80008790 <userret+0x700>
    80003064:	ffffe097          	auipc	ra,0xffffe
    80003068:	908080e7          	jalr	-1784(ra) # 8000096c <printf>
    p->killed = 1;
    8000306c:	4785                	li	a5,1
    8000306e:	c4bc                	sw	a5,72(s1)
    exit(-1);
    80003070:	557d                	li	a0,-1
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	62c080e7          	jalr	1580(ra) # 8000269e <exit>
  if(which_dev == 2)
    8000307a:	4789                	li	a5,2
    8000307c:	f6f917e3          	bne	s2,a5,80002fea <usertrap+0x64>
    yield();
    80003080:	fffff097          	auipc	ra,0xfffff
    80003084:	766080e7          	jalr	1894(ra) # 800027e6 <yield>
    80003088:	b78d                	j	80002fea <usertrap+0x64>
  int which_dev = 0;
    8000308a:	4901                	li	s2,0
    8000308c:	b7d5                	j	80003070 <usertrap+0xea>

000000008000308e <kerneltrap>:
{
    8000308e:	7179                	addi	sp,sp,-48
    80003090:	f406                	sd	ra,40(sp)
    80003092:	f022                	sd	s0,32(sp)
    80003094:	ec26                	sd	s1,24(sp)
    80003096:	e84a                	sd	s2,16(sp)
    80003098:	e44e                	sd	s3,8(sp)
    8000309a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000309c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030a0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030a4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800030a8:	1004f793          	andi	a5,s1,256
    800030ac:	cb85                	beqz	a5,800030dc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030ae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800030b2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800030b4:	ef85                	bnez	a5,800030ec <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800030b6:	00000097          	auipc	ra,0x0
    800030ba:	e3a080e7          	jalr	-454(ra) # 80002ef0 <devintr>
    800030be:	cd1d                	beqz	a0,800030fc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030c0:	4789                	li	a5,2
    800030c2:	08f50063          	beq	a0,a5,80003142 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800030c6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030ca:	10049073          	csrw	sstatus,s1
}
    800030ce:	70a2                	ld	ra,40(sp)
    800030d0:	7402                	ld	s0,32(sp)
    800030d2:	64e2                	ld	s1,24(sp)
    800030d4:	6942                	ld	s2,16(sp)
    800030d6:	69a2                	ld	s3,8(sp)
    800030d8:	6145                	addi	sp,sp,48
    800030da:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800030dc:	00005517          	auipc	a0,0x5
    800030e0:	6d450513          	addi	a0,a0,1748 # 800087b0 <userret+0x720>
    800030e4:	ffffd097          	auipc	ra,0xffffd
    800030e8:	672080e7          	jalr	1650(ra) # 80000756 <panic>
    panic("kerneltrap: interrupts enabled");
    800030ec:	00005517          	auipc	a0,0x5
    800030f0:	6ec50513          	addi	a0,a0,1772 # 800087d8 <userret+0x748>
    800030f4:	ffffd097          	auipc	ra,0xffffd
    800030f8:	662080e7          	jalr	1634(ra) # 80000756 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    800030fc:	854e                	mv	a0,s3
    800030fe:	00000097          	auipc	ra,0x0
    80003102:	be2080e7          	jalr	-1054(ra) # 80002ce0 <scause_desc>
    80003106:	862a                	mv	a2,a0
    80003108:	85ce                	mv	a1,s3
    8000310a:	00005517          	auipc	a0,0x5
    8000310e:	6ee50513          	addi	a0,a0,1774 # 800087f8 <userret+0x768>
    80003112:	ffffe097          	auipc	ra,0xffffe
    80003116:	85a080e7          	jalr	-1958(ra) # 8000096c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000311a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000311e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003122:	00005517          	auipc	a0,0x5
    80003126:	6e650513          	addi	a0,a0,1766 # 80008808 <userret+0x778>
    8000312a:	ffffe097          	auipc	ra,0xffffe
    8000312e:	842080e7          	jalr	-1982(ra) # 8000096c <printf>
    panic("kerneltrap");
    80003132:	00005517          	auipc	a0,0x5
    80003136:	6ee50513          	addi	a0,a0,1774 # 80008820 <userret+0x790>
    8000313a:	ffffd097          	auipc	ra,0xffffd
    8000313e:	61c080e7          	jalr	1564(ra) # 80000756 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003142:	fffff097          	auipc	ra,0xfffff
    80003146:	e5a080e7          	jalr	-422(ra) # 80001f9c <myproc>
    8000314a:	dd35                	beqz	a0,800030c6 <kerneltrap+0x38>
    8000314c:	fffff097          	auipc	ra,0xfffff
    80003150:	e50080e7          	jalr	-432(ra) # 80001f9c <myproc>
    80003154:	5918                	lw	a4,48(a0)
    80003156:	478d                	li	a5,3
    80003158:	f6f717e3          	bne	a4,a5,800030c6 <kerneltrap+0x38>
    yield();
    8000315c:	fffff097          	auipc	ra,0xfffff
    80003160:	68a080e7          	jalr	1674(ra) # 800027e6 <yield>
    80003164:	b78d                	j	800030c6 <kerneltrap+0x38>

0000000080003166 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003166:	1101                	addi	sp,sp,-32
    80003168:	ec06                	sd	ra,24(sp)
    8000316a:	e822                	sd	s0,16(sp)
    8000316c:	e426                	sd	s1,8(sp)
    8000316e:	1000                	addi	s0,sp,32
    80003170:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003172:	fffff097          	auipc	ra,0xfffff
    80003176:	e2a080e7          	jalr	-470(ra) # 80001f9c <myproc>
  switch (n) {
    8000317a:	4795                	li	a5,5
    8000317c:	0497e163          	bltu	a5,s1,800031be <argraw+0x58>
    80003180:	048a                	slli	s1,s1,0x2
    80003182:	00006717          	auipc	a4,0x6
    80003186:	ee670713          	addi	a4,a4,-282 # 80009068 <nointr_desc.1630+0x80>
    8000318a:	94ba                	add	s1,s1,a4
    8000318c:	409c                	lw	a5,0(s1)
    8000318e:	97ba                	add	a5,a5,a4
    80003190:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80003192:	793c                	ld	a5,112(a0)
    80003194:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80003196:	60e2                	ld	ra,24(sp)
    80003198:	6442                	ld	s0,16(sp)
    8000319a:	64a2                	ld	s1,8(sp)
    8000319c:	6105                	addi	sp,sp,32
    8000319e:	8082                	ret
    return p->tf->a1;
    800031a0:	793c                	ld	a5,112(a0)
    800031a2:	7fa8                	ld	a0,120(a5)
    800031a4:	bfcd                	j	80003196 <argraw+0x30>
    return p->tf->a2;
    800031a6:	793c                	ld	a5,112(a0)
    800031a8:	63c8                	ld	a0,128(a5)
    800031aa:	b7f5                	j	80003196 <argraw+0x30>
    return p->tf->a3;
    800031ac:	793c                	ld	a5,112(a0)
    800031ae:	67c8                	ld	a0,136(a5)
    800031b0:	b7dd                	j	80003196 <argraw+0x30>
    return p->tf->a4;
    800031b2:	793c                	ld	a5,112(a0)
    800031b4:	6bc8                	ld	a0,144(a5)
    800031b6:	b7c5                	j	80003196 <argraw+0x30>
    return p->tf->a5;
    800031b8:	793c                	ld	a5,112(a0)
    800031ba:	6fc8                	ld	a0,152(a5)
    800031bc:	bfe9                	j	80003196 <argraw+0x30>
  panic("argraw");
    800031be:	00006517          	auipc	a0,0x6
    800031c2:	86a50513          	addi	a0,a0,-1942 # 80008a28 <userret+0x998>
    800031c6:	ffffd097          	auipc	ra,0xffffd
    800031ca:	590080e7          	jalr	1424(ra) # 80000756 <panic>

00000000800031ce <fetchaddr>:
{
    800031ce:	1101                	addi	sp,sp,-32
    800031d0:	ec06                	sd	ra,24(sp)
    800031d2:	e822                	sd	s0,16(sp)
    800031d4:	e426                	sd	s1,8(sp)
    800031d6:	e04a                	sd	s2,0(sp)
    800031d8:	1000                	addi	s0,sp,32
    800031da:	84aa                	mv	s1,a0
    800031dc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800031de:	fffff097          	auipc	ra,0xfffff
    800031e2:	dbe080e7          	jalr	-578(ra) # 80001f9c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800031e6:	713c                	ld	a5,96(a0)
    800031e8:	02f4f863          	bgeu	s1,a5,80003218 <fetchaddr+0x4a>
    800031ec:	00848713          	addi	a4,s1,8
    800031f0:	02e7e663          	bltu	a5,a4,8000321c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800031f4:	46a1                	li	a3,8
    800031f6:	8626                	mv	a2,s1
    800031f8:	85ca                	mv	a1,s2
    800031fa:	7528                	ld	a0,104(a0)
    800031fc:	fffff097          	auipc	ra,0xfffff
    80003200:	a2e080e7          	jalr	-1490(ra) # 80001c2a <copyin>
    80003204:	00a03533          	snez	a0,a0
    80003208:	40a00533          	neg	a0,a0
}
    8000320c:	60e2                	ld	ra,24(sp)
    8000320e:	6442                	ld	s0,16(sp)
    80003210:	64a2                	ld	s1,8(sp)
    80003212:	6902                	ld	s2,0(sp)
    80003214:	6105                	addi	sp,sp,32
    80003216:	8082                	ret
    return -1;
    80003218:	557d                	li	a0,-1
    8000321a:	bfcd                	j	8000320c <fetchaddr+0x3e>
    8000321c:	557d                	li	a0,-1
    8000321e:	b7fd                	j	8000320c <fetchaddr+0x3e>

0000000080003220 <fetchstr>:
{
    80003220:	7179                	addi	sp,sp,-48
    80003222:	f406                	sd	ra,40(sp)
    80003224:	f022                	sd	s0,32(sp)
    80003226:	ec26                	sd	s1,24(sp)
    80003228:	e84a                	sd	s2,16(sp)
    8000322a:	e44e                	sd	s3,8(sp)
    8000322c:	1800                	addi	s0,sp,48
    8000322e:	892a                	mv	s2,a0
    80003230:	84ae                	mv	s1,a1
    80003232:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003234:	fffff097          	auipc	ra,0xfffff
    80003238:	d68080e7          	jalr	-664(ra) # 80001f9c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    8000323c:	86ce                	mv	a3,s3
    8000323e:	864a                	mv	a2,s2
    80003240:	85a6                	mv	a1,s1
    80003242:	7528                	ld	a0,104(a0)
    80003244:	fffff097          	auipc	ra,0xfffff
    80003248:	a72080e7          	jalr	-1422(ra) # 80001cb6 <copyinstr>
  if(err < 0)
    8000324c:	00054763          	bltz	a0,8000325a <fetchstr+0x3a>
  return strlen(buf);
    80003250:	8526                	mv	a0,s1
    80003252:	ffffe097          	auipc	ra,0xffffe
    80003256:	00a080e7          	jalr	10(ra) # 8000125c <strlen>
}
    8000325a:	70a2                	ld	ra,40(sp)
    8000325c:	7402                	ld	s0,32(sp)
    8000325e:	64e2                	ld	s1,24(sp)
    80003260:	6942                	ld	s2,16(sp)
    80003262:	69a2                	ld	s3,8(sp)
    80003264:	6145                	addi	sp,sp,48
    80003266:	8082                	ret

0000000080003268 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003268:	1101                	addi	sp,sp,-32
    8000326a:	ec06                	sd	ra,24(sp)
    8000326c:	e822                	sd	s0,16(sp)
    8000326e:	e426                	sd	s1,8(sp)
    80003270:	1000                	addi	s0,sp,32
    80003272:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003274:	00000097          	auipc	ra,0x0
    80003278:	ef2080e7          	jalr	-270(ra) # 80003166 <argraw>
    8000327c:	c088                	sw	a0,0(s1)
  return 0;
}
    8000327e:	4501                	li	a0,0
    80003280:	60e2                	ld	ra,24(sp)
    80003282:	6442                	ld	s0,16(sp)
    80003284:	64a2                	ld	s1,8(sp)
    80003286:	6105                	addi	sp,sp,32
    80003288:	8082                	ret

000000008000328a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    8000328a:	1101                	addi	sp,sp,-32
    8000328c:	ec06                	sd	ra,24(sp)
    8000328e:	e822                	sd	s0,16(sp)
    80003290:	e426                	sd	s1,8(sp)
    80003292:	1000                	addi	s0,sp,32
    80003294:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003296:	00000097          	auipc	ra,0x0
    8000329a:	ed0080e7          	jalr	-304(ra) # 80003166 <argraw>
    8000329e:	e088                	sd	a0,0(s1)
  return 0;
}
    800032a0:	4501                	li	a0,0
    800032a2:	60e2                	ld	ra,24(sp)
    800032a4:	6442                	ld	s0,16(sp)
    800032a6:	64a2                	ld	s1,8(sp)
    800032a8:	6105                	addi	sp,sp,32
    800032aa:	8082                	ret

00000000800032ac <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800032ac:	1101                	addi	sp,sp,-32
    800032ae:	ec06                	sd	ra,24(sp)
    800032b0:	e822                	sd	s0,16(sp)
    800032b2:	e426                	sd	s1,8(sp)
    800032b4:	e04a                	sd	s2,0(sp)
    800032b6:	1000                	addi	s0,sp,32
    800032b8:	84ae                	mv	s1,a1
    800032ba:	8932                	mv	s2,a2
  *ip = argraw(n);
    800032bc:	00000097          	auipc	ra,0x0
    800032c0:	eaa080e7          	jalr	-342(ra) # 80003166 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800032c4:	864a                	mv	a2,s2
    800032c6:	85a6                	mv	a1,s1
    800032c8:	00000097          	auipc	ra,0x0
    800032cc:	f58080e7          	jalr	-168(ra) # 80003220 <fetchstr>
}
    800032d0:	60e2                	ld	ra,24(sp)
    800032d2:	6442                	ld	s0,16(sp)
    800032d4:	64a2                	ld	s1,8(sp)
    800032d6:	6902                	ld	s2,0(sp)
    800032d8:	6105                	addi	sp,sp,32
    800032da:	8082                	ret

00000000800032dc <syscall>:
[SYS_release_mutex]  sys_release_mutex,
};

void
syscall(void)
{
    800032dc:	1101                	addi	sp,sp,-32
    800032de:	ec06                	sd	ra,24(sp)
    800032e0:	e822                	sd	s0,16(sp)
    800032e2:	e426                	sd	s1,8(sp)
    800032e4:	e04a                	sd	s2,0(sp)
    800032e6:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800032e8:	fffff097          	auipc	ra,0xfffff
    800032ec:	cb4080e7          	jalr	-844(ra) # 80001f9c <myproc>
    800032f0:	84aa                	mv	s1,a0

  num = p->tf->a7;
    800032f2:	07053903          	ld	s2,112(a0)
    800032f6:	0a893783          	ld	a5,168(s2)
    800032fa:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800032fe:	37fd                	addiw	a5,a5,-1
    80003300:	4765                	li	a4,25
    80003302:	00f76f63          	bltu	a4,a5,80003320 <syscall+0x44>
    80003306:	00369713          	slli	a4,a3,0x3
    8000330a:	00006797          	auipc	a5,0x6
    8000330e:	d7678793          	addi	a5,a5,-650 # 80009080 <syscalls>
    80003312:	97ba                	add	a5,a5,a4
    80003314:	639c                	ld	a5,0(a5)
    80003316:	c789                	beqz	a5,80003320 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80003318:	9782                	jalr	a5
    8000331a:	06a93823          	sd	a0,112(s2)
    8000331e:	a839                	j	8000333c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003320:	17048613          	addi	a2,s1,368
    80003324:	48ac                	lw	a1,80(s1)
    80003326:	00005517          	auipc	a0,0x5
    8000332a:	70a50513          	addi	a0,a0,1802 # 80008a30 <userret+0x9a0>
    8000332e:	ffffd097          	auipc	ra,0xffffd
    80003332:	63e080e7          	jalr	1598(ra) # 8000096c <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80003336:	78bc                	ld	a5,112(s1)
    80003338:	577d                	li	a4,-1
    8000333a:	fbb8                	sd	a4,112(a5)
  }
}
    8000333c:	60e2                	ld	ra,24(sp)
    8000333e:	6442                	ld	s0,16(sp)
    80003340:	64a2                	ld	s1,8(sp)
    80003342:	6902                	ld	s2,0(sp)
    80003344:	6105                	addi	sp,sp,32
    80003346:	8082                	ret

0000000080003348 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003348:	1101                	addi	sp,sp,-32
    8000334a:	ec06                	sd	ra,24(sp)
    8000334c:	e822                	sd	s0,16(sp)
    8000334e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003350:	fec40593          	addi	a1,s0,-20
    80003354:	4501                	li	a0,0
    80003356:	00000097          	auipc	ra,0x0
    8000335a:	f12080e7          	jalr	-238(ra) # 80003268 <argint>
    return -1;
    8000335e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003360:	00054963          	bltz	a0,80003372 <sys_exit+0x2a>
  exit(n);
    80003364:	fec42503          	lw	a0,-20(s0)
    80003368:	fffff097          	auipc	ra,0xfffff
    8000336c:	336080e7          	jalr	822(ra) # 8000269e <exit>
  return 0;  // not reached
    80003370:	4781                	li	a5,0
}
    80003372:	853e                	mv	a0,a5
    80003374:	60e2                	ld	ra,24(sp)
    80003376:	6442                	ld	s0,16(sp)
    80003378:	6105                	addi	sp,sp,32
    8000337a:	8082                	ret

000000008000337c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000337c:	1141                	addi	sp,sp,-16
    8000337e:	e406                	sd	ra,8(sp)
    80003380:	e022                	sd	s0,0(sp)
    80003382:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003384:	fffff097          	auipc	ra,0xfffff
    80003388:	c18080e7          	jalr	-1000(ra) # 80001f9c <myproc>
}
    8000338c:	4928                	lw	a0,80(a0)
    8000338e:	60a2                	ld	ra,8(sp)
    80003390:	6402                	ld	s0,0(sp)
    80003392:	0141                	addi	sp,sp,16
    80003394:	8082                	ret

0000000080003396 <sys_fork>:

uint64
sys_fork(void)
{
    80003396:	1141                	addi	sp,sp,-16
    80003398:	e406                	sd	ra,8(sp)
    8000339a:	e022                	sd	s0,0(sp)
    8000339c:	0800                	addi	s0,sp,16
  return fork();
    8000339e:	fffff097          	auipc	ra,0xfffff
    800033a2:	fc0080e7          	jalr	-64(ra) # 8000235e <fork>
}
    800033a6:	60a2                	ld	ra,8(sp)
    800033a8:	6402                	ld	s0,0(sp)
    800033aa:	0141                	addi	sp,sp,16
    800033ac:	8082                	ret

00000000800033ae <sys_wait>:

uint64
sys_wait(void)
{
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800033b6:	fe840593          	addi	a1,s0,-24
    800033ba:	4501                	li	a0,0
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	ece080e7          	jalr	-306(ra) # 8000328a <argaddr>
    800033c4:	87aa                	mv	a5,a0
    return -1;
    800033c6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    800033c8:	0007c863          	bltz	a5,800033d8 <sys_wait+0x2a>
  return wait(p);
    800033cc:	fe843503          	ld	a0,-24(s0)
    800033d0:	fffff097          	auipc	ra,0xfffff
    800033d4:	4d0080e7          	jalr	1232(ra) # 800028a0 <wait>
}
    800033d8:	60e2                	ld	ra,24(sp)
    800033da:	6442                	ld	s0,16(sp)
    800033dc:	6105                	addi	sp,sp,32
    800033de:	8082                	ret

00000000800033e0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800033e0:	7179                	addi	sp,sp,-48
    800033e2:	f406                	sd	ra,40(sp)
    800033e4:	f022                	sd	s0,32(sp)
    800033e6:	ec26                	sd	s1,24(sp)
    800033e8:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800033ea:	fdc40593          	addi	a1,s0,-36
    800033ee:	4501                	li	a0,0
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	e78080e7          	jalr	-392(ra) # 80003268 <argint>
    800033f8:	87aa                	mv	a5,a0
    return -1;
    800033fa:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    800033fc:	0207c063          	bltz	a5,8000341c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003400:	fffff097          	auipc	ra,0xfffff
    80003404:	b9c080e7          	jalr	-1124(ra) # 80001f9c <myproc>
    80003408:	5124                	lw	s1,96(a0)
  if(growproc(n) < 0)
    8000340a:	fdc42503          	lw	a0,-36(s0)
    8000340e:	fffff097          	auipc	ra,0xfffff
    80003412:	edc080e7          	jalr	-292(ra) # 800022ea <growproc>
    80003416:	00054863          	bltz	a0,80003426 <sys_sbrk+0x46>
    return -1;
  return addr;
    8000341a:	8526                	mv	a0,s1
}
    8000341c:	70a2                	ld	ra,40(sp)
    8000341e:	7402                	ld	s0,32(sp)
    80003420:	64e2                	ld	s1,24(sp)
    80003422:	6145                	addi	sp,sp,48
    80003424:	8082                	ret
    return -1;
    80003426:	557d                	li	a0,-1
    80003428:	bfd5                	j	8000341c <sys_sbrk+0x3c>

000000008000342a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000342a:	7139                	addi	sp,sp,-64
    8000342c:	fc06                	sd	ra,56(sp)
    8000342e:	f822                	sd	s0,48(sp)
    80003430:	f426                	sd	s1,40(sp)
    80003432:	f04a                	sd	s2,32(sp)
    80003434:	ec4e                	sd	s3,24(sp)
    80003436:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003438:	fcc40593          	addi	a1,s0,-52
    8000343c:	4501                	li	a0,0
    8000343e:	00000097          	auipc	ra,0x0
    80003442:	e2a080e7          	jalr	-470(ra) # 80003268 <argint>
    return -1;
    80003446:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003448:	06054563          	bltz	a0,800034b2 <sys_sleep+0x88>
  acquire(&tickslock);
    8000344c:	00019517          	auipc	a0,0x19
    80003450:	c4c50513          	addi	a0,a0,-948 # 8001c098 <tickslock>
    80003454:	ffffe097          	auipc	ra,0xffffe
    80003458:	834080e7          	jalr	-1996(ra) # 80000c88 <acquire>
  ticks0 = ticks;
    8000345c:	0002b917          	auipc	s2,0x2b
    80003460:	c2c92903          	lw	s2,-980(s2) # 8002e088 <ticks>
  while(ticks - ticks0 < n){
    80003464:	fcc42783          	lw	a5,-52(s0)
    80003468:	cf85                	beqz	a5,800034a0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000346a:	00019997          	auipc	s3,0x19
    8000346e:	c2e98993          	addi	s3,s3,-978 # 8001c098 <tickslock>
    80003472:	0002b497          	auipc	s1,0x2b
    80003476:	c1648493          	addi	s1,s1,-1002 # 8002e088 <ticks>
    if(myproc()->killed){
    8000347a:	fffff097          	auipc	ra,0xfffff
    8000347e:	b22080e7          	jalr	-1246(ra) # 80001f9c <myproc>
    80003482:	453c                	lw	a5,72(a0)
    80003484:	ef9d                	bnez	a5,800034c2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003486:	85ce                	mv	a1,s3
    80003488:	8526                	mv	a0,s1
    8000348a:	fffff097          	auipc	ra,0xfffff
    8000348e:	398080e7          	jalr	920(ra) # 80002822 <sleep>
  while(ticks - ticks0 < n){
    80003492:	409c                	lw	a5,0(s1)
    80003494:	412787bb          	subw	a5,a5,s2
    80003498:	fcc42703          	lw	a4,-52(s0)
    8000349c:	fce7efe3          	bltu	a5,a4,8000347a <sys_sleep+0x50>
  }
  release(&tickslock);
    800034a0:	00019517          	auipc	a0,0x19
    800034a4:	bf850513          	addi	a0,a0,-1032 # 8001c098 <tickslock>
    800034a8:	ffffe097          	auipc	ra,0xffffe
    800034ac:	a2c080e7          	jalr	-1492(ra) # 80000ed4 <release>
  return 0;
    800034b0:	4781                	li	a5,0
}
    800034b2:	853e                	mv	a0,a5
    800034b4:	70e2                	ld	ra,56(sp)
    800034b6:	7442                	ld	s0,48(sp)
    800034b8:	74a2                	ld	s1,40(sp)
    800034ba:	7902                	ld	s2,32(sp)
    800034bc:	69e2                	ld	s3,24(sp)
    800034be:	6121                	addi	sp,sp,64
    800034c0:	8082                	ret
      release(&tickslock);
    800034c2:	00019517          	auipc	a0,0x19
    800034c6:	bd650513          	addi	a0,a0,-1066 # 8001c098 <tickslock>
    800034ca:	ffffe097          	auipc	ra,0xffffe
    800034ce:	a0a080e7          	jalr	-1526(ra) # 80000ed4 <release>
      return -1;
    800034d2:	57fd                	li	a5,-1
    800034d4:	bff9                	j	800034b2 <sys_sleep+0x88>

00000000800034d6 <sys_nice>:

uint64
sys_nice(void){
    800034d6:	1141                	addi	sp,sp,-16
    800034d8:	e422                	sd	s0,8(sp)
    800034da:	0800                	addi	s0,sp,16
  return 0;
}
    800034dc:	4501                	li	a0,0
    800034de:	6422                	ld	s0,8(sp)
    800034e0:	0141                	addi	sp,sp,16
    800034e2:	8082                	ret

00000000800034e4 <sys_kill>:

uint64
sys_kill(void)
{
    800034e4:	1101                	addi	sp,sp,-32
    800034e6:	ec06                	sd	ra,24(sp)
    800034e8:	e822                	sd	s0,16(sp)
    800034ea:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800034ec:	fec40593          	addi	a1,s0,-20
    800034f0:	4501                	li	a0,0
    800034f2:	00000097          	auipc	ra,0x0
    800034f6:	d76080e7          	jalr	-650(ra) # 80003268 <argint>
    800034fa:	87aa                	mv	a5,a0
    return -1;
    800034fc:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800034fe:	0007c863          	bltz	a5,8000350e <sys_kill+0x2a>
  return kill(pid);
    80003502:	fec42503          	lw	a0,-20(s0)
    80003506:	fffff097          	auipc	ra,0xfffff
    8000350a:	50c080e7          	jalr	1292(ra) # 80002a12 <kill>
}
    8000350e:	60e2                	ld	ra,24(sp)
    80003510:	6442                	ld	s0,16(sp)
    80003512:	6105                	addi	sp,sp,32
    80003514:	8082                	ret

0000000080003516 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003516:	1101                	addi	sp,sp,-32
    80003518:	ec06                	sd	ra,24(sp)
    8000351a:	e822                	sd	s0,16(sp)
    8000351c:	e426                	sd	s1,8(sp)
    8000351e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003520:	00019517          	auipc	a0,0x19
    80003524:	b7850513          	addi	a0,a0,-1160 # 8001c098 <tickslock>
    80003528:	ffffd097          	auipc	ra,0xffffd
    8000352c:	760080e7          	jalr	1888(ra) # 80000c88 <acquire>
  xticks = ticks;
    80003530:	0002b497          	auipc	s1,0x2b
    80003534:	b584a483          	lw	s1,-1192(s1) # 8002e088 <ticks>
  release(&tickslock);
    80003538:	00019517          	auipc	a0,0x19
    8000353c:	b6050513          	addi	a0,a0,-1184 # 8001c098 <tickslock>
    80003540:	ffffe097          	auipc	ra,0xffffe
    80003544:	994080e7          	jalr	-1644(ra) # 80000ed4 <release>
  return xticks;
}
    80003548:	02049513          	slli	a0,s1,0x20
    8000354c:	9101                	srli	a0,a0,0x20
    8000354e:	60e2                	ld	ra,24(sp)
    80003550:	6442                	ld	s0,16(sp)
    80003552:	64a2                	ld	s1,8(sp)
    80003554:	6105                	addi	sp,sp,32
    80003556:	8082                	ret

0000000080003558 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003558:	7179                	addi	sp,sp,-48
    8000355a:	f406                	sd	ra,40(sp)
    8000355c:	f022                	sd	s0,32(sp)
    8000355e:	ec26                	sd	s1,24(sp)
    80003560:	e84a                	sd	s2,16(sp)
    80003562:	e44e                	sd	s3,8(sp)
    80003564:	e052                	sd	s4,0(sp)
    80003566:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003568:	00005597          	auipc	a1,0x5
    8000356c:	e9858593          	addi	a1,a1,-360 # 80008400 <userret+0x370>
    80003570:	00019517          	auipc	a0,0x19
    80003574:	b5850513          	addi	a0,a0,-1192 # 8001c0c8 <bcache>
    80003578:	ffffd097          	auipc	ra,0xffffd
    8000357c:	5a6080e7          	jalr	1446(ra) # 80000b1e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003580:	00021797          	auipc	a5,0x21
    80003584:	b4878793          	addi	a5,a5,-1208 # 800240c8 <bcache+0x8000>
    80003588:	00021717          	auipc	a4,0x21
    8000358c:	09070713          	addi	a4,a4,144 # 80024618 <bcache+0x8550>
    80003590:	5ae7b823          	sd	a4,1456(a5)
  bcache.head.next = &bcache.head;
    80003594:	5ae7bc23          	sd	a4,1464(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003598:	00019497          	auipc	s1,0x19
    8000359c:	b6048493          	addi	s1,s1,-1184 # 8001c0f8 <bcache+0x30>
    b->next = bcache.head.next;
    800035a0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800035a2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800035a4:	00005a17          	auipc	s4,0x5
    800035a8:	4aca0a13          	addi	s4,s4,1196 # 80008a50 <userret+0x9c0>
    b->next = bcache.head.next;
    800035ac:	5b893783          	ld	a5,1464(s2)
    800035b0:	f4bc                	sd	a5,104(s1)
    b->prev = &bcache.head;
    800035b2:	0734b023          	sd	s3,96(s1)
    initsleeplock(&b->lock, "buffer");
    800035b6:	85d2                	mv	a1,s4
    800035b8:	01048513          	addi	a0,s1,16
    800035bc:	00001097          	auipc	ra,0x1
    800035c0:	57c080e7          	jalr	1404(ra) # 80004b38 <initsleeplock>
    bcache.head.next->prev = b;
    800035c4:	5b893783          	ld	a5,1464(s2)
    800035c8:	f3a4                	sd	s1,96(a5)
    bcache.head.next = b;
    800035ca:	5a993c23          	sd	s1,1464(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035ce:	47048493          	addi	s1,s1,1136
    800035d2:	fd349de3          	bne	s1,s3,800035ac <binit+0x54>
  }
}
    800035d6:	70a2                	ld	ra,40(sp)
    800035d8:	7402                	ld	s0,32(sp)
    800035da:	64e2                	ld	s1,24(sp)
    800035dc:	6942                	ld	s2,16(sp)
    800035de:	69a2                	ld	s3,8(sp)
    800035e0:	6a02                	ld	s4,0(sp)
    800035e2:	6145                	addi	sp,sp,48
    800035e4:	8082                	ret

00000000800035e6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800035e6:	7179                	addi	sp,sp,-48
    800035e8:	f406                	sd	ra,40(sp)
    800035ea:	f022                	sd	s0,32(sp)
    800035ec:	ec26                	sd	s1,24(sp)
    800035ee:	e84a                	sd	s2,16(sp)
    800035f0:	e44e                	sd	s3,8(sp)
    800035f2:	1800                	addi	s0,sp,48
    800035f4:	89aa                	mv	s3,a0
    800035f6:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800035f8:	00019517          	auipc	a0,0x19
    800035fc:	ad050513          	addi	a0,a0,-1328 # 8001c0c8 <bcache>
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	688080e7          	jalr	1672(ra) # 80000c88 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003608:	00021497          	auipc	s1,0x21
    8000360c:	0784b483          	ld	s1,120(s1) # 80024680 <bcache+0x85b8>
    80003610:	00021797          	auipc	a5,0x21
    80003614:	00878793          	addi	a5,a5,8 # 80024618 <bcache+0x8550>
    80003618:	02f48f63          	beq	s1,a5,80003656 <bread+0x70>
    8000361c:	873e                	mv	a4,a5
    8000361e:	a021                	j	80003626 <bread+0x40>
    80003620:	74a4                	ld	s1,104(s1)
    80003622:	02e48a63          	beq	s1,a4,80003656 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003626:	449c                	lw	a5,8(s1)
    80003628:	ff379ce3          	bne	a5,s3,80003620 <bread+0x3a>
    8000362c:	44dc                	lw	a5,12(s1)
    8000362e:	ff2799e3          	bne	a5,s2,80003620 <bread+0x3a>
      b->refcnt++;
    80003632:	4cbc                	lw	a5,88(s1)
    80003634:	2785                	addiw	a5,a5,1
    80003636:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    80003638:	00019517          	auipc	a0,0x19
    8000363c:	a9050513          	addi	a0,a0,-1392 # 8001c0c8 <bcache>
    80003640:	ffffe097          	auipc	ra,0xffffe
    80003644:	894080e7          	jalr	-1900(ra) # 80000ed4 <release>
      acquiresleep(&b->lock);
    80003648:	01048513          	addi	a0,s1,16
    8000364c:	00001097          	auipc	ra,0x1
    80003650:	526080e7          	jalr	1318(ra) # 80004b72 <acquiresleep>
      return b;
    80003654:	a8b9                	j	800036b2 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003656:	00021497          	auipc	s1,0x21
    8000365a:	0224b483          	ld	s1,34(s1) # 80024678 <bcache+0x85b0>
    8000365e:	00021797          	auipc	a5,0x21
    80003662:	fba78793          	addi	a5,a5,-70 # 80024618 <bcache+0x8550>
    80003666:	00f48863          	beq	s1,a5,80003676 <bread+0x90>
    8000366a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000366c:	4cbc                	lw	a5,88(s1)
    8000366e:	cf81                	beqz	a5,80003686 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003670:	70a4                	ld	s1,96(s1)
    80003672:	fee49de3          	bne	s1,a4,8000366c <bread+0x86>
  panic("bget: no buffers");
    80003676:	00005517          	auipc	a0,0x5
    8000367a:	3e250513          	addi	a0,a0,994 # 80008a58 <userret+0x9c8>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	0d8080e7          	jalr	216(ra) # 80000756 <panic>
      b->dev = dev;
    80003686:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000368a:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000368e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003692:	4785                	li	a5,1
    80003694:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    80003696:	00019517          	auipc	a0,0x19
    8000369a:	a3250513          	addi	a0,a0,-1486 # 8001c0c8 <bcache>
    8000369e:	ffffe097          	auipc	ra,0xffffe
    800036a2:	836080e7          	jalr	-1994(ra) # 80000ed4 <release>
      acquiresleep(&b->lock);
    800036a6:	01048513          	addi	a0,s1,16
    800036aa:	00001097          	auipc	ra,0x1
    800036ae:	4c8080e7          	jalr	1224(ra) # 80004b72 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800036b2:	409c                	lw	a5,0(s1)
    800036b4:	cb89                	beqz	a5,800036c6 <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    800036b6:	8526                	mv	a0,s1
    800036b8:	70a2                	ld	ra,40(sp)
    800036ba:	7402                	ld	s0,32(sp)
    800036bc:	64e2                	ld	s1,24(sp)
    800036be:	6942                	ld	s2,16(sp)
    800036c0:	69a2                	ld	s3,8(sp)
    800036c2:	6145                	addi	sp,sp,48
    800036c4:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    800036c6:	4601                	li	a2,0
    800036c8:	85a6                	mv	a1,s1
    800036ca:	4488                	lw	a0,8(s1)
    800036cc:	00003097          	auipc	ra,0x3
    800036d0:	122080e7          	jalr	290(ra) # 800067ee <virtio_disk_rw>
    b->valid = 1;
    800036d4:	4785                	li	a5,1
    800036d6:	c09c                	sw	a5,0(s1)
  return b;
    800036d8:	bff9                	j	800036b6 <bread+0xd0>

00000000800036da <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800036da:	1101                	addi	sp,sp,-32
    800036dc:	ec06                	sd	ra,24(sp)
    800036de:	e822                	sd	s0,16(sp)
    800036e0:	e426                	sd	s1,8(sp)
    800036e2:	1000                	addi	s0,sp,32
    800036e4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036e6:	0541                	addi	a0,a0,16
    800036e8:	00001097          	auipc	ra,0x1
    800036ec:	524080e7          	jalr	1316(ra) # 80004c0c <holdingsleep>
    800036f0:	cd09                	beqz	a0,8000370a <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    800036f2:	4605                	li	a2,1
    800036f4:	85a6                	mv	a1,s1
    800036f6:	4488                	lw	a0,8(s1)
    800036f8:	00003097          	auipc	ra,0x3
    800036fc:	0f6080e7          	jalr	246(ra) # 800067ee <virtio_disk_rw>
}
    80003700:	60e2                	ld	ra,24(sp)
    80003702:	6442                	ld	s0,16(sp)
    80003704:	64a2                	ld	s1,8(sp)
    80003706:	6105                	addi	sp,sp,32
    80003708:	8082                	ret
    panic("bwrite");
    8000370a:	00005517          	auipc	a0,0x5
    8000370e:	36650513          	addi	a0,a0,870 # 80008a70 <userret+0x9e0>
    80003712:	ffffd097          	auipc	ra,0xffffd
    80003716:	044080e7          	jalr	68(ra) # 80000756 <panic>

000000008000371a <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    8000371a:	1101                	addi	sp,sp,-32
    8000371c:	ec06                	sd	ra,24(sp)
    8000371e:	e822                	sd	s0,16(sp)
    80003720:	e426                	sd	s1,8(sp)
    80003722:	e04a                	sd	s2,0(sp)
    80003724:	1000                	addi	s0,sp,32
    80003726:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003728:	01050913          	addi	s2,a0,16
    8000372c:	854a                	mv	a0,s2
    8000372e:	00001097          	auipc	ra,0x1
    80003732:	4de080e7          	jalr	1246(ra) # 80004c0c <holdingsleep>
    80003736:	c92d                	beqz	a0,800037a8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003738:	854a                	mv	a0,s2
    8000373a:	00001097          	auipc	ra,0x1
    8000373e:	48e080e7          	jalr	1166(ra) # 80004bc8 <releasesleep>

  acquire(&bcache.lock);
    80003742:	00019517          	auipc	a0,0x19
    80003746:	98650513          	addi	a0,a0,-1658 # 8001c0c8 <bcache>
    8000374a:	ffffd097          	auipc	ra,0xffffd
    8000374e:	53e080e7          	jalr	1342(ra) # 80000c88 <acquire>
  b->refcnt--;
    80003752:	4cbc                	lw	a5,88(s1)
    80003754:	37fd                	addiw	a5,a5,-1
    80003756:	0007871b          	sext.w	a4,a5
    8000375a:	ccbc                	sw	a5,88(s1)
  if (b->refcnt == 0) {
    8000375c:	eb05                	bnez	a4,8000378c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000375e:	74bc                	ld	a5,104(s1)
    80003760:	70b8                	ld	a4,96(s1)
    80003762:	f3b8                	sd	a4,96(a5)
    b->prev->next = b->next;
    80003764:	70bc                	ld	a5,96(s1)
    80003766:	74b8                	ld	a4,104(s1)
    80003768:	f7b8                	sd	a4,104(a5)
    b->next = bcache.head.next;
    8000376a:	00021797          	auipc	a5,0x21
    8000376e:	95e78793          	addi	a5,a5,-1698 # 800240c8 <bcache+0x8000>
    80003772:	5b87b703          	ld	a4,1464(a5)
    80003776:	f4b8                	sd	a4,104(s1)
    b->prev = &bcache.head;
    80003778:	00021717          	auipc	a4,0x21
    8000377c:	ea070713          	addi	a4,a4,-352 # 80024618 <bcache+0x8550>
    80003780:	f0b8                	sd	a4,96(s1)
    bcache.head.next->prev = b;
    80003782:	5b87b703          	ld	a4,1464(a5)
    80003786:	f324                	sd	s1,96(a4)
    bcache.head.next = b;
    80003788:	5a97bc23          	sd	s1,1464(a5)
  }
  
  release(&bcache.lock);
    8000378c:	00019517          	auipc	a0,0x19
    80003790:	93c50513          	addi	a0,a0,-1732 # 8001c0c8 <bcache>
    80003794:	ffffd097          	auipc	ra,0xffffd
    80003798:	740080e7          	jalr	1856(ra) # 80000ed4 <release>
}
    8000379c:	60e2                	ld	ra,24(sp)
    8000379e:	6442                	ld	s0,16(sp)
    800037a0:	64a2                	ld	s1,8(sp)
    800037a2:	6902                	ld	s2,0(sp)
    800037a4:	6105                	addi	sp,sp,32
    800037a6:	8082                	ret
    panic("brelse");
    800037a8:	00005517          	auipc	a0,0x5
    800037ac:	2d050513          	addi	a0,a0,720 # 80008a78 <userret+0x9e8>
    800037b0:	ffffd097          	auipc	ra,0xffffd
    800037b4:	fa6080e7          	jalr	-90(ra) # 80000756 <panic>

00000000800037b8 <bpin>:

void
bpin(struct buf *b) {
    800037b8:	1101                	addi	sp,sp,-32
    800037ba:	ec06                	sd	ra,24(sp)
    800037bc:	e822                	sd	s0,16(sp)
    800037be:	e426                	sd	s1,8(sp)
    800037c0:	1000                	addi	s0,sp,32
    800037c2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037c4:	00019517          	auipc	a0,0x19
    800037c8:	90450513          	addi	a0,a0,-1788 # 8001c0c8 <bcache>
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	4bc080e7          	jalr	1212(ra) # 80000c88 <acquire>
  b->refcnt++;
    800037d4:	4cbc                	lw	a5,88(s1)
    800037d6:	2785                	addiw	a5,a5,1
    800037d8:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    800037da:	00019517          	auipc	a0,0x19
    800037de:	8ee50513          	addi	a0,a0,-1810 # 8001c0c8 <bcache>
    800037e2:	ffffd097          	auipc	ra,0xffffd
    800037e6:	6f2080e7          	jalr	1778(ra) # 80000ed4 <release>
}
    800037ea:	60e2                	ld	ra,24(sp)
    800037ec:	6442                	ld	s0,16(sp)
    800037ee:	64a2                	ld	s1,8(sp)
    800037f0:	6105                	addi	sp,sp,32
    800037f2:	8082                	ret

00000000800037f4 <bunpin>:

void
bunpin(struct buf *b) {
    800037f4:	1101                	addi	sp,sp,-32
    800037f6:	ec06                	sd	ra,24(sp)
    800037f8:	e822                	sd	s0,16(sp)
    800037fa:	e426                	sd	s1,8(sp)
    800037fc:	1000                	addi	s0,sp,32
    800037fe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003800:	00019517          	auipc	a0,0x19
    80003804:	8c850513          	addi	a0,a0,-1848 # 8001c0c8 <bcache>
    80003808:	ffffd097          	auipc	ra,0xffffd
    8000380c:	480080e7          	jalr	1152(ra) # 80000c88 <acquire>
  b->refcnt--;
    80003810:	4cbc                	lw	a5,88(s1)
    80003812:	37fd                	addiw	a5,a5,-1
    80003814:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    80003816:	00019517          	auipc	a0,0x19
    8000381a:	8b250513          	addi	a0,a0,-1870 # 8001c0c8 <bcache>
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	6b6080e7          	jalr	1718(ra) # 80000ed4 <release>
}
    80003826:	60e2                	ld	ra,24(sp)
    80003828:	6442                	ld	s0,16(sp)
    8000382a:	64a2                	ld	s1,8(sp)
    8000382c:	6105                	addi	sp,sp,32
    8000382e:	8082                	ret

0000000080003830 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003830:	1101                	addi	sp,sp,-32
    80003832:	ec06                	sd	ra,24(sp)
    80003834:	e822                	sd	s0,16(sp)
    80003836:	e426                	sd	s1,8(sp)
    80003838:	e04a                	sd	s2,0(sp)
    8000383a:	1000                	addi	s0,sp,32
    8000383c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000383e:	00d5d59b          	srliw	a1,a1,0xd
    80003842:	00021797          	auipc	a5,0x21
    80003846:	2627a783          	lw	a5,610(a5) # 80024aa4 <sb+0x1c>
    8000384a:	9dbd                	addw	a1,a1,a5
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	d9a080e7          	jalr	-614(ra) # 800035e6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003854:	0074f713          	andi	a4,s1,7
    80003858:	4785                	li	a5,1
    8000385a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000385e:	14ce                	slli	s1,s1,0x33
    80003860:	90d9                	srli	s1,s1,0x36
    80003862:	00950733          	add	a4,a0,s1
    80003866:	07074703          	lbu	a4,112(a4)
    8000386a:	00e7f6b3          	and	a3,a5,a4
    8000386e:	c69d                	beqz	a3,8000389c <bfree+0x6c>
    80003870:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003872:	94aa                	add	s1,s1,a0
    80003874:	fff7c793          	not	a5,a5
    80003878:	8ff9                	and	a5,a5,a4
    8000387a:	06f48823          	sb	a5,112(s1)
  log_write(bp);
    8000387e:	00001097          	auipc	ra,0x1
    80003882:	188080e7          	jalr	392(ra) # 80004a06 <log_write>
  brelse(bp);
    80003886:	854a                	mv	a0,s2
    80003888:	00000097          	auipc	ra,0x0
    8000388c:	e92080e7          	jalr	-366(ra) # 8000371a <brelse>
}
    80003890:	60e2                	ld	ra,24(sp)
    80003892:	6442                	ld	s0,16(sp)
    80003894:	64a2                	ld	s1,8(sp)
    80003896:	6902                	ld	s2,0(sp)
    80003898:	6105                	addi	sp,sp,32
    8000389a:	8082                	ret
    panic("freeing free block");
    8000389c:	00005517          	auipc	a0,0x5
    800038a0:	1e450513          	addi	a0,a0,484 # 80008a80 <userret+0x9f0>
    800038a4:	ffffd097          	auipc	ra,0xffffd
    800038a8:	eb2080e7          	jalr	-334(ra) # 80000756 <panic>

00000000800038ac <balloc>:
{
    800038ac:	711d                	addi	sp,sp,-96
    800038ae:	ec86                	sd	ra,88(sp)
    800038b0:	e8a2                	sd	s0,80(sp)
    800038b2:	e4a6                	sd	s1,72(sp)
    800038b4:	e0ca                	sd	s2,64(sp)
    800038b6:	fc4e                	sd	s3,56(sp)
    800038b8:	f852                	sd	s4,48(sp)
    800038ba:	f456                	sd	s5,40(sp)
    800038bc:	f05a                	sd	s6,32(sp)
    800038be:	ec5e                	sd	s7,24(sp)
    800038c0:	e862                	sd	s8,16(sp)
    800038c2:	e466                	sd	s9,8(sp)
    800038c4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800038c6:	00021797          	auipc	a5,0x21
    800038ca:	1c67a783          	lw	a5,454(a5) # 80024a8c <sb+0x4>
    800038ce:	cbd1                	beqz	a5,80003962 <balloc+0xb6>
    800038d0:	8baa                	mv	s7,a0
    800038d2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800038d4:	00021b17          	auipc	s6,0x21
    800038d8:	1b4b0b13          	addi	s6,s6,436 # 80024a88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038dc:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800038de:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038e0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800038e2:	6c89                	lui	s9,0x2
    800038e4:	a831                	j	80003900 <balloc+0x54>
    brelse(bp);
    800038e6:	854a                	mv	a0,s2
    800038e8:	00000097          	auipc	ra,0x0
    800038ec:	e32080e7          	jalr	-462(ra) # 8000371a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800038f0:	015c87bb          	addw	a5,s9,s5
    800038f4:	00078a9b          	sext.w	s5,a5
    800038f8:	004b2703          	lw	a4,4(s6)
    800038fc:	06eaf363          	bgeu	s5,a4,80003962 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003900:	41fad79b          	sraiw	a5,s5,0x1f
    80003904:	0137d79b          	srliw	a5,a5,0x13
    80003908:	015787bb          	addw	a5,a5,s5
    8000390c:	40d7d79b          	sraiw	a5,a5,0xd
    80003910:	01cb2583          	lw	a1,28(s6)
    80003914:	9dbd                	addw	a1,a1,a5
    80003916:	855e                	mv	a0,s7
    80003918:	00000097          	auipc	ra,0x0
    8000391c:	cce080e7          	jalr	-818(ra) # 800035e6 <bread>
    80003920:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003922:	004b2503          	lw	a0,4(s6)
    80003926:	000a849b          	sext.w	s1,s5
    8000392a:	8662                	mv	a2,s8
    8000392c:	faa4fde3          	bgeu	s1,a0,800038e6 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003930:	41f6579b          	sraiw	a5,a2,0x1f
    80003934:	01d7d69b          	srliw	a3,a5,0x1d
    80003938:	00c6873b          	addw	a4,a3,a2
    8000393c:	00777793          	andi	a5,a4,7
    80003940:	9f95                	subw	a5,a5,a3
    80003942:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003946:	4037571b          	sraiw	a4,a4,0x3
    8000394a:	00e906b3          	add	a3,s2,a4
    8000394e:	0706c683          	lbu	a3,112(a3)
    80003952:	00d7f5b3          	and	a1,a5,a3
    80003956:	cd91                	beqz	a1,80003972 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003958:	2605                	addiw	a2,a2,1
    8000395a:	2485                	addiw	s1,s1,1
    8000395c:	fd4618e3          	bne	a2,s4,8000392c <balloc+0x80>
    80003960:	b759                	j	800038e6 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003962:	00005517          	auipc	a0,0x5
    80003966:	13650513          	addi	a0,a0,310 # 80008a98 <userret+0xa08>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	dec080e7          	jalr	-532(ra) # 80000756 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003972:	974a                	add	a4,a4,s2
    80003974:	8fd5                	or	a5,a5,a3
    80003976:	06f70823          	sb	a5,112(a4)
        log_write(bp);
    8000397a:	854a                	mv	a0,s2
    8000397c:	00001097          	auipc	ra,0x1
    80003980:	08a080e7          	jalr	138(ra) # 80004a06 <log_write>
        brelse(bp);
    80003984:	854a                	mv	a0,s2
    80003986:	00000097          	auipc	ra,0x0
    8000398a:	d94080e7          	jalr	-620(ra) # 8000371a <brelse>
  bp = bread(dev, bno);
    8000398e:	85a6                	mv	a1,s1
    80003990:	855e                	mv	a0,s7
    80003992:	00000097          	auipc	ra,0x0
    80003996:	c54080e7          	jalr	-940(ra) # 800035e6 <bread>
    8000399a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000399c:	40000613          	li	a2,1024
    800039a0:	4581                	li	a1,0
    800039a2:	07050513          	addi	a0,a0,112
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	72e080e7          	jalr	1838(ra) # 800010d4 <memset>
  log_write(bp);
    800039ae:	854a                	mv	a0,s2
    800039b0:	00001097          	auipc	ra,0x1
    800039b4:	056080e7          	jalr	86(ra) # 80004a06 <log_write>
  brelse(bp);
    800039b8:	854a                	mv	a0,s2
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	d60080e7          	jalr	-672(ra) # 8000371a <brelse>
}
    800039c2:	8526                	mv	a0,s1
    800039c4:	60e6                	ld	ra,88(sp)
    800039c6:	6446                	ld	s0,80(sp)
    800039c8:	64a6                	ld	s1,72(sp)
    800039ca:	6906                	ld	s2,64(sp)
    800039cc:	79e2                	ld	s3,56(sp)
    800039ce:	7a42                	ld	s4,48(sp)
    800039d0:	7aa2                	ld	s5,40(sp)
    800039d2:	7b02                	ld	s6,32(sp)
    800039d4:	6be2                	ld	s7,24(sp)
    800039d6:	6c42                	ld	s8,16(sp)
    800039d8:	6ca2                	ld	s9,8(sp)
    800039da:	6125                	addi	sp,sp,96
    800039dc:	8082                	ret

00000000800039de <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800039de:	7179                	addi	sp,sp,-48
    800039e0:	f406                	sd	ra,40(sp)
    800039e2:	f022                	sd	s0,32(sp)
    800039e4:	ec26                	sd	s1,24(sp)
    800039e6:	e84a                	sd	s2,16(sp)
    800039e8:	e44e                	sd	s3,8(sp)
    800039ea:	e052                	sd	s4,0(sp)
    800039ec:	1800                	addi	s0,sp,48
    800039ee:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800039f0:	47ad                	li	a5,11
    800039f2:	04b7fe63          	bgeu	a5,a1,80003a4e <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800039f6:	ff45849b          	addiw	s1,a1,-12
    800039fa:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039fe:	0ff00793          	li	a5,255
    80003a02:	0ae7e363          	bltu	a5,a4,80003aa8 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003a06:	09852583          	lw	a1,152(a0)
    80003a0a:	c5ad                	beqz	a1,80003a74 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003a0c:	00092503          	lw	a0,0(s2)
    80003a10:	00000097          	auipc	ra,0x0
    80003a14:	bd6080e7          	jalr	-1066(ra) # 800035e6 <bread>
    80003a18:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a1a:	07050793          	addi	a5,a0,112
    if((addr = a[bn]) == 0){
    80003a1e:	02049593          	slli	a1,s1,0x20
    80003a22:	9181                	srli	a1,a1,0x20
    80003a24:	058a                	slli	a1,a1,0x2
    80003a26:	00b784b3          	add	s1,a5,a1
    80003a2a:	0004a983          	lw	s3,0(s1)
    80003a2e:	04098d63          	beqz	s3,80003a88 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003a32:	8552                	mv	a0,s4
    80003a34:	00000097          	auipc	ra,0x0
    80003a38:	ce6080e7          	jalr	-794(ra) # 8000371a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003a3c:	854e                	mv	a0,s3
    80003a3e:	70a2                	ld	ra,40(sp)
    80003a40:	7402                	ld	s0,32(sp)
    80003a42:	64e2                	ld	s1,24(sp)
    80003a44:	6942                	ld	s2,16(sp)
    80003a46:	69a2                	ld	s3,8(sp)
    80003a48:	6a02                	ld	s4,0(sp)
    80003a4a:	6145                	addi	sp,sp,48
    80003a4c:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003a4e:	02059493          	slli	s1,a1,0x20
    80003a52:	9081                	srli	s1,s1,0x20
    80003a54:	048a                	slli	s1,s1,0x2
    80003a56:	94aa                	add	s1,s1,a0
    80003a58:	0684a983          	lw	s3,104(s1)
    80003a5c:	fe0990e3          	bnez	s3,80003a3c <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003a60:	4108                	lw	a0,0(a0)
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	e4a080e7          	jalr	-438(ra) # 800038ac <balloc>
    80003a6a:	0005099b          	sext.w	s3,a0
    80003a6e:	0734a423          	sw	s3,104(s1)
    80003a72:	b7e9                	j	80003a3c <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003a74:	4108                	lw	a0,0(a0)
    80003a76:	00000097          	auipc	ra,0x0
    80003a7a:	e36080e7          	jalr	-458(ra) # 800038ac <balloc>
    80003a7e:	0005059b          	sext.w	a1,a0
    80003a82:	08b92c23          	sw	a1,152(s2)
    80003a86:	b759                	j	80003a0c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003a88:	00092503          	lw	a0,0(s2)
    80003a8c:	00000097          	auipc	ra,0x0
    80003a90:	e20080e7          	jalr	-480(ra) # 800038ac <balloc>
    80003a94:	0005099b          	sext.w	s3,a0
    80003a98:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003a9c:	8552                	mv	a0,s4
    80003a9e:	00001097          	auipc	ra,0x1
    80003aa2:	f68080e7          	jalr	-152(ra) # 80004a06 <log_write>
    80003aa6:	b771                	j	80003a32 <bmap+0x54>
  panic("bmap: out of range");
    80003aa8:	00005517          	auipc	a0,0x5
    80003aac:	00850513          	addi	a0,a0,8 # 80008ab0 <userret+0xa20>
    80003ab0:	ffffd097          	auipc	ra,0xffffd
    80003ab4:	ca6080e7          	jalr	-858(ra) # 80000756 <panic>

0000000080003ab8 <iget>:
{
    80003ab8:	7179                	addi	sp,sp,-48
    80003aba:	f406                	sd	ra,40(sp)
    80003abc:	f022                	sd	s0,32(sp)
    80003abe:	ec26                	sd	s1,24(sp)
    80003ac0:	e84a                	sd	s2,16(sp)
    80003ac2:	e44e                	sd	s3,8(sp)
    80003ac4:	e052                	sd	s4,0(sp)
    80003ac6:	1800                	addi	s0,sp,48
    80003ac8:	89aa                	mv	s3,a0
    80003aca:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003acc:	00021517          	auipc	a0,0x21
    80003ad0:	fdc50513          	addi	a0,a0,-36 # 80024aa8 <icache>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	1b4080e7          	jalr	436(ra) # 80000c88 <acquire>
  empty = 0;
    80003adc:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003ade:	00021497          	auipc	s1,0x21
    80003ae2:	ffa48493          	addi	s1,s1,-6 # 80024ad8 <icache+0x30>
    80003ae6:	00023697          	auipc	a3,0x23
    80003aea:	f3268693          	addi	a3,a3,-206 # 80026a18 <log>
    80003aee:	a039                	j	80003afc <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003af0:	02090b63          	beqz	s2,80003b26 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003af4:	0a048493          	addi	s1,s1,160
    80003af8:	02d48a63          	beq	s1,a3,80003b2c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003afc:	449c                	lw	a5,8(s1)
    80003afe:	fef059e3          	blez	a5,80003af0 <iget+0x38>
    80003b02:	4098                	lw	a4,0(s1)
    80003b04:	ff3716e3          	bne	a4,s3,80003af0 <iget+0x38>
    80003b08:	40d8                	lw	a4,4(s1)
    80003b0a:	ff4713e3          	bne	a4,s4,80003af0 <iget+0x38>
      ip->ref++;
    80003b0e:	2785                	addiw	a5,a5,1
    80003b10:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003b12:	00021517          	auipc	a0,0x21
    80003b16:	f9650513          	addi	a0,a0,-106 # 80024aa8 <icache>
    80003b1a:	ffffd097          	auipc	ra,0xffffd
    80003b1e:	3ba080e7          	jalr	954(ra) # 80000ed4 <release>
      return ip;
    80003b22:	8926                	mv	s2,s1
    80003b24:	a03d                	j	80003b52 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b26:	f7f9                	bnez	a5,80003af4 <iget+0x3c>
    80003b28:	8926                	mv	s2,s1
    80003b2a:	b7e9                	j	80003af4 <iget+0x3c>
  if(empty == 0)
    80003b2c:	02090c63          	beqz	s2,80003b64 <iget+0xac>
  ip->dev = dev;
    80003b30:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b34:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b38:	4785                	li	a5,1
    80003b3a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b3e:	04092c23          	sw	zero,88(s2)
  release(&icache.lock);
    80003b42:	00021517          	auipc	a0,0x21
    80003b46:	f6650513          	addi	a0,a0,-154 # 80024aa8 <icache>
    80003b4a:	ffffd097          	auipc	ra,0xffffd
    80003b4e:	38a080e7          	jalr	906(ra) # 80000ed4 <release>
}
    80003b52:	854a                	mv	a0,s2
    80003b54:	70a2                	ld	ra,40(sp)
    80003b56:	7402                	ld	s0,32(sp)
    80003b58:	64e2                	ld	s1,24(sp)
    80003b5a:	6942                	ld	s2,16(sp)
    80003b5c:	69a2                	ld	s3,8(sp)
    80003b5e:	6a02                	ld	s4,0(sp)
    80003b60:	6145                	addi	sp,sp,48
    80003b62:	8082                	ret
    panic("iget: no inodes");
    80003b64:	00005517          	auipc	a0,0x5
    80003b68:	f6450513          	addi	a0,a0,-156 # 80008ac8 <userret+0xa38>
    80003b6c:	ffffd097          	auipc	ra,0xffffd
    80003b70:	bea080e7          	jalr	-1046(ra) # 80000756 <panic>

0000000080003b74 <fsinit>:
fsinit(int dev) {
    80003b74:	7179                	addi	sp,sp,-48
    80003b76:	f406                	sd	ra,40(sp)
    80003b78:	f022                	sd	s0,32(sp)
    80003b7a:	ec26                	sd	s1,24(sp)
    80003b7c:	e84a                	sd	s2,16(sp)
    80003b7e:	e44e                	sd	s3,8(sp)
    80003b80:	1800                	addi	s0,sp,48
    80003b82:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b84:	4585                	li	a1,1
    80003b86:	00000097          	auipc	ra,0x0
    80003b8a:	a60080e7          	jalr	-1440(ra) # 800035e6 <bread>
    80003b8e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b90:	00021997          	auipc	s3,0x21
    80003b94:	ef898993          	addi	s3,s3,-264 # 80024a88 <sb>
    80003b98:	02000613          	li	a2,32
    80003b9c:	07050593          	addi	a1,a0,112
    80003ba0:	854e                	mv	a0,s3
    80003ba2:	ffffd097          	auipc	ra,0xffffd
    80003ba6:	592080e7          	jalr	1426(ra) # 80001134 <memmove>
  brelse(bp);
    80003baa:	8526                	mv	a0,s1
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	b6e080e7          	jalr	-1170(ra) # 8000371a <brelse>
  if(sb.magic != FSMAGIC)
    80003bb4:	0009a703          	lw	a4,0(s3)
    80003bb8:	102037b7          	lui	a5,0x10203
    80003bbc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003bc0:	02f71263          	bne	a4,a5,80003be4 <fsinit+0x70>
  initlog(dev, &sb);
    80003bc4:	00021597          	auipc	a1,0x21
    80003bc8:	ec458593          	addi	a1,a1,-316 # 80024a88 <sb>
    80003bcc:	854a                	mv	a0,s2
    80003bce:	00001097          	auipc	ra,0x1
    80003bd2:	b22080e7          	jalr	-1246(ra) # 800046f0 <initlog>
}
    80003bd6:	70a2                	ld	ra,40(sp)
    80003bd8:	7402                	ld	s0,32(sp)
    80003bda:	64e2                	ld	s1,24(sp)
    80003bdc:	6942                	ld	s2,16(sp)
    80003bde:	69a2                	ld	s3,8(sp)
    80003be0:	6145                	addi	sp,sp,48
    80003be2:	8082                	ret
    panic("invalid file system");
    80003be4:	00005517          	auipc	a0,0x5
    80003be8:	ef450513          	addi	a0,a0,-268 # 80008ad8 <userret+0xa48>
    80003bec:	ffffd097          	auipc	ra,0xffffd
    80003bf0:	b6a080e7          	jalr	-1174(ra) # 80000756 <panic>

0000000080003bf4 <iinit>:
{
    80003bf4:	7179                	addi	sp,sp,-48
    80003bf6:	f406                	sd	ra,40(sp)
    80003bf8:	f022                	sd	s0,32(sp)
    80003bfa:	ec26                	sd	s1,24(sp)
    80003bfc:	e84a                	sd	s2,16(sp)
    80003bfe:	e44e                	sd	s3,8(sp)
    80003c00:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003c02:	00005597          	auipc	a1,0x5
    80003c06:	eee58593          	addi	a1,a1,-274 # 80008af0 <userret+0xa60>
    80003c0a:	00021517          	auipc	a0,0x21
    80003c0e:	e9e50513          	addi	a0,a0,-354 # 80024aa8 <icache>
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	f0c080e7          	jalr	-244(ra) # 80000b1e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003c1a:	00021497          	auipc	s1,0x21
    80003c1e:	ece48493          	addi	s1,s1,-306 # 80024ae8 <icache+0x40>
    80003c22:	00023997          	auipc	s3,0x23
    80003c26:	e0698993          	addi	s3,s3,-506 # 80026a28 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003c2a:	00005917          	auipc	s2,0x5
    80003c2e:	ece90913          	addi	s2,s2,-306 # 80008af8 <userret+0xa68>
    80003c32:	85ca                	mv	a1,s2
    80003c34:	8526                	mv	a0,s1
    80003c36:	00001097          	auipc	ra,0x1
    80003c3a:	f02080e7          	jalr	-254(ra) # 80004b38 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c3e:	0a048493          	addi	s1,s1,160
    80003c42:	ff3498e3          	bne	s1,s3,80003c32 <iinit+0x3e>
}
    80003c46:	70a2                	ld	ra,40(sp)
    80003c48:	7402                	ld	s0,32(sp)
    80003c4a:	64e2                	ld	s1,24(sp)
    80003c4c:	6942                	ld	s2,16(sp)
    80003c4e:	69a2                	ld	s3,8(sp)
    80003c50:	6145                	addi	sp,sp,48
    80003c52:	8082                	ret

0000000080003c54 <ialloc>:
{
    80003c54:	715d                	addi	sp,sp,-80
    80003c56:	e486                	sd	ra,72(sp)
    80003c58:	e0a2                	sd	s0,64(sp)
    80003c5a:	fc26                	sd	s1,56(sp)
    80003c5c:	f84a                	sd	s2,48(sp)
    80003c5e:	f44e                	sd	s3,40(sp)
    80003c60:	f052                	sd	s4,32(sp)
    80003c62:	ec56                	sd	s5,24(sp)
    80003c64:	e85a                	sd	s6,16(sp)
    80003c66:	e45e                	sd	s7,8(sp)
    80003c68:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c6a:	00021717          	auipc	a4,0x21
    80003c6e:	e2a72703          	lw	a4,-470(a4) # 80024a94 <sb+0xc>
    80003c72:	4785                	li	a5,1
    80003c74:	04e7fa63          	bgeu	a5,a4,80003cc8 <ialloc+0x74>
    80003c78:	8aaa                	mv	s5,a0
    80003c7a:	8bae                	mv	s7,a1
    80003c7c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c7e:	00021a17          	auipc	s4,0x21
    80003c82:	e0aa0a13          	addi	s4,s4,-502 # 80024a88 <sb>
    80003c86:	00048b1b          	sext.w	s6,s1
    80003c8a:	0044d593          	srli	a1,s1,0x4
    80003c8e:	018a2783          	lw	a5,24(s4)
    80003c92:	9dbd                	addw	a1,a1,a5
    80003c94:	8556                	mv	a0,s5
    80003c96:	00000097          	auipc	ra,0x0
    80003c9a:	950080e7          	jalr	-1712(ra) # 800035e6 <bread>
    80003c9e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ca0:	07050993          	addi	s3,a0,112
    80003ca4:	00f4f793          	andi	a5,s1,15
    80003ca8:	079a                	slli	a5,a5,0x6
    80003caa:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003cac:	00099783          	lh	a5,0(s3)
    80003cb0:	c785                	beqz	a5,80003cd8 <ialloc+0x84>
    brelse(bp);
    80003cb2:	00000097          	auipc	ra,0x0
    80003cb6:	a68080e7          	jalr	-1432(ra) # 8000371a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003cba:	0485                	addi	s1,s1,1
    80003cbc:	00ca2703          	lw	a4,12(s4)
    80003cc0:	0004879b          	sext.w	a5,s1
    80003cc4:	fce7e1e3          	bltu	a5,a4,80003c86 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003cc8:	00005517          	auipc	a0,0x5
    80003ccc:	e3850513          	addi	a0,a0,-456 # 80008b00 <userret+0xa70>
    80003cd0:	ffffd097          	auipc	ra,0xffffd
    80003cd4:	a86080e7          	jalr	-1402(ra) # 80000756 <panic>
      memset(dip, 0, sizeof(*dip));
    80003cd8:	04000613          	li	a2,64
    80003cdc:	4581                	li	a1,0
    80003cde:	854e                	mv	a0,s3
    80003ce0:	ffffd097          	auipc	ra,0xffffd
    80003ce4:	3f4080e7          	jalr	1012(ra) # 800010d4 <memset>
      dip->type = type;
    80003ce8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003cec:	854a                	mv	a0,s2
    80003cee:	00001097          	auipc	ra,0x1
    80003cf2:	d18080e7          	jalr	-744(ra) # 80004a06 <log_write>
      brelse(bp);
    80003cf6:	854a                	mv	a0,s2
    80003cf8:	00000097          	auipc	ra,0x0
    80003cfc:	a22080e7          	jalr	-1502(ra) # 8000371a <brelse>
      return iget(dev, inum);
    80003d00:	85da                	mv	a1,s6
    80003d02:	8556                	mv	a0,s5
    80003d04:	00000097          	auipc	ra,0x0
    80003d08:	db4080e7          	jalr	-588(ra) # 80003ab8 <iget>
}
    80003d0c:	60a6                	ld	ra,72(sp)
    80003d0e:	6406                	ld	s0,64(sp)
    80003d10:	74e2                	ld	s1,56(sp)
    80003d12:	7942                	ld	s2,48(sp)
    80003d14:	79a2                	ld	s3,40(sp)
    80003d16:	7a02                	ld	s4,32(sp)
    80003d18:	6ae2                	ld	s5,24(sp)
    80003d1a:	6b42                	ld	s6,16(sp)
    80003d1c:	6ba2                	ld	s7,8(sp)
    80003d1e:	6161                	addi	sp,sp,80
    80003d20:	8082                	ret

0000000080003d22 <iupdate>:
{
    80003d22:	1101                	addi	sp,sp,-32
    80003d24:	ec06                	sd	ra,24(sp)
    80003d26:	e822                	sd	s0,16(sp)
    80003d28:	e426                	sd	s1,8(sp)
    80003d2a:	e04a                	sd	s2,0(sp)
    80003d2c:	1000                	addi	s0,sp,32
    80003d2e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d30:	415c                	lw	a5,4(a0)
    80003d32:	0047d79b          	srliw	a5,a5,0x4
    80003d36:	00021597          	auipc	a1,0x21
    80003d3a:	d6a5a583          	lw	a1,-662(a1) # 80024aa0 <sb+0x18>
    80003d3e:	9dbd                	addw	a1,a1,a5
    80003d40:	4108                	lw	a0,0(a0)
    80003d42:	00000097          	auipc	ra,0x0
    80003d46:	8a4080e7          	jalr	-1884(ra) # 800035e6 <bread>
    80003d4a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d4c:	07050793          	addi	a5,a0,112
    80003d50:	40c8                	lw	a0,4(s1)
    80003d52:	893d                	andi	a0,a0,15
    80003d54:	051a                	slli	a0,a0,0x6
    80003d56:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003d58:	05c49703          	lh	a4,92(s1)
    80003d5c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003d60:	05e49703          	lh	a4,94(s1)
    80003d64:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003d68:	06049703          	lh	a4,96(s1)
    80003d6c:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003d70:	06249703          	lh	a4,98(s1)
    80003d74:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003d78:	50f8                	lw	a4,100(s1)
    80003d7a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d7c:	03400613          	li	a2,52
    80003d80:	06848593          	addi	a1,s1,104
    80003d84:	0531                	addi	a0,a0,12
    80003d86:	ffffd097          	auipc	ra,0xffffd
    80003d8a:	3ae080e7          	jalr	942(ra) # 80001134 <memmove>
  log_write(bp);
    80003d8e:	854a                	mv	a0,s2
    80003d90:	00001097          	auipc	ra,0x1
    80003d94:	c76080e7          	jalr	-906(ra) # 80004a06 <log_write>
  brelse(bp);
    80003d98:	854a                	mv	a0,s2
    80003d9a:	00000097          	auipc	ra,0x0
    80003d9e:	980080e7          	jalr	-1664(ra) # 8000371a <brelse>
}
    80003da2:	60e2                	ld	ra,24(sp)
    80003da4:	6442                	ld	s0,16(sp)
    80003da6:	64a2                	ld	s1,8(sp)
    80003da8:	6902                	ld	s2,0(sp)
    80003daa:	6105                	addi	sp,sp,32
    80003dac:	8082                	ret

0000000080003dae <idup>:
{
    80003dae:	1101                	addi	sp,sp,-32
    80003db0:	ec06                	sd	ra,24(sp)
    80003db2:	e822                	sd	s0,16(sp)
    80003db4:	e426                	sd	s1,8(sp)
    80003db6:	1000                	addi	s0,sp,32
    80003db8:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003dba:	00021517          	auipc	a0,0x21
    80003dbe:	cee50513          	addi	a0,a0,-786 # 80024aa8 <icache>
    80003dc2:	ffffd097          	auipc	ra,0xffffd
    80003dc6:	ec6080e7          	jalr	-314(ra) # 80000c88 <acquire>
  ip->ref++;
    80003dca:	449c                	lw	a5,8(s1)
    80003dcc:	2785                	addiw	a5,a5,1
    80003dce:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003dd0:	00021517          	auipc	a0,0x21
    80003dd4:	cd850513          	addi	a0,a0,-808 # 80024aa8 <icache>
    80003dd8:	ffffd097          	auipc	ra,0xffffd
    80003ddc:	0fc080e7          	jalr	252(ra) # 80000ed4 <release>
}
    80003de0:	8526                	mv	a0,s1
    80003de2:	60e2                	ld	ra,24(sp)
    80003de4:	6442                	ld	s0,16(sp)
    80003de6:	64a2                	ld	s1,8(sp)
    80003de8:	6105                	addi	sp,sp,32
    80003dea:	8082                	ret

0000000080003dec <ilock>:
{
    80003dec:	1101                	addi	sp,sp,-32
    80003dee:	ec06                	sd	ra,24(sp)
    80003df0:	e822                	sd	s0,16(sp)
    80003df2:	e426                	sd	s1,8(sp)
    80003df4:	e04a                	sd	s2,0(sp)
    80003df6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003df8:	c115                	beqz	a0,80003e1c <ilock+0x30>
    80003dfa:	84aa                	mv	s1,a0
    80003dfc:	451c                	lw	a5,8(a0)
    80003dfe:	00f05f63          	blez	a5,80003e1c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003e02:	0541                	addi	a0,a0,16
    80003e04:	00001097          	auipc	ra,0x1
    80003e08:	d6e080e7          	jalr	-658(ra) # 80004b72 <acquiresleep>
  if(ip->valid == 0){
    80003e0c:	4cbc                	lw	a5,88(s1)
    80003e0e:	cf99                	beqz	a5,80003e2c <ilock+0x40>
}
    80003e10:	60e2                	ld	ra,24(sp)
    80003e12:	6442                	ld	s0,16(sp)
    80003e14:	64a2                	ld	s1,8(sp)
    80003e16:	6902                	ld	s2,0(sp)
    80003e18:	6105                	addi	sp,sp,32
    80003e1a:	8082                	ret
    panic("ilock");
    80003e1c:	00005517          	auipc	a0,0x5
    80003e20:	cfc50513          	addi	a0,a0,-772 # 80008b18 <userret+0xa88>
    80003e24:	ffffd097          	auipc	ra,0xffffd
    80003e28:	932080e7          	jalr	-1742(ra) # 80000756 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e2c:	40dc                	lw	a5,4(s1)
    80003e2e:	0047d79b          	srliw	a5,a5,0x4
    80003e32:	00021597          	auipc	a1,0x21
    80003e36:	c6e5a583          	lw	a1,-914(a1) # 80024aa0 <sb+0x18>
    80003e3a:	9dbd                	addw	a1,a1,a5
    80003e3c:	4088                	lw	a0,0(s1)
    80003e3e:	fffff097          	auipc	ra,0xfffff
    80003e42:	7a8080e7          	jalr	1960(ra) # 800035e6 <bread>
    80003e46:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e48:	07050593          	addi	a1,a0,112
    80003e4c:	40dc                	lw	a5,4(s1)
    80003e4e:	8bbd                	andi	a5,a5,15
    80003e50:	079a                	slli	a5,a5,0x6
    80003e52:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e54:	00059783          	lh	a5,0(a1)
    80003e58:	04f49e23          	sh	a5,92(s1)
    ip->major = dip->major;
    80003e5c:	00259783          	lh	a5,2(a1)
    80003e60:	04f49f23          	sh	a5,94(s1)
    ip->minor = dip->minor;
    80003e64:	00459783          	lh	a5,4(a1)
    80003e68:	06f49023          	sh	a5,96(s1)
    ip->nlink = dip->nlink;
    80003e6c:	00659783          	lh	a5,6(a1)
    80003e70:	06f49123          	sh	a5,98(s1)
    ip->size = dip->size;
    80003e74:	459c                	lw	a5,8(a1)
    80003e76:	d0fc                	sw	a5,100(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e78:	03400613          	li	a2,52
    80003e7c:	05b1                	addi	a1,a1,12
    80003e7e:	06848513          	addi	a0,s1,104
    80003e82:	ffffd097          	auipc	ra,0xffffd
    80003e86:	2b2080e7          	jalr	690(ra) # 80001134 <memmove>
    brelse(bp);
    80003e8a:	854a                	mv	a0,s2
    80003e8c:	00000097          	auipc	ra,0x0
    80003e90:	88e080e7          	jalr	-1906(ra) # 8000371a <brelse>
    ip->valid = 1;
    80003e94:	4785                	li	a5,1
    80003e96:	ccbc                	sw	a5,88(s1)
    if(ip->type == 0)
    80003e98:	05c49783          	lh	a5,92(s1)
    80003e9c:	fbb5                	bnez	a5,80003e10 <ilock+0x24>
      panic("ilock: no type");
    80003e9e:	00005517          	auipc	a0,0x5
    80003ea2:	c8250513          	addi	a0,a0,-894 # 80008b20 <userret+0xa90>
    80003ea6:	ffffd097          	auipc	ra,0xffffd
    80003eaa:	8b0080e7          	jalr	-1872(ra) # 80000756 <panic>

0000000080003eae <iunlock>:
{
    80003eae:	1101                	addi	sp,sp,-32
    80003eb0:	ec06                	sd	ra,24(sp)
    80003eb2:	e822                	sd	s0,16(sp)
    80003eb4:	e426                	sd	s1,8(sp)
    80003eb6:	e04a                	sd	s2,0(sp)
    80003eb8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003eba:	c905                	beqz	a0,80003eea <iunlock+0x3c>
    80003ebc:	84aa                	mv	s1,a0
    80003ebe:	01050913          	addi	s2,a0,16
    80003ec2:	854a                	mv	a0,s2
    80003ec4:	00001097          	auipc	ra,0x1
    80003ec8:	d48080e7          	jalr	-696(ra) # 80004c0c <holdingsleep>
    80003ecc:	cd19                	beqz	a0,80003eea <iunlock+0x3c>
    80003ece:	449c                	lw	a5,8(s1)
    80003ed0:	00f05d63          	blez	a5,80003eea <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ed4:	854a                	mv	a0,s2
    80003ed6:	00001097          	auipc	ra,0x1
    80003eda:	cf2080e7          	jalr	-782(ra) # 80004bc8 <releasesleep>
}
    80003ede:	60e2                	ld	ra,24(sp)
    80003ee0:	6442                	ld	s0,16(sp)
    80003ee2:	64a2                	ld	s1,8(sp)
    80003ee4:	6902                	ld	s2,0(sp)
    80003ee6:	6105                	addi	sp,sp,32
    80003ee8:	8082                	ret
    panic("iunlock");
    80003eea:	00005517          	auipc	a0,0x5
    80003eee:	c4650513          	addi	a0,a0,-954 # 80008b30 <userret+0xaa0>
    80003ef2:	ffffd097          	auipc	ra,0xffffd
    80003ef6:	864080e7          	jalr	-1948(ra) # 80000756 <panic>

0000000080003efa <iput>:
{
    80003efa:	7139                	addi	sp,sp,-64
    80003efc:	fc06                	sd	ra,56(sp)
    80003efe:	f822                	sd	s0,48(sp)
    80003f00:	f426                	sd	s1,40(sp)
    80003f02:	f04a                	sd	s2,32(sp)
    80003f04:	ec4e                	sd	s3,24(sp)
    80003f06:	e852                	sd	s4,16(sp)
    80003f08:	e456                	sd	s5,8(sp)
    80003f0a:	0080                	addi	s0,sp,64
    80003f0c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003f0e:	00021517          	auipc	a0,0x21
    80003f12:	b9a50513          	addi	a0,a0,-1126 # 80024aa8 <icache>
    80003f16:	ffffd097          	auipc	ra,0xffffd
    80003f1a:	d72080e7          	jalr	-654(ra) # 80000c88 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f1e:	4498                	lw	a4,8(s1)
    80003f20:	4785                	li	a5,1
    80003f22:	02f70663          	beq	a4,a5,80003f4e <iput+0x54>
  ip->ref--;
    80003f26:	449c                	lw	a5,8(s1)
    80003f28:	37fd                	addiw	a5,a5,-1
    80003f2a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003f2c:	00021517          	auipc	a0,0x21
    80003f30:	b7c50513          	addi	a0,a0,-1156 # 80024aa8 <icache>
    80003f34:	ffffd097          	auipc	ra,0xffffd
    80003f38:	fa0080e7          	jalr	-96(ra) # 80000ed4 <release>
}
    80003f3c:	70e2                	ld	ra,56(sp)
    80003f3e:	7442                	ld	s0,48(sp)
    80003f40:	74a2                	ld	s1,40(sp)
    80003f42:	7902                	ld	s2,32(sp)
    80003f44:	69e2                	ld	s3,24(sp)
    80003f46:	6a42                	ld	s4,16(sp)
    80003f48:	6aa2                	ld	s5,8(sp)
    80003f4a:	6121                	addi	sp,sp,64
    80003f4c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f4e:	4cbc                	lw	a5,88(s1)
    80003f50:	dbf9                	beqz	a5,80003f26 <iput+0x2c>
    80003f52:	06249783          	lh	a5,98(s1)
    80003f56:	fbe1                	bnez	a5,80003f26 <iput+0x2c>
    acquiresleep(&ip->lock);
    80003f58:	01048a13          	addi	s4,s1,16
    80003f5c:	8552                	mv	a0,s4
    80003f5e:	00001097          	auipc	ra,0x1
    80003f62:	c14080e7          	jalr	-1004(ra) # 80004b72 <acquiresleep>
    release(&icache.lock);
    80003f66:	00021517          	auipc	a0,0x21
    80003f6a:	b4250513          	addi	a0,a0,-1214 # 80024aa8 <icache>
    80003f6e:	ffffd097          	auipc	ra,0xffffd
    80003f72:	f66080e7          	jalr	-154(ra) # 80000ed4 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003f76:	06848913          	addi	s2,s1,104
    80003f7a:	09848993          	addi	s3,s1,152
    80003f7e:	a819                	j	80003f94 <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003f80:	4088                	lw	a0,0(s1)
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	8ae080e7          	jalr	-1874(ra) # 80003830 <bfree>
      ip->addrs[i] = 0;
    80003f8a:	00092023          	sw	zero,0(s2)
  for(i = 0; i < NDIRECT; i++){
    80003f8e:	0911                	addi	s2,s2,4
    80003f90:	01390663          	beq	s2,s3,80003f9c <iput+0xa2>
    if(ip->addrs[i]){
    80003f94:	00092583          	lw	a1,0(s2)
    80003f98:	d9fd                	beqz	a1,80003f8e <iput+0x94>
    80003f9a:	b7dd                	j	80003f80 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f9c:	0984a583          	lw	a1,152(s1)
    80003fa0:	ed9d                	bnez	a1,80003fde <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003fa2:	0604a223          	sw	zero,100(s1)
  iupdate(ip);
    80003fa6:	8526                	mv	a0,s1
    80003fa8:	00000097          	auipc	ra,0x0
    80003fac:	d7a080e7          	jalr	-646(ra) # 80003d22 <iupdate>
    ip->type = 0;
    80003fb0:	04049e23          	sh	zero,92(s1)
    iupdate(ip);
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	00000097          	auipc	ra,0x0
    80003fba:	d6c080e7          	jalr	-660(ra) # 80003d22 <iupdate>
    ip->valid = 0;
    80003fbe:	0404ac23          	sw	zero,88(s1)
    releasesleep(&ip->lock);
    80003fc2:	8552                	mv	a0,s4
    80003fc4:	00001097          	auipc	ra,0x1
    80003fc8:	c04080e7          	jalr	-1020(ra) # 80004bc8 <releasesleep>
    acquire(&icache.lock);
    80003fcc:	00021517          	auipc	a0,0x21
    80003fd0:	adc50513          	addi	a0,a0,-1316 # 80024aa8 <icache>
    80003fd4:	ffffd097          	auipc	ra,0xffffd
    80003fd8:	cb4080e7          	jalr	-844(ra) # 80000c88 <acquire>
    80003fdc:	b7a9                	j	80003f26 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003fde:	4088                	lw	a0,0(s1)
    80003fe0:	fffff097          	auipc	ra,0xfffff
    80003fe4:	606080e7          	jalr	1542(ra) # 800035e6 <bread>
    80003fe8:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003fea:	07050913          	addi	s2,a0,112
    80003fee:	47050993          	addi	s3,a0,1136
    80003ff2:	a809                	j	80004004 <iput+0x10a>
        bfree(ip->dev, a[j]);
    80003ff4:	4088                	lw	a0,0(s1)
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	83a080e7          	jalr	-1990(ra) # 80003830 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003ffe:	0911                	addi	s2,s2,4
    80004000:	01390663          	beq	s2,s3,8000400c <iput+0x112>
      if(a[j])
    80004004:	00092583          	lw	a1,0(s2)
    80004008:	d9fd                	beqz	a1,80003ffe <iput+0x104>
    8000400a:	b7ed                	j	80003ff4 <iput+0xfa>
    brelse(bp);
    8000400c:	8556                	mv	a0,s5
    8000400e:	fffff097          	auipc	ra,0xfffff
    80004012:	70c080e7          	jalr	1804(ra) # 8000371a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004016:	0984a583          	lw	a1,152(s1)
    8000401a:	4088                	lw	a0,0(s1)
    8000401c:	00000097          	auipc	ra,0x0
    80004020:	814080e7          	jalr	-2028(ra) # 80003830 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004024:	0804ac23          	sw	zero,152(s1)
    80004028:	bfad                	j	80003fa2 <iput+0xa8>

000000008000402a <iunlockput>:
{
    8000402a:	1101                	addi	sp,sp,-32
    8000402c:	ec06                	sd	ra,24(sp)
    8000402e:	e822                	sd	s0,16(sp)
    80004030:	e426                	sd	s1,8(sp)
    80004032:	1000                	addi	s0,sp,32
    80004034:	84aa                	mv	s1,a0
  iunlock(ip);
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	e78080e7          	jalr	-392(ra) # 80003eae <iunlock>
  iput(ip);
    8000403e:	8526                	mv	a0,s1
    80004040:	00000097          	auipc	ra,0x0
    80004044:	eba080e7          	jalr	-326(ra) # 80003efa <iput>
}
    80004048:	60e2                	ld	ra,24(sp)
    8000404a:	6442                	ld	s0,16(sp)
    8000404c:	64a2                	ld	s1,8(sp)
    8000404e:	6105                	addi	sp,sp,32
    80004050:	8082                	ret

0000000080004052 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004052:	1141                	addi	sp,sp,-16
    80004054:	e422                	sd	s0,8(sp)
    80004056:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004058:	411c                	lw	a5,0(a0)
    8000405a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000405c:	415c                	lw	a5,4(a0)
    8000405e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004060:	05c51783          	lh	a5,92(a0)
    80004064:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004068:	06251783          	lh	a5,98(a0)
    8000406c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004070:	06456783          	lwu	a5,100(a0)
    80004074:	e99c                	sd	a5,16(a1)
}
    80004076:	6422                	ld	s0,8(sp)
    80004078:	0141                	addi	sp,sp,16
    8000407a:	8082                	ret

000000008000407c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000407c:	517c                	lw	a5,100(a0)
    8000407e:	0ed7e563          	bltu	a5,a3,80004168 <readi+0xec>
{
    80004082:	7159                	addi	sp,sp,-112
    80004084:	f486                	sd	ra,104(sp)
    80004086:	f0a2                	sd	s0,96(sp)
    80004088:	eca6                	sd	s1,88(sp)
    8000408a:	e8ca                	sd	s2,80(sp)
    8000408c:	e4ce                	sd	s3,72(sp)
    8000408e:	e0d2                	sd	s4,64(sp)
    80004090:	fc56                	sd	s5,56(sp)
    80004092:	f85a                	sd	s6,48(sp)
    80004094:	f45e                	sd	s7,40(sp)
    80004096:	f062                	sd	s8,32(sp)
    80004098:	ec66                	sd	s9,24(sp)
    8000409a:	e86a                	sd	s10,16(sp)
    8000409c:	e46e                	sd	s11,8(sp)
    8000409e:	1880                	addi	s0,sp,112
    800040a0:	8baa                	mv	s7,a0
    800040a2:	8c2e                	mv	s8,a1
    800040a4:	8ab2                	mv	s5,a2
    800040a6:	8936                	mv	s2,a3
    800040a8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800040aa:	9f35                	addw	a4,a4,a3
    800040ac:	0cd76063          	bltu	a4,a3,8000416c <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    800040b0:	00e7f463          	bgeu	a5,a4,800040b8 <readi+0x3c>
    n = ip->size - off;
    800040b4:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040b8:	080b0763          	beqz	s6,80004146 <readi+0xca>
    800040bc:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800040be:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800040c2:	5cfd                	li	s9,-1
    800040c4:	a82d                	j	800040fe <readi+0x82>
    800040c6:	02099d93          	slli	s11,s3,0x20
    800040ca:	020ddd93          	srli	s11,s11,0x20
    800040ce:	07048613          	addi	a2,s1,112
    800040d2:	86ee                	mv	a3,s11
    800040d4:	963a                	add	a2,a2,a4
    800040d6:	85d6                	mv	a1,s5
    800040d8:	8562                	mv	a0,s8
    800040da:	fffff097          	auipc	ra,0xfffff
    800040de:	9aa080e7          	jalr	-1622(ra) # 80002a84 <either_copyout>
    800040e2:	05950d63          	beq	a0,s9,8000413c <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    800040e6:	8526                	mv	a0,s1
    800040e8:	fffff097          	auipc	ra,0xfffff
    800040ec:	632080e7          	jalr	1586(ra) # 8000371a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040f0:	01498a3b          	addw	s4,s3,s4
    800040f4:	0129893b          	addw	s2,s3,s2
    800040f8:	9aee                	add	s5,s5,s11
    800040fa:	056a7663          	bgeu	s4,s6,80004146 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040fe:	000ba483          	lw	s1,0(s7)
    80004102:	00a9559b          	srliw	a1,s2,0xa
    80004106:	855e                	mv	a0,s7
    80004108:	00000097          	auipc	ra,0x0
    8000410c:	8d6080e7          	jalr	-1834(ra) # 800039de <bmap>
    80004110:	0005059b          	sext.w	a1,a0
    80004114:	8526                	mv	a0,s1
    80004116:	fffff097          	auipc	ra,0xfffff
    8000411a:	4d0080e7          	jalr	1232(ra) # 800035e6 <bread>
    8000411e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004120:	3ff97713          	andi	a4,s2,1023
    80004124:	40ed07bb          	subw	a5,s10,a4
    80004128:	414b06bb          	subw	a3,s6,s4
    8000412c:	89be                	mv	s3,a5
    8000412e:	2781                	sext.w	a5,a5
    80004130:	0006861b          	sext.w	a2,a3
    80004134:	f8f679e3          	bgeu	a2,a5,800040c6 <readi+0x4a>
    80004138:	89b6                	mv	s3,a3
    8000413a:	b771                	j	800040c6 <readi+0x4a>
      brelse(bp);
    8000413c:	8526                	mv	a0,s1
    8000413e:	fffff097          	auipc	ra,0xfffff
    80004142:	5dc080e7          	jalr	1500(ra) # 8000371a <brelse>
  }
  return n;
    80004146:	000b051b          	sext.w	a0,s6
}
    8000414a:	70a6                	ld	ra,104(sp)
    8000414c:	7406                	ld	s0,96(sp)
    8000414e:	64e6                	ld	s1,88(sp)
    80004150:	6946                	ld	s2,80(sp)
    80004152:	69a6                	ld	s3,72(sp)
    80004154:	6a06                	ld	s4,64(sp)
    80004156:	7ae2                	ld	s5,56(sp)
    80004158:	7b42                	ld	s6,48(sp)
    8000415a:	7ba2                	ld	s7,40(sp)
    8000415c:	7c02                	ld	s8,32(sp)
    8000415e:	6ce2                	ld	s9,24(sp)
    80004160:	6d42                	ld	s10,16(sp)
    80004162:	6da2                	ld	s11,8(sp)
    80004164:	6165                	addi	sp,sp,112
    80004166:	8082                	ret
    return -1;
    80004168:	557d                	li	a0,-1
}
    8000416a:	8082                	ret
    return -1;
    8000416c:	557d                	li	a0,-1
    8000416e:	bff1                	j	8000414a <readi+0xce>

0000000080004170 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004170:	517c                	lw	a5,100(a0)
    80004172:	10d7e663          	bltu	a5,a3,8000427e <writei+0x10e>
{
    80004176:	7159                	addi	sp,sp,-112
    80004178:	f486                	sd	ra,104(sp)
    8000417a:	f0a2                	sd	s0,96(sp)
    8000417c:	eca6                	sd	s1,88(sp)
    8000417e:	e8ca                	sd	s2,80(sp)
    80004180:	e4ce                	sd	s3,72(sp)
    80004182:	e0d2                	sd	s4,64(sp)
    80004184:	fc56                	sd	s5,56(sp)
    80004186:	f85a                	sd	s6,48(sp)
    80004188:	f45e                	sd	s7,40(sp)
    8000418a:	f062                	sd	s8,32(sp)
    8000418c:	ec66                	sd	s9,24(sp)
    8000418e:	e86a                	sd	s10,16(sp)
    80004190:	e46e                	sd	s11,8(sp)
    80004192:	1880                	addi	s0,sp,112
    80004194:	8baa                	mv	s7,a0
    80004196:	8c2e                	mv	s8,a1
    80004198:	8ab2                	mv	s5,a2
    8000419a:	8936                	mv	s2,a3
    8000419c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000419e:	00e687bb          	addw	a5,a3,a4
    800041a2:	0ed7e063          	bltu	a5,a3,80004282 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800041a6:	00043737          	lui	a4,0x43
    800041aa:	0cf76e63          	bltu	a4,a5,80004286 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041ae:	0a0b0763          	beqz	s6,8000425c <writei+0xec>
    800041b2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800041b4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800041b8:	5cfd                	li	s9,-1
    800041ba:	a091                	j	800041fe <writei+0x8e>
    800041bc:	02099d93          	slli	s11,s3,0x20
    800041c0:	020ddd93          	srli	s11,s11,0x20
    800041c4:	07048513          	addi	a0,s1,112
    800041c8:	86ee                	mv	a3,s11
    800041ca:	8656                	mv	a2,s5
    800041cc:	85e2                	mv	a1,s8
    800041ce:	953a                	add	a0,a0,a4
    800041d0:	fffff097          	auipc	ra,0xfffff
    800041d4:	90a080e7          	jalr	-1782(ra) # 80002ada <either_copyin>
    800041d8:	07950263          	beq	a0,s9,8000423c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800041dc:	8526                	mv	a0,s1
    800041de:	00001097          	auipc	ra,0x1
    800041e2:	828080e7          	jalr	-2008(ra) # 80004a06 <log_write>
    brelse(bp);
    800041e6:	8526                	mv	a0,s1
    800041e8:	fffff097          	auipc	ra,0xfffff
    800041ec:	532080e7          	jalr	1330(ra) # 8000371a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041f0:	01498a3b          	addw	s4,s3,s4
    800041f4:	0129893b          	addw	s2,s3,s2
    800041f8:	9aee                	add	s5,s5,s11
    800041fa:	056a7663          	bgeu	s4,s6,80004246 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800041fe:	000ba483          	lw	s1,0(s7)
    80004202:	00a9559b          	srliw	a1,s2,0xa
    80004206:	855e                	mv	a0,s7
    80004208:	fffff097          	auipc	ra,0xfffff
    8000420c:	7d6080e7          	jalr	2006(ra) # 800039de <bmap>
    80004210:	0005059b          	sext.w	a1,a0
    80004214:	8526                	mv	a0,s1
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	3d0080e7          	jalr	976(ra) # 800035e6 <bread>
    8000421e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004220:	3ff97713          	andi	a4,s2,1023
    80004224:	40ed07bb          	subw	a5,s10,a4
    80004228:	414b06bb          	subw	a3,s6,s4
    8000422c:	89be                	mv	s3,a5
    8000422e:	2781                	sext.w	a5,a5
    80004230:	0006861b          	sext.w	a2,a3
    80004234:	f8f674e3          	bgeu	a2,a5,800041bc <writei+0x4c>
    80004238:	89b6                	mv	s3,a3
    8000423a:	b749                	j	800041bc <writei+0x4c>
      brelse(bp);
    8000423c:	8526                	mv	a0,s1
    8000423e:	fffff097          	auipc	ra,0xfffff
    80004242:	4dc080e7          	jalr	1244(ra) # 8000371a <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80004246:	064ba783          	lw	a5,100(s7)
    8000424a:	0127f463          	bgeu	a5,s2,80004252 <writei+0xe2>
      ip->size = off;
    8000424e:	072ba223          	sw	s2,100(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80004252:	855e                	mv	a0,s7
    80004254:	00000097          	auipc	ra,0x0
    80004258:	ace080e7          	jalr	-1330(ra) # 80003d22 <iupdate>
  }

  return n;
    8000425c:	000b051b          	sext.w	a0,s6
}
    80004260:	70a6                	ld	ra,104(sp)
    80004262:	7406                	ld	s0,96(sp)
    80004264:	64e6                	ld	s1,88(sp)
    80004266:	6946                	ld	s2,80(sp)
    80004268:	69a6                	ld	s3,72(sp)
    8000426a:	6a06                	ld	s4,64(sp)
    8000426c:	7ae2                	ld	s5,56(sp)
    8000426e:	7b42                	ld	s6,48(sp)
    80004270:	7ba2                	ld	s7,40(sp)
    80004272:	7c02                	ld	s8,32(sp)
    80004274:	6ce2                	ld	s9,24(sp)
    80004276:	6d42                	ld	s10,16(sp)
    80004278:	6da2                	ld	s11,8(sp)
    8000427a:	6165                	addi	sp,sp,112
    8000427c:	8082                	ret
    return -1;
    8000427e:	557d                	li	a0,-1
}
    80004280:	8082                	ret
    return -1;
    80004282:	557d                	li	a0,-1
    80004284:	bff1                	j	80004260 <writei+0xf0>
    return -1;
    80004286:	557d                	li	a0,-1
    80004288:	bfe1                	j	80004260 <writei+0xf0>

000000008000428a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000428a:	1141                	addi	sp,sp,-16
    8000428c:	e406                	sd	ra,8(sp)
    8000428e:	e022                	sd	s0,0(sp)
    80004290:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004292:	4639                	li	a2,14
    80004294:	ffffd097          	auipc	ra,0xffffd
    80004298:	f1c080e7          	jalr	-228(ra) # 800011b0 <strncmp>
}
    8000429c:	60a2                	ld	ra,8(sp)
    8000429e:	6402                	ld	s0,0(sp)
    800042a0:	0141                	addi	sp,sp,16
    800042a2:	8082                	ret

00000000800042a4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800042a4:	7139                	addi	sp,sp,-64
    800042a6:	fc06                	sd	ra,56(sp)
    800042a8:	f822                	sd	s0,48(sp)
    800042aa:	f426                	sd	s1,40(sp)
    800042ac:	f04a                	sd	s2,32(sp)
    800042ae:	ec4e                	sd	s3,24(sp)
    800042b0:	e852                	sd	s4,16(sp)
    800042b2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800042b4:	05c51703          	lh	a4,92(a0)
    800042b8:	4785                	li	a5,1
    800042ba:	00f71a63          	bne	a4,a5,800042ce <dirlookup+0x2a>
    800042be:	892a                	mv	s2,a0
    800042c0:	89ae                	mv	s3,a1
    800042c2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800042c4:	517c                	lw	a5,100(a0)
    800042c6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800042c8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042ca:	e79d                	bnez	a5,800042f8 <dirlookup+0x54>
    800042cc:	a8a5                	j	80004344 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800042ce:	00005517          	auipc	a0,0x5
    800042d2:	86a50513          	addi	a0,a0,-1942 # 80008b38 <userret+0xaa8>
    800042d6:	ffffc097          	auipc	ra,0xffffc
    800042da:	480080e7          	jalr	1152(ra) # 80000756 <panic>
      panic("dirlookup read");
    800042de:	00005517          	auipc	a0,0x5
    800042e2:	87250513          	addi	a0,a0,-1934 # 80008b50 <userret+0xac0>
    800042e6:	ffffc097          	auipc	ra,0xffffc
    800042ea:	470080e7          	jalr	1136(ra) # 80000756 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042ee:	24c1                	addiw	s1,s1,16
    800042f0:	06492783          	lw	a5,100(s2)
    800042f4:	04f4f763          	bgeu	s1,a5,80004342 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042f8:	4741                	li	a4,16
    800042fa:	86a6                	mv	a3,s1
    800042fc:	fc040613          	addi	a2,s0,-64
    80004300:	4581                	li	a1,0
    80004302:	854a                	mv	a0,s2
    80004304:	00000097          	auipc	ra,0x0
    80004308:	d78080e7          	jalr	-648(ra) # 8000407c <readi>
    8000430c:	47c1                	li	a5,16
    8000430e:	fcf518e3          	bne	a0,a5,800042de <dirlookup+0x3a>
    if(de.inum == 0)
    80004312:	fc045783          	lhu	a5,-64(s0)
    80004316:	dfe1                	beqz	a5,800042ee <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004318:	fc240593          	addi	a1,s0,-62
    8000431c:	854e                	mv	a0,s3
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	f6c080e7          	jalr	-148(ra) # 8000428a <namecmp>
    80004326:	f561                	bnez	a0,800042ee <dirlookup+0x4a>
      if(poff)
    80004328:	000a0463          	beqz	s4,80004330 <dirlookup+0x8c>
        *poff = off;
    8000432c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004330:	fc045583          	lhu	a1,-64(s0)
    80004334:	00092503          	lw	a0,0(s2)
    80004338:	fffff097          	auipc	ra,0xfffff
    8000433c:	780080e7          	jalr	1920(ra) # 80003ab8 <iget>
    80004340:	a011                	j	80004344 <dirlookup+0xa0>
  return 0;
    80004342:	4501                	li	a0,0
}
    80004344:	70e2                	ld	ra,56(sp)
    80004346:	7442                	ld	s0,48(sp)
    80004348:	74a2                	ld	s1,40(sp)
    8000434a:	7902                	ld	s2,32(sp)
    8000434c:	69e2                	ld	s3,24(sp)
    8000434e:	6a42                	ld	s4,16(sp)
    80004350:	6121                	addi	sp,sp,64
    80004352:	8082                	ret

0000000080004354 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004354:	711d                	addi	sp,sp,-96
    80004356:	ec86                	sd	ra,88(sp)
    80004358:	e8a2                	sd	s0,80(sp)
    8000435a:	e4a6                	sd	s1,72(sp)
    8000435c:	e0ca                	sd	s2,64(sp)
    8000435e:	fc4e                	sd	s3,56(sp)
    80004360:	f852                	sd	s4,48(sp)
    80004362:	f456                	sd	s5,40(sp)
    80004364:	f05a                	sd	s6,32(sp)
    80004366:	ec5e                	sd	s7,24(sp)
    80004368:	e862                	sd	s8,16(sp)
    8000436a:	e466                	sd	s9,8(sp)
    8000436c:	1080                	addi	s0,sp,96
    8000436e:	84aa                	mv	s1,a0
    80004370:	8b2e                	mv	s6,a1
    80004372:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004374:	00054703          	lbu	a4,0(a0)
    80004378:	02f00793          	li	a5,47
    8000437c:	02f70363          	beq	a4,a5,800043a2 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004380:	ffffe097          	auipc	ra,0xffffe
    80004384:	c1c080e7          	jalr	-996(ra) # 80001f9c <myproc>
    80004388:	16853503          	ld	a0,360(a0)
    8000438c:	00000097          	auipc	ra,0x0
    80004390:	a22080e7          	jalr	-1502(ra) # 80003dae <idup>
    80004394:	89aa                	mv	s3,a0
  while(*path == '/')
    80004396:	02f00913          	li	s2,47
  len = path - s;
    8000439a:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000439c:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000439e:	4c05                	li	s8,1
    800043a0:	a865                	j	80004458 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800043a2:	4585                	li	a1,1
    800043a4:	4501                	li	a0,0
    800043a6:	fffff097          	auipc	ra,0xfffff
    800043aa:	712080e7          	jalr	1810(ra) # 80003ab8 <iget>
    800043ae:	89aa                	mv	s3,a0
    800043b0:	b7dd                	j	80004396 <namex+0x42>
      iunlockput(ip);
    800043b2:	854e                	mv	a0,s3
    800043b4:	00000097          	auipc	ra,0x0
    800043b8:	c76080e7          	jalr	-906(ra) # 8000402a <iunlockput>
      return 0;
    800043bc:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800043be:	854e                	mv	a0,s3
    800043c0:	60e6                	ld	ra,88(sp)
    800043c2:	6446                	ld	s0,80(sp)
    800043c4:	64a6                	ld	s1,72(sp)
    800043c6:	6906                	ld	s2,64(sp)
    800043c8:	79e2                	ld	s3,56(sp)
    800043ca:	7a42                	ld	s4,48(sp)
    800043cc:	7aa2                	ld	s5,40(sp)
    800043ce:	7b02                	ld	s6,32(sp)
    800043d0:	6be2                	ld	s7,24(sp)
    800043d2:	6c42                	ld	s8,16(sp)
    800043d4:	6ca2                	ld	s9,8(sp)
    800043d6:	6125                	addi	sp,sp,96
    800043d8:	8082                	ret
      iunlock(ip);
    800043da:	854e                	mv	a0,s3
    800043dc:	00000097          	auipc	ra,0x0
    800043e0:	ad2080e7          	jalr	-1326(ra) # 80003eae <iunlock>
      return ip;
    800043e4:	bfe9                	j	800043be <namex+0x6a>
      iunlockput(ip);
    800043e6:	854e                	mv	a0,s3
    800043e8:	00000097          	auipc	ra,0x0
    800043ec:	c42080e7          	jalr	-958(ra) # 8000402a <iunlockput>
      return 0;
    800043f0:	89d2                	mv	s3,s4
    800043f2:	b7f1                	j	800043be <namex+0x6a>
  len = path - s;
    800043f4:	40b48633          	sub	a2,s1,a1
    800043f8:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800043fc:	094cd463          	bge	s9,s4,80004484 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004400:	4639                	li	a2,14
    80004402:	8556                	mv	a0,s5
    80004404:	ffffd097          	auipc	ra,0xffffd
    80004408:	d30080e7          	jalr	-720(ra) # 80001134 <memmove>
  while(*path == '/')
    8000440c:	0004c783          	lbu	a5,0(s1)
    80004410:	01279763          	bne	a5,s2,8000441e <namex+0xca>
    path++;
    80004414:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004416:	0004c783          	lbu	a5,0(s1)
    8000441a:	ff278de3          	beq	a5,s2,80004414 <namex+0xc0>
    ilock(ip);
    8000441e:	854e                	mv	a0,s3
    80004420:	00000097          	auipc	ra,0x0
    80004424:	9cc080e7          	jalr	-1588(ra) # 80003dec <ilock>
    if(ip->type != T_DIR){
    80004428:	05c99783          	lh	a5,92(s3)
    8000442c:	f98793e3          	bne	a5,s8,800043b2 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004430:	000b0563          	beqz	s6,8000443a <namex+0xe6>
    80004434:	0004c783          	lbu	a5,0(s1)
    80004438:	d3cd                	beqz	a5,800043da <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000443a:	865e                	mv	a2,s7
    8000443c:	85d6                	mv	a1,s5
    8000443e:	854e                	mv	a0,s3
    80004440:	00000097          	auipc	ra,0x0
    80004444:	e64080e7          	jalr	-412(ra) # 800042a4 <dirlookup>
    80004448:	8a2a                	mv	s4,a0
    8000444a:	dd51                	beqz	a0,800043e6 <namex+0x92>
    iunlockput(ip);
    8000444c:	854e                	mv	a0,s3
    8000444e:	00000097          	auipc	ra,0x0
    80004452:	bdc080e7          	jalr	-1060(ra) # 8000402a <iunlockput>
    ip = next;
    80004456:	89d2                	mv	s3,s4
  while(*path == '/')
    80004458:	0004c783          	lbu	a5,0(s1)
    8000445c:	05279763          	bne	a5,s2,800044aa <namex+0x156>
    path++;
    80004460:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004462:	0004c783          	lbu	a5,0(s1)
    80004466:	ff278de3          	beq	a5,s2,80004460 <namex+0x10c>
  if(*path == 0)
    8000446a:	c79d                	beqz	a5,80004498 <namex+0x144>
    path++;
    8000446c:	85a6                	mv	a1,s1
  len = path - s;
    8000446e:	8a5e                	mv	s4,s7
    80004470:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004472:	01278963          	beq	a5,s2,80004484 <namex+0x130>
    80004476:	dfbd                	beqz	a5,800043f4 <namex+0xa0>
    path++;
    80004478:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000447a:	0004c783          	lbu	a5,0(s1)
    8000447e:	ff279ce3          	bne	a5,s2,80004476 <namex+0x122>
    80004482:	bf8d                	j	800043f4 <namex+0xa0>
    memmove(name, s, len);
    80004484:	2601                	sext.w	a2,a2
    80004486:	8556                	mv	a0,s5
    80004488:	ffffd097          	auipc	ra,0xffffd
    8000448c:	cac080e7          	jalr	-852(ra) # 80001134 <memmove>
    name[len] = 0;
    80004490:	9a56                	add	s4,s4,s5
    80004492:	000a0023          	sb	zero,0(s4)
    80004496:	bf9d                	j	8000440c <namex+0xb8>
  if(nameiparent){
    80004498:	f20b03e3          	beqz	s6,800043be <namex+0x6a>
    iput(ip);
    8000449c:	854e                	mv	a0,s3
    8000449e:	00000097          	auipc	ra,0x0
    800044a2:	a5c080e7          	jalr	-1444(ra) # 80003efa <iput>
    return 0;
    800044a6:	4981                	li	s3,0
    800044a8:	bf19                	j	800043be <namex+0x6a>
  if(*path == 0)
    800044aa:	d7fd                	beqz	a5,80004498 <namex+0x144>
  while(*path != '/' && *path != 0)
    800044ac:	0004c783          	lbu	a5,0(s1)
    800044b0:	85a6                	mv	a1,s1
    800044b2:	b7d1                	j	80004476 <namex+0x122>

00000000800044b4 <dirlink>:
{
    800044b4:	7139                	addi	sp,sp,-64
    800044b6:	fc06                	sd	ra,56(sp)
    800044b8:	f822                	sd	s0,48(sp)
    800044ba:	f426                	sd	s1,40(sp)
    800044bc:	f04a                	sd	s2,32(sp)
    800044be:	ec4e                	sd	s3,24(sp)
    800044c0:	e852                	sd	s4,16(sp)
    800044c2:	0080                	addi	s0,sp,64
    800044c4:	892a                	mv	s2,a0
    800044c6:	8a2e                	mv	s4,a1
    800044c8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800044ca:	4601                	li	a2,0
    800044cc:	00000097          	auipc	ra,0x0
    800044d0:	dd8080e7          	jalr	-552(ra) # 800042a4 <dirlookup>
    800044d4:	e93d                	bnez	a0,8000454a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044d6:	06492483          	lw	s1,100(s2)
    800044da:	c49d                	beqz	s1,80004508 <dirlink+0x54>
    800044dc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044de:	4741                	li	a4,16
    800044e0:	86a6                	mv	a3,s1
    800044e2:	fc040613          	addi	a2,s0,-64
    800044e6:	4581                	li	a1,0
    800044e8:	854a                	mv	a0,s2
    800044ea:	00000097          	auipc	ra,0x0
    800044ee:	b92080e7          	jalr	-1134(ra) # 8000407c <readi>
    800044f2:	47c1                	li	a5,16
    800044f4:	06f51163          	bne	a0,a5,80004556 <dirlink+0xa2>
    if(de.inum == 0)
    800044f8:	fc045783          	lhu	a5,-64(s0)
    800044fc:	c791                	beqz	a5,80004508 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044fe:	24c1                	addiw	s1,s1,16
    80004500:	06492783          	lw	a5,100(s2)
    80004504:	fcf4ede3          	bltu	s1,a5,800044de <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004508:	4639                	li	a2,14
    8000450a:	85d2                	mv	a1,s4
    8000450c:	fc240513          	addi	a0,s0,-62
    80004510:	ffffd097          	auipc	ra,0xffffd
    80004514:	cdc080e7          	jalr	-804(ra) # 800011ec <strncpy>
  de.inum = inum;
    80004518:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000451c:	4741                	li	a4,16
    8000451e:	86a6                	mv	a3,s1
    80004520:	fc040613          	addi	a2,s0,-64
    80004524:	4581                	li	a1,0
    80004526:	854a                	mv	a0,s2
    80004528:	00000097          	auipc	ra,0x0
    8000452c:	c48080e7          	jalr	-952(ra) # 80004170 <writei>
    80004530:	872a                	mv	a4,a0
    80004532:	47c1                	li	a5,16
  return 0;
    80004534:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004536:	02f71863          	bne	a4,a5,80004566 <dirlink+0xb2>
}
    8000453a:	70e2                	ld	ra,56(sp)
    8000453c:	7442                	ld	s0,48(sp)
    8000453e:	74a2                	ld	s1,40(sp)
    80004540:	7902                	ld	s2,32(sp)
    80004542:	69e2                	ld	s3,24(sp)
    80004544:	6a42                	ld	s4,16(sp)
    80004546:	6121                	addi	sp,sp,64
    80004548:	8082                	ret
    iput(ip);
    8000454a:	00000097          	auipc	ra,0x0
    8000454e:	9b0080e7          	jalr	-1616(ra) # 80003efa <iput>
    return -1;
    80004552:	557d                	li	a0,-1
    80004554:	b7dd                	j	8000453a <dirlink+0x86>
      panic("dirlink read");
    80004556:	00004517          	auipc	a0,0x4
    8000455a:	60a50513          	addi	a0,a0,1546 # 80008b60 <userret+0xad0>
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	1f8080e7          	jalr	504(ra) # 80000756 <panic>
    panic("dirlink");
    80004566:	00004517          	auipc	a0,0x4
    8000456a:	71a50513          	addi	a0,a0,1818 # 80008c80 <userret+0xbf0>
    8000456e:	ffffc097          	auipc	ra,0xffffc
    80004572:	1e8080e7          	jalr	488(ra) # 80000756 <panic>

0000000080004576 <namei>:

struct inode*
namei(char *path)
{
    80004576:	1101                	addi	sp,sp,-32
    80004578:	ec06                	sd	ra,24(sp)
    8000457a:	e822                	sd	s0,16(sp)
    8000457c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000457e:	fe040613          	addi	a2,s0,-32
    80004582:	4581                	li	a1,0
    80004584:	00000097          	auipc	ra,0x0
    80004588:	dd0080e7          	jalr	-560(ra) # 80004354 <namex>
}
    8000458c:	60e2                	ld	ra,24(sp)
    8000458e:	6442                	ld	s0,16(sp)
    80004590:	6105                	addi	sp,sp,32
    80004592:	8082                	ret

0000000080004594 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004594:	1141                	addi	sp,sp,-16
    80004596:	e406                	sd	ra,8(sp)
    80004598:	e022                	sd	s0,0(sp)
    8000459a:	0800                	addi	s0,sp,16
    8000459c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000459e:	4585                	li	a1,1
    800045a0:	00000097          	auipc	ra,0x0
    800045a4:	db4080e7          	jalr	-588(ra) # 80004354 <namex>
}
    800045a8:	60a2                	ld	ra,8(sp)
    800045aa:	6402                	ld	s0,0(sp)
    800045ac:	0141                	addi	sp,sp,16
    800045ae:	8082                	ret

00000000800045b0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    800045b0:	7179                	addi	sp,sp,-48
    800045b2:	f406                	sd	ra,40(sp)
    800045b4:	f022                	sd	s0,32(sp)
    800045b6:	ec26                	sd	s1,24(sp)
    800045b8:	e84a                	sd	s2,16(sp)
    800045ba:	e44e                	sd	s3,8(sp)
    800045bc:	1800                	addi	s0,sp,48
  struct buf *buf = bread(dev, log[dev].start);
    800045be:	00151993          	slli	s3,a0,0x1
    800045c2:	99aa                	add	s3,s3,a0
    800045c4:	00699793          	slli	a5,s3,0x6
    800045c8:	00022997          	auipc	s3,0x22
    800045cc:	45098993          	addi	s3,s3,1104 # 80026a18 <log>
    800045d0:	99be                	add	s3,s3,a5
    800045d2:	0309a583          	lw	a1,48(s3)
    800045d6:	fffff097          	auipc	ra,0xfffff
    800045da:	010080e7          	jalr	16(ra) # 800035e6 <bread>
    800045de:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    800045e0:	0449a783          	lw	a5,68(s3)
    800045e4:	d93c                	sw	a5,112(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    800045e6:	0449a783          	lw	a5,68(s3)
    800045ea:	00f05f63          	blez	a5,80004608 <write_head+0x58>
    800045ee:	87ce                	mv	a5,s3
    800045f0:	07450693          	addi	a3,a0,116
    800045f4:	4701                	li	a4,0
    800045f6:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    800045f8:	47b0                	lw	a2,72(a5)
    800045fa:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    800045fc:	2705                	addiw	a4,a4,1
    800045fe:	0791                	addi	a5,a5,4
    80004600:	0691                	addi	a3,a3,4
    80004602:	41f0                	lw	a2,68(a1)
    80004604:	fec74ae3          	blt	a4,a2,800045f8 <write_head+0x48>
  }
  bwrite(buf);
    80004608:	854a                	mv	a0,s2
    8000460a:	fffff097          	auipc	ra,0xfffff
    8000460e:	0d0080e7          	jalr	208(ra) # 800036da <bwrite>
  brelse(buf);
    80004612:	854a                	mv	a0,s2
    80004614:	fffff097          	auipc	ra,0xfffff
    80004618:	106080e7          	jalr	262(ra) # 8000371a <brelse>
}
    8000461c:	70a2                	ld	ra,40(sp)
    8000461e:	7402                	ld	s0,32(sp)
    80004620:	64e2                	ld	s1,24(sp)
    80004622:	6942                	ld	s2,16(sp)
    80004624:	69a2                	ld	s3,8(sp)
    80004626:	6145                	addi	sp,sp,48
    80004628:	8082                	ret

000000008000462a <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000462a:	00151793          	slli	a5,a0,0x1
    8000462e:	97aa                	add	a5,a5,a0
    80004630:	079a                	slli	a5,a5,0x6
    80004632:	00022717          	auipc	a4,0x22
    80004636:	3e670713          	addi	a4,a4,998 # 80026a18 <log>
    8000463a:	97ba                	add	a5,a5,a4
    8000463c:	43fc                	lw	a5,68(a5)
    8000463e:	0af05863          	blez	a5,800046ee <install_trans+0xc4>
{
    80004642:	7139                	addi	sp,sp,-64
    80004644:	fc06                	sd	ra,56(sp)
    80004646:	f822                	sd	s0,48(sp)
    80004648:	f426                	sd	s1,40(sp)
    8000464a:	f04a                	sd	s2,32(sp)
    8000464c:	ec4e                	sd	s3,24(sp)
    8000464e:	e852                	sd	s4,16(sp)
    80004650:	e456                	sd	s5,8(sp)
    80004652:	e05a                	sd	s6,0(sp)
    80004654:	0080                	addi	s0,sp,64
    80004656:	00151a13          	slli	s4,a0,0x1
    8000465a:	9a2a                	add	s4,s4,a0
    8000465c:	006a1793          	slli	a5,s4,0x6
    80004660:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004664:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80004666:	00050b1b          	sext.w	s6,a0
    8000466a:	8ad2                	mv	s5,s4
    8000466c:	030aa583          	lw	a1,48(s5)
    80004670:	013585bb          	addw	a1,a1,s3
    80004674:	2585                	addiw	a1,a1,1
    80004676:	855a                	mv	a0,s6
    80004678:	fffff097          	auipc	ra,0xfffff
    8000467c:	f6e080e7          	jalr	-146(ra) # 800035e6 <bread>
    80004680:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80004682:	048a2583          	lw	a1,72(s4)
    80004686:	855a                	mv	a0,s6
    80004688:	fffff097          	auipc	ra,0xfffff
    8000468c:	f5e080e7          	jalr	-162(ra) # 800035e6 <bread>
    80004690:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004692:	40000613          	li	a2,1024
    80004696:	07090593          	addi	a1,s2,112
    8000469a:	07050513          	addi	a0,a0,112
    8000469e:	ffffd097          	auipc	ra,0xffffd
    800046a2:	a96080e7          	jalr	-1386(ra) # 80001134 <memmove>
    bwrite(dbuf);  // write dst to disk
    800046a6:	8526                	mv	a0,s1
    800046a8:	fffff097          	auipc	ra,0xfffff
    800046ac:	032080e7          	jalr	50(ra) # 800036da <bwrite>
    bunpin(dbuf);
    800046b0:	8526                	mv	a0,s1
    800046b2:	fffff097          	auipc	ra,0xfffff
    800046b6:	142080e7          	jalr	322(ra) # 800037f4 <bunpin>
    brelse(lbuf);
    800046ba:	854a                	mv	a0,s2
    800046bc:	fffff097          	auipc	ra,0xfffff
    800046c0:	05e080e7          	jalr	94(ra) # 8000371a <brelse>
    brelse(dbuf);
    800046c4:	8526                	mv	a0,s1
    800046c6:	fffff097          	auipc	ra,0xfffff
    800046ca:	054080e7          	jalr	84(ra) # 8000371a <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800046ce:	2985                	addiw	s3,s3,1
    800046d0:	0a11                	addi	s4,s4,4
    800046d2:	044aa783          	lw	a5,68(s5)
    800046d6:	f8f9cbe3          	blt	s3,a5,8000466c <install_trans+0x42>
}
    800046da:	70e2                	ld	ra,56(sp)
    800046dc:	7442                	ld	s0,48(sp)
    800046de:	74a2                	ld	s1,40(sp)
    800046e0:	7902                	ld	s2,32(sp)
    800046e2:	69e2                	ld	s3,24(sp)
    800046e4:	6a42                	ld	s4,16(sp)
    800046e6:	6aa2                	ld	s5,8(sp)
    800046e8:	6b02                	ld	s6,0(sp)
    800046ea:	6121                	addi	sp,sp,64
    800046ec:	8082                	ret
    800046ee:	8082                	ret

00000000800046f0 <initlog>:
{
    800046f0:	7179                	addi	sp,sp,-48
    800046f2:	f406                	sd	ra,40(sp)
    800046f4:	f022                	sd	s0,32(sp)
    800046f6:	ec26                	sd	s1,24(sp)
    800046f8:	e84a                	sd	s2,16(sp)
    800046fa:	e44e                	sd	s3,8(sp)
    800046fc:	e052                	sd	s4,0(sp)
    800046fe:	1800                	addi	s0,sp,48
    80004700:	84aa                	mv	s1,a0
    80004702:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80004704:	00151713          	slli	a4,a0,0x1
    80004708:	972a                	add	a4,a4,a0
    8000470a:	00671993          	slli	s3,a4,0x6
    8000470e:	00022917          	auipc	s2,0x22
    80004712:	30a90913          	addi	s2,s2,778 # 80026a18 <log>
    80004716:	994e                	add	s2,s2,s3
    80004718:	00004597          	auipc	a1,0x4
    8000471c:	45858593          	addi	a1,a1,1112 # 80008b70 <userret+0xae0>
    80004720:	854a                	mv	a0,s2
    80004722:	ffffc097          	auipc	ra,0xffffc
    80004726:	3fc080e7          	jalr	1020(ra) # 80000b1e <initlock>
  log[dev].start = sb->logstart;
    8000472a:	014a2583          	lw	a1,20(s4)
    8000472e:	02b92823          	sw	a1,48(s2)
  log[dev].size = sb->nlog;
    80004732:	010a2783          	lw	a5,16(s4)
    80004736:	02f92a23          	sw	a5,52(s2)
  log[dev].dev = dev;
    8000473a:	04992023          	sw	s1,64(s2)
  struct buf *buf = bread(dev, log[dev].start);
    8000473e:	8526                	mv	a0,s1
    80004740:	fffff097          	auipc	ra,0xfffff
    80004744:	ea6080e7          	jalr	-346(ra) # 800035e6 <bread>
  log[dev].lh.n = lh->n;
    80004748:	593c                	lw	a5,112(a0)
    8000474a:	04f92223          	sw	a5,68(s2)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000474e:	02f05663          	blez	a5,8000477a <initlog+0x8a>
    80004752:	07450693          	addi	a3,a0,116
    80004756:	00022717          	auipc	a4,0x22
    8000475a:	30a70713          	addi	a4,a4,778 # 80026a60 <log+0x48>
    8000475e:	974e                	add	a4,a4,s3
    80004760:	37fd                	addiw	a5,a5,-1
    80004762:	1782                	slli	a5,a5,0x20
    80004764:	9381                	srli	a5,a5,0x20
    80004766:	078a                	slli	a5,a5,0x2
    80004768:	07850613          	addi	a2,a0,120
    8000476c:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    8000476e:	4290                	lw	a2,0(a3)
    80004770:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004772:	0691                	addi	a3,a3,4
    80004774:	0711                	addi	a4,a4,4
    80004776:	fef69ce3          	bne	a3,a5,8000476e <initlog+0x7e>
  brelse(buf);
    8000477a:	fffff097          	auipc	ra,0xfffff
    8000477e:	fa0080e7          	jalr	-96(ra) # 8000371a <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    80004782:	8526                	mv	a0,s1
    80004784:	00000097          	auipc	ra,0x0
    80004788:	ea6080e7          	jalr	-346(ra) # 8000462a <install_trans>
  log[dev].lh.n = 0;
    8000478c:	00149793          	slli	a5,s1,0x1
    80004790:	97a6                	add	a5,a5,s1
    80004792:	079a                	slli	a5,a5,0x6
    80004794:	00022717          	auipc	a4,0x22
    80004798:	28470713          	addi	a4,a4,644 # 80026a18 <log>
    8000479c:	97ba                	add	a5,a5,a4
    8000479e:	0407a223          	sw	zero,68(a5)
  write_head(dev); // clear the log
    800047a2:	8526                	mv	a0,s1
    800047a4:	00000097          	auipc	ra,0x0
    800047a8:	e0c080e7          	jalr	-500(ra) # 800045b0 <write_head>
}
    800047ac:	70a2                	ld	ra,40(sp)
    800047ae:	7402                	ld	s0,32(sp)
    800047b0:	64e2                	ld	s1,24(sp)
    800047b2:	6942                	ld	s2,16(sp)
    800047b4:	69a2                	ld	s3,8(sp)
    800047b6:	6a02                	ld	s4,0(sp)
    800047b8:	6145                	addi	sp,sp,48
    800047ba:	8082                	ret

00000000800047bc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    800047bc:	7139                	addi	sp,sp,-64
    800047be:	fc06                	sd	ra,56(sp)
    800047c0:	f822                	sd	s0,48(sp)
    800047c2:	f426                	sd	s1,40(sp)
    800047c4:	f04a                	sd	s2,32(sp)
    800047c6:	ec4e                	sd	s3,24(sp)
    800047c8:	e852                	sd	s4,16(sp)
    800047ca:	e456                	sd	s5,8(sp)
    800047cc:	0080                	addi	s0,sp,64
    800047ce:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    800047d0:	00151913          	slli	s2,a0,0x1
    800047d4:	992a                	add	s2,s2,a0
    800047d6:	00691793          	slli	a5,s2,0x6
    800047da:	00022917          	auipc	s2,0x22
    800047de:	23e90913          	addi	s2,s2,574 # 80026a18 <log>
    800047e2:	993e                	add	s2,s2,a5
    800047e4:	854a                	mv	a0,s2
    800047e6:	ffffc097          	auipc	ra,0xffffc
    800047ea:	4a2080e7          	jalr	1186(ra) # 80000c88 <acquire>
  while(1){
    if(log[dev].committing){
    800047ee:	00022997          	auipc	s3,0x22
    800047f2:	22a98993          	addi	s3,s3,554 # 80026a18 <log>
    800047f6:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047f8:	4a79                	li	s4,30
    800047fa:	a039                	j	80004808 <begin_op+0x4c>
      sleep(&log, &log[dev].lock);
    800047fc:	85ca                	mv	a1,s2
    800047fe:	854e                	mv	a0,s3
    80004800:	ffffe097          	auipc	ra,0xffffe
    80004804:	022080e7          	jalr	34(ra) # 80002822 <sleep>
    if(log[dev].committing){
    80004808:	5cdc                	lw	a5,60(s1)
    8000480a:	fbed                	bnez	a5,800047fc <begin_op+0x40>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000480c:	5c9c                	lw	a5,56(s1)
    8000480e:	0017871b          	addiw	a4,a5,1
    80004812:	0007069b          	sext.w	a3,a4
    80004816:	0027179b          	slliw	a5,a4,0x2
    8000481a:	9fb9                	addw	a5,a5,a4
    8000481c:	0017979b          	slliw	a5,a5,0x1
    80004820:	40f8                	lw	a4,68(s1)
    80004822:	9fb9                	addw	a5,a5,a4
    80004824:	00fa5963          	bge	s4,a5,80004836 <begin_op+0x7a>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    80004828:	85ca                	mv	a1,s2
    8000482a:	854e                	mv	a0,s3
    8000482c:	ffffe097          	auipc	ra,0xffffe
    80004830:	ff6080e7          	jalr	-10(ra) # 80002822 <sleep>
    80004834:	bfd1                	j	80004808 <begin_op+0x4c>
    } else {
      log[dev].outstanding += 1;
    80004836:	001a9513          	slli	a0,s5,0x1
    8000483a:	9aaa                	add	s5,s5,a0
    8000483c:	0a9a                	slli	s5,s5,0x6
    8000483e:	00022797          	auipc	a5,0x22
    80004842:	1da78793          	addi	a5,a5,474 # 80026a18 <log>
    80004846:	9abe                	add	s5,s5,a5
    80004848:	02daac23          	sw	a3,56(s5)
      release(&log[dev].lock);
    8000484c:	854a                	mv	a0,s2
    8000484e:	ffffc097          	auipc	ra,0xffffc
    80004852:	686080e7          	jalr	1670(ra) # 80000ed4 <release>
      break;
    }
  }
}
    80004856:	70e2                	ld	ra,56(sp)
    80004858:	7442                	ld	s0,48(sp)
    8000485a:	74a2                	ld	s1,40(sp)
    8000485c:	7902                	ld	s2,32(sp)
    8000485e:	69e2                	ld	s3,24(sp)
    80004860:	6a42                	ld	s4,16(sp)
    80004862:	6aa2                	ld	s5,8(sp)
    80004864:	6121                	addi	sp,sp,64
    80004866:	8082                	ret

0000000080004868 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    80004868:	715d                	addi	sp,sp,-80
    8000486a:	e486                	sd	ra,72(sp)
    8000486c:	e0a2                	sd	s0,64(sp)
    8000486e:	fc26                	sd	s1,56(sp)
    80004870:	f84a                	sd	s2,48(sp)
    80004872:	f44e                	sd	s3,40(sp)
    80004874:	f052                	sd	s4,32(sp)
    80004876:	ec56                	sd	s5,24(sp)
    80004878:	e85a                	sd	s6,16(sp)
    8000487a:	e45e                	sd	s7,8(sp)
    8000487c:	e062                	sd	s8,0(sp)
    8000487e:	0880                	addi	s0,sp,80
    80004880:	892a                	mv	s2,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    80004882:	00151493          	slli	s1,a0,0x1
    80004886:	94aa                	add	s1,s1,a0
    80004888:	00649793          	slli	a5,s1,0x6
    8000488c:	00022497          	auipc	s1,0x22
    80004890:	18c48493          	addi	s1,s1,396 # 80026a18 <log>
    80004894:	94be                	add	s1,s1,a5
    80004896:	8526                	mv	a0,s1
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	3f0080e7          	jalr	1008(ra) # 80000c88 <acquire>
  log[dev].outstanding -= 1;
    800048a0:	5c9c                	lw	a5,56(s1)
    800048a2:	37fd                	addiw	a5,a5,-1
    800048a4:	00078a1b          	sext.w	s4,a5
    800048a8:	dc9c                	sw	a5,56(s1)
  if(log[dev].committing)
    800048aa:	5cdc                	lw	a5,60(s1)
    800048ac:	efad                	bnez	a5,80004926 <end_op+0xbe>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    800048ae:	080a1463          	bnez	s4,80004936 <end_op+0xce>
    do_commit = 1;
    log[dev].committing = 1;
    800048b2:	00191793          	slli	a5,s2,0x1
    800048b6:	97ca                	add	a5,a5,s2
    800048b8:	079a                	slli	a5,a5,0x6
    800048ba:	00022997          	auipc	s3,0x22
    800048be:	15e98993          	addi	s3,s3,350 # 80026a18 <log>
    800048c2:	99be                	add	s3,s3,a5
    800048c4:	4785                	li	a5,1
    800048c6:	02f9ae23          	sw	a5,60(s3)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    800048ca:	8526                	mv	a0,s1
    800048cc:	ffffc097          	auipc	ra,0xffffc
    800048d0:	608080e7          	jalr	1544(ra) # 80000ed4 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    800048d4:	0449a783          	lw	a5,68(s3)
    800048d8:	06f04d63          	bgtz	a5,80004952 <end_op+0xea>
    acquire(&log[dev].lock);
    800048dc:	8526                	mv	a0,s1
    800048de:	ffffc097          	auipc	ra,0xffffc
    800048e2:	3aa080e7          	jalr	938(ra) # 80000c88 <acquire>
    log[dev].committing = 0;
    800048e6:	00022517          	auipc	a0,0x22
    800048ea:	13250513          	addi	a0,a0,306 # 80026a18 <log>
    800048ee:	00191793          	slli	a5,s2,0x1
    800048f2:	993e                	add	s2,s2,a5
    800048f4:	091a                	slli	s2,s2,0x6
    800048f6:	992a                	add	s2,s2,a0
    800048f8:	02092e23          	sw	zero,60(s2)
    wakeup(&log);
    800048fc:	ffffe097          	auipc	ra,0xffffe
    80004900:	0ac080e7          	jalr	172(ra) # 800029a8 <wakeup>
    release(&log[dev].lock);
    80004904:	8526                	mv	a0,s1
    80004906:	ffffc097          	auipc	ra,0xffffc
    8000490a:	5ce080e7          	jalr	1486(ra) # 80000ed4 <release>
}
    8000490e:	60a6                	ld	ra,72(sp)
    80004910:	6406                	ld	s0,64(sp)
    80004912:	74e2                	ld	s1,56(sp)
    80004914:	7942                	ld	s2,48(sp)
    80004916:	79a2                	ld	s3,40(sp)
    80004918:	7a02                	ld	s4,32(sp)
    8000491a:	6ae2                	ld	s5,24(sp)
    8000491c:	6b42                	ld	s6,16(sp)
    8000491e:	6ba2                	ld	s7,8(sp)
    80004920:	6c02                	ld	s8,0(sp)
    80004922:	6161                	addi	sp,sp,80
    80004924:	8082                	ret
    panic("log[dev].committing");
    80004926:	00004517          	auipc	a0,0x4
    8000492a:	25250513          	addi	a0,a0,594 # 80008b78 <userret+0xae8>
    8000492e:	ffffc097          	auipc	ra,0xffffc
    80004932:	e28080e7          	jalr	-472(ra) # 80000756 <panic>
    wakeup(&log);
    80004936:	00022517          	auipc	a0,0x22
    8000493a:	0e250513          	addi	a0,a0,226 # 80026a18 <log>
    8000493e:	ffffe097          	auipc	ra,0xffffe
    80004942:	06a080e7          	jalr	106(ra) # 800029a8 <wakeup>
  release(&log[dev].lock);
    80004946:	8526                	mv	a0,s1
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	58c080e7          	jalr	1420(ra) # 80000ed4 <release>
  if(do_commit){
    80004950:	bf7d                	j	8000490e <end_op+0xa6>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004952:	8b26                	mv	s6,s1
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80004954:	00090c1b          	sext.w	s8,s2
    80004958:	00191b93          	slli	s7,s2,0x1
    8000495c:	9bca                	add	s7,s7,s2
    8000495e:	006b9793          	slli	a5,s7,0x6
    80004962:	00022b97          	auipc	s7,0x22
    80004966:	0b6b8b93          	addi	s7,s7,182 # 80026a18 <log>
    8000496a:	9bbe                	add	s7,s7,a5
    8000496c:	030ba583          	lw	a1,48(s7)
    80004970:	014585bb          	addw	a1,a1,s4
    80004974:	2585                	addiw	a1,a1,1
    80004976:	8562                	mv	a0,s8
    80004978:	fffff097          	auipc	ra,0xfffff
    8000497c:	c6e080e7          	jalr	-914(ra) # 800035e6 <bread>
    80004980:	89aa                	mv	s3,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80004982:	048b2583          	lw	a1,72(s6)
    80004986:	8562                	mv	a0,s8
    80004988:	fffff097          	auipc	ra,0xfffff
    8000498c:	c5e080e7          	jalr	-930(ra) # 800035e6 <bread>
    80004990:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    80004992:	40000613          	li	a2,1024
    80004996:	07050593          	addi	a1,a0,112
    8000499a:	07098513          	addi	a0,s3,112
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	796080e7          	jalr	1942(ra) # 80001134 <memmove>
    bwrite(to);  // write the log
    800049a6:	854e                	mv	a0,s3
    800049a8:	fffff097          	auipc	ra,0xfffff
    800049ac:	d32080e7          	jalr	-718(ra) # 800036da <bwrite>
    brelse(from);
    800049b0:	8556                	mv	a0,s5
    800049b2:	fffff097          	auipc	ra,0xfffff
    800049b6:	d68080e7          	jalr	-664(ra) # 8000371a <brelse>
    brelse(to);
    800049ba:	854e                	mv	a0,s3
    800049bc:	fffff097          	auipc	ra,0xfffff
    800049c0:	d5e080e7          	jalr	-674(ra) # 8000371a <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800049c4:	2a05                	addiw	s4,s4,1
    800049c6:	0b11                	addi	s6,s6,4
    800049c8:	044ba783          	lw	a5,68(s7)
    800049cc:	fafa40e3          	blt	s4,a5,8000496c <end_op+0x104>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    800049d0:	854a                	mv	a0,s2
    800049d2:	00000097          	auipc	ra,0x0
    800049d6:	bde080e7          	jalr	-1058(ra) # 800045b0 <write_head>
    install_trans(dev); // Now install writes to home locations
    800049da:	854a                	mv	a0,s2
    800049dc:	00000097          	auipc	ra,0x0
    800049e0:	c4e080e7          	jalr	-946(ra) # 8000462a <install_trans>
    log[dev].lh.n = 0;
    800049e4:	00191793          	slli	a5,s2,0x1
    800049e8:	97ca                	add	a5,a5,s2
    800049ea:	079a                	slli	a5,a5,0x6
    800049ec:	00022717          	auipc	a4,0x22
    800049f0:	02c70713          	addi	a4,a4,44 # 80026a18 <log>
    800049f4:	97ba                	add	a5,a5,a4
    800049f6:	0407a223          	sw	zero,68(a5)
    write_head(dev);    // Erase the transaction from the log
    800049fa:	854a                	mv	a0,s2
    800049fc:	00000097          	auipc	ra,0x0
    80004a00:	bb4080e7          	jalr	-1100(ra) # 800045b0 <write_head>
    80004a04:	bde1                	j	800048dc <end_op+0x74>

0000000080004a06 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a06:	7179                	addi	sp,sp,-48
    80004a08:	f406                	sd	ra,40(sp)
    80004a0a:	f022                	sd	s0,32(sp)
    80004a0c:	ec26                	sd	s1,24(sp)
    80004a0e:	e84a                	sd	s2,16(sp)
    80004a10:	e44e                	sd	s3,8(sp)
    80004a12:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004a14:	4504                	lw	s1,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004a16:	00149793          	slli	a5,s1,0x1
    80004a1a:	97a6                	add	a5,a5,s1
    80004a1c:	079a                	slli	a5,a5,0x6
    80004a1e:	00022717          	auipc	a4,0x22
    80004a22:	ffa70713          	addi	a4,a4,-6 # 80026a18 <log>
    80004a26:	97ba                	add	a5,a5,a4
    80004a28:	43f4                	lw	a3,68(a5)
    80004a2a:	47f5                	li	a5,29
    80004a2c:	0ad7c863          	blt	a5,a3,80004adc <log_write+0xd6>
    80004a30:	89aa                	mv	s3,a0
    80004a32:	00149793          	slli	a5,s1,0x1
    80004a36:	97a6                	add	a5,a5,s1
    80004a38:	079a                	slli	a5,a5,0x6
    80004a3a:	97ba                	add	a5,a5,a4
    80004a3c:	5bdc                	lw	a5,52(a5)
    80004a3e:	37fd                	addiw	a5,a5,-1
    80004a40:	08f6de63          	bge	a3,a5,80004adc <log_write+0xd6>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004a44:	00149793          	slli	a5,s1,0x1
    80004a48:	97a6                	add	a5,a5,s1
    80004a4a:	079a                	slli	a5,a5,0x6
    80004a4c:	00022717          	auipc	a4,0x22
    80004a50:	fcc70713          	addi	a4,a4,-52 # 80026a18 <log>
    80004a54:	97ba                	add	a5,a5,a4
    80004a56:	5f9c                	lw	a5,56(a5)
    80004a58:	08f05a63          	blez	a5,80004aec <log_write+0xe6>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004a5c:	00149913          	slli	s2,s1,0x1
    80004a60:	9926                	add	s2,s2,s1
    80004a62:	00691793          	slli	a5,s2,0x6
    80004a66:	00022917          	auipc	s2,0x22
    80004a6a:	fb290913          	addi	s2,s2,-78 # 80026a18 <log>
    80004a6e:	993e                	add	s2,s2,a5
    80004a70:	854a                	mv	a0,s2
    80004a72:	ffffc097          	auipc	ra,0xffffc
    80004a76:	216080e7          	jalr	534(ra) # 80000c88 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004a7a:	04492603          	lw	a2,68(s2)
    80004a7e:	06c05f63          	blez	a2,80004afc <log_write+0xf6>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004a82:	00c9a583          	lw	a1,12(s3)
    80004a86:	874a                	mv	a4,s2
  for (i = 0; i < log[dev].lh.n; i++) {
    80004a88:	4781                	li	a5,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004a8a:	4734                	lw	a3,72(a4)
    80004a8c:	06b68963          	beq	a3,a1,80004afe <log_write+0xf8>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004a90:	2785                	addiw	a5,a5,1
    80004a92:	0711                	addi	a4,a4,4
    80004a94:	fec79be3          	bne	a5,a2,80004a8a <log_write+0x84>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004a98:	00149793          	slli	a5,s1,0x1
    80004a9c:	97a6                	add	a5,a5,s1
    80004a9e:	0792                	slli	a5,a5,0x4
    80004aa0:	97b2                	add	a5,a5,a2
    80004aa2:	07c1                	addi	a5,a5,16
    80004aa4:	078a                	slli	a5,a5,0x2
    80004aa6:	00022717          	auipc	a4,0x22
    80004aaa:	f7270713          	addi	a4,a4,-142 # 80026a18 <log>
    80004aae:	97ba                	add	a5,a5,a4
    80004ab0:	00c9a703          	lw	a4,12(s3)
    80004ab4:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    80004ab6:	854e                	mv	a0,s3
    80004ab8:	fffff097          	auipc	ra,0xfffff
    80004abc:	d00080e7          	jalr	-768(ra) # 800037b8 <bpin>
    log[dev].lh.n++;
    80004ac0:	00022697          	auipc	a3,0x22
    80004ac4:	f5868693          	addi	a3,a3,-168 # 80026a18 <log>
    80004ac8:	00149793          	slli	a5,s1,0x1
    80004acc:	00978733          	add	a4,a5,s1
    80004ad0:	071a                	slli	a4,a4,0x6
    80004ad2:	9736                	add	a4,a4,a3
    80004ad4:	437c                	lw	a5,68(a4)
    80004ad6:	2785                	addiw	a5,a5,1
    80004ad8:	c37c                	sw	a5,68(a4)
    80004ada:	a099                	j	80004b20 <log_write+0x11a>
    panic("too big a transaction");
    80004adc:	00004517          	auipc	a0,0x4
    80004ae0:	0b450513          	addi	a0,a0,180 # 80008b90 <userret+0xb00>
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	c72080e7          	jalr	-910(ra) # 80000756 <panic>
    panic("log_write outside of trans");
    80004aec:	00004517          	auipc	a0,0x4
    80004af0:	0bc50513          	addi	a0,a0,188 # 80008ba8 <userret+0xb18>
    80004af4:	ffffc097          	auipc	ra,0xffffc
    80004af8:	c62080e7          	jalr	-926(ra) # 80000756 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004afc:	4781                	li	a5,0
  log[dev].lh.block[i] = b->blockno;
    80004afe:	00149713          	slli	a4,s1,0x1
    80004b02:	9726                	add	a4,a4,s1
    80004b04:	0712                	slli	a4,a4,0x4
    80004b06:	973e                	add	a4,a4,a5
    80004b08:	0741                	addi	a4,a4,16
    80004b0a:	070a                	slli	a4,a4,0x2
    80004b0c:	00022697          	auipc	a3,0x22
    80004b10:	f0c68693          	addi	a3,a3,-244 # 80026a18 <log>
    80004b14:	9736                	add	a4,a4,a3
    80004b16:	00c9a683          	lw	a3,12(s3)
    80004b1a:	c714                	sw	a3,8(a4)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004b1c:	f8f60de3          	beq	a2,a5,80004ab6 <log_write+0xb0>
  }
  release(&log[dev].lock);
    80004b20:	854a                	mv	a0,s2
    80004b22:	ffffc097          	auipc	ra,0xffffc
    80004b26:	3b2080e7          	jalr	946(ra) # 80000ed4 <release>
}
    80004b2a:	70a2                	ld	ra,40(sp)
    80004b2c:	7402                	ld	s0,32(sp)
    80004b2e:	64e2                	ld	s1,24(sp)
    80004b30:	6942                	ld	s2,16(sp)
    80004b32:	69a2                	ld	s3,8(sp)
    80004b34:	6145                	addi	sp,sp,48
    80004b36:	8082                	ret

0000000080004b38 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b38:	1101                	addi	sp,sp,-32
    80004b3a:	ec06                	sd	ra,24(sp)
    80004b3c:	e822                	sd	s0,16(sp)
    80004b3e:	e426                	sd	s1,8(sp)
    80004b40:	e04a                	sd	s2,0(sp)
    80004b42:	1000                	addi	s0,sp,32
    80004b44:	84aa                	mv	s1,a0
    80004b46:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b48:	00004597          	auipc	a1,0x4
    80004b4c:	08058593          	addi	a1,a1,128 # 80008bc8 <userret+0xb38>
    80004b50:	0521                	addi	a0,a0,8
    80004b52:	ffffc097          	auipc	ra,0xffffc
    80004b56:	fcc080e7          	jalr	-52(ra) # 80000b1e <initlock>
  lk->name = name;
    80004b5a:	0324bc23          	sd	s2,56(s1)
  lk->locked = 0;
    80004b5e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b62:	0404a023          	sw	zero,64(s1)
}
    80004b66:	60e2                	ld	ra,24(sp)
    80004b68:	6442                	ld	s0,16(sp)
    80004b6a:	64a2                	ld	s1,8(sp)
    80004b6c:	6902                	ld	s2,0(sp)
    80004b6e:	6105                	addi	sp,sp,32
    80004b70:	8082                	ret

0000000080004b72 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b72:	1101                	addi	sp,sp,-32
    80004b74:	ec06                	sd	ra,24(sp)
    80004b76:	e822                	sd	s0,16(sp)
    80004b78:	e426                	sd	s1,8(sp)
    80004b7a:	e04a                	sd	s2,0(sp)
    80004b7c:	1000                	addi	s0,sp,32
    80004b7e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b80:	00850913          	addi	s2,a0,8
    80004b84:	854a                	mv	a0,s2
    80004b86:	ffffc097          	auipc	ra,0xffffc
    80004b8a:	102080e7          	jalr	258(ra) # 80000c88 <acquire>
  while (lk->locked) {
    80004b8e:	409c                	lw	a5,0(s1)
    80004b90:	cb89                	beqz	a5,80004ba2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b92:	85ca                	mv	a1,s2
    80004b94:	8526                	mv	a0,s1
    80004b96:	ffffe097          	auipc	ra,0xffffe
    80004b9a:	c8c080e7          	jalr	-884(ra) # 80002822 <sleep>
  while (lk->locked) {
    80004b9e:	409c                	lw	a5,0(s1)
    80004ba0:	fbed                	bnez	a5,80004b92 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004ba2:	4785                	li	a5,1
    80004ba4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ba6:	ffffd097          	auipc	ra,0xffffd
    80004baa:	3f6080e7          	jalr	1014(ra) # 80001f9c <myproc>
    80004bae:	493c                	lw	a5,80(a0)
    80004bb0:	c0bc                	sw	a5,64(s1)
  release(&lk->lk);
    80004bb2:	854a                	mv	a0,s2
    80004bb4:	ffffc097          	auipc	ra,0xffffc
    80004bb8:	320080e7          	jalr	800(ra) # 80000ed4 <release>
}
    80004bbc:	60e2                	ld	ra,24(sp)
    80004bbe:	6442                	ld	s0,16(sp)
    80004bc0:	64a2                	ld	s1,8(sp)
    80004bc2:	6902                	ld	s2,0(sp)
    80004bc4:	6105                	addi	sp,sp,32
    80004bc6:	8082                	ret

0000000080004bc8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004bc8:	1101                	addi	sp,sp,-32
    80004bca:	ec06                	sd	ra,24(sp)
    80004bcc:	e822                	sd	s0,16(sp)
    80004bce:	e426                	sd	s1,8(sp)
    80004bd0:	e04a                	sd	s2,0(sp)
    80004bd2:	1000                	addi	s0,sp,32
    80004bd4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bd6:	00850913          	addi	s2,a0,8
    80004bda:	854a                	mv	a0,s2
    80004bdc:	ffffc097          	auipc	ra,0xffffc
    80004be0:	0ac080e7          	jalr	172(ra) # 80000c88 <acquire>
  lk->locked = 0;
    80004be4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004be8:	0404a023          	sw	zero,64(s1)
  wakeup(lk);
    80004bec:	8526                	mv	a0,s1
    80004bee:	ffffe097          	auipc	ra,0xffffe
    80004bf2:	dba080e7          	jalr	-582(ra) # 800029a8 <wakeup>
  release(&lk->lk);
    80004bf6:	854a                	mv	a0,s2
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	2dc080e7          	jalr	732(ra) # 80000ed4 <release>
}
    80004c00:	60e2                	ld	ra,24(sp)
    80004c02:	6442                	ld	s0,16(sp)
    80004c04:	64a2                	ld	s1,8(sp)
    80004c06:	6902                	ld	s2,0(sp)
    80004c08:	6105                	addi	sp,sp,32
    80004c0a:	8082                	ret

0000000080004c0c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c0c:	7179                	addi	sp,sp,-48
    80004c0e:	f406                	sd	ra,40(sp)
    80004c10:	f022                	sd	s0,32(sp)
    80004c12:	ec26                	sd	s1,24(sp)
    80004c14:	e84a                	sd	s2,16(sp)
    80004c16:	e44e                	sd	s3,8(sp)
    80004c18:	1800                	addi	s0,sp,48
    80004c1a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c1c:	00850913          	addi	s2,a0,8
    80004c20:	854a                	mv	a0,s2
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	066080e7          	jalr	102(ra) # 80000c88 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c2a:	409c                	lw	a5,0(s1)
    80004c2c:	ef99                	bnez	a5,80004c4a <holdingsleep+0x3e>
    80004c2e:	4481                	li	s1,0
  release(&lk->lk);
    80004c30:	854a                	mv	a0,s2
    80004c32:	ffffc097          	auipc	ra,0xffffc
    80004c36:	2a2080e7          	jalr	674(ra) # 80000ed4 <release>
  return r;
}
    80004c3a:	8526                	mv	a0,s1
    80004c3c:	70a2                	ld	ra,40(sp)
    80004c3e:	7402                	ld	s0,32(sp)
    80004c40:	64e2                	ld	s1,24(sp)
    80004c42:	6942                	ld	s2,16(sp)
    80004c44:	69a2                	ld	s3,8(sp)
    80004c46:	6145                	addi	sp,sp,48
    80004c48:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c4a:	0404a983          	lw	s3,64(s1)
    80004c4e:	ffffd097          	auipc	ra,0xffffd
    80004c52:	34e080e7          	jalr	846(ra) # 80001f9c <myproc>
    80004c56:	4924                	lw	s1,80(a0)
    80004c58:	413484b3          	sub	s1,s1,s3
    80004c5c:	0014b493          	seqz	s1,s1
    80004c60:	bfc1                	j	80004c30 <holdingsleep+0x24>

0000000080004c62 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c62:	1141                	addi	sp,sp,-16
    80004c64:	e406                	sd	ra,8(sp)
    80004c66:	e022                	sd	s0,0(sp)
    80004c68:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c6a:	00004597          	auipc	a1,0x4
    80004c6e:	f6e58593          	addi	a1,a1,-146 # 80008bd8 <userret+0xb48>
    80004c72:	00022517          	auipc	a0,0x22
    80004c76:	fc650513          	addi	a0,a0,-58 # 80026c38 <ftable>
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	ea4080e7          	jalr	-348(ra) # 80000b1e <initlock>
}
    80004c82:	60a2                	ld	ra,8(sp)
    80004c84:	6402                	ld	s0,0(sp)
    80004c86:	0141                	addi	sp,sp,16
    80004c88:	8082                	ret

0000000080004c8a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c8a:	1101                	addi	sp,sp,-32
    80004c8c:	ec06                	sd	ra,24(sp)
    80004c8e:	e822                	sd	s0,16(sp)
    80004c90:	e426                	sd	s1,8(sp)
    80004c92:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c94:	00022517          	auipc	a0,0x22
    80004c98:	fa450513          	addi	a0,a0,-92 # 80026c38 <ftable>
    80004c9c:	ffffc097          	auipc	ra,0xffffc
    80004ca0:	fec080e7          	jalr	-20(ra) # 80000c88 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ca4:	00022497          	auipc	s1,0x22
    80004ca8:	fc448493          	addi	s1,s1,-60 # 80026c68 <ftable+0x30>
    80004cac:	00023717          	auipc	a4,0x23
    80004cb0:	f5c70713          	addi	a4,a4,-164 # 80027c08 <ftable+0xfd0>
    if(f->ref == 0){
    80004cb4:	40dc                	lw	a5,4(s1)
    80004cb6:	cf99                	beqz	a5,80004cd4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004cb8:	02848493          	addi	s1,s1,40
    80004cbc:	fee49ce3          	bne	s1,a4,80004cb4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004cc0:	00022517          	auipc	a0,0x22
    80004cc4:	f7850513          	addi	a0,a0,-136 # 80026c38 <ftable>
    80004cc8:	ffffc097          	auipc	ra,0xffffc
    80004ccc:	20c080e7          	jalr	524(ra) # 80000ed4 <release>
  return 0;
    80004cd0:	4481                	li	s1,0
    80004cd2:	a819                	j	80004ce8 <filealloc+0x5e>
      f->ref = 1;
    80004cd4:	4785                	li	a5,1
    80004cd6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004cd8:	00022517          	auipc	a0,0x22
    80004cdc:	f6050513          	addi	a0,a0,-160 # 80026c38 <ftable>
    80004ce0:	ffffc097          	auipc	ra,0xffffc
    80004ce4:	1f4080e7          	jalr	500(ra) # 80000ed4 <release>
}
    80004ce8:	8526                	mv	a0,s1
    80004cea:	60e2                	ld	ra,24(sp)
    80004cec:	6442                	ld	s0,16(sp)
    80004cee:	64a2                	ld	s1,8(sp)
    80004cf0:	6105                	addi	sp,sp,32
    80004cf2:	8082                	ret

0000000080004cf4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004cf4:	1101                	addi	sp,sp,-32
    80004cf6:	ec06                	sd	ra,24(sp)
    80004cf8:	e822                	sd	s0,16(sp)
    80004cfa:	e426                	sd	s1,8(sp)
    80004cfc:	1000                	addi	s0,sp,32
    80004cfe:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004d00:	00022517          	auipc	a0,0x22
    80004d04:	f3850513          	addi	a0,a0,-200 # 80026c38 <ftable>
    80004d08:	ffffc097          	auipc	ra,0xffffc
    80004d0c:	f80080e7          	jalr	-128(ra) # 80000c88 <acquire>
  if(f->ref < 1)
    80004d10:	40dc                	lw	a5,4(s1)
    80004d12:	02f05263          	blez	a5,80004d36 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d16:	2785                	addiw	a5,a5,1
    80004d18:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d1a:	00022517          	auipc	a0,0x22
    80004d1e:	f1e50513          	addi	a0,a0,-226 # 80026c38 <ftable>
    80004d22:	ffffc097          	auipc	ra,0xffffc
    80004d26:	1b2080e7          	jalr	434(ra) # 80000ed4 <release>
  return f;
}
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	60e2                	ld	ra,24(sp)
    80004d2e:	6442                	ld	s0,16(sp)
    80004d30:	64a2                	ld	s1,8(sp)
    80004d32:	6105                	addi	sp,sp,32
    80004d34:	8082                	ret
    panic("filedup");
    80004d36:	00004517          	auipc	a0,0x4
    80004d3a:	eaa50513          	addi	a0,a0,-342 # 80008be0 <userret+0xb50>
    80004d3e:	ffffc097          	auipc	ra,0xffffc
    80004d42:	a18080e7          	jalr	-1512(ra) # 80000756 <panic>

0000000080004d46 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004d46:	7139                	addi	sp,sp,-64
    80004d48:	fc06                	sd	ra,56(sp)
    80004d4a:	f822                	sd	s0,48(sp)
    80004d4c:	f426                	sd	s1,40(sp)
    80004d4e:	f04a                	sd	s2,32(sp)
    80004d50:	ec4e                	sd	s3,24(sp)
    80004d52:	e852                	sd	s4,16(sp)
    80004d54:	e456                	sd	s5,8(sp)
    80004d56:	0080                	addi	s0,sp,64
    80004d58:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d5a:	00022517          	auipc	a0,0x22
    80004d5e:	ede50513          	addi	a0,a0,-290 # 80026c38 <ftable>
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	f26080e7          	jalr	-218(ra) # 80000c88 <acquire>
  if(f->ref < 1)
    80004d6a:	40dc                	lw	a5,4(s1)
    80004d6c:	06f05563          	blez	a5,80004dd6 <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004d70:	37fd                	addiw	a5,a5,-1
    80004d72:	0007871b          	sext.w	a4,a5
    80004d76:	c0dc                	sw	a5,4(s1)
    80004d78:	06e04763          	bgtz	a4,80004de6 <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d7c:	0004a903          	lw	s2,0(s1)
    80004d80:	0094ca83          	lbu	s5,9(s1)
    80004d84:	0104ba03          	ld	s4,16(s1)
    80004d88:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d8c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d90:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d94:	00022517          	auipc	a0,0x22
    80004d98:	ea450513          	addi	a0,a0,-348 # 80026c38 <ftable>
    80004d9c:	ffffc097          	auipc	ra,0xffffc
    80004da0:	138080e7          	jalr	312(ra) # 80000ed4 <release>

  if(ff.type == FD_PIPE){
    80004da4:	4785                	li	a5,1
    80004da6:	06f90163          	beq	s2,a5,80004e08 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004daa:	3979                	addiw	s2,s2,-2
    80004dac:	4785                	li	a5,1
    80004dae:	0527e463          	bltu	a5,s2,80004df6 <fileclose+0xb0>
    begin_op(ff.ip->dev);
    80004db2:	0009a503          	lw	a0,0(s3)
    80004db6:	00000097          	auipc	ra,0x0
    80004dba:	a06080e7          	jalr	-1530(ra) # 800047bc <begin_op>
    iput(ff.ip);
    80004dbe:	854e                	mv	a0,s3
    80004dc0:	fffff097          	auipc	ra,0xfffff
    80004dc4:	13a080e7          	jalr	314(ra) # 80003efa <iput>
    end_op(ff.ip->dev);
    80004dc8:	0009a503          	lw	a0,0(s3)
    80004dcc:	00000097          	auipc	ra,0x0
    80004dd0:	a9c080e7          	jalr	-1380(ra) # 80004868 <end_op>
    80004dd4:	a00d                	j	80004df6 <fileclose+0xb0>
    panic("fileclose");
    80004dd6:	00004517          	auipc	a0,0x4
    80004dda:	e1250513          	addi	a0,a0,-494 # 80008be8 <userret+0xb58>
    80004dde:	ffffc097          	auipc	ra,0xffffc
    80004de2:	978080e7          	jalr	-1672(ra) # 80000756 <panic>
    release(&ftable.lock);
    80004de6:	00022517          	auipc	a0,0x22
    80004dea:	e5250513          	addi	a0,a0,-430 # 80026c38 <ftable>
    80004dee:	ffffc097          	auipc	ra,0xffffc
    80004df2:	0e6080e7          	jalr	230(ra) # 80000ed4 <release>
  }
}
    80004df6:	70e2                	ld	ra,56(sp)
    80004df8:	7442                	ld	s0,48(sp)
    80004dfa:	74a2                	ld	s1,40(sp)
    80004dfc:	7902                	ld	s2,32(sp)
    80004dfe:	69e2                	ld	s3,24(sp)
    80004e00:	6a42                	ld	s4,16(sp)
    80004e02:	6aa2                	ld	s5,8(sp)
    80004e04:	6121                	addi	sp,sp,64
    80004e06:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004e08:	85d6                	mv	a1,s5
    80004e0a:	8552                	mv	a0,s4
    80004e0c:	00000097          	auipc	ra,0x0
    80004e10:	376080e7          	jalr	886(ra) # 80005182 <pipeclose>
    80004e14:	b7cd                	j	80004df6 <fileclose+0xb0>

0000000080004e16 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004e16:	715d                	addi	sp,sp,-80
    80004e18:	e486                	sd	ra,72(sp)
    80004e1a:	e0a2                	sd	s0,64(sp)
    80004e1c:	fc26                	sd	s1,56(sp)
    80004e1e:	f84a                	sd	s2,48(sp)
    80004e20:	f44e                	sd	s3,40(sp)
    80004e22:	0880                	addi	s0,sp,80
    80004e24:	84aa                	mv	s1,a0
    80004e26:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e28:	ffffd097          	auipc	ra,0xffffd
    80004e2c:	174080e7          	jalr	372(ra) # 80001f9c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e30:	409c                	lw	a5,0(s1)
    80004e32:	37f9                	addiw	a5,a5,-2
    80004e34:	4705                	li	a4,1
    80004e36:	04f76763          	bltu	a4,a5,80004e84 <filestat+0x6e>
    80004e3a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e3c:	6c88                	ld	a0,24(s1)
    80004e3e:	fffff097          	auipc	ra,0xfffff
    80004e42:	fae080e7          	jalr	-82(ra) # 80003dec <ilock>
    stati(f->ip, &st);
    80004e46:	fb840593          	addi	a1,s0,-72
    80004e4a:	6c88                	ld	a0,24(s1)
    80004e4c:	fffff097          	auipc	ra,0xfffff
    80004e50:	206080e7          	jalr	518(ra) # 80004052 <stati>
    iunlock(f->ip);
    80004e54:	6c88                	ld	a0,24(s1)
    80004e56:	fffff097          	auipc	ra,0xfffff
    80004e5a:	058080e7          	jalr	88(ra) # 80003eae <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e5e:	46e1                	li	a3,24
    80004e60:	fb840613          	addi	a2,s0,-72
    80004e64:	85ce                	mv	a1,s3
    80004e66:	06893503          	ld	a0,104(s2)
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	d34080e7          	jalr	-716(ra) # 80001b9e <copyout>
    80004e72:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004e76:	60a6                	ld	ra,72(sp)
    80004e78:	6406                	ld	s0,64(sp)
    80004e7a:	74e2                	ld	s1,56(sp)
    80004e7c:	7942                	ld	s2,48(sp)
    80004e7e:	79a2                	ld	s3,40(sp)
    80004e80:	6161                	addi	sp,sp,80
    80004e82:	8082                	ret
  return -1;
    80004e84:	557d                	li	a0,-1
    80004e86:	bfc5                	j	80004e76 <filestat+0x60>

0000000080004e88 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e88:	7179                	addi	sp,sp,-48
    80004e8a:	f406                	sd	ra,40(sp)
    80004e8c:	f022                	sd	s0,32(sp)
    80004e8e:	ec26                	sd	s1,24(sp)
    80004e90:	e84a                	sd	s2,16(sp)
    80004e92:	e44e                	sd	s3,8(sp)
    80004e94:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e96:	00854783          	lbu	a5,8(a0)
    80004e9a:	c7c5                	beqz	a5,80004f42 <fileread+0xba>
    80004e9c:	84aa                	mv	s1,a0
    80004e9e:	89ae                	mv	s3,a1
    80004ea0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ea2:	411c                	lw	a5,0(a0)
    80004ea4:	4705                	li	a4,1
    80004ea6:	04e78963          	beq	a5,a4,80004ef8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004eaa:	470d                	li	a4,3
    80004eac:	04e78d63          	beq	a5,a4,80004f06 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004eb0:	4709                	li	a4,2
    80004eb2:	08e79063          	bne	a5,a4,80004f32 <fileread+0xaa>
    ilock(f->ip);
    80004eb6:	6d08                	ld	a0,24(a0)
    80004eb8:	fffff097          	auipc	ra,0xfffff
    80004ebc:	f34080e7          	jalr	-204(ra) # 80003dec <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ec0:	874a                	mv	a4,s2
    80004ec2:	5094                	lw	a3,32(s1)
    80004ec4:	864e                	mv	a2,s3
    80004ec6:	4585                	li	a1,1
    80004ec8:	6c88                	ld	a0,24(s1)
    80004eca:	fffff097          	auipc	ra,0xfffff
    80004ece:	1b2080e7          	jalr	434(ra) # 8000407c <readi>
    80004ed2:	892a                	mv	s2,a0
    80004ed4:	00a05563          	blez	a0,80004ede <fileread+0x56>
      f->off += r;
    80004ed8:	509c                	lw	a5,32(s1)
    80004eda:	9fa9                	addw	a5,a5,a0
    80004edc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ede:	6c88                	ld	a0,24(s1)
    80004ee0:	fffff097          	auipc	ra,0xfffff
    80004ee4:	fce080e7          	jalr	-50(ra) # 80003eae <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ee8:	854a                	mv	a0,s2
    80004eea:	70a2                	ld	ra,40(sp)
    80004eec:	7402                	ld	s0,32(sp)
    80004eee:	64e2                	ld	s1,24(sp)
    80004ef0:	6942                	ld	s2,16(sp)
    80004ef2:	69a2                	ld	s3,8(sp)
    80004ef4:	6145                	addi	sp,sp,48
    80004ef6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ef8:	6908                	ld	a0,16(a0)
    80004efa:	00000097          	auipc	ra,0x0
    80004efe:	40c080e7          	jalr	1036(ra) # 80005306 <piperead>
    80004f02:	892a                	mv	s2,a0
    80004f04:	b7d5                	j	80004ee8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004f06:	02451783          	lh	a5,36(a0)
    80004f0a:	03079693          	slli	a3,a5,0x30
    80004f0e:	92c1                	srli	a3,a3,0x30
    80004f10:	4725                	li	a4,9
    80004f12:	02d76a63          	bltu	a4,a3,80004f46 <fileread+0xbe>
    80004f16:	0792                	slli	a5,a5,0x4
    80004f18:	00022717          	auipc	a4,0x22
    80004f1c:	c8070713          	addi	a4,a4,-896 # 80026b98 <devsw>
    80004f20:	97ba                	add	a5,a5,a4
    80004f22:	639c                	ld	a5,0(a5)
    80004f24:	c39d                	beqz	a5,80004f4a <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004f26:	86b2                	mv	a3,a2
    80004f28:	862e                	mv	a2,a1
    80004f2a:	4585                	li	a1,1
    80004f2c:	9782                	jalr	a5
    80004f2e:	892a                	mv	s2,a0
    80004f30:	bf65                	j	80004ee8 <fileread+0x60>
    panic("fileread");
    80004f32:	00004517          	auipc	a0,0x4
    80004f36:	cc650513          	addi	a0,a0,-826 # 80008bf8 <userret+0xb68>
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	81c080e7          	jalr	-2020(ra) # 80000756 <panic>
    return -1;
    80004f42:	597d                	li	s2,-1
    80004f44:	b755                	j	80004ee8 <fileread+0x60>
      return -1;
    80004f46:	597d                	li	s2,-1
    80004f48:	b745                	j	80004ee8 <fileread+0x60>
    80004f4a:	597d                	li	s2,-1
    80004f4c:	bf71                	j	80004ee8 <fileread+0x60>

0000000080004f4e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004f4e:	00954783          	lbu	a5,9(a0)
    80004f52:	14078663          	beqz	a5,8000509e <filewrite+0x150>
{
    80004f56:	715d                	addi	sp,sp,-80
    80004f58:	e486                	sd	ra,72(sp)
    80004f5a:	e0a2                	sd	s0,64(sp)
    80004f5c:	fc26                	sd	s1,56(sp)
    80004f5e:	f84a                	sd	s2,48(sp)
    80004f60:	f44e                	sd	s3,40(sp)
    80004f62:	f052                	sd	s4,32(sp)
    80004f64:	ec56                	sd	s5,24(sp)
    80004f66:	e85a                	sd	s6,16(sp)
    80004f68:	e45e                	sd	s7,8(sp)
    80004f6a:	e062                	sd	s8,0(sp)
    80004f6c:	0880                	addi	s0,sp,80
    80004f6e:	84aa                	mv	s1,a0
    80004f70:	8aae                	mv	s5,a1
    80004f72:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f74:	411c                	lw	a5,0(a0)
    80004f76:	4705                	li	a4,1
    80004f78:	02e78263          	beq	a5,a4,80004f9c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f7c:	470d                	li	a4,3
    80004f7e:	02e78563          	beq	a5,a4,80004fa8 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004f82:	4709                	li	a4,2
    80004f84:	10e79563          	bne	a5,a4,8000508e <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f88:	0ec05f63          	blez	a2,80005086 <filewrite+0x138>
    int i = 0;
    80004f8c:	4981                	li	s3,0
    80004f8e:	6b05                	lui	s6,0x1
    80004f90:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004f94:	6b85                	lui	s7,0x1
    80004f96:	c00b8b9b          	addiw	s7,s7,-1024
    80004f9a:	a851                	j	8000502e <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004f9c:	6908                	ld	a0,16(a0)
    80004f9e:	00000097          	auipc	ra,0x0
    80004fa2:	254080e7          	jalr	596(ra) # 800051f2 <pipewrite>
    80004fa6:	a865                	j	8000505e <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004fa8:	02451783          	lh	a5,36(a0)
    80004fac:	03079693          	slli	a3,a5,0x30
    80004fb0:	92c1                	srli	a3,a3,0x30
    80004fb2:	4725                	li	a4,9
    80004fb4:	0ed76763          	bltu	a4,a3,800050a2 <filewrite+0x154>
    80004fb8:	0792                	slli	a5,a5,0x4
    80004fba:	00022717          	auipc	a4,0x22
    80004fbe:	bde70713          	addi	a4,a4,-1058 # 80026b98 <devsw>
    80004fc2:	97ba                	add	a5,a5,a4
    80004fc4:	679c                	ld	a5,8(a5)
    80004fc6:	c3e5                	beqz	a5,800050a6 <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004fc8:	86b2                	mv	a3,a2
    80004fca:	862e                	mv	a2,a1
    80004fcc:	4585                	li	a1,1
    80004fce:	9782                	jalr	a5
    80004fd0:	a079                	j	8000505e <filewrite+0x110>
    80004fd2:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80004fd6:	6c9c                	ld	a5,24(s1)
    80004fd8:	4388                	lw	a0,0(a5)
    80004fda:	fffff097          	auipc	ra,0xfffff
    80004fde:	7e2080e7          	jalr	2018(ra) # 800047bc <begin_op>
      ilock(f->ip);
    80004fe2:	6c88                	ld	a0,24(s1)
    80004fe4:	fffff097          	auipc	ra,0xfffff
    80004fe8:	e08080e7          	jalr	-504(ra) # 80003dec <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004fec:	8762                	mv	a4,s8
    80004fee:	5094                	lw	a3,32(s1)
    80004ff0:	01598633          	add	a2,s3,s5
    80004ff4:	4585                	li	a1,1
    80004ff6:	6c88                	ld	a0,24(s1)
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	178080e7          	jalr	376(ra) # 80004170 <writei>
    80005000:	892a                	mv	s2,a0
    80005002:	02a05e63          	blez	a0,8000503e <filewrite+0xf0>
        f->off += r;
    80005006:	509c                	lw	a5,32(s1)
    80005008:	9fa9                	addw	a5,a5,a0
    8000500a:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    8000500c:	6c88                	ld	a0,24(s1)
    8000500e:	fffff097          	auipc	ra,0xfffff
    80005012:	ea0080e7          	jalr	-352(ra) # 80003eae <iunlock>
      end_op(f->ip->dev);
    80005016:	6c9c                	ld	a5,24(s1)
    80005018:	4388                	lw	a0,0(a5)
    8000501a:	00000097          	auipc	ra,0x0
    8000501e:	84e080e7          	jalr	-1970(ra) # 80004868 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80005022:	052c1a63          	bne	s8,s2,80005076 <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80005026:	013909bb          	addw	s3,s2,s3
    while(i < n){
    8000502a:	0349d763          	bge	s3,s4,80005058 <filewrite+0x10a>
      int n1 = n - i;
    8000502e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005032:	893e                	mv	s2,a5
    80005034:	2781                	sext.w	a5,a5
    80005036:	f8fb5ee3          	bge	s6,a5,80004fd2 <filewrite+0x84>
    8000503a:	895e                	mv	s2,s7
    8000503c:	bf59                	j	80004fd2 <filewrite+0x84>
      iunlock(f->ip);
    8000503e:	6c88                	ld	a0,24(s1)
    80005040:	fffff097          	auipc	ra,0xfffff
    80005044:	e6e080e7          	jalr	-402(ra) # 80003eae <iunlock>
      end_op(f->ip->dev);
    80005048:	6c9c                	ld	a5,24(s1)
    8000504a:	4388                	lw	a0,0(a5)
    8000504c:	00000097          	auipc	ra,0x0
    80005050:	81c080e7          	jalr	-2020(ra) # 80004868 <end_op>
      if(r < 0)
    80005054:	fc0957e3          	bgez	s2,80005022 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80005058:	8552                	mv	a0,s4
    8000505a:	033a1863          	bne	s4,s3,8000508a <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000505e:	60a6                	ld	ra,72(sp)
    80005060:	6406                	ld	s0,64(sp)
    80005062:	74e2                	ld	s1,56(sp)
    80005064:	7942                	ld	s2,48(sp)
    80005066:	79a2                	ld	s3,40(sp)
    80005068:	7a02                	ld	s4,32(sp)
    8000506a:	6ae2                	ld	s5,24(sp)
    8000506c:	6b42                	ld	s6,16(sp)
    8000506e:	6ba2                	ld	s7,8(sp)
    80005070:	6c02                	ld	s8,0(sp)
    80005072:	6161                	addi	sp,sp,80
    80005074:	8082                	ret
        panic("short filewrite");
    80005076:	00004517          	auipc	a0,0x4
    8000507a:	b9250513          	addi	a0,a0,-1134 # 80008c08 <userret+0xb78>
    8000507e:	ffffb097          	auipc	ra,0xffffb
    80005082:	6d8080e7          	jalr	1752(ra) # 80000756 <panic>
    int i = 0;
    80005086:	4981                	li	s3,0
    80005088:	bfc1                	j	80005058 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    8000508a:	557d                	li	a0,-1
    8000508c:	bfc9                	j	8000505e <filewrite+0x110>
    panic("filewrite");
    8000508e:	00004517          	auipc	a0,0x4
    80005092:	b8a50513          	addi	a0,a0,-1142 # 80008c18 <userret+0xb88>
    80005096:	ffffb097          	auipc	ra,0xffffb
    8000509a:	6c0080e7          	jalr	1728(ra) # 80000756 <panic>
    return -1;
    8000509e:	557d                	li	a0,-1
}
    800050a0:	8082                	ret
      return -1;
    800050a2:	557d                	li	a0,-1
    800050a4:	bf6d                	j	8000505e <filewrite+0x110>
    800050a6:	557d                	li	a0,-1
    800050a8:	bf5d                	j	8000505e <filewrite+0x110>

00000000800050aa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800050aa:	7179                	addi	sp,sp,-48
    800050ac:	f406                	sd	ra,40(sp)
    800050ae:	f022                	sd	s0,32(sp)
    800050b0:	ec26                	sd	s1,24(sp)
    800050b2:	e84a                	sd	s2,16(sp)
    800050b4:	e44e                	sd	s3,8(sp)
    800050b6:	e052                	sd	s4,0(sp)
    800050b8:	1800                	addi	s0,sp,48
    800050ba:	84aa                	mv	s1,a0
    800050bc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800050be:	0005b023          	sd	zero,0(a1)
    800050c2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800050c6:	00000097          	auipc	ra,0x0
    800050ca:	bc4080e7          	jalr	-1084(ra) # 80004c8a <filealloc>
    800050ce:	e088                	sd	a0,0(s1)
    800050d0:	c549                	beqz	a0,8000515a <pipealloc+0xb0>
    800050d2:	00000097          	auipc	ra,0x0
    800050d6:	bb8080e7          	jalr	-1096(ra) # 80004c8a <filealloc>
    800050da:	00aa3023          	sd	a0,0(s4)
    800050de:	c925                	beqz	a0,8000514e <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800050e0:	ffffc097          	auipc	ra,0xffffc
    800050e4:	a24080e7          	jalr	-1500(ra) # 80000b04 <kalloc>
    800050e8:	892a                	mv	s2,a0
    800050ea:	cd39                	beqz	a0,80005148 <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    800050ec:	4985                	li	s3,1
    800050ee:	23352c23          	sw	s3,568(a0)
  pi->writeopen = 1;
    800050f2:	23352e23          	sw	s3,572(a0)
  pi->nwrite = 0;
    800050f6:	22052a23          	sw	zero,564(a0)
  pi->nread = 0;
    800050fa:	22052823          	sw	zero,560(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    800050fe:	03000613          	li	a2,48
    80005102:	4581                	li	a1,0
    80005104:	ffffc097          	auipc	ra,0xffffc
    80005108:	fd0080e7          	jalr	-48(ra) # 800010d4 <memset>
  (*f0)->type = FD_PIPE;
    8000510c:	609c                	ld	a5,0(s1)
    8000510e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005112:	609c                	ld	a5,0(s1)
    80005114:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005118:	609c                	ld	a5,0(s1)
    8000511a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000511e:	609c                	ld	a5,0(s1)
    80005120:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005124:	000a3783          	ld	a5,0(s4)
    80005128:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000512c:	000a3783          	ld	a5,0(s4)
    80005130:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005134:	000a3783          	ld	a5,0(s4)
    80005138:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000513c:	000a3783          	ld	a5,0(s4)
    80005140:	0127b823          	sd	s2,16(a5)
  return 0;
    80005144:	4501                	li	a0,0
    80005146:	a025                	j	8000516e <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005148:	6088                	ld	a0,0(s1)
    8000514a:	e501                	bnez	a0,80005152 <pipealloc+0xa8>
    8000514c:	a039                	j	8000515a <pipealloc+0xb0>
    8000514e:	6088                	ld	a0,0(s1)
    80005150:	c51d                	beqz	a0,8000517e <pipealloc+0xd4>
    fileclose(*f0);
    80005152:	00000097          	auipc	ra,0x0
    80005156:	bf4080e7          	jalr	-1036(ra) # 80004d46 <fileclose>
  if(*f1)
    8000515a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000515e:	557d                	li	a0,-1
  if(*f1)
    80005160:	c799                	beqz	a5,8000516e <pipealloc+0xc4>
    fileclose(*f1);
    80005162:	853e                	mv	a0,a5
    80005164:	00000097          	auipc	ra,0x0
    80005168:	be2080e7          	jalr	-1054(ra) # 80004d46 <fileclose>
  return -1;
    8000516c:	557d                	li	a0,-1
}
    8000516e:	70a2                	ld	ra,40(sp)
    80005170:	7402                	ld	s0,32(sp)
    80005172:	64e2                	ld	s1,24(sp)
    80005174:	6942                	ld	s2,16(sp)
    80005176:	69a2                	ld	s3,8(sp)
    80005178:	6a02                	ld	s4,0(sp)
    8000517a:	6145                	addi	sp,sp,48
    8000517c:	8082                	ret
  return -1;
    8000517e:	557d                	li	a0,-1
    80005180:	b7fd                	j	8000516e <pipealloc+0xc4>

0000000080005182 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005182:	1101                	addi	sp,sp,-32
    80005184:	ec06                	sd	ra,24(sp)
    80005186:	e822                	sd	s0,16(sp)
    80005188:	e426                	sd	s1,8(sp)
    8000518a:	e04a                	sd	s2,0(sp)
    8000518c:	1000                	addi	s0,sp,32
    8000518e:	84aa                	mv	s1,a0
    80005190:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005192:	ffffc097          	auipc	ra,0xffffc
    80005196:	af6080e7          	jalr	-1290(ra) # 80000c88 <acquire>
  if(writable){
    8000519a:	02090d63          	beqz	s2,800051d4 <pipeclose+0x52>
    pi->writeopen = 0;
    8000519e:	2204ae23          	sw	zero,572(s1)
    wakeup(&pi->nread);
    800051a2:	23048513          	addi	a0,s1,560
    800051a6:	ffffe097          	auipc	ra,0xffffe
    800051aa:	802080e7          	jalr	-2046(ra) # 800029a8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800051ae:	2384b783          	ld	a5,568(s1)
    800051b2:	eb95                	bnez	a5,800051e6 <pipeclose+0x64>
    release(&pi->lock);
    800051b4:	8526                	mv	a0,s1
    800051b6:	ffffc097          	auipc	ra,0xffffc
    800051ba:	d1e080e7          	jalr	-738(ra) # 80000ed4 <release>
    kfree((char*)pi);
    800051be:	8526                	mv	a0,s1
    800051c0:	ffffc097          	auipc	ra,0xffffc
    800051c4:	92c080e7          	jalr	-1748(ra) # 80000aec <kfree>
  } else
    release(&pi->lock);
}
    800051c8:	60e2                	ld	ra,24(sp)
    800051ca:	6442                	ld	s0,16(sp)
    800051cc:	64a2                	ld	s1,8(sp)
    800051ce:	6902                	ld	s2,0(sp)
    800051d0:	6105                	addi	sp,sp,32
    800051d2:	8082                	ret
    pi->readopen = 0;
    800051d4:	2204ac23          	sw	zero,568(s1)
    wakeup(&pi->nwrite);
    800051d8:	23448513          	addi	a0,s1,564
    800051dc:	ffffd097          	auipc	ra,0xffffd
    800051e0:	7cc080e7          	jalr	1996(ra) # 800029a8 <wakeup>
    800051e4:	b7e9                	j	800051ae <pipeclose+0x2c>
    release(&pi->lock);
    800051e6:	8526                	mv	a0,s1
    800051e8:	ffffc097          	auipc	ra,0xffffc
    800051ec:	cec080e7          	jalr	-788(ra) # 80000ed4 <release>
}
    800051f0:	bfe1                	j	800051c8 <pipeclose+0x46>

00000000800051f2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800051f2:	7159                	addi	sp,sp,-112
    800051f4:	f486                	sd	ra,104(sp)
    800051f6:	f0a2                	sd	s0,96(sp)
    800051f8:	eca6                	sd	s1,88(sp)
    800051fa:	e8ca                	sd	s2,80(sp)
    800051fc:	e4ce                	sd	s3,72(sp)
    800051fe:	e0d2                	sd	s4,64(sp)
    80005200:	fc56                	sd	s5,56(sp)
    80005202:	f85a                	sd	s6,48(sp)
    80005204:	f45e                	sd	s7,40(sp)
    80005206:	f062                	sd	s8,32(sp)
    80005208:	ec66                	sd	s9,24(sp)
    8000520a:	1880                	addi	s0,sp,112
    8000520c:	84aa                	mv	s1,a0
    8000520e:	8b2e                	mv	s6,a1
    80005210:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80005212:	ffffd097          	auipc	ra,0xffffd
    80005216:	d8a080e7          	jalr	-630(ra) # 80001f9c <myproc>
    8000521a:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    8000521c:	8526                	mv	a0,s1
    8000521e:	ffffc097          	auipc	ra,0xffffc
    80005222:	a6a080e7          	jalr	-1430(ra) # 80000c88 <acquire>
  for(i = 0; i < n; i++){
    80005226:	0b505063          	blez	s5,800052c6 <pipewrite+0xd4>
    8000522a:	8926                	mv	s2,s1
    8000522c:	fffa8b9b          	addiw	s7,s5,-1
    80005230:	1b82                	slli	s7,s7,0x20
    80005232:	020bdb93          	srli	s7,s7,0x20
    80005236:	001b0793          	addi	a5,s6,1
    8000523a:	9bbe                	add	s7,s7,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    8000523c:	23048a13          	addi	s4,s1,560
      sleep(&pi->nwrite, &pi->lock);
    80005240:	23448993          	addi	s3,s1,564
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005244:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80005246:	2304a783          	lw	a5,560(s1)
    8000524a:	2344a703          	lw	a4,564(s1)
    8000524e:	2007879b          	addiw	a5,a5,512
    80005252:	02f71e63          	bne	a4,a5,8000528e <pipewrite+0x9c>
      if(pi->readopen == 0 || myproc()->killed){
    80005256:	2384a783          	lw	a5,568(s1)
    8000525a:	c3d9                	beqz	a5,800052e0 <pipewrite+0xee>
    8000525c:	ffffd097          	auipc	ra,0xffffd
    80005260:	d40080e7          	jalr	-704(ra) # 80001f9c <myproc>
    80005264:	453c                	lw	a5,72(a0)
    80005266:	efad                	bnez	a5,800052e0 <pipewrite+0xee>
      wakeup(&pi->nread);
    80005268:	8552                	mv	a0,s4
    8000526a:	ffffd097          	auipc	ra,0xffffd
    8000526e:	73e080e7          	jalr	1854(ra) # 800029a8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005272:	85ca                	mv	a1,s2
    80005274:	854e                	mv	a0,s3
    80005276:	ffffd097          	auipc	ra,0xffffd
    8000527a:	5ac080e7          	jalr	1452(ra) # 80002822 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    8000527e:	2304a783          	lw	a5,560(s1)
    80005282:	2344a703          	lw	a4,564(s1)
    80005286:	2007879b          	addiw	a5,a5,512
    8000528a:	fcf706e3          	beq	a4,a5,80005256 <pipewrite+0x64>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000528e:	4685                	li	a3,1
    80005290:	865a                	mv	a2,s6
    80005292:	f9f40593          	addi	a1,s0,-97
    80005296:	068c3503          	ld	a0,104(s8)
    8000529a:	ffffd097          	auipc	ra,0xffffd
    8000529e:	990080e7          	jalr	-1648(ra) # 80001c2a <copyin>
    800052a2:	03950263          	beq	a0,s9,800052c6 <pipewrite+0xd4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800052a6:	2344a783          	lw	a5,564(s1)
    800052aa:	0017871b          	addiw	a4,a5,1
    800052ae:	22e4aa23          	sw	a4,564(s1)
    800052b2:	1ff7f793          	andi	a5,a5,511
    800052b6:	97a6                	add	a5,a5,s1
    800052b8:	f9f44703          	lbu	a4,-97(s0)
    800052bc:	02e78823          	sb	a4,48(a5)
  for(i = 0; i < n; i++){
    800052c0:	0b05                	addi	s6,s6,1
    800052c2:	f97b12e3          	bne	s6,s7,80005246 <pipewrite+0x54>
  }
  wakeup(&pi->nread);
    800052c6:	23048513          	addi	a0,s1,560
    800052ca:	ffffd097          	auipc	ra,0xffffd
    800052ce:	6de080e7          	jalr	1758(ra) # 800029a8 <wakeup>
  release(&pi->lock);
    800052d2:	8526                	mv	a0,s1
    800052d4:	ffffc097          	auipc	ra,0xffffc
    800052d8:	c00080e7          	jalr	-1024(ra) # 80000ed4 <release>
  return n;
    800052dc:	8556                	mv	a0,s5
    800052de:	a039                	j	800052ec <pipewrite+0xfa>
        release(&pi->lock);
    800052e0:	8526                	mv	a0,s1
    800052e2:	ffffc097          	auipc	ra,0xffffc
    800052e6:	bf2080e7          	jalr	-1038(ra) # 80000ed4 <release>
        return -1;
    800052ea:	557d                	li	a0,-1
}
    800052ec:	70a6                	ld	ra,104(sp)
    800052ee:	7406                	ld	s0,96(sp)
    800052f0:	64e6                	ld	s1,88(sp)
    800052f2:	6946                	ld	s2,80(sp)
    800052f4:	69a6                	ld	s3,72(sp)
    800052f6:	6a06                	ld	s4,64(sp)
    800052f8:	7ae2                	ld	s5,56(sp)
    800052fa:	7b42                	ld	s6,48(sp)
    800052fc:	7ba2                	ld	s7,40(sp)
    800052fe:	7c02                	ld	s8,32(sp)
    80005300:	6ce2                	ld	s9,24(sp)
    80005302:	6165                	addi	sp,sp,112
    80005304:	8082                	ret

0000000080005306 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005306:	715d                	addi	sp,sp,-80
    80005308:	e486                	sd	ra,72(sp)
    8000530a:	e0a2                	sd	s0,64(sp)
    8000530c:	fc26                	sd	s1,56(sp)
    8000530e:	f84a                	sd	s2,48(sp)
    80005310:	f44e                	sd	s3,40(sp)
    80005312:	f052                	sd	s4,32(sp)
    80005314:	ec56                	sd	s5,24(sp)
    80005316:	e85a                	sd	s6,16(sp)
    80005318:	0880                	addi	s0,sp,80
    8000531a:	84aa                	mv	s1,a0
    8000531c:	892e                	mv	s2,a1
    8000531e:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80005320:	ffffd097          	auipc	ra,0xffffd
    80005324:	c7c080e7          	jalr	-900(ra) # 80001f9c <myproc>
    80005328:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    8000532a:	8b26                	mv	s6,s1
    8000532c:	8526                	mv	a0,s1
    8000532e:	ffffc097          	auipc	ra,0xffffc
    80005332:	95a080e7          	jalr	-1702(ra) # 80000c88 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005336:	2304a703          	lw	a4,560(s1)
    8000533a:	2344a783          	lw	a5,564(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000533e:	23048993          	addi	s3,s1,560
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005342:	02f71763          	bne	a4,a5,80005370 <piperead+0x6a>
    80005346:	23c4a783          	lw	a5,572(s1)
    8000534a:	c39d                	beqz	a5,80005370 <piperead+0x6a>
    if(myproc()->killed){
    8000534c:	ffffd097          	auipc	ra,0xffffd
    80005350:	c50080e7          	jalr	-944(ra) # 80001f9c <myproc>
    80005354:	453c                	lw	a5,72(a0)
    80005356:	ebc1                	bnez	a5,800053e6 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005358:	85da                	mv	a1,s6
    8000535a:	854e                	mv	a0,s3
    8000535c:	ffffd097          	auipc	ra,0xffffd
    80005360:	4c6080e7          	jalr	1222(ra) # 80002822 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005364:	2304a703          	lw	a4,560(s1)
    80005368:	2344a783          	lw	a5,564(s1)
    8000536c:	fcf70de3          	beq	a4,a5,80005346 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005370:	09405263          	blez	s4,800053f4 <piperead+0xee>
    80005374:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005376:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005378:	2304a783          	lw	a5,560(s1)
    8000537c:	2344a703          	lw	a4,564(s1)
    80005380:	02f70d63          	beq	a4,a5,800053ba <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005384:	0017871b          	addiw	a4,a5,1
    80005388:	22e4a823          	sw	a4,560(s1)
    8000538c:	1ff7f793          	andi	a5,a5,511
    80005390:	97a6                	add	a5,a5,s1
    80005392:	0307c783          	lbu	a5,48(a5)
    80005396:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000539a:	4685                	li	a3,1
    8000539c:	fbf40613          	addi	a2,s0,-65
    800053a0:	85ca                	mv	a1,s2
    800053a2:	068ab503          	ld	a0,104(s5)
    800053a6:	ffffc097          	auipc	ra,0xffffc
    800053aa:	7f8080e7          	jalr	2040(ra) # 80001b9e <copyout>
    800053ae:	01650663          	beq	a0,s6,800053ba <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053b2:	2985                	addiw	s3,s3,1
    800053b4:	0905                	addi	s2,s2,1
    800053b6:	fd3a11e3          	bne	s4,s3,80005378 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800053ba:	23448513          	addi	a0,s1,564
    800053be:	ffffd097          	auipc	ra,0xffffd
    800053c2:	5ea080e7          	jalr	1514(ra) # 800029a8 <wakeup>
  release(&pi->lock);
    800053c6:	8526                	mv	a0,s1
    800053c8:	ffffc097          	auipc	ra,0xffffc
    800053cc:	b0c080e7          	jalr	-1268(ra) # 80000ed4 <release>
  return i;
}
    800053d0:	854e                	mv	a0,s3
    800053d2:	60a6                	ld	ra,72(sp)
    800053d4:	6406                	ld	s0,64(sp)
    800053d6:	74e2                	ld	s1,56(sp)
    800053d8:	7942                	ld	s2,48(sp)
    800053da:	79a2                	ld	s3,40(sp)
    800053dc:	7a02                	ld	s4,32(sp)
    800053de:	6ae2                	ld	s5,24(sp)
    800053e0:	6b42                	ld	s6,16(sp)
    800053e2:	6161                	addi	sp,sp,80
    800053e4:	8082                	ret
      release(&pi->lock);
    800053e6:	8526                	mv	a0,s1
    800053e8:	ffffc097          	auipc	ra,0xffffc
    800053ec:	aec080e7          	jalr	-1300(ra) # 80000ed4 <release>
      return -1;
    800053f0:	59fd                	li	s3,-1
    800053f2:	bff9                	j	800053d0 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053f4:	4981                	li	s3,0
    800053f6:	b7d1                	j	800053ba <piperead+0xb4>

00000000800053f8 <exec>:



int
exec(char *path, char **argv)
{
    800053f8:	df010113          	addi	sp,sp,-528
    800053fc:	20113423          	sd	ra,520(sp)
    80005400:	20813023          	sd	s0,512(sp)
    80005404:	ffa6                	sd	s1,504(sp)
    80005406:	fbca                	sd	s2,496(sp)
    80005408:	f7ce                	sd	s3,488(sp)
    8000540a:	f3d2                	sd	s4,480(sp)
    8000540c:	efd6                	sd	s5,472(sp)
    8000540e:	ebda                	sd	s6,464(sp)
    80005410:	e7de                	sd	s7,456(sp)
    80005412:	e3e2                	sd	s8,448(sp)
    80005414:	ff66                	sd	s9,440(sp)
    80005416:	fb6a                	sd	s10,432(sp)
    80005418:	f76e                	sd	s11,424(sp)
    8000541a:	0c00                	addi	s0,sp,528
    8000541c:	84aa                	mv	s1,a0
    8000541e:	dea43c23          	sd	a0,-520(s0)
    80005422:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005426:	ffffd097          	auipc	ra,0xffffd
    8000542a:	b76080e7          	jalr	-1162(ra) # 80001f9c <myproc>
    8000542e:	892a                	mv	s2,a0

  begin_op(ROOTDEV);
    80005430:	4501                	li	a0,0
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	38a080e7          	jalr	906(ra) # 800047bc <begin_op>

  if((ip = namei(path)) == 0){
    8000543a:	8526                	mv	a0,s1
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	13a080e7          	jalr	314(ra) # 80004576 <namei>
    80005444:	c935                	beqz	a0,800054b8 <exec+0xc0>
    80005446:	84aa                	mv	s1,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005448:	fffff097          	auipc	ra,0xfffff
    8000544c:	9a4080e7          	jalr	-1628(ra) # 80003dec <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005450:	04000713          	li	a4,64
    80005454:	4681                	li	a3,0
    80005456:	e4840613          	addi	a2,s0,-440
    8000545a:	4581                	li	a1,0
    8000545c:	8526                	mv	a0,s1
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	c1e080e7          	jalr	-994(ra) # 8000407c <readi>
    80005466:	04000793          	li	a5,64
    8000546a:	00f51a63          	bne	a0,a5,8000547e <exec+0x86>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000546e:	e4842703          	lw	a4,-440(s0)
    80005472:	464c47b7          	lui	a5,0x464c4
    80005476:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000547a:	04f70663          	beq	a4,a5,800054c6 <exec+0xce>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000547e:	8526                	mv	a0,s1
    80005480:	fffff097          	auipc	ra,0xfffff
    80005484:	baa080e7          	jalr	-1110(ra) # 8000402a <iunlockput>
    end_op(ROOTDEV);
    80005488:	4501                	li	a0,0
    8000548a:	fffff097          	auipc	ra,0xfffff
    8000548e:	3de080e7          	jalr	990(ra) # 80004868 <end_op>
  }
  return -1;
    80005492:	557d                	li	a0,-1
}
    80005494:	20813083          	ld	ra,520(sp)
    80005498:	20013403          	ld	s0,512(sp)
    8000549c:	74fe                	ld	s1,504(sp)
    8000549e:	795e                	ld	s2,496(sp)
    800054a0:	79be                	ld	s3,488(sp)
    800054a2:	7a1e                	ld	s4,480(sp)
    800054a4:	6afe                	ld	s5,472(sp)
    800054a6:	6b5e                	ld	s6,464(sp)
    800054a8:	6bbe                	ld	s7,456(sp)
    800054aa:	6c1e                	ld	s8,448(sp)
    800054ac:	7cfa                	ld	s9,440(sp)
    800054ae:	7d5a                	ld	s10,432(sp)
    800054b0:	7dba                	ld	s11,424(sp)
    800054b2:	21010113          	addi	sp,sp,528
    800054b6:	8082                	ret
    end_op(ROOTDEV);
    800054b8:	4501                	li	a0,0
    800054ba:	fffff097          	auipc	ra,0xfffff
    800054be:	3ae080e7          	jalr	942(ra) # 80004868 <end_op>
    return -1;
    800054c2:	557d                	li	a0,-1
    800054c4:	bfc1                	j	80005494 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800054c6:	854a                	mv	a0,s2
    800054c8:	ffffd097          	auipc	ra,0xffffd
    800054cc:	b98080e7          	jalr	-1128(ra) # 80002060 <proc_pagetable>
    800054d0:	8c2a                	mv	s8,a0
    800054d2:	d555                	beqz	a0,8000547e <exec+0x86>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054d4:	e6842983          	lw	s3,-408(s0)
    800054d8:	e8045783          	lhu	a5,-384(s0)
    800054dc:	c7fd                	beqz	a5,800055ca <exec+0x1d2>
  sz = 0;
    800054de:	e0043423          	sd	zero,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054e2:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    800054e4:	6b05                	lui	s6,0x1
    800054e6:	fffb0793          	addi	a5,s6,-1 # fff <_entry-0x7ffff001>
    800054ea:	def43823          	sd	a5,-528(s0)
    800054ee:	a0a5                	j	80005556 <exec+0x15e>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800054f0:	00003517          	auipc	a0,0x3
    800054f4:	73850513          	addi	a0,a0,1848 # 80008c28 <userret+0xb98>
    800054f8:	ffffb097          	auipc	ra,0xffffb
    800054fc:	25e080e7          	jalr	606(ra) # 80000756 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005500:	8756                	mv	a4,s5
    80005502:	012d86bb          	addw	a3,s11,s2
    80005506:	4581                	li	a1,0
    80005508:	8526                	mv	a0,s1
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	b72080e7          	jalr	-1166(ra) # 8000407c <readi>
    80005512:	2501                	sext.w	a0,a0
    80005514:	10aa9263          	bne	s5,a0,80005618 <exec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    80005518:	6785                	lui	a5,0x1
    8000551a:	0127893b          	addw	s2,a5,s2
    8000551e:	77fd                	lui	a5,0xfffff
    80005520:	01478a3b          	addw	s4,a5,s4
    80005524:	03997263          	bgeu	s2,s9,80005548 <exec+0x150>
    pa = walkaddr(pagetable, va + i);
    80005528:	02091593          	slli	a1,s2,0x20
    8000552c:	9181                	srli	a1,a1,0x20
    8000552e:	95ea                	add	a1,a1,s10
    80005530:	8562                	mv	a0,s8
    80005532:	ffffc097          	auipc	ra,0xffffc
    80005536:	08a080e7          	jalr	138(ra) # 800015bc <walkaddr>
    8000553a:	862a                	mv	a2,a0
    if(pa == 0)
    8000553c:	d955                	beqz	a0,800054f0 <exec+0xf8>
      n = PGSIZE;
    8000553e:	8ada                	mv	s5,s6
    if(sz - i < PGSIZE)
    80005540:	fd6a70e3          	bgeu	s4,s6,80005500 <exec+0x108>
      n = sz - i;
    80005544:	8ad2                	mv	s5,s4
    80005546:	bf6d                	j	80005500 <exec+0x108>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005548:	2b85                	addiw	s7,s7,1
    8000554a:	0389899b          	addiw	s3,s3,56
    8000554e:	e8045783          	lhu	a5,-384(s0)
    80005552:	06fbde63          	bge	s7,a5,800055ce <exec+0x1d6>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005556:	2981                	sext.w	s3,s3
    80005558:	03800713          	li	a4,56
    8000555c:	86ce                	mv	a3,s3
    8000555e:	e1040613          	addi	a2,s0,-496
    80005562:	4581                	li	a1,0
    80005564:	8526                	mv	a0,s1
    80005566:	fffff097          	auipc	ra,0xfffff
    8000556a:	b16080e7          	jalr	-1258(ra) # 8000407c <readi>
    8000556e:	03800793          	li	a5,56
    80005572:	0af51363          	bne	a0,a5,80005618 <exec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    80005576:	e1042783          	lw	a5,-496(s0)
    8000557a:	4705                	li	a4,1
    8000557c:	fce796e3          	bne	a5,a4,80005548 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80005580:	e3843603          	ld	a2,-456(s0)
    80005584:	e3043783          	ld	a5,-464(s0)
    80005588:	08f66863          	bltu	a2,a5,80005618 <exec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000558c:	e2043783          	ld	a5,-480(s0)
    80005590:	963e                	add	a2,a2,a5
    80005592:	08f66363          	bltu	a2,a5,80005618 <exec+0x220>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005596:	e0843583          	ld	a1,-504(s0)
    8000559a:	8562                	mv	a0,s8
    8000559c:	ffffc097          	auipc	ra,0xffffc
    800055a0:	428080e7          	jalr	1064(ra) # 800019c4 <uvmalloc>
    800055a4:	e0a43423          	sd	a0,-504(s0)
    800055a8:	c925                	beqz	a0,80005618 <exec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    800055aa:	e2043d03          	ld	s10,-480(s0)
    800055ae:	df043783          	ld	a5,-528(s0)
    800055b2:	00fd77b3          	and	a5,s10,a5
    800055b6:	e3ad                	bnez	a5,80005618 <exec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800055b8:	e1842d83          	lw	s11,-488(s0)
    800055bc:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055c0:	f80c84e3          	beqz	s9,80005548 <exec+0x150>
    800055c4:	8a66                	mv	s4,s9
    800055c6:	4901                	li	s2,0
    800055c8:	b785                	j	80005528 <exec+0x130>
  sz = 0;
    800055ca:	e0043423          	sd	zero,-504(s0)
  iunlockput(ip);
    800055ce:	8526                	mv	a0,s1
    800055d0:	fffff097          	auipc	ra,0xfffff
    800055d4:	a5a080e7          	jalr	-1446(ra) # 8000402a <iunlockput>
  end_op(ROOTDEV);
    800055d8:	4501                	li	a0,0
    800055da:	fffff097          	auipc	ra,0xfffff
    800055de:	28e080e7          	jalr	654(ra) # 80004868 <end_op>
  p = myproc();
    800055e2:	ffffd097          	auipc	ra,0xffffd
    800055e6:	9ba080e7          	jalr	-1606(ra) # 80001f9c <myproc>
    800055ea:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    800055ec:	06053d83          	ld	s11,96(a0)
  sz = PGROUNDUP(sz);
    800055f0:	6585                	lui	a1,0x1
    800055f2:	15fd                	addi	a1,a1,-1
    800055f4:	e0843783          	ld	a5,-504(s0)
    800055f8:	00b78b33          	add	s6,a5,a1
    800055fc:	75fd                	lui	a1,0xfffff
    800055fe:	00bb75b3          	and	a1,s6,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005602:	6609                	lui	a2,0x2
    80005604:	962e                	add	a2,a2,a1
    80005606:	8562                	mv	a0,s8
    80005608:	ffffc097          	auipc	ra,0xffffc
    8000560c:	3bc080e7          	jalr	956(ra) # 800019c4 <uvmalloc>
    80005610:	e0a43423          	sd	a0,-504(s0)
  ip = 0;
    80005614:	4481                	li	s1,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005616:	ed01                	bnez	a0,8000562e <exec+0x236>
    proc_freepagetable(pagetable, sz);
    80005618:	e0843583          	ld	a1,-504(s0)
    8000561c:	8562                	mv	a0,s8
    8000561e:	ffffd097          	auipc	ra,0xffffd
    80005622:	b46080e7          	jalr	-1210(ra) # 80002164 <proc_freepagetable>
  if(ip){
    80005626:	e4049ce3          	bnez	s1,8000547e <exec+0x86>
  return -1;
    8000562a:	557d                	li	a0,-1
    8000562c:	b5a5                	j	80005494 <exec+0x9c>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000562e:	75f9                	lui	a1,0xffffe
    80005630:	84aa                	mv	s1,a0
    80005632:	95aa                	add	a1,a1,a0
    80005634:	8562                	mv	a0,s8
    80005636:	ffffc097          	auipc	ra,0xffffc
    8000563a:	536080e7          	jalr	1334(ra) # 80001b6c <uvmclear>
  stackbase = sp - PGSIZE;
    8000563e:	7bfd                	lui	s7,0xfffff
    80005640:	9ba6                	add	s7,s7,s1
  for(argc = 0; argv[argc]; argc++) {
    80005642:	e0043983          	ld	s3,-512(s0)
    80005646:	0009b503          	ld	a0,0(s3)
    8000564a:	cd29                	beqz	a0,800056a4 <exec+0x2ac>
    8000564c:	e8840a13          	addi	s4,s0,-376
    80005650:	f8840c93          	addi	s9,s0,-120
    80005654:	4901                	li	s2,0
    sp -= strlen(argv[argc]) + 1;
    80005656:	ffffc097          	auipc	ra,0xffffc
    8000565a:	c06080e7          	jalr	-1018(ra) # 8000125c <strlen>
    8000565e:	2505                	addiw	a0,a0,1
    80005660:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005662:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    80005664:	1174e463          	bltu	s1,s7,8000576c <exec+0x374>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005668:	0009ba83          	ld	s5,0(s3)
    8000566c:	8556                	mv	a0,s5
    8000566e:	ffffc097          	auipc	ra,0xffffc
    80005672:	bee080e7          	jalr	-1042(ra) # 8000125c <strlen>
    80005676:	0015069b          	addiw	a3,a0,1
    8000567a:	8656                	mv	a2,s5
    8000567c:	85a6                	mv	a1,s1
    8000567e:	8562                	mv	a0,s8
    80005680:	ffffc097          	auipc	ra,0xffffc
    80005684:	51e080e7          	jalr	1310(ra) # 80001b9e <copyout>
    80005688:	0e054463          	bltz	a0,80005770 <exec+0x378>
    ustack[argc] = sp;
    8000568c:	009a3023          	sd	s1,0(s4)
  for(argc = 0; argv[argc]; argc++) {
    80005690:	0905                	addi	s2,s2,1
    80005692:	09a1                	addi	s3,s3,8
    80005694:	0009b503          	ld	a0,0(s3)
    80005698:	c909                	beqz	a0,800056aa <exec+0x2b2>
    if(argc >= MAXARG)
    8000569a:	0a21                	addi	s4,s4,8
    8000569c:	fb4c9de3          	bne	s9,s4,80005656 <exec+0x25e>
  ip = 0;
    800056a0:	4481                	li	s1,0
    800056a2:	bf9d                	j	80005618 <exec+0x220>
  sp = sz;
    800056a4:	e0843483          	ld	s1,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800056a8:	4901                	li	s2,0
  ustack[argc] = 0;
    800056aa:	00391793          	slli	a5,s2,0x3
    800056ae:	f9040713          	addi	a4,s0,-112
    800056b2:	97ba                	add	a5,a5,a4
    800056b4:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd0e4c>
  sp -= (argc+1) * sizeof(uint64);
    800056b8:	00190693          	addi	a3,s2,1
    800056bc:	068e                	slli	a3,a3,0x3
    800056be:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    800056c0:	ff04f993          	andi	s3,s1,-16
  ip = 0;
    800056c4:	4481                	li	s1,0
  if(sp < stackbase)
    800056c6:	f579e9e3          	bltu	s3,s7,80005618 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800056ca:	e8840613          	addi	a2,s0,-376
    800056ce:	85ce                	mv	a1,s3
    800056d0:	8562                	mv	a0,s8
    800056d2:	ffffc097          	auipc	ra,0xffffc
    800056d6:	4cc080e7          	jalr	1228(ra) # 80001b9e <copyout>
    800056da:	08054d63          	bltz	a0,80005774 <exec+0x37c>
  p->tf->a1 = sp;
    800056de:	070d3783          	ld	a5,112(s10)
    800056e2:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    800056e6:	df843783          	ld	a5,-520(s0)
    800056ea:	0007c703          	lbu	a4,0(a5)
    800056ee:	cf11                	beqz	a4,8000570a <exec+0x312>
    800056f0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800056f2:	02f00693          	li	a3,47
    800056f6:	a029                	j	80005700 <exec+0x308>
  for(last=s=path; *s; s++)
    800056f8:	0785                	addi	a5,a5,1
    800056fa:	fff7c703          	lbu	a4,-1(a5)
    800056fe:	c711                	beqz	a4,8000570a <exec+0x312>
    if(*s == '/')
    80005700:	fed71ce3          	bne	a4,a3,800056f8 <exec+0x300>
      last = s+1;
    80005704:	def43c23          	sd	a5,-520(s0)
    80005708:	bfc5                	j	800056f8 <exec+0x300>
  safestrcpy(p->name, last, sizeof(p->name));
    8000570a:	4641                	li	a2,16
    8000570c:	df843583          	ld	a1,-520(s0)
    80005710:	170d0513          	addi	a0,s10,368
    80005714:	ffffc097          	auipc	ra,0xffffc
    80005718:	b16080e7          	jalr	-1258(ra) # 8000122a <safestrcpy>
  if(p->cmd) bd_free(p->cmd);
    8000571c:	180d3503          	ld	a0,384(s10)
    80005720:	c509                	beqz	a0,8000572a <exec+0x332>
    80005722:	00002097          	auipc	ra,0x2
    80005726:	96a080e7          	jalr	-1686(ra) # 8000708c <bd_free>
  p->cmd = strjoin(argv);
    8000572a:	e0043503          	ld	a0,-512(s0)
    8000572e:	ffffc097          	auipc	ra,0xffffc
    80005732:	b58080e7          	jalr	-1192(ra) # 80001286 <strjoin>
    80005736:	18ad3023          	sd	a0,384(s10)
  oldpagetable = p->pagetable;
    8000573a:	068d3503          	ld	a0,104(s10)
  p->pagetable = pagetable;
    8000573e:	078d3423          	sd	s8,104(s10)
  p->sz = sz;
    80005742:	e0843783          	ld	a5,-504(s0)
    80005746:	06fd3023          	sd	a5,96(s10)
  p->tf->epc = elf.entry;  // initial program counter = main
    8000574a:	070d3783          	ld	a5,112(s10)
    8000574e:	e6043703          	ld	a4,-416(s0)
    80005752:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    80005754:	070d3783          	ld	a5,112(s10)
    80005758:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000575c:	85ee                	mv	a1,s11
    8000575e:	ffffd097          	auipc	ra,0xffffd
    80005762:	a06080e7          	jalr	-1530(ra) # 80002164 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005766:	0009051b          	sext.w	a0,s2
    8000576a:	b32d                	j	80005494 <exec+0x9c>
  ip = 0;
    8000576c:	4481                	li	s1,0
    8000576e:	b56d                	j	80005618 <exec+0x220>
    80005770:	4481                	li	s1,0
    80005772:	b55d                	j	80005618 <exec+0x220>
    80005774:	4481                	li	s1,0
    80005776:	b54d                	j	80005618 <exec+0x220>

0000000080005778 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005778:	7179                	addi	sp,sp,-48
    8000577a:	f406                	sd	ra,40(sp)
    8000577c:	f022                	sd	s0,32(sp)
    8000577e:	ec26                	sd	s1,24(sp)
    80005780:	e84a                	sd	s2,16(sp)
    80005782:	1800                	addi	s0,sp,48
    80005784:	892e                	mv	s2,a1
    80005786:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005788:	fdc40593          	addi	a1,s0,-36
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	adc080e7          	jalr	-1316(ra) # 80003268 <argint>
    80005794:	04054063          	bltz	a0,800057d4 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005798:	fdc42703          	lw	a4,-36(s0)
    8000579c:	47bd                	li	a5,15
    8000579e:	02e7ed63          	bltu	a5,a4,800057d8 <argfd+0x60>
    800057a2:	ffffc097          	auipc	ra,0xffffc
    800057a6:	7fa080e7          	jalr	2042(ra) # 80001f9c <myproc>
    800057aa:	fdc42703          	lw	a4,-36(s0)
    800057ae:	01c70793          	addi	a5,a4,28
    800057b2:	078e                	slli	a5,a5,0x3
    800057b4:	953e                	add	a0,a0,a5
    800057b6:	651c                	ld	a5,8(a0)
    800057b8:	c395                	beqz	a5,800057dc <argfd+0x64>
    return -1;
  if(pfd)
    800057ba:	00090463          	beqz	s2,800057c2 <argfd+0x4a>
    *pfd = fd;
    800057be:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800057c2:	4501                	li	a0,0
  if(pf)
    800057c4:	c091                	beqz	s1,800057c8 <argfd+0x50>
    *pf = f;
    800057c6:	e09c                	sd	a5,0(s1)
}
    800057c8:	70a2                	ld	ra,40(sp)
    800057ca:	7402                	ld	s0,32(sp)
    800057cc:	64e2                	ld	s1,24(sp)
    800057ce:	6942                	ld	s2,16(sp)
    800057d0:	6145                	addi	sp,sp,48
    800057d2:	8082                	ret
    return -1;
    800057d4:	557d                	li	a0,-1
    800057d6:	bfcd                	j	800057c8 <argfd+0x50>
    return -1;
    800057d8:	557d                	li	a0,-1
    800057da:	b7fd                	j	800057c8 <argfd+0x50>
    800057dc:	557d                	li	a0,-1
    800057de:	b7ed                	j	800057c8 <argfd+0x50>

00000000800057e0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800057e0:	1101                	addi	sp,sp,-32
    800057e2:	ec06                	sd	ra,24(sp)
    800057e4:	e822                	sd	s0,16(sp)
    800057e6:	e426                	sd	s1,8(sp)
    800057e8:	1000                	addi	s0,sp,32
    800057ea:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800057ec:	ffffc097          	auipc	ra,0xffffc
    800057f0:	7b0080e7          	jalr	1968(ra) # 80001f9c <myproc>
    800057f4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800057f6:	0e850793          	addi	a5,a0,232
    800057fa:	4501                	li	a0,0
    800057fc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800057fe:	6398                	ld	a4,0(a5)
    80005800:	cb19                	beqz	a4,80005816 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005802:	2505                	addiw	a0,a0,1
    80005804:	07a1                	addi	a5,a5,8
    80005806:	fed51ce3          	bne	a0,a3,800057fe <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000580a:	557d                	li	a0,-1
}
    8000580c:	60e2                	ld	ra,24(sp)
    8000580e:	6442                	ld	s0,16(sp)
    80005810:	64a2                	ld	s1,8(sp)
    80005812:	6105                	addi	sp,sp,32
    80005814:	8082                	ret
      p->ofile[fd] = f;
    80005816:	01c50793          	addi	a5,a0,28
    8000581a:	078e                	slli	a5,a5,0x3
    8000581c:	963e                	add	a2,a2,a5
    8000581e:	e604                	sd	s1,8(a2)
      return fd;
    80005820:	b7f5                	j	8000580c <fdalloc+0x2c>

0000000080005822 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005822:	715d                	addi	sp,sp,-80
    80005824:	e486                	sd	ra,72(sp)
    80005826:	e0a2                	sd	s0,64(sp)
    80005828:	fc26                	sd	s1,56(sp)
    8000582a:	f84a                	sd	s2,48(sp)
    8000582c:	f44e                	sd	s3,40(sp)
    8000582e:	f052                	sd	s4,32(sp)
    80005830:	ec56                	sd	s5,24(sp)
    80005832:	0880                	addi	s0,sp,80
    80005834:	89ae                	mv	s3,a1
    80005836:	8ab2                	mv	s5,a2
    80005838:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000583a:	fb040593          	addi	a1,s0,-80
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	d56080e7          	jalr	-682(ra) # 80004594 <nameiparent>
    80005846:	892a                	mv	s2,a0
    80005848:	12050f63          	beqz	a0,80005986 <create+0x164>
    return 0;

  ilock(dp);
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	5a0080e7          	jalr	1440(ra) # 80003dec <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005854:	4601                	li	a2,0
    80005856:	fb040593          	addi	a1,s0,-80
    8000585a:	854a                	mv	a0,s2
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	a48080e7          	jalr	-1464(ra) # 800042a4 <dirlookup>
    80005864:	84aa                	mv	s1,a0
    80005866:	c921                	beqz	a0,800058b6 <create+0x94>
    iunlockput(dp);
    80005868:	854a                	mv	a0,s2
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	7c0080e7          	jalr	1984(ra) # 8000402a <iunlockput>
    ilock(ip);
    80005872:	8526                	mv	a0,s1
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	578080e7          	jalr	1400(ra) # 80003dec <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000587c:	2981                	sext.w	s3,s3
    8000587e:	4789                	li	a5,2
    80005880:	02f99463          	bne	s3,a5,800058a8 <create+0x86>
    80005884:	05c4d783          	lhu	a5,92(s1)
    80005888:	37f9                	addiw	a5,a5,-2
    8000588a:	17c2                	slli	a5,a5,0x30
    8000588c:	93c1                	srli	a5,a5,0x30
    8000588e:	4705                	li	a4,1
    80005890:	00f76c63          	bltu	a4,a5,800058a8 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005894:	8526                	mv	a0,s1
    80005896:	60a6                	ld	ra,72(sp)
    80005898:	6406                	ld	s0,64(sp)
    8000589a:	74e2                	ld	s1,56(sp)
    8000589c:	7942                	ld	s2,48(sp)
    8000589e:	79a2                	ld	s3,40(sp)
    800058a0:	7a02                	ld	s4,32(sp)
    800058a2:	6ae2                	ld	s5,24(sp)
    800058a4:	6161                	addi	sp,sp,80
    800058a6:	8082                	ret
    iunlockput(ip);
    800058a8:	8526                	mv	a0,s1
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	780080e7          	jalr	1920(ra) # 8000402a <iunlockput>
    return 0;
    800058b2:	4481                	li	s1,0
    800058b4:	b7c5                	j	80005894 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800058b6:	85ce                	mv	a1,s3
    800058b8:	00092503          	lw	a0,0(s2)
    800058bc:	ffffe097          	auipc	ra,0xffffe
    800058c0:	398080e7          	jalr	920(ra) # 80003c54 <ialloc>
    800058c4:	84aa                	mv	s1,a0
    800058c6:	c529                	beqz	a0,80005910 <create+0xee>
  ilock(ip);
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	524080e7          	jalr	1316(ra) # 80003dec <ilock>
  ip->major = major;
    800058d0:	05549f23          	sh	s5,94(s1)
  ip->minor = minor;
    800058d4:	07449023          	sh	s4,96(s1)
  ip->nlink = 1;
    800058d8:	4785                	li	a5,1
    800058da:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    800058de:	8526                	mv	a0,s1
    800058e0:	ffffe097          	auipc	ra,0xffffe
    800058e4:	442080e7          	jalr	1090(ra) # 80003d22 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800058e8:	2981                	sext.w	s3,s3
    800058ea:	4785                	li	a5,1
    800058ec:	02f98a63          	beq	s3,a5,80005920 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800058f0:	40d0                	lw	a2,4(s1)
    800058f2:	fb040593          	addi	a1,s0,-80
    800058f6:	854a                	mv	a0,s2
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	bbc080e7          	jalr	-1092(ra) # 800044b4 <dirlink>
    80005900:	06054b63          	bltz	a0,80005976 <create+0x154>
  iunlockput(dp);
    80005904:	854a                	mv	a0,s2
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	724080e7          	jalr	1828(ra) # 8000402a <iunlockput>
  return ip;
    8000590e:	b759                	j	80005894 <create+0x72>
    panic("create: ialloc");
    80005910:	00003517          	auipc	a0,0x3
    80005914:	33850513          	addi	a0,a0,824 # 80008c48 <userret+0xbb8>
    80005918:	ffffb097          	auipc	ra,0xffffb
    8000591c:	e3e080e7          	jalr	-450(ra) # 80000756 <panic>
    dp->nlink++;  // for ".."
    80005920:	06295783          	lhu	a5,98(s2)
    80005924:	2785                	addiw	a5,a5,1
    80005926:	06f91123          	sh	a5,98(s2)
    iupdate(dp);
    8000592a:	854a                	mv	a0,s2
    8000592c:	ffffe097          	auipc	ra,0xffffe
    80005930:	3f6080e7          	jalr	1014(ra) # 80003d22 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005934:	40d0                	lw	a2,4(s1)
    80005936:	00003597          	auipc	a1,0x3
    8000593a:	32258593          	addi	a1,a1,802 # 80008c58 <userret+0xbc8>
    8000593e:	8526                	mv	a0,s1
    80005940:	fffff097          	auipc	ra,0xfffff
    80005944:	b74080e7          	jalr	-1164(ra) # 800044b4 <dirlink>
    80005948:	00054f63          	bltz	a0,80005966 <create+0x144>
    8000594c:	00492603          	lw	a2,4(s2)
    80005950:	00003597          	auipc	a1,0x3
    80005954:	31058593          	addi	a1,a1,784 # 80008c60 <userret+0xbd0>
    80005958:	8526                	mv	a0,s1
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	b5a080e7          	jalr	-1190(ra) # 800044b4 <dirlink>
    80005962:	f80557e3          	bgez	a0,800058f0 <create+0xce>
      panic("create dots");
    80005966:	00003517          	auipc	a0,0x3
    8000596a:	30250513          	addi	a0,a0,770 # 80008c68 <userret+0xbd8>
    8000596e:	ffffb097          	auipc	ra,0xffffb
    80005972:	de8080e7          	jalr	-536(ra) # 80000756 <panic>
    panic("create: dirlink");
    80005976:	00003517          	auipc	a0,0x3
    8000597a:	30250513          	addi	a0,a0,770 # 80008c78 <userret+0xbe8>
    8000597e:	ffffb097          	auipc	ra,0xffffb
    80005982:	dd8080e7          	jalr	-552(ra) # 80000756 <panic>
    return 0;
    80005986:	84aa                	mv	s1,a0
    80005988:	b731                	j	80005894 <create+0x72>

000000008000598a <sys_dup>:
{
    8000598a:	7179                	addi	sp,sp,-48
    8000598c:	f406                	sd	ra,40(sp)
    8000598e:	f022                	sd	s0,32(sp)
    80005990:	ec26                	sd	s1,24(sp)
    80005992:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005994:	fd840613          	addi	a2,s0,-40
    80005998:	4581                	li	a1,0
    8000599a:	4501                	li	a0,0
    8000599c:	00000097          	auipc	ra,0x0
    800059a0:	ddc080e7          	jalr	-548(ra) # 80005778 <argfd>
    return -1;
    800059a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800059a6:	02054363          	bltz	a0,800059cc <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800059aa:	fd843503          	ld	a0,-40(s0)
    800059ae:	00000097          	auipc	ra,0x0
    800059b2:	e32080e7          	jalr	-462(ra) # 800057e0 <fdalloc>
    800059b6:	84aa                	mv	s1,a0
    return -1;
    800059b8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800059ba:	00054963          	bltz	a0,800059cc <sys_dup+0x42>
  filedup(f);
    800059be:	fd843503          	ld	a0,-40(s0)
    800059c2:	fffff097          	auipc	ra,0xfffff
    800059c6:	332080e7          	jalr	818(ra) # 80004cf4 <filedup>
  return fd;
    800059ca:	87a6                	mv	a5,s1
}
    800059cc:	853e                	mv	a0,a5
    800059ce:	70a2                	ld	ra,40(sp)
    800059d0:	7402                	ld	s0,32(sp)
    800059d2:	64e2                	ld	s1,24(sp)
    800059d4:	6145                	addi	sp,sp,48
    800059d6:	8082                	ret

00000000800059d8 <sys_read>:
{
    800059d8:	7179                	addi	sp,sp,-48
    800059da:	f406                	sd	ra,40(sp)
    800059dc:	f022                	sd	s0,32(sp)
    800059de:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800059e0:	fe840613          	addi	a2,s0,-24
    800059e4:	4581                	li	a1,0
    800059e6:	4501                	li	a0,0
    800059e8:	00000097          	auipc	ra,0x0
    800059ec:	d90080e7          	jalr	-624(ra) # 80005778 <argfd>
    return -1;
    800059f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800059f2:	04054163          	bltz	a0,80005a34 <sys_read+0x5c>
    800059f6:	fe440593          	addi	a1,s0,-28
    800059fa:	4509                	li	a0,2
    800059fc:	ffffe097          	auipc	ra,0xffffe
    80005a00:	86c080e7          	jalr	-1940(ra) # 80003268 <argint>
    return -1;
    80005a04:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a06:	02054763          	bltz	a0,80005a34 <sys_read+0x5c>
    80005a0a:	fd840593          	addi	a1,s0,-40
    80005a0e:	4505                	li	a0,1
    80005a10:	ffffe097          	auipc	ra,0xffffe
    80005a14:	87a080e7          	jalr	-1926(ra) # 8000328a <argaddr>
    return -1;
    80005a18:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a1a:	00054d63          	bltz	a0,80005a34 <sys_read+0x5c>
  return fileread(f, p, n);
    80005a1e:	fe442603          	lw	a2,-28(s0)
    80005a22:	fd843583          	ld	a1,-40(s0)
    80005a26:	fe843503          	ld	a0,-24(s0)
    80005a2a:	fffff097          	auipc	ra,0xfffff
    80005a2e:	45e080e7          	jalr	1118(ra) # 80004e88 <fileread>
    80005a32:	87aa                	mv	a5,a0
}
    80005a34:	853e                	mv	a0,a5
    80005a36:	70a2                	ld	ra,40(sp)
    80005a38:	7402                	ld	s0,32(sp)
    80005a3a:	6145                	addi	sp,sp,48
    80005a3c:	8082                	ret

0000000080005a3e <sys_write>:
{
    80005a3e:	7179                	addi	sp,sp,-48
    80005a40:	f406                	sd	ra,40(sp)
    80005a42:	f022                	sd	s0,32(sp)
    80005a44:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a46:	fe840613          	addi	a2,s0,-24
    80005a4a:	4581                	li	a1,0
    80005a4c:	4501                	li	a0,0
    80005a4e:	00000097          	auipc	ra,0x0
    80005a52:	d2a080e7          	jalr	-726(ra) # 80005778 <argfd>
    return -1;
    80005a56:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a58:	04054163          	bltz	a0,80005a9a <sys_write+0x5c>
    80005a5c:	fe440593          	addi	a1,s0,-28
    80005a60:	4509                	li	a0,2
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	806080e7          	jalr	-2042(ra) # 80003268 <argint>
    return -1;
    80005a6a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a6c:	02054763          	bltz	a0,80005a9a <sys_write+0x5c>
    80005a70:	fd840593          	addi	a1,s0,-40
    80005a74:	4505                	li	a0,1
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	814080e7          	jalr	-2028(ra) # 8000328a <argaddr>
    return -1;
    80005a7e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a80:	00054d63          	bltz	a0,80005a9a <sys_write+0x5c>
  return filewrite(f, p, n);
    80005a84:	fe442603          	lw	a2,-28(s0)
    80005a88:	fd843583          	ld	a1,-40(s0)
    80005a8c:	fe843503          	ld	a0,-24(s0)
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	4be080e7          	jalr	1214(ra) # 80004f4e <filewrite>
    80005a98:	87aa                	mv	a5,a0
}
    80005a9a:	853e                	mv	a0,a5
    80005a9c:	70a2                	ld	ra,40(sp)
    80005a9e:	7402                	ld	s0,32(sp)
    80005aa0:	6145                	addi	sp,sp,48
    80005aa2:	8082                	ret

0000000080005aa4 <sys_close>:
{
    80005aa4:	1101                	addi	sp,sp,-32
    80005aa6:	ec06                	sd	ra,24(sp)
    80005aa8:	e822                	sd	s0,16(sp)
    80005aaa:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005aac:	fe040613          	addi	a2,s0,-32
    80005ab0:	fec40593          	addi	a1,s0,-20
    80005ab4:	4501                	li	a0,0
    80005ab6:	00000097          	auipc	ra,0x0
    80005aba:	cc2080e7          	jalr	-830(ra) # 80005778 <argfd>
    return -1;
    80005abe:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005ac0:	02054463          	bltz	a0,80005ae8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ac4:	ffffc097          	auipc	ra,0xffffc
    80005ac8:	4d8080e7          	jalr	1240(ra) # 80001f9c <myproc>
    80005acc:	fec42783          	lw	a5,-20(s0)
    80005ad0:	07f1                	addi	a5,a5,28
    80005ad2:	078e                	slli	a5,a5,0x3
    80005ad4:	97aa                	add	a5,a5,a0
    80005ad6:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005ada:	fe043503          	ld	a0,-32(s0)
    80005ade:	fffff097          	auipc	ra,0xfffff
    80005ae2:	268080e7          	jalr	616(ra) # 80004d46 <fileclose>
  return 0;
    80005ae6:	4781                	li	a5,0
}
    80005ae8:	853e                	mv	a0,a5
    80005aea:	60e2                	ld	ra,24(sp)
    80005aec:	6442                	ld	s0,16(sp)
    80005aee:	6105                	addi	sp,sp,32
    80005af0:	8082                	ret

0000000080005af2 <sys_fstat>:
{
    80005af2:	1101                	addi	sp,sp,-32
    80005af4:	ec06                	sd	ra,24(sp)
    80005af6:	e822                	sd	s0,16(sp)
    80005af8:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005afa:	fe840613          	addi	a2,s0,-24
    80005afe:	4581                	li	a1,0
    80005b00:	4501                	li	a0,0
    80005b02:	00000097          	auipc	ra,0x0
    80005b06:	c76080e7          	jalr	-906(ra) # 80005778 <argfd>
    return -1;
    80005b0a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005b0c:	02054563          	bltz	a0,80005b36 <sys_fstat+0x44>
    80005b10:	fe040593          	addi	a1,s0,-32
    80005b14:	4505                	li	a0,1
    80005b16:	ffffd097          	auipc	ra,0xffffd
    80005b1a:	774080e7          	jalr	1908(ra) # 8000328a <argaddr>
    return -1;
    80005b1e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005b20:	00054b63          	bltz	a0,80005b36 <sys_fstat+0x44>
  return filestat(f, st);
    80005b24:	fe043583          	ld	a1,-32(s0)
    80005b28:	fe843503          	ld	a0,-24(s0)
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	2ea080e7          	jalr	746(ra) # 80004e16 <filestat>
    80005b34:	87aa                	mv	a5,a0
}
    80005b36:	853e                	mv	a0,a5
    80005b38:	60e2                	ld	ra,24(sp)
    80005b3a:	6442                	ld	s0,16(sp)
    80005b3c:	6105                	addi	sp,sp,32
    80005b3e:	8082                	ret

0000000080005b40 <sys_link>:
{
    80005b40:	7169                	addi	sp,sp,-304
    80005b42:	f606                	sd	ra,296(sp)
    80005b44:	f222                	sd	s0,288(sp)
    80005b46:	ee26                	sd	s1,280(sp)
    80005b48:	ea4a                	sd	s2,272(sp)
    80005b4a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b4c:	08000613          	li	a2,128
    80005b50:	ed040593          	addi	a1,s0,-304
    80005b54:	4501                	li	a0,0
    80005b56:	ffffd097          	auipc	ra,0xffffd
    80005b5a:	756080e7          	jalr	1878(ra) # 800032ac <argstr>
    return -1;
    80005b5e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b60:	12054363          	bltz	a0,80005c86 <sys_link+0x146>
    80005b64:	08000613          	li	a2,128
    80005b68:	f5040593          	addi	a1,s0,-176
    80005b6c:	4505                	li	a0,1
    80005b6e:	ffffd097          	auipc	ra,0xffffd
    80005b72:	73e080e7          	jalr	1854(ra) # 800032ac <argstr>
    return -1;
    80005b76:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b78:	10054763          	bltz	a0,80005c86 <sys_link+0x146>
  begin_op(ROOTDEV);
    80005b7c:	4501                	li	a0,0
    80005b7e:	fffff097          	auipc	ra,0xfffff
    80005b82:	c3e080e7          	jalr	-962(ra) # 800047bc <begin_op>
  if((ip = namei(old)) == 0){
    80005b86:	ed040513          	addi	a0,s0,-304
    80005b8a:	fffff097          	auipc	ra,0xfffff
    80005b8e:	9ec080e7          	jalr	-1556(ra) # 80004576 <namei>
    80005b92:	84aa                	mv	s1,a0
    80005b94:	c559                	beqz	a0,80005c22 <sys_link+0xe2>
  ilock(ip);
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	256080e7          	jalr	598(ra) # 80003dec <ilock>
  if(ip->type == T_DIR){
    80005b9e:	05c49703          	lh	a4,92(s1)
    80005ba2:	4785                	li	a5,1
    80005ba4:	08f70663          	beq	a4,a5,80005c30 <sys_link+0xf0>
  ip->nlink++;
    80005ba8:	0624d783          	lhu	a5,98(s1)
    80005bac:	2785                	addiw	a5,a5,1
    80005bae:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005bb2:	8526                	mv	a0,s1
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	16e080e7          	jalr	366(ra) # 80003d22 <iupdate>
  iunlock(ip);
    80005bbc:	8526                	mv	a0,s1
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	2f0080e7          	jalr	752(ra) # 80003eae <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005bc6:	fd040593          	addi	a1,s0,-48
    80005bca:	f5040513          	addi	a0,s0,-176
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	9c6080e7          	jalr	-1594(ra) # 80004594 <nameiparent>
    80005bd6:	892a                	mv	s2,a0
    80005bd8:	cd2d                	beqz	a0,80005c52 <sys_link+0x112>
  ilock(dp);
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	212080e7          	jalr	530(ra) # 80003dec <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005be2:	00092703          	lw	a4,0(s2)
    80005be6:	409c                	lw	a5,0(s1)
    80005be8:	06f71063          	bne	a4,a5,80005c48 <sys_link+0x108>
    80005bec:	40d0                	lw	a2,4(s1)
    80005bee:	fd040593          	addi	a1,s0,-48
    80005bf2:	854a                	mv	a0,s2
    80005bf4:	fffff097          	auipc	ra,0xfffff
    80005bf8:	8c0080e7          	jalr	-1856(ra) # 800044b4 <dirlink>
    80005bfc:	04054663          	bltz	a0,80005c48 <sys_link+0x108>
  iunlockput(dp);
    80005c00:	854a                	mv	a0,s2
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	428080e7          	jalr	1064(ra) # 8000402a <iunlockput>
  iput(ip);
    80005c0a:	8526                	mv	a0,s1
    80005c0c:	ffffe097          	auipc	ra,0xffffe
    80005c10:	2ee080e7          	jalr	750(ra) # 80003efa <iput>
  end_op(ROOTDEV);
    80005c14:	4501                	li	a0,0
    80005c16:	fffff097          	auipc	ra,0xfffff
    80005c1a:	c52080e7          	jalr	-942(ra) # 80004868 <end_op>
  return 0;
    80005c1e:	4781                	li	a5,0
    80005c20:	a09d                	j	80005c86 <sys_link+0x146>
    end_op(ROOTDEV);
    80005c22:	4501                	li	a0,0
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	c44080e7          	jalr	-956(ra) # 80004868 <end_op>
    return -1;
    80005c2c:	57fd                	li	a5,-1
    80005c2e:	a8a1                	j	80005c86 <sys_link+0x146>
    iunlockput(ip);
    80005c30:	8526                	mv	a0,s1
    80005c32:	ffffe097          	auipc	ra,0xffffe
    80005c36:	3f8080e7          	jalr	1016(ra) # 8000402a <iunlockput>
    end_op(ROOTDEV);
    80005c3a:	4501                	li	a0,0
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	c2c080e7          	jalr	-980(ra) # 80004868 <end_op>
    return -1;
    80005c44:	57fd                	li	a5,-1
    80005c46:	a081                	j	80005c86 <sys_link+0x146>
    iunlockput(dp);
    80005c48:	854a                	mv	a0,s2
    80005c4a:	ffffe097          	auipc	ra,0xffffe
    80005c4e:	3e0080e7          	jalr	992(ra) # 8000402a <iunlockput>
  ilock(ip);
    80005c52:	8526                	mv	a0,s1
    80005c54:	ffffe097          	auipc	ra,0xffffe
    80005c58:	198080e7          	jalr	408(ra) # 80003dec <ilock>
  ip->nlink--;
    80005c5c:	0624d783          	lhu	a5,98(s1)
    80005c60:	37fd                	addiw	a5,a5,-1
    80005c62:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005c66:	8526                	mv	a0,s1
    80005c68:	ffffe097          	auipc	ra,0xffffe
    80005c6c:	0ba080e7          	jalr	186(ra) # 80003d22 <iupdate>
  iunlockput(ip);
    80005c70:	8526                	mv	a0,s1
    80005c72:	ffffe097          	auipc	ra,0xffffe
    80005c76:	3b8080e7          	jalr	952(ra) # 8000402a <iunlockput>
  end_op(ROOTDEV);
    80005c7a:	4501                	li	a0,0
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	bec080e7          	jalr	-1044(ra) # 80004868 <end_op>
  return -1;
    80005c84:	57fd                	li	a5,-1
}
    80005c86:	853e                	mv	a0,a5
    80005c88:	70b2                	ld	ra,296(sp)
    80005c8a:	7412                	ld	s0,288(sp)
    80005c8c:	64f2                	ld	s1,280(sp)
    80005c8e:	6952                	ld	s2,272(sp)
    80005c90:	6155                	addi	sp,sp,304
    80005c92:	8082                	ret

0000000080005c94 <sys_unlink>:
{
    80005c94:	7151                	addi	sp,sp,-240
    80005c96:	f586                	sd	ra,232(sp)
    80005c98:	f1a2                	sd	s0,224(sp)
    80005c9a:	eda6                	sd	s1,216(sp)
    80005c9c:	e9ca                	sd	s2,208(sp)
    80005c9e:	e5ce                	sd	s3,200(sp)
    80005ca0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005ca2:	08000613          	li	a2,128
    80005ca6:	f3040593          	addi	a1,s0,-208
    80005caa:	4501                	li	a0,0
    80005cac:	ffffd097          	auipc	ra,0xffffd
    80005cb0:	600080e7          	jalr	1536(ra) # 800032ac <argstr>
    80005cb4:	18054463          	bltz	a0,80005e3c <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    80005cb8:	4501                	li	a0,0
    80005cba:	fffff097          	auipc	ra,0xfffff
    80005cbe:	b02080e7          	jalr	-1278(ra) # 800047bc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005cc2:	fb040593          	addi	a1,s0,-80
    80005cc6:	f3040513          	addi	a0,s0,-208
    80005cca:	fffff097          	auipc	ra,0xfffff
    80005cce:	8ca080e7          	jalr	-1846(ra) # 80004594 <nameiparent>
    80005cd2:	84aa                	mv	s1,a0
    80005cd4:	cd61                	beqz	a0,80005dac <sys_unlink+0x118>
  ilock(dp);
    80005cd6:	ffffe097          	auipc	ra,0xffffe
    80005cda:	116080e7          	jalr	278(ra) # 80003dec <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005cde:	00003597          	auipc	a1,0x3
    80005ce2:	f7a58593          	addi	a1,a1,-134 # 80008c58 <userret+0xbc8>
    80005ce6:	fb040513          	addi	a0,s0,-80
    80005cea:	ffffe097          	auipc	ra,0xffffe
    80005cee:	5a0080e7          	jalr	1440(ra) # 8000428a <namecmp>
    80005cf2:	14050c63          	beqz	a0,80005e4a <sys_unlink+0x1b6>
    80005cf6:	00003597          	auipc	a1,0x3
    80005cfa:	f6a58593          	addi	a1,a1,-150 # 80008c60 <userret+0xbd0>
    80005cfe:	fb040513          	addi	a0,s0,-80
    80005d02:	ffffe097          	auipc	ra,0xffffe
    80005d06:	588080e7          	jalr	1416(ra) # 8000428a <namecmp>
    80005d0a:	14050063          	beqz	a0,80005e4a <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005d0e:	f2c40613          	addi	a2,s0,-212
    80005d12:	fb040593          	addi	a1,s0,-80
    80005d16:	8526                	mv	a0,s1
    80005d18:	ffffe097          	auipc	ra,0xffffe
    80005d1c:	58c080e7          	jalr	1420(ra) # 800042a4 <dirlookup>
    80005d20:	892a                	mv	s2,a0
    80005d22:	12050463          	beqz	a0,80005e4a <sys_unlink+0x1b6>
  ilock(ip);
    80005d26:	ffffe097          	auipc	ra,0xffffe
    80005d2a:	0c6080e7          	jalr	198(ra) # 80003dec <ilock>
  if(ip->nlink < 1)
    80005d2e:	06291783          	lh	a5,98(s2)
    80005d32:	08f05463          	blez	a5,80005dba <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005d36:	05c91703          	lh	a4,92(s2)
    80005d3a:	4785                	li	a5,1
    80005d3c:	08f70763          	beq	a4,a5,80005dca <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005d40:	4641                	li	a2,16
    80005d42:	4581                	li	a1,0
    80005d44:	fc040513          	addi	a0,s0,-64
    80005d48:	ffffb097          	auipc	ra,0xffffb
    80005d4c:	38c080e7          	jalr	908(ra) # 800010d4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d50:	4741                	li	a4,16
    80005d52:	f2c42683          	lw	a3,-212(s0)
    80005d56:	fc040613          	addi	a2,s0,-64
    80005d5a:	4581                	li	a1,0
    80005d5c:	8526                	mv	a0,s1
    80005d5e:	ffffe097          	auipc	ra,0xffffe
    80005d62:	412080e7          	jalr	1042(ra) # 80004170 <writei>
    80005d66:	47c1                	li	a5,16
    80005d68:	0af51763          	bne	a0,a5,80005e16 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005d6c:	05c91703          	lh	a4,92(s2)
    80005d70:	4785                	li	a5,1
    80005d72:	0af70a63          	beq	a4,a5,80005e26 <sys_unlink+0x192>
  iunlockput(dp);
    80005d76:	8526                	mv	a0,s1
    80005d78:	ffffe097          	auipc	ra,0xffffe
    80005d7c:	2b2080e7          	jalr	690(ra) # 8000402a <iunlockput>
  ip->nlink--;
    80005d80:	06295783          	lhu	a5,98(s2)
    80005d84:	37fd                	addiw	a5,a5,-1
    80005d86:	06f91123          	sh	a5,98(s2)
  iupdate(ip);
    80005d8a:	854a                	mv	a0,s2
    80005d8c:	ffffe097          	auipc	ra,0xffffe
    80005d90:	f96080e7          	jalr	-106(ra) # 80003d22 <iupdate>
  iunlockput(ip);
    80005d94:	854a                	mv	a0,s2
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	294080e7          	jalr	660(ra) # 8000402a <iunlockput>
  end_op(ROOTDEV);
    80005d9e:	4501                	li	a0,0
    80005da0:	fffff097          	auipc	ra,0xfffff
    80005da4:	ac8080e7          	jalr	-1336(ra) # 80004868 <end_op>
  return 0;
    80005da8:	4501                	li	a0,0
    80005daa:	a85d                	j	80005e60 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    80005dac:	4501                	li	a0,0
    80005dae:	fffff097          	auipc	ra,0xfffff
    80005db2:	aba080e7          	jalr	-1350(ra) # 80004868 <end_op>
    return -1;
    80005db6:	557d                	li	a0,-1
    80005db8:	a065                	j	80005e60 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    80005dba:	00003517          	auipc	a0,0x3
    80005dbe:	ece50513          	addi	a0,a0,-306 # 80008c88 <userret+0xbf8>
    80005dc2:	ffffb097          	auipc	ra,0xffffb
    80005dc6:	994080e7          	jalr	-1644(ra) # 80000756 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005dca:	06492703          	lw	a4,100(s2)
    80005dce:	02000793          	li	a5,32
    80005dd2:	f6e7f7e3          	bgeu	a5,a4,80005d40 <sys_unlink+0xac>
    80005dd6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005dda:	4741                	li	a4,16
    80005ddc:	86ce                	mv	a3,s3
    80005dde:	f1840613          	addi	a2,s0,-232
    80005de2:	4581                	li	a1,0
    80005de4:	854a                	mv	a0,s2
    80005de6:	ffffe097          	auipc	ra,0xffffe
    80005dea:	296080e7          	jalr	662(ra) # 8000407c <readi>
    80005dee:	47c1                	li	a5,16
    80005df0:	00f51b63          	bne	a0,a5,80005e06 <sys_unlink+0x172>
    if(de.inum != 0)
    80005df4:	f1845783          	lhu	a5,-232(s0)
    80005df8:	e7a1                	bnez	a5,80005e40 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005dfa:	29c1                	addiw	s3,s3,16
    80005dfc:	06492783          	lw	a5,100(s2)
    80005e00:	fcf9ede3          	bltu	s3,a5,80005dda <sys_unlink+0x146>
    80005e04:	bf35                	j	80005d40 <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005e06:	00003517          	auipc	a0,0x3
    80005e0a:	e9a50513          	addi	a0,a0,-358 # 80008ca0 <userret+0xc10>
    80005e0e:	ffffb097          	auipc	ra,0xffffb
    80005e12:	948080e7          	jalr	-1720(ra) # 80000756 <panic>
    panic("unlink: writei");
    80005e16:	00003517          	auipc	a0,0x3
    80005e1a:	ea250513          	addi	a0,a0,-350 # 80008cb8 <userret+0xc28>
    80005e1e:	ffffb097          	auipc	ra,0xffffb
    80005e22:	938080e7          	jalr	-1736(ra) # 80000756 <panic>
    dp->nlink--;
    80005e26:	0624d783          	lhu	a5,98(s1)
    80005e2a:	37fd                	addiw	a5,a5,-1
    80005e2c:	06f49123          	sh	a5,98(s1)
    iupdate(dp);
    80005e30:	8526                	mv	a0,s1
    80005e32:	ffffe097          	auipc	ra,0xffffe
    80005e36:	ef0080e7          	jalr	-272(ra) # 80003d22 <iupdate>
    80005e3a:	bf35                	j	80005d76 <sys_unlink+0xe2>
    return -1;
    80005e3c:	557d                	li	a0,-1
    80005e3e:	a00d                	j	80005e60 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005e40:	854a                	mv	a0,s2
    80005e42:	ffffe097          	auipc	ra,0xffffe
    80005e46:	1e8080e7          	jalr	488(ra) # 8000402a <iunlockput>
  iunlockput(dp);
    80005e4a:	8526                	mv	a0,s1
    80005e4c:	ffffe097          	auipc	ra,0xffffe
    80005e50:	1de080e7          	jalr	478(ra) # 8000402a <iunlockput>
  end_op(ROOTDEV);
    80005e54:	4501                	li	a0,0
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	a12080e7          	jalr	-1518(ra) # 80004868 <end_op>
  return -1;
    80005e5e:	557d                	li	a0,-1
}
    80005e60:	70ae                	ld	ra,232(sp)
    80005e62:	740e                	ld	s0,224(sp)
    80005e64:	64ee                	ld	s1,216(sp)
    80005e66:	694e                	ld	s2,208(sp)
    80005e68:	69ae                	ld	s3,200(sp)
    80005e6a:	616d                	addi	sp,sp,240
    80005e6c:	8082                	ret

0000000080005e6e <sys_open>:

uint64
sys_open(void)
{
    80005e6e:	7131                	addi	sp,sp,-192
    80005e70:	fd06                	sd	ra,184(sp)
    80005e72:	f922                	sd	s0,176(sp)
    80005e74:	f526                	sd	s1,168(sp)
    80005e76:	f14a                	sd	s2,160(sp)
    80005e78:	ed4e                	sd	s3,152(sp)
    80005e7a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005e7c:	08000613          	li	a2,128
    80005e80:	f5040593          	addi	a1,s0,-176
    80005e84:	4501                	li	a0,0
    80005e86:	ffffd097          	auipc	ra,0xffffd
    80005e8a:	426080e7          	jalr	1062(ra) # 800032ac <argstr>
    return -1;
    80005e8e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005e90:	0a054963          	bltz	a0,80005f42 <sys_open+0xd4>
    80005e94:	f4c40593          	addi	a1,s0,-180
    80005e98:	4505                	li	a0,1
    80005e9a:	ffffd097          	auipc	ra,0xffffd
    80005e9e:	3ce080e7          	jalr	974(ra) # 80003268 <argint>
    80005ea2:	0a054063          	bltz	a0,80005f42 <sys_open+0xd4>

  begin_op(ROOTDEV);
    80005ea6:	4501                	li	a0,0
    80005ea8:	fffff097          	auipc	ra,0xfffff
    80005eac:	914080e7          	jalr	-1772(ra) # 800047bc <begin_op>

  if(omode & O_CREATE){
    80005eb0:	f4c42783          	lw	a5,-180(s0)
    80005eb4:	2007f793          	andi	a5,a5,512
    80005eb8:	c3dd                	beqz	a5,80005f5e <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80005eba:	4681                	li	a3,0
    80005ebc:	4601                	li	a2,0
    80005ebe:	4589                	li	a1,2
    80005ec0:	f5040513          	addi	a0,s0,-176
    80005ec4:	00000097          	auipc	ra,0x0
    80005ec8:	95e080e7          	jalr	-1698(ra) # 80005822 <create>
    80005ecc:	892a                	mv	s2,a0
    if(ip == 0){
    80005ece:	c151                	beqz	a0,80005f52 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ed0:	05c91703          	lh	a4,92(s2)
    80005ed4:	478d                	li	a5,3
    80005ed6:	00f71763          	bne	a4,a5,80005ee4 <sys_open+0x76>
    80005eda:	05e95703          	lhu	a4,94(s2)
    80005ede:	47a5                	li	a5,9
    80005ee0:	0ce7e663          	bltu	a5,a4,80005fac <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ee4:	fffff097          	auipc	ra,0xfffff
    80005ee8:	da6080e7          	jalr	-602(ra) # 80004c8a <filealloc>
    80005eec:	89aa                	mv	s3,a0
    80005eee:	c97d                	beqz	a0,80005fe4 <sys_open+0x176>
    80005ef0:	00000097          	auipc	ra,0x0
    80005ef4:	8f0080e7          	jalr	-1808(ra) # 800057e0 <fdalloc>
    80005ef8:	84aa                	mv	s1,a0
    80005efa:	0e054063          	bltz	a0,80005fda <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005efe:	05c91703          	lh	a4,92(s2)
    80005f02:	478d                	li	a5,3
    80005f04:	0cf70063          	beq	a4,a5,80005fc4 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005f08:	4789                	li	a5,2
    80005f0a:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005f0e:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005f12:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005f16:	f4c42783          	lw	a5,-180(s0)
    80005f1a:	0017c713          	xori	a4,a5,1
    80005f1e:	8b05                	andi	a4,a4,1
    80005f20:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f24:	8b8d                	andi	a5,a5,3
    80005f26:	00f037b3          	snez	a5,a5
    80005f2a:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005f2e:	854a                	mv	a0,s2
    80005f30:	ffffe097          	auipc	ra,0xffffe
    80005f34:	f7e080e7          	jalr	-130(ra) # 80003eae <iunlock>
  end_op(ROOTDEV);
    80005f38:	4501                	li	a0,0
    80005f3a:	fffff097          	auipc	ra,0xfffff
    80005f3e:	92e080e7          	jalr	-1746(ra) # 80004868 <end_op>

  return fd;
}
    80005f42:	8526                	mv	a0,s1
    80005f44:	70ea                	ld	ra,184(sp)
    80005f46:	744a                	ld	s0,176(sp)
    80005f48:	74aa                	ld	s1,168(sp)
    80005f4a:	790a                	ld	s2,160(sp)
    80005f4c:	69ea                	ld	s3,152(sp)
    80005f4e:	6129                	addi	sp,sp,192
    80005f50:	8082                	ret
      end_op(ROOTDEV);
    80005f52:	4501                	li	a0,0
    80005f54:	fffff097          	auipc	ra,0xfffff
    80005f58:	914080e7          	jalr	-1772(ra) # 80004868 <end_op>
      return -1;
    80005f5c:	b7dd                	j	80005f42 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005f5e:	f5040513          	addi	a0,s0,-176
    80005f62:	ffffe097          	auipc	ra,0xffffe
    80005f66:	614080e7          	jalr	1556(ra) # 80004576 <namei>
    80005f6a:	892a                	mv	s2,a0
    80005f6c:	c90d                	beqz	a0,80005f9e <sys_open+0x130>
    ilock(ip);
    80005f6e:	ffffe097          	auipc	ra,0xffffe
    80005f72:	e7e080e7          	jalr	-386(ra) # 80003dec <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f76:	05c91703          	lh	a4,92(s2)
    80005f7a:	4785                	li	a5,1
    80005f7c:	f4f71ae3          	bne	a4,a5,80005ed0 <sys_open+0x62>
    80005f80:	f4c42783          	lw	a5,-180(s0)
    80005f84:	d3a5                	beqz	a5,80005ee4 <sys_open+0x76>
      iunlockput(ip);
    80005f86:	854a                	mv	a0,s2
    80005f88:	ffffe097          	auipc	ra,0xffffe
    80005f8c:	0a2080e7          	jalr	162(ra) # 8000402a <iunlockput>
      end_op(ROOTDEV);
    80005f90:	4501                	li	a0,0
    80005f92:	fffff097          	auipc	ra,0xfffff
    80005f96:	8d6080e7          	jalr	-1834(ra) # 80004868 <end_op>
      return -1;
    80005f9a:	54fd                	li	s1,-1
    80005f9c:	b75d                	j	80005f42 <sys_open+0xd4>
      end_op(ROOTDEV);
    80005f9e:	4501                	li	a0,0
    80005fa0:	fffff097          	auipc	ra,0xfffff
    80005fa4:	8c8080e7          	jalr	-1848(ra) # 80004868 <end_op>
      return -1;
    80005fa8:	54fd                	li	s1,-1
    80005faa:	bf61                	j	80005f42 <sys_open+0xd4>
    iunlockput(ip);
    80005fac:	854a                	mv	a0,s2
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	07c080e7          	jalr	124(ra) # 8000402a <iunlockput>
    end_op(ROOTDEV);
    80005fb6:	4501                	li	a0,0
    80005fb8:	fffff097          	auipc	ra,0xfffff
    80005fbc:	8b0080e7          	jalr	-1872(ra) # 80004868 <end_op>
    return -1;
    80005fc0:	54fd                	li	s1,-1
    80005fc2:	b741                	j	80005f42 <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005fc4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005fc8:	05e91783          	lh	a5,94(s2)
    80005fcc:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005fd0:	06091783          	lh	a5,96(s2)
    80005fd4:	02f99323          	sh	a5,38(s3)
    80005fd8:	bf1d                	j	80005f0e <sys_open+0xa0>
      fileclose(f);
    80005fda:	854e                	mv	a0,s3
    80005fdc:	fffff097          	auipc	ra,0xfffff
    80005fe0:	d6a080e7          	jalr	-662(ra) # 80004d46 <fileclose>
    iunlockput(ip);
    80005fe4:	854a                	mv	a0,s2
    80005fe6:	ffffe097          	auipc	ra,0xffffe
    80005fea:	044080e7          	jalr	68(ra) # 8000402a <iunlockput>
    end_op(ROOTDEV);
    80005fee:	4501                	li	a0,0
    80005ff0:	fffff097          	auipc	ra,0xfffff
    80005ff4:	878080e7          	jalr	-1928(ra) # 80004868 <end_op>
    return -1;
    80005ff8:	54fd                	li	s1,-1
    80005ffa:	b7a1                	j	80005f42 <sys_open+0xd4>

0000000080005ffc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ffc:	7175                	addi	sp,sp,-144
    80005ffe:	e506                	sd	ra,136(sp)
    80006000:	e122                	sd	s0,128(sp)
    80006002:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80006004:	4501                	li	a0,0
    80006006:	ffffe097          	auipc	ra,0xffffe
    8000600a:	7b6080e7          	jalr	1974(ra) # 800047bc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000600e:	08000613          	li	a2,128
    80006012:	f7040593          	addi	a1,s0,-144
    80006016:	4501                	li	a0,0
    80006018:	ffffd097          	auipc	ra,0xffffd
    8000601c:	294080e7          	jalr	660(ra) # 800032ac <argstr>
    80006020:	02054a63          	bltz	a0,80006054 <sys_mkdir+0x58>
    80006024:	4681                	li	a3,0
    80006026:	4601                	li	a2,0
    80006028:	4585                	li	a1,1
    8000602a:	f7040513          	addi	a0,s0,-144
    8000602e:	fffff097          	auipc	ra,0xfffff
    80006032:	7f4080e7          	jalr	2036(ra) # 80005822 <create>
    80006036:	cd19                	beqz	a0,80006054 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80006038:	ffffe097          	auipc	ra,0xffffe
    8000603c:	ff2080e7          	jalr	-14(ra) # 8000402a <iunlockput>
  end_op(ROOTDEV);
    80006040:	4501                	li	a0,0
    80006042:	fffff097          	auipc	ra,0xfffff
    80006046:	826080e7          	jalr	-2010(ra) # 80004868 <end_op>
  return 0;
    8000604a:	4501                	li	a0,0
}
    8000604c:	60aa                	ld	ra,136(sp)
    8000604e:	640a                	ld	s0,128(sp)
    80006050:	6149                	addi	sp,sp,144
    80006052:	8082                	ret
    end_op(ROOTDEV);
    80006054:	4501                	li	a0,0
    80006056:	fffff097          	auipc	ra,0xfffff
    8000605a:	812080e7          	jalr	-2030(ra) # 80004868 <end_op>
    return -1;
    8000605e:	557d                	li	a0,-1
    80006060:	b7f5                	j	8000604c <sys_mkdir+0x50>

0000000080006062 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006062:	7135                	addi	sp,sp,-160
    80006064:	ed06                	sd	ra,152(sp)
    80006066:	e922                	sd	s0,144(sp)
    80006068:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    8000606a:	4501                	li	a0,0
    8000606c:	ffffe097          	auipc	ra,0xffffe
    80006070:	750080e7          	jalr	1872(ra) # 800047bc <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006074:	08000613          	li	a2,128
    80006078:	f7040593          	addi	a1,s0,-144
    8000607c:	4501                	li	a0,0
    8000607e:	ffffd097          	auipc	ra,0xffffd
    80006082:	22e080e7          	jalr	558(ra) # 800032ac <argstr>
    80006086:	04054b63          	bltz	a0,800060dc <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    8000608a:	f6c40593          	addi	a1,s0,-148
    8000608e:	4505                	li	a0,1
    80006090:	ffffd097          	auipc	ra,0xffffd
    80006094:	1d8080e7          	jalr	472(ra) # 80003268 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006098:	04054263          	bltz	a0,800060dc <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    8000609c:	f6840593          	addi	a1,s0,-152
    800060a0:	4509                	li	a0,2
    800060a2:	ffffd097          	auipc	ra,0xffffd
    800060a6:	1c6080e7          	jalr	454(ra) # 80003268 <argint>
     argint(1, &major) < 0 ||
    800060aa:	02054963          	bltz	a0,800060dc <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800060ae:	f6841683          	lh	a3,-152(s0)
    800060b2:	f6c41603          	lh	a2,-148(s0)
    800060b6:	458d                	li	a1,3
    800060b8:	f7040513          	addi	a0,s0,-144
    800060bc:	fffff097          	auipc	ra,0xfffff
    800060c0:	766080e7          	jalr	1894(ra) # 80005822 <create>
     argint(2, &minor) < 0 ||
    800060c4:	cd01                	beqz	a0,800060dc <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    800060c6:	ffffe097          	auipc	ra,0xffffe
    800060ca:	f64080e7          	jalr	-156(ra) # 8000402a <iunlockput>
  end_op(ROOTDEV);
    800060ce:	4501                	li	a0,0
    800060d0:	ffffe097          	auipc	ra,0xffffe
    800060d4:	798080e7          	jalr	1944(ra) # 80004868 <end_op>
  return 0;
    800060d8:	4501                	li	a0,0
    800060da:	a039                	j	800060e8 <sys_mknod+0x86>
    end_op(ROOTDEV);
    800060dc:	4501                	li	a0,0
    800060de:	ffffe097          	auipc	ra,0xffffe
    800060e2:	78a080e7          	jalr	1930(ra) # 80004868 <end_op>
    return -1;
    800060e6:	557d                	li	a0,-1
}
    800060e8:	60ea                	ld	ra,152(sp)
    800060ea:	644a                	ld	s0,144(sp)
    800060ec:	610d                	addi	sp,sp,160
    800060ee:	8082                	ret

00000000800060f0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800060f0:	7135                	addi	sp,sp,-160
    800060f2:	ed06                	sd	ra,152(sp)
    800060f4:	e922                	sd	s0,144(sp)
    800060f6:	e526                	sd	s1,136(sp)
    800060f8:	e14a                	sd	s2,128(sp)
    800060fa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060fc:	ffffc097          	auipc	ra,0xffffc
    80006100:	ea0080e7          	jalr	-352(ra) # 80001f9c <myproc>
    80006104:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80006106:	4501                	li	a0,0
    80006108:	ffffe097          	auipc	ra,0xffffe
    8000610c:	6b4080e7          	jalr	1716(ra) # 800047bc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006110:	08000613          	li	a2,128
    80006114:	f6040593          	addi	a1,s0,-160
    80006118:	4501                	li	a0,0
    8000611a:	ffffd097          	auipc	ra,0xffffd
    8000611e:	192080e7          	jalr	402(ra) # 800032ac <argstr>
    80006122:	04054c63          	bltz	a0,8000617a <sys_chdir+0x8a>
    80006126:	f6040513          	addi	a0,s0,-160
    8000612a:	ffffe097          	auipc	ra,0xffffe
    8000612e:	44c080e7          	jalr	1100(ra) # 80004576 <namei>
    80006132:	84aa                	mv	s1,a0
    80006134:	c139                	beqz	a0,8000617a <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80006136:	ffffe097          	auipc	ra,0xffffe
    8000613a:	cb6080e7          	jalr	-842(ra) # 80003dec <ilock>
  if(ip->type != T_DIR){
    8000613e:	05c49703          	lh	a4,92(s1)
    80006142:	4785                	li	a5,1
    80006144:	04f71263          	bne	a4,a5,80006188 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80006148:	8526                	mv	a0,s1
    8000614a:	ffffe097          	auipc	ra,0xffffe
    8000614e:	d64080e7          	jalr	-668(ra) # 80003eae <iunlock>
  iput(p->cwd);
    80006152:	16893503          	ld	a0,360(s2)
    80006156:	ffffe097          	auipc	ra,0xffffe
    8000615a:	da4080e7          	jalr	-604(ra) # 80003efa <iput>
  end_op(ROOTDEV);
    8000615e:	4501                	li	a0,0
    80006160:	ffffe097          	auipc	ra,0xffffe
    80006164:	708080e7          	jalr	1800(ra) # 80004868 <end_op>
  p->cwd = ip;
    80006168:	16993423          	sd	s1,360(s2)
  return 0;
    8000616c:	4501                	li	a0,0
}
    8000616e:	60ea                	ld	ra,152(sp)
    80006170:	644a                	ld	s0,144(sp)
    80006172:	64aa                	ld	s1,136(sp)
    80006174:	690a                	ld	s2,128(sp)
    80006176:	610d                	addi	sp,sp,160
    80006178:	8082                	ret
    end_op(ROOTDEV);
    8000617a:	4501                	li	a0,0
    8000617c:	ffffe097          	auipc	ra,0xffffe
    80006180:	6ec080e7          	jalr	1772(ra) # 80004868 <end_op>
    return -1;
    80006184:	557d                	li	a0,-1
    80006186:	b7e5                	j	8000616e <sys_chdir+0x7e>
    iunlockput(ip);
    80006188:	8526                	mv	a0,s1
    8000618a:	ffffe097          	auipc	ra,0xffffe
    8000618e:	ea0080e7          	jalr	-352(ra) # 8000402a <iunlockput>
    end_op(ROOTDEV);
    80006192:	4501                	li	a0,0
    80006194:	ffffe097          	auipc	ra,0xffffe
    80006198:	6d4080e7          	jalr	1748(ra) # 80004868 <end_op>
    return -1;
    8000619c:	557d                	li	a0,-1
    8000619e:	bfc1                	j	8000616e <sys_chdir+0x7e>

00000000800061a0 <sys_exec>:

uint64
sys_exec(void)
{
    800061a0:	7145                	addi	sp,sp,-464
    800061a2:	e786                	sd	ra,456(sp)
    800061a4:	e3a2                	sd	s0,448(sp)
    800061a6:	ff26                	sd	s1,440(sp)
    800061a8:	fb4a                	sd	s2,432(sp)
    800061aa:	f74e                	sd	s3,424(sp)
    800061ac:	f352                	sd	s4,416(sp)
    800061ae:	ef56                	sd	s5,408(sp)
    800061b0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800061b2:	08000613          	li	a2,128
    800061b6:	f4040593          	addi	a1,s0,-192
    800061ba:	4501                	li	a0,0
    800061bc:	ffffd097          	auipc	ra,0xffffd
    800061c0:	0f0080e7          	jalr	240(ra) # 800032ac <argstr>
    800061c4:	0e054663          	bltz	a0,800062b0 <sys_exec+0x110>
    800061c8:	e3840593          	addi	a1,s0,-456
    800061cc:	4505                	li	a0,1
    800061ce:	ffffd097          	auipc	ra,0xffffd
    800061d2:	0bc080e7          	jalr	188(ra) # 8000328a <argaddr>
    800061d6:	0e054763          	bltz	a0,800062c4 <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    800061da:	10000613          	li	a2,256
    800061de:	4581                	li	a1,0
    800061e0:	e4040513          	addi	a0,s0,-448
    800061e4:	ffffb097          	auipc	ra,0xffffb
    800061e8:	ef0080e7          	jalr	-272(ra) # 800010d4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800061ec:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    800061f0:	89ca                	mv	s3,s2
    800061f2:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    800061f4:	02000a13          	li	s4,32
    800061f8:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061fc:	00349513          	slli	a0,s1,0x3
    80006200:	e3040593          	addi	a1,s0,-464
    80006204:	e3843783          	ld	a5,-456(s0)
    80006208:	953e                	add	a0,a0,a5
    8000620a:	ffffd097          	auipc	ra,0xffffd
    8000620e:	fc4080e7          	jalr	-60(ra) # 800031ce <fetchaddr>
    80006212:	02054a63          	bltz	a0,80006246 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80006216:	e3043783          	ld	a5,-464(s0)
    8000621a:	c7a1                	beqz	a5,80006262 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000621c:	ffffb097          	auipc	ra,0xffffb
    80006220:	8e8080e7          	jalr	-1816(ra) # 80000b04 <kalloc>
    80006224:	85aa                	mv	a1,a0
    80006226:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000622a:	c92d                	beqz	a0,8000629c <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    8000622c:	6605                	lui	a2,0x1
    8000622e:	e3043503          	ld	a0,-464(s0)
    80006232:	ffffd097          	auipc	ra,0xffffd
    80006236:	fee080e7          	jalr	-18(ra) # 80003220 <fetchstr>
    8000623a:	00054663          	bltz	a0,80006246 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    8000623e:	0485                	addi	s1,s1,1
    80006240:	09a1                	addi	s3,s3,8
    80006242:	fb449be3          	bne	s1,s4,800061f8 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006246:	10090493          	addi	s1,s2,256
    8000624a:	00093503          	ld	a0,0(s2)
    8000624e:	cd39                	beqz	a0,800062ac <sys_exec+0x10c>
    kfree(argv[i]);
    80006250:	ffffb097          	auipc	ra,0xffffb
    80006254:	89c080e7          	jalr	-1892(ra) # 80000aec <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006258:	0921                	addi	s2,s2,8
    8000625a:	fe9918e3          	bne	s2,s1,8000624a <sys_exec+0xaa>
  return -1;
    8000625e:	557d                	li	a0,-1
    80006260:	a889                	j	800062b2 <sys_exec+0x112>
      argv[i] = 0;
    80006262:	0a8e                	slli	s5,s5,0x3
    80006264:	fc040793          	addi	a5,s0,-64
    80006268:	9abe                	add	s5,s5,a5
    8000626a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000626e:	e4040593          	addi	a1,s0,-448
    80006272:	f4040513          	addi	a0,s0,-192
    80006276:	fffff097          	auipc	ra,0xfffff
    8000627a:	182080e7          	jalr	386(ra) # 800053f8 <exec>
    8000627e:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006280:	10090993          	addi	s3,s2,256
    80006284:	00093503          	ld	a0,0(s2)
    80006288:	c901                	beqz	a0,80006298 <sys_exec+0xf8>
    kfree(argv[i]);
    8000628a:	ffffb097          	auipc	ra,0xffffb
    8000628e:	862080e7          	jalr	-1950(ra) # 80000aec <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006292:	0921                	addi	s2,s2,8
    80006294:	ff3918e3          	bne	s2,s3,80006284 <sys_exec+0xe4>
  return ret;
    80006298:	8526                	mv	a0,s1
    8000629a:	a821                	j	800062b2 <sys_exec+0x112>
      panic("sys_exec kalloc");
    8000629c:	00003517          	auipc	a0,0x3
    800062a0:	a2c50513          	addi	a0,a0,-1492 # 80008cc8 <userret+0xc38>
    800062a4:	ffffa097          	auipc	ra,0xffffa
    800062a8:	4b2080e7          	jalr	1202(ra) # 80000756 <panic>
  return -1;
    800062ac:	557d                	li	a0,-1
    800062ae:	a011                	j	800062b2 <sys_exec+0x112>
    return -1;
    800062b0:	557d                	li	a0,-1
}
    800062b2:	60be                	ld	ra,456(sp)
    800062b4:	641e                	ld	s0,448(sp)
    800062b6:	74fa                	ld	s1,440(sp)
    800062b8:	795a                	ld	s2,432(sp)
    800062ba:	79ba                	ld	s3,424(sp)
    800062bc:	7a1a                	ld	s4,416(sp)
    800062be:	6afa                	ld	s5,408(sp)
    800062c0:	6179                	addi	sp,sp,464
    800062c2:	8082                	ret
    return -1;
    800062c4:	557d                	li	a0,-1
    800062c6:	b7f5                	j	800062b2 <sys_exec+0x112>

00000000800062c8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800062c8:	7139                	addi	sp,sp,-64
    800062ca:	fc06                	sd	ra,56(sp)
    800062cc:	f822                	sd	s0,48(sp)
    800062ce:	f426                	sd	s1,40(sp)
    800062d0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800062d2:	ffffc097          	auipc	ra,0xffffc
    800062d6:	cca080e7          	jalr	-822(ra) # 80001f9c <myproc>
    800062da:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800062dc:	fd840593          	addi	a1,s0,-40
    800062e0:	4501                	li	a0,0
    800062e2:	ffffd097          	auipc	ra,0xffffd
    800062e6:	fa8080e7          	jalr	-88(ra) # 8000328a <argaddr>
    return -1;
    800062ea:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800062ec:	0e054063          	bltz	a0,800063cc <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800062f0:	fc840593          	addi	a1,s0,-56
    800062f4:	fd040513          	addi	a0,s0,-48
    800062f8:	fffff097          	auipc	ra,0xfffff
    800062fc:	db2080e7          	jalr	-590(ra) # 800050aa <pipealloc>
    return -1;
    80006300:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006302:	0c054563          	bltz	a0,800063cc <sys_pipe+0x104>
  fd0 = -1;
    80006306:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000630a:	fd043503          	ld	a0,-48(s0)
    8000630e:	fffff097          	auipc	ra,0xfffff
    80006312:	4d2080e7          	jalr	1234(ra) # 800057e0 <fdalloc>
    80006316:	fca42223          	sw	a0,-60(s0)
    8000631a:	08054c63          	bltz	a0,800063b2 <sys_pipe+0xea>
    8000631e:	fc843503          	ld	a0,-56(s0)
    80006322:	fffff097          	auipc	ra,0xfffff
    80006326:	4be080e7          	jalr	1214(ra) # 800057e0 <fdalloc>
    8000632a:	fca42023          	sw	a0,-64(s0)
    8000632e:	06054863          	bltz	a0,8000639e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006332:	4691                	li	a3,4
    80006334:	fc440613          	addi	a2,s0,-60
    80006338:	fd843583          	ld	a1,-40(s0)
    8000633c:	74a8                	ld	a0,104(s1)
    8000633e:	ffffc097          	auipc	ra,0xffffc
    80006342:	860080e7          	jalr	-1952(ra) # 80001b9e <copyout>
    80006346:	02054063          	bltz	a0,80006366 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000634a:	4691                	li	a3,4
    8000634c:	fc040613          	addi	a2,s0,-64
    80006350:	fd843583          	ld	a1,-40(s0)
    80006354:	0591                	addi	a1,a1,4
    80006356:	74a8                	ld	a0,104(s1)
    80006358:	ffffc097          	auipc	ra,0xffffc
    8000635c:	846080e7          	jalr	-1978(ra) # 80001b9e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006360:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006362:	06055563          	bgez	a0,800063cc <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006366:	fc442783          	lw	a5,-60(s0)
    8000636a:	07f1                	addi	a5,a5,28
    8000636c:	078e                	slli	a5,a5,0x3
    8000636e:	97a6                	add	a5,a5,s1
    80006370:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006374:	fc042503          	lw	a0,-64(s0)
    80006378:	0571                	addi	a0,a0,28
    8000637a:	050e                	slli	a0,a0,0x3
    8000637c:	9526                	add	a0,a0,s1
    8000637e:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006382:	fd043503          	ld	a0,-48(s0)
    80006386:	fffff097          	auipc	ra,0xfffff
    8000638a:	9c0080e7          	jalr	-1600(ra) # 80004d46 <fileclose>
    fileclose(wf);
    8000638e:	fc843503          	ld	a0,-56(s0)
    80006392:	fffff097          	auipc	ra,0xfffff
    80006396:	9b4080e7          	jalr	-1612(ra) # 80004d46 <fileclose>
    return -1;
    8000639a:	57fd                	li	a5,-1
    8000639c:	a805                	j	800063cc <sys_pipe+0x104>
    if(fd0 >= 0)
    8000639e:	fc442783          	lw	a5,-60(s0)
    800063a2:	0007c863          	bltz	a5,800063b2 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800063a6:	01c78513          	addi	a0,a5,28
    800063aa:	050e                	slli	a0,a0,0x3
    800063ac:	9526                	add	a0,a0,s1
    800063ae:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    800063b2:	fd043503          	ld	a0,-48(s0)
    800063b6:	fffff097          	auipc	ra,0xfffff
    800063ba:	990080e7          	jalr	-1648(ra) # 80004d46 <fileclose>
    fileclose(wf);
    800063be:	fc843503          	ld	a0,-56(s0)
    800063c2:	fffff097          	auipc	ra,0xfffff
    800063c6:	984080e7          	jalr	-1660(ra) # 80004d46 <fileclose>
    return -1;
    800063ca:	57fd                	li	a5,-1
}
    800063cc:	853e                	mv	a0,a5
    800063ce:	70e2                	ld	ra,56(sp)
    800063d0:	7442                	ld	s0,48(sp)
    800063d2:	74a2                	ld	s1,40(sp)
    800063d4:	6121                	addi	sp,sp,64
    800063d6:	8082                	ret

00000000800063d8 <sys_create_mutex>:

uint64
sys_create_mutex(void)
{
    800063d8:	1141                	addi	sp,sp,-16
    800063da:	e422                	sd	s0,8(sp)
    800063dc:	0800                	addi	s0,sp,16
  return -1;
}
    800063de:	557d                	li	a0,-1
    800063e0:	6422                	ld	s0,8(sp)
    800063e2:	0141                	addi	sp,sp,16
    800063e4:	8082                	ret

00000000800063e6 <sys_acquire_mutex>:

uint64
sys_acquire_mutex(void)
{
    800063e6:	1141                	addi	sp,sp,-16
    800063e8:	e422                	sd	s0,8(sp)
    800063ea:	0800                	addi	s0,sp,16
  return 0;
}
    800063ec:	4501                	li	a0,0
    800063ee:	6422                	ld	s0,8(sp)
    800063f0:	0141                	addi	sp,sp,16
    800063f2:	8082                	ret

00000000800063f4 <sys_release_mutex>:

uint64
sys_release_mutex(void)
{
    800063f4:	1141                	addi	sp,sp,-16
    800063f6:	e422                	sd	s0,8(sp)
    800063f8:	0800                	addi	s0,sp,16

  return 0;
}
    800063fa:	4501                	li	a0,0
    800063fc:	6422                	ld	s0,8(sp)
    800063fe:	0141                	addi	sp,sp,16
    80006400:	8082                	ret
	...

0000000080006410 <kernelvec>:
    80006410:	7111                	addi	sp,sp,-256
    80006412:	e006                	sd	ra,0(sp)
    80006414:	e40a                	sd	sp,8(sp)
    80006416:	e80e                	sd	gp,16(sp)
    80006418:	ec12                	sd	tp,24(sp)
    8000641a:	f016                	sd	t0,32(sp)
    8000641c:	f41a                	sd	t1,40(sp)
    8000641e:	f81e                	sd	t2,48(sp)
    80006420:	fc22                	sd	s0,56(sp)
    80006422:	e0a6                	sd	s1,64(sp)
    80006424:	e4aa                	sd	a0,72(sp)
    80006426:	e8ae                	sd	a1,80(sp)
    80006428:	ecb2                	sd	a2,88(sp)
    8000642a:	f0b6                	sd	a3,96(sp)
    8000642c:	f4ba                	sd	a4,104(sp)
    8000642e:	f8be                	sd	a5,112(sp)
    80006430:	fcc2                	sd	a6,120(sp)
    80006432:	e146                	sd	a7,128(sp)
    80006434:	e54a                	sd	s2,136(sp)
    80006436:	e94e                	sd	s3,144(sp)
    80006438:	ed52                	sd	s4,152(sp)
    8000643a:	f156                	sd	s5,160(sp)
    8000643c:	f55a                	sd	s6,168(sp)
    8000643e:	f95e                	sd	s7,176(sp)
    80006440:	fd62                	sd	s8,184(sp)
    80006442:	e1e6                	sd	s9,192(sp)
    80006444:	e5ea                	sd	s10,200(sp)
    80006446:	e9ee                	sd	s11,208(sp)
    80006448:	edf2                	sd	t3,216(sp)
    8000644a:	f1f6                	sd	t4,224(sp)
    8000644c:	f5fa                	sd	t5,232(sp)
    8000644e:	f9fe                	sd	t6,240(sp)
    80006450:	c3ffc0ef          	jal	ra,8000308e <kerneltrap>
    80006454:	6082                	ld	ra,0(sp)
    80006456:	6122                	ld	sp,8(sp)
    80006458:	61c2                	ld	gp,16(sp)
    8000645a:	7282                	ld	t0,32(sp)
    8000645c:	7322                	ld	t1,40(sp)
    8000645e:	73c2                	ld	t2,48(sp)
    80006460:	7462                	ld	s0,56(sp)
    80006462:	6486                	ld	s1,64(sp)
    80006464:	6526                	ld	a0,72(sp)
    80006466:	65c6                	ld	a1,80(sp)
    80006468:	6666                	ld	a2,88(sp)
    8000646a:	7686                	ld	a3,96(sp)
    8000646c:	7726                	ld	a4,104(sp)
    8000646e:	77c6                	ld	a5,112(sp)
    80006470:	7866                	ld	a6,120(sp)
    80006472:	688a                	ld	a7,128(sp)
    80006474:	692a                	ld	s2,136(sp)
    80006476:	69ca                	ld	s3,144(sp)
    80006478:	6a6a                	ld	s4,152(sp)
    8000647a:	7a8a                	ld	s5,160(sp)
    8000647c:	7b2a                	ld	s6,168(sp)
    8000647e:	7bca                	ld	s7,176(sp)
    80006480:	7c6a                	ld	s8,184(sp)
    80006482:	6c8e                	ld	s9,192(sp)
    80006484:	6d2e                	ld	s10,200(sp)
    80006486:	6dce                	ld	s11,208(sp)
    80006488:	6e6e                	ld	t3,216(sp)
    8000648a:	7e8e                	ld	t4,224(sp)
    8000648c:	7f2e                	ld	t5,232(sp)
    8000648e:	7fce                	ld	t6,240(sp)
    80006490:	6111                	addi	sp,sp,256
    80006492:	10200073          	sret
    80006496:	00000013          	nop
    8000649a:	00000013          	nop
    8000649e:	0001                	nop

00000000800064a0 <timervec>:
    800064a0:	34051573          	csrrw	a0,mscratch,a0
    800064a4:	e10c                	sd	a1,0(a0)
    800064a6:	e510                	sd	a2,8(a0)
    800064a8:	e914                	sd	a3,16(a0)
    800064aa:	710c                	ld	a1,32(a0)
    800064ac:	7510                	ld	a2,40(a0)
    800064ae:	6194                	ld	a3,0(a1)
    800064b0:	96b2                	add	a3,a3,a2
    800064b2:	e194                	sd	a3,0(a1)
    800064b4:	4589                	li	a1,2
    800064b6:	14459073          	csrw	sip,a1
    800064ba:	6914                	ld	a3,16(a0)
    800064bc:	6510                	ld	a2,8(a0)
    800064be:	610c                	ld	a1,0(a0)
    800064c0:	34051573          	csrrw	a0,mscratch,a0
    800064c4:	30200073          	mret
	...

00000000800064ca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800064ca:	1141                	addi	sp,sp,-16
    800064cc:	e422                	sd	s0,8(sp)
    800064ce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800064d0:	0c0007b7          	lui	a5,0xc000
    800064d4:	4705                	li	a4,1
    800064d6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800064d8:	c3d8                	sw	a4,4(a5)
}
    800064da:	6422                	ld	s0,8(sp)
    800064dc:	0141                	addi	sp,sp,16
    800064de:	8082                	ret

00000000800064e0 <plicinithart>:

void
plicinithart(void)
{
    800064e0:	1141                	addi	sp,sp,-16
    800064e2:	e406                	sd	ra,8(sp)
    800064e4:	e022                	sd	s0,0(sp)
    800064e6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064e8:	ffffc097          	auipc	ra,0xffffc
    800064ec:	a88080e7          	jalr	-1400(ra) # 80001f70 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800064f0:	0085171b          	slliw	a4,a0,0x8
    800064f4:	0c0027b7          	lui	a5,0xc002
    800064f8:	97ba                	add	a5,a5,a4
    800064fa:	40200713          	li	a4,1026
    800064fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006502:	00d5151b          	slliw	a0,a0,0xd
    80006506:	0c2017b7          	lui	a5,0xc201
    8000650a:	953e                	add	a0,a0,a5
    8000650c:	00052023          	sw	zero,0(a0)
}
    80006510:	60a2                	ld	ra,8(sp)
    80006512:	6402                	ld	s0,0(sp)
    80006514:	0141                	addi	sp,sp,16
    80006516:	8082                	ret

0000000080006518 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006518:	1141                	addi	sp,sp,-16
    8000651a:	e406                	sd	ra,8(sp)
    8000651c:	e022                	sd	s0,0(sp)
    8000651e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006520:	ffffc097          	auipc	ra,0xffffc
    80006524:	a50080e7          	jalr	-1456(ra) # 80001f70 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006528:	00d5179b          	slliw	a5,a0,0xd
    8000652c:	0c201537          	lui	a0,0xc201
    80006530:	953e                	add	a0,a0,a5
  return irq;
}
    80006532:	4148                	lw	a0,4(a0)
    80006534:	60a2                	ld	ra,8(sp)
    80006536:	6402                	ld	s0,0(sp)
    80006538:	0141                	addi	sp,sp,16
    8000653a:	8082                	ret

000000008000653c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000653c:	1101                	addi	sp,sp,-32
    8000653e:	ec06                	sd	ra,24(sp)
    80006540:	e822                	sd	s0,16(sp)
    80006542:	e426                	sd	s1,8(sp)
    80006544:	1000                	addi	s0,sp,32
    80006546:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006548:	ffffc097          	auipc	ra,0xffffc
    8000654c:	a28080e7          	jalr	-1496(ra) # 80001f70 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006550:	00d5151b          	slliw	a0,a0,0xd
    80006554:	0c2017b7          	lui	a5,0xc201
    80006558:	97aa                	add	a5,a5,a0
    8000655a:	c3c4                	sw	s1,4(a5)
}
    8000655c:	60e2                	ld	ra,24(sp)
    8000655e:	6442                	ld	s0,16(sp)
    80006560:	64a2                	ld	s1,8(sp)
    80006562:	6105                	addi	sp,sp,32
    80006564:	8082                	ret

0000000080006566 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006566:	1141                	addi	sp,sp,-16
    80006568:	e406                	sd	ra,8(sp)
    8000656a:	e022                	sd	s0,0(sp)
    8000656c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000656e:	479d                	li	a5,7
    80006570:	06b7c963          	blt	a5,a1,800065e2 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006574:	00151793          	slli	a5,a0,0x1
    80006578:	97aa                	add	a5,a5,a0
    8000657a:	00c79713          	slli	a4,a5,0xc
    8000657e:	00022797          	auipc	a5,0x22
    80006582:	a8278793          	addi	a5,a5,-1406 # 80028000 <disk>
    80006586:	97ba                	add	a5,a5,a4
    80006588:	97ae                	add	a5,a5,a1
    8000658a:	6709                	lui	a4,0x2
    8000658c:	97ba                	add	a5,a5,a4
    8000658e:	0187c783          	lbu	a5,24(a5)
    80006592:	e3a5                	bnez	a5,800065f2 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006594:	00022817          	auipc	a6,0x22
    80006598:	a6c80813          	addi	a6,a6,-1428 # 80028000 <disk>
    8000659c:	00151693          	slli	a3,a0,0x1
    800065a0:	00a68733          	add	a4,a3,a0
    800065a4:	0732                	slli	a4,a4,0xc
    800065a6:	00e807b3          	add	a5,a6,a4
    800065aa:	6709                	lui	a4,0x2
    800065ac:	00f70633          	add	a2,a4,a5
    800065b0:	6210                	ld	a2,0(a2)
    800065b2:	00459893          	slli	a7,a1,0x4
    800065b6:	9646                	add	a2,a2,a7
    800065b8:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    800065bc:	97ae                	add	a5,a5,a1
    800065be:	97ba                	add	a5,a5,a4
    800065c0:	4605                	li	a2,1
    800065c2:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    800065c6:	96aa                	add	a3,a3,a0
    800065c8:	06b2                	slli	a3,a3,0xc
    800065ca:	0761                	addi	a4,a4,24
    800065cc:	96ba                	add	a3,a3,a4
    800065ce:	00d80533          	add	a0,a6,a3
    800065d2:	ffffc097          	auipc	ra,0xffffc
    800065d6:	3d6080e7          	jalr	982(ra) # 800029a8 <wakeup>
}
    800065da:	60a2                	ld	ra,8(sp)
    800065dc:	6402                	ld	s0,0(sp)
    800065de:	0141                	addi	sp,sp,16
    800065e0:	8082                	ret
    panic("virtio_disk_intr 1");
    800065e2:	00002517          	auipc	a0,0x2
    800065e6:	6f650513          	addi	a0,a0,1782 # 80008cd8 <userret+0xc48>
    800065ea:	ffffa097          	auipc	ra,0xffffa
    800065ee:	16c080e7          	jalr	364(ra) # 80000756 <panic>
    panic("virtio_disk_intr 2");
    800065f2:	00002517          	auipc	a0,0x2
    800065f6:	6fe50513          	addi	a0,a0,1790 # 80008cf0 <userret+0xc60>
    800065fa:	ffffa097          	auipc	ra,0xffffa
    800065fe:	15c080e7          	jalr	348(ra) # 80000756 <panic>

0000000080006602 <virtio_disk_init>:
  __sync_synchronize();
    80006602:	0ff0000f          	fence
  if(disk[n].init)
    80006606:	00151793          	slli	a5,a0,0x1
    8000660a:	97aa                	add	a5,a5,a0
    8000660c:	07b2                	slli	a5,a5,0xc
    8000660e:	00022717          	auipc	a4,0x22
    80006612:	9f270713          	addi	a4,a4,-1550 # 80028000 <disk>
    80006616:	973e                	add	a4,a4,a5
    80006618:	6789                	lui	a5,0x2
    8000661a:	97ba                	add	a5,a5,a4
    8000661c:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80006620:	c391                	beqz	a5,80006624 <virtio_disk_init+0x22>
    80006622:	8082                	ret
{
    80006624:	7139                	addi	sp,sp,-64
    80006626:	fc06                	sd	ra,56(sp)
    80006628:	f822                	sd	s0,48(sp)
    8000662a:	f426                	sd	s1,40(sp)
    8000662c:	f04a                	sd	s2,32(sp)
    8000662e:	ec4e                	sd	s3,24(sp)
    80006630:	e852                	sd	s4,16(sp)
    80006632:	e456                	sd	s5,8(sp)
    80006634:	0080                	addi	s0,sp,64
    80006636:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80006638:	85aa                	mv	a1,a0
    8000663a:	00002517          	auipc	a0,0x2
    8000663e:	6ce50513          	addi	a0,a0,1742 # 80008d08 <userret+0xc78>
    80006642:	ffffa097          	auipc	ra,0xffffa
    80006646:	32a080e7          	jalr	810(ra) # 8000096c <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    8000664a:	00149993          	slli	s3,s1,0x1
    8000664e:	99a6                	add	s3,s3,s1
    80006650:	09b2                	slli	s3,s3,0xc
    80006652:	6789                	lui	a5,0x2
    80006654:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006658:	97ce                	add	a5,a5,s3
    8000665a:	00002597          	auipc	a1,0x2
    8000665e:	6c658593          	addi	a1,a1,1734 # 80008d20 <userret+0xc90>
    80006662:	00022517          	auipc	a0,0x22
    80006666:	99e50513          	addi	a0,a0,-1634 # 80028000 <disk>
    8000666a:	953e                	add	a0,a0,a5
    8000666c:	ffffa097          	auipc	ra,0xffffa
    80006670:	4b2080e7          	jalr	1202(ra) # 80000b1e <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006674:	0014891b          	addiw	s2,s1,1
    80006678:	00c9191b          	slliw	s2,s2,0xc
    8000667c:	100007b7          	lui	a5,0x10000
    80006680:	97ca                	add	a5,a5,s2
    80006682:	4398                	lw	a4,0(a5)
    80006684:	2701                	sext.w	a4,a4
    80006686:	747277b7          	lui	a5,0x74727
    8000668a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000668e:	12f71863          	bne	a4,a5,800067be <virtio_disk_init+0x1bc>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006692:	100007b7          	lui	a5,0x10000
    80006696:	0791                	addi	a5,a5,4
    80006698:	97ca                	add	a5,a5,s2
    8000669a:	439c                	lw	a5,0(a5)
    8000669c:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000669e:	4705                	li	a4,1
    800066a0:	10e79f63          	bne	a5,a4,800067be <virtio_disk_init+0x1bc>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066a4:	100007b7          	lui	a5,0x10000
    800066a8:	07a1                	addi	a5,a5,8
    800066aa:	97ca                	add	a5,a5,s2
    800066ac:	439c                	lw	a5,0(a5)
    800066ae:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800066b0:	4709                	li	a4,2
    800066b2:	10e79663          	bne	a5,a4,800067be <virtio_disk_init+0x1bc>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800066b6:	100007b7          	lui	a5,0x10000
    800066ba:	07b1                	addi	a5,a5,12
    800066bc:	97ca                	add	a5,a5,s2
    800066be:	4398                	lw	a4,0(a5)
    800066c0:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800066c2:	554d47b7          	lui	a5,0x554d4
    800066c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800066ca:	0ef71a63          	bne	a4,a5,800067be <virtio_disk_init+0x1bc>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800066ce:	100007b7          	lui	a5,0x10000
    800066d2:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    800066d6:	96ca                	add	a3,a3,s2
    800066d8:	4705                	li	a4,1
    800066da:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800066dc:	470d                	li	a4,3
    800066de:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800066e0:	01078713          	addi	a4,a5,16
    800066e4:	974a                	add	a4,a4,s2
    800066e6:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800066e8:	02078613          	addi	a2,a5,32
    800066ec:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800066ee:	c7ffe737          	lui	a4,0xc7ffe
    800066f2:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd06b3>
    800066f6:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800066f8:	2701                	sext.w	a4,a4
    800066fa:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800066fc:	472d                	li	a4,11
    800066fe:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006700:	473d                	li	a4,15
    80006702:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006704:	02878713          	addi	a4,a5,40
    80006708:	974a                	add	a4,a4,s2
    8000670a:	6685                	lui	a3,0x1
    8000670c:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000670e:	03078713          	addi	a4,a5,48
    80006712:	974a                	add	a4,a4,s2
    80006714:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006718:	03478793          	addi	a5,a5,52
    8000671c:	97ca                	add	a5,a5,s2
    8000671e:	439c                	lw	a5,0(a5)
    80006720:	2781                	sext.w	a5,a5
  if(max == 0)
    80006722:	c7d5                	beqz	a5,800067ce <virtio_disk_init+0x1cc>
  if(max < NUM)
    80006724:	471d                	li	a4,7
    80006726:	0af77c63          	bgeu	a4,a5,800067de <virtio_disk_init+0x1dc>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000672a:	10000ab7          	lui	s5,0x10000
    8000672e:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006732:	97ca                	add	a5,a5,s2
    80006734:	4721                	li	a4,8
    80006736:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006738:	00022a17          	auipc	s4,0x22
    8000673c:	8c8a0a13          	addi	s4,s4,-1848 # 80028000 <disk>
    80006740:	99d2                	add	s3,s3,s4
    80006742:	6609                	lui	a2,0x2
    80006744:	4581                	li	a1,0
    80006746:	854e                	mv	a0,s3
    80006748:	ffffb097          	auipc	ra,0xffffb
    8000674c:	98c080e7          	jalr	-1652(ra) # 800010d4 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80006750:	040a8a93          	addi	s5,s5,64
    80006754:	9956                	add	s2,s2,s5
    80006756:	00c9d793          	srli	a5,s3,0xc
    8000675a:	2781                	sext.w	a5,a5
    8000675c:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80006760:	00149513          	slli	a0,s1,0x1
    80006764:	009507b3          	add	a5,a0,s1
    80006768:	07b2                	slli	a5,a5,0xc
    8000676a:	97d2                	add	a5,a5,s4
    8000676c:	6689                	lui	a3,0x2
    8000676e:	97b6                	add	a5,a5,a3
    80006770:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006774:	08098713          	addi	a4,s3,128
    80006778:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    8000677a:	6705                	lui	a4,0x1
    8000677c:	99ba                	add	s3,s3,a4
    8000677e:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006782:	4705                	li	a4,1
    80006784:	00e78c23          	sb	a4,24(a5)
    80006788:	00e78ca3          	sb	a4,25(a5)
    8000678c:	00e78d23          	sb	a4,26(a5)
    80006790:	00e78da3          	sb	a4,27(a5)
    80006794:	00e78e23          	sb	a4,28(a5)
    80006798:	00e78ea3          	sb	a4,29(a5)
    8000679c:	00e78f23          	sb	a4,30(a5)
    800067a0:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    800067a4:	853e                	mv	a0,a5
    800067a6:	4785                	li	a5,1
    800067a8:	0af52423          	sw	a5,168(a0)
}
    800067ac:	70e2                	ld	ra,56(sp)
    800067ae:	7442                	ld	s0,48(sp)
    800067b0:	74a2                	ld	s1,40(sp)
    800067b2:	7902                	ld	s2,32(sp)
    800067b4:	69e2                	ld	s3,24(sp)
    800067b6:	6a42                	ld	s4,16(sp)
    800067b8:	6aa2                	ld	s5,8(sp)
    800067ba:	6121                	addi	sp,sp,64
    800067bc:	8082                	ret
    panic("could not find virtio disk");
    800067be:	00002517          	auipc	a0,0x2
    800067c2:	57250513          	addi	a0,a0,1394 # 80008d30 <userret+0xca0>
    800067c6:	ffffa097          	auipc	ra,0xffffa
    800067ca:	f90080e7          	jalr	-112(ra) # 80000756 <panic>
    panic("virtio disk has no queue 0");
    800067ce:	00002517          	auipc	a0,0x2
    800067d2:	58250513          	addi	a0,a0,1410 # 80008d50 <userret+0xcc0>
    800067d6:	ffffa097          	auipc	ra,0xffffa
    800067da:	f80080e7          	jalr	-128(ra) # 80000756 <panic>
    panic("virtio disk max queue too short");
    800067de:	00002517          	auipc	a0,0x2
    800067e2:	59250513          	addi	a0,a0,1426 # 80008d70 <userret+0xce0>
    800067e6:	ffffa097          	auipc	ra,0xffffa
    800067ea:	f70080e7          	jalr	-144(ra) # 80000756 <panic>

00000000800067ee <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    800067ee:	7135                	addi	sp,sp,-160
    800067f0:	ed06                	sd	ra,152(sp)
    800067f2:	e922                	sd	s0,144(sp)
    800067f4:	e526                	sd	s1,136(sp)
    800067f6:	e14a                	sd	s2,128(sp)
    800067f8:	fcce                	sd	s3,120(sp)
    800067fa:	f8d2                	sd	s4,112(sp)
    800067fc:	f4d6                	sd	s5,104(sp)
    800067fe:	f0da                	sd	s6,96(sp)
    80006800:	ecde                	sd	s7,88(sp)
    80006802:	e8e2                	sd	s8,80(sp)
    80006804:	e4e6                	sd	s9,72(sp)
    80006806:	e0ea                	sd	s10,64(sp)
    80006808:	fc6e                	sd	s11,56(sp)
    8000680a:	1100                	addi	s0,sp,160
    8000680c:	892a                	mv	s2,a0
    8000680e:	89ae                	mv	s3,a1
    80006810:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80006812:	45dc                	lw	a5,12(a1)
    80006814:	0017979b          	slliw	a5,a5,0x1
    80006818:	1782                	slli	a5,a5,0x20
    8000681a:	9381                	srli	a5,a5,0x20
    8000681c:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    80006820:	00151493          	slli	s1,a0,0x1
    80006824:	94aa                	add	s1,s1,a0
    80006826:	04b2                	slli	s1,s1,0xc
    80006828:	6a89                	lui	s5,0x2
    8000682a:	0b0a8a13          	addi	s4,s5,176 # 20b0 <_entry-0x7fffdf50>
    8000682e:	9a26                	add	s4,s4,s1
    80006830:	00021b97          	auipc	s7,0x21
    80006834:	7d0b8b93          	addi	s7,s7,2000 # 80028000 <disk>
    80006838:	9a5e                	add	s4,s4,s7
    8000683a:	8552                	mv	a0,s4
    8000683c:	ffffa097          	auipc	ra,0xffffa
    80006840:	44c080e7          	jalr	1100(ra) # 80000c88 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006844:	0ae1                	addi	s5,s5,24
    80006846:	94d6                	add	s1,s1,s5
    80006848:	01748ab3          	add	s5,s1,s7
    8000684c:	8d56                	mv	s10,s5
  for(int i = 0; i < 3; i++){
    8000684e:	4b81                	li	s7,0
  for(int i = 0; i < NUM; i++){
    80006850:	4ca1                	li	s9,8
      disk[n].free[i] = 0;
    80006852:	00191b13          	slli	s6,s2,0x1
    80006856:	9b4a                	add	s6,s6,s2
    80006858:	00cb1793          	slli	a5,s6,0xc
    8000685c:	00021b17          	auipc	s6,0x21
    80006860:	7a4b0b13          	addi	s6,s6,1956 # 80028000 <disk>
    80006864:	9b3e                	add	s6,s6,a5
  for(int i = 0; i < NUM; i++){
    80006866:	8c5e                	mv	s8,s7
    80006868:	a8ad                	j	800068e2 <virtio_disk_rw+0xf4>
      disk[n].free[i] = 0;
    8000686a:	00fb06b3          	add	a3,s6,a5
    8000686e:	96aa                	add	a3,a3,a0
    80006870:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    80006874:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006876:	0207c363          	bltz	a5,8000689c <virtio_disk_rw+0xae>
  for(int i = 0; i < 3; i++){
    8000687a:	2485                	addiw	s1,s1,1
    8000687c:	0711                	addi	a4,a4,4
    8000687e:	26b48f63          	beq	s1,a1,80006afc <virtio_disk_rw+0x30e>
    idx[i] = alloc_desc(n);
    80006882:	863a                	mv	a2,a4
    80006884:	86ea                	mv	a3,s10
  for(int i = 0; i < NUM; i++){
    80006886:	87e2                	mv	a5,s8
    if(disk[n].free[i]){
    80006888:	0006c803          	lbu	a6,0(a3)
    8000688c:	fc081fe3          	bnez	a6,8000686a <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    80006890:	2785                	addiw	a5,a5,1
    80006892:	0685                	addi	a3,a3,1
    80006894:	ff979ae3          	bne	a5,s9,80006888 <virtio_disk_rw+0x9a>
    idx[i] = alloc_desc(n);
    80006898:	57fd                	li	a5,-1
    8000689a:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000689c:	02905d63          	blez	s1,800068d6 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800068a0:	f8042583          	lw	a1,-128(s0)
    800068a4:	854a                	mv	a0,s2
    800068a6:	00000097          	auipc	ra,0x0
    800068aa:	cc0080e7          	jalr	-832(ra) # 80006566 <free_desc>
      for(int j = 0; j < i; j++)
    800068ae:	4785                	li	a5,1
    800068b0:	0297d363          	bge	a5,s1,800068d6 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800068b4:	f8442583          	lw	a1,-124(s0)
    800068b8:	854a                	mv	a0,s2
    800068ba:	00000097          	auipc	ra,0x0
    800068be:	cac080e7          	jalr	-852(ra) # 80006566 <free_desc>
      for(int j = 0; j < i; j++)
    800068c2:	4789                	li	a5,2
    800068c4:	0097d963          	bge	a5,s1,800068d6 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800068c8:	f8842583          	lw	a1,-120(s0)
    800068cc:	854a                	mv	a0,s2
    800068ce:	00000097          	auipc	ra,0x0
    800068d2:	c98080e7          	jalr	-872(ra) # 80006566 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800068d6:	85d2                	mv	a1,s4
    800068d8:	8556                	mv	a0,s5
    800068da:	ffffc097          	auipc	ra,0xffffc
    800068de:	f48080e7          	jalr	-184(ra) # 80002822 <sleep>
  for(int i = 0; i < 3; i++){
    800068e2:	f8040713          	addi	a4,s0,-128
    800068e6:	84de                	mv	s1,s7
      disk[n].free[i] = 0;
    800068e8:	6509                	lui	a0,0x2
  for(int i = 0; i < 3; i++){
    800068ea:	458d                	li	a1,3
    800068ec:	bf59                	j	80006882 <virtio_disk_rw+0x94>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    800068ee:	4785                	li	a5,1
    800068f0:	f6f42823          	sw	a5,-144(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    800068f4:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    800068f8:	f6843783          	ld	a5,-152(s0)
    800068fc:	f6f43c23          	sd	a5,-136(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006900:	f8042483          	lw	s1,-128(s0)
    80006904:	00449b13          	slli	s6,s1,0x4
    80006908:	00191793          	slli	a5,s2,0x1
    8000690c:	97ca                	add	a5,a5,s2
    8000690e:	07b2                	slli	a5,a5,0xc
    80006910:	00021a97          	auipc	s5,0x21
    80006914:	6f0a8a93          	addi	s5,s5,1776 # 80028000 <disk>
    80006918:	97d6                	add	a5,a5,s5
    8000691a:	6a89                	lui	s5,0x2
    8000691c:	9abe                	add	s5,s5,a5
    8000691e:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    80006922:	9bda                	add	s7,s7,s6
    80006924:	f7040513          	addi	a0,s0,-144
    80006928:	ffffb097          	auipc	ra,0xffffb
    8000692c:	cd6080e7          	jalr	-810(ra) # 800015fe <kvmpa>
    80006930:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006934:	000ab783          	ld	a5,0(s5)
    80006938:	97da                	add	a5,a5,s6
    8000693a:	4741                	li	a4,16
    8000693c:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000693e:	000ab783          	ld	a5,0(s5)
    80006942:	97da                	add	a5,a5,s6
    80006944:	4705                	li	a4,1
    80006946:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    8000694a:	f8442683          	lw	a3,-124(s0)
    8000694e:	000ab783          	ld	a5,0(s5)
    80006952:	9b3e                	add	s6,s6,a5
    80006954:	00db1723          	sh	a3,14(s6)

  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006958:	0692                	slli	a3,a3,0x4
    8000695a:	000ab783          	ld	a5,0(s5)
    8000695e:	97b6                	add	a5,a5,a3
    80006960:	07098713          	addi	a4,s3,112
    80006964:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006966:	000ab783          	ld	a5,0(s5)
    8000696a:	97b6                	add	a5,a5,a3
    8000696c:	40000713          	li	a4,1024
    80006970:	c798                	sw	a4,8(a5)
  if(write)
    80006972:	140d8063          	beqz	s11,80006ab2 <virtio_disk_rw+0x2c4>
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006976:	000ab783          	ld	a5,0(s5)
    8000697a:	97b6                	add	a5,a5,a3
    8000697c:	00079623          	sh	zero,12(a5)
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006980:	00021517          	auipc	a0,0x21
    80006984:	68050513          	addi	a0,a0,1664 # 80028000 <disk>
    80006988:	00191793          	slli	a5,s2,0x1
    8000698c:	01278733          	add	a4,a5,s2
    80006990:	0732                	slli	a4,a4,0xc
    80006992:	972a                	add	a4,a4,a0
    80006994:	6609                	lui	a2,0x2
    80006996:	9732                	add	a4,a4,a2
    80006998:	630c                	ld	a1,0(a4)
    8000699a:	95b6                	add	a1,a1,a3
    8000699c:	00c5d603          	lhu	a2,12(a1)
    800069a0:	00166613          	ori	a2,a2,1
    800069a4:	00c59623          	sh	a2,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    800069a8:	f8842603          	lw	a2,-120(s0)
    800069ac:	630c                	ld	a1,0(a4)
    800069ae:	96ae                	add	a3,a3,a1
    800069b0:	00c69723          	sh	a2,14(a3)

  disk[n].info[idx[0]].status = 0;
    800069b4:	97ca                	add	a5,a5,s2
    800069b6:	07a2                	slli	a5,a5,0x8
    800069b8:	97a6                	add	a5,a5,s1
    800069ba:	20078793          	addi	a5,a5,512
    800069be:	0792                	slli	a5,a5,0x4
    800069c0:	97aa                	add	a5,a5,a0
    800069c2:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    800069c6:	00461693          	slli	a3,a2,0x4
    800069ca:	00073803          	ld	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800069ce:	9836                	add	a6,a6,a3
    800069d0:	20348613          	addi	a2,s1,515
    800069d4:	00191593          	slli	a1,s2,0x1
    800069d8:	95ca                	add	a1,a1,s2
    800069da:	05a2                	slli	a1,a1,0x8
    800069dc:	962e                	add	a2,a2,a1
    800069de:	0612                	slli	a2,a2,0x4
    800069e0:	962a                	add	a2,a2,a0
    800069e2:	00c83023          	sd	a2,0(a6)
  disk[n].desc[idx[2]].len = 1;
    800069e6:	6310                	ld	a2,0(a4)
    800069e8:	9636                	add	a2,a2,a3
    800069ea:	4585                	li	a1,1
    800069ec:	c60c                	sw	a1,8(a2)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800069ee:	6310                	ld	a2,0(a4)
    800069f0:	9636                	add	a2,a2,a3
    800069f2:	4509                	li	a0,2
    800069f4:	00a61623          	sh	a0,12(a2) # 200c <_entry-0x7fffdff4>
  disk[n].desc[idx[2]].next = 0;
    800069f8:	6310                	ld	a2,0(a4)
    800069fa:	96b2                	add	a3,a3,a2
    800069fc:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006a00:	00b9a223          	sw	a1,4(s3)
  disk[n].info[idx[0]].b = b;
    80006a04:	0337b423          	sd	s3,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    80006a08:	6714                	ld	a3,8(a4)
    80006a0a:	0026d783          	lhu	a5,2(a3)
    80006a0e:	8b9d                	andi	a5,a5,7
    80006a10:	2789                	addiw	a5,a5,2
    80006a12:	0786                	slli	a5,a5,0x1
    80006a14:	97b6                	add	a5,a5,a3
    80006a16:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80006a1a:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006a1e:	6718                	ld	a4,8(a4)
    80006a20:	00275783          	lhu	a5,2(a4)
    80006a24:	2785                	addiw	a5,a5,1
    80006a26:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006a2a:	0019079b          	addiw	a5,s2,1
    80006a2e:	00c7979b          	slliw	a5,a5,0xc
    80006a32:	10000737          	lui	a4,0x10000
    80006a36:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    80006a3a:	97ba                	add	a5,a5,a4
    80006a3c:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006a40:	0049a703          	lw	a4,4(s3)
    80006a44:	4785                	li	a5,1
    80006a46:	00f71d63          	bne	a4,a5,80006a60 <virtio_disk_rw+0x272>
    80006a4a:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    80006a4c:	85d2                	mv	a1,s4
    80006a4e:	854e                	mv	a0,s3
    80006a50:	ffffc097          	auipc	ra,0xffffc
    80006a54:	dd2080e7          	jalr	-558(ra) # 80002822 <sleep>
  while(b->disk == 1) {
    80006a58:	0049a783          	lw	a5,4(s3)
    80006a5c:	fe9788e3          	beq	a5,s1,80006a4c <virtio_disk_rw+0x25e>
  }

  disk[n].info[idx[0]].b = 0;
    80006a60:	f8042483          	lw	s1,-128(s0)
    80006a64:	00191793          	slli	a5,s2,0x1
    80006a68:	97ca                	add	a5,a5,s2
    80006a6a:	07a2                	slli	a5,a5,0x8
    80006a6c:	97a6                	add	a5,a5,s1
    80006a6e:	20078793          	addi	a5,a5,512
    80006a72:	0792                	slli	a5,a5,0x4
    80006a74:	00021717          	auipc	a4,0x21
    80006a78:	58c70713          	addi	a4,a4,1420 # 80028000 <disk>
    80006a7c:	97ba                	add	a5,a5,a4
    80006a7e:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006a82:	00191793          	slli	a5,s2,0x1
    80006a86:	97ca                	add	a5,a5,s2
    80006a88:	07b2                	slli	a5,a5,0xc
    80006a8a:	97ba                	add	a5,a5,a4
    80006a8c:	6989                	lui	s3,0x2
    80006a8e:	99be                	add	s3,s3,a5
    free_desc(n, i);
    80006a90:	85a6                	mv	a1,s1
    80006a92:	854a                	mv	a0,s2
    80006a94:	00000097          	auipc	ra,0x0
    80006a98:	ad2080e7          	jalr	-1326(ra) # 80006566 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006a9c:	0492                	slli	s1,s1,0x4
    80006a9e:	0009b783          	ld	a5,0(s3) # 2000 <_entry-0x7fffe000>
    80006aa2:	94be                	add	s1,s1,a5
    80006aa4:	00c4d783          	lhu	a5,12(s1)
    80006aa8:	8b85                	andi	a5,a5,1
    80006aaa:	c78d                	beqz	a5,80006ad4 <virtio_disk_rw+0x2e6>
      i = disk[n].desc[i].next;
    80006aac:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006ab0:	b7c5                	j	80006a90 <virtio_disk_rw+0x2a2>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006ab2:	00191793          	slli	a5,s2,0x1
    80006ab6:	97ca                	add	a5,a5,s2
    80006ab8:	07b2                	slli	a5,a5,0xc
    80006aba:	00021717          	auipc	a4,0x21
    80006abe:	54670713          	addi	a4,a4,1350 # 80028000 <disk>
    80006ac2:	973e                	add	a4,a4,a5
    80006ac4:	6789                	lui	a5,0x2
    80006ac6:	97ba                	add	a5,a5,a4
    80006ac8:	639c                	ld	a5,0(a5)
    80006aca:	97b6                	add	a5,a5,a3
    80006acc:	4709                	li	a4,2
    80006ace:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006ad2:	b57d                	j	80006980 <virtio_disk_rw+0x192>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006ad4:	8552                	mv	a0,s4
    80006ad6:	ffffa097          	auipc	ra,0xffffa
    80006ada:	3fe080e7          	jalr	1022(ra) # 80000ed4 <release>
}
    80006ade:	60ea                	ld	ra,152(sp)
    80006ae0:	644a                	ld	s0,144(sp)
    80006ae2:	64aa                	ld	s1,136(sp)
    80006ae4:	690a                	ld	s2,128(sp)
    80006ae6:	79e6                	ld	s3,120(sp)
    80006ae8:	7a46                	ld	s4,112(sp)
    80006aea:	7aa6                	ld	s5,104(sp)
    80006aec:	7b06                	ld	s6,96(sp)
    80006aee:	6be6                	ld	s7,88(sp)
    80006af0:	6c46                	ld	s8,80(sp)
    80006af2:	6ca6                	ld	s9,72(sp)
    80006af4:	6d06                	ld	s10,64(sp)
    80006af6:	7de2                	ld	s11,56(sp)
    80006af8:	610d                	addi	sp,sp,160
    80006afa:	8082                	ret
  if(write)
    80006afc:	de0d99e3          	bnez	s11,800068ee <virtio_disk_rw+0x100>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006b00:	f6042823          	sw	zero,-144(s0)
    80006b04:	bbc5                	j	800068f4 <virtio_disk_rw+0x106>

0000000080006b06 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006b06:	7139                	addi	sp,sp,-64
    80006b08:	fc06                	sd	ra,56(sp)
    80006b0a:	f822                	sd	s0,48(sp)
    80006b0c:	f426                	sd	s1,40(sp)
    80006b0e:	f04a                	sd	s2,32(sp)
    80006b10:	ec4e                	sd	s3,24(sp)
    80006b12:	e852                	sd	s4,16(sp)
    80006b14:	e456                	sd	s5,8(sp)
    80006b16:	0080                	addi	s0,sp,64
    80006b18:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006b1a:	00151913          	slli	s2,a0,0x1
    80006b1e:	00a90a33          	add	s4,s2,a0
    80006b22:	0a32                	slli	s4,s4,0xc
    80006b24:	6989                	lui	s3,0x2
    80006b26:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006b2a:	9a3e                	add	s4,s4,a5
    80006b2c:	00021a97          	auipc	s5,0x21
    80006b30:	4d4a8a93          	addi	s5,s5,1236 # 80028000 <disk>
    80006b34:	9a56                	add	s4,s4,s5
    80006b36:	8552                	mv	a0,s4
    80006b38:	ffffa097          	auipc	ra,0xffffa
    80006b3c:	150080e7          	jalr	336(ra) # 80000c88 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006b40:	9926                	add	s2,s2,s1
    80006b42:	0932                	slli	s2,s2,0xc
    80006b44:	9956                	add	s2,s2,s5
    80006b46:	99ca                	add	s3,s3,s2
    80006b48:	0209d783          	lhu	a5,32(s3)
    80006b4c:	0109b703          	ld	a4,16(s3)
    80006b50:	00275683          	lhu	a3,2(a4)
    80006b54:	8ebd                	xor	a3,a3,a5
    80006b56:	8a9d                	andi	a3,a3,7
    80006b58:	c2a5                	beqz	a3,80006bb8 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    80006b5a:	8956                	mv	s2,s5
    80006b5c:	00149693          	slli	a3,s1,0x1
    80006b60:	96a6                	add	a3,a3,s1
    80006b62:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006b66:	06b2                	slli	a3,a3,0xc
    80006b68:	96d6                	add	a3,a3,s5
    80006b6a:	6489                	lui	s1,0x2
    80006b6c:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006b6e:	078e                	slli	a5,a5,0x3
    80006b70:	97ba                	add	a5,a5,a4
    80006b72:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006b74:	00f98733          	add	a4,s3,a5
    80006b78:	20070713          	addi	a4,a4,512
    80006b7c:	0712                	slli	a4,a4,0x4
    80006b7e:	974a                	add	a4,a4,s2
    80006b80:	03074703          	lbu	a4,48(a4)
    80006b84:	eb21                	bnez	a4,80006bd4 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006b86:	97ce                	add	a5,a5,s3
    80006b88:	20078793          	addi	a5,a5,512
    80006b8c:	0792                	slli	a5,a5,0x4
    80006b8e:	97ca                	add	a5,a5,s2
    80006b90:	7798                	ld	a4,40(a5)
    80006b92:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006b96:	7788                	ld	a0,40(a5)
    80006b98:	ffffc097          	auipc	ra,0xffffc
    80006b9c:	e10080e7          	jalr	-496(ra) # 800029a8 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006ba0:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006ba4:	2785                	addiw	a5,a5,1
    80006ba6:	8b9d                	andi	a5,a5,7
    80006ba8:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006bac:	6898                	ld	a4,16(s1)
    80006bae:	00275683          	lhu	a3,2(a4)
    80006bb2:	8a9d                	andi	a3,a3,7
    80006bb4:	faf69de3          	bne	a3,a5,80006b6e <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006bb8:	8552                	mv	a0,s4
    80006bba:	ffffa097          	auipc	ra,0xffffa
    80006bbe:	31a080e7          	jalr	794(ra) # 80000ed4 <release>
}
    80006bc2:	70e2                	ld	ra,56(sp)
    80006bc4:	7442                	ld	s0,48(sp)
    80006bc6:	74a2                	ld	s1,40(sp)
    80006bc8:	7902                	ld	s2,32(sp)
    80006bca:	69e2                	ld	s3,24(sp)
    80006bcc:	6a42                	ld	s4,16(sp)
    80006bce:	6aa2                	ld	s5,8(sp)
    80006bd0:	6121                	addi	sp,sp,64
    80006bd2:	8082                	ret
      panic("virtio_disk_intr status");
    80006bd4:	00002517          	auipc	a0,0x2
    80006bd8:	1bc50513          	addi	a0,a0,444 # 80008d90 <userret+0xd00>
    80006bdc:	ffffa097          	auipc	ra,0xffffa
    80006be0:	b7a080e7          	jalr	-1158(ra) # 80000756 <panic>

0000000080006be4 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006be4:	1141                	addi	sp,sp,-16
    80006be6:	e422                	sd	s0,8(sp)
    80006be8:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80006bea:	41f5d79b          	sraiw	a5,a1,0x1f
    80006bee:	01d7d79b          	srliw	a5,a5,0x1d
    80006bf2:	9dbd                	addw	a1,a1,a5
    80006bf4:	0075f713          	andi	a4,a1,7
    80006bf8:	9f1d                	subw	a4,a4,a5
    80006bfa:	4785                	li	a5,1
    80006bfc:	00e797bb          	sllw	a5,a5,a4
    80006c00:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80006c04:	4035d59b          	sraiw	a1,a1,0x3
    80006c08:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006c0a:	0005c503          	lbu	a0,0(a1)
    80006c0e:	8d7d                	and	a0,a0,a5
    80006c10:	8d1d                	sub	a0,a0,a5
}
    80006c12:	00153513          	seqz	a0,a0
    80006c16:	6422                	ld	s0,8(sp)
    80006c18:	0141                	addi	sp,sp,16
    80006c1a:	8082                	ret

0000000080006c1c <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006c1c:	1141                	addi	sp,sp,-16
    80006c1e:	e422                	sd	s0,8(sp)
    80006c20:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006c22:	41f5d79b          	sraiw	a5,a1,0x1f
    80006c26:	01d7d79b          	srliw	a5,a5,0x1d
    80006c2a:	9dbd                	addw	a1,a1,a5
    80006c2c:	4035d71b          	sraiw	a4,a1,0x3
    80006c30:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006c32:	899d                	andi	a1,a1,7
    80006c34:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    80006c36:	4785                	li	a5,1
    80006c38:	00b795bb          	sllw	a1,a5,a1
    80006c3c:	00054783          	lbu	a5,0(a0)
    80006c40:	8ddd                	or	a1,a1,a5
    80006c42:	00b50023          	sb	a1,0(a0)
}
    80006c46:	6422                	ld	s0,8(sp)
    80006c48:	0141                	addi	sp,sp,16
    80006c4a:	8082                	ret

0000000080006c4c <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006c4c:	1141                	addi	sp,sp,-16
    80006c4e:	e422                	sd	s0,8(sp)
    80006c50:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006c52:	41f5d79b          	sraiw	a5,a1,0x1f
    80006c56:	01d7d79b          	srliw	a5,a5,0x1d
    80006c5a:	9dbd                	addw	a1,a1,a5
    80006c5c:	4035d71b          	sraiw	a4,a1,0x3
    80006c60:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006c62:	899d                	andi	a1,a1,7
    80006c64:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    80006c66:	4785                	li	a5,1
    80006c68:	00b795bb          	sllw	a1,a5,a1
    80006c6c:	fff5c593          	not	a1,a1
    80006c70:	00054783          	lbu	a5,0(a0)
    80006c74:	8dfd                	and	a1,a1,a5
    80006c76:	00b50023          	sb	a1,0(a0)
}
    80006c7a:	6422                	ld	s0,8(sp)
    80006c7c:	0141                	addi	sp,sp,16
    80006c7e:	8082                	ret

0000000080006c80 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006c80:	715d                	addi	sp,sp,-80
    80006c82:	e486                	sd	ra,72(sp)
    80006c84:	e0a2                	sd	s0,64(sp)
    80006c86:	fc26                	sd	s1,56(sp)
    80006c88:	f84a                	sd	s2,48(sp)
    80006c8a:	f44e                	sd	s3,40(sp)
    80006c8c:	f052                	sd	s4,32(sp)
    80006c8e:	ec56                	sd	s5,24(sp)
    80006c90:	e85a                	sd	s6,16(sp)
    80006c92:	e45e                	sd	s7,8(sp)
    80006c94:	0880                	addi	s0,sp,80
    80006c96:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006c98:	08b05b63          	blez	a1,80006d2e <bd_print_vector+0xae>
    80006c9c:	89aa                	mv	s3,a0
    80006c9e:	4481                	li	s1,0
  lb = 0;
    80006ca0:	4a81                	li	s5,0
  last = 1;
    80006ca2:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006ca4:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006ca6:	00002b97          	auipc	s7,0x2
    80006caa:	102b8b93          	addi	s7,s7,258 # 80008da8 <userret+0xd18>
    80006cae:	a01d                	j	80006cd4 <bd_print_vector+0x54>
    80006cb0:	8626                	mv	a2,s1
    80006cb2:	85d6                	mv	a1,s5
    80006cb4:	855e                	mv	a0,s7
    80006cb6:	ffffa097          	auipc	ra,0xffffa
    80006cba:	cb6080e7          	jalr	-842(ra) # 8000096c <printf>
    lb = b;
    last = bit_isset(vector, b);
    80006cbe:	85a6                	mv	a1,s1
    80006cc0:	854e                	mv	a0,s3
    80006cc2:	00000097          	auipc	ra,0x0
    80006cc6:	f22080e7          	jalr	-222(ra) # 80006be4 <bit_isset>
    80006cca:	892a                	mv	s2,a0
    80006ccc:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006cce:	2485                	addiw	s1,s1,1
    80006cd0:	009a0d63          	beq	s4,s1,80006cea <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006cd4:	85a6                	mv	a1,s1
    80006cd6:	854e                	mv	a0,s3
    80006cd8:	00000097          	auipc	ra,0x0
    80006cdc:	f0c080e7          	jalr	-244(ra) # 80006be4 <bit_isset>
    80006ce0:	ff2507e3          	beq	a0,s2,80006cce <bd_print_vector+0x4e>
    if(last == 1)
    80006ce4:	fd691de3          	bne	s2,s6,80006cbe <bd_print_vector+0x3e>
    80006ce8:	b7e1                	j	80006cb0 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80006cea:	000a8563          	beqz	s5,80006cf4 <bd_print_vector+0x74>
    80006cee:	4785                	li	a5,1
    80006cf0:	00f91c63          	bne	s2,a5,80006d08 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006cf4:	8652                	mv	a2,s4
    80006cf6:	85d6                	mv	a1,s5
    80006cf8:	00002517          	auipc	a0,0x2
    80006cfc:	0b050513          	addi	a0,a0,176 # 80008da8 <userret+0xd18>
    80006d00:	ffffa097          	auipc	ra,0xffffa
    80006d04:	c6c080e7          	jalr	-916(ra) # 8000096c <printf>
  }
  printf("\n");
    80006d08:	00002517          	auipc	a0,0x2
    80006d0c:	94050513          	addi	a0,a0,-1728 # 80008648 <userret+0x5b8>
    80006d10:	ffffa097          	auipc	ra,0xffffa
    80006d14:	c5c080e7          	jalr	-932(ra) # 8000096c <printf>
}
    80006d18:	60a6                	ld	ra,72(sp)
    80006d1a:	6406                	ld	s0,64(sp)
    80006d1c:	74e2                	ld	s1,56(sp)
    80006d1e:	7942                	ld	s2,48(sp)
    80006d20:	79a2                	ld	s3,40(sp)
    80006d22:	7a02                	ld	s4,32(sp)
    80006d24:	6ae2                	ld	s5,24(sp)
    80006d26:	6b42                	ld	s6,16(sp)
    80006d28:	6ba2                	ld	s7,8(sp)
    80006d2a:	6161                	addi	sp,sp,80
    80006d2c:	8082                	ret
  lb = 0;
    80006d2e:	4a81                	li	s5,0
    80006d30:	b7d1                	j	80006cf4 <bd_print_vector+0x74>

0000000080006d32 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006d32:	00027697          	auipc	a3,0x27
    80006d36:	36e6a683          	lw	a3,878(a3) # 8002e0a0 <nsizes>
    80006d3a:	10d05063          	blez	a3,80006e3a <bd_print+0x108>
bd_print() {
    80006d3e:	711d                	addi	sp,sp,-96
    80006d40:	ec86                	sd	ra,88(sp)
    80006d42:	e8a2                	sd	s0,80(sp)
    80006d44:	e4a6                	sd	s1,72(sp)
    80006d46:	e0ca                	sd	s2,64(sp)
    80006d48:	fc4e                	sd	s3,56(sp)
    80006d4a:	f852                	sd	s4,48(sp)
    80006d4c:	f456                	sd	s5,40(sp)
    80006d4e:	f05a                	sd	s6,32(sp)
    80006d50:	ec5e                	sd	s7,24(sp)
    80006d52:	e862                	sd	s8,16(sp)
    80006d54:	e466                	sd	s9,8(sp)
    80006d56:	e06a                	sd	s10,0(sp)
    80006d58:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80006d5a:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006d5c:	4a85                	li	s5,1
    80006d5e:	4c41                	li	s8,16
    80006d60:	00002b97          	auipc	s7,0x2
    80006d64:	058b8b93          	addi	s7,s7,88 # 80008db8 <userret+0xd28>
    lst_print(&bd_sizes[k].free);
    80006d68:	00027a17          	auipc	s4,0x27
    80006d6c:	330a0a13          	addi	s4,s4,816 # 8002e098 <bd_sizes>
    printf("  alloc:");
    80006d70:	00002b17          	auipc	s6,0x2
    80006d74:	070b0b13          	addi	s6,s6,112 # 80008de0 <userret+0xd50>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006d78:	00027997          	auipc	s3,0x27
    80006d7c:	32898993          	addi	s3,s3,808 # 8002e0a0 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006d80:	00002c97          	auipc	s9,0x2
    80006d84:	070c8c93          	addi	s9,s9,112 # 80008df0 <userret+0xd60>
    80006d88:	a801                	j	80006d98 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80006d8a:	0009a683          	lw	a3,0(s3)
    80006d8e:	0485                	addi	s1,s1,1
    80006d90:	0004879b          	sext.w	a5,s1
    80006d94:	08d7d563          	bge	a5,a3,80006e1e <bd_print+0xec>
    80006d98:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006d9c:	36fd                	addiw	a3,a3,-1
    80006d9e:	9e85                	subw	a3,a3,s1
    80006da0:	00da96bb          	sllw	a3,s5,a3
    80006da4:	009c1633          	sll	a2,s8,s1
    80006da8:	85ca                	mv	a1,s2
    80006daa:	855e                	mv	a0,s7
    80006dac:	ffffa097          	auipc	ra,0xffffa
    80006db0:	bc0080e7          	jalr	-1088(ra) # 8000096c <printf>
    lst_print(&bd_sizes[k].free);
    80006db4:	00549d13          	slli	s10,s1,0x5
    80006db8:	000a3503          	ld	a0,0(s4)
    80006dbc:	956a                	add	a0,a0,s10
    80006dbe:	00001097          	auipc	ra,0x1
    80006dc2:	a4e080e7          	jalr	-1458(ra) # 8000780c <lst_print>
    printf("  alloc:");
    80006dc6:	855a                	mv	a0,s6
    80006dc8:	ffffa097          	auipc	ra,0xffffa
    80006dcc:	ba4080e7          	jalr	-1116(ra) # 8000096c <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006dd0:	0009a583          	lw	a1,0(s3)
    80006dd4:	35fd                	addiw	a1,a1,-1
    80006dd6:	412585bb          	subw	a1,a1,s2
    80006dda:	000a3783          	ld	a5,0(s4)
    80006dde:	97ea                	add	a5,a5,s10
    80006de0:	00ba95bb          	sllw	a1,s5,a1
    80006de4:	6b88                	ld	a0,16(a5)
    80006de6:	00000097          	auipc	ra,0x0
    80006dea:	e9a080e7          	jalr	-358(ra) # 80006c80 <bd_print_vector>
    if(k > 0) {
    80006dee:	f9205ee3          	blez	s2,80006d8a <bd_print+0x58>
      printf("  split:");
    80006df2:	8566                	mv	a0,s9
    80006df4:	ffffa097          	auipc	ra,0xffffa
    80006df8:	b78080e7          	jalr	-1160(ra) # 8000096c <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006dfc:	0009a583          	lw	a1,0(s3)
    80006e00:	35fd                	addiw	a1,a1,-1
    80006e02:	412585bb          	subw	a1,a1,s2
    80006e06:	000a3783          	ld	a5,0(s4)
    80006e0a:	9d3e                	add	s10,s10,a5
    80006e0c:	00ba95bb          	sllw	a1,s5,a1
    80006e10:	018d3503          	ld	a0,24(s10)
    80006e14:	00000097          	auipc	ra,0x0
    80006e18:	e6c080e7          	jalr	-404(ra) # 80006c80 <bd_print_vector>
    80006e1c:	b7bd                	j	80006d8a <bd_print+0x58>
    }
  }
}
    80006e1e:	60e6                	ld	ra,88(sp)
    80006e20:	6446                	ld	s0,80(sp)
    80006e22:	64a6                	ld	s1,72(sp)
    80006e24:	6906                	ld	s2,64(sp)
    80006e26:	79e2                	ld	s3,56(sp)
    80006e28:	7a42                	ld	s4,48(sp)
    80006e2a:	7aa2                	ld	s5,40(sp)
    80006e2c:	7b02                	ld	s6,32(sp)
    80006e2e:	6be2                	ld	s7,24(sp)
    80006e30:	6c42                	ld	s8,16(sp)
    80006e32:	6ca2                	ld	s9,8(sp)
    80006e34:	6d02                	ld	s10,0(sp)
    80006e36:	6125                	addi	sp,sp,96
    80006e38:	8082                	ret
    80006e3a:	8082                	ret

0000000080006e3c <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006e3c:	1141                	addi	sp,sp,-16
    80006e3e:	e422                	sd	s0,8(sp)
    80006e40:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006e42:	47c1                	li	a5,16
    80006e44:	00a7fb63          	bgeu	a5,a0,80006e5a <firstk+0x1e>
    80006e48:	872a                	mv	a4,a0
  int k = 0;
    80006e4a:	4501                	li	a0,0
    k++;
    80006e4c:	2505                	addiw	a0,a0,1
    size *= 2;
    80006e4e:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006e50:	fee7eee3          	bltu	a5,a4,80006e4c <firstk+0x10>
  }
  return k;
}
    80006e54:	6422                	ld	s0,8(sp)
    80006e56:	0141                	addi	sp,sp,16
    80006e58:	8082                	ret
  int k = 0;
    80006e5a:	4501                	li	a0,0
    80006e5c:	bfe5                	j	80006e54 <firstk+0x18>

0000000080006e5e <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006e5e:	1141                	addi	sp,sp,-16
    80006e60:	e422                	sd	s0,8(sp)
    80006e62:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006e64:	00027797          	auipc	a5,0x27
    80006e68:	22c7b783          	ld	a5,556(a5) # 8002e090 <bd_base>
    80006e6c:	9d9d                	subw	a1,a1,a5
    80006e6e:	47c1                	li	a5,16
    80006e70:	00a79533          	sll	a0,a5,a0
    80006e74:	02a5c533          	div	a0,a1,a0
}
    80006e78:	2501                	sext.w	a0,a0
    80006e7a:	6422                	ld	s0,8(sp)
    80006e7c:	0141                	addi	sp,sp,16
    80006e7e:	8082                	ret

0000000080006e80 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006e80:	1141                	addi	sp,sp,-16
    80006e82:	e422                	sd	s0,8(sp)
    80006e84:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006e86:	47c1                	li	a5,16
    80006e88:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006e8c:	02b787bb          	mulw	a5,a5,a1
}
    80006e90:	00027517          	auipc	a0,0x27
    80006e94:	20053503          	ld	a0,512(a0) # 8002e090 <bd_base>
    80006e98:	953e                	add	a0,a0,a5
    80006e9a:	6422                	ld	s0,8(sp)
    80006e9c:	0141                	addi	sp,sp,16
    80006e9e:	8082                	ret

0000000080006ea0 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006ea0:	7159                	addi	sp,sp,-112
    80006ea2:	f486                	sd	ra,104(sp)
    80006ea4:	f0a2                	sd	s0,96(sp)
    80006ea6:	eca6                	sd	s1,88(sp)
    80006ea8:	e8ca                	sd	s2,80(sp)
    80006eaa:	e4ce                	sd	s3,72(sp)
    80006eac:	e0d2                	sd	s4,64(sp)
    80006eae:	fc56                	sd	s5,56(sp)
    80006eb0:	f85a                	sd	s6,48(sp)
    80006eb2:	f45e                	sd	s7,40(sp)
    80006eb4:	f062                	sd	s8,32(sp)
    80006eb6:	ec66                	sd	s9,24(sp)
    80006eb8:	e86a                	sd	s10,16(sp)
    80006eba:	e46e                	sd	s11,8(sp)
    80006ebc:	1880                	addi	s0,sp,112
    80006ebe:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006ec0:	00027517          	auipc	a0,0x27
    80006ec4:	14050513          	addi	a0,a0,320 # 8002e000 <lock>
    80006ec8:	ffffa097          	auipc	ra,0xffffa
    80006ecc:	dc0080e7          	jalr	-576(ra) # 80000c88 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006ed0:	8526                	mv	a0,s1
    80006ed2:	00000097          	auipc	ra,0x0
    80006ed6:	f6a080e7          	jalr	-150(ra) # 80006e3c <firstk>
  for (k = fk; k < nsizes; k++) {
    80006eda:	00027797          	auipc	a5,0x27
    80006ede:	1c67a783          	lw	a5,454(a5) # 8002e0a0 <nsizes>
    80006ee2:	02f55d63          	bge	a0,a5,80006f1c <bd_malloc+0x7c>
    80006ee6:	8c2a                	mv	s8,a0
    80006ee8:	00551913          	slli	s2,a0,0x5
    80006eec:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006eee:	00027997          	auipc	s3,0x27
    80006ef2:	1aa98993          	addi	s3,s3,426 # 8002e098 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006ef6:	00027a17          	auipc	s4,0x27
    80006efa:	1aaa0a13          	addi	s4,s4,426 # 8002e0a0 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006efe:	0009b503          	ld	a0,0(s3)
    80006f02:	954a                	add	a0,a0,s2
    80006f04:	00001097          	auipc	ra,0x1
    80006f08:	88e080e7          	jalr	-1906(ra) # 80007792 <lst_empty>
    80006f0c:	c115                	beqz	a0,80006f30 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006f0e:	2485                	addiw	s1,s1,1
    80006f10:	02090913          	addi	s2,s2,32
    80006f14:	000a2783          	lw	a5,0(s4)
    80006f18:	fef4c3e3          	blt	s1,a5,80006efe <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006f1c:	00027517          	auipc	a0,0x27
    80006f20:	0e450513          	addi	a0,a0,228 # 8002e000 <lock>
    80006f24:	ffffa097          	auipc	ra,0xffffa
    80006f28:	fb0080e7          	jalr	-80(ra) # 80000ed4 <release>
    return 0;
    80006f2c:	4b01                	li	s6,0
    80006f2e:	a0e1                	j	80006ff6 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006f30:	00027797          	auipc	a5,0x27
    80006f34:	1707a783          	lw	a5,368(a5) # 8002e0a0 <nsizes>
    80006f38:	fef4d2e3          	bge	s1,a5,80006f1c <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006f3c:	00549993          	slli	s3,s1,0x5
    80006f40:	00027917          	auipc	s2,0x27
    80006f44:	15890913          	addi	s2,s2,344 # 8002e098 <bd_sizes>
    80006f48:	00093503          	ld	a0,0(s2)
    80006f4c:	954e                	add	a0,a0,s3
    80006f4e:	00001097          	auipc	ra,0x1
    80006f52:	870080e7          	jalr	-1936(ra) # 800077be <lst_pop>
    80006f56:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006f58:	00027597          	auipc	a1,0x27
    80006f5c:	1385b583          	ld	a1,312(a1) # 8002e090 <bd_base>
    80006f60:	40b505bb          	subw	a1,a0,a1
    80006f64:	47c1                	li	a5,16
    80006f66:	009797b3          	sll	a5,a5,s1
    80006f6a:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006f6e:	00093783          	ld	a5,0(s2)
    80006f72:	97ce                	add	a5,a5,s3
    80006f74:	2581                	sext.w	a1,a1
    80006f76:	6b88                	ld	a0,16(a5)
    80006f78:	00000097          	auipc	ra,0x0
    80006f7c:	ca4080e7          	jalr	-860(ra) # 80006c1c <bit_set>
  for(; k > fk; k--) {
    80006f80:	069c5363          	bge	s8,s1,80006fe6 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006f84:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006f86:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006f88:	00027d17          	auipc	s10,0x27
    80006f8c:	108d0d13          	addi	s10,s10,264 # 8002e090 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006f90:	85a6                	mv	a1,s1
    80006f92:	34fd                	addiw	s1,s1,-1
    80006f94:	009b9ab3          	sll	s5,s7,s1
    80006f98:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006f9c:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    80006fa0:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006fa4:	412b093b          	subw	s2,s6,s2
    80006fa8:	00bb95b3          	sll	a1,s7,a1
    80006fac:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006fb0:	013a07b3          	add	a5,s4,s3
    80006fb4:	2581                	sext.w	a1,a1
    80006fb6:	6f88                	ld	a0,24(a5)
    80006fb8:	00000097          	auipc	ra,0x0
    80006fbc:	c64080e7          	jalr	-924(ra) # 80006c1c <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006fc0:	1981                	addi	s3,s3,-32
    80006fc2:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006fc4:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006fc8:	2581                	sext.w	a1,a1
    80006fca:	010a3503          	ld	a0,16(s4)
    80006fce:	00000097          	auipc	ra,0x0
    80006fd2:	c4e080e7          	jalr	-946(ra) # 80006c1c <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006fd6:	85e6                	mv	a1,s9
    80006fd8:	8552                	mv	a0,s4
    80006fda:	00001097          	auipc	ra,0x1
    80006fde:	81a080e7          	jalr	-2022(ra) # 800077f4 <lst_push>
  for(; k > fk; k--) {
    80006fe2:	fb8497e3          	bne	s1,s8,80006f90 <bd_malloc+0xf0>
  }
  release(&lock);
    80006fe6:	00027517          	auipc	a0,0x27
    80006fea:	01a50513          	addi	a0,a0,26 # 8002e000 <lock>
    80006fee:	ffffa097          	auipc	ra,0xffffa
    80006ff2:	ee6080e7          	jalr	-282(ra) # 80000ed4 <release>

  return p;
}
    80006ff6:	855a                	mv	a0,s6
    80006ff8:	70a6                	ld	ra,104(sp)
    80006ffa:	7406                	ld	s0,96(sp)
    80006ffc:	64e6                	ld	s1,88(sp)
    80006ffe:	6946                	ld	s2,80(sp)
    80007000:	69a6                	ld	s3,72(sp)
    80007002:	6a06                	ld	s4,64(sp)
    80007004:	7ae2                	ld	s5,56(sp)
    80007006:	7b42                	ld	s6,48(sp)
    80007008:	7ba2                	ld	s7,40(sp)
    8000700a:	7c02                	ld	s8,32(sp)
    8000700c:	6ce2                	ld	s9,24(sp)
    8000700e:	6d42                	ld	s10,16(sp)
    80007010:	6da2                	ld	s11,8(sp)
    80007012:	6165                	addi	sp,sp,112
    80007014:	8082                	ret

0000000080007016 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80007016:	7139                	addi	sp,sp,-64
    80007018:	fc06                	sd	ra,56(sp)
    8000701a:	f822                	sd	s0,48(sp)
    8000701c:	f426                	sd	s1,40(sp)
    8000701e:	f04a                	sd	s2,32(sp)
    80007020:	ec4e                	sd	s3,24(sp)
    80007022:	e852                	sd	s4,16(sp)
    80007024:	e456                	sd	s5,8(sp)
    80007026:	e05a                	sd	s6,0(sp)
    80007028:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    8000702a:	00027a97          	auipc	s5,0x27
    8000702e:	076aaa83          	lw	s5,118(s5) # 8002e0a0 <nsizes>
  return n / BLK_SIZE(k);
    80007032:	00027a17          	auipc	s4,0x27
    80007036:	05ea3a03          	ld	s4,94(s4) # 8002e090 <bd_base>
    8000703a:	41450a3b          	subw	s4,a0,s4
    8000703e:	00027497          	auipc	s1,0x27
    80007042:	05a4b483          	ld	s1,90(s1) # 8002e098 <bd_sizes>
    80007046:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    8000704a:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    8000704c:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    8000704e:	03595363          	bge	s2,s5,80007074 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80007052:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80007056:	013b15b3          	sll	a1,s6,s3
    8000705a:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    8000705e:	2581                	sext.w	a1,a1
    80007060:	6088                	ld	a0,0(s1)
    80007062:	00000097          	auipc	ra,0x0
    80007066:	b82080e7          	jalr	-1150(ra) # 80006be4 <bit_isset>
    8000706a:	02048493          	addi	s1,s1,32
    8000706e:	e501                	bnez	a0,80007076 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80007070:	894e                	mv	s2,s3
    80007072:	bff1                	j	8000704e <size+0x38>
      return k;
    }
  }
  return 0;
    80007074:	4901                	li	s2,0
}
    80007076:	854a                	mv	a0,s2
    80007078:	70e2                	ld	ra,56(sp)
    8000707a:	7442                	ld	s0,48(sp)
    8000707c:	74a2                	ld	s1,40(sp)
    8000707e:	7902                	ld	s2,32(sp)
    80007080:	69e2                	ld	s3,24(sp)
    80007082:	6a42                	ld	s4,16(sp)
    80007084:	6aa2                	ld	s5,8(sp)
    80007086:	6b02                	ld	s6,0(sp)
    80007088:	6121                	addi	sp,sp,64
    8000708a:	8082                	ret

000000008000708c <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    8000708c:	7159                	addi	sp,sp,-112
    8000708e:	f486                	sd	ra,104(sp)
    80007090:	f0a2                	sd	s0,96(sp)
    80007092:	eca6                	sd	s1,88(sp)
    80007094:	e8ca                	sd	s2,80(sp)
    80007096:	e4ce                	sd	s3,72(sp)
    80007098:	e0d2                	sd	s4,64(sp)
    8000709a:	fc56                	sd	s5,56(sp)
    8000709c:	f85a                	sd	s6,48(sp)
    8000709e:	f45e                	sd	s7,40(sp)
    800070a0:	f062                	sd	s8,32(sp)
    800070a2:	ec66                	sd	s9,24(sp)
    800070a4:	e86a                	sd	s10,16(sp)
    800070a6:	e46e                	sd	s11,8(sp)
    800070a8:	1880                	addi	s0,sp,112
    800070aa:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    800070ac:	00027517          	auipc	a0,0x27
    800070b0:	f5450513          	addi	a0,a0,-172 # 8002e000 <lock>
    800070b4:	ffffa097          	auipc	ra,0xffffa
    800070b8:	bd4080e7          	jalr	-1068(ra) # 80000c88 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    800070bc:	8556                	mv	a0,s5
    800070be:	00000097          	auipc	ra,0x0
    800070c2:	f58080e7          	jalr	-168(ra) # 80007016 <size>
    800070c6:	84aa                	mv	s1,a0
    800070c8:	00027797          	auipc	a5,0x27
    800070cc:	fd87a783          	lw	a5,-40(a5) # 8002e0a0 <nsizes>
    800070d0:	37fd                	addiw	a5,a5,-1
    800070d2:	0af55d63          	bge	a0,a5,8000718c <bd_free+0x100>
    800070d6:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    800070da:	00027c17          	auipc	s8,0x27
    800070de:	fb6c0c13          	addi	s8,s8,-74 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    800070e2:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    800070e4:	00027b17          	auipc	s6,0x27
    800070e8:	fb4b0b13          	addi	s6,s6,-76 # 8002e098 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    800070ec:	00027c97          	auipc	s9,0x27
    800070f0:	fb4c8c93          	addi	s9,s9,-76 # 8002e0a0 <nsizes>
    800070f4:	a82d                	j	8000712e <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800070f6:	fff58d9b          	addiw	s11,a1,-1
    800070fa:	a881                	j	8000714a <bd_free+0xbe>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800070fc:	020a0a13          	addi	s4,s4,32
    80007100:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80007102:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80007106:	40ba85bb          	subw	a1,s5,a1
    8000710a:	009b97b3          	sll	a5,s7,s1
    8000710e:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007112:	000b3783          	ld	a5,0(s6)
    80007116:	97d2                	add	a5,a5,s4
    80007118:	2581                	sext.w	a1,a1
    8000711a:	6f88                	ld	a0,24(a5)
    8000711c:	00000097          	auipc	ra,0x0
    80007120:	b30080e7          	jalr	-1232(ra) # 80006c4c <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80007124:	000ca783          	lw	a5,0(s9)
    80007128:	37fd                	addiw	a5,a5,-1
    8000712a:	06f4d163          	bge	s1,a5,8000718c <bd_free+0x100>
  int n = p - (char *) bd_base;
    8000712e:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80007132:	009b99b3          	sll	s3,s7,s1
    80007136:	412a87bb          	subw	a5,s5,s2
    8000713a:	0337c7b3          	div	a5,a5,s3
    8000713e:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007142:	8b85                	andi	a5,a5,1
    80007144:	fbcd                	bnez	a5,800070f6 <bd_free+0x6a>
    80007146:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    8000714a:	000b3d03          	ld	s10,0(s6)
    8000714e:	9d52                	add	s10,s10,s4
    80007150:	010d3503          	ld	a0,16(s10)
    80007154:	00000097          	auipc	ra,0x0
    80007158:	af8080e7          	jalr	-1288(ra) # 80006c4c <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    8000715c:	85ee                	mv	a1,s11
    8000715e:	010d3503          	ld	a0,16(s10)
    80007162:	00000097          	auipc	ra,0x0
    80007166:	a82080e7          	jalr	-1406(ra) # 80006be4 <bit_isset>
    8000716a:	e10d                	bnez	a0,8000718c <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    8000716c:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80007170:	03b989bb          	mulw	s3,s3,s11
    80007174:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80007176:	854a                	mv	a0,s2
    80007178:	00000097          	auipc	ra,0x0
    8000717c:	630080e7          	jalr	1584(ra) # 800077a8 <lst_remove>
    if(buddy % 2 == 0) {
    80007180:	001d7d13          	andi	s10,s10,1
    80007184:	f60d1ce3          	bnez	s10,800070fc <bd_free+0x70>
      p = q;
    80007188:	8aca                	mv	s5,s2
    8000718a:	bf8d                	j	800070fc <bd_free+0x70>
  }
  lst_push(&bd_sizes[k].free, p);
    8000718c:	0496                	slli	s1,s1,0x5
    8000718e:	85d6                	mv	a1,s5
    80007190:	00027517          	auipc	a0,0x27
    80007194:	f0853503          	ld	a0,-248(a0) # 8002e098 <bd_sizes>
    80007198:	9526                	add	a0,a0,s1
    8000719a:	00000097          	auipc	ra,0x0
    8000719e:	65a080e7          	jalr	1626(ra) # 800077f4 <lst_push>
  release(&lock);
    800071a2:	00027517          	auipc	a0,0x27
    800071a6:	e5e50513          	addi	a0,a0,-418 # 8002e000 <lock>
    800071aa:	ffffa097          	auipc	ra,0xffffa
    800071ae:	d2a080e7          	jalr	-726(ra) # 80000ed4 <release>
}
    800071b2:	70a6                	ld	ra,104(sp)
    800071b4:	7406                	ld	s0,96(sp)
    800071b6:	64e6                	ld	s1,88(sp)
    800071b8:	6946                	ld	s2,80(sp)
    800071ba:	69a6                	ld	s3,72(sp)
    800071bc:	6a06                	ld	s4,64(sp)
    800071be:	7ae2                	ld	s5,56(sp)
    800071c0:	7b42                	ld	s6,48(sp)
    800071c2:	7ba2                	ld	s7,40(sp)
    800071c4:	7c02                	ld	s8,32(sp)
    800071c6:	6ce2                	ld	s9,24(sp)
    800071c8:	6d42                	ld	s10,16(sp)
    800071ca:	6da2                	ld	s11,8(sp)
    800071cc:	6165                	addi	sp,sp,112
    800071ce:	8082                	ret

00000000800071d0 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    800071d0:	1141                	addi	sp,sp,-16
    800071d2:	e422                	sd	s0,8(sp)
    800071d4:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    800071d6:	00027797          	auipc	a5,0x27
    800071da:	eba7b783          	ld	a5,-326(a5) # 8002e090 <bd_base>
    800071de:	8d9d                	sub	a1,a1,a5
    800071e0:	47c1                	li	a5,16
    800071e2:	00a797b3          	sll	a5,a5,a0
    800071e6:	02f5c533          	div	a0,a1,a5
    800071ea:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    800071ec:	02f5e5b3          	rem	a1,a1,a5
    800071f0:	c191                	beqz	a1,800071f4 <blk_index_next+0x24>
      n++;
    800071f2:	2505                	addiw	a0,a0,1
  return n ;
}
    800071f4:	6422                	ld	s0,8(sp)
    800071f6:	0141                	addi	sp,sp,16
    800071f8:	8082                	ret

00000000800071fa <log2>:

int
log2(uint64 n) {
    800071fa:	1141                	addi	sp,sp,-16
    800071fc:	e422                	sd	s0,8(sp)
    800071fe:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80007200:	4705                	li	a4,1
    80007202:	00a77b63          	bgeu	a4,a0,80007218 <log2+0x1e>
    80007206:	87aa                	mv	a5,a0
  int k = 0;
    80007208:	4501                	li	a0,0
    k++;
    8000720a:	2505                	addiw	a0,a0,1
    n = n >> 1;
    8000720c:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    8000720e:	fef76ee3          	bltu	a4,a5,8000720a <log2+0x10>
  }
  return k;
}
    80007212:	6422                	ld	s0,8(sp)
    80007214:	0141                	addi	sp,sp,16
    80007216:	8082                	ret
  int k = 0;
    80007218:	4501                	li	a0,0
    8000721a:	bfe5                	j	80007212 <log2+0x18>

000000008000721c <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    8000721c:	711d                	addi	sp,sp,-96
    8000721e:	ec86                	sd	ra,88(sp)
    80007220:	e8a2                	sd	s0,80(sp)
    80007222:	e4a6                	sd	s1,72(sp)
    80007224:	e0ca                	sd	s2,64(sp)
    80007226:	fc4e                	sd	s3,56(sp)
    80007228:	f852                	sd	s4,48(sp)
    8000722a:	f456                	sd	s5,40(sp)
    8000722c:	f05a                	sd	s6,32(sp)
    8000722e:	ec5e                	sd	s7,24(sp)
    80007230:	e862                	sd	s8,16(sp)
    80007232:	e466                	sd	s9,8(sp)
    80007234:	e06a                	sd	s10,0(sp)
    80007236:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80007238:	00b56933          	or	s2,a0,a1
    8000723c:	00f97913          	andi	s2,s2,15
    80007240:	04091263          	bnez	s2,80007284 <bd_mark+0x68>
    80007244:	8b2a                	mv	s6,a0
    80007246:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80007248:	00027c17          	auipc	s8,0x27
    8000724c:	e58c2c03          	lw	s8,-424(s8) # 8002e0a0 <nsizes>
    80007250:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80007252:	00027d17          	auipc	s10,0x27
    80007256:	e3ed0d13          	addi	s10,s10,-450 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    8000725a:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    8000725c:	00027a97          	auipc	s5,0x27
    80007260:	e3ca8a93          	addi	s5,s5,-452 # 8002e098 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80007264:	07804563          	bgtz	s8,800072ce <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80007268:	60e6                	ld	ra,88(sp)
    8000726a:	6446                	ld	s0,80(sp)
    8000726c:	64a6                	ld	s1,72(sp)
    8000726e:	6906                	ld	s2,64(sp)
    80007270:	79e2                	ld	s3,56(sp)
    80007272:	7a42                	ld	s4,48(sp)
    80007274:	7aa2                	ld	s5,40(sp)
    80007276:	7b02                	ld	s6,32(sp)
    80007278:	6be2                	ld	s7,24(sp)
    8000727a:	6c42                	ld	s8,16(sp)
    8000727c:	6ca2                	ld	s9,8(sp)
    8000727e:	6d02                	ld	s10,0(sp)
    80007280:	6125                	addi	sp,sp,96
    80007282:	8082                	ret
    panic("bd_mark");
    80007284:	00002517          	auipc	a0,0x2
    80007288:	b7c50513          	addi	a0,a0,-1156 # 80008e00 <userret+0xd70>
    8000728c:	ffff9097          	auipc	ra,0xffff9
    80007290:	4ca080e7          	jalr	1226(ra) # 80000756 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80007294:	000ab783          	ld	a5,0(s5)
    80007298:	97ca                	add	a5,a5,s2
    8000729a:	85a6                	mv	a1,s1
    8000729c:	6b88                	ld	a0,16(a5)
    8000729e:	00000097          	auipc	ra,0x0
    800072a2:	97e080e7          	jalr	-1666(ra) # 80006c1c <bit_set>
    for(; bi < bj; bi++) {
    800072a6:	2485                	addiw	s1,s1,1
    800072a8:	009a0e63          	beq	s4,s1,800072c4 <bd_mark+0xa8>
      if(k > 0) {
    800072ac:	ff3054e3          	blez	s3,80007294 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    800072b0:	000ab783          	ld	a5,0(s5)
    800072b4:	97ca                	add	a5,a5,s2
    800072b6:	85a6                	mv	a1,s1
    800072b8:	6f88                	ld	a0,24(a5)
    800072ba:	00000097          	auipc	ra,0x0
    800072be:	962080e7          	jalr	-1694(ra) # 80006c1c <bit_set>
    800072c2:	bfc9                	j	80007294 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    800072c4:	2985                	addiw	s3,s3,1
    800072c6:	02090913          	addi	s2,s2,32
    800072ca:	f9898fe3          	beq	s3,s8,80007268 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    800072ce:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    800072d2:	409b04bb          	subw	s1,s6,s1
    800072d6:	013c97b3          	sll	a5,s9,s3
    800072da:	02f4c4b3          	div	s1,s1,a5
    800072de:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    800072e0:	85de                	mv	a1,s7
    800072e2:	854e                	mv	a0,s3
    800072e4:	00000097          	auipc	ra,0x0
    800072e8:	eec080e7          	jalr	-276(ra) # 800071d0 <blk_index_next>
    800072ec:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    800072ee:	faa4cfe3          	blt	s1,a0,800072ac <bd_mark+0x90>
    800072f2:	bfc9                	j	800072c4 <bd_mark+0xa8>

00000000800072f4 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    800072f4:	7139                	addi	sp,sp,-64
    800072f6:	fc06                	sd	ra,56(sp)
    800072f8:	f822                	sd	s0,48(sp)
    800072fa:	f426                	sd	s1,40(sp)
    800072fc:	f04a                	sd	s2,32(sp)
    800072fe:	ec4e                	sd	s3,24(sp)
    80007300:	e852                	sd	s4,16(sp)
    80007302:	e456                	sd	s5,8(sp)
    80007304:	e05a                	sd	s6,0(sp)
    80007306:	0080                	addi	s0,sp,64
    80007308:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000730a:	00058a9b          	sext.w	s5,a1
    8000730e:	0015f793          	andi	a5,a1,1
    80007312:	ebad                	bnez	a5,80007384 <bd_initfree_pair+0x90>
    80007314:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007318:	00599493          	slli	s1,s3,0x5
    8000731c:	00027797          	auipc	a5,0x27
    80007320:	d7c7b783          	ld	a5,-644(a5) # 8002e098 <bd_sizes>
    80007324:	94be                	add	s1,s1,a5
    80007326:	0104bb03          	ld	s6,16(s1)
    8000732a:	855a                	mv	a0,s6
    8000732c:	00000097          	auipc	ra,0x0
    80007330:	8b8080e7          	jalr	-1864(ra) # 80006be4 <bit_isset>
    80007334:	892a                	mv	s2,a0
    80007336:	85d2                	mv	a1,s4
    80007338:	855a                	mv	a0,s6
    8000733a:	00000097          	auipc	ra,0x0
    8000733e:	8aa080e7          	jalr	-1878(ra) # 80006be4 <bit_isset>
  int free = 0;
    80007342:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007344:	02a90563          	beq	s2,a0,8000736e <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80007348:	45c1                	li	a1,16
    8000734a:	013599b3          	sll	s3,a1,s3
    8000734e:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80007352:	02090c63          	beqz	s2,8000738a <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80007356:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    8000735a:	00027597          	auipc	a1,0x27
    8000735e:	d365b583          	ld	a1,-714(a1) # 8002e090 <bd_base>
    80007362:	95ce                	add	a1,a1,s3
    80007364:	8526                	mv	a0,s1
    80007366:	00000097          	auipc	ra,0x0
    8000736a:	48e080e7          	jalr	1166(ra) # 800077f4 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    8000736e:	855a                	mv	a0,s6
    80007370:	70e2                	ld	ra,56(sp)
    80007372:	7442                	ld	s0,48(sp)
    80007374:	74a2                	ld	s1,40(sp)
    80007376:	7902                	ld	s2,32(sp)
    80007378:	69e2                	ld	s3,24(sp)
    8000737a:	6a42                	ld	s4,16(sp)
    8000737c:	6aa2                	ld	s5,8(sp)
    8000737e:	6b02                	ld	s6,0(sp)
    80007380:	6121                	addi	sp,sp,64
    80007382:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007384:	fff58a1b          	addiw	s4,a1,-1
    80007388:	bf41                	j	80007318 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    8000738a:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    8000738e:	00027597          	auipc	a1,0x27
    80007392:	d025b583          	ld	a1,-766(a1) # 8002e090 <bd_base>
    80007396:	95ce                	add	a1,a1,s3
    80007398:	8526                	mv	a0,s1
    8000739a:	00000097          	auipc	ra,0x0
    8000739e:	45a080e7          	jalr	1114(ra) # 800077f4 <lst_push>
    800073a2:	b7f1                	j	8000736e <bd_initfree_pair+0x7a>

00000000800073a4 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    800073a4:	711d                	addi	sp,sp,-96
    800073a6:	ec86                	sd	ra,88(sp)
    800073a8:	e8a2                	sd	s0,80(sp)
    800073aa:	e4a6                	sd	s1,72(sp)
    800073ac:	e0ca                	sd	s2,64(sp)
    800073ae:	fc4e                	sd	s3,56(sp)
    800073b0:	f852                	sd	s4,48(sp)
    800073b2:	f456                	sd	s5,40(sp)
    800073b4:	f05a                	sd	s6,32(sp)
    800073b6:	ec5e                	sd	s7,24(sp)
    800073b8:	e862                	sd	s8,16(sp)
    800073ba:	e466                	sd	s9,8(sp)
    800073bc:	e06a                	sd	s10,0(sp)
    800073be:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    800073c0:	00027717          	auipc	a4,0x27
    800073c4:	ce072703          	lw	a4,-800(a4) # 8002e0a0 <nsizes>
    800073c8:	4785                	li	a5,1
    800073ca:	06e7db63          	bge	a5,a4,80007440 <bd_initfree+0x9c>
    800073ce:	8aaa                	mv	s5,a0
    800073d0:	8b2e                	mv	s6,a1
    800073d2:	4901                	li	s2,0
  int free = 0;
    800073d4:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    800073d6:	00027c97          	auipc	s9,0x27
    800073da:	cbac8c93          	addi	s9,s9,-838 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    800073de:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    800073e0:	00027b97          	auipc	s7,0x27
    800073e4:	cc0b8b93          	addi	s7,s7,-832 # 8002e0a0 <nsizes>
    800073e8:	a039                	j	800073f6 <bd_initfree+0x52>
    800073ea:	2905                	addiw	s2,s2,1
    800073ec:	000ba783          	lw	a5,0(s7)
    800073f0:	37fd                	addiw	a5,a5,-1
    800073f2:	04f95863          	bge	s2,a5,80007442 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    800073f6:	85d6                	mv	a1,s5
    800073f8:	854a                	mv	a0,s2
    800073fa:	00000097          	auipc	ra,0x0
    800073fe:	dd6080e7          	jalr	-554(ra) # 800071d0 <blk_index_next>
    80007402:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80007404:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80007408:	409b04bb          	subw	s1,s6,s1
    8000740c:	012c17b3          	sll	a5,s8,s2
    80007410:	02f4c4b3          	div	s1,s1,a5
    80007414:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80007416:	85aa                	mv	a1,a0
    80007418:	854a                	mv	a0,s2
    8000741a:	00000097          	auipc	ra,0x0
    8000741e:	eda080e7          	jalr	-294(ra) # 800072f4 <bd_initfree_pair>
    80007422:	01450d3b          	addw	s10,a0,s4
    80007426:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    8000742a:	fc99d0e3          	bge	s3,s1,800073ea <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    8000742e:	85a6                	mv	a1,s1
    80007430:	854a                	mv	a0,s2
    80007432:	00000097          	auipc	ra,0x0
    80007436:	ec2080e7          	jalr	-318(ra) # 800072f4 <bd_initfree_pair>
    8000743a:	00ad0a3b          	addw	s4,s10,a0
    8000743e:	b775                	j	800073ea <bd_initfree+0x46>
  int free = 0;
    80007440:	4a01                	li	s4,0
  }
  return free;
}
    80007442:	8552                	mv	a0,s4
    80007444:	60e6                	ld	ra,88(sp)
    80007446:	6446                	ld	s0,80(sp)
    80007448:	64a6                	ld	s1,72(sp)
    8000744a:	6906                	ld	s2,64(sp)
    8000744c:	79e2                	ld	s3,56(sp)
    8000744e:	7a42                	ld	s4,48(sp)
    80007450:	7aa2                	ld	s5,40(sp)
    80007452:	7b02                	ld	s6,32(sp)
    80007454:	6be2                	ld	s7,24(sp)
    80007456:	6c42                	ld	s8,16(sp)
    80007458:	6ca2                	ld	s9,8(sp)
    8000745a:	6d02                	ld	s10,0(sp)
    8000745c:	6125                	addi	sp,sp,96
    8000745e:	8082                	ret

0000000080007460 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80007460:	7179                	addi	sp,sp,-48
    80007462:	f406                	sd	ra,40(sp)
    80007464:	f022                	sd	s0,32(sp)
    80007466:	ec26                	sd	s1,24(sp)
    80007468:	e84a                	sd	s2,16(sp)
    8000746a:	e44e                	sd	s3,8(sp)
    8000746c:	1800                	addi	s0,sp,48
    8000746e:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80007470:	00027997          	auipc	s3,0x27
    80007474:	c2098993          	addi	s3,s3,-992 # 8002e090 <bd_base>
    80007478:	0009b483          	ld	s1,0(s3)
    8000747c:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80007480:	00027797          	auipc	a5,0x27
    80007484:	c207a783          	lw	a5,-992(a5) # 8002e0a0 <nsizes>
    80007488:	37fd                	addiw	a5,a5,-1
    8000748a:	4641                	li	a2,16
    8000748c:	00f61633          	sll	a2,a2,a5
    80007490:	85a6                	mv	a1,s1
    80007492:	00002517          	auipc	a0,0x2
    80007496:	97650513          	addi	a0,a0,-1674 # 80008e08 <userret+0xd78>
    8000749a:	ffff9097          	auipc	ra,0xffff9
    8000749e:	4d2080e7          	jalr	1234(ra) # 8000096c <printf>
  bd_mark(bd_base, p);
    800074a2:	85ca                	mv	a1,s2
    800074a4:	0009b503          	ld	a0,0(s3)
    800074a8:	00000097          	auipc	ra,0x0
    800074ac:	d74080e7          	jalr	-652(ra) # 8000721c <bd_mark>
  return meta;
}
    800074b0:	8526                	mv	a0,s1
    800074b2:	70a2                	ld	ra,40(sp)
    800074b4:	7402                	ld	s0,32(sp)
    800074b6:	64e2                	ld	s1,24(sp)
    800074b8:	6942                	ld	s2,16(sp)
    800074ba:	69a2                	ld	s3,8(sp)
    800074bc:	6145                	addi	sp,sp,48
    800074be:	8082                	ret

00000000800074c0 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    800074c0:	1101                	addi	sp,sp,-32
    800074c2:	ec06                	sd	ra,24(sp)
    800074c4:	e822                	sd	s0,16(sp)
    800074c6:	e426                	sd	s1,8(sp)
    800074c8:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    800074ca:	00027497          	auipc	s1,0x27
    800074ce:	bd64a483          	lw	s1,-1066(s1) # 8002e0a0 <nsizes>
    800074d2:	fff4879b          	addiw	a5,s1,-1
    800074d6:	44c1                	li	s1,16
    800074d8:	00f494b3          	sll	s1,s1,a5
    800074dc:	00027797          	auipc	a5,0x27
    800074e0:	bb47b783          	ld	a5,-1100(a5) # 8002e090 <bd_base>
    800074e4:	8d1d                	sub	a0,a0,a5
    800074e6:	40a4853b          	subw	a0,s1,a0
    800074ea:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    800074ee:	00905a63          	blez	s1,80007502 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    800074f2:	357d                	addiw	a0,a0,-1
    800074f4:	41f5549b          	sraiw	s1,a0,0x1f
    800074f8:	01c4d49b          	srliw	s1,s1,0x1c
    800074fc:	9ca9                	addw	s1,s1,a0
    800074fe:	98c1                	andi	s1,s1,-16
    80007500:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80007502:	85a6                	mv	a1,s1
    80007504:	00002517          	auipc	a0,0x2
    80007508:	93c50513          	addi	a0,a0,-1732 # 80008e40 <userret+0xdb0>
    8000750c:	ffff9097          	auipc	ra,0xffff9
    80007510:	460080e7          	jalr	1120(ra) # 8000096c <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007514:	00027717          	auipc	a4,0x27
    80007518:	b7c73703          	ld	a4,-1156(a4) # 8002e090 <bd_base>
    8000751c:	00027597          	auipc	a1,0x27
    80007520:	b845a583          	lw	a1,-1148(a1) # 8002e0a0 <nsizes>
    80007524:	fff5879b          	addiw	a5,a1,-1
    80007528:	45c1                	li	a1,16
    8000752a:	00f595b3          	sll	a1,a1,a5
    8000752e:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80007532:	95ba                	add	a1,a1,a4
    80007534:	953a                	add	a0,a0,a4
    80007536:	00000097          	auipc	ra,0x0
    8000753a:	ce6080e7          	jalr	-794(ra) # 8000721c <bd_mark>
  return unavailable;
}
    8000753e:	8526                	mv	a0,s1
    80007540:	60e2                	ld	ra,24(sp)
    80007542:	6442                	ld	s0,16(sp)
    80007544:	64a2                	ld	s1,8(sp)
    80007546:	6105                	addi	sp,sp,32
    80007548:	8082                	ret

000000008000754a <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    8000754a:	715d                	addi	sp,sp,-80
    8000754c:	e486                	sd	ra,72(sp)
    8000754e:	e0a2                	sd	s0,64(sp)
    80007550:	fc26                	sd	s1,56(sp)
    80007552:	f84a                	sd	s2,48(sp)
    80007554:	f44e                	sd	s3,40(sp)
    80007556:	f052                	sd	s4,32(sp)
    80007558:	ec56                	sd	s5,24(sp)
    8000755a:	e85a                	sd	s6,16(sp)
    8000755c:	e45e                	sd	s7,8(sp)
    8000755e:	e062                	sd	s8,0(sp)
    80007560:	0880                	addi	s0,sp,80
    80007562:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80007564:	fff50493          	addi	s1,a0,-1
    80007568:	98c1                	andi	s1,s1,-16
    8000756a:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    8000756c:	00002597          	auipc	a1,0x2
    80007570:	8f458593          	addi	a1,a1,-1804 # 80008e60 <userret+0xdd0>
    80007574:	00027517          	auipc	a0,0x27
    80007578:	a8c50513          	addi	a0,a0,-1396 # 8002e000 <lock>
    8000757c:	ffff9097          	auipc	ra,0xffff9
    80007580:	5a2080e7          	jalr	1442(ra) # 80000b1e <initlock>
  bd_base = (void *) p;
    80007584:	00027797          	auipc	a5,0x27
    80007588:	b097b623          	sd	s1,-1268(a5) # 8002e090 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    8000758c:	409c0933          	sub	s2,s8,s1
    80007590:	43f95513          	srai	a0,s2,0x3f
    80007594:	893d                	andi	a0,a0,15
    80007596:	954a                	add	a0,a0,s2
    80007598:	8511                	srai	a0,a0,0x4
    8000759a:	00000097          	auipc	ra,0x0
    8000759e:	c60080e7          	jalr	-928(ra) # 800071fa <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    800075a2:	47c1                	li	a5,16
    800075a4:	00a797b3          	sll	a5,a5,a0
    800075a8:	1b27c663          	blt	a5,s2,80007754 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    800075ac:	2505                	addiw	a0,a0,1
    800075ae:	00027797          	auipc	a5,0x27
    800075b2:	aea7a923          	sw	a0,-1294(a5) # 8002e0a0 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    800075b6:	00027997          	auipc	s3,0x27
    800075ba:	aea98993          	addi	s3,s3,-1302 # 8002e0a0 <nsizes>
    800075be:	0009a603          	lw	a2,0(s3)
    800075c2:	85ca                	mv	a1,s2
    800075c4:	00002517          	auipc	a0,0x2
    800075c8:	8a450513          	addi	a0,a0,-1884 # 80008e68 <userret+0xdd8>
    800075cc:	ffff9097          	auipc	ra,0xffff9
    800075d0:	3a0080e7          	jalr	928(ra) # 8000096c <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    800075d4:	00027797          	auipc	a5,0x27
    800075d8:	ac97b223          	sd	s1,-1340(a5) # 8002e098 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    800075dc:	0009a603          	lw	a2,0(s3)
    800075e0:	00561913          	slli	s2,a2,0x5
    800075e4:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    800075e6:	0056161b          	slliw	a2,a2,0x5
    800075ea:	4581                	li	a1,0
    800075ec:	8526                	mv	a0,s1
    800075ee:	ffffa097          	auipc	ra,0xffffa
    800075f2:	ae6080e7          	jalr	-1306(ra) # 800010d4 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    800075f6:	0009a783          	lw	a5,0(s3)
    800075fa:	06f05a63          	blez	a5,8000766e <bd_init+0x124>
    800075fe:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80007600:	00027a97          	auipc	s5,0x27
    80007604:	a98a8a93          	addi	s5,s5,-1384 # 8002e098 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007608:	00027a17          	auipc	s4,0x27
    8000760c:	a98a0a13          	addi	s4,s4,-1384 # 8002e0a0 <nsizes>
    80007610:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80007612:	00599b93          	slli	s7,s3,0x5
    80007616:	000ab503          	ld	a0,0(s5)
    8000761a:	955e                	add	a0,a0,s7
    8000761c:	00000097          	auipc	ra,0x0
    80007620:	166080e7          	jalr	358(ra) # 80007782 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007624:	000a2483          	lw	s1,0(s4)
    80007628:	34fd                	addiw	s1,s1,-1
    8000762a:	413484bb          	subw	s1,s1,s3
    8000762e:	009b14bb          	sllw	s1,s6,s1
    80007632:	fff4879b          	addiw	a5,s1,-1
    80007636:	41f7d49b          	sraiw	s1,a5,0x1f
    8000763a:	01d4d49b          	srliw	s1,s1,0x1d
    8000763e:	9cbd                	addw	s1,s1,a5
    80007640:	98e1                	andi	s1,s1,-8
    80007642:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80007644:	000ab783          	ld	a5,0(s5)
    80007648:	9bbe                	add	s7,s7,a5
    8000764a:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    8000764e:	848d                	srai	s1,s1,0x3
    80007650:	8626                	mv	a2,s1
    80007652:	4581                	li	a1,0
    80007654:	854a                	mv	a0,s2
    80007656:	ffffa097          	auipc	ra,0xffffa
    8000765a:	a7e080e7          	jalr	-1410(ra) # 800010d4 <memset>
    p += sz;
    8000765e:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80007660:	0985                	addi	s3,s3,1
    80007662:	000a2703          	lw	a4,0(s4)
    80007666:	0009879b          	sext.w	a5,s3
    8000766a:	fae7c4e3          	blt	a5,a4,80007612 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    8000766e:	00027797          	auipc	a5,0x27
    80007672:	a327a783          	lw	a5,-1486(a5) # 8002e0a0 <nsizes>
    80007676:	4705                	li	a4,1
    80007678:	06f75163          	bge	a4,a5,800076da <bd_init+0x190>
    8000767c:	02000a13          	li	s4,32
    80007680:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80007682:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80007684:	00027b17          	auipc	s6,0x27
    80007688:	a14b0b13          	addi	s6,s6,-1516 # 8002e098 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    8000768c:	00027a97          	auipc	s5,0x27
    80007690:	a14a8a93          	addi	s5,s5,-1516 # 8002e0a0 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80007694:	37fd                	addiw	a5,a5,-1
    80007696:	413787bb          	subw	a5,a5,s3
    8000769a:	00fb94bb          	sllw	s1,s7,a5
    8000769e:	fff4879b          	addiw	a5,s1,-1
    800076a2:	41f7d49b          	sraiw	s1,a5,0x1f
    800076a6:	01d4d49b          	srliw	s1,s1,0x1d
    800076aa:	9cbd                	addw	s1,s1,a5
    800076ac:	98e1                	andi	s1,s1,-8
    800076ae:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    800076b0:	000b3783          	ld	a5,0(s6)
    800076b4:	97d2                	add	a5,a5,s4
    800076b6:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    800076ba:	848d                	srai	s1,s1,0x3
    800076bc:	8626                	mv	a2,s1
    800076be:	4581                	li	a1,0
    800076c0:	854a                	mv	a0,s2
    800076c2:	ffffa097          	auipc	ra,0xffffa
    800076c6:	a12080e7          	jalr	-1518(ra) # 800010d4 <memset>
    p += sz;
    800076ca:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    800076cc:	2985                	addiw	s3,s3,1
    800076ce:	000aa783          	lw	a5,0(s5)
    800076d2:	020a0a13          	addi	s4,s4,32
    800076d6:	faf9cfe3          	blt	s3,a5,80007694 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    800076da:	197d                	addi	s2,s2,-1
    800076dc:	ff097913          	andi	s2,s2,-16
    800076e0:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    800076e2:	854a                	mv	a0,s2
    800076e4:	00000097          	auipc	ra,0x0
    800076e8:	d7c080e7          	jalr	-644(ra) # 80007460 <bd_mark_data_structures>
    800076ec:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    800076ee:	85ca                	mv	a1,s2
    800076f0:	8562                	mv	a0,s8
    800076f2:	00000097          	auipc	ra,0x0
    800076f6:	dce080e7          	jalr	-562(ra) # 800074c0 <bd_mark_unavailable>
    800076fa:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800076fc:	00027a97          	auipc	s5,0x27
    80007700:	9a4a8a93          	addi	s5,s5,-1628 # 8002e0a0 <nsizes>
    80007704:	000aa783          	lw	a5,0(s5)
    80007708:	37fd                	addiw	a5,a5,-1
    8000770a:	44c1                	li	s1,16
    8000770c:	00f497b3          	sll	a5,s1,a5
    80007710:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80007712:	00027597          	auipc	a1,0x27
    80007716:	97e5b583          	ld	a1,-1666(a1) # 8002e090 <bd_base>
    8000771a:	95be                	add	a1,a1,a5
    8000771c:	854a                	mv	a0,s2
    8000771e:	00000097          	auipc	ra,0x0
    80007722:	c86080e7          	jalr	-890(ra) # 800073a4 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80007726:	000aa603          	lw	a2,0(s5)
    8000772a:	367d                	addiw	a2,a2,-1
    8000772c:	00c49633          	sll	a2,s1,a2
    80007730:	41460633          	sub	a2,a2,s4
    80007734:	41360633          	sub	a2,a2,s3
    80007738:	02c51463          	bne	a0,a2,80007760 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    8000773c:	60a6                	ld	ra,72(sp)
    8000773e:	6406                	ld	s0,64(sp)
    80007740:	74e2                	ld	s1,56(sp)
    80007742:	7942                	ld	s2,48(sp)
    80007744:	79a2                	ld	s3,40(sp)
    80007746:	7a02                	ld	s4,32(sp)
    80007748:	6ae2                	ld	s5,24(sp)
    8000774a:	6b42                	ld	s6,16(sp)
    8000774c:	6ba2                	ld	s7,8(sp)
    8000774e:	6c02                	ld	s8,0(sp)
    80007750:	6161                	addi	sp,sp,80
    80007752:	8082                	ret
    nsizes++;  // round up to the next power of 2
    80007754:	2509                	addiw	a0,a0,2
    80007756:	00027797          	auipc	a5,0x27
    8000775a:	94a7a523          	sw	a0,-1718(a5) # 8002e0a0 <nsizes>
    8000775e:	bda1                	j	800075b6 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007760:	85aa                	mv	a1,a0
    80007762:	00001517          	auipc	a0,0x1
    80007766:	74650513          	addi	a0,a0,1862 # 80008ea8 <userret+0xe18>
    8000776a:	ffff9097          	auipc	ra,0xffff9
    8000776e:	202080e7          	jalr	514(ra) # 8000096c <printf>
    panic("bd_init: free mem");
    80007772:	00001517          	auipc	a0,0x1
    80007776:	74650513          	addi	a0,a0,1862 # 80008eb8 <userret+0xe28>
    8000777a:	ffff9097          	auipc	ra,0xffff9
    8000777e:	fdc080e7          	jalr	-36(ra) # 80000756 <panic>

0000000080007782 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80007782:	1141                	addi	sp,sp,-16
    80007784:	e422                	sd	s0,8(sp)
    80007786:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007788:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    8000778a:	e508                	sd	a0,8(a0)
}
    8000778c:	6422                	ld	s0,8(sp)
    8000778e:	0141                	addi	sp,sp,16
    80007790:	8082                	ret

0000000080007792 <lst_empty>:

int
lst_empty(struct list *lst) {
    80007792:	1141                	addi	sp,sp,-16
    80007794:	e422                	sd	s0,8(sp)
    80007796:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007798:	611c                	ld	a5,0(a0)
    8000779a:	40a78533          	sub	a0,a5,a0
}
    8000779e:	00153513          	seqz	a0,a0
    800077a2:	6422                	ld	s0,8(sp)
    800077a4:	0141                	addi	sp,sp,16
    800077a6:	8082                	ret

00000000800077a8 <lst_remove>:

void
lst_remove(struct list *e) {
    800077a8:	1141                	addi	sp,sp,-16
    800077aa:	e422                	sd	s0,8(sp)
    800077ac:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    800077ae:	6518                	ld	a4,8(a0)
    800077b0:	611c                	ld	a5,0(a0)
    800077b2:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    800077b4:	6518                	ld	a4,8(a0)
    800077b6:	e798                	sd	a4,8(a5)
}
    800077b8:	6422                	ld	s0,8(sp)
    800077ba:	0141                	addi	sp,sp,16
    800077bc:	8082                	ret

00000000800077be <lst_pop>:

void*
lst_pop(struct list *lst) {
    800077be:	1101                	addi	sp,sp,-32
    800077c0:	ec06                	sd	ra,24(sp)
    800077c2:	e822                	sd	s0,16(sp)
    800077c4:	e426                	sd	s1,8(sp)
    800077c6:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    800077c8:	6104                	ld	s1,0(a0)
    800077ca:	00a48d63          	beq	s1,a0,800077e4 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    800077ce:	8526                	mv	a0,s1
    800077d0:	00000097          	auipc	ra,0x0
    800077d4:	fd8080e7          	jalr	-40(ra) # 800077a8 <lst_remove>
  return (void *)p;
}
    800077d8:	8526                	mv	a0,s1
    800077da:	60e2                	ld	ra,24(sp)
    800077dc:	6442                	ld	s0,16(sp)
    800077de:	64a2                	ld	s1,8(sp)
    800077e0:	6105                	addi	sp,sp,32
    800077e2:	8082                	ret
    panic("lst_pop");
    800077e4:	00001517          	auipc	a0,0x1
    800077e8:	6ec50513          	addi	a0,a0,1772 # 80008ed0 <userret+0xe40>
    800077ec:	ffff9097          	auipc	ra,0xffff9
    800077f0:	f6a080e7          	jalr	-150(ra) # 80000756 <panic>

00000000800077f4 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    800077f4:	1141                	addi	sp,sp,-16
    800077f6:	e422                	sd	s0,8(sp)
    800077f8:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800077fa:	611c                	ld	a5,0(a0)
    800077fc:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800077fe:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007800:	611c                	ld	a5,0(a0)
    80007802:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80007804:	e10c                	sd	a1,0(a0)
}
    80007806:	6422                	ld	s0,8(sp)
    80007808:	0141                	addi	sp,sp,16
    8000780a:	8082                	ret

000000008000780c <lst_print>:

void
lst_print(struct list *lst)
{
    8000780c:	7179                	addi	sp,sp,-48
    8000780e:	f406                	sd	ra,40(sp)
    80007810:	f022                	sd	s0,32(sp)
    80007812:	ec26                	sd	s1,24(sp)
    80007814:	e84a                	sd	s2,16(sp)
    80007816:	e44e                	sd	s3,8(sp)
    80007818:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000781a:	6104                	ld	s1,0(a0)
    8000781c:	02950063          	beq	a0,s1,8000783c <lst_print+0x30>
    80007820:	892a                	mv	s2,a0
    printf(" %p", p);
    80007822:	00001997          	auipc	s3,0x1
    80007826:	6b698993          	addi	s3,s3,1718 # 80008ed8 <userret+0xe48>
    8000782a:	85a6                	mv	a1,s1
    8000782c:	854e                	mv	a0,s3
    8000782e:	ffff9097          	auipc	ra,0xffff9
    80007832:	13e080e7          	jalr	318(ra) # 8000096c <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007836:	6084                	ld	s1,0(s1)
    80007838:	fe9919e3          	bne	s2,s1,8000782a <lst_print+0x1e>
  }
  printf("\n");
    8000783c:	00001517          	auipc	a0,0x1
    80007840:	e0c50513          	addi	a0,a0,-500 # 80008648 <userret+0x5b8>
    80007844:	ffff9097          	auipc	ra,0xffff9
    80007848:	128080e7          	jalr	296(ra) # 8000096c <printf>
}
    8000784c:	70a2                	ld	ra,40(sp)
    8000784e:	7402                	ld	s0,32(sp)
    80007850:	64e2                	ld	s1,24(sp)
    80007852:	6942                	ld	s2,16(sp)
    80007854:	69a2                	ld	s3,8(sp)
    80007856:	6145                	addi	sp,sp,48
    80007858:	8082                	ret

000000008000785a <watchdogwrite>:
int watchdog_time;
struct spinlock watchdog_lock;

int
watchdogwrite(struct file *f, int user_src, uint64 src, int n)
{
    8000785a:	715d                	addi	sp,sp,-80
    8000785c:	e486                	sd	ra,72(sp)
    8000785e:	e0a2                	sd	s0,64(sp)
    80007860:	fc26                	sd	s1,56(sp)
    80007862:	f84a                	sd	s2,48(sp)
    80007864:	f44e                	sd	s3,40(sp)
    80007866:	f052                	sd	s4,32(sp)
    80007868:	ec56                	sd	s5,24(sp)
    8000786a:	0880                	addi	s0,sp,80
    8000786c:	89ae                	mv	s3,a1
    8000786e:	84b2                	mv	s1,a2
    80007870:	8a36                	mv	s4,a3
  acquire(&watchdog_lock);
    80007872:	00026517          	auipc	a0,0x26
    80007876:	7be50513          	addi	a0,a0,1982 # 8002e030 <watchdog_lock>
    8000787a:	ffff9097          	auipc	ra,0xffff9
    8000787e:	40e080e7          	jalr	1038(ra) # 80000c88 <acquire>

  int time = 0;
  for(int i = 0; i < n; i++){
    80007882:	09405d63          	blez	s4,8000791c <watchdogwrite+0xc2>
    80007886:	00148913          	addi	s2,s1,1
    8000788a:	3a7d                	addiw	s4,s4,-1
    8000788c:	1a02                	slli	s4,s4,0x20
    8000788e:	020a5a13          	srli	s4,s4,0x20
    80007892:	9952                	add	s2,s2,s4
  int time = 0;
    80007894:	4a01                	li	s4,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80007896:	5afd                	li	s5,-1
    80007898:	4685                	li	a3,1
    8000789a:	8626                	mv	a2,s1
    8000789c:	85ce                	mv	a1,s3
    8000789e:	fbf40513          	addi	a0,s0,-65
    800078a2:	ffffb097          	auipc	ra,0xffffb
    800078a6:	238080e7          	jalr	568(ra) # 80002ada <either_copyin>
    800078aa:	01550763          	beq	a0,s5,800078b8 <watchdogwrite+0x5e>
      break;
    time = c;
    800078ae:	fbf44a03          	lbu	s4,-65(s0)
  for(int i = 0; i < n; i++){
    800078b2:	0485                	addi	s1,s1,1
    800078b4:	ff2492e3          	bne	s1,s2,80007898 <watchdogwrite+0x3e>
  }

  acquire(&tickslock);
    800078b8:	00014517          	auipc	a0,0x14
    800078bc:	7e050513          	addi	a0,a0,2016 # 8001c098 <tickslock>
    800078c0:	ffff9097          	auipc	ra,0xffff9
    800078c4:	3c8080e7          	jalr	968(ra) # 80000c88 <acquire>
  n = ticks - watchdog_value;
    800078c8:	00026717          	auipc	a4,0x26
    800078cc:	7c072703          	lw	a4,1984(a4) # 8002e088 <ticks>
    800078d0:	00026797          	auipc	a5,0x26
    800078d4:	7d878793          	addi	a5,a5,2008 # 8002e0a8 <watchdog_value>
    800078d8:	4384                	lw	s1,0(a5)
    800078da:	409704bb          	subw	s1,a4,s1
  watchdog_value = ticks;
    800078de:	c398                	sw	a4,0(a5)
  watchdog_time = time;
    800078e0:	00026797          	auipc	a5,0x26
    800078e4:	7d47a223          	sw	s4,1988(a5) # 8002e0a4 <watchdog_time>
  release(&tickslock);
    800078e8:	00014517          	auipc	a0,0x14
    800078ec:	7b050513          	addi	a0,a0,1968 # 8001c098 <tickslock>
    800078f0:	ffff9097          	auipc	ra,0xffff9
    800078f4:	5e4080e7          	jalr	1508(ra) # 80000ed4 <release>

  release(&watchdog_lock);
    800078f8:	00026517          	auipc	a0,0x26
    800078fc:	73850513          	addi	a0,a0,1848 # 8002e030 <watchdog_lock>
    80007900:	ffff9097          	auipc	ra,0xffff9
    80007904:	5d4080e7          	jalr	1492(ra) # 80000ed4 <release>
  return n;
}
    80007908:	8526                	mv	a0,s1
    8000790a:	60a6                	ld	ra,72(sp)
    8000790c:	6406                	ld	s0,64(sp)
    8000790e:	74e2                	ld	s1,56(sp)
    80007910:	7942                	ld	s2,48(sp)
    80007912:	79a2                	ld	s3,40(sp)
    80007914:	7a02                	ld	s4,32(sp)
    80007916:	6ae2                	ld	s5,24(sp)
    80007918:	6161                	addi	sp,sp,80
    8000791a:	8082                	ret
  int time = 0;
    8000791c:	4a01                	li	s4,0
    8000791e:	bf69                	j	800078b8 <watchdogwrite+0x5e>

0000000080007920 <watchdoginit>:

void watchdoginit(){
    80007920:	1141                	addi	sp,sp,-16
    80007922:	e406                	sd	ra,8(sp)
    80007924:	e022                	sd	s0,0(sp)
    80007926:	0800                	addi	s0,sp,16
  initlock(&watchdog_lock, "watchdog_lock");
    80007928:	00001597          	auipc	a1,0x1
    8000792c:	5b858593          	addi	a1,a1,1464 # 80008ee0 <userret+0xe50>
    80007930:	00026517          	auipc	a0,0x26
    80007934:	70050513          	addi	a0,a0,1792 # 8002e030 <watchdog_lock>
    80007938:	ffff9097          	auipc	ra,0xffff9
    8000793c:	1e6080e7          	jalr	486(ra) # 80000b1e <initlock>
  watchdog_time = 0;
    80007940:	00026797          	auipc	a5,0x26
    80007944:	7607a223          	sw	zero,1892(a5) # 8002e0a4 <watchdog_time>


  devsw[WATCHDOG].read = 0;
    80007948:	0001f797          	auipc	a5,0x1f
    8000794c:	25078793          	addi	a5,a5,592 # 80026b98 <devsw>
    80007950:	0207b023          	sd	zero,32(a5)
  devsw[WATCHDOG].write = watchdogwrite;
    80007954:	00000717          	auipc	a4,0x0
    80007958:	f0670713          	addi	a4,a4,-250 # 8000785a <watchdogwrite>
    8000795c:	f798                	sd	a4,40(a5)
}
    8000795e:	60a2                	ld	ra,8(sp)
    80007960:	6402                	ld	s0,0(sp)
    80007962:	0141                	addi	sp,sp,16
    80007964:	8082                	ret
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
