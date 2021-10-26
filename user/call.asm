
user/_call:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <g>:
#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int g(int x) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  return x+3;
}
   6:	250d                	addiw	a0,a0,3
   8:	6422                	ld	s0,8(sp)
   a:	0141                	addi	sp,sp,16
   c:	8082                	ret

000000000000000e <f>:

int f(int x) {
   e:	1141                	addi	sp,sp,-16
  10:	e422                	sd	s0,8(sp)
  12:	0800                	addi	s0,sp,16
  return g(x);
}
  14:	250d                	addiw	a0,a0,3
  16:	6422                	ld	s0,8(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret

000000000000001c <main>:

void main(void) {
  1c:	1141                	addi	sp,sp,-16
  1e:	e406                	sd	ra,8(sp)
  20:	e022                	sd	s0,0(sp)
  22:	0800                	addi	s0,sp,16
  printf("%d %d\n", f(8)+1, 13);
  24:	4635                	li	a2,13
  26:	45b1                	li	a1,12
  28:	00001517          	auipc	a0,0x1
  2c:	91850513          	addi	a0,a0,-1768 # 940 <malloc+0xe8>
  30:	00000097          	auipc	ra,0x0
  34:	76a080e7          	jalr	1898(ra) # 79a <printf>
  exit(0);
  38:	4501                	li	a0,0
  3a:	00000097          	auipc	ra,0x0
  3e:	2cc080e7          	jalr	716(ra) # 306 <exit>

0000000000000042 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  42:	1141                	addi	sp,sp,-16
  44:	e422                	sd	s0,8(sp)
  46:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  48:	87aa                	mv	a5,a0
  4a:	0585                	addi	a1,a1,1
  4c:	0785                	addi	a5,a5,1
  4e:	fff5c703          	lbu	a4,-1(a1)
  52:	fee78fa3          	sb	a4,-1(a5)
  56:	fb75                	bnez	a4,4a <strcpy+0x8>
    ;
  return os;
}
  58:	6422                	ld	s0,8(sp)
  5a:	0141                	addi	sp,sp,16
  5c:	8082                	ret

000000000000005e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  5e:	1141                	addi	sp,sp,-16
  60:	e422                	sd	s0,8(sp)
  62:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  64:	00054783          	lbu	a5,0(a0)
  68:	cb91                	beqz	a5,7c <strcmp+0x1e>
  6a:	0005c703          	lbu	a4,0(a1)
  6e:	00f71763          	bne	a4,a5,7c <strcmp+0x1e>
    p++, q++;
  72:	0505                	addi	a0,a0,1
  74:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  76:	00054783          	lbu	a5,0(a0)
  7a:	fbe5                	bnez	a5,6a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  7c:	0005c503          	lbu	a0,0(a1)
}
  80:	40a7853b          	subw	a0,a5,a0
  84:	6422                	ld	s0,8(sp)
  86:	0141                	addi	sp,sp,16
  88:	8082                	ret

000000000000008a <strlen>:

uint
strlen(const char *s)
{
  8a:	1141                	addi	sp,sp,-16
  8c:	e422                	sd	s0,8(sp)
  8e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  90:	00054783          	lbu	a5,0(a0)
  94:	cf91                	beqz	a5,b0 <strlen+0x26>
  96:	0505                	addi	a0,a0,1
  98:	87aa                	mv	a5,a0
  9a:	4685                	li	a3,1
  9c:	9e89                	subw	a3,a3,a0
  9e:	00f6853b          	addw	a0,a3,a5
  a2:	0785                	addi	a5,a5,1
  a4:	fff7c703          	lbu	a4,-1(a5)
  a8:	fb7d                	bnez	a4,9e <strlen+0x14>
    ;
  return n;
}
  aa:	6422                	ld	s0,8(sp)
  ac:	0141                	addi	sp,sp,16
  ae:	8082                	ret
  for(n = 0; s[n]; n++)
  b0:	4501                	li	a0,0
  b2:	bfe5                	j	aa <strlen+0x20>

00000000000000b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e422                	sd	s0,8(sp)
  b8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ba:	ce09                	beqz	a2,d4 <memset+0x20>
  bc:	87aa                	mv	a5,a0
  be:	fff6071b          	addiw	a4,a2,-1
  c2:	1702                	slli	a4,a4,0x20
  c4:	9301                	srli	a4,a4,0x20
  c6:	0705                	addi	a4,a4,1
  c8:	972a                	add	a4,a4,a0
    cdst[i] = c;
  ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ce:	0785                	addi	a5,a5,1
  d0:	fee79de3          	bne	a5,a4,ca <memset+0x16>
  }
  return dst;
}
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret

00000000000000da <strchr>:

char*
strchr(const char *s, char c)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	cb99                	beqz	a5,fa <strchr+0x20>
    if(*s == c)
  e6:	00f58763          	beq	a1,a5,f4 <strchr+0x1a>
  for(; *s; s++)
  ea:	0505                	addi	a0,a0,1
  ec:	00054783          	lbu	a5,0(a0)
  f0:	fbfd                	bnez	a5,e6 <strchr+0xc>
      return (char*)s;
  return 0;
  f2:	4501                	li	a0,0
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret
  return 0;
  fa:	4501                	li	a0,0
  fc:	bfe5                	j	f4 <strchr+0x1a>

00000000000000fe <gets>:

char*
gets(char *buf, int max)
{
  fe:	711d                	addi	sp,sp,-96
 100:	ec86                	sd	ra,88(sp)
 102:	e8a2                	sd	s0,80(sp)
 104:	e4a6                	sd	s1,72(sp)
 106:	e0ca                	sd	s2,64(sp)
 108:	fc4e                	sd	s3,56(sp)
 10a:	f852                	sd	s4,48(sp)
 10c:	f456                	sd	s5,40(sp)
 10e:	f05a                	sd	s6,32(sp)
 110:	ec5e                	sd	s7,24(sp)
 112:	1080                	addi	s0,sp,96
 114:	8baa                	mv	s7,a0
 116:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 118:	892a                	mv	s2,a0
 11a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11c:	4aa9                	li	s5,10
 11e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 120:	89a6                	mv	s3,s1
 122:	2485                	addiw	s1,s1,1
 124:	0344d863          	bge	s1,s4,154 <gets+0x56>
    cc = read(0, &c, 1);
 128:	4605                	li	a2,1
 12a:	faf40593          	addi	a1,s0,-81
 12e:	4501                	li	a0,0
 130:	00000097          	auipc	ra,0x0
 134:	1ee080e7          	jalr	494(ra) # 31e <read>
    if(cc < 1)
 138:	00a05e63          	blez	a0,154 <gets+0x56>
    buf[i++] = c;
 13c:	faf44783          	lbu	a5,-81(s0)
 140:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 144:	01578763          	beq	a5,s5,152 <gets+0x54>
 148:	0905                	addi	s2,s2,1
 14a:	fd679be3          	bne	a5,s6,120 <gets+0x22>
  for(i=0; i+1 < max; ){
 14e:	89a6                	mv	s3,s1
 150:	a011                	j	154 <gets+0x56>
 152:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 154:	99de                	add	s3,s3,s7
 156:	00098023          	sb	zero,0(s3)
  return buf;
}
 15a:	855e                	mv	a0,s7
 15c:	60e6                	ld	ra,88(sp)
 15e:	6446                	ld	s0,80(sp)
 160:	64a6                	ld	s1,72(sp)
 162:	6906                	ld	s2,64(sp)
 164:	79e2                	ld	s3,56(sp)
 166:	7a42                	ld	s4,48(sp)
 168:	7aa2                	ld	s5,40(sp)
 16a:	7b02                	ld	s6,32(sp)
 16c:	6be2                	ld	s7,24(sp)
 16e:	6125                	addi	sp,sp,96
 170:	8082                	ret

0000000000000172 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 178:	00054603          	lbu	a2,0(a0)
 17c:	fd06079b          	addiw	a5,a2,-48
 180:	0ff7f793          	andi	a5,a5,255
 184:	4725                	li	a4,9
 186:	02f76963          	bltu	a4,a5,1b8 <atoi+0x46>
 18a:	86aa                	mv	a3,a0
  n = 0;
 18c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 18e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 190:	0685                	addi	a3,a3,1
 192:	0025179b          	slliw	a5,a0,0x2
 196:	9fa9                	addw	a5,a5,a0
 198:	0017979b          	slliw	a5,a5,0x1
 19c:	9fb1                	addw	a5,a5,a2
 19e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1a2:	0006c603          	lbu	a2,0(a3)
 1a6:	fd06071b          	addiw	a4,a2,-48
 1aa:	0ff77713          	andi	a4,a4,255
 1ae:	fee5f1e3          	bgeu	a1,a4,190 <atoi+0x1e>
  return n;
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret
  n = 0;
 1b8:	4501                	li	a0,0
 1ba:	bfe5                	j	1b2 <atoi+0x40>

00000000000001bc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1c2:	02b57663          	bgeu	a0,a1,1ee <memmove+0x32>
    while(n-- > 0)
 1c6:	02c05163          	blez	a2,1e8 <memmove+0x2c>
 1ca:	fff6079b          	addiw	a5,a2,-1
 1ce:	1782                	slli	a5,a5,0x20
 1d0:	9381                	srli	a5,a5,0x20
 1d2:	0785                	addi	a5,a5,1
 1d4:	97aa                	add	a5,a5,a0
  dst = vdst;
 1d6:	872a                	mv	a4,a0
      *dst++ = *src++;
 1d8:	0585                	addi	a1,a1,1
 1da:	0705                	addi	a4,a4,1
 1dc:	fff5c683          	lbu	a3,-1(a1)
 1e0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1e4:	fee79ae3          	bne	a5,a4,1d8 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret
    dst += n;
 1ee:	00c50733          	add	a4,a0,a2
    src += n;
 1f2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 1f4:	fec05ae3          	blez	a2,1e8 <memmove+0x2c>
 1f8:	fff6079b          	addiw	a5,a2,-1
 1fc:	1782                	slli	a5,a5,0x20
 1fe:	9381                	srli	a5,a5,0x20
 200:	fff7c793          	not	a5,a5
 204:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 206:	15fd                	addi	a1,a1,-1
 208:	177d                	addi	a4,a4,-1
 20a:	0005c683          	lbu	a3,0(a1)
 20e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 212:	fee79ae3          	bne	a5,a4,206 <memmove+0x4a>
 216:	bfc9                	j	1e8 <memmove+0x2c>

0000000000000218 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 21e:	ca05                	beqz	a2,24e <memcmp+0x36>
 220:	fff6069b          	addiw	a3,a2,-1
 224:	1682                	slli	a3,a3,0x20
 226:	9281                	srli	a3,a3,0x20
 228:	0685                	addi	a3,a3,1
 22a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 22c:	00054783          	lbu	a5,0(a0)
 230:	0005c703          	lbu	a4,0(a1)
 234:	00e79863          	bne	a5,a4,244 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 238:	0505                	addi	a0,a0,1
    p2++;
 23a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 23c:	fed518e3          	bne	a0,a3,22c <memcmp+0x14>
  }
  return 0;
 240:	4501                	li	a0,0
 242:	a019                	j	248 <memcmp+0x30>
      return *p1 - *p2;
 244:	40e7853b          	subw	a0,a5,a4
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
  return 0;
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <memcmp+0x30>

0000000000000252 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 252:	1141                	addi	sp,sp,-16
 254:	e406                	sd	ra,8(sp)
 256:	e022                	sd	s0,0(sp)
 258:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 25a:	00000097          	auipc	ra,0x0
 25e:	f62080e7          	jalr	-158(ra) # 1bc <memmove>
}
 262:	60a2                	ld	ra,8(sp)
 264:	6402                	ld	s0,0(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret

000000000000026a <close>:

int close(int fd){
 26a:	1101                	addi	sp,sp,-32
 26c:	ec06                	sd	ra,24(sp)
 26e:	e822                	sd	s0,16(sp)
 270:	e426                	sd	s1,8(sp)
 272:	1000                	addi	s0,sp,32
 274:	84aa                	mv	s1,a0
  fflush(fd);
 276:	00000097          	auipc	ra,0x0
 27a:	2d4080e7          	jalr	724(ra) # 54a <fflush>
  char* buf = get_putc_buf(fd);
 27e:	8526                	mv	a0,s1
 280:	00000097          	auipc	ra,0x0
 284:	14e080e7          	jalr	334(ra) # 3ce <get_putc_buf>
  if(buf){
 288:	cd11                	beqz	a0,2a4 <close+0x3a>
    free(buf);
 28a:	00000097          	auipc	ra,0x0
 28e:	546080e7          	jalr	1350(ra) # 7d0 <free>
    putc_buf[fd] = 0;
 292:	00349713          	slli	a4,s1,0x3
 296:	00000797          	auipc	a5,0x0
 29a:	6da78793          	addi	a5,a5,1754 # 970 <putc_buf>
 29e:	97ba                	add	a5,a5,a4
 2a0:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 2a4:	8526                	mv	a0,s1
 2a6:	00000097          	auipc	ra,0x0
 2aa:	088080e7          	jalr	136(ra) # 32e <sclose>
}
 2ae:	60e2                	ld	ra,24(sp)
 2b0:	6442                	ld	s0,16(sp)
 2b2:	64a2                	ld	s1,8(sp)
 2b4:	6105                	addi	sp,sp,32
 2b6:	8082                	ret

00000000000002b8 <stat>:
{
 2b8:	1101                	addi	sp,sp,-32
 2ba:	ec06                	sd	ra,24(sp)
 2bc:	e822                	sd	s0,16(sp)
 2be:	e426                	sd	s1,8(sp)
 2c0:	e04a                	sd	s2,0(sp)
 2c2:	1000                	addi	s0,sp,32
 2c4:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 2c6:	4581                	li	a1,0
 2c8:	00000097          	auipc	ra,0x0
 2cc:	07e080e7          	jalr	126(ra) # 346 <open>
  if(fd < 0)
 2d0:	02054563          	bltz	a0,2fa <stat+0x42>
 2d4:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 2d6:	85ca                	mv	a1,s2
 2d8:	00000097          	auipc	ra,0x0
 2dc:	086080e7          	jalr	134(ra) # 35e <fstat>
 2e0:	892a                	mv	s2,a0
  close(fd);
 2e2:	8526                	mv	a0,s1
 2e4:	00000097          	auipc	ra,0x0
 2e8:	f86080e7          	jalr	-122(ra) # 26a <close>
}
 2ec:	854a                	mv	a0,s2
 2ee:	60e2                	ld	ra,24(sp)
 2f0:	6442                	ld	s0,16(sp)
 2f2:	64a2                	ld	s1,8(sp)
 2f4:	6902                	ld	s2,0(sp)
 2f6:	6105                	addi	sp,sp,32
 2f8:	8082                	ret
    return -1;
 2fa:	597d                	li	s2,-1
 2fc:	bfc5                	j	2ec <stat+0x34>

00000000000002fe <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2fe:	4885                	li	a7,1
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <exit>:
.global exit
exit:
 li a7, SYS_exit
 306:	4889                	li	a7,2
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <wait>:
.global wait
wait:
 li a7, SYS_wait
 30e:	488d                	li	a7,3
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 316:	4891                	li	a7,4
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <read>:
.global read
read:
 li a7, SYS_read
 31e:	4895                	li	a7,5
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <write>:
.global write
write:
 li a7, SYS_write
 326:	48c1                	li	a7,16
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 32e:	48d5                	li	a7,21
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <kill>:
.global kill
kill:
 li a7, SYS_kill
 336:	4899                	li	a7,6
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <exec>:
.global exec
exec:
 li a7, SYS_exec
 33e:	489d                	li	a7,7
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <open>:
.global open
open:
 li a7, SYS_open
 346:	48bd                	li	a7,15
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 34e:	48c5                	li	a7,17
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 356:	48c9                	li	a7,18
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 35e:	48a1                	li	a7,8
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <link>:
.global link
link:
 li a7, SYS_link
 366:	48cd                	li	a7,19
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 36e:	48d1                	li	a7,20
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 376:	48a5                	li	a7,9
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <dup>:
.global dup
dup:
 li a7, SYS_dup
 37e:	48a9                	li	a7,10
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 386:	48ad                	li	a7,11
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 38e:	48b1                	li	a7,12
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 396:	48b5                	li	a7,13
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 39e:	48b9                	li	a7,14
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 3a6:	48d9                	li	a7,22
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <nice>:
.global nice
nice:
 li a7, SYS_nice
 3ae:	48dd                	li	a7,23
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 3b6:	48e1                	li	a7,24
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 3be:	48e5                	li	a7,25
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 3c6:	48e9                	li	a7,26
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 3ce:	1101                	addi	sp,sp,-32
 3d0:	ec06                	sd	ra,24(sp)
 3d2:	e822                	sd	s0,16(sp)
 3d4:	e426                	sd	s1,8(sp)
 3d6:	1000                	addi	s0,sp,32
 3d8:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 3da:	00351713          	slli	a4,a0,0x3
 3de:	00000797          	auipc	a5,0x0
 3e2:	59278793          	addi	a5,a5,1426 # 970 <putc_buf>
 3e6:	97ba                	add	a5,a5,a4
 3e8:	6388                	ld	a0,0(a5)
  if(buf) {
 3ea:	c511                	beqz	a0,3f6 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 3ec:	60e2                	ld	ra,24(sp)
 3ee:	6442                	ld	s0,16(sp)
 3f0:	64a2                	ld	s1,8(sp)
 3f2:	6105                	addi	sp,sp,32
 3f4:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 3f6:	6505                	lui	a0,0x1
 3f8:	00000097          	auipc	ra,0x0
 3fc:	460080e7          	jalr	1120(ra) # 858 <malloc>
  putc_buf[fd] = buf;
 400:	00000797          	auipc	a5,0x0
 404:	57078793          	addi	a5,a5,1392 # 970 <putc_buf>
 408:	00349713          	slli	a4,s1,0x3
 40c:	973e                	add	a4,a4,a5
 40e:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 410:	048a                	slli	s1,s1,0x2
 412:	94be                	add	s1,s1,a5
 414:	3204a023          	sw	zero,800(s1)
  return buf;
 418:	bfd1                	j	3ec <get_putc_buf+0x1e>

000000000000041a <putc>:

static void
putc(int fd, char c)
{
 41a:	1101                	addi	sp,sp,-32
 41c:	ec06                	sd	ra,24(sp)
 41e:	e822                	sd	s0,16(sp)
 420:	e426                	sd	s1,8(sp)
 422:	e04a                	sd	s2,0(sp)
 424:	1000                	addi	s0,sp,32
 426:	84aa                	mv	s1,a0
 428:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 42a:	00000097          	auipc	ra,0x0
 42e:	fa4080e7          	jalr	-92(ra) # 3ce <get_putc_buf>
  buf[putc_index[fd]++] = c;
 432:	00249793          	slli	a5,s1,0x2
 436:	00000717          	auipc	a4,0x0
 43a:	53a70713          	addi	a4,a4,1338 # 970 <putc_buf>
 43e:	973e                	add	a4,a4,a5
 440:	32072783          	lw	a5,800(a4)
 444:	0017869b          	addiw	a3,a5,1
 448:	32d72023          	sw	a3,800(a4)
 44c:	97aa                	add	a5,a5,a0
 44e:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 452:	47a9                	li	a5,10
 454:	02f90463          	beq	s2,a5,47c <putc+0x62>
 458:	00249713          	slli	a4,s1,0x2
 45c:	00000797          	auipc	a5,0x0
 460:	51478793          	addi	a5,a5,1300 # 970 <putc_buf>
 464:	97ba                	add	a5,a5,a4
 466:	3207a703          	lw	a4,800(a5)
 46a:	6785                	lui	a5,0x1
 46c:	00f70863          	beq	a4,a5,47c <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 470:	60e2                	ld	ra,24(sp)
 472:	6442                	ld	s0,16(sp)
 474:	64a2                	ld	s1,8(sp)
 476:	6902                	ld	s2,0(sp)
 478:	6105                	addi	sp,sp,32
 47a:	8082                	ret
    write(fd, buf, putc_index[fd]);
 47c:	00249793          	slli	a5,s1,0x2
 480:	00000917          	auipc	s2,0x0
 484:	4f090913          	addi	s2,s2,1264 # 970 <putc_buf>
 488:	993e                	add	s2,s2,a5
 48a:	32092603          	lw	a2,800(s2)
 48e:	85aa                	mv	a1,a0
 490:	8526                	mv	a0,s1
 492:	00000097          	auipc	ra,0x0
 496:	e94080e7          	jalr	-364(ra) # 326 <write>
    putc_index[fd] = 0;
 49a:	32092023          	sw	zero,800(s2)
}
 49e:	bfc9                	j	470 <putc+0x56>

00000000000004a0 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4a0:	7139                	addi	sp,sp,-64
 4a2:	fc06                	sd	ra,56(sp)
 4a4:	f822                	sd	s0,48(sp)
 4a6:	f426                	sd	s1,40(sp)
 4a8:	f04a                	sd	s2,32(sp)
 4aa:	ec4e                	sd	s3,24(sp)
 4ac:	0080                	addi	s0,sp,64
 4ae:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b0:	c299                	beqz	a3,4b6 <printint+0x16>
 4b2:	0805c863          	bltz	a1,542 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b6:	2581                	sext.w	a1,a1
  neg = 0;
 4b8:	4881                	li	a7,0
 4ba:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4be:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c0:	2601                	sext.w	a2,a2
 4c2:	00000517          	auipc	a0,0x0
 4c6:	48e50513          	addi	a0,a0,1166 # 950 <digits>
 4ca:	883a                	mv	a6,a4
 4cc:	2705                	addiw	a4,a4,1
 4ce:	02c5f7bb          	remuw	a5,a1,a2
 4d2:	1782                	slli	a5,a5,0x20
 4d4:	9381                	srli	a5,a5,0x20
 4d6:	97aa                	add	a5,a5,a0
 4d8:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x1d0>
 4dc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e0:	0005879b          	sext.w	a5,a1
 4e4:	02c5d5bb          	divuw	a1,a1,a2
 4e8:	0685                	addi	a3,a3,1
 4ea:	fec7f0e3          	bgeu	a5,a2,4ca <printint+0x2a>
  if(neg)
 4ee:	00088b63          	beqz	a7,504 <printint+0x64>
    buf[i++] = '-';
 4f2:	fd040793          	addi	a5,s0,-48
 4f6:	973e                	add	a4,a4,a5
 4f8:	02d00793          	li	a5,45
 4fc:	fef70823          	sb	a5,-16(a4)
 500:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 504:	02e05863          	blez	a4,534 <printint+0x94>
 508:	fc040793          	addi	a5,s0,-64
 50c:	00e78933          	add	s2,a5,a4
 510:	fff78993          	addi	s3,a5,-1
 514:	99ba                	add	s3,s3,a4
 516:	377d                	addiw	a4,a4,-1
 518:	1702                	slli	a4,a4,0x20
 51a:	9301                	srli	a4,a4,0x20
 51c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 520:	fff94583          	lbu	a1,-1(s2)
 524:	8526                	mv	a0,s1
 526:	00000097          	auipc	ra,0x0
 52a:	ef4080e7          	jalr	-268(ra) # 41a <putc>
  while(--i >= 0)
 52e:	197d                	addi	s2,s2,-1
 530:	ff3918e3          	bne	s2,s3,520 <printint+0x80>
}
 534:	70e2                	ld	ra,56(sp)
 536:	7442                	ld	s0,48(sp)
 538:	74a2                	ld	s1,40(sp)
 53a:	7902                	ld	s2,32(sp)
 53c:	69e2                	ld	s3,24(sp)
 53e:	6121                	addi	sp,sp,64
 540:	8082                	ret
    x = -xx;
 542:	40b005bb          	negw	a1,a1
    neg = 1;
 546:	4885                	li	a7,1
    x = -xx;
 548:	bf8d                	j	4ba <printint+0x1a>

000000000000054a <fflush>:
void fflush(int fd){
 54a:	1101                	addi	sp,sp,-32
 54c:	ec06                	sd	ra,24(sp)
 54e:	e822                	sd	s0,16(sp)
 550:	e426                	sd	s1,8(sp)
 552:	e04a                	sd	s2,0(sp)
 554:	1000                	addi	s0,sp,32
 556:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 558:	00000097          	auipc	ra,0x0
 55c:	e76080e7          	jalr	-394(ra) # 3ce <get_putc_buf>
 560:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 562:	00291793          	slli	a5,s2,0x2
 566:	00000497          	auipc	s1,0x0
 56a:	40a48493          	addi	s1,s1,1034 # 970 <putc_buf>
 56e:	94be                	add	s1,s1,a5
 570:	3204a603          	lw	a2,800(s1)
 574:	854a                	mv	a0,s2
 576:	00000097          	auipc	ra,0x0
 57a:	db0080e7          	jalr	-592(ra) # 326 <write>
  putc_index[fd] = 0;
 57e:	3204a023          	sw	zero,800(s1)
}
 582:	60e2                	ld	ra,24(sp)
 584:	6442                	ld	s0,16(sp)
 586:	64a2                	ld	s1,8(sp)
 588:	6902                	ld	s2,0(sp)
 58a:	6105                	addi	sp,sp,32
 58c:	8082                	ret

000000000000058e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 58e:	7119                	addi	sp,sp,-128
 590:	fc86                	sd	ra,120(sp)
 592:	f8a2                	sd	s0,112(sp)
 594:	f4a6                	sd	s1,104(sp)
 596:	f0ca                	sd	s2,96(sp)
 598:	ecce                	sd	s3,88(sp)
 59a:	e8d2                	sd	s4,80(sp)
 59c:	e4d6                	sd	s5,72(sp)
 59e:	e0da                	sd	s6,64(sp)
 5a0:	fc5e                	sd	s7,56(sp)
 5a2:	f862                	sd	s8,48(sp)
 5a4:	f466                	sd	s9,40(sp)
 5a6:	f06a                	sd	s10,32(sp)
 5a8:	ec6e                	sd	s11,24(sp)
 5aa:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ac:	0005c903          	lbu	s2,0(a1)
 5b0:	18090f63          	beqz	s2,74e <vprintf+0x1c0>
 5b4:	8aaa                	mv	s5,a0
 5b6:	8b32                	mv	s6,a2
 5b8:	00158493          	addi	s1,a1,1
  state = 0;
 5bc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5be:	02500a13          	li	s4,37
      if(c == 'd'){
 5c2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5c6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5ca:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5ce:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d2:	00000b97          	auipc	s7,0x0
 5d6:	37eb8b93          	addi	s7,s7,894 # 950 <digits>
 5da:	a839                	j	5f8 <vprintf+0x6a>
        putc(fd, c);
 5dc:	85ca                	mv	a1,s2
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	e3a080e7          	jalr	-454(ra) # 41a <putc>
 5e8:	a019                	j	5ee <vprintf+0x60>
    } else if(state == '%'){
 5ea:	01498f63          	beq	s3,s4,608 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5ee:	0485                	addi	s1,s1,1
 5f0:	fff4c903          	lbu	s2,-1(s1)
 5f4:	14090d63          	beqz	s2,74e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5f8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5fc:	fe0997e3          	bnez	s3,5ea <vprintf+0x5c>
      if(c == '%'){
 600:	fd479ee3          	bne	a5,s4,5dc <vprintf+0x4e>
        state = '%';
 604:	89be                	mv	s3,a5
 606:	b7e5                	j	5ee <vprintf+0x60>
      if(c == 'd'){
 608:	05878063          	beq	a5,s8,648 <vprintf+0xba>
      } else if(c == 'l') {
 60c:	05978c63          	beq	a5,s9,664 <vprintf+0xd6>
      } else if(c == 'x') {
 610:	07a78863          	beq	a5,s10,680 <vprintf+0xf2>
      } else if(c == 'p') {
 614:	09b78463          	beq	a5,s11,69c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 618:	07300713          	li	a4,115
 61c:	0ce78663          	beq	a5,a4,6e8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 620:	06300713          	li	a4,99
 624:	0ee78e63          	beq	a5,a4,720 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 628:	11478863          	beq	a5,s4,738 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 62c:	85d2                	mv	a1,s4
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	dea080e7          	jalr	-534(ra) # 41a <putc>
        putc(fd, c);
 638:	85ca                	mv	a1,s2
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	dde080e7          	jalr	-546(ra) # 41a <putc>
      }
      state = 0;
 644:	4981                	li	s3,0
 646:	b765                	j	5ee <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 648:	008b0913          	addi	s2,s6,8
 64c:	4685                	li	a3,1
 64e:	4629                	li	a2,10
 650:	000b2583          	lw	a1,0(s6)
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e4a080e7          	jalr	-438(ra) # 4a0 <printint>
 65e:	8b4a                	mv	s6,s2
      state = 0;
 660:	4981                	li	s3,0
 662:	b771                	j	5ee <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 664:	008b0913          	addi	s2,s6,8
 668:	4681                	li	a3,0
 66a:	4629                	li	a2,10
 66c:	000b2583          	lw	a1,0(s6)
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e2e080e7          	jalr	-466(ra) # 4a0 <printint>
 67a:	8b4a                	mv	s6,s2
      state = 0;
 67c:	4981                	li	s3,0
 67e:	bf85                	j	5ee <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 680:	008b0913          	addi	s2,s6,8
 684:	4681                	li	a3,0
 686:	4641                	li	a2,16
 688:	000b2583          	lw	a1,0(s6)
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	e12080e7          	jalr	-494(ra) # 4a0 <printint>
 696:	8b4a                	mv	s6,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	bf91                	j	5ee <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 69c:	008b0793          	addi	a5,s6,8
 6a0:	f8f43423          	sd	a5,-120(s0)
 6a4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6a8:	03000593          	li	a1,48
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	d6c080e7          	jalr	-660(ra) # 41a <putc>
  putc(fd, 'x');
 6b6:	85ea                	mv	a1,s10
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	d60080e7          	jalr	-672(ra) # 41a <putc>
 6c2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c4:	03c9d793          	srli	a5,s3,0x3c
 6c8:	97de                	add	a5,a5,s7
 6ca:	0007c583          	lbu	a1,0(a5)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	d4a080e7          	jalr	-694(ra) # 41a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6d8:	0992                	slli	s3,s3,0x4
 6da:	397d                	addiw	s2,s2,-1
 6dc:	fe0914e3          	bnez	s2,6c4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6e0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b721                	j	5ee <vprintf+0x60>
        s = va_arg(ap, char*);
 6e8:	008b0993          	addi	s3,s6,8
 6ec:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6f0:	02090163          	beqz	s2,712 <vprintf+0x184>
        while(*s != 0){
 6f4:	00094583          	lbu	a1,0(s2)
 6f8:	c9a1                	beqz	a1,748 <vprintf+0x1ba>
          putc(fd, *s);
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	d1e080e7          	jalr	-738(ra) # 41a <putc>
          s++;
 704:	0905                	addi	s2,s2,1
        while(*s != 0){
 706:	00094583          	lbu	a1,0(s2)
 70a:	f9e5                	bnez	a1,6fa <vprintf+0x16c>
        s = va_arg(ap, char*);
 70c:	8b4e                	mv	s6,s3
      state = 0;
 70e:	4981                	li	s3,0
 710:	bdf9                	j	5ee <vprintf+0x60>
          s = "(null)";
 712:	00000917          	auipc	s2,0x0
 716:	23690913          	addi	s2,s2,566 # 948 <malloc+0xf0>
        while(*s != 0){
 71a:	02800593          	li	a1,40
 71e:	bff1                	j	6fa <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 720:	008b0913          	addi	s2,s6,8
 724:	000b4583          	lbu	a1,0(s6)
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	cf0080e7          	jalr	-784(ra) # 41a <putc>
 732:	8b4a                	mv	s6,s2
      state = 0;
 734:	4981                	li	s3,0
 736:	bd65                	j	5ee <vprintf+0x60>
        putc(fd, c);
 738:	85d2                	mv	a1,s4
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	cde080e7          	jalr	-802(ra) # 41a <putc>
      state = 0;
 744:	4981                	li	s3,0
 746:	b565                	j	5ee <vprintf+0x60>
        s = va_arg(ap, char*);
 748:	8b4e                	mv	s6,s3
      state = 0;
 74a:	4981                	li	s3,0
 74c:	b54d                	j	5ee <vprintf+0x60>
    }
  }
}
 74e:	70e6                	ld	ra,120(sp)
 750:	7446                	ld	s0,112(sp)
 752:	74a6                	ld	s1,104(sp)
 754:	7906                	ld	s2,96(sp)
 756:	69e6                	ld	s3,88(sp)
 758:	6a46                	ld	s4,80(sp)
 75a:	6aa6                	ld	s5,72(sp)
 75c:	6b06                	ld	s6,64(sp)
 75e:	7be2                	ld	s7,56(sp)
 760:	7c42                	ld	s8,48(sp)
 762:	7ca2                	ld	s9,40(sp)
 764:	7d02                	ld	s10,32(sp)
 766:	6de2                	ld	s11,24(sp)
 768:	6109                	addi	sp,sp,128
 76a:	8082                	ret

000000000000076c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76c:	715d                	addi	sp,sp,-80
 76e:	ec06                	sd	ra,24(sp)
 770:	e822                	sd	s0,16(sp)
 772:	1000                	addi	s0,sp,32
 774:	e010                	sd	a2,0(s0)
 776:	e414                	sd	a3,8(s0)
 778:	e818                	sd	a4,16(s0)
 77a:	ec1c                	sd	a5,24(s0)
 77c:	03043023          	sd	a6,32(s0)
 780:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 784:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 788:	8622                	mv	a2,s0
 78a:	00000097          	auipc	ra,0x0
 78e:	e04080e7          	jalr	-508(ra) # 58e <vprintf>
}
 792:	60e2                	ld	ra,24(sp)
 794:	6442                	ld	s0,16(sp)
 796:	6161                	addi	sp,sp,80
 798:	8082                	ret

000000000000079a <printf>:

void
printf(const char *fmt, ...)
{
 79a:	711d                	addi	sp,sp,-96
 79c:	ec06                	sd	ra,24(sp)
 79e:	e822                	sd	s0,16(sp)
 7a0:	1000                	addi	s0,sp,32
 7a2:	e40c                	sd	a1,8(s0)
 7a4:	e810                	sd	a2,16(s0)
 7a6:	ec14                	sd	a3,24(s0)
 7a8:	f018                	sd	a4,32(s0)
 7aa:	f41c                	sd	a5,40(s0)
 7ac:	03043823          	sd	a6,48(s0)
 7b0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b4:	00840613          	addi	a2,s0,8
 7b8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7bc:	85aa                	mv	a1,a0
 7be:	4505                	li	a0,1
 7c0:	00000097          	auipc	ra,0x0
 7c4:	dce080e7          	jalr	-562(ra) # 58e <vprintf>
}
 7c8:	60e2                	ld	ra,24(sp)
 7ca:	6442                	ld	s0,16(sp)
 7cc:	6125                	addi	sp,sp,96
 7ce:	8082                	ret

00000000000007d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d0:	1141                	addi	sp,sp,-16
 7d2:	e422                	sd	s0,8(sp)
 7d4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7da:	00000797          	auipc	a5,0x0
 7de:	18e7b783          	ld	a5,398(a5) # 968 <freep>
 7e2:	a805                	j	812 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e4:	4618                	lw	a4,8(a2)
 7e6:	9db9                	addw	a1,a1,a4
 7e8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ec:	6398                	ld	a4,0(a5)
 7ee:	6318                	ld	a4,0(a4)
 7f0:	fee53823          	sd	a4,-16(a0)
 7f4:	a091                	j	838 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f6:	ff852703          	lw	a4,-8(a0)
 7fa:	9e39                	addw	a2,a2,a4
 7fc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7fe:	ff053703          	ld	a4,-16(a0)
 802:	e398                	sd	a4,0(a5)
 804:	a099                	j	84a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 806:	6398                	ld	a4,0(a5)
 808:	00e7e463          	bltu	a5,a4,810 <free+0x40>
 80c:	00e6ea63          	bltu	a3,a4,820 <free+0x50>
{
 810:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 812:	fed7fae3          	bgeu	a5,a3,806 <free+0x36>
 816:	6398                	ld	a4,0(a5)
 818:	00e6e463          	bltu	a3,a4,820 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	fee7eae3          	bltu	a5,a4,810 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 820:	ff852583          	lw	a1,-8(a0)
 824:	6390                	ld	a2,0(a5)
 826:	02059713          	slli	a4,a1,0x20
 82a:	9301                	srli	a4,a4,0x20
 82c:	0712                	slli	a4,a4,0x4
 82e:	9736                	add	a4,a4,a3
 830:	fae60ae3          	beq	a2,a4,7e4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 834:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 838:	4790                	lw	a2,8(a5)
 83a:	02061713          	slli	a4,a2,0x20
 83e:	9301                	srli	a4,a4,0x20
 840:	0712                	slli	a4,a4,0x4
 842:	973e                	add	a4,a4,a5
 844:	fae689e3          	beq	a3,a4,7f6 <free+0x26>
  } else
    p->s.ptr = bp;
 848:	e394                	sd	a3,0(a5)
  freep = p;
 84a:	00000717          	auipc	a4,0x0
 84e:	10f73f23          	sd	a5,286(a4) # 968 <freep>
}
 852:	6422                	ld	s0,8(sp)
 854:	0141                	addi	sp,sp,16
 856:	8082                	ret

0000000000000858 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 858:	7139                	addi	sp,sp,-64
 85a:	fc06                	sd	ra,56(sp)
 85c:	f822                	sd	s0,48(sp)
 85e:	f426                	sd	s1,40(sp)
 860:	f04a                	sd	s2,32(sp)
 862:	ec4e                	sd	s3,24(sp)
 864:	e852                	sd	s4,16(sp)
 866:	e456                	sd	s5,8(sp)
 868:	e05a                	sd	s6,0(sp)
 86a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 86c:	02051493          	slli	s1,a0,0x20
 870:	9081                	srli	s1,s1,0x20
 872:	04bd                	addi	s1,s1,15
 874:	8091                	srli	s1,s1,0x4
 876:	0014899b          	addiw	s3,s1,1
 87a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 87c:	00000517          	auipc	a0,0x0
 880:	0ec53503          	ld	a0,236(a0) # 968 <freep>
 884:	c515                	beqz	a0,8b0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 886:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 888:	4798                	lw	a4,8(a5)
 88a:	02977f63          	bgeu	a4,s1,8c8 <malloc+0x70>
 88e:	8a4e                	mv	s4,s3
 890:	0009871b          	sext.w	a4,s3
 894:	6685                	lui	a3,0x1
 896:	00d77363          	bgeu	a4,a3,89c <malloc+0x44>
 89a:	6a05                	lui	s4,0x1
 89c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a4:	00000917          	auipc	s2,0x0
 8a8:	0c490913          	addi	s2,s2,196 # 968 <freep>
  if(p == (char*)-1)
 8ac:	5afd                	li	s5,-1
 8ae:	a88d                	j	920 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8b0:	00000797          	auipc	a5,0x0
 8b4:	57078793          	addi	a5,a5,1392 # e20 <base>
 8b8:	00000717          	auipc	a4,0x0
 8bc:	0af73823          	sd	a5,176(a4) # 968 <freep>
 8c0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c6:	b7e1                	j	88e <malloc+0x36>
      if(p->s.size == nunits)
 8c8:	02e48b63          	beq	s1,a4,8fe <malloc+0xa6>
        p->s.size -= nunits;
 8cc:	4137073b          	subw	a4,a4,s3
 8d0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d2:	1702                	slli	a4,a4,0x20
 8d4:	9301                	srli	a4,a4,0x20
 8d6:	0712                	slli	a4,a4,0x4
 8d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8da:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8de:	00000717          	auipc	a4,0x0
 8e2:	08a73523          	sd	a0,138(a4) # 968 <freep>
      return (void*)(p + 1);
 8e6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8ea:	70e2                	ld	ra,56(sp)
 8ec:	7442                	ld	s0,48(sp)
 8ee:	74a2                	ld	s1,40(sp)
 8f0:	7902                	ld	s2,32(sp)
 8f2:	69e2                	ld	s3,24(sp)
 8f4:	6a42                	ld	s4,16(sp)
 8f6:	6aa2                	ld	s5,8(sp)
 8f8:	6b02                	ld	s6,0(sp)
 8fa:	6121                	addi	sp,sp,64
 8fc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8fe:	6398                	ld	a4,0(a5)
 900:	e118                	sd	a4,0(a0)
 902:	bff1                	j	8de <malloc+0x86>
  hp->s.size = nu;
 904:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 908:	0541                	addi	a0,a0,16
 90a:	00000097          	auipc	ra,0x0
 90e:	ec6080e7          	jalr	-314(ra) # 7d0 <free>
  return freep;
 912:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 916:	d971                	beqz	a0,8ea <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 918:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 91a:	4798                	lw	a4,8(a5)
 91c:	fa9776e3          	bgeu	a4,s1,8c8 <malloc+0x70>
    if(p == freep)
 920:	00093703          	ld	a4,0(s2)
 924:	853e                	mv	a0,a5
 926:	fef719e3          	bne	a4,a5,918 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 92a:	8552                	mv	a0,s4
 92c:	00000097          	auipc	ra,0x0
 930:	a62080e7          	jalr	-1438(ra) # 38e <sbrk>
  if(p == (char*)-1)
 934:	fd5518e3          	bne	a0,s5,904 <malloc+0xac>
        return 0;
 938:	4501                	li	a0,0
 93a:	bf45                	j	8ea <malloc+0x92>
