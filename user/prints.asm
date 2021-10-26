
user/_prints:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	0080                	addi	s0,sp,64
  int pid;
  for(int i = 0; i < 4; i++){
   c:	4481                	li	s1,0
   e:	4911                	li	s2,4
    pid = fork();
  10:	00000097          	auipc	ra,0x0
  14:	328080e7          	jalr	808(ra) # 338 <fork>
    if(pid == 0){
  18:	c10d                	beqz	a0,3a <main+0x3a>
  for(int i = 0; i < 4; i++){
  1a:	2485                	addiw	s1,s1,1
  1c:	ff249ae3          	bne	s1,s2,10 <main+0x10>
      argv[1][0] = 'A' + i;
      exec("/print", argv);
      exit(1);
    }
  }
  while(wait(0) != -1);
  20:	54fd                	li	s1,-1
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	324080e7          	jalr	804(ra) # 348 <wait>
  2c:	fe951be3          	bne	a0,s1,22 <main+0x22>
  exit(0);
  30:	4501                	li	a0,0
  32:	00000097          	auipc	ra,0x0
  36:	30e080e7          	jalr	782(ra) # 340 <exit>
      char* argv[] = {"print", "X", 0};
  3a:	00001797          	auipc	a5,0x1
  3e:	93e78793          	addi	a5,a5,-1730 # 978 <malloc+0xe6>
  42:	fcf43423          	sd	a5,-56(s0)
  46:	00001797          	auipc	a5,0x1
  4a:	93a78793          	addi	a5,a5,-1734 # 980 <malloc+0xee>
  4e:	fcf43823          	sd	a5,-48(s0)
  52:	fc043c23          	sd	zero,-40(s0)
      argv[1][0] = 'A' + i;
  56:	0414849b          	addiw	s1,s1,65
  5a:	00978023          	sb	s1,0(a5)
      exec("/print", argv);
  5e:	fc840593          	addi	a1,s0,-56
  62:	00001517          	auipc	a0,0x1
  66:	92650513          	addi	a0,a0,-1754 # 988 <malloc+0xf6>
  6a:	00000097          	auipc	ra,0x0
  6e:	30e080e7          	jalr	782(ra) # 378 <exec>
      exit(1);
  72:	4505                	li	a0,1
  74:	00000097          	auipc	ra,0x0
  78:	2cc080e7          	jalr	716(ra) # 340 <exit>

000000000000007c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  82:	87aa                	mv	a5,a0
  84:	0585                	addi	a1,a1,1
  86:	0785                	addi	a5,a5,1
  88:	fff5c703          	lbu	a4,-1(a1)
  8c:	fee78fa3          	sb	a4,-1(a5)
  90:	fb75                	bnez	a4,84 <strcpy+0x8>
    ;
  return os;
}
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret

0000000000000098 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  98:	1141                	addi	sp,sp,-16
  9a:	e422                	sd	s0,8(sp)
  9c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  9e:	00054783          	lbu	a5,0(a0)
  a2:	cb91                	beqz	a5,b6 <strcmp+0x1e>
  a4:	0005c703          	lbu	a4,0(a1)
  a8:	00f71763          	bne	a4,a5,b6 <strcmp+0x1e>
    p++, q++;
  ac:	0505                	addi	a0,a0,1
  ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b0:	00054783          	lbu	a5,0(a0)
  b4:	fbe5                	bnez	a5,a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b6:	0005c503          	lbu	a0,0(a1)
}
  ba:	40a7853b          	subw	a0,a5,a0
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strlen>:

uint
strlen(const char *s)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cf91                	beqz	a5,ea <strlen+0x26>
  d0:	0505                	addi	a0,a0,1
  d2:	87aa                	mv	a5,a0
  d4:	4685                	li	a3,1
  d6:	9e89                	subw	a3,a3,a0
  d8:	00f6853b          	addw	a0,a3,a5
  dc:	0785                	addi	a5,a5,1
  de:	fff7c703          	lbu	a4,-1(a5)
  e2:	fb7d                	bnez	a4,d8 <strlen+0x14>
    ;
  return n;
}
  e4:	6422                	ld	s0,8(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret
  for(n = 0; s[n]; n++)
  ea:	4501                	li	a0,0
  ec:	bfe5                	j	e4 <strlen+0x20>

00000000000000ee <memset>:

void*
memset(void *dst, int c, uint n)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f4:	ce09                	beqz	a2,10e <memset+0x20>
  f6:	87aa                	mv	a5,a0
  f8:	fff6071b          	addiw	a4,a2,-1
  fc:	1702                	slli	a4,a4,0x20
  fe:	9301                	srli	a4,a4,0x20
 100:	0705                	addi	a4,a4,1
 102:	972a                	add	a4,a4,a0
    cdst[i] = c;
 104:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 108:	0785                	addi	a5,a5,1
 10a:	fee79de3          	bne	a5,a4,104 <memset+0x16>
  }
  return dst;
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strchr>:

char*
strchr(const char *s, char c)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  for(; *s; s++)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cb99                	beqz	a5,134 <strchr+0x20>
    if(*s == c)
 120:	00f58763          	beq	a1,a5,12e <strchr+0x1a>
  for(; *s; s++)
 124:	0505                	addi	a0,a0,1
 126:	00054783          	lbu	a5,0(a0)
 12a:	fbfd                	bnez	a5,120 <strchr+0xc>
      return (char*)s;
  return 0;
 12c:	4501                	li	a0,0
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret
  return 0;
 134:	4501                	li	a0,0
 136:	bfe5                	j	12e <strchr+0x1a>

0000000000000138 <gets>:

char*
gets(char *buf, int max)
{
 138:	711d                	addi	sp,sp,-96
 13a:	ec86                	sd	ra,88(sp)
 13c:	e8a2                	sd	s0,80(sp)
 13e:	e4a6                	sd	s1,72(sp)
 140:	e0ca                	sd	s2,64(sp)
 142:	fc4e                	sd	s3,56(sp)
 144:	f852                	sd	s4,48(sp)
 146:	f456                	sd	s5,40(sp)
 148:	f05a                	sd	s6,32(sp)
 14a:	ec5e                	sd	s7,24(sp)
 14c:	1080                	addi	s0,sp,96
 14e:	8baa                	mv	s7,a0
 150:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 152:	892a                	mv	s2,a0
 154:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 156:	4aa9                	li	s5,10
 158:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15a:	89a6                	mv	s3,s1
 15c:	2485                	addiw	s1,s1,1
 15e:	0344d863          	bge	s1,s4,18e <gets+0x56>
    cc = read(0, &c, 1);
 162:	4605                	li	a2,1
 164:	faf40593          	addi	a1,s0,-81
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	1ee080e7          	jalr	494(ra) # 358 <read>
    if(cc < 1)
 172:	00a05e63          	blez	a0,18e <gets+0x56>
    buf[i++] = c;
 176:	faf44783          	lbu	a5,-81(s0)
 17a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17e:	01578763          	beq	a5,s5,18c <gets+0x54>
 182:	0905                	addi	s2,s2,1
 184:	fd679be3          	bne	a5,s6,15a <gets+0x22>
  for(i=0; i+1 < max; ){
 188:	89a6                	mv	s3,s1
 18a:	a011                	j	18e <gets+0x56>
 18c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18e:	99de                	add	s3,s3,s7
 190:	00098023          	sb	zero,0(s3)
  return buf;
}
 194:	855e                	mv	a0,s7
 196:	60e6                	ld	ra,88(sp)
 198:	6446                	ld	s0,80(sp)
 19a:	64a6                	ld	s1,72(sp)
 19c:	6906                	ld	s2,64(sp)
 19e:	79e2                	ld	s3,56(sp)
 1a0:	7a42                	ld	s4,48(sp)
 1a2:	7aa2                	ld	s5,40(sp)
 1a4:	7b02                	ld	s6,32(sp)
 1a6:	6be2                	ld	s7,24(sp)
 1a8:	6125                	addi	sp,sp,96
 1aa:	8082                	ret

00000000000001ac <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1b2:	00054603          	lbu	a2,0(a0)
 1b6:	fd06079b          	addiw	a5,a2,-48
 1ba:	0ff7f793          	andi	a5,a5,255
 1be:	4725                	li	a4,9
 1c0:	02f76963          	bltu	a4,a5,1f2 <atoi+0x46>
 1c4:	86aa                	mv	a3,a0
  n = 0;
 1c6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1c8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1ca:	0685                	addi	a3,a3,1
 1cc:	0025179b          	slliw	a5,a0,0x2
 1d0:	9fa9                	addw	a5,a5,a0
 1d2:	0017979b          	slliw	a5,a5,0x1
 1d6:	9fb1                	addw	a5,a5,a2
 1d8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1dc:	0006c603          	lbu	a2,0(a3)
 1e0:	fd06071b          	addiw	a4,a2,-48
 1e4:	0ff77713          	andi	a4,a4,255
 1e8:	fee5f1e3          	bgeu	a1,a4,1ca <atoi+0x1e>
  return n;
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret
  n = 0;
 1f2:	4501                	li	a0,0
 1f4:	bfe5                	j	1ec <atoi+0x40>

00000000000001f6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1fc:	02b57663          	bgeu	a0,a1,228 <memmove+0x32>
    while(n-- > 0)
 200:	02c05163          	blez	a2,222 <memmove+0x2c>
 204:	fff6079b          	addiw	a5,a2,-1
 208:	1782                	slli	a5,a5,0x20
 20a:	9381                	srli	a5,a5,0x20
 20c:	0785                	addi	a5,a5,1
 20e:	97aa                	add	a5,a5,a0
  dst = vdst;
 210:	872a                	mv	a4,a0
      *dst++ = *src++;
 212:	0585                	addi	a1,a1,1
 214:	0705                	addi	a4,a4,1
 216:	fff5c683          	lbu	a3,-1(a1)
 21a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 21e:	fee79ae3          	bne	a5,a4,212 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
    dst += n;
 228:	00c50733          	add	a4,a0,a2
    src += n;
 22c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 22e:	fec05ae3          	blez	a2,222 <memmove+0x2c>
 232:	fff6079b          	addiw	a5,a2,-1
 236:	1782                	slli	a5,a5,0x20
 238:	9381                	srli	a5,a5,0x20
 23a:	fff7c793          	not	a5,a5
 23e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 240:	15fd                	addi	a1,a1,-1
 242:	177d                	addi	a4,a4,-1
 244:	0005c683          	lbu	a3,0(a1)
 248:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 24c:	fee79ae3          	bne	a5,a4,240 <memmove+0x4a>
 250:	bfc9                	j	222 <memmove+0x2c>

0000000000000252 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 258:	ca05                	beqz	a2,288 <memcmp+0x36>
 25a:	fff6069b          	addiw	a3,a2,-1
 25e:	1682                	slli	a3,a3,0x20
 260:	9281                	srli	a3,a3,0x20
 262:	0685                	addi	a3,a3,1
 264:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 266:	00054783          	lbu	a5,0(a0)
 26a:	0005c703          	lbu	a4,0(a1)
 26e:	00e79863          	bne	a5,a4,27e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 272:	0505                	addi	a0,a0,1
    p2++;
 274:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 276:	fed518e3          	bne	a0,a3,266 <memcmp+0x14>
  }
  return 0;
 27a:	4501                	li	a0,0
 27c:	a019                	j	282 <memcmp+0x30>
      return *p1 - *p2;
 27e:	40e7853b          	subw	a0,a5,a4
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret
  return 0;
 288:	4501                	li	a0,0
 28a:	bfe5                	j	282 <memcmp+0x30>

000000000000028c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e406                	sd	ra,8(sp)
 290:	e022                	sd	s0,0(sp)
 292:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 294:	00000097          	auipc	ra,0x0
 298:	f62080e7          	jalr	-158(ra) # 1f6 <memmove>
}
 29c:	60a2                	ld	ra,8(sp)
 29e:	6402                	ld	s0,0(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret

00000000000002a4 <close>:

int close(int fd){
 2a4:	1101                	addi	sp,sp,-32
 2a6:	ec06                	sd	ra,24(sp)
 2a8:	e822                	sd	s0,16(sp)
 2aa:	e426                	sd	s1,8(sp)
 2ac:	1000                	addi	s0,sp,32
 2ae:	84aa                	mv	s1,a0
  fflush(fd);
 2b0:	00000097          	auipc	ra,0x0
 2b4:	2d4080e7          	jalr	724(ra) # 584 <fflush>
  char* buf = get_putc_buf(fd);
 2b8:	8526                	mv	a0,s1
 2ba:	00000097          	auipc	ra,0x0
 2be:	14e080e7          	jalr	334(ra) # 408 <get_putc_buf>
  if(buf){
 2c2:	cd11                	beqz	a0,2de <close+0x3a>
    free(buf);
 2c4:	00000097          	auipc	ra,0x0
 2c8:	546080e7          	jalr	1350(ra) # 80a <free>
    putc_buf[fd] = 0;
 2cc:	00349713          	slli	a4,s1,0x3
 2d0:	00000797          	auipc	a5,0x0
 2d4:	6e878793          	addi	a5,a5,1768 # 9b8 <putc_buf>
 2d8:	97ba                	add	a5,a5,a4
 2da:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 2de:	8526                	mv	a0,s1
 2e0:	00000097          	auipc	ra,0x0
 2e4:	088080e7          	jalr	136(ra) # 368 <sclose>
}
 2e8:	60e2                	ld	ra,24(sp)
 2ea:	6442                	ld	s0,16(sp)
 2ec:	64a2                	ld	s1,8(sp)
 2ee:	6105                	addi	sp,sp,32
 2f0:	8082                	ret

00000000000002f2 <stat>:
{
 2f2:	1101                	addi	sp,sp,-32
 2f4:	ec06                	sd	ra,24(sp)
 2f6:	e822                	sd	s0,16(sp)
 2f8:	e426                	sd	s1,8(sp)
 2fa:	e04a                	sd	s2,0(sp)
 2fc:	1000                	addi	s0,sp,32
 2fe:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 300:	4581                	li	a1,0
 302:	00000097          	auipc	ra,0x0
 306:	07e080e7          	jalr	126(ra) # 380 <open>
  if(fd < 0)
 30a:	02054563          	bltz	a0,334 <stat+0x42>
 30e:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 310:	85ca                	mv	a1,s2
 312:	00000097          	auipc	ra,0x0
 316:	086080e7          	jalr	134(ra) # 398 <fstat>
 31a:	892a                	mv	s2,a0
  close(fd);
 31c:	8526                	mv	a0,s1
 31e:	00000097          	auipc	ra,0x0
 322:	f86080e7          	jalr	-122(ra) # 2a4 <close>
}
 326:	854a                	mv	a0,s2
 328:	60e2                	ld	ra,24(sp)
 32a:	6442                	ld	s0,16(sp)
 32c:	64a2                	ld	s1,8(sp)
 32e:	6902                	ld	s2,0(sp)
 330:	6105                	addi	sp,sp,32
 332:	8082                	ret
    return -1;
 334:	597d                	li	s2,-1
 336:	bfc5                	j	326 <stat+0x34>

0000000000000338 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 338:	4885                	li	a7,1
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <exit>:
.global exit
exit:
 li a7, SYS_exit
 340:	4889                	li	a7,2
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <wait>:
.global wait
wait:
 li a7, SYS_wait
 348:	488d                	li	a7,3
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 350:	4891                	li	a7,4
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <read>:
.global read
read:
 li a7, SYS_read
 358:	4895                	li	a7,5
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <write>:
.global write
write:
 li a7, SYS_write
 360:	48c1                	li	a7,16
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 368:	48d5                	li	a7,21
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <kill>:
.global kill
kill:
 li a7, SYS_kill
 370:	4899                	li	a7,6
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exec>:
.global exec
exec:
 li a7, SYS_exec
 378:	489d                	li	a7,7
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <open>:
.global open
open:
 li a7, SYS_open
 380:	48bd                	li	a7,15
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 388:	48c5                	li	a7,17
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 390:	48c9                	li	a7,18
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 398:	48a1                	li	a7,8
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <link>:
.global link
link:
 li a7, SYS_link
 3a0:	48cd                	li	a7,19
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a8:	48d1                	li	a7,20
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b0:	48a5                	li	a7,9
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b8:	48a9                	li	a7,10
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c0:	48ad                	li	a7,11
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c8:	48b1                	li	a7,12
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d0:	48b5                	li	a7,13
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d8:	48b9                	li	a7,14
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 3e0:	48d9                	li	a7,22
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <nice>:
.global nice
nice:
 li a7, SYS_nice
 3e8:	48dd                	li	a7,23
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 3f0:	48e1                	li	a7,24
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 3f8:	48e5                	li	a7,25
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 400:	48e9                	li	a7,26
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 408:	1101                	addi	sp,sp,-32
 40a:	ec06                	sd	ra,24(sp)
 40c:	e822                	sd	s0,16(sp)
 40e:	e426                	sd	s1,8(sp)
 410:	1000                	addi	s0,sp,32
 412:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 414:	00351713          	slli	a4,a0,0x3
 418:	00000797          	auipc	a5,0x0
 41c:	5a078793          	addi	a5,a5,1440 # 9b8 <putc_buf>
 420:	97ba                	add	a5,a5,a4
 422:	6388                	ld	a0,0(a5)
  if(buf) {
 424:	c511                	beqz	a0,430 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 426:	60e2                	ld	ra,24(sp)
 428:	6442                	ld	s0,16(sp)
 42a:	64a2                	ld	s1,8(sp)
 42c:	6105                	addi	sp,sp,32
 42e:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 430:	6505                	lui	a0,0x1
 432:	00000097          	auipc	ra,0x0
 436:	460080e7          	jalr	1120(ra) # 892 <malloc>
  putc_buf[fd] = buf;
 43a:	00000797          	auipc	a5,0x0
 43e:	57e78793          	addi	a5,a5,1406 # 9b8 <putc_buf>
 442:	00349713          	slli	a4,s1,0x3
 446:	973e                	add	a4,a4,a5
 448:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 44a:	048a                	slli	s1,s1,0x2
 44c:	94be                	add	s1,s1,a5
 44e:	3204a023          	sw	zero,800(s1)
  return buf;
 452:	bfd1                	j	426 <get_putc_buf+0x1e>

0000000000000454 <putc>:

static void
putc(int fd, char c)
{
 454:	1101                	addi	sp,sp,-32
 456:	ec06                	sd	ra,24(sp)
 458:	e822                	sd	s0,16(sp)
 45a:	e426                	sd	s1,8(sp)
 45c:	e04a                	sd	s2,0(sp)
 45e:	1000                	addi	s0,sp,32
 460:	84aa                	mv	s1,a0
 462:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 464:	00000097          	auipc	ra,0x0
 468:	fa4080e7          	jalr	-92(ra) # 408 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 46c:	00249793          	slli	a5,s1,0x2
 470:	00000717          	auipc	a4,0x0
 474:	54870713          	addi	a4,a4,1352 # 9b8 <putc_buf>
 478:	973e                	add	a4,a4,a5
 47a:	32072783          	lw	a5,800(a4)
 47e:	0017869b          	addiw	a3,a5,1
 482:	32d72023          	sw	a3,800(a4)
 486:	97aa                	add	a5,a5,a0
 488:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 48c:	47a9                	li	a5,10
 48e:	02f90463          	beq	s2,a5,4b6 <putc+0x62>
 492:	00249713          	slli	a4,s1,0x2
 496:	00000797          	auipc	a5,0x0
 49a:	52278793          	addi	a5,a5,1314 # 9b8 <putc_buf>
 49e:	97ba                	add	a5,a5,a4
 4a0:	3207a703          	lw	a4,800(a5)
 4a4:	6785                	lui	a5,0x1
 4a6:	00f70863          	beq	a4,a5,4b6 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 4aa:	60e2                	ld	ra,24(sp)
 4ac:	6442                	ld	s0,16(sp)
 4ae:	64a2                	ld	s1,8(sp)
 4b0:	6902                	ld	s2,0(sp)
 4b2:	6105                	addi	sp,sp,32
 4b4:	8082                	ret
    write(fd, buf, putc_index[fd]);
 4b6:	00249793          	slli	a5,s1,0x2
 4ba:	00000917          	auipc	s2,0x0
 4be:	4fe90913          	addi	s2,s2,1278 # 9b8 <putc_buf>
 4c2:	993e                	add	s2,s2,a5
 4c4:	32092603          	lw	a2,800(s2)
 4c8:	85aa                	mv	a1,a0
 4ca:	8526                	mv	a0,s1
 4cc:	00000097          	auipc	ra,0x0
 4d0:	e94080e7          	jalr	-364(ra) # 360 <write>
    putc_index[fd] = 0;
 4d4:	32092023          	sw	zero,800(s2)
}
 4d8:	bfc9                	j	4aa <putc+0x56>

00000000000004da <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4da:	7139                	addi	sp,sp,-64
 4dc:	fc06                	sd	ra,56(sp)
 4de:	f822                	sd	s0,48(sp)
 4e0:	f426                	sd	s1,40(sp)
 4e2:	f04a                	sd	s2,32(sp)
 4e4:	ec4e                	sd	s3,24(sp)
 4e6:	0080                	addi	s0,sp,64
 4e8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ea:	c299                	beqz	a3,4f0 <printint+0x16>
 4ec:	0805c863          	bltz	a1,57c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4f0:	2581                	sext.w	a1,a1
  neg = 0;
 4f2:	4881                	li	a7,0
 4f4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4fa:	2601                	sext.w	a2,a2
 4fc:	00000517          	auipc	a0,0x0
 500:	49c50513          	addi	a0,a0,1180 # 998 <digits>
 504:	883a                	mv	a6,a4
 506:	2705                	addiw	a4,a4,1
 508:	02c5f7bb          	remuw	a5,a1,a2
 50c:	1782                	slli	a5,a5,0x20
 50e:	9381                	srli	a5,a5,0x20
 510:	97aa                	add	a5,a5,a0
 512:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x188>
 516:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 51a:	0005879b          	sext.w	a5,a1
 51e:	02c5d5bb          	divuw	a1,a1,a2
 522:	0685                	addi	a3,a3,1
 524:	fec7f0e3          	bgeu	a5,a2,504 <printint+0x2a>
  if(neg)
 528:	00088b63          	beqz	a7,53e <printint+0x64>
    buf[i++] = '-';
 52c:	fd040793          	addi	a5,s0,-48
 530:	973e                	add	a4,a4,a5
 532:	02d00793          	li	a5,45
 536:	fef70823          	sb	a5,-16(a4)
 53a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 53e:	02e05863          	blez	a4,56e <printint+0x94>
 542:	fc040793          	addi	a5,s0,-64
 546:	00e78933          	add	s2,a5,a4
 54a:	fff78993          	addi	s3,a5,-1
 54e:	99ba                	add	s3,s3,a4
 550:	377d                	addiw	a4,a4,-1
 552:	1702                	slli	a4,a4,0x20
 554:	9301                	srli	a4,a4,0x20
 556:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 55a:	fff94583          	lbu	a1,-1(s2)
 55e:	8526                	mv	a0,s1
 560:	00000097          	auipc	ra,0x0
 564:	ef4080e7          	jalr	-268(ra) # 454 <putc>
  while(--i >= 0)
 568:	197d                	addi	s2,s2,-1
 56a:	ff3918e3          	bne	s2,s3,55a <printint+0x80>
}
 56e:	70e2                	ld	ra,56(sp)
 570:	7442                	ld	s0,48(sp)
 572:	74a2                	ld	s1,40(sp)
 574:	7902                	ld	s2,32(sp)
 576:	69e2                	ld	s3,24(sp)
 578:	6121                	addi	sp,sp,64
 57a:	8082                	ret
    x = -xx;
 57c:	40b005bb          	negw	a1,a1
    neg = 1;
 580:	4885                	li	a7,1
    x = -xx;
 582:	bf8d                	j	4f4 <printint+0x1a>

0000000000000584 <fflush>:
void fflush(int fd){
 584:	1101                	addi	sp,sp,-32
 586:	ec06                	sd	ra,24(sp)
 588:	e822                	sd	s0,16(sp)
 58a:	e426                	sd	s1,8(sp)
 58c:	e04a                	sd	s2,0(sp)
 58e:	1000                	addi	s0,sp,32
 590:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 592:	00000097          	auipc	ra,0x0
 596:	e76080e7          	jalr	-394(ra) # 408 <get_putc_buf>
 59a:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 59c:	00291793          	slli	a5,s2,0x2
 5a0:	00000497          	auipc	s1,0x0
 5a4:	41848493          	addi	s1,s1,1048 # 9b8 <putc_buf>
 5a8:	94be                	add	s1,s1,a5
 5aa:	3204a603          	lw	a2,800(s1)
 5ae:	854a                	mv	a0,s2
 5b0:	00000097          	auipc	ra,0x0
 5b4:	db0080e7          	jalr	-592(ra) # 360 <write>
  putc_index[fd] = 0;
 5b8:	3204a023          	sw	zero,800(s1)
}
 5bc:	60e2                	ld	ra,24(sp)
 5be:	6442                	ld	s0,16(sp)
 5c0:	64a2                	ld	s1,8(sp)
 5c2:	6902                	ld	s2,0(sp)
 5c4:	6105                	addi	sp,sp,32
 5c6:	8082                	ret

00000000000005c8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c8:	7119                	addi	sp,sp,-128
 5ca:	fc86                	sd	ra,120(sp)
 5cc:	f8a2                	sd	s0,112(sp)
 5ce:	f4a6                	sd	s1,104(sp)
 5d0:	f0ca                	sd	s2,96(sp)
 5d2:	ecce                	sd	s3,88(sp)
 5d4:	e8d2                	sd	s4,80(sp)
 5d6:	e4d6                	sd	s5,72(sp)
 5d8:	e0da                	sd	s6,64(sp)
 5da:	fc5e                	sd	s7,56(sp)
 5dc:	f862                	sd	s8,48(sp)
 5de:	f466                	sd	s9,40(sp)
 5e0:	f06a                	sd	s10,32(sp)
 5e2:	ec6e                	sd	s11,24(sp)
 5e4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e6:	0005c903          	lbu	s2,0(a1)
 5ea:	18090f63          	beqz	s2,788 <vprintf+0x1c0>
 5ee:	8aaa                	mv	s5,a0
 5f0:	8b32                	mv	s6,a2
 5f2:	00158493          	addi	s1,a1,1
  state = 0;
 5f6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5f8:	02500a13          	li	s4,37
      if(c == 'd'){
 5fc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 600:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 604:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 608:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60c:	00000b97          	auipc	s7,0x0
 610:	38cb8b93          	addi	s7,s7,908 # 998 <digits>
 614:	a839                	j	632 <vprintf+0x6a>
        putc(fd, c);
 616:	85ca                	mv	a1,s2
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	e3a080e7          	jalr	-454(ra) # 454 <putc>
 622:	a019                	j	628 <vprintf+0x60>
    } else if(state == '%'){
 624:	01498f63          	beq	s3,s4,642 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 628:	0485                	addi	s1,s1,1
 62a:	fff4c903          	lbu	s2,-1(s1)
 62e:	14090d63          	beqz	s2,788 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 632:	0009079b          	sext.w	a5,s2
    if(state == 0){
 636:	fe0997e3          	bnez	s3,624 <vprintf+0x5c>
      if(c == '%'){
 63a:	fd479ee3          	bne	a5,s4,616 <vprintf+0x4e>
        state = '%';
 63e:	89be                	mv	s3,a5
 640:	b7e5                	j	628 <vprintf+0x60>
      if(c == 'd'){
 642:	05878063          	beq	a5,s8,682 <vprintf+0xba>
      } else if(c == 'l') {
 646:	05978c63          	beq	a5,s9,69e <vprintf+0xd6>
      } else if(c == 'x') {
 64a:	07a78863          	beq	a5,s10,6ba <vprintf+0xf2>
      } else if(c == 'p') {
 64e:	09b78463          	beq	a5,s11,6d6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 652:	07300713          	li	a4,115
 656:	0ce78663          	beq	a5,a4,722 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 65a:	06300713          	li	a4,99
 65e:	0ee78e63          	beq	a5,a4,75a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 662:	11478863          	beq	a5,s4,772 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 666:	85d2                	mv	a1,s4
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	dea080e7          	jalr	-534(ra) # 454 <putc>
        putc(fd, c);
 672:	85ca                	mv	a1,s2
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	dde080e7          	jalr	-546(ra) # 454 <putc>
      }
      state = 0;
 67e:	4981                	li	s3,0
 680:	b765                	j	628 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 682:	008b0913          	addi	s2,s6,8
 686:	4685                	li	a3,1
 688:	4629                	li	a2,10
 68a:	000b2583          	lw	a1,0(s6)
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e4a080e7          	jalr	-438(ra) # 4da <printint>
 698:	8b4a                	mv	s6,s2
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b771                	j	628 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 69e:	008b0913          	addi	s2,s6,8
 6a2:	4681                	li	a3,0
 6a4:	4629                	li	a2,10
 6a6:	000b2583          	lw	a1,0(s6)
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	e2e080e7          	jalr	-466(ra) # 4da <printint>
 6b4:	8b4a                	mv	s6,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bf85                	j	628 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6ba:	008b0913          	addi	s2,s6,8
 6be:	4681                	li	a3,0
 6c0:	4641                	li	a2,16
 6c2:	000b2583          	lw	a1,0(s6)
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e12080e7          	jalr	-494(ra) # 4da <printint>
 6d0:	8b4a                	mv	s6,s2
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	bf91                	j	628 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6d6:	008b0793          	addi	a5,s6,8
 6da:	f8f43423          	sd	a5,-120(s0)
 6de:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6e2:	03000593          	li	a1,48
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	d6c080e7          	jalr	-660(ra) # 454 <putc>
  putc(fd, 'x');
 6f0:	85ea                	mv	a1,s10
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	d60080e7          	jalr	-672(ra) # 454 <putc>
 6fc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fe:	03c9d793          	srli	a5,s3,0x3c
 702:	97de                	add	a5,a5,s7
 704:	0007c583          	lbu	a1,0(a5)
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	d4a080e7          	jalr	-694(ra) # 454 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 712:	0992                	slli	s3,s3,0x4
 714:	397d                	addiw	s2,s2,-1
 716:	fe0914e3          	bnez	s2,6fe <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 71a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 71e:	4981                	li	s3,0
 720:	b721                	j	628 <vprintf+0x60>
        s = va_arg(ap, char*);
 722:	008b0993          	addi	s3,s6,8
 726:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 72a:	02090163          	beqz	s2,74c <vprintf+0x184>
        while(*s != 0){
 72e:	00094583          	lbu	a1,0(s2)
 732:	c9a1                	beqz	a1,782 <vprintf+0x1ba>
          putc(fd, *s);
 734:	8556                	mv	a0,s5
 736:	00000097          	auipc	ra,0x0
 73a:	d1e080e7          	jalr	-738(ra) # 454 <putc>
          s++;
 73e:	0905                	addi	s2,s2,1
        while(*s != 0){
 740:	00094583          	lbu	a1,0(s2)
 744:	f9e5                	bnez	a1,734 <vprintf+0x16c>
        s = va_arg(ap, char*);
 746:	8b4e                	mv	s6,s3
      state = 0;
 748:	4981                	li	s3,0
 74a:	bdf9                	j	628 <vprintf+0x60>
          s = "(null)";
 74c:	00000917          	auipc	s2,0x0
 750:	24490913          	addi	s2,s2,580 # 990 <malloc+0xfe>
        while(*s != 0){
 754:	02800593          	li	a1,40
 758:	bff1                	j	734 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 75a:	008b0913          	addi	s2,s6,8
 75e:	000b4583          	lbu	a1,0(s6)
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	cf0080e7          	jalr	-784(ra) # 454 <putc>
 76c:	8b4a                	mv	s6,s2
      state = 0;
 76e:	4981                	li	s3,0
 770:	bd65                	j	628 <vprintf+0x60>
        putc(fd, c);
 772:	85d2                	mv	a1,s4
 774:	8556                	mv	a0,s5
 776:	00000097          	auipc	ra,0x0
 77a:	cde080e7          	jalr	-802(ra) # 454 <putc>
      state = 0;
 77e:	4981                	li	s3,0
 780:	b565                	j	628 <vprintf+0x60>
        s = va_arg(ap, char*);
 782:	8b4e                	mv	s6,s3
      state = 0;
 784:	4981                	li	s3,0
 786:	b54d                	j	628 <vprintf+0x60>
    }
  }
}
 788:	70e6                	ld	ra,120(sp)
 78a:	7446                	ld	s0,112(sp)
 78c:	74a6                	ld	s1,104(sp)
 78e:	7906                	ld	s2,96(sp)
 790:	69e6                	ld	s3,88(sp)
 792:	6a46                	ld	s4,80(sp)
 794:	6aa6                	ld	s5,72(sp)
 796:	6b06                	ld	s6,64(sp)
 798:	7be2                	ld	s7,56(sp)
 79a:	7c42                	ld	s8,48(sp)
 79c:	7ca2                	ld	s9,40(sp)
 79e:	7d02                	ld	s10,32(sp)
 7a0:	6de2                	ld	s11,24(sp)
 7a2:	6109                	addi	sp,sp,128
 7a4:	8082                	ret

00000000000007a6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a6:	715d                	addi	sp,sp,-80
 7a8:	ec06                	sd	ra,24(sp)
 7aa:	e822                	sd	s0,16(sp)
 7ac:	1000                	addi	s0,sp,32
 7ae:	e010                	sd	a2,0(s0)
 7b0:	e414                	sd	a3,8(s0)
 7b2:	e818                	sd	a4,16(s0)
 7b4:	ec1c                	sd	a5,24(s0)
 7b6:	03043023          	sd	a6,32(s0)
 7ba:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7be:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c2:	8622                	mv	a2,s0
 7c4:	00000097          	auipc	ra,0x0
 7c8:	e04080e7          	jalr	-508(ra) # 5c8 <vprintf>
}
 7cc:	60e2                	ld	ra,24(sp)
 7ce:	6442                	ld	s0,16(sp)
 7d0:	6161                	addi	sp,sp,80
 7d2:	8082                	ret

00000000000007d4 <printf>:

void
printf(const char *fmt, ...)
{
 7d4:	711d                	addi	sp,sp,-96
 7d6:	ec06                	sd	ra,24(sp)
 7d8:	e822                	sd	s0,16(sp)
 7da:	1000                	addi	s0,sp,32
 7dc:	e40c                	sd	a1,8(s0)
 7de:	e810                	sd	a2,16(s0)
 7e0:	ec14                	sd	a3,24(s0)
 7e2:	f018                	sd	a4,32(s0)
 7e4:	f41c                	sd	a5,40(s0)
 7e6:	03043823          	sd	a6,48(s0)
 7ea:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ee:	00840613          	addi	a2,s0,8
 7f2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f6:	85aa                	mv	a1,a0
 7f8:	4505                	li	a0,1
 7fa:	00000097          	auipc	ra,0x0
 7fe:	dce080e7          	jalr	-562(ra) # 5c8 <vprintf>
}
 802:	60e2                	ld	ra,24(sp)
 804:	6442                	ld	s0,16(sp)
 806:	6125                	addi	sp,sp,96
 808:	8082                	ret

000000000000080a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80a:	1141                	addi	sp,sp,-16
 80c:	e422                	sd	s0,8(sp)
 80e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 810:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 814:	00000797          	auipc	a5,0x0
 818:	19c7b783          	ld	a5,412(a5) # 9b0 <freep>
 81c:	a805                	j	84c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 81e:	4618                	lw	a4,8(a2)
 820:	9db9                	addw	a1,a1,a4
 822:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 826:	6398                	ld	a4,0(a5)
 828:	6318                	ld	a4,0(a4)
 82a:	fee53823          	sd	a4,-16(a0)
 82e:	a091                	j	872 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 830:	ff852703          	lw	a4,-8(a0)
 834:	9e39                	addw	a2,a2,a4
 836:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 838:	ff053703          	ld	a4,-16(a0)
 83c:	e398                	sd	a4,0(a5)
 83e:	a099                	j	884 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 840:	6398                	ld	a4,0(a5)
 842:	00e7e463          	bltu	a5,a4,84a <free+0x40>
 846:	00e6ea63          	bltu	a3,a4,85a <free+0x50>
{
 84a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84c:	fed7fae3          	bgeu	a5,a3,840 <free+0x36>
 850:	6398                	ld	a4,0(a5)
 852:	00e6e463          	bltu	a3,a4,85a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 856:	fee7eae3          	bltu	a5,a4,84a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 85a:	ff852583          	lw	a1,-8(a0)
 85e:	6390                	ld	a2,0(a5)
 860:	02059713          	slli	a4,a1,0x20
 864:	9301                	srli	a4,a4,0x20
 866:	0712                	slli	a4,a4,0x4
 868:	9736                	add	a4,a4,a3
 86a:	fae60ae3          	beq	a2,a4,81e <free+0x14>
    bp->s.ptr = p->s.ptr;
 86e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 872:	4790                	lw	a2,8(a5)
 874:	02061713          	slli	a4,a2,0x20
 878:	9301                	srli	a4,a4,0x20
 87a:	0712                	slli	a4,a4,0x4
 87c:	973e                	add	a4,a4,a5
 87e:	fae689e3          	beq	a3,a4,830 <free+0x26>
  } else
    p->s.ptr = bp;
 882:	e394                	sd	a3,0(a5)
  freep = p;
 884:	00000717          	auipc	a4,0x0
 888:	12f73623          	sd	a5,300(a4) # 9b0 <freep>
}
 88c:	6422                	ld	s0,8(sp)
 88e:	0141                	addi	sp,sp,16
 890:	8082                	ret

0000000000000892 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 892:	7139                	addi	sp,sp,-64
 894:	fc06                	sd	ra,56(sp)
 896:	f822                	sd	s0,48(sp)
 898:	f426                	sd	s1,40(sp)
 89a:	f04a                	sd	s2,32(sp)
 89c:	ec4e                	sd	s3,24(sp)
 89e:	e852                	sd	s4,16(sp)
 8a0:	e456                	sd	s5,8(sp)
 8a2:	e05a                	sd	s6,0(sp)
 8a4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a6:	02051493          	slli	s1,a0,0x20
 8aa:	9081                	srli	s1,s1,0x20
 8ac:	04bd                	addi	s1,s1,15
 8ae:	8091                	srli	s1,s1,0x4
 8b0:	0014899b          	addiw	s3,s1,1
 8b4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8b6:	00000517          	auipc	a0,0x0
 8ba:	0fa53503          	ld	a0,250(a0) # 9b0 <freep>
 8be:	c515                	beqz	a0,8ea <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c2:	4798                	lw	a4,8(a5)
 8c4:	02977f63          	bgeu	a4,s1,902 <malloc+0x70>
 8c8:	8a4e                	mv	s4,s3
 8ca:	0009871b          	sext.w	a4,s3
 8ce:	6685                	lui	a3,0x1
 8d0:	00d77363          	bgeu	a4,a3,8d6 <malloc+0x44>
 8d4:	6a05                	lui	s4,0x1
 8d6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8da:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8de:	00000917          	auipc	s2,0x0
 8e2:	0d290913          	addi	s2,s2,210 # 9b0 <freep>
  if(p == (char*)-1)
 8e6:	5afd                	li	s5,-1
 8e8:	a88d                	j	95a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8ea:	00000797          	auipc	a5,0x0
 8ee:	57e78793          	addi	a5,a5,1406 # e68 <base>
 8f2:	00000717          	auipc	a4,0x0
 8f6:	0af73f23          	sd	a5,190(a4) # 9b0 <freep>
 8fa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8fc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 900:	b7e1                	j	8c8 <malloc+0x36>
      if(p->s.size == nunits)
 902:	02e48b63          	beq	s1,a4,938 <malloc+0xa6>
        p->s.size -= nunits;
 906:	4137073b          	subw	a4,a4,s3
 90a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 90c:	1702                	slli	a4,a4,0x20
 90e:	9301                	srli	a4,a4,0x20
 910:	0712                	slli	a4,a4,0x4
 912:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 914:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 918:	00000717          	auipc	a4,0x0
 91c:	08a73c23          	sd	a0,152(a4) # 9b0 <freep>
      return (void*)(p + 1);
 920:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 924:	70e2                	ld	ra,56(sp)
 926:	7442                	ld	s0,48(sp)
 928:	74a2                	ld	s1,40(sp)
 92a:	7902                	ld	s2,32(sp)
 92c:	69e2                	ld	s3,24(sp)
 92e:	6a42                	ld	s4,16(sp)
 930:	6aa2                	ld	s5,8(sp)
 932:	6b02                	ld	s6,0(sp)
 934:	6121                	addi	sp,sp,64
 936:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 938:	6398                	ld	a4,0(a5)
 93a:	e118                	sd	a4,0(a0)
 93c:	bff1                	j	918 <malloc+0x86>
  hp->s.size = nu;
 93e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 942:	0541                	addi	a0,a0,16
 944:	00000097          	auipc	ra,0x0
 948:	ec6080e7          	jalr	-314(ra) # 80a <free>
  return freep;
 94c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 950:	d971                	beqz	a0,924 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 952:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 954:	4798                	lw	a4,8(a5)
 956:	fa9776e3          	bgeu	a4,s1,902 <malloc+0x70>
    if(p == freep)
 95a:	00093703          	ld	a4,0(s2)
 95e:	853e                	mv	a0,a5
 960:	fef719e3          	bne	a4,a5,952 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 964:	8552                	mv	a0,s4
 966:	00000097          	auipc	ra,0x0
 96a:	a62080e7          	jalr	-1438(ra) # 3c8 <sbrk>
  if(p == (char*)-1)
 96e:	fd5518e3          	bne	a0,s5,93e <malloc+0xac>
        return 0;
 972:	4501                	li	a0,0
 974:	bf45                	j	924 <malloc+0x92>
