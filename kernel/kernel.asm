
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
    80000062:	54278793          	addi	a5,a5,1346 # 800065a0 <timervec>
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
    8000016a:	6de080e7          	jalr	1758(ra) # 80002844 <sleep>
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
    800001d8:	670080e7          	jalr	1648(ra) # 80002844 <sleep>
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
    80000216:	894080e7          	jalr	-1900(ra) # 80002aa6 <either_copyout>
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
    8000034c:	4fc080e7          	jalr	1276(ra) # 80002844 <sleep>
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
    80000396:	00002097          	auipc	ra,0x2
    8000039a:	766080e7          	jalr	1894(ra) # 80002afc <either_copyin>
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
    8000047e:	550080e7          	jalr	1360(ra) # 800029ca <wakeup>
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
    8000058e:	5c8080e7          	jalr	1480(ra) # 80002b52 <procdump>
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
    800005b8:	65a080e7          	jalr	1626(ra) # 80002c0e <priodump>
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
    8000062e:	3a0080e7          	jalr	928(ra) # 800029ca <wakeup>
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
    80000b0e:	b96080e7          	jalr	-1130(ra) # 800076a0 <bd_init>
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
    80000b26:	6aa080e7          	jalr	1706(ra) # 800071cc <bd_free>
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
    80000b40:	48c080e7          	jalr	1164(ra) # 80006fc8 <bd_malloc>
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
    80000d9e:	db8080e7          	jalr	-584(ra) # 80002b52 <procdump>
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
    80000dce:	d88080e7          	jalr	-632(ra) # 80002b52 <procdump>
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
    80000f9a:	300080e7          	jalr	768(ra) # 80003296 <argint>
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
    8000133a:	c92080e7          	jalr	-878(ra) # 80006fc8 <bd_malloc>
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
    800013c2:	c0a080e7          	jalr	-1014(ra) # 80006fc8 <bd_malloc>
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
    8000142e:	99a080e7          	jalr	-1638(ra) # 80002dc4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001432:	00005097          	auipc	ra,0x5
    80001436:	1ae080e7          	jalr	430(ra) # 800065e0 <plicinithart>
  }

  scheduler();        
    8000143a:	00001097          	auipc	ra,0x1
    8000143e:	124080e7          	jalr	292(ra) # 8000255e <scheduler>
    consoleinit();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	1f2080e7          	jalr	498(ra) # 80000634 <consoleinit>
    watchdoginit();
    8000144a:	00006097          	auipc	ra,0x6
    8000144e:	632080e7          	jalr	1586(ra) # 80007a7c <watchdoginit>
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
    800014ae:	8f2080e7          	jalr	-1806(ra) # 80002d9c <trapinit>
    trapinithart();  // install kernel trap vector
    800014b2:	00002097          	auipc	ra,0x2
    800014b6:	912080e7          	jalr	-1774(ra) # 80002dc4 <trapinithart>
    plicinit();      // set up interrupt controller
    800014ba:	00005097          	auipc	ra,0x5
    800014be:	110080e7          	jalr	272(ra) # 800065ca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800014c2:	00005097          	auipc	ra,0x5
    800014c6:	11e080e7          	jalr	286(ra) # 800065e0 <plicinithart>
    binit();         // buffer cache
    800014ca:	00002097          	auipc	ra,0x2
    800014ce:	0c4080e7          	jalr	196(ra) # 8000358e <binit>
    iinit();         // inode cache
    800014d2:	00002097          	auipc	ra,0x2
    800014d6:	79a080e7          	jalr	1946(ra) # 80003c6c <iinit>
    fileinit();      // file table
    800014da:	00004097          	auipc	ra,0x4
    800014de:	82c080e7          	jalr	-2004(ra) # 80004d06 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    800014e2:	4501                	li	a0,0
    800014e4:	00005097          	auipc	ra,0x5
    800014e8:	21c080e7          	jalr	540(ra) # 80006700 <virtio_disk_init>
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
    80001e58:	174080e7          	jalr	372(ra) # 80006fc8 <bd_malloc>
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
    80001eea:	2e6080e7          	jalr	742(ra) # 800071cc <bd_free>
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
    80002094:	fc878793          	addi	a5,a5,-56 # 8000a058 <first.1807>
    80002098:	439c                	lw	a5,0(a5)
    8000209a:	eb89                	bnez	a5,800020ac <forkret+0x34>
  usertrapret();
    8000209c:	00001097          	auipc	ra,0x1
    800020a0:	d40080e7          	jalr	-704(ra) # 80002ddc <usertrapret>
}
    800020a4:	60a2                	ld	ra,8(sp)
    800020a6:	6402                	ld	s0,0(sp)
    800020a8:	0141                	addi	sp,sp,16
    800020aa:	8082                	ret
    first = 0;
    800020ac:	00008797          	auipc	a5,0x8
    800020b0:	fa07a623          	sw	zero,-84(a5) # 8000a058 <first.1807>
    fsinit(minor(ROOTDEV));
    800020b4:	4501                	li	a0,0
    800020b6:	00002097          	auipc	ra,0x2
    800020ba:	b38080e7          	jalr	-1224(ra) # 80003bee <fsinit>
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
    80002296:	f3a080e7          	jalr	-198(ra) # 800071cc <bd_free>
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
    800022d8:	1000                	addi	s0,sp,32
  p = allocproc();
    800022da:	00000097          	auipc	ra,0x0
    800022de:	e88080e7          	jalr	-376(ra) # 80002162 <allocproc>
    800022e2:	84aa                	mv	s1,a0
  initproc = p;
    800022e4:	0002c797          	auipc	a5,0x2c
    800022e8:	d8a7be23          	sd	a0,-612(a5) # 8002e080 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800022ec:	03300613          	li	a2,51
    800022f0:	00008597          	auipc	a1,0x8
    800022f4:	d1058593          	addi	a1,a1,-752 # 8000a000 <initcode>
    800022f8:	7528                	ld	a0,104(a0)
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	694080e7          	jalr	1684(ra) # 8000198e <uvminit>
  p->sz = PGSIZE;
    80002302:	6785                	lui	a5,0x1
    80002304:	f0bc                	sd	a5,96(s1)
  p->tf->epc = 0;      // user program counter
    80002306:	78b8                	ld	a4,112(s1)
    80002308:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    8000230c:	78b8                	ld	a4,112(s1)
    8000230e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002310:	4641                	li	a2,16
    80002312:	00006597          	auipc	a1,0x6
    80002316:	28e58593          	addi	a1,a1,654 # 800085a0 <userret+0x510>
    8000231a:	17048513          	addi	a0,s1,368
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	f88080e7          	jalr	-120(ra) # 800012a6 <safestrcpy>
  p->cmd = strdup("init");
    80002326:	00006517          	auipc	a0,0x6
    8000232a:	28a50513          	addi	a0,a0,650 # 800085b0 <userret+0x520>
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	072080e7          	jalr	114(ra) # 800013a0 <strdup>
    80002336:	18a4b023          	sd	a0,384(s1)
  p->cwd = namei("/");
    8000233a:	00006517          	auipc	a0,0x6
    8000233e:	27e50513          	addi	a0,a0,638 # 800085b8 <userret+0x528>
    80002342:	00002097          	auipc	ra,0x2
    80002346:	2ba080e7          	jalr	698(ra) # 800045fc <namei>
    8000234a:	16a4b423          	sd	a0,360(s1)
  p->state = RUNNABLE;
    8000234e:	4789                	li	a5,2
    80002350:	d89c                	sw	a5,48(s1)
  release(&p->lock);
    80002352:	8526                	mv	a0,s1
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	bb2080e7          	jalr	-1102(ra) # 80000f06 <release>
}
    8000235c:	60e2                	ld	ra,24(sp)
    8000235e:	6442                	ld	s0,16(sp)
    80002360:	64a2                	ld	s1,8(sp)
    80002362:	6105                	addi	sp,sp,32
    80002364:	8082                	ret

0000000080002366 <growproc>:
{
    80002366:	1101                	addi	sp,sp,-32
    80002368:	ec06                	sd	ra,24(sp)
    8000236a:	e822                	sd	s0,16(sp)
    8000236c:	e426                	sd	s1,8(sp)
    8000236e:	e04a                	sd	s2,0(sp)
    80002370:	1000                	addi	s0,sp,32
    80002372:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002374:	00000097          	auipc	ra,0x0
    80002378:	ccc080e7          	jalr	-820(ra) # 80002040 <myproc>
    8000237c:	892a                	mv	s2,a0
  sz = p->sz;
    8000237e:	712c                	ld	a1,96(a0)
    80002380:	0005851b          	sext.w	a0,a1
  if(n > 0){
    80002384:	00904f63          	bgtz	s1,800023a2 <growproc+0x3c>
  } else if(n < 0){
    80002388:	0204cd63          	bltz	s1,800023c2 <growproc+0x5c>
  p->sz = sz;
    8000238c:	1502                	slli	a0,a0,0x20
    8000238e:	9101                	srli	a0,a0,0x20
    80002390:	06a93023          	sd	a0,96(s2)
  return 0;
    80002394:	4501                	li	a0,0
}
    80002396:	60e2                	ld	ra,24(sp)
    80002398:	6442                	ld	s0,16(sp)
    8000239a:	64a2                	ld	s1,8(sp)
    8000239c:	6902                	ld	s2,0(sp)
    8000239e:	6105                	addi	sp,sp,32
    800023a0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800023a2:	00a4863b          	addw	a2,s1,a0
    800023a6:	1602                	slli	a2,a2,0x20
    800023a8:	9201                	srli	a2,a2,0x20
    800023aa:	1582                	slli	a1,a1,0x20
    800023ac:	9181                	srli	a1,a1,0x20
    800023ae:	06893503          	ld	a0,104(s2)
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	692080e7          	jalr	1682(ra) # 80001a44 <uvmalloc>
    800023ba:	2501                	sext.w	a0,a0
    800023bc:	f961                	bnez	a0,8000238c <growproc+0x26>
      return -1;
    800023be:	557d                	li	a0,-1
    800023c0:	bfd9                	j	80002396 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800023c2:	00a4863b          	addw	a2,s1,a0
    800023c6:	1602                	slli	a2,a2,0x20
    800023c8:	9201                	srli	a2,a2,0x20
    800023ca:	1582                	slli	a1,a1,0x20
    800023cc:	9181                	srli	a1,a1,0x20
    800023ce:	06893503          	ld	a0,104(s2)
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	62e080e7          	jalr	1582(ra) # 80001a00 <uvmdealloc>
    800023da:	2501                	sext.w	a0,a0
    800023dc:	bf45                	j	8000238c <growproc+0x26>

00000000800023de <fork>:
{
    800023de:	7179                	addi	sp,sp,-48
    800023e0:	f406                	sd	ra,40(sp)
    800023e2:	f022                	sd	s0,32(sp)
    800023e4:	ec26                	sd	s1,24(sp)
    800023e6:	e84a                	sd	s2,16(sp)
    800023e8:	e44e                	sd	s3,8(sp)
    800023ea:	e052                	sd	s4,0(sp)
    800023ec:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023ee:	00000097          	auipc	ra,0x0
    800023f2:	c52080e7          	jalr	-942(ra) # 80002040 <myproc>
    800023f6:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    800023f8:	00000097          	auipc	ra,0x0
    800023fc:	d6a080e7          	jalr	-662(ra) # 80002162 <allocproc>
    80002400:	c975                	beqz	a0,800024f4 <fork+0x116>
    80002402:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002404:	06093603          	ld	a2,96(s2)
    80002408:	752c                	ld	a1,104(a0)
    8000240a:	06893503          	ld	a0,104(s2)
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	70e080e7          	jalr	1806(ra) # 80001b1c <uvmcopy>
    80002416:	04054863          	bltz	a0,80002466 <fork+0x88>
  np->sz = p->sz;
    8000241a:	06093783          	ld	a5,96(s2)
    8000241e:	06f9b023          	sd	a5,96(s3) # 4000060 <_entry-0x7bffffa0>
  np->parent = p;
    80002422:	0329bc23          	sd	s2,56(s3)
  *(np->tf) = *(p->tf);
    80002426:	07093683          	ld	a3,112(s2)
    8000242a:	87b6                	mv	a5,a3
    8000242c:	0709b703          	ld	a4,112(s3)
    80002430:	12068693          	addi	a3,a3,288
    80002434:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002438:	6788                	ld	a0,8(a5)
    8000243a:	6b8c                	ld	a1,16(a5)
    8000243c:	6f90                	ld	a2,24(a5)
    8000243e:	01073023          	sd	a6,0(a4)
    80002442:	e708                	sd	a0,8(a4)
    80002444:	eb0c                	sd	a1,16(a4)
    80002446:	ef10                	sd	a2,24(a4)
    80002448:	02078793          	addi	a5,a5,32
    8000244c:	02070713          	addi	a4,a4,32
    80002450:	fed792e3          	bne	a5,a3,80002434 <fork+0x56>
  np->tf->a0 = 0;
    80002454:	0709b783          	ld	a5,112(s3)
    80002458:	0607b823          	sd	zero,112(a5)
    8000245c:	0e800493          	li	s1,232
  for(i = 0; i < NOFILE; i++)
    80002460:	16800a13          	li	s4,360
    80002464:	a03d                	j	80002492 <fork+0xb4>
    freeproc(np);
    80002466:	854e                	mv	a0,s3
    80002468:	00000097          	auipc	ra,0x0
    8000246c:	dfa080e7          	jalr	-518(ra) # 80002262 <freeproc>
    release(&np->lock);
    80002470:	854e                	mv	a0,s3
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	a94080e7          	jalr	-1388(ra) # 80000f06 <release>
    return -1;
    8000247a:	54fd                	li	s1,-1
    8000247c:	a09d                	j	800024e2 <fork+0x104>
      np->ofile[i] = filedup(p->ofile[i]);
    8000247e:	00003097          	auipc	ra,0x3
    80002482:	92e080e7          	jalr	-1746(ra) # 80004dac <filedup>
    80002486:	009987b3          	add	a5,s3,s1
    8000248a:	e388                	sd	a0,0(a5)
    8000248c:	04a1                	addi	s1,s1,8
  for(i = 0; i < NOFILE; i++)
    8000248e:	01448763          	beq	s1,s4,8000249c <fork+0xbe>
    if(p->ofile[i])
    80002492:	009907b3          	add	a5,s2,s1
    80002496:	6388                	ld	a0,0(a5)
    80002498:	f17d                	bnez	a0,8000247e <fork+0xa0>
    8000249a:	bfcd                	j	8000248c <fork+0xae>
  np->cwd = idup(p->cwd);
    8000249c:	16893503          	ld	a0,360(s2)
    800024a0:	00002097          	auipc	ra,0x2
    800024a4:	98a080e7          	jalr	-1654(ra) # 80003e2a <idup>
    800024a8:	16a9b423          	sd	a0,360(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800024ac:	4641                	li	a2,16
    800024ae:	17090593          	addi	a1,s2,368
    800024b2:	17098513          	addi	a0,s3,368
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	df0080e7          	jalr	-528(ra) # 800012a6 <safestrcpy>
  np->cmd = strdup(p->cmd);
    800024be:	18093503          	ld	a0,384(s2)
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	ede080e7          	jalr	-290(ra) # 800013a0 <strdup>
    800024ca:	18a9b023          	sd	a0,384(s3)
  pid = np->pid;
    800024ce:	0509a483          	lw	s1,80(s3)
  np->state = RUNNABLE;
    800024d2:	4789                	li	a5,2
    800024d4:	02f9a823          	sw	a5,48(s3)
  release(&np->lock);
    800024d8:	854e                	mv	a0,s3
    800024da:	fffff097          	auipc	ra,0xfffff
    800024de:	a2c080e7          	jalr	-1492(ra) # 80000f06 <release>
}
    800024e2:	8526                	mv	a0,s1
    800024e4:	70a2                	ld	ra,40(sp)
    800024e6:	7402                	ld	s0,32(sp)
    800024e8:	64e2                	ld	s1,24(sp)
    800024ea:	6942                	ld	s2,16(sp)
    800024ec:	69a2                	ld	s3,8(sp)
    800024ee:	6a02                	ld	s4,0(sp)
    800024f0:	6145                	addi	sp,sp,48
    800024f2:	8082                	ret
    return -1;
    800024f4:	54fd                	li	s1,-1
    800024f6:	b7f5                	j	800024e2 <fork+0x104>

00000000800024f8 <reparent>:
{
    800024f8:	7179                	addi	sp,sp,-48
    800024fa:	f406                	sd	ra,40(sp)
    800024fc:	f022                	sd	s0,32(sp)
    800024fe:	ec26                	sd	s1,24(sp)
    80002500:	e84a                	sd	s2,16(sp)
    80002502:	e44e                	sd	s3,8(sp)
    80002504:	e052                	sd	s4,0(sp)
    80002506:	1800                	addi	s0,sp,48
    80002508:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000250a:	00014497          	auipc	s1,0x14
    8000250e:	98e48493          	addi	s1,s1,-1650 # 80015e98 <proc>
      pp->parent = initproc;
    80002512:	0002ca17          	auipc	s4,0x2c
    80002516:	b6ea0a13          	addi	s4,s4,-1170 # 8002e080 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000251a:	0001a917          	auipc	s2,0x1a
    8000251e:	b7e90913          	addi	s2,s2,-1154 # 8001c098 <tickslock>
    80002522:	a029                	j	8000252c <reparent+0x34>
    80002524:	18848493          	addi	s1,s1,392
    80002528:	03248363          	beq	s1,s2,8000254e <reparent+0x56>
    if(pp->parent == p){
    8000252c:	7c9c                	ld	a5,56(s1)
    8000252e:	ff379be3          	bne	a5,s3,80002524 <reparent+0x2c>
      acquire(&pp->lock);
    80002532:	8526                	mv	a0,s1
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	786080e7          	jalr	1926(ra) # 80000cba <acquire>
      pp->parent = initproc;
    8000253c:	000a3783          	ld	a5,0(s4)
    80002540:	fc9c                	sd	a5,56(s1)
      release(&pp->lock);
    80002542:	8526                	mv	a0,s1
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	9c2080e7          	jalr	-1598(ra) # 80000f06 <release>
    8000254c:	bfe1                	j	80002524 <reparent+0x2c>
}
    8000254e:	70a2                	ld	ra,40(sp)
    80002550:	7402                	ld	s0,32(sp)
    80002552:	64e2                	ld	s1,24(sp)
    80002554:	6942                	ld	s2,16(sp)
    80002556:	69a2                	ld	s3,8(sp)
    80002558:	6a02                	ld	s4,0(sp)
    8000255a:	6145                	addi	sp,sp,48
    8000255c:	8082                	ret

000000008000255e <scheduler>:
{
    8000255e:	715d                	addi	sp,sp,-80
    80002560:	e486                	sd	ra,72(sp)
    80002562:	e0a2                	sd	s0,64(sp)
    80002564:	fc26                	sd	s1,56(sp)
    80002566:	f84a                	sd	s2,48(sp)
    80002568:	f44e                	sd	s3,40(sp)
    8000256a:	f052                	sd	s4,32(sp)
    8000256c:	ec56                	sd	s5,24(sp)
    8000256e:	e85a                	sd	s6,16(sp)
    80002570:	e45e                	sd	s7,8(sp)
    80002572:	e062                	sd	s8,0(sp)
    80002574:	0880                	addi	s0,sp,80
    80002576:	8792                	mv	a5,tp
  int id = r_tp();
    80002578:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000257a:	00779b93          	slli	s7,a5,0x7
    8000257e:	00013717          	auipc	a4,0x13
    80002582:	46a70713          	addi	a4,a4,1130 # 800159e8 <prio>
    80002586:	975e                	add	a4,a4,s7
    80002588:	0a073823          	sd	zero,176(a4)
        swtch(&c->scheduler, &p->context);
    8000258c:	00013717          	auipc	a4,0x13
    80002590:	51470713          	addi	a4,a4,1300 # 80015aa0 <cpus+0x8>
    80002594:	9bba                	add	s7,s7,a4
        p->state = RUNNING;
    80002596:	4c0d                	li	s8,3
        c->proc = p;
    80002598:	079e                	slli	a5,a5,0x7
    8000259a:	00013917          	auipc	s2,0x13
    8000259e:	44e90913          	addi	s2,s2,1102 # 800159e8 <prio>
    800025a2:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800025a4:	0001aa17          	auipc	s4,0x1a
    800025a8:	af4a0a13          	addi	s4,s4,-1292 # 8001c098 <tickslock>
    800025ac:	a0b9                	j	800025fa <scheduler+0x9c>
        p->state = RUNNING;
    800025ae:	0384a823          	sw	s8,48(s1)
        c->proc = p;
    800025b2:	0a993823          	sd	s1,176(s2)
        swtch(&c->scheduler, &p->context);
    800025b6:	07848593          	addi	a1,s1,120
    800025ba:	855e                	mv	a0,s7
    800025bc:	00000097          	auipc	ra,0x0
    800025c0:	6dc080e7          	jalr	1756(ra) # 80002c98 <swtch>
        c->proc = 0;
    800025c4:	0a093823          	sd	zero,176(s2)
        found = 1;
    800025c8:	8ada                	mv	s5,s6
      c->intena = 0;
    800025ca:	12092623          	sw	zero,300(s2)
      release(&p->lock);
    800025ce:	8526                	mv	a0,s1
    800025d0:	fffff097          	auipc	ra,0xfffff
    800025d4:	936080e7          	jalr	-1738(ra) # 80000f06 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800025d8:	18848493          	addi	s1,s1,392
    800025dc:	01448b63          	beq	s1,s4,800025f2 <scheduler+0x94>
      acquire(&p->lock);
    800025e0:	8526                	mv	a0,s1
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	6d8080e7          	jalr	1752(ra) # 80000cba <acquire>
      if(p->state == RUNNABLE) {
    800025ea:	589c                	lw	a5,48(s1)
    800025ec:	fd379fe3          	bne	a5,s3,800025ca <scheduler+0x6c>
    800025f0:	bf7d                	j	800025ae <scheduler+0x50>
    if(found == 0){
    800025f2:	000a9463          	bnez	s5,800025fa <scheduler+0x9c>
      asm volatile("wfi");
    800025f6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025fe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002602:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002606:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000260a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000260c:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002610:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002612:	00014497          	auipc	s1,0x14
    80002616:	88648493          	addi	s1,s1,-1914 # 80015e98 <proc>
      if(p->state == RUNNABLE) {
    8000261a:	4989                	li	s3,2
        found = 1;
    8000261c:	4b05                	li	s6,1
    8000261e:	b7c9                	j	800025e0 <scheduler+0x82>

0000000080002620 <sched>:
{
    80002620:	7179                	addi	sp,sp,-48
    80002622:	f406                	sd	ra,40(sp)
    80002624:	f022                	sd	s0,32(sp)
    80002626:	ec26                	sd	s1,24(sp)
    80002628:	e84a                	sd	s2,16(sp)
    8000262a:	e44e                	sd	s3,8(sp)
    8000262c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000262e:	00000097          	auipc	ra,0x0
    80002632:	a12080e7          	jalr	-1518(ra) # 80002040 <myproc>
    80002636:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	604080e7          	jalr	1540(ra) # 80000c3c <holding>
    80002640:	cd25                	beqz	a0,800026b8 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002642:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002644:	2781                	sext.w	a5,a5
    80002646:	079e                	slli	a5,a5,0x7
    80002648:	00013717          	auipc	a4,0x13
    8000264c:	3a070713          	addi	a4,a4,928 # 800159e8 <prio>
    80002650:	97ba                	add	a5,a5,a4
    80002652:	1287a703          	lw	a4,296(a5)
    80002656:	4785                	li	a5,1
    80002658:	06f71863          	bne	a4,a5,800026c8 <sched+0xa8>
  if(p->state == RUNNING)
    8000265c:	03092703          	lw	a4,48(s2)
    80002660:	478d                	li	a5,3
    80002662:	06f70b63          	beq	a4,a5,800026d8 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002666:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000266a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000266c:	efb5                	bnez	a5,800026e8 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000266e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002670:	00013497          	auipc	s1,0x13
    80002674:	37848493          	addi	s1,s1,888 # 800159e8 <prio>
    80002678:	2781                	sext.w	a5,a5
    8000267a:	079e                	slli	a5,a5,0x7
    8000267c:	97a6                	add	a5,a5,s1
    8000267e:	12c7a983          	lw	s3,300(a5)
    80002682:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80002684:	2781                	sext.w	a5,a5
    80002686:	079e                	slli	a5,a5,0x7
    80002688:	00013597          	auipc	a1,0x13
    8000268c:	41858593          	addi	a1,a1,1048 # 80015aa0 <cpus+0x8>
    80002690:	95be                	add	a1,a1,a5
    80002692:	07890513          	addi	a0,s2,120
    80002696:	00000097          	auipc	ra,0x0
    8000269a:	602080e7          	jalr	1538(ra) # 80002c98 <swtch>
    8000269e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800026a0:	2781                	sext.w	a5,a5
    800026a2:	079e                	slli	a5,a5,0x7
    800026a4:	97a6                	add	a5,a5,s1
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
    800026c4:	0c4080e7          	jalr	196(ra) # 80000784 <panic>
    panic("sched locks");
    800026c8:	00006517          	auipc	a0,0x6
    800026cc:	f0850513          	addi	a0,a0,-248 # 800085d0 <userret+0x540>
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	0b4080e7          	jalr	180(ra) # 80000784 <panic>
    panic("sched running");
    800026d8:	00006517          	auipc	a0,0x6
    800026dc:	f0850513          	addi	a0,a0,-248 # 800085e0 <userret+0x550>
    800026e0:	ffffe097          	auipc	ra,0xffffe
    800026e4:	0a4080e7          	jalr	164(ra) # 80000784 <panic>
    panic("sched interruptible");
    800026e8:	00006517          	auipc	a0,0x6
    800026ec:	f0850513          	addi	a0,a0,-248 # 800085f0 <userret+0x560>
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	094080e7          	jalr	148(ra) # 80000784 <panic>

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
    8000270e:	936080e7          	jalr	-1738(ra) # 80002040 <myproc>
    80002712:	89aa                	mv	s3,a0
  if(p == initproc)
    80002714:	0002c797          	auipc	a5,0x2c
    80002718:	96c78793          	addi	a5,a5,-1684 # 8002e080 <initproc>
    8000271c:	639c                	ld	a5,0(a5)
    8000271e:	0e850493          	addi	s1,a0,232
    80002722:	16850913          	addi	s2,a0,360
    80002726:	02a79363          	bne	a5,a0,8000274c <exit+0x54>
    panic("init exiting");
    8000272a:	00006517          	auipc	a0,0x6
    8000272e:	ede50513          	addi	a0,a0,-290 # 80008608 <userret+0x578>
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	052080e7          	jalr	82(ra) # 80000784 <panic>
      fileclose(f);
    8000273a:	00002097          	auipc	ra,0x2
    8000273e:	6c4080e7          	jalr	1732(ra) # 80004dfe <fileclose>
      p->ofile[fd] = 0;
    80002742:	0004b023          	sd	zero,0(s1)
    80002746:	04a1                	addi	s1,s1,8
  for(int fd = 0; fd < NOFILE; fd++){
    80002748:	01248563          	beq	s1,s2,80002752 <exit+0x5a>
    if(p->ofile[fd]){
    8000274c:	6088                	ld	a0,0(s1)
    8000274e:	f575                	bnez	a0,8000273a <exit+0x42>
    80002750:	bfdd                	j	80002746 <exit+0x4e>
  begin_op(ROOTDEV);
    80002752:	4501                	li	a0,0
    80002754:	00002097          	auipc	ra,0x2
    80002758:	0ee080e7          	jalr	238(ra) # 80004842 <begin_op>
  iput(p->cwd);
    8000275c:	1689b503          	ld	a0,360(s3)
    80002760:	00002097          	auipc	ra,0x2
    80002764:	818080e7          	jalr	-2024(ra) # 80003f78 <iput>
  end_op(ROOTDEV);
    80002768:	4501                	li	a0,0
    8000276a:	00002097          	auipc	ra,0x2
    8000276e:	184080e7          	jalr	388(ra) # 800048ee <end_op>
  p->cwd = 0;
    80002772:	1609b423          	sd	zero,360(s3)
  acquire(&initproc->lock);
    80002776:	0002c497          	auipc	s1,0x2c
    8000277a:	90a48493          	addi	s1,s1,-1782 # 8002e080 <initproc>
    8000277e:	6088                	ld	a0,0(s1)
    80002780:	ffffe097          	auipc	ra,0xffffe
    80002784:	53a080e7          	jalr	1338(ra) # 80000cba <acquire>
  wakeup1(initproc);
    80002788:	6088                	ld	a0,0(s1)
    8000278a:	fffff097          	auipc	ra,0xfffff
    8000278e:	678080e7          	jalr	1656(ra) # 80001e02 <wakeup1>
  release(&initproc->lock);
    80002792:	6088                	ld	a0,0(s1)
    80002794:	ffffe097          	auipc	ra,0xffffe
    80002798:	772080e7          	jalr	1906(ra) # 80000f06 <release>
  acquire(&p->lock);
    8000279c:	854e                	mv	a0,s3
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	51c080e7          	jalr	1308(ra) # 80000cba <acquire>
  struct proc *original_parent = p->parent;
    800027a6:	0389b483          	ld	s1,56(s3)
  release(&p->lock);
    800027aa:	854e                	mv	a0,s3
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	75a080e7          	jalr	1882(ra) # 80000f06 <release>
  acquire(&original_parent->lock);
    800027b4:	8526                	mv	a0,s1
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	504080e7          	jalr	1284(ra) # 80000cba <acquire>
  acquire(&p->lock);
    800027be:	854e                	mv	a0,s3
    800027c0:	ffffe097          	auipc	ra,0xffffe
    800027c4:	4fa080e7          	jalr	1274(ra) # 80000cba <acquire>
  reparent(p);
    800027c8:	854e                	mv	a0,s3
    800027ca:	00000097          	auipc	ra,0x0
    800027ce:	d2e080e7          	jalr	-722(ra) # 800024f8 <reparent>
  wakeup1(original_parent);
    800027d2:	8526                	mv	a0,s1
    800027d4:	fffff097          	auipc	ra,0xfffff
    800027d8:	62e080e7          	jalr	1582(ra) # 80001e02 <wakeup1>
  p->xstate = status;
    800027dc:	0549a623          	sw	s4,76(s3)
  p->state = ZOMBIE;
    800027e0:	4791                	li	a5,4
    800027e2:	02f9a823          	sw	a5,48(s3)
  release(&original_parent->lock);
    800027e6:	8526                	mv	a0,s1
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	71e080e7          	jalr	1822(ra) # 80000f06 <release>
  sched();
    800027f0:	00000097          	auipc	ra,0x0
    800027f4:	e30080e7          	jalr	-464(ra) # 80002620 <sched>
  panic("zombie exit");
    800027f8:	00006517          	auipc	a0,0x6
    800027fc:	e2050513          	addi	a0,a0,-480 # 80008618 <userret+0x588>
    80002800:	ffffe097          	auipc	ra,0xffffe
    80002804:	f84080e7          	jalr	-124(ra) # 80000784 <panic>

0000000080002808 <yield>:
{
    80002808:	1101                	addi	sp,sp,-32
    8000280a:	ec06                	sd	ra,24(sp)
    8000280c:	e822                	sd	s0,16(sp)
    8000280e:	e426                	sd	s1,8(sp)
    80002810:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002812:	00000097          	auipc	ra,0x0
    80002816:	82e080e7          	jalr	-2002(ra) # 80002040 <myproc>
    8000281a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000281c:	ffffe097          	auipc	ra,0xffffe
    80002820:	49e080e7          	jalr	1182(ra) # 80000cba <acquire>
  p->state = RUNNABLE;
    80002824:	4789                	li	a5,2
    80002826:	d89c                	sw	a5,48(s1)
  sched();
    80002828:	00000097          	auipc	ra,0x0
    8000282c:	df8080e7          	jalr	-520(ra) # 80002620 <sched>
  release(&p->lock);
    80002830:	8526                	mv	a0,s1
    80002832:	ffffe097          	auipc	ra,0xffffe
    80002836:	6d4080e7          	jalr	1748(ra) # 80000f06 <release>
}
    8000283a:	60e2                	ld	ra,24(sp)
    8000283c:	6442                	ld	s0,16(sp)
    8000283e:	64a2                	ld	s1,8(sp)
    80002840:	6105                	addi	sp,sp,32
    80002842:	8082                	ret

0000000080002844 <sleep>:
{
    80002844:	7179                	addi	sp,sp,-48
    80002846:	f406                	sd	ra,40(sp)
    80002848:	f022                	sd	s0,32(sp)
    8000284a:	ec26                	sd	s1,24(sp)
    8000284c:	e84a                	sd	s2,16(sp)
    8000284e:	e44e                	sd	s3,8(sp)
    80002850:	1800                	addi	s0,sp,48
    80002852:	89aa                	mv	s3,a0
    80002854:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002856:	fffff097          	auipc	ra,0xfffff
    8000285a:	7ea080e7          	jalr	2026(ra) # 80002040 <myproc>
    8000285e:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002860:	05250663          	beq	a0,s2,800028ac <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002864:	ffffe097          	auipc	ra,0xffffe
    80002868:	456080e7          	jalr	1110(ra) # 80000cba <acquire>
    release(lk);
    8000286c:	854a                	mv	a0,s2
    8000286e:	ffffe097          	auipc	ra,0xffffe
    80002872:	698080e7          	jalr	1688(ra) # 80000f06 <release>
  p->chan = chan;
    80002876:	0534b023          	sd	s3,64(s1)
  p->state = SLEEPING;
    8000287a:	4785                	li	a5,1
    8000287c:	d89c                	sw	a5,48(s1)
  sched();
    8000287e:	00000097          	auipc	ra,0x0
    80002882:	da2080e7          	jalr	-606(ra) # 80002620 <sched>
  p->chan = 0;
    80002886:	0404b023          	sd	zero,64(s1)
    release(&p->lock);
    8000288a:	8526                	mv	a0,s1
    8000288c:	ffffe097          	auipc	ra,0xffffe
    80002890:	67a080e7          	jalr	1658(ra) # 80000f06 <release>
    acquire(lk);
    80002894:	854a                	mv	a0,s2
    80002896:	ffffe097          	auipc	ra,0xffffe
    8000289a:	424080e7          	jalr	1060(ra) # 80000cba <acquire>
}
    8000289e:	70a2                	ld	ra,40(sp)
    800028a0:	7402                	ld	s0,32(sp)
    800028a2:	64e2                	ld	s1,24(sp)
    800028a4:	6942                	ld	s2,16(sp)
    800028a6:	69a2                	ld	s3,8(sp)
    800028a8:	6145                	addi	sp,sp,48
    800028aa:	8082                	ret
  p->chan = chan;
    800028ac:	05353023          	sd	s3,64(a0)
  p->state = SLEEPING;
    800028b0:	4785                	li	a5,1
    800028b2:	d91c                	sw	a5,48(a0)
  sched();
    800028b4:	00000097          	auipc	ra,0x0
    800028b8:	d6c080e7          	jalr	-660(ra) # 80002620 <sched>
  p->chan = 0;
    800028bc:	0404b023          	sd	zero,64(s1)
  if(lk != &p->lock){
    800028c0:	bff9                	j	8000289e <sleep+0x5a>

00000000800028c2 <wait>:
{
    800028c2:	715d                	addi	sp,sp,-80
    800028c4:	e486                	sd	ra,72(sp)
    800028c6:	e0a2                	sd	s0,64(sp)
    800028c8:	fc26                	sd	s1,56(sp)
    800028ca:	f84a                	sd	s2,48(sp)
    800028cc:	f44e                	sd	s3,40(sp)
    800028ce:	f052                	sd	s4,32(sp)
    800028d0:	ec56                	sd	s5,24(sp)
    800028d2:	e85a                	sd	s6,16(sp)
    800028d4:	e45e                	sd	s7,8(sp)
    800028d6:	e062                	sd	s8,0(sp)
    800028d8:	0880                	addi	s0,sp,80
    800028da:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800028dc:	fffff097          	auipc	ra,0xfffff
    800028e0:	764080e7          	jalr	1892(ra) # 80002040 <myproc>
    800028e4:	892a                	mv	s2,a0
  acquire(&p->lock);
    800028e6:	8c2a                	mv	s8,a0
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	3d2080e7          	jalr	978(ra) # 80000cba <acquire>
    havekids = 0;
    800028f0:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    800028f2:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800028f4:	00019997          	auipc	s3,0x19
    800028f8:	7a498993          	addi	s3,s3,1956 # 8001c098 <tickslock>
        havekids = 1;
    800028fc:	4a85                	li	s5,1
    havekids = 0;
    800028fe:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002900:	00013497          	auipc	s1,0x13
    80002904:	59848493          	addi	s1,s1,1432 # 80015e98 <proc>
    80002908:	a08d                	j	8000296a <wait+0xa8>
          pid = np->pid;
    8000290a:	0504a983          	lw	s3,80(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000290e:	000b8e63          	beqz	s7,8000292a <wait+0x68>
    80002912:	4691                	li	a3,4
    80002914:	04c48613          	addi	a2,s1,76
    80002918:	85de                	mv	a1,s7
    8000291a:	06893503          	ld	a0,104(s2)
    8000291e:	fffff097          	auipc	ra,0xfffff
    80002922:	300080e7          	jalr	768(ra) # 80001c1e <copyout>
    80002926:	02054263          	bltz	a0,8000294a <wait+0x88>
          freeproc(np);
    8000292a:	8526                	mv	a0,s1
    8000292c:	00000097          	auipc	ra,0x0
    80002930:	936080e7          	jalr	-1738(ra) # 80002262 <freeproc>
          release(&np->lock);
    80002934:	8526                	mv	a0,s1
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	5d0080e7          	jalr	1488(ra) # 80000f06 <release>
          release(&p->lock);
    8000293e:	854a                	mv	a0,s2
    80002940:	ffffe097          	auipc	ra,0xffffe
    80002944:	5c6080e7          	jalr	1478(ra) # 80000f06 <release>
          return pid;
    80002948:	a8a9                	j	800029a2 <wait+0xe0>
            release(&np->lock);
    8000294a:	8526                	mv	a0,s1
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	5ba080e7          	jalr	1466(ra) # 80000f06 <release>
            release(&p->lock);
    80002954:	854a                	mv	a0,s2
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	5b0080e7          	jalr	1456(ra) # 80000f06 <release>
            return -1;
    8000295e:	59fd                	li	s3,-1
    80002960:	a089                	j	800029a2 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002962:	18848493          	addi	s1,s1,392
    80002966:	03348463          	beq	s1,s3,8000298e <wait+0xcc>
      if(np->parent == p){
    8000296a:	7c9c                	ld	a5,56(s1)
    8000296c:	ff279be3          	bne	a5,s2,80002962 <wait+0xa0>
        acquire(&np->lock);
    80002970:	8526                	mv	a0,s1
    80002972:	ffffe097          	auipc	ra,0xffffe
    80002976:	348080e7          	jalr	840(ra) # 80000cba <acquire>
        if(np->state == ZOMBIE){
    8000297a:	589c                	lw	a5,48(s1)
    8000297c:	f94787e3          	beq	a5,s4,8000290a <wait+0x48>
        release(&np->lock);
    80002980:	8526                	mv	a0,s1
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	584080e7          	jalr	1412(ra) # 80000f06 <release>
        havekids = 1;
    8000298a:	8756                	mv	a4,s5
    8000298c:	bfd9                	j	80002962 <wait+0xa0>
    if(!havekids || p->killed){
    8000298e:	c701                	beqz	a4,80002996 <wait+0xd4>
    80002990:	04892783          	lw	a5,72(s2)
    80002994:	c785                	beqz	a5,800029bc <wait+0xfa>
      release(&p->lock);
    80002996:	854a                	mv	a0,s2
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	56e080e7          	jalr	1390(ra) # 80000f06 <release>
      return -1;
    800029a0:	59fd                	li	s3,-1
}
    800029a2:	854e                	mv	a0,s3
    800029a4:	60a6                	ld	ra,72(sp)
    800029a6:	6406                	ld	s0,64(sp)
    800029a8:	74e2                	ld	s1,56(sp)
    800029aa:	7942                	ld	s2,48(sp)
    800029ac:	79a2                	ld	s3,40(sp)
    800029ae:	7a02                	ld	s4,32(sp)
    800029b0:	6ae2                	ld	s5,24(sp)
    800029b2:	6b42                	ld	s6,16(sp)
    800029b4:	6ba2                	ld	s7,8(sp)
    800029b6:	6c02                	ld	s8,0(sp)
    800029b8:	6161                	addi	sp,sp,80
    800029ba:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800029bc:	85e2                	mv	a1,s8
    800029be:	854a                	mv	a0,s2
    800029c0:	00000097          	auipc	ra,0x0
    800029c4:	e84080e7          	jalr	-380(ra) # 80002844 <sleep>
    havekids = 0;
    800029c8:	bf1d                	j	800028fe <wait+0x3c>

00000000800029ca <wakeup>:
{
    800029ca:	7139                	addi	sp,sp,-64
    800029cc:	fc06                	sd	ra,56(sp)
    800029ce:	f822                	sd	s0,48(sp)
    800029d0:	f426                	sd	s1,40(sp)
    800029d2:	f04a                	sd	s2,32(sp)
    800029d4:	ec4e                	sd	s3,24(sp)
    800029d6:	e852                	sd	s4,16(sp)
    800029d8:	e456                	sd	s5,8(sp)
    800029da:	0080                	addi	s0,sp,64
    800029dc:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800029de:	00013497          	auipc	s1,0x13
    800029e2:	4ba48493          	addi	s1,s1,1210 # 80015e98 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800029e6:	4985                	li	s3,1
      p->state = RUNNABLE;
    800029e8:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800029ea:	00019917          	auipc	s2,0x19
    800029ee:	6ae90913          	addi	s2,s2,1710 # 8001c098 <tickslock>
    800029f2:	a821                	j	80002a0a <wakeup+0x40>
      p->state = RUNNABLE;
    800029f4:	0354a823          	sw	s5,48(s1)
    release(&p->lock);
    800029f8:	8526                	mv	a0,s1
    800029fa:	ffffe097          	auipc	ra,0xffffe
    800029fe:	50c080e7          	jalr	1292(ra) # 80000f06 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002a02:	18848493          	addi	s1,s1,392
    80002a06:	01248e63          	beq	s1,s2,80002a22 <wakeup+0x58>
    acquire(&p->lock);
    80002a0a:	8526                	mv	a0,s1
    80002a0c:	ffffe097          	auipc	ra,0xffffe
    80002a10:	2ae080e7          	jalr	686(ra) # 80000cba <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002a14:	589c                	lw	a5,48(s1)
    80002a16:	ff3791e3          	bne	a5,s3,800029f8 <wakeup+0x2e>
    80002a1a:	60bc                	ld	a5,64(s1)
    80002a1c:	fd479ee3          	bne	a5,s4,800029f8 <wakeup+0x2e>
    80002a20:	bfd1                	j	800029f4 <wakeup+0x2a>
}
    80002a22:	70e2                	ld	ra,56(sp)
    80002a24:	7442                	ld	s0,48(sp)
    80002a26:	74a2                	ld	s1,40(sp)
    80002a28:	7902                	ld	s2,32(sp)
    80002a2a:	69e2                	ld	s3,24(sp)
    80002a2c:	6a42                	ld	s4,16(sp)
    80002a2e:	6aa2                	ld	s5,8(sp)
    80002a30:	6121                	addi	sp,sp,64
    80002a32:	8082                	ret

0000000080002a34 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002a34:	7179                	addi	sp,sp,-48
    80002a36:	f406                	sd	ra,40(sp)
    80002a38:	f022                	sd	s0,32(sp)
    80002a3a:	ec26                	sd	s1,24(sp)
    80002a3c:	e84a                	sd	s2,16(sp)
    80002a3e:	e44e                	sd	s3,8(sp)
    80002a40:	1800                	addi	s0,sp,48
    80002a42:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002a44:	00013497          	auipc	s1,0x13
    80002a48:	45448493          	addi	s1,s1,1108 # 80015e98 <proc>
    80002a4c:	00019997          	auipc	s3,0x19
    80002a50:	64c98993          	addi	s3,s3,1612 # 8001c098 <tickslock>
    acquire(&p->lock);
    80002a54:	8526                	mv	a0,s1
    80002a56:	ffffe097          	auipc	ra,0xffffe
    80002a5a:	264080e7          	jalr	612(ra) # 80000cba <acquire>
    if(p->pid == pid){
    80002a5e:	48bc                	lw	a5,80(s1)
    80002a60:	01278d63          	beq	a5,s2,80002a7a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002a64:	8526                	mv	a0,s1
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	4a0080e7          	jalr	1184(ra) # 80000f06 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a6e:	18848493          	addi	s1,s1,392
    80002a72:	ff3491e3          	bne	s1,s3,80002a54 <kill+0x20>
  }
  return -1;
    80002a76:	557d                	li	a0,-1
    80002a78:	a829                	j	80002a92 <kill+0x5e>
      p->killed = 1;
    80002a7a:	4785                	li	a5,1
    80002a7c:	c4bc                	sw	a5,72(s1)
      if(p->state == SLEEPING){
    80002a7e:	5898                	lw	a4,48(s1)
    80002a80:	4785                	li	a5,1
    80002a82:	00f70f63          	beq	a4,a5,80002aa0 <kill+0x6c>
      release(&p->lock);
    80002a86:	8526                	mv	a0,s1
    80002a88:	ffffe097          	auipc	ra,0xffffe
    80002a8c:	47e080e7          	jalr	1150(ra) # 80000f06 <release>
      return 0;
    80002a90:	4501                	li	a0,0
}
    80002a92:	70a2                	ld	ra,40(sp)
    80002a94:	7402                	ld	s0,32(sp)
    80002a96:	64e2                	ld	s1,24(sp)
    80002a98:	6942                	ld	s2,16(sp)
    80002a9a:	69a2                	ld	s3,8(sp)
    80002a9c:	6145                	addi	sp,sp,48
    80002a9e:	8082                	ret
        p->state = RUNNABLE;
    80002aa0:	4789                	li	a5,2
    80002aa2:	d89c                	sw	a5,48(s1)
    80002aa4:	b7cd                	j	80002a86 <kill+0x52>

0000000080002aa6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002aa6:	7179                	addi	sp,sp,-48
    80002aa8:	f406                	sd	ra,40(sp)
    80002aaa:	f022                	sd	s0,32(sp)
    80002aac:	ec26                	sd	s1,24(sp)
    80002aae:	e84a                	sd	s2,16(sp)
    80002ab0:	e44e                	sd	s3,8(sp)
    80002ab2:	e052                	sd	s4,0(sp)
    80002ab4:	1800                	addi	s0,sp,48
    80002ab6:	84aa                	mv	s1,a0
    80002ab8:	892e                	mv	s2,a1
    80002aba:	89b2                	mv	s3,a2
    80002abc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002abe:	fffff097          	auipc	ra,0xfffff
    80002ac2:	582080e7          	jalr	1410(ra) # 80002040 <myproc>
  if(user_dst){
    80002ac6:	c08d                	beqz	s1,80002ae8 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002ac8:	86d2                	mv	a3,s4
    80002aca:	864e                	mv	a2,s3
    80002acc:	85ca                	mv	a1,s2
    80002ace:	7528                	ld	a0,104(a0)
    80002ad0:	fffff097          	auipc	ra,0xfffff
    80002ad4:	14e080e7          	jalr	334(ra) # 80001c1e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002ad8:	70a2                	ld	ra,40(sp)
    80002ada:	7402                	ld	s0,32(sp)
    80002adc:	64e2                	ld	s1,24(sp)
    80002ade:	6942                	ld	s2,16(sp)
    80002ae0:	69a2                	ld	s3,8(sp)
    80002ae2:	6a02                	ld	s4,0(sp)
    80002ae4:	6145                	addi	sp,sp,48
    80002ae6:	8082                	ret
    memmove((char *)dst, src, len);
    80002ae8:	000a061b          	sext.w	a2,s4
    80002aec:	85ce                	mv	a1,s3
    80002aee:	854a                	mv	a0,s2
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	6aa080e7          	jalr	1706(ra) # 8000119a <memmove>
    return 0;
    80002af8:	8526                	mv	a0,s1
    80002afa:	bff9                	j	80002ad8 <either_copyout+0x32>

0000000080002afc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002afc:	7179                	addi	sp,sp,-48
    80002afe:	f406                	sd	ra,40(sp)
    80002b00:	f022                	sd	s0,32(sp)
    80002b02:	ec26                	sd	s1,24(sp)
    80002b04:	e84a                	sd	s2,16(sp)
    80002b06:	e44e                	sd	s3,8(sp)
    80002b08:	e052                	sd	s4,0(sp)
    80002b0a:	1800                	addi	s0,sp,48
    80002b0c:	892a                	mv	s2,a0
    80002b0e:	84ae                	mv	s1,a1
    80002b10:	89b2                	mv	s3,a2
    80002b12:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002b14:	fffff097          	auipc	ra,0xfffff
    80002b18:	52c080e7          	jalr	1324(ra) # 80002040 <myproc>
  if(user_src){
    80002b1c:	c08d                	beqz	s1,80002b3e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002b1e:	86d2                	mv	a3,s4
    80002b20:	864e                	mv	a2,s3
    80002b22:	85ca                	mv	a1,s2
    80002b24:	7528                	ld	a0,104(a0)
    80002b26:	fffff097          	auipc	ra,0xfffff
    80002b2a:	184080e7          	jalr	388(ra) # 80001caa <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002b2e:	70a2                	ld	ra,40(sp)
    80002b30:	7402                	ld	s0,32(sp)
    80002b32:	64e2                	ld	s1,24(sp)
    80002b34:	6942                	ld	s2,16(sp)
    80002b36:	69a2                	ld	s3,8(sp)
    80002b38:	6a02                	ld	s4,0(sp)
    80002b3a:	6145                	addi	sp,sp,48
    80002b3c:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b3e:	000a061b          	sext.w	a2,s4
    80002b42:	85ce                	mv	a1,s3
    80002b44:	854a                	mv	a0,s2
    80002b46:	ffffe097          	auipc	ra,0xffffe
    80002b4a:	654080e7          	jalr	1620(ra) # 8000119a <memmove>
    return 0;
    80002b4e:	8526                	mv	a0,s1
    80002b50:	bff9                	j	80002b2e <either_copyin+0x32>

0000000080002b52 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b52:	715d                	addi	sp,sp,-80
    80002b54:	e486                	sd	ra,72(sp)
    80002b56:	e0a2                	sd	s0,64(sp)
    80002b58:	fc26                	sd	s1,56(sp)
    80002b5a:	f84a                	sd	s2,48(sp)
    80002b5c:	f44e                	sd	s3,40(sp)
    80002b5e:	f052                	sd	s4,32(sp)
    80002b60:	ec56                	sd	s5,24(sp)
    80002b62:	e85a                	sd	s6,16(sp)
    80002b64:	e45e                	sd	s7,8(sp)
    80002b66:	e062                	sd	s8,0(sp)
    80002b68:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\nPID\tPPID\tPRIO\tSTATE\tCMD\n");
    80002b6a:	00006517          	auipc	a0,0x6
    80002b6e:	ac650513          	addi	a0,a0,-1338 # 80008630 <userret+0x5a0>
    80002b72:	ffffe097          	auipc	ra,0xffffe
    80002b76:	e2a080e7          	jalr	-470(ra) # 8000099c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b7a:	00013497          	auipc	s1,0x13
    80002b7e:	31e48493          	addi	s1,s1,798 # 80015e98 <proc>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b82:	4b91                	li	s7,4
      state = states[p->state];
    else
      state = "???";
    80002b84:	00006997          	auipc	s3,0x6
    80002b88:	aa498993          	addi	s3,s3,-1372 # 80008628 <userret+0x598>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002b8c:	5b7d                	li	s6,-1
    80002b8e:	00006a97          	auipc	s5,0x6
    80002b92:	ac2a8a93          	addi	s5,s5,-1342 # 80008650 <userret+0x5c0>
           p->parent ? p->parent->pid : -1,
           p->priority,
           state,
           p->cmd
           );
    printf("\n");
    80002b96:	00006a17          	auipc	s4,0x6
    80002b9a:	ab2a0a13          	addi	s4,s4,-1358 # 80008648 <userret+0x5b8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b9e:	00006c17          	auipc	s8,0x6
    80002ba2:	36ac0c13          	addi	s8,s8,874 # 80008f08 <states.1847>
  for(p = proc; p < &proc[NPROC]; p++){
    80002ba6:	00019917          	auipc	s2,0x19
    80002baa:	4f290913          	addi	s2,s2,1266 # 8001c098 <tickslock>
    80002bae:	a03d                	j	80002bdc <procdump+0x8a>
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002bb0:	48ac                	lw	a1,80(s1)
           p->parent ? p->parent->pid : -1,
    80002bb2:	7c9c                	ld	a5,56(s1)
    printf("%d\t%d\t%d\t%s\t'%s'",
    80002bb4:	865a                	mv	a2,s6
    80002bb6:	c391                	beqz	a5,80002bba <procdump+0x68>
    80002bb8:	4bb0                	lw	a2,80(a5)
    80002bba:	1804b783          	ld	a5,384(s1)
    80002bbe:	48f4                	lw	a3,84(s1)
    80002bc0:	8556                	mv	a0,s5
    80002bc2:	ffffe097          	auipc	ra,0xffffe
    80002bc6:	dda080e7          	jalr	-550(ra) # 8000099c <printf>
    printf("\n");
    80002bca:	8552                	mv	a0,s4
    80002bcc:	ffffe097          	auipc	ra,0xffffe
    80002bd0:	dd0080e7          	jalr	-560(ra) # 8000099c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002bd4:	18848493          	addi	s1,s1,392
    80002bd8:	01248f63          	beq	s1,s2,80002bf6 <procdump+0xa4>
    if(p->state == UNUSED)
    80002bdc:	589c                	lw	a5,48(s1)
    80002bde:	dbfd                	beqz	a5,80002bd4 <procdump+0x82>
      state = "???";
    80002be0:	874e                	mv	a4,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002be2:	fcfbe7e3          	bltu	s7,a5,80002bb0 <procdump+0x5e>
    80002be6:	1782                	slli	a5,a5,0x20
    80002be8:	9381                	srli	a5,a5,0x20
    80002bea:	078e                	slli	a5,a5,0x3
    80002bec:	97e2                	add	a5,a5,s8
    80002bee:	6398                	ld	a4,0(a5)
    80002bf0:	f361                	bnez	a4,80002bb0 <procdump+0x5e>
      state = "???";
    80002bf2:	874e                	mv	a4,s3
    80002bf4:	bf75                	j	80002bb0 <procdump+0x5e>
  }
}
    80002bf6:	60a6                	ld	ra,72(sp)
    80002bf8:	6406                	ld	s0,64(sp)
    80002bfa:	74e2                	ld	s1,56(sp)
    80002bfc:	7942                	ld	s2,48(sp)
    80002bfe:	79a2                	ld	s3,40(sp)
    80002c00:	7a02                	ld	s4,32(sp)
    80002c02:	6ae2                	ld	s5,24(sp)
    80002c04:	6b42                	ld	s6,16(sp)
    80002c06:	6ba2                	ld	s7,8(sp)
    80002c08:	6c02                	ld	s8,0(sp)
    80002c0a:	6161                	addi	sp,sp,80
    80002c0c:	8082                	ret

0000000080002c0e <priodump>:

// No lock to avoid wedging a stuck machine further.
void priodump(void){
    80002c0e:	715d                	addi	sp,sp,-80
    80002c10:	e486                	sd	ra,72(sp)
    80002c12:	e0a2                	sd	s0,64(sp)
    80002c14:	fc26                	sd	s1,56(sp)
    80002c16:	f84a                	sd	s2,48(sp)
    80002c18:	f44e                	sd	s3,40(sp)
    80002c1a:	f052                	sd	s4,32(sp)
    80002c1c:	ec56                	sd	s5,24(sp)
    80002c1e:	e85a                	sd	s6,16(sp)
    80002c20:	e45e                	sd	s7,8(sp)
    80002c22:	0880                	addi	s0,sp,80
  for (int i = 0; i < NPRIO; i++){
    80002c24:	00013a17          	auipc	s4,0x13
    80002c28:	dc4a0a13          	addi	s4,s4,-572 # 800159e8 <prio>
    80002c2c:	4981                	li	s3,0
    struct list_proc* l = prio[i];
    printf("Priority queue for priority = %d: ", i);
    80002c2e:	00006b97          	auipc	s7,0x6
    80002c32:	a3ab8b93          	addi	s7,s7,-1478 # 80008668 <userret+0x5d8>
    while(l){
      printf("%d ", l->p->pid);
    80002c36:	00006917          	auipc	s2,0x6
    80002c3a:	a5a90913          	addi	s2,s2,-1446 # 80008690 <userret+0x600>
      l = l->next;
    }
    printf("\n");
    80002c3e:	00006b17          	auipc	s6,0x6
    80002c42:	a0ab0b13          	addi	s6,s6,-1526 # 80008648 <userret+0x5b8>
  for (int i = 0; i < NPRIO; i++){
    80002c46:	4aa9                	li	s5,10
    80002c48:	a811                	j	80002c5c <priodump+0x4e>
    printf("\n");
    80002c4a:	855a                	mv	a0,s6
    80002c4c:	ffffe097          	auipc	ra,0xffffe
    80002c50:	d50080e7          	jalr	-688(ra) # 8000099c <printf>
  for (int i = 0; i < NPRIO; i++){
    80002c54:	2985                	addiw	s3,s3,1
    80002c56:	0a21                	addi	s4,s4,8
    80002c58:	03598563          	beq	s3,s5,80002c82 <priodump+0x74>
    struct list_proc* l = prio[i];
    80002c5c:	000a3483          	ld	s1,0(s4)
    printf("Priority queue for priority = %d: ", i);
    80002c60:	85ce                	mv	a1,s3
    80002c62:	855e                	mv	a0,s7
    80002c64:	ffffe097          	auipc	ra,0xffffe
    80002c68:	d38080e7          	jalr	-712(ra) # 8000099c <printf>
    while(l){
    80002c6c:	dcf9                	beqz	s1,80002c4a <priodump+0x3c>
      printf("%d ", l->p->pid);
    80002c6e:	609c                	ld	a5,0(s1)
    80002c70:	4bac                	lw	a1,80(a5)
    80002c72:	854a                	mv	a0,s2
    80002c74:	ffffe097          	auipc	ra,0xffffe
    80002c78:	d28080e7          	jalr	-728(ra) # 8000099c <printf>
      l = l->next;
    80002c7c:	6484                	ld	s1,8(s1)
    while(l){
    80002c7e:	f8e5                	bnez	s1,80002c6e <priodump+0x60>
    80002c80:	b7e9                	j	80002c4a <priodump+0x3c>
  }
}
    80002c82:	60a6                	ld	ra,72(sp)
    80002c84:	6406                	ld	s0,64(sp)
    80002c86:	74e2                	ld	s1,56(sp)
    80002c88:	7942                	ld	s2,48(sp)
    80002c8a:	79a2                	ld	s3,40(sp)
    80002c8c:	7a02                	ld	s4,32(sp)
    80002c8e:	6ae2                	ld	s5,24(sp)
    80002c90:	6b42                	ld	s6,16(sp)
    80002c92:	6ba2                	ld	s7,8(sp)
    80002c94:	6161                	addi	sp,sp,80
    80002c96:	8082                	ret

0000000080002c98 <swtch>:
    80002c98:	00153023          	sd	ra,0(a0)
    80002c9c:	00253423          	sd	sp,8(a0)
    80002ca0:	e900                	sd	s0,16(a0)
    80002ca2:	ed04                	sd	s1,24(a0)
    80002ca4:	03253023          	sd	s2,32(a0)
    80002ca8:	03353423          	sd	s3,40(a0)
    80002cac:	03453823          	sd	s4,48(a0)
    80002cb0:	03553c23          	sd	s5,56(a0)
    80002cb4:	05653023          	sd	s6,64(a0)
    80002cb8:	05753423          	sd	s7,72(a0)
    80002cbc:	05853823          	sd	s8,80(a0)
    80002cc0:	05953c23          	sd	s9,88(a0)
    80002cc4:	07a53023          	sd	s10,96(a0)
    80002cc8:	07b53423          	sd	s11,104(a0)
    80002ccc:	0005b083          	ld	ra,0(a1)
    80002cd0:	0085b103          	ld	sp,8(a1)
    80002cd4:	6980                	ld	s0,16(a1)
    80002cd6:	6d84                	ld	s1,24(a1)
    80002cd8:	0205b903          	ld	s2,32(a1)
    80002cdc:	0285b983          	ld	s3,40(a1)
    80002ce0:	0305ba03          	ld	s4,48(a1)
    80002ce4:	0385ba83          	ld	s5,56(a1)
    80002ce8:	0405bb03          	ld	s6,64(a1)
    80002cec:	0485bb83          	ld	s7,72(a1)
    80002cf0:	0505bc03          	ld	s8,80(a1)
    80002cf4:	0585bc83          	ld	s9,88(a1)
    80002cf8:	0605bd03          	ld	s10,96(a1)
    80002cfc:	0685bd83          	ld	s11,104(a1)
    80002d00:	8082                	ret

0000000080002d02 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002d02:	1141                	addi	sp,sp,-16
    80002d04:	e422                	sd	s0,8(sp)
    80002d06:	0800                	addi	s0,sp,16
    80002d08:	872a                	mv	a4,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002d0a:	57fd                	li	a5,-1
    80002d0c:	8385                	srli	a5,a5,0x1
    80002d0e:	8fe9                	and	a5,a5,a0
  if (interrupt) {
    80002d10:	04054c63          	bltz	a0,80002d68 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002d14:	5685                	li	a3,-31
    80002d16:	8285                	srli	a3,a3,0x1
    80002d18:	8ee9                	and	a3,a3,a0
    80002d1a:	caad                	beqz	a3,80002d8c <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002d1c:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002d1e:	00006517          	auipc	a0,0x6
    80002d22:	9a250513          	addi	a0,a0,-1630 # 800086c0 <userret+0x630>
    } else if (code <= 23) {
    80002d26:	06f6f063          	bleu	a5,a3,80002d86 <scause_desc+0x84>
    } else if (code <= 31) {
    80002d2a:	fc100693          	li	a3,-63
    80002d2e:	8285                	srli	a3,a3,0x1
    80002d30:	8ef9                	and	a3,a3,a4
      return "<reserved for custom use>";
    80002d32:	00006517          	auipc	a0,0x6
    80002d36:	9b650513          	addi	a0,a0,-1610 # 800086e8 <userret+0x658>
    } else if (code <= 31) {
    80002d3a:	c6b1                	beqz	a3,80002d86 <scause_desc+0x84>
    } else if (code <= 47) {
    80002d3c:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    80002d40:	00006517          	auipc	a0,0x6
    80002d44:	98050513          	addi	a0,a0,-1664 # 800086c0 <userret+0x630>
    } else if (code <= 47) {
    80002d48:	02f6ff63          	bleu	a5,a3,80002d86 <scause_desc+0x84>
    } else if (code <= 63) {
    80002d4c:	f8100513          	li	a0,-127
    80002d50:	8105                	srli	a0,a0,0x1
    80002d52:	8f69                	and	a4,a4,a0
      return "<reserved for custom use>";
    80002d54:	00006517          	auipc	a0,0x6
    80002d58:	99450513          	addi	a0,a0,-1644 # 800086e8 <userret+0x658>
    } else if (code <= 63) {
    80002d5c:	c70d                	beqz	a4,80002d86 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    80002d5e:	00006517          	auipc	a0,0x6
    80002d62:	96250513          	addi	a0,a0,-1694 # 800086c0 <userret+0x630>
    80002d66:	a005                	j	80002d86 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    80002d68:	5505                	li	a0,-31
    80002d6a:	8105                	srli	a0,a0,0x1
    80002d6c:	8f69                	and	a4,a4,a0
      return "<reserved for platform use>";
    80002d6e:	00006517          	auipc	a0,0x6
    80002d72:	99a50513          	addi	a0,a0,-1638 # 80008708 <userret+0x678>
    if (code < NELEM(intr_desc)) {
    80002d76:	eb01                	bnez	a4,80002d86 <scause_desc+0x84>
      return intr_desc[code];
    80002d78:	078e                	slli	a5,a5,0x3
    80002d7a:	00006717          	auipc	a4,0x6
    80002d7e:	1b670713          	addi	a4,a4,438 # 80008f30 <intr_desc.1649>
    80002d82:	97ba                	add	a5,a5,a4
    80002d84:	6388                	ld	a0,0(a5)
    }
  }
}
    80002d86:	6422                	ld	s0,8(sp)
    80002d88:	0141                	addi	sp,sp,16
    80002d8a:	8082                	ret
      return nointr_desc[code];
    80002d8c:	078e                	slli	a5,a5,0x3
    80002d8e:	00006717          	auipc	a4,0x6
    80002d92:	1a270713          	addi	a4,a4,418 # 80008f30 <intr_desc.1649>
    80002d96:	97ba                	add	a5,a5,a4
    80002d98:	63c8                	ld	a0,128(a5)
    80002d9a:	b7f5                	j	80002d86 <scause_desc+0x84>

0000000080002d9c <trapinit>:
{
    80002d9c:	1141                	addi	sp,sp,-16
    80002d9e:	e406                	sd	ra,8(sp)
    80002da0:	e022                	sd	s0,0(sp)
    80002da2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002da4:	00006597          	auipc	a1,0x6
    80002da8:	98458593          	addi	a1,a1,-1660 # 80008728 <userret+0x698>
    80002dac:	00019517          	auipc	a0,0x19
    80002db0:	2ec50513          	addi	a0,a0,748 # 8001c098 <tickslock>
    80002db4:	ffffe097          	auipc	ra,0xffffe
    80002db8:	d98080e7          	jalr	-616(ra) # 80000b4c <initlock>
}
    80002dbc:	60a2                	ld	ra,8(sp)
    80002dbe:	6402                	ld	s0,0(sp)
    80002dc0:	0141                	addi	sp,sp,16
    80002dc2:	8082                	ret

0000000080002dc4 <trapinithart>:
{
    80002dc4:	1141                	addi	sp,sp,-16
    80002dc6:	e422                	sd	s0,8(sp)
    80002dc8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002dca:	00003797          	auipc	a5,0x3
    80002dce:	74678793          	addi	a5,a5,1862 # 80006510 <kernelvec>
    80002dd2:	10579073          	csrw	stvec,a5
}
    80002dd6:	6422                	ld	s0,8(sp)
    80002dd8:	0141                	addi	sp,sp,16
    80002dda:	8082                	ret

0000000080002ddc <usertrapret>:
{
    80002ddc:	1141                	addi	sp,sp,-16
    80002dde:	e406                	sd	ra,8(sp)
    80002de0:	e022                	sd	s0,0(sp)
    80002de2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002de4:	fffff097          	auipc	ra,0xfffff
    80002de8:	25c080e7          	jalr	604(ra) # 80002040 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002df0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002df2:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002df6:	00005617          	auipc	a2,0x5
    80002dfa:	20a60613          	addi	a2,a2,522 # 80008000 <trampoline>
    80002dfe:	00005697          	auipc	a3,0x5
    80002e02:	20268693          	addi	a3,a3,514 # 80008000 <trampoline>
    80002e06:	8e91                	sub	a3,a3,a2
    80002e08:	040007b7          	lui	a5,0x4000
    80002e0c:	17fd                	addi	a5,a5,-1
    80002e0e:	07b2                	slli	a5,a5,0xc
    80002e10:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e12:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002e16:	7938                	ld	a4,112(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002e18:	180026f3          	csrr	a3,satp
    80002e1c:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002e1e:	7938                	ld	a4,112(a0)
    80002e20:	6d34                	ld	a3,88(a0)
    80002e22:	6585                	lui	a1,0x1
    80002e24:	96ae                	add	a3,a3,a1
    80002e26:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002e28:	7938                	ld	a4,112(a0)
    80002e2a:	00000697          	auipc	a3,0x0
    80002e2e:	18468693          	addi	a3,a3,388 # 80002fae <usertrap>
    80002e32:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    80002e34:	7938                	ld	a4,112(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002e36:	8692                	mv	a3,tp
    80002e38:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e3a:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002e3e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002e42:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e46:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    80002e4a:	7938                	ld	a4,112(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e4c:	6f18                	ld	a4,24(a4)
    80002e4e:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002e52:	752c                	ld	a1,104(a0)
    80002e54:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002e56:	00005717          	auipc	a4,0x5
    80002e5a:	23a70713          	addi	a4,a4,570 # 80008090 <userret>
    80002e5e:	8f11                	sub	a4,a4,a2
    80002e60:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002e62:	577d                	li	a4,-1
    80002e64:	177e                	slli	a4,a4,0x3f
    80002e66:	8dd9                	or	a1,a1,a4
    80002e68:	02000537          	lui	a0,0x2000
    80002e6c:	157d                	addi	a0,a0,-1
    80002e6e:	0536                	slli	a0,a0,0xd
    80002e70:	9782                	jalr	a5
}
    80002e72:	60a2                	ld	ra,8(sp)
    80002e74:	6402                	ld	s0,0(sp)
    80002e76:	0141                	addi	sp,sp,16
    80002e78:	8082                	ret

0000000080002e7a <clockintr>:
{
    80002e7a:	1141                	addi	sp,sp,-16
    80002e7c:	e406                	sd	ra,8(sp)
    80002e7e:	e022                	sd	s0,0(sp)
    80002e80:	0800                	addi	s0,sp,16
  acquire(&watchdog_lock);
    80002e82:	0002b517          	auipc	a0,0x2b
    80002e86:	1ae50513          	addi	a0,a0,430 # 8002e030 <watchdog_lock>
    80002e8a:	ffffe097          	auipc	ra,0xffffe
    80002e8e:	e30080e7          	jalr	-464(ra) # 80000cba <acquire>
  acquire(&tickslock);
    80002e92:	00019517          	auipc	a0,0x19
    80002e96:	20650513          	addi	a0,a0,518 # 8001c098 <tickslock>
    80002e9a:	ffffe097          	auipc	ra,0xffffe
    80002e9e:	e20080e7          	jalr	-480(ra) # 80000cba <acquire>
  if (watchdog_time && ticks - watchdog_value > watchdog_time){
    80002ea2:	0002b797          	auipc	a5,0x2b
    80002ea6:	20278793          	addi	a5,a5,514 # 8002e0a4 <watchdog_time>
    80002eaa:	439c                	lw	a5,0(a5)
    80002eac:	cf99                	beqz	a5,80002eca <clockintr+0x50>
    80002eae:	0002b717          	auipc	a4,0x2b
    80002eb2:	1da70713          	addi	a4,a4,474 # 8002e088 <ticks>
    80002eb6:	4318                	lw	a4,0(a4)
    80002eb8:	0002b697          	auipc	a3,0x2b
    80002ebc:	1f068693          	addi	a3,a3,496 # 8002e0a8 <watchdog_value>
    80002ec0:	4294                	lw	a3,0(a3)
    80002ec2:	9f15                	subw	a4,a4,a3
    80002ec4:	2781                	sext.w	a5,a5
    80002ec6:	04e7e163          	bltu	a5,a4,80002f08 <clockintr+0x8e>
  ticks++;
    80002eca:	0002b517          	auipc	a0,0x2b
    80002ece:	1be50513          	addi	a0,a0,446 # 8002e088 <ticks>
    80002ed2:	411c                	lw	a5,0(a0)
    80002ed4:	2785                	addiw	a5,a5,1
    80002ed6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002ed8:	00000097          	auipc	ra,0x0
    80002edc:	af2080e7          	jalr	-1294(ra) # 800029ca <wakeup>
  release(&tickslock);
    80002ee0:	00019517          	auipc	a0,0x19
    80002ee4:	1b850513          	addi	a0,a0,440 # 8001c098 <tickslock>
    80002ee8:	ffffe097          	auipc	ra,0xffffe
    80002eec:	01e080e7          	jalr	30(ra) # 80000f06 <release>
  release(&watchdog_lock);
    80002ef0:	0002b517          	auipc	a0,0x2b
    80002ef4:	14050513          	addi	a0,a0,320 # 8002e030 <watchdog_lock>
    80002ef8:	ffffe097          	auipc	ra,0xffffe
    80002efc:	00e080e7          	jalr	14(ra) # 80000f06 <release>
}
    80002f00:	60a2                	ld	ra,8(sp)
    80002f02:	6402                	ld	s0,0(sp)
    80002f04:	0141                	addi	sp,sp,16
    80002f06:	8082                	ret
    panic("watchdog !!!");
    80002f08:	00006517          	auipc	a0,0x6
    80002f0c:	82850513          	addi	a0,a0,-2008 # 80008730 <userret+0x6a0>
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	874080e7          	jalr	-1932(ra) # 80000784 <panic>

0000000080002f18 <devintr>:
{
    80002f18:	1101                	addi	sp,sp,-32
    80002f1a:	ec06                	sd	ra,24(sp)
    80002f1c:	e822                	sd	s0,16(sp)
    80002f1e:	e426                	sd	s1,8(sp)
    80002f20:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f22:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002f26:	00074d63          	bltz	a4,80002f40 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002f2a:	57fd                	li	a5,-1
    80002f2c:	17fe                	slli	a5,a5,0x3f
    80002f2e:	0785                	addi	a5,a5,1
    return 0;
    80002f30:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002f32:	04f70d63          	beq	a4,a5,80002f8c <devintr+0x74>
}
    80002f36:	60e2                	ld	ra,24(sp)
    80002f38:	6442                	ld	s0,16(sp)
    80002f3a:	64a2                	ld	s1,8(sp)
    80002f3c:	6105                	addi	sp,sp,32
    80002f3e:	8082                	ret
     (scause & 0xff) == 9){
    80002f40:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002f44:	46a5                	li	a3,9
    80002f46:	fed792e3          	bne	a5,a3,80002f2a <devintr+0x12>
    int irq = plic_claim();
    80002f4a:	00003097          	auipc	ra,0x3
    80002f4e:	6ce080e7          	jalr	1742(ra) # 80006618 <plic_claim>
    80002f52:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002f54:	47a9                	li	a5,10
    80002f56:	00f50a63          	beq	a0,a5,80002f6a <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80002f5a:	fff5079b          	addiw	a5,a0,-1
    80002f5e:	4705                	li	a4,1
    80002f60:	00f77a63          	bleu	a5,a4,80002f74 <devintr+0x5c>
    return 1;
    80002f64:	4505                	li	a0,1
    if(irq)
    80002f66:	d8e1                	beqz	s1,80002f36 <devintr+0x1e>
    80002f68:	a819                	j	80002f7e <devintr+0x66>
      uartintr();
    80002f6a:	ffffe097          	auipc	ra,0xffffe
    80002f6e:	b5c080e7          	jalr	-1188(ra) # 80000ac6 <uartintr>
    80002f72:	a031                	j	80002f7e <devintr+0x66>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    80002f74:	853e                	mv	a0,a5
    80002f76:	00004097          	auipc	ra,0x4
    80002f7a:	c98080e7          	jalr	-872(ra) # 80006c0e <virtio_disk_intr>
      plic_complete(irq);
    80002f7e:	8526                	mv	a0,s1
    80002f80:	00003097          	auipc	ra,0x3
    80002f84:	6bc080e7          	jalr	1724(ra) # 8000663c <plic_complete>
    return 1;
    80002f88:	4505                	li	a0,1
    80002f8a:	b775                	j	80002f36 <devintr+0x1e>
    if(cpuid() == 0){
    80002f8c:	fffff097          	auipc	ra,0xfffff
    80002f90:	088080e7          	jalr	136(ra) # 80002014 <cpuid>
    80002f94:	c901                	beqz	a0,80002fa4 <devintr+0x8c>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002f96:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002f9a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002f9c:	14479073          	csrw	sip,a5
    return 2;
    80002fa0:	4509                	li	a0,2
    80002fa2:	bf51                	j	80002f36 <devintr+0x1e>
      clockintr();
    80002fa4:	00000097          	auipc	ra,0x0
    80002fa8:	ed6080e7          	jalr	-298(ra) # 80002e7a <clockintr>
    80002fac:	b7ed                	j	80002f96 <devintr+0x7e>

0000000080002fae <usertrap>:
{
    80002fae:	7179                	addi	sp,sp,-48
    80002fb0:	f406                	sd	ra,40(sp)
    80002fb2:	f022                	sd	s0,32(sp)
    80002fb4:	ec26                	sd	s1,24(sp)
    80002fb6:	e84a                	sd	s2,16(sp)
    80002fb8:	e44e                	sd	s3,8(sp)
    80002fba:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fbc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002fc0:	1007f793          	andi	a5,a5,256
    80002fc4:	e3b5                	bnez	a5,80003028 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002fc6:	00003797          	auipc	a5,0x3
    80002fca:	54a78793          	addi	a5,a5,1354 # 80006510 <kernelvec>
    80002fce:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002fd2:	fffff097          	auipc	ra,0xfffff
    80002fd6:	06e080e7          	jalr	110(ra) # 80002040 <myproc>
    80002fda:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002fdc:	793c                	ld	a5,112(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fde:	14102773          	csrr	a4,sepc
    80002fe2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fe4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002fe8:	47a1                	li	a5,8
    80002fea:	04f71d63          	bne	a4,a5,80003044 <usertrap+0x96>
    if(p->killed)
    80002fee:	453c                	lw	a5,72(a0)
    80002ff0:	e7a1                	bnez	a5,80003038 <usertrap+0x8a>
    p->tf->epc += 4;
    80002ff2:	78b8                	ld	a4,112(s1)
    80002ff4:	6f1c                	ld	a5,24(a4)
    80002ff6:	0791                	addi	a5,a5,4
    80002ff8:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ffa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ffe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003002:	10079073          	csrw	sstatus,a5
    syscall();
    80003006:	00000097          	auipc	ra,0x0
    8000300a:	304080e7          	jalr	772(ra) # 8000330a <syscall>
  if(p->killed)
    8000300e:	44bc                	lw	a5,72(s1)
    80003010:	e3cd                	bnez	a5,800030b2 <usertrap+0x104>
  usertrapret();
    80003012:	00000097          	auipc	ra,0x0
    80003016:	dca080e7          	jalr	-566(ra) # 80002ddc <usertrapret>
}
    8000301a:	70a2                	ld	ra,40(sp)
    8000301c:	7402                	ld	s0,32(sp)
    8000301e:	64e2                	ld	s1,24(sp)
    80003020:	6942                	ld	s2,16(sp)
    80003022:	69a2                	ld	s3,8(sp)
    80003024:	6145                	addi	sp,sp,48
    80003026:	8082                	ret
    panic("usertrap: not from user mode");
    80003028:	00005517          	auipc	a0,0x5
    8000302c:	71850513          	addi	a0,a0,1816 # 80008740 <userret+0x6b0>
    80003030:	ffffd097          	auipc	ra,0xffffd
    80003034:	754080e7          	jalr	1876(ra) # 80000784 <panic>
      exit(-1);
    80003038:	557d                	li	a0,-1
    8000303a:	fffff097          	auipc	ra,0xfffff
    8000303e:	6be080e7          	jalr	1726(ra) # 800026f8 <exit>
    80003042:	bf45                	j	80002ff2 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80003044:	00000097          	auipc	ra,0x0
    80003048:	ed4080e7          	jalr	-300(ra) # 80002f18 <devintr>
    8000304c:	892a                	mv	s2,a0
    8000304e:	c501                	beqz	a0,80003056 <usertrap+0xa8>
  if(p->killed)
    80003050:	44bc                	lw	a5,72(s1)
    80003052:	cba1                	beqz	a5,800030a2 <usertrap+0xf4>
    80003054:	a091                	j	80003098 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003056:	142029f3          	csrr	s3,scause
    8000305a:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    8000305e:	00000097          	auipc	ra,0x0
    80003062:	ca4080e7          	jalr	-860(ra) # 80002d02 <scause_desc>
    80003066:	48b4                	lw	a3,80(s1)
    80003068:	862a                	mv	a2,a0
    8000306a:	85ce                	mv	a1,s3
    8000306c:	00005517          	auipc	a0,0x5
    80003070:	6f450513          	addi	a0,a0,1780 # 80008760 <userret+0x6d0>
    80003074:	ffffe097          	auipc	ra,0xffffe
    80003078:	928080e7          	jalr	-1752(ra) # 8000099c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000307c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003080:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003084:	00005517          	auipc	a0,0x5
    80003088:	70c50513          	addi	a0,a0,1804 # 80008790 <userret+0x700>
    8000308c:	ffffe097          	auipc	ra,0xffffe
    80003090:	910080e7          	jalr	-1776(ra) # 8000099c <printf>
    p->killed = 1;
    80003094:	4785                	li	a5,1
    80003096:	c4bc                	sw	a5,72(s1)
    exit(-1);
    80003098:	557d                	li	a0,-1
    8000309a:	fffff097          	auipc	ra,0xfffff
    8000309e:	65e080e7          	jalr	1630(ra) # 800026f8 <exit>
  if(which_dev == 2)
    800030a2:	4789                	li	a5,2
    800030a4:	f6f917e3          	bne	s2,a5,80003012 <usertrap+0x64>
    yield();
    800030a8:	fffff097          	auipc	ra,0xfffff
    800030ac:	760080e7          	jalr	1888(ra) # 80002808 <yield>
    800030b0:	b78d                	j	80003012 <usertrap+0x64>
  int which_dev = 0;
    800030b2:	4901                	li	s2,0
    800030b4:	b7d5                	j	80003098 <usertrap+0xea>

00000000800030b6 <kerneltrap>:
{
    800030b6:	7179                	addi	sp,sp,-48
    800030b8:	f406                	sd	ra,40(sp)
    800030ba:	f022                	sd	s0,32(sp)
    800030bc:	ec26                	sd	s1,24(sp)
    800030be:	e84a                	sd	s2,16(sp)
    800030c0:	e44e                	sd	s3,8(sp)
    800030c2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030c4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030c8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030cc:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800030d0:	1004f793          	andi	a5,s1,256
    800030d4:	cb85                	beqz	a5,80003104 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030d6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800030da:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800030dc:	ef85                	bnez	a5,80003114 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800030de:	00000097          	auipc	ra,0x0
    800030e2:	e3a080e7          	jalr	-454(ra) # 80002f18 <devintr>
    800030e6:	cd1d                	beqz	a0,80003124 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030e8:	4789                	li	a5,2
    800030ea:	08f50063          	beq	a0,a5,8000316a <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800030ee:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030f2:	10049073          	csrw	sstatus,s1
}
    800030f6:	70a2                	ld	ra,40(sp)
    800030f8:	7402                	ld	s0,32(sp)
    800030fa:	64e2                	ld	s1,24(sp)
    800030fc:	6942                	ld	s2,16(sp)
    800030fe:	69a2                	ld	s3,8(sp)
    80003100:	6145                	addi	sp,sp,48
    80003102:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003104:	00005517          	auipc	a0,0x5
    80003108:	6ac50513          	addi	a0,a0,1708 # 800087b0 <userret+0x720>
    8000310c:	ffffd097          	auipc	ra,0xffffd
    80003110:	678080e7          	jalr	1656(ra) # 80000784 <panic>
    panic("kerneltrap: interrupts enabled");
    80003114:	00005517          	auipc	a0,0x5
    80003118:	6c450513          	addi	a0,a0,1732 # 800087d8 <userret+0x748>
    8000311c:	ffffd097          	auipc	ra,0xffffd
    80003120:	668080e7          	jalr	1640(ra) # 80000784 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80003124:	854e                	mv	a0,s3
    80003126:	00000097          	auipc	ra,0x0
    8000312a:	bdc080e7          	jalr	-1060(ra) # 80002d02 <scause_desc>
    8000312e:	862a                	mv	a2,a0
    80003130:	85ce                	mv	a1,s3
    80003132:	00005517          	auipc	a0,0x5
    80003136:	6c650513          	addi	a0,a0,1734 # 800087f8 <userret+0x768>
    8000313a:	ffffe097          	auipc	ra,0xffffe
    8000313e:	862080e7          	jalr	-1950(ra) # 8000099c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003142:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003146:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000314a:	00005517          	auipc	a0,0x5
    8000314e:	6be50513          	addi	a0,a0,1726 # 80008808 <userret+0x778>
    80003152:	ffffe097          	auipc	ra,0xffffe
    80003156:	84a080e7          	jalr	-1974(ra) # 8000099c <printf>
    panic("kerneltrap");
    8000315a:	00005517          	auipc	a0,0x5
    8000315e:	6c650513          	addi	a0,a0,1734 # 80008820 <userret+0x790>
    80003162:	ffffd097          	auipc	ra,0xffffd
    80003166:	622080e7          	jalr	1570(ra) # 80000784 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000316a:	fffff097          	auipc	ra,0xfffff
    8000316e:	ed6080e7          	jalr	-298(ra) # 80002040 <myproc>
    80003172:	dd35                	beqz	a0,800030ee <kerneltrap+0x38>
    80003174:	fffff097          	auipc	ra,0xfffff
    80003178:	ecc080e7          	jalr	-308(ra) # 80002040 <myproc>
    8000317c:	5918                	lw	a4,48(a0)
    8000317e:	478d                	li	a5,3
    80003180:	f6f717e3          	bne	a4,a5,800030ee <kerneltrap+0x38>
    yield();
    80003184:	fffff097          	auipc	ra,0xfffff
    80003188:	684080e7          	jalr	1668(ra) # 80002808 <yield>
    8000318c:	b78d                	j	800030ee <kerneltrap+0x38>

000000008000318e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000318e:	1101                	addi	sp,sp,-32
    80003190:	ec06                	sd	ra,24(sp)
    80003192:	e822                	sd	s0,16(sp)
    80003194:	e426                	sd	s1,8(sp)
    80003196:	1000                	addi	s0,sp,32
    80003198:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000319a:	fffff097          	auipc	ra,0xfffff
    8000319e:	ea6080e7          	jalr	-346(ra) # 80002040 <myproc>
  switch (n) {
    800031a2:	4795                	li	a5,5
    800031a4:	0497e363          	bltu	a5,s1,800031ea <argraw+0x5c>
    800031a8:	1482                	slli	s1,s1,0x20
    800031aa:	9081                	srli	s1,s1,0x20
    800031ac:	048a                	slli	s1,s1,0x2
    800031ae:	00006717          	auipc	a4,0x6
    800031b2:	e8270713          	addi	a4,a4,-382 # 80009030 <nointr_desc.1650+0x80>
    800031b6:	94ba                	add	s1,s1,a4
    800031b8:	409c                	lw	a5,0(s1)
    800031ba:	97ba                	add	a5,a5,a4
    800031bc:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    800031be:	793c                	ld	a5,112(a0)
    800031c0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    800031c2:	60e2                	ld	ra,24(sp)
    800031c4:	6442                	ld	s0,16(sp)
    800031c6:	64a2                	ld	s1,8(sp)
    800031c8:	6105                	addi	sp,sp,32
    800031ca:	8082                	ret
    return p->tf->a1;
    800031cc:	793c                	ld	a5,112(a0)
    800031ce:	7fa8                	ld	a0,120(a5)
    800031d0:	bfcd                	j	800031c2 <argraw+0x34>
    return p->tf->a2;
    800031d2:	793c                	ld	a5,112(a0)
    800031d4:	63c8                	ld	a0,128(a5)
    800031d6:	b7f5                	j	800031c2 <argraw+0x34>
    return p->tf->a3;
    800031d8:	793c                	ld	a5,112(a0)
    800031da:	67c8                	ld	a0,136(a5)
    800031dc:	b7dd                	j	800031c2 <argraw+0x34>
    return p->tf->a4;
    800031de:	793c                	ld	a5,112(a0)
    800031e0:	6bc8                	ld	a0,144(a5)
    800031e2:	b7c5                	j	800031c2 <argraw+0x34>
    return p->tf->a5;
    800031e4:	793c                	ld	a5,112(a0)
    800031e6:	6fc8                	ld	a0,152(a5)
    800031e8:	bfe9                	j	800031c2 <argraw+0x34>
  panic("argraw");
    800031ea:	00006517          	auipc	a0,0x6
    800031ee:	83e50513          	addi	a0,a0,-1986 # 80008a28 <userret+0x998>
    800031f2:	ffffd097          	auipc	ra,0xffffd
    800031f6:	592080e7          	jalr	1426(ra) # 80000784 <panic>

00000000800031fa <fetchaddr>:
{
    800031fa:	1101                	addi	sp,sp,-32
    800031fc:	ec06                	sd	ra,24(sp)
    800031fe:	e822                	sd	s0,16(sp)
    80003200:	e426                	sd	s1,8(sp)
    80003202:	e04a                	sd	s2,0(sp)
    80003204:	1000                	addi	s0,sp,32
    80003206:	84aa                	mv	s1,a0
    80003208:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000320a:	fffff097          	auipc	ra,0xfffff
    8000320e:	e36080e7          	jalr	-458(ra) # 80002040 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003212:	713c                	ld	a5,96(a0)
    80003214:	02f4f963          	bleu	a5,s1,80003246 <fetchaddr+0x4c>
    80003218:	00848713          	addi	a4,s1,8
    8000321c:	02e7e763          	bltu	a5,a4,8000324a <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003220:	46a1                	li	a3,8
    80003222:	8626                	mv	a2,s1
    80003224:	85ca                	mv	a1,s2
    80003226:	7528                	ld	a0,104(a0)
    80003228:	fffff097          	auipc	ra,0xfffff
    8000322c:	a82080e7          	jalr	-1406(ra) # 80001caa <copyin>
    80003230:	00a03533          	snez	a0,a0
    80003234:	40a0053b          	negw	a0,a0
    80003238:	2501                	sext.w	a0,a0
}
    8000323a:	60e2                	ld	ra,24(sp)
    8000323c:	6442                	ld	s0,16(sp)
    8000323e:	64a2                	ld	s1,8(sp)
    80003240:	6902                	ld	s2,0(sp)
    80003242:	6105                	addi	sp,sp,32
    80003244:	8082                	ret
    return -1;
    80003246:	557d                	li	a0,-1
    80003248:	bfcd                	j	8000323a <fetchaddr+0x40>
    8000324a:	557d                	li	a0,-1
    8000324c:	b7fd                	j	8000323a <fetchaddr+0x40>

000000008000324e <fetchstr>:
{
    8000324e:	7179                	addi	sp,sp,-48
    80003250:	f406                	sd	ra,40(sp)
    80003252:	f022                	sd	s0,32(sp)
    80003254:	ec26                	sd	s1,24(sp)
    80003256:	e84a                	sd	s2,16(sp)
    80003258:	e44e                	sd	s3,8(sp)
    8000325a:	1800                	addi	s0,sp,48
    8000325c:	892a                	mv	s2,a0
    8000325e:	84ae                	mv	s1,a1
    80003260:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003262:	fffff097          	auipc	ra,0xfffff
    80003266:	dde080e7          	jalr	-546(ra) # 80002040 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    8000326a:	86ce                	mv	a3,s3
    8000326c:	864a                	mv	a2,s2
    8000326e:	85a6                	mv	a1,s1
    80003270:	7528                	ld	a0,104(a0)
    80003272:	fffff097          	auipc	ra,0xfffff
    80003276:	ac6080e7          	jalr	-1338(ra) # 80001d38 <copyinstr>
  if(err < 0)
    8000327a:	00054763          	bltz	a0,80003288 <fetchstr+0x3a>
  return strlen(buf);
    8000327e:	8526                	mv	a0,s1
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	058080e7          	jalr	88(ra) # 800012d8 <strlen>
}
    80003288:	70a2                	ld	ra,40(sp)
    8000328a:	7402                	ld	s0,32(sp)
    8000328c:	64e2                	ld	s1,24(sp)
    8000328e:	6942                	ld	s2,16(sp)
    80003290:	69a2                	ld	s3,8(sp)
    80003292:	6145                	addi	sp,sp,48
    80003294:	8082                	ret

0000000080003296 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003296:	1101                	addi	sp,sp,-32
    80003298:	ec06                	sd	ra,24(sp)
    8000329a:	e822                	sd	s0,16(sp)
    8000329c:	e426                	sd	s1,8(sp)
    8000329e:	1000                	addi	s0,sp,32
    800032a0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032a2:	00000097          	auipc	ra,0x0
    800032a6:	eec080e7          	jalr	-276(ra) # 8000318e <argraw>
    800032aa:	c088                	sw	a0,0(s1)
  return 0;
}
    800032ac:	4501                	li	a0,0
    800032ae:	60e2                	ld	ra,24(sp)
    800032b0:	6442                	ld	s0,16(sp)
    800032b2:	64a2                	ld	s1,8(sp)
    800032b4:	6105                	addi	sp,sp,32
    800032b6:	8082                	ret

00000000800032b8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800032b8:	1101                	addi	sp,sp,-32
    800032ba:	ec06                	sd	ra,24(sp)
    800032bc:	e822                	sd	s0,16(sp)
    800032be:	e426                	sd	s1,8(sp)
    800032c0:	1000                	addi	s0,sp,32
    800032c2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032c4:	00000097          	auipc	ra,0x0
    800032c8:	eca080e7          	jalr	-310(ra) # 8000318e <argraw>
    800032cc:	e088                	sd	a0,0(s1)
  return 0;
}
    800032ce:	4501                	li	a0,0
    800032d0:	60e2                	ld	ra,24(sp)
    800032d2:	6442                	ld	s0,16(sp)
    800032d4:	64a2                	ld	s1,8(sp)
    800032d6:	6105                	addi	sp,sp,32
    800032d8:	8082                	ret

00000000800032da <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800032da:	1101                	addi	sp,sp,-32
    800032dc:	ec06                	sd	ra,24(sp)
    800032de:	e822                	sd	s0,16(sp)
    800032e0:	e426                	sd	s1,8(sp)
    800032e2:	e04a                	sd	s2,0(sp)
    800032e4:	1000                	addi	s0,sp,32
    800032e6:	84ae                	mv	s1,a1
    800032e8:	8932                	mv	s2,a2
  *ip = argraw(n);
    800032ea:	00000097          	auipc	ra,0x0
    800032ee:	ea4080e7          	jalr	-348(ra) # 8000318e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    800032f2:	864a                	mv	a2,s2
    800032f4:	85a6                	mv	a1,s1
    800032f6:	00000097          	auipc	ra,0x0
    800032fa:	f58080e7          	jalr	-168(ra) # 8000324e <fetchstr>
}
    800032fe:	60e2                	ld	ra,24(sp)
    80003300:	6442                	ld	s0,16(sp)
    80003302:	64a2                	ld	s1,8(sp)
    80003304:	6902                	ld	s2,0(sp)
    80003306:	6105                	addi	sp,sp,32
    80003308:	8082                	ret

000000008000330a <syscall>:
[SYS_release_mutex]  sys_release_mutex,
};

void
syscall(void)
{
    8000330a:	1101                	addi	sp,sp,-32
    8000330c:	ec06                	sd	ra,24(sp)
    8000330e:	e822                	sd	s0,16(sp)
    80003310:	e426                	sd	s1,8(sp)
    80003312:	e04a                	sd	s2,0(sp)
    80003314:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003316:	fffff097          	auipc	ra,0xfffff
    8000331a:	d2a080e7          	jalr	-726(ra) # 80002040 <myproc>
    8000331e:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80003320:	07053903          	ld	s2,112(a0)
    80003324:	0a893783          	ld	a5,168(s2)
    80003328:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000332c:	37fd                	addiw	a5,a5,-1
    8000332e:	4765                	li	a4,25
    80003330:	00f76f63          	bltu	a4,a5,8000334e <syscall+0x44>
    80003334:	00369713          	slli	a4,a3,0x3
    80003338:	00006797          	auipc	a5,0x6
    8000333c:	d1078793          	addi	a5,a5,-752 # 80009048 <syscalls>
    80003340:	97ba                	add	a5,a5,a4
    80003342:	639c                	ld	a5,0(a5)
    80003344:	c789                	beqz	a5,8000334e <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80003346:	9782                	jalr	a5
    80003348:	06a93823          	sd	a0,112(s2)
    8000334c:	a839                	j	8000336a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000334e:	17048613          	addi	a2,s1,368
    80003352:	48ac                	lw	a1,80(s1)
    80003354:	00005517          	auipc	a0,0x5
    80003358:	6dc50513          	addi	a0,a0,1756 # 80008a30 <userret+0x9a0>
    8000335c:	ffffd097          	auipc	ra,0xffffd
    80003360:	640080e7          	jalr	1600(ra) # 8000099c <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80003364:	78bc                	ld	a5,112(s1)
    80003366:	577d                	li	a4,-1
    80003368:	fbb8                	sd	a4,112(a5)
  }
}
    8000336a:	60e2                	ld	ra,24(sp)
    8000336c:	6442                	ld	s0,16(sp)
    8000336e:	64a2                	ld	s1,8(sp)
    80003370:	6902                	ld	s2,0(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret

0000000080003376 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003376:	1101                	addi	sp,sp,-32
    80003378:	ec06                	sd	ra,24(sp)
    8000337a:	e822                	sd	s0,16(sp)
    8000337c:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    8000337e:	fec40593          	addi	a1,s0,-20
    80003382:	4501                	li	a0,0
    80003384:	00000097          	auipc	ra,0x0
    80003388:	f12080e7          	jalr	-238(ra) # 80003296 <argint>
    return -1;
    8000338c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000338e:	00054963          	bltz	a0,800033a0 <sys_exit+0x2a>
  exit(n);
    80003392:	fec42503          	lw	a0,-20(s0)
    80003396:	fffff097          	auipc	ra,0xfffff
    8000339a:	362080e7          	jalr	866(ra) # 800026f8 <exit>
  return 0;  // not reached
    8000339e:	4781                	li	a5,0
}
    800033a0:	853e                	mv	a0,a5
    800033a2:	60e2                	ld	ra,24(sp)
    800033a4:	6442                	ld	s0,16(sp)
    800033a6:	6105                	addi	sp,sp,32
    800033a8:	8082                	ret

00000000800033aa <sys_getpid>:

uint64
sys_getpid(void)
{
    800033aa:	1141                	addi	sp,sp,-16
    800033ac:	e406                	sd	ra,8(sp)
    800033ae:	e022                	sd	s0,0(sp)
    800033b0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800033b2:	fffff097          	auipc	ra,0xfffff
    800033b6:	c8e080e7          	jalr	-882(ra) # 80002040 <myproc>
}
    800033ba:	4928                	lw	a0,80(a0)
    800033bc:	60a2                	ld	ra,8(sp)
    800033be:	6402                	ld	s0,0(sp)
    800033c0:	0141                	addi	sp,sp,16
    800033c2:	8082                	ret

00000000800033c4 <sys_fork>:

uint64
sys_fork(void)
{
    800033c4:	1141                	addi	sp,sp,-16
    800033c6:	e406                	sd	ra,8(sp)
    800033c8:	e022                	sd	s0,0(sp)
    800033ca:	0800                	addi	s0,sp,16
  return fork();
    800033cc:	fffff097          	auipc	ra,0xfffff
    800033d0:	012080e7          	jalr	18(ra) # 800023de <fork>
}
    800033d4:	60a2                	ld	ra,8(sp)
    800033d6:	6402                	ld	s0,0(sp)
    800033d8:	0141                	addi	sp,sp,16
    800033da:	8082                	ret

00000000800033dc <sys_wait>:

uint64
sys_wait(void)
{
    800033dc:	1101                	addi	sp,sp,-32
    800033de:	ec06                	sd	ra,24(sp)
    800033e0:	e822                	sd	s0,16(sp)
    800033e2:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800033e4:	fe840593          	addi	a1,s0,-24
    800033e8:	4501                	li	a0,0
    800033ea:	00000097          	auipc	ra,0x0
    800033ee:	ece080e7          	jalr	-306(ra) # 800032b8 <argaddr>
    return -1;
    800033f2:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    800033f4:	00054963          	bltz	a0,80003406 <sys_wait+0x2a>
  return wait(p);
    800033f8:	fe843503          	ld	a0,-24(s0)
    800033fc:	fffff097          	auipc	ra,0xfffff
    80003400:	4c6080e7          	jalr	1222(ra) # 800028c2 <wait>
    80003404:	87aa                	mv	a5,a0
}
    80003406:	853e                	mv	a0,a5
    80003408:	60e2                	ld	ra,24(sp)
    8000340a:	6442                	ld	s0,16(sp)
    8000340c:	6105                	addi	sp,sp,32
    8000340e:	8082                	ret

0000000080003410 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003410:	7179                	addi	sp,sp,-48
    80003412:	f406                	sd	ra,40(sp)
    80003414:	f022                	sd	s0,32(sp)
    80003416:	ec26                	sd	s1,24(sp)
    80003418:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000341a:	fdc40593          	addi	a1,s0,-36
    8000341e:	4501                	li	a0,0
    80003420:	00000097          	auipc	ra,0x0
    80003424:	e76080e7          	jalr	-394(ra) # 80003296 <argint>
    return -1;
    80003428:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000342a:	00054f63          	bltz	a0,80003448 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000342e:	fffff097          	auipc	ra,0xfffff
    80003432:	c12080e7          	jalr	-1006(ra) # 80002040 <myproc>
    80003436:	5124                	lw	s1,96(a0)
  if(growproc(n) < 0)
    80003438:	fdc42503          	lw	a0,-36(s0)
    8000343c:	fffff097          	auipc	ra,0xfffff
    80003440:	f2a080e7          	jalr	-214(ra) # 80002366 <growproc>
    80003444:	00054863          	bltz	a0,80003454 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003448:	8526                	mv	a0,s1
    8000344a:	70a2                	ld	ra,40(sp)
    8000344c:	7402                	ld	s0,32(sp)
    8000344e:	64e2                	ld	s1,24(sp)
    80003450:	6145                	addi	sp,sp,48
    80003452:	8082                	ret
    return -1;
    80003454:	54fd                	li	s1,-1
    80003456:	bfcd                	j	80003448 <sys_sbrk+0x38>

0000000080003458 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003458:	7139                	addi	sp,sp,-64
    8000345a:	fc06                	sd	ra,56(sp)
    8000345c:	f822                	sd	s0,48(sp)
    8000345e:	f426                	sd	s1,40(sp)
    80003460:	f04a                	sd	s2,32(sp)
    80003462:	ec4e                	sd	s3,24(sp)
    80003464:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003466:	fcc40593          	addi	a1,s0,-52
    8000346a:	4501                	li	a0,0
    8000346c:	00000097          	auipc	ra,0x0
    80003470:	e2a080e7          	jalr	-470(ra) # 80003296 <argint>
    return -1;
    80003474:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003476:	06054763          	bltz	a0,800034e4 <sys_sleep+0x8c>
  acquire(&tickslock);
    8000347a:	00019517          	auipc	a0,0x19
    8000347e:	c1e50513          	addi	a0,a0,-994 # 8001c098 <tickslock>
    80003482:	ffffe097          	auipc	ra,0xffffe
    80003486:	838080e7          	jalr	-1992(ra) # 80000cba <acquire>
  ticks0 = ticks;
    8000348a:	0002b797          	auipc	a5,0x2b
    8000348e:	bfe78793          	addi	a5,a5,-1026 # 8002e088 <ticks>
    80003492:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80003496:	fcc42783          	lw	a5,-52(s0)
    8000349a:	cf85                	beqz	a5,800034d2 <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000349c:	00019997          	auipc	s3,0x19
    800034a0:	bfc98993          	addi	s3,s3,-1028 # 8001c098 <tickslock>
    800034a4:	0002b497          	auipc	s1,0x2b
    800034a8:	be448493          	addi	s1,s1,-1052 # 8002e088 <ticks>
    if(myproc()->killed){
    800034ac:	fffff097          	auipc	ra,0xfffff
    800034b0:	b94080e7          	jalr	-1132(ra) # 80002040 <myproc>
    800034b4:	453c                	lw	a5,72(a0)
    800034b6:	ef9d                	bnez	a5,800034f4 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    800034b8:	85ce                	mv	a1,s3
    800034ba:	8526                	mv	a0,s1
    800034bc:	fffff097          	auipc	ra,0xfffff
    800034c0:	388080e7          	jalr	904(ra) # 80002844 <sleep>
  while(ticks - ticks0 < n){
    800034c4:	409c                	lw	a5,0(s1)
    800034c6:	412787bb          	subw	a5,a5,s2
    800034ca:	fcc42703          	lw	a4,-52(s0)
    800034ce:	fce7efe3          	bltu	a5,a4,800034ac <sys_sleep+0x54>
  }
  release(&tickslock);
    800034d2:	00019517          	auipc	a0,0x19
    800034d6:	bc650513          	addi	a0,a0,-1082 # 8001c098 <tickslock>
    800034da:	ffffe097          	auipc	ra,0xffffe
    800034de:	a2c080e7          	jalr	-1492(ra) # 80000f06 <release>
  return 0;
    800034e2:	4781                	li	a5,0
}
    800034e4:	853e                	mv	a0,a5
    800034e6:	70e2                	ld	ra,56(sp)
    800034e8:	7442                	ld	s0,48(sp)
    800034ea:	74a2                	ld	s1,40(sp)
    800034ec:	7902                	ld	s2,32(sp)
    800034ee:	69e2                	ld	s3,24(sp)
    800034f0:	6121                	addi	sp,sp,64
    800034f2:	8082                	ret
      release(&tickslock);
    800034f4:	00019517          	auipc	a0,0x19
    800034f8:	ba450513          	addi	a0,a0,-1116 # 8001c098 <tickslock>
    800034fc:	ffffe097          	auipc	ra,0xffffe
    80003500:	a0a080e7          	jalr	-1526(ra) # 80000f06 <release>
      return -1;
    80003504:	57fd                	li	a5,-1
    80003506:	bff9                	j	800034e4 <sys_sleep+0x8c>

0000000080003508 <sys_nice>:

uint64
sys_nice(void){
    80003508:	1141                	addi	sp,sp,-16
    8000350a:	e422                	sd	s0,8(sp)
    8000350c:	0800                	addi	s0,sp,16
  return 0;
}
    8000350e:	4501                	li	a0,0
    80003510:	6422                	ld	s0,8(sp)
    80003512:	0141                	addi	sp,sp,16
    80003514:	8082                	ret

0000000080003516 <sys_kill>:

uint64
sys_kill(void)
{
    80003516:	1101                	addi	sp,sp,-32
    80003518:	ec06                	sd	ra,24(sp)
    8000351a:	e822                	sd	s0,16(sp)
    8000351c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000351e:	fec40593          	addi	a1,s0,-20
    80003522:	4501                	li	a0,0
    80003524:	00000097          	auipc	ra,0x0
    80003528:	d72080e7          	jalr	-654(ra) # 80003296 <argint>
    return -1;
    8000352c:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    8000352e:	00054963          	bltz	a0,80003540 <sys_kill+0x2a>
  return kill(pid);
    80003532:	fec42503          	lw	a0,-20(s0)
    80003536:	fffff097          	auipc	ra,0xfffff
    8000353a:	4fe080e7          	jalr	1278(ra) # 80002a34 <kill>
    8000353e:	87aa                	mv	a5,a0
}
    80003540:	853e                	mv	a0,a5
    80003542:	60e2                	ld	ra,24(sp)
    80003544:	6442                	ld	s0,16(sp)
    80003546:	6105                	addi	sp,sp,32
    80003548:	8082                	ret

000000008000354a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000354a:	1101                	addi	sp,sp,-32
    8000354c:	ec06                	sd	ra,24(sp)
    8000354e:	e822                	sd	s0,16(sp)
    80003550:	e426                	sd	s1,8(sp)
    80003552:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003554:	00019517          	auipc	a0,0x19
    80003558:	b4450513          	addi	a0,a0,-1212 # 8001c098 <tickslock>
    8000355c:	ffffd097          	auipc	ra,0xffffd
    80003560:	75e080e7          	jalr	1886(ra) # 80000cba <acquire>
  xticks = ticks;
    80003564:	0002b797          	auipc	a5,0x2b
    80003568:	b2478793          	addi	a5,a5,-1244 # 8002e088 <ticks>
    8000356c:	4384                	lw	s1,0(a5)
  release(&tickslock);
    8000356e:	00019517          	auipc	a0,0x19
    80003572:	b2a50513          	addi	a0,a0,-1238 # 8001c098 <tickslock>
    80003576:	ffffe097          	auipc	ra,0xffffe
    8000357a:	990080e7          	jalr	-1648(ra) # 80000f06 <release>
  return xticks;
}
    8000357e:	02049513          	slli	a0,s1,0x20
    80003582:	9101                	srli	a0,a0,0x20
    80003584:	60e2                	ld	ra,24(sp)
    80003586:	6442                	ld	s0,16(sp)
    80003588:	64a2                	ld	s1,8(sp)
    8000358a:	6105                	addi	sp,sp,32
    8000358c:	8082                	ret

000000008000358e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000358e:	7179                	addi	sp,sp,-48
    80003590:	f406                	sd	ra,40(sp)
    80003592:	f022                	sd	s0,32(sp)
    80003594:	ec26                	sd	s1,24(sp)
    80003596:	e84a                	sd	s2,16(sp)
    80003598:	e44e                	sd	s3,8(sp)
    8000359a:	e052                	sd	s4,0(sp)
    8000359c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000359e:	00005597          	auipc	a1,0x5
    800035a2:	e6258593          	addi	a1,a1,-414 # 80008400 <userret+0x370>
    800035a6:	00019517          	auipc	a0,0x19
    800035aa:	b2250513          	addi	a0,a0,-1246 # 8001c0c8 <bcache>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	59e080e7          	jalr	1438(ra) # 80000b4c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800035b6:	00021797          	auipc	a5,0x21
    800035ba:	b1278793          	addi	a5,a5,-1262 # 800240c8 <bcache+0x8000>
    800035be:	00021717          	auipc	a4,0x21
    800035c2:	05a70713          	addi	a4,a4,90 # 80024618 <bcache+0x8550>
    800035c6:	5ae7b823          	sd	a4,1456(a5)
  bcache.head.next = &bcache.head;
    800035ca:	5ae7bc23          	sd	a4,1464(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035ce:	00019497          	auipc	s1,0x19
    800035d2:	b2a48493          	addi	s1,s1,-1238 # 8001c0f8 <bcache+0x30>
    b->next = bcache.head.next;
    800035d6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800035d8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800035da:	00005a17          	auipc	s4,0x5
    800035de:	476a0a13          	addi	s4,s4,1142 # 80008a50 <userret+0x9c0>
    b->next = bcache.head.next;
    800035e2:	5b893783          	ld	a5,1464(s2)
    800035e6:	f4bc                	sd	a5,104(s1)
    b->prev = &bcache.head;
    800035e8:	0734b023          	sd	s3,96(s1)
    initsleeplock(&b->lock, "buffer");
    800035ec:	85d2                	mv	a1,s4
    800035ee:	01048513          	addi	a0,s1,16
    800035f2:	00001097          	auipc	ra,0x1
    800035f6:	5ea080e7          	jalr	1514(ra) # 80004bdc <initsleeplock>
    bcache.head.next->prev = b;
    800035fa:	5b893783          	ld	a5,1464(s2)
    800035fe:	f3a4                	sd	s1,96(a5)
    bcache.head.next = b;
    80003600:	5a993c23          	sd	s1,1464(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003604:	47048493          	addi	s1,s1,1136
    80003608:	fd349de3          	bne	s1,s3,800035e2 <binit+0x54>
  }
}
    8000360c:	70a2                	ld	ra,40(sp)
    8000360e:	7402                	ld	s0,32(sp)
    80003610:	64e2                	ld	s1,24(sp)
    80003612:	6942                	ld	s2,16(sp)
    80003614:	69a2                	ld	s3,8(sp)
    80003616:	6a02                	ld	s4,0(sp)
    80003618:	6145                	addi	sp,sp,48
    8000361a:	8082                	ret

000000008000361c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000361c:	7179                	addi	sp,sp,-48
    8000361e:	f406                	sd	ra,40(sp)
    80003620:	f022                	sd	s0,32(sp)
    80003622:	ec26                	sd	s1,24(sp)
    80003624:	e84a                	sd	s2,16(sp)
    80003626:	e44e                	sd	s3,8(sp)
    80003628:	1800                	addi	s0,sp,48
    8000362a:	89aa                	mv	s3,a0
    8000362c:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000362e:	00019517          	auipc	a0,0x19
    80003632:	a9a50513          	addi	a0,a0,-1382 # 8001c0c8 <bcache>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	684080e7          	jalr	1668(ra) # 80000cba <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000363e:	00021797          	auipc	a5,0x21
    80003642:	a8a78793          	addi	a5,a5,-1398 # 800240c8 <bcache+0x8000>
    80003646:	5b87b483          	ld	s1,1464(a5)
    8000364a:	00021797          	auipc	a5,0x21
    8000364e:	fce78793          	addi	a5,a5,-50 # 80024618 <bcache+0x8550>
    80003652:	02f48f63          	beq	s1,a5,80003690 <bread+0x74>
    80003656:	873e                	mv	a4,a5
    80003658:	a021                	j	80003660 <bread+0x44>
    8000365a:	74a4                	ld	s1,104(s1)
    8000365c:	02e48a63          	beq	s1,a4,80003690 <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    80003660:	449c                	lw	a5,8(s1)
    80003662:	ff379ce3          	bne	a5,s3,8000365a <bread+0x3e>
    80003666:	44dc                	lw	a5,12(s1)
    80003668:	ff2799e3          	bne	a5,s2,8000365a <bread+0x3e>
      b->refcnt++;
    8000366c:	4cbc                	lw	a5,88(s1)
    8000366e:	2785                	addiw	a5,a5,1
    80003670:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    80003672:	00019517          	auipc	a0,0x19
    80003676:	a5650513          	addi	a0,a0,-1450 # 8001c0c8 <bcache>
    8000367a:	ffffe097          	auipc	ra,0xffffe
    8000367e:	88c080e7          	jalr	-1908(ra) # 80000f06 <release>
      acquiresleep(&b->lock);
    80003682:	01048513          	addi	a0,s1,16
    80003686:	00001097          	auipc	ra,0x1
    8000368a:	590080e7          	jalr	1424(ra) # 80004c16 <acquiresleep>
      return b;
    8000368e:	a8b1                	j	800036ea <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003690:	00021797          	auipc	a5,0x21
    80003694:	a3878793          	addi	a5,a5,-1480 # 800240c8 <bcache+0x8000>
    80003698:	5b07b483          	ld	s1,1456(a5)
    8000369c:	00021797          	auipc	a5,0x21
    800036a0:	f7c78793          	addi	a5,a5,-132 # 80024618 <bcache+0x8550>
    800036a4:	04f48d63          	beq	s1,a5,800036fe <bread+0xe2>
    if(b->refcnt == 0) {
    800036a8:	4cbc                	lw	a5,88(s1)
    800036aa:	cb91                	beqz	a5,800036be <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036ac:	00021717          	auipc	a4,0x21
    800036b0:	f6c70713          	addi	a4,a4,-148 # 80024618 <bcache+0x8550>
    800036b4:	70a4                	ld	s1,96(s1)
    800036b6:	04e48463          	beq	s1,a4,800036fe <bread+0xe2>
    if(b->refcnt == 0) {
    800036ba:	4cbc                	lw	a5,88(s1)
    800036bc:	ffe5                	bnez	a5,800036b4 <bread+0x98>
      b->dev = dev;
    800036be:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800036c2:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800036c6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800036ca:	4785                	li	a5,1
    800036cc:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    800036ce:	00019517          	auipc	a0,0x19
    800036d2:	9fa50513          	addi	a0,a0,-1542 # 8001c0c8 <bcache>
    800036d6:	ffffe097          	auipc	ra,0xffffe
    800036da:	830080e7          	jalr	-2000(ra) # 80000f06 <release>
      acquiresleep(&b->lock);
    800036de:	01048513          	addi	a0,s1,16
    800036e2:	00001097          	auipc	ra,0x1
    800036e6:	534080e7          	jalr	1332(ra) # 80004c16 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800036ea:	409c                	lw	a5,0(s1)
    800036ec:	c38d                	beqz	a5,8000370e <bread+0xf2>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    800036ee:	8526                	mv	a0,s1
    800036f0:	70a2                	ld	ra,40(sp)
    800036f2:	7402                	ld	s0,32(sp)
    800036f4:	64e2                	ld	s1,24(sp)
    800036f6:	6942                	ld	s2,16(sp)
    800036f8:	69a2                	ld	s3,8(sp)
    800036fa:	6145                	addi	sp,sp,48
    800036fc:	8082                	ret
  panic("bget: no buffers");
    800036fe:	00005517          	auipc	a0,0x5
    80003702:	35a50513          	addi	a0,a0,858 # 80008a58 <userret+0x9c8>
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	07e080e7          	jalr	126(ra) # 80000784 <panic>
    virtio_disk_rw(b->dev, b, 0);
    8000370e:	4601                	li	a2,0
    80003710:	85a6                	mv	a1,s1
    80003712:	4488                	lw	a0,8(s1)
    80003714:	00003097          	auipc	ra,0x3
    80003718:	1d6080e7          	jalr	470(ra) # 800068ea <virtio_disk_rw>
    b->valid = 1;
    8000371c:	4785                	li	a5,1
    8000371e:	c09c                	sw	a5,0(s1)
  return b;
    80003720:	b7f9                	j	800036ee <bread+0xd2>

0000000080003722 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003722:	1101                	addi	sp,sp,-32
    80003724:	ec06                	sd	ra,24(sp)
    80003726:	e822                	sd	s0,16(sp)
    80003728:	e426                	sd	s1,8(sp)
    8000372a:	1000                	addi	s0,sp,32
    8000372c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000372e:	0541                	addi	a0,a0,16
    80003730:	00001097          	auipc	ra,0x1
    80003734:	580080e7          	jalr	1408(ra) # 80004cb0 <holdingsleep>
    80003738:	cd09                	beqz	a0,80003752 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    8000373a:	4605                	li	a2,1
    8000373c:	85a6                	mv	a1,s1
    8000373e:	4488                	lw	a0,8(s1)
    80003740:	00003097          	auipc	ra,0x3
    80003744:	1aa080e7          	jalr	426(ra) # 800068ea <virtio_disk_rw>
}
    80003748:	60e2                	ld	ra,24(sp)
    8000374a:	6442                	ld	s0,16(sp)
    8000374c:	64a2                	ld	s1,8(sp)
    8000374e:	6105                	addi	sp,sp,32
    80003750:	8082                	ret
    panic("bwrite");
    80003752:	00005517          	auipc	a0,0x5
    80003756:	31e50513          	addi	a0,a0,798 # 80008a70 <userret+0x9e0>
    8000375a:	ffffd097          	auipc	ra,0xffffd
    8000375e:	02a080e7          	jalr	42(ra) # 80000784 <panic>

0000000080003762 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003762:	1101                	addi	sp,sp,-32
    80003764:	ec06                	sd	ra,24(sp)
    80003766:	e822                	sd	s0,16(sp)
    80003768:	e426                	sd	s1,8(sp)
    8000376a:	e04a                	sd	s2,0(sp)
    8000376c:	1000                	addi	s0,sp,32
    8000376e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003770:	01050913          	addi	s2,a0,16
    80003774:	854a                	mv	a0,s2
    80003776:	00001097          	auipc	ra,0x1
    8000377a:	53a080e7          	jalr	1338(ra) # 80004cb0 <holdingsleep>
    8000377e:	c92d                	beqz	a0,800037f0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003780:	854a                	mv	a0,s2
    80003782:	00001097          	auipc	ra,0x1
    80003786:	4ea080e7          	jalr	1258(ra) # 80004c6c <releasesleep>

  acquire(&bcache.lock);
    8000378a:	00019517          	auipc	a0,0x19
    8000378e:	93e50513          	addi	a0,a0,-1730 # 8001c0c8 <bcache>
    80003792:	ffffd097          	auipc	ra,0xffffd
    80003796:	528080e7          	jalr	1320(ra) # 80000cba <acquire>
  b->refcnt--;
    8000379a:	4cbc                	lw	a5,88(s1)
    8000379c:	37fd                	addiw	a5,a5,-1
    8000379e:	0007871b          	sext.w	a4,a5
    800037a2:	ccbc                	sw	a5,88(s1)
  if (b->refcnt == 0) {
    800037a4:	eb05                	bnez	a4,800037d4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800037a6:	74bc                	ld	a5,104(s1)
    800037a8:	70b8                	ld	a4,96(s1)
    800037aa:	f3b8                	sd	a4,96(a5)
    b->prev->next = b->next;
    800037ac:	70bc                	ld	a5,96(s1)
    800037ae:	74b8                	ld	a4,104(s1)
    800037b0:	f7b8                	sd	a4,104(a5)
    b->next = bcache.head.next;
    800037b2:	00021797          	auipc	a5,0x21
    800037b6:	91678793          	addi	a5,a5,-1770 # 800240c8 <bcache+0x8000>
    800037ba:	5b87b703          	ld	a4,1464(a5)
    800037be:	f4b8                	sd	a4,104(s1)
    b->prev = &bcache.head;
    800037c0:	00021717          	auipc	a4,0x21
    800037c4:	e5870713          	addi	a4,a4,-424 # 80024618 <bcache+0x8550>
    800037c8:	f0b8                	sd	a4,96(s1)
    bcache.head.next->prev = b;
    800037ca:	5b87b703          	ld	a4,1464(a5)
    800037ce:	f324                	sd	s1,96(a4)
    bcache.head.next = b;
    800037d0:	5a97bc23          	sd	s1,1464(a5)
  }
  
  release(&bcache.lock);
    800037d4:	00019517          	auipc	a0,0x19
    800037d8:	8f450513          	addi	a0,a0,-1804 # 8001c0c8 <bcache>
    800037dc:	ffffd097          	auipc	ra,0xffffd
    800037e0:	72a080e7          	jalr	1834(ra) # 80000f06 <release>
}
    800037e4:	60e2                	ld	ra,24(sp)
    800037e6:	6442                	ld	s0,16(sp)
    800037e8:	64a2                	ld	s1,8(sp)
    800037ea:	6902                	ld	s2,0(sp)
    800037ec:	6105                	addi	sp,sp,32
    800037ee:	8082                	ret
    panic("brelse");
    800037f0:	00005517          	auipc	a0,0x5
    800037f4:	28850513          	addi	a0,a0,648 # 80008a78 <userret+0x9e8>
    800037f8:	ffffd097          	auipc	ra,0xffffd
    800037fc:	f8c080e7          	jalr	-116(ra) # 80000784 <panic>

0000000080003800 <bpin>:

void
bpin(struct buf *b) {
    80003800:	1101                	addi	sp,sp,-32
    80003802:	ec06                	sd	ra,24(sp)
    80003804:	e822                	sd	s0,16(sp)
    80003806:	e426                	sd	s1,8(sp)
    80003808:	1000                	addi	s0,sp,32
    8000380a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000380c:	00019517          	auipc	a0,0x19
    80003810:	8bc50513          	addi	a0,a0,-1860 # 8001c0c8 <bcache>
    80003814:	ffffd097          	auipc	ra,0xffffd
    80003818:	4a6080e7          	jalr	1190(ra) # 80000cba <acquire>
  b->refcnt++;
    8000381c:	4cbc                	lw	a5,88(s1)
    8000381e:	2785                	addiw	a5,a5,1
    80003820:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    80003822:	00019517          	auipc	a0,0x19
    80003826:	8a650513          	addi	a0,a0,-1882 # 8001c0c8 <bcache>
    8000382a:	ffffd097          	auipc	ra,0xffffd
    8000382e:	6dc080e7          	jalr	1756(ra) # 80000f06 <release>
}
    80003832:	60e2                	ld	ra,24(sp)
    80003834:	6442                	ld	s0,16(sp)
    80003836:	64a2                	ld	s1,8(sp)
    80003838:	6105                	addi	sp,sp,32
    8000383a:	8082                	ret

000000008000383c <bunpin>:

void
bunpin(struct buf *b) {
    8000383c:	1101                	addi	sp,sp,-32
    8000383e:	ec06                	sd	ra,24(sp)
    80003840:	e822                	sd	s0,16(sp)
    80003842:	e426                	sd	s1,8(sp)
    80003844:	1000                	addi	s0,sp,32
    80003846:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003848:	00019517          	auipc	a0,0x19
    8000384c:	88050513          	addi	a0,a0,-1920 # 8001c0c8 <bcache>
    80003850:	ffffd097          	auipc	ra,0xffffd
    80003854:	46a080e7          	jalr	1130(ra) # 80000cba <acquire>
  b->refcnt--;
    80003858:	4cbc                	lw	a5,88(s1)
    8000385a:	37fd                	addiw	a5,a5,-1
    8000385c:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    8000385e:	00019517          	auipc	a0,0x19
    80003862:	86a50513          	addi	a0,a0,-1942 # 8001c0c8 <bcache>
    80003866:	ffffd097          	auipc	ra,0xffffd
    8000386a:	6a0080e7          	jalr	1696(ra) # 80000f06 <release>
}
    8000386e:	60e2                	ld	ra,24(sp)
    80003870:	6442                	ld	s0,16(sp)
    80003872:	64a2                	ld	s1,8(sp)
    80003874:	6105                	addi	sp,sp,32
    80003876:	8082                	ret

0000000080003878 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003878:	1101                	addi	sp,sp,-32
    8000387a:	ec06                	sd	ra,24(sp)
    8000387c:	e822                	sd	s0,16(sp)
    8000387e:	e426                	sd	s1,8(sp)
    80003880:	e04a                	sd	s2,0(sp)
    80003882:	1000                	addi	s0,sp,32
    80003884:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003886:	00d5d59b          	srliw	a1,a1,0xd
    8000388a:	00021797          	auipc	a5,0x21
    8000388e:	1fe78793          	addi	a5,a5,510 # 80024a88 <sb>
    80003892:	4fdc                	lw	a5,28(a5)
    80003894:	9dbd                	addw	a1,a1,a5
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	d86080e7          	jalr	-634(ra) # 8000361c <bread>
  bi = b % BPB;
    8000389e:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    800038a0:	0074f793          	andi	a5,s1,7
    800038a4:	4705                	li	a4,1
    800038a6:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    800038aa:	6789                	lui	a5,0x2
    800038ac:	17fd                	addi	a5,a5,-1
    800038ae:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    800038b0:	41f4d79b          	sraiw	a5,s1,0x1f
    800038b4:	01d7d79b          	srliw	a5,a5,0x1d
    800038b8:	9fa5                	addw	a5,a5,s1
    800038ba:	4037d79b          	sraiw	a5,a5,0x3
    800038be:	00f506b3          	add	a3,a0,a5
    800038c2:	0706c683          	lbu	a3,112(a3)
    800038c6:	00d77633          	and	a2,a4,a3
    800038ca:	c61d                	beqz	a2,800038f8 <bfree+0x80>
    800038cc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800038ce:	97aa                	add	a5,a5,a0
    800038d0:	fff74713          	not	a4,a4
    800038d4:	8f75                	and	a4,a4,a3
    800038d6:	06e78823          	sb	a4,112(a5) # 2070 <_entry-0x7fffdf90>
  log_write(bp);
    800038da:	00001097          	auipc	ra,0x1
    800038de:	1b2080e7          	jalr	434(ra) # 80004a8c <log_write>
  brelse(bp);
    800038e2:	854a                	mv	a0,s2
    800038e4:	00000097          	auipc	ra,0x0
    800038e8:	e7e080e7          	jalr	-386(ra) # 80003762 <brelse>
}
    800038ec:	60e2                	ld	ra,24(sp)
    800038ee:	6442                	ld	s0,16(sp)
    800038f0:	64a2                	ld	s1,8(sp)
    800038f2:	6902                	ld	s2,0(sp)
    800038f4:	6105                	addi	sp,sp,32
    800038f6:	8082                	ret
    panic("freeing free block");
    800038f8:	00005517          	auipc	a0,0x5
    800038fc:	18850513          	addi	a0,a0,392 # 80008a80 <userret+0x9f0>
    80003900:	ffffd097          	auipc	ra,0xffffd
    80003904:	e84080e7          	jalr	-380(ra) # 80000784 <panic>

0000000080003908 <balloc>:
{
    80003908:	711d                	addi	sp,sp,-96
    8000390a:	ec86                	sd	ra,88(sp)
    8000390c:	e8a2                	sd	s0,80(sp)
    8000390e:	e4a6                	sd	s1,72(sp)
    80003910:	e0ca                	sd	s2,64(sp)
    80003912:	fc4e                	sd	s3,56(sp)
    80003914:	f852                	sd	s4,48(sp)
    80003916:	f456                	sd	s5,40(sp)
    80003918:	f05a                	sd	s6,32(sp)
    8000391a:	ec5e                	sd	s7,24(sp)
    8000391c:	e862                	sd	s8,16(sp)
    8000391e:	e466                	sd	s9,8(sp)
    80003920:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003922:	00021797          	auipc	a5,0x21
    80003926:	16678793          	addi	a5,a5,358 # 80024a88 <sb>
    8000392a:	43dc                	lw	a5,4(a5)
    8000392c:	10078e63          	beqz	a5,80003a48 <balloc+0x140>
    80003930:	8baa                	mv	s7,a0
    80003932:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003934:	00021b17          	auipc	s6,0x21
    80003938:	154b0b13          	addi	s6,s6,340 # 80024a88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000393c:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    8000393e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003940:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003942:	6c89                	lui	s9,0x2
    80003944:	a079                	j	800039d2 <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003946:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    80003948:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000394a:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    8000394c:	96a6                	add	a3,a3,s1
    8000394e:	8f51                	or	a4,a4,a2
    80003950:	06e68823          	sb	a4,112(a3)
        log_write(bp);
    80003954:	8526                	mv	a0,s1
    80003956:	00001097          	auipc	ra,0x1
    8000395a:	136080e7          	jalr	310(ra) # 80004a8c <log_write>
        brelse(bp);
    8000395e:	8526                	mv	a0,s1
    80003960:	00000097          	auipc	ra,0x0
    80003964:	e02080e7          	jalr	-510(ra) # 80003762 <brelse>
  bp = bread(dev, bno);
    80003968:	85ca                	mv	a1,s2
    8000396a:	855e                	mv	a0,s7
    8000396c:	00000097          	auipc	ra,0x0
    80003970:	cb0080e7          	jalr	-848(ra) # 8000361c <bread>
    80003974:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    80003976:	40000613          	li	a2,1024
    8000397a:	4581                	li	a1,0
    8000397c:	07050513          	addi	a0,a0,112
    80003980:	ffffd097          	auipc	ra,0xffffd
    80003984:	7ae080e7          	jalr	1966(ra) # 8000112e <memset>
  log_write(bp);
    80003988:	8526                	mv	a0,s1
    8000398a:	00001097          	auipc	ra,0x1
    8000398e:	102080e7          	jalr	258(ra) # 80004a8c <log_write>
  brelse(bp);
    80003992:	8526                	mv	a0,s1
    80003994:	00000097          	auipc	ra,0x0
    80003998:	dce080e7          	jalr	-562(ra) # 80003762 <brelse>
}
    8000399c:	854a                	mv	a0,s2
    8000399e:	60e6                	ld	ra,88(sp)
    800039a0:	6446                	ld	s0,80(sp)
    800039a2:	64a6                	ld	s1,72(sp)
    800039a4:	6906                	ld	s2,64(sp)
    800039a6:	79e2                	ld	s3,56(sp)
    800039a8:	7a42                	ld	s4,48(sp)
    800039aa:	7aa2                	ld	s5,40(sp)
    800039ac:	7b02                	ld	s6,32(sp)
    800039ae:	6be2                	ld	s7,24(sp)
    800039b0:	6c42                	ld	s8,16(sp)
    800039b2:	6ca2                	ld	s9,8(sp)
    800039b4:	6125                	addi	sp,sp,96
    800039b6:	8082                	ret
    brelse(bp);
    800039b8:	8526                	mv	a0,s1
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	da8080e7          	jalr	-600(ra) # 80003762 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800039c2:	015c87bb          	addw	a5,s9,s5
    800039c6:	00078a9b          	sext.w	s5,a5
    800039ca:	004b2703          	lw	a4,4(s6)
    800039ce:	06eafd63          	bleu	a4,s5,80003a48 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    800039d2:	41fad79b          	sraiw	a5,s5,0x1f
    800039d6:	0137d79b          	srliw	a5,a5,0x13
    800039da:	015787bb          	addw	a5,a5,s5
    800039de:	40d7d79b          	sraiw	a5,a5,0xd
    800039e2:	01cb2583          	lw	a1,28(s6)
    800039e6:	9dbd                	addw	a1,a1,a5
    800039e8:	855e                	mv	a0,s7
    800039ea:	00000097          	auipc	ra,0x0
    800039ee:	c32080e7          	jalr	-974(ra) # 8000361c <bread>
    800039f2:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039f4:	000a881b          	sext.w	a6,s5
    800039f8:	004b2503          	lw	a0,4(s6)
    800039fc:	faa87ee3          	bleu	a0,a6,800039b8 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a00:	0704c603          	lbu	a2,112(s1)
    80003a04:	00167793          	andi	a5,a2,1
    80003a08:	df9d                	beqz	a5,80003946 <balloc+0x3e>
    80003a0a:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a0e:	87e2                	mv	a5,s8
    80003a10:	0107893b          	addw	s2,a5,a6
    80003a14:	faa782e3          	beq	a5,a0,800039b8 <balloc+0xb0>
      m = 1 << (bi % 8);
    80003a18:	41f7d71b          	sraiw	a4,a5,0x1f
    80003a1c:	01d7561b          	srliw	a2,a4,0x1d
    80003a20:	00f606bb          	addw	a3,a2,a5
    80003a24:	0076f713          	andi	a4,a3,7
    80003a28:	9f11                	subw	a4,a4,a2
    80003a2a:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a2e:	4036d69b          	sraiw	a3,a3,0x3
    80003a32:	00d48633          	add	a2,s1,a3
    80003a36:	07064603          	lbu	a2,112(a2)
    80003a3a:	00c775b3          	and	a1,a4,a2
    80003a3e:	d599                	beqz	a1,8000394c <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a40:	2785                	addiw	a5,a5,1
    80003a42:	fd4797e3          	bne	a5,s4,80003a10 <balloc+0x108>
    80003a46:	bf8d                	j	800039b8 <balloc+0xb0>
  panic("balloc: out of blocks");
    80003a48:	00005517          	auipc	a0,0x5
    80003a4c:	05050513          	addi	a0,a0,80 # 80008a98 <userret+0xa08>
    80003a50:	ffffd097          	auipc	ra,0xffffd
    80003a54:	d34080e7          	jalr	-716(ra) # 80000784 <panic>

0000000080003a58 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a58:	7179                	addi	sp,sp,-48
    80003a5a:	f406                	sd	ra,40(sp)
    80003a5c:	f022                	sd	s0,32(sp)
    80003a5e:	ec26                	sd	s1,24(sp)
    80003a60:	e84a                	sd	s2,16(sp)
    80003a62:	e44e                	sd	s3,8(sp)
    80003a64:	e052                	sd	s4,0(sp)
    80003a66:	1800                	addi	s0,sp,48
    80003a68:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003a6a:	47ad                	li	a5,11
    80003a6c:	04b7fe63          	bleu	a1,a5,80003ac8 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003a70:	ff45849b          	addiw	s1,a1,-12
    80003a74:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003a78:	0ff00793          	li	a5,255
    80003a7c:	0ae7e363          	bltu	a5,a4,80003b22 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003a80:	09852583          	lw	a1,152(a0)
    80003a84:	c5ad                	beqz	a1,80003aee <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003a86:	0009a503          	lw	a0,0(s3)
    80003a8a:	00000097          	auipc	ra,0x0
    80003a8e:	b92080e7          	jalr	-1134(ra) # 8000361c <bread>
    80003a92:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a94:	07050793          	addi	a5,a0,112
    if((addr = a[bn]) == 0){
    80003a98:	02049593          	slli	a1,s1,0x20
    80003a9c:	9181                	srli	a1,a1,0x20
    80003a9e:	058a                	slli	a1,a1,0x2
    80003aa0:	00b784b3          	add	s1,a5,a1
    80003aa4:	0004a903          	lw	s2,0(s1)
    80003aa8:	04090d63          	beqz	s2,80003b02 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003aac:	8552                	mv	a0,s4
    80003aae:	00000097          	auipc	ra,0x0
    80003ab2:	cb4080e7          	jalr	-844(ra) # 80003762 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003ab6:	854a                	mv	a0,s2
    80003ab8:	70a2                	ld	ra,40(sp)
    80003aba:	7402                	ld	s0,32(sp)
    80003abc:	64e2                	ld	s1,24(sp)
    80003abe:	6942                	ld	s2,16(sp)
    80003ac0:	69a2                	ld	s3,8(sp)
    80003ac2:	6a02                	ld	s4,0(sp)
    80003ac4:	6145                	addi	sp,sp,48
    80003ac6:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003ac8:	02059493          	slli	s1,a1,0x20
    80003acc:	9081                	srli	s1,s1,0x20
    80003ace:	048a                	slli	s1,s1,0x2
    80003ad0:	94aa                	add	s1,s1,a0
    80003ad2:	0684a903          	lw	s2,104(s1)
    80003ad6:	fe0910e3          	bnez	s2,80003ab6 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003ada:	4108                	lw	a0,0(a0)
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	e2c080e7          	jalr	-468(ra) # 80003908 <balloc>
    80003ae4:	0005091b          	sext.w	s2,a0
    80003ae8:	0724a423          	sw	s2,104(s1)
    80003aec:	b7e9                	j	80003ab6 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003aee:	4108                	lw	a0,0(a0)
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	e18080e7          	jalr	-488(ra) # 80003908 <balloc>
    80003af8:	0005059b          	sext.w	a1,a0
    80003afc:	08b9ac23          	sw	a1,152(s3)
    80003b00:	b759                	j	80003a86 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003b02:	0009a503          	lw	a0,0(s3)
    80003b06:	00000097          	auipc	ra,0x0
    80003b0a:	e02080e7          	jalr	-510(ra) # 80003908 <balloc>
    80003b0e:	0005091b          	sext.w	s2,a0
    80003b12:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    80003b16:	8552                	mv	a0,s4
    80003b18:	00001097          	auipc	ra,0x1
    80003b1c:	f74080e7          	jalr	-140(ra) # 80004a8c <log_write>
    80003b20:	b771                	j	80003aac <bmap+0x54>
  panic("bmap: out of range");
    80003b22:	00005517          	auipc	a0,0x5
    80003b26:	f8e50513          	addi	a0,a0,-114 # 80008ab0 <userret+0xa20>
    80003b2a:	ffffd097          	auipc	ra,0xffffd
    80003b2e:	c5a080e7          	jalr	-934(ra) # 80000784 <panic>

0000000080003b32 <iget>:
{
    80003b32:	7179                	addi	sp,sp,-48
    80003b34:	f406                	sd	ra,40(sp)
    80003b36:	f022                	sd	s0,32(sp)
    80003b38:	ec26                	sd	s1,24(sp)
    80003b3a:	e84a                	sd	s2,16(sp)
    80003b3c:	e44e                	sd	s3,8(sp)
    80003b3e:	e052                	sd	s4,0(sp)
    80003b40:	1800                	addi	s0,sp,48
    80003b42:	89aa                	mv	s3,a0
    80003b44:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003b46:	00021517          	auipc	a0,0x21
    80003b4a:	f6250513          	addi	a0,a0,-158 # 80024aa8 <icache>
    80003b4e:	ffffd097          	auipc	ra,0xffffd
    80003b52:	16c080e7          	jalr	364(ra) # 80000cba <acquire>
  empty = 0;
    80003b56:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003b58:	00021497          	auipc	s1,0x21
    80003b5c:	f8048493          	addi	s1,s1,-128 # 80024ad8 <icache+0x30>
    80003b60:	00023697          	auipc	a3,0x23
    80003b64:	eb868693          	addi	a3,a3,-328 # 80026a18 <log>
    80003b68:	a039                	j	80003b76 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b6a:	02090b63          	beqz	s2,80003ba0 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003b6e:	0a048493          	addi	s1,s1,160
    80003b72:	02d48a63          	beq	s1,a3,80003ba6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003b76:	449c                	lw	a5,8(s1)
    80003b78:	fef059e3          	blez	a5,80003b6a <iget+0x38>
    80003b7c:	4098                	lw	a4,0(s1)
    80003b7e:	ff3716e3          	bne	a4,s3,80003b6a <iget+0x38>
    80003b82:	40d8                	lw	a4,4(s1)
    80003b84:	ff4713e3          	bne	a4,s4,80003b6a <iget+0x38>
      ip->ref++;
    80003b88:	2785                	addiw	a5,a5,1
    80003b8a:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003b8c:	00021517          	auipc	a0,0x21
    80003b90:	f1c50513          	addi	a0,a0,-228 # 80024aa8 <icache>
    80003b94:	ffffd097          	auipc	ra,0xffffd
    80003b98:	372080e7          	jalr	882(ra) # 80000f06 <release>
      return ip;
    80003b9c:	8926                	mv	s2,s1
    80003b9e:	a03d                	j	80003bcc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ba0:	f7f9                	bnez	a5,80003b6e <iget+0x3c>
    80003ba2:	8926                	mv	s2,s1
    80003ba4:	b7e9                	j	80003b6e <iget+0x3c>
  if(empty == 0)
    80003ba6:	02090c63          	beqz	s2,80003bde <iget+0xac>
  ip->dev = dev;
    80003baa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003bae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003bb2:	4785                	li	a5,1
    80003bb4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003bb8:	04092c23          	sw	zero,88(s2)
  release(&icache.lock);
    80003bbc:	00021517          	auipc	a0,0x21
    80003bc0:	eec50513          	addi	a0,a0,-276 # 80024aa8 <icache>
    80003bc4:	ffffd097          	auipc	ra,0xffffd
    80003bc8:	342080e7          	jalr	834(ra) # 80000f06 <release>
}
    80003bcc:	854a                	mv	a0,s2
    80003bce:	70a2                	ld	ra,40(sp)
    80003bd0:	7402                	ld	s0,32(sp)
    80003bd2:	64e2                	ld	s1,24(sp)
    80003bd4:	6942                	ld	s2,16(sp)
    80003bd6:	69a2                	ld	s3,8(sp)
    80003bd8:	6a02                	ld	s4,0(sp)
    80003bda:	6145                	addi	sp,sp,48
    80003bdc:	8082                	ret
    panic("iget: no inodes");
    80003bde:	00005517          	auipc	a0,0x5
    80003be2:	eea50513          	addi	a0,a0,-278 # 80008ac8 <userret+0xa38>
    80003be6:	ffffd097          	auipc	ra,0xffffd
    80003bea:	b9e080e7          	jalr	-1122(ra) # 80000784 <panic>

0000000080003bee <fsinit>:
fsinit(int dev) {
    80003bee:	7179                	addi	sp,sp,-48
    80003bf0:	f406                	sd	ra,40(sp)
    80003bf2:	f022                	sd	s0,32(sp)
    80003bf4:	ec26                	sd	s1,24(sp)
    80003bf6:	e84a                	sd	s2,16(sp)
    80003bf8:	e44e                	sd	s3,8(sp)
    80003bfa:	1800                	addi	s0,sp,48
    80003bfc:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003bfe:	4585                	li	a1,1
    80003c00:	00000097          	auipc	ra,0x0
    80003c04:	a1c080e7          	jalr	-1508(ra) # 8000361c <bread>
    80003c08:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003c0a:	00021497          	auipc	s1,0x21
    80003c0e:	e7e48493          	addi	s1,s1,-386 # 80024a88 <sb>
    80003c12:	02000613          	li	a2,32
    80003c16:	07050593          	addi	a1,a0,112
    80003c1a:	8526                	mv	a0,s1
    80003c1c:	ffffd097          	auipc	ra,0xffffd
    80003c20:	57e080e7          	jalr	1406(ra) # 8000119a <memmove>
  brelse(bp);
    80003c24:	854a                	mv	a0,s2
    80003c26:	00000097          	auipc	ra,0x0
    80003c2a:	b3c080e7          	jalr	-1220(ra) # 80003762 <brelse>
  if(sb.magic != FSMAGIC)
    80003c2e:	4098                	lw	a4,0(s1)
    80003c30:	102037b7          	lui	a5,0x10203
    80003c34:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c38:	02f71263          	bne	a4,a5,80003c5c <fsinit+0x6e>
  initlog(dev, &sb);
    80003c3c:	00021597          	auipc	a1,0x21
    80003c40:	e4c58593          	addi	a1,a1,-436 # 80024a88 <sb>
    80003c44:	854e                	mv	a0,s3
    80003c46:	00001097          	auipc	ra,0x1
    80003c4a:	b30080e7          	jalr	-1232(ra) # 80004776 <initlog>
}
    80003c4e:	70a2                	ld	ra,40(sp)
    80003c50:	7402                	ld	s0,32(sp)
    80003c52:	64e2                	ld	s1,24(sp)
    80003c54:	6942                	ld	s2,16(sp)
    80003c56:	69a2                	ld	s3,8(sp)
    80003c58:	6145                	addi	sp,sp,48
    80003c5a:	8082                	ret
    panic("invalid file system");
    80003c5c:	00005517          	auipc	a0,0x5
    80003c60:	e7c50513          	addi	a0,a0,-388 # 80008ad8 <userret+0xa48>
    80003c64:	ffffd097          	auipc	ra,0xffffd
    80003c68:	b20080e7          	jalr	-1248(ra) # 80000784 <panic>

0000000080003c6c <iinit>:
{
    80003c6c:	7179                	addi	sp,sp,-48
    80003c6e:	f406                	sd	ra,40(sp)
    80003c70:	f022                	sd	s0,32(sp)
    80003c72:	ec26                	sd	s1,24(sp)
    80003c74:	e84a                	sd	s2,16(sp)
    80003c76:	e44e                	sd	s3,8(sp)
    80003c78:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003c7a:	00005597          	auipc	a1,0x5
    80003c7e:	e7658593          	addi	a1,a1,-394 # 80008af0 <userret+0xa60>
    80003c82:	00021517          	auipc	a0,0x21
    80003c86:	e2650513          	addi	a0,a0,-474 # 80024aa8 <icache>
    80003c8a:	ffffd097          	auipc	ra,0xffffd
    80003c8e:	ec2080e7          	jalr	-318(ra) # 80000b4c <initlock>
  for(i = 0; i < NINODE; i++) {
    80003c92:	00021497          	auipc	s1,0x21
    80003c96:	e5648493          	addi	s1,s1,-426 # 80024ae8 <icache+0x40>
    80003c9a:	00023997          	auipc	s3,0x23
    80003c9e:	d8e98993          	addi	s3,s3,-626 # 80026a28 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003ca2:	00005917          	auipc	s2,0x5
    80003ca6:	e5690913          	addi	s2,s2,-426 # 80008af8 <userret+0xa68>
    80003caa:	85ca                	mv	a1,s2
    80003cac:	8526                	mv	a0,s1
    80003cae:	00001097          	auipc	ra,0x1
    80003cb2:	f2e080e7          	jalr	-210(ra) # 80004bdc <initsleeplock>
    80003cb6:	0a048493          	addi	s1,s1,160
  for(i = 0; i < NINODE; i++) {
    80003cba:	ff3498e3          	bne	s1,s3,80003caa <iinit+0x3e>
}
    80003cbe:	70a2                	ld	ra,40(sp)
    80003cc0:	7402                	ld	s0,32(sp)
    80003cc2:	64e2                	ld	s1,24(sp)
    80003cc4:	6942                	ld	s2,16(sp)
    80003cc6:	69a2                	ld	s3,8(sp)
    80003cc8:	6145                	addi	sp,sp,48
    80003cca:	8082                	ret

0000000080003ccc <ialloc>:
{
    80003ccc:	715d                	addi	sp,sp,-80
    80003cce:	e486                	sd	ra,72(sp)
    80003cd0:	e0a2                	sd	s0,64(sp)
    80003cd2:	fc26                	sd	s1,56(sp)
    80003cd4:	f84a                	sd	s2,48(sp)
    80003cd6:	f44e                	sd	s3,40(sp)
    80003cd8:	f052                	sd	s4,32(sp)
    80003cda:	ec56                	sd	s5,24(sp)
    80003cdc:	e85a                	sd	s6,16(sp)
    80003cde:	e45e                	sd	s7,8(sp)
    80003ce0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ce2:	00021797          	auipc	a5,0x21
    80003ce6:	da678793          	addi	a5,a5,-602 # 80024a88 <sb>
    80003cea:	47d8                	lw	a4,12(a5)
    80003cec:	4785                	li	a5,1
    80003cee:	04e7fa63          	bleu	a4,a5,80003d42 <ialloc+0x76>
    80003cf2:	8a2a                	mv	s4,a0
    80003cf4:	8b2e                	mv	s6,a1
    80003cf6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003cf8:	00021997          	auipc	s3,0x21
    80003cfc:	d9098993          	addi	s3,s3,-624 # 80024a88 <sb>
    80003d00:	00048a9b          	sext.w	s5,s1
    80003d04:	0044d593          	srli	a1,s1,0x4
    80003d08:	0189a783          	lw	a5,24(s3)
    80003d0c:	9dbd                	addw	a1,a1,a5
    80003d0e:	8552                	mv	a0,s4
    80003d10:	00000097          	auipc	ra,0x0
    80003d14:	90c080e7          	jalr	-1780(ra) # 8000361c <bread>
    80003d18:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d1a:	07050913          	addi	s2,a0,112
    80003d1e:	00f4f793          	andi	a5,s1,15
    80003d22:	079a                	slli	a5,a5,0x6
    80003d24:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80003d26:	00091783          	lh	a5,0(s2)
    80003d2a:	c785                	beqz	a5,80003d52 <ialloc+0x86>
    brelse(bp);
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	a36080e7          	jalr	-1482(ra) # 80003762 <brelse>
    80003d34:	0485                	addi	s1,s1,1
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d36:	00c9a703          	lw	a4,12(s3)
    80003d3a:	0004879b          	sext.w	a5,s1
    80003d3e:	fce7e1e3          	bltu	a5,a4,80003d00 <ialloc+0x34>
  panic("ialloc: no inodes");
    80003d42:	00005517          	auipc	a0,0x5
    80003d46:	dbe50513          	addi	a0,a0,-578 # 80008b00 <userret+0xa70>
    80003d4a:	ffffd097          	auipc	ra,0xffffd
    80003d4e:	a3a080e7          	jalr	-1478(ra) # 80000784 <panic>
      memset(dip, 0, sizeof(*dip));
    80003d52:	04000613          	li	a2,64
    80003d56:	4581                	li	a1,0
    80003d58:	854a                	mv	a0,s2
    80003d5a:	ffffd097          	auipc	ra,0xffffd
    80003d5e:	3d4080e7          	jalr	980(ra) # 8000112e <memset>
      dip->type = type;
    80003d62:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    80003d66:	855e                	mv	a0,s7
    80003d68:	00001097          	auipc	ra,0x1
    80003d6c:	d24080e7          	jalr	-732(ra) # 80004a8c <log_write>
      brelse(bp);
    80003d70:	855e                	mv	a0,s7
    80003d72:	00000097          	auipc	ra,0x0
    80003d76:	9f0080e7          	jalr	-1552(ra) # 80003762 <brelse>
      return iget(dev, inum);
    80003d7a:	85d6                	mv	a1,s5
    80003d7c:	8552                	mv	a0,s4
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	db4080e7          	jalr	-588(ra) # 80003b32 <iget>
}
    80003d86:	60a6                	ld	ra,72(sp)
    80003d88:	6406                	ld	s0,64(sp)
    80003d8a:	74e2                	ld	s1,56(sp)
    80003d8c:	7942                	ld	s2,48(sp)
    80003d8e:	79a2                	ld	s3,40(sp)
    80003d90:	7a02                	ld	s4,32(sp)
    80003d92:	6ae2                	ld	s5,24(sp)
    80003d94:	6b42                	ld	s6,16(sp)
    80003d96:	6ba2                	ld	s7,8(sp)
    80003d98:	6161                	addi	sp,sp,80
    80003d9a:	8082                	ret

0000000080003d9c <iupdate>:
{
    80003d9c:	1101                	addi	sp,sp,-32
    80003d9e:	ec06                	sd	ra,24(sp)
    80003da0:	e822                	sd	s0,16(sp)
    80003da2:	e426                	sd	s1,8(sp)
    80003da4:	e04a                	sd	s2,0(sp)
    80003da6:	1000                	addi	s0,sp,32
    80003da8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003daa:	415c                	lw	a5,4(a0)
    80003dac:	0047d79b          	srliw	a5,a5,0x4
    80003db0:	00021717          	auipc	a4,0x21
    80003db4:	cd870713          	addi	a4,a4,-808 # 80024a88 <sb>
    80003db8:	4f0c                	lw	a1,24(a4)
    80003dba:	9dbd                	addw	a1,a1,a5
    80003dbc:	4108                	lw	a0,0(a0)
    80003dbe:	00000097          	auipc	ra,0x0
    80003dc2:	85e080e7          	jalr	-1954(ra) # 8000361c <bread>
    80003dc6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003dc8:	07050513          	addi	a0,a0,112
    80003dcc:	40dc                	lw	a5,4(s1)
    80003dce:	8bbd                	andi	a5,a5,15
    80003dd0:	079a                	slli	a5,a5,0x6
    80003dd2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003dd4:	05c49783          	lh	a5,92(s1)
    80003dd8:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    80003ddc:	05e49783          	lh	a5,94(s1)
    80003de0:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    80003de4:	06049783          	lh	a5,96(s1)
    80003de8:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    80003dec:	06249783          	lh	a5,98(s1)
    80003df0:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    80003df4:	50fc                	lw	a5,100(s1)
    80003df6:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003df8:	03400613          	li	a2,52
    80003dfc:	06848593          	addi	a1,s1,104
    80003e00:	0531                	addi	a0,a0,12
    80003e02:	ffffd097          	auipc	ra,0xffffd
    80003e06:	398080e7          	jalr	920(ra) # 8000119a <memmove>
  log_write(bp);
    80003e0a:	854a                	mv	a0,s2
    80003e0c:	00001097          	auipc	ra,0x1
    80003e10:	c80080e7          	jalr	-896(ra) # 80004a8c <log_write>
  brelse(bp);
    80003e14:	854a                	mv	a0,s2
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	94c080e7          	jalr	-1716(ra) # 80003762 <brelse>
}
    80003e1e:	60e2                	ld	ra,24(sp)
    80003e20:	6442                	ld	s0,16(sp)
    80003e22:	64a2                	ld	s1,8(sp)
    80003e24:	6902                	ld	s2,0(sp)
    80003e26:	6105                	addi	sp,sp,32
    80003e28:	8082                	ret

0000000080003e2a <idup>:
{
    80003e2a:	1101                	addi	sp,sp,-32
    80003e2c:	ec06                	sd	ra,24(sp)
    80003e2e:	e822                	sd	s0,16(sp)
    80003e30:	e426                	sd	s1,8(sp)
    80003e32:	1000                	addi	s0,sp,32
    80003e34:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003e36:	00021517          	auipc	a0,0x21
    80003e3a:	c7250513          	addi	a0,a0,-910 # 80024aa8 <icache>
    80003e3e:	ffffd097          	auipc	ra,0xffffd
    80003e42:	e7c080e7          	jalr	-388(ra) # 80000cba <acquire>
  ip->ref++;
    80003e46:	449c                	lw	a5,8(s1)
    80003e48:	2785                	addiw	a5,a5,1
    80003e4a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003e4c:	00021517          	auipc	a0,0x21
    80003e50:	c5c50513          	addi	a0,a0,-932 # 80024aa8 <icache>
    80003e54:	ffffd097          	auipc	ra,0xffffd
    80003e58:	0b2080e7          	jalr	178(ra) # 80000f06 <release>
}
    80003e5c:	8526                	mv	a0,s1
    80003e5e:	60e2                	ld	ra,24(sp)
    80003e60:	6442                	ld	s0,16(sp)
    80003e62:	64a2                	ld	s1,8(sp)
    80003e64:	6105                	addi	sp,sp,32
    80003e66:	8082                	ret

0000000080003e68 <ilock>:
{
    80003e68:	1101                	addi	sp,sp,-32
    80003e6a:	ec06                	sd	ra,24(sp)
    80003e6c:	e822                	sd	s0,16(sp)
    80003e6e:	e426                	sd	s1,8(sp)
    80003e70:	e04a                	sd	s2,0(sp)
    80003e72:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003e74:	c115                	beqz	a0,80003e98 <ilock+0x30>
    80003e76:	84aa                	mv	s1,a0
    80003e78:	451c                	lw	a5,8(a0)
    80003e7a:	00f05f63          	blez	a5,80003e98 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003e7e:	0541                	addi	a0,a0,16
    80003e80:	00001097          	auipc	ra,0x1
    80003e84:	d96080e7          	jalr	-618(ra) # 80004c16 <acquiresleep>
  if(ip->valid == 0){
    80003e88:	4cbc                	lw	a5,88(s1)
    80003e8a:	cf99                	beqz	a5,80003ea8 <ilock+0x40>
}
    80003e8c:	60e2                	ld	ra,24(sp)
    80003e8e:	6442                	ld	s0,16(sp)
    80003e90:	64a2                	ld	s1,8(sp)
    80003e92:	6902                	ld	s2,0(sp)
    80003e94:	6105                	addi	sp,sp,32
    80003e96:	8082                	ret
    panic("ilock");
    80003e98:	00005517          	auipc	a0,0x5
    80003e9c:	c8050513          	addi	a0,a0,-896 # 80008b18 <userret+0xa88>
    80003ea0:	ffffd097          	auipc	ra,0xffffd
    80003ea4:	8e4080e7          	jalr	-1820(ra) # 80000784 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ea8:	40dc                	lw	a5,4(s1)
    80003eaa:	0047d79b          	srliw	a5,a5,0x4
    80003eae:	00021717          	auipc	a4,0x21
    80003eb2:	bda70713          	addi	a4,a4,-1062 # 80024a88 <sb>
    80003eb6:	4f0c                	lw	a1,24(a4)
    80003eb8:	9dbd                	addw	a1,a1,a5
    80003eba:	4088                	lw	a0,0(s1)
    80003ebc:	fffff097          	auipc	ra,0xfffff
    80003ec0:	760080e7          	jalr	1888(ra) # 8000361c <bread>
    80003ec4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ec6:	07050593          	addi	a1,a0,112
    80003eca:	40dc                	lw	a5,4(s1)
    80003ecc:	8bbd                	andi	a5,a5,15
    80003ece:	079a                	slli	a5,a5,0x6
    80003ed0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ed2:	00059783          	lh	a5,0(a1)
    80003ed6:	04f49e23          	sh	a5,92(s1)
    ip->major = dip->major;
    80003eda:	00259783          	lh	a5,2(a1)
    80003ede:	04f49f23          	sh	a5,94(s1)
    ip->minor = dip->minor;
    80003ee2:	00459783          	lh	a5,4(a1)
    80003ee6:	06f49023          	sh	a5,96(s1)
    ip->nlink = dip->nlink;
    80003eea:	00659783          	lh	a5,6(a1)
    80003eee:	06f49123          	sh	a5,98(s1)
    ip->size = dip->size;
    80003ef2:	459c                	lw	a5,8(a1)
    80003ef4:	d0fc                	sw	a5,100(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ef6:	03400613          	li	a2,52
    80003efa:	05b1                	addi	a1,a1,12
    80003efc:	06848513          	addi	a0,s1,104
    80003f00:	ffffd097          	auipc	ra,0xffffd
    80003f04:	29a080e7          	jalr	666(ra) # 8000119a <memmove>
    brelse(bp);
    80003f08:	854a                	mv	a0,s2
    80003f0a:	00000097          	auipc	ra,0x0
    80003f0e:	858080e7          	jalr	-1960(ra) # 80003762 <brelse>
    ip->valid = 1;
    80003f12:	4785                	li	a5,1
    80003f14:	ccbc                	sw	a5,88(s1)
    if(ip->type == 0)
    80003f16:	05c49783          	lh	a5,92(s1)
    80003f1a:	fbad                	bnez	a5,80003e8c <ilock+0x24>
      panic("ilock: no type");
    80003f1c:	00005517          	auipc	a0,0x5
    80003f20:	c0450513          	addi	a0,a0,-1020 # 80008b20 <userret+0xa90>
    80003f24:	ffffd097          	auipc	ra,0xffffd
    80003f28:	860080e7          	jalr	-1952(ra) # 80000784 <panic>

0000000080003f2c <iunlock>:
{
    80003f2c:	1101                	addi	sp,sp,-32
    80003f2e:	ec06                	sd	ra,24(sp)
    80003f30:	e822                	sd	s0,16(sp)
    80003f32:	e426                	sd	s1,8(sp)
    80003f34:	e04a                	sd	s2,0(sp)
    80003f36:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f38:	c905                	beqz	a0,80003f68 <iunlock+0x3c>
    80003f3a:	84aa                	mv	s1,a0
    80003f3c:	01050913          	addi	s2,a0,16
    80003f40:	854a                	mv	a0,s2
    80003f42:	00001097          	auipc	ra,0x1
    80003f46:	d6e080e7          	jalr	-658(ra) # 80004cb0 <holdingsleep>
    80003f4a:	cd19                	beqz	a0,80003f68 <iunlock+0x3c>
    80003f4c:	449c                	lw	a5,8(s1)
    80003f4e:	00f05d63          	blez	a5,80003f68 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f52:	854a                	mv	a0,s2
    80003f54:	00001097          	auipc	ra,0x1
    80003f58:	d18080e7          	jalr	-744(ra) # 80004c6c <releasesleep>
}
    80003f5c:	60e2                	ld	ra,24(sp)
    80003f5e:	6442                	ld	s0,16(sp)
    80003f60:	64a2                	ld	s1,8(sp)
    80003f62:	6902                	ld	s2,0(sp)
    80003f64:	6105                	addi	sp,sp,32
    80003f66:	8082                	ret
    panic("iunlock");
    80003f68:	00005517          	auipc	a0,0x5
    80003f6c:	bc850513          	addi	a0,a0,-1080 # 80008b30 <userret+0xaa0>
    80003f70:	ffffd097          	auipc	ra,0xffffd
    80003f74:	814080e7          	jalr	-2028(ra) # 80000784 <panic>

0000000080003f78 <iput>:
{
    80003f78:	7139                	addi	sp,sp,-64
    80003f7a:	fc06                	sd	ra,56(sp)
    80003f7c:	f822                	sd	s0,48(sp)
    80003f7e:	f426                	sd	s1,40(sp)
    80003f80:	f04a                	sd	s2,32(sp)
    80003f82:	ec4e                	sd	s3,24(sp)
    80003f84:	e852                	sd	s4,16(sp)
    80003f86:	e456                	sd	s5,8(sp)
    80003f88:	0080                	addi	s0,sp,64
    80003f8a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003f8c:	00021517          	auipc	a0,0x21
    80003f90:	b1c50513          	addi	a0,a0,-1252 # 80024aa8 <icache>
    80003f94:	ffffd097          	auipc	ra,0xffffd
    80003f98:	d26080e7          	jalr	-730(ra) # 80000cba <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f9c:	4498                	lw	a4,8(s1)
    80003f9e:	4785                	li	a5,1
    80003fa0:	02f70663          	beq	a4,a5,80003fcc <iput+0x54>
  ip->ref--;
    80003fa4:	449c                	lw	a5,8(s1)
    80003fa6:	37fd                	addiw	a5,a5,-1
    80003fa8:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003faa:	00021517          	auipc	a0,0x21
    80003fae:	afe50513          	addi	a0,a0,-1282 # 80024aa8 <icache>
    80003fb2:	ffffd097          	auipc	ra,0xffffd
    80003fb6:	f54080e7          	jalr	-172(ra) # 80000f06 <release>
}
    80003fba:	70e2                	ld	ra,56(sp)
    80003fbc:	7442                	ld	s0,48(sp)
    80003fbe:	74a2                	ld	s1,40(sp)
    80003fc0:	7902                	ld	s2,32(sp)
    80003fc2:	69e2                	ld	s3,24(sp)
    80003fc4:	6a42                	ld	s4,16(sp)
    80003fc6:	6aa2                	ld	s5,8(sp)
    80003fc8:	6121                	addi	sp,sp,64
    80003fca:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fcc:	4cbc                	lw	a5,88(s1)
    80003fce:	dbf9                	beqz	a5,80003fa4 <iput+0x2c>
    80003fd0:	06249783          	lh	a5,98(s1)
    80003fd4:	fbe1                	bnez	a5,80003fa4 <iput+0x2c>
    acquiresleep(&ip->lock);
    80003fd6:	01048a13          	addi	s4,s1,16
    80003fda:	8552                	mv	a0,s4
    80003fdc:	00001097          	auipc	ra,0x1
    80003fe0:	c3a080e7          	jalr	-966(ra) # 80004c16 <acquiresleep>
    release(&icache.lock);
    80003fe4:	00021517          	auipc	a0,0x21
    80003fe8:	ac450513          	addi	a0,a0,-1340 # 80024aa8 <icache>
    80003fec:	ffffd097          	auipc	ra,0xffffd
    80003ff0:	f1a080e7          	jalr	-230(ra) # 80000f06 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ff4:	06848913          	addi	s2,s1,104
    80003ff8:	09848993          	addi	s3,s1,152
    80003ffc:	a819                	j	80004012 <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003ffe:	4088                	lw	a0,0(s1)
    80004000:	00000097          	auipc	ra,0x0
    80004004:	878080e7          	jalr	-1928(ra) # 80003878 <bfree>
      ip->addrs[i] = 0;
    80004008:	00092023          	sw	zero,0(s2)
    8000400c:	0911                	addi	s2,s2,4
  for(i = 0; i < NDIRECT; i++){
    8000400e:	01390663          	beq	s2,s3,8000401a <iput+0xa2>
    if(ip->addrs[i]){
    80004012:	00092583          	lw	a1,0(s2)
    80004016:	d9fd                	beqz	a1,8000400c <iput+0x94>
    80004018:	b7dd                	j	80003ffe <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000401a:	0984a583          	lw	a1,152(s1)
    8000401e:	ed9d                	bnez	a1,8000405c <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004020:	0604a223          	sw	zero,100(s1)
  iupdate(ip);
    80004024:	8526                	mv	a0,s1
    80004026:	00000097          	auipc	ra,0x0
    8000402a:	d76080e7          	jalr	-650(ra) # 80003d9c <iupdate>
    ip->type = 0;
    8000402e:	04049e23          	sh	zero,92(s1)
    iupdate(ip);
    80004032:	8526                	mv	a0,s1
    80004034:	00000097          	auipc	ra,0x0
    80004038:	d68080e7          	jalr	-664(ra) # 80003d9c <iupdate>
    ip->valid = 0;
    8000403c:	0404ac23          	sw	zero,88(s1)
    releasesleep(&ip->lock);
    80004040:	8552                	mv	a0,s4
    80004042:	00001097          	auipc	ra,0x1
    80004046:	c2a080e7          	jalr	-982(ra) # 80004c6c <releasesleep>
    acquire(&icache.lock);
    8000404a:	00021517          	auipc	a0,0x21
    8000404e:	a5e50513          	addi	a0,a0,-1442 # 80024aa8 <icache>
    80004052:	ffffd097          	auipc	ra,0xffffd
    80004056:	c68080e7          	jalr	-920(ra) # 80000cba <acquire>
    8000405a:	b7a9                	j	80003fa4 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000405c:	4088                	lw	a0,0(s1)
    8000405e:	fffff097          	auipc	ra,0xfffff
    80004062:	5be080e7          	jalr	1470(ra) # 8000361c <bread>
    80004066:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80004068:	07050913          	addi	s2,a0,112
    8000406c:	47050993          	addi	s3,a0,1136
    80004070:	a809                	j	80004082 <iput+0x10a>
        bfree(ip->dev, a[j]);
    80004072:	4088                	lw	a0,0(s1)
    80004074:	00000097          	auipc	ra,0x0
    80004078:	804080e7          	jalr	-2044(ra) # 80003878 <bfree>
    8000407c:	0911                	addi	s2,s2,4
    for(j = 0; j < NINDIRECT; j++){
    8000407e:	01390663          	beq	s2,s3,8000408a <iput+0x112>
      if(a[j])
    80004082:	00092583          	lw	a1,0(s2)
    80004086:	d9fd                	beqz	a1,8000407c <iput+0x104>
    80004088:	b7ed                	j	80004072 <iput+0xfa>
    brelse(bp);
    8000408a:	8556                	mv	a0,s5
    8000408c:	fffff097          	auipc	ra,0xfffff
    80004090:	6d6080e7          	jalr	1750(ra) # 80003762 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004094:	0984a583          	lw	a1,152(s1)
    80004098:	4088                	lw	a0,0(s1)
    8000409a:	fffff097          	auipc	ra,0xfffff
    8000409e:	7de080e7          	jalr	2014(ra) # 80003878 <bfree>
    ip->addrs[NDIRECT] = 0;
    800040a2:	0804ac23          	sw	zero,152(s1)
    800040a6:	bfad                	j	80004020 <iput+0xa8>

00000000800040a8 <iunlockput>:
{
    800040a8:	1101                	addi	sp,sp,-32
    800040aa:	ec06                	sd	ra,24(sp)
    800040ac:	e822                	sd	s0,16(sp)
    800040ae:	e426                	sd	s1,8(sp)
    800040b0:	1000                	addi	s0,sp,32
    800040b2:	84aa                	mv	s1,a0
  iunlock(ip);
    800040b4:	00000097          	auipc	ra,0x0
    800040b8:	e78080e7          	jalr	-392(ra) # 80003f2c <iunlock>
  iput(ip);
    800040bc:	8526                	mv	a0,s1
    800040be:	00000097          	auipc	ra,0x0
    800040c2:	eba080e7          	jalr	-326(ra) # 80003f78 <iput>
}
    800040c6:	60e2                	ld	ra,24(sp)
    800040c8:	6442                	ld	s0,16(sp)
    800040ca:	64a2                	ld	s1,8(sp)
    800040cc:	6105                	addi	sp,sp,32
    800040ce:	8082                	ret

00000000800040d0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800040d0:	1141                	addi	sp,sp,-16
    800040d2:	e422                	sd	s0,8(sp)
    800040d4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800040d6:	411c                	lw	a5,0(a0)
    800040d8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800040da:	415c                	lw	a5,4(a0)
    800040dc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800040de:	05c51783          	lh	a5,92(a0)
    800040e2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800040e6:	06251783          	lh	a5,98(a0)
    800040ea:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800040ee:	06456783          	lwu	a5,100(a0)
    800040f2:	e99c                	sd	a5,16(a1)
}
    800040f4:	6422                	ld	s0,8(sp)
    800040f6:	0141                	addi	sp,sp,16
    800040f8:	8082                	ret

00000000800040fa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040fa:	517c                	lw	a5,100(a0)
    800040fc:	0ed7e563          	bltu	a5,a3,800041e6 <readi+0xec>
{
    80004100:	7159                	addi	sp,sp,-112
    80004102:	f486                	sd	ra,104(sp)
    80004104:	f0a2                	sd	s0,96(sp)
    80004106:	eca6                	sd	s1,88(sp)
    80004108:	e8ca                	sd	s2,80(sp)
    8000410a:	e4ce                	sd	s3,72(sp)
    8000410c:	e0d2                	sd	s4,64(sp)
    8000410e:	fc56                	sd	s5,56(sp)
    80004110:	f85a                	sd	s6,48(sp)
    80004112:	f45e                	sd	s7,40(sp)
    80004114:	f062                	sd	s8,32(sp)
    80004116:	ec66                	sd	s9,24(sp)
    80004118:	e86a                	sd	s10,16(sp)
    8000411a:	e46e                	sd	s11,8(sp)
    8000411c:	1880                	addi	s0,sp,112
    8000411e:	8baa                	mv	s7,a0
    80004120:	8c2e                	mv	s8,a1
    80004122:	8a32                	mv	s4,a2
    80004124:	84b6                	mv	s1,a3
    80004126:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004128:	9f35                	addw	a4,a4,a3
    8000412a:	0cd76063          	bltu	a4,a3,800041ea <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    8000412e:	00e7f463          	bleu	a4,a5,80004136 <readi+0x3c>
    n = ip->size - off;
    80004132:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004136:	080b0763          	beqz	s6,800041c4 <readi+0xca>
    8000413a:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000413c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004140:	5cfd                	li	s9,-1
    80004142:	a82d                	j	8000417c <readi+0x82>
    80004144:	02091d93          	slli	s11,s2,0x20
    80004148:	020ddd93          	srli	s11,s11,0x20
    8000414c:	070a8613          	addi	a2,s5,112
    80004150:	86ee                	mv	a3,s11
    80004152:	963a                	add	a2,a2,a4
    80004154:	85d2                	mv	a1,s4
    80004156:	8562                	mv	a0,s8
    80004158:	fffff097          	auipc	ra,0xfffff
    8000415c:	94e080e7          	jalr	-1714(ra) # 80002aa6 <either_copyout>
    80004160:	05950d63          	beq	a0,s9,800041ba <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80004164:	8556                	mv	a0,s5
    80004166:	fffff097          	auipc	ra,0xfffff
    8000416a:	5fc080e7          	jalr	1532(ra) # 80003762 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000416e:	013909bb          	addw	s3,s2,s3
    80004172:	009904bb          	addw	s1,s2,s1
    80004176:	9a6e                	add	s4,s4,s11
    80004178:	0569f663          	bleu	s6,s3,800041c4 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000417c:	000ba903          	lw	s2,0(s7)
    80004180:	00a4d59b          	srliw	a1,s1,0xa
    80004184:	855e                	mv	a0,s7
    80004186:	00000097          	auipc	ra,0x0
    8000418a:	8d2080e7          	jalr	-1838(ra) # 80003a58 <bmap>
    8000418e:	0005059b          	sext.w	a1,a0
    80004192:	854a                	mv	a0,s2
    80004194:	fffff097          	auipc	ra,0xfffff
    80004198:	488080e7          	jalr	1160(ra) # 8000361c <bread>
    8000419c:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000419e:	3ff4f713          	andi	a4,s1,1023
    800041a2:	40ed07bb          	subw	a5,s10,a4
    800041a6:	413b06bb          	subw	a3,s6,s3
    800041aa:	893e                	mv	s2,a5
    800041ac:	2781                	sext.w	a5,a5
    800041ae:	0006861b          	sext.w	a2,a3
    800041b2:	f8f679e3          	bleu	a5,a2,80004144 <readi+0x4a>
    800041b6:	8936                	mv	s2,a3
    800041b8:	b771                	j	80004144 <readi+0x4a>
      brelse(bp);
    800041ba:	8556                	mv	a0,s5
    800041bc:	fffff097          	auipc	ra,0xfffff
    800041c0:	5a6080e7          	jalr	1446(ra) # 80003762 <brelse>
  }
  return n;
    800041c4:	000b051b          	sext.w	a0,s6
}
    800041c8:	70a6                	ld	ra,104(sp)
    800041ca:	7406                	ld	s0,96(sp)
    800041cc:	64e6                	ld	s1,88(sp)
    800041ce:	6946                	ld	s2,80(sp)
    800041d0:	69a6                	ld	s3,72(sp)
    800041d2:	6a06                	ld	s4,64(sp)
    800041d4:	7ae2                	ld	s5,56(sp)
    800041d6:	7b42                	ld	s6,48(sp)
    800041d8:	7ba2                	ld	s7,40(sp)
    800041da:	7c02                	ld	s8,32(sp)
    800041dc:	6ce2                	ld	s9,24(sp)
    800041de:	6d42                	ld	s10,16(sp)
    800041e0:	6da2                	ld	s11,8(sp)
    800041e2:	6165                	addi	sp,sp,112
    800041e4:	8082                	ret
    return -1;
    800041e6:	557d                	li	a0,-1
}
    800041e8:	8082                	ret
    return -1;
    800041ea:	557d                	li	a0,-1
    800041ec:	bff1                	j	800041c8 <readi+0xce>

00000000800041ee <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041ee:	517c                	lw	a5,100(a0)
    800041f0:	10d7e663          	bltu	a5,a3,800042fc <writei+0x10e>
{
    800041f4:	7159                	addi	sp,sp,-112
    800041f6:	f486                	sd	ra,104(sp)
    800041f8:	f0a2                	sd	s0,96(sp)
    800041fa:	eca6                	sd	s1,88(sp)
    800041fc:	e8ca                	sd	s2,80(sp)
    800041fe:	e4ce                	sd	s3,72(sp)
    80004200:	e0d2                	sd	s4,64(sp)
    80004202:	fc56                	sd	s5,56(sp)
    80004204:	f85a                	sd	s6,48(sp)
    80004206:	f45e                	sd	s7,40(sp)
    80004208:	f062                	sd	s8,32(sp)
    8000420a:	ec66                	sd	s9,24(sp)
    8000420c:	e86a                	sd	s10,16(sp)
    8000420e:	e46e                	sd	s11,8(sp)
    80004210:	1880                	addi	s0,sp,112
    80004212:	8baa                	mv	s7,a0
    80004214:	8c2e                	mv	s8,a1
    80004216:	8ab2                	mv	s5,a2
    80004218:	84b6                	mv	s1,a3
    8000421a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000421c:	00e687bb          	addw	a5,a3,a4
    80004220:	0ed7e063          	bltu	a5,a3,80004300 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004224:	00043737          	lui	a4,0x43
    80004228:	0cf76e63          	bltu	a4,a5,80004304 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000422c:	0a0b0763          	beqz	s6,800042da <writei+0xec>
    80004230:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004232:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004236:	5cfd                	li	s9,-1
    80004238:	a091                	j	8000427c <writei+0x8e>
    8000423a:	02091d93          	slli	s11,s2,0x20
    8000423e:	020ddd93          	srli	s11,s11,0x20
    80004242:	07098513          	addi	a0,s3,112
    80004246:	86ee                	mv	a3,s11
    80004248:	8656                	mv	a2,s5
    8000424a:	85e2                	mv	a1,s8
    8000424c:	953a                	add	a0,a0,a4
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	8ae080e7          	jalr	-1874(ra) # 80002afc <either_copyin>
    80004256:	07950263          	beq	a0,s9,800042ba <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000425a:	854e                	mv	a0,s3
    8000425c:	00001097          	auipc	ra,0x1
    80004260:	830080e7          	jalr	-2000(ra) # 80004a8c <log_write>
    brelse(bp);
    80004264:	854e                	mv	a0,s3
    80004266:	fffff097          	auipc	ra,0xfffff
    8000426a:	4fc080e7          	jalr	1276(ra) # 80003762 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000426e:	01490a3b          	addw	s4,s2,s4
    80004272:	009904bb          	addw	s1,s2,s1
    80004276:	9aee                	add	s5,s5,s11
    80004278:	056a7663          	bleu	s6,s4,800042c4 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000427c:	000ba903          	lw	s2,0(s7)
    80004280:	00a4d59b          	srliw	a1,s1,0xa
    80004284:	855e                	mv	a0,s7
    80004286:	fffff097          	auipc	ra,0xfffff
    8000428a:	7d2080e7          	jalr	2002(ra) # 80003a58 <bmap>
    8000428e:	0005059b          	sext.w	a1,a0
    80004292:	854a                	mv	a0,s2
    80004294:	fffff097          	auipc	ra,0xfffff
    80004298:	388080e7          	jalr	904(ra) # 8000361c <bread>
    8000429c:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000429e:	3ff4f713          	andi	a4,s1,1023
    800042a2:	40ed07bb          	subw	a5,s10,a4
    800042a6:	414b06bb          	subw	a3,s6,s4
    800042aa:	893e                	mv	s2,a5
    800042ac:	2781                	sext.w	a5,a5
    800042ae:	0006861b          	sext.w	a2,a3
    800042b2:	f8f674e3          	bleu	a5,a2,8000423a <writei+0x4c>
    800042b6:	8936                	mv	s2,a3
    800042b8:	b749                	j	8000423a <writei+0x4c>
      brelse(bp);
    800042ba:	854e                	mv	a0,s3
    800042bc:	fffff097          	auipc	ra,0xfffff
    800042c0:	4a6080e7          	jalr	1190(ra) # 80003762 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    800042c4:	064ba783          	lw	a5,100(s7)
    800042c8:	0097f463          	bleu	s1,a5,800042d0 <writei+0xe2>
      ip->size = off;
    800042cc:	069ba223          	sw	s1,100(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    800042d0:	855e                	mv	a0,s7
    800042d2:	00000097          	auipc	ra,0x0
    800042d6:	aca080e7          	jalr	-1334(ra) # 80003d9c <iupdate>
  }

  return n;
    800042da:	000b051b          	sext.w	a0,s6
}
    800042de:	70a6                	ld	ra,104(sp)
    800042e0:	7406                	ld	s0,96(sp)
    800042e2:	64e6                	ld	s1,88(sp)
    800042e4:	6946                	ld	s2,80(sp)
    800042e6:	69a6                	ld	s3,72(sp)
    800042e8:	6a06                	ld	s4,64(sp)
    800042ea:	7ae2                	ld	s5,56(sp)
    800042ec:	7b42                	ld	s6,48(sp)
    800042ee:	7ba2                	ld	s7,40(sp)
    800042f0:	7c02                	ld	s8,32(sp)
    800042f2:	6ce2                	ld	s9,24(sp)
    800042f4:	6d42                	ld	s10,16(sp)
    800042f6:	6da2                	ld	s11,8(sp)
    800042f8:	6165                	addi	sp,sp,112
    800042fa:	8082                	ret
    return -1;
    800042fc:	557d                	li	a0,-1
}
    800042fe:	8082                	ret
    return -1;
    80004300:	557d                	li	a0,-1
    80004302:	bff1                	j	800042de <writei+0xf0>
    return -1;
    80004304:	557d                	li	a0,-1
    80004306:	bfe1                	j	800042de <writei+0xf0>

0000000080004308 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004308:	1141                	addi	sp,sp,-16
    8000430a:	e406                	sd	ra,8(sp)
    8000430c:	e022                	sd	s0,0(sp)
    8000430e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004310:	4639                	li	a2,14
    80004312:	ffffd097          	auipc	ra,0xffffd
    80004316:	f04080e7          	jalr	-252(ra) # 80001216 <strncmp>
}
    8000431a:	60a2                	ld	ra,8(sp)
    8000431c:	6402                	ld	s0,0(sp)
    8000431e:	0141                	addi	sp,sp,16
    80004320:	8082                	ret

0000000080004322 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004322:	7139                	addi	sp,sp,-64
    80004324:	fc06                	sd	ra,56(sp)
    80004326:	f822                	sd	s0,48(sp)
    80004328:	f426                	sd	s1,40(sp)
    8000432a:	f04a                	sd	s2,32(sp)
    8000432c:	ec4e                	sd	s3,24(sp)
    8000432e:	e852                	sd	s4,16(sp)
    80004330:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004332:	05c51703          	lh	a4,92(a0)
    80004336:	4785                	li	a5,1
    80004338:	00f71a63          	bne	a4,a5,8000434c <dirlookup+0x2a>
    8000433c:	892a                	mv	s2,a0
    8000433e:	89ae                	mv	s3,a1
    80004340:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004342:	517c                	lw	a5,100(a0)
    80004344:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004346:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004348:	e79d                	bnez	a5,80004376 <dirlookup+0x54>
    8000434a:	a8a5                	j	800043c2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000434c:	00004517          	auipc	a0,0x4
    80004350:	7ec50513          	addi	a0,a0,2028 # 80008b38 <userret+0xaa8>
    80004354:	ffffc097          	auipc	ra,0xffffc
    80004358:	430080e7          	jalr	1072(ra) # 80000784 <panic>
      panic("dirlookup read");
    8000435c:	00004517          	auipc	a0,0x4
    80004360:	7f450513          	addi	a0,a0,2036 # 80008b50 <userret+0xac0>
    80004364:	ffffc097          	auipc	ra,0xffffc
    80004368:	420080e7          	jalr	1056(ra) # 80000784 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000436c:	24c1                	addiw	s1,s1,16
    8000436e:	06492783          	lw	a5,100(s2)
    80004372:	04f4f763          	bleu	a5,s1,800043c0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004376:	4741                	li	a4,16
    80004378:	86a6                	mv	a3,s1
    8000437a:	fc040613          	addi	a2,s0,-64
    8000437e:	4581                	li	a1,0
    80004380:	854a                	mv	a0,s2
    80004382:	00000097          	auipc	ra,0x0
    80004386:	d78080e7          	jalr	-648(ra) # 800040fa <readi>
    8000438a:	47c1                	li	a5,16
    8000438c:	fcf518e3          	bne	a0,a5,8000435c <dirlookup+0x3a>
    if(de.inum == 0)
    80004390:	fc045783          	lhu	a5,-64(s0)
    80004394:	dfe1                	beqz	a5,8000436c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004396:	fc240593          	addi	a1,s0,-62
    8000439a:	854e                	mv	a0,s3
    8000439c:	00000097          	auipc	ra,0x0
    800043a0:	f6c080e7          	jalr	-148(ra) # 80004308 <namecmp>
    800043a4:	f561                	bnez	a0,8000436c <dirlookup+0x4a>
      if(poff)
    800043a6:	000a0463          	beqz	s4,800043ae <dirlookup+0x8c>
        *poff = off;
    800043aa:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    800043ae:	fc045583          	lhu	a1,-64(s0)
    800043b2:	00092503          	lw	a0,0(s2)
    800043b6:	fffff097          	auipc	ra,0xfffff
    800043ba:	77c080e7          	jalr	1916(ra) # 80003b32 <iget>
    800043be:	a011                	j	800043c2 <dirlookup+0xa0>
  return 0;
    800043c0:	4501                	li	a0,0
}
    800043c2:	70e2                	ld	ra,56(sp)
    800043c4:	7442                	ld	s0,48(sp)
    800043c6:	74a2                	ld	s1,40(sp)
    800043c8:	7902                	ld	s2,32(sp)
    800043ca:	69e2                	ld	s3,24(sp)
    800043cc:	6a42                	ld	s4,16(sp)
    800043ce:	6121                	addi	sp,sp,64
    800043d0:	8082                	ret

00000000800043d2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800043d2:	711d                	addi	sp,sp,-96
    800043d4:	ec86                	sd	ra,88(sp)
    800043d6:	e8a2                	sd	s0,80(sp)
    800043d8:	e4a6                	sd	s1,72(sp)
    800043da:	e0ca                	sd	s2,64(sp)
    800043dc:	fc4e                	sd	s3,56(sp)
    800043de:	f852                	sd	s4,48(sp)
    800043e0:	f456                	sd	s5,40(sp)
    800043e2:	f05a                	sd	s6,32(sp)
    800043e4:	ec5e                	sd	s7,24(sp)
    800043e6:	e862                	sd	s8,16(sp)
    800043e8:	e466                	sd	s9,8(sp)
    800043ea:	1080                	addi	s0,sp,96
    800043ec:	84aa                	mv	s1,a0
    800043ee:	8bae                	mv	s7,a1
    800043f0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800043f2:	00054703          	lbu	a4,0(a0)
    800043f6:	02f00793          	li	a5,47
    800043fa:	02f70363          	beq	a4,a5,80004420 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800043fe:	ffffe097          	auipc	ra,0xffffe
    80004402:	c42080e7          	jalr	-958(ra) # 80002040 <myproc>
    80004406:	16853503          	ld	a0,360(a0)
    8000440a:	00000097          	auipc	ra,0x0
    8000440e:	a20080e7          	jalr	-1504(ra) # 80003e2a <idup>
    80004412:	89aa                	mv	s3,a0
  while(*path == '/')
    80004414:	02f00913          	li	s2,47
  len = path - s;
    80004418:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000441a:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000441c:	4c05                	li	s8,1
    8000441e:	a865                	j	800044d6 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004420:	4585                	li	a1,1
    80004422:	4501                	li	a0,0
    80004424:	fffff097          	auipc	ra,0xfffff
    80004428:	70e080e7          	jalr	1806(ra) # 80003b32 <iget>
    8000442c:	89aa                	mv	s3,a0
    8000442e:	b7dd                	j	80004414 <namex+0x42>
      iunlockput(ip);
    80004430:	854e                	mv	a0,s3
    80004432:	00000097          	auipc	ra,0x0
    80004436:	c76080e7          	jalr	-906(ra) # 800040a8 <iunlockput>
      return 0;
    8000443a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000443c:	854e                	mv	a0,s3
    8000443e:	60e6                	ld	ra,88(sp)
    80004440:	6446                	ld	s0,80(sp)
    80004442:	64a6                	ld	s1,72(sp)
    80004444:	6906                	ld	s2,64(sp)
    80004446:	79e2                	ld	s3,56(sp)
    80004448:	7a42                	ld	s4,48(sp)
    8000444a:	7aa2                	ld	s5,40(sp)
    8000444c:	7b02                	ld	s6,32(sp)
    8000444e:	6be2                	ld	s7,24(sp)
    80004450:	6c42                	ld	s8,16(sp)
    80004452:	6ca2                	ld	s9,8(sp)
    80004454:	6125                	addi	sp,sp,96
    80004456:	8082                	ret
      iunlock(ip);
    80004458:	854e                	mv	a0,s3
    8000445a:	00000097          	auipc	ra,0x0
    8000445e:	ad2080e7          	jalr	-1326(ra) # 80003f2c <iunlock>
      return ip;
    80004462:	bfe9                	j	8000443c <namex+0x6a>
      iunlockput(ip);
    80004464:	854e                	mv	a0,s3
    80004466:	00000097          	auipc	ra,0x0
    8000446a:	c42080e7          	jalr	-958(ra) # 800040a8 <iunlockput>
      return 0;
    8000446e:	89d2                	mv	s3,s4
    80004470:	b7f1                	j	8000443c <namex+0x6a>
  len = path - s;
    80004472:	40b48633          	sub	a2,s1,a1
    80004476:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000447a:	094cd663          	ble	s4,s9,80004506 <namex+0x134>
    memmove(name, s, DIRSIZ);
    8000447e:	4639                	li	a2,14
    80004480:	8556                	mv	a0,s5
    80004482:	ffffd097          	auipc	ra,0xffffd
    80004486:	d18080e7          	jalr	-744(ra) # 8000119a <memmove>
  while(*path == '/')
    8000448a:	0004c783          	lbu	a5,0(s1)
    8000448e:	01279763          	bne	a5,s2,8000449c <namex+0xca>
    path++;
    80004492:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004494:	0004c783          	lbu	a5,0(s1)
    80004498:	ff278de3          	beq	a5,s2,80004492 <namex+0xc0>
    ilock(ip);
    8000449c:	854e                	mv	a0,s3
    8000449e:	00000097          	auipc	ra,0x0
    800044a2:	9ca080e7          	jalr	-1590(ra) # 80003e68 <ilock>
    if(ip->type != T_DIR){
    800044a6:	05c99783          	lh	a5,92(s3)
    800044aa:	f98793e3          	bne	a5,s8,80004430 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800044ae:	000b8563          	beqz	s7,800044b8 <namex+0xe6>
    800044b2:	0004c783          	lbu	a5,0(s1)
    800044b6:	d3cd                	beqz	a5,80004458 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800044b8:	865a                	mv	a2,s6
    800044ba:	85d6                	mv	a1,s5
    800044bc:	854e                	mv	a0,s3
    800044be:	00000097          	auipc	ra,0x0
    800044c2:	e64080e7          	jalr	-412(ra) # 80004322 <dirlookup>
    800044c6:	8a2a                	mv	s4,a0
    800044c8:	dd51                	beqz	a0,80004464 <namex+0x92>
    iunlockput(ip);
    800044ca:	854e                	mv	a0,s3
    800044cc:	00000097          	auipc	ra,0x0
    800044d0:	bdc080e7          	jalr	-1060(ra) # 800040a8 <iunlockput>
    ip = next;
    800044d4:	89d2                	mv	s3,s4
  while(*path == '/')
    800044d6:	0004c783          	lbu	a5,0(s1)
    800044da:	05279d63          	bne	a5,s2,80004534 <namex+0x162>
    path++;
    800044de:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044e0:	0004c783          	lbu	a5,0(s1)
    800044e4:	ff278de3          	beq	a5,s2,800044de <namex+0x10c>
  if(*path == 0)
    800044e8:	cf8d                	beqz	a5,80004522 <namex+0x150>
  while(*path != '/' && *path != 0)
    800044ea:	01278b63          	beq	a5,s2,80004500 <namex+0x12e>
    800044ee:	c795                	beqz	a5,8000451a <namex+0x148>
    path++;
    800044f0:	85a6                	mv	a1,s1
    path++;
    800044f2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800044f4:	0004c783          	lbu	a5,0(s1)
    800044f8:	f7278de3          	beq	a5,s2,80004472 <namex+0xa0>
    800044fc:	fbfd                	bnez	a5,800044f2 <namex+0x120>
    800044fe:	bf95                	j	80004472 <namex+0xa0>
    80004500:	85a6                	mv	a1,s1
  len = path - s;
    80004502:	8a5a                	mv	s4,s6
    80004504:	865a                	mv	a2,s6
    memmove(name, s, len);
    80004506:	2601                	sext.w	a2,a2
    80004508:	8556                	mv	a0,s5
    8000450a:	ffffd097          	auipc	ra,0xffffd
    8000450e:	c90080e7          	jalr	-880(ra) # 8000119a <memmove>
    name[len] = 0;
    80004512:	9a56                	add	s4,s4,s5
    80004514:	000a0023          	sb	zero,0(s4)
    80004518:	bf8d                	j	8000448a <namex+0xb8>
  while(*path != '/' && *path != 0)
    8000451a:	85a6                	mv	a1,s1
  len = path - s;
    8000451c:	8a5a                	mv	s4,s6
    8000451e:	865a                	mv	a2,s6
    80004520:	b7dd                	j	80004506 <namex+0x134>
  if(nameiparent){
    80004522:	f00b8de3          	beqz	s7,8000443c <namex+0x6a>
    iput(ip);
    80004526:	854e                	mv	a0,s3
    80004528:	00000097          	auipc	ra,0x0
    8000452c:	a50080e7          	jalr	-1456(ra) # 80003f78 <iput>
    return 0;
    80004530:	4981                	li	s3,0
    80004532:	b729                	j	8000443c <namex+0x6a>
  if(*path == 0)
    80004534:	d7fd                	beqz	a5,80004522 <namex+0x150>
    80004536:	85a6                	mv	a1,s1
    80004538:	bf6d                	j	800044f2 <namex+0x120>

000000008000453a <dirlink>:
{
    8000453a:	7139                	addi	sp,sp,-64
    8000453c:	fc06                	sd	ra,56(sp)
    8000453e:	f822                	sd	s0,48(sp)
    80004540:	f426                	sd	s1,40(sp)
    80004542:	f04a                	sd	s2,32(sp)
    80004544:	ec4e                	sd	s3,24(sp)
    80004546:	e852                	sd	s4,16(sp)
    80004548:	0080                	addi	s0,sp,64
    8000454a:	892a                	mv	s2,a0
    8000454c:	8a2e                	mv	s4,a1
    8000454e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004550:	4601                	li	a2,0
    80004552:	00000097          	auipc	ra,0x0
    80004556:	dd0080e7          	jalr	-560(ra) # 80004322 <dirlookup>
    8000455a:	e93d                	bnez	a0,800045d0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000455c:	06492483          	lw	s1,100(s2)
    80004560:	c49d                	beqz	s1,8000458e <dirlink+0x54>
    80004562:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004564:	4741                	li	a4,16
    80004566:	86a6                	mv	a3,s1
    80004568:	fc040613          	addi	a2,s0,-64
    8000456c:	4581                	li	a1,0
    8000456e:	854a                	mv	a0,s2
    80004570:	00000097          	auipc	ra,0x0
    80004574:	b8a080e7          	jalr	-1142(ra) # 800040fa <readi>
    80004578:	47c1                	li	a5,16
    8000457a:	06f51163          	bne	a0,a5,800045dc <dirlink+0xa2>
    if(de.inum == 0)
    8000457e:	fc045783          	lhu	a5,-64(s0)
    80004582:	c791                	beqz	a5,8000458e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004584:	24c1                	addiw	s1,s1,16
    80004586:	06492783          	lw	a5,100(s2)
    8000458a:	fcf4ede3          	bltu	s1,a5,80004564 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000458e:	4639                	li	a2,14
    80004590:	85d2                	mv	a1,s4
    80004592:	fc240513          	addi	a0,s0,-62
    80004596:	ffffd097          	auipc	ra,0xffffd
    8000459a:	cd0080e7          	jalr	-816(ra) # 80001266 <strncpy>
  de.inum = inum;
    8000459e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045a2:	4741                	li	a4,16
    800045a4:	86a6                	mv	a3,s1
    800045a6:	fc040613          	addi	a2,s0,-64
    800045aa:	4581                	li	a1,0
    800045ac:	854a                	mv	a0,s2
    800045ae:	00000097          	auipc	ra,0x0
    800045b2:	c40080e7          	jalr	-960(ra) # 800041ee <writei>
    800045b6:	4741                	li	a4,16
  return 0;
    800045b8:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045ba:	02e51963          	bne	a0,a4,800045ec <dirlink+0xb2>
}
    800045be:	853e                	mv	a0,a5
    800045c0:	70e2                	ld	ra,56(sp)
    800045c2:	7442                	ld	s0,48(sp)
    800045c4:	74a2                	ld	s1,40(sp)
    800045c6:	7902                	ld	s2,32(sp)
    800045c8:	69e2                	ld	s3,24(sp)
    800045ca:	6a42                	ld	s4,16(sp)
    800045cc:	6121                	addi	sp,sp,64
    800045ce:	8082                	ret
    iput(ip);
    800045d0:	00000097          	auipc	ra,0x0
    800045d4:	9a8080e7          	jalr	-1624(ra) # 80003f78 <iput>
    return -1;
    800045d8:	57fd                	li	a5,-1
    800045da:	b7d5                	j	800045be <dirlink+0x84>
      panic("dirlink read");
    800045dc:	00004517          	auipc	a0,0x4
    800045e0:	58450513          	addi	a0,a0,1412 # 80008b60 <userret+0xad0>
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	1a0080e7          	jalr	416(ra) # 80000784 <panic>
    panic("dirlink");
    800045ec:	00004517          	auipc	a0,0x4
    800045f0:	69450513          	addi	a0,a0,1684 # 80008c80 <userret+0xbf0>
    800045f4:	ffffc097          	auipc	ra,0xffffc
    800045f8:	190080e7          	jalr	400(ra) # 80000784 <panic>

00000000800045fc <namei>:

struct inode*
namei(char *path)
{
    800045fc:	1101                	addi	sp,sp,-32
    800045fe:	ec06                	sd	ra,24(sp)
    80004600:	e822                	sd	s0,16(sp)
    80004602:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004604:	fe040613          	addi	a2,s0,-32
    80004608:	4581                	li	a1,0
    8000460a:	00000097          	auipc	ra,0x0
    8000460e:	dc8080e7          	jalr	-568(ra) # 800043d2 <namex>
}
    80004612:	60e2                	ld	ra,24(sp)
    80004614:	6442                	ld	s0,16(sp)
    80004616:	6105                	addi	sp,sp,32
    80004618:	8082                	ret

000000008000461a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000461a:	1141                	addi	sp,sp,-16
    8000461c:	e406                	sd	ra,8(sp)
    8000461e:	e022                	sd	s0,0(sp)
    80004620:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    80004622:	862e                	mv	a2,a1
    80004624:	4585                	li	a1,1
    80004626:	00000097          	auipc	ra,0x0
    8000462a:	dac080e7          	jalr	-596(ra) # 800043d2 <namex>
}
    8000462e:	60a2                	ld	ra,8(sp)
    80004630:	6402                	ld	s0,0(sp)
    80004632:	0141                	addi	sp,sp,16
    80004634:	8082                	ret

0000000080004636 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80004636:	7179                	addi	sp,sp,-48
    80004638:	f406                	sd	ra,40(sp)
    8000463a:	f022                	sd	s0,32(sp)
    8000463c:	ec26                	sd	s1,24(sp)
    8000463e:	e84a                	sd	s2,16(sp)
    80004640:	e44e                	sd	s3,8(sp)
    80004642:	1800                	addi	s0,sp,48
  struct buf *buf = bread(dev, log[dev].start);
    80004644:	00151913          	slli	s2,a0,0x1
    80004648:	992a                	add	s2,s2,a0
    8000464a:	00691793          	slli	a5,s2,0x6
    8000464e:	00022917          	auipc	s2,0x22
    80004652:	3ca90913          	addi	s2,s2,970 # 80026a18 <log>
    80004656:	993e                	add	s2,s2,a5
    80004658:	03092583          	lw	a1,48(s2)
    8000465c:	fffff097          	auipc	ra,0xfffff
    80004660:	fc0080e7          	jalr	-64(ra) # 8000361c <bread>
    80004664:	89aa                	mv	s3,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80004666:	04492783          	lw	a5,68(s2)
    8000466a:	d93c                	sw	a5,112(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000466c:	04492783          	lw	a5,68(s2)
    80004670:	00f05f63          	blez	a5,8000468e <write_head+0x58>
    80004674:	87ca                	mv	a5,s2
    80004676:	07450693          	addi	a3,a0,116
    8000467a:	4701                	li	a4,0
    8000467c:	85ca                	mv	a1,s2
    hb->block[i] = log[dev].lh.block[i];
    8000467e:	47b0                	lw	a2,72(a5)
    80004680:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004682:	2705                	addiw	a4,a4,1
    80004684:	0791                	addi	a5,a5,4
    80004686:	0691                	addi	a3,a3,4
    80004688:	41f0                	lw	a2,68(a1)
    8000468a:	fec74ae3          	blt	a4,a2,8000467e <write_head+0x48>
  }
  bwrite(buf);
    8000468e:	854e                	mv	a0,s3
    80004690:	fffff097          	auipc	ra,0xfffff
    80004694:	092080e7          	jalr	146(ra) # 80003722 <bwrite>
  brelse(buf);
    80004698:	854e                	mv	a0,s3
    8000469a:	fffff097          	auipc	ra,0xfffff
    8000469e:	0c8080e7          	jalr	200(ra) # 80003762 <brelse>
}
    800046a2:	70a2                	ld	ra,40(sp)
    800046a4:	7402                	ld	s0,32(sp)
    800046a6:	64e2                	ld	s1,24(sp)
    800046a8:	6942                	ld	s2,16(sp)
    800046aa:	69a2                	ld	s3,8(sp)
    800046ac:	6145                	addi	sp,sp,48
    800046ae:	8082                	ret

00000000800046b0 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800046b0:	00151793          	slli	a5,a0,0x1
    800046b4:	97aa                	add	a5,a5,a0
    800046b6:	079a                	slli	a5,a5,0x6
    800046b8:	00022717          	auipc	a4,0x22
    800046bc:	36070713          	addi	a4,a4,864 # 80026a18 <log>
    800046c0:	97ba                	add	a5,a5,a4
    800046c2:	43fc                	lw	a5,68(a5)
    800046c4:	0af05863          	blez	a5,80004774 <install_trans+0xc4>
{
    800046c8:	7139                	addi	sp,sp,-64
    800046ca:	fc06                	sd	ra,56(sp)
    800046cc:	f822                	sd	s0,48(sp)
    800046ce:	f426                	sd	s1,40(sp)
    800046d0:	f04a                	sd	s2,32(sp)
    800046d2:	ec4e                	sd	s3,24(sp)
    800046d4:	e852                	sd	s4,16(sp)
    800046d6:	e456                	sd	s5,8(sp)
    800046d8:	e05a                	sd	s6,0(sp)
    800046da:	0080                	addi	s0,sp,64
    800046dc:	00151993          	slli	s3,a0,0x1
    800046e0:	99aa                	add	s3,s3,a0
    800046e2:	00699793          	slli	a5,s3,0x6
    800046e6:	00f709b3          	add	s3,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800046ea:	4901                	li	s2,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    800046ec:	00050b1b          	sext.w	s6,a0
    800046f0:	8ace                	mv	s5,s3
    800046f2:	030aa583          	lw	a1,48(s5)
    800046f6:	012585bb          	addw	a1,a1,s2
    800046fa:	2585                	addiw	a1,a1,1
    800046fc:	855a                	mv	a0,s6
    800046fe:	fffff097          	auipc	ra,0xfffff
    80004702:	f1e080e7          	jalr	-226(ra) # 8000361c <bread>
    80004706:	8a2a                	mv	s4,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80004708:	0489a583          	lw	a1,72(s3)
    8000470c:	855a                	mv	a0,s6
    8000470e:	fffff097          	auipc	ra,0xfffff
    80004712:	f0e080e7          	jalr	-242(ra) # 8000361c <bread>
    80004716:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004718:	40000613          	li	a2,1024
    8000471c:	070a0593          	addi	a1,s4,112
    80004720:	07050513          	addi	a0,a0,112
    80004724:	ffffd097          	auipc	ra,0xffffd
    80004728:	a76080e7          	jalr	-1418(ra) # 8000119a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000472c:	8526                	mv	a0,s1
    8000472e:	fffff097          	auipc	ra,0xfffff
    80004732:	ff4080e7          	jalr	-12(ra) # 80003722 <bwrite>
    bunpin(dbuf);
    80004736:	8526                	mv	a0,s1
    80004738:	fffff097          	auipc	ra,0xfffff
    8000473c:	104080e7          	jalr	260(ra) # 8000383c <bunpin>
    brelse(lbuf);
    80004740:	8552                	mv	a0,s4
    80004742:	fffff097          	auipc	ra,0xfffff
    80004746:	020080e7          	jalr	32(ra) # 80003762 <brelse>
    brelse(dbuf);
    8000474a:	8526                	mv	a0,s1
    8000474c:	fffff097          	auipc	ra,0xfffff
    80004750:	016080e7          	jalr	22(ra) # 80003762 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004754:	2905                	addiw	s2,s2,1
    80004756:	0991                	addi	s3,s3,4
    80004758:	044aa783          	lw	a5,68(s5)
    8000475c:	f8f94be3          	blt	s2,a5,800046f2 <install_trans+0x42>
}
    80004760:	70e2                	ld	ra,56(sp)
    80004762:	7442                	ld	s0,48(sp)
    80004764:	74a2                	ld	s1,40(sp)
    80004766:	7902                	ld	s2,32(sp)
    80004768:	69e2                	ld	s3,24(sp)
    8000476a:	6a42                	ld	s4,16(sp)
    8000476c:	6aa2                	ld	s5,8(sp)
    8000476e:	6b02                	ld	s6,0(sp)
    80004770:	6121                	addi	sp,sp,64
    80004772:	8082                	ret
    80004774:	8082                	ret

0000000080004776 <initlog>:
{
    80004776:	7179                	addi	sp,sp,-48
    80004778:	f406                	sd	ra,40(sp)
    8000477a:	f022                	sd	s0,32(sp)
    8000477c:	ec26                	sd	s1,24(sp)
    8000477e:	e84a                	sd	s2,16(sp)
    80004780:	e44e                	sd	s3,8(sp)
    80004782:	e052                	sd	s4,0(sp)
    80004784:	1800                	addi	s0,sp,48
    80004786:	892a                	mv	s2,a0
    80004788:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    8000478a:	00151713          	slli	a4,a0,0x1
    8000478e:	972a                	add	a4,a4,a0
    80004790:	00671493          	slli	s1,a4,0x6
    80004794:	00022997          	auipc	s3,0x22
    80004798:	28498993          	addi	s3,s3,644 # 80026a18 <log>
    8000479c:	99a6                	add	s3,s3,s1
    8000479e:	00004597          	auipc	a1,0x4
    800047a2:	3d258593          	addi	a1,a1,978 # 80008b70 <userret+0xae0>
    800047a6:	854e                	mv	a0,s3
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	3a4080e7          	jalr	932(ra) # 80000b4c <initlock>
  log[dev].start = sb->logstart;
    800047b0:	014a2583          	lw	a1,20(s4)
    800047b4:	02b9a823          	sw	a1,48(s3)
  log[dev].size = sb->nlog;
    800047b8:	010a2783          	lw	a5,16(s4)
    800047bc:	02f9aa23          	sw	a5,52(s3)
  log[dev].dev = dev;
    800047c0:	0529a023          	sw	s2,64(s3)
  struct buf *buf = bread(dev, log[dev].start);
    800047c4:	854a                	mv	a0,s2
    800047c6:	fffff097          	auipc	ra,0xfffff
    800047ca:	e56080e7          	jalr	-426(ra) # 8000361c <bread>
  log[dev].lh.n = lh->n;
    800047ce:	593c                	lw	a5,112(a0)
    800047d0:	04f9a223          	sw	a5,68(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    800047d4:	02f05663          	blez	a5,80004800 <initlog+0x8a>
    800047d8:	07450693          	addi	a3,a0,116
    800047dc:	00022717          	auipc	a4,0x22
    800047e0:	28470713          	addi	a4,a4,644 # 80026a60 <log+0x48>
    800047e4:	9726                	add	a4,a4,s1
    800047e6:	37fd                	addiw	a5,a5,-1
    800047e8:	1782                	slli	a5,a5,0x20
    800047ea:	9381                	srli	a5,a5,0x20
    800047ec:	078a                	slli	a5,a5,0x2
    800047ee:	07850613          	addi	a2,a0,120
    800047f2:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    800047f4:	4290                	lw	a2,0(a3)
    800047f6:	c310                	sw	a2,0(a4)
    800047f8:	0691                	addi	a3,a3,4
    800047fa:	0711                	addi	a4,a4,4
  for (i = 0; i < log[dev].lh.n; i++) {
    800047fc:	fef69ce3          	bne	a3,a5,800047f4 <initlog+0x7e>
  brelse(buf);
    80004800:	fffff097          	auipc	ra,0xfffff
    80004804:	f62080e7          	jalr	-158(ra) # 80003762 <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    80004808:	854a                	mv	a0,s2
    8000480a:	00000097          	auipc	ra,0x0
    8000480e:	ea6080e7          	jalr	-346(ra) # 800046b0 <install_trans>
  log[dev].lh.n = 0;
    80004812:	00191793          	slli	a5,s2,0x1
    80004816:	97ca                	add	a5,a5,s2
    80004818:	079a                	slli	a5,a5,0x6
    8000481a:	00022717          	auipc	a4,0x22
    8000481e:	1fe70713          	addi	a4,a4,510 # 80026a18 <log>
    80004822:	97ba                	add	a5,a5,a4
    80004824:	0407a223          	sw	zero,68(a5)
  write_head(dev); // clear the log
    80004828:	854a                	mv	a0,s2
    8000482a:	00000097          	auipc	ra,0x0
    8000482e:	e0c080e7          	jalr	-500(ra) # 80004636 <write_head>
}
    80004832:	70a2                	ld	ra,40(sp)
    80004834:	7402                	ld	s0,32(sp)
    80004836:	64e2                	ld	s1,24(sp)
    80004838:	6942                	ld	s2,16(sp)
    8000483a:	69a2                	ld	s3,8(sp)
    8000483c:	6a02                	ld	s4,0(sp)
    8000483e:	6145                	addi	sp,sp,48
    80004840:	8082                	ret

0000000080004842 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    80004842:	7139                	addi	sp,sp,-64
    80004844:	fc06                	sd	ra,56(sp)
    80004846:	f822                	sd	s0,48(sp)
    80004848:	f426                	sd	s1,40(sp)
    8000484a:	f04a                	sd	s2,32(sp)
    8000484c:	ec4e                	sd	s3,24(sp)
    8000484e:	e852                	sd	s4,16(sp)
    80004850:	e456                	sd	s5,8(sp)
    80004852:	0080                	addi	s0,sp,64
    80004854:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80004856:	00151913          	slli	s2,a0,0x1
    8000485a:	992a                	add	s2,s2,a0
    8000485c:	00691793          	slli	a5,s2,0x6
    80004860:	00022917          	auipc	s2,0x22
    80004864:	1b890913          	addi	s2,s2,440 # 80026a18 <log>
    80004868:	993e                	add	s2,s2,a5
    8000486a:	854a                	mv	a0,s2
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	44e080e7          	jalr	1102(ra) # 80000cba <acquire>
  while(1){
    if(log[dev].committing){
    80004874:	00022997          	auipc	s3,0x22
    80004878:	1a498993          	addi	s3,s3,420 # 80026a18 <log>
    8000487c:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000487e:	4a79                	li	s4,30
    80004880:	a039                	j	8000488e <begin_op+0x4c>
      sleep(&log, &log[dev].lock);
    80004882:	85ca                	mv	a1,s2
    80004884:	854e                	mv	a0,s3
    80004886:	ffffe097          	auipc	ra,0xffffe
    8000488a:	fbe080e7          	jalr	-66(ra) # 80002844 <sleep>
    if(log[dev].committing){
    8000488e:	5cdc                	lw	a5,60(s1)
    80004890:	fbed                	bnez	a5,80004882 <begin_op+0x40>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004892:	5c9c                	lw	a5,56(s1)
    80004894:	0017871b          	addiw	a4,a5,1
    80004898:	0007069b          	sext.w	a3,a4
    8000489c:	0027179b          	slliw	a5,a4,0x2
    800048a0:	9fb9                	addw	a5,a5,a4
    800048a2:	0017979b          	slliw	a5,a5,0x1
    800048a6:	40f8                	lw	a4,68(s1)
    800048a8:	9fb9                	addw	a5,a5,a4
    800048aa:	00fa5963          	ble	a5,s4,800048bc <begin_op+0x7a>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    800048ae:	85ca                	mv	a1,s2
    800048b0:	854e                	mv	a0,s3
    800048b2:	ffffe097          	auipc	ra,0xffffe
    800048b6:	f92080e7          	jalr	-110(ra) # 80002844 <sleep>
    800048ba:	bfd1                	j	8000488e <begin_op+0x4c>
    } else {
      log[dev].outstanding += 1;
    800048bc:	001a9793          	slli	a5,s5,0x1
    800048c0:	9abe                	add	s5,s5,a5
    800048c2:	0a9a                	slli	s5,s5,0x6
    800048c4:	00022797          	auipc	a5,0x22
    800048c8:	15478793          	addi	a5,a5,340 # 80026a18 <log>
    800048cc:	9abe                	add	s5,s5,a5
    800048ce:	02daac23          	sw	a3,56(s5)
      release(&log[dev].lock);
    800048d2:	854a                	mv	a0,s2
    800048d4:	ffffc097          	auipc	ra,0xffffc
    800048d8:	632080e7          	jalr	1586(ra) # 80000f06 <release>
      break;
    }
  }
}
    800048dc:	70e2                	ld	ra,56(sp)
    800048de:	7442                	ld	s0,48(sp)
    800048e0:	74a2                	ld	s1,40(sp)
    800048e2:	7902                	ld	s2,32(sp)
    800048e4:	69e2                	ld	s3,24(sp)
    800048e6:	6a42                	ld	s4,16(sp)
    800048e8:	6aa2                	ld	s5,8(sp)
    800048ea:	6121                	addi	sp,sp,64
    800048ec:	8082                	ret

00000000800048ee <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    800048ee:	715d                	addi	sp,sp,-80
    800048f0:	e486                	sd	ra,72(sp)
    800048f2:	e0a2                	sd	s0,64(sp)
    800048f4:	fc26                	sd	s1,56(sp)
    800048f6:	f84a                	sd	s2,48(sp)
    800048f8:	f44e                	sd	s3,40(sp)
    800048fa:	f052                	sd	s4,32(sp)
    800048fc:	ec56                	sd	s5,24(sp)
    800048fe:	e85a                	sd	s6,16(sp)
    80004900:	e45e                	sd	s7,8(sp)
    80004902:	e062                	sd	s8,0(sp)
    80004904:	0880                	addi	s0,sp,80
    80004906:	892a                	mv	s2,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    80004908:	00151493          	slli	s1,a0,0x1
    8000490c:	94aa                	add	s1,s1,a0
    8000490e:	00649793          	slli	a5,s1,0x6
    80004912:	00022497          	auipc	s1,0x22
    80004916:	10648493          	addi	s1,s1,262 # 80026a18 <log>
    8000491a:	94be                	add	s1,s1,a5
    8000491c:	8526                	mv	a0,s1
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	39c080e7          	jalr	924(ra) # 80000cba <acquire>
  log[dev].outstanding -= 1;
    80004926:	5c9c                	lw	a5,56(s1)
    80004928:	37fd                	addiw	a5,a5,-1
    8000492a:	0007899b          	sext.w	s3,a5
    8000492e:	dc9c                	sw	a5,56(s1)
  if(log[dev].committing)
    80004930:	5cdc                	lw	a5,60(s1)
    80004932:	e3b5                	bnez	a5,80004996 <end_op+0xa8>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004934:	06099963          	bnez	s3,800049a6 <end_op+0xb8>
    do_commit = 1;
    log[dev].committing = 1;
    80004938:	00191793          	slli	a5,s2,0x1
    8000493c:	97ca                	add	a5,a5,s2
    8000493e:	079a                	slli	a5,a5,0x6
    80004940:	00022a17          	auipc	s4,0x22
    80004944:	0d8a0a13          	addi	s4,s4,216 # 80026a18 <log>
    80004948:	9a3e                	add	s4,s4,a5
    8000494a:	4785                	li	a5,1
    8000494c:	02fa2e23          	sw	a5,60(s4)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    80004950:	8526                	mv	a0,s1
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	5b4080e7          	jalr	1460(ra) # 80000f06 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    8000495a:	044a2783          	lw	a5,68(s4)
    8000495e:	06f04d63          	bgtz	a5,800049d8 <end_op+0xea>
    acquire(&log[dev].lock);
    80004962:	8526                	mv	a0,s1
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	356080e7          	jalr	854(ra) # 80000cba <acquire>
    log[dev].committing = 0;
    8000496c:	00022517          	auipc	a0,0x22
    80004970:	0ac50513          	addi	a0,a0,172 # 80026a18 <log>
    80004974:	00191793          	slli	a5,s2,0x1
    80004978:	993e                	add	s2,s2,a5
    8000497a:	091a                	slli	s2,s2,0x6
    8000497c:	992a                	add	s2,s2,a0
    8000497e:	02092e23          	sw	zero,60(s2)
    wakeup(&log);
    80004982:	ffffe097          	auipc	ra,0xffffe
    80004986:	048080e7          	jalr	72(ra) # 800029ca <wakeup>
    release(&log[dev].lock);
    8000498a:	8526                	mv	a0,s1
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	57a080e7          	jalr	1402(ra) # 80000f06 <release>
}
    80004994:	a035                	j	800049c0 <end_op+0xd2>
    panic("log[dev].committing");
    80004996:	00004517          	auipc	a0,0x4
    8000499a:	1e250513          	addi	a0,a0,482 # 80008b78 <userret+0xae8>
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	de6080e7          	jalr	-538(ra) # 80000784 <panic>
    wakeup(&log);
    800049a6:	00022517          	auipc	a0,0x22
    800049aa:	07250513          	addi	a0,a0,114 # 80026a18 <log>
    800049ae:	ffffe097          	auipc	ra,0xffffe
    800049b2:	01c080e7          	jalr	28(ra) # 800029ca <wakeup>
  release(&log[dev].lock);
    800049b6:	8526                	mv	a0,s1
    800049b8:	ffffc097          	auipc	ra,0xffffc
    800049bc:	54e080e7          	jalr	1358(ra) # 80000f06 <release>
}
    800049c0:	60a6                	ld	ra,72(sp)
    800049c2:	6406                	ld	s0,64(sp)
    800049c4:	74e2                	ld	s1,56(sp)
    800049c6:	7942                	ld	s2,48(sp)
    800049c8:	79a2                	ld	s3,40(sp)
    800049ca:	7a02                	ld	s4,32(sp)
    800049cc:	6ae2                	ld	s5,24(sp)
    800049ce:	6b42                	ld	s6,16(sp)
    800049d0:	6ba2                	ld	s7,8(sp)
    800049d2:	6c02                	ld	s8,0(sp)
    800049d4:	6161                	addi	sp,sp,80
    800049d6:	8082                	ret
    800049d8:	8aa6                	mv	s5,s1
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    800049da:	00090c1b          	sext.w	s8,s2
    800049de:	00191b93          	slli	s7,s2,0x1
    800049e2:	9bca                	add	s7,s7,s2
    800049e4:	006b9793          	slli	a5,s7,0x6
    800049e8:	00022b97          	auipc	s7,0x22
    800049ec:	030b8b93          	addi	s7,s7,48 # 80026a18 <log>
    800049f0:	9bbe                	add	s7,s7,a5
    800049f2:	030ba583          	lw	a1,48(s7)
    800049f6:	013585bb          	addw	a1,a1,s3
    800049fa:	2585                	addiw	a1,a1,1
    800049fc:	8562                	mv	a0,s8
    800049fe:	fffff097          	auipc	ra,0xfffff
    80004a02:	c1e080e7          	jalr	-994(ra) # 8000361c <bread>
    80004a06:	8a2a                	mv	s4,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80004a08:	048aa583          	lw	a1,72(s5)
    80004a0c:	8562                	mv	a0,s8
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	c0e080e7          	jalr	-1010(ra) # 8000361c <bread>
    80004a16:	8b2a                	mv	s6,a0
    memmove(to->data, from->data, BSIZE);
    80004a18:	40000613          	li	a2,1024
    80004a1c:	07050593          	addi	a1,a0,112
    80004a20:	070a0513          	addi	a0,s4,112
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	776080e7          	jalr	1910(ra) # 8000119a <memmove>
    bwrite(to);  // write the log
    80004a2c:	8552                	mv	a0,s4
    80004a2e:	fffff097          	auipc	ra,0xfffff
    80004a32:	cf4080e7          	jalr	-780(ra) # 80003722 <bwrite>
    brelse(from);
    80004a36:	855a                	mv	a0,s6
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	d2a080e7          	jalr	-726(ra) # 80003762 <brelse>
    brelse(to);
    80004a40:	8552                	mv	a0,s4
    80004a42:	fffff097          	auipc	ra,0xfffff
    80004a46:	d20080e7          	jalr	-736(ra) # 80003762 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004a4a:	2985                	addiw	s3,s3,1
    80004a4c:	0a91                	addi	s5,s5,4
    80004a4e:	044ba783          	lw	a5,68(s7)
    80004a52:	faf9c0e3          	blt	s3,a5,800049f2 <end_op+0x104>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    80004a56:	854a                	mv	a0,s2
    80004a58:	00000097          	auipc	ra,0x0
    80004a5c:	bde080e7          	jalr	-1058(ra) # 80004636 <write_head>
    install_trans(dev); // Now install writes to home locations
    80004a60:	854a                	mv	a0,s2
    80004a62:	00000097          	auipc	ra,0x0
    80004a66:	c4e080e7          	jalr	-946(ra) # 800046b0 <install_trans>
    log[dev].lh.n = 0;
    80004a6a:	00191793          	slli	a5,s2,0x1
    80004a6e:	97ca                	add	a5,a5,s2
    80004a70:	079a                	slli	a5,a5,0x6
    80004a72:	00022717          	auipc	a4,0x22
    80004a76:	fa670713          	addi	a4,a4,-90 # 80026a18 <log>
    80004a7a:	97ba                	add	a5,a5,a4
    80004a7c:	0407a223          	sw	zero,68(a5)
    write_head(dev);    // Erase the transaction from the log
    80004a80:	854a                	mv	a0,s2
    80004a82:	00000097          	auipc	ra,0x0
    80004a86:	bb4080e7          	jalr	-1100(ra) # 80004636 <write_head>
    80004a8a:	bde1                	j	80004962 <end_op+0x74>

0000000080004a8c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a8c:	7179                	addi	sp,sp,-48
    80004a8e:	f406                	sd	ra,40(sp)
    80004a90:	f022                	sd	s0,32(sp)
    80004a92:	ec26                	sd	s1,24(sp)
    80004a94:	e84a                	sd	s2,16(sp)
    80004a96:	e44e                	sd	s3,8(sp)
    80004a98:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004a9a:	4504                	lw	s1,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004a9c:	00149793          	slli	a5,s1,0x1
    80004aa0:	97a6                	add	a5,a5,s1
    80004aa2:	079a                	slli	a5,a5,0x6
    80004aa4:	00022717          	auipc	a4,0x22
    80004aa8:	f7470713          	addi	a4,a4,-140 # 80026a18 <log>
    80004aac:	97ba                	add	a5,a5,a4
    80004aae:	43f4                	lw	a3,68(a5)
    80004ab0:	47f5                	li	a5,29
    80004ab2:	0ad7c363          	blt	a5,a3,80004b58 <log_write+0xcc>
    80004ab6:	89aa                	mv	s3,a0
    80004ab8:	00149793          	slli	a5,s1,0x1
    80004abc:	97a6                	add	a5,a5,s1
    80004abe:	079a                	slli	a5,a5,0x6
    80004ac0:	97ba                	add	a5,a5,a4
    80004ac2:	5bdc                	lw	a5,52(a5)
    80004ac4:	37fd                	addiw	a5,a5,-1
    80004ac6:	08f6d963          	ble	a5,a3,80004b58 <log_write+0xcc>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004aca:	00149793          	slli	a5,s1,0x1
    80004ace:	97a6                	add	a5,a5,s1
    80004ad0:	079a                	slli	a5,a5,0x6
    80004ad2:	00022717          	auipc	a4,0x22
    80004ad6:	f4670713          	addi	a4,a4,-186 # 80026a18 <log>
    80004ada:	97ba                	add	a5,a5,a4
    80004adc:	5f9c                	lw	a5,56(a5)
    80004ade:	08f05563          	blez	a5,80004b68 <log_write+0xdc>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004ae2:	00149913          	slli	s2,s1,0x1
    80004ae6:	9926                	add	s2,s2,s1
    80004ae8:	00691793          	slli	a5,s2,0x6
    80004aec:	00022917          	auipc	s2,0x22
    80004af0:	f2c90913          	addi	s2,s2,-212 # 80026a18 <log>
    80004af4:	993e                	add	s2,s2,a5
    80004af6:	854a                	mv	a0,s2
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	1c2080e7          	jalr	450(ra) # 80000cba <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004b00:	04492603          	lw	a2,68(s2)
    80004b04:	06c05a63          	blez	a2,80004b78 <log_write+0xec>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004b08:	00c9a583          	lw	a1,12(s3)
    80004b0c:	04892783          	lw	a5,72(s2)
    80004b10:	08b78263          	beq	a5,a1,80004b94 <log_write+0x108>
    80004b14:	874a                	mv	a4,s2
  for (i = 0; i < log[dev].lh.n; i++) {
    80004b16:	4781                	li	a5,0
    80004b18:	2785                	addiw	a5,a5,1
    80004b1a:	06c78f63          	beq	a5,a2,80004b98 <log_write+0x10c>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004b1e:	4774                	lw	a3,76(a4)
    80004b20:	0711                	addi	a4,a4,4
    80004b22:	feb69be3          	bne	a3,a1,80004b18 <log_write+0x8c>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004b26:	00149713          	slli	a4,s1,0x1
    80004b2a:	94ba                	add	s1,s1,a4
    80004b2c:	0492                	slli	s1,s1,0x4
    80004b2e:	97a6                	add	a5,a5,s1
    80004b30:	07c1                	addi	a5,a5,16
    80004b32:	078a                	slli	a5,a5,0x2
    80004b34:	00022717          	auipc	a4,0x22
    80004b38:	ee470713          	addi	a4,a4,-284 # 80026a18 <log>
    80004b3c:	97ba                	add	a5,a5,a4
    80004b3e:	c78c                	sw	a1,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    log[dev].lh.n++;
  }
  release(&log[dev].lock);
    80004b40:	854a                	mv	a0,s2
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	3c4080e7          	jalr	964(ra) # 80000f06 <release>
}
    80004b4a:	70a2                	ld	ra,40(sp)
    80004b4c:	7402                	ld	s0,32(sp)
    80004b4e:	64e2                	ld	s1,24(sp)
    80004b50:	6942                	ld	s2,16(sp)
    80004b52:	69a2                	ld	s3,8(sp)
    80004b54:	6145                	addi	sp,sp,48
    80004b56:	8082                	ret
    panic("too big a transaction");
    80004b58:	00004517          	auipc	a0,0x4
    80004b5c:	03850513          	addi	a0,a0,56 # 80008b90 <userret+0xb00>
    80004b60:	ffffc097          	auipc	ra,0xffffc
    80004b64:	c24080e7          	jalr	-988(ra) # 80000784 <panic>
    panic("log_write outside of trans");
    80004b68:	00004517          	auipc	a0,0x4
    80004b6c:	04050513          	addi	a0,a0,64 # 80008ba8 <userret+0xb18>
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	c14080e7          	jalr	-1004(ra) # 80000784 <panic>
  log[dev].lh.block[i] = b->blockno;
    80004b78:	00149793          	slli	a5,s1,0x1
    80004b7c:	97a6                	add	a5,a5,s1
    80004b7e:	079a                	slli	a5,a5,0x6
    80004b80:	00022717          	auipc	a4,0x22
    80004b84:	e9870713          	addi	a4,a4,-360 # 80026a18 <log>
    80004b88:	97ba                	add	a5,a5,a4
    80004b8a:	00c9a703          	lw	a4,12(s3)
    80004b8e:	c7b8                	sw	a4,72(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004b90:	fa45                	bnez	a2,80004b40 <log_write+0xb4>
    80004b92:	a015                	j	80004bb6 <log_write+0x12a>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004b94:	4781                	li	a5,0
    80004b96:	bf41                	j	80004b26 <log_write+0x9a>
  log[dev].lh.block[i] = b->blockno;
    80004b98:	00149793          	slli	a5,s1,0x1
    80004b9c:	97a6                	add	a5,a5,s1
    80004b9e:	0792                	slli	a5,a5,0x4
    80004ba0:	97b2                	add	a5,a5,a2
    80004ba2:	07c1                	addi	a5,a5,16
    80004ba4:	078a                	slli	a5,a5,0x2
    80004ba6:	00022717          	auipc	a4,0x22
    80004baa:	e7270713          	addi	a4,a4,-398 # 80026a18 <log>
    80004bae:	97ba                	add	a5,a5,a4
    80004bb0:	00c9a703          	lw	a4,12(s3)
    80004bb4:	c798                	sw	a4,8(a5)
    bpin(b);
    80004bb6:	854e                	mv	a0,s3
    80004bb8:	fffff097          	auipc	ra,0xfffff
    80004bbc:	c48080e7          	jalr	-952(ra) # 80003800 <bpin>
    log[dev].lh.n++;
    80004bc0:	00022697          	auipc	a3,0x22
    80004bc4:	e5868693          	addi	a3,a3,-424 # 80026a18 <log>
    80004bc8:	00149793          	slli	a5,s1,0x1
    80004bcc:	00978733          	add	a4,a5,s1
    80004bd0:	071a                	slli	a4,a4,0x6
    80004bd2:	9736                	add	a4,a4,a3
    80004bd4:	437c                	lw	a5,68(a4)
    80004bd6:	2785                	addiw	a5,a5,1
    80004bd8:	c37c                	sw	a5,68(a4)
    80004bda:	b79d                	j	80004b40 <log_write+0xb4>

0000000080004bdc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004bdc:	1101                	addi	sp,sp,-32
    80004bde:	ec06                	sd	ra,24(sp)
    80004be0:	e822                	sd	s0,16(sp)
    80004be2:	e426                	sd	s1,8(sp)
    80004be4:	e04a                	sd	s2,0(sp)
    80004be6:	1000                	addi	s0,sp,32
    80004be8:	84aa                	mv	s1,a0
    80004bea:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004bec:	00004597          	auipc	a1,0x4
    80004bf0:	fdc58593          	addi	a1,a1,-36 # 80008bc8 <userret+0xb38>
    80004bf4:	0521                	addi	a0,a0,8
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	f56080e7          	jalr	-170(ra) # 80000b4c <initlock>
  lk->name = name;
    80004bfe:	0324bc23          	sd	s2,56(s1)
  lk->locked = 0;
    80004c02:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c06:	0404a023          	sw	zero,64(s1)
}
    80004c0a:	60e2                	ld	ra,24(sp)
    80004c0c:	6442                	ld	s0,16(sp)
    80004c0e:	64a2                	ld	s1,8(sp)
    80004c10:	6902                	ld	s2,0(sp)
    80004c12:	6105                	addi	sp,sp,32
    80004c14:	8082                	ret

0000000080004c16 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c16:	1101                	addi	sp,sp,-32
    80004c18:	ec06                	sd	ra,24(sp)
    80004c1a:	e822                	sd	s0,16(sp)
    80004c1c:	e426                	sd	s1,8(sp)
    80004c1e:	e04a                	sd	s2,0(sp)
    80004c20:	1000                	addi	s0,sp,32
    80004c22:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c24:	00850913          	addi	s2,a0,8
    80004c28:	854a                	mv	a0,s2
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	090080e7          	jalr	144(ra) # 80000cba <acquire>
  while (lk->locked) {
    80004c32:	409c                	lw	a5,0(s1)
    80004c34:	cb89                	beqz	a5,80004c46 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c36:	85ca                	mv	a1,s2
    80004c38:	8526                	mv	a0,s1
    80004c3a:	ffffe097          	auipc	ra,0xffffe
    80004c3e:	c0a080e7          	jalr	-1014(ra) # 80002844 <sleep>
  while (lk->locked) {
    80004c42:	409c                	lw	a5,0(s1)
    80004c44:	fbed                	bnez	a5,80004c36 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c46:	4785                	li	a5,1
    80004c48:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c4a:	ffffd097          	auipc	ra,0xffffd
    80004c4e:	3f6080e7          	jalr	1014(ra) # 80002040 <myproc>
    80004c52:	493c                	lw	a5,80(a0)
    80004c54:	c0bc                	sw	a5,64(s1)
  release(&lk->lk);
    80004c56:	854a                	mv	a0,s2
    80004c58:	ffffc097          	auipc	ra,0xffffc
    80004c5c:	2ae080e7          	jalr	686(ra) # 80000f06 <release>
}
    80004c60:	60e2                	ld	ra,24(sp)
    80004c62:	6442                	ld	s0,16(sp)
    80004c64:	64a2                	ld	s1,8(sp)
    80004c66:	6902                	ld	s2,0(sp)
    80004c68:	6105                	addi	sp,sp,32
    80004c6a:	8082                	ret

0000000080004c6c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c6c:	1101                	addi	sp,sp,-32
    80004c6e:	ec06                	sd	ra,24(sp)
    80004c70:	e822                	sd	s0,16(sp)
    80004c72:	e426                	sd	s1,8(sp)
    80004c74:	e04a                	sd	s2,0(sp)
    80004c76:	1000                	addi	s0,sp,32
    80004c78:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c7a:	00850913          	addi	s2,a0,8
    80004c7e:	854a                	mv	a0,s2
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	03a080e7          	jalr	58(ra) # 80000cba <acquire>
  lk->locked = 0;
    80004c88:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c8c:	0404a023          	sw	zero,64(s1)
  wakeup(lk);
    80004c90:	8526                	mv	a0,s1
    80004c92:	ffffe097          	auipc	ra,0xffffe
    80004c96:	d38080e7          	jalr	-712(ra) # 800029ca <wakeup>
  release(&lk->lk);
    80004c9a:	854a                	mv	a0,s2
    80004c9c:	ffffc097          	auipc	ra,0xffffc
    80004ca0:	26a080e7          	jalr	618(ra) # 80000f06 <release>
}
    80004ca4:	60e2                	ld	ra,24(sp)
    80004ca6:	6442                	ld	s0,16(sp)
    80004ca8:	64a2                	ld	s1,8(sp)
    80004caa:	6902                	ld	s2,0(sp)
    80004cac:	6105                	addi	sp,sp,32
    80004cae:	8082                	ret

0000000080004cb0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004cb0:	7179                	addi	sp,sp,-48
    80004cb2:	f406                	sd	ra,40(sp)
    80004cb4:	f022                	sd	s0,32(sp)
    80004cb6:	ec26                	sd	s1,24(sp)
    80004cb8:	e84a                	sd	s2,16(sp)
    80004cba:	e44e                	sd	s3,8(sp)
    80004cbc:	1800                	addi	s0,sp,48
    80004cbe:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004cc0:	00850913          	addi	s2,a0,8
    80004cc4:	854a                	mv	a0,s2
    80004cc6:	ffffc097          	auipc	ra,0xffffc
    80004cca:	ff4080e7          	jalr	-12(ra) # 80000cba <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cce:	409c                	lw	a5,0(s1)
    80004cd0:	ef99                	bnez	a5,80004cee <holdingsleep+0x3e>
    80004cd2:	4481                	li	s1,0
  release(&lk->lk);
    80004cd4:	854a                	mv	a0,s2
    80004cd6:	ffffc097          	auipc	ra,0xffffc
    80004cda:	230080e7          	jalr	560(ra) # 80000f06 <release>
  return r;
}
    80004cde:	8526                	mv	a0,s1
    80004ce0:	70a2                	ld	ra,40(sp)
    80004ce2:	7402                	ld	s0,32(sp)
    80004ce4:	64e2                	ld	s1,24(sp)
    80004ce6:	6942                	ld	s2,16(sp)
    80004ce8:	69a2                	ld	s3,8(sp)
    80004cea:	6145                	addi	sp,sp,48
    80004cec:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cee:	0404a983          	lw	s3,64(s1)
    80004cf2:	ffffd097          	auipc	ra,0xffffd
    80004cf6:	34e080e7          	jalr	846(ra) # 80002040 <myproc>
    80004cfa:	4924                	lw	s1,80(a0)
    80004cfc:	413484b3          	sub	s1,s1,s3
    80004d00:	0014b493          	seqz	s1,s1
    80004d04:	bfc1                	j	80004cd4 <holdingsleep+0x24>

0000000080004d06 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004d06:	1141                	addi	sp,sp,-16
    80004d08:	e406                	sd	ra,8(sp)
    80004d0a:	e022                	sd	s0,0(sp)
    80004d0c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004d0e:	00004597          	auipc	a1,0x4
    80004d12:	eca58593          	addi	a1,a1,-310 # 80008bd8 <userret+0xb48>
    80004d16:	00022517          	auipc	a0,0x22
    80004d1a:	f2250513          	addi	a0,a0,-222 # 80026c38 <ftable>
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	e2e080e7          	jalr	-466(ra) # 80000b4c <initlock>
}
    80004d26:	60a2                	ld	ra,8(sp)
    80004d28:	6402                	ld	s0,0(sp)
    80004d2a:	0141                	addi	sp,sp,16
    80004d2c:	8082                	ret

0000000080004d2e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004d2e:	1101                	addi	sp,sp,-32
    80004d30:	ec06                	sd	ra,24(sp)
    80004d32:	e822                	sd	s0,16(sp)
    80004d34:	e426                	sd	s1,8(sp)
    80004d36:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004d38:	00022517          	auipc	a0,0x22
    80004d3c:	f0050513          	addi	a0,a0,-256 # 80026c38 <ftable>
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	f7a080e7          	jalr	-134(ra) # 80000cba <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    80004d48:	00022797          	auipc	a5,0x22
    80004d4c:	ef078793          	addi	a5,a5,-272 # 80026c38 <ftable>
    80004d50:	5bdc                	lw	a5,52(a5)
    80004d52:	cb8d                	beqz	a5,80004d84 <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d54:	00022497          	auipc	s1,0x22
    80004d58:	f3c48493          	addi	s1,s1,-196 # 80026c90 <ftable+0x58>
    80004d5c:	00023717          	auipc	a4,0x23
    80004d60:	eac70713          	addi	a4,a4,-340 # 80027c08 <ftable+0xfd0>
    if(f->ref == 0){
    80004d64:	40dc                	lw	a5,4(s1)
    80004d66:	c39d                	beqz	a5,80004d8c <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d68:	02848493          	addi	s1,s1,40
    80004d6c:	fee49ce3          	bne	s1,a4,80004d64 <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004d70:	00022517          	auipc	a0,0x22
    80004d74:	ec850513          	addi	a0,a0,-312 # 80026c38 <ftable>
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	18e080e7          	jalr	398(ra) # 80000f06 <release>
  return 0;
    80004d80:	4481                	li	s1,0
    80004d82:	a839                	j	80004da0 <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004d84:	00022497          	auipc	s1,0x22
    80004d88:	ee448493          	addi	s1,s1,-284 # 80026c68 <ftable+0x30>
      f->ref = 1;
    80004d8c:	4785                	li	a5,1
    80004d8e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004d90:	00022517          	auipc	a0,0x22
    80004d94:	ea850513          	addi	a0,a0,-344 # 80026c38 <ftable>
    80004d98:	ffffc097          	auipc	ra,0xffffc
    80004d9c:	16e080e7          	jalr	366(ra) # 80000f06 <release>
}
    80004da0:	8526                	mv	a0,s1
    80004da2:	60e2                	ld	ra,24(sp)
    80004da4:	6442                	ld	s0,16(sp)
    80004da6:	64a2                	ld	s1,8(sp)
    80004da8:	6105                	addi	sp,sp,32
    80004daa:	8082                	ret

0000000080004dac <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004dac:	1101                	addi	sp,sp,-32
    80004dae:	ec06                	sd	ra,24(sp)
    80004db0:	e822                	sd	s0,16(sp)
    80004db2:	e426                	sd	s1,8(sp)
    80004db4:	1000                	addi	s0,sp,32
    80004db6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004db8:	00022517          	auipc	a0,0x22
    80004dbc:	e8050513          	addi	a0,a0,-384 # 80026c38 <ftable>
    80004dc0:	ffffc097          	auipc	ra,0xffffc
    80004dc4:	efa080e7          	jalr	-262(ra) # 80000cba <acquire>
  if(f->ref < 1)
    80004dc8:	40dc                	lw	a5,4(s1)
    80004dca:	02f05263          	blez	a5,80004dee <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004dce:	2785                	addiw	a5,a5,1
    80004dd0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004dd2:	00022517          	auipc	a0,0x22
    80004dd6:	e6650513          	addi	a0,a0,-410 # 80026c38 <ftable>
    80004dda:	ffffc097          	auipc	ra,0xffffc
    80004dde:	12c080e7          	jalr	300(ra) # 80000f06 <release>
  return f;
}
    80004de2:	8526                	mv	a0,s1
    80004de4:	60e2                	ld	ra,24(sp)
    80004de6:	6442                	ld	s0,16(sp)
    80004de8:	64a2                	ld	s1,8(sp)
    80004dea:	6105                	addi	sp,sp,32
    80004dec:	8082                	ret
    panic("filedup");
    80004dee:	00004517          	auipc	a0,0x4
    80004df2:	df250513          	addi	a0,a0,-526 # 80008be0 <userret+0xb50>
    80004df6:	ffffc097          	auipc	ra,0xffffc
    80004dfa:	98e080e7          	jalr	-1650(ra) # 80000784 <panic>

0000000080004dfe <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004dfe:	7139                	addi	sp,sp,-64
    80004e00:	fc06                	sd	ra,56(sp)
    80004e02:	f822                	sd	s0,48(sp)
    80004e04:	f426                	sd	s1,40(sp)
    80004e06:	f04a                	sd	s2,32(sp)
    80004e08:	ec4e                	sd	s3,24(sp)
    80004e0a:	e852                	sd	s4,16(sp)
    80004e0c:	e456                	sd	s5,8(sp)
    80004e0e:	0080                	addi	s0,sp,64
    80004e10:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004e12:	00022517          	auipc	a0,0x22
    80004e16:	e2650513          	addi	a0,a0,-474 # 80026c38 <ftable>
    80004e1a:	ffffc097          	auipc	ra,0xffffc
    80004e1e:	ea0080e7          	jalr	-352(ra) # 80000cba <acquire>
  if(f->ref < 1)
    80004e22:	40dc                	lw	a5,4(s1)
    80004e24:	06f05563          	blez	a5,80004e8e <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004e28:	37fd                	addiw	a5,a5,-1
    80004e2a:	0007871b          	sext.w	a4,a5
    80004e2e:	c0dc                	sw	a5,4(s1)
    80004e30:	06e04763          	bgtz	a4,80004e9e <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004e34:	0004a903          	lw	s2,0(s1)
    80004e38:	0094ca83          	lbu	s5,9(s1)
    80004e3c:	0104ba03          	ld	s4,16(s1)
    80004e40:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004e44:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004e48:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004e4c:	00022517          	auipc	a0,0x22
    80004e50:	dec50513          	addi	a0,a0,-532 # 80026c38 <ftable>
    80004e54:	ffffc097          	auipc	ra,0xffffc
    80004e58:	0b2080e7          	jalr	178(ra) # 80000f06 <release>

  if(ff.type == FD_PIPE){
    80004e5c:	4785                	li	a5,1
    80004e5e:	06f90163          	beq	s2,a5,80004ec0 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004e62:	3979                	addiw	s2,s2,-2
    80004e64:	4785                	li	a5,1
    80004e66:	0527e463          	bltu	a5,s2,80004eae <fileclose+0xb0>
    begin_op(ff.ip->dev);
    80004e6a:	0009a503          	lw	a0,0(s3)
    80004e6e:	00000097          	auipc	ra,0x0
    80004e72:	9d4080e7          	jalr	-1580(ra) # 80004842 <begin_op>
    iput(ff.ip);
    80004e76:	854e                	mv	a0,s3
    80004e78:	fffff097          	auipc	ra,0xfffff
    80004e7c:	100080e7          	jalr	256(ra) # 80003f78 <iput>
    end_op(ff.ip->dev);
    80004e80:	0009a503          	lw	a0,0(s3)
    80004e84:	00000097          	auipc	ra,0x0
    80004e88:	a6a080e7          	jalr	-1430(ra) # 800048ee <end_op>
    80004e8c:	a00d                	j	80004eae <fileclose+0xb0>
    panic("fileclose");
    80004e8e:	00004517          	auipc	a0,0x4
    80004e92:	d5a50513          	addi	a0,a0,-678 # 80008be8 <userret+0xb58>
    80004e96:	ffffc097          	auipc	ra,0xffffc
    80004e9a:	8ee080e7          	jalr	-1810(ra) # 80000784 <panic>
    release(&ftable.lock);
    80004e9e:	00022517          	auipc	a0,0x22
    80004ea2:	d9a50513          	addi	a0,a0,-614 # 80026c38 <ftable>
    80004ea6:	ffffc097          	auipc	ra,0xffffc
    80004eaa:	060080e7          	jalr	96(ra) # 80000f06 <release>
  }
}
    80004eae:	70e2                	ld	ra,56(sp)
    80004eb0:	7442                	ld	s0,48(sp)
    80004eb2:	74a2                	ld	s1,40(sp)
    80004eb4:	7902                	ld	s2,32(sp)
    80004eb6:	69e2                	ld	s3,24(sp)
    80004eb8:	6a42                	ld	s4,16(sp)
    80004eba:	6aa2                	ld	s5,8(sp)
    80004ebc:	6121                	addi	sp,sp,64
    80004ebe:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ec0:	85d6                	mv	a1,s5
    80004ec2:	8552                	mv	a0,s4
    80004ec4:	00000097          	auipc	ra,0x0
    80004ec8:	376080e7          	jalr	886(ra) # 8000523a <pipeclose>
    80004ecc:	b7cd                	j	80004eae <fileclose+0xb0>

0000000080004ece <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ece:	715d                	addi	sp,sp,-80
    80004ed0:	e486                	sd	ra,72(sp)
    80004ed2:	e0a2                	sd	s0,64(sp)
    80004ed4:	fc26                	sd	s1,56(sp)
    80004ed6:	f84a                	sd	s2,48(sp)
    80004ed8:	f44e                	sd	s3,40(sp)
    80004eda:	0880                	addi	s0,sp,80
    80004edc:	84aa                	mv	s1,a0
    80004ede:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ee0:	ffffd097          	auipc	ra,0xffffd
    80004ee4:	160080e7          	jalr	352(ra) # 80002040 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ee8:	409c                	lw	a5,0(s1)
    80004eea:	37f9                	addiw	a5,a5,-2
    80004eec:	4705                	li	a4,1
    80004eee:	04f76763          	bltu	a4,a5,80004f3c <filestat+0x6e>
    80004ef2:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ef4:	6c88                	ld	a0,24(s1)
    80004ef6:	fffff097          	auipc	ra,0xfffff
    80004efa:	f72080e7          	jalr	-142(ra) # 80003e68 <ilock>
    stati(f->ip, &st);
    80004efe:	fb840593          	addi	a1,s0,-72
    80004f02:	6c88                	ld	a0,24(s1)
    80004f04:	fffff097          	auipc	ra,0xfffff
    80004f08:	1cc080e7          	jalr	460(ra) # 800040d0 <stati>
    iunlock(f->ip);
    80004f0c:	6c88                	ld	a0,24(s1)
    80004f0e:	fffff097          	auipc	ra,0xfffff
    80004f12:	01e080e7          	jalr	30(ra) # 80003f2c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004f16:	46e1                	li	a3,24
    80004f18:	fb840613          	addi	a2,s0,-72
    80004f1c:	85ce                	mv	a1,s3
    80004f1e:	06893503          	ld	a0,104(s2)
    80004f22:	ffffd097          	auipc	ra,0xffffd
    80004f26:	cfc080e7          	jalr	-772(ra) # 80001c1e <copyout>
    80004f2a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004f2e:	60a6                	ld	ra,72(sp)
    80004f30:	6406                	ld	s0,64(sp)
    80004f32:	74e2                	ld	s1,56(sp)
    80004f34:	7942                	ld	s2,48(sp)
    80004f36:	79a2                	ld	s3,40(sp)
    80004f38:	6161                	addi	sp,sp,80
    80004f3a:	8082                	ret
  return -1;
    80004f3c:	557d                	li	a0,-1
    80004f3e:	bfc5                	j	80004f2e <filestat+0x60>

0000000080004f40 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004f40:	7179                	addi	sp,sp,-48
    80004f42:	f406                	sd	ra,40(sp)
    80004f44:	f022                	sd	s0,32(sp)
    80004f46:	ec26                	sd	s1,24(sp)
    80004f48:	e84a                	sd	s2,16(sp)
    80004f4a:	e44e                	sd	s3,8(sp)
    80004f4c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004f4e:	00854783          	lbu	a5,8(a0)
    80004f52:	c7c5                	beqz	a5,80004ffa <fileread+0xba>
    80004f54:	89b2                	mv	s3,a2
    80004f56:	892e                	mv	s2,a1
    80004f58:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004f5a:	411c                	lw	a5,0(a0)
    80004f5c:	4705                	li	a4,1
    80004f5e:	04e78963          	beq	a5,a4,80004fb0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f62:	470d                	li	a4,3
    80004f64:	04e78d63          	beq	a5,a4,80004fbe <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004f68:	4709                	li	a4,2
    80004f6a:	08e79063          	bne	a5,a4,80004fea <fileread+0xaa>
    ilock(f->ip);
    80004f6e:	6d08                	ld	a0,24(a0)
    80004f70:	fffff097          	auipc	ra,0xfffff
    80004f74:	ef8080e7          	jalr	-264(ra) # 80003e68 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f78:	874e                	mv	a4,s3
    80004f7a:	5094                	lw	a3,32(s1)
    80004f7c:	864a                	mv	a2,s2
    80004f7e:	4585                	li	a1,1
    80004f80:	6c88                	ld	a0,24(s1)
    80004f82:	fffff097          	auipc	ra,0xfffff
    80004f86:	178080e7          	jalr	376(ra) # 800040fa <readi>
    80004f8a:	892a                	mv	s2,a0
    80004f8c:	00a05563          	blez	a0,80004f96 <fileread+0x56>
      f->off += r;
    80004f90:	509c                	lw	a5,32(s1)
    80004f92:	9fa9                	addw	a5,a5,a0
    80004f94:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004f96:	6c88                	ld	a0,24(s1)
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	f94080e7          	jalr	-108(ra) # 80003f2c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004fa0:	854a                	mv	a0,s2
    80004fa2:	70a2                	ld	ra,40(sp)
    80004fa4:	7402                	ld	s0,32(sp)
    80004fa6:	64e2                	ld	s1,24(sp)
    80004fa8:	6942                	ld	s2,16(sp)
    80004faa:	69a2                	ld	s3,8(sp)
    80004fac:	6145                	addi	sp,sp,48
    80004fae:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004fb0:	6908                	ld	a0,16(a0)
    80004fb2:	00000097          	auipc	ra,0x0
    80004fb6:	412080e7          	jalr	1042(ra) # 800053c4 <piperead>
    80004fba:	892a                	mv	s2,a0
    80004fbc:	b7d5                	j	80004fa0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004fbe:	02451783          	lh	a5,36(a0)
    80004fc2:	03079693          	slli	a3,a5,0x30
    80004fc6:	92c1                	srli	a3,a3,0x30
    80004fc8:	4725                	li	a4,9
    80004fca:	02d76a63          	bltu	a4,a3,80004ffe <fileread+0xbe>
    80004fce:	0792                	slli	a5,a5,0x4
    80004fd0:	00022717          	auipc	a4,0x22
    80004fd4:	bc870713          	addi	a4,a4,-1080 # 80026b98 <devsw>
    80004fd8:	97ba                	add	a5,a5,a4
    80004fda:	639c                	ld	a5,0(a5)
    80004fdc:	c39d                	beqz	a5,80005002 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004fde:	86b2                	mv	a3,a2
    80004fe0:	862e                	mv	a2,a1
    80004fe2:	4585                	li	a1,1
    80004fe4:	9782                	jalr	a5
    80004fe6:	892a                	mv	s2,a0
    80004fe8:	bf65                	j	80004fa0 <fileread+0x60>
    panic("fileread");
    80004fea:	00004517          	auipc	a0,0x4
    80004fee:	c0e50513          	addi	a0,a0,-1010 # 80008bf8 <userret+0xb68>
    80004ff2:	ffffb097          	auipc	ra,0xffffb
    80004ff6:	792080e7          	jalr	1938(ra) # 80000784 <panic>
    return -1;
    80004ffa:	597d                	li	s2,-1
    80004ffc:	b755                	j	80004fa0 <fileread+0x60>
      return -1;
    80004ffe:	597d                	li	s2,-1
    80005000:	b745                	j	80004fa0 <fileread+0x60>
    80005002:	597d                	li	s2,-1
    80005004:	bf71                	j	80004fa0 <fileread+0x60>

0000000080005006 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005006:	00954783          	lbu	a5,9(a0)
    8000500a:	14078663          	beqz	a5,80005156 <filewrite+0x150>
{
    8000500e:	715d                	addi	sp,sp,-80
    80005010:	e486                	sd	ra,72(sp)
    80005012:	e0a2                	sd	s0,64(sp)
    80005014:	fc26                	sd	s1,56(sp)
    80005016:	f84a                	sd	s2,48(sp)
    80005018:	f44e                	sd	s3,40(sp)
    8000501a:	f052                	sd	s4,32(sp)
    8000501c:	ec56                	sd	s5,24(sp)
    8000501e:	e85a                	sd	s6,16(sp)
    80005020:	e45e                	sd	s7,8(sp)
    80005022:	e062                	sd	s8,0(sp)
    80005024:	0880                	addi	s0,sp,80
    80005026:	8ab2                	mv	s5,a2
    80005028:	8b2e                	mv	s6,a1
    8000502a:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    8000502c:	411c                	lw	a5,0(a0)
    8000502e:	4705                	li	a4,1
    80005030:	02e78263          	beq	a5,a4,80005054 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005034:	470d                	li	a4,3
    80005036:	02e78563          	beq	a5,a4,80005060 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    8000503a:	4709                	li	a4,2
    8000503c:	10e79563          	bne	a5,a4,80005146 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005040:	0ec05f63          	blez	a2,8000513e <filewrite+0x138>
    int i = 0;
    80005044:	4901                	li	s2,0
    80005046:	6b85                	lui	s7,0x1
    80005048:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000504c:	6c05                	lui	s8,0x1
    8000504e:	c00c0c1b          	addiw	s8,s8,-1024
    80005052:	a851                	j	800050e6 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80005054:	6908                	ld	a0,16(a0)
    80005056:	00000097          	auipc	ra,0x0
    8000505a:	254080e7          	jalr	596(ra) # 800052aa <pipewrite>
    8000505e:	a865                	j	80005116 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005060:	02451783          	lh	a5,36(a0)
    80005064:	03079693          	slli	a3,a5,0x30
    80005068:	92c1                	srli	a3,a3,0x30
    8000506a:	4725                	li	a4,9
    8000506c:	0ed76763          	bltu	a4,a3,8000515a <filewrite+0x154>
    80005070:	0792                	slli	a5,a5,0x4
    80005072:	00022717          	auipc	a4,0x22
    80005076:	b2670713          	addi	a4,a4,-1242 # 80026b98 <devsw>
    8000507a:	97ba                	add	a5,a5,a4
    8000507c:	679c                	ld	a5,8(a5)
    8000507e:	c3e5                	beqz	a5,8000515e <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    80005080:	86b2                	mv	a3,a2
    80005082:	862e                	mv	a2,a1
    80005084:	4585                	li	a1,1
    80005086:	9782                	jalr	a5
    80005088:	a079                	j	80005116 <filewrite+0x110>
    8000508a:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    8000508e:	6c9c                	ld	a5,24(s1)
    80005090:	4388                	lw	a0,0(a5)
    80005092:	fffff097          	auipc	ra,0xfffff
    80005096:	7b0080e7          	jalr	1968(ra) # 80004842 <begin_op>
      ilock(f->ip);
    8000509a:	6c88                	ld	a0,24(s1)
    8000509c:	fffff097          	auipc	ra,0xfffff
    800050a0:	dcc080e7          	jalr	-564(ra) # 80003e68 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800050a4:	8752                	mv	a4,s4
    800050a6:	5094                	lw	a3,32(s1)
    800050a8:	01690633          	add	a2,s2,s6
    800050ac:	4585                	li	a1,1
    800050ae:	6c88                	ld	a0,24(s1)
    800050b0:	fffff097          	auipc	ra,0xfffff
    800050b4:	13e080e7          	jalr	318(ra) # 800041ee <writei>
    800050b8:	89aa                	mv	s3,a0
    800050ba:	02a05e63          	blez	a0,800050f6 <filewrite+0xf0>
        f->off += r;
    800050be:	509c                	lw	a5,32(s1)
    800050c0:	9fa9                	addw	a5,a5,a0
    800050c2:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800050c4:	6c88                	ld	a0,24(s1)
    800050c6:	fffff097          	auipc	ra,0xfffff
    800050ca:	e66080e7          	jalr	-410(ra) # 80003f2c <iunlock>
      end_op(f->ip->dev);
    800050ce:	6c9c                	ld	a5,24(s1)
    800050d0:	4388                	lw	a0,0(a5)
    800050d2:	00000097          	auipc	ra,0x0
    800050d6:	81c080e7          	jalr	-2020(ra) # 800048ee <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800050da:	05499a63          	bne	s3,s4,8000512e <filewrite+0x128>
        panic("short filewrite");
      i += r;
    800050de:	012a093b          	addw	s2,s4,s2
    while(i < n){
    800050e2:	03595763          	ble	s5,s2,80005110 <filewrite+0x10a>
      int n1 = n - i;
    800050e6:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    800050ea:	89be                	mv	s3,a5
    800050ec:	2781                	sext.w	a5,a5
    800050ee:	f8fbdee3          	ble	a5,s7,8000508a <filewrite+0x84>
    800050f2:	89e2                	mv	s3,s8
    800050f4:	bf59                	j	8000508a <filewrite+0x84>
      iunlock(f->ip);
    800050f6:	6c88                	ld	a0,24(s1)
    800050f8:	fffff097          	auipc	ra,0xfffff
    800050fc:	e34080e7          	jalr	-460(ra) # 80003f2c <iunlock>
      end_op(f->ip->dev);
    80005100:	6c9c                	ld	a5,24(s1)
    80005102:	4388                	lw	a0,0(a5)
    80005104:	fffff097          	auipc	ra,0xfffff
    80005108:	7ea080e7          	jalr	2026(ra) # 800048ee <end_op>
      if(r < 0)
    8000510c:	fc09d7e3          	bgez	s3,800050da <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80005110:	8556                	mv	a0,s5
    80005112:	032a9863          	bne	s5,s2,80005142 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005116:	60a6                	ld	ra,72(sp)
    80005118:	6406                	ld	s0,64(sp)
    8000511a:	74e2                	ld	s1,56(sp)
    8000511c:	7942                	ld	s2,48(sp)
    8000511e:	79a2                	ld	s3,40(sp)
    80005120:	7a02                	ld	s4,32(sp)
    80005122:	6ae2                	ld	s5,24(sp)
    80005124:	6b42                	ld	s6,16(sp)
    80005126:	6ba2                	ld	s7,8(sp)
    80005128:	6c02                	ld	s8,0(sp)
    8000512a:	6161                	addi	sp,sp,80
    8000512c:	8082                	ret
        panic("short filewrite");
    8000512e:	00004517          	auipc	a0,0x4
    80005132:	ada50513          	addi	a0,a0,-1318 # 80008c08 <userret+0xb78>
    80005136:	ffffb097          	auipc	ra,0xffffb
    8000513a:	64e080e7          	jalr	1614(ra) # 80000784 <panic>
    int i = 0;
    8000513e:	4901                	li	s2,0
    80005140:	bfc1                	j	80005110 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    80005142:	557d                	li	a0,-1
    80005144:	bfc9                	j	80005116 <filewrite+0x110>
    panic("filewrite");
    80005146:	00004517          	auipc	a0,0x4
    8000514a:	ad250513          	addi	a0,a0,-1326 # 80008c18 <userret+0xb88>
    8000514e:	ffffb097          	auipc	ra,0xffffb
    80005152:	636080e7          	jalr	1590(ra) # 80000784 <panic>
    return -1;
    80005156:	557d                	li	a0,-1
}
    80005158:	8082                	ret
      return -1;
    8000515a:	557d                	li	a0,-1
    8000515c:	bf6d                	j	80005116 <filewrite+0x110>
    8000515e:	557d                	li	a0,-1
    80005160:	bf5d                	j	80005116 <filewrite+0x110>

0000000080005162 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005162:	7179                	addi	sp,sp,-48
    80005164:	f406                	sd	ra,40(sp)
    80005166:	f022                	sd	s0,32(sp)
    80005168:	ec26                	sd	s1,24(sp)
    8000516a:	e84a                	sd	s2,16(sp)
    8000516c:	e44e                	sd	s3,8(sp)
    8000516e:	e052                	sd	s4,0(sp)
    80005170:	1800                	addi	s0,sp,48
    80005172:	84aa                	mv	s1,a0
    80005174:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005176:	0005b023          	sd	zero,0(a1)
    8000517a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000517e:	00000097          	auipc	ra,0x0
    80005182:	bb0080e7          	jalr	-1104(ra) # 80004d2e <filealloc>
    80005186:	e088                	sd	a0,0(s1)
    80005188:	c549                	beqz	a0,80005212 <pipealloc+0xb0>
    8000518a:	00000097          	auipc	ra,0x0
    8000518e:	ba4080e7          	jalr	-1116(ra) # 80004d2e <filealloc>
    80005192:	00a93023          	sd	a0,0(s2)
    80005196:	c925                	beqz	a0,80005206 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005198:	ffffc097          	auipc	ra,0xffffc
    8000519c:	99a080e7          	jalr	-1638(ra) # 80000b32 <kalloc>
    800051a0:	89aa                	mv	s3,a0
    800051a2:	cd39                	beqz	a0,80005200 <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    800051a4:	4a05                	li	s4,1
    800051a6:	23452c23          	sw	s4,568(a0)
  pi->writeopen = 1;
    800051aa:	23452e23          	sw	s4,572(a0)
  pi->nwrite = 0;
    800051ae:	22052a23          	sw	zero,564(a0)
  pi->nread = 0;
    800051b2:	22052823          	sw	zero,560(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    800051b6:	03000613          	li	a2,48
    800051ba:	4581                	li	a1,0
    800051bc:	ffffc097          	auipc	ra,0xffffc
    800051c0:	f72080e7          	jalr	-142(ra) # 8000112e <memset>
  (*f0)->type = FD_PIPE;
    800051c4:	609c                	ld	a5,0(s1)
    800051c6:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    800051ca:	609c                	ld	a5,0(s1)
    800051cc:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    800051d0:	609c                	ld	a5,0(s1)
    800051d2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800051d6:	609c                	ld	a5,0(s1)
    800051d8:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    800051dc:	00093783          	ld	a5,0(s2)
    800051e0:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    800051e4:	00093783          	ld	a5,0(s2)
    800051e8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800051ec:	00093783          	ld	a5,0(s2)
    800051f0:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    800051f4:	00093783          	ld	a5,0(s2)
    800051f8:	0137b823          	sd	s3,16(a5)
  return 0;
    800051fc:	4501                	li	a0,0
    800051fe:	a025                	j	80005226 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005200:	6088                	ld	a0,0(s1)
    80005202:	e501                	bnez	a0,8000520a <pipealloc+0xa8>
    80005204:	a039                	j	80005212 <pipealloc+0xb0>
    80005206:	6088                	ld	a0,0(s1)
    80005208:	c51d                	beqz	a0,80005236 <pipealloc+0xd4>
    fileclose(*f0);
    8000520a:	00000097          	auipc	ra,0x0
    8000520e:	bf4080e7          	jalr	-1036(ra) # 80004dfe <fileclose>
  if(*f1)
    80005212:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80005216:	557d                	li	a0,-1
  if(*f1)
    80005218:	c799                	beqz	a5,80005226 <pipealloc+0xc4>
    fileclose(*f1);
    8000521a:	853e                	mv	a0,a5
    8000521c:	00000097          	auipc	ra,0x0
    80005220:	be2080e7          	jalr	-1054(ra) # 80004dfe <fileclose>
  return -1;
    80005224:	557d                	li	a0,-1
}
    80005226:	70a2                	ld	ra,40(sp)
    80005228:	7402                	ld	s0,32(sp)
    8000522a:	64e2                	ld	s1,24(sp)
    8000522c:	6942                	ld	s2,16(sp)
    8000522e:	69a2                	ld	s3,8(sp)
    80005230:	6a02                	ld	s4,0(sp)
    80005232:	6145                	addi	sp,sp,48
    80005234:	8082                	ret
  return -1;
    80005236:	557d                	li	a0,-1
    80005238:	b7fd                	j	80005226 <pipealloc+0xc4>

000000008000523a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000523a:	1101                	addi	sp,sp,-32
    8000523c:	ec06                	sd	ra,24(sp)
    8000523e:	e822                	sd	s0,16(sp)
    80005240:	e426                	sd	s1,8(sp)
    80005242:	e04a                	sd	s2,0(sp)
    80005244:	1000                	addi	s0,sp,32
    80005246:	84aa                	mv	s1,a0
    80005248:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000524a:	ffffc097          	auipc	ra,0xffffc
    8000524e:	a70080e7          	jalr	-1424(ra) # 80000cba <acquire>
  if(writable){
    80005252:	02090d63          	beqz	s2,8000528c <pipeclose+0x52>
    pi->writeopen = 0;
    80005256:	2204ae23          	sw	zero,572(s1)
    wakeup(&pi->nread);
    8000525a:	23048513          	addi	a0,s1,560
    8000525e:	ffffd097          	auipc	ra,0xffffd
    80005262:	76c080e7          	jalr	1900(ra) # 800029ca <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005266:	2384b783          	ld	a5,568(s1)
    8000526a:	eb95                	bnez	a5,8000529e <pipeclose+0x64>
    release(&pi->lock);
    8000526c:	8526                	mv	a0,s1
    8000526e:	ffffc097          	auipc	ra,0xffffc
    80005272:	c98080e7          	jalr	-872(ra) # 80000f06 <release>
    kfree((char*)pi);
    80005276:	8526                	mv	a0,s1
    80005278:	ffffc097          	auipc	ra,0xffffc
    8000527c:	8a2080e7          	jalr	-1886(ra) # 80000b1a <kfree>
  } else
    release(&pi->lock);
}
    80005280:	60e2                	ld	ra,24(sp)
    80005282:	6442                	ld	s0,16(sp)
    80005284:	64a2                	ld	s1,8(sp)
    80005286:	6902                	ld	s2,0(sp)
    80005288:	6105                	addi	sp,sp,32
    8000528a:	8082                	ret
    pi->readopen = 0;
    8000528c:	2204ac23          	sw	zero,568(s1)
    wakeup(&pi->nwrite);
    80005290:	23448513          	addi	a0,s1,564
    80005294:	ffffd097          	auipc	ra,0xffffd
    80005298:	736080e7          	jalr	1846(ra) # 800029ca <wakeup>
    8000529c:	b7e9                	j	80005266 <pipeclose+0x2c>
    release(&pi->lock);
    8000529e:	8526                	mv	a0,s1
    800052a0:	ffffc097          	auipc	ra,0xffffc
    800052a4:	c66080e7          	jalr	-922(ra) # 80000f06 <release>
}
    800052a8:	bfe1                	j	80005280 <pipeclose+0x46>

00000000800052aa <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800052aa:	7159                	addi	sp,sp,-112
    800052ac:	f486                	sd	ra,104(sp)
    800052ae:	f0a2                	sd	s0,96(sp)
    800052b0:	eca6                	sd	s1,88(sp)
    800052b2:	e8ca                	sd	s2,80(sp)
    800052b4:	e4ce                	sd	s3,72(sp)
    800052b6:	e0d2                	sd	s4,64(sp)
    800052b8:	fc56                	sd	s5,56(sp)
    800052ba:	f85a                	sd	s6,48(sp)
    800052bc:	f45e                	sd	s7,40(sp)
    800052be:	f062                	sd	s8,32(sp)
    800052c0:	ec66                	sd	s9,24(sp)
    800052c2:	1880                	addi	s0,sp,112
    800052c4:	84aa                	mv	s1,a0
    800052c6:	8bae                	mv	s7,a1
    800052c8:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    800052ca:	ffffd097          	auipc	ra,0xffffd
    800052ce:	d76080e7          	jalr	-650(ra) # 80002040 <myproc>
    800052d2:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    800052d4:	8526                	mv	a0,s1
    800052d6:	ffffc097          	auipc	ra,0xffffc
    800052da:	9e4080e7          	jalr	-1564(ra) # 80000cba <acquire>
  for(i = 0; i < n; i++){
    800052de:	0d605663          	blez	s6,800053aa <pipewrite+0x100>
    800052e2:	8926                	mv	s2,s1
    800052e4:	fffb0a9b          	addiw	s5,s6,-1
    800052e8:	1a82                	slli	s5,s5,0x20
    800052ea:	020ada93          	srli	s5,s5,0x20
    800052ee:	001b8793          	addi	a5,s7,1
    800052f2:	9abe                	add	s5,s5,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    800052f4:	23048a13          	addi	s4,s1,560
      sleep(&pi->nwrite, &pi->lock);
    800052f8:	23448993          	addi	s3,s1,564
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052fc:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800052fe:	2304a783          	lw	a5,560(s1)
    80005302:	2344a703          	lw	a4,564(s1)
    80005306:	2007879b          	addiw	a5,a5,512
    8000530a:	06f71463          	bne	a4,a5,80005372 <pipewrite+0xc8>
      if(pi->readopen == 0 || myproc()->killed){
    8000530e:	2384a783          	lw	a5,568(s1)
    80005312:	cf8d                	beqz	a5,8000534c <pipewrite+0xa2>
    80005314:	ffffd097          	auipc	ra,0xffffd
    80005318:	d2c080e7          	jalr	-724(ra) # 80002040 <myproc>
    8000531c:	453c                	lw	a5,72(a0)
    8000531e:	e79d                	bnez	a5,8000534c <pipewrite+0xa2>
      wakeup(&pi->nread);
    80005320:	8552                	mv	a0,s4
    80005322:	ffffd097          	auipc	ra,0xffffd
    80005326:	6a8080e7          	jalr	1704(ra) # 800029ca <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000532a:	85ca                	mv	a1,s2
    8000532c:	854e                	mv	a0,s3
    8000532e:	ffffd097          	auipc	ra,0xffffd
    80005332:	516080e7          	jalr	1302(ra) # 80002844 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80005336:	2304a783          	lw	a5,560(s1)
    8000533a:	2344a703          	lw	a4,564(s1)
    8000533e:	2007879b          	addiw	a5,a5,512
    80005342:	02f71863          	bne	a4,a5,80005372 <pipewrite+0xc8>
      if(pi->readopen == 0 || myproc()->killed){
    80005346:	2384a783          	lw	a5,568(s1)
    8000534a:	f7e9                	bnez	a5,80005314 <pipewrite+0x6a>
        release(&pi->lock);
    8000534c:	8526                	mv	a0,s1
    8000534e:	ffffc097          	auipc	ra,0xffffc
    80005352:	bb8080e7          	jalr	-1096(ra) # 80000f06 <release>
        return -1;
    80005356:	557d                	li	a0,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return n;
}
    80005358:	70a6                	ld	ra,104(sp)
    8000535a:	7406                	ld	s0,96(sp)
    8000535c:	64e6                	ld	s1,88(sp)
    8000535e:	6946                	ld	s2,80(sp)
    80005360:	69a6                	ld	s3,72(sp)
    80005362:	6a06                	ld	s4,64(sp)
    80005364:	7ae2                	ld	s5,56(sp)
    80005366:	7b42                	ld	s6,48(sp)
    80005368:	7ba2                	ld	s7,40(sp)
    8000536a:	7c02                	ld	s8,32(sp)
    8000536c:	6ce2                	ld	s9,24(sp)
    8000536e:	6165                	addi	sp,sp,112
    80005370:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005372:	4685                	li	a3,1
    80005374:	865e                	mv	a2,s7
    80005376:	f9f40593          	addi	a1,s0,-97
    8000537a:	068c3503          	ld	a0,104(s8) # 1068 <_entry-0x7fffef98>
    8000537e:	ffffd097          	auipc	ra,0xffffd
    80005382:	92c080e7          	jalr	-1748(ra) # 80001caa <copyin>
    80005386:	03950263          	beq	a0,s9,800053aa <pipewrite+0x100>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000538a:	2344a783          	lw	a5,564(s1)
    8000538e:	0017871b          	addiw	a4,a5,1
    80005392:	22e4aa23          	sw	a4,564(s1)
    80005396:	1ff7f793          	andi	a5,a5,511
    8000539a:	97a6                	add	a5,a5,s1
    8000539c:	f9f44703          	lbu	a4,-97(s0)
    800053a0:	02e78823          	sb	a4,48(a5)
    800053a4:	0b85                	addi	s7,s7,1
  for(i = 0; i < n; i++){
    800053a6:	f55b9ce3          	bne	s7,s5,800052fe <pipewrite+0x54>
  wakeup(&pi->nread);
    800053aa:	23048513          	addi	a0,s1,560
    800053ae:	ffffd097          	auipc	ra,0xffffd
    800053b2:	61c080e7          	jalr	1564(ra) # 800029ca <wakeup>
  release(&pi->lock);
    800053b6:	8526                	mv	a0,s1
    800053b8:	ffffc097          	auipc	ra,0xffffc
    800053bc:	b4e080e7          	jalr	-1202(ra) # 80000f06 <release>
  return n;
    800053c0:	855a                	mv	a0,s6
    800053c2:	bf59                	j	80005358 <pipewrite+0xae>

00000000800053c4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800053c4:	715d                	addi	sp,sp,-80
    800053c6:	e486                	sd	ra,72(sp)
    800053c8:	e0a2                	sd	s0,64(sp)
    800053ca:	fc26                	sd	s1,56(sp)
    800053cc:	f84a                	sd	s2,48(sp)
    800053ce:	f44e                	sd	s3,40(sp)
    800053d0:	f052                	sd	s4,32(sp)
    800053d2:	ec56                	sd	s5,24(sp)
    800053d4:	e85a                	sd	s6,16(sp)
    800053d6:	0880                	addi	s0,sp,80
    800053d8:	84aa                	mv	s1,a0
    800053da:	89ae                	mv	s3,a1
    800053dc:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    800053de:	ffffd097          	auipc	ra,0xffffd
    800053e2:	c62080e7          	jalr	-926(ra) # 80002040 <myproc>
    800053e6:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    800053e8:	8526                	mv	a0,s1
    800053ea:	ffffc097          	auipc	ra,0xffffc
    800053ee:	8d0080e7          	jalr	-1840(ra) # 80000cba <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053f2:	2304a703          	lw	a4,560(s1)
    800053f6:	2344a783          	lw	a5,564(s1)
    800053fa:	06f71b63          	bne	a4,a5,80005470 <piperead+0xac>
    800053fe:	8926                	mv	s2,s1
    80005400:	23c4a783          	lw	a5,572(s1)
    80005404:	cb85                	beqz	a5,80005434 <piperead+0x70>
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005406:	23048b13          	addi	s6,s1,560
    if(myproc()->killed){
    8000540a:	ffffd097          	auipc	ra,0xffffd
    8000540e:	c36080e7          	jalr	-970(ra) # 80002040 <myproc>
    80005412:	453c                	lw	a5,72(a0)
    80005414:	e7b9                	bnez	a5,80005462 <piperead+0x9e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005416:	85ca                	mv	a1,s2
    80005418:	855a                	mv	a0,s6
    8000541a:	ffffd097          	auipc	ra,0xffffd
    8000541e:	42a080e7          	jalr	1066(ra) # 80002844 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005422:	2304a703          	lw	a4,560(s1)
    80005426:	2344a783          	lw	a5,564(s1)
    8000542a:	04f71363          	bne	a4,a5,80005470 <piperead+0xac>
    8000542e:	23c4a783          	lw	a5,572(s1)
    80005432:	ffe1                	bnez	a5,8000540a <piperead+0x46>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80005434:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005436:	23448513          	addi	a0,s1,564
    8000543a:	ffffd097          	auipc	ra,0xffffd
    8000543e:	590080e7          	jalr	1424(ra) # 800029ca <wakeup>
  release(&pi->lock);
    80005442:	8526                	mv	a0,s1
    80005444:	ffffc097          	auipc	ra,0xffffc
    80005448:	ac2080e7          	jalr	-1342(ra) # 80000f06 <release>
  return i;
}
    8000544c:	854a                	mv	a0,s2
    8000544e:	60a6                	ld	ra,72(sp)
    80005450:	6406                	ld	s0,64(sp)
    80005452:	74e2                	ld	s1,56(sp)
    80005454:	7942                	ld	s2,48(sp)
    80005456:	79a2                	ld	s3,40(sp)
    80005458:	7a02                	ld	s4,32(sp)
    8000545a:	6ae2                	ld	s5,24(sp)
    8000545c:	6b42                	ld	s6,16(sp)
    8000545e:	6161                	addi	sp,sp,80
    80005460:	8082                	ret
      release(&pi->lock);
    80005462:	8526                	mv	a0,s1
    80005464:	ffffc097          	auipc	ra,0xffffc
    80005468:	aa2080e7          	jalr	-1374(ra) # 80000f06 <release>
      return -1;
    8000546c:	597d                	li	s2,-1
    8000546e:	bff9                	j	8000544c <piperead+0x88>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005470:	4901                	li	s2,0
    80005472:	fd4052e3          	blez	s4,80005436 <piperead+0x72>
    if(pi->nread == pi->nwrite)
    80005476:	2304a783          	lw	a5,560(s1)
    8000547a:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000547c:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000547e:	0017871b          	addiw	a4,a5,1
    80005482:	22e4a823          	sw	a4,560(s1)
    80005486:	1ff7f793          	andi	a5,a5,511
    8000548a:	97a6                	add	a5,a5,s1
    8000548c:	0307c783          	lbu	a5,48(a5)
    80005490:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005494:	4685                	li	a3,1
    80005496:	fbf40613          	addi	a2,s0,-65
    8000549a:	85ce                	mv	a1,s3
    8000549c:	068ab503          	ld	a0,104(s5)
    800054a0:	ffffc097          	auipc	ra,0xffffc
    800054a4:	77e080e7          	jalr	1918(ra) # 80001c1e <copyout>
    800054a8:	f96507e3          	beq	a0,s6,80005436 <piperead+0x72>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800054ac:	2905                	addiw	s2,s2,1
    800054ae:	f92a04e3          	beq	s4,s2,80005436 <piperead+0x72>
    if(pi->nread == pi->nwrite)
    800054b2:	2304a783          	lw	a5,560(s1)
    800054b6:	0985                	addi	s3,s3,1
    800054b8:	2344a703          	lw	a4,564(s1)
    800054bc:	fcf711e3          	bne	a4,a5,8000547e <piperead+0xba>
    800054c0:	bf9d                	j	80005436 <piperead+0x72>

00000000800054c2 <exec>:



int
exec(char *path, char **argv)
{
    800054c2:	de010113          	addi	sp,sp,-544
    800054c6:	20113c23          	sd	ra,536(sp)
    800054ca:	20813823          	sd	s0,528(sp)
    800054ce:	20913423          	sd	s1,520(sp)
    800054d2:	21213023          	sd	s2,512(sp)
    800054d6:	ffce                	sd	s3,504(sp)
    800054d8:	fbd2                	sd	s4,496(sp)
    800054da:	f7d6                	sd	s5,488(sp)
    800054dc:	f3da                	sd	s6,480(sp)
    800054de:	efde                	sd	s7,472(sp)
    800054e0:	ebe2                	sd	s8,464(sp)
    800054e2:	e7e6                	sd	s9,456(sp)
    800054e4:	e3ea                	sd	s10,448(sp)
    800054e6:	ff6e                	sd	s11,440(sp)
    800054e8:	1400                	addi	s0,sp,544
    800054ea:	892a                	mv	s2,a0
    800054ec:	dea43823          	sd	a0,-528(s0)
    800054f0:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800054f4:	ffffd097          	auipc	ra,0xffffd
    800054f8:	b4c080e7          	jalr	-1204(ra) # 80002040 <myproc>
    800054fc:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    800054fe:	4501                	li	a0,0
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	342080e7          	jalr	834(ra) # 80004842 <begin_op>

  if((ip = namei(path)) == 0){
    80005508:	854a                	mv	a0,s2
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	0f2080e7          	jalr	242(ra) # 800045fc <namei>
    80005512:	cd25                	beqz	a0,8000558a <exec+0xc8>
    80005514:	892a                	mv	s2,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005516:	fffff097          	auipc	ra,0xfffff
    8000551a:	952080e7          	jalr	-1710(ra) # 80003e68 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000551e:	04000713          	li	a4,64
    80005522:	4681                	li	a3,0
    80005524:	e4840613          	addi	a2,s0,-440
    80005528:	4581                	li	a1,0
    8000552a:	854a                	mv	a0,s2
    8000552c:	fffff097          	auipc	ra,0xfffff
    80005530:	bce080e7          	jalr	-1074(ra) # 800040fa <readi>
    80005534:	04000793          	li	a5,64
    80005538:	00f51a63          	bne	a0,a5,8000554c <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000553c:	e4842703          	lw	a4,-440(s0)
    80005540:	464c47b7          	lui	a5,0x464c4
    80005544:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005548:	04f70863          	beq	a4,a5,80005598 <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000554c:	854a                	mv	a0,s2
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	b5a080e7          	jalr	-1190(ra) # 800040a8 <iunlockput>
    end_op(ROOTDEV);
    80005556:	4501                	li	a0,0
    80005558:	fffff097          	auipc	ra,0xfffff
    8000555c:	396080e7          	jalr	918(ra) # 800048ee <end_op>
  }
  return -1;
    80005560:	557d                	li	a0,-1
}
    80005562:	21813083          	ld	ra,536(sp)
    80005566:	21013403          	ld	s0,528(sp)
    8000556a:	20813483          	ld	s1,520(sp)
    8000556e:	20013903          	ld	s2,512(sp)
    80005572:	79fe                	ld	s3,504(sp)
    80005574:	7a5e                	ld	s4,496(sp)
    80005576:	7abe                	ld	s5,488(sp)
    80005578:	7b1e                	ld	s6,480(sp)
    8000557a:	6bfe                	ld	s7,472(sp)
    8000557c:	6c5e                	ld	s8,464(sp)
    8000557e:	6cbe                	ld	s9,456(sp)
    80005580:	6d1e                	ld	s10,448(sp)
    80005582:	7dfa                	ld	s11,440(sp)
    80005584:	22010113          	addi	sp,sp,544
    80005588:	8082                	ret
    end_op(ROOTDEV);
    8000558a:	4501                	li	a0,0
    8000558c:	fffff097          	auipc	ra,0xfffff
    80005590:	362080e7          	jalr	866(ra) # 800048ee <end_op>
    return -1;
    80005594:	557d                	li	a0,-1
    80005596:	b7f1                	j	80005562 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80005598:	8526                	mv	a0,s1
    8000559a:	ffffd097          	auipc	ra,0xffffd
    8000559e:	b6c080e7          	jalr	-1172(ra) # 80002106 <proc_pagetable>
    800055a2:	e0a43423          	sd	a0,-504(s0)
    800055a6:	d15d                	beqz	a0,8000554c <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055a8:	e6842983          	lw	s3,-408(s0)
    800055ac:	e8045783          	lhu	a5,-384(s0)
    800055b0:	cbed                	beqz	a5,800056a2 <exec+0x1e0>
  sz = 0;
    800055b2:	e0043023          	sd	zero,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055b6:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800055b8:	6c05                	lui	s8,0x1
    800055ba:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    800055be:	def43423          	sd	a5,-536(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    800055c2:	6d05                	lui	s10,0x1
    800055c4:	a0a5                	j	8000562c <exec+0x16a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800055c6:	00003517          	auipc	a0,0x3
    800055ca:	66250513          	addi	a0,a0,1634 # 80008c28 <userret+0xb98>
    800055ce:	ffffb097          	auipc	ra,0xffffb
    800055d2:	1b6080e7          	jalr	438(ra) # 80000784 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800055d6:	8756                	mv	a4,s5
    800055d8:	009d86bb          	addw	a3,s11,s1
    800055dc:	4581                	li	a1,0
    800055de:	854a                	mv	a0,s2
    800055e0:	fffff097          	auipc	ra,0xfffff
    800055e4:	b1a080e7          	jalr	-1254(ra) # 800040fa <readi>
    800055e8:	2501                	sext.w	a0,a0
    800055ea:	10aa9563          	bne	s5,a0,800056f4 <exec+0x232>
  for(i = 0; i < sz; i += PGSIZE){
    800055ee:	009d04bb          	addw	s1,s10,s1
    800055f2:	77fd                	lui	a5,0xfffff
    800055f4:	01478a3b          	addw	s4,a5,s4
    800055f8:	0374f363          	bleu	s7,s1,8000561e <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    800055fc:	02049593          	slli	a1,s1,0x20
    80005600:	9181                	srli	a1,a1,0x20
    80005602:	95e6                	add	a1,a1,s9
    80005604:	e0843503          	ld	a0,-504(s0)
    80005608:	ffffc097          	auipc	ra,0xffffc
    8000560c:	032080e7          	jalr	50(ra) # 8000163a <walkaddr>
    80005610:	862a                	mv	a2,a0
    if(pa == 0)
    80005612:	d955                	beqz	a0,800055c6 <exec+0x104>
      n = PGSIZE;
    80005614:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80005616:	fd8a70e3          	bleu	s8,s4,800055d6 <exec+0x114>
      n = sz - i;
    8000561a:	8ad2                	mv	s5,s4
    8000561c:	bf6d                	j	800055d6 <exec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000561e:	2b05                	addiw	s6,s6,1
    80005620:	0389899b          	addiw	s3,s3,56
    80005624:	e8045783          	lhu	a5,-384(s0)
    80005628:	06fb5f63          	ble	a5,s6,800056a6 <exec+0x1e4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000562c:	2981                	sext.w	s3,s3
    8000562e:	03800713          	li	a4,56
    80005632:	86ce                	mv	a3,s3
    80005634:	e1040613          	addi	a2,s0,-496
    80005638:	4581                	li	a1,0
    8000563a:	854a                	mv	a0,s2
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	abe080e7          	jalr	-1346(ra) # 800040fa <readi>
    80005644:	03800793          	li	a5,56
    80005648:	0af51663          	bne	a0,a5,800056f4 <exec+0x232>
    if(ph.type != ELF_PROG_LOAD)
    8000564c:	e1042783          	lw	a5,-496(s0)
    80005650:	4705                	li	a4,1
    80005652:	fce796e3          	bne	a5,a4,8000561e <exec+0x15c>
    if(ph.memsz < ph.filesz)
    80005656:	e3843603          	ld	a2,-456(s0)
    8000565a:	e3043783          	ld	a5,-464(s0)
    8000565e:	08f66b63          	bltu	a2,a5,800056f4 <exec+0x232>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005662:	e2043783          	ld	a5,-480(s0)
    80005666:	963e                	add	a2,a2,a5
    80005668:	08f66663          	bltu	a2,a5,800056f4 <exec+0x232>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000566c:	e0043583          	ld	a1,-512(s0)
    80005670:	e0843503          	ld	a0,-504(s0)
    80005674:	ffffc097          	auipc	ra,0xffffc
    80005678:	3d0080e7          	jalr	976(ra) # 80001a44 <uvmalloc>
    8000567c:	e0a43023          	sd	a0,-512(s0)
    80005680:	c935                	beqz	a0,800056f4 <exec+0x232>
    if(ph.vaddr % PGSIZE != 0)
    80005682:	e2043c83          	ld	s9,-480(s0)
    80005686:	de843783          	ld	a5,-536(s0)
    8000568a:	00fcf7b3          	and	a5,s9,a5
    8000568e:	e3bd                	bnez	a5,800056f4 <exec+0x232>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005690:	e1842d83          	lw	s11,-488(s0)
    80005694:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005698:	f80b83e3          	beqz	s7,8000561e <exec+0x15c>
    8000569c:	8a5e                	mv	s4,s7
    8000569e:	4481                	li	s1,0
    800056a0:	bfb1                	j	800055fc <exec+0x13a>
  sz = 0;
    800056a2:	e0043023          	sd	zero,-512(s0)
  iunlockput(ip);
    800056a6:	854a                	mv	a0,s2
    800056a8:	fffff097          	auipc	ra,0xfffff
    800056ac:	a00080e7          	jalr	-1536(ra) # 800040a8 <iunlockput>
  end_op(ROOTDEV);
    800056b0:	4501                	li	a0,0
    800056b2:	fffff097          	auipc	ra,0xfffff
    800056b6:	23c080e7          	jalr	572(ra) # 800048ee <end_op>
  p = myproc();
    800056ba:	ffffd097          	auipc	ra,0xffffd
    800056be:	986080e7          	jalr	-1658(ra) # 80002040 <myproc>
    800056c2:	8caa                	mv	s9,a0
  uint64 oldsz = p->sz;
    800056c4:	06053d83          	ld	s11,96(a0)
  sz = PGROUNDUP(sz);
    800056c8:	6585                	lui	a1,0x1
    800056ca:	15fd                	addi	a1,a1,-1
    800056cc:	e0043783          	ld	a5,-512(s0)
    800056d0:	00b78d33          	add	s10,a5,a1
    800056d4:	75fd                	lui	a1,0xfffff
    800056d6:	00bd75b3          	and	a1,s10,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800056da:	6609                	lui	a2,0x2
    800056dc:	962e                	add	a2,a2,a1
    800056de:	e0843483          	ld	s1,-504(s0)
    800056e2:	8526                	mv	a0,s1
    800056e4:	ffffc097          	auipc	ra,0xffffc
    800056e8:	360080e7          	jalr	864(ra) # 80001a44 <uvmalloc>
    800056ec:	e0a43023          	sd	a0,-512(s0)
  ip = 0;
    800056f0:	4901                	li	s2,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800056f2:	ed09                	bnez	a0,8000570c <exec+0x24a>
    proc_freepagetable(pagetable, sz);
    800056f4:	e0043583          	ld	a1,-512(s0)
    800056f8:	e0843503          	ld	a0,-504(s0)
    800056fc:	ffffd097          	auipc	ra,0xffffd
    80005700:	b0e080e7          	jalr	-1266(ra) # 8000220a <proc_freepagetable>
  if(ip){
    80005704:	e40914e3          	bnez	s2,8000554c <exec+0x8a>
  return -1;
    80005708:	557d                	li	a0,-1
    8000570a:	bda1                	j	80005562 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000570c:	75f9                	lui	a1,0xffffe
    8000570e:	892a                	mv	s2,a0
    80005710:	95aa                	add	a1,a1,a0
    80005712:	8526                	mv	a0,s1
    80005714:	ffffc097          	auipc	ra,0xffffc
    80005718:	4d8080e7          	jalr	1240(ra) # 80001bec <uvmclear>
  stackbase = sp - PGSIZE;
    8000571c:	7b7d                	lui	s6,0xfffff
    8000571e:	9b4a                	add	s6,s6,s2
  for(argc = 0; argv[argc]; argc++) {
    80005720:	df843983          	ld	s3,-520(s0)
    80005724:	0009b503          	ld	a0,0(s3)
    80005728:	c125                	beqz	a0,80005788 <exec+0x2c6>
    8000572a:	e8840a13          	addi	s4,s0,-376
    8000572e:	f8840b93          	addi	s7,s0,-120
    80005732:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005734:	ffffc097          	auipc	ra,0xffffc
    80005738:	ba4080e7          	jalr	-1116(ra) # 800012d8 <strlen>
    8000573c:	2505                	addiw	a0,a0,1
    8000573e:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005742:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005746:	11696963          	bltu	s2,s6,80005858 <exec+0x396>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000574a:	0009ba83          	ld	s5,0(s3)
    8000574e:	8556                	mv	a0,s5
    80005750:	ffffc097          	auipc	ra,0xffffc
    80005754:	b88080e7          	jalr	-1144(ra) # 800012d8 <strlen>
    80005758:	0015069b          	addiw	a3,a0,1
    8000575c:	8656                	mv	a2,s5
    8000575e:	85ca                	mv	a1,s2
    80005760:	e0843503          	ld	a0,-504(s0)
    80005764:	ffffc097          	auipc	ra,0xffffc
    80005768:	4ba080e7          	jalr	1210(ra) # 80001c1e <copyout>
    8000576c:	0e054863          	bltz	a0,8000585c <exec+0x39a>
    ustack[argc] = sp;
    80005770:	012a3023          	sd	s2,0(s4)
  for(argc = 0; argv[argc]; argc++) {
    80005774:	0485                	addi	s1,s1,1
    80005776:	09a1                	addi	s3,s3,8
    80005778:	0009b503          	ld	a0,0(s3)
    8000577c:	c909                	beqz	a0,8000578e <exec+0x2cc>
    if(argc >= MAXARG)
    8000577e:	0a21                	addi	s4,s4,8
    80005780:	fb7a1ae3          	bne	s4,s7,80005734 <exec+0x272>
  ip = 0;
    80005784:	4901                	li	s2,0
    80005786:	b7bd                	j	800056f4 <exec+0x232>
  sp = sz;
    80005788:	e0043903          	ld	s2,-512(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000578c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000578e:	00349793          	slli	a5,s1,0x3
    80005792:	f9040713          	addi	a4,s0,-112
    80005796:	97ba                	add	a5,a5,a4
    80005798:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd0e4c>
  sp -= (argc+1) * sizeof(uint64);
    8000579c:	00148693          	addi	a3,s1,1
    800057a0:	068e                	slli	a3,a3,0x3
    800057a2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800057a6:	ff097993          	andi	s3,s2,-16
  ip = 0;
    800057aa:	4901                	li	s2,0
  if(sp < stackbase)
    800057ac:	f569e4e3          	bltu	s3,s6,800056f4 <exec+0x232>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800057b0:	e8840613          	addi	a2,s0,-376
    800057b4:	85ce                	mv	a1,s3
    800057b6:	e0843503          	ld	a0,-504(s0)
    800057ba:	ffffc097          	auipc	ra,0xffffc
    800057be:	464080e7          	jalr	1124(ra) # 80001c1e <copyout>
    800057c2:	08054f63          	bltz	a0,80005860 <exec+0x39e>
  p->tf->a1 = sp;
    800057c6:	070cb783          	ld	a5,112(s9) # 2070 <_entry-0x7fffdf90>
    800057ca:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    800057ce:	df043783          	ld	a5,-528(s0)
    800057d2:	0007c703          	lbu	a4,0(a5)
    800057d6:	cf11                	beqz	a4,800057f2 <exec+0x330>
    800057d8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800057da:	02f00693          	li	a3,47
    800057de:	a029                	j	800057e8 <exec+0x326>
    800057e0:	0785                	addi	a5,a5,1
  for(last=s=path; *s; s++)
    800057e2:	fff7c703          	lbu	a4,-1(a5)
    800057e6:	c711                	beqz	a4,800057f2 <exec+0x330>
    if(*s == '/')
    800057e8:	fed71ce3          	bne	a4,a3,800057e0 <exec+0x31e>
      last = s+1;
    800057ec:	def43823          	sd	a5,-528(s0)
    800057f0:	bfc5                	j	800057e0 <exec+0x31e>
  safestrcpy(p->name, last, sizeof(p->name));
    800057f2:	4641                	li	a2,16
    800057f4:	df043583          	ld	a1,-528(s0)
    800057f8:	170c8513          	addi	a0,s9,368
    800057fc:	ffffc097          	auipc	ra,0xffffc
    80005800:	aaa080e7          	jalr	-1366(ra) # 800012a6 <safestrcpy>
  if(p->cmd) bd_free(p->cmd);
    80005804:	180cb503          	ld	a0,384(s9)
    80005808:	c509                	beqz	a0,80005812 <exec+0x350>
    8000580a:	00002097          	auipc	ra,0x2
    8000580e:	9c2080e7          	jalr	-1598(ra) # 800071cc <bd_free>
  p->cmd = strjoin(argv);
    80005812:	df843503          	ld	a0,-520(s0)
    80005816:	ffffc097          	auipc	ra,0xffffc
    8000581a:	aec080e7          	jalr	-1300(ra) # 80001302 <strjoin>
    8000581e:	18acb023          	sd	a0,384(s9)
  oldpagetable = p->pagetable;
    80005822:	068cb503          	ld	a0,104(s9)
  p->pagetable = pagetable;
    80005826:	e0843783          	ld	a5,-504(s0)
    8000582a:	06fcb423          	sd	a5,104(s9)
  p->sz = sz;
    8000582e:	e0043783          	ld	a5,-512(s0)
    80005832:	06fcb023          	sd	a5,96(s9)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005836:	070cb783          	ld	a5,112(s9)
    8000583a:	e6043703          	ld	a4,-416(s0)
    8000583e:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    80005840:	070cb783          	ld	a5,112(s9)
    80005844:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005848:	85ee                	mv	a1,s11
    8000584a:	ffffd097          	auipc	ra,0xffffd
    8000584e:	9c0080e7          	jalr	-1600(ra) # 8000220a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005852:	0004851b          	sext.w	a0,s1
    80005856:	b331                	j	80005562 <exec+0xa0>
  ip = 0;
    80005858:	4901                	li	s2,0
    8000585a:	bd69                	j	800056f4 <exec+0x232>
    8000585c:	4901                	li	s2,0
    8000585e:	bd59                	j	800056f4 <exec+0x232>
    80005860:	4901                	li	s2,0
    80005862:	bd49                	j	800056f4 <exec+0x232>

0000000080005864 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005864:	7179                	addi	sp,sp,-48
    80005866:	f406                	sd	ra,40(sp)
    80005868:	f022                	sd	s0,32(sp)
    8000586a:	ec26                	sd	s1,24(sp)
    8000586c:	e84a                	sd	s2,16(sp)
    8000586e:	1800                	addi	s0,sp,48
    80005870:	892e                	mv	s2,a1
    80005872:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005874:	fdc40593          	addi	a1,s0,-36
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	a1e080e7          	jalr	-1506(ra) # 80003296 <argint>
    80005880:	04054063          	bltz	a0,800058c0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005884:	fdc42703          	lw	a4,-36(s0)
    80005888:	47bd                	li	a5,15
    8000588a:	02e7ed63          	bltu	a5,a4,800058c4 <argfd+0x60>
    8000588e:	ffffc097          	auipc	ra,0xffffc
    80005892:	7b2080e7          	jalr	1970(ra) # 80002040 <myproc>
    80005896:	fdc42703          	lw	a4,-36(s0)
    8000589a:	01c70793          	addi	a5,a4,28
    8000589e:	078e                	slli	a5,a5,0x3
    800058a0:	953e                	add	a0,a0,a5
    800058a2:	651c                	ld	a5,8(a0)
    800058a4:	c395                	beqz	a5,800058c8 <argfd+0x64>
    return -1;
  if(pfd)
    800058a6:	00090463          	beqz	s2,800058ae <argfd+0x4a>
    *pfd = fd;
    800058aa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800058ae:	4501                	li	a0,0
  if(pf)
    800058b0:	c091                	beqz	s1,800058b4 <argfd+0x50>
    *pf = f;
    800058b2:	e09c                	sd	a5,0(s1)
}
    800058b4:	70a2                	ld	ra,40(sp)
    800058b6:	7402                	ld	s0,32(sp)
    800058b8:	64e2                	ld	s1,24(sp)
    800058ba:	6942                	ld	s2,16(sp)
    800058bc:	6145                	addi	sp,sp,48
    800058be:	8082                	ret
    return -1;
    800058c0:	557d                	li	a0,-1
    800058c2:	bfcd                	j	800058b4 <argfd+0x50>
    return -1;
    800058c4:	557d                	li	a0,-1
    800058c6:	b7fd                	j	800058b4 <argfd+0x50>
    800058c8:	557d                	li	a0,-1
    800058ca:	b7ed                	j	800058b4 <argfd+0x50>

00000000800058cc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800058cc:	1101                	addi	sp,sp,-32
    800058ce:	ec06                	sd	ra,24(sp)
    800058d0:	e822                	sd	s0,16(sp)
    800058d2:	e426                	sd	s1,8(sp)
    800058d4:	1000                	addi	s0,sp,32
    800058d6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800058d8:	ffffc097          	auipc	ra,0xffffc
    800058dc:	768080e7          	jalr	1896(ra) # 80002040 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    800058e0:	757c                	ld	a5,232(a0)
    800058e2:	c395                	beqz	a5,80005906 <fdalloc+0x3a>
    800058e4:	0f050713          	addi	a4,a0,240
  for(fd = 0; fd < NOFILE; fd++){
    800058e8:	4785                	li	a5,1
    800058ea:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    800058ec:	6314                	ld	a3,0(a4)
    800058ee:	ce89                	beqz	a3,80005908 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    800058f0:	2785                	addiw	a5,a5,1
    800058f2:	0721                	addi	a4,a4,8
    800058f4:	fec79ce3          	bne	a5,a2,800058ec <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800058f8:	57fd                	li	a5,-1
}
    800058fa:	853e                	mv	a0,a5
    800058fc:	60e2                	ld	ra,24(sp)
    800058fe:	6442                	ld	s0,16(sp)
    80005900:	64a2                	ld	s1,8(sp)
    80005902:	6105                	addi	sp,sp,32
    80005904:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005906:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005908:	01c78713          	addi	a4,a5,28
    8000590c:	070e                	slli	a4,a4,0x3
    8000590e:	953a                	add	a0,a0,a4
    80005910:	e504                	sd	s1,8(a0)
      return fd;
    80005912:	b7e5                	j	800058fa <fdalloc+0x2e>

0000000080005914 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005914:	715d                	addi	sp,sp,-80
    80005916:	e486                	sd	ra,72(sp)
    80005918:	e0a2                	sd	s0,64(sp)
    8000591a:	fc26                	sd	s1,56(sp)
    8000591c:	f84a                	sd	s2,48(sp)
    8000591e:	f44e                	sd	s3,40(sp)
    80005920:	f052                	sd	s4,32(sp)
    80005922:	ec56                	sd	s5,24(sp)
    80005924:	0880                	addi	s0,sp,80
    80005926:	89ae                	mv	s3,a1
    80005928:	8ab2                	mv	s5,a2
    8000592a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000592c:	fb040593          	addi	a1,s0,-80
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	cea080e7          	jalr	-790(ra) # 8000461a <nameiparent>
    80005938:	892a                	mv	s2,a0
    8000593a:	12050f63          	beqz	a0,80005a78 <create+0x164>
    return 0;

  ilock(dp);
    8000593e:	ffffe097          	auipc	ra,0xffffe
    80005942:	52a080e7          	jalr	1322(ra) # 80003e68 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005946:	4601                	li	a2,0
    80005948:	fb040593          	addi	a1,s0,-80
    8000594c:	854a                	mv	a0,s2
    8000594e:	fffff097          	auipc	ra,0xfffff
    80005952:	9d4080e7          	jalr	-1580(ra) # 80004322 <dirlookup>
    80005956:	84aa                	mv	s1,a0
    80005958:	c921                	beqz	a0,800059a8 <create+0x94>
    iunlockput(dp);
    8000595a:	854a                	mv	a0,s2
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	74c080e7          	jalr	1868(ra) # 800040a8 <iunlockput>
    ilock(ip);
    80005964:	8526                	mv	a0,s1
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	502080e7          	jalr	1282(ra) # 80003e68 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000596e:	2981                	sext.w	s3,s3
    80005970:	4789                	li	a5,2
    80005972:	02f99463          	bne	s3,a5,8000599a <create+0x86>
    80005976:	05c4d783          	lhu	a5,92(s1)
    8000597a:	37f9                	addiw	a5,a5,-2
    8000597c:	17c2                	slli	a5,a5,0x30
    8000597e:	93c1                	srli	a5,a5,0x30
    80005980:	4705                	li	a4,1
    80005982:	00f76c63          	bltu	a4,a5,8000599a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005986:	8526                	mv	a0,s1
    80005988:	60a6                	ld	ra,72(sp)
    8000598a:	6406                	ld	s0,64(sp)
    8000598c:	74e2                	ld	s1,56(sp)
    8000598e:	7942                	ld	s2,48(sp)
    80005990:	79a2                	ld	s3,40(sp)
    80005992:	7a02                	ld	s4,32(sp)
    80005994:	6ae2                	ld	s5,24(sp)
    80005996:	6161                	addi	sp,sp,80
    80005998:	8082                	ret
    iunlockput(ip);
    8000599a:	8526                	mv	a0,s1
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	70c080e7          	jalr	1804(ra) # 800040a8 <iunlockput>
    return 0;
    800059a4:	4481                	li	s1,0
    800059a6:	b7c5                	j	80005986 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800059a8:	85ce                	mv	a1,s3
    800059aa:	00092503          	lw	a0,0(s2)
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	31e080e7          	jalr	798(ra) # 80003ccc <ialloc>
    800059b6:	84aa                	mv	s1,a0
    800059b8:	c529                	beqz	a0,80005a02 <create+0xee>
  ilock(ip);
    800059ba:	ffffe097          	auipc	ra,0xffffe
    800059be:	4ae080e7          	jalr	1198(ra) # 80003e68 <ilock>
  ip->major = major;
    800059c2:	05549f23          	sh	s5,94(s1)
  ip->minor = minor;
    800059c6:	07449023          	sh	s4,96(s1)
  ip->nlink = 1;
    800059ca:	4785                	li	a5,1
    800059cc:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    800059d0:	8526                	mv	a0,s1
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	3ca080e7          	jalr	970(ra) # 80003d9c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800059da:	2981                	sext.w	s3,s3
    800059dc:	4785                	li	a5,1
    800059de:	02f98a63          	beq	s3,a5,80005a12 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800059e2:	40d0                	lw	a2,4(s1)
    800059e4:	fb040593          	addi	a1,s0,-80
    800059e8:	854a                	mv	a0,s2
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	b50080e7          	jalr	-1200(ra) # 8000453a <dirlink>
    800059f2:	06054b63          	bltz	a0,80005a68 <create+0x154>
  iunlockput(dp);
    800059f6:	854a                	mv	a0,s2
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	6b0080e7          	jalr	1712(ra) # 800040a8 <iunlockput>
  return ip;
    80005a00:	b759                	j	80005986 <create+0x72>
    panic("create: ialloc");
    80005a02:	00003517          	auipc	a0,0x3
    80005a06:	24650513          	addi	a0,a0,582 # 80008c48 <userret+0xbb8>
    80005a0a:	ffffb097          	auipc	ra,0xffffb
    80005a0e:	d7a080e7          	jalr	-646(ra) # 80000784 <panic>
    dp->nlink++;  // for ".."
    80005a12:	06295783          	lhu	a5,98(s2)
    80005a16:	2785                	addiw	a5,a5,1
    80005a18:	06f91123          	sh	a5,98(s2)
    iupdate(dp);
    80005a1c:	854a                	mv	a0,s2
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	37e080e7          	jalr	894(ra) # 80003d9c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005a26:	40d0                	lw	a2,4(s1)
    80005a28:	00003597          	auipc	a1,0x3
    80005a2c:	23058593          	addi	a1,a1,560 # 80008c58 <userret+0xbc8>
    80005a30:	8526                	mv	a0,s1
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	b08080e7          	jalr	-1272(ra) # 8000453a <dirlink>
    80005a3a:	00054f63          	bltz	a0,80005a58 <create+0x144>
    80005a3e:	00492603          	lw	a2,4(s2)
    80005a42:	00003597          	auipc	a1,0x3
    80005a46:	21e58593          	addi	a1,a1,542 # 80008c60 <userret+0xbd0>
    80005a4a:	8526                	mv	a0,s1
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	aee080e7          	jalr	-1298(ra) # 8000453a <dirlink>
    80005a54:	f80557e3          	bgez	a0,800059e2 <create+0xce>
      panic("create dots");
    80005a58:	00003517          	auipc	a0,0x3
    80005a5c:	21050513          	addi	a0,a0,528 # 80008c68 <userret+0xbd8>
    80005a60:	ffffb097          	auipc	ra,0xffffb
    80005a64:	d24080e7          	jalr	-732(ra) # 80000784 <panic>
    panic("create: dirlink");
    80005a68:	00003517          	auipc	a0,0x3
    80005a6c:	21050513          	addi	a0,a0,528 # 80008c78 <userret+0xbe8>
    80005a70:	ffffb097          	auipc	ra,0xffffb
    80005a74:	d14080e7          	jalr	-748(ra) # 80000784 <panic>
    return 0;
    80005a78:	84aa                	mv	s1,a0
    80005a7a:	b731                	j	80005986 <create+0x72>

0000000080005a7c <sys_dup>:
{
    80005a7c:	7179                	addi	sp,sp,-48
    80005a7e:	f406                	sd	ra,40(sp)
    80005a80:	f022                	sd	s0,32(sp)
    80005a82:	ec26                	sd	s1,24(sp)
    80005a84:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005a86:	fd840613          	addi	a2,s0,-40
    80005a8a:	4581                	li	a1,0
    80005a8c:	4501                	li	a0,0
    80005a8e:	00000097          	auipc	ra,0x0
    80005a92:	dd6080e7          	jalr	-554(ra) # 80005864 <argfd>
    return -1;
    80005a96:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005a98:	02054363          	bltz	a0,80005abe <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005a9c:	fd843503          	ld	a0,-40(s0)
    80005aa0:	00000097          	auipc	ra,0x0
    80005aa4:	e2c080e7          	jalr	-468(ra) # 800058cc <fdalloc>
    80005aa8:	84aa                	mv	s1,a0
    return -1;
    80005aaa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005aac:	00054963          	bltz	a0,80005abe <sys_dup+0x42>
  filedup(f);
    80005ab0:	fd843503          	ld	a0,-40(s0)
    80005ab4:	fffff097          	auipc	ra,0xfffff
    80005ab8:	2f8080e7          	jalr	760(ra) # 80004dac <filedup>
  return fd;
    80005abc:	87a6                	mv	a5,s1
}
    80005abe:	853e                	mv	a0,a5
    80005ac0:	70a2                	ld	ra,40(sp)
    80005ac2:	7402                	ld	s0,32(sp)
    80005ac4:	64e2                	ld	s1,24(sp)
    80005ac6:	6145                	addi	sp,sp,48
    80005ac8:	8082                	ret

0000000080005aca <sys_read>:
{
    80005aca:	7179                	addi	sp,sp,-48
    80005acc:	f406                	sd	ra,40(sp)
    80005ace:	f022                	sd	s0,32(sp)
    80005ad0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ad2:	fe840613          	addi	a2,s0,-24
    80005ad6:	4581                	li	a1,0
    80005ad8:	4501                	li	a0,0
    80005ada:	00000097          	auipc	ra,0x0
    80005ade:	d8a080e7          	jalr	-630(ra) # 80005864 <argfd>
    return -1;
    80005ae2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ae4:	04054163          	bltz	a0,80005b26 <sys_read+0x5c>
    80005ae8:	fe440593          	addi	a1,s0,-28
    80005aec:	4509                	li	a0,2
    80005aee:	ffffd097          	auipc	ra,0xffffd
    80005af2:	7a8080e7          	jalr	1960(ra) # 80003296 <argint>
    return -1;
    80005af6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005af8:	02054763          	bltz	a0,80005b26 <sys_read+0x5c>
    80005afc:	fd840593          	addi	a1,s0,-40
    80005b00:	4505                	li	a0,1
    80005b02:	ffffd097          	auipc	ra,0xffffd
    80005b06:	7b6080e7          	jalr	1974(ra) # 800032b8 <argaddr>
    return -1;
    80005b0a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b0c:	00054d63          	bltz	a0,80005b26 <sys_read+0x5c>
  return fileread(f, p, n);
    80005b10:	fe442603          	lw	a2,-28(s0)
    80005b14:	fd843583          	ld	a1,-40(s0)
    80005b18:	fe843503          	ld	a0,-24(s0)
    80005b1c:	fffff097          	auipc	ra,0xfffff
    80005b20:	424080e7          	jalr	1060(ra) # 80004f40 <fileread>
    80005b24:	87aa                	mv	a5,a0
}
    80005b26:	853e                	mv	a0,a5
    80005b28:	70a2                	ld	ra,40(sp)
    80005b2a:	7402                	ld	s0,32(sp)
    80005b2c:	6145                	addi	sp,sp,48
    80005b2e:	8082                	ret

0000000080005b30 <sys_write>:
{
    80005b30:	7179                	addi	sp,sp,-48
    80005b32:	f406                	sd	ra,40(sp)
    80005b34:	f022                	sd	s0,32(sp)
    80005b36:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b38:	fe840613          	addi	a2,s0,-24
    80005b3c:	4581                	li	a1,0
    80005b3e:	4501                	li	a0,0
    80005b40:	00000097          	auipc	ra,0x0
    80005b44:	d24080e7          	jalr	-732(ra) # 80005864 <argfd>
    return -1;
    80005b48:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b4a:	04054163          	bltz	a0,80005b8c <sys_write+0x5c>
    80005b4e:	fe440593          	addi	a1,s0,-28
    80005b52:	4509                	li	a0,2
    80005b54:	ffffd097          	auipc	ra,0xffffd
    80005b58:	742080e7          	jalr	1858(ra) # 80003296 <argint>
    return -1;
    80005b5c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b5e:	02054763          	bltz	a0,80005b8c <sys_write+0x5c>
    80005b62:	fd840593          	addi	a1,s0,-40
    80005b66:	4505                	li	a0,1
    80005b68:	ffffd097          	auipc	ra,0xffffd
    80005b6c:	750080e7          	jalr	1872(ra) # 800032b8 <argaddr>
    return -1;
    80005b70:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005b72:	00054d63          	bltz	a0,80005b8c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005b76:	fe442603          	lw	a2,-28(s0)
    80005b7a:	fd843583          	ld	a1,-40(s0)
    80005b7e:	fe843503          	ld	a0,-24(s0)
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	484080e7          	jalr	1156(ra) # 80005006 <filewrite>
    80005b8a:	87aa                	mv	a5,a0
}
    80005b8c:	853e                	mv	a0,a5
    80005b8e:	70a2                	ld	ra,40(sp)
    80005b90:	7402                	ld	s0,32(sp)
    80005b92:	6145                	addi	sp,sp,48
    80005b94:	8082                	ret

0000000080005b96 <sys_close>:
{
    80005b96:	1101                	addi	sp,sp,-32
    80005b98:	ec06                	sd	ra,24(sp)
    80005b9a:	e822                	sd	s0,16(sp)
    80005b9c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005b9e:	fe040613          	addi	a2,s0,-32
    80005ba2:	fec40593          	addi	a1,s0,-20
    80005ba6:	4501                	li	a0,0
    80005ba8:	00000097          	auipc	ra,0x0
    80005bac:	cbc080e7          	jalr	-836(ra) # 80005864 <argfd>
    return -1;
    80005bb0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005bb2:	02054463          	bltz	a0,80005bda <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005bb6:	ffffc097          	auipc	ra,0xffffc
    80005bba:	48a080e7          	jalr	1162(ra) # 80002040 <myproc>
    80005bbe:	fec42783          	lw	a5,-20(s0)
    80005bc2:	07f1                	addi	a5,a5,28
    80005bc4:	078e                	slli	a5,a5,0x3
    80005bc6:	953e                	add	a0,a0,a5
    80005bc8:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005bcc:	fe043503          	ld	a0,-32(s0)
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	22e080e7          	jalr	558(ra) # 80004dfe <fileclose>
  return 0;
    80005bd8:	4781                	li	a5,0
}
    80005bda:	853e                	mv	a0,a5
    80005bdc:	60e2                	ld	ra,24(sp)
    80005bde:	6442                	ld	s0,16(sp)
    80005be0:	6105                	addi	sp,sp,32
    80005be2:	8082                	ret

0000000080005be4 <sys_fstat>:
{
    80005be4:	1101                	addi	sp,sp,-32
    80005be6:	ec06                	sd	ra,24(sp)
    80005be8:	e822                	sd	s0,16(sp)
    80005bea:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005bec:	fe840613          	addi	a2,s0,-24
    80005bf0:	4581                	li	a1,0
    80005bf2:	4501                	li	a0,0
    80005bf4:	00000097          	auipc	ra,0x0
    80005bf8:	c70080e7          	jalr	-912(ra) # 80005864 <argfd>
    return -1;
    80005bfc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005bfe:	02054563          	bltz	a0,80005c28 <sys_fstat+0x44>
    80005c02:	fe040593          	addi	a1,s0,-32
    80005c06:	4505                	li	a0,1
    80005c08:	ffffd097          	auipc	ra,0xffffd
    80005c0c:	6b0080e7          	jalr	1712(ra) # 800032b8 <argaddr>
    return -1;
    80005c10:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005c12:	00054b63          	bltz	a0,80005c28 <sys_fstat+0x44>
  return filestat(f, st);
    80005c16:	fe043583          	ld	a1,-32(s0)
    80005c1a:	fe843503          	ld	a0,-24(s0)
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	2b0080e7          	jalr	688(ra) # 80004ece <filestat>
    80005c26:	87aa                	mv	a5,a0
}
    80005c28:	853e                	mv	a0,a5
    80005c2a:	60e2                	ld	ra,24(sp)
    80005c2c:	6442                	ld	s0,16(sp)
    80005c2e:	6105                	addi	sp,sp,32
    80005c30:	8082                	ret

0000000080005c32 <sys_link>:
{
    80005c32:	7169                	addi	sp,sp,-304
    80005c34:	f606                	sd	ra,296(sp)
    80005c36:	f222                	sd	s0,288(sp)
    80005c38:	ee26                	sd	s1,280(sp)
    80005c3a:	ea4a                	sd	s2,272(sp)
    80005c3c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c3e:	08000613          	li	a2,128
    80005c42:	ed040593          	addi	a1,s0,-304
    80005c46:	4501                	li	a0,0
    80005c48:	ffffd097          	auipc	ra,0xffffd
    80005c4c:	692080e7          	jalr	1682(ra) # 800032da <argstr>
    return -1;
    80005c50:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c52:	12054363          	bltz	a0,80005d78 <sys_link+0x146>
    80005c56:	08000613          	li	a2,128
    80005c5a:	f5040593          	addi	a1,s0,-176
    80005c5e:	4505                	li	a0,1
    80005c60:	ffffd097          	auipc	ra,0xffffd
    80005c64:	67a080e7          	jalr	1658(ra) # 800032da <argstr>
    return -1;
    80005c68:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c6a:	10054763          	bltz	a0,80005d78 <sys_link+0x146>
  begin_op(ROOTDEV);
    80005c6e:	4501                	li	a0,0
    80005c70:	fffff097          	auipc	ra,0xfffff
    80005c74:	bd2080e7          	jalr	-1070(ra) # 80004842 <begin_op>
  if((ip = namei(old)) == 0){
    80005c78:	ed040513          	addi	a0,s0,-304
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	980080e7          	jalr	-1664(ra) # 800045fc <namei>
    80005c84:	84aa                	mv	s1,a0
    80005c86:	c559                	beqz	a0,80005d14 <sys_link+0xe2>
  ilock(ip);
    80005c88:	ffffe097          	auipc	ra,0xffffe
    80005c8c:	1e0080e7          	jalr	480(ra) # 80003e68 <ilock>
  if(ip->type == T_DIR){
    80005c90:	05c49703          	lh	a4,92(s1)
    80005c94:	4785                	li	a5,1
    80005c96:	08f70663          	beq	a4,a5,80005d22 <sys_link+0xf0>
  ip->nlink++;
    80005c9a:	0624d783          	lhu	a5,98(s1)
    80005c9e:	2785                	addiw	a5,a5,1
    80005ca0:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005ca4:	8526                	mv	a0,s1
    80005ca6:	ffffe097          	auipc	ra,0xffffe
    80005caa:	0f6080e7          	jalr	246(ra) # 80003d9c <iupdate>
  iunlock(ip);
    80005cae:	8526                	mv	a0,s1
    80005cb0:	ffffe097          	auipc	ra,0xffffe
    80005cb4:	27c080e7          	jalr	636(ra) # 80003f2c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005cb8:	fd040593          	addi	a1,s0,-48
    80005cbc:	f5040513          	addi	a0,s0,-176
    80005cc0:	fffff097          	auipc	ra,0xfffff
    80005cc4:	95a080e7          	jalr	-1702(ra) # 8000461a <nameiparent>
    80005cc8:	892a                	mv	s2,a0
    80005cca:	cd2d                	beqz	a0,80005d44 <sys_link+0x112>
  ilock(dp);
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	19c080e7          	jalr	412(ra) # 80003e68 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005cd4:	00092703          	lw	a4,0(s2)
    80005cd8:	409c                	lw	a5,0(s1)
    80005cda:	06f71063          	bne	a4,a5,80005d3a <sys_link+0x108>
    80005cde:	40d0                	lw	a2,4(s1)
    80005ce0:	fd040593          	addi	a1,s0,-48
    80005ce4:	854a                	mv	a0,s2
    80005ce6:	fffff097          	auipc	ra,0xfffff
    80005cea:	854080e7          	jalr	-1964(ra) # 8000453a <dirlink>
    80005cee:	04054663          	bltz	a0,80005d3a <sys_link+0x108>
  iunlockput(dp);
    80005cf2:	854a                	mv	a0,s2
    80005cf4:	ffffe097          	auipc	ra,0xffffe
    80005cf8:	3b4080e7          	jalr	948(ra) # 800040a8 <iunlockput>
  iput(ip);
    80005cfc:	8526                	mv	a0,s1
    80005cfe:	ffffe097          	auipc	ra,0xffffe
    80005d02:	27a080e7          	jalr	634(ra) # 80003f78 <iput>
  end_op(ROOTDEV);
    80005d06:	4501                	li	a0,0
    80005d08:	fffff097          	auipc	ra,0xfffff
    80005d0c:	be6080e7          	jalr	-1050(ra) # 800048ee <end_op>
  return 0;
    80005d10:	4781                	li	a5,0
    80005d12:	a09d                	j	80005d78 <sys_link+0x146>
    end_op(ROOTDEV);
    80005d14:	4501                	li	a0,0
    80005d16:	fffff097          	auipc	ra,0xfffff
    80005d1a:	bd8080e7          	jalr	-1064(ra) # 800048ee <end_op>
    return -1;
    80005d1e:	57fd                	li	a5,-1
    80005d20:	a8a1                	j	80005d78 <sys_link+0x146>
    iunlockput(ip);
    80005d22:	8526                	mv	a0,s1
    80005d24:	ffffe097          	auipc	ra,0xffffe
    80005d28:	384080e7          	jalr	900(ra) # 800040a8 <iunlockput>
    end_op(ROOTDEV);
    80005d2c:	4501                	li	a0,0
    80005d2e:	fffff097          	auipc	ra,0xfffff
    80005d32:	bc0080e7          	jalr	-1088(ra) # 800048ee <end_op>
    return -1;
    80005d36:	57fd                	li	a5,-1
    80005d38:	a081                	j	80005d78 <sys_link+0x146>
    iunlockput(dp);
    80005d3a:	854a                	mv	a0,s2
    80005d3c:	ffffe097          	auipc	ra,0xffffe
    80005d40:	36c080e7          	jalr	876(ra) # 800040a8 <iunlockput>
  ilock(ip);
    80005d44:	8526                	mv	a0,s1
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	122080e7          	jalr	290(ra) # 80003e68 <ilock>
  ip->nlink--;
    80005d4e:	0624d783          	lhu	a5,98(s1)
    80005d52:	37fd                	addiw	a5,a5,-1
    80005d54:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005d58:	8526                	mv	a0,s1
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	042080e7          	jalr	66(ra) # 80003d9c <iupdate>
  iunlockput(ip);
    80005d62:	8526                	mv	a0,s1
    80005d64:	ffffe097          	auipc	ra,0xffffe
    80005d68:	344080e7          	jalr	836(ra) # 800040a8 <iunlockput>
  end_op(ROOTDEV);
    80005d6c:	4501                	li	a0,0
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	b80080e7          	jalr	-1152(ra) # 800048ee <end_op>
  return -1;
    80005d76:	57fd                	li	a5,-1
}
    80005d78:	853e                	mv	a0,a5
    80005d7a:	70b2                	ld	ra,296(sp)
    80005d7c:	7412                	ld	s0,288(sp)
    80005d7e:	64f2                	ld	s1,280(sp)
    80005d80:	6952                	ld	s2,272(sp)
    80005d82:	6155                	addi	sp,sp,304
    80005d84:	8082                	ret

0000000080005d86 <sys_unlink>:
{
    80005d86:	7151                	addi	sp,sp,-240
    80005d88:	f586                	sd	ra,232(sp)
    80005d8a:	f1a2                	sd	s0,224(sp)
    80005d8c:	eda6                	sd	s1,216(sp)
    80005d8e:	e9ca                	sd	s2,208(sp)
    80005d90:	e5ce                	sd	s3,200(sp)
    80005d92:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005d94:	08000613          	li	a2,128
    80005d98:	f3040593          	addi	a1,s0,-208
    80005d9c:	4501                	li	a0,0
    80005d9e:	ffffd097          	auipc	ra,0xffffd
    80005da2:	53c080e7          	jalr	1340(ra) # 800032da <argstr>
    80005da6:	18054263          	bltz	a0,80005f2a <sys_unlink+0x1a4>
  begin_op(ROOTDEV);
    80005daa:	4501                	li	a0,0
    80005dac:	fffff097          	auipc	ra,0xfffff
    80005db0:	a96080e7          	jalr	-1386(ra) # 80004842 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005db4:	fb040593          	addi	a1,s0,-80
    80005db8:	f3040513          	addi	a0,s0,-208
    80005dbc:	fffff097          	auipc	ra,0xfffff
    80005dc0:	85e080e7          	jalr	-1954(ra) # 8000461a <nameiparent>
    80005dc4:	89aa                	mv	s3,a0
    80005dc6:	cd61                	beqz	a0,80005e9e <sys_unlink+0x118>
  ilock(dp);
    80005dc8:	ffffe097          	auipc	ra,0xffffe
    80005dcc:	0a0080e7          	jalr	160(ra) # 80003e68 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005dd0:	00003597          	auipc	a1,0x3
    80005dd4:	e8858593          	addi	a1,a1,-376 # 80008c58 <userret+0xbc8>
    80005dd8:	fb040513          	addi	a0,s0,-80
    80005ddc:	ffffe097          	auipc	ra,0xffffe
    80005de0:	52c080e7          	jalr	1324(ra) # 80004308 <namecmp>
    80005de4:	14050a63          	beqz	a0,80005f38 <sys_unlink+0x1b2>
    80005de8:	00003597          	auipc	a1,0x3
    80005dec:	e7858593          	addi	a1,a1,-392 # 80008c60 <userret+0xbd0>
    80005df0:	fb040513          	addi	a0,s0,-80
    80005df4:	ffffe097          	auipc	ra,0xffffe
    80005df8:	514080e7          	jalr	1300(ra) # 80004308 <namecmp>
    80005dfc:	12050e63          	beqz	a0,80005f38 <sys_unlink+0x1b2>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005e00:	f2c40613          	addi	a2,s0,-212
    80005e04:	fb040593          	addi	a1,s0,-80
    80005e08:	854e                	mv	a0,s3
    80005e0a:	ffffe097          	auipc	ra,0xffffe
    80005e0e:	518080e7          	jalr	1304(ra) # 80004322 <dirlookup>
    80005e12:	84aa                	mv	s1,a0
    80005e14:	12050263          	beqz	a0,80005f38 <sys_unlink+0x1b2>
  ilock(ip);
    80005e18:	ffffe097          	auipc	ra,0xffffe
    80005e1c:	050080e7          	jalr	80(ra) # 80003e68 <ilock>
  if(ip->nlink < 1)
    80005e20:	06249783          	lh	a5,98(s1)
    80005e24:	08f05463          	blez	a5,80005eac <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005e28:	05c49703          	lh	a4,92(s1)
    80005e2c:	4785                	li	a5,1
    80005e2e:	08f70763          	beq	a4,a5,80005ebc <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005e32:	4641                	li	a2,16
    80005e34:	4581                	li	a1,0
    80005e36:	fc040513          	addi	a0,s0,-64
    80005e3a:	ffffb097          	auipc	ra,0xffffb
    80005e3e:	2f4080e7          	jalr	756(ra) # 8000112e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e42:	4741                	li	a4,16
    80005e44:	f2c42683          	lw	a3,-212(s0)
    80005e48:	fc040613          	addi	a2,s0,-64
    80005e4c:	4581                	li	a1,0
    80005e4e:	854e                	mv	a0,s3
    80005e50:	ffffe097          	auipc	ra,0xffffe
    80005e54:	39e080e7          	jalr	926(ra) # 800041ee <writei>
    80005e58:	47c1                	li	a5,16
    80005e5a:	0af51563          	bne	a0,a5,80005f04 <sys_unlink+0x17e>
  if(ip->type == T_DIR){
    80005e5e:	05c49703          	lh	a4,92(s1)
    80005e62:	4785                	li	a5,1
    80005e64:	0af70863          	beq	a4,a5,80005f14 <sys_unlink+0x18e>
  iunlockput(dp);
    80005e68:	854e                	mv	a0,s3
    80005e6a:	ffffe097          	auipc	ra,0xffffe
    80005e6e:	23e080e7          	jalr	574(ra) # 800040a8 <iunlockput>
  ip->nlink--;
    80005e72:	0624d783          	lhu	a5,98(s1)
    80005e76:	37fd                	addiw	a5,a5,-1
    80005e78:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005e7c:	8526                	mv	a0,s1
    80005e7e:	ffffe097          	auipc	ra,0xffffe
    80005e82:	f1e080e7          	jalr	-226(ra) # 80003d9c <iupdate>
  iunlockput(ip);
    80005e86:	8526                	mv	a0,s1
    80005e88:	ffffe097          	auipc	ra,0xffffe
    80005e8c:	220080e7          	jalr	544(ra) # 800040a8 <iunlockput>
  end_op(ROOTDEV);
    80005e90:	4501                	li	a0,0
    80005e92:	fffff097          	auipc	ra,0xfffff
    80005e96:	a5c080e7          	jalr	-1444(ra) # 800048ee <end_op>
  return 0;
    80005e9a:	4501                	li	a0,0
    80005e9c:	a84d                	j	80005f4e <sys_unlink+0x1c8>
    end_op(ROOTDEV);
    80005e9e:	4501                	li	a0,0
    80005ea0:	fffff097          	auipc	ra,0xfffff
    80005ea4:	a4e080e7          	jalr	-1458(ra) # 800048ee <end_op>
    return -1;
    80005ea8:	557d                	li	a0,-1
    80005eaa:	a055                	j	80005f4e <sys_unlink+0x1c8>
    panic("unlink: nlink < 1");
    80005eac:	00003517          	auipc	a0,0x3
    80005eb0:	ddc50513          	addi	a0,a0,-548 # 80008c88 <userret+0xbf8>
    80005eb4:	ffffb097          	auipc	ra,0xffffb
    80005eb8:	8d0080e7          	jalr	-1840(ra) # 80000784 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ebc:	50f8                	lw	a4,100(s1)
    80005ebe:	02000793          	li	a5,32
    80005ec2:	f6e7f8e3          	bleu	a4,a5,80005e32 <sys_unlink+0xac>
    80005ec6:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005eca:	4741                	li	a4,16
    80005ecc:	86ca                	mv	a3,s2
    80005ece:	f1840613          	addi	a2,s0,-232
    80005ed2:	4581                	li	a1,0
    80005ed4:	8526                	mv	a0,s1
    80005ed6:	ffffe097          	auipc	ra,0xffffe
    80005eda:	224080e7          	jalr	548(ra) # 800040fa <readi>
    80005ede:	47c1                	li	a5,16
    80005ee0:	00f51a63          	bne	a0,a5,80005ef4 <sys_unlink+0x16e>
    if(de.inum != 0)
    80005ee4:	f1845783          	lhu	a5,-232(s0)
    80005ee8:	e3b9                	bnez	a5,80005f2e <sys_unlink+0x1a8>
    80005eea:	2941                	addiw	s2,s2,16
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005eec:	50fc                	lw	a5,100(s1)
    80005eee:	fcf96ee3          	bltu	s2,a5,80005eca <sys_unlink+0x144>
    80005ef2:	b781                	j	80005e32 <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005ef4:	00003517          	auipc	a0,0x3
    80005ef8:	dac50513          	addi	a0,a0,-596 # 80008ca0 <userret+0xc10>
    80005efc:	ffffb097          	auipc	ra,0xffffb
    80005f00:	888080e7          	jalr	-1912(ra) # 80000784 <panic>
    panic("unlink: writei");
    80005f04:	00003517          	auipc	a0,0x3
    80005f08:	db450513          	addi	a0,a0,-588 # 80008cb8 <userret+0xc28>
    80005f0c:	ffffb097          	auipc	ra,0xffffb
    80005f10:	878080e7          	jalr	-1928(ra) # 80000784 <panic>
    dp->nlink--;
    80005f14:	0629d783          	lhu	a5,98(s3)
    80005f18:	37fd                	addiw	a5,a5,-1
    80005f1a:	06f99123          	sh	a5,98(s3)
    iupdate(dp);
    80005f1e:	854e                	mv	a0,s3
    80005f20:	ffffe097          	auipc	ra,0xffffe
    80005f24:	e7c080e7          	jalr	-388(ra) # 80003d9c <iupdate>
    80005f28:	b781                	j	80005e68 <sys_unlink+0xe2>
    return -1;
    80005f2a:	557d                	li	a0,-1
    80005f2c:	a00d                	j	80005f4e <sys_unlink+0x1c8>
    iunlockput(ip);
    80005f2e:	8526                	mv	a0,s1
    80005f30:	ffffe097          	auipc	ra,0xffffe
    80005f34:	178080e7          	jalr	376(ra) # 800040a8 <iunlockput>
  iunlockput(dp);
    80005f38:	854e                	mv	a0,s3
    80005f3a:	ffffe097          	auipc	ra,0xffffe
    80005f3e:	16e080e7          	jalr	366(ra) # 800040a8 <iunlockput>
  end_op(ROOTDEV);
    80005f42:	4501                	li	a0,0
    80005f44:	fffff097          	auipc	ra,0xfffff
    80005f48:	9aa080e7          	jalr	-1622(ra) # 800048ee <end_op>
  return -1;
    80005f4c:	557d                	li	a0,-1
}
    80005f4e:	70ae                	ld	ra,232(sp)
    80005f50:	740e                	ld	s0,224(sp)
    80005f52:	64ee                	ld	s1,216(sp)
    80005f54:	694e                	ld	s2,208(sp)
    80005f56:	69ae                	ld	s3,200(sp)
    80005f58:	616d                	addi	sp,sp,240
    80005f5a:	8082                	ret

0000000080005f5c <sys_open>:

uint64
sys_open(void)
{
    80005f5c:	7131                	addi	sp,sp,-192
    80005f5e:	fd06                	sd	ra,184(sp)
    80005f60:	f922                	sd	s0,176(sp)
    80005f62:	f526                	sd	s1,168(sp)
    80005f64:	f14a                	sd	s2,160(sp)
    80005f66:	ed4e                	sd	s3,152(sp)
    80005f68:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005f6a:	08000613          	li	a2,128
    80005f6e:	f5040593          	addi	a1,s0,-176
    80005f72:	4501                	li	a0,0
    80005f74:	ffffd097          	auipc	ra,0xffffd
    80005f78:	366080e7          	jalr	870(ra) # 800032da <argstr>
    return -1;
    80005f7c:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005f7e:	0a054963          	bltz	a0,80006030 <sys_open+0xd4>
    80005f82:	f4c40593          	addi	a1,s0,-180
    80005f86:	4505                	li	a0,1
    80005f88:	ffffd097          	auipc	ra,0xffffd
    80005f8c:	30e080e7          	jalr	782(ra) # 80003296 <argint>
    80005f90:	0a054063          	bltz	a0,80006030 <sys_open+0xd4>

  begin_op(ROOTDEV);
    80005f94:	4501                	li	a0,0
    80005f96:	fffff097          	auipc	ra,0xfffff
    80005f9a:	8ac080e7          	jalr	-1876(ra) # 80004842 <begin_op>

  if(omode & O_CREATE){
    80005f9e:	f4c42783          	lw	a5,-180(s0)
    80005fa2:	2007f793          	andi	a5,a5,512
    80005fa6:	c3dd                	beqz	a5,8000604c <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80005fa8:	4681                	li	a3,0
    80005faa:	4601                	li	a2,0
    80005fac:	4589                	li	a1,2
    80005fae:	f5040513          	addi	a0,s0,-176
    80005fb2:	00000097          	auipc	ra,0x0
    80005fb6:	962080e7          	jalr	-1694(ra) # 80005914 <create>
    80005fba:	892a                	mv	s2,a0
    if(ip == 0){
    80005fbc:	c151                	beqz	a0,80006040 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005fbe:	05c91703          	lh	a4,92(s2)
    80005fc2:	478d                	li	a5,3
    80005fc4:	00f71763          	bne	a4,a5,80005fd2 <sys_open+0x76>
    80005fc8:	05e95703          	lhu	a4,94(s2)
    80005fcc:	47a5                	li	a5,9
    80005fce:	0ce7e663          	bltu	a5,a4,8000609a <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005fd2:	fffff097          	auipc	ra,0xfffff
    80005fd6:	d5c080e7          	jalr	-676(ra) # 80004d2e <filealloc>
    80005fda:	89aa                	mv	s3,a0
    80005fdc:	c97d                	beqz	a0,800060d2 <sys_open+0x176>
    80005fde:	00000097          	auipc	ra,0x0
    80005fe2:	8ee080e7          	jalr	-1810(ra) # 800058cc <fdalloc>
    80005fe6:	84aa                	mv	s1,a0
    80005fe8:	0e054063          	bltz	a0,800060c8 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005fec:	05c91703          	lh	a4,92(s2)
    80005ff0:	478d                	li	a5,3
    80005ff2:	0cf70063          	beq	a4,a5,800060b2 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005ff6:	4789                	li	a5,2
    80005ff8:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005ffc:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80006000:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80006004:	f4c42783          	lw	a5,-180(s0)
    80006008:	0017c713          	xori	a4,a5,1
    8000600c:	8b05                	andi	a4,a4,1
    8000600e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006012:	8b8d                	andi	a5,a5,3
    80006014:	00f037b3          	snez	a5,a5
    80006018:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    8000601c:	854a                	mv	a0,s2
    8000601e:	ffffe097          	auipc	ra,0xffffe
    80006022:	f0e080e7          	jalr	-242(ra) # 80003f2c <iunlock>
  end_op(ROOTDEV);
    80006026:	4501                	li	a0,0
    80006028:	fffff097          	auipc	ra,0xfffff
    8000602c:	8c6080e7          	jalr	-1850(ra) # 800048ee <end_op>

  return fd;
}
    80006030:	8526                	mv	a0,s1
    80006032:	70ea                	ld	ra,184(sp)
    80006034:	744a                	ld	s0,176(sp)
    80006036:	74aa                	ld	s1,168(sp)
    80006038:	790a                	ld	s2,160(sp)
    8000603a:	69ea                	ld	s3,152(sp)
    8000603c:	6129                	addi	sp,sp,192
    8000603e:	8082                	ret
      end_op(ROOTDEV);
    80006040:	4501                	li	a0,0
    80006042:	fffff097          	auipc	ra,0xfffff
    80006046:	8ac080e7          	jalr	-1876(ra) # 800048ee <end_op>
      return -1;
    8000604a:	b7dd                	j	80006030 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    8000604c:	f5040513          	addi	a0,s0,-176
    80006050:	ffffe097          	auipc	ra,0xffffe
    80006054:	5ac080e7          	jalr	1452(ra) # 800045fc <namei>
    80006058:	892a                	mv	s2,a0
    8000605a:	c90d                	beqz	a0,8000608c <sys_open+0x130>
    ilock(ip);
    8000605c:	ffffe097          	auipc	ra,0xffffe
    80006060:	e0c080e7          	jalr	-500(ra) # 80003e68 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006064:	05c91703          	lh	a4,92(s2)
    80006068:	4785                	li	a5,1
    8000606a:	f4f71ae3          	bne	a4,a5,80005fbe <sys_open+0x62>
    8000606e:	f4c42783          	lw	a5,-180(s0)
    80006072:	d3a5                	beqz	a5,80005fd2 <sys_open+0x76>
      iunlockput(ip);
    80006074:	854a                	mv	a0,s2
    80006076:	ffffe097          	auipc	ra,0xffffe
    8000607a:	032080e7          	jalr	50(ra) # 800040a8 <iunlockput>
      end_op(ROOTDEV);
    8000607e:	4501                	li	a0,0
    80006080:	fffff097          	auipc	ra,0xfffff
    80006084:	86e080e7          	jalr	-1938(ra) # 800048ee <end_op>
      return -1;
    80006088:	54fd                	li	s1,-1
    8000608a:	b75d                	j	80006030 <sys_open+0xd4>
      end_op(ROOTDEV);
    8000608c:	4501                	li	a0,0
    8000608e:	fffff097          	auipc	ra,0xfffff
    80006092:	860080e7          	jalr	-1952(ra) # 800048ee <end_op>
      return -1;
    80006096:	54fd                	li	s1,-1
    80006098:	bf61                	j	80006030 <sys_open+0xd4>
    iunlockput(ip);
    8000609a:	854a                	mv	a0,s2
    8000609c:	ffffe097          	auipc	ra,0xffffe
    800060a0:	00c080e7          	jalr	12(ra) # 800040a8 <iunlockput>
    end_op(ROOTDEV);
    800060a4:	4501                	li	a0,0
    800060a6:	fffff097          	auipc	ra,0xfffff
    800060aa:	848080e7          	jalr	-1976(ra) # 800048ee <end_op>
    return -1;
    800060ae:	54fd                	li	s1,-1
    800060b0:	b741                	j	80006030 <sys_open+0xd4>
    f->type = FD_DEVICE;
    800060b2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800060b6:	05e91783          	lh	a5,94(s2)
    800060ba:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    800060be:	06091783          	lh	a5,96(s2)
    800060c2:	02f99323          	sh	a5,38(s3)
    800060c6:	bf1d                	j	80005ffc <sys_open+0xa0>
      fileclose(f);
    800060c8:	854e                	mv	a0,s3
    800060ca:	fffff097          	auipc	ra,0xfffff
    800060ce:	d34080e7          	jalr	-716(ra) # 80004dfe <fileclose>
    iunlockput(ip);
    800060d2:	854a                	mv	a0,s2
    800060d4:	ffffe097          	auipc	ra,0xffffe
    800060d8:	fd4080e7          	jalr	-44(ra) # 800040a8 <iunlockput>
    end_op(ROOTDEV);
    800060dc:	4501                	li	a0,0
    800060de:	fffff097          	auipc	ra,0xfffff
    800060e2:	810080e7          	jalr	-2032(ra) # 800048ee <end_op>
    return -1;
    800060e6:	54fd                	li	s1,-1
    800060e8:	b7a1                	j	80006030 <sys_open+0xd4>

00000000800060ea <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800060ea:	7175                	addi	sp,sp,-144
    800060ec:	e506                	sd	ra,136(sp)
    800060ee:	e122                	sd	s0,128(sp)
    800060f0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    800060f2:	4501                	li	a0,0
    800060f4:	ffffe097          	auipc	ra,0xffffe
    800060f8:	74e080e7          	jalr	1870(ra) # 80004842 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800060fc:	08000613          	li	a2,128
    80006100:	f7040593          	addi	a1,s0,-144
    80006104:	4501                	li	a0,0
    80006106:	ffffd097          	auipc	ra,0xffffd
    8000610a:	1d4080e7          	jalr	468(ra) # 800032da <argstr>
    8000610e:	02054a63          	bltz	a0,80006142 <sys_mkdir+0x58>
    80006112:	4681                	li	a3,0
    80006114:	4601                	li	a2,0
    80006116:	4585                	li	a1,1
    80006118:	f7040513          	addi	a0,s0,-144
    8000611c:	fffff097          	auipc	ra,0xfffff
    80006120:	7f8080e7          	jalr	2040(ra) # 80005914 <create>
    80006124:	cd19                	beqz	a0,80006142 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80006126:	ffffe097          	auipc	ra,0xffffe
    8000612a:	f82080e7          	jalr	-126(ra) # 800040a8 <iunlockput>
  end_op(ROOTDEV);
    8000612e:	4501                	li	a0,0
    80006130:	ffffe097          	auipc	ra,0xffffe
    80006134:	7be080e7          	jalr	1982(ra) # 800048ee <end_op>
  return 0;
    80006138:	4501                	li	a0,0
}
    8000613a:	60aa                	ld	ra,136(sp)
    8000613c:	640a                	ld	s0,128(sp)
    8000613e:	6149                	addi	sp,sp,144
    80006140:	8082                	ret
    end_op(ROOTDEV);
    80006142:	4501                	li	a0,0
    80006144:	ffffe097          	auipc	ra,0xffffe
    80006148:	7aa080e7          	jalr	1962(ra) # 800048ee <end_op>
    return -1;
    8000614c:	557d                	li	a0,-1
    8000614e:	b7f5                	j	8000613a <sys_mkdir+0x50>

0000000080006150 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006150:	7135                	addi	sp,sp,-160
    80006152:	ed06                	sd	ra,152(sp)
    80006154:	e922                	sd	s0,144(sp)
    80006156:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80006158:	4501                	li	a0,0
    8000615a:	ffffe097          	auipc	ra,0xffffe
    8000615e:	6e8080e7          	jalr	1768(ra) # 80004842 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006162:	08000613          	li	a2,128
    80006166:	f7040593          	addi	a1,s0,-144
    8000616a:	4501                	li	a0,0
    8000616c:	ffffd097          	auipc	ra,0xffffd
    80006170:	16e080e7          	jalr	366(ra) # 800032da <argstr>
    80006174:	04054b63          	bltz	a0,800061ca <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80006178:	f6c40593          	addi	a1,s0,-148
    8000617c:	4505                	li	a0,1
    8000617e:	ffffd097          	auipc	ra,0xffffd
    80006182:	118080e7          	jalr	280(ra) # 80003296 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006186:	04054263          	bltz	a0,800061ca <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    8000618a:	f6840593          	addi	a1,s0,-152
    8000618e:	4509                	li	a0,2
    80006190:	ffffd097          	auipc	ra,0xffffd
    80006194:	106080e7          	jalr	262(ra) # 80003296 <argint>
     argint(1, &major) < 0 ||
    80006198:	02054963          	bltz	a0,800061ca <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000619c:	f6841683          	lh	a3,-152(s0)
    800061a0:	f6c41603          	lh	a2,-148(s0)
    800061a4:	458d                	li	a1,3
    800061a6:	f7040513          	addi	a0,s0,-144
    800061aa:	fffff097          	auipc	ra,0xfffff
    800061ae:	76a080e7          	jalr	1898(ra) # 80005914 <create>
     argint(2, &minor) < 0 ||
    800061b2:	cd01                	beqz	a0,800061ca <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    800061b4:	ffffe097          	auipc	ra,0xffffe
    800061b8:	ef4080e7          	jalr	-268(ra) # 800040a8 <iunlockput>
  end_op(ROOTDEV);
    800061bc:	4501                	li	a0,0
    800061be:	ffffe097          	auipc	ra,0xffffe
    800061c2:	730080e7          	jalr	1840(ra) # 800048ee <end_op>
  return 0;
    800061c6:	4501                	li	a0,0
    800061c8:	a039                	j	800061d6 <sys_mknod+0x86>
    end_op(ROOTDEV);
    800061ca:	4501                	li	a0,0
    800061cc:	ffffe097          	auipc	ra,0xffffe
    800061d0:	722080e7          	jalr	1826(ra) # 800048ee <end_op>
    return -1;
    800061d4:	557d                	li	a0,-1
}
    800061d6:	60ea                	ld	ra,152(sp)
    800061d8:	644a                	ld	s0,144(sp)
    800061da:	610d                	addi	sp,sp,160
    800061dc:	8082                	ret

00000000800061de <sys_chdir>:

uint64
sys_chdir(void)
{
    800061de:	7135                	addi	sp,sp,-160
    800061e0:	ed06                	sd	ra,152(sp)
    800061e2:	e922                	sd	s0,144(sp)
    800061e4:	e526                	sd	s1,136(sp)
    800061e6:	e14a                	sd	s2,128(sp)
    800061e8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800061ea:	ffffc097          	auipc	ra,0xffffc
    800061ee:	e56080e7          	jalr	-426(ra) # 80002040 <myproc>
    800061f2:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    800061f4:	4501                	li	a0,0
    800061f6:	ffffe097          	auipc	ra,0xffffe
    800061fa:	64c080e7          	jalr	1612(ra) # 80004842 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800061fe:	08000613          	li	a2,128
    80006202:	f6040593          	addi	a1,s0,-160
    80006206:	4501                	li	a0,0
    80006208:	ffffd097          	auipc	ra,0xffffd
    8000620c:	0d2080e7          	jalr	210(ra) # 800032da <argstr>
    80006210:	04054c63          	bltz	a0,80006268 <sys_chdir+0x8a>
    80006214:	f6040513          	addi	a0,s0,-160
    80006218:	ffffe097          	auipc	ra,0xffffe
    8000621c:	3e4080e7          	jalr	996(ra) # 800045fc <namei>
    80006220:	84aa                	mv	s1,a0
    80006222:	c139                	beqz	a0,80006268 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80006224:	ffffe097          	auipc	ra,0xffffe
    80006228:	c44080e7          	jalr	-956(ra) # 80003e68 <ilock>
  if(ip->type != T_DIR){
    8000622c:	05c49703          	lh	a4,92(s1)
    80006230:	4785                	li	a5,1
    80006232:	04f71263          	bne	a4,a5,80006276 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80006236:	8526                	mv	a0,s1
    80006238:	ffffe097          	auipc	ra,0xffffe
    8000623c:	cf4080e7          	jalr	-780(ra) # 80003f2c <iunlock>
  iput(p->cwd);
    80006240:	16893503          	ld	a0,360(s2)
    80006244:	ffffe097          	auipc	ra,0xffffe
    80006248:	d34080e7          	jalr	-716(ra) # 80003f78 <iput>
  end_op(ROOTDEV);
    8000624c:	4501                	li	a0,0
    8000624e:	ffffe097          	auipc	ra,0xffffe
    80006252:	6a0080e7          	jalr	1696(ra) # 800048ee <end_op>
  p->cwd = ip;
    80006256:	16993423          	sd	s1,360(s2)
  return 0;
    8000625a:	4501                	li	a0,0
}
    8000625c:	60ea                	ld	ra,152(sp)
    8000625e:	644a                	ld	s0,144(sp)
    80006260:	64aa                	ld	s1,136(sp)
    80006262:	690a                	ld	s2,128(sp)
    80006264:	610d                	addi	sp,sp,160
    80006266:	8082                	ret
    end_op(ROOTDEV);
    80006268:	4501                	li	a0,0
    8000626a:	ffffe097          	auipc	ra,0xffffe
    8000626e:	684080e7          	jalr	1668(ra) # 800048ee <end_op>
    return -1;
    80006272:	557d                	li	a0,-1
    80006274:	b7e5                	j	8000625c <sys_chdir+0x7e>
    iunlockput(ip);
    80006276:	8526                	mv	a0,s1
    80006278:	ffffe097          	auipc	ra,0xffffe
    8000627c:	e30080e7          	jalr	-464(ra) # 800040a8 <iunlockput>
    end_op(ROOTDEV);
    80006280:	4501                	li	a0,0
    80006282:	ffffe097          	auipc	ra,0xffffe
    80006286:	66c080e7          	jalr	1644(ra) # 800048ee <end_op>
    return -1;
    8000628a:	557d                	li	a0,-1
    8000628c:	bfc1                	j	8000625c <sys_chdir+0x7e>

000000008000628e <sys_exec>:

uint64
sys_exec(void)
{
    8000628e:	7145                	addi	sp,sp,-464
    80006290:	e786                	sd	ra,456(sp)
    80006292:	e3a2                	sd	s0,448(sp)
    80006294:	ff26                	sd	s1,440(sp)
    80006296:	fb4a                	sd	s2,432(sp)
    80006298:	f74e                	sd	s3,424(sp)
    8000629a:	f352                	sd	s4,416(sp)
    8000629c:	ef56                	sd	s5,408(sp)
    8000629e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800062a0:	08000613          	li	a2,128
    800062a4:	f4040593          	addi	a1,s0,-192
    800062a8:	4501                	li	a0,0
    800062aa:	ffffd097          	auipc	ra,0xffffd
    800062ae:	030080e7          	jalr	48(ra) # 800032da <argstr>
    800062b2:	10054763          	bltz	a0,800063c0 <sys_exec+0x132>
    800062b6:	e3840593          	addi	a1,s0,-456
    800062ba:	4505                	li	a0,1
    800062bc:	ffffd097          	auipc	ra,0xffffd
    800062c0:	ffc080e7          	jalr	-4(ra) # 800032b8 <argaddr>
    800062c4:	10054863          	bltz	a0,800063d4 <sys_exec+0x146>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    800062c8:	e4040913          	addi	s2,s0,-448
    800062cc:	10000613          	li	a2,256
    800062d0:	4581                	li	a1,0
    800062d2:	854a                	mv	a0,s2
    800062d4:	ffffb097          	auipc	ra,0xffffb
    800062d8:	e5a080e7          	jalr	-422(ra) # 8000112e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800062dc:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    800062de:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    800062e0:	02000a93          	li	s5,32
    800062e4:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800062e8:	00349513          	slli	a0,s1,0x3
    800062ec:	e3040593          	addi	a1,s0,-464
    800062f0:	e3843783          	ld	a5,-456(s0)
    800062f4:	953e                	add	a0,a0,a5
    800062f6:	ffffd097          	auipc	ra,0xffffd
    800062fa:	f04080e7          	jalr	-252(ra) # 800031fa <fetchaddr>
    800062fe:	02054a63          	bltz	a0,80006332 <sys_exec+0xa4>
      goto bad;
    }
    if(uarg == 0){
    80006302:	e3043783          	ld	a5,-464(s0)
    80006306:	cfa1                	beqz	a5,8000635e <sys_exec+0xd0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006308:	ffffb097          	auipc	ra,0xffffb
    8000630c:	82a080e7          	jalr	-2006(ra) # 80000b32 <kalloc>
    80006310:	85aa                	mv	a1,a0
    80006312:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80006316:	c949                	beqz	a0,800063a8 <sys_exec+0x11a>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80006318:	6605                	lui	a2,0x1
    8000631a:	e3043503          	ld	a0,-464(s0)
    8000631e:	ffffd097          	auipc	ra,0xffffd
    80006322:	f30080e7          	jalr	-208(ra) # 8000324e <fetchstr>
    80006326:	00054663          	bltz	a0,80006332 <sys_exec+0xa4>
    if(i >= NELEM(argv)){
    8000632a:	0485                	addi	s1,s1,1
    8000632c:	0921                	addi	s2,s2,8
    8000632e:	fb549be3          	bne	s1,s5,800062e4 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006332:	e4043503          	ld	a0,-448(s0)
    80006336:	c149                	beqz	a0,800063b8 <sys_exec+0x12a>
    kfree(argv[i]);
    80006338:	ffffa097          	auipc	ra,0xffffa
    8000633c:	7e2080e7          	jalr	2018(ra) # 80000b1a <kfree>
    80006340:	e4840493          	addi	s1,s0,-440
    80006344:	10098993          	addi	s3,s3,256
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006348:	6088                	ld	a0,0(s1)
    8000634a:	c92d                	beqz	a0,800063bc <sys_exec+0x12e>
    kfree(argv[i]);
    8000634c:	ffffa097          	auipc	ra,0xffffa
    80006350:	7ce080e7          	jalr	1998(ra) # 80000b1a <kfree>
    80006354:	04a1                	addi	s1,s1,8
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006356:	ff3499e3          	bne	s1,s3,80006348 <sys_exec+0xba>
  return -1;
    8000635a:	557d                	li	a0,-1
    8000635c:	a09d                	j	800063c2 <sys_exec+0x134>
      argv[i] = 0;
    8000635e:	0a0e                	slli	s4,s4,0x3
    80006360:	fc040793          	addi	a5,s0,-64
    80006364:	9a3e                	add	s4,s4,a5
    80006366:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    8000636a:	e4040593          	addi	a1,s0,-448
    8000636e:	f4040513          	addi	a0,s0,-192
    80006372:	fffff097          	auipc	ra,0xfffff
    80006376:	150080e7          	jalr	336(ra) # 800054c2 <exec>
    8000637a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000637c:	e4043503          	ld	a0,-448(s0)
    80006380:	c115                	beqz	a0,800063a4 <sys_exec+0x116>
    kfree(argv[i]);
    80006382:	ffffa097          	auipc	ra,0xffffa
    80006386:	798080e7          	jalr	1944(ra) # 80000b1a <kfree>
    8000638a:	e4840493          	addi	s1,s0,-440
    8000638e:	10098993          	addi	s3,s3,256
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006392:	6088                	ld	a0,0(s1)
    80006394:	c901                	beqz	a0,800063a4 <sys_exec+0x116>
    kfree(argv[i]);
    80006396:	ffffa097          	auipc	ra,0xffffa
    8000639a:	784080e7          	jalr	1924(ra) # 80000b1a <kfree>
    8000639e:	04a1                	addi	s1,s1,8
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800063a0:	ff3499e3          	bne	s1,s3,80006392 <sys_exec+0x104>
  return ret;
    800063a4:	854a                	mv	a0,s2
    800063a6:	a831                	j	800063c2 <sys_exec+0x134>
      panic("sys_exec kalloc");
    800063a8:	00003517          	auipc	a0,0x3
    800063ac:	92050513          	addi	a0,a0,-1760 # 80008cc8 <userret+0xc38>
    800063b0:	ffffa097          	auipc	ra,0xffffa
    800063b4:	3d4080e7          	jalr	980(ra) # 80000784 <panic>
  return -1;
    800063b8:	557d                	li	a0,-1
    800063ba:	a021                	j	800063c2 <sys_exec+0x134>
    800063bc:	557d                	li	a0,-1
    800063be:	a011                	j	800063c2 <sys_exec+0x134>
    return -1;
    800063c0:	557d                	li	a0,-1
}
    800063c2:	60be                	ld	ra,456(sp)
    800063c4:	641e                	ld	s0,448(sp)
    800063c6:	74fa                	ld	s1,440(sp)
    800063c8:	795a                	ld	s2,432(sp)
    800063ca:	79ba                	ld	s3,424(sp)
    800063cc:	7a1a                	ld	s4,416(sp)
    800063ce:	6afa                	ld	s5,408(sp)
    800063d0:	6179                	addi	sp,sp,464
    800063d2:	8082                	ret
    return -1;
    800063d4:	557d                	li	a0,-1
    800063d6:	b7f5                	j	800063c2 <sys_exec+0x134>

00000000800063d8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800063d8:	7139                	addi	sp,sp,-64
    800063da:	fc06                	sd	ra,56(sp)
    800063dc:	f822                	sd	s0,48(sp)
    800063de:	f426                	sd	s1,40(sp)
    800063e0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800063e2:	ffffc097          	auipc	ra,0xffffc
    800063e6:	c5e080e7          	jalr	-930(ra) # 80002040 <myproc>
    800063ea:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800063ec:	fd840593          	addi	a1,s0,-40
    800063f0:	4501                	li	a0,0
    800063f2:	ffffd097          	auipc	ra,0xffffd
    800063f6:	ec6080e7          	jalr	-314(ra) # 800032b8 <argaddr>
    return -1;
    800063fa:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800063fc:	0c054f63          	bltz	a0,800064da <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80006400:	fc840593          	addi	a1,s0,-56
    80006404:	fd040513          	addi	a0,s0,-48
    80006408:	fffff097          	auipc	ra,0xfffff
    8000640c:	d5a080e7          	jalr	-678(ra) # 80005162 <pipealloc>
    return -1;
    80006410:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006412:	0c054463          	bltz	a0,800064da <sys_pipe+0x102>
  fd0 = -1;
    80006416:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000641a:	fd043503          	ld	a0,-48(s0)
    8000641e:	fffff097          	auipc	ra,0xfffff
    80006422:	4ae080e7          	jalr	1198(ra) # 800058cc <fdalloc>
    80006426:	fca42223          	sw	a0,-60(s0)
    8000642a:	08054b63          	bltz	a0,800064c0 <sys_pipe+0xe8>
    8000642e:	fc843503          	ld	a0,-56(s0)
    80006432:	fffff097          	auipc	ra,0xfffff
    80006436:	49a080e7          	jalr	1178(ra) # 800058cc <fdalloc>
    8000643a:	fca42023          	sw	a0,-64(s0)
    8000643e:	06054863          	bltz	a0,800064ae <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006442:	4691                	li	a3,4
    80006444:	fc440613          	addi	a2,s0,-60
    80006448:	fd843583          	ld	a1,-40(s0)
    8000644c:	74a8                	ld	a0,104(s1)
    8000644e:	ffffb097          	auipc	ra,0xffffb
    80006452:	7d0080e7          	jalr	2000(ra) # 80001c1e <copyout>
    80006456:	02054063          	bltz	a0,80006476 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000645a:	4691                	li	a3,4
    8000645c:	fc040613          	addi	a2,s0,-64
    80006460:	fd843583          	ld	a1,-40(s0)
    80006464:	0591                	addi	a1,a1,4
    80006466:	74a8                	ld	a0,104(s1)
    80006468:	ffffb097          	auipc	ra,0xffffb
    8000646c:	7b6080e7          	jalr	1974(ra) # 80001c1e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006470:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006472:	06055463          	bgez	a0,800064da <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80006476:	fc442783          	lw	a5,-60(s0)
    8000647a:	07f1                	addi	a5,a5,28
    8000647c:	078e                	slli	a5,a5,0x3
    8000647e:	97a6                	add	a5,a5,s1
    80006480:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006484:	fc042783          	lw	a5,-64(s0)
    80006488:	07f1                	addi	a5,a5,28
    8000648a:	078e                	slli	a5,a5,0x3
    8000648c:	94be                	add	s1,s1,a5
    8000648e:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006492:	fd043503          	ld	a0,-48(s0)
    80006496:	fffff097          	auipc	ra,0xfffff
    8000649a:	968080e7          	jalr	-1688(ra) # 80004dfe <fileclose>
    fileclose(wf);
    8000649e:	fc843503          	ld	a0,-56(s0)
    800064a2:	fffff097          	auipc	ra,0xfffff
    800064a6:	95c080e7          	jalr	-1700(ra) # 80004dfe <fileclose>
    return -1;
    800064aa:	57fd                	li	a5,-1
    800064ac:	a03d                	j	800064da <sys_pipe+0x102>
    if(fd0 >= 0)
    800064ae:	fc442783          	lw	a5,-60(s0)
    800064b2:	0007c763          	bltz	a5,800064c0 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    800064b6:	07f1                	addi	a5,a5,28
    800064b8:	078e                	slli	a5,a5,0x3
    800064ba:	94be                	add	s1,s1,a5
    800064bc:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800064c0:	fd043503          	ld	a0,-48(s0)
    800064c4:	fffff097          	auipc	ra,0xfffff
    800064c8:	93a080e7          	jalr	-1734(ra) # 80004dfe <fileclose>
    fileclose(wf);
    800064cc:	fc843503          	ld	a0,-56(s0)
    800064d0:	fffff097          	auipc	ra,0xfffff
    800064d4:	92e080e7          	jalr	-1746(ra) # 80004dfe <fileclose>
    return -1;
    800064d8:	57fd                	li	a5,-1
}
    800064da:	853e                	mv	a0,a5
    800064dc:	70e2                	ld	ra,56(sp)
    800064de:	7442                	ld	s0,48(sp)
    800064e0:	74a2                	ld	s1,40(sp)
    800064e2:	6121                	addi	sp,sp,64
    800064e4:	8082                	ret

00000000800064e6 <sys_create_mutex>:

uint64
sys_create_mutex(void)
{
    800064e6:	1141                	addi	sp,sp,-16
    800064e8:	e422                	sd	s0,8(sp)
    800064ea:	0800                	addi	s0,sp,16
  return -1;
}
    800064ec:	557d                	li	a0,-1
    800064ee:	6422                	ld	s0,8(sp)
    800064f0:	0141                	addi	sp,sp,16
    800064f2:	8082                	ret

00000000800064f4 <sys_acquire_mutex>:

uint64
sys_acquire_mutex(void)
{
    800064f4:	1141                	addi	sp,sp,-16
    800064f6:	e422                	sd	s0,8(sp)
    800064f8:	0800                	addi	s0,sp,16
  return 0;
}
    800064fa:	4501                	li	a0,0
    800064fc:	6422                	ld	s0,8(sp)
    800064fe:	0141                	addi	sp,sp,16
    80006500:	8082                	ret

0000000080006502 <sys_release_mutex>:

uint64
sys_release_mutex(void)
{
    80006502:	1141                	addi	sp,sp,-16
    80006504:	e422                	sd	s0,8(sp)
    80006506:	0800                	addi	s0,sp,16

  return 0;
}
    80006508:	4501                	li	a0,0
    8000650a:	6422                	ld	s0,8(sp)
    8000650c:	0141                	addi	sp,sp,16
    8000650e:	8082                	ret

0000000080006510 <kernelvec>:
    80006510:	7111                	addi	sp,sp,-256
    80006512:	e006                	sd	ra,0(sp)
    80006514:	e40a                	sd	sp,8(sp)
    80006516:	e80e                	sd	gp,16(sp)
    80006518:	ec12                	sd	tp,24(sp)
    8000651a:	f016                	sd	t0,32(sp)
    8000651c:	f41a                	sd	t1,40(sp)
    8000651e:	f81e                	sd	t2,48(sp)
    80006520:	fc22                	sd	s0,56(sp)
    80006522:	e0a6                	sd	s1,64(sp)
    80006524:	e4aa                	sd	a0,72(sp)
    80006526:	e8ae                	sd	a1,80(sp)
    80006528:	ecb2                	sd	a2,88(sp)
    8000652a:	f0b6                	sd	a3,96(sp)
    8000652c:	f4ba                	sd	a4,104(sp)
    8000652e:	f8be                	sd	a5,112(sp)
    80006530:	fcc2                	sd	a6,120(sp)
    80006532:	e146                	sd	a7,128(sp)
    80006534:	e54a                	sd	s2,136(sp)
    80006536:	e94e                	sd	s3,144(sp)
    80006538:	ed52                	sd	s4,152(sp)
    8000653a:	f156                	sd	s5,160(sp)
    8000653c:	f55a                	sd	s6,168(sp)
    8000653e:	f95e                	sd	s7,176(sp)
    80006540:	fd62                	sd	s8,184(sp)
    80006542:	e1e6                	sd	s9,192(sp)
    80006544:	e5ea                	sd	s10,200(sp)
    80006546:	e9ee                	sd	s11,208(sp)
    80006548:	edf2                	sd	t3,216(sp)
    8000654a:	f1f6                	sd	t4,224(sp)
    8000654c:	f5fa                	sd	t5,232(sp)
    8000654e:	f9fe                	sd	t6,240(sp)
    80006550:	b67fc0ef          	jal	ra,800030b6 <kerneltrap>
    80006554:	6082                	ld	ra,0(sp)
    80006556:	6122                	ld	sp,8(sp)
    80006558:	61c2                	ld	gp,16(sp)
    8000655a:	7282                	ld	t0,32(sp)
    8000655c:	7322                	ld	t1,40(sp)
    8000655e:	73c2                	ld	t2,48(sp)
    80006560:	7462                	ld	s0,56(sp)
    80006562:	6486                	ld	s1,64(sp)
    80006564:	6526                	ld	a0,72(sp)
    80006566:	65c6                	ld	a1,80(sp)
    80006568:	6666                	ld	a2,88(sp)
    8000656a:	7686                	ld	a3,96(sp)
    8000656c:	7726                	ld	a4,104(sp)
    8000656e:	77c6                	ld	a5,112(sp)
    80006570:	7866                	ld	a6,120(sp)
    80006572:	688a                	ld	a7,128(sp)
    80006574:	692a                	ld	s2,136(sp)
    80006576:	69ca                	ld	s3,144(sp)
    80006578:	6a6a                	ld	s4,152(sp)
    8000657a:	7a8a                	ld	s5,160(sp)
    8000657c:	7b2a                	ld	s6,168(sp)
    8000657e:	7bca                	ld	s7,176(sp)
    80006580:	7c6a                	ld	s8,184(sp)
    80006582:	6c8e                	ld	s9,192(sp)
    80006584:	6d2e                	ld	s10,200(sp)
    80006586:	6dce                	ld	s11,208(sp)
    80006588:	6e6e                	ld	t3,216(sp)
    8000658a:	7e8e                	ld	t4,224(sp)
    8000658c:	7f2e                	ld	t5,232(sp)
    8000658e:	7fce                	ld	t6,240(sp)
    80006590:	6111                	addi	sp,sp,256
    80006592:	10200073          	sret
    80006596:	00000013          	nop
    8000659a:	00000013          	nop
    8000659e:	0001                	nop

00000000800065a0 <timervec>:
    800065a0:	34051573          	csrrw	a0,mscratch,a0
    800065a4:	e10c                	sd	a1,0(a0)
    800065a6:	e510                	sd	a2,8(a0)
    800065a8:	e914                	sd	a3,16(a0)
    800065aa:	710c                	ld	a1,32(a0)
    800065ac:	7510                	ld	a2,40(a0)
    800065ae:	6194                	ld	a3,0(a1)
    800065b0:	96b2                	add	a3,a3,a2
    800065b2:	e194                	sd	a3,0(a1)
    800065b4:	4589                	li	a1,2
    800065b6:	14459073          	csrw	sip,a1
    800065ba:	6914                	ld	a3,16(a0)
    800065bc:	6510                	ld	a2,8(a0)
    800065be:	610c                	ld	a1,0(a0)
    800065c0:	34051573          	csrrw	a0,mscratch,a0
    800065c4:	30200073          	mret
	...

00000000800065ca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800065ca:	1141                	addi	sp,sp,-16
    800065cc:	e422                	sd	s0,8(sp)
    800065ce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800065d0:	0c0007b7          	lui	a5,0xc000
    800065d4:	4705                	li	a4,1
    800065d6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800065d8:	c3d8                	sw	a4,4(a5)
}
    800065da:	6422                	ld	s0,8(sp)
    800065dc:	0141                	addi	sp,sp,16
    800065de:	8082                	ret

00000000800065e0 <plicinithart>:

void
plicinithart(void)
{
    800065e0:	1141                	addi	sp,sp,-16
    800065e2:	e406                	sd	ra,8(sp)
    800065e4:	e022                	sd	s0,0(sp)
    800065e6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800065e8:	ffffc097          	auipc	ra,0xffffc
    800065ec:	a2c080e7          	jalr	-1492(ra) # 80002014 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800065f0:	0085171b          	slliw	a4,a0,0x8
    800065f4:	0c0027b7          	lui	a5,0xc002
    800065f8:	97ba                	add	a5,a5,a4
    800065fa:	40200713          	li	a4,1026
    800065fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006602:	00d5151b          	slliw	a0,a0,0xd
    80006606:	0c2017b7          	lui	a5,0xc201
    8000660a:	953e                	add	a0,a0,a5
    8000660c:	00052023          	sw	zero,0(a0)
}
    80006610:	60a2                	ld	ra,8(sp)
    80006612:	6402                	ld	s0,0(sp)
    80006614:	0141                	addi	sp,sp,16
    80006616:	8082                	ret

0000000080006618 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006618:	1141                	addi	sp,sp,-16
    8000661a:	e406                	sd	ra,8(sp)
    8000661c:	e022                	sd	s0,0(sp)
    8000661e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006620:	ffffc097          	auipc	ra,0xffffc
    80006624:	9f4080e7          	jalr	-1548(ra) # 80002014 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006628:	00d5151b          	slliw	a0,a0,0xd
    8000662c:	0c2017b7          	lui	a5,0xc201
    80006630:	97aa                	add	a5,a5,a0
  return irq;
}
    80006632:	43c8                	lw	a0,4(a5)
    80006634:	60a2                	ld	ra,8(sp)
    80006636:	6402                	ld	s0,0(sp)
    80006638:	0141                	addi	sp,sp,16
    8000663a:	8082                	ret

000000008000663c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000663c:	1101                	addi	sp,sp,-32
    8000663e:	ec06                	sd	ra,24(sp)
    80006640:	e822                	sd	s0,16(sp)
    80006642:	e426                	sd	s1,8(sp)
    80006644:	1000                	addi	s0,sp,32
    80006646:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006648:	ffffc097          	auipc	ra,0xffffc
    8000664c:	9cc080e7          	jalr	-1588(ra) # 80002014 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006650:	00d5151b          	slliw	a0,a0,0xd
    80006654:	0c2017b7          	lui	a5,0xc201
    80006658:	97aa                	add	a5,a5,a0
    8000665a:	c3c4                	sw	s1,4(a5)
}
    8000665c:	60e2                	ld	ra,24(sp)
    8000665e:	6442                	ld	s0,16(sp)
    80006660:	64a2                	ld	s1,8(sp)
    80006662:	6105                	addi	sp,sp,32
    80006664:	8082                	ret

0000000080006666 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006666:	1141                	addi	sp,sp,-16
    80006668:	e406                	sd	ra,8(sp)
    8000666a:	e022                	sd	s0,0(sp)
    8000666c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000666e:	479d                	li	a5,7
    80006670:	06b7c863          	blt	a5,a1,800066e0 <free_desc+0x7a>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006674:	00151713          	slli	a4,a0,0x1
    80006678:	972a                	add	a4,a4,a0
    8000667a:	00c71693          	slli	a3,a4,0xc
    8000667e:	00022717          	auipc	a4,0x22
    80006682:	98270713          	addi	a4,a4,-1662 # 80028000 <disk>
    80006686:	9736                	add	a4,a4,a3
    80006688:	972e                	add	a4,a4,a1
    8000668a:	6789                	lui	a5,0x2
    8000668c:	973e                	add	a4,a4,a5
    8000668e:	01874783          	lbu	a5,24(a4)
    80006692:	efb9                	bnez	a5,800066f0 <free_desc+0x8a>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006694:	00022817          	auipc	a6,0x22
    80006698:	96c80813          	addi	a6,a6,-1684 # 80028000 <disk>
    8000669c:	00151713          	slli	a4,a0,0x1
    800066a0:	00a707b3          	add	a5,a4,a0
    800066a4:	07b2                	slli	a5,a5,0xc
    800066a6:	97c2                	add	a5,a5,a6
    800066a8:	6689                	lui	a3,0x2
    800066aa:	00f68633          	add	a2,a3,a5
    800066ae:	6210                	ld	a2,0(a2)
    800066b0:	00459893          	slli	a7,a1,0x4
    800066b4:	9646                	add	a2,a2,a7
    800066b6:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    800066ba:	97ae                	add	a5,a5,a1
    800066bc:	97b6                	add	a5,a5,a3
    800066be:	4605                	li	a2,1
    800066c0:	00c78c23          	sb	a2,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk[n].free[0]);
    800066c4:	972a                	add	a4,a4,a0
    800066c6:	0732                	slli	a4,a4,0xc
    800066c8:	06e1                	addi	a3,a3,24
    800066ca:	9736                	add	a4,a4,a3
    800066cc:	00e80533          	add	a0,a6,a4
    800066d0:	ffffc097          	auipc	ra,0xffffc
    800066d4:	2fa080e7          	jalr	762(ra) # 800029ca <wakeup>
}
    800066d8:	60a2                	ld	ra,8(sp)
    800066da:	6402                	ld	s0,0(sp)
    800066dc:	0141                	addi	sp,sp,16
    800066de:	8082                	ret
    panic("virtio_disk_intr 1");
    800066e0:	00002517          	auipc	a0,0x2
    800066e4:	5f850513          	addi	a0,a0,1528 # 80008cd8 <userret+0xc48>
    800066e8:	ffffa097          	auipc	ra,0xffffa
    800066ec:	09c080e7          	jalr	156(ra) # 80000784 <panic>
    panic("virtio_disk_intr 2");
    800066f0:	00002517          	auipc	a0,0x2
    800066f4:	60050513          	addi	a0,a0,1536 # 80008cf0 <userret+0xc60>
    800066f8:	ffffa097          	auipc	ra,0xffffa
    800066fc:	08c080e7          	jalr	140(ra) # 80000784 <panic>

0000000080006700 <virtio_disk_init>:
  __sync_synchronize();
    80006700:	0ff0000f          	fence
  if(disk[n].init)
    80006704:	00151793          	slli	a5,a0,0x1
    80006708:	97aa                	add	a5,a5,a0
    8000670a:	07b2                	slli	a5,a5,0xc
    8000670c:	00022717          	auipc	a4,0x22
    80006710:	8f470713          	addi	a4,a4,-1804 # 80028000 <disk>
    80006714:	973e                	add	a4,a4,a5
    80006716:	6789                	lui	a5,0x2
    80006718:	97ba                	add	a5,a5,a4
    8000671a:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    8000671e:	c391                	beqz	a5,80006722 <virtio_disk_init+0x22>
    80006720:	8082                	ret
{
    80006722:	7139                	addi	sp,sp,-64
    80006724:	fc06                	sd	ra,56(sp)
    80006726:	f822                	sd	s0,48(sp)
    80006728:	f426                	sd	s1,40(sp)
    8000672a:	f04a                	sd	s2,32(sp)
    8000672c:	ec4e                	sd	s3,24(sp)
    8000672e:	e852                	sd	s4,16(sp)
    80006730:	e456                	sd	s5,8(sp)
    80006732:	0080                	addi	s0,sp,64
    80006734:	892a                	mv	s2,a0
  printf("virtio disk init %d\n", n);
    80006736:	85aa                	mv	a1,a0
    80006738:	00002517          	auipc	a0,0x2
    8000673c:	5d050513          	addi	a0,a0,1488 # 80008d08 <userret+0xc78>
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	25c080e7          	jalr	604(ra) # 8000099c <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80006748:	00191993          	slli	s3,s2,0x1
    8000674c:	99ca                	add	s3,s3,s2
    8000674e:	09b2                	slli	s3,s3,0xc
    80006750:	6789                	lui	a5,0x2
    80006752:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006756:	97ce                	add	a5,a5,s3
    80006758:	00002597          	auipc	a1,0x2
    8000675c:	5c858593          	addi	a1,a1,1480 # 80008d20 <userret+0xc90>
    80006760:	00022517          	auipc	a0,0x22
    80006764:	8a050513          	addi	a0,a0,-1888 # 80028000 <disk>
    80006768:	953e                	add	a0,a0,a5
    8000676a:	ffffa097          	auipc	ra,0xffffa
    8000676e:	3e2080e7          	jalr	994(ra) # 80000b4c <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006772:	0019049b          	addiw	s1,s2,1
    80006776:	00c4949b          	slliw	s1,s1,0xc
    8000677a:	100007b7          	lui	a5,0x10000
    8000677e:	97a6                	add	a5,a5,s1
    80006780:	4398                	lw	a4,0(a5)
    80006782:	2701                	sext.w	a4,a4
    80006784:	747277b7          	lui	a5,0x74727
    80006788:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000678c:	12f71763          	bne	a4,a5,800068ba <virtio_disk_init+0x1ba>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006790:	100007b7          	lui	a5,0x10000
    80006794:	0791                	addi	a5,a5,4
    80006796:	97a6                	add	a5,a5,s1
    80006798:	439c                	lw	a5,0(a5)
    8000679a:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000679c:	4705                	li	a4,1
    8000679e:	10e79e63          	bne	a5,a4,800068ba <virtio_disk_init+0x1ba>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800067a2:	100007b7          	lui	a5,0x10000
    800067a6:	07a1                	addi	a5,a5,8
    800067a8:	97a6                	add	a5,a5,s1
    800067aa:	439c                	lw	a5,0(a5)
    800067ac:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800067ae:	4709                	li	a4,2
    800067b0:	10e79563          	bne	a5,a4,800068ba <virtio_disk_init+0x1ba>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800067b4:	100007b7          	lui	a5,0x10000
    800067b8:	07b1                	addi	a5,a5,12
    800067ba:	97a6                	add	a5,a5,s1
    800067bc:	4398                	lw	a4,0(a5)
    800067be:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800067c0:	554d47b7          	lui	a5,0x554d4
    800067c4:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800067c8:	0ef71963          	bne	a4,a5,800068ba <virtio_disk_init+0x1ba>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800067cc:	100007b7          	lui	a5,0x10000
    800067d0:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    800067d4:	96a6                	add	a3,a3,s1
    800067d6:	4705                	li	a4,1
    800067d8:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800067da:	470d                	li	a4,3
    800067dc:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800067de:	01078713          	addi	a4,a5,16
    800067e2:	9726                	add	a4,a4,s1
    800067e4:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800067e6:	02078613          	addi	a2,a5,32
    800067ea:	9626                	add	a2,a2,s1
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800067ec:	c7ffe737          	lui	a4,0xc7ffe
    800067f0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd06b3>
    800067f4:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800067f6:	2701                	sext.w	a4,a4
    800067f8:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800067fa:	472d                	li	a4,11
    800067fc:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800067fe:	473d                	li	a4,15
    80006800:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006802:	02878713          	addi	a4,a5,40
    80006806:	9726                	add	a4,a4,s1
    80006808:	6685                	lui	a3,0x1
    8000680a:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000680c:	03078713          	addi	a4,a5,48
    80006810:	9726                	add	a4,a4,s1
    80006812:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006816:	03478793          	addi	a5,a5,52
    8000681a:	97a6                	add	a5,a5,s1
    8000681c:	439c                	lw	a5,0(a5)
    8000681e:	2781                	sext.w	a5,a5
  if(max == 0)
    80006820:	c7cd                	beqz	a5,800068ca <virtio_disk_init+0x1ca>
  if(max < NUM)
    80006822:	471d                	li	a4,7
    80006824:	0af77b63          	bleu	a5,a4,800068da <virtio_disk_init+0x1da>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006828:	10000ab7          	lui	s5,0x10000
    8000682c:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006830:	97a6                	add	a5,a5,s1
    80006832:	4721                	li	a4,8
    80006834:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006836:	00021a17          	auipc	s4,0x21
    8000683a:	7caa0a13          	addi	s4,s4,1994 # 80028000 <disk>
    8000683e:	99d2                	add	s3,s3,s4
    80006840:	6609                	lui	a2,0x2
    80006842:	4581                	li	a1,0
    80006844:	854e                	mv	a0,s3
    80006846:	ffffb097          	auipc	ra,0xffffb
    8000684a:	8e8080e7          	jalr	-1816(ra) # 8000112e <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    8000684e:	040a8a93          	addi	s5,s5,64
    80006852:	94d6                	add	s1,s1,s5
    80006854:	00c9d793          	srli	a5,s3,0xc
    80006858:	2781                	sext.w	a5,a5
    8000685a:	c09c                	sw	a5,0(s1)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    8000685c:	00191513          	slli	a0,s2,0x1
    80006860:	012507b3          	add	a5,a0,s2
    80006864:	07b2                	slli	a5,a5,0xc
    80006866:	97d2                	add	a5,a5,s4
    80006868:	6689                	lui	a3,0x2
    8000686a:	97b6                	add	a5,a5,a3
    8000686c:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006870:	08098713          	addi	a4,s3,128
    80006874:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    80006876:	6705                	lui	a4,0x1
    80006878:	99ba                	add	s3,s3,a4
    8000687a:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    8000687e:	4705                	li	a4,1
    80006880:	00e78c23          	sb	a4,24(a5)
    80006884:	00e78ca3          	sb	a4,25(a5)
    80006888:	00e78d23          	sb	a4,26(a5)
    8000688c:	00e78da3          	sb	a4,27(a5)
    80006890:	00e78e23          	sb	a4,28(a5)
    80006894:	00e78ea3          	sb	a4,29(a5)
    80006898:	00e78f23          	sb	a4,30(a5)
    8000689c:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    800068a0:	853e                	mv	a0,a5
    800068a2:	4785                	li	a5,1
    800068a4:	0af52423          	sw	a5,168(a0)
}
    800068a8:	70e2                	ld	ra,56(sp)
    800068aa:	7442                	ld	s0,48(sp)
    800068ac:	74a2                	ld	s1,40(sp)
    800068ae:	7902                	ld	s2,32(sp)
    800068b0:	69e2                	ld	s3,24(sp)
    800068b2:	6a42                	ld	s4,16(sp)
    800068b4:	6aa2                	ld	s5,8(sp)
    800068b6:	6121                	addi	sp,sp,64
    800068b8:	8082                	ret
    panic("could not find virtio disk");
    800068ba:	00002517          	auipc	a0,0x2
    800068be:	47650513          	addi	a0,a0,1142 # 80008d30 <userret+0xca0>
    800068c2:	ffffa097          	auipc	ra,0xffffa
    800068c6:	ec2080e7          	jalr	-318(ra) # 80000784 <panic>
    panic("virtio disk has no queue 0");
    800068ca:	00002517          	auipc	a0,0x2
    800068ce:	48650513          	addi	a0,a0,1158 # 80008d50 <userret+0xcc0>
    800068d2:	ffffa097          	auipc	ra,0xffffa
    800068d6:	eb2080e7          	jalr	-334(ra) # 80000784 <panic>
    panic("virtio disk max queue too short");
    800068da:	00002517          	auipc	a0,0x2
    800068de:	49650513          	addi	a0,a0,1174 # 80008d70 <userret+0xce0>
    800068e2:	ffffa097          	auipc	ra,0xffffa
    800068e6:	ea2080e7          	jalr	-350(ra) # 80000784 <panic>

00000000800068ea <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    800068ea:	7175                	addi	sp,sp,-144
    800068ec:	e506                	sd	ra,136(sp)
    800068ee:	e122                	sd	s0,128(sp)
    800068f0:	fca6                	sd	s1,120(sp)
    800068f2:	f8ca                	sd	s2,112(sp)
    800068f4:	f4ce                	sd	s3,104(sp)
    800068f6:	f0d2                	sd	s4,96(sp)
    800068f8:	ecd6                	sd	s5,88(sp)
    800068fa:	e8da                	sd	s6,80(sp)
    800068fc:	e4de                	sd	s7,72(sp)
    800068fe:	e0e2                	sd	s8,64(sp)
    80006900:	fc66                	sd	s9,56(sp)
    80006902:	f86a                	sd	s10,48(sp)
    80006904:	f46e                	sd	s11,40(sp)
    80006906:	0900                	addi	s0,sp,144
    80006908:	892a                	mv	s2,a0
    8000690a:	8a2e                	mv	s4,a1
    8000690c:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    8000690e:	00c5ad03          	lw	s10,12(a1)
    80006912:	001d1d1b          	slliw	s10,s10,0x1
    80006916:	1d02                	slli	s10,s10,0x20
    80006918:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk[n].vdisk_lock);
    8000691c:	00151493          	slli	s1,a0,0x1
    80006920:	94aa                	add	s1,s1,a0
    80006922:	04b2                	slli	s1,s1,0xc
    80006924:	6a89                	lui	s5,0x2
    80006926:	0b0a8993          	addi	s3,s5,176 # 20b0 <_entry-0x7fffdf50>
    8000692a:	99a6                	add	s3,s3,s1
    8000692c:	00021c17          	auipc	s8,0x21
    80006930:	6d4c0c13          	addi	s8,s8,1748 # 80028000 <disk>
    80006934:	99e2                	add	s3,s3,s8
    80006936:	854e                	mv	a0,s3
    80006938:	ffffa097          	auipc	ra,0xffffa
    8000693c:	382080e7          	jalr	898(ra) # 80000cba <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006940:	018a8b93          	addi	s7,s5,24
    80006944:	9ba6                	add	s7,s7,s1
    80006946:	9be2                	add	s7,s7,s8
    80006948:	0ae5                	addi	s5,s5,25
    8000694a:	94d6                	add	s1,s1,s5
    8000694c:	01848ab3          	add	s5,s1,s8
    if(disk[n].free[i]){
    80006950:	00191b13          	slli	s6,s2,0x1
    80006954:	9b4a                	add	s6,s6,s2
    80006956:	00cb1793          	slli	a5,s6,0xc
    8000695a:	00fc0b33          	add	s6,s8,a5
    8000695e:	6c89                	lui	s9,0x2
    80006960:	016c8c33          	add	s8,s9,s6
    80006964:	a049                	j	800069e6 <virtio_disk_rw+0xfc>
      disk[n].free[i] = 0;
    80006966:	00fb06b3          	add	a3,s6,a5
    8000696a:	96e6                	add	a3,a3,s9
    8000696c:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    80006970:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006972:	0207c763          	bltz	a5,800069a0 <virtio_disk_rw+0xb6>
  for(int i = 0; i < 3; i++){
    80006976:	2485                	addiw	s1,s1,1
    80006978:	0711                	addi	a4,a4,4
    8000697a:	28b48063          	beq	s1,a1,80006bfa <virtio_disk_rw+0x310>
    idx[i] = alloc_desc(n);
    8000697e:	863a                	mv	a2,a4
    if(disk[n].free[i]){
    80006980:	018c4783          	lbu	a5,24(s8)
    80006984:	28079063          	bnez	a5,80006c04 <virtio_disk_rw+0x31a>
    80006988:	86d6                	mv	a3,s5
  for(int i = 0; i < NUM; i++){
    8000698a:	87c2                	mv	a5,a6
    if(disk[n].free[i]){
    8000698c:	0006c883          	lbu	a7,0(a3)
    80006990:	fc089be3          	bnez	a7,80006966 <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    80006994:	2785                	addiw	a5,a5,1
    80006996:	0685                	addi	a3,a3,1
    80006998:	fea79ae3          	bne	a5,a0,8000698c <virtio_disk_rw+0xa2>
    idx[i] = alloc_desc(n);
    8000699c:	57fd                	li	a5,-1
    8000699e:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800069a0:	02905d63          	blez	s1,800069da <virtio_disk_rw+0xf0>
        free_desc(n, idx[j]);
    800069a4:	f8042583          	lw	a1,-128(s0)
    800069a8:	854a                	mv	a0,s2
    800069aa:	00000097          	auipc	ra,0x0
    800069ae:	cbc080e7          	jalr	-836(ra) # 80006666 <free_desc>
      for(int j = 0; j < i; j++)
    800069b2:	4785                	li	a5,1
    800069b4:	0297d363          	ble	s1,a5,800069da <virtio_disk_rw+0xf0>
        free_desc(n, idx[j]);
    800069b8:	f8442583          	lw	a1,-124(s0)
    800069bc:	854a                	mv	a0,s2
    800069be:	00000097          	auipc	ra,0x0
    800069c2:	ca8080e7          	jalr	-856(ra) # 80006666 <free_desc>
      for(int j = 0; j < i; j++)
    800069c6:	4789                	li	a5,2
    800069c8:	0097d963          	ble	s1,a5,800069da <virtio_disk_rw+0xf0>
        free_desc(n, idx[j]);
    800069cc:	f8842583          	lw	a1,-120(s0)
    800069d0:	854a                	mv	a0,s2
    800069d2:	00000097          	auipc	ra,0x0
    800069d6:	c94080e7          	jalr	-876(ra) # 80006666 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800069da:	85ce                	mv	a1,s3
    800069dc:	855e                	mv	a0,s7
    800069de:	ffffc097          	auipc	ra,0xffffc
    800069e2:	e66080e7          	jalr	-410(ra) # 80002844 <sleep>
  for(int i = 0; i < 3; i++){
    800069e6:	f8040713          	addi	a4,s0,-128
    800069ea:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    800069ec:	4805                	li	a6,1
    800069ee:	4521                	li	a0,8
  for(int i = 0; i < 3; i++){
    800069f0:	458d                	li	a1,3
    800069f2:	b771                	j	8000697e <virtio_disk_rw+0x94>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    800069f4:	4785                	li	a5,1
    800069f6:	f6f42823          	sw	a5,-144(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    800069fa:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    800069fe:	f7a43c23          	sd	s10,-136(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006a02:	f8042483          	lw	s1,-128(s0)
    80006a06:	00449b13          	slli	s6,s1,0x4
    80006a0a:	00191793          	slli	a5,s2,0x1
    80006a0e:	97ca                	add	a5,a5,s2
    80006a10:	07b2                	slli	a5,a5,0xc
    80006a12:	00021a97          	auipc	s5,0x21
    80006a16:	5eea8a93          	addi	s5,s5,1518 # 80028000 <disk>
    80006a1a:	97d6                	add	a5,a5,s5
    80006a1c:	6a89                	lui	s5,0x2
    80006a1e:	9abe                	add	s5,s5,a5
    80006a20:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    80006a24:	9bda                	add	s7,s7,s6
    80006a26:	f7040513          	addi	a0,s0,-144
    80006a2a:	ffffb097          	auipc	ra,0xffffb
    80006a2e:	c52080e7          	jalr	-942(ra) # 8000167c <kvmpa>
    80006a32:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006a36:	000ab783          	ld	a5,0(s5)
    80006a3a:	97da                	add	a5,a5,s6
    80006a3c:	4741                	li	a4,16
    80006a3e:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006a40:	000ab783          	ld	a5,0(s5)
    80006a44:	97da                	add	a5,a5,s6
    80006a46:	4705                	li	a4,1
    80006a48:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006a4c:	f8442603          	lw	a2,-124(s0)
    80006a50:	000ab783          	ld	a5,0(s5)
    80006a54:	9b3e                	add	s6,s6,a5
    80006a56:	00cb1723          	sh	a2,14(s6) # fffffffffffff00e <end+0xffffffff7ffd0f62>

  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006a5a:	0612                	slli	a2,a2,0x4
    80006a5c:	000ab783          	ld	a5,0(s5)
    80006a60:	97b2                	add	a5,a5,a2
    80006a62:	070a0713          	addi	a4,s4,112
    80006a66:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006a68:	000ab783          	ld	a5,0(s5)
    80006a6c:	97b2                	add	a5,a5,a2
    80006a6e:	40000713          	li	a4,1024
    80006a72:	c798                	sw	a4,8(a5)
  if(write)
    80006a74:	120d8e63          	beqz	s11,80006bb0 <virtio_disk_rw+0x2c6>
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006a78:	000ab783          	ld	a5,0(s5)
    80006a7c:	97b2                	add	a5,a5,a2
    80006a7e:	00079623          	sh	zero,12(a5)
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006a82:	00021517          	auipc	a0,0x21
    80006a86:	57e50513          	addi	a0,a0,1406 # 80028000 <disk>
    80006a8a:	00191793          	slli	a5,s2,0x1
    80006a8e:	012786b3          	add	a3,a5,s2
    80006a92:	06b2                	slli	a3,a3,0xc
    80006a94:	96aa                	add	a3,a3,a0
    80006a96:	6709                	lui	a4,0x2
    80006a98:	96ba                	add	a3,a3,a4
    80006a9a:	628c                	ld	a1,0(a3)
    80006a9c:	95b2                	add	a1,a1,a2
    80006a9e:	00c5d703          	lhu	a4,12(a1)
    80006aa2:	00176713          	ori	a4,a4,1
    80006aa6:	00e59623          	sh	a4,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    80006aaa:	f8842583          	lw	a1,-120(s0)
    80006aae:	6298                	ld	a4,0(a3)
    80006ab0:	963a                	add	a2,a2,a4
    80006ab2:	00b61723          	sh	a1,14(a2) # 200e <_entry-0x7fffdff2>

  disk[n].info[idx[0]].status = 0;
    80006ab6:	97ca                	add	a5,a5,s2
    80006ab8:	07a2                	slli	a5,a5,0x8
    80006aba:	97a6                	add	a5,a5,s1
    80006abc:	20078793          	addi	a5,a5,512
    80006ac0:	0792                	slli	a5,a5,0x4
    80006ac2:	97aa                	add	a5,a5,a0
    80006ac4:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006ac8:	00459613          	slli	a2,a1,0x4
    80006acc:	628c                	ld	a1,0(a3)
    80006ace:	95b2                	add	a1,a1,a2
    80006ad0:	00191713          	slli	a4,s2,0x1
    80006ad4:	974a                	add	a4,a4,s2
    80006ad6:	0722                	slli	a4,a4,0x8
    80006ad8:	20348813          	addi	a6,s1,515
    80006adc:	9742                	add	a4,a4,a6
    80006ade:	0712                	slli	a4,a4,0x4
    80006ae0:	972a                	add	a4,a4,a0
    80006ae2:	e198                	sd	a4,0(a1)
  disk[n].desc[idx[2]].len = 1;
    80006ae4:	6298                	ld	a4,0(a3)
    80006ae6:	9732                	add	a4,a4,a2
    80006ae8:	4585                	li	a1,1
    80006aea:	c70c                	sw	a1,8(a4)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006aec:	6298                	ld	a4,0(a3)
    80006aee:	9732                	add	a4,a4,a2
    80006af0:	4509                	li	a0,2
    80006af2:	00a71623          	sh	a0,12(a4) # 200c <_entry-0x7fffdff4>
  disk[n].desc[idx[2]].next = 0;
    80006af6:	6298                	ld	a4,0(a3)
    80006af8:	963a                	add	a2,a2,a4
    80006afa:	00061723          	sh	zero,14(a2)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006afe:	00ba2223          	sw	a1,4(s4)
  disk[n].info[idx[0]].b = b;
    80006b02:	0347b423          	sd	s4,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    80006b06:	6698                	ld	a4,8(a3)
    80006b08:	00275783          	lhu	a5,2(a4)
    80006b0c:	8b9d                	andi	a5,a5,7
    80006b0e:	0789                	addi	a5,a5,2
    80006b10:	0786                	slli	a5,a5,0x1
    80006b12:	97ba                	add	a5,a5,a4
    80006b14:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80006b18:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006b1c:	6698                	ld	a4,8(a3)
    80006b1e:	00275783          	lhu	a5,2(a4)
    80006b22:	2785                	addiw	a5,a5,1
    80006b24:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006b28:	0019079b          	addiw	a5,s2,1
    80006b2c:	00c7979b          	slliw	a5,a5,0xc
    80006b30:	10000737          	lui	a4,0x10000
    80006b34:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    80006b38:	97ba                	add	a5,a5,a4
    80006b3a:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006b3e:	004a2703          	lw	a4,4(s4)
    80006b42:	4785                	li	a5,1
    80006b44:	00f71d63          	bne	a4,a5,80006b5e <virtio_disk_rw+0x274>
    80006b48:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    80006b4a:	85ce                	mv	a1,s3
    80006b4c:	8552                	mv	a0,s4
    80006b4e:	ffffc097          	auipc	ra,0xffffc
    80006b52:	cf6080e7          	jalr	-778(ra) # 80002844 <sleep>
  while(b->disk == 1) {
    80006b56:	004a2783          	lw	a5,4(s4)
    80006b5a:	fe9788e3          	beq	a5,s1,80006b4a <virtio_disk_rw+0x260>
  }

  disk[n].info[idx[0]].b = 0;
    80006b5e:	f8042483          	lw	s1,-128(s0)
    80006b62:	00191793          	slli	a5,s2,0x1
    80006b66:	97ca                	add	a5,a5,s2
    80006b68:	07a2                	slli	a5,a5,0x8
    80006b6a:	97a6                	add	a5,a5,s1
    80006b6c:	20078793          	addi	a5,a5,512
    80006b70:	0792                	slli	a5,a5,0x4
    80006b72:	00021717          	auipc	a4,0x21
    80006b76:	48e70713          	addi	a4,a4,1166 # 80028000 <disk>
    80006b7a:	97ba                	add	a5,a5,a4
    80006b7c:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006b80:	00191793          	slli	a5,s2,0x1
    80006b84:	97ca                	add	a5,a5,s2
    80006b86:	07b2                	slli	a5,a5,0xc
    80006b88:	97ba                	add	a5,a5,a4
    80006b8a:	6a09                	lui	s4,0x2
    80006b8c:	9a3e                	add	s4,s4,a5
    free_desc(n, i);
    80006b8e:	85a6                	mv	a1,s1
    80006b90:	854a                	mv	a0,s2
    80006b92:	00000097          	auipc	ra,0x0
    80006b96:	ad4080e7          	jalr	-1324(ra) # 80006666 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006b9a:	0492                	slli	s1,s1,0x4
    80006b9c:	000a3783          	ld	a5,0(s4) # 2000 <_entry-0x7fffe000>
    80006ba0:	94be                	add	s1,s1,a5
    80006ba2:	00c4d783          	lhu	a5,12(s1)
    80006ba6:	8b85                	andi	a5,a5,1
    80006ba8:	c78d                	beqz	a5,80006bd2 <virtio_disk_rw+0x2e8>
      i = disk[n].desc[i].next;
    80006baa:	00e4d483          	lhu	s1,14(s1)
    80006bae:	b7c5                	j	80006b8e <virtio_disk_rw+0x2a4>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006bb0:	00191793          	slli	a5,s2,0x1
    80006bb4:	97ca                	add	a5,a5,s2
    80006bb6:	07b2                	slli	a5,a5,0xc
    80006bb8:	00021717          	auipc	a4,0x21
    80006bbc:	44870713          	addi	a4,a4,1096 # 80028000 <disk>
    80006bc0:	973e                	add	a4,a4,a5
    80006bc2:	6789                	lui	a5,0x2
    80006bc4:	97ba                	add	a5,a5,a4
    80006bc6:	639c                	ld	a5,0(a5)
    80006bc8:	97b2                	add	a5,a5,a2
    80006bca:	4709                	li	a4,2
    80006bcc:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006bd0:	bd4d                	j	80006a82 <virtio_disk_rw+0x198>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006bd2:	854e                	mv	a0,s3
    80006bd4:	ffffa097          	auipc	ra,0xffffa
    80006bd8:	332080e7          	jalr	818(ra) # 80000f06 <release>
}
    80006bdc:	60aa                	ld	ra,136(sp)
    80006bde:	640a                	ld	s0,128(sp)
    80006be0:	74e6                	ld	s1,120(sp)
    80006be2:	7946                	ld	s2,112(sp)
    80006be4:	79a6                	ld	s3,104(sp)
    80006be6:	7a06                	ld	s4,96(sp)
    80006be8:	6ae6                	ld	s5,88(sp)
    80006bea:	6b46                	ld	s6,80(sp)
    80006bec:	6ba6                	ld	s7,72(sp)
    80006bee:	6c06                	ld	s8,64(sp)
    80006bf0:	7ce2                	ld	s9,56(sp)
    80006bf2:	7d42                	ld	s10,48(sp)
    80006bf4:	7da2                	ld	s11,40(sp)
    80006bf6:	6149                	addi	sp,sp,144
    80006bf8:	8082                	ret
  if(write)
    80006bfa:	de0d9de3          	bnez	s11,800069f4 <virtio_disk_rw+0x10a>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006bfe:	f6042823          	sw	zero,-144(s0)
    80006c02:	bbe5                	j	800069fa <virtio_disk_rw+0x110>
      disk[n].free[i] = 0;
    80006c04:	000c0c23          	sb	zero,24(s8)
    idx[i] = alloc_desc(n);
    80006c08:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    80006c0c:	b3ad                	j	80006976 <virtio_disk_rw+0x8c>

0000000080006c0e <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006c0e:	7139                	addi	sp,sp,-64
    80006c10:	fc06                	sd	ra,56(sp)
    80006c12:	f822                	sd	s0,48(sp)
    80006c14:	f426                	sd	s1,40(sp)
    80006c16:	f04a                	sd	s2,32(sp)
    80006c18:	ec4e                	sd	s3,24(sp)
    80006c1a:	e852                	sd	s4,16(sp)
    80006c1c:	e456                	sd	s5,8(sp)
    80006c1e:	0080                	addi	s0,sp,64
    80006c20:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006c22:	00151913          	slli	s2,a0,0x1
    80006c26:	00a90a33          	add	s4,s2,a0
    80006c2a:	0a32                	slli	s4,s4,0xc
    80006c2c:	6989                	lui	s3,0x2
    80006c2e:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006c32:	9a3e                	add	s4,s4,a5
    80006c34:	00021a97          	auipc	s5,0x21
    80006c38:	3cca8a93          	addi	s5,s5,972 # 80028000 <disk>
    80006c3c:	9a56                	add	s4,s4,s5
    80006c3e:	8552                	mv	a0,s4
    80006c40:	ffffa097          	auipc	ra,0xffffa
    80006c44:	07a080e7          	jalr	122(ra) # 80000cba <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006c48:	9926                	add	s2,s2,s1
    80006c4a:	0932                	slli	s2,s2,0xc
    80006c4c:	9956                	add	s2,s2,s5
    80006c4e:	99ca                	add	s3,s3,s2
    80006c50:	0209d683          	lhu	a3,32(s3)
    80006c54:	0109b703          	ld	a4,16(s3)
    80006c58:	00275783          	lhu	a5,2(a4)
    80006c5c:	8fb5                	xor	a5,a5,a3
    80006c5e:	8b9d                	andi	a5,a5,7
    80006c60:	cbd1                	beqz	a5,80006cf4 <virtio_disk_intr+0xe6>
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006c62:	068e                	slli	a3,a3,0x3
    80006c64:	9736                	add	a4,a4,a3
    80006c66:	435c                	lw	a5,4(a4)

    if(disk[n].info[id].status != 0)
    80006c68:	00149713          	slli	a4,s1,0x1
    80006c6c:	9726                	add	a4,a4,s1
    80006c6e:	0722                	slli	a4,a4,0x8
    80006c70:	973e                	add	a4,a4,a5
    80006c72:	20070713          	addi	a4,a4,512
    80006c76:	0712                	slli	a4,a4,0x4
    80006c78:	9756                	add	a4,a4,s5
    80006c7a:	03074703          	lbu	a4,48(a4)
    80006c7e:	e33d                	bnez	a4,80006ce4 <virtio_disk_intr+0xd6>
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006c80:	8956                	mv	s2,s5
    80006c82:	00149713          	slli	a4,s1,0x1
    80006c86:	9726                	add	a4,a4,s1
    80006c88:	00871993          	slli	s3,a4,0x8
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006c8c:	0732                	slli	a4,a4,0xc
    80006c8e:	9756                	add	a4,a4,s5
    80006c90:	6489                	lui	s1,0x2
    80006c92:	94ba                	add	s1,s1,a4
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006c94:	97ce                	add	a5,a5,s3
    80006c96:	20078793          	addi	a5,a5,512
    80006c9a:	0792                	slli	a5,a5,0x4
    80006c9c:	97ca                	add	a5,a5,s2
    80006c9e:	7798                	ld	a4,40(a5)
    80006ca0:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006ca4:	7788                	ld	a0,40(a5)
    80006ca6:	ffffc097          	auipc	ra,0xffffc
    80006caa:	d24080e7          	jalr	-732(ra) # 800029ca <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006cae:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006cb2:	2785                	addiw	a5,a5,1
    80006cb4:	8b9d                	andi	a5,a5,7
    80006cb6:	03079613          	slli	a2,a5,0x30
    80006cba:	9241                	srli	a2,a2,0x30
    80006cbc:	02c49023          	sh	a2,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006cc0:	6898                	ld	a4,16(s1)
    80006cc2:	00275683          	lhu	a3,2(a4)
    80006cc6:	8a9d                	andi	a3,a3,7
    80006cc8:	02c68663          	beq	a3,a2,80006cf4 <virtio_disk_intr+0xe6>
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006ccc:	078e                	slli	a5,a5,0x3
    80006cce:	97ba                	add	a5,a5,a4
    80006cd0:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006cd2:	00f98733          	add	a4,s3,a5
    80006cd6:	20070713          	addi	a4,a4,512
    80006cda:	0712                	slli	a4,a4,0x4
    80006cdc:	974a                	add	a4,a4,s2
    80006cde:	03074703          	lbu	a4,48(a4)
    80006ce2:	db4d                	beqz	a4,80006c94 <virtio_disk_intr+0x86>
      panic("virtio_disk_intr status");
    80006ce4:	00002517          	auipc	a0,0x2
    80006ce8:	0ac50513          	addi	a0,a0,172 # 80008d90 <userret+0xd00>
    80006cec:	ffffa097          	auipc	ra,0xffffa
    80006cf0:	a98080e7          	jalr	-1384(ra) # 80000784 <panic>
  }

  release(&disk[n].vdisk_lock);
    80006cf4:	8552                	mv	a0,s4
    80006cf6:	ffffa097          	auipc	ra,0xffffa
    80006cfa:	210080e7          	jalr	528(ra) # 80000f06 <release>
}
    80006cfe:	70e2                	ld	ra,56(sp)
    80006d00:	7442                	ld	s0,48(sp)
    80006d02:	74a2                	ld	s1,40(sp)
    80006d04:	7902                	ld	s2,32(sp)
    80006d06:	69e2                	ld	s3,24(sp)
    80006d08:	6a42                	ld	s4,16(sp)
    80006d0a:	6aa2                	ld	s5,8(sp)
    80006d0c:	6121                	addi	sp,sp,64
    80006d0e:	8082                	ret

0000000080006d10 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006d10:	1141                	addi	sp,sp,-16
    80006d12:	e422                	sd	s0,8(sp)
    80006d14:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80006d16:	41f5d79b          	sraiw	a5,a1,0x1f
    80006d1a:	01d7d79b          	srliw	a5,a5,0x1d
    80006d1e:	9dbd                	addw	a1,a1,a5
    80006d20:	0075f713          	andi	a4,a1,7
    80006d24:	9f1d                	subw	a4,a4,a5
    80006d26:	4785                	li	a5,1
    80006d28:	00e797bb          	sllw	a5,a5,a4
    80006d2c:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80006d30:	4035d59b          	sraiw	a1,a1,0x3
    80006d34:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006d36:	0005c503          	lbu	a0,0(a1)
    80006d3a:	8d7d                	and	a0,a0,a5
    80006d3c:	8d1d                	sub	a0,a0,a5
}
    80006d3e:	00153513          	seqz	a0,a0
    80006d42:	6422                	ld	s0,8(sp)
    80006d44:	0141                	addi	sp,sp,16
    80006d46:	8082                	ret

0000000080006d48 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006d48:	1141                	addi	sp,sp,-16
    80006d4a:	e422                	sd	s0,8(sp)
    80006d4c:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006d4e:	41f5d71b          	sraiw	a4,a1,0x1f
    80006d52:	01d7571b          	srliw	a4,a4,0x1d
    80006d56:	9db9                	addw	a1,a1,a4
    80006d58:	4035d79b          	sraiw	a5,a1,0x3
    80006d5c:	953e                	add	a0,a0,a5
  char m = (1 << (index % 8));
    80006d5e:	899d                	andi	a1,a1,7
    80006d60:	9d99                	subw	a1,a1,a4
  array[index/8] = (b | m);
    80006d62:	4785                	li	a5,1
    80006d64:	00b795bb          	sllw	a1,a5,a1
    80006d68:	00054783          	lbu	a5,0(a0)
    80006d6c:	8ddd                	or	a1,a1,a5
    80006d6e:	00b50023          	sb	a1,0(a0)
}
    80006d72:	6422                	ld	s0,8(sp)
    80006d74:	0141                	addi	sp,sp,16
    80006d76:	8082                	ret

0000000080006d78 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006d78:	1141                	addi	sp,sp,-16
    80006d7a:	e422                	sd	s0,8(sp)
    80006d7c:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006d7e:	41f5d71b          	sraiw	a4,a1,0x1f
    80006d82:	01d7571b          	srliw	a4,a4,0x1d
    80006d86:	9db9                	addw	a1,a1,a4
    80006d88:	4035d79b          	sraiw	a5,a1,0x3
    80006d8c:	953e                	add	a0,a0,a5
  char m = (1 << (index % 8));
    80006d8e:	899d                	andi	a1,a1,7
    80006d90:	9d99                	subw	a1,a1,a4
  array[index/8] = (b & ~m);
    80006d92:	4785                	li	a5,1
    80006d94:	00b795bb          	sllw	a1,a5,a1
    80006d98:	fff5c593          	not	a1,a1
    80006d9c:	00054783          	lbu	a5,0(a0)
    80006da0:	8dfd                	and	a1,a1,a5
    80006da2:	00b50023          	sb	a1,0(a0)
}
    80006da6:	6422                	ld	s0,8(sp)
    80006da8:	0141                	addi	sp,sp,16
    80006daa:	8082                	ret

0000000080006dac <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006dac:	715d                	addi	sp,sp,-80
    80006dae:	e486                	sd	ra,72(sp)
    80006db0:	e0a2                	sd	s0,64(sp)
    80006db2:	fc26                	sd	s1,56(sp)
    80006db4:	f84a                	sd	s2,48(sp)
    80006db6:	f44e                	sd	s3,40(sp)
    80006db8:	f052                	sd	s4,32(sp)
    80006dba:	ec56                	sd	s5,24(sp)
    80006dbc:	e85a                	sd	s6,16(sp)
    80006dbe:	e45e                	sd	s7,8(sp)
    80006dc0:	0880                	addi	s0,sp,80
    80006dc2:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006dc4:	08b05b63          	blez	a1,80006e5a <bd_print_vector+0xae>
    80006dc8:	89aa                	mv	s3,a0
    80006dca:	4481                	li	s1,0
  lb = 0;
    80006dcc:	4a81                	li	s5,0
  last = 1;
    80006dce:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006dd0:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006dd2:	00002b97          	auipc	s7,0x2
    80006dd6:	fd6b8b93          	addi	s7,s7,-42 # 80008da8 <userret+0xd18>
    80006dda:	a01d                	j	80006e00 <bd_print_vector+0x54>
    80006ddc:	8626                	mv	a2,s1
    80006dde:	85d6                	mv	a1,s5
    80006de0:	855e                	mv	a0,s7
    80006de2:	ffffa097          	auipc	ra,0xffffa
    80006de6:	bba080e7          	jalr	-1094(ra) # 8000099c <printf>
    lb = b;
    last = bit_isset(vector, b);
    80006dea:	85a6                	mv	a1,s1
    80006dec:	854e                	mv	a0,s3
    80006dee:	00000097          	auipc	ra,0x0
    80006df2:	f22080e7          	jalr	-222(ra) # 80006d10 <bit_isset>
    80006df6:	892a                	mv	s2,a0
    80006df8:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006dfa:	2485                	addiw	s1,s1,1
    80006dfc:	009a0d63          	beq	s4,s1,80006e16 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006e00:	85a6                	mv	a1,s1
    80006e02:	854e                	mv	a0,s3
    80006e04:	00000097          	auipc	ra,0x0
    80006e08:	f0c080e7          	jalr	-244(ra) # 80006d10 <bit_isset>
    80006e0c:	ff2507e3          	beq	a0,s2,80006dfa <bd_print_vector+0x4e>
    if(last == 1)
    80006e10:	fd691de3          	bne	s2,s6,80006dea <bd_print_vector+0x3e>
    80006e14:	b7e1                	j	80006ddc <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80006e16:	000a8563          	beqz	s5,80006e20 <bd_print_vector+0x74>
    80006e1a:	4785                	li	a5,1
    80006e1c:	00f91c63          	bne	s2,a5,80006e34 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006e20:	8652                	mv	a2,s4
    80006e22:	85d6                	mv	a1,s5
    80006e24:	00002517          	auipc	a0,0x2
    80006e28:	f8450513          	addi	a0,a0,-124 # 80008da8 <userret+0xd18>
    80006e2c:	ffffa097          	auipc	ra,0xffffa
    80006e30:	b70080e7          	jalr	-1168(ra) # 8000099c <printf>
  }
  printf("\n");
    80006e34:	00002517          	auipc	a0,0x2
    80006e38:	81450513          	addi	a0,a0,-2028 # 80008648 <userret+0x5b8>
    80006e3c:	ffffa097          	auipc	ra,0xffffa
    80006e40:	b60080e7          	jalr	-1184(ra) # 8000099c <printf>
}
    80006e44:	60a6                	ld	ra,72(sp)
    80006e46:	6406                	ld	s0,64(sp)
    80006e48:	74e2                	ld	s1,56(sp)
    80006e4a:	7942                	ld	s2,48(sp)
    80006e4c:	79a2                	ld	s3,40(sp)
    80006e4e:	7a02                	ld	s4,32(sp)
    80006e50:	6ae2                	ld	s5,24(sp)
    80006e52:	6b42                	ld	s6,16(sp)
    80006e54:	6ba2                	ld	s7,8(sp)
    80006e56:	6161                	addi	sp,sp,80
    80006e58:	8082                	ret
  lb = 0;
    80006e5a:	4a81                	li	s5,0
    80006e5c:	b7d1                	j	80006e20 <bd_print_vector+0x74>

0000000080006e5e <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006e5e:	00027797          	auipc	a5,0x27
    80006e62:	24278793          	addi	a5,a5,578 # 8002e0a0 <nsizes>
    80006e66:	4394                	lw	a3,0(a5)
    80006e68:	0ed05b63          	blez	a3,80006f5e <bd_print+0x100>
bd_print() {
    80006e6c:	711d                	addi	sp,sp,-96
    80006e6e:	ec86                	sd	ra,88(sp)
    80006e70:	e8a2                	sd	s0,80(sp)
    80006e72:	e4a6                	sd	s1,72(sp)
    80006e74:	e0ca                	sd	s2,64(sp)
    80006e76:	fc4e                	sd	s3,56(sp)
    80006e78:	f852                	sd	s4,48(sp)
    80006e7a:	f456                	sd	s5,40(sp)
    80006e7c:	f05a                	sd	s6,32(sp)
    80006e7e:	ec5e                	sd	s7,24(sp)
    80006e80:	e862                	sd	s8,16(sp)
    80006e82:	e466                	sd	s9,8(sp)
    80006e84:	e06a                	sd	s10,0(sp)
    80006e86:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80006e88:	4901                	li	s2,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006e8a:	4a85                	li	s5,1
    80006e8c:	4c41                	li	s8,16
    80006e8e:	00002b97          	auipc	s7,0x2
    80006e92:	f2ab8b93          	addi	s7,s7,-214 # 80008db8 <userret+0xd28>
    lst_print(&bd_sizes[k].free);
    80006e96:	00027a17          	auipc	s4,0x27
    80006e9a:	202a0a13          	addi	s4,s4,514 # 8002e098 <bd_sizes>
    printf("  alloc:");
    80006e9e:	00002b17          	auipc	s6,0x2
    80006ea2:	f42b0b13          	addi	s6,s6,-190 # 80008de0 <userret+0xd50>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006ea6:	89be                	mv	s3,a5
    if(k > 0) {
      printf("  split:");
    80006ea8:	00002c97          	auipc	s9,0x2
    80006eac:	f48c8c93          	addi	s9,s9,-184 # 80008df0 <userret+0xd60>
    80006eb0:	a801                	j	80006ec0 <bd_print+0x62>
  for (int k = 0; k < nsizes; k++) {
    80006eb2:	0009a683          	lw	a3,0(s3)
    80006eb6:	0905                	addi	s2,s2,1
    80006eb8:	0009079b          	sext.w	a5,s2
    80006ebc:	08d7d363          	ble	a3,a5,80006f42 <bd_print+0xe4>
    80006ec0:	0009049b          	sext.w	s1,s2
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006ec4:	36fd                	addiw	a3,a3,-1
    80006ec6:	9e85                	subw	a3,a3,s1
    80006ec8:	00da96bb          	sllw	a3,s5,a3
    80006ecc:	009c1633          	sll	a2,s8,s1
    80006ed0:	85a6                	mv	a1,s1
    80006ed2:	855e                	mv	a0,s7
    80006ed4:	ffffa097          	auipc	ra,0xffffa
    80006ed8:	ac8080e7          	jalr	-1336(ra) # 8000099c <printf>
    lst_print(&bd_sizes[k].free);
    80006edc:	00591d13          	slli	s10,s2,0x5
    80006ee0:	000a3503          	ld	a0,0(s4)
    80006ee4:	956a                	add	a0,a0,s10
    80006ee6:	00001097          	auipc	ra,0x1
    80006eea:	a80080e7          	jalr	-1408(ra) # 80007966 <lst_print>
    printf("  alloc:");
    80006eee:	855a                	mv	a0,s6
    80006ef0:	ffffa097          	auipc	ra,0xffffa
    80006ef4:	aac080e7          	jalr	-1364(ra) # 8000099c <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006ef8:	0009a583          	lw	a1,0(s3)
    80006efc:	35fd                	addiw	a1,a1,-1
    80006efe:	9d85                	subw	a1,a1,s1
    80006f00:	000a3783          	ld	a5,0(s4)
    80006f04:	97ea                	add	a5,a5,s10
    80006f06:	00ba95bb          	sllw	a1,s5,a1
    80006f0a:	6b88                	ld	a0,16(a5)
    80006f0c:	00000097          	auipc	ra,0x0
    80006f10:	ea0080e7          	jalr	-352(ra) # 80006dac <bd_print_vector>
    if(k > 0) {
    80006f14:	f8905fe3          	blez	s1,80006eb2 <bd_print+0x54>
      printf("  split:");
    80006f18:	8566                	mv	a0,s9
    80006f1a:	ffffa097          	auipc	ra,0xffffa
    80006f1e:	a82080e7          	jalr	-1406(ra) # 8000099c <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006f22:	0009a583          	lw	a1,0(s3)
    80006f26:	35fd                	addiw	a1,a1,-1
    80006f28:	9d85                	subw	a1,a1,s1
    80006f2a:	000a3783          	ld	a5,0(s4)
    80006f2e:	9d3e                	add	s10,s10,a5
    80006f30:	00ba95bb          	sllw	a1,s5,a1
    80006f34:	018d3503          	ld	a0,24(s10) # 1018 <_entry-0x7fffefe8>
    80006f38:	00000097          	auipc	ra,0x0
    80006f3c:	e74080e7          	jalr	-396(ra) # 80006dac <bd_print_vector>
    80006f40:	bf8d                	j	80006eb2 <bd_print+0x54>
    }
  }
}
    80006f42:	60e6                	ld	ra,88(sp)
    80006f44:	6446                	ld	s0,80(sp)
    80006f46:	64a6                	ld	s1,72(sp)
    80006f48:	6906                	ld	s2,64(sp)
    80006f4a:	79e2                	ld	s3,56(sp)
    80006f4c:	7a42                	ld	s4,48(sp)
    80006f4e:	7aa2                	ld	s5,40(sp)
    80006f50:	7b02                	ld	s6,32(sp)
    80006f52:	6be2                	ld	s7,24(sp)
    80006f54:	6c42                	ld	s8,16(sp)
    80006f56:	6ca2                	ld	s9,8(sp)
    80006f58:	6d02                	ld	s10,0(sp)
    80006f5a:	6125                	addi	sp,sp,96
    80006f5c:	8082                	ret
    80006f5e:	8082                	ret

0000000080006f60 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006f60:	1141                	addi	sp,sp,-16
    80006f62:	e422                	sd	s0,8(sp)
    80006f64:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006f66:	47c1                	li	a5,16
    80006f68:	00a7fb63          	bleu	a0,a5,80006f7e <firstk+0x1e>
  int k = 0;
    80006f6c:	4701                	li	a4,0
    k++;
    80006f6e:	2705                	addiw	a4,a4,1
    size *= 2;
    80006f70:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006f72:	fea7eee3          	bltu	a5,a0,80006f6e <firstk+0xe>
  }
  return k;
}
    80006f76:	853a                	mv	a0,a4
    80006f78:	6422                	ld	s0,8(sp)
    80006f7a:	0141                	addi	sp,sp,16
    80006f7c:	8082                	ret
  int k = 0;
    80006f7e:	4701                	li	a4,0
    80006f80:	bfdd                	j	80006f76 <firstk+0x16>

0000000080006f82 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006f82:	1141                	addi	sp,sp,-16
    80006f84:	e422                	sd	s0,8(sp)
    80006f86:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
    80006f88:	00027797          	auipc	a5,0x27
    80006f8c:	10878793          	addi	a5,a5,264 # 8002e090 <bd_base>
    80006f90:	639c                	ld	a5,0(a5)
  return n / BLK_SIZE(k);
    80006f92:	9d9d                	subw	a1,a1,a5
    80006f94:	47c1                	li	a5,16
    80006f96:	00a79533          	sll	a0,a5,a0
    80006f9a:	02a5c533          	div	a0,a1,a0
}
    80006f9e:	2501                	sext.w	a0,a0
    80006fa0:	6422                	ld	s0,8(sp)
    80006fa2:	0141                	addi	sp,sp,16
    80006fa4:	8082                	ret

0000000080006fa6 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006fa6:	1141                	addi	sp,sp,-16
    80006fa8:	e422                	sd	s0,8(sp)
    80006faa:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006fac:	47c1                	li	a5,16
    80006fae:	00a79533          	sll	a0,a5,a0
  return (char *) bd_base + n;
    80006fb2:	02a5853b          	mulw	a0,a1,a0
    80006fb6:	00027797          	auipc	a5,0x27
    80006fba:	0da78793          	addi	a5,a5,218 # 8002e090 <bd_base>
    80006fbe:	639c                	ld	a5,0(a5)
}
    80006fc0:	953e                	add	a0,a0,a5
    80006fc2:	6422                	ld	s0,8(sp)
    80006fc4:	0141                	addi	sp,sp,16
    80006fc6:	8082                	ret

0000000080006fc8 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006fc8:	7159                	addi	sp,sp,-112
    80006fca:	f486                	sd	ra,104(sp)
    80006fcc:	f0a2                	sd	s0,96(sp)
    80006fce:	eca6                	sd	s1,88(sp)
    80006fd0:	e8ca                	sd	s2,80(sp)
    80006fd2:	e4ce                	sd	s3,72(sp)
    80006fd4:	e0d2                	sd	s4,64(sp)
    80006fd6:	fc56                	sd	s5,56(sp)
    80006fd8:	f85a                	sd	s6,48(sp)
    80006fda:	f45e                	sd	s7,40(sp)
    80006fdc:	f062                	sd	s8,32(sp)
    80006fde:	ec66                	sd	s9,24(sp)
    80006fe0:	e86a                	sd	s10,16(sp)
    80006fe2:	e46e                	sd	s11,8(sp)
    80006fe4:	1880                	addi	s0,sp,112
    80006fe6:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006fe8:	00027517          	auipc	a0,0x27
    80006fec:	01850513          	addi	a0,a0,24 # 8002e000 <lock>
    80006ff0:	ffffa097          	auipc	ra,0xffffa
    80006ff4:	cca080e7          	jalr	-822(ra) # 80000cba <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006ff8:	8526                	mv	a0,s1
    80006ffa:	00000097          	auipc	ra,0x0
    80006ffe:	f66080e7          	jalr	-154(ra) # 80006f60 <firstk>
  for (k = fk; k < nsizes; k++) {
    80007002:	00027797          	auipc	a5,0x27
    80007006:	09e78793          	addi	a5,a5,158 # 8002e0a0 <nsizes>
    8000700a:	439c                	lw	a5,0(a5)
    8000700c:	02f55d63          	ble	a5,a0,80007046 <bd_malloc+0x7e>
    80007010:	8d2a                	mv	s10,a0
    80007012:	00551913          	slli	s2,a0,0x5
    80007016:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80007018:	00027997          	auipc	s3,0x27
    8000701c:	08098993          	addi	s3,s3,128 # 8002e098 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80007020:	00027a17          	auipc	s4,0x27
    80007024:	080a0a13          	addi	s4,s4,128 # 8002e0a0 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80007028:	0009b503          	ld	a0,0(s3)
    8000702c:	954a                	add	a0,a0,s2
    8000702e:	00001097          	auipc	ra,0x1
    80007032:	8be080e7          	jalr	-1858(ra) # 800078ec <lst_empty>
    80007036:	c115                	beqz	a0,8000705a <bd_malloc+0x92>
  for (k = fk; k < nsizes; k++) {
    80007038:	2485                	addiw	s1,s1,1
    8000703a:	02090913          	addi	s2,s2,32
    8000703e:	000a2783          	lw	a5,0(s4)
    80007042:	fef4c3e3          	blt	s1,a5,80007028 <bd_malloc+0x60>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80007046:	00027517          	auipc	a0,0x27
    8000704a:	fba50513          	addi	a0,a0,-70 # 8002e000 <lock>
    8000704e:	ffffa097          	auipc	ra,0xffffa
    80007052:	eb8080e7          	jalr	-328(ra) # 80000f06 <release>
    return 0;
    80007056:	4b81                	li	s7,0
    80007058:	a8d1                	j	8000712c <bd_malloc+0x164>
  if(k >= nsizes) { // No free blocks?
    8000705a:	00027797          	auipc	a5,0x27
    8000705e:	04678793          	addi	a5,a5,70 # 8002e0a0 <nsizes>
    80007062:	439c                	lw	a5,0(a5)
    80007064:	fef4d1e3          	ble	a5,s1,80007046 <bd_malloc+0x7e>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80007068:	00549993          	slli	s3,s1,0x5
    8000706c:	00027917          	auipc	s2,0x27
    80007070:	02c90913          	addi	s2,s2,44 # 8002e098 <bd_sizes>
    80007074:	00093503          	ld	a0,0(s2)
    80007078:	954e                	add	a0,a0,s3
    8000707a:	00001097          	auipc	ra,0x1
    8000707e:	89e080e7          	jalr	-1890(ra) # 80007918 <lst_pop>
    80007082:	8baa                	mv	s7,a0
  int n = p - (char *) bd_base;
    80007084:	00027797          	auipc	a5,0x27
    80007088:	00c78793          	addi	a5,a5,12 # 8002e090 <bd_base>
    8000708c:	638c                	ld	a1,0(a5)
  return n / BLK_SIZE(k);
    8000708e:	40b505bb          	subw	a1,a0,a1
    80007092:	47c1                	li	a5,16
    80007094:	009797b3          	sll	a5,a5,s1
    80007098:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    8000709c:	00093783          	ld	a5,0(s2)
    800070a0:	97ce                	add	a5,a5,s3
    800070a2:	2581                	sext.w	a1,a1
    800070a4:	6b88                	ld	a0,16(a5)
    800070a6:	00000097          	auipc	ra,0x0
    800070aa:	ca2080e7          	jalr	-862(ra) # 80006d48 <bit_set>
  for(; k > fk; k--) {
    800070ae:	069d5763          	ble	s1,s10,8000711c <bd_malloc+0x154>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800070b2:	4c41                	li	s8,16
  int n = p - (char *) bd_base;
    800070b4:	00027d97          	auipc	s11,0x27
    800070b8:	fdcd8d93          	addi	s11,s11,-36 # 8002e090 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800070bc:	fff48a9b          	addiw	s5,s1,-1
    800070c0:	015c1b33          	sll	s6,s8,s5
    800070c4:	016b8cb3          	add	s9,s7,s6
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800070c8:	00027797          	auipc	a5,0x27
    800070cc:	fd078793          	addi	a5,a5,-48 # 8002e098 <bd_sizes>
    800070d0:	0007ba03          	ld	s4,0(a5)
  int n = p - (char *) bd_base;
    800070d4:	000db903          	ld	s2,0(s11)
  return n / BLK_SIZE(k);
    800070d8:	412b893b          	subw	s2,s7,s2
    800070dc:	009c15b3          	sll	a1,s8,s1
    800070e0:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800070e4:	013a07b3          	add	a5,s4,s3
    800070e8:	2581                	sext.w	a1,a1
    800070ea:	6f88                	ld	a0,24(a5)
    800070ec:	00000097          	auipc	ra,0x0
    800070f0:	c5c080e7          	jalr	-932(ra) # 80006d48 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800070f4:	1981                	addi	s3,s3,-32
    800070f6:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    800070f8:	036945b3          	div	a1,s2,s6
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800070fc:	2581                	sext.w	a1,a1
    800070fe:	010a3503          	ld	a0,16(s4)
    80007102:	00000097          	auipc	ra,0x0
    80007106:	c46080e7          	jalr	-954(ra) # 80006d48 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    8000710a:	85e6                	mv	a1,s9
    8000710c:	8552                	mv	a0,s4
    8000710e:	00001097          	auipc	ra,0x1
    80007112:	840080e7          	jalr	-1984(ra) # 8000794e <lst_push>
  for(; k > fk; k--) {
    80007116:	84d6                	mv	s1,s5
    80007118:	fbaa92e3          	bne	s5,s10,800070bc <bd_malloc+0xf4>
  }
  release(&lock);
    8000711c:	00027517          	auipc	a0,0x27
    80007120:	ee450513          	addi	a0,a0,-284 # 8002e000 <lock>
    80007124:	ffffa097          	auipc	ra,0xffffa
    80007128:	de2080e7          	jalr	-542(ra) # 80000f06 <release>

  return p;
}
    8000712c:	855e                	mv	a0,s7
    8000712e:	70a6                	ld	ra,104(sp)
    80007130:	7406                	ld	s0,96(sp)
    80007132:	64e6                	ld	s1,88(sp)
    80007134:	6946                	ld	s2,80(sp)
    80007136:	69a6                	ld	s3,72(sp)
    80007138:	6a06                	ld	s4,64(sp)
    8000713a:	7ae2                	ld	s5,56(sp)
    8000713c:	7b42                	ld	s6,48(sp)
    8000713e:	7ba2                	ld	s7,40(sp)
    80007140:	7c02                	ld	s8,32(sp)
    80007142:	6ce2                	ld	s9,24(sp)
    80007144:	6d42                	ld	s10,16(sp)
    80007146:	6da2                	ld	s11,8(sp)
    80007148:	6165                	addi	sp,sp,112
    8000714a:	8082                	ret

000000008000714c <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    8000714c:	7139                	addi	sp,sp,-64
    8000714e:	fc06                	sd	ra,56(sp)
    80007150:	f822                	sd	s0,48(sp)
    80007152:	f426                	sd	s1,40(sp)
    80007154:	f04a                	sd	s2,32(sp)
    80007156:	ec4e                	sd	s3,24(sp)
    80007158:	e852                	sd	s4,16(sp)
    8000715a:	e456                	sd	s5,8(sp)
    8000715c:	e05a                	sd	s6,0(sp)
    8000715e:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80007160:	00027797          	auipc	a5,0x27
    80007164:	f4078793          	addi	a5,a5,-192 # 8002e0a0 <nsizes>
    80007168:	0007aa83          	lw	s5,0(a5)
  int n = p - (char *) bd_base;
    8000716c:	00027797          	auipc	a5,0x27
    80007170:	f2478793          	addi	a5,a5,-220 # 8002e090 <bd_base>
    80007174:	0007ba03          	ld	s4,0(a5)
  return n / BLK_SIZE(k);
    80007178:	41450a3b          	subw	s4,a0,s4
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    8000717c:	00027797          	auipc	a5,0x27
    80007180:	f1c78793          	addi	a5,a5,-228 # 8002e098 <bd_sizes>
    80007184:	6384                	ld	s1,0(a5)
    80007186:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    8000718a:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    8000718c:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    8000718e:	03595363          	ble	s5,s2,800071b4 <size+0x68>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80007192:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80007196:	013b15b3          	sll	a1,s6,s3
    8000719a:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    8000719e:	2581                	sext.w	a1,a1
    800071a0:	6088                	ld	a0,0(s1)
    800071a2:	00000097          	auipc	ra,0x0
    800071a6:	b6e080e7          	jalr	-1170(ra) # 80006d10 <bit_isset>
    800071aa:	02048493          	addi	s1,s1,32
    800071ae:	e501                	bnez	a0,800071b6 <size+0x6a>
  for (int k = 0; k < nsizes; k++) {
    800071b0:	894e                	mv	s2,s3
    800071b2:	bff1                	j	8000718e <size+0x42>
      return k;
    }
  }
  return 0;
    800071b4:	4901                	li	s2,0
}
    800071b6:	854a                	mv	a0,s2
    800071b8:	70e2                	ld	ra,56(sp)
    800071ba:	7442                	ld	s0,48(sp)
    800071bc:	74a2                	ld	s1,40(sp)
    800071be:	7902                	ld	s2,32(sp)
    800071c0:	69e2                	ld	s3,24(sp)
    800071c2:	6a42                	ld	s4,16(sp)
    800071c4:	6aa2                	ld	s5,8(sp)
    800071c6:	6b02                	ld	s6,0(sp)
    800071c8:	6121                	addi	sp,sp,64
    800071ca:	8082                	ret

00000000800071cc <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    800071cc:	7159                	addi	sp,sp,-112
    800071ce:	f486                	sd	ra,104(sp)
    800071d0:	f0a2                	sd	s0,96(sp)
    800071d2:	eca6                	sd	s1,88(sp)
    800071d4:	e8ca                	sd	s2,80(sp)
    800071d6:	e4ce                	sd	s3,72(sp)
    800071d8:	e0d2                	sd	s4,64(sp)
    800071da:	fc56                	sd	s5,56(sp)
    800071dc:	f85a                	sd	s6,48(sp)
    800071de:	f45e                	sd	s7,40(sp)
    800071e0:	f062                	sd	s8,32(sp)
    800071e2:	ec66                	sd	s9,24(sp)
    800071e4:	e86a                	sd	s10,16(sp)
    800071e6:	e46e                	sd	s11,8(sp)
    800071e8:	1880                	addi	s0,sp,112
    800071ea:	8b2a                	mv	s6,a0
  void *q;
  int k;

  acquire(&lock);
    800071ec:	00027517          	auipc	a0,0x27
    800071f0:	e1450513          	addi	a0,a0,-492 # 8002e000 <lock>
    800071f4:	ffffa097          	auipc	ra,0xffffa
    800071f8:	ac6080e7          	jalr	-1338(ra) # 80000cba <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    800071fc:	855a                	mv	a0,s6
    800071fe:	00000097          	auipc	ra,0x0
    80007202:	f4e080e7          	jalr	-178(ra) # 8000714c <size>
    80007206:	892a                	mv	s2,a0
    80007208:	00027797          	auipc	a5,0x27
    8000720c:	e9878793          	addi	a5,a5,-360 # 8002e0a0 <nsizes>
    80007210:	439c                	lw	a5,0(a5)
    80007212:	37fd                	addiw	a5,a5,-1
    80007214:	0af55a63          	ble	a5,a0,800072c8 <bd_free+0xfc>
    80007218:	00551a93          	slli	s5,a0,0x5
  int n = p - (char *) bd_base;
    8000721c:	00027c97          	auipc	s9,0x27
    80007220:	e74c8c93          	addi	s9,s9,-396 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    80007224:	4c41                	li	s8,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007226:	00027b97          	auipc	s7,0x27
    8000722a:	e72b8b93          	addi	s7,s7,-398 # 8002e098 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    8000722e:	00027d17          	auipc	s10,0x27
    80007232:	e72d0d13          	addi	s10,s10,-398 # 8002e0a0 <nsizes>
    80007236:	a82d                	j	80007270 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007238:	fff5849b          	addiw	s1,a1,-1
    8000723c:	a881                	j	8000728c <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    8000723e:	020a8a93          	addi	s5,s5,32
    80007242:	2905                	addiw	s2,s2,1
  int n = p - (char *) bd_base;
    80007244:	000cb583          	ld	a1,0(s9)
  return n / BLK_SIZE(k);
    80007248:	40bb05bb          	subw	a1,s6,a1
    8000724c:	012c17b3          	sll	a5,s8,s2
    80007250:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007254:	000bb783          	ld	a5,0(s7)
    80007258:	97d6                	add	a5,a5,s5
    8000725a:	2581                	sext.w	a1,a1
    8000725c:	6f88                	ld	a0,24(a5)
    8000725e:	00000097          	auipc	ra,0x0
    80007262:	b1a080e7          	jalr	-1254(ra) # 80006d78 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80007266:	000d2783          	lw	a5,0(s10)
    8000726a:	37fd                	addiw	a5,a5,-1
    8000726c:	04f95e63          	ble	a5,s2,800072c8 <bd_free+0xfc>
  int n = p - (char *) bd_base;
    80007270:	000cb983          	ld	s3,0(s9)
  return n / BLK_SIZE(k);
    80007274:	012c1a33          	sll	s4,s8,s2
    80007278:	413b07bb          	subw	a5,s6,s3
    8000727c:	0347c7b3          	div	a5,a5,s4
    80007280:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007284:	8b85                	andi	a5,a5,1
    80007286:	fbcd                	bnez	a5,80007238 <bd_free+0x6c>
    80007288:	0015849b          	addiw	s1,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    8000728c:	000bbd83          	ld	s11,0(s7)
    80007290:	9dd6                	add	s11,s11,s5
    80007292:	010db503          	ld	a0,16(s11)
    80007296:	00000097          	auipc	ra,0x0
    8000729a:	ae2080e7          	jalr	-1310(ra) # 80006d78 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    8000729e:	85a6                	mv	a1,s1
    800072a0:	010db503          	ld	a0,16(s11)
    800072a4:	00000097          	auipc	ra,0x0
    800072a8:	a6c080e7          	jalr	-1428(ra) # 80006d10 <bit_isset>
    800072ac:	ed11                	bnez	a0,800072c8 <bd_free+0xfc>
  int n = bi * BLK_SIZE(k);
    800072ae:	2481                	sext.w	s1,s1
  return (char *) bd_base + n;
    800072b0:	029a0a3b          	mulw	s4,s4,s1
    800072b4:	99d2                	add	s3,s3,s4
    lst_remove(q);    // remove buddy from free list
    800072b6:	854e                	mv	a0,s3
    800072b8:	00000097          	auipc	ra,0x0
    800072bc:	64a080e7          	jalr	1610(ra) # 80007902 <lst_remove>
    if(buddy % 2 == 0) {
    800072c0:	8885                	andi	s1,s1,1
    800072c2:	fcb5                	bnez	s1,8000723e <bd_free+0x72>
      p = q;
    800072c4:	8b4e                	mv	s6,s3
    800072c6:	bfa5                	j	8000723e <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    800072c8:	0916                	slli	s2,s2,0x5
    800072ca:	00027797          	auipc	a5,0x27
    800072ce:	dce78793          	addi	a5,a5,-562 # 8002e098 <bd_sizes>
    800072d2:	6388                	ld	a0,0(a5)
    800072d4:	85da                	mv	a1,s6
    800072d6:	954a                	add	a0,a0,s2
    800072d8:	00000097          	auipc	ra,0x0
    800072dc:	676080e7          	jalr	1654(ra) # 8000794e <lst_push>
  release(&lock);
    800072e0:	00027517          	auipc	a0,0x27
    800072e4:	d2050513          	addi	a0,a0,-736 # 8002e000 <lock>
    800072e8:	ffffa097          	auipc	ra,0xffffa
    800072ec:	c1e080e7          	jalr	-994(ra) # 80000f06 <release>
}
    800072f0:	70a6                	ld	ra,104(sp)
    800072f2:	7406                	ld	s0,96(sp)
    800072f4:	64e6                	ld	s1,88(sp)
    800072f6:	6946                	ld	s2,80(sp)
    800072f8:	69a6                	ld	s3,72(sp)
    800072fa:	6a06                	ld	s4,64(sp)
    800072fc:	7ae2                	ld	s5,56(sp)
    800072fe:	7b42                	ld	s6,48(sp)
    80007300:	7ba2                	ld	s7,40(sp)
    80007302:	7c02                	ld	s8,32(sp)
    80007304:	6ce2                	ld	s9,24(sp)
    80007306:	6d42                	ld	s10,16(sp)
    80007308:	6da2                	ld	s11,8(sp)
    8000730a:	6165                	addi	sp,sp,112
    8000730c:	8082                	ret

000000008000730e <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    8000730e:	1141                	addi	sp,sp,-16
    80007310:	e422                	sd	s0,8(sp)
    80007312:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80007314:	00027797          	auipc	a5,0x27
    80007318:	d7c78793          	addi	a5,a5,-644 # 8002e090 <bd_base>
    8000731c:	639c                	ld	a5,0(a5)
    8000731e:	8d9d                	sub	a1,a1,a5
    80007320:	47c1                	li	a5,16
    80007322:	00a797b3          	sll	a5,a5,a0
    80007326:	02f5c533          	div	a0,a1,a5
    8000732a:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    8000732c:	02f5e5b3          	rem	a1,a1,a5
    80007330:	c191                	beqz	a1,80007334 <blk_index_next+0x26>
      n++;
    80007332:	2505                	addiw	a0,a0,1
  return n ;
}
    80007334:	6422                	ld	s0,8(sp)
    80007336:	0141                	addi	sp,sp,16
    80007338:	8082                	ret

000000008000733a <log2>:

int
log2(uint64 n) {
    8000733a:	1141                	addi	sp,sp,-16
    8000733c:	e422                	sd	s0,8(sp)
    8000733e:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80007340:	4705                	li	a4,1
    80007342:	00a77b63          	bleu	a0,a4,80007358 <log2+0x1e>
    80007346:	87aa                	mv	a5,a0
  int k = 0;
    80007348:	4501                	li	a0,0
    k++;
    8000734a:	2505                	addiw	a0,a0,1
    n = n >> 1;
    8000734c:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    8000734e:	fef76ee3          	bltu	a4,a5,8000734a <log2+0x10>
  }
  return k;
}
    80007352:	6422                	ld	s0,8(sp)
    80007354:	0141                	addi	sp,sp,16
    80007356:	8082                	ret
  int k = 0;
    80007358:	4501                	li	a0,0
    8000735a:	bfe5                	j	80007352 <log2+0x18>

000000008000735c <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    8000735c:	711d                	addi	sp,sp,-96
    8000735e:	ec86                	sd	ra,88(sp)
    80007360:	e8a2                	sd	s0,80(sp)
    80007362:	e4a6                	sd	s1,72(sp)
    80007364:	e0ca                	sd	s2,64(sp)
    80007366:	fc4e                	sd	s3,56(sp)
    80007368:	f852                	sd	s4,48(sp)
    8000736a:	f456                	sd	s5,40(sp)
    8000736c:	f05a                	sd	s6,32(sp)
    8000736e:	ec5e                	sd	s7,24(sp)
    80007370:	e862                	sd	s8,16(sp)
    80007372:	e466                	sd	s9,8(sp)
    80007374:	e06a                	sd	s10,0(sp)
    80007376:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80007378:	00b56933          	or	s2,a0,a1
    8000737c:	00f97913          	andi	s2,s2,15
    80007380:	04091463          	bnez	s2,800073c8 <bd_mark+0x6c>
    80007384:	8baa                	mv	s7,a0
    80007386:	8c2e                	mv	s8,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80007388:	00027797          	auipc	a5,0x27
    8000738c:	d1878793          	addi	a5,a5,-744 # 8002e0a0 <nsizes>
    80007390:	0007ab03          	lw	s6,0(a5)
    80007394:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80007396:	00027d17          	auipc	s10,0x27
    8000739a:	cfad0d13          	addi	s10,s10,-774 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    8000739e:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    800073a0:	00027a17          	auipc	s4,0x27
    800073a4:	cf8a0a13          	addi	s4,s4,-776 # 8002e098 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    800073a8:	07604563          	bgtz	s6,80007412 <bd_mark+0xb6>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    800073ac:	60e6                	ld	ra,88(sp)
    800073ae:	6446                	ld	s0,80(sp)
    800073b0:	64a6                	ld	s1,72(sp)
    800073b2:	6906                	ld	s2,64(sp)
    800073b4:	79e2                	ld	s3,56(sp)
    800073b6:	7a42                	ld	s4,48(sp)
    800073b8:	7aa2                	ld	s5,40(sp)
    800073ba:	7b02                	ld	s6,32(sp)
    800073bc:	6be2                	ld	s7,24(sp)
    800073be:	6c42                	ld	s8,16(sp)
    800073c0:	6ca2                	ld	s9,8(sp)
    800073c2:	6d02                	ld	s10,0(sp)
    800073c4:	6125                	addi	sp,sp,96
    800073c6:	8082                	ret
    panic("bd_mark");
    800073c8:	00002517          	auipc	a0,0x2
    800073cc:	a3850513          	addi	a0,a0,-1480 # 80008e00 <userret+0xd70>
    800073d0:	ffff9097          	auipc	ra,0xffff9
    800073d4:	3b4080e7          	jalr	948(ra) # 80000784 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    800073d8:	000a3783          	ld	a5,0(s4)
    800073dc:	97ca                	add	a5,a5,s2
    800073de:	85a6                	mv	a1,s1
    800073e0:	6b88                	ld	a0,16(a5)
    800073e2:	00000097          	auipc	ra,0x0
    800073e6:	966080e7          	jalr	-1690(ra) # 80006d48 <bit_set>
    for(; bi < bj; bi++) {
    800073ea:	2485                	addiw	s1,s1,1
    800073ec:	009a8e63          	beq	s5,s1,80007408 <bd_mark+0xac>
      if(k > 0) {
    800073f0:	ff3054e3          	blez	s3,800073d8 <bd_mark+0x7c>
        bit_set(bd_sizes[k].split, bi);
    800073f4:	000a3783          	ld	a5,0(s4)
    800073f8:	97ca                	add	a5,a5,s2
    800073fa:	85a6                	mv	a1,s1
    800073fc:	6f88                	ld	a0,24(a5)
    800073fe:	00000097          	auipc	ra,0x0
    80007402:	94a080e7          	jalr	-1718(ra) # 80006d48 <bit_set>
    80007406:	bfc9                	j	800073d8 <bd_mark+0x7c>
  for (int k = 0; k < nsizes; k++) {
    80007408:	2985                	addiw	s3,s3,1
    8000740a:	02090913          	addi	s2,s2,32
    8000740e:	f9698fe3          	beq	s3,s6,800073ac <bd_mark+0x50>
  int n = p - (char *) bd_base;
    80007412:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80007416:	409b84bb          	subw	s1,s7,s1
    8000741a:	013c97b3          	sll	a5,s9,s3
    8000741e:	02f4c4b3          	div	s1,s1,a5
    80007422:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80007424:	85e2                	mv	a1,s8
    80007426:	854e                	mv	a0,s3
    80007428:	00000097          	auipc	ra,0x0
    8000742c:	ee6080e7          	jalr	-282(ra) # 8000730e <blk_index_next>
    80007430:	8aaa                	mv	s5,a0
    for(; bi < bj; bi++) {
    80007432:	faa4cfe3          	blt	s1,a0,800073f0 <bd_mark+0x94>
    80007436:	bfc9                	j	80007408 <bd_mark+0xac>

0000000080007438 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80007438:	7139                	addi	sp,sp,-64
    8000743a:	fc06                	sd	ra,56(sp)
    8000743c:	f822                	sd	s0,48(sp)
    8000743e:	f426                	sd	s1,40(sp)
    80007440:	f04a                	sd	s2,32(sp)
    80007442:	ec4e                	sd	s3,24(sp)
    80007444:	e852                	sd	s4,16(sp)
    80007446:	e456                	sd	s5,8(sp)
    80007448:	e05a                	sd	s6,0(sp)
    8000744a:	0080                	addi	s0,sp,64
    8000744c:	8b2a                	mv	s6,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000744e:	00058a1b          	sext.w	s4,a1
    80007452:	001a7793          	andi	a5,s4,1
    80007456:	ebbd                	bnez	a5,800074cc <bd_initfree_pair+0x94>
    80007458:	00158a9b          	addiw	s5,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    8000745c:	005b1493          	slli	s1,s6,0x5
    80007460:	00027797          	auipc	a5,0x27
    80007464:	c3878793          	addi	a5,a5,-968 # 8002e098 <bd_sizes>
    80007468:	639c                	ld	a5,0(a5)
    8000746a:	94be                	add	s1,s1,a5
    8000746c:	0104b903          	ld	s2,16(s1)
    80007470:	854a                	mv	a0,s2
    80007472:	00000097          	auipc	ra,0x0
    80007476:	89e080e7          	jalr	-1890(ra) # 80006d10 <bit_isset>
    8000747a:	89aa                	mv	s3,a0
    8000747c:	85d6                	mv	a1,s5
    8000747e:	854a                	mv	a0,s2
    80007480:	00000097          	auipc	ra,0x0
    80007484:	890080e7          	jalr	-1904(ra) # 80006d10 <bit_isset>
  int free = 0;
    80007488:	4901                	li	s2,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    8000748a:	02a98663          	beq	s3,a0,800074b6 <bd_initfree_pair+0x7e>
    // one of the pair is free
    free = BLK_SIZE(k);
    8000748e:	45c1                	li	a1,16
    80007490:	016595b3          	sll	a1,a1,s6
    80007494:	0005891b          	sext.w	s2,a1
    if(bit_isset(bd_sizes[k].alloc, bi))
    80007498:	02098d63          	beqz	s3,800074d2 <bd_initfree_pair+0x9a>
  return (char *) bd_base + n;
    8000749c:	035585bb          	mulw	a1,a1,s5
    800074a0:	00027797          	auipc	a5,0x27
    800074a4:	bf078793          	addi	a5,a5,-1040 # 8002e090 <bd_base>
    800074a8:	639c                	ld	a5,0(a5)
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    800074aa:	95be                	add	a1,a1,a5
    800074ac:	8526                	mv	a0,s1
    800074ae:	00000097          	auipc	ra,0x0
    800074b2:	4a0080e7          	jalr	1184(ra) # 8000794e <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    800074b6:	854a                	mv	a0,s2
    800074b8:	70e2                	ld	ra,56(sp)
    800074ba:	7442                	ld	s0,48(sp)
    800074bc:	74a2                	ld	s1,40(sp)
    800074be:	7902                	ld	s2,32(sp)
    800074c0:	69e2                	ld	s3,24(sp)
    800074c2:	6a42                	ld	s4,16(sp)
    800074c4:	6aa2                	ld	s5,8(sp)
    800074c6:	6b02                	ld	s6,0(sp)
    800074c8:	6121                	addi	sp,sp,64
    800074ca:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800074cc:	fff58a9b          	addiw	s5,a1,-1
    800074d0:	b771                	j	8000745c <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    800074d2:	034585bb          	mulw	a1,a1,s4
    800074d6:	00027797          	auipc	a5,0x27
    800074da:	bba78793          	addi	a5,a5,-1094 # 8002e090 <bd_base>
    800074de:	639c                	ld	a5,0(a5)
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    800074e0:	95be                	add	a1,a1,a5
    800074e2:	8526                	mv	a0,s1
    800074e4:	00000097          	auipc	ra,0x0
    800074e8:	46a080e7          	jalr	1130(ra) # 8000794e <lst_push>
    800074ec:	b7e9                	j	800074b6 <bd_initfree_pair+0x7e>

00000000800074ee <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    800074ee:	711d                	addi	sp,sp,-96
    800074f0:	ec86                	sd	ra,88(sp)
    800074f2:	e8a2                	sd	s0,80(sp)
    800074f4:	e4a6                	sd	s1,72(sp)
    800074f6:	e0ca                	sd	s2,64(sp)
    800074f8:	fc4e                	sd	s3,56(sp)
    800074fa:	f852                	sd	s4,48(sp)
    800074fc:	f456                	sd	s5,40(sp)
    800074fe:	f05a                	sd	s6,32(sp)
    80007500:	ec5e                	sd	s7,24(sp)
    80007502:	e862                	sd	s8,16(sp)
    80007504:	e466                	sd	s9,8(sp)
    80007506:	e06a                	sd	s10,0(sp)
    80007508:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    8000750a:	00027797          	auipc	a5,0x27
    8000750e:	b9678793          	addi	a5,a5,-1130 # 8002e0a0 <nsizes>
    80007512:	4398                	lw	a4,0(a5)
    80007514:	4785                	li	a5,1
    80007516:	06e7db63          	ble	a4,a5,8000758c <bd_initfree+0x9e>
    8000751a:	8b2e                	mv	s6,a1
    8000751c:	8aaa                	mv	s5,a0
    8000751e:	4901                	li	s2,0
  int free = 0;
    80007520:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80007522:	00027c97          	auipc	s9,0x27
    80007526:	b6ec8c93          	addi	s9,s9,-1170 # 8002e090 <bd_base>
  return n / BLK_SIZE(k);
    8000752a:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    8000752c:	00027b97          	auipc	s7,0x27
    80007530:	b74b8b93          	addi	s7,s7,-1164 # 8002e0a0 <nsizes>
    80007534:	a039                	j	80007542 <bd_initfree+0x54>
    80007536:	2905                	addiw	s2,s2,1
    80007538:	000ba783          	lw	a5,0(s7)
    8000753c:	37fd                	addiw	a5,a5,-1
    8000753e:	04f95863          	ble	a5,s2,8000758e <bd_initfree+0xa0>
    int left = blk_index_next(k, bd_left);
    80007542:	85d6                	mv	a1,s5
    80007544:	854a                	mv	a0,s2
    80007546:	00000097          	auipc	ra,0x0
    8000754a:	dc8080e7          	jalr	-568(ra) # 8000730e <blk_index_next>
    8000754e:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80007550:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80007554:	409b04bb          	subw	s1,s6,s1
    80007558:	012c17b3          	sll	a5,s8,s2
    8000755c:	02f4c4b3          	div	s1,s1,a5
    80007560:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80007562:	85aa                	mv	a1,a0
    80007564:	854a                	mv	a0,s2
    80007566:	00000097          	auipc	ra,0x0
    8000756a:	ed2080e7          	jalr	-302(ra) # 80007438 <bd_initfree_pair>
    8000756e:	01450d3b          	addw	s10,a0,s4
    80007572:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80007576:	fc99d0e3          	ble	s1,s3,80007536 <bd_initfree+0x48>
      continue;
    free += bd_initfree_pair(k, right);
    8000757a:	85a6                	mv	a1,s1
    8000757c:	854a                	mv	a0,s2
    8000757e:	00000097          	auipc	ra,0x0
    80007582:	eba080e7          	jalr	-326(ra) # 80007438 <bd_initfree_pair>
    80007586:	00ad0a3b          	addw	s4,s10,a0
    8000758a:	b775                	j	80007536 <bd_initfree+0x48>
  int free = 0;
    8000758c:	4a01                	li	s4,0
  }
  return free;
}
    8000758e:	8552                	mv	a0,s4
    80007590:	60e6                	ld	ra,88(sp)
    80007592:	6446                	ld	s0,80(sp)
    80007594:	64a6                	ld	s1,72(sp)
    80007596:	6906                	ld	s2,64(sp)
    80007598:	79e2                	ld	s3,56(sp)
    8000759a:	7a42                	ld	s4,48(sp)
    8000759c:	7aa2                	ld	s5,40(sp)
    8000759e:	7b02                	ld	s6,32(sp)
    800075a0:	6be2                	ld	s7,24(sp)
    800075a2:	6c42                	ld	s8,16(sp)
    800075a4:	6ca2                	ld	s9,8(sp)
    800075a6:	6d02                	ld	s10,0(sp)
    800075a8:	6125                	addi	sp,sp,96
    800075aa:	8082                	ret

00000000800075ac <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    800075ac:	7179                	addi	sp,sp,-48
    800075ae:	f406                	sd	ra,40(sp)
    800075b0:	f022                	sd	s0,32(sp)
    800075b2:	ec26                	sd	s1,24(sp)
    800075b4:	e84a                	sd	s2,16(sp)
    800075b6:	e44e                	sd	s3,8(sp)
    800075b8:	1800                	addi	s0,sp,48
    800075ba:	89aa                	mv	s3,a0
  int meta = p - (char*)bd_base;
    800075bc:	00027917          	auipc	s2,0x27
    800075c0:	ad490913          	addi	s2,s2,-1324 # 8002e090 <bd_base>
    800075c4:	00093483          	ld	s1,0(s2)
    800075c8:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    800075cc:	00027797          	auipc	a5,0x27
    800075d0:	ad478793          	addi	a5,a5,-1324 # 8002e0a0 <nsizes>
    800075d4:	439c                	lw	a5,0(a5)
    800075d6:	37fd                	addiw	a5,a5,-1
    800075d8:	4641                	li	a2,16
    800075da:	00f61633          	sll	a2,a2,a5
    800075de:	85a6                	mv	a1,s1
    800075e0:	00002517          	auipc	a0,0x2
    800075e4:	82850513          	addi	a0,a0,-2008 # 80008e08 <userret+0xd78>
    800075e8:	ffff9097          	auipc	ra,0xffff9
    800075ec:	3b4080e7          	jalr	948(ra) # 8000099c <printf>
  bd_mark(bd_base, p);
    800075f0:	85ce                	mv	a1,s3
    800075f2:	00093503          	ld	a0,0(s2)
    800075f6:	00000097          	auipc	ra,0x0
    800075fa:	d66080e7          	jalr	-666(ra) # 8000735c <bd_mark>
  return meta;
}
    800075fe:	8526                	mv	a0,s1
    80007600:	70a2                	ld	ra,40(sp)
    80007602:	7402                	ld	s0,32(sp)
    80007604:	64e2                	ld	s1,24(sp)
    80007606:	6942                	ld	s2,16(sp)
    80007608:	69a2                	ld	s3,8(sp)
    8000760a:	6145                	addi	sp,sp,48
    8000760c:	8082                	ret

000000008000760e <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    8000760e:	1101                	addi	sp,sp,-32
    80007610:	ec06                	sd	ra,24(sp)
    80007612:	e822                	sd	s0,16(sp)
    80007614:	e426                	sd	s1,8(sp)
    80007616:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80007618:	00027797          	auipc	a5,0x27
    8000761c:	a8878793          	addi	a5,a5,-1400 # 8002e0a0 <nsizes>
    80007620:	4384                	lw	s1,0(a5)
    80007622:	fff4879b          	addiw	a5,s1,-1
    80007626:	44c1                	li	s1,16
    80007628:	00f494b3          	sll	s1,s1,a5
    8000762c:	00027797          	auipc	a5,0x27
    80007630:	a6478793          	addi	a5,a5,-1436 # 8002e090 <bd_base>
    80007634:	639c                	ld	a5,0(a5)
    80007636:	8d1d                	sub	a0,a0,a5
    80007638:	40a4853b          	subw	a0,s1,a0
    8000763c:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80007640:	00905a63          	blez	s1,80007654 <bd_mark_unavailable+0x46>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80007644:	357d                	addiw	a0,a0,-1
    80007646:	41f5549b          	sraiw	s1,a0,0x1f
    8000764a:	01c4d49b          	srliw	s1,s1,0x1c
    8000764e:	9ca9                	addw	s1,s1,a0
    80007650:	98c1                	andi	s1,s1,-16
    80007652:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80007654:	85a6                	mv	a1,s1
    80007656:	00001517          	auipc	a0,0x1
    8000765a:	7ea50513          	addi	a0,a0,2026 # 80008e40 <userret+0xdb0>
    8000765e:	ffff9097          	auipc	ra,0xffff9
    80007662:	33e080e7          	jalr	830(ra) # 8000099c <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007666:	00027797          	auipc	a5,0x27
    8000766a:	a2a78793          	addi	a5,a5,-1494 # 8002e090 <bd_base>
    8000766e:	6398                	ld	a4,0(a5)
    80007670:	00027797          	auipc	a5,0x27
    80007674:	a3078793          	addi	a5,a5,-1488 # 8002e0a0 <nsizes>
    80007678:	438c                	lw	a1,0(a5)
    8000767a:	fff5879b          	addiw	a5,a1,-1
    8000767e:	45c1                	li	a1,16
    80007680:	00f595b3          	sll	a1,a1,a5
    80007684:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80007688:	95ba                	add	a1,a1,a4
    8000768a:	953a                	add	a0,a0,a4
    8000768c:	00000097          	auipc	ra,0x0
    80007690:	cd0080e7          	jalr	-816(ra) # 8000735c <bd_mark>
  return unavailable;
}
    80007694:	8526                	mv	a0,s1
    80007696:	60e2                	ld	ra,24(sp)
    80007698:	6442                	ld	s0,16(sp)
    8000769a:	64a2                	ld	s1,8(sp)
    8000769c:	6105                	addi	sp,sp,32
    8000769e:	8082                	ret

00000000800076a0 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    800076a0:	715d                	addi	sp,sp,-80
    800076a2:	e486                	sd	ra,72(sp)
    800076a4:	e0a2                	sd	s0,64(sp)
    800076a6:	fc26                	sd	s1,56(sp)
    800076a8:	f84a                	sd	s2,48(sp)
    800076aa:	f44e                	sd	s3,40(sp)
    800076ac:	f052                	sd	s4,32(sp)
    800076ae:	ec56                	sd	s5,24(sp)
    800076b0:	e85a                	sd	s6,16(sp)
    800076b2:	e45e                	sd	s7,8(sp)
    800076b4:	e062                	sd	s8,0(sp)
    800076b6:	0880                	addi	s0,sp,80
    800076b8:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    800076ba:	fff50493          	addi	s1,a0,-1
    800076be:	98c1                	andi	s1,s1,-16
    800076c0:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    800076c2:	00001597          	auipc	a1,0x1
    800076c6:	79e58593          	addi	a1,a1,1950 # 80008e60 <userret+0xdd0>
    800076ca:	00027517          	auipc	a0,0x27
    800076ce:	93650513          	addi	a0,a0,-1738 # 8002e000 <lock>
    800076d2:	ffff9097          	auipc	ra,0xffff9
    800076d6:	47a080e7          	jalr	1146(ra) # 80000b4c <initlock>
  bd_base = (void *) p;
    800076da:	00027797          	auipc	a5,0x27
    800076de:	9a97bb23          	sd	s1,-1610(a5) # 8002e090 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    800076e2:	409c0933          	sub	s2,s8,s1
    800076e6:	43f95513          	srai	a0,s2,0x3f
    800076ea:	893d                	andi	a0,a0,15
    800076ec:	954a                	add	a0,a0,s2
    800076ee:	8511                	srai	a0,a0,0x4
    800076f0:	00000097          	auipc	ra,0x0
    800076f4:	c4a080e7          	jalr	-950(ra) # 8000733a <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    800076f8:	47c1                	li	a5,16
    800076fa:	00a797b3          	sll	a5,a5,a0
    800076fe:	1b27c863          	blt	a5,s2,800078ae <bd_init+0x20e>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007702:	2505                	addiw	a0,a0,1
    80007704:	00027797          	auipc	a5,0x27
    80007708:	98a7ae23          	sw	a0,-1636(a5) # 8002e0a0 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    8000770c:	00027997          	auipc	s3,0x27
    80007710:	99498993          	addi	s3,s3,-1644 # 8002e0a0 <nsizes>
    80007714:	0009a603          	lw	a2,0(s3)
    80007718:	85ca                	mv	a1,s2
    8000771a:	00001517          	auipc	a0,0x1
    8000771e:	74e50513          	addi	a0,a0,1870 # 80008e68 <userret+0xdd8>
    80007722:	ffff9097          	auipc	ra,0xffff9
    80007726:	27a080e7          	jalr	634(ra) # 8000099c <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    8000772a:	00027797          	auipc	a5,0x27
    8000772e:	9697b723          	sd	s1,-1682(a5) # 8002e098 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80007732:	0009a603          	lw	a2,0(s3)
    80007736:	00561913          	slli	s2,a2,0x5
    8000773a:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    8000773c:	0056161b          	slliw	a2,a2,0x5
    80007740:	4581                	li	a1,0
    80007742:	8526                	mv	a0,s1
    80007744:	ffffa097          	auipc	ra,0xffffa
    80007748:	9ea080e7          	jalr	-1558(ra) # 8000112e <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    8000774c:	0009a783          	lw	a5,0(s3)
    80007750:	06f05a63          	blez	a5,800077c4 <bd_init+0x124>
    80007754:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80007756:	00027a97          	auipc	s5,0x27
    8000775a:	942a8a93          	addi	s5,s5,-1726 # 8002e098 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    8000775e:	00027a17          	auipc	s4,0x27
    80007762:	942a0a13          	addi	s4,s4,-1726 # 8002e0a0 <nsizes>
    80007766:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80007768:	00599b93          	slli	s7,s3,0x5
    8000776c:	000ab503          	ld	a0,0(s5)
    80007770:	955e                	add	a0,a0,s7
    80007772:	00000097          	auipc	ra,0x0
    80007776:	16a080e7          	jalr	362(ra) # 800078dc <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    8000777a:	000a2483          	lw	s1,0(s4)
    8000777e:	34fd                	addiw	s1,s1,-1
    80007780:	413484bb          	subw	s1,s1,s3
    80007784:	009b14bb          	sllw	s1,s6,s1
    80007788:	fff4879b          	addiw	a5,s1,-1
    8000778c:	41f7d49b          	sraiw	s1,a5,0x1f
    80007790:	01d4d49b          	srliw	s1,s1,0x1d
    80007794:	9cbd                	addw	s1,s1,a5
    80007796:	98e1                	andi	s1,s1,-8
    80007798:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    8000779a:	000ab783          	ld	a5,0(s5)
    8000779e:	9bbe                	add	s7,s7,a5
    800077a0:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    800077a4:	848d                	srai	s1,s1,0x3
    800077a6:	8626                	mv	a2,s1
    800077a8:	4581                	li	a1,0
    800077aa:	854a                	mv	a0,s2
    800077ac:	ffffa097          	auipc	ra,0xffffa
    800077b0:	982080e7          	jalr	-1662(ra) # 8000112e <memset>
    p += sz;
    800077b4:	9926                	add	s2,s2,s1
    800077b6:	0985                	addi	s3,s3,1
  for (int k = 0; k < nsizes; k++) {
    800077b8:	000a2703          	lw	a4,0(s4)
    800077bc:	0009879b          	sext.w	a5,s3
    800077c0:	fae7c4e3          	blt	a5,a4,80007768 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    800077c4:	00027797          	auipc	a5,0x27
    800077c8:	8dc78793          	addi	a5,a5,-1828 # 8002e0a0 <nsizes>
    800077cc:	439c                	lw	a5,0(a5)
    800077ce:	4705                	li	a4,1
    800077d0:	06f75163          	ble	a5,a4,80007832 <bd_init+0x192>
    800077d4:	02000a13          	li	s4,32
    800077d8:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    800077da:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    800077dc:	00027b17          	auipc	s6,0x27
    800077e0:	8bcb0b13          	addi	s6,s6,-1860 # 8002e098 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    800077e4:	00027a97          	auipc	s5,0x27
    800077e8:	8bca8a93          	addi	s5,s5,-1860 # 8002e0a0 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    800077ec:	37fd                	addiw	a5,a5,-1
    800077ee:	413787bb          	subw	a5,a5,s3
    800077f2:	00fb94bb          	sllw	s1,s7,a5
    800077f6:	fff4879b          	addiw	a5,s1,-1
    800077fa:	41f7d49b          	sraiw	s1,a5,0x1f
    800077fe:	01d4d49b          	srliw	s1,s1,0x1d
    80007802:	9cbd                	addw	s1,s1,a5
    80007804:	98e1                	andi	s1,s1,-8
    80007806:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007808:	000b3783          	ld	a5,0(s6)
    8000780c:	97d2                	add	a5,a5,s4
    8000780e:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007812:	848d                	srai	s1,s1,0x3
    80007814:	8626                	mv	a2,s1
    80007816:	4581                	li	a1,0
    80007818:	854a                	mv	a0,s2
    8000781a:	ffffa097          	auipc	ra,0xffffa
    8000781e:	914080e7          	jalr	-1772(ra) # 8000112e <memset>
    p += sz;
    80007822:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80007824:	2985                	addiw	s3,s3,1
    80007826:	000aa783          	lw	a5,0(s5)
    8000782a:	020a0a13          	addi	s4,s4,32
    8000782e:	faf9cfe3          	blt	s3,a5,800077ec <bd_init+0x14c>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80007832:	197d                	addi	s2,s2,-1
    80007834:	ff097913          	andi	s2,s2,-16
    80007838:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    8000783a:	854a                	mv	a0,s2
    8000783c:	00000097          	auipc	ra,0x0
    80007840:	d70080e7          	jalr	-656(ra) # 800075ac <bd_mark_data_structures>
    80007844:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80007846:	85ca                	mv	a1,s2
    80007848:	8562                	mv	a0,s8
    8000784a:	00000097          	auipc	ra,0x0
    8000784e:	dc4080e7          	jalr	-572(ra) # 8000760e <bd_mark_unavailable>
    80007852:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007854:	00027a97          	auipc	s5,0x27
    80007858:	84ca8a93          	addi	s5,s5,-1972 # 8002e0a0 <nsizes>
    8000785c:	000aa783          	lw	a5,0(s5)
    80007860:	37fd                	addiw	a5,a5,-1
    80007862:	44c1                	li	s1,16
    80007864:	00f497b3          	sll	a5,s1,a5
    80007868:	8f89                	sub	a5,a5,a0
    8000786a:	00027717          	auipc	a4,0x27
    8000786e:	82670713          	addi	a4,a4,-2010 # 8002e090 <bd_base>
    80007872:	630c                	ld	a1,0(a4)
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80007874:	95be                	add	a1,a1,a5
    80007876:	854a                	mv	a0,s2
    80007878:	00000097          	auipc	ra,0x0
    8000787c:	c76080e7          	jalr	-906(ra) # 800074ee <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80007880:	000aa603          	lw	a2,0(s5)
    80007884:	367d                	addiw	a2,a2,-1
    80007886:	00c49633          	sll	a2,s1,a2
    8000788a:	41460633          	sub	a2,a2,s4
    8000788e:	41360633          	sub	a2,a2,s3
    80007892:	02c51463          	bne	a0,a2,800078ba <bd_init+0x21a>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80007896:	60a6                	ld	ra,72(sp)
    80007898:	6406                	ld	s0,64(sp)
    8000789a:	74e2                	ld	s1,56(sp)
    8000789c:	7942                	ld	s2,48(sp)
    8000789e:	79a2                	ld	s3,40(sp)
    800078a0:	7a02                	ld	s4,32(sp)
    800078a2:	6ae2                	ld	s5,24(sp)
    800078a4:	6b42                	ld	s6,16(sp)
    800078a6:	6ba2                	ld	s7,8(sp)
    800078a8:	6c02                	ld	s8,0(sp)
    800078aa:	6161                	addi	sp,sp,80
    800078ac:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800078ae:	2509                	addiw	a0,a0,2
    800078b0:	00026797          	auipc	a5,0x26
    800078b4:	7ea7a823          	sw	a0,2032(a5) # 8002e0a0 <nsizes>
    800078b8:	bd91                	j	8000770c <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    800078ba:	85aa                	mv	a1,a0
    800078bc:	00001517          	auipc	a0,0x1
    800078c0:	5ec50513          	addi	a0,a0,1516 # 80008ea8 <userret+0xe18>
    800078c4:	ffff9097          	auipc	ra,0xffff9
    800078c8:	0d8080e7          	jalr	216(ra) # 8000099c <printf>
    panic("bd_init: free mem");
    800078cc:	00001517          	auipc	a0,0x1
    800078d0:	5ec50513          	addi	a0,a0,1516 # 80008eb8 <userret+0xe28>
    800078d4:	ffff9097          	auipc	ra,0xffff9
    800078d8:	eb0080e7          	jalr	-336(ra) # 80000784 <panic>

00000000800078dc <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    800078dc:	1141                	addi	sp,sp,-16
    800078de:	e422                	sd	s0,8(sp)
    800078e0:	0800                	addi	s0,sp,16
  lst->next = lst;
    800078e2:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    800078e4:	e508                	sd	a0,8(a0)
}
    800078e6:	6422                	ld	s0,8(sp)
    800078e8:	0141                	addi	sp,sp,16
    800078ea:	8082                	ret

00000000800078ec <lst_empty>:

int
lst_empty(struct list *lst) {
    800078ec:	1141                	addi	sp,sp,-16
    800078ee:	e422                	sd	s0,8(sp)
    800078f0:	0800                	addi	s0,sp,16
  return lst->next == lst;
    800078f2:	611c                	ld	a5,0(a0)
    800078f4:	40a78533          	sub	a0,a5,a0
}
    800078f8:	00153513          	seqz	a0,a0
    800078fc:	6422                	ld	s0,8(sp)
    800078fe:	0141                	addi	sp,sp,16
    80007900:	8082                	ret

0000000080007902 <lst_remove>:

void
lst_remove(struct list *e) {
    80007902:	1141                	addi	sp,sp,-16
    80007904:	e422                	sd	s0,8(sp)
    80007906:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007908:	6518                	ld	a4,8(a0)
    8000790a:	611c                	ld	a5,0(a0)
    8000790c:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000790e:	6518                	ld	a4,8(a0)
    80007910:	e798                	sd	a4,8(a5)
}
    80007912:	6422                	ld	s0,8(sp)
    80007914:	0141                	addi	sp,sp,16
    80007916:	8082                	ret

0000000080007918 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007918:	1101                	addi	sp,sp,-32
    8000791a:	ec06                	sd	ra,24(sp)
    8000791c:	e822                	sd	s0,16(sp)
    8000791e:	e426                	sd	s1,8(sp)
    80007920:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007922:	6104                	ld	s1,0(a0)
    80007924:	00a48d63          	beq	s1,a0,8000793e <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007928:	8526                	mv	a0,s1
    8000792a:	00000097          	auipc	ra,0x0
    8000792e:	fd8080e7          	jalr	-40(ra) # 80007902 <lst_remove>
  return (void *)p;
}
    80007932:	8526                	mv	a0,s1
    80007934:	60e2                	ld	ra,24(sp)
    80007936:	6442                	ld	s0,16(sp)
    80007938:	64a2                	ld	s1,8(sp)
    8000793a:	6105                	addi	sp,sp,32
    8000793c:	8082                	ret
    panic("lst_pop");
    8000793e:	00001517          	auipc	a0,0x1
    80007942:	59250513          	addi	a0,a0,1426 # 80008ed0 <userret+0xe40>
    80007946:	ffff9097          	auipc	ra,0xffff9
    8000794a:	e3e080e7          	jalr	-450(ra) # 80000784 <panic>

000000008000794e <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    8000794e:	1141                	addi	sp,sp,-16
    80007950:	e422                	sd	s0,8(sp)
    80007952:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80007954:	611c                	ld	a5,0(a0)
    80007956:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80007958:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    8000795a:	611c                	ld	a5,0(a0)
    8000795c:	e78c                	sd	a1,8(a5)
  lst->next = e;
    8000795e:	e10c                	sd	a1,0(a0)
}
    80007960:	6422                	ld	s0,8(sp)
    80007962:	0141                	addi	sp,sp,16
    80007964:	8082                	ret

0000000080007966 <lst_print>:

void
lst_print(struct list *lst)
{
    80007966:	7179                	addi	sp,sp,-48
    80007968:	f406                	sd	ra,40(sp)
    8000796a:	f022                	sd	s0,32(sp)
    8000796c:	ec26                	sd	s1,24(sp)
    8000796e:	e84a                	sd	s2,16(sp)
    80007970:	e44e                	sd	s3,8(sp)
    80007972:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007974:	6104                	ld	s1,0(a0)
    80007976:	02950063          	beq	a0,s1,80007996 <lst_print+0x30>
    8000797a:	892a                	mv	s2,a0
    printf(" %p", p);
    8000797c:	00001997          	auipc	s3,0x1
    80007980:	55c98993          	addi	s3,s3,1372 # 80008ed8 <userret+0xe48>
    80007984:	85a6                	mv	a1,s1
    80007986:	854e                	mv	a0,s3
    80007988:	ffff9097          	auipc	ra,0xffff9
    8000798c:	014080e7          	jalr	20(ra) # 8000099c <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007990:	6084                	ld	s1,0(s1)
    80007992:	fe9919e3          	bne	s2,s1,80007984 <lst_print+0x1e>
  }
  printf("\n");
    80007996:	00001517          	auipc	a0,0x1
    8000799a:	cb250513          	addi	a0,a0,-846 # 80008648 <userret+0x5b8>
    8000799e:	ffff9097          	auipc	ra,0xffff9
    800079a2:	ffe080e7          	jalr	-2(ra) # 8000099c <printf>
}
    800079a6:	70a2                	ld	ra,40(sp)
    800079a8:	7402                	ld	s0,32(sp)
    800079aa:	64e2                	ld	s1,24(sp)
    800079ac:	6942                	ld	s2,16(sp)
    800079ae:	69a2                	ld	s3,8(sp)
    800079b0:	6145                	addi	sp,sp,48
    800079b2:	8082                	ret

00000000800079b4 <watchdogwrite>:
int watchdog_time;
struct spinlock watchdog_lock;

int
watchdogwrite(struct file *f, int user_src, uint64 src, int n)
{
    800079b4:	715d                	addi	sp,sp,-80
    800079b6:	e486                	sd	ra,72(sp)
    800079b8:	e0a2                	sd	s0,64(sp)
    800079ba:	fc26                	sd	s1,56(sp)
    800079bc:	f84a                	sd	s2,48(sp)
    800079be:	f44e                	sd	s3,40(sp)
    800079c0:	f052                	sd	s4,32(sp)
    800079c2:	ec56                	sd	s5,24(sp)
    800079c4:	0880                	addi	s0,sp,80
    800079c6:	8a2e                	mv	s4,a1
    800079c8:	84b2                	mv	s1,a2
    800079ca:	89b6                	mv	s3,a3
  acquire(&watchdog_lock);
    800079cc:	00026517          	auipc	a0,0x26
    800079d0:	66450513          	addi	a0,a0,1636 # 8002e030 <watchdog_lock>
    800079d4:	ffff9097          	auipc	ra,0xffff9
    800079d8:	2e6080e7          	jalr	742(ra) # 80000cba <acquire>

  int time = 0;
  for(int i = 0; i < n; i++){
    800079dc:	09305e63          	blez	s3,80007a78 <watchdogwrite+0xc4>
    800079e0:	00148913          	addi	s2,s1,1
    800079e4:	39fd                	addiw	s3,s3,-1
    800079e6:	1982                	slli	s3,s3,0x20
    800079e8:	0209d993          	srli	s3,s3,0x20
    800079ec:	994e                	add	s2,s2,s3
  int time = 0;
    800079ee:	4981                	li	s3,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800079f0:	5afd                	li	s5,-1
    800079f2:	4685                	li	a3,1
    800079f4:	8626                	mv	a2,s1
    800079f6:	85d2                	mv	a1,s4
    800079f8:	fbf40513          	addi	a0,s0,-65
    800079fc:	ffffb097          	auipc	ra,0xffffb
    80007a00:	100080e7          	jalr	256(ra) # 80002afc <either_copyin>
    80007a04:	01550763          	beq	a0,s5,80007a12 <watchdogwrite+0x5e>
      break;
    time = c;
    80007a08:	fbf44983          	lbu	s3,-65(s0)
    80007a0c:	0485                	addi	s1,s1,1
  for(int i = 0; i < n; i++){
    80007a0e:	ff2492e3          	bne	s1,s2,800079f2 <watchdogwrite+0x3e>
  }

  acquire(&tickslock);
    80007a12:	00014517          	auipc	a0,0x14
    80007a16:	68650513          	addi	a0,a0,1670 # 8001c098 <tickslock>
    80007a1a:	ffff9097          	auipc	ra,0xffff9
    80007a1e:	2a0080e7          	jalr	672(ra) # 80000cba <acquire>
  n = ticks - watchdog_value;
    80007a22:	00026797          	auipc	a5,0x26
    80007a26:	66678793          	addi	a5,a5,1638 # 8002e088 <ticks>
    80007a2a:	4398                	lw	a4,0(a5)
    80007a2c:	00026797          	auipc	a5,0x26
    80007a30:	67c78793          	addi	a5,a5,1660 # 8002e0a8 <watchdog_value>
    80007a34:	4384                	lw	s1,0(a5)
    80007a36:	409704bb          	subw	s1,a4,s1
  watchdog_value = ticks;
    80007a3a:	c398                	sw	a4,0(a5)
  watchdog_time = time;
    80007a3c:	00026797          	auipc	a5,0x26
    80007a40:	6737a423          	sw	s3,1640(a5) # 8002e0a4 <watchdog_time>
  release(&tickslock);
    80007a44:	00014517          	auipc	a0,0x14
    80007a48:	65450513          	addi	a0,a0,1620 # 8001c098 <tickslock>
    80007a4c:	ffff9097          	auipc	ra,0xffff9
    80007a50:	4ba080e7          	jalr	1210(ra) # 80000f06 <release>

  release(&watchdog_lock);
    80007a54:	00026517          	auipc	a0,0x26
    80007a58:	5dc50513          	addi	a0,a0,1500 # 8002e030 <watchdog_lock>
    80007a5c:	ffff9097          	auipc	ra,0xffff9
    80007a60:	4aa080e7          	jalr	1194(ra) # 80000f06 <release>
  return n;
}
    80007a64:	8526                	mv	a0,s1
    80007a66:	60a6                	ld	ra,72(sp)
    80007a68:	6406                	ld	s0,64(sp)
    80007a6a:	74e2                	ld	s1,56(sp)
    80007a6c:	7942                	ld	s2,48(sp)
    80007a6e:	79a2                	ld	s3,40(sp)
    80007a70:	7a02                	ld	s4,32(sp)
    80007a72:	6ae2                	ld	s5,24(sp)
    80007a74:	6161                	addi	sp,sp,80
    80007a76:	8082                	ret
  int time = 0;
    80007a78:	4981                	li	s3,0
    80007a7a:	bf61                	j	80007a12 <watchdogwrite+0x5e>

0000000080007a7c <watchdoginit>:

void watchdoginit(){
    80007a7c:	1141                	addi	sp,sp,-16
    80007a7e:	e406                	sd	ra,8(sp)
    80007a80:	e022                	sd	s0,0(sp)
    80007a82:	0800                	addi	s0,sp,16
  initlock(&watchdog_lock, "watchdog_lock");
    80007a84:	00001597          	auipc	a1,0x1
    80007a88:	45c58593          	addi	a1,a1,1116 # 80008ee0 <userret+0xe50>
    80007a8c:	00026517          	auipc	a0,0x26
    80007a90:	5a450513          	addi	a0,a0,1444 # 8002e030 <watchdog_lock>
    80007a94:	ffff9097          	auipc	ra,0xffff9
    80007a98:	0b8080e7          	jalr	184(ra) # 80000b4c <initlock>
  watchdog_time = 0;
    80007a9c:	00026797          	auipc	a5,0x26
    80007aa0:	6007a423          	sw	zero,1544(a5) # 8002e0a4 <watchdog_time>


  devsw[WATCHDOG].read = 0;
    80007aa4:	0001f797          	auipc	a5,0x1f
    80007aa8:	0f478793          	addi	a5,a5,244 # 80026b98 <devsw>
    80007aac:	0207b023          	sd	zero,32(a5)
  devsw[WATCHDOG].write = watchdogwrite;
    80007ab0:	00000717          	auipc	a4,0x0
    80007ab4:	f0470713          	addi	a4,a4,-252 # 800079b4 <watchdogwrite>
    80007ab8:	f798                	sd	a4,40(a5)
}
    80007aba:	60a2                	ld	ra,8(sp)
    80007abc:	6402                	ld	s0,0(sp)
    80007abe:	0141                	addi	sp,sp,16
    80007ac0:	8082                	ret
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
