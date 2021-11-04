
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
    8000005e:	00007797          	auipc	a5,0x7
    80000062:	87278793          	addi	a5,a5,-1934 # 800068d0 <timervec>
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
    80000096:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffce753>
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
    80000144:	00030717          	auipc	a4,0x30
    80000148:	f2470713          	addi	a4,a4,-220 # 80030068 <console_number>
    8000014c:	4318                	lw	a4,0(a4)
    8000014e:	02e78763          	beq	a5,a4,8000017c <consoleread+0x8e>
    sleep(cons, &console_number_lock);
    80000152:	00014c97          	auipc	s9,0x14
    80000156:	8eec8c93          	addi	s9,s9,-1810 # 80013a40 <console_number_lock>
  while(console_number != f->minor - 1){
    8000015a:	00030c17          	auipc	s8,0x30
    8000015e:	f0ec0c13          	addi	s8,s8,-242 # 80030068 <console_number>
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
    80000286:	00030797          	auipc	a5,0x30
    8000028a:	de678793          	addi	a5,a5,-538 # 8003006c <panicked>
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
    80000326:	00030717          	auipc	a4,0x30
    8000032a:	d4270713          	addi	a4,a4,-702 # 80030068 <console_number>
    8000032e:	4318                	lw	a4,0(a4)
    80000330:	02e78763          	beq	a5,a4,8000035e <consolewrite+0x86>
    sleep(cons, &console_number_lock);
    80000334:	00013b97          	auipc	s7,0x13
    80000338:	70cb8b93          	addi	s7,s7,1804 # 80013a40 <console_number_lock>
  while(console_number != f->minor - 1){
    8000033c:	00030b17          	auipc	s6,0x30
    80000340:	d2cb0b13          	addi	s6,s6,-724 # 80030068 <console_number>
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
    800003e8:	00030797          	auipc	a5,0x30
    800003ec:	c7878793          	addi	a5,a5,-904 # 80030060 <cons>
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
    8000042a:	00030917          	auipc	s2,0x30
    8000042e:	c3690913          	addi	s2,s2,-970 # 80030060 <cons>
    80000432:	00093a03          	ld	s4,0(s2)
    console_number = (console_number + 1) % NBCONSOLES;
    80000436:	00030497          	auipc	s1,0x30
    8000043a:	c3248493          	addi	s1,s1,-974 # 80030068 <console_number>
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
    800004b4:	00030797          	auipc	a5,0x30
    800004b8:	bac78793          	addi	a5,a5,-1108 # 80030060 <cons>
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
    800004e0:	00030797          	auipc	a5,0x30
    800004e4:	b8078793          	addi	a5,a5,-1152 # 80030060 <cons>
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
    80000520:	00030797          	auipc	a5,0x30
    80000524:	b4078793          	addi	a5,a5,-1216 # 80030060 <cons>
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
    80000548:	00030497          	auipc	s1,0x30
    8000054c:	b1848493          	addi	s1,s1,-1256 # 80030060 <cons>
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
    80000592:	00030797          	auipc	a5,0x30
    80000596:	ace78793          	addi	a5,a5,-1330 # 80030060 <cons>
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
    800005c8:	00030797          	auipc	a5,0x30
    800005cc:	a9878793          	addi	a5,a5,-1384 # 80030060 <cons>
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
    800005fc:	00030797          	auipc	a5,0x30
    80000600:	a6478793          	addi	a5,a5,-1436 # 80030060 <cons>
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
    8000065e:	00030797          	auipc	a5,0x30
    80000662:	a007a523          	sw	zero,-1526(a5) # 80030068 <console_number>
  cons = &consoles[console_number];
    80000666:	00030797          	auipc	a5,0x30
    8000066a:	9e97bd23          	sd	s1,-1542(a5) # 80030060 <cons>
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
    800007d4:	00030717          	auipc	a4,0x30
    800007d8:	88f72c23          	sw	a5,-1896(a4) # 8003006c <panicked>
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
    80000afe:	00030517          	auipc	a0,0x30
    80000b02:	5ad50513          	addi	a0,a0,1453 # 800310ab <end+0xfff>
    80000b06:	77fd                	lui	a5,0xfffff
    80000b08:	8d7d                	and	a0,a0,a5
    80000b0a:	00007097          	auipc	ra,0x7
    80000b0e:	ec6080e7          	jalr	-314(ra) # 800079d0 <bd_init>
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
    80000b22:	00007097          	auipc	ra,0x7
    80000b26:	9da080e7          	jalr	-1574(ra) # 800074fc <bd_free>
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
    80000b40:	7bc080e7          	jalr	1980(ra) # 800072f8 <bd_malloc>
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
    80000b5e:	0002f797          	auipc	a5,0x2f
    80000b62:	51278793          	addi	a5,a5,1298 # 80030070 <nlock>
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
    80000b82:	0002f717          	auipc	a4,0x2f
    80000b86:	4ef72723          	sw	a5,1262(a4) # 80030070 <nlock>
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
    80000bc6:	0002f797          	auipc	a5,0x2f
    80000bca:	4aa78793          	addi	a5,a5,1194 # 80030070 <nlock>
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
    80000bee:	0002f997          	auipc	s3,0x2f
    80000bf2:	48298993          	addi	s3,s3,1154 # 80030070 <nlock>
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
    80000f9a:	45e080e7          	jalr	1118(ra) # 800033f4 <argint>
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
    8000133a:	fc2080e7          	jalr	-62(ra) # 800072f8 <bd_malloc>
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
    800013c2:	f3a080e7          	jalr	-198(ra) # 800072f8 <bd_malloc>
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
    800013f4:	0002f717          	auipc	a4,0x2f
    800013f8:	c8070713          	addi	a4,a4,-896 # 80030074 <started>
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
    8000142e:	af8080e7          	jalr	-1288(ra) # 80002f22 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001432:	00005097          	auipc	ra,0x5
    80001436:	4de080e7          	jalr	1246(ra) # 80006910 <plicinithart>
  }

  scheduler();        
    8000143a:	00001097          	auipc	ra,0x1
    8000143e:	1e4080e7          	jalr	484(ra) # 8000261e <scheduler>
    consoleinit();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	1f2080e7          	jalr	498(ra) # 80000634 <consoleinit>
    watchdoginit();
    8000144a:	00007097          	auipc	ra,0x7
    8000144e:	962080e7          	jalr	-1694(ra) # 80007dac <watchdoginit>
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
    800014ae:	a50080e7          	jalr	-1456(ra) # 80002efa <trapinit>
    trapinithart();  // install kernel trap vector
    800014b2:	00002097          	auipc	ra,0x2
    800014b6:	a70080e7          	jalr	-1424(ra) # 80002f22 <trapinithart>
    plicinit();      // set up interrupt controller
    800014ba:	00005097          	auipc	ra,0x5
    800014be:	440080e7          	jalr	1088(ra) # 800068fa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800014c2:	00005097          	auipc	ra,0x5
    800014c6:	44e080e7          	jalr	1102(ra) # 80006910 <plicinithart>
    binit();         // buffer cache
    800014ca:	00002097          	auipc	ra,0x2
    800014ce:	26e080e7          	jalr	622(ra) # 80003738 <binit>
    iinit();         // inode cache
    800014d2:	00003097          	auipc	ra,0x3
    800014d6:	944080e7          	jalr	-1724(ra) # 80003e16 <iinit>
    fileinit();      // file table
    800014da:	00004097          	auipc	ra,0x4
    800014de:	9d6080e7          	jalr	-1578(ra) # 80004eb0 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    800014e2:	4501                	li	a0,0
    800014e4:	00005097          	auipc	ra,0x5
    800014e8:	54c080e7          	jalr	1356(ra) # 80006a30 <virtio_disk_init>
    userinit();      // first user process
    800014ec:	00001097          	auipc	ra,0x1
    800014f0:	de4080e7          	jalr	-540(ra) # 800022d0 <userinit>
    __sync_synchronize();
    800014f4:	0ff0000f          	fence
    started = 1;
    800014f8:	4785                	li	a5,1
    800014fa:	0002f717          	auipc	a4,0x2f
    800014fe:	b6f72d23          	sw	a5,-1158(a4) # 80030074 <started>
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
    8000161a:	0002f797          	auipc	a5,0x2f
    8000161e:	a5e78793          	addi	a5,a5,-1442 # 80030078 <kernel_pagetable>
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
    80001692:	0002f797          	auipc	a5,0x2f
    80001696:	9e678793          	addi	a5,a5,-1562 # 80030078 <kernel_pagetable>
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
    80001778:	0002f797          	auipc	a5,0x2f
    8000177c:	90078793          	addi	a5,a5,-1792 # 80030078 <kernel_pagetable>
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
    800017b6:	0002f797          	auipc	a5,0x2f
    800017ba:	8ca7b123          	sd	a0,-1854(a5) # 80030078 <kernel_pagetable>
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
    80001e58:	4a4080e7          	jalr	1188(ra) # 800072f8 <bd_malloc>
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
    80001eea:	616080e7          	jalr	1558(ra) # 800074fc <bd_free>
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
    80002094:	fc878793          	addi	a5,a5,-56 # 8000a058 <first.1820>
    80002098:	439c                	lw	a5,0(a5)
    8000209a:	eb89                	bnez	a5,800020ac <forkret+0x34>
  usertrapret();
    8000209c:	00001097          	auipc	ra,0x1
    800020a0:	e9e080e7          	jalr	-354(ra) # 80002f3a <usertrapret>
}
    800020a4:	60a2                	ld	ra,8(sp)
    800020a6:	6402                	ld	s0,0(sp)
    800020a8:	0141                	addi	sp,sp,16
    800020aa:	8082                	ret
    first = 0;
    800020ac:	00008797          	auipc	a5,0x8
    800020b0:	fa07a623          	sw	zero,-84(a5) # 8000a058 <first.1820>
    fsinit(minor(ROOTDEV));
    800020b4:	4501                	li	a0,0
    800020b6:	00002097          	auipc	ra,0x2
    800020ba:	ce2080e7          	jalr	-798(ra) # 80003d98 <fsinit>
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
    80002296:	26a080e7          	jalr	618(ra) # 800074fc <bd_free>
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
    800022e6:	0002e797          	auipc	a5,0x2e
    800022ea:	d8a7bd23          	sd	a0,-614(a5) # 80030080 <initproc>
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
    80002348:	462080e7          	jalr	1122(ra) # 800047a6 <namei>
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
    800024ae:	aac080e7          	jalr	-1364(ra) # 80004f56 <filedup>
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
    800024d0:	b08080e7          	jalr	-1272(ra) # 80003fd4 <idup>
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
    80002564:	0002ea17          	auipc	s4,0x2e
    80002568:	b1ca0a13          	addi	s4,s4,-1252 # 80030080 <initproc>
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
    800026bc:	73e080e7          	jalr	1854(ra) # 80002df6 <swtch>
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
    8000274e:	6ac080e7          	jalr	1708(ra) # 80002df6 <swtch>
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
    800027c8:	0002e797          	auipc	a5,0x2e
    800027cc:	8b878793          	addi	a5,a5,-1864 # 80030080 <initproc>
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
    800027f2:	7ba080e7          	jalr	1978(ra) # 80004fa8 <fileclose>
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
    8000280c:	1e4080e7          	jalr	484(ra) # 800049ec <begin_op>
  iput(p->cwd);
    80002810:	1689b503          	ld	a0,360(s3)
    80002814:	00002097          	auipc	ra,0x2
    80002818:	90e080e7          	jalr	-1778(ra) # 80004122 <iput>
  end_op(ROOTDEV);
    8000281c:	4501                	li	a0,0
    8000281e:	00002097          	auipc	ra,0x2
    80002822:	27a080e7          	jalr	634(ra) # 80004a98 <end_op>
  p->cwd = 0;
    80002826:	1609b423          	sd	zero,360(s3)
  acquire(&initproc->lock);
    8000282a:	0002e497          	auipc	s1,0x2e
    8000282e:	85648493          	addi	s1,s1,-1962 # 80030080 <initproc>
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
    80002c90:	27cc0c13          	addi	s8,s8,636 # 80008f08 <states.1860>
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
  for (int i = 0; i<NPROC; i++) {
    if (proc[i].pid == pid) {
    80002d86:	00013797          	auipc	a5,0x13
    80002d8a:	11278793          	addi	a5,a5,274 # 80015e98 <proc>
    80002d8e:	4bbc                	lw	a5,80(a5)
    80002d90:	02a78363          	beq	a5,a0,80002db6 <nice+0x30>
    80002d94:	00013717          	auipc	a4,0x13
    80002d98:	2dc70713          	addi	a4,a4,732 # 80016070 <proc+0x1d8>
  for (int i = 0; i<NPROC; i++) {
    80002d9c:	4785                	li	a5,1
    80002d9e:	04000613          	li	a2,64
    if (proc[i].pid == pid) {
    80002da2:	4314                	lw	a3,0(a4)
    80002da4:	00a68a63          	beq	a3,a0,80002db8 <nice+0x32>
  for (int i = 0; i<NPROC; i++) {
    80002da8:	2785                	addiw	a5,a5,1
    80002daa:	18870713          	addi	a4,a4,392
    80002dae:	fec79ae3          	bne	a5,a2,80002da2 <nice+0x1c>
      remove_from_prio_queue(&proc[i]);
      insert_into_prio_queue(&proc[i]);
      return 1;
    }
  }
  return 0;
    80002db2:	4501                	li	a0,0
}
    80002db4:	8082                	ret
  for (int i = 0; i<NPROC; i++) {
    80002db6:	4781                	li	a5,0
int nice(int pid, int priority) {
    80002db8:	1101                	addi	sp,sp,-32
    80002dba:	ec06                	sd	ra,24(sp)
    80002dbc:	e822                	sd	s0,16(sp)
    80002dbe:	e426                	sd	s1,8(sp)
    80002dc0:	1000                	addi	s0,sp,32
      proc[i].priority = priority;
    80002dc2:	18800713          	li	a4,392
    80002dc6:	02e787b3          	mul	a5,a5,a4
    80002dca:	00013497          	auipc	s1,0x13
    80002dce:	0ce48493          	addi	s1,s1,206 # 80015e98 <proc>
    80002dd2:	94be                	add	s1,s1,a5
    80002dd4:	c8ec                	sw	a1,84(s1)
      remove_from_prio_queue(&proc[i]);
    80002dd6:	8526                	mv	a0,s1
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	0c8080e7          	jalr	200(ra) # 80001ea0 <remove_from_prio_queue>
      insert_into_prio_queue(&proc[i]);
    80002de0:	8526                	mv	a0,s1
    80002de2:	fffff097          	auipc	ra,0xfffff
    80002de6:	064080e7          	jalr	100(ra) # 80001e46 <insert_into_prio_queue>
      return 1;
    80002dea:	4505                	li	a0,1
}
    80002dec:	60e2                	ld	ra,24(sp)
    80002dee:	6442                	ld	s0,16(sp)
    80002df0:	64a2                	ld	s1,8(sp)
    80002df2:	6105                	addi	sp,sp,32
    80002df4:	8082                	ret

0000000080002df6 <swtch>:
    80002df6:	00153023          	sd	ra,0(a0)
    80002dfa:	00253423          	sd	sp,8(a0)
    80002dfe:	e900                	sd	s0,16(a0)
    80002e00:	ed04                	sd	s1,24(a0)
    80002e02:	03253023          	sd	s2,32(a0)
    80002e06:	03353423          	sd	s3,40(a0)
    80002e0a:	03453823          	sd	s4,48(a0)
    80002e0e:	03553c23          	sd	s5,56(a0)
    80002e12:	05653023          	sd	s6,64(a0)
    80002e16:	05753423          	sd	s7,72(a0)
    80002e1a:	05853823          	sd	s8,80(a0)
    80002e1e:	05953c23          	sd	s9,88(a0)
    80002e22:	07a53023          	sd	s10,96(a0)
    80002e26:	07b53423          	sd	s11,104(a0)
    80002e2a:	0005b083          	ld	ra,0(a1)
    80002e2e:	0085b103          	ld	sp,8(a1)
    80002e32:	6980                	ld	s0,16(a1)
    80002e34:	6d84                	ld	s1,24(a1)
    80002e36:	0205b903          	ld	s2,32(a1)
    80002e3a:	0285b983          	ld	s3,40(a1)
    80002e3e:	0305ba03          	ld	s4,48(a1)
    80002e42:	0385ba83          	ld	s5,56(a1)
    80002e46:	0405bb03          	ld	s6,64(a1)
    80002e4a:	0485bb83          	ld	s7,72(a1)
    80002e4e:	0505bc03          	ld	s8,80(a1)
    80002e52:	0585bc83          	ld	s9,88(a1)
    80002e56:	0605bd03          	ld	s10,96(a1)
    80002e5a:	0685bd83          	ld	s11,104(a1)
    80002e5e:	8082                	ret

0000000080002e60 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002e60:	1141                	addi	sp,sp,-16
    80002e62:	e422                	sd	s0,8(sp)
    80002e64:	0800                	addi	s0,sp,16
    80002e66:	872a                	mv	a4,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002e68:	57fd                	li	a5,-1
    80002e6a:	8385                	srli	a5,a5,0x1
    80002e6c:	8fe9                	and	a5,a5,a0
  if (interrupt) {
    80002e6e:	04054c63          	bltz	a0,80002ec6 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002e72:	5685                	li	a3,-31
    80002e74:	8285                	srli	a3,a3,0x1
    80002e76:	8ee9                	and	a3,a3,a0
    80002e78:	caad                	beqz	a3,80002eea <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002e7a:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002e7c:	00006517          	auipc	a0,0x6
    80002e80:	84450513          	addi	a0,a0,-1980 # 800086c0 <userret+0x630>
    } else if (code <= 23) {
    80002e84:	06f6f063          	bleu	a5,a3,80002ee4 <scause_desc+0x84>
    } else if (code <= 31) {
    80002e88:	fc100693          	li	a3,-63
    80002e8c:	8285                	srli	a3,a3,0x1
    80002e8e:	8ef9                	and	a3,a3,a4
      return "<reserved for custom use>";
    80002e90:	00006517          	auipc	a0,0x6
    80002e94:	85850513          	addi	a0,a0,-1960 # 800086e8 <userret+0x658>
    } else if (code <= 31) {
    80002e98:	c6b1                	beqz	a3,80002ee4 <scause_desc+0x84>
    } else if (code <= 47) {
    80002e9a:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    80002e9e:	00006517          	auipc	a0,0x6
    80002ea2:	82250513          	addi	a0,a0,-2014 # 800086c0 <userret+0x630>
    } else if (code <= 47) {
    80002ea6:	02f6ff63          	bleu	a5,a3,80002ee4 <scause_desc+0x84>
    } else if (code <= 63) {
    80002eaa:	f8100513          	li	a0,-127
    80002eae:	8105                	srli	a0,a0,0x1
    80002eb0:	8f69                	and	a4,a4,a0
      return "<reserved for custom use>";
    80002eb2:	00006517          	auipc	a0,0x6
    80002eb6:	83650513          	addi	a0,a0,-1994 # 800086e8 <userret+0x658>
    } else if (code <= 63) {
    80002eba:	c70d                	beqz	a4,80002ee4 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    80002ebc:	00006517          	auipc	a0,0x6
    80002ec0:	80450513          	addi	a0,a0,-2044 # 800086c0 <userret+0x630>
    80002ec4:	a005                	j	80002ee4 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    80002ec6:	5505                	li	a0,-31
    80002ec8:	8105                	srli	a0,a0,0x1
    80002eca:	8f69                	and	a4,a4,a0
      return "<reserved for platform use>";
    80002ecc:	00006517          	auipc	a0,0x6
    80002ed0:	83c50513          	addi	a0,a0,-1988 # 80008708 <userret+0x678>
    if (code < NELEM(intr_desc)) {
    80002ed4:	eb01                	bnez	a4,80002ee4 <scause_desc+0x84>
      return intr_desc[code];
    80002ed6:	078e                	slli	a5,a5,0x3
    80002ed8:	00006717          	auipc	a4,0x6
    80002edc:	05870713          	addi	a4,a4,88 # 80008f30 <intr_desc.1654>
    80002ee0:	97ba                	add	a5,a5,a4
    80002ee2:	6388                	ld	a0,0(a5)
    }
  }
}
    80002ee4:	6422                	ld	s0,8(sp)
    80002ee6:	0141                	addi	sp,sp,16
    80002ee8:	8082                	ret
      return nointr_desc[code];
    80002eea:	078e                	slli	a5,a5,0x3
    80002eec:	00006717          	auipc	a4,0x6
    80002ef0:	04470713          	addi	a4,a4,68 # 80008f30 <intr_desc.1654>
    80002ef4:	97ba                	add	a5,a5,a4
    80002ef6:	63c8                	ld	a0,128(a5)
    80002ef8:	b7f5                	j	80002ee4 <scause_desc+0x84>

0000000080002efa <trapinit>:
{
    80002efa:	1141                	addi	sp,sp,-16
    80002efc:	e406                	sd	ra,8(sp)
    80002efe:	e022                	sd	s0,0(sp)
    80002f00:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002f02:	00006597          	auipc	a1,0x6
    80002f06:	82658593          	addi	a1,a1,-2010 # 80008728 <userret+0x698>
    80002f0a:	00019517          	auipc	a0,0x19
    80002f0e:	18e50513          	addi	a0,a0,398 # 8001c098 <tickslock>
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	c3a080e7          	jalr	-966(ra) # 80000b4c <initlock>
}
    80002f1a:	60a2                	ld	ra,8(sp)
    80002f1c:	6402                	ld	s0,0(sp)
    80002f1e:	0141                	addi	sp,sp,16
    80002f20:	8082                	ret

0000000080002f22 <trapinithart>:
{
    80002f22:	1141                	addi	sp,sp,-16
    80002f24:	e422                	sd	s0,8(sp)
    80002f26:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f28:	00004797          	auipc	a5,0x4
    80002f2c:	91878793          	addi	a5,a5,-1768 # 80006840 <kernelvec>
    80002f30:	10579073          	csrw	stvec,a5
}
    80002f34:	6422                	ld	s0,8(sp)
    80002f36:	0141                	addi	sp,sp,16
    80002f38:	8082                	ret

0000000080002f3a <usertrapret>:
{
    80002f3a:	1141                	addi	sp,sp,-16
    80002f3c:	e406                	sd	ra,8(sp)
    80002f3e:	e022                	sd	s0,0(sp)
    80002f40:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002f42:	fffff097          	auipc	ra,0xfffff
    80002f46:	0fe080e7          	jalr	254(ra) # 80002040 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f4a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002f4e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f50:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002f54:	00005617          	auipc	a2,0x5
    80002f58:	0ac60613          	addi	a2,a2,172 # 80008000 <trampoline>
    80002f5c:	00005697          	auipc	a3,0x5
    80002f60:	0a468693          	addi	a3,a3,164 # 80008000 <trampoline>
    80002f64:	8e91                	sub	a3,a3,a2
    80002f66:	040007b7          	lui	a5,0x4000
    80002f6a:	17fd                	addi	a5,a5,-1
    80002f6c:	07b2                	slli	a5,a5,0xc
    80002f6e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f70:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002f74:	7938                	ld	a4,112(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002f76:	180026f3          	csrr	a3,satp
    80002f7a:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002f7c:	7938                	ld	a4,112(a0)
    80002f7e:	6d34                	ld	a3,88(a0)
    80002f80:	6585                	lui	a1,0x1
    80002f82:	96ae                	add	a3,a3,a1
    80002f84:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002f86:	7938                	ld	a4,112(a0)
    80002f88:	00000697          	auipc	a3,0x0
    80002f8c:	18468693          	addi	a3,a3,388 # 8000310c <usertrap>
    80002f90:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    80002f92:	7938                	ld	a4,112(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002f94:	8692                	mv	a3,tp
    80002f96:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f98:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002f9c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002fa0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fa4:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    80002fa8:	7938                	ld	a4,112(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002faa:	6f18                	ld	a4,24(a4)
    80002fac:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002fb0:	752c                	ld	a1,104(a0)
    80002fb2:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002fb4:	00005717          	auipc	a4,0x5
    80002fb8:	0dc70713          	addi	a4,a4,220 # 80008090 <userret>
    80002fbc:	8f11                	sub	a4,a4,a2
    80002fbe:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002fc0:	577d                	li	a4,-1
    80002fc2:	177e                	slli	a4,a4,0x3f
    80002fc4:	8dd9                	or	a1,a1,a4
    80002fc6:	02000537          	lui	a0,0x2000
    80002fca:	157d                	addi	a0,a0,-1
    80002fcc:	0536                	slli	a0,a0,0xd
    80002fce:	9782                	jalr	a5
}
    80002fd0:	60a2                	ld	ra,8(sp)
    80002fd2:	6402                	ld	s0,0(sp)
    80002fd4:	0141                	addi	sp,sp,16
    80002fd6:	8082                	ret

0000000080002fd8 <clockintr>:
{
    80002fd8:	1141                	addi	sp,sp,-16
    80002fda:	e406                	sd	ra,8(sp)
    80002fdc:	e022                	sd	s0,0(sp)
    80002fde:	0800                	addi	s0,sp,16
  acquire(&watchdog_lock);
    80002fe0:	0002d517          	auipc	a0,0x2d
    80002fe4:	05050513          	addi	a0,a0,80 # 80030030 <watchdog_lock>
    80002fe8:	ffffe097          	auipc	ra,0xffffe
    80002fec:	cd2080e7          	jalr	-814(ra) # 80000cba <acquire>
  acquire(&tickslock);
    80002ff0:	00019517          	auipc	a0,0x19
    80002ff4:	0a850513          	addi	a0,a0,168 # 8001c098 <tickslock>
    80002ff8:	ffffe097          	auipc	ra,0xffffe
    80002ffc:	cc2080e7          	jalr	-830(ra) # 80000cba <acquire>
  if (watchdog_time && ticks - watchdog_value > watchdog_time){
    80003000:	0002d797          	auipc	a5,0x2d
    80003004:	0a478793          	addi	a5,a5,164 # 800300a4 <watchdog_time>
    80003008:	439c                	lw	a5,0(a5)
    8000300a:	cf99                	beqz	a5,80003028 <clockintr+0x50>
    8000300c:	0002d717          	auipc	a4,0x2d
    80003010:	07c70713          	addi	a4,a4,124 # 80030088 <ticks>
    80003014:	4318                	lw	a4,0(a4)
    80003016:	0002d697          	auipc	a3,0x2d
    8000301a:	09268693          	addi	a3,a3,146 # 800300a8 <watchdog_value>
    8000301e:	4294                	lw	a3,0(a3)
    80003020:	9f15                	subw	a4,a4,a3
    80003022:	2781                	sext.w	a5,a5
    80003024:	04e7e163          	bltu	a5,a4,80003066 <clockintr+0x8e>
  ticks++;
    80003028:	0002d517          	auipc	a0,0x2d
    8000302c:	06050513          	addi	a0,a0,96 # 80030088 <ticks>
    80003030:	411c                	lw	a5,0(a0)
    80003032:	2785                	addiw	a5,a5,1
    80003034:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003036:	00000097          	auipc	ra,0x0
    8000303a:	a82080e7          	jalr	-1406(ra) # 80002ab8 <wakeup>
  release(&tickslock);
    8000303e:	00019517          	auipc	a0,0x19
    80003042:	05a50513          	addi	a0,a0,90 # 8001c098 <tickslock>
    80003046:	ffffe097          	auipc	ra,0xffffe
    8000304a:	ec0080e7          	jalr	-320(ra) # 80000f06 <release>
  release(&watchdog_lock);
    8000304e:	0002d517          	auipc	a0,0x2d
    80003052:	fe250513          	addi	a0,a0,-30 # 80030030 <watchdog_lock>
    80003056:	ffffe097          	auipc	ra,0xffffe
    8000305a:	eb0080e7          	jalr	-336(ra) # 80000f06 <release>
}
    8000305e:	60a2                	ld	ra,8(sp)
    80003060:	6402                	ld	s0,0(sp)
    80003062:	0141                	addi	sp,sp,16
    80003064:	8082                	ret
    panic("watchdog !!!");
    80003066:	00005517          	auipc	a0,0x5
    8000306a:	6ca50513          	addi	a0,a0,1738 # 80008730 <userret+0x6a0>
    8000306e:	ffffd097          	auipc	ra,0xffffd
    80003072:	716080e7          	jalr	1814(ra) # 80000784 <panic>

0000000080003076 <devintr>:
{
    80003076:	1101                	addi	sp,sp,-32
    80003078:	ec06                	sd	ra,24(sp)
    8000307a:	e822                	sd	s0,16(sp)
    8000307c:	e426                	sd	s1,8(sp)
    8000307e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003080:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80003084:	00074d63          	bltz	a4,8000309e <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80003088:	57fd                	li	a5,-1
    8000308a:	17fe                	slli	a5,a5,0x3f
    8000308c:	0785                	addi	a5,a5,1
    return 0;
    8000308e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80003090:	04f70d63          	beq	a4,a5,800030ea <devintr+0x74>
}
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	64a2                	ld	s1,8(sp)
    8000309a:	6105                	addi	sp,sp,32
    8000309c:	8082                	ret
     (scause & 0xff) == 9){
    8000309e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800030a2:	46a5                	li	a3,9
    800030a4:	fed792e3          	bne	a5,a3,80003088 <devintr+0x12>
    int irq = plic_claim();
    800030a8:	00004097          	auipc	ra,0x4
    800030ac:	8a0080e7          	jalr	-1888(ra) # 80006948 <plic_claim>
    800030b0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800030b2:	47a9                	li	a5,10
    800030b4:	00f50a63          	beq	a0,a5,800030c8 <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    800030b8:	fff5079b          	addiw	a5,a0,-1
    800030bc:	4705                	li	a4,1
    800030be:	00f77a63          	bleu	a5,a4,800030d2 <devintr+0x5c>
    return 1;
    800030c2:	4505                	li	a0,1
    if(irq)
    800030c4:	d8e1                	beqz	s1,80003094 <devintr+0x1e>
    800030c6:	a819                	j	800030dc <devintr+0x66>
      uartintr();
    800030c8:	ffffe097          	auipc	ra,0xffffe
    800030cc:	9fe080e7          	jalr	-1538(ra) # 80000ac6 <uartintr>
    800030d0:	a031                	j	800030dc <devintr+0x66>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800030d2:	853e                	mv	a0,a5
    800030d4:	00004097          	auipc	ra,0x4
    800030d8:	e6a080e7          	jalr	-406(ra) # 80006f3e <virtio_disk_intr>
      plic_complete(irq);
    800030dc:	8526                	mv	a0,s1
    800030de:	00004097          	auipc	ra,0x4
    800030e2:	88e080e7          	jalr	-1906(ra) # 8000696c <plic_complete>
    return 1;
    800030e6:	4505                	li	a0,1
    800030e8:	b775                	j	80003094 <devintr+0x1e>
    if(cpuid() == 0){
    800030ea:	fffff097          	auipc	ra,0xfffff
    800030ee:	f2a080e7          	jalr	-214(ra) # 80002014 <cpuid>
    800030f2:	c901                	beqz	a0,80003102 <devintr+0x8c>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800030f4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800030f8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800030fa:	14479073          	csrw	sip,a5
    return 2;
    800030fe:	4509                	li	a0,2
    80003100:	bf51                	j	80003094 <devintr+0x1e>
      clockintr();
    80003102:	00000097          	auipc	ra,0x0
    80003106:	ed6080e7          	jalr	-298(ra) # 80002fd8 <clockintr>
    8000310a:	b7ed                	j	800030f4 <devintr+0x7e>

000000008000310c <usertrap>:
{
    8000310c:	7179                	addi	sp,sp,-48
    8000310e:	f406                	sd	ra,40(sp)
    80003110:	f022                	sd	s0,32(sp)
    80003112:	ec26                	sd	s1,24(sp)
    80003114:	e84a                	sd	s2,16(sp)
    80003116:	e44e                	sd	s3,8(sp)
    80003118:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000311a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000311e:	1007f793          	andi	a5,a5,256
    80003122:	e3b5                	bnez	a5,80003186 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003124:	00003797          	auipc	a5,0x3
    80003128:	71c78793          	addi	a5,a5,1820 # 80006840 <kernelvec>
    8000312c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003130:	fffff097          	auipc	ra,0xfffff
    80003134:	f10080e7          	jalr	-240(ra) # 80002040 <myproc>
    80003138:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    8000313a:	793c                	ld	a5,112(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000313c:	14102773          	csrr	a4,sepc
    80003140:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003142:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003146:	47a1                	li	a5,8
    80003148:	04f71d63          	bne	a4,a5,800031a2 <usertrap+0x96>
    if(p->killed)
    8000314c:	453c                	lw	a5,72(a0)
    8000314e:	e7a1                	bnez	a5,80003196 <usertrap+0x8a>
    p->tf->epc += 4;
    80003150:	78b8                	ld	a4,112(s1)
    80003152:	6f1c                	ld	a5,24(a4)
    80003154:	0791                	addi	a5,a5,4
    80003156:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003158:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000315c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003160:	10079073          	csrw	sstatus,a5
    syscall();
    80003164:	00000097          	auipc	ra,0x0
    80003168:	304080e7          	jalr	772(ra) # 80003468 <syscall>
  if(p->killed)
    8000316c:	44bc                	lw	a5,72(s1)
    8000316e:	e3cd                	bnez	a5,80003210 <usertrap+0x104>
  usertrapret();
    80003170:	00000097          	auipc	ra,0x0
    80003174:	dca080e7          	jalr	-566(ra) # 80002f3a <usertrapret>
}
    80003178:	70a2                	ld	ra,40(sp)
    8000317a:	7402                	ld	s0,32(sp)
    8000317c:	64e2                	ld	s1,24(sp)
    8000317e:	6942                	ld	s2,16(sp)
    80003180:	69a2                	ld	s3,8(sp)
    80003182:	6145                	addi	sp,sp,48
    80003184:	8082                	ret
    panic("usertrap: not from user mode");
    80003186:	00005517          	auipc	a0,0x5
    8000318a:	5ba50513          	addi	a0,a0,1466 # 80008740 <userret+0x6b0>
    8000318e:	ffffd097          	auipc	ra,0xffffd
    80003192:	5f6080e7          	jalr	1526(ra) # 80000784 <panic>
      exit(-1);
    80003196:	557d                	li	a0,-1
    80003198:	fffff097          	auipc	ra,0xfffff
    8000319c:	614080e7          	jalr	1556(ra) # 800027ac <exit>
    800031a0:	bf45                	j	80003150 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    800031a2:	00000097          	auipc	ra,0x0
    800031a6:	ed4080e7          	jalr	-300(ra) # 80003076 <devintr>
    800031aa:	892a                	mv	s2,a0
    800031ac:	c501                	beqz	a0,800031b4 <usertrap+0xa8>
  if(p->killed)
    800031ae:	44bc                	lw	a5,72(s1)
    800031b0:	cba1                	beqz	a5,80003200 <usertrap+0xf4>
    800031b2:	a091                	j	800031f6 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800031b4:	142029f3          	csrr	s3,scause
    800031b8:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    800031bc:	00000097          	auipc	ra,0x0
    800031c0:	ca4080e7          	jalr	-860(ra) # 80002e60 <scause_desc>
    800031c4:	48b4                	lw	a3,80(s1)
    800031c6:	862a                	mv	a2,a0
    800031c8:	85ce                	mv	a1,s3
    800031ca:	00005517          	auipc	a0,0x5
    800031ce:	59650513          	addi	a0,a0,1430 # 80008760 <userret+0x6d0>
    800031d2:	ffffd097          	auipc	ra,0xffffd
    800031d6:	7ca080e7          	jalr	1994(ra) # 8000099c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800031da:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800031de:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800031e2:	00005517          	auipc	a0,0x5
    800031e6:	5ae50513          	addi	a0,a0,1454 # 80008790 <userret+0x700>
    800031ea:	ffffd097          	auipc	ra,0xffffd
    800031ee:	7b2080e7          	jalr	1970(ra) # 8000099c <printf>
    p->killed = 1;
    800031f2:	4785                	li	a5,1
    800031f4:	c4bc                	sw	a5,72(s1)
    exit(-1);
    800031f6:	557d                	li	a0,-1
    800031f8:	fffff097          	auipc	ra,0xfffff
    800031fc:	5b4080e7          	jalr	1460(ra) # 800027ac <exit>
  if(which_dev == 2)
    80003200:	4789                	li	a5,2
    80003202:	f6f917e3          	bne	s2,a5,80003170 <usertrap+0x64>
    yield();
    80003206:	fffff097          	auipc	ra,0xfffff
    8000320a:	6f0080e7          	jalr	1776(ra) # 800028f6 <yield>
    8000320e:	b78d                	j	80003170 <usertrap+0x64>
  int which_dev = 0;
    80003210:	4901                	li	s2,0
    80003212:	b7d5                	j	800031f6 <usertrap+0xea>

0000000080003214 <kerneltrap>:
{
    80003214:	7179                	addi	sp,sp,-48
    80003216:	f406                	sd	ra,40(sp)
    80003218:	f022                	sd	s0,32(sp)
    8000321a:	ec26                	sd	s1,24(sp)
    8000321c:	e84a                	sd	s2,16(sp)
    8000321e:	e44e                	sd	s3,8(sp)
    80003220:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003222:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003226:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000322a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000322e:	1004f793          	andi	a5,s1,256
    80003232:	cb85                	beqz	a5,80003262 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003234:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003238:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000323a:	ef85                	bnez	a5,80003272 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	e3a080e7          	jalr	-454(ra) # 80003076 <devintr>
    80003244:	cd1d                	beqz	a0,80003282 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003246:	4789                	li	a5,2
    80003248:	08f50063          	beq	a0,a5,800032c8 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000324c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003250:	10049073          	csrw	sstatus,s1
}
    80003254:	70a2                	ld	ra,40(sp)
    80003256:	7402                	ld	s0,32(sp)
    80003258:	64e2                	ld	s1,24(sp)
    8000325a:	6942                	ld	s2,16(sp)
    8000325c:	69a2                	ld	s3,8(sp)
    8000325e:	6145                	addi	sp,sp,48
    80003260:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003262:	00005517          	auipc	a0,0x5
    80003266:	54e50513          	addi	a0,a0,1358 # 800087b0 <userret+0x720>
    8000326a:	ffffd097          	auipc	ra,0xffffd
    8000326e:	51a080e7          	jalr	1306(ra) # 80000784 <panic>
    panic("kerneltrap: interrupts enabled");
    80003272:	00005517          	auipc	a0,0x5
    80003276:	56650513          	addi	a0,a0,1382 # 800087d8 <userret+0x748>
    8000327a:	ffffd097          	auipc	ra,0xffffd
    8000327e:	50a080e7          	jalr	1290(ra) # 80000784 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80003282:	854e                	mv	a0,s3
    80003284:	00000097          	auipc	ra,0x0
    80003288:	bdc080e7          	jalr	-1060(ra) # 80002e60 <scause_desc>
    8000328c:	862a                	mv	a2,a0
    8000328e:	85ce                	mv	a1,s3
    80003290:	00005517          	auipc	a0,0x5
    80003294:	56850513          	addi	a0,a0,1384 # 800087f8 <userret+0x768>
    80003298:	ffffd097          	auipc	ra,0xffffd
    8000329c:	704080e7          	jalr	1796(ra) # 8000099c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032a0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800032a4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800032a8:	00005517          	auipc	a0,0x5
    800032ac:	56050513          	addi	a0,a0,1376 # 80008808 <userret+0x778>
    800032b0:	ffffd097          	auipc	ra,0xffffd
    800032b4:	6ec080e7          	jalr	1772(ra) # 8000099c <printf>
    panic("kerneltrap");
    800032b8:	00005517          	auipc	a0,0x5
    800032bc:	56850513          	addi	a0,a0,1384 # 80008820 <userret+0x790>
    800032c0:	ffffd097          	auipc	ra,0xffffd
    800032c4:	4c4080e7          	jalr	1220(ra) # 80000784 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800032c8:	fffff097          	auipc	ra,0xfffff
    800032cc:	d78080e7          	jalr	-648(ra) # 80002040 <myproc>
    800032d0:	dd35                	beqz	a0,8000324c <kerneltrap+0x38>
    800032d2:	fffff097          	auipc	ra,0xfffff
    800032d6:	d6e080e7          	jalr	-658(ra) # 80002040 <myproc>
    800032da:	5918                	lw	a4,48(a0)
    800032dc:	478d                	li	a5,3
    800032de:	f6f717e3          	bne	a4,a5,8000324c <kerneltrap+0x38>
    yield();
    800032e2:	fffff097          	auipc	ra,0xfffff
    800032e6:	614080e7          	jalr	1556(ra) # 800028f6 <yield>
    800032ea:	b78d                	j	8000324c <kerneltrap+0x38>

00000000800032ec <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800032ec:	1101                	addi	sp,sp,-32
    800032ee:	ec06                	sd	ra,24(sp)
    800032f0:	e822                	sd	s0,16(sp)
    800032f2:	e426                	sd	s1,8(sp)
    800032f4:	1000                	addi	s0,sp,32
    800032f6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800032f8:	fffff097          	auipc	ra,0xfffff
    800032fc:	d48080e7          	jalr	-696(ra) # 80002040 <myproc>
  switch (n) {
    80003300:	4795                	li	a5,5
    80003302:	0497e363          	bltu	a5,s1,80003348 <argraw+0x5c>
    80003306:	1482                	slli	s1,s1,0x20
    80003308:	9081                	srli	s1,s1,0x20
    8000330a:	048a                	slli	s1,s1,0x2
    8000330c:	00006717          	auipc	a4,0x6
    80003310:	d2470713          	addi	a4,a4,-732 # 80009030 <nointr_desc.1655+0x80>
    80003314:	94ba                	add	s1,s1,a4
    80003316:	409c                	lw	a5,0(s1)
    80003318:	97ba                	add	a5,a5,a4
    8000331a:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    8000331c:	793c                	ld	a5,112(a0)
    8000331e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80003320:	60e2                	ld	ra,24(sp)
    80003322:	6442                	ld	s0,16(sp)
    80003324:	64a2                	ld	s1,8(sp)
    80003326:	6105                	addi	sp,sp,32
    80003328:	8082                	ret
    return p->tf->a1;
    8000332a:	793c                	ld	a5,112(a0)
    8000332c:	7fa8                	ld	a0,120(a5)
    8000332e:	bfcd                	j	80003320 <argraw+0x34>
    return p->tf->a2;
    80003330:	793c                	ld	a5,112(a0)
    80003332:	63c8                	ld	a0,128(a5)
    80003334:	b7f5                	j	80003320 <argraw+0x34>
    return p->tf->a3;
    80003336:	793c                	ld	a5,112(a0)
    80003338:	67c8                	ld	a0,136(a5)
    8000333a:	b7dd                	j	80003320 <argraw+0x34>
    return p->tf->a4;
    8000333c:	793c                	ld	a5,112(a0)
    8000333e:	6bc8                	ld	a0,144(a5)
    80003340:	b7c5                	j	80003320 <argraw+0x34>
    return p->tf->a5;
    80003342:	793c                	ld	a5,112(a0)
    80003344:	6fc8                	ld	a0,152(a5)
    80003346:	bfe9                	j	80003320 <argraw+0x34>
  panic("argraw");
    80003348:	00005517          	auipc	a0,0x5
    8000334c:	6e050513          	addi	a0,a0,1760 # 80008a28 <userret+0x998>
    80003350:	ffffd097          	auipc	ra,0xffffd
    80003354:	434080e7          	jalr	1076(ra) # 80000784 <panic>

0000000080003358 <fetchaddr>:
{
    80003358:	1101                	addi	sp,sp,-32
    8000335a:	ec06                	sd	ra,24(sp)
    8000335c:	e822                	sd	s0,16(sp)
    8000335e:	e426                	sd	s1,8(sp)
    80003360:	e04a                	sd	s2,0(sp)
    80003362:	1000                	addi	s0,sp,32
    80003364:	84aa                	mv	s1,a0
    80003366:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003368:	fffff097          	auipc	ra,0xfffff
    8000336c:	cd8080e7          	jalr	-808(ra) # 80002040 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003370:	713c                	ld	a5,96(a0)
    80003372:	02f4f963          	bleu	a5,s1,800033a4 <fetchaddr+0x4c>
    80003376:	00848713          	addi	a4,s1,8
    8000337a:	02e7e763          	bltu	a5,a4,800033a8 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000337e:	46a1                	li	a3,8
    80003380:	8626                	mv	a2,s1
    80003382:	85ca                	mv	a1,s2
    80003384:	7528                	ld	a0,104(a0)
    80003386:	fffff097          	auipc	ra,0xfffff
    8000338a:	924080e7          	jalr	-1756(ra) # 80001caa <copyin>
    8000338e:	00a03533          	snez	a0,a0
    80003392:	40a0053b          	negw	a0,a0
    80003396:	2501                	sext.w	a0,a0
}
    80003398:	60e2                	ld	ra,24(sp)
    8000339a:	6442                	ld	s0,16(sp)
    8000339c:	64a2                	ld	s1,8(sp)
    8000339e:	6902                	ld	s2,0(sp)
    800033a0:	6105                	addi	sp,sp,32
    800033a2:	8082                	ret
    return -1;
    800033a4:	557d                	li	a0,-1
    800033a6:	bfcd                	j	80003398 <fetchaddr+0x40>
    800033a8:	557d                	li	a0,-1
    800033aa:	b7fd                	j	80003398 <fetchaddr+0x40>

00000000800033ac <fetchstr>:
{
    800033ac:	7179                	addi	sp,sp,-48
    800033ae:	f406                	sd	ra,40(sp)
    800033b0:	f022                	sd	s0,32(sp)
    800033b2:	ec26                	sd	s1,24(sp)
    800033b4:	e84a                	sd	s2,16(sp)
    800033b6:	e44e                	sd	s3,8(sp)
    800033b8:	1800                	addi	s0,sp,48
    800033ba:	892a                	mv	s2,a0
    800033bc:	84ae                	mv	s1,a1
    800033be:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800033c0:	fffff097          	auipc	ra,0xfffff
    800033c4:	c80080e7          	jalr	-896(ra) # 80002040 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800033c8:	86ce                	mv	a3,s3
    800033ca:	864a                	mv	a2,s2
    800033cc:	85a6                	mv	a1,s1
    800033ce:	7528                	ld	a0,104(a0)
    800033d0:	fffff097          	auipc	ra,0xfffff
    800033d4:	968080e7          	jalr	-1688(ra) # 80001d38 <copyinstr>
  if(err < 0)
    800033d8:	00054763          	bltz	a0,800033e6 <fetchstr+0x3a>
  return strlen(buf);
    800033dc:	8526                	mv	a0,s1
    800033de:	ffffe097          	auipc	ra,0xffffe
    800033e2:	efa080e7          	jalr	-262(ra) # 800012d8 <strlen>
}
    800033e6:	70a2                	ld	ra,40(sp)
    800033e8:	7402                	ld	s0,32(sp)
    800033ea:	64e2                	ld	s1,24(sp)
    800033ec:	6942                	ld	s2,16(sp)
    800033ee:	69a2                	ld	s3,8(sp)
    800033f0:	6145                	addi	sp,sp,48
    800033f2:	8082                	ret

00000000800033f4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800033f4:	1101                	addi	sp,sp,-32
    800033f6:	ec06                	sd	ra,24(sp)
    800033f8:	e822                	sd	s0,16(sp)
    800033fa:	e426                	sd	s1,8(sp)
    800033fc:	1000                	addi	s0,sp,32
    800033fe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003400:	00000097          	auipc	ra,0x0
    80003404:	eec080e7          	jalr	-276(ra) # 800032ec <argraw>
    80003408:	c088                	sw	a0,0(s1)
  return 0;
}
    8000340a:	4501                	li	a0,0
    8000340c:	60e2                	ld	ra,24(sp)
    8000340e:	6442                	ld	s0,16(sp)
    80003410:	64a2                	ld	s1,8(sp)
    80003412:	6105                	addi	sp,sp,32
    80003414:	8082                	ret

0000000080003416 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003416:	1101                	addi	sp,sp,-32
    80003418:	ec06                	sd	ra,24(sp)
    8000341a:	e822                	sd	s0,16(sp)
    8000341c:	e426                	sd	s1,8(sp)
    8000341e:	1000                	addi	s0,sp,32
    80003420:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003422:	00000097          	auipc	ra,0x0
    80003426:	eca080e7          	jalr	-310(ra) # 800032ec <argraw>
    8000342a:	e088                	sd	a0,0(s1)
  return 0;
}
    8000342c:	4501                	li	a0,0
    8000342e:	60e2                	ld	ra,24(sp)
    80003430:	6442                	ld	s0,16(sp)
    80003432:	64a2                	ld	s1,8(sp)
    80003434:	6105                	addi	sp,sp,32
    80003436:	8082                	ret

0000000080003438 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003438:	1101                	addi	sp,sp,-32
    8000343a:	ec06                	sd	ra,24(sp)
    8000343c:	e822                	sd	s0,16(sp)
    8000343e:	e426                	sd	s1,8(sp)
    80003440:	e04a                	sd	s2,0(sp)
    80003442:	1000                	addi	s0,sp,32
    80003444:	84ae                	mv	s1,a1
    80003446:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003448:	00000097          	auipc	ra,0x0
    8000344c:	ea4080e7          	jalr	-348(ra) # 800032ec <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003450:	864a                	mv	a2,s2
    80003452:	85a6                	mv	a1,s1
    80003454:	00000097          	auipc	ra,0x0
    80003458:	f58080e7          	jalr	-168(ra) # 800033ac <fetchstr>
}
    8000345c:	60e2                	ld	ra,24(sp)
    8000345e:	6442                	ld	s0,16(sp)
    80003460:	64a2                	ld	s1,8(sp)
    80003462:	6902                	ld	s2,0(sp)
    80003464:	6105                	addi	sp,sp,32
    80003466:	8082                	ret

0000000080003468 <syscall>:
[SYS_release_mutex]  sys_release_mutex,
};

void
syscall(void)
{
    80003468:	1101                	addi	sp,sp,-32
    8000346a:	ec06                	sd	ra,24(sp)
    8000346c:	e822                	sd	s0,16(sp)
    8000346e:	e426                	sd	s1,8(sp)
    80003470:	e04a                	sd	s2,0(sp)
    80003472:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003474:	fffff097          	auipc	ra,0xfffff
    80003478:	bcc080e7          	jalr	-1076(ra) # 80002040 <myproc>
    8000347c:	84aa                	mv	s1,a0

  num = p->tf->a7;
    8000347e:	07053903          	ld	s2,112(a0)
    80003482:	0a893783          	ld	a5,168(s2)
    80003486:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000348a:	37fd                	addiw	a5,a5,-1
    8000348c:	4765                	li	a4,25
    8000348e:	00f76f63          	bltu	a4,a5,800034ac <syscall+0x44>
    80003492:	00369713          	slli	a4,a3,0x3
    80003496:	00006797          	auipc	a5,0x6
    8000349a:	bb278793          	addi	a5,a5,-1102 # 80009048 <syscalls>
    8000349e:	97ba                	add	a5,a5,a4
    800034a0:	639c                	ld	a5,0(a5)
    800034a2:	c789                	beqz	a5,800034ac <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    800034a4:	9782                	jalr	a5
    800034a6:	06a93823          	sd	a0,112(s2)
    800034aa:	a839                	j	800034c8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800034ac:	17048613          	addi	a2,s1,368
    800034b0:	48ac                	lw	a1,80(s1)
    800034b2:	00005517          	auipc	a0,0x5
    800034b6:	57e50513          	addi	a0,a0,1406 # 80008a30 <userret+0x9a0>
    800034ba:	ffffd097          	auipc	ra,0xffffd
    800034be:	4e2080e7          	jalr	1250(ra) # 8000099c <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    800034c2:	78bc                	ld	a5,112(s1)
    800034c4:	577d                	li	a4,-1
    800034c6:	fbb8                	sd	a4,112(a5)
  }
}
    800034c8:	60e2                	ld	ra,24(sp)
    800034ca:	6442                	ld	s0,16(sp)
    800034cc:	64a2                	ld	s1,8(sp)
    800034ce:	6902                	ld	s2,0(sp)
    800034d0:	6105                	addi	sp,sp,32
    800034d2:	8082                	ret

00000000800034d4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800034d4:	1101                	addi	sp,sp,-32
    800034d6:	ec06                	sd	ra,24(sp)
    800034d8:	e822                	sd	s0,16(sp)
    800034da:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800034dc:	fec40593          	addi	a1,s0,-20
    800034e0:	4501                	li	a0,0
    800034e2:	00000097          	auipc	ra,0x0
    800034e6:	f12080e7          	jalr	-238(ra) # 800033f4 <argint>
    return -1;
    800034ea:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800034ec:	00054963          	bltz	a0,800034fe <sys_exit+0x2a>
  exit(n);
    800034f0:	fec42503          	lw	a0,-20(s0)
    800034f4:	fffff097          	auipc	ra,0xfffff
    800034f8:	2b8080e7          	jalr	696(ra) # 800027ac <exit>
  return 0;  // not reached
    800034fc:	4781                	li	a5,0
}
    800034fe:	853e                	mv	a0,a5
    80003500:	60e2                	ld	ra,24(sp)
    80003502:	6442                	ld	s0,16(sp)
    80003504:	6105                	addi	sp,sp,32
    80003506:	8082                	ret

0000000080003508 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003508:	1141                	addi	sp,sp,-16
    8000350a:	e406                	sd	ra,8(sp)
    8000350c:	e022                	sd	s0,0(sp)
    8000350e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003510:	fffff097          	auipc	ra,0xfffff
    80003514:	b30080e7          	jalr	-1232(ra) # 80002040 <myproc>
}
    80003518:	4928                	lw	a0,80(a0)
    8000351a:	60a2                	ld	ra,8(sp)
    8000351c:	6402                	ld	s0,0(sp)
    8000351e:	0141                	addi	sp,sp,16
    80003520:	8082                	ret

0000000080003522 <sys_fork>:

uint64
sys_fork(void)
{
    80003522:	1141                	addi	sp,sp,-16
    80003524:	e406                	sd	ra,8(sp)
    80003526:	e022                	sd	s0,0(sp)
    80003528:	0800                	addi	s0,sp,16
  return fork();
    8000352a:	fffff097          	auipc	ra,0xfffff
    8000352e:	ede080e7          	jalr	-290(ra) # 80002408 <fork>
}
    80003532:	60a2                	ld	ra,8(sp)
    80003534:	6402                	ld	s0,0(sp)
    80003536:	0141                	addi	sp,sp,16
    80003538:	8082                	ret

000000008000353a <sys_wait>:

uint64
sys_wait(void)
{
    8000353a:	1101                	addi	sp,sp,-32
    8000353c:	ec06                	sd	ra,24(sp)
    8000353e:	e822                	sd	s0,16(sp)
    80003540:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003542:	fe840593          	addi	a1,s0,-24
    80003546:	4501                	li	a0,0
    80003548:	00000097          	auipc	ra,0x0
    8000354c:	ece080e7          	jalr	-306(ra) # 80003416 <argaddr>
    return -1;
    80003550:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80003552:	00054963          	bltz	a0,80003564 <sys_wait+0x2a>
  return wait(p);
    80003556:	fe843503          	ld	a0,-24(s0)
    8000355a:	fffff097          	auipc	ra,0xfffff
    8000355e:	456080e7          	jalr	1110(ra) # 800029b0 <wait>
    80003562:	87aa                	mv	a5,a0
}
    80003564:	853e                	mv	a0,a5
    80003566:	60e2                	ld	ra,24(sp)
    80003568:	6442                	ld	s0,16(sp)
    8000356a:	6105                	addi	sp,sp,32
    8000356c:	8082                	ret

000000008000356e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000356e:	7179                	addi	sp,sp,-48
    80003570:	f406                	sd	ra,40(sp)
    80003572:	f022                	sd	s0,32(sp)
    80003574:	ec26                	sd	s1,24(sp)
    80003576:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003578:	fdc40593          	addi	a1,s0,-36
    8000357c:	4501                	li	a0,0
    8000357e:	00000097          	auipc	ra,0x0
    80003582:	e76080e7          	jalr	-394(ra) # 800033f4 <argint>
    return -1;
    80003586:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003588:	00054f63          	bltz	a0,800035a6 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000358c:	fffff097          	auipc	ra,0xfffff
    80003590:	ab4080e7          	jalr	-1356(ra) # 80002040 <myproc>
    80003594:	5124                	lw	s1,96(a0)
  if(growproc(n) < 0)
    80003596:	fdc42503          	lw	a0,-36(s0)
    8000359a:	fffff097          	auipc	ra,0xfffff
    8000359e:	df6080e7          	jalr	-522(ra) # 80002390 <growproc>
    800035a2:	00054863          	bltz	a0,800035b2 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800035a6:	8526                	mv	a0,s1
    800035a8:	70a2                	ld	ra,40(sp)
    800035aa:	7402                	ld	s0,32(sp)
    800035ac:	64e2                	ld	s1,24(sp)
    800035ae:	6145                	addi	sp,sp,48
    800035b0:	8082                	ret
    return -1;
    800035b2:	54fd                	li	s1,-1
    800035b4:	bfcd                	j	800035a6 <sys_sbrk+0x38>

00000000800035b6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800035b6:	7139                	addi	sp,sp,-64
    800035b8:	fc06                	sd	ra,56(sp)
    800035ba:	f822                	sd	s0,48(sp)
    800035bc:	f426                	sd	s1,40(sp)
    800035be:	f04a                	sd	s2,32(sp)
    800035c0:	ec4e                	sd	s3,24(sp)
    800035c2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800035c4:	fcc40593          	addi	a1,s0,-52
    800035c8:	4501                	li	a0,0
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	e2a080e7          	jalr	-470(ra) # 800033f4 <argint>
    return -1;
    800035d2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800035d4:	06054763          	bltz	a0,80003642 <sys_sleep+0x8c>
  acquire(&tickslock);
    800035d8:	00019517          	auipc	a0,0x19
    800035dc:	ac050513          	addi	a0,a0,-1344 # 8001c098 <tickslock>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	6da080e7          	jalr	1754(ra) # 80000cba <acquire>
  ticks0 = ticks;
    800035e8:	0002d797          	auipc	a5,0x2d
    800035ec:	aa078793          	addi	a5,a5,-1376 # 80030088 <ticks>
    800035f0:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    800035f4:	fcc42783          	lw	a5,-52(s0)
    800035f8:	cf85                	beqz	a5,80003630 <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800035fa:	00019997          	auipc	s3,0x19
    800035fe:	a9e98993          	addi	s3,s3,-1378 # 8001c098 <tickslock>
    80003602:	0002d497          	auipc	s1,0x2d
    80003606:	a8648493          	addi	s1,s1,-1402 # 80030088 <ticks>
    if(myproc()->killed){
    8000360a:	fffff097          	auipc	ra,0xfffff
    8000360e:	a36080e7          	jalr	-1482(ra) # 80002040 <myproc>
    80003612:	453c                	lw	a5,72(a0)
    80003614:	ef9d                	bnez	a5,80003652 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    80003616:	85ce                	mv	a1,s3
    80003618:	8526                	mv	a0,s1
    8000361a:	fffff097          	auipc	ra,0xfffff
    8000361e:	318080e7          	jalr	792(ra) # 80002932 <sleep>
  while(ticks - ticks0 < n){
    80003622:	409c                	lw	a5,0(s1)
    80003624:	412787bb          	subw	a5,a5,s2
    80003628:	fcc42703          	lw	a4,-52(s0)
    8000362c:	fce7efe3          	bltu	a5,a4,8000360a <sys_sleep+0x54>
  }
  release(&tickslock);
    80003630:	00019517          	auipc	a0,0x19
    80003634:	a6850513          	addi	a0,a0,-1432 # 8001c098 <tickslock>
    80003638:	ffffe097          	auipc	ra,0xffffe
    8000363c:	8ce080e7          	jalr	-1842(ra) # 80000f06 <release>
  return 0;
    80003640:	4781                	li	a5,0
}
    80003642:	853e                	mv	a0,a5
    80003644:	70e2                	ld	ra,56(sp)
    80003646:	7442                	ld	s0,48(sp)
    80003648:	74a2                	ld	s1,40(sp)
    8000364a:	7902                	ld	s2,32(sp)
    8000364c:	69e2                	ld	s3,24(sp)
    8000364e:	6121                	addi	sp,sp,64
    80003650:	8082                	ret
      release(&tickslock);
    80003652:	00019517          	auipc	a0,0x19
    80003656:	a4650513          	addi	a0,a0,-1466 # 8001c098 <tickslock>
    8000365a:	ffffe097          	auipc	ra,0xffffe
    8000365e:	8ac080e7          	jalr	-1876(ra) # 80000f06 <release>
      return -1;
    80003662:	57fd                	li	a5,-1
    80003664:	bff9                	j	80003642 <sys_sleep+0x8c>

0000000080003666 <sys_nice>:

uint64
sys_nice(void){
    80003666:	1101                	addi	sp,sp,-32
    80003668:	ec06                	sd	ra,24(sp)
    8000366a:	e822                	sd	s0,16(sp)
    8000366c:	1000                	addi	s0,sp,32
  int pid;
  int priority;

  if(argint(0, &pid ) < 0)
    8000366e:	fec40593          	addi	a1,s0,-20
    80003672:	4501                	li	a0,0
    80003674:	00000097          	auipc	ra,0x0
    80003678:	d80080e7          	jalr	-640(ra) # 800033f4 <argint>
    return -1;
    8000367c:	57fd                	li	a5,-1
  if(argint(0, &pid ) < 0)
    8000367e:	02054a63          	bltz	a0,800036b2 <sys_nice+0x4c>
  if(argint(1, &priority ) <0)
    80003682:	fe840593          	addi	a1,s0,-24
    80003686:	4505                	li	a0,1
    80003688:	00000097          	auipc	ra,0x0
    8000368c:	d6c080e7          	jalr	-660(ra) # 800033f4 <argint>
    80003690:	02054663          	bltz	a0,800036bc <sys_nice+0x56>
    return -1;
  if (priority < 0 || priority >= NPRIO) {
    80003694:	fe842583          	lw	a1,-24(s0)
    80003698:	0005869b          	sext.w	a3,a1
    8000369c:	4725                	li	a4,9
    return -1;
    8000369e:	57fd                	li	a5,-1
  if (priority < 0 || priority >= NPRIO) {
    800036a0:	00d76963          	bltu	a4,a3,800036b2 <sys_nice+0x4c>
  }
  return nice(pid, priority);
    800036a4:	fec42503          	lw	a0,-20(s0)
    800036a8:	fffff097          	auipc	ra,0xfffff
    800036ac:	6de080e7          	jalr	1758(ra) # 80002d86 <nice>
    800036b0:	87aa                	mv	a5,a0
}
    800036b2:	853e                	mv	a0,a5
    800036b4:	60e2                	ld	ra,24(sp)
    800036b6:	6442                	ld	s0,16(sp)
    800036b8:	6105                	addi	sp,sp,32
    800036ba:	8082                	ret
    return -1;
    800036bc:	57fd                	li	a5,-1
    800036be:	bfd5                	j	800036b2 <sys_nice+0x4c>

00000000800036c0 <sys_kill>:

uint64
sys_kill(void)
{
    800036c0:	1101                	addi	sp,sp,-32
    800036c2:	ec06                	sd	ra,24(sp)
    800036c4:	e822                	sd	s0,16(sp)
    800036c6:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800036c8:	fec40593          	addi	a1,s0,-20
    800036cc:	4501                	li	a0,0
    800036ce:	00000097          	auipc	ra,0x0
    800036d2:	d26080e7          	jalr	-730(ra) # 800033f4 <argint>
    return -1;
    800036d6:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    800036d8:	00054963          	bltz	a0,800036ea <sys_kill+0x2a>
  return kill(pid);
    800036dc:	fec42503          	lw	a0,-20(s0)
    800036e0:	fffff097          	auipc	ra,0xfffff
    800036e4:	442080e7          	jalr	1090(ra) # 80002b22 <kill>
    800036e8:	87aa                	mv	a5,a0
}
    800036ea:	853e                	mv	a0,a5
    800036ec:	60e2                	ld	ra,24(sp)
    800036ee:	6442                	ld	s0,16(sp)
    800036f0:	6105                	addi	sp,sp,32
    800036f2:	8082                	ret

00000000800036f4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800036f4:	1101                	addi	sp,sp,-32
    800036f6:	ec06                	sd	ra,24(sp)
    800036f8:	e822                	sd	s0,16(sp)
    800036fa:	e426                	sd	s1,8(sp)
    800036fc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800036fe:	00019517          	auipc	a0,0x19
    80003702:	99a50513          	addi	a0,a0,-1638 # 8001c098 <tickslock>
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	5b4080e7          	jalr	1460(ra) # 80000cba <acquire>
  xticks = ticks;
    8000370e:	0002d797          	auipc	a5,0x2d
    80003712:	97a78793          	addi	a5,a5,-1670 # 80030088 <ticks>
    80003716:	4384                	lw	s1,0(a5)
  release(&tickslock);
    80003718:	00019517          	auipc	a0,0x19
    8000371c:	98050513          	addi	a0,a0,-1664 # 8001c098 <tickslock>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	7e6080e7          	jalr	2022(ra) # 80000f06 <release>
  return xticks;
}
    80003728:	02049513          	slli	a0,s1,0x20
    8000372c:	9101                	srli	a0,a0,0x20
    8000372e:	60e2                	ld	ra,24(sp)
    80003730:	6442                	ld	s0,16(sp)
    80003732:	64a2                	ld	s1,8(sp)
    80003734:	6105                	addi	sp,sp,32
    80003736:	8082                	ret

0000000080003738 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003738:	7179                	addi	sp,sp,-48
    8000373a:	f406                	sd	ra,40(sp)
    8000373c:	f022                	sd	s0,32(sp)
    8000373e:	ec26                	sd	s1,24(sp)
    80003740:	e84a                	sd	s2,16(sp)
    80003742:	e44e                	sd	s3,8(sp)
    80003744:	e052                	sd	s4,0(sp)
    80003746:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003748:	00005597          	auipc	a1,0x5
    8000374c:	cb858593          	addi	a1,a1,-840 # 80008400 <userret+0x370>
    80003750:	00019517          	auipc	a0,0x19
    80003754:	97850513          	addi	a0,a0,-1672 # 8001c0c8 <bcache>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	3f4080e7          	jalr	1012(ra) # 80000b4c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003760:	00021797          	auipc	a5,0x21
    80003764:	96878793          	addi	a5,a5,-1688 # 800240c8 <bcache+0x8000>
    80003768:	00021717          	auipc	a4,0x21
    8000376c:	eb070713          	addi	a4,a4,-336 # 80024618 <bcache+0x8550>
    80003770:	5ae7b823          	sd	a4,1456(a5)
  bcache.head.next = &bcache.head;
    80003774:	5ae7bc23          	sd	a4,1464(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003778:	00019497          	auipc	s1,0x19
    8000377c:	98048493          	addi	s1,s1,-1664 # 8001c0f8 <bcache+0x30>
    b->next = bcache.head.next;
    80003780:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003782:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003784:	00005a17          	auipc	s4,0x5
    80003788:	2cca0a13          	addi	s4,s4,716 # 80008a50 <userret+0x9c0>
    b->next = bcache.head.next;
    8000378c:	5b893783          	ld	a5,1464(s2)
    80003790:	f4bc                	sd	a5,104(s1)
    b->prev = &bcache.head;
    80003792:	0734b023          	sd	s3,96(s1)
    initsleeplock(&b->lock, "buffer");
    80003796:	85d2                	mv	a1,s4
    80003798:	01048513          	addi	a0,s1,16
    8000379c:	00001097          	auipc	ra,0x1
    800037a0:	5ea080e7          	jalr	1514(ra) # 80004d86 <initsleeplock>
    bcache.head.next->prev = b;
    800037a4:	5b893783          	ld	a5,1464(s2)
    800037a8:	f3a4                	sd	s1,96(a5)
    bcache.head.next = b;
    800037aa:	5a993c23          	sd	s1,1464(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800037ae:	47048493          	addi	s1,s1,1136
    800037b2:	fd349de3          	bne	s1,s3,8000378c <binit+0x54>
  }
}
    800037b6:	70a2                	ld	ra,40(sp)
    800037b8:	7402                	ld	s0,32(sp)
    800037ba:	64e2                	ld	s1,24(sp)
    800037bc:	6942                	ld	s2,16(sp)
    800037be:	69a2                	ld	s3,8(sp)
    800037c0:	6a02                	ld	s4,0(sp)
    800037c2:	6145                	addi	sp,sp,48
    800037c4:	8082                	ret

00000000800037c6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800037c6:	7179                	addi	sp,sp,-48
    800037c8:	f406                	sd	ra,40(sp)
    800037ca:	f022                	sd	s0,32(sp)
    800037cc:	ec26                	sd	s1,24(sp)
    800037ce:	e84a                	sd	s2,16(sp)
    800037d0:	e44e                	sd	s3,8(sp)
    800037d2:	1800                	addi	s0,sp,48
    800037d4:	89aa                	mv	s3,a0
    800037d6:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800037d8:	00019517          	auipc	a0,0x19
    800037dc:	8f050513          	addi	a0,a0,-1808 # 8001c0c8 <bcache>
    800037e0:	ffffd097          	auipc	ra,0xffffd
    800037e4:	4da080e7          	jalr	1242(ra) # 80000cba <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800037e8:	00021797          	auipc	a5,0x21
    800037ec:	8e078793          	addi	a5,a5,-1824 # 800240c8 <bcache+0x8000>
    800037f0:	5b87b483          	ld	s1,1464(a5)
    800037f4:	00021797          	auipc	a5,0x21
    800037f8:	e2478793          	addi	a5,a5,-476 # 80024618 <bcache+0x8550>
    800037fc:	02f48f63          	beq	s1,a5,8000383a <bread+0x74>
    80003800:	873e                	mv	a4,a5
    80003802:	a021                	j	8000380a <bread+0x44>
    80003804:	74a4                	ld	s1,104(s1)
    80003806:	02e48a63          	beq	s1,a4,8000383a <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    8000380a:	449c                	lw	a5,8(s1)
    8000380c:	ff379ce3          	bne	a5,s3,80003804 <bread+0x3e>
    80003810:	44dc                	lw	a5,12(s1)
    80003812:	ff2799e3          	bne	a5,s2,80003804 <bread+0x3e>
      b->refcnt++;
    80003816:	4cbc                	lw	a5,88(s1)
    80003818:	2785                	addiw	a5,a5,1
    8000381a:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    8000381c:	00019517          	auipc	a0,0x19
    80003820:	8ac50513          	addi	a0,a0,-1876 # 8001c0c8 <bcache>
    80003824:	ffffd097          	auipc	ra,0xffffd
    80003828:	6e2080e7          	jalr	1762(ra) # 80000f06 <release>
      acquiresleep(&b->lock);
    8000382c:	01048513          	addi	a0,s1,16
    80003830:	00001097          	auipc	ra,0x1
    80003834:	590080e7          	jalr	1424(ra) # 80004dc0 <acquiresleep>
      return b;
    80003838:	a8b1                	j	80003894 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000383a:	00021797          	auipc	a5,0x21
    8000383e:	88e78793          	addi	a5,a5,-1906 # 800240c8 <bcache+0x8000>
    80003842:	5b07b483          	ld	s1,1456(a5)
    80003846:	00021797          	auipc	a5,0x21
    8000384a:	dd278793          	addi	a5,a5,-558 # 80024618 <bcache+0x8550>
    8000384e:	04f48d63          	beq	s1,a5,800038a8 <bread+0xe2>
    if(b->refcnt == 0) {
    80003852:	4cbc                	lw	a5,88(s1)
    80003854:	cb91                	beqz	a5,80003868 <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003856:	00021717          	auipc	a4,0x21
    8000385a:	dc270713          	addi	a4,a4,-574 # 80024618 <bcache+0x8550>
    8000385e:	70a4                	ld	s1,96(s1)
    80003860:	04e48463          	beq	s1,a4,800038a8 <bread+0xe2>
    if(b->refcnt == 0) {
    80003864:	4cbc                	lw	a5,88(s1)
    80003866:	ffe5                	bnez	a5,8000385e <bread+0x98>
      b->dev = dev;
    80003868:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000386c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003870:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003874:	4785                	li	a5,1
    80003876:	ccbc                	sw	a5,88(s1)
      release(&bcache.lock);
    80003878:	00019517          	auipc	a0,0x19
    8000387c:	85050513          	addi	a0,a0,-1968 # 8001c0c8 <bcache>
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	686080e7          	jalr	1670(ra) # 80000f06 <release>
      acquiresleep(&b->lock);
    80003888:	01048513          	addi	a0,s1,16
    8000388c:	00001097          	auipc	ra,0x1
    80003890:	534080e7          	jalr	1332(ra) # 80004dc0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003894:	409c                	lw	a5,0(s1)
    80003896:	c38d                	beqz	a5,800038b8 <bread+0xf2>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80003898:	8526                	mv	a0,s1
    8000389a:	70a2                	ld	ra,40(sp)
    8000389c:	7402                	ld	s0,32(sp)
    8000389e:	64e2                	ld	s1,24(sp)
    800038a0:	6942                	ld	s2,16(sp)
    800038a2:	69a2                	ld	s3,8(sp)
    800038a4:	6145                	addi	sp,sp,48
    800038a6:	8082                	ret
  panic("bget: no buffers");
    800038a8:	00005517          	auipc	a0,0x5
    800038ac:	1b050513          	addi	a0,a0,432 # 80008a58 <userret+0x9c8>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	ed4080e7          	jalr	-300(ra) # 80000784 <panic>
    virtio_disk_rw(b->dev, b, 0);
    800038b8:	4601                	li	a2,0
    800038ba:	85a6                	mv	a1,s1
    800038bc:	4488                	lw	a0,8(s1)
    800038be:	00003097          	auipc	ra,0x3
    800038c2:	35c080e7          	jalr	860(ra) # 80006c1a <virtio_disk_rw>
    b->valid = 1;
    800038c6:	4785                	li	a5,1
    800038c8:	c09c                	sw	a5,0(s1)
  return b;
    800038ca:	b7f9                	j	80003898 <bread+0xd2>

00000000800038cc <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800038cc:	1101                	addi	sp,sp,-32
    800038ce:	ec06                	sd	ra,24(sp)
    800038d0:	e822                	sd	s0,16(sp)
    800038d2:	e426                	sd	s1,8(sp)
    800038d4:	1000                	addi	s0,sp,32
    800038d6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038d8:	0541                	addi	a0,a0,16
    800038da:	00001097          	auipc	ra,0x1
    800038de:	580080e7          	jalr	1408(ra) # 80004e5a <holdingsleep>
    800038e2:	cd09                	beqz	a0,800038fc <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    800038e4:	4605                	li	a2,1
    800038e6:	85a6                	mv	a1,s1
    800038e8:	4488                	lw	a0,8(s1)
    800038ea:	00003097          	auipc	ra,0x3
    800038ee:	330080e7          	jalr	816(ra) # 80006c1a <virtio_disk_rw>
}
    800038f2:	60e2                	ld	ra,24(sp)
    800038f4:	6442                	ld	s0,16(sp)
    800038f6:	64a2                	ld	s1,8(sp)
    800038f8:	6105                	addi	sp,sp,32
    800038fa:	8082                	ret
    panic("bwrite");
    800038fc:	00005517          	auipc	a0,0x5
    80003900:	17450513          	addi	a0,a0,372 # 80008a70 <userret+0x9e0>
    80003904:	ffffd097          	auipc	ra,0xffffd
    80003908:	e80080e7          	jalr	-384(ra) # 80000784 <panic>

000000008000390c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    8000390c:	1101                	addi	sp,sp,-32
    8000390e:	ec06                	sd	ra,24(sp)
    80003910:	e822                	sd	s0,16(sp)
    80003912:	e426                	sd	s1,8(sp)
    80003914:	e04a                	sd	s2,0(sp)
    80003916:	1000                	addi	s0,sp,32
    80003918:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000391a:	01050913          	addi	s2,a0,16
    8000391e:	854a                	mv	a0,s2
    80003920:	00001097          	auipc	ra,0x1
    80003924:	53a080e7          	jalr	1338(ra) # 80004e5a <holdingsleep>
    80003928:	c92d                	beqz	a0,8000399a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000392a:	854a                	mv	a0,s2
    8000392c:	00001097          	auipc	ra,0x1
    80003930:	4ea080e7          	jalr	1258(ra) # 80004e16 <releasesleep>

  acquire(&bcache.lock);
    80003934:	00018517          	auipc	a0,0x18
    80003938:	79450513          	addi	a0,a0,1940 # 8001c0c8 <bcache>
    8000393c:	ffffd097          	auipc	ra,0xffffd
    80003940:	37e080e7          	jalr	894(ra) # 80000cba <acquire>
  b->refcnt--;
    80003944:	4cbc                	lw	a5,88(s1)
    80003946:	37fd                	addiw	a5,a5,-1
    80003948:	0007871b          	sext.w	a4,a5
    8000394c:	ccbc                	sw	a5,88(s1)
  if (b->refcnt == 0) {
    8000394e:	eb05                	bnez	a4,8000397e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003950:	74bc                	ld	a5,104(s1)
    80003952:	70b8                	ld	a4,96(s1)
    80003954:	f3b8                	sd	a4,96(a5)
    b->prev->next = b->next;
    80003956:	70bc                	ld	a5,96(s1)
    80003958:	74b8                	ld	a4,104(s1)
    8000395a:	f7b8                	sd	a4,104(a5)
    b->next = bcache.head.next;
    8000395c:	00020797          	auipc	a5,0x20
    80003960:	76c78793          	addi	a5,a5,1900 # 800240c8 <bcache+0x8000>
    80003964:	5b87b703          	ld	a4,1464(a5)
    80003968:	f4b8                	sd	a4,104(s1)
    b->prev = &bcache.head;
    8000396a:	00021717          	auipc	a4,0x21
    8000396e:	cae70713          	addi	a4,a4,-850 # 80024618 <bcache+0x8550>
    80003972:	f0b8                	sd	a4,96(s1)
    bcache.head.next->prev = b;
    80003974:	5b87b703          	ld	a4,1464(a5)
    80003978:	f324                	sd	s1,96(a4)
    bcache.head.next = b;
    8000397a:	5a97bc23          	sd	s1,1464(a5)
  }
  
  release(&bcache.lock);
    8000397e:	00018517          	auipc	a0,0x18
    80003982:	74a50513          	addi	a0,a0,1866 # 8001c0c8 <bcache>
    80003986:	ffffd097          	auipc	ra,0xffffd
    8000398a:	580080e7          	jalr	1408(ra) # 80000f06 <release>
}
    8000398e:	60e2                	ld	ra,24(sp)
    80003990:	6442                	ld	s0,16(sp)
    80003992:	64a2                	ld	s1,8(sp)
    80003994:	6902                	ld	s2,0(sp)
    80003996:	6105                	addi	sp,sp,32
    80003998:	8082                	ret
    panic("brelse");
    8000399a:	00005517          	auipc	a0,0x5
    8000399e:	0de50513          	addi	a0,a0,222 # 80008a78 <userret+0x9e8>
    800039a2:	ffffd097          	auipc	ra,0xffffd
    800039a6:	de2080e7          	jalr	-542(ra) # 80000784 <panic>

00000000800039aa <bpin>:

void
bpin(struct buf *b) {
    800039aa:	1101                	addi	sp,sp,-32
    800039ac:	ec06                	sd	ra,24(sp)
    800039ae:	e822                	sd	s0,16(sp)
    800039b0:	e426                	sd	s1,8(sp)
    800039b2:	1000                	addi	s0,sp,32
    800039b4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039b6:	00018517          	auipc	a0,0x18
    800039ba:	71250513          	addi	a0,a0,1810 # 8001c0c8 <bcache>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	2fc080e7          	jalr	764(ra) # 80000cba <acquire>
  b->refcnt++;
    800039c6:	4cbc                	lw	a5,88(s1)
    800039c8:	2785                	addiw	a5,a5,1
    800039ca:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    800039cc:	00018517          	auipc	a0,0x18
    800039d0:	6fc50513          	addi	a0,a0,1788 # 8001c0c8 <bcache>
    800039d4:	ffffd097          	auipc	ra,0xffffd
    800039d8:	532080e7          	jalr	1330(ra) # 80000f06 <release>
}
    800039dc:	60e2                	ld	ra,24(sp)
    800039de:	6442                	ld	s0,16(sp)
    800039e0:	64a2                	ld	s1,8(sp)
    800039e2:	6105                	addi	sp,sp,32
    800039e4:	8082                	ret

00000000800039e6 <bunpin>:

void
bunpin(struct buf *b) {
    800039e6:	1101                	addi	sp,sp,-32
    800039e8:	ec06                	sd	ra,24(sp)
    800039ea:	e822                	sd	s0,16(sp)
    800039ec:	e426                	sd	s1,8(sp)
    800039ee:	1000                	addi	s0,sp,32
    800039f0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800039f2:	00018517          	auipc	a0,0x18
    800039f6:	6d650513          	addi	a0,a0,1750 # 8001c0c8 <bcache>
    800039fa:	ffffd097          	auipc	ra,0xffffd
    800039fe:	2c0080e7          	jalr	704(ra) # 80000cba <acquire>
  b->refcnt--;
    80003a02:	4cbc                	lw	a5,88(s1)
    80003a04:	37fd                	addiw	a5,a5,-1
    80003a06:	ccbc                	sw	a5,88(s1)
  release(&bcache.lock);
    80003a08:	00018517          	auipc	a0,0x18
    80003a0c:	6c050513          	addi	a0,a0,1728 # 8001c0c8 <bcache>
    80003a10:	ffffd097          	auipc	ra,0xffffd
    80003a14:	4f6080e7          	jalr	1270(ra) # 80000f06 <release>
}
    80003a18:	60e2                	ld	ra,24(sp)
    80003a1a:	6442                	ld	s0,16(sp)
    80003a1c:	64a2                	ld	s1,8(sp)
    80003a1e:	6105                	addi	sp,sp,32
    80003a20:	8082                	ret

0000000080003a22 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003a22:	1101                	addi	sp,sp,-32
    80003a24:	ec06                	sd	ra,24(sp)
    80003a26:	e822                	sd	s0,16(sp)
    80003a28:	e426                	sd	s1,8(sp)
    80003a2a:	e04a                	sd	s2,0(sp)
    80003a2c:	1000                	addi	s0,sp,32
    80003a2e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003a30:	00d5d59b          	srliw	a1,a1,0xd
    80003a34:	00021797          	auipc	a5,0x21
    80003a38:	05478793          	addi	a5,a5,84 # 80024a88 <sb>
    80003a3c:	4fdc                	lw	a5,28(a5)
    80003a3e:	9dbd                	addw	a1,a1,a5
    80003a40:	00000097          	auipc	ra,0x0
    80003a44:	d86080e7          	jalr	-634(ra) # 800037c6 <bread>
  bi = b % BPB;
    80003a48:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    80003a4a:	0074f793          	andi	a5,s1,7
    80003a4e:	4705                	li	a4,1
    80003a50:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    80003a54:	6789                	lui	a5,0x2
    80003a56:	17fd                	addi	a5,a5,-1
    80003a58:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    80003a5a:	41f4d79b          	sraiw	a5,s1,0x1f
    80003a5e:	01d7d79b          	srliw	a5,a5,0x1d
    80003a62:	9fa5                	addw	a5,a5,s1
    80003a64:	4037d79b          	sraiw	a5,a5,0x3
    80003a68:	00f506b3          	add	a3,a0,a5
    80003a6c:	0706c683          	lbu	a3,112(a3)
    80003a70:	00d77633          	and	a2,a4,a3
    80003a74:	c61d                	beqz	a2,80003aa2 <bfree+0x80>
    80003a76:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003a78:	97aa                	add	a5,a5,a0
    80003a7a:	fff74713          	not	a4,a4
    80003a7e:	8f75                	and	a4,a4,a3
    80003a80:	06e78823          	sb	a4,112(a5) # 2070 <_entry-0x7fffdf90>
  log_write(bp);
    80003a84:	00001097          	auipc	ra,0x1
    80003a88:	1b2080e7          	jalr	434(ra) # 80004c36 <log_write>
  brelse(bp);
    80003a8c:	854a                	mv	a0,s2
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	e7e080e7          	jalr	-386(ra) # 8000390c <brelse>
}
    80003a96:	60e2                	ld	ra,24(sp)
    80003a98:	6442                	ld	s0,16(sp)
    80003a9a:	64a2                	ld	s1,8(sp)
    80003a9c:	6902                	ld	s2,0(sp)
    80003a9e:	6105                	addi	sp,sp,32
    80003aa0:	8082                	ret
    panic("freeing free block");
    80003aa2:	00005517          	auipc	a0,0x5
    80003aa6:	fde50513          	addi	a0,a0,-34 # 80008a80 <userret+0x9f0>
    80003aaa:	ffffd097          	auipc	ra,0xffffd
    80003aae:	cda080e7          	jalr	-806(ra) # 80000784 <panic>

0000000080003ab2 <balloc>:
{
    80003ab2:	711d                	addi	sp,sp,-96
    80003ab4:	ec86                	sd	ra,88(sp)
    80003ab6:	e8a2                	sd	s0,80(sp)
    80003ab8:	e4a6                	sd	s1,72(sp)
    80003aba:	e0ca                	sd	s2,64(sp)
    80003abc:	fc4e                	sd	s3,56(sp)
    80003abe:	f852                	sd	s4,48(sp)
    80003ac0:	f456                	sd	s5,40(sp)
    80003ac2:	f05a                	sd	s6,32(sp)
    80003ac4:	ec5e                	sd	s7,24(sp)
    80003ac6:	e862                	sd	s8,16(sp)
    80003ac8:	e466                	sd	s9,8(sp)
    80003aca:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003acc:	00021797          	auipc	a5,0x21
    80003ad0:	fbc78793          	addi	a5,a5,-68 # 80024a88 <sb>
    80003ad4:	43dc                	lw	a5,4(a5)
    80003ad6:	10078e63          	beqz	a5,80003bf2 <balloc+0x140>
    80003ada:	8baa                	mv	s7,a0
    80003adc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003ade:	00021b17          	auipc	s6,0x21
    80003ae2:	faab0b13          	addi	s6,s6,-86 # 80024a88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ae6:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    80003ae8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003aea:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003aec:	6c89                	lui	s9,0x2
    80003aee:	a079                	j	80003b7c <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003af0:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    80003af2:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003af4:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    80003af6:	96a6                	add	a3,a3,s1
    80003af8:	8f51                	or	a4,a4,a2
    80003afa:	06e68823          	sb	a4,112(a3)
        log_write(bp);
    80003afe:	8526                	mv	a0,s1
    80003b00:	00001097          	auipc	ra,0x1
    80003b04:	136080e7          	jalr	310(ra) # 80004c36 <log_write>
        brelse(bp);
    80003b08:	8526                	mv	a0,s1
    80003b0a:	00000097          	auipc	ra,0x0
    80003b0e:	e02080e7          	jalr	-510(ra) # 8000390c <brelse>
  bp = bread(dev, bno);
    80003b12:	85ca                	mv	a1,s2
    80003b14:	855e                	mv	a0,s7
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	cb0080e7          	jalr	-848(ra) # 800037c6 <bread>
    80003b1e:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    80003b20:	40000613          	li	a2,1024
    80003b24:	4581                	li	a1,0
    80003b26:	07050513          	addi	a0,a0,112
    80003b2a:	ffffd097          	auipc	ra,0xffffd
    80003b2e:	604080e7          	jalr	1540(ra) # 8000112e <memset>
  log_write(bp);
    80003b32:	8526                	mv	a0,s1
    80003b34:	00001097          	auipc	ra,0x1
    80003b38:	102080e7          	jalr	258(ra) # 80004c36 <log_write>
  brelse(bp);
    80003b3c:	8526                	mv	a0,s1
    80003b3e:	00000097          	auipc	ra,0x0
    80003b42:	dce080e7          	jalr	-562(ra) # 8000390c <brelse>
}
    80003b46:	854a                	mv	a0,s2
    80003b48:	60e6                	ld	ra,88(sp)
    80003b4a:	6446                	ld	s0,80(sp)
    80003b4c:	64a6                	ld	s1,72(sp)
    80003b4e:	6906                	ld	s2,64(sp)
    80003b50:	79e2                	ld	s3,56(sp)
    80003b52:	7a42                	ld	s4,48(sp)
    80003b54:	7aa2                	ld	s5,40(sp)
    80003b56:	7b02                	ld	s6,32(sp)
    80003b58:	6be2                	ld	s7,24(sp)
    80003b5a:	6c42                	ld	s8,16(sp)
    80003b5c:	6ca2                	ld	s9,8(sp)
    80003b5e:	6125                	addi	sp,sp,96
    80003b60:	8082                	ret
    brelse(bp);
    80003b62:	8526                	mv	a0,s1
    80003b64:	00000097          	auipc	ra,0x0
    80003b68:	da8080e7          	jalr	-600(ra) # 8000390c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003b6c:	015c87bb          	addw	a5,s9,s5
    80003b70:	00078a9b          	sext.w	s5,a5
    80003b74:	004b2703          	lw	a4,4(s6)
    80003b78:	06eafd63          	bleu	a4,s5,80003bf2 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    80003b7c:	41fad79b          	sraiw	a5,s5,0x1f
    80003b80:	0137d79b          	srliw	a5,a5,0x13
    80003b84:	015787bb          	addw	a5,a5,s5
    80003b88:	40d7d79b          	sraiw	a5,a5,0xd
    80003b8c:	01cb2583          	lw	a1,28(s6)
    80003b90:	9dbd                	addw	a1,a1,a5
    80003b92:	855e                	mv	a0,s7
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	c32080e7          	jalr	-974(ra) # 800037c6 <bread>
    80003b9c:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b9e:	000a881b          	sext.w	a6,s5
    80003ba2:	004b2503          	lw	a0,4(s6)
    80003ba6:	faa87ee3          	bleu	a0,a6,80003b62 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003baa:	0704c603          	lbu	a2,112(s1)
    80003bae:	00167793          	andi	a5,a2,1
    80003bb2:	df9d                	beqz	a5,80003af0 <balloc+0x3e>
    80003bb4:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bb8:	87e2                	mv	a5,s8
    80003bba:	0107893b          	addw	s2,a5,a6
    80003bbe:	faa782e3          	beq	a5,a0,80003b62 <balloc+0xb0>
      m = 1 << (bi % 8);
    80003bc2:	41f7d71b          	sraiw	a4,a5,0x1f
    80003bc6:	01d7561b          	srliw	a2,a4,0x1d
    80003bca:	00f606bb          	addw	a3,a2,a5
    80003bce:	0076f713          	andi	a4,a3,7
    80003bd2:	9f11                	subw	a4,a4,a2
    80003bd4:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003bd8:	4036d69b          	sraiw	a3,a3,0x3
    80003bdc:	00d48633          	add	a2,s1,a3
    80003be0:	07064603          	lbu	a2,112(a2)
    80003be4:	00c775b3          	and	a1,a4,a2
    80003be8:	d599                	beqz	a1,80003af6 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bea:	2785                	addiw	a5,a5,1
    80003bec:	fd4797e3          	bne	a5,s4,80003bba <balloc+0x108>
    80003bf0:	bf8d                	j	80003b62 <balloc+0xb0>
  panic("balloc: out of blocks");
    80003bf2:	00005517          	auipc	a0,0x5
    80003bf6:	ea650513          	addi	a0,a0,-346 # 80008a98 <userret+0xa08>
    80003bfa:	ffffd097          	auipc	ra,0xffffd
    80003bfe:	b8a080e7          	jalr	-1142(ra) # 80000784 <panic>

0000000080003c02 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003c02:	7179                	addi	sp,sp,-48
    80003c04:	f406                	sd	ra,40(sp)
    80003c06:	f022                	sd	s0,32(sp)
    80003c08:	ec26                	sd	s1,24(sp)
    80003c0a:	e84a                	sd	s2,16(sp)
    80003c0c:	e44e                	sd	s3,8(sp)
    80003c0e:	e052                	sd	s4,0(sp)
    80003c10:	1800                	addi	s0,sp,48
    80003c12:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003c14:	47ad                	li	a5,11
    80003c16:	04b7fe63          	bleu	a1,a5,80003c72 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003c1a:	ff45849b          	addiw	s1,a1,-12
    80003c1e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003c22:	0ff00793          	li	a5,255
    80003c26:	0ae7e363          	bltu	a5,a4,80003ccc <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003c2a:	09852583          	lw	a1,152(a0)
    80003c2e:	c5ad                	beqz	a1,80003c98 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003c30:	0009a503          	lw	a0,0(s3)
    80003c34:	00000097          	auipc	ra,0x0
    80003c38:	b92080e7          	jalr	-1134(ra) # 800037c6 <bread>
    80003c3c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003c3e:	07050793          	addi	a5,a0,112
    if((addr = a[bn]) == 0){
    80003c42:	02049593          	slli	a1,s1,0x20
    80003c46:	9181                	srli	a1,a1,0x20
    80003c48:	058a                	slli	a1,a1,0x2
    80003c4a:	00b784b3          	add	s1,a5,a1
    80003c4e:	0004a903          	lw	s2,0(s1)
    80003c52:	04090d63          	beqz	s2,80003cac <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003c56:	8552                	mv	a0,s4
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	cb4080e7          	jalr	-844(ra) # 8000390c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003c60:	854a                	mv	a0,s2
    80003c62:	70a2                	ld	ra,40(sp)
    80003c64:	7402                	ld	s0,32(sp)
    80003c66:	64e2                	ld	s1,24(sp)
    80003c68:	6942                	ld	s2,16(sp)
    80003c6a:	69a2                	ld	s3,8(sp)
    80003c6c:	6a02                	ld	s4,0(sp)
    80003c6e:	6145                	addi	sp,sp,48
    80003c70:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003c72:	02059493          	slli	s1,a1,0x20
    80003c76:	9081                	srli	s1,s1,0x20
    80003c78:	048a                	slli	s1,s1,0x2
    80003c7a:	94aa                	add	s1,s1,a0
    80003c7c:	0684a903          	lw	s2,104(s1)
    80003c80:	fe0910e3          	bnez	s2,80003c60 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003c84:	4108                	lw	a0,0(a0)
    80003c86:	00000097          	auipc	ra,0x0
    80003c8a:	e2c080e7          	jalr	-468(ra) # 80003ab2 <balloc>
    80003c8e:	0005091b          	sext.w	s2,a0
    80003c92:	0724a423          	sw	s2,104(s1)
    80003c96:	b7e9                	j	80003c60 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003c98:	4108                	lw	a0,0(a0)
    80003c9a:	00000097          	auipc	ra,0x0
    80003c9e:	e18080e7          	jalr	-488(ra) # 80003ab2 <balloc>
    80003ca2:	0005059b          	sext.w	a1,a0
    80003ca6:	08b9ac23          	sw	a1,152(s3)
    80003caa:	b759                	j	80003c30 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003cac:	0009a503          	lw	a0,0(s3)
    80003cb0:	00000097          	auipc	ra,0x0
    80003cb4:	e02080e7          	jalr	-510(ra) # 80003ab2 <balloc>
    80003cb8:	0005091b          	sext.w	s2,a0
    80003cbc:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    80003cc0:	8552                	mv	a0,s4
    80003cc2:	00001097          	auipc	ra,0x1
    80003cc6:	f74080e7          	jalr	-140(ra) # 80004c36 <log_write>
    80003cca:	b771                	j	80003c56 <bmap+0x54>
  panic("bmap: out of range");
    80003ccc:	00005517          	auipc	a0,0x5
    80003cd0:	de450513          	addi	a0,a0,-540 # 80008ab0 <userret+0xa20>
    80003cd4:	ffffd097          	auipc	ra,0xffffd
    80003cd8:	ab0080e7          	jalr	-1360(ra) # 80000784 <panic>

0000000080003cdc <iget>:
{
    80003cdc:	7179                	addi	sp,sp,-48
    80003cde:	f406                	sd	ra,40(sp)
    80003ce0:	f022                	sd	s0,32(sp)
    80003ce2:	ec26                	sd	s1,24(sp)
    80003ce4:	e84a                	sd	s2,16(sp)
    80003ce6:	e44e                	sd	s3,8(sp)
    80003ce8:	e052                	sd	s4,0(sp)
    80003cea:	1800                	addi	s0,sp,48
    80003cec:	89aa                	mv	s3,a0
    80003cee:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003cf0:	00021517          	auipc	a0,0x21
    80003cf4:	db850513          	addi	a0,a0,-584 # 80024aa8 <icache>
    80003cf8:	ffffd097          	auipc	ra,0xffffd
    80003cfc:	fc2080e7          	jalr	-62(ra) # 80000cba <acquire>
  empty = 0;
    80003d00:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003d02:	00021497          	auipc	s1,0x21
    80003d06:	dd648493          	addi	s1,s1,-554 # 80024ad8 <icache+0x30>
    80003d0a:	00023697          	auipc	a3,0x23
    80003d0e:	d0e68693          	addi	a3,a3,-754 # 80026a18 <log>
    80003d12:	a039                	j	80003d20 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d14:	02090b63          	beqz	s2,80003d4a <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003d18:	0a048493          	addi	s1,s1,160
    80003d1c:	02d48a63          	beq	s1,a3,80003d50 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003d20:	449c                	lw	a5,8(s1)
    80003d22:	fef059e3          	blez	a5,80003d14 <iget+0x38>
    80003d26:	4098                	lw	a4,0(s1)
    80003d28:	ff3716e3          	bne	a4,s3,80003d14 <iget+0x38>
    80003d2c:	40d8                	lw	a4,4(s1)
    80003d2e:	ff4713e3          	bne	a4,s4,80003d14 <iget+0x38>
      ip->ref++;
    80003d32:	2785                	addiw	a5,a5,1
    80003d34:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003d36:	00021517          	auipc	a0,0x21
    80003d3a:	d7250513          	addi	a0,a0,-654 # 80024aa8 <icache>
    80003d3e:	ffffd097          	auipc	ra,0xffffd
    80003d42:	1c8080e7          	jalr	456(ra) # 80000f06 <release>
      return ip;
    80003d46:	8926                	mv	s2,s1
    80003d48:	a03d                	j	80003d76 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d4a:	f7f9                	bnez	a5,80003d18 <iget+0x3c>
    80003d4c:	8926                	mv	s2,s1
    80003d4e:	b7e9                	j	80003d18 <iget+0x3c>
  if(empty == 0)
    80003d50:	02090c63          	beqz	s2,80003d88 <iget+0xac>
  ip->dev = dev;
    80003d54:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003d58:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003d5c:	4785                	li	a5,1
    80003d5e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003d62:	04092c23          	sw	zero,88(s2)
  release(&icache.lock);
    80003d66:	00021517          	auipc	a0,0x21
    80003d6a:	d4250513          	addi	a0,a0,-702 # 80024aa8 <icache>
    80003d6e:	ffffd097          	auipc	ra,0xffffd
    80003d72:	198080e7          	jalr	408(ra) # 80000f06 <release>
}
    80003d76:	854a                	mv	a0,s2
    80003d78:	70a2                	ld	ra,40(sp)
    80003d7a:	7402                	ld	s0,32(sp)
    80003d7c:	64e2                	ld	s1,24(sp)
    80003d7e:	6942                	ld	s2,16(sp)
    80003d80:	69a2                	ld	s3,8(sp)
    80003d82:	6a02                	ld	s4,0(sp)
    80003d84:	6145                	addi	sp,sp,48
    80003d86:	8082                	ret
    panic("iget: no inodes");
    80003d88:	00005517          	auipc	a0,0x5
    80003d8c:	d4050513          	addi	a0,a0,-704 # 80008ac8 <userret+0xa38>
    80003d90:	ffffd097          	auipc	ra,0xffffd
    80003d94:	9f4080e7          	jalr	-1548(ra) # 80000784 <panic>

0000000080003d98 <fsinit>:
fsinit(int dev) {
    80003d98:	7179                	addi	sp,sp,-48
    80003d9a:	f406                	sd	ra,40(sp)
    80003d9c:	f022                	sd	s0,32(sp)
    80003d9e:	ec26                	sd	s1,24(sp)
    80003da0:	e84a                	sd	s2,16(sp)
    80003da2:	e44e                	sd	s3,8(sp)
    80003da4:	1800                	addi	s0,sp,48
    80003da6:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003da8:	4585                	li	a1,1
    80003daa:	00000097          	auipc	ra,0x0
    80003dae:	a1c080e7          	jalr	-1508(ra) # 800037c6 <bread>
    80003db2:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003db4:	00021497          	auipc	s1,0x21
    80003db8:	cd448493          	addi	s1,s1,-812 # 80024a88 <sb>
    80003dbc:	02000613          	li	a2,32
    80003dc0:	07050593          	addi	a1,a0,112
    80003dc4:	8526                	mv	a0,s1
    80003dc6:	ffffd097          	auipc	ra,0xffffd
    80003dca:	3d4080e7          	jalr	980(ra) # 8000119a <memmove>
  brelse(bp);
    80003dce:	854a                	mv	a0,s2
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	b3c080e7          	jalr	-1220(ra) # 8000390c <brelse>
  if(sb.magic != FSMAGIC)
    80003dd8:	4098                	lw	a4,0(s1)
    80003dda:	102037b7          	lui	a5,0x10203
    80003dde:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003de2:	02f71263          	bne	a4,a5,80003e06 <fsinit+0x6e>
  initlog(dev, &sb);
    80003de6:	00021597          	auipc	a1,0x21
    80003dea:	ca258593          	addi	a1,a1,-862 # 80024a88 <sb>
    80003dee:	854e                	mv	a0,s3
    80003df0:	00001097          	auipc	ra,0x1
    80003df4:	b30080e7          	jalr	-1232(ra) # 80004920 <initlog>
}
    80003df8:	70a2                	ld	ra,40(sp)
    80003dfa:	7402                	ld	s0,32(sp)
    80003dfc:	64e2                	ld	s1,24(sp)
    80003dfe:	6942                	ld	s2,16(sp)
    80003e00:	69a2                	ld	s3,8(sp)
    80003e02:	6145                	addi	sp,sp,48
    80003e04:	8082                	ret
    panic("invalid file system");
    80003e06:	00005517          	auipc	a0,0x5
    80003e0a:	cd250513          	addi	a0,a0,-814 # 80008ad8 <userret+0xa48>
    80003e0e:	ffffd097          	auipc	ra,0xffffd
    80003e12:	976080e7          	jalr	-1674(ra) # 80000784 <panic>

0000000080003e16 <iinit>:
{
    80003e16:	7179                	addi	sp,sp,-48
    80003e18:	f406                	sd	ra,40(sp)
    80003e1a:	f022                	sd	s0,32(sp)
    80003e1c:	ec26                	sd	s1,24(sp)
    80003e1e:	e84a                	sd	s2,16(sp)
    80003e20:	e44e                	sd	s3,8(sp)
    80003e22:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003e24:	00005597          	auipc	a1,0x5
    80003e28:	ccc58593          	addi	a1,a1,-820 # 80008af0 <userret+0xa60>
    80003e2c:	00021517          	auipc	a0,0x21
    80003e30:	c7c50513          	addi	a0,a0,-900 # 80024aa8 <icache>
    80003e34:	ffffd097          	auipc	ra,0xffffd
    80003e38:	d18080e7          	jalr	-744(ra) # 80000b4c <initlock>
  for(i = 0; i < NINODE; i++) {
    80003e3c:	00021497          	auipc	s1,0x21
    80003e40:	cac48493          	addi	s1,s1,-852 # 80024ae8 <icache+0x40>
    80003e44:	00023997          	auipc	s3,0x23
    80003e48:	be498993          	addi	s3,s3,-1052 # 80026a28 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003e4c:	00005917          	auipc	s2,0x5
    80003e50:	cac90913          	addi	s2,s2,-852 # 80008af8 <userret+0xa68>
    80003e54:	85ca                	mv	a1,s2
    80003e56:	8526                	mv	a0,s1
    80003e58:	00001097          	auipc	ra,0x1
    80003e5c:	f2e080e7          	jalr	-210(ra) # 80004d86 <initsleeplock>
    80003e60:	0a048493          	addi	s1,s1,160
  for(i = 0; i < NINODE; i++) {
    80003e64:	ff3498e3          	bne	s1,s3,80003e54 <iinit+0x3e>
}
    80003e68:	70a2                	ld	ra,40(sp)
    80003e6a:	7402                	ld	s0,32(sp)
    80003e6c:	64e2                	ld	s1,24(sp)
    80003e6e:	6942                	ld	s2,16(sp)
    80003e70:	69a2                	ld	s3,8(sp)
    80003e72:	6145                	addi	sp,sp,48
    80003e74:	8082                	ret

0000000080003e76 <ialloc>:
{
    80003e76:	715d                	addi	sp,sp,-80
    80003e78:	e486                	sd	ra,72(sp)
    80003e7a:	e0a2                	sd	s0,64(sp)
    80003e7c:	fc26                	sd	s1,56(sp)
    80003e7e:	f84a                	sd	s2,48(sp)
    80003e80:	f44e                	sd	s3,40(sp)
    80003e82:	f052                	sd	s4,32(sp)
    80003e84:	ec56                	sd	s5,24(sp)
    80003e86:	e85a                	sd	s6,16(sp)
    80003e88:	e45e                	sd	s7,8(sp)
    80003e8a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e8c:	00021797          	auipc	a5,0x21
    80003e90:	bfc78793          	addi	a5,a5,-1028 # 80024a88 <sb>
    80003e94:	47d8                	lw	a4,12(a5)
    80003e96:	4785                	li	a5,1
    80003e98:	04e7fa63          	bleu	a4,a5,80003eec <ialloc+0x76>
    80003e9c:	8a2a                	mv	s4,a0
    80003e9e:	8b2e                	mv	s6,a1
    80003ea0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003ea2:	00021997          	auipc	s3,0x21
    80003ea6:	be698993          	addi	s3,s3,-1050 # 80024a88 <sb>
    80003eaa:	00048a9b          	sext.w	s5,s1
    80003eae:	0044d593          	srli	a1,s1,0x4
    80003eb2:	0189a783          	lw	a5,24(s3)
    80003eb6:	9dbd                	addw	a1,a1,a5
    80003eb8:	8552                	mv	a0,s4
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	90c080e7          	jalr	-1780(ra) # 800037c6 <bread>
    80003ec2:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ec4:	07050913          	addi	s2,a0,112
    80003ec8:	00f4f793          	andi	a5,s1,15
    80003ecc:	079a                	slli	a5,a5,0x6
    80003ece:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80003ed0:	00091783          	lh	a5,0(s2)
    80003ed4:	c785                	beqz	a5,80003efc <ialloc+0x86>
    brelse(bp);
    80003ed6:	00000097          	auipc	ra,0x0
    80003eda:	a36080e7          	jalr	-1482(ra) # 8000390c <brelse>
    80003ede:	0485                	addi	s1,s1,1
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ee0:	00c9a703          	lw	a4,12(s3)
    80003ee4:	0004879b          	sext.w	a5,s1
    80003ee8:	fce7e1e3          	bltu	a5,a4,80003eaa <ialloc+0x34>
  panic("ialloc: no inodes");
    80003eec:	00005517          	auipc	a0,0x5
    80003ef0:	c1450513          	addi	a0,a0,-1004 # 80008b00 <userret+0xa70>
    80003ef4:	ffffd097          	auipc	ra,0xffffd
    80003ef8:	890080e7          	jalr	-1904(ra) # 80000784 <panic>
      memset(dip, 0, sizeof(*dip));
    80003efc:	04000613          	li	a2,64
    80003f00:	4581                	li	a1,0
    80003f02:	854a                	mv	a0,s2
    80003f04:	ffffd097          	auipc	ra,0xffffd
    80003f08:	22a080e7          	jalr	554(ra) # 8000112e <memset>
      dip->type = type;
    80003f0c:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    80003f10:	855e                	mv	a0,s7
    80003f12:	00001097          	auipc	ra,0x1
    80003f16:	d24080e7          	jalr	-732(ra) # 80004c36 <log_write>
      brelse(bp);
    80003f1a:	855e                	mv	a0,s7
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	9f0080e7          	jalr	-1552(ra) # 8000390c <brelse>
      return iget(dev, inum);
    80003f24:	85d6                	mv	a1,s5
    80003f26:	8552                	mv	a0,s4
    80003f28:	00000097          	auipc	ra,0x0
    80003f2c:	db4080e7          	jalr	-588(ra) # 80003cdc <iget>
}
    80003f30:	60a6                	ld	ra,72(sp)
    80003f32:	6406                	ld	s0,64(sp)
    80003f34:	74e2                	ld	s1,56(sp)
    80003f36:	7942                	ld	s2,48(sp)
    80003f38:	79a2                	ld	s3,40(sp)
    80003f3a:	7a02                	ld	s4,32(sp)
    80003f3c:	6ae2                	ld	s5,24(sp)
    80003f3e:	6b42                	ld	s6,16(sp)
    80003f40:	6ba2                	ld	s7,8(sp)
    80003f42:	6161                	addi	sp,sp,80
    80003f44:	8082                	ret

0000000080003f46 <iupdate>:
{
    80003f46:	1101                	addi	sp,sp,-32
    80003f48:	ec06                	sd	ra,24(sp)
    80003f4a:	e822                	sd	s0,16(sp)
    80003f4c:	e426                	sd	s1,8(sp)
    80003f4e:	e04a                	sd	s2,0(sp)
    80003f50:	1000                	addi	s0,sp,32
    80003f52:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f54:	415c                	lw	a5,4(a0)
    80003f56:	0047d79b          	srliw	a5,a5,0x4
    80003f5a:	00021717          	auipc	a4,0x21
    80003f5e:	b2e70713          	addi	a4,a4,-1234 # 80024a88 <sb>
    80003f62:	4f0c                	lw	a1,24(a4)
    80003f64:	9dbd                	addw	a1,a1,a5
    80003f66:	4108                	lw	a0,0(a0)
    80003f68:	00000097          	auipc	ra,0x0
    80003f6c:	85e080e7          	jalr	-1954(ra) # 800037c6 <bread>
    80003f70:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f72:	07050513          	addi	a0,a0,112
    80003f76:	40dc                	lw	a5,4(s1)
    80003f78:	8bbd                	andi	a5,a5,15
    80003f7a:	079a                	slli	a5,a5,0x6
    80003f7c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003f7e:	05c49783          	lh	a5,92(s1)
    80003f82:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    80003f86:	05e49783          	lh	a5,94(s1)
    80003f8a:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    80003f8e:	06049783          	lh	a5,96(s1)
    80003f92:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    80003f96:	06249783          	lh	a5,98(s1)
    80003f9a:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    80003f9e:	50fc                	lw	a5,100(s1)
    80003fa0:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003fa2:	03400613          	li	a2,52
    80003fa6:	06848593          	addi	a1,s1,104
    80003faa:	0531                	addi	a0,a0,12
    80003fac:	ffffd097          	auipc	ra,0xffffd
    80003fb0:	1ee080e7          	jalr	494(ra) # 8000119a <memmove>
  log_write(bp);
    80003fb4:	854a                	mv	a0,s2
    80003fb6:	00001097          	auipc	ra,0x1
    80003fba:	c80080e7          	jalr	-896(ra) # 80004c36 <log_write>
  brelse(bp);
    80003fbe:	854a                	mv	a0,s2
    80003fc0:	00000097          	auipc	ra,0x0
    80003fc4:	94c080e7          	jalr	-1716(ra) # 8000390c <brelse>
}
    80003fc8:	60e2                	ld	ra,24(sp)
    80003fca:	6442                	ld	s0,16(sp)
    80003fcc:	64a2                	ld	s1,8(sp)
    80003fce:	6902                	ld	s2,0(sp)
    80003fd0:	6105                	addi	sp,sp,32
    80003fd2:	8082                	ret

0000000080003fd4 <idup>:
{
    80003fd4:	1101                	addi	sp,sp,-32
    80003fd6:	ec06                	sd	ra,24(sp)
    80003fd8:	e822                	sd	s0,16(sp)
    80003fda:	e426                	sd	s1,8(sp)
    80003fdc:	1000                	addi	s0,sp,32
    80003fde:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003fe0:	00021517          	auipc	a0,0x21
    80003fe4:	ac850513          	addi	a0,a0,-1336 # 80024aa8 <icache>
    80003fe8:	ffffd097          	auipc	ra,0xffffd
    80003fec:	cd2080e7          	jalr	-814(ra) # 80000cba <acquire>
  ip->ref++;
    80003ff0:	449c                	lw	a5,8(s1)
    80003ff2:	2785                	addiw	a5,a5,1
    80003ff4:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003ff6:	00021517          	auipc	a0,0x21
    80003ffa:	ab250513          	addi	a0,a0,-1358 # 80024aa8 <icache>
    80003ffe:	ffffd097          	auipc	ra,0xffffd
    80004002:	f08080e7          	jalr	-248(ra) # 80000f06 <release>
}
    80004006:	8526                	mv	a0,s1
    80004008:	60e2                	ld	ra,24(sp)
    8000400a:	6442                	ld	s0,16(sp)
    8000400c:	64a2                	ld	s1,8(sp)
    8000400e:	6105                	addi	sp,sp,32
    80004010:	8082                	ret

0000000080004012 <ilock>:
{
    80004012:	1101                	addi	sp,sp,-32
    80004014:	ec06                	sd	ra,24(sp)
    80004016:	e822                	sd	s0,16(sp)
    80004018:	e426                	sd	s1,8(sp)
    8000401a:	e04a                	sd	s2,0(sp)
    8000401c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000401e:	c115                	beqz	a0,80004042 <ilock+0x30>
    80004020:	84aa                	mv	s1,a0
    80004022:	451c                	lw	a5,8(a0)
    80004024:	00f05f63          	blez	a5,80004042 <ilock+0x30>
  acquiresleep(&ip->lock);
    80004028:	0541                	addi	a0,a0,16
    8000402a:	00001097          	auipc	ra,0x1
    8000402e:	d96080e7          	jalr	-618(ra) # 80004dc0 <acquiresleep>
  if(ip->valid == 0){
    80004032:	4cbc                	lw	a5,88(s1)
    80004034:	cf99                	beqz	a5,80004052 <ilock+0x40>
}
    80004036:	60e2                	ld	ra,24(sp)
    80004038:	6442                	ld	s0,16(sp)
    8000403a:	64a2                	ld	s1,8(sp)
    8000403c:	6902                	ld	s2,0(sp)
    8000403e:	6105                	addi	sp,sp,32
    80004040:	8082                	ret
    panic("ilock");
    80004042:	00005517          	auipc	a0,0x5
    80004046:	ad650513          	addi	a0,a0,-1322 # 80008b18 <userret+0xa88>
    8000404a:	ffffc097          	auipc	ra,0xffffc
    8000404e:	73a080e7          	jalr	1850(ra) # 80000784 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004052:	40dc                	lw	a5,4(s1)
    80004054:	0047d79b          	srliw	a5,a5,0x4
    80004058:	00021717          	auipc	a4,0x21
    8000405c:	a3070713          	addi	a4,a4,-1488 # 80024a88 <sb>
    80004060:	4f0c                	lw	a1,24(a4)
    80004062:	9dbd                	addw	a1,a1,a5
    80004064:	4088                	lw	a0,0(s1)
    80004066:	fffff097          	auipc	ra,0xfffff
    8000406a:	760080e7          	jalr	1888(ra) # 800037c6 <bread>
    8000406e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004070:	07050593          	addi	a1,a0,112
    80004074:	40dc                	lw	a5,4(s1)
    80004076:	8bbd                	andi	a5,a5,15
    80004078:	079a                	slli	a5,a5,0x6
    8000407a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000407c:	00059783          	lh	a5,0(a1)
    80004080:	04f49e23          	sh	a5,92(s1)
    ip->major = dip->major;
    80004084:	00259783          	lh	a5,2(a1)
    80004088:	04f49f23          	sh	a5,94(s1)
    ip->minor = dip->minor;
    8000408c:	00459783          	lh	a5,4(a1)
    80004090:	06f49023          	sh	a5,96(s1)
    ip->nlink = dip->nlink;
    80004094:	00659783          	lh	a5,6(a1)
    80004098:	06f49123          	sh	a5,98(s1)
    ip->size = dip->size;
    8000409c:	459c                	lw	a5,8(a1)
    8000409e:	d0fc                	sw	a5,100(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800040a0:	03400613          	li	a2,52
    800040a4:	05b1                	addi	a1,a1,12
    800040a6:	06848513          	addi	a0,s1,104
    800040aa:	ffffd097          	auipc	ra,0xffffd
    800040ae:	0f0080e7          	jalr	240(ra) # 8000119a <memmove>
    brelse(bp);
    800040b2:	854a                	mv	a0,s2
    800040b4:	00000097          	auipc	ra,0x0
    800040b8:	858080e7          	jalr	-1960(ra) # 8000390c <brelse>
    ip->valid = 1;
    800040bc:	4785                	li	a5,1
    800040be:	ccbc                	sw	a5,88(s1)
    if(ip->type == 0)
    800040c0:	05c49783          	lh	a5,92(s1)
    800040c4:	fbad                	bnez	a5,80004036 <ilock+0x24>
      panic("ilock: no type");
    800040c6:	00005517          	auipc	a0,0x5
    800040ca:	a5a50513          	addi	a0,a0,-1446 # 80008b20 <userret+0xa90>
    800040ce:	ffffc097          	auipc	ra,0xffffc
    800040d2:	6b6080e7          	jalr	1718(ra) # 80000784 <panic>

00000000800040d6 <iunlock>:
{
    800040d6:	1101                	addi	sp,sp,-32
    800040d8:	ec06                	sd	ra,24(sp)
    800040da:	e822                	sd	s0,16(sp)
    800040dc:	e426                	sd	s1,8(sp)
    800040de:	e04a                	sd	s2,0(sp)
    800040e0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800040e2:	c905                	beqz	a0,80004112 <iunlock+0x3c>
    800040e4:	84aa                	mv	s1,a0
    800040e6:	01050913          	addi	s2,a0,16
    800040ea:	854a                	mv	a0,s2
    800040ec:	00001097          	auipc	ra,0x1
    800040f0:	d6e080e7          	jalr	-658(ra) # 80004e5a <holdingsleep>
    800040f4:	cd19                	beqz	a0,80004112 <iunlock+0x3c>
    800040f6:	449c                	lw	a5,8(s1)
    800040f8:	00f05d63          	blez	a5,80004112 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800040fc:	854a                	mv	a0,s2
    800040fe:	00001097          	auipc	ra,0x1
    80004102:	d18080e7          	jalr	-744(ra) # 80004e16 <releasesleep>
}
    80004106:	60e2                	ld	ra,24(sp)
    80004108:	6442                	ld	s0,16(sp)
    8000410a:	64a2                	ld	s1,8(sp)
    8000410c:	6902                	ld	s2,0(sp)
    8000410e:	6105                	addi	sp,sp,32
    80004110:	8082                	ret
    panic("iunlock");
    80004112:	00005517          	auipc	a0,0x5
    80004116:	a1e50513          	addi	a0,a0,-1506 # 80008b30 <userret+0xaa0>
    8000411a:	ffffc097          	auipc	ra,0xffffc
    8000411e:	66a080e7          	jalr	1642(ra) # 80000784 <panic>

0000000080004122 <iput>:
{
    80004122:	7139                	addi	sp,sp,-64
    80004124:	fc06                	sd	ra,56(sp)
    80004126:	f822                	sd	s0,48(sp)
    80004128:	f426                	sd	s1,40(sp)
    8000412a:	f04a                	sd	s2,32(sp)
    8000412c:	ec4e                	sd	s3,24(sp)
    8000412e:	e852                	sd	s4,16(sp)
    80004130:	e456                	sd	s5,8(sp)
    80004132:	0080                	addi	s0,sp,64
    80004134:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80004136:	00021517          	auipc	a0,0x21
    8000413a:	97250513          	addi	a0,a0,-1678 # 80024aa8 <icache>
    8000413e:	ffffd097          	auipc	ra,0xffffd
    80004142:	b7c080e7          	jalr	-1156(ra) # 80000cba <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004146:	4498                	lw	a4,8(s1)
    80004148:	4785                	li	a5,1
    8000414a:	02f70663          	beq	a4,a5,80004176 <iput+0x54>
  ip->ref--;
    8000414e:	449c                	lw	a5,8(s1)
    80004150:	37fd                	addiw	a5,a5,-1
    80004152:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80004154:	00021517          	auipc	a0,0x21
    80004158:	95450513          	addi	a0,a0,-1708 # 80024aa8 <icache>
    8000415c:	ffffd097          	auipc	ra,0xffffd
    80004160:	daa080e7          	jalr	-598(ra) # 80000f06 <release>
}
    80004164:	70e2                	ld	ra,56(sp)
    80004166:	7442                	ld	s0,48(sp)
    80004168:	74a2                	ld	s1,40(sp)
    8000416a:	7902                	ld	s2,32(sp)
    8000416c:	69e2                	ld	s3,24(sp)
    8000416e:	6a42                	ld	s4,16(sp)
    80004170:	6aa2                	ld	s5,8(sp)
    80004172:	6121                	addi	sp,sp,64
    80004174:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004176:	4cbc                	lw	a5,88(s1)
    80004178:	dbf9                	beqz	a5,8000414e <iput+0x2c>
    8000417a:	06249783          	lh	a5,98(s1)
    8000417e:	fbe1                	bnez	a5,8000414e <iput+0x2c>
    acquiresleep(&ip->lock);
    80004180:	01048a13          	addi	s4,s1,16
    80004184:	8552                	mv	a0,s4
    80004186:	00001097          	auipc	ra,0x1
    8000418a:	c3a080e7          	jalr	-966(ra) # 80004dc0 <acquiresleep>
    release(&icache.lock);
    8000418e:	00021517          	auipc	a0,0x21
    80004192:	91a50513          	addi	a0,a0,-1766 # 80024aa8 <icache>
    80004196:	ffffd097          	auipc	ra,0xffffd
    8000419a:	d70080e7          	jalr	-656(ra) # 80000f06 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000419e:	06848913          	addi	s2,s1,104
    800041a2:	09848993          	addi	s3,s1,152
    800041a6:	a819                	j	800041bc <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    800041a8:	4088                	lw	a0,0(s1)
    800041aa:	00000097          	auipc	ra,0x0
    800041ae:	878080e7          	jalr	-1928(ra) # 80003a22 <bfree>
      ip->addrs[i] = 0;
    800041b2:	00092023          	sw	zero,0(s2)
    800041b6:	0911                	addi	s2,s2,4
  for(i = 0; i < NDIRECT; i++){
    800041b8:	01390663          	beq	s2,s3,800041c4 <iput+0xa2>
    if(ip->addrs[i]){
    800041bc:	00092583          	lw	a1,0(s2)
    800041c0:	d9fd                	beqz	a1,800041b6 <iput+0x94>
    800041c2:	b7dd                	j	800041a8 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    800041c4:	0984a583          	lw	a1,152(s1)
    800041c8:	ed9d                	bnez	a1,80004206 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800041ca:	0604a223          	sw	zero,100(s1)
  iupdate(ip);
    800041ce:	8526                	mv	a0,s1
    800041d0:	00000097          	auipc	ra,0x0
    800041d4:	d76080e7          	jalr	-650(ra) # 80003f46 <iupdate>
    ip->type = 0;
    800041d8:	04049e23          	sh	zero,92(s1)
    iupdate(ip);
    800041dc:	8526                	mv	a0,s1
    800041de:	00000097          	auipc	ra,0x0
    800041e2:	d68080e7          	jalr	-664(ra) # 80003f46 <iupdate>
    ip->valid = 0;
    800041e6:	0404ac23          	sw	zero,88(s1)
    releasesleep(&ip->lock);
    800041ea:	8552                	mv	a0,s4
    800041ec:	00001097          	auipc	ra,0x1
    800041f0:	c2a080e7          	jalr	-982(ra) # 80004e16 <releasesleep>
    acquire(&icache.lock);
    800041f4:	00021517          	auipc	a0,0x21
    800041f8:	8b450513          	addi	a0,a0,-1868 # 80024aa8 <icache>
    800041fc:	ffffd097          	auipc	ra,0xffffd
    80004200:	abe080e7          	jalr	-1346(ra) # 80000cba <acquire>
    80004204:	b7a9                	j	8000414e <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004206:	4088                	lw	a0,0(s1)
    80004208:	fffff097          	auipc	ra,0xfffff
    8000420c:	5be080e7          	jalr	1470(ra) # 800037c6 <bread>
    80004210:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80004212:	07050913          	addi	s2,a0,112
    80004216:	47050993          	addi	s3,a0,1136
    8000421a:	a809                	j	8000422c <iput+0x10a>
        bfree(ip->dev, a[j]);
    8000421c:	4088                	lw	a0,0(s1)
    8000421e:	00000097          	auipc	ra,0x0
    80004222:	804080e7          	jalr	-2044(ra) # 80003a22 <bfree>
    80004226:	0911                	addi	s2,s2,4
    for(j = 0; j < NINDIRECT; j++){
    80004228:	01390663          	beq	s2,s3,80004234 <iput+0x112>
      if(a[j])
    8000422c:	00092583          	lw	a1,0(s2)
    80004230:	d9fd                	beqz	a1,80004226 <iput+0x104>
    80004232:	b7ed                	j	8000421c <iput+0xfa>
    brelse(bp);
    80004234:	8556                	mv	a0,s5
    80004236:	fffff097          	auipc	ra,0xfffff
    8000423a:	6d6080e7          	jalr	1750(ra) # 8000390c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000423e:	0984a583          	lw	a1,152(s1)
    80004242:	4088                	lw	a0,0(s1)
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	7de080e7          	jalr	2014(ra) # 80003a22 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000424c:	0804ac23          	sw	zero,152(s1)
    80004250:	bfad                	j	800041ca <iput+0xa8>

0000000080004252 <iunlockput>:
{
    80004252:	1101                	addi	sp,sp,-32
    80004254:	ec06                	sd	ra,24(sp)
    80004256:	e822                	sd	s0,16(sp)
    80004258:	e426                	sd	s1,8(sp)
    8000425a:	1000                	addi	s0,sp,32
    8000425c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000425e:	00000097          	auipc	ra,0x0
    80004262:	e78080e7          	jalr	-392(ra) # 800040d6 <iunlock>
  iput(ip);
    80004266:	8526                	mv	a0,s1
    80004268:	00000097          	auipc	ra,0x0
    8000426c:	eba080e7          	jalr	-326(ra) # 80004122 <iput>
}
    80004270:	60e2                	ld	ra,24(sp)
    80004272:	6442                	ld	s0,16(sp)
    80004274:	64a2                	ld	s1,8(sp)
    80004276:	6105                	addi	sp,sp,32
    80004278:	8082                	ret

000000008000427a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000427a:	1141                	addi	sp,sp,-16
    8000427c:	e422                	sd	s0,8(sp)
    8000427e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004280:	411c                	lw	a5,0(a0)
    80004282:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004284:	415c                	lw	a5,4(a0)
    80004286:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004288:	05c51783          	lh	a5,92(a0)
    8000428c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004290:	06251783          	lh	a5,98(a0)
    80004294:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004298:	06456783          	lwu	a5,100(a0)
    8000429c:	e99c                	sd	a5,16(a1)
}
    8000429e:	6422                	ld	s0,8(sp)
    800042a0:	0141                	addi	sp,sp,16
    800042a2:	8082                	ret

00000000800042a4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042a4:	517c                	lw	a5,100(a0)
    800042a6:	0ed7e563          	bltu	a5,a3,80004390 <readi+0xec>
{
    800042aa:	7159                	addi	sp,sp,-112
    800042ac:	f486                	sd	ra,104(sp)
    800042ae:	f0a2                	sd	s0,96(sp)
    800042b0:	eca6                	sd	s1,88(sp)
    800042b2:	e8ca                	sd	s2,80(sp)
    800042b4:	e4ce                	sd	s3,72(sp)
    800042b6:	e0d2                	sd	s4,64(sp)
    800042b8:	fc56                	sd	s5,56(sp)
    800042ba:	f85a                	sd	s6,48(sp)
    800042bc:	f45e                	sd	s7,40(sp)
    800042be:	f062                	sd	s8,32(sp)
    800042c0:	ec66                	sd	s9,24(sp)
    800042c2:	e86a                	sd	s10,16(sp)
    800042c4:	e46e                	sd	s11,8(sp)
    800042c6:	1880                	addi	s0,sp,112
    800042c8:	8baa                	mv	s7,a0
    800042ca:	8c2e                	mv	s8,a1
    800042cc:	8a32                	mv	s4,a2
    800042ce:	84b6                	mv	s1,a3
    800042d0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800042d2:	9f35                	addw	a4,a4,a3
    800042d4:	0cd76063          	bltu	a4,a3,80004394 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    800042d8:	00e7f463          	bleu	a4,a5,800042e0 <readi+0x3c>
    n = ip->size - off;
    800042dc:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042e0:	080b0763          	beqz	s6,8000436e <readi+0xca>
    800042e4:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800042e6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800042ea:	5cfd                	li	s9,-1
    800042ec:	a82d                	j	80004326 <readi+0x82>
    800042ee:	02091d93          	slli	s11,s2,0x20
    800042f2:	020ddd93          	srli	s11,s11,0x20
    800042f6:	070a8613          	addi	a2,s5,112
    800042fa:	86ee                	mv	a3,s11
    800042fc:	963a                	add	a2,a2,a4
    800042fe:	85d2                	mv	a1,s4
    80004300:	8562                	mv	a0,s8
    80004302:	fffff097          	auipc	ra,0xfffff
    80004306:	892080e7          	jalr	-1902(ra) # 80002b94 <either_copyout>
    8000430a:	05950d63          	beq	a0,s9,80004364 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    8000430e:	8556                	mv	a0,s5
    80004310:	fffff097          	auipc	ra,0xfffff
    80004314:	5fc080e7          	jalr	1532(ra) # 8000390c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004318:	013909bb          	addw	s3,s2,s3
    8000431c:	009904bb          	addw	s1,s2,s1
    80004320:	9a6e                	add	s4,s4,s11
    80004322:	0569f663          	bleu	s6,s3,8000436e <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004326:	000ba903          	lw	s2,0(s7)
    8000432a:	00a4d59b          	srliw	a1,s1,0xa
    8000432e:	855e                	mv	a0,s7
    80004330:	00000097          	auipc	ra,0x0
    80004334:	8d2080e7          	jalr	-1838(ra) # 80003c02 <bmap>
    80004338:	0005059b          	sext.w	a1,a0
    8000433c:	854a                	mv	a0,s2
    8000433e:	fffff097          	auipc	ra,0xfffff
    80004342:	488080e7          	jalr	1160(ra) # 800037c6 <bread>
    80004346:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004348:	3ff4f713          	andi	a4,s1,1023
    8000434c:	40ed07bb          	subw	a5,s10,a4
    80004350:	413b06bb          	subw	a3,s6,s3
    80004354:	893e                	mv	s2,a5
    80004356:	2781                	sext.w	a5,a5
    80004358:	0006861b          	sext.w	a2,a3
    8000435c:	f8f679e3          	bleu	a5,a2,800042ee <readi+0x4a>
    80004360:	8936                	mv	s2,a3
    80004362:	b771                	j	800042ee <readi+0x4a>
      brelse(bp);
    80004364:	8556                	mv	a0,s5
    80004366:	fffff097          	auipc	ra,0xfffff
    8000436a:	5a6080e7          	jalr	1446(ra) # 8000390c <brelse>
  }
  return n;
    8000436e:	000b051b          	sext.w	a0,s6
}
    80004372:	70a6                	ld	ra,104(sp)
    80004374:	7406                	ld	s0,96(sp)
    80004376:	64e6                	ld	s1,88(sp)
    80004378:	6946                	ld	s2,80(sp)
    8000437a:	69a6                	ld	s3,72(sp)
    8000437c:	6a06                	ld	s4,64(sp)
    8000437e:	7ae2                	ld	s5,56(sp)
    80004380:	7b42                	ld	s6,48(sp)
    80004382:	7ba2                	ld	s7,40(sp)
    80004384:	7c02                	ld	s8,32(sp)
    80004386:	6ce2                	ld	s9,24(sp)
    80004388:	6d42                	ld	s10,16(sp)
    8000438a:	6da2                	ld	s11,8(sp)
    8000438c:	6165                	addi	sp,sp,112
    8000438e:	8082                	ret
    return -1;
    80004390:	557d                	li	a0,-1
}
    80004392:	8082                	ret
    return -1;
    80004394:	557d                	li	a0,-1
    80004396:	bff1                	j	80004372 <readi+0xce>

0000000080004398 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004398:	517c                	lw	a5,100(a0)
    8000439a:	10d7e663          	bltu	a5,a3,800044a6 <writei+0x10e>
{
    8000439e:	7159                	addi	sp,sp,-112
    800043a0:	f486                	sd	ra,104(sp)
    800043a2:	f0a2                	sd	s0,96(sp)
    800043a4:	eca6                	sd	s1,88(sp)
    800043a6:	e8ca                	sd	s2,80(sp)
    800043a8:	e4ce                	sd	s3,72(sp)
    800043aa:	e0d2                	sd	s4,64(sp)
    800043ac:	fc56                	sd	s5,56(sp)
    800043ae:	f85a                	sd	s6,48(sp)
    800043b0:	f45e                	sd	s7,40(sp)
    800043b2:	f062                	sd	s8,32(sp)
    800043b4:	ec66                	sd	s9,24(sp)
    800043b6:	e86a                	sd	s10,16(sp)
    800043b8:	e46e                	sd	s11,8(sp)
    800043ba:	1880                	addi	s0,sp,112
    800043bc:	8baa                	mv	s7,a0
    800043be:	8c2e                	mv	s8,a1
    800043c0:	8ab2                	mv	s5,a2
    800043c2:	84b6                	mv	s1,a3
    800043c4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800043c6:	00e687bb          	addw	a5,a3,a4
    800043ca:	0ed7e063          	bltu	a5,a3,800044aa <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800043ce:	00043737          	lui	a4,0x43
    800043d2:	0cf76e63          	bltu	a4,a5,800044ae <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043d6:	0a0b0763          	beqz	s6,80004484 <writei+0xec>
    800043da:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800043dc:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800043e0:	5cfd                	li	s9,-1
    800043e2:	a091                	j	80004426 <writei+0x8e>
    800043e4:	02091d93          	slli	s11,s2,0x20
    800043e8:	020ddd93          	srli	s11,s11,0x20
    800043ec:	07098513          	addi	a0,s3,112
    800043f0:	86ee                	mv	a3,s11
    800043f2:	8656                	mv	a2,s5
    800043f4:	85e2                	mv	a1,s8
    800043f6:	953a                	add	a0,a0,a4
    800043f8:	ffffe097          	auipc	ra,0xffffe
    800043fc:	7f2080e7          	jalr	2034(ra) # 80002bea <either_copyin>
    80004400:	07950263          	beq	a0,s9,80004464 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004404:	854e                	mv	a0,s3
    80004406:	00001097          	auipc	ra,0x1
    8000440a:	830080e7          	jalr	-2000(ra) # 80004c36 <log_write>
    brelse(bp);
    8000440e:	854e                	mv	a0,s3
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	4fc080e7          	jalr	1276(ra) # 8000390c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004418:	01490a3b          	addw	s4,s2,s4
    8000441c:	009904bb          	addw	s1,s2,s1
    80004420:	9aee                	add	s5,s5,s11
    80004422:	056a7663          	bleu	s6,s4,8000446e <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004426:	000ba903          	lw	s2,0(s7)
    8000442a:	00a4d59b          	srliw	a1,s1,0xa
    8000442e:	855e                	mv	a0,s7
    80004430:	fffff097          	auipc	ra,0xfffff
    80004434:	7d2080e7          	jalr	2002(ra) # 80003c02 <bmap>
    80004438:	0005059b          	sext.w	a1,a0
    8000443c:	854a                	mv	a0,s2
    8000443e:	fffff097          	auipc	ra,0xfffff
    80004442:	388080e7          	jalr	904(ra) # 800037c6 <bread>
    80004446:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004448:	3ff4f713          	andi	a4,s1,1023
    8000444c:	40ed07bb          	subw	a5,s10,a4
    80004450:	414b06bb          	subw	a3,s6,s4
    80004454:	893e                	mv	s2,a5
    80004456:	2781                	sext.w	a5,a5
    80004458:	0006861b          	sext.w	a2,a3
    8000445c:	f8f674e3          	bleu	a5,a2,800043e4 <writei+0x4c>
    80004460:	8936                	mv	s2,a3
    80004462:	b749                	j	800043e4 <writei+0x4c>
      brelse(bp);
    80004464:	854e                	mv	a0,s3
    80004466:	fffff097          	auipc	ra,0xfffff
    8000446a:	4a6080e7          	jalr	1190(ra) # 8000390c <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    8000446e:	064ba783          	lw	a5,100(s7)
    80004472:	0097f463          	bleu	s1,a5,8000447a <writei+0xe2>
      ip->size = off;
    80004476:	069ba223          	sw	s1,100(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    8000447a:	855e                	mv	a0,s7
    8000447c:	00000097          	auipc	ra,0x0
    80004480:	aca080e7          	jalr	-1334(ra) # 80003f46 <iupdate>
  }

  return n;
    80004484:	000b051b          	sext.w	a0,s6
}
    80004488:	70a6                	ld	ra,104(sp)
    8000448a:	7406                	ld	s0,96(sp)
    8000448c:	64e6                	ld	s1,88(sp)
    8000448e:	6946                	ld	s2,80(sp)
    80004490:	69a6                	ld	s3,72(sp)
    80004492:	6a06                	ld	s4,64(sp)
    80004494:	7ae2                	ld	s5,56(sp)
    80004496:	7b42                	ld	s6,48(sp)
    80004498:	7ba2                	ld	s7,40(sp)
    8000449a:	7c02                	ld	s8,32(sp)
    8000449c:	6ce2                	ld	s9,24(sp)
    8000449e:	6d42                	ld	s10,16(sp)
    800044a0:	6da2                	ld	s11,8(sp)
    800044a2:	6165                	addi	sp,sp,112
    800044a4:	8082                	ret
    return -1;
    800044a6:	557d                	li	a0,-1
}
    800044a8:	8082                	ret
    return -1;
    800044aa:	557d                	li	a0,-1
    800044ac:	bff1                	j	80004488 <writei+0xf0>
    return -1;
    800044ae:	557d                	li	a0,-1
    800044b0:	bfe1                	j	80004488 <writei+0xf0>

00000000800044b2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800044b2:	1141                	addi	sp,sp,-16
    800044b4:	e406                	sd	ra,8(sp)
    800044b6:	e022                	sd	s0,0(sp)
    800044b8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800044ba:	4639                	li	a2,14
    800044bc:	ffffd097          	auipc	ra,0xffffd
    800044c0:	d5a080e7          	jalr	-678(ra) # 80001216 <strncmp>
}
    800044c4:	60a2                	ld	ra,8(sp)
    800044c6:	6402                	ld	s0,0(sp)
    800044c8:	0141                	addi	sp,sp,16
    800044ca:	8082                	ret

00000000800044cc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800044cc:	7139                	addi	sp,sp,-64
    800044ce:	fc06                	sd	ra,56(sp)
    800044d0:	f822                	sd	s0,48(sp)
    800044d2:	f426                	sd	s1,40(sp)
    800044d4:	f04a                	sd	s2,32(sp)
    800044d6:	ec4e                	sd	s3,24(sp)
    800044d8:	e852                	sd	s4,16(sp)
    800044da:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800044dc:	05c51703          	lh	a4,92(a0)
    800044e0:	4785                	li	a5,1
    800044e2:	00f71a63          	bne	a4,a5,800044f6 <dirlookup+0x2a>
    800044e6:	892a                	mv	s2,a0
    800044e8:	89ae                	mv	s3,a1
    800044ea:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800044ec:	517c                	lw	a5,100(a0)
    800044ee:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800044f0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044f2:	e79d                	bnez	a5,80004520 <dirlookup+0x54>
    800044f4:	a8a5                	j	8000456c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800044f6:	00004517          	auipc	a0,0x4
    800044fa:	64250513          	addi	a0,a0,1602 # 80008b38 <userret+0xaa8>
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	286080e7          	jalr	646(ra) # 80000784 <panic>
      panic("dirlookup read");
    80004506:	00004517          	auipc	a0,0x4
    8000450a:	64a50513          	addi	a0,a0,1610 # 80008b50 <userret+0xac0>
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	276080e7          	jalr	630(ra) # 80000784 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004516:	24c1                	addiw	s1,s1,16
    80004518:	06492783          	lw	a5,100(s2)
    8000451c:	04f4f763          	bleu	a5,s1,8000456a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004520:	4741                	li	a4,16
    80004522:	86a6                	mv	a3,s1
    80004524:	fc040613          	addi	a2,s0,-64
    80004528:	4581                	li	a1,0
    8000452a:	854a                	mv	a0,s2
    8000452c:	00000097          	auipc	ra,0x0
    80004530:	d78080e7          	jalr	-648(ra) # 800042a4 <readi>
    80004534:	47c1                	li	a5,16
    80004536:	fcf518e3          	bne	a0,a5,80004506 <dirlookup+0x3a>
    if(de.inum == 0)
    8000453a:	fc045783          	lhu	a5,-64(s0)
    8000453e:	dfe1                	beqz	a5,80004516 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004540:	fc240593          	addi	a1,s0,-62
    80004544:	854e                	mv	a0,s3
    80004546:	00000097          	auipc	ra,0x0
    8000454a:	f6c080e7          	jalr	-148(ra) # 800044b2 <namecmp>
    8000454e:	f561                	bnez	a0,80004516 <dirlookup+0x4a>
      if(poff)
    80004550:	000a0463          	beqz	s4,80004558 <dirlookup+0x8c>
        *poff = off;
    80004554:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80004558:	fc045583          	lhu	a1,-64(s0)
    8000455c:	00092503          	lw	a0,0(s2)
    80004560:	fffff097          	auipc	ra,0xfffff
    80004564:	77c080e7          	jalr	1916(ra) # 80003cdc <iget>
    80004568:	a011                	j	8000456c <dirlookup+0xa0>
  return 0;
    8000456a:	4501                	li	a0,0
}
    8000456c:	70e2                	ld	ra,56(sp)
    8000456e:	7442                	ld	s0,48(sp)
    80004570:	74a2                	ld	s1,40(sp)
    80004572:	7902                	ld	s2,32(sp)
    80004574:	69e2                	ld	s3,24(sp)
    80004576:	6a42                	ld	s4,16(sp)
    80004578:	6121                	addi	sp,sp,64
    8000457a:	8082                	ret

000000008000457c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000457c:	711d                	addi	sp,sp,-96
    8000457e:	ec86                	sd	ra,88(sp)
    80004580:	e8a2                	sd	s0,80(sp)
    80004582:	e4a6                	sd	s1,72(sp)
    80004584:	e0ca                	sd	s2,64(sp)
    80004586:	fc4e                	sd	s3,56(sp)
    80004588:	f852                	sd	s4,48(sp)
    8000458a:	f456                	sd	s5,40(sp)
    8000458c:	f05a                	sd	s6,32(sp)
    8000458e:	ec5e                	sd	s7,24(sp)
    80004590:	e862                	sd	s8,16(sp)
    80004592:	e466                	sd	s9,8(sp)
    80004594:	1080                	addi	s0,sp,96
    80004596:	84aa                	mv	s1,a0
    80004598:	8bae                	mv	s7,a1
    8000459a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000459c:	00054703          	lbu	a4,0(a0)
    800045a0:	02f00793          	li	a5,47
    800045a4:	02f70363          	beq	a4,a5,800045ca <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800045a8:	ffffe097          	auipc	ra,0xffffe
    800045ac:	a98080e7          	jalr	-1384(ra) # 80002040 <myproc>
    800045b0:	16853503          	ld	a0,360(a0)
    800045b4:	00000097          	auipc	ra,0x0
    800045b8:	a20080e7          	jalr	-1504(ra) # 80003fd4 <idup>
    800045bc:	89aa                	mv	s3,a0
  while(*path == '/')
    800045be:	02f00913          	li	s2,47
  len = path - s;
    800045c2:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800045c4:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800045c6:	4c05                	li	s8,1
    800045c8:	a865                	j	80004680 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800045ca:	4585                	li	a1,1
    800045cc:	4501                	li	a0,0
    800045ce:	fffff097          	auipc	ra,0xfffff
    800045d2:	70e080e7          	jalr	1806(ra) # 80003cdc <iget>
    800045d6:	89aa                	mv	s3,a0
    800045d8:	b7dd                	j	800045be <namex+0x42>
      iunlockput(ip);
    800045da:	854e                	mv	a0,s3
    800045dc:	00000097          	auipc	ra,0x0
    800045e0:	c76080e7          	jalr	-906(ra) # 80004252 <iunlockput>
      return 0;
    800045e4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800045e6:	854e                	mv	a0,s3
    800045e8:	60e6                	ld	ra,88(sp)
    800045ea:	6446                	ld	s0,80(sp)
    800045ec:	64a6                	ld	s1,72(sp)
    800045ee:	6906                	ld	s2,64(sp)
    800045f0:	79e2                	ld	s3,56(sp)
    800045f2:	7a42                	ld	s4,48(sp)
    800045f4:	7aa2                	ld	s5,40(sp)
    800045f6:	7b02                	ld	s6,32(sp)
    800045f8:	6be2                	ld	s7,24(sp)
    800045fa:	6c42                	ld	s8,16(sp)
    800045fc:	6ca2                	ld	s9,8(sp)
    800045fe:	6125                	addi	sp,sp,96
    80004600:	8082                	ret
      iunlock(ip);
    80004602:	854e                	mv	a0,s3
    80004604:	00000097          	auipc	ra,0x0
    80004608:	ad2080e7          	jalr	-1326(ra) # 800040d6 <iunlock>
      return ip;
    8000460c:	bfe9                	j	800045e6 <namex+0x6a>
      iunlockput(ip);
    8000460e:	854e                	mv	a0,s3
    80004610:	00000097          	auipc	ra,0x0
    80004614:	c42080e7          	jalr	-958(ra) # 80004252 <iunlockput>
      return 0;
    80004618:	89d2                	mv	s3,s4
    8000461a:	b7f1                	j	800045e6 <namex+0x6a>
  len = path - s;
    8000461c:	40b48633          	sub	a2,s1,a1
    80004620:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004624:	094cd663          	ble	s4,s9,800046b0 <namex+0x134>
    memmove(name, s, DIRSIZ);
    80004628:	4639                	li	a2,14
    8000462a:	8556                	mv	a0,s5
    8000462c:	ffffd097          	auipc	ra,0xffffd
    80004630:	b6e080e7          	jalr	-1170(ra) # 8000119a <memmove>
  while(*path == '/')
    80004634:	0004c783          	lbu	a5,0(s1)
    80004638:	01279763          	bne	a5,s2,80004646 <namex+0xca>
    path++;
    8000463c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000463e:	0004c783          	lbu	a5,0(s1)
    80004642:	ff278de3          	beq	a5,s2,8000463c <namex+0xc0>
    ilock(ip);
    80004646:	854e                	mv	a0,s3
    80004648:	00000097          	auipc	ra,0x0
    8000464c:	9ca080e7          	jalr	-1590(ra) # 80004012 <ilock>
    if(ip->type != T_DIR){
    80004650:	05c99783          	lh	a5,92(s3)
    80004654:	f98793e3          	bne	a5,s8,800045da <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004658:	000b8563          	beqz	s7,80004662 <namex+0xe6>
    8000465c:	0004c783          	lbu	a5,0(s1)
    80004660:	d3cd                	beqz	a5,80004602 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004662:	865a                	mv	a2,s6
    80004664:	85d6                	mv	a1,s5
    80004666:	854e                	mv	a0,s3
    80004668:	00000097          	auipc	ra,0x0
    8000466c:	e64080e7          	jalr	-412(ra) # 800044cc <dirlookup>
    80004670:	8a2a                	mv	s4,a0
    80004672:	dd51                	beqz	a0,8000460e <namex+0x92>
    iunlockput(ip);
    80004674:	854e                	mv	a0,s3
    80004676:	00000097          	auipc	ra,0x0
    8000467a:	bdc080e7          	jalr	-1060(ra) # 80004252 <iunlockput>
    ip = next;
    8000467e:	89d2                	mv	s3,s4
  while(*path == '/')
    80004680:	0004c783          	lbu	a5,0(s1)
    80004684:	05279d63          	bne	a5,s2,800046de <namex+0x162>
    path++;
    80004688:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000468a:	0004c783          	lbu	a5,0(s1)
    8000468e:	ff278de3          	beq	a5,s2,80004688 <namex+0x10c>
  if(*path == 0)
    80004692:	cf8d                	beqz	a5,800046cc <namex+0x150>
  while(*path != '/' && *path != 0)
    80004694:	01278b63          	beq	a5,s2,800046aa <namex+0x12e>
    80004698:	c795                	beqz	a5,800046c4 <namex+0x148>
    path++;
    8000469a:	85a6                	mv	a1,s1
    path++;
    8000469c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000469e:	0004c783          	lbu	a5,0(s1)
    800046a2:	f7278de3          	beq	a5,s2,8000461c <namex+0xa0>
    800046a6:	fbfd                	bnez	a5,8000469c <namex+0x120>
    800046a8:	bf95                	j	8000461c <namex+0xa0>
    800046aa:	85a6                	mv	a1,s1
  len = path - s;
    800046ac:	8a5a                	mv	s4,s6
    800046ae:	865a                	mv	a2,s6
    memmove(name, s, len);
    800046b0:	2601                	sext.w	a2,a2
    800046b2:	8556                	mv	a0,s5
    800046b4:	ffffd097          	auipc	ra,0xffffd
    800046b8:	ae6080e7          	jalr	-1306(ra) # 8000119a <memmove>
    name[len] = 0;
    800046bc:	9a56                	add	s4,s4,s5
    800046be:	000a0023          	sb	zero,0(s4)
    800046c2:	bf8d                	j	80004634 <namex+0xb8>
  while(*path != '/' && *path != 0)
    800046c4:	85a6                	mv	a1,s1
  len = path - s;
    800046c6:	8a5a                	mv	s4,s6
    800046c8:	865a                	mv	a2,s6
    800046ca:	b7dd                	j	800046b0 <namex+0x134>
  if(nameiparent){
    800046cc:	f00b8de3          	beqz	s7,800045e6 <namex+0x6a>
    iput(ip);
    800046d0:	854e                	mv	a0,s3
    800046d2:	00000097          	auipc	ra,0x0
    800046d6:	a50080e7          	jalr	-1456(ra) # 80004122 <iput>
    return 0;
    800046da:	4981                	li	s3,0
    800046dc:	b729                	j	800045e6 <namex+0x6a>
  if(*path == 0)
    800046de:	d7fd                	beqz	a5,800046cc <namex+0x150>
    800046e0:	85a6                	mv	a1,s1
    800046e2:	bf6d                	j	8000469c <namex+0x120>

00000000800046e4 <dirlink>:
{
    800046e4:	7139                	addi	sp,sp,-64
    800046e6:	fc06                	sd	ra,56(sp)
    800046e8:	f822                	sd	s0,48(sp)
    800046ea:	f426                	sd	s1,40(sp)
    800046ec:	f04a                	sd	s2,32(sp)
    800046ee:	ec4e                	sd	s3,24(sp)
    800046f0:	e852                	sd	s4,16(sp)
    800046f2:	0080                	addi	s0,sp,64
    800046f4:	892a                	mv	s2,a0
    800046f6:	8a2e                	mv	s4,a1
    800046f8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800046fa:	4601                	li	a2,0
    800046fc:	00000097          	auipc	ra,0x0
    80004700:	dd0080e7          	jalr	-560(ra) # 800044cc <dirlookup>
    80004704:	e93d                	bnez	a0,8000477a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004706:	06492483          	lw	s1,100(s2)
    8000470a:	c49d                	beqz	s1,80004738 <dirlink+0x54>
    8000470c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000470e:	4741                	li	a4,16
    80004710:	86a6                	mv	a3,s1
    80004712:	fc040613          	addi	a2,s0,-64
    80004716:	4581                	li	a1,0
    80004718:	854a                	mv	a0,s2
    8000471a:	00000097          	auipc	ra,0x0
    8000471e:	b8a080e7          	jalr	-1142(ra) # 800042a4 <readi>
    80004722:	47c1                	li	a5,16
    80004724:	06f51163          	bne	a0,a5,80004786 <dirlink+0xa2>
    if(de.inum == 0)
    80004728:	fc045783          	lhu	a5,-64(s0)
    8000472c:	c791                	beqz	a5,80004738 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000472e:	24c1                	addiw	s1,s1,16
    80004730:	06492783          	lw	a5,100(s2)
    80004734:	fcf4ede3          	bltu	s1,a5,8000470e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004738:	4639                	li	a2,14
    8000473a:	85d2                	mv	a1,s4
    8000473c:	fc240513          	addi	a0,s0,-62
    80004740:	ffffd097          	auipc	ra,0xffffd
    80004744:	b26080e7          	jalr	-1242(ra) # 80001266 <strncpy>
  de.inum = inum;
    80004748:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000474c:	4741                	li	a4,16
    8000474e:	86a6                	mv	a3,s1
    80004750:	fc040613          	addi	a2,s0,-64
    80004754:	4581                	li	a1,0
    80004756:	854a                	mv	a0,s2
    80004758:	00000097          	auipc	ra,0x0
    8000475c:	c40080e7          	jalr	-960(ra) # 80004398 <writei>
    80004760:	4741                	li	a4,16
  return 0;
    80004762:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004764:	02e51963          	bne	a0,a4,80004796 <dirlink+0xb2>
}
    80004768:	853e                	mv	a0,a5
    8000476a:	70e2                	ld	ra,56(sp)
    8000476c:	7442                	ld	s0,48(sp)
    8000476e:	74a2                	ld	s1,40(sp)
    80004770:	7902                	ld	s2,32(sp)
    80004772:	69e2                	ld	s3,24(sp)
    80004774:	6a42                	ld	s4,16(sp)
    80004776:	6121                	addi	sp,sp,64
    80004778:	8082                	ret
    iput(ip);
    8000477a:	00000097          	auipc	ra,0x0
    8000477e:	9a8080e7          	jalr	-1624(ra) # 80004122 <iput>
    return -1;
    80004782:	57fd                	li	a5,-1
    80004784:	b7d5                	j	80004768 <dirlink+0x84>
      panic("dirlink read");
    80004786:	00004517          	auipc	a0,0x4
    8000478a:	3da50513          	addi	a0,a0,986 # 80008b60 <userret+0xad0>
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	ff6080e7          	jalr	-10(ra) # 80000784 <panic>
    panic("dirlink");
    80004796:	00004517          	auipc	a0,0x4
    8000479a:	4ea50513          	addi	a0,a0,1258 # 80008c80 <userret+0xbf0>
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	fe6080e7          	jalr	-26(ra) # 80000784 <panic>

00000000800047a6 <namei>:

struct inode*
namei(char *path)
{
    800047a6:	1101                	addi	sp,sp,-32
    800047a8:	ec06                	sd	ra,24(sp)
    800047aa:	e822                	sd	s0,16(sp)
    800047ac:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800047ae:	fe040613          	addi	a2,s0,-32
    800047b2:	4581                	li	a1,0
    800047b4:	00000097          	auipc	ra,0x0
    800047b8:	dc8080e7          	jalr	-568(ra) # 8000457c <namex>
}
    800047bc:	60e2                	ld	ra,24(sp)
    800047be:	6442                	ld	s0,16(sp)
    800047c0:	6105                	addi	sp,sp,32
    800047c2:	8082                	ret

00000000800047c4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800047c4:	1141                	addi	sp,sp,-16
    800047c6:	e406                	sd	ra,8(sp)
    800047c8:	e022                	sd	s0,0(sp)
    800047ca:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    800047cc:	862e                	mv	a2,a1
    800047ce:	4585                	li	a1,1
    800047d0:	00000097          	auipc	ra,0x0
    800047d4:	dac080e7          	jalr	-596(ra) # 8000457c <namex>
}
    800047d8:	60a2                	ld	ra,8(sp)
    800047da:	6402                	ld	s0,0(sp)
    800047dc:	0141                	addi	sp,sp,16
    800047de:	8082                	ret

00000000800047e0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    800047e0:	7179                	addi	sp,sp,-48
    800047e2:	f406                	sd	ra,40(sp)
    800047e4:	f022                	sd	s0,32(sp)
    800047e6:	ec26                	sd	s1,24(sp)
    800047e8:	e84a                	sd	s2,16(sp)
    800047ea:	e44e                	sd	s3,8(sp)
    800047ec:	1800                	addi	s0,sp,48
  struct buf *buf = bread(dev, log[dev].start);
    800047ee:	00151913          	slli	s2,a0,0x1
    800047f2:	992a                	add	s2,s2,a0
    800047f4:	00691793          	slli	a5,s2,0x6
    800047f8:	00022917          	auipc	s2,0x22
    800047fc:	22090913          	addi	s2,s2,544 # 80026a18 <log>
    80004800:	993e                	add	s2,s2,a5
    80004802:	03092583          	lw	a1,48(s2)
    80004806:	fffff097          	auipc	ra,0xfffff
    8000480a:	fc0080e7          	jalr	-64(ra) # 800037c6 <bread>
    8000480e:	89aa                	mv	s3,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80004810:	04492783          	lw	a5,68(s2)
    80004814:	d93c                	sw	a5,112(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004816:	04492783          	lw	a5,68(s2)
    8000481a:	00f05f63          	blez	a5,80004838 <write_head+0x58>
    8000481e:	87ca                	mv	a5,s2
    80004820:	07450693          	addi	a3,a0,116
    80004824:	4701                	li	a4,0
    80004826:	85ca                	mv	a1,s2
    hb->block[i] = log[dev].lh.block[i];
    80004828:	47b0                	lw	a2,72(a5)
    8000482a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000482c:	2705                	addiw	a4,a4,1
    8000482e:	0791                	addi	a5,a5,4
    80004830:	0691                	addi	a3,a3,4
    80004832:	41f0                	lw	a2,68(a1)
    80004834:	fec74ae3          	blt	a4,a2,80004828 <write_head+0x48>
  }
  bwrite(buf);
    80004838:	854e                	mv	a0,s3
    8000483a:	fffff097          	auipc	ra,0xfffff
    8000483e:	092080e7          	jalr	146(ra) # 800038cc <bwrite>
  brelse(buf);
    80004842:	854e                	mv	a0,s3
    80004844:	fffff097          	auipc	ra,0xfffff
    80004848:	0c8080e7          	jalr	200(ra) # 8000390c <brelse>
}
    8000484c:	70a2                	ld	ra,40(sp)
    8000484e:	7402                	ld	s0,32(sp)
    80004850:	64e2                	ld	s1,24(sp)
    80004852:	6942                	ld	s2,16(sp)
    80004854:	69a2                	ld	s3,8(sp)
    80004856:	6145                	addi	sp,sp,48
    80004858:	8082                	ret

000000008000485a <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000485a:	00151793          	slli	a5,a0,0x1
    8000485e:	97aa                	add	a5,a5,a0
    80004860:	079a                	slli	a5,a5,0x6
    80004862:	00022717          	auipc	a4,0x22
    80004866:	1b670713          	addi	a4,a4,438 # 80026a18 <log>
    8000486a:	97ba                	add	a5,a5,a4
    8000486c:	43fc                	lw	a5,68(a5)
    8000486e:	0af05863          	blez	a5,8000491e <install_trans+0xc4>
{
    80004872:	7139                	addi	sp,sp,-64
    80004874:	fc06                	sd	ra,56(sp)
    80004876:	f822                	sd	s0,48(sp)
    80004878:	f426                	sd	s1,40(sp)
    8000487a:	f04a                	sd	s2,32(sp)
    8000487c:	ec4e                	sd	s3,24(sp)
    8000487e:	e852                	sd	s4,16(sp)
    80004880:	e456                	sd	s5,8(sp)
    80004882:	e05a                	sd	s6,0(sp)
    80004884:	0080                	addi	s0,sp,64
    80004886:	00151993          	slli	s3,a0,0x1
    8000488a:	99aa                	add	s3,s3,a0
    8000488c:	00699793          	slli	a5,s3,0x6
    80004890:	00f709b3          	add	s3,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004894:	4901                	li	s2,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80004896:	00050b1b          	sext.w	s6,a0
    8000489a:	8ace                	mv	s5,s3
    8000489c:	030aa583          	lw	a1,48(s5)
    800048a0:	012585bb          	addw	a1,a1,s2
    800048a4:	2585                	addiw	a1,a1,1
    800048a6:	855a                	mv	a0,s6
    800048a8:	fffff097          	auipc	ra,0xfffff
    800048ac:	f1e080e7          	jalr	-226(ra) # 800037c6 <bread>
    800048b0:	8a2a                	mv	s4,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    800048b2:	0489a583          	lw	a1,72(s3)
    800048b6:	855a                	mv	a0,s6
    800048b8:	fffff097          	auipc	ra,0xfffff
    800048bc:	f0e080e7          	jalr	-242(ra) # 800037c6 <bread>
    800048c0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800048c2:	40000613          	li	a2,1024
    800048c6:	070a0593          	addi	a1,s4,112
    800048ca:	07050513          	addi	a0,a0,112
    800048ce:	ffffd097          	auipc	ra,0xffffd
    800048d2:	8cc080e7          	jalr	-1844(ra) # 8000119a <memmove>
    bwrite(dbuf);  // write dst to disk
    800048d6:	8526                	mv	a0,s1
    800048d8:	fffff097          	auipc	ra,0xfffff
    800048dc:	ff4080e7          	jalr	-12(ra) # 800038cc <bwrite>
    bunpin(dbuf);
    800048e0:	8526                	mv	a0,s1
    800048e2:	fffff097          	auipc	ra,0xfffff
    800048e6:	104080e7          	jalr	260(ra) # 800039e6 <bunpin>
    brelse(lbuf);
    800048ea:	8552                	mv	a0,s4
    800048ec:	fffff097          	auipc	ra,0xfffff
    800048f0:	020080e7          	jalr	32(ra) # 8000390c <brelse>
    brelse(dbuf);
    800048f4:	8526                	mv	a0,s1
    800048f6:	fffff097          	auipc	ra,0xfffff
    800048fa:	016080e7          	jalr	22(ra) # 8000390c <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800048fe:	2905                	addiw	s2,s2,1
    80004900:	0991                	addi	s3,s3,4
    80004902:	044aa783          	lw	a5,68(s5)
    80004906:	f8f94be3          	blt	s2,a5,8000489c <install_trans+0x42>
}
    8000490a:	70e2                	ld	ra,56(sp)
    8000490c:	7442                	ld	s0,48(sp)
    8000490e:	74a2                	ld	s1,40(sp)
    80004910:	7902                	ld	s2,32(sp)
    80004912:	69e2                	ld	s3,24(sp)
    80004914:	6a42                	ld	s4,16(sp)
    80004916:	6aa2                	ld	s5,8(sp)
    80004918:	6b02                	ld	s6,0(sp)
    8000491a:	6121                	addi	sp,sp,64
    8000491c:	8082                	ret
    8000491e:	8082                	ret

0000000080004920 <initlog>:
{
    80004920:	7179                	addi	sp,sp,-48
    80004922:	f406                	sd	ra,40(sp)
    80004924:	f022                	sd	s0,32(sp)
    80004926:	ec26                	sd	s1,24(sp)
    80004928:	e84a                	sd	s2,16(sp)
    8000492a:	e44e                	sd	s3,8(sp)
    8000492c:	e052                	sd	s4,0(sp)
    8000492e:	1800                	addi	s0,sp,48
    80004930:	892a                	mv	s2,a0
    80004932:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80004934:	00151713          	slli	a4,a0,0x1
    80004938:	972a                	add	a4,a4,a0
    8000493a:	00671493          	slli	s1,a4,0x6
    8000493e:	00022997          	auipc	s3,0x22
    80004942:	0da98993          	addi	s3,s3,218 # 80026a18 <log>
    80004946:	99a6                	add	s3,s3,s1
    80004948:	00004597          	auipc	a1,0x4
    8000494c:	22858593          	addi	a1,a1,552 # 80008b70 <userret+0xae0>
    80004950:	854e                	mv	a0,s3
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	1fa080e7          	jalr	506(ra) # 80000b4c <initlock>
  log[dev].start = sb->logstart;
    8000495a:	014a2583          	lw	a1,20(s4)
    8000495e:	02b9a823          	sw	a1,48(s3)
  log[dev].size = sb->nlog;
    80004962:	010a2783          	lw	a5,16(s4)
    80004966:	02f9aa23          	sw	a5,52(s3)
  log[dev].dev = dev;
    8000496a:	0529a023          	sw	s2,64(s3)
  struct buf *buf = bread(dev, log[dev].start);
    8000496e:	854a                	mv	a0,s2
    80004970:	fffff097          	auipc	ra,0xfffff
    80004974:	e56080e7          	jalr	-426(ra) # 800037c6 <bread>
  log[dev].lh.n = lh->n;
    80004978:	593c                	lw	a5,112(a0)
    8000497a:	04f9a223          	sw	a5,68(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000497e:	02f05663          	blez	a5,800049aa <initlog+0x8a>
    80004982:	07450693          	addi	a3,a0,116
    80004986:	00022717          	auipc	a4,0x22
    8000498a:	0da70713          	addi	a4,a4,218 # 80026a60 <log+0x48>
    8000498e:	9726                	add	a4,a4,s1
    80004990:	37fd                	addiw	a5,a5,-1
    80004992:	1782                	slli	a5,a5,0x20
    80004994:	9381                	srli	a5,a5,0x20
    80004996:	078a                	slli	a5,a5,0x2
    80004998:	07850613          	addi	a2,a0,120
    8000499c:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    8000499e:	4290                	lw	a2,0(a3)
    800049a0:	c310                	sw	a2,0(a4)
    800049a2:	0691                	addi	a3,a3,4
    800049a4:	0711                	addi	a4,a4,4
  for (i = 0; i < log[dev].lh.n; i++) {
    800049a6:	fef69ce3          	bne	a3,a5,8000499e <initlog+0x7e>
  brelse(buf);
    800049aa:	fffff097          	auipc	ra,0xfffff
    800049ae:	f62080e7          	jalr	-158(ra) # 8000390c <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    800049b2:	854a                	mv	a0,s2
    800049b4:	00000097          	auipc	ra,0x0
    800049b8:	ea6080e7          	jalr	-346(ra) # 8000485a <install_trans>
  log[dev].lh.n = 0;
    800049bc:	00191793          	slli	a5,s2,0x1
    800049c0:	97ca                	add	a5,a5,s2
    800049c2:	079a                	slli	a5,a5,0x6
    800049c4:	00022717          	auipc	a4,0x22
    800049c8:	05470713          	addi	a4,a4,84 # 80026a18 <log>
    800049cc:	97ba                	add	a5,a5,a4
    800049ce:	0407a223          	sw	zero,68(a5)
  write_head(dev); // clear the log
    800049d2:	854a                	mv	a0,s2
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	e0c080e7          	jalr	-500(ra) # 800047e0 <write_head>
}
    800049dc:	70a2                	ld	ra,40(sp)
    800049de:	7402                	ld	s0,32(sp)
    800049e0:	64e2                	ld	s1,24(sp)
    800049e2:	6942                	ld	s2,16(sp)
    800049e4:	69a2                	ld	s3,8(sp)
    800049e6:	6a02                	ld	s4,0(sp)
    800049e8:	6145                	addi	sp,sp,48
    800049ea:	8082                	ret

00000000800049ec <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    800049ec:	7139                	addi	sp,sp,-64
    800049ee:	fc06                	sd	ra,56(sp)
    800049f0:	f822                	sd	s0,48(sp)
    800049f2:	f426                	sd	s1,40(sp)
    800049f4:	f04a                	sd	s2,32(sp)
    800049f6:	ec4e                	sd	s3,24(sp)
    800049f8:	e852                	sd	s4,16(sp)
    800049fa:	e456                	sd	s5,8(sp)
    800049fc:	0080                	addi	s0,sp,64
    800049fe:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80004a00:	00151913          	slli	s2,a0,0x1
    80004a04:	992a                	add	s2,s2,a0
    80004a06:	00691793          	slli	a5,s2,0x6
    80004a0a:	00022917          	auipc	s2,0x22
    80004a0e:	00e90913          	addi	s2,s2,14 # 80026a18 <log>
    80004a12:	993e                	add	s2,s2,a5
    80004a14:	854a                	mv	a0,s2
    80004a16:	ffffc097          	auipc	ra,0xffffc
    80004a1a:	2a4080e7          	jalr	676(ra) # 80000cba <acquire>
  while(1){
    if(log[dev].committing){
    80004a1e:	00022997          	auipc	s3,0x22
    80004a22:	ffa98993          	addi	s3,s3,-6 # 80026a18 <log>
    80004a26:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004a28:	4a79                	li	s4,30
    80004a2a:	a039                	j	80004a38 <begin_op+0x4c>
      sleep(&log, &log[dev].lock);
    80004a2c:	85ca                	mv	a1,s2
    80004a2e:	854e                	mv	a0,s3
    80004a30:	ffffe097          	auipc	ra,0xffffe
    80004a34:	f02080e7          	jalr	-254(ra) # 80002932 <sleep>
    if(log[dev].committing){
    80004a38:	5cdc                	lw	a5,60(s1)
    80004a3a:	fbed                	bnez	a5,80004a2c <begin_op+0x40>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004a3c:	5c9c                	lw	a5,56(s1)
    80004a3e:	0017871b          	addiw	a4,a5,1
    80004a42:	0007069b          	sext.w	a3,a4
    80004a46:	0027179b          	slliw	a5,a4,0x2
    80004a4a:	9fb9                	addw	a5,a5,a4
    80004a4c:	0017979b          	slliw	a5,a5,0x1
    80004a50:	40f8                	lw	a4,68(s1)
    80004a52:	9fb9                	addw	a5,a5,a4
    80004a54:	00fa5963          	ble	a5,s4,80004a66 <begin_op+0x7a>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    80004a58:	85ca                	mv	a1,s2
    80004a5a:	854e                	mv	a0,s3
    80004a5c:	ffffe097          	auipc	ra,0xffffe
    80004a60:	ed6080e7          	jalr	-298(ra) # 80002932 <sleep>
    80004a64:	bfd1                	j	80004a38 <begin_op+0x4c>
    } else {
      log[dev].outstanding += 1;
    80004a66:	001a9793          	slli	a5,s5,0x1
    80004a6a:	9abe                	add	s5,s5,a5
    80004a6c:	0a9a                	slli	s5,s5,0x6
    80004a6e:	00022797          	auipc	a5,0x22
    80004a72:	faa78793          	addi	a5,a5,-86 # 80026a18 <log>
    80004a76:	9abe                	add	s5,s5,a5
    80004a78:	02daac23          	sw	a3,56(s5)
      release(&log[dev].lock);
    80004a7c:	854a                	mv	a0,s2
    80004a7e:	ffffc097          	auipc	ra,0xffffc
    80004a82:	488080e7          	jalr	1160(ra) # 80000f06 <release>
      break;
    }
  }
}
    80004a86:	70e2                	ld	ra,56(sp)
    80004a88:	7442                	ld	s0,48(sp)
    80004a8a:	74a2                	ld	s1,40(sp)
    80004a8c:	7902                	ld	s2,32(sp)
    80004a8e:	69e2                	ld	s3,24(sp)
    80004a90:	6a42                	ld	s4,16(sp)
    80004a92:	6aa2                	ld	s5,8(sp)
    80004a94:	6121                	addi	sp,sp,64
    80004a96:	8082                	ret

0000000080004a98 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    80004a98:	715d                	addi	sp,sp,-80
    80004a9a:	e486                	sd	ra,72(sp)
    80004a9c:	e0a2                	sd	s0,64(sp)
    80004a9e:	fc26                	sd	s1,56(sp)
    80004aa0:	f84a                	sd	s2,48(sp)
    80004aa2:	f44e                	sd	s3,40(sp)
    80004aa4:	f052                	sd	s4,32(sp)
    80004aa6:	ec56                	sd	s5,24(sp)
    80004aa8:	e85a                	sd	s6,16(sp)
    80004aaa:	e45e                	sd	s7,8(sp)
    80004aac:	e062                	sd	s8,0(sp)
    80004aae:	0880                	addi	s0,sp,80
    80004ab0:	892a                	mv	s2,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    80004ab2:	00151493          	slli	s1,a0,0x1
    80004ab6:	94aa                	add	s1,s1,a0
    80004ab8:	00649793          	slli	a5,s1,0x6
    80004abc:	00022497          	auipc	s1,0x22
    80004ac0:	f5c48493          	addi	s1,s1,-164 # 80026a18 <log>
    80004ac4:	94be                	add	s1,s1,a5
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	ffffc097          	auipc	ra,0xffffc
    80004acc:	1f2080e7          	jalr	498(ra) # 80000cba <acquire>
  log[dev].outstanding -= 1;
    80004ad0:	5c9c                	lw	a5,56(s1)
    80004ad2:	37fd                	addiw	a5,a5,-1
    80004ad4:	0007899b          	sext.w	s3,a5
    80004ad8:	dc9c                	sw	a5,56(s1)
  if(log[dev].committing)
    80004ada:	5cdc                	lw	a5,60(s1)
    80004adc:	e3b5                	bnez	a5,80004b40 <end_op+0xa8>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004ade:	06099963          	bnez	s3,80004b50 <end_op+0xb8>
    do_commit = 1;
    log[dev].committing = 1;
    80004ae2:	00191793          	slli	a5,s2,0x1
    80004ae6:	97ca                	add	a5,a5,s2
    80004ae8:	079a                	slli	a5,a5,0x6
    80004aea:	00022a17          	auipc	s4,0x22
    80004aee:	f2ea0a13          	addi	s4,s4,-210 # 80026a18 <log>
    80004af2:	9a3e                	add	s4,s4,a5
    80004af4:	4785                	li	a5,1
    80004af6:	02fa2e23          	sw	a5,60(s4)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    80004afa:	8526                	mv	a0,s1
    80004afc:	ffffc097          	auipc	ra,0xffffc
    80004b00:	40a080e7          	jalr	1034(ra) # 80000f06 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    80004b04:	044a2783          	lw	a5,68(s4)
    80004b08:	06f04d63          	bgtz	a5,80004b82 <end_op+0xea>
    acquire(&log[dev].lock);
    80004b0c:	8526                	mv	a0,s1
    80004b0e:	ffffc097          	auipc	ra,0xffffc
    80004b12:	1ac080e7          	jalr	428(ra) # 80000cba <acquire>
    log[dev].committing = 0;
    80004b16:	00022517          	auipc	a0,0x22
    80004b1a:	f0250513          	addi	a0,a0,-254 # 80026a18 <log>
    80004b1e:	00191793          	slli	a5,s2,0x1
    80004b22:	993e                	add	s2,s2,a5
    80004b24:	091a                	slli	s2,s2,0x6
    80004b26:	992a                	add	s2,s2,a0
    80004b28:	02092e23          	sw	zero,60(s2)
    wakeup(&log);
    80004b2c:	ffffe097          	auipc	ra,0xffffe
    80004b30:	f8c080e7          	jalr	-116(ra) # 80002ab8 <wakeup>
    release(&log[dev].lock);
    80004b34:	8526                	mv	a0,s1
    80004b36:	ffffc097          	auipc	ra,0xffffc
    80004b3a:	3d0080e7          	jalr	976(ra) # 80000f06 <release>
}
    80004b3e:	a035                	j	80004b6a <end_op+0xd2>
    panic("log[dev].committing");
    80004b40:	00004517          	auipc	a0,0x4
    80004b44:	03850513          	addi	a0,a0,56 # 80008b78 <userret+0xae8>
    80004b48:	ffffc097          	auipc	ra,0xffffc
    80004b4c:	c3c080e7          	jalr	-964(ra) # 80000784 <panic>
    wakeup(&log);
    80004b50:	00022517          	auipc	a0,0x22
    80004b54:	ec850513          	addi	a0,a0,-312 # 80026a18 <log>
    80004b58:	ffffe097          	auipc	ra,0xffffe
    80004b5c:	f60080e7          	jalr	-160(ra) # 80002ab8 <wakeup>
  release(&log[dev].lock);
    80004b60:	8526                	mv	a0,s1
    80004b62:	ffffc097          	auipc	ra,0xffffc
    80004b66:	3a4080e7          	jalr	932(ra) # 80000f06 <release>
}
    80004b6a:	60a6                	ld	ra,72(sp)
    80004b6c:	6406                	ld	s0,64(sp)
    80004b6e:	74e2                	ld	s1,56(sp)
    80004b70:	7942                	ld	s2,48(sp)
    80004b72:	79a2                	ld	s3,40(sp)
    80004b74:	7a02                	ld	s4,32(sp)
    80004b76:	6ae2                	ld	s5,24(sp)
    80004b78:	6b42                	ld	s6,16(sp)
    80004b7a:	6ba2                	ld	s7,8(sp)
    80004b7c:	6c02                	ld	s8,0(sp)
    80004b7e:	6161                	addi	sp,sp,80
    80004b80:	8082                	ret
    80004b82:	8aa6                	mv	s5,s1
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80004b84:	00090c1b          	sext.w	s8,s2
    80004b88:	00191b93          	slli	s7,s2,0x1
    80004b8c:	9bca                	add	s7,s7,s2
    80004b8e:	006b9793          	slli	a5,s7,0x6
    80004b92:	00022b97          	auipc	s7,0x22
    80004b96:	e86b8b93          	addi	s7,s7,-378 # 80026a18 <log>
    80004b9a:	9bbe                	add	s7,s7,a5
    80004b9c:	030ba583          	lw	a1,48(s7)
    80004ba0:	013585bb          	addw	a1,a1,s3
    80004ba4:	2585                	addiw	a1,a1,1
    80004ba6:	8562                	mv	a0,s8
    80004ba8:	fffff097          	auipc	ra,0xfffff
    80004bac:	c1e080e7          	jalr	-994(ra) # 800037c6 <bread>
    80004bb0:	8a2a                	mv	s4,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80004bb2:	048aa583          	lw	a1,72(s5)
    80004bb6:	8562                	mv	a0,s8
    80004bb8:	fffff097          	auipc	ra,0xfffff
    80004bbc:	c0e080e7          	jalr	-1010(ra) # 800037c6 <bread>
    80004bc0:	8b2a                	mv	s6,a0
    memmove(to->data, from->data, BSIZE);
    80004bc2:	40000613          	li	a2,1024
    80004bc6:	07050593          	addi	a1,a0,112
    80004bca:	070a0513          	addi	a0,s4,112
    80004bce:	ffffc097          	auipc	ra,0xffffc
    80004bd2:	5cc080e7          	jalr	1484(ra) # 8000119a <memmove>
    bwrite(to);  // write the log
    80004bd6:	8552                	mv	a0,s4
    80004bd8:	fffff097          	auipc	ra,0xfffff
    80004bdc:	cf4080e7          	jalr	-780(ra) # 800038cc <bwrite>
    brelse(from);
    80004be0:	855a                	mv	a0,s6
    80004be2:	fffff097          	auipc	ra,0xfffff
    80004be6:	d2a080e7          	jalr	-726(ra) # 8000390c <brelse>
    brelse(to);
    80004bea:	8552                	mv	a0,s4
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	d20080e7          	jalr	-736(ra) # 8000390c <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004bf4:	2985                	addiw	s3,s3,1
    80004bf6:	0a91                	addi	s5,s5,4
    80004bf8:	044ba783          	lw	a5,68(s7)
    80004bfc:	faf9c0e3          	blt	s3,a5,80004b9c <end_op+0x104>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    80004c00:	854a                	mv	a0,s2
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	bde080e7          	jalr	-1058(ra) # 800047e0 <write_head>
    install_trans(dev); // Now install writes to home locations
    80004c0a:	854a                	mv	a0,s2
    80004c0c:	00000097          	auipc	ra,0x0
    80004c10:	c4e080e7          	jalr	-946(ra) # 8000485a <install_trans>
    log[dev].lh.n = 0;
    80004c14:	00191793          	slli	a5,s2,0x1
    80004c18:	97ca                	add	a5,a5,s2
    80004c1a:	079a                	slli	a5,a5,0x6
    80004c1c:	00022717          	auipc	a4,0x22
    80004c20:	dfc70713          	addi	a4,a4,-516 # 80026a18 <log>
    80004c24:	97ba                	add	a5,a5,a4
    80004c26:	0407a223          	sw	zero,68(a5)
    write_head(dev);    // Erase the transaction from the log
    80004c2a:	854a                	mv	a0,s2
    80004c2c:	00000097          	auipc	ra,0x0
    80004c30:	bb4080e7          	jalr	-1100(ra) # 800047e0 <write_head>
    80004c34:	bde1                	j	80004b0c <end_op+0x74>

0000000080004c36 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004c36:	7179                	addi	sp,sp,-48
    80004c38:	f406                	sd	ra,40(sp)
    80004c3a:	f022                	sd	s0,32(sp)
    80004c3c:	ec26                	sd	s1,24(sp)
    80004c3e:	e84a                	sd	s2,16(sp)
    80004c40:	e44e                	sd	s3,8(sp)
    80004c42:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004c44:	4504                	lw	s1,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004c46:	00149793          	slli	a5,s1,0x1
    80004c4a:	97a6                	add	a5,a5,s1
    80004c4c:	079a                	slli	a5,a5,0x6
    80004c4e:	00022717          	auipc	a4,0x22
    80004c52:	dca70713          	addi	a4,a4,-566 # 80026a18 <log>
    80004c56:	97ba                	add	a5,a5,a4
    80004c58:	43f4                	lw	a3,68(a5)
    80004c5a:	47f5                	li	a5,29
    80004c5c:	0ad7c363          	blt	a5,a3,80004d02 <log_write+0xcc>
    80004c60:	89aa                	mv	s3,a0
    80004c62:	00149793          	slli	a5,s1,0x1
    80004c66:	97a6                	add	a5,a5,s1
    80004c68:	079a                	slli	a5,a5,0x6
    80004c6a:	97ba                	add	a5,a5,a4
    80004c6c:	5bdc                	lw	a5,52(a5)
    80004c6e:	37fd                	addiw	a5,a5,-1
    80004c70:	08f6d963          	ble	a5,a3,80004d02 <log_write+0xcc>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004c74:	00149793          	slli	a5,s1,0x1
    80004c78:	97a6                	add	a5,a5,s1
    80004c7a:	079a                	slli	a5,a5,0x6
    80004c7c:	00022717          	auipc	a4,0x22
    80004c80:	d9c70713          	addi	a4,a4,-612 # 80026a18 <log>
    80004c84:	97ba                	add	a5,a5,a4
    80004c86:	5f9c                	lw	a5,56(a5)
    80004c88:	08f05563          	blez	a5,80004d12 <log_write+0xdc>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004c8c:	00149913          	slli	s2,s1,0x1
    80004c90:	9926                	add	s2,s2,s1
    80004c92:	00691793          	slli	a5,s2,0x6
    80004c96:	00022917          	auipc	s2,0x22
    80004c9a:	d8290913          	addi	s2,s2,-638 # 80026a18 <log>
    80004c9e:	993e                	add	s2,s2,a5
    80004ca0:	854a                	mv	a0,s2
    80004ca2:	ffffc097          	auipc	ra,0xffffc
    80004ca6:	018080e7          	jalr	24(ra) # 80000cba <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004caa:	04492603          	lw	a2,68(s2)
    80004cae:	06c05a63          	blez	a2,80004d22 <log_write+0xec>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004cb2:	00c9a583          	lw	a1,12(s3)
    80004cb6:	04892783          	lw	a5,72(s2)
    80004cba:	08b78263          	beq	a5,a1,80004d3e <log_write+0x108>
    80004cbe:	874a                	mv	a4,s2
  for (i = 0; i < log[dev].lh.n; i++) {
    80004cc0:	4781                	li	a5,0
    80004cc2:	2785                	addiw	a5,a5,1
    80004cc4:	06c78f63          	beq	a5,a2,80004d42 <log_write+0x10c>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004cc8:	4774                	lw	a3,76(a4)
    80004cca:	0711                	addi	a4,a4,4
    80004ccc:	feb69be3          	bne	a3,a1,80004cc2 <log_write+0x8c>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004cd0:	00149713          	slli	a4,s1,0x1
    80004cd4:	94ba                	add	s1,s1,a4
    80004cd6:	0492                	slli	s1,s1,0x4
    80004cd8:	97a6                	add	a5,a5,s1
    80004cda:	07c1                	addi	a5,a5,16
    80004cdc:	078a                	slli	a5,a5,0x2
    80004cde:	00022717          	auipc	a4,0x22
    80004ce2:	d3a70713          	addi	a4,a4,-710 # 80026a18 <log>
    80004ce6:	97ba                	add	a5,a5,a4
    80004ce8:	c78c                	sw	a1,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    log[dev].lh.n++;
  }
  release(&log[dev].lock);
    80004cea:	854a                	mv	a0,s2
    80004cec:	ffffc097          	auipc	ra,0xffffc
    80004cf0:	21a080e7          	jalr	538(ra) # 80000f06 <release>
}
    80004cf4:	70a2                	ld	ra,40(sp)
    80004cf6:	7402                	ld	s0,32(sp)
    80004cf8:	64e2                	ld	s1,24(sp)
    80004cfa:	6942                	ld	s2,16(sp)
    80004cfc:	69a2                	ld	s3,8(sp)
    80004cfe:	6145                	addi	sp,sp,48
    80004d00:	8082                	ret
    panic("too big a transaction");
    80004d02:	00004517          	auipc	a0,0x4
    80004d06:	e8e50513          	addi	a0,a0,-370 # 80008b90 <userret+0xb00>
    80004d0a:	ffffc097          	auipc	ra,0xffffc
    80004d0e:	a7a080e7          	jalr	-1414(ra) # 80000784 <panic>
    panic("log_write outside of trans");
    80004d12:	00004517          	auipc	a0,0x4
    80004d16:	e9650513          	addi	a0,a0,-362 # 80008ba8 <userret+0xb18>
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	a6a080e7          	jalr	-1430(ra) # 80000784 <panic>
  log[dev].lh.block[i] = b->blockno;
    80004d22:	00149793          	slli	a5,s1,0x1
    80004d26:	97a6                	add	a5,a5,s1
    80004d28:	079a                	slli	a5,a5,0x6
    80004d2a:	00022717          	auipc	a4,0x22
    80004d2e:	cee70713          	addi	a4,a4,-786 # 80026a18 <log>
    80004d32:	97ba                	add	a5,a5,a4
    80004d34:	00c9a703          	lw	a4,12(s3)
    80004d38:	c7b8                	sw	a4,72(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004d3a:	fa45                	bnez	a2,80004cea <log_write+0xb4>
    80004d3c:	a015                	j	80004d60 <log_write+0x12a>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004d3e:	4781                	li	a5,0
    80004d40:	bf41                	j	80004cd0 <log_write+0x9a>
  log[dev].lh.block[i] = b->blockno;
    80004d42:	00149793          	slli	a5,s1,0x1
    80004d46:	97a6                	add	a5,a5,s1
    80004d48:	0792                	slli	a5,a5,0x4
    80004d4a:	97b2                	add	a5,a5,a2
    80004d4c:	07c1                	addi	a5,a5,16
    80004d4e:	078a                	slli	a5,a5,0x2
    80004d50:	00022717          	auipc	a4,0x22
    80004d54:	cc870713          	addi	a4,a4,-824 # 80026a18 <log>
    80004d58:	97ba                	add	a5,a5,a4
    80004d5a:	00c9a703          	lw	a4,12(s3)
    80004d5e:	c798                	sw	a4,8(a5)
    bpin(b);
    80004d60:	854e                	mv	a0,s3
    80004d62:	fffff097          	auipc	ra,0xfffff
    80004d66:	c48080e7          	jalr	-952(ra) # 800039aa <bpin>
    log[dev].lh.n++;
    80004d6a:	00022697          	auipc	a3,0x22
    80004d6e:	cae68693          	addi	a3,a3,-850 # 80026a18 <log>
    80004d72:	00149793          	slli	a5,s1,0x1
    80004d76:	00978733          	add	a4,a5,s1
    80004d7a:	071a                	slli	a4,a4,0x6
    80004d7c:	9736                	add	a4,a4,a3
    80004d7e:	437c                	lw	a5,68(a4)
    80004d80:	2785                	addiw	a5,a5,1
    80004d82:	c37c                	sw	a5,68(a4)
    80004d84:	b79d                	j	80004cea <log_write+0xb4>

0000000080004d86 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004d86:	1101                	addi	sp,sp,-32
    80004d88:	ec06                	sd	ra,24(sp)
    80004d8a:	e822                	sd	s0,16(sp)
    80004d8c:	e426                	sd	s1,8(sp)
    80004d8e:	e04a                	sd	s2,0(sp)
    80004d90:	1000                	addi	s0,sp,32
    80004d92:	84aa                	mv	s1,a0
    80004d94:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004d96:	00004597          	auipc	a1,0x4
    80004d9a:	e3258593          	addi	a1,a1,-462 # 80008bc8 <userret+0xb38>
    80004d9e:	0521                	addi	a0,a0,8
    80004da0:	ffffc097          	auipc	ra,0xffffc
    80004da4:	dac080e7          	jalr	-596(ra) # 80000b4c <initlock>
  lk->name = name;
    80004da8:	0324bc23          	sd	s2,56(s1)
  lk->locked = 0;
    80004dac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004db0:	0404a023          	sw	zero,64(s1)
}
    80004db4:	60e2                	ld	ra,24(sp)
    80004db6:	6442                	ld	s0,16(sp)
    80004db8:	64a2                	ld	s1,8(sp)
    80004dba:	6902                	ld	s2,0(sp)
    80004dbc:	6105                	addi	sp,sp,32
    80004dbe:	8082                	ret

0000000080004dc0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004dc0:	1101                	addi	sp,sp,-32
    80004dc2:	ec06                	sd	ra,24(sp)
    80004dc4:	e822                	sd	s0,16(sp)
    80004dc6:	e426                	sd	s1,8(sp)
    80004dc8:	e04a                	sd	s2,0(sp)
    80004dca:	1000                	addi	s0,sp,32
    80004dcc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004dce:	00850913          	addi	s2,a0,8
    80004dd2:	854a                	mv	a0,s2
    80004dd4:	ffffc097          	auipc	ra,0xffffc
    80004dd8:	ee6080e7          	jalr	-282(ra) # 80000cba <acquire>
  while (lk->locked) {
    80004ddc:	409c                	lw	a5,0(s1)
    80004dde:	cb89                	beqz	a5,80004df0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004de0:	85ca                	mv	a1,s2
    80004de2:	8526                	mv	a0,s1
    80004de4:	ffffe097          	auipc	ra,0xffffe
    80004de8:	b4e080e7          	jalr	-1202(ra) # 80002932 <sleep>
  while (lk->locked) {
    80004dec:	409c                	lw	a5,0(s1)
    80004dee:	fbed                	bnez	a5,80004de0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004df0:	4785                	li	a5,1
    80004df2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004df4:	ffffd097          	auipc	ra,0xffffd
    80004df8:	24c080e7          	jalr	588(ra) # 80002040 <myproc>
    80004dfc:	493c                	lw	a5,80(a0)
    80004dfe:	c0bc                	sw	a5,64(s1)
  release(&lk->lk);
    80004e00:	854a                	mv	a0,s2
    80004e02:	ffffc097          	auipc	ra,0xffffc
    80004e06:	104080e7          	jalr	260(ra) # 80000f06 <release>
}
    80004e0a:	60e2                	ld	ra,24(sp)
    80004e0c:	6442                	ld	s0,16(sp)
    80004e0e:	64a2                	ld	s1,8(sp)
    80004e10:	6902                	ld	s2,0(sp)
    80004e12:	6105                	addi	sp,sp,32
    80004e14:	8082                	ret

0000000080004e16 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004e16:	1101                	addi	sp,sp,-32
    80004e18:	ec06                	sd	ra,24(sp)
    80004e1a:	e822                	sd	s0,16(sp)
    80004e1c:	e426                	sd	s1,8(sp)
    80004e1e:	e04a                	sd	s2,0(sp)
    80004e20:	1000                	addi	s0,sp,32
    80004e22:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004e24:	00850913          	addi	s2,a0,8
    80004e28:	854a                	mv	a0,s2
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	e90080e7          	jalr	-368(ra) # 80000cba <acquire>
  lk->locked = 0;
    80004e32:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004e36:	0404a023          	sw	zero,64(s1)
  wakeup(lk);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	ffffe097          	auipc	ra,0xffffe
    80004e40:	c7c080e7          	jalr	-900(ra) # 80002ab8 <wakeup>
  release(&lk->lk);
    80004e44:	854a                	mv	a0,s2
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	0c0080e7          	jalr	192(ra) # 80000f06 <release>
}
    80004e4e:	60e2                	ld	ra,24(sp)
    80004e50:	6442                	ld	s0,16(sp)
    80004e52:	64a2                	ld	s1,8(sp)
    80004e54:	6902                	ld	s2,0(sp)
    80004e56:	6105                	addi	sp,sp,32
    80004e58:	8082                	ret

0000000080004e5a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004e5a:	7179                	addi	sp,sp,-48
    80004e5c:	f406                	sd	ra,40(sp)
    80004e5e:	f022                	sd	s0,32(sp)
    80004e60:	ec26                	sd	s1,24(sp)
    80004e62:	e84a                	sd	s2,16(sp)
    80004e64:	e44e                	sd	s3,8(sp)
    80004e66:	1800                	addi	s0,sp,48
    80004e68:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004e6a:	00850913          	addi	s2,a0,8
    80004e6e:	854a                	mv	a0,s2
    80004e70:	ffffc097          	auipc	ra,0xffffc
    80004e74:	e4a080e7          	jalr	-438(ra) # 80000cba <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e78:	409c                	lw	a5,0(s1)
    80004e7a:	ef99                	bnez	a5,80004e98 <holdingsleep+0x3e>
    80004e7c:	4481                	li	s1,0
  release(&lk->lk);
    80004e7e:	854a                	mv	a0,s2
    80004e80:	ffffc097          	auipc	ra,0xffffc
    80004e84:	086080e7          	jalr	134(ra) # 80000f06 <release>
  return r;
}
    80004e88:	8526                	mv	a0,s1
    80004e8a:	70a2                	ld	ra,40(sp)
    80004e8c:	7402                	ld	s0,32(sp)
    80004e8e:	64e2                	ld	s1,24(sp)
    80004e90:	6942                	ld	s2,16(sp)
    80004e92:	69a2                	ld	s3,8(sp)
    80004e94:	6145                	addi	sp,sp,48
    80004e96:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e98:	0404a983          	lw	s3,64(s1)
    80004e9c:	ffffd097          	auipc	ra,0xffffd
    80004ea0:	1a4080e7          	jalr	420(ra) # 80002040 <myproc>
    80004ea4:	4924                	lw	s1,80(a0)
    80004ea6:	413484b3          	sub	s1,s1,s3
    80004eaa:	0014b493          	seqz	s1,s1
    80004eae:	bfc1                	j	80004e7e <holdingsleep+0x24>

0000000080004eb0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004eb0:	1141                	addi	sp,sp,-16
    80004eb2:	e406                	sd	ra,8(sp)
    80004eb4:	e022                	sd	s0,0(sp)
    80004eb6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004eb8:	00004597          	auipc	a1,0x4
    80004ebc:	d2058593          	addi	a1,a1,-736 # 80008bd8 <userret+0xb48>
    80004ec0:	00022517          	auipc	a0,0x22
    80004ec4:	d7850513          	addi	a0,a0,-648 # 80026c38 <ftable>
    80004ec8:	ffffc097          	auipc	ra,0xffffc
    80004ecc:	c84080e7          	jalr	-892(ra) # 80000b4c <initlock>
}
    80004ed0:	60a2                	ld	ra,8(sp)
    80004ed2:	6402                	ld	s0,0(sp)
    80004ed4:	0141                	addi	sp,sp,16
    80004ed6:	8082                	ret

0000000080004ed8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004ed8:	1101                	addi	sp,sp,-32
    80004eda:	ec06                	sd	ra,24(sp)
    80004edc:	e822                	sd	s0,16(sp)
    80004ede:	e426                	sd	s1,8(sp)
    80004ee0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ee2:	00022517          	auipc	a0,0x22
    80004ee6:	d5650513          	addi	a0,a0,-682 # 80026c38 <ftable>
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	dd0080e7          	jalr	-560(ra) # 80000cba <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    80004ef2:	00022797          	auipc	a5,0x22
    80004ef6:	d4678793          	addi	a5,a5,-698 # 80026c38 <ftable>
    80004efa:	5bdc                	lw	a5,52(a5)
    80004efc:	cb8d                	beqz	a5,80004f2e <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004efe:	00022497          	auipc	s1,0x22
    80004f02:	dda48493          	addi	s1,s1,-550 # 80026cd8 <ftable+0xa0>
    80004f06:	00025717          	auipc	a4,0x25
    80004f0a:	92270713          	addi	a4,a4,-1758 # 80029828 <ftable+0x2bf0>
    if(f->ref == 0){
    80004f0e:	40dc                	lw	a5,4(s1)
    80004f10:	c39d                	beqz	a5,80004f36 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f12:	07048493          	addi	s1,s1,112
    80004f16:	fee49ce3          	bne	s1,a4,80004f0e <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004f1a:	00022517          	auipc	a0,0x22
    80004f1e:	d1e50513          	addi	a0,a0,-738 # 80026c38 <ftable>
    80004f22:	ffffc097          	auipc	ra,0xffffc
    80004f26:	fe4080e7          	jalr	-28(ra) # 80000f06 <release>
  return 0;
    80004f2a:	4481                	li	s1,0
    80004f2c:	a839                	j	80004f4a <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004f2e:	00022497          	auipc	s1,0x22
    80004f32:	d3a48493          	addi	s1,s1,-710 # 80026c68 <ftable+0x30>
      f->ref = 1;
    80004f36:	4785                	li	a5,1
    80004f38:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004f3a:	00022517          	auipc	a0,0x22
    80004f3e:	cfe50513          	addi	a0,a0,-770 # 80026c38 <ftable>
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	fc4080e7          	jalr	-60(ra) # 80000f06 <release>
}
    80004f4a:	8526                	mv	a0,s1
    80004f4c:	60e2                	ld	ra,24(sp)
    80004f4e:	6442                	ld	s0,16(sp)
    80004f50:	64a2                	ld	s1,8(sp)
    80004f52:	6105                	addi	sp,sp,32
    80004f54:	8082                	ret

0000000080004f56 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004f56:	1101                	addi	sp,sp,-32
    80004f58:	ec06                	sd	ra,24(sp)
    80004f5a:	e822                	sd	s0,16(sp)
    80004f5c:	e426                	sd	s1,8(sp)
    80004f5e:	1000                	addi	s0,sp,32
    80004f60:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004f62:	00022517          	auipc	a0,0x22
    80004f66:	cd650513          	addi	a0,a0,-810 # 80026c38 <ftable>
    80004f6a:	ffffc097          	auipc	ra,0xffffc
    80004f6e:	d50080e7          	jalr	-688(ra) # 80000cba <acquire>
  if(f->ref < 1)
    80004f72:	40dc                	lw	a5,4(s1)
    80004f74:	02f05263          	blez	a5,80004f98 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004f78:	2785                	addiw	a5,a5,1
    80004f7a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004f7c:	00022517          	auipc	a0,0x22
    80004f80:	cbc50513          	addi	a0,a0,-836 # 80026c38 <ftable>
    80004f84:	ffffc097          	auipc	ra,0xffffc
    80004f88:	f82080e7          	jalr	-126(ra) # 80000f06 <release>
  return f;
}
    80004f8c:	8526                	mv	a0,s1
    80004f8e:	60e2                	ld	ra,24(sp)
    80004f90:	6442                	ld	s0,16(sp)
    80004f92:	64a2                	ld	s1,8(sp)
    80004f94:	6105                	addi	sp,sp,32
    80004f96:	8082                	ret
    panic("filedup");
    80004f98:	00004517          	auipc	a0,0x4
    80004f9c:	c4850513          	addi	a0,a0,-952 # 80008be0 <userret+0xb50>
    80004fa0:	ffffb097          	auipc	ra,0xffffb
    80004fa4:	7e4080e7          	jalr	2020(ra) # 80000784 <panic>

0000000080004fa8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004fa8:	7139                	addi	sp,sp,-64
    80004faa:	fc06                	sd	ra,56(sp)
    80004fac:	f822                	sd	s0,48(sp)
    80004fae:	f426                	sd	s1,40(sp)
    80004fb0:	f04a                	sd	s2,32(sp)
    80004fb2:	ec4e                	sd	s3,24(sp)
    80004fb4:	e852                	sd	s4,16(sp)
    80004fb6:	e456                	sd	s5,8(sp)
    80004fb8:	0080                	addi	s0,sp,64
    80004fba:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004fbc:	00022517          	auipc	a0,0x22
    80004fc0:	c7c50513          	addi	a0,a0,-900 # 80026c38 <ftable>
    80004fc4:	ffffc097          	auipc	ra,0xffffc
    80004fc8:	cf6080e7          	jalr	-778(ra) # 80000cba <acquire>
  if(f->ref < 1)
    80004fcc:	40dc                	lw	a5,4(s1)
    80004fce:	06f05563          	blez	a5,80005038 <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004fd2:	37fd                	addiw	a5,a5,-1
    80004fd4:	0007871b          	sext.w	a4,a5
    80004fd8:	c0dc                	sw	a5,4(s1)
    80004fda:	06e04763          	bgtz	a4,80005048 <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004fde:	0004a903          	lw	s2,0(s1)
    80004fe2:	0094ca83          	lbu	s5,9(s1)
    80004fe6:	0104ba03          	ld	s4,16(s1)
    80004fea:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004fee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ff2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ff6:	00022517          	auipc	a0,0x22
    80004ffa:	c4250513          	addi	a0,a0,-958 # 80026c38 <ftable>
    80004ffe:	ffffc097          	auipc	ra,0xffffc
    80005002:	f08080e7          	jalr	-248(ra) # 80000f06 <release>

  if(ff.type == FD_PIPE){
    80005006:	4785                	li	a5,1
    80005008:	06f90163          	beq	s2,a5,8000506a <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000500c:	3979                	addiw	s2,s2,-2
    8000500e:	4785                	li	a5,1
    80005010:	0527e463          	bltu	a5,s2,80005058 <fileclose+0xb0>
    begin_op(ff.ip->dev);
    80005014:	0009a503          	lw	a0,0(s3)
    80005018:	00000097          	auipc	ra,0x0
    8000501c:	9d4080e7          	jalr	-1580(ra) # 800049ec <begin_op>
    iput(ff.ip);
    80005020:	854e                	mv	a0,s3
    80005022:	fffff097          	auipc	ra,0xfffff
    80005026:	100080e7          	jalr	256(ra) # 80004122 <iput>
    end_op(ff.ip->dev);
    8000502a:	0009a503          	lw	a0,0(s3)
    8000502e:	00000097          	auipc	ra,0x0
    80005032:	a6a080e7          	jalr	-1430(ra) # 80004a98 <end_op>
    80005036:	a00d                	j	80005058 <fileclose+0xb0>
    panic("fileclose");
    80005038:	00004517          	auipc	a0,0x4
    8000503c:	bb050513          	addi	a0,a0,-1104 # 80008be8 <userret+0xb58>
    80005040:	ffffb097          	auipc	ra,0xffffb
    80005044:	744080e7          	jalr	1860(ra) # 80000784 <panic>
    release(&ftable.lock);
    80005048:	00022517          	auipc	a0,0x22
    8000504c:	bf050513          	addi	a0,a0,-1040 # 80026c38 <ftable>
    80005050:	ffffc097          	auipc	ra,0xffffc
    80005054:	eb6080e7          	jalr	-330(ra) # 80000f06 <release>
  }
}
    80005058:	70e2                	ld	ra,56(sp)
    8000505a:	7442                	ld	s0,48(sp)
    8000505c:	74a2                	ld	s1,40(sp)
    8000505e:	7902                	ld	s2,32(sp)
    80005060:	69e2                	ld	s3,24(sp)
    80005062:	6a42                	ld	s4,16(sp)
    80005064:	6aa2                	ld	s5,8(sp)
    80005066:	6121                	addi	sp,sp,64
    80005068:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000506a:	85d6                	mv	a1,s5
    8000506c:	8552                	mv	a0,s4
    8000506e:	00000097          	auipc	ra,0x0
    80005072:	376080e7          	jalr	886(ra) # 800053e4 <pipeclose>
    80005076:	b7cd                	j	80005058 <fileclose+0xb0>

0000000080005078 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005078:	715d                	addi	sp,sp,-80
    8000507a:	e486                	sd	ra,72(sp)
    8000507c:	e0a2                	sd	s0,64(sp)
    8000507e:	fc26                	sd	s1,56(sp)
    80005080:	f84a                	sd	s2,48(sp)
    80005082:	f44e                	sd	s3,40(sp)
    80005084:	0880                	addi	s0,sp,80
    80005086:	84aa                	mv	s1,a0
    80005088:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000508a:	ffffd097          	auipc	ra,0xffffd
    8000508e:	fb6080e7          	jalr	-74(ra) # 80002040 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005092:	409c                	lw	a5,0(s1)
    80005094:	37f9                	addiw	a5,a5,-2
    80005096:	4705                	li	a4,1
    80005098:	04f76763          	bltu	a4,a5,800050e6 <filestat+0x6e>
    8000509c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000509e:	6c88                	ld	a0,24(s1)
    800050a0:	fffff097          	auipc	ra,0xfffff
    800050a4:	f72080e7          	jalr	-142(ra) # 80004012 <ilock>
    stati(f->ip, &st);
    800050a8:	fb840593          	addi	a1,s0,-72
    800050ac:	6c88                	ld	a0,24(s1)
    800050ae:	fffff097          	auipc	ra,0xfffff
    800050b2:	1cc080e7          	jalr	460(ra) # 8000427a <stati>
    iunlock(f->ip);
    800050b6:	6c88                	ld	a0,24(s1)
    800050b8:	fffff097          	auipc	ra,0xfffff
    800050bc:	01e080e7          	jalr	30(ra) # 800040d6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800050c0:	46e1                	li	a3,24
    800050c2:	fb840613          	addi	a2,s0,-72
    800050c6:	85ce                	mv	a1,s3
    800050c8:	06893503          	ld	a0,104(s2)
    800050cc:	ffffd097          	auipc	ra,0xffffd
    800050d0:	b52080e7          	jalr	-1198(ra) # 80001c1e <copyout>
    800050d4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800050d8:	60a6                	ld	ra,72(sp)
    800050da:	6406                	ld	s0,64(sp)
    800050dc:	74e2                	ld	s1,56(sp)
    800050de:	7942                	ld	s2,48(sp)
    800050e0:	79a2                	ld	s3,40(sp)
    800050e2:	6161                	addi	sp,sp,80
    800050e4:	8082                	ret
  return -1;
    800050e6:	557d                	li	a0,-1
    800050e8:	bfc5                	j	800050d8 <filestat+0x60>

00000000800050ea <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800050ea:	7179                	addi	sp,sp,-48
    800050ec:	f406                	sd	ra,40(sp)
    800050ee:	f022                	sd	s0,32(sp)
    800050f0:	ec26                	sd	s1,24(sp)
    800050f2:	e84a                	sd	s2,16(sp)
    800050f4:	e44e                	sd	s3,8(sp)
    800050f6:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800050f8:	00854783          	lbu	a5,8(a0)
    800050fc:	c7c5                	beqz	a5,800051a4 <fileread+0xba>
    800050fe:	89b2                	mv	s3,a2
    80005100:	892e                	mv	s2,a1
    80005102:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80005104:	411c                	lw	a5,0(a0)
    80005106:	4705                	li	a4,1
    80005108:	04e78963          	beq	a5,a4,8000515a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000510c:	470d                	li	a4,3
    8000510e:	04e78d63          	beq	a5,a4,80005168 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80005112:	4709                	li	a4,2
    80005114:	08e79063          	bne	a5,a4,80005194 <fileread+0xaa>
    ilock(f->ip);
    80005118:	6d08                	ld	a0,24(a0)
    8000511a:	fffff097          	auipc	ra,0xfffff
    8000511e:	ef8080e7          	jalr	-264(ra) # 80004012 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005122:	874e                	mv	a4,s3
    80005124:	5094                	lw	a3,32(s1)
    80005126:	864a                	mv	a2,s2
    80005128:	4585                	li	a1,1
    8000512a:	6c88                	ld	a0,24(s1)
    8000512c:	fffff097          	auipc	ra,0xfffff
    80005130:	178080e7          	jalr	376(ra) # 800042a4 <readi>
    80005134:	892a                	mv	s2,a0
    80005136:	00a05563          	blez	a0,80005140 <fileread+0x56>
      f->off += r;
    8000513a:	509c                	lw	a5,32(s1)
    8000513c:	9fa9                	addw	a5,a5,a0
    8000513e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005140:	6c88                	ld	a0,24(s1)
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	f94080e7          	jalr	-108(ra) # 800040d6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000514a:	854a                	mv	a0,s2
    8000514c:	70a2                	ld	ra,40(sp)
    8000514e:	7402                	ld	s0,32(sp)
    80005150:	64e2                	ld	s1,24(sp)
    80005152:	6942                	ld	s2,16(sp)
    80005154:	69a2                	ld	s3,8(sp)
    80005156:	6145                	addi	sp,sp,48
    80005158:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000515a:	6908                	ld	a0,16(a0)
    8000515c:	00000097          	auipc	ra,0x0
    80005160:	412080e7          	jalr	1042(ra) # 8000556e <piperead>
    80005164:	892a                	mv	s2,a0
    80005166:	b7d5                	j	8000514a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005168:	02451783          	lh	a5,36(a0)
    8000516c:	03079693          	slli	a3,a5,0x30
    80005170:	92c1                	srli	a3,a3,0x30
    80005172:	4725                	li	a4,9
    80005174:	02d76a63          	bltu	a4,a3,800051a8 <fileread+0xbe>
    80005178:	0792                	slli	a5,a5,0x4
    8000517a:	00022717          	auipc	a4,0x22
    8000517e:	a1e70713          	addi	a4,a4,-1506 # 80026b98 <devsw>
    80005182:	97ba                	add	a5,a5,a4
    80005184:	639c                	ld	a5,0(a5)
    80005186:	c39d                	beqz	a5,800051ac <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80005188:	86b2                	mv	a3,a2
    8000518a:	862e                	mv	a2,a1
    8000518c:	4585                	li	a1,1
    8000518e:	9782                	jalr	a5
    80005190:	892a                	mv	s2,a0
    80005192:	bf65                	j	8000514a <fileread+0x60>
    panic("fileread");
    80005194:	00004517          	auipc	a0,0x4
    80005198:	a6450513          	addi	a0,a0,-1436 # 80008bf8 <userret+0xb68>
    8000519c:	ffffb097          	auipc	ra,0xffffb
    800051a0:	5e8080e7          	jalr	1512(ra) # 80000784 <panic>
    return -1;
    800051a4:	597d                	li	s2,-1
    800051a6:	b755                	j	8000514a <fileread+0x60>
      return -1;
    800051a8:	597d                	li	s2,-1
    800051aa:	b745                	j	8000514a <fileread+0x60>
    800051ac:	597d                	li	s2,-1
    800051ae:	bf71                	j	8000514a <fileread+0x60>

00000000800051b0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800051b0:	00954783          	lbu	a5,9(a0)
    800051b4:	14078663          	beqz	a5,80005300 <filewrite+0x150>
{
    800051b8:	715d                	addi	sp,sp,-80
    800051ba:	e486                	sd	ra,72(sp)
    800051bc:	e0a2                	sd	s0,64(sp)
    800051be:	fc26                	sd	s1,56(sp)
    800051c0:	f84a                	sd	s2,48(sp)
    800051c2:	f44e                	sd	s3,40(sp)
    800051c4:	f052                	sd	s4,32(sp)
    800051c6:	ec56                	sd	s5,24(sp)
    800051c8:	e85a                	sd	s6,16(sp)
    800051ca:	e45e                	sd	s7,8(sp)
    800051cc:	e062                	sd	s8,0(sp)
    800051ce:	0880                	addi	s0,sp,80
    800051d0:	8ab2                	mv	s5,a2
    800051d2:	8b2e                	mv	s6,a1
    800051d4:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    800051d6:	411c                	lw	a5,0(a0)
    800051d8:	4705                	li	a4,1
    800051da:	02e78263          	beq	a5,a4,800051fe <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800051de:	470d                	li	a4,3
    800051e0:	02e78563          	beq	a5,a4,8000520a <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800051e4:	4709                	li	a4,2
    800051e6:	10e79563          	bne	a5,a4,800052f0 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800051ea:	0ec05f63          	blez	a2,800052e8 <filewrite+0x138>
    int i = 0;
    800051ee:	4901                	li	s2,0
    800051f0:	6b85                	lui	s7,0x1
    800051f2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800051f6:	6c05                	lui	s8,0x1
    800051f8:	c00c0c1b          	addiw	s8,s8,-1024
    800051fc:	a851                	j	80005290 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800051fe:	6908                	ld	a0,16(a0)
    80005200:	00000097          	auipc	ra,0x0
    80005204:	254080e7          	jalr	596(ra) # 80005454 <pipewrite>
    80005208:	a865                	j	800052c0 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000520a:	02451783          	lh	a5,36(a0)
    8000520e:	03079693          	slli	a3,a5,0x30
    80005212:	92c1                	srli	a3,a3,0x30
    80005214:	4725                	li	a4,9
    80005216:	0ed76763          	bltu	a4,a3,80005304 <filewrite+0x154>
    8000521a:	0792                	slli	a5,a5,0x4
    8000521c:	00022717          	auipc	a4,0x22
    80005220:	97c70713          	addi	a4,a4,-1668 # 80026b98 <devsw>
    80005224:	97ba                	add	a5,a5,a4
    80005226:	679c                	ld	a5,8(a5)
    80005228:	c3e5                	beqz	a5,80005308 <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    8000522a:	86b2                	mv	a3,a2
    8000522c:	862e                	mv	a2,a1
    8000522e:	4585                	li	a1,1
    80005230:	9782                	jalr	a5
    80005232:	a079                	j	800052c0 <filewrite+0x110>
    80005234:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80005238:	6c9c                	ld	a5,24(s1)
    8000523a:	4388                	lw	a0,0(a5)
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	7b0080e7          	jalr	1968(ra) # 800049ec <begin_op>
      ilock(f->ip);
    80005244:	6c88                	ld	a0,24(s1)
    80005246:	fffff097          	auipc	ra,0xfffff
    8000524a:	dcc080e7          	jalr	-564(ra) # 80004012 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000524e:	8752                	mv	a4,s4
    80005250:	5094                	lw	a3,32(s1)
    80005252:	01690633          	add	a2,s2,s6
    80005256:	4585                	li	a1,1
    80005258:	6c88                	ld	a0,24(s1)
    8000525a:	fffff097          	auipc	ra,0xfffff
    8000525e:	13e080e7          	jalr	318(ra) # 80004398 <writei>
    80005262:	89aa                	mv	s3,a0
    80005264:	02a05e63          	blez	a0,800052a0 <filewrite+0xf0>
        f->off += r;
    80005268:	509c                	lw	a5,32(s1)
    8000526a:	9fa9                	addw	a5,a5,a0
    8000526c:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    8000526e:	6c88                	ld	a0,24(s1)
    80005270:	fffff097          	auipc	ra,0xfffff
    80005274:	e66080e7          	jalr	-410(ra) # 800040d6 <iunlock>
      end_op(f->ip->dev);
    80005278:	6c9c                	ld	a5,24(s1)
    8000527a:	4388                	lw	a0,0(a5)
    8000527c:	00000097          	auipc	ra,0x0
    80005280:	81c080e7          	jalr	-2020(ra) # 80004a98 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80005284:	05499a63          	bne	s3,s4,800052d8 <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80005288:	012a093b          	addw	s2,s4,s2
    while(i < n){
    8000528c:	03595763          	ble	s5,s2,800052ba <filewrite+0x10a>
      int n1 = n - i;
    80005290:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80005294:	89be                	mv	s3,a5
    80005296:	2781                	sext.w	a5,a5
    80005298:	f8fbdee3          	ble	a5,s7,80005234 <filewrite+0x84>
    8000529c:	89e2                	mv	s3,s8
    8000529e:	bf59                	j	80005234 <filewrite+0x84>
      iunlock(f->ip);
    800052a0:	6c88                	ld	a0,24(s1)
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	e34080e7          	jalr	-460(ra) # 800040d6 <iunlock>
      end_op(f->ip->dev);
    800052aa:	6c9c                	ld	a5,24(s1)
    800052ac:	4388                	lw	a0,0(a5)
    800052ae:	fffff097          	auipc	ra,0xfffff
    800052b2:	7ea080e7          	jalr	2026(ra) # 80004a98 <end_op>
      if(r < 0)
    800052b6:	fc09d7e3          	bgez	s3,80005284 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800052ba:	8556                	mv	a0,s5
    800052bc:	032a9863          	bne	s5,s2,800052ec <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800052c0:	60a6                	ld	ra,72(sp)
    800052c2:	6406                	ld	s0,64(sp)
    800052c4:	74e2                	ld	s1,56(sp)
    800052c6:	7942                	ld	s2,48(sp)
    800052c8:	79a2                	ld	s3,40(sp)
    800052ca:	7a02                	ld	s4,32(sp)
    800052cc:	6ae2                	ld	s5,24(sp)
    800052ce:	6b42                	ld	s6,16(sp)
    800052d0:	6ba2                	ld	s7,8(sp)
    800052d2:	6c02                	ld	s8,0(sp)
    800052d4:	6161                	addi	sp,sp,80
    800052d6:	8082                	ret
        panic("short filewrite");
    800052d8:	00004517          	auipc	a0,0x4
    800052dc:	93050513          	addi	a0,a0,-1744 # 80008c08 <userret+0xb78>
    800052e0:	ffffb097          	auipc	ra,0xffffb
    800052e4:	4a4080e7          	jalr	1188(ra) # 80000784 <panic>
    int i = 0;
    800052e8:	4901                	li	s2,0
    800052ea:	bfc1                	j	800052ba <filewrite+0x10a>
    ret = (i == n ? n : -1);
    800052ec:	557d                	li	a0,-1
    800052ee:	bfc9                	j	800052c0 <filewrite+0x110>
    panic("filewrite");
    800052f0:	00004517          	auipc	a0,0x4
    800052f4:	92850513          	addi	a0,a0,-1752 # 80008c18 <userret+0xb88>
    800052f8:	ffffb097          	auipc	ra,0xffffb
    800052fc:	48c080e7          	jalr	1164(ra) # 80000784 <panic>
    return -1;
    80005300:	557d                	li	a0,-1
}
    80005302:	8082                	ret
      return -1;
    80005304:	557d                	li	a0,-1
    80005306:	bf6d                	j	800052c0 <filewrite+0x110>
    80005308:	557d                	li	a0,-1
    8000530a:	bf5d                	j	800052c0 <filewrite+0x110>

000000008000530c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000530c:	7179                	addi	sp,sp,-48
    8000530e:	f406                	sd	ra,40(sp)
    80005310:	f022                	sd	s0,32(sp)
    80005312:	ec26                	sd	s1,24(sp)
    80005314:	e84a                	sd	s2,16(sp)
    80005316:	e44e                	sd	s3,8(sp)
    80005318:	e052                	sd	s4,0(sp)
    8000531a:	1800                	addi	s0,sp,48
    8000531c:	84aa                	mv	s1,a0
    8000531e:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005320:	0005b023          	sd	zero,0(a1)
    80005324:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005328:	00000097          	auipc	ra,0x0
    8000532c:	bb0080e7          	jalr	-1104(ra) # 80004ed8 <filealloc>
    80005330:	e088                	sd	a0,0(s1)
    80005332:	c549                	beqz	a0,800053bc <pipealloc+0xb0>
    80005334:	00000097          	auipc	ra,0x0
    80005338:	ba4080e7          	jalr	-1116(ra) # 80004ed8 <filealloc>
    8000533c:	00a93023          	sd	a0,0(s2)
    80005340:	c925                	beqz	a0,800053b0 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005342:	ffffb097          	auipc	ra,0xffffb
    80005346:	7f0080e7          	jalr	2032(ra) # 80000b32 <kalloc>
    8000534a:	89aa                	mv	s3,a0
    8000534c:	cd39                	beqz	a0,800053aa <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    8000534e:	4a05                	li	s4,1
    80005350:	23452c23          	sw	s4,568(a0)
  pi->writeopen = 1;
    80005354:	23452e23          	sw	s4,572(a0)
  pi->nwrite = 0;
    80005358:	22052a23          	sw	zero,564(a0)
  pi->nread = 0;
    8000535c:	22052823          	sw	zero,560(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80005360:	03000613          	li	a2,48
    80005364:	4581                	li	a1,0
    80005366:	ffffc097          	auipc	ra,0xffffc
    8000536a:	dc8080e7          	jalr	-568(ra) # 8000112e <memset>
  (*f0)->type = FD_PIPE;
    8000536e:	609c                	ld	a5,0(s1)
    80005370:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80005374:	609c                	ld	a5,0(s1)
    80005376:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    8000537a:	609c                	ld	a5,0(s1)
    8000537c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005380:	609c                	ld	a5,0(s1)
    80005382:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80005386:	00093783          	ld	a5,0(s2)
    8000538a:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    8000538e:	00093783          	ld	a5,0(s2)
    80005392:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005396:	00093783          	ld	a5,0(s2)
    8000539a:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    8000539e:	00093783          	ld	a5,0(s2)
    800053a2:	0137b823          	sd	s3,16(a5)
  return 0;
    800053a6:	4501                	li	a0,0
    800053a8:	a025                	j	800053d0 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800053aa:	6088                	ld	a0,0(s1)
    800053ac:	e501                	bnez	a0,800053b4 <pipealloc+0xa8>
    800053ae:	a039                	j	800053bc <pipealloc+0xb0>
    800053b0:	6088                	ld	a0,0(s1)
    800053b2:	c51d                	beqz	a0,800053e0 <pipealloc+0xd4>
    fileclose(*f0);
    800053b4:	00000097          	auipc	ra,0x0
    800053b8:	bf4080e7          	jalr	-1036(ra) # 80004fa8 <fileclose>
  if(*f1)
    800053bc:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    800053c0:	557d                	li	a0,-1
  if(*f1)
    800053c2:	c799                	beqz	a5,800053d0 <pipealloc+0xc4>
    fileclose(*f1);
    800053c4:	853e                	mv	a0,a5
    800053c6:	00000097          	auipc	ra,0x0
    800053ca:	be2080e7          	jalr	-1054(ra) # 80004fa8 <fileclose>
  return -1;
    800053ce:	557d                	li	a0,-1
}
    800053d0:	70a2                	ld	ra,40(sp)
    800053d2:	7402                	ld	s0,32(sp)
    800053d4:	64e2                	ld	s1,24(sp)
    800053d6:	6942                	ld	s2,16(sp)
    800053d8:	69a2                	ld	s3,8(sp)
    800053da:	6a02                	ld	s4,0(sp)
    800053dc:	6145                	addi	sp,sp,48
    800053de:	8082                	ret
  return -1;
    800053e0:	557d                	li	a0,-1
    800053e2:	b7fd                	j	800053d0 <pipealloc+0xc4>

00000000800053e4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800053e4:	1101                	addi	sp,sp,-32
    800053e6:	ec06                	sd	ra,24(sp)
    800053e8:	e822                	sd	s0,16(sp)
    800053ea:	e426                	sd	s1,8(sp)
    800053ec:	e04a                	sd	s2,0(sp)
    800053ee:	1000                	addi	s0,sp,32
    800053f0:	84aa                	mv	s1,a0
    800053f2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800053f4:	ffffc097          	auipc	ra,0xffffc
    800053f8:	8c6080e7          	jalr	-1850(ra) # 80000cba <acquire>
  if(writable){
    800053fc:	02090d63          	beqz	s2,80005436 <pipeclose+0x52>
    pi->writeopen = 0;
    80005400:	2204ae23          	sw	zero,572(s1)
    wakeup(&pi->nread);
    80005404:	23048513          	addi	a0,s1,560
    80005408:	ffffd097          	auipc	ra,0xffffd
    8000540c:	6b0080e7          	jalr	1712(ra) # 80002ab8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005410:	2384b783          	ld	a5,568(s1)
    80005414:	eb95                	bnez	a5,80005448 <pipeclose+0x64>
    release(&pi->lock);
    80005416:	8526                	mv	a0,s1
    80005418:	ffffc097          	auipc	ra,0xffffc
    8000541c:	aee080e7          	jalr	-1298(ra) # 80000f06 <release>
    kfree((char*)pi);
    80005420:	8526                	mv	a0,s1
    80005422:	ffffb097          	auipc	ra,0xffffb
    80005426:	6f8080e7          	jalr	1784(ra) # 80000b1a <kfree>
  } else
    release(&pi->lock);
}
    8000542a:	60e2                	ld	ra,24(sp)
    8000542c:	6442                	ld	s0,16(sp)
    8000542e:	64a2                	ld	s1,8(sp)
    80005430:	6902                	ld	s2,0(sp)
    80005432:	6105                	addi	sp,sp,32
    80005434:	8082                	ret
    pi->readopen = 0;
    80005436:	2204ac23          	sw	zero,568(s1)
    wakeup(&pi->nwrite);
    8000543a:	23448513          	addi	a0,s1,564
    8000543e:	ffffd097          	auipc	ra,0xffffd
    80005442:	67a080e7          	jalr	1658(ra) # 80002ab8 <wakeup>
    80005446:	b7e9                	j	80005410 <pipeclose+0x2c>
    release(&pi->lock);
    80005448:	8526                	mv	a0,s1
    8000544a:	ffffc097          	auipc	ra,0xffffc
    8000544e:	abc080e7          	jalr	-1348(ra) # 80000f06 <release>
}
    80005452:	bfe1                	j	8000542a <pipeclose+0x46>

0000000080005454 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005454:	7159                	addi	sp,sp,-112
    80005456:	f486                	sd	ra,104(sp)
    80005458:	f0a2                	sd	s0,96(sp)
    8000545a:	eca6                	sd	s1,88(sp)
    8000545c:	e8ca                	sd	s2,80(sp)
    8000545e:	e4ce                	sd	s3,72(sp)
    80005460:	e0d2                	sd	s4,64(sp)
    80005462:	fc56                	sd	s5,56(sp)
    80005464:	f85a                	sd	s6,48(sp)
    80005466:	f45e                	sd	s7,40(sp)
    80005468:	f062                	sd	s8,32(sp)
    8000546a:	ec66                	sd	s9,24(sp)
    8000546c:	1880                	addi	s0,sp,112
    8000546e:	84aa                	mv	s1,a0
    80005470:	8bae                	mv	s7,a1
    80005472:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80005474:	ffffd097          	auipc	ra,0xffffd
    80005478:	bcc080e7          	jalr	-1076(ra) # 80002040 <myproc>
    8000547c:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    8000547e:	8526                	mv	a0,s1
    80005480:	ffffc097          	auipc	ra,0xffffc
    80005484:	83a080e7          	jalr	-1990(ra) # 80000cba <acquire>
  for(i = 0; i < n; i++){
    80005488:	0d605663          	blez	s6,80005554 <pipewrite+0x100>
    8000548c:	8926                	mv	s2,s1
    8000548e:	fffb0a9b          	addiw	s5,s6,-1
    80005492:	1a82                	slli	s5,s5,0x20
    80005494:	020ada93          	srli	s5,s5,0x20
    80005498:	001b8793          	addi	a5,s7,1
    8000549c:	9abe                	add	s5,s5,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    8000549e:	23048a13          	addi	s4,s1,560
      sleep(&pi->nwrite, &pi->lock);
    800054a2:	23448993          	addi	s3,s1,564
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800054a6:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800054a8:	2304a783          	lw	a5,560(s1)
    800054ac:	2344a703          	lw	a4,564(s1)
    800054b0:	2007879b          	addiw	a5,a5,512
    800054b4:	06f71463          	bne	a4,a5,8000551c <pipewrite+0xc8>
      if(pi->readopen == 0 || myproc()->killed){
    800054b8:	2384a783          	lw	a5,568(s1)
    800054bc:	cf8d                	beqz	a5,800054f6 <pipewrite+0xa2>
    800054be:	ffffd097          	auipc	ra,0xffffd
    800054c2:	b82080e7          	jalr	-1150(ra) # 80002040 <myproc>
    800054c6:	453c                	lw	a5,72(a0)
    800054c8:	e79d                	bnez	a5,800054f6 <pipewrite+0xa2>
      wakeup(&pi->nread);
    800054ca:	8552                	mv	a0,s4
    800054cc:	ffffd097          	auipc	ra,0xffffd
    800054d0:	5ec080e7          	jalr	1516(ra) # 80002ab8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800054d4:	85ca                	mv	a1,s2
    800054d6:	854e                	mv	a0,s3
    800054d8:	ffffd097          	auipc	ra,0xffffd
    800054dc:	45a080e7          	jalr	1114(ra) # 80002932 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800054e0:	2304a783          	lw	a5,560(s1)
    800054e4:	2344a703          	lw	a4,564(s1)
    800054e8:	2007879b          	addiw	a5,a5,512
    800054ec:	02f71863          	bne	a4,a5,8000551c <pipewrite+0xc8>
      if(pi->readopen == 0 || myproc()->killed){
    800054f0:	2384a783          	lw	a5,568(s1)
    800054f4:	f7e9                	bnez	a5,800054be <pipewrite+0x6a>
        release(&pi->lock);
    800054f6:	8526                	mv	a0,s1
    800054f8:	ffffc097          	auipc	ra,0xffffc
    800054fc:	a0e080e7          	jalr	-1522(ra) # 80000f06 <release>
        return -1;
    80005500:	557d                	li	a0,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return n;
}
    80005502:	70a6                	ld	ra,104(sp)
    80005504:	7406                	ld	s0,96(sp)
    80005506:	64e6                	ld	s1,88(sp)
    80005508:	6946                	ld	s2,80(sp)
    8000550a:	69a6                	ld	s3,72(sp)
    8000550c:	6a06                	ld	s4,64(sp)
    8000550e:	7ae2                	ld	s5,56(sp)
    80005510:	7b42                	ld	s6,48(sp)
    80005512:	7ba2                	ld	s7,40(sp)
    80005514:	7c02                	ld	s8,32(sp)
    80005516:	6ce2                	ld	s9,24(sp)
    80005518:	6165                	addi	sp,sp,112
    8000551a:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000551c:	4685                	li	a3,1
    8000551e:	865e                	mv	a2,s7
    80005520:	f9f40593          	addi	a1,s0,-97
    80005524:	068c3503          	ld	a0,104(s8) # 1068 <_entry-0x7fffef98>
    80005528:	ffffc097          	auipc	ra,0xffffc
    8000552c:	782080e7          	jalr	1922(ra) # 80001caa <copyin>
    80005530:	03950263          	beq	a0,s9,80005554 <pipewrite+0x100>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005534:	2344a783          	lw	a5,564(s1)
    80005538:	0017871b          	addiw	a4,a5,1
    8000553c:	22e4aa23          	sw	a4,564(s1)
    80005540:	1ff7f793          	andi	a5,a5,511
    80005544:	97a6                	add	a5,a5,s1
    80005546:	f9f44703          	lbu	a4,-97(s0)
    8000554a:	02e78823          	sb	a4,48(a5)
    8000554e:	0b85                	addi	s7,s7,1
  for(i = 0; i < n; i++){
    80005550:	f55b9ce3          	bne	s7,s5,800054a8 <pipewrite+0x54>
  wakeup(&pi->nread);
    80005554:	23048513          	addi	a0,s1,560
    80005558:	ffffd097          	auipc	ra,0xffffd
    8000555c:	560080e7          	jalr	1376(ra) # 80002ab8 <wakeup>
  release(&pi->lock);
    80005560:	8526                	mv	a0,s1
    80005562:	ffffc097          	auipc	ra,0xffffc
    80005566:	9a4080e7          	jalr	-1628(ra) # 80000f06 <release>
  return n;
    8000556a:	855a                	mv	a0,s6
    8000556c:	bf59                	j	80005502 <pipewrite+0xae>

000000008000556e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000556e:	715d                	addi	sp,sp,-80
    80005570:	e486                	sd	ra,72(sp)
    80005572:	e0a2                	sd	s0,64(sp)
    80005574:	fc26                	sd	s1,56(sp)
    80005576:	f84a                	sd	s2,48(sp)
    80005578:	f44e                	sd	s3,40(sp)
    8000557a:	f052                	sd	s4,32(sp)
    8000557c:	ec56                	sd	s5,24(sp)
    8000557e:	e85a                	sd	s6,16(sp)
    80005580:	0880                	addi	s0,sp,80
    80005582:	84aa                	mv	s1,a0
    80005584:	89ae                	mv	s3,a1
    80005586:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80005588:	ffffd097          	auipc	ra,0xffffd
    8000558c:	ab8080e7          	jalr	-1352(ra) # 80002040 <myproc>
    80005590:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80005592:	8526                	mv	a0,s1
    80005594:	ffffb097          	auipc	ra,0xffffb
    80005598:	726080e7          	jalr	1830(ra) # 80000cba <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000559c:	2304a703          	lw	a4,560(s1)
    800055a0:	2344a783          	lw	a5,564(s1)
    800055a4:	06f71b63          	bne	a4,a5,8000561a <piperead+0xac>
    800055a8:	8926                	mv	s2,s1
    800055aa:	23c4a783          	lw	a5,572(s1)
    800055ae:	cb85                	beqz	a5,800055de <piperead+0x70>
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055b0:	23048b13          	addi	s6,s1,560
    if(myproc()->killed){
    800055b4:	ffffd097          	auipc	ra,0xffffd
    800055b8:	a8c080e7          	jalr	-1396(ra) # 80002040 <myproc>
    800055bc:	453c                	lw	a5,72(a0)
    800055be:	e7b9                	bnez	a5,8000560c <piperead+0x9e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800055c0:	85ca                	mv	a1,s2
    800055c2:	855a                	mv	a0,s6
    800055c4:	ffffd097          	auipc	ra,0xffffd
    800055c8:	36e080e7          	jalr	878(ra) # 80002932 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800055cc:	2304a703          	lw	a4,560(s1)
    800055d0:	2344a783          	lw	a5,564(s1)
    800055d4:	04f71363          	bne	a4,a5,8000561a <piperead+0xac>
    800055d8:	23c4a783          	lw	a5,572(s1)
    800055dc:	ffe1                	bnez	a5,800055b4 <piperead+0x46>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    800055de:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800055e0:	23448513          	addi	a0,s1,564
    800055e4:	ffffd097          	auipc	ra,0xffffd
    800055e8:	4d4080e7          	jalr	1236(ra) # 80002ab8 <wakeup>
  release(&pi->lock);
    800055ec:	8526                	mv	a0,s1
    800055ee:	ffffc097          	auipc	ra,0xffffc
    800055f2:	918080e7          	jalr	-1768(ra) # 80000f06 <release>
  return i;
}
    800055f6:	854a                	mv	a0,s2
    800055f8:	60a6                	ld	ra,72(sp)
    800055fa:	6406                	ld	s0,64(sp)
    800055fc:	74e2                	ld	s1,56(sp)
    800055fe:	7942                	ld	s2,48(sp)
    80005600:	79a2                	ld	s3,40(sp)
    80005602:	7a02                	ld	s4,32(sp)
    80005604:	6ae2                	ld	s5,24(sp)
    80005606:	6b42                	ld	s6,16(sp)
    80005608:	6161                	addi	sp,sp,80
    8000560a:	8082                	ret
      release(&pi->lock);
    8000560c:	8526                	mv	a0,s1
    8000560e:	ffffc097          	auipc	ra,0xffffc
    80005612:	8f8080e7          	jalr	-1800(ra) # 80000f06 <release>
      return -1;
    80005616:	597d                	li	s2,-1
    80005618:	bff9                	j	800055f6 <piperead+0x88>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000561a:	4901                	li	s2,0
    8000561c:	fd4052e3          	blez	s4,800055e0 <piperead+0x72>
    if(pi->nread == pi->nwrite)
    80005620:	2304a783          	lw	a5,560(s1)
    80005624:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005626:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005628:	0017871b          	addiw	a4,a5,1
    8000562c:	22e4a823          	sw	a4,560(s1)
    80005630:	1ff7f793          	andi	a5,a5,511
    80005634:	97a6                	add	a5,a5,s1
    80005636:	0307c783          	lbu	a5,48(a5)
    8000563a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000563e:	4685                	li	a3,1
    80005640:	fbf40613          	addi	a2,s0,-65
    80005644:	85ce                	mv	a1,s3
    80005646:	068ab503          	ld	a0,104(s5)
    8000564a:	ffffc097          	auipc	ra,0xffffc
    8000564e:	5d4080e7          	jalr	1492(ra) # 80001c1e <copyout>
    80005652:	f96507e3          	beq	a0,s6,800055e0 <piperead+0x72>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005656:	2905                	addiw	s2,s2,1
    80005658:	f92a04e3          	beq	s4,s2,800055e0 <piperead+0x72>
    if(pi->nread == pi->nwrite)
    8000565c:	2304a783          	lw	a5,560(s1)
    80005660:	0985                	addi	s3,s3,1
    80005662:	2344a703          	lw	a4,564(s1)
    80005666:	fcf711e3          	bne	a4,a5,80005628 <piperead+0xba>
    8000566a:	bf9d                	j	800055e0 <piperead+0x72>

000000008000566c <exec>:



int
exec(char *path, char **argv)
{
    8000566c:	de010113          	addi	sp,sp,-544
    80005670:	20113c23          	sd	ra,536(sp)
    80005674:	20813823          	sd	s0,528(sp)
    80005678:	20913423          	sd	s1,520(sp)
    8000567c:	21213023          	sd	s2,512(sp)
    80005680:	ffce                	sd	s3,504(sp)
    80005682:	fbd2                	sd	s4,496(sp)
    80005684:	f7d6                	sd	s5,488(sp)
    80005686:	f3da                	sd	s6,480(sp)
    80005688:	efde                	sd	s7,472(sp)
    8000568a:	ebe2                	sd	s8,464(sp)
    8000568c:	e7e6                	sd	s9,456(sp)
    8000568e:	e3ea                	sd	s10,448(sp)
    80005690:	ff6e                	sd	s11,440(sp)
    80005692:	1400                	addi	s0,sp,544
    80005694:	892a                	mv	s2,a0
    80005696:	dea43823          	sd	a0,-528(s0)
    8000569a:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000569e:	ffffd097          	auipc	ra,0xffffd
    800056a2:	9a2080e7          	jalr	-1630(ra) # 80002040 <myproc>
    800056a6:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    800056a8:	4501                	li	a0,0
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	342080e7          	jalr	834(ra) # 800049ec <begin_op>

  if((ip = namei(path)) == 0){
    800056b2:	854a                	mv	a0,s2
    800056b4:	fffff097          	auipc	ra,0xfffff
    800056b8:	0f2080e7          	jalr	242(ra) # 800047a6 <namei>
    800056bc:	cd25                	beqz	a0,80005734 <exec+0xc8>
    800056be:	892a                	mv	s2,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	952080e7          	jalr	-1710(ra) # 80004012 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800056c8:	04000713          	li	a4,64
    800056cc:	4681                	li	a3,0
    800056ce:	e4840613          	addi	a2,s0,-440
    800056d2:	4581                	li	a1,0
    800056d4:	854a                	mv	a0,s2
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	bce080e7          	jalr	-1074(ra) # 800042a4 <readi>
    800056de:	04000793          	li	a5,64
    800056e2:	00f51a63          	bne	a0,a5,800056f6 <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800056e6:	e4842703          	lw	a4,-440(s0)
    800056ea:	464c47b7          	lui	a5,0x464c4
    800056ee:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800056f2:	04f70863          	beq	a4,a5,80005742 <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800056f6:	854a                	mv	a0,s2
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	b5a080e7          	jalr	-1190(ra) # 80004252 <iunlockput>
    end_op(ROOTDEV);
    80005700:	4501                	li	a0,0
    80005702:	fffff097          	auipc	ra,0xfffff
    80005706:	396080e7          	jalr	918(ra) # 80004a98 <end_op>
  }
  return -1;
    8000570a:	557d                	li	a0,-1
}
    8000570c:	21813083          	ld	ra,536(sp)
    80005710:	21013403          	ld	s0,528(sp)
    80005714:	20813483          	ld	s1,520(sp)
    80005718:	20013903          	ld	s2,512(sp)
    8000571c:	79fe                	ld	s3,504(sp)
    8000571e:	7a5e                	ld	s4,496(sp)
    80005720:	7abe                	ld	s5,488(sp)
    80005722:	7b1e                	ld	s6,480(sp)
    80005724:	6bfe                	ld	s7,472(sp)
    80005726:	6c5e                	ld	s8,464(sp)
    80005728:	6cbe                	ld	s9,456(sp)
    8000572a:	6d1e                	ld	s10,448(sp)
    8000572c:	7dfa                	ld	s11,440(sp)
    8000572e:	22010113          	addi	sp,sp,544
    80005732:	8082                	ret
    end_op(ROOTDEV);
    80005734:	4501                	li	a0,0
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	362080e7          	jalr	866(ra) # 80004a98 <end_op>
    return -1;
    8000573e:	557d                	li	a0,-1
    80005740:	b7f1                	j	8000570c <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80005742:	8526                	mv	a0,s1
    80005744:	ffffd097          	auipc	ra,0xffffd
    80005748:	9c2080e7          	jalr	-1598(ra) # 80002106 <proc_pagetable>
    8000574c:	e0a43423          	sd	a0,-504(s0)
    80005750:	d15d                	beqz	a0,800056f6 <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005752:	e6842983          	lw	s3,-408(s0)
    80005756:	e8045783          	lhu	a5,-384(s0)
    8000575a:	cbed                	beqz	a5,8000584c <exec+0x1e0>
  sz = 0;
    8000575c:	e0043023          	sd	zero,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005760:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005762:	6c05                	lui	s8,0x1
    80005764:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80005768:	def43423          	sd	a5,-536(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    8000576c:	6d05                	lui	s10,0x1
    8000576e:	a0a5                	j	800057d6 <exec+0x16a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005770:	00003517          	auipc	a0,0x3
    80005774:	4b850513          	addi	a0,a0,1208 # 80008c28 <userret+0xb98>
    80005778:	ffffb097          	auipc	ra,0xffffb
    8000577c:	00c080e7          	jalr	12(ra) # 80000784 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005780:	8756                	mv	a4,s5
    80005782:	009d86bb          	addw	a3,s11,s1
    80005786:	4581                	li	a1,0
    80005788:	854a                	mv	a0,s2
    8000578a:	fffff097          	auipc	ra,0xfffff
    8000578e:	b1a080e7          	jalr	-1254(ra) # 800042a4 <readi>
    80005792:	2501                	sext.w	a0,a0
    80005794:	10aa9563          	bne	s5,a0,8000589e <exec+0x232>
  for(i = 0; i < sz; i += PGSIZE){
    80005798:	009d04bb          	addw	s1,s10,s1
    8000579c:	77fd                	lui	a5,0xfffff
    8000579e:	01478a3b          	addw	s4,a5,s4
    800057a2:	0374f363          	bleu	s7,s1,800057c8 <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    800057a6:	02049593          	slli	a1,s1,0x20
    800057aa:	9181                	srli	a1,a1,0x20
    800057ac:	95e6                	add	a1,a1,s9
    800057ae:	e0843503          	ld	a0,-504(s0)
    800057b2:	ffffc097          	auipc	ra,0xffffc
    800057b6:	e88080e7          	jalr	-376(ra) # 8000163a <walkaddr>
    800057ba:	862a                	mv	a2,a0
    if(pa == 0)
    800057bc:	d955                	beqz	a0,80005770 <exec+0x104>
      n = PGSIZE;
    800057be:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    800057c0:	fd8a70e3          	bleu	s8,s4,80005780 <exec+0x114>
      n = sz - i;
    800057c4:	8ad2                	mv	s5,s4
    800057c6:	bf6d                	j	80005780 <exec+0x114>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057c8:	2b05                	addiw	s6,s6,1
    800057ca:	0389899b          	addiw	s3,s3,56
    800057ce:	e8045783          	lhu	a5,-384(s0)
    800057d2:	06fb5f63          	ble	a5,s6,80005850 <exec+0x1e4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800057d6:	2981                	sext.w	s3,s3
    800057d8:	03800713          	li	a4,56
    800057dc:	86ce                	mv	a3,s3
    800057de:	e1040613          	addi	a2,s0,-496
    800057e2:	4581                	li	a1,0
    800057e4:	854a                	mv	a0,s2
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	abe080e7          	jalr	-1346(ra) # 800042a4 <readi>
    800057ee:	03800793          	li	a5,56
    800057f2:	0af51663          	bne	a0,a5,8000589e <exec+0x232>
    if(ph.type != ELF_PROG_LOAD)
    800057f6:	e1042783          	lw	a5,-496(s0)
    800057fa:	4705                	li	a4,1
    800057fc:	fce796e3          	bne	a5,a4,800057c8 <exec+0x15c>
    if(ph.memsz < ph.filesz)
    80005800:	e3843603          	ld	a2,-456(s0)
    80005804:	e3043783          	ld	a5,-464(s0)
    80005808:	08f66b63          	bltu	a2,a5,8000589e <exec+0x232>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000580c:	e2043783          	ld	a5,-480(s0)
    80005810:	963e                	add	a2,a2,a5
    80005812:	08f66663          	bltu	a2,a5,8000589e <exec+0x232>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005816:	e0043583          	ld	a1,-512(s0)
    8000581a:	e0843503          	ld	a0,-504(s0)
    8000581e:	ffffc097          	auipc	ra,0xffffc
    80005822:	226080e7          	jalr	550(ra) # 80001a44 <uvmalloc>
    80005826:	e0a43023          	sd	a0,-512(s0)
    8000582a:	c935                	beqz	a0,8000589e <exec+0x232>
    if(ph.vaddr % PGSIZE != 0)
    8000582c:	e2043c83          	ld	s9,-480(s0)
    80005830:	de843783          	ld	a5,-536(s0)
    80005834:	00fcf7b3          	and	a5,s9,a5
    80005838:	e3bd                	bnez	a5,8000589e <exec+0x232>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000583a:	e1842d83          	lw	s11,-488(s0)
    8000583e:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005842:	f80b83e3          	beqz	s7,800057c8 <exec+0x15c>
    80005846:	8a5e                	mv	s4,s7
    80005848:	4481                	li	s1,0
    8000584a:	bfb1                	j	800057a6 <exec+0x13a>
  sz = 0;
    8000584c:	e0043023          	sd	zero,-512(s0)
  iunlockput(ip);
    80005850:	854a                	mv	a0,s2
    80005852:	fffff097          	auipc	ra,0xfffff
    80005856:	a00080e7          	jalr	-1536(ra) # 80004252 <iunlockput>
  end_op(ROOTDEV);
    8000585a:	4501                	li	a0,0
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	23c080e7          	jalr	572(ra) # 80004a98 <end_op>
  p = myproc();
    80005864:	ffffc097          	auipc	ra,0xffffc
    80005868:	7dc080e7          	jalr	2012(ra) # 80002040 <myproc>
    8000586c:	8caa                	mv	s9,a0
  uint64 oldsz = p->sz;
    8000586e:	06053d83          	ld	s11,96(a0)
  sz = PGROUNDUP(sz);
    80005872:	6585                	lui	a1,0x1
    80005874:	15fd                	addi	a1,a1,-1
    80005876:	e0043783          	ld	a5,-512(s0)
    8000587a:	00b78d33          	add	s10,a5,a1
    8000587e:	75fd                	lui	a1,0xfffff
    80005880:	00bd75b3          	and	a1,s10,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005884:	6609                	lui	a2,0x2
    80005886:	962e                	add	a2,a2,a1
    80005888:	e0843483          	ld	s1,-504(s0)
    8000588c:	8526                	mv	a0,s1
    8000588e:	ffffc097          	auipc	ra,0xffffc
    80005892:	1b6080e7          	jalr	438(ra) # 80001a44 <uvmalloc>
    80005896:	e0a43023          	sd	a0,-512(s0)
  ip = 0;
    8000589a:	4901                	li	s2,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000589c:	ed09                	bnez	a0,800058b6 <exec+0x24a>
    proc_freepagetable(pagetable, sz);
    8000589e:	e0043583          	ld	a1,-512(s0)
    800058a2:	e0843503          	ld	a0,-504(s0)
    800058a6:	ffffd097          	auipc	ra,0xffffd
    800058aa:	964080e7          	jalr	-1692(ra) # 8000220a <proc_freepagetable>
  if(ip){
    800058ae:	e40914e3          	bnez	s2,800056f6 <exec+0x8a>
  return -1;
    800058b2:	557d                	li	a0,-1
    800058b4:	bda1                	j	8000570c <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    800058b6:	75f9                	lui	a1,0xffffe
    800058b8:	892a                	mv	s2,a0
    800058ba:	95aa                	add	a1,a1,a0
    800058bc:	8526                	mv	a0,s1
    800058be:	ffffc097          	auipc	ra,0xffffc
    800058c2:	32e080e7          	jalr	814(ra) # 80001bec <uvmclear>
  stackbase = sp - PGSIZE;
    800058c6:	7b7d                	lui	s6,0xfffff
    800058c8:	9b4a                	add	s6,s6,s2
  for(argc = 0; argv[argc]; argc++) {
    800058ca:	df843983          	ld	s3,-520(s0)
    800058ce:	0009b503          	ld	a0,0(s3)
    800058d2:	c125                	beqz	a0,80005932 <exec+0x2c6>
    800058d4:	e8840a13          	addi	s4,s0,-376
    800058d8:	f8840b93          	addi	s7,s0,-120
    800058dc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800058de:	ffffc097          	auipc	ra,0xffffc
    800058e2:	9fa080e7          	jalr	-1542(ra) # 800012d8 <strlen>
    800058e6:	2505                	addiw	a0,a0,1
    800058e8:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800058ec:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800058f0:	11696963          	bltu	s2,s6,80005a02 <exec+0x396>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800058f4:	0009ba83          	ld	s5,0(s3)
    800058f8:	8556                	mv	a0,s5
    800058fa:	ffffc097          	auipc	ra,0xffffc
    800058fe:	9de080e7          	jalr	-1570(ra) # 800012d8 <strlen>
    80005902:	0015069b          	addiw	a3,a0,1
    80005906:	8656                	mv	a2,s5
    80005908:	85ca                	mv	a1,s2
    8000590a:	e0843503          	ld	a0,-504(s0)
    8000590e:	ffffc097          	auipc	ra,0xffffc
    80005912:	310080e7          	jalr	784(ra) # 80001c1e <copyout>
    80005916:	0e054863          	bltz	a0,80005a06 <exec+0x39a>
    ustack[argc] = sp;
    8000591a:	012a3023          	sd	s2,0(s4)
  for(argc = 0; argv[argc]; argc++) {
    8000591e:	0485                	addi	s1,s1,1
    80005920:	09a1                	addi	s3,s3,8
    80005922:	0009b503          	ld	a0,0(s3)
    80005926:	c909                	beqz	a0,80005938 <exec+0x2cc>
    if(argc >= MAXARG)
    80005928:	0a21                	addi	s4,s4,8
    8000592a:	fb7a1ae3          	bne	s4,s7,800058de <exec+0x272>
  ip = 0;
    8000592e:	4901                	li	s2,0
    80005930:	b7bd                	j	8000589e <exec+0x232>
  sp = sz;
    80005932:	e0043903          	ld	s2,-512(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005936:	4481                	li	s1,0
  ustack[argc] = 0;
    80005938:	00349793          	slli	a5,s1,0x3
    8000593c:	f9040713          	addi	a4,s0,-112
    80005940:	97ba                	add	a5,a5,a4
    80005942:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcee4c>
  sp -= (argc+1) * sizeof(uint64);
    80005946:	00148693          	addi	a3,s1,1
    8000594a:	068e                	slli	a3,a3,0x3
    8000594c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005950:	ff097993          	andi	s3,s2,-16
  ip = 0;
    80005954:	4901                	li	s2,0
  if(sp < stackbase)
    80005956:	f569e4e3          	bltu	s3,s6,8000589e <exec+0x232>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000595a:	e8840613          	addi	a2,s0,-376
    8000595e:	85ce                	mv	a1,s3
    80005960:	e0843503          	ld	a0,-504(s0)
    80005964:	ffffc097          	auipc	ra,0xffffc
    80005968:	2ba080e7          	jalr	698(ra) # 80001c1e <copyout>
    8000596c:	08054f63          	bltz	a0,80005a0a <exec+0x39e>
  p->tf->a1 = sp;
    80005970:	070cb783          	ld	a5,112(s9) # 2070 <_entry-0x7fffdf90>
    80005974:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    80005978:	df043783          	ld	a5,-528(s0)
    8000597c:	0007c703          	lbu	a4,0(a5)
    80005980:	cf11                	beqz	a4,8000599c <exec+0x330>
    80005982:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005984:	02f00693          	li	a3,47
    80005988:	a029                	j	80005992 <exec+0x326>
    8000598a:	0785                	addi	a5,a5,1
  for(last=s=path; *s; s++)
    8000598c:	fff7c703          	lbu	a4,-1(a5)
    80005990:	c711                	beqz	a4,8000599c <exec+0x330>
    if(*s == '/')
    80005992:	fed71ce3          	bne	a4,a3,8000598a <exec+0x31e>
      last = s+1;
    80005996:	def43823          	sd	a5,-528(s0)
    8000599a:	bfc5                	j	8000598a <exec+0x31e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000599c:	4641                	li	a2,16
    8000599e:	df043583          	ld	a1,-528(s0)
    800059a2:	170c8513          	addi	a0,s9,368
    800059a6:	ffffc097          	auipc	ra,0xffffc
    800059aa:	900080e7          	jalr	-1792(ra) # 800012a6 <safestrcpy>
  if(p->cmd) bd_free(p->cmd);
    800059ae:	180cb503          	ld	a0,384(s9)
    800059b2:	c509                	beqz	a0,800059bc <exec+0x350>
    800059b4:	00002097          	auipc	ra,0x2
    800059b8:	b48080e7          	jalr	-1208(ra) # 800074fc <bd_free>
  p->cmd = strjoin(argv);
    800059bc:	df843503          	ld	a0,-520(s0)
    800059c0:	ffffc097          	auipc	ra,0xffffc
    800059c4:	942080e7          	jalr	-1726(ra) # 80001302 <strjoin>
    800059c8:	18acb023          	sd	a0,384(s9)
  oldpagetable = p->pagetable;
    800059cc:	068cb503          	ld	a0,104(s9)
  p->pagetable = pagetable;
    800059d0:	e0843783          	ld	a5,-504(s0)
    800059d4:	06fcb423          	sd	a5,104(s9)
  p->sz = sz;
    800059d8:	e0043783          	ld	a5,-512(s0)
    800059dc:	06fcb023          	sd	a5,96(s9)
  p->tf->epc = elf.entry;  // initial program counter = main
    800059e0:	070cb783          	ld	a5,112(s9)
    800059e4:	e6043703          	ld	a4,-416(s0)
    800059e8:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    800059ea:	070cb783          	ld	a5,112(s9)
    800059ee:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800059f2:	85ee                	mv	a1,s11
    800059f4:	ffffd097          	auipc	ra,0xffffd
    800059f8:	816080e7          	jalr	-2026(ra) # 8000220a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800059fc:	0004851b          	sext.w	a0,s1
    80005a00:	b331                	j	8000570c <exec+0xa0>
  ip = 0;
    80005a02:	4901                	li	s2,0
    80005a04:	bd69                	j	8000589e <exec+0x232>
    80005a06:	4901                	li	s2,0
    80005a08:	bd59                	j	8000589e <exec+0x232>
    80005a0a:	4901                	li	s2,0
    80005a0c:	bd49                	j	8000589e <exec+0x232>

0000000080005a0e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005a0e:	7179                	addi	sp,sp,-48
    80005a10:	f406                	sd	ra,40(sp)
    80005a12:	f022                	sd	s0,32(sp)
    80005a14:	ec26                	sd	s1,24(sp)
    80005a16:	e84a                	sd	s2,16(sp)
    80005a18:	1800                	addi	s0,sp,48
    80005a1a:	892e                	mv	s2,a1
    80005a1c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005a1e:	fdc40593          	addi	a1,s0,-36
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	9d2080e7          	jalr	-1582(ra) # 800033f4 <argint>
    80005a2a:	04054063          	bltz	a0,80005a6a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005a2e:	fdc42703          	lw	a4,-36(s0)
    80005a32:	47bd                	li	a5,15
    80005a34:	02e7ed63          	bltu	a5,a4,80005a6e <argfd+0x60>
    80005a38:	ffffc097          	auipc	ra,0xffffc
    80005a3c:	608080e7          	jalr	1544(ra) # 80002040 <myproc>
    80005a40:	fdc42703          	lw	a4,-36(s0)
    80005a44:	01c70793          	addi	a5,a4,28
    80005a48:	078e                	slli	a5,a5,0x3
    80005a4a:	953e                	add	a0,a0,a5
    80005a4c:	651c                	ld	a5,8(a0)
    80005a4e:	c395                	beqz	a5,80005a72 <argfd+0x64>
    return -1;
  if(pfd)
    80005a50:	00090463          	beqz	s2,80005a58 <argfd+0x4a>
    *pfd = fd;
    80005a54:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005a58:	4501                	li	a0,0
  if(pf)
    80005a5a:	c091                	beqz	s1,80005a5e <argfd+0x50>
    *pf = f;
    80005a5c:	e09c                	sd	a5,0(s1)
}
    80005a5e:	70a2                	ld	ra,40(sp)
    80005a60:	7402                	ld	s0,32(sp)
    80005a62:	64e2                	ld	s1,24(sp)
    80005a64:	6942                	ld	s2,16(sp)
    80005a66:	6145                	addi	sp,sp,48
    80005a68:	8082                	ret
    return -1;
    80005a6a:	557d                	li	a0,-1
    80005a6c:	bfcd                	j	80005a5e <argfd+0x50>
    return -1;
    80005a6e:	557d                	li	a0,-1
    80005a70:	b7fd                	j	80005a5e <argfd+0x50>
    80005a72:	557d                	li	a0,-1
    80005a74:	b7ed                	j	80005a5e <argfd+0x50>

0000000080005a76 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005a76:	1101                	addi	sp,sp,-32
    80005a78:	ec06                	sd	ra,24(sp)
    80005a7a:	e822                	sd	s0,16(sp)
    80005a7c:	e426                	sd	s1,8(sp)
    80005a7e:	1000                	addi	s0,sp,32
    80005a80:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005a82:	ffffc097          	auipc	ra,0xffffc
    80005a86:	5be080e7          	jalr	1470(ra) # 80002040 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    80005a8a:	757c                	ld	a5,232(a0)
    80005a8c:	c395                	beqz	a5,80005ab0 <fdalloc+0x3a>
    80005a8e:	0f050713          	addi	a4,a0,240
  for(fd = 0; fd < NOFILE; fd++){
    80005a92:	4785                	li	a5,1
    80005a94:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    80005a96:	6314                	ld	a3,0(a4)
    80005a98:	ce89                	beqz	a3,80005ab2 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    80005a9a:	2785                	addiw	a5,a5,1
    80005a9c:	0721                	addi	a4,a4,8
    80005a9e:	fec79ce3          	bne	a5,a2,80005a96 <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005aa2:	57fd                	li	a5,-1
}
    80005aa4:	853e                	mv	a0,a5
    80005aa6:	60e2                	ld	ra,24(sp)
    80005aa8:	6442                	ld	s0,16(sp)
    80005aaa:	64a2                	ld	s1,8(sp)
    80005aac:	6105                	addi	sp,sp,32
    80005aae:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005ab0:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005ab2:	01c78713          	addi	a4,a5,28
    80005ab6:	070e                	slli	a4,a4,0x3
    80005ab8:	953a                	add	a0,a0,a4
    80005aba:	e504                	sd	s1,8(a0)
      return fd;
    80005abc:	b7e5                	j	80005aa4 <fdalloc+0x2e>

0000000080005abe <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005abe:	715d                	addi	sp,sp,-80
    80005ac0:	e486                	sd	ra,72(sp)
    80005ac2:	e0a2                	sd	s0,64(sp)
    80005ac4:	fc26                	sd	s1,56(sp)
    80005ac6:	f84a                	sd	s2,48(sp)
    80005ac8:	f44e                	sd	s3,40(sp)
    80005aca:	f052                	sd	s4,32(sp)
    80005acc:	ec56                	sd	s5,24(sp)
    80005ace:	0880                	addi	s0,sp,80
    80005ad0:	89ae                	mv	s3,a1
    80005ad2:	8ab2                	mv	s5,a2
    80005ad4:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005ad6:	fb040593          	addi	a1,s0,-80
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	cea080e7          	jalr	-790(ra) # 800047c4 <nameiparent>
    80005ae2:	892a                	mv	s2,a0
    80005ae4:	12050f63          	beqz	a0,80005c22 <create+0x164>
    return 0;

  ilock(dp);
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	52a080e7          	jalr	1322(ra) # 80004012 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005af0:	4601                	li	a2,0
    80005af2:	fb040593          	addi	a1,s0,-80
    80005af6:	854a                	mv	a0,s2
    80005af8:	fffff097          	auipc	ra,0xfffff
    80005afc:	9d4080e7          	jalr	-1580(ra) # 800044cc <dirlookup>
    80005b00:	84aa                	mv	s1,a0
    80005b02:	c921                	beqz	a0,80005b52 <create+0x94>
    iunlockput(dp);
    80005b04:	854a                	mv	a0,s2
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	74c080e7          	jalr	1868(ra) # 80004252 <iunlockput>
    ilock(ip);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	502080e7          	jalr	1282(ra) # 80004012 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005b18:	2981                	sext.w	s3,s3
    80005b1a:	4789                	li	a5,2
    80005b1c:	02f99463          	bne	s3,a5,80005b44 <create+0x86>
    80005b20:	05c4d783          	lhu	a5,92(s1)
    80005b24:	37f9                	addiw	a5,a5,-2
    80005b26:	17c2                	slli	a5,a5,0x30
    80005b28:	93c1                	srli	a5,a5,0x30
    80005b2a:	4705                	li	a4,1
    80005b2c:	00f76c63          	bltu	a4,a5,80005b44 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005b30:	8526                	mv	a0,s1
    80005b32:	60a6                	ld	ra,72(sp)
    80005b34:	6406                	ld	s0,64(sp)
    80005b36:	74e2                	ld	s1,56(sp)
    80005b38:	7942                	ld	s2,48(sp)
    80005b3a:	79a2                	ld	s3,40(sp)
    80005b3c:	7a02                	ld	s4,32(sp)
    80005b3e:	6ae2                	ld	s5,24(sp)
    80005b40:	6161                	addi	sp,sp,80
    80005b42:	8082                	ret
    iunlockput(ip);
    80005b44:	8526                	mv	a0,s1
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	70c080e7          	jalr	1804(ra) # 80004252 <iunlockput>
    return 0;
    80005b4e:	4481                	li	s1,0
    80005b50:	b7c5                	j	80005b30 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005b52:	85ce                	mv	a1,s3
    80005b54:	00092503          	lw	a0,0(s2)
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	31e080e7          	jalr	798(ra) # 80003e76 <ialloc>
    80005b60:	84aa                	mv	s1,a0
    80005b62:	c529                	beqz	a0,80005bac <create+0xee>
  ilock(ip);
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	4ae080e7          	jalr	1198(ra) # 80004012 <ilock>
  ip->major = major;
    80005b6c:	05549f23          	sh	s5,94(s1)
  ip->minor = minor;
    80005b70:	07449023          	sh	s4,96(s1)
  ip->nlink = 1;
    80005b74:	4785                	li	a5,1
    80005b76:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005b7a:	8526                	mv	a0,s1
    80005b7c:	ffffe097          	auipc	ra,0xffffe
    80005b80:	3ca080e7          	jalr	970(ra) # 80003f46 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005b84:	2981                	sext.w	s3,s3
    80005b86:	4785                	li	a5,1
    80005b88:	02f98a63          	beq	s3,a5,80005bbc <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005b8c:	40d0                	lw	a2,4(s1)
    80005b8e:	fb040593          	addi	a1,s0,-80
    80005b92:	854a                	mv	a0,s2
    80005b94:	fffff097          	auipc	ra,0xfffff
    80005b98:	b50080e7          	jalr	-1200(ra) # 800046e4 <dirlink>
    80005b9c:	06054b63          	bltz	a0,80005c12 <create+0x154>
  iunlockput(dp);
    80005ba0:	854a                	mv	a0,s2
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	6b0080e7          	jalr	1712(ra) # 80004252 <iunlockput>
  return ip;
    80005baa:	b759                	j	80005b30 <create+0x72>
    panic("create: ialloc");
    80005bac:	00003517          	auipc	a0,0x3
    80005bb0:	09c50513          	addi	a0,a0,156 # 80008c48 <userret+0xbb8>
    80005bb4:	ffffb097          	auipc	ra,0xffffb
    80005bb8:	bd0080e7          	jalr	-1072(ra) # 80000784 <panic>
    dp->nlink++;  // for ".."
    80005bbc:	06295783          	lhu	a5,98(s2)
    80005bc0:	2785                	addiw	a5,a5,1
    80005bc2:	06f91123          	sh	a5,98(s2)
    iupdate(dp);
    80005bc6:	854a                	mv	a0,s2
    80005bc8:	ffffe097          	auipc	ra,0xffffe
    80005bcc:	37e080e7          	jalr	894(ra) # 80003f46 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005bd0:	40d0                	lw	a2,4(s1)
    80005bd2:	00003597          	auipc	a1,0x3
    80005bd6:	08658593          	addi	a1,a1,134 # 80008c58 <userret+0xbc8>
    80005bda:	8526                	mv	a0,s1
    80005bdc:	fffff097          	auipc	ra,0xfffff
    80005be0:	b08080e7          	jalr	-1272(ra) # 800046e4 <dirlink>
    80005be4:	00054f63          	bltz	a0,80005c02 <create+0x144>
    80005be8:	00492603          	lw	a2,4(s2)
    80005bec:	00003597          	auipc	a1,0x3
    80005bf0:	07458593          	addi	a1,a1,116 # 80008c60 <userret+0xbd0>
    80005bf4:	8526                	mv	a0,s1
    80005bf6:	fffff097          	auipc	ra,0xfffff
    80005bfa:	aee080e7          	jalr	-1298(ra) # 800046e4 <dirlink>
    80005bfe:	f80557e3          	bgez	a0,80005b8c <create+0xce>
      panic("create dots");
    80005c02:	00003517          	auipc	a0,0x3
    80005c06:	06650513          	addi	a0,a0,102 # 80008c68 <userret+0xbd8>
    80005c0a:	ffffb097          	auipc	ra,0xffffb
    80005c0e:	b7a080e7          	jalr	-1158(ra) # 80000784 <panic>
    panic("create: dirlink");
    80005c12:	00003517          	auipc	a0,0x3
    80005c16:	06650513          	addi	a0,a0,102 # 80008c78 <userret+0xbe8>
    80005c1a:	ffffb097          	auipc	ra,0xffffb
    80005c1e:	b6a080e7          	jalr	-1174(ra) # 80000784 <panic>
    return 0;
    80005c22:	84aa                	mv	s1,a0
    80005c24:	b731                	j	80005b30 <create+0x72>

0000000080005c26 <sys_dup>:
{
    80005c26:	7179                	addi	sp,sp,-48
    80005c28:	f406                	sd	ra,40(sp)
    80005c2a:	f022                	sd	s0,32(sp)
    80005c2c:	ec26                	sd	s1,24(sp)
    80005c2e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005c30:	fd840613          	addi	a2,s0,-40
    80005c34:	4581                	li	a1,0
    80005c36:	4501                	li	a0,0
    80005c38:	00000097          	auipc	ra,0x0
    80005c3c:	dd6080e7          	jalr	-554(ra) # 80005a0e <argfd>
    return -1;
    80005c40:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005c42:	02054363          	bltz	a0,80005c68 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005c46:	fd843503          	ld	a0,-40(s0)
    80005c4a:	00000097          	auipc	ra,0x0
    80005c4e:	e2c080e7          	jalr	-468(ra) # 80005a76 <fdalloc>
    80005c52:	84aa                	mv	s1,a0
    return -1;
    80005c54:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005c56:	00054963          	bltz	a0,80005c68 <sys_dup+0x42>
  filedup(f);
    80005c5a:	fd843503          	ld	a0,-40(s0)
    80005c5e:	fffff097          	auipc	ra,0xfffff
    80005c62:	2f8080e7          	jalr	760(ra) # 80004f56 <filedup>
  return fd;
    80005c66:	87a6                	mv	a5,s1
}
    80005c68:	853e                	mv	a0,a5
    80005c6a:	70a2                	ld	ra,40(sp)
    80005c6c:	7402                	ld	s0,32(sp)
    80005c6e:	64e2                	ld	s1,24(sp)
    80005c70:	6145                	addi	sp,sp,48
    80005c72:	8082                	ret

0000000080005c74 <sys_read>:
{
    80005c74:	7179                	addi	sp,sp,-48
    80005c76:	f406                	sd	ra,40(sp)
    80005c78:	f022                	sd	s0,32(sp)
    80005c7a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c7c:	fe840613          	addi	a2,s0,-24
    80005c80:	4581                	li	a1,0
    80005c82:	4501                	li	a0,0
    80005c84:	00000097          	auipc	ra,0x0
    80005c88:	d8a080e7          	jalr	-630(ra) # 80005a0e <argfd>
    return -1;
    80005c8c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005c8e:	04054163          	bltz	a0,80005cd0 <sys_read+0x5c>
    80005c92:	fe440593          	addi	a1,s0,-28
    80005c96:	4509                	li	a0,2
    80005c98:	ffffd097          	auipc	ra,0xffffd
    80005c9c:	75c080e7          	jalr	1884(ra) # 800033f4 <argint>
    return -1;
    80005ca0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ca2:	02054763          	bltz	a0,80005cd0 <sys_read+0x5c>
    80005ca6:	fd840593          	addi	a1,s0,-40
    80005caa:	4505                	li	a0,1
    80005cac:	ffffd097          	auipc	ra,0xffffd
    80005cb0:	76a080e7          	jalr	1898(ra) # 80003416 <argaddr>
    return -1;
    80005cb4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005cb6:	00054d63          	bltz	a0,80005cd0 <sys_read+0x5c>
  return fileread(f, p, n);
    80005cba:	fe442603          	lw	a2,-28(s0)
    80005cbe:	fd843583          	ld	a1,-40(s0)
    80005cc2:	fe843503          	ld	a0,-24(s0)
    80005cc6:	fffff097          	auipc	ra,0xfffff
    80005cca:	424080e7          	jalr	1060(ra) # 800050ea <fileread>
    80005cce:	87aa                	mv	a5,a0
}
    80005cd0:	853e                	mv	a0,a5
    80005cd2:	70a2                	ld	ra,40(sp)
    80005cd4:	7402                	ld	s0,32(sp)
    80005cd6:	6145                	addi	sp,sp,48
    80005cd8:	8082                	ret

0000000080005cda <sys_write>:
{
    80005cda:	7179                	addi	sp,sp,-48
    80005cdc:	f406                	sd	ra,40(sp)
    80005cde:	f022                	sd	s0,32(sp)
    80005ce0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005ce2:	fe840613          	addi	a2,s0,-24
    80005ce6:	4581                	li	a1,0
    80005ce8:	4501                	li	a0,0
    80005cea:	00000097          	auipc	ra,0x0
    80005cee:	d24080e7          	jalr	-732(ra) # 80005a0e <argfd>
    return -1;
    80005cf2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005cf4:	04054163          	bltz	a0,80005d36 <sys_write+0x5c>
    80005cf8:	fe440593          	addi	a1,s0,-28
    80005cfc:	4509                	li	a0,2
    80005cfe:	ffffd097          	auipc	ra,0xffffd
    80005d02:	6f6080e7          	jalr	1782(ra) # 800033f4 <argint>
    return -1;
    80005d06:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005d08:	02054763          	bltz	a0,80005d36 <sys_write+0x5c>
    80005d0c:	fd840593          	addi	a1,s0,-40
    80005d10:	4505                	li	a0,1
    80005d12:	ffffd097          	auipc	ra,0xffffd
    80005d16:	704080e7          	jalr	1796(ra) # 80003416 <argaddr>
    return -1;
    80005d1a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005d1c:	00054d63          	bltz	a0,80005d36 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005d20:	fe442603          	lw	a2,-28(s0)
    80005d24:	fd843583          	ld	a1,-40(s0)
    80005d28:	fe843503          	ld	a0,-24(s0)
    80005d2c:	fffff097          	auipc	ra,0xfffff
    80005d30:	484080e7          	jalr	1156(ra) # 800051b0 <filewrite>
    80005d34:	87aa                	mv	a5,a0
}
    80005d36:	853e                	mv	a0,a5
    80005d38:	70a2                	ld	ra,40(sp)
    80005d3a:	7402                	ld	s0,32(sp)
    80005d3c:	6145                	addi	sp,sp,48
    80005d3e:	8082                	ret

0000000080005d40 <sys_close>:
{
    80005d40:	1101                	addi	sp,sp,-32
    80005d42:	ec06                	sd	ra,24(sp)
    80005d44:	e822                	sd	s0,16(sp)
    80005d46:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005d48:	fe040613          	addi	a2,s0,-32
    80005d4c:	fec40593          	addi	a1,s0,-20
    80005d50:	4501                	li	a0,0
    80005d52:	00000097          	auipc	ra,0x0
    80005d56:	cbc080e7          	jalr	-836(ra) # 80005a0e <argfd>
    return -1;
    80005d5a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005d5c:	02054463          	bltz	a0,80005d84 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005d60:	ffffc097          	auipc	ra,0xffffc
    80005d64:	2e0080e7          	jalr	736(ra) # 80002040 <myproc>
    80005d68:	fec42783          	lw	a5,-20(s0)
    80005d6c:	07f1                	addi	a5,a5,28
    80005d6e:	078e                	slli	a5,a5,0x3
    80005d70:	953e                	add	a0,a0,a5
    80005d72:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005d76:	fe043503          	ld	a0,-32(s0)
    80005d7a:	fffff097          	auipc	ra,0xfffff
    80005d7e:	22e080e7          	jalr	558(ra) # 80004fa8 <fileclose>
  return 0;
    80005d82:	4781                	li	a5,0
}
    80005d84:	853e                	mv	a0,a5
    80005d86:	60e2                	ld	ra,24(sp)
    80005d88:	6442                	ld	s0,16(sp)
    80005d8a:	6105                	addi	sp,sp,32
    80005d8c:	8082                	ret

0000000080005d8e <sys_fstat>:
{
    80005d8e:	1101                	addi	sp,sp,-32
    80005d90:	ec06                	sd	ra,24(sp)
    80005d92:	e822                	sd	s0,16(sp)
    80005d94:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005d96:	fe840613          	addi	a2,s0,-24
    80005d9a:	4581                	li	a1,0
    80005d9c:	4501                	li	a0,0
    80005d9e:	00000097          	auipc	ra,0x0
    80005da2:	c70080e7          	jalr	-912(ra) # 80005a0e <argfd>
    return -1;
    80005da6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005da8:	02054563          	bltz	a0,80005dd2 <sys_fstat+0x44>
    80005dac:	fe040593          	addi	a1,s0,-32
    80005db0:	4505                	li	a0,1
    80005db2:	ffffd097          	auipc	ra,0xffffd
    80005db6:	664080e7          	jalr	1636(ra) # 80003416 <argaddr>
    return -1;
    80005dba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005dbc:	00054b63          	bltz	a0,80005dd2 <sys_fstat+0x44>
  return filestat(f, st);
    80005dc0:	fe043583          	ld	a1,-32(s0)
    80005dc4:	fe843503          	ld	a0,-24(s0)
    80005dc8:	fffff097          	auipc	ra,0xfffff
    80005dcc:	2b0080e7          	jalr	688(ra) # 80005078 <filestat>
    80005dd0:	87aa                	mv	a5,a0
}
    80005dd2:	853e                	mv	a0,a5
    80005dd4:	60e2                	ld	ra,24(sp)
    80005dd6:	6442                	ld	s0,16(sp)
    80005dd8:	6105                	addi	sp,sp,32
    80005dda:	8082                	ret

0000000080005ddc <sys_link>:
{
    80005ddc:	7169                	addi	sp,sp,-304
    80005dde:	f606                	sd	ra,296(sp)
    80005de0:	f222                	sd	s0,288(sp)
    80005de2:	ee26                	sd	s1,280(sp)
    80005de4:	ea4a                	sd	s2,272(sp)
    80005de6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005de8:	08000613          	li	a2,128
    80005dec:	ed040593          	addi	a1,s0,-304
    80005df0:	4501                	li	a0,0
    80005df2:	ffffd097          	auipc	ra,0xffffd
    80005df6:	646080e7          	jalr	1606(ra) # 80003438 <argstr>
    return -1;
    80005dfa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005dfc:	12054363          	bltz	a0,80005f22 <sys_link+0x146>
    80005e00:	08000613          	li	a2,128
    80005e04:	f5040593          	addi	a1,s0,-176
    80005e08:	4505                	li	a0,1
    80005e0a:	ffffd097          	auipc	ra,0xffffd
    80005e0e:	62e080e7          	jalr	1582(ra) # 80003438 <argstr>
    return -1;
    80005e12:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005e14:	10054763          	bltz	a0,80005f22 <sys_link+0x146>
  begin_op(ROOTDEV);
    80005e18:	4501                	li	a0,0
    80005e1a:	fffff097          	auipc	ra,0xfffff
    80005e1e:	bd2080e7          	jalr	-1070(ra) # 800049ec <begin_op>
  if((ip = namei(old)) == 0){
    80005e22:	ed040513          	addi	a0,s0,-304
    80005e26:	fffff097          	auipc	ra,0xfffff
    80005e2a:	980080e7          	jalr	-1664(ra) # 800047a6 <namei>
    80005e2e:	84aa                	mv	s1,a0
    80005e30:	c559                	beqz	a0,80005ebe <sys_link+0xe2>
  ilock(ip);
    80005e32:	ffffe097          	auipc	ra,0xffffe
    80005e36:	1e0080e7          	jalr	480(ra) # 80004012 <ilock>
  if(ip->type == T_DIR){
    80005e3a:	05c49703          	lh	a4,92(s1)
    80005e3e:	4785                	li	a5,1
    80005e40:	08f70663          	beq	a4,a5,80005ecc <sys_link+0xf0>
  ip->nlink++;
    80005e44:	0624d783          	lhu	a5,98(s1)
    80005e48:	2785                	addiw	a5,a5,1
    80005e4a:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005e4e:	8526                	mv	a0,s1
    80005e50:	ffffe097          	auipc	ra,0xffffe
    80005e54:	0f6080e7          	jalr	246(ra) # 80003f46 <iupdate>
  iunlock(ip);
    80005e58:	8526                	mv	a0,s1
    80005e5a:	ffffe097          	auipc	ra,0xffffe
    80005e5e:	27c080e7          	jalr	636(ra) # 800040d6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005e62:	fd040593          	addi	a1,s0,-48
    80005e66:	f5040513          	addi	a0,s0,-176
    80005e6a:	fffff097          	auipc	ra,0xfffff
    80005e6e:	95a080e7          	jalr	-1702(ra) # 800047c4 <nameiparent>
    80005e72:	892a                	mv	s2,a0
    80005e74:	cd2d                	beqz	a0,80005eee <sys_link+0x112>
  ilock(dp);
    80005e76:	ffffe097          	auipc	ra,0xffffe
    80005e7a:	19c080e7          	jalr	412(ra) # 80004012 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005e7e:	00092703          	lw	a4,0(s2)
    80005e82:	409c                	lw	a5,0(s1)
    80005e84:	06f71063          	bne	a4,a5,80005ee4 <sys_link+0x108>
    80005e88:	40d0                	lw	a2,4(s1)
    80005e8a:	fd040593          	addi	a1,s0,-48
    80005e8e:	854a                	mv	a0,s2
    80005e90:	fffff097          	auipc	ra,0xfffff
    80005e94:	854080e7          	jalr	-1964(ra) # 800046e4 <dirlink>
    80005e98:	04054663          	bltz	a0,80005ee4 <sys_link+0x108>
  iunlockput(dp);
    80005e9c:	854a                	mv	a0,s2
    80005e9e:	ffffe097          	auipc	ra,0xffffe
    80005ea2:	3b4080e7          	jalr	948(ra) # 80004252 <iunlockput>
  iput(ip);
    80005ea6:	8526                	mv	a0,s1
    80005ea8:	ffffe097          	auipc	ra,0xffffe
    80005eac:	27a080e7          	jalr	634(ra) # 80004122 <iput>
  end_op(ROOTDEV);
    80005eb0:	4501                	li	a0,0
    80005eb2:	fffff097          	auipc	ra,0xfffff
    80005eb6:	be6080e7          	jalr	-1050(ra) # 80004a98 <end_op>
  return 0;
    80005eba:	4781                	li	a5,0
    80005ebc:	a09d                	j	80005f22 <sys_link+0x146>
    end_op(ROOTDEV);
    80005ebe:	4501                	li	a0,0
    80005ec0:	fffff097          	auipc	ra,0xfffff
    80005ec4:	bd8080e7          	jalr	-1064(ra) # 80004a98 <end_op>
    return -1;
    80005ec8:	57fd                	li	a5,-1
    80005eca:	a8a1                	j	80005f22 <sys_link+0x146>
    iunlockput(ip);
    80005ecc:	8526                	mv	a0,s1
    80005ece:	ffffe097          	auipc	ra,0xffffe
    80005ed2:	384080e7          	jalr	900(ra) # 80004252 <iunlockput>
    end_op(ROOTDEV);
    80005ed6:	4501                	li	a0,0
    80005ed8:	fffff097          	auipc	ra,0xfffff
    80005edc:	bc0080e7          	jalr	-1088(ra) # 80004a98 <end_op>
    return -1;
    80005ee0:	57fd                	li	a5,-1
    80005ee2:	a081                	j	80005f22 <sys_link+0x146>
    iunlockput(dp);
    80005ee4:	854a                	mv	a0,s2
    80005ee6:	ffffe097          	auipc	ra,0xffffe
    80005eea:	36c080e7          	jalr	876(ra) # 80004252 <iunlockput>
  ilock(ip);
    80005eee:	8526                	mv	a0,s1
    80005ef0:	ffffe097          	auipc	ra,0xffffe
    80005ef4:	122080e7          	jalr	290(ra) # 80004012 <ilock>
  ip->nlink--;
    80005ef8:	0624d783          	lhu	a5,98(s1)
    80005efc:	37fd                	addiw	a5,a5,-1
    80005efe:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80005f02:	8526                	mv	a0,s1
    80005f04:	ffffe097          	auipc	ra,0xffffe
    80005f08:	042080e7          	jalr	66(ra) # 80003f46 <iupdate>
  iunlockput(ip);
    80005f0c:	8526                	mv	a0,s1
    80005f0e:	ffffe097          	auipc	ra,0xffffe
    80005f12:	344080e7          	jalr	836(ra) # 80004252 <iunlockput>
  end_op(ROOTDEV);
    80005f16:	4501                	li	a0,0
    80005f18:	fffff097          	auipc	ra,0xfffff
    80005f1c:	b80080e7          	jalr	-1152(ra) # 80004a98 <end_op>
  return -1;
    80005f20:	57fd                	li	a5,-1
}
    80005f22:	853e                	mv	a0,a5
    80005f24:	70b2                	ld	ra,296(sp)
    80005f26:	7412                	ld	s0,288(sp)
    80005f28:	64f2                	ld	s1,280(sp)
    80005f2a:	6952                	ld	s2,272(sp)
    80005f2c:	6155                	addi	sp,sp,304
    80005f2e:	8082                	ret

0000000080005f30 <sys_unlink>:
{
    80005f30:	7151                	addi	sp,sp,-240
    80005f32:	f586                	sd	ra,232(sp)
    80005f34:	f1a2                	sd	s0,224(sp)
    80005f36:	eda6                	sd	s1,216(sp)
    80005f38:	e9ca                	sd	s2,208(sp)
    80005f3a:	e5ce                	sd	s3,200(sp)
    80005f3c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005f3e:	08000613          	li	a2,128
    80005f42:	f3040593          	addi	a1,s0,-208
    80005f46:	4501                	li	a0,0
    80005f48:	ffffd097          	auipc	ra,0xffffd
    80005f4c:	4f0080e7          	jalr	1264(ra) # 80003438 <argstr>
    80005f50:	18054263          	bltz	a0,800060d4 <sys_unlink+0x1a4>
  begin_op(ROOTDEV);
    80005f54:	4501                	li	a0,0
    80005f56:	fffff097          	auipc	ra,0xfffff
    80005f5a:	a96080e7          	jalr	-1386(ra) # 800049ec <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005f5e:	fb040593          	addi	a1,s0,-80
    80005f62:	f3040513          	addi	a0,s0,-208
    80005f66:	fffff097          	auipc	ra,0xfffff
    80005f6a:	85e080e7          	jalr	-1954(ra) # 800047c4 <nameiparent>
    80005f6e:	89aa                	mv	s3,a0
    80005f70:	cd61                	beqz	a0,80006048 <sys_unlink+0x118>
  ilock(dp);
    80005f72:	ffffe097          	auipc	ra,0xffffe
    80005f76:	0a0080e7          	jalr	160(ra) # 80004012 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005f7a:	00003597          	auipc	a1,0x3
    80005f7e:	cde58593          	addi	a1,a1,-802 # 80008c58 <userret+0xbc8>
    80005f82:	fb040513          	addi	a0,s0,-80
    80005f86:	ffffe097          	auipc	ra,0xffffe
    80005f8a:	52c080e7          	jalr	1324(ra) # 800044b2 <namecmp>
    80005f8e:	14050a63          	beqz	a0,800060e2 <sys_unlink+0x1b2>
    80005f92:	00003597          	auipc	a1,0x3
    80005f96:	cce58593          	addi	a1,a1,-818 # 80008c60 <userret+0xbd0>
    80005f9a:	fb040513          	addi	a0,s0,-80
    80005f9e:	ffffe097          	auipc	ra,0xffffe
    80005fa2:	514080e7          	jalr	1300(ra) # 800044b2 <namecmp>
    80005fa6:	12050e63          	beqz	a0,800060e2 <sys_unlink+0x1b2>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005faa:	f2c40613          	addi	a2,s0,-212
    80005fae:	fb040593          	addi	a1,s0,-80
    80005fb2:	854e                	mv	a0,s3
    80005fb4:	ffffe097          	auipc	ra,0xffffe
    80005fb8:	518080e7          	jalr	1304(ra) # 800044cc <dirlookup>
    80005fbc:	84aa                	mv	s1,a0
    80005fbe:	12050263          	beqz	a0,800060e2 <sys_unlink+0x1b2>
  ilock(ip);
    80005fc2:	ffffe097          	auipc	ra,0xffffe
    80005fc6:	050080e7          	jalr	80(ra) # 80004012 <ilock>
  if(ip->nlink < 1)
    80005fca:	06249783          	lh	a5,98(s1)
    80005fce:	08f05463          	blez	a5,80006056 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005fd2:	05c49703          	lh	a4,92(s1)
    80005fd6:	4785                	li	a5,1
    80005fd8:	08f70763          	beq	a4,a5,80006066 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005fdc:	4641                	li	a2,16
    80005fde:	4581                	li	a1,0
    80005fe0:	fc040513          	addi	a0,s0,-64
    80005fe4:	ffffb097          	auipc	ra,0xffffb
    80005fe8:	14a080e7          	jalr	330(ra) # 8000112e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005fec:	4741                	li	a4,16
    80005fee:	f2c42683          	lw	a3,-212(s0)
    80005ff2:	fc040613          	addi	a2,s0,-64
    80005ff6:	4581                	li	a1,0
    80005ff8:	854e                	mv	a0,s3
    80005ffa:	ffffe097          	auipc	ra,0xffffe
    80005ffe:	39e080e7          	jalr	926(ra) # 80004398 <writei>
    80006002:	47c1                	li	a5,16
    80006004:	0af51563          	bne	a0,a5,800060ae <sys_unlink+0x17e>
  if(ip->type == T_DIR){
    80006008:	05c49703          	lh	a4,92(s1)
    8000600c:	4785                	li	a5,1
    8000600e:	0af70863          	beq	a4,a5,800060be <sys_unlink+0x18e>
  iunlockput(dp);
    80006012:	854e                	mv	a0,s3
    80006014:	ffffe097          	auipc	ra,0xffffe
    80006018:	23e080e7          	jalr	574(ra) # 80004252 <iunlockput>
  ip->nlink--;
    8000601c:	0624d783          	lhu	a5,98(s1)
    80006020:	37fd                	addiw	a5,a5,-1
    80006022:	06f49123          	sh	a5,98(s1)
  iupdate(ip);
    80006026:	8526                	mv	a0,s1
    80006028:	ffffe097          	auipc	ra,0xffffe
    8000602c:	f1e080e7          	jalr	-226(ra) # 80003f46 <iupdate>
  iunlockput(ip);
    80006030:	8526                	mv	a0,s1
    80006032:	ffffe097          	auipc	ra,0xffffe
    80006036:	220080e7          	jalr	544(ra) # 80004252 <iunlockput>
  end_op(ROOTDEV);
    8000603a:	4501                	li	a0,0
    8000603c:	fffff097          	auipc	ra,0xfffff
    80006040:	a5c080e7          	jalr	-1444(ra) # 80004a98 <end_op>
  return 0;
    80006044:	4501                	li	a0,0
    80006046:	a84d                	j	800060f8 <sys_unlink+0x1c8>
    end_op(ROOTDEV);
    80006048:	4501                	li	a0,0
    8000604a:	fffff097          	auipc	ra,0xfffff
    8000604e:	a4e080e7          	jalr	-1458(ra) # 80004a98 <end_op>
    return -1;
    80006052:	557d                	li	a0,-1
    80006054:	a055                	j	800060f8 <sys_unlink+0x1c8>
    panic("unlink: nlink < 1");
    80006056:	00003517          	auipc	a0,0x3
    8000605a:	c3250513          	addi	a0,a0,-974 # 80008c88 <userret+0xbf8>
    8000605e:	ffffa097          	auipc	ra,0xffffa
    80006062:	726080e7          	jalr	1830(ra) # 80000784 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006066:	50f8                	lw	a4,100(s1)
    80006068:	02000793          	li	a5,32
    8000606c:	f6e7f8e3          	bleu	a4,a5,80005fdc <sys_unlink+0xac>
    80006070:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006074:	4741                	li	a4,16
    80006076:	86ca                	mv	a3,s2
    80006078:	f1840613          	addi	a2,s0,-232
    8000607c:	4581                	li	a1,0
    8000607e:	8526                	mv	a0,s1
    80006080:	ffffe097          	auipc	ra,0xffffe
    80006084:	224080e7          	jalr	548(ra) # 800042a4 <readi>
    80006088:	47c1                	li	a5,16
    8000608a:	00f51a63          	bne	a0,a5,8000609e <sys_unlink+0x16e>
    if(de.inum != 0)
    8000608e:	f1845783          	lhu	a5,-232(s0)
    80006092:	e3b9                	bnez	a5,800060d8 <sys_unlink+0x1a8>
    80006094:	2941                	addiw	s2,s2,16
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006096:	50fc                	lw	a5,100(s1)
    80006098:	fcf96ee3          	bltu	s2,a5,80006074 <sys_unlink+0x144>
    8000609c:	b781                	j	80005fdc <sys_unlink+0xac>
      panic("isdirempty: readi");
    8000609e:	00003517          	auipc	a0,0x3
    800060a2:	c0250513          	addi	a0,a0,-1022 # 80008ca0 <userret+0xc10>
    800060a6:	ffffa097          	auipc	ra,0xffffa
    800060aa:	6de080e7          	jalr	1758(ra) # 80000784 <panic>
    panic("unlink: writei");
    800060ae:	00003517          	auipc	a0,0x3
    800060b2:	c0a50513          	addi	a0,a0,-1014 # 80008cb8 <userret+0xc28>
    800060b6:	ffffa097          	auipc	ra,0xffffa
    800060ba:	6ce080e7          	jalr	1742(ra) # 80000784 <panic>
    dp->nlink--;
    800060be:	0629d783          	lhu	a5,98(s3)
    800060c2:	37fd                	addiw	a5,a5,-1
    800060c4:	06f99123          	sh	a5,98(s3)
    iupdate(dp);
    800060c8:	854e                	mv	a0,s3
    800060ca:	ffffe097          	auipc	ra,0xffffe
    800060ce:	e7c080e7          	jalr	-388(ra) # 80003f46 <iupdate>
    800060d2:	b781                	j	80006012 <sys_unlink+0xe2>
    return -1;
    800060d4:	557d                	li	a0,-1
    800060d6:	a00d                	j	800060f8 <sys_unlink+0x1c8>
    iunlockput(ip);
    800060d8:	8526                	mv	a0,s1
    800060da:	ffffe097          	auipc	ra,0xffffe
    800060de:	178080e7          	jalr	376(ra) # 80004252 <iunlockput>
  iunlockput(dp);
    800060e2:	854e                	mv	a0,s3
    800060e4:	ffffe097          	auipc	ra,0xffffe
    800060e8:	16e080e7          	jalr	366(ra) # 80004252 <iunlockput>
  end_op(ROOTDEV);
    800060ec:	4501                	li	a0,0
    800060ee:	fffff097          	auipc	ra,0xfffff
    800060f2:	9aa080e7          	jalr	-1622(ra) # 80004a98 <end_op>
  return -1;
    800060f6:	557d                	li	a0,-1
}
    800060f8:	70ae                	ld	ra,232(sp)
    800060fa:	740e                	ld	s0,224(sp)
    800060fc:	64ee                	ld	s1,216(sp)
    800060fe:	694e                	ld	s2,208(sp)
    80006100:	69ae                	ld	s3,200(sp)
    80006102:	616d                	addi	sp,sp,240
    80006104:	8082                	ret

0000000080006106 <sys_open>:

uint64
sys_open(void)
{
    80006106:	7131                	addi	sp,sp,-192
    80006108:	fd06                	sd	ra,184(sp)
    8000610a:	f922                	sd	s0,176(sp)
    8000610c:	f526                	sd	s1,168(sp)
    8000610e:	f14a                	sd	s2,160(sp)
    80006110:	ed4e                	sd	s3,152(sp)
    80006112:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006114:	08000613          	li	a2,128
    80006118:	f5040593          	addi	a1,s0,-176
    8000611c:	4501                	li	a0,0
    8000611e:	ffffd097          	auipc	ra,0xffffd
    80006122:	31a080e7          	jalr	794(ra) # 80003438 <argstr>
    return -1;
    80006126:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006128:	0a054963          	bltz	a0,800061da <sys_open+0xd4>
    8000612c:	f4c40593          	addi	a1,s0,-180
    80006130:	4505                	li	a0,1
    80006132:	ffffd097          	auipc	ra,0xffffd
    80006136:	2c2080e7          	jalr	706(ra) # 800033f4 <argint>
    8000613a:	0a054063          	bltz	a0,800061da <sys_open+0xd4>

  begin_op(ROOTDEV);
    8000613e:	4501                	li	a0,0
    80006140:	fffff097          	auipc	ra,0xfffff
    80006144:	8ac080e7          	jalr	-1876(ra) # 800049ec <begin_op>

  if(omode & O_CREATE){
    80006148:	f4c42783          	lw	a5,-180(s0)
    8000614c:	2007f793          	andi	a5,a5,512
    80006150:	c3dd                	beqz	a5,800061f6 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80006152:	4681                	li	a3,0
    80006154:	4601                	li	a2,0
    80006156:	4589                	li	a1,2
    80006158:	f5040513          	addi	a0,s0,-176
    8000615c:	00000097          	auipc	ra,0x0
    80006160:	962080e7          	jalr	-1694(ra) # 80005abe <create>
    80006164:	892a                	mv	s2,a0
    if(ip == 0){
    80006166:	c151                	beqz	a0,800061ea <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006168:	05c91703          	lh	a4,92(s2)
    8000616c:	478d                	li	a5,3
    8000616e:	00f71763          	bne	a4,a5,8000617c <sys_open+0x76>
    80006172:	05e95703          	lhu	a4,94(s2)
    80006176:	47a5                	li	a5,9
    80006178:	0ce7e663          	bltu	a5,a4,80006244 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000617c:	fffff097          	auipc	ra,0xfffff
    80006180:	d5c080e7          	jalr	-676(ra) # 80004ed8 <filealloc>
    80006184:	89aa                	mv	s3,a0
    80006186:	c97d                	beqz	a0,8000627c <sys_open+0x176>
    80006188:	00000097          	auipc	ra,0x0
    8000618c:	8ee080e7          	jalr	-1810(ra) # 80005a76 <fdalloc>
    80006190:	84aa                	mv	s1,a0
    80006192:	0e054063          	bltz	a0,80006272 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006196:	05c91703          	lh	a4,92(s2)
    8000619a:	478d                	li	a5,3
    8000619c:	0cf70063          	beq	a4,a5,8000625c <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    800061a0:	4789                	li	a5,2
    800061a2:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    800061a6:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    800061aa:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    800061ae:	f4c42783          	lw	a5,-180(s0)
    800061b2:	0017c713          	xori	a4,a5,1
    800061b6:	8b05                	andi	a4,a4,1
    800061b8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800061bc:	8b8d                	andi	a5,a5,3
    800061be:	00f037b3          	snez	a5,a5
    800061c2:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    800061c6:	854a                	mv	a0,s2
    800061c8:	ffffe097          	auipc	ra,0xffffe
    800061cc:	f0e080e7          	jalr	-242(ra) # 800040d6 <iunlock>
  end_op(ROOTDEV);
    800061d0:	4501                	li	a0,0
    800061d2:	fffff097          	auipc	ra,0xfffff
    800061d6:	8c6080e7          	jalr	-1850(ra) # 80004a98 <end_op>

  return fd;
}
    800061da:	8526                	mv	a0,s1
    800061dc:	70ea                	ld	ra,184(sp)
    800061de:	744a                	ld	s0,176(sp)
    800061e0:	74aa                	ld	s1,168(sp)
    800061e2:	790a                	ld	s2,160(sp)
    800061e4:	69ea                	ld	s3,152(sp)
    800061e6:	6129                	addi	sp,sp,192
    800061e8:	8082                	ret
      end_op(ROOTDEV);
    800061ea:	4501                	li	a0,0
    800061ec:	fffff097          	auipc	ra,0xfffff
    800061f0:	8ac080e7          	jalr	-1876(ra) # 80004a98 <end_op>
      return -1;
    800061f4:	b7dd                	j	800061da <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    800061f6:	f5040513          	addi	a0,s0,-176
    800061fa:	ffffe097          	auipc	ra,0xffffe
    800061fe:	5ac080e7          	jalr	1452(ra) # 800047a6 <namei>
    80006202:	892a                	mv	s2,a0
    80006204:	c90d                	beqz	a0,80006236 <sys_open+0x130>
    ilock(ip);
    80006206:	ffffe097          	auipc	ra,0xffffe
    8000620a:	e0c080e7          	jalr	-500(ra) # 80004012 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000620e:	05c91703          	lh	a4,92(s2)
    80006212:	4785                	li	a5,1
    80006214:	f4f71ae3          	bne	a4,a5,80006168 <sys_open+0x62>
    80006218:	f4c42783          	lw	a5,-180(s0)
    8000621c:	d3a5                	beqz	a5,8000617c <sys_open+0x76>
      iunlockput(ip);
    8000621e:	854a                	mv	a0,s2
    80006220:	ffffe097          	auipc	ra,0xffffe
    80006224:	032080e7          	jalr	50(ra) # 80004252 <iunlockput>
      end_op(ROOTDEV);
    80006228:	4501                	li	a0,0
    8000622a:	fffff097          	auipc	ra,0xfffff
    8000622e:	86e080e7          	jalr	-1938(ra) # 80004a98 <end_op>
      return -1;
    80006232:	54fd                	li	s1,-1
    80006234:	b75d                	j	800061da <sys_open+0xd4>
      end_op(ROOTDEV);
    80006236:	4501                	li	a0,0
    80006238:	fffff097          	auipc	ra,0xfffff
    8000623c:	860080e7          	jalr	-1952(ra) # 80004a98 <end_op>
      return -1;
    80006240:	54fd                	li	s1,-1
    80006242:	bf61                	j	800061da <sys_open+0xd4>
    iunlockput(ip);
    80006244:	854a                	mv	a0,s2
    80006246:	ffffe097          	auipc	ra,0xffffe
    8000624a:	00c080e7          	jalr	12(ra) # 80004252 <iunlockput>
    end_op(ROOTDEV);
    8000624e:	4501                	li	a0,0
    80006250:	fffff097          	auipc	ra,0xfffff
    80006254:	848080e7          	jalr	-1976(ra) # 80004a98 <end_op>
    return -1;
    80006258:	54fd                	li	s1,-1
    8000625a:	b741                	j	800061da <sys_open+0xd4>
    f->type = FD_DEVICE;
    8000625c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006260:	05e91783          	lh	a5,94(s2)
    80006264:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80006268:	06091783          	lh	a5,96(s2)
    8000626c:	02f99323          	sh	a5,38(s3)
    80006270:	bf1d                	j	800061a6 <sys_open+0xa0>
      fileclose(f);
    80006272:	854e                	mv	a0,s3
    80006274:	fffff097          	auipc	ra,0xfffff
    80006278:	d34080e7          	jalr	-716(ra) # 80004fa8 <fileclose>
    iunlockput(ip);
    8000627c:	854a                	mv	a0,s2
    8000627e:	ffffe097          	auipc	ra,0xffffe
    80006282:	fd4080e7          	jalr	-44(ra) # 80004252 <iunlockput>
    end_op(ROOTDEV);
    80006286:	4501                	li	a0,0
    80006288:	fffff097          	auipc	ra,0xfffff
    8000628c:	810080e7          	jalr	-2032(ra) # 80004a98 <end_op>
    return -1;
    80006290:	54fd                	li	s1,-1
    80006292:	b7a1                	j	800061da <sys_open+0xd4>

0000000080006294 <sys_create_mutex>:

// Question 4-3
uint64
sys_create_mutex(void)
{
    80006294:	7131                	addi	sp,sp,-192
    80006296:	fd06                	sd	ra,184(sp)
    80006298:	f922                	sd	s0,176(sp)
    8000629a:	f526                	sd	s1,168(sp)
    8000629c:	f14a                	sd	s2,160(sp)
    8000629e:	ed4e                	sd	s3,152(sp)
    800062a0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800062a2:	08000613          	li	a2,128
    800062a6:	f5040593          	addi	a1,s0,-176
    800062aa:	4501                	li	a0,0
    800062ac:	ffffd097          	auipc	ra,0xffffd
    800062b0:	18c080e7          	jalr	396(ra) # 80003438 <argstr>
    return -1;
    800062b4:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800062b6:	0a054b63          	bltz	a0,8000636c <sys_create_mutex+0xd8>
    800062ba:	f4c40593          	addi	a1,s0,-180
    800062be:	4505                	li	a0,1
    800062c0:	ffffd097          	auipc	ra,0xffffd
    800062c4:	134080e7          	jalr	308(ra) # 800033f4 <argint>
    800062c8:	0a054263          	bltz	a0,8000636c <sys_create_mutex+0xd8>

  begin_op(ROOTDEV);
    800062cc:	4501                	li	a0,0
    800062ce:	ffffe097          	auipc	ra,0xffffe
    800062d2:	71e080e7          	jalr	1822(ra) # 800049ec <begin_op>

  if(omode & O_CREATE){
    800062d6:	f4c42783          	lw	a5,-180(s0)
    800062da:	2007f793          	andi	a5,a5,512
    800062de:	c7cd                	beqz	a5,80006388 <sys_create_mutex+0xf4>
    ip = create(path, T_FILE, 0, 0);
    800062e0:	4681                	li	a3,0
    800062e2:	4601                	li	a2,0
    800062e4:	4589                	li	a1,2
    800062e6:	f5040513          	addi	a0,s0,-176
    800062ea:	fffff097          	auipc	ra,0xfffff
    800062ee:	7d4080e7          	jalr	2004(ra) # 80005abe <create>
    800062f2:	892a                	mv	s2,a0
    if(ip == 0){
    800062f4:	c541                	beqz	a0,8000637c <sys_create_mutex+0xe8>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800062f6:	05c91703          	lh	a4,92(s2)
    800062fa:	478d                	li	a5,3
    800062fc:	00f71763          	bne	a4,a5,8000630a <sys_create_mutex+0x76>
    80006300:	05e95703          	lhu	a4,94(s2)
    80006304:	47a5                	li	a5,9
    80006306:	0ce7e863          	bltu	a5,a4,800063d6 <sys_create_mutex+0x142>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000630a:	fffff097          	auipc	ra,0xfffff
    8000630e:	bce080e7          	jalr	-1074(ra) # 80004ed8 <filealloc>
    80006312:	89aa                	mv	s3,a0
    80006314:	cd6d                	beqz	a0,8000640e <sys_create_mutex+0x17a>
    80006316:	fffff097          	auipc	ra,0xfffff
    8000631a:	760080e7          	jalr	1888(ra) # 80005a76 <fdalloc>
    8000631e:	84aa                	mv	s1,a0
    80006320:	0e054263          	bltz	a0,80006404 <sys_create_mutex+0x170>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006324:	05c91703          	lh	a4,92(s2)
    80006328:	478d                	li	a5,3
    8000632a:	0cf70263          	beq	a4,a5,800063ee <sys_create_mutex+0x15a>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_MUTEX;
    8000632e:	4791                	li	a5,4
    80006330:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80006334:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80006338:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    8000633c:	f4c42783          	lw	a5,-180(s0)
    80006340:	0017c713          	xori	a4,a5,1
    80006344:	8b05                	andi	a4,a4,1
    80006346:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000634a:	8b8d                	andi	a5,a5,3
    8000634c:	00f037b3          	snez	a5,a5
    80006350:	00f984a3          	sb	a5,9(s3)
  f->mutex.locked = 0;
    80006354:	0209a423          	sw	zero,40(s3)

  iunlock(ip);
    80006358:	854a                	mv	a0,s2
    8000635a:	ffffe097          	auipc	ra,0xffffe
    8000635e:	d7c080e7          	jalr	-644(ra) # 800040d6 <iunlock>
  end_op(ROOTDEV);
    80006362:	4501                	li	a0,0
    80006364:	ffffe097          	auipc	ra,0xffffe
    80006368:	734080e7          	jalr	1844(ra) # 80004a98 <end_op>

  return fd;
}
    8000636c:	8526                	mv	a0,s1
    8000636e:	70ea                	ld	ra,184(sp)
    80006370:	744a                	ld	s0,176(sp)
    80006372:	74aa                	ld	s1,168(sp)
    80006374:	790a                	ld	s2,160(sp)
    80006376:	69ea                	ld	s3,152(sp)
    80006378:	6129                	addi	sp,sp,192
    8000637a:	8082                	ret
      end_op(ROOTDEV);
    8000637c:	4501                	li	a0,0
    8000637e:	ffffe097          	auipc	ra,0xffffe
    80006382:	71a080e7          	jalr	1818(ra) # 80004a98 <end_op>
      return -1;
    80006386:	b7dd                	j	8000636c <sys_create_mutex+0xd8>
    if((ip = namei(path)) == 0){
    80006388:	f5040513          	addi	a0,s0,-176
    8000638c:	ffffe097          	auipc	ra,0xffffe
    80006390:	41a080e7          	jalr	1050(ra) # 800047a6 <namei>
    80006394:	892a                	mv	s2,a0
    80006396:	c90d                	beqz	a0,800063c8 <sys_create_mutex+0x134>
    ilock(ip);
    80006398:	ffffe097          	auipc	ra,0xffffe
    8000639c:	c7a080e7          	jalr	-902(ra) # 80004012 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800063a0:	05c91703          	lh	a4,92(s2)
    800063a4:	4785                	li	a5,1
    800063a6:	f4f718e3          	bne	a4,a5,800062f6 <sys_create_mutex+0x62>
    800063aa:	f4c42783          	lw	a5,-180(s0)
    800063ae:	dfb1                	beqz	a5,8000630a <sys_create_mutex+0x76>
      iunlockput(ip);
    800063b0:	854a                	mv	a0,s2
    800063b2:	ffffe097          	auipc	ra,0xffffe
    800063b6:	ea0080e7          	jalr	-352(ra) # 80004252 <iunlockput>
      end_op(ROOTDEV);
    800063ba:	4501                	li	a0,0
    800063bc:	ffffe097          	auipc	ra,0xffffe
    800063c0:	6dc080e7          	jalr	1756(ra) # 80004a98 <end_op>
      return -1;
    800063c4:	54fd                	li	s1,-1
    800063c6:	b75d                	j	8000636c <sys_create_mutex+0xd8>
      end_op(ROOTDEV);
    800063c8:	4501                	li	a0,0
    800063ca:	ffffe097          	auipc	ra,0xffffe
    800063ce:	6ce080e7          	jalr	1742(ra) # 80004a98 <end_op>
      return -1;
    800063d2:	54fd                	li	s1,-1
    800063d4:	bf61                	j	8000636c <sys_create_mutex+0xd8>
    iunlockput(ip);
    800063d6:	854a                	mv	a0,s2
    800063d8:	ffffe097          	auipc	ra,0xffffe
    800063dc:	e7a080e7          	jalr	-390(ra) # 80004252 <iunlockput>
    end_op(ROOTDEV);
    800063e0:	4501                	li	a0,0
    800063e2:	ffffe097          	auipc	ra,0xffffe
    800063e6:	6b6080e7          	jalr	1718(ra) # 80004a98 <end_op>
    return -1;
    800063ea:	54fd                	li	s1,-1
    800063ec:	b741                	j	8000636c <sys_create_mutex+0xd8>
    f->type = FD_DEVICE;
    800063ee:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800063f2:	05e91783          	lh	a5,94(s2)
    800063f6:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    800063fa:	06091783          	lh	a5,96(s2)
    800063fe:	02f99323          	sh	a5,38(s3)
    80006402:	bf0d                	j	80006334 <sys_create_mutex+0xa0>
      fileclose(f);
    80006404:	854e                	mv	a0,s3
    80006406:	fffff097          	auipc	ra,0xfffff
    8000640a:	ba2080e7          	jalr	-1118(ra) # 80004fa8 <fileclose>
    iunlockput(ip);
    8000640e:	854a                	mv	a0,s2
    80006410:	ffffe097          	auipc	ra,0xffffe
    80006414:	e42080e7          	jalr	-446(ra) # 80004252 <iunlockput>
    end_op(ROOTDEV);
    80006418:	4501                	li	a0,0
    8000641a:	ffffe097          	auipc	ra,0xffffe
    8000641e:	67e080e7          	jalr	1662(ra) # 80004a98 <end_op>
    return -1;
    80006422:	54fd                	li	s1,-1
    80006424:	b7a1                	j	8000636c <sys_create_mutex+0xd8>

0000000080006426 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006426:	7175                	addi	sp,sp,-144
    80006428:	e506                	sd	ra,136(sp)
    8000642a:	e122                	sd	s0,128(sp)
    8000642c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    8000642e:	4501                	li	a0,0
    80006430:	ffffe097          	auipc	ra,0xffffe
    80006434:	5bc080e7          	jalr	1468(ra) # 800049ec <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006438:	08000613          	li	a2,128
    8000643c:	f7040593          	addi	a1,s0,-144
    80006440:	4501                	li	a0,0
    80006442:	ffffd097          	auipc	ra,0xffffd
    80006446:	ff6080e7          	jalr	-10(ra) # 80003438 <argstr>
    8000644a:	02054a63          	bltz	a0,8000647e <sys_mkdir+0x58>
    8000644e:	4681                	li	a3,0
    80006450:	4601                	li	a2,0
    80006452:	4585                	li	a1,1
    80006454:	f7040513          	addi	a0,s0,-144
    80006458:	fffff097          	auipc	ra,0xfffff
    8000645c:	666080e7          	jalr	1638(ra) # 80005abe <create>
    80006460:	cd19                	beqz	a0,8000647e <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80006462:	ffffe097          	auipc	ra,0xffffe
    80006466:	df0080e7          	jalr	-528(ra) # 80004252 <iunlockput>
  end_op(ROOTDEV);
    8000646a:	4501                	li	a0,0
    8000646c:	ffffe097          	auipc	ra,0xffffe
    80006470:	62c080e7          	jalr	1580(ra) # 80004a98 <end_op>
  return 0;
    80006474:	4501                	li	a0,0
}
    80006476:	60aa                	ld	ra,136(sp)
    80006478:	640a                	ld	s0,128(sp)
    8000647a:	6149                	addi	sp,sp,144
    8000647c:	8082                	ret
    end_op(ROOTDEV);
    8000647e:	4501                	li	a0,0
    80006480:	ffffe097          	auipc	ra,0xffffe
    80006484:	618080e7          	jalr	1560(ra) # 80004a98 <end_op>
    return -1;
    80006488:	557d                	li	a0,-1
    8000648a:	b7f5                	j	80006476 <sys_mkdir+0x50>

000000008000648c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000648c:	7135                	addi	sp,sp,-160
    8000648e:	ed06                	sd	ra,152(sp)
    80006490:	e922                	sd	s0,144(sp)
    80006492:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80006494:	4501                	li	a0,0
    80006496:	ffffe097          	auipc	ra,0xffffe
    8000649a:	556080e7          	jalr	1366(ra) # 800049ec <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000649e:	08000613          	li	a2,128
    800064a2:	f7040593          	addi	a1,s0,-144
    800064a6:	4501                	li	a0,0
    800064a8:	ffffd097          	auipc	ra,0xffffd
    800064ac:	f90080e7          	jalr	-112(ra) # 80003438 <argstr>
    800064b0:	04054b63          	bltz	a0,80006506 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    800064b4:	f6c40593          	addi	a1,s0,-148
    800064b8:	4505                	li	a0,1
    800064ba:	ffffd097          	auipc	ra,0xffffd
    800064be:	f3a080e7          	jalr	-198(ra) # 800033f4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800064c2:	04054263          	bltz	a0,80006506 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    800064c6:	f6840593          	addi	a1,s0,-152
    800064ca:	4509                	li	a0,2
    800064cc:	ffffd097          	auipc	ra,0xffffd
    800064d0:	f28080e7          	jalr	-216(ra) # 800033f4 <argint>
     argint(1, &major) < 0 ||
    800064d4:	02054963          	bltz	a0,80006506 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800064d8:	f6841683          	lh	a3,-152(s0)
    800064dc:	f6c41603          	lh	a2,-148(s0)
    800064e0:	458d                	li	a1,3
    800064e2:	f7040513          	addi	a0,s0,-144
    800064e6:	fffff097          	auipc	ra,0xfffff
    800064ea:	5d8080e7          	jalr	1496(ra) # 80005abe <create>
     argint(2, &minor) < 0 ||
    800064ee:	cd01                	beqz	a0,80006506 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    800064f0:	ffffe097          	auipc	ra,0xffffe
    800064f4:	d62080e7          	jalr	-670(ra) # 80004252 <iunlockput>
  end_op(ROOTDEV);
    800064f8:	4501                	li	a0,0
    800064fa:	ffffe097          	auipc	ra,0xffffe
    800064fe:	59e080e7          	jalr	1438(ra) # 80004a98 <end_op>
  return 0;
    80006502:	4501                	li	a0,0
    80006504:	a039                	j	80006512 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80006506:	4501                	li	a0,0
    80006508:	ffffe097          	auipc	ra,0xffffe
    8000650c:	590080e7          	jalr	1424(ra) # 80004a98 <end_op>
    return -1;
    80006510:	557d                	li	a0,-1
}
    80006512:	60ea                	ld	ra,152(sp)
    80006514:	644a                	ld	s0,144(sp)
    80006516:	610d                	addi	sp,sp,160
    80006518:	8082                	ret

000000008000651a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000651a:	7135                	addi	sp,sp,-160
    8000651c:	ed06                	sd	ra,152(sp)
    8000651e:	e922                	sd	s0,144(sp)
    80006520:	e526                	sd	s1,136(sp)
    80006522:	e14a                	sd	s2,128(sp)
    80006524:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006526:	ffffc097          	auipc	ra,0xffffc
    8000652a:	b1a080e7          	jalr	-1254(ra) # 80002040 <myproc>
    8000652e:	892a                	mv	s2,a0

  begin_op(ROOTDEV);
    80006530:	4501                	li	a0,0
    80006532:	ffffe097          	auipc	ra,0xffffe
    80006536:	4ba080e7          	jalr	1210(ra) # 800049ec <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000653a:	08000613          	li	a2,128
    8000653e:	f6040593          	addi	a1,s0,-160
    80006542:	4501                	li	a0,0
    80006544:	ffffd097          	auipc	ra,0xffffd
    80006548:	ef4080e7          	jalr	-268(ra) # 80003438 <argstr>
    8000654c:	04054c63          	bltz	a0,800065a4 <sys_chdir+0x8a>
    80006550:	f6040513          	addi	a0,s0,-160
    80006554:	ffffe097          	auipc	ra,0xffffe
    80006558:	252080e7          	jalr	594(ra) # 800047a6 <namei>
    8000655c:	84aa                	mv	s1,a0
    8000655e:	c139                	beqz	a0,800065a4 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80006560:	ffffe097          	auipc	ra,0xffffe
    80006564:	ab2080e7          	jalr	-1358(ra) # 80004012 <ilock>
  if(ip->type != T_DIR){
    80006568:	05c49703          	lh	a4,92(s1)
    8000656c:	4785                	li	a5,1
    8000656e:	04f71263          	bne	a4,a5,800065b2 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80006572:	8526                	mv	a0,s1
    80006574:	ffffe097          	auipc	ra,0xffffe
    80006578:	b62080e7          	jalr	-1182(ra) # 800040d6 <iunlock>
  iput(p->cwd);
    8000657c:	16893503          	ld	a0,360(s2)
    80006580:	ffffe097          	auipc	ra,0xffffe
    80006584:	ba2080e7          	jalr	-1118(ra) # 80004122 <iput>
  end_op(ROOTDEV);
    80006588:	4501                	li	a0,0
    8000658a:	ffffe097          	auipc	ra,0xffffe
    8000658e:	50e080e7          	jalr	1294(ra) # 80004a98 <end_op>
  p->cwd = ip;
    80006592:	16993423          	sd	s1,360(s2)
  return 0;
    80006596:	4501                	li	a0,0
}
    80006598:	60ea                	ld	ra,152(sp)
    8000659a:	644a                	ld	s0,144(sp)
    8000659c:	64aa                	ld	s1,136(sp)
    8000659e:	690a                	ld	s2,128(sp)
    800065a0:	610d                	addi	sp,sp,160
    800065a2:	8082                	ret
    end_op(ROOTDEV);
    800065a4:	4501                	li	a0,0
    800065a6:	ffffe097          	auipc	ra,0xffffe
    800065aa:	4f2080e7          	jalr	1266(ra) # 80004a98 <end_op>
    return -1;
    800065ae:	557d                	li	a0,-1
    800065b0:	b7e5                	j	80006598 <sys_chdir+0x7e>
    iunlockput(ip);
    800065b2:	8526                	mv	a0,s1
    800065b4:	ffffe097          	auipc	ra,0xffffe
    800065b8:	c9e080e7          	jalr	-866(ra) # 80004252 <iunlockput>
    end_op(ROOTDEV);
    800065bc:	4501                	li	a0,0
    800065be:	ffffe097          	auipc	ra,0xffffe
    800065c2:	4da080e7          	jalr	1242(ra) # 80004a98 <end_op>
    return -1;
    800065c6:	557d                	li	a0,-1
    800065c8:	bfc1                	j	80006598 <sys_chdir+0x7e>

00000000800065ca <sys_exec>:

uint64
sys_exec(void)
{
    800065ca:	7145                	addi	sp,sp,-464
    800065cc:	e786                	sd	ra,456(sp)
    800065ce:	e3a2                	sd	s0,448(sp)
    800065d0:	ff26                	sd	s1,440(sp)
    800065d2:	fb4a                	sd	s2,432(sp)
    800065d4:	f74e                	sd	s3,424(sp)
    800065d6:	f352                	sd	s4,416(sp)
    800065d8:	ef56                	sd	s5,408(sp)
    800065da:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800065dc:	08000613          	li	a2,128
    800065e0:	f4040593          	addi	a1,s0,-192
    800065e4:	4501                	li	a0,0
    800065e6:	ffffd097          	auipc	ra,0xffffd
    800065ea:	e52080e7          	jalr	-430(ra) # 80003438 <argstr>
    800065ee:	10054763          	bltz	a0,800066fc <sys_exec+0x132>
    800065f2:	e3840593          	addi	a1,s0,-456
    800065f6:	4505                	li	a0,1
    800065f8:	ffffd097          	auipc	ra,0xffffd
    800065fc:	e1e080e7          	jalr	-482(ra) # 80003416 <argaddr>
    80006600:	10054863          	bltz	a0,80006710 <sys_exec+0x146>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80006604:	e4040913          	addi	s2,s0,-448
    80006608:	10000613          	li	a2,256
    8000660c:	4581                	li	a1,0
    8000660e:	854a                	mv	a0,s2
    80006610:	ffffb097          	auipc	ra,0xffffb
    80006614:	b1e080e7          	jalr	-1250(ra) # 8000112e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006618:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    8000661a:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    8000661c:	02000a93          	li	s5,32
    80006620:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006624:	00349513          	slli	a0,s1,0x3
    80006628:	e3040593          	addi	a1,s0,-464
    8000662c:	e3843783          	ld	a5,-456(s0)
    80006630:	953e                	add	a0,a0,a5
    80006632:	ffffd097          	auipc	ra,0xffffd
    80006636:	d26080e7          	jalr	-730(ra) # 80003358 <fetchaddr>
    8000663a:	02054a63          	bltz	a0,8000666e <sys_exec+0xa4>
      goto bad;
    }
    if(uarg == 0){
    8000663e:	e3043783          	ld	a5,-464(s0)
    80006642:	cfa1                	beqz	a5,8000669a <sys_exec+0xd0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006644:	ffffa097          	auipc	ra,0xffffa
    80006648:	4ee080e7          	jalr	1262(ra) # 80000b32 <kalloc>
    8000664c:	85aa                	mv	a1,a0
    8000664e:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80006652:	c949                	beqz	a0,800066e4 <sys_exec+0x11a>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80006654:	6605                	lui	a2,0x1
    80006656:	e3043503          	ld	a0,-464(s0)
    8000665a:	ffffd097          	auipc	ra,0xffffd
    8000665e:	d52080e7          	jalr	-686(ra) # 800033ac <fetchstr>
    80006662:	00054663          	bltz	a0,8000666e <sys_exec+0xa4>
    if(i >= NELEM(argv)){
    80006666:	0485                	addi	s1,s1,1
    80006668:	0921                	addi	s2,s2,8
    8000666a:	fb549be3          	bne	s1,s5,80006620 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000666e:	e4043503          	ld	a0,-448(s0)
    80006672:	c149                	beqz	a0,800066f4 <sys_exec+0x12a>
    kfree(argv[i]);
    80006674:	ffffa097          	auipc	ra,0xffffa
    80006678:	4a6080e7          	jalr	1190(ra) # 80000b1a <kfree>
    8000667c:	e4840493          	addi	s1,s0,-440
    80006680:	10098993          	addi	s3,s3,256
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006684:	6088                	ld	a0,0(s1)
    80006686:	c92d                	beqz	a0,800066f8 <sys_exec+0x12e>
    kfree(argv[i]);
    80006688:	ffffa097          	auipc	ra,0xffffa
    8000668c:	492080e7          	jalr	1170(ra) # 80000b1a <kfree>
    80006690:	04a1                	addi	s1,s1,8
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006692:	ff3499e3          	bne	s1,s3,80006684 <sys_exec+0xba>
  return -1;
    80006696:	557d                	li	a0,-1
    80006698:	a09d                	j	800066fe <sys_exec+0x134>
      argv[i] = 0;
    8000669a:	0a0e                	slli	s4,s4,0x3
    8000669c:	fc040793          	addi	a5,s0,-64
    800066a0:	9a3e                	add	s4,s4,a5
    800066a2:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    800066a6:	e4040593          	addi	a1,s0,-448
    800066aa:	f4040513          	addi	a0,s0,-192
    800066ae:	fffff097          	auipc	ra,0xfffff
    800066b2:	fbe080e7          	jalr	-66(ra) # 8000566c <exec>
    800066b6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800066b8:	e4043503          	ld	a0,-448(s0)
    800066bc:	c115                	beqz	a0,800066e0 <sys_exec+0x116>
    kfree(argv[i]);
    800066be:	ffffa097          	auipc	ra,0xffffa
    800066c2:	45c080e7          	jalr	1116(ra) # 80000b1a <kfree>
    800066c6:	e4840493          	addi	s1,s0,-440
    800066ca:	10098993          	addi	s3,s3,256
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800066ce:	6088                	ld	a0,0(s1)
    800066d0:	c901                	beqz	a0,800066e0 <sys_exec+0x116>
    kfree(argv[i]);
    800066d2:	ffffa097          	auipc	ra,0xffffa
    800066d6:	448080e7          	jalr	1096(ra) # 80000b1a <kfree>
    800066da:	04a1                	addi	s1,s1,8
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800066dc:	ff3499e3          	bne	s1,s3,800066ce <sys_exec+0x104>
  return ret;
    800066e0:	854a                	mv	a0,s2
    800066e2:	a831                	j	800066fe <sys_exec+0x134>
      panic("sys_exec kalloc");
    800066e4:	00002517          	auipc	a0,0x2
    800066e8:	5e450513          	addi	a0,a0,1508 # 80008cc8 <userret+0xc38>
    800066ec:	ffffa097          	auipc	ra,0xffffa
    800066f0:	098080e7          	jalr	152(ra) # 80000784 <panic>
  return -1;
    800066f4:	557d                	li	a0,-1
    800066f6:	a021                	j	800066fe <sys_exec+0x134>
    800066f8:	557d                	li	a0,-1
    800066fa:	a011                	j	800066fe <sys_exec+0x134>
    return -1;
    800066fc:	557d                	li	a0,-1
}
    800066fe:	60be                	ld	ra,456(sp)
    80006700:	641e                	ld	s0,448(sp)
    80006702:	74fa                	ld	s1,440(sp)
    80006704:	795a                	ld	s2,432(sp)
    80006706:	79ba                	ld	s3,424(sp)
    80006708:	7a1a                	ld	s4,416(sp)
    8000670a:	6afa                	ld	s5,408(sp)
    8000670c:	6179                	addi	sp,sp,464
    8000670e:	8082                	ret
    return -1;
    80006710:	557d                	li	a0,-1
    80006712:	b7f5                	j	800066fe <sys_exec+0x134>

0000000080006714 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006714:	7139                	addi	sp,sp,-64
    80006716:	fc06                	sd	ra,56(sp)
    80006718:	f822                	sd	s0,48(sp)
    8000671a:	f426                	sd	s1,40(sp)
    8000671c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000671e:	ffffc097          	auipc	ra,0xffffc
    80006722:	922080e7          	jalr	-1758(ra) # 80002040 <myproc>
    80006726:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006728:	fd840593          	addi	a1,s0,-40
    8000672c:	4501                	li	a0,0
    8000672e:	ffffd097          	auipc	ra,0xffffd
    80006732:	ce8080e7          	jalr	-792(ra) # 80003416 <argaddr>
    return -1;
    80006736:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006738:	0c054f63          	bltz	a0,80006816 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    8000673c:	fc840593          	addi	a1,s0,-56
    80006740:	fd040513          	addi	a0,s0,-48
    80006744:	fffff097          	auipc	ra,0xfffff
    80006748:	bc8080e7          	jalr	-1080(ra) # 8000530c <pipealloc>
    return -1;
    8000674c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000674e:	0c054463          	bltz	a0,80006816 <sys_pipe+0x102>
  fd0 = -1;
    80006752:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006756:	fd043503          	ld	a0,-48(s0)
    8000675a:	fffff097          	auipc	ra,0xfffff
    8000675e:	31c080e7          	jalr	796(ra) # 80005a76 <fdalloc>
    80006762:	fca42223          	sw	a0,-60(s0)
    80006766:	08054b63          	bltz	a0,800067fc <sys_pipe+0xe8>
    8000676a:	fc843503          	ld	a0,-56(s0)
    8000676e:	fffff097          	auipc	ra,0xfffff
    80006772:	308080e7          	jalr	776(ra) # 80005a76 <fdalloc>
    80006776:	fca42023          	sw	a0,-64(s0)
    8000677a:	06054863          	bltz	a0,800067ea <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000677e:	4691                	li	a3,4
    80006780:	fc440613          	addi	a2,s0,-60
    80006784:	fd843583          	ld	a1,-40(s0)
    80006788:	74a8                	ld	a0,104(s1)
    8000678a:	ffffb097          	auipc	ra,0xffffb
    8000678e:	494080e7          	jalr	1172(ra) # 80001c1e <copyout>
    80006792:	02054063          	bltz	a0,800067b2 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006796:	4691                	li	a3,4
    80006798:	fc040613          	addi	a2,s0,-64
    8000679c:	fd843583          	ld	a1,-40(s0)
    800067a0:	0591                	addi	a1,a1,4
    800067a2:	74a8                	ld	a0,104(s1)
    800067a4:	ffffb097          	auipc	ra,0xffffb
    800067a8:	47a080e7          	jalr	1146(ra) # 80001c1e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800067ac:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800067ae:	06055463          	bgez	a0,80006816 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    800067b2:	fc442783          	lw	a5,-60(s0)
    800067b6:	07f1                	addi	a5,a5,28
    800067b8:	078e                	slli	a5,a5,0x3
    800067ba:	97a6                	add	a5,a5,s1
    800067bc:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800067c0:	fc042783          	lw	a5,-64(s0)
    800067c4:	07f1                	addi	a5,a5,28
    800067c6:	078e                	slli	a5,a5,0x3
    800067c8:	94be                	add	s1,s1,a5
    800067ca:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800067ce:	fd043503          	ld	a0,-48(s0)
    800067d2:	ffffe097          	auipc	ra,0xffffe
    800067d6:	7d6080e7          	jalr	2006(ra) # 80004fa8 <fileclose>
    fileclose(wf);
    800067da:	fc843503          	ld	a0,-56(s0)
    800067de:	ffffe097          	auipc	ra,0xffffe
    800067e2:	7ca080e7          	jalr	1994(ra) # 80004fa8 <fileclose>
    return -1;
    800067e6:	57fd                	li	a5,-1
    800067e8:	a03d                	j	80006816 <sys_pipe+0x102>
    if(fd0 >= 0)
    800067ea:	fc442783          	lw	a5,-60(s0)
    800067ee:	0007c763          	bltz	a5,800067fc <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    800067f2:	07f1                	addi	a5,a5,28
    800067f4:	078e                	slli	a5,a5,0x3
    800067f6:	94be                	add	s1,s1,a5
    800067f8:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800067fc:	fd043503          	ld	a0,-48(s0)
    80006800:	ffffe097          	auipc	ra,0xffffe
    80006804:	7a8080e7          	jalr	1960(ra) # 80004fa8 <fileclose>
    fileclose(wf);
    80006808:	fc843503          	ld	a0,-56(s0)
    8000680c:	ffffe097          	auipc	ra,0xffffe
    80006810:	79c080e7          	jalr	1948(ra) # 80004fa8 <fileclose>
    return -1;
    80006814:	57fd                	li	a5,-1
}
    80006816:	853e                	mv	a0,a5
    80006818:	70e2                	ld	ra,56(sp)
    8000681a:	7442                	ld	s0,48(sp)
    8000681c:	74a2                	ld	s1,40(sp)
    8000681e:	6121                	addi	sp,sp,64
    80006820:	8082                	ret

0000000080006822 <sys_acquire_mutex>:
//   return -1;
// }

uint64
sys_acquire_mutex(void)
{
    80006822:	1141                	addi	sp,sp,-16
    80006824:	e422                	sd	s0,8(sp)
    80006826:	0800                	addi	s0,sp,16
  return 0;
}
    80006828:	4501                	li	a0,0
    8000682a:	6422                	ld	s0,8(sp)
    8000682c:	0141                	addi	sp,sp,16
    8000682e:	8082                	ret

0000000080006830 <sys_release_mutex>:

uint64
sys_release_mutex(void)
{
    80006830:	1141                	addi	sp,sp,-16
    80006832:	e422                	sd	s0,8(sp)
    80006834:	0800                	addi	s0,sp,16

  return 0;
}
    80006836:	4501                	li	a0,0
    80006838:	6422                	ld	s0,8(sp)
    8000683a:	0141                	addi	sp,sp,16
    8000683c:	8082                	ret
	...

0000000080006840 <kernelvec>:
    80006840:	7111                	addi	sp,sp,-256
    80006842:	e006                	sd	ra,0(sp)
    80006844:	e40a                	sd	sp,8(sp)
    80006846:	e80e                	sd	gp,16(sp)
    80006848:	ec12                	sd	tp,24(sp)
    8000684a:	f016                	sd	t0,32(sp)
    8000684c:	f41a                	sd	t1,40(sp)
    8000684e:	f81e                	sd	t2,48(sp)
    80006850:	fc22                	sd	s0,56(sp)
    80006852:	e0a6                	sd	s1,64(sp)
    80006854:	e4aa                	sd	a0,72(sp)
    80006856:	e8ae                	sd	a1,80(sp)
    80006858:	ecb2                	sd	a2,88(sp)
    8000685a:	f0b6                	sd	a3,96(sp)
    8000685c:	f4ba                	sd	a4,104(sp)
    8000685e:	f8be                	sd	a5,112(sp)
    80006860:	fcc2                	sd	a6,120(sp)
    80006862:	e146                	sd	a7,128(sp)
    80006864:	e54a                	sd	s2,136(sp)
    80006866:	e94e                	sd	s3,144(sp)
    80006868:	ed52                	sd	s4,152(sp)
    8000686a:	f156                	sd	s5,160(sp)
    8000686c:	f55a                	sd	s6,168(sp)
    8000686e:	f95e                	sd	s7,176(sp)
    80006870:	fd62                	sd	s8,184(sp)
    80006872:	e1e6                	sd	s9,192(sp)
    80006874:	e5ea                	sd	s10,200(sp)
    80006876:	e9ee                	sd	s11,208(sp)
    80006878:	edf2                	sd	t3,216(sp)
    8000687a:	f1f6                	sd	t4,224(sp)
    8000687c:	f5fa                	sd	t5,232(sp)
    8000687e:	f9fe                	sd	t6,240(sp)
    80006880:	995fc0ef          	jal	ra,80003214 <kerneltrap>
    80006884:	6082                	ld	ra,0(sp)
    80006886:	6122                	ld	sp,8(sp)
    80006888:	61c2                	ld	gp,16(sp)
    8000688a:	7282                	ld	t0,32(sp)
    8000688c:	7322                	ld	t1,40(sp)
    8000688e:	73c2                	ld	t2,48(sp)
    80006890:	7462                	ld	s0,56(sp)
    80006892:	6486                	ld	s1,64(sp)
    80006894:	6526                	ld	a0,72(sp)
    80006896:	65c6                	ld	a1,80(sp)
    80006898:	6666                	ld	a2,88(sp)
    8000689a:	7686                	ld	a3,96(sp)
    8000689c:	7726                	ld	a4,104(sp)
    8000689e:	77c6                	ld	a5,112(sp)
    800068a0:	7866                	ld	a6,120(sp)
    800068a2:	688a                	ld	a7,128(sp)
    800068a4:	692a                	ld	s2,136(sp)
    800068a6:	69ca                	ld	s3,144(sp)
    800068a8:	6a6a                	ld	s4,152(sp)
    800068aa:	7a8a                	ld	s5,160(sp)
    800068ac:	7b2a                	ld	s6,168(sp)
    800068ae:	7bca                	ld	s7,176(sp)
    800068b0:	7c6a                	ld	s8,184(sp)
    800068b2:	6c8e                	ld	s9,192(sp)
    800068b4:	6d2e                	ld	s10,200(sp)
    800068b6:	6dce                	ld	s11,208(sp)
    800068b8:	6e6e                	ld	t3,216(sp)
    800068ba:	7e8e                	ld	t4,224(sp)
    800068bc:	7f2e                	ld	t5,232(sp)
    800068be:	7fce                	ld	t6,240(sp)
    800068c0:	6111                	addi	sp,sp,256
    800068c2:	10200073          	sret
    800068c6:	00000013          	nop
    800068ca:	00000013          	nop
    800068ce:	0001                	nop

00000000800068d0 <timervec>:
    800068d0:	34051573          	csrrw	a0,mscratch,a0
    800068d4:	e10c                	sd	a1,0(a0)
    800068d6:	e510                	sd	a2,8(a0)
    800068d8:	e914                	sd	a3,16(a0)
    800068da:	710c                	ld	a1,32(a0)
    800068dc:	7510                	ld	a2,40(a0)
    800068de:	6194                	ld	a3,0(a1)
    800068e0:	96b2                	add	a3,a3,a2
    800068e2:	e194                	sd	a3,0(a1)
    800068e4:	4589                	li	a1,2
    800068e6:	14459073          	csrw	sip,a1
    800068ea:	6914                	ld	a3,16(a0)
    800068ec:	6510                	ld	a2,8(a0)
    800068ee:	610c                	ld	a1,0(a0)
    800068f0:	34051573          	csrrw	a0,mscratch,a0
    800068f4:	30200073          	mret
	...

00000000800068fa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800068fa:	1141                	addi	sp,sp,-16
    800068fc:	e422                	sd	s0,8(sp)
    800068fe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006900:	0c0007b7          	lui	a5,0xc000
    80006904:	4705                	li	a4,1
    80006906:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006908:	c3d8                	sw	a4,4(a5)
}
    8000690a:	6422                	ld	s0,8(sp)
    8000690c:	0141                	addi	sp,sp,16
    8000690e:	8082                	ret

0000000080006910 <plicinithart>:

void
plicinithart(void)
{
    80006910:	1141                	addi	sp,sp,-16
    80006912:	e406                	sd	ra,8(sp)
    80006914:	e022                	sd	s0,0(sp)
    80006916:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006918:	ffffb097          	auipc	ra,0xffffb
    8000691c:	6fc080e7          	jalr	1788(ra) # 80002014 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006920:	0085171b          	slliw	a4,a0,0x8
    80006924:	0c0027b7          	lui	a5,0xc002
    80006928:	97ba                	add	a5,a5,a4
    8000692a:	40200713          	li	a4,1026
    8000692e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006932:	00d5151b          	slliw	a0,a0,0xd
    80006936:	0c2017b7          	lui	a5,0xc201
    8000693a:	953e                	add	a0,a0,a5
    8000693c:	00052023          	sw	zero,0(a0)
}
    80006940:	60a2                	ld	ra,8(sp)
    80006942:	6402                	ld	s0,0(sp)
    80006944:	0141                	addi	sp,sp,16
    80006946:	8082                	ret

0000000080006948 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006948:	1141                	addi	sp,sp,-16
    8000694a:	e406                	sd	ra,8(sp)
    8000694c:	e022                	sd	s0,0(sp)
    8000694e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006950:	ffffb097          	auipc	ra,0xffffb
    80006954:	6c4080e7          	jalr	1732(ra) # 80002014 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006958:	00d5151b          	slliw	a0,a0,0xd
    8000695c:	0c2017b7          	lui	a5,0xc201
    80006960:	97aa                	add	a5,a5,a0
  return irq;
}
    80006962:	43c8                	lw	a0,4(a5)
    80006964:	60a2                	ld	ra,8(sp)
    80006966:	6402                	ld	s0,0(sp)
    80006968:	0141                	addi	sp,sp,16
    8000696a:	8082                	ret

000000008000696c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000696c:	1101                	addi	sp,sp,-32
    8000696e:	ec06                	sd	ra,24(sp)
    80006970:	e822                	sd	s0,16(sp)
    80006972:	e426                	sd	s1,8(sp)
    80006974:	1000                	addi	s0,sp,32
    80006976:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006978:	ffffb097          	auipc	ra,0xffffb
    8000697c:	69c080e7          	jalr	1692(ra) # 80002014 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006980:	00d5151b          	slliw	a0,a0,0xd
    80006984:	0c2017b7          	lui	a5,0xc201
    80006988:	97aa                	add	a5,a5,a0
    8000698a:	c3c4                	sw	s1,4(a5)
}
    8000698c:	60e2                	ld	ra,24(sp)
    8000698e:	6442                	ld	s0,16(sp)
    80006990:	64a2                	ld	s1,8(sp)
    80006992:	6105                	addi	sp,sp,32
    80006994:	8082                	ret

0000000080006996 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006996:	1141                	addi	sp,sp,-16
    80006998:	e406                	sd	ra,8(sp)
    8000699a:	e022                	sd	s0,0(sp)
    8000699c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000699e:	479d                	li	a5,7
    800069a0:	06b7c863          	blt	a5,a1,80006a10 <free_desc+0x7a>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    800069a4:	00151713          	slli	a4,a0,0x1
    800069a8:	972a                	add	a4,a4,a0
    800069aa:	00c71693          	slli	a3,a4,0xc
    800069ae:	00023717          	auipc	a4,0x23
    800069b2:	65270713          	addi	a4,a4,1618 # 8002a000 <disk>
    800069b6:	9736                	add	a4,a4,a3
    800069b8:	972e                	add	a4,a4,a1
    800069ba:	6789                	lui	a5,0x2
    800069bc:	973e                	add	a4,a4,a5
    800069be:	01874783          	lbu	a5,24(a4)
    800069c2:	efb9                	bnez	a5,80006a20 <free_desc+0x8a>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    800069c4:	00023817          	auipc	a6,0x23
    800069c8:	63c80813          	addi	a6,a6,1596 # 8002a000 <disk>
    800069cc:	00151713          	slli	a4,a0,0x1
    800069d0:	00a707b3          	add	a5,a4,a0
    800069d4:	07b2                	slli	a5,a5,0xc
    800069d6:	97c2                	add	a5,a5,a6
    800069d8:	6689                	lui	a3,0x2
    800069da:	00f68633          	add	a2,a3,a5
    800069de:	6210                	ld	a2,0(a2)
    800069e0:	00459893          	slli	a7,a1,0x4
    800069e4:	9646                	add	a2,a2,a7
    800069e6:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    800069ea:	97ae                	add	a5,a5,a1
    800069ec:	97b6                	add	a5,a5,a3
    800069ee:	4605                	li	a2,1
    800069f0:	00c78c23          	sb	a2,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk[n].free[0]);
    800069f4:	972a                	add	a4,a4,a0
    800069f6:	0732                	slli	a4,a4,0xc
    800069f8:	06e1                	addi	a3,a3,24
    800069fa:	9736                	add	a4,a4,a3
    800069fc:	00e80533          	add	a0,a6,a4
    80006a00:	ffffc097          	auipc	ra,0xffffc
    80006a04:	0b8080e7          	jalr	184(ra) # 80002ab8 <wakeup>
}
    80006a08:	60a2                	ld	ra,8(sp)
    80006a0a:	6402                	ld	s0,0(sp)
    80006a0c:	0141                	addi	sp,sp,16
    80006a0e:	8082                	ret
    panic("virtio_disk_intr 1");
    80006a10:	00002517          	auipc	a0,0x2
    80006a14:	2c850513          	addi	a0,a0,712 # 80008cd8 <userret+0xc48>
    80006a18:	ffffa097          	auipc	ra,0xffffa
    80006a1c:	d6c080e7          	jalr	-660(ra) # 80000784 <panic>
    panic("virtio_disk_intr 2");
    80006a20:	00002517          	auipc	a0,0x2
    80006a24:	2d050513          	addi	a0,a0,720 # 80008cf0 <userret+0xc60>
    80006a28:	ffffa097          	auipc	ra,0xffffa
    80006a2c:	d5c080e7          	jalr	-676(ra) # 80000784 <panic>

0000000080006a30 <virtio_disk_init>:
  __sync_synchronize();
    80006a30:	0ff0000f          	fence
  if(disk[n].init)
    80006a34:	00151793          	slli	a5,a0,0x1
    80006a38:	97aa                	add	a5,a5,a0
    80006a3a:	07b2                	slli	a5,a5,0xc
    80006a3c:	00023717          	auipc	a4,0x23
    80006a40:	5c470713          	addi	a4,a4,1476 # 8002a000 <disk>
    80006a44:	973e                	add	a4,a4,a5
    80006a46:	6789                	lui	a5,0x2
    80006a48:	97ba                	add	a5,a5,a4
    80006a4a:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80006a4e:	c391                	beqz	a5,80006a52 <virtio_disk_init+0x22>
    80006a50:	8082                	ret
{
    80006a52:	7139                	addi	sp,sp,-64
    80006a54:	fc06                	sd	ra,56(sp)
    80006a56:	f822                	sd	s0,48(sp)
    80006a58:	f426                	sd	s1,40(sp)
    80006a5a:	f04a                	sd	s2,32(sp)
    80006a5c:	ec4e                	sd	s3,24(sp)
    80006a5e:	e852                	sd	s4,16(sp)
    80006a60:	e456                	sd	s5,8(sp)
    80006a62:	0080                	addi	s0,sp,64
    80006a64:	892a                	mv	s2,a0
  printf("virtio disk init %d\n", n);
    80006a66:	85aa                	mv	a1,a0
    80006a68:	00002517          	auipc	a0,0x2
    80006a6c:	2a050513          	addi	a0,a0,672 # 80008d08 <userret+0xc78>
    80006a70:	ffffa097          	auipc	ra,0xffffa
    80006a74:	f2c080e7          	jalr	-212(ra) # 8000099c <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80006a78:	00191993          	slli	s3,s2,0x1
    80006a7c:	99ca                	add	s3,s3,s2
    80006a7e:	09b2                	slli	s3,s3,0xc
    80006a80:	6789                	lui	a5,0x2
    80006a82:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006a86:	97ce                	add	a5,a5,s3
    80006a88:	00002597          	auipc	a1,0x2
    80006a8c:	29858593          	addi	a1,a1,664 # 80008d20 <userret+0xc90>
    80006a90:	00023517          	auipc	a0,0x23
    80006a94:	57050513          	addi	a0,a0,1392 # 8002a000 <disk>
    80006a98:	953e                	add	a0,a0,a5
    80006a9a:	ffffa097          	auipc	ra,0xffffa
    80006a9e:	0b2080e7          	jalr	178(ra) # 80000b4c <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006aa2:	0019049b          	addiw	s1,s2,1
    80006aa6:	00c4949b          	slliw	s1,s1,0xc
    80006aaa:	100007b7          	lui	a5,0x10000
    80006aae:	97a6                	add	a5,a5,s1
    80006ab0:	4398                	lw	a4,0(a5)
    80006ab2:	2701                	sext.w	a4,a4
    80006ab4:	747277b7          	lui	a5,0x74727
    80006ab8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006abc:	12f71763          	bne	a4,a5,80006bea <virtio_disk_init+0x1ba>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006ac0:	100007b7          	lui	a5,0x10000
    80006ac4:	0791                	addi	a5,a5,4
    80006ac6:	97a6                	add	a5,a5,s1
    80006ac8:	439c                	lw	a5,0(a5)
    80006aca:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006acc:	4705                	li	a4,1
    80006ace:	10e79e63          	bne	a5,a4,80006bea <virtio_disk_init+0x1ba>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006ad2:	100007b7          	lui	a5,0x10000
    80006ad6:	07a1                	addi	a5,a5,8
    80006ad8:	97a6                	add	a5,a5,s1
    80006ada:	439c                	lw	a5,0(a5)
    80006adc:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006ade:	4709                	li	a4,2
    80006ae0:	10e79563          	bne	a5,a4,80006bea <virtio_disk_init+0x1ba>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006ae4:	100007b7          	lui	a5,0x10000
    80006ae8:	07b1                	addi	a5,a5,12
    80006aea:	97a6                	add	a5,a5,s1
    80006aec:	4398                	lw	a4,0(a5)
    80006aee:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006af0:	554d47b7          	lui	a5,0x554d4
    80006af4:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006af8:	0ef71963          	bne	a4,a5,80006bea <virtio_disk_init+0x1ba>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006afc:	100007b7          	lui	a5,0x10000
    80006b00:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80006b04:	96a6                	add	a3,a3,s1
    80006b06:	4705                	li	a4,1
    80006b08:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006b0a:	470d                	li	a4,3
    80006b0c:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80006b0e:	01078713          	addi	a4,a5,16
    80006b12:	9726                	add	a4,a4,s1
    80006b14:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006b16:	02078613          	addi	a2,a5,32
    80006b1a:	9626                	add	a2,a2,s1
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006b1c:	c7ffe737          	lui	a4,0xc7ffe
    80006b20:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fce6b3>
    80006b24:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006b26:	2701                	sext.w	a4,a4
    80006b28:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006b2a:	472d                	li	a4,11
    80006b2c:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006b2e:	473d                	li	a4,15
    80006b30:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006b32:	02878713          	addi	a4,a5,40
    80006b36:	9726                	add	a4,a4,s1
    80006b38:	6685                	lui	a3,0x1
    80006b3a:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006b3c:	03078713          	addi	a4,a5,48
    80006b40:	9726                	add	a4,a4,s1
    80006b42:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006b46:	03478793          	addi	a5,a5,52
    80006b4a:	97a6                	add	a5,a5,s1
    80006b4c:	439c                	lw	a5,0(a5)
    80006b4e:	2781                	sext.w	a5,a5
  if(max == 0)
    80006b50:	c7cd                	beqz	a5,80006bfa <virtio_disk_init+0x1ca>
  if(max < NUM)
    80006b52:	471d                	li	a4,7
    80006b54:	0af77b63          	bleu	a5,a4,80006c0a <virtio_disk_init+0x1da>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006b58:	10000ab7          	lui	s5,0x10000
    80006b5c:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006b60:	97a6                	add	a5,a5,s1
    80006b62:	4721                	li	a4,8
    80006b64:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006b66:	00023a17          	auipc	s4,0x23
    80006b6a:	49aa0a13          	addi	s4,s4,1178 # 8002a000 <disk>
    80006b6e:	99d2                	add	s3,s3,s4
    80006b70:	6609                	lui	a2,0x2
    80006b72:	4581                	li	a1,0
    80006b74:	854e                	mv	a0,s3
    80006b76:	ffffa097          	auipc	ra,0xffffa
    80006b7a:	5b8080e7          	jalr	1464(ra) # 8000112e <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80006b7e:	040a8a93          	addi	s5,s5,64
    80006b82:	94d6                	add	s1,s1,s5
    80006b84:	00c9d793          	srli	a5,s3,0xc
    80006b88:	2781                	sext.w	a5,a5
    80006b8a:	c09c                	sw	a5,0(s1)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80006b8c:	00191513          	slli	a0,s2,0x1
    80006b90:	012507b3          	add	a5,a0,s2
    80006b94:	07b2                	slli	a5,a5,0xc
    80006b96:	97d2                	add	a5,a5,s4
    80006b98:	6689                	lui	a3,0x2
    80006b9a:	97b6                	add	a5,a5,a3
    80006b9c:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006ba0:	08098713          	addi	a4,s3,128
    80006ba4:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    80006ba6:	6705                	lui	a4,0x1
    80006ba8:	99ba                	add	s3,s3,a4
    80006baa:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006bae:	4705                	li	a4,1
    80006bb0:	00e78c23          	sb	a4,24(a5)
    80006bb4:	00e78ca3          	sb	a4,25(a5)
    80006bb8:	00e78d23          	sb	a4,26(a5)
    80006bbc:	00e78da3          	sb	a4,27(a5)
    80006bc0:	00e78e23          	sb	a4,28(a5)
    80006bc4:	00e78ea3          	sb	a4,29(a5)
    80006bc8:	00e78f23          	sb	a4,30(a5)
    80006bcc:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006bd0:	853e                	mv	a0,a5
    80006bd2:	4785                	li	a5,1
    80006bd4:	0af52423          	sw	a5,168(a0)
}
    80006bd8:	70e2                	ld	ra,56(sp)
    80006bda:	7442                	ld	s0,48(sp)
    80006bdc:	74a2                	ld	s1,40(sp)
    80006bde:	7902                	ld	s2,32(sp)
    80006be0:	69e2                	ld	s3,24(sp)
    80006be2:	6a42                	ld	s4,16(sp)
    80006be4:	6aa2                	ld	s5,8(sp)
    80006be6:	6121                	addi	sp,sp,64
    80006be8:	8082                	ret
    panic("could not find virtio disk");
    80006bea:	00002517          	auipc	a0,0x2
    80006bee:	14650513          	addi	a0,a0,326 # 80008d30 <userret+0xca0>
    80006bf2:	ffffa097          	auipc	ra,0xffffa
    80006bf6:	b92080e7          	jalr	-1134(ra) # 80000784 <panic>
    panic("virtio disk has no queue 0");
    80006bfa:	00002517          	auipc	a0,0x2
    80006bfe:	15650513          	addi	a0,a0,342 # 80008d50 <userret+0xcc0>
    80006c02:	ffffa097          	auipc	ra,0xffffa
    80006c06:	b82080e7          	jalr	-1150(ra) # 80000784 <panic>
    panic("virtio disk max queue too short");
    80006c0a:	00002517          	auipc	a0,0x2
    80006c0e:	16650513          	addi	a0,a0,358 # 80008d70 <userret+0xce0>
    80006c12:	ffffa097          	auipc	ra,0xffffa
    80006c16:	b72080e7          	jalr	-1166(ra) # 80000784 <panic>

0000000080006c1a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    80006c1a:	7175                	addi	sp,sp,-144
    80006c1c:	e506                	sd	ra,136(sp)
    80006c1e:	e122                	sd	s0,128(sp)
    80006c20:	fca6                	sd	s1,120(sp)
    80006c22:	f8ca                	sd	s2,112(sp)
    80006c24:	f4ce                	sd	s3,104(sp)
    80006c26:	f0d2                	sd	s4,96(sp)
    80006c28:	ecd6                	sd	s5,88(sp)
    80006c2a:	e8da                	sd	s6,80(sp)
    80006c2c:	e4de                	sd	s7,72(sp)
    80006c2e:	e0e2                	sd	s8,64(sp)
    80006c30:	fc66                	sd	s9,56(sp)
    80006c32:	f86a                	sd	s10,48(sp)
    80006c34:	f46e                	sd	s11,40(sp)
    80006c36:	0900                	addi	s0,sp,144
    80006c38:	892a                	mv	s2,a0
    80006c3a:	8a2e                	mv	s4,a1
    80006c3c:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80006c3e:	00c5ad03          	lw	s10,12(a1)
    80006c42:	001d1d1b          	slliw	s10,s10,0x1
    80006c46:	1d02                	slli	s10,s10,0x20
    80006c48:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk[n].vdisk_lock);
    80006c4c:	00151493          	slli	s1,a0,0x1
    80006c50:	94aa                	add	s1,s1,a0
    80006c52:	04b2                	slli	s1,s1,0xc
    80006c54:	6a89                	lui	s5,0x2
    80006c56:	0b0a8993          	addi	s3,s5,176 # 20b0 <_entry-0x7fffdf50>
    80006c5a:	99a6                	add	s3,s3,s1
    80006c5c:	00023c17          	auipc	s8,0x23
    80006c60:	3a4c0c13          	addi	s8,s8,932 # 8002a000 <disk>
    80006c64:	99e2                	add	s3,s3,s8
    80006c66:	854e                	mv	a0,s3
    80006c68:	ffffa097          	auipc	ra,0xffffa
    80006c6c:	052080e7          	jalr	82(ra) # 80000cba <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006c70:	018a8b93          	addi	s7,s5,24
    80006c74:	9ba6                	add	s7,s7,s1
    80006c76:	9be2                	add	s7,s7,s8
    80006c78:	0ae5                	addi	s5,s5,25
    80006c7a:	94d6                	add	s1,s1,s5
    80006c7c:	01848ab3          	add	s5,s1,s8
    if(disk[n].free[i]){
    80006c80:	00191b13          	slli	s6,s2,0x1
    80006c84:	9b4a                	add	s6,s6,s2
    80006c86:	00cb1793          	slli	a5,s6,0xc
    80006c8a:	00fc0b33          	add	s6,s8,a5
    80006c8e:	6c89                	lui	s9,0x2
    80006c90:	016c8c33          	add	s8,s9,s6
    80006c94:	a049                	j	80006d16 <virtio_disk_rw+0xfc>
      disk[n].free[i] = 0;
    80006c96:	00fb06b3          	add	a3,s6,a5
    80006c9a:	96e6                	add	a3,a3,s9
    80006c9c:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    80006ca0:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006ca2:	0207c763          	bltz	a5,80006cd0 <virtio_disk_rw+0xb6>
  for(int i = 0; i < 3; i++){
    80006ca6:	2485                	addiw	s1,s1,1
    80006ca8:	0711                	addi	a4,a4,4
    80006caa:	28b48063          	beq	s1,a1,80006f2a <virtio_disk_rw+0x310>
    idx[i] = alloc_desc(n);
    80006cae:	863a                	mv	a2,a4
    if(disk[n].free[i]){
    80006cb0:	018c4783          	lbu	a5,24(s8)
    80006cb4:	28079063          	bnez	a5,80006f34 <virtio_disk_rw+0x31a>
    80006cb8:	86d6                	mv	a3,s5
  for(int i = 0; i < NUM; i++){
    80006cba:	87c2                	mv	a5,a6
    if(disk[n].free[i]){
    80006cbc:	0006c883          	lbu	a7,0(a3)
    80006cc0:	fc089be3          	bnez	a7,80006c96 <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    80006cc4:	2785                	addiw	a5,a5,1
    80006cc6:	0685                	addi	a3,a3,1
    80006cc8:	fea79ae3          	bne	a5,a0,80006cbc <virtio_disk_rw+0xa2>
    idx[i] = alloc_desc(n);
    80006ccc:	57fd                	li	a5,-1
    80006cce:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006cd0:	02905d63          	blez	s1,80006d0a <virtio_disk_rw+0xf0>
        free_desc(n, idx[j]);
    80006cd4:	f8042583          	lw	a1,-128(s0)
    80006cd8:	854a                	mv	a0,s2
    80006cda:	00000097          	auipc	ra,0x0
    80006cde:	cbc080e7          	jalr	-836(ra) # 80006996 <free_desc>
      for(int j = 0; j < i; j++)
    80006ce2:	4785                	li	a5,1
    80006ce4:	0297d363          	ble	s1,a5,80006d0a <virtio_disk_rw+0xf0>
        free_desc(n, idx[j]);
    80006ce8:	f8442583          	lw	a1,-124(s0)
    80006cec:	854a                	mv	a0,s2
    80006cee:	00000097          	auipc	ra,0x0
    80006cf2:	ca8080e7          	jalr	-856(ra) # 80006996 <free_desc>
      for(int j = 0; j < i; j++)
    80006cf6:	4789                	li	a5,2
    80006cf8:	0097d963          	ble	s1,a5,80006d0a <virtio_disk_rw+0xf0>
        free_desc(n, idx[j]);
    80006cfc:	f8842583          	lw	a1,-120(s0)
    80006d00:	854a                	mv	a0,s2
    80006d02:	00000097          	auipc	ra,0x0
    80006d06:	c94080e7          	jalr	-876(ra) # 80006996 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006d0a:	85ce                	mv	a1,s3
    80006d0c:	855e                	mv	a0,s7
    80006d0e:	ffffc097          	auipc	ra,0xffffc
    80006d12:	c24080e7          	jalr	-988(ra) # 80002932 <sleep>
  for(int i = 0; i < 3; i++){
    80006d16:	f8040713          	addi	a4,s0,-128
    80006d1a:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80006d1c:	4805                	li	a6,1
    80006d1e:	4521                	li	a0,8
  for(int i = 0; i < 3; i++){
    80006d20:	458d                	li	a1,3
    80006d22:	b771                	j	80006cae <virtio_disk_rw+0x94>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006d24:	4785                	li	a5,1
    80006d26:	f6f42823          	sw	a5,-144(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    80006d2a:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006d2e:	f7a43c23          	sd	s10,-136(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006d32:	f8042483          	lw	s1,-128(s0)
    80006d36:	00449b13          	slli	s6,s1,0x4
    80006d3a:	00191793          	slli	a5,s2,0x1
    80006d3e:	97ca                	add	a5,a5,s2
    80006d40:	07b2                	slli	a5,a5,0xc
    80006d42:	00023a97          	auipc	s5,0x23
    80006d46:	2bea8a93          	addi	s5,s5,702 # 8002a000 <disk>
    80006d4a:	97d6                	add	a5,a5,s5
    80006d4c:	6a89                	lui	s5,0x2
    80006d4e:	9abe                	add	s5,s5,a5
    80006d50:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    80006d54:	9bda                	add	s7,s7,s6
    80006d56:	f7040513          	addi	a0,s0,-144
    80006d5a:	ffffb097          	auipc	ra,0xffffb
    80006d5e:	922080e7          	jalr	-1758(ra) # 8000167c <kvmpa>
    80006d62:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006d66:	000ab783          	ld	a5,0(s5)
    80006d6a:	97da                	add	a5,a5,s6
    80006d6c:	4741                	li	a4,16
    80006d6e:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006d70:	000ab783          	ld	a5,0(s5)
    80006d74:	97da                	add	a5,a5,s6
    80006d76:	4705                	li	a4,1
    80006d78:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006d7c:	f8442603          	lw	a2,-124(s0)
    80006d80:	000ab783          	ld	a5,0(s5)
    80006d84:	9b3e                	add	s6,s6,a5
    80006d86:	00cb1723          	sh	a2,14(s6) # fffffffffffff00e <end+0xffffffff7ffcef62>

  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006d8a:	0612                	slli	a2,a2,0x4
    80006d8c:	000ab783          	ld	a5,0(s5)
    80006d90:	97b2                	add	a5,a5,a2
    80006d92:	070a0713          	addi	a4,s4,112
    80006d96:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006d98:	000ab783          	ld	a5,0(s5)
    80006d9c:	97b2                	add	a5,a5,a2
    80006d9e:	40000713          	li	a4,1024
    80006da2:	c798                	sw	a4,8(a5)
  if(write)
    80006da4:	120d8e63          	beqz	s11,80006ee0 <virtio_disk_rw+0x2c6>
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006da8:	000ab783          	ld	a5,0(s5)
    80006dac:	97b2                	add	a5,a5,a2
    80006dae:	00079623          	sh	zero,12(a5)
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006db2:	00023517          	auipc	a0,0x23
    80006db6:	24e50513          	addi	a0,a0,590 # 8002a000 <disk>
    80006dba:	00191793          	slli	a5,s2,0x1
    80006dbe:	012786b3          	add	a3,a5,s2
    80006dc2:	06b2                	slli	a3,a3,0xc
    80006dc4:	96aa                	add	a3,a3,a0
    80006dc6:	6709                	lui	a4,0x2
    80006dc8:	96ba                	add	a3,a3,a4
    80006dca:	628c                	ld	a1,0(a3)
    80006dcc:	95b2                	add	a1,a1,a2
    80006dce:	00c5d703          	lhu	a4,12(a1)
    80006dd2:	00176713          	ori	a4,a4,1
    80006dd6:	00e59623          	sh	a4,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    80006dda:	f8842583          	lw	a1,-120(s0)
    80006dde:	6298                	ld	a4,0(a3)
    80006de0:	963a                	add	a2,a2,a4
    80006de2:	00b61723          	sh	a1,14(a2) # 200e <_entry-0x7fffdff2>

  disk[n].info[idx[0]].status = 0;
    80006de6:	97ca                	add	a5,a5,s2
    80006de8:	07a2                	slli	a5,a5,0x8
    80006dea:	97a6                	add	a5,a5,s1
    80006dec:	20078793          	addi	a5,a5,512
    80006df0:	0792                	slli	a5,a5,0x4
    80006df2:	97aa                	add	a5,a5,a0
    80006df4:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006df8:	00459613          	slli	a2,a1,0x4
    80006dfc:	628c                	ld	a1,0(a3)
    80006dfe:	95b2                	add	a1,a1,a2
    80006e00:	00191713          	slli	a4,s2,0x1
    80006e04:	974a                	add	a4,a4,s2
    80006e06:	0722                	slli	a4,a4,0x8
    80006e08:	20348813          	addi	a6,s1,515
    80006e0c:	9742                	add	a4,a4,a6
    80006e0e:	0712                	slli	a4,a4,0x4
    80006e10:	972a                	add	a4,a4,a0
    80006e12:	e198                	sd	a4,0(a1)
  disk[n].desc[idx[2]].len = 1;
    80006e14:	6298                	ld	a4,0(a3)
    80006e16:	9732                	add	a4,a4,a2
    80006e18:	4585                	li	a1,1
    80006e1a:	c70c                	sw	a1,8(a4)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006e1c:	6298                	ld	a4,0(a3)
    80006e1e:	9732                	add	a4,a4,a2
    80006e20:	4509                	li	a0,2
    80006e22:	00a71623          	sh	a0,12(a4) # 200c <_entry-0x7fffdff4>
  disk[n].desc[idx[2]].next = 0;
    80006e26:	6298                	ld	a4,0(a3)
    80006e28:	963a                	add	a2,a2,a4
    80006e2a:	00061723          	sh	zero,14(a2)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006e2e:	00ba2223          	sw	a1,4(s4)
  disk[n].info[idx[0]].b = b;
    80006e32:	0347b423          	sd	s4,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    80006e36:	6698                	ld	a4,8(a3)
    80006e38:	00275783          	lhu	a5,2(a4)
    80006e3c:	8b9d                	andi	a5,a5,7
    80006e3e:	0789                	addi	a5,a5,2
    80006e40:	0786                	slli	a5,a5,0x1
    80006e42:	97ba                	add	a5,a5,a4
    80006e44:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80006e48:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006e4c:	6698                	ld	a4,8(a3)
    80006e4e:	00275783          	lhu	a5,2(a4)
    80006e52:	2785                	addiw	a5,a5,1
    80006e54:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006e58:	0019079b          	addiw	a5,s2,1
    80006e5c:	00c7979b          	slliw	a5,a5,0xc
    80006e60:	10000737          	lui	a4,0x10000
    80006e64:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    80006e68:	97ba                	add	a5,a5,a4
    80006e6a:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006e6e:	004a2703          	lw	a4,4(s4)
    80006e72:	4785                	li	a5,1
    80006e74:	00f71d63          	bne	a4,a5,80006e8e <virtio_disk_rw+0x274>
    80006e78:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    80006e7a:	85ce                	mv	a1,s3
    80006e7c:	8552                	mv	a0,s4
    80006e7e:	ffffc097          	auipc	ra,0xffffc
    80006e82:	ab4080e7          	jalr	-1356(ra) # 80002932 <sleep>
  while(b->disk == 1) {
    80006e86:	004a2783          	lw	a5,4(s4)
    80006e8a:	fe9788e3          	beq	a5,s1,80006e7a <virtio_disk_rw+0x260>
  }

  disk[n].info[idx[0]].b = 0;
    80006e8e:	f8042483          	lw	s1,-128(s0)
    80006e92:	00191793          	slli	a5,s2,0x1
    80006e96:	97ca                	add	a5,a5,s2
    80006e98:	07a2                	slli	a5,a5,0x8
    80006e9a:	97a6                	add	a5,a5,s1
    80006e9c:	20078793          	addi	a5,a5,512
    80006ea0:	0792                	slli	a5,a5,0x4
    80006ea2:	00023717          	auipc	a4,0x23
    80006ea6:	15e70713          	addi	a4,a4,350 # 8002a000 <disk>
    80006eaa:	97ba                	add	a5,a5,a4
    80006eac:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006eb0:	00191793          	slli	a5,s2,0x1
    80006eb4:	97ca                	add	a5,a5,s2
    80006eb6:	07b2                	slli	a5,a5,0xc
    80006eb8:	97ba                	add	a5,a5,a4
    80006eba:	6a09                	lui	s4,0x2
    80006ebc:	9a3e                	add	s4,s4,a5
    free_desc(n, i);
    80006ebe:	85a6                	mv	a1,s1
    80006ec0:	854a                	mv	a0,s2
    80006ec2:	00000097          	auipc	ra,0x0
    80006ec6:	ad4080e7          	jalr	-1324(ra) # 80006996 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006eca:	0492                	slli	s1,s1,0x4
    80006ecc:	000a3783          	ld	a5,0(s4) # 2000 <_entry-0x7fffe000>
    80006ed0:	94be                	add	s1,s1,a5
    80006ed2:	00c4d783          	lhu	a5,12(s1)
    80006ed6:	8b85                	andi	a5,a5,1
    80006ed8:	c78d                	beqz	a5,80006f02 <virtio_disk_rw+0x2e8>
      i = disk[n].desc[i].next;
    80006eda:	00e4d483          	lhu	s1,14(s1)
    80006ede:	b7c5                	j	80006ebe <virtio_disk_rw+0x2a4>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006ee0:	00191793          	slli	a5,s2,0x1
    80006ee4:	97ca                	add	a5,a5,s2
    80006ee6:	07b2                	slli	a5,a5,0xc
    80006ee8:	00023717          	auipc	a4,0x23
    80006eec:	11870713          	addi	a4,a4,280 # 8002a000 <disk>
    80006ef0:	973e                	add	a4,a4,a5
    80006ef2:	6789                	lui	a5,0x2
    80006ef4:	97ba                	add	a5,a5,a4
    80006ef6:	639c                	ld	a5,0(a5)
    80006ef8:	97b2                	add	a5,a5,a2
    80006efa:	4709                	li	a4,2
    80006efc:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006f00:	bd4d                	j	80006db2 <virtio_disk_rw+0x198>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006f02:	854e                	mv	a0,s3
    80006f04:	ffffa097          	auipc	ra,0xffffa
    80006f08:	002080e7          	jalr	2(ra) # 80000f06 <release>
}
    80006f0c:	60aa                	ld	ra,136(sp)
    80006f0e:	640a                	ld	s0,128(sp)
    80006f10:	74e6                	ld	s1,120(sp)
    80006f12:	7946                	ld	s2,112(sp)
    80006f14:	79a6                	ld	s3,104(sp)
    80006f16:	7a06                	ld	s4,96(sp)
    80006f18:	6ae6                	ld	s5,88(sp)
    80006f1a:	6b46                	ld	s6,80(sp)
    80006f1c:	6ba6                	ld	s7,72(sp)
    80006f1e:	6c06                	ld	s8,64(sp)
    80006f20:	7ce2                	ld	s9,56(sp)
    80006f22:	7d42                	ld	s10,48(sp)
    80006f24:	7da2                	ld	s11,40(sp)
    80006f26:	6149                	addi	sp,sp,144
    80006f28:	8082                	ret
  if(write)
    80006f2a:	de0d9de3          	bnez	s11,80006d24 <virtio_disk_rw+0x10a>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006f2e:	f6042823          	sw	zero,-144(s0)
    80006f32:	bbe5                	j	80006d2a <virtio_disk_rw+0x110>
      disk[n].free[i] = 0;
    80006f34:	000c0c23          	sb	zero,24(s8)
    idx[i] = alloc_desc(n);
    80006f38:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    80006f3c:	b3ad                	j	80006ca6 <virtio_disk_rw+0x8c>

0000000080006f3e <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006f3e:	7139                	addi	sp,sp,-64
    80006f40:	fc06                	sd	ra,56(sp)
    80006f42:	f822                	sd	s0,48(sp)
    80006f44:	f426                	sd	s1,40(sp)
    80006f46:	f04a                	sd	s2,32(sp)
    80006f48:	ec4e                	sd	s3,24(sp)
    80006f4a:	e852                	sd	s4,16(sp)
    80006f4c:	e456                	sd	s5,8(sp)
    80006f4e:	0080                	addi	s0,sp,64
    80006f50:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006f52:	00151913          	slli	s2,a0,0x1
    80006f56:	00a90a33          	add	s4,s2,a0
    80006f5a:	0a32                	slli	s4,s4,0xc
    80006f5c:	6989                	lui	s3,0x2
    80006f5e:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006f62:	9a3e                	add	s4,s4,a5
    80006f64:	00023a97          	auipc	s5,0x23
    80006f68:	09ca8a93          	addi	s5,s5,156 # 8002a000 <disk>
    80006f6c:	9a56                	add	s4,s4,s5
    80006f6e:	8552                	mv	a0,s4
    80006f70:	ffffa097          	auipc	ra,0xffffa
    80006f74:	d4a080e7          	jalr	-694(ra) # 80000cba <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006f78:	9926                	add	s2,s2,s1
    80006f7a:	0932                	slli	s2,s2,0xc
    80006f7c:	9956                	add	s2,s2,s5
    80006f7e:	99ca                	add	s3,s3,s2
    80006f80:	0209d683          	lhu	a3,32(s3)
    80006f84:	0109b703          	ld	a4,16(s3)
    80006f88:	00275783          	lhu	a5,2(a4)
    80006f8c:	8fb5                	xor	a5,a5,a3
    80006f8e:	8b9d                	andi	a5,a5,7
    80006f90:	cbd1                	beqz	a5,80007024 <virtio_disk_intr+0xe6>
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006f92:	068e                	slli	a3,a3,0x3
    80006f94:	9736                	add	a4,a4,a3
    80006f96:	435c                	lw	a5,4(a4)

    if(disk[n].info[id].status != 0)
    80006f98:	00149713          	slli	a4,s1,0x1
    80006f9c:	9726                	add	a4,a4,s1
    80006f9e:	0722                	slli	a4,a4,0x8
    80006fa0:	973e                	add	a4,a4,a5
    80006fa2:	20070713          	addi	a4,a4,512
    80006fa6:	0712                	slli	a4,a4,0x4
    80006fa8:	9756                	add	a4,a4,s5
    80006faa:	03074703          	lbu	a4,48(a4)
    80006fae:	e33d                	bnez	a4,80007014 <virtio_disk_intr+0xd6>
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006fb0:	8956                	mv	s2,s5
    80006fb2:	00149713          	slli	a4,s1,0x1
    80006fb6:	9726                	add	a4,a4,s1
    80006fb8:	00871993          	slli	s3,a4,0x8
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006fbc:	0732                	slli	a4,a4,0xc
    80006fbe:	9756                	add	a4,a4,s5
    80006fc0:	6489                	lui	s1,0x2
    80006fc2:	94ba                	add	s1,s1,a4
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006fc4:	97ce                	add	a5,a5,s3
    80006fc6:	20078793          	addi	a5,a5,512
    80006fca:	0792                	slli	a5,a5,0x4
    80006fcc:	97ca                	add	a5,a5,s2
    80006fce:	7798                	ld	a4,40(a5)
    80006fd0:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006fd4:	7788                	ld	a0,40(a5)
    80006fd6:	ffffc097          	auipc	ra,0xffffc
    80006fda:	ae2080e7          	jalr	-1310(ra) # 80002ab8 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006fde:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006fe2:	2785                	addiw	a5,a5,1
    80006fe4:	8b9d                	andi	a5,a5,7
    80006fe6:	03079613          	slli	a2,a5,0x30
    80006fea:	9241                	srli	a2,a2,0x30
    80006fec:	02c49023          	sh	a2,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006ff0:	6898                	ld	a4,16(s1)
    80006ff2:	00275683          	lhu	a3,2(a4)
    80006ff6:	8a9d                	andi	a3,a3,7
    80006ff8:	02c68663          	beq	a3,a2,80007024 <virtio_disk_intr+0xe6>
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006ffc:	078e                	slli	a5,a5,0x3
    80006ffe:	97ba                	add	a5,a5,a4
    80007000:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80007002:	00f98733          	add	a4,s3,a5
    80007006:	20070713          	addi	a4,a4,512
    8000700a:	0712                	slli	a4,a4,0x4
    8000700c:	974a                	add	a4,a4,s2
    8000700e:	03074703          	lbu	a4,48(a4)
    80007012:	db4d                	beqz	a4,80006fc4 <virtio_disk_intr+0x86>
      panic("virtio_disk_intr status");
    80007014:	00002517          	auipc	a0,0x2
    80007018:	d7c50513          	addi	a0,a0,-644 # 80008d90 <userret+0xd00>
    8000701c:	ffff9097          	auipc	ra,0xffff9
    80007020:	768080e7          	jalr	1896(ra) # 80000784 <panic>
  }

  release(&disk[n].vdisk_lock);
    80007024:	8552                	mv	a0,s4
    80007026:	ffffa097          	auipc	ra,0xffffa
    8000702a:	ee0080e7          	jalr	-288(ra) # 80000f06 <release>
}
    8000702e:	70e2                	ld	ra,56(sp)
    80007030:	7442                	ld	s0,48(sp)
    80007032:	74a2                	ld	s1,40(sp)
    80007034:	7902                	ld	s2,32(sp)
    80007036:	69e2                	ld	s3,24(sp)
    80007038:	6a42                	ld	s4,16(sp)
    8000703a:	6aa2                	ld	s5,8(sp)
    8000703c:	6121                	addi	sp,sp,64
    8000703e:	8082                	ret

0000000080007040 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80007040:	1141                	addi	sp,sp,-16
    80007042:	e422                	sd	s0,8(sp)
    80007044:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80007046:	41f5d79b          	sraiw	a5,a1,0x1f
    8000704a:	01d7d79b          	srliw	a5,a5,0x1d
    8000704e:	9dbd                	addw	a1,a1,a5
    80007050:	0075f713          	andi	a4,a1,7
    80007054:	9f1d                	subw	a4,a4,a5
    80007056:	4785                	li	a5,1
    80007058:	00e797bb          	sllw	a5,a5,a4
    8000705c:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80007060:	4035d59b          	sraiw	a1,a1,0x3
    80007064:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80007066:	0005c503          	lbu	a0,0(a1)
    8000706a:	8d7d                	and	a0,a0,a5
    8000706c:	8d1d                	sub	a0,a0,a5
}
    8000706e:	00153513          	seqz	a0,a0
    80007072:	6422                	ld	s0,8(sp)
    80007074:	0141                	addi	sp,sp,16
    80007076:	8082                	ret

0000000080007078 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80007078:	1141                	addi	sp,sp,-16
    8000707a:	e422                	sd	s0,8(sp)
    8000707c:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000707e:	41f5d71b          	sraiw	a4,a1,0x1f
    80007082:	01d7571b          	srliw	a4,a4,0x1d
    80007086:	9db9                	addw	a1,a1,a4
    80007088:	4035d79b          	sraiw	a5,a1,0x3
    8000708c:	953e                	add	a0,a0,a5
  char m = (1 << (index % 8));
    8000708e:	899d                	andi	a1,a1,7
    80007090:	9d99                	subw	a1,a1,a4
  array[index/8] = (b | m);
    80007092:	4785                	li	a5,1
    80007094:	00b795bb          	sllw	a1,a5,a1
    80007098:	00054783          	lbu	a5,0(a0)
    8000709c:	8ddd                	or	a1,a1,a5
    8000709e:	00b50023          	sb	a1,0(a0)
}
    800070a2:	6422                	ld	s0,8(sp)
    800070a4:	0141                	addi	sp,sp,16
    800070a6:	8082                	ret

00000000800070a8 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    800070a8:	1141                	addi	sp,sp,-16
    800070aa:	e422                	sd	s0,8(sp)
    800070ac:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800070ae:	41f5d71b          	sraiw	a4,a1,0x1f
    800070b2:	01d7571b          	srliw	a4,a4,0x1d
    800070b6:	9db9                	addw	a1,a1,a4
    800070b8:	4035d79b          	sraiw	a5,a1,0x3
    800070bc:	953e                	add	a0,a0,a5
  char m = (1 << (index % 8));
    800070be:	899d                	andi	a1,a1,7
    800070c0:	9d99                	subw	a1,a1,a4
  array[index/8] = (b & ~m);
    800070c2:	4785                	li	a5,1
    800070c4:	00b795bb          	sllw	a1,a5,a1
    800070c8:	fff5c593          	not	a1,a1
    800070cc:	00054783          	lbu	a5,0(a0)
    800070d0:	8dfd                	and	a1,a1,a5
    800070d2:	00b50023          	sb	a1,0(a0)
}
    800070d6:	6422                	ld	s0,8(sp)
    800070d8:	0141                	addi	sp,sp,16
    800070da:	8082                	ret

00000000800070dc <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    800070dc:	715d                	addi	sp,sp,-80
    800070de:	e486                	sd	ra,72(sp)
    800070e0:	e0a2                	sd	s0,64(sp)
    800070e2:	fc26                	sd	s1,56(sp)
    800070e4:	f84a                	sd	s2,48(sp)
    800070e6:	f44e                	sd	s3,40(sp)
    800070e8:	f052                	sd	s4,32(sp)
    800070ea:	ec56                	sd	s5,24(sp)
    800070ec:	e85a                	sd	s6,16(sp)
    800070ee:	e45e                	sd	s7,8(sp)
    800070f0:	0880                	addi	s0,sp,80
    800070f2:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    800070f4:	08b05b63          	blez	a1,8000718a <bd_print_vector+0xae>
    800070f8:	89aa                	mv	s3,a0
    800070fa:	4481                	li	s1,0
  lb = 0;
    800070fc:	4a81                	li	s5,0
  last = 1;
    800070fe:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80007100:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80007102:	00002b97          	auipc	s7,0x2
    80007106:	ca6b8b93          	addi	s7,s7,-858 # 80008da8 <userret+0xd18>
    8000710a:	a01d                	j	80007130 <bd_print_vector+0x54>
    8000710c:	8626                	mv	a2,s1
    8000710e:	85d6                	mv	a1,s5
    80007110:	855e                	mv	a0,s7
    80007112:	ffffa097          	auipc	ra,0xffffa
    80007116:	88a080e7          	jalr	-1910(ra) # 8000099c <printf>
    lb = b;
    last = bit_isset(vector, b);
    8000711a:	85a6                	mv	a1,s1
    8000711c:	854e                	mv	a0,s3
    8000711e:	00000097          	auipc	ra,0x0
    80007122:	f22080e7          	jalr	-222(ra) # 80007040 <bit_isset>
    80007126:	892a                	mv	s2,a0
    80007128:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    8000712a:	2485                	addiw	s1,s1,1
    8000712c:	009a0d63          	beq	s4,s1,80007146 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80007130:	85a6                	mv	a1,s1
    80007132:	854e                	mv	a0,s3
    80007134:	00000097          	auipc	ra,0x0
    80007138:	f0c080e7          	jalr	-244(ra) # 80007040 <bit_isset>
    8000713c:	ff2507e3          	beq	a0,s2,8000712a <bd_print_vector+0x4e>
    if(last == 1)
    80007140:	fd691de3          	bne	s2,s6,8000711a <bd_print_vector+0x3e>
    80007144:	b7e1                	j	8000710c <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80007146:	000a8563          	beqz	s5,80007150 <bd_print_vector+0x74>
    8000714a:	4785                	li	a5,1
    8000714c:	00f91c63          	bne	s2,a5,80007164 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80007150:	8652                	mv	a2,s4
    80007152:	85d6                	mv	a1,s5
    80007154:	00002517          	auipc	a0,0x2
    80007158:	c5450513          	addi	a0,a0,-940 # 80008da8 <userret+0xd18>
    8000715c:	ffffa097          	auipc	ra,0xffffa
    80007160:	840080e7          	jalr	-1984(ra) # 8000099c <printf>
  }
  printf("\n");
    80007164:	00001517          	auipc	a0,0x1
    80007168:	4e450513          	addi	a0,a0,1252 # 80008648 <userret+0x5b8>
    8000716c:	ffffa097          	auipc	ra,0xffffa
    80007170:	830080e7          	jalr	-2000(ra) # 8000099c <printf>
}
    80007174:	60a6                	ld	ra,72(sp)
    80007176:	6406                	ld	s0,64(sp)
    80007178:	74e2                	ld	s1,56(sp)
    8000717a:	7942                	ld	s2,48(sp)
    8000717c:	79a2                	ld	s3,40(sp)
    8000717e:	7a02                	ld	s4,32(sp)
    80007180:	6ae2                	ld	s5,24(sp)
    80007182:	6b42                	ld	s6,16(sp)
    80007184:	6ba2                	ld	s7,8(sp)
    80007186:	6161                	addi	sp,sp,80
    80007188:	8082                	ret
  lb = 0;
    8000718a:	4a81                	li	s5,0
    8000718c:	b7d1                	j	80007150 <bd_print_vector+0x74>

000000008000718e <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    8000718e:	00029797          	auipc	a5,0x29
    80007192:	f1278793          	addi	a5,a5,-238 # 800300a0 <nsizes>
    80007196:	4394                	lw	a3,0(a5)
    80007198:	0ed05b63          	blez	a3,8000728e <bd_print+0x100>
bd_print() {
    8000719c:	711d                	addi	sp,sp,-96
    8000719e:	ec86                	sd	ra,88(sp)
    800071a0:	e8a2                	sd	s0,80(sp)
    800071a2:	e4a6                	sd	s1,72(sp)
    800071a4:	e0ca                	sd	s2,64(sp)
    800071a6:	fc4e                	sd	s3,56(sp)
    800071a8:	f852                	sd	s4,48(sp)
    800071aa:	f456                	sd	s5,40(sp)
    800071ac:	f05a                	sd	s6,32(sp)
    800071ae:	ec5e                	sd	s7,24(sp)
    800071b0:	e862                	sd	s8,16(sp)
    800071b2:	e466                	sd	s9,8(sp)
    800071b4:	e06a                	sd	s10,0(sp)
    800071b6:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    800071b8:	4901                	li	s2,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800071ba:	4a85                	li	s5,1
    800071bc:	4c41                	li	s8,16
    800071be:	00002b97          	auipc	s7,0x2
    800071c2:	bfab8b93          	addi	s7,s7,-1030 # 80008db8 <userret+0xd28>
    lst_print(&bd_sizes[k].free);
    800071c6:	00029a17          	auipc	s4,0x29
    800071ca:	ed2a0a13          	addi	s4,s4,-302 # 80030098 <bd_sizes>
    printf("  alloc:");
    800071ce:	00002b17          	auipc	s6,0x2
    800071d2:	c12b0b13          	addi	s6,s6,-1006 # 80008de0 <userret+0xd50>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800071d6:	89be                	mv	s3,a5
    if(k > 0) {
      printf("  split:");
    800071d8:	00002c97          	auipc	s9,0x2
    800071dc:	c18c8c93          	addi	s9,s9,-1000 # 80008df0 <userret+0xd60>
    800071e0:	a801                	j	800071f0 <bd_print+0x62>
  for (int k = 0; k < nsizes; k++) {
    800071e2:	0009a683          	lw	a3,0(s3)
    800071e6:	0905                	addi	s2,s2,1
    800071e8:	0009079b          	sext.w	a5,s2
    800071ec:	08d7d363          	ble	a3,a5,80007272 <bd_print+0xe4>
    800071f0:	0009049b          	sext.w	s1,s2
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800071f4:	36fd                	addiw	a3,a3,-1
    800071f6:	9e85                	subw	a3,a3,s1
    800071f8:	00da96bb          	sllw	a3,s5,a3
    800071fc:	009c1633          	sll	a2,s8,s1
    80007200:	85a6                	mv	a1,s1
    80007202:	855e                	mv	a0,s7
    80007204:	ffff9097          	auipc	ra,0xffff9
    80007208:	798080e7          	jalr	1944(ra) # 8000099c <printf>
    lst_print(&bd_sizes[k].free);
    8000720c:	00591d13          	slli	s10,s2,0x5
    80007210:	000a3503          	ld	a0,0(s4)
    80007214:	956a                	add	a0,a0,s10
    80007216:	00001097          	auipc	ra,0x1
    8000721a:	a80080e7          	jalr	-1408(ra) # 80007c96 <lst_print>
    printf("  alloc:");
    8000721e:	855a                	mv	a0,s6
    80007220:	ffff9097          	auipc	ra,0xffff9
    80007224:	77c080e7          	jalr	1916(ra) # 8000099c <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80007228:	0009a583          	lw	a1,0(s3)
    8000722c:	35fd                	addiw	a1,a1,-1
    8000722e:	9d85                	subw	a1,a1,s1
    80007230:	000a3783          	ld	a5,0(s4)
    80007234:	97ea                	add	a5,a5,s10
    80007236:	00ba95bb          	sllw	a1,s5,a1
    8000723a:	6b88                	ld	a0,16(a5)
    8000723c:	00000097          	auipc	ra,0x0
    80007240:	ea0080e7          	jalr	-352(ra) # 800070dc <bd_print_vector>
    if(k > 0) {
    80007244:	f8905fe3          	blez	s1,800071e2 <bd_print+0x54>
      printf("  split:");
    80007248:	8566                	mv	a0,s9
    8000724a:	ffff9097          	auipc	ra,0xffff9
    8000724e:	752080e7          	jalr	1874(ra) # 8000099c <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80007252:	0009a583          	lw	a1,0(s3)
    80007256:	35fd                	addiw	a1,a1,-1
    80007258:	9d85                	subw	a1,a1,s1
    8000725a:	000a3783          	ld	a5,0(s4)
    8000725e:	9d3e                	add	s10,s10,a5
    80007260:	00ba95bb          	sllw	a1,s5,a1
    80007264:	018d3503          	ld	a0,24(s10) # 1018 <_entry-0x7fffefe8>
    80007268:	00000097          	auipc	ra,0x0
    8000726c:	e74080e7          	jalr	-396(ra) # 800070dc <bd_print_vector>
    80007270:	bf8d                	j	800071e2 <bd_print+0x54>
    }
  }
}
    80007272:	60e6                	ld	ra,88(sp)
    80007274:	6446                	ld	s0,80(sp)
    80007276:	64a6                	ld	s1,72(sp)
    80007278:	6906                	ld	s2,64(sp)
    8000727a:	79e2                	ld	s3,56(sp)
    8000727c:	7a42                	ld	s4,48(sp)
    8000727e:	7aa2                	ld	s5,40(sp)
    80007280:	7b02                	ld	s6,32(sp)
    80007282:	6be2                	ld	s7,24(sp)
    80007284:	6c42                	ld	s8,16(sp)
    80007286:	6ca2                	ld	s9,8(sp)
    80007288:	6d02                	ld	s10,0(sp)
    8000728a:	6125                	addi	sp,sp,96
    8000728c:	8082                	ret
    8000728e:	8082                	ret

0000000080007290 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80007290:	1141                	addi	sp,sp,-16
    80007292:	e422                	sd	s0,8(sp)
    80007294:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80007296:	47c1                	li	a5,16
    80007298:	00a7fb63          	bleu	a0,a5,800072ae <firstk+0x1e>
  int k = 0;
    8000729c:	4701                	li	a4,0
    k++;
    8000729e:	2705                	addiw	a4,a4,1
    size *= 2;
    800072a0:	0786                	slli	a5,a5,0x1
  while (size < n) {
    800072a2:	fea7eee3          	bltu	a5,a0,8000729e <firstk+0xe>
  }
  return k;
}
    800072a6:	853a                	mv	a0,a4
    800072a8:	6422                	ld	s0,8(sp)
    800072aa:	0141                	addi	sp,sp,16
    800072ac:	8082                	ret
  int k = 0;
    800072ae:	4701                	li	a4,0
    800072b0:	bfdd                	j	800072a6 <firstk+0x16>

00000000800072b2 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    800072b2:	1141                	addi	sp,sp,-16
    800072b4:	e422                	sd	s0,8(sp)
    800072b6:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
    800072b8:	00029797          	auipc	a5,0x29
    800072bc:	dd878793          	addi	a5,a5,-552 # 80030090 <bd_base>
    800072c0:	639c                	ld	a5,0(a5)
  return n / BLK_SIZE(k);
    800072c2:	9d9d                	subw	a1,a1,a5
    800072c4:	47c1                	li	a5,16
    800072c6:	00a79533          	sll	a0,a5,a0
    800072ca:	02a5c533          	div	a0,a1,a0
}
    800072ce:	2501                	sext.w	a0,a0
    800072d0:	6422                	ld	s0,8(sp)
    800072d2:	0141                	addi	sp,sp,16
    800072d4:	8082                	ret

00000000800072d6 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    800072d6:	1141                	addi	sp,sp,-16
    800072d8:	e422                	sd	s0,8(sp)
    800072da:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    800072dc:	47c1                	li	a5,16
    800072de:	00a79533          	sll	a0,a5,a0
  return (char *) bd_base + n;
    800072e2:	02a5853b          	mulw	a0,a1,a0
    800072e6:	00029797          	auipc	a5,0x29
    800072ea:	daa78793          	addi	a5,a5,-598 # 80030090 <bd_base>
    800072ee:	639c                	ld	a5,0(a5)
}
    800072f0:	953e                	add	a0,a0,a5
    800072f2:	6422                	ld	s0,8(sp)
    800072f4:	0141                	addi	sp,sp,16
    800072f6:	8082                	ret

00000000800072f8 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    800072f8:	7159                	addi	sp,sp,-112
    800072fa:	f486                	sd	ra,104(sp)
    800072fc:	f0a2                	sd	s0,96(sp)
    800072fe:	eca6                	sd	s1,88(sp)
    80007300:	e8ca                	sd	s2,80(sp)
    80007302:	e4ce                	sd	s3,72(sp)
    80007304:	e0d2                	sd	s4,64(sp)
    80007306:	fc56                	sd	s5,56(sp)
    80007308:	f85a                	sd	s6,48(sp)
    8000730a:	f45e                	sd	s7,40(sp)
    8000730c:	f062                	sd	s8,32(sp)
    8000730e:	ec66                	sd	s9,24(sp)
    80007310:	e86a                	sd	s10,16(sp)
    80007312:	e46e                	sd	s11,8(sp)
    80007314:	1880                	addi	s0,sp,112
    80007316:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80007318:	00029517          	auipc	a0,0x29
    8000731c:	ce850513          	addi	a0,a0,-792 # 80030000 <lock>
    80007320:	ffffa097          	auipc	ra,0xffffa
    80007324:	99a080e7          	jalr	-1638(ra) # 80000cba <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80007328:	8526                	mv	a0,s1
    8000732a:	00000097          	auipc	ra,0x0
    8000732e:	f66080e7          	jalr	-154(ra) # 80007290 <firstk>
  for (k = fk; k < nsizes; k++) {
    80007332:	00029797          	auipc	a5,0x29
    80007336:	d6e78793          	addi	a5,a5,-658 # 800300a0 <nsizes>
    8000733a:	439c                	lw	a5,0(a5)
    8000733c:	02f55d63          	ble	a5,a0,80007376 <bd_malloc+0x7e>
    80007340:	8d2a                	mv	s10,a0
    80007342:	00551913          	slli	s2,a0,0x5
    80007346:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80007348:	00029997          	auipc	s3,0x29
    8000734c:	d5098993          	addi	s3,s3,-688 # 80030098 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80007350:	00029a17          	auipc	s4,0x29
    80007354:	d50a0a13          	addi	s4,s4,-688 # 800300a0 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80007358:	0009b503          	ld	a0,0(s3)
    8000735c:	954a                	add	a0,a0,s2
    8000735e:	00001097          	auipc	ra,0x1
    80007362:	8be080e7          	jalr	-1858(ra) # 80007c1c <lst_empty>
    80007366:	c115                	beqz	a0,8000738a <bd_malloc+0x92>
  for (k = fk; k < nsizes; k++) {
    80007368:	2485                	addiw	s1,s1,1
    8000736a:	02090913          	addi	s2,s2,32
    8000736e:	000a2783          	lw	a5,0(s4)
    80007372:	fef4c3e3          	blt	s1,a5,80007358 <bd_malloc+0x60>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80007376:	00029517          	auipc	a0,0x29
    8000737a:	c8a50513          	addi	a0,a0,-886 # 80030000 <lock>
    8000737e:	ffffa097          	auipc	ra,0xffffa
    80007382:	b88080e7          	jalr	-1144(ra) # 80000f06 <release>
    return 0;
    80007386:	4b81                	li	s7,0
    80007388:	a8d1                	j	8000745c <bd_malloc+0x164>
  if(k >= nsizes) { // No free blocks?
    8000738a:	00029797          	auipc	a5,0x29
    8000738e:	d1678793          	addi	a5,a5,-746 # 800300a0 <nsizes>
    80007392:	439c                	lw	a5,0(a5)
    80007394:	fef4d1e3          	ble	a5,s1,80007376 <bd_malloc+0x7e>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80007398:	00549993          	slli	s3,s1,0x5
    8000739c:	00029917          	auipc	s2,0x29
    800073a0:	cfc90913          	addi	s2,s2,-772 # 80030098 <bd_sizes>
    800073a4:	00093503          	ld	a0,0(s2)
    800073a8:	954e                	add	a0,a0,s3
    800073aa:	00001097          	auipc	ra,0x1
    800073ae:	89e080e7          	jalr	-1890(ra) # 80007c48 <lst_pop>
    800073b2:	8baa                	mv	s7,a0
  int n = p - (char *) bd_base;
    800073b4:	00029797          	auipc	a5,0x29
    800073b8:	cdc78793          	addi	a5,a5,-804 # 80030090 <bd_base>
    800073bc:	638c                	ld	a1,0(a5)
  return n / BLK_SIZE(k);
    800073be:	40b505bb          	subw	a1,a0,a1
    800073c2:	47c1                	li	a5,16
    800073c4:	009797b3          	sll	a5,a5,s1
    800073c8:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    800073cc:	00093783          	ld	a5,0(s2)
    800073d0:	97ce                	add	a5,a5,s3
    800073d2:	2581                	sext.w	a1,a1
    800073d4:	6b88                	ld	a0,16(a5)
    800073d6:	00000097          	auipc	ra,0x0
    800073da:	ca2080e7          	jalr	-862(ra) # 80007078 <bit_set>
  for(; k > fk; k--) {
    800073de:	069d5763          	ble	s1,s10,8000744c <bd_malloc+0x154>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800073e2:	4c41                	li	s8,16
  int n = p - (char *) bd_base;
    800073e4:	00029d97          	auipc	s11,0x29
    800073e8:	cacd8d93          	addi	s11,s11,-852 # 80030090 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800073ec:	fff48a9b          	addiw	s5,s1,-1
    800073f0:	015c1b33          	sll	s6,s8,s5
    800073f4:	016b8cb3          	add	s9,s7,s6
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800073f8:	00029797          	auipc	a5,0x29
    800073fc:	ca078793          	addi	a5,a5,-864 # 80030098 <bd_sizes>
    80007400:	0007ba03          	ld	s4,0(a5)
  int n = p - (char *) bd_base;
    80007404:	000db903          	ld	s2,0(s11)
  return n / BLK_SIZE(k);
    80007408:	412b893b          	subw	s2,s7,s2
    8000740c:	009c15b3          	sll	a1,s8,s1
    80007410:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80007414:	013a07b3          	add	a5,s4,s3
    80007418:	2581                	sext.w	a1,a1
    8000741a:	6f88                	ld	a0,24(a5)
    8000741c:	00000097          	auipc	ra,0x0
    80007420:	c5c080e7          	jalr	-932(ra) # 80007078 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80007424:	1981                	addi	s3,s3,-32
    80007426:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80007428:	036945b3          	div	a1,s2,s6
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    8000742c:	2581                	sext.w	a1,a1
    8000742e:	010a3503          	ld	a0,16(s4)
    80007432:	00000097          	auipc	ra,0x0
    80007436:	c46080e7          	jalr	-954(ra) # 80007078 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    8000743a:	85e6                	mv	a1,s9
    8000743c:	8552                	mv	a0,s4
    8000743e:	00001097          	auipc	ra,0x1
    80007442:	840080e7          	jalr	-1984(ra) # 80007c7e <lst_push>
  for(; k > fk; k--) {
    80007446:	84d6                	mv	s1,s5
    80007448:	fbaa92e3          	bne	s5,s10,800073ec <bd_malloc+0xf4>
  }
  release(&lock);
    8000744c:	00029517          	auipc	a0,0x29
    80007450:	bb450513          	addi	a0,a0,-1100 # 80030000 <lock>
    80007454:	ffffa097          	auipc	ra,0xffffa
    80007458:	ab2080e7          	jalr	-1358(ra) # 80000f06 <release>

  return p;
}
    8000745c:	855e                	mv	a0,s7
    8000745e:	70a6                	ld	ra,104(sp)
    80007460:	7406                	ld	s0,96(sp)
    80007462:	64e6                	ld	s1,88(sp)
    80007464:	6946                	ld	s2,80(sp)
    80007466:	69a6                	ld	s3,72(sp)
    80007468:	6a06                	ld	s4,64(sp)
    8000746a:	7ae2                	ld	s5,56(sp)
    8000746c:	7b42                	ld	s6,48(sp)
    8000746e:	7ba2                	ld	s7,40(sp)
    80007470:	7c02                	ld	s8,32(sp)
    80007472:	6ce2                	ld	s9,24(sp)
    80007474:	6d42                	ld	s10,16(sp)
    80007476:	6da2                	ld	s11,8(sp)
    80007478:	6165                	addi	sp,sp,112
    8000747a:	8082                	ret

000000008000747c <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    8000747c:	7139                	addi	sp,sp,-64
    8000747e:	fc06                	sd	ra,56(sp)
    80007480:	f822                	sd	s0,48(sp)
    80007482:	f426                	sd	s1,40(sp)
    80007484:	f04a                	sd	s2,32(sp)
    80007486:	ec4e                	sd	s3,24(sp)
    80007488:	e852                	sd	s4,16(sp)
    8000748a:	e456                	sd	s5,8(sp)
    8000748c:	e05a                	sd	s6,0(sp)
    8000748e:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80007490:	00029797          	auipc	a5,0x29
    80007494:	c1078793          	addi	a5,a5,-1008 # 800300a0 <nsizes>
    80007498:	0007aa83          	lw	s5,0(a5)
  int n = p - (char *) bd_base;
    8000749c:	00029797          	auipc	a5,0x29
    800074a0:	bf478793          	addi	a5,a5,-1036 # 80030090 <bd_base>
    800074a4:	0007ba03          	ld	s4,0(a5)
  return n / BLK_SIZE(k);
    800074a8:	41450a3b          	subw	s4,a0,s4
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800074ac:	00029797          	auipc	a5,0x29
    800074b0:	bec78793          	addi	a5,a5,-1044 # 80030098 <bd_sizes>
    800074b4:	6384                	ld	s1,0(a5)
    800074b6:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    800074ba:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    800074bc:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    800074be:	03595363          	ble	s5,s2,800074e4 <size+0x68>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800074c2:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    800074c6:	013b15b3          	sll	a1,s6,s3
    800074ca:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800074ce:	2581                	sext.w	a1,a1
    800074d0:	6088                	ld	a0,0(s1)
    800074d2:	00000097          	auipc	ra,0x0
    800074d6:	b6e080e7          	jalr	-1170(ra) # 80007040 <bit_isset>
    800074da:	02048493          	addi	s1,s1,32
    800074de:	e501                	bnez	a0,800074e6 <size+0x6a>
  for (int k = 0; k < nsizes; k++) {
    800074e0:	894e                	mv	s2,s3
    800074e2:	bff1                	j	800074be <size+0x42>
      return k;
    }
  }
  return 0;
    800074e4:	4901                	li	s2,0
}
    800074e6:	854a                	mv	a0,s2
    800074e8:	70e2                	ld	ra,56(sp)
    800074ea:	7442                	ld	s0,48(sp)
    800074ec:	74a2                	ld	s1,40(sp)
    800074ee:	7902                	ld	s2,32(sp)
    800074f0:	69e2                	ld	s3,24(sp)
    800074f2:	6a42                	ld	s4,16(sp)
    800074f4:	6aa2                	ld	s5,8(sp)
    800074f6:	6b02                	ld	s6,0(sp)
    800074f8:	6121                	addi	sp,sp,64
    800074fa:	8082                	ret

00000000800074fc <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    800074fc:	7159                	addi	sp,sp,-112
    800074fe:	f486                	sd	ra,104(sp)
    80007500:	f0a2                	sd	s0,96(sp)
    80007502:	eca6                	sd	s1,88(sp)
    80007504:	e8ca                	sd	s2,80(sp)
    80007506:	e4ce                	sd	s3,72(sp)
    80007508:	e0d2                	sd	s4,64(sp)
    8000750a:	fc56                	sd	s5,56(sp)
    8000750c:	f85a                	sd	s6,48(sp)
    8000750e:	f45e                	sd	s7,40(sp)
    80007510:	f062                	sd	s8,32(sp)
    80007512:	ec66                	sd	s9,24(sp)
    80007514:	e86a                	sd	s10,16(sp)
    80007516:	e46e                	sd	s11,8(sp)
    80007518:	1880                	addi	s0,sp,112
    8000751a:	8b2a                	mv	s6,a0
  void *q;
  int k;

  acquire(&lock);
    8000751c:	00029517          	auipc	a0,0x29
    80007520:	ae450513          	addi	a0,a0,-1308 # 80030000 <lock>
    80007524:	ffff9097          	auipc	ra,0xffff9
    80007528:	796080e7          	jalr	1942(ra) # 80000cba <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    8000752c:	855a                	mv	a0,s6
    8000752e:	00000097          	auipc	ra,0x0
    80007532:	f4e080e7          	jalr	-178(ra) # 8000747c <size>
    80007536:	892a                	mv	s2,a0
    80007538:	00029797          	auipc	a5,0x29
    8000753c:	b6878793          	addi	a5,a5,-1176 # 800300a0 <nsizes>
    80007540:	439c                	lw	a5,0(a5)
    80007542:	37fd                	addiw	a5,a5,-1
    80007544:	0af55a63          	ble	a5,a0,800075f8 <bd_free+0xfc>
    80007548:	00551a93          	slli	s5,a0,0x5
  int n = p - (char *) bd_base;
    8000754c:	00029c97          	auipc	s9,0x29
    80007550:	b44c8c93          	addi	s9,s9,-1212 # 80030090 <bd_base>
  return n / BLK_SIZE(k);
    80007554:	4c41                	li	s8,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007556:	00029b97          	auipc	s7,0x29
    8000755a:	b42b8b93          	addi	s7,s7,-1214 # 80030098 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    8000755e:	00029d17          	auipc	s10,0x29
    80007562:	b42d0d13          	addi	s10,s10,-1214 # 800300a0 <nsizes>
    80007566:	a82d                	j	800075a0 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007568:	fff5849b          	addiw	s1,a1,-1
    8000756c:	a881                	j	800075bc <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    8000756e:	020a8a93          	addi	s5,s5,32
    80007572:	2905                	addiw	s2,s2,1
  int n = p - (char *) bd_base;
    80007574:	000cb583          	ld	a1,0(s9)
  return n / BLK_SIZE(k);
    80007578:	40bb05bb          	subw	a1,s6,a1
    8000757c:	012c17b3          	sll	a5,s8,s2
    80007580:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007584:	000bb783          	ld	a5,0(s7)
    80007588:	97d6                	add	a5,a5,s5
    8000758a:	2581                	sext.w	a1,a1
    8000758c:	6f88                	ld	a0,24(a5)
    8000758e:	00000097          	auipc	ra,0x0
    80007592:	b1a080e7          	jalr	-1254(ra) # 800070a8 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80007596:	000d2783          	lw	a5,0(s10)
    8000759a:	37fd                	addiw	a5,a5,-1
    8000759c:	04f95e63          	ble	a5,s2,800075f8 <bd_free+0xfc>
  int n = p - (char *) bd_base;
    800075a0:	000cb983          	ld	s3,0(s9)
  return n / BLK_SIZE(k);
    800075a4:	012c1a33          	sll	s4,s8,s2
    800075a8:	413b07bb          	subw	a5,s6,s3
    800075ac:	0347c7b3          	div	a5,a5,s4
    800075b0:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800075b4:	8b85                	andi	a5,a5,1
    800075b6:	fbcd                	bnez	a5,80007568 <bd_free+0x6c>
    800075b8:	0015849b          	addiw	s1,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    800075bc:	000bbd83          	ld	s11,0(s7)
    800075c0:	9dd6                	add	s11,s11,s5
    800075c2:	010db503          	ld	a0,16(s11)
    800075c6:	00000097          	auipc	ra,0x0
    800075ca:	ae2080e7          	jalr	-1310(ra) # 800070a8 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    800075ce:	85a6                	mv	a1,s1
    800075d0:	010db503          	ld	a0,16(s11)
    800075d4:	00000097          	auipc	ra,0x0
    800075d8:	a6c080e7          	jalr	-1428(ra) # 80007040 <bit_isset>
    800075dc:	ed11                	bnez	a0,800075f8 <bd_free+0xfc>
  int n = bi * BLK_SIZE(k);
    800075de:	2481                	sext.w	s1,s1
  return (char *) bd_base + n;
    800075e0:	029a0a3b          	mulw	s4,s4,s1
    800075e4:	99d2                	add	s3,s3,s4
    lst_remove(q);    // remove buddy from free list
    800075e6:	854e                	mv	a0,s3
    800075e8:	00000097          	auipc	ra,0x0
    800075ec:	64a080e7          	jalr	1610(ra) # 80007c32 <lst_remove>
    if(buddy % 2 == 0) {
    800075f0:	8885                	andi	s1,s1,1
    800075f2:	fcb5                	bnez	s1,8000756e <bd_free+0x72>
      p = q;
    800075f4:	8b4e                	mv	s6,s3
    800075f6:	bfa5                	j	8000756e <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    800075f8:	0916                	slli	s2,s2,0x5
    800075fa:	00029797          	auipc	a5,0x29
    800075fe:	a9e78793          	addi	a5,a5,-1378 # 80030098 <bd_sizes>
    80007602:	6388                	ld	a0,0(a5)
    80007604:	85da                	mv	a1,s6
    80007606:	954a                	add	a0,a0,s2
    80007608:	00000097          	auipc	ra,0x0
    8000760c:	676080e7          	jalr	1654(ra) # 80007c7e <lst_push>
  release(&lock);
    80007610:	00029517          	auipc	a0,0x29
    80007614:	9f050513          	addi	a0,a0,-1552 # 80030000 <lock>
    80007618:	ffffa097          	auipc	ra,0xffffa
    8000761c:	8ee080e7          	jalr	-1810(ra) # 80000f06 <release>
}
    80007620:	70a6                	ld	ra,104(sp)
    80007622:	7406                	ld	s0,96(sp)
    80007624:	64e6                	ld	s1,88(sp)
    80007626:	6946                	ld	s2,80(sp)
    80007628:	69a6                	ld	s3,72(sp)
    8000762a:	6a06                	ld	s4,64(sp)
    8000762c:	7ae2                	ld	s5,56(sp)
    8000762e:	7b42                	ld	s6,48(sp)
    80007630:	7ba2                	ld	s7,40(sp)
    80007632:	7c02                	ld	s8,32(sp)
    80007634:	6ce2                	ld	s9,24(sp)
    80007636:	6d42                	ld	s10,16(sp)
    80007638:	6da2                	ld	s11,8(sp)
    8000763a:	6165                	addi	sp,sp,112
    8000763c:	8082                	ret

000000008000763e <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    8000763e:	1141                	addi	sp,sp,-16
    80007640:	e422                	sd	s0,8(sp)
    80007642:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80007644:	00029797          	auipc	a5,0x29
    80007648:	a4c78793          	addi	a5,a5,-1460 # 80030090 <bd_base>
    8000764c:	639c                	ld	a5,0(a5)
    8000764e:	8d9d                	sub	a1,a1,a5
    80007650:	47c1                	li	a5,16
    80007652:	00a797b3          	sll	a5,a5,a0
    80007656:	02f5c533          	div	a0,a1,a5
    8000765a:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    8000765c:	02f5e5b3          	rem	a1,a1,a5
    80007660:	c191                	beqz	a1,80007664 <blk_index_next+0x26>
      n++;
    80007662:	2505                	addiw	a0,a0,1
  return n ;
}
    80007664:	6422                	ld	s0,8(sp)
    80007666:	0141                	addi	sp,sp,16
    80007668:	8082                	ret

000000008000766a <log2>:

int
log2(uint64 n) {
    8000766a:	1141                	addi	sp,sp,-16
    8000766c:	e422                	sd	s0,8(sp)
    8000766e:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80007670:	4705                	li	a4,1
    80007672:	00a77b63          	bleu	a0,a4,80007688 <log2+0x1e>
    80007676:	87aa                	mv	a5,a0
  int k = 0;
    80007678:	4501                	li	a0,0
    k++;
    8000767a:	2505                	addiw	a0,a0,1
    n = n >> 1;
    8000767c:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    8000767e:	fef76ee3          	bltu	a4,a5,8000767a <log2+0x10>
  }
  return k;
}
    80007682:	6422                	ld	s0,8(sp)
    80007684:	0141                	addi	sp,sp,16
    80007686:	8082                	ret
  int k = 0;
    80007688:	4501                	li	a0,0
    8000768a:	bfe5                	j	80007682 <log2+0x18>

000000008000768c <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    8000768c:	711d                	addi	sp,sp,-96
    8000768e:	ec86                	sd	ra,88(sp)
    80007690:	e8a2                	sd	s0,80(sp)
    80007692:	e4a6                	sd	s1,72(sp)
    80007694:	e0ca                	sd	s2,64(sp)
    80007696:	fc4e                	sd	s3,56(sp)
    80007698:	f852                	sd	s4,48(sp)
    8000769a:	f456                	sd	s5,40(sp)
    8000769c:	f05a                	sd	s6,32(sp)
    8000769e:	ec5e                	sd	s7,24(sp)
    800076a0:	e862                	sd	s8,16(sp)
    800076a2:	e466                	sd	s9,8(sp)
    800076a4:	e06a                	sd	s10,0(sp)
    800076a6:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    800076a8:	00b56933          	or	s2,a0,a1
    800076ac:	00f97913          	andi	s2,s2,15
    800076b0:	04091463          	bnez	s2,800076f8 <bd_mark+0x6c>
    800076b4:	8baa                	mv	s7,a0
    800076b6:	8c2e                	mv	s8,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    800076b8:	00029797          	auipc	a5,0x29
    800076bc:	9e878793          	addi	a5,a5,-1560 # 800300a0 <nsizes>
    800076c0:	0007ab03          	lw	s6,0(a5)
    800076c4:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    800076c6:	00029d17          	auipc	s10,0x29
    800076ca:	9cad0d13          	addi	s10,s10,-1590 # 80030090 <bd_base>
  return n / BLK_SIZE(k);
    800076ce:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    800076d0:	00029a17          	auipc	s4,0x29
    800076d4:	9c8a0a13          	addi	s4,s4,-1592 # 80030098 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    800076d8:	07604563          	bgtz	s6,80007742 <bd_mark+0xb6>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    800076dc:	60e6                	ld	ra,88(sp)
    800076de:	6446                	ld	s0,80(sp)
    800076e0:	64a6                	ld	s1,72(sp)
    800076e2:	6906                	ld	s2,64(sp)
    800076e4:	79e2                	ld	s3,56(sp)
    800076e6:	7a42                	ld	s4,48(sp)
    800076e8:	7aa2                	ld	s5,40(sp)
    800076ea:	7b02                	ld	s6,32(sp)
    800076ec:	6be2                	ld	s7,24(sp)
    800076ee:	6c42                	ld	s8,16(sp)
    800076f0:	6ca2                	ld	s9,8(sp)
    800076f2:	6d02                	ld	s10,0(sp)
    800076f4:	6125                	addi	sp,sp,96
    800076f6:	8082                	ret
    panic("bd_mark");
    800076f8:	00001517          	auipc	a0,0x1
    800076fc:	70850513          	addi	a0,a0,1800 # 80008e00 <userret+0xd70>
    80007700:	ffff9097          	auipc	ra,0xffff9
    80007704:	084080e7          	jalr	132(ra) # 80000784 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80007708:	000a3783          	ld	a5,0(s4)
    8000770c:	97ca                	add	a5,a5,s2
    8000770e:	85a6                	mv	a1,s1
    80007710:	6b88                	ld	a0,16(a5)
    80007712:	00000097          	auipc	ra,0x0
    80007716:	966080e7          	jalr	-1690(ra) # 80007078 <bit_set>
    for(; bi < bj; bi++) {
    8000771a:	2485                	addiw	s1,s1,1
    8000771c:	009a8e63          	beq	s5,s1,80007738 <bd_mark+0xac>
      if(k > 0) {
    80007720:	ff3054e3          	blez	s3,80007708 <bd_mark+0x7c>
        bit_set(bd_sizes[k].split, bi);
    80007724:	000a3783          	ld	a5,0(s4)
    80007728:	97ca                	add	a5,a5,s2
    8000772a:	85a6                	mv	a1,s1
    8000772c:	6f88                	ld	a0,24(a5)
    8000772e:	00000097          	auipc	ra,0x0
    80007732:	94a080e7          	jalr	-1718(ra) # 80007078 <bit_set>
    80007736:	bfc9                	j	80007708 <bd_mark+0x7c>
  for (int k = 0; k < nsizes; k++) {
    80007738:	2985                	addiw	s3,s3,1
    8000773a:	02090913          	addi	s2,s2,32
    8000773e:	f9698fe3          	beq	s3,s6,800076dc <bd_mark+0x50>
  int n = p - (char *) bd_base;
    80007742:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80007746:	409b84bb          	subw	s1,s7,s1
    8000774a:	013c97b3          	sll	a5,s9,s3
    8000774e:	02f4c4b3          	div	s1,s1,a5
    80007752:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80007754:	85e2                	mv	a1,s8
    80007756:	854e                	mv	a0,s3
    80007758:	00000097          	auipc	ra,0x0
    8000775c:	ee6080e7          	jalr	-282(ra) # 8000763e <blk_index_next>
    80007760:	8aaa                	mv	s5,a0
    for(; bi < bj; bi++) {
    80007762:	faa4cfe3          	blt	s1,a0,80007720 <bd_mark+0x94>
    80007766:	bfc9                	j	80007738 <bd_mark+0xac>

0000000080007768 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80007768:	7139                	addi	sp,sp,-64
    8000776a:	fc06                	sd	ra,56(sp)
    8000776c:	f822                	sd	s0,48(sp)
    8000776e:	f426                	sd	s1,40(sp)
    80007770:	f04a                	sd	s2,32(sp)
    80007772:	ec4e                	sd	s3,24(sp)
    80007774:	e852                	sd	s4,16(sp)
    80007776:	e456                	sd	s5,8(sp)
    80007778:	e05a                	sd	s6,0(sp)
    8000777a:	0080                	addi	s0,sp,64
    8000777c:	8b2a                	mv	s6,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000777e:	00058a1b          	sext.w	s4,a1
    80007782:	001a7793          	andi	a5,s4,1
    80007786:	ebbd                	bnez	a5,800077fc <bd_initfree_pair+0x94>
    80007788:	00158a9b          	addiw	s5,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    8000778c:	005b1493          	slli	s1,s6,0x5
    80007790:	00029797          	auipc	a5,0x29
    80007794:	90878793          	addi	a5,a5,-1784 # 80030098 <bd_sizes>
    80007798:	639c                	ld	a5,0(a5)
    8000779a:	94be                	add	s1,s1,a5
    8000779c:	0104b903          	ld	s2,16(s1)
    800077a0:	854a                	mv	a0,s2
    800077a2:	00000097          	auipc	ra,0x0
    800077a6:	89e080e7          	jalr	-1890(ra) # 80007040 <bit_isset>
    800077aa:	89aa                	mv	s3,a0
    800077ac:	85d6                	mv	a1,s5
    800077ae:	854a                	mv	a0,s2
    800077b0:	00000097          	auipc	ra,0x0
    800077b4:	890080e7          	jalr	-1904(ra) # 80007040 <bit_isset>
  int free = 0;
    800077b8:	4901                	li	s2,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    800077ba:	02a98663          	beq	s3,a0,800077e6 <bd_initfree_pair+0x7e>
    // one of the pair is free
    free = BLK_SIZE(k);
    800077be:	45c1                	li	a1,16
    800077c0:	016595b3          	sll	a1,a1,s6
    800077c4:	0005891b          	sext.w	s2,a1
    if(bit_isset(bd_sizes[k].alloc, bi))
    800077c8:	02098d63          	beqz	s3,80007802 <bd_initfree_pair+0x9a>
  return (char *) bd_base + n;
    800077cc:	035585bb          	mulw	a1,a1,s5
    800077d0:	00029797          	auipc	a5,0x29
    800077d4:	8c078793          	addi	a5,a5,-1856 # 80030090 <bd_base>
    800077d8:	639c                	ld	a5,0(a5)
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    800077da:	95be                	add	a1,a1,a5
    800077dc:	8526                	mv	a0,s1
    800077de:	00000097          	auipc	ra,0x0
    800077e2:	4a0080e7          	jalr	1184(ra) # 80007c7e <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    800077e6:	854a                	mv	a0,s2
    800077e8:	70e2                	ld	ra,56(sp)
    800077ea:	7442                	ld	s0,48(sp)
    800077ec:	74a2                	ld	s1,40(sp)
    800077ee:	7902                	ld	s2,32(sp)
    800077f0:	69e2                	ld	s3,24(sp)
    800077f2:	6a42                	ld	s4,16(sp)
    800077f4:	6aa2                	ld	s5,8(sp)
    800077f6:	6b02                	ld	s6,0(sp)
    800077f8:	6121                	addi	sp,sp,64
    800077fa:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800077fc:	fff58a9b          	addiw	s5,a1,-1
    80007800:	b771                	j	8000778c <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80007802:	034585bb          	mulw	a1,a1,s4
    80007806:	00029797          	auipc	a5,0x29
    8000780a:	88a78793          	addi	a5,a5,-1910 # 80030090 <bd_base>
    8000780e:	639c                	ld	a5,0(a5)
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80007810:	95be                	add	a1,a1,a5
    80007812:	8526                	mv	a0,s1
    80007814:	00000097          	auipc	ra,0x0
    80007818:	46a080e7          	jalr	1130(ra) # 80007c7e <lst_push>
    8000781c:	b7e9                	j	800077e6 <bd_initfree_pair+0x7e>

000000008000781e <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    8000781e:	711d                	addi	sp,sp,-96
    80007820:	ec86                	sd	ra,88(sp)
    80007822:	e8a2                	sd	s0,80(sp)
    80007824:	e4a6                	sd	s1,72(sp)
    80007826:	e0ca                	sd	s2,64(sp)
    80007828:	fc4e                	sd	s3,56(sp)
    8000782a:	f852                	sd	s4,48(sp)
    8000782c:	f456                	sd	s5,40(sp)
    8000782e:	f05a                	sd	s6,32(sp)
    80007830:	ec5e                	sd	s7,24(sp)
    80007832:	e862                	sd	s8,16(sp)
    80007834:	e466                	sd	s9,8(sp)
    80007836:	e06a                	sd	s10,0(sp)
    80007838:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    8000783a:	00029797          	auipc	a5,0x29
    8000783e:	86678793          	addi	a5,a5,-1946 # 800300a0 <nsizes>
    80007842:	4398                	lw	a4,0(a5)
    80007844:	4785                	li	a5,1
    80007846:	06e7db63          	ble	a4,a5,800078bc <bd_initfree+0x9e>
    8000784a:	8b2e                	mv	s6,a1
    8000784c:	8aaa                	mv	s5,a0
    8000784e:	4901                	li	s2,0
  int free = 0;
    80007850:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80007852:	00029c97          	auipc	s9,0x29
    80007856:	83ec8c93          	addi	s9,s9,-1986 # 80030090 <bd_base>
  return n / BLK_SIZE(k);
    8000785a:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    8000785c:	00029b97          	auipc	s7,0x29
    80007860:	844b8b93          	addi	s7,s7,-1980 # 800300a0 <nsizes>
    80007864:	a039                	j	80007872 <bd_initfree+0x54>
    80007866:	2905                	addiw	s2,s2,1
    80007868:	000ba783          	lw	a5,0(s7)
    8000786c:	37fd                	addiw	a5,a5,-1
    8000786e:	04f95863          	ble	a5,s2,800078be <bd_initfree+0xa0>
    int left = blk_index_next(k, bd_left);
    80007872:	85d6                	mv	a1,s5
    80007874:	854a                	mv	a0,s2
    80007876:	00000097          	auipc	ra,0x0
    8000787a:	dc8080e7          	jalr	-568(ra) # 8000763e <blk_index_next>
    8000787e:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80007880:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80007884:	409b04bb          	subw	s1,s6,s1
    80007888:	012c17b3          	sll	a5,s8,s2
    8000788c:	02f4c4b3          	div	s1,s1,a5
    80007890:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80007892:	85aa                	mv	a1,a0
    80007894:	854a                	mv	a0,s2
    80007896:	00000097          	auipc	ra,0x0
    8000789a:	ed2080e7          	jalr	-302(ra) # 80007768 <bd_initfree_pair>
    8000789e:	01450d3b          	addw	s10,a0,s4
    800078a2:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    800078a6:	fc99d0e3          	ble	s1,s3,80007866 <bd_initfree+0x48>
      continue;
    free += bd_initfree_pair(k, right);
    800078aa:	85a6                	mv	a1,s1
    800078ac:	854a                	mv	a0,s2
    800078ae:	00000097          	auipc	ra,0x0
    800078b2:	eba080e7          	jalr	-326(ra) # 80007768 <bd_initfree_pair>
    800078b6:	00ad0a3b          	addw	s4,s10,a0
    800078ba:	b775                	j	80007866 <bd_initfree+0x48>
  int free = 0;
    800078bc:	4a01                	li	s4,0
  }
  return free;
}
    800078be:	8552                	mv	a0,s4
    800078c0:	60e6                	ld	ra,88(sp)
    800078c2:	6446                	ld	s0,80(sp)
    800078c4:	64a6                	ld	s1,72(sp)
    800078c6:	6906                	ld	s2,64(sp)
    800078c8:	79e2                	ld	s3,56(sp)
    800078ca:	7a42                	ld	s4,48(sp)
    800078cc:	7aa2                	ld	s5,40(sp)
    800078ce:	7b02                	ld	s6,32(sp)
    800078d0:	6be2                	ld	s7,24(sp)
    800078d2:	6c42                	ld	s8,16(sp)
    800078d4:	6ca2                	ld	s9,8(sp)
    800078d6:	6d02                	ld	s10,0(sp)
    800078d8:	6125                	addi	sp,sp,96
    800078da:	8082                	ret

00000000800078dc <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    800078dc:	7179                	addi	sp,sp,-48
    800078de:	f406                	sd	ra,40(sp)
    800078e0:	f022                	sd	s0,32(sp)
    800078e2:	ec26                	sd	s1,24(sp)
    800078e4:	e84a                	sd	s2,16(sp)
    800078e6:	e44e                	sd	s3,8(sp)
    800078e8:	1800                	addi	s0,sp,48
    800078ea:	89aa                	mv	s3,a0
  int meta = p - (char*)bd_base;
    800078ec:	00028917          	auipc	s2,0x28
    800078f0:	7a490913          	addi	s2,s2,1956 # 80030090 <bd_base>
    800078f4:	00093483          	ld	s1,0(s2)
    800078f8:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    800078fc:	00028797          	auipc	a5,0x28
    80007900:	7a478793          	addi	a5,a5,1956 # 800300a0 <nsizes>
    80007904:	439c                	lw	a5,0(a5)
    80007906:	37fd                	addiw	a5,a5,-1
    80007908:	4641                	li	a2,16
    8000790a:	00f61633          	sll	a2,a2,a5
    8000790e:	85a6                	mv	a1,s1
    80007910:	00001517          	auipc	a0,0x1
    80007914:	4f850513          	addi	a0,a0,1272 # 80008e08 <userret+0xd78>
    80007918:	ffff9097          	auipc	ra,0xffff9
    8000791c:	084080e7          	jalr	132(ra) # 8000099c <printf>
  bd_mark(bd_base, p);
    80007920:	85ce                	mv	a1,s3
    80007922:	00093503          	ld	a0,0(s2)
    80007926:	00000097          	auipc	ra,0x0
    8000792a:	d66080e7          	jalr	-666(ra) # 8000768c <bd_mark>
  return meta;
}
    8000792e:	8526                	mv	a0,s1
    80007930:	70a2                	ld	ra,40(sp)
    80007932:	7402                	ld	s0,32(sp)
    80007934:	64e2                	ld	s1,24(sp)
    80007936:	6942                	ld	s2,16(sp)
    80007938:	69a2                	ld	s3,8(sp)
    8000793a:	6145                	addi	sp,sp,48
    8000793c:	8082                	ret

000000008000793e <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    8000793e:	1101                	addi	sp,sp,-32
    80007940:	ec06                	sd	ra,24(sp)
    80007942:	e822                	sd	s0,16(sp)
    80007944:	e426                	sd	s1,8(sp)
    80007946:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80007948:	00028797          	auipc	a5,0x28
    8000794c:	75878793          	addi	a5,a5,1880 # 800300a0 <nsizes>
    80007950:	4384                	lw	s1,0(a5)
    80007952:	fff4879b          	addiw	a5,s1,-1
    80007956:	44c1                	li	s1,16
    80007958:	00f494b3          	sll	s1,s1,a5
    8000795c:	00028797          	auipc	a5,0x28
    80007960:	73478793          	addi	a5,a5,1844 # 80030090 <bd_base>
    80007964:	639c                	ld	a5,0(a5)
    80007966:	8d1d                	sub	a0,a0,a5
    80007968:	40a4853b          	subw	a0,s1,a0
    8000796c:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80007970:	00905a63          	blez	s1,80007984 <bd_mark_unavailable+0x46>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80007974:	357d                	addiw	a0,a0,-1
    80007976:	41f5549b          	sraiw	s1,a0,0x1f
    8000797a:	01c4d49b          	srliw	s1,s1,0x1c
    8000797e:	9ca9                	addw	s1,s1,a0
    80007980:	98c1                	andi	s1,s1,-16
    80007982:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80007984:	85a6                	mv	a1,s1
    80007986:	00001517          	auipc	a0,0x1
    8000798a:	4ba50513          	addi	a0,a0,1210 # 80008e40 <userret+0xdb0>
    8000798e:	ffff9097          	auipc	ra,0xffff9
    80007992:	00e080e7          	jalr	14(ra) # 8000099c <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007996:	00028797          	auipc	a5,0x28
    8000799a:	6fa78793          	addi	a5,a5,1786 # 80030090 <bd_base>
    8000799e:	6398                	ld	a4,0(a5)
    800079a0:	00028797          	auipc	a5,0x28
    800079a4:	70078793          	addi	a5,a5,1792 # 800300a0 <nsizes>
    800079a8:	438c                	lw	a1,0(a5)
    800079aa:	fff5879b          	addiw	a5,a1,-1
    800079ae:	45c1                	li	a1,16
    800079b0:	00f595b3          	sll	a1,a1,a5
    800079b4:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    800079b8:	95ba                	add	a1,a1,a4
    800079ba:	953a                	add	a0,a0,a4
    800079bc:	00000097          	auipc	ra,0x0
    800079c0:	cd0080e7          	jalr	-816(ra) # 8000768c <bd_mark>
  return unavailable;
}
    800079c4:	8526                	mv	a0,s1
    800079c6:	60e2                	ld	ra,24(sp)
    800079c8:	6442                	ld	s0,16(sp)
    800079ca:	64a2                	ld	s1,8(sp)
    800079cc:	6105                	addi	sp,sp,32
    800079ce:	8082                	ret

00000000800079d0 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    800079d0:	715d                	addi	sp,sp,-80
    800079d2:	e486                	sd	ra,72(sp)
    800079d4:	e0a2                	sd	s0,64(sp)
    800079d6:	fc26                	sd	s1,56(sp)
    800079d8:	f84a                	sd	s2,48(sp)
    800079da:	f44e                	sd	s3,40(sp)
    800079dc:	f052                	sd	s4,32(sp)
    800079de:	ec56                	sd	s5,24(sp)
    800079e0:	e85a                	sd	s6,16(sp)
    800079e2:	e45e                	sd	s7,8(sp)
    800079e4:	e062                	sd	s8,0(sp)
    800079e6:	0880                	addi	s0,sp,80
    800079e8:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    800079ea:	fff50493          	addi	s1,a0,-1
    800079ee:	98c1                	andi	s1,s1,-16
    800079f0:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    800079f2:	00001597          	auipc	a1,0x1
    800079f6:	46e58593          	addi	a1,a1,1134 # 80008e60 <userret+0xdd0>
    800079fa:	00028517          	auipc	a0,0x28
    800079fe:	60650513          	addi	a0,a0,1542 # 80030000 <lock>
    80007a02:	ffff9097          	auipc	ra,0xffff9
    80007a06:	14a080e7          	jalr	330(ra) # 80000b4c <initlock>
  bd_base = (void *) p;
    80007a0a:	00028797          	auipc	a5,0x28
    80007a0e:	6897b323          	sd	s1,1670(a5) # 80030090 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007a12:	409c0933          	sub	s2,s8,s1
    80007a16:	43f95513          	srai	a0,s2,0x3f
    80007a1a:	893d                	andi	a0,a0,15
    80007a1c:	954a                	add	a0,a0,s2
    80007a1e:	8511                	srai	a0,a0,0x4
    80007a20:	00000097          	auipc	ra,0x0
    80007a24:	c4a080e7          	jalr	-950(ra) # 8000766a <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80007a28:	47c1                	li	a5,16
    80007a2a:	00a797b3          	sll	a5,a5,a0
    80007a2e:	1b27c863          	blt	a5,s2,80007bde <bd_init+0x20e>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007a32:	2505                	addiw	a0,a0,1
    80007a34:	00028797          	auipc	a5,0x28
    80007a38:	66a7a623          	sw	a0,1644(a5) # 800300a0 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80007a3c:	00028997          	auipc	s3,0x28
    80007a40:	66498993          	addi	s3,s3,1636 # 800300a0 <nsizes>
    80007a44:	0009a603          	lw	a2,0(s3)
    80007a48:	85ca                	mv	a1,s2
    80007a4a:	00001517          	auipc	a0,0x1
    80007a4e:	41e50513          	addi	a0,a0,1054 # 80008e68 <userret+0xdd8>
    80007a52:	ffff9097          	auipc	ra,0xffff9
    80007a56:	f4a080e7          	jalr	-182(ra) # 8000099c <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80007a5a:	00028797          	auipc	a5,0x28
    80007a5e:	6297bf23          	sd	s1,1598(a5) # 80030098 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80007a62:	0009a603          	lw	a2,0(s3)
    80007a66:	00561913          	slli	s2,a2,0x5
    80007a6a:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80007a6c:	0056161b          	slliw	a2,a2,0x5
    80007a70:	4581                	li	a1,0
    80007a72:	8526                	mv	a0,s1
    80007a74:	ffff9097          	auipc	ra,0xffff9
    80007a78:	6ba080e7          	jalr	1722(ra) # 8000112e <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80007a7c:	0009a783          	lw	a5,0(s3)
    80007a80:	06f05a63          	blez	a5,80007af4 <bd_init+0x124>
    80007a84:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80007a86:	00028a97          	auipc	s5,0x28
    80007a8a:	612a8a93          	addi	s5,s5,1554 # 80030098 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007a8e:	00028a17          	auipc	s4,0x28
    80007a92:	612a0a13          	addi	s4,s4,1554 # 800300a0 <nsizes>
    80007a96:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80007a98:	00599b93          	slli	s7,s3,0x5
    80007a9c:	000ab503          	ld	a0,0(s5)
    80007aa0:	955e                	add	a0,a0,s7
    80007aa2:	00000097          	auipc	ra,0x0
    80007aa6:	16a080e7          	jalr	362(ra) # 80007c0c <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007aaa:	000a2483          	lw	s1,0(s4)
    80007aae:	34fd                	addiw	s1,s1,-1
    80007ab0:	413484bb          	subw	s1,s1,s3
    80007ab4:	009b14bb          	sllw	s1,s6,s1
    80007ab8:	fff4879b          	addiw	a5,s1,-1
    80007abc:	41f7d49b          	sraiw	s1,a5,0x1f
    80007ac0:	01d4d49b          	srliw	s1,s1,0x1d
    80007ac4:	9cbd                	addw	s1,s1,a5
    80007ac6:	98e1                	andi	s1,s1,-8
    80007ac8:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80007aca:	000ab783          	ld	a5,0(s5)
    80007ace:	9bbe                	add	s7,s7,a5
    80007ad0:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80007ad4:	848d                	srai	s1,s1,0x3
    80007ad6:	8626                	mv	a2,s1
    80007ad8:	4581                	li	a1,0
    80007ada:	854a                	mv	a0,s2
    80007adc:	ffff9097          	auipc	ra,0xffff9
    80007ae0:	652080e7          	jalr	1618(ra) # 8000112e <memset>
    p += sz;
    80007ae4:	9926                	add	s2,s2,s1
    80007ae6:	0985                	addi	s3,s3,1
  for (int k = 0; k < nsizes; k++) {
    80007ae8:	000a2703          	lw	a4,0(s4)
    80007aec:	0009879b          	sext.w	a5,s3
    80007af0:	fae7c4e3          	blt	a5,a4,80007a98 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80007af4:	00028797          	auipc	a5,0x28
    80007af8:	5ac78793          	addi	a5,a5,1452 # 800300a0 <nsizes>
    80007afc:	439c                	lw	a5,0(a5)
    80007afe:	4705                	li	a4,1
    80007b00:	06f75163          	ble	a5,a4,80007b62 <bd_init+0x192>
    80007b04:	02000a13          	li	s4,32
    80007b08:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80007b0a:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80007b0c:	00028b17          	auipc	s6,0x28
    80007b10:	58cb0b13          	addi	s6,s6,1420 # 80030098 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80007b14:	00028a97          	auipc	s5,0x28
    80007b18:	58ca8a93          	addi	s5,s5,1420 # 800300a0 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80007b1c:	37fd                	addiw	a5,a5,-1
    80007b1e:	413787bb          	subw	a5,a5,s3
    80007b22:	00fb94bb          	sllw	s1,s7,a5
    80007b26:	fff4879b          	addiw	a5,s1,-1
    80007b2a:	41f7d49b          	sraiw	s1,a5,0x1f
    80007b2e:	01d4d49b          	srliw	s1,s1,0x1d
    80007b32:	9cbd                	addw	s1,s1,a5
    80007b34:	98e1                	andi	s1,s1,-8
    80007b36:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007b38:	000b3783          	ld	a5,0(s6)
    80007b3c:	97d2                	add	a5,a5,s4
    80007b3e:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007b42:	848d                	srai	s1,s1,0x3
    80007b44:	8626                	mv	a2,s1
    80007b46:	4581                	li	a1,0
    80007b48:	854a                	mv	a0,s2
    80007b4a:	ffff9097          	auipc	ra,0xffff9
    80007b4e:	5e4080e7          	jalr	1508(ra) # 8000112e <memset>
    p += sz;
    80007b52:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80007b54:	2985                	addiw	s3,s3,1
    80007b56:	000aa783          	lw	a5,0(s5)
    80007b5a:	020a0a13          	addi	s4,s4,32
    80007b5e:	faf9cfe3          	blt	s3,a5,80007b1c <bd_init+0x14c>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80007b62:	197d                	addi	s2,s2,-1
    80007b64:	ff097913          	andi	s2,s2,-16
    80007b68:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80007b6a:	854a                	mv	a0,s2
    80007b6c:	00000097          	auipc	ra,0x0
    80007b70:	d70080e7          	jalr	-656(ra) # 800078dc <bd_mark_data_structures>
    80007b74:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80007b76:	85ca                	mv	a1,s2
    80007b78:	8562                	mv	a0,s8
    80007b7a:	00000097          	auipc	ra,0x0
    80007b7e:	dc4080e7          	jalr	-572(ra) # 8000793e <bd_mark_unavailable>
    80007b82:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007b84:	00028a97          	auipc	s5,0x28
    80007b88:	51ca8a93          	addi	s5,s5,1308 # 800300a0 <nsizes>
    80007b8c:	000aa783          	lw	a5,0(s5)
    80007b90:	37fd                	addiw	a5,a5,-1
    80007b92:	44c1                	li	s1,16
    80007b94:	00f497b3          	sll	a5,s1,a5
    80007b98:	8f89                	sub	a5,a5,a0
    80007b9a:	00028717          	auipc	a4,0x28
    80007b9e:	4f670713          	addi	a4,a4,1270 # 80030090 <bd_base>
    80007ba2:	630c                	ld	a1,0(a4)
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80007ba4:	95be                	add	a1,a1,a5
    80007ba6:	854a                	mv	a0,s2
    80007ba8:	00000097          	auipc	ra,0x0
    80007bac:	c76080e7          	jalr	-906(ra) # 8000781e <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80007bb0:	000aa603          	lw	a2,0(s5)
    80007bb4:	367d                	addiw	a2,a2,-1
    80007bb6:	00c49633          	sll	a2,s1,a2
    80007bba:	41460633          	sub	a2,a2,s4
    80007bbe:	41360633          	sub	a2,a2,s3
    80007bc2:	02c51463          	bne	a0,a2,80007bea <bd_init+0x21a>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80007bc6:	60a6                	ld	ra,72(sp)
    80007bc8:	6406                	ld	s0,64(sp)
    80007bca:	74e2                	ld	s1,56(sp)
    80007bcc:	7942                	ld	s2,48(sp)
    80007bce:	79a2                	ld	s3,40(sp)
    80007bd0:	7a02                	ld	s4,32(sp)
    80007bd2:	6ae2                	ld	s5,24(sp)
    80007bd4:	6b42                	ld	s6,16(sp)
    80007bd6:	6ba2                	ld	s7,8(sp)
    80007bd8:	6c02                	ld	s8,0(sp)
    80007bda:	6161                	addi	sp,sp,80
    80007bdc:	8082                	ret
    nsizes++;  // round up to the next power of 2
    80007bde:	2509                	addiw	a0,a0,2
    80007be0:	00028797          	auipc	a5,0x28
    80007be4:	4ca7a023          	sw	a0,1216(a5) # 800300a0 <nsizes>
    80007be8:	bd91                	j	80007a3c <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007bea:	85aa                	mv	a1,a0
    80007bec:	00001517          	auipc	a0,0x1
    80007bf0:	2bc50513          	addi	a0,a0,700 # 80008ea8 <userret+0xe18>
    80007bf4:	ffff9097          	auipc	ra,0xffff9
    80007bf8:	da8080e7          	jalr	-600(ra) # 8000099c <printf>
    panic("bd_init: free mem");
    80007bfc:	00001517          	auipc	a0,0x1
    80007c00:	2bc50513          	addi	a0,a0,700 # 80008eb8 <userret+0xe28>
    80007c04:	ffff9097          	auipc	ra,0xffff9
    80007c08:	b80080e7          	jalr	-1152(ra) # 80000784 <panic>

0000000080007c0c <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80007c0c:	1141                	addi	sp,sp,-16
    80007c0e:	e422                	sd	s0,8(sp)
    80007c10:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007c12:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80007c14:	e508                	sd	a0,8(a0)
}
    80007c16:	6422                	ld	s0,8(sp)
    80007c18:	0141                	addi	sp,sp,16
    80007c1a:	8082                	ret

0000000080007c1c <lst_empty>:

int
lst_empty(struct list *lst) {
    80007c1c:	1141                	addi	sp,sp,-16
    80007c1e:	e422                	sd	s0,8(sp)
    80007c20:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007c22:	611c                	ld	a5,0(a0)
    80007c24:	40a78533          	sub	a0,a5,a0
}
    80007c28:	00153513          	seqz	a0,a0
    80007c2c:	6422                	ld	s0,8(sp)
    80007c2e:	0141                	addi	sp,sp,16
    80007c30:	8082                	ret

0000000080007c32 <lst_remove>:

void
lst_remove(struct list *e) {
    80007c32:	1141                	addi	sp,sp,-16
    80007c34:	e422                	sd	s0,8(sp)
    80007c36:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007c38:	6518                	ld	a4,8(a0)
    80007c3a:	611c                	ld	a5,0(a0)
    80007c3c:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80007c3e:	6518                	ld	a4,8(a0)
    80007c40:	e798                	sd	a4,8(a5)
}
    80007c42:	6422                	ld	s0,8(sp)
    80007c44:	0141                	addi	sp,sp,16
    80007c46:	8082                	ret

0000000080007c48 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007c48:	1101                	addi	sp,sp,-32
    80007c4a:	ec06                	sd	ra,24(sp)
    80007c4c:	e822                	sd	s0,16(sp)
    80007c4e:	e426                	sd	s1,8(sp)
    80007c50:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007c52:	6104                	ld	s1,0(a0)
    80007c54:	00a48d63          	beq	s1,a0,80007c6e <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007c58:	8526                	mv	a0,s1
    80007c5a:	00000097          	auipc	ra,0x0
    80007c5e:	fd8080e7          	jalr	-40(ra) # 80007c32 <lst_remove>
  return (void *)p;
}
    80007c62:	8526                	mv	a0,s1
    80007c64:	60e2                	ld	ra,24(sp)
    80007c66:	6442                	ld	s0,16(sp)
    80007c68:	64a2                	ld	s1,8(sp)
    80007c6a:	6105                	addi	sp,sp,32
    80007c6c:	8082                	ret
    panic("lst_pop");
    80007c6e:	00001517          	auipc	a0,0x1
    80007c72:	26250513          	addi	a0,a0,610 # 80008ed0 <userret+0xe40>
    80007c76:	ffff9097          	auipc	ra,0xffff9
    80007c7a:	b0e080e7          	jalr	-1266(ra) # 80000784 <panic>

0000000080007c7e <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80007c7e:	1141                	addi	sp,sp,-16
    80007c80:	e422                	sd	s0,8(sp)
    80007c82:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80007c84:	611c                	ld	a5,0(a0)
    80007c86:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80007c88:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007c8a:	611c                	ld	a5,0(a0)
    80007c8c:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80007c8e:	e10c                	sd	a1,0(a0)
}
    80007c90:	6422                	ld	s0,8(sp)
    80007c92:	0141                	addi	sp,sp,16
    80007c94:	8082                	ret

0000000080007c96 <lst_print>:

void
lst_print(struct list *lst)
{
    80007c96:	7179                	addi	sp,sp,-48
    80007c98:	f406                	sd	ra,40(sp)
    80007c9a:	f022                	sd	s0,32(sp)
    80007c9c:	ec26                	sd	s1,24(sp)
    80007c9e:	e84a                	sd	s2,16(sp)
    80007ca0:	e44e                	sd	s3,8(sp)
    80007ca2:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007ca4:	6104                	ld	s1,0(a0)
    80007ca6:	02950063          	beq	a0,s1,80007cc6 <lst_print+0x30>
    80007caa:	892a                	mv	s2,a0
    printf(" %p", p);
    80007cac:	00001997          	auipc	s3,0x1
    80007cb0:	22c98993          	addi	s3,s3,556 # 80008ed8 <userret+0xe48>
    80007cb4:	85a6                	mv	a1,s1
    80007cb6:	854e                	mv	a0,s3
    80007cb8:	ffff9097          	auipc	ra,0xffff9
    80007cbc:	ce4080e7          	jalr	-796(ra) # 8000099c <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007cc0:	6084                	ld	s1,0(s1)
    80007cc2:	fe9919e3          	bne	s2,s1,80007cb4 <lst_print+0x1e>
  }
  printf("\n");
    80007cc6:	00001517          	auipc	a0,0x1
    80007cca:	98250513          	addi	a0,a0,-1662 # 80008648 <userret+0x5b8>
    80007cce:	ffff9097          	auipc	ra,0xffff9
    80007cd2:	cce080e7          	jalr	-818(ra) # 8000099c <printf>
}
    80007cd6:	70a2                	ld	ra,40(sp)
    80007cd8:	7402                	ld	s0,32(sp)
    80007cda:	64e2                	ld	s1,24(sp)
    80007cdc:	6942                	ld	s2,16(sp)
    80007cde:	69a2                	ld	s3,8(sp)
    80007ce0:	6145                	addi	sp,sp,48
    80007ce2:	8082                	ret

0000000080007ce4 <watchdogwrite>:
int watchdog_time;
struct spinlock watchdog_lock;

int
watchdogwrite(struct file *f, int user_src, uint64 src, int n)
{
    80007ce4:	715d                	addi	sp,sp,-80
    80007ce6:	e486                	sd	ra,72(sp)
    80007ce8:	e0a2                	sd	s0,64(sp)
    80007cea:	fc26                	sd	s1,56(sp)
    80007cec:	f84a                	sd	s2,48(sp)
    80007cee:	f44e                	sd	s3,40(sp)
    80007cf0:	f052                	sd	s4,32(sp)
    80007cf2:	ec56                	sd	s5,24(sp)
    80007cf4:	0880                	addi	s0,sp,80
    80007cf6:	8a2e                	mv	s4,a1
    80007cf8:	84b2                	mv	s1,a2
    80007cfa:	89b6                	mv	s3,a3
  acquire(&watchdog_lock);
    80007cfc:	00028517          	auipc	a0,0x28
    80007d00:	33450513          	addi	a0,a0,820 # 80030030 <watchdog_lock>
    80007d04:	ffff9097          	auipc	ra,0xffff9
    80007d08:	fb6080e7          	jalr	-74(ra) # 80000cba <acquire>

  int time = 0;
  for(int i = 0; i < n; i++){
    80007d0c:	09305e63          	blez	s3,80007da8 <watchdogwrite+0xc4>
    80007d10:	00148913          	addi	s2,s1,1
    80007d14:	39fd                	addiw	s3,s3,-1
    80007d16:	1982                	slli	s3,s3,0x20
    80007d18:	0209d993          	srli	s3,s3,0x20
    80007d1c:	994e                	add	s2,s2,s3
  int time = 0;
    80007d1e:	4981                	li	s3,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80007d20:	5afd                	li	s5,-1
    80007d22:	4685                	li	a3,1
    80007d24:	8626                	mv	a2,s1
    80007d26:	85d2                	mv	a1,s4
    80007d28:	fbf40513          	addi	a0,s0,-65
    80007d2c:	ffffb097          	auipc	ra,0xffffb
    80007d30:	ebe080e7          	jalr	-322(ra) # 80002bea <either_copyin>
    80007d34:	01550763          	beq	a0,s5,80007d42 <watchdogwrite+0x5e>
      break;
    time = c;
    80007d38:	fbf44983          	lbu	s3,-65(s0)
    80007d3c:	0485                	addi	s1,s1,1
  for(int i = 0; i < n; i++){
    80007d3e:	ff2492e3          	bne	s1,s2,80007d22 <watchdogwrite+0x3e>
  }

  acquire(&tickslock);
    80007d42:	00014517          	auipc	a0,0x14
    80007d46:	35650513          	addi	a0,a0,854 # 8001c098 <tickslock>
    80007d4a:	ffff9097          	auipc	ra,0xffff9
    80007d4e:	f70080e7          	jalr	-144(ra) # 80000cba <acquire>
  n = ticks - watchdog_value;
    80007d52:	00028797          	auipc	a5,0x28
    80007d56:	33678793          	addi	a5,a5,822 # 80030088 <ticks>
    80007d5a:	4398                	lw	a4,0(a5)
    80007d5c:	00028797          	auipc	a5,0x28
    80007d60:	34c78793          	addi	a5,a5,844 # 800300a8 <watchdog_value>
    80007d64:	4384                	lw	s1,0(a5)
    80007d66:	409704bb          	subw	s1,a4,s1
  watchdog_value = ticks;
    80007d6a:	c398                	sw	a4,0(a5)
  watchdog_time = time;
    80007d6c:	00028797          	auipc	a5,0x28
    80007d70:	3337ac23          	sw	s3,824(a5) # 800300a4 <watchdog_time>
  release(&tickslock);
    80007d74:	00014517          	auipc	a0,0x14
    80007d78:	32450513          	addi	a0,a0,804 # 8001c098 <tickslock>
    80007d7c:	ffff9097          	auipc	ra,0xffff9
    80007d80:	18a080e7          	jalr	394(ra) # 80000f06 <release>

  release(&watchdog_lock);
    80007d84:	00028517          	auipc	a0,0x28
    80007d88:	2ac50513          	addi	a0,a0,684 # 80030030 <watchdog_lock>
    80007d8c:	ffff9097          	auipc	ra,0xffff9
    80007d90:	17a080e7          	jalr	378(ra) # 80000f06 <release>
  return n;
}
    80007d94:	8526                	mv	a0,s1
    80007d96:	60a6                	ld	ra,72(sp)
    80007d98:	6406                	ld	s0,64(sp)
    80007d9a:	74e2                	ld	s1,56(sp)
    80007d9c:	7942                	ld	s2,48(sp)
    80007d9e:	79a2                	ld	s3,40(sp)
    80007da0:	7a02                	ld	s4,32(sp)
    80007da2:	6ae2                	ld	s5,24(sp)
    80007da4:	6161                	addi	sp,sp,80
    80007da6:	8082                	ret
  int time = 0;
    80007da8:	4981                	li	s3,0
    80007daa:	bf61                	j	80007d42 <watchdogwrite+0x5e>

0000000080007dac <watchdoginit>:

void watchdoginit(){
    80007dac:	1141                	addi	sp,sp,-16
    80007dae:	e406                	sd	ra,8(sp)
    80007db0:	e022                	sd	s0,0(sp)
    80007db2:	0800                	addi	s0,sp,16
  initlock(&watchdog_lock, "watchdog_lock");
    80007db4:	00001597          	auipc	a1,0x1
    80007db8:	12c58593          	addi	a1,a1,300 # 80008ee0 <userret+0xe50>
    80007dbc:	00028517          	auipc	a0,0x28
    80007dc0:	27450513          	addi	a0,a0,628 # 80030030 <watchdog_lock>
    80007dc4:	ffff9097          	auipc	ra,0xffff9
    80007dc8:	d88080e7          	jalr	-632(ra) # 80000b4c <initlock>
  watchdog_time = 0;
    80007dcc:	00028797          	auipc	a5,0x28
    80007dd0:	2c07ac23          	sw	zero,728(a5) # 800300a4 <watchdog_time>


  devsw[WATCHDOG].read = 0;
    80007dd4:	0001f797          	auipc	a5,0x1f
    80007dd8:	dc478793          	addi	a5,a5,-572 # 80026b98 <devsw>
    80007ddc:	0207b023          	sd	zero,32(a5)
  devsw[WATCHDOG].write = watchdogwrite;
    80007de0:	00000717          	auipc	a4,0x0
    80007de4:	f0470713          	addi	a4,a4,-252 # 80007ce4 <watchdogwrite>
    80007de8:	f798                	sd	a4,40(a5)
}
    80007dea:	60a2                	ld	ra,8(sp)
    80007dec:	6402                	ld	s0,0(sp)
    80007dee:	0141                	addi	sp,sp,16
    80007df0:	8082                	ret
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
