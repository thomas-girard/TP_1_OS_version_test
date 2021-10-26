
user/_nice:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  if(argc != 3){
   c:	478d                	li	a5,3
   e:	02f50063          	beq	a0,a5,2e <main+0x2e>
    fprintf(2, "usage: nice pid priority\n");
  12:	00001597          	auipc	a1,0x1
  16:	94658593          	addi	a1,a1,-1722 # 958 <malloc+0xe6>
  1a:	4509                	li	a0,2
  1c:	00000097          	auipc	ra,0x0
  20:	76a080e7          	jalr	1898(ra) # 786 <fprintf>
    exit(1);
  24:	4505                	li	a0,1
  26:	00000097          	auipc	ra,0x0
  2a:	2fa080e7          	jalr	762(ra) # 320 <exit>
  2e:	84ae                	mv	s1,a1
  }
  nice(atoi(argv[1]), atoi(argv[2]));
  30:	6588                	ld	a0,8(a1)
  32:	00000097          	auipc	ra,0x0
  36:	15a080e7          	jalr	346(ra) # 18c <atoi>
  3a:	892a                	mv	s2,a0
  3c:	6888                	ld	a0,16(s1)
  3e:	00000097          	auipc	ra,0x0
  42:	14e080e7          	jalr	334(ra) # 18c <atoi>
  46:	85aa                	mv	a1,a0
  48:	854a                	mv	a0,s2
  4a:	00000097          	auipc	ra,0x0
  4e:	37e080e7          	jalr	894(ra) # 3c8 <nice>
  exit(0);
  52:	4501                	li	a0,0
  54:	00000097          	auipc	ra,0x0
  58:	2cc080e7          	jalr	716(ra) # 320 <exit>

000000000000005c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  5c:	1141                	addi	sp,sp,-16
  5e:	e422                	sd	s0,8(sp)
  60:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  62:	87aa                	mv	a5,a0
  64:	0585                	addi	a1,a1,1
  66:	0785                	addi	a5,a5,1
  68:	fff5c703          	lbu	a4,-1(a1)
  6c:	fee78fa3          	sb	a4,-1(a5)
  70:	fb75                	bnez	a4,64 <strcpy+0x8>
    ;
  return os;
}
  72:	6422                	ld	s0,8(sp)
  74:	0141                	addi	sp,sp,16
  76:	8082                	ret

0000000000000078 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e422                	sd	s0,8(sp)
  7c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  7e:	00054783          	lbu	a5,0(a0)
  82:	cb91                	beqz	a5,96 <strcmp+0x1e>
  84:	0005c703          	lbu	a4,0(a1)
  88:	00f71763          	bne	a4,a5,96 <strcmp+0x1e>
    p++, q++;
  8c:	0505                	addi	a0,a0,1
  8e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  90:	00054783          	lbu	a5,0(a0)
  94:	fbe5                	bnez	a5,84 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  96:	0005c503          	lbu	a0,0(a1)
}
  9a:	40a7853b          	subw	a0,a5,a0
  9e:	6422                	ld	s0,8(sp)
  a0:	0141                	addi	sp,sp,16
  a2:	8082                	ret

00000000000000a4 <strlen>:

uint
strlen(const char *s)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  aa:	00054783          	lbu	a5,0(a0)
  ae:	cf91                	beqz	a5,ca <strlen+0x26>
  b0:	0505                	addi	a0,a0,1
  b2:	87aa                	mv	a5,a0
  b4:	4685                	li	a3,1
  b6:	9e89                	subw	a3,a3,a0
  b8:	00f6853b          	addw	a0,a3,a5
  bc:	0785                	addi	a5,a5,1
  be:	fff7c703          	lbu	a4,-1(a5)
  c2:	fb7d                	bnez	a4,b8 <strlen+0x14>
    ;
  return n;
}
  c4:	6422                	ld	s0,8(sp)
  c6:	0141                	addi	sp,sp,16
  c8:	8082                	ret
  for(n = 0; s[n]; n++)
  ca:	4501                	li	a0,0
  cc:	bfe5                	j	c4 <strlen+0x20>

00000000000000ce <memset>:

void*
memset(void *dst, int c, uint n)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e422                	sd	s0,8(sp)
  d2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d4:	ce09                	beqz	a2,ee <memset+0x20>
  d6:	87aa                	mv	a5,a0
  d8:	fff6071b          	addiw	a4,a2,-1
  dc:	1702                	slli	a4,a4,0x20
  de:	9301                	srli	a4,a4,0x20
  e0:	0705                	addi	a4,a4,1
  e2:	972a                	add	a4,a4,a0
    cdst[i] = c;
  e4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e8:	0785                	addi	a5,a5,1
  ea:	fee79de3          	bne	a5,a4,e4 <memset+0x16>
  }
  return dst;
}
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strchr>:

char*
strchr(const char *s, char c)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cb99                	beqz	a5,114 <strchr+0x20>
    if(*s == c)
 100:	00f58763          	beq	a1,a5,10e <strchr+0x1a>
  for(; *s; s++)
 104:	0505                	addi	a0,a0,1
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbfd                	bnez	a5,100 <strchr+0xc>
      return (char*)s;
  return 0;
 10c:	4501                	li	a0,0
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret
  return 0;
 114:	4501                	li	a0,0
 116:	bfe5                	j	10e <strchr+0x1a>

0000000000000118 <gets>:

char*
gets(char *buf, int max)
{
 118:	711d                	addi	sp,sp,-96
 11a:	ec86                	sd	ra,88(sp)
 11c:	e8a2                	sd	s0,80(sp)
 11e:	e4a6                	sd	s1,72(sp)
 120:	e0ca                	sd	s2,64(sp)
 122:	fc4e                	sd	s3,56(sp)
 124:	f852                	sd	s4,48(sp)
 126:	f456                	sd	s5,40(sp)
 128:	f05a                	sd	s6,32(sp)
 12a:	ec5e                	sd	s7,24(sp)
 12c:	1080                	addi	s0,sp,96
 12e:	8baa                	mv	s7,a0
 130:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 132:	892a                	mv	s2,a0
 134:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 136:	4aa9                	li	s5,10
 138:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13a:	89a6                	mv	s3,s1
 13c:	2485                	addiw	s1,s1,1
 13e:	0344d863          	bge	s1,s4,16e <gets+0x56>
    cc = read(0, &c, 1);
 142:	4605                	li	a2,1
 144:	faf40593          	addi	a1,s0,-81
 148:	4501                	li	a0,0
 14a:	00000097          	auipc	ra,0x0
 14e:	1ee080e7          	jalr	494(ra) # 338 <read>
    if(cc < 1)
 152:	00a05e63          	blez	a0,16e <gets+0x56>
    buf[i++] = c;
 156:	faf44783          	lbu	a5,-81(s0)
 15a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15e:	01578763          	beq	a5,s5,16c <gets+0x54>
 162:	0905                	addi	s2,s2,1
 164:	fd679be3          	bne	a5,s6,13a <gets+0x22>
  for(i=0; i+1 < max; ){
 168:	89a6                	mv	s3,s1
 16a:	a011                	j	16e <gets+0x56>
 16c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16e:	99de                	add	s3,s3,s7
 170:	00098023          	sb	zero,0(s3)
  return buf;
}
 174:	855e                	mv	a0,s7
 176:	60e6                	ld	ra,88(sp)
 178:	6446                	ld	s0,80(sp)
 17a:	64a6                	ld	s1,72(sp)
 17c:	6906                	ld	s2,64(sp)
 17e:	79e2                	ld	s3,56(sp)
 180:	7a42                	ld	s4,48(sp)
 182:	7aa2                	ld	s5,40(sp)
 184:	7b02                	ld	s6,32(sp)
 186:	6be2                	ld	s7,24(sp)
 188:	6125                	addi	sp,sp,96
 18a:	8082                	ret

000000000000018c <atoi>:
  return r;
}

int
atoi(const char *s)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e422                	sd	s0,8(sp)
 190:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 192:	00054603          	lbu	a2,0(a0)
 196:	fd06079b          	addiw	a5,a2,-48
 19a:	0ff7f793          	andi	a5,a5,255
 19e:	4725                	li	a4,9
 1a0:	02f76963          	bltu	a4,a5,1d2 <atoi+0x46>
 1a4:	86aa                	mv	a3,a0
  n = 0;
 1a6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1a8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1aa:	0685                	addi	a3,a3,1
 1ac:	0025179b          	slliw	a5,a0,0x2
 1b0:	9fa9                	addw	a5,a5,a0
 1b2:	0017979b          	slliw	a5,a5,0x1
 1b6:	9fb1                	addw	a5,a5,a2
 1b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1bc:	0006c603          	lbu	a2,0(a3)
 1c0:	fd06071b          	addiw	a4,a2,-48
 1c4:	0ff77713          	andi	a4,a4,255
 1c8:	fee5f1e3          	bgeu	a1,a4,1aa <atoi+0x1e>
  return n;
}
 1cc:	6422                	ld	s0,8(sp)
 1ce:	0141                	addi	sp,sp,16
 1d0:	8082                	ret
  n = 0;
 1d2:	4501                	li	a0,0
 1d4:	bfe5                	j	1cc <atoi+0x40>

00000000000001d6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1dc:	02b57663          	bgeu	a0,a1,208 <memmove+0x32>
    while(n-- > 0)
 1e0:	02c05163          	blez	a2,202 <memmove+0x2c>
 1e4:	fff6079b          	addiw	a5,a2,-1
 1e8:	1782                	slli	a5,a5,0x20
 1ea:	9381                	srli	a5,a5,0x20
 1ec:	0785                	addi	a5,a5,1
 1ee:	97aa                	add	a5,a5,a0
  dst = vdst;
 1f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f2:	0585                	addi	a1,a1,1
 1f4:	0705                	addi	a4,a4,1
 1f6:	fff5c683          	lbu	a3,-1(a1)
 1fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1fe:	fee79ae3          	bne	a5,a4,1f2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
    dst += n;
 208:	00c50733          	add	a4,a0,a2
    src += n;
 20c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 20e:	fec05ae3          	blez	a2,202 <memmove+0x2c>
 212:	fff6079b          	addiw	a5,a2,-1
 216:	1782                	slli	a5,a5,0x20
 218:	9381                	srli	a5,a5,0x20
 21a:	fff7c793          	not	a5,a5
 21e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 220:	15fd                	addi	a1,a1,-1
 222:	177d                	addi	a4,a4,-1
 224:	0005c683          	lbu	a3,0(a1)
 228:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 22c:	fee79ae3          	bne	a5,a4,220 <memmove+0x4a>
 230:	bfc9                	j	202 <memmove+0x2c>

0000000000000232 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 238:	ca05                	beqz	a2,268 <memcmp+0x36>
 23a:	fff6069b          	addiw	a3,a2,-1
 23e:	1682                	slli	a3,a3,0x20
 240:	9281                	srli	a3,a3,0x20
 242:	0685                	addi	a3,a3,1
 244:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 246:	00054783          	lbu	a5,0(a0)
 24a:	0005c703          	lbu	a4,0(a1)
 24e:	00e79863          	bne	a5,a4,25e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 252:	0505                	addi	a0,a0,1
    p2++;
 254:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 256:	fed518e3          	bne	a0,a3,246 <memcmp+0x14>
  }
  return 0;
 25a:	4501                	li	a0,0
 25c:	a019                	j	262 <memcmp+0x30>
      return *p1 - *p2;
 25e:	40e7853b          	subw	a0,a5,a4
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  return 0;
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <memcmp+0x30>

000000000000026c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 274:	00000097          	auipc	ra,0x0
 278:	f62080e7          	jalr	-158(ra) # 1d6 <memmove>
}
 27c:	60a2                	ld	ra,8(sp)
 27e:	6402                	ld	s0,0(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret

0000000000000284 <close>:

int close(int fd){
 284:	1101                	addi	sp,sp,-32
 286:	ec06                	sd	ra,24(sp)
 288:	e822                	sd	s0,16(sp)
 28a:	e426                	sd	s1,8(sp)
 28c:	1000                	addi	s0,sp,32
 28e:	84aa                	mv	s1,a0
  fflush(fd);
 290:	00000097          	auipc	ra,0x0
 294:	2d4080e7          	jalr	724(ra) # 564 <fflush>
  char* buf = get_putc_buf(fd);
 298:	8526                	mv	a0,s1
 29a:	00000097          	auipc	ra,0x0
 29e:	14e080e7          	jalr	334(ra) # 3e8 <get_putc_buf>
  if(buf){
 2a2:	cd11                	beqz	a0,2be <close+0x3a>
    free(buf);
 2a4:	00000097          	auipc	ra,0x0
 2a8:	546080e7          	jalr	1350(ra) # 7ea <free>
    putc_buf[fd] = 0;
 2ac:	00349713          	slli	a4,s1,0x3
 2b0:	00000797          	auipc	a5,0x0
 2b4:	6f078793          	addi	a5,a5,1776 # 9a0 <putc_buf>
 2b8:	97ba                	add	a5,a5,a4
 2ba:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 2be:	8526                	mv	a0,s1
 2c0:	00000097          	auipc	ra,0x0
 2c4:	088080e7          	jalr	136(ra) # 348 <sclose>
}
 2c8:	60e2                	ld	ra,24(sp)
 2ca:	6442                	ld	s0,16(sp)
 2cc:	64a2                	ld	s1,8(sp)
 2ce:	6105                	addi	sp,sp,32
 2d0:	8082                	ret

00000000000002d2 <stat>:
{
 2d2:	1101                	addi	sp,sp,-32
 2d4:	ec06                	sd	ra,24(sp)
 2d6:	e822                	sd	s0,16(sp)
 2d8:	e426                	sd	s1,8(sp)
 2da:	e04a                	sd	s2,0(sp)
 2dc:	1000                	addi	s0,sp,32
 2de:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 2e0:	4581                	li	a1,0
 2e2:	00000097          	auipc	ra,0x0
 2e6:	07e080e7          	jalr	126(ra) # 360 <open>
  if(fd < 0)
 2ea:	02054563          	bltz	a0,314 <stat+0x42>
 2ee:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 2f0:	85ca                	mv	a1,s2
 2f2:	00000097          	auipc	ra,0x0
 2f6:	086080e7          	jalr	134(ra) # 378 <fstat>
 2fa:	892a                	mv	s2,a0
  close(fd);
 2fc:	8526                	mv	a0,s1
 2fe:	00000097          	auipc	ra,0x0
 302:	f86080e7          	jalr	-122(ra) # 284 <close>
}
 306:	854a                	mv	a0,s2
 308:	60e2                	ld	ra,24(sp)
 30a:	6442                	ld	s0,16(sp)
 30c:	64a2                	ld	s1,8(sp)
 30e:	6902                	ld	s2,0(sp)
 310:	6105                	addi	sp,sp,32
 312:	8082                	ret
    return -1;
 314:	597d                	li	s2,-1
 316:	bfc5                	j	306 <stat+0x34>

0000000000000318 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 318:	4885                	li	a7,1
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <exit>:
.global exit
exit:
 li a7, SYS_exit
 320:	4889                	li	a7,2
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <wait>:
.global wait
wait:
 li a7, SYS_wait
 328:	488d                	li	a7,3
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 330:	4891                	li	a7,4
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <read>:
.global read
read:
 li a7, SYS_read
 338:	4895                	li	a7,5
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <write>:
.global write
write:
 li a7, SYS_write
 340:	48c1                	li	a7,16
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 348:	48d5                	li	a7,21
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <kill>:
.global kill
kill:
 li a7, SYS_kill
 350:	4899                	li	a7,6
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exec>:
.global exec
exec:
 li a7, SYS_exec
 358:	489d                	li	a7,7
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <open>:
.global open
open:
 li a7, SYS_open
 360:	48bd                	li	a7,15
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 368:	48c5                	li	a7,17
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 370:	48c9                	li	a7,18
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 378:	48a1                	li	a7,8
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <link>:
.global link
link:
 li a7, SYS_link
 380:	48cd                	li	a7,19
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 388:	48d1                	li	a7,20
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 390:	48a5                	li	a7,9
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <dup>:
.global dup
dup:
 li a7, SYS_dup
 398:	48a9                	li	a7,10
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a0:	48ad                	li	a7,11
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3a8:	48b1                	li	a7,12
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b0:	48b5                	li	a7,13
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b8:	48b9                	li	a7,14
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 3c0:	48d9                	li	a7,22
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <nice>:
.global nice
nice:
 li a7, SYS_nice
 3c8:	48dd                	li	a7,23
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 3d0:	48e1                	li	a7,24
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 3d8:	48e5                	li	a7,25
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 3e0:	48e9                	li	a7,26
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 3e8:	1101                	addi	sp,sp,-32
 3ea:	ec06                	sd	ra,24(sp)
 3ec:	e822                	sd	s0,16(sp)
 3ee:	e426                	sd	s1,8(sp)
 3f0:	1000                	addi	s0,sp,32
 3f2:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 3f4:	00351713          	slli	a4,a0,0x3
 3f8:	00000797          	auipc	a5,0x0
 3fc:	5a878793          	addi	a5,a5,1448 # 9a0 <putc_buf>
 400:	97ba                	add	a5,a5,a4
 402:	6388                	ld	a0,0(a5)
  if(buf) {
 404:	c511                	beqz	a0,410 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 406:	60e2                	ld	ra,24(sp)
 408:	6442                	ld	s0,16(sp)
 40a:	64a2                	ld	s1,8(sp)
 40c:	6105                	addi	sp,sp,32
 40e:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 410:	6505                	lui	a0,0x1
 412:	00000097          	auipc	ra,0x0
 416:	460080e7          	jalr	1120(ra) # 872 <malloc>
  putc_buf[fd] = buf;
 41a:	00000797          	auipc	a5,0x0
 41e:	58678793          	addi	a5,a5,1414 # 9a0 <putc_buf>
 422:	00349713          	slli	a4,s1,0x3
 426:	973e                	add	a4,a4,a5
 428:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 42a:	048a                	slli	s1,s1,0x2
 42c:	94be                	add	s1,s1,a5
 42e:	3204a023          	sw	zero,800(s1)
  return buf;
 432:	bfd1                	j	406 <get_putc_buf+0x1e>

0000000000000434 <putc>:

static void
putc(int fd, char c)
{
 434:	1101                	addi	sp,sp,-32
 436:	ec06                	sd	ra,24(sp)
 438:	e822                	sd	s0,16(sp)
 43a:	e426                	sd	s1,8(sp)
 43c:	e04a                	sd	s2,0(sp)
 43e:	1000                	addi	s0,sp,32
 440:	84aa                	mv	s1,a0
 442:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 444:	00000097          	auipc	ra,0x0
 448:	fa4080e7          	jalr	-92(ra) # 3e8 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 44c:	00249793          	slli	a5,s1,0x2
 450:	00000717          	auipc	a4,0x0
 454:	55070713          	addi	a4,a4,1360 # 9a0 <putc_buf>
 458:	973e                	add	a4,a4,a5
 45a:	32072783          	lw	a5,800(a4)
 45e:	0017869b          	addiw	a3,a5,1
 462:	32d72023          	sw	a3,800(a4)
 466:	97aa                	add	a5,a5,a0
 468:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 46c:	47a9                	li	a5,10
 46e:	02f90463          	beq	s2,a5,496 <putc+0x62>
 472:	00249713          	slli	a4,s1,0x2
 476:	00000797          	auipc	a5,0x0
 47a:	52a78793          	addi	a5,a5,1322 # 9a0 <putc_buf>
 47e:	97ba                	add	a5,a5,a4
 480:	3207a703          	lw	a4,800(a5)
 484:	6785                	lui	a5,0x1
 486:	00f70863          	beq	a4,a5,496 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 48a:	60e2                	ld	ra,24(sp)
 48c:	6442                	ld	s0,16(sp)
 48e:	64a2                	ld	s1,8(sp)
 490:	6902                	ld	s2,0(sp)
 492:	6105                	addi	sp,sp,32
 494:	8082                	ret
    write(fd, buf, putc_index[fd]);
 496:	00249793          	slli	a5,s1,0x2
 49a:	00000917          	auipc	s2,0x0
 49e:	50690913          	addi	s2,s2,1286 # 9a0 <putc_buf>
 4a2:	993e                	add	s2,s2,a5
 4a4:	32092603          	lw	a2,800(s2)
 4a8:	85aa                	mv	a1,a0
 4aa:	8526                	mv	a0,s1
 4ac:	00000097          	auipc	ra,0x0
 4b0:	e94080e7          	jalr	-364(ra) # 340 <write>
    putc_index[fd] = 0;
 4b4:	32092023          	sw	zero,800(s2)
}
 4b8:	bfc9                	j	48a <putc+0x56>

00000000000004ba <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4ba:	7139                	addi	sp,sp,-64
 4bc:	fc06                	sd	ra,56(sp)
 4be:	f822                	sd	s0,48(sp)
 4c0:	f426                	sd	s1,40(sp)
 4c2:	f04a                	sd	s2,32(sp)
 4c4:	ec4e                	sd	s3,24(sp)
 4c6:	0080                	addi	s0,sp,64
 4c8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ca:	c299                	beqz	a3,4d0 <printint+0x16>
 4cc:	0805c863          	bltz	a1,55c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4d0:	2581                	sext.w	a1,a1
  neg = 0;
 4d2:	4881                	li	a7,0
 4d4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4da:	2601                	sext.w	a2,a2
 4dc:	00000517          	auipc	a0,0x0
 4e0:	4a450513          	addi	a0,a0,1188 # 980 <digits>
 4e4:	883a                	mv	a6,a4
 4e6:	2705                	addiw	a4,a4,1
 4e8:	02c5f7bb          	remuw	a5,a1,a2
 4ec:	1782                	slli	a5,a5,0x20
 4ee:	9381                	srli	a5,a5,0x20
 4f0:	97aa                	add	a5,a5,a0
 4f2:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x1a0>
 4f6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4fa:	0005879b          	sext.w	a5,a1
 4fe:	02c5d5bb          	divuw	a1,a1,a2
 502:	0685                	addi	a3,a3,1
 504:	fec7f0e3          	bgeu	a5,a2,4e4 <printint+0x2a>
  if(neg)
 508:	00088b63          	beqz	a7,51e <printint+0x64>
    buf[i++] = '-';
 50c:	fd040793          	addi	a5,s0,-48
 510:	973e                	add	a4,a4,a5
 512:	02d00793          	li	a5,45
 516:	fef70823          	sb	a5,-16(a4)
 51a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 51e:	02e05863          	blez	a4,54e <printint+0x94>
 522:	fc040793          	addi	a5,s0,-64
 526:	00e78933          	add	s2,a5,a4
 52a:	fff78993          	addi	s3,a5,-1
 52e:	99ba                	add	s3,s3,a4
 530:	377d                	addiw	a4,a4,-1
 532:	1702                	slli	a4,a4,0x20
 534:	9301                	srli	a4,a4,0x20
 536:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 53a:	fff94583          	lbu	a1,-1(s2)
 53e:	8526                	mv	a0,s1
 540:	00000097          	auipc	ra,0x0
 544:	ef4080e7          	jalr	-268(ra) # 434 <putc>
  while(--i >= 0)
 548:	197d                	addi	s2,s2,-1
 54a:	ff3918e3          	bne	s2,s3,53a <printint+0x80>
}
 54e:	70e2                	ld	ra,56(sp)
 550:	7442                	ld	s0,48(sp)
 552:	74a2                	ld	s1,40(sp)
 554:	7902                	ld	s2,32(sp)
 556:	69e2                	ld	s3,24(sp)
 558:	6121                	addi	sp,sp,64
 55a:	8082                	ret
    x = -xx;
 55c:	40b005bb          	negw	a1,a1
    neg = 1;
 560:	4885                	li	a7,1
    x = -xx;
 562:	bf8d                	j	4d4 <printint+0x1a>

0000000000000564 <fflush>:
void fflush(int fd){
 564:	1101                	addi	sp,sp,-32
 566:	ec06                	sd	ra,24(sp)
 568:	e822                	sd	s0,16(sp)
 56a:	e426                	sd	s1,8(sp)
 56c:	e04a                	sd	s2,0(sp)
 56e:	1000                	addi	s0,sp,32
 570:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 572:	00000097          	auipc	ra,0x0
 576:	e76080e7          	jalr	-394(ra) # 3e8 <get_putc_buf>
 57a:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 57c:	00291793          	slli	a5,s2,0x2
 580:	00000497          	auipc	s1,0x0
 584:	42048493          	addi	s1,s1,1056 # 9a0 <putc_buf>
 588:	94be                	add	s1,s1,a5
 58a:	3204a603          	lw	a2,800(s1)
 58e:	854a                	mv	a0,s2
 590:	00000097          	auipc	ra,0x0
 594:	db0080e7          	jalr	-592(ra) # 340 <write>
  putc_index[fd] = 0;
 598:	3204a023          	sw	zero,800(s1)
}
 59c:	60e2                	ld	ra,24(sp)
 59e:	6442                	ld	s0,16(sp)
 5a0:	64a2                	ld	s1,8(sp)
 5a2:	6902                	ld	s2,0(sp)
 5a4:	6105                	addi	sp,sp,32
 5a6:	8082                	ret

00000000000005a8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5a8:	7119                	addi	sp,sp,-128
 5aa:	fc86                	sd	ra,120(sp)
 5ac:	f8a2                	sd	s0,112(sp)
 5ae:	f4a6                	sd	s1,104(sp)
 5b0:	f0ca                	sd	s2,96(sp)
 5b2:	ecce                	sd	s3,88(sp)
 5b4:	e8d2                	sd	s4,80(sp)
 5b6:	e4d6                	sd	s5,72(sp)
 5b8:	e0da                	sd	s6,64(sp)
 5ba:	fc5e                	sd	s7,56(sp)
 5bc:	f862                	sd	s8,48(sp)
 5be:	f466                	sd	s9,40(sp)
 5c0:	f06a                	sd	s10,32(sp)
 5c2:	ec6e                	sd	s11,24(sp)
 5c4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5c6:	0005c903          	lbu	s2,0(a1)
 5ca:	18090f63          	beqz	s2,768 <vprintf+0x1c0>
 5ce:	8aaa                	mv	s5,a0
 5d0:	8b32                	mv	s6,a2
 5d2:	00158493          	addi	s1,a1,1
  state = 0;
 5d6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5d8:	02500a13          	li	s4,37
      if(c == 'd'){
 5dc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5e0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5e4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5e8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ec:	00000b97          	auipc	s7,0x0
 5f0:	394b8b93          	addi	s7,s7,916 # 980 <digits>
 5f4:	a839                	j	612 <vprintf+0x6a>
        putc(fd, c);
 5f6:	85ca                	mv	a1,s2
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e3a080e7          	jalr	-454(ra) # 434 <putc>
 602:	a019                	j	608 <vprintf+0x60>
    } else if(state == '%'){
 604:	01498f63          	beq	s3,s4,622 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 608:	0485                	addi	s1,s1,1
 60a:	fff4c903          	lbu	s2,-1(s1)
 60e:	14090d63          	beqz	s2,768 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 612:	0009079b          	sext.w	a5,s2
    if(state == 0){
 616:	fe0997e3          	bnez	s3,604 <vprintf+0x5c>
      if(c == '%'){
 61a:	fd479ee3          	bne	a5,s4,5f6 <vprintf+0x4e>
        state = '%';
 61e:	89be                	mv	s3,a5
 620:	b7e5                	j	608 <vprintf+0x60>
      if(c == 'd'){
 622:	05878063          	beq	a5,s8,662 <vprintf+0xba>
      } else if(c == 'l') {
 626:	05978c63          	beq	a5,s9,67e <vprintf+0xd6>
      } else if(c == 'x') {
 62a:	07a78863          	beq	a5,s10,69a <vprintf+0xf2>
      } else if(c == 'p') {
 62e:	09b78463          	beq	a5,s11,6b6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 632:	07300713          	li	a4,115
 636:	0ce78663          	beq	a5,a4,702 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 63a:	06300713          	li	a4,99
 63e:	0ee78e63          	beq	a5,a4,73a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 642:	11478863          	beq	a5,s4,752 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 646:	85d2                	mv	a1,s4
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	dea080e7          	jalr	-534(ra) # 434 <putc>
        putc(fd, c);
 652:	85ca                	mv	a1,s2
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	dde080e7          	jalr	-546(ra) # 434 <putc>
      }
      state = 0;
 65e:	4981                	li	s3,0
 660:	b765                	j	608 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 662:	008b0913          	addi	s2,s6,8
 666:	4685                	li	a3,1
 668:	4629                	li	a2,10
 66a:	000b2583          	lw	a1,0(s6)
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	e4a080e7          	jalr	-438(ra) # 4ba <printint>
 678:	8b4a                	mv	s6,s2
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b771                	j	608 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67e:	008b0913          	addi	s2,s6,8
 682:	4681                	li	a3,0
 684:	4629                	li	a2,10
 686:	000b2583          	lw	a1,0(s6)
 68a:	8556                	mv	a0,s5
 68c:	00000097          	auipc	ra,0x0
 690:	e2e080e7          	jalr	-466(ra) # 4ba <printint>
 694:	8b4a                	mv	s6,s2
      state = 0;
 696:	4981                	li	s3,0
 698:	bf85                	j	608 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 69a:	008b0913          	addi	s2,s6,8
 69e:	4681                	li	a3,0
 6a0:	4641                	li	a2,16
 6a2:	000b2583          	lw	a1,0(s6)
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	e12080e7          	jalr	-494(ra) # 4ba <printint>
 6b0:	8b4a                	mv	s6,s2
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bf91                	j	608 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6b6:	008b0793          	addi	a5,s6,8
 6ba:	f8f43423          	sd	a5,-120(s0)
 6be:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6c2:	03000593          	li	a1,48
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	d6c080e7          	jalr	-660(ra) # 434 <putc>
  putc(fd, 'x');
 6d0:	85ea                	mv	a1,s10
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	d60080e7          	jalr	-672(ra) # 434 <putc>
 6dc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6de:	03c9d793          	srli	a5,s3,0x3c
 6e2:	97de                	add	a5,a5,s7
 6e4:	0007c583          	lbu	a1,0(a5)
 6e8:	8556                	mv	a0,s5
 6ea:	00000097          	auipc	ra,0x0
 6ee:	d4a080e7          	jalr	-694(ra) # 434 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f2:	0992                	slli	s3,s3,0x4
 6f4:	397d                	addiw	s2,s2,-1
 6f6:	fe0914e3          	bnez	s2,6de <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6fa:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b721                	j	608 <vprintf+0x60>
        s = va_arg(ap, char*);
 702:	008b0993          	addi	s3,s6,8
 706:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 70a:	02090163          	beqz	s2,72c <vprintf+0x184>
        while(*s != 0){
 70e:	00094583          	lbu	a1,0(s2)
 712:	c9a1                	beqz	a1,762 <vprintf+0x1ba>
          putc(fd, *s);
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	d1e080e7          	jalr	-738(ra) # 434 <putc>
          s++;
 71e:	0905                	addi	s2,s2,1
        while(*s != 0){
 720:	00094583          	lbu	a1,0(s2)
 724:	f9e5                	bnez	a1,714 <vprintf+0x16c>
        s = va_arg(ap, char*);
 726:	8b4e                	mv	s6,s3
      state = 0;
 728:	4981                	li	s3,0
 72a:	bdf9                	j	608 <vprintf+0x60>
          s = "(null)";
 72c:	00000917          	auipc	s2,0x0
 730:	24c90913          	addi	s2,s2,588 # 978 <malloc+0x106>
        while(*s != 0){
 734:	02800593          	li	a1,40
 738:	bff1                	j	714 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 73a:	008b0913          	addi	s2,s6,8
 73e:	000b4583          	lbu	a1,0(s6)
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	cf0080e7          	jalr	-784(ra) # 434 <putc>
 74c:	8b4a                	mv	s6,s2
      state = 0;
 74e:	4981                	li	s3,0
 750:	bd65                	j	608 <vprintf+0x60>
        putc(fd, c);
 752:	85d2                	mv	a1,s4
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	cde080e7          	jalr	-802(ra) # 434 <putc>
      state = 0;
 75e:	4981                	li	s3,0
 760:	b565                	j	608 <vprintf+0x60>
        s = va_arg(ap, char*);
 762:	8b4e                	mv	s6,s3
      state = 0;
 764:	4981                	li	s3,0
 766:	b54d                	j	608 <vprintf+0x60>
    }
  }
}
 768:	70e6                	ld	ra,120(sp)
 76a:	7446                	ld	s0,112(sp)
 76c:	74a6                	ld	s1,104(sp)
 76e:	7906                	ld	s2,96(sp)
 770:	69e6                	ld	s3,88(sp)
 772:	6a46                	ld	s4,80(sp)
 774:	6aa6                	ld	s5,72(sp)
 776:	6b06                	ld	s6,64(sp)
 778:	7be2                	ld	s7,56(sp)
 77a:	7c42                	ld	s8,48(sp)
 77c:	7ca2                	ld	s9,40(sp)
 77e:	7d02                	ld	s10,32(sp)
 780:	6de2                	ld	s11,24(sp)
 782:	6109                	addi	sp,sp,128
 784:	8082                	ret

0000000000000786 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 786:	715d                	addi	sp,sp,-80
 788:	ec06                	sd	ra,24(sp)
 78a:	e822                	sd	s0,16(sp)
 78c:	1000                	addi	s0,sp,32
 78e:	e010                	sd	a2,0(s0)
 790:	e414                	sd	a3,8(s0)
 792:	e818                	sd	a4,16(s0)
 794:	ec1c                	sd	a5,24(s0)
 796:	03043023          	sd	a6,32(s0)
 79a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a2:	8622                	mv	a2,s0
 7a4:	00000097          	auipc	ra,0x0
 7a8:	e04080e7          	jalr	-508(ra) # 5a8 <vprintf>
}
 7ac:	60e2                	ld	ra,24(sp)
 7ae:	6442                	ld	s0,16(sp)
 7b0:	6161                	addi	sp,sp,80
 7b2:	8082                	ret

00000000000007b4 <printf>:

void
printf(const char *fmt, ...)
{
 7b4:	711d                	addi	sp,sp,-96
 7b6:	ec06                	sd	ra,24(sp)
 7b8:	e822                	sd	s0,16(sp)
 7ba:	1000                	addi	s0,sp,32
 7bc:	e40c                	sd	a1,8(s0)
 7be:	e810                	sd	a2,16(s0)
 7c0:	ec14                	sd	a3,24(s0)
 7c2:	f018                	sd	a4,32(s0)
 7c4:	f41c                	sd	a5,40(s0)
 7c6:	03043823          	sd	a6,48(s0)
 7ca:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ce:	00840613          	addi	a2,s0,8
 7d2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d6:	85aa                	mv	a1,a0
 7d8:	4505                	li	a0,1
 7da:	00000097          	auipc	ra,0x0
 7de:	dce080e7          	jalr	-562(ra) # 5a8 <vprintf>
}
 7e2:	60e2                	ld	ra,24(sp)
 7e4:	6442                	ld	s0,16(sp)
 7e6:	6125                	addi	sp,sp,96
 7e8:	8082                	ret

00000000000007ea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ea:	1141                	addi	sp,sp,-16
 7ec:	e422                	sd	s0,8(sp)
 7ee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f4:	00000797          	auipc	a5,0x0
 7f8:	1a47b783          	ld	a5,420(a5) # 998 <freep>
 7fc:	a805                	j	82c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7fe:	4618                	lw	a4,8(a2)
 800:	9db9                	addw	a1,a1,a4
 802:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 806:	6398                	ld	a4,0(a5)
 808:	6318                	ld	a4,0(a4)
 80a:	fee53823          	sd	a4,-16(a0)
 80e:	a091                	j	852 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 810:	ff852703          	lw	a4,-8(a0)
 814:	9e39                	addw	a2,a2,a4
 816:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 818:	ff053703          	ld	a4,-16(a0)
 81c:	e398                	sd	a4,0(a5)
 81e:	a099                	j	864 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 820:	6398                	ld	a4,0(a5)
 822:	00e7e463          	bltu	a5,a4,82a <free+0x40>
 826:	00e6ea63          	bltu	a3,a4,83a <free+0x50>
{
 82a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82c:	fed7fae3          	bgeu	a5,a3,820 <free+0x36>
 830:	6398                	ld	a4,0(a5)
 832:	00e6e463          	bltu	a3,a4,83a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 836:	fee7eae3          	bltu	a5,a4,82a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 83a:	ff852583          	lw	a1,-8(a0)
 83e:	6390                	ld	a2,0(a5)
 840:	02059713          	slli	a4,a1,0x20
 844:	9301                	srli	a4,a4,0x20
 846:	0712                	slli	a4,a4,0x4
 848:	9736                	add	a4,a4,a3
 84a:	fae60ae3          	beq	a2,a4,7fe <free+0x14>
    bp->s.ptr = p->s.ptr;
 84e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 852:	4790                	lw	a2,8(a5)
 854:	02061713          	slli	a4,a2,0x20
 858:	9301                	srli	a4,a4,0x20
 85a:	0712                	slli	a4,a4,0x4
 85c:	973e                	add	a4,a4,a5
 85e:	fae689e3          	beq	a3,a4,810 <free+0x26>
  } else
    p->s.ptr = bp;
 862:	e394                	sd	a3,0(a5)
  freep = p;
 864:	00000717          	auipc	a4,0x0
 868:	12f73a23          	sd	a5,308(a4) # 998 <freep>
}
 86c:	6422                	ld	s0,8(sp)
 86e:	0141                	addi	sp,sp,16
 870:	8082                	ret

0000000000000872 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 872:	7139                	addi	sp,sp,-64
 874:	fc06                	sd	ra,56(sp)
 876:	f822                	sd	s0,48(sp)
 878:	f426                	sd	s1,40(sp)
 87a:	f04a                	sd	s2,32(sp)
 87c:	ec4e                	sd	s3,24(sp)
 87e:	e852                	sd	s4,16(sp)
 880:	e456                	sd	s5,8(sp)
 882:	e05a                	sd	s6,0(sp)
 884:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 886:	02051493          	slli	s1,a0,0x20
 88a:	9081                	srli	s1,s1,0x20
 88c:	04bd                	addi	s1,s1,15
 88e:	8091                	srli	s1,s1,0x4
 890:	0014899b          	addiw	s3,s1,1
 894:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 896:	00000517          	auipc	a0,0x0
 89a:	10253503          	ld	a0,258(a0) # 998 <freep>
 89e:	c515                	beqz	a0,8ca <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a2:	4798                	lw	a4,8(a5)
 8a4:	02977f63          	bgeu	a4,s1,8e2 <malloc+0x70>
 8a8:	8a4e                	mv	s4,s3
 8aa:	0009871b          	sext.w	a4,s3
 8ae:	6685                	lui	a3,0x1
 8b0:	00d77363          	bgeu	a4,a3,8b6 <malloc+0x44>
 8b4:	6a05                	lui	s4,0x1
 8b6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ba:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8be:	00000917          	auipc	s2,0x0
 8c2:	0da90913          	addi	s2,s2,218 # 998 <freep>
  if(p == (char*)-1)
 8c6:	5afd                	li	s5,-1
 8c8:	a88d                	j	93a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8ca:	00000797          	auipc	a5,0x0
 8ce:	58678793          	addi	a5,a5,1414 # e50 <base>
 8d2:	00000717          	auipc	a4,0x0
 8d6:	0cf73323          	sd	a5,198(a4) # 998 <freep>
 8da:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8dc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e0:	b7e1                	j	8a8 <malloc+0x36>
      if(p->s.size == nunits)
 8e2:	02e48b63          	beq	s1,a4,918 <malloc+0xa6>
        p->s.size -= nunits;
 8e6:	4137073b          	subw	a4,a4,s3
 8ea:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ec:	1702                	slli	a4,a4,0x20
 8ee:	9301                	srli	a4,a4,0x20
 8f0:	0712                	slli	a4,a4,0x4
 8f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f8:	00000717          	auipc	a4,0x0
 8fc:	0aa73023          	sd	a0,160(a4) # 998 <freep>
      return (void*)(p + 1);
 900:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 904:	70e2                	ld	ra,56(sp)
 906:	7442                	ld	s0,48(sp)
 908:	74a2                	ld	s1,40(sp)
 90a:	7902                	ld	s2,32(sp)
 90c:	69e2                	ld	s3,24(sp)
 90e:	6a42                	ld	s4,16(sp)
 910:	6aa2                	ld	s5,8(sp)
 912:	6b02                	ld	s6,0(sp)
 914:	6121                	addi	sp,sp,64
 916:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 918:	6398                	ld	a4,0(a5)
 91a:	e118                	sd	a4,0(a0)
 91c:	bff1                	j	8f8 <malloc+0x86>
  hp->s.size = nu;
 91e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 922:	0541                	addi	a0,a0,16
 924:	00000097          	auipc	ra,0x0
 928:	ec6080e7          	jalr	-314(ra) # 7ea <free>
  return freep;
 92c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 930:	d971                	beqz	a0,904 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 932:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 934:	4798                	lw	a4,8(a5)
 936:	fa9776e3          	bgeu	a4,s1,8e2 <malloc+0x70>
    if(p == freep)
 93a:	00093703          	ld	a4,0(s2)
 93e:	853e                	mv	a0,a5
 940:	fef719e3          	bne	a4,a5,932 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 944:	8552                	mv	a0,s4
 946:	00000097          	auipc	ra,0x0
 94a:	a62080e7          	jalr	-1438(ra) # 3a8 <sbrk>
  if(p == (char*)-1)
 94e:	fd5518e3          	bne	a0,s5,91e <malloc+0xac>
        return 0;
 952:	4501                	li	a0,0
 954:	bf45                	j	904 <malloc+0x92>
