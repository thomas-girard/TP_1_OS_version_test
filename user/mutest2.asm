
user/_mutest2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <freadint>:

char fname[] = "moncompteur";

#define MAXLEN 20

int freadint(){
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	0080                	addi	s0,sp,64
  int res = -1;
  char buf[MAXLEN];
  int fd = open(fname, O_RDONLY);
   c:	4581                	li	a1,0
   e:	00001517          	auipc	a0,0x1
  12:	b4250513          	addi	a0,a0,-1214 # b50 <fname>
  16:	00000097          	auipc	ra,0x0
  1a:	4f6080e7          	jalr	1270(ra) # 50c <open>
  1e:	84aa                	mv	s1,a0
  if(read(fd, buf, MAXLEN) > 0){
  20:	4651                	li	a2,20
  22:	fc840593          	addi	a1,s0,-56
  26:	00000097          	auipc	ra,0x0
  2a:	4be080e7          	jalr	1214(ra) # 4e4 <read>
  2e:	02a05563          	blez	a0,58 <freadint+0x58>
    res = atoi(buf);
  32:	fc840513          	addi	a0,s0,-56
  36:	00000097          	auipc	ra,0x0
  3a:	302080e7          	jalr	770(ra) # 338 <atoi>
  3e:	892a                	mv	s2,a0
  }
  close(fd);
  40:	8526                	mv	a0,s1
  42:	00000097          	auipc	ra,0x0
  46:	3ee080e7          	jalr	1006(ra) # 430 <close>
  return res;
}
  4a:	854a                	mv	a0,s2
  4c:	70e2                	ld	ra,56(sp)
  4e:	7442                	ld	s0,48(sp)
  50:	74a2                	ld	s1,40(sp)
  52:	7902                	ld	s2,32(sp)
  54:	6121                	addi	sp,sp,64
  56:	8082                	ret
  int res = -1;
  58:	597d                	li	s2,-1
  5a:	b7dd                	j	40 <freadint+0x40>

000000000000005c <fwriteint>:

void fwriteint(int i){
  5c:	1101                	addi	sp,sp,-32
  5e:	ec06                	sd	ra,24(sp)
  60:	e822                	sd	s0,16(sp)
  62:	e426                	sd	s1,8(sp)
  64:	e04a                	sd	s2,0(sp)
  66:	1000                	addi	s0,sp,32
  68:	892a                	mv	s2,a0
  int fd = open(fname, O_CREATE | O_RDWR);
  6a:	20200593          	li	a1,514
  6e:	00001517          	auipc	a0,0x1
  72:	ae250513          	addi	a0,a0,-1310 # b50 <fname>
  76:	00000097          	auipc	ra,0x0
  7a:	496080e7          	jalr	1174(ra) # 50c <open>
  7e:	84aa                	mv	s1,a0
  fprintf(fd, "%d\n", i);
  80:	864a                	mv	a2,s2
  82:	00001597          	auipc	a1,0x1
  86:	a8658593          	addi	a1,a1,-1402 # b08 <malloc+0xea>
  8a:	00001097          	auipc	ra,0x1
  8e:	8a8080e7          	jalr	-1880(ra) # 932 <fprintf>
  close(fd);
  92:	8526                	mv	a0,s1
  94:	00000097          	auipc	ra,0x0
  98:	39c080e7          	jalr	924(ra) # 430 <close>
}
  9c:	60e2                	ld	ra,24(sp)
  9e:	6442                	ld	s0,16(sp)
  a0:	64a2                	ld	s1,8(sp)
  a2:	6902                	ld	s2,0(sp)
  a4:	6105                	addi	sp,sp,32
  a6:	8082                	ret

00000000000000a8 <inc>:

#define NITER 100

void inc(int mut){
  a8:	1101                	addi	sp,sp,-32
  aa:	ec06                	sd	ra,24(sp)
  ac:	e822                	sd	s0,16(sp)
  ae:	e426                	sd	s1,8(sp)
  b0:	e04a                	sd	s2,0(sp)
  b2:	1000                	addi	s0,sp,32
  b4:	892a                	mv	s2,a0
  b6:	06400493          	li	s1,100
  for(int i = 0; i < NITER; i++){
    acquire_mutex(mut);
  ba:	854a                	mv	a0,s2
  bc:	00000097          	auipc	ra,0x0
  c0:	4c8080e7          	jalr	1224(ra) # 584 <acquire_mutex>
    int val = freadint();
  c4:	00000097          	auipc	ra,0x0
  c8:	f3c080e7          	jalr	-196(ra) # 0 <freadint>
    fwriteint(val+1);
  cc:	2505                	addiw	a0,a0,1
  ce:	00000097          	auipc	ra,0x0
  d2:	f8e080e7          	jalr	-114(ra) # 5c <fwriteint>
    release_mutex(mut);
  d6:	854a                	mv	a0,s2
  d8:	00000097          	auipc	ra,0x0
  dc:	4b4080e7          	jalr	1204(ra) # 58c <release_mutex>
  for(int i = 0; i < NITER; i++){
  e0:	34fd                	addiw	s1,s1,-1
  e2:	fce1                	bnez	s1,ba <inc+0x12>
  }
}
  e4:	60e2                	ld	ra,24(sp)
  e6:	6442                	ld	s0,16(sp)
  e8:	64a2                	ld	s1,8(sp)
  ea:	6902                	ld	s2,0(sp)
  ec:	6105                	addi	sp,sp,32
  ee:	8082                	ret

00000000000000f0 <dec>:

void dec(int mut){
  f0:	1101                	addi	sp,sp,-32
  f2:	ec06                	sd	ra,24(sp)
  f4:	e822                	sd	s0,16(sp)
  f6:	e426                	sd	s1,8(sp)
  f8:	e04a                	sd	s2,0(sp)
  fa:	1000                	addi	s0,sp,32
  fc:	892a                	mv	s2,a0
  fe:	06400493          	li	s1,100
  for(int i = 0; i < NITER; i++){
    acquire_mutex(mut);
 102:	854a                	mv	a0,s2
 104:	00000097          	auipc	ra,0x0
 108:	480080e7          	jalr	1152(ra) # 584 <acquire_mutex>
    int val = freadint();
 10c:	00000097          	auipc	ra,0x0
 110:	ef4080e7          	jalr	-268(ra) # 0 <freadint>
    fwriteint(val-1);
 114:	357d                	addiw	a0,a0,-1
 116:	00000097          	auipc	ra,0x0
 11a:	f46080e7          	jalr	-186(ra) # 5c <fwriteint>
    release_mutex(mut);
 11e:	854a                	mv	a0,s2
 120:	00000097          	auipc	ra,0x0
 124:	46c080e7          	jalr	1132(ra) # 58c <release_mutex>
  for(int i = 0; i < NITER; i++){
 128:	34fd                	addiw	s1,s1,-1
 12a:	fce1                	bnez	s1,102 <dec+0x12>
  }
}
 12c:	60e2                	ld	ra,24(sp)
 12e:	6442                	ld	s0,16(sp)
 130:	64a2                	ld	s1,8(sp)
 132:	6902                	ld	s2,0(sp)
 134:	6105                	addi	sp,sp,32
 136:	8082                	ret

0000000000000138 <main>:


int main(){
 138:	1101                	addi	sp,sp,-32
 13a:	ec06                	sd	ra,24(sp)
 13c:	e822                	sd	s0,16(sp)
 13e:	e426                	sd	s1,8(sp)
 140:	1000                	addi	s0,sp,32
  fwriteint(100);
 142:	06400513          	li	a0,100
 146:	00000097          	auipc	ra,0x0
 14a:	f16080e7          	jalr	-234(ra) # 5c <fwriteint>
  int mut = create_mutex();
 14e:	00000097          	auipc	ra,0x0
 152:	42e080e7          	jalr	1070(ra) # 57c <create_mutex>
 156:	84aa                	mv	s1,a0
  int pid = fork();
 158:	00000097          	auipc	ra,0x0
 15c:	36c080e7          	jalr	876(ra) # 4c4 <fork>
  if(pid < 0){
 160:	00054d63          	bltz	a0,17a <main+0x42>
    printf("error fork\n");
    exit(1);
  } else if (pid == 0){
 164:	e905                	bnez	a0,194 <main+0x5c>
    inc(mut);
 166:	8526                	mv	a0,s1
 168:	00000097          	auipc	ra,0x0
 16c:	f40080e7          	jalr	-192(ra) # a8 <inc>
    exit(0);
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	35a080e7          	jalr	858(ra) # 4cc <exit>
    printf("error fork\n");
 17a:	00001517          	auipc	a0,0x1
 17e:	99650513          	addi	a0,a0,-1642 # b10 <malloc+0xf2>
 182:	00000097          	auipc	ra,0x0
 186:	7de080e7          	jalr	2014(ra) # 960 <printf>
    exit(1);
 18a:	4505                	li	a0,1
 18c:	00000097          	auipc	ra,0x0
 190:	340080e7          	jalr	832(ra) # 4cc <exit>
  } else {
    pid = fork();
 194:	00000097          	auipc	ra,0x0
 198:	330080e7          	jalr	816(ra) # 4c4 <fork>
    if(pid < 0){
 19c:	00054d63          	bltz	a0,1b6 <main+0x7e>
      printf("error fork\n");
      exit(1);
    } else if (pid == 0){
 1a0:	e905                	bnez	a0,1d0 <main+0x98>
      dec(mut);
 1a2:	8526                	mv	a0,s1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	f4c080e7          	jalr	-180(ra) # f0 <dec>
      exit(0);
 1ac:	4501                	li	a0,0
 1ae:	00000097          	auipc	ra,0x0
 1b2:	31e080e7          	jalr	798(ra) # 4cc <exit>
      printf("error fork\n");
 1b6:	00001517          	auipc	a0,0x1
 1ba:	95a50513          	addi	a0,a0,-1702 # b10 <malloc+0xf2>
 1be:	00000097          	auipc	ra,0x0
 1c2:	7a2080e7          	jalr	1954(ra) # 960 <printf>
      exit(1);
 1c6:	4505                	li	a0,1
 1c8:	00000097          	auipc	ra,0x0
 1cc:	304080e7          	jalr	772(ra) # 4cc <exit>
    }
    wait(0);
 1d0:	4501                	li	a0,0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	302080e7          	jalr	770(ra) # 4d4 <wait>
    wait(0);
 1da:	4501                	li	a0,0
 1dc:	00000097          	auipc	ra,0x0
 1e0:	2f8080e7          	jalr	760(ra) # 4d4 <wait>
    printf("Result = %d\n", freadint());
 1e4:	00000097          	auipc	ra,0x0
 1e8:	e1c080e7          	jalr	-484(ra) # 0 <freadint>
 1ec:	85aa                	mv	a1,a0
 1ee:	00001517          	auipc	a0,0x1
 1f2:	93250513          	addi	a0,a0,-1742 # b20 <malloc+0x102>
 1f6:	00000097          	auipc	ra,0x0
 1fa:	76a080e7          	jalr	1898(ra) # 960 <printf>
    exit(0);
 1fe:	4501                	li	a0,0
 200:	00000097          	auipc	ra,0x0
 204:	2cc080e7          	jalr	716(ra) # 4cc <exit>

0000000000000208 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 20e:	87aa                	mv	a5,a0
 210:	0585                	addi	a1,a1,1
 212:	0785                	addi	a5,a5,1
 214:	fff5c703          	lbu	a4,-1(a1)
 218:	fee78fa3          	sb	a4,-1(a5)
 21c:	fb75                	bnez	a4,210 <strcpy+0x8>
    ;
  return os;
}
 21e:	6422                	ld	s0,8(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret

0000000000000224 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 224:	1141                	addi	sp,sp,-16
 226:	e422                	sd	s0,8(sp)
 228:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 22a:	00054783          	lbu	a5,0(a0)
 22e:	cb91                	beqz	a5,242 <strcmp+0x1e>
 230:	0005c703          	lbu	a4,0(a1)
 234:	00f71763          	bne	a4,a5,242 <strcmp+0x1e>
    p++, q++;
 238:	0505                	addi	a0,a0,1
 23a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 23c:	00054783          	lbu	a5,0(a0)
 240:	fbe5                	bnez	a5,230 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 242:	0005c503          	lbu	a0,0(a1)
}
 246:	40a7853b          	subw	a0,a5,a0
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret

0000000000000250 <strlen>:

uint
strlen(const char *s)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 256:	00054783          	lbu	a5,0(a0)
 25a:	cf91                	beqz	a5,276 <strlen+0x26>
 25c:	0505                	addi	a0,a0,1
 25e:	87aa                	mv	a5,a0
 260:	4685                	li	a3,1
 262:	9e89                	subw	a3,a3,a0
 264:	00f6853b          	addw	a0,a3,a5
 268:	0785                	addi	a5,a5,1
 26a:	fff7c703          	lbu	a4,-1(a5)
 26e:	fb7d                	bnez	a4,264 <strlen+0x14>
    ;
  return n;
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret
  for(n = 0; s[n]; n++)
 276:	4501                	li	a0,0
 278:	bfe5                	j	270 <strlen+0x20>

000000000000027a <memset>:

void*
memset(void *dst, int c, uint n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 280:	ce09                	beqz	a2,29a <memset+0x20>
 282:	87aa                	mv	a5,a0
 284:	fff6071b          	addiw	a4,a2,-1
 288:	1702                	slli	a4,a4,0x20
 28a:	9301                	srli	a4,a4,0x20
 28c:	0705                	addi	a4,a4,1
 28e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 290:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 294:	0785                	addi	a5,a5,1
 296:	fee79de3          	bne	a5,a4,290 <memset+0x16>
  }
  return dst;
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret

00000000000002a0 <strchr>:

char*
strchr(const char *s, char c)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	cb99                	beqz	a5,2c0 <strchr+0x20>
    if(*s == c)
 2ac:	00f58763          	beq	a1,a5,2ba <strchr+0x1a>
  for(; *s; s++)
 2b0:	0505                	addi	a0,a0,1
 2b2:	00054783          	lbu	a5,0(a0)
 2b6:	fbfd                	bnez	a5,2ac <strchr+0xc>
      return (char*)s;
  return 0;
 2b8:	4501                	li	a0,0
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
  return 0;
 2c0:	4501                	li	a0,0
 2c2:	bfe5                	j	2ba <strchr+0x1a>

00000000000002c4 <gets>:

char*
gets(char *buf, int max)
{
 2c4:	711d                	addi	sp,sp,-96
 2c6:	ec86                	sd	ra,88(sp)
 2c8:	e8a2                	sd	s0,80(sp)
 2ca:	e4a6                	sd	s1,72(sp)
 2cc:	e0ca                	sd	s2,64(sp)
 2ce:	fc4e                	sd	s3,56(sp)
 2d0:	f852                	sd	s4,48(sp)
 2d2:	f456                	sd	s5,40(sp)
 2d4:	f05a                	sd	s6,32(sp)
 2d6:	ec5e                	sd	s7,24(sp)
 2d8:	1080                	addi	s0,sp,96
 2da:	8baa                	mv	s7,a0
 2dc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2de:	892a                	mv	s2,a0
 2e0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2e2:	4aa9                	li	s5,10
 2e4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2e6:	89a6                	mv	s3,s1
 2e8:	2485                	addiw	s1,s1,1
 2ea:	0344d863          	bge	s1,s4,31a <gets+0x56>
    cc = read(0, &c, 1);
 2ee:	4605                	li	a2,1
 2f0:	faf40593          	addi	a1,s0,-81
 2f4:	4501                	li	a0,0
 2f6:	00000097          	auipc	ra,0x0
 2fa:	1ee080e7          	jalr	494(ra) # 4e4 <read>
    if(cc < 1)
 2fe:	00a05e63          	blez	a0,31a <gets+0x56>
    buf[i++] = c;
 302:	faf44783          	lbu	a5,-81(s0)
 306:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 30a:	01578763          	beq	a5,s5,318 <gets+0x54>
 30e:	0905                	addi	s2,s2,1
 310:	fd679be3          	bne	a5,s6,2e6 <gets+0x22>
  for(i=0; i+1 < max; ){
 314:	89a6                	mv	s3,s1
 316:	a011                	j	31a <gets+0x56>
 318:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 31a:	99de                	add	s3,s3,s7
 31c:	00098023          	sb	zero,0(s3)
  return buf;
}
 320:	855e                	mv	a0,s7
 322:	60e6                	ld	ra,88(sp)
 324:	6446                	ld	s0,80(sp)
 326:	64a6                	ld	s1,72(sp)
 328:	6906                	ld	s2,64(sp)
 32a:	79e2                	ld	s3,56(sp)
 32c:	7a42                	ld	s4,48(sp)
 32e:	7aa2                	ld	s5,40(sp)
 330:	7b02                	ld	s6,32(sp)
 332:	6be2                	ld	s7,24(sp)
 334:	6125                	addi	sp,sp,96
 336:	8082                	ret

0000000000000338 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 33e:	00054603          	lbu	a2,0(a0)
 342:	fd06079b          	addiw	a5,a2,-48
 346:	0ff7f793          	andi	a5,a5,255
 34a:	4725                	li	a4,9
 34c:	02f76963          	bltu	a4,a5,37e <atoi+0x46>
 350:	86aa                	mv	a3,a0
  n = 0;
 352:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 354:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 356:	0685                	addi	a3,a3,1
 358:	0025179b          	slliw	a5,a0,0x2
 35c:	9fa9                	addw	a5,a5,a0
 35e:	0017979b          	slliw	a5,a5,0x1
 362:	9fb1                	addw	a5,a5,a2
 364:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 368:	0006c603          	lbu	a2,0(a3)
 36c:	fd06071b          	addiw	a4,a2,-48
 370:	0ff77713          	andi	a4,a4,255
 374:	fee5f1e3          	bgeu	a1,a4,356 <atoi+0x1e>
  return n;
}
 378:	6422                	ld	s0,8(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret
  n = 0;
 37e:	4501                	li	a0,0
 380:	bfe5                	j	378 <atoi+0x40>

0000000000000382 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 382:	1141                	addi	sp,sp,-16
 384:	e422                	sd	s0,8(sp)
 386:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 388:	02b57663          	bgeu	a0,a1,3b4 <memmove+0x32>
    while(n-- > 0)
 38c:	02c05163          	blez	a2,3ae <memmove+0x2c>
 390:	fff6079b          	addiw	a5,a2,-1
 394:	1782                	slli	a5,a5,0x20
 396:	9381                	srli	a5,a5,0x20
 398:	0785                	addi	a5,a5,1
 39a:	97aa                	add	a5,a5,a0
  dst = vdst;
 39c:	872a                	mv	a4,a0
      *dst++ = *src++;
 39e:	0585                	addi	a1,a1,1
 3a0:	0705                	addi	a4,a4,1
 3a2:	fff5c683          	lbu	a3,-1(a1)
 3a6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3aa:	fee79ae3          	bne	a5,a4,39e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ae:	6422                	ld	s0,8(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret
    dst += n;
 3b4:	00c50733          	add	a4,a0,a2
    src += n;
 3b8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ba:	fec05ae3          	blez	a2,3ae <memmove+0x2c>
 3be:	fff6079b          	addiw	a5,a2,-1
 3c2:	1782                	slli	a5,a5,0x20
 3c4:	9381                	srli	a5,a5,0x20
 3c6:	fff7c793          	not	a5,a5
 3ca:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3cc:	15fd                	addi	a1,a1,-1
 3ce:	177d                	addi	a4,a4,-1
 3d0:	0005c683          	lbu	a3,0(a1)
 3d4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d8:	fee79ae3          	bne	a5,a4,3cc <memmove+0x4a>
 3dc:	bfc9                	j	3ae <memmove+0x2c>

00000000000003de <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3e4:	ca05                	beqz	a2,414 <memcmp+0x36>
 3e6:	fff6069b          	addiw	a3,a2,-1
 3ea:	1682                	slli	a3,a3,0x20
 3ec:	9281                	srli	a3,a3,0x20
 3ee:	0685                	addi	a3,a3,1
 3f0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3f2:	00054783          	lbu	a5,0(a0)
 3f6:	0005c703          	lbu	a4,0(a1)
 3fa:	00e79863          	bne	a5,a4,40a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3fe:	0505                	addi	a0,a0,1
    p2++;
 400:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 402:	fed518e3          	bne	a0,a3,3f2 <memcmp+0x14>
  }
  return 0;
 406:	4501                	li	a0,0
 408:	a019                	j	40e <memcmp+0x30>
      return *p1 - *p2;
 40a:	40e7853b          	subw	a0,a5,a4
}
 40e:	6422                	ld	s0,8(sp)
 410:	0141                	addi	sp,sp,16
 412:	8082                	ret
  return 0;
 414:	4501                	li	a0,0
 416:	bfe5                	j	40e <memcmp+0x30>

0000000000000418 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 418:	1141                	addi	sp,sp,-16
 41a:	e406                	sd	ra,8(sp)
 41c:	e022                	sd	s0,0(sp)
 41e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 420:	00000097          	auipc	ra,0x0
 424:	f62080e7          	jalr	-158(ra) # 382 <memmove>
}
 428:	60a2                	ld	ra,8(sp)
 42a:	6402                	ld	s0,0(sp)
 42c:	0141                	addi	sp,sp,16
 42e:	8082                	ret

0000000000000430 <close>:

int close(int fd){
 430:	1101                	addi	sp,sp,-32
 432:	ec06                	sd	ra,24(sp)
 434:	e822                	sd	s0,16(sp)
 436:	e426                	sd	s1,8(sp)
 438:	1000                	addi	s0,sp,32
 43a:	84aa                	mv	s1,a0
  fflush(fd);
 43c:	00000097          	auipc	ra,0x0
 440:	2d4080e7          	jalr	724(ra) # 710 <fflush>
  char* buf = get_putc_buf(fd);
 444:	8526                	mv	a0,s1
 446:	00000097          	auipc	ra,0x0
 44a:	14e080e7          	jalr	334(ra) # 594 <get_putc_buf>
  if(buf){
 44e:	cd11                	beqz	a0,46a <close+0x3a>
    free(buf);
 450:	00000097          	auipc	ra,0x0
 454:	546080e7          	jalr	1350(ra) # 996 <free>
    putc_buf[fd] = 0;
 458:	00349713          	slli	a4,s1,0x3
 45c:	00000797          	auipc	a5,0x0
 460:	70c78793          	addi	a5,a5,1804 # b68 <putc_buf>
 464:	97ba                	add	a5,a5,a4
 466:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 46a:	8526                	mv	a0,s1
 46c:	00000097          	auipc	ra,0x0
 470:	088080e7          	jalr	136(ra) # 4f4 <sclose>
}
 474:	60e2                	ld	ra,24(sp)
 476:	6442                	ld	s0,16(sp)
 478:	64a2                	ld	s1,8(sp)
 47a:	6105                	addi	sp,sp,32
 47c:	8082                	ret

000000000000047e <stat>:
{
 47e:	1101                	addi	sp,sp,-32
 480:	ec06                	sd	ra,24(sp)
 482:	e822                	sd	s0,16(sp)
 484:	e426                	sd	s1,8(sp)
 486:	e04a                	sd	s2,0(sp)
 488:	1000                	addi	s0,sp,32
 48a:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 48c:	4581                	li	a1,0
 48e:	00000097          	auipc	ra,0x0
 492:	07e080e7          	jalr	126(ra) # 50c <open>
  if(fd < 0)
 496:	02054563          	bltz	a0,4c0 <stat+0x42>
 49a:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 49c:	85ca                	mv	a1,s2
 49e:	00000097          	auipc	ra,0x0
 4a2:	086080e7          	jalr	134(ra) # 524 <fstat>
 4a6:	892a                	mv	s2,a0
  close(fd);
 4a8:	8526                	mv	a0,s1
 4aa:	00000097          	auipc	ra,0x0
 4ae:	f86080e7          	jalr	-122(ra) # 430 <close>
}
 4b2:	854a                	mv	a0,s2
 4b4:	60e2                	ld	ra,24(sp)
 4b6:	6442                	ld	s0,16(sp)
 4b8:	64a2                	ld	s1,8(sp)
 4ba:	6902                	ld	s2,0(sp)
 4bc:	6105                	addi	sp,sp,32
 4be:	8082                	ret
    return -1;
 4c0:	597d                	li	s2,-1
 4c2:	bfc5                	j	4b2 <stat+0x34>

00000000000004c4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4c4:	4885                	li	a7,1
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <exit>:
.global exit
exit:
 li a7, SYS_exit
 4cc:	4889                	li	a7,2
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4d4:	488d                	li	a7,3
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4dc:	4891                	li	a7,4
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <read>:
.global read
read:
 li a7, SYS_read
 4e4:	4895                	li	a7,5
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <write>:
.global write
write:
 li a7, SYS_write
 4ec:	48c1                	li	a7,16
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 4f4:	48d5                	li	a7,21
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <kill>:
.global kill
kill:
 li a7, SYS_kill
 4fc:	4899                	li	a7,6
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <exec>:
.global exec
exec:
 li a7, SYS_exec
 504:	489d                	li	a7,7
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <open>:
.global open
open:
 li a7, SYS_open
 50c:	48bd                	li	a7,15
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 514:	48c5                	li	a7,17
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 51c:	48c9                	li	a7,18
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 524:	48a1                	li	a7,8
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <link>:
.global link
link:
 li a7, SYS_link
 52c:	48cd                	li	a7,19
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 534:	48d1                	li	a7,20
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 53c:	48a5                	li	a7,9
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <dup>:
.global dup
dup:
 li a7, SYS_dup
 544:	48a9                	li	a7,10
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 54c:	48ad                	li	a7,11
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 554:	48b1                	li	a7,12
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 55c:	48b5                	li	a7,13
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 564:	48b9                	li	a7,14
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 56c:	48d9                	li	a7,22
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <nice>:
.global nice
nice:
 li a7, SYS_nice
 574:	48dd                	li	a7,23
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 57c:	48e1                	li	a7,24
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 584:	48e5                	li	a7,25
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 58c:	48e9                	li	a7,26
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 594:	1101                	addi	sp,sp,-32
 596:	ec06                	sd	ra,24(sp)
 598:	e822                	sd	s0,16(sp)
 59a:	e426                	sd	s1,8(sp)
 59c:	1000                	addi	s0,sp,32
 59e:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 5a0:	00351713          	slli	a4,a0,0x3
 5a4:	00000797          	auipc	a5,0x0
 5a8:	5c478793          	addi	a5,a5,1476 # b68 <putc_buf>
 5ac:	97ba                	add	a5,a5,a4
 5ae:	6388                	ld	a0,0(a5)
  if(buf) {
 5b0:	c511                	beqz	a0,5bc <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 5b2:	60e2                	ld	ra,24(sp)
 5b4:	6442                	ld	s0,16(sp)
 5b6:	64a2                	ld	s1,8(sp)
 5b8:	6105                	addi	sp,sp,32
 5ba:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 5bc:	6505                	lui	a0,0x1
 5be:	00000097          	auipc	ra,0x0
 5c2:	460080e7          	jalr	1120(ra) # a1e <malloc>
  putc_buf[fd] = buf;
 5c6:	00000797          	auipc	a5,0x0
 5ca:	5a278793          	addi	a5,a5,1442 # b68 <putc_buf>
 5ce:	00349713          	slli	a4,s1,0x3
 5d2:	973e                	add	a4,a4,a5
 5d4:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 5d6:	048a                	slli	s1,s1,0x2
 5d8:	94be                	add	s1,s1,a5
 5da:	3204a023          	sw	zero,800(s1)
  return buf;
 5de:	bfd1                	j	5b2 <get_putc_buf+0x1e>

00000000000005e0 <putc>:

static void
putc(int fd, char c)
{
 5e0:	1101                	addi	sp,sp,-32
 5e2:	ec06                	sd	ra,24(sp)
 5e4:	e822                	sd	s0,16(sp)
 5e6:	e426                	sd	s1,8(sp)
 5e8:	e04a                	sd	s2,0(sp)
 5ea:	1000                	addi	s0,sp,32
 5ec:	84aa                	mv	s1,a0
 5ee:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 5f0:	00000097          	auipc	ra,0x0
 5f4:	fa4080e7          	jalr	-92(ra) # 594 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 5f8:	00249793          	slli	a5,s1,0x2
 5fc:	00000717          	auipc	a4,0x0
 600:	56c70713          	addi	a4,a4,1388 # b68 <putc_buf>
 604:	973e                	add	a4,a4,a5
 606:	32072783          	lw	a5,800(a4)
 60a:	0017869b          	addiw	a3,a5,1
 60e:	32d72023          	sw	a3,800(a4)
 612:	97aa                	add	a5,a5,a0
 614:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 618:	47a9                	li	a5,10
 61a:	02f90463          	beq	s2,a5,642 <putc+0x62>
 61e:	00249713          	slli	a4,s1,0x2
 622:	00000797          	auipc	a5,0x0
 626:	54678793          	addi	a5,a5,1350 # b68 <putc_buf>
 62a:	97ba                	add	a5,a5,a4
 62c:	3207a703          	lw	a4,800(a5)
 630:	6785                	lui	a5,0x1
 632:	00f70863          	beq	a4,a5,642 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 636:	60e2                	ld	ra,24(sp)
 638:	6442                	ld	s0,16(sp)
 63a:	64a2                	ld	s1,8(sp)
 63c:	6902                	ld	s2,0(sp)
 63e:	6105                	addi	sp,sp,32
 640:	8082                	ret
    write(fd, buf, putc_index[fd]);
 642:	00249793          	slli	a5,s1,0x2
 646:	00000917          	auipc	s2,0x0
 64a:	52290913          	addi	s2,s2,1314 # b68 <putc_buf>
 64e:	993e                	add	s2,s2,a5
 650:	32092603          	lw	a2,800(s2)
 654:	85aa                	mv	a1,a0
 656:	8526                	mv	a0,s1
 658:	00000097          	auipc	ra,0x0
 65c:	e94080e7          	jalr	-364(ra) # 4ec <write>
    putc_index[fd] = 0;
 660:	32092023          	sw	zero,800(s2)
}
 664:	bfc9                	j	636 <putc+0x56>

0000000000000666 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 666:	7139                	addi	sp,sp,-64
 668:	fc06                	sd	ra,56(sp)
 66a:	f822                	sd	s0,48(sp)
 66c:	f426                	sd	s1,40(sp)
 66e:	f04a                	sd	s2,32(sp)
 670:	ec4e                	sd	s3,24(sp)
 672:	0080                	addi	s0,sp,64
 674:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 676:	c299                	beqz	a3,67c <printint+0x16>
 678:	0805c863          	bltz	a1,708 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 67c:	2581                	sext.w	a1,a1
  neg = 0;
 67e:	4881                	li	a7,0
 680:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 684:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 686:	2601                	sext.w	a2,a2
 688:	00000517          	auipc	a0,0x0
 68c:	4b050513          	addi	a0,a0,1200 # b38 <digits>
 690:	883a                	mv	a6,a4
 692:	2705                	addiw	a4,a4,1
 694:	02c5f7bb          	remuw	a5,a1,a2
 698:	1782                	slli	a5,a5,0x20
 69a:	9381                	srli	a5,a5,0x20
 69c:	97aa                	add	a5,a5,a0
 69e:	0007c783          	lbu	a5,0(a5) # 1000 <putc_index+0x178>
 6a2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6a6:	0005879b          	sext.w	a5,a1
 6aa:	02c5d5bb          	divuw	a1,a1,a2
 6ae:	0685                	addi	a3,a3,1
 6b0:	fec7f0e3          	bgeu	a5,a2,690 <printint+0x2a>
  if(neg)
 6b4:	00088b63          	beqz	a7,6ca <printint+0x64>
    buf[i++] = '-';
 6b8:	fd040793          	addi	a5,s0,-48
 6bc:	973e                	add	a4,a4,a5
 6be:	02d00793          	li	a5,45
 6c2:	fef70823          	sb	a5,-16(a4)
 6c6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6ca:	02e05863          	blez	a4,6fa <printint+0x94>
 6ce:	fc040793          	addi	a5,s0,-64
 6d2:	00e78933          	add	s2,a5,a4
 6d6:	fff78993          	addi	s3,a5,-1
 6da:	99ba                	add	s3,s3,a4
 6dc:	377d                	addiw	a4,a4,-1
 6de:	1702                	slli	a4,a4,0x20
 6e0:	9301                	srli	a4,a4,0x20
 6e2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6e6:	fff94583          	lbu	a1,-1(s2)
 6ea:	8526                	mv	a0,s1
 6ec:	00000097          	auipc	ra,0x0
 6f0:	ef4080e7          	jalr	-268(ra) # 5e0 <putc>
  while(--i >= 0)
 6f4:	197d                	addi	s2,s2,-1
 6f6:	ff3918e3          	bne	s2,s3,6e6 <printint+0x80>
}
 6fa:	70e2                	ld	ra,56(sp)
 6fc:	7442                	ld	s0,48(sp)
 6fe:	74a2                	ld	s1,40(sp)
 700:	7902                	ld	s2,32(sp)
 702:	69e2                	ld	s3,24(sp)
 704:	6121                	addi	sp,sp,64
 706:	8082                	ret
    x = -xx;
 708:	40b005bb          	negw	a1,a1
    neg = 1;
 70c:	4885                	li	a7,1
    x = -xx;
 70e:	bf8d                	j	680 <printint+0x1a>

0000000000000710 <fflush>:
void fflush(int fd){
 710:	1101                	addi	sp,sp,-32
 712:	ec06                	sd	ra,24(sp)
 714:	e822                	sd	s0,16(sp)
 716:	e426                	sd	s1,8(sp)
 718:	e04a                	sd	s2,0(sp)
 71a:	1000                	addi	s0,sp,32
 71c:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 71e:	00000097          	auipc	ra,0x0
 722:	e76080e7          	jalr	-394(ra) # 594 <get_putc_buf>
 726:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 728:	00291793          	slli	a5,s2,0x2
 72c:	00000497          	auipc	s1,0x0
 730:	43c48493          	addi	s1,s1,1084 # b68 <putc_buf>
 734:	94be                	add	s1,s1,a5
 736:	3204a603          	lw	a2,800(s1)
 73a:	854a                	mv	a0,s2
 73c:	00000097          	auipc	ra,0x0
 740:	db0080e7          	jalr	-592(ra) # 4ec <write>
  putc_index[fd] = 0;
 744:	3204a023          	sw	zero,800(s1)
}
 748:	60e2                	ld	ra,24(sp)
 74a:	6442                	ld	s0,16(sp)
 74c:	64a2                	ld	s1,8(sp)
 74e:	6902                	ld	s2,0(sp)
 750:	6105                	addi	sp,sp,32
 752:	8082                	ret

0000000000000754 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 754:	7119                	addi	sp,sp,-128
 756:	fc86                	sd	ra,120(sp)
 758:	f8a2                	sd	s0,112(sp)
 75a:	f4a6                	sd	s1,104(sp)
 75c:	f0ca                	sd	s2,96(sp)
 75e:	ecce                	sd	s3,88(sp)
 760:	e8d2                	sd	s4,80(sp)
 762:	e4d6                	sd	s5,72(sp)
 764:	e0da                	sd	s6,64(sp)
 766:	fc5e                	sd	s7,56(sp)
 768:	f862                	sd	s8,48(sp)
 76a:	f466                	sd	s9,40(sp)
 76c:	f06a                	sd	s10,32(sp)
 76e:	ec6e                	sd	s11,24(sp)
 770:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 772:	0005c903          	lbu	s2,0(a1)
 776:	18090f63          	beqz	s2,914 <vprintf+0x1c0>
 77a:	8aaa                	mv	s5,a0
 77c:	8b32                	mv	s6,a2
 77e:	00158493          	addi	s1,a1,1
  state = 0;
 782:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 784:	02500a13          	li	s4,37
      if(c == 'd'){
 788:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 78c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 790:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 794:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 798:	00000b97          	auipc	s7,0x0
 79c:	3a0b8b93          	addi	s7,s7,928 # b38 <digits>
 7a0:	a839                	j	7be <vprintf+0x6a>
        putc(fd, c);
 7a2:	85ca                	mv	a1,s2
 7a4:	8556                	mv	a0,s5
 7a6:	00000097          	auipc	ra,0x0
 7aa:	e3a080e7          	jalr	-454(ra) # 5e0 <putc>
 7ae:	a019                	j	7b4 <vprintf+0x60>
    } else if(state == '%'){
 7b0:	01498f63          	beq	s3,s4,7ce <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 7b4:	0485                	addi	s1,s1,1
 7b6:	fff4c903          	lbu	s2,-1(s1)
 7ba:	14090d63          	beqz	s2,914 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 7be:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7c2:	fe0997e3          	bnez	s3,7b0 <vprintf+0x5c>
      if(c == '%'){
 7c6:	fd479ee3          	bne	a5,s4,7a2 <vprintf+0x4e>
        state = '%';
 7ca:	89be                	mv	s3,a5
 7cc:	b7e5                	j	7b4 <vprintf+0x60>
      if(c == 'd'){
 7ce:	05878063          	beq	a5,s8,80e <vprintf+0xba>
      } else if(c == 'l') {
 7d2:	05978c63          	beq	a5,s9,82a <vprintf+0xd6>
      } else if(c == 'x') {
 7d6:	07a78863          	beq	a5,s10,846 <vprintf+0xf2>
      } else if(c == 'p') {
 7da:	09b78463          	beq	a5,s11,862 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7de:	07300713          	li	a4,115
 7e2:	0ce78663          	beq	a5,a4,8ae <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7e6:	06300713          	li	a4,99
 7ea:	0ee78e63          	beq	a5,a4,8e6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7ee:	11478863          	beq	a5,s4,8fe <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7f2:	85d2                	mv	a1,s4
 7f4:	8556                	mv	a0,s5
 7f6:	00000097          	auipc	ra,0x0
 7fa:	dea080e7          	jalr	-534(ra) # 5e0 <putc>
        putc(fd, c);
 7fe:	85ca                	mv	a1,s2
 800:	8556                	mv	a0,s5
 802:	00000097          	auipc	ra,0x0
 806:	dde080e7          	jalr	-546(ra) # 5e0 <putc>
      }
      state = 0;
 80a:	4981                	li	s3,0
 80c:	b765                	j	7b4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 80e:	008b0913          	addi	s2,s6,8
 812:	4685                	li	a3,1
 814:	4629                	li	a2,10
 816:	000b2583          	lw	a1,0(s6)
 81a:	8556                	mv	a0,s5
 81c:	00000097          	auipc	ra,0x0
 820:	e4a080e7          	jalr	-438(ra) # 666 <printint>
 824:	8b4a                	mv	s6,s2
      state = 0;
 826:	4981                	li	s3,0
 828:	b771                	j	7b4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 82a:	008b0913          	addi	s2,s6,8
 82e:	4681                	li	a3,0
 830:	4629                	li	a2,10
 832:	000b2583          	lw	a1,0(s6)
 836:	8556                	mv	a0,s5
 838:	00000097          	auipc	ra,0x0
 83c:	e2e080e7          	jalr	-466(ra) # 666 <printint>
 840:	8b4a                	mv	s6,s2
      state = 0;
 842:	4981                	li	s3,0
 844:	bf85                	j	7b4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 846:	008b0913          	addi	s2,s6,8
 84a:	4681                	li	a3,0
 84c:	4641                	li	a2,16
 84e:	000b2583          	lw	a1,0(s6)
 852:	8556                	mv	a0,s5
 854:	00000097          	auipc	ra,0x0
 858:	e12080e7          	jalr	-494(ra) # 666 <printint>
 85c:	8b4a                	mv	s6,s2
      state = 0;
 85e:	4981                	li	s3,0
 860:	bf91                	j	7b4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 862:	008b0793          	addi	a5,s6,8
 866:	f8f43423          	sd	a5,-120(s0)
 86a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 86e:	03000593          	li	a1,48
 872:	8556                	mv	a0,s5
 874:	00000097          	auipc	ra,0x0
 878:	d6c080e7          	jalr	-660(ra) # 5e0 <putc>
  putc(fd, 'x');
 87c:	85ea                	mv	a1,s10
 87e:	8556                	mv	a0,s5
 880:	00000097          	auipc	ra,0x0
 884:	d60080e7          	jalr	-672(ra) # 5e0 <putc>
 888:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 88a:	03c9d793          	srli	a5,s3,0x3c
 88e:	97de                	add	a5,a5,s7
 890:	0007c583          	lbu	a1,0(a5)
 894:	8556                	mv	a0,s5
 896:	00000097          	auipc	ra,0x0
 89a:	d4a080e7          	jalr	-694(ra) # 5e0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 89e:	0992                	slli	s3,s3,0x4
 8a0:	397d                	addiw	s2,s2,-1
 8a2:	fe0914e3          	bnez	s2,88a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 8a6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 8aa:	4981                	li	s3,0
 8ac:	b721                	j	7b4 <vprintf+0x60>
        s = va_arg(ap, char*);
 8ae:	008b0993          	addi	s3,s6,8
 8b2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 8b6:	02090163          	beqz	s2,8d8 <vprintf+0x184>
        while(*s != 0){
 8ba:	00094583          	lbu	a1,0(s2)
 8be:	c9a1                	beqz	a1,90e <vprintf+0x1ba>
          putc(fd, *s);
 8c0:	8556                	mv	a0,s5
 8c2:	00000097          	auipc	ra,0x0
 8c6:	d1e080e7          	jalr	-738(ra) # 5e0 <putc>
          s++;
 8ca:	0905                	addi	s2,s2,1
        while(*s != 0){
 8cc:	00094583          	lbu	a1,0(s2)
 8d0:	f9e5                	bnez	a1,8c0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 8d2:	8b4e                	mv	s6,s3
      state = 0;
 8d4:	4981                	li	s3,0
 8d6:	bdf9                	j	7b4 <vprintf+0x60>
          s = "(null)";
 8d8:	00000917          	auipc	s2,0x0
 8dc:	25890913          	addi	s2,s2,600 # b30 <malloc+0x112>
        while(*s != 0){
 8e0:	02800593          	li	a1,40
 8e4:	bff1                	j	8c0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8e6:	008b0913          	addi	s2,s6,8
 8ea:	000b4583          	lbu	a1,0(s6)
 8ee:	8556                	mv	a0,s5
 8f0:	00000097          	auipc	ra,0x0
 8f4:	cf0080e7          	jalr	-784(ra) # 5e0 <putc>
 8f8:	8b4a                	mv	s6,s2
      state = 0;
 8fa:	4981                	li	s3,0
 8fc:	bd65                	j	7b4 <vprintf+0x60>
        putc(fd, c);
 8fe:	85d2                	mv	a1,s4
 900:	8556                	mv	a0,s5
 902:	00000097          	auipc	ra,0x0
 906:	cde080e7          	jalr	-802(ra) # 5e0 <putc>
      state = 0;
 90a:	4981                	li	s3,0
 90c:	b565                	j	7b4 <vprintf+0x60>
        s = va_arg(ap, char*);
 90e:	8b4e                	mv	s6,s3
      state = 0;
 910:	4981                	li	s3,0
 912:	b54d                	j	7b4 <vprintf+0x60>
    }
  }
}
 914:	70e6                	ld	ra,120(sp)
 916:	7446                	ld	s0,112(sp)
 918:	74a6                	ld	s1,104(sp)
 91a:	7906                	ld	s2,96(sp)
 91c:	69e6                	ld	s3,88(sp)
 91e:	6a46                	ld	s4,80(sp)
 920:	6aa6                	ld	s5,72(sp)
 922:	6b06                	ld	s6,64(sp)
 924:	7be2                	ld	s7,56(sp)
 926:	7c42                	ld	s8,48(sp)
 928:	7ca2                	ld	s9,40(sp)
 92a:	7d02                	ld	s10,32(sp)
 92c:	6de2                	ld	s11,24(sp)
 92e:	6109                	addi	sp,sp,128
 930:	8082                	ret

0000000000000932 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 932:	715d                	addi	sp,sp,-80
 934:	ec06                	sd	ra,24(sp)
 936:	e822                	sd	s0,16(sp)
 938:	1000                	addi	s0,sp,32
 93a:	e010                	sd	a2,0(s0)
 93c:	e414                	sd	a3,8(s0)
 93e:	e818                	sd	a4,16(s0)
 940:	ec1c                	sd	a5,24(s0)
 942:	03043023          	sd	a6,32(s0)
 946:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 94a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 94e:	8622                	mv	a2,s0
 950:	00000097          	auipc	ra,0x0
 954:	e04080e7          	jalr	-508(ra) # 754 <vprintf>
}
 958:	60e2                	ld	ra,24(sp)
 95a:	6442                	ld	s0,16(sp)
 95c:	6161                	addi	sp,sp,80
 95e:	8082                	ret

0000000000000960 <printf>:

void
printf(const char *fmt, ...)
{
 960:	711d                	addi	sp,sp,-96
 962:	ec06                	sd	ra,24(sp)
 964:	e822                	sd	s0,16(sp)
 966:	1000                	addi	s0,sp,32
 968:	e40c                	sd	a1,8(s0)
 96a:	e810                	sd	a2,16(s0)
 96c:	ec14                	sd	a3,24(s0)
 96e:	f018                	sd	a4,32(s0)
 970:	f41c                	sd	a5,40(s0)
 972:	03043823          	sd	a6,48(s0)
 976:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 97a:	00840613          	addi	a2,s0,8
 97e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 982:	85aa                	mv	a1,a0
 984:	4505                	li	a0,1
 986:	00000097          	auipc	ra,0x0
 98a:	dce080e7          	jalr	-562(ra) # 754 <vprintf>
}
 98e:	60e2                	ld	ra,24(sp)
 990:	6442                	ld	s0,16(sp)
 992:	6125                	addi	sp,sp,96
 994:	8082                	ret

0000000000000996 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 996:	1141                	addi	sp,sp,-16
 998:	e422                	sd	s0,8(sp)
 99a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 99c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a0:	00000797          	auipc	a5,0x0
 9a4:	1c07b783          	ld	a5,448(a5) # b60 <freep>
 9a8:	a805                	j	9d8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9aa:	4618                	lw	a4,8(a2)
 9ac:	9db9                	addw	a1,a1,a4
 9ae:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9b2:	6398                	ld	a4,0(a5)
 9b4:	6318                	ld	a4,0(a4)
 9b6:	fee53823          	sd	a4,-16(a0)
 9ba:	a091                	j	9fe <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9bc:	ff852703          	lw	a4,-8(a0)
 9c0:	9e39                	addw	a2,a2,a4
 9c2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9c4:	ff053703          	ld	a4,-16(a0)
 9c8:	e398                	sd	a4,0(a5)
 9ca:	a099                	j	a10 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9cc:	6398                	ld	a4,0(a5)
 9ce:	00e7e463          	bltu	a5,a4,9d6 <free+0x40>
 9d2:	00e6ea63          	bltu	a3,a4,9e6 <free+0x50>
{
 9d6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d8:	fed7fae3          	bgeu	a5,a3,9cc <free+0x36>
 9dc:	6398                	ld	a4,0(a5)
 9de:	00e6e463          	bltu	a3,a4,9e6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e2:	fee7eae3          	bltu	a5,a4,9d6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9e6:	ff852583          	lw	a1,-8(a0)
 9ea:	6390                	ld	a2,0(a5)
 9ec:	02059713          	slli	a4,a1,0x20
 9f0:	9301                	srli	a4,a4,0x20
 9f2:	0712                	slli	a4,a4,0x4
 9f4:	9736                	add	a4,a4,a3
 9f6:	fae60ae3          	beq	a2,a4,9aa <free+0x14>
    bp->s.ptr = p->s.ptr;
 9fa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9fe:	4790                	lw	a2,8(a5)
 a00:	02061713          	slli	a4,a2,0x20
 a04:	9301                	srli	a4,a4,0x20
 a06:	0712                	slli	a4,a4,0x4
 a08:	973e                	add	a4,a4,a5
 a0a:	fae689e3          	beq	a3,a4,9bc <free+0x26>
  } else
    p->s.ptr = bp;
 a0e:	e394                	sd	a3,0(a5)
  freep = p;
 a10:	00000717          	auipc	a4,0x0
 a14:	14f73823          	sd	a5,336(a4) # b60 <freep>
}
 a18:	6422                	ld	s0,8(sp)
 a1a:	0141                	addi	sp,sp,16
 a1c:	8082                	ret

0000000000000a1e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a1e:	7139                	addi	sp,sp,-64
 a20:	fc06                	sd	ra,56(sp)
 a22:	f822                	sd	s0,48(sp)
 a24:	f426                	sd	s1,40(sp)
 a26:	f04a                	sd	s2,32(sp)
 a28:	ec4e                	sd	s3,24(sp)
 a2a:	e852                	sd	s4,16(sp)
 a2c:	e456                	sd	s5,8(sp)
 a2e:	e05a                	sd	s6,0(sp)
 a30:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a32:	02051493          	slli	s1,a0,0x20
 a36:	9081                	srli	s1,s1,0x20
 a38:	04bd                	addi	s1,s1,15
 a3a:	8091                	srli	s1,s1,0x4
 a3c:	0014899b          	addiw	s3,s1,1
 a40:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a42:	00000517          	auipc	a0,0x0
 a46:	11e53503          	ld	a0,286(a0) # b60 <freep>
 a4a:	c515                	beqz	a0,a76 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a4e:	4798                	lw	a4,8(a5)
 a50:	02977f63          	bgeu	a4,s1,a8e <malloc+0x70>
 a54:	8a4e                	mv	s4,s3
 a56:	0009871b          	sext.w	a4,s3
 a5a:	6685                	lui	a3,0x1
 a5c:	00d77363          	bgeu	a4,a3,a62 <malloc+0x44>
 a60:	6a05                	lui	s4,0x1
 a62:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a66:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a6a:	00000917          	auipc	s2,0x0
 a6e:	0f690913          	addi	s2,s2,246 # b60 <freep>
  if(p == (char*)-1)
 a72:	5afd                	li	s5,-1
 a74:	a88d                	j	ae6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a76:	00000797          	auipc	a5,0x0
 a7a:	5a278793          	addi	a5,a5,1442 # 1018 <base>
 a7e:	00000717          	auipc	a4,0x0
 a82:	0ef73123          	sd	a5,226(a4) # b60 <freep>
 a86:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a88:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a8c:	b7e1                	j	a54 <malloc+0x36>
      if(p->s.size == nunits)
 a8e:	02e48b63          	beq	s1,a4,ac4 <malloc+0xa6>
        p->s.size -= nunits;
 a92:	4137073b          	subw	a4,a4,s3
 a96:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a98:	1702                	slli	a4,a4,0x20
 a9a:	9301                	srli	a4,a4,0x20
 a9c:	0712                	slli	a4,a4,0x4
 a9e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 aa0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 aa4:	00000717          	auipc	a4,0x0
 aa8:	0aa73e23          	sd	a0,188(a4) # b60 <freep>
      return (void*)(p + 1);
 aac:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 ab0:	70e2                	ld	ra,56(sp)
 ab2:	7442                	ld	s0,48(sp)
 ab4:	74a2                	ld	s1,40(sp)
 ab6:	7902                	ld	s2,32(sp)
 ab8:	69e2                	ld	s3,24(sp)
 aba:	6a42                	ld	s4,16(sp)
 abc:	6aa2                	ld	s5,8(sp)
 abe:	6b02                	ld	s6,0(sp)
 ac0:	6121                	addi	sp,sp,64
 ac2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ac4:	6398                	ld	a4,0(a5)
 ac6:	e118                	sd	a4,0(a0)
 ac8:	bff1                	j	aa4 <malloc+0x86>
  hp->s.size = nu;
 aca:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ace:	0541                	addi	a0,a0,16
 ad0:	00000097          	auipc	ra,0x0
 ad4:	ec6080e7          	jalr	-314(ra) # 996 <free>
  return freep;
 ad8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 adc:	d971                	beqz	a0,ab0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ade:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ae0:	4798                	lw	a4,8(a5)
 ae2:	fa9776e3          	bgeu	a4,s1,a8e <malloc+0x70>
    if(p == freep)
 ae6:	00093703          	ld	a4,0(s2)
 aea:	853e                	mv	a0,a5
 aec:	fef719e3          	bne	a4,a5,ade <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 af0:	8552                	mv	a0,s4
 af2:	00000097          	auipc	ra,0x0
 af6:	a62080e7          	jalr	-1438(ra) # 554 <sbrk>
  if(p == (char*)-1)
 afa:	fd5518e3          	bne	a0,s5,aca <malloc+0xac>
        return 0;
 afe:	4501                	li	a0,0
 b00:	bf45                	j	ab0 <malloc+0x92>
