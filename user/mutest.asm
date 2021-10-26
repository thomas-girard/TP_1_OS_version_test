
user/_mutest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(){
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  int fd = create_mutex();
   e:	00000097          	auipc	ra,0x0
  12:	40a080e7          	jalr	1034(ra) # 418 <create_mutex>
  16:	89aa                	mv	s3,a0
  acquire_mutex(fd);
  18:	00000097          	auipc	ra,0x0
  1c:	408080e7          	jalr	1032(ra) # 420 <acquire_mutex>
  int pid = fork();
  20:	00000097          	auipc	ra,0x0
  24:	340080e7          	jalr	832(ra) # 360 <fork>
  if(pid < 0){
  28:	02054f63          	bltz	a0,66 <main+0x66>
    printf("error fork\n");
    exit(1);
  } else if (pid == 0){
  2c:	3e800493          	li	s1,1000
    acquire_mutex(fd);
    printf("Oui, père.\n");
    exit(0);
  } else {
    for(int i = 0; i < 1000; i++){
      printf("Fils, tu m'attendras\n");
  30:	00001917          	auipc	s2,0x1
  34:	99090913          	addi	s2,s2,-1648 # 9c0 <malloc+0x106>
  } else if (pid == 0){
  38:	c521                	beqz	a0,80 <main+0x80>
      printf("Fils, tu m'attendras\n");
  3a:	854a                	mv	a0,s2
  3c:	00000097          	auipc	ra,0x0
  40:	7c0080e7          	jalr	1984(ra) # 7fc <printf>
    for(int i = 0; i < 1000; i++){
  44:	34fd                	addiw	s1,s1,-1
  46:	f8f5                	bnez	s1,3a <main+0x3a>
    }
    release_mutex(fd);
  48:	854e                	mv	a0,s3
  4a:	00000097          	auipc	ra,0x0
  4e:	3de080e7          	jalr	990(ra) # 428 <release_mutex>
    wait(0);
  52:	4501                	li	a0,0
  54:	00000097          	auipc	ra,0x0
  58:	31c080e7          	jalr	796(ra) # 370 <wait>
    exit(0);
  5c:	4501                	li	a0,0
  5e:	00000097          	auipc	ra,0x0
  62:	30a080e7          	jalr	778(ra) # 368 <exit>
    printf("error fork\n");
  66:	00001517          	auipc	a0,0x1
  6a:	93a50513          	addi	a0,a0,-1734 # 9a0 <malloc+0xe6>
  6e:	00000097          	auipc	ra,0x0
  72:	78e080e7          	jalr	1934(ra) # 7fc <printf>
    exit(1);
  76:	4505                	li	a0,1
  78:	00000097          	auipc	ra,0x0
  7c:	2f0080e7          	jalr	752(ra) # 368 <exit>
    acquire_mutex(fd);
  80:	854e                	mv	a0,s3
  82:	00000097          	auipc	ra,0x0
  86:	39e080e7          	jalr	926(ra) # 420 <acquire_mutex>
    printf("Oui, père.\n");
  8a:	00001517          	auipc	a0,0x1
  8e:	92650513          	addi	a0,a0,-1754 # 9b0 <malloc+0xf6>
  92:	00000097          	auipc	ra,0x0
  96:	76a080e7          	jalr	1898(ra) # 7fc <printf>
    exit(0);
  9a:	4501                	li	a0,0
  9c:	00000097          	auipc	ra,0x0
  a0:	2cc080e7          	jalr	716(ra) # 368 <exit>

00000000000000a4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  aa:	87aa                	mv	a5,a0
  ac:	0585                	addi	a1,a1,1
  ae:	0785                	addi	a5,a5,1
  b0:	fff5c703          	lbu	a4,-1(a1)
  b4:	fee78fa3          	sb	a4,-1(a5)
  b8:	fb75                	bnez	a4,ac <strcpy+0x8>
    ;
  return os;
}
  ba:	6422                	ld	s0,8(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	cb91                	beqz	a5,de <strcmp+0x1e>
  cc:	0005c703          	lbu	a4,0(a1)
  d0:	00f71763          	bne	a4,a5,de <strcmp+0x1e>
    p++, q++;
  d4:	0505                	addi	a0,a0,1
  d6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d8:	00054783          	lbu	a5,0(a0)
  dc:	fbe5                	bnez	a5,cc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  de:	0005c503          	lbu	a0,0(a1)
}
  e2:	40a7853b          	subw	a0,a5,a0
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret

00000000000000ec <strlen>:

uint
strlen(const char *s)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f2:	00054783          	lbu	a5,0(a0)
  f6:	cf91                	beqz	a5,112 <strlen+0x26>
  f8:	0505                	addi	a0,a0,1
  fa:	87aa                	mv	a5,a0
  fc:	4685                	li	a3,1
  fe:	9e89                	subw	a3,a3,a0
 100:	00f6853b          	addw	a0,a3,a5
 104:	0785                	addi	a5,a5,1
 106:	fff7c703          	lbu	a4,-1(a5)
 10a:	fb7d                	bnez	a4,100 <strlen+0x14>
    ;
  return n;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret
  for(n = 0; s[n]; n++)
 112:	4501                	li	a0,0
 114:	bfe5                	j	10c <strlen+0x20>

0000000000000116 <memset>:

void*
memset(void *dst, int c, uint n)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 11c:	ce09                	beqz	a2,136 <memset+0x20>
 11e:	87aa                	mv	a5,a0
 120:	fff6071b          	addiw	a4,a2,-1
 124:	1702                	slli	a4,a4,0x20
 126:	9301                	srli	a4,a4,0x20
 128:	0705                	addi	a4,a4,1
 12a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 12c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 130:	0785                	addi	a5,a5,1
 132:	fee79de3          	bne	a5,a4,12c <memset+0x16>
  }
  return dst;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  for(; *s; s++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb99                	beqz	a5,15c <strchr+0x20>
    if(*s == c)
 148:	00f58763          	beq	a1,a5,156 <strchr+0x1a>
  for(; *s; s++)
 14c:	0505                	addi	a0,a0,1
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbfd                	bnez	a5,148 <strchr+0xc>
      return (char*)s;
  return 0;
 154:	4501                	li	a0,0
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strchr+0x1a>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	711d                	addi	sp,sp,-96
 162:	ec86                	sd	ra,88(sp)
 164:	e8a2                	sd	s0,80(sp)
 166:	e4a6                	sd	s1,72(sp)
 168:	e0ca                	sd	s2,64(sp)
 16a:	fc4e                	sd	s3,56(sp)
 16c:	f852                	sd	s4,48(sp)
 16e:	f456                	sd	s5,40(sp)
 170:	f05a                	sd	s6,32(sp)
 172:	ec5e                	sd	s7,24(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17e:	4aa9                	li	s5,10
 180:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	2485                	addiw	s1,s1,1
 186:	0344d863          	bge	s1,s4,1b6 <gets+0x56>
    cc = read(0, &c, 1);
 18a:	4605                	li	a2,1
 18c:	faf40593          	addi	a1,s0,-81
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	1ee080e7          	jalr	494(ra) # 380 <read>
    if(cc < 1)
 19a:	00a05e63          	blez	a0,1b6 <gets+0x56>
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	01578763          	beq	a5,s5,1b4 <gets+0x54>
 1aa:	0905                	addi	s2,s2,1
 1ac:	fd679be3          	bne	a5,s6,182 <gets+0x22>
  for(i=0; i+1 < max; ){
 1b0:	89a6                	mv	s3,s1
 1b2:	a011                	j	1b6 <gets+0x56>
 1b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b6:	99de                	add	s3,s3,s7
 1b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1bc:	855e                	mv	a0,s7
 1be:	60e6                	ld	ra,88(sp)
 1c0:	6446                	ld	s0,80(sp)
 1c2:	64a6                	ld	s1,72(sp)
 1c4:	6906                	ld	s2,64(sp)
 1c6:	79e2                	ld	s3,56(sp)
 1c8:	7a42                	ld	s4,48(sp)
 1ca:	7aa2                	ld	s5,40(sp)
 1cc:	7b02                	ld	s6,32(sp)
 1ce:	6be2                	ld	s7,24(sp)
 1d0:	6125                	addi	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1da:	00054603          	lbu	a2,0(a0)
 1de:	fd06079b          	addiw	a5,a2,-48
 1e2:	0ff7f793          	andi	a5,a5,255
 1e6:	4725                	li	a4,9
 1e8:	02f76963          	bltu	a4,a5,21a <atoi+0x46>
 1ec:	86aa                	mv	a3,a0
  n = 0;
 1ee:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1f0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1f2:	0685                	addi	a3,a3,1
 1f4:	0025179b          	slliw	a5,a0,0x2
 1f8:	9fa9                	addw	a5,a5,a0
 1fa:	0017979b          	slliw	a5,a5,0x1
 1fe:	9fb1                	addw	a5,a5,a2
 200:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 204:	0006c603          	lbu	a2,0(a3)
 208:	fd06071b          	addiw	a4,a2,-48
 20c:	0ff77713          	andi	a4,a4,255
 210:	fee5f1e3          	bgeu	a1,a4,1f2 <atoi+0x1e>
  return n;
}
 214:	6422                	ld	s0,8(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret
  n = 0;
 21a:	4501                	li	a0,0
 21c:	bfe5                	j	214 <atoi+0x40>

000000000000021e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 224:	02b57663          	bgeu	a0,a1,250 <memmove+0x32>
    while(n-- > 0)
 228:	02c05163          	blez	a2,24a <memmove+0x2c>
 22c:	fff6079b          	addiw	a5,a2,-1
 230:	1782                	slli	a5,a5,0x20
 232:	9381                	srli	a5,a5,0x20
 234:	0785                	addi	a5,a5,1
 236:	97aa                	add	a5,a5,a0
  dst = vdst;
 238:	872a                	mv	a4,a0
      *dst++ = *src++;
 23a:	0585                	addi	a1,a1,1
 23c:	0705                	addi	a4,a4,1
 23e:	fff5c683          	lbu	a3,-1(a1)
 242:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 246:	fee79ae3          	bne	a5,a4,23a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
    dst += n;
 250:	00c50733          	add	a4,a0,a2
    src += n;
 254:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 256:	fec05ae3          	blez	a2,24a <memmove+0x2c>
 25a:	fff6079b          	addiw	a5,a2,-1
 25e:	1782                	slli	a5,a5,0x20
 260:	9381                	srli	a5,a5,0x20
 262:	fff7c793          	not	a5,a5
 266:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 268:	15fd                	addi	a1,a1,-1
 26a:	177d                	addi	a4,a4,-1
 26c:	0005c683          	lbu	a3,0(a1)
 270:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 274:	fee79ae3          	bne	a5,a4,268 <memmove+0x4a>
 278:	bfc9                	j	24a <memmove+0x2c>

000000000000027a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 280:	ca05                	beqz	a2,2b0 <memcmp+0x36>
 282:	fff6069b          	addiw	a3,a2,-1
 286:	1682                	slli	a3,a3,0x20
 288:	9281                	srli	a3,a3,0x20
 28a:	0685                	addi	a3,a3,1
 28c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 28e:	00054783          	lbu	a5,0(a0)
 292:	0005c703          	lbu	a4,0(a1)
 296:	00e79863          	bne	a5,a4,2a6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 29a:	0505                	addi	a0,a0,1
    p2++;
 29c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 29e:	fed518e3          	bne	a0,a3,28e <memcmp+0x14>
  }
  return 0;
 2a2:	4501                	li	a0,0
 2a4:	a019                	j	2aa <memcmp+0x30>
      return *p1 - *p2;
 2a6:	40e7853b          	subw	a0,a5,a4
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	addi	sp,sp,16
 2ae:	8082                	ret
  return 0;
 2b0:	4501                	li	a0,0
 2b2:	bfe5                	j	2aa <memcmp+0x30>

00000000000002b4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2bc:	00000097          	auipc	ra,0x0
 2c0:	f62080e7          	jalr	-158(ra) # 21e <memmove>
}
 2c4:	60a2                	ld	ra,8(sp)
 2c6:	6402                	ld	s0,0(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret

00000000000002cc <close>:

int close(int fd){
 2cc:	1101                	addi	sp,sp,-32
 2ce:	ec06                	sd	ra,24(sp)
 2d0:	e822                	sd	s0,16(sp)
 2d2:	e426                	sd	s1,8(sp)
 2d4:	1000                	addi	s0,sp,32
 2d6:	84aa                	mv	s1,a0
  fflush(fd);
 2d8:	00000097          	auipc	ra,0x0
 2dc:	2d4080e7          	jalr	724(ra) # 5ac <fflush>
  char* buf = get_putc_buf(fd);
 2e0:	8526                	mv	a0,s1
 2e2:	00000097          	auipc	ra,0x0
 2e6:	14e080e7          	jalr	334(ra) # 430 <get_putc_buf>
  if(buf){
 2ea:	cd11                	beqz	a0,306 <close+0x3a>
    free(buf);
 2ec:	00000097          	auipc	ra,0x0
 2f0:	546080e7          	jalr	1350(ra) # 832 <free>
    putc_buf[fd] = 0;
 2f4:	00349713          	slli	a4,s1,0x3
 2f8:	00000797          	auipc	a5,0x0
 2fc:	70878793          	addi	a5,a5,1800 # a00 <putc_buf>
 300:	97ba                	add	a5,a5,a4
 302:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 306:	8526                	mv	a0,s1
 308:	00000097          	auipc	ra,0x0
 30c:	088080e7          	jalr	136(ra) # 390 <sclose>
}
 310:	60e2                	ld	ra,24(sp)
 312:	6442                	ld	s0,16(sp)
 314:	64a2                	ld	s1,8(sp)
 316:	6105                	addi	sp,sp,32
 318:	8082                	ret

000000000000031a <stat>:
{
 31a:	1101                	addi	sp,sp,-32
 31c:	ec06                	sd	ra,24(sp)
 31e:	e822                	sd	s0,16(sp)
 320:	e426                	sd	s1,8(sp)
 322:	e04a                	sd	s2,0(sp)
 324:	1000                	addi	s0,sp,32
 326:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 328:	4581                	li	a1,0
 32a:	00000097          	auipc	ra,0x0
 32e:	07e080e7          	jalr	126(ra) # 3a8 <open>
  if(fd < 0)
 332:	02054563          	bltz	a0,35c <stat+0x42>
 336:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 338:	85ca                	mv	a1,s2
 33a:	00000097          	auipc	ra,0x0
 33e:	086080e7          	jalr	134(ra) # 3c0 <fstat>
 342:	892a                	mv	s2,a0
  close(fd);
 344:	8526                	mv	a0,s1
 346:	00000097          	auipc	ra,0x0
 34a:	f86080e7          	jalr	-122(ra) # 2cc <close>
}
 34e:	854a                	mv	a0,s2
 350:	60e2                	ld	ra,24(sp)
 352:	6442                	ld	s0,16(sp)
 354:	64a2                	ld	s1,8(sp)
 356:	6902                	ld	s2,0(sp)
 358:	6105                	addi	sp,sp,32
 35a:	8082                	ret
    return -1;
 35c:	597d                	li	s2,-1
 35e:	bfc5                	j	34e <stat+0x34>

0000000000000360 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 360:	4885                	li	a7,1
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <exit>:
.global exit
exit:
 li a7, SYS_exit
 368:	4889                	li	a7,2
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <wait>:
.global wait
wait:
 li a7, SYS_wait
 370:	488d                	li	a7,3
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 378:	4891                	li	a7,4
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <read>:
.global read
read:
 li a7, SYS_read
 380:	4895                	li	a7,5
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <write>:
.global write
write:
 li a7, SYS_write
 388:	48c1                	li	a7,16
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 390:	48d5                	li	a7,21
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <kill>:
.global kill
kill:
 li a7, SYS_kill
 398:	4899                	li	a7,6
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a0:	489d                	li	a7,7
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <open>:
.global open
open:
 li a7, SYS_open
 3a8:	48bd                	li	a7,15
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b0:	48c5                	li	a7,17
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b8:	48c9                	li	a7,18
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c0:	48a1                	li	a7,8
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <link>:
.global link
link:
 li a7, SYS_link
 3c8:	48cd                	li	a7,19
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d0:	48d1                	li	a7,20
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d8:	48a5                	li	a7,9
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e0:	48a9                	li	a7,10
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e8:	48ad                	li	a7,11
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3f0:	48b1                	li	a7,12
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3f8:	48b5                	li	a7,13
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 400:	48b9                	li	a7,14
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 408:	48d9                	li	a7,22
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <nice>:
.global nice
nice:
 li a7, SYS_nice
 410:	48dd                	li	a7,23
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 418:	48e1                	li	a7,24
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 420:	48e5                	li	a7,25
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 428:	48e9                	li	a7,26
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 430:	1101                	addi	sp,sp,-32
 432:	ec06                	sd	ra,24(sp)
 434:	e822                	sd	s0,16(sp)
 436:	e426                	sd	s1,8(sp)
 438:	1000                	addi	s0,sp,32
 43a:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 43c:	00351713          	slli	a4,a0,0x3
 440:	00000797          	auipc	a5,0x0
 444:	5c078793          	addi	a5,a5,1472 # a00 <putc_buf>
 448:	97ba                	add	a5,a5,a4
 44a:	6388                	ld	a0,0(a5)
  if(buf) {
 44c:	c511                	beqz	a0,458 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 44e:	60e2                	ld	ra,24(sp)
 450:	6442                	ld	s0,16(sp)
 452:	64a2                	ld	s1,8(sp)
 454:	6105                	addi	sp,sp,32
 456:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 458:	6505                	lui	a0,0x1
 45a:	00000097          	auipc	ra,0x0
 45e:	460080e7          	jalr	1120(ra) # 8ba <malloc>
  putc_buf[fd] = buf;
 462:	00000797          	auipc	a5,0x0
 466:	59e78793          	addi	a5,a5,1438 # a00 <putc_buf>
 46a:	00349713          	slli	a4,s1,0x3
 46e:	973e                	add	a4,a4,a5
 470:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 472:	048a                	slli	s1,s1,0x2
 474:	94be                	add	s1,s1,a5
 476:	3204a023          	sw	zero,800(s1)
  return buf;
 47a:	bfd1                	j	44e <get_putc_buf+0x1e>

000000000000047c <putc>:

static void
putc(int fd, char c)
{
 47c:	1101                	addi	sp,sp,-32
 47e:	ec06                	sd	ra,24(sp)
 480:	e822                	sd	s0,16(sp)
 482:	e426                	sd	s1,8(sp)
 484:	e04a                	sd	s2,0(sp)
 486:	1000                	addi	s0,sp,32
 488:	84aa                	mv	s1,a0
 48a:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 48c:	00000097          	auipc	ra,0x0
 490:	fa4080e7          	jalr	-92(ra) # 430 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 494:	00249793          	slli	a5,s1,0x2
 498:	00000717          	auipc	a4,0x0
 49c:	56870713          	addi	a4,a4,1384 # a00 <putc_buf>
 4a0:	973e                	add	a4,a4,a5
 4a2:	32072783          	lw	a5,800(a4)
 4a6:	0017869b          	addiw	a3,a5,1
 4aa:	32d72023          	sw	a3,800(a4)
 4ae:	97aa                	add	a5,a5,a0
 4b0:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 4b4:	47a9                	li	a5,10
 4b6:	02f90463          	beq	s2,a5,4de <putc+0x62>
 4ba:	00249713          	slli	a4,s1,0x2
 4be:	00000797          	auipc	a5,0x0
 4c2:	54278793          	addi	a5,a5,1346 # a00 <putc_buf>
 4c6:	97ba                	add	a5,a5,a4
 4c8:	3207a703          	lw	a4,800(a5)
 4cc:	6785                	lui	a5,0x1
 4ce:	00f70863          	beq	a4,a5,4de <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 4d2:	60e2                	ld	ra,24(sp)
 4d4:	6442                	ld	s0,16(sp)
 4d6:	64a2                	ld	s1,8(sp)
 4d8:	6902                	ld	s2,0(sp)
 4da:	6105                	addi	sp,sp,32
 4dc:	8082                	ret
    write(fd, buf, putc_index[fd]);
 4de:	00249793          	slli	a5,s1,0x2
 4e2:	00000917          	auipc	s2,0x0
 4e6:	51e90913          	addi	s2,s2,1310 # a00 <putc_buf>
 4ea:	993e                	add	s2,s2,a5
 4ec:	32092603          	lw	a2,800(s2)
 4f0:	85aa                	mv	a1,a0
 4f2:	8526                	mv	a0,s1
 4f4:	00000097          	auipc	ra,0x0
 4f8:	e94080e7          	jalr	-364(ra) # 388 <write>
    putc_index[fd] = 0;
 4fc:	32092023          	sw	zero,800(s2)
}
 500:	bfc9                	j	4d2 <putc+0x56>

0000000000000502 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 502:	7139                	addi	sp,sp,-64
 504:	fc06                	sd	ra,56(sp)
 506:	f822                	sd	s0,48(sp)
 508:	f426                	sd	s1,40(sp)
 50a:	f04a                	sd	s2,32(sp)
 50c:	ec4e                	sd	s3,24(sp)
 50e:	0080                	addi	s0,sp,64
 510:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 512:	c299                	beqz	a3,518 <printint+0x16>
 514:	0805c863          	bltz	a1,5a4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 518:	2581                	sext.w	a1,a1
  neg = 0;
 51a:	4881                	li	a7,0
 51c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 520:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 522:	2601                	sext.w	a2,a2
 524:	00000517          	auipc	a0,0x0
 528:	4bc50513          	addi	a0,a0,1212 # 9e0 <digits>
 52c:	883a                	mv	a6,a4
 52e:	2705                	addiw	a4,a4,1
 530:	02c5f7bb          	remuw	a5,a1,a2
 534:	1782                	slli	a5,a5,0x20
 536:	9381                	srli	a5,a5,0x20
 538:	97aa                	add	a5,a5,a0
 53a:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x140>
 53e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 542:	0005879b          	sext.w	a5,a1
 546:	02c5d5bb          	divuw	a1,a1,a2
 54a:	0685                	addi	a3,a3,1
 54c:	fec7f0e3          	bgeu	a5,a2,52c <printint+0x2a>
  if(neg)
 550:	00088b63          	beqz	a7,566 <printint+0x64>
    buf[i++] = '-';
 554:	fd040793          	addi	a5,s0,-48
 558:	973e                	add	a4,a4,a5
 55a:	02d00793          	li	a5,45
 55e:	fef70823          	sb	a5,-16(a4)
 562:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 566:	02e05863          	blez	a4,596 <printint+0x94>
 56a:	fc040793          	addi	a5,s0,-64
 56e:	00e78933          	add	s2,a5,a4
 572:	fff78993          	addi	s3,a5,-1
 576:	99ba                	add	s3,s3,a4
 578:	377d                	addiw	a4,a4,-1
 57a:	1702                	slli	a4,a4,0x20
 57c:	9301                	srli	a4,a4,0x20
 57e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 582:	fff94583          	lbu	a1,-1(s2)
 586:	8526                	mv	a0,s1
 588:	00000097          	auipc	ra,0x0
 58c:	ef4080e7          	jalr	-268(ra) # 47c <putc>
  while(--i >= 0)
 590:	197d                	addi	s2,s2,-1
 592:	ff3918e3          	bne	s2,s3,582 <printint+0x80>
}
 596:	70e2                	ld	ra,56(sp)
 598:	7442                	ld	s0,48(sp)
 59a:	74a2                	ld	s1,40(sp)
 59c:	7902                	ld	s2,32(sp)
 59e:	69e2                	ld	s3,24(sp)
 5a0:	6121                	addi	sp,sp,64
 5a2:	8082                	ret
    x = -xx;
 5a4:	40b005bb          	negw	a1,a1
    neg = 1;
 5a8:	4885                	li	a7,1
    x = -xx;
 5aa:	bf8d                	j	51c <printint+0x1a>

00000000000005ac <fflush>:
void fflush(int fd){
 5ac:	1101                	addi	sp,sp,-32
 5ae:	ec06                	sd	ra,24(sp)
 5b0:	e822                	sd	s0,16(sp)
 5b2:	e426                	sd	s1,8(sp)
 5b4:	e04a                	sd	s2,0(sp)
 5b6:	1000                	addi	s0,sp,32
 5b8:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 5ba:	00000097          	auipc	ra,0x0
 5be:	e76080e7          	jalr	-394(ra) # 430 <get_putc_buf>
 5c2:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 5c4:	00291793          	slli	a5,s2,0x2
 5c8:	00000497          	auipc	s1,0x0
 5cc:	43848493          	addi	s1,s1,1080 # a00 <putc_buf>
 5d0:	94be                	add	s1,s1,a5
 5d2:	3204a603          	lw	a2,800(s1)
 5d6:	854a                	mv	a0,s2
 5d8:	00000097          	auipc	ra,0x0
 5dc:	db0080e7          	jalr	-592(ra) # 388 <write>
  putc_index[fd] = 0;
 5e0:	3204a023          	sw	zero,800(s1)
}
 5e4:	60e2                	ld	ra,24(sp)
 5e6:	6442                	ld	s0,16(sp)
 5e8:	64a2                	ld	s1,8(sp)
 5ea:	6902                	ld	s2,0(sp)
 5ec:	6105                	addi	sp,sp,32
 5ee:	8082                	ret

00000000000005f0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5f0:	7119                	addi	sp,sp,-128
 5f2:	fc86                	sd	ra,120(sp)
 5f4:	f8a2                	sd	s0,112(sp)
 5f6:	f4a6                	sd	s1,104(sp)
 5f8:	f0ca                	sd	s2,96(sp)
 5fa:	ecce                	sd	s3,88(sp)
 5fc:	e8d2                	sd	s4,80(sp)
 5fe:	e4d6                	sd	s5,72(sp)
 600:	e0da                	sd	s6,64(sp)
 602:	fc5e                	sd	s7,56(sp)
 604:	f862                	sd	s8,48(sp)
 606:	f466                	sd	s9,40(sp)
 608:	f06a                	sd	s10,32(sp)
 60a:	ec6e                	sd	s11,24(sp)
 60c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 60e:	0005c903          	lbu	s2,0(a1)
 612:	18090f63          	beqz	s2,7b0 <vprintf+0x1c0>
 616:	8aaa                	mv	s5,a0
 618:	8b32                	mv	s6,a2
 61a:	00158493          	addi	s1,a1,1
  state = 0;
 61e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 620:	02500a13          	li	s4,37
      if(c == 'd'){
 624:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 628:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 62c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 630:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 634:	00000b97          	auipc	s7,0x0
 638:	3acb8b93          	addi	s7,s7,940 # 9e0 <digits>
 63c:	a839                	j	65a <vprintf+0x6a>
        putc(fd, c);
 63e:	85ca                	mv	a1,s2
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e3a080e7          	jalr	-454(ra) # 47c <putc>
 64a:	a019                	j	650 <vprintf+0x60>
    } else if(state == '%'){
 64c:	01498f63          	beq	s3,s4,66a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 650:	0485                	addi	s1,s1,1
 652:	fff4c903          	lbu	s2,-1(s1)
 656:	14090d63          	beqz	s2,7b0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 65a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 65e:	fe0997e3          	bnez	s3,64c <vprintf+0x5c>
      if(c == '%'){
 662:	fd479ee3          	bne	a5,s4,63e <vprintf+0x4e>
        state = '%';
 666:	89be                	mv	s3,a5
 668:	b7e5                	j	650 <vprintf+0x60>
      if(c == 'd'){
 66a:	05878063          	beq	a5,s8,6aa <vprintf+0xba>
      } else if(c == 'l') {
 66e:	05978c63          	beq	a5,s9,6c6 <vprintf+0xd6>
      } else if(c == 'x') {
 672:	07a78863          	beq	a5,s10,6e2 <vprintf+0xf2>
      } else if(c == 'p') {
 676:	09b78463          	beq	a5,s11,6fe <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 67a:	07300713          	li	a4,115
 67e:	0ce78663          	beq	a5,a4,74a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 682:	06300713          	li	a4,99
 686:	0ee78e63          	beq	a5,a4,782 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 68a:	11478863          	beq	a5,s4,79a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 68e:	85d2                	mv	a1,s4
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	dea080e7          	jalr	-534(ra) # 47c <putc>
        putc(fd, c);
 69a:	85ca                	mv	a1,s2
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	dde080e7          	jalr	-546(ra) # 47c <putc>
      }
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b765                	j	650 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6aa:	008b0913          	addi	s2,s6,8
 6ae:	4685                	li	a3,1
 6b0:	4629                	li	a2,10
 6b2:	000b2583          	lw	a1,0(s6)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	e4a080e7          	jalr	-438(ra) # 502 <printint>
 6c0:	8b4a                	mv	s6,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	b771                	j	650 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c6:	008b0913          	addi	s2,s6,8
 6ca:	4681                	li	a3,0
 6cc:	4629                	li	a2,10
 6ce:	000b2583          	lw	a1,0(s6)
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	e2e080e7          	jalr	-466(ra) # 502 <printint>
 6dc:	8b4a                	mv	s6,s2
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bf85                	j	650 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6e2:	008b0913          	addi	s2,s6,8
 6e6:	4681                	li	a3,0
 6e8:	4641                	li	a2,16
 6ea:	000b2583          	lw	a1,0(s6)
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	e12080e7          	jalr	-494(ra) # 502 <printint>
 6f8:	8b4a                	mv	s6,s2
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	bf91                	j	650 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6fe:	008b0793          	addi	a5,s6,8
 702:	f8f43423          	sd	a5,-120(s0)
 706:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 70a:	03000593          	li	a1,48
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	d6c080e7          	jalr	-660(ra) # 47c <putc>
  putc(fd, 'x');
 718:	85ea                	mv	a1,s10
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	d60080e7          	jalr	-672(ra) # 47c <putc>
 724:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 726:	03c9d793          	srli	a5,s3,0x3c
 72a:	97de                	add	a5,a5,s7
 72c:	0007c583          	lbu	a1,0(a5)
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	d4a080e7          	jalr	-694(ra) # 47c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73a:	0992                	slli	s3,s3,0x4
 73c:	397d                	addiw	s2,s2,-1
 73e:	fe0914e3          	bnez	s2,726 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 742:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 746:	4981                	li	s3,0
 748:	b721                	j	650 <vprintf+0x60>
        s = va_arg(ap, char*);
 74a:	008b0993          	addi	s3,s6,8
 74e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 752:	02090163          	beqz	s2,774 <vprintf+0x184>
        while(*s != 0){
 756:	00094583          	lbu	a1,0(s2)
 75a:	c9a1                	beqz	a1,7aa <vprintf+0x1ba>
          putc(fd, *s);
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	d1e080e7          	jalr	-738(ra) # 47c <putc>
          s++;
 766:	0905                	addi	s2,s2,1
        while(*s != 0){
 768:	00094583          	lbu	a1,0(s2)
 76c:	f9e5                	bnez	a1,75c <vprintf+0x16c>
        s = va_arg(ap, char*);
 76e:	8b4e                	mv	s6,s3
      state = 0;
 770:	4981                	li	s3,0
 772:	bdf9                	j	650 <vprintf+0x60>
          s = "(null)";
 774:	00000917          	auipc	s2,0x0
 778:	26490913          	addi	s2,s2,612 # 9d8 <malloc+0x11e>
        while(*s != 0){
 77c:	02800593          	li	a1,40
 780:	bff1                	j	75c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 782:	008b0913          	addi	s2,s6,8
 786:	000b4583          	lbu	a1,0(s6)
 78a:	8556                	mv	a0,s5
 78c:	00000097          	auipc	ra,0x0
 790:	cf0080e7          	jalr	-784(ra) # 47c <putc>
 794:	8b4a                	mv	s6,s2
      state = 0;
 796:	4981                	li	s3,0
 798:	bd65                	j	650 <vprintf+0x60>
        putc(fd, c);
 79a:	85d2                	mv	a1,s4
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	cde080e7          	jalr	-802(ra) # 47c <putc>
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	b565                	j	650 <vprintf+0x60>
        s = va_arg(ap, char*);
 7aa:	8b4e                	mv	s6,s3
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	b54d                	j	650 <vprintf+0x60>
    }
  }
}
 7b0:	70e6                	ld	ra,120(sp)
 7b2:	7446                	ld	s0,112(sp)
 7b4:	74a6                	ld	s1,104(sp)
 7b6:	7906                	ld	s2,96(sp)
 7b8:	69e6                	ld	s3,88(sp)
 7ba:	6a46                	ld	s4,80(sp)
 7bc:	6aa6                	ld	s5,72(sp)
 7be:	6b06                	ld	s6,64(sp)
 7c0:	7be2                	ld	s7,56(sp)
 7c2:	7c42                	ld	s8,48(sp)
 7c4:	7ca2                	ld	s9,40(sp)
 7c6:	7d02                	ld	s10,32(sp)
 7c8:	6de2                	ld	s11,24(sp)
 7ca:	6109                	addi	sp,sp,128
 7cc:	8082                	ret

00000000000007ce <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ce:	715d                	addi	sp,sp,-80
 7d0:	ec06                	sd	ra,24(sp)
 7d2:	e822                	sd	s0,16(sp)
 7d4:	1000                	addi	s0,sp,32
 7d6:	e010                	sd	a2,0(s0)
 7d8:	e414                	sd	a3,8(s0)
 7da:	e818                	sd	a4,16(s0)
 7dc:	ec1c                	sd	a5,24(s0)
 7de:	03043023          	sd	a6,32(s0)
 7e2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ea:	8622                	mv	a2,s0
 7ec:	00000097          	auipc	ra,0x0
 7f0:	e04080e7          	jalr	-508(ra) # 5f0 <vprintf>
}
 7f4:	60e2                	ld	ra,24(sp)
 7f6:	6442                	ld	s0,16(sp)
 7f8:	6161                	addi	sp,sp,80
 7fa:	8082                	ret

00000000000007fc <printf>:

void
printf(const char *fmt, ...)
{
 7fc:	711d                	addi	sp,sp,-96
 7fe:	ec06                	sd	ra,24(sp)
 800:	e822                	sd	s0,16(sp)
 802:	1000                	addi	s0,sp,32
 804:	e40c                	sd	a1,8(s0)
 806:	e810                	sd	a2,16(s0)
 808:	ec14                	sd	a3,24(s0)
 80a:	f018                	sd	a4,32(s0)
 80c:	f41c                	sd	a5,40(s0)
 80e:	03043823          	sd	a6,48(s0)
 812:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 816:	00840613          	addi	a2,s0,8
 81a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81e:	85aa                	mv	a1,a0
 820:	4505                	li	a0,1
 822:	00000097          	auipc	ra,0x0
 826:	dce080e7          	jalr	-562(ra) # 5f0 <vprintf>
}
 82a:	60e2                	ld	ra,24(sp)
 82c:	6442                	ld	s0,16(sp)
 82e:	6125                	addi	sp,sp,96
 830:	8082                	ret

0000000000000832 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 832:	1141                	addi	sp,sp,-16
 834:	e422                	sd	s0,8(sp)
 836:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 838:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83c:	00000797          	auipc	a5,0x0
 840:	1bc7b783          	ld	a5,444(a5) # 9f8 <freep>
 844:	a805                	j	874 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 846:	4618                	lw	a4,8(a2)
 848:	9db9                	addw	a1,a1,a4
 84a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 84e:	6398                	ld	a4,0(a5)
 850:	6318                	ld	a4,0(a4)
 852:	fee53823          	sd	a4,-16(a0)
 856:	a091                	j	89a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 858:	ff852703          	lw	a4,-8(a0)
 85c:	9e39                	addw	a2,a2,a4
 85e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 860:	ff053703          	ld	a4,-16(a0)
 864:	e398                	sd	a4,0(a5)
 866:	a099                	j	8ac <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 868:	6398                	ld	a4,0(a5)
 86a:	00e7e463          	bltu	a5,a4,872 <free+0x40>
 86e:	00e6ea63          	bltu	a3,a4,882 <free+0x50>
{
 872:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 874:	fed7fae3          	bgeu	a5,a3,868 <free+0x36>
 878:	6398                	ld	a4,0(a5)
 87a:	00e6e463          	bltu	a3,a4,882 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87e:	fee7eae3          	bltu	a5,a4,872 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 882:	ff852583          	lw	a1,-8(a0)
 886:	6390                	ld	a2,0(a5)
 888:	02059713          	slli	a4,a1,0x20
 88c:	9301                	srli	a4,a4,0x20
 88e:	0712                	slli	a4,a4,0x4
 890:	9736                	add	a4,a4,a3
 892:	fae60ae3          	beq	a2,a4,846 <free+0x14>
    bp->s.ptr = p->s.ptr;
 896:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 89a:	4790                	lw	a2,8(a5)
 89c:	02061713          	slli	a4,a2,0x20
 8a0:	9301                	srli	a4,a4,0x20
 8a2:	0712                	slli	a4,a4,0x4
 8a4:	973e                	add	a4,a4,a5
 8a6:	fae689e3          	beq	a3,a4,858 <free+0x26>
  } else
    p->s.ptr = bp;
 8aa:	e394                	sd	a3,0(a5)
  freep = p;
 8ac:	00000717          	auipc	a4,0x0
 8b0:	14f73623          	sd	a5,332(a4) # 9f8 <freep>
}
 8b4:	6422                	ld	s0,8(sp)
 8b6:	0141                	addi	sp,sp,16
 8b8:	8082                	ret

00000000000008ba <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ba:	7139                	addi	sp,sp,-64
 8bc:	fc06                	sd	ra,56(sp)
 8be:	f822                	sd	s0,48(sp)
 8c0:	f426                	sd	s1,40(sp)
 8c2:	f04a                	sd	s2,32(sp)
 8c4:	ec4e                	sd	s3,24(sp)
 8c6:	e852                	sd	s4,16(sp)
 8c8:	e456                	sd	s5,8(sp)
 8ca:	e05a                	sd	s6,0(sp)
 8cc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ce:	02051493          	slli	s1,a0,0x20
 8d2:	9081                	srli	s1,s1,0x20
 8d4:	04bd                	addi	s1,s1,15
 8d6:	8091                	srli	s1,s1,0x4
 8d8:	0014899b          	addiw	s3,s1,1
 8dc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8de:	00000517          	auipc	a0,0x0
 8e2:	11a53503          	ld	a0,282(a0) # 9f8 <freep>
 8e6:	c515                	beqz	a0,912 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ea:	4798                	lw	a4,8(a5)
 8ec:	02977f63          	bgeu	a4,s1,92a <malloc+0x70>
 8f0:	8a4e                	mv	s4,s3
 8f2:	0009871b          	sext.w	a4,s3
 8f6:	6685                	lui	a3,0x1
 8f8:	00d77363          	bgeu	a4,a3,8fe <malloc+0x44>
 8fc:	6a05                	lui	s4,0x1
 8fe:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 902:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 906:	00000917          	auipc	s2,0x0
 90a:	0f290913          	addi	s2,s2,242 # 9f8 <freep>
  if(p == (char*)-1)
 90e:	5afd                	li	s5,-1
 910:	a88d                	j	982 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 912:	00000797          	auipc	a5,0x0
 916:	59e78793          	addi	a5,a5,1438 # eb0 <base>
 91a:	00000717          	auipc	a4,0x0
 91e:	0cf73f23          	sd	a5,222(a4) # 9f8 <freep>
 922:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 924:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 928:	b7e1                	j	8f0 <malloc+0x36>
      if(p->s.size == nunits)
 92a:	02e48b63          	beq	s1,a4,960 <malloc+0xa6>
        p->s.size -= nunits;
 92e:	4137073b          	subw	a4,a4,s3
 932:	c798                	sw	a4,8(a5)
        p += p->s.size;
 934:	1702                	slli	a4,a4,0x20
 936:	9301                	srli	a4,a4,0x20
 938:	0712                	slli	a4,a4,0x4
 93a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 93c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 940:	00000717          	auipc	a4,0x0
 944:	0aa73c23          	sd	a0,184(a4) # 9f8 <freep>
      return (void*)(p + 1);
 948:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 94c:	70e2                	ld	ra,56(sp)
 94e:	7442                	ld	s0,48(sp)
 950:	74a2                	ld	s1,40(sp)
 952:	7902                	ld	s2,32(sp)
 954:	69e2                	ld	s3,24(sp)
 956:	6a42                	ld	s4,16(sp)
 958:	6aa2                	ld	s5,8(sp)
 95a:	6b02                	ld	s6,0(sp)
 95c:	6121                	addi	sp,sp,64
 95e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 960:	6398                	ld	a4,0(a5)
 962:	e118                	sd	a4,0(a0)
 964:	bff1                	j	940 <malloc+0x86>
  hp->s.size = nu;
 966:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 96a:	0541                	addi	a0,a0,16
 96c:	00000097          	auipc	ra,0x0
 970:	ec6080e7          	jalr	-314(ra) # 832 <free>
  return freep;
 974:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 978:	d971                	beqz	a0,94c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 97c:	4798                	lw	a4,8(a5)
 97e:	fa9776e3          	bgeu	a4,s1,92a <malloc+0x70>
    if(p == freep)
 982:	00093703          	ld	a4,0(s2)
 986:	853e                	mv	a0,a5
 988:	fef719e3          	bne	a4,a5,97a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 98c:	8552                	mv	a0,s4
 98e:	00000097          	auipc	ra,0x0
 992:	a62080e7          	jalr	-1438(ra) # 3f0 <sbrk>
  if(p == (char*)-1)
 996:	fd5518e3          	bne	a0,s5,966 <malloc+0xac>
        return 0;
 99a:	4501                	li	a0,0
 99c:	bf45                	j	94c <malloc+0x92>
