
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	a7890913          	addi	s2,s2,-1416 # a88 <buf>
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	3d4080e7          	jalr	980(ra) # 3f4 <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05863          	blez	a0,5a <cat+0x5a>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	3c8080e7          	jalr	968(ra) # 3fc <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      printf("cat: write error\n");
  40:	00001517          	auipc	a0,0x1
  44:	9d850513          	addi	a0,a0,-1576 # a18 <malloc+0xea>
  48:	00001097          	auipc	ra,0x1
  4c:	828080e7          	jalr	-2008(ra) # 870 <printf>
      exit(1);
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	38a080e7          	jalr	906(ra) # 3dc <exit>
    }
  }
  if(n < 0){
  5a:	00054963          	bltz	a0,6c <cat+0x6c>
    printf("cat: read error\n");
    exit(1);
  }
}
  5e:	70a2                	ld	ra,40(sp)
  60:	7402                	ld	s0,32(sp)
  62:	64e2                	ld	s1,24(sp)
  64:	6942                	ld	s2,16(sp)
  66:	69a2                	ld	s3,8(sp)
  68:	6145                	addi	sp,sp,48
  6a:	8082                	ret
    printf("cat: read error\n");
  6c:	00001517          	auipc	a0,0x1
  70:	9c450513          	addi	a0,a0,-1596 # a30 <malloc+0x102>
  74:	00000097          	auipc	ra,0x0
  78:	7fc080e7          	jalr	2044(ra) # 870 <printf>
    exit(1);
  7c:	4505                	li	a0,1
  7e:	00000097          	auipc	ra,0x0
  82:	35e080e7          	jalr	862(ra) # 3dc <exit>

0000000000000086 <main>:

int
main(int argc, char *argv[])
{
  86:	7179                	addi	sp,sp,-48
  88:	f406                	sd	ra,40(sp)
  8a:	f022                	sd	s0,32(sp)
  8c:	ec26                	sd	s1,24(sp)
  8e:	e84a                	sd	s2,16(sp)
  90:	e44e                	sd	s3,8(sp)
  92:	e052                	sd	s4,0(sp)
  94:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  96:	4785                	li	a5,1
  98:	04a7d763          	bge	a5,a0,e6 <main+0x60>
  9c:	00858913          	addi	s2,a1,8
  a0:	ffe5099b          	addiw	s3,a0,-2
  a4:	1982                	slli	s3,s3,0x20
  a6:	0209d993          	srli	s3,s3,0x20
  aa:	098e                	slli	s3,s3,0x3
  ac:	05c1                	addi	a1,a1,16
  ae:	99ae                	add	s3,s3,a1
    cat(0);
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b0:	4581                	li	a1,0
  b2:	00093503          	ld	a0,0(s2)
  b6:	00000097          	auipc	ra,0x0
  ba:	366080e7          	jalr	870(ra) # 41c <open>
  be:	84aa                	mv	s1,a0
  c0:	02054d63          	bltz	a0,fa <main+0x74>
      printf("cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c4:	00000097          	auipc	ra,0x0
  c8:	f3c080e7          	jalr	-196(ra) # 0 <cat>
    close(fd);
  cc:	8526                	mv	a0,s1
  ce:	00000097          	auipc	ra,0x0
  d2:	272080e7          	jalr	626(ra) # 340 <close>
  for(i = 1; i < argc; i++){
  d6:	0921                	addi	s2,s2,8
  d8:	fd391ce3          	bne	s2,s3,b0 <main+0x2a>
  }
  exit(0);
  dc:	4501                	li	a0,0
  de:	00000097          	auipc	ra,0x0
  e2:	2fe080e7          	jalr	766(ra) # 3dc <exit>
    cat(0);
  e6:	4501                	li	a0,0
  e8:	00000097          	auipc	ra,0x0
  ec:	f18080e7          	jalr	-232(ra) # 0 <cat>
    exit(1);
  f0:	4505                	li	a0,1
  f2:	00000097          	auipc	ra,0x0
  f6:	2ea080e7          	jalr	746(ra) # 3dc <exit>
      printf("cat: cannot open %s\n", argv[i]);
  fa:	00093583          	ld	a1,0(s2)
  fe:	00001517          	auipc	a0,0x1
 102:	94a50513          	addi	a0,a0,-1718 # a48 <malloc+0x11a>
 106:	00000097          	auipc	ra,0x0
 10a:	76a080e7          	jalr	1898(ra) # 870 <printf>
      exit(1);
 10e:	4505                	li	a0,1
 110:	00000097          	auipc	ra,0x0
 114:	2cc080e7          	jalr	716(ra) # 3dc <exit>

0000000000000118 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11e:	87aa                	mv	a5,a0
 120:	0585                	addi	a1,a1,1
 122:	0785                	addi	a5,a5,1
 124:	fff5c703          	lbu	a4,-1(a1)
 128:	fee78fa3          	sb	a4,-1(a5)
 12c:	fb75                	bnez	a4,120 <strcpy+0x8>
    ;
  return os;
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb91                	beqz	a5,152 <strcmp+0x1e>
 140:	0005c703          	lbu	a4,0(a1)
 144:	00f71763          	bne	a4,a5,152 <strcmp+0x1e>
    p++, q++;
 148:	0505                	addi	a0,a0,1
 14a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbe5                	bnez	a5,140 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 152:	0005c503          	lbu	a0,0(a1)
}
 156:	40a7853b          	subw	a0,a5,a0
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strlen>:

uint
strlen(const char *s)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cf91                	beqz	a5,186 <strlen+0x26>
 16c:	0505                	addi	a0,a0,1
 16e:	87aa                	mv	a5,a0
 170:	4685                	li	a3,1
 172:	9e89                	subw	a3,a3,a0
 174:	00f6853b          	addw	a0,a3,a5
 178:	0785                	addi	a5,a5,1
 17a:	fff7c703          	lbu	a4,-1(a5)
 17e:	fb7d                	bnez	a4,174 <strlen+0x14>
    ;
  return n;
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret
  for(n = 0; s[n]; n++)
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strlen+0x20>

000000000000018a <memset>:

void*
memset(void *dst, int c, uint n)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 190:	ce09                	beqz	a2,1aa <memset+0x20>
 192:	87aa                	mv	a5,a0
 194:	fff6071b          	addiw	a4,a2,-1
 198:	1702                	slli	a4,a4,0x20
 19a:	9301                	srli	a4,a4,0x20
 19c:	0705                	addi	a4,a4,1
 19e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1a0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a4:	0785                	addi	a5,a5,1
 1a6:	fee79de3          	bne	a5,a4,1a0 <memset+0x16>
  }
  return dst;
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret

00000000000001b0 <strchr>:

char*
strchr(const char *s, char c)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	cb99                	beqz	a5,1d0 <strchr+0x20>
    if(*s == c)
 1bc:	00f58763          	beq	a1,a5,1ca <strchr+0x1a>
  for(; *s; s++)
 1c0:	0505                	addi	a0,a0,1
 1c2:	00054783          	lbu	a5,0(a0)
 1c6:	fbfd                	bnez	a5,1bc <strchr+0xc>
      return (char*)s;
  return 0;
 1c8:	4501                	li	a0,0
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret
  return 0;
 1d0:	4501                	li	a0,0
 1d2:	bfe5                	j	1ca <strchr+0x1a>

00000000000001d4 <gets>:

char*
gets(char *buf, int max)
{
 1d4:	711d                	addi	sp,sp,-96
 1d6:	ec86                	sd	ra,88(sp)
 1d8:	e8a2                	sd	s0,80(sp)
 1da:	e4a6                	sd	s1,72(sp)
 1dc:	e0ca                	sd	s2,64(sp)
 1de:	fc4e                	sd	s3,56(sp)
 1e0:	f852                	sd	s4,48(sp)
 1e2:	f456                	sd	s5,40(sp)
 1e4:	f05a                	sd	s6,32(sp)
 1e6:	ec5e                	sd	s7,24(sp)
 1e8:	1080                	addi	s0,sp,96
 1ea:	8baa                	mv	s7,a0
 1ec:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ee:	892a                	mv	s2,a0
 1f0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f2:	4aa9                	li	s5,10
 1f4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f6:	89a6                	mv	s3,s1
 1f8:	2485                	addiw	s1,s1,1
 1fa:	0344d863          	bge	s1,s4,22a <gets+0x56>
    cc = read(0, &c, 1);
 1fe:	4605                	li	a2,1
 200:	faf40593          	addi	a1,s0,-81
 204:	4501                	li	a0,0
 206:	00000097          	auipc	ra,0x0
 20a:	1ee080e7          	jalr	494(ra) # 3f4 <read>
    if(cc < 1)
 20e:	00a05e63          	blez	a0,22a <gets+0x56>
    buf[i++] = c;
 212:	faf44783          	lbu	a5,-81(s0)
 216:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 21a:	01578763          	beq	a5,s5,228 <gets+0x54>
 21e:	0905                	addi	s2,s2,1
 220:	fd679be3          	bne	a5,s6,1f6 <gets+0x22>
  for(i=0; i+1 < max; ){
 224:	89a6                	mv	s3,s1
 226:	a011                	j	22a <gets+0x56>
 228:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 22a:	99de                	add	s3,s3,s7
 22c:	00098023          	sb	zero,0(s3)
  return buf;
}
 230:	855e                	mv	a0,s7
 232:	60e6                	ld	ra,88(sp)
 234:	6446                	ld	s0,80(sp)
 236:	64a6                	ld	s1,72(sp)
 238:	6906                	ld	s2,64(sp)
 23a:	79e2                	ld	s3,56(sp)
 23c:	7a42                	ld	s4,48(sp)
 23e:	7aa2                	ld	s5,40(sp)
 240:	7b02                	ld	s6,32(sp)
 242:	6be2                	ld	s7,24(sp)
 244:	6125                	addi	sp,sp,96
 246:	8082                	ret

0000000000000248 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24e:	00054603          	lbu	a2,0(a0)
 252:	fd06079b          	addiw	a5,a2,-48
 256:	0ff7f793          	andi	a5,a5,255
 25a:	4725                	li	a4,9
 25c:	02f76963          	bltu	a4,a5,28e <atoi+0x46>
 260:	86aa                	mv	a3,a0
  n = 0;
 262:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 264:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 266:	0685                	addi	a3,a3,1
 268:	0025179b          	slliw	a5,a0,0x2
 26c:	9fa9                	addw	a5,a5,a0
 26e:	0017979b          	slliw	a5,a5,0x1
 272:	9fb1                	addw	a5,a5,a2
 274:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 278:	0006c603          	lbu	a2,0(a3)
 27c:	fd06071b          	addiw	a4,a2,-48
 280:	0ff77713          	andi	a4,a4,255
 284:	fee5f1e3          	bgeu	a1,a4,266 <atoi+0x1e>
  return n;
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  n = 0;
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <atoi+0x40>

0000000000000292 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 292:	1141                	addi	sp,sp,-16
 294:	e422                	sd	s0,8(sp)
 296:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 298:	02b57663          	bgeu	a0,a1,2c4 <memmove+0x32>
    while(n-- > 0)
 29c:	02c05163          	blez	a2,2be <memmove+0x2c>
 2a0:	fff6079b          	addiw	a5,a2,-1
 2a4:	1782                	slli	a5,a5,0x20
 2a6:	9381                	srli	a5,a5,0x20
 2a8:	0785                	addi	a5,a5,1
 2aa:	97aa                	add	a5,a5,a0
  dst = vdst;
 2ac:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ae:	0585                	addi	a1,a1,1
 2b0:	0705                	addi	a4,a4,1
 2b2:	fff5c683          	lbu	a3,-1(a1)
 2b6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ba:	fee79ae3          	bne	a5,a4,2ae <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret
    dst += n;
 2c4:	00c50733          	add	a4,a0,a2
    src += n;
 2c8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ca:	fec05ae3          	blez	a2,2be <memmove+0x2c>
 2ce:	fff6079b          	addiw	a5,a2,-1
 2d2:	1782                	slli	a5,a5,0x20
 2d4:	9381                	srli	a5,a5,0x20
 2d6:	fff7c793          	not	a5,a5
 2da:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2dc:	15fd                	addi	a1,a1,-1
 2de:	177d                	addi	a4,a4,-1
 2e0:	0005c683          	lbu	a3,0(a1)
 2e4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e8:	fee79ae3          	bne	a5,a4,2dc <memmove+0x4a>
 2ec:	bfc9                	j	2be <memmove+0x2c>

00000000000002ee <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f4:	ca05                	beqz	a2,324 <memcmp+0x36>
 2f6:	fff6069b          	addiw	a3,a2,-1
 2fa:	1682                	slli	a3,a3,0x20
 2fc:	9281                	srli	a3,a3,0x20
 2fe:	0685                	addi	a3,a3,1
 300:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 302:	00054783          	lbu	a5,0(a0)
 306:	0005c703          	lbu	a4,0(a1)
 30a:	00e79863          	bne	a5,a4,31a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 30e:	0505                	addi	a0,a0,1
    p2++;
 310:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 312:	fed518e3          	bne	a0,a3,302 <memcmp+0x14>
  }
  return 0;
 316:	4501                	li	a0,0
 318:	a019                	j	31e <memcmp+0x30>
      return *p1 - *p2;
 31a:	40e7853b          	subw	a0,a5,a4
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret
  return 0;
 324:	4501                	li	a0,0
 326:	bfe5                	j	31e <memcmp+0x30>

0000000000000328 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e406                	sd	ra,8(sp)
 32c:	e022                	sd	s0,0(sp)
 32e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 330:	00000097          	auipc	ra,0x0
 334:	f62080e7          	jalr	-158(ra) # 292 <memmove>
}
 338:	60a2                	ld	ra,8(sp)
 33a:	6402                	ld	s0,0(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret

0000000000000340 <close>:

int close(int fd){
 340:	1101                	addi	sp,sp,-32
 342:	ec06                	sd	ra,24(sp)
 344:	e822                	sd	s0,16(sp)
 346:	e426                	sd	s1,8(sp)
 348:	1000                	addi	s0,sp,32
 34a:	84aa                	mv	s1,a0
  fflush(fd);
 34c:	00000097          	auipc	ra,0x0
 350:	2d4080e7          	jalr	724(ra) # 620 <fflush>
  char* buf = get_putc_buf(fd);
 354:	8526                	mv	a0,s1
 356:	00000097          	auipc	ra,0x0
 35a:	14e080e7          	jalr	334(ra) # 4a4 <get_putc_buf>
  if(buf){
 35e:	cd11                	beqz	a0,37a <close+0x3a>
    free(buf);
 360:	00000097          	auipc	ra,0x0
 364:	546080e7          	jalr	1350(ra) # 8a6 <free>
    putc_buf[fd] = 0;
 368:	00349713          	slli	a4,s1,0x3
 36c:	00001797          	auipc	a5,0x1
 370:	91c78793          	addi	a5,a5,-1764 # c88 <putc_buf>
 374:	97ba                	add	a5,a5,a4
 376:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 37a:	8526                	mv	a0,s1
 37c:	00000097          	auipc	ra,0x0
 380:	088080e7          	jalr	136(ra) # 404 <sclose>
}
 384:	60e2                	ld	ra,24(sp)
 386:	6442                	ld	s0,16(sp)
 388:	64a2                	ld	s1,8(sp)
 38a:	6105                	addi	sp,sp,32
 38c:	8082                	ret

000000000000038e <stat>:
{
 38e:	1101                	addi	sp,sp,-32
 390:	ec06                	sd	ra,24(sp)
 392:	e822                	sd	s0,16(sp)
 394:	e426                	sd	s1,8(sp)
 396:	e04a                	sd	s2,0(sp)
 398:	1000                	addi	s0,sp,32
 39a:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 39c:	4581                	li	a1,0
 39e:	00000097          	auipc	ra,0x0
 3a2:	07e080e7          	jalr	126(ra) # 41c <open>
  if(fd < 0)
 3a6:	02054563          	bltz	a0,3d0 <stat+0x42>
 3aa:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 3ac:	85ca                	mv	a1,s2
 3ae:	00000097          	auipc	ra,0x0
 3b2:	086080e7          	jalr	134(ra) # 434 <fstat>
 3b6:	892a                	mv	s2,a0
  close(fd);
 3b8:	8526                	mv	a0,s1
 3ba:	00000097          	auipc	ra,0x0
 3be:	f86080e7          	jalr	-122(ra) # 340 <close>
}
 3c2:	854a                	mv	a0,s2
 3c4:	60e2                	ld	ra,24(sp)
 3c6:	6442                	ld	s0,16(sp)
 3c8:	64a2                	ld	s1,8(sp)
 3ca:	6902                	ld	s2,0(sp)
 3cc:	6105                	addi	sp,sp,32
 3ce:	8082                	ret
    return -1;
 3d0:	597d                	li	s2,-1
 3d2:	bfc5                	j	3c2 <stat+0x34>

00000000000003d4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d4:	4885                	li	a7,1
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3dc:	4889                	li	a7,2
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e4:	488d                	li	a7,3
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ec:	4891                	li	a7,4
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <read>:
.global read
read:
 li a7, SYS_read
 3f4:	4895                	li	a7,5
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <write>:
.global write
write:
 li a7, SYS_write
 3fc:	48c1                	li	a7,16
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 404:	48d5                	li	a7,21
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <kill>:
.global kill
kill:
 li a7, SYS_kill
 40c:	4899                	li	a7,6
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <exec>:
.global exec
exec:
 li a7, SYS_exec
 414:	489d                	li	a7,7
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <open>:
.global open
open:
 li a7, SYS_open
 41c:	48bd                	li	a7,15
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 424:	48c5                	li	a7,17
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42c:	48c9                	li	a7,18
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 434:	48a1                	li	a7,8
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <link>:
.global link
link:
 li a7, SYS_link
 43c:	48cd                	li	a7,19
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 444:	48d1                	li	a7,20
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44c:	48a5                	li	a7,9
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <dup>:
.global dup
dup:
 li a7, SYS_dup
 454:	48a9                	li	a7,10
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45c:	48ad                	li	a7,11
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 464:	48b1                	li	a7,12
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 46c:	48b5                	li	a7,13
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 474:	48b9                	li	a7,14
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 47c:	48d9                	li	a7,22
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <nice>:
.global nice
nice:
 li a7, SYS_nice
 484:	48dd                	li	a7,23
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 48c:	48e1                	li	a7,24
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 494:	48e5                	li	a7,25
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 49c:	48e9                	li	a7,26
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 4a4:	1101                	addi	sp,sp,-32
 4a6:	ec06                	sd	ra,24(sp)
 4a8:	e822                	sd	s0,16(sp)
 4aa:	e426                	sd	s1,8(sp)
 4ac:	1000                	addi	s0,sp,32
 4ae:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 4b0:	00351713          	slli	a4,a0,0x3
 4b4:	00000797          	auipc	a5,0x0
 4b8:	7d478793          	addi	a5,a5,2004 # c88 <putc_buf>
 4bc:	97ba                	add	a5,a5,a4
 4be:	6388                	ld	a0,0(a5)
  if(buf) {
 4c0:	c511                	beqz	a0,4cc <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 4c2:	60e2                	ld	ra,24(sp)
 4c4:	6442                	ld	s0,16(sp)
 4c6:	64a2                	ld	s1,8(sp)
 4c8:	6105                	addi	sp,sp,32
 4ca:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 4cc:	6505                	lui	a0,0x1
 4ce:	00000097          	auipc	ra,0x0
 4d2:	460080e7          	jalr	1120(ra) # 92e <malloc>
  putc_buf[fd] = buf;
 4d6:	00000797          	auipc	a5,0x0
 4da:	7b278793          	addi	a5,a5,1970 # c88 <putc_buf>
 4de:	00349713          	slli	a4,s1,0x3
 4e2:	973e                	add	a4,a4,a5
 4e4:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 4e6:	048a                	slli	s1,s1,0x2
 4e8:	94be                	add	s1,s1,a5
 4ea:	3204a023          	sw	zero,800(s1)
  return buf;
 4ee:	bfd1                	j	4c2 <get_putc_buf+0x1e>

00000000000004f0 <putc>:

static void
putc(int fd, char c)
{
 4f0:	1101                	addi	sp,sp,-32
 4f2:	ec06                	sd	ra,24(sp)
 4f4:	e822                	sd	s0,16(sp)
 4f6:	e426                	sd	s1,8(sp)
 4f8:	e04a                	sd	s2,0(sp)
 4fa:	1000                	addi	s0,sp,32
 4fc:	84aa                	mv	s1,a0
 4fe:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 500:	00000097          	auipc	ra,0x0
 504:	fa4080e7          	jalr	-92(ra) # 4a4 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 508:	00249793          	slli	a5,s1,0x2
 50c:	00000717          	auipc	a4,0x0
 510:	77c70713          	addi	a4,a4,1916 # c88 <putc_buf>
 514:	973e                	add	a4,a4,a5
 516:	32072783          	lw	a5,800(a4)
 51a:	0017869b          	addiw	a3,a5,1
 51e:	32d72023          	sw	a3,800(a4)
 522:	97aa                	add	a5,a5,a0
 524:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 528:	47a9                	li	a5,10
 52a:	02f90463          	beq	s2,a5,552 <putc+0x62>
 52e:	00249713          	slli	a4,s1,0x2
 532:	00000797          	auipc	a5,0x0
 536:	75678793          	addi	a5,a5,1878 # c88 <putc_buf>
 53a:	97ba                	add	a5,a5,a4
 53c:	3207a703          	lw	a4,800(a5)
 540:	6785                	lui	a5,0x1
 542:	00f70863          	beq	a4,a5,552 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 546:	60e2                	ld	ra,24(sp)
 548:	6442                	ld	s0,16(sp)
 54a:	64a2                	ld	s1,8(sp)
 54c:	6902                	ld	s2,0(sp)
 54e:	6105                	addi	sp,sp,32
 550:	8082                	ret
    write(fd, buf, putc_index[fd]);
 552:	00249793          	slli	a5,s1,0x2
 556:	00000917          	auipc	s2,0x0
 55a:	73290913          	addi	s2,s2,1842 # c88 <putc_buf>
 55e:	993e                	add	s2,s2,a5
 560:	32092603          	lw	a2,800(s2)
 564:	85aa                	mv	a1,a0
 566:	8526                	mv	a0,s1
 568:	00000097          	auipc	ra,0x0
 56c:	e94080e7          	jalr	-364(ra) # 3fc <write>
    putc_index[fd] = 0;
 570:	32092023          	sw	zero,800(s2)
}
 574:	bfc9                	j	546 <putc+0x56>

0000000000000576 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 576:	7139                	addi	sp,sp,-64
 578:	fc06                	sd	ra,56(sp)
 57a:	f822                	sd	s0,48(sp)
 57c:	f426                	sd	s1,40(sp)
 57e:	f04a                	sd	s2,32(sp)
 580:	ec4e                	sd	s3,24(sp)
 582:	0080                	addi	s0,sp,64
 584:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 586:	c299                	beqz	a3,58c <printint+0x16>
 588:	0805c863          	bltz	a1,618 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 58c:	2581                	sext.w	a1,a1
  neg = 0;
 58e:	4881                	li	a7,0
 590:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 594:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 596:	2601                	sext.w	a2,a2
 598:	00000517          	auipc	a0,0x0
 59c:	4d050513          	addi	a0,a0,1232 # a68 <digits>
 5a0:	883a                	mv	a6,a4
 5a2:	2705                	addiw	a4,a4,1
 5a4:	02c5f7bb          	remuw	a5,a1,a2
 5a8:	1782                	slli	a5,a5,0x20
 5aa:	9381                	srli	a5,a5,0x20
 5ac:	97aa                	add	a5,a5,a0
 5ae:	0007c783          	lbu	a5,0(a5) # 1000 <putc_index+0x58>
 5b2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5b6:	0005879b          	sext.w	a5,a1
 5ba:	02c5d5bb          	divuw	a1,a1,a2
 5be:	0685                	addi	a3,a3,1
 5c0:	fec7f0e3          	bgeu	a5,a2,5a0 <printint+0x2a>
  if(neg)
 5c4:	00088b63          	beqz	a7,5da <printint+0x64>
    buf[i++] = '-';
 5c8:	fd040793          	addi	a5,s0,-48
 5cc:	973e                	add	a4,a4,a5
 5ce:	02d00793          	li	a5,45
 5d2:	fef70823          	sb	a5,-16(a4)
 5d6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5da:	02e05863          	blez	a4,60a <printint+0x94>
 5de:	fc040793          	addi	a5,s0,-64
 5e2:	00e78933          	add	s2,a5,a4
 5e6:	fff78993          	addi	s3,a5,-1
 5ea:	99ba                	add	s3,s3,a4
 5ec:	377d                	addiw	a4,a4,-1
 5ee:	1702                	slli	a4,a4,0x20
 5f0:	9301                	srli	a4,a4,0x20
 5f2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5f6:	fff94583          	lbu	a1,-1(s2)
 5fa:	8526                	mv	a0,s1
 5fc:	00000097          	auipc	ra,0x0
 600:	ef4080e7          	jalr	-268(ra) # 4f0 <putc>
  while(--i >= 0)
 604:	197d                	addi	s2,s2,-1
 606:	ff3918e3          	bne	s2,s3,5f6 <printint+0x80>
}
 60a:	70e2                	ld	ra,56(sp)
 60c:	7442                	ld	s0,48(sp)
 60e:	74a2                	ld	s1,40(sp)
 610:	7902                	ld	s2,32(sp)
 612:	69e2                	ld	s3,24(sp)
 614:	6121                	addi	sp,sp,64
 616:	8082                	ret
    x = -xx;
 618:	40b005bb          	negw	a1,a1
    neg = 1;
 61c:	4885                	li	a7,1
    x = -xx;
 61e:	bf8d                	j	590 <printint+0x1a>

0000000000000620 <fflush>:
void fflush(int fd){
 620:	1101                	addi	sp,sp,-32
 622:	ec06                	sd	ra,24(sp)
 624:	e822                	sd	s0,16(sp)
 626:	e426                	sd	s1,8(sp)
 628:	e04a                	sd	s2,0(sp)
 62a:	1000                	addi	s0,sp,32
 62c:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 62e:	00000097          	auipc	ra,0x0
 632:	e76080e7          	jalr	-394(ra) # 4a4 <get_putc_buf>
 636:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 638:	00291793          	slli	a5,s2,0x2
 63c:	00000497          	auipc	s1,0x0
 640:	64c48493          	addi	s1,s1,1612 # c88 <putc_buf>
 644:	94be                	add	s1,s1,a5
 646:	3204a603          	lw	a2,800(s1)
 64a:	854a                	mv	a0,s2
 64c:	00000097          	auipc	ra,0x0
 650:	db0080e7          	jalr	-592(ra) # 3fc <write>
  putc_index[fd] = 0;
 654:	3204a023          	sw	zero,800(s1)
}
 658:	60e2                	ld	ra,24(sp)
 65a:	6442                	ld	s0,16(sp)
 65c:	64a2                	ld	s1,8(sp)
 65e:	6902                	ld	s2,0(sp)
 660:	6105                	addi	sp,sp,32
 662:	8082                	ret

0000000000000664 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 664:	7119                	addi	sp,sp,-128
 666:	fc86                	sd	ra,120(sp)
 668:	f8a2                	sd	s0,112(sp)
 66a:	f4a6                	sd	s1,104(sp)
 66c:	f0ca                	sd	s2,96(sp)
 66e:	ecce                	sd	s3,88(sp)
 670:	e8d2                	sd	s4,80(sp)
 672:	e4d6                	sd	s5,72(sp)
 674:	e0da                	sd	s6,64(sp)
 676:	fc5e                	sd	s7,56(sp)
 678:	f862                	sd	s8,48(sp)
 67a:	f466                	sd	s9,40(sp)
 67c:	f06a                	sd	s10,32(sp)
 67e:	ec6e                	sd	s11,24(sp)
 680:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 682:	0005c903          	lbu	s2,0(a1)
 686:	18090f63          	beqz	s2,824 <vprintf+0x1c0>
 68a:	8aaa                	mv	s5,a0
 68c:	8b32                	mv	s6,a2
 68e:	00158493          	addi	s1,a1,1
  state = 0;
 692:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 694:	02500a13          	li	s4,37
      if(c == 'd'){
 698:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 69c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6a0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6a4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a8:	00000b97          	auipc	s7,0x0
 6ac:	3c0b8b93          	addi	s7,s7,960 # a68 <digits>
 6b0:	a839                	j	6ce <vprintf+0x6a>
        putc(fd, c);
 6b2:	85ca                	mv	a1,s2
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e3a080e7          	jalr	-454(ra) # 4f0 <putc>
 6be:	a019                	j	6c4 <vprintf+0x60>
    } else if(state == '%'){
 6c0:	01498f63          	beq	s3,s4,6de <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6c4:	0485                	addi	s1,s1,1
 6c6:	fff4c903          	lbu	s2,-1(s1)
 6ca:	14090d63          	beqz	s2,824 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6ce:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6d2:	fe0997e3          	bnez	s3,6c0 <vprintf+0x5c>
      if(c == '%'){
 6d6:	fd479ee3          	bne	a5,s4,6b2 <vprintf+0x4e>
        state = '%';
 6da:	89be                	mv	s3,a5
 6dc:	b7e5                	j	6c4 <vprintf+0x60>
      if(c == 'd'){
 6de:	05878063          	beq	a5,s8,71e <vprintf+0xba>
      } else if(c == 'l') {
 6e2:	05978c63          	beq	a5,s9,73a <vprintf+0xd6>
      } else if(c == 'x') {
 6e6:	07a78863          	beq	a5,s10,756 <vprintf+0xf2>
      } else if(c == 'p') {
 6ea:	09b78463          	beq	a5,s11,772 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6ee:	07300713          	li	a4,115
 6f2:	0ce78663          	beq	a5,a4,7be <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6f6:	06300713          	li	a4,99
 6fa:	0ee78e63          	beq	a5,a4,7f6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6fe:	11478863          	beq	a5,s4,80e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 702:	85d2                	mv	a1,s4
 704:	8556                	mv	a0,s5
 706:	00000097          	auipc	ra,0x0
 70a:	dea080e7          	jalr	-534(ra) # 4f0 <putc>
        putc(fd, c);
 70e:	85ca                	mv	a1,s2
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	dde080e7          	jalr	-546(ra) # 4f0 <putc>
      }
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b765                	j	6c4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 71e:	008b0913          	addi	s2,s6,8
 722:	4685                	li	a3,1
 724:	4629                	li	a2,10
 726:	000b2583          	lw	a1,0(s6)
 72a:	8556                	mv	a0,s5
 72c:	00000097          	auipc	ra,0x0
 730:	e4a080e7          	jalr	-438(ra) # 576 <printint>
 734:	8b4a                	mv	s6,s2
      state = 0;
 736:	4981                	li	s3,0
 738:	b771                	j	6c4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 73a:	008b0913          	addi	s2,s6,8
 73e:	4681                	li	a3,0
 740:	4629                	li	a2,10
 742:	000b2583          	lw	a1,0(s6)
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	e2e080e7          	jalr	-466(ra) # 576 <printint>
 750:	8b4a                	mv	s6,s2
      state = 0;
 752:	4981                	li	s3,0
 754:	bf85                	j	6c4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 756:	008b0913          	addi	s2,s6,8
 75a:	4681                	li	a3,0
 75c:	4641                	li	a2,16
 75e:	000b2583          	lw	a1,0(s6)
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	e12080e7          	jalr	-494(ra) # 576 <printint>
 76c:	8b4a                	mv	s6,s2
      state = 0;
 76e:	4981                	li	s3,0
 770:	bf91                	j	6c4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 772:	008b0793          	addi	a5,s6,8
 776:	f8f43423          	sd	a5,-120(s0)
 77a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 77e:	03000593          	li	a1,48
 782:	8556                	mv	a0,s5
 784:	00000097          	auipc	ra,0x0
 788:	d6c080e7          	jalr	-660(ra) # 4f0 <putc>
  putc(fd, 'x');
 78c:	85ea                	mv	a1,s10
 78e:	8556                	mv	a0,s5
 790:	00000097          	auipc	ra,0x0
 794:	d60080e7          	jalr	-672(ra) # 4f0 <putc>
 798:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 79a:	03c9d793          	srli	a5,s3,0x3c
 79e:	97de                	add	a5,a5,s7
 7a0:	0007c583          	lbu	a1,0(a5)
 7a4:	8556                	mv	a0,s5
 7a6:	00000097          	auipc	ra,0x0
 7aa:	d4a080e7          	jalr	-694(ra) # 4f0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ae:	0992                	slli	s3,s3,0x4
 7b0:	397d                	addiw	s2,s2,-1
 7b2:	fe0914e3          	bnez	s2,79a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7b6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b721                	j	6c4 <vprintf+0x60>
        s = va_arg(ap, char*);
 7be:	008b0993          	addi	s3,s6,8
 7c2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7c6:	02090163          	beqz	s2,7e8 <vprintf+0x184>
        while(*s != 0){
 7ca:	00094583          	lbu	a1,0(s2)
 7ce:	c9a1                	beqz	a1,81e <vprintf+0x1ba>
          putc(fd, *s);
 7d0:	8556                	mv	a0,s5
 7d2:	00000097          	auipc	ra,0x0
 7d6:	d1e080e7          	jalr	-738(ra) # 4f0 <putc>
          s++;
 7da:	0905                	addi	s2,s2,1
        while(*s != 0){
 7dc:	00094583          	lbu	a1,0(s2)
 7e0:	f9e5                	bnez	a1,7d0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7e2:	8b4e                	mv	s6,s3
      state = 0;
 7e4:	4981                	li	s3,0
 7e6:	bdf9                	j	6c4 <vprintf+0x60>
          s = "(null)";
 7e8:	00000917          	auipc	s2,0x0
 7ec:	27890913          	addi	s2,s2,632 # a60 <malloc+0x132>
        while(*s != 0){
 7f0:	02800593          	li	a1,40
 7f4:	bff1                	j	7d0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7f6:	008b0913          	addi	s2,s6,8
 7fa:	000b4583          	lbu	a1,0(s6)
 7fe:	8556                	mv	a0,s5
 800:	00000097          	auipc	ra,0x0
 804:	cf0080e7          	jalr	-784(ra) # 4f0 <putc>
 808:	8b4a                	mv	s6,s2
      state = 0;
 80a:	4981                	li	s3,0
 80c:	bd65                	j	6c4 <vprintf+0x60>
        putc(fd, c);
 80e:	85d2                	mv	a1,s4
 810:	8556                	mv	a0,s5
 812:	00000097          	auipc	ra,0x0
 816:	cde080e7          	jalr	-802(ra) # 4f0 <putc>
      state = 0;
 81a:	4981                	li	s3,0
 81c:	b565                	j	6c4 <vprintf+0x60>
        s = va_arg(ap, char*);
 81e:	8b4e                	mv	s6,s3
      state = 0;
 820:	4981                	li	s3,0
 822:	b54d                	j	6c4 <vprintf+0x60>
    }
  }
}
 824:	70e6                	ld	ra,120(sp)
 826:	7446                	ld	s0,112(sp)
 828:	74a6                	ld	s1,104(sp)
 82a:	7906                	ld	s2,96(sp)
 82c:	69e6                	ld	s3,88(sp)
 82e:	6a46                	ld	s4,80(sp)
 830:	6aa6                	ld	s5,72(sp)
 832:	6b06                	ld	s6,64(sp)
 834:	7be2                	ld	s7,56(sp)
 836:	7c42                	ld	s8,48(sp)
 838:	7ca2                	ld	s9,40(sp)
 83a:	7d02                	ld	s10,32(sp)
 83c:	6de2                	ld	s11,24(sp)
 83e:	6109                	addi	sp,sp,128
 840:	8082                	ret

0000000000000842 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 842:	715d                	addi	sp,sp,-80
 844:	ec06                	sd	ra,24(sp)
 846:	e822                	sd	s0,16(sp)
 848:	1000                	addi	s0,sp,32
 84a:	e010                	sd	a2,0(s0)
 84c:	e414                	sd	a3,8(s0)
 84e:	e818                	sd	a4,16(s0)
 850:	ec1c                	sd	a5,24(s0)
 852:	03043023          	sd	a6,32(s0)
 856:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 85a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 85e:	8622                	mv	a2,s0
 860:	00000097          	auipc	ra,0x0
 864:	e04080e7          	jalr	-508(ra) # 664 <vprintf>
}
 868:	60e2                	ld	ra,24(sp)
 86a:	6442                	ld	s0,16(sp)
 86c:	6161                	addi	sp,sp,80
 86e:	8082                	ret

0000000000000870 <printf>:

void
printf(const char *fmt, ...)
{
 870:	711d                	addi	sp,sp,-96
 872:	ec06                	sd	ra,24(sp)
 874:	e822                	sd	s0,16(sp)
 876:	1000                	addi	s0,sp,32
 878:	e40c                	sd	a1,8(s0)
 87a:	e810                	sd	a2,16(s0)
 87c:	ec14                	sd	a3,24(s0)
 87e:	f018                	sd	a4,32(s0)
 880:	f41c                	sd	a5,40(s0)
 882:	03043823          	sd	a6,48(s0)
 886:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 88a:	00840613          	addi	a2,s0,8
 88e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 892:	85aa                	mv	a1,a0
 894:	4505                	li	a0,1
 896:	00000097          	auipc	ra,0x0
 89a:	dce080e7          	jalr	-562(ra) # 664 <vprintf>
}
 89e:	60e2                	ld	ra,24(sp)
 8a0:	6442                	ld	s0,16(sp)
 8a2:	6125                	addi	sp,sp,96
 8a4:	8082                	ret

00000000000008a6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a6:	1141                	addi	sp,sp,-16
 8a8:	e422                	sd	s0,8(sp)
 8aa:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ac:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b0:	00000797          	auipc	a5,0x0
 8b4:	1d07b783          	ld	a5,464(a5) # a80 <freep>
 8b8:	a805                	j	8e8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8ba:	4618                	lw	a4,8(a2)
 8bc:	9db9                	addw	a1,a1,a4
 8be:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c2:	6398                	ld	a4,0(a5)
 8c4:	6318                	ld	a4,0(a4)
 8c6:	fee53823          	sd	a4,-16(a0)
 8ca:	a091                	j	90e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8cc:	ff852703          	lw	a4,-8(a0)
 8d0:	9e39                	addw	a2,a2,a4
 8d2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8d4:	ff053703          	ld	a4,-16(a0)
 8d8:	e398                	sd	a4,0(a5)
 8da:	a099                	j	920 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8dc:	6398                	ld	a4,0(a5)
 8de:	00e7e463          	bltu	a5,a4,8e6 <free+0x40>
 8e2:	00e6ea63          	bltu	a3,a4,8f6 <free+0x50>
{
 8e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e8:	fed7fae3          	bgeu	a5,a3,8dc <free+0x36>
 8ec:	6398                	ld	a4,0(a5)
 8ee:	00e6e463          	bltu	a3,a4,8f6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f2:	fee7eae3          	bltu	a5,a4,8e6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8f6:	ff852583          	lw	a1,-8(a0)
 8fa:	6390                	ld	a2,0(a5)
 8fc:	02059713          	slli	a4,a1,0x20
 900:	9301                	srli	a4,a4,0x20
 902:	0712                	slli	a4,a4,0x4
 904:	9736                	add	a4,a4,a3
 906:	fae60ae3          	beq	a2,a4,8ba <free+0x14>
    bp->s.ptr = p->s.ptr;
 90a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 90e:	4790                	lw	a2,8(a5)
 910:	02061713          	slli	a4,a2,0x20
 914:	9301                	srli	a4,a4,0x20
 916:	0712                	slli	a4,a4,0x4
 918:	973e                	add	a4,a4,a5
 91a:	fae689e3          	beq	a3,a4,8cc <free+0x26>
  } else
    p->s.ptr = bp;
 91e:	e394                	sd	a3,0(a5)
  freep = p;
 920:	00000717          	auipc	a4,0x0
 924:	16f73023          	sd	a5,352(a4) # a80 <freep>
}
 928:	6422                	ld	s0,8(sp)
 92a:	0141                	addi	sp,sp,16
 92c:	8082                	ret

000000000000092e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 92e:	7139                	addi	sp,sp,-64
 930:	fc06                	sd	ra,56(sp)
 932:	f822                	sd	s0,48(sp)
 934:	f426                	sd	s1,40(sp)
 936:	f04a                	sd	s2,32(sp)
 938:	ec4e                	sd	s3,24(sp)
 93a:	e852                	sd	s4,16(sp)
 93c:	e456                	sd	s5,8(sp)
 93e:	e05a                	sd	s6,0(sp)
 940:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 942:	02051493          	slli	s1,a0,0x20
 946:	9081                	srli	s1,s1,0x20
 948:	04bd                	addi	s1,s1,15
 94a:	8091                	srli	s1,s1,0x4
 94c:	0014899b          	addiw	s3,s1,1
 950:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 952:	00000517          	auipc	a0,0x0
 956:	12e53503          	ld	a0,302(a0) # a80 <freep>
 95a:	c515                	beqz	a0,986 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95e:	4798                	lw	a4,8(a5)
 960:	02977f63          	bgeu	a4,s1,99e <malloc+0x70>
 964:	8a4e                	mv	s4,s3
 966:	0009871b          	sext.w	a4,s3
 96a:	6685                	lui	a3,0x1
 96c:	00d77363          	bgeu	a4,a3,972 <malloc+0x44>
 970:	6a05                	lui	s4,0x1
 972:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 976:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 97a:	00000917          	auipc	s2,0x0
 97e:	10690913          	addi	s2,s2,262 # a80 <freep>
  if(p == (char*)-1)
 982:	5afd                	li	s5,-1
 984:	a88d                	j	9f6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 986:	00000797          	auipc	a5,0x0
 98a:	7b278793          	addi	a5,a5,1970 # 1138 <base>
 98e:	00000717          	auipc	a4,0x0
 992:	0ef73923          	sd	a5,242(a4) # a80 <freep>
 996:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 998:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 99c:	b7e1                	j	964 <malloc+0x36>
      if(p->s.size == nunits)
 99e:	02e48b63          	beq	s1,a4,9d4 <malloc+0xa6>
        p->s.size -= nunits;
 9a2:	4137073b          	subw	a4,a4,s3
 9a6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9a8:	1702                	slli	a4,a4,0x20
 9aa:	9301                	srli	a4,a4,0x20
 9ac:	0712                	slli	a4,a4,0x4
 9ae:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9b0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9b4:	00000717          	auipc	a4,0x0
 9b8:	0ca73623          	sd	a0,204(a4) # a80 <freep>
      return (void*)(p + 1);
 9bc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9c0:	70e2                	ld	ra,56(sp)
 9c2:	7442                	ld	s0,48(sp)
 9c4:	74a2                	ld	s1,40(sp)
 9c6:	7902                	ld	s2,32(sp)
 9c8:	69e2                	ld	s3,24(sp)
 9ca:	6a42                	ld	s4,16(sp)
 9cc:	6aa2                	ld	s5,8(sp)
 9ce:	6b02                	ld	s6,0(sp)
 9d0:	6121                	addi	sp,sp,64
 9d2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9d4:	6398                	ld	a4,0(a5)
 9d6:	e118                	sd	a4,0(a0)
 9d8:	bff1                	j	9b4 <malloc+0x86>
  hp->s.size = nu;
 9da:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9de:	0541                	addi	a0,a0,16
 9e0:	00000097          	auipc	ra,0x0
 9e4:	ec6080e7          	jalr	-314(ra) # 8a6 <free>
  return freep;
 9e8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ec:	d971                	beqz	a0,9c0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f0:	4798                	lw	a4,8(a5)
 9f2:	fa9776e3          	bgeu	a4,s1,99e <malloc+0x70>
    if(p == freep)
 9f6:	00093703          	ld	a4,0(s2)
 9fa:	853e                	mv	a0,a5
 9fc:	fef719e3          	bne	a4,a5,9ee <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a00:	8552                	mv	a0,s4
 a02:	00000097          	auipc	ra,0x0
 a06:	a62080e7          	jalr	-1438(ra) # 464 <sbrk>
  if(p == (char*)-1)
 a0a:	fd5518e3          	bne	a0,s5,9da <malloc+0xac>
        return 0;
 a0e:	4501                	li	a0,0
 a10:	bf45                	j	9c0 <malloc+0x92>
