
user/_mkdir:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  int i;

  if(argc < 2){
   e:	4785                	li	a5,1
  10:	02a7d763          	bge	a5,a0,3e <main+0x3e>
  14:	00858493          	addi	s1,a1,8
  18:	ffe5091b          	addiw	s2,a0,-2
  1c:	1902                	slli	s2,s2,0x20
  1e:	02095913          	srli	s2,s2,0x20
  22:	090e                	slli	s2,s2,0x3
  24:	05c1                	addi	a1,a1,16
  26:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  28:	6088                	ld	a0,0(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	37a080e7          	jalr	890(ra) # 3a4 <mkdir>
  32:	02054463          	bltz	a0,5a <main+0x5a>
  for(i = 1; i < argc; i++){
  36:	04a1                	addi	s1,s1,8
  38:	ff2498e3          	bne	s1,s2,28 <main+0x28>
  3c:	a80d                	j	6e <main+0x6e>
    fprintf(2, "Usage: mkdir files...\n");
  3e:	00001597          	auipc	a1,0x1
  42:	93a58593          	addi	a1,a1,-1734 # 978 <malloc+0xea>
  46:	4509                	li	a0,2
  48:	00000097          	auipc	ra,0x0
  4c:	75a080e7          	jalr	1882(ra) # 7a2 <fprintf>
    exit(1);
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	2ea080e7          	jalr	746(ra) # 33c <exit>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  5a:	6090                	ld	a2,0(s1)
  5c:	00001597          	auipc	a1,0x1
  60:	93458593          	addi	a1,a1,-1740 # 990 <malloc+0x102>
  64:	4509                	li	a0,2
  66:	00000097          	auipc	ra,0x0
  6a:	73c080e7          	jalr	1852(ra) # 7a2 <fprintf>
      break;
    }
  }

  exit(0);
  6e:	4501                	li	a0,0
  70:	00000097          	auipc	ra,0x0
  74:	2cc080e7          	jalr	716(ra) # 33c <exit>

0000000000000078 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e422                	sd	s0,8(sp)
  7c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7e:	87aa                	mv	a5,a0
  80:	0585                	addi	a1,a1,1
  82:	0785                	addi	a5,a5,1
  84:	fff5c703          	lbu	a4,-1(a1)
  88:	fee78fa3          	sb	a4,-1(a5)
  8c:	fb75                	bnez	a4,80 <strcpy+0x8>
    ;
  return os;
}
  8e:	6422                	ld	s0,8(sp)
  90:	0141                	addi	sp,sp,16
  92:	8082                	ret

0000000000000094 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  94:	1141                	addi	sp,sp,-16
  96:	e422                	sd	s0,8(sp)
  98:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  9a:	00054783          	lbu	a5,0(a0)
  9e:	cb91                	beqz	a5,b2 <strcmp+0x1e>
  a0:	0005c703          	lbu	a4,0(a1)
  a4:	00f71763          	bne	a4,a5,b2 <strcmp+0x1e>
    p++, q++;
  a8:	0505                	addi	a0,a0,1
  aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	fbe5                	bnez	a5,a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b2:	0005c503          	lbu	a0,0(a1)
}
  b6:	40a7853b          	subw	a0,a5,a0
  ba:	6422                	ld	s0,8(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strlen>:

uint
strlen(const char *s)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	cf91                	beqz	a5,e6 <strlen+0x26>
  cc:	0505                	addi	a0,a0,1
  ce:	87aa                	mv	a5,a0
  d0:	4685                	li	a3,1
  d2:	9e89                	subw	a3,a3,a0
  d4:	00f6853b          	addw	a0,a3,a5
  d8:	0785                	addi	a5,a5,1
  da:	fff7c703          	lbu	a4,-1(a5)
  de:	fb7d                	bnez	a4,d4 <strlen+0x14>
    ;
  return n;
}
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret
  for(n = 0; s[n]; n++)
  e6:	4501                	li	a0,0
  e8:	bfe5                	j	e0 <strlen+0x20>

00000000000000ea <memset>:

void*
memset(void *dst, int c, uint n)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e422                	sd	s0,8(sp)
  ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f0:	ce09                	beqz	a2,10a <memset+0x20>
  f2:	87aa                	mv	a5,a0
  f4:	fff6071b          	addiw	a4,a2,-1
  f8:	1702                	slli	a4,a4,0x20
  fa:	9301                	srli	a4,a4,0x20
  fc:	0705                	addi	a4,a4,1
  fe:	972a                	add	a4,a4,a0
    cdst[i] = c;
 100:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 104:	0785                	addi	a5,a5,1
 106:	fee79de3          	bne	a5,a4,100 <memset+0x16>
  }
  return dst;
}
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret

0000000000000110 <strchr>:

char*
strchr(const char *s, char c)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  for(; *s; s++)
 116:	00054783          	lbu	a5,0(a0)
 11a:	cb99                	beqz	a5,130 <strchr+0x20>
    if(*s == c)
 11c:	00f58763          	beq	a1,a5,12a <strchr+0x1a>
  for(; *s; s++)
 120:	0505                	addi	a0,a0,1
 122:	00054783          	lbu	a5,0(a0)
 126:	fbfd                	bnez	a5,11c <strchr+0xc>
      return (char*)s;
  return 0;
 128:	4501                	li	a0,0
}
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret
  return 0;
 130:	4501                	li	a0,0
 132:	bfe5                	j	12a <strchr+0x1a>

0000000000000134 <gets>:

char*
gets(char *buf, int max)
{
 134:	711d                	addi	sp,sp,-96
 136:	ec86                	sd	ra,88(sp)
 138:	e8a2                	sd	s0,80(sp)
 13a:	e4a6                	sd	s1,72(sp)
 13c:	e0ca                	sd	s2,64(sp)
 13e:	fc4e                	sd	s3,56(sp)
 140:	f852                	sd	s4,48(sp)
 142:	f456                	sd	s5,40(sp)
 144:	f05a                	sd	s6,32(sp)
 146:	ec5e                	sd	s7,24(sp)
 148:	1080                	addi	s0,sp,96
 14a:	8baa                	mv	s7,a0
 14c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14e:	892a                	mv	s2,a0
 150:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 152:	4aa9                	li	s5,10
 154:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 156:	89a6                	mv	s3,s1
 158:	2485                	addiw	s1,s1,1
 15a:	0344d863          	bge	s1,s4,18a <gets+0x56>
    cc = read(0, &c, 1);
 15e:	4605                	li	a2,1
 160:	faf40593          	addi	a1,s0,-81
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	1ee080e7          	jalr	494(ra) # 354 <read>
    if(cc < 1)
 16e:	00a05e63          	blez	a0,18a <gets+0x56>
    buf[i++] = c;
 172:	faf44783          	lbu	a5,-81(s0)
 176:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17a:	01578763          	beq	a5,s5,188 <gets+0x54>
 17e:	0905                	addi	s2,s2,1
 180:	fd679be3          	bne	a5,s6,156 <gets+0x22>
  for(i=0; i+1 < max; ){
 184:	89a6                	mv	s3,s1
 186:	a011                	j	18a <gets+0x56>
 188:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18a:	99de                	add	s3,s3,s7
 18c:	00098023          	sb	zero,0(s3)
  return buf;
}
 190:	855e                	mv	a0,s7
 192:	60e6                	ld	ra,88(sp)
 194:	6446                	ld	s0,80(sp)
 196:	64a6                	ld	s1,72(sp)
 198:	6906                	ld	s2,64(sp)
 19a:	79e2                	ld	s3,56(sp)
 19c:	7a42                	ld	s4,48(sp)
 19e:	7aa2                	ld	s5,40(sp)
 1a0:	7b02                	ld	s6,32(sp)
 1a2:	6be2                	ld	s7,24(sp)
 1a4:	6125                	addi	sp,sp,96
 1a6:	8082                	ret

00000000000001a8 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ae:	00054603          	lbu	a2,0(a0)
 1b2:	fd06079b          	addiw	a5,a2,-48
 1b6:	0ff7f793          	andi	a5,a5,255
 1ba:	4725                	li	a4,9
 1bc:	02f76963          	bltu	a4,a5,1ee <atoi+0x46>
 1c0:	86aa                	mv	a3,a0
  n = 0;
 1c2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1c4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1c6:	0685                	addi	a3,a3,1
 1c8:	0025179b          	slliw	a5,a0,0x2
 1cc:	9fa9                	addw	a5,a5,a0
 1ce:	0017979b          	slliw	a5,a5,0x1
 1d2:	9fb1                	addw	a5,a5,a2
 1d4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d8:	0006c603          	lbu	a2,0(a3)
 1dc:	fd06071b          	addiw	a4,a2,-48
 1e0:	0ff77713          	andi	a4,a4,255
 1e4:	fee5f1e3          	bgeu	a1,a4,1c6 <atoi+0x1e>
  return n;
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret
  n = 0;
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <atoi+0x40>

00000000000001f2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f8:	02b57663          	bgeu	a0,a1,224 <memmove+0x32>
    while(n-- > 0)
 1fc:	02c05163          	blez	a2,21e <memmove+0x2c>
 200:	fff6079b          	addiw	a5,a2,-1
 204:	1782                	slli	a5,a5,0x20
 206:	9381                	srli	a5,a5,0x20
 208:	0785                	addi	a5,a5,1
 20a:	97aa                	add	a5,a5,a0
  dst = vdst;
 20c:	872a                	mv	a4,a0
      *dst++ = *src++;
 20e:	0585                	addi	a1,a1,1
 210:	0705                	addi	a4,a4,1
 212:	fff5c683          	lbu	a3,-1(a1)
 216:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 21a:	fee79ae3          	bne	a5,a4,20e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 21e:	6422                	ld	s0,8(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret
    dst += n;
 224:	00c50733          	add	a4,a0,a2
    src += n;
 228:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 22a:	fec05ae3          	blez	a2,21e <memmove+0x2c>
 22e:	fff6079b          	addiw	a5,a2,-1
 232:	1782                	slli	a5,a5,0x20
 234:	9381                	srli	a5,a5,0x20
 236:	fff7c793          	not	a5,a5
 23a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 23c:	15fd                	addi	a1,a1,-1
 23e:	177d                	addi	a4,a4,-1
 240:	0005c683          	lbu	a3,0(a1)
 244:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 248:	fee79ae3          	bne	a5,a4,23c <memmove+0x4a>
 24c:	bfc9                	j	21e <memmove+0x2c>

000000000000024e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 254:	ca05                	beqz	a2,284 <memcmp+0x36>
 256:	fff6069b          	addiw	a3,a2,-1
 25a:	1682                	slli	a3,a3,0x20
 25c:	9281                	srli	a3,a3,0x20
 25e:	0685                	addi	a3,a3,1
 260:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 262:	00054783          	lbu	a5,0(a0)
 266:	0005c703          	lbu	a4,0(a1)
 26a:	00e79863          	bne	a5,a4,27a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 26e:	0505                	addi	a0,a0,1
    p2++;
 270:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 272:	fed518e3          	bne	a0,a3,262 <memcmp+0x14>
  }
  return 0;
 276:	4501                	li	a0,0
 278:	a019                	j	27e <memcmp+0x30>
      return *p1 - *p2;
 27a:	40e7853b          	subw	a0,a5,a4
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  return 0;
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <memcmp+0x30>

0000000000000288 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e406                	sd	ra,8(sp)
 28c:	e022                	sd	s0,0(sp)
 28e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 290:	00000097          	auipc	ra,0x0
 294:	f62080e7          	jalr	-158(ra) # 1f2 <memmove>
}
 298:	60a2                	ld	ra,8(sp)
 29a:	6402                	ld	s0,0(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret

00000000000002a0 <close>:

int close(int fd){
 2a0:	1101                	addi	sp,sp,-32
 2a2:	ec06                	sd	ra,24(sp)
 2a4:	e822                	sd	s0,16(sp)
 2a6:	e426                	sd	s1,8(sp)
 2a8:	1000                	addi	s0,sp,32
 2aa:	84aa                	mv	s1,a0
  fflush(fd);
 2ac:	00000097          	auipc	ra,0x0
 2b0:	2d4080e7          	jalr	724(ra) # 580 <fflush>
  char* buf = get_putc_buf(fd);
 2b4:	8526                	mv	a0,s1
 2b6:	00000097          	auipc	ra,0x0
 2ba:	14e080e7          	jalr	334(ra) # 404 <get_putc_buf>
  if(buf){
 2be:	cd11                	beqz	a0,2da <close+0x3a>
    free(buf);
 2c0:	00000097          	auipc	ra,0x0
 2c4:	546080e7          	jalr	1350(ra) # 806 <free>
    putc_buf[fd] = 0;
 2c8:	00349713          	slli	a4,s1,0x3
 2cc:	00000797          	auipc	a5,0x0
 2d0:	70c78793          	addi	a5,a5,1804 # 9d8 <putc_buf>
 2d4:	97ba                	add	a5,a5,a4
 2d6:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 2da:	8526                	mv	a0,s1
 2dc:	00000097          	auipc	ra,0x0
 2e0:	088080e7          	jalr	136(ra) # 364 <sclose>
}
 2e4:	60e2                	ld	ra,24(sp)
 2e6:	6442                	ld	s0,16(sp)
 2e8:	64a2                	ld	s1,8(sp)
 2ea:	6105                	addi	sp,sp,32
 2ec:	8082                	ret

00000000000002ee <stat>:
{
 2ee:	1101                	addi	sp,sp,-32
 2f0:	ec06                	sd	ra,24(sp)
 2f2:	e822                	sd	s0,16(sp)
 2f4:	e426                	sd	s1,8(sp)
 2f6:	e04a                	sd	s2,0(sp)
 2f8:	1000                	addi	s0,sp,32
 2fa:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 2fc:	4581                	li	a1,0
 2fe:	00000097          	auipc	ra,0x0
 302:	07e080e7          	jalr	126(ra) # 37c <open>
  if(fd < 0)
 306:	02054563          	bltz	a0,330 <stat+0x42>
 30a:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 30c:	85ca                	mv	a1,s2
 30e:	00000097          	auipc	ra,0x0
 312:	086080e7          	jalr	134(ra) # 394 <fstat>
 316:	892a                	mv	s2,a0
  close(fd);
 318:	8526                	mv	a0,s1
 31a:	00000097          	auipc	ra,0x0
 31e:	f86080e7          	jalr	-122(ra) # 2a0 <close>
}
 322:	854a                	mv	a0,s2
 324:	60e2                	ld	ra,24(sp)
 326:	6442                	ld	s0,16(sp)
 328:	64a2                	ld	s1,8(sp)
 32a:	6902                	ld	s2,0(sp)
 32c:	6105                	addi	sp,sp,32
 32e:	8082                	ret
    return -1;
 330:	597d                	li	s2,-1
 332:	bfc5                	j	322 <stat+0x34>

0000000000000334 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 334:	4885                	li	a7,1
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <exit>:
.global exit
exit:
 li a7, SYS_exit
 33c:	4889                	li	a7,2
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <wait>:
.global wait
wait:
 li a7, SYS_wait
 344:	488d                	li	a7,3
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34c:	4891                	li	a7,4
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <read>:
.global read
read:
 li a7, SYS_read
 354:	4895                	li	a7,5
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <write>:
.global write
write:
 li a7, SYS_write
 35c:	48c1                	li	a7,16
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 364:	48d5                	li	a7,21
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <kill>:
.global kill
kill:
 li a7, SYS_kill
 36c:	4899                	li	a7,6
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <exec>:
.global exec
exec:
 li a7, SYS_exec
 374:	489d                	li	a7,7
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <open>:
.global open
open:
 li a7, SYS_open
 37c:	48bd                	li	a7,15
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 384:	48c5                	li	a7,17
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38c:	48c9                	li	a7,18
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 394:	48a1                	li	a7,8
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <link>:
.global link
link:
 li a7, SYS_link
 39c:	48cd                	li	a7,19
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a4:	48d1                	li	a7,20
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ac:	48a5                	li	a7,9
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b4:	48a9                	li	a7,10
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3bc:	48ad                	li	a7,11
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c4:	48b1                	li	a7,12
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3cc:	48b5                	li	a7,13
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d4:	48b9                	li	a7,14
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 3dc:	48d9                	li	a7,22
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <nice>:
.global nice
nice:
 li a7, SYS_nice
 3e4:	48dd                	li	a7,23
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 3ec:	48e1                	li	a7,24
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 3f4:	48e5                	li	a7,25
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 3fc:	48e9                	li	a7,26
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 404:	1101                	addi	sp,sp,-32
 406:	ec06                	sd	ra,24(sp)
 408:	e822                	sd	s0,16(sp)
 40a:	e426                	sd	s1,8(sp)
 40c:	1000                	addi	s0,sp,32
 40e:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 410:	00351713          	slli	a4,a0,0x3
 414:	00000797          	auipc	a5,0x0
 418:	5c478793          	addi	a5,a5,1476 # 9d8 <putc_buf>
 41c:	97ba                	add	a5,a5,a4
 41e:	6388                	ld	a0,0(a5)
  if(buf) {
 420:	c511                	beqz	a0,42c <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	64a2                	ld	s1,8(sp)
 428:	6105                	addi	sp,sp,32
 42a:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 42c:	6505                	lui	a0,0x1
 42e:	00000097          	auipc	ra,0x0
 432:	460080e7          	jalr	1120(ra) # 88e <malloc>
  putc_buf[fd] = buf;
 436:	00000797          	auipc	a5,0x0
 43a:	5a278793          	addi	a5,a5,1442 # 9d8 <putc_buf>
 43e:	00349713          	slli	a4,s1,0x3
 442:	973e                	add	a4,a4,a5
 444:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 446:	048a                	slli	s1,s1,0x2
 448:	94be                	add	s1,s1,a5
 44a:	3204a023          	sw	zero,800(s1)
  return buf;
 44e:	bfd1                	j	422 <get_putc_buf+0x1e>

0000000000000450 <putc>:

static void
putc(int fd, char c)
{
 450:	1101                	addi	sp,sp,-32
 452:	ec06                	sd	ra,24(sp)
 454:	e822                	sd	s0,16(sp)
 456:	e426                	sd	s1,8(sp)
 458:	e04a                	sd	s2,0(sp)
 45a:	1000                	addi	s0,sp,32
 45c:	84aa                	mv	s1,a0
 45e:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 460:	00000097          	auipc	ra,0x0
 464:	fa4080e7          	jalr	-92(ra) # 404 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 468:	00249793          	slli	a5,s1,0x2
 46c:	00000717          	auipc	a4,0x0
 470:	56c70713          	addi	a4,a4,1388 # 9d8 <putc_buf>
 474:	973e                	add	a4,a4,a5
 476:	32072783          	lw	a5,800(a4)
 47a:	0017869b          	addiw	a3,a5,1
 47e:	32d72023          	sw	a3,800(a4)
 482:	97aa                	add	a5,a5,a0
 484:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 488:	47a9                	li	a5,10
 48a:	02f90463          	beq	s2,a5,4b2 <putc+0x62>
 48e:	00249713          	slli	a4,s1,0x2
 492:	00000797          	auipc	a5,0x0
 496:	54678793          	addi	a5,a5,1350 # 9d8 <putc_buf>
 49a:	97ba                	add	a5,a5,a4
 49c:	3207a703          	lw	a4,800(a5)
 4a0:	6785                	lui	a5,0x1
 4a2:	00f70863          	beq	a4,a5,4b2 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 4a6:	60e2                	ld	ra,24(sp)
 4a8:	6442                	ld	s0,16(sp)
 4aa:	64a2                	ld	s1,8(sp)
 4ac:	6902                	ld	s2,0(sp)
 4ae:	6105                	addi	sp,sp,32
 4b0:	8082                	ret
    write(fd, buf, putc_index[fd]);
 4b2:	00249793          	slli	a5,s1,0x2
 4b6:	00000917          	auipc	s2,0x0
 4ba:	52290913          	addi	s2,s2,1314 # 9d8 <putc_buf>
 4be:	993e                	add	s2,s2,a5
 4c0:	32092603          	lw	a2,800(s2)
 4c4:	85aa                	mv	a1,a0
 4c6:	8526                	mv	a0,s1
 4c8:	00000097          	auipc	ra,0x0
 4cc:	e94080e7          	jalr	-364(ra) # 35c <write>
    putc_index[fd] = 0;
 4d0:	32092023          	sw	zero,800(s2)
}
 4d4:	bfc9                	j	4a6 <putc+0x56>

00000000000004d6 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4d6:	7139                	addi	sp,sp,-64
 4d8:	fc06                	sd	ra,56(sp)
 4da:	f822                	sd	s0,48(sp)
 4dc:	f426                	sd	s1,40(sp)
 4de:	f04a                	sd	s2,32(sp)
 4e0:	ec4e                	sd	s3,24(sp)
 4e2:	0080                	addi	s0,sp,64
 4e4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e6:	c299                	beqz	a3,4ec <printint+0x16>
 4e8:	0805c863          	bltz	a1,578 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ec:	2581                	sext.w	a1,a1
  neg = 0;
 4ee:	4881                	li	a7,0
 4f0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f6:	2601                	sext.w	a2,a2
 4f8:	00000517          	auipc	a0,0x0
 4fc:	4c050513          	addi	a0,a0,1216 # 9b8 <digits>
 500:	883a                	mv	a6,a4
 502:	2705                	addiw	a4,a4,1
 504:	02c5f7bb          	remuw	a5,a1,a2
 508:	1782                	slli	a5,a5,0x20
 50a:	9381                	srli	a5,a5,0x20
 50c:	97aa                	add	a5,a5,a0
 50e:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x168>
 512:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 516:	0005879b          	sext.w	a5,a1
 51a:	02c5d5bb          	divuw	a1,a1,a2
 51e:	0685                	addi	a3,a3,1
 520:	fec7f0e3          	bgeu	a5,a2,500 <printint+0x2a>
  if(neg)
 524:	00088b63          	beqz	a7,53a <printint+0x64>
    buf[i++] = '-';
 528:	fd040793          	addi	a5,s0,-48
 52c:	973e                	add	a4,a4,a5
 52e:	02d00793          	li	a5,45
 532:	fef70823          	sb	a5,-16(a4)
 536:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 53a:	02e05863          	blez	a4,56a <printint+0x94>
 53e:	fc040793          	addi	a5,s0,-64
 542:	00e78933          	add	s2,a5,a4
 546:	fff78993          	addi	s3,a5,-1
 54a:	99ba                	add	s3,s3,a4
 54c:	377d                	addiw	a4,a4,-1
 54e:	1702                	slli	a4,a4,0x20
 550:	9301                	srli	a4,a4,0x20
 552:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 556:	fff94583          	lbu	a1,-1(s2)
 55a:	8526                	mv	a0,s1
 55c:	00000097          	auipc	ra,0x0
 560:	ef4080e7          	jalr	-268(ra) # 450 <putc>
  while(--i >= 0)
 564:	197d                	addi	s2,s2,-1
 566:	ff3918e3          	bne	s2,s3,556 <printint+0x80>
}
 56a:	70e2                	ld	ra,56(sp)
 56c:	7442                	ld	s0,48(sp)
 56e:	74a2                	ld	s1,40(sp)
 570:	7902                	ld	s2,32(sp)
 572:	69e2                	ld	s3,24(sp)
 574:	6121                	addi	sp,sp,64
 576:	8082                	ret
    x = -xx;
 578:	40b005bb          	negw	a1,a1
    neg = 1;
 57c:	4885                	li	a7,1
    x = -xx;
 57e:	bf8d                	j	4f0 <printint+0x1a>

0000000000000580 <fflush>:
void fflush(int fd){
 580:	1101                	addi	sp,sp,-32
 582:	ec06                	sd	ra,24(sp)
 584:	e822                	sd	s0,16(sp)
 586:	e426                	sd	s1,8(sp)
 588:	e04a                	sd	s2,0(sp)
 58a:	1000                	addi	s0,sp,32
 58c:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 58e:	00000097          	auipc	ra,0x0
 592:	e76080e7          	jalr	-394(ra) # 404 <get_putc_buf>
 596:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 598:	00291793          	slli	a5,s2,0x2
 59c:	00000497          	auipc	s1,0x0
 5a0:	43c48493          	addi	s1,s1,1084 # 9d8 <putc_buf>
 5a4:	94be                	add	s1,s1,a5
 5a6:	3204a603          	lw	a2,800(s1)
 5aa:	854a                	mv	a0,s2
 5ac:	00000097          	auipc	ra,0x0
 5b0:	db0080e7          	jalr	-592(ra) # 35c <write>
  putc_index[fd] = 0;
 5b4:	3204a023          	sw	zero,800(s1)
}
 5b8:	60e2                	ld	ra,24(sp)
 5ba:	6442                	ld	s0,16(sp)
 5bc:	64a2                	ld	s1,8(sp)
 5be:	6902                	ld	s2,0(sp)
 5c0:	6105                	addi	sp,sp,32
 5c2:	8082                	ret

00000000000005c4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c4:	7119                	addi	sp,sp,-128
 5c6:	fc86                	sd	ra,120(sp)
 5c8:	f8a2                	sd	s0,112(sp)
 5ca:	f4a6                	sd	s1,104(sp)
 5cc:	f0ca                	sd	s2,96(sp)
 5ce:	ecce                	sd	s3,88(sp)
 5d0:	e8d2                	sd	s4,80(sp)
 5d2:	e4d6                	sd	s5,72(sp)
 5d4:	e0da                	sd	s6,64(sp)
 5d6:	fc5e                	sd	s7,56(sp)
 5d8:	f862                	sd	s8,48(sp)
 5da:	f466                	sd	s9,40(sp)
 5dc:	f06a                	sd	s10,32(sp)
 5de:	ec6e                	sd	s11,24(sp)
 5e0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e2:	0005c903          	lbu	s2,0(a1)
 5e6:	18090f63          	beqz	s2,784 <vprintf+0x1c0>
 5ea:	8aaa                	mv	s5,a0
 5ec:	8b32                	mv	s6,a2
 5ee:	00158493          	addi	s1,a1,1
  state = 0;
 5f2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5f4:	02500a13          	li	s4,37
      if(c == 'd'){
 5f8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5fc:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 600:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 604:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 608:	00000b97          	auipc	s7,0x0
 60c:	3b0b8b93          	addi	s7,s7,944 # 9b8 <digits>
 610:	a839                	j	62e <vprintf+0x6a>
        putc(fd, c);
 612:	85ca                	mv	a1,s2
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e3a080e7          	jalr	-454(ra) # 450 <putc>
 61e:	a019                	j	624 <vprintf+0x60>
    } else if(state == '%'){
 620:	01498f63          	beq	s3,s4,63e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 624:	0485                	addi	s1,s1,1
 626:	fff4c903          	lbu	s2,-1(s1)
 62a:	14090d63          	beqz	s2,784 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 62e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 632:	fe0997e3          	bnez	s3,620 <vprintf+0x5c>
      if(c == '%'){
 636:	fd479ee3          	bne	a5,s4,612 <vprintf+0x4e>
        state = '%';
 63a:	89be                	mv	s3,a5
 63c:	b7e5                	j	624 <vprintf+0x60>
      if(c == 'd'){
 63e:	05878063          	beq	a5,s8,67e <vprintf+0xba>
      } else if(c == 'l') {
 642:	05978c63          	beq	a5,s9,69a <vprintf+0xd6>
      } else if(c == 'x') {
 646:	07a78863          	beq	a5,s10,6b6 <vprintf+0xf2>
      } else if(c == 'p') {
 64a:	09b78463          	beq	a5,s11,6d2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 64e:	07300713          	li	a4,115
 652:	0ce78663          	beq	a5,a4,71e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 656:	06300713          	li	a4,99
 65a:	0ee78e63          	beq	a5,a4,756 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 65e:	11478863          	beq	a5,s4,76e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 662:	85d2                	mv	a1,s4
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	dea080e7          	jalr	-534(ra) # 450 <putc>
        putc(fd, c);
 66e:	85ca                	mv	a1,s2
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	dde080e7          	jalr	-546(ra) # 450 <putc>
      }
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b765                	j	624 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 67e:	008b0913          	addi	s2,s6,8
 682:	4685                	li	a3,1
 684:	4629                	li	a2,10
 686:	000b2583          	lw	a1,0(s6)
 68a:	8556                	mv	a0,s5
 68c:	00000097          	auipc	ra,0x0
 690:	e4a080e7          	jalr	-438(ra) # 4d6 <printint>
 694:	8b4a                	mv	s6,s2
      state = 0;
 696:	4981                	li	s3,0
 698:	b771                	j	624 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 69a:	008b0913          	addi	s2,s6,8
 69e:	4681                	li	a3,0
 6a0:	4629                	li	a2,10
 6a2:	000b2583          	lw	a1,0(s6)
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	e2e080e7          	jalr	-466(ra) # 4d6 <printint>
 6b0:	8b4a                	mv	s6,s2
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bf85                	j	624 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6b6:	008b0913          	addi	s2,s6,8
 6ba:	4681                	li	a3,0
 6bc:	4641                	li	a2,16
 6be:	000b2583          	lw	a1,0(s6)
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	e12080e7          	jalr	-494(ra) # 4d6 <printint>
 6cc:	8b4a                	mv	s6,s2
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bf91                	j	624 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6d2:	008b0793          	addi	a5,s6,8
 6d6:	f8f43423          	sd	a5,-120(s0)
 6da:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6de:	03000593          	li	a1,48
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	d6c080e7          	jalr	-660(ra) # 450 <putc>
  putc(fd, 'x');
 6ec:	85ea                	mv	a1,s10
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	d60080e7          	jalr	-672(ra) # 450 <putc>
 6f8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fa:	03c9d793          	srli	a5,s3,0x3c
 6fe:	97de                	add	a5,a5,s7
 700:	0007c583          	lbu	a1,0(a5)
 704:	8556                	mv	a0,s5
 706:	00000097          	auipc	ra,0x0
 70a:	d4a080e7          	jalr	-694(ra) # 450 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70e:	0992                	slli	s3,s3,0x4
 710:	397d                	addiw	s2,s2,-1
 712:	fe0914e3          	bnez	s2,6fa <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 716:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b721                	j	624 <vprintf+0x60>
        s = va_arg(ap, char*);
 71e:	008b0993          	addi	s3,s6,8
 722:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 726:	02090163          	beqz	s2,748 <vprintf+0x184>
        while(*s != 0){
 72a:	00094583          	lbu	a1,0(s2)
 72e:	c9a1                	beqz	a1,77e <vprintf+0x1ba>
          putc(fd, *s);
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	d1e080e7          	jalr	-738(ra) # 450 <putc>
          s++;
 73a:	0905                	addi	s2,s2,1
        while(*s != 0){
 73c:	00094583          	lbu	a1,0(s2)
 740:	f9e5                	bnez	a1,730 <vprintf+0x16c>
        s = va_arg(ap, char*);
 742:	8b4e                	mv	s6,s3
      state = 0;
 744:	4981                	li	s3,0
 746:	bdf9                	j	624 <vprintf+0x60>
          s = "(null)";
 748:	00000917          	auipc	s2,0x0
 74c:	26890913          	addi	s2,s2,616 # 9b0 <malloc+0x122>
        while(*s != 0){
 750:	02800593          	li	a1,40
 754:	bff1                	j	730 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 756:	008b0913          	addi	s2,s6,8
 75a:	000b4583          	lbu	a1,0(s6)
 75e:	8556                	mv	a0,s5
 760:	00000097          	auipc	ra,0x0
 764:	cf0080e7          	jalr	-784(ra) # 450 <putc>
 768:	8b4a                	mv	s6,s2
      state = 0;
 76a:	4981                	li	s3,0
 76c:	bd65                	j	624 <vprintf+0x60>
        putc(fd, c);
 76e:	85d2                	mv	a1,s4
 770:	8556                	mv	a0,s5
 772:	00000097          	auipc	ra,0x0
 776:	cde080e7          	jalr	-802(ra) # 450 <putc>
      state = 0;
 77a:	4981                	li	s3,0
 77c:	b565                	j	624 <vprintf+0x60>
        s = va_arg(ap, char*);
 77e:	8b4e                	mv	s6,s3
      state = 0;
 780:	4981                	li	s3,0
 782:	b54d                	j	624 <vprintf+0x60>
    }
  }
}
 784:	70e6                	ld	ra,120(sp)
 786:	7446                	ld	s0,112(sp)
 788:	74a6                	ld	s1,104(sp)
 78a:	7906                	ld	s2,96(sp)
 78c:	69e6                	ld	s3,88(sp)
 78e:	6a46                	ld	s4,80(sp)
 790:	6aa6                	ld	s5,72(sp)
 792:	6b06                	ld	s6,64(sp)
 794:	7be2                	ld	s7,56(sp)
 796:	7c42                	ld	s8,48(sp)
 798:	7ca2                	ld	s9,40(sp)
 79a:	7d02                	ld	s10,32(sp)
 79c:	6de2                	ld	s11,24(sp)
 79e:	6109                	addi	sp,sp,128
 7a0:	8082                	ret

00000000000007a2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a2:	715d                	addi	sp,sp,-80
 7a4:	ec06                	sd	ra,24(sp)
 7a6:	e822                	sd	s0,16(sp)
 7a8:	1000                	addi	s0,sp,32
 7aa:	e010                	sd	a2,0(s0)
 7ac:	e414                	sd	a3,8(s0)
 7ae:	e818                	sd	a4,16(s0)
 7b0:	ec1c                	sd	a5,24(s0)
 7b2:	03043023          	sd	a6,32(s0)
 7b6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ba:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7be:	8622                	mv	a2,s0
 7c0:	00000097          	auipc	ra,0x0
 7c4:	e04080e7          	jalr	-508(ra) # 5c4 <vprintf>
}
 7c8:	60e2                	ld	ra,24(sp)
 7ca:	6442                	ld	s0,16(sp)
 7cc:	6161                	addi	sp,sp,80
 7ce:	8082                	ret

00000000000007d0 <printf>:

void
printf(const char *fmt, ...)
{
 7d0:	711d                	addi	sp,sp,-96
 7d2:	ec06                	sd	ra,24(sp)
 7d4:	e822                	sd	s0,16(sp)
 7d6:	1000                	addi	s0,sp,32
 7d8:	e40c                	sd	a1,8(s0)
 7da:	e810                	sd	a2,16(s0)
 7dc:	ec14                	sd	a3,24(s0)
 7de:	f018                	sd	a4,32(s0)
 7e0:	f41c                	sd	a5,40(s0)
 7e2:	03043823          	sd	a6,48(s0)
 7e6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ea:	00840613          	addi	a2,s0,8
 7ee:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f2:	85aa                	mv	a1,a0
 7f4:	4505                	li	a0,1
 7f6:	00000097          	auipc	ra,0x0
 7fa:	dce080e7          	jalr	-562(ra) # 5c4 <vprintf>
}
 7fe:	60e2                	ld	ra,24(sp)
 800:	6442                	ld	s0,16(sp)
 802:	6125                	addi	sp,sp,96
 804:	8082                	ret

0000000000000806 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 806:	1141                	addi	sp,sp,-16
 808:	e422                	sd	s0,8(sp)
 80a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 810:	00000797          	auipc	a5,0x0
 814:	1c07b783          	ld	a5,448(a5) # 9d0 <freep>
 818:	a805                	j	848 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 81a:	4618                	lw	a4,8(a2)
 81c:	9db9                	addw	a1,a1,a4
 81e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 822:	6398                	ld	a4,0(a5)
 824:	6318                	ld	a4,0(a4)
 826:	fee53823          	sd	a4,-16(a0)
 82a:	a091                	j	86e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 82c:	ff852703          	lw	a4,-8(a0)
 830:	9e39                	addw	a2,a2,a4
 832:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 834:	ff053703          	ld	a4,-16(a0)
 838:	e398                	sd	a4,0(a5)
 83a:	a099                	j	880 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83c:	6398                	ld	a4,0(a5)
 83e:	00e7e463          	bltu	a5,a4,846 <free+0x40>
 842:	00e6ea63          	bltu	a3,a4,856 <free+0x50>
{
 846:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 848:	fed7fae3          	bgeu	a5,a3,83c <free+0x36>
 84c:	6398                	ld	a4,0(a5)
 84e:	00e6e463          	bltu	a3,a4,856 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 852:	fee7eae3          	bltu	a5,a4,846 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 856:	ff852583          	lw	a1,-8(a0)
 85a:	6390                	ld	a2,0(a5)
 85c:	02059713          	slli	a4,a1,0x20
 860:	9301                	srli	a4,a4,0x20
 862:	0712                	slli	a4,a4,0x4
 864:	9736                	add	a4,a4,a3
 866:	fae60ae3          	beq	a2,a4,81a <free+0x14>
    bp->s.ptr = p->s.ptr;
 86a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 86e:	4790                	lw	a2,8(a5)
 870:	02061713          	slli	a4,a2,0x20
 874:	9301                	srli	a4,a4,0x20
 876:	0712                	slli	a4,a4,0x4
 878:	973e                	add	a4,a4,a5
 87a:	fae689e3          	beq	a3,a4,82c <free+0x26>
  } else
    p->s.ptr = bp;
 87e:	e394                	sd	a3,0(a5)
  freep = p;
 880:	00000717          	auipc	a4,0x0
 884:	14f73823          	sd	a5,336(a4) # 9d0 <freep>
}
 888:	6422                	ld	s0,8(sp)
 88a:	0141                	addi	sp,sp,16
 88c:	8082                	ret

000000000000088e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 88e:	7139                	addi	sp,sp,-64
 890:	fc06                	sd	ra,56(sp)
 892:	f822                	sd	s0,48(sp)
 894:	f426                	sd	s1,40(sp)
 896:	f04a                	sd	s2,32(sp)
 898:	ec4e                	sd	s3,24(sp)
 89a:	e852                	sd	s4,16(sp)
 89c:	e456                	sd	s5,8(sp)
 89e:	e05a                	sd	s6,0(sp)
 8a0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a2:	02051493          	slli	s1,a0,0x20
 8a6:	9081                	srli	s1,s1,0x20
 8a8:	04bd                	addi	s1,s1,15
 8aa:	8091                	srli	s1,s1,0x4
 8ac:	0014899b          	addiw	s3,s1,1
 8b0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8b2:	00000517          	auipc	a0,0x0
 8b6:	11e53503          	ld	a0,286(a0) # 9d0 <freep>
 8ba:	c515                	beqz	a0,8e6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8be:	4798                	lw	a4,8(a5)
 8c0:	02977f63          	bgeu	a4,s1,8fe <malloc+0x70>
 8c4:	8a4e                	mv	s4,s3
 8c6:	0009871b          	sext.w	a4,s3
 8ca:	6685                	lui	a3,0x1
 8cc:	00d77363          	bgeu	a4,a3,8d2 <malloc+0x44>
 8d0:	6a05                	lui	s4,0x1
 8d2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8da:	00000917          	auipc	s2,0x0
 8de:	0f690913          	addi	s2,s2,246 # 9d0 <freep>
  if(p == (char*)-1)
 8e2:	5afd                	li	s5,-1
 8e4:	a88d                	j	956 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8e6:	00000797          	auipc	a5,0x0
 8ea:	5a278793          	addi	a5,a5,1442 # e88 <base>
 8ee:	00000717          	auipc	a4,0x0
 8f2:	0ef73123          	sd	a5,226(a4) # 9d0 <freep>
 8f6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8fc:	b7e1                	j	8c4 <malloc+0x36>
      if(p->s.size == nunits)
 8fe:	02e48b63          	beq	s1,a4,934 <malloc+0xa6>
        p->s.size -= nunits;
 902:	4137073b          	subw	a4,a4,s3
 906:	c798                	sw	a4,8(a5)
        p += p->s.size;
 908:	1702                	slli	a4,a4,0x20
 90a:	9301                	srli	a4,a4,0x20
 90c:	0712                	slli	a4,a4,0x4
 90e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 910:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 914:	00000717          	auipc	a4,0x0
 918:	0aa73e23          	sd	a0,188(a4) # 9d0 <freep>
      return (void*)(p + 1);
 91c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 920:	70e2                	ld	ra,56(sp)
 922:	7442                	ld	s0,48(sp)
 924:	74a2                	ld	s1,40(sp)
 926:	7902                	ld	s2,32(sp)
 928:	69e2                	ld	s3,24(sp)
 92a:	6a42                	ld	s4,16(sp)
 92c:	6aa2                	ld	s5,8(sp)
 92e:	6b02                	ld	s6,0(sp)
 930:	6121                	addi	sp,sp,64
 932:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 934:	6398                	ld	a4,0(a5)
 936:	e118                	sd	a4,0(a0)
 938:	bff1                	j	914 <malloc+0x86>
  hp->s.size = nu;
 93a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 93e:	0541                	addi	a0,a0,16
 940:	00000097          	auipc	ra,0x0
 944:	ec6080e7          	jalr	-314(ra) # 806 <free>
  return freep;
 948:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 94c:	d971                	beqz	a0,920 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 94e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 950:	4798                	lw	a4,8(a5)
 952:	fa9776e3          	bgeu	a4,s1,8fe <malloc+0x70>
    if(p == freep)
 956:	00093703          	ld	a4,0(s2)
 95a:	853e                	mv	a0,a5
 95c:	fef719e3          	bne	a4,a5,94e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 960:	8552                	mv	a0,s4
 962:	00000097          	auipc	ra,0x0
 966:	a62080e7          	jalr	-1438(ra) # 3c4 <sbrk>
  if(p == (char*)-1)
 96a:	fd5518e3          	bne	a0,s5,93a <malloc+0xac>
        return 0;
 96e:	4501                	li	a0,0
 970:	bf45                	j	920 <malloc+0x92>
