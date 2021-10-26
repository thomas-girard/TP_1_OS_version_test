
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  if(argc != 3){
   a:	478d                	li	a5,3
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	95058593          	addi	a1,a1,-1712 # 960 <malloc+0xea>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	770080e7          	jalr	1904(ra) # 78a <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	300080e7          	jalr	768(ra) # 324 <exit>
  2c:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  2e:	698c                	ld	a1,16(a1)
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	352080e7          	jalr	850(ra) # 384 <link>
  3a:	00054763          	bltz	a0,48 <main+0x48>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2e4080e7          	jalr	740(ra) # 324 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	6894                	ld	a3,16(s1)
  4a:	6490                	ld	a2,8(s1)
  4c:	00001597          	auipc	a1,0x1
  50:	92c58593          	addi	a1,a1,-1748 # 978 <malloc+0x102>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	734080e7          	jalr	1844(ra) # 78a <fprintf>
  5e:	b7c5                	j	3e <main+0x3e>

0000000000000060 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  66:	87aa                	mv	a5,a0
  68:	0585                	addi	a1,a1,1
  6a:	0785                	addi	a5,a5,1
  6c:	fff5c703          	lbu	a4,-1(a1)
  70:	fee78fa3          	sb	a4,-1(a5)
  74:	fb75                	bnez	a4,68 <strcpy+0x8>
    ;
  return os;
}
  76:	6422                	ld	s0,8(sp)
  78:	0141                	addi	sp,sp,16
  7a:	8082                	ret

000000000000007c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  82:	00054783          	lbu	a5,0(a0)
  86:	cb91                	beqz	a5,9a <strcmp+0x1e>
  88:	0005c703          	lbu	a4,0(a1)
  8c:	00f71763          	bne	a4,a5,9a <strcmp+0x1e>
    p++, q++;
  90:	0505                	addi	a0,a0,1
  92:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  94:	00054783          	lbu	a5,0(a0)
  98:	fbe5                	bnez	a5,88 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9a:	0005c503          	lbu	a0,0(a1)
}
  9e:	40a7853b          	subw	a0,a5,a0
  a2:	6422                	ld	s0,8(sp)
  a4:	0141                	addi	sp,sp,16
  a6:	8082                	ret

00000000000000a8 <strlen>:

uint
strlen(const char *s)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cf91                	beqz	a5,ce <strlen+0x26>
  b4:	0505                	addi	a0,a0,1
  b6:	87aa                	mv	a5,a0
  b8:	4685                	li	a3,1
  ba:	9e89                	subw	a3,a3,a0
  bc:	00f6853b          	addw	a0,a3,a5
  c0:	0785                	addi	a5,a5,1
  c2:	fff7c703          	lbu	a4,-1(a5)
  c6:	fb7d                	bnez	a4,bc <strlen+0x14>
    ;
  return n;
}
  c8:	6422                	ld	s0,8(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret
  for(n = 0; s[n]; n++)
  ce:	4501                	li	a0,0
  d0:	bfe5                	j	c8 <strlen+0x20>

00000000000000d2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d8:	ce09                	beqz	a2,f2 <memset+0x20>
  da:	87aa                	mv	a5,a0
  dc:	fff6071b          	addiw	a4,a2,-1
  e0:	1702                	slli	a4,a4,0x20
  e2:	9301                	srli	a4,a4,0x20
  e4:	0705                	addi	a4,a4,1
  e6:	972a                	add	a4,a4,a0
    cdst[i] = c;
  e8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ec:	0785                	addi	a5,a5,1
  ee:	fee79de3          	bne	a5,a4,e8 <memset+0x16>
  }
  return dst;
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <strchr>:

char*
strchr(const char *s, char c)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cb99                	beqz	a5,118 <strchr+0x20>
    if(*s == c)
 104:	00f58763          	beq	a1,a5,112 <strchr+0x1a>
  for(; *s; s++)
 108:	0505                	addi	a0,a0,1
 10a:	00054783          	lbu	a5,0(a0)
 10e:	fbfd                	bnez	a5,104 <strchr+0xc>
      return (char*)s;
  return 0;
 110:	4501                	li	a0,0
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret
  return 0;
 118:	4501                	li	a0,0
 11a:	bfe5                	j	112 <strchr+0x1a>

000000000000011c <gets>:

char*
gets(char *buf, int max)
{
 11c:	711d                	addi	sp,sp,-96
 11e:	ec86                	sd	ra,88(sp)
 120:	e8a2                	sd	s0,80(sp)
 122:	e4a6                	sd	s1,72(sp)
 124:	e0ca                	sd	s2,64(sp)
 126:	fc4e                	sd	s3,56(sp)
 128:	f852                	sd	s4,48(sp)
 12a:	f456                	sd	s5,40(sp)
 12c:	f05a                	sd	s6,32(sp)
 12e:	ec5e                	sd	s7,24(sp)
 130:	1080                	addi	s0,sp,96
 132:	8baa                	mv	s7,a0
 134:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 136:	892a                	mv	s2,a0
 138:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 13a:	4aa9                	li	s5,10
 13c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13e:	89a6                	mv	s3,s1
 140:	2485                	addiw	s1,s1,1
 142:	0344d863          	bge	s1,s4,172 <gets+0x56>
    cc = read(0, &c, 1);
 146:	4605                	li	a2,1
 148:	faf40593          	addi	a1,s0,-81
 14c:	4501                	li	a0,0
 14e:	00000097          	auipc	ra,0x0
 152:	1ee080e7          	jalr	494(ra) # 33c <read>
    if(cc < 1)
 156:	00a05e63          	blez	a0,172 <gets+0x56>
    buf[i++] = c;
 15a:	faf44783          	lbu	a5,-81(s0)
 15e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 162:	01578763          	beq	a5,s5,170 <gets+0x54>
 166:	0905                	addi	s2,s2,1
 168:	fd679be3          	bne	a5,s6,13e <gets+0x22>
  for(i=0; i+1 < max; ){
 16c:	89a6                	mv	s3,s1
 16e:	a011                	j	172 <gets+0x56>
 170:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 172:	99de                	add	s3,s3,s7
 174:	00098023          	sb	zero,0(s3)
  return buf;
}
 178:	855e                	mv	a0,s7
 17a:	60e6                	ld	ra,88(sp)
 17c:	6446                	ld	s0,80(sp)
 17e:	64a6                	ld	s1,72(sp)
 180:	6906                	ld	s2,64(sp)
 182:	79e2                	ld	s3,56(sp)
 184:	7a42                	ld	s4,48(sp)
 186:	7aa2                	ld	s5,40(sp)
 188:	7b02                	ld	s6,32(sp)
 18a:	6be2                	ld	s7,24(sp)
 18c:	6125                	addi	sp,sp,96
 18e:	8082                	ret

0000000000000190 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 196:	00054603          	lbu	a2,0(a0)
 19a:	fd06079b          	addiw	a5,a2,-48
 19e:	0ff7f793          	andi	a5,a5,255
 1a2:	4725                	li	a4,9
 1a4:	02f76963          	bltu	a4,a5,1d6 <atoi+0x46>
 1a8:	86aa                	mv	a3,a0
  n = 0;
 1aa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1ac:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1ae:	0685                	addi	a3,a3,1
 1b0:	0025179b          	slliw	a5,a0,0x2
 1b4:	9fa9                	addw	a5,a5,a0
 1b6:	0017979b          	slliw	a5,a5,0x1
 1ba:	9fb1                	addw	a5,a5,a2
 1bc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c0:	0006c603          	lbu	a2,0(a3)
 1c4:	fd06071b          	addiw	a4,a2,-48
 1c8:	0ff77713          	andi	a4,a4,255
 1cc:	fee5f1e3          	bgeu	a1,a4,1ae <atoi+0x1e>
  return n;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
  n = 0;
 1d6:	4501                	li	a0,0
 1d8:	bfe5                	j	1d0 <atoi+0x40>

00000000000001da <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e422                	sd	s0,8(sp)
 1de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e0:	02b57663          	bgeu	a0,a1,20c <memmove+0x32>
    while(n-- > 0)
 1e4:	02c05163          	blez	a2,206 <memmove+0x2c>
 1e8:	fff6079b          	addiw	a5,a2,-1
 1ec:	1782                	slli	a5,a5,0x20
 1ee:	9381                	srli	a5,a5,0x20
 1f0:	0785                	addi	a5,a5,1
 1f2:	97aa                	add	a5,a5,a0
  dst = vdst;
 1f4:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f6:	0585                	addi	a1,a1,1
 1f8:	0705                	addi	a4,a4,1
 1fa:	fff5c683          	lbu	a3,-1(a1)
 1fe:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 202:	fee79ae3          	bne	a5,a4,1f6 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret
    dst += n;
 20c:	00c50733          	add	a4,a0,a2
    src += n;
 210:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 212:	fec05ae3          	blez	a2,206 <memmove+0x2c>
 216:	fff6079b          	addiw	a5,a2,-1
 21a:	1782                	slli	a5,a5,0x20
 21c:	9381                	srli	a5,a5,0x20
 21e:	fff7c793          	not	a5,a5
 222:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 224:	15fd                	addi	a1,a1,-1
 226:	177d                	addi	a4,a4,-1
 228:	0005c683          	lbu	a3,0(a1)
 22c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 230:	fee79ae3          	bne	a5,a4,224 <memmove+0x4a>
 234:	bfc9                	j	206 <memmove+0x2c>

0000000000000236 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 23c:	ca05                	beqz	a2,26c <memcmp+0x36>
 23e:	fff6069b          	addiw	a3,a2,-1
 242:	1682                	slli	a3,a3,0x20
 244:	9281                	srli	a3,a3,0x20
 246:	0685                	addi	a3,a3,1
 248:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 24a:	00054783          	lbu	a5,0(a0)
 24e:	0005c703          	lbu	a4,0(a1)
 252:	00e79863          	bne	a5,a4,262 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 256:	0505                	addi	a0,a0,1
    p2++;
 258:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 25a:	fed518e3          	bne	a0,a3,24a <memcmp+0x14>
  }
  return 0;
 25e:	4501                	li	a0,0
 260:	a019                	j	266 <memcmp+0x30>
      return *p1 - *p2;
 262:	40e7853b          	subw	a0,a5,a4
}
 266:	6422                	ld	s0,8(sp)
 268:	0141                	addi	sp,sp,16
 26a:	8082                	ret
  return 0;
 26c:	4501                	li	a0,0
 26e:	bfe5                	j	266 <memcmp+0x30>

0000000000000270 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 270:	1141                	addi	sp,sp,-16
 272:	e406                	sd	ra,8(sp)
 274:	e022                	sd	s0,0(sp)
 276:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 278:	00000097          	auipc	ra,0x0
 27c:	f62080e7          	jalr	-158(ra) # 1da <memmove>
}
 280:	60a2                	ld	ra,8(sp)
 282:	6402                	ld	s0,0(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret

0000000000000288 <close>:

int close(int fd){
 288:	1101                	addi	sp,sp,-32
 28a:	ec06                	sd	ra,24(sp)
 28c:	e822                	sd	s0,16(sp)
 28e:	e426                	sd	s1,8(sp)
 290:	1000                	addi	s0,sp,32
 292:	84aa                	mv	s1,a0
  fflush(fd);
 294:	00000097          	auipc	ra,0x0
 298:	2d4080e7          	jalr	724(ra) # 568 <fflush>
  char* buf = get_putc_buf(fd);
 29c:	8526                	mv	a0,s1
 29e:	00000097          	auipc	ra,0x0
 2a2:	14e080e7          	jalr	334(ra) # 3ec <get_putc_buf>
  if(buf){
 2a6:	cd11                	beqz	a0,2c2 <close+0x3a>
    free(buf);
 2a8:	00000097          	auipc	ra,0x0
 2ac:	546080e7          	jalr	1350(ra) # 7ee <free>
    putc_buf[fd] = 0;
 2b0:	00349713          	slli	a4,s1,0x3
 2b4:	00000797          	auipc	a5,0x0
 2b8:	70478793          	addi	a5,a5,1796 # 9b8 <putc_buf>
 2bc:	97ba                	add	a5,a5,a4
 2be:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 2c2:	8526                	mv	a0,s1
 2c4:	00000097          	auipc	ra,0x0
 2c8:	088080e7          	jalr	136(ra) # 34c <sclose>
}
 2cc:	60e2                	ld	ra,24(sp)
 2ce:	6442                	ld	s0,16(sp)
 2d0:	64a2                	ld	s1,8(sp)
 2d2:	6105                	addi	sp,sp,32
 2d4:	8082                	ret

00000000000002d6 <stat>:
{
 2d6:	1101                	addi	sp,sp,-32
 2d8:	ec06                	sd	ra,24(sp)
 2da:	e822                	sd	s0,16(sp)
 2dc:	e426                	sd	s1,8(sp)
 2de:	e04a                	sd	s2,0(sp)
 2e0:	1000                	addi	s0,sp,32
 2e2:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 2e4:	4581                	li	a1,0
 2e6:	00000097          	auipc	ra,0x0
 2ea:	07e080e7          	jalr	126(ra) # 364 <open>
  if(fd < 0)
 2ee:	02054563          	bltz	a0,318 <stat+0x42>
 2f2:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 2f4:	85ca                	mv	a1,s2
 2f6:	00000097          	auipc	ra,0x0
 2fa:	086080e7          	jalr	134(ra) # 37c <fstat>
 2fe:	892a                	mv	s2,a0
  close(fd);
 300:	8526                	mv	a0,s1
 302:	00000097          	auipc	ra,0x0
 306:	f86080e7          	jalr	-122(ra) # 288 <close>
}
 30a:	854a                	mv	a0,s2
 30c:	60e2                	ld	ra,24(sp)
 30e:	6442                	ld	s0,16(sp)
 310:	64a2                	ld	s1,8(sp)
 312:	6902                	ld	s2,0(sp)
 314:	6105                	addi	sp,sp,32
 316:	8082                	ret
    return -1;
 318:	597d                	li	s2,-1
 31a:	bfc5                	j	30a <stat+0x34>

000000000000031c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 31c:	4885                	li	a7,1
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <exit>:
.global exit
exit:
 li a7, SYS_exit
 324:	4889                	li	a7,2
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <wait>:
.global wait
wait:
 li a7, SYS_wait
 32c:	488d                	li	a7,3
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 334:	4891                	li	a7,4
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <read>:
.global read
read:
 li a7, SYS_read
 33c:	4895                	li	a7,5
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <write>:
.global write
write:
 li a7, SYS_write
 344:	48c1                	li	a7,16
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 34c:	48d5                	li	a7,21
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <kill>:
.global kill
kill:
 li a7, SYS_kill
 354:	4899                	li	a7,6
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <exec>:
.global exec
exec:
 li a7, SYS_exec
 35c:	489d                	li	a7,7
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <open>:
.global open
open:
 li a7, SYS_open
 364:	48bd                	li	a7,15
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 36c:	48c5                	li	a7,17
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 374:	48c9                	li	a7,18
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 37c:	48a1                	li	a7,8
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <link>:
.global link
link:
 li a7, SYS_link
 384:	48cd                	li	a7,19
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 38c:	48d1                	li	a7,20
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 394:	48a5                	li	a7,9
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <dup>:
.global dup
dup:
 li a7, SYS_dup
 39c:	48a9                	li	a7,10
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a4:	48ad                	li	a7,11
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ac:	48b1                	li	a7,12
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b4:	48b5                	li	a7,13
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3bc:	48b9                	li	a7,14
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 3c4:	48d9                	li	a7,22
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <nice>:
.global nice
nice:
 li a7, SYS_nice
 3cc:	48dd                	li	a7,23
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 3d4:	48e1                	li	a7,24
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 3dc:	48e5                	li	a7,25
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 3e4:	48e9                	li	a7,26
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 3ec:	1101                	addi	sp,sp,-32
 3ee:	ec06                	sd	ra,24(sp)
 3f0:	e822                	sd	s0,16(sp)
 3f2:	e426                	sd	s1,8(sp)
 3f4:	1000                	addi	s0,sp,32
 3f6:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 3f8:	00351713          	slli	a4,a0,0x3
 3fc:	00000797          	auipc	a5,0x0
 400:	5bc78793          	addi	a5,a5,1468 # 9b8 <putc_buf>
 404:	97ba                	add	a5,a5,a4
 406:	6388                	ld	a0,0(a5)
  if(buf) {
 408:	c511                	beqz	a0,414 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 40a:	60e2                	ld	ra,24(sp)
 40c:	6442                	ld	s0,16(sp)
 40e:	64a2                	ld	s1,8(sp)
 410:	6105                	addi	sp,sp,32
 412:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 414:	6505                	lui	a0,0x1
 416:	00000097          	auipc	ra,0x0
 41a:	460080e7          	jalr	1120(ra) # 876 <malloc>
  putc_buf[fd] = buf;
 41e:	00000797          	auipc	a5,0x0
 422:	59a78793          	addi	a5,a5,1434 # 9b8 <putc_buf>
 426:	00349713          	slli	a4,s1,0x3
 42a:	973e                	add	a4,a4,a5
 42c:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 42e:	048a                	slli	s1,s1,0x2
 430:	94be                	add	s1,s1,a5
 432:	3204a023          	sw	zero,800(s1)
  return buf;
 436:	bfd1                	j	40a <get_putc_buf+0x1e>

0000000000000438 <putc>:

static void
putc(int fd, char c)
{
 438:	1101                	addi	sp,sp,-32
 43a:	ec06                	sd	ra,24(sp)
 43c:	e822                	sd	s0,16(sp)
 43e:	e426                	sd	s1,8(sp)
 440:	e04a                	sd	s2,0(sp)
 442:	1000                	addi	s0,sp,32
 444:	84aa                	mv	s1,a0
 446:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 448:	00000097          	auipc	ra,0x0
 44c:	fa4080e7          	jalr	-92(ra) # 3ec <get_putc_buf>
  buf[putc_index[fd]++] = c;
 450:	00249793          	slli	a5,s1,0x2
 454:	00000717          	auipc	a4,0x0
 458:	56470713          	addi	a4,a4,1380 # 9b8 <putc_buf>
 45c:	973e                	add	a4,a4,a5
 45e:	32072783          	lw	a5,800(a4)
 462:	0017869b          	addiw	a3,a5,1
 466:	32d72023          	sw	a3,800(a4)
 46a:	97aa                	add	a5,a5,a0
 46c:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 470:	47a9                	li	a5,10
 472:	02f90463          	beq	s2,a5,49a <putc+0x62>
 476:	00249713          	slli	a4,s1,0x2
 47a:	00000797          	auipc	a5,0x0
 47e:	53e78793          	addi	a5,a5,1342 # 9b8 <putc_buf>
 482:	97ba                	add	a5,a5,a4
 484:	3207a703          	lw	a4,800(a5)
 488:	6785                	lui	a5,0x1
 48a:	00f70863          	beq	a4,a5,49a <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 48e:	60e2                	ld	ra,24(sp)
 490:	6442                	ld	s0,16(sp)
 492:	64a2                	ld	s1,8(sp)
 494:	6902                	ld	s2,0(sp)
 496:	6105                	addi	sp,sp,32
 498:	8082                	ret
    write(fd, buf, putc_index[fd]);
 49a:	00249793          	slli	a5,s1,0x2
 49e:	00000917          	auipc	s2,0x0
 4a2:	51a90913          	addi	s2,s2,1306 # 9b8 <putc_buf>
 4a6:	993e                	add	s2,s2,a5
 4a8:	32092603          	lw	a2,800(s2)
 4ac:	85aa                	mv	a1,a0
 4ae:	8526                	mv	a0,s1
 4b0:	00000097          	auipc	ra,0x0
 4b4:	e94080e7          	jalr	-364(ra) # 344 <write>
    putc_index[fd] = 0;
 4b8:	32092023          	sw	zero,800(s2)
}
 4bc:	bfc9                	j	48e <putc+0x56>

00000000000004be <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4be:	7139                	addi	sp,sp,-64
 4c0:	fc06                	sd	ra,56(sp)
 4c2:	f822                	sd	s0,48(sp)
 4c4:	f426                	sd	s1,40(sp)
 4c6:	f04a                	sd	s2,32(sp)
 4c8:	ec4e                	sd	s3,24(sp)
 4ca:	0080                	addi	s0,sp,64
 4cc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ce:	c299                	beqz	a3,4d4 <printint+0x16>
 4d0:	0805c863          	bltz	a1,560 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4d4:	2581                	sext.w	a1,a1
  neg = 0;
 4d6:	4881                	li	a7,0
 4d8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4dc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4de:	2601                	sext.w	a2,a2
 4e0:	00000517          	auipc	a0,0x0
 4e4:	4b850513          	addi	a0,a0,1208 # 998 <digits>
 4e8:	883a                	mv	a6,a4
 4ea:	2705                	addiw	a4,a4,1
 4ec:	02c5f7bb          	remuw	a5,a1,a2
 4f0:	1782                	slli	a5,a5,0x20
 4f2:	9381                	srli	a5,a5,0x20
 4f4:	97aa                	add	a5,a5,a0
 4f6:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x188>
 4fa:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4fe:	0005879b          	sext.w	a5,a1
 502:	02c5d5bb          	divuw	a1,a1,a2
 506:	0685                	addi	a3,a3,1
 508:	fec7f0e3          	bgeu	a5,a2,4e8 <printint+0x2a>
  if(neg)
 50c:	00088b63          	beqz	a7,522 <printint+0x64>
    buf[i++] = '-';
 510:	fd040793          	addi	a5,s0,-48
 514:	973e                	add	a4,a4,a5
 516:	02d00793          	li	a5,45
 51a:	fef70823          	sb	a5,-16(a4)
 51e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 522:	02e05863          	blez	a4,552 <printint+0x94>
 526:	fc040793          	addi	a5,s0,-64
 52a:	00e78933          	add	s2,a5,a4
 52e:	fff78993          	addi	s3,a5,-1
 532:	99ba                	add	s3,s3,a4
 534:	377d                	addiw	a4,a4,-1
 536:	1702                	slli	a4,a4,0x20
 538:	9301                	srli	a4,a4,0x20
 53a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 53e:	fff94583          	lbu	a1,-1(s2)
 542:	8526                	mv	a0,s1
 544:	00000097          	auipc	ra,0x0
 548:	ef4080e7          	jalr	-268(ra) # 438 <putc>
  while(--i >= 0)
 54c:	197d                	addi	s2,s2,-1
 54e:	ff3918e3          	bne	s2,s3,53e <printint+0x80>
}
 552:	70e2                	ld	ra,56(sp)
 554:	7442                	ld	s0,48(sp)
 556:	74a2                	ld	s1,40(sp)
 558:	7902                	ld	s2,32(sp)
 55a:	69e2                	ld	s3,24(sp)
 55c:	6121                	addi	sp,sp,64
 55e:	8082                	ret
    x = -xx;
 560:	40b005bb          	negw	a1,a1
    neg = 1;
 564:	4885                	li	a7,1
    x = -xx;
 566:	bf8d                	j	4d8 <printint+0x1a>

0000000000000568 <fflush>:
void fflush(int fd){
 568:	1101                	addi	sp,sp,-32
 56a:	ec06                	sd	ra,24(sp)
 56c:	e822                	sd	s0,16(sp)
 56e:	e426                	sd	s1,8(sp)
 570:	e04a                	sd	s2,0(sp)
 572:	1000                	addi	s0,sp,32
 574:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 576:	00000097          	auipc	ra,0x0
 57a:	e76080e7          	jalr	-394(ra) # 3ec <get_putc_buf>
 57e:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 580:	00291793          	slli	a5,s2,0x2
 584:	00000497          	auipc	s1,0x0
 588:	43448493          	addi	s1,s1,1076 # 9b8 <putc_buf>
 58c:	94be                	add	s1,s1,a5
 58e:	3204a603          	lw	a2,800(s1)
 592:	854a                	mv	a0,s2
 594:	00000097          	auipc	ra,0x0
 598:	db0080e7          	jalr	-592(ra) # 344 <write>
  putc_index[fd] = 0;
 59c:	3204a023          	sw	zero,800(s1)
}
 5a0:	60e2                	ld	ra,24(sp)
 5a2:	6442                	ld	s0,16(sp)
 5a4:	64a2                	ld	s1,8(sp)
 5a6:	6902                	ld	s2,0(sp)
 5a8:	6105                	addi	sp,sp,32
 5aa:	8082                	ret

00000000000005ac <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ac:	7119                	addi	sp,sp,-128
 5ae:	fc86                	sd	ra,120(sp)
 5b0:	f8a2                	sd	s0,112(sp)
 5b2:	f4a6                	sd	s1,104(sp)
 5b4:	f0ca                	sd	s2,96(sp)
 5b6:	ecce                	sd	s3,88(sp)
 5b8:	e8d2                	sd	s4,80(sp)
 5ba:	e4d6                	sd	s5,72(sp)
 5bc:	e0da                	sd	s6,64(sp)
 5be:	fc5e                	sd	s7,56(sp)
 5c0:	f862                	sd	s8,48(sp)
 5c2:	f466                	sd	s9,40(sp)
 5c4:	f06a                	sd	s10,32(sp)
 5c6:	ec6e                	sd	s11,24(sp)
 5c8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ca:	0005c903          	lbu	s2,0(a1)
 5ce:	18090f63          	beqz	s2,76c <vprintf+0x1c0>
 5d2:	8aaa                	mv	s5,a0
 5d4:	8b32                	mv	s6,a2
 5d6:	00158493          	addi	s1,a1,1
  state = 0;
 5da:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5dc:	02500a13          	li	s4,37
      if(c == 'd'){
 5e0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5e4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5e8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5ec:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f0:	00000b97          	auipc	s7,0x0
 5f4:	3a8b8b93          	addi	s7,s7,936 # 998 <digits>
 5f8:	a839                	j	616 <vprintf+0x6a>
        putc(fd, c);
 5fa:	85ca                	mv	a1,s2
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	e3a080e7          	jalr	-454(ra) # 438 <putc>
 606:	a019                	j	60c <vprintf+0x60>
    } else if(state == '%'){
 608:	01498f63          	beq	s3,s4,626 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 60c:	0485                	addi	s1,s1,1
 60e:	fff4c903          	lbu	s2,-1(s1)
 612:	14090d63          	beqz	s2,76c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 616:	0009079b          	sext.w	a5,s2
    if(state == 0){
 61a:	fe0997e3          	bnez	s3,608 <vprintf+0x5c>
      if(c == '%'){
 61e:	fd479ee3          	bne	a5,s4,5fa <vprintf+0x4e>
        state = '%';
 622:	89be                	mv	s3,a5
 624:	b7e5                	j	60c <vprintf+0x60>
      if(c == 'd'){
 626:	05878063          	beq	a5,s8,666 <vprintf+0xba>
      } else if(c == 'l') {
 62a:	05978c63          	beq	a5,s9,682 <vprintf+0xd6>
      } else if(c == 'x') {
 62e:	07a78863          	beq	a5,s10,69e <vprintf+0xf2>
      } else if(c == 'p') {
 632:	09b78463          	beq	a5,s11,6ba <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 636:	07300713          	li	a4,115
 63a:	0ce78663          	beq	a5,a4,706 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 63e:	06300713          	li	a4,99
 642:	0ee78e63          	beq	a5,a4,73e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 646:	11478863          	beq	a5,s4,756 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 64a:	85d2                	mv	a1,s4
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	dea080e7          	jalr	-534(ra) # 438 <putc>
        putc(fd, c);
 656:	85ca                	mv	a1,s2
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	dde080e7          	jalr	-546(ra) # 438 <putc>
      }
      state = 0;
 662:	4981                	li	s3,0
 664:	b765                	j	60c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 666:	008b0913          	addi	s2,s6,8
 66a:	4685                	li	a3,1
 66c:	4629                	li	a2,10
 66e:	000b2583          	lw	a1,0(s6)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e4a080e7          	jalr	-438(ra) # 4be <printint>
 67c:	8b4a                	mv	s6,s2
      state = 0;
 67e:	4981                	li	s3,0
 680:	b771                	j	60c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	008b0913          	addi	s2,s6,8
 686:	4681                	li	a3,0
 688:	4629                	li	a2,10
 68a:	000b2583          	lw	a1,0(s6)
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e2e080e7          	jalr	-466(ra) # 4be <printint>
 698:	8b4a                	mv	s6,s2
      state = 0;
 69a:	4981                	li	s3,0
 69c:	bf85                	j	60c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 69e:	008b0913          	addi	s2,s6,8
 6a2:	4681                	li	a3,0
 6a4:	4641                	li	a2,16
 6a6:	000b2583          	lw	a1,0(s6)
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	e12080e7          	jalr	-494(ra) # 4be <printint>
 6b4:	8b4a                	mv	s6,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bf91                	j	60c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6ba:	008b0793          	addi	a5,s6,8
 6be:	f8f43423          	sd	a5,-120(s0)
 6c2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6c6:	03000593          	li	a1,48
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	d6c080e7          	jalr	-660(ra) # 438 <putc>
  putc(fd, 'x');
 6d4:	85ea                	mv	a1,s10
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	d60080e7          	jalr	-672(ra) # 438 <putc>
 6e0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e2:	03c9d793          	srli	a5,s3,0x3c
 6e6:	97de                	add	a5,a5,s7
 6e8:	0007c583          	lbu	a1,0(a5)
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	d4a080e7          	jalr	-694(ra) # 438 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f6:	0992                	slli	s3,s3,0x4
 6f8:	397d                	addiw	s2,s2,-1
 6fa:	fe0914e3          	bnez	s2,6e2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6fe:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 702:	4981                	li	s3,0
 704:	b721                	j	60c <vprintf+0x60>
        s = va_arg(ap, char*);
 706:	008b0993          	addi	s3,s6,8
 70a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 70e:	02090163          	beqz	s2,730 <vprintf+0x184>
        while(*s != 0){
 712:	00094583          	lbu	a1,0(s2)
 716:	c9a1                	beqz	a1,766 <vprintf+0x1ba>
          putc(fd, *s);
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	d1e080e7          	jalr	-738(ra) # 438 <putc>
          s++;
 722:	0905                	addi	s2,s2,1
        while(*s != 0){
 724:	00094583          	lbu	a1,0(s2)
 728:	f9e5                	bnez	a1,718 <vprintf+0x16c>
        s = va_arg(ap, char*);
 72a:	8b4e                	mv	s6,s3
      state = 0;
 72c:	4981                	li	s3,0
 72e:	bdf9                	j	60c <vprintf+0x60>
          s = "(null)";
 730:	00000917          	auipc	s2,0x0
 734:	26090913          	addi	s2,s2,608 # 990 <malloc+0x11a>
        while(*s != 0){
 738:	02800593          	li	a1,40
 73c:	bff1                	j	718 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 73e:	008b0913          	addi	s2,s6,8
 742:	000b4583          	lbu	a1,0(s6)
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	cf0080e7          	jalr	-784(ra) # 438 <putc>
 750:	8b4a                	mv	s6,s2
      state = 0;
 752:	4981                	li	s3,0
 754:	bd65                	j	60c <vprintf+0x60>
        putc(fd, c);
 756:	85d2                	mv	a1,s4
 758:	8556                	mv	a0,s5
 75a:	00000097          	auipc	ra,0x0
 75e:	cde080e7          	jalr	-802(ra) # 438 <putc>
      state = 0;
 762:	4981                	li	s3,0
 764:	b565                	j	60c <vprintf+0x60>
        s = va_arg(ap, char*);
 766:	8b4e                	mv	s6,s3
      state = 0;
 768:	4981                	li	s3,0
 76a:	b54d                	j	60c <vprintf+0x60>
    }
  }
}
 76c:	70e6                	ld	ra,120(sp)
 76e:	7446                	ld	s0,112(sp)
 770:	74a6                	ld	s1,104(sp)
 772:	7906                	ld	s2,96(sp)
 774:	69e6                	ld	s3,88(sp)
 776:	6a46                	ld	s4,80(sp)
 778:	6aa6                	ld	s5,72(sp)
 77a:	6b06                	ld	s6,64(sp)
 77c:	7be2                	ld	s7,56(sp)
 77e:	7c42                	ld	s8,48(sp)
 780:	7ca2                	ld	s9,40(sp)
 782:	7d02                	ld	s10,32(sp)
 784:	6de2                	ld	s11,24(sp)
 786:	6109                	addi	sp,sp,128
 788:	8082                	ret

000000000000078a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 78a:	715d                	addi	sp,sp,-80
 78c:	ec06                	sd	ra,24(sp)
 78e:	e822                	sd	s0,16(sp)
 790:	1000                	addi	s0,sp,32
 792:	e010                	sd	a2,0(s0)
 794:	e414                	sd	a3,8(s0)
 796:	e818                	sd	a4,16(s0)
 798:	ec1c                	sd	a5,24(s0)
 79a:	03043023          	sd	a6,32(s0)
 79e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a6:	8622                	mv	a2,s0
 7a8:	00000097          	auipc	ra,0x0
 7ac:	e04080e7          	jalr	-508(ra) # 5ac <vprintf>
}
 7b0:	60e2                	ld	ra,24(sp)
 7b2:	6442                	ld	s0,16(sp)
 7b4:	6161                	addi	sp,sp,80
 7b6:	8082                	ret

00000000000007b8 <printf>:

void
printf(const char *fmt, ...)
{
 7b8:	711d                	addi	sp,sp,-96
 7ba:	ec06                	sd	ra,24(sp)
 7bc:	e822                	sd	s0,16(sp)
 7be:	1000                	addi	s0,sp,32
 7c0:	e40c                	sd	a1,8(s0)
 7c2:	e810                	sd	a2,16(s0)
 7c4:	ec14                	sd	a3,24(s0)
 7c6:	f018                	sd	a4,32(s0)
 7c8:	f41c                	sd	a5,40(s0)
 7ca:	03043823          	sd	a6,48(s0)
 7ce:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d2:	00840613          	addi	a2,s0,8
 7d6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7da:	85aa                	mv	a1,a0
 7dc:	4505                	li	a0,1
 7de:	00000097          	auipc	ra,0x0
 7e2:	dce080e7          	jalr	-562(ra) # 5ac <vprintf>
}
 7e6:	60e2                	ld	ra,24(sp)
 7e8:	6442                	ld	s0,16(sp)
 7ea:	6125                	addi	sp,sp,96
 7ec:	8082                	ret

00000000000007ee <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ee:	1141                	addi	sp,sp,-16
 7f0:	e422                	sd	s0,8(sp)
 7f2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f8:	00000797          	auipc	a5,0x0
 7fc:	1b87b783          	ld	a5,440(a5) # 9b0 <freep>
 800:	a805                	j	830 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 802:	4618                	lw	a4,8(a2)
 804:	9db9                	addw	a1,a1,a4
 806:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 80a:	6398                	ld	a4,0(a5)
 80c:	6318                	ld	a4,0(a4)
 80e:	fee53823          	sd	a4,-16(a0)
 812:	a091                	j	856 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 814:	ff852703          	lw	a4,-8(a0)
 818:	9e39                	addw	a2,a2,a4
 81a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 81c:	ff053703          	ld	a4,-16(a0)
 820:	e398                	sd	a4,0(a5)
 822:	a099                	j	868 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 824:	6398                	ld	a4,0(a5)
 826:	00e7e463          	bltu	a5,a4,82e <free+0x40>
 82a:	00e6ea63          	bltu	a3,a4,83e <free+0x50>
{
 82e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 830:	fed7fae3          	bgeu	a5,a3,824 <free+0x36>
 834:	6398                	ld	a4,0(a5)
 836:	00e6e463          	bltu	a3,a4,83e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83a:	fee7eae3          	bltu	a5,a4,82e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 83e:	ff852583          	lw	a1,-8(a0)
 842:	6390                	ld	a2,0(a5)
 844:	02059713          	slli	a4,a1,0x20
 848:	9301                	srli	a4,a4,0x20
 84a:	0712                	slli	a4,a4,0x4
 84c:	9736                	add	a4,a4,a3
 84e:	fae60ae3          	beq	a2,a4,802 <free+0x14>
    bp->s.ptr = p->s.ptr;
 852:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 856:	4790                	lw	a2,8(a5)
 858:	02061713          	slli	a4,a2,0x20
 85c:	9301                	srli	a4,a4,0x20
 85e:	0712                	slli	a4,a4,0x4
 860:	973e                	add	a4,a4,a5
 862:	fae689e3          	beq	a3,a4,814 <free+0x26>
  } else
    p->s.ptr = bp;
 866:	e394                	sd	a3,0(a5)
  freep = p;
 868:	00000717          	auipc	a4,0x0
 86c:	14f73423          	sd	a5,328(a4) # 9b0 <freep>
}
 870:	6422                	ld	s0,8(sp)
 872:	0141                	addi	sp,sp,16
 874:	8082                	ret

0000000000000876 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 876:	7139                	addi	sp,sp,-64
 878:	fc06                	sd	ra,56(sp)
 87a:	f822                	sd	s0,48(sp)
 87c:	f426                	sd	s1,40(sp)
 87e:	f04a                	sd	s2,32(sp)
 880:	ec4e                	sd	s3,24(sp)
 882:	e852                	sd	s4,16(sp)
 884:	e456                	sd	s5,8(sp)
 886:	e05a                	sd	s6,0(sp)
 888:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 88a:	02051493          	slli	s1,a0,0x20
 88e:	9081                	srli	s1,s1,0x20
 890:	04bd                	addi	s1,s1,15
 892:	8091                	srli	s1,s1,0x4
 894:	0014899b          	addiw	s3,s1,1
 898:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 89a:	00000517          	auipc	a0,0x0
 89e:	11653503          	ld	a0,278(a0) # 9b0 <freep>
 8a2:	c515                	beqz	a0,8ce <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a6:	4798                	lw	a4,8(a5)
 8a8:	02977f63          	bgeu	a4,s1,8e6 <malloc+0x70>
 8ac:	8a4e                	mv	s4,s3
 8ae:	0009871b          	sext.w	a4,s3
 8b2:	6685                	lui	a3,0x1
 8b4:	00d77363          	bgeu	a4,a3,8ba <malloc+0x44>
 8b8:	6a05                	lui	s4,0x1
 8ba:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8be:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c2:	00000917          	auipc	s2,0x0
 8c6:	0ee90913          	addi	s2,s2,238 # 9b0 <freep>
  if(p == (char*)-1)
 8ca:	5afd                	li	s5,-1
 8cc:	a88d                	j	93e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8ce:	00000797          	auipc	a5,0x0
 8d2:	59a78793          	addi	a5,a5,1434 # e68 <base>
 8d6:	00000717          	auipc	a4,0x0
 8da:	0cf73d23          	sd	a5,218(a4) # 9b0 <freep>
 8de:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e4:	b7e1                	j	8ac <malloc+0x36>
      if(p->s.size == nunits)
 8e6:	02e48b63          	beq	s1,a4,91c <malloc+0xa6>
        p->s.size -= nunits;
 8ea:	4137073b          	subw	a4,a4,s3
 8ee:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f0:	1702                	slli	a4,a4,0x20
 8f2:	9301                	srli	a4,a4,0x20
 8f4:	0712                	slli	a4,a4,0x4
 8f6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8fc:	00000717          	auipc	a4,0x0
 900:	0aa73a23          	sd	a0,180(a4) # 9b0 <freep>
      return (void*)(p + 1);
 904:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 908:	70e2                	ld	ra,56(sp)
 90a:	7442                	ld	s0,48(sp)
 90c:	74a2                	ld	s1,40(sp)
 90e:	7902                	ld	s2,32(sp)
 910:	69e2                	ld	s3,24(sp)
 912:	6a42                	ld	s4,16(sp)
 914:	6aa2                	ld	s5,8(sp)
 916:	6b02                	ld	s6,0(sp)
 918:	6121                	addi	sp,sp,64
 91a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 91c:	6398                	ld	a4,0(a5)
 91e:	e118                	sd	a4,0(a0)
 920:	bff1                	j	8fc <malloc+0x86>
  hp->s.size = nu;
 922:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 926:	0541                	addi	a0,a0,16
 928:	00000097          	auipc	ra,0x0
 92c:	ec6080e7          	jalr	-314(ra) # 7ee <free>
  return freep;
 930:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 934:	d971                	beqz	a0,908 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 936:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 938:	4798                	lw	a4,8(a5)
 93a:	fa9776e3          	bgeu	a4,s1,8e6 <malloc+0x70>
    if(p == freep)
 93e:	00093703          	ld	a4,0(s2)
 942:	853e                	mv	a0,a5
 944:	fef719e3          	bne	a4,a5,936 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 948:	8552                	mv	a0,s4
 94a:	00000097          	auipc	ra,0x0
 94e:	a62080e7          	jalr	-1438(ra) # 3ac <sbrk>
  if(p == (char*)-1)
 952:	fd5518e3          	bne	a0,s5,922 <malloc+0xac>
        return 0;
 956:	4501                	li	a0,0
 958:	bf45                	j	908 <malloc+0x92>
