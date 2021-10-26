
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N  1000

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
   c:	00000097          	auipc	ra,0x0
  10:	15a080e7          	jalr	346(ra) # 166 <strlen>
  14:	0005061b          	sext.w	a2,a0
  18:	85a6                	mv	a1,s1
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	3e6080e7          	jalr	998(ra) # 402 <write>
}
  24:	60e2                	ld	ra,24(sp)
  26:	6442                	ld	s0,16(sp)
  28:	64a2                	ld	s1,8(sp)
  2a:	6105                	addi	sp,sp,32
  2c:	8082                	ret

000000000000002e <forktest>:

void
forktest(void)
{
  2e:	1101                	addi	sp,sp,-32
  30:	ec06                	sd	ra,24(sp)
  32:	e822                	sd	s0,16(sp)
  34:	e426                	sd	s1,8(sp)
  36:	e04a                	sd	s2,0(sp)
  38:	1000                	addi	s0,sp,32
  int n, pid;

  print("fork test\n");
  3a:	00001517          	auipc	a0,0x1
  3e:	9de50513          	addi	a0,a0,-1570 # a18 <printf+0x36>
  42:	00000097          	auipc	ra,0x0
  46:	fbe080e7          	jalr	-66(ra) # 0 <print>

  for(n=0; n<N; n++){
  4a:	4481                	li	s1,0
  4c:	3e800913          	li	s2,1000
    pid = fork();
  50:	00000097          	auipc	ra,0x0
  54:	38a080e7          	jalr	906(ra) # 3da <fork>
    if(pid < 0)
  58:	02054763          	bltz	a0,86 <forktest+0x58>
      break;
    if(pid == 0)
  5c:	c10d                	beqz	a0,7e <forktest+0x50>
  for(n=0; n<N; n++){
  5e:	2485                	addiw	s1,s1,1
  60:	ff2498e3          	bne	s1,s2,50 <forktest+0x22>
      exit(0);
  }

  if(n == N){
    print("fork claimed to work N times!\n");
  64:	00001517          	auipc	a0,0x1
  68:	9c450513          	addi	a0,a0,-1596 # a28 <printf+0x46>
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <print>
    exit(1);
  74:	4505                	li	a0,1
  76:	00000097          	auipc	ra,0x0
  7a:	36c080e7          	jalr	876(ra) # 3e2 <exit>
      exit(0);
  7e:	00000097          	auipc	ra,0x0
  82:	364080e7          	jalr	868(ra) # 3e2 <exit>
  if(n == N){
  86:	3e800793          	li	a5,1000
  8a:	fcf48de3          	beq	s1,a5,64 <forktest+0x36>
  }

  for(; n > 0; n--){
  8e:	00905b63          	blez	s1,a4 <forktest+0x76>
    if(wait(0) < 0){
  92:	4501                	li	a0,0
  94:	00000097          	auipc	ra,0x0
  98:	356080e7          	jalr	854(ra) # 3ea <wait>
  9c:	02054a63          	bltz	a0,d0 <forktest+0xa2>
  for(; n > 0; n--){
  a0:	34fd                	addiw	s1,s1,-1
  a2:	f8e5                	bnez	s1,92 <forktest+0x64>
      print("wait stopped early\n");
      exit(1);
    }
  }

  if(wait(0) != -1){
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	344080e7          	jalr	836(ra) # 3ea <wait>
  ae:	57fd                	li	a5,-1
  b0:	02f51d63          	bne	a0,a5,ea <forktest+0xbc>
    print("wait got too many\n");
    exit(1);
  }

  print("fork test OK\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	9c450513          	addi	a0,a0,-1596 # a78 <printf+0x96>
  bc:	00000097          	auipc	ra,0x0
  c0:	f44080e7          	jalr	-188(ra) # 0 <print>
}
  c4:	60e2                	ld	ra,24(sp)
  c6:	6442                	ld	s0,16(sp)
  c8:	64a2                	ld	s1,8(sp)
  ca:	6902                	ld	s2,0(sp)
  cc:	6105                	addi	sp,sp,32
  ce:	8082                	ret
      print("wait stopped early\n");
  d0:	00001517          	auipc	a0,0x1
  d4:	97850513          	addi	a0,a0,-1672 # a48 <printf+0x66>
  d8:	00000097          	auipc	ra,0x0
  dc:	f28080e7          	jalr	-216(ra) # 0 <print>
      exit(1);
  e0:	4505                	li	a0,1
  e2:	00000097          	auipc	ra,0x0
  e6:	300080e7          	jalr	768(ra) # 3e2 <exit>
    print("wait got too many\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	97650513          	addi	a0,a0,-1674 # a60 <printf+0x7e>
  f2:	00000097          	auipc	ra,0x0
  f6:	f0e080e7          	jalr	-242(ra) # 0 <print>
    exit(1);
  fa:	4505                	li	a0,1
  fc:	00000097          	auipc	ra,0x0
 100:	2e6080e7          	jalr	742(ra) # 3e2 <exit>

0000000000000104 <main>:

int
main(void)
{
 104:	1141                	addi	sp,sp,-16
 106:	e406                	sd	ra,8(sp)
 108:	e022                	sd	s0,0(sp)
 10a:	0800                	addi	s0,sp,16
  forktest();
 10c:	00000097          	auipc	ra,0x0
 110:	f22080e7          	jalr	-222(ra) # 2e <forktest>
  exit(0);
 114:	4501                	li	a0,0
 116:	00000097          	auipc	ra,0x0
 11a:	2cc080e7          	jalr	716(ra) # 3e2 <exit>

000000000000011e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 124:	87aa                	mv	a5,a0
 126:	0585                	addi	a1,a1,1
 128:	0785                	addi	a5,a5,1
 12a:	fff5c703          	lbu	a4,-1(a1)
 12e:	fee78fa3          	sb	a4,-1(a5)
 132:	fb75                	bnez	a4,126 <strcpy+0x8>
    ;
  return os;
}
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret

000000000000013a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 140:	00054783          	lbu	a5,0(a0)
 144:	cb91                	beqz	a5,158 <strcmp+0x1e>
 146:	0005c703          	lbu	a4,0(a1)
 14a:	00f71763          	bne	a4,a5,158 <strcmp+0x1e>
    p++, q++;
 14e:	0505                	addi	a0,a0,1
 150:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 152:	00054783          	lbu	a5,0(a0)
 156:	fbe5                	bnez	a5,146 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 158:	0005c503          	lbu	a0,0(a1)
}
 15c:	40a7853b          	subw	a0,a5,a0
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strlen>:

uint
strlen(const char *s)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cf91                	beqz	a5,18c <strlen+0x26>
 172:	0505                	addi	a0,a0,1
 174:	87aa                	mv	a5,a0
 176:	4685                	li	a3,1
 178:	9e89                	subw	a3,a3,a0
 17a:	00f6853b          	addw	a0,a3,a5
 17e:	0785                	addi	a5,a5,1
 180:	fff7c703          	lbu	a4,-1(a5)
 184:	fb7d                	bnez	a4,17a <strlen+0x14>
    ;
  return n;
}
 186:	6422                	ld	s0,8(sp)
 188:	0141                	addi	sp,sp,16
 18a:	8082                	ret
  for(n = 0; s[n]; n++)
 18c:	4501                	li	a0,0
 18e:	bfe5                	j	186 <strlen+0x20>

0000000000000190 <memset>:

void*
memset(void *dst, int c, uint n)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 196:	ce09                	beqz	a2,1b0 <memset+0x20>
 198:	87aa                	mv	a5,a0
 19a:	fff6071b          	addiw	a4,a2,-1
 19e:	1702                	slli	a4,a4,0x20
 1a0:	9301                	srli	a4,a4,0x20
 1a2:	0705                	addi	a4,a4,1
 1a4:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1a6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1aa:	0785                	addi	a5,a5,1
 1ac:	fee79de3          	bne	a5,a4,1a6 <memset+0x16>
  }
  return dst;
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strchr>:

char*
strchr(const char *s, char c)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cb99                	beqz	a5,1d6 <strchr+0x20>
    if(*s == c)
 1c2:	00f58763          	beq	a1,a5,1d0 <strchr+0x1a>
  for(; *s; s++)
 1c6:	0505                	addi	a0,a0,1
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	fbfd                	bnez	a5,1c2 <strchr+0xc>
      return (char*)s;
  return 0;
 1ce:	4501                	li	a0,0
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
  return 0;
 1d6:	4501                	li	a0,0
 1d8:	bfe5                	j	1d0 <strchr+0x1a>

00000000000001da <gets>:

char*
gets(char *buf, int max)
{
 1da:	711d                	addi	sp,sp,-96
 1dc:	ec86                	sd	ra,88(sp)
 1de:	e8a2                	sd	s0,80(sp)
 1e0:	e4a6                	sd	s1,72(sp)
 1e2:	e0ca                	sd	s2,64(sp)
 1e4:	fc4e                	sd	s3,56(sp)
 1e6:	f852                	sd	s4,48(sp)
 1e8:	f456                	sd	s5,40(sp)
 1ea:	f05a                	sd	s6,32(sp)
 1ec:	ec5e                	sd	s7,24(sp)
 1ee:	1080                	addi	s0,sp,96
 1f0:	8baa                	mv	s7,a0
 1f2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f4:	892a                	mv	s2,a0
 1f6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f8:	4aa9                	li	s5,10
 1fa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1fc:	89a6                	mv	s3,s1
 1fe:	2485                	addiw	s1,s1,1
 200:	0344d863          	bge	s1,s4,230 <gets+0x56>
    cc = read(0, &c, 1);
 204:	4605                	li	a2,1
 206:	faf40593          	addi	a1,s0,-81
 20a:	4501                	li	a0,0
 20c:	00000097          	auipc	ra,0x0
 210:	1ee080e7          	jalr	494(ra) # 3fa <read>
    if(cc < 1)
 214:	00a05e63          	blez	a0,230 <gets+0x56>
    buf[i++] = c;
 218:	faf44783          	lbu	a5,-81(s0)
 21c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 220:	01578763          	beq	a5,s5,22e <gets+0x54>
 224:	0905                	addi	s2,s2,1
 226:	fd679be3          	bne	a5,s6,1fc <gets+0x22>
  for(i=0; i+1 < max; ){
 22a:	89a6                	mv	s3,s1
 22c:	a011                	j	230 <gets+0x56>
 22e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 230:	99de                	add	s3,s3,s7
 232:	00098023          	sb	zero,0(s3)
  return buf;
}
 236:	855e                	mv	a0,s7
 238:	60e6                	ld	ra,88(sp)
 23a:	6446                	ld	s0,80(sp)
 23c:	64a6                	ld	s1,72(sp)
 23e:	6906                	ld	s2,64(sp)
 240:	79e2                	ld	s3,56(sp)
 242:	7a42                	ld	s4,48(sp)
 244:	7aa2                	ld	s5,40(sp)
 246:	7b02                	ld	s6,32(sp)
 248:	6be2                	ld	s7,24(sp)
 24a:	6125                	addi	sp,sp,96
 24c:	8082                	ret

000000000000024e <atoi>:
  return r;
}

int
atoi(const char *s)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 254:	00054603          	lbu	a2,0(a0)
 258:	fd06079b          	addiw	a5,a2,-48
 25c:	0ff7f793          	andi	a5,a5,255
 260:	4725                	li	a4,9
 262:	02f76963          	bltu	a4,a5,294 <atoi+0x46>
 266:	86aa                	mv	a3,a0
  n = 0;
 268:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 26a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 26c:	0685                	addi	a3,a3,1
 26e:	0025179b          	slliw	a5,a0,0x2
 272:	9fa9                	addw	a5,a5,a0
 274:	0017979b          	slliw	a5,a5,0x1
 278:	9fb1                	addw	a5,a5,a2
 27a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 27e:	0006c603          	lbu	a2,0(a3)
 282:	fd06071b          	addiw	a4,a2,-48
 286:	0ff77713          	andi	a4,a4,255
 28a:	fee5f1e3          	bgeu	a1,a4,26c <atoi+0x1e>
  return n;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
  n = 0;
 294:	4501                	li	a0,0
 296:	bfe5                	j	28e <atoi+0x40>

0000000000000298 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29e:	02b57663          	bgeu	a0,a1,2ca <memmove+0x32>
    while(n-- > 0)
 2a2:	02c05163          	blez	a2,2c4 <memmove+0x2c>
 2a6:	fff6079b          	addiw	a5,a2,-1
 2aa:	1782                	slli	a5,a5,0x20
 2ac:	9381                	srli	a5,a5,0x20
 2ae:	0785                	addi	a5,a5,1
 2b0:	97aa                	add	a5,a5,a0
  dst = vdst;
 2b2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b4:	0585                	addi	a1,a1,1
 2b6:	0705                	addi	a4,a4,1
 2b8:	fff5c683          	lbu	a3,-1(a1)
 2bc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c0:	fee79ae3          	bne	a5,a4,2b4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
    dst += n;
 2ca:	00c50733          	add	a4,a0,a2
    src += n;
 2ce:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d0:	fec05ae3          	blez	a2,2c4 <memmove+0x2c>
 2d4:	fff6079b          	addiw	a5,a2,-1
 2d8:	1782                	slli	a5,a5,0x20
 2da:	9381                	srli	a5,a5,0x20
 2dc:	fff7c793          	not	a5,a5
 2e0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e2:	15fd                	addi	a1,a1,-1
 2e4:	177d                	addi	a4,a4,-1
 2e6:	0005c683          	lbu	a3,0(a1)
 2ea:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ee:	fee79ae3          	bne	a5,a4,2e2 <memmove+0x4a>
 2f2:	bfc9                	j	2c4 <memmove+0x2c>

00000000000002f4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2fa:	ca05                	beqz	a2,32a <memcmp+0x36>
 2fc:	fff6069b          	addiw	a3,a2,-1
 300:	1682                	slli	a3,a3,0x20
 302:	9281                	srli	a3,a3,0x20
 304:	0685                	addi	a3,a3,1
 306:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 308:	00054783          	lbu	a5,0(a0)
 30c:	0005c703          	lbu	a4,0(a1)
 310:	00e79863          	bne	a5,a4,320 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 314:	0505                	addi	a0,a0,1
    p2++;
 316:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 318:	fed518e3          	bne	a0,a3,308 <memcmp+0x14>
  }
  return 0;
 31c:	4501                	li	a0,0
 31e:	a019                	j	324 <memcmp+0x30>
      return *p1 - *p2;
 320:	40e7853b          	subw	a0,a5,a4
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
  return 0;
 32a:	4501                	li	a0,0
 32c:	bfe5                	j	324 <memcmp+0x30>

000000000000032e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e406                	sd	ra,8(sp)
 332:	e022                	sd	s0,0(sp)
 334:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 336:	00000097          	auipc	ra,0x0
 33a:	f62080e7          	jalr	-158(ra) # 298 <memmove>
}
 33e:	60a2                	ld	ra,8(sp)
 340:	6402                	ld	s0,0(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret

0000000000000346 <close>:

int close(int fd){
 346:	1101                	addi	sp,sp,-32
 348:	ec06                	sd	ra,24(sp)
 34a:	e822                	sd	s0,16(sp)
 34c:	e426                	sd	s1,8(sp)
 34e:	1000                	addi	s0,sp,32
 350:	84aa                	mv	s1,a0
  fflush(fd);
 352:	00000097          	auipc	ra,0x0
 356:	440080e7          	jalr	1088(ra) # 792 <fflush>
  char* buf = get_putc_buf(fd);
 35a:	8526                	mv	a0,s1
 35c:	00000097          	auipc	ra,0x0
 360:	2ba080e7          	jalr	698(ra) # 616 <get_putc_buf>
  if(buf){
 364:	cd11                	beqz	a0,380 <close+0x3a>
    free(buf);
 366:	00000097          	auipc	ra,0x0
 36a:	144080e7          	jalr	324(ra) # 4aa <free>
    putc_buf[fd] = 0;
 36e:	00349713          	slli	a4,s1,0x3
 372:	00000797          	auipc	a5,0x0
 376:	74e78793          	addi	a5,a5,1870 # ac0 <putc_buf>
 37a:	97ba                	add	a5,a5,a4
 37c:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 380:	8526                	mv	a0,s1
 382:	00000097          	auipc	ra,0x0
 386:	088080e7          	jalr	136(ra) # 40a <sclose>
}
 38a:	60e2                	ld	ra,24(sp)
 38c:	6442                	ld	s0,16(sp)
 38e:	64a2                	ld	s1,8(sp)
 390:	6105                	addi	sp,sp,32
 392:	8082                	ret

0000000000000394 <stat>:
{
 394:	1101                	addi	sp,sp,-32
 396:	ec06                	sd	ra,24(sp)
 398:	e822                	sd	s0,16(sp)
 39a:	e426                	sd	s1,8(sp)
 39c:	e04a                	sd	s2,0(sp)
 39e:	1000                	addi	s0,sp,32
 3a0:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 3a2:	4581                	li	a1,0
 3a4:	00000097          	auipc	ra,0x0
 3a8:	07e080e7          	jalr	126(ra) # 422 <open>
  if(fd < 0)
 3ac:	02054563          	bltz	a0,3d6 <stat+0x42>
 3b0:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 3b2:	85ca                	mv	a1,s2
 3b4:	00000097          	auipc	ra,0x0
 3b8:	086080e7          	jalr	134(ra) # 43a <fstat>
 3bc:	892a                	mv	s2,a0
  close(fd);
 3be:	8526                	mv	a0,s1
 3c0:	00000097          	auipc	ra,0x0
 3c4:	f86080e7          	jalr	-122(ra) # 346 <close>
}
 3c8:	854a                	mv	a0,s2
 3ca:	60e2                	ld	ra,24(sp)
 3cc:	6442                	ld	s0,16(sp)
 3ce:	64a2                	ld	s1,8(sp)
 3d0:	6902                	ld	s2,0(sp)
 3d2:	6105                	addi	sp,sp,32
 3d4:	8082                	ret
    return -1;
 3d6:	597d                	li	s2,-1
 3d8:	bfc5                	j	3c8 <stat+0x34>

00000000000003da <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3da:	4885                	li	a7,1
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e2:	4889                	li	a7,2
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ea:	488d                	li	a7,3
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f2:	4891                	li	a7,4
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <read>:
.global read
read:
 li a7, SYS_read
 3fa:	4895                	li	a7,5
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <write>:
.global write
write:
 li a7, SYS_write
 402:	48c1                	li	a7,16
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 40a:	48d5                	li	a7,21
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <kill>:
.global kill
kill:
 li a7, SYS_kill
 412:	4899                	li	a7,6
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <exec>:
.global exec
exec:
 li a7, SYS_exec
 41a:	489d                	li	a7,7
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <open>:
.global open
open:
 li a7, SYS_open
 422:	48bd                	li	a7,15
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 42a:	48c5                	li	a7,17
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 432:	48c9                	li	a7,18
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 43a:	48a1                	li	a7,8
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <link>:
.global link
link:
 li a7, SYS_link
 442:	48cd                	li	a7,19
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 44a:	48d1                	li	a7,20
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 452:	48a5                	li	a7,9
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <dup>:
.global dup
dup:
 li a7, SYS_dup
 45a:	48a9                	li	a7,10
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 462:	48ad                	li	a7,11
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 46a:	48b1                	li	a7,12
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 472:	48b5                	li	a7,13
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 47a:	48b9                	li	a7,14
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 482:	48d9                	li	a7,22
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <nice>:
.global nice
nice:
 li a7, SYS_nice
 48a:	48dd                	li	a7,23
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 492:	48e1                	li	a7,24
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 49a:	48e5                	li	a7,25
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 4a2:	48e9                	li	a7,26
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4aa:	1141                	addi	sp,sp,-16
 4ac:	e422                	sd	s0,8(sp)
 4ae:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4b0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4b4:	00000797          	auipc	a5,0x0
 4b8:	5f47b783          	ld	a5,1524(a5) # aa8 <freep>
 4bc:	a805                	j	4ec <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 4be:	4618                	lw	a4,8(a2)
 4c0:	9db9                	addw	a1,a1,a4
 4c2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 4c6:	6398                	ld	a4,0(a5)
 4c8:	6318                	ld	a4,0(a4)
 4ca:	fee53823          	sd	a4,-16(a0)
 4ce:	a091                	j	512 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 4d0:	ff852703          	lw	a4,-8(a0)
 4d4:	9e39                	addw	a2,a2,a4
 4d6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 4d8:	ff053703          	ld	a4,-16(a0)
 4dc:	e398                	sd	a4,0(a5)
 4de:	a099                	j	524 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4e0:	6398                	ld	a4,0(a5)
 4e2:	00e7e463          	bltu	a5,a4,4ea <free+0x40>
 4e6:	00e6ea63          	bltu	a3,a4,4fa <free+0x50>
{
 4ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4ec:	fed7fae3          	bgeu	a5,a3,4e0 <free+0x36>
 4f0:	6398                	ld	a4,0(a5)
 4f2:	00e6e463          	bltu	a3,a4,4fa <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4f6:	fee7eae3          	bltu	a5,a4,4ea <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 4fa:	ff852583          	lw	a1,-8(a0)
 4fe:	6390                	ld	a2,0(a5)
 500:	02059713          	slli	a4,a1,0x20
 504:	9301                	srli	a4,a4,0x20
 506:	0712                	slli	a4,a4,0x4
 508:	9736                	add	a4,a4,a3
 50a:	fae60ae3          	beq	a2,a4,4be <free+0x14>
    bp->s.ptr = p->s.ptr;
 50e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 512:	4790                	lw	a2,8(a5)
 514:	02061713          	slli	a4,a2,0x20
 518:	9301                	srli	a4,a4,0x20
 51a:	0712                	slli	a4,a4,0x4
 51c:	973e                	add	a4,a4,a5
 51e:	fae689e3          	beq	a3,a4,4d0 <free+0x26>
  } else
    p->s.ptr = bp;
 522:	e394                	sd	a3,0(a5)
  freep = p;
 524:	00000717          	auipc	a4,0x0
 528:	58f73223          	sd	a5,1412(a4) # aa8 <freep>
}
 52c:	6422                	ld	s0,8(sp)
 52e:	0141                	addi	sp,sp,16
 530:	8082                	ret

0000000000000532 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 532:	7139                	addi	sp,sp,-64
 534:	fc06                	sd	ra,56(sp)
 536:	f822                	sd	s0,48(sp)
 538:	f426                	sd	s1,40(sp)
 53a:	f04a                	sd	s2,32(sp)
 53c:	ec4e                	sd	s3,24(sp)
 53e:	e852                	sd	s4,16(sp)
 540:	e456                	sd	s5,8(sp)
 542:	e05a                	sd	s6,0(sp)
 544:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 546:	02051493          	slli	s1,a0,0x20
 54a:	9081                	srli	s1,s1,0x20
 54c:	04bd                	addi	s1,s1,15
 54e:	8091                	srli	s1,s1,0x4
 550:	0014899b          	addiw	s3,s1,1
 554:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 556:	00000517          	auipc	a0,0x0
 55a:	55253503          	ld	a0,1362(a0) # aa8 <freep>
 55e:	c515                	beqz	a0,58a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 560:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 562:	4798                	lw	a4,8(a5)
 564:	02977f63          	bgeu	a4,s1,5a2 <malloc+0x70>
 568:	8a4e                	mv	s4,s3
 56a:	0009871b          	sext.w	a4,s3
 56e:	6685                	lui	a3,0x1
 570:	00d77363          	bgeu	a4,a3,576 <malloc+0x44>
 574:	6a05                	lui	s4,0x1
 576:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 57a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 57e:	00000917          	auipc	s2,0x0
 582:	52a90913          	addi	s2,s2,1322 # aa8 <freep>
  if(p == (char*)-1)
 586:	5afd                	li	s5,-1
 588:	a88d                	j	5fa <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 58a:	00000797          	auipc	a5,0x0
 58e:	52678793          	addi	a5,a5,1318 # ab0 <base>
 592:	00000717          	auipc	a4,0x0
 596:	50f73b23          	sd	a5,1302(a4) # aa8 <freep>
 59a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 59c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 5a0:	b7e1                	j	568 <malloc+0x36>
      if(p->s.size == nunits)
 5a2:	02e48b63          	beq	s1,a4,5d8 <malloc+0xa6>
        p->s.size -= nunits;
 5a6:	4137073b          	subw	a4,a4,s3
 5aa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 5ac:	1702                	slli	a4,a4,0x20
 5ae:	9301                	srli	a4,a4,0x20
 5b0:	0712                	slli	a4,a4,0x4
 5b2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 5b4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 5b8:	00000717          	auipc	a4,0x0
 5bc:	4ea73823          	sd	a0,1264(a4) # aa8 <freep>
      return (void*)(p + 1);
 5c0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5c4:	70e2                	ld	ra,56(sp)
 5c6:	7442                	ld	s0,48(sp)
 5c8:	74a2                	ld	s1,40(sp)
 5ca:	7902                	ld	s2,32(sp)
 5cc:	69e2                	ld	s3,24(sp)
 5ce:	6a42                	ld	s4,16(sp)
 5d0:	6aa2                	ld	s5,8(sp)
 5d2:	6b02                	ld	s6,0(sp)
 5d4:	6121                	addi	sp,sp,64
 5d6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 5d8:	6398                	ld	a4,0(a5)
 5da:	e118                	sd	a4,0(a0)
 5dc:	bff1                	j	5b8 <malloc+0x86>
  hp->s.size = nu;
 5de:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 5e2:	0541                	addi	a0,a0,16
 5e4:	00000097          	auipc	ra,0x0
 5e8:	ec6080e7          	jalr	-314(ra) # 4aa <free>
  return freep;
 5ec:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 5f0:	d971                	beqz	a0,5c4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5f2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 5f4:	4798                	lw	a4,8(a5)
 5f6:	fa9776e3          	bgeu	a4,s1,5a2 <malloc+0x70>
    if(p == freep)
 5fa:	00093703          	ld	a4,0(s2)
 5fe:	853e                	mv	a0,a5
 600:	fef719e3          	bne	a4,a5,5f2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 604:	8552                	mv	a0,s4
 606:	00000097          	auipc	ra,0x0
 60a:	e64080e7          	jalr	-412(ra) # 46a <sbrk>
  if(p == (char*)-1)
 60e:	fd5518e3          	bne	a0,s5,5de <malloc+0xac>
        return 0;
 612:	4501                	li	a0,0
 614:	bf45                	j	5c4 <malloc+0x92>

0000000000000616 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 616:	1101                	addi	sp,sp,-32
 618:	ec06                	sd	ra,24(sp)
 61a:	e822                	sd	s0,16(sp)
 61c:	e426                	sd	s1,8(sp)
 61e:	1000                	addi	s0,sp,32
 620:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 622:	00351713          	slli	a4,a0,0x3
 626:	00000797          	auipc	a5,0x0
 62a:	49a78793          	addi	a5,a5,1178 # ac0 <putc_buf>
 62e:	97ba                	add	a5,a5,a4
 630:	6388                	ld	a0,0(a5)
  if(buf) {
 632:	c511                	beqz	a0,63e <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 634:	60e2                	ld	ra,24(sp)
 636:	6442                	ld	s0,16(sp)
 638:	64a2                	ld	s1,8(sp)
 63a:	6105                	addi	sp,sp,32
 63c:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 63e:	6505                	lui	a0,0x1
 640:	00000097          	auipc	ra,0x0
 644:	ef2080e7          	jalr	-270(ra) # 532 <malloc>
  putc_buf[fd] = buf;
 648:	00000797          	auipc	a5,0x0
 64c:	47878793          	addi	a5,a5,1144 # ac0 <putc_buf>
 650:	00349713          	slli	a4,s1,0x3
 654:	973e                	add	a4,a4,a5
 656:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 658:	048a                	slli	s1,s1,0x2
 65a:	94be                	add	s1,s1,a5
 65c:	3204a023          	sw	zero,800(s1)
  return buf;
 660:	bfd1                	j	634 <get_putc_buf+0x1e>

0000000000000662 <putc>:

static void
putc(int fd, char c)
{
 662:	1101                	addi	sp,sp,-32
 664:	ec06                	sd	ra,24(sp)
 666:	e822                	sd	s0,16(sp)
 668:	e426                	sd	s1,8(sp)
 66a:	e04a                	sd	s2,0(sp)
 66c:	1000                	addi	s0,sp,32
 66e:	84aa                	mv	s1,a0
 670:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 672:	00000097          	auipc	ra,0x0
 676:	fa4080e7          	jalr	-92(ra) # 616 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 67a:	00249793          	slli	a5,s1,0x2
 67e:	00000717          	auipc	a4,0x0
 682:	44270713          	addi	a4,a4,1090 # ac0 <putc_buf>
 686:	973e                	add	a4,a4,a5
 688:	32072783          	lw	a5,800(a4)
 68c:	0017869b          	addiw	a3,a5,1
 690:	32d72023          	sw	a3,800(a4)
 694:	97aa                	add	a5,a5,a0
 696:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 69a:	47a9                	li	a5,10
 69c:	02f90463          	beq	s2,a5,6c4 <putc+0x62>
 6a0:	00249713          	slli	a4,s1,0x2
 6a4:	00000797          	auipc	a5,0x0
 6a8:	41c78793          	addi	a5,a5,1052 # ac0 <putc_buf>
 6ac:	97ba                	add	a5,a5,a4
 6ae:	3207a703          	lw	a4,800(a5)
 6b2:	6785                	lui	a5,0x1
 6b4:	00f70863          	beq	a4,a5,6c4 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 6b8:	60e2                	ld	ra,24(sp)
 6ba:	6442                	ld	s0,16(sp)
 6bc:	64a2                	ld	s1,8(sp)
 6be:	6902                	ld	s2,0(sp)
 6c0:	6105                	addi	sp,sp,32
 6c2:	8082                	ret
    write(fd, buf, putc_index[fd]);
 6c4:	00249793          	slli	a5,s1,0x2
 6c8:	00000917          	auipc	s2,0x0
 6cc:	3f890913          	addi	s2,s2,1016 # ac0 <putc_buf>
 6d0:	993e                	add	s2,s2,a5
 6d2:	32092603          	lw	a2,800(s2)
 6d6:	85aa                	mv	a1,a0
 6d8:	8526                	mv	a0,s1
 6da:	00000097          	auipc	ra,0x0
 6de:	d28080e7          	jalr	-728(ra) # 402 <write>
    putc_index[fd] = 0;
 6e2:	32092023          	sw	zero,800(s2)
}
 6e6:	bfc9                	j	6b8 <putc+0x56>

00000000000006e8 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 6e8:	7139                	addi	sp,sp,-64
 6ea:	fc06                	sd	ra,56(sp)
 6ec:	f822                	sd	s0,48(sp)
 6ee:	f426                	sd	s1,40(sp)
 6f0:	f04a                	sd	s2,32(sp)
 6f2:	ec4e                	sd	s3,24(sp)
 6f4:	0080                	addi	s0,sp,64
 6f6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6f8:	c299                	beqz	a3,6fe <printint+0x16>
 6fa:	0805c863          	bltz	a1,78a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6fe:	2581                	sext.w	a1,a1
  neg = 0;
 700:	4881                	li	a7,0
 702:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 706:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 708:	2601                	sext.w	a2,a2
 70a:	00000517          	auipc	a0,0x0
 70e:	38650513          	addi	a0,a0,902 # a90 <digits>
 712:	883a                	mv	a6,a4
 714:	2705                	addiw	a4,a4,1
 716:	02c5f7bb          	remuw	a5,a1,a2
 71a:	1782                	slli	a5,a5,0x20
 71c:	9381                	srli	a5,a5,0x20
 71e:	97aa                	add	a5,a5,a0
 720:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x90>
 724:	00f68023          	sb	a5,0(a3) # 1000 <__BSS_END__+0x90>
  }while((x /= base) != 0);
 728:	0005879b          	sext.w	a5,a1
 72c:	02c5d5bb          	divuw	a1,a1,a2
 730:	0685                	addi	a3,a3,1
 732:	fec7f0e3          	bgeu	a5,a2,712 <printint+0x2a>
  if(neg)
 736:	00088b63          	beqz	a7,74c <printint+0x64>
    buf[i++] = '-';
 73a:	fd040793          	addi	a5,s0,-48
 73e:	973e                	add	a4,a4,a5
 740:	02d00793          	li	a5,45
 744:	fef70823          	sb	a5,-16(a4)
 748:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 74c:	02e05863          	blez	a4,77c <printint+0x94>
 750:	fc040793          	addi	a5,s0,-64
 754:	00e78933          	add	s2,a5,a4
 758:	fff78993          	addi	s3,a5,-1
 75c:	99ba                	add	s3,s3,a4
 75e:	377d                	addiw	a4,a4,-1
 760:	1702                	slli	a4,a4,0x20
 762:	9301                	srli	a4,a4,0x20
 764:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 768:	fff94583          	lbu	a1,-1(s2)
 76c:	8526                	mv	a0,s1
 76e:	00000097          	auipc	ra,0x0
 772:	ef4080e7          	jalr	-268(ra) # 662 <putc>
  while(--i >= 0)
 776:	197d                	addi	s2,s2,-1
 778:	ff3918e3          	bne	s2,s3,768 <printint+0x80>
}
 77c:	70e2                	ld	ra,56(sp)
 77e:	7442                	ld	s0,48(sp)
 780:	74a2                	ld	s1,40(sp)
 782:	7902                	ld	s2,32(sp)
 784:	69e2                	ld	s3,24(sp)
 786:	6121                	addi	sp,sp,64
 788:	8082                	ret
    x = -xx;
 78a:	40b005bb          	negw	a1,a1
    neg = 1;
 78e:	4885                	li	a7,1
    x = -xx;
 790:	bf8d                	j	702 <printint+0x1a>

0000000000000792 <fflush>:
void fflush(int fd){
 792:	1101                	addi	sp,sp,-32
 794:	ec06                	sd	ra,24(sp)
 796:	e822                	sd	s0,16(sp)
 798:	e426                	sd	s1,8(sp)
 79a:	e04a                	sd	s2,0(sp)
 79c:	1000                	addi	s0,sp,32
 79e:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 7a0:	00000097          	auipc	ra,0x0
 7a4:	e76080e7          	jalr	-394(ra) # 616 <get_putc_buf>
 7a8:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 7aa:	00291793          	slli	a5,s2,0x2
 7ae:	00000497          	auipc	s1,0x0
 7b2:	31248493          	addi	s1,s1,786 # ac0 <putc_buf>
 7b6:	94be                	add	s1,s1,a5
 7b8:	3204a603          	lw	a2,800(s1)
 7bc:	854a                	mv	a0,s2
 7be:	00000097          	auipc	ra,0x0
 7c2:	c44080e7          	jalr	-956(ra) # 402 <write>
  putc_index[fd] = 0;
 7c6:	3204a023          	sw	zero,800(s1)
}
 7ca:	60e2                	ld	ra,24(sp)
 7cc:	6442                	ld	s0,16(sp)
 7ce:	64a2                	ld	s1,8(sp)
 7d0:	6902                	ld	s2,0(sp)
 7d2:	6105                	addi	sp,sp,32
 7d4:	8082                	ret

00000000000007d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7d6:	7119                	addi	sp,sp,-128
 7d8:	fc86                	sd	ra,120(sp)
 7da:	f8a2                	sd	s0,112(sp)
 7dc:	f4a6                	sd	s1,104(sp)
 7de:	f0ca                	sd	s2,96(sp)
 7e0:	ecce                	sd	s3,88(sp)
 7e2:	e8d2                	sd	s4,80(sp)
 7e4:	e4d6                	sd	s5,72(sp)
 7e6:	e0da                	sd	s6,64(sp)
 7e8:	fc5e                	sd	s7,56(sp)
 7ea:	f862                	sd	s8,48(sp)
 7ec:	f466                	sd	s9,40(sp)
 7ee:	f06a                	sd	s10,32(sp)
 7f0:	ec6e                	sd	s11,24(sp)
 7f2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7f4:	0005c903          	lbu	s2,0(a1)
 7f8:	18090f63          	beqz	s2,996 <vprintf+0x1c0>
 7fc:	8aaa                	mv	s5,a0
 7fe:	8b32                	mv	s6,a2
 800:	00158493          	addi	s1,a1,1
  state = 0;
 804:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 806:	02500a13          	li	s4,37
      if(c == 'd'){
 80a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 80e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 812:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 816:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 81a:	00000b97          	auipc	s7,0x0
 81e:	276b8b93          	addi	s7,s7,630 # a90 <digits>
 822:	a839                	j	840 <vprintf+0x6a>
        putc(fd, c);
 824:	85ca                	mv	a1,s2
 826:	8556                	mv	a0,s5
 828:	00000097          	auipc	ra,0x0
 82c:	e3a080e7          	jalr	-454(ra) # 662 <putc>
 830:	a019                	j	836 <vprintf+0x60>
    } else if(state == '%'){
 832:	01498f63          	beq	s3,s4,850 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 836:	0485                	addi	s1,s1,1
 838:	fff4c903          	lbu	s2,-1(s1)
 83c:	14090d63          	beqz	s2,996 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 840:	0009079b          	sext.w	a5,s2
    if(state == 0){
 844:	fe0997e3          	bnez	s3,832 <vprintf+0x5c>
      if(c == '%'){
 848:	fd479ee3          	bne	a5,s4,824 <vprintf+0x4e>
        state = '%';
 84c:	89be                	mv	s3,a5
 84e:	b7e5                	j	836 <vprintf+0x60>
      if(c == 'd'){
 850:	05878063          	beq	a5,s8,890 <vprintf+0xba>
      } else if(c == 'l') {
 854:	05978c63          	beq	a5,s9,8ac <vprintf+0xd6>
      } else if(c == 'x') {
 858:	07a78863          	beq	a5,s10,8c8 <vprintf+0xf2>
      } else if(c == 'p') {
 85c:	09b78463          	beq	a5,s11,8e4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 860:	07300713          	li	a4,115
 864:	0ce78663          	beq	a5,a4,930 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 868:	06300713          	li	a4,99
 86c:	0ee78e63          	beq	a5,a4,968 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 870:	11478863          	beq	a5,s4,980 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 874:	85d2                	mv	a1,s4
 876:	8556                	mv	a0,s5
 878:	00000097          	auipc	ra,0x0
 87c:	dea080e7          	jalr	-534(ra) # 662 <putc>
        putc(fd, c);
 880:	85ca                	mv	a1,s2
 882:	8556                	mv	a0,s5
 884:	00000097          	auipc	ra,0x0
 888:	dde080e7          	jalr	-546(ra) # 662 <putc>
      }
      state = 0;
 88c:	4981                	li	s3,0
 88e:	b765                	j	836 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 890:	008b0913          	addi	s2,s6,8
 894:	4685                	li	a3,1
 896:	4629                	li	a2,10
 898:	000b2583          	lw	a1,0(s6)
 89c:	8556                	mv	a0,s5
 89e:	00000097          	auipc	ra,0x0
 8a2:	e4a080e7          	jalr	-438(ra) # 6e8 <printint>
 8a6:	8b4a                	mv	s6,s2
      state = 0;
 8a8:	4981                	li	s3,0
 8aa:	b771                	j	836 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8ac:	008b0913          	addi	s2,s6,8
 8b0:	4681                	li	a3,0
 8b2:	4629                	li	a2,10
 8b4:	000b2583          	lw	a1,0(s6)
 8b8:	8556                	mv	a0,s5
 8ba:	00000097          	auipc	ra,0x0
 8be:	e2e080e7          	jalr	-466(ra) # 6e8 <printint>
 8c2:	8b4a                	mv	s6,s2
      state = 0;
 8c4:	4981                	li	s3,0
 8c6:	bf85                	j	836 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 8c8:	008b0913          	addi	s2,s6,8
 8cc:	4681                	li	a3,0
 8ce:	4641                	li	a2,16
 8d0:	000b2583          	lw	a1,0(s6)
 8d4:	8556                	mv	a0,s5
 8d6:	00000097          	auipc	ra,0x0
 8da:	e12080e7          	jalr	-494(ra) # 6e8 <printint>
 8de:	8b4a                	mv	s6,s2
      state = 0;
 8e0:	4981                	li	s3,0
 8e2:	bf91                	j	836 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 8e4:	008b0793          	addi	a5,s6,8
 8e8:	f8f43423          	sd	a5,-120(s0)
 8ec:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 8f0:	03000593          	li	a1,48
 8f4:	8556                	mv	a0,s5
 8f6:	00000097          	auipc	ra,0x0
 8fa:	d6c080e7          	jalr	-660(ra) # 662 <putc>
  putc(fd, 'x');
 8fe:	85ea                	mv	a1,s10
 900:	8556                	mv	a0,s5
 902:	00000097          	auipc	ra,0x0
 906:	d60080e7          	jalr	-672(ra) # 662 <putc>
 90a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 90c:	03c9d793          	srli	a5,s3,0x3c
 910:	97de                	add	a5,a5,s7
 912:	0007c583          	lbu	a1,0(a5)
 916:	8556                	mv	a0,s5
 918:	00000097          	auipc	ra,0x0
 91c:	d4a080e7          	jalr	-694(ra) # 662 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 920:	0992                	slli	s3,s3,0x4
 922:	397d                	addiw	s2,s2,-1
 924:	fe0914e3          	bnez	s2,90c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 928:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 92c:	4981                	li	s3,0
 92e:	b721                	j	836 <vprintf+0x60>
        s = va_arg(ap, char*);
 930:	008b0993          	addi	s3,s6,8
 934:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 938:	02090163          	beqz	s2,95a <vprintf+0x184>
        while(*s != 0){
 93c:	00094583          	lbu	a1,0(s2)
 940:	c9a1                	beqz	a1,990 <vprintf+0x1ba>
          putc(fd, *s);
 942:	8556                	mv	a0,s5
 944:	00000097          	auipc	ra,0x0
 948:	d1e080e7          	jalr	-738(ra) # 662 <putc>
          s++;
 94c:	0905                	addi	s2,s2,1
        while(*s != 0){
 94e:	00094583          	lbu	a1,0(s2)
 952:	f9e5                	bnez	a1,942 <vprintf+0x16c>
        s = va_arg(ap, char*);
 954:	8b4e                	mv	s6,s3
      state = 0;
 956:	4981                	li	s3,0
 958:	bdf9                	j	836 <vprintf+0x60>
          s = "(null)";
 95a:	00000917          	auipc	s2,0x0
 95e:	12e90913          	addi	s2,s2,302 # a88 <printf+0xa6>
        while(*s != 0){
 962:	02800593          	li	a1,40
 966:	bff1                	j	942 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 968:	008b0913          	addi	s2,s6,8
 96c:	000b4583          	lbu	a1,0(s6)
 970:	8556                	mv	a0,s5
 972:	00000097          	auipc	ra,0x0
 976:	cf0080e7          	jalr	-784(ra) # 662 <putc>
 97a:	8b4a                	mv	s6,s2
      state = 0;
 97c:	4981                	li	s3,0
 97e:	bd65                	j	836 <vprintf+0x60>
        putc(fd, c);
 980:	85d2                	mv	a1,s4
 982:	8556                	mv	a0,s5
 984:	00000097          	auipc	ra,0x0
 988:	cde080e7          	jalr	-802(ra) # 662 <putc>
      state = 0;
 98c:	4981                	li	s3,0
 98e:	b565                	j	836 <vprintf+0x60>
        s = va_arg(ap, char*);
 990:	8b4e                	mv	s6,s3
      state = 0;
 992:	4981                	li	s3,0
 994:	b54d                	j	836 <vprintf+0x60>
    }
  }
}
 996:	70e6                	ld	ra,120(sp)
 998:	7446                	ld	s0,112(sp)
 99a:	74a6                	ld	s1,104(sp)
 99c:	7906                	ld	s2,96(sp)
 99e:	69e6                	ld	s3,88(sp)
 9a0:	6a46                	ld	s4,80(sp)
 9a2:	6aa6                	ld	s5,72(sp)
 9a4:	6b06                	ld	s6,64(sp)
 9a6:	7be2                	ld	s7,56(sp)
 9a8:	7c42                	ld	s8,48(sp)
 9aa:	7ca2                	ld	s9,40(sp)
 9ac:	7d02                	ld	s10,32(sp)
 9ae:	6de2                	ld	s11,24(sp)
 9b0:	6109                	addi	sp,sp,128
 9b2:	8082                	ret

00000000000009b4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9b4:	715d                	addi	sp,sp,-80
 9b6:	ec06                	sd	ra,24(sp)
 9b8:	e822                	sd	s0,16(sp)
 9ba:	1000                	addi	s0,sp,32
 9bc:	e010                	sd	a2,0(s0)
 9be:	e414                	sd	a3,8(s0)
 9c0:	e818                	sd	a4,16(s0)
 9c2:	ec1c                	sd	a5,24(s0)
 9c4:	03043023          	sd	a6,32(s0)
 9c8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9cc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9d0:	8622                	mv	a2,s0
 9d2:	00000097          	auipc	ra,0x0
 9d6:	e04080e7          	jalr	-508(ra) # 7d6 <vprintf>
}
 9da:	60e2                	ld	ra,24(sp)
 9dc:	6442                	ld	s0,16(sp)
 9de:	6161                	addi	sp,sp,80
 9e0:	8082                	ret

00000000000009e2 <printf>:

void
printf(const char *fmt, ...)
{
 9e2:	711d                	addi	sp,sp,-96
 9e4:	ec06                	sd	ra,24(sp)
 9e6:	e822                	sd	s0,16(sp)
 9e8:	1000                	addi	s0,sp,32
 9ea:	e40c                	sd	a1,8(s0)
 9ec:	e810                	sd	a2,16(s0)
 9ee:	ec14                	sd	a3,24(s0)
 9f0:	f018                	sd	a4,32(s0)
 9f2:	f41c                	sd	a5,40(s0)
 9f4:	03043823          	sd	a6,48(s0)
 9f8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9fc:	00840613          	addi	a2,s0,8
 a00:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a04:	85aa                	mv	a1,a0
 a06:	4505                	li	a0,1
 a08:	00000097          	auipc	ra,0x0
 a0c:	dce080e7          	jalr	-562(ra) # 7d6 <vprintf>
}
 a10:	60e2                	ld	ra,24(sp)
 a12:	6442                	ld	s0,16(sp)
 a14:	6125                	addi	sp,sp,96
 a16:	8082                	ret
