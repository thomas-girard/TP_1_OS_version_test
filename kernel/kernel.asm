
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
    80000016:	072000ef          	jal	ra,80000088 <start>

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
    80000026:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000028:	0037969b          	slliw	a3,a5,0x3
    8000002c:	02004737          	lui	a4,0x2004
    80000030:	96ba                	add	a3,a3,a4
    80000032:	0200c737          	lui	a4,0x200c
    80000036:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003a:	000f4737          	lui	a4,0xf4
    8000003e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000042:	963a                	add	a2,a2,a4
    80000044:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000046:	0057979b          	slliw	a5,a5,0x5
    8000004a:	078e                	slli	a5,a5,0x3
    8000004c:	0000b617          	auipc	a2,0xb
    80000050:	fb460613          	addi	a2,a2,-76 # 8000b000 <mscratch0>
    80000054:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000056:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000058:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005a:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005e:	00006797          	auipc	a5,0x6
    80000062:	64278793          	addi	a5,a5,1602 # 800066a0 <timervec>
    80000066:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000072:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000076:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007e:	30479073          	csrw	mie,a5
}
    80000082:	6422                	ld	s0,8(sp)
    80000084:	0141                	addi	sp,sp,16
    80000086:	8082                	ret

0000000080000088 <start>:
{
    80000088:	1141                	addi	sp,sp,-16
    8000008a:	e406                	sd	ra,8(sp)
    8000008c:	e022                	sd	s0,0(sp)
    8000008e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000090:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000094:	7779                	lui	a4,0xffffe
    80000096:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd0753>
    8000009a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009c:	6705                	lui	a4,0x1
    8000009e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a8:	00001797          	auipc	a5,0x1
    800000ac:	33c78793          	addi	a5,a5,828 # 800013e4 <main>
    800000b0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b4:	4781                	li	a5,0
    800000b6:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000ba:	67c1                	lui	a5,0x10
    800000bc:	17fd                	addi	a5,a5,-1
    800000be:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c2:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ca:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000ce:	10479073          	csrw	sie,a5
  timerinit();
    800000d2:	00000097          	auipc	ra,0x0
    800000d6:	f4a080e7          	jalr	-182(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000da:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000de:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e0:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e2:	30200073          	mret
}
    800000e6:	60a2                	ld	ra,8(sp)
    800000e8:	6402                	ld	s0,0(sp)
    800000ea:	0141                	addi	sp,sp,16
    800000ec:	8082                	ret

00000000800000ee <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(struct file *f, int user_dst, uint64 dst, int n)
{
    800000ee:	7159                	addi	sp,sp,-112
    800000f0:	f486                	sd	ra,104(sp)
    800000f2:	f0a2                	sd	s0,96(sp)
    800000f4:	eca6                	sd	s1,88(sp)
    800000f6:	e8ca                	sd	s2,80(sp)
    800000f8:	e4ce                	sd	s3,72(sp)
    800000fa:	e0d2                	sd	s4,64(sp)
    800000fc:	fc56                	sd	s5,56(sp)
    800000fe:	f85a                	sd	s6,48(sp)
    80000100:	f45e                	sd	s7,40(sp)
    80000102:	f062                	sd	s8,32(sp)
    80000104:	ec66                	sd	s9,24(sp)
    80000106:	e86a                	sd	s10,16(sp)
    80000108:	1880                	addi	s0,sp,112
    8000010a:	84aa                	mv	s1,a0
    8000010c:	8bae                	mv	s7,a1
    8000010e:	8ab2                	mv	s5,a2
    80000110:	8a36                	mv	s4,a3
  uint target;
  int c;
  char cbuf;

  target = n;
    80000112:	00068b1b          	sext.w	s6,a3
  struct cons_t* cons = &consoles[f->minor-1];
    80000116:	02651983          	lh	s3,38(a0) # 1026 <_entry-0x7fffefda>
    8000011a:	39fd                	addiw	s3,s3,-1
    8000011c:	00199d13          	slli	s10,s3,0x1
    80000120:	9d4e                	add	s10,s10,s3
    80000122:	0d1a                	slli	s10,s10,0x6
    80000124:	00013917          	auipc	s2,0x13
    80000128:	6dc90913          	addi	s2,s2,1756 # 80013800 <consoles>
    8000012c:	996a                	add	s2,s2,s10
  acquire(&console_number_lock);
    8000012e:	00014517          	auipc	a0,0x14
    80000132:	91250513          	addi	a0,a0,-1774 # 80013a40 <console_number_lock>
    80000136:	00001097          	auipc	ra,0x1
    8000013a:	b84080e7          	jalr	-1148(ra) # 80000cba <acquire>
  while(console_number != f->minor - 1){
    8000013e:	02649783          	lh	a5,38(s1)
    80000142:	37fd                	addiw	a5,a5,-1
    80000144:	0002e717          	auipc	a4,0x2e
    80000148:	f2470713          	addi	a4,a4,-220 # 8002e068 <console_number>
    8000014c:	4318                	lw	a4,0(a4)
    8000014e:	02e78763          	beq	a5,a4,8000017c <consoleread+0x8e>
    sleep(cons, &console_number_lock);
    80000152:	00014c97          	auipc	s9,0x14
    80000156:	8eec8c93          	addi	s9,s9,-1810 # 80013a40 <console_number_lock>
  while(console_number != f->minor - 1){
    8000015a:	0002ec17          	auipc	s8,0x2e
    8000015e:	f0ec0c13          	addi	s8,s8,-242 # 8002e068 <console_number>
    sleep(cons, &console_number_lock);
    80000162:	85e6                	mv	a1,s9
    80000164:	854a                	mv	a0,s2
    80000166:	00002097          	auipc	ra,0x2
    8000016a:	7cc080e7          	jalr	1996(ra) # 80002932 <sleep>
  while(console_number != f->minor - 1){
    8000016e:	02649783          	lh	a5,38(s1)
    80000172:	37fd                	addiw	a5,a5,-1
    80000174:	000c2703          	lw	a4,0(s8)
    80000178:	fee795e3          	bne	a5,a4,80000162 <consoleread+0x74>
  }
  release(&console_number_lock);
    8000017c:	00014517          	auipc	a0,0x14
    80000180:	8c450513          	addi	a0,a0,-1852 # 80013a40 <console_number_lock>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	d82080e7          	jalr	-638(ra) # 80000f06 <release>
  acquire(&cons->lock);
    8000018c:	854a                	mv	a0,s2
    8000018e:	00001097          	auipc	ra,0x1
    80000192:	b2c080e7          	jalr	-1236(ra) # 80000cba <acquire>
  while(n > 0){
    80000196:	09405c63          	blez	s4,8000022e <consoleread+0x140>
    while(cons->r == cons->w){
      if(myproc()->killed){
        release(&cons->lock);
        return -1;
      }
      sleep(&cons->r, &cons->lock);
    8000019a:	00013797          	auipc	a5,0x13
    8000019e:	71678793          	addi	a5,a5,1814 # 800138b0 <consoles+0xb0>
    800001a2:	9d3e                	add	s10,s10,a5
    while(cons->r == cons->w){
    800001a4:	00199493          	slli	s1,s3,0x1
    800001a8:	94ce                	add	s1,s1,s3
    800001aa:	00649793          	slli	a5,s1,0x6
    800001ae:	00013497          	auipc	s1,0x13
    800001b2:	65248493          	addi	s1,s1,1618 # 80013800 <consoles>
    800001b6:	94be                	add	s1,s1,a5
    800001b8:	0b04a783          	lw	a5,176(s1)
    800001bc:	0b44a703          	lw	a4,180(s1)
    800001c0:	02f71463          	bne	a4,a5,800001e8 <consoleread+0xfa>
      if(myproc()->killed){
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	e7c080e7          	jalr	-388(ra) # 80002040 <myproc>
    800001cc:	453c                	lw	a5,72(a0)
    800001ce:	eba5                	bnez	a5,8000023e <consoleread+0x150>
      sleep(&cons->r, &cons->lock);
    800001d0:	85ca                	mv	a1,s2
    800001d2:	856a                	mv	a0,s10
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	75e080e7          	jalr	1886(ra) # 80002932 <sleep>
    while(cons->r == cons->w){
    800001dc:	0b04a783          	lw	a5,176(s1)
    800001e0:	0b44a703          	lw	a4,180(s1)
    800001e4:	fef700e3          	beq	a4,a5,800001c4 <consoleread+0xd6>
    }

    c = cons->buf[cons->r++ % INPUT_BUF];
    800001e8:	0017871b          	addiw	a4,a5,1
    800001ec:	0ae4a823          	sw	a4,176(s1)
    800001f0:	07f7f713          	andi	a4,a5,127
    800001f4:	9726                	add	a4,a4,s1
    800001f6:	03074703          	lbu	a4,48(a4)
    800001fa:	00070c1b          	sext.w	s8,a4

    if(c == C('D')){  // end-of-file
    800001fe:	4691                	li	a3,4
    80000200:	06dc0363          	beq	s8,a3,80000266 <consoleread+0x178>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d6                	mv	a1,s5
    80000210:	855e                	mv	a0,s7
    80000212:	00003097          	auipc	ra,0x3
    80000216:	982080e7          	jalr	-1662(ra) # 80002b94 <either_copyout>
    8000021a:	57fd                	li	a5,-1
    8000021c:	00f50963          	beq	a0,a5,8000022e <consoleread+0x140>
      break;

    dst++;
    80000220:	0a85                	addi	s5,s5,1
    --n;
    80000222:	3a7d                	addiw	s4,s4,-1

    if(c == '\n'){
    80000224:	47a9                	li	a5,10
    80000226:	00fc0463          	beq	s8,a5,8000022e <consoleread+0x140>
  while(n > 0){
    8000022a:	f80a17e3          	bnez	s4,800001b8 <consoleread+0xca>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons->lock);
    8000022e:	854a                	mv	a0,s2
    80000230:	00001097          	auipc	ra,0x1
    80000234:	cd6080e7          	jalr	-810(ra) # 80000f06 <release>

  return target - n;
    80000238:	414b053b          	subw	a0,s6,s4
    8000023c:	a039                	j	8000024a <consoleread+0x15c>
        release(&cons->lock);
    8000023e:	854a                	mv	a0,s2
    80000240:	00001097          	auipc	ra,0x1
    80000244:	cc6080e7          	jalr	-826(ra) # 80000f06 <release>
        return -1;
    80000248:	557d                	li	a0,-1
}
    8000024a:	70a6                	ld	ra,104(sp)
    8000024c:	7406                	ld	s0,96(sp)
    8000024e:	64e6                	ld	s1,88(sp)
    80000250:	6946                	ld	s2,80(sp)
    80000252:	69a6                	ld	s3,72(sp)
    80000254:	6a06                	ld	s4,64(sp)
    80000256:	7ae2                	ld	s5,56(sp)
    80000258:	7b42                	ld	s6,48(sp)
    8000025a:	7ba2                	ld	s7,40(sp)
    8000025c:	7c02                	ld	s8,32(sp)
    8000025e:	6ce2                	ld	s9,24(sp)
    80000260:	6d42                	ld	s10,16(sp)
    80000262:	6165                	addi	sp,sp,112
    80000264:	8082                	ret
      if(n < target){
    80000266:	000a071b          	sext.w	a4,s4
    8000026a:	fd6772e3          	bleu	s6,a4,8000022e <consoleread+0x140>
        cons->r--;
    8000026e:	00199713          	slli	a4,s3,0x1
    80000272:	974e                	add	a4,a4,s3
    80000274:	071a                	slli	a4,a4,0x6
    80000276:	00013697          	auipc	a3,0x13
    8000027a:	58a68693          	addi	a3,a3,1418 # 80013800 <consoles>
    8000027e:	9736                	add	a4,a4,a3
    80000280:	0af72823          	sw	a5,176(a4)
    80000284:	b76d                	j	8000022e <consoleread+0x140>

0000000080000286 <consputc>:
  if(panicked){
    80000286:	0002e797          	auipc	a5,0x2e
    8000028a:	de678793          	addi	a5,a5,-538 # 8002e06c <panicked>
    8000028e:	439c                	lw	a5,0(a5)
    80000290:	2781                	sext.w	a5,a5
    80000292:	c391                	beqz	a5,80000296 <consputc+0x10>
      ;
    80000294:	a001                	j	80000294 <consputc+0xe>
{
    80000296:	1141                	addi	sp,sp,-16
    80000298:	e406                	sd	ra,8(sp)
    8000029a:	e022                	sd	s0,0(sp)
    8000029c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000029e:	10000793          	li	a5,256
    800002a2:	00f50a63          	beq	a0,a5,800002b6 <consputc+0x30>
    uartputc(c);
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	7d2080e7          	jalr	2002(ra) # 80000a78 <uartputc>
}
    800002ae:	60a2                	ld	ra,8(sp)
    800002b0:	6402                	ld	s0,0(sp)
    800002b2:	0141                	addi	sp,sp,16
    800002b4:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    800002b6:	4521                	li	a0,8
    800002b8:	00000097          	auipc	ra,0x0
    800002bc:	7c0080e7          	jalr	1984(ra) # 80000a78 <uartputc>
    800002c0:	02000513          	li	a0,32
    800002c4:	00000097          	auipc	ra,0x0
    800002c8:	7b4080e7          	jalr	1972(ra) # 80000a78 <uartputc>
    800002cc:	4521                	li	a0,8
    800002ce:	00000097          	auipc	ra,0x0
    800002d2:	7aa080e7          	jalr	1962(ra) # 80000a78 <uartputc>
    800002d6:	bfe1                	j	800002ae <consputc+0x28>

00000000800002d8 <consolewrite>:
{
    800002d8:	711d                	addi	sp,sp,-96
    800002da:	ec86                	sd	ra,88(sp)
    800002dc:	e8a2                	sd	s0,80(sp)
    800002de:	e4a6                	sd	s1,72(sp)
    800002e0:	e0ca                	sd	s2,64(sp)
    800002e2:	fc4e                	sd	s3,56(sp)
    800002e4:	f852                	sd	s4,48(sp)
    800002e6:	f456                	sd	s5,40(sp)
    800002e8:	f05a                	sd	s6,32(sp)
    800002ea:	ec5e                	sd	s7,24(sp)
    800002ec:	1080                	addi	s0,sp,96
    800002ee:	89aa                	mv	s3,a0
    800002f0:	8a2e                	mv	s4,a1
    800002f2:	84b2                	mv	s1,a2
    800002f4:	8ab6                	mv	s5,a3
  struct cons_t* cons = &consoles[f->minor-1];
    800002f6:	02651783          	lh	a5,38(a0)
    800002fa:	37fd                	addiw	a5,a5,-1
    800002fc:	00179913          	slli	s2,a5,0x1
    80000300:	993e                	add	s2,s2,a5
    80000302:	00691793          	slli	a5,s2,0x6
    80000306:	00013917          	auipc	s2,0x13
    8000030a:	4fa90913          	addi	s2,s2,1274 # 80013800 <consoles>
    8000030e:	993e                	add	s2,s2,a5
  acquire(&console_number_lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	73050513          	addi	a0,a0,1840 # 80013a40 <console_number_lock>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	9a2080e7          	jalr	-1630(ra) # 80000cba <acquire>
  while(console_number != f->minor - 1){
    80000320:	02699783          	lh	a5,38(s3)
    80000324:	37fd                	addiw	a5,a5,-1
    80000326:	0002e717          	auipc	a4,0x2e
    8000032a:	d4270713          	addi	a4,a4,-702 # 8002e068 <console_number>
    8000032e:	4318                	lw	a4,0(a4)
    80000330:	02e78763          	beq	a5,a4,8000035e <consolewrite+0x86>
    sleep(cons, &console_number_lock);
    80000334:	00013b97          	auipc	s7,0x13
    80000338:	70cb8b93          	addi	s7,s7,1804 # 80013a40 <console_number_lock>
  while(console_number != f->minor - 1){
    8000033c:	0002eb17          	auipc	s6,0x2e
    80000340:	d2cb0b13          	addi	s6,s6,-724 # 8002e068 <console_number>
    sleep(cons, &console_number_lock);
    80000344:	85de                	mv	a1,s7
    80000346:	854a                	mv	a0,s2
    80000348:	00002097          	auipc	ra,0x2
    8000034c:	5ea080e7          	jalr	1514(ra) # 80002932 <sleep>
  while(console_number != f->minor - 1){
    80000350:	02699783          	lh	a5,38(s3)
    80000354:	37fd                	addiw	a5,a5,-1
    80000356:	000b2703          	lw	a4,0(s6)
    8000035a:	fee795e3          	bne	a5,a4,80000344 <consolewrite+0x6c>
  release(&console_number_lock);
    8000035e:	00013517          	auipc	a0,0x13
    80000362:	6e250513          	addi	a0,a0,1762 # 80013a40 <console_number_lock>
    80000366:	00001097          	auipc	ra,0x1
    8000036a:	ba0080e7          	jalr	-1120(ra) # 80000f06 <release>
  acquire(&cons->lock);
    8000036e:	854a                	mv	a0,s2
    80000370:	00001097          	auipc	ra,0x1
    80000374:	94a080e7          	jalr	-1718(ra) # 80000cba <acquire>
  for(i = 0; i < n; i++){
    80000378:	03505e63          	blez	s5,800003b4 <consolewrite+0xdc>
    8000037c:	00148993          	addi	s3,s1,1
    80000380:	fffa879b          	addiw	a5,s5,-1
    80000384:	1782                	slli	a5,a5,0x20
    80000386:	9381                	srli	a5,a5,0x20
    80000388:	99be                	add	s3,s3,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000038a:	5b7d                	li	s6,-1
    8000038c:	4685                	li	a3,1
    8000038e:	8626                	mv	a2,s1
    80000390:	85d2                	mv	a1,s4
    80000392:	faf40513          	addi	a0,s0,-81
    80000396:	00003097          	auipc	ra,0x3
    8000039a:	854080e7          	jalr	-1964(ra) # 80002bea <either_copyin>
    8000039e:	01650b63          	beq	a0,s6,800003b4 <consolewrite+0xdc>
    consputc(c);
    800003a2:	faf44503          	lbu	a0,-81(s0)
    800003a6:	00000097          	auipc	ra,0x0
    800003aa:	ee0080e7          	jalr	-288(ra) # 80000286 <consputc>
    800003ae:	0485                	addi	s1,s1,1
  for(i = 0; i < n; i++){
    800003b0:	fd349ee3          	bne	s1,s3,8000038c <consolewrite+0xb4>
  release(&cons->lock);
    800003b4:	854a                	mv	a0,s2
    800003b6:	00001097          	auipc	ra,0x1
    800003ba:	b50080e7          	jalr	-1200(ra) # 80000f06 <release>
}
    800003be:	8556                	mv	a0,s5
    800003c0:	60e6                	ld	ra,88(sp)
    800003c2:	6446                	ld	s0,80(sp)
    800003c4:	64a6                	ld	s1,72(sp)
    800003c6:	6906                	ld	s2,64(sp)
    800003c8:	79e2                	ld	s3,56(sp)
    800003ca:	7a42                	ld	s4,48(sp)
    800003cc:	7aa2                	ld	s5,40(sp)
    800003ce:	7b02                	ld	s6,32(sp)
    800003d0:	6be2                	ld	s7,24(sp)
    800003d2:	6125                	addi	sp,sp,96
    800003d4:	8082                	ret

00000000800003d6 <consoleintr>:
// do erase/kill processing, append to cons->buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800003d6:	7179                	addi	sp,sp,-48
    800003d8:	f406                	sd	ra,40(sp)
    800003da:	f022                	sd	s0,32(sp)
    800003dc:	ec26                	sd	s1,24(sp)
    800003de:	e84a                	sd	s2,16(sp)
    800003e0:	e44e                	sd	s3,8(sp)
    800003e2:	e052                	sd	s4,0(sp)
    800003e4:	1800                	addi	s0,sp,48
    800003e6:	84aa                	mv	s1,a0
  acquire(&cons->lock);
    800003e8:	0002e797          	auipc	a5,0x2e
    800003ec:	c7878793          	addi	a5,a5,-904 # 8002e060 <cons>
    800003f0:	6388                	ld	a0,0(a5)
    800003f2:	00001097          	auipc	ra,0x1
    800003f6:	8c8080e7          	jalr	-1848(ra) # 80000cba <acquire>

  switch(c){
    800003fa:	47c5                	li	a5,17
    800003fc:	1af48c63          	beq	s1,a5,800005b4 <consoleintr+0x1de>
    80000400:	0a97d063          	ble	s1,a5,800004a0 <consoleintr+0xca>
    80000404:	47d5                	li	a5,21
    80000406:	10f48d63          	beq	s1,a5,80000520 <consoleintr+0x14a>
    8000040a:	07f00793          	li	a5,127
    8000040e:	1af48d63          	beq	s1,a5,800005c8 <consoleintr+0x1f2>
    80000412:	47cd                	li	a5,19
    80000414:	08f49f63          	bne	s1,a5,800004b2 <consoleintr+0xdc>
      consputc(BACKSPACE);
    }
    break;
  case C('S'): // switch consoles
  {
    acquire(&console_number_lock);
    80000418:	00013997          	auipc	s3,0x13
    8000041c:	62898993          	addi	s3,s3,1576 # 80013a40 <console_number_lock>
    80000420:	854e                	mv	a0,s3
    80000422:	00001097          	auipc	ra,0x1
    80000426:	898080e7          	jalr	-1896(ra) # 80000cba <acquire>
    struct spinlock* old = &cons->lock;
    8000042a:	0002e917          	auipc	s2,0x2e
    8000042e:	c3690913          	addi	s2,s2,-970 # 8002e060 <cons>
    80000432:	00093a03          	ld	s4,0(s2)
    console_number = (console_number + 1) % NBCONSOLES;
    80000436:	0002e497          	auipc	s1,0x2e
    8000043a:	c3248493          	addi	s1,s1,-974 # 8002e068 <console_number>
    8000043e:	409c                	lw	a5,0(s1)
    80000440:	2785                	addiw	a5,a5,1
    80000442:	470d                	li	a4,3
    80000444:	02e7e7bb          	remw	a5,a5,a4
    80000448:	0007871b          	sext.w	a4,a5
    8000044c:	c09c                	sw	a5,0(s1)
    cons = &consoles[console_number];
    8000044e:	00171513          	slli	a0,a4,0x1
    80000452:	953a                	add	a0,a0,a4
    80000454:	051a                	slli	a0,a0,0x6
    80000456:	00013797          	auipc	a5,0x13
    8000045a:	3aa78793          	addi	a5,a5,938 # 80013800 <consoles>
    8000045e:	953e                	add	a0,a0,a5
    80000460:	00a93023          	sd	a0,0(s2)
    acquire(&cons->lock);
    80000464:	00001097          	auipc	ra,0x1
    80000468:	856080e7          	jalr	-1962(ra) # 80000cba <acquire>
    release(old);
    8000046c:	8552                	mv	a0,s4
    8000046e:	00001097          	auipc	ra,0x1
    80000472:	a98080e7          	jalr	-1384(ra) # 80000f06 <release>
    wakeup(cons);
    80000476:	00093503          	ld	a0,0(s2)
    8000047a:	00002097          	auipc	ra,0x2
    8000047e:	63e080e7          	jalr	1598(ra) # 80002ab8 <wakeup>
    printf("Switched to console number %d\n", console_number);
    80000482:	408c                	lw	a1,0(s1)
    80000484:	00008517          	auipc	a0,0x8
    80000488:	c9450513          	addi	a0,a0,-876 # 80008118 <userret+0x88>
    8000048c:	00000097          	auipc	ra,0x0
    80000490:	510080e7          	jalr	1296(ra) # 8000099c <printf>
    release(&console_number_lock);
    80000494:	854e                	mv	a0,s3
    80000496:	00001097          	auipc	ra,0x1
    8000049a:	a70080e7          	jalr	-1424(ra) # 80000f06 <release>
    break;
    8000049e:	a8d5                	j	80000592 <consoleintr+0x1bc>
  switch(c){
    800004a0:	47b1                	li	a5,12
    800004a2:	10f48e63          	beq	s1,a5,800005be <consoleintr+0x1e8>
    800004a6:	47c1                	li	a5,16
    800004a8:	0ef48163          	beq	s1,a5,8000058a <consoleintr+0x1b4>
    800004ac:	47a1                	li	a5,8
    800004ae:	10f48d63          	beq	s1,a5,800005c8 <consoleintr+0x1f2>
      cons->e--;
      consputc(BACKSPACE);
    }
    break;
  default:
    if(c != 0 && cons->e-cons->r < INPUT_BUF){
    800004b2:	c0e5                	beqz	s1,80000592 <consoleintr+0x1bc>
    800004b4:	0002e797          	auipc	a5,0x2e
    800004b8:	bac78793          	addi	a5,a5,-1108 # 8002e060 <cons>
    800004bc:	6398                	ld	a4,0(a5)
    800004be:	0b872783          	lw	a5,184(a4)
    800004c2:	0b072703          	lw	a4,176(a4)
    800004c6:	9f99                	subw	a5,a5,a4
    800004c8:	07f00713          	li	a4,127
    800004cc:	0cf76363          	bltu	a4,a5,80000592 <consoleintr+0x1bc>
      c = (c == '\r') ? '\n' : c;
    800004d0:	47b5                	li	a5,13
    800004d2:	12f48063          	beq	s1,a5,800005f2 <consoleintr+0x21c>

      // echo back to the user.
      consputc(c);
    800004d6:	8526                	mv	a0,s1
    800004d8:	00000097          	auipc	ra,0x0
    800004dc:	dae080e7          	jalr	-594(ra) # 80000286 <consputc>

      // store for consumption by consoleread().
      cons->buf[cons->e++ % INPUT_BUF] = c;
    800004e0:	0002e797          	auipc	a5,0x2e
    800004e4:	b8078793          	addi	a5,a5,-1152 # 8002e060 <cons>
    800004e8:	6388                	ld	a0,0(a5)
    800004ea:	0b852783          	lw	a5,184(a0)
    800004ee:	0017871b          	addiw	a4,a5,1
    800004f2:	0007069b          	sext.w	a3,a4
    800004f6:	0ae52c23          	sw	a4,184(a0)
    800004fa:	07f7f793          	andi	a5,a5,127
    800004fe:	97aa                	add	a5,a5,a0
    80000500:	02978823          	sb	s1,48(a5)

      if(c == '\n' || c == C('D') || cons->e == cons->r+INPUT_BUF){
    80000504:	47a9                	li	a5,10
    80000506:	10f48e63          	beq	s1,a5,80000622 <consoleintr+0x24c>
    8000050a:	4791                	li	a5,4
    8000050c:	10f48b63          	beq	s1,a5,80000622 <consoleintr+0x24c>
    80000510:	0b052783          	lw	a5,176(a0)
    80000514:	0807879b          	addiw	a5,a5,128
    80000518:	06f69d63          	bne	a3,a5,80000592 <consoleintr+0x1bc>
      cons->buf[cons->e++ % INPUT_BUF] = c;
    8000051c:	86be                	mv	a3,a5
    8000051e:	a211                	j	80000622 <consoleintr+0x24c>
    while(cons->e != cons->w &&
    80000520:	0002e797          	auipc	a5,0x2e
    80000524:	b4078793          	addi	a5,a5,-1216 # 8002e060 <cons>
    80000528:	6398                	ld	a4,0(a5)
    8000052a:	0b872783          	lw	a5,184(a4)
    8000052e:	0b472683          	lw	a3,180(a4)
    80000532:	06f68063          	beq	a3,a5,80000592 <consoleintr+0x1bc>
          cons->buf[(cons->e-1) % INPUT_BUF] != '\n'){
    80000536:	37fd                	addiw	a5,a5,-1
    80000538:	0007869b          	sext.w	a3,a5
    8000053c:	07f7f793          	andi	a5,a5,127
    80000540:	97ba                	add	a5,a5,a4
    while(cons->e != cons->w &&
    80000542:	0307c603          	lbu	a2,48(a5)
    80000546:	47a9                	li	a5,10
    80000548:	0002e497          	auipc	s1,0x2e
    8000054c:	b1848493          	addi	s1,s1,-1256 # 8002e060 <cons>
    80000550:	4929                	li	s2,10
    80000552:	04f60063          	beq	a2,a5,80000592 <consoleintr+0x1bc>
      cons->e--;
    80000556:	0ad72c23          	sw	a3,184(a4)
      consputc(BACKSPACE);
    8000055a:	10000513          	li	a0,256
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	d28080e7          	jalr	-728(ra) # 80000286 <consputc>
    while(cons->e != cons->w &&
    80000566:	6098                	ld	a4,0(s1)
    80000568:	0b872783          	lw	a5,184(a4)
    8000056c:	0b472683          	lw	a3,180(a4)
    80000570:	02f68163          	beq	a3,a5,80000592 <consoleintr+0x1bc>
          cons->buf[(cons->e-1) % INPUT_BUF] != '\n'){
    80000574:	37fd                	addiw	a5,a5,-1
    80000576:	0007869b          	sext.w	a3,a5
    8000057a:	07f7f793          	andi	a5,a5,127
    8000057e:	97ba                	add	a5,a5,a4
    while(cons->e != cons->w &&
    80000580:	0307c783          	lbu	a5,48(a5)
    80000584:	fd2799e3          	bne	a5,s2,80000556 <consoleintr+0x180>
    80000588:	a029                	j	80000592 <consoleintr+0x1bc>
    procdump();
    8000058a:	00002097          	auipc	ra,0x2
    8000058e:	6b6080e7          	jalr	1718(ra) # 80002c40 <procdump>
      }
    }
    break;
  }
  
  release(&cons->lock);
    80000592:	0002e797          	auipc	a5,0x2e
    80000596:	ace78793          	addi	a5,a5,-1330 # 8002e060 <cons>
    8000059a:	6388                	ld	a0,0(a5)
    8000059c:	00001097          	auipc	ra,0x1
    800005a0:	96a080e7          	jalr	-1686(ra) # 80000f06 <release>
}
    800005a4:	70a2                	ld	ra,40(sp)
    800005a6:	7402                	ld	s0,32(sp)
    800005a8:	64e2                	ld	s1,24(sp)
    800005aa:	6942                	ld	s2,16(sp)
    800005ac:	69a2                	ld	s3,8(sp)
    800005ae:	6a02                	ld	s4,0(sp)
    800005b0:	6145                	addi	sp,sp,48
    800005b2:	8082                	ret
    priodump();
    800005b4:	00002097          	auipc	ra,0x2
    800005b8:	748080e7          	jalr	1864(ra) # 80002cfc <priodump>
    break;
    800005bc:	bfd9                	j	80000592 <consoleintr+0x1bc>
    dump_locks();
    800005be:	00000097          	auipc	ra,0x0
    800005c2:	5e6080e7          	jalr	1510(ra) # 80000ba4 <dump_locks>
    break;
    800005c6:	b7f1                	j	80000592 <consoleintr+0x1bc>
    if(cons->e != cons->w){
    800005c8:	0002e797          	auipc	a5,0x2e
    800005cc:	a9878793          	addi	a5,a5,-1384 # 8002e060 <cons>
    800005d0:	639c                	ld	a5,0(a5)
    800005d2:	0b87a703          	lw	a4,184(a5)
    800005d6:	0b47a683          	lw	a3,180(a5)
    800005da:	fae68ce3          	beq	a3,a4,80000592 <consoleintr+0x1bc>
      cons->e--;
    800005de:	377d                	addiw	a4,a4,-1
    800005e0:	0ae7ac23          	sw	a4,184(a5)
      consputc(BACKSPACE);
    800005e4:	10000513          	li	a0,256
    800005e8:	00000097          	auipc	ra,0x0
    800005ec:	c9e080e7          	jalr	-866(ra) # 80000286 <consputc>
    800005f0:	b74d                	j	80000592 <consoleintr+0x1bc>
      consputc(c);
    800005f2:	4529                	li	a0,10
    800005f4:	00000097          	auipc	ra,0x0
    800005f8:	c92080e7          	jalr	-878(ra) # 80000286 <consputc>
      cons->buf[cons->e++ % INPUT_BUF] = c;
    800005fc:	0002e797          	auipc	a5,0x2e
    80000600:	a6478793          	addi	a5,a5,-1436 # 8002e060 <cons>
    80000604:	6388                	ld	a0,0(a5)
    80000606:	0b852783          	lw	a5,184(a0)
    8000060a:	0017871b          	addiw	a4,a5,1
    8000060e:	0007069b          	sext.w	a3,a4
    80000612:	0ae52c23          	sw	a4,184(a0)
    80000616:	07f7f793          	andi	a5,a5,127
    8000061a:	97aa                	add	a5,a5,a0
    8000061c:	4729                	li	a4,10
    8000061e:	02e78823          	sb	a4,48(a5)
        cons->w = cons->e;
    80000622:	0ad52a23          	sw	a3,180(a0)
        wakeup(&cons->r);
    80000626:	0b050513          	addi	a0,a0,176
    8000062a:	00002097          	auipc	ra,0x2
    8000062e:	48e080e7          	jalr	1166(ra) # 80002ab8 <wakeup>
    80000632:	b785                	j	80000592 <consoleintr+0x1bc>

0000000080000634 <consoleinit>:

void
consoleinit(void)
{
    80000634:	1101                	addi	sp,sp,-32
    80000636:	ec06                	sd	ra,24(sp)
    80000638:	e822                	sd	s0,16(sp)
    8000063a:	e426                	sd	s1,8(sp)
    8000063c:	1000                	addi	s0,sp,32
  initlock(&console_number_lock, "console_number_lock");
    8000063e:	00013497          	auipc	s1,0x13
    80000642:	1c248493          	addi	s1,s1,450 # 80013800 <consoles>
    80000646:	00008597          	auipc	a1,0x8
    8000064a:	af258593          	addi	a1,a1,-1294 # 80008138 <userret+0xa8>
    8000064e:	00013517          	auipc	a0,0x13
    80000652:	3f250513          	addi	a0,a0,1010 # 80013a40 <console_number_lock>
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	4f6080e7          	jalr	1270(ra) # 80000b4c <initlock>
  console_number = 0;
    8000065e:	0002e797          	auipc	a5,0x2e
    80000662:	a007a523          	sw	zero,-1526(a5) # 8002e068 <console_number>
  cons = &consoles[console_number];
    80000666:	0002e797          	auipc	a5,0x2e
    8000066a:	9e97bd23          	sd	s1,-1542(a5) # 8002e060 <cons>
  for(int i = 0; i < NBCONSOLES; i++){
    initlock(&consoles[i].lock, "cons");
    8000066e:	00008597          	auipc	a1,0x8
    80000672:	ae258593          	addi	a1,a1,-1310 # 80008150 <userret+0xc0>
    80000676:	8526                	mv	a0,s1
    80000678:	00000097          	auipc	ra,0x0
    8000067c:	4d4080e7          	jalr	1236(ra) # 80000b4c <initlock>
    80000680:	00008597          	auipc	a1,0x8
    80000684:	ad058593          	addi	a1,a1,-1328 # 80008150 <userret+0xc0>
    80000688:	00013517          	auipc	a0,0x13
    8000068c:	23850513          	addi	a0,a0,568 # 800138c0 <consoles+0xc0>
    80000690:	00000097          	auipc	ra,0x0
    80000694:	4bc080e7          	jalr	1212(ra) # 80000b4c <initlock>
    80000698:	00008597          	auipc	a1,0x8
    8000069c:	ab858593          	addi	a1,a1,-1352 # 80008150 <userret+0xc0>
    800006a0:	00013517          	auipc	a0,0x13
    800006a4:	2e050513          	addi	a0,a0,736 # 80013980 <consoles+0x180>
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	4a4080e7          	jalr	1188(ra) # 80000b4c <initlock>
  }

  uartinit();
    800006b0:	00000097          	auipc	ra,0x0
    800006b4:	392080e7          	jalr	914(ra) # 80000a42 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800006b8:	00026797          	auipc	a5,0x26
    800006bc:	4e078793          	addi	a5,a5,1248 # 80026b98 <devsw>
    800006c0:	00000717          	auipc	a4,0x0
    800006c4:	a2e70713          	addi	a4,a4,-1490 # 800000ee <consoleread>
    800006c8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800006ca:	00000717          	auipc	a4,0x0
    800006ce:	c0e70713          	addi	a4,a4,-1010 # 800002d8 <consolewrite>
    800006d2:	ef98                	sd	a4,24(a5)
}
    800006d4:	60e2                	ld	ra,24(sp)
    800006d6:	6442                	ld	s0,16(sp)
    800006d8:	64a2                	ld	s1,8(sp)
    800006da:	6105                	addi	sp,sp,32
    800006dc:	8082                	ret

00000000800006de <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800006de:	7179                	addi	sp,sp,-48
    800006e0:	f406                	sd	ra,40(sp)
    800006e2:	f022                	sd	s0,32(sp)
    800006e4:	ec26                	sd	s1,24(sp)
    800006e6:	e84a                	sd	s2,16(sp)
    800006e8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800006ea:	c219                	beqz	a2,800006f0 <printint+0x12>
    800006ec:	00054d63          	bltz	a0,80000706 <printint+0x28>
    x = -xx;
  else
    x = xx;
    800006f0:	2501                	sext.w	a0,a0
    800006f2:	4881                	li	a7,0
    800006f4:	fd040713          	addi	a4,s0,-48

  i = 0;
    800006f8:	4601                	li	a2,0
  do {
    buf[i++] = digits[x % base];
    800006fa:	2581                	sext.w	a1,a1
    800006fc:	00008817          	auipc	a6,0x8
    80000700:	7f480813          	addi	a6,a6,2036 # 80008ef0 <digits>
    80000704:	a801                	j	80000714 <printint+0x36>
    x = -xx;
    80000706:	40a0053b          	negw	a0,a0
    8000070a:	2501                	sext.w	a0,a0
  if(sign && (sign = xx < 0))
    8000070c:	4885                	li	a7,1
    x = -xx;
    8000070e:	b7dd                	j	800006f4 <printint+0x16>
  } while((x /= base) != 0);
    80000710:	853e                	mv	a0,a5
    buf[i++] = digits[x % base];
    80000712:	8636                	mv	a2,a3
    80000714:	0016069b          	addiw	a3,a2,1
    80000718:	02b577bb          	remuw	a5,a0,a1
    8000071c:	1782                	slli	a5,a5,0x20
    8000071e:	9381                	srli	a5,a5,0x20
    80000720:	97c2                	add	a5,a5,a6
    80000722:	0007c783          	lbu	a5,0(a5)
    80000726:	00f70023          	sb	a5,0(a4)
    8000072a:	0705                	addi	a4,a4,1
  } while((x /= base) != 0);
    8000072c:	02b557bb          	divuw	a5,a0,a1
    80000730:	feb570e3          	bleu	a1,a0,80000710 <printint+0x32>

  if(sign)
    80000734:	00088b63          	beqz	a7,8000074a <printint+0x6c>
    buf[i++] = '-';
    80000738:	fe040793          	addi	a5,s0,-32
    8000073c:	96be                	add	a3,a3,a5
    8000073e:	02d00793          	li	a5,45
    80000742:	fef68823          	sb	a5,-16(a3)
    80000746:	0026069b          	addiw	a3,a2,2

  while(--i >= 0)
    8000074a:	02d05763          	blez	a3,80000778 <printint+0x9a>
    8000074e:	fd040793          	addi	a5,s0,-48
    80000752:	00d784b3          	add	s1,a5,a3
    80000756:	fff78913          	addi	s2,a5,-1
    8000075a:	9936                	add	s2,s2,a3
    8000075c:	36fd                	addiw	a3,a3,-1
    8000075e:	1682                	slli	a3,a3,0x20
    80000760:	9281                	srli	a3,a3,0x20
    80000762:	40d90933          	sub	s2,s2,a3
    consputc(buf[i]);
    80000766:	fff4c503          	lbu	a0,-1(s1)
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	b1c080e7          	jalr	-1252(ra) # 80000286 <consputc>
    80000772:	14fd                	addi	s1,s1,-1
  while(--i >= 0)
    80000774:	ff2499e3          	bne	s1,s2,80000766 <printint+0x88>
}
    80000778:	70a2                	ld	ra,40(sp)
    8000077a:	7402                	ld	s0,32(sp)
    8000077c:	64e2                	ld	s1,24(sp)
    8000077e:	6942                	ld	s2,16(sp)
    80000780:	6145                	addi	sp,sp,48
    80000782:	8082                	ret

0000000080000784 <panic>:
  printf_locking(0, fmt, ap);
}

void
panic(char *s)
{
    80000784:	1101                	addi	sp,sp,-32
    80000786:	ec06                	sd	ra,24(sp)
    80000788:	e822                	sd	s0,16(sp)
    8000078a:	e426                	sd	s1,8(sp)
    8000078c:	1000                	addi	s0,sp,32
    8000078e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000790:	00013797          	auipc	a5,0x13
    80000794:	3007a823          	sw	zero,784(a5) # 80013aa0 <pr+0x30>
  printf("PANIC: ");
    80000798:	00008517          	auipc	a0,0x8
    8000079c:	9c050513          	addi	a0,a0,-1600 # 80008158 <userret+0xc8>
    800007a0:	00000097          	auipc	ra,0x0
    800007a4:	1fc080e7          	jalr	508(ra) # 8000099c <printf>
  printf(s);
    800007a8:	8526                	mv	a0,s1
    800007aa:	00000097          	auipc	ra,0x0
    800007ae:	1f2080e7          	jalr	498(ra) # 8000099c <printf>
  printf("\n");
    800007b2:	00008517          	auipc	a0,0x8
    800007b6:	e9650513          	addi	a0,a0,-362 # 80008648 <userret+0x5b8>
    800007ba:	00000097          	auipc	ra,0x0
    800007be:	1e2080e7          	jalr	482(ra) # 8000099c <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    800007c2:	00008517          	auipc	a0,0x8
    800007c6:	99e50513          	addi	a0,a0,-1634 # 80008160 <userret+0xd0>
    800007ca:	00000097          	auipc	ra,0x0
    800007ce:	1d2080e7          	jalr	466(ra) # 8000099c <printf>
  panicked = 1; // freeze other CPUs
    800007d2:	4785                	li	a5,1
    800007d4:	0002e717          	auipc	a4,0x2e
    800007d8:	88f72c23          	sw	a5,-1896(a4) # 8002e06c <panicked>
  for(;;)
    ;
    800007dc:	a001                	j	800007dc <panic+0x58>

00000000800007de <printf_locking>:
{
    800007de:	7119                	addi	sp,sp,-128
    800007e0:	fc86                	sd	ra,120(sp)
    800007e2:	f8a2                	sd	s0,112(sp)
    800007e4:	f4a6                	sd	s1,104(sp)
    800007e6:	f0ca                	sd	s2,96(sp)
    800007e8:	ecce                	sd	s3,88(sp)
    800007ea:	e8d2                	sd	s4,80(sp)
    800007ec:	e4d6                	sd	s5,72(sp)
    800007ee:	e0da                	sd	s6,64(sp)
    800007f0:	fc5e                	sd	s7,56(sp)
    800007f2:	f862                	sd	s8,48(sp)
    800007f4:	f466                	sd	s9,40(sp)
    800007f6:	f06a                	sd	s10,32(sp)
    800007f8:	ec6e                	sd	s11,24(sp)
    800007fa:	0100                	addi	s0,sp,128
    800007fc:	8daa                	mv	s11,a0
    800007fe:	8aae                	mv	s5,a1
    80000800:	8932                	mv	s2,a2
  if(locking)
    80000802:	e515                	bnez	a0,8000082e <printf_locking+0x50>
  if (fmt == 0)
    80000804:	020a8e63          	beqz	s5,80000840 <printf_locking+0x62>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000808:	000ac503          	lbu	a0,0(s5)
    8000080c:	4481                	li	s1,0
    8000080e:	14050d63          	beqz	a0,80000968 <printf_locking+0x18a>
    if(c != '%'){
    80000812:	02500a13          	li	s4,37
    switch(c){
    80000816:	07000b13          	li	s6,112
  consputc('x');
    8000081a:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000081c:	00008b97          	auipc	s7,0x8
    80000820:	6d4b8b93          	addi	s7,s7,1748 # 80008ef0 <digits>
    switch(c){
    80000824:	07300c93          	li	s9,115
    80000828:	06400c13          	li	s8,100
    8000082c:	a82d                	j	80000866 <printf_locking+0x88>
    acquire(&pr.lock);
    8000082e:	00013517          	auipc	a0,0x13
    80000832:	24250513          	addi	a0,a0,578 # 80013a70 <pr>
    80000836:	00000097          	auipc	ra,0x0
    8000083a:	484080e7          	jalr	1156(ra) # 80000cba <acquire>
    8000083e:	b7d9                	j	80000804 <printf_locking+0x26>
    panic("null fmt");
    80000840:	00008517          	auipc	a0,0x8
    80000844:	9f850513          	addi	a0,a0,-1544 # 80008238 <userret+0x1a8>
    80000848:	00000097          	auipc	ra,0x0
    8000084c:	f3c080e7          	jalr	-196(ra) # 80000784 <panic>
      consputc(c);
    80000850:	00000097          	auipc	ra,0x0
    80000854:	a36080e7          	jalr	-1482(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000858:	2485                	addiw	s1,s1,1
    8000085a:	009a87b3          	add	a5,s5,s1
    8000085e:	0007c503          	lbu	a0,0(a5)
    80000862:	10050363          	beqz	a0,80000968 <printf_locking+0x18a>
    if(c != '%'){
    80000866:	ff4515e3          	bne	a0,s4,80000850 <printf_locking+0x72>
    c = fmt[++i] & 0xff;
    8000086a:	2485                	addiw	s1,s1,1
    8000086c:	009a87b3          	add	a5,s5,s1
    80000870:	0007c783          	lbu	a5,0(a5)
    80000874:	0007899b          	sext.w	s3,a5
    if(c == 0)
    80000878:	0e098863          	beqz	s3,80000968 <printf_locking+0x18a>
    switch(c){
    8000087c:	05678663          	beq	a5,s6,800008c8 <printf_locking+0xea>
    80000880:	02fb7463          	bleu	a5,s6,800008a8 <printf_locking+0xca>
    80000884:	09978563          	beq	a5,s9,8000090e <printf_locking+0x130>
    80000888:	07800713          	li	a4,120
    8000088c:	0ce79163          	bne	a5,a4,8000094e <printf_locking+0x170>
      printint(va_arg(ap, int), 16, 1);
    80000890:	00890993          	addi	s3,s2,8
    80000894:	4605                	li	a2,1
    80000896:	85ea                	mv	a1,s10
    80000898:	00092503          	lw	a0,0(s2)
    8000089c:	00000097          	auipc	ra,0x0
    800008a0:	e42080e7          	jalr	-446(ra) # 800006de <printint>
    800008a4:	894e                	mv	s2,s3
      break;
    800008a6:	bf4d                	j	80000858 <printf_locking+0x7a>
    switch(c){
    800008a8:	09478d63          	beq	a5,s4,80000942 <printf_locking+0x164>
    800008ac:	0b879163          	bne	a5,s8,8000094e <printf_locking+0x170>
      printint(va_arg(ap, int), 10, 1);
    800008b0:	00890993          	addi	s3,s2,8
    800008b4:	4605                	li	a2,1
    800008b6:	45a9                	li	a1,10
    800008b8:	00092503          	lw	a0,0(s2)
    800008bc:	00000097          	auipc	ra,0x0
    800008c0:	e22080e7          	jalr	-478(ra) # 800006de <printint>
    800008c4:	894e                	mv	s2,s3
      break;
    800008c6:	bf49                	j	80000858 <printf_locking+0x7a>
      printptr(va_arg(ap, uint64));
    800008c8:	00890793          	addi	a5,s2,8
    800008cc:	f8f43423          	sd	a5,-120(s0)
    800008d0:	00093983          	ld	s3,0(s2)
  consputc('0');
    800008d4:	03000513          	li	a0,48
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	9ae080e7          	jalr	-1618(ra) # 80000286 <consputc>
  consputc('x');
    800008e0:	07800513          	li	a0,120
    800008e4:	00000097          	auipc	ra,0x0
    800008e8:	9a2080e7          	jalr	-1630(ra) # 80000286 <consputc>
    800008ec:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800008ee:	03c9d793          	srli	a5,s3,0x3c
    800008f2:	97de                	add	a5,a5,s7
    800008f4:	0007c503          	lbu	a0,0(a5)
    800008f8:	00000097          	auipc	ra,0x0
    800008fc:	98e080e7          	jalr	-1650(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000900:	0992                	slli	s3,s3,0x4
    80000902:	397d                	addiw	s2,s2,-1
    80000904:	fe0915e3          	bnez	s2,800008ee <printf_locking+0x110>
      printptr(va_arg(ap, uint64));
    80000908:	f8843903          	ld	s2,-120(s0)
    8000090c:	b7b1                	j	80000858 <printf_locking+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000090e:	00890993          	addi	s3,s2,8
    80000912:	00093903          	ld	s2,0(s2)
    80000916:	00090f63          	beqz	s2,80000934 <printf_locking+0x156>
      for(; *s; s++)
    8000091a:	00094503          	lbu	a0,0(s2)
    8000091e:	c139                	beqz	a0,80000964 <printf_locking+0x186>
        consputc(*s);
    80000920:	00000097          	auipc	ra,0x0
    80000924:	966080e7          	jalr	-1690(ra) # 80000286 <consputc>
      for(; *s; s++)
    80000928:	0905                	addi	s2,s2,1
    8000092a:	00094503          	lbu	a0,0(s2)
    8000092e:	f96d                	bnez	a0,80000920 <printf_locking+0x142>
      if((s = va_arg(ap, char*)) == 0)
    80000930:	894e                	mv	s2,s3
    80000932:	b71d                	j	80000858 <printf_locking+0x7a>
        s = "(null)";
    80000934:	00008917          	auipc	s2,0x8
    80000938:	8fc90913          	addi	s2,s2,-1796 # 80008230 <userret+0x1a0>
      for(; *s; s++)
    8000093c:	02800513          	li	a0,40
    80000940:	b7c5                	j	80000920 <printf_locking+0x142>
      consputc('%');
    80000942:	8552                	mv	a0,s4
    80000944:	00000097          	auipc	ra,0x0
    80000948:	942080e7          	jalr	-1726(ra) # 80000286 <consputc>
      break;
    8000094c:	b731                	j	80000858 <printf_locking+0x7a>
      consputc('%');
    8000094e:	8552                	mv	a0,s4
    80000950:	00000097          	auipc	ra,0x0
    80000954:	936080e7          	jalr	-1738(ra) # 80000286 <consputc>
      consputc(c);
    80000958:	854e                	mv	a0,s3
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	92c080e7          	jalr	-1748(ra) # 80000286 <consputc>
      break;
    80000962:	bddd                	j	80000858 <printf_locking+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    80000964:	894e                	mv	s2,s3
    80000966:	bdcd                	j	80000858 <printf_locking+0x7a>
  if(locking)
    80000968:	020d9163          	bnez	s11,8000098a <printf_locking+0x1ac>
}
    8000096c:	70e6                	ld	ra,120(sp)
    8000096e:	7446                	ld	s0,112(sp)
    80000970:	74a6                	ld	s1,104(sp)
    80000972:	7906                	ld	s2,96(sp)
    80000974:	69e6                	ld	s3,88(sp)
    80000976:	6a46                	ld	s4,80(sp)
    80000978:	6aa6                	ld	s5,72(sp)
    8000097a:	6b06                	ld	s6,64(sp)
    8000097c:	7be2                	ld	s7,56(sp)
    8000097e:	7c42                	ld	s8,48(sp)
    80000980:	7ca2                	ld	s9,40(sp)
    80000982:	7d02                	ld	s10,32(sp)
    80000984:	6de2                	ld	s11,24(sp)
    80000986:	6109                	addi	sp,sp,128
    80000988:	8082                	ret
    release(&pr.lock);
    8000098a:	00013517          	auipc	a0,0x13
    8000098e:	0e650513          	addi	a0,a0,230 # 80013a70 <pr>
    80000992:	00000097          	auipc	ra,0x0
    80000996:	574080e7          	jalr	1396(ra) # 80000f06 <release>
}
    8000099a:	bfc9                	j	8000096c <printf_locking+0x18e>

000000008000099c <printf>:
printf(char *fmt, ...){
    8000099c:	711d                	addi	sp,sp,-96
    8000099e:	ec06                	sd	ra,24(sp)
    800009a0:	e822                	sd	s0,16(sp)
    800009a2:	1000                	addi	s0,sp,32
    800009a4:	e40c                	sd	a1,8(s0)
    800009a6:	e810                	sd	a2,16(s0)
    800009a8:	ec14                	sd	a3,24(s0)
    800009aa:	f018                	sd	a4,32(s0)
    800009ac:	f41c                	sd	a5,40(s0)
    800009ae:	03043823          	sd	a6,48(s0)
    800009b2:	03143c23          	sd	a7,56(s0)
  va_start(ap, fmt);
    800009b6:	00840613          	addi	a2,s0,8
    800009ba:	fec43423          	sd	a2,-24(s0)
  printf_locking(pr.locking, fmt, ap);
    800009be:	85aa                	mv	a1,a0
    800009c0:	00013797          	auipc	a5,0x13
    800009c4:	0b078793          	addi	a5,a5,176 # 80013a70 <pr>
    800009c8:	5b88                	lw	a0,48(a5)
    800009ca:	00000097          	auipc	ra,0x0
    800009ce:	e14080e7          	jalr	-492(ra) # 800007de <printf_locking>
}
    800009d2:	60e2                	ld	ra,24(sp)
    800009d4:	6442                	ld	s0,16(sp)
    800009d6:	6125                	addi	sp,sp,96
    800009d8:	8082                	ret

00000000800009da <printf_no_lock>:
printf_no_lock(char *fmt, ...){
    800009da:	711d                	addi	sp,sp,-96
    800009dc:	ec06                	sd	ra,24(sp)
    800009de:	e822                	sd	s0,16(sp)
    800009e0:	1000                	addi	s0,sp,32
    800009e2:	e40c                	sd	a1,8(s0)
    800009e4:	e810                	sd	a2,16(s0)
    800009e6:	ec14                	sd	a3,24(s0)
    800009e8:	f018                	sd	a4,32(s0)
    800009ea:	f41c                	sd	a5,40(s0)
    800009ec:	03043823          	sd	a6,48(s0)
    800009f0:	03143c23          	sd	a7,56(s0)
  va_start(ap, fmt);
    800009f4:	00840613          	addi	a2,s0,8
    800009f8:	fec43423          	sd	a2,-24(s0)
  printf_locking(0, fmt, ap);
    800009fc:	85aa                	mv	a1,a0
    800009fe:	4501                	li	a0,0
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	dde080e7          	jalr	-546(ra) # 800007de <printf_locking>
}
    80000a08:	60e2                	ld	ra,24(sp)
    80000a0a:	6442                	ld	s0,16(sp)
    80000a0c:	6125                	addi	sp,sp,96
    80000a0e:	8082                	ret

0000000080000a10 <printfinit>:
}

void
printfinit(void)
{
    80000a10:	1101                	addi	sp,sp,-32
    80000a12:	ec06                	sd	ra,24(sp)
    80000a14:	e822                	sd	s0,16(sp)
    80000a16:	e426                	sd	s1,8(sp)
    80000a18:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000a1a:	00013497          	auipc	s1,0x13
    80000a1e:	05648493          	addi	s1,s1,86 # 80013a70 <pr>
    80000a22:	00008597          	auipc	a1,0x8
    80000a26:	82658593          	addi	a1,a1,-2010 # 80008248 <userret+0x1b8>
    80000a2a:	8526                	mv	a0,s1
    80000a2c:	00000097          	auipc	ra,0x0
    80000a30:	120080e7          	jalr	288(ra) # 80000b4c <initlock>
  pr.locking = 1;
    80000a34:	4785                	li	a5,1
    80000a36:	d89c                	sw	a5,48(s1)
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    80000a42:	1141                	addi	sp,sp,-16
    80000a44:	e422                	sd	s0,8(sp)
    80000a46:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000a48:	100007b7          	lui	a5,0x10000
    80000a4c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    80000a50:	f8000713          	li	a4,-128
    80000a54:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000a58:	470d                	li	a4,3
    80000a5a:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000a5e:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    80000a62:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    80000a66:	471d                	li	a4,7
    80000a68:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    80000a6c:	4705                	li	a4,1
    80000a6e:	00e780a3          	sb	a4,1(a5)
}
    80000a72:	6422                	ld	s0,8(sp)
    80000a74:	0141                	addi	sp,sp,16
    80000a76:	8082                	ret

0000000080000a78 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    80000a78:	1141                	addi	sp,sp,-16
    80000a7a:	e422                	sd	s0,8(sp)
    80000a7c:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    80000a7e:	10000737          	lui	a4,0x10000
    80000a82:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000a86:	0ff7f793          	andi	a5,a5,255
    80000a8a:	0207f793          	andi	a5,a5,32
    80000a8e:	dbf5                	beqz	a5,80000a82 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    80000a90:	0ff57513          	andi	a0,a0,255
    80000a94:	100007b7          	lui	a5,0x10000
    80000a98:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    80000a9c:	6422                	ld	s0,8(sp)
    80000a9e:	0141                	addi	sp,sp,16
    80000aa0:	8082                	ret

0000000080000aa2 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000aa2:	1141                	addi	sp,sp,-16
    80000aa4:	e422                	sd	s0,8(sp)
    80000aa6:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000aa8:	100007b7          	lui	a5,0x10000
    80000aac:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000ab0:	8b85                	andi	a5,a5,1
    80000ab2:	cb81                	beqz	a5,80000ac2 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000ab4:	100007b7          	lui	a5,0x10000
    80000ab8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000abc:	6422                	ld	s0,8(sp)
    80000abe:	0141                	addi	sp,sp,16
    80000ac0:	8082                	ret
    return -1;
    80000ac2:	557d                	li	a0,-1
    80000ac4:	bfe5                	j	80000abc <uartgetc+0x1a>

0000000080000ac6 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000ac6:	1101                	addi	sp,sp,-32
    80000ac8:	ec06                	sd	ra,24(sp)
    80000aca:	e822                	sd	s0,16(sp)
    80000acc:	e426                	sd	s1,8(sp)
    80000ace:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000ad0:	54fd                	li	s1,-1
    int c = uartgetc();
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	fd0080e7          	jalr	-48(ra) # 80000aa2 <uartgetc>
    if(c == -1)
    80000ada:	00950763          	beq	a0,s1,80000ae8 <uartintr+0x22>
      break;
    consoleintr(c);
    80000ade:	00000097          	auipc	ra,0x0
    80000ae2:	8f8080e7          	jalr	-1800(ra) # 800003d6 <consoleintr>
  while(1){
    80000ae6:	b7f5                	j	80000ad2 <uartintr+0xc>
  }
}
    80000ae8:	60e2                	ld	ra,24(sp)
    80000aea:	6442                	ld	s0,16(sp)
    80000aec:	64a2                	ld	s1,8(sp)
    80000aee:	6105                	addi	sp,sp,32
    80000af0:	8082                	ret

0000000080000af2 <kinit>:
extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

void
kinit()
{
    80000af2:	1141                	addi	sp,sp,-16
    80000af4:	e406                	sd	ra,8(sp)
    80000af6:	e022                	sd	s0,0(sp)
    80000af8:	0800                	addi	s0,sp,16
  char *p = (char *) PGROUNDUP((uint64) end);
  bd_init(p, (void*)PHYSTOP);
    80000afa:	45c5                	li	a1,17
    80000afc:	05ee                	slli	a1,a1,0x1b
    80000afe:	0002e517          	auipc	a0,0x2e
    80000b02:	5ad50513          	addi	a0,a0,1453 # 8002f0ab <end+0xfff>
    80000b06:	77fd                	lui	a5,0xfffff
    80000b08:	8d7d                	and	a0,a0,a5
    80000b0a:	00007097          	auipc	ra,0x7
    80000b0e:	c96080e7          	jalr	-874(ra) # 800077a0 <bd_init>
}
    80000b12:	60a2                	ld	ra,8(sp)
    80000b14:	6402                	ld	s0,0(sp)
    80000b16:	0141                	addi	sp,sp,16
    80000b18:	8082                	ret

0000000080000b1a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000b1a:	1141                	addi	sp,sp,-16
    80000b1c:	e406                	sd	ra,8(sp)
    80000b1e:	e022                	sd	s0,0(sp)
    80000b20:	0800                	addi	s0,sp,16
  bd_free(pa);
    80000b22:	00006097          	auipc	ra,0x6
    80000b26:	7aa080e7          	jalr	1962(ra) # 800072cc <bd_free>
}
    80000b2a:	60a2                	ld	ra,8(sp)
    80000b2c:	6402                	ld	s0,0(sp)
    80000b2e:	0141                	addi	sp,sp,16
    80000b30:	8082                	ret

0000000080000b32 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e406                	sd	ra,8(sp)
    80000b36:	e022                	sd	s0,0(sp)
    80000b38:	0800                	addi	s0,sp,16
  return bd_malloc(PGSIZE);
    80000b3a:	6505                	lui	a0,0x1
    80000b3c:	00006097          	auipc	ra,0x6
    80000b40:	58c080e7          	jalr	1420(ra) # 800070c8 <bd_malloc>
}
    80000b44:	60a2                	ld	ra,8(sp)
    80000b46:	6402                	ld	s0,0(sp)
    80000b48:	0141                	addi	sp,sp,16
    80000b4a:	8082                	ret

0000000080000b4c <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0) # 1000 <_entry-0x7ffff000>
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000b56:	02052423          	sw	zero,40(a0)
  lk->n = 0;
    80000b5a:	02052223          	sw	zero,36(a0)
  if(nlock >= NLOCK)
    80000b5e:	0002d797          	auipc	a5,0x2d
    80000b62:	51278793          	addi	a5,a5,1298 # 8002e070 <nlock>
    80000b66:	439c                	lw	a5,0(a5)
    80000b68:	3e700713          	li	a4,999
    80000b6c:	02f74063          	blt	a4,a5,80000b8c <initlock+0x40>
    panic("initlock");
  locks[nlock] = lk;
    80000b70:	00379693          	slli	a3,a5,0x3
    80000b74:	00013717          	auipc	a4,0x13
    80000b78:	f3470713          	addi	a4,a4,-204 # 80013aa8 <locks>
    80000b7c:	9736                	add	a4,a4,a3
    80000b7e:	e308                	sd	a0,0(a4)
  nlock++;
    80000b80:	2785                	addiw	a5,a5,1
    80000b82:	0002d717          	auipc	a4,0x2d
    80000b86:	4ef72723          	sw	a5,1262(a4) # 8002e070 <nlock>
    80000b8a:	8082                	ret
{
    80000b8c:	1141                	addi	sp,sp,-16
    80000b8e:	e406                	sd	ra,8(sp)
    80000b90:	e022                	sd	s0,0(sp)
    80000b92:	0800                	addi	s0,sp,16
    panic("initlock");
    80000b94:	00007517          	auipc	a0,0x7
    80000b98:	6bc50513          	addi	a0,a0,1724 # 80008250 <userret+0x1c0>
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	be8080e7          	jalr	-1048(ra) # 80000784 <panic>

0000000080000ba4 <dump_locks>:
}

void dump_locks(void){
    80000ba4:	7139                	addi	sp,sp,-64
    80000ba6:	fc06                	sd	ra,56(sp)
    80000ba8:	f822                	sd	s0,48(sp)
    80000baa:	f426                	sd	s1,40(sp)
    80000bac:	f04a                	sd	s2,32(sp)
    80000bae:	ec4e                	sd	s3,24(sp)
    80000bb0:	e852                	sd	s4,16(sp)
    80000bb2:	e456                	sd	s5,8(sp)
    80000bb4:	0080                	addi	s0,sp,64
  printf_no_lock("LID\tLOCKED\tCPU\tPID\tNAME\t\tPC\n");
    80000bb6:	00007517          	auipc	a0,0x7
    80000bba:	6aa50513          	addi	a0,a0,1706 # 80008260 <userret+0x1d0>
    80000bbe:	00000097          	auipc	ra,0x0
    80000bc2:	e1c080e7          	jalr	-484(ra) # 800009da <printf_no_lock>
  for(int i = 0; i < nlock; i++){
    80000bc6:	0002d797          	auipc	a5,0x2d
    80000bca:	4aa78793          	addi	a5,a5,1194 # 8002e070 <nlock>
    80000bce:	439c                	lw	a5,0(a5)
    80000bd0:	04f05d63          	blez	a5,80000c2a <dump_locks+0x86>
    80000bd4:	00013917          	auipc	s2,0x13
    80000bd8:	ed490913          	addi	s2,s2,-300 # 80013aa8 <locks>
    80000bdc:	4481                	li	s1,0
    if(locks[i]->locked)
      printf_no_lock("%d\t%d\t%d\t%d\t%s\t\t%p\n",
                     i,
                     locks[i]->locked,
                     locks[i]->cpu - cpus,
    80000bde:	00015a97          	auipc	s5,0x15
    80000be2:	ebaa8a93          	addi	s5,s5,-326 # 80015a98 <cpus>
      printf_no_lock("%d\t%d\t%d\t%d\t%s\t\t%p\n",
    80000be6:	00007a17          	auipc	s4,0x7
    80000bea:	69aa0a13          	addi	s4,s4,1690 # 80008280 <userret+0x1f0>
  for(int i = 0; i < nlock; i++){
    80000bee:	0002d997          	auipc	s3,0x2d
    80000bf2:	48298993          	addi	s3,s3,1154 # 8002e070 <nlock>
    80000bf6:	a02d                	j	80000c20 <dump_locks+0x7c>
                     locks[i]->cpu - cpus,
    80000bf8:	6b14                	ld	a3,16(a4)
    80000bfa:	415686b3          	sub	a3,a3,s5
      printf_no_lock("%d\t%d\t%d\t%d\t%s\t\t%p\n",
    80000bfe:	01873803          	ld	a6,24(a4)
    80000c02:	671c                	ld	a5,8(a4)
    80000c04:	5318                	lw	a4,32(a4)
    80000c06:	869d                	srai	a3,a3,0x7
    80000c08:	85a6                	mv	a1,s1
    80000c0a:	8552                	mv	a0,s4
    80000c0c:	00000097          	auipc	ra,0x0
    80000c10:	dce080e7          	jalr	-562(ra) # 800009da <printf_no_lock>
  for(int i = 0; i < nlock; i++){
    80000c14:	2485                	addiw	s1,s1,1
    80000c16:	0921                	addi	s2,s2,8
    80000c18:	0009a783          	lw	a5,0(s3)
    80000c1c:	00f4d763          	ble	a5,s1,80000c2a <dump_locks+0x86>
    if(locks[i]->locked)
    80000c20:	00093703          	ld	a4,0(s2)
    80000c24:	4310                	lw	a2,0(a4)
    80000c26:	d67d                	beqz	a2,80000c14 <dump_locks+0x70>
    80000c28:	bfc1                	j	80000bf8 <dump_locks+0x54>
                     locks[i]->pid,
                     locks[i]->name,
                     locks[i]->pc
        );
  }
}
    80000c2a:	70e2                	ld	ra,56(sp)
    80000c2c:	7442                	ld	s0,48(sp)
    80000c2e:	74a2                	ld	s1,40(sp)
    80000c30:	7902                	ld	s2,32(sp)
    80000c32:	69e2                	ld	s3,24(sp)
    80000c34:	6a42                	ld	s4,16(sp)
    80000c36:	6aa2                	ld	s5,8(sp)
    80000c38:	6121                	addi	sp,sp,64
    80000c3a:	8082                	ret

0000000080000c3c <holding>:
// Must be called with interrupts off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c3c:	411c                	lw	a5,0(a0)
    80000c3e:	e399                	bnez	a5,80000c44 <holding+0x8>
    80000c40:	4501                	li	a0,0
  return r;
}
    80000c42:	8082                	ret
{
    80000c44:	1101                	addi	sp,sp,-32
    80000c46:	ec06                	sd	ra,24(sp)
    80000c48:	e822                	sd	s0,16(sp)
    80000c4a:	e426                	sd	s1,8(sp)
    80000c4c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c4e:	6904                	ld	s1,16(a0)
    80000c50:	00001097          	auipc	ra,0x1
    80000c54:	3d4080e7          	jalr	980(ra) # 80002024 <mycpu>
    80000c58:	40a48533          	sub	a0,s1,a0
    80000c5c:	00153513          	seqz	a0,a0
}
    80000c60:	60e2                	ld	ra,24(sp)
    80000c62:	6442                	ld	s0,16(sp)
    80000c64:	64a2                	ld	s1,8(sp)
    80000c66:	6105                	addi	sp,sp,32
    80000c68:	8082                	ret

0000000080000c6a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c6a:	1101                	addi	sp,sp,-32
    80000c6c:	ec06                	sd	ra,24(sp)
    80000c6e:	e822                	sd	s0,16(sp)
    80000c70:	e426                	sd	s1,8(sp)
    80000c72:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c74:	100024f3          	csrr	s1,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c78:	8889                	andi	s1,s1,2
  int old = intr_get();
  if(old)
    80000c7a:	c491                	beqz	s1,80000c86 <push_off+0x1c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c7c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c80:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c82:	10079073          	csrw	sstatus,a5
    intr_off();
  if(mycpu()->noff == 0)
    80000c86:	00001097          	auipc	ra,0x1
    80000c8a:	39e080e7          	jalr	926(ra) # 80002024 <mycpu>
    80000c8e:	5d3c                	lw	a5,120(a0)
    80000c90:	cf89                	beqz	a5,80000caa <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c92:	00001097          	auipc	ra,0x1
    80000c96:	392080e7          	jalr	914(ra) # 80002024 <mycpu>
    80000c9a:	5d3c                	lw	a5,120(a0)
    80000c9c:	2785                	addiw	a5,a5,1
    80000c9e:	dd3c                	sw	a5,120(a0)
}
    80000ca0:	60e2                	ld	ra,24(sp)
    80000ca2:	6442                	ld	s0,16(sp)
    80000ca4:	64a2                	ld	s1,8(sp)
    80000ca6:	6105                	addi	sp,sp,32
    80000ca8:	8082                	ret
    mycpu()->intena = old;
    80000caa:	00001097          	auipc	ra,0x1
    80000cae:	37a080e7          	jalr	890(ra) # 80002024 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cb2:	009034b3          	snez	s1,s1
    80000cb6:	dd64                	sw	s1,124(a0)
    80000cb8:	bfe9                	j	80000c92 <push_off+0x28>

0000000080000cba <acquire>:
{
    80000cba:	7159                	addi	sp,sp,-112
    80000cbc:	f486                	sd	ra,104(sp)
    80000cbe:	f0a2                	sd	s0,96(sp)
    80000cc0:	eca6                	sd	s1,88(sp)
    80000cc2:	e8ca                	sd	s2,80(sp)
    80000cc4:	e4ce                	sd	s3,72(sp)
    80000cc6:	e0d2                	sd	s4,64(sp)
    80000cc8:	fc56                	sd	s5,56(sp)
    80000cca:	f85a                	sd	s6,48(sp)
    80000ccc:	f45e                	sd	s7,40(sp)
    80000cce:	f062                	sd	s8,32(sp)
    80000cd0:	ec66                	sd	s9,24(sp)
    80000cd2:	e86a                	sd	s10,16(sp)
    80000cd4:	e46e                	sd	s11,8(sp)
    80000cd6:	1880                	addi	s0,sp,112
    80000cd8:	84aa                	mv	s1,a0
  asm volatile("mv %0, ra" : "=r" (ra));
    80000cda:	8a86                	mv	s5,ra
  ra -= 4;
    80000cdc:	1af1                	addi	s5,s5,-4
  push_off(); // disable interrupts to avoid deadlock.
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	f8c080e7          	jalr	-116(ra) # 80000c6a <push_off>
  if(holding(lk)){
    80000ce6:	8526                	mv	a0,s1
    80000ce8:	00000097          	auipc	ra,0x0
    80000cec:	f54080e7          	jalr	-172(ra) # 80000c3c <holding>
    80000cf0:	e121                	bnez	a0,80000d30 <acquire+0x76>
    80000cf2:	892a                	mv	s2,a0
  __sync_fetch_and_add(&(lk->n), 1);
    80000cf4:	4785                	li	a5,1
    80000cf6:	02448713          	addi	a4,s1,36
    80000cfa:	0f50000f          	fence	iorw,ow
    80000cfe:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  int warned = 0;
    80000d02:	872a                	mv	a4,a0
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000d04:	4985                	li	s3,1
    if(nbtries > MAXTRIES && !warned){
    80000d06:	6a61                	lui	s4,0x18
    80000d08:	6a0a0a13          	addi	s4,s4,1696 # 186a0 <_entry-0x7ffe7960>
      printf_no_lock("CPU %d: Blocked while acquiring %s (%p)\n", cpuid(), lk->name, lk);
    80000d0c:	00007d17          	auipc	s10,0x7
    80000d10:	614d0d13          	addi	s10,s10,1556 # 80008320 <userret+0x290>
                     lk->cpu - cpus,
    80000d14:	00015c97          	auipc	s9,0x15
    80000d18:	d84c8c93          	addi	s9,s9,-636 # 80015a98 <cpus>
      printf_no_lock("process %d (CPU %d) took it at pc=%p \n", lk->pid,
    80000d1c:	00007c17          	auipc	s8,0x7
    80000d20:	5a4c0c13          	addi	s8,s8,1444 # 800082c0 <userret+0x230>
      printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000d24:	5bfd                	li	s7,-1
    80000d26:	00007b17          	auipc	s6,0x7
    80000d2a:	5c2b0b13          	addi	s6,s6,1474 # 800082e8 <userret+0x258>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000d2e:	a84d                	j	80000de0 <acquire+0x126>
    printf_no_lock("requesting %s (%p) but already have it\n", lk->name, lk);
    80000d30:	8626                	mv	a2,s1
    80000d32:	648c                	ld	a1,8(s1)
    80000d34:	00007517          	auipc	a0,0x7
    80000d38:	56450513          	addi	a0,a0,1380 # 80008298 <userret+0x208>
    80000d3c:	00000097          	auipc	ra,0x0
    80000d40:	c9e080e7          	jalr	-866(ra) # 800009da <printf_no_lock>
                   lk->cpu - cpus,
    80000d44:	6890                	ld	a2,16(s1)
    80000d46:	00015797          	auipc	a5,0x15
    80000d4a:	d5278793          	addi	a5,a5,-686 # 80015a98 <cpus>
    80000d4e:	8e1d                	sub	a2,a2,a5
    printf_no_lock("process %d (CPU %d) took it at pc=%p \n", lk->pid,
    80000d50:	6c94                	ld	a3,24(s1)
    80000d52:	861d                	srai	a2,a2,0x7
    80000d54:	508c                	lw	a1,32(s1)
    80000d56:	00007517          	auipc	a0,0x7
    80000d5a:	56a50513          	addi	a0,a0,1386 # 800082c0 <userret+0x230>
    80000d5e:	00000097          	auipc	ra,0x0
    80000d62:	c7c080e7          	jalr	-900(ra) # 800009da <printf_no_lock>
                   myproc() ? myproc()->pid : -1,
    80000d66:	00001097          	auipc	ra,0x1
    80000d6a:	2da080e7          	jalr	730(ra) # 80002040 <myproc>
    printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000d6e:	54fd                	li	s1,-1
    80000d70:	c511                	beqz	a0,80000d7c <acquire+0xc2>
                   myproc() ? myproc()->pid : -1,
    80000d72:	00001097          	auipc	ra,0x1
    80000d76:	2ce080e7          	jalr	718(ra) # 80002040 <myproc>
    printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000d7a:	4924                	lw	s1,80(a0)
    80000d7c:	00001097          	auipc	ra,0x1
    80000d80:	298080e7          	jalr	664(ra) # 80002014 <cpuid>
    80000d84:	86aa                	mv	a3,a0
    80000d86:	8626                	mv	a2,s1
    80000d88:	85d6                	mv	a1,s5
    80000d8a:	00007517          	auipc	a0,0x7
    80000d8e:	55e50513          	addi	a0,a0,1374 # 800082e8 <userret+0x258>
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	c48080e7          	jalr	-952(ra) # 800009da <printf_no_lock>
    procdump();
    80000d9a:	00002097          	auipc	ra,0x2
    80000d9e:	ea6080e7          	jalr	-346(ra) # 80002c40 <procdump>
    panic("acquire");
    80000da2:	00007517          	auipc	a0,0x7
    80000da6:	57650513          	addi	a0,a0,1398 # 80008318 <userret+0x288>
    80000daa:	00000097          	auipc	ra,0x0
    80000dae:	9da080e7          	jalr	-1574(ra) # 80000784 <panic>
      printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000db2:	00001097          	auipc	ra,0x1
    80000db6:	262080e7          	jalr	610(ra) # 80002014 <cpuid>
    80000dba:	86aa                	mv	a3,a0
    80000dbc:	866e                	mv	a2,s11
    80000dbe:	85d6                	mv	a1,s5
    80000dc0:	855a                	mv	a0,s6
    80000dc2:	00000097          	auipc	ra,0x0
    80000dc6:	c18080e7          	jalr	-1000(ra) # 800009da <printf_no_lock>
      procdump();
    80000dca:	00002097          	auipc	ra,0x2
    80000dce:	e76080e7          	jalr	-394(ra) # 80002c40 <procdump>
      warned = 1;
    80000dd2:	4705                	li	a4,1
     __sync_fetch_and_add(&lk->nts, 1);
    80000dd4:	02848793          	addi	a5,s1,40
    80000dd8:	0f50000f          	fence	iorw,ow
    80000ddc:	0537a02f          	amoadd.w.aq	zero,s3,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000de0:	87ce                	mv	a5,s3
    80000de2:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000de6:	2781                	sext.w	a5,a5
    80000de8:	cba9                	beqz	a5,80000e3a <acquire+0x180>
    nbtries++;
    80000dea:	2905                	addiw	s2,s2,1
    if(nbtries > MAXTRIES && !warned){
    80000dec:	ff2a54e3          	ble	s2,s4,80000dd4 <acquire+0x11a>
    80000df0:	f375                	bnez	a4,80000dd4 <acquire+0x11a>
      printf_no_lock("CPU %d: Blocked while acquiring %s (%p)\n", cpuid(), lk->name, lk);
    80000df2:	00001097          	auipc	ra,0x1
    80000df6:	222080e7          	jalr	546(ra) # 80002014 <cpuid>
    80000dfa:	86a6                	mv	a3,s1
    80000dfc:	6490                	ld	a2,8(s1)
    80000dfe:	85aa                	mv	a1,a0
    80000e00:	856a                	mv	a0,s10
    80000e02:	00000097          	auipc	ra,0x0
    80000e06:	bd8080e7          	jalr	-1064(ra) # 800009da <printf_no_lock>
                     lk->cpu - cpus,
    80000e0a:	6890                	ld	a2,16(s1)
    80000e0c:	41960633          	sub	a2,a2,s9
      printf_no_lock("process %d (CPU %d) took it at pc=%p \n", lk->pid,
    80000e10:	6c94                	ld	a3,24(s1)
    80000e12:	861d                	srai	a2,a2,0x7
    80000e14:	508c                	lw	a1,32(s1)
    80000e16:	8562                	mv	a0,s8
    80000e18:	00000097          	auipc	ra,0x0
    80000e1c:	bc2080e7          	jalr	-1086(ra) # 800009da <printf_no_lock>
                     myproc() ? myproc()->pid : -1,
    80000e20:	00001097          	auipc	ra,0x1
    80000e24:	220080e7          	jalr	544(ra) # 80002040 <myproc>
      printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000e28:	8dde                	mv	s11,s7
    80000e2a:	d541                	beqz	a0,80000db2 <acquire+0xf8>
                     myproc() ? myproc()->pid : -1,
    80000e2c:	00001097          	auipc	ra,0x1
    80000e30:	214080e7          	jalr	532(ra) # 80002040 <myproc>
      printf_no_lock("I am myself at pc=%p in pid=%d on CPU %d\n",
    80000e34:	05052d83          	lw	s11,80(a0)
    80000e38:	bfad                	j	80000db2 <acquire+0xf8>
  if(warned){
    80000e3a:	e729                	bnez	a4,80000e84 <acquire+0x1ca>
  __sync_synchronize();
    80000e3c:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000e40:	00001097          	auipc	ra,0x1
    80000e44:	1e4080e7          	jalr	484(ra) # 80002024 <mycpu>
    80000e48:	e888                	sd	a0,16(s1)
  lk->pc = ra;
    80000e4a:	0154bc23          	sd	s5,24(s1)
  lk->pid = myproc() ? myproc()->pid : -1;
    80000e4e:	00001097          	auipc	ra,0x1
    80000e52:	1f2080e7          	jalr	498(ra) # 80002040 <myproc>
    80000e56:	57fd                	li	a5,-1
    80000e58:	c511                	beqz	a0,80000e64 <acquire+0x1aa>
    80000e5a:	00001097          	auipc	ra,0x1
    80000e5e:	1e6080e7          	jalr	486(ra) # 80002040 <myproc>
    80000e62:	493c                	lw	a5,80(a0)
    80000e64:	d09c                	sw	a5,32(s1)
}
    80000e66:	70a6                	ld	ra,104(sp)
    80000e68:	7406                	ld	s0,96(sp)
    80000e6a:	64e6                	ld	s1,88(sp)
    80000e6c:	6946                	ld	s2,80(sp)
    80000e6e:	69a6                	ld	s3,72(sp)
    80000e70:	6a06                	ld	s4,64(sp)
    80000e72:	7ae2                	ld	s5,56(sp)
    80000e74:	7b42                	ld	s6,48(sp)
    80000e76:	7ba2                	ld	s7,40(sp)
    80000e78:	7c02                	ld	s8,32(sp)
    80000e7a:	6ce2                	ld	s9,24(sp)
    80000e7c:	6d42                	ld	s10,16(sp)
    80000e7e:	6da2                	ld	s11,8(sp)
    80000e80:	6165                	addi	sp,sp,112
    80000e82:	8082                	ret
    printf_no_lock("CPU %d: Finally acquired %s (%p) after %d tries\n", cpuid(), lk->name, lk, nbtries);
    80000e84:	00001097          	auipc	ra,0x1
    80000e88:	190080e7          	jalr	400(ra) # 80002014 <cpuid>
    80000e8c:	874a                	mv	a4,s2
    80000e8e:	86a6                	mv	a3,s1
    80000e90:	6490                	ld	a2,8(s1)
    80000e92:	85aa                	mv	a1,a0
    80000e94:	00007517          	auipc	a0,0x7
    80000e98:	4bc50513          	addi	a0,a0,1212 # 80008350 <userret+0x2c0>
    80000e9c:	00000097          	auipc	ra,0x0
    80000ea0:	b3e080e7          	jalr	-1218(ra) # 800009da <printf_no_lock>
    80000ea4:	bf61                	j	80000e3c <acquire+0x182>

0000000080000ea6 <pop_off>:

void
pop_off(void)
{
    80000ea6:	1141                	addi	sp,sp,-16
    80000ea8:	e406                	sd	ra,8(sp)
    80000eaa:	e022                	sd	s0,0(sp)
    80000eac:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000eae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000eb2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000eb4:	eb8d                	bnez	a5,80000ee6 <pop_off+0x40>
    panic("pop_off - interruptible");
  struct cpu *c = mycpu();
    80000eb6:	00001097          	auipc	ra,0x1
    80000eba:	16e080e7          	jalr	366(ra) # 80002024 <mycpu>
  if(c->noff < 1)
    80000ebe:	5d3c                	lw	a5,120(a0)
    80000ec0:	02f05b63          	blez	a5,80000ef6 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000ec4:	37fd                	addiw	a5,a5,-1
    80000ec6:	0007871b          	sext.w	a4,a5
    80000eca:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000ecc:	eb09                	bnez	a4,80000ede <pop_off+0x38>
    80000ece:	5d7c                	lw	a5,124(a0)
    80000ed0:	c799                	beqz	a5,80000ede <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ed2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ed6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000eda:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ede:	60a2                	ld	ra,8(sp)
    80000ee0:	6402                	ld	s0,0(sp)
    80000ee2:	0141                	addi	sp,sp,16
    80000ee4:	8082                	ret
    panic("pop_off - interruptible");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	4a250513          	addi	a0,a0,1186 # 80008388 <userret+0x2f8>
    80000eee:	00000097          	auipc	ra,0x0
    80000ef2:	896080e7          	jalr	-1898(ra) # 80000784 <panic>
    panic("pop_off");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	4aa50513          	addi	a0,a0,1194 # 800083a0 <userret+0x310>
    80000efe:	00000097          	auipc	ra,0x0
    80000f02:	886080e7          	jalr	-1914(ra) # 80000784 <panic>

0000000080000f06 <release>:
{
    80000f06:	1101                	addi	sp,sp,-32
    80000f08:	ec06                	sd	ra,24(sp)
    80000f0a:	e822                	sd	s0,16(sp)
    80000f0c:	e426                	sd	s1,8(sp)
    80000f0e:	1000                	addi	s0,sp,32
    80000f10:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	d2a080e7          	jalr	-726(ra) # 80000c3c <holding>
    80000f1a:	c115                	beqz	a0,80000f3e <release+0x38>
  lk->cpu = 0;
    80000f1c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000f20:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000f24:	0f50000f          	fence	iorw,ow
    80000f28:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	f7a080e7          	jalr	-134(ra) # 80000ea6 <pop_off>
}
    80000f34:	60e2                	ld	ra,24(sp)
    80000f36:	6442                	ld	s0,16(sp)
    80000f38:	64a2                	ld	s1,8(sp)
    80000f3a:	6105                	addi	sp,sp,32
    80000f3c:	8082                	ret
    panic("release");
    80000f3e:	00007517          	auipc	a0,0x7
    80000f42:	46a50513          	addi	a0,a0,1130 # 800083a8 <userret+0x318>
    80000f46:	00000097          	auipc	ra,0x0
    80000f4a:	83e080e7          	jalr	-1986(ra) # 80000784 <panic>

0000000080000f4e <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000f4e:	5154                	lw	a3,36(a0)
    80000f50:	e291                	bnez	a3,80000f54 <print_lock+0x6>
    80000f52:	8082                	ret
{
    80000f54:	1141                	addi	sp,sp,-16
    80000f56:	e406                	sd	ra,8(sp)
    80000f58:	e022                	sd	s0,0(sp)
    80000f5a:	0800                	addi	s0,sp,16
    printf("lock: %s: #test-and-set %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000f5c:	5510                	lw	a2,40(a0)
    80000f5e:	650c                	ld	a1,8(a0)
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	45050513          	addi	a0,a0,1104 # 800083b0 <userret+0x320>
    80000f68:	00000097          	auipc	ra,0x0
    80000f6c:	a34080e7          	jalr	-1484(ra) # 8000099c <printf>
}
    80000f70:	60a2                	ld	ra,8(sp)
    80000f72:	6402                	ld	s0,0(sp)
    80000f74:	0141                	addi	sp,sp,16
    80000f76:	8082                	ret

0000000080000f78 <sys_ntas>:

uint64
sys_ntas(void)
{
    80000f78:	715d                	addi	sp,sp,-80
    80000f7a:	e486                	sd	ra,72(sp)
    80000f7c:	e0a2                	sd	s0,64(sp)
    80000f7e:	fc26                	sd	s1,56(sp)
    80000f80:	f84a                	sd	s2,48(sp)
    80000f82:	f44e                	sd	s3,40(sp)
    80000f84:	f052                	sd	s4,32(sp)
    80000f86:	ec56                	sd	s5,24(sp)
    80000f88:	e85a                	sd	s6,16(sp)
    80000f8a:	0880                	addi	s0,sp,80
  int zero = 0;
    80000f8c:	fa042e23          	sw	zero,-68(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000f90:	fbc40593          	addi	a1,s0,-68
    80000f94:	4501                	li	a0,0
    80000f96:	00002097          	auipc	ra,0x2
    80000f9a:	3fc080e7          	jalr	1020(ra) # 80003392 <argint>
    80000f9e:	18054263          	bltz	a0,80001122 <sys_ntas+0x1aa>
    return -1;
  }
  if(zero == 0) {
    80000fa2:	fbc42783          	lw	a5,-68(s0)
    80000fa6:	e3a9                	bnez	a5,80000fe8 <sys_ntas+0x70>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000fa8:	00013797          	auipc	a5,0x13
    80000fac:	b0078793          	addi	a5,a5,-1280 # 80013aa8 <locks>
    80000fb0:	639c                	ld	a5,0(a5)
    80000fb2:	16078a63          	beqz	a5,80001126 <sys_ntas+0x1ae>
        break;
      locks[i]->nts = 0;
    80000fb6:	0207a423          	sw	zero,40(a5)
      locks[i]->n = 0;
    80000fba:	0207a223          	sw	zero,36(a5)
    80000fbe:	00013797          	auipc	a5,0x13
    80000fc2:	af278793          	addi	a5,a5,-1294 # 80013ab0 <locks+0x8>
    80000fc6:	00015697          	auipc	a3,0x15
    80000fca:	a2268693          	addi	a3,a3,-1502 # 800159e8 <prio>
      if(locks[i] == 0)
    80000fce:	6398                	ld	a4,0(a5)
    80000fd0:	14070d63          	beqz	a4,8000112a <sys_ntas+0x1b2>
      locks[i]->nts = 0;
    80000fd4:	02072423          	sw	zero,40(a4)
      locks[i]->n = 0;
    80000fd8:	6398                	ld	a4,0(a5)
    80000fda:	02072223          	sw	zero,36(a4)
    80000fde:	07a1                	addi	a5,a5,8
    for(int i = 0; i < NLOCK; i++) {
    80000fe0:	fed797e3          	bne	a5,a3,80000fce <sys_ntas+0x56>
    }
    return 0;
    80000fe4:	4501                	li	a0,0
    80000fe6:	a225                	j	8000110e <sys_ntas+0x196>
  }

  printf("=== lock kmem/bcache stats\n");
    80000fe8:	00007517          	auipc	a0,0x7
    80000fec:	3f850513          	addi	a0,a0,1016 # 800083e0 <userret+0x350>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	9ac080e7          	jalr	-1620(ra) # 8000099c <printf>
  for(int i = 0; i < NLOCK; i++) {
    if(locks[i] == 0)
    80000ff8:	00013797          	auipc	a5,0x13
    80000ffc:	ab078793          	addi	a5,a5,-1360 # 80013aa8 <locks>
    80001000:	639c                	ld	a5,0(a5)
    80001002:	c3d1                	beqz	a5,80001086 <sys_ntas+0x10e>
    80001004:	00013497          	auipc	s1,0x13
    80001008:	aa448493          	addi	s1,s1,-1372 # 80013aa8 <locks>
    8000100c:	00015a97          	auipc	s5,0x15
    80001010:	9d4a8a93          	addi	s5,s5,-1580 # 800159e0 <locks+0x1f38>
  int tot = 0;
    80001014:	4981                	li	s3,0
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80001016:	00007917          	auipc	s2,0x7
    8000101a:	3ea90913          	addi	s2,s2,1002 # 80008400 <userret+0x370>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    8000101e:	00007b17          	auipc	s6,0x7
    80001022:	3eab0b13          	addi	s6,s6,1002 # 80008408 <userret+0x378>
    80001026:	a831                	j	80001042 <sys_ntas+0xca>
      tot += locks[i]->nts;
    80001028:	6088                	ld	a0,0(s1)
    8000102a:	551c                	lw	a5,40(a0)
    8000102c:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80001030:	00000097          	auipc	ra,0x0
    80001034:	f1e080e7          	jalr	-226(ra) # 80000f4e <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80001038:	05548863          	beq	s1,s5,80001088 <sys_ntas+0x110>
    if(locks[i] == 0)
    8000103c:	04a1                	addi	s1,s1,8
    8000103e:	609c                	ld	a5,0(s1)
    80001040:	c7a1                	beqz	a5,80001088 <sys_ntas+0x110>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80001042:	0087ba03          	ld	s4,8(a5)
    80001046:	854a                	mv	a0,s2
    80001048:	00000097          	auipc	ra,0x0
    8000104c:	290080e7          	jalr	656(ra) # 800012d8 <strlen>
    80001050:	0005061b          	sext.w	a2,a0
    80001054:	85ca                	mv	a1,s2
    80001056:	8552                	mv	a0,s4
    80001058:	00000097          	auipc	ra,0x0
    8000105c:	1be080e7          	jalr	446(ra) # 80001216 <strncmp>
    80001060:	d561                	beqz	a0,80001028 <sys_ntas+0xb0>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80001062:	609c                	ld	a5,0(s1)
    80001064:	0087ba03          	ld	s4,8(a5)
    80001068:	855a                	mv	a0,s6
    8000106a:	00000097          	auipc	ra,0x0
    8000106e:	26e080e7          	jalr	622(ra) # 800012d8 <strlen>
    80001072:	0005061b          	sext.w	a2,a0
    80001076:	85da                	mv	a1,s6
    80001078:	8552                	mv	a0,s4
    8000107a:	00000097          	auipc	ra,0x0
    8000107e:	19c080e7          	jalr	412(ra) # 80001216 <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80001082:	f95d                	bnez	a0,80001038 <sys_ntas+0xc0>
    80001084:	b755                	j	80001028 <sys_ntas+0xb0>
  int tot = 0;
    80001086:	4981                	li	s3,0
    }
  }

  printf("=== top 5 contended locks:\n");
    80001088:	00007517          	auipc	a0,0x7
    8000108c:	38850513          	addi	a0,a0,904 # 80008410 <userret+0x380>
    80001090:	00000097          	auipc	ra,0x0
    80001094:	90c080e7          	jalr	-1780(ra) # 8000099c <printf>
    80001098:	4a15                	li	s4,5
  int last = 100000000;
    8000109a:	05f5e537          	lui	a0,0x5f5e
    8000109e:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    800010a2:	00013497          	auipc	s1,0x13
    800010a6:	a0648493          	addi	s1,s1,-1530 # 80013aa8 <locks>
    for(int i = 0; i < NLOCK; i++) {
    800010aa:	4a81                	li	s5,0
    800010ac:	3e800913          	li	s2,1000
    800010b0:	a0a1                	j	800010f8 <sys_ntas+0x180>
    800010b2:	2705                	addiw	a4,a4,1
    800010b4:	03270363          	beq	a4,s2,800010da <sys_ntas+0x162>
      if(locks[i] == 0)
    800010b8:	06a1                	addi	a3,a3,8
    800010ba:	ff86b783          	ld	a5,-8(a3)
    800010be:	cf91                	beqz	a5,800010da <sys_ntas+0x162>
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    800010c0:	5790                	lw	a2,40(a5)
    800010c2:	00359793          	slli	a5,a1,0x3
    800010c6:	97a6                	add	a5,a5,s1
    800010c8:	639c                	ld	a5,0(a5)
    800010ca:	579c                	lw	a5,40(a5)
    800010cc:	fec7f3e3          	bleu	a2,a5,800010b2 <sys_ntas+0x13a>
    800010d0:	fea671e3          	bleu	a0,a2,800010b2 <sys_ntas+0x13a>
    800010d4:	85ba                	mv	a1,a4
    800010d6:	bff1                	j	800010b2 <sys_ntas+0x13a>
    int top = 0;
    800010d8:	85d6                	mv	a1,s5
        top = i;
      }
    }
    print_lock(locks[top]);
    800010da:	058e                	slli	a1,a1,0x3
    800010dc:	00b48b33          	add	s6,s1,a1
    800010e0:	000b3503          	ld	a0,0(s6)
    800010e4:	00000097          	auipc	ra,0x0
    800010e8:	e6a080e7          	jalr	-406(ra) # 80000f4e <print_lock>
    last = locks[top]->nts;
    800010ec:	000b3783          	ld	a5,0(s6)
    800010f0:	5788                	lw	a0,40(a5)
    800010f2:	3a7d                	addiw	s4,s4,-1
  for(int t= 0; t < 5; t++) {
    800010f4:	000a0c63          	beqz	s4,8000110c <sys_ntas+0x194>
      if(locks[i] == 0)
    800010f8:	609c                	ld	a5,0(s1)
    800010fa:	dff9                	beqz	a5,800010d8 <sys_ntas+0x160>
    800010fc:	00013697          	auipc	a3,0x13
    80001100:	9b468693          	addi	a3,a3,-1612 # 80013ab0 <locks+0x8>
    for(int i = 0; i < NLOCK; i++) {
    80001104:	8756                	mv	a4,s5
    int top = 0;
    80001106:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80001108:	2501                	sext.w	a0,a0
    8000110a:	bf5d                	j	800010c0 <sys_ntas+0x148>
  }
  return tot;
    8000110c:	854e                	mv	a0,s3
}
    8000110e:	60a6                	ld	ra,72(sp)
    80001110:	6406                	ld	s0,64(sp)
    80001112:	74e2                	ld	s1,56(sp)
    80001114:	7942                	ld	s2,48(sp)
    80001116:	79a2                	ld	s3,40(sp)
    80001118:	7a02                	ld	s4,32(sp)
    8000111a:	6ae2                	ld	s5,24(sp)
    8000111c:	6b42                	ld	s6,16(sp)
    8000111e:	6161                	addi	sp,sp,80
    80001120:	8082                	ret
    return -1;
    80001122:	557d                	li	a0,-1
    80001124:	b7ed                	j	8000110e <sys_ntas+0x196>
    return 0;
    80001126:	4501                	li	a0,0
    80001128:	b7dd                	j	8000110e <sys_ntas+0x196>
    8000112a:	4501                	li	a0,0
    8000112c:	b7cd                	j	8000110e <sys_ntas+0x196>

000000008000112e <memset>:
#include "types.h"
#include "defs.h"

void*
memset(void *dst, int c, uint n)
{
    8000112e:	1141                	addi	sp,sp,-16
    80001130:	e422                	sd	s0,8(sp)
    80001132:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80001134:	ce09                	beqz	a2,8000114e <memset+0x20>
    80001136:	87aa                	mv	a5,a0
    80001138:	fff6071b          	addiw	a4,a2,-1
    8000113c:	1702                	slli	a4,a4,0x20
    8000113e:	9301                	srli	a4,a4,0x20
    80001140:	0705                	addi	a4,a4,1
    80001142:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80001144:	00b78023          	sb	a1,0(a5)
    80001148:	0785                	addi	a5,a5,1
  for(i = 0; i < n; i++){
    8000114a:	fee79de3          	bne	a5,a4,80001144 <memset+0x16>
  }
  return dst;
}
    8000114e:	6422                	ld	s0,8(sp)
    80001150:	0141                	addi	sp,sp,16
    80001152:	8082                	ret

0000000080001154 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80001154:	1141                	addi	sp,sp,-16
    80001156:	e422                	sd	s0,8(sp)
    80001158:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000115a:	ce15                	beqz	a2,80001196 <memcmp+0x42>
    8000115c:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    80001160:	00054783          	lbu	a5,0(a0)
    80001164:	0005c703          	lbu	a4,0(a1)
    80001168:	02e79063          	bne	a5,a4,80001188 <memcmp+0x34>
    8000116c:	1682                	slli	a3,a3,0x20
    8000116e:	9281                	srli	a3,a3,0x20
    80001170:	0685                	addi	a3,a3,1
    80001172:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    80001174:	0505                	addi	a0,a0,1
    80001176:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80001178:	00d50d63          	beq	a0,a3,80001192 <memcmp+0x3e>
    if(*s1 != *s2)
    8000117c:	00054783          	lbu	a5,0(a0)
    80001180:	0005c703          	lbu	a4,0(a1)
    80001184:	fee788e3          	beq	a5,a4,80001174 <memcmp+0x20>
      return *s1 - *s2;
    80001188:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    8000118c:	6422                	ld	s0,8(sp)
    8000118e:	0141                	addi	sp,sp,16
    80001190:	8082                	ret
  return 0;
    80001192:	4501                	li	a0,0
    80001194:	bfe5                	j	8000118c <memcmp+0x38>
    80001196:	4501                	li	a0,0
    80001198:	bfd5                	j	8000118c <memcmp+0x38>

000000008000119a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    8000119a:	1141                	addi	sp,sp,-16
    8000119c:	e422                	sd	s0,8(sp)
    8000119e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    800011a0:	00a5f963          	bleu	a0,a1,800011b2 <memmove+0x18>
    800011a4:	02061713          	slli	a4,a2,0x20
    800011a8:	9301                	srli	a4,a4,0x20
    800011aa:	00e587b3          	add	a5,a1,a4
    800011ae:	02f56563          	bltu	a0,a5,800011d8 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800011b2:	fff6069b          	addiw	a3,a2,-1
    800011b6:	ce11                	beqz	a2,800011d2 <memmove+0x38>
    800011b8:	1682                	slli	a3,a3,0x20
    800011ba:	9281                	srli	a3,a3,0x20
    800011bc:	0685                	addi	a3,a3,1
    800011be:	96ae                	add	a3,a3,a1
    800011c0:	87aa                	mv	a5,a0
      *d++ = *s++;
    800011c2:	0585                	addi	a1,a1,1
    800011c4:	0785                	addi	a5,a5,1
    800011c6:	fff5c703          	lbu	a4,-1(a1)
    800011ca:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    800011ce:	fed59ae3          	bne	a1,a3,800011c2 <memmove+0x28>

  return dst;
}
    800011d2:	6422                	ld	s0,8(sp)
    800011d4:	0141                	addi	sp,sp,16
    800011d6:	8082                	ret
    d += n;
    800011d8:	972a                	add	a4,a4,a0
    while(n-- > 0)
    800011da:	fff6069b          	addiw	a3,a2,-1
    800011de:	da75                	beqz	a2,800011d2 <memmove+0x38>
    800011e0:	02069613          	slli	a2,a3,0x20
    800011e4:	9201                	srli	a2,a2,0x20
    800011e6:	fff64613          	not	a2,a2
    800011ea:	963e                	add	a2,a2,a5
      *--d = *--s;
    800011ec:	17fd                	addi	a5,a5,-1
    800011ee:	177d                	addi	a4,a4,-1
    800011f0:	0007c683          	lbu	a3,0(a5)
    800011f4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    800011f8:	fef61ae3          	bne	a2,a5,800011ec <memmove+0x52>
    800011fc:	bfd9                	j	800011d2 <memmove+0x38>

00000000800011fe <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    800011fe:	1141                	addi	sp,sp,-16
    80001200:	e406                	sd	ra,8(sp)
    80001202:	e022                	sd	s0,0(sp)
    80001204:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f94080e7          	jalr	-108(ra) # 8000119a <memmove>
}
    8000120e:	60a2                	ld	ra,8(sp)
    80001210:	6402                	ld	s0,0(sp)
    80001212:	0141                	addi	sp,sp,16
    80001214:	8082                	ret

0000000080001216 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001216:	1141                	addi	sp,sp,-16
    80001218:	e422                	sd	s0,8(sp)
    8000121a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    8000121c:	c229                	beqz	a2,8000125e <strncmp+0x48>
    8000121e:	00054783          	lbu	a5,0(a0)
    80001222:	c795                	beqz	a5,8000124e <strncmp+0x38>
    80001224:	0005c703          	lbu	a4,0(a1)
    80001228:	02f71363          	bne	a4,a5,8000124e <strncmp+0x38>
    8000122c:	fff6071b          	addiw	a4,a2,-1
    80001230:	1702                	slli	a4,a4,0x20
    80001232:	9301                	srli	a4,a4,0x20
    80001234:	0705                	addi	a4,a4,1
    80001236:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80001238:	0505                	addi	a0,a0,1
    8000123a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000123c:	02e50363          	beq	a0,a4,80001262 <strncmp+0x4c>
    80001240:	00054783          	lbu	a5,0(a0)
    80001244:	c789                	beqz	a5,8000124e <strncmp+0x38>
    80001246:	0005c683          	lbu	a3,0(a1)
    8000124a:	fef687e3          	beq	a3,a5,80001238 <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    8000124e:	00054503          	lbu	a0,0(a0)
    80001252:	0005c783          	lbu	a5,0(a1)
    80001256:	9d1d                	subw	a0,a0,a5
}
    80001258:	6422                	ld	s0,8(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret
    return 0;
    8000125e:	4501                	li	a0,0
    80001260:	bfe5                	j	80001258 <strncmp+0x42>
    80001262:	4501                	li	a0,0
    80001264:	bfd5                	j	80001258 <strncmp+0x42>

0000000080001266 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80001266:	1141                	addi	sp,sp,-16
    80001268:	e422                	sd	s0,8(sp)
    8000126a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000126c:	872a                	mv	a4,a0
    8000126e:	a011                	j	80001272 <strncpy+0xc>
    80001270:	8636                	mv	a2,a3
    80001272:	fff6069b          	addiw	a3,a2,-1
    80001276:	00c05963          	blez	a2,80001288 <strncpy+0x22>
    8000127a:	0705                	addi	a4,a4,1
    8000127c:	0005c783          	lbu	a5,0(a1)
    80001280:	fef70fa3          	sb	a5,-1(a4)
    80001284:	0585                	addi	a1,a1,1
    80001286:	f7ed                	bnez	a5,80001270 <strncpy+0xa>
    ;
  while(n-- > 0)
    80001288:	00d05c63          	blez	a3,800012a0 <strncpy+0x3a>
    8000128c:	86ba                	mv	a3,a4
    *s++ = 0;
    8000128e:	0685                	addi	a3,a3,1
    80001290:	fe068fa3          	sb	zero,-1(a3)
    80001294:	fff6c793          	not	a5,a3
    80001298:	9fb9                	addw	a5,a5,a4
  while(n-- > 0)
    8000129a:	9fb1                	addw	a5,a5,a2
    8000129c:	fef049e3          	bgtz	a5,8000128e <strncpy+0x28>
  return os;
}
    800012a0:	6422                	ld	s0,8(sp)
    800012a2:	0141                	addi	sp,sp,16
    800012a4:	8082                	ret

00000000800012a6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800012a6:	1141                	addi	sp,sp,-16
    800012a8:	e422                	sd	s0,8(sp)
    800012aa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800012ac:	02c05363          	blez	a2,800012d2 <safestrcpy+0x2c>
    800012b0:	fff6069b          	addiw	a3,a2,-1
    800012b4:	1682                	slli	a3,a3,0x20
    800012b6:	9281                	srli	a3,a3,0x20
    800012b8:	96ae                	add	a3,a3,a1
    800012ba:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800012bc:	00d58963          	beq	a1,a3,800012ce <safestrcpy+0x28>
    800012c0:	0585                	addi	a1,a1,1
    800012c2:	0785                	addi	a5,a5,1
    800012c4:	fff5c703          	lbu	a4,-1(a1)
    800012c8:	fee78fa3          	sb	a4,-1(a5)
    800012cc:	fb65                	bnez	a4,800012bc <safestrcpy+0x16>
    ;
  *s = 0;
    800012ce:	00078023          	sb	zero,0(a5)
  return os;
}
    800012d2:	6422                	ld	s0,8(sp)
    800012d4:	0141                	addi	sp,sp,16
    800012d6:	8082                	ret

00000000800012d8 <strlen>:

int
strlen(const char *s)
{
    800012d8:	1141                	addi	sp,sp,-16
    800012da:	e422                	sd	s0,8(sp)
    800012dc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800012de:	00054783          	lbu	a5,0(a0)
    800012e2:	cf91                	beqz	a5,800012fe <strlen+0x26>
    800012e4:	0505                	addi	a0,a0,1
    800012e6:	87aa                	mv	a5,a0
    800012e8:	4685                	li	a3,1
    800012ea:	9e89                	subw	a3,a3,a0
    ;
    800012ec:	00f6853b          	addw	a0,a3,a5
    800012f0:	0785                	addi	a5,a5,1
  for(n = 0; s[n]; n++)
    800012f2:	fff7c703          	lbu	a4,-1(a5)
    800012f6:	fb7d                	bnez	a4,800012ec <strlen+0x14>
  return n;
}
    800012f8:	6422                	ld	s0,8(sp)
    800012fa:	0141                	addi	sp,sp,16
    800012fc:	8082                	ret
  for(n = 0; s[n]; n++)
    800012fe:	4501                	li	a0,0
    80001300:	bfe5                	j	800012f8 <strlen+0x20>

0000000080001302 <strjoin>:


char* strjoin(char **s){
    80001302:	7139                	addi	sp,sp,-64
    80001304:	fc06                	sd	ra,56(sp)
    80001306:	f822                	sd	s0,48(sp)
    80001308:	f426                	sd	s1,40(sp)
    8000130a:	f04a                	sd	s2,32(sp)
    8000130c:	ec4e                	sd	s3,24(sp)
    8000130e:	e852                	sd	s4,16(sp)
    80001310:	e456                	sd	s5,8(sp)
    80001312:	e05a                	sd	s6,0(sp)
    80001314:	0080                	addi	s0,sp,64
    80001316:	89aa                	mv	s3,a0
  int n = 0;
  char** os = s;
  while(*s){
    80001318:	6108                	ld	a0,0(a0)
    8000131a:	cd3d                	beqz	a0,80001398 <strjoin+0x96>
    8000131c:	84ce                	mv	s1,s3
  int n = 0;
    8000131e:	4901                	li	s2,0
    n += strlen(*s) + 1;
    80001320:	00000097          	auipc	ra,0x0
    80001324:	fb8080e7          	jalr	-72(ra) # 800012d8 <strlen>
    80001328:	2505                	addiw	a0,a0,1
    8000132a:	0125093b          	addw	s2,a0,s2
    s++;
    8000132e:	04a1                	addi	s1,s1,8
  while(*s){
    80001330:	6088                	ld	a0,0(s1)
    80001332:	f57d                	bnez	a0,80001320 <strjoin+0x1e>
  }
  char* d = bd_malloc(n);
    80001334:	854a                	mv	a0,s2
    80001336:	00006097          	auipc	ra,0x6
    8000133a:	d92080e7          	jalr	-622(ra) # 800070c8 <bd_malloc>
    8000133e:	8b2a                	mv	s6,a0
  s = os;
  char* od = d;
  while(*s){
    80001340:	0009b903          	ld	s2,0(s3)
    80001344:	04090c63          	beqz	s2,8000139c <strjoin+0x9a>
  char* d = bd_malloc(n);
    80001348:	8a2a                	mv	s4,a0
    n = strlen(*s);
    safestrcpy(d, *s, n+1);
    d+=n;
    *d++ = ' ';
    8000134a:	02000a93          	li	s5,32
    n = strlen(*s);
    8000134e:	854a                	mv	a0,s2
    80001350:	00000097          	auipc	ra,0x0
    80001354:	f88080e7          	jalr	-120(ra) # 800012d8 <strlen>
    80001358:	84aa                	mv	s1,a0
    safestrcpy(d, *s, n+1);
    8000135a:	0015061b          	addiw	a2,a0,1
    8000135e:	85ca                	mv	a1,s2
    80001360:	8552                	mv	a0,s4
    80001362:	00000097          	auipc	ra,0x0
    80001366:	f44080e7          	jalr	-188(ra) # 800012a6 <safestrcpy>
    d+=n;
    8000136a:	94d2                	add	s1,s1,s4
    *d++ = ' ';
    8000136c:	00148a13          	addi	s4,s1,1
    80001370:	01548023          	sb	s5,0(s1)
    s++;
    80001374:	09a1                	addi	s3,s3,8
  while(*s){
    80001376:	0009b903          	ld	s2,0(s3)
    8000137a:	fc091ae3          	bnez	s2,8000134e <strjoin+0x4c>
  }
  d[-1] = 0;
    8000137e:	fe0a0fa3          	sb	zero,-1(s4)
  return od;
}
    80001382:	855a                	mv	a0,s6
    80001384:	70e2                	ld	ra,56(sp)
    80001386:	7442                	ld	s0,48(sp)
    80001388:	74a2                	ld	s1,40(sp)
    8000138a:	7902                	ld	s2,32(sp)
    8000138c:	69e2                	ld	s3,24(sp)
    8000138e:	6a42                	ld	s4,16(sp)
    80001390:	6aa2                	ld	s5,8(sp)
    80001392:	6b02                	ld	s6,0(sp)
    80001394:	6121                	addi	sp,sp,64
    80001396:	8082                	ret
  int n = 0;
    80001398:	4901                	li	s2,0
    8000139a:	bf69                	j	80001334 <strjoin+0x32>
  char* d = bd_malloc(n);
    8000139c:	8a2a                	mv	s4,a0
    8000139e:	b7c5                	j	8000137e <strjoin+0x7c>

00000000800013a0 <strdup>:


char* strdup(char *s){
    800013a0:	7179                	addi	sp,sp,-48
    800013a2:	f406                	sd	ra,40(sp)
    800013a4:	f022                	sd	s0,32(sp)
    800013a6:	ec26                	sd	s1,24(sp)
    800013a8:	e84a                	sd	s2,16(sp)
    800013aa:	e44e                	sd	s3,8(sp)
    800013ac:	1800                	addi	s0,sp,48
    800013ae:	89aa                	mv	s3,a0
  int n = 0;
  n = strlen(s) + 1;
    800013b0:	00000097          	auipc	ra,0x0
    800013b4:	f28080e7          	jalr	-216(ra) # 800012d8 <strlen>
    800013b8:	0015049b          	addiw	s1,a0,1
  char* d = bd_malloc(n);
    800013bc:	8526                	mv	a0,s1
    800013be:	00006097          	auipc	ra,0x6
    800013c2:	d0a080e7          	jalr	-758(ra) # 800070c8 <bd_malloc>
    800013c6:	892a                	mv	s2,a0
  safestrcpy(d, s, n);
    800013c8:	8626                	mv	a2,s1
    800013ca:	85ce                	mv	a1,s3
    800013cc:	00000097          	auipc	ra,0x0
    800013d0:	eda080e7          	jalr	-294(ra) # 800012a6 <safestrcpy>
  return d;
}
    800013d4:	854a                	mv	a0,s2
    800013d6:	70a2                	ld	ra,40(sp)
    800013d8:	7402                	ld	s0,32(sp)
    800013da:	64e2                	ld	s1,24(sp)
    800013dc:	6942                	ld	s2,16(sp)
    800013de:	69a2                	ld	s3,8(sp)
    800013e0:	6145                	addi	sp,sp,48
    800013e2:	8082                	ret

00000000800013e4 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800013e4:	1141                	addi	sp,sp,-16
    800013e6:	e406                	sd	ra,8(sp)
    800013e8:	e022                	sd	s0,0(sp)
    800013ea:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800013ec:	00001097          	auipc	ra,0x1
    800013f0:	c28080e7          	jalr	-984(ra) # 80002014 <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800013f4:	0002d717          	auipc	a4,0x2d
    800013f8:	c8070713          	addi	a4,a4,-896 # 8002e074 <started>
  if(cpuid() == 0){
    800013fc:	c139                	beqz	a0,80001442 <main+0x5e>
    while(started == 0)
    800013fe:	431c                	lw	a5,0(a4)
    80001400:	2781                	sext.w	a5,a5
    80001402:	dff5                	beqz	a5,800013fe <main+0x1a>
      ;
    __sync_synchronize();
    80001404:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001408:	00001097          	auipc	ra,0x1
    8000140c:	c0c080e7          	jalr	-1012(ra) # 80002014 <cpuid>
    80001410:	85aa                	mv	a1,a0
    80001412:	00007517          	auipc	a0,0x7
    80001416:	03650513          	addi	a0,a0,54 # 80008448 <userret+0x3b8>
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	582080e7          	jalr	1410(ra) # 8000099c <printf>
    kvminithart();    // turn on paging
    80001422:	00000097          	auipc	ra,0x0
    80001426:	1f2080e7          	jalr	498(ra) # 80001614 <kvminithart>
    trapinithart();   // install kernel trap vector
    8000142a:	00002097          	auipc	ra,0x2
    8000142e:	a96080e7          	jalr	-1386(ra) # 80002ec0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001432:	00005097          	auipc	ra,0x5
    80001436:	2ae080e7          	jalr	686(ra) # 800066e0 <plicinithart>
  }

  scheduler();        
    8000143a:	00001097          	auipc	ra,0x1
    8000143e:	1e4080e7          	jalr	484(ra) # 8000261e <scheduler>
    consoleinit();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	1f2080e7          	jalr	498(ra) # 80000634 <consoleinit>
    watchdoginit();
    8000144a:	00006097          	auipc	ra,0x6
    8000144e:	732080e7          	jalr	1842(ra) # 80007b7c <watchdoginit>
    printfinit();
    80001452:	fffff097          	auipc	ra,0xfffff
    80001456:	5be080e7          	jalr	1470(ra) # 80000a10 <printfinit>
    printf("\n");
    8000145a:	00007517          	auipc	a0,0x7
    8000145e:	1ee50513          	addi	a0,a0,494 # 80008648 <userret+0x5b8>
    80001462:	fffff097          	auipc	ra,0xfffff
    80001466:	53a080e7          	jalr	1338(ra) # 8000099c <printf>
    printf("xv6 kernel is booting\n");
    8000146a:	00007517          	auipc	a0,0x7
    8000146e:	fc650513          	addi	a0,a0,-58 # 80008430 <userret+0x3a0>
    80001472:	fffff097          	auipc	ra,0xfffff
    80001476:	52a080e7          	jalr	1322(ra) # 8000099c <printf>
    printf("\n");
    8000147a:	00007517          	auipc	a0,0x7
    8000147e:	1ce50513          	addi	a0,a0,462 # 80008648 <userret+0x5b8>
    80001482:	fffff097          	auipc	ra,0xfffff
    80001486:	51a080e7          	jalr	1306(ra) # 8000099c <printf>
    kinit();         // physical page allocator
    8000148a:	fffff097          	auipc	ra,0xfffff
    8000148e:	668080e7          	jalr	1640(ra) # 80000af2 <kinit>
    kvminit();       // create kernel page table
    80001492:	00000097          	auipc	ra,0x0
    80001496:	312080e7          	jalr	786(ra) # 800017a4 <kvminit>
    kvminithart();   // turn on paging
    8000149a:	00000097          	auipc	ra,0x0
    8000149e:	17a080e7          	jalr	378(ra) # 80001614 <kvminithart>
    procinit();      // process table
    800014a2:	00001097          	auipc	ra,0x1
    800014a6:	a74080e7          	jalr	-1420(ra) # 80001f16 <procinit>
    trapinit();      // trap vectors
    800014aa:	00002097          	auipc	ra,0x2
    800014ae:	9ee080e7          	jalr	-1554(ra) # 80002e98 <trapinit>
    trapinithart();  // install kernel trap vector
    800014b2:	00002097          	auipc	ra,0x2
    800014b6:	a0e080e7          	jalr	-1522(ra) # 80002ec0 <trapinithart>
    plicinit();      // set up interrupt controller
    800014ba:	00005097          	auipc	ra,0x5
    800014be:	210080e7          	jalr	528(ra) # 800066ca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800014c2:	00005097          	auipc	ra,0x5
    800014c6:	21e080e7          	jalr	542(ra) # 800066e0 <plicinithart>
    binit();         // buffer cache
    800014ca:	00002097          	auipc	ra,0x2
    800014ce:	1c0080e7          	jalr	448(ra) # 8000368a <binit>
    iinit();         // inode cache
    800014d2:	00003097          	auipc	ra,0x3
    800014d6:	896080e7          	jalr	-1898(ra) # 80003d68 <iinit>
    fileinit();      // file table
    800014da:	00004097          	auipc	ra,0x4
    800014de:	928080e7          	jalr	-1752(ra) # 80004e02 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    800014e2:	4501                	li	a0,0
    800014e4:	00005097          	auipc	ra,0x5
    800014e8:	31c080e7          	jalr	796(ra) # 80006800 <virtio_disk_init>
    userinit();      // first user process
    800014ec:	00001097          	auipc	ra,0x1
    800014f0:	de4080e7          	jalr	-540(ra) # 800022d0 <userinit>
    __sync_synchronize();
    800014f4:	0ff0000f          	fence
    started = 1;
    800014f8:	4785                	li	a5,1
    800014fa:	0002d717          	auipc	a4,0x2d
    800014fe:	b6f72d23          	sw	a5,-1158(a4) # 8002e074 <started>
    80001502:	bf25                	j	8000143a <main+0x56>

0000000080001504 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001504:	7139                	addi	sp,sp,-64
    80001506:	fc06                	sd	ra,56(sp)
    80001508:	f822                	sd	s0,48(sp)
    8000150a:	f426                	sd	s1,40(sp)
    8000150c:	f04a                	sd	s2,32(sp)
    8000150e:	ec4e                	sd	s3,24(sp)
    80001510:	e852                	sd	s4,16(sp)
    80001512:	e456                	sd	s5,8(sp)
    80001514:	e05a                	sd	s6,0(sp)
    80001516:	0080                	addi	s0,sp,64
    80001518:	84aa                	mv	s1,a0
    8000151a:	89ae                	mv	s3,a1
    8000151c:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    8000151e:	57fd                	li	a5,-1
    80001520:	83e9                	srli	a5,a5,0x1a
    80001522:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001524:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80001526:	04b7f263          	bleu	a1,a5,8000156a <walk+0x66>
    panic("walk");
    8000152a:	00007517          	auipc	a0,0x7
    8000152e:	f3650513          	addi	a0,a0,-202 # 80008460 <userret+0x3d0>
    80001532:	fffff097          	auipc	ra,0xfffff
    80001536:	252080e7          	jalr	594(ra) # 80000784 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000153a:	060b0663          	beqz	s6,800015a6 <walk+0xa2>
    8000153e:	fffff097          	auipc	ra,0xfffff
    80001542:	5f4080e7          	jalr	1524(ra) # 80000b32 <kalloc>
    80001546:	84aa                	mv	s1,a0
    80001548:	c529                	beqz	a0,80001592 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000154a:	6605                	lui	a2,0x1
    8000154c:	4581                	li	a1,0
    8000154e:	00000097          	auipc	ra,0x0
    80001552:	be0080e7          	jalr	-1056(ra) # 8000112e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001556:	00c4d793          	srli	a5,s1,0xc
    8000155a:	07aa                	slli	a5,a5,0xa
    8000155c:	0017e793          	ori	a5,a5,1
    80001560:	00f93023          	sd	a5,0(s2)
    80001564:	3a5d                	addiw	s4,s4,-9
  for(int level = 2; level > 0; level--) {
    80001566:	035a0063          	beq	s4,s5,80001586 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000156a:	0149d933          	srl	s2,s3,s4
    8000156e:	1ff97913          	andi	s2,s2,511
    80001572:	090e                	slli	s2,s2,0x3
    80001574:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001576:	00093483          	ld	s1,0(s2)
    8000157a:	0014f793          	andi	a5,s1,1
    8000157e:	dfd5                	beqz	a5,8000153a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001580:	80a9                	srli	s1,s1,0xa
    80001582:	04b2                	slli	s1,s1,0xc
    80001584:	b7c5                	j	80001564 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001586:	00c9d513          	srli	a0,s3,0xc
    8000158a:	1ff57513          	andi	a0,a0,511
    8000158e:	050e                	slli	a0,a0,0x3
    80001590:	9526                	add	a0,a0,s1
}
    80001592:	70e2                	ld	ra,56(sp)
    80001594:	7442                	ld	s0,48(sp)
    80001596:	74a2                	ld	s1,40(sp)
    80001598:	7902                	ld	s2,32(sp)
    8000159a:	69e2                	ld	s3,24(sp)
    8000159c:	6a42                	ld	s4,16(sp)
    8000159e:	6aa2                	ld	s5,8(sp)
    800015a0:	6b02                	ld	s6,0(sp)
    800015a2:	6121                	addi	sp,sp,64
    800015a4:	8082                	ret
        return 0;
    800015a6:	4501                	li	a0,0
    800015a8:	b7ed                	j	80001592 <walk+0x8e>

00000000800015aa <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    800015aa:	7179                	addi	sp,sp,-48
    800015ac:	f406                	sd	ra,40(sp)
    800015ae:	f022                	sd	s0,32(sp)
    800015b0:	ec26                	sd	s1,24(sp)
    800015b2:	e84a                	sd	s2,16(sp)
    800015b4:	e44e                	sd	s3,8(sp)
    800015b6:	e052                	sd	s4,0(sp)
    800015b8:	1800                	addi	s0,sp,48
    800015ba:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015bc:	84aa                	mv	s1,a0
    800015be:	6905                	lui	s2,0x1
    800015c0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c2:	4985                	li	s3,1
    800015c4:	a821                	j	800015dc <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015c6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015c8:	0532                	slli	a0,a0,0xc
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	fe0080e7          	jalr	-32(ra) # 800015aa <freewalk>
      pagetable[i] = 0;
    800015d2:	0004b023          	sd	zero,0(s1)
    800015d6:	04a1                	addi	s1,s1,8
  for(int i = 0; i < 512; i++){
    800015d8:	03248163          	beq	s1,s2,800015fa <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015dc:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015de:	00f57793          	andi	a5,a0,15
    800015e2:	ff3782e3          	beq	a5,s3,800015c6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015e6:	8905                	andi	a0,a0,1
    800015e8:	d57d                	beqz	a0,800015d6 <freewalk+0x2c>
      panic("freewalk: leaf");
    800015ea:	00007517          	auipc	a0,0x7
    800015ee:	e7e50513          	addi	a0,a0,-386 # 80008468 <userret+0x3d8>
    800015f2:	fffff097          	auipc	ra,0xfffff
    800015f6:	192080e7          	jalr	402(ra) # 80000784 <panic>
    }
  }
  kfree((void*)pagetable);
    800015fa:	8552                	mv	a0,s4
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	51e080e7          	jalr	1310(ra) # 80000b1a <kfree>
}
    80001604:	70a2                	ld	ra,40(sp)
    80001606:	7402                	ld	s0,32(sp)
    80001608:	64e2                	ld	s1,24(sp)
    8000160a:	6942                	ld	s2,16(sp)
    8000160c:	69a2                	ld	s3,8(sp)
    8000160e:	6a02                	ld	s4,0(sp)
    80001610:	6145                	addi	sp,sp,48
    80001612:	8082                	ret

0000000080001614 <kvminithart>:
{
    80001614:	1141                	addi	sp,sp,-16
    80001616:	e422                	sd	s0,8(sp)
    80001618:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000161a:	0002d797          	auipc	a5,0x2d
    8000161e:	a5e78793          	addi	a5,a5,-1442 # 8002e078 <kernel_pagetable>
    80001622:	639c                	ld	a5,0(a5)
    80001624:	83b1                	srli	a5,a5,0xc
    80001626:	577d                	li	a4,-1
    80001628:	177e                	slli	a4,a4,0x3f
    8000162a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000162c:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001630:	12000073          	sfence.vma
}
    80001634:	6422                	ld	s0,8(sp)
    80001636:	0141                	addi	sp,sp,16
    80001638:	8082                	ret

000000008000163a <walkaddr>:
  if(va >= MAXVA)
    8000163a:	57fd                	li	a5,-1
    8000163c:	83e9                	srli	a5,a5,0x1a
    8000163e:	00b7f463          	bleu	a1,a5,80001646 <walkaddr+0xc>
    return 0;
    80001642:	4501                	li	a0,0
}
    80001644:	8082                	ret
{
    80001646:	1141                	addi	sp,sp,-16
    80001648:	e406                	sd	ra,8(sp)
    8000164a:	e022                	sd	s0,0(sp)
    8000164c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000164e:	4601                	li	a2,0
    80001650:	00000097          	auipc	ra,0x0
    80001654:	eb4080e7          	jalr	-332(ra) # 80001504 <walk>
  if(pte == 0)
    80001658:	c105                	beqz	a0,80001678 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000165a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000165c:	0117f693          	andi	a3,a5,17
    80001660:	4745                	li	a4,17
    return 0;
    80001662:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001664:	00e68663          	beq	a3,a4,80001670 <walkaddr+0x36>
}
    80001668:	60a2                	ld	ra,8(sp)
    8000166a:	6402                	ld	s0,0(sp)
    8000166c:	0141                	addi	sp,sp,16
    8000166e:	8082                	ret
  pa = PTE2PA(*pte);
    80001670:	00a7d513          	srli	a0,a5,0xa
    80001674:	0532                	slli	a0,a0,0xc
  return pa;
    80001676:	bfcd                	j	80001668 <walkaddr+0x2e>
    return 0;
    80001678:	4501                	li	a0,0
    8000167a:	b7fd                	j	80001668 <walkaddr+0x2e>

000000008000167c <kvmpa>:
{
    8000167c:	1101                	addi	sp,sp,-32
    8000167e:	ec06                	sd	ra,24(sp)
    80001680:	e822                	sd	s0,16(sp)
    80001682:	e426                	sd	s1,8(sp)
    80001684:	1000                	addi	s0,sp,32
    80001686:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001688:	6785                	lui	a5,0x1
    8000168a:	17fd                	addi	a5,a5,-1
    8000168c:	00f574b3          	and	s1,a0,a5
  pte = walk(kernel_pagetable, va, 0);
    80001690:	4601                	li	a2,0
    80001692:	0002d797          	auipc	a5,0x2d
    80001696:	9e678793          	addi	a5,a5,-1562 # 8002e078 <kernel_pagetable>
    8000169a:	6388                	ld	a0,0(a5)
    8000169c:	00000097          	auipc	ra,0x0
    800016a0:	e68080e7          	jalr	-408(ra) # 80001504 <walk>
  if(pte == 0)
    800016a4:	cd09                	beqz	a0,800016be <kvmpa+0x42>
  if((*pte & PTE_V) == 0)
    800016a6:	6108                	ld	a0,0(a0)
    800016a8:	00157793          	andi	a5,a0,1
    800016ac:	c38d                	beqz	a5,800016ce <kvmpa+0x52>
  pa = PTE2PA(*pte);
    800016ae:	8129                	srli	a0,a0,0xa
    800016b0:	0532                	slli	a0,a0,0xc
}
    800016b2:	9526                	add	a0,a0,s1
    800016b4:	60e2                	ld	ra,24(sp)
    800016b6:	6442                	ld	s0,16(sp)
    800016b8:	64a2                	ld	s1,8(sp)
    800016ba:	6105                	addi	sp,sp,32
    800016bc:	8082                	ret
    panic("kvmpa");
    800016be:	00007517          	auipc	a0,0x7
    800016c2:	dba50513          	addi	a0,a0,-582 # 80008478 <userret+0x3e8>
    800016c6:	fffff097          	auipc	ra,0xfffff
    800016ca:	0be080e7          	jalr	190(ra) # 80000784 <panic>
    panic("kvmpa");
    800016ce:	00007517          	auipc	a0,0x7
    800016d2:	daa50513          	addi	a0,a0,-598 # 80008478 <userret+0x3e8>
    800016d6:	fffff097          	auipc	ra,0xfffff
    800016da:	0ae080e7          	jalr	174(ra) # 80000784 <panic>

00000000800016de <mappages>:
{
    800016de:	715d                	addi	sp,sp,-80
    800016e0:	e486                	sd	ra,72(sp)
    800016e2:	e0a2                	sd	s0,64(sp)
    800016e4:	fc26                	sd	s1,56(sp)
    800016e6:	f84a                	sd	s2,48(sp)
    800016e8:	f44e                	sd	s3,40(sp)
    800016ea:	f052                	sd	s4,32(sp)
    800016ec:	ec56                	sd	s5,24(sp)
    800016ee:	e85a                	sd	s6,16(sp)
    800016f0:	e45e                	sd	s7,8(sp)
    800016f2:	0880                	addi	s0,sp,80
    800016f4:	8aaa                	mv	s5,a0
    800016f6:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    800016f8:	79fd                	lui	s3,0xfffff
    800016fa:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    800016fe:	167d                	addi	a2,a2,-1
    80001700:	962e                	add	a2,a2,a1
    80001702:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    80001706:	8952                	mv	s2,s4
    80001708:	41468a33          	sub	s4,a3,s4
    a += PGSIZE;
    8000170c:	6b85                	lui	s7,0x1
    8000170e:	a811                	j	80001722 <mappages+0x44>
      panic("remap");
    80001710:	00007517          	auipc	a0,0x7
    80001714:	d7050513          	addi	a0,a0,-656 # 80008480 <userret+0x3f0>
    80001718:	fffff097          	auipc	ra,0xfffff
    8000171c:	06c080e7          	jalr	108(ra) # 80000784 <panic>
    a += PGSIZE;
    80001720:	995e                	add	s2,s2,s7
    pa += PGSIZE;
    80001722:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001726:	4605                	li	a2,1
    80001728:	85ca                	mv	a1,s2
    8000172a:	8556                	mv	a0,s5
    8000172c:	00000097          	auipc	ra,0x0
    80001730:	dd8080e7          	jalr	-552(ra) # 80001504 <walk>
    80001734:	cd19                	beqz	a0,80001752 <mappages+0x74>
    if(*pte & PTE_V)
    80001736:	611c                	ld	a5,0(a0)
    80001738:	8b85                	andi	a5,a5,1
    8000173a:	fbf9                	bnez	a5,80001710 <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000173c:	80b1                	srli	s1,s1,0xc
    8000173e:	04aa                	slli	s1,s1,0xa
    80001740:	0164e4b3          	or	s1,s1,s6
    80001744:	0014e493          	ori	s1,s1,1
    80001748:	e104                	sd	s1,0(a0)
    if(a == last)
    8000174a:	fd391be3          	bne	s2,s3,80001720 <mappages+0x42>
  return 0;
    8000174e:	4501                	li	a0,0
    80001750:	a011                	j	80001754 <mappages+0x76>
      return -1;
    80001752:	557d                	li	a0,-1
}
    80001754:	60a6                	ld	ra,72(sp)
    80001756:	6406                	ld	s0,64(sp)
    80001758:	74e2                	ld	s1,56(sp)
    8000175a:	7942                	ld	s2,48(sp)
    8000175c:	79a2                	ld	s3,40(sp)
    8000175e:	7a02                	ld	s4,32(sp)
    80001760:	6ae2                	ld	s5,24(sp)
    80001762:	6b42                	ld	s6,16(sp)
    80001764:	6ba2                	ld	s7,8(sp)
    80001766:	6161                	addi	sp,sp,80
    80001768:	8082                	ret

000000008000176a <kvmmap>:
{
    8000176a:	1141                	addi	sp,sp,-16
    8000176c:	e406                	sd	ra,8(sp)
    8000176e:	e022                	sd	s0,0(sp)
    80001770:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001772:	8736                	mv	a4,a3
    80001774:	86ae                	mv	a3,a1
    80001776:	85aa                	mv	a1,a0
    80001778:	0002d797          	auipc	a5,0x2d
    8000177c:	90078793          	addi	a5,a5,-1792 # 8002e078 <kernel_pagetable>
    80001780:	6388                	ld	a0,0(a5)
    80001782:	00000097          	auipc	ra,0x0
    80001786:	f5c080e7          	jalr	-164(ra) # 800016de <mappages>
    8000178a:	e509                	bnez	a0,80001794 <kvmmap+0x2a>
}
    8000178c:	60a2                	ld	ra,8(sp)
    8000178e:	6402                	ld	s0,0(sp)
    80001790:	0141                	addi	sp,sp,16
    80001792:	8082                	ret
    panic("kvmmap");
    80001794:	00007517          	auipc	a0,0x7
    80001798:	cf450513          	addi	a0,a0,-780 # 80008488 <userret+0x3f8>
    8000179c:	fffff097          	auipc	ra,0xfffff
    800017a0:	fe8080e7          	jalr	-24(ra) # 80000784 <panic>

00000000800017a4 <kvminit>:
{
    800017a4:	1101                	addi	sp,sp,-32
    800017a6:	ec06                	sd	ra,24(sp)
    800017a8:	e822                	sd	s0,16(sp)
    800017aa:	e426                	sd	s1,8(sp)
    800017ac:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800017ae:	fffff097          	auipc	ra,0xfffff
    800017b2:	384080e7          	jalr	900(ra) # 80000b32 <kalloc>
    800017b6:	0002d797          	auipc	a5,0x2d
    800017ba:	8ca7b123          	sd	a0,-1854(a5) # 8002e078 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800017be:	6605                	lui	a2,0x1
    800017c0:	4581                	li	a1,0
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	96c080e7          	jalr	-1684(ra) # 8000112e <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800017ca:	4699                	li	a3,6
    800017cc:	6605                	lui	a2,0x1
    800017ce:	100005b7          	lui	a1,0x10000
    800017d2:	10000537          	lui	a0,0x10000
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	f94080e7          	jalr	-108(ra) # 8000176a <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    800017de:	4699                	li	a3,6
    800017e0:	6605                	lui	a2,0x1
    800017e2:	100015b7          	lui	a1,0x10001
    800017e6:	10001537          	lui	a0,0x10001
    800017ea:	00000097          	auipc	ra,0x0
    800017ee:	f80080e7          	jalr	-128(ra) # 8000176a <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    800017f2:	4699                	li	a3,6
    800017f4:	6605                	lui	a2,0x1
    800017f6:	100025b7          	lui	a1,0x10002
    800017fa:	10002537          	lui	a0,0x10002
    800017fe:	00000097          	auipc	ra,0x0
    80001802:	f6c080e7          	jalr	-148(ra) # 8000176a <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001806:	4699                	li	a3,6
    80001808:	6641                	lui	a2,0x10
    8000180a:	020005b7          	lui	a1,0x2000
    8000180e:	02000537          	lui	a0,0x2000
    80001812:	00000097          	auipc	ra,0x0
    80001816:	f58080e7          	jalr	-168(ra) # 8000176a <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000181a:	4699                	li	a3,6
    8000181c:	00400637          	lui	a2,0x400
    80001820:	0c0005b7          	lui	a1,0xc000
    80001824:	0c000537          	lui	a0,0xc000
    80001828:	00000097          	auipc	ra,0x0
    8000182c:	f42080e7          	jalr	-190(ra) # 8000176a <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001830:	00008497          	auipc	s1,0x8
    80001834:	7d048493          	addi	s1,s1,2000 # 8000a000 <initcode>
    80001838:	46a9                	li	a3,10
    8000183a:	80008617          	auipc	a2,0x80008
    8000183e:	7c660613          	addi	a2,a2,1990 # a000 <_entry-0x7fff6000>
    80001842:	4585                	li	a1,1
    80001844:	05fe                	slli	a1,a1,0x1f
    80001846:	852e                	mv	a0,a1
    80001848:	00000097          	auipc	ra,0x0
    8000184c:	f22080e7          	jalr	-222(ra) # 8000176a <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001850:	4699                	li	a3,6
    80001852:	4645                	li	a2,17
    80001854:	066e                	slli	a2,a2,0x1b
    80001856:	8e05                	sub	a2,a2,s1
    80001858:	85a6                	mv	a1,s1
    8000185a:	8526                	mv	a0,s1
    8000185c:	00000097          	auipc	ra,0x0
    80001860:	f0e080e7          	jalr	-242(ra) # 8000176a <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001864:	46a9                	li	a3,10
    80001866:	6605                	lui	a2,0x1
    80001868:	00006597          	auipc	a1,0x6
    8000186c:	79858593          	addi	a1,a1,1944 # 80008000 <trampoline>
    80001870:	04000537          	lui	a0,0x4000
    80001874:	157d                	addi	a0,a0,-1
    80001876:	0532                	slli	a0,a0,0xc
    80001878:	00000097          	auipc	ra,0x0
    8000187c:	ef2080e7          	jalr	-270(ra) # 8000176a <kvmmap>
}
    80001880:	60e2                	ld	ra,24(sp)
    80001882:	6442                	ld	s0,16(sp)
    80001884:	64a2                	ld	s1,8(sp)
    80001886:	6105                	addi	sp,sp,32
    80001888:	8082                	ret

000000008000188a <uvmunmap>:
{
    8000188a:	715d                	addi	sp,sp,-80
    8000188c:	e486                	sd	ra,72(sp)
    8000188e:	e0a2                	sd	s0,64(sp)
    80001890:	fc26                	sd	s1,56(sp)
    80001892:	f84a                	sd	s2,48(sp)
    80001894:	f44e                	sd	s3,40(sp)
    80001896:	f052                	sd	s4,32(sp)
    80001898:	ec56                	sd	s5,24(sp)
    8000189a:	e85a                	sd	s6,16(sp)
    8000189c:	e45e                	sd	s7,8(sp)
    8000189e:	0880                	addi	s0,sp,80
    800018a0:	8a2a                	mv	s4,a0
    800018a2:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800018a4:	79fd                	lui	s3,0xfffff
    800018a6:	0135f933          	and	s2,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    800018aa:	167d                	addi	a2,a2,-1
    800018ac:	962e                	add	a2,a2,a1
    800018ae:	013679b3          	and	s3,a2,s3
    if(PTE_FLAGS(*pte) == PTE_V)
    800018b2:	4b05                	li	s6,1
    a += PGSIZE;
    800018b4:	6b85                	lui	s7,0x1
    800018b6:	a8b1                	j	80001912 <uvmunmap+0x88>
      panic("uvmunmap: walk");
    800018b8:	00007517          	auipc	a0,0x7
    800018bc:	bd850513          	addi	a0,a0,-1064 # 80008490 <userret+0x400>
    800018c0:	fffff097          	auipc	ra,0xfffff
    800018c4:	ec4080e7          	jalr	-316(ra) # 80000784 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800018c8:	862a                	mv	a2,a0
    800018ca:	85ca                	mv	a1,s2
    800018cc:	00007517          	auipc	a0,0x7
    800018d0:	bd450513          	addi	a0,a0,-1068 # 800084a0 <userret+0x410>
    800018d4:	fffff097          	auipc	ra,0xfffff
    800018d8:	0c8080e7          	jalr	200(ra) # 8000099c <printf>
      panic("uvmunmap: not mapped");
    800018dc:	00007517          	auipc	a0,0x7
    800018e0:	bd450513          	addi	a0,a0,-1068 # 800084b0 <userret+0x420>
    800018e4:	fffff097          	auipc	ra,0xfffff
    800018e8:	ea0080e7          	jalr	-352(ra) # 80000784 <panic>
      panic("uvmunmap: not a leaf");
    800018ec:	00007517          	auipc	a0,0x7
    800018f0:	bdc50513          	addi	a0,a0,-1060 # 800084c8 <userret+0x438>
    800018f4:	fffff097          	auipc	ra,0xfffff
    800018f8:	e90080e7          	jalr	-368(ra) # 80000784 <panic>
      pa = PTE2PA(*pte);
    800018fc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800018fe:	0532                	slli	a0,a0,0xc
    80001900:	fffff097          	auipc	ra,0xfffff
    80001904:	21a080e7          	jalr	538(ra) # 80000b1a <kfree>
    *pte = 0;
    80001908:	0004b023          	sd	zero,0(s1)
    if(a == last)
    8000190c:	03390763          	beq	s2,s3,8000193a <uvmunmap+0xb0>
    a += PGSIZE;
    80001910:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    80001912:	4601                	li	a2,0
    80001914:	85ca                	mv	a1,s2
    80001916:	8552                	mv	a0,s4
    80001918:	00000097          	auipc	ra,0x0
    8000191c:	bec080e7          	jalr	-1044(ra) # 80001504 <walk>
    80001920:	84aa                	mv	s1,a0
    80001922:	d959                	beqz	a0,800018b8 <uvmunmap+0x2e>
    if((*pte & PTE_V) == 0){
    80001924:	6108                	ld	a0,0(a0)
    80001926:	00157793          	andi	a5,a0,1
    8000192a:	dfd9                	beqz	a5,800018c8 <uvmunmap+0x3e>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000192c:	3ff57793          	andi	a5,a0,1023
    80001930:	fb678ee3          	beq	a5,s6,800018ec <uvmunmap+0x62>
    if(do_free){
    80001934:	fc0a8ae3          	beqz	s5,80001908 <uvmunmap+0x7e>
    80001938:	b7d1                	j	800018fc <uvmunmap+0x72>
}
    8000193a:	60a6                	ld	ra,72(sp)
    8000193c:	6406                	ld	s0,64(sp)
    8000193e:	74e2                	ld	s1,56(sp)
    80001940:	7942                	ld	s2,48(sp)
    80001942:	79a2                	ld	s3,40(sp)
    80001944:	7a02                	ld	s4,32(sp)
    80001946:	6ae2                	ld	s5,24(sp)
    80001948:	6b42                	ld	s6,16(sp)
    8000194a:	6ba2                	ld	s7,8(sp)
    8000194c:	6161                	addi	sp,sp,80
    8000194e:	8082                	ret

0000000080001950 <uvmcreate>:
{
    80001950:	1101                	addi	sp,sp,-32
    80001952:	ec06                	sd	ra,24(sp)
    80001954:	e822                	sd	s0,16(sp)
    80001956:	e426                	sd	s1,8(sp)
    80001958:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    8000195a:	fffff097          	auipc	ra,0xfffff
    8000195e:	1d8080e7          	jalr	472(ra) # 80000b32 <kalloc>
  if(pagetable == 0)
    80001962:	cd11                	beqz	a0,8000197e <uvmcreate+0x2e>
    80001964:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001966:	6605                	lui	a2,0x1
    80001968:	4581                	li	a1,0
    8000196a:	fffff097          	auipc	ra,0xfffff
    8000196e:	7c4080e7          	jalr	1988(ra) # 8000112e <memset>
}
    80001972:	8526                	mv	a0,s1
    80001974:	60e2                	ld	ra,24(sp)
    80001976:	6442                	ld	s0,16(sp)
    80001978:	64a2                	ld	s1,8(sp)
    8000197a:	6105                	addi	sp,sp,32
    8000197c:	8082                	ret
    panic("uvmcreate: out of memory");
    8000197e:	00007517          	auipc	a0,0x7
    80001982:	b6250513          	addi	a0,a0,-1182 # 800084e0 <userret+0x450>
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	dfe080e7          	jalr	-514(ra) # 80000784 <panic>

000000008000198e <uvminit>:
{
    8000198e:	7179                	addi	sp,sp,-48
    80001990:	f406                	sd	ra,40(sp)
    80001992:	f022                	sd	s0,32(sp)
    80001994:	ec26                	sd	s1,24(sp)
    80001996:	e84a                	sd	s2,16(sp)
    80001998:	e44e                	sd	s3,8(sp)
    8000199a:	e052                	sd	s4,0(sp)
    8000199c:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    8000199e:	6785                	lui	a5,0x1
    800019a0:	04f67863          	bleu	a5,a2,800019f0 <uvminit+0x62>
    800019a4:	8a2a                	mv	s4,a0
    800019a6:	89ae                	mv	s3,a1
    800019a8:	84b2                	mv	s1,a2
  mem = kalloc();
    800019aa:	fffff097          	auipc	ra,0xfffff
    800019ae:	188080e7          	jalr	392(ra) # 80000b32 <kalloc>
    800019b2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800019b4:	6605                	lui	a2,0x1
    800019b6:	4581                	li	a1,0
    800019b8:	fffff097          	auipc	ra,0xfffff
    800019bc:	776080e7          	jalr	1910(ra) # 8000112e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800019c0:	4779                	li	a4,30
    800019c2:	86ca                	mv	a3,s2
    800019c4:	6605                	lui	a2,0x1
    800019c6:	4581                	li	a1,0
    800019c8:	8552                	mv	a0,s4
    800019ca:	00000097          	auipc	ra,0x0
    800019ce:	d14080e7          	jalr	-748(ra) # 800016de <mappages>
  memmove(mem, src, sz);
    800019d2:	8626                	mv	a2,s1
    800019d4:	85ce                	mv	a1,s3
    800019d6:	854a                	mv	a0,s2
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	7c2080e7          	jalr	1986(ra) # 8000119a <memmove>
}
    800019e0:	70a2                	ld	ra,40(sp)
    800019e2:	7402                	ld	s0,32(sp)
    800019e4:	64e2                	ld	s1,24(sp)
    800019e6:	6942                	ld	s2,16(sp)
    800019e8:	69a2                	ld	s3,8(sp)
    800019ea:	6a02                	ld	s4,0(sp)
    800019ec:	6145                	addi	sp,sp,48
    800019ee:	8082                	ret
    panic("inituvm: more than a page");
    800019f0:	00007517          	auipc	a0,0x7
    800019f4:	b1050513          	addi	a0,a0,-1264 # 80008500 <userret+0x470>
    800019f8:	fffff097          	auipc	ra,0xfffff
    800019fc:	d8c080e7          	jalr	-628(ra) # 80000784 <panic>

0000000080001a00 <uvmdealloc>:
{
    80001a00:	1101                	addi	sp,sp,-32
    80001a02:	ec06                	sd	ra,24(sp)
    80001a04:	e822                	sd	s0,16(sp)
    80001a06:	e426                	sd	s1,8(sp)
    80001a08:	1000                	addi	s0,sp,32
    return oldsz;
    80001a0a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001a0c:	00b67d63          	bleu	a1,a2,80001a26 <uvmdealloc+0x26>
    80001a10:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    80001a12:	6785                	lui	a5,0x1
    80001a14:	17fd                	addi	a5,a5,-1
    80001a16:	00f60733          	add	a4,a2,a5
    80001a1a:	76fd                	lui	a3,0xfffff
    80001a1c:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001a1e:	97ae                	add	a5,a5,a1
    80001a20:	8ff5                	and	a5,a5,a3
    80001a22:	00f76863          	bltu	a4,a5,80001a32 <uvmdealloc+0x32>
}
    80001a26:	8526                	mv	a0,s1
    80001a28:	60e2                	ld	ra,24(sp)
    80001a2a:	6442                	ld	s0,16(sp)
    80001a2c:	64a2                	ld	s1,8(sp)
    80001a2e:	6105                	addi	sp,sp,32
    80001a30:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    80001a32:	4685                	li	a3,1
    80001a34:	40e58633          	sub	a2,a1,a4
    80001a38:	85ba                	mv	a1,a4
    80001a3a:	00000097          	auipc	ra,0x0
    80001a3e:	e50080e7          	jalr	-432(ra) # 8000188a <uvmunmap>
    80001a42:	b7d5                	j	80001a26 <uvmdealloc+0x26>

0000000080001a44 <uvmalloc>:
  if(newsz < oldsz)
    80001a44:	0ab66163          	bltu	a2,a1,80001ae6 <uvmalloc+0xa2>
{
    80001a48:	7139                	addi	sp,sp,-64
    80001a4a:	fc06                	sd	ra,56(sp)
    80001a4c:	f822                	sd	s0,48(sp)
    80001a4e:	f426                	sd	s1,40(sp)
    80001a50:	f04a                	sd	s2,32(sp)
    80001a52:	ec4e                	sd	s3,24(sp)
    80001a54:	e852                	sd	s4,16(sp)
    80001a56:	e456                	sd	s5,8(sp)
    80001a58:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    80001a5a:	6a05                	lui	s4,0x1
    80001a5c:	1a7d                	addi	s4,s4,-1
    80001a5e:	95d2                	add	a1,a1,s4
    80001a60:	7a7d                	lui	s4,0xfffff
    80001a62:	0145fa33          	and	s4,a1,s4
  for(; a < newsz; a += PGSIZE){
    80001a66:	08ca7263          	bleu	a2,s4,80001aea <uvmalloc+0xa6>
    80001a6a:	89b2                	mv	s3,a2
    80001a6c:	8aaa                	mv	s5,a0
  a = oldsz;
    80001a6e:	8952                	mv	s2,s4
    mem = kalloc();
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	0c2080e7          	jalr	194(ra) # 80000b32 <kalloc>
    80001a78:	84aa                	mv	s1,a0
    if(mem == 0){
    80001a7a:	c51d                	beqz	a0,80001aa8 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001a7c:	6605                	lui	a2,0x1
    80001a7e:	4581                	li	a1,0
    80001a80:	fffff097          	auipc	ra,0xfffff
    80001a84:	6ae080e7          	jalr	1710(ra) # 8000112e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001a88:	4779                	li	a4,30
    80001a8a:	86a6                	mv	a3,s1
    80001a8c:	6605                	lui	a2,0x1
    80001a8e:	85ca                	mv	a1,s2
    80001a90:	8556                	mv	a0,s5
    80001a92:	00000097          	auipc	ra,0x0
    80001a96:	c4c080e7          	jalr	-948(ra) # 800016de <mappages>
    80001a9a:	e905                	bnez	a0,80001aca <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    80001a9c:	6785                	lui	a5,0x1
    80001a9e:	993e                	add	s2,s2,a5
    80001aa0:	fd3968e3          	bltu	s2,s3,80001a70 <uvmalloc+0x2c>
  return newsz;
    80001aa4:	854e                	mv	a0,s3
    80001aa6:	a809                	j	80001ab8 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001aa8:	8652                	mv	a2,s4
    80001aaa:	85ca                	mv	a1,s2
    80001aac:	8556                	mv	a0,s5
    80001aae:	00000097          	auipc	ra,0x0
    80001ab2:	f52080e7          	jalr	-174(ra) # 80001a00 <uvmdealloc>
      return 0;
    80001ab6:	4501                	li	a0,0
}
    80001ab8:	70e2                	ld	ra,56(sp)
    80001aba:	7442                	ld	s0,48(sp)
    80001abc:	74a2                	ld	s1,40(sp)
    80001abe:	7902                	ld	s2,32(sp)
    80001ac0:	69e2                	ld	s3,24(sp)
    80001ac2:	6a42                	ld	s4,16(sp)
    80001ac4:	6aa2                	ld	s5,8(sp)
    80001ac6:	6121                	addi	sp,sp,64
    80001ac8:	8082                	ret
      kfree(mem);
    80001aca:	8526                	mv	a0,s1
    80001acc:	fffff097          	auipc	ra,0xfffff
    80001ad0:	04e080e7          	jalr	78(ra) # 80000b1a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001ad4:	8652                	mv	a2,s4
    80001ad6:	85ca                	mv	a1,s2
    80001ad8:	8556                	mv	a0,s5
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	f26080e7          	jalr	-218(ra) # 80001a00 <uvmdealloc>
      return 0;
    80001ae2:	4501                	li	a0,0
    80001ae4:	bfd1                	j	80001ab8 <uvmalloc+0x74>
    return oldsz;
    80001ae6:	852e                	mv	a0,a1
}
    80001ae8:	8082                	ret
  return newsz;
    80001aea:	8532                	mv	a0,a2
    80001aec:	b7f1                	j	80001ab8 <uvmalloc+0x74>

0000000080001aee <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001aee:	1101                	addi	sp,sp,-32
    80001af0:	ec06                	sd	ra,24(sp)
    80001af2:	e822                	sd	s0,16(sp)
    80001af4:	e426                	sd	s1,8(sp)
    80001af6:	1000                	addi	s0,sp,32
    80001af8:	84aa                	mv	s1,a0
  uvmunmap(pagetable, 0, sz, 1);
    80001afa:	4685                	li	a3,1
    80001afc:	862e                	mv	a2,a1
    80001afe:	4581                	li	a1,0
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	d8a080e7          	jalr	-630(ra) # 8000188a <uvmunmap>
  freewalk(pagetable);
    80001b08:	8526                	mv	a0,s1
    80001b0a:	00000097          	auipc	ra,0x0
    80001b0e:	aa0080e7          	jalr	-1376(ra) # 800015aa <freewalk>
}
    80001b12:	60e2                	ld	ra,24(sp)
    80001b14:	6442                	ld	s0,16(sp)
    80001b16:	64a2                	ld	s1,8(sp)
    80001b18:	6105                	addi	sp,sp,32
    80001b1a:	8082                	ret

0000000080001b1c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001b1c:	c671                	beqz	a2,80001be8 <uvmcopy+0xcc>
{
    80001b1e:	715d                	addi	sp,sp,-80
    80001b20:	e486                	sd	ra,72(sp)
    80001b22:	e0a2                	sd	s0,64(sp)
    80001b24:	fc26                	sd	s1,56(sp)
    80001b26:	f84a                	sd	s2,48(sp)
    80001b28:	f44e                	sd	s3,40(sp)
    80001b2a:	f052                	sd	s4,32(sp)
    80001b2c:	ec56                	sd	s5,24(sp)
    80001b2e:	e85a                	sd	s6,16(sp)
    80001b30:	e45e                	sd	s7,8(sp)
    80001b32:	0880                	addi	s0,sp,80
    80001b34:	8ab2                	mv	s5,a2
    80001b36:	8b2e                	mv	s6,a1
    80001b38:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    80001b3a:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    80001b3c:	4601                	li	a2,0
    80001b3e:	85ca                	mv	a1,s2
    80001b40:	855e                	mv	a0,s7
    80001b42:	00000097          	auipc	ra,0x0
    80001b46:	9c2080e7          	jalr	-1598(ra) # 80001504 <walk>
    80001b4a:	c531                	beqz	a0,80001b96 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001b4c:	6118                	ld	a4,0(a0)
    80001b4e:	00177793          	andi	a5,a4,1
    80001b52:	cbb1                	beqz	a5,80001ba6 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001b54:	00a75593          	srli	a1,a4,0xa
    80001b58:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001b5c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001b60:	fffff097          	auipc	ra,0xfffff
    80001b64:	fd2080e7          	jalr	-46(ra) # 80000b32 <kalloc>
    80001b68:	8a2a                	mv	s4,a0
    80001b6a:	c939                	beqz	a0,80001bc0 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001b6c:	6605                	lui	a2,0x1
    80001b6e:	85ce                	mv	a1,s3
    80001b70:	fffff097          	auipc	ra,0xfffff
    80001b74:	62a080e7          	jalr	1578(ra) # 8000119a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001b78:	8726                	mv	a4,s1
    80001b7a:	86d2                	mv	a3,s4
    80001b7c:	6605                	lui	a2,0x1
    80001b7e:	85ca                	mv	a1,s2
    80001b80:	855a                	mv	a0,s6
    80001b82:	00000097          	auipc	ra,0x0
    80001b86:	b5c080e7          	jalr	-1188(ra) # 800016de <mappages>
    80001b8a:	e515                	bnez	a0,80001bb6 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001b8c:	6785                	lui	a5,0x1
    80001b8e:	993e                	add	s2,s2,a5
    80001b90:	fb5966e3          	bltu	s2,s5,80001b3c <uvmcopy+0x20>
    80001b94:	a83d                	j	80001bd2 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    80001b96:	00007517          	auipc	a0,0x7
    80001b9a:	98a50513          	addi	a0,a0,-1654 # 80008520 <userret+0x490>
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	be6080e7          	jalr	-1050(ra) # 80000784 <panic>
      panic("uvmcopy: page not present");
    80001ba6:	00007517          	auipc	a0,0x7
    80001baa:	99a50513          	addi	a0,a0,-1638 # 80008540 <userret+0x4b0>
    80001bae:	fffff097          	auipc	ra,0xfffff
    80001bb2:	bd6080e7          	jalr	-1066(ra) # 80000784 <panic>
      kfree(mem);
    80001bb6:	8552                	mv	a0,s4
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	f62080e7          	jalr	-158(ra) # 80000b1a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    80001bc0:	4685                	li	a3,1
    80001bc2:	864a                	mv	a2,s2
    80001bc4:	4581                	li	a1,0
    80001bc6:	855a                	mv	a0,s6
    80001bc8:	00000097          	auipc	ra,0x0
    80001bcc:	cc2080e7          	jalr	-830(ra) # 8000188a <uvmunmap>
  return -1;
    80001bd0:	557d                	li	a0,-1
}
    80001bd2:	60a6                	ld	ra,72(sp)
    80001bd4:	6406                	ld	s0,64(sp)
    80001bd6:	74e2                	ld	s1,56(sp)
    80001bd8:	7942                	ld	s2,48(sp)
    80001bda:	79a2                	ld	s3,40(sp)
    80001bdc:	7a02                	ld	s4,32(sp)
    80001bde:	6ae2                	ld	s5,24(sp)
    80001be0:	6b42                	ld	s6,16(sp)
    80001be2:	6ba2                	ld	s7,8(sp)
    80001be4:	6161                	addi	sp,sp,80
    80001be6:	8082                	ret
  return 0;
    80001be8:	4501                	li	a0,0
}
    80001bea:	8082                	ret

0000000080001bec <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001bec:	1141                	addi	sp,sp,-16
    80001bee:	e406                	sd	ra,8(sp)
    80001bf0:	e022                	sd	s0,0(sp)
    80001bf2:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001bf4:	4601                	li	a2,0
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	90e080e7          	jalr	-1778(ra) # 80001504 <walk>
  if(pte == 0)
    80001bfe:	c901                	beqz	a0,80001c0e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001c00:	611c                	ld	a5,0(a0)
    80001c02:	9bbd                	andi	a5,a5,-17
    80001c04:	e11c                	sd	a5,0(a0)
}
    80001c06:	60a2                	ld	ra,8(sp)
    80001c08:	6402                	ld	s0,0(sp)
    80001c0a:	0141                	addi	sp,sp,16
    80001c0c:	8082                	ret
    panic("uvmclear");
    80001c0e:	00007517          	auipc	a0,0x7
    80001c12:	95250513          	addi	a0,a0,-1710 # 80008560 <userret+0x4d0>
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	b6e080e7          	jalr	-1170(ra) # 80000784 <panic>

0000000080001c1e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001c1e:	c6bd                	beqz	a3,80001c8c <copyout+0x6e>
{
    80001c20:	715d                	addi	sp,sp,-80
    80001c22:	e486                	sd	ra,72(sp)
    80001c24:	e0a2                	sd	s0,64(sp)
    80001c26:	fc26                	sd	s1,56(sp)
    80001c28:	f84a                	sd	s2,48(sp)
    80001c2a:	f44e                	sd	s3,40(sp)
    80001c2c:	f052                	sd	s4,32(sp)
    80001c2e:	ec56                	sd	s5,24(sp)
    80001c30:	e85a                	sd	s6,16(sp)
    80001c32:	e45e                	sd	s7,8(sp)
    80001c34:	e062                	sd	s8,0(sp)
    80001c36:	0880                	addi	s0,sp,80
    80001c38:	8baa                	mv	s7,a0
    80001c3a:	8a2e                	mv	s4,a1
    80001c3c:	8ab2                	mv	s5,a2
    80001c3e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001c40:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001c42:	6b05                	lui	s6,0x1
    80001c44:	a015                	j	80001c68 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001c46:	9552                	add	a0,a0,s4
    80001c48:	0004861b          	sext.w	a2,s1
    80001c4c:	85d6                	mv	a1,s5
    80001c4e:	41250533          	sub	a0,a0,s2
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	548080e7          	jalr	1352(ra) # 8000119a <memmove>

    len -= n;
    80001c5a:	409989b3          	sub	s3,s3,s1
    src += n;
    80001c5e:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    80001c60:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80001c64:	02098263          	beqz	s3,80001c88 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001c68:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001c6c:	85ca                	mv	a1,s2
    80001c6e:	855e                	mv	a0,s7
    80001c70:	00000097          	auipc	ra,0x0
    80001c74:	9ca080e7          	jalr	-1590(ra) # 8000163a <walkaddr>
    if(pa0 == 0)
    80001c78:	cd01                	beqz	a0,80001c90 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001c7a:	414904b3          	sub	s1,s2,s4
    80001c7e:	94da                	add	s1,s1,s6
    if(n > len)
    80001c80:	fc99f3e3          	bleu	s1,s3,80001c46 <copyout+0x28>
    80001c84:	84ce                	mv	s1,s3
    80001c86:	b7c1                	j	80001c46 <copyout+0x28>
  }
  return 0;
    80001c88:	4501                	li	a0,0
    80001c8a:	a021                	j	80001c92 <copyout+0x74>
    80001c8c:	4501                	li	a0,0
}
    80001c8e:	8082                	ret
      return -1;
    80001c90:	557d                	li	a0,-1
}
    80001c92:	60a6                	ld	ra,72(sp)
    80001c94:	6406                	ld	s0,64(sp)
    80001c96:	74e2                	ld	s1,56(sp)
    80001c98:	7942                	ld	s2,48(sp)
    80001c9a:	79a2                	ld	s3,40(sp)
    80001c9c:	7a02                	ld	s4,32(sp)
    80001c9e:	6ae2                	ld	s5,24(sp)
    80001ca0:	6b42                	ld	s6,16(sp)
    80001ca2:	6ba2                	ld	s7,8(sp)
    80001ca4:	6c02                	ld	s8,0(sp)
    80001ca6:	6161                	addi	sp,sp,80
    80001ca8:	8082                	ret

0000000080001caa <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001caa:	caa5                	beqz	a3,80001d1a <copyin+0x70>
{
    80001cac:	715d                	addi	sp,sp,-80
    80001cae:	e486                	sd	ra,72(sp)
    80001cb0:	e0a2                	sd	s0,64(sp)
    80001cb2:	fc26                	sd	s1,56(sp)
    80001cb4:	f84a                	sd	s2,48(sp)
    80001cb6:	f44e                	sd	s3,40(sp)
    80001cb8:	f052                	sd	s4,32(sp)
    80001cba:	ec56                	sd	s5,24(sp)
    80001cbc:	e85a                	sd	s6,16(sp)
    80001cbe:	e45e                	sd	s7,8(sp)
    80001cc0:	e062                	sd	s8,0(sp)
    80001cc2:	0880                	addi	s0,sp,80
    80001cc4:	8baa                	mv	s7,a0
    80001cc6:	8aae                	mv	s5,a1
    80001cc8:	8a32                	mv	s4,a2
    80001cca:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001ccc:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001cce:	6b05                	lui	s6,0x1
    80001cd0:	a01d                	j	80001cf6 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001cd2:	014505b3          	add	a1,a0,s4
    80001cd6:	0004861b          	sext.w	a2,s1
    80001cda:	412585b3          	sub	a1,a1,s2
    80001cde:	8556                	mv	a0,s5
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	4ba080e7          	jalr	1210(ra) # 8000119a <memmove>

    len -= n;
    80001ce8:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001cec:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001cee:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80001cf2:	02098263          	beqz	s3,80001d16 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001cf6:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001cfa:	85ca                	mv	a1,s2
    80001cfc:	855e                	mv	a0,s7
    80001cfe:	00000097          	auipc	ra,0x0
    80001d02:	93c080e7          	jalr	-1732(ra) # 8000163a <walkaddr>
    if(pa0 == 0)
    80001d06:	cd01                	beqz	a0,80001d1e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001d08:	414904b3          	sub	s1,s2,s4
    80001d0c:	94da                	add	s1,s1,s6
    if(n > len)
    80001d0e:	fc99f2e3          	bleu	s1,s3,80001cd2 <copyin+0x28>
    80001d12:	84ce                	mv	s1,s3
    80001d14:	bf7d                	j	80001cd2 <copyin+0x28>
  }
  return 0;
    80001d16:	4501                	li	a0,0
    80001d18:	a021                	j	80001d20 <copyin+0x76>
    80001d1a:	4501                	li	a0,0
}
    80001d1c:	8082                	ret
      return -1;
    80001d1e:	557d                	li	a0,-1
}
    80001d20:	60a6                	ld	ra,72(sp)
    80001d22:	6406                	ld	s0,64(sp)
    80001d24:	74e2                	ld	s1,56(sp)
    80001d26:	7942                	ld	s2,48(sp)
    80001d28:	79a2                	ld	s3,40(sp)
    80001d2a:	7a02                	ld	s4,32(sp)
    80001d2c:	6ae2                	ld	s5,24(sp)
    80001d2e:	6b42                	ld	s6,16(sp)
    80001d30:	6ba2                	ld	s7,8(sp)
    80001d32:	6c02                	ld	s8,0(sp)
    80001d34:	6161                	addi	sp,sp,80
    80001d36:	8082                	ret

0000000080001d38 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001d38:	ced5                	beqz	a3,80001df4 <copyinstr+0xbc>
{
    80001d3a:	715d                	addi	sp,sp,-80
    80001d3c:	e486                	sd	ra,72(sp)
    80001d3e:	e0a2                	sd	s0,64(sp)
    80001d40:	fc26                	sd	s1,56(sp)
    80001d42:	f84a                	sd	s2,48(sp)
    80001d44:	f44e                	sd	s3,40(sp)
    80001d46:	f052                	sd	s4,32(sp)
    80001d48:	ec56                	sd	s5,24(sp)
    80001d4a:	e85a                	sd	s6,16(sp)
    80001d4c:	e45e                	sd	s7,8(sp)
    80001d4e:	e062                	sd	s8,0(sp)
    80001d50:	0880                	addi	s0,sp,80
    80001d52:	8aaa                	mv	s5,a0
    80001d54:	84ae                	mv	s1,a1
    80001d56:	8c32                	mv	s8,a2
    80001d58:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    80001d5a:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001d5c:	6985                	lui	s3,0x1
    80001d5e:	4b05                	li	s6,1
    80001d60:	a801                	j	80001d70 <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    80001d62:	87a6                	mv	a5,s1
    80001d64:	a085                	j	80001dc4 <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    80001d66:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    80001d68:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    80001d6c:	080b8063          	beqz	s7,80001dec <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    80001d70:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    80001d74:	85ca                	mv	a1,s2
    80001d76:	8556                	mv	a0,s5
    80001d78:	00000097          	auipc	ra,0x0
    80001d7c:	8c2080e7          	jalr	-1854(ra) # 8000163a <walkaddr>
    if(pa0 == 0)
    80001d80:	c925                	beqz	a0,80001df0 <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    80001d82:	41890633          	sub	a2,s2,s8
    80001d86:	964e                	add	a2,a2,s3
    if(n > max)
    80001d88:	00cbf363          	bleu	a2,s7,80001d8e <copyinstr+0x56>
    80001d8c:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    80001d8e:	9562                	add	a0,a0,s8
    80001d90:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001d94:	da71                	beqz	a2,80001d68 <copyinstr+0x30>
      if(*p == '\0'){
    80001d96:	00054703          	lbu	a4,0(a0)
    80001d9a:	d761                	beqz	a4,80001d62 <copyinstr+0x2a>
    80001d9c:	9626                	add	a2,a2,s1
    80001d9e:	87a6                	mv	a5,s1
    80001da0:	1bfd                	addi	s7,s7,-1
    80001da2:	009b86b3          	add	a3,s7,s1
    80001da6:	409b04b3          	sub	s1,s6,s1
    80001daa:	94aa                	add	s1,s1,a0
        *dst = *p;
    80001dac:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    80001db0:	40f68bb3          	sub	s7,a3,a5
      p++;
    80001db4:	00f48733          	add	a4,s1,a5
      dst++;
    80001db8:	0785                	addi	a5,a5,1
    while(n > 0){
    80001dba:	faf606e3          	beq	a2,a5,80001d66 <copyinstr+0x2e>
      if(*p == '\0'){
    80001dbe:	00074703          	lbu	a4,0(a4)
    80001dc2:	f76d                	bnez	a4,80001dac <copyinstr+0x74>
        *dst = '\0';
    80001dc4:	00078023          	sb	zero,0(a5)
    80001dc8:	4785                	li	a5,1
  }
  if(got_null){
    80001dca:	0017b513          	seqz	a0,a5
    80001dce:	40a0053b          	negw	a0,a0
    80001dd2:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    80001dd4:	60a6                	ld	ra,72(sp)
    80001dd6:	6406                	ld	s0,64(sp)
    80001dd8:	74e2                	ld	s1,56(sp)
    80001dda:	7942                	ld	s2,48(sp)
    80001ddc:	79a2                	ld	s3,40(sp)
    80001dde:	7a02                	ld	s4,32(sp)
    80001de0:	6ae2                	ld	s5,24(sp)
    80001de2:	6b42                	ld	s6,16(sp)
    80001de4:	6ba2                	ld	s7,8(sp)
    80001de6:	6c02                	ld	s8,0(sp)
    80001de8:	6161                	addi	sp,sp,80
    80001dea:	8082                	ret
    80001dec:	4781                	li	a5,0
    80001dee:	bff1                	j	80001dca <copyinstr+0x92>
      return -1;
    80001df0:	557d                	li	a0,-1
    80001df2:	b7cd                	j	80001dd4 <copyinstr+0x9c>
  int got_null = 0;
    80001df4:	4781                	li	a5,0
  if(got_null){
    80001df6:	0017b513          	seqz	a0,a5
    80001dfa:	40a0053b          	negw	a0,a0
    80001dfe:	2501                	sext.w	a0,a0
}
    80001e00:	8082                	ret

0000000080001e02 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001e02:	1101                	addi	sp,sp,-32
    80001e04:	ec06                	sd	ra,24(sp)
    80001e06:	e822                	sd	s0,16(sp)
    80001e08:	e426                	sd	s1,8(sp)
    80001e0a:	1000                	addi	s0,sp,32
    80001e0c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	e2e080e7          	jalr	-466(ra) # 80000c3c <holding>
    80001e16:	c909                	beqz	a0,80001e28 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001e18:	60bc                	ld	a5,64(s1)
    80001e1a:	00978f63          	beq	a5,s1,80001e38 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001e1e:	60e2                	ld	ra,24(sp)
    80001e20:	6442                	ld	s0,16(sp)
    80001e22:	64a2                	ld	s1,8(sp)
    80001e24:	6105                	addi	sp,sp,32
    80001e26:	8082                	ret
    panic("wakeup1");
    80001e28:	00006517          	auipc	a0,0x6
    80001e2c:	74850513          	addi	a0,a0,1864 # 80008570 <userret+0x4e0>
    80001e30:	fffff097          	auipc	ra,0xfffff
    80001e34:	954080e7          	jalr	-1708(ra) # 80000784 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001e38:	5898                	lw	a4,48(s1)
    80001e3a:	4785                	li	a5,1
    80001e3c:	fef711e3          	bne	a4,a5,80001e1e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001e40:	4789                	li	a5,2
    80001e42:	d89c                	sw	a5,48(s1)
}
    80001e44:	bfe9                	j	80001e1e <wakeup1+0x1c>

0000000080001e46 <insert_into_prio_queue>:
void insert_into_prio_queue(struct proc* p){
    80001e46:	1101                	addi	sp,sp,-32
    80001e48:	ec06                	sd	ra,24(sp)
    80001e4a:	e822                	sd	s0,16(sp)
    80001e4c:	e426                	sd	s1,8(sp)
    80001e4e:	1000                	addi	s0,sp,32
    80001e50:	84aa                	mv	s1,a0
  struct list_proc* new = bd_malloc(sizeof(struct list_proc));
    80001e52:	4541                	li	a0,16
    80001e54:	00005097          	auipc	ra,0x5
    80001e58:	274080e7          	jalr	628(ra) # 800070c8 <bd_malloc>
  new->next = 0;
    80001e5c:	00053423          	sd	zero,8(a0)
  new->p = p;
    80001e60:	e104                	sd	s1,0(a0)
  if(!prio[p->priority]){
    80001e62:	48f8                	lw	a4,84(s1)
    80001e64:	00371693          	slli	a3,a4,0x3
    80001e68:	00014797          	auipc	a5,0x14
    80001e6c:	b8078793          	addi	a5,a5,-1152 # 800159e8 <prio>
    80001e70:	97b6                	add	a5,a5,a3
    80001e72:	639c                	ld	a5,0(a5)
    80001e74:	c789                	beqz	a5,80001e7e <insert_into_prio_queue+0x38>
    while(last && last->next){
    80001e76:	6798                	ld	a4,8(a5)
    80001e78:	ef01                	bnez	a4,80001e90 <insert_into_prio_queue+0x4a>
    struct list_proc* last = prio[p->priority];
    80001e7a:	873e                	mv	a4,a5
    80001e7c:	a821                	j	80001e94 <insert_into_prio_queue+0x4e>
    prio[p->priority] = new;
    80001e7e:	00014797          	auipc	a5,0x14
    80001e82:	b6a78793          	addi	a5,a5,-1174 # 800159e8 <prio>
    80001e86:	00d78733          	add	a4,a5,a3
    80001e8a:	e308                	sd	a0,0(a4)
    80001e8c:	a029                	j	80001e96 <insert_into_prio_queue+0x50>
    while(last && last->next){
    80001e8e:	873e                	mv	a4,a5
    80001e90:	671c                	ld	a5,8(a4)
    80001e92:	fff5                	bnez	a5,80001e8e <insert_into_prio_queue+0x48>
    last->next = new;
    80001e94:	e708                	sd	a0,8(a4)
}
    80001e96:	60e2                	ld	ra,24(sp)
    80001e98:	6442                	ld	s0,16(sp)
    80001e9a:	64a2                	ld	s1,8(sp)
    80001e9c:	6105                	addi	sp,sp,32
    80001e9e:	8082                	ret

0000000080001ea0 <remove_from_prio_queue>:
void remove_from_prio_queue(struct proc* p){
    80001ea0:	1101                	addi	sp,sp,-32
    80001ea2:	ec06                	sd	ra,24(sp)
    80001ea4:	e822                	sd	s0,16(sp)
    80001ea6:	e426                	sd	s1,8(sp)
    80001ea8:	e04a                	sd	s2,0(sp)
    80001eaa:	1000                	addi	s0,sp,32
    80001eac:	84aa                	mv	s1,a0
  struct list_proc* old = prio[p->priority];
    80001eae:	497c                	lw	a5,84(a0)
    80001eb0:	00379713          	slli	a4,a5,0x3
    80001eb4:	00014797          	auipc	a5,0x14
    80001eb8:	b3478793          	addi	a5,a5,-1228 # 800159e8 <prio>
    80001ebc:	97ba                	add	a5,a5,a4
    80001ebe:	0007b903          	ld	s2,0(a5)
  while(old){
    80001ec2:	02090663          	beqz	s2,80001eee <remove_from_prio_queue+0x4e>
    if(old->p == p) {
    80001ec6:	00093783          	ld	a5,0(s2) # 1000 <_entry-0x7ffff000>
    80001eca:	04f50263          	beq	a0,a5,80001f0e <remove_from_prio_queue+0x6e>
  struct list_proc* old = prio[p->priority];
    80001ece:	87ca                	mv	a5,s2
    old = old->next;
    80001ed0:	6788                	ld	a0,8(a5)
  while(old){
    80001ed2:	cd11                	beqz	a0,80001eee <remove_from_prio_queue+0x4e>
    if(old->p == p) {
    80001ed4:	6118                	ld	a4,0(a0)
    80001ed6:	00970463          	beq	a4,s1,80001ede <remove_from_prio_queue+0x3e>
    old = old->next;
    80001eda:	87aa                	mv	a5,a0
    80001edc:	bfd5                	j	80001ed0 <remove_from_prio_queue+0x30>
      if(old == head){
    80001ede:	02a90963          	beq	s2,a0,80001f10 <remove_from_prio_queue+0x70>
        prev->next = old->next;
    80001ee2:	6518                	ld	a4,8(a0)
    80001ee4:	e798                	sd	a4,8(a5)
      bd_free(old);
    80001ee6:	00005097          	auipc	ra,0x5
    80001eea:	3e6080e7          	jalr	998(ra) # 800072cc <bd_free>
  prio[p->priority] = head;
    80001eee:	48fc                	lw	a5,84(s1)
    80001ef0:	00379713          	slli	a4,a5,0x3
    80001ef4:	00014797          	auipc	a5,0x14
    80001ef8:	af478793          	addi	a5,a5,-1292 # 800159e8 <prio>
    80001efc:	97ba                	add	a5,a5,a4
    80001efe:	0127b023          	sd	s2,0(a5)
}
    80001f02:	60e2                	ld	ra,24(sp)
    80001f04:	6442                	ld	s0,16(sp)
    80001f06:	64a2                	ld	s1,8(sp)
    80001f08:	6902                	ld	s2,0(sp)
    80001f0a:	6105                	addi	sp,sp,32
    80001f0c:	8082                	ret
  struct list_proc* old = prio[p->priority];
    80001f0e:	854a                	mv	a0,s2
        head = old->next;
    80001f10:	00853903          	ld	s2,8(a0)
    80001f14:	bfc9                	j	80001ee6 <remove_from_prio_queue+0x46>

0000000080001f16 <procinit>:
{
    80001f16:	715d                	addi	sp,sp,-80
    80001f18:	e486                	sd	ra,72(sp)
    80001f1a:	e0a2                	sd	s0,64(sp)
    80001f1c:	fc26                	sd	s1,56(sp)
    80001f1e:	f84a                	sd	s2,48(sp)
    80001f20:	f44e                	sd	s3,40(sp)
    80001f22:	f052                	sd	s4,32(sp)
    80001f24:	ec56                	sd	s5,24(sp)
    80001f26:	e85a                	sd	s6,16(sp)
    80001f28:	e45e                	sd	s7,8(sp)
    80001f2a:	0880                	addi	s0,sp,80
  initlock(&prio_lock, "priolock");
    80001f2c:	00014497          	auipc	s1,0x14
    80001f30:	b0c48493          	addi	s1,s1,-1268 # 80015a38 <prio_lock>
    80001f34:	00006597          	auipc	a1,0x6
    80001f38:	64458593          	addi	a1,a1,1604 # 80008578 <userret+0x4e8>
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	c0e080e7          	jalr	-1010(ra) # 80000b4c <initlock>
  for(int i = 0; i < NPRIO; i++){
    80001f46:	00014797          	auipc	a5,0x14
    80001f4a:	aa278793          	addi	a5,a5,-1374 # 800159e8 <prio>
    80001f4e:	8526                	mv	a0,s1
    prio[i] = 0;
    80001f50:	0007b023          	sd	zero,0(a5)
    80001f54:	07a1                	addi	a5,a5,8
  for(int i = 0; i < NPRIO; i++){
    80001f56:	fea79de3          	bne	a5,a0,80001f50 <procinit+0x3a>
  initlock(&pid_lock, "nextpid");
    80001f5a:	00006597          	auipc	a1,0x6
    80001f5e:	62e58593          	addi	a1,a1,1582 # 80008588 <userret+0x4f8>
    80001f62:	00014517          	auipc	a0,0x14
    80001f66:	b0650513          	addi	a0,a0,-1274 # 80015a68 <pid_lock>
    80001f6a:	fffff097          	auipc	ra,0xfffff
    80001f6e:	be2080e7          	jalr	-1054(ra) # 80000b4c <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f72:	00014917          	auipc	s2,0x14
    80001f76:	f2690913          	addi	s2,s2,-218 # 80015e98 <proc>
      initlock(&p->lock, "proc");
    80001f7a:	00006b97          	auipc	s7,0x6
    80001f7e:	616b8b93          	addi	s7,s7,1558 # 80008590 <userret+0x500>
      uint64 va = KSTACK((int) (p - proc));
    80001f82:	8b4a                	mv	s6,s2
    80001f84:	00007a97          	auipc	s5,0x7
    80001f88:	19ca8a93          	addi	s5,s5,412 # 80009120 <syscalls+0xd8>
    80001f8c:	040009b7          	lui	s3,0x4000
    80001f90:	19fd                	addi	s3,s3,-1
    80001f92:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f94:	0001aa17          	auipc	s4,0x1a
    80001f98:	104a0a13          	addi	s4,s4,260 # 8001c098 <tickslock>
      initlock(&p->lock, "proc");
    80001f9c:	85de                	mv	a1,s7
    80001f9e:	854a                	mv	a0,s2
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	bac080e7          	jalr	-1108(ra) # 80000b4c <initlock>
      char *pa = kalloc();
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	b8a080e7          	jalr	-1142(ra) # 80000b32 <kalloc>
    80001fb0:	85aa                	mv	a1,a0
      if(pa == 0)
    80001fb2:	c929                	beqz	a0,80002004 <procinit+0xee>
      uint64 va = KSTACK((int) (p - proc));
    80001fb4:	416904b3          	sub	s1,s2,s6
    80001fb8:	848d                	srai	s1,s1,0x3
    80001fba:	000ab783          	ld	a5,0(s5)
    80001fbe:	02f484b3          	mul	s1,s1,a5
    80001fc2:	2485                	addiw	s1,s1,1
    80001fc4:	00d4949b          	slliw	s1,s1,0xd
    80001fc8:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001fcc:	4699                	li	a3,6
    80001fce:	6605                	lui	a2,0x1
    80001fd0:	8526                	mv	a0,s1
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	798080e7          	jalr	1944(ra) # 8000176a <kvmmap>
      p->kstack = va;
    80001fda:	04993c23          	sd	s1,88(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fde:	18890913          	addi	s2,s2,392
    80001fe2:	fb491de3          	bne	s2,s4,80001f9c <procinit+0x86>
  kvminithart();
    80001fe6:	fffff097          	auipc	ra,0xfffff
    80001fea:	62e080e7          	jalr	1582(ra) # 80001614 <kvminithart>
}
    80001fee:	60a6                	ld	ra,72(sp)
    80001ff0:	6406                	ld	s0,64(sp)
    80001ff2:	74e2                	ld	s1,56(sp)
    80001ff4:	7942                	ld	s2,48(sp)
    80001ff6:	79a2                	ld	s3,40(sp)
    80001ff8:	7a02                	ld	s4,32(sp)
    80001ffa:	6ae2                	ld	s5,24(sp)
    80001ffc:	6b42                	ld	s6,16(sp)
    80001ffe:	6ba2                	ld	s7,8(sp)
    80002000:	6161                	addi	sp,sp,80
    80002002:	8082                	ret
        panic("kalloc");
    80002004:	00006517          	auipc	a0,0x6
    80002008:	59450513          	addi	a0,a0,1428 # 80008598 <userret+0x508>
    8000200c:	ffffe097          	auipc	ra,0xffffe
    80002010:	778080e7          	jalr	1912(ra) # 80000784 <panic>

0000000080002014 <cpuid>:
{
    80002014:	1141                	addi	sp,sp,-16
    80002016:	e422                	sd	s0,8(sp)
    80002018:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000201a:	8512                	mv	a0,tp
}
    8000201c:	2501                	sext.w	a0,a0
    8000201e:	6422                	ld	s0,8(sp)
    80002020:	0141                	addi	sp,sp,16
    80002022:	8082                	ret

0000000080002024 <mycpu>:
mycpu(void) {
    80002024:	1141                	addi	sp,sp,-16
    80002026:	e422                	sd	s0,8(sp)
    80002028:	0800                	addi	s0,sp,16
    8000202a:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    8000202c:	2781                	sext.w	a5,a5
    8000202e:	079e                	slli	a5,a5,0x7
}
    80002030:	00014517          	auipc	a0,0x14
    80002034:	a6850513          	addi	a0,a0,-1432 # 80015a98 <cpus>
    80002038:	953e                	add	a0,a0,a5
    8000203a:	6422                	ld	s0,8(sp)
    8000203c:	0141                	addi	sp,sp,16
    8000203e:	8082                	ret

0000000080002040 <myproc>:
myproc(void) {
    80002040:	1101                	addi	sp,sp,-32
    80002042:	ec06                	sd	ra,24(sp)
    80002044:	e822                	sd	s0,16(sp)
    80002046:	e426                	sd	s1,8(sp)
    80002048:	1000                	addi	s0,sp,32
  push_off();
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	c20080e7          	jalr	-992(ra) # 80000c6a <push_off>
    80002052:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80002054:	2781                	sext.w	a5,a5
    80002056:	079e                	slli	a5,a5,0x7
    80002058:	00014717          	auipc	a4,0x14
    8000205c:	99070713          	addi	a4,a4,-1648 # 800159e8 <prio>
    80002060:	97ba                	add	a5,a5,a4
    80002062:	7bc4                	ld	s1,176(a5)
  pop_off();
    80002064:	fffff097          	auipc	ra,0xfffff
    80002068:	e42080e7          	jalr	-446(ra) # 80000ea6 <pop_off>
}
    8000206c:	8526                	mv	a0,s1
    8000206e:	60e2                	ld	ra,24(sp)
    80002070:	6442                	ld	s0,16(sp)
    80002072:	64a2                	ld	s1,8(sp)
    80002074:	6105                	addi	sp,sp,32
    80002076:	8082                	ret

0000000080002078 <forkret>:
{
    80002078:	1141                	addi	sp,sp,-16
    8000207a:	e406                	sd	ra,8(sp)
    8000207c:	e022                	sd	s0,0(sp)
    8000207e:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80002080:	00000097          	auipc	ra,0x0
    80002084:	fc0080e7          	jalr	-64(ra) # 80002040 <myproc>
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	e7e080e7          	jalr	-386(ra) # 80000f06 <release>
  if (first) {
    80002090:	00008797          	auipc	a5,0x8
    80002094:	fc878793          	addi	a5,a5,-56 # 8000a058 <first.1818>
    80002098:	439c                	lw	a5,0(a5)
    8000209a:	eb89                	bnez	a5,800020ac <forkret+0x34>
  usertrapret();
    8000209c:	00001097          	auipc	ra,0x1
    800020a0:	e3c080e7          	jalr	-452(ra) # 80002ed8 <usertrapret>
}
    800020a4:	60a2                	ld	ra,8(sp)
    800020a6:	6402                	ld	s0,0(sp)
    800020a8:	0141                	addi	sp,sp,16
    800020aa:	8082                	ret
    first = 0;
    800020ac:	00008797          	auipc	a5,0x8
    800020b0:	fa07a623          	sw	zero,-84(a5) # 8000a058 <first.1818>
    fsinit(minor(ROOTDEV));
    800020b4:	4501                	li	a0,0
    800020b6:	00002097          	auipc	ra,0x2
    800020ba:	c34080e7          	jalr	-972(ra) # 80003cea <fsinit>
    800020be:	bff9                	j	8000209c <forkret+0x24>

00000000800020c0 <allocpid>:
allocpid() {
    800020c0:	1101                	addi	sp,sp,-32
    800020c2:	ec06                	sd	ra,24(sp)
    800020c4:	e822                	sd	s0,16(sp)
    800020c6:	e426                	sd	s1,8(sp)
    800020c8:	e04a                	sd	s2,0(sp)
    800020ca:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800020cc:	00014917          	auipc	s2,0x14
    800020d0:	99c90913          	addi	s2,s2,-1636 # 80015a68 <pid_lock>
    800020d4:	854a                	mv	a0,s2
    800020d6:	fffff097          	auipc	ra,0xfffff
    800020da:	be4080e7          	jalr	-1052(ra) # 80000cba <acquire>
  pid = nextpid;
    800020de:	00008797          	auipc	a5,0x8
    800020e2:	f7e78793          	addi	a5,a5,-130 # 8000a05c <nextpid>
    800020e6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800020e8:	0014871b          	addiw	a4,s1,1
    800020ec:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800020ee:	854a                	mv	a0,s2
    800020f0:	fffff097          	auipc	ra,0xfffff
    800020f4:	e16080e7          	jalr	-490(ra) # 80000f06 <release>
}
    800020f8:	8526                	mv	a0,s1
    800020fa:	60e2                	ld	ra,24(sp)
    800020fc:	6442                	ld	s0,16(sp)
    800020fe:	64a2                	ld	s1,8(sp)
    80002100:	6902                	ld	s2,0(sp)
    80002102:	6105                	addi	sp,sp,32
    80002104:	8082                	ret

0000000080002106 <proc_pagetable>:
{
    80002106:	1101                	addi	sp,sp,-32
    80002108:	ec06                	sd	ra,24(sp)
    8000210a:	e822                	sd	s0,16(sp)
    8000210c:	e426                	sd	s1,8(sp)
    8000210e:	e04a                	sd	s2,0(sp)
    80002110:	1000                	addi	s0,sp,32
    80002112:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80002114:	00000097          	auipc	ra,0x0
    80002118:	83c080e7          	jalr	-1988(ra) # 80001950 <uvmcreate>
    8000211c:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000211e:	4729                	li	a4,10
    80002120:	00006697          	auipc	a3,0x6
    80002124:	ee068693          	addi	a3,a3,-288 # 80008000 <trampoline>
    80002128:	6605                	lui	a2,0x1
    8000212a:	040005b7          	lui	a1,0x4000
    8000212e:	15fd                	addi	a1,a1,-1
    80002130:	05b2                	slli	a1,a1,0xc
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	5ac080e7          	jalr	1452(ra) # 800016de <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    8000213a:	4719                	li	a4,6
    8000213c:	07093683          	ld	a3,112(s2)
    80002140:	6605                	lui	a2,0x1
    80002142:	020005b7          	lui	a1,0x2000
    80002146:	15fd                	addi	a1,a1,-1
    80002148:	05b6                	slli	a1,a1,0xd
    8000214a:	8526                	mv	a0,s1
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	592080e7          	jalr	1426(ra) # 800016de <mappages>
}
    80002154:	8526                	mv	a0,s1
    80002156:	60e2                	ld	ra,24(sp)
    80002158:	6442                	ld	s0,16(sp)
    8000215a:	64a2                	ld	s1,8(sp)
    8000215c:	6902                	ld	s2,0(sp)
    8000215e:	6105                	addi	sp,sp,32
    80002160:	8082                	ret

0000000080002162 <allocproc>:
{
    80002162:	1101                	addi	sp,sp,-32
    80002164:	ec06                	sd	ra,24(sp)
    80002166:	e822                	sd	s0,16(sp)
    80002168:	e426                	sd	s1,8(sp)
    8000216a:	e04a                	sd	s2,0(sp)
    8000216c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000216e:	00014497          	auipc	s1,0x14
    80002172:	d2a48493          	addi	s1,s1,-726 # 80015e98 <proc>
    80002176:	0001a917          	auipc	s2,0x1a
    8000217a:	f2290913          	addi	s2,s2,-222 # 8001c098 <tickslock>
    acquire(&p->lock);
    8000217e:	8526                	mv	a0,s1
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	b3a080e7          	jalr	-1222(ra) # 80000cba <acquire>
    if(p->state == UNUSED) {
    80002188:	589c                	lw	a5,48(s1)
    8000218a:	cf81                	beqz	a5,800021a2 <allocproc+0x40>
      release(&p->lock);
    8000218c:	8526                	mv	a0,s1
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	d78080e7          	jalr	-648(ra) # 80000f06 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002196:	18848493          	addi	s1,s1,392
    8000219a:	ff2492e3          	bne	s1,s2,8000217e <allocproc+0x1c>
  return 0;
    8000219e:	4481                	li	s1,0
    800021a0:	a0b9                	j	800021ee <allocproc+0x8c>
  p->pid = allocpid();
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	f1e080e7          	jalr	-226(ra) # 800020c0 <allocpid>
    800021aa:	c8a8                	sw	a0,80(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	986080e7          	jalr	-1658(ra) # 80000b32 <kalloc>
    800021b4:	892a                	mv	s2,a0
    800021b6:	f8a8                	sd	a0,112(s1)
    800021b8:	c131                	beqz	a0,800021fc <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    800021ba:	8526                	mv	a0,s1
    800021bc:	00000097          	auipc	ra,0x0
    800021c0:	f4a080e7          	jalr	-182(ra) # 80002106 <proc_pagetable>
    800021c4:	f4a8                	sd	a0,104(s1)
  p->priority = DEF_PRIO;
    800021c6:	4795                	li	a5,5
    800021c8:	c8fc                	sw	a5,84(s1)
  memset(&p->context, 0, sizeof p->context);
    800021ca:	07000613          	li	a2,112
    800021ce:	4581                	li	a1,0
    800021d0:	07848513          	addi	a0,s1,120
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	f5a080e7          	jalr	-166(ra) # 8000112e <memset>
  p->context.ra = (uint64)forkret;
    800021dc:	00000797          	auipc	a5,0x0
    800021e0:	e9c78793          	addi	a5,a5,-356 # 80002078 <forkret>
    800021e4:	fcbc                	sd	a5,120(s1)
  p->context.sp = p->kstack + PGSIZE;
    800021e6:	6cbc                	ld	a5,88(s1)
    800021e8:	6705                	lui	a4,0x1
    800021ea:	97ba                	add	a5,a5,a4
    800021ec:	e0dc                	sd	a5,128(s1)
}
    800021ee:	8526                	mv	a0,s1
    800021f0:	60e2                	ld	ra,24(sp)
    800021f2:	6442                	ld	s0,16(sp)
    800021f4:	64a2                	ld	s1,8(sp)
    800021f6:	6902                	ld	s2,0(sp)
    800021f8:	6105                	addi	sp,sp,32
    800021fa:	8082                	ret
    release(&p->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	fffff097          	auipc	ra,0xfffff
    80002202:	d08080e7          	jalr	-760(ra) # 80000f06 <release>
    return 0;
    80002206:	84ca                	mv	s1,s2
    80002208:	b7dd                	j	800021ee <allocproc+0x8c>

000000008000220a <proc_freepagetable>:
{
    8000220a:	1101                	addi	sp,sp,-32
    8000220c:	ec06                	sd	ra,24(sp)
    8000220e:	e822                	sd	s0,16(sp)
    80002210:	e426                	sd	s1,8(sp)
    80002212:	e04a                	sd	s2,0(sp)
    80002214:	1000                	addi	s0,sp,32
    80002216:	84aa                	mv	s1,a0
    80002218:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    8000221a:	4681                	li	a3,0
    8000221c:	6605                	lui	a2,0x1
    8000221e:	040005b7          	lui	a1,0x4000
    80002222:	15fd                	addi	a1,a1,-1
    80002224:	05b2                	slli	a1,a1,0xc
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	664080e7          	jalr	1636(ra) # 8000188a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    8000222e:	4681                	li	a3,0
    80002230:	6605                	lui	a2,0x1
    80002232:	020005b7          	lui	a1,0x2000
    80002236:	15fd                	addi	a1,a1,-1
    80002238:	05b6                	slli	a1,a1,0xd
    8000223a:	8526                	mv	a0,s1
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	64e080e7          	jalr	1614(ra) # 8000188a <uvmunmap>
  if(sz > 0)
    80002244:	00091863          	bnez	s2,80002254 <proc_freepagetable+0x4a>
}
    80002248:	60e2                	ld	ra,24(sp)
    8000224a:	6442                	ld	s0,16(sp)
    8000224c:	64a2                	ld	s1,8(sp)
    8000224e:	6902                	ld	s2,0(sp)
    80002250:	6105                	addi	sp,sp,32
    80002252:	8082                	ret
    uvmfree(pagetable, sz);
    80002254:	85ca                	mv	a1,s2
    80002256:	8526                	mv	a0,s1
    80002258:	00000097          	auipc	ra,0x0
    8000225c:	896080e7          	jalr	-1898(ra) # 80001aee <uvmfree>
}
    80002260:	b7e5                	j	80002248 <proc_freepagetable+0x3e>

0000000080002262 <freeproc>:
{
    80002262:	1101                	addi	sp,sp,-32
    80002264:	ec06                	sd	ra,24(sp)
    80002266:	e822                	sd	s0,16(sp)
    80002268:	e426                	sd	s1,8(sp)
    8000226a:	1000                	addi	s0,sp,32
    8000226c:	84aa                	mv	s1,a0
  if(p->tf)
    8000226e:	7928                	ld	a0,112(a0)
    80002270:	c509                	beqz	a0,8000227a <freeproc+0x18>
    kfree((void*)p->tf);
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	8a8080e7          	jalr	-1880(ra) # 80000b1a <kfree>
  p->tf = 0;
    8000227a:	0604b823          	sd	zero,112(s1)
  if(p->pagetable)
    8000227e:	74a8                	ld	a0,104(s1)
    80002280:	c511                	beqz	a0,8000228c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80002282:	70ac                	ld	a1,96(s1)
    80002284:	00000097          	auipc	ra,0x0
    80002288:	f86080e7          	jalr	-122(ra) # 8000220a <proc_freepagetable>
  if(p->cmd)
    8000228c:	1804b503          	ld	a0,384(s1)
    80002290:	c509                	beqz	a0,8000229a <freeproc+0x38>
    bd_free(p->cmd);
    80002292:	00005097          	auipc	ra,0x5
    80002296:	03a080e7          	jalr	58(ra) # 800072cc <bd_free>
  p->cmd = 0;
    8000229a:	1804b023          	sd	zero,384(s1)
  p->priority = 0;
    8000229e:	0404aa23          	sw	zero,84(s1)
  p->pagetable = 0;
    800022a2:	0604b423          	sd	zero,104(s1)
  p->sz = 0;
    800022a6:	0604b023          	sd	zero,96(s1)
  p->pid = 0;
    800022aa:	0404a823          	sw	zero,80(s1)
  p->parent = 0;
    800022ae:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800022b2:	16048823          	sb	zero,368(s1)
  p->chan = 0;
    800022b6:	0404b023          	sd	zero,64(s1)
  p->killed = 0;
    800022ba:	0404a423          	sw	zero,72(s1)
  p->xstate = 0;
    800022be:	0404a623          	sw	zero,76(s1)
  p->state = UNUSED;
    800022c2:	0204a823          	sw	zero,48(s1)
}
    800022c6:	60e2                	ld	ra,24(sp)
    800022c8:	6442                	ld	s0,16(sp)
    800022ca:	64a2                	ld	s1,8(sp)
    800022cc:	6105                	addi	sp,sp,32
    800022ce:	8082                	ret

00000000800022d0 <userinit>:
{
    800022d0:	1101                	addi	sp,sp,-32
    800022d2:	ec06                	sd	ra,24(sp)
    800022d4:	e822                	sd	s0,16(sp)
    800022d6:	e426                	sd	s1,8(sp)
    800022d8:	e04a                	sd	s2,0(sp)
    800022da:	1000                	addi	s0,sp,32
  p = allocproc();
    800022dc:	00000097          	auipc	ra,0x0
    800022e0:	e86080e7          	jalr	-378(ra) # 80002162 <allocproc>
    800022e4:	84aa                	mv	s1,a0
  initproc = p;
    800022e6:	0002c797          	auipc	a5,0x2c
    800022ea:	d8a7bd23          	sd	a0,-614(a5) # 8002e080 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800022ee:	03300613          	li	a2,51
    800022f2:	00008597          	auipc	a1,0x8
    800022f6:	d0e58593          	addi	a1,a1,-754 # 8000a000 <initcode>
    800022fa:	7528                	ld	a0,104(a0)
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	692080e7          	jalr	1682(ra) # 8000198e <uvminit>
  p->sz = PGSIZE;
    80002304:	6785                	lui	a5,0x1
    80002306:	f0bc                	sd	a5,96(s1)
  p->tf->epc = 0;      // user program counter
    80002308:	78b8                	ld	a4,112(s1)
    8000230a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    8000230e:	78b8                	ld	a4,112(s1)
    80002310:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002312:	4641                	li	a2,16
    80002314:	00006597          	auipc	a1,0x6
    80002318:	28c58593          	addi	a1,a1,652 # 800085a0 <userret+0x510>
    8000231c:	17048513          	addi	a0,s1,368
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	f86080e7          	jalr	-122(ra) # 800012a6 <safestrcpy>
  p->cmd = strdup("init");
    80002328:	00006517          	auipc	a0,0x6
    8000232c:	28850513          	addi	a0,a0,648 # 800085b0 <userret+0x520>
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	070080e7          	jalr	112(ra) # 800013a0 <strdup>
    80002338:	18a4b023          	sd	a0,384(s1)
  p->cwd = namei("/");
    8000233c:	00006517          	auipc	a0,0x6
    80002340:	27c50513          	addi	a0,a0,636 # 800085b8 <userret+0x528>
    80002344:	00002097          	auipc	ra,0x2
    80002348:	3b4080e7          	jalr	948(ra) # 800046f8 <namei>
    8000234c:	16a4b423          	sd	a0,360(s1)
  p->state = RUNNABLE;
    80002350:	4789                	li	a5,2
    80002352:	d89c                	sw	a5,48(s1)
  acquire(&prio_lock);
    80002354:	00013917          	auipc	s2,0x13
    80002358:	6e490913          	addi	s2,s2,1764 # 80015a38 <prio_lock>
    8000235c:	854a                	mv	a0,s2
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	95c080e7          	jalr	-1700(ra) # 80000cba <acquire>
  insert_into_prio_queue(p);
    80002366:	8526                	mv	a0,s1
    80002368:	00000097          	auipc	ra,0x0
    8000236c:	ade080e7          	jalr	-1314(ra) # 80001e46 <insert_into_prio_queue>
  release(&p->lock);
    80002370:	8526                	mv	a0,s1
    80002372:	fffff097          	auipc	ra,0xfffff
    80002376:	b94080e7          	jalr	-1132(ra) # 80000f06 <release>
  release(&prio_lock);
    8000237a:	854a                	mv	a0,s2
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	b8a080e7          	jalr	-1142(ra) # 80000f06 <release>
}
    80002384:	60e2                	ld	ra,24(sp)
    80002386:	6442                	ld	s0,16(sp)
    80002388:	64a2                	ld	s1,8(sp)
    8000238a:	6902                	ld	s2,0(sp)
    8000238c:	6105                	addi	sp,sp,32
    8000238e:	8082                	ret

0000000080002390 <growproc>:
{
    80002390:	1101                	addi	sp,sp,-32
    80002392:	ec06                	sd	ra,24(sp)
    80002394:	e822                	sd	s0,16(sp)
    80002396:	e426                	sd	s1,8(sp)
    80002398:	e04a                	sd	s2,0(sp)
    8000239a:	1000                	addi	s0,sp,32
    8000239c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000239e:	00000097          	auipc	ra,0x0
    800023a2:	ca2080e7          	jalr	-862(ra) # 80002040 <myproc>
    800023a6:	892a                	mv	s2,a0
  sz = p->sz;
    800023a8:	712c                	ld	a1,96(a0)
    800023aa:	0005851b          	sext.w	a0,a1
  if(n > 0){
    800023ae:	00904f63          	bgtz	s1,800023cc <growproc+0x3c>
  } else if(n < 0){
    800023b2:	0204cd63          	bltz	s1,800023ec <growproc+0x5c>
  p->sz = sz;
    800023b6:	1502                	slli	a0,a0,0x20
    800023b8:	9101                	srli	a0,a0,0x20
    800023ba:	06a93023          	sd	a0,96(s2)
  return 0;
    800023be:	4501                	li	a0,0
}
    800023c0:	60e2                	ld	ra,24(sp)
    800023c2:	6442                	ld	s0,16(sp)
    800023c4:	64a2                	ld	s1,8(sp)
    800023c6:	6902                	ld	s2,0(sp)
    800023c8:	6105                	addi	sp,sp,32
    800023ca:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800023cc:	00a4863b          	addw	a2,s1,a0
    800023d0:	1602                	slli	a2,a2,0x20
    800023d2:	9201                	srli	a2,a2,0x20
    800023d4:	1582                	slli	a1,a1,0x20
    800023d6:	9181                	srli	a1,a1,0x20
    800023d8:	06893503          	ld	a0,104(s2)
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	668080e7          	jalr	1640(ra) # 80001a44 <uvmalloc>
    800023e4:	2501                	sext.w	a0,a0
    800023e6:	f961                	bnez	a0,800023b6 <growproc+0x26>
      return -1;
    800023e8:	557d                	li	a0,-1
    800023ea:	bfd9                	j	800023c0 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800023ec:	00a4863b          	addw	a2,s1,a0
    800023f0:	1602                	slli	a2,a2,0x20
    800023f2:	9201                	srli	a2,a2,0x20
    800023f4:	1582                	slli	a1,a1,0x20
    800023f6:	9181                	srli	a1,a1,0x20
    800023f8:	06893503          	ld	a0,104(s2)
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	604080e7          	jalr	1540(ra) # 80001a00 <uvmdealloc>
    80002404:	2501                	sext.w	a0,a0
    80002406:	bf45                	j	800023b6 <growproc+0x26>

0000000080002408 <fork>:
{
    80002408:	7179                	addi	sp,sp,-48
    8000240a:	f406                	sd	ra,40(sp)
    8000240c:	f022                	sd	s0,32(sp)
    8000240e:	ec26                	sd	s1,24(sp)
    80002410:	e84a                	sd	s2,16(sp)
    80002412:	e44e                	sd	s3,8(sp)
    80002414:	e052                	sd	s4,0(sp)
    80002416:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002418:	00000097          	auipc	ra,0x0
    8000241c:	c28080e7          	jalr	-984(ra) # 80002040 <myproc>
    80002420:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80002422:	00000097          	auipc	ra,0x0
    80002426:	d40080e7          	jalr	-704(ra) # 80002162 <allocproc>
    8000242a:	10050e63          	beqz	a0,80002546 <fork+0x13e>
    8000242e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002430:	06093603          	ld	a2,96(s2)
    80002434:	752c                	ld	a1,104(a0)
    80002436:	06893503          	ld	a0,104(s2)
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	6e2080e7          	jalr	1762(ra) # 80001b1c <uvmcopy>
    80002442:	04054863          	bltz	a0,80002492 <fork+0x8a>
  np->sz = p->sz;
    80002446:	06093783          	ld	a5,96(s2)
    8000244a:	06f9b023          	sd	a5,96(s3) # 4000060 <_entry-0x7bffffa0>
  np->parent = p;
    8000244e:	0329bc23          	sd	s2,56(s3)
  *(np->tf) = *(p->tf);
    80002452:	07093683          	ld	a3,112(s2)
    80002456:	87b6                	mv	a5,a3
    80002458:	0709b703          	ld	a4,112(s3)
    8000245c:	12068693          	addi	a3,a3,288
    80002460:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002464:	6788                	ld	a0,8(a5)
    80002466:	6b8c                	ld	a1,16(a5)
    80002468:	6f90                	ld	a2,24(a5)
    8000246a:	01073023          	sd	a6,0(a4)
    8000246e:	e708                	sd	a0,8(a4)
    80002470:	eb0c                	sd	a1,16(a4)
    80002472:	ef10                	sd	a2,24(a4)
    80002474:	02078793          	addi	a5,a5,32
    80002478:	02070713          	addi	a4,a4,32
    8000247c:	fed792e3          	bne	a5,a3,80002460 <fork+0x58>
  np->tf->a0 = 0;
    80002480:	0709b783          	ld	a5,112(s3)
    80002484:	0607b823          	sd	zero,112(a5)
    80002488:	0e800493          	li	s1,232
  for(i = 0; i < NOFILE; i++)
    8000248c:	16800a13          	li	s4,360
    80002490:	a03d                	j	800024be <fork+0xb6>
    freeproc(np);
    80002492:	854e                	mv	a0,s3
    80002494:	00000097          	auipc	ra,0x0
    80002498:	dce080e7          	jalr	-562(ra) # 80002262 <freeproc>
    release(&np->lock);
    8000249c:	854e                	mv	a0,s3
    8000249e:	fffff097          	auipc	ra,0xfffff
    800024a2:	a68080e7          	jalr	-1432(ra) # 80000f06 <release>
    return -1;
    800024a6:	597d                	li	s2,-1
    800024a8:	a071                	j	80002534 <fork+0x12c>
      np->ofile[i] = filedup(p->ofile[i]);
    800024aa:	00003097          	auipc	ra,0x3
    800024ae:	9fe080e7          	jalr	-1538(ra) # 80004ea8 <filedup>
    800024b2:	009987b3          	add	a5,s3,s1
    800024b6:	e388                	sd	a0,0(a5)
    800024b8:	04a1                	addi	s1,s1,8
  for(i = 0; i < NOFILE; i++)
    800024ba:	01448763          	beq	s1,s4,800024c8 <fork+0xc0>
    if(p->ofile[i])
    800024be:	009907b3          	add	a5,s2,s1
    800024c2:	6388                	ld	a0,0(a5)
    800024c4:	f17d                	bnez	a0,800024aa <fork+0xa2>
    800024c6:	bfcd                	j	800024b8 <fork+0xb0>
  np->cwd = idup(p->cwd);
    800024c8:	16893503          	ld	a0,360(s2)
    800024cc:	00002097          	auipc	ra,0x2
    800024d0:	a5a080e7          	jalr	-1446(ra) # 80003f26 <idup>
    800024d4:	16a9b423          	sd	a0,360(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800024d8:	4641                	li	a2,16
    800024da:	17090593          	addi	a1,s2,368
    800024de:	17098513          	addi	a0,s3,368
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	dc4080e7          	jalr	-572(ra) # 800012a6 <safestrcpy>
  np->cmd = strdup(p->cmd);
    800024ea:	18093503          	ld	a0,384(s2)
    800024ee:	fffff097          	auipc	ra,0xfffff
    800024f2:	eb2080e7          	jalr	-334(ra) # 800013a0 <strdup>
    800024f6:	18a9b023          	sd	a0,384(s3)
  pid = np->pid;
    800024fa:	0509a903          	lw	s2,80(s3)
  np->state = RUNNABLE;
    800024fe:	4789                	li	a5,2
    80002500:	02f9a823          	sw	a5,48(s3)
  acquire(&prio_lock);
    80002504:	00013497          	auipc	s1,0x13
    80002508:	53448493          	addi	s1,s1,1332 # 80015a38 <prio_lock>
    8000250c:	8526                	mv	a0,s1
    8000250e:	ffffe097          	auipc	ra,0xffffe
    80002512:	7ac080e7          	jalr	1964(ra) # 80000cba <acquire>
  insert_into_prio_queue(np);
    80002516:	854e                	mv	a0,s3
    80002518:	00000097          	auipc	ra,0x0
    8000251c:	92e080e7          	jalr	-1746(ra) # 80001e46 <insert_into_prio_queue>
  release(&prio_lock);
    80002520:	8526                	mv	a0,s1
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	9e4080e7          	jalr	-1564(ra) # 80000f06 <release>
  release(&np->lock);
    8000252a:	854e                	mv	a0,s3
    8000252c:	fffff097          	auipc	ra,0xfffff
    80002530:	9da080e7          	jalr	-1574(ra) # 80000f06 <release>
}
    80002534:	854a                	mv	a0,s2
    80002536:	70a2                	ld	ra,40(sp)
    80002538:	7402                	ld	s0,32(sp)
    8000253a:	64e2                	ld	s1,24(sp)
    8000253c:	6942                	ld	s2,16(sp)
    8000253e:	69a2                	ld	s3,8(sp)
    80002540:	6a02                	ld	s4,0(sp)
    80002542:	6145                	addi	sp,sp,48
    80002544:	8082                	ret
    return -1;
    80002546:	597d                	li	s2,-1
    80002548:	b7f5                	j	80002534 <fork+0x12c>

000000008000254a <reparent>:
{
    8000254a:	7179                	addi	sp,sp,-48
    8000254c:	f406                	sd	ra,40(sp)
    8000254e:	f022                	sd	s0,32(sp)
    80002550:	ec26                	sd	s1,24(sp)
    80002552:	e84a                	sd	s2,16(sp)
    80002554:	e44e                	sd	s3,8(sp)
    80002556:	e052                	sd	s4,0(sp)
    80002558:	1800                	addi	s0,sp,48
    8000255a:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000255c:	00014497          	auipc	s1,0x14
    80002560:	93c48493          	addi	s1,s1,-1732 # 80015e98 <proc>
      pp->parent = initproc;
    80002564:	0002ca17          	auipc	s4,0x2c
    80002568:	b1ca0a13          	addi	s4,s4,-1252 # 8002e080 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000256c:	0001a917          	auipc	s2,0x1a
    80002570:	b2c90913          	addi	s2,s2,-1236 # 8001c098 <tickslock>
    80002574:	a029                	j	8000257e <reparent+0x34>
    80002576:	18848493          	addi	s1,s1,392
    8000257a:	03248363          	beq	s1,s2,800025a0 <reparent+0x56>
    if(pp->parent == p){
    8000257e:	7c9c                	ld	a5,56(s1)
    80002580:	ff379be3          	bne	a5,s3,80002576 <reparent+0x2c>
      acquire(&pp->lock);
    80002584:	8526                	mv	a0,s1
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	734080e7          	jalr	1844(ra) # 80000cba <acquire>
      pp->parent = initproc;
    8000258e:	000a3783          	ld	a5,0(s4)
    80002592:	fc9c                	sd	a5,56(s1)
      release(&pp->lock);
    80002594:	8526                	mv	a0,s1
    80002596:	fffff097          	auipc	ra,0xfffff
    8000259a:	970080e7          	jalr	-1680(ra) # 80000f06 <release>
    8000259e:	bfe1                	j	80002576 <reparent+0x2c>
}
    800025a0:	70a2                	ld	ra,40(sp)
    800025a2:	7402                	ld	s0,32(sp)
    800025a4:	64e2                	ld	s1,24(sp)
    800025a6:	6942                	ld	s2,16(sp)
    800025a8:	69a2                	ld	s3,8(sp)
    800025aa:	6a02                	ld	s4,0(sp)
    800025ac:	6145                	addi	sp,sp,48
    800025ae:	8082                	ret

00000000800025b0 <pick_highest_priority_runnable_proc>:
proc* pick_highest_priority_runnable_proc() {
    800025b0:	1101                	addi	sp,sp,-32
    800025b2:	ec06                	sd	ra,24(sp)
    800025b4:	e822                	sd	s0,16(sp)
    800025b6:	e426                	sd	s1,8(sp)
    800025b8:	1000                	addi	s0,sp,32
  acquire(&prio_lock);
    800025ba:	00013497          	auipc	s1,0x13
    800025be:	47e48493          	addi	s1,s1,1150 # 80015a38 <prio_lock>
    800025c2:	8526                	mv	a0,s1
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	6f6080e7          	jalr	1782(ra) # 80000cba <acquire>
  for (int i = 0; i<NPRIO; i++) {
    800025cc:	00013697          	auipc	a3,0x13
    800025d0:	41c68693          	addi	a3,a3,1052 # 800159e8 <prio>
    800025d4:	8626                	mv	a2,s1
      if (p_liste_actuelle->p->state == RUNNABLE) {
    800025d6:	4709                	li	a4,2
    struct list_proc* p_liste_actuelle = prio[i];
    800025d8:	6284                	ld	s1,0(a3)
    while (p_liste_actuelle) {
    800025da:	c48d                	beqz	s1,80002604 <pick_highest_priority_runnable_proc+0x54>
      if (p_liste_actuelle->p->state == RUNNABLE) {
    800025dc:	6088                	ld	a0,0(s1)
    800025de:	591c                	lw	a5,48(a0)
    800025e0:	00e78863          	beq	a5,a4,800025f0 <pick_highest_priority_runnable_proc+0x40>
      p_liste_actuelle = p_liste_actuelle->next;
    800025e4:	6484                	ld	s1,8(s1)
    while (p_liste_actuelle) {
    800025e6:	cc99                	beqz	s1,80002604 <pick_highest_priority_runnable_proc+0x54>
      if (p_liste_actuelle->p->state == RUNNABLE) {
    800025e8:	6088                	ld	a0,0(s1)
    800025ea:	591c                	lw	a5,48(a0)
    800025ec:	fee79ce3          	bne	a5,a4,800025e4 <pick_highest_priority_runnable_proc+0x34>
        acquire(&p_liste_actuelle->p->lock);
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	6ca080e7          	jalr	1738(ra) # 80000cba <acquire>
        return p_liste_actuelle->p;
    800025f8:	6088                	ld	a0,0(s1)
}
    800025fa:	60e2                	ld	ra,24(sp)
    800025fc:	6442                	ld	s0,16(sp)
    800025fe:	64a2                	ld	s1,8(sp)
    80002600:	6105                	addi	sp,sp,32
    80002602:	8082                	ret
    80002604:	06a1                	addi	a3,a3,8
  for (int i = 0; i<NPRIO; i++) {
    80002606:	fcc699e3          	bne	a3,a2,800025d8 <pick_highest_priority_runnable_proc+0x28>
  release(&prio_lock);
    8000260a:	00013517          	auipc	a0,0x13
    8000260e:	42e50513          	addi	a0,a0,1070 # 80015a38 <prio_lock>
    80002612:	fffff097          	auipc	ra,0xfffff
    80002616:	8f4080e7          	jalr	-1804(ra) # 80000f06 <release>
  return 0;
    8000261a:	4501                	li	a0,0
    8000261c:	bff9                	j	800025fa <pick_highest_priority_runnable_proc+0x4a>

000000008000261e <scheduler>:
{
    8000261e:	7139                	addi	sp,sp,-64
    80002620:	fc06                	sd	ra,56(sp)
    80002622:	f822                	sd	s0,48(sp)
    80002624:	f426                	sd	s1,40(sp)
    80002626:	f04a                	sd	s2,32(sp)
    80002628:	ec4e                	sd	s3,24(sp)
    8000262a:	e852                	sd	s4,16(sp)
    8000262c:	e456                	sd	s5,8(sp)
    8000262e:	0080                	addi	s0,sp,64
    80002630:	8792                	mv	a5,tp
  int id = r_tp();
    80002632:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002634:	00779993          	slli	s3,a5,0x7
    80002638:	00013717          	auipc	a4,0x13
    8000263c:	3b070713          	addi	a4,a4,944 # 800159e8 <prio>
    80002640:	974e                	add	a4,a4,s3
    80002642:	0a073823          	sd	zero,176(a4)
      swtch(&c->scheduler, &p->context);
    80002646:	00013717          	auipc	a4,0x13
    8000264a:	45a70713          	addi	a4,a4,1114 # 80015aa0 <cpus+0x8>
    8000264e:	99ba                	add	s3,s3,a4
      p->state = RUNNING;
    80002650:	4a8d                	li	s5,3
      c->proc = p;
    80002652:	079e                	slli	a5,a5,0x7
    80002654:	00013917          	auipc	s2,0x13
    80002658:	39490913          	addi	s2,s2,916 # 800159e8 <prio>
    8000265c:	993e                	add	s2,s2,a5
      release(&prio_lock);
    8000265e:	00013a17          	auipc	s4,0x13
    80002662:	3daa0a13          	addi	s4,s4,986 # 80015a38 <prio_lock>
    80002666:	a019                	j	8000266c <scheduler+0x4e>
      asm volatile("wfi");
    80002668:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000266c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002670:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002674:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002678:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000267c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000267e:	10079073          	csrw	sstatus,a5
    struct proc* p = pick_highest_priority_runnable_proc();
    80002682:	00000097          	auipc	ra,0x0
    80002686:	f2e080e7          	jalr	-210(ra) # 800025b0 <pick_highest_priority_runnable_proc>
    8000268a:	84aa                	mv	s1,a0
    if (p) {
    8000268c:	dd71                	beqz	a0,80002668 <scheduler+0x4a>
      p->state = RUNNING;
    8000268e:	03552823          	sw	s5,48(a0)
      c->proc = p;
    80002692:	0aa93823          	sd	a0,176(s2)
      remove_from_prio_queue(p);
    80002696:	00000097          	auipc	ra,0x0
    8000269a:	80a080e7          	jalr	-2038(ra) # 80001ea0 <remove_from_prio_queue>
      insert_into_prio_queue(p);
    8000269e:	8526                	mv	a0,s1
    800026a0:	fffff097          	auipc	ra,0xfffff
    800026a4:	7a6080e7          	jalr	1958(ra) # 80001e46 <insert_into_prio_queue>
      release(&prio_lock);
    800026a8:	8552                	mv	a0,s4
    800026aa:	fffff097          	auipc	ra,0xfffff
    800026ae:	85c080e7          	jalr	-1956(ra) # 80000f06 <release>
      swtch(&c->scheduler, &p->context);
    800026b2:	07848593          	addi	a1,s1,120
    800026b6:	854e                	mv	a0,s3
    800026b8:	00000097          	auipc	ra,0x0
    800026bc:	6dc080e7          	jalr	1756(ra) # 80002d94 <swtch>
       c->proc = 0;
    800026c0:	0a093823          	sd	zero,176(s2)
      c->intena = 0;
    800026c4:	12092623          	sw	zero,300(s2)
      release(&p->lock);
    800026c8:	8526                	mv	a0,s1
    800026ca:	fffff097          	auipc	ra,0xfffff
    800026ce:	83c080e7          	jalr	-1988(ra) # 80000f06 <release>
    800026d2:	bf69                	j	8000266c <scheduler+0x4e>

00000000800026d4 <sched>:
{
    800026d4:	7179                	addi	sp,sp,-48
    800026d6:	f406                	sd	ra,40(sp)
    800026d8:	f022                	sd	s0,32(sp)
    800026da:	ec26                	sd	s1,24(sp)
    800026dc:	e84a                	sd	s2,16(sp)
    800026de:	e44e                	sd	s3,8(sp)
    800026e0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800026e2:	00000097          	auipc	ra,0x0
    800026e6:	95e080e7          	jalr	-1698(ra) # 80002040 <myproc>
    800026ea:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	550080e7          	jalr	1360(ra) # 80000c3c <holding>
    800026f4:	cd25                	beqz	a0,8000276c <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800026f6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800026f8:	2781                	sext.w	a5,a5
    800026fa:	079e                	slli	a5,a5,0x7
    800026fc:	00013717          	auipc	a4,0x13
    80002700:	2ec70713          	addi	a4,a4,748 # 800159e8 <prio>
    80002704:	97ba                	add	a5,a5,a4
    80002706:	1287a703          	lw	a4,296(a5)
    8000270a:	4785                	li	a5,1
    8000270c:	06f71863          	bne	a4,a5,8000277c <sched+0xa8>
  if(p->state == RUNNING)
    80002710:	03092703          	lw	a4,48(s2)
    80002714:	478d                	li	a5,3
    80002716:	06f70b63          	beq	a4,a5,8000278c <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000271a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000271e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002720:	efb5                	bnez	a5,8000279c <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002722:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002724:	00013497          	auipc	s1,0x13
    80002728:	2c448493          	addi	s1,s1,708 # 800159e8 <prio>
    8000272c:	2781                	sext.w	a5,a5
    8000272e:	079e                	slli	a5,a5,0x7
    80002730:	97a6                	add	a5,a5,s1
    80002732:	12c7a983          	lw	s3,300(a5)
    80002736:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80002738:	2781                	sext.w	a5,a5
    8000273a:	079e                	slli	a5,a5,0x7
    8000273c:	00013597          	auipc	a1,0x13
    80002740:	36458593          	addi	a1,a1,868 # 80015aa0 <cpus+0x8>
    80002744:	95be                	add	a1,a1,a5
    80002746:	07890513          	addi	a0,s2,120
    8000274a:	00000097          	auipc	ra,0x0
    8000274e:	64a080e7          	jalr	1610(ra) # 80002d94 <swtch>
    80002752:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002754:	2781                	sext.w	a5,a5
    80002756:	079e                	slli	a5,a5,0x7
    80002758:	97a6                	add	a5,a5,s1
    8000275a:	1337a623          	sw	s3,300(a5)
}
    8000275e:	70a2                	ld	ra,40(sp)
    80002760:	7402                	ld	s0,32(sp)
    80002762:	64e2                	ld	s1,24(sp)
    80002764:	6942                	ld	s2,16(sp)
    80002766:	69a2                	ld	s3,8(sp)
    80002768:	6145                	addi	sp,sp,48
    8000276a:	8082                	ret
    panic("sched p->lock");
    8000276c:	00006517          	auipc	a0,0x6
    80002770:	e5450513          	addi	a0,a0,-428 # 800085c0 <userret+0x530>
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	010080e7          	jalr	16(ra) # 80000784 <panic>
    panic("sched locks");
    8000277c:	00006517          	auipc	a0,0x6
    80002780:	e5450513          	addi	a0,a0,-428 # 800085d0 <userret+0x540>
    80002784:	ffffe097          	auipc	ra,0xffffe
    80002788:	000080e7          	jalr	ra # 80000784 <panic>
    panic("sched running");
    8000278c:	00006517          	auipc	a0,0x6
    80002790:	e5450513          	addi	a0,a0,-428 # 800085e0 <userret+0x550>
    80002794:	ffffe097          	auipc	ra,0xffffe
    80002798:	ff0080e7          	jalr	-16(ra) # 80000784 <panic>
    panic("sched interruptible");
    8000279c:	00006517          	auipc	a0,0x6
    800027a0:	e5450513          	addi	a0,a0,-428 # 800085f0 <userret+0x560>
    800027a4:	ffffe097          	auipc	ra,0xffffe
    800027a8:	fe0080e7          	jalr	-32(ra) # 80000784 <panic>

00000000800027ac <exit>:
{
    800027ac:	7179                	addi	sp,sp,-48
    800027ae:	f406                	sd	ra,40(sp)
    800027b0:	f022                	sd	s0,32(sp)
    800027b2:	ec26                	sd	s1,24(sp)
    800027b4:	e84a                	sd	s2,16(sp)
    800027b6:	e44e                	sd	s3,8(sp)
    800027b8:	e052                	sd	s4,0(sp)
    800027ba:	1800                	addi	s0,sp,48
    800027bc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800027be:	00000097          	auipc	ra,0x0
    800027c2:	882080e7          	jalr	-1918(ra) # 80002040 <myproc>
    800027c6:	89aa                	mv	s3,a0
  if(p == initproc)
    800027c8:	0002c797          	auipc	a5,0x2c
    800027cc:	8b878793          	addi	a5,a5,-1864 # 8002e080 <initproc>
    800027d0:	639c                	ld	a5,0(a5)
    800027d2:	0e850493          	addi	s1,a0,232
    800027d6:	16850913          	addi	s2,a0,360
    800027da:	02a79363          	bne	a5,a0,80002800 <exit+0x54>
    panic("init exiting");
    800027de:	00006517          	auipc	a0,0x6
    800027e2:	e2a50513          	addi	a0,a0,-470 # 80008608 <userret+0x578>
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	f9e080e7          	jalr	-98(ra) # 80000784 <panic>
      fileclose(f);
    800027ee:	00002097          	auipc	ra,0x2
    800027f2:	70c080e7          	jalr	1804(ra) # 80004efa <fileclose>
      p->ofile[fd] = 0;
    800027f6:	0004b023          	sd	zero,0(s1)
    800027fa:	04a1                	addi	s1,s1,8
  for(int fd = 0; fd < NOFILE; fd++){
    800027fc:	01248563          	beq	s1,s2,80002806 <exit+0x5a>
    if(p->ofile[fd]){
    80002800:	6088                	ld	a0,0(s1)
    80002802:	f575                	bnez	a0,800027ee <exit+0x42>
    80002804:	bfdd                	j	800027fa <exit+0x4e>
  begin_op(ROOTDEV);
    80002806:	4501                	li	a0,0
    80002808:	00002097          	auipc	ra,0x2
    8000280c:	136080e7          	jalr	310(ra) # 8000493e <begin_op>
  iput(p->cwd);
    80002810:	1689b503          	ld	a0,360(s3)
    80002814:	00002097          	auipc	ra,0x2
    80002818:	860080e7          	jalr	-1952(ra) # 80004074 <iput>
  end_op(ROOTDEV);
    8000281c:	4501                	li	a0,0
    8000281e:	00002097          	auipc	ra,0x2
    80002822:	1cc080e7          	jalr	460(ra) # 800049ea <end_op>
  p->cwd = 0;
    80002826:	1609b423          	sd	zero,360(s3)
  acquire(&initproc->lock);
    8000282a:	0002c497          	auipc	s1,0x2c
    8000282e:	85648493          	addi	s1,s1,-1962 # 8002e080 <initproc>
    80002832:	6088                	ld	a0,0(s1)
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	486080e7          	jalr	1158(ra) # 80000cba <acquire>
  wakeup1(initproc);
    8000283c:	6088                	ld	a0,0(s1)
    8000283e:	fffff097          	auipc	ra,0xfffff
    80002842:	5c4080e7          	jalr	1476(ra) # 80001e02 <wakeup1>
  release(&initproc->lock);
    80002846:	6088                	ld	a0,0(s1)
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	6be080e7          	jalr	1726(ra) # 80000f06 <release>
  acquire(&prio_lock);
    80002850:	00013497          	auipc	s1,0x13
    80002854:	1e848493          	addi	s1,s1,488 # 80015a38 <prio_lock>
    80002858:	8526                	mv	a0,s1
    8000285a:	ffffe097          	auipc	ra,0xffffe
    8000285e:	460080e7          	jalr	1120(ra) # 80000cba <acquire>
  acquire(&p->lock);
    80002862:	854e                	mv	a0,s3
    80002864:	ffffe097          	auipc	ra,0xffffe
    80002868:	456080e7          	jalr	1110(ra) # 80000cba <acquire>
  remove_from_prio_queue(p);
    8000286c:	854e                	mv	a0,s3
    8000286e:	fffff097          	auipc	ra,0xfffff
    80002872:	632080e7          	jalr	1586(ra) # 80001ea0 <remove_from_prio_queue>
  release(&p->lock);
    80002876:	854e                	mv	a0,s3
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	68e080e7          	jalr	1678(ra) # 80000f06 <release>
  release(&prio_lock);
    80002880:	8526                	mv	a0,s1
    80002882:	ffffe097          	auipc	ra,0xffffe
    80002886:	684080e7          	jalr	1668(ra) # 80000f06 <release>
  acquire(&p->lock);
    8000288a:	854e                	mv	a0,s3
    8000288c:	ffffe097          	auipc	ra,0xffffe
    80002890:	42e080e7          	jalr	1070(ra) # 80000cba <acquire>
  struct proc *original_parent = p->parent;
    80002894:	0389b483          	ld	s1,56(s3)
  release(&p->lock);
    80002898:	854e                	mv	a0,s3
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	66c080e7          	jalr	1644(ra) # 80000f06 <release>
  acquire(&original_parent->lock);
    800028a2:	8526                	mv	a0,s1
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	416080e7          	jalr	1046(ra) # 80000cba <acquire>
  acquire(&p->lock);
    800028ac:	854e                	mv	a0,s3
    800028ae:	ffffe097          	auipc	ra,0xffffe
    800028b2:	40c080e7          	jalr	1036(ra) # 80000cba <acquire>
  reparent(p);
    800028b6:	854e                	mv	a0,s3
    800028b8:	00000097          	auipc	ra,0x0
    800028bc:	c92080e7          	jalr	-878(ra) # 8000254a <reparent>
  wakeup1(original_parent);
    800028c0:	8526                	mv	a0,s1
    800028c2:	fffff097          	auipc	ra,0xfffff
    800028c6:	540080e7          	jalr	1344(ra) # 80001e02 <wakeup1>
  p->xstate = status;
    800028ca:	0549a623          	sw	s4,76(s3)
  p->state = ZOMBIE;
    800028ce:	4791                	li	a5,4
    800028d0:	02f9a823          	sw	a5,48(s3)
  release(&original_parent->lock);
    800028d4:	8526                	mv	a0,s1
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	630080e7          	jalr	1584(ra) # 80000f06 <release>
  sched();
    800028de:	00000097          	auipc	ra,0x0
    800028e2:	df6080e7          	jalr	-522(ra) # 800026d4 <sched>
  panic("zombie exit");
    800028e6:	00006517          	auipc	a0,0x6
    800028ea:	d3250513          	addi	a0,a0,-718 # 80008618 <userret+0x588>
    800028ee:	ffffe097          	auipc	ra,0xffffe
    800028f2:	e96080e7          	jalr	-362(ra) # 80000784 <panic>

00000000800028f6 <yield>:
{
    800028f6:	1101                	addi	sp,sp,-32
    800028f8:	ec06                	sd	ra,24(sp)
    800028fa:	e822                	sd	s0,16(sp)
    800028fc:	e426                	sd	s1,8(sp)
    800028fe:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002900:	fffff097          	auipc	ra,0xfffff
    80002904:	740080e7          	jalr	1856(ra) # 80002040 <myproc>
    80002908:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	3b0080e7          	jalr	944(ra) # 80000cba <acquire>
  p->state = RUNNABLE;
    80002912:	4789                	li	a5,2
    80002914:	d89c                	sw	a5,48(s1)
  sched();
    80002916:	00000097          	auipc	ra,0x0
    8000291a:	dbe080e7          	jalr	-578(ra) # 800026d4 <sched>
  release(&p->lock);
    8000291e:	8526                	mv	a0,s1
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	5e6080e7          	jalr	1510(ra) # 80000f06 <release>
}
    80002928:	60e2                	ld	ra,24(sp)
    8000292a:	6442                	ld	s0,16(sp)
    8000292c:	64a2                	ld	s1,8(sp)
    8000292e:	6105                	addi	sp,sp,32
    80002930:	8082                	ret

0000000080002932 <sleep>:
{
    80002932:	7179                	addi	sp,sp,-48
    80002934:	f406                	sd	ra,40(sp)
    80002936:	f022                	sd	s0,32(sp)
    80002938:	ec26                	sd	s1,24(sp)
    8000293a:	e84a                	sd	s2,16(sp)
    8000293c:	e44e                	sd	s3,8(sp)
    8000293e:	1800                	addi	s0,sp,48
    80002940:	89aa                	mv	s3,a0
    80002942:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002944:	fffff097          	auipc	ra,0xfffff
    80002948:	6fc080e7          	jalr	1788(ra) # 80002040 <myproc>
    8000294c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000294e:	05250663          	beq	a0,s2,8000299a <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002952:	ffffe097          	auipc	ra,0xffffe
    80002956:	368080e7          	jalr	872(ra) # 80000cba <acquire>
    release(lk);
    8000295a:	854a                	mv	a0,s2
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	5aa080e7          	jalr	1450(ra) # 80000f06 <release>
  p->chan = chan;
    80002964:	0534b023          	sd	s3,64(s1)
  p->state = SLEEPING;
    80002968:	4785                	li	a5,1
    8000296a:	d89c                	sw	a5,48(s1)
  sched();
    8000296c:	00000097          	auipc	ra,0x0
    80002970:	d68080e7          	jalr	-664(ra) # 800026d4 <sched>
  p->chan = 0;
    80002974:	0404b023          	sd	zero,64(s1)
    release(&p->lock);
    80002978:	8526                	mv	a0,s1
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	58c080e7          	jalr	1420(ra) # 80000f06 <release>
    acquire(lk);
    80002982:	854a                	mv	a0,s2
    80002984:	ffffe097          	auipc	ra,0xffffe
    80002988:	336080e7          	jalr	822(ra) # 80000cba <acquire>
}
    8000298c:	70a2                	ld	ra,40(sp)
    8000298e:	7402                	ld	s0,32(sp)
    80002990:	64e2                	ld	s1,24(sp)
    80002992:	6942                	ld	s2,16(sp)
    80002994:	69a2                	ld	s3,8(sp)
    80002996:	6145                	addi	sp,sp,48
    80002998:	8082                	ret
  p->chan = chan;
    8000299a:	05353023          	sd	s3,64(a0)
  p->state = SLEEPING;
    8000299e:	4785                	li	a5,1
    800029a0:	d91c                	sw	a5,48(a0)
  sched();
    800029a2:	00000097          	auipc	ra,0x0
    800029a6:	d32080e7          	jalr	-718(ra) # 800026d4 <sched>
  p->chan = 0;
    800029aa:	0404b023          	sd	zero,64(s1)
  if(lk != &p->lock){
    800029ae:	bff9                	j	8000298c <sleep+0x5a>

00000000800029b0 <wait>:
{
    800029b0:	715d                	addi	sp,sp,-80
    800029b2:	e486                	sd	ra,72(sp)
    800029b4:	e0a2                	sd	s0,64(sp)
    800029b6:	fc26                	sd	s1,56(sp)
    800029b8:	f84a                	sd	s2,48(sp)
    800029ba:	f44e                	sd	s3,40(sp)
    800029bc:	f052                	sd	s4,32(sp)
    800029be:	ec56                	sd	s5,24(sp)
    800029c0:	e85a                	sd	s6,16(sp)
    800029c2:	e45e                	sd	s7,8(sp)
    800029c4:	e062                	sd	s8,0(sp)
    800029c6:	0880                	addi	s0,sp,80
    800029c8:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800029ca:	fffff097          	auipc	ra,0xfffff
    800029ce:	676080e7          	jalr	1654(ra) # 80002040 <myproc>
    800029d2:	892a                	mv	s2,a0
  acquire(&p->lock);
    800029d4:	8c2a                	mv	s8,a0
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	2e4080e7          	jalr	740(ra) # 80000cba <acquire>
    havekids = 0;
    800029de:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    800029e0:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800029e2:	00019997          	auipc	s3,0x19
    800029e6:	6b698993          	addi	s3,s3,1718 # 8001c098 <tickslock>
        havekids = 1;
    800029ea:	4a85                	li	s5,1
    havekids = 0;
    800029ec:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    800029ee:	00013497          	auipc	s1,0x13
    800029f2:	4aa48493          	addi	s1,s1,1194 # 80015e98 <proc>
    800029f6:	a08d                	j	80002a58 <wait+0xa8>
          pid = np->pid;
    800029f8:	0504a983          	lw	s3,80(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800029fc:	000b8e63          	beqz	s7,80002a18 <wait+0x68>
    80002a00:	4691                	li	a3,4
    80002a02:	04c48613          	addi	a2,s1,76
    80002a06:	85de                	mv	a1,s7
    80002a08:	06893503          	ld	a0,104(s2)
    80002a0c:	fffff097          	auipc	ra,0xfffff
    80002a10:	212080e7          	jalr	530(ra) # 80001c1e <copyout>
    80002a14:	02054263          	bltz	a0,80002a38 <wait+0x88>
          freeproc(np);
    80002a18:	8526                	mv	a0,s1
    80002a1a:	00000097          	auipc	ra,0x0
    80002a1e:	848080e7          	jalr	-1976(ra) # 80002262 <freeproc>
          release(&np->lock);
    80002a22:	8526                	mv	a0,s1
    80002a24:	ffffe097          	auipc	ra,0xffffe
    80002a28:	4e2080e7          	jalr	1250(ra) # 80000f06 <release>
          release(&p->lock);
    80002a2c:	854a                	mv	a0,s2
    80002a2e:	ffffe097          	auipc	ra,0xffffe
    80002a32:	4d8080e7          	jalr	1240(ra) # 80000f06 <release>
          return pid;
    80002a36:	a8a9                	j	80002a90 <wait+0xe0>
            release(&np->lock);
    80002a38:	8526                	mv	a0,s1
    80002a3a:	ffffe097          	auipc	ra,0xffffe
    80002a3e:	4cc080e7          	jalr	1228(ra) # 80000f06 <release>
            release(&p->lock);
    80002a42:	854a                	mv	a0,s2
    80002a44:	ffffe097          	auipc	ra,0xffffe
    80002a48:	4c2080e7          	jalr	1218(ra) # 80000f06 <release>
            return -1;
    80002a4c:	59fd                	li	s3,-1
    80002a4e:	a089                	j	80002a90 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002a50:	18848493          	addi	s1,s1,392
    80002a54:	03348463          	beq	s1,s3,80002a7c <wait+0xcc>
      if(np->parent == p){
    80002a58:	7c9c                	ld	a5,56(s1)
    80002a5a:	ff279be3          	bne	a5,s2,80002a50 <wait+0xa0>
        acquire(&np->lock);
    80002a5e:	8526                	mv	a0,s1
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	25a080e7          	jalr	602(ra) # 80000cba <acquire>
        if(np->state == ZOMBIE){
    80002a68:	589c                	lw	a5,48(s1)
    80002a6a:	f94787e3          	beq	a5,s4,800029f8 <wait+0x48>
        release(&np->lock);
    80002a6e:	8526                	mv	a0,s1
    80002a70:	ffffe097          	auipc	ra,0xffffe
    80002a74:	496080e7          	jalr	1174(ra) # 80000f06 <release>
        havekids = 1;
    80002a78:	8756                	mv	a4,s5
    80002a7a:	bfd9                	j	80002a50 <wait+0xa0>
    if(!havekids || p->killed){
    80002a7c:	c701                	beqz	a4,80002a84 <wait+0xd4>
    80002a7e:	04892783          	lw	a5,72(s2)
    80002a82:	c785                	beqz	a5,80002aaa <wait+0xfa>
      release(&p->lock);
    80002a84:	854a                	mv	a0,s2
    80002a86:	ffffe097          	auipc	ra,0xffffe
    80002a8a:	480080e7          	jalr	1152(ra) # 80000f06 <release>
      return -1;
    80002a8e:	59fd                	li	s3,-1
}
    80002a90:	854e                	mv	a0,s3
    80002a92:	60a6                	ld	ra,72(sp)
    80002a94:	6406                	ld	s0,64(sp)
    80002a96:	74e2                	ld	s1,56(sp)
    80002a98:	7942                	ld	s2,48(sp)
    80002a9a:	79a2                	ld	s3,40(sp)
    80002a9c:	7a02                	ld	s4,32(sp)
    80002a9e:	6ae2                	ld	s5,24(sp)
    80002aa0:	6b42                	ld	s6,16(sp)
    80002aa2:	6ba2                	ld	s7,8(sp)
    80002aa4:	6c02                	ld	s8,0(sp)
    80002aa6:	6161                	addi	sp,sp,80
    80002aa8:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002aaa:	85e2                	mv	a1,s8
    80002aac:	854a                	mv	a0,s2
    80002aae:	00000097          	auipc	ra,0x0
    80002ab2:	e84080e7          	jalr	-380(ra) # 80002932 <sleep>
    havekids = 0;
    80002ab6:	bf1d                	j	800029ec <wait+0x3c>

0000000080002ab8 <wakeup>:
{
    80002ab8:	7139                	addi	sp,sp,-64
    80002aba:	fc06                	sd	ra,56(sp)
    80002abc:	f822                	sd	s0,48(sp)
    80002abe:	f426                	sd	s1,40(sp)
    80002ac0:	f04a                	sd	s2,32(sp)
    80002ac2:	ec4e                	sd	s3,24(sp)
    80002ac4:	e852                	sd	s4,16(sp)
    80002ac6:	e456                	sd	s5,8(sp)
    80002ac8:	0080                	addi	s0,sp,64
    80002aca:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002acc:	00013497          	auipc	s1,0x13
    80002ad0:	3cc48493          	addi	s1,s1,972 # 80015e98 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002ad4:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002ad6:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002ad8:	00019917          	auipc	s2,0x19
    80002adc:	5c090913          	addi	s2,s2,1472 # 8001c098 <tickslock>
    80002ae0:	a821                	j	80002af8 <wakeup+0x40>
      p->state = RUNNABLE;
    80002ae2:	0354a823          	sw	s5,48(s1)
    release(&p->lock);
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	41e080e7          	jalr	1054(ra) # 80000f06 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002af0:	18848493          	addi	s1,s1,392
    80002af4:	01248e63          	beq	s1,s2,80002b10 <wakeup+0x58>
    acquire(&p->lock);
    80002af8:	8526                	mv	a0,s1
    80002afa:	ffffe097          	auipc	ra,0xffffe
    80002afe:	1c0080e7          	jalr	448(ra) # 80000cba <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002b02:	589c                	lw	a5,48(s1)
    80002b04:	ff3791e3          	bne	a5,s3,80002ae6 <wakeup+0x2e>
    80002b08:	60bc                	ld	a5,64(s1)
    80002b0a:	fd479ee3          	bne	a5,s4,80002ae6 <wakeup+0x2e>
    80002b0e:	bfd1                	j	80002ae2 <wakeup+0x2a>
}
    80002b10:	70e2                	ld	ra,56(sp)
    80002b12:	7442                	ld	s0,48(sp)
    80002b14:	74a2                	ld	s1,40(sp)
    80002b16:	7902                	ld	s2,32(sp)
    80002b18:	69e2                	ld	s3,24(sp)
    80002b1a:	6a42                	ld	s4,16(sp)
    80002b1c:	6aa2                	ld	s5,8(sp)
    80002b1e:	6121                	addi	sp,sp,64
    80002b20:	8082                	ret

0000000080002b22 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002b22:	7179                	addi	sp,sp,-48
    80002b24:	f406                	sd	ra,40(sp)
    80002b26:	f022                	sd	s0,32(sp)
    80002b28:	ec26                	sd	s1,24(sp)
    80002b2a:	e84a                	sd	s2,16(sp)
    80002b2c:	e44e                	sd	s3,8(sp)
    80002b2e:	1800                	addi	s0,sp,48
    80002b30:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002b32:	00013497          	auipc	s1,0x13
    80002b36:	36648493          	addi	s1,s1,870 # 80015e98 <proc>
    80002b3a:	00019997          	auipc	s3,0x19
    80002b3e:	55e98993          	addi	s3,s3,1374 # 8001c098 <tickslock>
    acquire(&p->lock);
    80002b42:	8526                	mv	a0,s1
    80002b44:	ffffe097          	auipc	ra,0xffffe
    80002b48:	176080e7          	jalr	374(ra) # 80000cba <acquire>
    if(p->pid == pid){
    80002b4c:	48bc                	lw	a5,80(s1)
    80002b4e:	01278d63          	beq	a5,s2,80002b68 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002b52:	8526                	mv	a0,s1
    80002b54:	ffffe097          	auipc	ra,0xffffe
    80002b58:	3b2080e7          	jalr	946(ra) # 80000f06 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b5c:	18848493          	addi	s1,s1,392
    80002b60:	ff3491e3          	bne	s1,s3,80002b42 <kill+0x20>
  }
  return -1;
    80002b64:	557d                	li	a0,-1
    80002b66:	a829                	j	80002b80 <kill+0x5e>
      p->killed = 1;
    80002b68:	4785                	li	a5,1
    80002b6a:	c4bc                	sw	a5,72(s1)
      if(p->state == SLEEPING){
    80002b6c:	5898                	lw	a4,48(s1)
    80002b6e:	4785                	li	a5,1
    80002b70:	00f70f63          	beq	a4,a5,80002b8e <kill+0x6c>
      release(&p->lock);
    80002b74:	8526                	mv	a0,s1
    80002b76:	ffffe097          	auipc	ra,0xffffe
    80002b7a:	390080e7          	jalr	912(ra) # 80000f06 <release>
      return 0;
    80002b7e:	4501                	li	a0,0
}
    80002b80:	70a2                	ld	ra,40(sp)
    80002b82:	7402                	ld	s0,32(sp)
    80002b84:	64e2                	ld	s1,24(sp)
    80002b86:	6942                	ld	s2,16(sp)
    80002b88:	69a2                	ld	s3,8(sp)
    80002b8a:	6145                	addi	sp,sp,48
    80002b8c:	8082                	ret
        p->state = RUNNABLE;
    80002b8e:	4789                	li	a5,2
    80002b90:	d89c                	sw	a5,48(s1)
    80002b92:	b7cd                	j	80002b74 <kill+0x52>

0000000080002b94 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002b94:	7179                	addi	sp,sp,-48
    80002b96:	f406                	sd	ra,40(sp)
    80002b98:	f022                	sd	s0,32(sp)
    80002b9a:	ec26                	sd	s1,24(sp)
    80002b9c:	e84a                	sd	s2,16(sp)
    80002b9e:	e44e                	sd	s3,8(sp)
    80002ba0:	e052                	sd	s4,0(sp)
    80002ba2:	1800                	addi	s0,sp,48
    80002ba4:	84aa                	mv	s1,a0
    80002ba6:	892e                	mv	s2,a1
    80002ba8:	89b2                	mv	s3,a2
    80002baa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002bac:	fffff097          	auipc	ra,0xfffff
    80002bb0:	494080e7          	jalr	1172(ra) # 80002040 <myproc>
  if(user_dst){
    80002bb4:	c08d                	beqz	s1,80002bd6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002bb6:	86d2                	mv	a3,s4
    80002bb8:	864e                	mv	a2,s3
    80002bba:	85ca                	mv	a1,s2
    80002bbc:	7528                	ld	a0,104(a0)
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	060080e7          	jalr	96(ra) # 80001c1e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002bc6:	70a2                	ld	ra,40(sp)
    80002bc8:	7402                	ld	s0,32(sp)
    80002bca:	64e2                	ld	s1,24(sp)
    80002bcc:	6942                	ld	s2,16(sp)
    80002bce:	69a2                	ld	s3,8(sp)
    80002bd0:	6a02                	ld	s4,0(sp)
    80002bd2:	6145                	addi	sp,sp,48
    80002bd4:	8082                	ret
    memmove((char *)dst, src, len);
    80002bd6:	000a061b          	sext.w	a2,s4
    80002bda:	85ce                	mv	a1,s3
    80002bdc:	854a                	mv	a0,s2
    80002bde:	ffffe097          	auipc	ra,0xffffe
    80002be2:	5bc080e7          	jalr	1468(ra) # 8000119a <memmove>
    return 0;
    80002be6:	8526                	mv	a0,s1
    80002be8:	bff9                	j	80002bc6 <either_copyout+0x32>

0000000080002bea <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002bea:	7179                	addi	sp,sp,-48
    80002bec:	f406                	sd	ra,40(sp)
    80002bee:	f022                	sd	s0,32(sp)
    80002bf0:	ec26                	sd	s1,24(sp)
    80002bf2:	e84a                	sd	s2,16(sp)
    80002bf4:	e44e                	sd	s3,8(sp)
    80002bf6:	e052                	sd	s4,0(sp)
    80002bf8:	1800                	addi	s0,sp,48
    80002bfa:	892a                	mv	s2,a0
    80002bfc:	84ae                	mv	s1,a1
    80002bfe:	89b2                	mv	s3,a2
    80002c00:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002c02:	fffff097          	auipc	ra,0xfffff
    80002c06:	43e080e7          	jalr	1086(ra) # 80002040 <myproc>
  if(user_src){
    80002c0a:	c08d                	beqz	s1,80002c2c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002c0c:	86d2                	mv	a3,s4
    80002c0e:	864e                	mv	a2,s3
    80002c10:	85ca                	mv	a1,s2
    80002c12:	7528                	ld	a0,104(a0)
    80002c14:	fffff097          	auipc	ra,0xfffff
    80002c18:	096080e7          	jalr	150(ra) # 80001caa <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002c1c:	70a2                	ld	ra,40(sp)
    80002c1e:	7402                	ld	s0,32(sp)
    80002c20:	64e2                	ld	s1,24(sp)
    80002c22:	6942                	ld	s2,16(sp)
    80002c24:	69a2                	ld	s3,8(sp)
    80002c26:	6a02                	ld	s4,0(sp)
    80002c28:	6145                	addi	sp,sp,48
    80002c2a:	8082                	ret
    memmove(dst, (char*)src, len);
    80002c2c:	000a061b          	sext.w	a2,s4
    80002c30:	85ce                	mv	a1,s3
    80002c32:	854a                	mv	a0,s2
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	566080e7          	jalr	1382(ra) # 8000119a <memmove>
    return 0;
    80002c3c:	8526                	mv	a0,s1
    80002c3e:	bff9                	j	80002c1c <either_copyin+0x32>

0000000080002c40 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002c40:	715d                	addi	sp,sp,-80
    80002c42:	e486                	sd	ra,72(sp)
    80002c44:	e0a2                	sd	s0,64(sp)
    80002c46:	fc26                	sd	s1,56(sp)
    80002c48:	f84a                	sd	s2,48(sp)
    80002c4a:	f44e                	sd	s3,40(sp)
    80002c4c:	f052                	sd	s4,32(sp)
    80002c4e:	ec56                	sd	s5,24(sp)
    80002c50:	e85a                	sd	s6,16(sp)
    80002c52:	e45e                	sd	s7,8(sp)
    80002c54:	e062                	sd	s8,0(sp)
    80002c56:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\nPID\tPPID\tPRIO\tSTATE\tCMD\n");
    80002c58:	00006517          	auipc	a0,0x6
    80002c5c:	9d850513          	addi	a0,a0,-1576 # 80008630 <userret+0x5a0>
    80002c60:	ffffe097          	auipc	ra,0xffffe
    80002c64:	d3c080e7          	jalr	-708(ra) # 8000099c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c68:	00013497          	auipc	s1,0x13
    80002c6c:	23048493          	addi	s1,s1,560 # 80015e98 <proc>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c70:	4b91                	li	s7,4
      state = states[p->state];
    else
      state = "???";
    80002c72:	00006997          	auipc	s3,0x6
    80002c76:	9b698993          	addi	s3,s3,-1610 # 80008628 <userret+0x598>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002c7a:	5b7d                	li	s6,-1
    80002c7c:	00006a97          	auipc	s5,0x6
    80002c80:	9d4a8a93          	addi	s5,s5,-1580 # 80008650 <userret+0x5c0>
           p->parent ? p->parent->pid : -1,
           p->priority,
           state,
           p->cmd
           );
    printf("\n");
    80002c84:	00006a17          	auipc	s4,0x6
    80002c88:	9c4a0a13          	addi	s4,s4,-1596 # 80008648 <userret+0x5b8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c8c:	00006c17          	auipc	s8,0x6
    80002c90:	27cc0c13          	addi	s8,s8,636 # 80008f08 <states.1858>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c94:	00019917          	auipc	s2,0x19
    80002c98:	40490913          	addi	s2,s2,1028 # 8001c098 <tickslock>
    80002c9c:	a03d                	j	80002cca <procdump+0x8a>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002c9e:	48ac                	lw	a1,80(s1)
           p->parent ? p->parent->pid : -1,
    80002ca0:	7c9c                	ld	a5,56(s1)
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002ca2:	865a                	mv	a2,s6
    80002ca4:	c391                	beqz	a5,80002ca8 <procdump+0x68>
    80002ca6:	4bb0                	lw	a2,80(a5)
    80002ca8:	1804b783          	ld	a5,384(s1)
    80002cac:	48f4                	lw	a3,84(s1)
    80002cae:	8556                	mv	a0,s5
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	cec080e7          	jalr	-788(ra) # 8000099c <printf>
    printf("\n");
    80002cb8:	8552                	mv	a0,s4
    80002cba:	ffffe097          	auipc	ra,0xffffe
    80002cbe:	ce2080e7          	jalr	-798(ra) # 8000099c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002cc2:	18848493          	addi	s1,s1,392
    80002cc6:	01248f63          	beq	s1,s2,80002ce4 <procdump+0xa4>
    if(p->state == UNUSED)
    80002cca:	589c                	lw	a5,48(s1)
    80002ccc:	dbfd                	beqz	a5,80002cc2 <procdump+0x82>
      state = "???";
    80002cce:	874e                	mv	a4,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002cd0:	fcfbe7e3          	bltu	s7,a5,80002c9e <procdump+0x5e>
    80002cd4:	1782                	slli	a5,a5,0x20
    80002cd6:	9381                	srli	a5,a5,0x20
    80002cd8:	078e                	slli	a5,a5,0x3
    80002cda:	97e2                	add	a5,a5,s8
    80002cdc:	6398                	ld	a4,0(a5)
    80002cde:	f361                	bnez	a4,80002c9e <procdump+0x5e>
      state = "???";
    80002ce0:	874e                	mv	a4,s3
    80002ce2:	bf75                	j	80002c9e <procdump+0x5e>
  }
}
    80002ce4:	60a6                	ld	ra,72(sp)
    80002ce6:	6406                	ld	s0,64(sp)
    80002ce8:	74e2                	ld	s1,56(sp)
    80002cea:	7942                	ld	s2,48(sp)
    80002cec:	79a2                	ld	s3,40(sp)
    80002cee:	7a02                	ld	s4,32(sp)
    80002cf0:	6ae2                	ld	s5,24(sp)
    80002cf2:	6b42                	ld	s6,16(sp)
    80002cf4:	6ba2                	ld	s7,8(sp)
    80002cf6:	6c02                	ld	s8,0(sp)
    80002cf8:	6161                	addi	sp,sp,80
    80002cfa:	8082                	ret

0000000080002cfc <priodump>:

// No lock to avoid wedging a stuck machine further.
void priodump(void){
    80002cfc:	715d                	addi	sp,sp,-80
    80002cfe:	e486                	sd	ra,72(sp)
    80002d00:	e0a2                	sd	s0,64(sp)
    80002d02:	fc26                	sd	s1,56(sp)
    80002d04:	f84a                	sd	s2,48(sp)
    80002d06:	f44e                	sd	s3,40(sp)
    80002d08:	f052                	sd	s4,32(sp)
    80002d0a:	ec56                	sd	s5,24(sp)
    80002d0c:	e85a                	sd	s6,16(sp)
    80002d0e:	e45e                	sd	s7,8(sp)
    80002d10:	0880                	addi	s0,sp,80
  for (int i = 0; i < NPRIO; i++){
    80002d12:	00013a17          	auipc	s4,0x13
    80002d16:	cd6a0a13          	addi	s4,s4,-810 # 800159e8 <prio>
    80002d1a:	4981                	li	s3,0
    struct list_proc* l = prio[i];
    printf("Priority queue for priority = %d: ", i);
    80002d1c:	00006b97          	auipc	s7,0x6
    80002d20:	94cb8b93          	addi	s7,s7,-1716 # 80008668 <userret+0x5d8>
    while(l){
      printf("%d ", l->p->pid);
    80002d24:	00006917          	auipc	s2,0x6
    80002d28:	96c90913          	addi	s2,s2,-1684 # 80008690 <userret+0x600>
      l = l->next;
    }
    printf("\n");
    80002d2c:	00006b17          	auipc	s6,0x6
    80002d30:	91cb0b13          	addi	s6,s6,-1764 # 80008648 <userret+0x5b8>
  for (int i = 0; i < NPRIO; i++){
    80002d34:	4aa9                	li	s5,10
    80002d36:	a811                	j	80002d4a <priodump+0x4e>
    printf("\n");
    80002d38:	855a                	mv	a0,s6
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	c62080e7          	jalr	-926(ra) # 8000099c <printf>
  for (int i = 0; i < NPRIO; i++){
    80002d42:	2985                	addiw	s3,s3,1
    80002d44:	0a21                	addi	s4,s4,8
    80002d46:	03598563          	beq	s3,s5,80002d70 <priodump+0x74>
    struct list_proc* l = prio[i];
    80002d4a:	000a3483          	ld	s1,0(s4)
    printf("Priority queue for priority = %d: ", i);
    80002d4e:	85ce                	mv	a1,s3
    80002d50:	855e                	mv	a0,s7
    80002d52:	ffffe097          	auipc	ra,0xffffe
    80002d56:	c4a080e7          	jalr	-950(ra) # 8000099c <printf>
    while(l){
    80002d5a:	dcf9                	beqz	s1,80002d38 <priodump+0x3c>
      printf("%d ", l->p->pid);
    80002d5c:	609c                	ld	a5,0(s1)
    80002d5e:	4bac                	lw	a1,80(a5)
    80002d60:	854a                	mv	a0,s2
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	c3a080e7          	jalr	-966(ra) # 8000099c <printf>
      l = l->next;
    80002d6a:	6484                	ld	s1,8(s1)
    while(l){
    80002d6c:	f8e5                	bnez	s1,80002d5c <priodump+0x60>
    80002d6e:	b7e9                	j	80002d38 <priodump+0x3c>
  }
}
    80002d70:	60a6                	ld	ra,72(sp)
    80002d72:	6406                	ld	s0,64(sp)
    80002d74:	74e2                	ld	s1,56(sp)
    80002d76:	7942                	ld	s2,48(sp)
    80002d78:	79a2                	ld	s3,40(sp)
    80002d7a:	7a02                	ld	s4,32(sp)
    80002d7c:	6ae2                	ld	s5,24(sp)
    80002d7e:	6b42                	ld	s6,16(sp)
    80002d80:	6ba2                	ld	s7,8(sp)
    80002d82:	6161                	addi	sp,sp,80
    80002d84:	8082                	ret

0000000080002d86 <nice>:

int nice(int pid, int priority) {
    80002d86:	1141                	addi	sp,sp,-16
    80002d88:	e422                	sd	s0,8(sp)
    80002d8a:	0800                	addi	s0,sp,16
  return -1;
}
    80002d8c:	557d                	li	a0,-1
    80002d8e:	6422                	ld	s0,8(sp)
    80002d90:	0141                	addi	sp,sp,16
    80002d92:	8082                	ret

0000000080002d94 <swtch>:
    80002d94:	00153023          	sd	ra,0(a0)
    80002d98:	00253423          	sd	sp,8(a0)
    80002d9c:	e900                	sd	s0,16(a0)
    80002d9e:	ed04                	sd	s1,24(a0)
    80002da0:	03253023          	sd	s2,32(a0)
    80002da4:	03353423          	sd	s3,40(a0)
    80002da8:	03453823          	sd	s4,48(a0)
    80002dac:	03553c23          	sd	s5,56(a0)
    80002db0:	05653023          	sd	s6,64(a0)
    80002db4:	05753423          	sd	s7,72(a0)
    80002db8:	05853823          	sd	s8,80(a0)
    80002dbc:	05953c23          	sd	s9,88(a0)
    80002dc0:	07a53023          	sd	s10,96(a0)
    80002dc4:	07b53423          	sd	s11,104(a0)
    80002dc8:	0005b083          	ld	ra,0(a1)
    80002dcc:	0085b103          	ld	sp,8(a1)
    80002dd0:	6980                	ld	s0,16(a1)
    80002dd2:	6d84                	ld	s1,24(a1)
    80002dd4:	0205b903          	ld	s2,32(a1)
    80002dd8:	0285b983          	ld	s3,40(a1)
    80002ddc:	0305ba03          	ld	s4,48(a1)
    80002de0:	0385ba83          	ld	s5,56(a1)
    80002de4:	0405bb03          	ld	s6,64(a1)
    80002de8:	0485bb83          	ld	s7,72(a1)
    80002dec:	0505bc03          	ld	s8,80(a1)
    80002df0:	0585bc83          	ld	s9,88(a1)
    80002df4:	0605bd03          	ld	s10,96(a1)
    80002df8:	0685bd83          	ld	s11,104(a1)
    80002dfc:	8082                	ret

0000000080002dfe <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002dfe:	1141                	addi	sp,sp,-16
    80002e00:	e422                	sd	s0,8(sp)
    80002e02:	0800                	addi	s0,sp,16
    80002e04:	872a                	mv	a4,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002e06:	57fd                	li	a5,-1
    80002e08:	8385                	srli	a5,a5,0x1
    80002e0a:	8fe9                	and	a5,a5,a0
  if (interrupt) {
    80002e0c:	04054c63          	bltz	a0,80002e64 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002e10:	5685                	li	a3,-31
    80002e12:	8285                	srli	a3,a3,0x1
    80002e14:	8ee9                	and	a3,a3,a0
    80002e16:	caad                	beqz	a3,80002e88 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002e18:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002e1a:	00006517          	auipc	a0,0x6
    80002e1e:	8a650513          	addi	a0,a0,-1882 # 800086c0 <userret+0x630>
    } else if (code <= 23) {
    80002e22:	06f6f063          	bleu	a5,a3,80002e82 <scause_desc+0x84>
    } else if (code <= 31) {
    80002e26:	fc100693          	li	a3,-63
    80002e2a:	8285                	srli	a3,a3,0x1
    80002e2c:	8ef9                	and	a3,a3,a4
      return "<reserved for custom use>";
    80002e2e:	00006517          	auipc	a0,0x6
    80002e32:	8ba50513          	addi	a0,a0,-1862 # 800086e8 <userret+0x658>
    } else if (code <= 31) {
    80002e36:	c6b1                	beqz	a3,80002e82 <scause_desc+0x84>
    } else if (code <= 47) {
    80002e38:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    80002e3c:	00006517          	auipc	a0,0x6
    80002e40:	88450513          	addi	a0,a0,-1916 # 800086c0 <userret+0x630>
    } else if (code <= 47) {
    80002e44:	02f6ff63          	bleu	a5,a3,80002e82 <scause_desc+0x84>
    } else if (code <= 63) {
    80002e48:	f8100513          	li	a0,-127
    80002e4c:	8105                	srli	a0,a0,0x1
    80002e4e:	8f69                	and	a4,a4,a0
      return "<reserved for custom use>";
    80002e50:	00006517          	auipc	a0,0x6
    80002e54:	89850513          	addi	a0,a0,-1896 # 800086e8 <userret+0x658>
    } else if (code <= 63) {
    80002e58:	c70d                	beqz	a4,80002e82 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    80002e5a:	00006517          	auipc	a0,0x6
    80002e5e:	86650513          	addi	a0,a0,-1946 # 800086c0 <userret+0x630>
    80002e62:	a005                	j	80002e82 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    80002e64:	5505                	li	a0,-31
    80002e66:	8105                	srli	a0,a0,0x1
    80002e68:	8f69                	and	a4,a4,a0
      return "<reserved for platform use>";
    80002e6a:	00006517          	auipc	a0,0x6
    80002e6e:	89e50513          	addi	a0,a0,-1890 # 80008708 <userret+0x678>
    if (code < NELEM(intr_desc)) {
    80002e72:	eb01                	bnez	a4,80002e82 <scause_desc+0x84>
      return intr_desc[code];
    80002e74:	078e                	slli	a5,a5,0x3
    80002e76:	00006717          	auipc	a4,0x6
    80002e7a:	0ba70713          	addi	a4,a4,186 # 80008f30 <intr_desc.1654>
    80002e7e:	97ba                	add	a5,a5,a4
    80002e80:	6388                	ld	a0,0(a5)
    }
  }
}
    80002e82:	6422                	ld	s0,8(sp)
    80002e84:	0141                	addi	sp,sp,16
    80002e86:	8082                	ret
      return nointr_desc[code];
    80002e88:	078e                	slli	a5,a5,0x3
    80002e8a:	00006717          	auipc	a4,0x6
    80002e8e:	0a670713          	addi	a4,a4,166 # 80008f30 <intr_desc.1654>
    80002e92:	97ba                	add	a5,a5,a4
    80002e94:	63c8                	ld	a0,128(a5)
    80002e96:	b7f5                	j	80002e82 <scause_desc+0x84>

0000000080002e98 <trapinit>:
{
    80002e98:	1141                	addi	sp,sp,-16
    80002e9a:	e406                	sd	ra,8(sp)
    80002e9c:	e022                	sd	s0,0(sp)
    80002e9e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002ea0:	00006597          	auipc	a1,0x6
    80002ea4:	88858593          	addi	a1,a1,-1912 # 80008728 <userret+0x698>
    80002ea8:	00019517          	auipc	a0,0x19
    80002eac:	1f050513          	addi	a0,a0,496 # 8001c098 <tickslock>
    80002eb0:	ffffe097          	auipc	ra,0xffffe
    80002eb4:	c9c080e7          	jalr	-868(ra) # 80000b4c <initlock>
}
    80002eb8:	60a2                	ld	ra,8(sp)
    80002eba:	6402                	ld	s0,0(sp)
    80002ebc:	0141                	addi	sp,sp,16
    80002ebe:	8082                	ret

0000000080002ec0 <trapinithart>:
{
    80002ec0:	1141                	addi	sp,sp,-16
    80002ec2:	e422                	sd	s0,8(sp)
    80002ec4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ec6:	00003797          	auipc	a5,0x3
    80002eca:	74a78793          	addi	a5,a5,1866 # 80006610 <kernelvec>
    80002ece:	10579073          	csrw	stvec,a5
}
    80002ed2:	6422                	ld	s0,8(sp)
    80002ed4:	0141                	addi	sp,sp,16
    80002ed6:	8082                	ret

0000000080002ed8 <usertrapret>:
{
    80002ed8:	1141                	addi	sp,sp,-16
    80002eda:	e406                	sd	ra,8(sp)
    80002edc:	e022                	sd	s0,0(sp)
    80002ede:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ee0:	fffff097          	auipc	ra,0xfffff
    80002ee4:	160080e7          	jalr	352(ra) # 80002040 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ee8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002eec:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002eee:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002ef2:	00005617          	auipc	a2,0x5
    80002ef6:	10e60613          	addi	a2,a2,270 # 80008000 <trampoline>
    80002efa:	00005697          	auipc	a3,0x5
    80002efe:	10668693          	addi	a3,a3,262 # 80008000 <trampoline>
    80002f02:	8e91                	sub	a3,a3,a2
    80002f04:	040007b7          	lui	a5,0x4000
    80002f08:	17fd                	addi	a5,a5,-1
    80002f0a:	07b2                	slli	a5,a5,0xc
    80002f0c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f0e:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002f12:	7938                	ld	a4,112(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002f14:	180026f3          	csrr	a3,satp
    80002f18:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002f1a:	7938                	ld	a4,112(a0)
    80002f1c:	6d34                	ld	a3,88(a0)
    80002f1e:	6585                	lui	a1,0x1
    80002f20:	96ae                	add	a3,a3,a1
    80002f22:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002f24:	7938                	ld	a4,112(a0)
    80002f26:	00000697          	auipc	a3,0x0
    80002f2a:	18468693          	addi	a3,a3,388 # 800030aa <usertrap>
    80002f2e:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    80002f30:	7938                	ld	a4,112(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002f32:	8692                	mv	a3,tp
    80002f34:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f36:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002f3a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002f3e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f42:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    80002f46:	7938                	ld	a4,112(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f48:	6f18                	ld	a4,24(a4)
    80002f4a:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002f4e:	752c                	ld	a1,104(a0)
    80002f50:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002f52:	00005717          	auipc	a4,0x5
    80002f56:	13e70713          	addi	a4,a4,318 # 80008090 <userret>
    80002f5a:	8f11                	sub	a4,a4,a2
    80002f5c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002f5e:	577d                	li	a4,-1
    80002f60:	177e                	slli	a4,a4,0x3f
    80002f62:	8dd9                	or	a1,a1,a4
    80002f64:	02000537          	lui	a0,0x2000
    80002f68:	157d                	addi	a0,a0,-1
    80002f6a:	0536                	slli	a0,a0,0xd
    80002f6c:	9782                	jalr	a5
}
    80002f6e:	60a2                	ld	ra,8(sp)
    80002f70:	6402                	ld	s0,0(sp)
    80002f72:	0141                	addi	sp,sp,16
    80002f74:	8082                	ret

0000000080002f76 <clockintr>:
{
    80002f76:	1141                	addi	sp,sp,-16
    80002f78:	e406                	sd	ra,8(sp)
    80002f7a:	e022                	sd	s0,0(sp)
    80002f7c:	0800                	addi	s0,sp,16
  acquire(&watchdog_lock);
    80002f7e:	0002b517          	auipc	a0,0x2b
    80002f82:	0b250513          	addi	a0,a0,178 # 8002e030 <watchdog_lock>
    80002f86:	ffffe097          	auipc	ra,0xffffe
    80002f8a:	d34080e7          	jalr	-716(ra) # 80000cba <acquire>
  acquire(&tickslock);
    80002f8e:	00019517          	auipc	a0,0x19
    80002f92:	10a50513          	addi	a0,a0,266 # 8001c098 <tickslock>
    80002f96:	ffffe097          	auipc	ra,0xffffe
    80002f9a:	d24080e7          	jalr	-732(ra) # 80000cba <acquire>
  if (watchdog_time && ticks - watchdog_value > watchdog_time){
    80002f9e:	0002b797          	auipc	a5,0x2b
    80002fa2:	10678793          	addi	a5,a5,262 # 8002e0a4 <watchdog_time>
    80002fa6:	439c                	lw	a5,0(a5)
    80002fa8:	cf99                	beqz	a5,80002fc6 <clockintr+0x50>
    80002faa:	0002b717          	auipc	a4,0x2b
    80002fae:	0de70713          	addi	a4,a4,222 # 8002e088 <ticks>
    80002fb2:	4318                	lw	a4,0(a4)
    80002fb4:	0002b697          	auipc	a3,0x2b
    80002fb8:	0f468693          	addi	a3,a3,244 # 8002e0a8 <watchdog_value>
    80002fbc:	4294                	lw	a3,0(a3)
    80002fbe:	9f15                	subw	a4,a4,a3
    80002fc0:	2781                	sext.w	a5,a5
    80002fc2:	04e7e163          	bltu	a5,a4,80003004 <clockintr+0x8e>
  ticks++;
    80002fc6:	0002b517          	auipc	a0,0x2b
    80002fca:	0c250513          	addi	a0,a0,194 # 8002e088 <ticks>
    80002fce:	411c                	lw	a5,0(a0)
    80002fd0:	2785                	addiw	a5,a5,1
    80002fd2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002fd4:	00000097          	auipc	ra,0x0
    80002fd8:	ae4080e7          	jalr	-1308(ra) # 80002ab8 <wakeup>
  release(&tickslock);
    80002fdc:	00019517          	auipc	a0,0x19
    80002fe0:	0bc50513          	addi	a0,a0,188 # 8001c098 <tickslock>
    80002fe4:	ffffe097          	auipc	ra,0xffffe
    80002fe8:	f22080e7          	jalr	-222(ra) # 80000f06 <release>
  release(&watchdog_lock);
    80002fec:	0002b517          	auipc	a0,0x2b
    80002ff0:	04450513          	addi	a0,a0,68 # 8002e030 <watchdog_lock>
    80002ff4:	ffffe097          	auipc	ra,0xffffe
    80002ff8:	f12080e7          	jalr	-238(ra) # 80000f06 <release>
}
    80002ffc:	60a2                	ld	ra,8(sp)
    80002ffe:	6402                	ld	s0,0(sp)
    80003000:	0141                	addi	sp,sp,16
    80003002:	8082                	ret
    panic("watchdog !!!");
    80003004:	00005517          	auipc	a0,0x5
    80003008:	72c50513          	addi	a0,a0,1836 # 80008730 <userret+0x6a0>
    8000300c:	ffffd097          	auipc	ra,0xffffd
    80003010:	778080e7          	jalr	1912(ra) # 80000784 <panic>

0000000080003014 <devintr>:
{
    80003014:	1101                	addi	sp,sp,-32
    80003016:	ec06                	sd	ra,24(sp)
    80003018:	e822                	sd	s0,16(sp)
    8000301a:	e426                	sd	s1,8(sp)
    8000301c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000301e:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80003022:	00074d63          	bltz	a4,8000303c <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80003026:	57fd                	li	a5,-1
    80003028:	17fe                	slli	a5,a5,0x3f
    8000302a:	0785                	addi	a5,a5,1
    return 0;
    8000302c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000302e:	04f70d63          	beq	a4,a5,80003088 <devintr+0x74>
}
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	64a2                	ld	s1,8(sp)
    80003038:	6105                	addi	sp,sp,32
    8000303a:	8082                	ret
     (scause & 0xff) == 9){
    8000303c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80003040:	46a5                	li	a3,9
    80003042:	fed792e3          	bne	a5,a3,80003026 <devintr+0x12>
    int irq = plic_claim();
    80003046:	00003097          	auipc	ra,0x3
    8000304a:	6d2080e7          	jalr	1746(ra) # 80006718 <plic_claim>
    8000304e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003050:	47a9                	li	a5,10
    80003052:	00f50a63          	beq	a0,a5,80003066 <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80003056:	fff5079b          	addiw	a5,a0,-1
    8000305a:	4705                	li	a4,1
    8000305c:	00f77a63          	bleu	a5,a4,80003070 <devintr+0x5c>
    return 1;
    80003060:	4505                	li	a0,1
    if(irq)
    80003062:	d8e1                	beqz	s1,80003032 <devintr+0x1e>
    80003064:	a819                	j	8000307a <devintr+0x66>
      uartintr();
    80003066:	ffffe097          	auipc	ra,0xffffe
    8000306a:	a60080e7          	jalr	-1440(ra) # 80000ac6 <uartintr>
    8000306e:	a031                	j	8000307a <devintr+0x66>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    80003070:	853e                	mv	a0,a5
    80003072:	00004097          	auipc	ra,0x4
    80003076:	c9c080e7          	jalr	-868(ra) # 80006d0e <virtio_disk_intr>
      plic_complete(irq);
    8000307a:	8526                	mv	a0,s1
    8000307c:	00003097          	auipc	ra,0x3
    80003080:	6c0080e7          	jalr	1728(ra) # 8000673c <plic_complete>
    return 1;
    80003084:	4505                	li	a0,1
    80003086:	b775                	j	80003032 <devintr+0x1e>
    if(cpuid() == 0){
    80003088:	fffff097          	auipc	ra,0xfffff
    8000308c:	f8c080e7          	jalr	-116(ra) # 80002014 <cpuid>
    80003090:	c901                	beqz	a0,800030a0 <devintr+0x8c>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003092:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003096:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003098:	14479073          	csrw	sip,a5
    return 2;
    8000309c:	4509                	li	a0,2
    8000309e:	bf51                	j	80003032 <devintr+0x1e>
      clockintr();
    800030a0:	00000097          	auipc	ra,0x0
    800030a4:	ed6080e7          	jalr	-298(ra) # 80002f76 <clockintr>
    800030a8:	b7ed                	j	80003092 <devintr+0x7e>

00000000800030aa <usertrap>:
{
    800030aa:	7179                	addi	sp,sp,-48
    800030ac:	f406                	sd	ra,40(sp)
    800030ae:	f022                	sd	s0,32(sp)
    800030b0:	ec26                	sd	s1,24(sp)
    800030b2:	e84a                	sd	s2,16(sp)
    800030b4:	e44e                	sd	s3,8(sp)
    800030b6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030b8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800030bc:	1007f793          	andi	a5,a5,256
    800030c0:	e3b5                	bnez	a5,80003124 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800030c2:	00003797          	auipc	a5,0x3
    800030c6:	54e78793          	addi	a5,a5,1358 # 80006610 <kernelvec>
    800030ca:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800030ce:	fffff097          	auipc	ra,0xfffff
    800030d2:	f72080e7          	jalr	-142(ra) # 80002040 <myproc>
    800030d6:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    800030d8:	793c                	ld	a5,112(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030da:	14102773          	csrr	a4,sepc
    800030de:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030e0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800030e4:	47a1                	li	a5,8
    800030e6:	04f71d63          	bne	a4,a5,80003140 <usertrap+0x96>
    if(p->killed)
    800030ea:	453c                	lw	a5,72(a0)
    800030ec:	e7a1                	bnez	a5,80003134 <usertrap+0x8a>
    p->tf->epc += 4;
    800030ee:	78b8                	ld	a4,112(s1)
    800030f0:	6f1c                	ld	a5,24(a4)
    800030f2:	0791                	addi	a5,a5,4
    800030f4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800030fa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030fe:	10079073          	csrw	sstatus,a5
    syscall();
    80003102:	00000097          	auipc	ra,0x0
    80003106:	304080e7          	jalr	772(ra) # 80003406 <syscall>
  if(p->killed)
    8000310a:	44bc                	lw	a5,72(s1)
    8000310c:	e3cd                	bnez	a5,800031ae <usertrap+0x104>
  usertrapret();
    8000310e:	00000097          	auipc	ra,0x0
    80003112:	dca080e7          	jalr	-566(ra) # 80002ed8 <usertrapret>
}
    80003116:	70a2                	ld	ra,40(sp)
    80003118:	7402                	ld	s0,32(sp)
    8000311a:	64e2                	ld	s1,24(sp)
    8000311c:	6942                	ld	s2,16(sp)
    8000311e:	69a2                	ld	s3,8(sp)
    80003120:	6145                	addi	sp,sp,48
    80003122:	8082                	ret
    panic("usertrap: not from user mode");
    80003124:	00005517          	auipc	a0,0x5
    80003128:	61c50513          	addi	a0,a0,1564 # 80008740 <userret+0x6b0>
    8000312c:	ffffd097          	auipc	ra,0xffffd
    80003130:	658080e7          	jalr	1624(ra) # 80000784 <panic>
      exit(-1);
    80003134:	557d                	li	a0,-1
    80003136:	fffff097          	auipc	ra,0xfffff
    8000313a:	676080e7          	jalr	1654(ra) # 800027ac <exit>
    8000313e:	bf45                	j	800030ee <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80003140:	00000097          	auipc	ra,0x0
    80003144:	ed4080e7          	jalr	-300(ra) # 80003014 <devintr>
    80003148:	892a                	mv	s2,a0
    8000314a:	c501                	beqz	a0,80003152 <usertrap+0xa8>
  if(p->killed)
    8000314c:	44bc                	lw	a5,72(s1)
    8000314e:	cba1                	beqz	a5,8000319e <usertrap+0xf4>
    80003150:	a091                	j	80003194 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003152:	142029f3          	csrr	s3,scause
    80003156:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    8000315a:	00000097          	auipc	ra,0x0
    8000315e:	ca4080e7          	jalr	-860(ra) # 80002dfe <scause_desc>
    80003162:	48b4                	lw	a3,80(s1)
    80003164:	862a                	mv	a2,a0
    80003166:	85ce                	mv	a1,s3
    80003168:	00005517          	auipc	a0,0x5
    8000316c:	5f850513          	addi	a0,a0,1528 # 80008760 <userret+0x6d0>
    80003170:	ffffe097          	auipc	ra,0xffffe
    80003174:	82c080e7          	jalr	-2004(ra) # 8000099c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003178:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000317c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003180:	00005517          	auipc	a0,0x5
    80003184:	61050513          	addi	a0,a0,1552 # 80008790 <userret+0x700>
    80003188:	ffffe097          	auipc	ra,0xffffe
    8000318c:	814080e7          	jalr	-2028(ra) # 8000099c <printf>
    p->killed = 1;
    80003190:	4785                	li	a5,1
    80003192:	c4bc                	sw	a5,72(s1)
    exit(-1);
    80003194:	557d                	li	a0,-1
    80003196:	fffff097          	auipc	ra,0xfffff
    8000319a:	616080e7          	jalr	1558(ra) # 800027ac <exit>
  if(which_dev == 2)
    8000319e:	4789                	li	a5,2
    800031a0:	f6f917e3          	bne	s2,a5,8000310e <usertrap+0x64>
    yield();
    800031a4:	fffff097          	auipc	ra,0xfffff
    800031a8:	752080e7          	jalr	1874(ra) # 800028f6 <yield>
    800031ac:	b78d                	j	8000310e <usertrap+0x64>
  int which_dev = 0;
    800031ae:	4901                	li	s2,0
    800031b0:	b7d5                	j	80003194 <usertrap+0xea>

00000000800031b2 <kerneltrap>:
{
    800031b2:	7179                	addi	sp,sp,-48
    800031b4:	f406                	sd	ra,40(sp)
    800031b6:	f022                	sd	s0,32(sp)
    800031b8:	ec26                	sd	s1,24(sp)
    800031ba:	e84a                	sd	s2,16(sp)
    800031bc:	e44e                	sd	s3,8(sp)
    800031be:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800031c0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031c4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800031c8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800031cc:	1004f793          	andi	a5,s1,256
    800031d0:	cb85                	beqz	a5,80003200 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031d2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800031d6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800031d8:	ef85                	bnez	a5,80003210 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800031da:	00000097          	auipc	ra,0x0
    800031de:	e3a080e7          	jalr	-454(ra) # 80003014 <devintr>
    800031e2:	cd1d                	beqz	a0,80003220 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800031e4:	4789                	li	a5,2
    800031e6:	08f50063          	beq	a0,a5,80003266 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800031ea:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800031ee:	10049073          	csrw	sstatus,s1
}
    800031f2:	70a2                	ld	ra,40(sp)
    800031f4:	7402                	ld	s0,32(sp)
    800031f6:	64e2                	ld	s1,24(sp)
    800031f8:	6942                	ld	s2,16(sp)
    800031fa:	69a2                	ld	s3,8(sp)
    800031fc:	6145                	addi	sp,sp,48
    800031fe:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003200:	00005517          	auipc	a0,0x5
    80003204:	5b050513          	addi	a0,a0,1456 # 800087b0 <userret+0x720>
    80003208:	ffffd097          	auipc	ra,0xffffd
    8000320c:	57c080e7          	jalr	1404(ra) # 80000784 <panic>
    panic("kerneltrap: interrupts enabled");
    80003210:	00005517          	auipc	a0,0x5
    80003214:	5c850513          	addi	a0,a0,1480 # 800087d8 <userret+0x748>
    80003218:	ffffd097          	auipc	ra,0xffffd
    8000321c:	56c080e7          	jalr	1388(ra) # 80000784 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80003220:	854e                	mv	a0,s3
    80003222:	00000097          	auipc	ra,0x0
    80003226:	bdc080e7          	jalr	-1060(ra) # 80002dfe <scause_desc>
    8000322a:	862a                	mv	a2,a0
    8000322c:	85ce                	mv	a1,s3
    8000322e:	00005517          	auipc	a0,0x5
    80003232:	5ca50513          	addi	a0,a0,1482 # 800087f8 <userret+0x768>
    80003236:	ffffd097          	auipc	ra,0xffffd
    8000323a:	766080e7          	jalr	1894(ra) # 8000099c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000323e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003242:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003246:	00005517          	auipc	a0,0x5
    8000324a:	5c250513          	addi	a0,a0,1474 # 80008808 <userret+0x778>
    8000324e:	ffffd097          	auipc	ra,0xffffd
    80003252:	74e080e7          	jalr	1870(ra) # 8000099c <printf>
    panic("kerneltrap");
    80003256:	00005517          	auipc	a0,0x5
    8000325a:	5ca50513          	addi	a0,a0,1482 # 80008820 <userret+0x790>
    8000325e:	ffffd097          	auipc	ra,0xffffd
    80003262:	526080e7          	jalr	1318(ra) # 80000784 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003266:	fffff097          	auipc	ra,0xfffff
    8000326a:	dda080e7          	jalr	-550(ra) # 80002040 <myproc>
    8000326e:	dd35                	beqz	a0,800031ea <kerneltrap+0x38>
    80003270:	fffff097          	auipc	ra,0xfffff
    80003274:	dd0080e7          	jalr	-560(ra) # 80002040 <myproc>
    80003278:	5918                	lw	a4,48(a0)
    8000327a:	478d                	li	a5,3
    8000327c:	f6f717e3          	bne	a4,a5,800031ea <kerneltrap+0x38>
    yield();
    80003280:	fffff097          	auipc	ra,0xfffff
    80003284:	676080e7          	jalr	1654(ra) # 800028f6 <yield>
    80003288:	b78d                	j	800031ea <kerneltrap+0x38>

000000008000328a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000328a:	1101                	addi	sp,sp,-32
    8000328c:	ec06                	sd	ra,24(sp)
    8000328e:	e822                	sd	s0,16(sp)
    80003290:	e426                	sd	s1,8(sp)
    80003292:	1000                	addi	s0,sp,32
    80003294:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003296:	fffff097          	auipc	ra,0xfffff
    8000329a:	daa080e7          	jalr	-598(ra) # 80002040 <myproc>
  switch (n) {
    8000329e:	4795                	li	a5,5
    800032a0:	0497e363          	bltu	a5,s1,800032e6 <argraw+0x5c>
    800032a4:	1482                	slli	s1,s1,0x20
    800032a6:	9081                	srli	s1,s1,0x20
    800032a8:	048a                	slli	s1,s1,0x2
    800032aa:	00006717          	auipc	a4,0x6
    800032ae:	d8670713          	addi	a4,a4,-634 # 80009030 <nointr_desc.1655+0x80>
    800032b2:	94ba                	add	s1,s1,a4
    800032b4:	409c                	lw	a5,0(s1)
    800032b6:	97ba                	add	a5,a5,a4
    800032b8:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    800032ba:	793c                	ld	a5,112(a0)
    800032bc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    800032be:	60e2                	ld	ra,24(sp)
    800032c0:	6442                	ld	s0,16(sp)
    800032c2:	64a2                	ld	s1,8(sp)
    800032c4:	6105                	addi	sp,sp,32
    800032c6:	8082                	ret
    return p->tf->a1;
    800032c8:	793c                	ld	a5,112(a0)
    800032ca:	7fa8                	ld	a0,120(a5)
    800032cc:	bfcd                	j	800032be <argraw+0x34>
    return p->tf->a2;
    800032ce:	793c                	ld	a5,112(a0)
    800032d0:	63c8                	ld	a0,128(a5)
    800032d2:	b7f5                	j	800032be <argraw+0x34>
    return p->tf->a3;
    800032d4:	793c                	ld	a5,112(a0)
    800032d6:	67c8                	ld	a0,136(a5)
    800032d8:	b7dd                	j	800032be <argraw+0x34>
    return p->tf->a4;
    800032da:	793c                	ld	a5,112(a0)
    800032dc:	6bc8                	ld	a0,144(a5)
    800032de:	b7c5                	j	800032be <argraw+0x34>
    return p->tf->a5;
    800032e0:	793c                	ld	a5,112(a0)
    800032e2:	6fc8                	ld	a0,152(a5)
    800032e4:	bfe9                	j	800032be <argraw+0x34>
  panic("argraw");
    800032e6:	00005517          	auipc	a0,0x5
    800032ea:	74250513          	addi	a0,a0,1858 # 80008a28 <userret+0x998>
    800032ee:	ffffd097          	auipc	ra,0xffffd
    800032f2:	496080e7          	jalr	1174(ra) # 80000784 <panic>

00000000800032f6 <fetchaddr>:
{
    800032f6:	1101                	addi	sp,sp,-32
    800032f8:	ec06                	sd	ra,24(sp)
    800032fa:	e822                	sd	s0,16(sp)
    800032fc:	e426                	sd	s1,8(sp)
    800032fe:	e04a                	sd	s2,0(sp)
    80003300:	1000                	addi	s0,sp,32
    80003302:	84aa                	mv	s1,a0
    80003304:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003306:	fffff097          	auipc	ra,0xfffff
    8000330a:	d3a080e7          	jalr	-710(ra) # 80002040 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    8000330e:	713c                	ld	a5,96(a0)
    80003310:	02f4f963          	bleu	a5,s1,80003342 <fetchaddr+0x4c>
    80003314:	00848713          	addi	a4,s1,8
    80003318:	02e7e763          	bltu	a5,a4,80003346 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000331c:	46a1                	li	a3,8
    8000331e:	8626                	mv	a2,s1
    80003320:	85ca                	mv	a1,s2
    80003322:	7528                	ld	a0,104(a0)
    80003324:	fffff097          	auipc	ra,0xfffff
    80003328:	986080e7          	jalr	-1658(ra) # 80001caa <copyin>
    8000332c:	00a03533          	snez	a0,a0
    80003330:	40a0053b          	negw	a0,a0
    80003334:	2501                	sext.w	a0,a0
}
    80003336:	60e2                	ld	ra,24(sp)
    80003338:	6442                	ld	s0,16(sp)
    8000333a:	64a2                	ld	s1,8(sp)
    8000333c:	6902                	ld	s2,0(sp)
    8000333e:	6105                	addi	sp,sp,32
    80003340:	8082                	ret
    return -1;
    80003342:	557d                	li	a0,-1
    80003344:	bfcd                	j	80003336 <fetchaddr+0x40>
    80003346:	557d                	li	a0,-1
    80003348:	b7fd                	j	80003336 <fetchaddr+0x40>

000000008000334a <fetchstr>:
{
    8000334a:	7179                	addi	sp,sp,-48
    8000334c:	f406                	sd	ra,40(sp)
    8000334e:	f022                	sd	s0,32(sp)
    80003350:	ec26                	sd	s1,24(sp)
    80003352:	e84a                	sd	s2,16(sp)
    80003354:	e44e                	sd	s3,8(sp)
    80003356:	1800                	addi	s0,sp,48
    80003358:	892a                	mv	s2,a0
    8000335a:	84ae                	mv	s1,a1
    8000335c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000335e:	fffff097          	auipc	ra,0xfffff
    80003362:	ce2080e7          	jalr	-798(ra) # 80002040 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003366:	86ce                	mv	a3,s3
    80003368:	864a                	mv	a2,s2
    8000336a:	85a6                	mv	a1,s1
    8000336c:	7528                	ld	a0,104(a0)
    8000336e:	fffff097          	auipc	ra,0xfffff
    80003372:	9ca080e7          	jalr	-1590(ra) # 80001d38 <copyinstr>
  if(err < 0)
    80003376:	00054763          	bltz	a0,80003384 <fetchstr+0x3a>
  return strlen(buf);
    8000337a:	8526                	mv	a0,s1
    8000337c:	ffffe097          	auipc	ra,0xffffe
    80003380:	f5c080e7          	jalr	-164(ra) # 800012d8 <strlen>
}
    80003384:	70a2                	ld	ra,40(sp)
    80003386:	7402                	ld	s0,32(sp)
    80003388:	64e2                	ld	s1,24(sp)
    8000338a:	6942                	ld	s2,16(sp)
    8000338c:	69a2                	ld	s3,8(sp)
    8000338e:	6145                	addi	sp,sp,48
    80003390:	8082                	ret

0000000080003392 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003392:	1101                	addi	sp,sp,-32
    80003394:	ec06                	sd	ra,24(sp)
    80003396:	e822                	sd	s0,16(sp)
    80003398:	e426                	sd	s1,8(sp)
    8000339a:	1000                	addi	s0,sp,32
    8000339c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000339e:	00000097          	auipc	ra,0x0
    800033a2:	eec080e7          	jalr	-276(ra) # 8000328a <argraw>
    800033a6:	c088                	sw	a0,0(s1)
  return 0;
}
    800033a8:	4501                	li	a0,0
    800033aa:	60e2                	ld	ra,24(sp)
    800033ac:	6442                	ld	s0,16(sp)
    800033ae:	64a2                	ld	s1,8(sp)
    800033b0:	6105                	addi	sp,sp,32
    800033b2:	8082                	ret

00000000800033b4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800033b4:	1101                	addi	sp,sp,-32
    800033b6:	ec06                	sd	ra,24(sp)
    800033b8:	e822                	sd	s0,16(sp)
    800033ba:	e426                	sd	s1,8(sp)
    800033bc:	1000                	addi	s0,sp,32
    800033be:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800033c0:	00000097          	auipc	ra,0x0
    800033c4:	eca080e7          	jalr	-310(ra) # 8000328a <argraw>
    800033c8:	e088                	sd	a0,0(s1)
  return 0;
}
    800033ca:	4501                	li	a0,0
    800033cc:	60e2                	ld	ra,24(sp)
    800033ce:	6442                	ld	s0,16(sp)
    800033d0:	64a2                	ld	s1,8(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret

00000000800033d6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800033d6:	1101                	addi	sp,sp,-32
    800033d8:	ec06                	sd	ra,24(sp)
    800033da:	e822                	sd	s0,16(sp)
    800033dc:	e426                	sd	s1,8(sp)
    800033de:	e04a                	sd	s2,0(sp)
    800033e0:	1000                	addi	s0,sp,32
    800033e2:	84ae                	mv	s1,a1
    800033e4:	8932                	mv	s2,a2
  *ip = argraw(n);
    800033e6:	00000097          	auipc	ra,0x0
    800033ea:	ea4080e7          	jalr	-348(ra) # 8000328a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800033ee:	864a                	mv	a2,s2
    800033f0:	85a6                	mv	a1,s1
    800033f2:	00000097          	auipc	ra,0x0
    800033f6:	f58080e7          	jalr	-168(ra) # 8000334a <fetchstr>
}
    800033fa:	60e2                	ld	ra,24(sp)
    800033fc:	6442                	ld	s0,16(sp)
    800033fe:	64a2                	ld	s1,8(sp)
    80003400:	6902                	ld	s2,0(sp)
    80003402:	6105                	addi	sp,sp,32
    80003404:	8082                	ret

0000000080003406 <syscall>:
[SYS_release_mutex]  sys_release_mutex,
};

void
syscall(void)
{
    80003406:	1101                	addi	sp,sp,-32
    80003408:	ec06                	sd	ra,24(sp)
    8000340a:	e822                	sd	s0,16(sp)
    8000340c:	e426                	sd	s1,8(sp)
    8000340e:	e04a                	sd	s2,0(sp)
    80003410:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003412:	fffff097          	auipc	ra,0xfffff
    80003416:	c2e080e7          	jalr	-978(ra) # 80002040 <myproc>
    8000341a:	84aa                	mv	s1,a0

  num = p->tf->a7;
    8000341c:	07053903          	ld	s2,112(a0)
    80003420:	0a893783          	ld	a5,168(s2)
    80003424:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003428:	37fd                	addiw	a5,a5,-1
    8000342a:	4765                	li	a4,25
    8000342c:	00f76f63          	bltu	a4,a5,8000344a <syscall+0x44>
    80003430:	00369713          	slli	a4,a3,0x3
    80003434:	00006797          	auipc	a5,0x6
    80003438:	c1478793          	addi	a5,a5,-1004 # 80009048 <syscalls>
    8000343c:	97ba                	add	a5,a5,a4
    8000343e:	639c                	ld	a5,0(a5)
    80003440:	c789                	beqz	a5,8000344a <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80003442:	9782                	jalr	a5
    80003444:	06a93823          	sd	a0,112(s2)
    80003448:	a839                	j	80003466 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000344a:	17048613          	addi	a2,s1,368
    8000344e:	48ac                	lw	a1,80(s1)
    80003450:	00005517          	auipc	a0,0x5
    80003454:	5e050513          	addi	a0,a0,1504 # 80008a30 <userret+0x9a0>
    80003458:	ffffd097          	auipc	ra,0xffffd
    8000345c:	544080e7          	jalr	1348(ra) # 8000099c <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80003460:	78bc                	ld	a5,112(s1)
    80003462:	577d                	li	a4,-1
    80003464:	fbb8                	sd	a4,112(a5)
  }
}
    80003466:	60e2                	ld	ra,24(sp)
    80003468:	6442                	ld	s0,16(sp)
    8000346a:	64a2                	ld	s1,8(sp)
    8000346c:	6902                	ld	s2,0(sp)
    8000346e:	6105                	addi	sp,sp,32
    80003470:	8082                	ret

0000000080003472 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003472:	1101                	addi	sp,sp,-32
    80003474:	ec06                	sd	ra,24(sp)
    80003476:	e822                	sd	s0,16(sp)
    80003478:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    8000347a:	fec40593          	addi	a1,s0,-20
    8000347e:	4501                	li	a0,0
    80003480:	00000097          	auipc	ra,0x0
    80003484:	f12080e7          	jalr	-238(ra) # 80003392 <argint>
    return -1;
    80003488:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000348a:	00054963          	bltz	a0,8000349c <sys_exit+0x2a>
  exit(n);
    8000348e:	fec42503          	lw	a0,-20(s0)
    80003492:	fffff097          	auipc	ra,0xfffff
    80003496:	31a080e7          	jalr	794(ra) # 800027ac <exit>
  return 0;  // not reached
    8000349a:	4781                	li	a5,0
}
    8000349c:	853e                	mv	a0,a5
    8000349e:	60e2                	ld	ra,24(sp)
    800034a0:	6442                	ld	s0,16(sp)
    800034a2:	6105                	addi	sp,sp,32
    800034a4:	8082                	ret

00000000800034a6 <sys_getpid>:

uint64
sys_getpid(void)
{
    800034a6:	1141                	addi	sp,sp,-16
    800034a8:	e406                	sd	ra,8(sp)
    800034aa:	e022                	sd	s0,0(sp)
    800034ac:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800034ae:	fffff097          	auipc	ra,0xfffff
    800034b2:	b92080e7          	jalr	-1134(ra) # 80002040 <myproc>
}
    800034b6:	4928                	lw	a0,80(a0)
    800034b8:	60a2                	ld	ra,8(sp)
    800034ba:	6402                	ld	s0,0(sp)
    800034bc:	0141                	addi	sp,sp,16
    800034be:	8082                	ret

00000000800034c0 <sys_fork>:

uint64
sys_fork(void)
{
    800034c0:	1141                	addi	sp,sp,-16
    800034c2:	e406                	sd	ra,8(sp)
    800034c4:	e022                	sd	s0,0(sp)
    800034c6:	0800                	addi	s0,sp,16
  return fork();
    800034c8:	fffff097          	auipc	ra,0xfffff
    800034cc:	f40080e7          	jalr	-192(ra) # 80002408 <fork>
}
    800034d0:	60a2                	ld	ra,8(sp)
    800034d2:	6402                	ld	s0,0(sp)
    800034d4:	0141                	addi	sp,sp,16
    800034d6:	8082                	ret

00000000800034d8 <sys_wait>:

uint64
sys_wait(void)
{
    800034d8:	1101                	addi	sp,sp,-32
    800034da:	ec06                	sd	ra,24(sp)
    800034dc:	e822                	sd	s0,16(sp)
    800034de:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800034e0:	fe840593          	addi	a1,s0,-24
    800034e4:	4501                	li	a0,0
    800034e6:	00000097          	auipc	ra,0x0
    800034ea:	ece080e7          	jalr	-306(ra) # 800033b4 <argaddr>
    return -1;
    800034ee:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    800034f0:	00054963          	bltz	a0,80003502 <sys_wait+0x2a>
  return wait(p);
    800034f4:	fe843503          	ld	a0,-24(s0)
    800034f8:	fffff097          	auipc	ra,0xfffff
    800034fc:	4b8080e7          	jalr	1208(ra) # 800029b0 <wait>
    80003500:	87aa                	mv	a5,a0
}
    80003502:	853e                	mv	a0,a5
    80003504:	60e2                	ld	ra,24(sp)
    80003506:	6442                	ld	s0,16(sp)
    80003508:	6105                	addi	sp,sp,32
    8000350a:	8082                	ret

000000008000350c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000350c:	7179                	addi	sp,sp,-48
    8000350e:	f406                	sd	ra,40(sp)
    80003510:	f022                	sd	s0,32(sp)
    80003512:	ec26                	sd	s1,24(sp)
    80003514:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003516:	fdc40593          	addi	a1,s0,-36
    8000351a:	4501                	li	a0,0
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	e76080e7          	jalr	-394(ra) # 80003392 <argint>
    return -1;
    80003524:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003526:	00054f63          	bltz	a0,80003544 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000352a:	fffff097          	auipc	ra,0xfffff
    8000352e:	b16080e7          	jalr	-1258(ra) # 80002040 <myproc>
    80003532:	5124                	lw	s1,96(a0)
  if(growproc(n) < 0)
    80003534:	fdc42503          	lw	a0,-36(s0)
    80003538:	fffff097          	auipc	ra,0xfffff
    8000353c:	e58080e7          	jalr	-424(ra) # 80002390 <growproc>
    80003540:	00054863          	bltz	a0,80003550 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003544:	8526                	mv	a0,s1
    80003546:	70a2                	ld	ra,40(sp)
    80003548:	7402                	ld	s0,32(sp)
    8000354a:	64e2                	ld	s1,24(sp)
    8000354c:	6145                	addi	sp,sp,48
    8000354e:	8082                	ret
    return -1;
    80003550:	54fd                	li	s1,-1
    80003552:	bfcd                	j	80003544 <sys_sbrk+0x38>

0000000080003554 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003554:	7139                	addi	sp,sp,-64
    80003556:	fc06                	sd	ra,56(sp)
    80003558:	f822                	sd	s0,48(sp)
    8000355a:	f426                	sd	s1,40(sp)
    8000355c:	f04a                	sd	s2,32(sp)
    8000355e:	ec4e                	sd	s3,24(sp)
    80003560:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003562:	fcc40593          	addi	a1,s0,-52
    80003566:	4501                	li	a0,0
    80003568:	00000097          	auipc	ra,0x0
    8000356c:	e2a080e7          	jalr	-470(ra) # 80003392 <argint>
    return -1;
    80003570:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003572:	06054763          	bltz	a0,800035e0 <sys_sleep+0x8c>
  acquire(&tickslock);
    80003576:	00019517          	auipc	a0,0x19
    8000357a:	b2250513          	addi	a0,a0,-1246 # 8001c098 <tickslock>
    8000357e:	ffffd097          	auipc	ra,0xffffd
    80003582:	73c080e7          	jalr	1852(ra) # 80000cba <acquire>
  ticks0 = ticks;
    80003586:	0002b797          	auipc	a5,0x2b
    8000358a:	b0278793          	addi	a5,a5,-1278 # 8002e088 <ticks>
    8000358e:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80003592:	fcc42783          	lw	a5,-52(s0)
    80003596:	cf85                	beqz	a5,800035ce <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003598:	00019997          	auipc	s3,0x19
    8000359c:	b0098993          	addi	s3,s3,-1280 # 8001c098 <tickslock>
    800035a0:	0002b497          	auipc	s1,0x2b
    800035a4:	ae848493          	addi	s1,s1,-1304 # 8002e088 <ticks>
    if(myproc()->killed){
    800035a8:	fffff097          	auipc	ra,0xfffff
    800035ac:	a98080e7          	jalr	-1384(ra) # 80002040 <myproc>
    800035b0:	453c                	lw	a5,72(a0)
    800035b2:	ef9d                	bnez	a5,800035f0 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    800035b4:	85ce                	mv	a1,s3
    800035b6:	8526                	mv	a0,s1
    800035b8:	fffff097          	auipc	ra,0xfffff
    800035bc:	37a080e7          	jalr	890(ra) # 80002932 <sleep>
  while(ticks - ticks0 < n){
    800035c0:	409c                	lw	a5,0(s1)
    800035c2:	412787bb          	subw	a5,a5,s2
    800035c6:	fcc42703          	lw	a4,-52(s0)
    800035ca:	fce7efe3          	bltu	a5,a4,800035a8 <sys_sleep+0x54>
  }
  release(&tickslock);
    800035ce:	00019517          	auipc	a0,0x19
    800035d2:	aca50513          	addi	a0,a0,-1334 # 8001c098 <tickslock>
    800035d6:	ffffe097          	auipc	ra,0xffffe
    800035da:	930080e7          	jalr	-1744(ra) # 80000f06 <release>
  return 0;
    800035de:	4781                	li	a5,0
}
    800035e0:	853e                	mv	a0,a5
    800035e2:	70e2                	ld	ra,56(sp)
    800035e4:	7442                	ld	s0,48(sp)
    800035e6:	74a2                	ld	s1,40(sp)
    800035e8:	7902                	ld	s2,32(sp)
    800035ea:	69e2                	ld	s3,24(sp)
    800035ec:	6121                	addi	sp,sp,64
    800035ee:	8082                	ret
      release(&tickslock);
    800035f0:	00019517          	auipc	a0,0x19
    800035f4:	aa850513          	addi	a0,a0,-1368 # 8001c098 <tickslock>
    800035f8:	ffffe097          	auipc	ra,0xffffe
    800035fc:	90e080e7          	jalr	-1778(ra) # 80000f06 <release>
      return -1;
    80003600:	57fd                	li	a5,-1
    80003602:	bff9                	j	800035e0 <sys_sleep+0x8c>

0000000080003604 <sys_nice>:

uint64
sys_nice(void){
    80003604:	1141                	addi	sp,sp,-16
    80003606:	e422                	sd	s0,8(sp)
    80003608:	0800                	addi	s0,sp,16
  return 0;
}
    8000360a:	4501                	li	a0,0
    8000360c:	6422                	ld	s0,8(sp)
    8000360e:	0141                	addi	sp,sp,16
    80003610:	8082                	ret

0000000080003612 <sys_kill>:

uint64
sys_kill(void)
{
    80003612:	1101                	addi	sp,sp,-32
    80003614:	ec06                	sd	ra,24(sp)
    80003616:	e822                	sd	s0,16(sp)
    80003618:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000361a:	fec40593          	addi	a1,s0,-20
    8000361e:	4501                	li	a0,0
    80003620:	00000097          	auipc	ra,0x0
    80003624:	d72080e7          	jalr	-654(ra) # 80003392 <argint>
    return -1;
    80003628:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    8000362a:	00054963          	bltz	a0,8000363c <sys_kill+0x2a>
  return kill(pid);
    8000362e:	fec42503          	lw	a0,-20(s0)
    80003632:	fffff097          	auipc	ra,0xfffff
    80003636:	4f0080e7          	jalr	1264(ra) # 80002b22 <kill>
    8000363a:	87aa                	mv	a5,a0
}
    8000363c:	853e                	mv	a0,a5
    8000363e:	60e2                	ld	ra,24(sp)
    80003640:	6442                	ld	s0,16(sp)
    80003642:	6105                	addi	sp,sp,32
    80003644:	8082                	ret

0000000080003646 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003646:	1101                	addi	sp,sp,-32
    80003648:	ec06                	sd	ra,24(sp)
    8000364a:	e822                	sd	s0,16(sp)
    8000364c:	e426                	sd	s1,8(sp)
    8000364e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003650:	00019517          	auipc	a0,0x19
    80003654:	a4850513          	addi	a0,a0,-1464 # 8001c098 <tickslock>
    80003658:	ffffd097          	auipc	ra,0xffffd
    8000365c:	662080e7          	jalr	1634(ra) # 80000cba <acquire>
  xticks = ticks;
    80003660:	0002b797          	auipc	a5,0x2b
    80003664:	a2878793          	addi	a5,a5,-1496 # 8002e088 <ticks>
    80003668:	4384                	lw	s1,0(a5)
  release(&tickslock);
    8000366a:	00019517          	auipc	a0,0x19
    8000366e:	a2e50513          	addi	a0,a0,-1490 # 8001c098 <tickslock>
    80003672:	ffffe097          	auipc	ra,0xffffe
    80003676:	894080e7          	jalr	-1900(ra) # 80000f06 <release>
  return xticks;
}
    8000367a:	02049513          	slli	a0,s1,0x20
    8000367e:	9101                	srli	a0,a0,0x20
    80003680:	60e2                	ld	ra,24(sp)
    80003682:	6442                	ld	s0,16(sp)
    80003684:	64a2                	ld	s1,8(sp)
    80003686:	6105                	addi	sp,sp,32
    80003688:	8082                	ret

000000008000368a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000368a:	7179                	addi	sp,sp,-48
    8000368c:	f406                	sd	ra,40(sp)
    8000368e:	f022                	sd	s0,32(sp)
    80003690:	ec26                	sd	s1,24(sp)
    80003692:	e84a                	sd	s2,16(sp)
    80003694:	e44e                	sd	s3,8(sp)
    80003696:	e052                	sd	s4,0(sp)
    80003698:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000369a:	00005597          	auipc	a1,0x5
    8000369e:	d6658593          	addi	a1,a1,-666 # 80008400 <userret+0x370>
    800036a2:	00019517          	auipc	a0,0x19
    800036a6:	a2650513          	addi	a0,a0,-1498 # 8001c0c8 <bcache>
    800036aa:	ffffd097          	auipc	ra,0xffffd
    800036ae:	4a2080e7          	jalr	1186(ra) # 80000b4c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800036b2:	00021797          	auipc	a5,0x21
    800036b6:	a1678793          	addi	a5,a5,-1514 # 800240c8 <bcache+0x8000>
    800036ba:	00021717          	auipc	a4,0x21
    800036be:	f5e70713          	addi	a4,a4,-162 # 80024618 <bcache+0x8550>
    800036c2:	5ae7b823          	sd	a4,1456(a5)
  bcache.head.next = &bcache.head;
    800036c6:	5ae7bc23          	sd	a4,1464(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036ca:	00019497          	auipc	s1,0x19
    800036ce:	a2e48493          	addi	s1,s1,-1490 # 8001c0f8 <bcache+0x30>
    b->next = bcache.head.next;
    800036d2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036d4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036d6:	00005a17          	auipc	s4,0x5
    800036da:	37aa0a13          	addi	s4,s4,890 # 80008a50 <userret+0x9c0>
    b->next = bcache.head.next;
    800036de:	5b893783          	ld	a5,1464(s2)
    800036e2:	f4bc                	sd	a5,104(s1)
    b->prev = &bcache.head;
    800036e4:	0734b023          	sd	s3,96(s1)
    initsleeplock(&b->lock, "buffer");
    800036e8:	85d2                	mv	a1,s4
    800036ea:	01048513          	addi	a0,s1,16
    800036ee:	00001097          	auipc	ra,0x1
    800036f2:	5ea080e7          	jalr	1514(ra) # 80004cd8 <initsleeplock>
    bcache.head.next->prev = b;
    800036f6:	5b893783          	ld	a5,1464(s2)
    800036fa:	f3a4                	sd	s1,96(a5)
    bcache.head.next = b;
    800036fc:	5a993c23          	sd	s1,1464(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003700:	47048493          	addi	s1,s1,1136
    80003704:	fd349de3          	bne	s1,s3,800036de <binit+0x54>
  }
}
    80003708:	70a2                	ld	ra,40(sp)
    8000370a:	7402                	ld	s0,32(sp)
    8000370c:	64e2                	ld	s1,24(sp)
    8000370e:	6942                	ld	s2,16(sp)
    80003710:	69a2                	ld	s3,8(sp)
    80003712:	6a02                	ld	s4,0(sp)
    80003714:	6145                	addi	sp,sp,48
    80003716:	8082                	ret

0000000080003718 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003718:	7179                	addi	sp,sp,-48
    8000371a:	f406                	sd	ra,40(sp)
    8000371c:	f022                	sd	s0,32(sp)
    8000371e:	ec26                	sd	s1,24(sp)
    80003720:	e84a                	sd	s2,16(sp)
    80003722:	e44e                	sd	s3,8(sp)
    80003724:	1800                	addi	s0,sp,48
    80003726:	89aa                	mv	s3,a0
    80003728:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000372a:	00019517          	auipc	a0,0x19
    8000372e:	99e50513          	addi	a0,a0,-1634 # 8001c0c8 <bcache>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	588080e7          	jalr	1416(ra) # 80000cba <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000373a:	00021797          	auipc	a5,0x21
    8000373e:	98e78793          	addi	a5,a5,-1650 # 800240c8 <bcache+0x8000>
    80003742:	5b87b483          	ld	s1,1464(a5)
    80003746:	00021797          	auipc	a5,0x21
    8000374a:	ed278793          	addi	a5,a5,-302 # 80024618 <bcache+0x8550>
    8000374e:	02f48f63          	beq	s1,a5,8000378c <bread+0x74>
    80003752:	873e                	mv	a4,a5
    80003754:	a021                	j	8000375c <bread+0x44>
    80003756:	74a4                	ld	s1,104(s1)
    80003758:	02e48a63          	beq	s1,a4,8000378c <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    8000375c:	449c                	lw	a5,8(s1)
    8000375e:	ff379ce3          	bne	a5,s3,80003756 <bread+0x3e>
    80003762:	44dc                	lw	a5,12(s1)
    80003764:	ff2799e3          	bne	a5,s2,80003756 <bread+0x3e>
      b->refcnt++;
    80003768:	4cbc                	lw	a5,88(s1)
    8000376a:	2785                	addiw	a5,a5,1
    8000376c:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    8000376e:	00019517          	auipc	a0,0x19
    80003772:	95a50513          	addi	a0,a0,-1702 # 8001c0c8 <bcache>
    80003776:	ffffd097          	auipc	ra,0xffffd
    8000377a:	790080e7          	jalr	1936(ra) # 80000f06 <release>
      acquiresleep(&b->lock);
    8000377e:	01048513          	addi	a0,s1,16
    80003782:	00001097          	auipc	ra,0x1
    80003786:	590080e7          	jalr	1424(ra) # 80004d12 <acquiresleep>
      return b;
    8000378a:	a8b1                	j	800037e6 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000378c:	00021797          	auipc	a5,0x21
    80003790:	93c78793          	addi	a5,a5,-1732 # 800240c8 <bcache+0x8000>
    80003794:	5b07b483          	ld	s1,1456(a5)
    80003798:	00021797          	auipc	a5,0x21
    8000379c:	e8078793          	addi	a5,a5,-384 # 80024618 <bcache+0x8550>
    800037a0:	04f48d63          	beq	s1,a5,800037fa <bread+0xe2>
    if(b->refcnt == 0) {
    800037a4:	4cbc                	lw	a5,88(s1)
    800037a6:	cb91                	beqz	a5,800037ba <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037a8:	00021717          	auipc	a4,0x21
    800037ac:	e7070713          	addi	a4,a4,-400 # 80024618 <bcache+0x8550>
    800037b0:	70a4                	ld	s1,96(s1)
    800037b2:	04e48463          	beq	s1,a4,800037fa <bread+0xe2>
    if(b->refcnt == 0) {
    800037b6:	4cbc                	lw	a5,88(s1)
    800037b8:	ffe5                	bnez	a5,800037b0 <bread+0x98>
      b->dev = dev;
    800037ba:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800037be:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800037c2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800037c6:	4785                	li	a5,1
    800037c8:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    800037ca:	00019517          	auipc	a0,0x19
    800037ce:	8fe50513          	addi	a0,a0,-1794 # 8001c0c8 <bcache>
    800037d2:	ffffd097          	auipc	ra,0xffffd
    800037d6:	734080e7          	jalr	1844(ra) # 80000f06 <release>
      acquiresleep(&b->lock);
    800037da:	01048513          	addi	a0,s1,16
    800037de:	00001097          	auipc	ra,0x1
    800037e2:	534080e7          	jalr	1332(ra) # 80004d12 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800037e6:	409c                	lw	a5,0(s1)
    800037e8:	c38d                	beqz	a5,8000380a <bread+0xf2>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    800037ea:	8526                	mv	a0,s1
    800037ec:	70a2                	ld	ra,40(sp)
    800037ee:	7402                	ld	s0,32(sp)
    800037f0:	64e2                	ld	s1,24(sp)
    800037f2:	6942                	ld	s2,16(sp)
    800037f4:	69a2                	ld	s3,8(sp)
    800037f6:	6145                	addi	sp,sp,48
    800037f8:	8082                	ret
  panic("bget: no buffers");
    800037fa:	00005517          	auipc	a0,0x5
    800037fe:	25e50513          	addi	a0,a0,606 # 80008a58 <userret+0x9c8>
    80003802:	ffffd097          	auipc	ra,0xffffd
    80003806:	f82080e7          	jalr	-126(ra) # 80000784 <panic>
    virtio_disk_rw(b->dev, b, 0);
    8000380a:	4601                	li	a2,0
    8000380c:	85a6                	mv	a1,s1
    8000380e:	4488                	lw	a0,8(s1)
    80003810:	00003097          	auipc	ra,0x3
    80003814:	1da080e7          	jalr	474(ra) # 800069ea <virtio_disk_rw>
    b->valid = 1;
    80003818:	4785                	li	a5,1
    8000381a:	c09c                	sw	a5,0(s1)
  return b;
    8000381c:	b7f9                	j	800037ea <bread+0xd2>

000000008000381e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000381e:	1101                	addi	sp,sp,-32
    80003820:	ec06                	sd	ra,24(sp)
    80003822:	e822                	sd	s0,16(sp)
    80003824:	e426                	sd	s1,8(sp)
    80003826:	1000                	addi	s0,sp,32
    80003828:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000382a:	0541                	addi	a0,a0,16
    8000382c:	00001097          	auipc	ra,0x1
    80003830:	580080e7          	jalr	1408(ra) # 80004dac <holdingsleep>
    80003834:	cd09                	beqz	a0,8000384e <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80003836:	4605                	li	a2,1
    80003838:	85a6                	mv	a1,s1
    8000383a:	4488                	lw	a0,8(s1)
    8000383c:	00003097          	auipc	ra,0x3
    80003840:	1ae080e7          	jalr	430(ra) # 800069ea <virtio_disk_rw>
}
    80003844:	60e2                	ld	ra,24(sp)
    80003846:	6442                	ld	s0,16(sp)
    80003848:	64a2                	ld	s1,8(sp)
    8000384a:	6105                	addi	sp,sp,32
    8000384c:	8082                	ret
    panic("bwrite");
    8000384e:	00005517          	auipc	a0,0x5
    80003852:	22250513          	addi	a0,a0,546 # 80008a70 <userret+0x9e0>
    80003856:	ffffd097          	auipc	ra,0xffffd
    8000385a:	f2e080e7          	jalr	-210(ra) # 80000784 <panic>

000000008000385e <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    8000385e:	1101                	addi	sp,sp,-32
    80003860:	ec06                	sd	ra,24(sp)
    80003862:	e822                	sd	s0,16(sp)
    80003864:	e426                	sd	s1,8(sp)
    80003866:	e04a                	sd	s2,0(sp)
    80003868:	1000                	addi	s0,sp,32
    8000386a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000386c:	01050913          	addi	s2,a0,16
    80003870:	854a                	mv	a0,s2
    80003872:	00001097          	auipc	ra,0x1
    80003876:	53a080e7          	jalr	1338(ra) # 80004dac <holdingsleep>
    8000387a:	c92d                	beqz	a0,800038ec <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000387c:	854a                	mv	a0,s2
    8000387e:	00001097          	auipc	ra,0x1
    80003882:	4ea080e7          	jalr	1258(ra) # 80004d68 <releasesleep>

  acquire(&bcache.lock);
    80003886:	00019517          	auipc	a0,0x19
    8000388a:	84250513          	addi	a0,a0,-1982 # 8001c0c8 <bcache>
    8000388e:	ffffd097          	auipc	ra,0xffffd
    80003892:	42c080e7          	jalr	1068(ra) # 80000cba <acquire>
  b->refcnt--;
    80003896:	4cbc                	lw	a5,88(s1)
    80003898:	37fd                	addiw	a5,a5,-1
    8000389a:	0007871b          	sext.w	a4,a5
    8000389e:	ccbc                	sw	a5,88(s1)
  if (b->refcnt == 0) {
    800038a0:	eb05                	bnez	a4,800038d0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800038a2:	74bc                	ld	a5,104(s1)
    800038a4:	70b8                	ld	a4,96(s1)
    800038a6:	f3b8                	sd	a4,96(a5)
    b->prev->next = b->next;
    800038a8:	70bc                	ld	a5,96(s1)
    800038aa:	74b8                	ld	a4,104(s1)
    800038ac:	f7b8                	sd	a4,104(a5)
    b->next = bcache.head.next;
    800038ae:	00021797          	auipc	a5,0x21
    800038b2:	81a78793          	addi	a5,a5,-2022 # 800240c8 <bcache+0x8000>
    800038b6:	5b87b703          	ld	a4,1464(a5)
    800038ba:	f4b8                	sd	a4,104(s1)
    b->prev = &bcache.head;
    800038bc:	00021717          	auipc	a4,0x21
    800038c0:	d5c70713          	addi	a4,a4,-676 # 80024618 <bcache+0x8550>
    800038c4:	f0b8                	sd	a4,96(s1)
    bcache.head.next->prev = b;
    800038c6:	5b87b703          	ld	a4,1464(a5)
    800038ca:	f324                	sd	s1,96(a4)
    bcache.head.next = b;
    800038cc:	5a97bc23          	sd	s1,1464(a5)
  }
  
  release(&bcache.lock);
    800038d0:	00018517          	auipc	a0,0x18
    800038d4:	7f850513          	addi	a0,a0,2040 # 8001c0c8 <bcache>
    800038d8:	ffffd097          	auipc	ra,0xffffd
    800038dc:	62e080e7          	jalr	1582(ra) # 80000f06 <release>
}
    800038e0:	60e2                	ld	ra,24(sp)
    800038e2:	6442                	ld	s0,16(sp)
    800038e4:	64a2                	ld	s1,8(sp)
    800038e6:	6902                	ld	s2,0(sp)
    800038e8:	6105                	addi	sp,sp,32
    800038ea:	8082                	ret
    panic("brelse");
    800038ec:	00005517          	auipc	a0,0x5
    800038f0:	18c50513          	addi	a0,a0,396 # 80008a78 <userret+0x9e8>
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	e90080e7          	jalr	-368(ra) # 80000784 <panic>

00000000800038fc <bpin>:

void
bpin(struct buf *b) {
    800038fc:	1101                	addi	sp,sp,-32
    800038fe:	ec06                	sd	ra,24(sp)
    80003900:	e822                	sd	s0,16(sp)
    80003902:	e426                	sd	s1,8(sp)
    80003904:	1000                	addi	s0,sp,32
    80003906:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003908:	00018517          	auipc	a0,0x18
    8000390c:	7c050513          	addi	a0,a0,1984 # 8001c0c8 <bcache>
    80003910:	ffffd097          	auipc	ra,0xffffd
    80003914:	3aa080e7          	jalr	938(ra) # 80000cba <acquire>
  b->refcnt++;
    80003918:	4cbc                	lw	a5,88(s1)
    8000391a:	2785                	addiw	a5,a5,1
    8000391c:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    8000391e:	00018517          	auipc	a0,0x18
    80003922:	7aa50513          	addi	a0,a0,1962 # 8001c0c8 <bcache>
    80003926:	ffffd097          	auipc	ra,0xffffd
    8000392a:	5e0080e7          	jalr	1504(ra) # 80000f06 <release>
}
    8000392e:	60e2                	ld	ra,24(sp)
    80003930:	6442                	ld	s0,16(sp)
    80003932:	64a2                	ld	s1,8(sp)
    80003934:	6105                	addi	sp,sp,32
    80003936:	8082                	ret

0000000080003938 <bunpin>:

void
bunpin(struct buf *b) {
    80003938:	1101                	addi	sp,sp,-32
    8000393a:	ec06                	sd	ra,24(sp)
    8000393c:	e822                	sd	s0,16(sp)
    8000393e:	e426                	sd	s1,8(sp)
    80003940:	1000                	addi	s0,sp,32
    80003942:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003944:	00018517          	auipc	a0,0x18
    80003948:	78450513          	addi	a0,a0,1924 # 8001c0c8 <bcache>
    8000394c:	ffffd097          	auipc	ra,0xffffd
    80003950:	36e080e7          	jalr	878(ra) # 80000cba <acquire>
  b->refcnt--;
    80003954:	4cbc                	lw	a5,88(s1)
    80003956:	37fd                	addiw	a5,a5,-1
    80003958:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    8000395a:	00018517          	auipc	a0,0x18
    8000395e:	76e50513          	addi	a0,a0,1902 # 8001c0c8 <bcache>
    80003962:	ffffd097          	auipc	ra,0xffffd
    80003966:	5a4080e7          	jalr	1444(ra) # 80000f06 <release>
}
    8000396a:	60e2                	ld	ra,24(sp)
    8000396c:	6442                	ld	s0,16(sp)
    8000396e:	64a2                	ld	s1,8(sp)
    80003970:	6105                	addi	sp,sp,32
    80003972:	8082                	ret

0000000080003974 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003974:	1101                	addi	sp,sp,-32
    80003976:	ec06                	sd	ra,24(sp)
    80003978:	e822                	sd	s0,16(sp)
    8000397a:	e426                	sd	s1,8(sp)
    8000397c:	e04a                	sd	s2,0(sp)
    8000397e:	1000                	addi	s0,sp,32
    80003980:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003982:	00d5d59b          	srliw	a1,a1,0xd
    80003986:	00021797          	auipc	a5,0x21
    8000398a:	10278793          	addi	a5,a5,258 # 80024a88 <sb>
    8000398e:	4fdc                	lw	a5,28(a5)
    80003990:	9dbd                	addw	a1,a1,a5
    80003992:	00000097          	auipc	ra,0x0
    80003996:	d86080e7          	jalr	-634(ra) # 80003718 <bread>
  bi = b % BPB;
    8000399a:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    8000399c:	0074f793          	andi	a5,s1,7
    800039a0:	4705                	li	a4,1
    800039a2:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    800039a6:	6789                	lui	a5,0x2
    800039a8:	17fd                	addi	a5,a5,-1
    800039aa:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    800039ac:	41f4d79b          	sraiw	a5,s1,0x1f
    800039b0:	01d7d79b          	srliw	a5,a5,0x1d
    800039b4:	9fa5                	addw	a5,a5,s1
    800039b6:	4037d79b          	sraiw	a5,a5,0x3
    800039ba:	00f506b3          	add	a3,a0,a5
    800039be:	0706c683          	lbu	a3,112(a3)
    800039c2:	00d77633          	and	a2,a4,a3
    800039c6:	c61d                	beqz	a2,800039f4 <bfree+0x80>
    800039c8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800039ca:	97aa                	add	a5,a5,a0
    800039cc:	fff74713          	not	a4,a4
    800039d0:	8f75                	and	a4,a4,a3
    800039d2:	06e78823          	sb	a4,112(a5) # 2070 <_entry-0x7fffdf90>
  log_write(bp);
    800039d6:	00001097          	auipc	ra,0x1
    800039da:	1b2080e7          	jalr	434(ra) # 80004b88 <log_write>
  brelse(bp);
    800039de:	854a                	mv	a0,s2
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	e7e080e7          	jalr	-386(ra) # 8000385e <brelse>
}
    800039e8:	60e2                	ld	ra,24(sp)
    800039ea:	6442                	ld	s0,16(sp)
    800039ec:	64a2                	ld	s1,8(sp)
    800039ee:	6902                	ld	s2,0(sp)
    800039f0:	6105                	addi	sp,sp,32
    800039f2:	8082                	ret
    panic("freeing free block");
    800039f4:	00005517          	auipc	a0,0x5
    800039f8:	08c50513          	addi	a0,a0,140 # 80008a80 <userret+0x9f0>
    800039fc:	ffffd097          	auipc	ra,0xffffd
    80003a00:	d88080e7          	jalr	-632(ra) # 80000784 <panic>

0000000080003a04 <balloc>:
{
    80003a04:	711d                	addi	sp,sp,-96
    80003a06:	ec86                	sd	ra,88(sp)
    80003a08:	e8a2                	sd	s0,80(sp)
    80003a0a:	e4a6                	sd	s1,72(sp)
    80003a0c:	e0ca                	sd	s2,64(sp)
    80003a0e:	fc4e                	sd	s3,56(sp)
    80003a10:	f852                	sd	s4,48(sp)
    80003a12:	f456                	sd	s5,40(sp)
    80003a14:	f05a                	sd	s6,32(sp)
    80003a16:	ec5e                	sd	s7,24(sp)
    80003a18:	e862                	sd	s8,16(sp)
    80003a1a:	e466                	sd	s9,8(sp)
    80003a1c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a1e:	00021797          	auipc	a5,0x21
    80003a22:	06a78793          	addi	a5,a5,106 # 80024a88 <sb>
    80003a26:	43dc                	lw	a5,4(a5)
    80003a28:	10078e63          	beqz	a5,80003b44 <balloc+0x140>
    80003a2c:	8baa                	mv	s7,a0
    80003a2e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a30:	00021b17          	auipc	s6,0x21
    80003a34:	058b0b13          	addi	s6,s6,88 # 80024a88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a38:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    80003a3a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a3c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a3e:	6c89                	lui	s9,0x2
    80003a40:	a079                	j	80003ace <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a42:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    80003a44:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a46:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a48:	96a6                	add	a3,a3,s1
    80003a4a:	8f51                	or	a4,a4,a2
    80003a4c:	06e68823          	sb	a4,112(a3)
        log_write(bp);
    80003a50:	8526                	mv	a0,s1
    80003a52:	00001097          	auipc	ra,0x1
    80003a56:	136080e7          	jalr	310(ra) # 80004b88 <log_write>
        brelse(bp);
    80003a5a:	8526                	mv	a0,s1
    80003a5c:	00000097          	auipc	ra,0x0
    80003a60:	e02080e7          	jalr	-510(ra) # 8000385e <brelse>
  bp = bread(dev, bno);
    80003a64:	85ca                	mv	a1,s2
    80003a66:	855e                	mv	a0,s7
    80003a68:	00000097          	auipc	ra,0x0
    80003a6c:	cb0080e7          	jalr	-848(ra) # 80003718 <bread>
    80003a70:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    80003a72:	40000613          	li	a2,1024
    80003a76:	4581                	li	a1,0
    80003a78:	07050513          	addi	a0,a0,112
    80003a7c:	ffffd097          	auipc	ra,0xffffd
    80003a80:	6b2080e7          	jalr	1714(ra) # 8000112e <memset>
  log_write(bp);
    80003a84:	8526                	mv	a0,s1
    80003a86:	00001097          	auipc	ra,0x1
    80003a8a:	102080e7          	jalr	258(ra) # 80004b88 <log_write>
  brelse(bp);
    80003a8e:	8526                	mv	a0,s1
    80003a90:	00000097          	auipc	ra,0x0
    80003a94:	dce080e7          	jalr	-562(ra) # 8000385e <brelse>
}
    80003a98:	854a                	mv	a0,s2
    80003a9a:	60e6                	ld	ra,88(sp)
    80003a9c:	6446                	ld	s0,80(sp)
    80003a9e:	64a6                	ld	s1,72(sp)
    80003aa0:	6906                	ld	s2,64(sp)
    80003aa2:	79e2                	ld	s3,56(sp)
    80003aa4:	7a42                	ld	s4,48(sp)
    80003aa6:	7aa2                	ld	s5,40(sp)
    80003aa8:	7b02                	ld	s6,32(sp)
    80003aaa:	6be2                	ld	s7,24(sp)
    80003aac:	6c42                	ld	s8,16(sp)
    80003aae:	6ca2                	ld	s9,8(sp)
    80003ab0:	6125                	addi	sp,sp,96
    80003ab2:	8082                	ret
    brelse(bp);
    80003ab4:	8526                	mv	a0,s1
    80003ab6:	00000097          	auipc	ra,0x0
    80003aba:	da8080e7          	jalr	-600(ra) # 8000385e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003abe:	015c87bb          	addw	a5,s9,s5
    80003ac2:	00078a9b          	sext.w	s5,a5
    80003ac6:	004b2703          	lw	a4,4(s6)
    80003aca:	06eafd63          	bleu	a4,s5,80003b44 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    80003ace:	41fad79b          	sraiw	a5,s5,0x1f
    80003ad2:	0137d79b          	srliw	a5,a5,0x13
    80003ad6:	015787bb          	addw	a5,a5,s5
    80003ada:	40d7d79b          	sraiw	a5,a5,0xd
    80003ade:	01cb2583          	lw	a1,28(s6)
    80003ae2:	9dbd                	addw	a1,a1,a5
    80003ae4:	855e                	mv	a0,s7
    80003ae6:	00000097          	auipc	ra,0x0
    80003aea:	c32080e7          	jalr	-974(ra) # 80003718 <bread>
    80003aee:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003af0:	000a881b          	sext.w	a6,s5
    80003af4:	004b2503          	lw	a0,4(s6)
    80003af8:	faa87ee3          	bleu	a0,a6,80003ab4 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003afc:	0704c603          	lbu	a2,112(s1)
    80003b00:	00167793          	andi	a5,a2,1
    80003b04:	df9d                	beqz	a5,80003a42 <balloc+0x3e>
    80003b06:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b0a:	87e2                	mv	a5,s8
    80003b0c:	0107893b          	addw	s2,a5,a6
    80003b10:	faa782e3          	beq	a5,a0,80003ab4 <balloc+0xb0>
      m = 1 << (bi % 8);
    80003b14:	41f7d71b          	sraiw	a4,a5,0x1f
    80003b18:	01d7561b          	srliw	a2,a4,0x1d
    80003b1c:	00f606bb          	addw	a3,a2,a5
    80003b20:	0076f713          	andi	a4,a3,7
    80003b24:	9f11                	subw	a4,a4,a2
    80003b26:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b2a:	4036d69b          	sraiw	a3,a3,0x3
    80003b2e:	00d48633          	add	a2,s1,a3
    80003b32:	07064603          	lbu	a2,112(a2)
    80003b36:	00c775b3          	and	a1,a4,a2
    80003b3a:	d599                	beqz	a1,80003a48 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b3c:	2785                	addiw	a5,a5,1
    80003b3e:	fd4797e3          	bne	a5,s4,80003b0c <balloc+0x108>
    80003b42:	bf8d                	j	80003ab4 <balloc+0xb0>
  panic("balloc: out of blocks");
    80003b44:	00005517          	auipc	a0,0x5
    80003b48:	f5450513          	addi	a0,a0,-172 # 80008a98 <userret+0xa08>
    80003b4c:	ffffd097          	auipc	ra,0xffffd
    80003b50:	c38080e7          	jalr	-968(ra) # 80000784 <panic>

0000000080003b54 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b54:	7179                	addi	sp,sp,-48
    80003b56:	f406                	sd	ra,40(sp)
    80003b58:	f022                	sd	s0,32(sp)
    80003b5a:	ec26                	sd	s1,24(sp)
    80003b5c:	e84a                	sd	s2,16(sp)
    80003b5e:	e44e                	sd	s3,8(sp)
    80003b60:	e052                	sd	s4,0(sp)
    80003b62:	1800                	addi	s0,sp,48
    80003b64:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b66:	47ad                	li	a5,11
    80003b68:	04b7fe63          	bleu	a1,a5,80003bc4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003b6c:	ff45849b          	addiw	s1,a1,-12
    80003b70:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003b74:	0ff00793          	li	a5,255
    80003b78:	0ae7e363          	bltu	a5,a4,80003c1e <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003b7c:	09852583          	lw	a1,152(a0)
    80003b80:	c5ad                	beqz	a1,80003bea <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003b82:	0009a503          	lw	a0,0(s3)
    80003b86:	00000097          	auipc	ra,0x0
    80003b8a:	b92080e7          	jalr	-1134(ra) # 80003718 <bread>
    80003b8e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b90:	07050793          	addi	a5,a0,112
    if((addr = a[bn]) == 0){
    80003b94:	02049593          	slli	a1,s1,0x20
    80003b98:	9181                	srli	a1,a1,0x20
    80003b9a:	058a                	slli	a1,a1,0x2
    80003b9c:	00b784b3          	add	s1,a5,a1
    80003ba0:	0004a903          	lw	s2,0(s1)
    80003ba4:	04090d63          	beqz	s2,80003bfe <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003ba8:	8552                	mv	a0,s4
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	cb4080e7          	jalr	-844(ra) # 8000385e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003bb2:	854a                	mv	a0,s2
    80003bb4:	70a2                	ld	ra,40(sp)
    80003bb6:	7402                	ld	s0,32(sp)
    80003bb8:	64e2                	ld	s1,24(sp)
    80003bba:	6942                	ld	s2,16(sp)
    80003bbc:	69a2                	ld	s3,8(sp)
    80003bbe:	6a02                	ld	s4,0(sp)
    80003bc0:	6145                	addi	sp,sp,48
    80003bc2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003bc4:	02059493          	slli	s1,a1,0x20
    80003bc8:	9081                	srli	s1,s1,0x20
    80003bca:	048a                	slli	s1,s1,0x2
    80003bcc:	94aa                	add	s1,s1,a0
    80003bce:	0684a903          	lw	s2,104(s1)
    80003bd2:	fe0910e3          	bnez	s2,80003bb2 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003bd6:	4108                	lw	a0,0(a0)
    80003bd8:	00000097          	auipc	ra,0x0
    80003bdc:	e2c080e7          	jalr	-468(ra) # 80003a04 <balloc>
    80003be0:	0005091b          	sext.w	s2,a0
    80003be4:	0724a423          	sw	s2,104(s1)
    80003be8:	b7e9                	j	80003bb2 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003bea:	4108                	lw	a0,0(a0)
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	e18080e7          	jalr	-488(ra) # 80003a04 <balloc>
    80003bf4:	0005059b          	sext.w	a1,a0
    80003bf8:	08b9ac23          	sw	a1,152(s3)
    80003bfc:	b759                	j	80003b82 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003bfe:	0009a503          	lw	a0,0(s3)
    80003c02:	00000097          	auipc	ra,0x0
    80003c06:	e02080e7          	jalr	-510(ra) # 80003a04 <balloc>
    80003c0a:	0005091b          	sext.w	s2,a0
    80003c0e:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    80003c12:	8552                	mv	a0,s4
    80003c14:	00001097          	auipc	ra,0x1
    80003c18:	f74080e7          	jalr	-140(ra) # 80004b88 <log_write>
    80003c1c:	b771                	j	80003ba8 <bmap+0x54>
  panic("bmap: out of range");
    80003c1e:	00005517          	auipc	a0,0x5
    80003c22:	e9250513          	addi	a0,a0,-366 # 80008ab0 <userret+0xa20>
    80003c26:	ffffd097          	auipc	ra,0xffffd
    80003c2a:	b5e080e7          	jalr	-1186(ra) # 80000784 <panic>

0000000080003c2e <iget>:
{
    80003c2e:	7179                	addi	sp,sp,-48
    80003c30:	f406                	sd	ra,40(sp)
    80003c32:	f022                	sd	s0,32(sp)
    80003c34:	ec26                	sd	s1,24(sp)
    80003c36:	e84a                	sd	s2,16(sp)
    80003c38:	e44e                	sd	s3,8(sp)
    80003c3a:	e052                	sd	s4,0(sp)
    80003c3c:	1800                	addi	s0,sp,48
    80003c3e:	89aa                	mv	s3,a0
    80003c40:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003c42:	00021517          	auipc	a0,0x21
    80003c46:	e6650513          	addi	a0,a0,-410 # 80024aa8 <icache>
    80003c4a:	ffffd097          	auipc	ra,0xffffd
    80003c4e:	070080e7          	jalr	112(ra) # 80000cba <acquire>
  empty = 0;
    80003c52:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003c54:	00021497          	auipc	s1,0x21
    80003c58:	e8448493          	addi	s1,s1,-380 # 80024ad8 <icache+0x30>
    80003c5c:	00023697          	auipc	a3,0x23
    80003c60:	dbc68693          	addi	a3,a3,-580 # 80026a18 <log>
    80003c64:	a039                	j	80003c72 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c66:	02090b63          	beqz	s2,80003c9c <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003c6a:	0a048493          	addi	s1,s1,160
    80003c6e:	02d48a63          	beq	s1,a3,80003ca2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c72:	449c                	lw	a5,8(s1)
    80003c74:	fef059e3          	blez	a5,80003c66 <iget+0x38>
    80003c78:	4098                	lw	a4,0(s1)
    80003c7a:	ff3716e3          	bne	a4,s3,80003c66 <iget+0x38>
    80003c7e:	40d8                	lw	a4,4(s1)
    80003c80:	ff4713e3          	bne	a4,s4,80003c66 <iget+0x38>
      ip->ref++;
    80003c84:	2785                	addiw	a5,a5,1
    80003c86:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003c88:	00021517          	auipc	a0,0x21
    80003c8c:	e2050513          	addi	a0,a0,-480 # 80024aa8 <icache>
    80003c90:	ffffd097          	auipc	ra,0xffffd
    80003c94:	276080e7          	jalr	630(ra) # 80000f06 <release>
      return ip;
    80003c98:	8926                	mv	s2,s1
    80003c9a:	a03d                	j	80003cc8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c9c:	f7f9                	bnez	a5,80003c6a <iget+0x3c>
    80003c9e:	8926                	mv	s2,s1
    80003ca0:	b7e9                	j	80003c6a <iget+0x3c>
  if(empty == 0)
    80003ca2:	02090c63          	beqz	s2,80003cda <iget+0xac>
  ip->dev = dev;
    80003ca6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003caa:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003cae:	4785                	li	a5,1
    80003cb0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003cb4:	04092c23          	sw	zero,88(s2)
  release(&icache.lock);
    80003cb8:	00021517          	auipc	a0,0x21
    80003cbc:	df050513          	addi	a0,a0,-528 # 80024aa8 <icache>
    80003cc0:	ffffd097          	auipc	ra,0xffffd
    80003cc4:	246080e7          	jalr	582(ra) # 80000f06 <release>
}
    80003cc8:	854a                	mv	a0,s2
    80003cca:	70a2                	ld	ra,40(sp)
    80003ccc:	7402                	ld	s0,32(sp)
    80003cce:	64e2                	ld	s1,24(sp)
    80003cd0:	6942                	ld	s2,16(sp)
    80003cd2:	69a2                	ld	s3,8(sp)
    80003cd4:	6a02                	ld	s4,0(sp)
    80003cd6:	6145                	addi	sp,sp,48
    80003cd8:	8082                	ret
    panic("iget: no inodes");
    80003cda:	00005517          	auipc	a0,0x5
    80003cde:	dee50513          	addi	a0,a0,-530 # 80008ac8 <userret+0xa38>
    80003ce2:	ffffd097          	auipc	ra,0xffffd
    80003ce6:	aa2080e7          	jalr	-1374(ra) # 80000784 <panic>

0000000080003cea <fsinit>:
fsinit(int dev) {
    80003cea:	7179                	addi	sp,sp,-48
    80003cec:	f406                	sd	ra,40(sp)
    80003cee:	f022                	sd	s0,32(sp)
    80003cf0:	ec26                	sd	s1,24(sp)
    80003cf2:	e84a                	sd	s2,16(sp)
    80003cf4:	e44e                	sd	s3,8(sp)
    80003cf6:	1800                	addi	s0,sp,48
    80003cf8:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003cfa:	4585                	li	a1,1
    80003cfc:	00000097          	auipc	ra,0x0
    80003d00:	a1c080e7          	jalr	-1508(ra) # 80003718 <bread>
    80003d04:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d06:	00021497          	auipc	s1,0x21
    80003d0a:	d8248493          	addi	s1,s1,-638 # 80024a88 <sb>
    80003d0e:	02000613          	li	a2,32
    80003d12:	07050593          	addi	a1,a0,112
    80003d16:	8526                	mv	a0,s1
    80003d18:	ffffd097          	auipc	ra,0xffffd
    80003d1c:	482080e7          	jalr	1154(ra) # 8000119a <memmove>
  brelse(bp);
    80003d20:	854a                	mv	a0,s2
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	b3c080e7          	jalr	-1220(ra) # 8000385e <brelse>
  if(sb.magic != FSMAGIC)
    80003d2a:	4098                	lw	a4,0(s1)
    80003d2c:	102037b7          	lui	a5,0x10203
    80003d30:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d34:	02f71263          	bne	a4,a5,80003d58 <fsinit+0x6e>
  initlog(dev, &sb);
    80003d38:	00021597          	auipc	a1,0x21
    80003d3c:	d5058593          	addi	a1,a1,-688 # 80024a88 <sb>
    80003d40:	854e                	mv	a0,s3
    80003d42:	00001097          	auipc	ra,0x1
    80003d46:	b30080e7          	jalr	-1232(ra) # 80004872 <initlog>
}
    80003d4a:	70a2                	ld	ra,40(sp)
    80003d4c:	7402                	ld	s0,32(sp)
    80003d4e:	64e2                	ld	s1,24(sp)
    80003d50:	6942                	ld	s2,16(sp)
    80003d52:	69a2                	ld	s3,8(sp)
    80003d54:	6145                	addi	sp,sp,48
    80003d56:	8082                	ret
    panic("invalid file system");
    80003d58:	00005517          	auipc	a0,0x5
    80003d5c:	d8050513          	addi	a0,a0,-640 # 80008ad8 <userret+0xa48>
    80003d60:	ffffd097          	auipc	ra,0xffffd
    80003d64:	a24080e7          	jalr	-1500(ra) # 80000784 <panic>

0000000080003d68 <iinit>:
{
    80003d68:	7179                	addi	sp,sp,-48
    80003d6a:	f406                	sd	ra,40(sp)
    80003d6c:	f022                	sd	s0,32(sp)
    80003d6e:	ec26                	sd	s1,24(sp)
    80003d70:	e84a                	sd	s2,16(sp)
    80003d72:	e44e                	sd	s3,8(sp)
    80003d74:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003d76:	00005597          	auipc	a1,0x5
    80003d7a:	d7a58593          	addi	a1,a1,-646 # 80008af0 <userret+0xa60>
    80003d7e:	00021517          	auipc	a0,0x21
    80003d82:	d2a50513          	addi	a0,a0,-726 # 80024aa8 <icache>
    80003d86:	ffffd097          	auipc	ra,0xffffd
    80003d8a:	dc6080e7          	jalr	-570(ra) # 80000b4c <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d8e:	00021497          	auipc	s1,0x21
    80003d92:	d5a48493          	addi	s1,s1,-678 # 80024ae8 <icache+0x40>
    80003d96:	00023997          	auipc	s3,0x23
    80003d9a:	c9298993          	addi	s3,s3,-878 # 80026a28 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003d9e:	00005917          	auipc	s2,0x5
    80003da2:	d5a90913          	addi	s2,s2,-678 # 80008af8 <userret+0xa68>
    80003da6:	85ca                	mv	a1,s2
    80003da8:	8526                	mv	a0,s1
    80003daa:	00001097          	auipc	ra,0x1
    80003dae:	f2e080e7          	jalr	-210(ra) # 80004cd8 <initsleeplock>
    80003db2:	0a048493          	addi	s1,s1,160
  for(i = 0; i < NINODE; i++) {
    80003db6:	ff3498e3          	bne	s1,s3,80003da6 <iinit+0x3e>
}
    80003dba:	70a2                	ld	ra,40(sp)
    80003dbc:	7402                	ld	s0,32(sp)
    80003dbe:	64e2                	ld	s1,24(sp)
    80003dc0:	6942                	ld	s2,16(sp)
    80003dc2:	69a2                	ld	s3,8(sp)
    80003dc4:	6145                	addi	sp,sp,48
    80003dc6:	8082                	ret

0000000080003dc8 <ialloc>:
{
    80003dc8:	715d                	addi	sp,sp,-80
    80003dca:	e486                	sd	ra,72(sp)
    80003dcc:	e0a2                	sd	s0,64(sp)
    80003dce:	fc26                	sd	s1,56(sp)
    80003dd0:	f84a                	sd	s2,48(sp)
    80003dd2:	f44e                	sd	s3,40(sp)
    80003dd4:	f052                	sd	s4,32(sp)
    80003dd6:	ec56                	sd	s5,24(sp)
    80003dd8:	e85a                	sd	s6,16(sp)
    80003dda:	e45e                	sd	s7,8(sp)
    80003ddc:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003dde:	00021797          	auipc	a5,0x21
    80003de2:	caa78793          	addi	a5,a5,-854 # 80024a88 <sb>
    80003de6:	47d8                	lw	a4,12(a5)
    80003de8:	4785                	li	a5,1
    80003dea:	04e7fa63          	bleu	a4,a5,80003e3e <ialloc+0x76>
    80003dee:	8a2a                	mv	s4,a0
    80003df0:	8b2e                	mv	s6,a1
    80003df2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003df4:	00021997          	auipc	s3,0x21
    80003df8:	c9498993          	addi	s3,s3,-876 # 80024a88 <sb>
    80003dfc:	00048a9b          	sext.w	s5,s1
    80003e00:	0044d593          	srli	a1,s1,0x4
    80003e04:	0189a783          	lw	a5,24(s3)
    80003e08:	9dbd                	addw	a1,a1,a5
    80003e0a:	8552                	mv	a0,s4
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	90c080e7          	jalr	-1780(ra) # 80003718 <bread>
    80003e14:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e16:	07050913          	addi	s2,a0,112
    80003e1a:	00f4f793          	andi	a5,s1,15
    80003e1e:	079a                	slli	a5,a5,0x6
    80003e20:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80003e22:	00091783          	lh	a5,0(s2)
    80003e26:	c785                	beqz	a5,80003e4e <ialloc+0x86>
    brelse(bp);
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	a36080e7          	jalr	-1482(ra) # 8000385e <brelse>
    80003e30:	0485                	addi	s1,s1,1
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e32:	00c9a703          	lw	a4,12(s3)
    80003e36:	0004879b          	sext.w	a5,s1
    80003e3a:	fce7e1e3          	bltu	a5,a4,80003dfc <ialloc+0x34>
  panic("ialloc: no inodes");
    80003e3e:	00005517          	auipc	a0,0x5
    80003e42:	cc250513          	addi	a0,a0,-830 # 80008b00 <userret+0xa70>
    80003e46:	ffffd097          	auipc	ra,0xffffd
    80003e4a:	93e080e7          	jalr	-1730(ra) # 80000784 <panic>
      memset(dip, 0, sizeof(*dip));
    80003e4e:	04000613          	li	a2,64
    80003e52:	4581                	li	a1,0
    80003e54:	854a                	mv	a0,s2
    80003e56:	ffffd097          	auipc	ra,0xffffd
    80003e5a:	2d8080e7          	jalr	728(ra) # 8000112e <memset>
      dip->type = type;
    80003e5e:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    80003e62:	855e                	mv	a0,s7
    80003e64:	00001097          	auipc	ra,0x1
    80003e68:	d24080e7          	jalr	-732(ra) # 80004b88 <log_write>
      brelse(bp);
    80003e6c:	855e                	mv	a0,s7
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	9f0080e7          	jalr	-1552(ra) # 8000385e <brelse>
      return iget(dev, inum);
    80003e76:	85d6                	mv	a1,s5
    80003e78:	8552                	mv	a0,s4
    80003e7a:	00000097          	auipc	ra,0x0
    80003e7e:	db4080e7          	jalr	-588(ra) # 80003c2e <iget>
}
    80003e82:	60a6                	ld	ra,72(sp)
    80003e84:	6406                	ld	s0,64(sp)
    80003e86:	74e2                	ld	s1,56(sp)
    80003e88:	7942                	ld	s2,48(sp)
    80003e8a:	79a2                	ld	s3,40(sp)
    80003e8c:	7a02                	ld	s4,32(sp)
    80003e8e:	6ae2                	ld	s5,24(sp)
    80003e90:	6b42                	ld	s6,16(sp)
    80003e92:	6ba2                	ld	s7,8(sp)
    80003e94:	6161                	addi	sp,sp,80
    80003e96:	8082                	ret

0000000080003e98 <iupdate>:
{
    80003e98:	1101                	addi	sp,sp,-32
    80003e9a:	ec06                	sd	ra,24(sp)
    80003e9c:	e822                	sd	s0,16(sp)
    80003e9e:	e426                	sd	s1,8(sp)
    80003ea0:	e04a                	sd	s2,0(sp)
    80003ea2:	1000                	addi	s0,sp,32
    80003ea4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ea6:	415c                	lw	a5,4(a0)
    80003ea8:	0047d79b          	srliw	a5,a5,0x4
    80003eac:	00021717          	auipc	a4,0x21
    80003eb0:	bdc70713          	addi	a4,a4,-1060 # 80024a88 <sb>
    80003eb4:	4f0c                	lw	a1,24(a4)
    80003eb6:	9dbd                	addw	a1,a1,a5
    80003eb8:	4108                	lw	a0,0(a0)
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	85e080e7          	jalr	-1954(ra) # 80003718 <bread>
    80003ec2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ec4:	07050513          	addi	a0,a0,112
    80003ec8:	40dc                	lw	a5,4(s1)
    80003eca:	8bbd                	andi	a5,a5,15
    80003ecc:	079a                	slli	a5,a5,0x6
    80003ece:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ed0:	05c49783          	lh	a5,92(s1)
    80003ed4:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    80003ed8:	05e49783          	lh	a5,94(s1)
    80003edc:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    80003ee0:	06049783          	lh	a5,96(s1)
    80003ee4:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    80003ee8:	06249783          	lh	a5,98(s1)
    80003eec:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    80003ef0:	50fc                	lw	a5,100(s1)
    80003ef2:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ef4:	03400613          	li	a2,52
    80003ef8:	06848593          	addi	a1,s1,104
    80003efc:	0531                	addi	a0,a0,12
    80003efe:	ffffd097          	auipc	ra,0xffffd
    80003f02:	29c080e7          	jalr	668(ra) # 8000119a <memmove>
  log_write(bp);
    80003f06:	854a                	mv	a0,s2
    80003f08:	00001097          	auipc	ra,0x1
    80003f0c:	c80080e7          	jalr	-896(ra) # 80004b88 <log_write>
  brelse(bp);
    80003f10:	854a                	mv	a0,s2
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	94c080e7          	jalr	-1716(ra) # 8000385e <brelse>
}
    80003f1a:	60e2                	ld	ra,24(sp)
    80003f1c:	6442                	ld	s0,16(sp)
    80003f1e:	64a2                	ld	s1,8(sp)
    80003f20:	6902                	ld	s2,0(sp)
    80003f22:	6105                	addi	sp,sp,32
    80003f24:	8082                	ret

0000000080003f26 <idup>:
{
    80003f26:	1101                	addi	sp,sp,-32
    80003f28:	ec06                	sd	ra,24(sp)
    80003f2a:	e822                	sd	s0,16(sp)
    80003f2c:	e426                	sd	s1,8(sp)
    80003f2e:	1000                	addi	s0,sp,32
    80003f30:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003f32:	00021517          	auipc	a0,0x21
    80003f36:	b7650513          	addi	a0,a0,-1162 # 80024aa8 <icache>
    80003f3a:	ffffd097          	auipc	ra,0xffffd
    80003f3e:	d80080e7          	jalr	-640(ra) # 80000cba <acquire>
  ip->ref++;
    80003f42:	449c                	lw	a5,8(s1)
    80003f44:	2785                	addiw	a5,a5,1
    80003f46:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003f48:	00021517          	auipc	a0,0x21
    80003f4c:	b6050513          	addi	a0,a0,-1184 # 80024aa8 <icache>
    80003f50:	ffffd097          	auipc	ra,0xffffd
    80003f54:	fb6080e7          	jalr	-74(ra) # 80000f06 <release>
}
    80003f58:	8526                	mv	a0,s1
    80003f5a:	60e2                	ld	ra,24(sp)
    80003f5c:	6442                	ld	s0,16(sp)
    80003f5e:	64a2                	ld	s1,8(sp)
    80003f60:	6105                	addi	sp,sp,32
    80003f62:	8082                	ret

0000000080003f64 <ilock>:
{
    80003f64:	1101                	addi	sp,sp,-32
    80003f66:	ec06                	sd	ra,24(sp)
    80003f68:	e822                	sd	s0,16(sp)
    80003f6a:	e426                	sd	s1,8(sp)
    80003f6c:	e04a                	sd	s2,0(sp)
    80003f6e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f70:	c115                	beqz	a0,80003f94 <ilock+0x30>
    80003f72:	84aa                	mv	s1,a0
    80003f74:	451c                	lw	a5,8(a0)
    80003f76:	00f05f63          	blez	a5,80003f94 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003f7a:	0541                	addi	a0,a0,16
    80003f7c:	00001097          	auipc	ra,0x1
    80003f80:	d96080e7          	jalr	-618(ra) # 80004d12 <acquiresleep>
  if(ip->valid == 0){
    80003f84:	4cbc                	lw	a5,88(s1)
    80003f86:	cf99                	beqz	a5,80003fa4 <ilock+0x40>
}
    80003f88:	60e2                	ld	ra,24(sp)
    80003f8a:	6442                	ld	s0,16(sp)
    80003f8c:	64a2                	ld	s1,8(sp)
    80003f8e:	6902                	ld	s2,0(sp)
    80003f90:	6105                	addi	sp,sp,32
    80003f92:	8082                	ret
    panic("ilock");
    80003f94:	00005517          	auipc	a0,0x5
    80003f98:	b8450513          	addi	a0,a0,-1148 # 80008b18 <userret+0xa88>
    80003f9c:	ffffc097          	auipc	ra,0xffffc
    80003fa0:	7e8080e7          	jalr	2024(ra) # 80000784 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003fa4:	40dc                	lw	a5,4(s1)
    80003fa6:	0047d79b          	srliw	a5,a5,0x4
    80003faa:	00021717          	auipc	a4,0x21
    80003fae:	ade70713          	addi	a4,a4,-1314 # 80024a88 <sb>
    80003fb2:	4f0c                	lw	a1,24(a4)
    80003fb4:	9dbd                	addw	a1,a1,a5
    80003fb6:	4088                	lw	a0,0(s1)
    80003fb8:	fffff097          	auipc	ra,0xfffff
    80003fbc:	760080e7          	jalr	1888(ra) # 80003718 <bread>
    80003fc0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003fc2:	07050593          	addi	a1,a0,112
    80003fc6:	40dc                	lw	a5,4(s1)
    80003fc8:	8bbd                	andi	a5,a5,15
    80003fca:	079a                	slli	a5,a5,0x6
    80003fcc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003fce:	00059783          	lh	a5,0(a1)
    80003fd2:	04f49e23          	sh	a5,92(s1)
    ip->major = dip->major;
    80003fd6:	00259783          	lh	a5,2(a1)
    80003fda:	04f49f23          	sh	a5,94(s1)
    ip->minor = dip->minor;
    80003fde:	00459783          	lh	a5,4(a1)
    80003fe2:	06f49023          	sh	a5,96(s1)
    ip->nlink = dip->nlink;
    80003fe6:	00659783          	lh	a5,6(a1)
    80003fea:	06f49123          	sh	a5,98(s1)
    ip->size = dip->size;
    80003fee:	459c                	lw	a5,8(a1)
    80003ff0:	d0fc                	sw	a5,100(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ff2:	03400613          	li	a2,52
    80003ff6:	05b1                	addi	a1,a1,12
    80003ff8:	06848513          	addi	a0,s1,104
    80003ffc:	ffffd097          	auipc	ra,0xffffd
    80004000:	19e080e7          	jalr	414(ra) # 8000119a <memmove>
    brelse(bp);
    80004004:	854a                	mv	a0,s2
    80004006:	00000097          	auipc	ra,0x0
    8000400a:	858080e7          	jalr	-1960(ra) # 8000385e <brelse>
    ip->valid = 1;
    8000400e:	4785                	li	a5,1
    80004010:	ccbc                	sw	a5,88(s1)
    if(ip->type == 0)
    80004012:	05c49783          	lh	a5,92(s1)
    80004016:	fbad                	bnez	a5,80003f88 <ilock+0x24>
      panic("ilock: no type");
    80004018:	00005517          	auipc	a0,0x5
    8000401c:	b0850513          	addi	a0,a0,-1272 # 80008b20 <userret+0xa90>
    80004020:	ffffc097          	auipc	ra,0xffffc
    80004024:	764080e7          	jalr	1892(ra) # 80000784 <panic>

0000000080004028 <iunlock>:
{
    80004028:	1101                	addi	sp,sp,-32
    8000402a:	ec06                	sd	ra,24(sp)
    8000402c:	e822                	sd	s0,16(sp)
    8000402e:	e426                	sd	s1,8(sp)
    80004030:	e04a                	sd	s2,0(sp)
    80004032:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004034:	c905                	beqz	a0,80004064 <iunlock+0x3c>
    80004036:	84aa                	mv	s1,a0
    80004038:	01050913          	addi	s2,a0,16
    8000403c:	854a                	mv	a0,s2
    8000403e:	00001097          	auipc	ra,0x1
    80004042:	d6e080e7          	jalr	-658(ra) # 80004dac <holdingsleep>
    80004046:	cd19                	beqz	a0,80004064 <iunlock+0x3c>
    80004048:	449c                	lw	a5,8(s1)
    8000404a:	00f05d63          	blez	a5,80004064 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000404e:	854a                	mv	a0,s2
    80004050:	00001097          	auipc	ra,0x1
    80004054:	d18080e7          	jalr	-744(ra) # 80004d68 <releasesleep>
}
    80004058:	60e2                	ld	ra,24(sp)
    8000405a:	6442                	ld	s0,16(sp)
    8000405c:	64a2                	ld	s1,8(sp)
    8000405e:	6902                	ld	s2,0(sp)
    80004060:	6105                	addi	sp,sp,32
    80004062:	8082                	ret
    panic("iunlock");
    80004064:	00005517          	auipc	a0,0x5
    80004068:	acc50513          	addi	a0,a0,-1332 # 80008b30 <userret+0xaa0>
    8000406c:	ffffc097          	auipc	ra,0xffffc
    80004070:	718080e7          	jalr	1816(ra) # 80000784 <panic>

0000000080004074 <iput>:
{
    80004074:	7139                	addi	sp,sp,-64
    80004076:	fc06                	sd	ra,56(sp)
    80004078:	f822                	sd	s0,48(sp)
    8000407a:	f426                	sd	s1,40(sp)
    8000407c:	f04a                	sd	s2,32(sp)
    8000407e:	ec4e                	sd	s3,24(sp)
    80004080:	e852                	sd	s4,16(sp)
    80004082:	e456                	sd	s5,8(sp)
    80004084:	0080                	addi	s0,sp,64
    80004086:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80004088:	00021517          	auipc	a0,0x21
    8000408c:	a2050513          	addi	a0,a0,-1504 # 80024aa8 <icache>
    80004090:	ffffd097          	auipc	ra,0xffffd
    80004094:	c2a080e7          	jalr	-982(ra) # 80000cba <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004098:	4498                	lw	a4,8(s1)
    8000409a:	4785                	li	a5,1
    8000409c:	02f70663          	beq	a4,a5,800040c8 <iput+0x54>
  ip->ref--;
    800040a0:	449c                	lw	a5,8(s1)
    800040a2:	37fd                	addiw	a5,a5,-1
    800040a4:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800040a6:	00021517          	auipc	a0,0x21
    800040aa:	a0250513          	addi	a0,a0,-1534 # 80024aa8 <icache>
    800040ae:	ffffd097          	auipc	ra,0xffffd
    800040b2:	e58080e7          	jalr	-424(ra) # 80000f06 <release>
}
    800040b6:	70e2                	ld	ra,56(sp)
    800040b8:	7442                	ld	s0,48(sp)
    800040ba:	74a2                	ld	s1,40(sp)
    800040bc:	7902                	ld	s2,32(sp)
    800040be:	69e2                	ld	s3,24(sp)
    800040c0:	6a42                	ld	s4,16(sp)
    800040c2:	6aa2                	ld	s5,8(sp)
    800040c4:	6121                	addi	sp,sp,64
    800040c6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800040c8:	4cbc                	lw	a5,88(s1)
    800040ca:	dbf9                	beqz	a5,800040a0 <iput+0x2c>
    800040cc:	06249783          	lh	a5,98(s1)
    800040d0:	fbe1                	bnez	a5,800040a0 <iput+0x2c>
    acquiresleep(&ip->lock);
    800040d2:	01048a13          	addi	s4,s1,16
    800040d6:	8552                	mv	a0,s4
    800040d8:	00001097          	auipc	ra,0x1
    800040dc:	c3a080e7          	jalr	-966(ra) # 80004d12 <acquiresleep>
    release(&icache.lock);
    800040e0:	00021517          	auipc	a0,0x21
    800040e4:	9c850513          	addi	a0,a0,-1592 # 80024aa8 <icache>
    800040e8:	ffffd097          	auipc	ra,0xffffd
    800040ec:	e1e080e7          	jalr	-482(ra) # 80000f06 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800040f0:	06848913          	addi	s2,s1,104
    800040f4:	09848993          	addi	s3,s1,152
    800040f8:	a819                	j	8000410e <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    800040fa:	4088                	lw	a0,0(s1)
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	878080e7          	jalr	-1928(ra) # 80003974 <bfree>
      ip->addrs[i] = 0;
    80004104:	00092023          	sw	zero,0(s2)
    80004108:	0911                	addi	s2,s2,4
  for(i = 0; i < NDIRECT; i++){
    8000410a:	01390663          	beq	s2,s3,80004116 <iput+0xa2>
    if(ip->addrs[i]){
    8000410e:	00092583          	lw	a1,0(s2)
    80004112:	d9fd                	beqz	a1,80004108 <iput+0x94>
    80004114:	b7dd                	j	800040fa <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004116:	0984a583          	lw	a1,152(s1)
    8000411a:	ed9d                	bnez	a1,80004158 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000411c:	0604a223          	sw	zero,100(s1)
  iupdate(ip);
    80004120:	8526                	mv	a0,s1
    80004122:	00000097          	auipc	ra,0x0
    80004126:	d76080e7          	jalr	-650(ra) # 80003e98 <iupdate>
    ip->type = 0;
    8000412a:	04049e23          	sh	zero,92(s1)
    iupdate(ip);
    8000412e:	8526                	mv	a0,s1
    80004130:	00000097          	auipc	ra,0x0
    80004134:	d68080e7          	jalr	-664(ra) # 80003e98 <iupdate>
    ip->valid = 0;
    80004138:	0404ac23          	sw	zero,88(s1)
    releasesleep(&ip->lock);
    8000413c:	8552                	mv	a0,s4
    8000413e:	00001097          	auipc	ra,0x1
    80004142:	c2a080e7          	jalr	-982(ra) # 80004d68 <releasesleep>
    acquire(&icache.lock);
    80004146:	00021517          	auipc	a0,0x21
    8000414a:	96250513          	addi	a0,a0,-1694 # 80024aa8 <icache>
    8000414e:	ffffd097          	auipc	ra,0xffffd
    80004152:	b6c080e7          	jalr	-1172(ra) # 80000cba <acquire>
    80004156:	b7a9                	j	800040a0 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004158:	4088                	lw	a0,0(s1)
    8000415a:	fffff097          	auipc	ra,0xfffff
    8000415e:	5be080e7          	jalr	1470(ra) # 80003718 <bread>
    80004162:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80004164:	07050913          	addi	s2,a0,112
    80004168:	47050993          	addi	s3,a0,1136
    8000416c:	a809                	j	8000417e <iput+0x10a>
        bfree(ip->dev, a[j]);
    8000416e:	4088                	lw	a0,0(s1)
    80004170:	00000097          	auipc	ra,0x0
    80004174:	804080e7          	jalr	-2044(ra) # 80003974 <bfree>
    80004178:	0911                	addi	s2,s2,4
    for(j = 0; j < NINDIRECT; j++){
    8000417a:	01390663          	beq	s2,s3,80004186 <iput+0x112>
      if(a[j])
    8000417e:	00092583          	lw	a1,0(s2)
    80004182:	d9fd                	beqz	a1,80004178 <iput+0x104>
    80004184:	b7ed                	j	8000416e <iput+0xfa>
    brelse(bp);
    80004186:	8556                	mv	a0,s5
    80004188:	fffff097          	auipc	ra,0xfffff
    8000418c:	6d6080e7          	jalr	1750(ra) # 8000385e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004190:	0984a583          	lw	a1,152(s1)
    80004194:	4088                	lw	a0,0(s1)
    80004196:	fffff097          	auipc	ra,0xfffff
    8000419a:	7de080e7          	jalr	2014(ra) # 80003974 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000419e:	0804ac23          	sw	zero,152(s1)
    800041a2:	bfad                	j	8000411c <iput+0xa8>

00000000800041a4 <iunlockput>:
{
    800041a4:	1101                	addi	sp,sp,-32
    800041a6:	ec06                	sd	ra,24(sp)
    800041a8:	e822                	sd	s0,16(sp)
    800041aa:	e426                	sd	s1,8(sp)
    800041ac:	1000                	addi	s0,sp,32
    800041ae:	84aa                	mv	s1,a0
  iunlock(ip);
    800041b0:	00000097          	auipc	ra,0x0
    800041b4:	e78080e7          	jalr	-392(ra) # 80004028 <iunlock>
  iput(ip);
    800041b8:	8526                	mv	a0,s1
    800041ba:	00000097          	auipc	ra,0x0
    800041be:	eba080e7          	jalr	-326(ra) # 80004074 <iput>
}
    800041c2:	60e2                	ld	ra,24(sp)
    800041c4:	6442                	ld	s0,16(sp)
    800041c6:	64a2                	ld	s1,8(sp)
    800041c8:	6105                	addi	sp,sp,32
    800041ca:	8082                	ret

00000000800041cc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041cc:	1141                	addi	sp,sp,-16
    800041ce:	e422                	sd	s0,8(sp)
    800041d0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800041d2:	411c                	lw	a5,0(a0)
    800041d4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800041d6:	415c                	lw	a5,4(a0)
    800041d8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800041da:	05c51783          	lh	a5,92(a0)
    800041de:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800041e2:	06251783          	lh	a5,98(a0)
    800041e6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800041ea:	06456783          	lwu	a5,100(a0)
    800041ee:	e99c                	sd	a5,16(a1)
}
    800041f0:	6422                	ld	s0,8(sp)
    800041f2:	0141                	addi	sp,sp,16
    800041f4:	8082                	ret

00000000800041f6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041f6:	517c                	lw	a5,100(a0)
    800041f8:	0ed7e563          	bltu	a5,a3,800042e2 <readi+0xec>
{
    800041fc:	7159                	addi	sp,sp,-112
    800041fe:	f486                	sd	ra,104(sp)
    80004200:	f0a2                	sd	s0,96(sp)
    80004202:	eca6                	sd	s1,88(sp)
    80004204:	e8ca                	sd	s2,80(sp)
    80004206:	e4ce                	sd	s3,72(sp)
    80004208:	e0d2                	sd	s4,64(sp)
    8000420a:	fc56                	sd	s5,56(sp)
    8000420c:	f85a                	sd	s6,48(sp)
    8000420e:	f45e                	sd	s7,40(sp)
    80004210:	f062                	sd	s8,32(sp)
    80004212:	ec66                	sd	s9,24(sp)
    80004214:	e86a                	sd	s10,16(sp)
    80004216:	e46e                	sd	s11,8(sp)
    80004218:	1880                	addi	s0,sp,112
    8000421a:	8baa                	mv	s7,a0
    8000421c:	8c2e                	mv	s8,a1
    8000421e:	8a32                	mv	s4,a2
    80004220:	84b6                	mv	s1,a3
    80004222:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004224:	9f35                	addw	a4,a4,a3
    80004226:	0cd76063          	bltu	a4,a3,800042e6 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    8000422a:	00e7f463          	bleu	a4,a5,80004232 <readi+0x3c>
    n = ip->size - off;
    8000422e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004232:	080b0763          	beqz	s6,800042c0 <readi+0xca>
    80004236:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004238:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000423c:	5cfd                	li	s9,-1
    8000423e:	a82d                	j	80004278 <readi+0x82>
    80004240:	02091d93          	slli	s11,s2,0x20
    80004244:	020ddd93          	srli	s11,s11,0x20
    80004248:	070a8613          	addi	a2,s5,112
    8000424c:	86ee                	mv	a3,s11
    8000424e:	963a                	add	a2,a2,a4
    80004250:	85d2                	mv	a1,s4
    80004252:	8562                	mv	a0,s8
    80004254:	fffff097          	auipc	ra,0xfffff
    80004258:	940080e7          	jalr	-1728(ra) # 80002b94 <either_copyout>
    8000425c:	05950d63          	beq	a0,s9,800042b6 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80004260:	8556                	mv	a0,s5
    80004262:	fffff097          	auipc	ra,0xfffff
    80004266:	5fc080e7          	jalr	1532(ra) # 8000385e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000426a:	013909bb          	addw	s3,s2,s3
    8000426e:	009904bb          	addw	s1,s2,s1
    80004272:	9a6e                	add	s4,s4,s11
    80004274:	0569f663          	bleu	s6,s3,800042c0 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004278:	000ba903          	lw	s2,0(s7)
    8000427c:	00a4d59b          	srliw	a1,s1,0xa
    80004280:	855e                	mv	a0,s7
    80004282:	00000097          	auipc	ra,0x0
    80004286:	8d2080e7          	jalr	-1838(ra) # 80003b54 <bmap>
    8000428a:	0005059b          	sext.w	a1,a0
    8000428e:	854a                	mv	a0,s2
    80004290:	fffff097          	auipc	ra,0xfffff
    80004294:	488080e7          	jalr	1160(ra) # 80003718 <bread>
    80004298:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000429a:	3ff4f713          	andi	a4,s1,1023
    8000429e:	40ed07bb          	subw	a5,s10,a4
    800042a2:	413b06bb          	subw	a3,s6,s3
    800042a6:	893e                	mv	s2,a5
    800042a8:	2781                	sext.w	a5,a5
    800042aa:	0006861b          	sext.w	a2,a3
    800042ae:	f8f679e3          	bleu	a5,a2,80004240 <readi+0x4a>
    800042b2:	8936                	mv	s2,a3
    800042b4:	b771                	j	80004240 <readi+0x4a>
      brelse(bp);
    800042b6:	8556                	mv	a0,s5
    800042b8:	fffff097          	auipc	ra,0xfffff
    800042bc:	5a6080e7          	jalr	1446(ra) # 8000385e <brelse>
  }
  return n;
    800042c0:	000b051b          	sext.w	a0,s6
}
    800042c4:	70a6                	ld	ra,104(sp)
    800042c6:	7406                	ld	s0,96(sp)
    800042c8:	64e6                	ld	s1,88(sp)
    800042ca:	6946                	ld	s2,80(sp)
    800042cc:	69a6                	ld	s3,72(sp)
    800042ce:	6a06                	ld	s4,64(sp)
    800042d0:	7ae2                	ld	s5,56(sp)
    800042d2:	7b42                	ld	s6,48(sp)
    800042d4:	7ba2                	ld	s7,40(sp)
    800042d6:	7c02                	ld	s8,32(sp)
    800042d8:	6ce2                	ld	s9,24(sp)
    800042da:	6d42                	ld	s10,16(sp)
    800042dc:	6da2                	ld	s11,8(sp)
    800042de:	6165                	addi	sp,sp,112
    800042e0:	8082                	ret
    return -1;
    800042e2:	557d                	li	a0,-1
}
    800042e4:	8082                	ret
    return -1;
    800042e6:	557d                	li	a0,-1
    800042e8:	bff1                	j	800042c4 <readi+0xce>

00000000800042ea <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042ea:	517c                	lw	a5,100(a0)
    800042ec:	10d7e663          	bltu	a5,a3,800043f8 <writei+0x10e>
{
    800042f0:	7159                	addi	sp,sp,-112
    800042f2:	f486                	sd	ra,104(sp)
    800042f4:	f0a2                	sd	s0,96(sp)
    800042f6:	eca6                	sd	s1,88(sp)
    800042f8:	e8ca                	sd	s2,80(sp)
    800042fa:	e4ce                	sd	s3,72(sp)
    800042fc:	e0d2                	sd	s4,64(sp)
    800042fe:	fc56                	sd	s5,56(sp)
    80004300:	f85a                	sd	s6,48(sp)
    80004302:	f45e                	sd	s7,40(sp)
    80004304:	f062                	sd	s8,32(sp)
    80004306:	ec66                	sd	s9,24(sp)
    80004308:	e86a                	sd	s10,16(sp)
    8000430a:	e46e                	sd	s11,8(sp)
    8000430c:	1880                	addi	s0,sp,112
    8000430e:	8baa                	mv	s7,a0
    80004310:	8c2e                	mv	s8,a1
    80004312:	8ab2                	mv	s5,a2
    80004314:	84b6                	mv	s1,a3
    80004316:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004318:	00e687bb          	addw	a5,a3,a4
    8000431c:	0ed7e063          	bltu	a5,a3,800043fc <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004320:	00043737          	lui	a4,0x43
    80004324:	0cf76e63          	bltu	a4,a5,80004400 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004328:	0a0b0763          	beqz	s6,800043d6 <writei+0xec>
    8000432c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000432e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004332:	5cfd                	li	s9,-1
    80004334:	a091                	j	80004378 <writei+0x8e>
    80004336:	02091d93          	slli	s11,s2,0x20
    8000433a:	020ddd93          	srli	s11,s11,0x20
    8000433e:	07098513          	addi	a0,s3,112
    80004342:	86ee                	mv	a3,s11
    80004344:	8656                	mv	a2,s5
    80004346:	85e2                	mv	a1,s8
    80004348:	953a                	add	a0,a0,a4
    8000434a:	fffff097          	auipc	ra,0xfffff
    8000434e:	8a0080e7          	jalr	-1888(ra) # 80002bea <either_copyin>
    80004352:	07950263          	beq	a0,s9,800043b6 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004356:	854e                	mv	a0,s3
    80004358:	00001097          	auipc	ra,0x1
    8000435c:	830080e7          	jalr	-2000(ra) # 80004b88 <log_write>
    brelse(bp);
    80004360:	854e                	mv	a0,s3
    80004362:	fffff097          	auipc	ra,0xfffff
    80004366:	4fc080e7          	jalr	1276(ra) # 8000385e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000436a:	01490a3b          	addw	s4,s2,s4
    8000436e:	009904bb          	addw	s1,s2,s1
    80004372:	9aee                	add	s5,s5,s11
    80004374:	056a7663          	bleu	s6,s4,800043c0 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004378:	000ba903          	lw	s2,0(s7)
    8000437c:	00a4d59b          	srliw	a1,s1,0xa
    80004380:	855e                	mv	a0,s7
    80004382:	fffff097          	auipc	ra,0xfffff
    80004386:	7d2080e7          	jalr	2002(ra) # 80003b54 <bmap>
    8000438a:	0005059b          	sext.w	a1,a0
    8000438e:	854a                	mv	a0,s2
    80004390:	fffff097          	auipc	ra,0xfffff
    80004394:	388080e7          	jalr	904(ra) # 80003718 <bread>
    80004398:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000439a:	3ff4f713          	andi	a4,s1,1023
    8000439e:	40ed07bb          	subw	a5,s10,a4
    800043a2:	414b06bb          	subw	a3,s6,s4
    800043a6:	893e                	mv	s2,a5
    800043a8:	2781                	sext.w	a5,a5
    800043aa:	0006861b          	sext.w	a2,a3
    800043ae:	f8f674e3          	bleu	a5,a2,80004336 <writei+0x4c>
    800043b2:	8936                	mv	s2,a3
    800043b4:	b749                	j	80004336 <writei+0x4c>
      brelse(bp);
    800043b6:	854e                	mv	a0,s3
    800043b8:	fffff097          	auipc	ra,0xfffff
    800043bc:	4a6080e7          	jalr	1190(ra) # 8000385e <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    800043c0:	064ba783          	lw	a5,100(s7)
    800043c4:	0097f463          	bleu	s1,a5,800043cc <writei+0xe2>
      ip->size = off;
    800043c8:	069ba223          	sw	s1,100(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    800043cc:	855e                	mv	a0,s7
    800043ce:	00000097          	auipc	ra,0x0
    800043d2:	aca080e7          	jalr	-1334(ra) # 80003e98 <iupdate>
  }

  return n;
    800043d6:	000b051b          	sext.w	a0,s6
}
    800043da:	70a6                	ld	ra,104(sp)
    800043dc:	7406                	ld	s0,96(sp)
    800043de:	64e6                	ld	s1,88(sp)
    800043e0:	6946                	ld	s2,80(sp)
    800043e2:	69a6                	ld	s3,72(sp)
    800043e4:	6a06                	ld	s4,64(sp)
    800043e6:	7ae2                	ld	s5,56(sp)
    800043e8:	7b42                	ld	s6,48(sp)
    800043ea:	7ba2                	ld	s7,40(sp)
    800043ec:	7c02                	ld	s8,32(sp)
    800043ee:	6ce2                	ld	s9,24(sp)
    800043f0:	6d42                	ld	s10,16(sp)
    800043f2:	6da2                	ld	s11,8(sp)
    800043f4:	6165                	addi	sp,sp,112
    800043f6:	8082                	ret
    return -1;
    800043f8:	557d                	li	a0,-1
}
    800043fa:	8082                	ret
    return -1;
    800043fc:	557d                	li	a0,-1
    800043fe:	bff1                	j	800043da <writei+0xf0>
    return -1;
    80004400:	557d                	li	a0,-1
    80004402:	bfe1                	j	800043da <writei+0xf0>

0000000080004404 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004404:	1141                	addi	sp,sp,-16
    80004406:	e406                	sd	ra,8(sp)
    80004408:	e022                	sd	s0,0(sp)
    8000440a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000440c:	4639                	li	a2,14
    8000440e:	ffffd097          	auipc	ra,0xffffd
    80004412:	e08080e7          	jalr	-504(ra) # 80001216 <strncmp>
}
    80004416:	60a2                	ld	ra,8(sp)
    80004418:	6402                	ld	s0,0(sp)
    8000441a:	0141                	addi	sp,sp,16
    8000441c:	8082                	ret

000000008000441e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000441e:	7139                	addi	sp,sp,-64
    80004420:	fc06                	sd	ra,56(sp)
    80004422:	f822                	sd	s0,48(sp)
    80004424:	f426                	sd	s1,40(sp)
    80004426:	f04a                	sd	s2,32(sp)
    80004428:	ec4e                	sd	s3,24(sp)
    8000442a:	e852                	sd	s4,16(sp)
    8000442c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000442e:	05c51703          	lh	a4,92(a0)
    80004432:	4785                	li	a5,1
    80004434:	00f71a63          	bne	a4,a5,80004448 <dirlookup+0x2a>
    80004438:	892a                	mv	s2,a0
    8000443a:	89ae                	mv	s3,a1
    8000443c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000443e:	517c                	lw	a5,100(a0)
    80004440:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004442:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004444:	e79d                	bnez	a5,80004472 <dirlookup+0x54>
    80004446:	a8a5                	j	800044be <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004448:	00004517          	auipc	a0,0x4
    8000444c:	6f050513          	addi	a0,a0,1776 # 80008b38 <userret+0xaa8>
    80004450:	ffffc097          	auipc	ra,0xffffc
    80004454:	334080e7          	jalr	820(ra) # 80000784 <panic>
      panic("dirlookup read");
    80004458:	00004517          	auipc	a0,0x4
    8000445c:	6f850513          	addi	a0,a0,1784 # 80008b50 <userret+0xac0>
    80004460:	ffffc097          	auipc	ra,0xffffc
    80004464:	324080e7          	jalr	804(ra) # 80000784 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004468:	24c1                	addiw	s1,s1,16
    8000446a:	06492783          	lw	a5,100(s2)
    8000446e:	04f4f763          	bleu	a5,s1,800044bc <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004472:	4741                	li	a4,16
    80004474:	86a6                	mv	a3,s1
    80004476:	fc040613          	addi	a2,s0,-64
    8000447a:	4581                	li	a1,0
    8000447c:	854a                	mv	a0,s2
    8000447e:	00000097          	auipc	ra,0x0
    80004482:	d78080e7          	jalr	-648(ra) # 800041f6 <readi>
    80004486:	47c1                	li	a5,16
    80004488:	fcf518e3          	bne	a0,a5,80004458 <dirlookup+0x3a>
    if(de.inum == 0)
    8000448c:	fc045783          	lhu	a5,-64(s0)
    80004490:	dfe1                	beqz	a5,80004468 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004492:	fc240593          	addi	a1,s0,-62
    80004496:	854e                	mv	a0,s3
    80004498:	00000097          	auipc	ra,0x0
    8000449c:	f6c080e7          	jalr	-148(ra) # 80004404 <namecmp>
    800044a0:	f561                	bnez	a0,80004468 <dirlookup+0x4a>
      if(poff)
    800044a2:	000a0463          	beqz	s4,800044aa <dirlookup+0x8c>
        *poff = off;
    800044a6:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    800044aa:	fc045583          	lhu	a1,-64(s0)
    800044ae:	00092503          	lw	a0,0(s2)
    800044b2:	fffff097          	auipc	ra,0xfffff
    800044b6:	77c080e7          	jalr	1916(ra) # 80003c2e <iget>
    800044ba:	a011                	j	800044be <dirlookup+0xa0>
  return 0;
    800044bc:	4501                	li	a0,0
}
    800044be:	70e2                	ld	ra,56(sp)
    800044c0:	7442                	ld	s0,48(sp)
    800044c2:	74a2                	ld	s1,40(sp)
    800044c4:	7902                	ld	s2,32(sp)
    800044c6:	69e2                	ld	s3,24(sp)
    800044c8:	6a42                	ld	s4,16(sp)
    800044ca:	6121                	addi	sp,sp,64
    800044cc:	8082                	ret

00000000800044ce <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044ce:	711d                	addi	sp,sp,-96
    800044d0:	ec86                	sd	ra,88(sp)
    800044d2:	e8a2                	sd	s0,80(sp)
    800044d4:	e4a6                	sd	s1,72(sp)
    800044d6:	e0ca                	sd	s2,64(sp)
    800044d8:	fc4e                	sd	s3,56(sp)
    800044da:	f852                	sd	s4,48(sp)
    800044dc:	f456                	sd	s5,40(sp)
    800044de:	f05a                	sd	s6,32(sp)
    800044e0:	ec5e                	sd	s7,24(sp)
    800044e2:	e862                	sd	s8,16(sp)
    800044e4:	e466                	sd	s9,8(sp)
    800044e6:	1080                	addi	s0,sp,96
    800044e8:	84aa                	mv	s1,a0
    800044ea:	8bae                	mv	s7,a1
    800044ec:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800044ee:	00054703          	lbu	a4,0(a0)
    800044f2:	02f00793          	li	a5,47
    800044f6:	02f70363          	beq	a4,a5,8000451c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800044fa:	ffffe097          	auipc	ra,0xffffe
    800044fe:	b46080e7          	jalr	-1210(ra) # 80002040 <myproc>
    80004502:	16853503          	ld	a0,360(a0)
    80004506:	00000097          	auipc	ra,0x0
    8000450a:	a20080e7          	jalr	-1504(ra) # 80003f26 <idup>
    8000450e:	89aa                	mv	s3,a0
  while(*path == '/')
    80004510:	02f00913          	li	s2,47
  len = path - s;
    80004514:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004516:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004518:	4c05                	li	s8,1
    8000451a:	a865                	j	800045d2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000451c:	4585                	li	a1,1
    8000451e:	4501                	li	a0,0
    80004520:	fffff097          	auipc	ra,0xfffff
    80004524:	70e080e7          	jalr	1806(ra) # 80003c2e <iget>
    80004528:	89aa                	mv	s3,a0
    8000452a:	b7dd                	j	80004510 <namex+0x42>
      iunlockput(ip);
    8000452c:	854e                	mv	a0,s3
    8000452e:	00000097          	auipc	ra,0x0
    80004532:	c76080e7          	jalr	-906(ra) # 800041a4 <iunlockput>
      return 0;
    80004536:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004538:	854e                	mv	a0,s3
    8000453a:	60e6                	ld	ra,88(sp)
    8000453c:	6446                	ld	s0,80(sp)
    8000453e:	64a6                	ld	s1,72(sp)
    80004540:	6906                	ld	s2,64(sp)
    80004542:	79e2                	ld	s3,56(sp)
    80004544:	7a42                	ld	s4,48(sp)
    80004546:	7aa2                	ld	s5,40(sp)
    80004548:	7b02                	ld	s6,32(sp)
    8000454a:	6be2                	ld	s7,24(sp)
    8000454c:	6c42                	ld	s8,16(sp)
    8000454e:	6ca2                	ld	s9,8(sp)
    80004550:	6125                	addi	sp,sp,96
    80004552:	8082                	ret
      iunlock(ip);
    80004554:	854e                	mv	a0,s3
    80004556:	00000097          	auipc	ra,0x0
    8000455a:	ad2080e7          	jalr	-1326(ra) # 80004028 <iunlock>
      return ip;
    8000455e:	bfe9                	j	80004538 <namex+0x6a>
      iunlockput(ip);
    80004560:	854e                	mv	a0,s3
    80004562:	00000097          	auipc	ra,0x0
    80004566:	c42080e7          	jalr	-958(ra) # 800041a4 <iunlockput>
      return 0;
    8000456a:	89d2                	mv	s3,s4
    8000456c:	b7f1                	j	80004538 <namex+0x6a>
  len = path - s;
    8000456e:	40b48633          	sub	a2,s1,a1
    80004572:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004576:	094cd663          	ble	s4,s9,80004602 <namex+0x134>
    memmove(name, s, DIRSIZ);
    8000457a:	4639                	li	a2,14
    8000457c:	8556                	mv	a0,s5
    8000457e:	ffffd097          	auipc	ra,0xffffd
    80004582:	c1c080e7          	jalr	-996(ra) # 8000119a <memmove>
  while(*path == '/')
    80004586:	0004c783          	lbu	a5,0(s1)
    8000458a:	01279763          	bne	a5,s2,80004598 <namex+0xca>
    path++;
    8000458e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004590:	0004c783          	lbu	a5,0(s1)
    80004594:	ff278de3          	beq	a5,s2,8000458e <namex+0xc0>
    ilock(ip);
    80004598:	854e                	mv	a0,s3
    8000459a:	00000097          	auipc	ra,0x0
    8000459e:	9ca080e7          	jalr	-1590(ra) # 80003f64 <ilock>
    if(ip->type != T_DIR){
    800045a2:	05c99783          	lh	a5,92(s3)
    800045a6:	f98793e3          	bne	a5,s8,8000452c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800045aa:	000b8563          	beqz	s7,800045b4 <namex+0xe6>
    800045ae:	0004c783          	lbu	a5,0(s1)
    800045b2:	d3cd                	beqz	a5,80004554 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800045b4:	865a                	mv	a2,s6
    800045b6:	85d6                	mv	a1,s5
    800045b8:	854e                	mv	a0,s3
    800045ba:	00000097          	auipc	ra,0x0
    800045be:	e64080e7          	jalr	-412(ra) # 8000441e <dirlookup>
    800045c2:	8a2a                	mv	s4,a0
    800045c4:	dd51                	beqz	a0,80004560 <namex+0x92>
    iunlockput(ip);
    800045c6:	854e                	mv	a0,s3
    800045c8:	00000097          	auipc	ra,0x0
    800045cc:	bdc080e7          	jalr	-1060(ra) # 800041a4 <iunlockput>
    ip = next;
    800045d0:	89d2                	mv	s3,s4
  while(*path == '/')
    800045d2:	0004c783          	lbu	a5,0(s1)
    800045d6:	05279d63          	bne	a5,s2,80004630 <namex+0x162>
    path++;
    800045da:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045dc:	0004c783          	lbu	a5,0(s1)
    800045e0:	ff278de3          	beq	a5,s2,800045da <namex+0x10c>
  if(*path == 0)
    800045e4:	cf8d                	beqz	a5,8000461e <namex+0x150>
  while(*path != '/' && *path != 0)
    800045e6:	01278b63          	beq	a5,s2,800045fc <namex+0x12e>
    800045ea:	c795                	beqz	a5,80004616 <namex+0x148>
    path++;
    800045ec:	85a6                	mv	a1,s1
    path++;
    800045ee:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800045f0:	0004c783          	lbu	a5,0(s1)
    800045f4:	f7278de3          	beq	a5,s2,8000456e <namex+0xa0>
    800045f8:	fbfd                	bnez	a5,800045ee <namex+0x120>
    800045fa:	bf95                	j	8000456e <namex+0xa0>
    800045fc:	85a6                	mv	a1,s1
  len = path - s;
    800045fe:	8a5a                	mv	s4,s6
    80004600:	865a                	mv	a2,s6
    memmove(name, s, len);
    80004602:	2601                	sext.w	a2,a2
    80004604:	8556                	mv	a0,s5
    80004606:	ffffd097          	auipc	ra,0xffffd
    8000460a:	b94080e7          	jalr	-1132(ra) # 8000119a <memmove>
    name[len] = 0;
    8000460e:	9a56                	add	s4,s4,s5
    80004610:	000a0023          	sb	zero,0(s4)
    80004614:	bf8d                	j	80004586 <namex+0xb8>
  while(*path != '/' && *path != 0)
    80004616:	85a6                	mv	a1,s1
  len = path - s;
    80004618:	8a5a                	mv	s4,s6
    8000461a:	865a                	mv	a2,s6
    8000461c:	b7dd                	j	80004602 <namex+0x134>
  if(nameiparent){
    8000461e:	f00b8de3          	beqz	s7,80004538 <namex+0x6a>
    iput(ip);
    80004622:	854e                	mv	a0,s3
    80004624:	00000097          	auipc	ra,0x0
    80004628:	a50080e7          	jalr	-1456(ra) # 80004074 <iput>
    return 0;
    8000462c:	4981                	li	s3,0
    8000462e:	b729                	j	80004538 <namex+0x6a>
  if(*path == 0)
    80004630:	d7fd                	beqz	a5,8000461e <namex+0x150>
    80004632:	85a6                	mv	a1,s1
    80004634:	bf6d                	j	800045ee <namex+0x120>

0000000080004636 <dirlink>:
{
    80004636:	7139                	addi	sp,sp,-64
    80004638:	fc06                	sd	ra,56(sp)
    8000463a:	f822                	sd	s0,48(sp)
    8000463c:	f426                	sd	s1,40(sp)
    8000463e:	f04a                	sd	s2,32(sp)
    80004640:	ec4e                	sd	s3,24(sp)
    80004642:	e852                	sd	s4,16(sp)
    80004644:	0080                	addi	s0,sp,64
    80004646:	892a                	mv	s2,a0
    80004648:	8a2e                	mv	s4,a1
    8000464a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000464c:	4601                	li	a2,0
    8000464e:	00000097          	auipc	ra,0x0
    80004652:	dd0080e7          	jalr	-560(ra) # 8000441e <dirlookup>
    80004656:	e93d                	bnez	a0,800046cc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004658:	06492483          	lw	s1,100(s2)
    8000465c:	c49d                	beqz	s1,8000468a <dirlink+0x54>
    8000465e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004660:	4741                	li	a4,16
    80004662:	86a6                	mv	a3,s1
    80004664:	fc040613          	addi	a2,s0,-64
    80004668:	4581                	li	a1,0
    8000466a:	854a                	mv	a0,s2
    8000466c:	00000097          	auipc	ra,0x0
    80004670:	b8a080e7          	jalr	-1142(ra) # 800041f6 <readi>
    80004674:	47c1                	li	a5,16
    80004676:	06f51163          	bne	a0,a5,800046d8 <dirlink+0xa2>
    if(de.inum == 0)
    8000467a:	fc045783          	lhu	a5,-64(s0)
    8000467e:	c791                	beqz	a5,8000468a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004680:	24c1                	addiw	s1,s1,16
    80004682:	06492783          	lw	a5,100(s2)
    80004686:	fcf4ede3          	bltu	s1,a5,80004660 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000468a:	4639                	li	a2,14
    8000468c:	85d2                	mv	a1,s4
    8000468e:	fc240513          	addi	a0,s0,-62
    80004692:	ffffd097          	auipc	ra,0xffffd
    80004696:	bd4080e7          	jalr	-1068(ra) # 80001266 <strncpy>
  de.inum = inum;
    8000469a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000469e:	4741                	li	a4,16
    800046a0:	86a6                	mv	a3,s1
    800046a2:	fc040613          	addi	a2,s0,-64
    800046a6:	4581                	li	a1,0
    800046a8:	854a                	mv	a0,s2
    800046aa:	00000097          	auipc	ra,0x0
    800046ae:	c40080e7          	jalr	-960(ra) # 800042ea <writei>
    800046b2:	4741                	li	a4,16
  return 0;
    800046b4:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046b6:	02e51963          	bne	a0,a4,800046e8 <dirlink+0xb2>
}
    800046ba:	853e                	mv	a0,a5
    800046bc:	70e2                	ld	ra,56(sp)
    800046be:	7442                	ld	s0,48(sp)
    800046c0:	74a2                	ld	s1,40(sp)
    800046c2:	7902                	ld	s2,32(sp)
    800046c4:	69e2                	ld	s3,24(sp)
    800046c6:	6a42                	ld	s4,16(sp)
    800046c8:	6121                	addi	sp,sp,64
    800046ca:	8082                	ret
    iput(ip);
    800046cc:	00000097          	auipc	ra,0x0
    800046d0:	9a8080e7          	jalr	-1624(ra) # 80004074 <iput>
    return -1;
    800046d4:	57fd                	li	a5,-1
    800046d6:	b7d5                	j	800046ba <dirlink+0x84>
      panic("dirlink read");
    800046d8:	00004517          	auipc	a0,0x4
    800046dc:	48850513          	addi	a0,a0,1160 # 80008b60 <userret+0xad0>
    800046e0:	ffffc097          	auipc	ra,0xffffc
    800046e4:	0a4080e7          	jalr	164(ra) # 80000784 <panic>
    panic("dirlink");
    800046e8:	00004517          	auipc	a0,0x4
    800046ec:	59850513          	addi	a0,a0,1432 # 80008c80 <userret+0xbf0>
    800046f0:	ffffc097          	auipc	ra,0xffffc
    800046f4:	094080e7          	jalr	148(ra) # 80000784 <panic>

00000000800046f8 <namei>:

struct inode*
namei(char *path)
{
    800046f8:	1101                	addi	sp,sp,-32
    800046fa:	ec06                	sd	ra,24(sp)
    800046fc:	e822                	sd	s0,16(sp)
    800046fe:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004700:	fe040613          	addi	a2,s0,-32
    80004704:	4581                	li	a1,0
    80004706:	00000097          	auipc	ra,0x0
    8000470a:	dc8080e7          	jalr	-568(ra) # 800044ce <namex>
}
    8000470e:	60e2                	ld	ra,24(sp)
    80004710:	6442                	ld	s0,16(sp)
    80004712:	6105                	addi	sp,sp,32
    80004714:	8082                	ret

0000000080004716 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004716:	1141                	addi	sp,sp,-16
    80004718:	e406                	sd	ra,8(sp)
    8000471a:	e022                	sd	s0,0(sp)
    8000471c:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    8000471e:	862e                	mv	a2,a1
    80004720:	4585                	li	a1,1
    80004722:	00000097          	auipc	ra,0x0
    80004726:	dac080e7          	jalr	-596(ra) # 800044ce <namex>
}
    8000472a:	60a2                	ld	ra,8(sp)
    8000472c:	6402                	ld	s0,0(sp)
    8000472e:	0141                	addi	sp,sp,16
    80004730:	8082                	ret

0000000080004732 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80004732:	7179                	addi	sp,sp,-48
    80004734:	f406                	sd	ra,40(sp)
    80004736:	f022                	sd	s0,32(sp)
    80004738:	ec26                	sd	s1,24(sp)
    8000473a:	e84a                	sd	s2,16(sp)
    8000473c:	e44e                	sd	s3,8(sp)
    8000473e:	1800                	addi	s0,sp,48
  struct buf *buf = bread(dev, log[dev].start);
    80004740:	00151913          	slli	s2,a0,0x1
    80004744:	992a                	add	s2,s2,a0
    80004746:	00691793          	slli	a5,s2,0x6
    8000474a:	00022917          	auipc	s2,0x22
    8000474e:	2ce90913          	addi	s2,s2,718 # 80026a18 <log>
    80004752:	993e                	add	s2,s2,a5
    80004754:	03092583          	lw	a1,48(s2)
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	fc0080e7          	jalr	-64(ra) # 80003718 <bread>
    80004760:	89aa                	mv	s3,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80004762:	04492783          	lw	a5,68(s2)
    80004766:	d93c                	sw	a5,112(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004768:	04492783          	lw	a5,68(s2)
    8000476c:	00f05f63          	blez	a5,8000478a <write_head+0x58>
    80004770:	87ca                	mv	a5,s2
    80004772:	07450693          	addi	a3,a0,116
    80004776:	4701                	li	a4,0
    80004778:	85ca                	mv	a1,s2
    hb->block[i] = log[dev].lh.block[i];
    8000477a:	47b0                	lw	a2,72(a5)
    8000477c:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000477e:	2705                	addiw	a4,a4,1
    80004780:	0791                	addi	a5,a5,4
    80004782:	0691                	addi	a3,a3,4
    80004784:	41f0                	lw	a2,68(a1)
    80004786:	fec74ae3          	blt	a4,a2,8000477a <write_head+0x48>
  }
  bwrite(buf);
    8000478a:	854e                	mv	a0,s3
    8000478c:	fffff097          	auipc	ra,0xfffff
    80004790:	092080e7          	jalr	146(ra) # 8000381e <bwrite>
  brelse(buf);
    80004794:	854e                	mv	a0,s3
    80004796:	fffff097          	auipc	ra,0xfffff
    8000479a:	0c8080e7          	jalr	200(ra) # 8000385e <brelse>
}
    8000479e:	70a2                	ld	ra,40(sp)
    800047a0:	7402                	ld	s0,32(sp)
    800047a2:	64e2                	ld	s1,24(sp)
    800047a4:	6942                	ld	s2,16(sp)
    800047a6:	69a2                	ld	s3,8(sp)
    800047a8:	6145                	addi	sp,sp,48
    800047aa:	8082                	ret

00000000800047ac <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800047ac:	00151793          	slli	a5,a0,0x1
    800047b0:	97aa                	add	a5,a5,a0
    800047b2:	079a                	slli	a5,a5,0x6
    800047b4:	00022717          	auipc	a4,0x22
    800047b8:	26470713          	addi	a4,a4,612 # 80026a18 <log>
    800047bc:	97ba                	add	a5,a5,a4
    800047be:	43fc                	lw	a5,68(a5)
    800047c0:	0af05863          	blez	a5,80004870 <install_trans+0xc4>
{
    800047c4:	7139                	addi	sp,sp,-64
    800047c6:	fc06                	sd	ra,56(sp)
    800047c8:	f822                	sd	s0,48(sp)
    800047ca:	f426                	sd	s1,40(sp)
    800047cc:	f04a                	sd	s2,32(sp)
    800047ce:	ec4e                	sd	s3,24(sp)
    800047d0:	e852                	sd	s4,16(sp)
    800047d2:	e456                	sd	s5,8(sp)
    800047d4:	e05a                	sd	s6,0(sp)
    800047d6:	0080                	addi	s0,sp,64
    800047d8:	00151993          	slli	s3,a0,0x1
    800047dc:	99aa                	add	s3,s3,a0
    800047de:	00699793          	slli	a5,s3,0x6
    800047e2:	00f709b3          	add	s3,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800047e6:	4901                	li	s2,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    800047e8:	00050b1b          	sext.w	s6,a0
    800047ec:	8ace                	mv	s5,s3
    800047ee:	030aa583          	lw	a1,48(s5)
    800047f2:	012585bb          	addw	a1,a1,s2
    800047f6:	2585                	addiw	a1,a1,1
    800047f8:	855a                	mv	a0,s6
    800047fa:	fffff097          	auipc	ra,0xfffff
    800047fe:	f1e080e7          	jalr	-226(ra) # 80003718 <bread>
    80004802:	8a2a                	mv	s4,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80004804:	0489a583          	lw	a1,72(s3)
    80004808:	855a                	mv	a0,s6
    8000480a:	fffff097          	auipc	ra,0xfffff
    8000480e:	f0e080e7          	jalr	-242(ra) # 80003718 <bread>
    80004812:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004814:	40000613          	li	a2,1024
    80004818:	070a0593          	addi	a1,s4,112
    8000481c:	07050513          	addi	a0,a0,112
    80004820:	ffffd097          	auipc	ra,0xffffd
    80004824:	97a080e7          	jalr	-1670(ra) # 8000119a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004828:	8526                	mv	a0,s1
    8000482a:	fffff097          	auipc	ra,0xfffff
    8000482e:	ff4080e7          	jalr	-12(ra) # 8000381e <bwrite>
    bunpin(dbuf);
    80004832:	8526                	mv	a0,s1
    80004834:	fffff097          	auipc	ra,0xfffff
    80004838:	104080e7          	jalr	260(ra) # 80003938 <bunpin>
    brelse(lbuf);
    8000483c:	8552                	mv	a0,s4
    8000483e:	fffff097          	auipc	ra,0xfffff
    80004842:	020080e7          	jalr	32(ra) # 8000385e <brelse>
    brelse(dbuf);
    80004846:	8526                	mv	a0,s1
    80004848:	fffff097          	auipc	ra,0xfffff
    8000484c:	016080e7          	jalr	22(ra) # 8000385e <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004850:	2905                	addiw	s2,s2,1
    80004852:	0991                	addi	s3,s3,4
    80004854:	044aa783          	lw	a5,68(s5)
    80004858:	f8f94be3          	blt	s2,a5,800047ee <install_trans+0x42>
}
    8000485c:	70e2                	ld	ra,56(sp)
    8000485e:	7442                	ld	s0,48(sp)
    80004860:	74a2                	ld	s1,40(sp)
    80004862:	7902                	ld	s2,32(sp)
    80004864:	69e2                	ld	s3,24(sp)
    80004866:	6a42                	ld	s4,16(sp)
    80004868:	6aa2                	ld	s5,8(sp)
    8000486a:	6b02                	ld	s6,0(sp)
    8000486c:	6121                	addi	sp,sp,64
    8000486e:	8082                	ret
    80004870:	8082                	ret

0000000080004872 <initlog>:
{
    80004872:	7179                	addi	sp,sp,-48
    80004874:	f406                	sd	ra,40(sp)
    80004876:	f022                	sd	s0,32(sp)
    80004878:	ec26                	sd	s1,24(sp)
    8000487a:	e84a                	sd	s2,16(sp)
    8000487c:	e44e                	sd	s3,8(sp)
    8000487e:	e052                	sd	s4,0(sp)
    80004880:	1800                	addi	s0,sp,48
    80004882:	892a                	mv	s2,a0
    80004884:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80004886:	00151713          	slli	a4,a0,0x1
    8000488a:	972a                	add	a4,a4,a0
    8000488c:	00671493          	slli	s1,a4,0x6
    80004890:	00022997          	auipc	s3,0x22
    80004894:	18898993          	addi	s3,s3,392 # 80026a18 <log>
    80004898:	99a6                	add	s3,s3,s1
    8000489a:	00004597          	auipc	a1,0x4
    8000489e:	2d658593          	addi	a1,a1,726 # 80008b70 <userret+0xae0>
    800048a2:	854e                	mv	a0,s3
    800048a4:	ffffc097          	auipc	ra,0xffffc
    800048a8:	2a8080e7          	jalr	680(ra) # 80000b4c <initlock>
  log[dev].start = sb->logstart;
    800048ac:	014a2583          	lw	a1,20(s4)
    800048b0:	02b9a823          	sw	a1,48(s3)
  log[dev].size = sb->nlog;
    800048b4:	010a2783          	lw	a5,16(s4)
    800048b8:	02f9aa23          	sw	a5,52(s3)
  log[dev].dev = dev;
    800048bc:	0529a023          	sw	s2,64(s3)
  struct buf *buf = bread(dev, log[dev].start);
    800048c0:	854a                	mv	a0,s2
    800048c2:	fffff097          	auipc	ra,0xfffff
    800048c6:	e56080e7          	jalr	-426(ra) # 80003718 <bread>
  log[dev].lh.n = lh->n;
    800048ca:	593c                	lw	a5,112(a0)
    800048cc:	04f9a223          	sw	a5,68(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    800048d0:	02f05663          	blez	a5,800048fc <initlog+0x8a>
    800048d4:	07450693          	addi	a3,a0,116
    800048d8:	00022717          	auipc	a4,0x22
    800048dc:	18870713          	addi	a4,a4,392 # 80026a60 <log+0x48>
    800048e0:	9726                	add	a4,a4,s1
    800048e2:	37fd                	addiw	a5,a5,-1
    800048e4:	1782                	slli	a5,a5,0x20
    800048e6:	9381                	srli	a5,a5,0x20
    800048e8:	078a                	slli	a5,a5,0x2
    800048ea:	07850613          	addi	a2,a0,120
    800048ee:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    800048f0:	4290                	lw	a2,0(a3)
    800048f2:	c310                	sw	a2,0(a4)
    800048f4:	0691                	addi	a3,a3,4
    800048f6:	0711                	addi	a4,a4,4
  for (i = 0; i < log[dev].lh.n; i++) {
    800048f8:	fef69ce3          	bne	a3,a5,800048f0 <initlog+0x7e>
  brelse(buf);
    800048fc:	fffff097          	auipc	ra,0xfffff
    80004900:	f62080e7          	jalr	-158(ra) # 8000385e <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    80004904:	854a                	mv	a0,s2
    80004906:	00000097          	auipc	ra,0x0
    8000490a:	ea6080e7          	jalr	-346(ra) # 800047ac <install_trans>
  log[dev].lh.n = 0;
    8000490e:	00191793          	slli	a5,s2,0x1
    80004912:	97ca                	add	a5,a5,s2
    80004914:	079a                	slli	a5,a5,0x6
    80004916:	00022717          	auipc	a4,0x22
    8000491a:	10270713          	addi	a4,a4,258 # 80026a18 <log>
    8000491e:	97ba                	add	a5,a5,a4
    80004920:	0407a223          	sw	zero,68(a5)
  write_head(dev); // clear the log
    80004924:	854a                	mv	a0,s2
    80004926:	00000097          	auipc	ra,0x0
    8000492a:	e0c080e7          	jalr	-500(ra) # 80004732 <write_head>
}
    8000492e:	70a2                	ld	ra,40(sp)
    80004930:	7402                	ld	s0,32(sp)
    80004932:	64e2                	ld	s1,24(sp)
    80004934:	6942                	ld	s2,16(sp)
    80004936:	69a2                	ld	s3,8(sp)
    80004938:	6a02                	ld	s4,0(sp)
    8000493a:	6145                	addi	sp,sp,48
    8000493c:	8082                	ret

000000008000493e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    8000493e:	7139                	addi	sp,sp,-64
    80004940:	fc06                	sd	ra,56(sp)
    80004942:	f822                	sd	s0,48(sp)
    80004944:	f426                	sd	s1,40(sp)
    80004946:	f04a                	sd	s2,32(sp)
    80004948:	ec4e                	sd	s3,24(sp)
    8000494a:	e852                	sd	s4,16(sp)
    8000494c:	e456                	sd	s5,8(sp)
    8000494e:	0080                	addi	s0,sp,64
    80004950:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80004952:	00151913          	slli	s2,a0,0x1
    80004956:	992a                	add	s2,s2,a0
    80004958:	00691793          	slli	a5,s2,0x6
    8000495c:	00022917          	auipc	s2,0x22
    80004960:	0bc90913          	addi	s2,s2,188 # 80026a18 <log>
    80004964:	993e                	add	s2,s2,a5
    80004966:	854a                	mv	a0,s2
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	352080e7          	jalr	850(ra) # 80000cba <acquire>
  while(1){
    if(log[dev].committing){
    80004970:	00022997          	auipc	s3,0x22
    80004974:	0a898993          	addi	s3,s3,168 # 80026a18 <log>
    80004978:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000497a:	4a79                	li	s4,30
    8000497c:	a039                	j	8000498a <begin_op+0x4c>
      sleep(&log, &log[dev].lock);
    8000497e:	85ca                	mv	a1,s2
    80004980:	854e                	mv	a0,s3
    80004982:	ffffe097          	auipc	ra,0xffffe
    80004986:	fb0080e7          	jalr	-80(ra) # 80002932 <sleep>
    if(log[dev].committing){
    8000498a:	5cdc                	lw	a5,60(s1)
    8000498c:	fbed                	bnez	a5,8000497e <begin_op+0x40>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000498e:	5c9c                	lw	a5,56(s1)
    80004990:	0017871b          	addiw	a4,a5,1
    80004994:	0007069b          	sext.w	a3,a4
    80004998:	0027179b          	slliw	a5,a4,0x2
    8000499c:	9fb9                	addw	a5,a5,a4
    8000499e:	0017979b          	slliw	a5,a5,0x1
    800049a2:	40f8                	lw	a4,68(s1)
    800049a4:	9fb9                	addw	a5,a5,a4
    800049a6:	00fa5963          	ble	a5,s4,800049b8 <begin_op+0x7a>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    800049aa:	85ca                	mv	a1,s2
    800049ac:	854e                	mv	a0,s3
    800049ae:	ffffe097          	auipc	ra,0xffffe
    800049b2:	f84080e7          	jalr	-124(ra) # 80002932 <sleep>
    800049b6:	bfd1                	j	8000498a <begin_op+0x4c>
    } else {
      log[dev].outstanding += 1;
    800049b8:	001a9793          	slli	a5,s5,0x1
    800049bc:	9abe                	add	s5,s5,a5
    800049be:	0a9a                	slli	s5,s5,0x6
    800049c0:	00022797          	auipc	a5,0x22
    800049c4:	05878793          	addi	a5,a5,88 # 80026a18 <log>
    800049c8:	9abe                	add	s5,s5,a5
    800049ca:	02daac23          	sw	a3,56(s5)
      release(&log[dev].lock);
    800049ce:	854a                	mv	a0,s2
    800049d0:	ffffc097          	auipc	ra,0xffffc
    800049d4:	536080e7          	jalr	1334(ra) # 80000f06 <release>
      break;
    }
  }
}
    800049d8:	70e2                	ld	ra,56(sp)
    800049da:	7442                	ld	s0,48(sp)
    800049dc:	74a2                	ld	s1,40(sp)
    800049de:	7902                	ld	s2,32(sp)
    800049e0:	69e2                	ld	s3,24(sp)
    800049e2:	6a42                	ld	s4,16(sp)
    800049e4:	6aa2                	ld	s5,8(sp)
    800049e6:	6121                	addi	sp,sp,64
    800049e8:	8082                	ret

00000000800049ea <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    800049ea:	715d                	addi	sp,sp,-80
    800049ec:	e486                	sd	ra,72(sp)
    800049ee:	e0a2                	sd	s0,64(sp)
    800049f0:	fc26                	sd	s1,56(sp)
    800049f2:	f84a                	sd	s2,48(sp)
    800049f4:	f44e                	sd	s3,40(sp)
    800049f6:	f052                	sd	s4,32(sp)
    800049f8:	ec56                	sd	s5,24(sp)
    800049fa:	e85a                	sd	s6,16(sp)
    800049fc:	e45e                	sd	s7,8(sp)
    800049fe:	e062                	sd	s8,0(sp)
    80004a00:	0880                	addi	s0,sp,80
    80004a02:	892a                	mv	s2,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    80004a04:	00151493          	slli	s1,a0,0x1
    80004a08:	94aa                	add	s1,s1,a0
    80004a0a:	00649793          	slli	a5,s1,0x6
    80004a0e:	00022497          	auipc	s1,0x22
    80004a12:	00a48493          	addi	s1,s1,10 # 80026a18 <log>
    80004a16:	94be                	add	s1,s1,a5
    80004a18:	8526                	mv	a0,s1
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	2a0080e7          	jalr	672(ra) # 80000cba <acquire>
  log[dev].outstanding -= 1;
    80004a22:	5c9c                	lw	a5,56(s1)
    80004a24:	37fd                	addiw	a5,a5,-1
    80004a26:	0007899b          	sext.w	s3,a5
    80004a2a:	dc9c                	sw	a5,56(s1)
  if(log[dev].committing)
    80004a2c:	5cdc                	lw	a5,60(s1)
    80004a2e:	e3b5                	bnez	a5,80004a92 <end_op+0xa8>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004a30:	06099963          	bnez	s3,80004aa2 <end_op+0xb8>
    do_commit = 1;
    log[dev].committing = 1;
    80004a34:	00191793          	slli	a5,s2,0x1
    80004a38:	97ca                	add	a5,a5,s2
    80004a3a:	079a                	slli	a5,a5,0x6
    80004a3c:	00022a17          	auipc	s4,0x22
    80004a40:	fdca0a13          	addi	s4,s4,-36 # 80026a18 <log>
    80004a44:	9a3e                	add	s4,s4,a5
    80004a46:	4785                	li	a5,1
    80004a48:	02fa2e23          	sw	a5,60(s4)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    80004a4c:	8526                	mv	a0,s1
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	4b8080e7          	jalr	1208(ra) # 80000f06 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    80004a56:	044a2783          	lw	a5,68(s4)
    80004a5a:	06f04d63          	bgtz	a5,80004ad4 <end_op+0xea>
    acquire(&log[dev].lock);
    80004a5e:	8526                	mv	a0,s1
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	25a080e7          	jalr	602(ra) # 80000cba <acquire>
    log[dev].committing = 0;
    80004a68:	00022517          	auipc	a0,0x22
    80004a6c:	fb050513          	addi	a0,a0,-80 # 80026a18 <log>
    80004a70:	00191793          	slli	a5,s2,0x1
    80004a74:	993e                	add	s2,s2,a5
    80004a76:	091a                	slli	s2,s2,0x6
    80004a78:	992a                	add	s2,s2,a0
    80004a7a:	02092e23          	sw	zero,60(s2)
    wakeup(&log);
    80004a7e:	ffffe097          	auipc	ra,0xffffe
    80004a82:	03a080e7          	jalr	58(ra) # 80002ab8 <wakeup>
    release(&log[dev].lock);
    80004a86:	8526                	mv	a0,s1
    80004a88:	ffffc097          	auipc	ra,0xffffc
    80004a8c:	47e080e7          	jalr	1150(ra) # 80000f06 <release>
}
    80004a90:	a035                	j	80004abc <end_op+0xd2>
    panic("log[dev].committing");
    80004a92:	00004517          	auipc	a0,0x4
    80004a96:	0e650513          	addi	a0,a0,230 # 80008b78 <userret+0xae8>
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	cea080e7          	jalr	-790(ra) # 80000784 <panic>
    wakeup(&log);
    80004aa2:	00022517          	auipc	a0,0x22
    80004aa6:	f7650513          	addi	a0,a0,-138 # 80026a18 <log>
    80004aaa:	ffffe097          	auipc	ra,0xffffe
    80004aae:	00e080e7          	jalr	14(ra) # 80002ab8 <wakeup>
  release(&log[dev].lock);
    80004ab2:	8526                	mv	a0,s1
    80004ab4:	ffffc097          	auipc	ra,0xffffc
    80004ab8:	452080e7          	jalr	1106(ra) # 80000f06 <release>
}
    80004abc:	60a6                	ld	ra,72(sp)
    80004abe:	6406                	ld	s0,64(sp)
    80004ac0:	74e2                	ld	s1,56(sp)
    80004ac2:	7942                	ld	s2,48(sp)
    80004ac4:	79a2                	ld	s3,40(sp)
    80004ac6:	7a02                	ld	s4,32(sp)
    80004ac8:	6ae2                	ld	s5,24(sp)
    80004aca:	6b42                	ld	s6,16(sp)
    80004acc:	6ba2                	ld	s7,8(sp)
    80004ace:	6c02                	ld	s8,0(sp)
    80004ad0:	6161                	addi	sp,sp,80
    80004ad2:	8082                	ret
    80004ad4:	8aa6                	mv	s5,s1
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80004ad6:	00090c1b          	sext.w	s8,s2
    80004ada:	00191b93          	slli	s7,s2,0x1
    80004ade:	9bca                	add	s7,s7,s2
    80004ae0:	006b9793          	slli	a5,s7,0x6
    80004ae4:	00022b97          	auipc	s7,0x22
    80004ae8:	f34b8b93          	addi	s7,s7,-204 # 80026a18 <log>
    80004aec:	9bbe                	add	s7,s7,a5
    80004aee:	030ba583          	lw	a1,48(s7)
    80004af2:	013585bb          	addw	a1,a1,s3
    80004af6:	2585                	addiw	a1,a1,1
    80004af8:	8562                	mv	a0,s8
    80004afa:	fffff097          	auipc	ra,0xfffff
    80004afe:	c1e080e7          	jalr	-994(ra) # 80003718 <bread>
    80004b02:	8a2a                	mv	s4,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80004b04:	048aa583          	lw	a1,72(s5)
    80004b08:	8562                	mv	a0,s8
    80004b0a:	fffff097          	auipc	ra,0xfffff
    80004b0e:	c0e080e7          	jalr	-1010(ra) # 80003718 <bread>
    80004b12:	8b2a                	mv	s6,a0
    memmove(to->data, from->data, BSIZE);
    80004b14:	40000613          	li	a2,1024
    80004b18:	07050593          	addi	a1,a0,112
    80004b1c:	070a0513          	addi	a0,s4,112
    80004b20:	ffffc097          	auipc	ra,0xffffc
    80004b24:	67a080e7          	jalr	1658(ra) # 8000119a <memmove>
    bwrite(to);  // write the log
    80004b28:	8552                	mv	a0,s4
    80004b2a:	fffff097          	auipc	ra,0xfffff
    80004b2e:	cf4080e7          	jalr	-780(ra) # 8000381e <bwrite>
    brelse(from);
    80004b32:	855a                	mv	a0,s6
    80004b34:	fffff097          	auipc	ra,0xfffff
    80004b38:	d2a080e7          	jalr	-726(ra) # 8000385e <brelse>
    brelse(to);
    80004b3c:	8552                	mv	a0,s4
    80004b3e:	fffff097          	auipc	ra,0xfffff
    80004b42:	d20080e7          	jalr	-736(ra) # 8000385e <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004b46:	2985                	addiw	s3,s3,1
    80004b48:	0a91                	addi	s5,s5,4
    80004b4a:	044ba783          	lw	a5,68(s7)
    80004b4e:	faf9c0e3          	blt	s3,a5,80004aee <end_op+0x104>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    80004b52:	854a                	mv	a0,s2
    80004b54:	00000097          	auipc	ra,0x0
    80004b58:	bde080e7          	jalr	-1058(ra) # 80004732 <write_head>
    install_trans(dev); // Now install writes to home locations
    80004b5c:	854a                	mv	a0,s2
    80004b5e:	00000097          	auipc	ra,0x0
    80004b62:	c4e080e7          	jalr	-946(ra) # 800047ac <install_trans>
    log[dev].lh.n = 0;
    80004b66:	00191793          	slli	a5,s2,0x1
    80004b6a:	97ca                	add	a5,a5,s2
    80004b6c:	079a                	slli	a5,a5,0x6
    80004b6e:	00022717          	auipc	a4,0x22
    80004b72:	eaa70713          	addi	a4,a4,-342 # 80026a18 <log>
    80004b76:	97ba                	add	a5,a5,a4
    80004b78:	0407a223          	sw	zero,68(a5)
    write_head(dev);    // Erase the transaction from the log
    80004b7c:	854a                	mv	a0,s2
    80004b7e:	00000097          	auipc	ra,0x0
    80004b82:	bb4080e7          	jalr	-1100(ra) # 80004732 <write_head>
    80004b86:	bde1                	j	80004a5e <end_op+0x74>

0000000080004b88 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004b88:	7179                	addi	sp,sp,-48
    80004b8a:	f406                	sd	ra,40(sp)
    80004b8c:	f022                	sd	s0,32(sp)
    80004b8e:	ec26                	sd	s1,24(sp)
    80004b90:	e84a                	sd	s2,16(sp)
    80004b92:	e44e                	sd	s3,8(sp)
    80004b94:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004b96:	4504                	lw	s1,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004b98:	00149793          	slli	a5,s1,0x1
    80004b9c:	97a6                	add	a5,a5,s1
    80004b9e:	079a                	slli	a5,a5,0x6
    80004ba0:	00022717          	auipc	a4,0x22
    80004ba4:	e7870713          	addi	a4,a4,-392 # 80026a18 <log>
    80004ba8:	97ba                	add	a5,a5,a4
    80004baa:	43f4                	lw	a3,68(a5)
    80004bac:	47f5                	li	a5,29
    80004bae:	0ad7c363          	blt	a5,a3,80004c54 <log_write+0xcc>
    80004bb2:	89aa                	mv	s3,a0
    80004bb4:	00149793          	slli	a5,s1,0x1
    80004bb8:	97a6                	add	a5,a5,s1
    80004bba:	079a                	slli	a5,a5,0x6
    80004bbc:	97ba                	add	a5,a5,a4
    80004bbe:	5bdc                	lw	a5,52(a5)
    80004bc0:	37fd                	addiw	a5,a5,-1
    80004bc2:	08f6d963          	ble	a5,a3,80004c54 <log_write+0xcc>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004bc6:	00149793          	slli	a5,s1,0x1
    80004bca:	97a6                	add	a5,a5,s1
    80004bcc:	079a                	slli	a5,a5,0x6
    80004bce:	00022717          	auipc	a4,0x22
    80004bd2:	e4a70713          	addi	a4,a4,-438 # 80026a18 <log>
    80004bd6:	97ba                	add	a5,a5,a4
    80004bd8:	5f9c                	lw	a5,56(a5)
    80004bda:	08f05563          	blez	a5,80004c64 <log_write+0xdc>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004bde:	00149913          	slli	s2,s1,0x1
    80004be2:	9926                	add	s2,s2,s1
    80004be4:	00691793          	slli	a5,s2,0x6
    80004be8:	00022917          	auipc	s2,0x22
    80004bec:	e3090913          	addi	s2,s2,-464 # 80026a18 <log>
    80004bf0:	993e                	add	s2,s2,a5
    80004bf2:	854a                	mv	a0,s2
    80004bf4:	ffffc097          	auipc	ra,0xffffc
    80004bf8:	0c6080e7          	jalr	198(ra) # 80000cba <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004bfc:	04492603          	lw	a2,68(s2)
    80004c00:	06c05a63          	blez	a2,80004c74 <log_write+0xec>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004c04:	00c9a583          	lw	a1,12(s3)
    80004c08:	04892783          	lw	a5,72(s2)
    80004c0c:	08b78263          	beq	a5,a1,80004c90 <log_write+0x108>
    80004c10:	874a                	mv	a4,s2
  for (i = 0; i < log[dev].lh.n; i++) {
    80004c12:	4781                	li	a5,0
    80004c14:	2785                	addiw	a5,a5,1
    80004c16:	06c78f63          	beq	a5,a2,80004c94 <log_write+0x10c>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004c1a:	4774                	lw	a3,76(a4)
    80004c1c:	0711                	addi	a4,a4,4
    80004c1e:	feb69be3          	bne	a3,a1,80004c14 <log_write+0x8c>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004c22:	00149713          	slli	a4,s1,0x1
    80004c26:	94ba                	add	s1,s1,a4
    80004c28:	0492                	slli	s1,s1,0x4
    80004c2a:	97a6                	add	a5,a5,s1
    80004c2c:	07c1                	addi	a5,a5,16
    80004c2e:	078a                	slli	a5,a5,0x2
    80004c30:	00022717          	auipc	a4,0x22
    80004c34:	de870713          	addi	a4,a4,-536 # 80026a18 <log>
    80004c38:	97ba                	add	a5,a5,a4
    80004c3a:	c78c                	sw	a1,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    log[dev].lh.n++;
  }
  release(&log[dev].lock);
    80004c3c:	854a                	mv	a0,s2
    80004c3e:	ffffc097          	auipc	ra,0xffffc
    80004c42:	2c8080e7          	jalr	712(ra) # 80000f06 <release>
}
    80004c46:	70a2                	ld	ra,40(sp)
    80004c48:	7402                	ld	s0,32(sp)
    80004c4a:	64e2                	ld	s1,24(sp)
    80004c4c:	6942                	ld	s2,16(sp)
    80004c4e:	69a2                	ld	s3,8(sp)
    80004c50:	6145                	addi	sp,sp,48
    80004c52:	8082                	ret
    panic("too big a transaction");
    80004c54:	00004517          	auipc	a0,0x4
    80004c58:	f3c50513          	addi	a0,a0,-196 # 80008b90 <userret+0xb00>
    80004c5c:	ffffc097          	auipc	ra,0xffffc
    80004c60:	b28080e7          	jalr	-1240(ra) # 80000784 <panic>
    panic("log_write outside of trans");
    80004c64:	00004517          	auipc	a0,0x4
    80004c68:	f4450513          	addi	a0,a0,-188 # 80008ba8 <userret+0xb18>
    80004c6c:	ffffc097          	auipc	ra,0xffffc
    80004c70:	b18080e7          	jalr	-1256(ra) # 80000784 <panic>
  log[dev].lh.block[i] = b->blockno;
    80004c74:	00149793          	slli	a5,s1,0x1
    80004c78:	97a6                	add	a5,a5,s1
    80004c7a:	079a                	slli	a5,a5,0x6
    80004c7c:	00022717          	auipc	a4,0x22
    80004c80:	d9c70713          	addi	a4,a4,-612 # 80026a18 <log>
    80004c84:	97ba                	add	a5,a5,a4
    80004c86:	00c9a703          	lw	a4,12(s3)
    80004c8a:	c7b8                	sw	a4,72(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004c8c:	fa45                	bnez	a2,80004c3c <log_write+0xb4>
    80004c8e:	a015                	j	80004cb2 <log_write+0x12a>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004c90:	4781                	li	a5,0
    80004c92:	bf41                	j	80004c22 <log_write+0x9a>
  log[dev].lh.block[i] = b->blockno;
    80004c94:	00149793          	slli	a5,s1,0x1
    80004c98:	97a6                	add	a5,a5,s1
    80004c9a:	0792                	slli	a5,a5,0x4
    80004c9c:	97b2                	add	a5,a5,a2
    80004c9e:	07c1                	addi	a5,a5,16
    80004ca0:	078a                	slli	a5,a5,0x2
    80004ca2:	00022717          	auipc	a4,0x22
    80004ca6:	d7670713          	addi	a4,a4,-650 # 80026a18 <log>
    80004caa:	97ba                	add	a5,a5,a4
    80004cac:	00c9a703          	lw	a4,12(s3)
    80004cb0:	c798                	sw	a4,8(a5)
    bpin(b);
    80004cb2:	854e                	mv	a0,s3
    80004cb4:	fffff097          	auipc	ra,0xfffff
    80004cb8:	c48080e7          	jalr	-952(ra) # 800038fc <bpin>
    log[dev].lh.n++;
    80004cbc:	00022697          	auipc	a3,0x22
    80004cc0:	d5c68693          	addi	a3,a3,-676 # 80026a18 <log>
    80004cc4:	00149793          	slli	a5,s1,0x1
    80004cc8:	00978733          	add	a4,a5,s1
    80004ccc:	071a                	slli	a4,a4,0x6
    80004cce:	9736                	add	a4,a4,a3
    80004cd0:	437c                	lw	a5,68(a4)
    80004cd2:	2785                	addiw	a5,a5,1
    80004cd4:	c37c                	sw	a5,68(a4)
    80004cd6:	b79d                	j	80004c3c <log_write+0xb4>

0000000080004cd8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004cd8:	1101                	addi	sp,sp,-32
    80004cda:	ec06                	sd	ra,24(sp)
    80004cdc:	e822                	sd	s0,16(sp)
    80004cde:	e426                	sd	s1,8(sp)
    80004ce0:	e04a                	sd	s2,0(sp)
    80004ce2:	1000                	addi	s0,sp,32
    80004ce4:	84aa                	mv	s1,a0
    80004ce6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004ce8:	00004597          	auipc	a1,0x4
    80004cec:	ee058593          	addi	a1,a1,-288 # 80008bc8 <userret+0xb38>
    80004cf0:	0521                	addi	a0,a0,8
    80004cf2:	ffffc097          	auipc	ra,0xffffc
    80004cf6:	e5a080e7          	jalr	-422(ra) # 80000b4c <initlock>
  lk->name = name;
    80004cfa:	0324bc23          	sd	s2,56(s1)
  lk->locked = 0;
    80004cfe:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d02:	0404a023          	sw	zero,64(s1)
}
    80004d06:	60e2                	ld	ra,24(sp)
    80004d08:	6442                	ld	s0,16(sp)
    80004d0a:	64a2                	ld	s1,8(sp)
    80004d0c:	6902                	ld	s2,0(sp)
    80004d0e:	6105                	addi	sp,sp,32
    80004d10:	8082                	ret

0000000080004d12 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004d12:	1101                	addi	sp,sp,-32
    80004d14:	ec06                	sd	ra,24(sp)
    80004d16:	e822                	sd	s0,16(sp)
    80004d18:	e426                	sd	s1,8(sp)
    80004d1a:	e04a                	sd	s2,0(sp)
    80004d1c:	1000                	addi	s0,sp,32
    80004d1e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004d20:	00850913          	addi	s2,a0,8
    80004d24:	854a                	mv	a0,s2
    80004d26:	ffffc097          	auipc	ra,0xffffc
    80004d2a:	f94080e7          	jalr	-108(ra) # 80000cba <acquire>
  while (lk->locked) {
    80004d2e:	409c                	lw	a5,0(s1)
    80004d30:	cb89                	beqz	a5,80004d42 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004d32:	85ca                	mv	a1,s2
    80004d34:	8526                	mv	a0,s1
    80004d36:	ffffe097          	auipc	ra,0xffffe
    80004d3a:	bfc080e7          	jalr	-1028(ra) # 80002932 <sleep>
  while (lk->locked) {
    80004d3e:	409c                	lw	a5,0(s1)
    80004d40:	fbed                	bnez	a5,80004d32 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004d42:	4785                	li	a5,1
    80004d44:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004d46:	ffffd097          	auipc	ra,0xffffd
    80004d4a:	2fa080e7          	jalr	762(ra) # 80002040 <myproc>
    80004d4e:	493c                	lw	a5,80(a0)
    80004d50:	c0bc                	sw	a5,64(s1)
  release(&lk->lk);
    80004d52:	854a                	mv	a0,s2
    80004d54:	ffffc097          	auipc	ra,0xffffc
    80004d58:	1b2080e7          	jalr	434(ra) # 80000f06 <release>
}
    80004d5c:	60e2                	ld	ra,24(sp)
    80004d5e:	6442                	ld	s0,16(sp)
    80004d60:	64a2                	ld	s1,8(sp)
    80004d62:	6902                	ld	s2,0(sp)
    80004d64:	6105                	addi	sp,sp,32
    80004d66:	8082                	ret

0000000080004d68 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004d68:	1101                	addi	sp,sp,-32
    80004d6a:	ec06                	sd	ra,24(sp)
    80004d6c:	e822                	sd	s0,16(sp)
    80004d6e:	e426                	sd	s1,8(sp)
    80004d70:	e04a                	sd	s2,0(sp)
    80004d72:	1000                	addi	s0,sp,32
    80004d74:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004d76:	00850913          	addi	s2,a0,8
    80004d7a:	854a                	mv	a0,s2
    80004d7c:	ffffc097          	auipc	ra,0xffffc
    80004d80:	f3e080e7          	jalr	-194(ra) # 80000cba <acquire>
  lk->locked = 0;
    80004d84:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d88:	0404a023          	sw	zero,64(s1)
  wakeup(lk);
    80004d8c:	8526                	mv	a0,s1
    80004d8e:	ffffe097          	auipc	ra,0xffffe
    80004d92:	d2a080e7          	jalr	-726(ra) # 80002ab8 <wakeup>
  release(&lk->lk);
    80004d96:	854a                	mv	a0,s2
    80004d98:	ffffc097          	auipc	ra,0xffffc
    80004d9c:	16e080e7          	jalr	366(ra) # 80000f06 <release>
}
    80004da0:	60e2                	ld	ra,24(sp)
    80004da2:	6442                	ld	s0,16(sp)
    80004da4:	64a2                	ld	s1,8(sp)
    80004da6:	6902                	ld	s2,0(sp)
    80004da8:	6105                	addi	sp,sp,32
    80004daa:	8082                	ret

0000000080004dac <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004dac:	7179                	addi	sp,sp,-48
    80004dae:	f406                	sd	ra,40(sp)
    80004db0:	f022                	sd	s0,32(sp)
    80004db2:	ec26                	sd	s1,24(sp)
    80004db4:	e84a                	sd	s2,16(sp)
    80004db6:	e44e                	sd	s3,8(sp)
    80004db8:	1800                	addi	s0,sp,48
    80004dba:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004dbc:	00850913          	addi	s2,a0,8
    80004dc0:	854a                	mv	a0,s2
    80004dc2:	ffffc097          	auipc	ra,0xffffc
    80004dc6:	ef8080e7          	jalr	-264(ra) # 80000cba <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004dca:	409c                	lw	a5,0(s1)
    80004dcc:	ef99                	bnez	a5,80004dea <holdingsleep+0x3e>
    80004dce:	4481                	li	s1,0
  release(&lk->lk);
    80004dd0:	854a                	mv	a0,s2
    80004dd2:	ffffc097          	auipc	ra,0xffffc
    80004dd6:	134080e7          	jalr	308(ra) # 80000f06 <release>
  return r;
}
    80004dda:	8526                	mv	a0,s1
    80004ddc:	70a2                	ld	ra,40(sp)
    80004dde:	7402                	ld	s0,32(sp)
    80004de0:	64e2                	ld	s1,24(sp)
    80004de2:	6942                	ld	s2,16(sp)
    80004de4:	69a2                	ld	s3,8(sp)
    80004de6:	6145                	addi	sp,sp,48
    80004de8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004dea:	0404a983          	lw	s3,64(s1)
    80004dee:	ffffd097          	auipc	ra,0xffffd
    80004df2:	252080e7          	jalr	594(ra) # 80002040 <myproc>
    80004df6:	4924                	lw	s1,80(a0)
    80004df8:	413484b3          	sub	s1,s1,s3
    80004dfc:	0014b493          	seqz	s1,s1
    80004e00:	bfc1                	j	80004dd0 <holdingsleep+0x24>

0000000080004e02 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004e02:	1141                	addi	sp,sp,-16
    80004e04:	e406                	sd	ra,8(sp)
    80004e06:	e022                	sd	s0,0(sp)
    80004e08:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004e0a:	00004597          	auipc	a1,0x4
    80004e0e:	dce58593          	addi	a1,a1,-562 # 80008bd8 <userret+0xb48>
    80004e12:	00022517          	auipc	a0,0x22
    80004e16:	e2650513          	addi	a0,a0,-474 # 80026c38 <ftable>
    80004e1a:	ffffc097          	auipc	ra,0xffffc
    80004e1e:	d32080e7          	jalr	-718(ra) # 80000b4c <initlock>
}
    80004e22:	60a2                	ld	ra,8(sp)
    80004e24:	6402                	ld	s0,0(sp)
    80004e26:	0141                	addi	sp,sp,16
    80004e28:	8082                	ret

0000000080004e2a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004e2a:	1101                	addi	sp,sp,-32
    80004e2c:	ec06                	sd	ra,24(sp)
    80004e2e:	e822                	sd	s0,16(sp)
    80004e30:	e426                	sd	s1,8(sp)
    80004e32:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004e34:	00022517          	auipc	a0,0x22
    80004e38:	e0450513          	addi	a0,a0,-508 # 80026c38 <ftable>
    80004e3c:	ffffc097          	auipc	ra,0xffffc
    80004e40:	e7e080e7          	jalr	-386(ra) # 80000cba <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    80004e44:	00022797          	auipc	a5,0x22
    80004e48:	df478793          	addi	a5,a5,-524 # 80026c38 <ftable>
    80004e4c:	5bdc                	lw	a5,52(a5)
    80004e4e:	cb8d                	beqz	a5,80004e80 <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e50:	00022497          	auipc	s1,0x22
    80004e54:	e4048493          	addi	s1,s1,-448 # 80026c90 <ftable+0x58>
    80004e58:	00023717          	auipc	a4,0x23
    80004e5c:	db070713          	addi	a4,a4,-592 # 80027c08 <ftable+0xfd0>
    if(f->ref == 0){
    80004e60:	40dc                	lw	a5,4(s1)
    80004e62:	c39d                	beqz	a5,80004e88 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e64:	02848493          	addi	s1,s1,40
    80004e68:	fee49ce3          	bne	s1,a4,80004e60 <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004e6c:	00022517          	auipc	a0,0x22
    80004e70:	dcc50513          	addi	a0,a0,-564 # 80026c38 <ftable>
    80004e74:	ffffc097          	auipc	ra,0xffffc
    80004e78:	092080e7          	jalr	146(ra) # 80000f06 <release>
  return 0;
    80004e7c:	4481                	li	s1,0
    80004e7e:	a839                	j	80004e9c <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e80:	00022497          	auipc	s1,0x22
    80004e84:	de848493          	addi	s1,s1,-536 # 80026c68 <ftable+0x30>
      f->ref = 1;
    80004e88:	4785                	li	a5,1
    80004e8a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004e8c:	00022517          	auipc	a0,0x22
    80004e90:	dac50513          	addi	a0,a0,-596 # 80026c38 <ftable>
    80004e94:	ffffc097          	auipc	ra,0xffffc
    80004e98:	072080e7          	jalr	114(ra) # 80000f06 <release>
}
    80004e9c:	8526                	mv	a0,s1
    80004e9e:	60e2                	ld	ra,24(sp)
    80004ea0:	6442                	ld	s0,16(sp)
    80004ea2:	64a2                	ld	s1,8(sp)
    80004ea4:	6105                	addi	sp,sp,32
    80004ea6:	8082                	ret

0000000080004ea8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ea8:	1101                	addi	sp,sp,-32
    80004eaa:	ec06                	sd	ra,24(sp)
    80004eac:	e822                	sd	s0,16(sp)
    80004eae:	e426                	sd	s1,8(sp)
    80004eb0:	1000                	addi	s0,sp,32
    80004eb2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004eb4:	00022517          	auipc	a0,0x22
    80004eb8:	d8450513          	addi	a0,a0,-636 # 80026c38 <ftable>
    80004ebc:	ffffc097          	auipc	ra,0xffffc
    80004ec0:	dfe080e7          	jalr	-514(ra) # 80000cba <acquire>
  if(f->ref < 1)
    80004ec4:	40dc                	lw	a5,4(s1)
    80004ec6:	02f05263          	blez	a5,80004eea <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004eca:	2785                	addiw	a5,a5,1
    80004ecc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004ece:	00022517          	auipc	a0,0x22
    80004ed2:	d6a50513          	addi	a0,a0,-662 # 80026c38 <ftable>
    80004ed6:	ffffc097          	auipc	ra,0xffffc
    80004eda:	030080e7          	jalr	48(ra) # 80000f06 <release>
  return f;
}
    80004ede:	8526                	mv	a0,s1
    80004ee0:	60e2                	ld	ra,24(sp)
    80004ee2:	6442                	ld	s0,16(sp)
    80004ee4:	64a2                	ld	s1,8(sp)
    80004ee6:	6105                	addi	sp,sp,32
    80004ee8:	8082                	ret
    panic("filedup");
    80004eea:	00004517          	auipc	a0,0x4
    80004eee:	cf650513          	addi	a0,a0,-778 # 80008be0 <userret+0xb50>
    80004ef2:	ffffc097          	auipc	ra,0xffffc
    80004ef6:	892080e7          	jalr	-1902(ra) # 80000784 <panic>

0000000080004efa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004efa:	7139                	addi	sp,sp,-64
    80004efc:	fc06                	sd	ra,56(sp)
    80004efe:	f822                	sd	s0,48(sp)
    80004f00:	f426                	sd	s1,40(sp)
    80004f02:	f04a                	sd	s2,32(sp)
    80004f04:	ec4e                	sd	s3,24(sp)
    80004f06:	e852                	sd	s4,16(sp)
    80004f08:	e456                	sd	s5,8(sp)
    80004f0a:	0080                	addi	s0,sp,64
    80004f0c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004f0e:	00022517          	auipc	a0,0x22
    80004f12:	d2a50513          	addi	a0,a0,-726 # 80026c38 <ftable>
    80004f16:	ffffc097          	auipc	ra,0xffffc
    80004f1a:	da4080e7          	jalr	-604(ra) # 80000cba <acquire>
  if(f->ref < 1)
    80004f1e:	40dc                	lw	a5,4(s1)
    80004f20:	06f05563          	blez	a5,80004f8a <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004f24:	37fd                	addiw	a5,a5,-1
    80004f26:	0007871b          	sext.w	a4,a5
    80004f2a:	c0dc                	sw	a5,4(s1)
    80004f2c:	06e04763          	bgtz	a4,80004f9a <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004f30:	0004a903          	lw	s2,0(s1)
    80004f34:	0094ca83          	lbu	s5,9(s1)
    80004f38:	0104ba03          	ld	s4,16(s1)
    80004f3c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004f40:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004f44:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004f48:	00022517          	auipc	a0,0x22
    80004f4c:	cf050513          	addi	a0,a0,-784 # 80026c38 <ftable>
    80004f50:	ffffc097          	auipc	ra,0xffffc
    80004f54:	fb6080e7          	jalr	-74(ra) # 80000f06 <release>

  if(ff.type == FD_PIPE){
    80004f58:	4785                	li	a5,1
    80004f5a:	06f90163          	beq	s2,a5,80004fbc <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004f5e:	3979                	addiw	s2,s2,-2
    80004f60:	4785                	li	a5,1
    80004f62:	0527e463          	bltu	a5,s2,80004faa <fileclose+0xb0>
    begin_op(ff.ip->dev);
    80004f66:	0009a503          	lw	a0,0(s3)
    80004f6a:	00000097          	auipc	ra,0x0
    80004f6e:	9d4080e7          	jalr	-1580(ra) # 8000493e <begin_op>
    iput(ff.ip);
    80004f72:	854e                	mv	a0,s3
    80004f74:	fffff097          	auipc	ra,0xfffff
    80004f78:	100080e7          	jalr	256(ra) # 80004074 <iput>
    end_op(ff.ip->dev);
    80004f7c:	0009a503          	lw	a0,0(s3)
    80004f80:	00000097          	auipc	ra,0x0
    80004f84:	a6a080e7          	jalr	-1430(ra) # 800049ea <end_op>
    80004f88:	a00d                	j	80004faa <fileclose+0xb0>
    panic("fileclose");
    80004f8a:	00004517          	auipc	a0,0x4
    80004f8e:	c5e50513          	addi	a0,a0,-930 # 80008be8 <userret+0xb58>
    80004f92:	ffffb097          	auipc	ra,0xffffb
    80004f96:	7f2080e7          	jalr	2034(ra) # 80000784 <panic>
    release(&ftable.lock);
    80004f9a:	00022517          	auipc	a0,0x22
    80004f9e:	c9e50513          	addi	a0,a0,-866 # 80026c38 <ftable>
    80004fa2:	ffffc097          	auipc	ra,0xffffc
    80004fa6:	f64080e7          	jalr	-156(ra) # 80000f06 <release>
  }
}
    80004faa:	70e2                	ld	ra,56(sp)
    80004fac:	7442                	ld	s0,48(sp)
    80004fae:	74a2                	ld	s1,40(sp)
    80004fb0:	7902                	ld	s2,32(sp)
    80004fb2:	69e2                	ld	s3,24(sp)
    80004fb4:	6a42                	ld	s4,16(sp)
    80004fb6:	6aa2                	ld	s5,8(sp)
    80004fb8:	6121                	addi	sp,sp,64
    80004fba:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004fbc:	85d6                	mv	a1,s5
    80004fbe:	8552                	mv	a0,s4
    80004fc0:	00000097          	auipc	ra,0x0
    80004fc4:	376080e7          	jalr	886(ra) # 80005336 <pipeclose>
    80004fc8:	b7cd                	j	80004faa <fileclose+0xb0>

0000000080004fca <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004fca:	715d                	addi	sp,sp,-80
    80004fcc:	e486                	sd	ra,72(sp)
    80004fce:	e0a2                	sd	s0,64(sp)
    80004fd0:	fc26                	sd	s1,56(sp)
    80004fd2:	f84a                	sd	s2,48(sp)
    80004fd4:	f44e                	sd	s3,40(sp)
    80004fd6:	0880                	addi	s0,sp,80
    80004fd8:	84aa                	mv	s1,a0
    80004fda:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004fdc:	ffffd097          	auipc	ra,0xffffd
    80004fe0:	064080e7          	jalr	100(ra) # 80002040 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004fe4:	409c                	lw	a5,0(s1)
    80004fe6:	37f9                	addiw	a5,a5,-2
    80004fe8:	4705                	li	a4,1
    80004fea:	04f76763          	bltu	a4,a5,80005038 <filestat+0x6e>
    80004fee:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ff0:	6c88                	ld	a0,24(s1)
    80004ff2:	fffff097          	auipc	ra,0xfffff
    80004ff6:	f72080e7          	jalr	-142(ra) # 80003f64 <ilock>
    stati(f->ip, &st);
    80004ffa:	fb840593          	addi	a1,s0,-72
    80004ffe:	6c88                	ld	a0,24(s1)
    80005000:	fffff097          	auipc	ra,0xfffff
    80005004:	1cc080e7          	jalr	460(ra) # 800041cc <stati>
    iunlock(f->ip);
    80005008:	6c88                	ld	a0,24(s1)
    8000500a:	fffff097          	auipc	ra,0xfffff
    8000500e:	01e080e7          	jalr	30(ra) # 80004028 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005012:	46e1                	li	a3,24
    80005014:	fb840613          	addi	a2,s0,-72
    80005018:	85ce                	mv	a1,s3
    8000501a:	06893503          	ld	a0,104(s2)
    8000501e:	ffffd097          	auipc	ra,0xffffd
    80005022:	c00080e7          	jalr	-1024(ra) # 80001c1e <copyout>
    80005026:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000502a:	60a6                	ld	ra,72(sp)
    8000502c:	6406                	ld	s0,64(sp)
    8000502e:	74e2                	ld	s1,56(sp)
    80005030:	7942                	ld	s2,48(sp)
    80005032:	79a2                	ld	s3,40(sp)
    80005034:	6161                	addi	sp,sp,80
    80005036:	8082                	ret
  return -1;
    80005038:	557d                	li	a0,-1
    8000503a:	bfc5                	j	8000502a <filestat+0x60>

000000008000503c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000503c:	7179                	addi	sp,sp,-48
    8000503e:	f406                	sd	ra,40(sp)
    80005040:	f022                	sd	s0,32(sp)
    80005042:	ec26                	sd	s1,24(sp)
    80005044:	e84a                	sd	s2,16(sp)
    80005046:	e44e                	sd	s3,8(sp)
    80005048:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000504a:	00854783          	lbu	a5,8(a0)
    8000504e:	c7c5                	beqz	a5,800050f6 <fileread+0xba>
    80005050:	89b2                	mv	s3,a2
    80005052:	892e                	mv	s2,a1
    80005054:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80005056:	411c                	lw	a5,0(a0)
    80005058:	4705                	li	a4,1
    8000505a:	04e78963          	beq	a5,a4,800050ac <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000505e:	470d                	li	a4,3
    80005060:	04e78d63          	beq	a5,a4,800050ba <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80005064:	4709                	li	a4,2
    80005066:	08e79063          	bne	a5,a4,800050e6 <fileread+0xaa>
    ilock(f->ip);
    8000506a:	6d08                	ld	a0,24(a0)
    8000506c:	fffff097          	auipc	ra,0xfffff
    80005070:	ef8080e7          	jalr	-264(ra) # 80003f64 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005074:	874e                	mv	a4,s3
    80005076:	5094                	lw	a3,32(s1)
    80005078:	864a                	mv	a2,s2
    8000507a:	4585                	li	a1,1
    8000507c:	6c88                	ld	a0,24(s1)
    8000507e:	fffff097          	auipc	ra,0xfffff
    80005082:	178080e7          	jalr	376(ra) # 800041f6 <readi>
    80005086:	892a                	mv	s2,a0
    80005088:	00a05563          	blez	a0,80005092 <fileread+0x56>
      f->off += r;
    8000508c:	509c                	lw	a5,32(s1)
    8000508e:	9fa9                	addw	a5,a5,a0
    80005090:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005092:	6c88                	ld	a0,24(s1)
    80005094:	fffff097          	auipc	ra,0xfffff
    80005098:	f94080e7          	jalr	-108(ra) # 80004028 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000509c:	854a                	mv	a0,s2
    8000509e:	70a2                	ld	ra,40(sp)
    800050a0:	7402                	ld	s0,32(sp)
    800050a2:	64e2                	ld	s1,24(sp)
    800050a4:	6942                	ld	s2,16(sp)
    800050a6:	69a2                	ld	s3,8(sp)
    800050a8:	6145                	addi	sp,sp,48
    800050aa:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800050ac:	6908                	ld	a0,16(a0)
    800050ae:	00000097          	auipc	ra,0x0
    800050b2:	412080e7          	jalr	1042(ra) # 800054c0 <piperead>
    800050b6:	892a                	mv	s2,a0
    800050b8:	b7d5                	j	8000509c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800050ba:	02451783          	lh	a5,36(a0)
    800050be:	03079693          	slli	a3,a5,0x30
    800050c2:	92c1                	srli	a3,a3,0x30
    800050c4:	4725                	li	a4,9
    800050c6:	02d76a63          	bltu	a4,a3,800050fa <fileread+0xbe>
    800050ca:	0792                	slli	a5,a5,0x4
    800050cc:	00022717          	auipc	a4,0x22
    800050d0:	acc70713          	addi	a4,a4,-1332 # 80026b98 <devsw>
    800050d4:	97ba                	add	a5,a5,a4
    800050d6:	639c                	ld	a5,0(a5)
    800050d8:	c39d                	beqz	a5,800050fe <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    800050da:	86b2                	mv	a3,a2
    800050dc:	862e                	mv	a2,a1
    800050de:	4585                	li	a1,1
    800050e0:	9782                	jalr	a5
    800050e2:	892a                	mv	s2,a0
    800050e4:	bf65                	j	8000509c <fileread+0x60>
    panic("fileread");
    800050e6:	00004517          	auipc	a0,0x4
    800050ea:	b1250513          	addi	a0,a0,-1262 # 80008bf8 <userret+0xb68>
    800050ee:	ffffb097          	auipc	ra,0xffffb
    800050f2:	696080e7          	jalr	1686(ra) # 80000784 <panic>
    return -1;
    800050f6:	597d                	li	s2,-1
    800050f8:	b755                	j	8000509c <fileread+0x60>
      return -1;
    800050fa:	597d                	li	s2,-1
    800050fc:	b745                	j	8000509c <fileread+0x60>
    800050fe:	597d                	li	s2,-1
    80005100:	bf71                	j	8000509c <fileread+0x60>

0000000080005102 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005102:	00954783          	lbu	a5,9(a0)
    80005106:	14078663          	beqz	a5,80005252 <filewrite+0x150>
{
    8000510a:	715d                	addi	sp,sp,-80
    8000510c:	e486                	sd	ra,72(sp)
    8000510e:	e0a2                	sd	s0,64(sp)
    80005110:	fc26                	sd	s1,56(sp)
    80005112:	f84a                	sd	s2,48(sp)
    80005114:	f44e                	sd	s3,40(sp)
    80005116:	f052                	sd	s4,32(sp)
    80005118:	ec56                	sd	s5,24(sp)
    8000511a:	e85a                	sd	s6,16(sp)
    8000511c:	e45e                	sd	s7,8(sp)
    8000511e:	e062                	sd	s8,0(sp)
    80005120:	0880                	addi	s0,sp,80
    80005122:	8ab2                	mv	s5,a2
    80005124:	8b2e                	mv	s6,a1
    80005126:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80005128:	411c                	lw	a5,0(a0)
    8000512a:	4705                	li	a4,1
    8000512c:	02e78263          	beq	a5,a4,80005150 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005130:	470d                	li	a4,3
    80005132:	02e78563          	beq	a5,a4,8000515c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80005136:	4709                	li	a4,2
    80005138:	10e79563          	bne	a5,a4,80005242 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000513c:	0ec05f63          	blez	a2,8000523a <filewrite+0x138>
    int i = 0;
    80005140:	4901                	li	s2,0
    80005142:	6b85                	lui	s7,0x1
    80005144:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80005148:	6c05                	lui	s8,0x1
    8000514a:	c00c0c1b          	addiw	s8,s8,-1024
    8000514e:	a851                	j	800051e2 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80005150:	6908                	ld	a0,16(a0)
    80005152:	00000097          	auipc	ra,0x0
    80005156:	254080e7          	jalr	596(ra) # 800053a6 <pipewrite>
    8000515a:	a865                	j	80005212 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000515c:	02451783          	lh	a5,36(a0)
    80005160:	03079693          	slli	a3,a5,0x30
    80005164:	92c1                	srli	a3,a3,0x30
    80005166:	4725                	li	a4,9
    80005168:	0ed76763          	bltu	a4,a3,80005256 <filewrite+0x154>
    8000516c:	0792                	slli	a5,a5,0x4
    8000516e:	00022717          	auipc	a4,0x22
    80005172:	a2a70713          	addi	a4,a4,-1494 # 80026b98 <devsw>
    80005176:	97ba                	add	a5,a5,a4
    80005178:	679c                	ld	a5,8(a5)
    8000517a:	c3e5                	beqz	a5,8000525a <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    8000517c:	86b2                	mv	a3,a2
    8000517e:	862e                	mv	a2,a1
    80005180:	4585                	li	a1,1
    80005182:	9782                	jalr	a5
    80005184:	a079                	j	80005212 <filewrite+0x110>
    80005186:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    8000518a:	6c9c                	ld	a5,24(s1)
    8000518c:	4388                	lw	a0,0(a5)
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	7b0080e7          	jalr	1968(ra) # 8000493e <begin_op>
      ilock(f->ip);
    80005196:	6c88                	ld	a0,24(s1)
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	dcc080e7          	jalr	-564(ra) # 80003f64 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800051a0:	8752                	mv	a4,s4
    800051a2:	5094                	lw	a3,32(s1)
    800051a4:	01690633          	add	a2,s2,s6
    800051a8:	4585                	li	a1,1
    800051aa:	6c88                	ld	a0,24(s1)
    800051ac:	fffff097          	auipc	ra,0xfffff
    800051b0:	13e080e7          	jalr	318(ra) # 800042ea <writei>
    800051b4:	89aa                	mv	s3,a0
    800051b6:	02a05e63          	blez	a0,800051f2 <filewrite+0xf0>
        f->off += r;
    800051ba:	509c                	lw	a5,32(s1)
    800051bc:	9fa9                	addw	a5,a5,a0
    800051be:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800051c0:	6c88                	ld	a0,24(s1)
    800051c2:	fffff097          	auipc	ra,0xfffff
    800051c6:	e66080e7          	jalr	-410(ra) # 80004028 <iunlock>
      end_op(f->ip->dev);
    800051ca:	6c9c                	ld	a5,24(s1)
    800051cc:	4388                	lw	a0,0(a5)
    800051ce:	00000097          	auipc	ra,0x0
    800051d2:	81c080e7          	jalr	-2020(ra) # 800049ea <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800051d6:	05499a63          	bne	s3,s4,8000522a <filewrite+0x128>
        panic("short filewrite");
      i += r;
    800051da:	012a093b          	addw	s2,s4,s2
    while(i < n){
    800051de:	03595763          	ble	s5,s2,8000520c <filewrite+0x10a>
      int n1 = n - i;
    800051e2:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    800051e6:	89be                	mv	s3,a5
    800051e8:	2781                	sext.w	a5,a5
    800051ea:	f8fbdee3          	ble	a5,s7,80005186 <filewrite+0x84>
    800051ee:	89e2                	mv	s3,s8
    800051f0:	bf59                	j	80005186 <filewrite+0x84>
      iunlock(f->ip);
    800051f2:	6c88                	ld	a0,24(s1)
    800051f4:	fffff097          	auipc	ra,0xfffff
    800051f8:	e34080e7          	jalr	-460(ra) # 80004028 <iunlock>
      end_op(f->ip->dev);
    800051fc:	6c9c                	ld	a5,24(s1)
    800051fe:	4388                	lw	a0,0(a5)
    80005200:	fffff097          	auipc	ra,0xfffff
    80005204:	7ea080e7          	jalr	2026(ra) # 800049ea <end_op>
      if(r < 0)
    80005208:	fc09d7e3          	bgez	s3,800051d6 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    8000520c:	8556                	mv	a0,s5
    8000520e:	032a9863          	bne	s5,s2,8000523e <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005212:	60a6                	ld	ra,72(sp)
    80005214:	6406                	ld	s0,64(sp)
    80005216:	74e2                	ld	s1,56(sp)
    80005218:	7942                	ld	s2,48(sp)
    8000521a:	79a2                	ld	s3,40(sp)
    8000521c:	7a02                	ld	s4,32(sp)
    8000521e:	6ae2                	ld	s5,24(sp)
    80005220:	6b42                	ld	s6,16(sp)
    80005222:	6ba2                	ld	s7,8(sp)
    80005224:	6c02                	ld	s8,0(sp)
    80005226:	6161                	addi	sp,sp,80
    80005228:	8082                	ret
        panic("short filewrite");
    8000522a:	00004517          	auipc	a0,0x4
    8000522e:	9de50513          	addi	a0,a0,-1570 # 80008c08 <userret+0xb78>
    80005232:	ffffb097          	auipc	ra,0xffffb
    80005236:	552080e7          	jalr	1362(ra) # 80000784 <panic>
    int i = 0;
    8000523a:	4901                	li	s2,0
    8000523c:	bfc1                	j	8000520c <filewrite+0x10a>
    ret = (i == n ? n : -1);
    8000523e:	557d                	li	a0,-1
    80005240:	bfc9                	j	80005212 <filewrite+0x110>
    panic("filewrite");
    80005242:	00004517          	auipc	a0,0x4
    80005246:	9d650513          	addi	a0,a0,-1578 # 80008c18 <userret+0xb88>
    8000524a:	ffffb097          	auipc	ra,0xffffb
    8000524e:	53a080e7          	jalr	1338(ra) # 80000784 <panic>
    return -1;
    80005252:	557d                	li	a0,-1
}
    80005254:	8082                	ret
      return -1;
    80005256:	557d                	li	a0,-1
    80005258:	bf6d                	j	80005212 <filewrite+0x110>
    8000525a:	557d                	li	a0,-1
    8000525c:	bf5d                	j	80005212 <filewrite+0x110>

000000008000525e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000525e:	7179                	addi	sp,sp,-48
    80005260:	f406                	sd	ra,40(sp)
    80005262:	f022                	sd	s0,32(sp)
    80005264:	ec26                	sd	s1,24(sp)
    80005266:	e84a                	sd	s2,16(sp)
    80005268:	e44e                	sd	s3,8(sp)
    8000526a:	e052                	sd	s4,0(sp)
    8000526c:	1800                	addi	s0,sp,48
    8000526e:	84aa                	mv	s1,a0
    80005270:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005272:	0005b023          	sd	zero,0(a1)
    80005276:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000527a:	00000097          	auipc	ra,0x0
    8000527e:	bb0080e7          	jalr	-1104(ra) # 80004e2a <filealloc>
    80005282:	e088                	sd	a0,0(s1)
    80005284:	c549                	beqz	a0,8000530e <pipealloc+0xb0>
    80005286:	00000097          	auipc	ra,0x0
    8000528a:	ba4080e7          	jalr	-1116(ra) # 80004e2a <filealloc>
    8000528e:	00a93023          	sd	a0,0(s2)
    80005292:	c925                	beqz	a0,80005302 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005294:	ffffc097          	auipc	ra,0xffffc
    80005298:	89e080e7          	jalr	-1890(ra) # 80000b32 <kalloc>
    8000529c:	89aa                	mv	s3,a0
    8000529e:	cd39                	beqz	a0,800052fc <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    800052a0:	4a05                	li	s4,1
    800052a2:	23452c23          	sw	s4,568(a0)
  pi->writeopen = 1;
    800052a6:	23452e23          	sw	s4,572(a0)
  pi->nwrite = 0;
    800052aa:	22052a23          	sw	zero,564(a0)
  pi->nread = 0;
    800052ae:	22052823          	sw	zero,560(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    800052b2:	03000613          	li	a2,48
    800052b6:	4581                	li	a1,0
    800052b8:	ffffc097          	auipc	ra,0xffffc
    800052bc:	e76080e7          	jalr	-394(ra) # 8000112e <memset>
  (*f0)->type = FD_PIPE;
    800052c0:	609c                	ld	a5,0(s1)
    800052c2:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    800052c6:	609c                	ld	a5,0(s1)
    800052c8:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    800052cc:	609c                	ld	a5,0(s1)
    800052ce:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800052d2:	609c                	ld	a5,0(s1)
    800052d4:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    800052d8:	00093783          	ld	a5,0(s2)
    800052dc:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    800052e0:	00093783          	ld	a5,0(s2)
    800052e4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800052e8:	00093783          	ld	a5,0(s2)
    800052ec:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    800052f0:	00093783          	ld	a5,0(s2)
    800052f4:	0137b823          	sd	s3,16(a5)
  return 0;
    800052f8:	4501                	li	a0,0
    800052fa:	a025                	j	80005322 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800052fc:	6088                	ld	a0,0(s1)
    800052fe:	e501                	bnez	a0,80005306 <pipealloc+0xa8>
    80005300:	a039                	j	8000530e <pipealloc+0xb0>
    80005302:	6088                	ld	a0,0(s1)
    80005304:	c51d                	beqz	a0,80005332 <pipealloc+0xd4>
    fileclose(*f0);
    80005306:	00000097          	auipc	ra,0x0
    8000530a:	bf4080e7          	jalr	-1036(ra) # 80004efa <fileclose>
  if(*f1)
    8000530e:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80005312:	557d                	li	a0,-1
  if(*f1)
    80005314:	c799                	beqz	a5,80005322 <pipealloc+0xc4>
    fileclose(*f1);
    80005316:	853e                	mv	a0,a5
    80005318:	00000097          	auipc	ra,0x0
    8000531c:	be2080e7          	jalr	-1054(ra) # 80004efa <fileclose>
  return -1;
    80005320:	557d                	li	a0,-1
}
    80005322:	70a2                	ld	ra,40(sp)
    80005324:	7402                	ld	s0,32(sp)
    80005326:	64e2                	ld	s1,24(sp)
    80005328:	6942                	ld	s2,16(sp)
    8000532a:	69a2                	ld	s3,8(sp)
    8000532c:	6a02                	ld	s4,0(sp)
    8000532e:	6145                	addi	sp,sp,48
    80005330:	8082                	ret
  return -1;
    80005332:	557d                	li	a0,-1
    80005334:	b7fd                	j	80005322 <pipealloc+0xc4>

0000000080005336 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005336:	1101                	addi	sp,sp,-32
    80005338:	ec06                	sd	ra,24(sp)
    8000533a:	e822                	sd	s0,16(sp)
    8000533c:	e426                	sd	s1,8(sp)
    8000533e:	e04a                	sd	s2,0(sp)
    80005340:	1000                	addi	s0,sp,32
    80005342:	84aa                	mv	s1,a0
    80005344:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005346:	ffffc097          	auipc	ra,0xffffc
    8000534a:	974080e7          	jalr	-1676(ra) # 80000cba <acquire>
  if(writable){
    8000534e:	02090d63          	beqz	s2,80005388 <pipeclose+0x52>
    pi->writeopen = 0;
    80005352:	2204ae23          	sw	zero,572(s1)
    wakeup(&pi->nread);
    80005356:	23048513          	addi	a0,s1,560
    8000535a:	ffffd097          	auipc	ra,0xffffd
    8000535e:	75e080e7          	jalr	1886(ra) # 80002ab8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005362:	2384b783          	ld	a5,568(s1)
    80005366:	eb95                	bnez	a5,8000539a <pipeclose+0x64>
    release(&pi->lock);
    80005368:	8526                	mv	a0,s1
    8000536a:	ffffc097          	auipc	ra,0xffffc
    8000536e:	b9c080e7          	jalr	-1124(ra) # 80000f06 <release>
    kfree((char*)pi);
    80005372:	8526                	mv	a0,s1
    80005374:	ffffb097          	auipc	ra,0xffffb
    80005378:	7a6080e7          	jalr	1958(ra) # 80000b1a <kfree>
  } else
    release(&pi->lock);
}
    8000537c:	60e2                	ld	ra,24(sp)
    8000537e:	6442                	ld	s0,16(sp)
    80005380:	64a2                	ld	s1,8(sp)
    80005382:	6902                	ld	s2,0(sp)
    80005384:	6105                	addi	sp,sp,32
    80005386:	8082                	ret
    pi->readopen = 0;
    80005388:	2204ac23          	sw	zero,568(s1)
    wakeup(&pi->nwrite);
    8000538c:	23448513          	addi	a0,s1,564
    80005390:	ffffd097          	auipc	ra,0xffffd
    80005394:	728080e7          	jalr	1832(ra) # 80002ab8 <wakeup>
    80005398:	b7e9                	j	80005362 <pipeclose+0x2c>
    release(&pi->lock);
    8000539a:	8526                	mv	a0,s1
    8000539c:	ffffc097          	auipc	ra,0xffffc
    800053a0:	b6a080e7          	jalr	-1174(ra) # 80000f06 <release>
}
    800053a4:	bfe1                	j	8000537c <pipeclose+0x46>

00000000800053a6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800053a6:	7159                	addi	sp,sp,-112
    800053a8:	f486                	sd	ra,104(sp)
    800053aa:	f0a2                	sd	s0,96(sp)
    800053ac:	eca6                	sd	s1,88(sp)
    800053ae:	e8ca                	sd	s2,80(sp)
    800053b0:	e4ce                	sd	s3,72(sp)
    800053b2:	e0d2                	sd	s4,64(sp)
    800053b4:	fc56                	sd	s5,56(sp)
    800053b6:	f85a                	sd	s6,48(sp)
    800053b8:	f45e                	sd	s7,40(sp)
    800053ba:	f062                	sd	s8,32(sp)
    800053bc:	ec66                	sd	s9,24(sp)
    800053be:	1880                	addi	s0,sp,112
    800053c0:	84aa                	mv	s1,a0
    800053c2:	8bae                	mv	s7,a1
    800053c4:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    800053c6:	ffffd097          	auipc	ra,0xffffd
    800053ca:	c7a080e7          	jalr	-902(ra) # 80002040 <myproc>
    800053ce:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    800053d0:	8526                	mv	a0,s1
    800053d2:	ffffc097          	auipc	ra,0xffffc
    800053d6:	8e8080e7          	jalr	-1816(ra) # 80000cba <acquire>
  for(i = 0; i < n; i++){
    800053da:	0d605663          	blez	s6,800054a6 <pipewrite+0x100>
    800053de:	8926                	mv	s2,s1
    800053e0:	fffb0a9b          	addiw	s5,s6,-1
    800053e4:	1a82                	slli	s5,s5,0x20
    800053e6:	020ada93          	srli	s5,s5,0x20
    800053ea:	001b8793          	addi	a5,s7,1
    800053ee:	9abe                	add	s5,s5,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    800053f0:	23048a13          	addi	s4,s1,560
      sleep(&pi->nwrite, &pi->lock);
    800053f4:	23448993          	addi	s3,s1,564
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800053f8:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800053fa:	2304a783          	lw	a5,560(s1)
    800053fe:	2344a703          	lw	a4,564(s1)
    80005402:	2007879b          	addiw	a5,a5,512
    80005406:	06f71463          	bne	a4,a5,8000546e <pipewrite+0xc8>
      if(pi->readopen == 0 || myproc()->killed){
    8000540a:	2384a783          	lw	a5,568(s1)
    8000540e:	cf8d                	beqz	a5,80005448 <pipewrite+0xa2>
    80005410:	ffffd097          	auipc	ra,0xffffd
    80005414:	c30080e7          	jalr	-976(ra) # 80002040 <myproc>
    80005418:	453c                	lw	a5,72(a0)
    8000541a:	e79d                	bnez	a5,80005448 <pipewrite+0xa2>
      wakeup(&pi->nread);
    8000541c:	8552                	mv	a0,s4
    8000541e:	ffffd097          	auipc	ra,0xffffd
    80005422:	69a080e7          	jalr	1690(ra) # 80002ab8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005426:	85ca                	mv	a1,s2
    80005428:	854e                	mv	a0,s3
    8000542a:	ffffd097          	auipc	ra,0xffffd
    8000542e:	508080e7          	jalr	1288(ra) # 80002932 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80005432:	2304a783          	lw	a5,560(s1)
    80005436:	2344a703          	lw	a4,564(s1)
    8000543a:	2007879b          	addiw	a5,a5,512
    8000543e:	02f71863          	bne	a4,a5,8000546e <pipewrite+0xc8>
      if(pi->readopen == 0 || myproc()->killed){
    80005442:	2384a783          	lw	a5,568(s1)
    80005446:	f7e9                	bnez	a5,80005410 <pipewrite+0x6a>
        release(&pi->lock);
    80005448:	8526                	mv	a0,s1
    8000544a:	ffffc097          	auipc	ra,0xffffc
    8000544e:	abc080e7          	jalr	-1348(ra) # 80000f06 <release>
        return -1;
    80005452:	557d                	li	a0,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return n;
}
    80005454:	70a6                	ld	ra,104(sp)
    80005456:	7406                	ld	s0,96(sp)
    80005458:	64e6                	ld	s1,88(sp)
    8000545a:	6946                	ld	s2,80(sp)
    8000545c:	69a6                	ld	s3,72(sp)
    8000545e:	6a06                	ld	s4,64(sp)
    80005460:	7ae2                	ld	s5,56(sp)
    80005462:	7b42                	ld	s6,48(sp)
    80005464:	7ba2                	ld	s7,40(sp)
    80005466:	7c02                	ld	s8,32(sp)
    80005468:	6ce2                	ld	s9,24(sp)
    8000546a:	6165                	addi	sp,sp,112
    8000546c:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000546e:	4685                	li	a3,1
    80005470:	865e                	mv	a2,s7
    80005472:	f9f40593          	addi	a1,s0,-97
    80005476:	068c3503          	ld	a0,104(s8) # 1068 <_entry-0x7fffef98>
    8000547a:	ffffd097          	auipc	ra,0xffffd
    8000547e:	830080e7          	jalr	-2000(ra) # 80001caa <copyin>
    80005482:	03950263          	beq	a0,s9,800054a6 <pipewrite+0x100>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005486:	2344a783          	lw	a5,564(s1)
    8000548a:	0017871b          	addiw	a4,a5,1
    8000548e:	22e4aa23          	sw	a4,564(s1)
    80005492:	1ff7f793          	andi	a5,a5,511
    80005496:	97a6                	add	a5,a5,s1
    80005498:	f9f44703          	lbu	a4,-97(s0)
    8000549c:	02e78823          	sb	a4,48(a5)
    800054a0:	0b85                	addi	s7,s7,1
  for(i = 0; i < n; i++){
    800054a2:	f55b9ce3          	bne	s7,s5,800053fa <pipewrite+0x54>
  wakeup(&pi->nread);
    800054a6:	23048513          	addi	a0,s1,560
    800054aa:	ffffd097          	auipc	ra,0xffffd
    800054ae:	60e080e7          	jalr	1550(ra) # 80002ab8 <wakeup>
  release(&pi->lock);
    800054b2:	8526                	mv	a0,s1
    800054b4:	ffffc097          	auipc	ra,0xffffc
    800054b8:	a52080e7          	jalr	-1454(ra) # 80000f06 <release>
  return n;
    800054bc:	855a                	mv	a0,s6
    800054be:	bf59                	j	80005454 <pipewrite+0xae>

00000000800054c0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800054c0:	715d                	addi	sp,sp,-80
    800054c2:	e486                	sd	ra,72(sp)
    800054c4:	e0a2                	sd	s0,64(sp)
    800054c6:	fc26                	sd	s1,56(sp)
    800054c8:	f84a                	sd	s2,48(sp)
    800054ca:	f44e                	sd	s3,40(sp)
    800054cc:	f052                	sd	s4,32(sp)
    800054ce:	ec56                	sd	s5,24(sp)
    800054d0:	e85a                	sd	s6,16(sp)
    800054d2:	0880                	addi	s0,sp,80
    800054d4:	84aa                	mv	s1,a0
    800054d6:	89ae                	mv	s3,a1
    800054d8:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    800054da:	ffffd097          	auipc	ra,0xffffd
    800054de:	b66080e7          	jalr	-1178(ra) # 80002040 <myproc>
    800054e2:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    800054e4:	8526                	mv	a0,s1
    800054e6:	ffffb097          	auipc	ra,0xffffb
    800054ea:	7d4080e7          	jalr	2004(ra) # 80000cba <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054ee:	2304a703          	lw	a4,560(s1)
    800054f2:	2344a783          	lw	a5,564(s1)
    800054f6:	06f71b63          	bne	a4,a5,8000556c <piperead+0xac>
    800054fa:	8926                	mv	s2,s1
    800054fc:	23c4a783          	lw	a5,572(s1)
    80005500:	cb85                	beqz	a5,80005530 <piperead+0x70>
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005502:	23048b13          	addi	s6,s1,560
    if(myproc()->killed){
    80005506:	ffffd097          	auipc	ra,0xffffd
    8000550a:	b3a080e7          	jalr	-1222(ra) # 80002040 <myproc>
    8000550e:	453c                	lw	a5,72(a0)
    80005510:	e7b9                	bnez	a5,8000555e <piperead+0x9e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005512:	85ca                	mv	a1,s2
    80005514:	855a                	mv	a0,s6
    80005516:	ffffd097          	auipc	ra,0xffffd
    8000551a:	41c080e7          	jalr	1052(ra) # 80002932 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000551e:	2304a703          	lw	a4,560(s1)
    80005522:	2344a783          	lw	a5,564(s1)
    80005526:	04f71363          	bne	a4,a5,8000556c <piperead+0xac>
    8000552a:	23c4a783          	lw	a5,572(s1)
    8000552e:	ffe1                	bnez	a5,80005506 <piperead+0x46>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80005530:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005532:	23448513          	addi	a0,s1,564
    80005536:	ffffd097          	auipc	ra,0xffffd
    8000553a:	582080e7          	jalr	1410(ra) # 80002ab8 <wakeup>
  release(&pi->lock);
    8000553e:	8526                	mv	a0,s1
    80005540:	ffffc097          	auipc	ra,0xffffc
    80005544:	9c6080e7          	jalr	-1594(ra) # 80000f06 <release>
  return i;
}
    80005548:	854a                	mv	a0,s2
    8000554a:	60a6                	ld	ra,72(sp)
    8000554c:	6406                	ld	s0,64(sp)
    8000554e:	74e2                	ld	s1,56(sp)
    80005550:	7942                	ld	s2,48(sp)
    80005552:	79a2                	ld	s3,40(sp)
    80005554:	7a02                	ld	s4,32(sp)
    80005556:	6ae2                	ld	s5,24(sp)
    80005558:	6b42                	ld	s6,16(sp)
    8000555a:	6161                	addi	sp,sp,80
    8000555c:	8082                	ret
      release(&pi->lock);
    8000555e:	8526                	mv	a0,s1
    80005560:	ffffc097          	auipc	ra,0xffffc
    80005564:	9a6080e7          	jalr	-1626(ra) # 80000f06 <release>
      return -1;
    80005568:	597d                	li	s2,-1
    8000556a:	bff9                	j	80005548 <piperead+0x88>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000556c:	4901                	li	s2,0
    8000556e:	fd4052e3          	blez	s4,80005532 <piperead+0x72>
    if(pi->nread == pi->nwrite)
    80005572:	2304a783          	lw	a5,560(s1)
    80005576:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005578:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000557a:	0017871b          	addiw	a4,a5,1
    8000557e:	22e4a823          	sw	a4,560(s1)
    80005582:	1ff7f793          	andi	a5,a5,511
    80005586:	97a6                	add	a5,a5,s1
    80005588:	0307c783          	lbu	a5,48(a5)
    8000558c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005590:	4685                	li	a3,1
    80005592:	fbf40613          	addi	a2,s0,-65
    80005596:	85ce                	mv	a1,s3
    80005598:	068ab503          	ld	a0,104(s5)
    8000559c:	ffffc097          	auipc	ra,0xffffc
    800055a0:	682080e7          	jalr	1666(ra) # 80001c1e <copyout>
    800055a4:	f96507e3          	beq	a0,s6,80005532 <piperead+0x72>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800055a8:	2905                	addiw	s2,s2,1
    800055aa:	f92a04e3          	beq	s4,s2,80005532 <piperead+0x72>
    if(pi->nread == pi->nwrite)
    800055ae:	2304a783          	lw	a5,560(s1)
    800055b2:	0985                	addi	s3,s3,1
    800055b4:	2344a703          	lw	a4,564(s1)
    800055b8:	fcf711e3          	bne	a4,a5,8000557a <piperead+0xba>
    800055bc:	bf9d                	j	80005532 <piperead+0x72>

00000000800055be <exec>:



int
exec(char *path, char **argv)
{
    800055be:	de010113          	addi	sp,sp,-544
    800055c2:	20113c23          	sd	ra,536(sp)
    800055c6:	20813823          	sd	s0,528(sp)
    800055ca:	20913423          	sd	s1,520(sp)
    800055ce:	21213023          	sd	s2,512(sp)
    800055d2:	ffce                	sd	s3,504(sp)
    800055d4:	fbd2                	sd	s4,496(sp)
    800055d6:	f7d6                	sd	s5,488(sp)
    800055d8:	f3da                	sd	s6,480(sp)
    800055da:	efde                	sd	s7,472(sp)
    800055dc:	ebe2                	sd	s8,464(sp)
    800055de:	e7e6                	sd	s9,456(sp)
    800055e0:	e3ea                	sd	s10,448(sp)
    800055e2:	ff6e                	sd	s11,440(sp)
    800055e4:	1400                	addi	s0,sp,544
    800055e6:	892a                	mv	s2,a0
    800055e8:	dea43823          	sd	a0,-528(s0)
    800055ec:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800055f0:	ffffd097          	auipc	ra,0xffffd
    800055f4:	a50080e7          	jalr	-1456(ra) # 80002040 <myproc>
    800055f8:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    800055fa:	4501                	li	a0,0
    800055fc:	fffff097          	auipc	ra,0xfffff
    80005600:	342080e7          	jalr	834(ra) # 8000493e <begin_op>

  if((ip = namei(path)) == 0){
    80005604:	854a                	mv	a0,s2
    80005606:	fffff097          	auipc	ra,0xfffff
    8000560a:	0f2080e7          	jalr	242(ra) # 800046f8 <namei>
    8000560e:	cd25                	beqz	a0,80005686 <exec+0xc8>
    80005610:	892a                	mv	s2,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005612:	fffff097          	auipc	ra,0xfffff
    80005616:	952080e7          	jalr	-1710(ra) # 80003f64 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000561a:	04000713          	li	a4,64
    8000561e:	4681                	li	a3,0
    80005620:	e4840613          	addi	a2,s0,-440
    80005624:	4581                	li	a1,0
    80005626:	854a                	mv	a0,s2
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	bce080e7          	jalr	-1074(ra) # 800041f6 <readi>
    80005630:	04000793          	li	a5,64
    80005634:	00f51a63          	bne	a0,a5,80005648 <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005638:	e4842703          	lw	a4,-440(s0)
    8000563c:	464c47b7          	lui	a5,0x464c4
    80005640:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005644:	04f70863          	beq	a4,a5,80005694 <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005648:	854a                	mv	a0,s2
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	b5a080e7          	jalr	-1190(ra) # 800041a4 <iunlockput>
    end_op(ROOTDEV);
    80005652:	4501                	li	a0,0
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	396080e7          	jalr	918(ra) # 800049ea <end_op>
  }
  return -1;
    8000565c:	557d                	li	a0,-1
}
    8000565e:	21813083          	ld	ra,536(sp)
    80005662:	21013403          	ld	s0,528(sp)
    80005666:	20813483          	ld	s1,520(sp)
    8000566a:	20013903          	ld	s2,512(sp)
    8000566e:	79fe                	ld	s3,504(sp)
    80005670:	7a5e                	ld	s4,496(sp)
    80005672:	7abe                	ld	s5,488(sp)
    80005674:	7b1e                	ld	s6,480(sp)
    80005676:	6bfe                	ld	s7,472(sp)
    80005678:	6c5e                	ld	s8,464(sp)
    8000567a:	6cbe                	ld	s9,456(sp)
    8000567c:	6d1e                	ld	s10,448(sp)
    8000567e:	7dfa                	ld	s11,440(sp)
    80005680:	22010113          	addi	sp,sp,544
    80005684:	8082                	ret
    end_op(ROOTDEV);
    80005686:	4501                	li	a0,0
    80005688:	fffff097          	auipc	ra,0xfffff
    8000568c:	362080e7          	jalr	866(ra) # 800049ea <end_op>
    return -1;
    80005690:	557d                	li	a0,-1
    80005692:	b7f1                	j	8000565e <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80005694:	8526                	mv	a0,s1
    80005696:	ffffd097          	auipc	ra,0xffffd
    8000569a:	a70080e7          	jalr	-1424(ra) # 80002106 <proc_pagetable>
    8000569e:	e0a43423          	sd	a0,-504(s0)
    800056a2:	d15d                	beqz	a0,80005648 <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056a4:	e6842983          	lw	s3,-408(s0)
    800056a8:	e8045783          	lhu	a5,-384(s0)
    800056ac:	cbed                	beqz	a5,8000579e <exec+0x1e0>
  sz = 0;
    800056ae:	e0043023          	sd	zero,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056b2:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800056b4:	6c05                	lui	s8,0x1
    800056b6:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    800056ba:	def43423          	sd	a5,-536(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800056be:	6d05                	lui	s10,0x1
    800056c0:	a0a5                	j	80005728 <exec+0x16a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800056c2:	00003517          	auipc	a0,0x3
    800056c6:	56650513          	addi	a0,a0,1382 # 80008c28 <userret+0xb98>
    800056ca:	ffffb097          	auipc	ra,0xffffb
    800056ce:	0ba080e7          	jalr	186(ra) # 80000784 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800056d2:	8756                	mv	a4,s5
    800056d4:	009d86bb          	addw	a3,s11,s1
    800056d8:	4581                	li	a1,0
    800056da:	854a                	mv	a0,s2
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	b1a080e7          	jalr	-1254(ra) # 800041f6 <readi>
    800056e4:	2501                	sext.w	a0,a0
    800056e6:	10aa9563          	bne	s5,a0,800057f0 <exec+0x232>
  for(i = 0; i < sz; i += PGSIZE){
    800056ea:	009d04bb          	addw	s1,s10,s1
    800056ee:	77fd                	lui	a5,0xfffff
    800056f0:	01478a3b          	addw	s4,a5,s4
    800056f4:	0374f363          	bleu	s7,s1,8000571a <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    800056f8:	02049593          	slli	a1,s1,0x20
    800056fc:	9181                	srli	a1,a1,0x20
    800056fe:	95e6                	add	a1,a1,s9
    80005700:	e0843503          	ld	a0,-504(s0)
    80005704:	ffffc097          	auipc	ra,0xffffc
    80005708:	f36080e7          	jalr	-202(ra) # 8000163a <walkaddr>
    8000570c:	862a                	mv	a2,a0
    if(pa == 0)
    8000570e:	d955                	beqz	a0,800056c2 <exec+0x104>
      n = PGSIZE;
    80005710:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80005712:	fd8a70e3          	bleu	s8,s4,800056d2 <exec+0x114>
      n = sz - i;
    80005716:	8ad2                	mv	s5,s4
    80005718:	bf6d                	j	800056d2 <exec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000571a:	2b05                	addiw	s6,s6,1
    8000571c:	0389899b          	addiw	s3,s3,56
    80005720:	e8045783          	lhu	a5,-384(s0)
    80005724:	06fb5f63          	ble	a5,s6,800057a2 <exec+0x1e4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005728:	2981                	sext.w	s3,s3
    8000572a:	03800713          	li	a4,56
    8000572e:	86ce                	mv	a3,s3
    80005730:	e1040613          	addi	a2,s0,-496
    80005734:	4581                	li	a1,0
    80005736:	854a                	mv	a0,s2
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	abe080e7          	jalr	-1346(ra) # 800041f6 <readi>
    80005740:	03800793          	li	a5,56
    80005744:	0af51663          	bne	a0,a5,800057f0 <exec+0x232>
    if(ph.type != ELF_PROG_LOAD)
    80005748:	e1042783          	lw	a5,-496(s0)
    8000574c:	4705                	li	a4,1
    8000574e:	fce796e3          	bne	a5,a4,8000571a <exec+0x15c>
    if(ph.memsz < ph.filesz)
    80005752:	e3843603          	ld	a2,-456(s0)
    80005756:	e3043783          	ld	a5,-464(s0)
    8000575a:	08f66b63          	bltu	a2,a5,800057f0 <exec+0x232>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000575e:	e2043783          	ld	a5,-480(s0)
    80005762:	963e                	add	a2,a2,a5
    80005764:	08f66663          	bltu	a2,a5,800057f0 <exec+0x232>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005768:	e0043583          	ld	a1,-512(s0)
    8000576c:	e0843503          	ld	a0,-504(s0)
    80005770:	ffffc097          	auipc	ra,0xffffc
    80005774:	2d4080e7          	jalr	724(ra) # 80001a44 <uvmalloc>
    80005778:	e0a43023          	sd	a0,-512(s0)
    8000577c:	c935                	beqz	a0,800057f0 <exec+0x232>
    if(ph.vaddr % PGSIZE != 0)
    8000577e:	e2043c83          	ld	s9,-480(s0)
    80005782:	de843783          	ld	a5,-536(s0)
    80005786:	00fcf7b3          	and	a5,s9,a5
    8000578a:	e3bd                	bnez	a5,800057f0 <exec+0x232>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000578c:	e1842d83          	lw	s11,-488(s0)
    80005790:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005794:	f80b83e3          	beqz	s7,8000571a <exec+0x15c>
    80005798:	8a5e                	mv	s4,s7
    8000579a:	4481                	li	s1,0
    8000579c:	bfb1                	j	800056f8 <exec+0x13a>
  sz = 0;
    8000579e:	e0043023          	sd	zero,-512(s0)
  iunlockput(ip);
    800057a2:	854a                	mv	a0,s2
    800057a4:	fffff097          	auipc	ra,0xfffff
    800057a8:	a00080e7          	jalr	-1536(ra) # 800041a4 <iunlockput>
  end_op(ROOTDEV);
    800057ac:	4501                	li	a0,0
    800057ae:	fffff097          	auipc	ra,0xfffff
    800057b2:	23c080e7          	jalr	572(ra) # 800049ea <end_op>
  p = myproc();
    800057b6:	ffffd097          	auipc	ra,0xffffd
    800057ba:	88a080e7          	jalr	-1910(ra) # 80002040 <myproc>
    800057be:	8caa                	mv	s9,a0
  uint64 oldsz = p->sz;
    800057c0:	06053d83          	ld	s11,96(a0)
  sz = PGROUNDUP(sz);
    800057c4:	6585                	lui	a1,0x1
    800057c6:	15fd                	addi	a1,a1,-1
    800057c8:	e0043783          	ld	a5,-512(s0)
    800057cc:	00b78d33          	add	s10,a5,a1
    800057d0:	75fd                	lui	a1,0xfffff
    800057d2:	00bd75b3          	and	a1,s10,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800057d6:	6609                	lui	a2,0x2
    800057d8:	962e                	add	a2,a2,a1
    800057da:	e0843483          	ld	s1,-504(s0)
    800057de:	8526                	mv	a0,s1
    800057e0:	ffffc097          	auipc	ra,0xffffc
    800057e4:	264080e7          	jalr	612(ra) # 80001a44 <uvmalloc>
    800057e8:	e0a43023          	sd	a0,-512(s0)
  ip = 0;
    800057ec:	4901                	li	s2,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800057ee:	ed09                	bnez	a0,80005808 <exec+0x24a>
    proc_freepagetable(pagetable, sz);
    800057f0:	e0043583          	ld	a1,-512(s0)
    800057f4:	e0843503          	ld	a0,-504(s0)
    800057f8:	ffffd097          	auipc	ra,0xffffd
    800057fc:	a12080e7          	jalr	-1518(ra) # 8000220a <proc_freepagetable>
  if(ip){
    80005800:	e40914e3          	bnez	s2,80005648 <exec+0x8a>
  return -1;
    80005804:	557d                	li	a0,-1
    80005806:	bda1                	j	8000565e <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005808:	75f9                	lui	a1,0xffffe
    8000580a:	892a                	mv	s2,a0
    8000580c:	95aa                	add	a1,a1,a0
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffc097          	auipc	ra,0xffffc
    80005814:	3dc080e7          	jalr	988(ra) # 80001bec <uvmclear>
  stackbase = sp - PGSIZE;
    80005818:	7b7d                	lui	s6,0xfffff
    8000581a:	9b4a                	add	s6,s6,s2
  for(argc = 0; argv[argc]; argc++) {
    8000581c:	df843983          	ld	s3,-520(s0)
    80005820:	0009b503          	ld	a0,0(s3)
    80005824:	c125                	beqz	a0,80005884 <exec+0x2c6>
    80005826:	e8840a13          	addi	s4,s0,-376
    8000582a:	f8840b93          	addi	s7,s0,-120
    8000582e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005830:	ffffc097          	auipc	ra,0xffffc
    80005834:	aa8080e7          	jalr	-1368(ra) # 800012d8 <strlen>
    80005838:	2505                	addiw	a0,a0,1
    8000583a:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000583e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005842:	11696963          	bltu	s2,s6,80005954 <exec+0x396>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005846:	0009ba83          	ld	s5,0(s3)
    8000584a:	8556                	mv	a0,s5
    8000584c:	ffffc097          	auipc	ra,0xffffc
    80005850:	a8c080e7          	jalr	-1396(ra) # 800012d8 <strlen>
    80005854:	0015069b          	addiw	a3,a0,1
    80005858:	8656                	mv	a2,s5
    8000585a:	85ca                	mv	a1,s2
    8000585c:	e0843503          	ld	a0,-504(s0)
    80005860:	ffffc097          	auipc	ra,0xffffc
    80005864:	3be080e7          	jalr	958(ra) # 80001c1e <copyout>
    80005868:	0e054863          	bltz	a0,80005958 <exec+0x39a>
    ustack[argc] = sp;
    8000586c:	012a3023          	sd	s2,0(s4)
  for(argc = 0; argv[argc]; argc++) {
    80005870:	0485                	addi	s1,s1,1
    80005872:	09a1                	addi	s3,s3,8
    80005874:	0009b503          	ld	a0,0(s3)
    80005878:	c909                	beqz	a0,8000588a <exec+0x2cc>
    if(argc >= MAXARG)
    8000587a:	0a21                	addi	s4,s4,8
    8000587c:	fb7a1ae3          	bne	s4,s7,80005830 <exec+0x272>
  ip = 0;
    80005880:	4901                	li	s2,0
    80005882:	b7bd                	j	800057f0 <exec+0x232>
  sp = sz;
    80005884:	e0043903          	ld	s2,-512(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005888:	4481                	li	s1,0
  ustack[argc] = 0;
    8000588a:	00349793          	slli	a5,s1,0x3
    8000588e:	f9040713          	addi	a4,s0,-112
    80005892:	97ba                	add	a5,a5,a4
    80005894:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd0e4c>
  sp -= (argc+1) * sizeof(uint64);
    80005898:	00148693          	addi	a3,s1,1
    8000589c:	068e                	slli	a3,a3,0x3
    8000589e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800058a2:	ff097993          	andi	s3,s2,-16
  ip = 0;
    800058a6:	4901                	li	s2,0
  if(sp < stackbase)
    800058a8:	f569e4e3          	bltu	s3,s6,800057f0 <exec+0x232>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800058ac:	e8840613          	addi	a2,s0,-376
    800058b0:	85ce                	mv	a1,s3
    800058b2:	e0843503          	ld	a0,-504(s0)
    800058b6:	ffffc097          	auipc	ra,0xffffc
    800058ba:	368080e7          	jalr	872(ra) # 80001c1e <copyout>
    800058be:	08054f63          	bltz	a0,8000595c <exec+0x39e>
  p->tf->a1 = sp;
    800058c2:	070cb783          	ld	a5,112(s9) # 2070 <_entry-0x7fffdf90>
    800058c6:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    800058ca:	df043783          	ld	a5,-528(s0)
    800058ce:	0007c703          	lbu	a4,0(a5)
    800058d2:	cf11                	beqz	a4,800058ee <exec+0x330>
    800058d4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800058d6:	02f00693          	li	a3,47
    800058da:	a029                	j	800058e4 <exec+0x326>
    800058dc:	0785                	addi	a5,a5,1
  for(last=s=path; *s; s++)
    800058de:	fff7c703          	lbu	a4,-1(a5)
    800058e2:	c711                	beqz	a4,800058ee <exec+0x330>
    if(*s == '/')
    800058e4:	fed71ce3          	bne	a4,a3,800058dc <exec+0x31e>
      last = s+1;
    800058e8:	def43823          	sd	a5,-528(s0)
    800058ec:	bfc5                	j	800058dc <exec+0x31e>
  safestrcpy(p->name, last, sizeof(p->name));
    800058ee:	4641                	li	a2,16
    800058f0:	df043583          	ld	a1,-528(s0)
    800058f4:	170c8513          	addi	a0,s9,368
    800058f8:	ffffc097          	auipc	ra,0xffffc
    800058fc:	9ae080e7          	jalr	-1618(ra) # 800012a6 <safestrcpy>
  if(p->cmd) bd_free(p->cmd);
    80005900:	180cb503          	ld	a0,384(s9)
    80005904:	c509                	beqz	a0,8000590e <exec+0x350>
    80005906:	00002097          	auipc	ra,0x2
    8000590a:	9c6080e7          	jalr	-1594(ra) # 800072cc <bd_free>
  p->cmd = strjoin(argv);
    8000590e:	df843503          	ld	a0,-520(s0)
    80005912:	ffffc097          	auipc	ra,0xffffc
    80005916:	9f0080e7          	jalr	-1552(ra) # 80001302 <strjoin>
    8000591a:	18acb023          	sd	a0,384(s9)
  oldpagetable = p->pagetable;
    8000591e:	068cb503          	ld	a0,104(s9)
  p->pagetable = pagetable;
    80005922:	e0843783          	ld	a5,-504(s0)
    80005926:	06fcb423          	sd	a5,104(s9)
  p->sz = sz;
    8000592a:	e0043783          	ld	a5,-512(s0)
    8000592e:	06fcb023          	sd	a5,96(s9)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005932:	070cb783          	ld	a5,112(s9)
    80005936:	e6043703          	ld	a4,-416(s0)
    8000593a:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    8000593c:	070cb783          	ld	a5,112(s9)
    80005940:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005944:	85ee                	mv	a1,s11
    80005946:	ffffd097          	auipc	ra,0xffffd
    8000594a:	8c4080e7          	jalr	-1852(ra) # 8000220a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000594e:	0004851b          	sext.w	a0,s1
    80005952:	b331                	j	8000565e <exec+0xa0>
  ip = 0;
    80005954:	4901                	li	s2,0
    80005956:	bd69                	j	800057f0 <exec+0x232>
    80005958:	4901                	li	s2,0
    8000595a:	bd59                	j	800057f0 <exec+0x232>
    8000595c:	4901                	li	s2,0
    8000595e:	bd49                	j	800057f0 <exec+0x232>

0000000080005960 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005960:	7179                	addi	sp,sp,-48
    80005962:	f406                	sd	ra,40(sp)
    80005964:	f022                	sd	s0,32(sp)
    80005966:	ec26                	sd	s1,24(sp)
    80005968:	e84a                	sd	s2,16(sp)
    8000596a:	1800                	addi	s0,sp,48
    8000596c:	892e                	mv	s2,a1
    8000596e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005970:	fdc40593          	addi	a1,s0,-36
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	a1e080e7          	jalr	-1506(ra) # 80003392 <argint>
    8000597c:	04054063          	bltz	a0,800059bc <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005980:	fdc42703          	lw	a4,-36(s0)
    80005984:	47bd                	li	a5,15
    80005986:	02e7ed63          	bltu	a5,a4,800059c0 <argfd+0x60>
    8000598a:	ffffc097          	auipc	ra,0xffffc
    8000598e:	6b6080e7          	jalr	1718(ra) # 80002040 <myproc>
    80005992:	fdc42703          	lw	a4,-36(s0)
    80005996:	01c70793          	addi	a5,a4,28
    8000599a:	078e                	slli	a5,a5,0x3
    8000599c:	953e                	add	a0,a0,a5
    8000599e:	651c                	ld	a5,8(a0)
    800059a0:	c395                	beqz	a5,800059c4 <argfd+0x64>
    return -1;
  if(pfd)
    800059a2:	00090463          	beqz	s2,800059aa <argfd+0x4a>
    *pfd = fd;
    800059a6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800059aa:	4501                	li	a0,0
  if(pf)
    800059ac:	c091                	beqz	s1,800059b0 <argfd+0x50>
    *pf = f;
    800059ae:	e09c                	sd	a5,0(s1)
}
    800059b0:	70a2                	ld	ra,40(sp)
    800059b2:	7402                	ld	s0,32(sp)
    800059b4:	64e2                	ld	s1,24(sp)
    800059b6:	6942                	ld	s2,16(sp)
    800059b8:	6145                	addi	sp,sp,48
    800059ba:	8082                	ret
    return -1;
    800059bc:	557d                	li	a0,-1
    800059be:	bfcd                	j	800059b0 <argfd+0x50>
    return -1;
    800059c0:	557d                	li	a0,-1
    800059c2:	b7fd                	j	800059b0 <argfd+0x50>
    800059c4:	557d                	li	a0,-1
    800059c6:	b7ed                	j	800059b0 <argfd+0x50>

00000000800059c8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800059c8:	1101                	addi	sp,sp,-32
    800059ca:	ec06                	sd	ra,24(sp)
    800059cc:	e822                	sd	s0,16(sp)
    800059ce:	e426                	sd	s1,8(sp)
    800059d0:	1000                	addi	s0,sp,32
    800059d2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800059d4:	ffffc097          	auipc	ra,0xffffc
    800059d8:	66c080e7          	jalr	1644(ra) # 80002040 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    800059dc:	757c                	ld	a5,232(a0)
    800059de:	c395                	beqz	a5,80005a02 <fdalloc+0x3a>
    800059e0:	0f050713          	addi	a4,a0,240
  for(fd = 0; fd < NOFILE; fd++){
    800059e4:	4785                	li	a5,1
    800059e6:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    800059e8:	6314                	ld	a3,0(a4)
    800059ea:	ce89                	beqz	a3,80005a04 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    800059ec:	2785                	addiw	a5,a5,1
    800059ee:	0721                	addi	a4,a4,8
    800059f0:	fec79ce3          	bne	a5,a2,800059e8 <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800059f4:	57fd                	li	a5,-1
}
    800059f6:	853e                	mv	a0,a5
    800059f8:	60e2                	ld	ra,24(sp)
    800059fa:	6442                	ld	s0,16(sp)
    800059fc:	64a2                	ld	s1,8(sp)
    800059fe:	6105                	addi	sp,sp,32
    80005a00:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005a02:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005a04:	01c78713          	addi	a4,a5,28
    80005a08:	070e                	slli	a4,a4,0x3
    80005a0a:	953a                	add	a0,a0,a4
    80005a0c:	e504                	sd	s1,8(a0)
      return fd;
    80005a0e:	b7e5                	j	800059f6 <fdalloc+0x2e>

0000000080005a10 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005a10:	715d                	addi	sp,sp,-80
    80005a12:	e486                	sd	ra,72(sp)
    80005a14:	e0a2                	sd	s0,64(sp)
    80005a16:	fc26                	sd	s1,56(sp)
    80005a18:	f84a                	sd	s2,48(sp)
    80005a1a:	f44e                	sd	s3,40(sp)
    80005a1c:	f052                	sd	s4,32(sp)
    80005a1e:	ec56                	sd	s5,24(sp)
    80005a20:	0880                	addi	s0,sp,80
    80005a22:	89ae                	mv	s3,a1
    80005a24:	8ab2                	mv	s5,a2
    80005a26:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005a28:	fb040593          	addi	a1,s0,-80
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	cea080e7          	jalr	-790(ra) # 80004716 <nameiparent>
    80005a34:	892a                	mv	s2,a0
    80005a36:	12050f63          	beqz	a0,80005b74 <create+0x164>
    return 0;

  ilock(dp);
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	52a080e7          	jalr	1322(ra) # 80003f64 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005a42:	4601                	li	a2,0
    80005a44:	fb040593          	addi	a1,s0,-80
    80005a48:	854a                	mv	a0,s2
    80005a4a:	fffff097          	auipc	ra,0xfffff
    80005a4e:	9d4080e7          	jalr	-1580(ra) # 8000441e <dirlookup>
    80005a52:	84aa                	mv	s1,a0
    80005a54:	c921                	beqz	a0,80005aa4 <create+0x94>
    iunlockput(dp);
    80005a56:	854a                	mv	a0,s2
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	74c080e7          	jalr	1868(ra) # 800041a4 <iunlockput>
    ilock(ip);
    80005a60:	8526                	mv	a0,s1
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	502080e7          	jalr	1282(ra) # 80003f64 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005a6a:	2981                	sext.w	s3,s3
    80005a6c:	4789                	li	a5,2
    80005a6e:	02f99463          	bne	s3,a5,80005a96 <create+0x86>
    80005a72:	05c4d783          	lhu	a5,92(s1)
    80005a76:	37f9                	addiw	a5,a5,-2
    80005a78:	17c2                	slli	a5,a5,0x30
    80005a7a:	93c1                	srli	a5,a5,0x30
    80005a7c:	4705                	li	a4,1
    80005a7e:	00f76c63          	bltu	a4,a5,80005a96 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005a82:	8526                	mv	a0,s1
    80005a84:	60a6                	ld	ra,72(sp)
    80005a86:	6406                	ld	s0,64(sp)
    80005a88:	74e2                	ld	s1,56(sp)
    80005a8a:	7942                	ld	s2,48(sp)
    80005a8c:	79a2                	ld	s3,40(sp)
    80005a8e:	7a02                	ld	s4,32(sp)
    80005a90:	6ae2                	ld	s5,24(sp)
    80005a92:	6161                	addi	sp,sp,80
    80005a94:	8082                	ret
    iunlockput(ip);
    80005a96:	8526                	mv	a0,s1
    80005a98:	ffffe097          	auipc	ra,0xffffe
    80005a9c:	70c080e7          	jalr	1804(ra) # 800041a4 <iunlockput>
    return 0;
    80005aa0:	4481                	li	s1,0
    80005aa2:	b7c5                	j	80005a82 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005aa4:	85ce                	mv	a1,s3
    80005aa6:	00092503          	lw	a0,0(s2)
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	31e080e7          	jalr	798(ra) # 80003dc8 <ialloc>
    80005ab2:	84aa                	mv	s1,a0
    80005ab4:	c529                	beqz	a0,80005afe <create+0xee>
  ilock(ip);
    80005ab6:	ffffe097          	auipc	ra,0xffffe
    80005aba:	4ae080e7          	jalr	1198(ra) # 80003f64 <ilock>
  ip->major = major;
    80005abe:	05549f23          	sh	s5,94(s1)
  ip->minor = minor;
    80005ac2:	07449023          	sh	s4,96(s1)
  ip->nlink = 1;
    80005ac6:	4785                	li	a5,1
    80005ac8:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005acc:	8526                	mv	a0,s1
    80005ace:	ffffe097          	auipc	ra,0xffffe
    80005ad2:	3ca080e7          	jalr	970(ra) # 80003e98 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005ad6:	2981                	sext.w	s3,s3
    80005ad8:	4785                	li	a5,1
    80005ada:	02f98a63          	beq	s3,a5,80005b0e <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005ade:	40d0                	lw	a2,4(s1)
    80005ae0:	fb040593          	addi	a1,s0,-80
    80005ae4:	854a                	mv	a0,s2
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	b50080e7          	jalr	-1200(ra) # 80004636 <dirlink>
    80005aee:	06054b63          	bltz	a0,80005b64 <create+0x154>
  iunlockput(dp);
    80005af2:	854a                	mv	a0,s2
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	6b0080e7          	jalr	1712(ra) # 800041a4 <iunlockput>
  return ip;
    80005afc:	b759                	j	80005a82 <create+0x72>
    panic("create: ialloc");
    80005afe:	00003517          	auipc	a0,0x3
    80005b02:	14a50513          	addi	a0,a0,330 # 80008c48 <userret+0xbb8>
    80005b06:	ffffb097          	auipc	ra,0xffffb
    80005b0a:	c7e080e7          	jalr	-898(ra) # 80000784 <panic>
    dp->nlink++;  // for ".."
    80005b0e:	06295783          	lhu	a5,98(s2)
    80005b12:	2785                	addiw	a5,a5,1
    80005b14:	06f91123          	sh	a5,98(s2)
    iupdate(dp);
    80005b18:	854a                	mv	a0,s2
    80005b1a:	ffffe097          	auipc	ra,0xffffe
    80005b1e:	37e080e7          	jalr	894(ra) # 80003e98 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005b22:	40d0                	lw	a2,4(s1)
    80005b24:	00003597          	auipc	a1,0x3
    80005b28:	13458593          	addi	a1,a1,308 # 80008c58 <userret+0xbc8>
    80005b2c:	8526                	mv	a0,s1
    80005b2e:	fffff097          	auipc	ra,0xfffff
    80005b32:	b08080e7          	jalr	-1272(ra) # 80004636 <dirlink>
    80005b36:	00054f63          	bltz	a0,80005b54 <create+0x144>
    80005b3a:	00492603          	lw	a2,4(s2)
    80005b3e:	00003597          	auipc	a1,0x3
    80005b42:	12258593          	addi	a1,a1,290 # 80008c60 <userret+0xbd0>
    80005b46:	8526                	mv	a0,s1
    80005b48:	fffff097          	auipc	ra,0xfffff
    80005b4c:	aee080e7          	jalr	-1298(ra) # 80004636 <dirlink>
    80005b50:	f80557e3          	bgez	a0,80005ade <create+0xce>
      panic("create dots");
    80005b54:	00003517          	auipc	a0,0x3
    80005b58:	11450513          	addi	a0,a0,276 # 80008c68 <userret+0xbd8>
    80005b5c:	ffffb097          	auipc	ra,0xffffb
    80005b60:	c28080e7          	jalr	-984(ra) # 80000784 <panic>
    panic("create: dirlink");
    80005b64:	00003517          	auipc	a0,0x3
    80005b68:	11450513          	addi	a0,a0,276 # 80008c78 <userret+0xbe8>
    80005b6c:	ffffb097          	auipc	ra,0xffffb
    80005b70:	c18080e7          	jalr	-1000(ra) # 80000784 <panic>
    return 0;
    80005b74:	84aa                	mv	s1,a0
    80005b76:	b731                	j	80005a82 <create+0x72>

0000000080005b78 <sys_dup>:
{
    80005b78:	7179                	addi	sp,sp,-48
    80005b7a:	f406                	sd	ra,40(sp)
    80005b7c:	f022                	sd	s0,32(sp)
    80005b7e:	ec26                	sd	s1,24(sp)
    80005b80:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005b82:	fd840613          	addi	a2,s0,-40
    80005b86:	4581                	li	a1,0
    80005b88:	4501                	li	a0,0
    80005b8a:	00000097          	auipc	ra,0x0
    80005b8e:	dd6080e7          	jalr	-554(ra) # 80005960 <argfd>
    return -1;
    80005b92:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005b94:	02054363          	bltz	a0,80005bba <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005b98:	fd843503          	ld	a0,-40(s0)
    80005b9c:	00000097          	auipc	ra,0x0
    80005ba0:	e2c080e7          	jalr	-468(ra) # 800059c8 <fdalloc>
    80005ba4:	84aa                	mv	s1,a0
    return -1;
    80005ba6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005ba8:	00054963          	bltz	a0,80005bba <sys_dup+0x42>
  filedup(f);
    80005bac:	fd843503          	ld	a0,-40(s0)
    80005bb0:	fffff097          	auipc	ra,0xfffff
    80005bb4:	2f8080e7          	jalr	760(ra) # 80004ea8 <filedup>
  return fd;
    80005bb8:	87a6                	mv	a5,s1
}
    80005bba:	853e                	mv	a0,a5
    80005bbc:	70a2                	ld	ra,40(sp)
    80005bbe:	7402                	ld	s0,32(sp)
    80005bc0:	64e2                	ld	s1,24(sp)
    80005bc2:	6145                	addi	sp,sp,48
    80005bc4:	8082                	ret

0000000080005bc6 <sys_read>:
{
    80005bc6:	7179                	addi	sp,sp,-48
    80005bc8:	f406                	sd	ra,40(sp)
    80005bca:	f022                	sd	s0,32(sp)
    80005bcc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005bce:	fe840613          	addi	a2,s0,-24
    80005bd2:	4581                	li	a1,0
    80005bd4:	4501                	li	a0,0
    80005bd6:	00000097          	auipc	ra,0x0
    80005bda:	d8a080e7          	jalr	-630(ra) # 80005960 <argfd>
    return -1;
    80005bde:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005be0:	04054163          	bltz	a0,80005c22 <sys_read+0x5c>
    80005be4:	fe440593          	addi	a1,s0,-28
    80005be8:	4509                	li	a0,2
    80005bea:	ffffd097          	auipc	ra,0xffffd
    80005bee:	7a8080e7          	jalr	1960(ra) # 80003392 <argint>
    return -1;
    80005bf2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005bf4:	02054763          	bltz	a0,80005c22 <sys_read+0x5c>
    80005bf8:	fd840593          	addi	a1,s0,-40
    80005bfc:	4505                	li	a0,1
    80005bfe:	ffffd097          	auipc	ra,0xffffd
    80005c02:	7b6080e7          	jalr	1974(ra) # 800033b4 <argaddr>
    return -1;
    80005c06:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c08:	00054d63          	bltz	a0,80005c22 <sys_read+0x5c>
  return fileread(f, p, n);
    80005c0c:	fe442603          	lw	a2,-28(s0)
    80005c10:	fd843583          	ld	a1,-40(s0)
    80005c14:	fe843503          	ld	a0,-24(s0)
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	424080e7          	jalr	1060(ra) # 8000503c <fileread>
    80005c20:	87aa                	mv	a5,a0
}
    80005c22:	853e                	mv	a0,a5
    80005c24:	70a2                	ld	ra,40(sp)
    80005c26:	7402                	ld	s0,32(sp)
    80005c28:	6145                	addi	sp,sp,48
    80005c2a:	8082                	ret

0000000080005c2c <sys_write>:
{
    80005c2c:	7179                	addi	sp,sp,-48
    80005c2e:	f406                	sd	ra,40(sp)
    80005c30:	f022                	sd	s0,32(sp)
    80005c32:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c34:	fe840613          	addi	a2,s0,-24
    80005c38:	4581                	li	a1,0
    80005c3a:	4501                	li	a0,0
    80005c3c:	00000097          	auipc	ra,0x0
    80005c40:	d24080e7          	jalr	-732(ra) # 80005960 <argfd>
    return -1;
    80005c44:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c46:	04054163          	bltz	a0,80005c88 <sys_write+0x5c>
    80005c4a:	fe440593          	addi	a1,s0,-28
    80005c4e:	4509                	li	a0,2
    80005c50:	ffffd097          	auipc	ra,0xffffd
    80005c54:	742080e7          	jalr	1858(ra) # 80003392 <argint>
    return -1;
    80005c58:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c5a:	02054763          	bltz	a0,80005c88 <sys_write+0x5c>
    80005c5e:	fd840593          	addi	a1,s0,-40
    80005c62:	4505                	li	a0,1
    80005c64:	ffffd097          	auipc	ra,0xffffd
    80005c68:	750080e7          	jalr	1872(ra) # 800033b4 <argaddr>
    return -1;
    80005c6c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c6e:	00054d63          	bltz	a0,80005c88 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005c72:	fe442603          	lw	a2,-28(s0)
    80005c76:	fd843583          	ld	a1,-40(s0)
    80005c7a:	fe843503          	ld	a0,-24(s0)
    80005c7e:	fffff097          	auipc	ra,0xfffff
    80005c82:	484080e7          	jalr	1156(ra) # 80005102 <filewrite>
    80005c86:	87aa                	mv	a5,a0
}
    80005c88:	853e                	mv	a0,a5
    80005c8a:	70a2                	ld	ra,40(sp)
    80005c8c:	7402                	ld	s0,32(sp)
    80005c8e:	6145                	addi	sp,sp,48
    80005c90:	8082                	ret

0000000080005c92 <sys_close>:
{
    80005c92:	1101                	addi	sp,sp,-32
    80005c94:	ec06                	sd	ra,24(sp)
    80005c96:	e822                	sd	s0,16(sp)
    80005c98:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005c9a:	fe040613          	addi	a2,s0,-32
    80005c9e:	fec40593          	addi	a1,s0,-20
    80005ca2:	4501                	li	a0,0
    80005ca4:	00000097          	auipc	ra,0x0
    80005ca8:	cbc080e7          	jalr	-836(ra) # 80005960 <argfd>
    return -1;
    80005cac:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005cae:	02054463          	bltz	a0,80005cd6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005cb2:	ffffc097          	auipc	ra,0xffffc
    80005cb6:	38e080e7          	jalr	910(ra) # 80002040 <myproc>
    80005cba:	fec42783          	lw	a5,-20(s0)
    80005cbe:	07f1                	addi	a5,a5,28
    80005cc0:	078e                	slli	a5,a5,0x3
    80005cc2:	953e                	add	a0,a0,a5
    80005cc4:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005cc8:	fe043503          	ld	a0,-32(s0)
    80005ccc:	fffff097          	auipc	ra,0xfffff
    80005cd0:	22e080e7          	jalr	558(ra) # 80004efa <fileclose>
  return 0;
    80005cd4:	4781                	li	a5,0
}
    80005cd6:	853e                	mv	a0,a5
    80005cd8:	60e2                	ld	ra,24(sp)
    80005cda:	6442                	ld	s0,16(sp)
    80005cdc:	6105                	addi	sp,sp,32
    80005cde:	8082                	ret

0000000080005ce0 <sys_fstat>:
{
    80005ce0:	1101                	addi	sp,sp,-32
    80005ce2:	ec06                	sd	ra,24(sp)
    80005ce4:	e822                	sd	s0,16(sp)
    80005ce6:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005ce8:	fe840613          	addi	a2,s0,-24
    80005cec:	4581                	li	a1,0
    80005cee:	4501                	li	a0,0
    80005cf0:	00000097          	auipc	ra,0x0
    80005cf4:	c70080e7          	jalr	-912(ra) # 80005960 <argfd>
    return -1;
    80005cf8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005cfa:	02054563          	bltz	a0,80005d24 <sys_fstat+0x44>
    80005cfe:	fe040593          	addi	a1,s0,-32
    80005d02:	4505                	li	a0,1
    80005d04:	ffffd097          	auipc	ra,0xffffd
    80005d08:	6b0080e7          	jalr	1712(ra) # 800033b4 <argaddr>
    return -1;
    80005d0c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005d0e:	00054b63          	bltz	a0,80005d24 <sys_fstat+0x44>
  return filestat(f, st);
    80005d12:	fe043583          	ld	a1,-32(s0)
    80005d16:	fe843503          	ld	a0,-24(s0)
    80005d1a:	fffff097          	auipc	ra,0xfffff
    80005d1e:	2b0080e7          	jalr	688(ra) # 80004fca <filestat>
    80005d22:	87aa                	mv	a5,a0
}
    80005d24:	853e                	mv	a0,a5
    80005d26:	60e2                	ld	ra,24(sp)
    80005d28:	6442                	ld	s0,16(sp)
    80005d2a:	6105                	addi	sp,sp,32
    80005d2c:	8082                	ret

0000000080005d2e <sys_link>:
{
    80005d2e:	7169                	addi	sp,sp,-304
    80005d30:	f606                	sd	ra,296(sp)
    80005d32:	f222                	sd	s0,288(sp)
    80005d34:	ee26                	sd	s1,280(sp)
    80005d36:	ea4a                	sd	s2,272(sp)
    80005d38:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d3a:	08000613          	li	a2,128
    80005d3e:	ed040593          	addi	a1,s0,-304
    80005d42:	4501                	li	a0,0
    80005d44:	ffffd097          	auipc	ra,0xffffd
    80005d48:	692080e7          	jalr	1682(ra) # 800033d6 <argstr>
    return -1;
    80005d4c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d4e:	12054363          	bltz	a0,80005e74 <sys_link+0x146>
    80005d52:	08000613          	li	a2,128
    80005d56:	f5040593          	addi	a1,s0,-176
    80005d5a:	4505                	li	a0,1
    80005d5c:	ffffd097          	auipc	ra,0xffffd
    80005d60:	67a080e7          	jalr	1658(ra) # 800033d6 <argstr>
    return -1;
    80005d64:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d66:	10054763          	bltz	a0,80005e74 <sys_link+0x146>
  begin_op(ROOTDEV);
    80005d6a:	4501                	li	a0,0
    80005d6c:	fffff097          	auipc	ra,0xfffff
    80005d70:	bd2080e7          	jalr	-1070(ra) # 8000493e <begin_op>
  if((ip = namei(old)) == 0){
    80005d74:	ed040513          	addi	a0,s0,-304
    80005d78:	fffff097          	auipc	ra,0xfffff
    80005d7c:	980080e7          	jalr	-1664(ra) # 800046f8 <namei>
    80005d80:	84aa                	mv	s1,a0
    80005d82:	c559                	beqz	a0,80005e10 <sys_link+0xe2>
  ilock(ip);
    80005d84:	ffffe097          	auipc	ra,0xffffe
    80005d88:	1e0080e7          	jalr	480(ra) # 80003f64 <ilock>
  if(ip->type == T_DIR){
    80005d8c:	05c49703          	lh	a4,92(s1)
    80005d90:	4785                	li	a5,1
    80005d92:	08f70663          	beq	a4,a5,80005e1e <sys_link+0xf0>
  ip->nlink++;
    80005d96:	0624d783          	lhu	a5,98(s1)
    80005d9a:	2785                	addiw	a5,a5,1
    80005d9c:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005da0:	8526                	mv	a0,s1
    80005da2:	ffffe097          	auipc	ra,0xffffe
    80005da6:	0f6080e7          	jalr	246(ra) # 80003e98 <iupdate>
  iunlock(ip);
    80005daa:	8526                	mv	a0,s1
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	27c080e7          	jalr	636(ra) # 80004028 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005db4:	fd040593          	addi	a1,s0,-48
    80005db8:	f5040513          	addi	a0,s0,-176
    80005dbc:	fffff097          	auipc	ra,0xfffff
    80005dc0:	95a080e7          	jalr	-1702(ra) # 80004716 <nameiparent>
    80005dc4:	892a                	mv	s2,a0
    80005dc6:	cd2d                	beqz	a0,80005e40 <sys_link+0x112>
  ilock(dp);
    80005dc8:	ffffe097          	auipc	ra,0xffffe
    80005dcc:	19c080e7          	jalr	412(ra) # 80003f64 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005dd0:	00092703          	lw	a4,0(s2)
    80005dd4:	409c                	lw	a5,0(s1)
    80005dd6:	06f71063          	bne	a4,a5,80005e36 <sys_link+0x108>
    80005dda:	40d0                	lw	a2,4(s1)
    80005ddc:	fd040593          	addi	a1,s0,-48
    80005de0:	854a                	mv	a0,s2
    80005de2:	fffff097          	auipc	ra,0xfffff
    80005de6:	854080e7          	jalr	-1964(ra) # 80004636 <dirlink>
    80005dea:	04054663          	bltz	a0,80005e36 <sys_link+0x108>
  iunlockput(dp);
    80005dee:	854a                	mv	a0,s2
    80005df0:	ffffe097          	auipc	ra,0xffffe
    80005df4:	3b4080e7          	jalr	948(ra) # 800041a4 <iunlockput>
  iput(ip);
    80005df8:	8526                	mv	a0,s1
    80005dfa:	ffffe097          	auipc	ra,0xffffe
    80005dfe:	27a080e7          	jalr	634(ra) # 80004074 <iput>
  end_op(ROOTDEV);
    80005e02:	4501                	li	a0,0
    80005e04:	fffff097          	auipc	ra,0xfffff
    80005e08:	be6080e7          	jalr	-1050(ra) # 800049ea <end_op>
  return 0;
    80005e0c:	4781                	li	a5,0
    80005e0e:	a09d                	j	80005e74 <sys_link+0x146>
    end_op(ROOTDEV);
    80005e10:	4501                	li	a0,0
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	bd8080e7          	jalr	-1064(ra) # 800049ea <end_op>
    return -1;
    80005e1a:	57fd                	li	a5,-1
    80005e1c:	a8a1                	j	80005e74 <sys_link+0x146>
    iunlockput(ip);
    80005e1e:	8526                	mv	a0,s1
    80005e20:	ffffe097          	auipc	ra,0xffffe
    80005e24:	384080e7          	jalr	900(ra) # 800041a4 <iunlockput>
    end_op(ROOTDEV);
    80005e28:	4501                	li	a0,0
    80005e2a:	fffff097          	auipc	ra,0xfffff
    80005e2e:	bc0080e7          	jalr	-1088(ra) # 800049ea <end_op>
    return -1;
    80005e32:	57fd                	li	a5,-1
    80005e34:	a081                	j	80005e74 <sys_link+0x146>
    iunlockput(dp);
    80005e36:	854a                	mv	a0,s2
    80005e38:	ffffe097          	auipc	ra,0xffffe
    80005e3c:	36c080e7          	jalr	876(ra) # 800041a4 <iunlockput>
  ilock(ip);
    80005e40:	8526                	mv	a0,s1
    80005e42:	ffffe097          	auipc	ra,0xffffe
    80005e46:	122080e7          	jalr	290(ra) # 80003f64 <ilock>
  ip->nlink--;
    80005e4a:	0624d783          	lhu	a5,98(s1)
    80005e4e:	37fd                	addiw	a5,a5,-1
    80005e50:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005e54:	8526                	mv	a0,s1
    80005e56:	ffffe097          	auipc	ra,0xffffe
    80005e5a:	042080e7          	jalr	66(ra) # 80003e98 <iupdate>
  iunlockput(ip);
    80005e5e:	8526                	mv	a0,s1
    80005e60:	ffffe097          	auipc	ra,0xffffe
    80005e64:	344080e7          	jalr	836(ra) # 800041a4 <iunlockput>
  end_op(ROOTDEV);
    80005e68:	4501                	li	a0,0
    80005e6a:	fffff097          	auipc	ra,0xfffff
    80005e6e:	b80080e7          	jalr	-1152(ra) # 800049ea <end_op>
  return -1;
    80005e72:	57fd                	li	a5,-1
}
    80005e74:	853e                	mv	a0,a5
    80005e76:	70b2                	ld	ra,296(sp)
    80005e78:	7412                	ld	s0,288(sp)
    80005e7a:	64f2                	ld	s1,280(sp)
    80005e7c:	6952                	ld	s2,272(sp)
    80005e7e:	6155                	addi	sp,sp,304
    80005e80:	8082                	ret

0000000080005e82 <sys_unlink>:
{
    80005e82:	7151                	addi	sp,sp,-240
    80005e84:	f586                	sd	ra,232(sp)
    80005e86:	f1a2                	sd	s0,224(sp)
    80005e88:	eda6                	sd	s1,216(sp)
    80005e8a:	e9ca                	sd	s2,208(sp)
    80005e8c:	e5ce                	sd	s3,200(sp)
    80005e8e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005e90:	08000613          	li	a2,128
    80005e94:	f3040593          	addi	a1,s0,-208
    80005e98:	4501                	li	a0,0
    80005e9a:	ffffd097          	auipc	ra,0xffffd
    80005e9e:	53c080e7          	jalr	1340(ra) # 800033d6 <argstr>
    80005ea2:	18054263          	bltz	a0,80006026 <sys_unlink+0x1a4>
  begin_op(ROOTDEV);
    80005ea6:	4501                	li	a0,0
    80005ea8:	fffff097          	auipc	ra,0xfffff
    80005eac:	a96080e7          	jalr	-1386(ra) # 8000493e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005eb0:	fb040593          	addi	a1,s0,-80
    80005eb4:	f3040513          	addi	a0,s0,-208
    80005eb8:	fffff097          	auipc	ra,0xfffff
    80005ebc:	85e080e7          	jalr	-1954(ra) # 80004716 <nameiparent>
    80005ec0:	89aa                	mv	s3,a0
    80005ec2:	cd61                	beqz	a0,80005f9a <sys_unlink+0x118>
  ilock(dp);
    80005ec4:	ffffe097          	auipc	ra,0xffffe
    80005ec8:	0a0080e7          	jalr	160(ra) # 80003f64 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005ecc:	00003597          	auipc	a1,0x3
    80005ed0:	d8c58593          	addi	a1,a1,-628 # 80008c58 <userret+0xbc8>
    80005ed4:	fb040513          	addi	a0,s0,-80
    80005ed8:	ffffe097          	auipc	ra,0xffffe
    80005edc:	52c080e7          	jalr	1324(ra) # 80004404 <namecmp>
    80005ee0:	14050a63          	beqz	a0,80006034 <sys_unlink+0x1b2>
    80005ee4:	00003597          	auipc	a1,0x3
    80005ee8:	d7c58593          	addi	a1,a1,-644 # 80008c60 <userret+0xbd0>
    80005eec:	fb040513          	addi	a0,s0,-80
    80005ef0:	ffffe097          	auipc	ra,0xffffe
    80005ef4:	514080e7          	jalr	1300(ra) # 80004404 <namecmp>
    80005ef8:	12050e63          	beqz	a0,80006034 <sys_unlink+0x1b2>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005efc:	f2c40613          	addi	a2,s0,-212
    80005f00:	fb040593          	addi	a1,s0,-80
    80005f04:	854e                	mv	a0,s3
    80005f06:	ffffe097          	auipc	ra,0xffffe
    80005f0a:	518080e7          	jalr	1304(ra) # 8000441e <dirlookup>
    80005f0e:	84aa                	mv	s1,a0
    80005f10:	12050263          	beqz	a0,80006034 <sys_unlink+0x1b2>
  ilock(ip);
    80005f14:	ffffe097          	auipc	ra,0xffffe
    80005f18:	050080e7          	jalr	80(ra) # 80003f64 <ilock>
  if(ip->nlink < 1)
    80005f1c:	06249783          	lh	a5,98(s1)
    80005f20:	08f05463          	blez	a5,80005fa8 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005f24:	05c49703          	lh	a4,92(s1)
    80005f28:	4785                	li	a5,1
    80005f2a:	08f70763          	beq	a4,a5,80005fb8 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005f2e:	4641                	li	a2,16
    80005f30:	4581                	li	a1,0
    80005f32:	fc040513          	addi	a0,s0,-64
    80005f36:	ffffb097          	auipc	ra,0xffffb
    80005f3a:	1f8080e7          	jalr	504(ra) # 8000112e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f3e:	4741                	li	a4,16
    80005f40:	f2c42683          	lw	a3,-212(s0)
    80005f44:	fc040613          	addi	a2,s0,-64
    80005f48:	4581                	li	a1,0
    80005f4a:	854e                	mv	a0,s3
    80005f4c:	ffffe097          	auipc	ra,0xffffe
    80005f50:	39e080e7          	jalr	926(ra) # 800042ea <writei>
    80005f54:	47c1                	li	a5,16
    80005f56:	0af51563          	bne	a0,a5,80006000 <sys_unlink+0x17e>
  if(ip->type == T_DIR){
    80005f5a:	05c49703          	lh	a4,92(s1)
    80005f5e:	4785                	li	a5,1
    80005f60:	0af70863          	beq	a4,a5,80006010 <sys_unlink+0x18e>
  iunlockput(dp);
    80005f64:	854e                	mv	a0,s3
    80005f66:	ffffe097          	auipc	ra,0xffffe
    80005f6a:	23e080e7          	jalr	574(ra) # 800041a4 <iunlockput>
  ip->nlink--;
    80005f6e:	0624d783          	lhu	a5,98(s1)
    80005f72:	37fd                	addiw	a5,a5,-1
    80005f74:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005f78:	8526                	mv	a0,s1
    80005f7a:	ffffe097          	auipc	ra,0xffffe
    80005f7e:	f1e080e7          	jalr	-226(ra) # 80003e98 <iupdate>
  iunlockput(ip);
    80005f82:	8526                	mv	a0,s1
    80005f84:	ffffe097          	auipc	ra,0xffffe
    80005f88:	220080e7          	jalr	544(ra) # 800041a4 <iunlockput>
  end_op(ROOTDEV);
    80005f8c:	4501                	li	a0,0
    80005f8e:	fffff097          	auipc	ra,0xfffff
    80005f92:	a5c080e7          	jalr	-1444(ra) # 800049ea <end_op>
  return 0;
    80005f96:	4501                	li	a0,0
    80005f98:	a84d                	j	8000604a <sys_unlink+0x1c8>
    end_op(ROOTDEV);
    80005f9a:	4501                	li	a0,0
    80005f9c:	fffff097          	auipc	ra,0xfffff
    80005fa0:	a4e080e7          	jalr	-1458(ra) # 800049ea <end_op>
    return -1;
    80005fa4:	557d                	li	a0,-1
    80005fa6:	a055                	j	8000604a <sys_unlink+0x1c8>
    panic("unlink: nlink < 1");
    80005fa8:	00003517          	auipc	a0,0x3
    80005fac:	ce050513          	addi	a0,a0,-800 # 80008c88 <userret+0xbf8>
    80005fb0:	ffffa097          	auipc	ra,0xffffa
    80005fb4:	7d4080e7          	jalr	2004(ra) # 80000784 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005fb8:	50f8                	lw	a4,100(s1)
    80005fba:	02000793          	li	a5,32
    80005fbe:	f6e7f8e3          	bleu	a4,a5,80005f2e <sys_unlink+0xac>
    80005fc2:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005fc6:	4741                	li	a4,16
    80005fc8:	86ca                	mv	a3,s2
    80005fca:	f1840613          	addi	a2,s0,-232
    80005fce:	4581                	li	a1,0
    80005fd0:	8526                	mv	a0,s1
    80005fd2:	ffffe097          	auipc	ra,0xffffe
    80005fd6:	224080e7          	jalr	548(ra) # 800041f6 <readi>
    80005fda:	47c1                	li	a5,16
    80005fdc:	00f51a63          	bne	a0,a5,80005ff0 <sys_unlink+0x16e>
    if(de.inum != 0)
    80005fe0:	f1845783          	lhu	a5,-232(s0)
    80005fe4:	e3b9                	bnez	a5,8000602a <sys_unlink+0x1a8>
    80005fe6:	2941                	addiw	s2,s2,16
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005fe8:	50fc                	lw	a5,100(s1)
    80005fea:	fcf96ee3          	bltu	s2,a5,80005fc6 <sys_unlink+0x144>
    80005fee:	b781                	j	80005f2e <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005ff0:	00003517          	auipc	a0,0x3
    80005ff4:	cb050513          	addi	a0,a0,-848 # 80008ca0 <userret+0xc10>
    80005ff8:	ffffa097          	auipc	ra,0xffffa
    80005ffc:	78c080e7          	jalr	1932(ra) # 80000784 <panic>
    panic("unlink: writei");
    80006000:	00003517          	auipc	a0,0x3
    80006004:	cb850513          	addi	a0,a0,-840 # 80008cb8 <userret+0xc28>
    80006008:	ffffa097          	auipc	ra,0xffffa
    8000600c:	77c080e7          	jalr	1916(ra) # 80000784 <panic>
    dp->nlink--;
    80006010:	0629d783          	lhu	a5,98(s3)
    80006014:	37fd                	addiw	a5,a5,-1
    80006016:	06f99123          	sh	a5,98(s3)
    iupdate(dp);
    8000601a:	854e                	mv	a0,s3
    8000601c:	ffffe097          	auipc	ra,0xffffe
    80006020:	e7c080e7          	jalr	-388(ra) # 80003e98 <iupdate>
    80006024:	b781                	j	80005f64 <sys_unlink+0xe2>
    return -1;
    80006026:	557d                	li	a0,-1
    80006028:	a00d                	j	8000604a <sys_unlink+0x1c8>
    iunlockput(ip);
    8000602a:	8526                	mv	a0,s1
    8000602c:	ffffe097          	auipc	ra,0xffffe
    80006030:	178080e7          	jalr	376(ra) # 800041a4 <iunlockput>
  iunlockput(dp);
    80006034:	854e                	mv	a0,s3
    80006036:	ffffe097          	auipc	ra,0xffffe
    8000603a:	16e080e7          	jalr	366(ra) # 800041a4 <iunlockput>
  end_op(ROOTDEV);
    8000603e:	4501                	li	a0,0
    80006040:	fffff097          	auipc	ra,0xfffff
    80006044:	9aa080e7          	jalr	-1622(ra) # 800049ea <end_op>
  return -1;
    80006048:	557d                	li	a0,-1
}
    8000604a:	70ae                	ld	ra,232(sp)
    8000604c:	740e                	ld	s0,224(sp)
    8000604e:	64ee                	ld	s1,216(sp)
    80006050:	694e                	ld	s2,208(sp)
    80006052:	69ae                	ld	s3,200(sp)
    80006054:	616d                	addi	sp,sp,240
    80006056:	8082                	ret

0000000080006058 <sys_open>:

uint64
sys_open(void)
{
    80006058:	7131                	addi	sp,sp,-192
    8000605a:	fd06                	sd	ra,184(sp)
    8000605c:	f922                	sd	s0,176(sp)
    8000605e:	f526                	sd	s1,168(sp)
    80006060:	f14a                	sd	s2,160(sp)
    80006062:	ed4e                	sd	s3,152(sp)
    80006064:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006066:	08000613          	li	a2,128
    8000606a:	f5040593          	addi	a1,s0,-176
    8000606e:	4501                	li	a0,0
    80006070:	ffffd097          	auipc	ra,0xffffd
    80006074:	366080e7          	jalr	870(ra) # 800033d6 <argstr>
    return -1;
    80006078:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000607a:	0a054963          	bltz	a0,8000612c <sys_open+0xd4>
    8000607e:	f4c40593          	addi	a1,s0,-180
    80006082:	4505                	li	a0,1
    80006084:	ffffd097          	auipc	ra,0xffffd
    80006088:	30e080e7          	jalr	782(ra) # 80003392 <argint>
    8000608c:	0a054063          	bltz	a0,8000612c <sys_open+0xd4>

  begin_op(ROOTDEV);
    80006090:	4501                	li	a0,0
    80006092:	fffff097          	auipc	ra,0xfffff
    80006096:	8ac080e7          	jalr	-1876(ra) # 8000493e <begin_op>

  if(omode & O_CREATE){
    8000609a:	f4c42783          	lw	a5,-180(s0)
    8000609e:	2007f793          	andi	a5,a5,512
    800060a2:	c3dd                	beqz	a5,80006148 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    800060a4:	4681                	li	a3,0
    800060a6:	4601                	li	a2,0
    800060a8:	4589                	li	a1,2
    800060aa:	f5040513          	addi	a0,s0,-176
    800060ae:	00000097          	auipc	ra,0x0
    800060b2:	962080e7          	jalr	-1694(ra) # 80005a10 <create>
    800060b6:	892a                	mv	s2,a0
    if(ip == 0){
    800060b8:	c151                	beqz	a0,8000613c <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800060ba:	05c91703          	lh	a4,92(s2)
    800060be:	478d                	li	a5,3
    800060c0:	00f71763          	bne	a4,a5,800060ce <sys_open+0x76>
    800060c4:	05e95703          	lhu	a4,94(s2)
    800060c8:	47a5                	li	a5,9
    800060ca:	0ce7e663          	bltu	a5,a4,80006196 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	d5c080e7          	jalr	-676(ra) # 80004e2a <filealloc>
    800060d6:	89aa                	mv	s3,a0
    800060d8:	c97d                	beqz	a0,800061ce <sys_open+0x176>
    800060da:	00000097          	auipc	ra,0x0
    800060de:	8ee080e7          	jalr	-1810(ra) # 800059c8 <fdalloc>
    800060e2:	84aa                	mv	s1,a0
    800060e4:	0e054063          	bltz	a0,800061c4 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    800060e8:	05c91703          	lh	a4,92(s2)
    800060ec:	478d                	li	a5,3
    800060ee:	0cf70063          	beq	a4,a5,800061ae <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    800060f2:	4789                	li	a5,2
    800060f4:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    800060f8:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    800060fc:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80006100:	f4c42783          	lw	a5,-180(s0)
    80006104:	0017c713          	xori	a4,a5,1
    80006108:	8b05                	andi	a4,a4,1
    8000610a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000610e:	8b8d                	andi	a5,a5,3
    80006110:	00f037b3          	snez	a5,a5
    80006114:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80006118:	854a                	mv	a0,s2
    8000611a:	ffffe097          	auipc	ra,0xffffe
    8000611e:	f0e080e7          	jalr	-242(ra) # 80004028 <iunlock>
  end_op(ROOTDEV);
    80006122:	4501                	li	a0,0
    80006124:	fffff097          	auipc	ra,0xfffff
    80006128:	8c6080e7          	jalr	-1850(ra) # 800049ea <end_op>

  return fd;
}
    8000612c:	8526                	mv	a0,s1
    8000612e:	70ea                	ld	ra,184(sp)
    80006130:	744a                	ld	s0,176(sp)
    80006132:	74aa                	ld	s1,168(sp)
    80006134:	790a                	ld	s2,160(sp)
    80006136:	69ea                	ld	s3,152(sp)
    80006138:	6129                	addi	sp,sp,192
    8000613a:	8082                	ret
      end_op(ROOTDEV);
    8000613c:	4501                	li	a0,0
    8000613e:	fffff097          	auipc	ra,0xfffff
    80006142:	8ac080e7          	jalr	-1876(ra) # 800049ea <end_op>
      return -1;
    80006146:	b7dd                	j	8000612c <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80006148:	f5040513          	addi	a0,s0,-176
    8000614c:	ffffe097          	auipc	ra,0xffffe
    80006150:	5ac080e7          	jalr	1452(ra) # 800046f8 <namei>
    80006154:	892a                	mv	s2,a0
    80006156:	c90d                	beqz	a0,80006188 <sys_open+0x130>
    ilock(ip);
    80006158:	ffffe097          	auipc	ra,0xffffe
    8000615c:	e0c080e7          	jalr	-500(ra) # 80003f64 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006160:	05c91703          	lh	a4,92(s2)
    80006164:	4785                	li	a5,1
    80006166:	f4f71ae3          	bne	a4,a5,800060ba <sys_open+0x62>
    8000616a:	f4c42783          	lw	a5,-180(s0)
    8000616e:	d3a5                	beqz	a5,800060ce <sys_open+0x76>
      iunlockput(ip);
    80006170:	854a                	mv	a0,s2
    80006172:	ffffe097          	auipc	ra,0xffffe
    80006176:	032080e7          	jalr	50(ra) # 800041a4 <iunlockput>
      end_op(ROOTDEV);
    8000617a:	4501                	li	a0,0
    8000617c:	fffff097          	auipc	ra,0xfffff
    80006180:	86e080e7          	jalr	-1938(ra) # 800049ea <end_op>
      return -1;
    80006184:	54fd                	li	s1,-1
    80006186:	b75d                	j	8000612c <sys_open+0xd4>
      end_op(ROOTDEV);
    80006188:	4501                	li	a0,0
    8000618a:	fffff097          	auipc	ra,0xfffff
    8000618e:	860080e7          	jalr	-1952(ra) # 800049ea <end_op>
      return -1;
    80006192:	54fd                	li	s1,-1
    80006194:	bf61                	j	8000612c <sys_open+0xd4>
    iunlockput(ip);
    80006196:	854a                	mv	a0,s2
    80006198:	ffffe097          	auipc	ra,0xffffe
    8000619c:	00c080e7          	jalr	12(ra) # 800041a4 <iunlockput>
    end_op(ROOTDEV);
    800061a0:	4501                	li	a0,0
    800061a2:	fffff097          	auipc	ra,0xfffff
    800061a6:	848080e7          	jalr	-1976(ra) # 800049ea <end_op>
    return -1;
    800061aa:	54fd                	li	s1,-1
    800061ac:	b741                	j	8000612c <sys_open+0xd4>
    f->type = FD_DEVICE;
    800061ae:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800061b2:	05e91783          	lh	a5,94(s2)
    800061b6:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    800061ba:	06091783          	lh	a5,96(s2)
    800061be:	02f99323          	sh	a5,38(s3)
    800061c2:	bf1d                	j	800060f8 <sys_open+0xa0>
      fileclose(f);
    800061c4:	854e                	mv	a0,s3
    800061c6:	fffff097          	auipc	ra,0xfffff
    800061ca:	d34080e7          	jalr	-716(ra) # 80004efa <fileclose>
    iunlockput(ip);
    800061ce:	854a                	mv	a0,s2
    800061d0:	ffffe097          	auipc	ra,0xffffe
    800061d4:	fd4080e7          	jalr	-44(ra) # 800041a4 <iunlockput>
    end_op(ROOTDEV);
    800061d8:	4501                	li	a0,0
    800061da:	fffff097          	auipc	ra,0xfffff
    800061de:	810080e7          	jalr	-2032(ra) # 800049ea <end_op>
    return -1;
    800061e2:	54fd                	li	s1,-1
    800061e4:	b7a1                	j	8000612c <sys_open+0xd4>

00000000800061e6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800061e6:	7175                	addi	sp,sp,-144
    800061e8:	e506                	sd	ra,136(sp)
    800061ea:	e122                	sd	s0,128(sp)
    800061ec:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    800061ee:	4501                	li	a0,0
    800061f0:	ffffe097          	auipc	ra,0xffffe
    800061f4:	74e080e7          	jalr	1870(ra) # 8000493e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800061f8:	08000613          	li	a2,128
    800061fc:	f7040593          	addi	a1,s0,-144
    80006200:	4501                	li	a0,0
    80006202:	ffffd097          	auipc	ra,0xffffd
    80006206:	1d4080e7          	jalr	468(ra) # 800033d6 <argstr>
    8000620a:	02054a63          	bltz	a0,8000623e <sys_mkdir+0x58>
    8000620e:	4681                	li	a3,0
    80006210:	4601                	li	a2,0
    80006212:	4585                	li	a1,1
    80006214:	f7040513          	addi	a0,s0,-144
    80006218:	fffff097          	auipc	ra,0xfffff
    8000621c:	7f8080e7          	jalr	2040(ra) # 80005a10 <create>
    80006220:	cd19                	beqz	a0,8000623e <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80006222:	ffffe097          	auipc	ra,0xffffe
    80006226:	f82080e7          	jalr	-126(ra) # 800041a4 <iunlockput>
  end_op(ROOTDEV);
    8000622a:	4501                	li	a0,0
    8000622c:	ffffe097          	auipc	ra,0xffffe
    80006230:	7be080e7          	jalr	1982(ra) # 800049ea <end_op>
  return 0;
    80006234:	4501                	li	a0,0
}
    80006236:	60aa                	ld	ra,136(sp)
    80006238:	640a                	ld	s0,128(sp)
    8000623a:	6149                	addi	sp,sp,144
    8000623c:	8082                	ret
    end_op(ROOTDEV);
    8000623e:	4501                	li	a0,0
    80006240:	ffffe097          	auipc	ra,0xffffe
    80006244:	7aa080e7          	jalr	1962(ra) # 800049ea <end_op>
    return -1;
    80006248:	557d                	li	a0,-1
    8000624a:	b7f5                	j	80006236 <sys_mkdir+0x50>

000000008000624c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000624c:	7135                	addi	sp,sp,-160
    8000624e:	ed06                	sd	ra,152(sp)
    80006250:	e922                	sd	s0,144(sp)
    80006252:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80006254:	4501                	li	a0,0
    80006256:	ffffe097          	auipc	ra,0xffffe
    8000625a:	6e8080e7          	jalr	1768(ra) # 8000493e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000625e:	08000613          	li	a2,128
    80006262:	f7040593          	addi	a1,s0,-144
    80006266:	4501                	li	a0,0
    80006268:	ffffd097          	auipc	ra,0xffffd
    8000626c:	16e080e7          	jalr	366(ra) # 800033d6 <argstr>
    80006270:	04054b63          	bltz	a0,800062c6 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80006274:	f6c40593          	addi	a1,s0,-148
    80006278:	4505                	li	a0,1
    8000627a:	ffffd097          	auipc	ra,0xffffd
    8000627e:	118080e7          	jalr	280(ra) # 80003392 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006282:	04054263          	bltz	a0,800062c6 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80006286:	f6840593          	addi	a1,s0,-152
    8000628a:	4509                	li	a0,2
    8000628c:	ffffd097          	auipc	ra,0xffffd
    80006290:	106080e7          	jalr	262(ra) # 80003392 <argint>
     argint(1, &major) < 0 ||
    80006294:	02054963          	bltz	a0,800062c6 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006298:	f6841683          	lh	a3,-152(s0)
    8000629c:	f6c41603          	lh	a2,-148(s0)
    800062a0:	458d                	li	a1,3
    800062a2:	f7040513          	addi	a0,s0,-144
    800062a6:	fffff097          	auipc	ra,0xfffff
    800062aa:	76a080e7          	jalr	1898(ra) # 80005a10 <create>
     argint(2, &minor) < 0 ||
    800062ae:	cd01                	beqz	a0,800062c6 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    800062b0:	ffffe097          	auipc	ra,0xffffe
    800062b4:	ef4080e7          	jalr	-268(ra) # 800041a4 <iunlockput>
  end_op(ROOTDEV);
    800062b8:	4501                	li	a0,0
    800062ba:	ffffe097          	auipc	ra,0xffffe
    800062be:	730080e7          	jalr	1840(ra) # 800049ea <end_op>
  return 0;
    800062c2:	4501                	li	a0,0
    800062c4:	a039                	j	800062d2 <sys_mknod+0x86>
    end_op(ROOTDEV);
    800062c6:	4501                	li	a0,0
    800062c8:	ffffe097          	auipc	ra,0xffffe
    800062cc:	722080e7          	jalr	1826(ra) # 800049ea <end_op>
    return -1;
    800062d0:	557d                	li	a0,-1
}
    800062d2:	60ea                	ld	ra,152(sp)
    800062d4:	644a                	ld	s0,144(sp)
    800062d6:	610d                	addi	sp,sp,160
    800062d8:	8082                	ret

00000000800062da <sys_chdir>:

uint64
sys_chdir(void)
{
    800062da:	7135                	addi	sp,sp,-160
    800062dc:	ed06                	sd	ra,152(sp)
    800062de:	e922                	sd	s0,144(sp)
    800062e0:	e526                	sd	s1,136(sp)
    800062e2:	e14a                	sd	s2,128(sp)
    800062e4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800062e6:	ffffc097          	auipc	ra,0xffffc
    800062ea:	d5a080e7          	jalr	-678(ra) # 80002040 <myproc>
    800062ee:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    800062f0:	4501                	li	a0,0
    800062f2:	ffffe097          	auipc	ra,0xffffe
    800062f6:	64c080e7          	jalr	1612(ra) # 8000493e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800062fa:	08000613          	li	a2,128
    800062fe:	f6040593          	addi	a1,s0,-160
    80006302:	4501                	li	a0,0
    80006304:	ffffd097          	auipc	ra,0xffffd
    80006308:	0d2080e7          	jalr	210(ra) # 800033d6 <argstr>
    8000630c:	04054c63          	bltz	a0,80006364 <sys_chdir+0x8a>
    80006310:	f6040513          	addi	a0,s0,-160
    80006314:	ffffe097          	auipc	ra,0xffffe
    80006318:	3e4080e7          	jalr	996(ra) # 800046f8 <namei>
    8000631c:	84aa                	mv	s1,a0
    8000631e:	c139                	beqz	a0,80006364 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80006320:	ffffe097          	auipc	ra,0xffffe
    80006324:	c44080e7          	jalr	-956(ra) # 80003f64 <ilock>
  if(ip->type != T_DIR){
    80006328:	05c49703          	lh	a4,92(s1)
    8000632c:	4785                	li	a5,1
    8000632e:	04f71263          	bne	a4,a5,80006372 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80006332:	8526                	mv	a0,s1
    80006334:	ffffe097          	auipc	ra,0xffffe
    80006338:	cf4080e7          	jalr	-780(ra) # 80004028 <iunlock>
  iput(p->cwd);
    8000633c:	16893503          	ld	a0,360(s2)
    80006340:	ffffe097          	auipc	ra,0xffffe
    80006344:	d34080e7          	jalr	-716(ra) # 80004074 <iput>
  end_op(ROOTDEV);
    80006348:	4501                	li	a0,0
    8000634a:	ffffe097          	auipc	ra,0xffffe
    8000634e:	6a0080e7          	jalr	1696(ra) # 800049ea <end_op>
  p->cwd = ip;
    80006352:	16993423          	sd	s1,360(s2)
  return 0;
    80006356:	4501                	li	a0,0
}
    80006358:	60ea                	ld	ra,152(sp)
    8000635a:	644a                	ld	s0,144(sp)
    8000635c:	64aa                	ld	s1,136(sp)
    8000635e:	690a                	ld	s2,128(sp)
    80006360:	610d                	addi	sp,sp,160
    80006362:	8082                	ret
    end_op(ROOTDEV);
    80006364:	4501                	li	a0,0
    80006366:	ffffe097          	auipc	ra,0xffffe
    8000636a:	684080e7          	jalr	1668(ra) # 800049ea <end_op>
    return -1;
    8000636e:	557d                	li	a0,-1
    80006370:	b7e5                	j	80006358 <sys_chdir+0x7e>
    iunlockput(ip);
    80006372:	8526                	mv	a0,s1
    80006374:	ffffe097          	auipc	ra,0xffffe
    80006378:	e30080e7          	jalr	-464(ra) # 800041a4 <iunlockput>
    end_op(ROOTDEV);
    8000637c:	4501                	li	a0,0
    8000637e:	ffffe097          	auipc	ra,0xffffe
    80006382:	66c080e7          	jalr	1644(ra) # 800049ea <end_op>
    return -1;
    80006386:	557d                	li	a0,-1
    80006388:	bfc1                	j	80006358 <sys_chdir+0x7e>

000000008000638a <sys_exec>:

uint64
sys_exec(void)
{
    8000638a:	7145                	addi	sp,sp,-464
    8000638c:	e786                	sd	ra,456(sp)
    8000638e:	e3a2                	sd	s0,448(sp)
    80006390:	ff26                	sd	s1,440(sp)
    80006392:	fb4a                	sd	s2,432(sp)
    80006394:	f74e                	sd	s3,424(sp)
    80006396:	f352                	sd	s4,416(sp)
    80006398:	ef56                	sd	s5,408(sp)
    8000639a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000639c:	08000613          	li	a2,128
    800063a0:	f4040593          	addi	a1,s0,-192
    800063a4:	4501                	li	a0,0
    800063a6:	ffffd097          	auipc	ra,0xffffd
    800063aa:	030080e7          	jalr	48(ra) # 800033d6 <argstr>
    800063ae:	10054763          	bltz	a0,800064bc <sys_exec+0x132>
    800063b2:	e3840593          	addi	a1,s0,-456
    800063b6:	4505                	li	a0,1
    800063b8:	ffffd097          	auipc	ra,0xffffd
    800063bc:	ffc080e7          	jalr	-4(ra) # 800033b4 <argaddr>
    800063c0:	10054863          	bltz	a0,800064d0 <sys_exec+0x146>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    800063c4:	e4040913          	addi	s2,s0,-448
    800063c8:	10000613          	li	a2,256
    800063cc:	4581                	li	a1,0
    800063ce:	854a                	mv	a0,s2
    800063d0:	ffffb097          	auipc	ra,0xffffb
    800063d4:	d5e080e7          	jalr	-674(ra) # 8000112e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800063d8:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    800063da:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    800063dc:	02000a93          	li	s5,32
    800063e0:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800063e4:	00349513          	slli	a0,s1,0x3
    800063e8:	e3040593          	addi	a1,s0,-464
    800063ec:	e3843783          	ld	a5,-456(s0)
    800063f0:	953e                	add	a0,a0,a5
    800063f2:	ffffd097          	auipc	ra,0xffffd
    800063f6:	f04080e7          	jalr	-252(ra) # 800032f6 <fetchaddr>
    800063fa:	02054a63          	bltz	a0,8000642e <sys_exec+0xa4>
      goto bad;
    }
    if(uarg == 0){
    800063fe:	e3043783          	ld	a5,-464(s0)
    80006402:	cfa1                	beqz	a5,8000645a <sys_exec+0xd0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006404:	ffffa097          	auipc	ra,0xffffa
    80006408:	72e080e7          	jalr	1838(ra) # 80000b32 <kalloc>
    8000640c:	85aa                	mv	a1,a0
    8000640e:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80006412:	c949                	beqz	a0,800064a4 <sys_exec+0x11a>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80006414:	6605                	lui	a2,0x1
    80006416:	e3043503          	ld	a0,-464(s0)
    8000641a:	ffffd097          	auipc	ra,0xffffd
    8000641e:	f30080e7          	jalr	-208(ra) # 8000334a <fetchstr>
    80006422:	00054663          	bltz	a0,8000642e <sys_exec+0xa4>
    if(i >= NELEM(argv)){
    80006426:	0485                	addi	s1,s1,1
    80006428:	0921                	addi	s2,s2,8
    8000642a:	fb549be3          	bne	s1,s5,800063e0 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000642e:	e4043503          	ld	a0,-448(s0)
    80006432:	c149                	beqz	a0,800064b4 <sys_exec+0x12a>
    kfree(argv[i]);
    80006434:	ffffa097          	auipc	ra,0xffffa
    80006438:	6e6080e7          	jalr	1766(ra) # 80000b1a <kfree>
    8000643c:	e4840493          	addi	s1,s0,-440
    80006440:	10098993          	addi	s3,s3,256
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006444:	6088                	ld	a0,0(s1)
    80006446:	c92d                	beqz	a0,800064b8 <sys_exec+0x12e>
    kfree(argv[i]);
    80006448:	ffffa097          	auipc	ra,0xffffa
    8000644c:	6d2080e7          	jalr	1746(ra) # 80000b1a <kfree>
    80006450:	04a1                	addi	s1,s1,8
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006452:	ff3499e3          	bne	s1,s3,80006444 <sys_exec+0xba>
  return -1;
    80006456:	557d                	li	a0,-1
    80006458:	a09d                	j	800064be <sys_exec+0x134>
      argv[i] = 0;
    8000645a:	0a0e                	slli	s4,s4,0x3
    8000645c:	fc040793          	addi	a5,s0,-64
    80006460:	9a3e                	add	s4,s4,a5
    80006462:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80006466:	e4040593          	addi	a1,s0,-448
    8000646a:	f4040513          	addi	a0,s0,-192
    8000646e:	fffff097          	auipc	ra,0xfffff
    80006472:	150080e7          	jalr	336(ra) # 800055be <exec>
    80006476:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006478:	e4043503          	ld	a0,-448(s0)
    8000647c:	c115                	beqz	a0,800064a0 <sys_exec+0x116>
    kfree(argv[i]);
    8000647e:	ffffa097          	auipc	ra,0xffffa
    80006482:	69c080e7          	jalr	1692(ra) # 80000b1a <kfree>
    80006486:	e4840493          	addi	s1,s0,-440
    8000648a:	10098993          	addi	s3,s3,256
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000648e:	6088                	ld	a0,0(s1)
    80006490:	c901                	beqz	a0,800064a0 <sys_exec+0x116>
    kfree(argv[i]);
    80006492:	ffffa097          	auipc	ra,0xffffa
    80006496:	688080e7          	jalr	1672(ra) # 80000b1a <kfree>
    8000649a:	04a1                	addi	s1,s1,8
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000649c:	ff3499e3          	bne	s1,s3,8000648e <sys_exec+0x104>
  return ret;
    800064a0:	854a                	mv	a0,s2
    800064a2:	a831                	j	800064be <sys_exec+0x134>
      panic("sys_exec kalloc");
    800064a4:	00003517          	auipc	a0,0x3
    800064a8:	82450513          	addi	a0,a0,-2012 # 80008cc8 <userret+0xc38>
    800064ac:	ffffa097          	auipc	ra,0xffffa
    800064b0:	2d8080e7          	jalr	728(ra) # 80000784 <panic>
  return -1;
    800064b4:	557d                	li	a0,-1
    800064b6:	a021                	j	800064be <sys_exec+0x134>
    800064b8:	557d                	li	a0,-1
    800064ba:	a011                	j	800064be <sys_exec+0x134>
    return -1;
    800064bc:	557d                	li	a0,-1
}
    800064be:	60be                	ld	ra,456(sp)
    800064c0:	641e                	ld	s0,448(sp)
    800064c2:	74fa                	ld	s1,440(sp)
    800064c4:	795a                	ld	s2,432(sp)
    800064c6:	79ba                	ld	s3,424(sp)
    800064c8:	7a1a                	ld	s4,416(sp)
    800064ca:	6afa                	ld	s5,408(sp)
    800064cc:	6179                	addi	sp,sp,464
    800064ce:	8082                	ret
    return -1;
    800064d0:	557d                	li	a0,-1
    800064d2:	b7f5                	j	800064be <sys_exec+0x134>

00000000800064d4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800064d4:	7139                	addi	sp,sp,-64
    800064d6:	fc06                	sd	ra,56(sp)
    800064d8:	f822                	sd	s0,48(sp)
    800064da:	f426                	sd	s1,40(sp)
    800064dc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800064de:	ffffc097          	auipc	ra,0xffffc
    800064e2:	b62080e7          	jalr	-1182(ra) # 80002040 <myproc>
    800064e6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800064e8:	fd840593          	addi	a1,s0,-40
    800064ec:	4501                	li	a0,0
    800064ee:	ffffd097          	auipc	ra,0xffffd
    800064f2:	ec6080e7          	jalr	-314(ra) # 800033b4 <argaddr>
    return -1;
    800064f6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800064f8:	0c054f63          	bltz	a0,800065d6 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    800064fc:	fc840593          	addi	a1,s0,-56
    80006500:	fd040513          	addi	a0,s0,-48
    80006504:	fffff097          	auipc	ra,0xfffff
    80006508:	d5a080e7          	jalr	-678(ra) # 8000525e <pipealloc>
    return -1;
    8000650c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000650e:	0c054463          	bltz	a0,800065d6 <sys_pipe+0x102>
  fd0 = -1;
    80006512:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006516:	fd043503          	ld	a0,-48(s0)
    8000651a:	fffff097          	auipc	ra,0xfffff
    8000651e:	4ae080e7          	jalr	1198(ra) # 800059c8 <fdalloc>
    80006522:	fca42223          	sw	a0,-60(s0)
    80006526:	08054b63          	bltz	a0,800065bc <sys_pipe+0xe8>
    8000652a:	fc843503          	ld	a0,-56(s0)
    8000652e:	fffff097          	auipc	ra,0xfffff
    80006532:	49a080e7          	jalr	1178(ra) # 800059c8 <fdalloc>
    80006536:	fca42023          	sw	a0,-64(s0)
    8000653a:	06054863          	bltz	a0,800065aa <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000653e:	4691                	li	a3,4
    80006540:	fc440613          	addi	a2,s0,-60
    80006544:	fd843583          	ld	a1,-40(s0)
    80006548:	74a8                	ld	a0,104(s1)
    8000654a:	ffffb097          	auipc	ra,0xffffb
    8000654e:	6d4080e7          	jalr	1748(ra) # 80001c1e <copyout>
    80006552:	02054063          	bltz	a0,80006572 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006556:	4691                	li	a3,4
    80006558:	fc040613          	addi	a2,s0,-64
    8000655c:	fd843583          	ld	a1,-40(s0)
    80006560:	0591                	addi	a1,a1,4
    80006562:	74a8                	ld	a0,104(s1)
    80006564:	ffffb097          	auipc	ra,0xffffb
    80006568:	6ba080e7          	jalr	1722(ra) # 80001c1e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000656c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000656e:	06055463          	bgez	a0,800065d6 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80006572:	fc442783          	lw	a5,-60(s0)
    80006576:	07f1                	addi	a5,a5,28
    80006578:	078e                	slli	a5,a5,0x3
    8000657a:	97a6                	add	a5,a5,s1
    8000657c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006580:	fc042783          	lw	a5,-64(s0)
    80006584:	07f1                	addi	a5,a5,28
    80006586:	078e                	slli	a5,a5,0x3
    80006588:	94be                	add	s1,s1,a5
    8000658a:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000658e:	fd043503          	ld	a0,-48(s0)
    80006592:	fffff097          	auipc	ra,0xfffff
    80006596:	968080e7          	jalr	-1688(ra) # 80004efa <fileclose>
    fileclose(wf);
    8000659a:	fc843503          	ld	a0,-56(s0)
    8000659e:	fffff097          	auipc	ra,0xfffff
    800065a2:	95c080e7          	jalr	-1700(ra) # 80004efa <fileclose>
    return -1;
    800065a6:	57fd                	li	a5,-1
    800065a8:	a03d                	j	800065d6 <sys_pipe+0x102>
    if(fd0 >= 0)
    800065aa:	fc442783          	lw	a5,-60(s0)
    800065ae:	0007c763          	bltz	a5,800065bc <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    800065b2:	07f1                	addi	a5,a5,28
    800065b4:	078e                	slli	a5,a5,0x3
    800065b6:	94be                	add	s1,s1,a5
    800065b8:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800065bc:	fd043503          	ld	a0,-48(s0)
    800065c0:	fffff097          	auipc	ra,0xfffff
    800065c4:	93a080e7          	jalr	-1734(ra) # 80004efa <fileclose>
    fileclose(wf);
    800065c8:	fc843503          	ld	a0,-56(s0)
    800065cc:	fffff097          	auipc	ra,0xfffff
    800065d0:	92e080e7          	jalr	-1746(ra) # 80004efa <fileclose>
    return -1;
    800065d4:	57fd                	li	a5,-1
}
    800065d6:	853e                	mv	a0,a5
    800065d8:	70e2                	ld	ra,56(sp)
    800065da:	7442                	ld	s0,48(sp)
    800065dc:	74a2                	ld	s1,40(sp)
    800065de:	6121                	addi	sp,sp,64
    800065e0:	8082                	ret

00000000800065e2 <sys_create_mutex>:

uint64
sys_create_mutex(void)
{
    800065e2:	1141                	addi	sp,sp,-16
    800065e4:	e422                	sd	s0,8(sp)
    800065e6:	0800                	addi	s0,sp,16
  return -1;
}
    800065e8:	557d                	li	a0,-1
    800065ea:	6422                	ld	s0,8(sp)
    800065ec:	0141                	addi	sp,sp,16
    800065ee:	8082                	ret

00000000800065f0 <sys_acquire_mutex>:

uint64
sys_acquire_mutex(void)
{
    800065f0:	1141                	addi	sp,sp,-16
    800065f2:	e422                	sd	s0,8(sp)
    800065f4:	0800                	addi	s0,sp,16
  return 0;
}
    800065f6:	4501                	li	a0,0
    800065f8:	6422                	ld	s0,8(sp)
    800065fa:	0141                	addi	sp,sp,16
    800065fc:	8082                	ret

00000000800065fe <sys_release_mutex>:

uint64
sys_release_mutex(void)
{
    800065fe:	1141                	addi	sp,sp,-16
    80006600:	e422                	sd	s0,8(sp)
    80006602:	0800                	addi	s0,sp,16

  return 0;
}
    80006604:	4501                	li	a0,0
    80006606:	6422                	ld	s0,8(sp)
    80006608:	0141                	addi	sp,sp,16
    8000660a:	8082                	ret
    8000660c:	0000                	unimp
	...

0000000080006610 <kernelvec>:
    80006610:	7111                	addi	sp,sp,-256
    80006612:	e006                	sd	ra,0(sp)
    80006614:	e40a                	sd	sp,8(sp)
    80006616:	e80e                	sd	gp,16(sp)
    80006618:	ec12                	sd	tp,24(sp)
    8000661a:	f016                	sd	t0,32(sp)
    8000661c:	f41a                	sd	t1,40(sp)
    8000661e:	f81e                	sd	t2,48(sp)
    80006620:	fc22                	sd	s0,56(sp)
    80006622:	e0a6                	sd	s1,64(sp)
    80006624:	e4aa                	sd	a0,72(sp)
    80006626:	e8ae                	sd	a1,80(sp)
    80006628:	ecb2                	sd	a2,88(sp)
    8000662a:	f0b6                	sd	a3,96(sp)
    8000662c:	f4ba                	sd	a4,104(sp)
    8000662e:	f8be                	sd	a5,112(sp)
    80006630:	fcc2                	sd	a6,120(sp)
    80006632:	e146                	sd	a7,128(sp)
    80006634:	e54a                	sd	s2,136(sp)
    80006636:	e94e                	sd	s3,144(sp)
    80006638:	ed52                	sd	s4,152(sp)
    8000663a:	f156                	sd	s5,160(sp)
    8000663c:	f55a                	sd	s6,168(sp)
    8000663e:	f95e                	sd	s7,176(sp)
    80006640:	fd62                	sd	s8,184(sp)
    80006642:	e1e6                	sd	s9,192(sp)
    80006644:	e5ea                	sd	s10,200(sp)
    80006646:	e9ee                	sd	s11,208(sp)
    80006648:	edf2                	sd	t3,216(sp)
    8000664a:	f1f6                	sd	t4,224(sp)
    8000664c:	f5fa                	sd	t5,232(sp)
    8000664e:	f9fe                	sd	t6,240(sp)
    80006650:	b63fc0ef          	jal	ra,800031b2 <kerneltrap>
    80006654:	6082                	ld	ra,0(sp)
    80006656:	6122                	ld	sp,8(sp)
    80006658:	61c2                	ld	gp,16(sp)
    8000665a:	7282                	ld	t0,32(sp)
    8000665c:	7322                	ld	t1,40(sp)
    8000665e:	73c2                	ld	t2,48(sp)
    80006660:	7462                	ld	s0,56(sp)
    80006662:	6486                	ld	s1,64(sp)
    80006664:	6526                	ld	a0,72(sp)
    80006666:	65c6                	ld	a1,80(sp)
    80006668:	6666                	ld	a2,88(sp)
    8000666a:	7686                	ld	a3,96(sp)
    8000666c:	7726                	ld	a4,104(sp)
    8000666e:	77c6                	ld	a5,112(sp)
    80006670:	7866                	ld	a6,120(sp)
    80006672:	688a                	ld	a7,128(sp)
    80006674:	692a                	ld	s2,136(sp)
    80006676:	69ca                	ld	s3,144(sp)
    80006678:	6a6a                	ld	s4,152(sp)
    8000667a:	7a8a                	ld	s5,160(sp)
    8000667c:	7b2a                	ld	s6,168(sp)
    8000667e:	7bca                	ld	s7,176(sp)
    80006680:	7c6a                	ld	s8,184(sp)
    80006682:	6c8e                	ld	s9,192(sp)
    80006684:	6d2e                	ld	s10,200(sp)
    80006686:	6dce                	ld	s11,208(sp)
    80006688:	6e6e                	ld	t3,216(sp)
    8000668a:	7e8e                	ld	t4,224(sp)
    8000668c:	7f2e                	ld	t5,232(sp)
    8000668e:	7fce                	ld	t6,240(sp)
    80006690:	6111                	addi	sp,sp,256
    80006692:	10200073          	sret
    80006696:	00000013          	nop
    8000669a:	00000013          	nop
    8000669e:	0001                	nop

00000000800066a0 <timervec>:
    800066a0:	34051573          	csrrw	a0,mscratch,a0
    800066a4:	e10c                	sd	a1,0(a0)
    800066a6:	e510                	sd	a2,8(a0)
    800066a8:	e914                	sd	a3,16(a0)
    800066aa:	710c                	ld	a1,32(a0)
    800066ac:	7510                	ld	a2,40(a0)
    800066ae:	6194                	ld	a3,0(a1)
    800066b0:	96b2                	add	a3,a3,a2
    800066b2:	e194                	sd	a3,0(a1)
    800066b4:	4589                	li	a1,2
    800066b6:	14459073          	csrw	sip,a1
    800066ba:	6914                	ld	a3,16(a0)
    800066bc:	6510                	ld	a2,8(a0)
    800066be:	610c                	ld	a1,0(a0)
    800066c0:	34051573          	csrrw	a0,mscratch,a0
    800066c4:	30200073          	mret
	...

00000000800066ca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800066ca:	1141                	addi	sp,sp,-16
    800066cc:	e422                	sd	s0,8(sp)
    800066ce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800066d0:	0c0007b7          	lui	a5,0xc000
    800066d4:	4705                	li	a4,1
    800066d6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800066d8:	c3d8                	sw	a4,4(a5)
}
    800066da:	6422                	ld	s0,8(sp)
    800066dc:	0141                	addi	sp,sp,16
    800066de:	8082                	ret

00000000800066e0 <plicinithart>:

void
plicinithart(void)
{
    800066e0:	1141                	addi	sp,sp,-16
    800066e2:	e406                	sd	ra,8(sp)
    800066e4:	e022                	sd	s0,0(sp)
    800066e6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800066e8:	ffffc097          	auipc	ra,0xffffc
    800066ec:	92c080e7          	jalr	-1748(ra) # 80002014 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800066f0:	0085171b          	slliw	a4,a0,0x8
    800066f4:	0c0027b7          	lui	a5,0xc002
    800066f8:	97ba                	add	a5,a5,a4
    800066fa:	40200713          	li	a4,1026
    800066fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006702:	00d5151b          	slliw	a0,a0,0xd
    80006706:	0c2017b7          	lui	a5,0xc201
    8000670a:	953e                	add	a0,a0,a5
    8000670c:	00052023          	sw	zero,0(a0)
}
    80006710:	60a2                	ld	ra,8(sp)
    80006712:	6402                	ld	s0,0(sp)
    80006714:	0141                	addi	sp,sp,16
    80006716:	8082                	ret

0000000080006718 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006718:	1141                	addi	sp,sp,-16
    8000671a:	e406                	sd	ra,8(sp)
    8000671c:	e022                	sd	s0,0(sp)
    8000671e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006720:	ffffc097          	auipc	ra,0xffffc
    80006724:	8f4080e7          	jalr	-1804(ra) # 80002014 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006728:	00d5151b          	slliw	a0,a0,0xd
    8000672c:	0c2017b7          	lui	a5,0xc201
    80006730:	97aa                	add	a5,a5,a0
  return irq;
}
    80006732:	43c8                	lw	a0,4(a5)
    80006734:	60a2                	ld	ra,8(sp)
    80006736:	6402                	ld	s0,0(sp)
    80006738:	0141                	addi	sp,sp,16
    8000673a:	8082                	ret

000000008000673c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000673c:	1101                	addi	sp,sp,-32
    8000673e:	ec06                	sd	ra,24(sp)
    80006740:	e822                	sd	s0,16(sp)
    80006742:	e426                	sd	s1,8(sp)
    80006744:	1000                	addi	s0,sp,32
    80006746:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006748:	ffffc097          	auipc	ra,0xffffc
    8000674c:	8cc080e7          	jalr	-1844(ra) # 80002014 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006750:	00d5151b          	slliw	a0,a0,0xd
    80006754:	0c2017b7          	lui	a5,0xc201
    80006758:	97aa                	add	a5,a5,a0
    8000675a:	c3c4                	sw	s1,4(a5)
}
    8000675c:	60e2                	ld	ra,24(sp)
    8000675e:	6442                	ld	s0,16(sp)
    80006760:	64a2                	ld	s1,8(sp)
    80006762:	6105                	addi	sp,sp,32
    80006764:	8082                	ret

0000000080006766 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006766:	1141                	addi	sp,sp,-16
    80006768:	e406                	sd	ra,8(sp)
    8000676a:	e022                	sd	s0,0(sp)
    8000676c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000676e:	479d                	li	a5,7
    80006770:	06b7c863          	blt	a5,a1,800067e0 <free_desc+0x7a>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006774:	00151713          	slli	a4,a0,0x1
    80006778:	972a                	add	a4,a4,a0
    8000677a:	00c71693          	slli	a3,a4,0xc
    8000677e:	00022717          	auipc	a4,0x22
    80006782:	88270713          	addi	a4,a4,-1918 # 80028000 <disk>
    80006786:	9736                	add	a4,a4,a3
    80006788:	972e                	add	a4,a4,a1
    8000678a:	6789                	lui	a5,0x2
    8000678c:	973e                	add	a4,a4,a5
    8000678e:	01874783          	lbu	a5,24(a4)
    80006792:	efb9                	bnez	a5,800067f0 <free_desc+0x8a>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006794:	00022817          	auipc	a6,0x22
    80006798:	86c80813          	addi	a6,a6,-1940 # 80028000 <disk>
    8000679c:	00151713          	slli	a4,a0,0x1
    800067a0:	00a707b3          	add	a5,a4,a0
    800067a4:	07b2                	slli	a5,a5,0xc
    800067a6:	97c2                	add	a5,a5,a6
    800067a8:	6689                	lui	a3,0x2
    800067aa:	00f68633          	add	a2,a3,a5
    800067ae:	6210                	ld	a2,0(a2)
    800067b0:	00459893          	slli	a7,a1,0x4
    800067b4:	9646                	add	a2,a2,a7
    800067b6:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    800067ba:	97ae                	add	a5,a5,a1
    800067bc:	97b6                	add	a5,a5,a3
    800067be:	4605                	li	a2,1
    800067c0:	00c78c23          	sb	a2,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk[n].free[0]);
    800067c4:	972a                	add	a4,a4,a0
    800067c6:	0732                	slli	a4,a4,0xc
    800067c8:	06e1                	addi	a3,a3,24
    800067ca:	9736                	add	a4,a4,a3
    800067cc:	00e80533          	add	a0,a6,a4
    800067d0:	ffffc097          	auipc	ra,0xffffc
    800067d4:	2e8080e7          	jalr	744(ra) # 80002ab8 <wakeup>
}
    800067d8:	60a2                	ld	ra,8(sp)
    800067da:	6402                	ld	s0,0(sp)
    800067dc:	0141                	addi	sp,sp,16
    800067de:	8082                	ret
    panic("virtio_disk_intr 1");
    800067e0:	00002517          	auipc	a0,0x2
    800067e4:	4f850513          	addi	a0,a0,1272 # 80008cd8 <userret+0xc48>
    800067e8:	ffffa097          	auipc	ra,0xffffa
    800067ec:	f9c080e7          	jalr	-100(ra) # 80000784 <panic>
    panic("virtio_disk_intr 2");
    800067f0:	00002517          	auipc	a0,0x2
    800067f4:	50050513          	addi	a0,a0,1280 # 80008cf0 <userret+0xc60>
    800067f8:	ffffa097          	auipc	ra,0xffffa
    800067fc:	f8c080e7          	jalr	-116(ra) # 80000784 <panic>

0000000080006800 <virtio_disk_init>:
  __sync_synchronize();
    80006800:	0ff0000f          	fence
  if(disk[n].init)
    80006804:	00151793          	slli	a5,a0,0x1
    80006808:	97aa                	add	a5,a5,a0
    8000680a:	07b2                	slli	a5,a5,0xc
    8000680c:	00021717          	auipc	a4,0x21
    80006810:	7f470713          	addi	a4,a4,2036 # 80028000 <disk>
    80006814:	973e                	add	a4,a4,a5
    80006816:	6789                	lui	a5,0x2
    80006818:	97ba                	add	a5,a5,a4
    8000681a:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    8000681e:	c391                	beqz	a5,80006822 <virtio_disk_init+0x22>
    80006820:	8082                	ret
{
    80006822:	7139                	addi	sp,sp,-64
    80006824:	fc06                	sd	ra,56(sp)
    80006826:	f822                	sd	s0,48(sp)
    80006828:	f426                	sd	s1,40(sp)
    8000682a:	f04a                	sd	s2,32(sp)
    8000682c:	ec4e                	sd	s3,24(sp)
    8000682e:	e852                	sd	s4,16(sp)
    80006830:	e456                	sd	s5,8(sp)
    80006832:	0080                	addi	s0,sp,64
    80006834:	892a                	mv	s2,a0
  printf("virtio disk init %d\n", n);
    80006836:	85aa                	mv	a1,a0
    80006838:	00002517          	auipc	a0,0x2
    8000683c:	4d050513          	addi	a0,a0,1232 # 80008d08 <userret+0xc78>
    80006840:	ffffa097          	auipc	ra,0xffffa
    80006844:	15c080e7          	jalr	348(ra) # 8000099c <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80006848:	00191993          	slli	s3,s2,0x1
    8000684c:	99ca                	add	s3,s3,s2
    8000684e:	09b2                	slli	s3,s3,0xc
    80006850:	6789                	lui	a5,0x2
    80006852:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006856:	97ce                	add	a5,a5,s3
    80006858:	00002597          	auipc	a1,0x2
    8000685c:	4c858593          	addi	a1,a1,1224 # 80008d20 <userret+0xc90>
    80006860:	00021517          	auipc	a0,0x21
    80006864:	7a050513          	addi	a0,a0,1952 # 80028000 <disk>
    80006868:	953e                	add	a0,a0,a5
    8000686a:	ffffa097          	auipc	ra,0xffffa
    8000686e:	2e2080e7          	jalr	738(ra) # 80000b4c <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006872:	0019049b          	addiw	s1,s2,1
    80006876:	00c4949b          	slliw	s1,s1,0xc
    8000687a:	100007b7          	lui	a5,0x10000
    8000687e:	97a6                	add	a5,a5,s1
    80006880:	4398                	lw	a4,0(a5)
    80006882:	2701                	sext.w	a4,a4
    80006884:	747277b7          	lui	a5,0x74727
    80006888:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000688c:	12f71763          	bne	a4,a5,800069ba <virtio_disk_init+0x1ba>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006890:	100007b7          	lui	a5,0x10000
    80006894:	0791                	addi	a5,a5,4
    80006896:	97a6                	add	a5,a5,s1
    80006898:	439c                	lw	a5,0(a5)
    8000689a:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000689c:	4705                	li	a4,1
    8000689e:	10e79e63          	bne	a5,a4,800069ba <virtio_disk_init+0x1ba>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800068a2:	100007b7          	lui	a5,0x10000
    800068a6:	07a1                	addi	a5,a5,8
    800068a8:	97a6                	add	a5,a5,s1
    800068aa:	439c                	lw	a5,0(a5)
    800068ac:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800068ae:	4709                	li	a4,2
    800068b0:	10e79563          	bne	a5,a4,800069ba <virtio_disk_init+0x1ba>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800068b4:	100007b7          	lui	a5,0x10000
    800068b8:	07b1                	addi	a5,a5,12
    800068ba:	97a6                	add	a5,a5,s1
    800068bc:	4398                	lw	a4,0(a5)
    800068be:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800068c0:	554d47b7          	lui	a5,0x554d4
    800068c4:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800068c8:	0ef71963          	bne	a4,a5,800069ba <virtio_disk_init+0x1ba>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800068cc:	100007b7          	lui	a5,0x10000
    800068d0:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    800068d4:	96a6                	add	a3,a3,s1
    800068d6:	4705                	li	a4,1
    800068d8:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800068da:	470d                	li	a4,3
    800068dc:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800068de:	01078713          	addi	a4,a5,16
    800068e2:	9726                	add	a4,a4,s1
    800068e4:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800068e6:	02078613          	addi	a2,a5,32
    800068ea:	9626                	add	a2,a2,s1
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800068ec:	c7ffe737          	lui	a4,0xc7ffe
    800068f0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd06b3>
    800068f4:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800068f6:	2701                	sext.w	a4,a4
    800068f8:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800068fa:	472d                	li	a4,11
    800068fc:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800068fe:	473d                	li	a4,15
    80006900:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006902:	02878713          	addi	a4,a5,40
    80006906:	9726                	add	a4,a4,s1
    80006908:	6685                	lui	a3,0x1
    8000690a:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000690c:	03078713          	addi	a4,a5,48
    80006910:	9726                	add	a4,a4,s1
    80006912:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006916:	03478793          	addi	a5,a5,52
    8000691a:	97a6                	add	a5,a5,s1
    8000691c:	439c                	lw	a5,0(a5)
    8000691e:	2781                	sext.w	a5,a5
  if(max == 0)
    80006920:	c7cd                	beqz	a5,800069ca <virtio_disk_init+0x1ca>
  if(max < NUM)
    80006922:	471d                	li	a4,7
    80006924:	0af77b63          	bleu	a5,a4,800069da <virtio_disk_init+0x1da>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006928:	10000ab7          	lui	s5,0x10000
    8000692c:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006930:	97a6                	add	a5,a5,s1
    80006932:	4721                	li	a4,8
    80006934:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006936:	00021a17          	auipc	s4,0x21
    8000693a:	6caa0a13          	addi	s4,s4,1738 # 80028000 <disk>
    8000693e:	99d2                	add	s3,s3,s4
    80006940:	6609                	lui	a2,0x2
    80006942:	4581                	li	a1,0
    80006944:	854e                	mv	a0,s3
    80006946:	ffffa097          	auipc	ra,0xffffa
    8000694a:	7e8080e7          	jalr	2024(ra) # 8000112e <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    8000694e:	040a8a93          	addi	s5,s5,64
    80006952:	94d6                	add	s1,s1,s5
    80006954:	00c9d793          	srli	a5,s3,0xc
    80006958:	2781                	sext.w	a5,a5
    8000695a:	c09c                	sw	a5,0(s1)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    8000695c:	00191513          	slli	a0,s2,0x1
    80006960:	012507b3          	add	a5,a0,s2
    80006964:	07b2                	slli	a5,a5,0xc
    80006966:	97d2                	add	a5,a5,s4
    80006968:	6689                	lui	a3,0x2
    8000696a:	97b6                	add	a5,a5,a3
    8000696c:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006970:	08098713          	addi	a4,s3,128
    80006974:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    80006976:	6705                	lui	a4,0x1
    80006978:	99ba                	add	s3,s3,a4
    8000697a:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    8000697e:	4705                	li	a4,1
    80006980:	00e78c23          	sb	a4,24(a5)
    80006984:	00e78ca3          	sb	a4,25(a5)
    80006988:	00e78d23          	sb	a4,26(a5)
    8000698c:	00e78da3          	sb	a4,27(a5)
    80006990:	00e78e23          	sb	a4,28(a5)
    80006994:	00e78ea3          	sb	a4,29(a5)
    80006998:	00e78f23          	sb	a4,30(a5)
    8000699c:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    800069a0:	853e                	mv	a0,a5
    800069a2:	4785                	li	a5,1
    800069a4:	0af52423          	sw	a5,168(a0)
}
    800069a8:	70e2                	ld	ra,56(sp)
    800069aa:	7442                	ld	s0,48(sp)
    800069ac:	74a2                	ld	s1,40(sp)
    800069ae:	7902                	ld	s2,32(sp)
    800069b0:	69e2                	ld	s3,24(sp)
    800069b2:	6a42                	ld	s4,16(sp)
    800069b4:	6aa2                	ld	s5,8(sp)
    800069b6:	6121                	addi	sp,sp,64
    800069b8:	8082                	ret
    panic("could not find virtio disk");
    800069ba:	00002517          	auipc	a0,0x2
    800069be:	37650513          	addi	a0,a0,886 # 80008d30 <userret+0xca0>
    800069c2:	ffffa097          	auipc	ra,0xffffa
    800069c6:	dc2080e7          	jalr	-574(ra) # 80000784 <panic>
    panic("virtio disk has no queue 0");
    800069ca:	00002517          	auipc	a0,0x2
    800069ce:	38650513          	addi	a0,a0,902 # 80008d50 <userret+0xcc0>
    800069d2:	ffffa097          	auipc	ra,0xffffa
    800069d6:	db2080e7          	jalr	-590(ra) # 80000784 <panic>
    panic("virtio disk max queue too short");
    800069da:	00002517          	auipc	a0,0x2
    800069de:	39650513          	addi	a0,a0,918 # 80008d70 <userret+0xce0>
    800069e2:	ffffa097          	auipc	ra,0xffffa
    800069e6:	da2080e7          	jalr	-606(ra) # 80000784 <panic>

00000000800069ea <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    800069ea:	7175                	addi	sp,sp,-144
    800069ec:	e506                	sd	ra,136(sp)
    800069ee:	e122                	sd	s0,128(sp)
    800069f0:	fca6                	sd	s1,120(sp)
    800069f2:	f8ca                	sd	s2,112(sp)
    800069f4:	f4ce                	sd	s3,104(sp)
    800069f6:	f0d2                	sd	s4,96(sp)
    800069f8:	ecd6                	sd	s5,88(sp)
    800069fa:	e8da                	sd	s6,80(sp)
    800069fc:	e4de                	sd	s7,72(sp)
    800069fe:	e0e2                	sd	s8,64(sp)
    80006a00:	fc66                	sd	s9,56(sp)
    80006a02:	f86a                	sd	s10,48(sp)
    80006a04:	f46e                	sd	s11,40(sp)
    80006a06:	0900                	addi	s0,sp,144
    80006a08:	892a                	mv	s2,a0
    80006a0a:	8a2e                	mv	s4,a1
    80006a0c:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80006a0e:	00c5ad03          	lw	s10,12(a1)
    80006a12:	001d1d1b          	slliw	s10,s10,0x1
    80006a16:	1d02                	slli	s10,s10,0x20
    80006a18:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk[n].vdisk_lock);
    80006a1c:	00151493          	slli	s1,a0,0x1
    80006a20:	94aa                	add	s1,s1,a0
    80006a22:	04b2                	slli	s1,s1,0xc
    80006a24:	6a89                	lui	s5,0x2
    80006a26:	0b0a8993          	addi	s3,s5,176 # 20b0 <_entry-0x7fffdf50>
    80006a2a:	99a6                	add	s3,s3,s1
    80006a2c:	00021c17          	auipc	s8,0x21
    80006a30:	5d4c0c13          	addi	s8,s8,1492 # 80028000 <disk>
    80006a34:	99e2                	add	s3,s3,s8
    80006a36:	854e                	mv	a0,s3
    80006a38:	ffffa097          	auipc	ra,0xffffa
    80006a3c:	282080e7          	jalr	642(ra) # 80000cba <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006a40:	018a8b93          	addi	s7,s5,24
    80006a44:	9ba6                	add	s7,s7,s1
    80006a46:	9be2                	add	s7,s7,s8
    80006a48:	0ae5                	addi	s5,s5,25
    80006a4a:	94d6                	add	s1,s1,s5
    80006a4c:	01848ab3          	add	s5,s1,s8
    if(disk[n].free[i]){
    80006a50:	00191b13          	slli	s6,s2,0x1
    80006a54:	9b4a                	add	s6,s6,s2
    80006a56:	00cb1793          	slli	a5,s6,0xc
    80006a5a:	00fc0b33          	add	s6,s8,a5
    80006a5e:	6c89                	lui	s9,0x2
    80006a60:	016c8c33          	add	s8,s9,s6
    80006a64:	a049                	j	80006ae6 <virtio_disk_rw+0xfc>
      disk[n].free[i] = 0;
    80006a66:	00fb06b3          	add	a3,s6,a5
    80006a6a:	96e6                	add	a3,a3,s9
    80006a6c:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    80006a70:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006a72:	0207c763          	bltz	a5,80006aa0 <virtio_disk_rw+0xb6>
  for(int i = 0; i < 3; i++){
    80006a76:	2485                	addiw	s1,s1,1
    80006a78:	0711                	addi	a4,a4,4
    80006a7a:	28b48063          	beq	s1,a1,80006cfa <virtio_disk_rw+0x310>
    idx[i] = alloc_desc(n);
    80006a7e:	863a                	mv	a2,a4
    if(disk[n].free[i]){
    80006a80:	018c4783          	lbu	a5,24(s8)
    80006a84:	28079063          	bnez	a5,80006d04 <virtio_disk_rw+0x31a>
    80006a88:	86d6                	mv	a3,s5
  for(int i = 0; i < NUM; i++){
    80006a8a:	87c2                	mv	a5,a6
    if(disk[n].free[i]){
    80006a8c:	0006c883          	lbu	a7,0(a3)
    80006a90:	fc089be3          	bnez	a7,80006a66 <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    80006a94:	2785                	addiw	a5,a5,1
    80006a96:	0685                	addi	a3,a3,1
    80006a98:	fea79ae3          	bne	a5,a0,80006a8c <virtio_disk_rw+0xa2>
    idx[i] = alloc_desc(n);
    80006a9c:	57fd                	li	a5,-1
    80006a9e:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006aa0:	02905d63          	blez	s1,80006ada <virtio_disk_rw+0xf0>
        free_desc(n, idx[j]);
    80006aa4:	f8042583          	lw	a1,-128(s0)
    80006aa8:	854a                	mv	a0,s2
    80006aaa:	00000097          	auipc	ra,0x0
    80006aae:	cbc080e7          	jalr	-836(ra) # 80006766 <free_desc>
      for(int j = 0; j < i; j++)
    80006ab2:	4785                	li	a5,1
    80006ab4:	0297d363          	ble	s1,a5,80006ada <virtio_disk_rw+0xf0>
        free_desc(n, idx[j]);
    80006ab8:	f8442583          	lw	a1,-124(s0)
    80006abc:	854a                	mv	a0,s2
    80006abe:	00000097          	auipc	ra,0x0
    80006ac2:	ca8080e7          	jalr	-856(ra) # 80006766 <free_desc>
      for(int j = 0; j < i; j++)
    80006ac6:	4789                	li	a5,2
    80006ac8:	0097d963          	ble	s1,a5,80006ada <virtio_disk_rw+0xf0>
        free_desc(n, idx[j]);
    80006acc:	f8842583          	lw	a1,-120(s0)
    80006ad0:	854a                	mv	a0,s2
    80006ad2:	00000097          	auipc	ra,0x0
    80006ad6:	c94080e7          	jalr	-876(ra) # 80006766 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006ada:	85ce                	mv	a1,s3
    80006adc:	855e                	mv	a0,s7
    80006ade:	ffffc097          	auipc	ra,0xffffc
    80006ae2:	e54080e7          	jalr	-428(ra) # 80002932 <sleep>
  for(int i = 0; i < 3; i++){
    80006ae6:	f8040713          	addi	a4,s0,-128
    80006aea:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80006aec:	4805                	li	a6,1
    80006aee:	4521                	li	a0,8
  for(int i = 0; i < 3; i++){
    80006af0:	458d                	li	a1,3
    80006af2:	b771                	j	80006a7e <virtio_disk_rw+0x94>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006af4:	4785                	li	a5,1
    80006af6:	f6f42823          	sw	a5,-144(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    80006afa:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006afe:	f7a43c23          	sd	s10,-136(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006b02:	f8042483          	lw	s1,-128(s0)
    80006b06:	00449b13          	slli	s6,s1,0x4
    80006b0a:	00191793          	slli	a5,s2,0x1
    80006b0e:	97ca                	add	a5,a5,s2
    80006b10:	07b2                	slli	a5,a5,0xc
    80006b12:	00021a97          	auipc	s5,0x21
    80006b16:	4eea8a93          	addi	s5,s5,1262 # 80028000 <disk>
    80006b1a:	97d6                	add	a5,a5,s5
    80006b1c:	6a89                	lui	s5,0x2
    80006b1e:	9abe                	add	s5,s5,a5
    80006b20:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    80006b24:	9bda                	add	s7,s7,s6
    80006b26:	f7040513          	addi	a0,s0,-144
    80006b2a:	ffffb097          	auipc	ra,0xffffb
    80006b2e:	b52080e7          	jalr	-1198(ra) # 8000167c <kvmpa>
    80006b32:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006b36:	000ab783          	ld	a5,0(s5)
    80006b3a:	97da                	add	a5,a5,s6
    80006b3c:	4741                	li	a4,16
    80006b3e:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006b40:	000ab783          	ld	a5,0(s5)
    80006b44:	97da                	add	a5,a5,s6
    80006b46:	4705                	li	a4,1
    80006b48:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006b4c:	f8442603          	lw	a2,-124(s0)
    80006b50:	000ab783          	ld	a5,0(s5)
    80006b54:	9b3e                	add	s6,s6,a5
    80006b56:	00cb1723          	sh	a2,14(s6) # fffffffffffff00e <end+0xffffffff7ffd0f62>

  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006b5a:	0612                	slli	a2,a2,0x4
    80006b5c:	000ab783          	ld	a5,0(s5)
    80006b60:	97b2                	add	a5,a5,a2
    80006b62:	070a0713          	addi	a4,s4,112
    80006b66:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006b68:	000ab783          	ld	a5,0(s5)
    80006b6c:	97b2                	add	a5,a5,a2
    80006b6e:	40000713          	li	a4,1024
    80006b72:	c798                	sw	a4,8(a5)
  if(write)
    80006b74:	120d8e63          	beqz	s11,80006cb0 <virtio_disk_rw+0x2c6>
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006b78:	000ab783          	ld	a5,0(s5)
    80006b7c:	97b2                	add	a5,a5,a2
    80006b7e:	00079623          	sh	zero,12(a5)
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006b82:	00021517          	auipc	a0,0x21
    80006b86:	47e50513          	addi	a0,a0,1150 # 80028000 <disk>
    80006b8a:	00191793          	slli	a5,s2,0x1
    80006b8e:	012786b3          	add	a3,a5,s2
    80006b92:	06b2                	slli	a3,a3,0xc
    80006b94:	96aa                	add	a3,a3,a0
    80006b96:	6709                	lui	a4,0x2
    80006b98:	96ba                	add	a3,a3,a4
    80006b9a:	628c                	ld	a1,0(a3)
    80006b9c:	95b2                	add	a1,a1,a2
    80006b9e:	00c5d703          	lhu	a4,12(a1)
    80006ba2:	00176713          	ori	a4,a4,1
    80006ba6:	00e59623          	sh	a4,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    80006baa:	f8842583          	lw	a1,-120(s0)
    80006bae:	6298                	ld	a4,0(a3)
    80006bb0:	963a                	add	a2,a2,a4
    80006bb2:	00b61723          	sh	a1,14(a2) # 200e <_entry-0x7fffdff2>

  disk[n].info[idx[0]].status = 0;
    80006bb6:	97ca                	add	a5,a5,s2
    80006bb8:	07a2                	slli	a5,a5,0x8
    80006bba:	97a6                	add	a5,a5,s1
    80006bbc:	20078793          	addi	a5,a5,512
    80006bc0:	0792                	slli	a5,a5,0x4
    80006bc2:	97aa                	add	a5,a5,a0
    80006bc4:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006bc8:	00459613          	slli	a2,a1,0x4
    80006bcc:	628c                	ld	a1,0(a3)
    80006bce:	95b2                	add	a1,a1,a2
    80006bd0:	00191713          	slli	a4,s2,0x1
    80006bd4:	974a                	add	a4,a4,s2
    80006bd6:	0722                	slli	a4,a4,0x8
    80006bd8:	20348813          	addi	a6,s1,515
    80006bdc:	9742                	add	a4,a4,a6
    80006bde:	0712                	slli	a4,a4,0x4
    80006be0:	972a                	add	a4,a4,a0
    80006be2:	e198                	sd	a4,0(a1)
  disk[n].desc[idx[2]].len = 1;
    80006be4:	6298                	ld	a4,0(a3)
    80006be6:	9732                	add	a4,a4,a2
    80006be8:	4585                	li	a1,1
    80006bea:	c70c                	sw	a1,8(a4)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006bec:	6298                	ld	a4,0(a3)
    80006bee:	9732                	add	a4,a4,a2
    80006bf0:	4509                	li	a0,2
    80006bf2:	00a71623          	sh	a0,12(a4) # 200c <_entry-0x7fffdff4>
  disk[n].desc[idx[2]].next = 0;
    80006bf6:	6298                	ld	a4,0(a3)
    80006bf8:	963a                	add	a2,a2,a4
    80006bfa:	00061723          	sh	zero,14(a2)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006bfe:	00ba2223          	sw	a1,4(s4)
  disk[n].info[idx[0]].b = b;
    80006c02:	0347b423          	sd	s4,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    80006c06:	6698                	ld	a4,8(a3)
    80006c08:	00275783          	lhu	a5,2(a4)
    80006c0c:	8b9d                	andi	a5,a5,7
    80006c0e:	0789                	addi	a5,a5,2
    80006c10:	0786                	slli	a5,a5,0x1
    80006c12:	97ba                	add	a5,a5,a4
    80006c14:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80006c18:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006c1c:	6698                	ld	a4,8(a3)
    80006c1e:	00275783          	lhu	a5,2(a4)
    80006c22:	2785                	addiw	a5,a5,1
    80006c24:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006c28:	0019079b          	addiw	a5,s2,1
    80006c2c:	00c7979b          	slliw	a5,a5,0xc
    80006c30:	10000737          	lui	a4,0x10000
    80006c34:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    80006c38:	97ba                	add	a5,a5,a4
    80006c3a:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006c3e:	004a2703          	lw	a4,4(s4)
    80006c42:	4785                	li	a5,1
    80006c44:	00f71d63          	bne	a4,a5,80006c5e <virtio_disk_rw+0x274>
    80006c48:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    80006c4a:	85ce                	mv	a1,s3
    80006c4c:	8552                	mv	a0,s4
    80006c4e:	ffffc097          	auipc	ra,0xffffc
    80006c52:	ce4080e7          	jalr	-796(ra) # 80002932 <sleep>
  while(b->disk == 1) {
    80006c56:	004a2783          	lw	a5,4(s4)
    80006c5a:	fe9788e3          	beq	a5,s1,80006c4a <virtio_disk_rw+0x260>
  }

  disk[n].info[idx[0]].b = 0;
    80006c5e:	f8042483          	lw	s1,-128(s0)
    80006c62:	00191793          	slli	a5,s2,0x1
    80006c66:	97ca                	add	a5,a5,s2
    80006c68:	07a2                	slli	a5,a5,0x8
    80006c6a:	97a6                	add	a5,a5,s1
    80006c6c:	20078793          	addi	a5,a5,512
    80006c70:	0792                	slli	a5,a5,0x4
    80006c72:	00021717          	auipc	a4,0x21
    80006c76:	38e70713          	addi	a4,a4,910 # 80028000 <disk>
    80006c7a:	97ba                	add	a5,a5,a4
    80006c7c:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006c80:	00191793          	slli	a5,s2,0x1
    80006c84:	97ca                	add	a5,a5,s2
    80006c86:	07b2                	slli	a5,a5,0xc
    80006c88:	97ba                	add	a5,a5,a4
    80006c8a:	6a09                	lui	s4,0x2
    80006c8c:	9a3e                	add	s4,s4,a5
    free_desc(n, i);
    80006c8e:	85a6                	mv	a1,s1
    80006c90:	854a                	mv	a0,s2
    80006c92:	00000097          	auipc	ra,0x0
    80006c96:	ad4080e7          	jalr	-1324(ra) # 80006766 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006c9a:	0492                	slli	s1,s1,0x4
    80006c9c:	000a3783          	ld	a5,0(s4) # 2000 <_entry-0x7fffe000>
    80006ca0:	94be                	add	s1,s1,a5
    80006ca2:	00c4d783          	lhu	a5,12(s1)
    80006ca6:	8b85                	andi	a5,a5,1
    80006ca8:	c78d                	beqz	a5,80006cd2 <virtio_disk_rw+0x2e8>
      i = disk[n].desc[i].next;
    80006caa:	00e4d483          	lhu	s1,14(s1)
    80006cae:	b7c5                	j	80006c8e <virtio_disk_rw+0x2a4>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006cb0:	00191793          	slli	a5,s2,0x1
    80006cb4:	97ca                	add	a5,a5,s2
    80006cb6:	07b2                	slli	a5,a5,0xc
    80006cb8:	00021717          	auipc	a4,0x21
    80006cbc:	34870713          	addi	a4,a4,840 # 80028000 <disk>
    80006cc0:	973e                	add	a4,a4,a5
    80006cc2:	6789                	lui	a5,0x2
    80006cc4:	97ba                	add	a5,a5,a4
    80006cc6:	639c                	ld	a5,0(a5)
    80006cc8:	97b2                	add	a5,a5,a2
    80006cca:	4709                	li	a4,2
    80006ccc:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006cd0:	bd4d                	j	80006b82 <virtio_disk_rw+0x198>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006cd2:	854e                	mv	a0,s3
    80006cd4:	ffffa097          	auipc	ra,0xffffa
    80006cd8:	232080e7          	jalr	562(ra) # 80000f06 <release>
}
    80006cdc:	60aa                	ld	ra,136(sp)
    80006cde:	640a                	ld	s0,128(sp)
    80006ce0:	74e6                	ld	s1,120(sp)
    80006ce2:	7946                	ld	s2,112(sp)
    80006ce4:	79a6                	ld	s3,104(sp)
    80006ce6:	7a06                	ld	s4,96(sp)
    80006ce8:	6ae6                	ld	s5,88(sp)
    80006cea:	6b46                	ld	s6,80(sp)
    80006cec:	6ba6                	ld	s7,72(sp)
    80006cee:	6c06                	ld	s8,64(sp)
    80006cf0:	7ce2                	ld	s9,56(sp)
    80006cf2:	7d42                	ld	s10,48(sp)
    80006cf4:	7da2                	ld	s11,40(sp)
    80006cf6:	6149                	addi	sp,sp,144
    80006cf8:	8082                	ret
  if(write)
    80006cfa:	de0d9de3          	bnez	s11,80006af4 <virtio_disk_rw+0x10a>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006cfe:	f6042823          	sw	zero,-144(s0)
    80006d02:	bbe5                	j	80006afa <virtio_disk_rw+0x110>
      disk[n].free[i] = 0;
    80006d04:	000c0c23          	sb	zero,24(s8)
    idx[i] = alloc_desc(n);
    80006d08:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    80006d0c:	b3ad                	j	80006a76 <virtio_disk_rw+0x8c>

0000000080006d0e <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006d0e:	7139                	addi	sp,sp,-64
    80006d10:	fc06                	sd	ra,56(sp)
    80006d12:	f822                	sd	s0,48(sp)
    80006d14:	f426                	sd	s1,40(sp)
    80006d16:	f04a                	sd	s2,32(sp)
    80006d18:	ec4e                	sd	s3,24(sp)
    80006d1a:	e852                	sd	s4,16(sp)
    80006d1c:	e456                	sd	s5,8(sp)
    80006d1e:	0080                	addi	s0,sp,64
    80006d20:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006d22:	00151913          	slli	s2,a0,0x1
    80006d26:	00a90a33          	add	s4,s2,a0
    80006d2a:	0a32                	slli	s4,s4,0xc
    80006d2c:	6989                	lui	s3,0x2
    80006d2e:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006d32:	9a3e                	add	s4,s4,a5
    80006d34:	00021a97          	auipc	s5,0x21
    80006d38:	2cca8a93          	addi	s5,s5,716 # 80028000 <disk>
    80006d3c:	9a56                	add	s4,s4,s5
    80006d3e:	8552                	mv	a0,s4
    80006d40:	ffffa097          	auipc	ra,0xffffa
    80006d44:	f7a080e7          	jalr	-134(ra) # 80000cba <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006d48:	9926                	add	s2,s2,s1
    80006d4a:	0932                	slli	s2,s2,0xc
    80006d4c:	9956                	add	s2,s2,s5
    80006d4e:	99ca                	add	s3,s3,s2
    80006d50:	0209d683          	lhu	a3,32(s3)
    80006d54:	0109b703          	ld	a4,16(s3)
    80006d58:	00275783          	lhu	a5,2(a4)
    80006d5c:	8fb5                	xor	a5,a5,a3
    80006d5e:	8b9d                	andi	a5,a5,7
    80006d60:	cbd1                	beqz	a5,80006df4 <virtio_disk_intr+0xe6>
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006d62:	068e                	slli	a3,a3,0x3
    80006d64:	9736                	add	a4,a4,a3
    80006d66:	435c                	lw	a5,4(a4)

    if(disk[n].info[id].status != 0)
    80006d68:	00149713          	slli	a4,s1,0x1
    80006d6c:	9726                	add	a4,a4,s1
    80006d6e:	0722                	slli	a4,a4,0x8
    80006d70:	973e                	add	a4,a4,a5
    80006d72:	20070713          	addi	a4,a4,512
    80006d76:	0712                	slli	a4,a4,0x4
    80006d78:	9756                	add	a4,a4,s5
    80006d7a:	03074703          	lbu	a4,48(a4)
    80006d7e:	e33d                	bnez	a4,80006de4 <virtio_disk_intr+0xd6>
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006d80:	8956                	mv	s2,s5
    80006d82:	00149713          	slli	a4,s1,0x1
    80006d86:	9726                	add	a4,a4,s1
    80006d88:	00871993          	slli	s3,a4,0x8
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006d8c:	0732                	slli	a4,a4,0xc
    80006d8e:	9756                	add	a4,a4,s5
    80006d90:	6489                	lui	s1,0x2
    80006d92:	94ba                	add	s1,s1,a4
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006d94:	97ce                	add	a5,a5,s3
    80006d96:	20078793          	addi	a5,a5,512
    80006d9a:	0792                	slli	a5,a5,0x4
    80006d9c:	97ca                	add	a5,a5,s2
    80006d9e:	7798                	ld	a4,40(a5)
    80006da0:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006da4:	7788                	ld	a0,40(a5)
    80006da6:	ffffc097          	auipc	ra,0xffffc
    80006daa:	d12080e7          	jalr	-750(ra) # 80002ab8 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006dae:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006db2:	2785                	addiw	a5,a5,1
    80006db4:	8b9d                	andi	a5,a5,7
    80006db6:	03079613          	slli	a2,a5,0x30
    80006dba:	9241                	srli	a2,a2,0x30
    80006dbc:	02c49023          	sh	a2,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006dc0:	6898                	ld	a4,16(s1)
    80006dc2:	00275683          	lhu	a3,2(a4)
    80006dc6:	8a9d                	andi	a3,a3,7
    80006dc8:	02c68663          	beq	a3,a2,80006df4 <virtio_disk_intr+0xe6>
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006dcc:	078e                	slli	a5,a5,0x3
    80006dce:	97ba                	add	a5,a5,a4
    80006dd0:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006dd2:	00f98733          	add	a4,s3,a5
    80006dd6:	20070713          	addi	a4,a4,512
    80006dda:	0712                	slli	a4,a4,0x4
    80006ddc:	974a                	add	a4,a4,s2
    80006dde:	03074703          	lbu	a4,48(a4)
    80006de2:	db4d                	beqz	a4,80006d94 <virtio_disk_intr+0x86>
      panic("virtio_disk_intr status");
    80006de4:	00002517          	auipc	a0,0x2
    80006de8:	fac50513          	addi	a0,a0,-84 # 80008d90 <userret+0xd00>
    80006dec:	ffffa097          	auipc	ra,0xffffa
    80006df0:	998080e7          	jalr	-1640(ra) # 80000784 <panic>
  }

  release(&disk[n].vdisk_lock);
    80006df4:	8552                	mv	a0,s4
    80006df6:	ffffa097          	auipc	ra,0xffffa
    80006dfa:	110080e7          	jalr	272(ra) # 80000f06 <release>
}
    80006dfe:	70e2                	ld	ra,56(sp)
    80006e00:	7442                	ld	s0,48(sp)
    80006e02:	74a2                	ld	s1,40(sp)
    80006e04:	7902                	ld	s2,32(sp)
    80006e06:	69e2                	ld	s3,24(sp)
    80006e08:	6a42                	ld	s4,16(sp)
    80006e0a:	6aa2                	ld	s5,8(sp)
    80006e0c:	6121                	addi	sp,sp,64
    80006e0e:	8082                	ret

0000000080006e10 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006e10:	1141                	addi	sp,sp,-16
    80006e12:	e422                	sd	s0,8(sp)
    80006e14:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80006e16:	41f5d79b          	sraiw	a5,a1,0x1f
    80006e1a:	01d7d79b          	srliw	a5,a5,0x1d
    80006e1e:	9dbd                	addw	a1,a1,a5
    80006e20:	0075f713          	andi	a4,a1,7
    80006e24:	9f1d                	subw	a4,a4,a5
    80006e26:	4785                	li	a5,1
    80006e28:	00e797bb          	sllw	a5,a5,a4
    80006e2c:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80006e30:	4035d59b          	sraiw	a1,a1,0x3
    80006e34:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006e36:	0005c503          	lbu	a0,0(a1)
    80006e3a:	8d7d                	and	a0,a0,a5
    80006e3c:	8d1d                	sub	a0,a0,a5
}
    80006e3e:	00153513          	seqz	a0,a0
    80006e42:	6422                	ld	s0,8(sp)
    80006e44:	0141                	addi	sp,sp,16
    80006e46:	8082                	ret

0000000080006e48 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006e48:	1141                	addi	sp,sp,-16
    80006e4a:	e422                	sd	s0,8(sp)
    80006e4c:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006e4e:	41f5d71b          	sraiw	a4,a1,0x1f
    80006e52:	01d7571b          	srliw	a4,a4,0x1d
    80006e56:	9db9                	addw	a1,a1,a4
    80006e58:	4035d79b          	sraiw	a5,a1,0x3
    80006e5c:	953e                	add	a0,a0,a5
  char m = (1 << (index % 8));
    80006e5e:	899d                	andi	a1,a1,7
    80006e60:	9d99                	subw	a1,a1,a4
  array[index/8] = (b | m);
    80006e62:	4785                	li	a5,1
    80006e64:	00b795bb          	sllw	a1,a5,a1
    80006e68:	00054783          	lbu	a5,0(a0)
    80006e6c:	8ddd                	or	a1,a1,a5
    80006e6e:	00b50023          	sb	a1,0(a0)
}
    80006e72:	6422                	ld	s0,8(sp)
    80006e74:	0141                	addi	sp,sp,16
    80006e76:	8082                	ret

0000000080006e78 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006e78:	1141                	addi	sp,sp,-16
    80006e7a:	e422                	sd	s0,8(sp)
    80006e7c:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006e7e:	41f5d71b          	sraiw	a4,a1,0x1f
    80006e82:	01d7571b          	srliw	a4,a4,0x1d
    80006e86:	9db9                	addw	a1,a1,a4
    80006e88:	4035d79b          	sraiw	a5,a1,0x3
    80006e8c:	953e                	add	a0,a0,a5
  char m = (1 << (index % 8));
    80006e8e:	899d                	andi	a1,a1,7
    80006e90:	9d99                	subw	a1,a1,a4
  array[index/8] = (b & ~m);
    80006e92:	4785                	li	a5,1
    80006e94:	00b795bb          	sllw	a1,a5,a1
    80006e98:	fff5c593          	not	a1,a1
    80006e9c:	00054783          	lbu	a5,0(a0)
    80006ea0:	8dfd                	and	a1,a1,a5
    80006ea2:	00b50023          	sb	a1,0(a0)
}
    80006ea6:	6422                	ld	s0,8(sp)
    80006ea8:	0141                	addi	sp,sp,16
    80006eaa:	8082                	ret

0000000080006eac <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006eac:	715d                	addi	sp,sp,-80
    80006eae:	e486                	sd	ra,72(sp)
    80006eb0:	e0a2                	sd	s0,64(sp)
    80006eb2:	fc26                	sd	s1,56(sp)
    80006eb4:	f84a                	sd	s2,48(sp)
    80006eb6:	f44e                	sd	s3,40(sp)
    80006eb8:	f052                	sd	s4,32(sp)
    80006eba:	ec56                	sd	s5,24(sp)
    80006ebc:	e85a                	sd	s6,16(sp)
    80006ebe:	e45e                	sd	s7,8(sp)
    80006ec0:	0880                	addi	s0,sp,80
    80006ec2:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006ec4:	08b05b63          	blez	a1,80006f5a <bd_print_vector+0xae>
    80006ec8:	89aa                	mv	s3,a0
    80006eca:	4481                	li	s1,0
  lb = 0;
    80006ecc:	4a81                	li	s5,0
  last = 1;
    80006ece:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006ed0:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006ed2:	00002b97          	auipc	s7,0x2
    80006ed6:	ed6b8b93          	addi	s7,s7,-298 # 80008da8 <userret+0xd18>
    80006eda:	a01d                	j	80006f00 <bd_print_vector+0x54>
    80006edc:	8626                	mv	a2,s1
    80006ede:	85d6                	mv	a1,s5
    80006ee0:	855e                	mv	a0,s7
    80006ee2:	ffffa097          	auipc	ra,0xffffa
    80006ee6:	aba080e7          	jalr	-1350(ra) # 8000099c <printf>
    lb = b;
    last = bit_isset(vector, b);
    80006eea:	85a6                	mv	a1,s1
    80006eec:	854e                	mv	a0,s3
    80006eee:	00000097          	auipc	ra,0x0
    80006ef2:	f22080e7          	jalr	-222(ra) # 80006e10 <bit_isset>
    80006ef6:	892a                	mv	s2,a0
    80006ef8:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006efa:	2485                	addiw	s1,s1,1
    80006efc:	009a0d63          	beq	s4,s1,80006f16 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006f00:	85a6                	mv	a1,s1
    80006f02:	854e                	mv	a0,s3
    80006f04:	00000097          	auipc	ra,0x0
    80006f08:	f0c080e7          	jalr	-244(ra) # 80006e10 <bit_isset>
    80006f0c:	ff2507e3          	beq	a0,s2,80006efa <bd_print_vector+0x4e>
    if(last == 1)
    80006f10:	fd691de3          	bne	s2,s6,80006eea <bd_print_vector+0x3e>
    80006f14:	b7e1                	j	80006edc <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80006f16:	000a8563          	beqz	s5,80006f20 <bd_print_vector+0x74>
    80006f1a:	4785                	li	a5,1
    80006f1c:	00f91c63          	bne	s2,a5,80006f34 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006f20:	8652                	mv	a2,s4
    80006f22:	85d6                	mv	a1,s5
    80006f24:	00002517          	auipc	a0,0x2
    80006f28:	e8450513          	addi	a0,a0,-380 # 80008da8 <userret+0xd18>
    80006f2c:	ffffa097          	auipc	ra,0xffffa
    80006f30:	a70080e7          	jalr	-1424(ra) # 8000099c <printf>
  }
  printf("\n");
    80006f34:	00001517          	auipc	a0,0x1
    80006f38:	71450513          	addi	a0,a0,1812 # 80008648 <userret+0x5b8>
    80006f3c:	ffffa097          	auipc	ra,0xffffa
    80006f40:	a60080e7          	jalr	-1440(ra) # 8000099c <printf>
}
    80006f44:	60a6                	ld	ra,72(sp)
    80006f46:	6406                	ld	s0,64(sp)
    80006f48:	74e2                	ld	s1,56(sp)
    80006f4a:	7942                	ld	s2,48(sp)
    80006f4c:	79a2                	ld	s3,40(sp)
    80006f4e:	7a02                	ld	s4,32(sp)
    80006f50:	6ae2                	ld	s5,24(sp)
    80006f52:	6b42                	ld	s6,16(sp)
    80006f54:	6ba2                	ld	s7,8(sp)
    80006f56:	6161                	addi	sp,sp,80
    80006f58:	8082                	ret
  lb = 0;
    80006f5a:	4a81                	li	s5,0
    80006f5c:	b7d1                	j	80006f20 <bd_print_vector+0x74>

0000000080006f5e <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006f5e:	00027797          	auipc	a5,0x27
    80006f62:	14278793          	addi	a5,a5,322 # 8002e0a0 <nsizes>
    80006f66:	4394                	lw	a3,0(a5)
    80006f68:	0ed05b63          	blez	a3,8000705e <bd_print+0x100>
bd_print() {
    80006f6c:	711d                	addi	sp,sp,-96
    80006f6e:	ec86                	sd	ra,88(sp)
    80006f70:	e8a2                	sd	s0,80(sp)
    80006f72:	e4a6                	sd	s1,72(sp)
    80006f74:	e0ca                	sd	s2,64(sp)
    80006f76:	fc4e                	sd	s3,56(sp)
    80006f78:	f852                	sd	s4,48(sp)
    80006f7a:	f456                	sd	s5,40(sp)
    80006f7c:	f05a                	sd	s6,32(sp)
    80006f7e:	ec5e                	sd	s7,24(sp)
    80006f80:	e862                	sd	s8,16(sp)
    80006f82:	e466                	sd	s9,8(sp)
    80006f84:	e06a                	sd	s10,0(sp)
    80006f86:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80006f88:	4901                	li	s2,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006f8a:	4a85                	li	s5,1
    80006f8c:	4c41                	li	s8,16
    80006f8e:	00002b97          	auipc	s7,0x2
    80006f92:	e2ab8b93          	addi	s7,s7,-470 # 80008db8 <userret+0xd28>
    lst_print(&bd_sizes[k].free);
    80006f96:	00027a17          	auipc	s4,0x27
    80006f9a:	102a0a13          	addi	s4,s4,258 # 8002e098 <bd_sizes>
    printf("  alloc:");
    80006f9e:	00002b17          	auipc	s6,0x2
    80006fa2:	e42b0b13          	addi	s6,s6,-446 # 80008de0 <userret+0xd50>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006fa6:	89be                	mv	s3,a5
    if(k > 0) {
      printf("  split:");
    80006fa8:	00002c97          	auipc	s9,0x2
    80006fac:	e48c8c93          	addi	s9,s9,-440 # 80008df0 <userret+0xd60>
    80006fb0:	a801                	j	80006fc0 <bd_print+0x62>
  for (int k = 0; k < nsizes; k++) {
    80006fb2:	0009a683          	lw	a3,0(s3)
    80006fb6:	0905                	addi	s2,s2,1
    80006fb8:	0009079b          	sext.w	a5,s2
    80006fbc:	08d7d363          	ble	a3,a5,80007042 <bd_print+0xe4>
    80006fc0:	0009049b          	sext.w	s1,s2
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006fc4:	36fd                	addiw	a3,a3,-1
    80006fc6:	9e85                	subw	a3,a3,s1
    80006fc8:	00da96bb          	sllw	a3,s5,a3
    80006fcc:	009c1633          	sll	a2,s8,s1
    80006fd0:	85a6                	mv	a1,s1
    80006fd2:	855e                	mv	a0,s7
    80006fd4:	ffffa097          	auipc	ra,0xffffa
    80006fd8:	9c8080e7          	jalr	-1592(ra) # 8000099c <printf>
    lst_print(&bd_sizes[k].free);
    80006fdc:	00591d13          	slli	s10,s2,0x5
    80006fe0:	000a3503          	ld	a0,0(s4)
    80006fe4:	956a                	add	a0,a0,s10
    80006fe6:	00001097          	auipc	ra,0x1
    80006fea:	a80080e7          	jalr	-1408(ra) # 80007a66 <lst_print>
    printf("  alloc:");
    80006fee:	855a                	mv	a0,s6
    80006ff0:	ffffa097          	auipc	ra,0xffffa
    80006ff4:	9ac080e7          	jalr	-1620(ra) # 8000099c <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006ff8:	0009a583          	lw	a1,0(s3)
    80006ffc:	35fd                	addiw	a1,a1,-1
    80006ffe:	9d85                	subw	a1,a1,s1
    80007000:	000a3783          	ld	a5,0(s4)
    80007004:	97ea                	add	a5,a5,s10
    80007006:	00ba95bb          	sllw	a1,s5,a1
    8000700a:	6b88                	ld	a0,16(a5)
    8000700c:	00000097          	auipc	ra,0x0
    80007010:	ea0080e7          	jalr	-352(ra) # 80006eac <bd_print_vector>
    if(k > 0) {
    80007014:	f8905fe3          	blez	s1,80006fb2 <bd_print+0x54>
      printf("  split:");
    80007018:	8566                	mv	a0,s9
    8000701a:	ffffa097          	auipc	ra,0xffffa
    8000701e:	982080e7          	jalr	-1662(ra) # 8000099c <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80007022:	0009a583          	lw	a1,0(s3)
    80007026:	35fd                	addiw	a1,a1,-1
    80007028:	9d85                	subw	a1,a1,s1
    8000702a:	000a3783          	ld	a5,0(s4)
    8000702e:	9d3e                	add	s10,s10,a5
    80007030:	00ba95bb          	sllw	a1,s5,a1
    80007034:	018d3503          	ld	a0,24(s10) # 1018 <_entry-0x7fffefe8>
    80007038:	00000097          	auipc	ra,0x0
    8000703c:	e74080e7          	jalr	-396(ra) # 80006eac <bd_print_vector>
    80007040:	bf8d                	j	80006fb2 <bd_print+0x54>
    }
  }
}
    80007042:	60e6                	ld	ra,88(sp)
    80007044:	6446                	ld	s0,80(sp)
    80007046:	64a6                	ld	s1,72(sp)
    80007048:	6906                	ld	s2,64(sp)
    8000704a:	79e2                	ld	s3,56(sp)
    8000704c:	7a42                	ld	s4,48(sp)
    8000704e:	7aa2                	ld	s5,40(sp)
    80007050:	7b02                	ld	s6,32(sp)
    80007052:	6be2                	ld	s7,24(sp)
    80007054:	6c42                	ld	s8,16(sp)
    80007056:	6ca2                	ld	s9,8(sp)
    80007058:	6d02                	ld	s10,0(sp)
    8000705a:	6125                	addi	sp,sp,96
    8000705c:	8082                	ret
    8000705e:	8082                	ret

0000000080007060 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80007060:	1141                	addi	sp,sp,-16
    80007062:	e422                	sd	s0,8(sp)
    80007064:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80007066:	47c1                	li	a5,16
    80007068:	00a7fb63          	bleu	a0,a5,8000707e <firstk+0x1e>
  int k = 0;
    8000706c:	4701                	li	a4,0
    k++;
    8000706e:	2705                	addiw	a4,a4,1
    size *= 2;
    80007070:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80007072:	fea7eee3          	bltu	a5,a0,8000706e <firstk+0xe>
  }
  return k;
}
    80007076:	853a                	mv	a0,a4
    80007078:	6422                	ld	s0,8(sp)
    8000707a:	0141                	addi	sp,sp,16
    8000707c:	8082                	ret
  int k = 0;
    8000707e:	4701                	li	a4,0
    80007080:	bfdd                	j	80007076 <firstk+0x16>

0000000080007082 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80007082:	1141                	addi	sp,sp,-16
    80007084:	e422                	sd	s0,8(sp)
    80007086:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
    80007088:	00027797          	auipc	a5,0x27
    8000708c:	00878793          	addi	a5,a5,8 # 8002e090 <bd_base>
    80007090:	639c                	ld	a5,0(a5)
  return n / BLK_SIZE(k);
    80007092:	9d9d                	subw	a1,a1,a5
    80007094:	47c1                	li	a5,16
    80007096:	00a79533          	sll	a0,a5,a0
    8000709a:	02a5c533          	div	a0,a1,a0
}
    8000709e:	2501                	sext.w	a0,a0
    800070a0:	6422                	ld	s0,8(sp)
    800070a2:	0141                	addi	sp,sp,16
    800070a4:	8082                	ret

00000000800070a6 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    800070a6:	1141                	addi	sp,sp,-16
    800070a8:	e422                	sd	s0,8(sp)
    800070aa:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    800070ac:	47c1                	li	a5,16
    800070ae:	00a79533          	sll	a0,a5,a0
  return (char *) bd_base + n;
    800070b2:	02a5853b          	mulw	a0,a1,a0
    800070b6:	00027797          	auipc	a5,0x27
    800070ba:	fda78793          	addi	a5,a5,-38 # 8002e090 <bd_base>
    800070be:	639c                	ld	a5,0(a5)
}
    800070c0:	953e                	add	a0,a0,a5
    800070c2:	6422                	ld	s0,8(sp)
    800070c4:	0141                	addi	sp,sp,16
    800070c6:	8082                	ret

00000000800070c8 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    800070c8:	7159                	addi	sp,sp,-112
    800070ca:	f486                	sd	ra,104(sp)
    800070cc:	f0a2                	sd	s0,96(sp)
    800070ce:	eca6                	sd	s1,88(sp)
    800070d0:	e8ca                	sd	s2,80(sp)
    800070d2:	e4ce                	sd	s3,72(sp)
    800070d4:	e0d2                	sd	s4,64(sp)
    800070d6:	fc56                	sd	s5,56(sp)
    800070d8:	f85a                	sd	s6,48(sp)
    800070da:	f45e                	sd	s7,40(sp)
    800070dc:	f062                	sd	s8,32(sp)
    800070de:	ec66                	sd	s9,24(sp)
    800070e0:	e86a                	sd	s10,16(sp)
    800070e2:	e46e                	sd	s11,8(sp)
    800070e4:	1880                	addi	s0,sp,112
    800070e6:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    800070e8:	00027517          	auipc	a0,0x27
    800070ec:	f1850513          	addi	a0,a0,-232 # 8002e000 <lock>
    800070f0:	ffffa097          	auipc	ra,0xffffa
    800070f4:	bca080e7          	jalr	-1078(ra) # 80000cba <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    800070f8:	8526                	mv	a0,s1
    800070fa:	00000097          	auipc	ra,0x0
    800070fe:	f66080e7          	jalr	-154(ra) # 80007060 <firstk>
  for (k = fk; k < nsizes; k++) {
    80007102:	00027797          	auipc	a5,0x27
    80007106:	f9e78793          	addi	a5,a5,-98 # 8002e0a0 <nsizes>
    8000710a:	439c                	lw	a5,0(a5)
    8000710c:	02f55d63          	ble	a5,a0,80007146 <bd_malloc+0x7e>
    80007110:	8d2a                	mv	s10,a0
    80007112:	00551913          	slli	s2,a0,0x5
    80007116:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80007118:	00027997          	auipc	s3,0x27
    8000711c:	f8098993          	addi	s3,s3,-128 # 8002e098 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80007120:	00027a17          	auipc	s4,0x27
    80007124:	f80a0a13          	addi	s4,s4,-128 # 8002e0a0 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80007128:	0009b503          	ld	a0,0(s3)
    8000712c:	954a                	add	a0,a0,s2
    8000712e:	00001097          	auipc	ra,0x1
    80007132:	8be080e7          	jalr	-1858(ra) # 800079ec <lst_empty>
    80007136:	c115                	beqz	a0,8000715a <bd_malloc+0x92>
  for (k = fk; k < nsizes; k++) {
    80007138:	2485                	addiw	s1,s1,1
    8000713a:	02090913          	addi	s2,s2,32
    8000713e:	000a2783          	lw	a5,0(s4)
    80007142:	fef4c3e3          	blt	s1,a5,80007128 <bd_malloc+0x60>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80007146:	00027517          	auipc	a0,0x27
    8000714a:	eba50513          	addi	a0,a0,-326 # 8002e000 <lock>
    8000714e:	ffffa097          	auipc	ra,0xffffa
    80007152:	db8080e7          	jalr	-584(ra) # 80000f06 <release>
    return 0;
    80007156:	4b81                	li	s7,0
    80007158:	a8d1                	j	8000722c <bd_malloc+0x164>
  if(k >= nsizes) { // No free blocks?
    8000715a:	00027797          	auipc	a5,0x27
    8000715e:	f4678793          	addi	a5,a5,-186 # 8002e0a0 <nsizes>
    80007162:	439c                	lw	a5,0(a5)
    80007164:	fef4d1e3          	ble	a5,s1,80007146 <bd_malloc+0x7e>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80007168:	00549993          	slli	s3,s1,0x5
    8000716c:	00027917          	auipc	s2,0x27
    80007170:	f2c90913          	addi	s2,s2,-212 # 8002e098 <bd_sizes>
    80007174:	00093503          	ld	a0,0(s2)
    80007178:	954e                	add	a0,a0,s3
    8000717a:	00001097          	auipc	ra,0x1
    8000717e:	89e080e7          	jalr	-1890(ra) # 80007a18 <lst_pop>
    80007182:	8baa                	mv	s7,a0
  int n = p - (char *) bd_base;
    80007184:	00027797          	auipc	a5,0x27
    80007188:	f0c78793          	addi	a5,a5,-244 # 8002e090 <bd_base>
    8000718c:	638c                	ld	a1,0(a5)
  return n / BLK_SIZE(k);
    8000718e:	40b505bb          	subw	a1,a0,a1
    80007192:	47c1                	li	a5,16
    80007194:	009797b3          	sll	a5,a5,s1
    80007198:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    8000719c:	00093783          	ld	a5,0(s2)
    800071a0:	97ce                	add	a5,a5,s3
    800071a2:	2581                	sext.w	a1,a1
    800071a4:	6b88                	ld	a0,16(a5)
    800071a6:	00000097          	auipc	ra,0x0
    800071aa:	ca2080e7          	jalr	-862(ra) # 80006e48 <bit_set>
  for(; k > fk; k--) {
    800071ae:	069d5763          	ble	s1,s10,8000721c <bd_malloc+0x154>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800071b2:	4c41                	li	s8,16
  int n = p - (char *) bd_base;
    800071b4:	00027d97          	auipc	s11,0x27
    800071b8:	edcd8d93          	addi	s11,s11,-292 # 8002e090 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800071bc:	fff48a9b          	addiw	s5,s1,-1
    800071c0:	015c1b33          	sll	s6,s8,s5
    800071c4:	016b8cb3          	add	s9,s7,s6
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800071c8:	00027797          	auipc	a5,0x27
    800071cc:	ed078793          	addi	a5,a5,-304 # 8002e098 <bd_sizes>
    800071d0:	0007ba03          	ld	s4,0(a5)
  int n = p - (char *) bd_base;
    800071d4:	000db903          	ld	s2,0(s11)
  return n / BLK_SIZE(k);
    800071d8:	412b893b          	subw	s2,s7,s2
    800071dc:	009c15b3          	sll	a1,s8,s1
    800071e0:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800071e4:	013a07b3          	add	a5,s4,s3
    800071e8:	2581                	sext.w	a1,a1
    800071ea:	6f88                	ld	a0,24(a5)
    800071ec:	00000097          	auipc	ra,0x0
    800071f0:	c5c080e7          	jalr	-932(ra) # 80006e48 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800071f4:	1981                	addi	s3,s3,-32
    800071f6:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    800071f8:	036945b3          	div	a1,s2,s6
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800071fc:	2581                	sext.w	a1,a1
    800071fe:	010a3503          	ld	a0,16(s4)
    80007202:	00000097          	auipc	ra,0x0
    80007206:	c46080e7          	jalr	-954(ra) # 80006e48 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    8000720a:	85e6                	mv	a1,s9
    8000720c:	8552                	mv	a0,s4
    8000720e:	00001097          	auipc	ra,0x1
    80007212:	840080e7          	jalr	-1984(ra) # 80007a4e <lst_push>
  for(; k > fk; k--) {
    80007216:	84d6                	mv	s1,s5
    80007218:	fbaa92e3          	bne	s5,s10,800071bc <bd_malloc+0xf4>
  }
  release(&lock);
    8000721c:	00027517          	auipc	a0,0x27
    80007220:	de450513          	addi	a0,a0,-540 # 8002e000 <lock>
    80007224:	ffffa097          	auipc	ra,0xffffa
    80007228:	ce2080e7          	jalr	-798(ra) # 80000f06 <release>

  return p;
}
    8000722c:	855e                	mv	a0,s7
    8000722e:	70a6                	ld	ra,104(sp)
    80007230:	7406                	ld	s0,96(sp)
    80007232:	64e6                	ld	s1,88(sp)
    80007234:	6946                	ld	s2,80(sp)
    80007236:	69a6                	ld	s3,72(sp)
    80007238:	6a06                	ld	s4,64(sp)
    8000723a:	7ae2                	ld	s5,56(sp)
    8000723c:	7b42                	ld	s6,48(sp)
    8000723e:	7ba2                	ld	s7,40(sp)
    80007240:	7c02                	ld	s8,32(sp)
    80007242:	6ce2                	ld	s9,24(sp)
    80007244:	6d42                	ld	s10,16(sp)
    80007246:	6da2                	ld	s11,8(sp)
    80007248:	6165                	addi	sp,sp,112
    8000724a:	8082                	ret

000000008000724c <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    8000724c:	7139                	addi	sp,sp,-64
    8000724e:	fc06                	sd	ra,56(sp)
    80007250:	f822                	sd	s0,48(sp)
    80007252:	f426                	sd	s1,40(sp)
    80007254:	f04a                	sd	s2,32(sp)
    80007256:	ec4e                	sd	s3,24(sp)
    80007258:	e852                	sd	s4,16(sp)
    8000725a:	e456                	sd	s5,8(sp)
    8000725c:	e05a                	sd	s6,0(sp)
    8000725e:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80007260:	00027797          	auipc	a5,0x27
    80007264:	e4078793          	addi	a5,a5,-448 # 8002e0a0 <nsizes>
    80007268:	0007aa83          	lw	s5,0(a5)
  int n = p - (char *) bd_base;
    8000726c:	00027797          	auipc	a5,0x27
    80007270:	e2478793          	addi	a5,a5,-476 # 8002e090 <bd_base>
    80007274:	0007ba03          	ld	s4,0(a5)
  return n / BLK_SIZE(k);
    80007278:	41450a3b          	subw	s4,a0,s4
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    8000727c:	00027797          	auipc	a5,0x27
    80007280:	e1c78793          	addi	a5,a5,-484 # 8002e098 <bd_sizes>
    80007284:	6384                	ld	s1,0(a5)
    80007286:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    8000728a:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    8000728c:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    8000728e:	03595363          	ble	s5,s2,800072b4 <size+0x68>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80007292:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80007296:	013b15b3          	sll	a1,s6,s3
    8000729a:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    8000729e:	2581                	sext.w	a1,a1
    800072a0:	6088                	ld	a0,0(s1)
    800072a2:	00000097          	auipc	ra,0x0
    800072a6:	b6e080e7          	jalr	-1170(ra) # 80006e10 <bit_isset>
    800072aa:	02048493          	addi	s1,s1,32
    800072ae:	e501                	bnez	a0,800072b6 <size+0x6a>
  for (int k = 0; k < nsizes; k++) {
    800072b0:	894e                	mv	s2,s3
    800072b2:	bff1                	j	8000728e <size+0x42>
      return k;
    }
  }
  return 0;
    800072b4:	4901                	li	s2,0
}
    800072b6:	854a                	mv	a0,s2
    800072b8:	70e2                	ld	ra,56(sp)
    800072ba:	7442                	ld	s0,48(sp)
    800072bc:	74a2                	ld	s1,40(sp)
    800072be:	7902                	ld	s2,32(sp)
    800072c0:	69e2                	ld	s3,24(sp)
    800072c2:	6a42                	ld	s4,16(sp)
    800072c4:	6aa2                	ld	s5,8(sp)
    800072c6:	6b02                	ld	s6,0(sp)
    800072c8:	6121                	addi	sp,sp,64
    800072ca:	8082                	ret

00000000800072cc <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    800072cc:	7159                	addi	sp,sp,-112
    800072ce:	f486                	sd	ra,104(sp)
    800072d0:	f0a2                	sd	s0,96(sp)
    800072d2:	eca6                	sd	s1,88(sp)
    800072d4:	e8ca                	sd	s2,80(sp)
    800072d6:	e4ce                	sd	s3,72(sp)
    800072d8:	e0d2                	sd	s4,64(sp)
    800072da:	fc56                	sd	s5,56(sp)
    800072dc:	f85a                	sd	s6,48(sp)
    800072de:	f45e                	sd	s7,40(sp)
    800072e0:	f062                	sd	s8,32(sp)
    800072e2:	ec66                	sd	s9,24(sp)
    800072e4:	e86a                	sd	s10,16(sp)
    800072e6:	e46e                	sd	s11,8(sp)
    800072e8:	1880                	addi	s0,sp,112
    800072ea:	8b2a                	mv	s6,a0
  void *q;
  int k;

  acquire(&lock);
    800072ec:	00027517          	auipc	a0,0x27
    800072f0:	d1450513          	addi	a0,a0,-748 # 8002e000 <lock>
    800072f4:	ffffa097          	auipc	ra,0xffffa
    800072f8:	9c6080e7          	jalr	-1594(ra) # 80000cba <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    800072fc:	855a                	mv	a0,s6
    800072fe:	00000097          	auipc	ra,0x0
    80007302:	f4e080e7          	jalr	-178(ra) # 8000724c <size>
    80007306:	892a                	mv	s2,a0
    80007308:	00027797          	auipc	a5,0x27
    8000730c:	d9878793          	addi	a5,a5,-616 # 8002e0a0 <nsizes>
    80007310:	439c                	lw	a5,0(a5)
    80007312:	37fd                	addiw	a5,a5,-1
    80007314:	0af55a63          	ble	a5,a0,800073c8 <bd_free+0xfc>
    80007318:	00551a93          	slli	s5,a0,0x5
  int n = p - (char *) bd_base;
    8000731c:	00027c97          	auipc	s9,0x27
    80007320:	d74c8c93          	addi	s9,s9,-652 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    80007324:	4c41                	li	s8,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007326:	00027b97          	auipc	s7,0x27
    8000732a:	d72b8b93          	addi	s7,s7,-654 # 8002e098 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    8000732e:	00027d17          	auipc	s10,0x27
    80007332:	d72d0d13          	addi	s10,s10,-654 # 8002e0a0 <nsizes>
    80007336:	a82d                	j	80007370 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007338:	fff5849b          	addiw	s1,a1,-1
    8000733c:	a881                	j	8000738c <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    8000733e:	020a8a93          	addi	s5,s5,32
    80007342:	2905                	addiw	s2,s2,1
  int n = p - (char *) bd_base;
    80007344:	000cb583          	ld	a1,0(s9)
  return n / BLK_SIZE(k);
    80007348:	40bb05bb          	subw	a1,s6,a1
    8000734c:	012c17b3          	sll	a5,s8,s2
    80007350:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007354:	000bb783          	ld	a5,0(s7)
    80007358:	97d6                	add	a5,a5,s5
    8000735a:	2581                	sext.w	a1,a1
    8000735c:	6f88                	ld	a0,24(a5)
    8000735e:	00000097          	auipc	ra,0x0
    80007362:	b1a080e7          	jalr	-1254(ra) # 80006e78 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80007366:	000d2783          	lw	a5,0(s10)
    8000736a:	37fd                	addiw	a5,a5,-1
    8000736c:	04f95e63          	ble	a5,s2,800073c8 <bd_free+0xfc>
  int n = p - (char *) bd_base;
    80007370:	000cb983          	ld	s3,0(s9)
  return n / BLK_SIZE(k);
    80007374:	012c1a33          	sll	s4,s8,s2
    80007378:	413b07bb          	subw	a5,s6,s3
    8000737c:	0347c7b3          	div	a5,a5,s4
    80007380:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007384:	8b85                	andi	a5,a5,1
    80007386:	fbcd                	bnez	a5,80007338 <bd_free+0x6c>
    80007388:	0015849b          	addiw	s1,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    8000738c:	000bbd83          	ld	s11,0(s7)
    80007390:	9dd6                	add	s11,s11,s5
    80007392:	010db503          	ld	a0,16(s11)
    80007396:	00000097          	auipc	ra,0x0
    8000739a:	ae2080e7          	jalr	-1310(ra) # 80006e78 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    8000739e:	85a6                	mv	a1,s1
    800073a0:	010db503          	ld	a0,16(s11)
    800073a4:	00000097          	auipc	ra,0x0
    800073a8:	a6c080e7          	jalr	-1428(ra) # 80006e10 <bit_isset>
    800073ac:	ed11                	bnez	a0,800073c8 <bd_free+0xfc>
  int n = bi * BLK_SIZE(k);
    800073ae:	2481                	sext.w	s1,s1
  return (char *) bd_base + n;
    800073b0:	029a0a3b          	mulw	s4,s4,s1
    800073b4:	99d2                	add	s3,s3,s4
    lst_remove(q);    // remove buddy from free list
    800073b6:	854e                	mv	a0,s3
    800073b8:	00000097          	auipc	ra,0x0
    800073bc:	64a080e7          	jalr	1610(ra) # 80007a02 <lst_remove>
    if(buddy % 2 == 0) {
    800073c0:	8885                	andi	s1,s1,1
    800073c2:	fcb5                	bnez	s1,8000733e <bd_free+0x72>
      p = q;
    800073c4:	8b4e                	mv	s6,s3
    800073c6:	bfa5                	j	8000733e <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    800073c8:	0916                	slli	s2,s2,0x5
    800073ca:	00027797          	auipc	a5,0x27
    800073ce:	cce78793          	addi	a5,a5,-818 # 8002e098 <bd_sizes>
    800073d2:	6388                	ld	a0,0(a5)
    800073d4:	85da                	mv	a1,s6
    800073d6:	954a                	add	a0,a0,s2
    800073d8:	00000097          	auipc	ra,0x0
    800073dc:	676080e7          	jalr	1654(ra) # 80007a4e <lst_push>
  release(&lock);
    800073e0:	00027517          	auipc	a0,0x27
    800073e4:	c2050513          	addi	a0,a0,-992 # 8002e000 <lock>
    800073e8:	ffffa097          	auipc	ra,0xffffa
    800073ec:	b1e080e7          	jalr	-1250(ra) # 80000f06 <release>
}
    800073f0:	70a6                	ld	ra,104(sp)
    800073f2:	7406                	ld	s0,96(sp)
    800073f4:	64e6                	ld	s1,88(sp)
    800073f6:	6946                	ld	s2,80(sp)
    800073f8:	69a6                	ld	s3,72(sp)
    800073fa:	6a06                	ld	s4,64(sp)
    800073fc:	7ae2                	ld	s5,56(sp)
    800073fe:	7b42                	ld	s6,48(sp)
    80007400:	7ba2                	ld	s7,40(sp)
    80007402:	7c02                	ld	s8,32(sp)
    80007404:	6ce2                	ld	s9,24(sp)
    80007406:	6d42                	ld	s10,16(sp)
    80007408:	6da2                	ld	s11,8(sp)
    8000740a:	6165                	addi	sp,sp,112
    8000740c:	8082                	ret

000000008000740e <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    8000740e:	1141                	addi	sp,sp,-16
    80007410:	e422                	sd	s0,8(sp)
    80007412:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80007414:	00027797          	auipc	a5,0x27
    80007418:	c7c78793          	addi	a5,a5,-900 # 8002e090 <bd_base>
    8000741c:	639c                	ld	a5,0(a5)
    8000741e:	8d9d                	sub	a1,a1,a5
    80007420:	47c1                	li	a5,16
    80007422:	00a797b3          	sll	a5,a5,a0
    80007426:	02f5c533          	div	a0,a1,a5
    8000742a:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    8000742c:	02f5e5b3          	rem	a1,a1,a5
    80007430:	c191                	beqz	a1,80007434 <blk_index_next+0x26>
      n++;
    80007432:	2505                	addiw	a0,a0,1
  return n ;
}
    80007434:	6422                	ld	s0,8(sp)
    80007436:	0141                	addi	sp,sp,16
    80007438:	8082                	ret

000000008000743a <log2>:

int
log2(uint64 n) {
    8000743a:	1141                	addi	sp,sp,-16
    8000743c:	e422                	sd	s0,8(sp)
    8000743e:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80007440:	4705                	li	a4,1
    80007442:	00a77b63          	bleu	a0,a4,80007458 <log2+0x1e>
    80007446:	87aa                	mv	a5,a0
  int k = 0;
    80007448:	4501                	li	a0,0
    k++;
    8000744a:	2505                	addiw	a0,a0,1
    n = n >> 1;
    8000744c:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    8000744e:	fef76ee3          	bltu	a4,a5,8000744a <log2+0x10>
  }
  return k;
}
    80007452:	6422                	ld	s0,8(sp)
    80007454:	0141                	addi	sp,sp,16
    80007456:	8082                	ret
  int k = 0;
    80007458:	4501                	li	a0,0
    8000745a:	bfe5                	j	80007452 <log2+0x18>

000000008000745c <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    8000745c:	711d                	addi	sp,sp,-96
    8000745e:	ec86                	sd	ra,88(sp)
    80007460:	e8a2                	sd	s0,80(sp)
    80007462:	e4a6                	sd	s1,72(sp)
    80007464:	e0ca                	sd	s2,64(sp)
    80007466:	fc4e                	sd	s3,56(sp)
    80007468:	f852                	sd	s4,48(sp)
    8000746a:	f456                	sd	s5,40(sp)
    8000746c:	f05a                	sd	s6,32(sp)
    8000746e:	ec5e                	sd	s7,24(sp)
    80007470:	e862                	sd	s8,16(sp)
    80007472:	e466                	sd	s9,8(sp)
    80007474:	e06a                	sd	s10,0(sp)
    80007476:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80007478:	00b56933          	or	s2,a0,a1
    8000747c:	00f97913          	andi	s2,s2,15
    80007480:	04091463          	bnez	s2,800074c8 <bd_mark+0x6c>
    80007484:	8baa                	mv	s7,a0
    80007486:	8c2e                	mv	s8,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80007488:	00027797          	auipc	a5,0x27
    8000748c:	c1878793          	addi	a5,a5,-1000 # 8002e0a0 <nsizes>
    80007490:	0007ab03          	lw	s6,0(a5)
    80007494:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80007496:	00027d17          	auipc	s10,0x27
    8000749a:	bfad0d13          	addi	s10,s10,-1030 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    8000749e:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    800074a0:	00027a17          	auipc	s4,0x27
    800074a4:	bf8a0a13          	addi	s4,s4,-1032 # 8002e098 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    800074a8:	07604563          	bgtz	s6,80007512 <bd_mark+0xb6>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    800074ac:	60e6                	ld	ra,88(sp)
    800074ae:	6446                	ld	s0,80(sp)
    800074b0:	64a6                	ld	s1,72(sp)
    800074b2:	6906                	ld	s2,64(sp)
    800074b4:	79e2                	ld	s3,56(sp)
    800074b6:	7a42                	ld	s4,48(sp)
    800074b8:	7aa2                	ld	s5,40(sp)
    800074ba:	7b02                	ld	s6,32(sp)
    800074bc:	6be2                	ld	s7,24(sp)
    800074be:	6c42                	ld	s8,16(sp)
    800074c0:	6ca2                	ld	s9,8(sp)
    800074c2:	6d02                	ld	s10,0(sp)
    800074c4:	6125                	addi	sp,sp,96
    800074c6:	8082                	ret
    panic("bd_mark");
    800074c8:	00002517          	auipc	a0,0x2
    800074cc:	93850513          	addi	a0,a0,-1736 # 80008e00 <userret+0xd70>
    800074d0:	ffff9097          	auipc	ra,0xffff9
    800074d4:	2b4080e7          	jalr	692(ra) # 80000784 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    800074d8:	000a3783          	ld	a5,0(s4)
    800074dc:	97ca                	add	a5,a5,s2
    800074de:	85a6                	mv	a1,s1
    800074e0:	6b88                	ld	a0,16(a5)
    800074e2:	00000097          	auipc	ra,0x0
    800074e6:	966080e7          	jalr	-1690(ra) # 80006e48 <bit_set>
    for(; bi < bj; bi++) {
    800074ea:	2485                	addiw	s1,s1,1
    800074ec:	009a8e63          	beq	s5,s1,80007508 <bd_mark+0xac>
      if(k > 0) {
    800074f0:	ff3054e3          	blez	s3,800074d8 <bd_mark+0x7c>
        bit_set(bd_sizes[k].split, bi);
    800074f4:	000a3783          	ld	a5,0(s4)
    800074f8:	97ca                	add	a5,a5,s2
    800074fa:	85a6                	mv	a1,s1
    800074fc:	6f88                	ld	a0,24(a5)
    800074fe:	00000097          	auipc	ra,0x0
    80007502:	94a080e7          	jalr	-1718(ra) # 80006e48 <bit_set>
    80007506:	bfc9                	j	800074d8 <bd_mark+0x7c>
  for (int k = 0; k < nsizes; k++) {
    80007508:	2985                	addiw	s3,s3,1
    8000750a:	02090913          	addi	s2,s2,32
    8000750e:	f9698fe3          	beq	s3,s6,800074ac <bd_mark+0x50>
  int n = p - (char *) bd_base;
    80007512:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80007516:	409b84bb          	subw	s1,s7,s1
    8000751a:	013c97b3          	sll	a5,s9,s3
    8000751e:	02f4c4b3          	div	s1,s1,a5
    80007522:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80007524:	85e2                	mv	a1,s8
    80007526:	854e                	mv	a0,s3
    80007528:	00000097          	auipc	ra,0x0
    8000752c:	ee6080e7          	jalr	-282(ra) # 8000740e <blk_index_next>
    80007530:	8aaa                	mv	s5,a0
    for(; bi < bj; bi++) {
    80007532:	faa4cfe3          	blt	s1,a0,800074f0 <bd_mark+0x94>
    80007536:	bfc9                	j	80007508 <bd_mark+0xac>

0000000080007538 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80007538:	7139                	addi	sp,sp,-64
    8000753a:	fc06                	sd	ra,56(sp)
    8000753c:	f822                	sd	s0,48(sp)
    8000753e:	f426                	sd	s1,40(sp)
    80007540:	f04a                	sd	s2,32(sp)
    80007542:	ec4e                	sd	s3,24(sp)
    80007544:	e852                	sd	s4,16(sp)
    80007546:	e456                	sd	s5,8(sp)
    80007548:	e05a                	sd	s6,0(sp)
    8000754a:	0080                	addi	s0,sp,64
    8000754c:	8b2a                	mv	s6,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000754e:	00058a1b          	sext.w	s4,a1
    80007552:	001a7793          	andi	a5,s4,1
    80007556:	ebbd                	bnez	a5,800075cc <bd_initfree_pair+0x94>
    80007558:	00158a9b          	addiw	s5,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    8000755c:	005b1493          	slli	s1,s6,0x5
    80007560:	00027797          	auipc	a5,0x27
    80007564:	b3878793          	addi	a5,a5,-1224 # 8002e098 <bd_sizes>
    80007568:	639c                	ld	a5,0(a5)
    8000756a:	94be                	add	s1,s1,a5
    8000756c:	0104b903          	ld	s2,16(s1)
    80007570:	854a                	mv	a0,s2
    80007572:	00000097          	auipc	ra,0x0
    80007576:	89e080e7          	jalr	-1890(ra) # 80006e10 <bit_isset>
    8000757a:	89aa                	mv	s3,a0
    8000757c:	85d6                	mv	a1,s5
    8000757e:	854a                	mv	a0,s2
    80007580:	00000097          	auipc	ra,0x0
    80007584:	890080e7          	jalr	-1904(ra) # 80006e10 <bit_isset>
  int free = 0;
    80007588:	4901                	li	s2,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    8000758a:	02a98663          	beq	s3,a0,800075b6 <bd_initfree_pair+0x7e>
    // one of the pair is free
    free = BLK_SIZE(k);
    8000758e:	45c1                	li	a1,16
    80007590:	016595b3          	sll	a1,a1,s6
    80007594:	0005891b          	sext.w	s2,a1
    if(bit_isset(bd_sizes[k].alloc, bi))
    80007598:	02098d63          	beqz	s3,800075d2 <bd_initfree_pair+0x9a>
  return (char *) bd_base + n;
    8000759c:	035585bb          	mulw	a1,a1,s5
    800075a0:	00027797          	auipc	a5,0x27
    800075a4:	af078793          	addi	a5,a5,-1296 # 8002e090 <bd_base>
    800075a8:	639c                	ld	a5,0(a5)
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    800075aa:	95be                	add	a1,a1,a5
    800075ac:	8526                	mv	a0,s1
    800075ae:	00000097          	auipc	ra,0x0
    800075b2:	4a0080e7          	jalr	1184(ra) # 80007a4e <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    800075b6:	854a                	mv	a0,s2
    800075b8:	70e2                	ld	ra,56(sp)
    800075ba:	7442                	ld	s0,48(sp)
    800075bc:	74a2                	ld	s1,40(sp)
    800075be:	7902                	ld	s2,32(sp)
    800075c0:	69e2                	ld	s3,24(sp)
    800075c2:	6a42                	ld	s4,16(sp)
    800075c4:	6aa2                	ld	s5,8(sp)
    800075c6:	6b02                	ld	s6,0(sp)
    800075c8:	6121                	addi	sp,sp,64
    800075ca:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800075cc:	fff58a9b          	addiw	s5,a1,-1
    800075d0:	b771                	j	8000755c <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    800075d2:	034585bb          	mulw	a1,a1,s4
    800075d6:	00027797          	auipc	a5,0x27
    800075da:	aba78793          	addi	a5,a5,-1350 # 8002e090 <bd_base>
    800075de:	639c                	ld	a5,0(a5)
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    800075e0:	95be                	add	a1,a1,a5
    800075e2:	8526                	mv	a0,s1
    800075e4:	00000097          	auipc	ra,0x0
    800075e8:	46a080e7          	jalr	1130(ra) # 80007a4e <lst_push>
    800075ec:	b7e9                	j	800075b6 <bd_initfree_pair+0x7e>

00000000800075ee <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    800075ee:	711d                	addi	sp,sp,-96
    800075f0:	ec86                	sd	ra,88(sp)
    800075f2:	e8a2                	sd	s0,80(sp)
    800075f4:	e4a6                	sd	s1,72(sp)
    800075f6:	e0ca                	sd	s2,64(sp)
    800075f8:	fc4e                	sd	s3,56(sp)
    800075fa:	f852                	sd	s4,48(sp)
    800075fc:	f456                	sd	s5,40(sp)
    800075fe:	f05a                	sd	s6,32(sp)
    80007600:	ec5e                	sd	s7,24(sp)
    80007602:	e862                	sd	s8,16(sp)
    80007604:	e466                	sd	s9,8(sp)
    80007606:	e06a                	sd	s10,0(sp)
    80007608:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    8000760a:	00027797          	auipc	a5,0x27
    8000760e:	a9678793          	addi	a5,a5,-1386 # 8002e0a0 <nsizes>
    80007612:	4398                	lw	a4,0(a5)
    80007614:	4785                	li	a5,1
    80007616:	06e7db63          	ble	a4,a5,8000768c <bd_initfree+0x9e>
    8000761a:	8b2e                	mv	s6,a1
    8000761c:	8aaa                	mv	s5,a0
    8000761e:	4901                	li	s2,0
  int free = 0;
    80007620:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80007622:	00027c97          	auipc	s9,0x27
    80007626:	a6ec8c93          	addi	s9,s9,-1426 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    8000762a:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    8000762c:	00027b97          	auipc	s7,0x27
    80007630:	a74b8b93          	addi	s7,s7,-1420 # 8002e0a0 <nsizes>
    80007634:	a039                	j	80007642 <bd_initfree+0x54>
    80007636:	2905                	addiw	s2,s2,1
    80007638:	000ba783          	lw	a5,0(s7)
    8000763c:	37fd                	addiw	a5,a5,-1
    8000763e:	04f95863          	ble	a5,s2,8000768e <bd_initfree+0xa0>
    int left = blk_index_next(k, bd_left);
    80007642:	85d6                	mv	a1,s5
    80007644:	854a                	mv	a0,s2
    80007646:	00000097          	auipc	ra,0x0
    8000764a:	dc8080e7          	jalr	-568(ra) # 8000740e <blk_index_next>
    8000764e:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80007650:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80007654:	409b04bb          	subw	s1,s6,s1
    80007658:	012c17b3          	sll	a5,s8,s2
    8000765c:	02f4c4b3          	div	s1,s1,a5
    80007660:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80007662:	85aa                	mv	a1,a0
    80007664:	854a                	mv	a0,s2
    80007666:	00000097          	auipc	ra,0x0
    8000766a:	ed2080e7          	jalr	-302(ra) # 80007538 <bd_initfree_pair>
    8000766e:	01450d3b          	addw	s10,a0,s4
    80007672:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80007676:	fc99d0e3          	ble	s1,s3,80007636 <bd_initfree+0x48>
      continue;
    free += bd_initfree_pair(k, right);
    8000767a:	85a6                	mv	a1,s1
    8000767c:	854a                	mv	a0,s2
    8000767e:	00000097          	auipc	ra,0x0
    80007682:	eba080e7          	jalr	-326(ra) # 80007538 <bd_initfree_pair>
    80007686:	00ad0a3b          	addw	s4,s10,a0
    8000768a:	b775                	j	80007636 <bd_initfree+0x48>
  int free = 0;
    8000768c:	4a01                	li	s4,0
  }
  return free;
}
    8000768e:	8552                	mv	a0,s4
    80007690:	60e6                	ld	ra,88(sp)
    80007692:	6446                	ld	s0,80(sp)
    80007694:	64a6                	ld	s1,72(sp)
    80007696:	6906                	ld	s2,64(sp)
    80007698:	79e2                	ld	s3,56(sp)
    8000769a:	7a42                	ld	s4,48(sp)
    8000769c:	7aa2                	ld	s5,40(sp)
    8000769e:	7b02                	ld	s6,32(sp)
    800076a0:	6be2                	ld	s7,24(sp)
    800076a2:	6c42                	ld	s8,16(sp)
    800076a4:	6ca2                	ld	s9,8(sp)
    800076a6:	6d02                	ld	s10,0(sp)
    800076a8:	6125                	addi	sp,sp,96
    800076aa:	8082                	ret

00000000800076ac <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    800076ac:	7179                	addi	sp,sp,-48
    800076ae:	f406                	sd	ra,40(sp)
    800076b0:	f022                	sd	s0,32(sp)
    800076b2:	ec26                	sd	s1,24(sp)
    800076b4:	e84a                	sd	s2,16(sp)
    800076b6:	e44e                	sd	s3,8(sp)
    800076b8:	1800                	addi	s0,sp,48
    800076ba:	89aa                	mv	s3,a0
  int meta = p - (char*)bd_base;
    800076bc:	00027917          	auipc	s2,0x27
    800076c0:	9d490913          	addi	s2,s2,-1580 # 8002e090 <bd_base>
    800076c4:	00093483          	ld	s1,0(s2)
    800076c8:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    800076cc:	00027797          	auipc	a5,0x27
    800076d0:	9d478793          	addi	a5,a5,-1580 # 8002e0a0 <nsizes>
    800076d4:	439c                	lw	a5,0(a5)
    800076d6:	37fd                	addiw	a5,a5,-1
    800076d8:	4641                	li	a2,16
    800076da:	00f61633          	sll	a2,a2,a5
    800076de:	85a6                	mv	a1,s1
    800076e0:	00001517          	auipc	a0,0x1
    800076e4:	72850513          	addi	a0,a0,1832 # 80008e08 <userret+0xd78>
    800076e8:	ffff9097          	auipc	ra,0xffff9
    800076ec:	2b4080e7          	jalr	692(ra) # 8000099c <printf>
  bd_mark(bd_base, p);
    800076f0:	85ce                	mv	a1,s3
    800076f2:	00093503          	ld	a0,0(s2)
    800076f6:	00000097          	auipc	ra,0x0
    800076fa:	d66080e7          	jalr	-666(ra) # 8000745c <bd_mark>
  return meta;
}
    800076fe:	8526                	mv	a0,s1
    80007700:	70a2                	ld	ra,40(sp)
    80007702:	7402                	ld	s0,32(sp)
    80007704:	64e2                	ld	s1,24(sp)
    80007706:	6942                	ld	s2,16(sp)
    80007708:	69a2                	ld	s3,8(sp)
    8000770a:	6145                	addi	sp,sp,48
    8000770c:	8082                	ret

000000008000770e <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    8000770e:	1101                	addi	sp,sp,-32
    80007710:	ec06                	sd	ra,24(sp)
    80007712:	e822                	sd	s0,16(sp)
    80007714:	e426                	sd	s1,8(sp)
    80007716:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80007718:	00027797          	auipc	a5,0x27
    8000771c:	98878793          	addi	a5,a5,-1656 # 8002e0a0 <nsizes>
    80007720:	4384                	lw	s1,0(a5)
    80007722:	fff4879b          	addiw	a5,s1,-1
    80007726:	44c1                	li	s1,16
    80007728:	00f494b3          	sll	s1,s1,a5
    8000772c:	00027797          	auipc	a5,0x27
    80007730:	96478793          	addi	a5,a5,-1692 # 8002e090 <bd_base>
    80007734:	639c                	ld	a5,0(a5)
    80007736:	8d1d                	sub	a0,a0,a5
    80007738:	40a4853b          	subw	a0,s1,a0
    8000773c:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80007740:	00905a63          	blez	s1,80007754 <bd_mark_unavailable+0x46>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80007744:	357d                	addiw	a0,a0,-1
    80007746:	41f5549b          	sraiw	s1,a0,0x1f
    8000774a:	01c4d49b          	srliw	s1,s1,0x1c
    8000774e:	9ca9                	addw	s1,s1,a0
    80007750:	98c1                	andi	s1,s1,-16
    80007752:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80007754:	85a6                	mv	a1,s1
    80007756:	00001517          	auipc	a0,0x1
    8000775a:	6ea50513          	addi	a0,a0,1770 # 80008e40 <userret+0xdb0>
    8000775e:	ffff9097          	auipc	ra,0xffff9
    80007762:	23e080e7          	jalr	574(ra) # 8000099c <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007766:	00027797          	auipc	a5,0x27
    8000776a:	92a78793          	addi	a5,a5,-1750 # 8002e090 <bd_base>
    8000776e:	6398                	ld	a4,0(a5)
    80007770:	00027797          	auipc	a5,0x27
    80007774:	93078793          	addi	a5,a5,-1744 # 8002e0a0 <nsizes>
    80007778:	438c                	lw	a1,0(a5)
    8000777a:	fff5879b          	addiw	a5,a1,-1
    8000777e:	45c1                	li	a1,16
    80007780:	00f595b3          	sll	a1,a1,a5
    80007784:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80007788:	95ba                	add	a1,a1,a4
    8000778a:	953a                	add	a0,a0,a4
    8000778c:	00000097          	auipc	ra,0x0
    80007790:	cd0080e7          	jalr	-816(ra) # 8000745c <bd_mark>
  return unavailable;
}
    80007794:	8526                	mv	a0,s1
    80007796:	60e2                	ld	ra,24(sp)
    80007798:	6442                	ld	s0,16(sp)
    8000779a:	64a2                	ld	s1,8(sp)
    8000779c:	6105                	addi	sp,sp,32
    8000779e:	8082                	ret

00000000800077a0 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    800077a0:	715d                	addi	sp,sp,-80
    800077a2:	e486                	sd	ra,72(sp)
    800077a4:	e0a2                	sd	s0,64(sp)
    800077a6:	fc26                	sd	s1,56(sp)
    800077a8:	f84a                	sd	s2,48(sp)
    800077aa:	f44e                	sd	s3,40(sp)
    800077ac:	f052                	sd	s4,32(sp)
    800077ae:	ec56                	sd	s5,24(sp)
    800077b0:	e85a                	sd	s6,16(sp)
    800077b2:	e45e                	sd	s7,8(sp)
    800077b4:	e062                	sd	s8,0(sp)
    800077b6:	0880                	addi	s0,sp,80
    800077b8:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    800077ba:	fff50493          	addi	s1,a0,-1
    800077be:	98c1                	andi	s1,s1,-16
    800077c0:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    800077c2:	00001597          	auipc	a1,0x1
    800077c6:	69e58593          	addi	a1,a1,1694 # 80008e60 <userret+0xdd0>
    800077ca:	00027517          	auipc	a0,0x27
    800077ce:	83650513          	addi	a0,a0,-1994 # 8002e000 <lock>
    800077d2:	ffff9097          	auipc	ra,0xffff9
    800077d6:	37a080e7          	jalr	890(ra) # 80000b4c <initlock>
  bd_base = (void *) p;
    800077da:	00027797          	auipc	a5,0x27
    800077de:	8a97bb23          	sd	s1,-1866(a5) # 8002e090 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    800077e2:	409c0933          	sub	s2,s8,s1
    800077e6:	43f95513          	srai	a0,s2,0x3f
    800077ea:	893d                	andi	a0,a0,15
    800077ec:	954a                	add	a0,a0,s2
    800077ee:	8511                	srai	a0,a0,0x4
    800077f0:	00000097          	auipc	ra,0x0
    800077f4:	c4a080e7          	jalr	-950(ra) # 8000743a <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    800077f8:	47c1                	li	a5,16
    800077fa:	00a797b3          	sll	a5,a5,a0
    800077fe:	1b27c863          	blt	a5,s2,800079ae <bd_init+0x20e>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007802:	2505                	addiw	a0,a0,1
    80007804:	00027797          	auipc	a5,0x27
    80007808:	88a7ae23          	sw	a0,-1892(a5) # 8002e0a0 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    8000780c:	00027997          	auipc	s3,0x27
    80007810:	89498993          	addi	s3,s3,-1900 # 8002e0a0 <nsizes>
    80007814:	0009a603          	lw	a2,0(s3)
    80007818:	85ca                	mv	a1,s2
    8000781a:	00001517          	auipc	a0,0x1
    8000781e:	64e50513          	addi	a0,a0,1614 # 80008e68 <userret+0xdd8>
    80007822:	ffff9097          	auipc	ra,0xffff9
    80007826:	17a080e7          	jalr	378(ra) # 8000099c <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    8000782a:	00027797          	auipc	a5,0x27
    8000782e:	8697b723          	sd	s1,-1938(a5) # 8002e098 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80007832:	0009a603          	lw	a2,0(s3)
    80007836:	00561913          	slli	s2,a2,0x5
    8000783a:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    8000783c:	0056161b          	slliw	a2,a2,0x5
    80007840:	4581                	li	a1,0
    80007842:	8526                	mv	a0,s1
    80007844:	ffffa097          	auipc	ra,0xffffa
    80007848:	8ea080e7          	jalr	-1814(ra) # 8000112e <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    8000784c:	0009a783          	lw	a5,0(s3)
    80007850:	06f05a63          	blez	a5,800078c4 <bd_init+0x124>
    80007854:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80007856:	00027a97          	auipc	s5,0x27
    8000785a:	842a8a93          	addi	s5,s5,-1982 # 8002e098 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    8000785e:	00027a17          	auipc	s4,0x27
    80007862:	842a0a13          	addi	s4,s4,-1982 # 8002e0a0 <nsizes>
    80007866:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80007868:	00599b93          	slli	s7,s3,0x5
    8000786c:	000ab503          	ld	a0,0(s5)
    80007870:	955e                	add	a0,a0,s7
    80007872:	00000097          	auipc	ra,0x0
    80007876:	16a080e7          	jalr	362(ra) # 800079dc <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    8000787a:	000a2483          	lw	s1,0(s4)
    8000787e:	34fd                	addiw	s1,s1,-1
    80007880:	413484bb          	subw	s1,s1,s3
    80007884:	009b14bb          	sllw	s1,s6,s1
    80007888:	fff4879b          	addiw	a5,s1,-1
    8000788c:	41f7d49b          	sraiw	s1,a5,0x1f
    80007890:	01d4d49b          	srliw	s1,s1,0x1d
    80007894:	9cbd                	addw	s1,s1,a5
    80007896:	98e1                	andi	s1,s1,-8
    80007898:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    8000789a:	000ab783          	ld	a5,0(s5)
    8000789e:	9bbe                	add	s7,s7,a5
    800078a0:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    800078a4:	848d                	srai	s1,s1,0x3
    800078a6:	8626                	mv	a2,s1
    800078a8:	4581                	li	a1,0
    800078aa:	854a                	mv	a0,s2
    800078ac:	ffffa097          	auipc	ra,0xffffa
    800078b0:	882080e7          	jalr	-1918(ra) # 8000112e <memset>
    p += sz;
    800078b4:	9926                	add	s2,s2,s1
    800078b6:	0985                	addi	s3,s3,1
  for (int k = 0; k < nsizes; k++) {
    800078b8:	000a2703          	lw	a4,0(s4)
    800078bc:	0009879b          	sext.w	a5,s3
    800078c0:	fae7c4e3          	blt	a5,a4,80007868 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    800078c4:	00026797          	auipc	a5,0x26
    800078c8:	7dc78793          	addi	a5,a5,2012 # 8002e0a0 <nsizes>
    800078cc:	439c                	lw	a5,0(a5)
    800078ce:	4705                	li	a4,1
    800078d0:	06f75163          	ble	a5,a4,80007932 <bd_init+0x192>
    800078d4:	02000a13          	li	s4,32
    800078d8:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    800078da:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    800078dc:	00026b17          	auipc	s6,0x26
    800078e0:	7bcb0b13          	addi	s6,s6,1980 # 8002e098 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    800078e4:	00026a97          	auipc	s5,0x26
    800078e8:	7bca8a93          	addi	s5,s5,1980 # 8002e0a0 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    800078ec:	37fd                	addiw	a5,a5,-1
    800078ee:	413787bb          	subw	a5,a5,s3
    800078f2:	00fb94bb          	sllw	s1,s7,a5
    800078f6:	fff4879b          	addiw	a5,s1,-1
    800078fa:	41f7d49b          	sraiw	s1,a5,0x1f
    800078fe:	01d4d49b          	srliw	s1,s1,0x1d
    80007902:	9cbd                	addw	s1,s1,a5
    80007904:	98e1                	andi	s1,s1,-8
    80007906:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007908:	000b3783          	ld	a5,0(s6)
    8000790c:	97d2                	add	a5,a5,s4
    8000790e:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007912:	848d                	srai	s1,s1,0x3
    80007914:	8626                	mv	a2,s1
    80007916:	4581                	li	a1,0
    80007918:	854a                	mv	a0,s2
    8000791a:	ffffa097          	auipc	ra,0xffffa
    8000791e:	814080e7          	jalr	-2028(ra) # 8000112e <memset>
    p += sz;
    80007922:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80007924:	2985                	addiw	s3,s3,1
    80007926:	000aa783          	lw	a5,0(s5)
    8000792a:	020a0a13          	addi	s4,s4,32
    8000792e:	faf9cfe3          	blt	s3,a5,800078ec <bd_init+0x14c>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80007932:	197d                	addi	s2,s2,-1
    80007934:	ff097913          	andi	s2,s2,-16
    80007938:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    8000793a:	854a                	mv	a0,s2
    8000793c:	00000097          	auipc	ra,0x0
    80007940:	d70080e7          	jalr	-656(ra) # 800076ac <bd_mark_data_structures>
    80007944:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80007946:	85ca                	mv	a1,s2
    80007948:	8562                	mv	a0,s8
    8000794a:	00000097          	auipc	ra,0x0
    8000794e:	dc4080e7          	jalr	-572(ra) # 8000770e <bd_mark_unavailable>
    80007952:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007954:	00026a97          	auipc	s5,0x26
    80007958:	74ca8a93          	addi	s5,s5,1868 # 8002e0a0 <nsizes>
    8000795c:	000aa783          	lw	a5,0(s5)
    80007960:	37fd                	addiw	a5,a5,-1
    80007962:	44c1                	li	s1,16
    80007964:	00f497b3          	sll	a5,s1,a5
    80007968:	8f89                	sub	a5,a5,a0
    8000796a:	00026717          	auipc	a4,0x26
    8000796e:	72670713          	addi	a4,a4,1830 # 8002e090 <bd_base>
    80007972:	630c                	ld	a1,0(a4)
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80007974:	95be                	add	a1,a1,a5
    80007976:	854a                	mv	a0,s2
    80007978:	00000097          	auipc	ra,0x0
    8000797c:	c76080e7          	jalr	-906(ra) # 800075ee <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80007980:	000aa603          	lw	a2,0(s5)
    80007984:	367d                	addiw	a2,a2,-1
    80007986:	00c49633          	sll	a2,s1,a2
    8000798a:	41460633          	sub	a2,a2,s4
    8000798e:	41360633          	sub	a2,a2,s3
    80007992:	02c51463          	bne	a0,a2,800079ba <bd_init+0x21a>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80007996:	60a6                	ld	ra,72(sp)
    80007998:	6406                	ld	s0,64(sp)
    8000799a:	74e2                	ld	s1,56(sp)
    8000799c:	7942                	ld	s2,48(sp)
    8000799e:	79a2                	ld	s3,40(sp)
    800079a0:	7a02                	ld	s4,32(sp)
    800079a2:	6ae2                	ld	s5,24(sp)
    800079a4:	6b42                	ld	s6,16(sp)
    800079a6:	6ba2                	ld	s7,8(sp)
    800079a8:	6c02                	ld	s8,0(sp)
    800079aa:	6161                	addi	sp,sp,80
    800079ac:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800079ae:	2509                	addiw	a0,a0,2
    800079b0:	00026797          	auipc	a5,0x26
    800079b4:	6ea7a823          	sw	a0,1776(a5) # 8002e0a0 <nsizes>
    800079b8:	bd91                	j	8000780c <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    800079ba:	85aa                	mv	a1,a0
    800079bc:	00001517          	auipc	a0,0x1
    800079c0:	4ec50513          	addi	a0,a0,1260 # 80008ea8 <userret+0xe18>
    800079c4:	ffff9097          	auipc	ra,0xffff9
    800079c8:	fd8080e7          	jalr	-40(ra) # 8000099c <printf>
    panic("bd_init: free mem");
    800079cc:	00001517          	auipc	a0,0x1
    800079d0:	4ec50513          	addi	a0,a0,1260 # 80008eb8 <userret+0xe28>
    800079d4:	ffff9097          	auipc	ra,0xffff9
    800079d8:	db0080e7          	jalr	-592(ra) # 80000784 <panic>

00000000800079dc <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    800079dc:	1141                	addi	sp,sp,-16
    800079de:	e422                	sd	s0,8(sp)
    800079e0:	0800                	addi	s0,sp,16
  lst->next = lst;
    800079e2:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    800079e4:	e508                	sd	a0,8(a0)
}
    800079e6:	6422                	ld	s0,8(sp)
    800079e8:	0141                	addi	sp,sp,16
    800079ea:	8082                	ret

00000000800079ec <lst_empty>:

int
lst_empty(struct list *lst) {
    800079ec:	1141                	addi	sp,sp,-16
    800079ee:	e422                	sd	s0,8(sp)
    800079f0:	0800                	addi	s0,sp,16
  return lst->next == lst;
    800079f2:	611c                	ld	a5,0(a0)
    800079f4:	40a78533          	sub	a0,a5,a0
}
    800079f8:	00153513          	seqz	a0,a0
    800079fc:	6422                	ld	s0,8(sp)
    800079fe:	0141                	addi	sp,sp,16
    80007a00:	8082                	ret

0000000080007a02 <lst_remove>:

void
lst_remove(struct list *e) {
    80007a02:	1141                	addi	sp,sp,-16
    80007a04:	e422                	sd	s0,8(sp)
    80007a06:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007a08:	6518                	ld	a4,8(a0)
    80007a0a:	611c                	ld	a5,0(a0)
    80007a0c:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80007a0e:	6518                	ld	a4,8(a0)
    80007a10:	e798                	sd	a4,8(a5)
}
    80007a12:	6422                	ld	s0,8(sp)
    80007a14:	0141                	addi	sp,sp,16
    80007a16:	8082                	ret

0000000080007a18 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007a18:	1101                	addi	sp,sp,-32
    80007a1a:	ec06                	sd	ra,24(sp)
    80007a1c:	e822                	sd	s0,16(sp)
    80007a1e:	e426                	sd	s1,8(sp)
    80007a20:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007a22:	6104                	ld	s1,0(a0)
    80007a24:	00a48d63          	beq	s1,a0,80007a3e <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007a28:	8526                	mv	a0,s1
    80007a2a:	00000097          	auipc	ra,0x0
    80007a2e:	fd8080e7          	jalr	-40(ra) # 80007a02 <lst_remove>
  return (void *)p;
}
    80007a32:	8526                	mv	a0,s1
    80007a34:	60e2                	ld	ra,24(sp)
    80007a36:	6442                	ld	s0,16(sp)
    80007a38:	64a2                	ld	s1,8(sp)
    80007a3a:	6105                	addi	sp,sp,32
    80007a3c:	8082                	ret
    panic("lst_pop");
    80007a3e:	00001517          	auipc	a0,0x1
    80007a42:	49250513          	addi	a0,a0,1170 # 80008ed0 <userret+0xe40>
    80007a46:	ffff9097          	auipc	ra,0xffff9
    80007a4a:	d3e080e7          	jalr	-706(ra) # 80000784 <panic>

0000000080007a4e <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80007a4e:	1141                	addi	sp,sp,-16
    80007a50:	e422                	sd	s0,8(sp)
    80007a52:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80007a54:	611c                	ld	a5,0(a0)
    80007a56:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80007a58:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007a5a:	611c                	ld	a5,0(a0)
    80007a5c:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80007a5e:	e10c                	sd	a1,0(a0)
}
    80007a60:	6422                	ld	s0,8(sp)
    80007a62:	0141                	addi	sp,sp,16
    80007a64:	8082                	ret

0000000080007a66 <lst_print>:

void
lst_print(struct list *lst)
{
    80007a66:	7179                	addi	sp,sp,-48
    80007a68:	f406                	sd	ra,40(sp)
    80007a6a:	f022                	sd	s0,32(sp)
    80007a6c:	ec26                	sd	s1,24(sp)
    80007a6e:	e84a                	sd	s2,16(sp)
    80007a70:	e44e                	sd	s3,8(sp)
    80007a72:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007a74:	6104                	ld	s1,0(a0)
    80007a76:	02950063          	beq	a0,s1,80007a96 <lst_print+0x30>
    80007a7a:	892a                	mv	s2,a0
    printf(" %p", p);
    80007a7c:	00001997          	auipc	s3,0x1
    80007a80:	45c98993          	addi	s3,s3,1116 # 80008ed8 <userret+0xe48>
    80007a84:	85a6                	mv	a1,s1
    80007a86:	854e                	mv	a0,s3
    80007a88:	ffff9097          	auipc	ra,0xffff9
    80007a8c:	f14080e7          	jalr	-236(ra) # 8000099c <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007a90:	6084                	ld	s1,0(s1)
    80007a92:	fe9919e3          	bne	s2,s1,80007a84 <lst_print+0x1e>
  }
  printf("\n");
    80007a96:	00001517          	auipc	a0,0x1
    80007a9a:	bb250513          	addi	a0,a0,-1102 # 80008648 <userret+0x5b8>
    80007a9e:	ffff9097          	auipc	ra,0xffff9
    80007aa2:	efe080e7          	jalr	-258(ra) # 8000099c <printf>
}
    80007aa6:	70a2                	ld	ra,40(sp)
    80007aa8:	7402                	ld	s0,32(sp)
    80007aaa:	64e2                	ld	s1,24(sp)
    80007aac:	6942                	ld	s2,16(sp)
    80007aae:	69a2                	ld	s3,8(sp)
    80007ab0:	6145                	addi	sp,sp,48
    80007ab2:	8082                	ret

0000000080007ab4 <watchdogwrite>:
int watchdog_time;
struct spinlock watchdog_lock;

int
watchdogwrite(struct file *f, int user_src, uint64 src, int n)
{
    80007ab4:	715d                	addi	sp,sp,-80
    80007ab6:	e486                	sd	ra,72(sp)
    80007ab8:	e0a2                	sd	s0,64(sp)
    80007aba:	fc26                	sd	s1,56(sp)
    80007abc:	f84a                	sd	s2,48(sp)
    80007abe:	f44e                	sd	s3,40(sp)
    80007ac0:	f052                	sd	s4,32(sp)
    80007ac2:	ec56                	sd	s5,24(sp)
    80007ac4:	0880                	addi	s0,sp,80
    80007ac6:	8a2e                	mv	s4,a1
    80007ac8:	84b2                	mv	s1,a2
    80007aca:	89b6                	mv	s3,a3
  acquire(&watchdog_lock);
    80007acc:	00026517          	auipc	a0,0x26
    80007ad0:	56450513          	addi	a0,a0,1380 # 8002e030 <watchdog_lock>
    80007ad4:	ffff9097          	auipc	ra,0xffff9
    80007ad8:	1e6080e7          	jalr	486(ra) # 80000cba <acquire>

  int time = 0;
  for(int i = 0; i < n; i++){
    80007adc:	09305e63          	blez	s3,80007b78 <watchdogwrite+0xc4>
    80007ae0:	00148913          	addi	s2,s1,1
    80007ae4:	39fd                	addiw	s3,s3,-1
    80007ae6:	1982                	slli	s3,s3,0x20
    80007ae8:	0209d993          	srli	s3,s3,0x20
    80007aec:	994e                	add	s2,s2,s3
  int time = 0;
    80007aee:	4981                	li	s3,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80007af0:	5afd                	li	s5,-1
    80007af2:	4685                	li	a3,1
    80007af4:	8626                	mv	a2,s1
    80007af6:	85d2                	mv	a1,s4
    80007af8:	fbf40513          	addi	a0,s0,-65
    80007afc:	ffffb097          	auipc	ra,0xffffb
    80007b00:	0ee080e7          	jalr	238(ra) # 80002bea <either_copyin>
    80007b04:	01550763          	beq	a0,s5,80007b12 <watchdogwrite+0x5e>
      break;
    time = c;
    80007b08:	fbf44983          	lbu	s3,-65(s0)
    80007b0c:	0485                	addi	s1,s1,1
  for(int i = 0; i < n; i++){
    80007b0e:	ff2492e3          	bne	s1,s2,80007af2 <watchdogwrite+0x3e>
  }

  acquire(&tickslock);
    80007b12:	00014517          	auipc	a0,0x14
    80007b16:	58650513          	addi	a0,a0,1414 # 8001c098 <tickslock>
    80007b1a:	ffff9097          	auipc	ra,0xffff9
    80007b1e:	1a0080e7          	jalr	416(ra) # 80000cba <acquire>
  n = ticks - watchdog_value;
    80007b22:	00026797          	auipc	a5,0x26
    80007b26:	56678793          	addi	a5,a5,1382 # 8002e088 <ticks>
    80007b2a:	4398                	lw	a4,0(a5)
    80007b2c:	00026797          	auipc	a5,0x26
    80007b30:	57c78793          	addi	a5,a5,1404 # 8002e0a8 <watchdog_value>
    80007b34:	4384                	lw	s1,0(a5)
    80007b36:	409704bb          	subw	s1,a4,s1
  watchdog_value = ticks;
    80007b3a:	c398                	sw	a4,0(a5)
  watchdog_time = time;
    80007b3c:	00026797          	auipc	a5,0x26
    80007b40:	5737a423          	sw	s3,1384(a5) # 8002e0a4 <watchdog_time>
  release(&tickslock);
    80007b44:	00014517          	auipc	a0,0x14
    80007b48:	55450513          	addi	a0,a0,1364 # 8001c098 <tickslock>
    80007b4c:	ffff9097          	auipc	ra,0xffff9
    80007b50:	3ba080e7          	jalr	954(ra) # 80000f06 <release>

  release(&watchdog_lock);
    80007b54:	00026517          	auipc	a0,0x26
    80007b58:	4dc50513          	addi	a0,a0,1244 # 8002e030 <watchdog_lock>
    80007b5c:	ffff9097          	auipc	ra,0xffff9
    80007b60:	3aa080e7          	jalr	938(ra) # 80000f06 <release>
  return n;
}
    80007b64:	8526                	mv	a0,s1
    80007b66:	60a6                	ld	ra,72(sp)
    80007b68:	6406                	ld	s0,64(sp)
    80007b6a:	74e2                	ld	s1,56(sp)
    80007b6c:	7942                	ld	s2,48(sp)
    80007b6e:	79a2                	ld	s3,40(sp)
    80007b70:	7a02                	ld	s4,32(sp)
    80007b72:	6ae2                	ld	s5,24(sp)
    80007b74:	6161                	addi	sp,sp,80
    80007b76:	8082                	ret
  int time = 0;
    80007b78:	4981                	li	s3,0
    80007b7a:	bf61                	j	80007b12 <watchdogwrite+0x5e>

0000000080007b7c <watchdoginit>:

void watchdoginit(){
    80007b7c:	1141                	addi	sp,sp,-16
    80007b7e:	e406                	sd	ra,8(sp)
    80007b80:	e022                	sd	s0,0(sp)
    80007b82:	0800                	addi	s0,sp,16
  initlock(&watchdog_lock, "watchdog_lock");
    80007b84:	00001597          	auipc	a1,0x1
    80007b88:	35c58593          	addi	a1,a1,860 # 80008ee0 <userret+0xe50>
    80007b8c:	00026517          	auipc	a0,0x26
    80007b90:	4a450513          	addi	a0,a0,1188 # 8002e030 <watchdog_lock>
    80007b94:	ffff9097          	auipc	ra,0xffff9
    80007b98:	fb8080e7          	jalr	-72(ra) # 80000b4c <initlock>
  watchdog_time = 0;
    80007b9c:	00026797          	auipc	a5,0x26
    80007ba0:	5007a423          	sw	zero,1288(a5) # 8002e0a4 <watchdog_time>


  devsw[WATCHDOG].read = 0;
    80007ba4:	0001f797          	auipc	a5,0x1f
    80007ba8:	ff478793          	addi	a5,a5,-12 # 80026b98 <devsw>
    80007bac:	0207b023          	sd	zero,32(a5)
  devsw[WATCHDOG].write = watchdogwrite;
    80007bb0:	00000717          	auipc	a4,0x0
    80007bb4:	f0470713          	addi	a4,a4,-252 # 80007ab4 <watchdogwrite>
    80007bb8:	f798                	sd	a4,40(a5)
}
    80007bba:	60a2                	ld	ra,8(sp)
    80007bbc:	6402                	ld	s0,0(sp)
    80007bbe:	0141                	addi	sp,sp,16
    80007bc0:	8082                	ret
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
