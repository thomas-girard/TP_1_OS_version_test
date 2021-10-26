
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <make_consoleX>:
#include "kernel/fcntl.h"


char consoleX[] = "consoleX";

char* make_consoleX(int i){
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  if(i < 1 || i > 9){
   e:	fff5071b          	addiw	a4,a0,-1
  12:	47a1                	li	a5,8
  14:	04e7e363          	bltu	a5,a4,5a <make_consoleX+0x5a>
  18:	84aa                	mv	s1,a0
    printf("Console number can not be more than 9.\n");
    exit(1);
  }
  int l = strlen(consoleX);
  1a:	00001997          	auipc	s3,0x1
  1e:	b2e98993          	addi	s3,s3,-1234 # b48 <consoleX>
  22:	854e                	mv	a0,s3
  24:	00000097          	auipc	ra,0x0
  28:	1d4080e7          	jalr	468(ra) # 1f8 <strlen>
  char* str = malloc(l+1);
  2c:	2505                	addiw	a0,a0,1
  2e:	00001097          	auipc	ra,0x1
  32:	998080e7          	jalr	-1640(ra) # 9c6 <malloc>
  36:	892a                	mv	s2,a0
  strcpy(str, consoleX);
  38:	85ce                	mv	a1,s3
  3a:	00000097          	auipc	ra,0x0
  3e:	176080e7          	jalr	374(ra) # 1b0 <strcpy>
  str[7] = '0' + i;
  42:	0304849b          	addiw	s1,s1,48
  46:	009903a3          	sb	s1,7(s2)
  return str;
}
  4a:	854a                	mv	a0,s2
  4c:	70a2                	ld	ra,40(sp)
  4e:	7402                	ld	s0,32(sp)
  50:	64e2                	ld	s1,24(sp)
  52:	6942                	ld	s2,16(sp)
  54:	69a2                	ld	s3,8(sp)
  56:	6145                	addi	sp,sp,48
  58:	8082                	ret
    printf("Console number can not be more than 9.\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	a5650513          	addi	a0,a0,-1450 # ab0 <malloc+0xea>
  62:	00001097          	auipc	ra,0x1
  66:	8a6080e7          	jalr	-1882(ra) # 908 <printf>
    exit(1);
  6a:	4505                	li	a0,1
  6c:	00000097          	auipc	ra,0x0
  70:	408080e7          	jalr	1032(ra) # 474 <exit>

0000000000000074 <shloop>:


char *argv[] = { "sh", 0, 0 };

void shloop(int cur_console){
  74:	7179                	addi	sp,sp,-48
  76:	f406                	sd	ra,40(sp)
  78:	f022                	sd	s0,32(sp)
  7a:	ec26                	sd	s1,24(sp)
  7c:	e84a                	sd	s2,16(sp)
  7e:	e44e                	sd	s3,8(sp)
  80:	1800                	addi	s0,sp,48
  82:	84aa                	mv	s1,a0

  char* cons = make_consoleX(cur_console);
  84:	00000097          	auipc	ra,0x0
  88:	f7c080e7          	jalr	-132(ra) # 0 <make_consoleX>
  8c:	89aa                	mv	s3,a0
  int fd;
  if((fd = open(cons, O_RDWR)) < 0){
  8e:	4589                	li	a1,2
  90:	00000097          	auipc	ra,0x0
  94:	424080e7          	jalr	1060(ra) # 4b4 <open>
  98:	04054763          	bltz	a0,e6 <shloop+0x72>
    mknod(cons, 1, cur_console);
    fd = open(cons, O_RDWR);
  }
  dup(0);  // stdout
  9c:	4501                	li	a0,0
  9e:	00000097          	auipc	ra,0x0
  a2:	44e080e7          	jalr	1102(ra) # 4ec <dup>
  dup(0);  // stderr
  a6:	4501                	li	a0,0
  a8:	00000097          	auipc	ra,0x0
  ac:	444080e7          	jalr	1092(ra) # 4ec <dup>
  int pid, wpid;

  for(;;){
    printf("init: starting sh\n");
  b0:	00001917          	auipc	s2,0x1
  b4:	a2890913          	addi	s2,s2,-1496 # ad8 <malloc+0x112>
  b8:	854a                	mv	a0,s2
  ba:	00001097          	auipc	ra,0x1
  be:	84e080e7          	jalr	-1970(ra) # 908 <printf>
    pid = fork();
  c2:	00000097          	auipc	ra,0x0
  c6:	3aa080e7          	jalr	938(ra) # 46c <fork>
  ca:	84aa                	mv	s1,a0
    if(pid < 0){
  cc:	02054e63          	bltz	a0,108 <shloop+0x94>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  d0:	c929                	beqz	a0,122 <shloop+0xae>
      argv[1] = cons;
      exec("sh", argv);
      printf("init: exec sh failed\n");
      exit(1);
    }
    while((wpid=wait(0)) >= 0 && wpid != pid){
  d2:	4501                	li	a0,0
  d4:	00000097          	auipc	ra,0x0
  d8:	3a8080e7          	jalr	936(ra) # 47c <wait>
  dc:	fc054ee3          	bltz	a0,b8 <shloop+0x44>
  e0:	fea499e3          	bne	s1,a0,d2 <shloop+0x5e>
  e4:	bfd1                	j	b8 <shloop+0x44>
    mknod(cons, 1, cur_console);
  e6:	0104961b          	slliw	a2,s1,0x10
  ea:	4106561b          	sraiw	a2,a2,0x10
  ee:	4585                	li	a1,1
  f0:	854e                	mv	a0,s3
  f2:	00000097          	auipc	ra,0x0
  f6:	3ca080e7          	jalr	970(ra) # 4bc <mknod>
    fd = open(cons, O_RDWR);
  fa:	4589                	li	a1,2
  fc:	854e                	mv	a0,s3
  fe:	00000097          	auipc	ra,0x0
 102:	3b6080e7          	jalr	950(ra) # 4b4 <open>
 106:	bf59                	j	9c <shloop+0x28>
      printf("init: fork failed\n");
 108:	00001517          	auipc	a0,0x1
 10c:	9e850513          	addi	a0,a0,-1560 # af0 <malloc+0x12a>
 110:	00000097          	auipc	ra,0x0
 114:	7f8080e7          	jalr	2040(ra) # 908 <printf>
      exit(1);
 118:	4505                	li	a0,1
 11a:	00000097          	auipc	ra,0x0
 11e:	35a080e7          	jalr	858(ra) # 474 <exit>
      argv[1] = cons;
 122:	00001797          	auipc	a5,0x1
 126:	a337bf23          	sd	s3,-1474(a5) # b60 <argv+0x8>
      exec("sh", argv);
 12a:	00001597          	auipc	a1,0x1
 12e:	a2e58593          	addi	a1,a1,-1490 # b58 <argv>
 132:	00001517          	auipc	a0,0x1
 136:	9d650513          	addi	a0,a0,-1578 # b08 <malloc+0x142>
 13a:	00000097          	auipc	ra,0x0
 13e:	372080e7          	jalr	882(ra) # 4ac <exec>
      printf("init: exec sh failed\n");
 142:	00001517          	auipc	a0,0x1
 146:	9ce50513          	addi	a0,a0,-1586 # b10 <malloc+0x14a>
 14a:	00000097          	auipc	ra,0x0
 14e:	7be080e7          	jalr	1982(ra) # 908 <printf>
      exit(1);
 152:	4505                	li	a0,1
 154:	00000097          	auipc	ra,0x0
 158:	320080e7          	jalr	800(ra) # 474 <exit>

000000000000015c <main>:

}

int
main(void)
{
 15c:	1101                	addi	sp,sp,-32
 15e:	ec06                	sd	ra,24(sp)
 160:	e822                	sd	s0,16(sp)
 162:	e426                	sd	s1,8(sp)
 164:	e04a                	sd	s2,0(sp)
 166:	1000                	addi	s0,sp,32
  int nb_consoles = 3;

  int cur_console = 0;
  int pid;

  while(cur_console++ < nb_consoles){
 168:	4485                	li	s1,1
 16a:	4911                	li	s2,4
    pid = fork();
 16c:	00000097          	auipc	ra,0x0
 170:	300080e7          	jalr	768(ra) # 46c <fork>
    if (pid < 0){
 174:	00054c63          	bltz	a0,18c <main+0x30>
      printf("init: fork failed\n");
      exit(1);
    }
    if (pid == 0){
 178:	c51d                	beqz	a0,1a6 <main+0x4a>
  while(cur_console++ < nb_consoles){
 17a:	2485                	addiw	s1,s1,1
 17c:	ff2498e3          	bne	s1,s2,16c <main+0x10>
      shloop(cur_console);
      return 1;
    }
  }
  while(1) wait(0);
 180:	4501                	li	a0,0
 182:	00000097          	auipc	ra,0x0
 186:	2fa080e7          	jalr	762(ra) # 47c <wait>
 18a:	bfdd                	j	180 <main+0x24>
      printf("init: fork failed\n");
 18c:	00001517          	auipc	a0,0x1
 190:	96450513          	addi	a0,a0,-1692 # af0 <malloc+0x12a>
 194:	00000097          	auipc	ra,0x0
 198:	774080e7          	jalr	1908(ra) # 908 <printf>
      exit(1);
 19c:	4505                	li	a0,1
 19e:	00000097          	auipc	ra,0x0
 1a2:	2d6080e7          	jalr	726(ra) # 474 <exit>
      shloop(cur_console);
 1a6:	8526                	mv	a0,s1
 1a8:	00000097          	auipc	ra,0x0
 1ac:	ecc080e7          	jalr	-308(ra) # 74 <shloop>

00000000000001b0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1b6:	87aa                	mv	a5,a0
 1b8:	0585                	addi	a1,a1,1
 1ba:	0785                	addi	a5,a5,1
 1bc:	fff5c703          	lbu	a4,-1(a1)
 1c0:	fee78fa3          	sb	a4,-1(a5)
 1c4:	fb75                	bnez	a4,1b8 <strcpy+0x8>
    ;
  return os;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cb91                	beqz	a5,1ea <strcmp+0x1e>
 1d8:	0005c703          	lbu	a4,0(a1)
 1dc:	00f71763          	bne	a4,a5,1ea <strcmp+0x1e>
    p++, q++;
 1e0:	0505                	addi	a0,a0,1
 1e2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	fbe5                	bnez	a5,1d8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ea:	0005c503          	lbu	a0,0(a1)
}
 1ee:	40a7853b          	subw	a0,a5,a0
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret

00000000000001f8 <strlen>:

uint
strlen(const char *s)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1fe:	00054783          	lbu	a5,0(a0)
 202:	cf91                	beqz	a5,21e <strlen+0x26>
 204:	0505                	addi	a0,a0,1
 206:	87aa                	mv	a5,a0
 208:	4685                	li	a3,1
 20a:	9e89                	subw	a3,a3,a0
 20c:	00f6853b          	addw	a0,a3,a5
 210:	0785                	addi	a5,a5,1
 212:	fff7c703          	lbu	a4,-1(a5)
 216:	fb7d                	bnez	a4,20c <strlen+0x14>
    ;
  return n;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret
  for(n = 0; s[n]; n++)
 21e:	4501                	li	a0,0
 220:	bfe5                	j	218 <strlen+0x20>

0000000000000222 <memset>:

void*
memset(void *dst, int c, uint n)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 228:	ce09                	beqz	a2,242 <memset+0x20>
 22a:	87aa                	mv	a5,a0
 22c:	fff6071b          	addiw	a4,a2,-1
 230:	1702                	slli	a4,a4,0x20
 232:	9301                	srli	a4,a4,0x20
 234:	0705                	addi	a4,a4,1
 236:	972a                	add	a4,a4,a0
    cdst[i] = c;
 238:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 23c:	0785                	addi	a5,a5,1
 23e:	fee79de3          	bne	a5,a4,238 <memset+0x16>
  }
  return dst;
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret

0000000000000248 <strchr>:

char*
strchr(const char *s, char c)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 24e:	00054783          	lbu	a5,0(a0)
 252:	cb99                	beqz	a5,268 <strchr+0x20>
    if(*s == c)
 254:	00f58763          	beq	a1,a5,262 <strchr+0x1a>
  for(; *s; s++)
 258:	0505                	addi	a0,a0,1
 25a:	00054783          	lbu	a5,0(a0)
 25e:	fbfd                	bnez	a5,254 <strchr+0xc>
      return (char*)s;
  return 0;
 260:	4501                	li	a0,0
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  return 0;
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <strchr+0x1a>

000000000000026c <gets>:

char*
gets(char *buf, int max)
{
 26c:	711d                	addi	sp,sp,-96
 26e:	ec86                	sd	ra,88(sp)
 270:	e8a2                	sd	s0,80(sp)
 272:	e4a6                	sd	s1,72(sp)
 274:	e0ca                	sd	s2,64(sp)
 276:	fc4e                	sd	s3,56(sp)
 278:	f852                	sd	s4,48(sp)
 27a:	f456                	sd	s5,40(sp)
 27c:	f05a                	sd	s6,32(sp)
 27e:	ec5e                	sd	s7,24(sp)
 280:	1080                	addi	s0,sp,96
 282:	8baa                	mv	s7,a0
 284:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 286:	892a                	mv	s2,a0
 288:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 28a:	4aa9                	li	s5,10
 28c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 28e:	89a6                	mv	s3,s1
 290:	2485                	addiw	s1,s1,1
 292:	0344d863          	bge	s1,s4,2c2 <gets+0x56>
    cc = read(0, &c, 1);
 296:	4605                	li	a2,1
 298:	faf40593          	addi	a1,s0,-81
 29c:	4501                	li	a0,0
 29e:	00000097          	auipc	ra,0x0
 2a2:	1ee080e7          	jalr	494(ra) # 48c <read>
    if(cc < 1)
 2a6:	00a05e63          	blez	a0,2c2 <gets+0x56>
    buf[i++] = c;
 2aa:	faf44783          	lbu	a5,-81(s0)
 2ae:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2b2:	01578763          	beq	a5,s5,2c0 <gets+0x54>
 2b6:	0905                	addi	s2,s2,1
 2b8:	fd679be3          	bne	a5,s6,28e <gets+0x22>
  for(i=0; i+1 < max; ){
 2bc:	89a6                	mv	s3,s1
 2be:	a011                	j	2c2 <gets+0x56>
 2c0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2c2:	99de                	add	s3,s3,s7
 2c4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2c8:	855e                	mv	a0,s7
 2ca:	60e6                	ld	ra,88(sp)
 2cc:	6446                	ld	s0,80(sp)
 2ce:	64a6                	ld	s1,72(sp)
 2d0:	6906                	ld	s2,64(sp)
 2d2:	79e2                	ld	s3,56(sp)
 2d4:	7a42                	ld	s4,48(sp)
 2d6:	7aa2                	ld	s5,40(sp)
 2d8:	7b02                	ld	s6,32(sp)
 2da:	6be2                	ld	s7,24(sp)
 2dc:	6125                	addi	sp,sp,96
 2de:	8082                	ret

00000000000002e0 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e6:	00054603          	lbu	a2,0(a0)
 2ea:	fd06079b          	addiw	a5,a2,-48
 2ee:	0ff7f793          	andi	a5,a5,255
 2f2:	4725                	li	a4,9
 2f4:	02f76963          	bltu	a4,a5,326 <atoi+0x46>
 2f8:	86aa                	mv	a3,a0
  n = 0;
 2fa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2fc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2fe:	0685                	addi	a3,a3,1
 300:	0025179b          	slliw	a5,a0,0x2
 304:	9fa9                	addw	a5,a5,a0
 306:	0017979b          	slliw	a5,a5,0x1
 30a:	9fb1                	addw	a5,a5,a2
 30c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 310:	0006c603          	lbu	a2,0(a3)
 314:	fd06071b          	addiw	a4,a2,-48
 318:	0ff77713          	andi	a4,a4,255
 31c:	fee5f1e3          	bgeu	a1,a4,2fe <atoi+0x1e>
  return n;
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  n = 0;
 326:	4501                	li	a0,0
 328:	bfe5                	j	320 <atoi+0x40>

000000000000032a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 330:	02b57663          	bgeu	a0,a1,35c <memmove+0x32>
    while(n-- > 0)
 334:	02c05163          	blez	a2,356 <memmove+0x2c>
 338:	fff6079b          	addiw	a5,a2,-1
 33c:	1782                	slli	a5,a5,0x20
 33e:	9381                	srli	a5,a5,0x20
 340:	0785                	addi	a5,a5,1
 342:	97aa                	add	a5,a5,a0
  dst = vdst;
 344:	872a                	mv	a4,a0
      *dst++ = *src++;
 346:	0585                	addi	a1,a1,1
 348:	0705                	addi	a4,a4,1
 34a:	fff5c683          	lbu	a3,-1(a1)
 34e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 352:	fee79ae3          	bne	a5,a4,346 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret
    dst += n;
 35c:	00c50733          	add	a4,a0,a2
    src += n;
 360:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 362:	fec05ae3          	blez	a2,356 <memmove+0x2c>
 366:	fff6079b          	addiw	a5,a2,-1
 36a:	1782                	slli	a5,a5,0x20
 36c:	9381                	srli	a5,a5,0x20
 36e:	fff7c793          	not	a5,a5
 372:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 374:	15fd                	addi	a1,a1,-1
 376:	177d                	addi	a4,a4,-1
 378:	0005c683          	lbu	a3,0(a1)
 37c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 380:	fee79ae3          	bne	a5,a4,374 <memmove+0x4a>
 384:	bfc9                	j	356 <memmove+0x2c>

0000000000000386 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e422                	sd	s0,8(sp)
 38a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38c:	ca05                	beqz	a2,3bc <memcmp+0x36>
 38e:	fff6069b          	addiw	a3,a2,-1
 392:	1682                	slli	a3,a3,0x20
 394:	9281                	srli	a3,a3,0x20
 396:	0685                	addi	a3,a3,1
 398:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 39a:	00054783          	lbu	a5,0(a0)
 39e:	0005c703          	lbu	a4,0(a1)
 3a2:	00e79863          	bne	a5,a4,3b2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a6:	0505                	addi	a0,a0,1
    p2++;
 3a8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3aa:	fed518e3          	bne	a0,a3,39a <memcmp+0x14>
  }
  return 0;
 3ae:	4501                	li	a0,0
 3b0:	a019                	j	3b6 <memcmp+0x30>
      return *p1 - *p2;
 3b2:	40e7853b          	subw	a0,a5,a4
}
 3b6:	6422                	ld	s0,8(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
  return 0;
 3bc:	4501                	li	a0,0
 3be:	bfe5                	j	3b6 <memcmp+0x30>

00000000000003c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c8:	00000097          	auipc	ra,0x0
 3cc:	f62080e7          	jalr	-158(ra) # 32a <memmove>
}
 3d0:	60a2                	ld	ra,8(sp)
 3d2:	6402                	ld	s0,0(sp)
 3d4:	0141                	addi	sp,sp,16
 3d6:	8082                	ret

00000000000003d8 <close>:

int close(int fd){
 3d8:	1101                	addi	sp,sp,-32
 3da:	ec06                	sd	ra,24(sp)
 3dc:	e822                	sd	s0,16(sp)
 3de:	e426                	sd	s1,8(sp)
 3e0:	1000                	addi	s0,sp,32
 3e2:	84aa                	mv	s1,a0
  fflush(fd);
 3e4:	00000097          	auipc	ra,0x0
 3e8:	2d4080e7          	jalr	724(ra) # 6b8 <fflush>
  char* buf = get_putc_buf(fd);
 3ec:	8526                	mv	a0,s1
 3ee:	00000097          	auipc	ra,0x0
 3f2:	14e080e7          	jalr	334(ra) # 53c <get_putc_buf>
  if(buf){
 3f6:	cd11                	beqz	a0,412 <close+0x3a>
    free(buf);
 3f8:	00000097          	auipc	ra,0x0
 3fc:	546080e7          	jalr	1350(ra) # 93e <free>
    putc_buf[fd] = 0;
 400:	00349713          	slli	a4,s1,0x3
 404:	00000797          	auipc	a5,0x0
 408:	77478793          	addi	a5,a5,1908 # b78 <putc_buf>
 40c:	97ba                	add	a5,a5,a4
 40e:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 412:	8526                	mv	a0,s1
 414:	00000097          	auipc	ra,0x0
 418:	088080e7          	jalr	136(ra) # 49c <sclose>
}
 41c:	60e2                	ld	ra,24(sp)
 41e:	6442                	ld	s0,16(sp)
 420:	64a2                	ld	s1,8(sp)
 422:	6105                	addi	sp,sp,32
 424:	8082                	ret

0000000000000426 <stat>:
{
 426:	1101                	addi	sp,sp,-32
 428:	ec06                	sd	ra,24(sp)
 42a:	e822                	sd	s0,16(sp)
 42c:	e426                	sd	s1,8(sp)
 42e:	e04a                	sd	s2,0(sp)
 430:	1000                	addi	s0,sp,32
 432:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 434:	4581                	li	a1,0
 436:	00000097          	auipc	ra,0x0
 43a:	07e080e7          	jalr	126(ra) # 4b4 <open>
  if(fd < 0)
 43e:	02054563          	bltz	a0,468 <stat+0x42>
 442:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 444:	85ca                	mv	a1,s2
 446:	00000097          	auipc	ra,0x0
 44a:	086080e7          	jalr	134(ra) # 4cc <fstat>
 44e:	892a                	mv	s2,a0
  close(fd);
 450:	8526                	mv	a0,s1
 452:	00000097          	auipc	ra,0x0
 456:	f86080e7          	jalr	-122(ra) # 3d8 <close>
}
 45a:	854a                	mv	a0,s2
 45c:	60e2                	ld	ra,24(sp)
 45e:	6442                	ld	s0,16(sp)
 460:	64a2                	ld	s1,8(sp)
 462:	6902                	ld	s2,0(sp)
 464:	6105                	addi	sp,sp,32
 466:	8082                	ret
    return -1;
 468:	597d                	li	s2,-1
 46a:	bfc5                	j	45a <stat+0x34>

000000000000046c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 46c:	4885                	li	a7,1
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <exit>:
.global exit
exit:
 li a7, SYS_exit
 474:	4889                	li	a7,2
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <wait>:
.global wait
wait:
 li a7, SYS_wait
 47c:	488d                	li	a7,3
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 484:	4891                	li	a7,4
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <read>:
.global read
read:
 li a7, SYS_read
 48c:	4895                	li	a7,5
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <write>:
.global write
write:
 li a7, SYS_write
 494:	48c1                	li	a7,16
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 49c:	48d5                	li	a7,21
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a4:	4899                	li	a7,6
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ac:	489d                	li	a7,7
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <open>:
.global open
open:
 li a7, SYS_open
 4b4:	48bd                	li	a7,15
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4bc:	48c5                	li	a7,17
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c4:	48c9                	li	a7,18
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4cc:	48a1                	li	a7,8
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <link>:
.global link
link:
 li a7, SYS_link
 4d4:	48cd                	li	a7,19
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4dc:	48d1                	li	a7,20
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e4:	48a5                	li	a7,9
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ec:	48a9                	li	a7,10
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f4:	48ad                	li	a7,11
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4fc:	48b1                	li	a7,12
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 504:	48b5                	li	a7,13
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 50c:	48b9                	li	a7,14
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 514:	48d9                	li	a7,22
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <nice>:
.global nice
nice:
 li a7, SYS_nice
 51c:	48dd                	li	a7,23
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 524:	48e1                	li	a7,24
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 52c:	48e5                	li	a7,25
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 534:	48e9                	li	a7,26
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 53c:	1101                	addi	sp,sp,-32
 53e:	ec06                	sd	ra,24(sp)
 540:	e822                	sd	s0,16(sp)
 542:	e426                	sd	s1,8(sp)
 544:	1000                	addi	s0,sp,32
 546:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 548:	00351713          	slli	a4,a0,0x3
 54c:	00000797          	auipc	a5,0x0
 550:	62c78793          	addi	a5,a5,1580 # b78 <putc_buf>
 554:	97ba                	add	a5,a5,a4
 556:	6388                	ld	a0,0(a5)
  if(buf) {
 558:	c511                	beqz	a0,564 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 55a:	60e2                	ld	ra,24(sp)
 55c:	6442                	ld	s0,16(sp)
 55e:	64a2                	ld	s1,8(sp)
 560:	6105                	addi	sp,sp,32
 562:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 564:	6505                	lui	a0,0x1
 566:	00000097          	auipc	ra,0x0
 56a:	460080e7          	jalr	1120(ra) # 9c6 <malloc>
  putc_buf[fd] = buf;
 56e:	00000797          	auipc	a5,0x0
 572:	60a78793          	addi	a5,a5,1546 # b78 <putc_buf>
 576:	00349713          	slli	a4,s1,0x3
 57a:	973e                	add	a4,a4,a5
 57c:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 57e:	048a                	slli	s1,s1,0x2
 580:	94be                	add	s1,s1,a5
 582:	3204a023          	sw	zero,800(s1)
  return buf;
 586:	bfd1                	j	55a <get_putc_buf+0x1e>

0000000000000588 <putc>:

static void
putc(int fd, char c)
{
 588:	1101                	addi	sp,sp,-32
 58a:	ec06                	sd	ra,24(sp)
 58c:	e822                	sd	s0,16(sp)
 58e:	e426                	sd	s1,8(sp)
 590:	e04a                	sd	s2,0(sp)
 592:	1000                	addi	s0,sp,32
 594:	84aa                	mv	s1,a0
 596:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 598:	00000097          	auipc	ra,0x0
 59c:	fa4080e7          	jalr	-92(ra) # 53c <get_putc_buf>
  buf[putc_index[fd]++] = c;
 5a0:	00249793          	slli	a5,s1,0x2
 5a4:	00000717          	auipc	a4,0x0
 5a8:	5d470713          	addi	a4,a4,1492 # b78 <putc_buf>
 5ac:	973e                	add	a4,a4,a5
 5ae:	32072783          	lw	a5,800(a4)
 5b2:	0017869b          	addiw	a3,a5,1
 5b6:	32d72023          	sw	a3,800(a4)
 5ba:	97aa                	add	a5,a5,a0
 5bc:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 5c0:	47a9                	li	a5,10
 5c2:	02f90463          	beq	s2,a5,5ea <putc+0x62>
 5c6:	00249713          	slli	a4,s1,0x2
 5ca:	00000797          	auipc	a5,0x0
 5ce:	5ae78793          	addi	a5,a5,1454 # b78 <putc_buf>
 5d2:	97ba                	add	a5,a5,a4
 5d4:	3207a703          	lw	a4,800(a5)
 5d8:	6785                	lui	a5,0x1
 5da:	00f70863          	beq	a4,a5,5ea <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 5de:	60e2                	ld	ra,24(sp)
 5e0:	6442                	ld	s0,16(sp)
 5e2:	64a2                	ld	s1,8(sp)
 5e4:	6902                	ld	s2,0(sp)
 5e6:	6105                	addi	sp,sp,32
 5e8:	8082                	ret
    write(fd, buf, putc_index[fd]);
 5ea:	00249793          	slli	a5,s1,0x2
 5ee:	00000917          	auipc	s2,0x0
 5f2:	58a90913          	addi	s2,s2,1418 # b78 <putc_buf>
 5f6:	993e                	add	s2,s2,a5
 5f8:	32092603          	lw	a2,800(s2)
 5fc:	85aa                	mv	a1,a0
 5fe:	8526                	mv	a0,s1
 600:	00000097          	auipc	ra,0x0
 604:	e94080e7          	jalr	-364(ra) # 494 <write>
    putc_index[fd] = 0;
 608:	32092023          	sw	zero,800(s2)
}
 60c:	bfc9                	j	5de <putc+0x56>

000000000000060e <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 60e:	7139                	addi	sp,sp,-64
 610:	fc06                	sd	ra,56(sp)
 612:	f822                	sd	s0,48(sp)
 614:	f426                	sd	s1,40(sp)
 616:	f04a                	sd	s2,32(sp)
 618:	ec4e                	sd	s3,24(sp)
 61a:	0080                	addi	s0,sp,64
 61c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 61e:	c299                	beqz	a3,624 <printint+0x16>
 620:	0805c863          	bltz	a1,6b0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 624:	2581                	sext.w	a1,a1
  neg = 0;
 626:	4881                	li	a7,0
 628:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 62c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 62e:	2601                	sext.w	a2,a2
 630:	00000517          	auipc	a0,0x0
 634:	50050513          	addi	a0,a0,1280 # b30 <digits>
 638:	883a                	mv	a6,a4
 63a:	2705                	addiw	a4,a4,1
 63c:	02c5f7bb          	remuw	a5,a1,a2
 640:	1782                	slli	a5,a5,0x20
 642:	9381                	srli	a5,a5,0x20
 644:	97aa                	add	a5,a5,a0
 646:	0007c783          	lbu	a5,0(a5) # 1000 <putc_index+0x168>
 64a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 64e:	0005879b          	sext.w	a5,a1
 652:	02c5d5bb          	divuw	a1,a1,a2
 656:	0685                	addi	a3,a3,1
 658:	fec7f0e3          	bgeu	a5,a2,638 <printint+0x2a>
  if(neg)
 65c:	00088b63          	beqz	a7,672 <printint+0x64>
    buf[i++] = '-';
 660:	fd040793          	addi	a5,s0,-48
 664:	973e                	add	a4,a4,a5
 666:	02d00793          	li	a5,45
 66a:	fef70823          	sb	a5,-16(a4)
 66e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 672:	02e05863          	blez	a4,6a2 <printint+0x94>
 676:	fc040793          	addi	a5,s0,-64
 67a:	00e78933          	add	s2,a5,a4
 67e:	fff78993          	addi	s3,a5,-1
 682:	99ba                	add	s3,s3,a4
 684:	377d                	addiw	a4,a4,-1
 686:	1702                	slli	a4,a4,0x20
 688:	9301                	srli	a4,a4,0x20
 68a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 68e:	fff94583          	lbu	a1,-1(s2)
 692:	8526                	mv	a0,s1
 694:	00000097          	auipc	ra,0x0
 698:	ef4080e7          	jalr	-268(ra) # 588 <putc>
  while(--i >= 0)
 69c:	197d                	addi	s2,s2,-1
 69e:	ff3918e3          	bne	s2,s3,68e <printint+0x80>
}
 6a2:	70e2                	ld	ra,56(sp)
 6a4:	7442                	ld	s0,48(sp)
 6a6:	74a2                	ld	s1,40(sp)
 6a8:	7902                	ld	s2,32(sp)
 6aa:	69e2                	ld	s3,24(sp)
 6ac:	6121                	addi	sp,sp,64
 6ae:	8082                	ret
    x = -xx;
 6b0:	40b005bb          	negw	a1,a1
    neg = 1;
 6b4:	4885                	li	a7,1
    x = -xx;
 6b6:	bf8d                	j	628 <printint+0x1a>

00000000000006b8 <fflush>:
void fflush(int fd){
 6b8:	1101                	addi	sp,sp,-32
 6ba:	ec06                	sd	ra,24(sp)
 6bc:	e822                	sd	s0,16(sp)
 6be:	e426                	sd	s1,8(sp)
 6c0:	e04a                	sd	s2,0(sp)
 6c2:	1000                	addi	s0,sp,32
 6c4:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 6c6:	00000097          	auipc	ra,0x0
 6ca:	e76080e7          	jalr	-394(ra) # 53c <get_putc_buf>
 6ce:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 6d0:	00291793          	slli	a5,s2,0x2
 6d4:	00000497          	auipc	s1,0x0
 6d8:	4a448493          	addi	s1,s1,1188 # b78 <putc_buf>
 6dc:	94be                	add	s1,s1,a5
 6de:	3204a603          	lw	a2,800(s1)
 6e2:	854a                	mv	a0,s2
 6e4:	00000097          	auipc	ra,0x0
 6e8:	db0080e7          	jalr	-592(ra) # 494 <write>
  putc_index[fd] = 0;
 6ec:	3204a023          	sw	zero,800(s1)
}
 6f0:	60e2                	ld	ra,24(sp)
 6f2:	6442                	ld	s0,16(sp)
 6f4:	64a2                	ld	s1,8(sp)
 6f6:	6902                	ld	s2,0(sp)
 6f8:	6105                	addi	sp,sp,32
 6fa:	8082                	ret

00000000000006fc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6fc:	7119                	addi	sp,sp,-128
 6fe:	fc86                	sd	ra,120(sp)
 700:	f8a2                	sd	s0,112(sp)
 702:	f4a6                	sd	s1,104(sp)
 704:	f0ca                	sd	s2,96(sp)
 706:	ecce                	sd	s3,88(sp)
 708:	e8d2                	sd	s4,80(sp)
 70a:	e4d6                	sd	s5,72(sp)
 70c:	e0da                	sd	s6,64(sp)
 70e:	fc5e                	sd	s7,56(sp)
 710:	f862                	sd	s8,48(sp)
 712:	f466                	sd	s9,40(sp)
 714:	f06a                	sd	s10,32(sp)
 716:	ec6e                	sd	s11,24(sp)
 718:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 71a:	0005c903          	lbu	s2,0(a1)
 71e:	18090f63          	beqz	s2,8bc <vprintf+0x1c0>
 722:	8aaa                	mv	s5,a0
 724:	8b32                	mv	s6,a2
 726:	00158493          	addi	s1,a1,1
  state = 0;
 72a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 72c:	02500a13          	li	s4,37
      if(c == 'd'){
 730:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 734:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 738:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 73c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 740:	00000b97          	auipc	s7,0x0
 744:	3f0b8b93          	addi	s7,s7,1008 # b30 <digits>
 748:	a839                	j	766 <vprintf+0x6a>
        putc(fd, c);
 74a:	85ca                	mv	a1,s2
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	e3a080e7          	jalr	-454(ra) # 588 <putc>
 756:	a019                	j	75c <vprintf+0x60>
    } else if(state == '%'){
 758:	01498f63          	beq	s3,s4,776 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 75c:	0485                	addi	s1,s1,1
 75e:	fff4c903          	lbu	s2,-1(s1)
 762:	14090d63          	beqz	s2,8bc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 766:	0009079b          	sext.w	a5,s2
    if(state == 0){
 76a:	fe0997e3          	bnez	s3,758 <vprintf+0x5c>
      if(c == '%'){
 76e:	fd479ee3          	bne	a5,s4,74a <vprintf+0x4e>
        state = '%';
 772:	89be                	mv	s3,a5
 774:	b7e5                	j	75c <vprintf+0x60>
      if(c == 'd'){
 776:	05878063          	beq	a5,s8,7b6 <vprintf+0xba>
      } else if(c == 'l') {
 77a:	05978c63          	beq	a5,s9,7d2 <vprintf+0xd6>
      } else if(c == 'x') {
 77e:	07a78863          	beq	a5,s10,7ee <vprintf+0xf2>
      } else if(c == 'p') {
 782:	09b78463          	beq	a5,s11,80a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 786:	07300713          	li	a4,115
 78a:	0ce78663          	beq	a5,a4,856 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 78e:	06300713          	li	a4,99
 792:	0ee78e63          	beq	a5,a4,88e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 796:	11478863          	beq	a5,s4,8a6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 79a:	85d2                	mv	a1,s4
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	dea080e7          	jalr	-534(ra) # 588 <putc>
        putc(fd, c);
 7a6:	85ca                	mv	a1,s2
 7a8:	8556                	mv	a0,s5
 7aa:	00000097          	auipc	ra,0x0
 7ae:	dde080e7          	jalr	-546(ra) # 588 <putc>
      }
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b765                	j	75c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7b6:	008b0913          	addi	s2,s6,8
 7ba:	4685                	li	a3,1
 7bc:	4629                	li	a2,10
 7be:	000b2583          	lw	a1,0(s6)
 7c2:	8556                	mv	a0,s5
 7c4:	00000097          	auipc	ra,0x0
 7c8:	e4a080e7          	jalr	-438(ra) # 60e <printint>
 7cc:	8b4a                	mv	s6,s2
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	b771                	j	75c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d2:	008b0913          	addi	s2,s6,8
 7d6:	4681                	li	a3,0
 7d8:	4629                	li	a2,10
 7da:	000b2583          	lw	a1,0(s6)
 7de:	8556                	mv	a0,s5
 7e0:	00000097          	auipc	ra,0x0
 7e4:	e2e080e7          	jalr	-466(ra) # 60e <printint>
 7e8:	8b4a                	mv	s6,s2
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	bf85                	j	75c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7ee:	008b0913          	addi	s2,s6,8
 7f2:	4681                	li	a3,0
 7f4:	4641                	li	a2,16
 7f6:	000b2583          	lw	a1,0(s6)
 7fa:	8556                	mv	a0,s5
 7fc:	00000097          	auipc	ra,0x0
 800:	e12080e7          	jalr	-494(ra) # 60e <printint>
 804:	8b4a                	mv	s6,s2
      state = 0;
 806:	4981                	li	s3,0
 808:	bf91                	j	75c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 80a:	008b0793          	addi	a5,s6,8
 80e:	f8f43423          	sd	a5,-120(s0)
 812:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 816:	03000593          	li	a1,48
 81a:	8556                	mv	a0,s5
 81c:	00000097          	auipc	ra,0x0
 820:	d6c080e7          	jalr	-660(ra) # 588 <putc>
  putc(fd, 'x');
 824:	85ea                	mv	a1,s10
 826:	8556                	mv	a0,s5
 828:	00000097          	auipc	ra,0x0
 82c:	d60080e7          	jalr	-672(ra) # 588 <putc>
 830:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 832:	03c9d793          	srli	a5,s3,0x3c
 836:	97de                	add	a5,a5,s7
 838:	0007c583          	lbu	a1,0(a5)
 83c:	8556                	mv	a0,s5
 83e:	00000097          	auipc	ra,0x0
 842:	d4a080e7          	jalr	-694(ra) # 588 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 846:	0992                	slli	s3,s3,0x4
 848:	397d                	addiw	s2,s2,-1
 84a:	fe0914e3          	bnez	s2,832 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 84e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 852:	4981                	li	s3,0
 854:	b721                	j	75c <vprintf+0x60>
        s = va_arg(ap, char*);
 856:	008b0993          	addi	s3,s6,8
 85a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 85e:	02090163          	beqz	s2,880 <vprintf+0x184>
        while(*s != 0){
 862:	00094583          	lbu	a1,0(s2)
 866:	c9a1                	beqz	a1,8b6 <vprintf+0x1ba>
          putc(fd, *s);
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	d1e080e7          	jalr	-738(ra) # 588 <putc>
          s++;
 872:	0905                	addi	s2,s2,1
        while(*s != 0){
 874:	00094583          	lbu	a1,0(s2)
 878:	f9e5                	bnez	a1,868 <vprintf+0x16c>
        s = va_arg(ap, char*);
 87a:	8b4e                	mv	s6,s3
      state = 0;
 87c:	4981                	li	s3,0
 87e:	bdf9                	j	75c <vprintf+0x60>
          s = "(null)";
 880:	00000917          	auipc	s2,0x0
 884:	2a890913          	addi	s2,s2,680 # b28 <malloc+0x162>
        while(*s != 0){
 888:	02800593          	li	a1,40
 88c:	bff1                	j	868 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 88e:	008b0913          	addi	s2,s6,8
 892:	000b4583          	lbu	a1,0(s6)
 896:	8556                	mv	a0,s5
 898:	00000097          	auipc	ra,0x0
 89c:	cf0080e7          	jalr	-784(ra) # 588 <putc>
 8a0:	8b4a                	mv	s6,s2
      state = 0;
 8a2:	4981                	li	s3,0
 8a4:	bd65                	j	75c <vprintf+0x60>
        putc(fd, c);
 8a6:	85d2                	mv	a1,s4
 8a8:	8556                	mv	a0,s5
 8aa:	00000097          	auipc	ra,0x0
 8ae:	cde080e7          	jalr	-802(ra) # 588 <putc>
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	b565                	j	75c <vprintf+0x60>
        s = va_arg(ap, char*);
 8b6:	8b4e                	mv	s6,s3
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	b54d                	j	75c <vprintf+0x60>
    }
  }
}
 8bc:	70e6                	ld	ra,120(sp)
 8be:	7446                	ld	s0,112(sp)
 8c0:	74a6                	ld	s1,104(sp)
 8c2:	7906                	ld	s2,96(sp)
 8c4:	69e6                	ld	s3,88(sp)
 8c6:	6a46                	ld	s4,80(sp)
 8c8:	6aa6                	ld	s5,72(sp)
 8ca:	6b06                	ld	s6,64(sp)
 8cc:	7be2                	ld	s7,56(sp)
 8ce:	7c42                	ld	s8,48(sp)
 8d0:	7ca2                	ld	s9,40(sp)
 8d2:	7d02                	ld	s10,32(sp)
 8d4:	6de2                	ld	s11,24(sp)
 8d6:	6109                	addi	sp,sp,128
 8d8:	8082                	ret

00000000000008da <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8da:	715d                	addi	sp,sp,-80
 8dc:	ec06                	sd	ra,24(sp)
 8de:	e822                	sd	s0,16(sp)
 8e0:	1000                	addi	s0,sp,32
 8e2:	e010                	sd	a2,0(s0)
 8e4:	e414                	sd	a3,8(s0)
 8e6:	e818                	sd	a4,16(s0)
 8e8:	ec1c                	sd	a5,24(s0)
 8ea:	03043023          	sd	a6,32(s0)
 8ee:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8f6:	8622                	mv	a2,s0
 8f8:	00000097          	auipc	ra,0x0
 8fc:	e04080e7          	jalr	-508(ra) # 6fc <vprintf>
}
 900:	60e2                	ld	ra,24(sp)
 902:	6442                	ld	s0,16(sp)
 904:	6161                	addi	sp,sp,80
 906:	8082                	ret

0000000000000908 <printf>:

void
printf(const char *fmt, ...)
{
 908:	711d                	addi	sp,sp,-96
 90a:	ec06                	sd	ra,24(sp)
 90c:	e822                	sd	s0,16(sp)
 90e:	1000                	addi	s0,sp,32
 910:	e40c                	sd	a1,8(s0)
 912:	e810                	sd	a2,16(s0)
 914:	ec14                	sd	a3,24(s0)
 916:	f018                	sd	a4,32(s0)
 918:	f41c                	sd	a5,40(s0)
 91a:	03043823          	sd	a6,48(s0)
 91e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 922:	00840613          	addi	a2,s0,8
 926:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 92a:	85aa                	mv	a1,a0
 92c:	4505                	li	a0,1
 92e:	00000097          	auipc	ra,0x0
 932:	dce080e7          	jalr	-562(ra) # 6fc <vprintf>
}
 936:	60e2                	ld	ra,24(sp)
 938:	6442                	ld	s0,16(sp)
 93a:	6125                	addi	sp,sp,96
 93c:	8082                	ret

000000000000093e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 93e:	1141                	addi	sp,sp,-16
 940:	e422                	sd	s0,8(sp)
 942:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 944:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 948:	00000797          	auipc	a5,0x0
 94c:	2287b783          	ld	a5,552(a5) # b70 <freep>
 950:	a805                	j	980 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 952:	4618                	lw	a4,8(a2)
 954:	9db9                	addw	a1,a1,a4
 956:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 95a:	6398                	ld	a4,0(a5)
 95c:	6318                	ld	a4,0(a4)
 95e:	fee53823          	sd	a4,-16(a0)
 962:	a091                	j	9a6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 964:	ff852703          	lw	a4,-8(a0)
 968:	9e39                	addw	a2,a2,a4
 96a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 96c:	ff053703          	ld	a4,-16(a0)
 970:	e398                	sd	a4,0(a5)
 972:	a099                	j	9b8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 974:	6398                	ld	a4,0(a5)
 976:	00e7e463          	bltu	a5,a4,97e <free+0x40>
 97a:	00e6ea63          	bltu	a3,a4,98e <free+0x50>
{
 97e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 980:	fed7fae3          	bgeu	a5,a3,974 <free+0x36>
 984:	6398                	ld	a4,0(a5)
 986:	00e6e463          	bltu	a3,a4,98e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 98a:	fee7eae3          	bltu	a5,a4,97e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 98e:	ff852583          	lw	a1,-8(a0)
 992:	6390                	ld	a2,0(a5)
 994:	02059713          	slli	a4,a1,0x20
 998:	9301                	srli	a4,a4,0x20
 99a:	0712                	slli	a4,a4,0x4
 99c:	9736                	add	a4,a4,a3
 99e:	fae60ae3          	beq	a2,a4,952 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9a2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9a6:	4790                	lw	a2,8(a5)
 9a8:	02061713          	slli	a4,a2,0x20
 9ac:	9301                	srli	a4,a4,0x20
 9ae:	0712                	slli	a4,a4,0x4
 9b0:	973e                	add	a4,a4,a5
 9b2:	fae689e3          	beq	a3,a4,964 <free+0x26>
  } else
    p->s.ptr = bp;
 9b6:	e394                	sd	a3,0(a5)
  freep = p;
 9b8:	00000717          	auipc	a4,0x0
 9bc:	1af73c23          	sd	a5,440(a4) # b70 <freep>
}
 9c0:	6422                	ld	s0,8(sp)
 9c2:	0141                	addi	sp,sp,16
 9c4:	8082                	ret

00000000000009c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9c6:	7139                	addi	sp,sp,-64
 9c8:	fc06                	sd	ra,56(sp)
 9ca:	f822                	sd	s0,48(sp)
 9cc:	f426                	sd	s1,40(sp)
 9ce:	f04a                	sd	s2,32(sp)
 9d0:	ec4e                	sd	s3,24(sp)
 9d2:	e852                	sd	s4,16(sp)
 9d4:	e456                	sd	s5,8(sp)
 9d6:	e05a                	sd	s6,0(sp)
 9d8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9da:	02051493          	slli	s1,a0,0x20
 9de:	9081                	srli	s1,s1,0x20
 9e0:	04bd                	addi	s1,s1,15
 9e2:	8091                	srli	s1,s1,0x4
 9e4:	0014899b          	addiw	s3,s1,1
 9e8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9ea:	00000517          	auipc	a0,0x0
 9ee:	18653503          	ld	a0,390(a0) # b70 <freep>
 9f2:	c515                	beqz	a0,a1e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f6:	4798                	lw	a4,8(a5)
 9f8:	02977f63          	bgeu	a4,s1,a36 <malloc+0x70>
 9fc:	8a4e                	mv	s4,s3
 9fe:	0009871b          	sext.w	a4,s3
 a02:	6685                	lui	a3,0x1
 a04:	00d77363          	bgeu	a4,a3,a0a <malloc+0x44>
 a08:	6a05                	lui	s4,0x1
 a0a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a0e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a12:	00000917          	auipc	s2,0x0
 a16:	15e90913          	addi	s2,s2,350 # b70 <freep>
  if(p == (char*)-1)
 a1a:	5afd                	li	s5,-1
 a1c:	a88d                	j	a8e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a1e:	00000797          	auipc	a5,0x0
 a22:	60a78793          	addi	a5,a5,1546 # 1028 <base>
 a26:	00000717          	auipc	a4,0x0
 a2a:	14f73523          	sd	a5,330(a4) # b70 <freep>
 a2e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a30:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a34:	b7e1                	j	9fc <malloc+0x36>
      if(p->s.size == nunits)
 a36:	02e48b63          	beq	s1,a4,a6c <malloc+0xa6>
        p->s.size -= nunits;
 a3a:	4137073b          	subw	a4,a4,s3
 a3e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a40:	1702                	slli	a4,a4,0x20
 a42:	9301                	srli	a4,a4,0x20
 a44:	0712                	slli	a4,a4,0x4
 a46:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a48:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a4c:	00000717          	auipc	a4,0x0
 a50:	12a73223          	sd	a0,292(a4) # b70 <freep>
      return (void*)(p + 1);
 a54:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a58:	70e2                	ld	ra,56(sp)
 a5a:	7442                	ld	s0,48(sp)
 a5c:	74a2                	ld	s1,40(sp)
 a5e:	7902                	ld	s2,32(sp)
 a60:	69e2                	ld	s3,24(sp)
 a62:	6a42                	ld	s4,16(sp)
 a64:	6aa2                	ld	s5,8(sp)
 a66:	6b02                	ld	s6,0(sp)
 a68:	6121                	addi	sp,sp,64
 a6a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a6c:	6398                	ld	a4,0(a5)
 a6e:	e118                	sd	a4,0(a0)
 a70:	bff1                	j	a4c <malloc+0x86>
  hp->s.size = nu;
 a72:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a76:	0541                	addi	a0,a0,16
 a78:	00000097          	auipc	ra,0x0
 a7c:	ec6080e7          	jalr	-314(ra) # 93e <free>
  return freep;
 a80:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a84:	d971                	beqz	a0,a58 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a86:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a88:	4798                	lw	a4,8(a5)
 a8a:	fa9776e3          	bgeu	a4,s1,a36 <malloc+0x70>
    if(p == freep)
 a8e:	00093703          	ld	a4,0(s2)
 a92:	853e                	mv	a0,a5
 a94:	fef719e3          	bne	a4,a5,a86 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a98:	8552                	mv	a0,s4
 a9a:	00000097          	auipc	ra,0x0
 a9e:	a62080e7          	jalr	-1438(ra) # 4fc <sbrk>
  if(p == (char*)-1)
 aa2:	fd5518e3          	bne	a0,s5,a72 <malloc+0xac>
        return 0;
 aa6:	4501                	li	a0,0
 aa8:	bf45                	j	a58 <malloc+0x92>
