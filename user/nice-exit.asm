
user/_nice-exit:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"

int main(){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	06400913          	li	s2,100
  10:	a811                	j	24 <main+0x24>
  for(int i=0; i < 100; i++){
    int pid = fork();
    if(pid>0){
      int pid2 = fork();
  12:	00000097          	auipc	ra,0x0
  16:	31e080e7          	jalr	798(ra) # 330 <fork>
      if(pid2>0){
  1a:	02a04263          	bgtz	a0,3e <main+0x3e>
  for(int i=0; i < 100; i++){
  1e:	397d                	addiw	s2,s2,-1
  20:	04090563          	beqz	s2,6a <main+0x6a>
    int pid = fork();
  24:	00000097          	auipc	ra,0x0
  28:	30c080e7          	jalr	780(ra) # 330 <fork>
  2c:	84aa                	mv	s1,a0
    if(pid>0){
  2e:	fea042e3          	bgtz	a0,12 <main+0x12>
          if(nice(pid,4) != 1) break;
          if(nice(pid,5) != 1) break;
        }
        exit(0);
      }
    } else if(pid == 0){
  32:	f575                	bnez	a0,1e <main+0x1e>
      exit(0);
  34:	4501                	li	a0,0
  36:	00000097          	auipc	ra,0x0
  3a:	302080e7          	jalr	770(ra) # 338 <exit>
          if(nice(pid,4) != 1) break;
  3e:	4905                	li	s2,1
  40:	4591                	li	a1,4
  42:	8526                	mv	a0,s1
  44:	00000097          	auipc	ra,0x0
  48:	39c080e7          	jalr	924(ra) # 3e0 <nice>
  4c:	01251a63          	bne	a0,s2,60 <main+0x60>
          if(nice(pid,5) != 1) break;
  50:	4595                	li	a1,5
  52:	8526                	mv	a0,s1
  54:	00000097          	auipc	ra,0x0
  58:	38c080e7          	jalr	908(ra) # 3e0 <nice>
  5c:	ff2502e3          	beq	a0,s2,40 <main+0x40>
        exit(0);
  60:	4501                	li	a0,0
  62:	00000097          	auipc	ra,0x0
  66:	2d6080e7          	jalr	726(ra) # 338 <exit>
    }
  }
  exit(1);
  6a:	4505                	li	a0,1
  6c:	00000097          	auipc	ra,0x0
  70:	2cc080e7          	jalr	716(ra) # 338 <exit>

0000000000000074 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  74:	1141                	addi	sp,sp,-16
  76:	e422                	sd	s0,8(sp)
  78:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7a:	87aa                	mv	a5,a0
  7c:	0585                	addi	a1,a1,1
  7e:	0785                	addi	a5,a5,1
  80:	fff5c703          	lbu	a4,-1(a1)
  84:	fee78fa3          	sb	a4,-1(a5)
  88:	fb75                	bnez	a4,7c <strcpy+0x8>
    ;
  return os;
}
  8a:	6422                	ld	s0,8(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret

0000000000000090 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  90:	1141                	addi	sp,sp,-16
  92:	e422                	sd	s0,8(sp)
  94:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  96:	00054783          	lbu	a5,0(a0)
  9a:	cb91                	beqz	a5,ae <strcmp+0x1e>
  9c:	0005c703          	lbu	a4,0(a1)
  a0:	00f71763          	bne	a4,a5,ae <strcmp+0x1e>
    p++, q++;
  a4:	0505                	addi	a0,a0,1
  a6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  a8:	00054783          	lbu	a5,0(a0)
  ac:	fbe5                	bnez	a5,9c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ae:	0005c503          	lbu	a0,0(a1)
}
  b2:	40a7853b          	subw	a0,a5,a0
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret

00000000000000bc <strlen>:

uint
strlen(const char *s)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c2:	00054783          	lbu	a5,0(a0)
  c6:	cf91                	beqz	a5,e2 <strlen+0x26>
  c8:	0505                	addi	a0,a0,1
  ca:	87aa                	mv	a5,a0
  cc:	4685                	li	a3,1
  ce:	9e89                	subw	a3,a3,a0
  d0:	00f6853b          	addw	a0,a3,a5
  d4:	0785                	addi	a5,a5,1
  d6:	fff7c703          	lbu	a4,-1(a5)
  da:	fb7d                	bnez	a4,d0 <strlen+0x14>
    ;
  return n;
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  for(n = 0; s[n]; n++)
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strlen+0x20>

00000000000000e6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ec:	ce09                	beqz	a2,106 <memset+0x20>
  ee:	87aa                	mv	a5,a0
  f0:	fff6071b          	addiw	a4,a2,-1
  f4:	1702                	slli	a4,a4,0x20
  f6:	9301                	srli	a4,a4,0x20
  f8:	0705                	addi	a4,a4,1
  fa:	972a                	add	a4,a4,a0
    cdst[i] = c;
  fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 100:	0785                	addi	a5,a5,1
 102:	fee79de3          	bne	a5,a4,fc <memset+0x16>
  }
  return dst;
}
 106:	6422                	ld	s0,8(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret

000000000000010c <strchr>:

char*
strchr(const char *s, char c)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e422                	sd	s0,8(sp)
 110:	0800                	addi	s0,sp,16
  for(; *s; s++)
 112:	00054783          	lbu	a5,0(a0)
 116:	cb99                	beqz	a5,12c <strchr+0x20>
    if(*s == c)
 118:	00f58763          	beq	a1,a5,126 <strchr+0x1a>
  for(; *s; s++)
 11c:	0505                	addi	a0,a0,1
 11e:	00054783          	lbu	a5,0(a0)
 122:	fbfd                	bnez	a5,118 <strchr+0xc>
      return (char*)s;
  return 0;
 124:	4501                	li	a0,0
}
 126:	6422                	ld	s0,8(sp)
 128:	0141                	addi	sp,sp,16
 12a:	8082                	ret
  return 0;
 12c:	4501                	li	a0,0
 12e:	bfe5                	j	126 <strchr+0x1a>

0000000000000130 <gets>:

char*
gets(char *buf, int max)
{
 130:	711d                	addi	sp,sp,-96
 132:	ec86                	sd	ra,88(sp)
 134:	e8a2                	sd	s0,80(sp)
 136:	e4a6                	sd	s1,72(sp)
 138:	e0ca                	sd	s2,64(sp)
 13a:	fc4e                	sd	s3,56(sp)
 13c:	f852                	sd	s4,48(sp)
 13e:	f456                	sd	s5,40(sp)
 140:	f05a                	sd	s6,32(sp)
 142:	ec5e                	sd	s7,24(sp)
 144:	1080                	addi	s0,sp,96
 146:	8baa                	mv	s7,a0
 148:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14a:	892a                	mv	s2,a0
 14c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 14e:	4aa9                	li	s5,10
 150:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 152:	89a6                	mv	s3,s1
 154:	2485                	addiw	s1,s1,1
 156:	0344d863          	bge	s1,s4,186 <gets+0x56>
    cc = read(0, &c, 1);
 15a:	4605                	li	a2,1
 15c:	faf40593          	addi	a1,s0,-81
 160:	4501                	li	a0,0
 162:	00000097          	auipc	ra,0x0
 166:	1ee080e7          	jalr	494(ra) # 350 <read>
    if(cc < 1)
 16a:	00a05e63          	blez	a0,186 <gets+0x56>
    buf[i++] = c;
 16e:	faf44783          	lbu	a5,-81(s0)
 172:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 176:	01578763          	beq	a5,s5,184 <gets+0x54>
 17a:	0905                	addi	s2,s2,1
 17c:	fd679be3          	bne	a5,s6,152 <gets+0x22>
  for(i=0; i+1 < max; ){
 180:	89a6                	mv	s3,s1
 182:	a011                	j	186 <gets+0x56>
 184:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 186:	99de                	add	s3,s3,s7
 188:	00098023          	sb	zero,0(s3)
  return buf;
}
 18c:	855e                	mv	a0,s7
 18e:	60e6                	ld	ra,88(sp)
 190:	6446                	ld	s0,80(sp)
 192:	64a6                	ld	s1,72(sp)
 194:	6906                	ld	s2,64(sp)
 196:	79e2                	ld	s3,56(sp)
 198:	7a42                	ld	s4,48(sp)
 19a:	7aa2                	ld	s5,40(sp)
 19c:	7b02                	ld	s6,32(sp)
 19e:	6be2                	ld	s7,24(sp)
 1a0:	6125                	addi	sp,sp,96
 1a2:	8082                	ret

00000000000001a4 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1aa:	00054603          	lbu	a2,0(a0)
 1ae:	fd06079b          	addiw	a5,a2,-48
 1b2:	0ff7f793          	andi	a5,a5,255
 1b6:	4725                	li	a4,9
 1b8:	02f76963          	bltu	a4,a5,1ea <atoi+0x46>
 1bc:	86aa                	mv	a3,a0
  n = 0;
 1be:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1c0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1c2:	0685                	addi	a3,a3,1
 1c4:	0025179b          	slliw	a5,a0,0x2
 1c8:	9fa9                	addw	a5,a5,a0
 1ca:	0017979b          	slliw	a5,a5,0x1
 1ce:	9fb1                	addw	a5,a5,a2
 1d0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d4:	0006c603          	lbu	a2,0(a3)
 1d8:	fd06071b          	addiw	a4,a2,-48
 1dc:	0ff77713          	andi	a4,a4,255
 1e0:	fee5f1e3          	bgeu	a1,a4,1c2 <atoi+0x1e>
  return n;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret
  n = 0;
 1ea:	4501                	li	a0,0
 1ec:	bfe5                	j	1e4 <atoi+0x40>

00000000000001ee <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ee:	1141                	addi	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f4:	02b57663          	bgeu	a0,a1,220 <memmove+0x32>
    while(n-- > 0)
 1f8:	02c05163          	blez	a2,21a <memmove+0x2c>
 1fc:	fff6079b          	addiw	a5,a2,-1
 200:	1782                	slli	a5,a5,0x20
 202:	9381                	srli	a5,a5,0x20
 204:	0785                	addi	a5,a5,1
 206:	97aa                	add	a5,a5,a0
  dst = vdst;
 208:	872a                	mv	a4,a0
      *dst++ = *src++;
 20a:	0585                	addi	a1,a1,1
 20c:	0705                	addi	a4,a4,1
 20e:	fff5c683          	lbu	a3,-1(a1)
 212:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 216:	fee79ae3          	bne	a5,a4,20a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
    dst += n;
 220:	00c50733          	add	a4,a0,a2
    src += n;
 224:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 226:	fec05ae3          	blez	a2,21a <memmove+0x2c>
 22a:	fff6079b          	addiw	a5,a2,-1
 22e:	1782                	slli	a5,a5,0x20
 230:	9381                	srli	a5,a5,0x20
 232:	fff7c793          	not	a5,a5
 236:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 238:	15fd                	addi	a1,a1,-1
 23a:	177d                	addi	a4,a4,-1
 23c:	0005c683          	lbu	a3,0(a1)
 240:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 244:	fee79ae3          	bne	a5,a4,238 <memmove+0x4a>
 248:	bfc9                	j	21a <memmove+0x2c>

000000000000024a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 250:	ca05                	beqz	a2,280 <memcmp+0x36>
 252:	fff6069b          	addiw	a3,a2,-1
 256:	1682                	slli	a3,a3,0x20
 258:	9281                	srli	a3,a3,0x20
 25a:	0685                	addi	a3,a3,1
 25c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 25e:	00054783          	lbu	a5,0(a0)
 262:	0005c703          	lbu	a4,0(a1)
 266:	00e79863          	bne	a5,a4,276 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 26a:	0505                	addi	a0,a0,1
    p2++;
 26c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 26e:	fed518e3          	bne	a0,a3,25e <memcmp+0x14>
  }
  return 0;
 272:	4501                	li	a0,0
 274:	a019                	j	27a <memcmp+0x30>
      return *p1 - *p2;
 276:	40e7853b          	subw	a0,a5,a4
}
 27a:	6422                	ld	s0,8(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
  return 0;
 280:	4501                	li	a0,0
 282:	bfe5                	j	27a <memcmp+0x30>

0000000000000284 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 284:	1141                	addi	sp,sp,-16
 286:	e406                	sd	ra,8(sp)
 288:	e022                	sd	s0,0(sp)
 28a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 28c:	00000097          	auipc	ra,0x0
 290:	f62080e7          	jalr	-158(ra) # 1ee <memmove>
}
 294:	60a2                	ld	ra,8(sp)
 296:	6402                	ld	s0,0(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret

000000000000029c <close>:

int close(int fd){
 29c:	1101                	addi	sp,sp,-32
 29e:	ec06                	sd	ra,24(sp)
 2a0:	e822                	sd	s0,16(sp)
 2a2:	e426                	sd	s1,8(sp)
 2a4:	1000                	addi	s0,sp,32
 2a6:	84aa                	mv	s1,a0
  fflush(fd);
 2a8:	00000097          	auipc	ra,0x0
 2ac:	2d4080e7          	jalr	724(ra) # 57c <fflush>
  char* buf = get_putc_buf(fd);
 2b0:	8526                	mv	a0,s1
 2b2:	00000097          	auipc	ra,0x0
 2b6:	14e080e7          	jalr	334(ra) # 400 <get_putc_buf>
  if(buf){
 2ba:	cd11                	beqz	a0,2d6 <close+0x3a>
    free(buf);
 2bc:	00000097          	auipc	ra,0x0
 2c0:	546080e7          	jalr	1350(ra) # 802 <free>
    putc_buf[fd] = 0;
 2c4:	00349713          	slli	a4,s1,0x3
 2c8:	00000797          	auipc	a5,0x0
 2cc:	6d078793          	addi	a5,a5,1744 # 998 <putc_buf>
 2d0:	97ba                	add	a5,a5,a4
 2d2:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 2d6:	8526                	mv	a0,s1
 2d8:	00000097          	auipc	ra,0x0
 2dc:	088080e7          	jalr	136(ra) # 360 <sclose>
}
 2e0:	60e2                	ld	ra,24(sp)
 2e2:	6442                	ld	s0,16(sp)
 2e4:	64a2                	ld	s1,8(sp)
 2e6:	6105                	addi	sp,sp,32
 2e8:	8082                	ret

00000000000002ea <stat>:
{
 2ea:	1101                	addi	sp,sp,-32
 2ec:	ec06                	sd	ra,24(sp)
 2ee:	e822                	sd	s0,16(sp)
 2f0:	e426                	sd	s1,8(sp)
 2f2:	e04a                	sd	s2,0(sp)
 2f4:	1000                	addi	s0,sp,32
 2f6:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 2f8:	4581                	li	a1,0
 2fa:	00000097          	auipc	ra,0x0
 2fe:	07e080e7          	jalr	126(ra) # 378 <open>
  if(fd < 0)
 302:	02054563          	bltz	a0,32c <stat+0x42>
 306:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 308:	85ca                	mv	a1,s2
 30a:	00000097          	auipc	ra,0x0
 30e:	086080e7          	jalr	134(ra) # 390 <fstat>
 312:	892a                	mv	s2,a0
  close(fd);
 314:	8526                	mv	a0,s1
 316:	00000097          	auipc	ra,0x0
 31a:	f86080e7          	jalr	-122(ra) # 29c <close>
}
 31e:	854a                	mv	a0,s2
 320:	60e2                	ld	ra,24(sp)
 322:	6442                	ld	s0,16(sp)
 324:	64a2                	ld	s1,8(sp)
 326:	6902                	ld	s2,0(sp)
 328:	6105                	addi	sp,sp,32
 32a:	8082                	ret
    return -1;
 32c:	597d                	li	s2,-1
 32e:	bfc5                	j	31e <stat+0x34>

0000000000000330 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 330:	4885                	li	a7,1
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <exit>:
.global exit
exit:
 li a7, SYS_exit
 338:	4889                	li	a7,2
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <wait>:
.global wait
wait:
 li a7, SYS_wait
 340:	488d                	li	a7,3
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 348:	4891                	li	a7,4
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <read>:
.global read
read:
 li a7, SYS_read
 350:	4895                	li	a7,5
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <write>:
.global write
write:
 li a7, SYS_write
 358:	48c1                	li	a7,16
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 360:	48d5                	li	a7,21
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <kill>:
.global kill
kill:
 li a7, SYS_kill
 368:	4899                	li	a7,6
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <exec>:
.global exec
exec:
 li a7, SYS_exec
 370:	489d                	li	a7,7
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <open>:
.global open
open:
 li a7, SYS_open
 378:	48bd                	li	a7,15
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 380:	48c5                	li	a7,17
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 388:	48c9                	li	a7,18
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 390:	48a1                	li	a7,8
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <link>:
.global link
link:
 li a7, SYS_link
 398:	48cd                	li	a7,19
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a0:	48d1                	li	a7,20
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a8:	48a5                	li	a7,9
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b0:	48a9                	li	a7,10
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b8:	48ad                	li	a7,11
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c0:	48b1                	li	a7,12
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c8:	48b5                	li	a7,13
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d0:	48b9                	li	a7,14
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 3d8:	48d9                	li	a7,22
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <nice>:
.global nice
nice:
 li a7, SYS_nice
 3e0:	48dd                	li	a7,23
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 3e8:	48e1                	li	a7,24
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 3f0:	48e5                	li	a7,25
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 3f8:	48e9                	li	a7,26
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 400:	1101                	addi	sp,sp,-32
 402:	ec06                	sd	ra,24(sp)
 404:	e822                	sd	s0,16(sp)
 406:	e426                	sd	s1,8(sp)
 408:	1000                	addi	s0,sp,32
 40a:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 40c:	00351713          	slli	a4,a0,0x3
 410:	00000797          	auipc	a5,0x0
 414:	58878793          	addi	a5,a5,1416 # 998 <putc_buf>
 418:	97ba                	add	a5,a5,a4
 41a:	6388                	ld	a0,0(a5)
  if(buf) {
 41c:	c511                	beqz	a0,428 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 41e:	60e2                	ld	ra,24(sp)
 420:	6442                	ld	s0,16(sp)
 422:	64a2                	ld	s1,8(sp)
 424:	6105                	addi	sp,sp,32
 426:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 428:	6505                	lui	a0,0x1
 42a:	00000097          	auipc	ra,0x0
 42e:	460080e7          	jalr	1120(ra) # 88a <malloc>
  putc_buf[fd] = buf;
 432:	00000797          	auipc	a5,0x0
 436:	56678793          	addi	a5,a5,1382 # 998 <putc_buf>
 43a:	00349713          	slli	a4,s1,0x3
 43e:	973e                	add	a4,a4,a5
 440:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 442:	048a                	slli	s1,s1,0x2
 444:	94be                	add	s1,s1,a5
 446:	3204a023          	sw	zero,800(s1)
  return buf;
 44a:	bfd1                	j	41e <get_putc_buf+0x1e>

000000000000044c <putc>:

static void
putc(int fd, char c)
{
 44c:	1101                	addi	sp,sp,-32
 44e:	ec06                	sd	ra,24(sp)
 450:	e822                	sd	s0,16(sp)
 452:	e426                	sd	s1,8(sp)
 454:	e04a                	sd	s2,0(sp)
 456:	1000                	addi	s0,sp,32
 458:	84aa                	mv	s1,a0
 45a:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 45c:	00000097          	auipc	ra,0x0
 460:	fa4080e7          	jalr	-92(ra) # 400 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 464:	00249793          	slli	a5,s1,0x2
 468:	00000717          	auipc	a4,0x0
 46c:	53070713          	addi	a4,a4,1328 # 998 <putc_buf>
 470:	973e                	add	a4,a4,a5
 472:	32072783          	lw	a5,800(a4)
 476:	0017869b          	addiw	a3,a5,1
 47a:	32d72023          	sw	a3,800(a4)
 47e:	97aa                	add	a5,a5,a0
 480:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 484:	47a9                	li	a5,10
 486:	02f90463          	beq	s2,a5,4ae <putc+0x62>
 48a:	00249713          	slli	a4,s1,0x2
 48e:	00000797          	auipc	a5,0x0
 492:	50a78793          	addi	a5,a5,1290 # 998 <putc_buf>
 496:	97ba                	add	a5,a5,a4
 498:	3207a703          	lw	a4,800(a5)
 49c:	6785                	lui	a5,0x1
 49e:	00f70863          	beq	a4,a5,4ae <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 4a2:	60e2                	ld	ra,24(sp)
 4a4:	6442                	ld	s0,16(sp)
 4a6:	64a2                	ld	s1,8(sp)
 4a8:	6902                	ld	s2,0(sp)
 4aa:	6105                	addi	sp,sp,32
 4ac:	8082                	ret
    write(fd, buf, putc_index[fd]);
 4ae:	00249793          	slli	a5,s1,0x2
 4b2:	00000917          	auipc	s2,0x0
 4b6:	4e690913          	addi	s2,s2,1254 # 998 <putc_buf>
 4ba:	993e                	add	s2,s2,a5
 4bc:	32092603          	lw	a2,800(s2)
 4c0:	85aa                	mv	a1,a0
 4c2:	8526                	mv	a0,s1
 4c4:	00000097          	auipc	ra,0x0
 4c8:	e94080e7          	jalr	-364(ra) # 358 <write>
    putc_index[fd] = 0;
 4cc:	32092023          	sw	zero,800(s2)
}
 4d0:	bfc9                	j	4a2 <putc+0x56>

00000000000004d2 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4d2:	7139                	addi	sp,sp,-64
 4d4:	fc06                	sd	ra,56(sp)
 4d6:	f822                	sd	s0,48(sp)
 4d8:	f426                	sd	s1,40(sp)
 4da:	f04a                	sd	s2,32(sp)
 4dc:	ec4e                	sd	s3,24(sp)
 4de:	0080                	addi	s0,sp,64
 4e0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e2:	c299                	beqz	a3,4e8 <printint+0x16>
 4e4:	0805c863          	bltz	a1,574 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e8:	2581                	sext.w	a1,a1
  neg = 0;
 4ea:	4881                	li	a7,0
 4ec:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f2:	2601                	sext.w	a2,a2
 4f4:	00000517          	auipc	a0,0x0
 4f8:	48450513          	addi	a0,a0,1156 # 978 <digits>
 4fc:	883a                	mv	a6,a4
 4fe:	2705                	addiw	a4,a4,1
 500:	02c5f7bb          	remuw	a5,a1,a2
 504:	1782                	slli	a5,a5,0x20
 506:	9381                	srli	a5,a5,0x20
 508:	97aa                	add	a5,a5,a0
 50a:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x1a8>
 50e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 512:	0005879b          	sext.w	a5,a1
 516:	02c5d5bb          	divuw	a1,a1,a2
 51a:	0685                	addi	a3,a3,1
 51c:	fec7f0e3          	bgeu	a5,a2,4fc <printint+0x2a>
  if(neg)
 520:	00088b63          	beqz	a7,536 <printint+0x64>
    buf[i++] = '-';
 524:	fd040793          	addi	a5,s0,-48
 528:	973e                	add	a4,a4,a5
 52a:	02d00793          	li	a5,45
 52e:	fef70823          	sb	a5,-16(a4)
 532:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 536:	02e05863          	blez	a4,566 <printint+0x94>
 53a:	fc040793          	addi	a5,s0,-64
 53e:	00e78933          	add	s2,a5,a4
 542:	fff78993          	addi	s3,a5,-1
 546:	99ba                	add	s3,s3,a4
 548:	377d                	addiw	a4,a4,-1
 54a:	1702                	slli	a4,a4,0x20
 54c:	9301                	srli	a4,a4,0x20
 54e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 552:	fff94583          	lbu	a1,-1(s2)
 556:	8526                	mv	a0,s1
 558:	00000097          	auipc	ra,0x0
 55c:	ef4080e7          	jalr	-268(ra) # 44c <putc>
  while(--i >= 0)
 560:	197d                	addi	s2,s2,-1
 562:	ff3918e3          	bne	s2,s3,552 <printint+0x80>
}
 566:	70e2                	ld	ra,56(sp)
 568:	7442                	ld	s0,48(sp)
 56a:	74a2                	ld	s1,40(sp)
 56c:	7902                	ld	s2,32(sp)
 56e:	69e2                	ld	s3,24(sp)
 570:	6121                	addi	sp,sp,64
 572:	8082                	ret
    x = -xx;
 574:	40b005bb          	negw	a1,a1
    neg = 1;
 578:	4885                	li	a7,1
    x = -xx;
 57a:	bf8d                	j	4ec <printint+0x1a>

000000000000057c <fflush>:
void fflush(int fd){
 57c:	1101                	addi	sp,sp,-32
 57e:	ec06                	sd	ra,24(sp)
 580:	e822                	sd	s0,16(sp)
 582:	e426                	sd	s1,8(sp)
 584:	e04a                	sd	s2,0(sp)
 586:	1000                	addi	s0,sp,32
 588:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 58a:	00000097          	auipc	ra,0x0
 58e:	e76080e7          	jalr	-394(ra) # 400 <get_putc_buf>
 592:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 594:	00291793          	slli	a5,s2,0x2
 598:	00000497          	auipc	s1,0x0
 59c:	40048493          	addi	s1,s1,1024 # 998 <putc_buf>
 5a0:	94be                	add	s1,s1,a5
 5a2:	3204a603          	lw	a2,800(s1)
 5a6:	854a                	mv	a0,s2
 5a8:	00000097          	auipc	ra,0x0
 5ac:	db0080e7          	jalr	-592(ra) # 358 <write>
  putc_index[fd] = 0;
 5b0:	3204a023          	sw	zero,800(s1)
}
 5b4:	60e2                	ld	ra,24(sp)
 5b6:	6442                	ld	s0,16(sp)
 5b8:	64a2                	ld	s1,8(sp)
 5ba:	6902                	ld	s2,0(sp)
 5bc:	6105                	addi	sp,sp,32
 5be:	8082                	ret

00000000000005c0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c0:	7119                	addi	sp,sp,-128
 5c2:	fc86                	sd	ra,120(sp)
 5c4:	f8a2                	sd	s0,112(sp)
 5c6:	f4a6                	sd	s1,104(sp)
 5c8:	f0ca                	sd	s2,96(sp)
 5ca:	ecce                	sd	s3,88(sp)
 5cc:	e8d2                	sd	s4,80(sp)
 5ce:	e4d6                	sd	s5,72(sp)
 5d0:	e0da                	sd	s6,64(sp)
 5d2:	fc5e                	sd	s7,56(sp)
 5d4:	f862                	sd	s8,48(sp)
 5d6:	f466                	sd	s9,40(sp)
 5d8:	f06a                	sd	s10,32(sp)
 5da:	ec6e                	sd	s11,24(sp)
 5dc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5de:	0005c903          	lbu	s2,0(a1)
 5e2:	18090f63          	beqz	s2,780 <vprintf+0x1c0>
 5e6:	8aaa                	mv	s5,a0
 5e8:	8b32                	mv	s6,a2
 5ea:	00158493          	addi	s1,a1,1
  state = 0;
 5ee:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5f0:	02500a13          	li	s4,37
      if(c == 'd'){
 5f4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5f8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5fc:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 600:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 604:	00000b97          	auipc	s7,0x0
 608:	374b8b93          	addi	s7,s7,884 # 978 <digits>
 60c:	a839                	j	62a <vprintf+0x6a>
        putc(fd, c);
 60e:	85ca                	mv	a1,s2
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	e3a080e7          	jalr	-454(ra) # 44c <putc>
 61a:	a019                	j	620 <vprintf+0x60>
    } else if(state == '%'){
 61c:	01498f63          	beq	s3,s4,63a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 620:	0485                	addi	s1,s1,1
 622:	fff4c903          	lbu	s2,-1(s1)
 626:	14090d63          	beqz	s2,780 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 62a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 62e:	fe0997e3          	bnez	s3,61c <vprintf+0x5c>
      if(c == '%'){
 632:	fd479ee3          	bne	a5,s4,60e <vprintf+0x4e>
        state = '%';
 636:	89be                	mv	s3,a5
 638:	b7e5                	j	620 <vprintf+0x60>
      if(c == 'd'){
 63a:	05878063          	beq	a5,s8,67a <vprintf+0xba>
      } else if(c == 'l') {
 63e:	05978c63          	beq	a5,s9,696 <vprintf+0xd6>
      } else if(c == 'x') {
 642:	07a78863          	beq	a5,s10,6b2 <vprintf+0xf2>
      } else if(c == 'p') {
 646:	09b78463          	beq	a5,s11,6ce <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 64a:	07300713          	li	a4,115
 64e:	0ce78663          	beq	a5,a4,71a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 652:	06300713          	li	a4,99
 656:	0ee78e63          	beq	a5,a4,752 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 65a:	11478863          	beq	a5,s4,76a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 65e:	85d2                	mv	a1,s4
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	dea080e7          	jalr	-534(ra) # 44c <putc>
        putc(fd, c);
 66a:	85ca                	mv	a1,s2
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	dde080e7          	jalr	-546(ra) # 44c <putc>
      }
      state = 0;
 676:	4981                	li	s3,0
 678:	b765                	j	620 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 67a:	008b0913          	addi	s2,s6,8
 67e:	4685                	li	a3,1
 680:	4629                	li	a2,10
 682:	000b2583          	lw	a1,0(s6)
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	e4a080e7          	jalr	-438(ra) # 4d2 <printint>
 690:	8b4a                	mv	s6,s2
      state = 0;
 692:	4981                	li	s3,0
 694:	b771                	j	620 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 696:	008b0913          	addi	s2,s6,8
 69a:	4681                	li	a3,0
 69c:	4629                	li	a2,10
 69e:	000b2583          	lw	a1,0(s6)
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	e2e080e7          	jalr	-466(ra) # 4d2 <printint>
 6ac:	8b4a                	mv	s6,s2
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	bf85                	j	620 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6b2:	008b0913          	addi	s2,s6,8
 6b6:	4681                	li	a3,0
 6b8:	4641                	li	a2,16
 6ba:	000b2583          	lw	a1,0(s6)
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	e12080e7          	jalr	-494(ra) # 4d2 <printint>
 6c8:	8b4a                	mv	s6,s2
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	bf91                	j	620 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6ce:	008b0793          	addi	a5,s6,8
 6d2:	f8f43423          	sd	a5,-120(s0)
 6d6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6da:	03000593          	li	a1,48
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	d6c080e7          	jalr	-660(ra) # 44c <putc>
  putc(fd, 'x');
 6e8:	85ea                	mv	a1,s10
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	d60080e7          	jalr	-672(ra) # 44c <putc>
 6f4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f6:	03c9d793          	srli	a5,s3,0x3c
 6fa:	97de                	add	a5,a5,s7
 6fc:	0007c583          	lbu	a1,0(a5)
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	d4a080e7          	jalr	-694(ra) # 44c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70a:	0992                	slli	s3,s3,0x4
 70c:	397d                	addiw	s2,s2,-1
 70e:	fe0914e3          	bnez	s2,6f6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 712:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 716:	4981                	li	s3,0
 718:	b721                	j	620 <vprintf+0x60>
        s = va_arg(ap, char*);
 71a:	008b0993          	addi	s3,s6,8
 71e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 722:	02090163          	beqz	s2,744 <vprintf+0x184>
        while(*s != 0){
 726:	00094583          	lbu	a1,0(s2)
 72a:	c9a1                	beqz	a1,77a <vprintf+0x1ba>
          putc(fd, *s);
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	d1e080e7          	jalr	-738(ra) # 44c <putc>
          s++;
 736:	0905                	addi	s2,s2,1
        while(*s != 0){
 738:	00094583          	lbu	a1,0(s2)
 73c:	f9e5                	bnez	a1,72c <vprintf+0x16c>
        s = va_arg(ap, char*);
 73e:	8b4e                	mv	s6,s3
      state = 0;
 740:	4981                	li	s3,0
 742:	bdf9                	j	620 <vprintf+0x60>
          s = "(null)";
 744:	00000917          	auipc	s2,0x0
 748:	22c90913          	addi	s2,s2,556 # 970 <malloc+0xe6>
        while(*s != 0){
 74c:	02800593          	li	a1,40
 750:	bff1                	j	72c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 752:	008b0913          	addi	s2,s6,8
 756:	000b4583          	lbu	a1,0(s6)
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	cf0080e7          	jalr	-784(ra) # 44c <putc>
 764:	8b4a                	mv	s6,s2
      state = 0;
 766:	4981                	li	s3,0
 768:	bd65                	j	620 <vprintf+0x60>
        putc(fd, c);
 76a:	85d2                	mv	a1,s4
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	cde080e7          	jalr	-802(ra) # 44c <putc>
      state = 0;
 776:	4981                	li	s3,0
 778:	b565                	j	620 <vprintf+0x60>
        s = va_arg(ap, char*);
 77a:	8b4e                	mv	s6,s3
      state = 0;
 77c:	4981                	li	s3,0
 77e:	b54d                	j	620 <vprintf+0x60>
    }
  }
}
 780:	70e6                	ld	ra,120(sp)
 782:	7446                	ld	s0,112(sp)
 784:	74a6                	ld	s1,104(sp)
 786:	7906                	ld	s2,96(sp)
 788:	69e6                	ld	s3,88(sp)
 78a:	6a46                	ld	s4,80(sp)
 78c:	6aa6                	ld	s5,72(sp)
 78e:	6b06                	ld	s6,64(sp)
 790:	7be2                	ld	s7,56(sp)
 792:	7c42                	ld	s8,48(sp)
 794:	7ca2                	ld	s9,40(sp)
 796:	7d02                	ld	s10,32(sp)
 798:	6de2                	ld	s11,24(sp)
 79a:	6109                	addi	sp,sp,128
 79c:	8082                	ret

000000000000079e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 79e:	715d                	addi	sp,sp,-80
 7a0:	ec06                	sd	ra,24(sp)
 7a2:	e822                	sd	s0,16(sp)
 7a4:	1000                	addi	s0,sp,32
 7a6:	e010                	sd	a2,0(s0)
 7a8:	e414                	sd	a3,8(s0)
 7aa:	e818                	sd	a4,16(s0)
 7ac:	ec1c                	sd	a5,24(s0)
 7ae:	03043023          	sd	a6,32(s0)
 7b2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ba:	8622                	mv	a2,s0
 7bc:	00000097          	auipc	ra,0x0
 7c0:	e04080e7          	jalr	-508(ra) # 5c0 <vprintf>
}
 7c4:	60e2                	ld	ra,24(sp)
 7c6:	6442                	ld	s0,16(sp)
 7c8:	6161                	addi	sp,sp,80
 7ca:	8082                	ret

00000000000007cc <printf>:

void
printf(const char *fmt, ...)
{
 7cc:	711d                	addi	sp,sp,-96
 7ce:	ec06                	sd	ra,24(sp)
 7d0:	e822                	sd	s0,16(sp)
 7d2:	1000                	addi	s0,sp,32
 7d4:	e40c                	sd	a1,8(s0)
 7d6:	e810                	sd	a2,16(s0)
 7d8:	ec14                	sd	a3,24(s0)
 7da:	f018                	sd	a4,32(s0)
 7dc:	f41c                	sd	a5,40(s0)
 7de:	03043823          	sd	a6,48(s0)
 7e2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e6:	00840613          	addi	a2,s0,8
 7ea:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ee:	85aa                	mv	a1,a0
 7f0:	4505                	li	a0,1
 7f2:	00000097          	auipc	ra,0x0
 7f6:	dce080e7          	jalr	-562(ra) # 5c0 <vprintf>
}
 7fa:	60e2                	ld	ra,24(sp)
 7fc:	6442                	ld	s0,16(sp)
 7fe:	6125                	addi	sp,sp,96
 800:	8082                	ret

0000000000000802 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 802:	1141                	addi	sp,sp,-16
 804:	e422                	sd	s0,8(sp)
 806:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 808:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80c:	00000797          	auipc	a5,0x0
 810:	1847b783          	ld	a5,388(a5) # 990 <freep>
 814:	a805                	j	844 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 816:	4618                	lw	a4,8(a2)
 818:	9db9                	addw	a1,a1,a4
 81a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 81e:	6398                	ld	a4,0(a5)
 820:	6318                	ld	a4,0(a4)
 822:	fee53823          	sd	a4,-16(a0)
 826:	a091                	j	86a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 828:	ff852703          	lw	a4,-8(a0)
 82c:	9e39                	addw	a2,a2,a4
 82e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 830:	ff053703          	ld	a4,-16(a0)
 834:	e398                	sd	a4,0(a5)
 836:	a099                	j	87c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 838:	6398                	ld	a4,0(a5)
 83a:	00e7e463          	bltu	a5,a4,842 <free+0x40>
 83e:	00e6ea63          	bltu	a3,a4,852 <free+0x50>
{
 842:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 844:	fed7fae3          	bgeu	a5,a3,838 <free+0x36>
 848:	6398                	ld	a4,0(a5)
 84a:	00e6e463          	bltu	a3,a4,852 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84e:	fee7eae3          	bltu	a5,a4,842 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 852:	ff852583          	lw	a1,-8(a0)
 856:	6390                	ld	a2,0(a5)
 858:	02059713          	slli	a4,a1,0x20
 85c:	9301                	srli	a4,a4,0x20
 85e:	0712                	slli	a4,a4,0x4
 860:	9736                	add	a4,a4,a3
 862:	fae60ae3          	beq	a2,a4,816 <free+0x14>
    bp->s.ptr = p->s.ptr;
 866:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 86a:	4790                	lw	a2,8(a5)
 86c:	02061713          	slli	a4,a2,0x20
 870:	9301                	srli	a4,a4,0x20
 872:	0712                	slli	a4,a4,0x4
 874:	973e                	add	a4,a4,a5
 876:	fae689e3          	beq	a3,a4,828 <free+0x26>
  } else
    p->s.ptr = bp;
 87a:	e394                	sd	a3,0(a5)
  freep = p;
 87c:	00000717          	auipc	a4,0x0
 880:	10f73a23          	sd	a5,276(a4) # 990 <freep>
}
 884:	6422                	ld	s0,8(sp)
 886:	0141                	addi	sp,sp,16
 888:	8082                	ret

000000000000088a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 88a:	7139                	addi	sp,sp,-64
 88c:	fc06                	sd	ra,56(sp)
 88e:	f822                	sd	s0,48(sp)
 890:	f426                	sd	s1,40(sp)
 892:	f04a                	sd	s2,32(sp)
 894:	ec4e                	sd	s3,24(sp)
 896:	e852                	sd	s4,16(sp)
 898:	e456                	sd	s5,8(sp)
 89a:	e05a                	sd	s6,0(sp)
 89c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89e:	02051493          	slli	s1,a0,0x20
 8a2:	9081                	srli	s1,s1,0x20
 8a4:	04bd                	addi	s1,s1,15
 8a6:	8091                	srli	s1,s1,0x4
 8a8:	0014899b          	addiw	s3,s1,1
 8ac:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ae:	00000517          	auipc	a0,0x0
 8b2:	0e253503          	ld	a0,226(a0) # 990 <freep>
 8b6:	c515                	beqz	a0,8e2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ba:	4798                	lw	a4,8(a5)
 8bc:	02977f63          	bgeu	a4,s1,8fa <malloc+0x70>
 8c0:	8a4e                	mv	s4,s3
 8c2:	0009871b          	sext.w	a4,s3
 8c6:	6685                	lui	a3,0x1
 8c8:	00d77363          	bgeu	a4,a3,8ce <malloc+0x44>
 8cc:	6a05                	lui	s4,0x1
 8ce:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d6:	00000917          	auipc	s2,0x0
 8da:	0ba90913          	addi	s2,s2,186 # 990 <freep>
  if(p == (char*)-1)
 8de:	5afd                	li	s5,-1
 8e0:	a88d                	j	952 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8e2:	00000797          	auipc	a5,0x0
 8e6:	56678793          	addi	a5,a5,1382 # e48 <base>
 8ea:	00000717          	auipc	a4,0x0
 8ee:	0af73323          	sd	a5,166(a4) # 990 <freep>
 8f2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f8:	b7e1                	j	8c0 <malloc+0x36>
      if(p->s.size == nunits)
 8fa:	02e48b63          	beq	s1,a4,930 <malloc+0xa6>
        p->s.size -= nunits;
 8fe:	4137073b          	subw	a4,a4,s3
 902:	c798                	sw	a4,8(a5)
        p += p->s.size;
 904:	1702                	slli	a4,a4,0x20
 906:	9301                	srli	a4,a4,0x20
 908:	0712                	slli	a4,a4,0x4
 90a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 90c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 910:	00000717          	auipc	a4,0x0
 914:	08a73023          	sd	a0,128(a4) # 990 <freep>
      return (void*)(p + 1);
 918:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 91c:	70e2                	ld	ra,56(sp)
 91e:	7442                	ld	s0,48(sp)
 920:	74a2                	ld	s1,40(sp)
 922:	7902                	ld	s2,32(sp)
 924:	69e2                	ld	s3,24(sp)
 926:	6a42                	ld	s4,16(sp)
 928:	6aa2                	ld	s5,8(sp)
 92a:	6b02                	ld	s6,0(sp)
 92c:	6121                	addi	sp,sp,64
 92e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 930:	6398                	ld	a4,0(a5)
 932:	e118                	sd	a4,0(a0)
 934:	bff1                	j	910 <malloc+0x86>
  hp->s.size = nu;
 936:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 93a:	0541                	addi	a0,a0,16
 93c:	00000097          	auipc	ra,0x0
 940:	ec6080e7          	jalr	-314(ra) # 802 <free>
  return freep;
 944:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 948:	d971                	beqz	a0,91c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 94a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 94c:	4798                	lw	a4,8(a5)
 94e:	fa9776e3          	bgeu	a4,s1,8fa <malloc+0x70>
    if(p == freep)
 952:	00093703          	ld	a4,0(s2)
 956:	853e                	mv	a0,a5
 958:	fef719e3          	bne	a4,a5,94a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 95c:	8552                	mv	a0,s4
 95e:	00000097          	auipc	ra,0x0
 962:	a62080e7          	jalr	-1438(ra) # 3c0 <sbrk>
  if(p == (char*)-1)
 966:	fd5518e3          	bne	a0,s5,936 <malloc+0xac>
        return 0;
 96a:	4501                	li	a0,0
 96c:	bf45                	j	91c <malloc+0x92>
