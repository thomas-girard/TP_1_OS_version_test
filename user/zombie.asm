
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	2de080e7          	jalr	734(ra) # 2e6 <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	2d8080e7          	jalr	728(ra) # 2ee <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	35e080e7          	jalr	862(ra) # 37e <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e422                	sd	s0,8(sp)
  2e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  30:	87aa                	mv	a5,a0
  32:	0585                	addi	a1,a1,1
  34:	0785                	addi	a5,a5,1
  36:	fff5c703          	lbu	a4,-1(a1)
  3a:	fee78fa3          	sb	a4,-1(a5)
  3e:	fb75                	bnez	a4,32 <strcpy+0x8>
    ;
  return os;
}
  40:	6422                	ld	s0,8(sp)
  42:	0141                	addi	sp,sp,16
  44:	8082                	ret

0000000000000046 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  4c:	00054783          	lbu	a5,0(a0)
  50:	cb91                	beqz	a5,64 <strcmp+0x1e>
  52:	0005c703          	lbu	a4,0(a1)
  56:	00f71763          	bne	a4,a5,64 <strcmp+0x1e>
    p++, q++;
  5a:	0505                	addi	a0,a0,1
  5c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  5e:	00054783          	lbu	a5,0(a0)
  62:	fbe5                	bnez	a5,52 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  64:	0005c503          	lbu	a0,0(a1)
}
  68:	40a7853b          	subw	a0,a5,a0
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strlen>:

uint
strlen(const char *s)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  78:	00054783          	lbu	a5,0(a0)
  7c:	cf91                	beqz	a5,98 <strlen+0x26>
  7e:	0505                	addi	a0,a0,1
  80:	87aa                	mv	a5,a0
  82:	4685                	li	a3,1
  84:	9e89                	subw	a3,a3,a0
  86:	00f6853b          	addw	a0,a3,a5
  8a:	0785                	addi	a5,a5,1
  8c:	fff7c703          	lbu	a4,-1(a5)
  90:	fb7d                	bnez	a4,86 <strlen+0x14>
    ;
  return n;
}
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret
  for(n = 0; s[n]; n++)
  98:	4501                	li	a0,0
  9a:	bfe5                	j	92 <strlen+0x20>

000000000000009c <memset>:

void*
memset(void *dst, int c, uint n)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a2:	ce09                	beqz	a2,bc <memset+0x20>
  a4:	87aa                	mv	a5,a0
  a6:	fff6071b          	addiw	a4,a2,-1
  aa:	1702                	slli	a4,a4,0x20
  ac:	9301                	srli	a4,a4,0x20
  ae:	0705                	addi	a4,a4,1
  b0:	972a                	add	a4,a4,a0
    cdst[i] = c;
  b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b6:	0785                	addi	a5,a5,1
  b8:	fee79de3          	bne	a5,a4,b2 <memset+0x16>
  }
  return dst;
}
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strchr>:

char*
strchr(const char *s, char c)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cb99                	beqz	a5,e2 <strchr+0x20>
    if(*s == c)
  ce:	00f58763          	beq	a1,a5,dc <strchr+0x1a>
  for(; *s; s++)
  d2:	0505                	addi	a0,a0,1
  d4:	00054783          	lbu	a5,0(a0)
  d8:	fbfd                	bnez	a5,ce <strchr+0xc>
      return (char*)s;
  return 0;
  da:	4501                	li	a0,0
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  return 0;
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strchr+0x1a>

00000000000000e6 <gets>:

char*
gets(char *buf, int max)
{
  e6:	711d                	addi	sp,sp,-96
  e8:	ec86                	sd	ra,88(sp)
  ea:	e8a2                	sd	s0,80(sp)
  ec:	e4a6                	sd	s1,72(sp)
  ee:	e0ca                	sd	s2,64(sp)
  f0:	fc4e                	sd	s3,56(sp)
  f2:	f852                	sd	s4,48(sp)
  f4:	f456                	sd	s5,40(sp)
  f6:	f05a                	sd	s6,32(sp)
  f8:	ec5e                	sd	s7,24(sp)
  fa:	1080                	addi	s0,sp,96
  fc:	8baa                	mv	s7,a0
  fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 100:	892a                	mv	s2,a0
 102:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 104:	4aa9                	li	s5,10
 106:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 108:	89a6                	mv	s3,s1
 10a:	2485                	addiw	s1,s1,1
 10c:	0344d863          	bge	s1,s4,13c <gets+0x56>
    cc = read(0, &c, 1);
 110:	4605                	li	a2,1
 112:	faf40593          	addi	a1,s0,-81
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	1ee080e7          	jalr	494(ra) # 306 <read>
    if(cc < 1)
 120:	00a05e63          	blez	a0,13c <gets+0x56>
    buf[i++] = c;
 124:	faf44783          	lbu	a5,-81(s0)
 128:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 12c:	01578763          	beq	a5,s5,13a <gets+0x54>
 130:	0905                	addi	s2,s2,1
 132:	fd679be3          	bne	a5,s6,108 <gets+0x22>
  for(i=0; i+1 < max; ){
 136:	89a6                	mv	s3,s1
 138:	a011                	j	13c <gets+0x56>
 13a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 13c:	99de                	add	s3,s3,s7
 13e:	00098023          	sb	zero,0(s3)
  return buf;
}
 142:	855e                	mv	a0,s7
 144:	60e6                	ld	ra,88(sp)
 146:	6446                	ld	s0,80(sp)
 148:	64a6                	ld	s1,72(sp)
 14a:	6906                	ld	s2,64(sp)
 14c:	79e2                	ld	s3,56(sp)
 14e:	7a42                	ld	s4,48(sp)
 150:	7aa2                	ld	s5,40(sp)
 152:	7b02                	ld	s6,32(sp)
 154:	6be2                	ld	s7,24(sp)
 156:	6125                	addi	sp,sp,96
 158:	8082                	ret

000000000000015a <atoi>:
  return r;
}

int
atoi(const char *s)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 160:	00054603          	lbu	a2,0(a0)
 164:	fd06079b          	addiw	a5,a2,-48
 168:	0ff7f793          	andi	a5,a5,255
 16c:	4725                	li	a4,9
 16e:	02f76963          	bltu	a4,a5,1a0 <atoi+0x46>
 172:	86aa                	mv	a3,a0
  n = 0;
 174:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 176:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 178:	0685                	addi	a3,a3,1
 17a:	0025179b          	slliw	a5,a0,0x2
 17e:	9fa9                	addw	a5,a5,a0
 180:	0017979b          	slliw	a5,a5,0x1
 184:	9fb1                	addw	a5,a5,a2
 186:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 18a:	0006c603          	lbu	a2,0(a3)
 18e:	fd06071b          	addiw	a4,a2,-48
 192:	0ff77713          	andi	a4,a4,255
 196:	fee5f1e3          	bgeu	a1,a4,178 <atoi+0x1e>
  return n;
}
 19a:	6422                	ld	s0,8(sp)
 19c:	0141                	addi	sp,sp,16
 19e:	8082                	ret
  n = 0;
 1a0:	4501                	li	a0,0
 1a2:	bfe5                	j	19a <atoi+0x40>

00000000000001a4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1aa:	02b57663          	bgeu	a0,a1,1d6 <memmove+0x32>
    while(n-- > 0)
 1ae:	02c05163          	blez	a2,1d0 <memmove+0x2c>
 1b2:	fff6079b          	addiw	a5,a2,-1
 1b6:	1782                	slli	a5,a5,0x20
 1b8:	9381                	srli	a5,a5,0x20
 1ba:	0785                	addi	a5,a5,1
 1bc:	97aa                	add	a5,a5,a0
  dst = vdst;
 1be:	872a                	mv	a4,a0
      *dst++ = *src++;
 1c0:	0585                	addi	a1,a1,1
 1c2:	0705                	addi	a4,a4,1
 1c4:	fff5c683          	lbu	a3,-1(a1)
 1c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1cc:	fee79ae3          	bne	a5,a4,1c0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
    dst += n;
 1d6:	00c50733          	add	a4,a0,a2
    src += n;
 1da:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 1dc:	fec05ae3          	blez	a2,1d0 <memmove+0x2c>
 1e0:	fff6079b          	addiw	a5,a2,-1
 1e4:	1782                	slli	a5,a5,0x20
 1e6:	9381                	srli	a5,a5,0x20
 1e8:	fff7c793          	not	a5,a5
 1ec:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 1ee:	15fd                	addi	a1,a1,-1
 1f0:	177d                	addi	a4,a4,-1
 1f2:	0005c683          	lbu	a3,0(a1)
 1f6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 1fa:	fee79ae3          	bne	a5,a4,1ee <memmove+0x4a>
 1fe:	bfc9                	j	1d0 <memmove+0x2c>

0000000000000200 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 206:	ca05                	beqz	a2,236 <memcmp+0x36>
 208:	fff6069b          	addiw	a3,a2,-1
 20c:	1682                	slli	a3,a3,0x20
 20e:	9281                	srli	a3,a3,0x20
 210:	0685                	addi	a3,a3,1
 212:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 214:	00054783          	lbu	a5,0(a0)
 218:	0005c703          	lbu	a4,0(a1)
 21c:	00e79863          	bne	a5,a4,22c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 220:	0505                	addi	a0,a0,1
    p2++;
 222:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 224:	fed518e3          	bne	a0,a3,214 <memcmp+0x14>
  }
  return 0;
 228:	4501                	li	a0,0
 22a:	a019                	j	230 <memcmp+0x30>
      return *p1 - *p2;
 22c:	40e7853b          	subw	a0,a5,a4
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
  return 0;
 236:	4501                	li	a0,0
 238:	bfe5                	j	230 <memcmp+0x30>

000000000000023a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e406                	sd	ra,8(sp)
 23e:	e022                	sd	s0,0(sp)
 240:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 242:	00000097          	auipc	ra,0x0
 246:	f62080e7          	jalr	-158(ra) # 1a4 <memmove>
}
 24a:	60a2                	ld	ra,8(sp)
 24c:	6402                	ld	s0,0(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret

0000000000000252 <close>:

int close(int fd){
 252:	1101                	addi	sp,sp,-32
 254:	ec06                	sd	ra,24(sp)
 256:	e822                	sd	s0,16(sp)
 258:	e426                	sd	s1,8(sp)
 25a:	1000                	addi	s0,sp,32
 25c:	84aa                	mv	s1,a0
  fflush(fd);
 25e:	00000097          	auipc	ra,0x0
 262:	2d4080e7          	jalr	724(ra) # 532 <fflush>
  char* buf = get_putc_buf(fd);
 266:	8526                	mv	a0,s1
 268:	00000097          	auipc	ra,0x0
 26c:	14e080e7          	jalr	334(ra) # 3b6 <get_putc_buf>
  if(buf){
 270:	cd11                	beqz	a0,28c <close+0x3a>
    free(buf);
 272:	00000097          	auipc	ra,0x0
 276:	546080e7          	jalr	1350(ra) # 7b8 <free>
    putc_buf[fd] = 0;
 27a:	00349713          	slli	a4,s1,0x3
 27e:	00000797          	auipc	a5,0x0
 282:	6d278793          	addi	a5,a5,1746 # 950 <putc_buf>
 286:	97ba                	add	a5,a5,a4
 288:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 28c:	8526                	mv	a0,s1
 28e:	00000097          	auipc	ra,0x0
 292:	088080e7          	jalr	136(ra) # 316 <sclose>
}
 296:	60e2                	ld	ra,24(sp)
 298:	6442                	ld	s0,16(sp)
 29a:	64a2                	ld	s1,8(sp)
 29c:	6105                	addi	sp,sp,32
 29e:	8082                	ret

00000000000002a0 <stat>:
{
 2a0:	1101                	addi	sp,sp,-32
 2a2:	ec06                	sd	ra,24(sp)
 2a4:	e822                	sd	s0,16(sp)
 2a6:	e426                	sd	s1,8(sp)
 2a8:	e04a                	sd	s2,0(sp)
 2aa:	1000                	addi	s0,sp,32
 2ac:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 2ae:	4581                	li	a1,0
 2b0:	00000097          	auipc	ra,0x0
 2b4:	07e080e7          	jalr	126(ra) # 32e <open>
  if(fd < 0)
 2b8:	02054563          	bltz	a0,2e2 <stat+0x42>
 2bc:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 2be:	85ca                	mv	a1,s2
 2c0:	00000097          	auipc	ra,0x0
 2c4:	086080e7          	jalr	134(ra) # 346 <fstat>
 2c8:	892a                	mv	s2,a0
  close(fd);
 2ca:	8526                	mv	a0,s1
 2cc:	00000097          	auipc	ra,0x0
 2d0:	f86080e7          	jalr	-122(ra) # 252 <close>
}
 2d4:	854a                	mv	a0,s2
 2d6:	60e2                	ld	ra,24(sp)
 2d8:	6442                	ld	s0,16(sp)
 2da:	64a2                	ld	s1,8(sp)
 2dc:	6902                	ld	s2,0(sp)
 2de:	6105                	addi	sp,sp,32
 2e0:	8082                	ret
    return -1;
 2e2:	597d                	li	s2,-1
 2e4:	bfc5                	j	2d4 <stat+0x34>

00000000000002e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e6:	4885                	li	a7,1
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ee:	4889                	li	a7,2
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f6:	488d                	li	a7,3
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fe:	4891                	li	a7,4
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <read>:
.global read
read:
 li a7, SYS_read
 306:	4895                	li	a7,5
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <write>:
.global write
write:
 li a7, SYS_write
 30e:	48c1                	li	a7,16
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 316:	48d5                	li	a7,21
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <kill>:
.global kill
kill:
 li a7, SYS_kill
 31e:	4899                	li	a7,6
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <exec>:
.global exec
exec:
 li a7, SYS_exec
 326:	489d                	li	a7,7
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <open>:
.global open
open:
 li a7, SYS_open
 32e:	48bd                	li	a7,15
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 336:	48c5                	li	a7,17
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33e:	48c9                	li	a7,18
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 346:	48a1                	li	a7,8
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <link>:
.global link
link:
 li a7, SYS_link
 34e:	48cd                	li	a7,19
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 356:	48d1                	li	a7,20
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35e:	48a5                	li	a7,9
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <dup>:
.global dup
dup:
 li a7, SYS_dup
 366:	48a9                	li	a7,10
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36e:	48ad                	li	a7,11
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 376:	48b1                	li	a7,12
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37e:	48b5                	li	a7,13
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 386:	48b9                	li	a7,14
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 38e:	48d9                	li	a7,22
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <nice>:
.global nice
nice:
 li a7, SYS_nice
 396:	48dd                	li	a7,23
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 39e:	48e1                	li	a7,24
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 3a6:	48e5                	li	a7,25
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 3ae:	48e9                	li	a7,26
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 3b6:	1101                	addi	sp,sp,-32
 3b8:	ec06                	sd	ra,24(sp)
 3ba:	e822                	sd	s0,16(sp)
 3bc:	e426                	sd	s1,8(sp)
 3be:	1000                	addi	s0,sp,32
 3c0:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 3c2:	00351713          	slli	a4,a0,0x3
 3c6:	00000797          	auipc	a5,0x0
 3ca:	58a78793          	addi	a5,a5,1418 # 950 <putc_buf>
 3ce:	97ba                	add	a5,a5,a4
 3d0:	6388                	ld	a0,0(a5)
  if(buf) {
 3d2:	c511                	beqz	a0,3de <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 3d4:	60e2                	ld	ra,24(sp)
 3d6:	6442                	ld	s0,16(sp)
 3d8:	64a2                	ld	s1,8(sp)
 3da:	6105                	addi	sp,sp,32
 3dc:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 3de:	6505                	lui	a0,0x1
 3e0:	00000097          	auipc	ra,0x0
 3e4:	460080e7          	jalr	1120(ra) # 840 <malloc>
  putc_buf[fd] = buf;
 3e8:	00000797          	auipc	a5,0x0
 3ec:	56878793          	addi	a5,a5,1384 # 950 <putc_buf>
 3f0:	00349713          	slli	a4,s1,0x3
 3f4:	973e                	add	a4,a4,a5
 3f6:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 3f8:	048a                	slli	s1,s1,0x2
 3fa:	94be                	add	s1,s1,a5
 3fc:	3204a023          	sw	zero,800(s1)
  return buf;
 400:	bfd1                	j	3d4 <get_putc_buf+0x1e>

0000000000000402 <putc>:

static void
putc(int fd, char c)
{
 402:	1101                	addi	sp,sp,-32
 404:	ec06                	sd	ra,24(sp)
 406:	e822                	sd	s0,16(sp)
 408:	e426                	sd	s1,8(sp)
 40a:	e04a                	sd	s2,0(sp)
 40c:	1000                	addi	s0,sp,32
 40e:	84aa                	mv	s1,a0
 410:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 412:	00000097          	auipc	ra,0x0
 416:	fa4080e7          	jalr	-92(ra) # 3b6 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 41a:	00249793          	slli	a5,s1,0x2
 41e:	00000717          	auipc	a4,0x0
 422:	53270713          	addi	a4,a4,1330 # 950 <putc_buf>
 426:	973e                	add	a4,a4,a5
 428:	32072783          	lw	a5,800(a4)
 42c:	0017869b          	addiw	a3,a5,1
 430:	32d72023          	sw	a3,800(a4)
 434:	97aa                	add	a5,a5,a0
 436:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 43a:	47a9                	li	a5,10
 43c:	02f90463          	beq	s2,a5,464 <putc+0x62>
 440:	00249713          	slli	a4,s1,0x2
 444:	00000797          	auipc	a5,0x0
 448:	50c78793          	addi	a5,a5,1292 # 950 <putc_buf>
 44c:	97ba                	add	a5,a5,a4
 44e:	3207a703          	lw	a4,800(a5)
 452:	6785                	lui	a5,0x1
 454:	00f70863          	beq	a4,a5,464 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 458:	60e2                	ld	ra,24(sp)
 45a:	6442                	ld	s0,16(sp)
 45c:	64a2                	ld	s1,8(sp)
 45e:	6902                	ld	s2,0(sp)
 460:	6105                	addi	sp,sp,32
 462:	8082                	ret
    write(fd, buf, putc_index[fd]);
 464:	00249793          	slli	a5,s1,0x2
 468:	00000917          	auipc	s2,0x0
 46c:	4e890913          	addi	s2,s2,1256 # 950 <putc_buf>
 470:	993e                	add	s2,s2,a5
 472:	32092603          	lw	a2,800(s2)
 476:	85aa                	mv	a1,a0
 478:	8526                	mv	a0,s1
 47a:	00000097          	auipc	ra,0x0
 47e:	e94080e7          	jalr	-364(ra) # 30e <write>
    putc_index[fd] = 0;
 482:	32092023          	sw	zero,800(s2)
}
 486:	bfc9                	j	458 <putc+0x56>

0000000000000488 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 488:	7139                	addi	sp,sp,-64
 48a:	fc06                	sd	ra,56(sp)
 48c:	f822                	sd	s0,48(sp)
 48e:	f426                	sd	s1,40(sp)
 490:	f04a                	sd	s2,32(sp)
 492:	ec4e                	sd	s3,24(sp)
 494:	0080                	addi	s0,sp,64
 496:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 498:	c299                	beqz	a3,49e <printint+0x16>
 49a:	0805c863          	bltz	a1,52a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 49e:	2581                	sext.w	a1,a1
  neg = 0;
 4a0:	4881                	li	a7,0
 4a2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4a6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a8:	2601                	sext.w	a2,a2
 4aa:	00000517          	auipc	a0,0x0
 4ae:	48650513          	addi	a0,a0,1158 # 930 <digits>
 4b2:	883a                	mv	a6,a4
 4b4:	2705                	addiw	a4,a4,1
 4b6:	02c5f7bb          	remuw	a5,a1,a2
 4ba:	1782                	slli	a5,a5,0x20
 4bc:	9381                	srli	a5,a5,0x20
 4be:	97aa                	add	a5,a5,a0
 4c0:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x1f0>
 4c4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c8:	0005879b          	sext.w	a5,a1
 4cc:	02c5d5bb          	divuw	a1,a1,a2
 4d0:	0685                	addi	a3,a3,1
 4d2:	fec7f0e3          	bgeu	a5,a2,4b2 <printint+0x2a>
  if(neg)
 4d6:	00088b63          	beqz	a7,4ec <printint+0x64>
    buf[i++] = '-';
 4da:	fd040793          	addi	a5,s0,-48
 4de:	973e                	add	a4,a4,a5
 4e0:	02d00793          	li	a5,45
 4e4:	fef70823          	sb	a5,-16(a4)
 4e8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ec:	02e05863          	blez	a4,51c <printint+0x94>
 4f0:	fc040793          	addi	a5,s0,-64
 4f4:	00e78933          	add	s2,a5,a4
 4f8:	fff78993          	addi	s3,a5,-1
 4fc:	99ba                	add	s3,s3,a4
 4fe:	377d                	addiw	a4,a4,-1
 500:	1702                	slli	a4,a4,0x20
 502:	9301                	srli	a4,a4,0x20
 504:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 508:	fff94583          	lbu	a1,-1(s2)
 50c:	8526                	mv	a0,s1
 50e:	00000097          	auipc	ra,0x0
 512:	ef4080e7          	jalr	-268(ra) # 402 <putc>
  while(--i >= 0)
 516:	197d                	addi	s2,s2,-1
 518:	ff3918e3          	bne	s2,s3,508 <printint+0x80>
}
 51c:	70e2                	ld	ra,56(sp)
 51e:	7442                	ld	s0,48(sp)
 520:	74a2                	ld	s1,40(sp)
 522:	7902                	ld	s2,32(sp)
 524:	69e2                	ld	s3,24(sp)
 526:	6121                	addi	sp,sp,64
 528:	8082                	ret
    x = -xx;
 52a:	40b005bb          	negw	a1,a1
    neg = 1;
 52e:	4885                	li	a7,1
    x = -xx;
 530:	bf8d                	j	4a2 <printint+0x1a>

0000000000000532 <fflush>:
void fflush(int fd){
 532:	1101                	addi	sp,sp,-32
 534:	ec06                	sd	ra,24(sp)
 536:	e822                	sd	s0,16(sp)
 538:	e426                	sd	s1,8(sp)
 53a:	e04a                	sd	s2,0(sp)
 53c:	1000                	addi	s0,sp,32
 53e:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 540:	00000097          	auipc	ra,0x0
 544:	e76080e7          	jalr	-394(ra) # 3b6 <get_putc_buf>
 548:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 54a:	00291793          	slli	a5,s2,0x2
 54e:	00000497          	auipc	s1,0x0
 552:	40248493          	addi	s1,s1,1026 # 950 <putc_buf>
 556:	94be                	add	s1,s1,a5
 558:	3204a603          	lw	a2,800(s1)
 55c:	854a                	mv	a0,s2
 55e:	00000097          	auipc	ra,0x0
 562:	db0080e7          	jalr	-592(ra) # 30e <write>
  putc_index[fd] = 0;
 566:	3204a023          	sw	zero,800(s1)
}
 56a:	60e2                	ld	ra,24(sp)
 56c:	6442                	ld	s0,16(sp)
 56e:	64a2                	ld	s1,8(sp)
 570:	6902                	ld	s2,0(sp)
 572:	6105                	addi	sp,sp,32
 574:	8082                	ret

0000000000000576 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 576:	7119                	addi	sp,sp,-128
 578:	fc86                	sd	ra,120(sp)
 57a:	f8a2                	sd	s0,112(sp)
 57c:	f4a6                	sd	s1,104(sp)
 57e:	f0ca                	sd	s2,96(sp)
 580:	ecce                	sd	s3,88(sp)
 582:	e8d2                	sd	s4,80(sp)
 584:	e4d6                	sd	s5,72(sp)
 586:	e0da                	sd	s6,64(sp)
 588:	fc5e                	sd	s7,56(sp)
 58a:	f862                	sd	s8,48(sp)
 58c:	f466                	sd	s9,40(sp)
 58e:	f06a                	sd	s10,32(sp)
 590:	ec6e                	sd	s11,24(sp)
 592:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 594:	0005c903          	lbu	s2,0(a1)
 598:	18090f63          	beqz	s2,736 <vprintf+0x1c0>
 59c:	8aaa                	mv	s5,a0
 59e:	8b32                	mv	s6,a2
 5a0:	00158493          	addi	s1,a1,1
  state = 0;
 5a4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a6:	02500a13          	li	s4,37
      if(c == 'd'){
 5aa:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5ae:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5b2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5b6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ba:	00000b97          	auipc	s7,0x0
 5be:	376b8b93          	addi	s7,s7,886 # 930 <digits>
 5c2:	a839                	j	5e0 <vprintf+0x6a>
        putc(fd, c);
 5c4:	85ca                	mv	a1,s2
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e3a080e7          	jalr	-454(ra) # 402 <putc>
 5d0:	a019                	j	5d6 <vprintf+0x60>
    } else if(state == '%'){
 5d2:	01498f63          	beq	s3,s4,5f0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5d6:	0485                	addi	s1,s1,1
 5d8:	fff4c903          	lbu	s2,-1(s1)
 5dc:	14090d63          	beqz	s2,736 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5e0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e4:	fe0997e3          	bnez	s3,5d2 <vprintf+0x5c>
      if(c == '%'){
 5e8:	fd479ee3          	bne	a5,s4,5c4 <vprintf+0x4e>
        state = '%';
 5ec:	89be                	mv	s3,a5
 5ee:	b7e5                	j	5d6 <vprintf+0x60>
      if(c == 'd'){
 5f0:	05878063          	beq	a5,s8,630 <vprintf+0xba>
      } else if(c == 'l') {
 5f4:	05978c63          	beq	a5,s9,64c <vprintf+0xd6>
      } else if(c == 'x') {
 5f8:	07a78863          	beq	a5,s10,668 <vprintf+0xf2>
      } else if(c == 'p') {
 5fc:	09b78463          	beq	a5,s11,684 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 600:	07300713          	li	a4,115
 604:	0ce78663          	beq	a5,a4,6d0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 608:	06300713          	li	a4,99
 60c:	0ee78e63          	beq	a5,a4,708 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 610:	11478863          	beq	a5,s4,720 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 614:	85d2                	mv	a1,s4
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	dea080e7          	jalr	-534(ra) # 402 <putc>
        putc(fd, c);
 620:	85ca                	mv	a1,s2
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	dde080e7          	jalr	-546(ra) # 402 <putc>
      }
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b765                	j	5d6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 630:	008b0913          	addi	s2,s6,8
 634:	4685                	li	a3,1
 636:	4629                	li	a2,10
 638:	000b2583          	lw	a1,0(s6)
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	e4a080e7          	jalr	-438(ra) # 488 <printint>
 646:	8b4a                	mv	s6,s2
      state = 0;
 648:	4981                	li	s3,0
 64a:	b771                	j	5d6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	008b0913          	addi	s2,s6,8
 650:	4681                	li	a3,0
 652:	4629                	li	a2,10
 654:	000b2583          	lw	a1,0(s6)
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	e2e080e7          	jalr	-466(ra) # 488 <printint>
 662:	8b4a                	mv	s6,s2
      state = 0;
 664:	4981                	li	s3,0
 666:	bf85                	j	5d6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 668:	008b0913          	addi	s2,s6,8
 66c:	4681                	li	a3,0
 66e:	4641                	li	a2,16
 670:	000b2583          	lw	a1,0(s6)
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	e12080e7          	jalr	-494(ra) # 488 <printint>
 67e:	8b4a                	mv	s6,s2
      state = 0;
 680:	4981                	li	s3,0
 682:	bf91                	j	5d6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 684:	008b0793          	addi	a5,s6,8
 688:	f8f43423          	sd	a5,-120(s0)
 68c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 690:	03000593          	li	a1,48
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	d6c080e7          	jalr	-660(ra) # 402 <putc>
  putc(fd, 'x');
 69e:	85ea                	mv	a1,s10
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	d60080e7          	jalr	-672(ra) # 402 <putc>
 6aa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ac:	03c9d793          	srli	a5,s3,0x3c
 6b0:	97de                	add	a5,a5,s7
 6b2:	0007c583          	lbu	a1,0(a5)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	d4a080e7          	jalr	-694(ra) # 402 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c0:	0992                	slli	s3,s3,0x4
 6c2:	397d                	addiw	s2,s2,-1
 6c4:	fe0914e3          	bnez	s2,6ac <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6c8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b721                	j	5d6 <vprintf+0x60>
        s = va_arg(ap, char*);
 6d0:	008b0993          	addi	s3,s6,8
 6d4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6d8:	02090163          	beqz	s2,6fa <vprintf+0x184>
        while(*s != 0){
 6dc:	00094583          	lbu	a1,0(s2)
 6e0:	c9a1                	beqz	a1,730 <vprintf+0x1ba>
          putc(fd, *s);
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	d1e080e7          	jalr	-738(ra) # 402 <putc>
          s++;
 6ec:	0905                	addi	s2,s2,1
        while(*s != 0){
 6ee:	00094583          	lbu	a1,0(s2)
 6f2:	f9e5                	bnez	a1,6e2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6f4:	8b4e                	mv	s6,s3
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bdf9                	j	5d6 <vprintf+0x60>
          s = "(null)";
 6fa:	00000917          	auipc	s2,0x0
 6fe:	22e90913          	addi	s2,s2,558 # 928 <malloc+0xe8>
        while(*s != 0){
 702:	02800593          	li	a1,40
 706:	bff1                	j	6e2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 708:	008b0913          	addi	s2,s6,8
 70c:	000b4583          	lbu	a1,0(s6)
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	cf0080e7          	jalr	-784(ra) # 402 <putc>
 71a:	8b4a                	mv	s6,s2
      state = 0;
 71c:	4981                	li	s3,0
 71e:	bd65                	j	5d6 <vprintf+0x60>
        putc(fd, c);
 720:	85d2                	mv	a1,s4
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	cde080e7          	jalr	-802(ra) # 402 <putc>
      state = 0;
 72c:	4981                	li	s3,0
 72e:	b565                	j	5d6 <vprintf+0x60>
        s = va_arg(ap, char*);
 730:	8b4e                	mv	s6,s3
      state = 0;
 732:	4981                	li	s3,0
 734:	b54d                	j	5d6 <vprintf+0x60>
    }
  }
}
 736:	70e6                	ld	ra,120(sp)
 738:	7446                	ld	s0,112(sp)
 73a:	74a6                	ld	s1,104(sp)
 73c:	7906                	ld	s2,96(sp)
 73e:	69e6                	ld	s3,88(sp)
 740:	6a46                	ld	s4,80(sp)
 742:	6aa6                	ld	s5,72(sp)
 744:	6b06                	ld	s6,64(sp)
 746:	7be2                	ld	s7,56(sp)
 748:	7c42                	ld	s8,48(sp)
 74a:	7ca2                	ld	s9,40(sp)
 74c:	7d02                	ld	s10,32(sp)
 74e:	6de2                	ld	s11,24(sp)
 750:	6109                	addi	sp,sp,128
 752:	8082                	ret

0000000000000754 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 754:	715d                	addi	sp,sp,-80
 756:	ec06                	sd	ra,24(sp)
 758:	e822                	sd	s0,16(sp)
 75a:	1000                	addi	s0,sp,32
 75c:	e010                	sd	a2,0(s0)
 75e:	e414                	sd	a3,8(s0)
 760:	e818                	sd	a4,16(s0)
 762:	ec1c                	sd	a5,24(s0)
 764:	03043023          	sd	a6,32(s0)
 768:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 76c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 770:	8622                	mv	a2,s0
 772:	00000097          	auipc	ra,0x0
 776:	e04080e7          	jalr	-508(ra) # 576 <vprintf>
}
 77a:	60e2                	ld	ra,24(sp)
 77c:	6442                	ld	s0,16(sp)
 77e:	6161                	addi	sp,sp,80
 780:	8082                	ret

0000000000000782 <printf>:

void
printf(const char *fmt, ...)
{
 782:	711d                	addi	sp,sp,-96
 784:	ec06                	sd	ra,24(sp)
 786:	e822                	sd	s0,16(sp)
 788:	1000                	addi	s0,sp,32
 78a:	e40c                	sd	a1,8(s0)
 78c:	e810                	sd	a2,16(s0)
 78e:	ec14                	sd	a3,24(s0)
 790:	f018                	sd	a4,32(s0)
 792:	f41c                	sd	a5,40(s0)
 794:	03043823          	sd	a6,48(s0)
 798:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79c:	00840613          	addi	a2,s0,8
 7a0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a4:	85aa                	mv	a1,a0
 7a6:	4505                	li	a0,1
 7a8:	00000097          	auipc	ra,0x0
 7ac:	dce080e7          	jalr	-562(ra) # 576 <vprintf>
}
 7b0:	60e2                	ld	ra,24(sp)
 7b2:	6442                	ld	s0,16(sp)
 7b4:	6125                	addi	sp,sp,96
 7b6:	8082                	ret

00000000000007b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b8:	1141                	addi	sp,sp,-16
 7ba:	e422                	sd	s0,8(sp)
 7bc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7be:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c2:	00000797          	auipc	a5,0x0
 7c6:	1867b783          	ld	a5,390(a5) # 948 <freep>
 7ca:	a805                	j	7fa <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7cc:	4618                	lw	a4,8(a2)
 7ce:	9db9                	addw	a1,a1,a4
 7d0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d4:	6398                	ld	a4,0(a5)
 7d6:	6318                	ld	a4,0(a4)
 7d8:	fee53823          	sd	a4,-16(a0)
 7dc:	a091                	j	820 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7de:	ff852703          	lw	a4,-8(a0)
 7e2:	9e39                	addw	a2,a2,a4
 7e4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7e6:	ff053703          	ld	a4,-16(a0)
 7ea:	e398                	sd	a4,0(a5)
 7ec:	a099                	j	832 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ee:	6398                	ld	a4,0(a5)
 7f0:	00e7e463          	bltu	a5,a4,7f8 <free+0x40>
 7f4:	00e6ea63          	bltu	a3,a4,808 <free+0x50>
{
 7f8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fa:	fed7fae3          	bgeu	a5,a3,7ee <free+0x36>
 7fe:	6398                	ld	a4,0(a5)
 800:	00e6e463          	bltu	a3,a4,808 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 804:	fee7eae3          	bltu	a5,a4,7f8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 808:	ff852583          	lw	a1,-8(a0)
 80c:	6390                	ld	a2,0(a5)
 80e:	02059713          	slli	a4,a1,0x20
 812:	9301                	srli	a4,a4,0x20
 814:	0712                	slli	a4,a4,0x4
 816:	9736                	add	a4,a4,a3
 818:	fae60ae3          	beq	a2,a4,7cc <free+0x14>
    bp->s.ptr = p->s.ptr;
 81c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 820:	4790                	lw	a2,8(a5)
 822:	02061713          	slli	a4,a2,0x20
 826:	9301                	srli	a4,a4,0x20
 828:	0712                	slli	a4,a4,0x4
 82a:	973e                	add	a4,a4,a5
 82c:	fae689e3          	beq	a3,a4,7de <free+0x26>
  } else
    p->s.ptr = bp;
 830:	e394                	sd	a3,0(a5)
  freep = p;
 832:	00000717          	auipc	a4,0x0
 836:	10f73b23          	sd	a5,278(a4) # 948 <freep>
}
 83a:	6422                	ld	s0,8(sp)
 83c:	0141                	addi	sp,sp,16
 83e:	8082                	ret

0000000000000840 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 840:	7139                	addi	sp,sp,-64
 842:	fc06                	sd	ra,56(sp)
 844:	f822                	sd	s0,48(sp)
 846:	f426                	sd	s1,40(sp)
 848:	f04a                	sd	s2,32(sp)
 84a:	ec4e                	sd	s3,24(sp)
 84c:	e852                	sd	s4,16(sp)
 84e:	e456                	sd	s5,8(sp)
 850:	e05a                	sd	s6,0(sp)
 852:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 854:	02051493          	slli	s1,a0,0x20
 858:	9081                	srli	s1,s1,0x20
 85a:	04bd                	addi	s1,s1,15
 85c:	8091                	srli	s1,s1,0x4
 85e:	0014899b          	addiw	s3,s1,1
 862:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 864:	00000517          	auipc	a0,0x0
 868:	0e453503          	ld	a0,228(a0) # 948 <freep>
 86c:	c515                	beqz	a0,898 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 870:	4798                	lw	a4,8(a5)
 872:	02977f63          	bgeu	a4,s1,8b0 <malloc+0x70>
 876:	8a4e                	mv	s4,s3
 878:	0009871b          	sext.w	a4,s3
 87c:	6685                	lui	a3,0x1
 87e:	00d77363          	bgeu	a4,a3,884 <malloc+0x44>
 882:	6a05                	lui	s4,0x1
 884:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 888:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 88c:	00000917          	auipc	s2,0x0
 890:	0bc90913          	addi	s2,s2,188 # 948 <freep>
  if(p == (char*)-1)
 894:	5afd                	li	s5,-1
 896:	a88d                	j	908 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 898:	00000797          	auipc	a5,0x0
 89c:	56878793          	addi	a5,a5,1384 # e00 <base>
 8a0:	00000717          	auipc	a4,0x0
 8a4:	0af73423          	sd	a5,168(a4) # 948 <freep>
 8a8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8aa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ae:	b7e1                	j	876 <malloc+0x36>
      if(p->s.size == nunits)
 8b0:	02e48b63          	beq	s1,a4,8e6 <malloc+0xa6>
        p->s.size -= nunits;
 8b4:	4137073b          	subw	a4,a4,s3
 8b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ba:	1702                	slli	a4,a4,0x20
 8bc:	9301                	srli	a4,a4,0x20
 8be:	0712                	slli	a4,a4,0x4
 8c0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c6:	00000717          	auipc	a4,0x0
 8ca:	08a73123          	sd	a0,130(a4) # 948 <freep>
      return (void*)(p + 1);
 8ce:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d2:	70e2                	ld	ra,56(sp)
 8d4:	7442                	ld	s0,48(sp)
 8d6:	74a2                	ld	s1,40(sp)
 8d8:	7902                	ld	s2,32(sp)
 8da:	69e2                	ld	s3,24(sp)
 8dc:	6a42                	ld	s4,16(sp)
 8de:	6aa2                	ld	s5,8(sp)
 8e0:	6b02                	ld	s6,0(sp)
 8e2:	6121                	addi	sp,sp,64
 8e4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8e6:	6398                	ld	a4,0(a5)
 8e8:	e118                	sd	a4,0(a0)
 8ea:	bff1                	j	8c6 <malloc+0x86>
  hp->s.size = nu;
 8ec:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f0:	0541                	addi	a0,a0,16
 8f2:	00000097          	auipc	ra,0x0
 8f6:	ec6080e7          	jalr	-314(ra) # 7b8 <free>
  return freep;
 8fa:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8fe:	d971                	beqz	a0,8d2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 900:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 902:	4798                	lw	a4,8(a5)
 904:	fa9776e3          	bgeu	a4,s1,8b0 <malloc+0x70>
    if(p == freep)
 908:	00093703          	ld	a4,0(s2)
 90c:	853e                	mv	a0,a5
 90e:	fef719e3          	bne	a4,a5,900 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 912:	8552                	mv	a0,s4
 914:	00000097          	auipc	ra,0x0
 918:	a62080e7          	jalr	-1438(ra) # 376 <sbrk>
  if(p == (char*)-1)
 91c:	fd5518e3          	bne	a0,s5,8ec <malloc+0xac>
        return 0;
 920:	4501                	li	a0,0
 922:	bf45                	j	8d2 <malloc+0x92>
