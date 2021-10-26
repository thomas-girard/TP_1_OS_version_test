
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
    80000060:	3e478793          	addi	a5,a5,996 # 80006440 <timervec>
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
    80000166:	668080e7          	jalr	1640(ra) # 800027ca <sleep>
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
    800001d4:	5fa080e7          	jalr	1530(ra) # 800027ca <sleep>
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
    80000212:	81e080e7          	jalr	-2018(ra) # 80002a2c <either_copyout>
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
    8000033e:	490080e7          	jalr	1168(ra) # 800027ca <sleep>
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
    8000038c:	6fa080e7          	jalr	1786(ra) # 80002a82 <either_copyin>
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
    800004de:	5fe080e7          	jalr	1534(ra) # 80002ad8 <procdump>
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
    80000506:	692080e7          	jalr	1682(ra) # 80002b94 <priodump>
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
    8000057c:	3d8080e7          	jalr	984(ra) # 80002950 <wakeup>
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
    80000604:	350080e7          	jalr	848(ra) # 80002950 <wakeup>
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
    80000ae0:	a0e080e7          	jalr	-1522(ra) # 800074ea <bd_init>
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
    80000af8:	538080e7          	jalr	1336(ra) # 8000702c <bd_free>
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
    80000b12:	332080e7          	jalr	818(ra) # 80006e40 <bd_malloc>
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
    80000d6c:	d70080e7          	jalr	-656(ra) # 80002ad8 <procdump>
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
    80000d9c:	d40080e7          	jalr	-704(ra) # 80002ad8 <procdump>
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
    80000f6c:	2a8080e7          	jalr	680(ra) # 80003210 <argint>
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
    800012be:	b86080e7          	jalr	-1146(ra) # 80006e40 <bd_malloc>
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
    80001346:	afe080e7          	jalr	-1282(ra) # 80006e40 <bd_malloc>
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
    800013b2:	99c080e7          	jalr	-1636(ra) # 80002d4a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800013b6:	00005097          	auipc	ra,0x5
    800013ba:	0ca080e7          	jalr	202(ra) # 80006480 <plicinithart>
  }

  scheduler();        
    800013be:	00001097          	auipc	ra,0x1
    800013c2:	12a080e7          	jalr	298(ra) # 800024e8 <scheduler>
    consoleinit();
    800013c6:	fffff097          	auipc	ra,0xfffff
    800013ca:	244080e7          	jalr	580(ra) # 8000060a <consoleinit>
    watchdoginit();
    800013ce:	00006097          	auipc	ra,0x6
    800013d2:	4f2080e7          	jalr	1266(ra) # 800078c0 <watchdoginit>
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
    80001432:	8f4080e7          	jalr	-1804(ra) # 80002d22 <trapinit>
    trapinithart();  // install kernel trap vector
    80001436:	00002097          	auipc	ra,0x2
    8000143a:	914080e7          	jalr	-1772(ra) # 80002d4a <trapinithart>
    plicinit();      // set up interrupt controller
    8000143e:	00005097          	auipc	ra,0x5
    80001442:	02c080e7          	jalr	44(ra) # 8000646a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001446:	00005097          	auipc	ra,0x5
    8000144a:	03a080e7          	jalr	58(ra) # 80006480 <plicinithart>
    binit();         // buffer cache
    8000144e:	00002097          	auipc	ra,0x2
    80001452:	0b2080e7          	jalr	178(ra) # 80003500 <binit>
    iinit();         // inode cache
    80001456:	00002097          	auipc	ra,0x2
    8000145a:	746080e7          	jalr	1862(ra) # 80003b9c <iinit>
    fileinit();      // file table
    8000145e:	00003097          	auipc	ra,0x3
    80001462:	7ac080e7          	jalr	1964(ra) # 80004c0a <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80001466:	4501                	li	a0,0
    80001468:	00005097          	auipc	ra,0x5
    8000146c:	13a080e7          	jalr	314(ra) # 800065a2 <virtio_disk_init>
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
    80001dc0:	084080e7          	jalr	132(ra) # 80006e40 <bd_malloc>
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
    80001e48:	1e8080e7          	jalr	488(ra) # 8000702c <bd_free>
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
    80001ffa:	d6c080e7          	jalr	-660(ra) # 80002d62 <usertrapret>
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
    80002014:	b0c080e7          	jalr	-1268(ra) # 80003b1c <fsinit>
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
    800021f0:	e40080e7          	jalr	-448(ra) # 8000702c <bd_free>
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
    800022a2:	280080e7          	jalr	640(ra) # 8000451e <namei>
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
  acquire(&p->lock);
    800022c0:	8526                	mv	a0,s1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	9c6080e7          	jalr	-1594(ra) # 80000c88 <acquire>
  insert_into_prio_queue(p);
    800022ca:	8526                	mv	a0,s1
    800022cc:	00000097          	auipc	ra,0x0
    800022d0:	ae2080e7          	jalr	-1310(ra) # 80001dae <insert_into_prio_queue>
  release(&p->lock);
    800022d4:	8526                	mv	a0,s1
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	bfe080e7          	jalr	-1026(ra) # 80000ed4 <release>
  release(&prio_lock);
    800022de:	854a                	mv	a0,s2
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	bf4080e7          	jalr	-1036(ra) # 80000ed4 <release>
}
    800022e8:	60e2                	ld	ra,24(sp)
    800022ea:	6442                	ld	s0,16(sp)
    800022ec:	64a2                	ld	s1,8(sp)
    800022ee:	6902                	ld	s2,0(sp)
    800022f0:	6105                	addi	sp,sp,32
    800022f2:	8082                	ret

00000000800022f4 <growproc>:
{
    800022f4:	1101                	addi	sp,sp,-32
    800022f6:	ec06                	sd	ra,24(sp)
    800022f8:	e822                	sd	s0,16(sp)
    800022fa:	e426                	sd	s1,8(sp)
    800022fc:	e04a                	sd	s2,0(sp)
    800022fe:	1000                	addi	s0,sp,32
    80002300:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002302:	00000097          	auipc	ra,0x0
    80002306:	c9a080e7          	jalr	-870(ra) # 80001f9c <myproc>
    8000230a:	892a                	mv	s2,a0
  sz = p->sz;
    8000230c:	712c                	ld	a1,96(a0)
    8000230e:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002312:	00904f63          	bgtz	s1,80002330 <growproc+0x3c>
  } else if(n < 0){
    80002316:	0204cc63          	bltz	s1,8000234e <growproc+0x5a>
  p->sz = sz;
    8000231a:	1602                	slli	a2,a2,0x20
    8000231c:	9201                	srli	a2,a2,0x20
    8000231e:	06c93023          	sd	a2,96(s2)
  return 0;
    80002322:	4501                	li	a0,0
}
    80002324:	60e2                	ld	ra,24(sp)
    80002326:	6442                	ld	s0,16(sp)
    80002328:	64a2                	ld	s1,8(sp)
    8000232a:	6902                	ld	s2,0(sp)
    8000232c:	6105                	addi	sp,sp,32
    8000232e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80002330:	9e25                	addw	a2,a2,s1
    80002332:	1602                	slli	a2,a2,0x20
    80002334:	9201                	srli	a2,a2,0x20
    80002336:	1582                	slli	a1,a1,0x20
    80002338:	9181                	srli	a1,a1,0x20
    8000233a:	7528                	ld	a0,104(a0)
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	688080e7          	jalr	1672(ra) # 800019c4 <uvmalloc>
    80002344:	0005061b          	sext.w	a2,a0
    80002348:	fa69                	bnez	a2,8000231a <growproc+0x26>
      return -1;
    8000234a:	557d                	li	a0,-1
    8000234c:	bfe1                	j	80002324 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000234e:	9e25                	addw	a2,a2,s1
    80002350:	1602                	slli	a2,a2,0x20
    80002352:	9201                	srli	a2,a2,0x20
    80002354:	1582                	slli	a1,a1,0x20
    80002356:	9181                	srli	a1,a1,0x20
    80002358:	7528                	ld	a0,104(a0)
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	626080e7          	jalr	1574(ra) # 80001980 <uvmdealloc>
    80002362:	0005061b          	sext.w	a2,a0
    80002366:	bf55                	j	8000231a <growproc+0x26>

0000000080002368 <fork>:
{
    80002368:	7179                	addi	sp,sp,-48
    8000236a:	f406                	sd	ra,40(sp)
    8000236c:	f022                	sd	s0,32(sp)
    8000236e:	ec26                	sd	s1,24(sp)
    80002370:	e84a                	sd	s2,16(sp)
    80002372:	e44e                	sd	s3,8(sp)
    80002374:	e052                	sd	s4,0(sp)
    80002376:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002378:	00000097          	auipc	ra,0x0
    8000237c:	c24080e7          	jalr	-988(ra) # 80001f9c <myproc>
    80002380:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80002382:	00000097          	auipc	ra,0x0
    80002386:	d3a080e7          	jalr	-710(ra) # 800020bc <allocproc>
    8000238a:	c975                	beqz	a0,8000247e <fork+0x116>
    8000238c:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000238e:	06093603          	ld	a2,96(s2)
    80002392:	752c                	ld	a1,104(a0)
    80002394:	06893503          	ld	a0,104(s2)
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	704080e7          	jalr	1796(ra) # 80001a9c <uvmcopy>
    800023a0:	04054863          	bltz	a0,800023f0 <fork+0x88>
  np->sz = p->sz;
    800023a4:	06093783          	ld	a5,96(s2)
    800023a8:	06f9b023          	sd	a5,96(s3) # 4000060 <_entry-0x7bffffa0>
  np->parent = p;
    800023ac:	0329bc23          	sd	s2,56(s3)
  *(np->tf) = *(p->tf);
    800023b0:	07093683          	ld	a3,112(s2)
    800023b4:	87b6                	mv	a5,a3
    800023b6:	0709b703          	ld	a4,112(s3)
    800023ba:	12068693          	addi	a3,a3,288
    800023be:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800023c2:	6788                	ld	a0,8(a5)
    800023c4:	6b8c                	ld	a1,16(a5)
    800023c6:	6f90                	ld	a2,24(a5)
    800023c8:	01073023          	sd	a6,0(a4)
    800023cc:	e708                	sd	a0,8(a4)
    800023ce:	eb0c                	sd	a1,16(a4)
    800023d0:	ef10                	sd	a2,24(a4)
    800023d2:	02078793          	addi	a5,a5,32
    800023d6:	02070713          	addi	a4,a4,32
    800023da:	fed792e3          	bne	a5,a3,800023be <fork+0x56>
  np->tf->a0 = 0;
    800023de:	0709b783          	ld	a5,112(s3)
    800023e2:	0607b823          	sd	zero,112(a5)
    800023e6:	0e800493          	li	s1,232
  for(i = 0; i < NOFILE; i++)
    800023ea:	16800a13          	li	s4,360
    800023ee:	a03d                	j	8000241c <fork+0xb4>
    freeproc(np);
    800023f0:	854e                	mv	a0,s3
    800023f2:	00000097          	auipc	ra,0x0
    800023f6:	dca080e7          	jalr	-566(ra) # 800021bc <freeproc>
    release(&np->lock);
    800023fa:	854e                	mv	a0,s3
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	ad8080e7          	jalr	-1320(ra) # 80000ed4 <release>
    return -1;
    80002404:	54fd                	li	s1,-1
    80002406:	a09d                	j	8000246c <fork+0x104>
      np->ofile[i] = filedup(p->ofile[i]);
    80002408:	00003097          	auipc	ra,0x3
    8000240c:	894080e7          	jalr	-1900(ra) # 80004c9c <filedup>
    80002410:	009987b3          	add	a5,s3,s1
    80002414:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002416:	04a1                	addi	s1,s1,8
    80002418:	01448763          	beq	s1,s4,80002426 <fork+0xbe>
    if(p->ofile[i])
    8000241c:	009907b3          	add	a5,s2,s1
    80002420:	6388                	ld	a0,0(a5)
    80002422:	f17d                	bnez	a0,80002408 <fork+0xa0>
    80002424:	bfcd                	j	80002416 <fork+0xae>
  np->cwd = idup(p->cwd);
    80002426:	16893503          	ld	a0,360(s2)
    8000242a:	00002097          	auipc	ra,0x2
    8000242e:	92c080e7          	jalr	-1748(ra) # 80003d56 <idup>
    80002432:	16a9b423          	sd	a0,360(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002436:	4641                	li	a2,16
    80002438:	17090593          	addi	a1,s2,368
    8000243c:	17098513          	addi	a0,s3,368
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	dea080e7          	jalr	-534(ra) # 8000122a <safestrcpy>
  np->cmd = strdup(p->cmd);
    80002448:	18093503          	ld	a0,384(s2)
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	ed8080e7          	jalr	-296(ra) # 80001324 <strdup>
    80002454:	18a9b023          	sd	a0,384(s3)
  pid = np->pid;
    80002458:	0509a483          	lw	s1,80(s3)
  np->state = RUNNABLE;
    8000245c:	4789                	li	a5,2
    8000245e:	02f9a823          	sw	a5,48(s3)
  release(&np->lock);
    80002462:	854e                	mv	a0,s3
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	a70080e7          	jalr	-1424(ra) # 80000ed4 <release>
}
    8000246c:	8526                	mv	a0,s1
    8000246e:	70a2                	ld	ra,40(sp)
    80002470:	7402                	ld	s0,32(sp)
    80002472:	64e2                	ld	s1,24(sp)
    80002474:	6942                	ld	s2,16(sp)
    80002476:	69a2                	ld	s3,8(sp)
    80002478:	6a02                	ld	s4,0(sp)
    8000247a:	6145                	addi	sp,sp,48
    8000247c:	8082                	ret
    return -1;
    8000247e:	54fd                	li	s1,-1
    80002480:	b7f5                	j	8000246c <fork+0x104>

0000000080002482 <reparent>:
{
    80002482:	7179                	addi	sp,sp,-48
    80002484:	f406                	sd	ra,40(sp)
    80002486:	f022                	sd	s0,32(sp)
    80002488:	ec26                	sd	s1,24(sp)
    8000248a:	e84a                	sd	s2,16(sp)
    8000248c:	e44e                	sd	s3,8(sp)
    8000248e:	e052                	sd	s4,0(sp)
    80002490:	1800                	addi	s0,sp,48
    80002492:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002494:	00014497          	auipc	s1,0x14
    80002498:	a0448493          	addi	s1,s1,-1532 # 80015e98 <proc>
      pp->parent = initproc;
    8000249c:	0002ca17          	auipc	s4,0x2c
    800024a0:	be4a0a13          	addi	s4,s4,-1052 # 8002e080 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800024a4:	0001a997          	auipc	s3,0x1a
    800024a8:	bf498993          	addi	s3,s3,-1036 # 8001c098 <tickslock>
    800024ac:	a029                	j	800024b6 <reparent+0x34>
    800024ae:	18848493          	addi	s1,s1,392
    800024b2:	03348363          	beq	s1,s3,800024d8 <reparent+0x56>
    if(pp->parent == p){
    800024b6:	7c9c                	ld	a5,56(s1)
    800024b8:	ff279be3          	bne	a5,s2,800024ae <reparent+0x2c>
      acquire(&pp->lock);
    800024bc:	8526                	mv	a0,s1
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	7ca080e7          	jalr	1994(ra) # 80000c88 <acquire>
      pp->parent = initproc;
    800024c6:	000a3783          	ld	a5,0(s4)
    800024ca:	fc9c                	sd	a5,56(s1)
      release(&pp->lock);
    800024cc:	8526                	mv	a0,s1
    800024ce:	fffff097          	auipc	ra,0xfffff
    800024d2:	a06080e7          	jalr	-1530(ra) # 80000ed4 <release>
    800024d6:	bfe1                	j	800024ae <reparent+0x2c>
}
    800024d8:	70a2                	ld	ra,40(sp)
    800024da:	7402                	ld	s0,32(sp)
    800024dc:	64e2                	ld	s1,24(sp)
    800024de:	6942                	ld	s2,16(sp)
    800024e0:	69a2                	ld	s3,8(sp)
    800024e2:	6a02                	ld	s4,0(sp)
    800024e4:	6145                	addi	sp,sp,48
    800024e6:	8082                	ret

00000000800024e8 <scheduler>:
{
    800024e8:	715d                	addi	sp,sp,-80
    800024ea:	e486                	sd	ra,72(sp)
    800024ec:	e0a2                	sd	s0,64(sp)
    800024ee:	fc26                	sd	s1,56(sp)
    800024f0:	f84a                	sd	s2,48(sp)
    800024f2:	f44e                	sd	s3,40(sp)
    800024f4:	f052                	sd	s4,32(sp)
    800024f6:	ec56                	sd	s5,24(sp)
    800024f8:	e85a                	sd	s6,16(sp)
    800024fa:	e45e                	sd	s7,8(sp)
    800024fc:	e062                	sd	s8,0(sp)
    800024fe:	0880                	addi	s0,sp,80
    80002500:	8792                	mv	a5,tp
  int id = r_tp();
    80002502:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002504:	00779b93          	slli	s7,a5,0x7
    80002508:	00013717          	auipc	a4,0x13
    8000250c:	4e070713          	addi	a4,a4,1248 # 800159e8 <prio>
    80002510:	975e                	add	a4,a4,s7
    80002512:	0a073823          	sd	zero,176(a4)
        swtch(&c->scheduler, &p->context);
    80002516:	00013717          	auipc	a4,0x13
    8000251a:	58a70713          	addi	a4,a4,1418 # 80015aa0 <cpus+0x8>
    8000251e:	9bba                	add	s7,s7,a4
        p->state = RUNNING;
    80002520:	4c0d                	li	s8,3
        c->proc = p;
    80002522:	079e                	slli	a5,a5,0x7
    80002524:	00013917          	auipc	s2,0x13
    80002528:	4c490913          	addi	s2,s2,1220 # 800159e8 <prio>
    8000252c:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000252e:	0001aa17          	auipc	s4,0x1a
    80002532:	b6aa0a13          	addi	s4,s4,-1174 # 8001c098 <tickslock>
    80002536:	a0b9                	j	80002584 <scheduler+0x9c>
        p->state = RUNNING;
    80002538:	0384a823          	sw	s8,48(s1)
        c->proc = p;
    8000253c:	0a993823          	sd	s1,176(s2)
        swtch(&c->scheduler, &p->context);
    80002540:	07848593          	addi	a1,s1,120
    80002544:	855e                	mv	a0,s7
    80002546:	00000097          	auipc	ra,0x0
    8000254a:	6d8080e7          	jalr	1752(ra) # 80002c1e <swtch>
        c->proc = 0;
    8000254e:	0a093823          	sd	zero,176(s2)
        found = 1;
    80002552:	8ada                	mv	s5,s6
      c->intena = 0;
    80002554:	12092623          	sw	zero,300(s2)
      release(&p->lock);
    80002558:	8526                	mv	a0,s1
    8000255a:	fffff097          	auipc	ra,0xfffff
    8000255e:	97a080e7          	jalr	-1670(ra) # 80000ed4 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002562:	18848493          	addi	s1,s1,392
    80002566:	01448b63          	beq	s1,s4,8000257c <scheduler+0x94>
      acquire(&p->lock);
    8000256a:	8526                	mv	a0,s1
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	71c080e7          	jalr	1820(ra) # 80000c88 <acquire>
      if(p->state == RUNNABLE) {
    80002574:	589c                	lw	a5,48(s1)
    80002576:	fd379fe3          	bne	a5,s3,80002554 <scheduler+0x6c>
    8000257a:	bf7d                	j	80002538 <scheduler+0x50>
    if(found == 0){
    8000257c:	000a9463          	bnez	s5,80002584 <scheduler+0x9c>
      asm volatile("wfi");
    80002580:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002584:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002588:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000258c:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002590:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002594:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002596:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000259a:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000259c:	00014497          	auipc	s1,0x14
    800025a0:	8fc48493          	addi	s1,s1,-1796 # 80015e98 <proc>
      if(p->state == RUNNABLE) {
    800025a4:	4989                	li	s3,2
        found = 1;
    800025a6:	4b05                	li	s6,1
    800025a8:	b7c9                	j	8000256a <scheduler+0x82>

00000000800025aa <sched>:
{
    800025aa:	7179                	addi	sp,sp,-48
    800025ac:	f406                	sd	ra,40(sp)
    800025ae:	f022                	sd	s0,32(sp)
    800025b0:	ec26                	sd	s1,24(sp)
    800025b2:	e84a                	sd	s2,16(sp)
    800025b4:	e44e                	sd	s3,8(sp)
    800025b6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800025b8:	00000097          	auipc	ra,0x0
    800025bc:	9e4080e7          	jalr	-1564(ra) # 80001f9c <myproc>
    800025c0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	648080e7          	jalr	1608(ra) # 80000c0a <holding>
    800025ca:	c93d                	beqz	a0,80002640 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025cc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800025ce:	2781                	sext.w	a5,a5
    800025d0:	079e                	slli	a5,a5,0x7
    800025d2:	00013717          	auipc	a4,0x13
    800025d6:	41670713          	addi	a4,a4,1046 # 800159e8 <prio>
    800025da:	97ba                	add	a5,a5,a4
    800025dc:	1287a703          	lw	a4,296(a5)
    800025e0:	4785                	li	a5,1
    800025e2:	06f71763          	bne	a4,a5,80002650 <sched+0xa6>
  if(p->state == RUNNING)
    800025e6:	5898                	lw	a4,48(s1)
    800025e8:	478d                	li	a5,3
    800025ea:	06f70b63          	beq	a4,a5,80002660 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025ee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025f2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800025f4:	efb5                	bnez	a5,80002670 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025f6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800025f8:	00013917          	auipc	s2,0x13
    800025fc:	3f090913          	addi	s2,s2,1008 # 800159e8 <prio>
    80002600:	2781                	sext.w	a5,a5
    80002602:	079e                	slli	a5,a5,0x7
    80002604:	97ca                	add	a5,a5,s2
    80002606:	12c7a983          	lw	s3,300(a5)
    8000260a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    8000260c:	2781                	sext.w	a5,a5
    8000260e:	079e                	slli	a5,a5,0x7
    80002610:	00013597          	auipc	a1,0x13
    80002614:	49058593          	addi	a1,a1,1168 # 80015aa0 <cpus+0x8>
    80002618:	95be                	add	a1,a1,a5
    8000261a:	07848513          	addi	a0,s1,120
    8000261e:	00000097          	auipc	ra,0x0
    80002622:	600080e7          	jalr	1536(ra) # 80002c1e <swtch>
    80002626:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002628:	2781                	sext.w	a5,a5
    8000262a:	079e                	slli	a5,a5,0x7
    8000262c:	97ca                	add	a5,a5,s2
    8000262e:	1337a623          	sw	s3,300(a5)
}
    80002632:	70a2                	ld	ra,40(sp)
    80002634:	7402                	ld	s0,32(sp)
    80002636:	64e2                	ld	s1,24(sp)
    80002638:	6942                	ld	s2,16(sp)
    8000263a:	69a2                	ld	s3,8(sp)
    8000263c:	6145                	addi	sp,sp,48
    8000263e:	8082                	ret
    panic("sched p->lock");
    80002640:	00006517          	auipc	a0,0x6
    80002644:	f8050513          	addi	a0,a0,-128 # 800085c0 <userret+0x530>
    80002648:	ffffe097          	auipc	ra,0xffffe
    8000264c:	10e080e7          	jalr	270(ra) # 80000756 <panic>
    panic("sched locks");
    80002650:	00006517          	auipc	a0,0x6
    80002654:	f8050513          	addi	a0,a0,-128 # 800085d0 <userret+0x540>
    80002658:	ffffe097          	auipc	ra,0xffffe
    8000265c:	0fe080e7          	jalr	254(ra) # 80000756 <panic>
    panic("sched running");
    80002660:	00006517          	auipc	a0,0x6
    80002664:	f8050513          	addi	a0,a0,-128 # 800085e0 <userret+0x550>
    80002668:	ffffe097          	auipc	ra,0xffffe
    8000266c:	0ee080e7          	jalr	238(ra) # 80000756 <panic>
    panic("sched interruptible");
    80002670:	00006517          	auipc	a0,0x6
    80002674:	f8050513          	addi	a0,a0,-128 # 800085f0 <userret+0x560>
    80002678:	ffffe097          	auipc	ra,0xffffe
    8000267c:	0de080e7          	jalr	222(ra) # 80000756 <panic>

0000000080002680 <exit>:
{
    80002680:	7179                	addi	sp,sp,-48
    80002682:	f406                	sd	ra,40(sp)
    80002684:	f022                	sd	s0,32(sp)
    80002686:	ec26                	sd	s1,24(sp)
    80002688:	e84a                	sd	s2,16(sp)
    8000268a:	e44e                	sd	s3,8(sp)
    8000268c:	e052                	sd	s4,0(sp)
    8000268e:	1800                	addi	s0,sp,48
    80002690:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002692:	00000097          	auipc	ra,0x0
    80002696:	90a080e7          	jalr	-1782(ra) # 80001f9c <myproc>
    8000269a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000269c:	0002c797          	auipc	a5,0x2c
    800026a0:	9e47b783          	ld	a5,-1564(a5) # 8002e080 <initproc>
    800026a4:	0e850493          	addi	s1,a0,232
    800026a8:	16850913          	addi	s2,a0,360
    800026ac:	02a79363          	bne	a5,a0,800026d2 <exit+0x52>
    panic("init exiting");
    800026b0:	00006517          	auipc	a0,0x6
    800026b4:	f5850513          	addi	a0,a0,-168 # 80008608 <userret+0x578>
    800026b8:	ffffe097          	auipc	ra,0xffffe
    800026bc:	09e080e7          	jalr	158(ra) # 80000756 <panic>
      fileclose(f);
    800026c0:	00002097          	auipc	ra,0x2
    800026c4:	62e080e7          	jalr	1582(ra) # 80004cee <fileclose>
      p->ofile[fd] = 0;
    800026c8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800026cc:	04a1                	addi	s1,s1,8
    800026ce:	01248563          	beq	s1,s2,800026d8 <exit+0x58>
    if(p->ofile[fd]){
    800026d2:	6088                	ld	a0,0(s1)
    800026d4:	f575                	bnez	a0,800026c0 <exit+0x40>
    800026d6:	bfdd                	j	800026cc <exit+0x4c>
  begin_op(ROOTDEV);
    800026d8:	4501                	li	a0,0
    800026da:	00002097          	auipc	ra,0x2
    800026de:	08a080e7          	jalr	138(ra) # 80004764 <begin_op>
  iput(p->cwd);
    800026e2:	1689b503          	ld	a0,360(s3)
    800026e6:	00001097          	auipc	ra,0x1
    800026ea:	7bc080e7          	jalr	1980(ra) # 80003ea2 <iput>
  end_op(ROOTDEV);
    800026ee:	4501                	li	a0,0
    800026f0:	00002097          	auipc	ra,0x2
    800026f4:	120080e7          	jalr	288(ra) # 80004810 <end_op>
  p->cwd = 0;
    800026f8:	1609b423          	sd	zero,360(s3)
  acquire(&initproc->lock);
    800026fc:	0002c497          	auipc	s1,0x2c
    80002700:	98448493          	addi	s1,s1,-1660 # 8002e080 <initproc>
    80002704:	6088                	ld	a0,0(s1)
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	582080e7          	jalr	1410(ra) # 80000c88 <acquire>
  wakeup1(initproc);
    8000270e:	6088                	ld	a0,0(s1)
    80002710:	fffff097          	auipc	ra,0xfffff
    80002714:	65a080e7          	jalr	1626(ra) # 80001d6a <wakeup1>
  release(&initproc->lock);
    80002718:	6088                	ld	a0,0(s1)
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	7ba080e7          	jalr	1978(ra) # 80000ed4 <release>
  acquire(&p->lock);
    80002722:	854e                	mv	a0,s3
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	564080e7          	jalr	1380(ra) # 80000c88 <acquire>
  struct proc *original_parent = p->parent;
    8000272c:	0389b483          	ld	s1,56(s3)
  release(&p->lock);
    80002730:	854e                	mv	a0,s3
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	7a2080e7          	jalr	1954(ra) # 80000ed4 <release>
  acquire(&original_parent->lock);
    8000273a:	8526                	mv	a0,s1
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	54c080e7          	jalr	1356(ra) # 80000c88 <acquire>
  acquire(&p->lock);
    80002744:	854e                	mv	a0,s3
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	542080e7          	jalr	1346(ra) # 80000c88 <acquire>
  reparent(p);
    8000274e:	854e                	mv	a0,s3
    80002750:	00000097          	auipc	ra,0x0
    80002754:	d32080e7          	jalr	-718(ra) # 80002482 <reparent>
  wakeup1(original_parent);
    80002758:	8526                	mv	a0,s1
    8000275a:	fffff097          	auipc	ra,0xfffff
    8000275e:	610080e7          	jalr	1552(ra) # 80001d6a <wakeup1>
  p->xstate = status;
    80002762:	0549a623          	sw	s4,76(s3)
  p->state = ZOMBIE;
    80002766:	4791                	li	a5,4
    80002768:	02f9a823          	sw	a5,48(s3)
  release(&original_parent->lock);
    8000276c:	8526                	mv	a0,s1
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	766080e7          	jalr	1894(ra) # 80000ed4 <release>
  sched();
    80002776:	00000097          	auipc	ra,0x0
    8000277a:	e34080e7          	jalr	-460(ra) # 800025aa <sched>
  panic("zombie exit");
    8000277e:	00006517          	auipc	a0,0x6
    80002782:	e9a50513          	addi	a0,a0,-358 # 80008618 <userret+0x588>
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	fd0080e7          	jalr	-48(ra) # 80000756 <panic>

000000008000278e <yield>:
{
    8000278e:	1101                	addi	sp,sp,-32
    80002790:	ec06                	sd	ra,24(sp)
    80002792:	e822                	sd	s0,16(sp)
    80002794:	e426                	sd	s1,8(sp)
    80002796:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002798:	00000097          	auipc	ra,0x0
    8000279c:	804080e7          	jalr	-2044(ra) # 80001f9c <myproc>
    800027a0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	4e6080e7          	jalr	1254(ra) # 80000c88 <acquire>
  p->state = RUNNABLE;
    800027aa:	4789                	li	a5,2
    800027ac:	d89c                	sw	a5,48(s1)
  sched();
    800027ae:	00000097          	auipc	ra,0x0
    800027b2:	dfc080e7          	jalr	-516(ra) # 800025aa <sched>
  release(&p->lock);
    800027b6:	8526                	mv	a0,s1
    800027b8:	ffffe097          	auipc	ra,0xffffe
    800027bc:	71c080e7          	jalr	1820(ra) # 80000ed4 <release>
}
    800027c0:	60e2                	ld	ra,24(sp)
    800027c2:	6442                	ld	s0,16(sp)
    800027c4:	64a2                	ld	s1,8(sp)
    800027c6:	6105                	addi	sp,sp,32
    800027c8:	8082                	ret

00000000800027ca <sleep>:
{
    800027ca:	7179                	addi	sp,sp,-48
    800027cc:	f406                	sd	ra,40(sp)
    800027ce:	f022                	sd	s0,32(sp)
    800027d0:	ec26                	sd	s1,24(sp)
    800027d2:	e84a                	sd	s2,16(sp)
    800027d4:	e44e                	sd	s3,8(sp)
    800027d6:	1800                	addi	s0,sp,48
    800027d8:	89aa                	mv	s3,a0
    800027da:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027dc:	fffff097          	auipc	ra,0xfffff
    800027e0:	7c0080e7          	jalr	1984(ra) # 80001f9c <myproc>
    800027e4:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800027e6:	05250663          	beq	a0,s2,80002832 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	49e080e7          	jalr	1182(ra) # 80000c88 <acquire>
    release(lk);
    800027f2:	854a                	mv	a0,s2
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	6e0080e7          	jalr	1760(ra) # 80000ed4 <release>
  p->chan = chan;
    800027fc:	0534b023          	sd	s3,64(s1)
  p->state = SLEEPING;
    80002800:	4785                	li	a5,1
    80002802:	d89c                	sw	a5,48(s1)
  sched();
    80002804:	00000097          	auipc	ra,0x0
    80002808:	da6080e7          	jalr	-602(ra) # 800025aa <sched>
  p->chan = 0;
    8000280c:	0404b023          	sd	zero,64(s1)
    release(&p->lock);
    80002810:	8526                	mv	a0,s1
    80002812:	ffffe097          	auipc	ra,0xffffe
    80002816:	6c2080e7          	jalr	1730(ra) # 80000ed4 <release>
    acquire(lk);
    8000281a:	854a                	mv	a0,s2
    8000281c:	ffffe097          	auipc	ra,0xffffe
    80002820:	46c080e7          	jalr	1132(ra) # 80000c88 <acquire>
}
    80002824:	70a2                	ld	ra,40(sp)
    80002826:	7402                	ld	s0,32(sp)
    80002828:	64e2                	ld	s1,24(sp)
    8000282a:	6942                	ld	s2,16(sp)
    8000282c:	69a2                	ld	s3,8(sp)
    8000282e:	6145                	addi	sp,sp,48
    80002830:	8082                	ret
  p->chan = chan;
    80002832:	05353023          	sd	s3,64(a0)
  p->state = SLEEPING;
    80002836:	4785                	li	a5,1
    80002838:	d91c                	sw	a5,48(a0)
  sched();
    8000283a:	00000097          	auipc	ra,0x0
    8000283e:	d70080e7          	jalr	-656(ra) # 800025aa <sched>
  p->chan = 0;
    80002842:	0404b023          	sd	zero,64(s1)
  if(lk != &p->lock){
    80002846:	bff9                	j	80002824 <sleep+0x5a>

0000000080002848 <wait>:
{
    80002848:	715d                	addi	sp,sp,-80
    8000284a:	e486                	sd	ra,72(sp)
    8000284c:	e0a2                	sd	s0,64(sp)
    8000284e:	fc26                	sd	s1,56(sp)
    80002850:	f84a                	sd	s2,48(sp)
    80002852:	f44e                	sd	s3,40(sp)
    80002854:	f052                	sd	s4,32(sp)
    80002856:	ec56                	sd	s5,24(sp)
    80002858:	e85a                	sd	s6,16(sp)
    8000285a:	e45e                	sd	s7,8(sp)
    8000285c:	e062                	sd	s8,0(sp)
    8000285e:	0880                	addi	s0,sp,80
    80002860:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002862:	fffff097          	auipc	ra,0xfffff
    80002866:	73a080e7          	jalr	1850(ra) # 80001f9c <myproc>
    8000286a:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000286c:	8c2a                	mv	s8,a0
    8000286e:	ffffe097          	auipc	ra,0xffffe
    80002872:	41a080e7          	jalr	1050(ra) # 80000c88 <acquire>
    havekids = 0;
    80002876:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002878:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000287a:	0001a997          	auipc	s3,0x1a
    8000287e:	81e98993          	addi	s3,s3,-2018 # 8001c098 <tickslock>
        havekids = 1;
    80002882:	4a85                	li	s5,1
    havekids = 0;
    80002884:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002886:	00013497          	auipc	s1,0x13
    8000288a:	61248493          	addi	s1,s1,1554 # 80015e98 <proc>
    8000288e:	a08d                	j	800028f0 <wait+0xa8>
          pid = np->pid;
    80002890:	0504a983          	lw	s3,80(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002894:	000b0e63          	beqz	s6,800028b0 <wait+0x68>
    80002898:	4691                	li	a3,4
    8000289a:	04c48613          	addi	a2,s1,76
    8000289e:	85da                	mv	a1,s6
    800028a0:	06893503          	ld	a0,104(s2)
    800028a4:	fffff097          	auipc	ra,0xfffff
    800028a8:	2fa080e7          	jalr	762(ra) # 80001b9e <copyout>
    800028ac:	02054263          	bltz	a0,800028d0 <wait+0x88>
          freeproc(np);
    800028b0:	8526                	mv	a0,s1
    800028b2:	00000097          	auipc	ra,0x0
    800028b6:	90a080e7          	jalr	-1782(ra) # 800021bc <freeproc>
          release(&np->lock);
    800028ba:	8526                	mv	a0,s1
    800028bc:	ffffe097          	auipc	ra,0xffffe
    800028c0:	618080e7          	jalr	1560(ra) # 80000ed4 <release>
          release(&p->lock);
    800028c4:	854a                	mv	a0,s2
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	60e080e7          	jalr	1550(ra) # 80000ed4 <release>
          return pid;
    800028ce:	a8a9                	j	80002928 <wait+0xe0>
            release(&np->lock);
    800028d0:	8526                	mv	a0,s1
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	602080e7          	jalr	1538(ra) # 80000ed4 <release>
            release(&p->lock);
    800028da:	854a                	mv	a0,s2
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	5f8080e7          	jalr	1528(ra) # 80000ed4 <release>
            return -1;
    800028e4:	59fd                	li	s3,-1
    800028e6:	a089                	j	80002928 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    800028e8:	18848493          	addi	s1,s1,392
    800028ec:	03348463          	beq	s1,s3,80002914 <wait+0xcc>
      if(np->parent == p){
    800028f0:	7c9c                	ld	a5,56(s1)
    800028f2:	ff279be3          	bne	a5,s2,800028e8 <wait+0xa0>
        acquire(&np->lock);
    800028f6:	8526                	mv	a0,s1
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	390080e7          	jalr	912(ra) # 80000c88 <acquire>
        if(np->state == ZOMBIE){
    80002900:	589c                	lw	a5,48(s1)
    80002902:	f94787e3          	beq	a5,s4,80002890 <wait+0x48>
        release(&np->lock);
    80002906:	8526                	mv	a0,s1
    80002908:	ffffe097          	auipc	ra,0xffffe
    8000290c:	5cc080e7          	jalr	1484(ra) # 80000ed4 <release>
        havekids = 1;
    80002910:	8756                	mv	a4,s5
    80002912:	bfd9                	j	800028e8 <wait+0xa0>
    if(!havekids || p->killed){
    80002914:	c701                	beqz	a4,8000291c <wait+0xd4>
    80002916:	04892783          	lw	a5,72(s2)
    8000291a:	c785                	beqz	a5,80002942 <wait+0xfa>
      release(&p->lock);
    8000291c:	854a                	mv	a0,s2
    8000291e:	ffffe097          	auipc	ra,0xffffe
    80002922:	5b6080e7          	jalr	1462(ra) # 80000ed4 <release>
      return -1;
    80002926:	59fd                	li	s3,-1
}
    80002928:	854e                	mv	a0,s3
    8000292a:	60a6                	ld	ra,72(sp)
    8000292c:	6406                	ld	s0,64(sp)
    8000292e:	74e2                	ld	s1,56(sp)
    80002930:	7942                	ld	s2,48(sp)
    80002932:	79a2                	ld	s3,40(sp)
    80002934:	7a02                	ld	s4,32(sp)
    80002936:	6ae2                	ld	s5,24(sp)
    80002938:	6b42                	ld	s6,16(sp)
    8000293a:	6ba2                	ld	s7,8(sp)
    8000293c:	6c02                	ld	s8,0(sp)
    8000293e:	6161                	addi	sp,sp,80
    80002940:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002942:	85e2                	mv	a1,s8
    80002944:	854a                	mv	a0,s2
    80002946:	00000097          	auipc	ra,0x0
    8000294a:	e84080e7          	jalr	-380(ra) # 800027ca <sleep>
    havekids = 0;
    8000294e:	bf1d                	j	80002884 <wait+0x3c>

0000000080002950 <wakeup>:
{
    80002950:	7139                	addi	sp,sp,-64
    80002952:	fc06                	sd	ra,56(sp)
    80002954:	f822                	sd	s0,48(sp)
    80002956:	f426                	sd	s1,40(sp)
    80002958:	f04a                	sd	s2,32(sp)
    8000295a:	ec4e                	sd	s3,24(sp)
    8000295c:	e852                	sd	s4,16(sp)
    8000295e:	e456                	sd	s5,8(sp)
    80002960:	0080                	addi	s0,sp,64
    80002962:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002964:	00013497          	auipc	s1,0x13
    80002968:	53448493          	addi	s1,s1,1332 # 80015e98 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000296c:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000296e:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002970:	00019917          	auipc	s2,0x19
    80002974:	72890913          	addi	s2,s2,1832 # 8001c098 <tickslock>
    80002978:	a821                	j	80002990 <wakeup+0x40>
      p->state = RUNNABLE;
    8000297a:	0354a823          	sw	s5,48(s1)
    release(&p->lock);
    8000297e:	8526                	mv	a0,s1
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	554080e7          	jalr	1364(ra) # 80000ed4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002988:	18848493          	addi	s1,s1,392
    8000298c:	01248e63          	beq	s1,s2,800029a8 <wakeup+0x58>
    acquire(&p->lock);
    80002990:	8526                	mv	a0,s1
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	2f6080e7          	jalr	758(ra) # 80000c88 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000299a:	589c                	lw	a5,48(s1)
    8000299c:	ff3791e3          	bne	a5,s3,8000297e <wakeup+0x2e>
    800029a0:	60bc                	ld	a5,64(s1)
    800029a2:	fd479ee3          	bne	a5,s4,8000297e <wakeup+0x2e>
    800029a6:	bfd1                	j	8000297a <wakeup+0x2a>
}
    800029a8:	70e2                	ld	ra,56(sp)
    800029aa:	7442                	ld	s0,48(sp)
    800029ac:	74a2                	ld	s1,40(sp)
    800029ae:	7902                	ld	s2,32(sp)
    800029b0:	69e2                	ld	s3,24(sp)
    800029b2:	6a42                	ld	s4,16(sp)
    800029b4:	6aa2                	ld	s5,8(sp)
    800029b6:	6121                	addi	sp,sp,64
    800029b8:	8082                	ret

00000000800029ba <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800029ba:	7179                	addi	sp,sp,-48
    800029bc:	f406                	sd	ra,40(sp)
    800029be:	f022                	sd	s0,32(sp)
    800029c0:	ec26                	sd	s1,24(sp)
    800029c2:	e84a                	sd	s2,16(sp)
    800029c4:	e44e                	sd	s3,8(sp)
    800029c6:	1800                	addi	s0,sp,48
    800029c8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800029ca:	00013497          	auipc	s1,0x13
    800029ce:	4ce48493          	addi	s1,s1,1230 # 80015e98 <proc>
    800029d2:	00019997          	auipc	s3,0x19
    800029d6:	6c698993          	addi	s3,s3,1734 # 8001c098 <tickslock>
    acquire(&p->lock);
    800029da:	8526                	mv	a0,s1
    800029dc:	ffffe097          	auipc	ra,0xffffe
    800029e0:	2ac080e7          	jalr	684(ra) # 80000c88 <acquire>
    if(p->pid == pid){
    800029e4:	48bc                	lw	a5,80(s1)
    800029e6:	01278d63          	beq	a5,s2,80002a00 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800029ea:	8526                	mv	a0,s1
    800029ec:	ffffe097          	auipc	ra,0xffffe
    800029f0:	4e8080e7          	jalr	1256(ra) # 80000ed4 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800029f4:	18848493          	addi	s1,s1,392
    800029f8:	ff3491e3          	bne	s1,s3,800029da <kill+0x20>
  }
  return -1;
    800029fc:	557d                	li	a0,-1
    800029fe:	a829                	j	80002a18 <kill+0x5e>
      p->killed = 1;
    80002a00:	4785                	li	a5,1
    80002a02:	c4bc                	sw	a5,72(s1)
      if(p->state == SLEEPING){
    80002a04:	5898                	lw	a4,48(s1)
    80002a06:	4785                	li	a5,1
    80002a08:	00f70f63          	beq	a4,a5,80002a26 <kill+0x6c>
      release(&p->lock);
    80002a0c:	8526                	mv	a0,s1
    80002a0e:	ffffe097          	auipc	ra,0xffffe
    80002a12:	4c6080e7          	jalr	1222(ra) # 80000ed4 <release>
      return 0;
    80002a16:	4501                	li	a0,0
}
    80002a18:	70a2                	ld	ra,40(sp)
    80002a1a:	7402                	ld	s0,32(sp)
    80002a1c:	64e2                	ld	s1,24(sp)
    80002a1e:	6942                	ld	s2,16(sp)
    80002a20:	69a2                	ld	s3,8(sp)
    80002a22:	6145                	addi	sp,sp,48
    80002a24:	8082                	ret
        p->state = RUNNABLE;
    80002a26:	4789                	li	a5,2
    80002a28:	d89c                	sw	a5,48(s1)
    80002a2a:	b7cd                	j	80002a0c <kill+0x52>

0000000080002a2c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a2c:	7179                	addi	sp,sp,-48
    80002a2e:	f406                	sd	ra,40(sp)
    80002a30:	f022                	sd	s0,32(sp)
    80002a32:	ec26                	sd	s1,24(sp)
    80002a34:	e84a                	sd	s2,16(sp)
    80002a36:	e44e                	sd	s3,8(sp)
    80002a38:	e052                	sd	s4,0(sp)
    80002a3a:	1800                	addi	s0,sp,48
    80002a3c:	84aa                	mv	s1,a0
    80002a3e:	892e                	mv	s2,a1
    80002a40:	89b2                	mv	s3,a2
    80002a42:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a44:	fffff097          	auipc	ra,0xfffff
    80002a48:	558080e7          	jalr	1368(ra) # 80001f9c <myproc>
  if(user_dst){
    80002a4c:	c08d                	beqz	s1,80002a6e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002a4e:	86d2                	mv	a3,s4
    80002a50:	864e                	mv	a2,s3
    80002a52:	85ca                	mv	a1,s2
    80002a54:	7528                	ld	a0,104(a0)
    80002a56:	fffff097          	auipc	ra,0xfffff
    80002a5a:	148080e7          	jalr	328(ra) # 80001b9e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a5e:	70a2                	ld	ra,40(sp)
    80002a60:	7402                	ld	s0,32(sp)
    80002a62:	64e2                	ld	s1,24(sp)
    80002a64:	6942                	ld	s2,16(sp)
    80002a66:	69a2                	ld	s3,8(sp)
    80002a68:	6a02                	ld	s4,0(sp)
    80002a6a:	6145                	addi	sp,sp,48
    80002a6c:	8082                	ret
    memmove((char *)dst, src, len);
    80002a6e:	000a061b          	sext.w	a2,s4
    80002a72:	85ce                	mv	a1,s3
    80002a74:	854a                	mv	a0,s2
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	6be080e7          	jalr	1726(ra) # 80001134 <memmove>
    return 0;
    80002a7e:	8526                	mv	a0,s1
    80002a80:	bff9                	j	80002a5e <either_copyout+0x32>

0000000080002a82 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a82:	7179                	addi	sp,sp,-48
    80002a84:	f406                	sd	ra,40(sp)
    80002a86:	f022                	sd	s0,32(sp)
    80002a88:	ec26                	sd	s1,24(sp)
    80002a8a:	e84a                	sd	s2,16(sp)
    80002a8c:	e44e                	sd	s3,8(sp)
    80002a8e:	e052                	sd	s4,0(sp)
    80002a90:	1800                	addi	s0,sp,48
    80002a92:	892a                	mv	s2,a0
    80002a94:	84ae                	mv	s1,a1
    80002a96:	89b2                	mv	s3,a2
    80002a98:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a9a:	fffff097          	auipc	ra,0xfffff
    80002a9e:	502080e7          	jalr	1282(ra) # 80001f9c <myproc>
  if(user_src){
    80002aa2:	c08d                	beqz	s1,80002ac4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002aa4:	86d2                	mv	a3,s4
    80002aa6:	864e                	mv	a2,s3
    80002aa8:	85ca                	mv	a1,s2
    80002aaa:	7528                	ld	a0,104(a0)
    80002aac:	fffff097          	auipc	ra,0xfffff
    80002ab0:	17e080e7          	jalr	382(ra) # 80001c2a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002ab4:	70a2                	ld	ra,40(sp)
    80002ab6:	7402                	ld	s0,32(sp)
    80002ab8:	64e2                	ld	s1,24(sp)
    80002aba:	6942                	ld	s2,16(sp)
    80002abc:	69a2                	ld	s3,8(sp)
    80002abe:	6a02                	ld	s4,0(sp)
    80002ac0:	6145                	addi	sp,sp,48
    80002ac2:	8082                	ret
    memmove(dst, (char*)src, len);
    80002ac4:	000a061b          	sext.w	a2,s4
    80002ac8:	85ce                	mv	a1,s3
    80002aca:	854a                	mv	a0,s2
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	668080e7          	jalr	1640(ra) # 80001134 <memmove>
    return 0;
    80002ad4:	8526                	mv	a0,s1
    80002ad6:	bff9                	j	80002ab4 <either_copyin+0x32>

0000000080002ad8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002ad8:	715d                	addi	sp,sp,-80
    80002ada:	e486                	sd	ra,72(sp)
    80002adc:	e0a2                	sd	s0,64(sp)
    80002ade:	fc26                	sd	s1,56(sp)
    80002ae0:	f84a                	sd	s2,48(sp)
    80002ae2:	f44e                	sd	s3,40(sp)
    80002ae4:	f052                	sd	s4,32(sp)
    80002ae6:	ec56                	sd	s5,24(sp)
    80002ae8:	e85a                	sd	s6,16(sp)
    80002aea:	e45e                	sd	s7,8(sp)
    80002aec:	e062                	sd	s8,0(sp)
    80002aee:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\nPID\tPPID\tPRIO\tSTATE\tCMD\n");
    80002af0:	00006517          	auipc	a0,0x6
    80002af4:	b4050513          	addi	a0,a0,-1216 # 80008630 <userret+0x5a0>
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	e74080e7          	jalr	-396(ra) # 8000096c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b00:	00013497          	auipc	s1,0x13
    80002b04:	39848493          	addi	s1,s1,920 # 80015e98 <proc>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b08:	4b91                	li	s7,4
      state = states[p->state];
    else
      state = "???";
    80002b0a:	00006997          	auipc	s3,0x6
    80002b0e:	b1e98993          	addi	s3,s3,-1250 # 80008628 <userret+0x598>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002b12:	5b7d                	li	s6,-1
    80002b14:	00006a97          	auipc	s5,0x6
    80002b18:	b3ca8a93          	addi	s5,s5,-1220 # 80008650 <userret+0x5c0>
           p->parent ? p->parent->pid : -1,
           p->priority,
           state,
           p->cmd
           );
    printf("\n");
    80002b1c:	00006a17          	auipc	s4,0x6
    80002b20:	b2ca0a13          	addi	s4,s4,-1236 # 80008648 <userret+0x5b8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b24:	00006c17          	auipc	s8,0x6
    80002b28:	41cc0c13          	addi	s8,s8,1052 # 80008f40 <states.1827>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b2c:	00019917          	auipc	s2,0x19
    80002b30:	56c90913          	addi	s2,s2,1388 # 8001c098 <tickslock>
    80002b34:	a03d                	j	80002b62 <procdump+0x8a>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002b36:	48ac                	lw	a1,80(s1)
           p->parent ? p->parent->pid : -1,
    80002b38:	7c9c                	ld	a5,56(s1)
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002b3a:	865a                	mv	a2,s6
    80002b3c:	c391                	beqz	a5,80002b40 <procdump+0x68>
    80002b3e:	4bb0                	lw	a2,80(a5)
    80002b40:	1804b783          	ld	a5,384(s1)
    80002b44:	48f4                	lw	a3,84(s1)
    80002b46:	8556                	mv	a0,s5
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	e24080e7          	jalr	-476(ra) # 8000096c <printf>
    printf("\n");
    80002b50:	8552                	mv	a0,s4
    80002b52:	ffffe097          	auipc	ra,0xffffe
    80002b56:	e1a080e7          	jalr	-486(ra) # 8000096c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b5a:	18848493          	addi	s1,s1,392
    80002b5e:	01248f63          	beq	s1,s2,80002b7c <procdump+0xa4>
    if(p->state == UNUSED)
    80002b62:	589c                	lw	a5,48(s1)
    80002b64:	dbfd                	beqz	a5,80002b5a <procdump+0x82>
      state = "???";
    80002b66:	874e                	mv	a4,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b68:	fcfbe7e3          	bltu	s7,a5,80002b36 <procdump+0x5e>
    80002b6c:	1782                	slli	a5,a5,0x20
    80002b6e:	9381                	srli	a5,a5,0x20
    80002b70:	078e                	slli	a5,a5,0x3
    80002b72:	97e2                	add	a5,a5,s8
    80002b74:	6398                	ld	a4,0(a5)
    80002b76:	f361                	bnez	a4,80002b36 <procdump+0x5e>
      state = "???";
    80002b78:	874e                	mv	a4,s3
    80002b7a:	bf75                	j	80002b36 <procdump+0x5e>
  }
}
    80002b7c:	60a6                	ld	ra,72(sp)
    80002b7e:	6406                	ld	s0,64(sp)
    80002b80:	74e2                	ld	s1,56(sp)
    80002b82:	7942                	ld	s2,48(sp)
    80002b84:	79a2                	ld	s3,40(sp)
    80002b86:	7a02                	ld	s4,32(sp)
    80002b88:	6ae2                	ld	s5,24(sp)
    80002b8a:	6b42                	ld	s6,16(sp)
    80002b8c:	6ba2                	ld	s7,8(sp)
    80002b8e:	6c02                	ld	s8,0(sp)
    80002b90:	6161                	addi	sp,sp,80
    80002b92:	8082                	ret

0000000080002b94 <priodump>:

// No lock to avoid wedging a stuck machine further.
void priodump(void){
    80002b94:	715d                	addi	sp,sp,-80
    80002b96:	e486                	sd	ra,72(sp)
    80002b98:	e0a2                	sd	s0,64(sp)
    80002b9a:	fc26                	sd	s1,56(sp)
    80002b9c:	f84a                	sd	s2,48(sp)
    80002b9e:	f44e                	sd	s3,40(sp)
    80002ba0:	f052                	sd	s4,32(sp)
    80002ba2:	ec56                	sd	s5,24(sp)
    80002ba4:	e85a                	sd	s6,16(sp)
    80002ba6:	e45e                	sd	s7,8(sp)
    80002ba8:	0880                	addi	s0,sp,80
  for (int i = 0; i < NPRIO; i++){
    80002baa:	00013a17          	auipc	s4,0x13
    80002bae:	e3ea0a13          	addi	s4,s4,-450 # 800159e8 <prio>
    80002bb2:	4981                	li	s3,0
    struct list_proc* l = prio[i];
    printf("Priority queue for priority = %d: ", i);
    80002bb4:	00006b97          	auipc	s7,0x6
    80002bb8:	ab4b8b93          	addi	s7,s7,-1356 # 80008668 <userret+0x5d8>
    while(l){
      printf("%d ", l->p->pid);
    80002bbc:	00006917          	auipc	s2,0x6
    80002bc0:	ad490913          	addi	s2,s2,-1324 # 80008690 <userret+0x600>
      l = l->next;
    }
    printf("\n");
    80002bc4:	00006b17          	auipc	s6,0x6
    80002bc8:	a84b0b13          	addi	s6,s6,-1404 # 80008648 <userret+0x5b8>
  for (int i = 0; i < NPRIO; i++){
    80002bcc:	4aa9                	li	s5,10
    80002bce:	a811                	j	80002be2 <priodump+0x4e>
    printf("\n");
    80002bd0:	855a                	mv	a0,s6
    80002bd2:	ffffe097          	auipc	ra,0xffffe
    80002bd6:	d9a080e7          	jalr	-614(ra) # 8000096c <printf>
  for (int i = 0; i < NPRIO; i++){
    80002bda:	2985                	addiw	s3,s3,1
    80002bdc:	0a21                	addi	s4,s4,8
    80002bde:	03598563          	beq	s3,s5,80002c08 <priodump+0x74>
    struct list_proc* l = prio[i];
    80002be2:	000a3483          	ld	s1,0(s4)
    printf("Priority queue for priority = %d: ", i);
    80002be6:	85ce                	mv	a1,s3
    80002be8:	855e                	mv	a0,s7
    80002bea:	ffffe097          	auipc	ra,0xffffe
    80002bee:	d82080e7          	jalr	-638(ra) # 8000096c <printf>
    while(l){
    80002bf2:	dcf9                	beqz	s1,80002bd0 <priodump+0x3c>
      printf("%d ", l->p->pid);
    80002bf4:	609c                	ld	a5,0(s1)
    80002bf6:	4bac                	lw	a1,80(a5)
    80002bf8:	854a                	mv	a0,s2
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	d72080e7          	jalr	-654(ra) # 8000096c <printf>
      l = l->next;
    80002c02:	6484                	ld	s1,8(s1)
    while(l){
    80002c04:	f8e5                	bnez	s1,80002bf4 <priodump+0x60>
    80002c06:	b7e9                	j	80002bd0 <priodump+0x3c>
  }
}
    80002c08:	60a6                	ld	ra,72(sp)
    80002c0a:	6406                	ld	s0,64(sp)
    80002c0c:	74e2                	ld	s1,56(sp)
    80002c0e:	7942                	ld	s2,48(sp)
    80002c10:	79a2                	ld	s3,40(sp)
    80002c12:	7a02                	ld	s4,32(sp)
    80002c14:	6ae2                	ld	s5,24(sp)
    80002c16:	6b42                	ld	s6,16(sp)
    80002c18:	6ba2                	ld	s7,8(sp)
    80002c1a:	6161                	addi	sp,sp,80
    80002c1c:	8082                	ret

0000000080002c1e <swtch>:
    80002c1e:	00153023          	sd	ra,0(a0)
    80002c22:	00253423          	sd	sp,8(a0)
    80002c26:	e900                	sd	s0,16(a0)
    80002c28:	ed04                	sd	s1,24(a0)
    80002c2a:	03253023          	sd	s2,32(a0)
    80002c2e:	03353423          	sd	s3,40(a0)
    80002c32:	03453823          	sd	s4,48(a0)
    80002c36:	03553c23          	sd	s5,56(a0)
    80002c3a:	05653023          	sd	s6,64(a0)
    80002c3e:	05753423          	sd	s7,72(a0)
    80002c42:	05853823          	sd	s8,80(a0)
    80002c46:	05953c23          	sd	s9,88(a0)
    80002c4a:	07a53023          	sd	s10,96(a0)
    80002c4e:	07b53423          	sd	s11,104(a0)
    80002c52:	0005b083          	ld	ra,0(a1)
    80002c56:	0085b103          	ld	sp,8(a1)
    80002c5a:	6980                	ld	s0,16(a1)
    80002c5c:	6d84                	ld	s1,24(a1)
    80002c5e:	0205b903          	ld	s2,32(a1)
    80002c62:	0285b983          	ld	s3,40(a1)
    80002c66:	0305ba03          	ld	s4,48(a1)
    80002c6a:	0385ba83          	ld	s5,56(a1)
    80002c6e:	0405bb03          	ld	s6,64(a1)
    80002c72:	0485bb83          	ld	s7,72(a1)
    80002c76:	0505bc03          	ld	s8,80(a1)
    80002c7a:	0585bc83          	ld	s9,88(a1)
    80002c7e:	0605bd03          	ld	s10,96(a1)
    80002c82:	0685bd83          	ld	s11,104(a1)
    80002c86:	8082                	ret

0000000080002c88 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002c88:	1141                	addi	sp,sp,-16
    80002c8a:	e422                	sd	s0,8(sp)
    80002c8c:	0800                	addi	s0,sp,16
    80002c8e:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002c90:	00151713          	slli	a4,a0,0x1
    80002c94:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    80002c96:	04054c63          	bltz	a0,80002cee <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002c9a:	5685                	li	a3,-31
    80002c9c:	8285                	srli	a3,a3,0x1
    80002c9e:	8ee9                	and	a3,a3,a0
    80002ca0:	caad                	beqz	a3,80002d12 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002ca2:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002ca4:	00006517          	auipc	a0,0x6
    80002ca8:	a1c50513          	addi	a0,a0,-1508 # 800086c0 <userret+0x630>
    } else if (code <= 23) {
    80002cac:	06e6f063          	bgeu	a3,a4,80002d0c <scause_desc+0x84>
    } else if (code <= 31) {
    80002cb0:	fc100693          	li	a3,-63
    80002cb4:	8285                	srli	a3,a3,0x1
    80002cb6:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    80002cb8:	00006517          	auipc	a0,0x6
    80002cbc:	a3050513          	addi	a0,a0,-1488 # 800086e8 <userret+0x658>
    } else if (code <= 31) {
    80002cc0:	c6b1                	beqz	a3,80002d0c <scause_desc+0x84>
    } else if (code <= 47) {
    80002cc2:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    80002cc6:	00006517          	auipc	a0,0x6
    80002cca:	9fa50513          	addi	a0,a0,-1542 # 800086c0 <userret+0x630>
    } else if (code <= 47) {
    80002cce:	02e6ff63          	bgeu	a3,a4,80002d0c <scause_desc+0x84>
    } else if (code <= 63) {
    80002cd2:	f8100513          	li	a0,-127
    80002cd6:	8105                	srli	a0,a0,0x1
    80002cd8:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    80002cda:	00006517          	auipc	a0,0x6
    80002cde:	a0e50513          	addi	a0,a0,-1522 # 800086e8 <userret+0x658>
    } else if (code <= 63) {
    80002ce2:	c78d                	beqz	a5,80002d0c <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    80002ce4:	00006517          	auipc	a0,0x6
    80002ce8:	9dc50513          	addi	a0,a0,-1572 # 800086c0 <userret+0x630>
    80002cec:	a005                	j	80002d0c <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    80002cee:	5505                	li	a0,-31
    80002cf0:	8105                	srli	a0,a0,0x1
    80002cf2:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    80002cf4:	00006517          	auipc	a0,0x6
    80002cf8:	a1450513          	addi	a0,a0,-1516 # 80008708 <userret+0x678>
    if (code < NELEM(intr_desc)) {
    80002cfc:	eb81                	bnez	a5,80002d0c <scause_desc+0x84>
      return intr_desc[code];
    80002cfe:	070e                	slli	a4,a4,0x3
    80002d00:	00006797          	auipc	a5,0x6
    80002d04:	26878793          	addi	a5,a5,616 # 80008f68 <intr_desc.1629>
    80002d08:	973e                	add	a4,a4,a5
    80002d0a:	6308                	ld	a0,0(a4)
    }
  }
}
    80002d0c:	6422                	ld	s0,8(sp)
    80002d0e:	0141                	addi	sp,sp,16
    80002d10:	8082                	ret
      return nointr_desc[code];
    80002d12:	070e                	slli	a4,a4,0x3
    80002d14:	00006797          	auipc	a5,0x6
    80002d18:	25478793          	addi	a5,a5,596 # 80008f68 <intr_desc.1629>
    80002d1c:	973e                	add	a4,a4,a5
    80002d1e:	6348                	ld	a0,128(a4)
    80002d20:	b7f5                	j	80002d0c <scause_desc+0x84>

0000000080002d22 <trapinit>:
{
    80002d22:	1141                	addi	sp,sp,-16
    80002d24:	e406                	sd	ra,8(sp)
    80002d26:	e022                	sd	s0,0(sp)
    80002d28:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002d2a:	00006597          	auipc	a1,0x6
    80002d2e:	9fe58593          	addi	a1,a1,-1538 # 80008728 <userret+0x698>
    80002d32:	00019517          	auipc	a0,0x19
    80002d36:	36650513          	addi	a0,a0,870 # 8001c098 <tickslock>
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	de4080e7          	jalr	-540(ra) # 80000b1e <initlock>
}
    80002d42:	60a2                	ld	ra,8(sp)
    80002d44:	6402                	ld	s0,0(sp)
    80002d46:	0141                	addi	sp,sp,16
    80002d48:	8082                	ret

0000000080002d4a <trapinithart>:
{
    80002d4a:	1141                	addi	sp,sp,-16
    80002d4c:	e422                	sd	s0,8(sp)
    80002d4e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d50:	00003797          	auipc	a5,0x3
    80002d54:	66078793          	addi	a5,a5,1632 # 800063b0 <kernelvec>
    80002d58:	10579073          	csrw	stvec,a5
}
    80002d5c:	6422                	ld	s0,8(sp)
    80002d5e:	0141                	addi	sp,sp,16
    80002d60:	8082                	ret

0000000080002d62 <usertrapret>:
{
    80002d62:	1141                	addi	sp,sp,-16
    80002d64:	e406                	sd	ra,8(sp)
    80002d66:	e022                	sd	s0,0(sp)
    80002d68:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	232080e7          	jalr	562(ra) # 80001f9c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d72:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002d76:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d78:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002d7c:	00005617          	auipc	a2,0x5
    80002d80:	28460613          	addi	a2,a2,644 # 80008000 <trampoline>
    80002d84:	00005697          	auipc	a3,0x5
    80002d88:	27c68693          	addi	a3,a3,636 # 80008000 <trampoline>
    80002d8c:	8e91                	sub	a3,a3,a2
    80002d8e:	040007b7          	lui	a5,0x4000
    80002d92:	17fd                	addi	a5,a5,-1
    80002d94:	07b2                	slli	a5,a5,0xc
    80002d96:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d98:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002d9c:	7938                	ld	a4,112(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d9e:	180026f3          	csrr	a3,satp
    80002da2:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002da4:	7938                	ld	a4,112(a0)
    80002da6:	6d34                	ld	a3,88(a0)
    80002da8:	6585                	lui	a1,0x1
    80002daa:	96ae                	add	a3,a3,a1
    80002dac:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002dae:	7938                	ld	a4,112(a0)
    80002db0:	00000697          	auipc	a3,0x0
    80002db4:	17e68693          	addi	a3,a3,382 # 80002f2e <usertrap>
    80002db8:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    80002dba:	7938                	ld	a4,112(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002dbc:	8692                	mv	a3,tp
    80002dbe:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dc0:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002dc4:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002dc8:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dcc:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    80002dd0:	7938                	ld	a4,112(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dd2:	6f18                	ld	a4,24(a4)
    80002dd4:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002dd8:	752c                	ld	a1,104(a0)
    80002dda:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002ddc:	00005717          	auipc	a4,0x5
    80002de0:	2b470713          	addi	a4,a4,692 # 80008090 <userret>
    80002de4:	8f11                	sub	a4,a4,a2
    80002de6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002de8:	577d                	li	a4,-1
    80002dea:	177e                	slli	a4,a4,0x3f
    80002dec:	8dd9                	or	a1,a1,a4
    80002dee:	02000537          	lui	a0,0x2000
    80002df2:	157d                	addi	a0,a0,-1
    80002df4:	0536                	slli	a0,a0,0xd
    80002df6:	9782                	jalr	a5
}
    80002df8:	60a2                	ld	ra,8(sp)
    80002dfa:	6402                	ld	s0,0(sp)
    80002dfc:	0141                	addi	sp,sp,16
    80002dfe:	8082                	ret

0000000080002e00 <clockintr>:
{
    80002e00:	1141                	addi	sp,sp,-16
    80002e02:	e406                	sd	ra,8(sp)
    80002e04:	e022                	sd	s0,0(sp)
    80002e06:	0800                	addi	s0,sp,16
  acquire(&watchdog_lock);
    80002e08:	0002b517          	auipc	a0,0x2b
    80002e0c:	22850513          	addi	a0,a0,552 # 8002e030 <watchdog_lock>
    80002e10:	ffffe097          	auipc	ra,0xffffe
    80002e14:	e78080e7          	jalr	-392(ra) # 80000c88 <acquire>
  acquire(&tickslock);
    80002e18:	00019517          	auipc	a0,0x19
    80002e1c:	28050513          	addi	a0,a0,640 # 8001c098 <tickslock>
    80002e20:	ffffe097          	auipc	ra,0xffffe
    80002e24:	e68080e7          	jalr	-408(ra) # 80000c88 <acquire>
  if (watchdog_time && ticks - watchdog_value > watchdog_time){
    80002e28:	0002b797          	auipc	a5,0x2b
    80002e2c:	27c7a783          	lw	a5,636(a5) # 8002e0a4 <watchdog_time>
    80002e30:	cf89                	beqz	a5,80002e4a <clockintr+0x4a>
    80002e32:	0002b717          	auipc	a4,0x2b
    80002e36:	25672703          	lw	a4,598(a4) # 8002e088 <ticks>
    80002e3a:	0002b697          	auipc	a3,0x2b
    80002e3e:	26e6a683          	lw	a3,622(a3) # 8002e0a8 <watchdog_value>
    80002e42:	9f15                	subw	a4,a4,a3
    80002e44:	2781                	sext.w	a5,a5
    80002e46:	04e7e163          	bltu	a5,a4,80002e88 <clockintr+0x88>
  ticks++;
    80002e4a:	0002b517          	auipc	a0,0x2b
    80002e4e:	23e50513          	addi	a0,a0,574 # 8002e088 <ticks>
    80002e52:	411c                	lw	a5,0(a0)
    80002e54:	2785                	addiw	a5,a5,1
    80002e56:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002e58:	00000097          	auipc	ra,0x0
    80002e5c:	af8080e7          	jalr	-1288(ra) # 80002950 <wakeup>
  release(&tickslock);
    80002e60:	00019517          	auipc	a0,0x19
    80002e64:	23850513          	addi	a0,a0,568 # 8001c098 <tickslock>
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	06c080e7          	jalr	108(ra) # 80000ed4 <release>
  release(&watchdog_lock);
    80002e70:	0002b517          	auipc	a0,0x2b
    80002e74:	1c050513          	addi	a0,a0,448 # 8002e030 <watchdog_lock>
    80002e78:	ffffe097          	auipc	ra,0xffffe
    80002e7c:	05c080e7          	jalr	92(ra) # 80000ed4 <release>
}
    80002e80:	60a2                	ld	ra,8(sp)
    80002e82:	6402                	ld	s0,0(sp)
    80002e84:	0141                	addi	sp,sp,16
    80002e86:	8082                	ret
    panic("watchdog !!!");
    80002e88:	00006517          	auipc	a0,0x6
    80002e8c:	8a850513          	addi	a0,a0,-1880 # 80008730 <userret+0x6a0>
    80002e90:	ffffe097          	auipc	ra,0xffffe
    80002e94:	8c6080e7          	jalr	-1850(ra) # 80000756 <panic>

0000000080002e98 <devintr>:
{
    80002e98:	1101                	addi	sp,sp,-32
    80002e9a:	ec06                	sd	ra,24(sp)
    80002e9c:	e822                	sd	s0,16(sp)
    80002e9e:	e426                	sd	s1,8(sp)
    80002ea0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ea2:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002ea6:	00074d63          	bltz	a4,80002ec0 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002eaa:	57fd                	li	a5,-1
    80002eac:	17fe                	slli	a5,a5,0x3f
    80002eae:	0785                	addi	a5,a5,1
    return 0;
    80002eb0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002eb2:	04f70d63          	beq	a4,a5,80002f0c <devintr+0x74>
}
    80002eb6:	60e2                	ld	ra,24(sp)
    80002eb8:	6442                	ld	s0,16(sp)
    80002eba:	64a2                	ld	s1,8(sp)
    80002ebc:	6105                	addi	sp,sp,32
    80002ebe:	8082                	ret
     (scause & 0xff) == 9){
    80002ec0:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002ec4:	46a5                	li	a3,9
    80002ec6:	fed792e3          	bne	a5,a3,80002eaa <devintr+0x12>
    int irq = plic_claim();
    80002eca:	00003097          	auipc	ra,0x3
    80002ece:	5ee080e7          	jalr	1518(ra) # 800064b8 <plic_claim>
    80002ed2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ed4:	47a9                	li	a5,10
    80002ed6:	00f50a63          	beq	a0,a5,80002eea <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80002eda:	fff5079b          	addiw	a5,a0,-1
    80002ede:	4705                	li	a4,1
    80002ee0:	00f77a63          	bgeu	a4,a5,80002ef4 <devintr+0x5c>
    return 1;
    80002ee4:	4505                	li	a0,1
    if(irq)
    80002ee6:	d8e1                	beqz	s1,80002eb6 <devintr+0x1e>
    80002ee8:	a819                	j	80002efe <devintr+0x66>
      uartintr();
    80002eea:	ffffe097          	auipc	ra,0xffffe
    80002eee:	bae080e7          	jalr	-1106(ra) # 80000a98 <uartintr>
    80002ef2:	a031                	j	80002efe <devintr+0x66>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    80002ef4:	853e                	mv	a0,a5
    80002ef6:	00004097          	auipc	ra,0x4
    80002efa:	bb0080e7          	jalr	-1104(ra) # 80006aa6 <virtio_disk_intr>
      plic_complete(irq);
    80002efe:	8526                	mv	a0,s1
    80002f00:	00003097          	auipc	ra,0x3
    80002f04:	5dc080e7          	jalr	1500(ra) # 800064dc <plic_complete>
    return 1;
    80002f08:	4505                	li	a0,1
    80002f0a:	b775                	j	80002eb6 <devintr+0x1e>
    if(cpuid() == 0){
    80002f0c:	fffff097          	auipc	ra,0xfffff
    80002f10:	064080e7          	jalr	100(ra) # 80001f70 <cpuid>
    80002f14:	c901                	beqz	a0,80002f24 <devintr+0x8c>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002f16:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002f1a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002f1c:	14479073          	csrw	sip,a5
    return 2;
    80002f20:	4509                	li	a0,2
    80002f22:	bf51                	j	80002eb6 <devintr+0x1e>
      clockintr();
    80002f24:	00000097          	auipc	ra,0x0
    80002f28:	edc080e7          	jalr	-292(ra) # 80002e00 <clockintr>
    80002f2c:	b7ed                	j	80002f16 <devintr+0x7e>

0000000080002f2e <usertrap>:
{
    80002f2e:	7179                	addi	sp,sp,-48
    80002f30:	f406                	sd	ra,40(sp)
    80002f32:	f022                	sd	s0,32(sp)
    80002f34:	ec26                	sd	s1,24(sp)
    80002f36:	e84a                	sd	s2,16(sp)
    80002f38:	e44e                	sd	s3,8(sp)
    80002f3a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f3c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002f40:	1007f793          	andi	a5,a5,256
    80002f44:	e3b5                	bnez	a5,80002fa8 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f46:	00003797          	auipc	a5,0x3
    80002f4a:	46a78793          	addi	a5,a5,1130 # 800063b0 <kernelvec>
    80002f4e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002f52:	fffff097          	auipc	ra,0xfffff
    80002f56:	04a080e7          	jalr	74(ra) # 80001f9c <myproc>
    80002f5a:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002f5c:	793c                	ld	a5,112(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f5e:	14102773          	csrr	a4,sepc
    80002f62:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f64:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002f68:	47a1                	li	a5,8
    80002f6a:	04f71d63          	bne	a4,a5,80002fc4 <usertrap+0x96>
    if(p->killed)
    80002f6e:	453c                	lw	a5,72(a0)
    80002f70:	e7a1                	bnez	a5,80002fb8 <usertrap+0x8a>
    p->tf->epc += 4;
    80002f72:	78b8                	ld	a4,112(s1)
    80002f74:	6f1c                	ld	a5,24(a4)
    80002f76:	0791                	addi	a5,a5,4
    80002f78:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f7a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f7e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f82:	10079073          	csrw	sstatus,a5
    syscall();
    80002f86:	00000097          	auipc	ra,0x0
    80002f8a:	2fe080e7          	jalr	766(ra) # 80003284 <syscall>
  if(p->killed)
    80002f8e:	44bc                	lw	a5,72(s1)
    80002f90:	e3cd                	bnez	a5,80003032 <usertrap+0x104>
  usertrapret();
    80002f92:	00000097          	auipc	ra,0x0
    80002f96:	dd0080e7          	jalr	-560(ra) # 80002d62 <usertrapret>
}
    80002f9a:	70a2                	ld	ra,40(sp)
    80002f9c:	7402                	ld	s0,32(sp)
    80002f9e:	64e2                	ld	s1,24(sp)
    80002fa0:	6942                	ld	s2,16(sp)
    80002fa2:	69a2                	ld	s3,8(sp)
    80002fa4:	6145                	addi	sp,sp,48
    80002fa6:	8082                	ret
    panic("usertrap: not from user mode");
    80002fa8:	00005517          	auipc	a0,0x5
    80002fac:	79850513          	addi	a0,a0,1944 # 80008740 <userret+0x6b0>
    80002fb0:	ffffd097          	auipc	ra,0xffffd
    80002fb4:	7a6080e7          	jalr	1958(ra) # 80000756 <panic>
      exit(-1);
    80002fb8:	557d                	li	a0,-1
    80002fba:	fffff097          	auipc	ra,0xfffff
    80002fbe:	6c6080e7          	jalr	1734(ra) # 80002680 <exit>
    80002fc2:	bf45                	j	80002f72 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002fc4:	00000097          	auipc	ra,0x0
    80002fc8:	ed4080e7          	jalr	-300(ra) # 80002e98 <devintr>
    80002fcc:	892a                	mv	s2,a0
    80002fce:	c501                	beqz	a0,80002fd6 <usertrap+0xa8>
  if(p->killed)
    80002fd0:	44bc                	lw	a5,72(s1)
    80002fd2:	cba1                	beqz	a5,80003022 <usertrap+0xf4>
    80002fd4:	a091                	j	80003018 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fd6:	142029f3          	csrr	s3,scause
    80002fda:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002fde:	00000097          	auipc	ra,0x0
    80002fe2:	caa080e7          	jalr	-854(ra) # 80002c88 <scause_desc>
    80002fe6:	862a                	mv	a2,a0
    80002fe8:	48b4                	lw	a3,80(s1)
    80002fea:	85ce                	mv	a1,s3
    80002fec:	00005517          	auipc	a0,0x5
    80002ff0:	77450513          	addi	a0,a0,1908 # 80008760 <userret+0x6d0>
    80002ff4:	ffffe097          	auipc	ra,0xffffe
    80002ff8:	978080e7          	jalr	-1672(ra) # 8000096c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ffc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003000:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003004:	00005517          	auipc	a0,0x5
    80003008:	78c50513          	addi	a0,a0,1932 # 80008790 <userret+0x700>
    8000300c:	ffffe097          	auipc	ra,0xffffe
    80003010:	960080e7          	jalr	-1696(ra) # 8000096c <printf>
    p->killed = 1;
    80003014:	4785                	li	a5,1
    80003016:	c4bc                	sw	a5,72(s1)
    exit(-1);
    80003018:	557d                	li	a0,-1
    8000301a:	fffff097          	auipc	ra,0xfffff
    8000301e:	666080e7          	jalr	1638(ra) # 80002680 <exit>
  if(which_dev == 2)
    80003022:	4789                	li	a5,2
    80003024:	f6f917e3          	bne	s2,a5,80002f92 <usertrap+0x64>
    yield();
    80003028:	fffff097          	auipc	ra,0xfffff
    8000302c:	766080e7          	jalr	1894(ra) # 8000278e <yield>
    80003030:	b78d                	j	80002f92 <usertrap+0x64>
  int which_dev = 0;
    80003032:	4901                	li	s2,0
    80003034:	b7d5                	j	80003018 <usertrap+0xea>

0000000080003036 <kerneltrap>:
{
    80003036:	7179                	addi	sp,sp,-48
    80003038:	f406                	sd	ra,40(sp)
    8000303a:	f022                	sd	s0,32(sp)
    8000303c:	ec26                	sd	s1,24(sp)
    8000303e:	e84a                	sd	s2,16(sp)
    80003040:	e44e                	sd	s3,8(sp)
    80003042:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003044:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003048:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000304c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003050:	1004f793          	andi	a5,s1,256
    80003054:	cb85                	beqz	a5,80003084 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003056:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000305a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000305c:	ef85                	bnez	a5,80003094 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000305e:	00000097          	auipc	ra,0x0
    80003062:	e3a080e7          	jalr	-454(ra) # 80002e98 <devintr>
    80003066:	cd1d                	beqz	a0,800030a4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003068:	4789                	li	a5,2
    8000306a:	08f50063          	beq	a0,a5,800030ea <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000306e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003072:	10049073          	csrw	sstatus,s1
}
    80003076:	70a2                	ld	ra,40(sp)
    80003078:	7402                	ld	s0,32(sp)
    8000307a:	64e2                	ld	s1,24(sp)
    8000307c:	6942                	ld	s2,16(sp)
    8000307e:	69a2                	ld	s3,8(sp)
    80003080:	6145                	addi	sp,sp,48
    80003082:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003084:	00005517          	auipc	a0,0x5
    80003088:	72c50513          	addi	a0,a0,1836 # 800087b0 <userret+0x720>
    8000308c:	ffffd097          	auipc	ra,0xffffd
    80003090:	6ca080e7          	jalr	1738(ra) # 80000756 <panic>
    panic("kerneltrap: interrupts enabled");
    80003094:	00005517          	auipc	a0,0x5
    80003098:	74450513          	addi	a0,a0,1860 # 800087d8 <userret+0x748>
    8000309c:	ffffd097          	auipc	ra,0xffffd
    800030a0:	6ba080e7          	jalr	1722(ra) # 80000756 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    800030a4:	854e                	mv	a0,s3
    800030a6:	00000097          	auipc	ra,0x0
    800030aa:	be2080e7          	jalr	-1054(ra) # 80002c88 <scause_desc>
    800030ae:	862a                	mv	a2,a0
    800030b0:	85ce                	mv	a1,s3
    800030b2:	00005517          	auipc	a0,0x5
    800030b6:	74650513          	addi	a0,a0,1862 # 800087f8 <userret+0x768>
    800030ba:	ffffe097          	auipc	ra,0xffffe
    800030be:	8b2080e7          	jalr	-1870(ra) # 8000096c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030c2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800030c6:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800030ca:	00005517          	auipc	a0,0x5
    800030ce:	73e50513          	addi	a0,a0,1854 # 80008808 <userret+0x778>
    800030d2:	ffffe097          	auipc	ra,0xffffe
    800030d6:	89a080e7          	jalr	-1894(ra) # 8000096c <printf>
    panic("kerneltrap");
    800030da:	00005517          	auipc	a0,0x5
    800030de:	74650513          	addi	a0,a0,1862 # 80008820 <userret+0x790>
    800030e2:	ffffd097          	auipc	ra,0xffffd
    800030e6:	674080e7          	jalr	1652(ra) # 80000756 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030ea:	fffff097          	auipc	ra,0xfffff
    800030ee:	eb2080e7          	jalr	-334(ra) # 80001f9c <myproc>
    800030f2:	dd35                	beqz	a0,8000306e <kerneltrap+0x38>
    800030f4:	fffff097          	auipc	ra,0xfffff
    800030f8:	ea8080e7          	jalr	-344(ra) # 80001f9c <myproc>
    800030fc:	5918                	lw	a4,48(a0)
    800030fe:	478d                	li	a5,3
    80003100:	f6f717e3          	bne	a4,a5,8000306e <kerneltrap+0x38>
    yield();
    80003104:	fffff097          	auipc	ra,0xfffff
    80003108:	68a080e7          	jalr	1674(ra) # 8000278e <yield>
    8000310c:	b78d                	j	8000306e <kerneltrap+0x38>

000000008000310e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000310e:	1101                	addi	sp,sp,-32
    80003110:	ec06                	sd	ra,24(sp)
    80003112:	e822                	sd	s0,16(sp)
    80003114:	e426                	sd	s1,8(sp)
    80003116:	1000                	addi	s0,sp,32
    80003118:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000311a:	fffff097          	auipc	ra,0xfffff
    8000311e:	e82080e7          	jalr	-382(ra) # 80001f9c <myproc>
  switch (n) {
    80003122:	4795                	li	a5,5
    80003124:	0497e163          	bltu	a5,s1,80003166 <argraw+0x58>
    80003128:	048a                	slli	s1,s1,0x2
    8000312a:	00006717          	auipc	a4,0x6
    8000312e:	f3e70713          	addi	a4,a4,-194 # 80009068 <nointr_desc.1630+0x80>
    80003132:	94ba                	add	s1,s1,a4
    80003134:	409c                	lw	a5,0(s1)
    80003136:	97ba                	add	a5,a5,a4
    80003138:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    8000313a:	793c                	ld	a5,112(a0)
    8000313c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    8000313e:	60e2                	ld	ra,24(sp)
    80003140:	6442                	ld	s0,16(sp)
    80003142:	64a2                	ld	s1,8(sp)
    80003144:	6105                	addi	sp,sp,32
    80003146:	8082                	ret
    return p->tf->a1;
    80003148:	793c                	ld	a5,112(a0)
    8000314a:	7fa8                	ld	a0,120(a5)
    8000314c:	bfcd                	j	8000313e <argraw+0x30>
    return p->tf->a2;
    8000314e:	793c                	ld	a5,112(a0)
    80003150:	63c8                	ld	a0,128(a5)
    80003152:	b7f5                	j	8000313e <argraw+0x30>
    return p->tf->a3;
    80003154:	793c                	ld	a5,112(a0)
    80003156:	67c8                	ld	a0,136(a5)
    80003158:	b7dd                	j	8000313e <argraw+0x30>
    return p->tf->a4;
    8000315a:	793c                	ld	a5,112(a0)
    8000315c:	6bc8                	ld	a0,144(a5)
    8000315e:	b7c5                	j	8000313e <argraw+0x30>
    return p->tf->a5;
    80003160:	793c                	ld	a5,112(a0)
    80003162:	6fc8                	ld	a0,152(a5)
    80003164:	bfe9                	j	8000313e <argraw+0x30>
  panic("argraw");
    80003166:	00006517          	auipc	a0,0x6
    8000316a:	8c250513          	addi	a0,a0,-1854 # 80008a28 <userret+0x998>
    8000316e:	ffffd097          	auipc	ra,0xffffd
    80003172:	5e8080e7          	jalr	1512(ra) # 80000756 <panic>

0000000080003176 <fetchaddr>:
{
    80003176:	1101                	addi	sp,sp,-32
    80003178:	ec06                	sd	ra,24(sp)
    8000317a:	e822                	sd	s0,16(sp)
    8000317c:	e426                	sd	s1,8(sp)
    8000317e:	e04a                	sd	s2,0(sp)
    80003180:	1000                	addi	s0,sp,32
    80003182:	84aa                	mv	s1,a0
    80003184:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003186:	fffff097          	auipc	ra,0xfffff
    8000318a:	e16080e7          	jalr	-490(ra) # 80001f9c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    8000318e:	713c                	ld	a5,96(a0)
    80003190:	02f4f863          	bgeu	s1,a5,800031c0 <fetchaddr+0x4a>
    80003194:	00848713          	addi	a4,s1,8
    80003198:	02e7e663          	bltu	a5,a4,800031c4 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000319c:	46a1                	li	a3,8
    8000319e:	8626                	mv	a2,s1
    800031a0:	85ca                	mv	a1,s2
    800031a2:	7528                	ld	a0,104(a0)
    800031a4:	fffff097          	auipc	ra,0xfffff
    800031a8:	a86080e7          	jalr	-1402(ra) # 80001c2a <copyin>
    800031ac:	00a03533          	snez	a0,a0
    800031b0:	40a00533          	neg	a0,a0
}
    800031b4:	60e2                	ld	ra,24(sp)
    800031b6:	6442                	ld	s0,16(sp)
    800031b8:	64a2                	ld	s1,8(sp)
    800031ba:	6902                	ld	s2,0(sp)
    800031bc:	6105                	addi	sp,sp,32
    800031be:	8082                	ret
    return -1;
    800031c0:	557d                	li	a0,-1
    800031c2:	bfcd                	j	800031b4 <fetchaddr+0x3e>
    800031c4:	557d                	li	a0,-1
    800031c6:	b7fd                	j	800031b4 <fetchaddr+0x3e>

00000000800031c8 <fetchstr>:
{
    800031c8:	7179                	addi	sp,sp,-48
    800031ca:	f406                	sd	ra,40(sp)
    800031cc:	f022                	sd	s0,32(sp)
    800031ce:	ec26                	sd	s1,24(sp)
    800031d0:	e84a                	sd	s2,16(sp)
    800031d2:	e44e                	sd	s3,8(sp)
    800031d4:	1800                	addi	s0,sp,48
    800031d6:	892a                	mv	s2,a0
    800031d8:	84ae                	mv	s1,a1
    800031da:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800031dc:	fffff097          	auipc	ra,0xfffff
    800031e0:	dc0080e7          	jalr	-576(ra) # 80001f9c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800031e4:	86ce                	mv	a3,s3
    800031e6:	864a                	mv	a2,s2
    800031e8:	85a6                	mv	a1,s1
    800031ea:	7528                	ld	a0,104(a0)
    800031ec:	fffff097          	auipc	ra,0xfffff
    800031f0:	aca080e7          	jalr	-1334(ra) # 80001cb6 <copyinstr>
  if(err < 0)
    800031f4:	00054763          	bltz	a0,80003202 <fetchstr+0x3a>
  return strlen(buf);
    800031f8:	8526                	mv	a0,s1
    800031fa:	ffffe097          	auipc	ra,0xffffe
    800031fe:	062080e7          	jalr	98(ra) # 8000125c <strlen>
}
    80003202:	70a2                	ld	ra,40(sp)
    80003204:	7402                	ld	s0,32(sp)
    80003206:	64e2                	ld	s1,24(sp)
    80003208:	6942                	ld	s2,16(sp)
    8000320a:	69a2                	ld	s3,8(sp)
    8000320c:	6145                	addi	sp,sp,48
    8000320e:	8082                	ret

0000000080003210 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003210:	1101                	addi	sp,sp,-32
    80003212:	ec06                	sd	ra,24(sp)
    80003214:	e822                	sd	s0,16(sp)
    80003216:	e426                	sd	s1,8(sp)
    80003218:	1000                	addi	s0,sp,32
    8000321a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	ef2080e7          	jalr	-270(ra) # 8000310e <argraw>
    80003224:	c088                	sw	a0,0(s1)
  return 0;
}
    80003226:	4501                	li	a0,0
    80003228:	60e2                	ld	ra,24(sp)
    8000322a:	6442                	ld	s0,16(sp)
    8000322c:	64a2                	ld	s1,8(sp)
    8000322e:	6105                	addi	sp,sp,32
    80003230:	8082                	ret

0000000080003232 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003232:	1101                	addi	sp,sp,-32
    80003234:	ec06                	sd	ra,24(sp)
    80003236:	e822                	sd	s0,16(sp)
    80003238:	e426                	sd	s1,8(sp)
    8000323a:	1000                	addi	s0,sp,32
    8000323c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000323e:	00000097          	auipc	ra,0x0
    80003242:	ed0080e7          	jalr	-304(ra) # 8000310e <argraw>
    80003246:	e088                	sd	a0,0(s1)
  return 0;
}
    80003248:	4501                	li	a0,0
    8000324a:	60e2                	ld	ra,24(sp)
    8000324c:	6442                	ld	s0,16(sp)
    8000324e:	64a2                	ld	s1,8(sp)
    80003250:	6105                	addi	sp,sp,32
    80003252:	8082                	ret

0000000080003254 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003254:	1101                	addi	sp,sp,-32
    80003256:	ec06                	sd	ra,24(sp)
    80003258:	e822                	sd	s0,16(sp)
    8000325a:	e426                	sd	s1,8(sp)
    8000325c:	e04a                	sd	s2,0(sp)
    8000325e:	1000                	addi	s0,sp,32
    80003260:	84ae                	mv	s1,a1
    80003262:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003264:	00000097          	auipc	ra,0x0
    80003268:	eaa080e7          	jalr	-342(ra) # 8000310e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000326c:	864a                	mv	a2,s2
    8000326e:	85a6                	mv	a1,s1
    80003270:	00000097          	auipc	ra,0x0
    80003274:	f58080e7          	jalr	-168(ra) # 800031c8 <fetchstr>
}
    80003278:	60e2                	ld	ra,24(sp)
    8000327a:	6442                	ld	s0,16(sp)
    8000327c:	64a2                	ld	s1,8(sp)
    8000327e:	6902                	ld	s2,0(sp)
    80003280:	6105                	addi	sp,sp,32
    80003282:	8082                	ret

0000000080003284 <syscall>:
[SYS_release_mutex]  sys_release_mutex,
};

void
syscall(void)
{
    80003284:	1101                	addi	sp,sp,-32
    80003286:	ec06                	sd	ra,24(sp)
    80003288:	e822                	sd	s0,16(sp)
    8000328a:	e426                	sd	s1,8(sp)
    8000328c:	e04a                	sd	s2,0(sp)
    8000328e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003290:	fffff097          	auipc	ra,0xfffff
    80003294:	d0c080e7          	jalr	-756(ra) # 80001f9c <myproc>
    80003298:	84aa                	mv	s1,a0

  num = p->tf->a7;
    8000329a:	07053903          	ld	s2,112(a0)
    8000329e:	0a893783          	ld	a5,168(s2)
    800032a2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800032a6:	37fd                	addiw	a5,a5,-1
    800032a8:	4765                	li	a4,25
    800032aa:	00f76f63          	bltu	a4,a5,800032c8 <syscall+0x44>
    800032ae:	00369713          	slli	a4,a3,0x3
    800032b2:	00006797          	auipc	a5,0x6
    800032b6:	dce78793          	addi	a5,a5,-562 # 80009080 <syscalls>
    800032ba:	97ba                	add	a5,a5,a4
    800032bc:	639c                	ld	a5,0(a5)
    800032be:	c789                	beqz	a5,800032c8 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    800032c0:	9782                	jalr	a5
    800032c2:	06a93823          	sd	a0,112(s2)
    800032c6:	a839                	j	800032e4 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800032c8:	17048613          	addi	a2,s1,368
    800032cc:	48ac                	lw	a1,80(s1)
    800032ce:	00005517          	auipc	a0,0x5
    800032d2:	76250513          	addi	a0,a0,1890 # 80008a30 <userret+0x9a0>
    800032d6:	ffffd097          	auipc	ra,0xffffd
    800032da:	696080e7          	jalr	1686(ra) # 8000096c <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    800032de:	78bc                	ld	a5,112(s1)
    800032e0:	577d                	li	a4,-1
    800032e2:	fbb8                	sd	a4,112(a5)
  }
}
    800032e4:	60e2                	ld	ra,24(sp)
    800032e6:	6442                	ld	s0,16(sp)
    800032e8:	64a2                	ld	s1,8(sp)
    800032ea:	6902                	ld	s2,0(sp)
    800032ec:	6105                	addi	sp,sp,32
    800032ee:	8082                	ret

00000000800032f0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800032f0:	1101                	addi	sp,sp,-32
    800032f2:	ec06                	sd	ra,24(sp)
    800032f4:	e822                	sd	s0,16(sp)
    800032f6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800032f8:	fec40593          	addi	a1,s0,-20
    800032fc:	4501                	li	a0,0
    800032fe:	00000097          	auipc	ra,0x0
    80003302:	f12080e7          	jalr	-238(ra) # 80003210 <argint>
    return -1;
    80003306:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003308:	00054963          	bltz	a0,8000331a <sys_exit+0x2a>
  exit(n);
    8000330c:	fec42503          	lw	a0,-20(s0)
    80003310:	fffff097          	auipc	ra,0xfffff
    80003314:	370080e7          	jalr	880(ra) # 80002680 <exit>
  return 0;  // not reached
    80003318:	4781                	li	a5,0
}
    8000331a:	853e                	mv	a0,a5
    8000331c:	60e2                	ld	ra,24(sp)
    8000331e:	6442                	ld	s0,16(sp)
    80003320:	6105                	addi	sp,sp,32
    80003322:	8082                	ret

0000000080003324 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003324:	1141                	addi	sp,sp,-16
    80003326:	e406                	sd	ra,8(sp)
    80003328:	e022                	sd	s0,0(sp)
    8000332a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000332c:	fffff097          	auipc	ra,0xfffff
    80003330:	c70080e7          	jalr	-912(ra) # 80001f9c <myproc>
}
    80003334:	4928                	lw	a0,80(a0)
    80003336:	60a2                	ld	ra,8(sp)
    80003338:	6402                	ld	s0,0(sp)
    8000333a:	0141                	addi	sp,sp,16
    8000333c:	8082                	ret

000000008000333e <sys_fork>:

uint64
sys_fork(void)
{
    8000333e:	1141                	addi	sp,sp,-16
    80003340:	e406                	sd	ra,8(sp)
    80003342:	e022                	sd	s0,0(sp)
    80003344:	0800                	addi	s0,sp,16
  return fork();
    80003346:	fffff097          	auipc	ra,0xfffff
    8000334a:	022080e7          	jalr	34(ra) # 80002368 <fork>
}
    8000334e:	60a2                	ld	ra,8(sp)
    80003350:	6402                	ld	s0,0(sp)
    80003352:	0141                	addi	sp,sp,16
    80003354:	8082                	ret

0000000080003356 <sys_wait>:

uint64
sys_wait(void)
{
    80003356:	1101                	addi	sp,sp,-32
    80003358:	ec06                	sd	ra,24(sp)
    8000335a:	e822                	sd	s0,16(sp)
    8000335c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000335e:	fe840593          	addi	a1,s0,-24
    80003362:	4501                	li	a0,0
    80003364:	00000097          	auipc	ra,0x0
    80003368:	ece080e7          	jalr	-306(ra) # 80003232 <argaddr>
    8000336c:	87aa                	mv	a5,a0
    return -1;
    8000336e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003370:	0007c863          	bltz	a5,80003380 <sys_wait+0x2a>
  return wait(p);
    80003374:	fe843503          	ld	a0,-24(s0)
    80003378:	fffff097          	auipc	ra,0xfffff
    8000337c:	4d0080e7          	jalr	1232(ra) # 80002848 <wait>
}
    80003380:	60e2                	ld	ra,24(sp)
    80003382:	6442                	ld	s0,16(sp)
    80003384:	6105                	addi	sp,sp,32
    80003386:	8082                	ret

0000000080003388 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003388:	7179                	addi	sp,sp,-48
    8000338a:	f406                	sd	ra,40(sp)
    8000338c:	f022                	sd	s0,32(sp)
    8000338e:	ec26                	sd	s1,24(sp)
    80003390:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003392:	fdc40593          	addi	a1,s0,-36
    80003396:	4501                	li	a0,0
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	e78080e7          	jalr	-392(ra) # 80003210 <argint>
    800033a0:	87aa                	mv	a5,a0
    return -1;
    800033a2:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    800033a4:	0207c063          	bltz	a5,800033c4 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    800033a8:	fffff097          	auipc	ra,0xfffff
    800033ac:	bf4080e7          	jalr	-1036(ra) # 80001f9c <myproc>
    800033b0:	5124                	lw	s1,96(a0)
  if(growproc(n) < 0)
    800033b2:	fdc42503          	lw	a0,-36(s0)
    800033b6:	fffff097          	auipc	ra,0xfffff
    800033ba:	f3e080e7          	jalr	-194(ra) # 800022f4 <growproc>
    800033be:	00054863          	bltz	a0,800033ce <sys_sbrk+0x46>
    return -1;
  return addr;
    800033c2:	8526                	mv	a0,s1
}
    800033c4:	70a2                	ld	ra,40(sp)
    800033c6:	7402                	ld	s0,32(sp)
    800033c8:	64e2                	ld	s1,24(sp)
    800033ca:	6145                	addi	sp,sp,48
    800033cc:	8082                	ret
    return -1;
    800033ce:	557d                	li	a0,-1
    800033d0:	bfd5                	j	800033c4 <sys_sbrk+0x3c>

00000000800033d2 <sys_sleep>:

uint64
sys_sleep(void)
{
    800033d2:	7139                	addi	sp,sp,-64
    800033d4:	fc06                	sd	ra,56(sp)
    800033d6:	f822                	sd	s0,48(sp)
    800033d8:	f426                	sd	s1,40(sp)
    800033da:	f04a                	sd	s2,32(sp)
    800033dc:	ec4e                	sd	s3,24(sp)
    800033de:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800033e0:	fcc40593          	addi	a1,s0,-52
    800033e4:	4501                	li	a0,0
    800033e6:	00000097          	auipc	ra,0x0
    800033ea:	e2a080e7          	jalr	-470(ra) # 80003210 <argint>
    return -1;
    800033ee:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800033f0:	06054563          	bltz	a0,8000345a <sys_sleep+0x88>
  acquire(&tickslock);
    800033f4:	00019517          	auipc	a0,0x19
    800033f8:	ca450513          	addi	a0,a0,-860 # 8001c098 <tickslock>
    800033fc:	ffffe097          	auipc	ra,0xffffe
    80003400:	88c080e7          	jalr	-1908(ra) # 80000c88 <acquire>
  ticks0 = ticks;
    80003404:	0002b917          	auipc	s2,0x2b
    80003408:	c8492903          	lw	s2,-892(s2) # 8002e088 <ticks>
  while(ticks - ticks0 < n){
    8000340c:	fcc42783          	lw	a5,-52(s0)
    80003410:	cf85                	beqz	a5,80003448 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003412:	00019997          	auipc	s3,0x19
    80003416:	c8698993          	addi	s3,s3,-890 # 8001c098 <tickslock>
    8000341a:	0002b497          	auipc	s1,0x2b
    8000341e:	c6e48493          	addi	s1,s1,-914 # 8002e088 <ticks>
    if(myproc()->killed){
    80003422:	fffff097          	auipc	ra,0xfffff
    80003426:	b7a080e7          	jalr	-1158(ra) # 80001f9c <myproc>
    8000342a:	453c                	lw	a5,72(a0)
    8000342c:	ef9d                	bnez	a5,8000346a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000342e:	85ce                	mv	a1,s3
    80003430:	8526                	mv	a0,s1
    80003432:	fffff097          	auipc	ra,0xfffff
    80003436:	398080e7          	jalr	920(ra) # 800027ca <sleep>
  while(ticks - ticks0 < n){
    8000343a:	409c                	lw	a5,0(s1)
    8000343c:	412787bb          	subw	a5,a5,s2
    80003440:	fcc42703          	lw	a4,-52(s0)
    80003444:	fce7efe3          	bltu	a5,a4,80003422 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003448:	00019517          	auipc	a0,0x19
    8000344c:	c5050513          	addi	a0,a0,-944 # 8001c098 <tickslock>
    80003450:	ffffe097          	auipc	ra,0xffffe
    80003454:	a84080e7          	jalr	-1404(ra) # 80000ed4 <release>
  return 0;
    80003458:	4781                	li	a5,0
}
    8000345a:	853e                	mv	a0,a5
    8000345c:	70e2                	ld	ra,56(sp)
    8000345e:	7442                	ld	s0,48(sp)
    80003460:	74a2                	ld	s1,40(sp)
    80003462:	7902                	ld	s2,32(sp)
    80003464:	69e2                	ld	s3,24(sp)
    80003466:	6121                	addi	sp,sp,64
    80003468:	8082                	ret
      release(&tickslock);
    8000346a:	00019517          	auipc	a0,0x19
    8000346e:	c2e50513          	addi	a0,a0,-978 # 8001c098 <tickslock>
    80003472:	ffffe097          	auipc	ra,0xffffe
    80003476:	a62080e7          	jalr	-1438(ra) # 80000ed4 <release>
      return -1;
    8000347a:	57fd                	li	a5,-1
    8000347c:	bff9                	j	8000345a <sys_sleep+0x88>

000000008000347e <sys_nice>:

uint64
sys_nice(void){
    8000347e:	1141                	addi	sp,sp,-16
    80003480:	e422                	sd	s0,8(sp)
    80003482:	0800                	addi	s0,sp,16
  return 0;
}
    80003484:	4501                	li	a0,0
    80003486:	6422                	ld	s0,8(sp)
    80003488:	0141                	addi	sp,sp,16
    8000348a:	8082                	ret

000000008000348c <sys_kill>:

uint64
sys_kill(void)
{
    8000348c:	1101                	addi	sp,sp,-32
    8000348e:	ec06                	sd	ra,24(sp)
    80003490:	e822                	sd	s0,16(sp)
    80003492:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003494:	fec40593          	addi	a1,s0,-20
    80003498:	4501                	li	a0,0
    8000349a:	00000097          	auipc	ra,0x0
    8000349e:	d76080e7          	jalr	-650(ra) # 80003210 <argint>
    800034a2:	87aa                	mv	a5,a0
    return -1;
    800034a4:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800034a6:	0007c863          	bltz	a5,800034b6 <sys_kill+0x2a>
  return kill(pid);
    800034aa:	fec42503          	lw	a0,-20(s0)
    800034ae:	fffff097          	auipc	ra,0xfffff
    800034b2:	50c080e7          	jalr	1292(ra) # 800029ba <kill>
}
    800034b6:	60e2                	ld	ra,24(sp)
    800034b8:	6442                	ld	s0,16(sp)
    800034ba:	6105                	addi	sp,sp,32
    800034bc:	8082                	ret

00000000800034be <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800034be:	1101                	addi	sp,sp,-32
    800034c0:	ec06                	sd	ra,24(sp)
    800034c2:	e822                	sd	s0,16(sp)
    800034c4:	e426                	sd	s1,8(sp)
    800034c6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800034c8:	00019517          	auipc	a0,0x19
    800034cc:	bd050513          	addi	a0,a0,-1072 # 8001c098 <tickslock>
    800034d0:	ffffd097          	auipc	ra,0xffffd
    800034d4:	7b8080e7          	jalr	1976(ra) # 80000c88 <acquire>
  xticks = ticks;
    800034d8:	0002b497          	auipc	s1,0x2b
    800034dc:	bb04a483          	lw	s1,-1104(s1) # 8002e088 <ticks>
  release(&tickslock);
    800034e0:	00019517          	auipc	a0,0x19
    800034e4:	bb850513          	addi	a0,a0,-1096 # 8001c098 <tickslock>
    800034e8:	ffffe097          	auipc	ra,0xffffe
    800034ec:	9ec080e7          	jalr	-1556(ra) # 80000ed4 <release>
  return xticks;
}
    800034f0:	02049513          	slli	a0,s1,0x20
    800034f4:	9101                	srli	a0,a0,0x20
    800034f6:	60e2                	ld	ra,24(sp)
    800034f8:	6442                	ld	s0,16(sp)
    800034fa:	64a2                	ld	s1,8(sp)
    800034fc:	6105                	addi	sp,sp,32
    800034fe:	8082                	ret

0000000080003500 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003500:	7179                	addi	sp,sp,-48
    80003502:	f406                	sd	ra,40(sp)
    80003504:	f022                	sd	s0,32(sp)
    80003506:	ec26                	sd	s1,24(sp)
    80003508:	e84a                	sd	s2,16(sp)
    8000350a:	e44e                	sd	s3,8(sp)
    8000350c:	e052                	sd	s4,0(sp)
    8000350e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003510:	00005597          	auipc	a1,0x5
    80003514:	ef058593          	addi	a1,a1,-272 # 80008400 <userret+0x370>
    80003518:	00019517          	auipc	a0,0x19
    8000351c:	bb050513          	addi	a0,a0,-1104 # 8001c0c8 <bcache>
    80003520:	ffffd097          	auipc	ra,0xffffd
    80003524:	5fe080e7          	jalr	1534(ra) # 80000b1e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003528:	00021797          	auipc	a5,0x21
    8000352c:	ba078793          	addi	a5,a5,-1120 # 800240c8 <bcache+0x8000>
    80003530:	00021717          	auipc	a4,0x21
    80003534:	0e870713          	addi	a4,a4,232 # 80024618 <bcache+0x8550>
    80003538:	5ae7b823          	sd	a4,1456(a5)
  bcache.head.next = &bcache.head;
    8000353c:	5ae7bc23          	sd	a4,1464(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003540:	00019497          	auipc	s1,0x19
    80003544:	bb848493          	addi	s1,s1,-1096 # 8001c0f8 <bcache+0x30>
    b->next = bcache.head.next;
    80003548:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000354a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000354c:	00005a17          	auipc	s4,0x5
    80003550:	504a0a13          	addi	s4,s4,1284 # 80008a50 <userret+0x9c0>
    b->next = bcache.head.next;
    80003554:	5b893783          	ld	a5,1464(s2)
    80003558:	f4bc                	sd	a5,104(s1)
    b->prev = &bcache.head;
    8000355a:	0734b023          	sd	s3,96(s1)
    initsleeplock(&b->lock, "buffer");
    8000355e:	85d2                	mv	a1,s4
    80003560:	01048513          	addi	a0,s1,16
    80003564:	00001097          	auipc	ra,0x1
    80003568:	57c080e7          	jalr	1404(ra) # 80004ae0 <initsleeplock>
    bcache.head.next->prev = b;
    8000356c:	5b893783          	ld	a5,1464(s2)
    80003570:	f3a4                	sd	s1,96(a5)
    bcache.head.next = b;
    80003572:	5a993c23          	sd	s1,1464(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003576:	47048493          	addi	s1,s1,1136
    8000357a:	fd349de3          	bne	s1,s3,80003554 <binit+0x54>
  }
}
    8000357e:	70a2                	ld	ra,40(sp)
    80003580:	7402                	ld	s0,32(sp)
    80003582:	64e2                	ld	s1,24(sp)
    80003584:	6942                	ld	s2,16(sp)
    80003586:	69a2                	ld	s3,8(sp)
    80003588:	6a02                	ld	s4,0(sp)
    8000358a:	6145                	addi	sp,sp,48
    8000358c:	8082                	ret

000000008000358e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000358e:	7179                	addi	sp,sp,-48
    80003590:	f406                	sd	ra,40(sp)
    80003592:	f022                	sd	s0,32(sp)
    80003594:	ec26                	sd	s1,24(sp)
    80003596:	e84a                	sd	s2,16(sp)
    80003598:	e44e                	sd	s3,8(sp)
    8000359a:	1800                	addi	s0,sp,48
    8000359c:	89aa                	mv	s3,a0
    8000359e:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800035a0:	00019517          	auipc	a0,0x19
    800035a4:	b2850513          	addi	a0,a0,-1240 # 8001c0c8 <bcache>
    800035a8:	ffffd097          	auipc	ra,0xffffd
    800035ac:	6e0080e7          	jalr	1760(ra) # 80000c88 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800035b0:	00021497          	auipc	s1,0x21
    800035b4:	0d04b483          	ld	s1,208(s1) # 80024680 <bcache+0x85b8>
    800035b8:	00021797          	auipc	a5,0x21
    800035bc:	06078793          	addi	a5,a5,96 # 80024618 <bcache+0x8550>
    800035c0:	02f48f63          	beq	s1,a5,800035fe <bread+0x70>
    800035c4:	873e                	mv	a4,a5
    800035c6:	a021                	j	800035ce <bread+0x40>
    800035c8:	74a4                	ld	s1,104(s1)
    800035ca:	02e48a63          	beq	s1,a4,800035fe <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800035ce:	449c                	lw	a5,8(s1)
    800035d0:	ff379ce3          	bne	a5,s3,800035c8 <bread+0x3a>
    800035d4:	44dc                	lw	a5,12(s1)
    800035d6:	ff2799e3          	bne	a5,s2,800035c8 <bread+0x3a>
      b->refcnt++;
    800035da:	4cbc                	lw	a5,88(s1)
    800035dc:	2785                	addiw	a5,a5,1
    800035de:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    800035e0:	00019517          	auipc	a0,0x19
    800035e4:	ae850513          	addi	a0,a0,-1304 # 8001c0c8 <bcache>
    800035e8:	ffffe097          	auipc	ra,0xffffe
    800035ec:	8ec080e7          	jalr	-1812(ra) # 80000ed4 <release>
      acquiresleep(&b->lock);
    800035f0:	01048513          	addi	a0,s1,16
    800035f4:	00001097          	auipc	ra,0x1
    800035f8:	526080e7          	jalr	1318(ra) # 80004b1a <acquiresleep>
      return b;
    800035fc:	a8b9                	j	8000365a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035fe:	00021497          	auipc	s1,0x21
    80003602:	07a4b483          	ld	s1,122(s1) # 80024678 <bcache+0x85b0>
    80003606:	00021797          	auipc	a5,0x21
    8000360a:	01278793          	addi	a5,a5,18 # 80024618 <bcache+0x8550>
    8000360e:	00f48863          	beq	s1,a5,8000361e <bread+0x90>
    80003612:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003614:	4cbc                	lw	a5,88(s1)
    80003616:	cf81                	beqz	a5,8000362e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003618:	70a4                	ld	s1,96(s1)
    8000361a:	fee49de3          	bne	s1,a4,80003614 <bread+0x86>
  panic("bget: no buffers");
    8000361e:	00005517          	auipc	a0,0x5
    80003622:	43a50513          	addi	a0,a0,1082 # 80008a58 <userret+0x9c8>
    80003626:	ffffd097          	auipc	ra,0xffffd
    8000362a:	130080e7          	jalr	304(ra) # 80000756 <panic>
      b->dev = dev;
    8000362e:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003632:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003636:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000363a:	4785                	li	a5,1
    8000363c:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    8000363e:	00019517          	auipc	a0,0x19
    80003642:	a8a50513          	addi	a0,a0,-1398 # 8001c0c8 <bcache>
    80003646:	ffffe097          	auipc	ra,0xffffe
    8000364a:	88e080e7          	jalr	-1906(ra) # 80000ed4 <release>
      acquiresleep(&b->lock);
    8000364e:	01048513          	addi	a0,s1,16
    80003652:	00001097          	auipc	ra,0x1
    80003656:	4c8080e7          	jalr	1224(ra) # 80004b1a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000365a:	409c                	lw	a5,0(s1)
    8000365c:	cb89                	beqz	a5,8000366e <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    8000365e:	8526                	mv	a0,s1
    80003660:	70a2                	ld	ra,40(sp)
    80003662:	7402                	ld	s0,32(sp)
    80003664:	64e2                	ld	s1,24(sp)
    80003666:	6942                	ld	s2,16(sp)
    80003668:	69a2                	ld	s3,8(sp)
    8000366a:	6145                	addi	sp,sp,48
    8000366c:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    8000366e:	4601                	li	a2,0
    80003670:	85a6                	mv	a1,s1
    80003672:	4488                	lw	a0,8(s1)
    80003674:	00003097          	auipc	ra,0x3
    80003678:	11a080e7          	jalr	282(ra) # 8000678e <virtio_disk_rw>
    b->valid = 1;
    8000367c:	4785                	li	a5,1
    8000367e:	c09c                	sw	a5,0(s1)
  return b;
    80003680:	bff9                	j	8000365e <bread+0xd0>

0000000080003682 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003682:	1101                	addi	sp,sp,-32
    80003684:	ec06                	sd	ra,24(sp)
    80003686:	e822                	sd	s0,16(sp)
    80003688:	e426                	sd	s1,8(sp)
    8000368a:	1000                	addi	s0,sp,32
    8000368c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000368e:	0541                	addi	a0,a0,16
    80003690:	00001097          	auipc	ra,0x1
    80003694:	524080e7          	jalr	1316(ra) # 80004bb4 <holdingsleep>
    80003698:	cd09                	beqz	a0,800036b2 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    8000369a:	4605                	li	a2,1
    8000369c:	85a6                	mv	a1,s1
    8000369e:	4488                	lw	a0,8(s1)
    800036a0:	00003097          	auipc	ra,0x3
    800036a4:	0ee080e7          	jalr	238(ra) # 8000678e <virtio_disk_rw>
}
    800036a8:	60e2                	ld	ra,24(sp)
    800036aa:	6442                	ld	s0,16(sp)
    800036ac:	64a2                	ld	s1,8(sp)
    800036ae:	6105                	addi	sp,sp,32
    800036b0:	8082                	ret
    panic("bwrite");
    800036b2:	00005517          	auipc	a0,0x5
    800036b6:	3be50513          	addi	a0,a0,958 # 80008a70 <userret+0x9e0>
    800036ba:	ffffd097          	auipc	ra,0xffffd
    800036be:	09c080e7          	jalr	156(ra) # 80000756 <panic>

00000000800036c2 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    800036c2:	1101                	addi	sp,sp,-32
    800036c4:	ec06                	sd	ra,24(sp)
    800036c6:	e822                	sd	s0,16(sp)
    800036c8:	e426                	sd	s1,8(sp)
    800036ca:	e04a                	sd	s2,0(sp)
    800036cc:	1000                	addi	s0,sp,32
    800036ce:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036d0:	01050913          	addi	s2,a0,16
    800036d4:	854a                	mv	a0,s2
    800036d6:	00001097          	auipc	ra,0x1
    800036da:	4de080e7          	jalr	1246(ra) # 80004bb4 <holdingsleep>
    800036de:	c92d                	beqz	a0,80003750 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800036e0:	854a                	mv	a0,s2
    800036e2:	00001097          	auipc	ra,0x1
    800036e6:	48e080e7          	jalr	1166(ra) # 80004b70 <releasesleep>

  acquire(&bcache.lock);
    800036ea:	00019517          	auipc	a0,0x19
    800036ee:	9de50513          	addi	a0,a0,-1570 # 8001c0c8 <bcache>
    800036f2:	ffffd097          	auipc	ra,0xffffd
    800036f6:	596080e7          	jalr	1430(ra) # 80000c88 <acquire>
  b->refcnt--;
    800036fa:	4cbc                	lw	a5,88(s1)
    800036fc:	37fd                	addiw	a5,a5,-1
    800036fe:	0007871b          	sext.w	a4,a5
    80003702:	ccbc                	sw	a5,88(s1)
  if (b->refcnt == 0) {
    80003704:	eb05                	bnez	a4,80003734 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003706:	74bc                	ld	a5,104(s1)
    80003708:	70b8                	ld	a4,96(s1)
    8000370a:	f3b8                	sd	a4,96(a5)
    b->prev->next = b->next;
    8000370c:	70bc                	ld	a5,96(s1)
    8000370e:	74b8                	ld	a4,104(s1)
    80003710:	f7b8                	sd	a4,104(a5)
    b->next = bcache.head.next;
    80003712:	00021797          	auipc	a5,0x21
    80003716:	9b678793          	addi	a5,a5,-1610 # 800240c8 <bcache+0x8000>
    8000371a:	5b87b703          	ld	a4,1464(a5)
    8000371e:	f4b8                	sd	a4,104(s1)
    b->prev = &bcache.head;
    80003720:	00021717          	auipc	a4,0x21
    80003724:	ef870713          	addi	a4,a4,-264 # 80024618 <bcache+0x8550>
    80003728:	f0b8                	sd	a4,96(s1)
    bcache.head.next->prev = b;
    8000372a:	5b87b703          	ld	a4,1464(a5)
    8000372e:	f324                	sd	s1,96(a4)
    bcache.head.next = b;
    80003730:	5a97bc23          	sd	s1,1464(a5)
  }
  
  release(&bcache.lock);
    80003734:	00019517          	auipc	a0,0x19
    80003738:	99450513          	addi	a0,a0,-1644 # 8001c0c8 <bcache>
    8000373c:	ffffd097          	auipc	ra,0xffffd
    80003740:	798080e7          	jalr	1944(ra) # 80000ed4 <release>
}
    80003744:	60e2                	ld	ra,24(sp)
    80003746:	6442                	ld	s0,16(sp)
    80003748:	64a2                	ld	s1,8(sp)
    8000374a:	6902                	ld	s2,0(sp)
    8000374c:	6105                	addi	sp,sp,32
    8000374e:	8082                	ret
    panic("brelse");
    80003750:	00005517          	auipc	a0,0x5
    80003754:	32850513          	addi	a0,a0,808 # 80008a78 <userret+0x9e8>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	ffe080e7          	jalr	-2(ra) # 80000756 <panic>

0000000080003760 <bpin>:

void
bpin(struct buf *b) {
    80003760:	1101                	addi	sp,sp,-32
    80003762:	ec06                	sd	ra,24(sp)
    80003764:	e822                	sd	s0,16(sp)
    80003766:	e426                	sd	s1,8(sp)
    80003768:	1000                	addi	s0,sp,32
    8000376a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000376c:	00019517          	auipc	a0,0x19
    80003770:	95c50513          	addi	a0,a0,-1700 # 8001c0c8 <bcache>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	514080e7          	jalr	1300(ra) # 80000c88 <acquire>
  b->refcnt++;
    8000377c:	4cbc                	lw	a5,88(s1)
    8000377e:	2785                	addiw	a5,a5,1
    80003780:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    80003782:	00019517          	auipc	a0,0x19
    80003786:	94650513          	addi	a0,a0,-1722 # 8001c0c8 <bcache>
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	74a080e7          	jalr	1866(ra) # 80000ed4 <release>
}
    80003792:	60e2                	ld	ra,24(sp)
    80003794:	6442                	ld	s0,16(sp)
    80003796:	64a2                	ld	s1,8(sp)
    80003798:	6105                	addi	sp,sp,32
    8000379a:	8082                	ret

000000008000379c <bunpin>:

void
bunpin(struct buf *b) {
    8000379c:	1101                	addi	sp,sp,-32
    8000379e:	ec06                	sd	ra,24(sp)
    800037a0:	e822                	sd	s0,16(sp)
    800037a2:	e426                	sd	s1,8(sp)
    800037a4:	1000                	addi	s0,sp,32
    800037a6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037a8:	00019517          	auipc	a0,0x19
    800037ac:	92050513          	addi	a0,a0,-1760 # 8001c0c8 <bcache>
    800037b0:	ffffd097          	auipc	ra,0xffffd
    800037b4:	4d8080e7          	jalr	1240(ra) # 80000c88 <acquire>
  b->refcnt--;
    800037b8:	4cbc                	lw	a5,88(s1)
    800037ba:	37fd                	addiw	a5,a5,-1
    800037bc:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    800037be:	00019517          	auipc	a0,0x19
    800037c2:	90a50513          	addi	a0,a0,-1782 # 8001c0c8 <bcache>
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	70e080e7          	jalr	1806(ra) # 80000ed4 <release>
}
    800037ce:	60e2                	ld	ra,24(sp)
    800037d0:	6442                	ld	s0,16(sp)
    800037d2:	64a2                	ld	s1,8(sp)
    800037d4:	6105                	addi	sp,sp,32
    800037d6:	8082                	ret

00000000800037d8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800037d8:	1101                	addi	sp,sp,-32
    800037da:	ec06                	sd	ra,24(sp)
    800037dc:	e822                	sd	s0,16(sp)
    800037de:	e426                	sd	s1,8(sp)
    800037e0:	e04a                	sd	s2,0(sp)
    800037e2:	1000                	addi	s0,sp,32
    800037e4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800037e6:	00d5d59b          	srliw	a1,a1,0xd
    800037ea:	00021797          	auipc	a5,0x21
    800037ee:	2ba7a783          	lw	a5,698(a5) # 80024aa4 <sb+0x1c>
    800037f2:	9dbd                	addw	a1,a1,a5
    800037f4:	00000097          	auipc	ra,0x0
    800037f8:	d9a080e7          	jalr	-614(ra) # 8000358e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800037fc:	0074f713          	andi	a4,s1,7
    80003800:	4785                	li	a5,1
    80003802:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003806:	14ce                	slli	s1,s1,0x33
    80003808:	90d9                	srli	s1,s1,0x36
    8000380a:	00950733          	add	a4,a0,s1
    8000380e:	07074703          	lbu	a4,112(a4)
    80003812:	00e7f6b3          	and	a3,a5,a4
    80003816:	c69d                	beqz	a3,80003844 <bfree+0x6c>
    80003818:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000381a:	94aa                	add	s1,s1,a0
    8000381c:	fff7c793          	not	a5,a5
    80003820:	8ff9                	and	a5,a5,a4
    80003822:	06f48823          	sb	a5,112(s1)
  log_write(bp);
    80003826:	00001097          	auipc	ra,0x1
    8000382a:	188080e7          	jalr	392(ra) # 800049ae <log_write>
  brelse(bp);
    8000382e:	854a                	mv	a0,s2
    80003830:	00000097          	auipc	ra,0x0
    80003834:	e92080e7          	jalr	-366(ra) # 800036c2 <brelse>
}
    80003838:	60e2                	ld	ra,24(sp)
    8000383a:	6442                	ld	s0,16(sp)
    8000383c:	64a2                	ld	s1,8(sp)
    8000383e:	6902                	ld	s2,0(sp)
    80003840:	6105                	addi	sp,sp,32
    80003842:	8082                	ret
    panic("freeing free block");
    80003844:	00005517          	auipc	a0,0x5
    80003848:	23c50513          	addi	a0,a0,572 # 80008a80 <userret+0x9f0>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	f0a080e7          	jalr	-246(ra) # 80000756 <panic>

0000000080003854 <balloc>:
{
    80003854:	711d                	addi	sp,sp,-96
    80003856:	ec86                	sd	ra,88(sp)
    80003858:	e8a2                	sd	s0,80(sp)
    8000385a:	e4a6                	sd	s1,72(sp)
    8000385c:	e0ca                	sd	s2,64(sp)
    8000385e:	fc4e                	sd	s3,56(sp)
    80003860:	f852                	sd	s4,48(sp)
    80003862:	f456                	sd	s5,40(sp)
    80003864:	f05a                	sd	s6,32(sp)
    80003866:	ec5e                	sd	s7,24(sp)
    80003868:	e862                	sd	s8,16(sp)
    8000386a:	e466                	sd	s9,8(sp)
    8000386c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000386e:	00021797          	auipc	a5,0x21
    80003872:	21e7a783          	lw	a5,542(a5) # 80024a8c <sb+0x4>
    80003876:	cbd1                	beqz	a5,8000390a <balloc+0xb6>
    80003878:	8baa                	mv	s7,a0
    8000387a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000387c:	00021b17          	auipc	s6,0x21
    80003880:	20cb0b13          	addi	s6,s6,524 # 80024a88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003884:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003886:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003888:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000388a:	6c89                	lui	s9,0x2
    8000388c:	a831                	j	800038a8 <balloc+0x54>
    brelse(bp);
    8000388e:	854a                	mv	a0,s2
    80003890:	00000097          	auipc	ra,0x0
    80003894:	e32080e7          	jalr	-462(ra) # 800036c2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003898:	015c87bb          	addw	a5,s9,s5
    8000389c:	00078a9b          	sext.w	s5,a5
    800038a0:	004b2703          	lw	a4,4(s6)
    800038a4:	06eaf363          	bgeu	s5,a4,8000390a <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800038a8:	41fad79b          	sraiw	a5,s5,0x1f
    800038ac:	0137d79b          	srliw	a5,a5,0x13
    800038b0:	015787bb          	addw	a5,a5,s5
    800038b4:	40d7d79b          	sraiw	a5,a5,0xd
    800038b8:	01cb2583          	lw	a1,28(s6)
    800038bc:	9dbd                	addw	a1,a1,a5
    800038be:	855e                	mv	a0,s7
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	cce080e7          	jalr	-818(ra) # 8000358e <bread>
    800038c8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038ca:	004b2503          	lw	a0,4(s6)
    800038ce:	000a849b          	sext.w	s1,s5
    800038d2:	8662                	mv	a2,s8
    800038d4:	faa4fde3          	bgeu	s1,a0,8000388e <balloc+0x3a>
      m = 1 << (bi % 8);
    800038d8:	41f6579b          	sraiw	a5,a2,0x1f
    800038dc:	01d7d69b          	srliw	a3,a5,0x1d
    800038e0:	00c6873b          	addw	a4,a3,a2
    800038e4:	00777793          	andi	a5,a4,7
    800038e8:	9f95                	subw	a5,a5,a3
    800038ea:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800038ee:	4037571b          	sraiw	a4,a4,0x3
    800038f2:	00e906b3          	add	a3,s2,a4
    800038f6:	0706c683          	lbu	a3,112(a3)
    800038fa:	00d7f5b3          	and	a1,a5,a3
    800038fe:	cd91                	beqz	a1,8000391a <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003900:	2605                	addiw	a2,a2,1
    80003902:	2485                	addiw	s1,s1,1
    80003904:	fd4618e3          	bne	a2,s4,800038d4 <balloc+0x80>
    80003908:	b759                	j	8000388e <balloc+0x3a>
  panic("balloc: out of blocks");
    8000390a:	00005517          	auipc	a0,0x5
    8000390e:	18e50513          	addi	a0,a0,398 # 80008a98 <userret+0xa08>
    80003912:	ffffd097          	auipc	ra,0xffffd
    80003916:	e44080e7          	jalr	-444(ra) # 80000756 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000391a:	974a                	add	a4,a4,s2
    8000391c:	8fd5                	or	a5,a5,a3
    8000391e:	06f70823          	sb	a5,112(a4)
        log_write(bp);
    80003922:	854a                	mv	a0,s2
    80003924:	00001097          	auipc	ra,0x1
    80003928:	08a080e7          	jalr	138(ra) # 800049ae <log_write>
        brelse(bp);
    8000392c:	854a                	mv	a0,s2
    8000392e:	00000097          	auipc	ra,0x0
    80003932:	d94080e7          	jalr	-620(ra) # 800036c2 <brelse>
  bp = bread(dev, bno);
    80003936:	85a6                	mv	a1,s1
    80003938:	855e                	mv	a0,s7
    8000393a:	00000097          	auipc	ra,0x0
    8000393e:	c54080e7          	jalr	-940(ra) # 8000358e <bread>
    80003942:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003944:	40000613          	li	a2,1024
    80003948:	4581                	li	a1,0
    8000394a:	07050513          	addi	a0,a0,112
    8000394e:	ffffd097          	auipc	ra,0xffffd
    80003952:	786080e7          	jalr	1926(ra) # 800010d4 <memset>
  log_write(bp);
    80003956:	854a                	mv	a0,s2
    80003958:	00001097          	auipc	ra,0x1
    8000395c:	056080e7          	jalr	86(ra) # 800049ae <log_write>
  brelse(bp);
    80003960:	854a                	mv	a0,s2
    80003962:	00000097          	auipc	ra,0x0
    80003966:	d60080e7          	jalr	-672(ra) # 800036c2 <brelse>
}
    8000396a:	8526                	mv	a0,s1
    8000396c:	60e6                	ld	ra,88(sp)
    8000396e:	6446                	ld	s0,80(sp)
    80003970:	64a6                	ld	s1,72(sp)
    80003972:	6906                	ld	s2,64(sp)
    80003974:	79e2                	ld	s3,56(sp)
    80003976:	7a42                	ld	s4,48(sp)
    80003978:	7aa2                	ld	s5,40(sp)
    8000397a:	7b02                	ld	s6,32(sp)
    8000397c:	6be2                	ld	s7,24(sp)
    8000397e:	6c42                	ld	s8,16(sp)
    80003980:	6ca2                	ld	s9,8(sp)
    80003982:	6125                	addi	sp,sp,96
    80003984:	8082                	ret

0000000080003986 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003986:	7179                	addi	sp,sp,-48
    80003988:	f406                	sd	ra,40(sp)
    8000398a:	f022                	sd	s0,32(sp)
    8000398c:	ec26                	sd	s1,24(sp)
    8000398e:	e84a                	sd	s2,16(sp)
    80003990:	e44e                	sd	s3,8(sp)
    80003992:	e052                	sd	s4,0(sp)
    80003994:	1800                	addi	s0,sp,48
    80003996:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003998:	47ad                	li	a5,11
    8000399a:	04b7fe63          	bgeu	a5,a1,800039f6 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000399e:	ff45849b          	addiw	s1,a1,-12
    800039a2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039a6:	0ff00793          	li	a5,255
    800039aa:	0ae7e363          	bltu	a5,a4,80003a50 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800039ae:	09852583          	lw	a1,152(a0)
    800039b2:	c5ad                	beqz	a1,80003a1c <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800039b4:	00092503          	lw	a0,0(s2)
    800039b8:	00000097          	auipc	ra,0x0
    800039bc:	bd6080e7          	jalr	-1066(ra) # 8000358e <bread>
    800039c0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800039c2:	07050793          	addi	a5,a0,112
    if((addr = a[bn]) == 0){
    800039c6:	02049593          	slli	a1,s1,0x20
    800039ca:	9181                	srli	a1,a1,0x20
    800039cc:	058a                	slli	a1,a1,0x2
    800039ce:	00b784b3          	add	s1,a5,a1
    800039d2:	0004a983          	lw	s3,0(s1)
    800039d6:	04098d63          	beqz	s3,80003a30 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800039da:	8552                	mv	a0,s4
    800039dc:	00000097          	auipc	ra,0x0
    800039e0:	ce6080e7          	jalr	-794(ra) # 800036c2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800039e4:	854e                	mv	a0,s3
    800039e6:	70a2                	ld	ra,40(sp)
    800039e8:	7402                	ld	s0,32(sp)
    800039ea:	64e2                	ld	s1,24(sp)
    800039ec:	6942                	ld	s2,16(sp)
    800039ee:	69a2                	ld	s3,8(sp)
    800039f0:	6a02                	ld	s4,0(sp)
    800039f2:	6145                	addi	sp,sp,48
    800039f4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800039f6:	02059493          	slli	s1,a1,0x20
    800039fa:	9081                	srli	s1,s1,0x20
    800039fc:	048a                	slli	s1,s1,0x2
    800039fe:	94aa                	add	s1,s1,a0
    80003a00:	0684a983          	lw	s3,104(s1)
    80003a04:	fe0990e3          	bnez	s3,800039e4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003a08:	4108                	lw	a0,0(a0)
    80003a0a:	00000097          	auipc	ra,0x0
    80003a0e:	e4a080e7          	jalr	-438(ra) # 80003854 <balloc>
    80003a12:	0005099b          	sext.w	s3,a0
    80003a16:	0734a423          	sw	s3,104(s1)
    80003a1a:	b7e9                	j	800039e4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003a1c:	4108                	lw	a0,0(a0)
    80003a1e:	00000097          	auipc	ra,0x0
    80003a22:	e36080e7          	jalr	-458(ra) # 80003854 <balloc>
    80003a26:	0005059b          	sext.w	a1,a0
    80003a2a:	08b92c23          	sw	a1,152(s2)
    80003a2e:	b759                	j	800039b4 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003a30:	00092503          	lw	a0,0(s2)
    80003a34:	00000097          	auipc	ra,0x0
    80003a38:	e20080e7          	jalr	-480(ra) # 80003854 <balloc>
    80003a3c:	0005099b          	sext.w	s3,a0
    80003a40:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003a44:	8552                	mv	a0,s4
    80003a46:	00001097          	auipc	ra,0x1
    80003a4a:	f68080e7          	jalr	-152(ra) # 800049ae <log_write>
    80003a4e:	b771                	j	800039da <bmap+0x54>
  panic("bmap: out of range");
    80003a50:	00005517          	auipc	a0,0x5
    80003a54:	06050513          	addi	a0,a0,96 # 80008ab0 <userret+0xa20>
    80003a58:	ffffd097          	auipc	ra,0xffffd
    80003a5c:	cfe080e7          	jalr	-770(ra) # 80000756 <panic>

0000000080003a60 <iget>:
{
    80003a60:	7179                	addi	sp,sp,-48
    80003a62:	f406                	sd	ra,40(sp)
    80003a64:	f022                	sd	s0,32(sp)
    80003a66:	ec26                	sd	s1,24(sp)
    80003a68:	e84a                	sd	s2,16(sp)
    80003a6a:	e44e                	sd	s3,8(sp)
    80003a6c:	e052                	sd	s4,0(sp)
    80003a6e:	1800                	addi	s0,sp,48
    80003a70:	89aa                	mv	s3,a0
    80003a72:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003a74:	00021517          	auipc	a0,0x21
    80003a78:	03450513          	addi	a0,a0,52 # 80024aa8 <icache>
    80003a7c:	ffffd097          	auipc	ra,0xffffd
    80003a80:	20c080e7          	jalr	524(ra) # 80000c88 <acquire>
  empty = 0;
    80003a84:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003a86:	00021497          	auipc	s1,0x21
    80003a8a:	05248493          	addi	s1,s1,82 # 80024ad8 <icache+0x30>
    80003a8e:	00023697          	auipc	a3,0x23
    80003a92:	f8a68693          	addi	a3,a3,-118 # 80026a18 <log>
    80003a96:	a039                	j	80003aa4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a98:	02090b63          	beqz	s2,80003ace <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003a9c:	0a048493          	addi	s1,s1,160
    80003aa0:	02d48a63          	beq	s1,a3,80003ad4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003aa4:	449c                	lw	a5,8(s1)
    80003aa6:	fef059e3          	blez	a5,80003a98 <iget+0x38>
    80003aaa:	4098                	lw	a4,0(s1)
    80003aac:	ff3716e3          	bne	a4,s3,80003a98 <iget+0x38>
    80003ab0:	40d8                	lw	a4,4(s1)
    80003ab2:	ff4713e3          	bne	a4,s4,80003a98 <iget+0x38>
      ip->ref++;
    80003ab6:	2785                	addiw	a5,a5,1
    80003ab8:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003aba:	00021517          	auipc	a0,0x21
    80003abe:	fee50513          	addi	a0,a0,-18 # 80024aa8 <icache>
    80003ac2:	ffffd097          	auipc	ra,0xffffd
    80003ac6:	412080e7          	jalr	1042(ra) # 80000ed4 <release>
      return ip;
    80003aca:	8926                	mv	s2,s1
    80003acc:	a03d                	j	80003afa <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ace:	f7f9                	bnez	a5,80003a9c <iget+0x3c>
    80003ad0:	8926                	mv	s2,s1
    80003ad2:	b7e9                	j	80003a9c <iget+0x3c>
  if(empty == 0)
    80003ad4:	02090c63          	beqz	s2,80003b0c <iget+0xac>
  ip->dev = dev;
    80003ad8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003adc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003ae0:	4785                	li	a5,1
    80003ae2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ae6:	04092c23          	sw	zero,88(s2)
  release(&icache.lock);
    80003aea:	00021517          	auipc	a0,0x21
    80003aee:	fbe50513          	addi	a0,a0,-66 # 80024aa8 <icache>
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	3e2080e7          	jalr	994(ra) # 80000ed4 <release>
}
    80003afa:	854a                	mv	a0,s2
    80003afc:	70a2                	ld	ra,40(sp)
    80003afe:	7402                	ld	s0,32(sp)
    80003b00:	64e2                	ld	s1,24(sp)
    80003b02:	6942                	ld	s2,16(sp)
    80003b04:	69a2                	ld	s3,8(sp)
    80003b06:	6a02                	ld	s4,0(sp)
    80003b08:	6145                	addi	sp,sp,48
    80003b0a:	8082                	ret
    panic("iget: no inodes");
    80003b0c:	00005517          	auipc	a0,0x5
    80003b10:	fbc50513          	addi	a0,a0,-68 # 80008ac8 <userret+0xa38>
    80003b14:	ffffd097          	auipc	ra,0xffffd
    80003b18:	c42080e7          	jalr	-958(ra) # 80000756 <panic>

0000000080003b1c <fsinit>:
fsinit(int dev) {
    80003b1c:	7179                	addi	sp,sp,-48
    80003b1e:	f406                	sd	ra,40(sp)
    80003b20:	f022                	sd	s0,32(sp)
    80003b22:	ec26                	sd	s1,24(sp)
    80003b24:	e84a                	sd	s2,16(sp)
    80003b26:	e44e                	sd	s3,8(sp)
    80003b28:	1800                	addi	s0,sp,48
    80003b2a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b2c:	4585                	li	a1,1
    80003b2e:	00000097          	auipc	ra,0x0
    80003b32:	a60080e7          	jalr	-1440(ra) # 8000358e <bread>
    80003b36:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b38:	00021997          	auipc	s3,0x21
    80003b3c:	f5098993          	addi	s3,s3,-176 # 80024a88 <sb>
    80003b40:	02000613          	li	a2,32
    80003b44:	07050593          	addi	a1,a0,112
    80003b48:	854e                	mv	a0,s3
    80003b4a:	ffffd097          	auipc	ra,0xffffd
    80003b4e:	5ea080e7          	jalr	1514(ra) # 80001134 <memmove>
  brelse(bp);
    80003b52:	8526                	mv	a0,s1
    80003b54:	00000097          	auipc	ra,0x0
    80003b58:	b6e080e7          	jalr	-1170(ra) # 800036c2 <brelse>
  if(sb.magic != FSMAGIC)
    80003b5c:	0009a703          	lw	a4,0(s3)
    80003b60:	102037b7          	lui	a5,0x10203
    80003b64:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b68:	02f71263          	bne	a4,a5,80003b8c <fsinit+0x70>
  initlog(dev, &sb);
    80003b6c:	00021597          	auipc	a1,0x21
    80003b70:	f1c58593          	addi	a1,a1,-228 # 80024a88 <sb>
    80003b74:	854a                	mv	a0,s2
    80003b76:	00001097          	auipc	ra,0x1
    80003b7a:	b22080e7          	jalr	-1246(ra) # 80004698 <initlog>
}
    80003b7e:	70a2                	ld	ra,40(sp)
    80003b80:	7402                	ld	s0,32(sp)
    80003b82:	64e2                	ld	s1,24(sp)
    80003b84:	6942                	ld	s2,16(sp)
    80003b86:	69a2                	ld	s3,8(sp)
    80003b88:	6145                	addi	sp,sp,48
    80003b8a:	8082                	ret
    panic("invalid file system");
    80003b8c:	00005517          	auipc	a0,0x5
    80003b90:	f4c50513          	addi	a0,a0,-180 # 80008ad8 <userret+0xa48>
    80003b94:	ffffd097          	auipc	ra,0xffffd
    80003b98:	bc2080e7          	jalr	-1086(ra) # 80000756 <panic>

0000000080003b9c <iinit>:
{
    80003b9c:	7179                	addi	sp,sp,-48
    80003b9e:	f406                	sd	ra,40(sp)
    80003ba0:	f022                	sd	s0,32(sp)
    80003ba2:	ec26                	sd	s1,24(sp)
    80003ba4:	e84a                	sd	s2,16(sp)
    80003ba6:	e44e                	sd	s3,8(sp)
    80003ba8:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003baa:	00005597          	auipc	a1,0x5
    80003bae:	f4658593          	addi	a1,a1,-186 # 80008af0 <userret+0xa60>
    80003bb2:	00021517          	auipc	a0,0x21
    80003bb6:	ef650513          	addi	a0,a0,-266 # 80024aa8 <icache>
    80003bba:	ffffd097          	auipc	ra,0xffffd
    80003bbe:	f64080e7          	jalr	-156(ra) # 80000b1e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003bc2:	00021497          	auipc	s1,0x21
    80003bc6:	f2648493          	addi	s1,s1,-218 # 80024ae8 <icache+0x40>
    80003bca:	00023997          	auipc	s3,0x23
    80003bce:	e5e98993          	addi	s3,s3,-418 # 80026a28 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003bd2:	00005917          	auipc	s2,0x5
    80003bd6:	f2690913          	addi	s2,s2,-218 # 80008af8 <userret+0xa68>
    80003bda:	85ca                	mv	a1,s2
    80003bdc:	8526                	mv	a0,s1
    80003bde:	00001097          	auipc	ra,0x1
    80003be2:	f02080e7          	jalr	-254(ra) # 80004ae0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003be6:	0a048493          	addi	s1,s1,160
    80003bea:	ff3498e3          	bne	s1,s3,80003bda <iinit+0x3e>
}
    80003bee:	70a2                	ld	ra,40(sp)
    80003bf0:	7402                	ld	s0,32(sp)
    80003bf2:	64e2                	ld	s1,24(sp)
    80003bf4:	6942                	ld	s2,16(sp)
    80003bf6:	69a2                	ld	s3,8(sp)
    80003bf8:	6145                	addi	sp,sp,48
    80003bfa:	8082                	ret

0000000080003bfc <ialloc>:
{
    80003bfc:	715d                	addi	sp,sp,-80
    80003bfe:	e486                	sd	ra,72(sp)
    80003c00:	e0a2                	sd	s0,64(sp)
    80003c02:	fc26                	sd	s1,56(sp)
    80003c04:	f84a                	sd	s2,48(sp)
    80003c06:	f44e                	sd	s3,40(sp)
    80003c08:	f052                	sd	s4,32(sp)
    80003c0a:	ec56                	sd	s5,24(sp)
    80003c0c:	e85a                	sd	s6,16(sp)
    80003c0e:	e45e                	sd	s7,8(sp)
    80003c10:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c12:	00021717          	auipc	a4,0x21
    80003c16:	e8272703          	lw	a4,-382(a4) # 80024a94 <sb+0xc>
    80003c1a:	4785                	li	a5,1
    80003c1c:	04e7fa63          	bgeu	a5,a4,80003c70 <ialloc+0x74>
    80003c20:	8aaa                	mv	s5,a0
    80003c22:	8bae                	mv	s7,a1
    80003c24:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c26:	00021a17          	auipc	s4,0x21
    80003c2a:	e62a0a13          	addi	s4,s4,-414 # 80024a88 <sb>
    80003c2e:	00048b1b          	sext.w	s6,s1
    80003c32:	0044d593          	srli	a1,s1,0x4
    80003c36:	018a2783          	lw	a5,24(s4)
    80003c3a:	9dbd                	addw	a1,a1,a5
    80003c3c:	8556                	mv	a0,s5
    80003c3e:	00000097          	auipc	ra,0x0
    80003c42:	950080e7          	jalr	-1712(ra) # 8000358e <bread>
    80003c46:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c48:	07050993          	addi	s3,a0,112
    80003c4c:	00f4f793          	andi	a5,s1,15
    80003c50:	079a                	slli	a5,a5,0x6
    80003c52:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c54:	00099783          	lh	a5,0(s3)
    80003c58:	c785                	beqz	a5,80003c80 <ialloc+0x84>
    brelse(bp);
    80003c5a:	00000097          	auipc	ra,0x0
    80003c5e:	a68080e7          	jalr	-1432(ra) # 800036c2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c62:	0485                	addi	s1,s1,1
    80003c64:	00ca2703          	lw	a4,12(s4)
    80003c68:	0004879b          	sext.w	a5,s1
    80003c6c:	fce7e1e3          	bltu	a5,a4,80003c2e <ialloc+0x32>
  panic("ialloc: no inodes");
    80003c70:	00005517          	auipc	a0,0x5
    80003c74:	e9050513          	addi	a0,a0,-368 # 80008b00 <userret+0xa70>
    80003c78:	ffffd097          	auipc	ra,0xffffd
    80003c7c:	ade080e7          	jalr	-1314(ra) # 80000756 <panic>
      memset(dip, 0, sizeof(*dip));
    80003c80:	04000613          	li	a2,64
    80003c84:	4581                	li	a1,0
    80003c86:	854e                	mv	a0,s3
    80003c88:	ffffd097          	auipc	ra,0xffffd
    80003c8c:	44c080e7          	jalr	1100(ra) # 800010d4 <memset>
      dip->type = type;
    80003c90:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c94:	854a                	mv	a0,s2
    80003c96:	00001097          	auipc	ra,0x1
    80003c9a:	d18080e7          	jalr	-744(ra) # 800049ae <log_write>
      brelse(bp);
    80003c9e:	854a                	mv	a0,s2
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	a22080e7          	jalr	-1502(ra) # 800036c2 <brelse>
      return iget(dev, inum);
    80003ca8:	85da                	mv	a1,s6
    80003caa:	8556                	mv	a0,s5
    80003cac:	00000097          	auipc	ra,0x0
    80003cb0:	db4080e7          	jalr	-588(ra) # 80003a60 <iget>
}
    80003cb4:	60a6                	ld	ra,72(sp)
    80003cb6:	6406                	ld	s0,64(sp)
    80003cb8:	74e2                	ld	s1,56(sp)
    80003cba:	7942                	ld	s2,48(sp)
    80003cbc:	79a2                	ld	s3,40(sp)
    80003cbe:	7a02                	ld	s4,32(sp)
    80003cc0:	6ae2                	ld	s5,24(sp)
    80003cc2:	6b42                	ld	s6,16(sp)
    80003cc4:	6ba2                	ld	s7,8(sp)
    80003cc6:	6161                	addi	sp,sp,80
    80003cc8:	8082                	ret

0000000080003cca <iupdate>:
{
    80003cca:	1101                	addi	sp,sp,-32
    80003ccc:	ec06                	sd	ra,24(sp)
    80003cce:	e822                	sd	s0,16(sp)
    80003cd0:	e426                	sd	s1,8(sp)
    80003cd2:	e04a                	sd	s2,0(sp)
    80003cd4:	1000                	addi	s0,sp,32
    80003cd6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cd8:	415c                	lw	a5,4(a0)
    80003cda:	0047d79b          	srliw	a5,a5,0x4
    80003cde:	00021597          	auipc	a1,0x21
    80003ce2:	dc25a583          	lw	a1,-574(a1) # 80024aa0 <sb+0x18>
    80003ce6:	9dbd                	addw	a1,a1,a5
    80003ce8:	4108                	lw	a0,0(a0)
    80003cea:	00000097          	auipc	ra,0x0
    80003cee:	8a4080e7          	jalr	-1884(ra) # 8000358e <bread>
    80003cf2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cf4:	07050793          	addi	a5,a0,112
    80003cf8:	40c8                	lw	a0,4(s1)
    80003cfa:	893d                	andi	a0,a0,15
    80003cfc:	051a                	slli	a0,a0,0x6
    80003cfe:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003d00:	05c49703          	lh	a4,92(s1)
    80003d04:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003d08:	05e49703          	lh	a4,94(s1)
    80003d0c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003d10:	06049703          	lh	a4,96(s1)
    80003d14:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003d18:	06249703          	lh	a4,98(s1)
    80003d1c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003d20:	50f8                	lw	a4,100(s1)
    80003d22:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d24:	03400613          	li	a2,52
    80003d28:	06848593          	addi	a1,s1,104
    80003d2c:	0531                	addi	a0,a0,12
    80003d2e:	ffffd097          	auipc	ra,0xffffd
    80003d32:	406080e7          	jalr	1030(ra) # 80001134 <memmove>
  log_write(bp);
    80003d36:	854a                	mv	a0,s2
    80003d38:	00001097          	auipc	ra,0x1
    80003d3c:	c76080e7          	jalr	-906(ra) # 800049ae <log_write>
  brelse(bp);
    80003d40:	854a                	mv	a0,s2
    80003d42:	00000097          	auipc	ra,0x0
    80003d46:	980080e7          	jalr	-1664(ra) # 800036c2 <brelse>
}
    80003d4a:	60e2                	ld	ra,24(sp)
    80003d4c:	6442                	ld	s0,16(sp)
    80003d4e:	64a2                	ld	s1,8(sp)
    80003d50:	6902                	ld	s2,0(sp)
    80003d52:	6105                	addi	sp,sp,32
    80003d54:	8082                	ret

0000000080003d56 <idup>:
{
    80003d56:	1101                	addi	sp,sp,-32
    80003d58:	ec06                	sd	ra,24(sp)
    80003d5a:	e822                	sd	s0,16(sp)
    80003d5c:	e426                	sd	s1,8(sp)
    80003d5e:	1000                	addi	s0,sp,32
    80003d60:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003d62:	00021517          	auipc	a0,0x21
    80003d66:	d4650513          	addi	a0,a0,-698 # 80024aa8 <icache>
    80003d6a:	ffffd097          	auipc	ra,0xffffd
    80003d6e:	f1e080e7          	jalr	-226(ra) # 80000c88 <acquire>
  ip->ref++;
    80003d72:	449c                	lw	a5,8(s1)
    80003d74:	2785                	addiw	a5,a5,1
    80003d76:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003d78:	00021517          	auipc	a0,0x21
    80003d7c:	d3050513          	addi	a0,a0,-720 # 80024aa8 <icache>
    80003d80:	ffffd097          	auipc	ra,0xffffd
    80003d84:	154080e7          	jalr	340(ra) # 80000ed4 <release>
}
    80003d88:	8526                	mv	a0,s1
    80003d8a:	60e2                	ld	ra,24(sp)
    80003d8c:	6442                	ld	s0,16(sp)
    80003d8e:	64a2                	ld	s1,8(sp)
    80003d90:	6105                	addi	sp,sp,32
    80003d92:	8082                	ret

0000000080003d94 <ilock>:
{
    80003d94:	1101                	addi	sp,sp,-32
    80003d96:	ec06                	sd	ra,24(sp)
    80003d98:	e822                	sd	s0,16(sp)
    80003d9a:	e426                	sd	s1,8(sp)
    80003d9c:	e04a                	sd	s2,0(sp)
    80003d9e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003da0:	c115                	beqz	a0,80003dc4 <ilock+0x30>
    80003da2:	84aa                	mv	s1,a0
    80003da4:	451c                	lw	a5,8(a0)
    80003da6:	00f05f63          	blez	a5,80003dc4 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003daa:	0541                	addi	a0,a0,16
    80003dac:	00001097          	auipc	ra,0x1
    80003db0:	d6e080e7          	jalr	-658(ra) # 80004b1a <acquiresleep>
  if(ip->valid == 0){
    80003db4:	4cbc                	lw	a5,88(s1)
    80003db6:	cf99                	beqz	a5,80003dd4 <ilock+0x40>
}
    80003db8:	60e2                	ld	ra,24(sp)
    80003dba:	6442                	ld	s0,16(sp)
    80003dbc:	64a2                	ld	s1,8(sp)
    80003dbe:	6902                	ld	s2,0(sp)
    80003dc0:	6105                	addi	sp,sp,32
    80003dc2:	8082                	ret
    panic("ilock");
    80003dc4:	00005517          	auipc	a0,0x5
    80003dc8:	d5450513          	addi	a0,a0,-684 # 80008b18 <userret+0xa88>
    80003dcc:	ffffd097          	auipc	ra,0xffffd
    80003dd0:	98a080e7          	jalr	-1654(ra) # 80000756 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003dd4:	40dc                	lw	a5,4(s1)
    80003dd6:	0047d79b          	srliw	a5,a5,0x4
    80003dda:	00021597          	auipc	a1,0x21
    80003dde:	cc65a583          	lw	a1,-826(a1) # 80024aa0 <sb+0x18>
    80003de2:	9dbd                	addw	a1,a1,a5
    80003de4:	4088                	lw	a0,0(s1)
    80003de6:	fffff097          	auipc	ra,0xfffff
    80003dea:	7a8080e7          	jalr	1960(ra) # 8000358e <bread>
    80003dee:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003df0:	07050593          	addi	a1,a0,112
    80003df4:	40dc                	lw	a5,4(s1)
    80003df6:	8bbd                	andi	a5,a5,15
    80003df8:	079a                	slli	a5,a5,0x6
    80003dfa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003dfc:	00059783          	lh	a5,0(a1)
    80003e00:	04f49e23          	sh	a5,92(s1)
    ip->major = dip->major;
    80003e04:	00259783          	lh	a5,2(a1)
    80003e08:	04f49f23          	sh	a5,94(s1)
    ip->minor = dip->minor;
    80003e0c:	00459783          	lh	a5,4(a1)
    80003e10:	06f49023          	sh	a5,96(s1)
    ip->nlink = dip->nlink;
    80003e14:	00659783          	lh	a5,6(a1)
    80003e18:	06f49123          	sh	a5,98(s1)
    ip->size = dip->size;
    80003e1c:	459c                	lw	a5,8(a1)
    80003e1e:	d0fc                	sw	a5,100(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e20:	03400613          	li	a2,52
    80003e24:	05b1                	addi	a1,a1,12
    80003e26:	06848513          	addi	a0,s1,104
    80003e2a:	ffffd097          	auipc	ra,0xffffd
    80003e2e:	30a080e7          	jalr	778(ra) # 80001134 <memmove>
    brelse(bp);
    80003e32:	854a                	mv	a0,s2
    80003e34:	00000097          	auipc	ra,0x0
    80003e38:	88e080e7          	jalr	-1906(ra) # 800036c2 <brelse>
    ip->valid = 1;
    80003e3c:	4785                	li	a5,1
    80003e3e:	ccbc                	sw	a5,88(s1)
    if(ip->type == 0)
    80003e40:	05c49783          	lh	a5,92(s1)
    80003e44:	fbb5                	bnez	a5,80003db8 <ilock+0x24>
      panic("ilock: no type");
    80003e46:	00005517          	auipc	a0,0x5
    80003e4a:	cda50513          	addi	a0,a0,-806 # 80008b20 <userret+0xa90>
    80003e4e:	ffffd097          	auipc	ra,0xffffd
    80003e52:	908080e7          	jalr	-1784(ra) # 80000756 <panic>

0000000080003e56 <iunlock>:
{
    80003e56:	1101                	addi	sp,sp,-32
    80003e58:	ec06                	sd	ra,24(sp)
    80003e5a:	e822                	sd	s0,16(sp)
    80003e5c:	e426                	sd	s1,8(sp)
    80003e5e:	e04a                	sd	s2,0(sp)
    80003e60:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e62:	c905                	beqz	a0,80003e92 <iunlock+0x3c>
    80003e64:	84aa                	mv	s1,a0
    80003e66:	01050913          	addi	s2,a0,16
    80003e6a:	854a                	mv	a0,s2
    80003e6c:	00001097          	auipc	ra,0x1
    80003e70:	d48080e7          	jalr	-696(ra) # 80004bb4 <holdingsleep>
    80003e74:	cd19                	beqz	a0,80003e92 <iunlock+0x3c>
    80003e76:	449c                	lw	a5,8(s1)
    80003e78:	00f05d63          	blez	a5,80003e92 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e7c:	854a                	mv	a0,s2
    80003e7e:	00001097          	auipc	ra,0x1
    80003e82:	cf2080e7          	jalr	-782(ra) # 80004b70 <releasesleep>
}
    80003e86:	60e2                	ld	ra,24(sp)
    80003e88:	6442                	ld	s0,16(sp)
    80003e8a:	64a2                	ld	s1,8(sp)
    80003e8c:	6902                	ld	s2,0(sp)
    80003e8e:	6105                	addi	sp,sp,32
    80003e90:	8082                	ret
    panic("iunlock");
    80003e92:	00005517          	auipc	a0,0x5
    80003e96:	c9e50513          	addi	a0,a0,-866 # 80008b30 <userret+0xaa0>
    80003e9a:	ffffd097          	auipc	ra,0xffffd
    80003e9e:	8bc080e7          	jalr	-1860(ra) # 80000756 <panic>

0000000080003ea2 <iput>:
{
    80003ea2:	7139                	addi	sp,sp,-64
    80003ea4:	fc06                	sd	ra,56(sp)
    80003ea6:	f822                	sd	s0,48(sp)
    80003ea8:	f426                	sd	s1,40(sp)
    80003eaa:	f04a                	sd	s2,32(sp)
    80003eac:	ec4e                	sd	s3,24(sp)
    80003eae:	e852                	sd	s4,16(sp)
    80003eb0:	e456                	sd	s5,8(sp)
    80003eb2:	0080                	addi	s0,sp,64
    80003eb4:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003eb6:	00021517          	auipc	a0,0x21
    80003eba:	bf250513          	addi	a0,a0,-1038 # 80024aa8 <icache>
    80003ebe:	ffffd097          	auipc	ra,0xffffd
    80003ec2:	dca080e7          	jalr	-566(ra) # 80000c88 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ec6:	4498                	lw	a4,8(s1)
    80003ec8:	4785                	li	a5,1
    80003eca:	02f70663          	beq	a4,a5,80003ef6 <iput+0x54>
  ip->ref--;
    80003ece:	449c                	lw	a5,8(s1)
    80003ed0:	37fd                	addiw	a5,a5,-1
    80003ed2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003ed4:	00021517          	auipc	a0,0x21
    80003ed8:	bd450513          	addi	a0,a0,-1068 # 80024aa8 <icache>
    80003edc:	ffffd097          	auipc	ra,0xffffd
    80003ee0:	ff8080e7          	jalr	-8(ra) # 80000ed4 <release>
}
    80003ee4:	70e2                	ld	ra,56(sp)
    80003ee6:	7442                	ld	s0,48(sp)
    80003ee8:	74a2                	ld	s1,40(sp)
    80003eea:	7902                	ld	s2,32(sp)
    80003eec:	69e2                	ld	s3,24(sp)
    80003eee:	6a42                	ld	s4,16(sp)
    80003ef0:	6aa2                	ld	s5,8(sp)
    80003ef2:	6121                	addi	sp,sp,64
    80003ef4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ef6:	4cbc                	lw	a5,88(s1)
    80003ef8:	dbf9                	beqz	a5,80003ece <iput+0x2c>
    80003efa:	06249783          	lh	a5,98(s1)
    80003efe:	fbe1                	bnez	a5,80003ece <iput+0x2c>
    acquiresleep(&ip->lock);
    80003f00:	01048a13          	addi	s4,s1,16
    80003f04:	8552                	mv	a0,s4
    80003f06:	00001097          	auipc	ra,0x1
    80003f0a:	c14080e7          	jalr	-1004(ra) # 80004b1a <acquiresleep>
    release(&icache.lock);
    80003f0e:	00021517          	auipc	a0,0x21
    80003f12:	b9a50513          	addi	a0,a0,-1126 # 80024aa8 <icache>
    80003f16:	ffffd097          	auipc	ra,0xffffd
    80003f1a:	fbe080e7          	jalr	-66(ra) # 80000ed4 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003f1e:	06848913          	addi	s2,s1,104
    80003f22:	09848993          	addi	s3,s1,152
    80003f26:	a819                	j	80003f3c <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003f28:	4088                	lw	a0,0(s1)
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	8ae080e7          	jalr	-1874(ra) # 800037d8 <bfree>
      ip->addrs[i] = 0;
    80003f32:	00092023          	sw	zero,0(s2)
  for(i = 0; i < NDIRECT; i++){
    80003f36:	0911                	addi	s2,s2,4
    80003f38:	01390663          	beq	s2,s3,80003f44 <iput+0xa2>
    if(ip->addrs[i]){
    80003f3c:	00092583          	lw	a1,0(s2)
    80003f40:	d9fd                	beqz	a1,80003f36 <iput+0x94>
    80003f42:	b7dd                	j	80003f28 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f44:	0984a583          	lw	a1,152(s1)
    80003f48:	ed9d                	bnez	a1,80003f86 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f4a:	0604a223          	sw	zero,100(s1)
  iupdate(ip);
    80003f4e:	8526                	mv	a0,s1
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	d7a080e7          	jalr	-646(ra) # 80003cca <iupdate>
    ip->type = 0;
    80003f58:	04049e23          	sh	zero,92(s1)
    iupdate(ip);
    80003f5c:	8526                	mv	a0,s1
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	d6c080e7          	jalr	-660(ra) # 80003cca <iupdate>
    ip->valid = 0;
    80003f66:	0404ac23          	sw	zero,88(s1)
    releasesleep(&ip->lock);
    80003f6a:	8552                	mv	a0,s4
    80003f6c:	00001097          	auipc	ra,0x1
    80003f70:	c04080e7          	jalr	-1020(ra) # 80004b70 <releasesleep>
    acquire(&icache.lock);
    80003f74:	00021517          	auipc	a0,0x21
    80003f78:	b3450513          	addi	a0,a0,-1228 # 80024aa8 <icache>
    80003f7c:	ffffd097          	auipc	ra,0xffffd
    80003f80:	d0c080e7          	jalr	-756(ra) # 80000c88 <acquire>
    80003f84:	b7a9                	j	80003ece <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f86:	4088                	lw	a0,0(s1)
    80003f88:	fffff097          	auipc	ra,0xfffff
    80003f8c:	606080e7          	jalr	1542(ra) # 8000358e <bread>
    80003f90:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003f92:	07050913          	addi	s2,a0,112
    80003f96:	47050993          	addi	s3,a0,1136
    80003f9a:	a809                	j	80003fac <iput+0x10a>
        bfree(ip->dev, a[j]);
    80003f9c:	4088                	lw	a0,0(s1)
    80003f9e:	00000097          	auipc	ra,0x0
    80003fa2:	83a080e7          	jalr	-1990(ra) # 800037d8 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003fa6:	0911                	addi	s2,s2,4
    80003fa8:	01390663          	beq	s2,s3,80003fb4 <iput+0x112>
      if(a[j])
    80003fac:	00092583          	lw	a1,0(s2)
    80003fb0:	d9fd                	beqz	a1,80003fa6 <iput+0x104>
    80003fb2:	b7ed                	j	80003f9c <iput+0xfa>
    brelse(bp);
    80003fb4:	8556                	mv	a0,s5
    80003fb6:	fffff097          	auipc	ra,0xfffff
    80003fba:	70c080e7          	jalr	1804(ra) # 800036c2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003fbe:	0984a583          	lw	a1,152(s1)
    80003fc2:	4088                	lw	a0,0(s1)
    80003fc4:	00000097          	auipc	ra,0x0
    80003fc8:	814080e7          	jalr	-2028(ra) # 800037d8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003fcc:	0804ac23          	sw	zero,152(s1)
    80003fd0:	bfad                	j	80003f4a <iput+0xa8>

0000000080003fd2 <iunlockput>:
{
    80003fd2:	1101                	addi	sp,sp,-32
    80003fd4:	ec06                	sd	ra,24(sp)
    80003fd6:	e822                	sd	s0,16(sp)
    80003fd8:	e426                	sd	s1,8(sp)
    80003fda:	1000                	addi	s0,sp,32
    80003fdc:	84aa                	mv	s1,a0
  iunlock(ip);
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	e78080e7          	jalr	-392(ra) # 80003e56 <iunlock>
  iput(ip);
    80003fe6:	8526                	mv	a0,s1
    80003fe8:	00000097          	auipc	ra,0x0
    80003fec:	eba080e7          	jalr	-326(ra) # 80003ea2 <iput>
}
    80003ff0:	60e2                	ld	ra,24(sp)
    80003ff2:	6442                	ld	s0,16(sp)
    80003ff4:	64a2                	ld	s1,8(sp)
    80003ff6:	6105                	addi	sp,sp,32
    80003ff8:	8082                	ret

0000000080003ffa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ffa:	1141                	addi	sp,sp,-16
    80003ffc:	e422                	sd	s0,8(sp)
    80003ffe:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004000:	411c                	lw	a5,0(a0)
    80004002:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004004:	415c                	lw	a5,4(a0)
    80004006:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004008:	05c51783          	lh	a5,92(a0)
    8000400c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004010:	06251783          	lh	a5,98(a0)
    80004014:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004018:	06456783          	lwu	a5,100(a0)
    8000401c:	e99c                	sd	a5,16(a1)
}
    8000401e:	6422                	ld	s0,8(sp)
    80004020:	0141                	addi	sp,sp,16
    80004022:	8082                	ret

0000000080004024 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004024:	517c                	lw	a5,100(a0)
    80004026:	0ed7e563          	bltu	a5,a3,80004110 <readi+0xec>
{
    8000402a:	7159                	addi	sp,sp,-112
    8000402c:	f486                	sd	ra,104(sp)
    8000402e:	f0a2                	sd	s0,96(sp)
    80004030:	eca6                	sd	s1,88(sp)
    80004032:	e8ca                	sd	s2,80(sp)
    80004034:	e4ce                	sd	s3,72(sp)
    80004036:	e0d2                	sd	s4,64(sp)
    80004038:	fc56                	sd	s5,56(sp)
    8000403a:	f85a                	sd	s6,48(sp)
    8000403c:	f45e                	sd	s7,40(sp)
    8000403e:	f062                	sd	s8,32(sp)
    80004040:	ec66                	sd	s9,24(sp)
    80004042:	e86a                	sd	s10,16(sp)
    80004044:	e46e                	sd	s11,8(sp)
    80004046:	1880                	addi	s0,sp,112
    80004048:	8baa                	mv	s7,a0
    8000404a:	8c2e                	mv	s8,a1
    8000404c:	8ab2                	mv	s5,a2
    8000404e:	8936                	mv	s2,a3
    80004050:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004052:	9f35                	addw	a4,a4,a3
    80004054:	0cd76063          	bltu	a4,a3,80004114 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80004058:	00e7f463          	bgeu	a5,a4,80004060 <readi+0x3c>
    n = ip->size - off;
    8000405c:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004060:	080b0763          	beqz	s6,800040ee <readi+0xca>
    80004064:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004066:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000406a:	5cfd                	li	s9,-1
    8000406c:	a82d                	j	800040a6 <readi+0x82>
    8000406e:	02099d93          	slli	s11,s3,0x20
    80004072:	020ddd93          	srli	s11,s11,0x20
    80004076:	07048613          	addi	a2,s1,112
    8000407a:	86ee                	mv	a3,s11
    8000407c:	963a                	add	a2,a2,a4
    8000407e:	85d6                	mv	a1,s5
    80004080:	8562                	mv	a0,s8
    80004082:	fffff097          	auipc	ra,0xfffff
    80004086:	9aa080e7          	jalr	-1622(ra) # 80002a2c <either_copyout>
    8000408a:	05950d63          	beq	a0,s9,800040e4 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    8000408e:	8526                	mv	a0,s1
    80004090:	fffff097          	auipc	ra,0xfffff
    80004094:	632080e7          	jalr	1586(ra) # 800036c2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004098:	01498a3b          	addw	s4,s3,s4
    8000409c:	0129893b          	addw	s2,s3,s2
    800040a0:	9aee                	add	s5,s5,s11
    800040a2:	056a7663          	bgeu	s4,s6,800040ee <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040a6:	000ba483          	lw	s1,0(s7)
    800040aa:	00a9559b          	srliw	a1,s2,0xa
    800040ae:	855e                	mv	a0,s7
    800040b0:	00000097          	auipc	ra,0x0
    800040b4:	8d6080e7          	jalr	-1834(ra) # 80003986 <bmap>
    800040b8:	0005059b          	sext.w	a1,a0
    800040bc:	8526                	mv	a0,s1
    800040be:	fffff097          	auipc	ra,0xfffff
    800040c2:	4d0080e7          	jalr	1232(ra) # 8000358e <bread>
    800040c6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040c8:	3ff97713          	andi	a4,s2,1023
    800040cc:	40ed07bb          	subw	a5,s10,a4
    800040d0:	414b06bb          	subw	a3,s6,s4
    800040d4:	89be                	mv	s3,a5
    800040d6:	2781                	sext.w	a5,a5
    800040d8:	0006861b          	sext.w	a2,a3
    800040dc:	f8f679e3          	bgeu	a2,a5,8000406e <readi+0x4a>
    800040e0:	89b6                	mv	s3,a3
    800040e2:	b771                	j	8000406e <readi+0x4a>
      brelse(bp);
    800040e4:	8526                	mv	a0,s1
    800040e6:	fffff097          	auipc	ra,0xfffff
    800040ea:	5dc080e7          	jalr	1500(ra) # 800036c2 <brelse>
  }
  return n;
    800040ee:	000b051b          	sext.w	a0,s6
}
    800040f2:	70a6                	ld	ra,104(sp)
    800040f4:	7406                	ld	s0,96(sp)
    800040f6:	64e6                	ld	s1,88(sp)
    800040f8:	6946                	ld	s2,80(sp)
    800040fa:	69a6                	ld	s3,72(sp)
    800040fc:	6a06                	ld	s4,64(sp)
    800040fe:	7ae2                	ld	s5,56(sp)
    80004100:	7b42                	ld	s6,48(sp)
    80004102:	7ba2                	ld	s7,40(sp)
    80004104:	7c02                	ld	s8,32(sp)
    80004106:	6ce2                	ld	s9,24(sp)
    80004108:	6d42                	ld	s10,16(sp)
    8000410a:	6da2                	ld	s11,8(sp)
    8000410c:	6165                	addi	sp,sp,112
    8000410e:	8082                	ret
    return -1;
    80004110:	557d                	li	a0,-1
}
    80004112:	8082                	ret
    return -1;
    80004114:	557d                	li	a0,-1
    80004116:	bff1                	j	800040f2 <readi+0xce>

0000000080004118 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004118:	517c                	lw	a5,100(a0)
    8000411a:	10d7e663          	bltu	a5,a3,80004226 <writei+0x10e>
{
    8000411e:	7159                	addi	sp,sp,-112
    80004120:	f486                	sd	ra,104(sp)
    80004122:	f0a2                	sd	s0,96(sp)
    80004124:	eca6                	sd	s1,88(sp)
    80004126:	e8ca                	sd	s2,80(sp)
    80004128:	e4ce                	sd	s3,72(sp)
    8000412a:	e0d2                	sd	s4,64(sp)
    8000412c:	fc56                	sd	s5,56(sp)
    8000412e:	f85a                	sd	s6,48(sp)
    80004130:	f45e                	sd	s7,40(sp)
    80004132:	f062                	sd	s8,32(sp)
    80004134:	ec66                	sd	s9,24(sp)
    80004136:	e86a                	sd	s10,16(sp)
    80004138:	e46e                	sd	s11,8(sp)
    8000413a:	1880                	addi	s0,sp,112
    8000413c:	8baa                	mv	s7,a0
    8000413e:	8c2e                	mv	s8,a1
    80004140:	8ab2                	mv	s5,a2
    80004142:	8936                	mv	s2,a3
    80004144:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004146:	00e687bb          	addw	a5,a3,a4
    8000414a:	0ed7e063          	bltu	a5,a3,8000422a <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000414e:	00043737          	lui	a4,0x43
    80004152:	0cf76e63          	bltu	a4,a5,8000422e <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004156:	0a0b0763          	beqz	s6,80004204 <writei+0xec>
    8000415a:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000415c:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004160:	5cfd                	li	s9,-1
    80004162:	a091                	j	800041a6 <writei+0x8e>
    80004164:	02099d93          	slli	s11,s3,0x20
    80004168:	020ddd93          	srli	s11,s11,0x20
    8000416c:	07048513          	addi	a0,s1,112
    80004170:	86ee                	mv	a3,s11
    80004172:	8656                	mv	a2,s5
    80004174:	85e2                	mv	a1,s8
    80004176:	953a                	add	a0,a0,a4
    80004178:	fffff097          	auipc	ra,0xfffff
    8000417c:	90a080e7          	jalr	-1782(ra) # 80002a82 <either_copyin>
    80004180:	07950263          	beq	a0,s9,800041e4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004184:	8526                	mv	a0,s1
    80004186:	00001097          	auipc	ra,0x1
    8000418a:	828080e7          	jalr	-2008(ra) # 800049ae <log_write>
    brelse(bp);
    8000418e:	8526                	mv	a0,s1
    80004190:	fffff097          	auipc	ra,0xfffff
    80004194:	532080e7          	jalr	1330(ra) # 800036c2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004198:	01498a3b          	addw	s4,s3,s4
    8000419c:	0129893b          	addw	s2,s3,s2
    800041a0:	9aee                	add	s5,s5,s11
    800041a2:	056a7663          	bgeu	s4,s6,800041ee <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800041a6:	000ba483          	lw	s1,0(s7)
    800041aa:	00a9559b          	srliw	a1,s2,0xa
    800041ae:	855e                	mv	a0,s7
    800041b0:	fffff097          	auipc	ra,0xfffff
    800041b4:	7d6080e7          	jalr	2006(ra) # 80003986 <bmap>
    800041b8:	0005059b          	sext.w	a1,a0
    800041bc:	8526                	mv	a0,s1
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	3d0080e7          	jalr	976(ra) # 8000358e <bread>
    800041c6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800041c8:	3ff97713          	andi	a4,s2,1023
    800041cc:	40ed07bb          	subw	a5,s10,a4
    800041d0:	414b06bb          	subw	a3,s6,s4
    800041d4:	89be                	mv	s3,a5
    800041d6:	2781                	sext.w	a5,a5
    800041d8:	0006861b          	sext.w	a2,a3
    800041dc:	f8f674e3          	bgeu	a2,a5,80004164 <writei+0x4c>
    800041e0:	89b6                	mv	s3,a3
    800041e2:	b749                	j	80004164 <writei+0x4c>
      brelse(bp);
    800041e4:	8526                	mv	a0,s1
    800041e6:	fffff097          	auipc	ra,0xfffff
    800041ea:	4dc080e7          	jalr	1244(ra) # 800036c2 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    800041ee:	064ba783          	lw	a5,100(s7)
    800041f2:	0127f463          	bgeu	a5,s2,800041fa <writei+0xe2>
      ip->size = off;
    800041f6:	072ba223          	sw	s2,100(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    800041fa:	855e                	mv	a0,s7
    800041fc:	00000097          	auipc	ra,0x0
    80004200:	ace080e7          	jalr	-1330(ra) # 80003cca <iupdate>
  }

  return n;
    80004204:	000b051b          	sext.w	a0,s6
}
    80004208:	70a6                	ld	ra,104(sp)
    8000420a:	7406                	ld	s0,96(sp)
    8000420c:	64e6                	ld	s1,88(sp)
    8000420e:	6946                	ld	s2,80(sp)
    80004210:	69a6                	ld	s3,72(sp)
    80004212:	6a06                	ld	s4,64(sp)
    80004214:	7ae2                	ld	s5,56(sp)
    80004216:	7b42                	ld	s6,48(sp)
    80004218:	7ba2                	ld	s7,40(sp)
    8000421a:	7c02                	ld	s8,32(sp)
    8000421c:	6ce2                	ld	s9,24(sp)
    8000421e:	6d42                	ld	s10,16(sp)
    80004220:	6da2                	ld	s11,8(sp)
    80004222:	6165                	addi	sp,sp,112
    80004224:	8082                	ret
    return -1;
    80004226:	557d                	li	a0,-1
}
    80004228:	8082                	ret
    return -1;
    8000422a:	557d                	li	a0,-1
    8000422c:	bff1                	j	80004208 <writei+0xf0>
    return -1;
    8000422e:	557d                	li	a0,-1
    80004230:	bfe1                	j	80004208 <writei+0xf0>

0000000080004232 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004232:	1141                	addi	sp,sp,-16
    80004234:	e406                	sd	ra,8(sp)
    80004236:	e022                	sd	s0,0(sp)
    80004238:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000423a:	4639                	li	a2,14
    8000423c:	ffffd097          	auipc	ra,0xffffd
    80004240:	f74080e7          	jalr	-140(ra) # 800011b0 <strncmp>
}
    80004244:	60a2                	ld	ra,8(sp)
    80004246:	6402                	ld	s0,0(sp)
    80004248:	0141                	addi	sp,sp,16
    8000424a:	8082                	ret

000000008000424c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000424c:	7139                	addi	sp,sp,-64
    8000424e:	fc06                	sd	ra,56(sp)
    80004250:	f822                	sd	s0,48(sp)
    80004252:	f426                	sd	s1,40(sp)
    80004254:	f04a                	sd	s2,32(sp)
    80004256:	ec4e                	sd	s3,24(sp)
    80004258:	e852                	sd	s4,16(sp)
    8000425a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000425c:	05c51703          	lh	a4,92(a0)
    80004260:	4785                	li	a5,1
    80004262:	00f71a63          	bne	a4,a5,80004276 <dirlookup+0x2a>
    80004266:	892a                	mv	s2,a0
    80004268:	89ae                	mv	s3,a1
    8000426a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000426c:	517c                	lw	a5,100(a0)
    8000426e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004270:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004272:	e79d                	bnez	a5,800042a0 <dirlookup+0x54>
    80004274:	a8a5                	j	800042ec <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004276:	00005517          	auipc	a0,0x5
    8000427a:	8c250513          	addi	a0,a0,-1854 # 80008b38 <userret+0xaa8>
    8000427e:	ffffc097          	auipc	ra,0xffffc
    80004282:	4d8080e7          	jalr	1240(ra) # 80000756 <panic>
      panic("dirlookup read");
    80004286:	00005517          	auipc	a0,0x5
    8000428a:	8ca50513          	addi	a0,a0,-1846 # 80008b50 <userret+0xac0>
    8000428e:	ffffc097          	auipc	ra,0xffffc
    80004292:	4c8080e7          	jalr	1224(ra) # 80000756 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004296:	24c1                	addiw	s1,s1,16
    80004298:	06492783          	lw	a5,100(s2)
    8000429c:	04f4f763          	bgeu	s1,a5,800042ea <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042a0:	4741                	li	a4,16
    800042a2:	86a6                	mv	a3,s1
    800042a4:	fc040613          	addi	a2,s0,-64
    800042a8:	4581                	li	a1,0
    800042aa:	854a                	mv	a0,s2
    800042ac:	00000097          	auipc	ra,0x0
    800042b0:	d78080e7          	jalr	-648(ra) # 80004024 <readi>
    800042b4:	47c1                	li	a5,16
    800042b6:	fcf518e3          	bne	a0,a5,80004286 <dirlookup+0x3a>
    if(de.inum == 0)
    800042ba:	fc045783          	lhu	a5,-64(s0)
    800042be:	dfe1                	beqz	a5,80004296 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800042c0:	fc240593          	addi	a1,s0,-62
    800042c4:	854e                	mv	a0,s3
    800042c6:	00000097          	auipc	ra,0x0
    800042ca:	f6c080e7          	jalr	-148(ra) # 80004232 <namecmp>
    800042ce:	f561                	bnez	a0,80004296 <dirlookup+0x4a>
      if(poff)
    800042d0:	000a0463          	beqz	s4,800042d8 <dirlookup+0x8c>
        *poff = off;
    800042d4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800042d8:	fc045583          	lhu	a1,-64(s0)
    800042dc:	00092503          	lw	a0,0(s2)
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	780080e7          	jalr	1920(ra) # 80003a60 <iget>
    800042e8:	a011                	j	800042ec <dirlookup+0xa0>
  return 0;
    800042ea:	4501                	li	a0,0
}
    800042ec:	70e2                	ld	ra,56(sp)
    800042ee:	7442                	ld	s0,48(sp)
    800042f0:	74a2                	ld	s1,40(sp)
    800042f2:	7902                	ld	s2,32(sp)
    800042f4:	69e2                	ld	s3,24(sp)
    800042f6:	6a42                	ld	s4,16(sp)
    800042f8:	6121                	addi	sp,sp,64
    800042fa:	8082                	ret

00000000800042fc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042fc:	711d                	addi	sp,sp,-96
    800042fe:	ec86                	sd	ra,88(sp)
    80004300:	e8a2                	sd	s0,80(sp)
    80004302:	e4a6                	sd	s1,72(sp)
    80004304:	e0ca                	sd	s2,64(sp)
    80004306:	fc4e                	sd	s3,56(sp)
    80004308:	f852                	sd	s4,48(sp)
    8000430a:	f456                	sd	s5,40(sp)
    8000430c:	f05a                	sd	s6,32(sp)
    8000430e:	ec5e                	sd	s7,24(sp)
    80004310:	e862                	sd	s8,16(sp)
    80004312:	e466                	sd	s9,8(sp)
    80004314:	1080                	addi	s0,sp,96
    80004316:	84aa                	mv	s1,a0
    80004318:	8b2e                	mv	s6,a1
    8000431a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000431c:	00054703          	lbu	a4,0(a0)
    80004320:	02f00793          	li	a5,47
    80004324:	02f70363          	beq	a4,a5,8000434a <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004328:	ffffe097          	auipc	ra,0xffffe
    8000432c:	c74080e7          	jalr	-908(ra) # 80001f9c <myproc>
    80004330:	16853503          	ld	a0,360(a0)
    80004334:	00000097          	auipc	ra,0x0
    80004338:	a22080e7          	jalr	-1502(ra) # 80003d56 <idup>
    8000433c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000433e:	02f00913          	li	s2,47
  len = path - s;
    80004342:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004344:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004346:	4c05                	li	s8,1
    80004348:	a865                	j	80004400 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000434a:	4585                	li	a1,1
    8000434c:	4501                	li	a0,0
    8000434e:	fffff097          	auipc	ra,0xfffff
    80004352:	712080e7          	jalr	1810(ra) # 80003a60 <iget>
    80004356:	89aa                	mv	s3,a0
    80004358:	b7dd                	j	8000433e <namex+0x42>
      iunlockput(ip);
    8000435a:	854e                	mv	a0,s3
    8000435c:	00000097          	auipc	ra,0x0
    80004360:	c76080e7          	jalr	-906(ra) # 80003fd2 <iunlockput>
      return 0;
    80004364:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004366:	854e                	mv	a0,s3
    80004368:	60e6                	ld	ra,88(sp)
    8000436a:	6446                	ld	s0,80(sp)
    8000436c:	64a6                	ld	s1,72(sp)
    8000436e:	6906                	ld	s2,64(sp)
    80004370:	79e2                	ld	s3,56(sp)
    80004372:	7a42                	ld	s4,48(sp)
    80004374:	7aa2                	ld	s5,40(sp)
    80004376:	7b02                	ld	s6,32(sp)
    80004378:	6be2                	ld	s7,24(sp)
    8000437a:	6c42                	ld	s8,16(sp)
    8000437c:	6ca2                	ld	s9,8(sp)
    8000437e:	6125                	addi	sp,sp,96
    80004380:	8082                	ret
      iunlock(ip);
    80004382:	854e                	mv	a0,s3
    80004384:	00000097          	auipc	ra,0x0
    80004388:	ad2080e7          	jalr	-1326(ra) # 80003e56 <iunlock>
      return ip;
    8000438c:	bfe9                	j	80004366 <namex+0x6a>
      iunlockput(ip);
    8000438e:	854e                	mv	a0,s3
    80004390:	00000097          	auipc	ra,0x0
    80004394:	c42080e7          	jalr	-958(ra) # 80003fd2 <iunlockput>
      return 0;
    80004398:	89d2                	mv	s3,s4
    8000439a:	b7f1                	j	80004366 <namex+0x6a>
  len = path - s;
    8000439c:	40b48633          	sub	a2,s1,a1
    800043a0:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800043a4:	094cd463          	bge	s9,s4,8000442c <namex+0x130>
    memmove(name, s, DIRSIZ);
    800043a8:	4639                	li	a2,14
    800043aa:	8556                	mv	a0,s5
    800043ac:	ffffd097          	auipc	ra,0xffffd
    800043b0:	d88080e7          	jalr	-632(ra) # 80001134 <memmove>
  while(*path == '/')
    800043b4:	0004c783          	lbu	a5,0(s1)
    800043b8:	01279763          	bne	a5,s2,800043c6 <namex+0xca>
    path++;
    800043bc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043be:	0004c783          	lbu	a5,0(s1)
    800043c2:	ff278de3          	beq	a5,s2,800043bc <namex+0xc0>
    ilock(ip);
    800043c6:	854e                	mv	a0,s3
    800043c8:	00000097          	auipc	ra,0x0
    800043cc:	9cc080e7          	jalr	-1588(ra) # 80003d94 <ilock>
    if(ip->type != T_DIR){
    800043d0:	05c99783          	lh	a5,92(s3)
    800043d4:	f98793e3          	bne	a5,s8,8000435a <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800043d8:	000b0563          	beqz	s6,800043e2 <namex+0xe6>
    800043dc:	0004c783          	lbu	a5,0(s1)
    800043e0:	d3cd                	beqz	a5,80004382 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800043e2:	865e                	mv	a2,s7
    800043e4:	85d6                	mv	a1,s5
    800043e6:	854e                	mv	a0,s3
    800043e8:	00000097          	auipc	ra,0x0
    800043ec:	e64080e7          	jalr	-412(ra) # 8000424c <dirlookup>
    800043f0:	8a2a                	mv	s4,a0
    800043f2:	dd51                	beqz	a0,8000438e <namex+0x92>
    iunlockput(ip);
    800043f4:	854e                	mv	a0,s3
    800043f6:	00000097          	auipc	ra,0x0
    800043fa:	bdc080e7          	jalr	-1060(ra) # 80003fd2 <iunlockput>
    ip = next;
    800043fe:	89d2                	mv	s3,s4
  while(*path == '/')
    80004400:	0004c783          	lbu	a5,0(s1)
    80004404:	05279763          	bne	a5,s2,80004452 <namex+0x156>
    path++;
    80004408:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000440a:	0004c783          	lbu	a5,0(s1)
    8000440e:	ff278de3          	beq	a5,s2,80004408 <namex+0x10c>
  if(*path == 0)
    80004412:	c79d                	beqz	a5,80004440 <namex+0x144>
    path++;
    80004414:	85a6                	mv	a1,s1
  len = path - s;
    80004416:	8a5e                	mv	s4,s7
    80004418:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000441a:	01278963          	beq	a5,s2,8000442c <namex+0x130>
    8000441e:	dfbd                	beqz	a5,8000439c <namex+0xa0>
    path++;
    80004420:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004422:	0004c783          	lbu	a5,0(s1)
    80004426:	ff279ce3          	bne	a5,s2,8000441e <namex+0x122>
    8000442a:	bf8d                	j	8000439c <namex+0xa0>
    memmove(name, s, len);
    8000442c:	2601                	sext.w	a2,a2
    8000442e:	8556                	mv	a0,s5
    80004430:	ffffd097          	auipc	ra,0xffffd
    80004434:	d04080e7          	jalr	-764(ra) # 80001134 <memmove>
    name[len] = 0;
    80004438:	9a56                	add	s4,s4,s5
    8000443a:	000a0023          	sb	zero,0(s4)
    8000443e:	bf9d                	j	800043b4 <namex+0xb8>
  if(nameiparent){
    80004440:	f20b03e3          	beqz	s6,80004366 <namex+0x6a>
    iput(ip);
    80004444:	854e                	mv	a0,s3
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	a5c080e7          	jalr	-1444(ra) # 80003ea2 <iput>
    return 0;
    8000444e:	4981                	li	s3,0
    80004450:	bf19                	j	80004366 <namex+0x6a>
  if(*path == 0)
    80004452:	d7fd                	beqz	a5,80004440 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004454:	0004c783          	lbu	a5,0(s1)
    80004458:	85a6                	mv	a1,s1
    8000445a:	b7d1                	j	8000441e <namex+0x122>

000000008000445c <dirlink>:
{
    8000445c:	7139                	addi	sp,sp,-64
    8000445e:	fc06                	sd	ra,56(sp)
    80004460:	f822                	sd	s0,48(sp)
    80004462:	f426                	sd	s1,40(sp)
    80004464:	f04a                	sd	s2,32(sp)
    80004466:	ec4e                	sd	s3,24(sp)
    80004468:	e852                	sd	s4,16(sp)
    8000446a:	0080                	addi	s0,sp,64
    8000446c:	892a                	mv	s2,a0
    8000446e:	8a2e                	mv	s4,a1
    80004470:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004472:	4601                	li	a2,0
    80004474:	00000097          	auipc	ra,0x0
    80004478:	dd8080e7          	jalr	-552(ra) # 8000424c <dirlookup>
    8000447c:	e93d                	bnez	a0,800044f2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000447e:	06492483          	lw	s1,100(s2)
    80004482:	c49d                	beqz	s1,800044b0 <dirlink+0x54>
    80004484:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004486:	4741                	li	a4,16
    80004488:	86a6                	mv	a3,s1
    8000448a:	fc040613          	addi	a2,s0,-64
    8000448e:	4581                	li	a1,0
    80004490:	854a                	mv	a0,s2
    80004492:	00000097          	auipc	ra,0x0
    80004496:	b92080e7          	jalr	-1134(ra) # 80004024 <readi>
    8000449a:	47c1                	li	a5,16
    8000449c:	06f51163          	bne	a0,a5,800044fe <dirlink+0xa2>
    if(de.inum == 0)
    800044a0:	fc045783          	lhu	a5,-64(s0)
    800044a4:	c791                	beqz	a5,800044b0 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044a6:	24c1                	addiw	s1,s1,16
    800044a8:	06492783          	lw	a5,100(s2)
    800044ac:	fcf4ede3          	bltu	s1,a5,80004486 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800044b0:	4639                	li	a2,14
    800044b2:	85d2                	mv	a1,s4
    800044b4:	fc240513          	addi	a0,s0,-62
    800044b8:	ffffd097          	auipc	ra,0xffffd
    800044bc:	d34080e7          	jalr	-716(ra) # 800011ec <strncpy>
  de.inum = inum;
    800044c0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044c4:	4741                	li	a4,16
    800044c6:	86a6                	mv	a3,s1
    800044c8:	fc040613          	addi	a2,s0,-64
    800044cc:	4581                	li	a1,0
    800044ce:	854a                	mv	a0,s2
    800044d0:	00000097          	auipc	ra,0x0
    800044d4:	c48080e7          	jalr	-952(ra) # 80004118 <writei>
    800044d8:	872a                	mv	a4,a0
    800044da:	47c1                	li	a5,16
  return 0;
    800044dc:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044de:	02f71863          	bne	a4,a5,8000450e <dirlink+0xb2>
}
    800044e2:	70e2                	ld	ra,56(sp)
    800044e4:	7442                	ld	s0,48(sp)
    800044e6:	74a2                	ld	s1,40(sp)
    800044e8:	7902                	ld	s2,32(sp)
    800044ea:	69e2                	ld	s3,24(sp)
    800044ec:	6a42                	ld	s4,16(sp)
    800044ee:	6121                	addi	sp,sp,64
    800044f0:	8082                	ret
    iput(ip);
    800044f2:	00000097          	auipc	ra,0x0
    800044f6:	9b0080e7          	jalr	-1616(ra) # 80003ea2 <iput>
    return -1;
    800044fa:	557d                	li	a0,-1
    800044fc:	b7dd                	j	800044e2 <dirlink+0x86>
      panic("dirlink read");
    800044fe:	00004517          	auipc	a0,0x4
    80004502:	66250513          	addi	a0,a0,1634 # 80008b60 <userret+0xad0>
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	250080e7          	jalr	592(ra) # 80000756 <panic>
    panic("dirlink");
    8000450e:	00004517          	auipc	a0,0x4
    80004512:	77250513          	addi	a0,a0,1906 # 80008c80 <userret+0xbf0>
    80004516:	ffffc097          	auipc	ra,0xffffc
    8000451a:	240080e7          	jalr	576(ra) # 80000756 <panic>

000000008000451e <namei>:

struct inode*
namei(char *path)
{
    8000451e:	1101                	addi	sp,sp,-32
    80004520:	ec06                	sd	ra,24(sp)
    80004522:	e822                	sd	s0,16(sp)
    80004524:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004526:	fe040613          	addi	a2,s0,-32
    8000452a:	4581                	li	a1,0
    8000452c:	00000097          	auipc	ra,0x0
    80004530:	dd0080e7          	jalr	-560(ra) # 800042fc <namex>
}
    80004534:	60e2                	ld	ra,24(sp)
    80004536:	6442                	ld	s0,16(sp)
    80004538:	6105                	addi	sp,sp,32
    8000453a:	8082                	ret

000000008000453c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000453c:	1141                	addi	sp,sp,-16
    8000453e:	e406                	sd	ra,8(sp)
    80004540:	e022                	sd	s0,0(sp)
    80004542:	0800                	addi	s0,sp,16
    80004544:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004546:	4585                	li	a1,1
    80004548:	00000097          	auipc	ra,0x0
    8000454c:	db4080e7          	jalr	-588(ra) # 800042fc <namex>
}
    80004550:	60a2                	ld	ra,8(sp)
    80004552:	6402                	ld	s0,0(sp)
    80004554:	0141                	addi	sp,sp,16
    80004556:	8082                	ret

0000000080004558 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80004558:	7179                	addi	sp,sp,-48
    8000455a:	f406                	sd	ra,40(sp)
    8000455c:	f022                	sd	s0,32(sp)
    8000455e:	ec26                	sd	s1,24(sp)
    80004560:	e84a                	sd	s2,16(sp)
    80004562:	e44e                	sd	s3,8(sp)
    80004564:	1800                	addi	s0,sp,48
  struct buf *buf = bread(dev, log[dev].start);
    80004566:	00151993          	slli	s3,a0,0x1
    8000456a:	99aa                	add	s3,s3,a0
    8000456c:	00699793          	slli	a5,s3,0x6
    80004570:	00022997          	auipc	s3,0x22
    80004574:	4a898993          	addi	s3,s3,1192 # 80026a18 <log>
    80004578:	99be                	add	s3,s3,a5
    8000457a:	0309a583          	lw	a1,48(s3)
    8000457e:	fffff097          	auipc	ra,0xfffff
    80004582:	010080e7          	jalr	16(ra) # 8000358e <bread>
    80004586:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80004588:	0449a783          	lw	a5,68(s3)
    8000458c:	d93c                	sw	a5,112(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000458e:	0449a783          	lw	a5,68(s3)
    80004592:	00f05f63          	blez	a5,800045b0 <write_head+0x58>
    80004596:	87ce                	mv	a5,s3
    80004598:	07450693          	addi	a3,a0,116
    8000459c:	4701                	li	a4,0
    8000459e:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    800045a0:	47b0                	lw	a2,72(a5)
    800045a2:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    800045a4:	2705                	addiw	a4,a4,1
    800045a6:	0791                	addi	a5,a5,4
    800045a8:	0691                	addi	a3,a3,4
    800045aa:	41f0                	lw	a2,68(a1)
    800045ac:	fec74ae3          	blt	a4,a2,800045a0 <write_head+0x48>
  }
  bwrite(buf);
    800045b0:	854a                	mv	a0,s2
    800045b2:	fffff097          	auipc	ra,0xfffff
    800045b6:	0d0080e7          	jalr	208(ra) # 80003682 <bwrite>
  brelse(buf);
    800045ba:	854a                	mv	a0,s2
    800045bc:	fffff097          	auipc	ra,0xfffff
    800045c0:	106080e7          	jalr	262(ra) # 800036c2 <brelse>
}
    800045c4:	70a2                	ld	ra,40(sp)
    800045c6:	7402                	ld	s0,32(sp)
    800045c8:	64e2                	ld	s1,24(sp)
    800045ca:	6942                	ld	s2,16(sp)
    800045cc:	69a2                	ld	s3,8(sp)
    800045ce:	6145                	addi	sp,sp,48
    800045d0:	8082                	ret

00000000800045d2 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800045d2:	00151793          	slli	a5,a0,0x1
    800045d6:	97aa                	add	a5,a5,a0
    800045d8:	079a                	slli	a5,a5,0x6
    800045da:	00022717          	auipc	a4,0x22
    800045de:	43e70713          	addi	a4,a4,1086 # 80026a18 <log>
    800045e2:	97ba                	add	a5,a5,a4
    800045e4:	43fc                	lw	a5,68(a5)
    800045e6:	0af05863          	blez	a5,80004696 <install_trans+0xc4>
{
    800045ea:	7139                	addi	sp,sp,-64
    800045ec:	fc06                	sd	ra,56(sp)
    800045ee:	f822                	sd	s0,48(sp)
    800045f0:	f426                	sd	s1,40(sp)
    800045f2:	f04a                	sd	s2,32(sp)
    800045f4:	ec4e                	sd	s3,24(sp)
    800045f6:	e852                	sd	s4,16(sp)
    800045f8:	e456                	sd	s5,8(sp)
    800045fa:	e05a                	sd	s6,0(sp)
    800045fc:	0080                	addi	s0,sp,64
    800045fe:	00151a13          	slli	s4,a0,0x1
    80004602:	9a2a                	add	s4,s4,a0
    80004604:	006a1793          	slli	a5,s4,0x6
    80004608:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000460c:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    8000460e:	00050b1b          	sext.w	s6,a0
    80004612:	8ad2                	mv	s5,s4
    80004614:	030aa583          	lw	a1,48(s5)
    80004618:	013585bb          	addw	a1,a1,s3
    8000461c:	2585                	addiw	a1,a1,1
    8000461e:	855a                	mv	a0,s6
    80004620:	fffff097          	auipc	ra,0xfffff
    80004624:	f6e080e7          	jalr	-146(ra) # 8000358e <bread>
    80004628:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    8000462a:	048a2583          	lw	a1,72(s4)
    8000462e:	855a                	mv	a0,s6
    80004630:	fffff097          	auipc	ra,0xfffff
    80004634:	f5e080e7          	jalr	-162(ra) # 8000358e <bread>
    80004638:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000463a:	40000613          	li	a2,1024
    8000463e:	07090593          	addi	a1,s2,112
    80004642:	07050513          	addi	a0,a0,112
    80004646:	ffffd097          	auipc	ra,0xffffd
    8000464a:	aee080e7          	jalr	-1298(ra) # 80001134 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000464e:	8526                	mv	a0,s1
    80004650:	fffff097          	auipc	ra,0xfffff
    80004654:	032080e7          	jalr	50(ra) # 80003682 <bwrite>
    bunpin(dbuf);
    80004658:	8526                	mv	a0,s1
    8000465a:	fffff097          	auipc	ra,0xfffff
    8000465e:	142080e7          	jalr	322(ra) # 8000379c <bunpin>
    brelse(lbuf);
    80004662:	854a                	mv	a0,s2
    80004664:	fffff097          	auipc	ra,0xfffff
    80004668:	05e080e7          	jalr	94(ra) # 800036c2 <brelse>
    brelse(dbuf);
    8000466c:	8526                	mv	a0,s1
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	054080e7          	jalr	84(ra) # 800036c2 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004676:	2985                	addiw	s3,s3,1
    80004678:	0a11                	addi	s4,s4,4
    8000467a:	044aa783          	lw	a5,68(s5)
    8000467e:	f8f9cbe3          	blt	s3,a5,80004614 <install_trans+0x42>
}
    80004682:	70e2                	ld	ra,56(sp)
    80004684:	7442                	ld	s0,48(sp)
    80004686:	74a2                	ld	s1,40(sp)
    80004688:	7902                	ld	s2,32(sp)
    8000468a:	69e2                	ld	s3,24(sp)
    8000468c:	6a42                	ld	s4,16(sp)
    8000468e:	6aa2                	ld	s5,8(sp)
    80004690:	6b02                	ld	s6,0(sp)
    80004692:	6121                	addi	sp,sp,64
    80004694:	8082                	ret
    80004696:	8082                	ret

0000000080004698 <initlog>:
{
    80004698:	7179                	addi	sp,sp,-48
    8000469a:	f406                	sd	ra,40(sp)
    8000469c:	f022                	sd	s0,32(sp)
    8000469e:	ec26                	sd	s1,24(sp)
    800046a0:	e84a                	sd	s2,16(sp)
    800046a2:	e44e                	sd	s3,8(sp)
    800046a4:	e052                	sd	s4,0(sp)
    800046a6:	1800                	addi	s0,sp,48
    800046a8:	84aa                	mv	s1,a0
    800046aa:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    800046ac:	00151713          	slli	a4,a0,0x1
    800046b0:	972a                	add	a4,a4,a0
    800046b2:	00671993          	slli	s3,a4,0x6
    800046b6:	00022917          	auipc	s2,0x22
    800046ba:	36290913          	addi	s2,s2,866 # 80026a18 <log>
    800046be:	994e                	add	s2,s2,s3
    800046c0:	00004597          	auipc	a1,0x4
    800046c4:	4b058593          	addi	a1,a1,1200 # 80008b70 <userret+0xae0>
    800046c8:	854a                	mv	a0,s2
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	454080e7          	jalr	1108(ra) # 80000b1e <initlock>
  log[dev].start = sb->logstart;
    800046d2:	014a2583          	lw	a1,20(s4)
    800046d6:	02b92823          	sw	a1,48(s2)
  log[dev].size = sb->nlog;
    800046da:	010a2783          	lw	a5,16(s4)
    800046de:	02f92a23          	sw	a5,52(s2)
  log[dev].dev = dev;
    800046e2:	04992023          	sw	s1,64(s2)
  struct buf *buf = bread(dev, log[dev].start);
    800046e6:	8526                	mv	a0,s1
    800046e8:	fffff097          	auipc	ra,0xfffff
    800046ec:	ea6080e7          	jalr	-346(ra) # 8000358e <bread>
  log[dev].lh.n = lh->n;
    800046f0:	593c                	lw	a5,112(a0)
    800046f2:	04f92223          	sw	a5,68(s2)
  for (i = 0; i < log[dev].lh.n; i++) {
    800046f6:	02f05663          	blez	a5,80004722 <initlog+0x8a>
    800046fa:	07450693          	addi	a3,a0,116
    800046fe:	00022717          	auipc	a4,0x22
    80004702:	36270713          	addi	a4,a4,866 # 80026a60 <log+0x48>
    80004706:	974e                	add	a4,a4,s3
    80004708:	37fd                	addiw	a5,a5,-1
    8000470a:	1782                	slli	a5,a5,0x20
    8000470c:	9381                	srli	a5,a5,0x20
    8000470e:	078a                	slli	a5,a5,0x2
    80004710:	07850613          	addi	a2,a0,120
    80004714:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    80004716:	4290                	lw	a2,0(a3)
    80004718:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000471a:	0691                	addi	a3,a3,4
    8000471c:	0711                	addi	a4,a4,4
    8000471e:	fef69ce3          	bne	a3,a5,80004716 <initlog+0x7e>
  brelse(buf);
    80004722:	fffff097          	auipc	ra,0xfffff
    80004726:	fa0080e7          	jalr	-96(ra) # 800036c2 <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    8000472a:	8526                	mv	a0,s1
    8000472c:	00000097          	auipc	ra,0x0
    80004730:	ea6080e7          	jalr	-346(ra) # 800045d2 <install_trans>
  log[dev].lh.n = 0;
    80004734:	00149793          	slli	a5,s1,0x1
    80004738:	97a6                	add	a5,a5,s1
    8000473a:	079a                	slli	a5,a5,0x6
    8000473c:	00022717          	auipc	a4,0x22
    80004740:	2dc70713          	addi	a4,a4,732 # 80026a18 <log>
    80004744:	97ba                	add	a5,a5,a4
    80004746:	0407a223          	sw	zero,68(a5)
  write_head(dev); // clear the log
    8000474a:	8526                	mv	a0,s1
    8000474c:	00000097          	auipc	ra,0x0
    80004750:	e0c080e7          	jalr	-500(ra) # 80004558 <write_head>
}
    80004754:	70a2                	ld	ra,40(sp)
    80004756:	7402                	ld	s0,32(sp)
    80004758:	64e2                	ld	s1,24(sp)
    8000475a:	6942                	ld	s2,16(sp)
    8000475c:	69a2                	ld	s3,8(sp)
    8000475e:	6a02                	ld	s4,0(sp)
    80004760:	6145                	addi	sp,sp,48
    80004762:	8082                	ret

0000000080004764 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    80004764:	7139                	addi	sp,sp,-64
    80004766:	fc06                	sd	ra,56(sp)
    80004768:	f822                	sd	s0,48(sp)
    8000476a:	f426                	sd	s1,40(sp)
    8000476c:	f04a                	sd	s2,32(sp)
    8000476e:	ec4e                	sd	s3,24(sp)
    80004770:	e852                	sd	s4,16(sp)
    80004772:	e456                	sd	s5,8(sp)
    80004774:	0080                	addi	s0,sp,64
    80004776:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80004778:	00151913          	slli	s2,a0,0x1
    8000477c:	992a                	add	s2,s2,a0
    8000477e:	00691793          	slli	a5,s2,0x6
    80004782:	00022917          	auipc	s2,0x22
    80004786:	29690913          	addi	s2,s2,662 # 80026a18 <log>
    8000478a:	993e                	add	s2,s2,a5
    8000478c:	854a                	mv	a0,s2
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	4fa080e7          	jalr	1274(ra) # 80000c88 <acquire>
  while(1){
    if(log[dev].committing){
    80004796:	00022997          	auipc	s3,0x22
    8000479a:	28298993          	addi	s3,s3,642 # 80026a18 <log>
    8000479e:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047a0:	4a79                	li	s4,30
    800047a2:	a039                	j	800047b0 <begin_op+0x4c>
      sleep(&log, &log[dev].lock);
    800047a4:	85ca                	mv	a1,s2
    800047a6:	854e                	mv	a0,s3
    800047a8:	ffffe097          	auipc	ra,0xffffe
    800047ac:	022080e7          	jalr	34(ra) # 800027ca <sleep>
    if(log[dev].committing){
    800047b0:	5cdc                	lw	a5,60(s1)
    800047b2:	fbed                	bnez	a5,800047a4 <begin_op+0x40>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047b4:	5c9c                	lw	a5,56(s1)
    800047b6:	0017871b          	addiw	a4,a5,1
    800047ba:	0007069b          	sext.w	a3,a4
    800047be:	0027179b          	slliw	a5,a4,0x2
    800047c2:	9fb9                	addw	a5,a5,a4
    800047c4:	0017979b          	slliw	a5,a5,0x1
    800047c8:	40f8                	lw	a4,68(s1)
    800047ca:	9fb9                	addw	a5,a5,a4
    800047cc:	00fa5963          	bge	s4,a5,800047de <begin_op+0x7a>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    800047d0:	85ca                	mv	a1,s2
    800047d2:	854e                	mv	a0,s3
    800047d4:	ffffe097          	auipc	ra,0xffffe
    800047d8:	ff6080e7          	jalr	-10(ra) # 800027ca <sleep>
    800047dc:	bfd1                	j	800047b0 <begin_op+0x4c>
    } else {
      log[dev].outstanding += 1;
    800047de:	001a9513          	slli	a0,s5,0x1
    800047e2:	9aaa                	add	s5,s5,a0
    800047e4:	0a9a                	slli	s5,s5,0x6
    800047e6:	00022797          	auipc	a5,0x22
    800047ea:	23278793          	addi	a5,a5,562 # 80026a18 <log>
    800047ee:	9abe                	add	s5,s5,a5
    800047f0:	02daac23          	sw	a3,56(s5)
      release(&log[dev].lock);
    800047f4:	854a                	mv	a0,s2
    800047f6:	ffffc097          	auipc	ra,0xffffc
    800047fa:	6de080e7          	jalr	1758(ra) # 80000ed4 <release>
      break;
    }
  }
}
    800047fe:	70e2                	ld	ra,56(sp)
    80004800:	7442                	ld	s0,48(sp)
    80004802:	74a2                	ld	s1,40(sp)
    80004804:	7902                	ld	s2,32(sp)
    80004806:	69e2                	ld	s3,24(sp)
    80004808:	6a42                	ld	s4,16(sp)
    8000480a:	6aa2                	ld	s5,8(sp)
    8000480c:	6121                	addi	sp,sp,64
    8000480e:	8082                	ret

0000000080004810 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    80004810:	715d                	addi	sp,sp,-80
    80004812:	e486                	sd	ra,72(sp)
    80004814:	e0a2                	sd	s0,64(sp)
    80004816:	fc26                	sd	s1,56(sp)
    80004818:	f84a                	sd	s2,48(sp)
    8000481a:	f44e                	sd	s3,40(sp)
    8000481c:	f052                	sd	s4,32(sp)
    8000481e:	ec56                	sd	s5,24(sp)
    80004820:	e85a                	sd	s6,16(sp)
    80004822:	e45e                	sd	s7,8(sp)
    80004824:	e062                	sd	s8,0(sp)
    80004826:	0880                	addi	s0,sp,80
    80004828:	892a                	mv	s2,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    8000482a:	00151493          	slli	s1,a0,0x1
    8000482e:	94aa                	add	s1,s1,a0
    80004830:	00649793          	slli	a5,s1,0x6
    80004834:	00022497          	auipc	s1,0x22
    80004838:	1e448493          	addi	s1,s1,484 # 80026a18 <log>
    8000483c:	94be                	add	s1,s1,a5
    8000483e:	8526                	mv	a0,s1
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	448080e7          	jalr	1096(ra) # 80000c88 <acquire>
  log[dev].outstanding -= 1;
    80004848:	5c9c                	lw	a5,56(s1)
    8000484a:	37fd                	addiw	a5,a5,-1
    8000484c:	00078a1b          	sext.w	s4,a5
    80004850:	dc9c                	sw	a5,56(s1)
  if(log[dev].committing)
    80004852:	5cdc                	lw	a5,60(s1)
    80004854:	efad                	bnez	a5,800048ce <end_op+0xbe>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004856:	080a1463          	bnez	s4,800048de <end_op+0xce>
    do_commit = 1;
    log[dev].committing = 1;
    8000485a:	00191793          	slli	a5,s2,0x1
    8000485e:	97ca                	add	a5,a5,s2
    80004860:	079a                	slli	a5,a5,0x6
    80004862:	00022997          	auipc	s3,0x22
    80004866:	1b698993          	addi	s3,s3,438 # 80026a18 <log>
    8000486a:	99be                	add	s3,s3,a5
    8000486c:	4785                	li	a5,1
    8000486e:	02f9ae23          	sw	a5,60(s3)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    80004872:	8526                	mv	a0,s1
    80004874:	ffffc097          	auipc	ra,0xffffc
    80004878:	660080e7          	jalr	1632(ra) # 80000ed4 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    8000487c:	0449a783          	lw	a5,68(s3)
    80004880:	06f04d63          	bgtz	a5,800048fa <end_op+0xea>
    acquire(&log[dev].lock);
    80004884:	8526                	mv	a0,s1
    80004886:	ffffc097          	auipc	ra,0xffffc
    8000488a:	402080e7          	jalr	1026(ra) # 80000c88 <acquire>
    log[dev].committing = 0;
    8000488e:	00022517          	auipc	a0,0x22
    80004892:	18a50513          	addi	a0,a0,394 # 80026a18 <log>
    80004896:	00191793          	slli	a5,s2,0x1
    8000489a:	993e                	add	s2,s2,a5
    8000489c:	091a                	slli	s2,s2,0x6
    8000489e:	992a                	add	s2,s2,a0
    800048a0:	02092e23          	sw	zero,60(s2)
    wakeup(&log);
    800048a4:	ffffe097          	auipc	ra,0xffffe
    800048a8:	0ac080e7          	jalr	172(ra) # 80002950 <wakeup>
    release(&log[dev].lock);
    800048ac:	8526                	mv	a0,s1
    800048ae:	ffffc097          	auipc	ra,0xffffc
    800048b2:	626080e7          	jalr	1574(ra) # 80000ed4 <release>
}
    800048b6:	60a6                	ld	ra,72(sp)
    800048b8:	6406                	ld	s0,64(sp)
    800048ba:	74e2                	ld	s1,56(sp)
    800048bc:	7942                	ld	s2,48(sp)
    800048be:	79a2                	ld	s3,40(sp)
    800048c0:	7a02                	ld	s4,32(sp)
    800048c2:	6ae2                	ld	s5,24(sp)
    800048c4:	6b42                	ld	s6,16(sp)
    800048c6:	6ba2                	ld	s7,8(sp)
    800048c8:	6c02                	ld	s8,0(sp)
    800048ca:	6161                	addi	sp,sp,80
    800048cc:	8082                	ret
    panic("log[dev].committing");
    800048ce:	00004517          	auipc	a0,0x4
    800048d2:	2aa50513          	addi	a0,a0,682 # 80008b78 <userret+0xae8>
    800048d6:	ffffc097          	auipc	ra,0xffffc
    800048da:	e80080e7          	jalr	-384(ra) # 80000756 <panic>
    wakeup(&log);
    800048de:	00022517          	auipc	a0,0x22
    800048e2:	13a50513          	addi	a0,a0,314 # 80026a18 <log>
    800048e6:	ffffe097          	auipc	ra,0xffffe
    800048ea:	06a080e7          	jalr	106(ra) # 80002950 <wakeup>
  release(&log[dev].lock);
    800048ee:	8526                	mv	a0,s1
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	5e4080e7          	jalr	1508(ra) # 80000ed4 <release>
  if(do_commit){
    800048f8:	bf7d                	j	800048b6 <end_op+0xa6>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800048fa:	8b26                	mv	s6,s1
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    800048fc:	00090c1b          	sext.w	s8,s2
    80004900:	00191b93          	slli	s7,s2,0x1
    80004904:	9bca                	add	s7,s7,s2
    80004906:	006b9793          	slli	a5,s7,0x6
    8000490a:	00022b97          	auipc	s7,0x22
    8000490e:	10eb8b93          	addi	s7,s7,270 # 80026a18 <log>
    80004912:	9bbe                	add	s7,s7,a5
    80004914:	030ba583          	lw	a1,48(s7)
    80004918:	014585bb          	addw	a1,a1,s4
    8000491c:	2585                	addiw	a1,a1,1
    8000491e:	8562                	mv	a0,s8
    80004920:	fffff097          	auipc	ra,0xfffff
    80004924:	c6e080e7          	jalr	-914(ra) # 8000358e <bread>
    80004928:	89aa                	mv	s3,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    8000492a:	048b2583          	lw	a1,72(s6)
    8000492e:	8562                	mv	a0,s8
    80004930:	fffff097          	auipc	ra,0xfffff
    80004934:	c5e080e7          	jalr	-930(ra) # 8000358e <bread>
    80004938:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    8000493a:	40000613          	li	a2,1024
    8000493e:	07050593          	addi	a1,a0,112
    80004942:	07098513          	addi	a0,s3,112
    80004946:	ffffc097          	auipc	ra,0xffffc
    8000494a:	7ee080e7          	jalr	2030(ra) # 80001134 <memmove>
    bwrite(to);  // write the log
    8000494e:	854e                	mv	a0,s3
    80004950:	fffff097          	auipc	ra,0xfffff
    80004954:	d32080e7          	jalr	-718(ra) # 80003682 <bwrite>
    brelse(from);
    80004958:	8556                	mv	a0,s5
    8000495a:	fffff097          	auipc	ra,0xfffff
    8000495e:	d68080e7          	jalr	-664(ra) # 800036c2 <brelse>
    brelse(to);
    80004962:	854e                	mv	a0,s3
    80004964:	fffff097          	auipc	ra,0xfffff
    80004968:	d5e080e7          	jalr	-674(ra) # 800036c2 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000496c:	2a05                	addiw	s4,s4,1
    8000496e:	0b11                	addi	s6,s6,4
    80004970:	044ba783          	lw	a5,68(s7)
    80004974:	fafa40e3          	blt	s4,a5,80004914 <end_op+0x104>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    80004978:	854a                	mv	a0,s2
    8000497a:	00000097          	auipc	ra,0x0
    8000497e:	bde080e7          	jalr	-1058(ra) # 80004558 <write_head>
    install_trans(dev); // Now install writes to home locations
    80004982:	854a                	mv	a0,s2
    80004984:	00000097          	auipc	ra,0x0
    80004988:	c4e080e7          	jalr	-946(ra) # 800045d2 <install_trans>
    log[dev].lh.n = 0;
    8000498c:	00191793          	slli	a5,s2,0x1
    80004990:	97ca                	add	a5,a5,s2
    80004992:	079a                	slli	a5,a5,0x6
    80004994:	00022717          	auipc	a4,0x22
    80004998:	08470713          	addi	a4,a4,132 # 80026a18 <log>
    8000499c:	97ba                	add	a5,a5,a4
    8000499e:	0407a223          	sw	zero,68(a5)
    write_head(dev);    // Erase the transaction from the log
    800049a2:	854a                	mv	a0,s2
    800049a4:	00000097          	auipc	ra,0x0
    800049a8:	bb4080e7          	jalr	-1100(ra) # 80004558 <write_head>
    800049ac:	bde1                	j	80004884 <end_op+0x74>

00000000800049ae <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800049ae:	7179                	addi	sp,sp,-48
    800049b0:	f406                	sd	ra,40(sp)
    800049b2:	f022                	sd	s0,32(sp)
    800049b4:	ec26                	sd	s1,24(sp)
    800049b6:	e84a                	sd	s2,16(sp)
    800049b8:	e44e                	sd	s3,8(sp)
    800049ba:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    800049bc:	4504                	lw	s1,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    800049be:	00149793          	slli	a5,s1,0x1
    800049c2:	97a6                	add	a5,a5,s1
    800049c4:	079a                	slli	a5,a5,0x6
    800049c6:	00022717          	auipc	a4,0x22
    800049ca:	05270713          	addi	a4,a4,82 # 80026a18 <log>
    800049ce:	97ba                	add	a5,a5,a4
    800049d0:	43f4                	lw	a3,68(a5)
    800049d2:	47f5                	li	a5,29
    800049d4:	0ad7c863          	blt	a5,a3,80004a84 <log_write+0xd6>
    800049d8:	89aa                	mv	s3,a0
    800049da:	00149793          	slli	a5,s1,0x1
    800049de:	97a6                	add	a5,a5,s1
    800049e0:	079a                	slli	a5,a5,0x6
    800049e2:	97ba                	add	a5,a5,a4
    800049e4:	5bdc                	lw	a5,52(a5)
    800049e6:	37fd                	addiw	a5,a5,-1
    800049e8:	08f6de63          	bge	a3,a5,80004a84 <log_write+0xd6>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    800049ec:	00149793          	slli	a5,s1,0x1
    800049f0:	97a6                	add	a5,a5,s1
    800049f2:	079a                	slli	a5,a5,0x6
    800049f4:	00022717          	auipc	a4,0x22
    800049f8:	02470713          	addi	a4,a4,36 # 80026a18 <log>
    800049fc:	97ba                	add	a5,a5,a4
    800049fe:	5f9c                	lw	a5,56(a5)
    80004a00:	08f05a63          	blez	a5,80004a94 <log_write+0xe6>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004a04:	00149913          	slli	s2,s1,0x1
    80004a08:	9926                	add	s2,s2,s1
    80004a0a:	00691793          	slli	a5,s2,0x6
    80004a0e:	00022917          	auipc	s2,0x22
    80004a12:	00a90913          	addi	s2,s2,10 # 80026a18 <log>
    80004a16:	993e                	add	s2,s2,a5
    80004a18:	854a                	mv	a0,s2
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	26e080e7          	jalr	622(ra) # 80000c88 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004a22:	04492603          	lw	a2,68(s2)
    80004a26:	06c05f63          	blez	a2,80004aa4 <log_write+0xf6>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004a2a:	00c9a583          	lw	a1,12(s3)
    80004a2e:	874a                	mv	a4,s2
  for (i = 0; i < log[dev].lh.n; i++) {
    80004a30:	4781                	li	a5,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004a32:	4734                	lw	a3,72(a4)
    80004a34:	06b68963          	beq	a3,a1,80004aa6 <log_write+0xf8>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004a38:	2785                	addiw	a5,a5,1
    80004a3a:	0711                	addi	a4,a4,4
    80004a3c:	fec79be3          	bne	a5,a2,80004a32 <log_write+0x84>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004a40:	00149793          	slli	a5,s1,0x1
    80004a44:	97a6                	add	a5,a5,s1
    80004a46:	0792                	slli	a5,a5,0x4
    80004a48:	97b2                	add	a5,a5,a2
    80004a4a:	07c1                	addi	a5,a5,16
    80004a4c:	078a                	slli	a5,a5,0x2
    80004a4e:	00022717          	auipc	a4,0x22
    80004a52:	fca70713          	addi	a4,a4,-54 # 80026a18 <log>
    80004a56:	97ba                	add	a5,a5,a4
    80004a58:	00c9a703          	lw	a4,12(s3)
    80004a5c:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    80004a5e:	854e                	mv	a0,s3
    80004a60:	fffff097          	auipc	ra,0xfffff
    80004a64:	d00080e7          	jalr	-768(ra) # 80003760 <bpin>
    log[dev].lh.n++;
    80004a68:	00022697          	auipc	a3,0x22
    80004a6c:	fb068693          	addi	a3,a3,-80 # 80026a18 <log>
    80004a70:	00149793          	slli	a5,s1,0x1
    80004a74:	00978733          	add	a4,a5,s1
    80004a78:	071a                	slli	a4,a4,0x6
    80004a7a:	9736                	add	a4,a4,a3
    80004a7c:	437c                	lw	a5,68(a4)
    80004a7e:	2785                	addiw	a5,a5,1
    80004a80:	c37c                	sw	a5,68(a4)
    80004a82:	a099                	j	80004ac8 <log_write+0x11a>
    panic("too big a transaction");
    80004a84:	00004517          	auipc	a0,0x4
    80004a88:	10c50513          	addi	a0,a0,268 # 80008b90 <userret+0xb00>
    80004a8c:	ffffc097          	auipc	ra,0xffffc
    80004a90:	cca080e7          	jalr	-822(ra) # 80000756 <panic>
    panic("log_write outside of trans");
    80004a94:	00004517          	auipc	a0,0x4
    80004a98:	11450513          	addi	a0,a0,276 # 80008ba8 <userret+0xb18>
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	cba080e7          	jalr	-838(ra) # 80000756 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004aa4:	4781                	li	a5,0
  log[dev].lh.block[i] = b->blockno;
    80004aa6:	00149713          	slli	a4,s1,0x1
    80004aaa:	9726                	add	a4,a4,s1
    80004aac:	0712                	slli	a4,a4,0x4
    80004aae:	973e                	add	a4,a4,a5
    80004ab0:	0741                	addi	a4,a4,16
    80004ab2:	070a                	slli	a4,a4,0x2
    80004ab4:	00022697          	auipc	a3,0x22
    80004ab8:	f6468693          	addi	a3,a3,-156 # 80026a18 <log>
    80004abc:	9736                	add	a4,a4,a3
    80004abe:	00c9a683          	lw	a3,12(s3)
    80004ac2:	c714                	sw	a3,8(a4)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004ac4:	f8f60de3          	beq	a2,a5,80004a5e <log_write+0xb0>
  }
  release(&log[dev].lock);
    80004ac8:	854a                	mv	a0,s2
    80004aca:	ffffc097          	auipc	ra,0xffffc
    80004ace:	40a080e7          	jalr	1034(ra) # 80000ed4 <release>
}
    80004ad2:	70a2                	ld	ra,40(sp)
    80004ad4:	7402                	ld	s0,32(sp)
    80004ad6:	64e2                	ld	s1,24(sp)
    80004ad8:	6942                	ld	s2,16(sp)
    80004ada:	69a2                	ld	s3,8(sp)
    80004adc:	6145                	addi	sp,sp,48
    80004ade:	8082                	ret

0000000080004ae0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004ae0:	1101                	addi	sp,sp,-32
    80004ae2:	ec06                	sd	ra,24(sp)
    80004ae4:	e822                	sd	s0,16(sp)
    80004ae6:	e426                	sd	s1,8(sp)
    80004ae8:	e04a                	sd	s2,0(sp)
    80004aea:	1000                	addi	s0,sp,32
    80004aec:	84aa                	mv	s1,a0
    80004aee:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004af0:	00004597          	auipc	a1,0x4
    80004af4:	0d858593          	addi	a1,a1,216 # 80008bc8 <userret+0xb38>
    80004af8:	0521                	addi	a0,a0,8
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	024080e7          	jalr	36(ra) # 80000b1e <initlock>
  lk->name = name;
    80004b02:	0324bc23          	sd	s2,56(s1)
  lk->locked = 0;
    80004b06:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b0a:	0404a023          	sw	zero,64(s1)
}
    80004b0e:	60e2                	ld	ra,24(sp)
    80004b10:	6442                	ld	s0,16(sp)
    80004b12:	64a2                	ld	s1,8(sp)
    80004b14:	6902                	ld	s2,0(sp)
    80004b16:	6105                	addi	sp,sp,32
    80004b18:	8082                	ret

0000000080004b1a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b1a:	1101                	addi	sp,sp,-32
    80004b1c:	ec06                	sd	ra,24(sp)
    80004b1e:	e822                	sd	s0,16(sp)
    80004b20:	e426                	sd	s1,8(sp)
    80004b22:	e04a                	sd	s2,0(sp)
    80004b24:	1000                	addi	s0,sp,32
    80004b26:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b28:	00850913          	addi	s2,a0,8
    80004b2c:	854a                	mv	a0,s2
    80004b2e:	ffffc097          	auipc	ra,0xffffc
    80004b32:	15a080e7          	jalr	346(ra) # 80000c88 <acquire>
  while (lk->locked) {
    80004b36:	409c                	lw	a5,0(s1)
    80004b38:	cb89                	beqz	a5,80004b4a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b3a:	85ca                	mv	a1,s2
    80004b3c:	8526                	mv	a0,s1
    80004b3e:	ffffe097          	auipc	ra,0xffffe
    80004b42:	c8c080e7          	jalr	-884(ra) # 800027ca <sleep>
  while (lk->locked) {
    80004b46:	409c                	lw	a5,0(s1)
    80004b48:	fbed                	bnez	a5,80004b3a <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004b4a:	4785                	li	a5,1
    80004b4c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b4e:	ffffd097          	auipc	ra,0xffffd
    80004b52:	44e080e7          	jalr	1102(ra) # 80001f9c <myproc>
    80004b56:	493c                	lw	a5,80(a0)
    80004b58:	c0bc                	sw	a5,64(s1)
  release(&lk->lk);
    80004b5a:	854a                	mv	a0,s2
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	378080e7          	jalr	888(ra) # 80000ed4 <release>
}
    80004b64:	60e2                	ld	ra,24(sp)
    80004b66:	6442                	ld	s0,16(sp)
    80004b68:	64a2                	ld	s1,8(sp)
    80004b6a:	6902                	ld	s2,0(sp)
    80004b6c:	6105                	addi	sp,sp,32
    80004b6e:	8082                	ret

0000000080004b70 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004b70:	1101                	addi	sp,sp,-32
    80004b72:	ec06                	sd	ra,24(sp)
    80004b74:	e822                	sd	s0,16(sp)
    80004b76:	e426                	sd	s1,8(sp)
    80004b78:	e04a                	sd	s2,0(sp)
    80004b7a:	1000                	addi	s0,sp,32
    80004b7c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b7e:	00850913          	addi	s2,a0,8
    80004b82:	854a                	mv	a0,s2
    80004b84:	ffffc097          	auipc	ra,0xffffc
    80004b88:	104080e7          	jalr	260(ra) # 80000c88 <acquire>
  lk->locked = 0;
    80004b8c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b90:	0404a023          	sw	zero,64(s1)
  wakeup(lk);
    80004b94:	8526                	mv	a0,s1
    80004b96:	ffffe097          	auipc	ra,0xffffe
    80004b9a:	dba080e7          	jalr	-582(ra) # 80002950 <wakeup>
  release(&lk->lk);
    80004b9e:	854a                	mv	a0,s2
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	334080e7          	jalr	820(ra) # 80000ed4 <release>
}
    80004ba8:	60e2                	ld	ra,24(sp)
    80004baa:	6442                	ld	s0,16(sp)
    80004bac:	64a2                	ld	s1,8(sp)
    80004bae:	6902                	ld	s2,0(sp)
    80004bb0:	6105                	addi	sp,sp,32
    80004bb2:	8082                	ret

0000000080004bb4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004bb4:	7179                	addi	sp,sp,-48
    80004bb6:	f406                	sd	ra,40(sp)
    80004bb8:	f022                	sd	s0,32(sp)
    80004bba:	ec26                	sd	s1,24(sp)
    80004bbc:	e84a                	sd	s2,16(sp)
    80004bbe:	e44e                	sd	s3,8(sp)
    80004bc0:	1800                	addi	s0,sp,48
    80004bc2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004bc4:	00850913          	addi	s2,a0,8
    80004bc8:	854a                	mv	a0,s2
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	0be080e7          	jalr	190(ra) # 80000c88 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004bd2:	409c                	lw	a5,0(s1)
    80004bd4:	ef99                	bnez	a5,80004bf2 <holdingsleep+0x3e>
    80004bd6:	4481                	li	s1,0
  release(&lk->lk);
    80004bd8:	854a                	mv	a0,s2
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	2fa080e7          	jalr	762(ra) # 80000ed4 <release>
  return r;
}
    80004be2:	8526                	mv	a0,s1
    80004be4:	70a2                	ld	ra,40(sp)
    80004be6:	7402                	ld	s0,32(sp)
    80004be8:	64e2                	ld	s1,24(sp)
    80004bea:	6942                	ld	s2,16(sp)
    80004bec:	69a2                	ld	s3,8(sp)
    80004bee:	6145                	addi	sp,sp,48
    80004bf0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004bf2:	0404a983          	lw	s3,64(s1)
    80004bf6:	ffffd097          	auipc	ra,0xffffd
    80004bfa:	3a6080e7          	jalr	934(ra) # 80001f9c <myproc>
    80004bfe:	4924                	lw	s1,80(a0)
    80004c00:	413484b3          	sub	s1,s1,s3
    80004c04:	0014b493          	seqz	s1,s1
    80004c08:	bfc1                	j	80004bd8 <holdingsleep+0x24>

0000000080004c0a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c0a:	1141                	addi	sp,sp,-16
    80004c0c:	e406                	sd	ra,8(sp)
    80004c0e:	e022                	sd	s0,0(sp)
    80004c10:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c12:	00004597          	auipc	a1,0x4
    80004c16:	fc658593          	addi	a1,a1,-58 # 80008bd8 <userret+0xb48>
    80004c1a:	00022517          	auipc	a0,0x22
    80004c1e:	01e50513          	addi	a0,a0,30 # 80026c38 <ftable>
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	efc080e7          	jalr	-260(ra) # 80000b1e <initlock>
}
    80004c2a:	60a2                	ld	ra,8(sp)
    80004c2c:	6402                	ld	s0,0(sp)
    80004c2e:	0141                	addi	sp,sp,16
    80004c30:	8082                	ret

0000000080004c32 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c32:	1101                	addi	sp,sp,-32
    80004c34:	ec06                	sd	ra,24(sp)
    80004c36:	e822                	sd	s0,16(sp)
    80004c38:	e426                	sd	s1,8(sp)
    80004c3a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c3c:	00022517          	auipc	a0,0x22
    80004c40:	ffc50513          	addi	a0,a0,-4 # 80026c38 <ftable>
    80004c44:	ffffc097          	auipc	ra,0xffffc
    80004c48:	044080e7          	jalr	68(ra) # 80000c88 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c4c:	00022497          	auipc	s1,0x22
    80004c50:	01c48493          	addi	s1,s1,28 # 80026c68 <ftable+0x30>
    80004c54:	00023717          	auipc	a4,0x23
    80004c58:	fb470713          	addi	a4,a4,-76 # 80027c08 <ftable+0xfd0>
    if(f->ref == 0){
    80004c5c:	40dc                	lw	a5,4(s1)
    80004c5e:	cf99                	beqz	a5,80004c7c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c60:	02848493          	addi	s1,s1,40
    80004c64:	fee49ce3          	bne	s1,a4,80004c5c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004c68:	00022517          	auipc	a0,0x22
    80004c6c:	fd050513          	addi	a0,a0,-48 # 80026c38 <ftable>
    80004c70:	ffffc097          	auipc	ra,0xffffc
    80004c74:	264080e7          	jalr	612(ra) # 80000ed4 <release>
  return 0;
    80004c78:	4481                	li	s1,0
    80004c7a:	a819                	j	80004c90 <filealloc+0x5e>
      f->ref = 1;
    80004c7c:	4785                	li	a5,1
    80004c7e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004c80:	00022517          	auipc	a0,0x22
    80004c84:	fb850513          	addi	a0,a0,-72 # 80026c38 <ftable>
    80004c88:	ffffc097          	auipc	ra,0xffffc
    80004c8c:	24c080e7          	jalr	588(ra) # 80000ed4 <release>
}
    80004c90:	8526                	mv	a0,s1
    80004c92:	60e2                	ld	ra,24(sp)
    80004c94:	6442                	ld	s0,16(sp)
    80004c96:	64a2                	ld	s1,8(sp)
    80004c98:	6105                	addi	sp,sp,32
    80004c9a:	8082                	ret

0000000080004c9c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c9c:	1101                	addi	sp,sp,-32
    80004c9e:	ec06                	sd	ra,24(sp)
    80004ca0:	e822                	sd	s0,16(sp)
    80004ca2:	e426                	sd	s1,8(sp)
    80004ca4:	1000                	addi	s0,sp,32
    80004ca6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ca8:	00022517          	auipc	a0,0x22
    80004cac:	f9050513          	addi	a0,a0,-112 # 80026c38 <ftable>
    80004cb0:	ffffc097          	auipc	ra,0xffffc
    80004cb4:	fd8080e7          	jalr	-40(ra) # 80000c88 <acquire>
  if(f->ref < 1)
    80004cb8:	40dc                	lw	a5,4(s1)
    80004cba:	02f05263          	blez	a5,80004cde <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004cbe:	2785                	addiw	a5,a5,1
    80004cc0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004cc2:	00022517          	auipc	a0,0x22
    80004cc6:	f7650513          	addi	a0,a0,-138 # 80026c38 <ftable>
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	20a080e7          	jalr	522(ra) # 80000ed4 <release>
  return f;
}
    80004cd2:	8526                	mv	a0,s1
    80004cd4:	60e2                	ld	ra,24(sp)
    80004cd6:	6442                	ld	s0,16(sp)
    80004cd8:	64a2                	ld	s1,8(sp)
    80004cda:	6105                	addi	sp,sp,32
    80004cdc:	8082                	ret
    panic("filedup");
    80004cde:	00004517          	auipc	a0,0x4
    80004ce2:	f0250513          	addi	a0,a0,-254 # 80008be0 <userret+0xb50>
    80004ce6:	ffffc097          	auipc	ra,0xffffc
    80004cea:	a70080e7          	jalr	-1424(ra) # 80000756 <panic>

0000000080004cee <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004cee:	7139                	addi	sp,sp,-64
    80004cf0:	fc06                	sd	ra,56(sp)
    80004cf2:	f822                	sd	s0,48(sp)
    80004cf4:	f426                	sd	s1,40(sp)
    80004cf6:	f04a                	sd	s2,32(sp)
    80004cf8:	ec4e                	sd	s3,24(sp)
    80004cfa:	e852                	sd	s4,16(sp)
    80004cfc:	e456                	sd	s5,8(sp)
    80004cfe:	0080                	addi	s0,sp,64
    80004d00:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d02:	00022517          	auipc	a0,0x22
    80004d06:	f3650513          	addi	a0,a0,-202 # 80026c38 <ftable>
    80004d0a:	ffffc097          	auipc	ra,0xffffc
    80004d0e:	f7e080e7          	jalr	-130(ra) # 80000c88 <acquire>
  if(f->ref < 1)
    80004d12:	40dc                	lw	a5,4(s1)
    80004d14:	06f05563          	blez	a5,80004d7e <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004d18:	37fd                	addiw	a5,a5,-1
    80004d1a:	0007871b          	sext.w	a4,a5
    80004d1e:	c0dc                	sw	a5,4(s1)
    80004d20:	06e04763          	bgtz	a4,80004d8e <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d24:	0004a903          	lw	s2,0(s1)
    80004d28:	0094ca83          	lbu	s5,9(s1)
    80004d2c:	0104ba03          	ld	s4,16(s1)
    80004d30:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d34:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d38:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d3c:	00022517          	auipc	a0,0x22
    80004d40:	efc50513          	addi	a0,a0,-260 # 80026c38 <ftable>
    80004d44:	ffffc097          	auipc	ra,0xffffc
    80004d48:	190080e7          	jalr	400(ra) # 80000ed4 <release>

  if(ff.type == FD_PIPE){
    80004d4c:	4785                	li	a5,1
    80004d4e:	06f90163          	beq	s2,a5,80004db0 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004d52:	3979                	addiw	s2,s2,-2
    80004d54:	4785                	li	a5,1
    80004d56:	0527e463          	bltu	a5,s2,80004d9e <fileclose+0xb0>
    begin_op(ff.ip->dev);
    80004d5a:	0009a503          	lw	a0,0(s3)
    80004d5e:	00000097          	auipc	ra,0x0
    80004d62:	a06080e7          	jalr	-1530(ra) # 80004764 <begin_op>
    iput(ff.ip);
    80004d66:	854e                	mv	a0,s3
    80004d68:	fffff097          	auipc	ra,0xfffff
    80004d6c:	13a080e7          	jalr	314(ra) # 80003ea2 <iput>
    end_op(ff.ip->dev);
    80004d70:	0009a503          	lw	a0,0(s3)
    80004d74:	00000097          	auipc	ra,0x0
    80004d78:	a9c080e7          	jalr	-1380(ra) # 80004810 <end_op>
    80004d7c:	a00d                	j	80004d9e <fileclose+0xb0>
    panic("fileclose");
    80004d7e:	00004517          	auipc	a0,0x4
    80004d82:	e6a50513          	addi	a0,a0,-406 # 80008be8 <userret+0xb58>
    80004d86:	ffffc097          	auipc	ra,0xffffc
    80004d8a:	9d0080e7          	jalr	-1584(ra) # 80000756 <panic>
    release(&ftable.lock);
    80004d8e:	00022517          	auipc	a0,0x22
    80004d92:	eaa50513          	addi	a0,a0,-342 # 80026c38 <ftable>
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	13e080e7          	jalr	318(ra) # 80000ed4 <release>
  }
}
    80004d9e:	70e2                	ld	ra,56(sp)
    80004da0:	7442                	ld	s0,48(sp)
    80004da2:	74a2                	ld	s1,40(sp)
    80004da4:	7902                	ld	s2,32(sp)
    80004da6:	69e2                	ld	s3,24(sp)
    80004da8:	6a42                	ld	s4,16(sp)
    80004daa:	6aa2                	ld	s5,8(sp)
    80004dac:	6121                	addi	sp,sp,64
    80004dae:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004db0:	85d6                	mv	a1,s5
    80004db2:	8552                	mv	a0,s4
    80004db4:	00000097          	auipc	ra,0x0
    80004db8:	376080e7          	jalr	886(ra) # 8000512a <pipeclose>
    80004dbc:	b7cd                	j	80004d9e <fileclose+0xb0>

0000000080004dbe <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004dbe:	715d                	addi	sp,sp,-80
    80004dc0:	e486                	sd	ra,72(sp)
    80004dc2:	e0a2                	sd	s0,64(sp)
    80004dc4:	fc26                	sd	s1,56(sp)
    80004dc6:	f84a                	sd	s2,48(sp)
    80004dc8:	f44e                	sd	s3,40(sp)
    80004dca:	0880                	addi	s0,sp,80
    80004dcc:	84aa                	mv	s1,a0
    80004dce:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	1cc080e7          	jalr	460(ra) # 80001f9c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004dd8:	409c                	lw	a5,0(s1)
    80004dda:	37f9                	addiw	a5,a5,-2
    80004ddc:	4705                	li	a4,1
    80004dde:	04f76763          	bltu	a4,a5,80004e2c <filestat+0x6e>
    80004de2:	892a                	mv	s2,a0
    ilock(f->ip);
    80004de4:	6c88                	ld	a0,24(s1)
    80004de6:	fffff097          	auipc	ra,0xfffff
    80004dea:	fae080e7          	jalr	-82(ra) # 80003d94 <ilock>
    stati(f->ip, &st);
    80004dee:	fb840593          	addi	a1,s0,-72
    80004df2:	6c88                	ld	a0,24(s1)
    80004df4:	fffff097          	auipc	ra,0xfffff
    80004df8:	206080e7          	jalr	518(ra) # 80003ffa <stati>
    iunlock(f->ip);
    80004dfc:	6c88                	ld	a0,24(s1)
    80004dfe:	fffff097          	auipc	ra,0xfffff
    80004e02:	058080e7          	jalr	88(ra) # 80003e56 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e06:	46e1                	li	a3,24
    80004e08:	fb840613          	addi	a2,s0,-72
    80004e0c:	85ce                	mv	a1,s3
    80004e0e:	06893503          	ld	a0,104(s2)
    80004e12:	ffffd097          	auipc	ra,0xffffd
    80004e16:	d8c080e7          	jalr	-628(ra) # 80001b9e <copyout>
    80004e1a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004e1e:	60a6                	ld	ra,72(sp)
    80004e20:	6406                	ld	s0,64(sp)
    80004e22:	74e2                	ld	s1,56(sp)
    80004e24:	7942                	ld	s2,48(sp)
    80004e26:	79a2                	ld	s3,40(sp)
    80004e28:	6161                	addi	sp,sp,80
    80004e2a:	8082                	ret
  return -1;
    80004e2c:	557d                	li	a0,-1
    80004e2e:	bfc5                	j	80004e1e <filestat+0x60>

0000000080004e30 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e30:	7179                	addi	sp,sp,-48
    80004e32:	f406                	sd	ra,40(sp)
    80004e34:	f022                	sd	s0,32(sp)
    80004e36:	ec26                	sd	s1,24(sp)
    80004e38:	e84a                	sd	s2,16(sp)
    80004e3a:	e44e                	sd	s3,8(sp)
    80004e3c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e3e:	00854783          	lbu	a5,8(a0)
    80004e42:	c7c5                	beqz	a5,80004eea <fileread+0xba>
    80004e44:	84aa                	mv	s1,a0
    80004e46:	89ae                	mv	s3,a1
    80004e48:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e4a:	411c                	lw	a5,0(a0)
    80004e4c:	4705                	li	a4,1
    80004e4e:	04e78963          	beq	a5,a4,80004ea0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e52:	470d                	li	a4,3
    80004e54:	04e78d63          	beq	a5,a4,80004eae <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004e58:	4709                	li	a4,2
    80004e5a:	08e79063          	bne	a5,a4,80004eda <fileread+0xaa>
    ilock(f->ip);
    80004e5e:	6d08                	ld	a0,24(a0)
    80004e60:	fffff097          	auipc	ra,0xfffff
    80004e64:	f34080e7          	jalr	-204(ra) # 80003d94 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004e68:	874a                	mv	a4,s2
    80004e6a:	5094                	lw	a3,32(s1)
    80004e6c:	864e                	mv	a2,s3
    80004e6e:	4585                	li	a1,1
    80004e70:	6c88                	ld	a0,24(s1)
    80004e72:	fffff097          	auipc	ra,0xfffff
    80004e76:	1b2080e7          	jalr	434(ra) # 80004024 <readi>
    80004e7a:	892a                	mv	s2,a0
    80004e7c:	00a05563          	blez	a0,80004e86 <fileread+0x56>
      f->off += r;
    80004e80:	509c                	lw	a5,32(s1)
    80004e82:	9fa9                	addw	a5,a5,a0
    80004e84:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004e86:	6c88                	ld	a0,24(s1)
    80004e88:	fffff097          	auipc	ra,0xfffff
    80004e8c:	fce080e7          	jalr	-50(ra) # 80003e56 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004e90:	854a                	mv	a0,s2
    80004e92:	70a2                	ld	ra,40(sp)
    80004e94:	7402                	ld	s0,32(sp)
    80004e96:	64e2                	ld	s1,24(sp)
    80004e98:	6942                	ld	s2,16(sp)
    80004e9a:	69a2                	ld	s3,8(sp)
    80004e9c:	6145                	addi	sp,sp,48
    80004e9e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ea0:	6908                	ld	a0,16(a0)
    80004ea2:	00000097          	auipc	ra,0x0
    80004ea6:	40c080e7          	jalr	1036(ra) # 800052ae <piperead>
    80004eaa:	892a                	mv	s2,a0
    80004eac:	b7d5                	j	80004e90 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004eae:	02451783          	lh	a5,36(a0)
    80004eb2:	03079693          	slli	a3,a5,0x30
    80004eb6:	92c1                	srli	a3,a3,0x30
    80004eb8:	4725                	li	a4,9
    80004eba:	02d76a63          	bltu	a4,a3,80004eee <fileread+0xbe>
    80004ebe:	0792                	slli	a5,a5,0x4
    80004ec0:	00022717          	auipc	a4,0x22
    80004ec4:	cd870713          	addi	a4,a4,-808 # 80026b98 <devsw>
    80004ec8:	97ba                	add	a5,a5,a4
    80004eca:	639c                	ld	a5,0(a5)
    80004ecc:	c39d                	beqz	a5,80004ef2 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004ece:	86b2                	mv	a3,a2
    80004ed0:	862e                	mv	a2,a1
    80004ed2:	4585                	li	a1,1
    80004ed4:	9782                	jalr	a5
    80004ed6:	892a                	mv	s2,a0
    80004ed8:	bf65                	j	80004e90 <fileread+0x60>
    panic("fileread");
    80004eda:	00004517          	auipc	a0,0x4
    80004ede:	d1e50513          	addi	a0,a0,-738 # 80008bf8 <userret+0xb68>
    80004ee2:	ffffc097          	auipc	ra,0xffffc
    80004ee6:	874080e7          	jalr	-1932(ra) # 80000756 <panic>
    return -1;
    80004eea:	597d                	li	s2,-1
    80004eec:	b755                	j	80004e90 <fileread+0x60>
      return -1;
    80004eee:	597d                	li	s2,-1
    80004ef0:	b745                	j	80004e90 <fileread+0x60>
    80004ef2:	597d                	li	s2,-1
    80004ef4:	bf71                	j	80004e90 <fileread+0x60>

0000000080004ef6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004ef6:	00954783          	lbu	a5,9(a0)
    80004efa:	14078663          	beqz	a5,80005046 <filewrite+0x150>
{
    80004efe:	715d                	addi	sp,sp,-80
    80004f00:	e486                	sd	ra,72(sp)
    80004f02:	e0a2                	sd	s0,64(sp)
    80004f04:	fc26                	sd	s1,56(sp)
    80004f06:	f84a                	sd	s2,48(sp)
    80004f08:	f44e                	sd	s3,40(sp)
    80004f0a:	f052                	sd	s4,32(sp)
    80004f0c:	ec56                	sd	s5,24(sp)
    80004f0e:	e85a                	sd	s6,16(sp)
    80004f10:	e45e                	sd	s7,8(sp)
    80004f12:	e062                	sd	s8,0(sp)
    80004f14:	0880                	addi	s0,sp,80
    80004f16:	84aa                	mv	s1,a0
    80004f18:	8aae                	mv	s5,a1
    80004f1a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f1c:	411c                	lw	a5,0(a0)
    80004f1e:	4705                	li	a4,1
    80004f20:	02e78263          	beq	a5,a4,80004f44 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f24:	470d                	li	a4,3
    80004f26:	02e78563          	beq	a5,a4,80004f50 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004f2a:	4709                	li	a4,2
    80004f2c:	10e79563          	bne	a5,a4,80005036 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f30:	0ec05f63          	blez	a2,8000502e <filewrite+0x138>
    int i = 0;
    80004f34:	4981                	li	s3,0
    80004f36:	6b05                	lui	s6,0x1
    80004f38:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004f3c:	6b85                	lui	s7,0x1
    80004f3e:	c00b8b9b          	addiw	s7,s7,-1024
    80004f42:	a851                	j	80004fd6 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004f44:	6908                	ld	a0,16(a0)
    80004f46:	00000097          	auipc	ra,0x0
    80004f4a:	254080e7          	jalr	596(ra) # 8000519a <pipewrite>
    80004f4e:	a865                	j	80005006 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f50:	02451783          	lh	a5,36(a0)
    80004f54:	03079693          	slli	a3,a5,0x30
    80004f58:	92c1                	srli	a3,a3,0x30
    80004f5a:	4725                	li	a4,9
    80004f5c:	0ed76763          	bltu	a4,a3,8000504a <filewrite+0x154>
    80004f60:	0792                	slli	a5,a5,0x4
    80004f62:	00022717          	auipc	a4,0x22
    80004f66:	c3670713          	addi	a4,a4,-970 # 80026b98 <devsw>
    80004f6a:	97ba                	add	a5,a5,a4
    80004f6c:	679c                	ld	a5,8(a5)
    80004f6e:	c3e5                	beqz	a5,8000504e <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004f70:	86b2                	mv	a3,a2
    80004f72:	862e                	mv	a2,a1
    80004f74:	4585                	li	a1,1
    80004f76:	9782                	jalr	a5
    80004f78:	a079                	j	80005006 <filewrite+0x110>
    80004f7a:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80004f7e:	6c9c                	ld	a5,24(s1)
    80004f80:	4388                	lw	a0,0(a5)
    80004f82:	fffff097          	auipc	ra,0xfffff
    80004f86:	7e2080e7          	jalr	2018(ra) # 80004764 <begin_op>
      ilock(f->ip);
    80004f8a:	6c88                	ld	a0,24(s1)
    80004f8c:	fffff097          	auipc	ra,0xfffff
    80004f90:	e08080e7          	jalr	-504(ra) # 80003d94 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004f94:	8762                	mv	a4,s8
    80004f96:	5094                	lw	a3,32(s1)
    80004f98:	01598633          	add	a2,s3,s5
    80004f9c:	4585                	li	a1,1
    80004f9e:	6c88                	ld	a0,24(s1)
    80004fa0:	fffff097          	auipc	ra,0xfffff
    80004fa4:	178080e7          	jalr	376(ra) # 80004118 <writei>
    80004fa8:	892a                	mv	s2,a0
    80004faa:	02a05e63          	blez	a0,80004fe6 <filewrite+0xf0>
        f->off += r;
    80004fae:	509c                	lw	a5,32(s1)
    80004fb0:	9fa9                	addw	a5,a5,a0
    80004fb2:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004fb4:	6c88                	ld	a0,24(s1)
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	ea0080e7          	jalr	-352(ra) # 80003e56 <iunlock>
      end_op(f->ip->dev);
    80004fbe:	6c9c                	ld	a5,24(s1)
    80004fc0:	4388                	lw	a0,0(a5)
    80004fc2:	00000097          	auipc	ra,0x0
    80004fc6:	84e080e7          	jalr	-1970(ra) # 80004810 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004fca:	052c1a63          	bne	s8,s2,8000501e <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80004fce:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004fd2:	0349d763          	bge	s3,s4,80005000 <filewrite+0x10a>
      int n1 = n - i;
    80004fd6:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004fda:	893e                	mv	s2,a5
    80004fdc:	2781                	sext.w	a5,a5
    80004fde:	f8fb5ee3          	bge	s6,a5,80004f7a <filewrite+0x84>
    80004fe2:	895e                	mv	s2,s7
    80004fe4:	bf59                	j	80004f7a <filewrite+0x84>
      iunlock(f->ip);
    80004fe6:	6c88                	ld	a0,24(s1)
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	e6e080e7          	jalr	-402(ra) # 80003e56 <iunlock>
      end_op(f->ip->dev);
    80004ff0:	6c9c                	ld	a5,24(s1)
    80004ff2:	4388                	lw	a0,0(a5)
    80004ff4:	00000097          	auipc	ra,0x0
    80004ff8:	81c080e7          	jalr	-2020(ra) # 80004810 <end_op>
      if(r < 0)
    80004ffc:	fc0957e3          	bgez	s2,80004fca <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80005000:	8552                	mv	a0,s4
    80005002:	033a1863          	bne	s4,s3,80005032 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005006:	60a6                	ld	ra,72(sp)
    80005008:	6406                	ld	s0,64(sp)
    8000500a:	74e2                	ld	s1,56(sp)
    8000500c:	7942                	ld	s2,48(sp)
    8000500e:	79a2                	ld	s3,40(sp)
    80005010:	7a02                	ld	s4,32(sp)
    80005012:	6ae2                	ld	s5,24(sp)
    80005014:	6b42                	ld	s6,16(sp)
    80005016:	6ba2                	ld	s7,8(sp)
    80005018:	6c02                	ld	s8,0(sp)
    8000501a:	6161                	addi	sp,sp,80
    8000501c:	8082                	ret
        panic("short filewrite");
    8000501e:	00004517          	auipc	a0,0x4
    80005022:	bea50513          	addi	a0,a0,-1046 # 80008c08 <userret+0xb78>
    80005026:	ffffb097          	auipc	ra,0xffffb
    8000502a:	730080e7          	jalr	1840(ra) # 80000756 <panic>
    int i = 0;
    8000502e:	4981                	li	s3,0
    80005030:	bfc1                	j	80005000 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    80005032:	557d                	li	a0,-1
    80005034:	bfc9                	j	80005006 <filewrite+0x110>
    panic("filewrite");
    80005036:	00004517          	auipc	a0,0x4
    8000503a:	be250513          	addi	a0,a0,-1054 # 80008c18 <userret+0xb88>
    8000503e:	ffffb097          	auipc	ra,0xffffb
    80005042:	718080e7          	jalr	1816(ra) # 80000756 <panic>
    return -1;
    80005046:	557d                	li	a0,-1
}
    80005048:	8082                	ret
      return -1;
    8000504a:	557d                	li	a0,-1
    8000504c:	bf6d                	j	80005006 <filewrite+0x110>
    8000504e:	557d                	li	a0,-1
    80005050:	bf5d                	j	80005006 <filewrite+0x110>

0000000080005052 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005052:	7179                	addi	sp,sp,-48
    80005054:	f406                	sd	ra,40(sp)
    80005056:	f022                	sd	s0,32(sp)
    80005058:	ec26                	sd	s1,24(sp)
    8000505a:	e84a                	sd	s2,16(sp)
    8000505c:	e44e                	sd	s3,8(sp)
    8000505e:	e052                	sd	s4,0(sp)
    80005060:	1800                	addi	s0,sp,48
    80005062:	84aa                	mv	s1,a0
    80005064:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005066:	0005b023          	sd	zero,0(a1)
    8000506a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000506e:	00000097          	auipc	ra,0x0
    80005072:	bc4080e7          	jalr	-1084(ra) # 80004c32 <filealloc>
    80005076:	e088                	sd	a0,0(s1)
    80005078:	c549                	beqz	a0,80005102 <pipealloc+0xb0>
    8000507a:	00000097          	auipc	ra,0x0
    8000507e:	bb8080e7          	jalr	-1096(ra) # 80004c32 <filealloc>
    80005082:	00aa3023          	sd	a0,0(s4)
    80005086:	c925                	beqz	a0,800050f6 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	a7c080e7          	jalr	-1412(ra) # 80000b04 <kalloc>
    80005090:	892a                	mv	s2,a0
    80005092:	cd39                	beqz	a0,800050f0 <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80005094:	4985                	li	s3,1
    80005096:	23352c23          	sw	s3,568(a0)
  pi->writeopen = 1;
    8000509a:	23352e23          	sw	s3,572(a0)
  pi->nwrite = 0;
    8000509e:	22052a23          	sw	zero,564(a0)
  pi->nread = 0;
    800050a2:	22052823          	sw	zero,560(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    800050a6:	03000613          	li	a2,48
    800050aa:	4581                	li	a1,0
    800050ac:	ffffc097          	auipc	ra,0xffffc
    800050b0:	028080e7          	jalr	40(ra) # 800010d4 <memset>
  (*f0)->type = FD_PIPE;
    800050b4:	609c                	ld	a5,0(s1)
    800050b6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800050ba:	609c                	ld	a5,0(s1)
    800050bc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800050c0:	609c                	ld	a5,0(s1)
    800050c2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800050c6:	609c                	ld	a5,0(s1)
    800050c8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800050cc:	000a3783          	ld	a5,0(s4)
    800050d0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800050d4:	000a3783          	ld	a5,0(s4)
    800050d8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800050dc:	000a3783          	ld	a5,0(s4)
    800050e0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800050e4:	000a3783          	ld	a5,0(s4)
    800050e8:	0127b823          	sd	s2,16(a5)
  return 0;
    800050ec:	4501                	li	a0,0
    800050ee:	a025                	j	80005116 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800050f0:	6088                	ld	a0,0(s1)
    800050f2:	e501                	bnez	a0,800050fa <pipealloc+0xa8>
    800050f4:	a039                	j	80005102 <pipealloc+0xb0>
    800050f6:	6088                	ld	a0,0(s1)
    800050f8:	c51d                	beqz	a0,80005126 <pipealloc+0xd4>
    fileclose(*f0);
    800050fa:	00000097          	auipc	ra,0x0
    800050fe:	bf4080e7          	jalr	-1036(ra) # 80004cee <fileclose>
  if(*f1)
    80005102:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005106:	557d                	li	a0,-1
  if(*f1)
    80005108:	c799                	beqz	a5,80005116 <pipealloc+0xc4>
    fileclose(*f1);
    8000510a:	853e                	mv	a0,a5
    8000510c:	00000097          	auipc	ra,0x0
    80005110:	be2080e7          	jalr	-1054(ra) # 80004cee <fileclose>
  return -1;
    80005114:	557d                	li	a0,-1
}
    80005116:	70a2                	ld	ra,40(sp)
    80005118:	7402                	ld	s0,32(sp)
    8000511a:	64e2                	ld	s1,24(sp)
    8000511c:	6942                	ld	s2,16(sp)
    8000511e:	69a2                	ld	s3,8(sp)
    80005120:	6a02                	ld	s4,0(sp)
    80005122:	6145                	addi	sp,sp,48
    80005124:	8082                	ret
  return -1;
    80005126:	557d                	li	a0,-1
    80005128:	b7fd                	j	80005116 <pipealloc+0xc4>

000000008000512a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000512a:	1101                	addi	sp,sp,-32
    8000512c:	ec06                	sd	ra,24(sp)
    8000512e:	e822                	sd	s0,16(sp)
    80005130:	e426                	sd	s1,8(sp)
    80005132:	e04a                	sd	s2,0(sp)
    80005134:	1000                	addi	s0,sp,32
    80005136:	84aa                	mv	s1,a0
    80005138:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000513a:	ffffc097          	auipc	ra,0xffffc
    8000513e:	b4e080e7          	jalr	-1202(ra) # 80000c88 <acquire>
  if(writable){
    80005142:	02090d63          	beqz	s2,8000517c <pipeclose+0x52>
    pi->writeopen = 0;
    80005146:	2204ae23          	sw	zero,572(s1)
    wakeup(&pi->nread);
    8000514a:	23048513          	addi	a0,s1,560
    8000514e:	ffffe097          	auipc	ra,0xffffe
    80005152:	802080e7          	jalr	-2046(ra) # 80002950 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005156:	2384b783          	ld	a5,568(s1)
    8000515a:	eb95                	bnez	a5,8000518e <pipeclose+0x64>
    release(&pi->lock);
    8000515c:	8526                	mv	a0,s1
    8000515e:	ffffc097          	auipc	ra,0xffffc
    80005162:	d76080e7          	jalr	-650(ra) # 80000ed4 <release>
    kfree((char*)pi);
    80005166:	8526                	mv	a0,s1
    80005168:	ffffc097          	auipc	ra,0xffffc
    8000516c:	984080e7          	jalr	-1660(ra) # 80000aec <kfree>
  } else
    release(&pi->lock);
}
    80005170:	60e2                	ld	ra,24(sp)
    80005172:	6442                	ld	s0,16(sp)
    80005174:	64a2                	ld	s1,8(sp)
    80005176:	6902                	ld	s2,0(sp)
    80005178:	6105                	addi	sp,sp,32
    8000517a:	8082                	ret
    pi->readopen = 0;
    8000517c:	2204ac23          	sw	zero,568(s1)
    wakeup(&pi->nwrite);
    80005180:	23448513          	addi	a0,s1,564
    80005184:	ffffd097          	auipc	ra,0xffffd
    80005188:	7cc080e7          	jalr	1996(ra) # 80002950 <wakeup>
    8000518c:	b7e9                	j	80005156 <pipeclose+0x2c>
    release(&pi->lock);
    8000518e:	8526                	mv	a0,s1
    80005190:	ffffc097          	auipc	ra,0xffffc
    80005194:	d44080e7          	jalr	-700(ra) # 80000ed4 <release>
}
    80005198:	bfe1                	j	80005170 <pipeclose+0x46>

000000008000519a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000519a:	7159                	addi	sp,sp,-112
    8000519c:	f486                	sd	ra,104(sp)
    8000519e:	f0a2                	sd	s0,96(sp)
    800051a0:	eca6                	sd	s1,88(sp)
    800051a2:	e8ca                	sd	s2,80(sp)
    800051a4:	e4ce                	sd	s3,72(sp)
    800051a6:	e0d2                	sd	s4,64(sp)
    800051a8:	fc56                	sd	s5,56(sp)
    800051aa:	f85a                	sd	s6,48(sp)
    800051ac:	f45e                	sd	s7,40(sp)
    800051ae:	f062                	sd	s8,32(sp)
    800051b0:	ec66                	sd	s9,24(sp)
    800051b2:	1880                	addi	s0,sp,112
    800051b4:	84aa                	mv	s1,a0
    800051b6:	8b2e                	mv	s6,a1
    800051b8:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    800051ba:	ffffd097          	auipc	ra,0xffffd
    800051be:	de2080e7          	jalr	-542(ra) # 80001f9c <myproc>
    800051c2:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    800051c4:	8526                	mv	a0,s1
    800051c6:	ffffc097          	auipc	ra,0xffffc
    800051ca:	ac2080e7          	jalr	-1342(ra) # 80000c88 <acquire>
  for(i = 0; i < n; i++){
    800051ce:	0b505063          	blez	s5,8000526e <pipewrite+0xd4>
    800051d2:	8926                	mv	s2,s1
    800051d4:	fffa8b9b          	addiw	s7,s5,-1
    800051d8:	1b82                	slli	s7,s7,0x20
    800051da:	020bdb93          	srli	s7,s7,0x20
    800051de:	001b0793          	addi	a5,s6,1
    800051e2:	9bbe                	add	s7,s7,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    800051e4:	23048a13          	addi	s4,s1,560
      sleep(&pi->nwrite, &pi->lock);
    800051e8:	23448993          	addi	s3,s1,564
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051ec:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800051ee:	2304a783          	lw	a5,560(s1)
    800051f2:	2344a703          	lw	a4,564(s1)
    800051f6:	2007879b          	addiw	a5,a5,512
    800051fa:	02f71e63          	bne	a4,a5,80005236 <pipewrite+0x9c>
      if(pi->readopen == 0 || myproc()->killed){
    800051fe:	2384a783          	lw	a5,568(s1)
    80005202:	c3d9                	beqz	a5,80005288 <pipewrite+0xee>
    80005204:	ffffd097          	auipc	ra,0xffffd
    80005208:	d98080e7          	jalr	-616(ra) # 80001f9c <myproc>
    8000520c:	453c                	lw	a5,72(a0)
    8000520e:	efad                	bnez	a5,80005288 <pipewrite+0xee>
      wakeup(&pi->nread);
    80005210:	8552                	mv	a0,s4
    80005212:	ffffd097          	auipc	ra,0xffffd
    80005216:	73e080e7          	jalr	1854(ra) # 80002950 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000521a:	85ca                	mv	a1,s2
    8000521c:	854e                	mv	a0,s3
    8000521e:	ffffd097          	auipc	ra,0xffffd
    80005222:	5ac080e7          	jalr	1452(ra) # 800027ca <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80005226:	2304a783          	lw	a5,560(s1)
    8000522a:	2344a703          	lw	a4,564(s1)
    8000522e:	2007879b          	addiw	a5,a5,512
    80005232:	fcf706e3          	beq	a4,a5,800051fe <pipewrite+0x64>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005236:	4685                	li	a3,1
    80005238:	865a                	mv	a2,s6
    8000523a:	f9f40593          	addi	a1,s0,-97
    8000523e:	068c3503          	ld	a0,104(s8)
    80005242:	ffffd097          	auipc	ra,0xffffd
    80005246:	9e8080e7          	jalr	-1560(ra) # 80001c2a <copyin>
    8000524a:	03950263          	beq	a0,s9,8000526e <pipewrite+0xd4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000524e:	2344a783          	lw	a5,564(s1)
    80005252:	0017871b          	addiw	a4,a5,1
    80005256:	22e4aa23          	sw	a4,564(s1)
    8000525a:	1ff7f793          	andi	a5,a5,511
    8000525e:	97a6                	add	a5,a5,s1
    80005260:	f9f44703          	lbu	a4,-97(s0)
    80005264:	02e78823          	sb	a4,48(a5)
  for(i = 0; i < n; i++){
    80005268:	0b05                	addi	s6,s6,1
    8000526a:	f97b12e3          	bne	s6,s7,800051ee <pipewrite+0x54>
  }
  wakeup(&pi->nread);
    8000526e:	23048513          	addi	a0,s1,560
    80005272:	ffffd097          	auipc	ra,0xffffd
    80005276:	6de080e7          	jalr	1758(ra) # 80002950 <wakeup>
  release(&pi->lock);
    8000527a:	8526                	mv	a0,s1
    8000527c:	ffffc097          	auipc	ra,0xffffc
    80005280:	c58080e7          	jalr	-936(ra) # 80000ed4 <release>
  return n;
    80005284:	8556                	mv	a0,s5
    80005286:	a039                	j	80005294 <pipewrite+0xfa>
        release(&pi->lock);
    80005288:	8526                	mv	a0,s1
    8000528a:	ffffc097          	auipc	ra,0xffffc
    8000528e:	c4a080e7          	jalr	-950(ra) # 80000ed4 <release>
        return -1;
    80005292:	557d                	li	a0,-1
}
    80005294:	70a6                	ld	ra,104(sp)
    80005296:	7406                	ld	s0,96(sp)
    80005298:	64e6                	ld	s1,88(sp)
    8000529a:	6946                	ld	s2,80(sp)
    8000529c:	69a6                	ld	s3,72(sp)
    8000529e:	6a06                	ld	s4,64(sp)
    800052a0:	7ae2                	ld	s5,56(sp)
    800052a2:	7b42                	ld	s6,48(sp)
    800052a4:	7ba2                	ld	s7,40(sp)
    800052a6:	7c02                	ld	s8,32(sp)
    800052a8:	6ce2                	ld	s9,24(sp)
    800052aa:	6165                	addi	sp,sp,112
    800052ac:	8082                	ret

00000000800052ae <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800052ae:	715d                	addi	sp,sp,-80
    800052b0:	e486                	sd	ra,72(sp)
    800052b2:	e0a2                	sd	s0,64(sp)
    800052b4:	fc26                	sd	s1,56(sp)
    800052b6:	f84a                	sd	s2,48(sp)
    800052b8:	f44e                	sd	s3,40(sp)
    800052ba:	f052                	sd	s4,32(sp)
    800052bc:	ec56                	sd	s5,24(sp)
    800052be:	e85a                	sd	s6,16(sp)
    800052c0:	0880                	addi	s0,sp,80
    800052c2:	84aa                	mv	s1,a0
    800052c4:	892e                	mv	s2,a1
    800052c6:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    800052c8:	ffffd097          	auipc	ra,0xffffd
    800052cc:	cd4080e7          	jalr	-812(ra) # 80001f9c <myproc>
    800052d0:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    800052d2:	8b26                	mv	s6,s1
    800052d4:	8526                	mv	a0,s1
    800052d6:	ffffc097          	auipc	ra,0xffffc
    800052da:	9b2080e7          	jalr	-1614(ra) # 80000c88 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052de:	2304a703          	lw	a4,560(s1)
    800052e2:	2344a783          	lw	a5,564(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052e6:	23048993          	addi	s3,s1,560
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052ea:	02f71763          	bne	a4,a5,80005318 <piperead+0x6a>
    800052ee:	23c4a783          	lw	a5,572(s1)
    800052f2:	c39d                	beqz	a5,80005318 <piperead+0x6a>
    if(myproc()->killed){
    800052f4:	ffffd097          	auipc	ra,0xffffd
    800052f8:	ca8080e7          	jalr	-856(ra) # 80001f9c <myproc>
    800052fc:	453c                	lw	a5,72(a0)
    800052fe:	ebc1                	bnez	a5,8000538e <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005300:	85da                	mv	a1,s6
    80005302:	854e                	mv	a0,s3
    80005304:	ffffd097          	auipc	ra,0xffffd
    80005308:	4c6080e7          	jalr	1222(ra) # 800027ca <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000530c:	2304a703          	lw	a4,560(s1)
    80005310:	2344a783          	lw	a5,564(s1)
    80005314:	fcf70de3          	beq	a4,a5,800052ee <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005318:	09405263          	blez	s4,8000539c <piperead+0xee>
    8000531c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000531e:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005320:	2304a783          	lw	a5,560(s1)
    80005324:	2344a703          	lw	a4,564(s1)
    80005328:	02f70d63          	beq	a4,a5,80005362 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000532c:	0017871b          	addiw	a4,a5,1
    80005330:	22e4a823          	sw	a4,560(s1)
    80005334:	1ff7f793          	andi	a5,a5,511
    80005338:	97a6                	add	a5,a5,s1
    8000533a:	0307c783          	lbu	a5,48(a5)
    8000533e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005342:	4685                	li	a3,1
    80005344:	fbf40613          	addi	a2,s0,-65
    80005348:	85ca                	mv	a1,s2
    8000534a:	068ab503          	ld	a0,104(s5)
    8000534e:	ffffd097          	auipc	ra,0xffffd
    80005352:	850080e7          	jalr	-1968(ra) # 80001b9e <copyout>
    80005356:	01650663          	beq	a0,s6,80005362 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000535a:	2985                	addiw	s3,s3,1
    8000535c:	0905                	addi	s2,s2,1
    8000535e:	fd3a11e3          	bne	s4,s3,80005320 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005362:	23448513          	addi	a0,s1,564
    80005366:	ffffd097          	auipc	ra,0xffffd
    8000536a:	5ea080e7          	jalr	1514(ra) # 80002950 <wakeup>
  release(&pi->lock);
    8000536e:	8526                	mv	a0,s1
    80005370:	ffffc097          	auipc	ra,0xffffc
    80005374:	b64080e7          	jalr	-1180(ra) # 80000ed4 <release>
  return i;
}
    80005378:	854e                	mv	a0,s3
    8000537a:	60a6                	ld	ra,72(sp)
    8000537c:	6406                	ld	s0,64(sp)
    8000537e:	74e2                	ld	s1,56(sp)
    80005380:	7942                	ld	s2,48(sp)
    80005382:	79a2                	ld	s3,40(sp)
    80005384:	7a02                	ld	s4,32(sp)
    80005386:	6ae2                	ld	s5,24(sp)
    80005388:	6b42                	ld	s6,16(sp)
    8000538a:	6161                	addi	sp,sp,80
    8000538c:	8082                	ret
      release(&pi->lock);
    8000538e:	8526                	mv	a0,s1
    80005390:	ffffc097          	auipc	ra,0xffffc
    80005394:	b44080e7          	jalr	-1212(ra) # 80000ed4 <release>
      return -1;
    80005398:	59fd                	li	s3,-1
    8000539a:	bff9                	j	80005378 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000539c:	4981                	li	s3,0
    8000539e:	b7d1                	j	80005362 <piperead+0xb4>

00000000800053a0 <exec>:



int
exec(char *path, char **argv)
{
    800053a0:	df010113          	addi	sp,sp,-528
    800053a4:	20113423          	sd	ra,520(sp)
    800053a8:	20813023          	sd	s0,512(sp)
    800053ac:	ffa6                	sd	s1,504(sp)
    800053ae:	fbca                	sd	s2,496(sp)
    800053b0:	f7ce                	sd	s3,488(sp)
    800053b2:	f3d2                	sd	s4,480(sp)
    800053b4:	efd6                	sd	s5,472(sp)
    800053b6:	ebda                	sd	s6,464(sp)
    800053b8:	e7de                	sd	s7,456(sp)
    800053ba:	e3e2                	sd	s8,448(sp)
    800053bc:	ff66                	sd	s9,440(sp)
    800053be:	fb6a                	sd	s10,432(sp)
    800053c0:	f76e                	sd	s11,424(sp)
    800053c2:	0c00                	addi	s0,sp,528
    800053c4:	84aa                	mv	s1,a0
    800053c6:	dea43c23          	sd	a0,-520(s0)
    800053ca:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800053ce:	ffffd097          	auipc	ra,0xffffd
    800053d2:	bce080e7          	jalr	-1074(ra) # 80001f9c <myproc>
    800053d6:	892a                	mv	s2,a0

  begin_op(ROOTDEV);
    800053d8:	4501                	li	a0,0
    800053da:	fffff097          	auipc	ra,0xfffff
    800053de:	38a080e7          	jalr	906(ra) # 80004764 <begin_op>

  if((ip = namei(path)) == 0){
    800053e2:	8526                	mv	a0,s1
    800053e4:	fffff097          	auipc	ra,0xfffff
    800053e8:	13a080e7          	jalr	314(ra) # 8000451e <namei>
    800053ec:	c935                	beqz	a0,80005460 <exec+0xc0>
    800053ee:	84aa                	mv	s1,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    800053f0:	fffff097          	auipc	ra,0xfffff
    800053f4:	9a4080e7          	jalr	-1628(ra) # 80003d94 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800053f8:	04000713          	li	a4,64
    800053fc:	4681                	li	a3,0
    800053fe:	e4840613          	addi	a2,s0,-440
    80005402:	4581                	li	a1,0
    80005404:	8526                	mv	a0,s1
    80005406:	fffff097          	auipc	ra,0xfffff
    8000540a:	c1e080e7          	jalr	-994(ra) # 80004024 <readi>
    8000540e:	04000793          	li	a5,64
    80005412:	00f51a63          	bne	a0,a5,80005426 <exec+0x86>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005416:	e4842703          	lw	a4,-440(s0)
    8000541a:	464c47b7          	lui	a5,0x464c4
    8000541e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005422:	04f70663          	beq	a4,a5,8000546e <exec+0xce>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005426:	8526                	mv	a0,s1
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	baa080e7          	jalr	-1110(ra) # 80003fd2 <iunlockput>
    end_op(ROOTDEV);
    80005430:	4501                	li	a0,0
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	3de080e7          	jalr	990(ra) # 80004810 <end_op>
  }
  return -1;
    8000543a:	557d                	li	a0,-1
}
    8000543c:	20813083          	ld	ra,520(sp)
    80005440:	20013403          	ld	s0,512(sp)
    80005444:	74fe                	ld	s1,504(sp)
    80005446:	795e                	ld	s2,496(sp)
    80005448:	79be                	ld	s3,488(sp)
    8000544a:	7a1e                	ld	s4,480(sp)
    8000544c:	6afe                	ld	s5,472(sp)
    8000544e:	6b5e                	ld	s6,464(sp)
    80005450:	6bbe                	ld	s7,456(sp)
    80005452:	6c1e                	ld	s8,448(sp)
    80005454:	7cfa                	ld	s9,440(sp)
    80005456:	7d5a                	ld	s10,432(sp)
    80005458:	7dba                	ld	s11,424(sp)
    8000545a:	21010113          	addi	sp,sp,528
    8000545e:	8082                	ret
    end_op(ROOTDEV);
    80005460:	4501                	li	a0,0
    80005462:	fffff097          	auipc	ra,0xfffff
    80005466:	3ae080e7          	jalr	942(ra) # 80004810 <end_op>
    return -1;
    8000546a:	557d                	li	a0,-1
    8000546c:	bfc1                	j	8000543c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000546e:	854a                	mv	a0,s2
    80005470:	ffffd097          	auipc	ra,0xffffd
    80005474:	bf0080e7          	jalr	-1040(ra) # 80002060 <proc_pagetable>
    80005478:	8c2a                	mv	s8,a0
    8000547a:	d555                	beqz	a0,80005426 <exec+0x86>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000547c:	e6842983          	lw	s3,-408(s0)
    80005480:	e8045783          	lhu	a5,-384(s0)
    80005484:	c7fd                	beqz	a5,80005572 <exec+0x1d2>
  sz = 0;
    80005486:	e0043423          	sd	zero,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000548a:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    8000548c:	6b05                	lui	s6,0x1
    8000548e:	fffb0793          	addi	a5,s6,-1 # fff <_entry-0x7ffff001>
    80005492:	def43823          	sd	a5,-528(s0)
    80005496:	a0a5                	j	800054fe <exec+0x15e>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005498:	00003517          	auipc	a0,0x3
    8000549c:	79050513          	addi	a0,a0,1936 # 80008c28 <userret+0xb98>
    800054a0:	ffffb097          	auipc	ra,0xffffb
    800054a4:	2b6080e7          	jalr	694(ra) # 80000756 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800054a8:	8756                	mv	a4,s5
    800054aa:	012d86bb          	addw	a3,s11,s2
    800054ae:	4581                	li	a1,0
    800054b0:	8526                	mv	a0,s1
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	b72080e7          	jalr	-1166(ra) # 80004024 <readi>
    800054ba:	2501                	sext.w	a0,a0
    800054bc:	10aa9263          	bne	s5,a0,800055c0 <exec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    800054c0:	6785                	lui	a5,0x1
    800054c2:	0127893b          	addw	s2,a5,s2
    800054c6:	77fd                	lui	a5,0xfffff
    800054c8:	01478a3b          	addw	s4,a5,s4
    800054cc:	03997263          	bgeu	s2,s9,800054f0 <exec+0x150>
    pa = walkaddr(pagetable, va + i);
    800054d0:	02091593          	slli	a1,s2,0x20
    800054d4:	9181                	srli	a1,a1,0x20
    800054d6:	95ea                	add	a1,a1,s10
    800054d8:	8562                	mv	a0,s8
    800054da:	ffffc097          	auipc	ra,0xffffc
    800054de:	0e2080e7          	jalr	226(ra) # 800015bc <walkaddr>
    800054e2:	862a                	mv	a2,a0
    if(pa == 0)
    800054e4:	d955                	beqz	a0,80005498 <exec+0xf8>
      n = PGSIZE;
    800054e6:	8ada                	mv	s5,s6
    if(sz - i < PGSIZE)
    800054e8:	fd6a70e3          	bgeu	s4,s6,800054a8 <exec+0x108>
      n = sz - i;
    800054ec:	8ad2                	mv	s5,s4
    800054ee:	bf6d                	j	800054a8 <exec+0x108>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054f0:	2b85                	addiw	s7,s7,1
    800054f2:	0389899b          	addiw	s3,s3,56
    800054f6:	e8045783          	lhu	a5,-384(s0)
    800054fa:	06fbde63          	bge	s7,a5,80005576 <exec+0x1d6>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054fe:	2981                	sext.w	s3,s3
    80005500:	03800713          	li	a4,56
    80005504:	86ce                	mv	a3,s3
    80005506:	e1040613          	addi	a2,s0,-496
    8000550a:	4581                	li	a1,0
    8000550c:	8526                	mv	a0,s1
    8000550e:	fffff097          	auipc	ra,0xfffff
    80005512:	b16080e7          	jalr	-1258(ra) # 80004024 <readi>
    80005516:	03800793          	li	a5,56
    8000551a:	0af51363          	bne	a0,a5,800055c0 <exec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    8000551e:	e1042783          	lw	a5,-496(s0)
    80005522:	4705                	li	a4,1
    80005524:	fce796e3          	bne	a5,a4,800054f0 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80005528:	e3843603          	ld	a2,-456(s0)
    8000552c:	e3043783          	ld	a5,-464(s0)
    80005530:	08f66863          	bltu	a2,a5,800055c0 <exec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005534:	e2043783          	ld	a5,-480(s0)
    80005538:	963e                	add	a2,a2,a5
    8000553a:	08f66363          	bltu	a2,a5,800055c0 <exec+0x220>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000553e:	e0843583          	ld	a1,-504(s0)
    80005542:	8562                	mv	a0,s8
    80005544:	ffffc097          	auipc	ra,0xffffc
    80005548:	480080e7          	jalr	1152(ra) # 800019c4 <uvmalloc>
    8000554c:	e0a43423          	sd	a0,-504(s0)
    80005550:	c925                	beqz	a0,800055c0 <exec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80005552:	e2043d03          	ld	s10,-480(s0)
    80005556:	df043783          	ld	a5,-528(s0)
    8000555a:	00fd77b3          	and	a5,s10,a5
    8000555e:	e3ad                	bnez	a5,800055c0 <exec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005560:	e1842d83          	lw	s11,-488(s0)
    80005564:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005568:	f80c84e3          	beqz	s9,800054f0 <exec+0x150>
    8000556c:	8a66                	mv	s4,s9
    8000556e:	4901                	li	s2,0
    80005570:	b785                	j	800054d0 <exec+0x130>
  sz = 0;
    80005572:	e0043423          	sd	zero,-504(s0)
  iunlockput(ip);
    80005576:	8526                	mv	a0,s1
    80005578:	fffff097          	auipc	ra,0xfffff
    8000557c:	a5a080e7          	jalr	-1446(ra) # 80003fd2 <iunlockput>
  end_op(ROOTDEV);
    80005580:	4501                	li	a0,0
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	28e080e7          	jalr	654(ra) # 80004810 <end_op>
  p = myproc();
    8000558a:	ffffd097          	auipc	ra,0xffffd
    8000558e:	a12080e7          	jalr	-1518(ra) # 80001f9c <myproc>
    80005592:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80005594:	06053d83          	ld	s11,96(a0)
  sz = PGROUNDUP(sz);
    80005598:	6585                	lui	a1,0x1
    8000559a:	15fd                	addi	a1,a1,-1
    8000559c:	e0843783          	ld	a5,-504(s0)
    800055a0:	00b78b33          	add	s6,a5,a1
    800055a4:	75fd                	lui	a1,0xfffff
    800055a6:	00bb75b3          	and	a1,s6,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800055aa:	6609                	lui	a2,0x2
    800055ac:	962e                	add	a2,a2,a1
    800055ae:	8562                	mv	a0,s8
    800055b0:	ffffc097          	auipc	ra,0xffffc
    800055b4:	414080e7          	jalr	1044(ra) # 800019c4 <uvmalloc>
    800055b8:	e0a43423          	sd	a0,-504(s0)
  ip = 0;
    800055bc:	4481                	li	s1,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800055be:	ed01                	bnez	a0,800055d6 <exec+0x236>
    proc_freepagetable(pagetable, sz);
    800055c0:	e0843583          	ld	a1,-504(s0)
    800055c4:	8562                	mv	a0,s8
    800055c6:	ffffd097          	auipc	ra,0xffffd
    800055ca:	b9e080e7          	jalr	-1122(ra) # 80002164 <proc_freepagetable>
  if(ip){
    800055ce:	e4049ce3          	bnez	s1,80005426 <exec+0x86>
  return -1;
    800055d2:	557d                	li	a0,-1
    800055d4:	b5a5                	j	8000543c <exec+0x9c>
  uvmclear(pagetable, sz-2*PGSIZE);
    800055d6:	75f9                	lui	a1,0xffffe
    800055d8:	84aa                	mv	s1,a0
    800055da:	95aa                	add	a1,a1,a0
    800055dc:	8562                	mv	a0,s8
    800055de:	ffffc097          	auipc	ra,0xffffc
    800055e2:	58e080e7          	jalr	1422(ra) # 80001b6c <uvmclear>
  stackbase = sp - PGSIZE;
    800055e6:	7bfd                	lui	s7,0xfffff
    800055e8:	9ba6                	add	s7,s7,s1
  for(argc = 0; argv[argc]; argc++) {
    800055ea:	e0043983          	ld	s3,-512(s0)
    800055ee:	0009b503          	ld	a0,0(s3)
    800055f2:	cd29                	beqz	a0,8000564c <exec+0x2ac>
    800055f4:	e8840a13          	addi	s4,s0,-376
    800055f8:	f8840c93          	addi	s9,s0,-120
    800055fc:	4901                	li	s2,0
    sp -= strlen(argv[argc]) + 1;
    800055fe:	ffffc097          	auipc	ra,0xffffc
    80005602:	c5e080e7          	jalr	-930(ra) # 8000125c <strlen>
    80005606:	2505                	addiw	a0,a0,1
    80005608:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000560a:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    8000560c:	1174e463          	bltu	s1,s7,80005714 <exec+0x374>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005610:	0009ba83          	ld	s5,0(s3)
    80005614:	8556                	mv	a0,s5
    80005616:	ffffc097          	auipc	ra,0xffffc
    8000561a:	c46080e7          	jalr	-954(ra) # 8000125c <strlen>
    8000561e:	0015069b          	addiw	a3,a0,1
    80005622:	8656                	mv	a2,s5
    80005624:	85a6                	mv	a1,s1
    80005626:	8562                	mv	a0,s8
    80005628:	ffffc097          	auipc	ra,0xffffc
    8000562c:	576080e7          	jalr	1398(ra) # 80001b9e <copyout>
    80005630:	0e054463          	bltz	a0,80005718 <exec+0x378>
    ustack[argc] = sp;
    80005634:	009a3023          	sd	s1,0(s4)
  for(argc = 0; argv[argc]; argc++) {
    80005638:	0905                	addi	s2,s2,1
    8000563a:	09a1                	addi	s3,s3,8
    8000563c:	0009b503          	ld	a0,0(s3)
    80005640:	c909                	beqz	a0,80005652 <exec+0x2b2>
    if(argc >= MAXARG)
    80005642:	0a21                	addi	s4,s4,8
    80005644:	fb4c9de3          	bne	s9,s4,800055fe <exec+0x25e>
  ip = 0;
    80005648:	4481                	li	s1,0
    8000564a:	bf9d                	j	800055c0 <exec+0x220>
  sp = sz;
    8000564c:	e0843483          	ld	s1,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005650:	4901                	li	s2,0
  ustack[argc] = 0;
    80005652:	00391793          	slli	a5,s2,0x3
    80005656:	f9040713          	addi	a4,s0,-112
    8000565a:	97ba                	add	a5,a5,a4
    8000565c:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd0e4c>
  sp -= (argc+1) * sizeof(uint64);
    80005660:	00190693          	addi	a3,s2,1
    80005664:	068e                	slli	a3,a3,0x3
    80005666:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    80005668:	ff04f993          	andi	s3,s1,-16
  ip = 0;
    8000566c:	4481                	li	s1,0
  if(sp < stackbase)
    8000566e:	f579e9e3          	bltu	s3,s7,800055c0 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005672:	e8840613          	addi	a2,s0,-376
    80005676:	85ce                	mv	a1,s3
    80005678:	8562                	mv	a0,s8
    8000567a:	ffffc097          	auipc	ra,0xffffc
    8000567e:	524080e7          	jalr	1316(ra) # 80001b9e <copyout>
    80005682:	08054d63          	bltz	a0,8000571c <exec+0x37c>
  p->tf->a1 = sp;
    80005686:	070d3783          	ld	a5,112(s10)
    8000568a:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    8000568e:	df843783          	ld	a5,-520(s0)
    80005692:	0007c703          	lbu	a4,0(a5)
    80005696:	cf11                	beqz	a4,800056b2 <exec+0x312>
    80005698:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000569a:	02f00693          	li	a3,47
    8000569e:	a029                	j	800056a8 <exec+0x308>
  for(last=s=path; *s; s++)
    800056a0:	0785                	addi	a5,a5,1
    800056a2:	fff7c703          	lbu	a4,-1(a5)
    800056a6:	c711                	beqz	a4,800056b2 <exec+0x312>
    if(*s == '/')
    800056a8:	fed71ce3          	bne	a4,a3,800056a0 <exec+0x300>
      last = s+1;
    800056ac:	def43c23          	sd	a5,-520(s0)
    800056b0:	bfc5                	j	800056a0 <exec+0x300>
  safestrcpy(p->name, last, sizeof(p->name));
    800056b2:	4641                	li	a2,16
    800056b4:	df843583          	ld	a1,-520(s0)
    800056b8:	170d0513          	addi	a0,s10,368
    800056bc:	ffffc097          	auipc	ra,0xffffc
    800056c0:	b6e080e7          	jalr	-1170(ra) # 8000122a <safestrcpy>
  if(p->cmd) bd_free(p->cmd);
    800056c4:	180d3503          	ld	a0,384(s10)
    800056c8:	c509                	beqz	a0,800056d2 <exec+0x332>
    800056ca:	00002097          	auipc	ra,0x2
    800056ce:	962080e7          	jalr	-1694(ra) # 8000702c <bd_free>
  p->cmd = strjoin(argv);
    800056d2:	e0043503          	ld	a0,-512(s0)
    800056d6:	ffffc097          	auipc	ra,0xffffc
    800056da:	bb0080e7          	jalr	-1104(ra) # 80001286 <strjoin>
    800056de:	18ad3023          	sd	a0,384(s10)
  oldpagetable = p->pagetable;
    800056e2:	068d3503          	ld	a0,104(s10)
  p->pagetable = pagetable;
    800056e6:	078d3423          	sd	s8,104(s10)
  p->sz = sz;
    800056ea:	e0843783          	ld	a5,-504(s0)
    800056ee:	06fd3023          	sd	a5,96(s10)
  p->tf->epc = elf.entry;  // initial program counter = main
    800056f2:	070d3783          	ld	a5,112(s10)
    800056f6:	e6043703          	ld	a4,-416(s0)
    800056fa:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    800056fc:	070d3783          	ld	a5,112(s10)
    80005700:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005704:	85ee                	mv	a1,s11
    80005706:	ffffd097          	auipc	ra,0xffffd
    8000570a:	a5e080e7          	jalr	-1442(ra) # 80002164 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000570e:	0009051b          	sext.w	a0,s2
    80005712:	b32d                	j	8000543c <exec+0x9c>
  ip = 0;
    80005714:	4481                	li	s1,0
    80005716:	b56d                	j	800055c0 <exec+0x220>
    80005718:	4481                	li	s1,0
    8000571a:	b55d                	j	800055c0 <exec+0x220>
    8000571c:	4481                	li	s1,0
    8000571e:	b54d                	j	800055c0 <exec+0x220>

0000000080005720 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005720:	7179                	addi	sp,sp,-48
    80005722:	f406                	sd	ra,40(sp)
    80005724:	f022                	sd	s0,32(sp)
    80005726:	ec26                	sd	s1,24(sp)
    80005728:	e84a                	sd	s2,16(sp)
    8000572a:	1800                	addi	s0,sp,48
    8000572c:	892e                	mv	s2,a1
    8000572e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005730:	fdc40593          	addi	a1,s0,-36
    80005734:	ffffe097          	auipc	ra,0xffffe
    80005738:	adc080e7          	jalr	-1316(ra) # 80003210 <argint>
    8000573c:	04054063          	bltz	a0,8000577c <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005740:	fdc42703          	lw	a4,-36(s0)
    80005744:	47bd                	li	a5,15
    80005746:	02e7ed63          	bltu	a5,a4,80005780 <argfd+0x60>
    8000574a:	ffffd097          	auipc	ra,0xffffd
    8000574e:	852080e7          	jalr	-1966(ra) # 80001f9c <myproc>
    80005752:	fdc42703          	lw	a4,-36(s0)
    80005756:	01c70793          	addi	a5,a4,28
    8000575a:	078e                	slli	a5,a5,0x3
    8000575c:	953e                	add	a0,a0,a5
    8000575e:	651c                	ld	a5,8(a0)
    80005760:	c395                	beqz	a5,80005784 <argfd+0x64>
    return -1;
  if(pfd)
    80005762:	00090463          	beqz	s2,8000576a <argfd+0x4a>
    *pfd = fd;
    80005766:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000576a:	4501                	li	a0,0
  if(pf)
    8000576c:	c091                	beqz	s1,80005770 <argfd+0x50>
    *pf = f;
    8000576e:	e09c                	sd	a5,0(s1)
}
    80005770:	70a2                	ld	ra,40(sp)
    80005772:	7402                	ld	s0,32(sp)
    80005774:	64e2                	ld	s1,24(sp)
    80005776:	6942                	ld	s2,16(sp)
    80005778:	6145                	addi	sp,sp,48
    8000577a:	8082                	ret
    return -1;
    8000577c:	557d                	li	a0,-1
    8000577e:	bfcd                	j	80005770 <argfd+0x50>
    return -1;
    80005780:	557d                	li	a0,-1
    80005782:	b7fd                	j	80005770 <argfd+0x50>
    80005784:	557d                	li	a0,-1
    80005786:	b7ed                	j	80005770 <argfd+0x50>

0000000080005788 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005788:	1101                	addi	sp,sp,-32
    8000578a:	ec06                	sd	ra,24(sp)
    8000578c:	e822                	sd	s0,16(sp)
    8000578e:	e426                	sd	s1,8(sp)
    80005790:	1000                	addi	s0,sp,32
    80005792:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005794:	ffffd097          	auipc	ra,0xffffd
    80005798:	808080e7          	jalr	-2040(ra) # 80001f9c <myproc>
    8000579c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000579e:	0e850793          	addi	a5,a0,232
    800057a2:	4501                	li	a0,0
    800057a4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800057a6:	6398                	ld	a4,0(a5)
    800057a8:	cb19                	beqz	a4,800057be <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800057aa:	2505                	addiw	a0,a0,1
    800057ac:	07a1                	addi	a5,a5,8
    800057ae:	fed51ce3          	bne	a0,a3,800057a6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800057b2:	557d                	li	a0,-1
}
    800057b4:	60e2                	ld	ra,24(sp)
    800057b6:	6442                	ld	s0,16(sp)
    800057b8:	64a2                	ld	s1,8(sp)
    800057ba:	6105                	addi	sp,sp,32
    800057bc:	8082                	ret
      p->ofile[fd] = f;
    800057be:	01c50793          	addi	a5,a0,28
    800057c2:	078e                	slli	a5,a5,0x3
    800057c4:	963e                	add	a2,a2,a5
    800057c6:	e604                	sd	s1,8(a2)
      return fd;
    800057c8:	b7f5                	j	800057b4 <fdalloc+0x2c>

00000000800057ca <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800057ca:	715d                	addi	sp,sp,-80
    800057cc:	e486                	sd	ra,72(sp)
    800057ce:	e0a2                	sd	s0,64(sp)
    800057d0:	fc26                	sd	s1,56(sp)
    800057d2:	f84a                	sd	s2,48(sp)
    800057d4:	f44e                	sd	s3,40(sp)
    800057d6:	f052                	sd	s4,32(sp)
    800057d8:	ec56                	sd	s5,24(sp)
    800057da:	0880                	addi	s0,sp,80
    800057dc:	89ae                	mv	s3,a1
    800057de:	8ab2                	mv	s5,a2
    800057e0:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800057e2:	fb040593          	addi	a1,s0,-80
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	d56080e7          	jalr	-682(ra) # 8000453c <nameiparent>
    800057ee:	892a                	mv	s2,a0
    800057f0:	12050f63          	beqz	a0,8000592e <create+0x164>
    return 0;

  ilock(dp);
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	5a0080e7          	jalr	1440(ra) # 80003d94 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800057fc:	4601                	li	a2,0
    800057fe:	fb040593          	addi	a1,s0,-80
    80005802:	854a                	mv	a0,s2
    80005804:	fffff097          	auipc	ra,0xfffff
    80005808:	a48080e7          	jalr	-1464(ra) # 8000424c <dirlookup>
    8000580c:	84aa                	mv	s1,a0
    8000580e:	c921                	beqz	a0,8000585e <create+0x94>
    iunlockput(dp);
    80005810:	854a                	mv	a0,s2
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	7c0080e7          	jalr	1984(ra) # 80003fd2 <iunlockput>
    ilock(ip);
    8000581a:	8526                	mv	a0,s1
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	578080e7          	jalr	1400(ra) # 80003d94 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005824:	2981                	sext.w	s3,s3
    80005826:	4789                	li	a5,2
    80005828:	02f99463          	bne	s3,a5,80005850 <create+0x86>
    8000582c:	05c4d783          	lhu	a5,92(s1)
    80005830:	37f9                	addiw	a5,a5,-2
    80005832:	17c2                	slli	a5,a5,0x30
    80005834:	93c1                	srli	a5,a5,0x30
    80005836:	4705                	li	a4,1
    80005838:	00f76c63          	bltu	a4,a5,80005850 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000583c:	8526                	mv	a0,s1
    8000583e:	60a6                	ld	ra,72(sp)
    80005840:	6406                	ld	s0,64(sp)
    80005842:	74e2                	ld	s1,56(sp)
    80005844:	7942                	ld	s2,48(sp)
    80005846:	79a2                	ld	s3,40(sp)
    80005848:	7a02                	ld	s4,32(sp)
    8000584a:	6ae2                	ld	s5,24(sp)
    8000584c:	6161                	addi	sp,sp,80
    8000584e:	8082                	ret
    iunlockput(ip);
    80005850:	8526                	mv	a0,s1
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	780080e7          	jalr	1920(ra) # 80003fd2 <iunlockput>
    return 0;
    8000585a:	4481                	li	s1,0
    8000585c:	b7c5                	j	8000583c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000585e:	85ce                	mv	a1,s3
    80005860:	00092503          	lw	a0,0(s2)
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	398080e7          	jalr	920(ra) # 80003bfc <ialloc>
    8000586c:	84aa                	mv	s1,a0
    8000586e:	c529                	beqz	a0,800058b8 <create+0xee>
  ilock(ip);
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	524080e7          	jalr	1316(ra) # 80003d94 <ilock>
  ip->major = major;
    80005878:	05549f23          	sh	s5,94(s1)
  ip->minor = minor;
    8000587c:	07449023          	sh	s4,96(s1)
  ip->nlink = 1;
    80005880:	4785                	li	a5,1
    80005882:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005886:	8526                	mv	a0,s1
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	442080e7          	jalr	1090(ra) # 80003cca <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005890:	2981                	sext.w	s3,s3
    80005892:	4785                	li	a5,1
    80005894:	02f98a63          	beq	s3,a5,800058c8 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005898:	40d0                	lw	a2,4(s1)
    8000589a:	fb040593          	addi	a1,s0,-80
    8000589e:	854a                	mv	a0,s2
    800058a0:	fffff097          	auipc	ra,0xfffff
    800058a4:	bbc080e7          	jalr	-1092(ra) # 8000445c <dirlink>
    800058a8:	06054b63          	bltz	a0,8000591e <create+0x154>
  iunlockput(dp);
    800058ac:	854a                	mv	a0,s2
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	724080e7          	jalr	1828(ra) # 80003fd2 <iunlockput>
  return ip;
    800058b6:	b759                	j	8000583c <create+0x72>
    panic("create: ialloc");
    800058b8:	00003517          	auipc	a0,0x3
    800058bc:	39050513          	addi	a0,a0,912 # 80008c48 <userret+0xbb8>
    800058c0:	ffffb097          	auipc	ra,0xffffb
    800058c4:	e96080e7          	jalr	-362(ra) # 80000756 <panic>
    dp->nlink++;  // for ".."
    800058c8:	06295783          	lhu	a5,98(s2)
    800058cc:	2785                	addiw	a5,a5,1
    800058ce:	06f91123          	sh	a5,98(s2)
    iupdate(dp);
    800058d2:	854a                	mv	a0,s2
    800058d4:	ffffe097          	auipc	ra,0xffffe
    800058d8:	3f6080e7          	jalr	1014(ra) # 80003cca <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800058dc:	40d0                	lw	a2,4(s1)
    800058de:	00003597          	auipc	a1,0x3
    800058e2:	37a58593          	addi	a1,a1,890 # 80008c58 <userret+0xbc8>
    800058e6:	8526                	mv	a0,s1
    800058e8:	fffff097          	auipc	ra,0xfffff
    800058ec:	b74080e7          	jalr	-1164(ra) # 8000445c <dirlink>
    800058f0:	00054f63          	bltz	a0,8000590e <create+0x144>
    800058f4:	00492603          	lw	a2,4(s2)
    800058f8:	00003597          	auipc	a1,0x3
    800058fc:	36858593          	addi	a1,a1,872 # 80008c60 <userret+0xbd0>
    80005900:	8526                	mv	a0,s1
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	b5a080e7          	jalr	-1190(ra) # 8000445c <dirlink>
    8000590a:	f80557e3          	bgez	a0,80005898 <create+0xce>
      panic("create dots");
    8000590e:	00003517          	auipc	a0,0x3
    80005912:	35a50513          	addi	a0,a0,858 # 80008c68 <userret+0xbd8>
    80005916:	ffffb097          	auipc	ra,0xffffb
    8000591a:	e40080e7          	jalr	-448(ra) # 80000756 <panic>
    panic("create: dirlink");
    8000591e:	00003517          	auipc	a0,0x3
    80005922:	35a50513          	addi	a0,a0,858 # 80008c78 <userret+0xbe8>
    80005926:	ffffb097          	auipc	ra,0xffffb
    8000592a:	e30080e7          	jalr	-464(ra) # 80000756 <panic>
    return 0;
    8000592e:	84aa                	mv	s1,a0
    80005930:	b731                	j	8000583c <create+0x72>

0000000080005932 <sys_dup>:
{
    80005932:	7179                	addi	sp,sp,-48
    80005934:	f406                	sd	ra,40(sp)
    80005936:	f022                	sd	s0,32(sp)
    80005938:	ec26                	sd	s1,24(sp)
    8000593a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000593c:	fd840613          	addi	a2,s0,-40
    80005940:	4581                	li	a1,0
    80005942:	4501                	li	a0,0
    80005944:	00000097          	auipc	ra,0x0
    80005948:	ddc080e7          	jalr	-548(ra) # 80005720 <argfd>
    return -1;
    8000594c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000594e:	02054363          	bltz	a0,80005974 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005952:	fd843503          	ld	a0,-40(s0)
    80005956:	00000097          	auipc	ra,0x0
    8000595a:	e32080e7          	jalr	-462(ra) # 80005788 <fdalloc>
    8000595e:	84aa                	mv	s1,a0
    return -1;
    80005960:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005962:	00054963          	bltz	a0,80005974 <sys_dup+0x42>
  filedup(f);
    80005966:	fd843503          	ld	a0,-40(s0)
    8000596a:	fffff097          	auipc	ra,0xfffff
    8000596e:	332080e7          	jalr	818(ra) # 80004c9c <filedup>
  return fd;
    80005972:	87a6                	mv	a5,s1
}
    80005974:	853e                	mv	a0,a5
    80005976:	70a2                	ld	ra,40(sp)
    80005978:	7402                	ld	s0,32(sp)
    8000597a:	64e2                	ld	s1,24(sp)
    8000597c:	6145                	addi	sp,sp,48
    8000597e:	8082                	ret

0000000080005980 <sys_read>:
{
    80005980:	7179                	addi	sp,sp,-48
    80005982:	f406                	sd	ra,40(sp)
    80005984:	f022                	sd	s0,32(sp)
    80005986:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005988:	fe840613          	addi	a2,s0,-24
    8000598c:	4581                	li	a1,0
    8000598e:	4501                	li	a0,0
    80005990:	00000097          	auipc	ra,0x0
    80005994:	d90080e7          	jalr	-624(ra) # 80005720 <argfd>
    return -1;
    80005998:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000599a:	04054163          	bltz	a0,800059dc <sys_read+0x5c>
    8000599e:	fe440593          	addi	a1,s0,-28
    800059a2:	4509                	li	a0,2
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	86c080e7          	jalr	-1940(ra) # 80003210 <argint>
    return -1;
    800059ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800059ae:	02054763          	bltz	a0,800059dc <sys_read+0x5c>
    800059b2:	fd840593          	addi	a1,s0,-40
    800059b6:	4505                	li	a0,1
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	87a080e7          	jalr	-1926(ra) # 80003232 <argaddr>
    return -1;
    800059c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800059c2:	00054d63          	bltz	a0,800059dc <sys_read+0x5c>
  return fileread(f, p, n);
    800059c6:	fe442603          	lw	a2,-28(s0)
    800059ca:	fd843583          	ld	a1,-40(s0)
    800059ce:	fe843503          	ld	a0,-24(s0)
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	45e080e7          	jalr	1118(ra) # 80004e30 <fileread>
    800059da:	87aa                	mv	a5,a0
}
    800059dc:	853e                	mv	a0,a5
    800059de:	70a2                	ld	ra,40(sp)
    800059e0:	7402                	ld	s0,32(sp)
    800059e2:	6145                	addi	sp,sp,48
    800059e4:	8082                	ret

00000000800059e6 <sys_write>:
{
    800059e6:	7179                	addi	sp,sp,-48
    800059e8:	f406                	sd	ra,40(sp)
    800059ea:	f022                	sd	s0,32(sp)
    800059ec:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800059ee:	fe840613          	addi	a2,s0,-24
    800059f2:	4581                	li	a1,0
    800059f4:	4501                	li	a0,0
    800059f6:	00000097          	auipc	ra,0x0
    800059fa:	d2a080e7          	jalr	-726(ra) # 80005720 <argfd>
    return -1;
    800059fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a00:	04054163          	bltz	a0,80005a42 <sys_write+0x5c>
    80005a04:	fe440593          	addi	a1,s0,-28
    80005a08:	4509                	li	a0,2
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	806080e7          	jalr	-2042(ra) # 80003210 <argint>
    return -1;
    80005a12:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a14:	02054763          	bltz	a0,80005a42 <sys_write+0x5c>
    80005a18:	fd840593          	addi	a1,s0,-40
    80005a1c:	4505                	li	a0,1
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	814080e7          	jalr	-2028(ra) # 80003232 <argaddr>
    return -1;
    80005a26:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005a28:	00054d63          	bltz	a0,80005a42 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005a2c:	fe442603          	lw	a2,-28(s0)
    80005a30:	fd843583          	ld	a1,-40(s0)
    80005a34:	fe843503          	ld	a0,-24(s0)
    80005a38:	fffff097          	auipc	ra,0xfffff
    80005a3c:	4be080e7          	jalr	1214(ra) # 80004ef6 <filewrite>
    80005a40:	87aa                	mv	a5,a0
}
    80005a42:	853e                	mv	a0,a5
    80005a44:	70a2                	ld	ra,40(sp)
    80005a46:	7402                	ld	s0,32(sp)
    80005a48:	6145                	addi	sp,sp,48
    80005a4a:	8082                	ret

0000000080005a4c <sys_close>:
{
    80005a4c:	1101                	addi	sp,sp,-32
    80005a4e:	ec06                	sd	ra,24(sp)
    80005a50:	e822                	sd	s0,16(sp)
    80005a52:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005a54:	fe040613          	addi	a2,s0,-32
    80005a58:	fec40593          	addi	a1,s0,-20
    80005a5c:	4501                	li	a0,0
    80005a5e:	00000097          	auipc	ra,0x0
    80005a62:	cc2080e7          	jalr	-830(ra) # 80005720 <argfd>
    return -1;
    80005a66:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005a68:	02054463          	bltz	a0,80005a90 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005a6c:	ffffc097          	auipc	ra,0xffffc
    80005a70:	530080e7          	jalr	1328(ra) # 80001f9c <myproc>
    80005a74:	fec42783          	lw	a5,-20(s0)
    80005a78:	07f1                	addi	a5,a5,28
    80005a7a:	078e                	slli	a5,a5,0x3
    80005a7c:	97aa                	add	a5,a5,a0
    80005a7e:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005a82:	fe043503          	ld	a0,-32(s0)
    80005a86:	fffff097          	auipc	ra,0xfffff
    80005a8a:	268080e7          	jalr	616(ra) # 80004cee <fileclose>
  return 0;
    80005a8e:	4781                	li	a5,0
}
    80005a90:	853e                	mv	a0,a5
    80005a92:	60e2                	ld	ra,24(sp)
    80005a94:	6442                	ld	s0,16(sp)
    80005a96:	6105                	addi	sp,sp,32
    80005a98:	8082                	ret

0000000080005a9a <sys_fstat>:
{
    80005a9a:	1101                	addi	sp,sp,-32
    80005a9c:	ec06                	sd	ra,24(sp)
    80005a9e:	e822                	sd	s0,16(sp)
    80005aa0:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005aa2:	fe840613          	addi	a2,s0,-24
    80005aa6:	4581                	li	a1,0
    80005aa8:	4501                	li	a0,0
    80005aaa:	00000097          	auipc	ra,0x0
    80005aae:	c76080e7          	jalr	-906(ra) # 80005720 <argfd>
    return -1;
    80005ab2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005ab4:	02054563          	bltz	a0,80005ade <sys_fstat+0x44>
    80005ab8:	fe040593          	addi	a1,s0,-32
    80005abc:	4505                	li	a0,1
    80005abe:	ffffd097          	auipc	ra,0xffffd
    80005ac2:	774080e7          	jalr	1908(ra) # 80003232 <argaddr>
    return -1;
    80005ac6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005ac8:	00054b63          	bltz	a0,80005ade <sys_fstat+0x44>
  return filestat(f, st);
    80005acc:	fe043583          	ld	a1,-32(s0)
    80005ad0:	fe843503          	ld	a0,-24(s0)
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	2ea080e7          	jalr	746(ra) # 80004dbe <filestat>
    80005adc:	87aa                	mv	a5,a0
}
    80005ade:	853e                	mv	a0,a5
    80005ae0:	60e2                	ld	ra,24(sp)
    80005ae2:	6442                	ld	s0,16(sp)
    80005ae4:	6105                	addi	sp,sp,32
    80005ae6:	8082                	ret

0000000080005ae8 <sys_link>:
{
    80005ae8:	7169                	addi	sp,sp,-304
    80005aea:	f606                	sd	ra,296(sp)
    80005aec:	f222                	sd	s0,288(sp)
    80005aee:	ee26                	sd	s1,280(sp)
    80005af0:	ea4a                	sd	s2,272(sp)
    80005af2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005af4:	08000613          	li	a2,128
    80005af8:	ed040593          	addi	a1,s0,-304
    80005afc:	4501                	li	a0,0
    80005afe:	ffffd097          	auipc	ra,0xffffd
    80005b02:	756080e7          	jalr	1878(ra) # 80003254 <argstr>
    return -1;
    80005b06:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b08:	12054363          	bltz	a0,80005c2e <sys_link+0x146>
    80005b0c:	08000613          	li	a2,128
    80005b10:	f5040593          	addi	a1,s0,-176
    80005b14:	4505                	li	a0,1
    80005b16:	ffffd097          	auipc	ra,0xffffd
    80005b1a:	73e080e7          	jalr	1854(ra) # 80003254 <argstr>
    return -1;
    80005b1e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b20:	10054763          	bltz	a0,80005c2e <sys_link+0x146>
  begin_op(ROOTDEV);
    80005b24:	4501                	li	a0,0
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	c3e080e7          	jalr	-962(ra) # 80004764 <begin_op>
  if((ip = namei(old)) == 0){
    80005b2e:	ed040513          	addi	a0,s0,-304
    80005b32:	fffff097          	auipc	ra,0xfffff
    80005b36:	9ec080e7          	jalr	-1556(ra) # 8000451e <namei>
    80005b3a:	84aa                	mv	s1,a0
    80005b3c:	c559                	beqz	a0,80005bca <sys_link+0xe2>
  ilock(ip);
    80005b3e:	ffffe097          	auipc	ra,0xffffe
    80005b42:	256080e7          	jalr	598(ra) # 80003d94 <ilock>
  if(ip->type == T_DIR){
    80005b46:	05c49703          	lh	a4,92(s1)
    80005b4a:	4785                	li	a5,1
    80005b4c:	08f70663          	beq	a4,a5,80005bd8 <sys_link+0xf0>
  ip->nlink++;
    80005b50:	0624d783          	lhu	a5,98(s1)
    80005b54:	2785                	addiw	a5,a5,1
    80005b56:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005b5a:	8526                	mv	a0,s1
    80005b5c:	ffffe097          	auipc	ra,0xffffe
    80005b60:	16e080e7          	jalr	366(ra) # 80003cca <iupdate>
  iunlock(ip);
    80005b64:	8526                	mv	a0,s1
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	2f0080e7          	jalr	752(ra) # 80003e56 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005b6e:	fd040593          	addi	a1,s0,-48
    80005b72:	f5040513          	addi	a0,s0,-176
    80005b76:	fffff097          	auipc	ra,0xfffff
    80005b7a:	9c6080e7          	jalr	-1594(ra) # 8000453c <nameiparent>
    80005b7e:	892a                	mv	s2,a0
    80005b80:	cd2d                	beqz	a0,80005bfa <sys_link+0x112>
  ilock(dp);
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	212080e7          	jalr	530(ra) # 80003d94 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005b8a:	00092703          	lw	a4,0(s2)
    80005b8e:	409c                	lw	a5,0(s1)
    80005b90:	06f71063          	bne	a4,a5,80005bf0 <sys_link+0x108>
    80005b94:	40d0                	lw	a2,4(s1)
    80005b96:	fd040593          	addi	a1,s0,-48
    80005b9a:	854a                	mv	a0,s2
    80005b9c:	fffff097          	auipc	ra,0xfffff
    80005ba0:	8c0080e7          	jalr	-1856(ra) # 8000445c <dirlink>
    80005ba4:	04054663          	bltz	a0,80005bf0 <sys_link+0x108>
  iunlockput(dp);
    80005ba8:	854a                	mv	a0,s2
    80005baa:	ffffe097          	auipc	ra,0xffffe
    80005bae:	428080e7          	jalr	1064(ra) # 80003fd2 <iunlockput>
  iput(ip);
    80005bb2:	8526                	mv	a0,s1
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	2ee080e7          	jalr	750(ra) # 80003ea2 <iput>
  end_op(ROOTDEV);
    80005bbc:	4501                	li	a0,0
    80005bbe:	fffff097          	auipc	ra,0xfffff
    80005bc2:	c52080e7          	jalr	-942(ra) # 80004810 <end_op>
  return 0;
    80005bc6:	4781                	li	a5,0
    80005bc8:	a09d                	j	80005c2e <sys_link+0x146>
    end_op(ROOTDEV);
    80005bca:	4501                	li	a0,0
    80005bcc:	fffff097          	auipc	ra,0xfffff
    80005bd0:	c44080e7          	jalr	-956(ra) # 80004810 <end_op>
    return -1;
    80005bd4:	57fd                	li	a5,-1
    80005bd6:	a8a1                	j	80005c2e <sys_link+0x146>
    iunlockput(ip);
    80005bd8:	8526                	mv	a0,s1
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	3f8080e7          	jalr	1016(ra) # 80003fd2 <iunlockput>
    end_op(ROOTDEV);
    80005be2:	4501                	li	a0,0
    80005be4:	fffff097          	auipc	ra,0xfffff
    80005be8:	c2c080e7          	jalr	-980(ra) # 80004810 <end_op>
    return -1;
    80005bec:	57fd                	li	a5,-1
    80005bee:	a081                	j	80005c2e <sys_link+0x146>
    iunlockput(dp);
    80005bf0:	854a                	mv	a0,s2
    80005bf2:	ffffe097          	auipc	ra,0xffffe
    80005bf6:	3e0080e7          	jalr	992(ra) # 80003fd2 <iunlockput>
  ilock(ip);
    80005bfa:	8526                	mv	a0,s1
    80005bfc:	ffffe097          	auipc	ra,0xffffe
    80005c00:	198080e7          	jalr	408(ra) # 80003d94 <ilock>
  ip->nlink--;
    80005c04:	0624d783          	lhu	a5,98(s1)
    80005c08:	37fd                	addiw	a5,a5,-1
    80005c0a:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005c0e:	8526                	mv	a0,s1
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	0ba080e7          	jalr	186(ra) # 80003cca <iupdate>
  iunlockput(ip);
    80005c18:	8526                	mv	a0,s1
    80005c1a:	ffffe097          	auipc	ra,0xffffe
    80005c1e:	3b8080e7          	jalr	952(ra) # 80003fd2 <iunlockput>
  end_op(ROOTDEV);
    80005c22:	4501                	li	a0,0
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	bec080e7          	jalr	-1044(ra) # 80004810 <end_op>
  return -1;
    80005c2c:	57fd                	li	a5,-1
}
    80005c2e:	853e                	mv	a0,a5
    80005c30:	70b2                	ld	ra,296(sp)
    80005c32:	7412                	ld	s0,288(sp)
    80005c34:	64f2                	ld	s1,280(sp)
    80005c36:	6952                	ld	s2,272(sp)
    80005c38:	6155                	addi	sp,sp,304
    80005c3a:	8082                	ret

0000000080005c3c <sys_unlink>:
{
    80005c3c:	7151                	addi	sp,sp,-240
    80005c3e:	f586                	sd	ra,232(sp)
    80005c40:	f1a2                	sd	s0,224(sp)
    80005c42:	eda6                	sd	s1,216(sp)
    80005c44:	e9ca                	sd	s2,208(sp)
    80005c46:	e5ce                	sd	s3,200(sp)
    80005c48:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c4a:	08000613          	li	a2,128
    80005c4e:	f3040593          	addi	a1,s0,-208
    80005c52:	4501                	li	a0,0
    80005c54:	ffffd097          	auipc	ra,0xffffd
    80005c58:	600080e7          	jalr	1536(ra) # 80003254 <argstr>
    80005c5c:	18054463          	bltz	a0,80005de4 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    80005c60:	4501                	li	a0,0
    80005c62:	fffff097          	auipc	ra,0xfffff
    80005c66:	b02080e7          	jalr	-1278(ra) # 80004764 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005c6a:	fb040593          	addi	a1,s0,-80
    80005c6e:	f3040513          	addi	a0,s0,-208
    80005c72:	fffff097          	auipc	ra,0xfffff
    80005c76:	8ca080e7          	jalr	-1846(ra) # 8000453c <nameiparent>
    80005c7a:	84aa                	mv	s1,a0
    80005c7c:	cd61                	beqz	a0,80005d54 <sys_unlink+0x118>
  ilock(dp);
    80005c7e:	ffffe097          	auipc	ra,0xffffe
    80005c82:	116080e7          	jalr	278(ra) # 80003d94 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005c86:	00003597          	auipc	a1,0x3
    80005c8a:	fd258593          	addi	a1,a1,-46 # 80008c58 <userret+0xbc8>
    80005c8e:	fb040513          	addi	a0,s0,-80
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	5a0080e7          	jalr	1440(ra) # 80004232 <namecmp>
    80005c9a:	14050c63          	beqz	a0,80005df2 <sys_unlink+0x1b6>
    80005c9e:	00003597          	auipc	a1,0x3
    80005ca2:	fc258593          	addi	a1,a1,-62 # 80008c60 <userret+0xbd0>
    80005ca6:	fb040513          	addi	a0,s0,-80
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	588080e7          	jalr	1416(ra) # 80004232 <namecmp>
    80005cb2:	14050063          	beqz	a0,80005df2 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005cb6:	f2c40613          	addi	a2,s0,-212
    80005cba:	fb040593          	addi	a1,s0,-80
    80005cbe:	8526                	mv	a0,s1
    80005cc0:	ffffe097          	auipc	ra,0xffffe
    80005cc4:	58c080e7          	jalr	1420(ra) # 8000424c <dirlookup>
    80005cc8:	892a                	mv	s2,a0
    80005cca:	12050463          	beqz	a0,80005df2 <sys_unlink+0x1b6>
  ilock(ip);
    80005cce:	ffffe097          	auipc	ra,0xffffe
    80005cd2:	0c6080e7          	jalr	198(ra) # 80003d94 <ilock>
  if(ip->nlink < 1)
    80005cd6:	06291783          	lh	a5,98(s2)
    80005cda:	08f05463          	blez	a5,80005d62 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005cde:	05c91703          	lh	a4,92(s2)
    80005ce2:	4785                	li	a5,1
    80005ce4:	08f70763          	beq	a4,a5,80005d72 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005ce8:	4641                	li	a2,16
    80005cea:	4581                	li	a1,0
    80005cec:	fc040513          	addi	a0,s0,-64
    80005cf0:	ffffb097          	auipc	ra,0xffffb
    80005cf4:	3e4080e7          	jalr	996(ra) # 800010d4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005cf8:	4741                	li	a4,16
    80005cfa:	f2c42683          	lw	a3,-212(s0)
    80005cfe:	fc040613          	addi	a2,s0,-64
    80005d02:	4581                	li	a1,0
    80005d04:	8526                	mv	a0,s1
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	412080e7          	jalr	1042(ra) # 80004118 <writei>
    80005d0e:	47c1                	li	a5,16
    80005d10:	0af51763          	bne	a0,a5,80005dbe <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005d14:	05c91703          	lh	a4,92(s2)
    80005d18:	4785                	li	a5,1
    80005d1a:	0af70a63          	beq	a4,a5,80005dce <sys_unlink+0x192>
  iunlockput(dp);
    80005d1e:	8526                	mv	a0,s1
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	2b2080e7          	jalr	690(ra) # 80003fd2 <iunlockput>
  ip->nlink--;
    80005d28:	06295783          	lhu	a5,98(s2)
    80005d2c:	37fd                	addiw	a5,a5,-1
    80005d2e:	06f91123          	sh	a5,98(s2)
  iupdate(ip);
    80005d32:	854a                	mv	a0,s2
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	f96080e7          	jalr	-106(ra) # 80003cca <iupdate>
  iunlockput(ip);
    80005d3c:	854a                	mv	a0,s2
    80005d3e:	ffffe097          	auipc	ra,0xffffe
    80005d42:	294080e7          	jalr	660(ra) # 80003fd2 <iunlockput>
  end_op(ROOTDEV);
    80005d46:	4501                	li	a0,0
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	ac8080e7          	jalr	-1336(ra) # 80004810 <end_op>
  return 0;
    80005d50:	4501                	li	a0,0
    80005d52:	a85d                	j	80005e08 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    80005d54:	4501                	li	a0,0
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	aba080e7          	jalr	-1350(ra) # 80004810 <end_op>
    return -1;
    80005d5e:	557d                	li	a0,-1
    80005d60:	a065                	j	80005e08 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    80005d62:	00003517          	auipc	a0,0x3
    80005d66:	f2650513          	addi	a0,a0,-218 # 80008c88 <userret+0xbf8>
    80005d6a:	ffffb097          	auipc	ra,0xffffb
    80005d6e:	9ec080e7          	jalr	-1556(ra) # 80000756 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d72:	06492703          	lw	a4,100(s2)
    80005d76:	02000793          	li	a5,32
    80005d7a:	f6e7f7e3          	bgeu	a5,a4,80005ce8 <sys_unlink+0xac>
    80005d7e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d82:	4741                	li	a4,16
    80005d84:	86ce                	mv	a3,s3
    80005d86:	f1840613          	addi	a2,s0,-232
    80005d8a:	4581                	li	a1,0
    80005d8c:	854a                	mv	a0,s2
    80005d8e:	ffffe097          	auipc	ra,0xffffe
    80005d92:	296080e7          	jalr	662(ra) # 80004024 <readi>
    80005d96:	47c1                	li	a5,16
    80005d98:	00f51b63          	bne	a0,a5,80005dae <sys_unlink+0x172>
    if(de.inum != 0)
    80005d9c:	f1845783          	lhu	a5,-232(s0)
    80005da0:	e7a1                	bnez	a5,80005de8 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005da2:	29c1                	addiw	s3,s3,16
    80005da4:	06492783          	lw	a5,100(s2)
    80005da8:	fcf9ede3          	bltu	s3,a5,80005d82 <sys_unlink+0x146>
    80005dac:	bf35                	j	80005ce8 <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005dae:	00003517          	auipc	a0,0x3
    80005db2:	ef250513          	addi	a0,a0,-270 # 80008ca0 <userret+0xc10>
    80005db6:	ffffb097          	auipc	ra,0xffffb
    80005dba:	9a0080e7          	jalr	-1632(ra) # 80000756 <panic>
    panic("unlink: writei");
    80005dbe:	00003517          	auipc	a0,0x3
    80005dc2:	efa50513          	addi	a0,a0,-262 # 80008cb8 <userret+0xc28>
    80005dc6:	ffffb097          	auipc	ra,0xffffb
    80005dca:	990080e7          	jalr	-1648(ra) # 80000756 <panic>
    dp->nlink--;
    80005dce:	0624d783          	lhu	a5,98(s1)
    80005dd2:	37fd                	addiw	a5,a5,-1
    80005dd4:	06f49123          	sh	a5,98(s1)
    iupdate(dp);
    80005dd8:	8526                	mv	a0,s1
    80005dda:	ffffe097          	auipc	ra,0xffffe
    80005dde:	ef0080e7          	jalr	-272(ra) # 80003cca <iupdate>
    80005de2:	bf35                	j	80005d1e <sys_unlink+0xe2>
    return -1;
    80005de4:	557d                	li	a0,-1
    80005de6:	a00d                	j	80005e08 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005de8:	854a                	mv	a0,s2
    80005dea:	ffffe097          	auipc	ra,0xffffe
    80005dee:	1e8080e7          	jalr	488(ra) # 80003fd2 <iunlockput>
  iunlockput(dp);
    80005df2:	8526                	mv	a0,s1
    80005df4:	ffffe097          	auipc	ra,0xffffe
    80005df8:	1de080e7          	jalr	478(ra) # 80003fd2 <iunlockput>
  end_op(ROOTDEV);
    80005dfc:	4501                	li	a0,0
    80005dfe:	fffff097          	auipc	ra,0xfffff
    80005e02:	a12080e7          	jalr	-1518(ra) # 80004810 <end_op>
  return -1;
    80005e06:	557d                	li	a0,-1
}
    80005e08:	70ae                	ld	ra,232(sp)
    80005e0a:	740e                	ld	s0,224(sp)
    80005e0c:	64ee                	ld	s1,216(sp)
    80005e0e:	694e                	ld	s2,208(sp)
    80005e10:	69ae                	ld	s3,200(sp)
    80005e12:	616d                	addi	sp,sp,240
    80005e14:	8082                	ret

0000000080005e16 <sys_open>:

uint64
sys_open(void)
{
    80005e16:	7131                	addi	sp,sp,-192
    80005e18:	fd06                	sd	ra,184(sp)
    80005e1a:	f922                	sd	s0,176(sp)
    80005e1c:	f526                	sd	s1,168(sp)
    80005e1e:	f14a                	sd	s2,160(sp)
    80005e20:	ed4e                	sd	s3,152(sp)
    80005e22:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005e24:	08000613          	li	a2,128
    80005e28:	f5040593          	addi	a1,s0,-176
    80005e2c:	4501                	li	a0,0
    80005e2e:	ffffd097          	auipc	ra,0xffffd
    80005e32:	426080e7          	jalr	1062(ra) # 80003254 <argstr>
    return -1;
    80005e36:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005e38:	0a054963          	bltz	a0,80005eea <sys_open+0xd4>
    80005e3c:	f4c40593          	addi	a1,s0,-180
    80005e40:	4505                	li	a0,1
    80005e42:	ffffd097          	auipc	ra,0xffffd
    80005e46:	3ce080e7          	jalr	974(ra) # 80003210 <argint>
    80005e4a:	0a054063          	bltz	a0,80005eea <sys_open+0xd4>

  begin_op(ROOTDEV);
    80005e4e:	4501                	li	a0,0
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	914080e7          	jalr	-1772(ra) # 80004764 <begin_op>

  if(omode & O_CREATE){
    80005e58:	f4c42783          	lw	a5,-180(s0)
    80005e5c:	2007f793          	andi	a5,a5,512
    80005e60:	c3dd                	beqz	a5,80005f06 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80005e62:	4681                	li	a3,0
    80005e64:	4601                	li	a2,0
    80005e66:	4589                	li	a1,2
    80005e68:	f5040513          	addi	a0,s0,-176
    80005e6c:	00000097          	auipc	ra,0x0
    80005e70:	95e080e7          	jalr	-1698(ra) # 800057ca <create>
    80005e74:	892a                	mv	s2,a0
    if(ip == 0){
    80005e76:	c151                	beqz	a0,80005efa <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005e78:	05c91703          	lh	a4,92(s2)
    80005e7c:	478d                	li	a5,3
    80005e7e:	00f71763          	bne	a4,a5,80005e8c <sys_open+0x76>
    80005e82:	05e95703          	lhu	a4,94(s2)
    80005e86:	47a5                	li	a5,9
    80005e88:	0ce7e663          	bltu	a5,a4,80005f54 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005e8c:	fffff097          	auipc	ra,0xfffff
    80005e90:	da6080e7          	jalr	-602(ra) # 80004c32 <filealloc>
    80005e94:	89aa                	mv	s3,a0
    80005e96:	c97d                	beqz	a0,80005f8c <sys_open+0x176>
    80005e98:	00000097          	auipc	ra,0x0
    80005e9c:	8f0080e7          	jalr	-1808(ra) # 80005788 <fdalloc>
    80005ea0:	84aa                	mv	s1,a0
    80005ea2:	0e054063          	bltz	a0,80005f82 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ea6:	05c91703          	lh	a4,92(s2)
    80005eaa:	478d                	li	a5,3
    80005eac:	0cf70063          	beq	a4,a5,80005f6c <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005eb0:	4789                	li	a5,2
    80005eb2:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005eb6:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005eba:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005ebe:	f4c42783          	lw	a5,-180(s0)
    80005ec2:	0017c713          	xori	a4,a5,1
    80005ec6:	8b05                	andi	a4,a4,1
    80005ec8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ecc:	8b8d                	andi	a5,a5,3
    80005ece:	00f037b3          	snez	a5,a5
    80005ed2:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005ed6:	854a                	mv	a0,s2
    80005ed8:	ffffe097          	auipc	ra,0xffffe
    80005edc:	f7e080e7          	jalr	-130(ra) # 80003e56 <iunlock>
  end_op(ROOTDEV);
    80005ee0:	4501                	li	a0,0
    80005ee2:	fffff097          	auipc	ra,0xfffff
    80005ee6:	92e080e7          	jalr	-1746(ra) # 80004810 <end_op>

  return fd;
}
    80005eea:	8526                	mv	a0,s1
    80005eec:	70ea                	ld	ra,184(sp)
    80005eee:	744a                	ld	s0,176(sp)
    80005ef0:	74aa                	ld	s1,168(sp)
    80005ef2:	790a                	ld	s2,160(sp)
    80005ef4:	69ea                	ld	s3,152(sp)
    80005ef6:	6129                	addi	sp,sp,192
    80005ef8:	8082                	ret
      end_op(ROOTDEV);
    80005efa:	4501                	li	a0,0
    80005efc:	fffff097          	auipc	ra,0xfffff
    80005f00:	914080e7          	jalr	-1772(ra) # 80004810 <end_op>
      return -1;
    80005f04:	b7dd                	j	80005eea <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005f06:	f5040513          	addi	a0,s0,-176
    80005f0a:	ffffe097          	auipc	ra,0xffffe
    80005f0e:	614080e7          	jalr	1556(ra) # 8000451e <namei>
    80005f12:	892a                	mv	s2,a0
    80005f14:	c90d                	beqz	a0,80005f46 <sys_open+0x130>
    ilock(ip);
    80005f16:	ffffe097          	auipc	ra,0xffffe
    80005f1a:	e7e080e7          	jalr	-386(ra) # 80003d94 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f1e:	05c91703          	lh	a4,92(s2)
    80005f22:	4785                	li	a5,1
    80005f24:	f4f71ae3          	bne	a4,a5,80005e78 <sys_open+0x62>
    80005f28:	f4c42783          	lw	a5,-180(s0)
    80005f2c:	d3a5                	beqz	a5,80005e8c <sys_open+0x76>
      iunlockput(ip);
    80005f2e:	854a                	mv	a0,s2
    80005f30:	ffffe097          	auipc	ra,0xffffe
    80005f34:	0a2080e7          	jalr	162(ra) # 80003fd2 <iunlockput>
      end_op(ROOTDEV);
    80005f38:	4501                	li	a0,0
    80005f3a:	fffff097          	auipc	ra,0xfffff
    80005f3e:	8d6080e7          	jalr	-1834(ra) # 80004810 <end_op>
      return -1;
    80005f42:	54fd                	li	s1,-1
    80005f44:	b75d                	j	80005eea <sys_open+0xd4>
      end_op(ROOTDEV);
    80005f46:	4501                	li	a0,0
    80005f48:	fffff097          	auipc	ra,0xfffff
    80005f4c:	8c8080e7          	jalr	-1848(ra) # 80004810 <end_op>
      return -1;
    80005f50:	54fd                	li	s1,-1
    80005f52:	bf61                	j	80005eea <sys_open+0xd4>
    iunlockput(ip);
    80005f54:	854a                	mv	a0,s2
    80005f56:	ffffe097          	auipc	ra,0xffffe
    80005f5a:	07c080e7          	jalr	124(ra) # 80003fd2 <iunlockput>
    end_op(ROOTDEV);
    80005f5e:	4501                	li	a0,0
    80005f60:	fffff097          	auipc	ra,0xfffff
    80005f64:	8b0080e7          	jalr	-1872(ra) # 80004810 <end_op>
    return -1;
    80005f68:	54fd                	li	s1,-1
    80005f6a:	b741                	j	80005eea <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005f6c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005f70:	05e91783          	lh	a5,94(s2)
    80005f74:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005f78:	06091783          	lh	a5,96(s2)
    80005f7c:	02f99323          	sh	a5,38(s3)
    80005f80:	bf1d                	j	80005eb6 <sys_open+0xa0>
      fileclose(f);
    80005f82:	854e                	mv	a0,s3
    80005f84:	fffff097          	auipc	ra,0xfffff
    80005f88:	d6a080e7          	jalr	-662(ra) # 80004cee <fileclose>
    iunlockput(ip);
    80005f8c:	854a                	mv	a0,s2
    80005f8e:	ffffe097          	auipc	ra,0xffffe
    80005f92:	044080e7          	jalr	68(ra) # 80003fd2 <iunlockput>
    end_op(ROOTDEV);
    80005f96:	4501                	li	a0,0
    80005f98:	fffff097          	auipc	ra,0xfffff
    80005f9c:	878080e7          	jalr	-1928(ra) # 80004810 <end_op>
    return -1;
    80005fa0:	54fd                	li	s1,-1
    80005fa2:	b7a1                	j	80005eea <sys_open+0xd4>

0000000080005fa4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005fa4:	7175                	addi	sp,sp,-144
    80005fa6:	e506                	sd	ra,136(sp)
    80005fa8:	e122                	sd	s0,128(sp)
    80005faa:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005fac:	4501                	li	a0,0
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	7b6080e7          	jalr	1974(ra) # 80004764 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005fb6:	08000613          	li	a2,128
    80005fba:	f7040593          	addi	a1,s0,-144
    80005fbe:	4501                	li	a0,0
    80005fc0:	ffffd097          	auipc	ra,0xffffd
    80005fc4:	294080e7          	jalr	660(ra) # 80003254 <argstr>
    80005fc8:	02054a63          	bltz	a0,80005ffc <sys_mkdir+0x58>
    80005fcc:	4681                	li	a3,0
    80005fce:	4601                	li	a2,0
    80005fd0:	4585                	li	a1,1
    80005fd2:	f7040513          	addi	a0,s0,-144
    80005fd6:	fffff097          	auipc	ra,0xfffff
    80005fda:	7f4080e7          	jalr	2036(ra) # 800057ca <create>
    80005fde:	cd19                	beqz	a0,80005ffc <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005fe0:	ffffe097          	auipc	ra,0xffffe
    80005fe4:	ff2080e7          	jalr	-14(ra) # 80003fd2 <iunlockput>
  end_op(ROOTDEV);
    80005fe8:	4501                	li	a0,0
    80005fea:	fffff097          	auipc	ra,0xfffff
    80005fee:	826080e7          	jalr	-2010(ra) # 80004810 <end_op>
  return 0;
    80005ff2:	4501                	li	a0,0
}
    80005ff4:	60aa                	ld	ra,136(sp)
    80005ff6:	640a                	ld	s0,128(sp)
    80005ff8:	6149                	addi	sp,sp,144
    80005ffa:	8082                	ret
    end_op(ROOTDEV);
    80005ffc:	4501                	li	a0,0
    80005ffe:	fffff097          	auipc	ra,0xfffff
    80006002:	812080e7          	jalr	-2030(ra) # 80004810 <end_op>
    return -1;
    80006006:	557d                	li	a0,-1
    80006008:	b7f5                	j	80005ff4 <sys_mkdir+0x50>

000000008000600a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000600a:	7135                	addi	sp,sp,-160
    8000600c:	ed06                	sd	ra,152(sp)
    8000600e:	e922                	sd	s0,144(sp)
    80006010:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80006012:	4501                	li	a0,0
    80006014:	ffffe097          	auipc	ra,0xffffe
    80006018:	750080e7          	jalr	1872(ra) # 80004764 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000601c:	08000613          	li	a2,128
    80006020:	f7040593          	addi	a1,s0,-144
    80006024:	4501                	li	a0,0
    80006026:	ffffd097          	auipc	ra,0xffffd
    8000602a:	22e080e7          	jalr	558(ra) # 80003254 <argstr>
    8000602e:	04054b63          	bltz	a0,80006084 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80006032:	f6c40593          	addi	a1,s0,-148
    80006036:	4505                	li	a0,1
    80006038:	ffffd097          	auipc	ra,0xffffd
    8000603c:	1d8080e7          	jalr	472(ra) # 80003210 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006040:	04054263          	bltz	a0,80006084 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80006044:	f6840593          	addi	a1,s0,-152
    80006048:	4509                	li	a0,2
    8000604a:	ffffd097          	auipc	ra,0xffffd
    8000604e:	1c6080e7          	jalr	454(ra) # 80003210 <argint>
     argint(1, &major) < 0 ||
    80006052:	02054963          	bltz	a0,80006084 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006056:	f6841683          	lh	a3,-152(s0)
    8000605a:	f6c41603          	lh	a2,-148(s0)
    8000605e:	458d                	li	a1,3
    80006060:	f7040513          	addi	a0,s0,-144
    80006064:	fffff097          	auipc	ra,0xfffff
    80006068:	766080e7          	jalr	1894(ra) # 800057ca <create>
     argint(2, &minor) < 0 ||
    8000606c:	cd01                	beqz	a0,80006084 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    8000606e:	ffffe097          	auipc	ra,0xffffe
    80006072:	f64080e7          	jalr	-156(ra) # 80003fd2 <iunlockput>
  end_op(ROOTDEV);
    80006076:	4501                	li	a0,0
    80006078:	ffffe097          	auipc	ra,0xffffe
    8000607c:	798080e7          	jalr	1944(ra) # 80004810 <end_op>
  return 0;
    80006080:	4501                	li	a0,0
    80006082:	a039                	j	80006090 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80006084:	4501                	li	a0,0
    80006086:	ffffe097          	auipc	ra,0xffffe
    8000608a:	78a080e7          	jalr	1930(ra) # 80004810 <end_op>
    return -1;
    8000608e:	557d                	li	a0,-1
}
    80006090:	60ea                	ld	ra,152(sp)
    80006092:	644a                	ld	s0,144(sp)
    80006094:	610d                	addi	sp,sp,160
    80006096:	8082                	ret

0000000080006098 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006098:	7135                	addi	sp,sp,-160
    8000609a:	ed06                	sd	ra,152(sp)
    8000609c:	e922                	sd	s0,144(sp)
    8000609e:	e526                	sd	s1,136(sp)
    800060a0:	e14a                	sd	s2,128(sp)
    800060a2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060a4:	ffffc097          	auipc	ra,0xffffc
    800060a8:	ef8080e7          	jalr	-264(ra) # 80001f9c <myproc>
    800060ac:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    800060ae:	4501                	li	a0,0
    800060b0:	ffffe097          	auipc	ra,0xffffe
    800060b4:	6b4080e7          	jalr	1716(ra) # 80004764 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800060b8:	08000613          	li	a2,128
    800060bc:	f6040593          	addi	a1,s0,-160
    800060c0:	4501                	li	a0,0
    800060c2:	ffffd097          	auipc	ra,0xffffd
    800060c6:	192080e7          	jalr	402(ra) # 80003254 <argstr>
    800060ca:	04054c63          	bltz	a0,80006122 <sys_chdir+0x8a>
    800060ce:	f6040513          	addi	a0,s0,-160
    800060d2:	ffffe097          	auipc	ra,0xffffe
    800060d6:	44c080e7          	jalr	1100(ra) # 8000451e <namei>
    800060da:	84aa                	mv	s1,a0
    800060dc:	c139                	beqz	a0,80006122 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    800060de:	ffffe097          	auipc	ra,0xffffe
    800060e2:	cb6080e7          	jalr	-842(ra) # 80003d94 <ilock>
  if(ip->type != T_DIR){
    800060e6:	05c49703          	lh	a4,92(s1)
    800060ea:	4785                	li	a5,1
    800060ec:	04f71263          	bne	a4,a5,80006130 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    800060f0:	8526                	mv	a0,s1
    800060f2:	ffffe097          	auipc	ra,0xffffe
    800060f6:	d64080e7          	jalr	-668(ra) # 80003e56 <iunlock>
  iput(p->cwd);
    800060fa:	16893503          	ld	a0,360(s2)
    800060fe:	ffffe097          	auipc	ra,0xffffe
    80006102:	da4080e7          	jalr	-604(ra) # 80003ea2 <iput>
  end_op(ROOTDEV);
    80006106:	4501                	li	a0,0
    80006108:	ffffe097          	auipc	ra,0xffffe
    8000610c:	708080e7          	jalr	1800(ra) # 80004810 <end_op>
  p->cwd = ip;
    80006110:	16993423          	sd	s1,360(s2)
  return 0;
    80006114:	4501                	li	a0,0
}
    80006116:	60ea                	ld	ra,152(sp)
    80006118:	644a                	ld	s0,144(sp)
    8000611a:	64aa                	ld	s1,136(sp)
    8000611c:	690a                	ld	s2,128(sp)
    8000611e:	610d                	addi	sp,sp,160
    80006120:	8082                	ret
    end_op(ROOTDEV);
    80006122:	4501                	li	a0,0
    80006124:	ffffe097          	auipc	ra,0xffffe
    80006128:	6ec080e7          	jalr	1772(ra) # 80004810 <end_op>
    return -1;
    8000612c:	557d                	li	a0,-1
    8000612e:	b7e5                	j	80006116 <sys_chdir+0x7e>
    iunlockput(ip);
    80006130:	8526                	mv	a0,s1
    80006132:	ffffe097          	auipc	ra,0xffffe
    80006136:	ea0080e7          	jalr	-352(ra) # 80003fd2 <iunlockput>
    end_op(ROOTDEV);
    8000613a:	4501                	li	a0,0
    8000613c:	ffffe097          	auipc	ra,0xffffe
    80006140:	6d4080e7          	jalr	1748(ra) # 80004810 <end_op>
    return -1;
    80006144:	557d                	li	a0,-1
    80006146:	bfc1                	j	80006116 <sys_chdir+0x7e>

0000000080006148 <sys_exec>:

uint64
sys_exec(void)
{
    80006148:	7145                	addi	sp,sp,-464
    8000614a:	e786                	sd	ra,456(sp)
    8000614c:	e3a2                	sd	s0,448(sp)
    8000614e:	ff26                	sd	s1,440(sp)
    80006150:	fb4a                	sd	s2,432(sp)
    80006152:	f74e                	sd	s3,424(sp)
    80006154:	f352                	sd	s4,416(sp)
    80006156:	ef56                	sd	s5,408(sp)
    80006158:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000615a:	08000613          	li	a2,128
    8000615e:	f4040593          	addi	a1,s0,-192
    80006162:	4501                	li	a0,0
    80006164:	ffffd097          	auipc	ra,0xffffd
    80006168:	0f0080e7          	jalr	240(ra) # 80003254 <argstr>
    8000616c:	0e054663          	bltz	a0,80006258 <sys_exec+0x110>
    80006170:	e3840593          	addi	a1,s0,-456
    80006174:	4505                	li	a0,1
    80006176:	ffffd097          	auipc	ra,0xffffd
    8000617a:	0bc080e7          	jalr	188(ra) # 80003232 <argaddr>
    8000617e:	0e054763          	bltz	a0,8000626c <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80006182:	10000613          	li	a2,256
    80006186:	4581                	li	a1,0
    80006188:	e4040513          	addi	a0,s0,-448
    8000618c:	ffffb097          	auipc	ra,0xffffb
    80006190:	f48080e7          	jalr	-184(ra) # 800010d4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006194:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80006198:	89ca                	mv	s3,s2
    8000619a:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    8000619c:	02000a13          	li	s4,32
    800061a0:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061a4:	00349513          	slli	a0,s1,0x3
    800061a8:	e3040593          	addi	a1,s0,-464
    800061ac:	e3843783          	ld	a5,-456(s0)
    800061b0:	953e                	add	a0,a0,a5
    800061b2:	ffffd097          	auipc	ra,0xffffd
    800061b6:	fc4080e7          	jalr	-60(ra) # 80003176 <fetchaddr>
    800061ba:	02054a63          	bltz	a0,800061ee <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800061be:	e3043783          	ld	a5,-464(s0)
    800061c2:	c7a1                	beqz	a5,8000620a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800061c4:	ffffb097          	auipc	ra,0xffffb
    800061c8:	940080e7          	jalr	-1728(ra) # 80000b04 <kalloc>
    800061cc:	85aa                	mv	a1,a0
    800061ce:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800061d2:	c92d                	beqz	a0,80006244 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    800061d4:	6605                	lui	a2,0x1
    800061d6:	e3043503          	ld	a0,-464(s0)
    800061da:	ffffd097          	auipc	ra,0xffffd
    800061de:	fee080e7          	jalr	-18(ra) # 800031c8 <fetchstr>
    800061e2:	00054663          	bltz	a0,800061ee <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800061e6:	0485                	addi	s1,s1,1
    800061e8:	09a1                	addi	s3,s3,8
    800061ea:	fb449be3          	bne	s1,s4,800061a0 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061ee:	10090493          	addi	s1,s2,256
    800061f2:	00093503          	ld	a0,0(s2)
    800061f6:	cd39                	beqz	a0,80006254 <sys_exec+0x10c>
    kfree(argv[i]);
    800061f8:	ffffb097          	auipc	ra,0xffffb
    800061fc:	8f4080e7          	jalr	-1804(ra) # 80000aec <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006200:	0921                	addi	s2,s2,8
    80006202:	fe9918e3          	bne	s2,s1,800061f2 <sys_exec+0xaa>
  return -1;
    80006206:	557d                	li	a0,-1
    80006208:	a889                	j	8000625a <sys_exec+0x112>
      argv[i] = 0;
    8000620a:	0a8e                	slli	s5,s5,0x3
    8000620c:	fc040793          	addi	a5,s0,-64
    80006210:	9abe                	add	s5,s5,a5
    80006212:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006216:	e4040593          	addi	a1,s0,-448
    8000621a:	f4040513          	addi	a0,s0,-192
    8000621e:	fffff097          	auipc	ra,0xfffff
    80006222:	182080e7          	jalr	386(ra) # 800053a0 <exec>
    80006226:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006228:	10090993          	addi	s3,s2,256
    8000622c:	00093503          	ld	a0,0(s2)
    80006230:	c901                	beqz	a0,80006240 <sys_exec+0xf8>
    kfree(argv[i]);
    80006232:	ffffb097          	auipc	ra,0xffffb
    80006236:	8ba080e7          	jalr	-1862(ra) # 80000aec <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000623a:	0921                	addi	s2,s2,8
    8000623c:	ff3918e3          	bne	s2,s3,8000622c <sys_exec+0xe4>
  return ret;
    80006240:	8526                	mv	a0,s1
    80006242:	a821                	j	8000625a <sys_exec+0x112>
      panic("sys_exec kalloc");
    80006244:	00003517          	auipc	a0,0x3
    80006248:	a8450513          	addi	a0,a0,-1404 # 80008cc8 <userret+0xc38>
    8000624c:	ffffa097          	auipc	ra,0xffffa
    80006250:	50a080e7          	jalr	1290(ra) # 80000756 <panic>
  return -1;
    80006254:	557d                	li	a0,-1
    80006256:	a011                	j	8000625a <sys_exec+0x112>
    return -1;
    80006258:	557d                	li	a0,-1
}
    8000625a:	60be                	ld	ra,456(sp)
    8000625c:	641e                	ld	s0,448(sp)
    8000625e:	74fa                	ld	s1,440(sp)
    80006260:	795a                	ld	s2,432(sp)
    80006262:	79ba                	ld	s3,424(sp)
    80006264:	7a1a                	ld	s4,416(sp)
    80006266:	6afa                	ld	s5,408(sp)
    80006268:	6179                	addi	sp,sp,464
    8000626a:	8082                	ret
    return -1;
    8000626c:	557d                	li	a0,-1
    8000626e:	b7f5                	j	8000625a <sys_exec+0x112>

0000000080006270 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006270:	7139                	addi	sp,sp,-64
    80006272:	fc06                	sd	ra,56(sp)
    80006274:	f822                	sd	s0,48(sp)
    80006276:	f426                	sd	s1,40(sp)
    80006278:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000627a:	ffffc097          	auipc	ra,0xffffc
    8000627e:	d22080e7          	jalr	-734(ra) # 80001f9c <myproc>
    80006282:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006284:	fd840593          	addi	a1,s0,-40
    80006288:	4501                	li	a0,0
    8000628a:	ffffd097          	auipc	ra,0xffffd
    8000628e:	fa8080e7          	jalr	-88(ra) # 80003232 <argaddr>
    return -1;
    80006292:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006294:	0e054063          	bltz	a0,80006374 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006298:	fc840593          	addi	a1,s0,-56
    8000629c:	fd040513          	addi	a0,s0,-48
    800062a0:	fffff097          	auipc	ra,0xfffff
    800062a4:	db2080e7          	jalr	-590(ra) # 80005052 <pipealloc>
    return -1;
    800062a8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800062aa:	0c054563          	bltz	a0,80006374 <sys_pipe+0x104>
  fd0 = -1;
    800062ae:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800062b2:	fd043503          	ld	a0,-48(s0)
    800062b6:	fffff097          	auipc	ra,0xfffff
    800062ba:	4d2080e7          	jalr	1234(ra) # 80005788 <fdalloc>
    800062be:	fca42223          	sw	a0,-60(s0)
    800062c2:	08054c63          	bltz	a0,8000635a <sys_pipe+0xea>
    800062c6:	fc843503          	ld	a0,-56(s0)
    800062ca:	fffff097          	auipc	ra,0xfffff
    800062ce:	4be080e7          	jalr	1214(ra) # 80005788 <fdalloc>
    800062d2:	fca42023          	sw	a0,-64(s0)
    800062d6:	06054863          	bltz	a0,80006346 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062da:	4691                	li	a3,4
    800062dc:	fc440613          	addi	a2,s0,-60
    800062e0:	fd843583          	ld	a1,-40(s0)
    800062e4:	74a8                	ld	a0,104(s1)
    800062e6:	ffffc097          	auipc	ra,0xffffc
    800062ea:	8b8080e7          	jalr	-1864(ra) # 80001b9e <copyout>
    800062ee:	02054063          	bltz	a0,8000630e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800062f2:	4691                	li	a3,4
    800062f4:	fc040613          	addi	a2,s0,-64
    800062f8:	fd843583          	ld	a1,-40(s0)
    800062fc:	0591                	addi	a1,a1,4
    800062fe:	74a8                	ld	a0,104(s1)
    80006300:	ffffc097          	auipc	ra,0xffffc
    80006304:	89e080e7          	jalr	-1890(ra) # 80001b9e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006308:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000630a:	06055563          	bgez	a0,80006374 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    8000630e:	fc442783          	lw	a5,-60(s0)
    80006312:	07f1                	addi	a5,a5,28
    80006314:	078e                	slli	a5,a5,0x3
    80006316:	97a6                	add	a5,a5,s1
    80006318:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000631c:	fc042503          	lw	a0,-64(s0)
    80006320:	0571                	addi	a0,a0,28
    80006322:	050e                	slli	a0,a0,0x3
    80006324:	9526                	add	a0,a0,s1
    80006326:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000632a:	fd043503          	ld	a0,-48(s0)
    8000632e:	fffff097          	auipc	ra,0xfffff
    80006332:	9c0080e7          	jalr	-1600(ra) # 80004cee <fileclose>
    fileclose(wf);
    80006336:	fc843503          	ld	a0,-56(s0)
    8000633a:	fffff097          	auipc	ra,0xfffff
    8000633e:	9b4080e7          	jalr	-1612(ra) # 80004cee <fileclose>
    return -1;
    80006342:	57fd                	li	a5,-1
    80006344:	a805                	j	80006374 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006346:	fc442783          	lw	a5,-60(s0)
    8000634a:	0007c863          	bltz	a5,8000635a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000634e:	01c78513          	addi	a0,a5,28
    80006352:	050e                	slli	a0,a0,0x3
    80006354:	9526                	add	a0,a0,s1
    80006356:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000635a:	fd043503          	ld	a0,-48(s0)
    8000635e:	fffff097          	auipc	ra,0xfffff
    80006362:	990080e7          	jalr	-1648(ra) # 80004cee <fileclose>
    fileclose(wf);
    80006366:	fc843503          	ld	a0,-56(s0)
    8000636a:	fffff097          	auipc	ra,0xfffff
    8000636e:	984080e7          	jalr	-1660(ra) # 80004cee <fileclose>
    return -1;
    80006372:	57fd                	li	a5,-1
}
    80006374:	853e                	mv	a0,a5
    80006376:	70e2                	ld	ra,56(sp)
    80006378:	7442                	ld	s0,48(sp)
    8000637a:	74a2                	ld	s1,40(sp)
    8000637c:	6121                	addi	sp,sp,64
    8000637e:	8082                	ret

0000000080006380 <sys_create_mutex>:

uint64
sys_create_mutex(void)
{
    80006380:	1141                	addi	sp,sp,-16
    80006382:	e422                	sd	s0,8(sp)
    80006384:	0800                	addi	s0,sp,16
  return -1;
}
    80006386:	557d                	li	a0,-1
    80006388:	6422                	ld	s0,8(sp)
    8000638a:	0141                	addi	sp,sp,16
    8000638c:	8082                	ret

000000008000638e <sys_acquire_mutex>:

uint64
sys_acquire_mutex(void)
{
    8000638e:	1141                	addi	sp,sp,-16
    80006390:	e422                	sd	s0,8(sp)
    80006392:	0800                	addi	s0,sp,16
  return 0;
}
    80006394:	4501                	li	a0,0
    80006396:	6422                	ld	s0,8(sp)
    80006398:	0141                	addi	sp,sp,16
    8000639a:	8082                	ret

000000008000639c <sys_release_mutex>:

uint64
sys_release_mutex(void)
{
    8000639c:	1141                	addi	sp,sp,-16
    8000639e:	e422                	sd	s0,8(sp)
    800063a0:	0800                	addi	s0,sp,16

  return 0;
}
    800063a2:	4501                	li	a0,0
    800063a4:	6422                	ld	s0,8(sp)
    800063a6:	0141                	addi	sp,sp,16
    800063a8:	8082                	ret
    800063aa:	0000                	unimp
    800063ac:	0000                	unimp
	...

00000000800063b0 <kernelvec>:
    800063b0:	7111                	addi	sp,sp,-256
    800063b2:	e006                	sd	ra,0(sp)
    800063b4:	e40a                	sd	sp,8(sp)
    800063b6:	e80e                	sd	gp,16(sp)
    800063b8:	ec12                	sd	tp,24(sp)
    800063ba:	f016                	sd	t0,32(sp)
    800063bc:	f41a                	sd	t1,40(sp)
    800063be:	f81e                	sd	t2,48(sp)
    800063c0:	fc22                	sd	s0,56(sp)
    800063c2:	e0a6                	sd	s1,64(sp)
    800063c4:	e4aa                	sd	a0,72(sp)
    800063c6:	e8ae                	sd	a1,80(sp)
    800063c8:	ecb2                	sd	a2,88(sp)
    800063ca:	f0b6                	sd	a3,96(sp)
    800063cc:	f4ba                	sd	a4,104(sp)
    800063ce:	f8be                	sd	a5,112(sp)
    800063d0:	fcc2                	sd	a6,120(sp)
    800063d2:	e146                	sd	a7,128(sp)
    800063d4:	e54a                	sd	s2,136(sp)
    800063d6:	e94e                	sd	s3,144(sp)
    800063d8:	ed52                	sd	s4,152(sp)
    800063da:	f156                	sd	s5,160(sp)
    800063dc:	f55a                	sd	s6,168(sp)
    800063de:	f95e                	sd	s7,176(sp)
    800063e0:	fd62                	sd	s8,184(sp)
    800063e2:	e1e6                	sd	s9,192(sp)
    800063e4:	e5ea                	sd	s10,200(sp)
    800063e6:	e9ee                	sd	s11,208(sp)
    800063e8:	edf2                	sd	t3,216(sp)
    800063ea:	f1f6                	sd	t4,224(sp)
    800063ec:	f5fa                	sd	t5,232(sp)
    800063ee:	f9fe                	sd	t6,240(sp)
    800063f0:	c47fc0ef          	jal	ra,80003036 <kerneltrap>
    800063f4:	6082                	ld	ra,0(sp)
    800063f6:	6122                	ld	sp,8(sp)
    800063f8:	61c2                	ld	gp,16(sp)
    800063fa:	7282                	ld	t0,32(sp)
    800063fc:	7322                	ld	t1,40(sp)
    800063fe:	73c2                	ld	t2,48(sp)
    80006400:	7462                	ld	s0,56(sp)
    80006402:	6486                	ld	s1,64(sp)
    80006404:	6526                	ld	a0,72(sp)
    80006406:	65c6                	ld	a1,80(sp)
    80006408:	6666                	ld	a2,88(sp)
    8000640a:	7686                	ld	a3,96(sp)
    8000640c:	7726                	ld	a4,104(sp)
    8000640e:	77c6                	ld	a5,112(sp)
    80006410:	7866                	ld	a6,120(sp)
    80006412:	688a                	ld	a7,128(sp)
    80006414:	692a                	ld	s2,136(sp)
    80006416:	69ca                	ld	s3,144(sp)
    80006418:	6a6a                	ld	s4,152(sp)
    8000641a:	7a8a                	ld	s5,160(sp)
    8000641c:	7b2a                	ld	s6,168(sp)
    8000641e:	7bca                	ld	s7,176(sp)
    80006420:	7c6a                	ld	s8,184(sp)
    80006422:	6c8e                	ld	s9,192(sp)
    80006424:	6d2e                	ld	s10,200(sp)
    80006426:	6dce                	ld	s11,208(sp)
    80006428:	6e6e                	ld	t3,216(sp)
    8000642a:	7e8e                	ld	t4,224(sp)
    8000642c:	7f2e                	ld	t5,232(sp)
    8000642e:	7fce                	ld	t6,240(sp)
    80006430:	6111                	addi	sp,sp,256
    80006432:	10200073          	sret
    80006436:	00000013          	nop
    8000643a:	00000013          	nop
    8000643e:	0001                	nop

0000000080006440 <timervec>:
    80006440:	34051573          	csrrw	a0,mscratch,a0
    80006444:	e10c                	sd	a1,0(a0)
    80006446:	e510                	sd	a2,8(a0)
    80006448:	e914                	sd	a3,16(a0)
    8000644a:	710c                	ld	a1,32(a0)
    8000644c:	7510                	ld	a2,40(a0)
    8000644e:	6194                	ld	a3,0(a1)
    80006450:	96b2                	add	a3,a3,a2
    80006452:	e194                	sd	a3,0(a1)
    80006454:	4589                	li	a1,2
    80006456:	14459073          	csrw	sip,a1
    8000645a:	6914                	ld	a3,16(a0)
    8000645c:	6510                	ld	a2,8(a0)
    8000645e:	610c                	ld	a1,0(a0)
    80006460:	34051573          	csrrw	a0,mscratch,a0
    80006464:	30200073          	mret
	...

000000008000646a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000646a:	1141                	addi	sp,sp,-16
    8000646c:	e422                	sd	s0,8(sp)
    8000646e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006470:	0c0007b7          	lui	a5,0xc000
    80006474:	4705                	li	a4,1
    80006476:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006478:	c3d8                	sw	a4,4(a5)
}
    8000647a:	6422                	ld	s0,8(sp)
    8000647c:	0141                	addi	sp,sp,16
    8000647e:	8082                	ret

0000000080006480 <plicinithart>:

void
plicinithart(void)
{
    80006480:	1141                	addi	sp,sp,-16
    80006482:	e406                	sd	ra,8(sp)
    80006484:	e022                	sd	s0,0(sp)
    80006486:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006488:	ffffc097          	auipc	ra,0xffffc
    8000648c:	ae8080e7          	jalr	-1304(ra) # 80001f70 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006490:	0085171b          	slliw	a4,a0,0x8
    80006494:	0c0027b7          	lui	a5,0xc002
    80006498:	97ba                	add	a5,a5,a4
    8000649a:	40200713          	li	a4,1026
    8000649e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800064a2:	00d5151b          	slliw	a0,a0,0xd
    800064a6:	0c2017b7          	lui	a5,0xc201
    800064aa:	953e                	add	a0,a0,a5
    800064ac:	00052023          	sw	zero,0(a0)
}
    800064b0:	60a2                	ld	ra,8(sp)
    800064b2:	6402                	ld	s0,0(sp)
    800064b4:	0141                	addi	sp,sp,16
    800064b6:	8082                	ret

00000000800064b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800064b8:	1141                	addi	sp,sp,-16
    800064ba:	e406                	sd	ra,8(sp)
    800064bc:	e022                	sd	s0,0(sp)
    800064be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064c0:	ffffc097          	auipc	ra,0xffffc
    800064c4:	ab0080e7          	jalr	-1360(ra) # 80001f70 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800064c8:	00d5179b          	slliw	a5,a0,0xd
    800064cc:	0c201537          	lui	a0,0xc201
    800064d0:	953e                	add	a0,a0,a5
  return irq;
}
    800064d2:	4148                	lw	a0,4(a0)
    800064d4:	60a2                	ld	ra,8(sp)
    800064d6:	6402                	ld	s0,0(sp)
    800064d8:	0141                	addi	sp,sp,16
    800064da:	8082                	ret

00000000800064dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800064dc:	1101                	addi	sp,sp,-32
    800064de:	ec06                	sd	ra,24(sp)
    800064e0:	e822                	sd	s0,16(sp)
    800064e2:	e426                	sd	s1,8(sp)
    800064e4:	1000                	addi	s0,sp,32
    800064e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064e8:	ffffc097          	auipc	ra,0xffffc
    800064ec:	a88080e7          	jalr	-1400(ra) # 80001f70 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064f0:	00d5151b          	slliw	a0,a0,0xd
    800064f4:	0c2017b7          	lui	a5,0xc201
    800064f8:	97aa                	add	a5,a5,a0
    800064fa:	c3c4                	sw	s1,4(a5)
}
    800064fc:	60e2                	ld	ra,24(sp)
    800064fe:	6442                	ld	s0,16(sp)
    80006500:	64a2                	ld	s1,8(sp)
    80006502:	6105                	addi	sp,sp,32
    80006504:	8082                	ret

0000000080006506 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006506:	1141                	addi	sp,sp,-16
    80006508:	e406                	sd	ra,8(sp)
    8000650a:	e022                	sd	s0,0(sp)
    8000650c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000650e:	479d                	li	a5,7
    80006510:	06b7c963          	blt	a5,a1,80006582 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006514:	00151793          	slli	a5,a0,0x1
    80006518:	97aa                	add	a5,a5,a0
    8000651a:	00c79713          	slli	a4,a5,0xc
    8000651e:	00022797          	auipc	a5,0x22
    80006522:	ae278793          	addi	a5,a5,-1310 # 80028000 <disk>
    80006526:	97ba                	add	a5,a5,a4
    80006528:	97ae                	add	a5,a5,a1
    8000652a:	6709                	lui	a4,0x2
    8000652c:	97ba                	add	a5,a5,a4
    8000652e:	0187c783          	lbu	a5,24(a5)
    80006532:	e3a5                	bnez	a5,80006592 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006534:	00022817          	auipc	a6,0x22
    80006538:	acc80813          	addi	a6,a6,-1332 # 80028000 <disk>
    8000653c:	00151693          	slli	a3,a0,0x1
    80006540:	00a68733          	add	a4,a3,a0
    80006544:	0732                	slli	a4,a4,0xc
    80006546:	00e807b3          	add	a5,a6,a4
    8000654a:	6709                	lui	a4,0x2
    8000654c:	00f70633          	add	a2,a4,a5
    80006550:	6210                	ld	a2,0(a2)
    80006552:	00459893          	slli	a7,a1,0x4
    80006556:	9646                	add	a2,a2,a7
    80006558:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    8000655c:	97ae                	add	a5,a5,a1
    8000655e:	97ba                	add	a5,a5,a4
    80006560:	4605                	li	a2,1
    80006562:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80006566:	96aa                	add	a3,a3,a0
    80006568:	06b2                	slli	a3,a3,0xc
    8000656a:	0761                	addi	a4,a4,24
    8000656c:	96ba                	add	a3,a3,a4
    8000656e:	00d80533          	add	a0,a6,a3
    80006572:	ffffc097          	auipc	ra,0xffffc
    80006576:	3de080e7          	jalr	990(ra) # 80002950 <wakeup>
}
    8000657a:	60a2                	ld	ra,8(sp)
    8000657c:	6402                	ld	s0,0(sp)
    8000657e:	0141                	addi	sp,sp,16
    80006580:	8082                	ret
    panic("virtio_disk_intr 1");
    80006582:	00002517          	auipc	a0,0x2
    80006586:	75650513          	addi	a0,a0,1878 # 80008cd8 <userret+0xc48>
    8000658a:	ffffa097          	auipc	ra,0xffffa
    8000658e:	1cc080e7          	jalr	460(ra) # 80000756 <panic>
    panic("virtio_disk_intr 2");
    80006592:	00002517          	auipc	a0,0x2
    80006596:	75e50513          	addi	a0,a0,1886 # 80008cf0 <userret+0xc60>
    8000659a:	ffffa097          	auipc	ra,0xffffa
    8000659e:	1bc080e7          	jalr	444(ra) # 80000756 <panic>

00000000800065a2 <virtio_disk_init>:
  __sync_synchronize();
    800065a2:	0ff0000f          	fence
  if(disk[n].init)
    800065a6:	00151793          	slli	a5,a0,0x1
    800065aa:	97aa                	add	a5,a5,a0
    800065ac:	07b2                	slli	a5,a5,0xc
    800065ae:	00022717          	auipc	a4,0x22
    800065b2:	a5270713          	addi	a4,a4,-1454 # 80028000 <disk>
    800065b6:	973e                	add	a4,a4,a5
    800065b8:	6789                	lui	a5,0x2
    800065ba:	97ba                	add	a5,a5,a4
    800065bc:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    800065c0:	c391                	beqz	a5,800065c4 <virtio_disk_init+0x22>
    800065c2:	8082                	ret
{
    800065c4:	7139                	addi	sp,sp,-64
    800065c6:	fc06                	sd	ra,56(sp)
    800065c8:	f822                	sd	s0,48(sp)
    800065ca:	f426                	sd	s1,40(sp)
    800065cc:	f04a                	sd	s2,32(sp)
    800065ce:	ec4e                	sd	s3,24(sp)
    800065d0:	e852                	sd	s4,16(sp)
    800065d2:	e456                	sd	s5,8(sp)
    800065d4:	0080                	addi	s0,sp,64
    800065d6:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    800065d8:	85aa                	mv	a1,a0
    800065da:	00002517          	auipc	a0,0x2
    800065de:	72e50513          	addi	a0,a0,1838 # 80008d08 <userret+0xc78>
    800065e2:	ffffa097          	auipc	ra,0xffffa
    800065e6:	38a080e7          	jalr	906(ra) # 8000096c <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    800065ea:	00149993          	slli	s3,s1,0x1
    800065ee:	99a6                	add	s3,s3,s1
    800065f0:	09b2                	slli	s3,s3,0xc
    800065f2:	6789                	lui	a5,0x2
    800065f4:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    800065f8:	97ce                	add	a5,a5,s3
    800065fa:	00002597          	auipc	a1,0x2
    800065fe:	72658593          	addi	a1,a1,1830 # 80008d20 <userret+0xc90>
    80006602:	00022517          	auipc	a0,0x22
    80006606:	9fe50513          	addi	a0,a0,-1538 # 80028000 <disk>
    8000660a:	953e                	add	a0,a0,a5
    8000660c:	ffffa097          	auipc	ra,0xffffa
    80006610:	512080e7          	jalr	1298(ra) # 80000b1e <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006614:	0014891b          	addiw	s2,s1,1
    80006618:	00c9191b          	slliw	s2,s2,0xc
    8000661c:	100007b7          	lui	a5,0x10000
    80006620:	97ca                	add	a5,a5,s2
    80006622:	4398                	lw	a4,0(a5)
    80006624:	2701                	sext.w	a4,a4
    80006626:	747277b7          	lui	a5,0x74727
    8000662a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000662e:	12f71863          	bne	a4,a5,8000675e <virtio_disk_init+0x1bc>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006632:	100007b7          	lui	a5,0x10000
    80006636:	0791                	addi	a5,a5,4
    80006638:	97ca                	add	a5,a5,s2
    8000663a:	439c                	lw	a5,0(a5)
    8000663c:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000663e:	4705                	li	a4,1
    80006640:	10e79f63          	bne	a5,a4,8000675e <virtio_disk_init+0x1bc>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006644:	100007b7          	lui	a5,0x10000
    80006648:	07a1                	addi	a5,a5,8
    8000664a:	97ca                	add	a5,a5,s2
    8000664c:	439c                	lw	a5,0(a5)
    8000664e:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006650:	4709                	li	a4,2
    80006652:	10e79663          	bne	a5,a4,8000675e <virtio_disk_init+0x1bc>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006656:	100007b7          	lui	a5,0x10000
    8000665a:	07b1                	addi	a5,a5,12
    8000665c:	97ca                	add	a5,a5,s2
    8000665e:	4398                	lw	a4,0(a5)
    80006660:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006662:	554d47b7          	lui	a5,0x554d4
    80006666:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000666a:	0ef71a63          	bne	a4,a5,8000675e <virtio_disk_init+0x1bc>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000666e:	100007b7          	lui	a5,0x10000
    80006672:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80006676:	96ca                	add	a3,a3,s2
    80006678:	4705                	li	a4,1
    8000667a:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000667c:	470d                	li	a4,3
    8000667e:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80006680:	01078713          	addi	a4,a5,16
    80006684:	974a                	add	a4,a4,s2
    80006686:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006688:	02078613          	addi	a2,a5,32
    8000668c:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000668e:	c7ffe737          	lui	a4,0xc7ffe
    80006692:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd06b3>
    80006696:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006698:	2701                	sext.w	a4,a4
    8000669a:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000669c:	472d                	li	a4,11
    8000669e:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800066a0:	473d                	li	a4,15
    800066a2:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800066a4:	02878713          	addi	a4,a5,40
    800066a8:	974a                	add	a4,a4,s2
    800066aa:	6685                	lui	a3,0x1
    800066ac:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    800066ae:	03078713          	addi	a4,a5,48
    800066b2:	974a                	add	a4,a4,s2
    800066b4:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    800066b8:	03478793          	addi	a5,a5,52
    800066bc:	97ca                	add	a5,a5,s2
    800066be:	439c                	lw	a5,0(a5)
    800066c0:	2781                	sext.w	a5,a5
  if(max == 0)
    800066c2:	c7d5                	beqz	a5,8000676e <virtio_disk_init+0x1cc>
  if(max < NUM)
    800066c4:	471d                	li	a4,7
    800066c6:	0af77c63          	bgeu	a4,a5,8000677e <virtio_disk_init+0x1dc>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800066ca:	10000ab7          	lui	s5,0x10000
    800066ce:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    800066d2:	97ca                	add	a5,a5,s2
    800066d4:	4721                	li	a4,8
    800066d6:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    800066d8:	00022a17          	auipc	s4,0x22
    800066dc:	928a0a13          	addi	s4,s4,-1752 # 80028000 <disk>
    800066e0:	99d2                	add	s3,s3,s4
    800066e2:	6609                	lui	a2,0x2
    800066e4:	4581                	li	a1,0
    800066e6:	854e                	mv	a0,s3
    800066e8:	ffffb097          	auipc	ra,0xffffb
    800066ec:	9ec080e7          	jalr	-1556(ra) # 800010d4 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    800066f0:	040a8a93          	addi	s5,s5,64
    800066f4:	9956                	add	s2,s2,s5
    800066f6:	00c9d793          	srli	a5,s3,0xc
    800066fa:	2781                	sext.w	a5,a5
    800066fc:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80006700:	00149513          	slli	a0,s1,0x1
    80006704:	009507b3          	add	a5,a0,s1
    80006708:	07b2                	slli	a5,a5,0xc
    8000670a:	97d2                	add	a5,a5,s4
    8000670c:	6689                	lui	a3,0x2
    8000670e:	97b6                	add	a5,a5,a3
    80006710:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006714:	08098713          	addi	a4,s3,128
    80006718:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    8000671a:	6705                	lui	a4,0x1
    8000671c:	99ba                	add	s3,s3,a4
    8000671e:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006722:	4705                	li	a4,1
    80006724:	00e78c23          	sb	a4,24(a5)
    80006728:	00e78ca3          	sb	a4,25(a5)
    8000672c:	00e78d23          	sb	a4,26(a5)
    80006730:	00e78da3          	sb	a4,27(a5)
    80006734:	00e78e23          	sb	a4,28(a5)
    80006738:	00e78ea3          	sb	a4,29(a5)
    8000673c:	00e78f23          	sb	a4,30(a5)
    80006740:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006744:	853e                	mv	a0,a5
    80006746:	4785                	li	a5,1
    80006748:	0af52423          	sw	a5,168(a0)
}
    8000674c:	70e2                	ld	ra,56(sp)
    8000674e:	7442                	ld	s0,48(sp)
    80006750:	74a2                	ld	s1,40(sp)
    80006752:	7902                	ld	s2,32(sp)
    80006754:	69e2                	ld	s3,24(sp)
    80006756:	6a42                	ld	s4,16(sp)
    80006758:	6aa2                	ld	s5,8(sp)
    8000675a:	6121                	addi	sp,sp,64
    8000675c:	8082                	ret
    panic("could not find virtio disk");
    8000675e:	00002517          	auipc	a0,0x2
    80006762:	5d250513          	addi	a0,a0,1490 # 80008d30 <userret+0xca0>
    80006766:	ffffa097          	auipc	ra,0xffffa
    8000676a:	ff0080e7          	jalr	-16(ra) # 80000756 <panic>
    panic("virtio disk has no queue 0");
    8000676e:	00002517          	auipc	a0,0x2
    80006772:	5e250513          	addi	a0,a0,1506 # 80008d50 <userret+0xcc0>
    80006776:	ffffa097          	auipc	ra,0xffffa
    8000677a:	fe0080e7          	jalr	-32(ra) # 80000756 <panic>
    panic("virtio disk max queue too short");
    8000677e:	00002517          	auipc	a0,0x2
    80006782:	5f250513          	addi	a0,a0,1522 # 80008d70 <userret+0xce0>
    80006786:	ffffa097          	auipc	ra,0xffffa
    8000678a:	fd0080e7          	jalr	-48(ra) # 80000756 <panic>

000000008000678e <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    8000678e:	7135                	addi	sp,sp,-160
    80006790:	ed06                	sd	ra,152(sp)
    80006792:	e922                	sd	s0,144(sp)
    80006794:	e526                	sd	s1,136(sp)
    80006796:	e14a                	sd	s2,128(sp)
    80006798:	fcce                	sd	s3,120(sp)
    8000679a:	f8d2                	sd	s4,112(sp)
    8000679c:	f4d6                	sd	s5,104(sp)
    8000679e:	f0da                	sd	s6,96(sp)
    800067a0:	ecde                	sd	s7,88(sp)
    800067a2:	e8e2                	sd	s8,80(sp)
    800067a4:	e4e6                	sd	s9,72(sp)
    800067a6:	e0ea                	sd	s10,64(sp)
    800067a8:	fc6e                	sd	s11,56(sp)
    800067aa:	1100                	addi	s0,sp,160
    800067ac:	892a                	mv	s2,a0
    800067ae:	89ae                	mv	s3,a1
    800067b0:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    800067b2:	45dc                	lw	a5,12(a1)
    800067b4:	0017979b          	slliw	a5,a5,0x1
    800067b8:	1782                	slli	a5,a5,0x20
    800067ba:	9381                	srli	a5,a5,0x20
    800067bc:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    800067c0:	00151493          	slli	s1,a0,0x1
    800067c4:	94aa                	add	s1,s1,a0
    800067c6:	04b2                	slli	s1,s1,0xc
    800067c8:	6a89                	lui	s5,0x2
    800067ca:	0b0a8a13          	addi	s4,s5,176 # 20b0 <_entry-0x7fffdf50>
    800067ce:	9a26                	add	s4,s4,s1
    800067d0:	00022b97          	auipc	s7,0x22
    800067d4:	830b8b93          	addi	s7,s7,-2000 # 80028000 <disk>
    800067d8:	9a5e                	add	s4,s4,s7
    800067da:	8552                	mv	a0,s4
    800067dc:	ffffa097          	auipc	ra,0xffffa
    800067e0:	4ac080e7          	jalr	1196(ra) # 80000c88 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800067e4:	0ae1                	addi	s5,s5,24
    800067e6:	94d6                	add	s1,s1,s5
    800067e8:	01748ab3          	add	s5,s1,s7
    800067ec:	8d56                	mv	s10,s5
  for(int i = 0; i < 3; i++){
    800067ee:	4b81                	li	s7,0
  for(int i = 0; i < NUM; i++){
    800067f0:	4ca1                	li	s9,8
      disk[n].free[i] = 0;
    800067f2:	00191b13          	slli	s6,s2,0x1
    800067f6:	9b4a                	add	s6,s6,s2
    800067f8:	00cb1793          	slli	a5,s6,0xc
    800067fc:	00022b17          	auipc	s6,0x22
    80006800:	804b0b13          	addi	s6,s6,-2044 # 80028000 <disk>
    80006804:	9b3e                	add	s6,s6,a5
  for(int i = 0; i < NUM; i++){
    80006806:	8c5e                	mv	s8,s7
    80006808:	a8ad                	j	80006882 <virtio_disk_rw+0xf4>
      disk[n].free[i] = 0;
    8000680a:	00fb06b3          	add	a3,s6,a5
    8000680e:	96aa                	add	a3,a3,a0
    80006810:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    80006814:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006816:	0207c363          	bltz	a5,8000683c <virtio_disk_rw+0xae>
  for(int i = 0; i < 3; i++){
    8000681a:	2485                	addiw	s1,s1,1
    8000681c:	0711                	addi	a4,a4,4
    8000681e:	26b48f63          	beq	s1,a1,80006a9c <virtio_disk_rw+0x30e>
    idx[i] = alloc_desc(n);
    80006822:	863a                	mv	a2,a4
    80006824:	86ea                	mv	a3,s10
  for(int i = 0; i < NUM; i++){
    80006826:	87e2                	mv	a5,s8
    if(disk[n].free[i]){
    80006828:	0006c803          	lbu	a6,0(a3)
    8000682c:	fc081fe3          	bnez	a6,8000680a <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    80006830:	2785                	addiw	a5,a5,1
    80006832:	0685                	addi	a3,a3,1
    80006834:	ff979ae3          	bne	a5,s9,80006828 <virtio_disk_rw+0x9a>
    idx[i] = alloc_desc(n);
    80006838:	57fd                	li	a5,-1
    8000683a:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000683c:	02905d63          	blez	s1,80006876 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006840:	f8042583          	lw	a1,-128(s0)
    80006844:	854a                	mv	a0,s2
    80006846:	00000097          	auipc	ra,0x0
    8000684a:	cc0080e7          	jalr	-832(ra) # 80006506 <free_desc>
      for(int j = 0; j < i; j++)
    8000684e:	4785                	li	a5,1
    80006850:	0297d363          	bge	a5,s1,80006876 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006854:	f8442583          	lw	a1,-124(s0)
    80006858:	854a                	mv	a0,s2
    8000685a:	00000097          	auipc	ra,0x0
    8000685e:	cac080e7          	jalr	-852(ra) # 80006506 <free_desc>
      for(int j = 0; j < i; j++)
    80006862:	4789                	li	a5,2
    80006864:	0097d963          	bge	a5,s1,80006876 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006868:	f8842583          	lw	a1,-120(s0)
    8000686c:	854a                	mv	a0,s2
    8000686e:	00000097          	auipc	ra,0x0
    80006872:	c98080e7          	jalr	-872(ra) # 80006506 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006876:	85d2                	mv	a1,s4
    80006878:	8556                	mv	a0,s5
    8000687a:	ffffc097          	auipc	ra,0xffffc
    8000687e:	f50080e7          	jalr	-176(ra) # 800027ca <sleep>
  for(int i = 0; i < 3; i++){
    80006882:	f8040713          	addi	a4,s0,-128
    80006886:	84de                	mv	s1,s7
      disk[n].free[i] = 0;
    80006888:	6509                	lui	a0,0x2
  for(int i = 0; i < 3; i++){
    8000688a:	458d                	li	a1,3
    8000688c:	bf59                	j	80006822 <virtio_disk_rw+0x94>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    8000688e:	4785                	li	a5,1
    80006890:	f6f42823          	sw	a5,-144(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    80006894:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006898:	f6843783          	ld	a5,-152(s0)
    8000689c:	f6f43c23          	sd	a5,-136(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800068a0:	f8042483          	lw	s1,-128(s0)
    800068a4:	00449b13          	slli	s6,s1,0x4
    800068a8:	00191793          	slli	a5,s2,0x1
    800068ac:	97ca                	add	a5,a5,s2
    800068ae:	07b2                	slli	a5,a5,0xc
    800068b0:	00021a97          	auipc	s5,0x21
    800068b4:	750a8a93          	addi	s5,s5,1872 # 80028000 <disk>
    800068b8:	97d6                	add	a5,a5,s5
    800068ba:	6a89                	lui	s5,0x2
    800068bc:	9abe                	add	s5,s5,a5
    800068be:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    800068c2:	9bda                	add	s7,s7,s6
    800068c4:	f7040513          	addi	a0,s0,-144
    800068c8:	ffffb097          	auipc	ra,0xffffb
    800068cc:	d36080e7          	jalr	-714(ra) # 800015fe <kvmpa>
    800068d0:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    800068d4:	000ab783          	ld	a5,0(s5)
    800068d8:	97da                	add	a5,a5,s6
    800068da:	4741                	li	a4,16
    800068dc:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800068de:	000ab783          	ld	a5,0(s5)
    800068e2:	97da                	add	a5,a5,s6
    800068e4:	4705                	li	a4,1
    800068e6:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    800068ea:	f8442683          	lw	a3,-124(s0)
    800068ee:	000ab783          	ld	a5,0(s5)
    800068f2:	9b3e                	add	s6,s6,a5
    800068f4:	00db1723          	sh	a3,14(s6)

  disk[n].desc[idx[1]].addr = (uint64) b->data;
    800068f8:	0692                	slli	a3,a3,0x4
    800068fa:	000ab783          	ld	a5,0(s5)
    800068fe:	97b6                	add	a5,a5,a3
    80006900:	07098713          	addi	a4,s3,112
    80006904:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006906:	000ab783          	ld	a5,0(s5)
    8000690a:	97b6                	add	a5,a5,a3
    8000690c:	40000713          	li	a4,1024
    80006910:	c798                	sw	a4,8(a5)
  if(write)
    80006912:	140d8063          	beqz	s11,80006a52 <virtio_disk_rw+0x2c4>
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006916:	000ab783          	ld	a5,0(s5)
    8000691a:	97b6                	add	a5,a5,a3
    8000691c:	00079623          	sh	zero,12(a5)
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006920:	00021517          	auipc	a0,0x21
    80006924:	6e050513          	addi	a0,a0,1760 # 80028000 <disk>
    80006928:	00191793          	slli	a5,s2,0x1
    8000692c:	01278733          	add	a4,a5,s2
    80006930:	0732                	slli	a4,a4,0xc
    80006932:	972a                	add	a4,a4,a0
    80006934:	6609                	lui	a2,0x2
    80006936:	9732                	add	a4,a4,a2
    80006938:	630c                	ld	a1,0(a4)
    8000693a:	95b6                	add	a1,a1,a3
    8000693c:	00c5d603          	lhu	a2,12(a1)
    80006940:	00166613          	ori	a2,a2,1
    80006944:	00c59623          	sh	a2,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    80006948:	f8842603          	lw	a2,-120(s0)
    8000694c:	630c                	ld	a1,0(a4)
    8000694e:	96ae                	add	a3,a3,a1
    80006950:	00c69723          	sh	a2,14(a3)

  disk[n].info[idx[0]].status = 0;
    80006954:	97ca                	add	a5,a5,s2
    80006956:	07a2                	slli	a5,a5,0x8
    80006958:	97a6                	add	a5,a5,s1
    8000695a:	20078793          	addi	a5,a5,512
    8000695e:	0792                	slli	a5,a5,0x4
    80006960:	97aa                	add	a5,a5,a0
    80006962:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006966:	00461693          	slli	a3,a2,0x4
    8000696a:	00073803          	ld	a6,0(a4) # 1000 <_entry-0x7ffff000>
    8000696e:	9836                	add	a6,a6,a3
    80006970:	20348613          	addi	a2,s1,515
    80006974:	00191593          	slli	a1,s2,0x1
    80006978:	95ca                	add	a1,a1,s2
    8000697a:	05a2                	slli	a1,a1,0x8
    8000697c:	962e                	add	a2,a2,a1
    8000697e:	0612                	slli	a2,a2,0x4
    80006980:	962a                	add	a2,a2,a0
    80006982:	00c83023          	sd	a2,0(a6)
  disk[n].desc[idx[2]].len = 1;
    80006986:	6310                	ld	a2,0(a4)
    80006988:	9636                	add	a2,a2,a3
    8000698a:	4585                	li	a1,1
    8000698c:	c60c                	sw	a1,8(a2)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000698e:	6310                	ld	a2,0(a4)
    80006990:	9636                	add	a2,a2,a3
    80006992:	4509                	li	a0,2
    80006994:	00a61623          	sh	a0,12(a2) # 200c <_entry-0x7fffdff4>
  disk[n].desc[idx[2]].next = 0;
    80006998:	6310                	ld	a2,0(a4)
    8000699a:	96b2                	add	a3,a3,a2
    8000699c:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800069a0:	00b9a223          	sw	a1,4(s3)
  disk[n].info[idx[0]].b = b;
    800069a4:	0337b423          	sd	s3,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    800069a8:	6714                	ld	a3,8(a4)
    800069aa:	0026d783          	lhu	a5,2(a3)
    800069ae:	8b9d                	andi	a5,a5,7
    800069b0:	2789                	addiw	a5,a5,2
    800069b2:	0786                	slli	a5,a5,0x1
    800069b4:	97b6                	add	a5,a5,a3
    800069b6:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800069ba:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    800069be:	6718                	ld	a4,8(a4)
    800069c0:	00275783          	lhu	a5,2(a4)
    800069c4:	2785                	addiw	a5,a5,1
    800069c6:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800069ca:	0019079b          	addiw	a5,s2,1
    800069ce:	00c7979b          	slliw	a5,a5,0xc
    800069d2:	10000737          	lui	a4,0x10000
    800069d6:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    800069da:	97ba                	add	a5,a5,a4
    800069dc:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800069e0:	0049a703          	lw	a4,4(s3)
    800069e4:	4785                	li	a5,1
    800069e6:	00f71d63          	bne	a4,a5,80006a00 <virtio_disk_rw+0x272>
    800069ea:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    800069ec:	85d2                	mv	a1,s4
    800069ee:	854e                	mv	a0,s3
    800069f0:	ffffc097          	auipc	ra,0xffffc
    800069f4:	dda080e7          	jalr	-550(ra) # 800027ca <sleep>
  while(b->disk == 1) {
    800069f8:	0049a783          	lw	a5,4(s3)
    800069fc:	fe9788e3          	beq	a5,s1,800069ec <virtio_disk_rw+0x25e>
  }

  disk[n].info[idx[0]].b = 0;
    80006a00:	f8042483          	lw	s1,-128(s0)
    80006a04:	00191793          	slli	a5,s2,0x1
    80006a08:	97ca                	add	a5,a5,s2
    80006a0a:	07a2                	slli	a5,a5,0x8
    80006a0c:	97a6                	add	a5,a5,s1
    80006a0e:	20078793          	addi	a5,a5,512
    80006a12:	0792                	slli	a5,a5,0x4
    80006a14:	00021717          	auipc	a4,0x21
    80006a18:	5ec70713          	addi	a4,a4,1516 # 80028000 <disk>
    80006a1c:	97ba                	add	a5,a5,a4
    80006a1e:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006a22:	00191793          	slli	a5,s2,0x1
    80006a26:	97ca                	add	a5,a5,s2
    80006a28:	07b2                	slli	a5,a5,0xc
    80006a2a:	97ba                	add	a5,a5,a4
    80006a2c:	6989                	lui	s3,0x2
    80006a2e:	99be                	add	s3,s3,a5
    free_desc(n, i);
    80006a30:	85a6                	mv	a1,s1
    80006a32:	854a                	mv	a0,s2
    80006a34:	00000097          	auipc	ra,0x0
    80006a38:	ad2080e7          	jalr	-1326(ra) # 80006506 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006a3c:	0492                	slli	s1,s1,0x4
    80006a3e:	0009b783          	ld	a5,0(s3) # 2000 <_entry-0x7fffe000>
    80006a42:	94be                	add	s1,s1,a5
    80006a44:	00c4d783          	lhu	a5,12(s1)
    80006a48:	8b85                	andi	a5,a5,1
    80006a4a:	c78d                	beqz	a5,80006a74 <virtio_disk_rw+0x2e6>
      i = disk[n].desc[i].next;
    80006a4c:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006a50:	b7c5                	j	80006a30 <virtio_disk_rw+0x2a2>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006a52:	00191793          	slli	a5,s2,0x1
    80006a56:	97ca                	add	a5,a5,s2
    80006a58:	07b2                	slli	a5,a5,0xc
    80006a5a:	00021717          	auipc	a4,0x21
    80006a5e:	5a670713          	addi	a4,a4,1446 # 80028000 <disk>
    80006a62:	973e                	add	a4,a4,a5
    80006a64:	6789                	lui	a5,0x2
    80006a66:	97ba                	add	a5,a5,a4
    80006a68:	639c                	ld	a5,0(a5)
    80006a6a:	97b6                	add	a5,a5,a3
    80006a6c:	4709                	li	a4,2
    80006a6e:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006a72:	b57d                	j	80006920 <virtio_disk_rw+0x192>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006a74:	8552                	mv	a0,s4
    80006a76:	ffffa097          	auipc	ra,0xffffa
    80006a7a:	45e080e7          	jalr	1118(ra) # 80000ed4 <release>
}
    80006a7e:	60ea                	ld	ra,152(sp)
    80006a80:	644a                	ld	s0,144(sp)
    80006a82:	64aa                	ld	s1,136(sp)
    80006a84:	690a                	ld	s2,128(sp)
    80006a86:	79e6                	ld	s3,120(sp)
    80006a88:	7a46                	ld	s4,112(sp)
    80006a8a:	7aa6                	ld	s5,104(sp)
    80006a8c:	7b06                	ld	s6,96(sp)
    80006a8e:	6be6                	ld	s7,88(sp)
    80006a90:	6c46                	ld	s8,80(sp)
    80006a92:	6ca6                	ld	s9,72(sp)
    80006a94:	6d06                	ld	s10,64(sp)
    80006a96:	7de2                	ld	s11,56(sp)
    80006a98:	610d                	addi	sp,sp,160
    80006a9a:	8082                	ret
  if(write)
    80006a9c:	de0d99e3          	bnez	s11,8000688e <virtio_disk_rw+0x100>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006aa0:	f6042823          	sw	zero,-144(s0)
    80006aa4:	bbc5                	j	80006894 <virtio_disk_rw+0x106>

0000000080006aa6 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006aa6:	7139                	addi	sp,sp,-64
    80006aa8:	fc06                	sd	ra,56(sp)
    80006aaa:	f822                	sd	s0,48(sp)
    80006aac:	f426                	sd	s1,40(sp)
    80006aae:	f04a                	sd	s2,32(sp)
    80006ab0:	ec4e                	sd	s3,24(sp)
    80006ab2:	e852                	sd	s4,16(sp)
    80006ab4:	e456                	sd	s5,8(sp)
    80006ab6:	0080                	addi	s0,sp,64
    80006ab8:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006aba:	00151913          	slli	s2,a0,0x1
    80006abe:	00a90a33          	add	s4,s2,a0
    80006ac2:	0a32                	slli	s4,s4,0xc
    80006ac4:	6989                	lui	s3,0x2
    80006ac6:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006aca:	9a3e                	add	s4,s4,a5
    80006acc:	00021a97          	auipc	s5,0x21
    80006ad0:	534a8a93          	addi	s5,s5,1332 # 80028000 <disk>
    80006ad4:	9a56                	add	s4,s4,s5
    80006ad6:	8552                	mv	a0,s4
    80006ad8:	ffffa097          	auipc	ra,0xffffa
    80006adc:	1b0080e7          	jalr	432(ra) # 80000c88 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006ae0:	9926                	add	s2,s2,s1
    80006ae2:	0932                	slli	s2,s2,0xc
    80006ae4:	9956                	add	s2,s2,s5
    80006ae6:	99ca                	add	s3,s3,s2
    80006ae8:	0209d783          	lhu	a5,32(s3)
    80006aec:	0109b703          	ld	a4,16(s3)
    80006af0:	00275683          	lhu	a3,2(a4)
    80006af4:	8ebd                	xor	a3,a3,a5
    80006af6:	8a9d                	andi	a3,a3,7
    80006af8:	c2a5                	beqz	a3,80006b58 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    80006afa:	8956                	mv	s2,s5
    80006afc:	00149693          	slli	a3,s1,0x1
    80006b00:	96a6                	add	a3,a3,s1
    80006b02:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006b06:	06b2                	slli	a3,a3,0xc
    80006b08:	96d6                	add	a3,a3,s5
    80006b0a:	6489                	lui	s1,0x2
    80006b0c:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006b0e:	078e                	slli	a5,a5,0x3
    80006b10:	97ba                	add	a5,a5,a4
    80006b12:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006b14:	00f98733          	add	a4,s3,a5
    80006b18:	20070713          	addi	a4,a4,512
    80006b1c:	0712                	slli	a4,a4,0x4
    80006b1e:	974a                	add	a4,a4,s2
    80006b20:	03074703          	lbu	a4,48(a4)
    80006b24:	eb21                	bnez	a4,80006b74 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006b26:	97ce                	add	a5,a5,s3
    80006b28:	20078793          	addi	a5,a5,512
    80006b2c:	0792                	slli	a5,a5,0x4
    80006b2e:	97ca                	add	a5,a5,s2
    80006b30:	7798                	ld	a4,40(a5)
    80006b32:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006b36:	7788                	ld	a0,40(a5)
    80006b38:	ffffc097          	auipc	ra,0xffffc
    80006b3c:	e18080e7          	jalr	-488(ra) # 80002950 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006b40:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006b44:	2785                	addiw	a5,a5,1
    80006b46:	8b9d                	andi	a5,a5,7
    80006b48:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006b4c:	6898                	ld	a4,16(s1)
    80006b4e:	00275683          	lhu	a3,2(a4)
    80006b52:	8a9d                	andi	a3,a3,7
    80006b54:	faf69de3          	bne	a3,a5,80006b0e <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006b58:	8552                	mv	a0,s4
    80006b5a:	ffffa097          	auipc	ra,0xffffa
    80006b5e:	37a080e7          	jalr	890(ra) # 80000ed4 <release>
}
    80006b62:	70e2                	ld	ra,56(sp)
    80006b64:	7442                	ld	s0,48(sp)
    80006b66:	74a2                	ld	s1,40(sp)
    80006b68:	7902                	ld	s2,32(sp)
    80006b6a:	69e2                	ld	s3,24(sp)
    80006b6c:	6a42                	ld	s4,16(sp)
    80006b6e:	6aa2                	ld	s5,8(sp)
    80006b70:	6121                	addi	sp,sp,64
    80006b72:	8082                	ret
      panic("virtio_disk_intr status");
    80006b74:	00002517          	auipc	a0,0x2
    80006b78:	21c50513          	addi	a0,a0,540 # 80008d90 <userret+0xd00>
    80006b7c:	ffffa097          	auipc	ra,0xffffa
    80006b80:	bda080e7          	jalr	-1062(ra) # 80000756 <panic>

0000000080006b84 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006b84:	1141                	addi	sp,sp,-16
    80006b86:	e422                	sd	s0,8(sp)
    80006b88:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80006b8a:	41f5d79b          	sraiw	a5,a1,0x1f
    80006b8e:	01d7d79b          	srliw	a5,a5,0x1d
    80006b92:	9dbd                	addw	a1,a1,a5
    80006b94:	0075f713          	andi	a4,a1,7
    80006b98:	9f1d                	subw	a4,a4,a5
    80006b9a:	4785                	li	a5,1
    80006b9c:	00e797bb          	sllw	a5,a5,a4
    80006ba0:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80006ba4:	4035d59b          	sraiw	a1,a1,0x3
    80006ba8:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006baa:	0005c503          	lbu	a0,0(a1)
    80006bae:	8d7d                	and	a0,a0,a5
    80006bb0:	8d1d                	sub	a0,a0,a5
}
    80006bb2:	00153513          	seqz	a0,a0
    80006bb6:	6422                	ld	s0,8(sp)
    80006bb8:	0141                	addi	sp,sp,16
    80006bba:	8082                	ret

0000000080006bbc <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006bbc:	1141                	addi	sp,sp,-16
    80006bbe:	e422                	sd	s0,8(sp)
    80006bc0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006bc2:	41f5d79b          	sraiw	a5,a1,0x1f
    80006bc6:	01d7d79b          	srliw	a5,a5,0x1d
    80006bca:	9dbd                	addw	a1,a1,a5
    80006bcc:	4035d71b          	sraiw	a4,a1,0x3
    80006bd0:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006bd2:	899d                	andi	a1,a1,7
    80006bd4:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    80006bd6:	4785                	li	a5,1
    80006bd8:	00b795bb          	sllw	a1,a5,a1
    80006bdc:	00054783          	lbu	a5,0(a0)
    80006be0:	8ddd                	or	a1,a1,a5
    80006be2:	00b50023          	sb	a1,0(a0)
}
    80006be6:	6422                	ld	s0,8(sp)
    80006be8:	0141                	addi	sp,sp,16
    80006bea:	8082                	ret

0000000080006bec <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006bec:	1141                	addi	sp,sp,-16
    80006bee:	e422                	sd	s0,8(sp)
    80006bf0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006bf2:	41f5d79b          	sraiw	a5,a1,0x1f
    80006bf6:	01d7d79b          	srliw	a5,a5,0x1d
    80006bfa:	9dbd                	addw	a1,a1,a5
    80006bfc:	4035d71b          	sraiw	a4,a1,0x3
    80006c00:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006c02:	899d                	andi	a1,a1,7
    80006c04:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    80006c06:	4785                	li	a5,1
    80006c08:	00b795bb          	sllw	a1,a5,a1
    80006c0c:	fff5c593          	not	a1,a1
    80006c10:	00054783          	lbu	a5,0(a0)
    80006c14:	8dfd                	and	a1,a1,a5
    80006c16:	00b50023          	sb	a1,0(a0)
}
    80006c1a:	6422                	ld	s0,8(sp)
    80006c1c:	0141                	addi	sp,sp,16
    80006c1e:	8082                	ret

0000000080006c20 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006c20:	715d                	addi	sp,sp,-80
    80006c22:	e486                	sd	ra,72(sp)
    80006c24:	e0a2                	sd	s0,64(sp)
    80006c26:	fc26                	sd	s1,56(sp)
    80006c28:	f84a                	sd	s2,48(sp)
    80006c2a:	f44e                	sd	s3,40(sp)
    80006c2c:	f052                	sd	s4,32(sp)
    80006c2e:	ec56                	sd	s5,24(sp)
    80006c30:	e85a                	sd	s6,16(sp)
    80006c32:	e45e                	sd	s7,8(sp)
    80006c34:	0880                	addi	s0,sp,80
    80006c36:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006c38:	08b05b63          	blez	a1,80006cce <bd_print_vector+0xae>
    80006c3c:	89aa                	mv	s3,a0
    80006c3e:	4481                	li	s1,0
  lb = 0;
    80006c40:	4a81                	li	s5,0
  last = 1;
    80006c42:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006c44:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006c46:	00002b97          	auipc	s7,0x2
    80006c4a:	162b8b93          	addi	s7,s7,354 # 80008da8 <userret+0xd18>
    80006c4e:	a01d                	j	80006c74 <bd_print_vector+0x54>
    80006c50:	8626                	mv	a2,s1
    80006c52:	85d6                	mv	a1,s5
    80006c54:	855e                	mv	a0,s7
    80006c56:	ffffa097          	auipc	ra,0xffffa
    80006c5a:	d16080e7          	jalr	-746(ra) # 8000096c <printf>
    lb = b;
    last = bit_isset(vector, b);
    80006c5e:	85a6                	mv	a1,s1
    80006c60:	854e                	mv	a0,s3
    80006c62:	00000097          	auipc	ra,0x0
    80006c66:	f22080e7          	jalr	-222(ra) # 80006b84 <bit_isset>
    80006c6a:	892a                	mv	s2,a0
    80006c6c:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006c6e:	2485                	addiw	s1,s1,1
    80006c70:	009a0d63          	beq	s4,s1,80006c8a <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006c74:	85a6                	mv	a1,s1
    80006c76:	854e                	mv	a0,s3
    80006c78:	00000097          	auipc	ra,0x0
    80006c7c:	f0c080e7          	jalr	-244(ra) # 80006b84 <bit_isset>
    80006c80:	ff2507e3          	beq	a0,s2,80006c6e <bd_print_vector+0x4e>
    if(last == 1)
    80006c84:	fd691de3          	bne	s2,s6,80006c5e <bd_print_vector+0x3e>
    80006c88:	b7e1                	j	80006c50 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80006c8a:	000a8563          	beqz	s5,80006c94 <bd_print_vector+0x74>
    80006c8e:	4785                	li	a5,1
    80006c90:	00f91c63          	bne	s2,a5,80006ca8 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006c94:	8652                	mv	a2,s4
    80006c96:	85d6                	mv	a1,s5
    80006c98:	00002517          	auipc	a0,0x2
    80006c9c:	11050513          	addi	a0,a0,272 # 80008da8 <userret+0xd18>
    80006ca0:	ffffa097          	auipc	ra,0xffffa
    80006ca4:	ccc080e7          	jalr	-820(ra) # 8000096c <printf>
  }
  printf("\n");
    80006ca8:	00002517          	auipc	a0,0x2
    80006cac:	9a050513          	addi	a0,a0,-1632 # 80008648 <userret+0x5b8>
    80006cb0:	ffffa097          	auipc	ra,0xffffa
    80006cb4:	cbc080e7          	jalr	-836(ra) # 8000096c <printf>
}
    80006cb8:	60a6                	ld	ra,72(sp)
    80006cba:	6406                	ld	s0,64(sp)
    80006cbc:	74e2                	ld	s1,56(sp)
    80006cbe:	7942                	ld	s2,48(sp)
    80006cc0:	79a2                	ld	s3,40(sp)
    80006cc2:	7a02                	ld	s4,32(sp)
    80006cc4:	6ae2                	ld	s5,24(sp)
    80006cc6:	6b42                	ld	s6,16(sp)
    80006cc8:	6ba2                	ld	s7,8(sp)
    80006cca:	6161                	addi	sp,sp,80
    80006ccc:	8082                	ret
  lb = 0;
    80006cce:	4a81                	li	s5,0
    80006cd0:	b7d1                	j	80006c94 <bd_print_vector+0x74>

0000000080006cd2 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006cd2:	00027697          	auipc	a3,0x27
    80006cd6:	3ce6a683          	lw	a3,974(a3) # 8002e0a0 <nsizes>
    80006cda:	10d05063          	blez	a3,80006dda <bd_print+0x108>
bd_print() {
    80006cde:	711d                	addi	sp,sp,-96
    80006ce0:	ec86                	sd	ra,88(sp)
    80006ce2:	e8a2                	sd	s0,80(sp)
    80006ce4:	e4a6                	sd	s1,72(sp)
    80006ce6:	e0ca                	sd	s2,64(sp)
    80006ce8:	fc4e                	sd	s3,56(sp)
    80006cea:	f852                	sd	s4,48(sp)
    80006cec:	f456                	sd	s5,40(sp)
    80006cee:	f05a                	sd	s6,32(sp)
    80006cf0:	ec5e                	sd	s7,24(sp)
    80006cf2:	e862                	sd	s8,16(sp)
    80006cf4:	e466                	sd	s9,8(sp)
    80006cf6:	e06a                	sd	s10,0(sp)
    80006cf8:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80006cfa:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006cfc:	4a85                	li	s5,1
    80006cfe:	4c41                	li	s8,16
    80006d00:	00002b97          	auipc	s7,0x2
    80006d04:	0b8b8b93          	addi	s7,s7,184 # 80008db8 <userret+0xd28>
    lst_print(&bd_sizes[k].free);
    80006d08:	00027a17          	auipc	s4,0x27
    80006d0c:	390a0a13          	addi	s4,s4,912 # 8002e098 <bd_sizes>
    printf("  alloc:");
    80006d10:	00002b17          	auipc	s6,0x2
    80006d14:	0d0b0b13          	addi	s6,s6,208 # 80008de0 <userret+0xd50>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006d18:	00027997          	auipc	s3,0x27
    80006d1c:	38898993          	addi	s3,s3,904 # 8002e0a0 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006d20:	00002c97          	auipc	s9,0x2
    80006d24:	0d0c8c93          	addi	s9,s9,208 # 80008df0 <userret+0xd60>
    80006d28:	a801                	j	80006d38 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80006d2a:	0009a683          	lw	a3,0(s3)
    80006d2e:	0485                	addi	s1,s1,1
    80006d30:	0004879b          	sext.w	a5,s1
    80006d34:	08d7d563          	bge	a5,a3,80006dbe <bd_print+0xec>
    80006d38:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006d3c:	36fd                	addiw	a3,a3,-1
    80006d3e:	9e85                	subw	a3,a3,s1
    80006d40:	00da96bb          	sllw	a3,s5,a3
    80006d44:	009c1633          	sll	a2,s8,s1
    80006d48:	85ca                	mv	a1,s2
    80006d4a:	855e                	mv	a0,s7
    80006d4c:	ffffa097          	auipc	ra,0xffffa
    80006d50:	c20080e7          	jalr	-992(ra) # 8000096c <printf>
    lst_print(&bd_sizes[k].free);
    80006d54:	00549d13          	slli	s10,s1,0x5
    80006d58:	000a3503          	ld	a0,0(s4)
    80006d5c:	956a                	add	a0,a0,s10
    80006d5e:	00001097          	auipc	ra,0x1
    80006d62:	a4e080e7          	jalr	-1458(ra) # 800077ac <lst_print>
    printf("  alloc:");
    80006d66:	855a                	mv	a0,s6
    80006d68:	ffffa097          	auipc	ra,0xffffa
    80006d6c:	c04080e7          	jalr	-1020(ra) # 8000096c <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006d70:	0009a583          	lw	a1,0(s3)
    80006d74:	35fd                	addiw	a1,a1,-1
    80006d76:	412585bb          	subw	a1,a1,s2
    80006d7a:	000a3783          	ld	a5,0(s4)
    80006d7e:	97ea                	add	a5,a5,s10
    80006d80:	00ba95bb          	sllw	a1,s5,a1
    80006d84:	6b88                	ld	a0,16(a5)
    80006d86:	00000097          	auipc	ra,0x0
    80006d8a:	e9a080e7          	jalr	-358(ra) # 80006c20 <bd_print_vector>
    if(k > 0) {
    80006d8e:	f9205ee3          	blez	s2,80006d2a <bd_print+0x58>
      printf("  split:");
    80006d92:	8566                	mv	a0,s9
    80006d94:	ffffa097          	auipc	ra,0xffffa
    80006d98:	bd8080e7          	jalr	-1064(ra) # 8000096c <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006d9c:	0009a583          	lw	a1,0(s3)
    80006da0:	35fd                	addiw	a1,a1,-1
    80006da2:	412585bb          	subw	a1,a1,s2
    80006da6:	000a3783          	ld	a5,0(s4)
    80006daa:	9d3e                	add	s10,s10,a5
    80006dac:	00ba95bb          	sllw	a1,s5,a1
    80006db0:	018d3503          	ld	a0,24(s10)
    80006db4:	00000097          	auipc	ra,0x0
    80006db8:	e6c080e7          	jalr	-404(ra) # 80006c20 <bd_print_vector>
    80006dbc:	b7bd                	j	80006d2a <bd_print+0x58>
    }
  }
}
    80006dbe:	60e6                	ld	ra,88(sp)
    80006dc0:	6446                	ld	s0,80(sp)
    80006dc2:	64a6                	ld	s1,72(sp)
    80006dc4:	6906                	ld	s2,64(sp)
    80006dc6:	79e2                	ld	s3,56(sp)
    80006dc8:	7a42                	ld	s4,48(sp)
    80006dca:	7aa2                	ld	s5,40(sp)
    80006dcc:	7b02                	ld	s6,32(sp)
    80006dce:	6be2                	ld	s7,24(sp)
    80006dd0:	6c42                	ld	s8,16(sp)
    80006dd2:	6ca2                	ld	s9,8(sp)
    80006dd4:	6d02                	ld	s10,0(sp)
    80006dd6:	6125                	addi	sp,sp,96
    80006dd8:	8082                	ret
    80006dda:	8082                	ret

0000000080006ddc <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006ddc:	1141                	addi	sp,sp,-16
    80006dde:	e422                	sd	s0,8(sp)
    80006de0:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006de2:	47c1                	li	a5,16
    80006de4:	00a7fb63          	bgeu	a5,a0,80006dfa <firstk+0x1e>
    80006de8:	872a                	mv	a4,a0
  int k = 0;
    80006dea:	4501                	li	a0,0
    k++;
    80006dec:	2505                	addiw	a0,a0,1
    size *= 2;
    80006dee:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006df0:	fee7eee3          	bltu	a5,a4,80006dec <firstk+0x10>
  }
  return k;
}
    80006df4:	6422                	ld	s0,8(sp)
    80006df6:	0141                	addi	sp,sp,16
    80006df8:	8082                	ret
  int k = 0;
    80006dfa:	4501                	li	a0,0
    80006dfc:	bfe5                	j	80006df4 <firstk+0x18>

0000000080006dfe <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006dfe:	1141                	addi	sp,sp,-16
    80006e00:	e422                	sd	s0,8(sp)
    80006e02:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006e04:	00027797          	auipc	a5,0x27
    80006e08:	28c7b783          	ld	a5,652(a5) # 8002e090 <bd_base>
    80006e0c:	9d9d                	subw	a1,a1,a5
    80006e0e:	47c1                	li	a5,16
    80006e10:	00a79533          	sll	a0,a5,a0
    80006e14:	02a5c533          	div	a0,a1,a0
}
    80006e18:	2501                	sext.w	a0,a0
    80006e1a:	6422                	ld	s0,8(sp)
    80006e1c:	0141                	addi	sp,sp,16
    80006e1e:	8082                	ret

0000000080006e20 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006e20:	1141                	addi	sp,sp,-16
    80006e22:	e422                	sd	s0,8(sp)
    80006e24:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006e26:	47c1                	li	a5,16
    80006e28:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006e2c:	02b787bb          	mulw	a5,a5,a1
}
    80006e30:	00027517          	auipc	a0,0x27
    80006e34:	26053503          	ld	a0,608(a0) # 8002e090 <bd_base>
    80006e38:	953e                	add	a0,a0,a5
    80006e3a:	6422                	ld	s0,8(sp)
    80006e3c:	0141                	addi	sp,sp,16
    80006e3e:	8082                	ret

0000000080006e40 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006e40:	7159                	addi	sp,sp,-112
    80006e42:	f486                	sd	ra,104(sp)
    80006e44:	f0a2                	sd	s0,96(sp)
    80006e46:	eca6                	sd	s1,88(sp)
    80006e48:	e8ca                	sd	s2,80(sp)
    80006e4a:	e4ce                	sd	s3,72(sp)
    80006e4c:	e0d2                	sd	s4,64(sp)
    80006e4e:	fc56                	sd	s5,56(sp)
    80006e50:	f85a                	sd	s6,48(sp)
    80006e52:	f45e                	sd	s7,40(sp)
    80006e54:	f062                	sd	s8,32(sp)
    80006e56:	ec66                	sd	s9,24(sp)
    80006e58:	e86a                	sd	s10,16(sp)
    80006e5a:	e46e                	sd	s11,8(sp)
    80006e5c:	1880                	addi	s0,sp,112
    80006e5e:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006e60:	00027517          	auipc	a0,0x27
    80006e64:	1a050513          	addi	a0,a0,416 # 8002e000 <lock>
    80006e68:	ffffa097          	auipc	ra,0xffffa
    80006e6c:	e20080e7          	jalr	-480(ra) # 80000c88 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006e70:	8526                	mv	a0,s1
    80006e72:	00000097          	auipc	ra,0x0
    80006e76:	f6a080e7          	jalr	-150(ra) # 80006ddc <firstk>
  for (k = fk; k < nsizes; k++) {
    80006e7a:	00027797          	auipc	a5,0x27
    80006e7e:	2267a783          	lw	a5,550(a5) # 8002e0a0 <nsizes>
    80006e82:	02f55d63          	bge	a0,a5,80006ebc <bd_malloc+0x7c>
    80006e86:	8c2a                	mv	s8,a0
    80006e88:	00551913          	slli	s2,a0,0x5
    80006e8c:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006e8e:	00027997          	auipc	s3,0x27
    80006e92:	20a98993          	addi	s3,s3,522 # 8002e098 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006e96:	00027a17          	auipc	s4,0x27
    80006e9a:	20aa0a13          	addi	s4,s4,522 # 8002e0a0 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006e9e:	0009b503          	ld	a0,0(s3)
    80006ea2:	954a                	add	a0,a0,s2
    80006ea4:	00001097          	auipc	ra,0x1
    80006ea8:	88e080e7          	jalr	-1906(ra) # 80007732 <lst_empty>
    80006eac:	c115                	beqz	a0,80006ed0 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006eae:	2485                	addiw	s1,s1,1
    80006eb0:	02090913          	addi	s2,s2,32
    80006eb4:	000a2783          	lw	a5,0(s4)
    80006eb8:	fef4c3e3          	blt	s1,a5,80006e9e <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006ebc:	00027517          	auipc	a0,0x27
    80006ec0:	14450513          	addi	a0,a0,324 # 8002e000 <lock>
    80006ec4:	ffffa097          	auipc	ra,0xffffa
    80006ec8:	010080e7          	jalr	16(ra) # 80000ed4 <release>
    return 0;
    80006ecc:	4b01                	li	s6,0
    80006ece:	a0e1                	j	80006f96 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006ed0:	00027797          	auipc	a5,0x27
    80006ed4:	1d07a783          	lw	a5,464(a5) # 8002e0a0 <nsizes>
    80006ed8:	fef4d2e3          	bge	s1,a5,80006ebc <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006edc:	00549993          	slli	s3,s1,0x5
    80006ee0:	00027917          	auipc	s2,0x27
    80006ee4:	1b890913          	addi	s2,s2,440 # 8002e098 <bd_sizes>
    80006ee8:	00093503          	ld	a0,0(s2)
    80006eec:	954e                	add	a0,a0,s3
    80006eee:	00001097          	auipc	ra,0x1
    80006ef2:	870080e7          	jalr	-1936(ra) # 8000775e <lst_pop>
    80006ef6:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006ef8:	00027597          	auipc	a1,0x27
    80006efc:	1985b583          	ld	a1,408(a1) # 8002e090 <bd_base>
    80006f00:	40b505bb          	subw	a1,a0,a1
    80006f04:	47c1                	li	a5,16
    80006f06:	009797b3          	sll	a5,a5,s1
    80006f0a:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006f0e:	00093783          	ld	a5,0(s2)
    80006f12:	97ce                	add	a5,a5,s3
    80006f14:	2581                	sext.w	a1,a1
    80006f16:	6b88                	ld	a0,16(a5)
    80006f18:	00000097          	auipc	ra,0x0
    80006f1c:	ca4080e7          	jalr	-860(ra) # 80006bbc <bit_set>
  for(; k > fk; k--) {
    80006f20:	069c5363          	bge	s8,s1,80006f86 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006f24:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006f26:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006f28:	00027d17          	auipc	s10,0x27
    80006f2c:	168d0d13          	addi	s10,s10,360 # 8002e090 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006f30:	85a6                	mv	a1,s1
    80006f32:	34fd                	addiw	s1,s1,-1
    80006f34:	009b9ab3          	sll	s5,s7,s1
    80006f38:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006f3c:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    80006f40:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006f44:	412b093b          	subw	s2,s6,s2
    80006f48:	00bb95b3          	sll	a1,s7,a1
    80006f4c:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006f50:	013a07b3          	add	a5,s4,s3
    80006f54:	2581                	sext.w	a1,a1
    80006f56:	6f88                	ld	a0,24(a5)
    80006f58:	00000097          	auipc	ra,0x0
    80006f5c:	c64080e7          	jalr	-924(ra) # 80006bbc <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006f60:	1981                	addi	s3,s3,-32
    80006f62:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006f64:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006f68:	2581                	sext.w	a1,a1
    80006f6a:	010a3503          	ld	a0,16(s4)
    80006f6e:	00000097          	auipc	ra,0x0
    80006f72:	c4e080e7          	jalr	-946(ra) # 80006bbc <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006f76:	85e6                	mv	a1,s9
    80006f78:	8552                	mv	a0,s4
    80006f7a:	00001097          	auipc	ra,0x1
    80006f7e:	81a080e7          	jalr	-2022(ra) # 80007794 <lst_push>
  for(; k > fk; k--) {
    80006f82:	fb8497e3          	bne	s1,s8,80006f30 <bd_malloc+0xf0>
  }
  release(&lock);
    80006f86:	00027517          	auipc	a0,0x27
    80006f8a:	07a50513          	addi	a0,a0,122 # 8002e000 <lock>
    80006f8e:	ffffa097          	auipc	ra,0xffffa
    80006f92:	f46080e7          	jalr	-186(ra) # 80000ed4 <release>

  return p;
}
    80006f96:	855a                	mv	a0,s6
    80006f98:	70a6                	ld	ra,104(sp)
    80006f9a:	7406                	ld	s0,96(sp)
    80006f9c:	64e6                	ld	s1,88(sp)
    80006f9e:	6946                	ld	s2,80(sp)
    80006fa0:	69a6                	ld	s3,72(sp)
    80006fa2:	6a06                	ld	s4,64(sp)
    80006fa4:	7ae2                	ld	s5,56(sp)
    80006fa6:	7b42                	ld	s6,48(sp)
    80006fa8:	7ba2                	ld	s7,40(sp)
    80006faa:	7c02                	ld	s8,32(sp)
    80006fac:	6ce2                	ld	s9,24(sp)
    80006fae:	6d42                	ld	s10,16(sp)
    80006fb0:	6da2                	ld	s11,8(sp)
    80006fb2:	6165                	addi	sp,sp,112
    80006fb4:	8082                	ret

0000000080006fb6 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006fb6:	7139                	addi	sp,sp,-64
    80006fb8:	fc06                	sd	ra,56(sp)
    80006fba:	f822                	sd	s0,48(sp)
    80006fbc:	f426                	sd	s1,40(sp)
    80006fbe:	f04a                	sd	s2,32(sp)
    80006fc0:	ec4e                	sd	s3,24(sp)
    80006fc2:	e852                	sd	s4,16(sp)
    80006fc4:	e456                	sd	s5,8(sp)
    80006fc6:	e05a                	sd	s6,0(sp)
    80006fc8:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006fca:	00027a97          	auipc	s5,0x27
    80006fce:	0d6aaa83          	lw	s5,214(s5) # 8002e0a0 <nsizes>
  return n / BLK_SIZE(k);
    80006fd2:	00027a17          	auipc	s4,0x27
    80006fd6:	0bea3a03          	ld	s4,190(s4) # 8002e090 <bd_base>
    80006fda:	41450a3b          	subw	s4,a0,s4
    80006fde:	00027497          	auipc	s1,0x27
    80006fe2:	0ba4b483          	ld	s1,186(s1) # 8002e098 <bd_sizes>
    80006fe6:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006fea:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006fec:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006fee:	03595363          	bge	s2,s5,80007014 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006ff2:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006ff6:	013b15b3          	sll	a1,s6,s3
    80006ffa:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006ffe:	2581                	sext.w	a1,a1
    80007000:	6088                	ld	a0,0(s1)
    80007002:	00000097          	auipc	ra,0x0
    80007006:	b82080e7          	jalr	-1150(ra) # 80006b84 <bit_isset>
    8000700a:	02048493          	addi	s1,s1,32
    8000700e:	e501                	bnez	a0,80007016 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80007010:	894e                	mv	s2,s3
    80007012:	bff1                	j	80006fee <size+0x38>
      return k;
    }
  }
  return 0;
    80007014:	4901                	li	s2,0
}
    80007016:	854a                	mv	a0,s2
    80007018:	70e2                	ld	ra,56(sp)
    8000701a:	7442                	ld	s0,48(sp)
    8000701c:	74a2                	ld	s1,40(sp)
    8000701e:	7902                	ld	s2,32(sp)
    80007020:	69e2                	ld	s3,24(sp)
    80007022:	6a42                	ld	s4,16(sp)
    80007024:	6aa2                	ld	s5,8(sp)
    80007026:	6b02                	ld	s6,0(sp)
    80007028:	6121                	addi	sp,sp,64
    8000702a:	8082                	ret

000000008000702c <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    8000702c:	7159                	addi	sp,sp,-112
    8000702e:	f486                	sd	ra,104(sp)
    80007030:	f0a2                	sd	s0,96(sp)
    80007032:	eca6                	sd	s1,88(sp)
    80007034:	e8ca                	sd	s2,80(sp)
    80007036:	e4ce                	sd	s3,72(sp)
    80007038:	e0d2                	sd	s4,64(sp)
    8000703a:	fc56                	sd	s5,56(sp)
    8000703c:	f85a                	sd	s6,48(sp)
    8000703e:	f45e                	sd	s7,40(sp)
    80007040:	f062                	sd	s8,32(sp)
    80007042:	ec66                	sd	s9,24(sp)
    80007044:	e86a                	sd	s10,16(sp)
    80007046:	e46e                	sd	s11,8(sp)
    80007048:	1880                	addi	s0,sp,112
    8000704a:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    8000704c:	00027517          	auipc	a0,0x27
    80007050:	fb450513          	addi	a0,a0,-76 # 8002e000 <lock>
    80007054:	ffffa097          	auipc	ra,0xffffa
    80007058:	c34080e7          	jalr	-972(ra) # 80000c88 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    8000705c:	8556                	mv	a0,s5
    8000705e:	00000097          	auipc	ra,0x0
    80007062:	f58080e7          	jalr	-168(ra) # 80006fb6 <size>
    80007066:	84aa                	mv	s1,a0
    80007068:	00027797          	auipc	a5,0x27
    8000706c:	0387a783          	lw	a5,56(a5) # 8002e0a0 <nsizes>
    80007070:	37fd                	addiw	a5,a5,-1
    80007072:	0af55d63          	bge	a0,a5,8000712c <bd_free+0x100>
    80007076:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    8000707a:	00027c17          	auipc	s8,0x27
    8000707e:	016c0c13          	addi	s8,s8,22 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    80007082:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007084:	00027b17          	auipc	s6,0x27
    80007088:	014b0b13          	addi	s6,s6,20 # 8002e098 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    8000708c:	00027c97          	auipc	s9,0x27
    80007090:	014c8c93          	addi	s9,s9,20 # 8002e0a0 <nsizes>
    80007094:	a82d                	j	800070ce <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007096:	fff58d9b          	addiw	s11,a1,-1
    8000709a:	a881                	j	800070ea <bd_free+0xbe>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    8000709c:	020a0a13          	addi	s4,s4,32
    800070a0:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    800070a2:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    800070a6:	40ba85bb          	subw	a1,s5,a1
    800070aa:	009b97b3          	sll	a5,s7,s1
    800070ae:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800070b2:	000b3783          	ld	a5,0(s6)
    800070b6:	97d2                	add	a5,a5,s4
    800070b8:	2581                	sext.w	a1,a1
    800070ba:	6f88                	ld	a0,24(a5)
    800070bc:	00000097          	auipc	ra,0x0
    800070c0:	b30080e7          	jalr	-1232(ra) # 80006bec <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    800070c4:	000ca783          	lw	a5,0(s9)
    800070c8:	37fd                	addiw	a5,a5,-1
    800070ca:	06f4d163          	bge	s1,a5,8000712c <bd_free+0x100>
  int n = p - (char *) bd_base;
    800070ce:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    800070d2:	009b99b3          	sll	s3,s7,s1
    800070d6:	412a87bb          	subw	a5,s5,s2
    800070da:	0337c7b3          	div	a5,a5,s3
    800070de:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800070e2:	8b85                	andi	a5,a5,1
    800070e4:	fbcd                	bnez	a5,80007096 <bd_free+0x6a>
    800070e6:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    800070ea:	000b3d03          	ld	s10,0(s6)
    800070ee:	9d52                	add	s10,s10,s4
    800070f0:	010d3503          	ld	a0,16(s10)
    800070f4:	00000097          	auipc	ra,0x0
    800070f8:	af8080e7          	jalr	-1288(ra) # 80006bec <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    800070fc:	85ee                	mv	a1,s11
    800070fe:	010d3503          	ld	a0,16(s10)
    80007102:	00000097          	auipc	ra,0x0
    80007106:	a82080e7          	jalr	-1406(ra) # 80006b84 <bit_isset>
    8000710a:	e10d                	bnez	a0,8000712c <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    8000710c:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80007110:	03b989bb          	mulw	s3,s3,s11
    80007114:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80007116:	854a                	mv	a0,s2
    80007118:	00000097          	auipc	ra,0x0
    8000711c:	630080e7          	jalr	1584(ra) # 80007748 <lst_remove>
    if(buddy % 2 == 0) {
    80007120:	001d7d13          	andi	s10,s10,1
    80007124:	f60d1ce3          	bnez	s10,8000709c <bd_free+0x70>
      p = q;
    80007128:	8aca                	mv	s5,s2
    8000712a:	bf8d                	j	8000709c <bd_free+0x70>
  }
  lst_push(&bd_sizes[k].free, p);
    8000712c:	0496                	slli	s1,s1,0x5
    8000712e:	85d6                	mv	a1,s5
    80007130:	00027517          	auipc	a0,0x27
    80007134:	f6853503          	ld	a0,-152(a0) # 8002e098 <bd_sizes>
    80007138:	9526                	add	a0,a0,s1
    8000713a:	00000097          	auipc	ra,0x0
    8000713e:	65a080e7          	jalr	1626(ra) # 80007794 <lst_push>
  release(&lock);
    80007142:	00027517          	auipc	a0,0x27
    80007146:	ebe50513          	addi	a0,a0,-322 # 8002e000 <lock>
    8000714a:	ffffa097          	auipc	ra,0xffffa
    8000714e:	d8a080e7          	jalr	-630(ra) # 80000ed4 <release>
}
    80007152:	70a6                	ld	ra,104(sp)
    80007154:	7406                	ld	s0,96(sp)
    80007156:	64e6                	ld	s1,88(sp)
    80007158:	6946                	ld	s2,80(sp)
    8000715a:	69a6                	ld	s3,72(sp)
    8000715c:	6a06                	ld	s4,64(sp)
    8000715e:	7ae2                	ld	s5,56(sp)
    80007160:	7b42                	ld	s6,48(sp)
    80007162:	7ba2                	ld	s7,40(sp)
    80007164:	7c02                	ld	s8,32(sp)
    80007166:	6ce2                	ld	s9,24(sp)
    80007168:	6d42                	ld	s10,16(sp)
    8000716a:	6da2                	ld	s11,8(sp)
    8000716c:	6165                	addi	sp,sp,112
    8000716e:	8082                	ret

0000000080007170 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80007170:	1141                	addi	sp,sp,-16
    80007172:	e422                	sd	s0,8(sp)
    80007174:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80007176:	00027797          	auipc	a5,0x27
    8000717a:	f1a7b783          	ld	a5,-230(a5) # 8002e090 <bd_base>
    8000717e:	8d9d                	sub	a1,a1,a5
    80007180:	47c1                	li	a5,16
    80007182:	00a797b3          	sll	a5,a5,a0
    80007186:	02f5c533          	div	a0,a1,a5
    8000718a:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    8000718c:	02f5e5b3          	rem	a1,a1,a5
    80007190:	c191                	beqz	a1,80007194 <blk_index_next+0x24>
      n++;
    80007192:	2505                	addiw	a0,a0,1
  return n ;
}
    80007194:	6422                	ld	s0,8(sp)
    80007196:	0141                	addi	sp,sp,16
    80007198:	8082                	ret

000000008000719a <log2>:

int
log2(uint64 n) {
    8000719a:	1141                	addi	sp,sp,-16
    8000719c:	e422                	sd	s0,8(sp)
    8000719e:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    800071a0:	4705                	li	a4,1
    800071a2:	00a77b63          	bgeu	a4,a0,800071b8 <log2+0x1e>
    800071a6:	87aa                	mv	a5,a0
  int k = 0;
    800071a8:	4501                	li	a0,0
    k++;
    800071aa:	2505                	addiw	a0,a0,1
    n = n >> 1;
    800071ac:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    800071ae:	fef76ee3          	bltu	a4,a5,800071aa <log2+0x10>
  }
  return k;
}
    800071b2:	6422                	ld	s0,8(sp)
    800071b4:	0141                	addi	sp,sp,16
    800071b6:	8082                	ret
  int k = 0;
    800071b8:	4501                	li	a0,0
    800071ba:	bfe5                	j	800071b2 <log2+0x18>

00000000800071bc <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    800071bc:	711d                	addi	sp,sp,-96
    800071be:	ec86                	sd	ra,88(sp)
    800071c0:	e8a2                	sd	s0,80(sp)
    800071c2:	e4a6                	sd	s1,72(sp)
    800071c4:	e0ca                	sd	s2,64(sp)
    800071c6:	fc4e                	sd	s3,56(sp)
    800071c8:	f852                	sd	s4,48(sp)
    800071ca:	f456                	sd	s5,40(sp)
    800071cc:	f05a                	sd	s6,32(sp)
    800071ce:	ec5e                	sd	s7,24(sp)
    800071d0:	e862                	sd	s8,16(sp)
    800071d2:	e466                	sd	s9,8(sp)
    800071d4:	e06a                	sd	s10,0(sp)
    800071d6:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    800071d8:	00b56933          	or	s2,a0,a1
    800071dc:	00f97913          	andi	s2,s2,15
    800071e0:	04091263          	bnez	s2,80007224 <bd_mark+0x68>
    800071e4:	8b2a                	mv	s6,a0
    800071e6:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    800071e8:	00027c17          	auipc	s8,0x27
    800071ec:	eb8c2c03          	lw	s8,-328(s8) # 8002e0a0 <nsizes>
    800071f0:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    800071f2:	00027d17          	auipc	s10,0x27
    800071f6:	e9ed0d13          	addi	s10,s10,-354 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    800071fa:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    800071fc:	00027a97          	auipc	s5,0x27
    80007200:	e9ca8a93          	addi	s5,s5,-356 # 8002e098 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80007204:	07804563          	bgtz	s8,8000726e <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80007208:	60e6                	ld	ra,88(sp)
    8000720a:	6446                	ld	s0,80(sp)
    8000720c:	64a6                	ld	s1,72(sp)
    8000720e:	6906                	ld	s2,64(sp)
    80007210:	79e2                	ld	s3,56(sp)
    80007212:	7a42                	ld	s4,48(sp)
    80007214:	7aa2                	ld	s5,40(sp)
    80007216:	7b02                	ld	s6,32(sp)
    80007218:	6be2                	ld	s7,24(sp)
    8000721a:	6c42                	ld	s8,16(sp)
    8000721c:	6ca2                	ld	s9,8(sp)
    8000721e:	6d02                	ld	s10,0(sp)
    80007220:	6125                	addi	sp,sp,96
    80007222:	8082                	ret
    panic("bd_mark");
    80007224:	00002517          	auipc	a0,0x2
    80007228:	bdc50513          	addi	a0,a0,-1060 # 80008e00 <userret+0xd70>
    8000722c:	ffff9097          	auipc	ra,0xffff9
    80007230:	52a080e7          	jalr	1322(ra) # 80000756 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80007234:	000ab783          	ld	a5,0(s5)
    80007238:	97ca                	add	a5,a5,s2
    8000723a:	85a6                	mv	a1,s1
    8000723c:	6b88                	ld	a0,16(a5)
    8000723e:	00000097          	auipc	ra,0x0
    80007242:	97e080e7          	jalr	-1666(ra) # 80006bbc <bit_set>
    for(; bi < bj; bi++) {
    80007246:	2485                	addiw	s1,s1,1
    80007248:	009a0e63          	beq	s4,s1,80007264 <bd_mark+0xa8>
      if(k > 0) {
    8000724c:	ff3054e3          	blez	s3,80007234 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80007250:	000ab783          	ld	a5,0(s5)
    80007254:	97ca                	add	a5,a5,s2
    80007256:	85a6                	mv	a1,s1
    80007258:	6f88                	ld	a0,24(a5)
    8000725a:	00000097          	auipc	ra,0x0
    8000725e:	962080e7          	jalr	-1694(ra) # 80006bbc <bit_set>
    80007262:	bfc9                	j	80007234 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80007264:	2985                	addiw	s3,s3,1
    80007266:	02090913          	addi	s2,s2,32
    8000726a:	f9898fe3          	beq	s3,s8,80007208 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    8000726e:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80007272:	409b04bb          	subw	s1,s6,s1
    80007276:	013c97b3          	sll	a5,s9,s3
    8000727a:	02f4c4b3          	div	s1,s1,a5
    8000727e:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80007280:	85de                	mv	a1,s7
    80007282:	854e                	mv	a0,s3
    80007284:	00000097          	auipc	ra,0x0
    80007288:	eec080e7          	jalr	-276(ra) # 80007170 <blk_index_next>
    8000728c:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    8000728e:	faa4cfe3          	blt	s1,a0,8000724c <bd_mark+0x90>
    80007292:	bfc9                	j	80007264 <bd_mark+0xa8>

0000000080007294 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80007294:	7139                	addi	sp,sp,-64
    80007296:	fc06                	sd	ra,56(sp)
    80007298:	f822                	sd	s0,48(sp)
    8000729a:	f426                	sd	s1,40(sp)
    8000729c:	f04a                	sd	s2,32(sp)
    8000729e:	ec4e                	sd	s3,24(sp)
    800072a0:	e852                	sd	s4,16(sp)
    800072a2:	e456                	sd	s5,8(sp)
    800072a4:	e05a                	sd	s6,0(sp)
    800072a6:	0080                	addi	s0,sp,64
    800072a8:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800072aa:	00058a9b          	sext.w	s5,a1
    800072ae:	0015f793          	andi	a5,a1,1
    800072b2:	ebad                	bnez	a5,80007324 <bd_initfree_pair+0x90>
    800072b4:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    800072b8:	00599493          	slli	s1,s3,0x5
    800072bc:	00027797          	auipc	a5,0x27
    800072c0:	ddc7b783          	ld	a5,-548(a5) # 8002e098 <bd_sizes>
    800072c4:	94be                	add	s1,s1,a5
    800072c6:	0104bb03          	ld	s6,16(s1)
    800072ca:	855a                	mv	a0,s6
    800072cc:	00000097          	auipc	ra,0x0
    800072d0:	8b8080e7          	jalr	-1864(ra) # 80006b84 <bit_isset>
    800072d4:	892a                	mv	s2,a0
    800072d6:	85d2                	mv	a1,s4
    800072d8:	855a                	mv	a0,s6
    800072da:	00000097          	auipc	ra,0x0
    800072de:	8aa080e7          	jalr	-1878(ra) # 80006b84 <bit_isset>
  int free = 0;
    800072e2:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    800072e4:	02a90563          	beq	s2,a0,8000730e <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    800072e8:	45c1                	li	a1,16
    800072ea:	013599b3          	sll	s3,a1,s3
    800072ee:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    800072f2:	02090c63          	beqz	s2,8000732a <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    800072f6:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    800072fa:	00027597          	auipc	a1,0x27
    800072fe:	d965b583          	ld	a1,-618(a1) # 8002e090 <bd_base>
    80007302:	95ce                	add	a1,a1,s3
    80007304:	8526                	mv	a0,s1
    80007306:	00000097          	auipc	ra,0x0
    8000730a:	48e080e7          	jalr	1166(ra) # 80007794 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    8000730e:	855a                	mv	a0,s6
    80007310:	70e2                	ld	ra,56(sp)
    80007312:	7442                	ld	s0,48(sp)
    80007314:	74a2                	ld	s1,40(sp)
    80007316:	7902                	ld	s2,32(sp)
    80007318:	69e2                	ld	s3,24(sp)
    8000731a:	6a42                	ld	s4,16(sp)
    8000731c:	6aa2                	ld	s5,8(sp)
    8000731e:	6b02                	ld	s6,0(sp)
    80007320:	6121                	addi	sp,sp,64
    80007322:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007324:	fff58a1b          	addiw	s4,a1,-1
    80007328:	bf41                	j	800072b8 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    8000732a:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    8000732e:	00027597          	auipc	a1,0x27
    80007332:	d625b583          	ld	a1,-670(a1) # 8002e090 <bd_base>
    80007336:	95ce                	add	a1,a1,s3
    80007338:	8526                	mv	a0,s1
    8000733a:	00000097          	auipc	ra,0x0
    8000733e:	45a080e7          	jalr	1114(ra) # 80007794 <lst_push>
    80007342:	b7f1                	j	8000730e <bd_initfree_pair+0x7a>

0000000080007344 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80007344:	711d                	addi	sp,sp,-96
    80007346:	ec86                	sd	ra,88(sp)
    80007348:	e8a2                	sd	s0,80(sp)
    8000734a:	e4a6                	sd	s1,72(sp)
    8000734c:	e0ca                	sd	s2,64(sp)
    8000734e:	fc4e                	sd	s3,56(sp)
    80007350:	f852                	sd	s4,48(sp)
    80007352:	f456                	sd	s5,40(sp)
    80007354:	f05a                	sd	s6,32(sp)
    80007356:	ec5e                	sd	s7,24(sp)
    80007358:	e862                	sd	s8,16(sp)
    8000735a:	e466                	sd	s9,8(sp)
    8000735c:	e06a                	sd	s10,0(sp)
    8000735e:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007360:	00027717          	auipc	a4,0x27
    80007364:	d4072703          	lw	a4,-704(a4) # 8002e0a0 <nsizes>
    80007368:	4785                	li	a5,1
    8000736a:	06e7db63          	bge	a5,a4,800073e0 <bd_initfree+0x9c>
    8000736e:	8aaa                	mv	s5,a0
    80007370:	8b2e                	mv	s6,a1
    80007372:	4901                	li	s2,0
  int free = 0;
    80007374:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80007376:	00027c97          	auipc	s9,0x27
    8000737a:	d1ac8c93          	addi	s9,s9,-742 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    8000737e:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007380:	00027b97          	auipc	s7,0x27
    80007384:	d20b8b93          	addi	s7,s7,-736 # 8002e0a0 <nsizes>
    80007388:	a039                	j	80007396 <bd_initfree+0x52>
    8000738a:	2905                	addiw	s2,s2,1
    8000738c:	000ba783          	lw	a5,0(s7)
    80007390:	37fd                	addiw	a5,a5,-1
    80007392:	04f95863          	bge	s2,a5,800073e2 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80007396:	85d6                	mv	a1,s5
    80007398:	854a                	mv	a0,s2
    8000739a:	00000097          	auipc	ra,0x0
    8000739e:	dd6080e7          	jalr	-554(ra) # 80007170 <blk_index_next>
    800073a2:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    800073a4:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    800073a8:	409b04bb          	subw	s1,s6,s1
    800073ac:	012c17b3          	sll	a5,s8,s2
    800073b0:	02f4c4b3          	div	s1,s1,a5
    800073b4:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    800073b6:	85aa                	mv	a1,a0
    800073b8:	854a                	mv	a0,s2
    800073ba:	00000097          	auipc	ra,0x0
    800073be:	eda080e7          	jalr	-294(ra) # 80007294 <bd_initfree_pair>
    800073c2:	01450d3b          	addw	s10,a0,s4
    800073c6:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    800073ca:	fc99d0e3          	bge	s3,s1,8000738a <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    800073ce:	85a6                	mv	a1,s1
    800073d0:	854a                	mv	a0,s2
    800073d2:	00000097          	auipc	ra,0x0
    800073d6:	ec2080e7          	jalr	-318(ra) # 80007294 <bd_initfree_pair>
    800073da:	00ad0a3b          	addw	s4,s10,a0
    800073de:	b775                	j	8000738a <bd_initfree+0x46>
  int free = 0;
    800073e0:	4a01                	li	s4,0
  }
  return free;
}
    800073e2:	8552                	mv	a0,s4
    800073e4:	60e6                	ld	ra,88(sp)
    800073e6:	6446                	ld	s0,80(sp)
    800073e8:	64a6                	ld	s1,72(sp)
    800073ea:	6906                	ld	s2,64(sp)
    800073ec:	79e2                	ld	s3,56(sp)
    800073ee:	7a42                	ld	s4,48(sp)
    800073f0:	7aa2                	ld	s5,40(sp)
    800073f2:	7b02                	ld	s6,32(sp)
    800073f4:	6be2                	ld	s7,24(sp)
    800073f6:	6c42                	ld	s8,16(sp)
    800073f8:	6ca2                	ld	s9,8(sp)
    800073fa:	6d02                	ld	s10,0(sp)
    800073fc:	6125                	addi	sp,sp,96
    800073fe:	8082                	ret

0000000080007400 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80007400:	7179                	addi	sp,sp,-48
    80007402:	f406                	sd	ra,40(sp)
    80007404:	f022                	sd	s0,32(sp)
    80007406:	ec26                	sd	s1,24(sp)
    80007408:	e84a                	sd	s2,16(sp)
    8000740a:	e44e                	sd	s3,8(sp)
    8000740c:	1800                	addi	s0,sp,48
    8000740e:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80007410:	00027997          	auipc	s3,0x27
    80007414:	c8098993          	addi	s3,s3,-896 # 8002e090 <bd_base>
    80007418:	0009b483          	ld	s1,0(s3)
    8000741c:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80007420:	00027797          	auipc	a5,0x27
    80007424:	c807a783          	lw	a5,-896(a5) # 8002e0a0 <nsizes>
    80007428:	37fd                	addiw	a5,a5,-1
    8000742a:	4641                	li	a2,16
    8000742c:	00f61633          	sll	a2,a2,a5
    80007430:	85a6                	mv	a1,s1
    80007432:	00002517          	auipc	a0,0x2
    80007436:	9d650513          	addi	a0,a0,-1578 # 80008e08 <userret+0xd78>
    8000743a:	ffff9097          	auipc	ra,0xffff9
    8000743e:	532080e7          	jalr	1330(ra) # 8000096c <printf>
  bd_mark(bd_base, p);
    80007442:	85ca                	mv	a1,s2
    80007444:	0009b503          	ld	a0,0(s3)
    80007448:	00000097          	auipc	ra,0x0
    8000744c:	d74080e7          	jalr	-652(ra) # 800071bc <bd_mark>
  return meta;
}
    80007450:	8526                	mv	a0,s1
    80007452:	70a2                	ld	ra,40(sp)
    80007454:	7402                	ld	s0,32(sp)
    80007456:	64e2                	ld	s1,24(sp)
    80007458:	6942                	ld	s2,16(sp)
    8000745a:	69a2                	ld	s3,8(sp)
    8000745c:	6145                	addi	sp,sp,48
    8000745e:	8082                	ret

0000000080007460 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80007460:	1101                	addi	sp,sp,-32
    80007462:	ec06                	sd	ra,24(sp)
    80007464:	e822                	sd	s0,16(sp)
    80007466:	e426                	sd	s1,8(sp)
    80007468:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    8000746a:	00027497          	auipc	s1,0x27
    8000746e:	c364a483          	lw	s1,-970(s1) # 8002e0a0 <nsizes>
    80007472:	fff4879b          	addiw	a5,s1,-1
    80007476:	44c1                	li	s1,16
    80007478:	00f494b3          	sll	s1,s1,a5
    8000747c:	00027797          	auipc	a5,0x27
    80007480:	c147b783          	ld	a5,-1004(a5) # 8002e090 <bd_base>
    80007484:	8d1d                	sub	a0,a0,a5
    80007486:	40a4853b          	subw	a0,s1,a0
    8000748a:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    8000748e:	00905a63          	blez	s1,800074a2 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80007492:	357d                	addiw	a0,a0,-1
    80007494:	41f5549b          	sraiw	s1,a0,0x1f
    80007498:	01c4d49b          	srliw	s1,s1,0x1c
    8000749c:	9ca9                	addw	s1,s1,a0
    8000749e:	98c1                	andi	s1,s1,-16
    800074a0:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    800074a2:	85a6                	mv	a1,s1
    800074a4:	00002517          	auipc	a0,0x2
    800074a8:	99c50513          	addi	a0,a0,-1636 # 80008e40 <userret+0xdb0>
    800074ac:	ffff9097          	auipc	ra,0xffff9
    800074b0:	4c0080e7          	jalr	1216(ra) # 8000096c <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800074b4:	00027717          	auipc	a4,0x27
    800074b8:	bdc73703          	ld	a4,-1060(a4) # 8002e090 <bd_base>
    800074bc:	00027597          	auipc	a1,0x27
    800074c0:	be45a583          	lw	a1,-1052(a1) # 8002e0a0 <nsizes>
    800074c4:	fff5879b          	addiw	a5,a1,-1
    800074c8:	45c1                	li	a1,16
    800074ca:	00f595b3          	sll	a1,a1,a5
    800074ce:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    800074d2:	95ba                	add	a1,a1,a4
    800074d4:	953a                	add	a0,a0,a4
    800074d6:	00000097          	auipc	ra,0x0
    800074da:	ce6080e7          	jalr	-794(ra) # 800071bc <bd_mark>
  return unavailable;
}
    800074de:	8526                	mv	a0,s1
    800074e0:	60e2                	ld	ra,24(sp)
    800074e2:	6442                	ld	s0,16(sp)
    800074e4:	64a2                	ld	s1,8(sp)
    800074e6:	6105                	addi	sp,sp,32
    800074e8:	8082                	ret

00000000800074ea <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    800074ea:	715d                	addi	sp,sp,-80
    800074ec:	e486                	sd	ra,72(sp)
    800074ee:	e0a2                	sd	s0,64(sp)
    800074f0:	fc26                	sd	s1,56(sp)
    800074f2:	f84a                	sd	s2,48(sp)
    800074f4:	f44e                	sd	s3,40(sp)
    800074f6:	f052                	sd	s4,32(sp)
    800074f8:	ec56                	sd	s5,24(sp)
    800074fa:	e85a                	sd	s6,16(sp)
    800074fc:	e45e                	sd	s7,8(sp)
    800074fe:	e062                	sd	s8,0(sp)
    80007500:	0880                	addi	s0,sp,80
    80007502:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80007504:	fff50493          	addi	s1,a0,-1
    80007508:	98c1                	andi	s1,s1,-16
    8000750a:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    8000750c:	00002597          	auipc	a1,0x2
    80007510:	95458593          	addi	a1,a1,-1708 # 80008e60 <userret+0xdd0>
    80007514:	00027517          	auipc	a0,0x27
    80007518:	aec50513          	addi	a0,a0,-1300 # 8002e000 <lock>
    8000751c:	ffff9097          	auipc	ra,0xffff9
    80007520:	602080e7          	jalr	1538(ra) # 80000b1e <initlock>
  bd_base = (void *) p;
    80007524:	00027797          	auipc	a5,0x27
    80007528:	b697b623          	sd	s1,-1172(a5) # 8002e090 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    8000752c:	409c0933          	sub	s2,s8,s1
    80007530:	43f95513          	srai	a0,s2,0x3f
    80007534:	893d                	andi	a0,a0,15
    80007536:	954a                	add	a0,a0,s2
    80007538:	8511                	srai	a0,a0,0x4
    8000753a:	00000097          	auipc	ra,0x0
    8000753e:	c60080e7          	jalr	-928(ra) # 8000719a <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80007542:	47c1                	li	a5,16
    80007544:	00a797b3          	sll	a5,a5,a0
    80007548:	1b27c663          	blt	a5,s2,800076f4 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    8000754c:	2505                	addiw	a0,a0,1
    8000754e:	00027797          	auipc	a5,0x27
    80007552:	b4a7a923          	sw	a0,-1198(a5) # 8002e0a0 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80007556:	00027997          	auipc	s3,0x27
    8000755a:	b4a98993          	addi	s3,s3,-1206 # 8002e0a0 <nsizes>
    8000755e:	0009a603          	lw	a2,0(s3)
    80007562:	85ca                	mv	a1,s2
    80007564:	00002517          	auipc	a0,0x2
    80007568:	90450513          	addi	a0,a0,-1788 # 80008e68 <userret+0xdd8>
    8000756c:	ffff9097          	auipc	ra,0xffff9
    80007570:	400080e7          	jalr	1024(ra) # 8000096c <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80007574:	00027797          	auipc	a5,0x27
    80007578:	b297b223          	sd	s1,-1244(a5) # 8002e098 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    8000757c:	0009a603          	lw	a2,0(s3)
    80007580:	00561913          	slli	s2,a2,0x5
    80007584:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80007586:	0056161b          	slliw	a2,a2,0x5
    8000758a:	4581                	li	a1,0
    8000758c:	8526                	mv	a0,s1
    8000758e:	ffffa097          	auipc	ra,0xffffa
    80007592:	b46080e7          	jalr	-1210(ra) # 800010d4 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80007596:	0009a783          	lw	a5,0(s3)
    8000759a:	06f05a63          	blez	a5,8000760e <bd_init+0x124>
    8000759e:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    800075a0:	00027a97          	auipc	s5,0x27
    800075a4:	af8a8a93          	addi	s5,s5,-1288 # 8002e098 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800075a8:	00027a17          	auipc	s4,0x27
    800075ac:	af8a0a13          	addi	s4,s4,-1288 # 8002e0a0 <nsizes>
    800075b0:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    800075b2:	00599b93          	slli	s7,s3,0x5
    800075b6:	000ab503          	ld	a0,0(s5)
    800075ba:	955e                	add	a0,a0,s7
    800075bc:	00000097          	auipc	ra,0x0
    800075c0:	166080e7          	jalr	358(ra) # 80007722 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800075c4:	000a2483          	lw	s1,0(s4)
    800075c8:	34fd                	addiw	s1,s1,-1
    800075ca:	413484bb          	subw	s1,s1,s3
    800075ce:	009b14bb          	sllw	s1,s6,s1
    800075d2:	fff4879b          	addiw	a5,s1,-1
    800075d6:	41f7d49b          	sraiw	s1,a5,0x1f
    800075da:	01d4d49b          	srliw	s1,s1,0x1d
    800075de:	9cbd                	addw	s1,s1,a5
    800075e0:	98e1                	andi	s1,s1,-8
    800075e2:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    800075e4:	000ab783          	ld	a5,0(s5)
    800075e8:	9bbe                	add	s7,s7,a5
    800075ea:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    800075ee:	848d                	srai	s1,s1,0x3
    800075f0:	8626                	mv	a2,s1
    800075f2:	4581                	li	a1,0
    800075f4:	854a                	mv	a0,s2
    800075f6:	ffffa097          	auipc	ra,0xffffa
    800075fa:	ade080e7          	jalr	-1314(ra) # 800010d4 <memset>
    p += sz;
    800075fe:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80007600:	0985                	addi	s3,s3,1
    80007602:	000a2703          	lw	a4,0(s4)
    80007606:	0009879b          	sext.w	a5,s3
    8000760a:	fae7c4e3          	blt	a5,a4,800075b2 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    8000760e:	00027797          	auipc	a5,0x27
    80007612:	a927a783          	lw	a5,-1390(a5) # 8002e0a0 <nsizes>
    80007616:	4705                	li	a4,1
    80007618:	06f75163          	bge	a4,a5,8000767a <bd_init+0x190>
    8000761c:	02000a13          	li	s4,32
    80007620:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80007622:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80007624:	00027b17          	auipc	s6,0x27
    80007628:	a74b0b13          	addi	s6,s6,-1420 # 8002e098 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    8000762c:	00027a97          	auipc	s5,0x27
    80007630:	a74a8a93          	addi	s5,s5,-1420 # 8002e0a0 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80007634:	37fd                	addiw	a5,a5,-1
    80007636:	413787bb          	subw	a5,a5,s3
    8000763a:	00fb94bb          	sllw	s1,s7,a5
    8000763e:	fff4879b          	addiw	a5,s1,-1
    80007642:	41f7d49b          	sraiw	s1,a5,0x1f
    80007646:	01d4d49b          	srliw	s1,s1,0x1d
    8000764a:	9cbd                	addw	s1,s1,a5
    8000764c:	98e1                	andi	s1,s1,-8
    8000764e:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007650:	000b3783          	ld	a5,0(s6)
    80007654:	97d2                	add	a5,a5,s4
    80007656:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    8000765a:	848d                	srai	s1,s1,0x3
    8000765c:	8626                	mv	a2,s1
    8000765e:	4581                	li	a1,0
    80007660:	854a                	mv	a0,s2
    80007662:	ffffa097          	auipc	ra,0xffffa
    80007666:	a72080e7          	jalr	-1422(ra) # 800010d4 <memset>
    p += sz;
    8000766a:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    8000766c:	2985                	addiw	s3,s3,1
    8000766e:	000aa783          	lw	a5,0(s5)
    80007672:	020a0a13          	addi	s4,s4,32
    80007676:	faf9cfe3          	blt	s3,a5,80007634 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    8000767a:	197d                	addi	s2,s2,-1
    8000767c:	ff097913          	andi	s2,s2,-16
    80007680:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80007682:	854a                	mv	a0,s2
    80007684:	00000097          	auipc	ra,0x0
    80007688:	d7c080e7          	jalr	-644(ra) # 80007400 <bd_mark_data_structures>
    8000768c:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    8000768e:	85ca                	mv	a1,s2
    80007690:	8562                	mv	a0,s8
    80007692:	00000097          	auipc	ra,0x0
    80007696:	dce080e7          	jalr	-562(ra) # 80007460 <bd_mark_unavailable>
    8000769a:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    8000769c:	00027a97          	auipc	s5,0x27
    800076a0:	a04a8a93          	addi	s5,s5,-1532 # 8002e0a0 <nsizes>
    800076a4:	000aa783          	lw	a5,0(s5)
    800076a8:	37fd                	addiw	a5,a5,-1
    800076aa:	44c1                	li	s1,16
    800076ac:	00f497b3          	sll	a5,s1,a5
    800076b0:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    800076b2:	00027597          	auipc	a1,0x27
    800076b6:	9de5b583          	ld	a1,-1570(a1) # 8002e090 <bd_base>
    800076ba:	95be                	add	a1,a1,a5
    800076bc:	854a                	mv	a0,s2
    800076be:	00000097          	auipc	ra,0x0
    800076c2:	c86080e7          	jalr	-890(ra) # 80007344 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    800076c6:	000aa603          	lw	a2,0(s5)
    800076ca:	367d                	addiw	a2,a2,-1
    800076cc:	00c49633          	sll	a2,s1,a2
    800076d0:	41460633          	sub	a2,a2,s4
    800076d4:	41360633          	sub	a2,a2,s3
    800076d8:	02c51463          	bne	a0,a2,80007700 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    800076dc:	60a6                	ld	ra,72(sp)
    800076de:	6406                	ld	s0,64(sp)
    800076e0:	74e2                	ld	s1,56(sp)
    800076e2:	7942                	ld	s2,48(sp)
    800076e4:	79a2                	ld	s3,40(sp)
    800076e6:	7a02                	ld	s4,32(sp)
    800076e8:	6ae2                	ld	s5,24(sp)
    800076ea:	6b42                	ld	s6,16(sp)
    800076ec:	6ba2                	ld	s7,8(sp)
    800076ee:	6c02                	ld	s8,0(sp)
    800076f0:	6161                	addi	sp,sp,80
    800076f2:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800076f4:	2509                	addiw	a0,a0,2
    800076f6:	00027797          	auipc	a5,0x27
    800076fa:	9aa7a523          	sw	a0,-1622(a5) # 8002e0a0 <nsizes>
    800076fe:	bda1                	j	80007556 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007700:	85aa                	mv	a1,a0
    80007702:	00001517          	auipc	a0,0x1
    80007706:	7a650513          	addi	a0,a0,1958 # 80008ea8 <userret+0xe18>
    8000770a:	ffff9097          	auipc	ra,0xffff9
    8000770e:	262080e7          	jalr	610(ra) # 8000096c <printf>
    panic("bd_init: free mem");
    80007712:	00001517          	auipc	a0,0x1
    80007716:	7a650513          	addi	a0,a0,1958 # 80008eb8 <userret+0xe28>
    8000771a:	ffff9097          	auipc	ra,0xffff9
    8000771e:	03c080e7          	jalr	60(ra) # 80000756 <panic>

0000000080007722 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80007722:	1141                	addi	sp,sp,-16
    80007724:	e422                	sd	s0,8(sp)
    80007726:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007728:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    8000772a:	e508                	sd	a0,8(a0)
}
    8000772c:	6422                	ld	s0,8(sp)
    8000772e:	0141                	addi	sp,sp,16
    80007730:	8082                	ret

0000000080007732 <lst_empty>:

int
lst_empty(struct list *lst) {
    80007732:	1141                	addi	sp,sp,-16
    80007734:	e422                	sd	s0,8(sp)
    80007736:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007738:	611c                	ld	a5,0(a0)
    8000773a:	40a78533          	sub	a0,a5,a0
}
    8000773e:	00153513          	seqz	a0,a0
    80007742:	6422                	ld	s0,8(sp)
    80007744:	0141                	addi	sp,sp,16
    80007746:	8082                	ret

0000000080007748 <lst_remove>:

void
lst_remove(struct list *e) {
    80007748:	1141                	addi	sp,sp,-16
    8000774a:	e422                	sd	s0,8(sp)
    8000774c:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    8000774e:	6518                	ld	a4,8(a0)
    80007750:	611c                	ld	a5,0(a0)
    80007752:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80007754:	6518                	ld	a4,8(a0)
    80007756:	e798                	sd	a4,8(a5)
}
    80007758:	6422                	ld	s0,8(sp)
    8000775a:	0141                	addi	sp,sp,16
    8000775c:	8082                	ret

000000008000775e <lst_pop>:

void*
lst_pop(struct list *lst) {
    8000775e:	1101                	addi	sp,sp,-32
    80007760:	ec06                	sd	ra,24(sp)
    80007762:	e822                	sd	s0,16(sp)
    80007764:	e426                	sd	s1,8(sp)
    80007766:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007768:	6104                	ld	s1,0(a0)
    8000776a:	00a48d63          	beq	s1,a0,80007784 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    8000776e:	8526                	mv	a0,s1
    80007770:	00000097          	auipc	ra,0x0
    80007774:	fd8080e7          	jalr	-40(ra) # 80007748 <lst_remove>
  return (void *)p;
}
    80007778:	8526                	mv	a0,s1
    8000777a:	60e2                	ld	ra,24(sp)
    8000777c:	6442                	ld	s0,16(sp)
    8000777e:	64a2                	ld	s1,8(sp)
    80007780:	6105                	addi	sp,sp,32
    80007782:	8082                	ret
    panic("lst_pop");
    80007784:	00001517          	auipc	a0,0x1
    80007788:	74c50513          	addi	a0,a0,1868 # 80008ed0 <userret+0xe40>
    8000778c:	ffff9097          	auipc	ra,0xffff9
    80007790:	fca080e7          	jalr	-54(ra) # 80000756 <panic>

0000000080007794 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80007794:	1141                	addi	sp,sp,-16
    80007796:	e422                	sd	s0,8(sp)
    80007798:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    8000779a:	611c                	ld	a5,0(a0)
    8000779c:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    8000779e:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800077a0:	611c                	ld	a5,0(a0)
    800077a2:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800077a4:	e10c                	sd	a1,0(a0)
}
    800077a6:	6422                	ld	s0,8(sp)
    800077a8:	0141                	addi	sp,sp,16
    800077aa:	8082                	ret

00000000800077ac <lst_print>:

void
lst_print(struct list *lst)
{
    800077ac:	7179                	addi	sp,sp,-48
    800077ae:	f406                	sd	ra,40(sp)
    800077b0:	f022                	sd	s0,32(sp)
    800077b2:	ec26                	sd	s1,24(sp)
    800077b4:	e84a                	sd	s2,16(sp)
    800077b6:	e44e                	sd	s3,8(sp)
    800077b8:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800077ba:	6104                	ld	s1,0(a0)
    800077bc:	02950063          	beq	a0,s1,800077dc <lst_print+0x30>
    800077c0:	892a                	mv	s2,a0
    printf(" %p", p);
    800077c2:	00001997          	auipc	s3,0x1
    800077c6:	71698993          	addi	s3,s3,1814 # 80008ed8 <userret+0xe48>
    800077ca:	85a6                	mv	a1,s1
    800077cc:	854e                	mv	a0,s3
    800077ce:	ffff9097          	auipc	ra,0xffff9
    800077d2:	19e080e7          	jalr	414(ra) # 8000096c <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800077d6:	6084                	ld	s1,0(s1)
    800077d8:	fe9919e3          	bne	s2,s1,800077ca <lst_print+0x1e>
  }
  printf("\n");
    800077dc:	00001517          	auipc	a0,0x1
    800077e0:	e6c50513          	addi	a0,a0,-404 # 80008648 <userret+0x5b8>
    800077e4:	ffff9097          	auipc	ra,0xffff9
    800077e8:	188080e7          	jalr	392(ra) # 8000096c <printf>
}
    800077ec:	70a2                	ld	ra,40(sp)
    800077ee:	7402                	ld	s0,32(sp)
    800077f0:	64e2                	ld	s1,24(sp)
    800077f2:	6942                	ld	s2,16(sp)
    800077f4:	69a2                	ld	s3,8(sp)
    800077f6:	6145                	addi	sp,sp,48
    800077f8:	8082                	ret

00000000800077fa <watchdogwrite>:
int watchdog_time;
struct spinlock watchdog_lock;

int
watchdogwrite(struct file *f, int user_src, uint64 src, int n)
{
    800077fa:	715d                	addi	sp,sp,-80
    800077fc:	e486                	sd	ra,72(sp)
    800077fe:	e0a2                	sd	s0,64(sp)
    80007800:	fc26                	sd	s1,56(sp)
    80007802:	f84a                	sd	s2,48(sp)
    80007804:	f44e                	sd	s3,40(sp)
    80007806:	f052                	sd	s4,32(sp)
    80007808:	ec56                	sd	s5,24(sp)
    8000780a:	0880                	addi	s0,sp,80
    8000780c:	89ae                	mv	s3,a1
    8000780e:	84b2                	mv	s1,a2
    80007810:	8a36                	mv	s4,a3
  acquire(&watchdog_lock);
    80007812:	00027517          	auipc	a0,0x27
    80007816:	81e50513          	addi	a0,a0,-2018 # 8002e030 <watchdog_lock>
    8000781a:	ffff9097          	auipc	ra,0xffff9
    8000781e:	46e080e7          	jalr	1134(ra) # 80000c88 <acquire>

  int time = 0;
  for(int i = 0; i < n; i++){
    80007822:	09405d63          	blez	s4,800078bc <watchdogwrite+0xc2>
    80007826:	00148913          	addi	s2,s1,1
    8000782a:	3a7d                	addiw	s4,s4,-1
    8000782c:	1a02                	slli	s4,s4,0x20
    8000782e:	020a5a13          	srli	s4,s4,0x20
    80007832:	9952                	add	s2,s2,s4
  int time = 0;
    80007834:	4a01                	li	s4,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80007836:	5afd                	li	s5,-1
    80007838:	4685                	li	a3,1
    8000783a:	8626                	mv	a2,s1
    8000783c:	85ce                	mv	a1,s3
    8000783e:	fbf40513          	addi	a0,s0,-65
    80007842:	ffffb097          	auipc	ra,0xffffb
    80007846:	240080e7          	jalr	576(ra) # 80002a82 <either_copyin>
    8000784a:	01550763          	beq	a0,s5,80007858 <watchdogwrite+0x5e>
      break;
    time = c;
    8000784e:	fbf44a03          	lbu	s4,-65(s0)
  for(int i = 0; i < n; i++){
    80007852:	0485                	addi	s1,s1,1
    80007854:	ff2492e3          	bne	s1,s2,80007838 <watchdogwrite+0x3e>
  }

  acquire(&tickslock);
    80007858:	00015517          	auipc	a0,0x15
    8000785c:	84050513          	addi	a0,a0,-1984 # 8001c098 <tickslock>
    80007860:	ffff9097          	auipc	ra,0xffff9
    80007864:	428080e7          	jalr	1064(ra) # 80000c88 <acquire>
  n = ticks - watchdog_value;
    80007868:	00027717          	auipc	a4,0x27
    8000786c:	82072703          	lw	a4,-2016(a4) # 8002e088 <ticks>
    80007870:	00027797          	auipc	a5,0x27
    80007874:	83878793          	addi	a5,a5,-1992 # 8002e0a8 <watchdog_value>
    80007878:	4384                	lw	s1,0(a5)
    8000787a:	409704bb          	subw	s1,a4,s1
  watchdog_value = ticks;
    8000787e:	c398                	sw	a4,0(a5)
  watchdog_time = time;
    80007880:	00027797          	auipc	a5,0x27
    80007884:	8347a223          	sw	s4,-2012(a5) # 8002e0a4 <watchdog_time>
  release(&tickslock);
    80007888:	00015517          	auipc	a0,0x15
    8000788c:	81050513          	addi	a0,a0,-2032 # 8001c098 <tickslock>
    80007890:	ffff9097          	auipc	ra,0xffff9
    80007894:	644080e7          	jalr	1604(ra) # 80000ed4 <release>

  release(&watchdog_lock);
    80007898:	00026517          	auipc	a0,0x26
    8000789c:	79850513          	addi	a0,a0,1944 # 8002e030 <watchdog_lock>
    800078a0:	ffff9097          	auipc	ra,0xffff9
    800078a4:	634080e7          	jalr	1588(ra) # 80000ed4 <release>
  return n;
}
    800078a8:	8526                	mv	a0,s1
    800078aa:	60a6                	ld	ra,72(sp)
    800078ac:	6406                	ld	s0,64(sp)
    800078ae:	74e2                	ld	s1,56(sp)
    800078b0:	7942                	ld	s2,48(sp)
    800078b2:	79a2                	ld	s3,40(sp)
    800078b4:	7a02                	ld	s4,32(sp)
    800078b6:	6ae2                	ld	s5,24(sp)
    800078b8:	6161                	addi	sp,sp,80
    800078ba:	8082                	ret
  int time = 0;
    800078bc:	4a01                	li	s4,0
    800078be:	bf69                	j	80007858 <watchdogwrite+0x5e>

00000000800078c0 <watchdoginit>:

void watchdoginit(){
    800078c0:	1141                	addi	sp,sp,-16
    800078c2:	e406                	sd	ra,8(sp)
    800078c4:	e022                	sd	s0,0(sp)
    800078c6:	0800                	addi	s0,sp,16
  initlock(&watchdog_lock, "watchdog_lock");
    800078c8:	00001597          	auipc	a1,0x1
    800078cc:	61858593          	addi	a1,a1,1560 # 80008ee0 <userret+0xe50>
    800078d0:	00026517          	auipc	a0,0x26
    800078d4:	76050513          	addi	a0,a0,1888 # 8002e030 <watchdog_lock>
    800078d8:	ffff9097          	auipc	ra,0xffff9
    800078dc:	246080e7          	jalr	582(ra) # 80000b1e <initlock>
  watchdog_time = 0;
    800078e0:	00026797          	auipc	a5,0x26
    800078e4:	7c07a223          	sw	zero,1988(a5) # 8002e0a4 <watchdog_time>


  devsw[WATCHDOG].read = 0;
    800078e8:	0001f797          	auipc	a5,0x1f
    800078ec:	2b078793          	addi	a5,a5,688 # 80026b98 <devsw>
    800078f0:	0207b023          	sd	zero,32(a5)
  devsw[WATCHDOG].write = watchdogwrite;
    800078f4:	00000717          	auipc	a4,0x0
    800078f8:	f0670713          	addi	a4,a4,-250 # 800077fa <watchdogwrite>
    800078fc:	f798                	sd	a4,40(a5)
}
    800078fe:	60a2                	ld	ra,8(sp)
    80007900:	6402                	ld	s0,0(sp)
    80007902:	0141                	addi	sp,sp,16
    80007904:	8082                	ret
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
