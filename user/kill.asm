
user/_kill:     file format elf64-littleriscv


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
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	1902                	slli	s2,s2,0x20
  1c:	02095913          	srli	s2,s2,0x20
  20:	090e                	slli	s2,s2,0x3
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	16c080e7          	jalr	364(ra) # 194 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	328080e7          	jalr	808(ra) # 358 <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2e8080e7          	jalr	744(ra) # 328 <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00001597          	auipc	a1,0x1
  4c:	91858593          	addi	a1,a1,-1768 # 960 <malloc+0xe6>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	73c080e7          	jalr	1852(ra) # 78e <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	2cc080e7          	jalr	716(ra) # 328 <exit>

0000000000000064 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  64:	1141                	addi	sp,sp,-16
  66:	e422                	sd	s0,8(sp)
  68:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  6a:	87aa                	mv	a5,a0
  6c:	0585                	addi	a1,a1,1
  6e:	0785                	addi	a5,a5,1
  70:	fff5c703          	lbu	a4,-1(a1)
  74:	fee78fa3          	sb	a4,-1(a5)
  78:	fb75                	bnez	a4,6c <strcpy+0x8>
    ;
  return os;
}
  7a:	6422                	ld	s0,8(sp)
  7c:	0141                	addi	sp,sp,16
  7e:	8082                	ret

0000000000000080 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80:	1141                	addi	sp,sp,-16
  82:	e422                	sd	s0,8(sp)
  84:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  86:	00054783          	lbu	a5,0(a0)
  8a:	cb91                	beqz	a5,9e <strcmp+0x1e>
  8c:	0005c703          	lbu	a4,0(a1)
  90:	00f71763          	bne	a4,a5,9e <strcmp+0x1e>
    p++, q++;
  94:	0505                	addi	a0,a0,1
  96:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  98:	00054783          	lbu	a5,0(a0)
  9c:	fbe5                	bnez	a5,8c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9e:	0005c503          	lbu	a0,0(a1)
}
  a2:	40a7853b          	subw	a0,a5,a0
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret

00000000000000ac <strlen>:

uint
strlen(const char *s)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e422                	sd	s0,8(sp)
  b0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	cf91                	beqz	a5,d2 <strlen+0x26>
  b8:	0505                	addi	a0,a0,1
  ba:	87aa                	mv	a5,a0
  bc:	4685                	li	a3,1
  be:	9e89                	subw	a3,a3,a0
  c0:	00f6853b          	addw	a0,a3,a5
  c4:	0785                	addi	a5,a5,1
  c6:	fff7c703          	lbu	a4,-1(a5)
  ca:	fb7d                	bnez	a4,c0 <strlen+0x14>
    ;
  return n;
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret
  for(n = 0; s[n]; n++)
  d2:	4501                	li	a0,0
  d4:	bfe5                	j	cc <strlen+0x20>

00000000000000d6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  dc:	ce09                	beqz	a2,f6 <memset+0x20>
  de:	87aa                	mv	a5,a0
  e0:	fff6071b          	addiw	a4,a2,-1
  e4:	1702                	slli	a4,a4,0x20
  e6:	9301                	srli	a4,a4,0x20
  e8:	0705                	addi	a4,a4,1
  ea:	972a                	add	a4,a4,a0
    cdst[i] = c;
  ec:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  f0:	0785                	addi	a5,a5,1
  f2:	fee79de3          	bne	a5,a4,ec <memset+0x16>
  }
  return dst;
}
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	addi	sp,sp,16
  fa:	8082                	ret

00000000000000fc <strchr>:

char*
strchr(const char *s, char c)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  for(; *s; s++)
 102:	00054783          	lbu	a5,0(a0)
 106:	cb99                	beqz	a5,11c <strchr+0x20>
    if(*s == c)
 108:	00f58763          	beq	a1,a5,116 <strchr+0x1a>
  for(; *s; s++)
 10c:	0505                	addi	a0,a0,1
 10e:	00054783          	lbu	a5,0(a0)
 112:	fbfd                	bnez	a5,108 <strchr+0xc>
      return (char*)s;
  return 0;
 114:	4501                	li	a0,0
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret
  return 0;
 11c:	4501                	li	a0,0
 11e:	bfe5                	j	116 <strchr+0x1a>

0000000000000120 <gets>:

char*
gets(char *buf, int max)
{
 120:	711d                	addi	sp,sp,-96
 122:	ec86                	sd	ra,88(sp)
 124:	e8a2                	sd	s0,80(sp)
 126:	e4a6                	sd	s1,72(sp)
 128:	e0ca                	sd	s2,64(sp)
 12a:	fc4e                	sd	s3,56(sp)
 12c:	f852                	sd	s4,48(sp)
 12e:	f456                	sd	s5,40(sp)
 130:	f05a                	sd	s6,32(sp)
 132:	ec5e                	sd	s7,24(sp)
 134:	1080                	addi	s0,sp,96
 136:	8baa                	mv	s7,a0
 138:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13a:	892a                	mv	s2,a0
 13c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 13e:	4aa9                	li	s5,10
 140:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 142:	89a6                	mv	s3,s1
 144:	2485                	addiw	s1,s1,1
 146:	0344d863          	bge	s1,s4,176 <gets+0x56>
    cc = read(0, &c, 1);
 14a:	4605                	li	a2,1
 14c:	faf40593          	addi	a1,s0,-81
 150:	4501                	li	a0,0
 152:	00000097          	auipc	ra,0x0
 156:	1ee080e7          	jalr	494(ra) # 340 <read>
    if(cc < 1)
 15a:	00a05e63          	blez	a0,176 <gets+0x56>
    buf[i++] = c;
 15e:	faf44783          	lbu	a5,-81(s0)
 162:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 166:	01578763          	beq	a5,s5,174 <gets+0x54>
 16a:	0905                	addi	s2,s2,1
 16c:	fd679be3          	bne	a5,s6,142 <gets+0x22>
  for(i=0; i+1 < max; ){
 170:	89a6                	mv	s3,s1
 172:	a011                	j	176 <gets+0x56>
 174:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 176:	99de                	add	s3,s3,s7
 178:	00098023          	sb	zero,0(s3)
  return buf;
}
 17c:	855e                	mv	a0,s7
 17e:	60e6                	ld	ra,88(sp)
 180:	6446                	ld	s0,80(sp)
 182:	64a6                	ld	s1,72(sp)
 184:	6906                	ld	s2,64(sp)
 186:	79e2                	ld	s3,56(sp)
 188:	7a42                	ld	s4,48(sp)
 18a:	7aa2                	ld	s5,40(sp)
 18c:	7b02                	ld	s6,32(sp)
 18e:	6be2                	ld	s7,24(sp)
 190:	6125                	addi	sp,sp,96
 192:	8082                	ret

0000000000000194 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 19a:	00054603          	lbu	a2,0(a0)
 19e:	fd06079b          	addiw	a5,a2,-48
 1a2:	0ff7f793          	andi	a5,a5,255
 1a6:	4725                	li	a4,9
 1a8:	02f76963          	bltu	a4,a5,1da <atoi+0x46>
 1ac:	86aa                	mv	a3,a0
  n = 0;
 1ae:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1b0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1b2:	0685                	addi	a3,a3,1
 1b4:	0025179b          	slliw	a5,a0,0x2
 1b8:	9fa9                	addw	a5,a5,a0
 1ba:	0017979b          	slliw	a5,a5,0x1
 1be:	9fb1                	addw	a5,a5,a2
 1c0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c4:	0006c603          	lbu	a2,0(a3)
 1c8:	fd06071b          	addiw	a4,a2,-48
 1cc:	0ff77713          	andi	a4,a4,255
 1d0:	fee5f1e3          	bgeu	a1,a4,1b2 <atoi+0x1e>
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  n = 0;
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <atoi+0x40>

00000000000001de <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e4:	02b57663          	bgeu	a0,a1,210 <memmove+0x32>
    while(n-- > 0)
 1e8:	02c05163          	blez	a2,20a <memmove+0x2c>
 1ec:	fff6079b          	addiw	a5,a2,-1
 1f0:	1782                	slli	a5,a5,0x20
 1f2:	9381                	srli	a5,a5,0x20
 1f4:	0785                	addi	a5,a5,1
 1f6:	97aa                	add	a5,a5,a0
  dst = vdst;
 1f8:	872a                	mv	a4,a0
      *dst++ = *src++;
 1fa:	0585                	addi	a1,a1,1
 1fc:	0705                	addi	a4,a4,1
 1fe:	fff5c683          	lbu	a3,-1(a1)
 202:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 206:	fee79ae3          	bne	a5,a4,1fa <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret
    dst += n;
 210:	00c50733          	add	a4,a0,a2
    src += n;
 214:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 216:	fec05ae3          	blez	a2,20a <memmove+0x2c>
 21a:	fff6079b          	addiw	a5,a2,-1
 21e:	1782                	slli	a5,a5,0x20
 220:	9381                	srli	a5,a5,0x20
 222:	fff7c793          	not	a5,a5
 226:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 228:	15fd                	addi	a1,a1,-1
 22a:	177d                	addi	a4,a4,-1
 22c:	0005c683          	lbu	a3,0(a1)
 230:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 234:	fee79ae3          	bne	a5,a4,228 <memmove+0x4a>
 238:	bfc9                	j	20a <memmove+0x2c>

000000000000023a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 240:	ca05                	beqz	a2,270 <memcmp+0x36>
 242:	fff6069b          	addiw	a3,a2,-1
 246:	1682                	slli	a3,a3,0x20
 248:	9281                	srli	a3,a3,0x20
 24a:	0685                	addi	a3,a3,1
 24c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 24e:	00054783          	lbu	a5,0(a0)
 252:	0005c703          	lbu	a4,0(a1)
 256:	00e79863          	bne	a5,a4,266 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 25a:	0505                	addi	a0,a0,1
    p2++;
 25c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 25e:	fed518e3          	bne	a0,a3,24e <memcmp+0x14>
  }
  return 0;
 262:	4501                	li	a0,0
 264:	a019                	j	26a <memcmp+0x30>
      return *p1 - *p2;
 266:	40e7853b          	subw	a0,a5,a4
}
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
  return 0;
 270:	4501                	li	a0,0
 272:	bfe5                	j	26a <memcmp+0x30>

0000000000000274 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 274:	1141                	addi	sp,sp,-16
 276:	e406                	sd	ra,8(sp)
 278:	e022                	sd	s0,0(sp)
 27a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 27c:	00000097          	auipc	ra,0x0
 280:	f62080e7          	jalr	-158(ra) # 1de <memmove>
}
 284:	60a2                	ld	ra,8(sp)
 286:	6402                	ld	s0,0(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <close>:

int close(int fd){
 28c:	1101                	addi	sp,sp,-32
 28e:	ec06                	sd	ra,24(sp)
 290:	e822                	sd	s0,16(sp)
 292:	e426                	sd	s1,8(sp)
 294:	1000                	addi	s0,sp,32
 296:	84aa                	mv	s1,a0
  fflush(fd);
 298:	00000097          	auipc	ra,0x0
 29c:	2d4080e7          	jalr	724(ra) # 56c <fflush>
  char* buf = get_putc_buf(fd);
 2a0:	8526                	mv	a0,s1
 2a2:	00000097          	auipc	ra,0x0
 2a6:	14e080e7          	jalr	334(ra) # 3f0 <get_putc_buf>
  if(buf){
 2aa:	cd11                	beqz	a0,2c6 <close+0x3a>
    free(buf);
 2ac:	00000097          	auipc	ra,0x0
 2b0:	546080e7          	jalr	1350(ra) # 7f2 <free>
    putc_buf[fd] = 0;
 2b4:	00349713          	slli	a4,s1,0x3
 2b8:	00000797          	auipc	a5,0x0
 2bc:	6e878793          	addi	a5,a5,1768 # 9a0 <putc_buf>
 2c0:	97ba                	add	a5,a5,a4
 2c2:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 2c6:	8526                	mv	a0,s1
 2c8:	00000097          	auipc	ra,0x0
 2cc:	088080e7          	jalr	136(ra) # 350 <sclose>
}
 2d0:	60e2                	ld	ra,24(sp)
 2d2:	6442                	ld	s0,16(sp)
 2d4:	64a2                	ld	s1,8(sp)
 2d6:	6105                	addi	sp,sp,32
 2d8:	8082                	ret

00000000000002da <stat>:
{
 2da:	1101                	addi	sp,sp,-32
 2dc:	ec06                	sd	ra,24(sp)
 2de:	e822                	sd	s0,16(sp)
 2e0:	e426                	sd	s1,8(sp)
 2e2:	e04a                	sd	s2,0(sp)
 2e4:	1000                	addi	s0,sp,32
 2e6:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 2e8:	4581                	li	a1,0
 2ea:	00000097          	auipc	ra,0x0
 2ee:	07e080e7          	jalr	126(ra) # 368 <open>
  if(fd < 0)
 2f2:	02054563          	bltz	a0,31c <stat+0x42>
 2f6:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 2f8:	85ca                	mv	a1,s2
 2fa:	00000097          	auipc	ra,0x0
 2fe:	086080e7          	jalr	134(ra) # 380 <fstat>
 302:	892a                	mv	s2,a0
  close(fd);
 304:	8526                	mv	a0,s1
 306:	00000097          	auipc	ra,0x0
 30a:	f86080e7          	jalr	-122(ra) # 28c <close>
}
 30e:	854a                	mv	a0,s2
 310:	60e2                	ld	ra,24(sp)
 312:	6442                	ld	s0,16(sp)
 314:	64a2                	ld	s1,8(sp)
 316:	6902                	ld	s2,0(sp)
 318:	6105                	addi	sp,sp,32
 31a:	8082                	ret
    return -1;
 31c:	597d                	li	s2,-1
 31e:	bfc5                	j	30e <stat+0x34>

0000000000000320 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 320:	4885                	li	a7,1
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <exit>:
.global exit
exit:
 li a7, SYS_exit
 328:	4889                	li	a7,2
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <wait>:
.global wait
wait:
 li a7, SYS_wait
 330:	488d                	li	a7,3
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 338:	4891                	li	a7,4
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <read>:
.global read
read:
 li a7, SYS_read
 340:	4895                	li	a7,5
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <write>:
.global write
write:
 li a7, SYS_write
 348:	48c1                	li	a7,16
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 350:	48d5                	li	a7,21
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <kill>:
.global kill
kill:
 li a7, SYS_kill
 358:	4899                	li	a7,6
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <exec>:
.global exec
exec:
 li a7, SYS_exec
 360:	489d                	li	a7,7
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <open>:
.global open
open:
 li a7, SYS_open
 368:	48bd                	li	a7,15
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 370:	48c5                	li	a7,17
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 378:	48c9                	li	a7,18
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 380:	48a1                	li	a7,8
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <link>:
.global link
link:
 li a7, SYS_link
 388:	48cd                	li	a7,19
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 390:	48d1                	li	a7,20
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 398:	48a5                	li	a7,9
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a0:	48a9                	li	a7,10
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a8:	48ad                	li	a7,11
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b0:	48b1                	li	a7,12
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b8:	48b5                	li	a7,13
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c0:	48b9                	li	a7,14
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 3c8:	48d9                	li	a7,22
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <nice>:
.global nice
nice:
 li a7, SYS_nice
 3d0:	48dd                	li	a7,23
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 3d8:	48e1                	li	a7,24
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 3e0:	48e5                	li	a7,25
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 3e8:	48e9                	li	a7,26
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 3f0:	1101                	addi	sp,sp,-32
 3f2:	ec06                	sd	ra,24(sp)
 3f4:	e822                	sd	s0,16(sp)
 3f6:	e426                	sd	s1,8(sp)
 3f8:	1000                	addi	s0,sp,32
 3fa:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 3fc:	00351713          	slli	a4,a0,0x3
 400:	00000797          	auipc	a5,0x0
 404:	5a078793          	addi	a5,a5,1440 # 9a0 <putc_buf>
 408:	97ba                	add	a5,a5,a4
 40a:	6388                	ld	a0,0(a5)
  if(buf) {
 40c:	c511                	beqz	a0,418 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 40e:	60e2                	ld	ra,24(sp)
 410:	6442                	ld	s0,16(sp)
 412:	64a2                	ld	s1,8(sp)
 414:	6105                	addi	sp,sp,32
 416:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 418:	6505                	lui	a0,0x1
 41a:	00000097          	auipc	ra,0x0
 41e:	460080e7          	jalr	1120(ra) # 87a <malloc>
  putc_buf[fd] = buf;
 422:	00000797          	auipc	a5,0x0
 426:	57e78793          	addi	a5,a5,1406 # 9a0 <putc_buf>
 42a:	00349713          	slli	a4,s1,0x3
 42e:	973e                	add	a4,a4,a5
 430:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 432:	048a                	slli	s1,s1,0x2
 434:	94be                	add	s1,s1,a5
 436:	3204a023          	sw	zero,800(s1)
  return buf;
 43a:	bfd1                	j	40e <get_putc_buf+0x1e>

000000000000043c <putc>:

static void
putc(int fd, char c)
{
 43c:	1101                	addi	sp,sp,-32
 43e:	ec06                	sd	ra,24(sp)
 440:	e822                	sd	s0,16(sp)
 442:	e426                	sd	s1,8(sp)
 444:	e04a                	sd	s2,0(sp)
 446:	1000                	addi	s0,sp,32
 448:	84aa                	mv	s1,a0
 44a:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 44c:	00000097          	auipc	ra,0x0
 450:	fa4080e7          	jalr	-92(ra) # 3f0 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 454:	00249793          	slli	a5,s1,0x2
 458:	00000717          	auipc	a4,0x0
 45c:	54870713          	addi	a4,a4,1352 # 9a0 <putc_buf>
 460:	973e                	add	a4,a4,a5
 462:	32072783          	lw	a5,800(a4)
 466:	0017869b          	addiw	a3,a5,1
 46a:	32d72023          	sw	a3,800(a4)
 46e:	97aa                	add	a5,a5,a0
 470:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 474:	47a9                	li	a5,10
 476:	02f90463          	beq	s2,a5,49e <putc+0x62>
 47a:	00249713          	slli	a4,s1,0x2
 47e:	00000797          	auipc	a5,0x0
 482:	52278793          	addi	a5,a5,1314 # 9a0 <putc_buf>
 486:	97ba                	add	a5,a5,a4
 488:	3207a703          	lw	a4,800(a5)
 48c:	6785                	lui	a5,0x1
 48e:	00f70863          	beq	a4,a5,49e <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 492:	60e2                	ld	ra,24(sp)
 494:	6442                	ld	s0,16(sp)
 496:	64a2                	ld	s1,8(sp)
 498:	6902                	ld	s2,0(sp)
 49a:	6105                	addi	sp,sp,32
 49c:	8082                	ret
    write(fd, buf, putc_index[fd]);
 49e:	00249793          	slli	a5,s1,0x2
 4a2:	00000917          	auipc	s2,0x0
 4a6:	4fe90913          	addi	s2,s2,1278 # 9a0 <putc_buf>
 4aa:	993e                	add	s2,s2,a5
 4ac:	32092603          	lw	a2,800(s2)
 4b0:	85aa                	mv	a1,a0
 4b2:	8526                	mv	a0,s1
 4b4:	00000097          	auipc	ra,0x0
 4b8:	e94080e7          	jalr	-364(ra) # 348 <write>
    putc_index[fd] = 0;
 4bc:	32092023          	sw	zero,800(s2)
}
 4c0:	bfc9                	j	492 <putc+0x56>

00000000000004c2 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4c2:	7139                	addi	sp,sp,-64
 4c4:	fc06                	sd	ra,56(sp)
 4c6:	f822                	sd	s0,48(sp)
 4c8:	f426                	sd	s1,40(sp)
 4ca:	f04a                	sd	s2,32(sp)
 4cc:	ec4e                	sd	s3,24(sp)
 4ce:	0080                	addi	s0,sp,64
 4d0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4d2:	c299                	beqz	a3,4d8 <printint+0x16>
 4d4:	0805c863          	bltz	a1,564 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4d8:	2581                	sext.w	a1,a1
  neg = 0;
 4da:	4881                	li	a7,0
 4dc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4e0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4e2:	2601                	sext.w	a2,a2
 4e4:	00000517          	auipc	a0,0x0
 4e8:	49c50513          	addi	a0,a0,1180 # 980 <digits>
 4ec:	883a                	mv	a6,a4
 4ee:	2705                	addiw	a4,a4,1
 4f0:	02c5f7bb          	remuw	a5,a1,a2
 4f4:	1782                	slli	a5,a5,0x20
 4f6:	9381                	srli	a5,a5,0x20
 4f8:	97aa                	add	a5,a5,a0
 4fa:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x1a0>
 4fe:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 502:	0005879b          	sext.w	a5,a1
 506:	02c5d5bb          	divuw	a1,a1,a2
 50a:	0685                	addi	a3,a3,1
 50c:	fec7f0e3          	bgeu	a5,a2,4ec <printint+0x2a>
  if(neg)
 510:	00088b63          	beqz	a7,526 <printint+0x64>
    buf[i++] = '-';
 514:	fd040793          	addi	a5,s0,-48
 518:	973e                	add	a4,a4,a5
 51a:	02d00793          	li	a5,45
 51e:	fef70823          	sb	a5,-16(a4)
 522:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 526:	02e05863          	blez	a4,556 <printint+0x94>
 52a:	fc040793          	addi	a5,s0,-64
 52e:	00e78933          	add	s2,a5,a4
 532:	fff78993          	addi	s3,a5,-1
 536:	99ba                	add	s3,s3,a4
 538:	377d                	addiw	a4,a4,-1
 53a:	1702                	slli	a4,a4,0x20
 53c:	9301                	srli	a4,a4,0x20
 53e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 542:	fff94583          	lbu	a1,-1(s2)
 546:	8526                	mv	a0,s1
 548:	00000097          	auipc	ra,0x0
 54c:	ef4080e7          	jalr	-268(ra) # 43c <putc>
  while(--i >= 0)
 550:	197d                	addi	s2,s2,-1
 552:	ff3918e3          	bne	s2,s3,542 <printint+0x80>
}
 556:	70e2                	ld	ra,56(sp)
 558:	7442                	ld	s0,48(sp)
 55a:	74a2                	ld	s1,40(sp)
 55c:	7902                	ld	s2,32(sp)
 55e:	69e2                	ld	s3,24(sp)
 560:	6121                	addi	sp,sp,64
 562:	8082                	ret
    x = -xx;
 564:	40b005bb          	negw	a1,a1
    neg = 1;
 568:	4885                	li	a7,1
    x = -xx;
 56a:	bf8d                	j	4dc <printint+0x1a>

000000000000056c <fflush>:
void fflush(int fd){
 56c:	1101                	addi	sp,sp,-32
 56e:	ec06                	sd	ra,24(sp)
 570:	e822                	sd	s0,16(sp)
 572:	e426                	sd	s1,8(sp)
 574:	e04a                	sd	s2,0(sp)
 576:	1000                	addi	s0,sp,32
 578:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 57a:	00000097          	auipc	ra,0x0
 57e:	e76080e7          	jalr	-394(ra) # 3f0 <get_putc_buf>
 582:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 584:	00291793          	slli	a5,s2,0x2
 588:	00000497          	auipc	s1,0x0
 58c:	41848493          	addi	s1,s1,1048 # 9a0 <putc_buf>
 590:	94be                	add	s1,s1,a5
 592:	3204a603          	lw	a2,800(s1)
 596:	854a                	mv	a0,s2
 598:	00000097          	auipc	ra,0x0
 59c:	db0080e7          	jalr	-592(ra) # 348 <write>
  putc_index[fd] = 0;
 5a0:	3204a023          	sw	zero,800(s1)
}
 5a4:	60e2                	ld	ra,24(sp)
 5a6:	6442                	ld	s0,16(sp)
 5a8:	64a2                	ld	s1,8(sp)
 5aa:	6902                	ld	s2,0(sp)
 5ac:	6105                	addi	sp,sp,32
 5ae:	8082                	ret

00000000000005b0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5b0:	7119                	addi	sp,sp,-128
 5b2:	fc86                	sd	ra,120(sp)
 5b4:	f8a2                	sd	s0,112(sp)
 5b6:	f4a6                	sd	s1,104(sp)
 5b8:	f0ca                	sd	s2,96(sp)
 5ba:	ecce                	sd	s3,88(sp)
 5bc:	e8d2                	sd	s4,80(sp)
 5be:	e4d6                	sd	s5,72(sp)
 5c0:	e0da                	sd	s6,64(sp)
 5c2:	fc5e                	sd	s7,56(sp)
 5c4:	f862                	sd	s8,48(sp)
 5c6:	f466                	sd	s9,40(sp)
 5c8:	f06a                	sd	s10,32(sp)
 5ca:	ec6e                	sd	s11,24(sp)
 5cc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ce:	0005c903          	lbu	s2,0(a1)
 5d2:	18090f63          	beqz	s2,770 <vprintf+0x1c0>
 5d6:	8aaa                	mv	s5,a0
 5d8:	8b32                	mv	s6,a2
 5da:	00158493          	addi	s1,a1,1
  state = 0;
 5de:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5e0:	02500a13          	li	s4,37
      if(c == 'd'){
 5e4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5e8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5ec:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5f0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f4:	00000b97          	auipc	s7,0x0
 5f8:	38cb8b93          	addi	s7,s7,908 # 980 <digits>
 5fc:	a839                	j	61a <vprintf+0x6a>
        putc(fd, c);
 5fe:	85ca                	mv	a1,s2
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e3a080e7          	jalr	-454(ra) # 43c <putc>
 60a:	a019                	j	610 <vprintf+0x60>
    } else if(state == '%'){
 60c:	01498f63          	beq	s3,s4,62a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 610:	0485                	addi	s1,s1,1
 612:	fff4c903          	lbu	s2,-1(s1)
 616:	14090d63          	beqz	s2,770 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 61a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 61e:	fe0997e3          	bnez	s3,60c <vprintf+0x5c>
      if(c == '%'){
 622:	fd479ee3          	bne	a5,s4,5fe <vprintf+0x4e>
        state = '%';
 626:	89be                	mv	s3,a5
 628:	b7e5                	j	610 <vprintf+0x60>
      if(c == 'd'){
 62a:	05878063          	beq	a5,s8,66a <vprintf+0xba>
      } else if(c == 'l') {
 62e:	05978c63          	beq	a5,s9,686 <vprintf+0xd6>
      } else if(c == 'x') {
 632:	07a78863          	beq	a5,s10,6a2 <vprintf+0xf2>
      } else if(c == 'p') {
 636:	09b78463          	beq	a5,s11,6be <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 63a:	07300713          	li	a4,115
 63e:	0ce78663          	beq	a5,a4,70a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 642:	06300713          	li	a4,99
 646:	0ee78e63          	beq	a5,a4,742 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 64a:	11478863          	beq	a5,s4,75a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 64e:	85d2                	mv	a1,s4
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	dea080e7          	jalr	-534(ra) # 43c <putc>
        putc(fd, c);
 65a:	85ca                	mv	a1,s2
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	dde080e7          	jalr	-546(ra) # 43c <putc>
      }
      state = 0;
 666:	4981                	li	s3,0
 668:	b765                	j	610 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 66a:	008b0913          	addi	s2,s6,8
 66e:	4685                	li	a3,1
 670:	4629                	li	a2,10
 672:	000b2583          	lw	a1,0(s6)
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	e4a080e7          	jalr	-438(ra) # 4c2 <printint>
 680:	8b4a                	mv	s6,s2
      state = 0;
 682:	4981                	li	s3,0
 684:	b771                	j	610 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 686:	008b0913          	addi	s2,s6,8
 68a:	4681                	li	a3,0
 68c:	4629                	li	a2,10
 68e:	000b2583          	lw	a1,0(s6)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e2e080e7          	jalr	-466(ra) # 4c2 <printint>
 69c:	8b4a                	mv	s6,s2
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bf85                	j	610 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6a2:	008b0913          	addi	s2,s6,8
 6a6:	4681                	li	a3,0
 6a8:	4641                	li	a2,16
 6aa:	000b2583          	lw	a1,0(s6)
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	e12080e7          	jalr	-494(ra) # 4c2 <printint>
 6b8:	8b4a                	mv	s6,s2
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	bf91                	j	610 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6be:	008b0793          	addi	a5,s6,8
 6c2:	f8f43423          	sd	a5,-120(s0)
 6c6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6ca:	03000593          	li	a1,48
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	d6c080e7          	jalr	-660(ra) # 43c <putc>
  putc(fd, 'x');
 6d8:	85ea                	mv	a1,s10
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	d60080e7          	jalr	-672(ra) # 43c <putc>
 6e4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e6:	03c9d793          	srli	a5,s3,0x3c
 6ea:	97de                	add	a5,a5,s7
 6ec:	0007c583          	lbu	a1,0(a5)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	d4a080e7          	jalr	-694(ra) # 43c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6fa:	0992                	slli	s3,s3,0x4
 6fc:	397d                	addiw	s2,s2,-1
 6fe:	fe0914e3          	bnez	s2,6e6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 702:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 706:	4981                	li	s3,0
 708:	b721                	j	610 <vprintf+0x60>
        s = va_arg(ap, char*);
 70a:	008b0993          	addi	s3,s6,8
 70e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 712:	02090163          	beqz	s2,734 <vprintf+0x184>
        while(*s != 0){
 716:	00094583          	lbu	a1,0(s2)
 71a:	c9a1                	beqz	a1,76a <vprintf+0x1ba>
          putc(fd, *s);
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	d1e080e7          	jalr	-738(ra) # 43c <putc>
          s++;
 726:	0905                	addi	s2,s2,1
        while(*s != 0){
 728:	00094583          	lbu	a1,0(s2)
 72c:	f9e5                	bnez	a1,71c <vprintf+0x16c>
        s = va_arg(ap, char*);
 72e:	8b4e                	mv	s6,s3
      state = 0;
 730:	4981                	li	s3,0
 732:	bdf9                	j	610 <vprintf+0x60>
          s = "(null)";
 734:	00000917          	auipc	s2,0x0
 738:	24490913          	addi	s2,s2,580 # 978 <malloc+0xfe>
        while(*s != 0){
 73c:	02800593          	li	a1,40
 740:	bff1                	j	71c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 742:	008b0913          	addi	s2,s6,8
 746:	000b4583          	lbu	a1,0(s6)
 74a:	8556                	mv	a0,s5
 74c:	00000097          	auipc	ra,0x0
 750:	cf0080e7          	jalr	-784(ra) # 43c <putc>
 754:	8b4a                	mv	s6,s2
      state = 0;
 756:	4981                	li	s3,0
 758:	bd65                	j	610 <vprintf+0x60>
        putc(fd, c);
 75a:	85d2                	mv	a1,s4
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	cde080e7          	jalr	-802(ra) # 43c <putc>
      state = 0;
 766:	4981                	li	s3,0
 768:	b565                	j	610 <vprintf+0x60>
        s = va_arg(ap, char*);
 76a:	8b4e                	mv	s6,s3
      state = 0;
 76c:	4981                	li	s3,0
 76e:	b54d                	j	610 <vprintf+0x60>
    }
  }
}
 770:	70e6                	ld	ra,120(sp)
 772:	7446                	ld	s0,112(sp)
 774:	74a6                	ld	s1,104(sp)
 776:	7906                	ld	s2,96(sp)
 778:	69e6                	ld	s3,88(sp)
 77a:	6a46                	ld	s4,80(sp)
 77c:	6aa6                	ld	s5,72(sp)
 77e:	6b06                	ld	s6,64(sp)
 780:	7be2                	ld	s7,56(sp)
 782:	7c42                	ld	s8,48(sp)
 784:	7ca2                	ld	s9,40(sp)
 786:	7d02                	ld	s10,32(sp)
 788:	6de2                	ld	s11,24(sp)
 78a:	6109                	addi	sp,sp,128
 78c:	8082                	ret

000000000000078e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 78e:	715d                	addi	sp,sp,-80
 790:	ec06                	sd	ra,24(sp)
 792:	e822                	sd	s0,16(sp)
 794:	1000                	addi	s0,sp,32
 796:	e010                	sd	a2,0(s0)
 798:	e414                	sd	a3,8(s0)
 79a:	e818                	sd	a4,16(s0)
 79c:	ec1c                	sd	a5,24(s0)
 79e:	03043023          	sd	a6,32(s0)
 7a2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7a6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7aa:	8622                	mv	a2,s0
 7ac:	00000097          	auipc	ra,0x0
 7b0:	e04080e7          	jalr	-508(ra) # 5b0 <vprintf>
}
 7b4:	60e2                	ld	ra,24(sp)
 7b6:	6442                	ld	s0,16(sp)
 7b8:	6161                	addi	sp,sp,80
 7ba:	8082                	ret

00000000000007bc <printf>:

void
printf(const char *fmt, ...)
{
 7bc:	711d                	addi	sp,sp,-96
 7be:	ec06                	sd	ra,24(sp)
 7c0:	e822                	sd	s0,16(sp)
 7c2:	1000                	addi	s0,sp,32
 7c4:	e40c                	sd	a1,8(s0)
 7c6:	e810                	sd	a2,16(s0)
 7c8:	ec14                	sd	a3,24(s0)
 7ca:	f018                	sd	a4,32(s0)
 7cc:	f41c                	sd	a5,40(s0)
 7ce:	03043823          	sd	a6,48(s0)
 7d2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7d6:	00840613          	addi	a2,s0,8
 7da:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7de:	85aa                	mv	a1,a0
 7e0:	4505                	li	a0,1
 7e2:	00000097          	auipc	ra,0x0
 7e6:	dce080e7          	jalr	-562(ra) # 5b0 <vprintf>
}
 7ea:	60e2                	ld	ra,24(sp)
 7ec:	6442                	ld	s0,16(sp)
 7ee:	6125                	addi	sp,sp,96
 7f0:	8082                	ret

00000000000007f2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f2:	1141                	addi	sp,sp,-16
 7f4:	e422                	sd	s0,8(sp)
 7f6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fc:	00000797          	auipc	a5,0x0
 800:	19c7b783          	ld	a5,412(a5) # 998 <freep>
 804:	a805                	j	834 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 806:	4618                	lw	a4,8(a2)
 808:	9db9                	addw	a1,a1,a4
 80a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 80e:	6398                	ld	a4,0(a5)
 810:	6318                	ld	a4,0(a4)
 812:	fee53823          	sd	a4,-16(a0)
 816:	a091                	j	85a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 818:	ff852703          	lw	a4,-8(a0)
 81c:	9e39                	addw	a2,a2,a4
 81e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 820:	ff053703          	ld	a4,-16(a0)
 824:	e398                	sd	a4,0(a5)
 826:	a099                	j	86c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 828:	6398                	ld	a4,0(a5)
 82a:	00e7e463          	bltu	a5,a4,832 <free+0x40>
 82e:	00e6ea63          	bltu	a3,a4,842 <free+0x50>
{
 832:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 834:	fed7fae3          	bgeu	a5,a3,828 <free+0x36>
 838:	6398                	ld	a4,0(a5)
 83a:	00e6e463          	bltu	a3,a4,842 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83e:	fee7eae3          	bltu	a5,a4,832 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 842:	ff852583          	lw	a1,-8(a0)
 846:	6390                	ld	a2,0(a5)
 848:	02059713          	slli	a4,a1,0x20
 84c:	9301                	srli	a4,a4,0x20
 84e:	0712                	slli	a4,a4,0x4
 850:	9736                	add	a4,a4,a3
 852:	fae60ae3          	beq	a2,a4,806 <free+0x14>
    bp->s.ptr = p->s.ptr;
 856:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 85a:	4790                	lw	a2,8(a5)
 85c:	02061713          	slli	a4,a2,0x20
 860:	9301                	srli	a4,a4,0x20
 862:	0712                	slli	a4,a4,0x4
 864:	973e                	add	a4,a4,a5
 866:	fae689e3          	beq	a3,a4,818 <free+0x26>
  } else
    p->s.ptr = bp;
 86a:	e394                	sd	a3,0(a5)
  freep = p;
 86c:	00000717          	auipc	a4,0x0
 870:	12f73623          	sd	a5,300(a4) # 998 <freep>
}
 874:	6422                	ld	s0,8(sp)
 876:	0141                	addi	sp,sp,16
 878:	8082                	ret

000000000000087a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 87a:	7139                	addi	sp,sp,-64
 87c:	fc06                	sd	ra,56(sp)
 87e:	f822                	sd	s0,48(sp)
 880:	f426                	sd	s1,40(sp)
 882:	f04a                	sd	s2,32(sp)
 884:	ec4e                	sd	s3,24(sp)
 886:	e852                	sd	s4,16(sp)
 888:	e456                	sd	s5,8(sp)
 88a:	e05a                	sd	s6,0(sp)
 88c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 88e:	02051493          	slli	s1,a0,0x20
 892:	9081                	srli	s1,s1,0x20
 894:	04bd                	addi	s1,s1,15
 896:	8091                	srli	s1,s1,0x4
 898:	0014899b          	addiw	s3,s1,1
 89c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 89e:	00000517          	auipc	a0,0x0
 8a2:	0fa53503          	ld	a0,250(a0) # 998 <freep>
 8a6:	c515                	beqz	a0,8d2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8aa:	4798                	lw	a4,8(a5)
 8ac:	02977f63          	bgeu	a4,s1,8ea <malloc+0x70>
 8b0:	8a4e                	mv	s4,s3
 8b2:	0009871b          	sext.w	a4,s3
 8b6:	6685                	lui	a3,0x1
 8b8:	00d77363          	bgeu	a4,a3,8be <malloc+0x44>
 8bc:	6a05                	lui	s4,0x1
 8be:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8c6:	00000917          	auipc	s2,0x0
 8ca:	0d290913          	addi	s2,s2,210 # 998 <freep>
  if(p == (char*)-1)
 8ce:	5afd                	li	s5,-1
 8d0:	a88d                	j	942 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8d2:	00000797          	auipc	a5,0x0
 8d6:	57e78793          	addi	a5,a5,1406 # e50 <base>
 8da:	00000717          	auipc	a4,0x0
 8de:	0af73f23          	sd	a5,190(a4) # 998 <freep>
 8e2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8e4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8e8:	b7e1                	j	8b0 <malloc+0x36>
      if(p->s.size == nunits)
 8ea:	02e48b63          	beq	s1,a4,920 <malloc+0xa6>
        p->s.size -= nunits;
 8ee:	4137073b          	subw	a4,a4,s3
 8f2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f4:	1702                	slli	a4,a4,0x20
 8f6:	9301                	srli	a4,a4,0x20
 8f8:	0712                	slli	a4,a4,0x4
 8fa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8fc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 900:	00000717          	auipc	a4,0x0
 904:	08a73c23          	sd	a0,152(a4) # 998 <freep>
      return (void*)(p + 1);
 908:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 90c:	70e2                	ld	ra,56(sp)
 90e:	7442                	ld	s0,48(sp)
 910:	74a2                	ld	s1,40(sp)
 912:	7902                	ld	s2,32(sp)
 914:	69e2                	ld	s3,24(sp)
 916:	6a42                	ld	s4,16(sp)
 918:	6aa2                	ld	s5,8(sp)
 91a:	6b02                	ld	s6,0(sp)
 91c:	6121                	addi	sp,sp,64
 91e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 920:	6398                	ld	a4,0(a5)
 922:	e118                	sd	a4,0(a0)
 924:	bff1                	j	900 <malloc+0x86>
  hp->s.size = nu;
 926:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 92a:	0541                	addi	a0,a0,16
 92c:	00000097          	auipc	ra,0x0
 930:	ec6080e7          	jalr	-314(ra) # 7f2 <free>
  return freep;
 934:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 938:	d971                	beqz	a0,90c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 93c:	4798                	lw	a4,8(a5)
 93e:	fa9776e3          	bgeu	a4,s1,8ea <malloc+0x70>
    if(p == freep)
 942:	00093703          	ld	a4,0(s2)
 946:	853e                	mv	a0,a5
 948:	fef719e3          	bne	a4,a5,93a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 94c:	8552                	mv	a0,s4
 94e:	00000097          	auipc	ra,0x0
 952:	a62080e7          	jalr	-1438(ra) # 3b0 <sbrk>
  if(p == (char*)-1)
 956:	fd5518e3          	bne	a0,s5,926 <malloc+0xac>
        return 0;
 95a:	4501                	li	a0,0
 95c:	bf45                	j	90c <malloc+0x92>
