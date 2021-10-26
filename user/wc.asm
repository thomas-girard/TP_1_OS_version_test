
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4981                	li	s3,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  2e:	00001d97          	auipc	s11,0x1
  32:	ad3d8d93          	addi	s11,s11,-1325 # b01 <buf+0x1>
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	a58a0a13          	addi	s4,s4,-1448 # a90 <malloc+0xe4>
        inword = 0;
  40:	4b01                	li	s6,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	1e8080e7          	jalr	488(ra) # 22e <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	89da                	mv	s3,s6
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	01248d63          	beq	s1,s2,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2b85                	addiw	s7,s7,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0997e3          	bnez	s3,52 <wc+0x52>
        w++;
  68:	2c05                	addiw	s8,s8,1
        inword = 1;
  6a:	4985                	li	s3,1
  6c:	b7dd                	j	52 <wc+0x52>
  6e:	01ac8cbb          	addw	s9,s9,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	00001597          	auipc	a1,0x1
  7a:	a8a58593          	addi	a1,a1,-1398 # b00 <buf>
  7e:	f8843503          	ld	a0,-120(s0)
  82:	00000097          	auipc	ra,0x0
  86:	3f0080e7          	jalr	1008(ra) # 472 <read>
  8a:	00a05f63          	blez	a0,a8 <wc+0xa8>
    for(i=0; i<n; i++){
  8e:	00001497          	auipc	s1,0x1
  92:	a7248493          	addi	s1,s1,-1422 # b00 <buf>
  96:	00050d1b          	sext.w	s10,a0
  9a:	fff5091b          	addiw	s2,a0,-1
  9e:	1902                	slli	s2,s2,0x20
  a0:	02095913          	srli	s2,s2,0x20
  a4:	996e                	add	s2,s2,s11
  a6:	bf4d                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  a8:	02054e63          	bltz	a0,e4 <wc+0xe4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  ac:	f8043703          	ld	a4,-128(s0)
  b0:	86e6                	mv	a3,s9
  b2:	8662                	mv	a2,s8
  b4:	85de                	mv	a1,s7
  b6:	00001517          	auipc	a0,0x1
  ba:	9f250513          	addi	a0,a0,-1550 # aa8 <malloc+0xfc>
  be:	00001097          	auipc	ra,0x1
  c2:	830080e7          	jalr	-2000(ra) # 8ee <printf>
}
  c6:	70e6                	ld	ra,120(sp)
  c8:	7446                	ld	s0,112(sp)
  ca:	74a6                	ld	s1,104(sp)
  cc:	7906                	ld	s2,96(sp)
  ce:	69e6                	ld	s3,88(sp)
  d0:	6a46                	ld	s4,80(sp)
  d2:	6aa6                	ld	s5,72(sp)
  d4:	6b06                	ld	s6,64(sp)
  d6:	7be2                	ld	s7,56(sp)
  d8:	7c42                	ld	s8,48(sp)
  da:	7ca2                	ld	s9,40(sp)
  dc:	7d02                	ld	s10,32(sp)
  de:	6de2                	ld	s11,24(sp)
  e0:	6109                	addi	sp,sp,128
  e2:	8082                	ret
    printf("wc: read error\n");
  e4:	00001517          	auipc	a0,0x1
  e8:	9b450513          	addi	a0,a0,-1612 # a98 <malloc+0xec>
  ec:	00001097          	auipc	ra,0x1
  f0:	802080e7          	jalr	-2046(ra) # 8ee <printf>
    exit(1);
  f4:	4505                	li	a0,1
  f6:	00000097          	auipc	ra,0x0
  fa:	364080e7          	jalr	868(ra) # 45a <exit>

00000000000000fe <main>:

int
main(int argc, char *argv[])
{
  fe:	7179                	addi	sp,sp,-48
 100:	f406                	sd	ra,40(sp)
 102:	f022                	sd	s0,32(sp)
 104:	ec26                	sd	s1,24(sp)
 106:	e84a                	sd	s2,16(sp)
 108:	e44e                	sd	s3,8(sp)
 10a:	e052                	sd	s4,0(sp)
 10c:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
 10e:	4785                	li	a5,1
 110:	04a7d763          	bge	a5,a0,15e <main+0x60>
 114:	00858493          	addi	s1,a1,8
 118:	ffe5099b          	addiw	s3,a0,-2
 11c:	1982                	slli	s3,s3,0x20
 11e:	0209d993          	srli	s3,s3,0x20
 122:	098e                	slli	s3,s3,0x3
 124:	05c1                	addi	a1,a1,16
 126:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 128:	4581                	li	a1,0
 12a:	6088                	ld	a0,0(s1)
 12c:	00000097          	auipc	ra,0x0
 130:	36e080e7          	jalr	878(ra) # 49a <open>
 134:	892a                	mv	s2,a0
 136:	04054263          	bltz	a0,17a <main+0x7c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 13a:	608c                	ld	a1,0(s1)
 13c:	00000097          	auipc	ra,0x0
 140:	ec4080e7          	jalr	-316(ra) # 0 <wc>
    close(fd);
 144:	854a                	mv	a0,s2
 146:	00000097          	auipc	ra,0x0
 14a:	278080e7          	jalr	632(ra) # 3be <close>
  for(i = 1; i < argc; i++){
 14e:	04a1                	addi	s1,s1,8
 150:	fd349ce3          	bne	s1,s3,128 <main+0x2a>
  }
  exit(0);
 154:	4501                	li	a0,0
 156:	00000097          	auipc	ra,0x0
 15a:	304080e7          	jalr	772(ra) # 45a <exit>
    wc(0, "");
 15e:	00001597          	auipc	a1,0x1
 162:	95a58593          	addi	a1,a1,-1702 # ab8 <malloc+0x10c>
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	e98080e7          	jalr	-360(ra) # 0 <wc>
    exit(0);
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	2e8080e7          	jalr	744(ra) # 45a <exit>
      printf("wc: cannot open %s\n", argv[i]);
 17a:	608c                	ld	a1,0(s1)
 17c:	00001517          	auipc	a0,0x1
 180:	94450513          	addi	a0,a0,-1724 # ac0 <malloc+0x114>
 184:	00000097          	auipc	ra,0x0
 188:	76a080e7          	jalr	1898(ra) # 8ee <printf>
      exit(1);
 18c:	4505                	li	a0,1
 18e:	00000097          	auipc	ra,0x0
 192:	2cc080e7          	jalr	716(ra) # 45a <exit>

0000000000000196 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 19c:	87aa                	mv	a5,a0
 19e:	0585                	addi	a1,a1,1
 1a0:	0785                	addi	a5,a5,1
 1a2:	fff5c703          	lbu	a4,-1(a1)
 1a6:	fee78fa3          	sb	a4,-1(a5)
 1aa:	fb75                	bnez	a4,19e <strcpy+0x8>
    ;
  return os;
}
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret

00000000000001b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e422                	sd	s0,8(sp)
 1b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	cb91                	beqz	a5,1d0 <strcmp+0x1e>
 1be:	0005c703          	lbu	a4,0(a1)
 1c2:	00f71763          	bne	a4,a5,1d0 <strcmp+0x1e>
    p++, q++;
 1c6:	0505                	addi	a0,a0,1
 1c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	fbe5                	bnez	a5,1be <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d0:	0005c503          	lbu	a0,0(a1)
}
 1d4:	40a7853b          	subw	a0,a5,a0
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret

00000000000001de <strlen>:

uint
strlen(const char *s)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	cf91                	beqz	a5,204 <strlen+0x26>
 1ea:	0505                	addi	a0,a0,1
 1ec:	87aa                	mv	a5,a0
 1ee:	4685                	li	a3,1
 1f0:	9e89                	subw	a3,a3,a0
 1f2:	00f6853b          	addw	a0,a3,a5
 1f6:	0785                	addi	a5,a5,1
 1f8:	fff7c703          	lbu	a4,-1(a5)
 1fc:	fb7d                	bnez	a4,1f2 <strlen+0x14>
    ;
  return n;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  for(n = 0; s[n]; n++)
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <strlen+0x20>

0000000000000208 <memset>:

void*
memset(void *dst, int c, uint n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 20e:	ce09                	beqz	a2,228 <memset+0x20>
 210:	87aa                	mv	a5,a0
 212:	fff6071b          	addiw	a4,a2,-1
 216:	1702                	slli	a4,a4,0x20
 218:	9301                	srli	a4,a4,0x20
 21a:	0705                	addi	a4,a4,1
 21c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 21e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 222:	0785                	addi	a5,a5,1
 224:	fee79de3          	bne	a5,a4,21e <memset+0x16>
  }
  return dst;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret

000000000000022e <strchr>:

char*
strchr(const char *s, char c)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  for(; *s; s++)
 234:	00054783          	lbu	a5,0(a0)
 238:	cb99                	beqz	a5,24e <strchr+0x20>
    if(*s == c)
 23a:	00f58763          	beq	a1,a5,248 <strchr+0x1a>
  for(; *s; s++)
 23e:	0505                	addi	a0,a0,1
 240:	00054783          	lbu	a5,0(a0)
 244:	fbfd                	bnez	a5,23a <strchr+0xc>
      return (char*)s;
  return 0;
 246:	4501                	li	a0,0
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
  return 0;
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <strchr+0x1a>

0000000000000252 <gets>:

char*
gets(char *buf, int max)
{
 252:	711d                	addi	sp,sp,-96
 254:	ec86                	sd	ra,88(sp)
 256:	e8a2                	sd	s0,80(sp)
 258:	e4a6                	sd	s1,72(sp)
 25a:	e0ca                	sd	s2,64(sp)
 25c:	fc4e                	sd	s3,56(sp)
 25e:	f852                	sd	s4,48(sp)
 260:	f456                	sd	s5,40(sp)
 262:	f05a                	sd	s6,32(sp)
 264:	ec5e                	sd	s7,24(sp)
 266:	1080                	addi	s0,sp,96
 268:	8baa                	mv	s7,a0
 26a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26c:	892a                	mv	s2,a0
 26e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 270:	4aa9                	li	s5,10
 272:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 274:	89a6                	mv	s3,s1
 276:	2485                	addiw	s1,s1,1
 278:	0344d863          	bge	s1,s4,2a8 <gets+0x56>
    cc = read(0, &c, 1);
 27c:	4605                	li	a2,1
 27e:	faf40593          	addi	a1,s0,-81
 282:	4501                	li	a0,0
 284:	00000097          	auipc	ra,0x0
 288:	1ee080e7          	jalr	494(ra) # 472 <read>
    if(cc < 1)
 28c:	00a05e63          	blez	a0,2a8 <gets+0x56>
    buf[i++] = c;
 290:	faf44783          	lbu	a5,-81(s0)
 294:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 298:	01578763          	beq	a5,s5,2a6 <gets+0x54>
 29c:	0905                	addi	s2,s2,1
 29e:	fd679be3          	bne	a5,s6,274 <gets+0x22>
  for(i=0; i+1 < max; ){
 2a2:	89a6                	mv	s3,s1
 2a4:	a011                	j	2a8 <gets+0x56>
 2a6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a8:	99de                	add	s3,s3,s7
 2aa:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ae:	855e                	mv	a0,s7
 2b0:	60e6                	ld	ra,88(sp)
 2b2:	6446                	ld	s0,80(sp)
 2b4:	64a6                	ld	s1,72(sp)
 2b6:	6906                	ld	s2,64(sp)
 2b8:	79e2                	ld	s3,56(sp)
 2ba:	7a42                	ld	s4,48(sp)
 2bc:	7aa2                	ld	s5,40(sp)
 2be:	7b02                	ld	s6,32(sp)
 2c0:	6be2                	ld	s7,24(sp)
 2c2:	6125                	addi	sp,sp,96
 2c4:	8082                	ret

00000000000002c6 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2cc:	00054603          	lbu	a2,0(a0)
 2d0:	fd06079b          	addiw	a5,a2,-48
 2d4:	0ff7f793          	andi	a5,a5,255
 2d8:	4725                	li	a4,9
 2da:	02f76963          	bltu	a4,a5,30c <atoi+0x46>
 2de:	86aa                	mv	a3,a0
  n = 0;
 2e0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2e2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2e4:	0685                	addi	a3,a3,1
 2e6:	0025179b          	slliw	a5,a0,0x2
 2ea:	9fa9                	addw	a5,a5,a0
 2ec:	0017979b          	slliw	a5,a5,0x1
 2f0:	9fb1                	addw	a5,a5,a2
 2f2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f6:	0006c603          	lbu	a2,0(a3)
 2fa:	fd06071b          	addiw	a4,a2,-48
 2fe:	0ff77713          	andi	a4,a4,255
 302:	fee5f1e3          	bgeu	a1,a4,2e4 <atoi+0x1e>
  return n;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  n = 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <atoi+0x40>

0000000000000310 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 316:	02b57663          	bgeu	a0,a1,342 <memmove+0x32>
    while(n-- > 0)
 31a:	02c05163          	blez	a2,33c <memmove+0x2c>
 31e:	fff6079b          	addiw	a5,a2,-1
 322:	1782                	slli	a5,a5,0x20
 324:	9381                	srli	a5,a5,0x20
 326:	0785                	addi	a5,a5,1
 328:	97aa                	add	a5,a5,a0
  dst = vdst;
 32a:	872a                	mv	a4,a0
      *dst++ = *src++;
 32c:	0585                	addi	a1,a1,1
 32e:	0705                	addi	a4,a4,1
 330:	fff5c683          	lbu	a3,-1(a1)
 334:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 338:	fee79ae3          	bne	a5,a4,32c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
    dst += n;
 342:	00c50733          	add	a4,a0,a2
    src += n;
 346:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 348:	fec05ae3          	blez	a2,33c <memmove+0x2c>
 34c:	fff6079b          	addiw	a5,a2,-1
 350:	1782                	slli	a5,a5,0x20
 352:	9381                	srli	a5,a5,0x20
 354:	fff7c793          	not	a5,a5
 358:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35a:	15fd                	addi	a1,a1,-1
 35c:	177d                	addi	a4,a4,-1
 35e:	0005c683          	lbu	a3,0(a1)
 362:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 366:	fee79ae3          	bne	a5,a4,35a <memmove+0x4a>
 36a:	bfc9                	j	33c <memmove+0x2c>

000000000000036c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 372:	ca05                	beqz	a2,3a2 <memcmp+0x36>
 374:	fff6069b          	addiw	a3,a2,-1
 378:	1682                	slli	a3,a3,0x20
 37a:	9281                	srli	a3,a3,0x20
 37c:	0685                	addi	a3,a3,1
 37e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 380:	00054783          	lbu	a5,0(a0)
 384:	0005c703          	lbu	a4,0(a1)
 388:	00e79863          	bne	a5,a4,398 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38c:	0505                	addi	a0,a0,1
    p2++;
 38e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 390:	fed518e3          	bne	a0,a3,380 <memcmp+0x14>
  }
  return 0;
 394:	4501                	li	a0,0
 396:	a019                	j	39c <memcmp+0x30>
      return *p1 - *p2;
 398:	40e7853b          	subw	a0,a5,a4
}
 39c:	6422                	ld	s0,8(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret
  return 0;
 3a2:	4501                	li	a0,0
 3a4:	bfe5                	j	39c <memcmp+0x30>

00000000000003a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e406                	sd	ra,8(sp)
 3aa:	e022                	sd	s0,0(sp)
 3ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ae:	00000097          	auipc	ra,0x0
 3b2:	f62080e7          	jalr	-158(ra) # 310 <memmove>
}
 3b6:	60a2                	ld	ra,8(sp)
 3b8:	6402                	ld	s0,0(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret

00000000000003be <close>:

int close(int fd){
 3be:	1101                	addi	sp,sp,-32
 3c0:	ec06                	sd	ra,24(sp)
 3c2:	e822                	sd	s0,16(sp)
 3c4:	e426                	sd	s1,8(sp)
 3c6:	1000                	addi	s0,sp,32
 3c8:	84aa                	mv	s1,a0
  fflush(fd);
 3ca:	00000097          	auipc	ra,0x0
 3ce:	2d4080e7          	jalr	724(ra) # 69e <fflush>
  char* buf = get_putc_buf(fd);
 3d2:	8526                	mv	a0,s1
 3d4:	00000097          	auipc	ra,0x0
 3d8:	14e080e7          	jalr	334(ra) # 522 <get_putc_buf>
  if(buf){
 3dc:	cd11                	beqz	a0,3f8 <close+0x3a>
    free(buf);
 3de:	00000097          	auipc	ra,0x0
 3e2:	546080e7          	jalr	1350(ra) # 924 <free>
    putc_buf[fd] = 0;
 3e6:	00349713          	slli	a4,s1,0x3
 3ea:	00001797          	auipc	a5,0x1
 3ee:	91678793          	addi	a5,a5,-1770 # d00 <putc_buf>
 3f2:	97ba                	add	a5,a5,a4
 3f4:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 3f8:	8526                	mv	a0,s1
 3fa:	00000097          	auipc	ra,0x0
 3fe:	088080e7          	jalr	136(ra) # 482 <sclose>
}
 402:	60e2                	ld	ra,24(sp)
 404:	6442                	ld	s0,16(sp)
 406:	64a2                	ld	s1,8(sp)
 408:	6105                	addi	sp,sp,32
 40a:	8082                	ret

000000000000040c <stat>:
{
 40c:	1101                	addi	sp,sp,-32
 40e:	ec06                	sd	ra,24(sp)
 410:	e822                	sd	s0,16(sp)
 412:	e426                	sd	s1,8(sp)
 414:	e04a                	sd	s2,0(sp)
 416:	1000                	addi	s0,sp,32
 418:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 41a:	4581                	li	a1,0
 41c:	00000097          	auipc	ra,0x0
 420:	07e080e7          	jalr	126(ra) # 49a <open>
  if(fd < 0)
 424:	02054563          	bltz	a0,44e <stat+0x42>
 428:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 42a:	85ca                	mv	a1,s2
 42c:	00000097          	auipc	ra,0x0
 430:	086080e7          	jalr	134(ra) # 4b2 <fstat>
 434:	892a                	mv	s2,a0
  close(fd);
 436:	8526                	mv	a0,s1
 438:	00000097          	auipc	ra,0x0
 43c:	f86080e7          	jalr	-122(ra) # 3be <close>
}
 440:	854a                	mv	a0,s2
 442:	60e2                	ld	ra,24(sp)
 444:	6442                	ld	s0,16(sp)
 446:	64a2                	ld	s1,8(sp)
 448:	6902                	ld	s2,0(sp)
 44a:	6105                	addi	sp,sp,32
 44c:	8082                	ret
    return -1;
 44e:	597d                	li	s2,-1
 450:	bfc5                	j	440 <stat+0x34>

0000000000000452 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 452:	4885                	li	a7,1
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <exit>:
.global exit
exit:
 li a7, SYS_exit
 45a:	4889                	li	a7,2
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <wait>:
.global wait
wait:
 li a7, SYS_wait
 462:	488d                	li	a7,3
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 46a:	4891                	li	a7,4
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <read>:
.global read
read:
 li a7, SYS_read
 472:	4895                	li	a7,5
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <write>:
.global write
write:
 li a7, SYS_write
 47a:	48c1                	li	a7,16
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 482:	48d5                	li	a7,21
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <kill>:
.global kill
kill:
 li a7, SYS_kill
 48a:	4899                	li	a7,6
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <exec>:
.global exec
exec:
 li a7, SYS_exec
 492:	489d                	li	a7,7
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <open>:
.global open
open:
 li a7, SYS_open
 49a:	48bd                	li	a7,15
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4a2:	48c5                	li	a7,17
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4aa:	48c9                	li	a7,18
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4b2:	48a1                	li	a7,8
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <link>:
.global link
link:
 li a7, SYS_link
 4ba:	48cd                	li	a7,19
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4c2:	48d1                	li	a7,20
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ca:	48a5                	li	a7,9
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4d2:	48a9                	li	a7,10
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4da:	48ad                	li	a7,11
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4e2:	48b1                	li	a7,12
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ea:	48b5                	li	a7,13
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4f2:	48b9                	li	a7,14
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 4fa:	48d9                	li	a7,22
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <nice>:
.global nice
nice:
 li a7, SYS_nice
 502:	48dd                	li	a7,23
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 50a:	48e1                	li	a7,24
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 512:	48e5                	li	a7,25
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 51a:	48e9                	li	a7,26
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 522:	1101                	addi	sp,sp,-32
 524:	ec06                	sd	ra,24(sp)
 526:	e822                	sd	s0,16(sp)
 528:	e426                	sd	s1,8(sp)
 52a:	1000                	addi	s0,sp,32
 52c:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 52e:	00351713          	slli	a4,a0,0x3
 532:	00000797          	auipc	a5,0x0
 536:	7ce78793          	addi	a5,a5,1998 # d00 <putc_buf>
 53a:	97ba                	add	a5,a5,a4
 53c:	6388                	ld	a0,0(a5)
  if(buf) {
 53e:	c511                	beqz	a0,54a <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 540:	60e2                	ld	ra,24(sp)
 542:	6442                	ld	s0,16(sp)
 544:	64a2                	ld	s1,8(sp)
 546:	6105                	addi	sp,sp,32
 548:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 54a:	6505                	lui	a0,0x1
 54c:	00000097          	auipc	ra,0x0
 550:	460080e7          	jalr	1120(ra) # 9ac <malloc>
  putc_buf[fd] = buf;
 554:	00000797          	auipc	a5,0x0
 558:	7ac78793          	addi	a5,a5,1964 # d00 <putc_buf>
 55c:	00349713          	slli	a4,s1,0x3
 560:	973e                	add	a4,a4,a5
 562:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 564:	048a                	slli	s1,s1,0x2
 566:	94be                	add	s1,s1,a5
 568:	3204a023          	sw	zero,800(s1)
  return buf;
 56c:	bfd1                	j	540 <get_putc_buf+0x1e>

000000000000056e <putc>:

static void
putc(int fd, char c)
{
 56e:	1101                	addi	sp,sp,-32
 570:	ec06                	sd	ra,24(sp)
 572:	e822                	sd	s0,16(sp)
 574:	e426                	sd	s1,8(sp)
 576:	e04a                	sd	s2,0(sp)
 578:	1000                	addi	s0,sp,32
 57a:	84aa                	mv	s1,a0
 57c:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 57e:	00000097          	auipc	ra,0x0
 582:	fa4080e7          	jalr	-92(ra) # 522 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 586:	00249793          	slli	a5,s1,0x2
 58a:	00000717          	auipc	a4,0x0
 58e:	77670713          	addi	a4,a4,1910 # d00 <putc_buf>
 592:	973e                	add	a4,a4,a5
 594:	32072783          	lw	a5,800(a4)
 598:	0017869b          	addiw	a3,a5,1
 59c:	32d72023          	sw	a3,800(a4)
 5a0:	97aa                	add	a5,a5,a0
 5a2:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 5a6:	47a9                	li	a5,10
 5a8:	02f90463          	beq	s2,a5,5d0 <putc+0x62>
 5ac:	00249713          	slli	a4,s1,0x2
 5b0:	00000797          	auipc	a5,0x0
 5b4:	75078793          	addi	a5,a5,1872 # d00 <putc_buf>
 5b8:	97ba                	add	a5,a5,a4
 5ba:	3207a703          	lw	a4,800(a5)
 5be:	6785                	lui	a5,0x1
 5c0:	00f70863          	beq	a4,a5,5d0 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 5c4:	60e2                	ld	ra,24(sp)
 5c6:	6442                	ld	s0,16(sp)
 5c8:	64a2                	ld	s1,8(sp)
 5ca:	6902                	ld	s2,0(sp)
 5cc:	6105                	addi	sp,sp,32
 5ce:	8082                	ret
    write(fd, buf, putc_index[fd]);
 5d0:	00249793          	slli	a5,s1,0x2
 5d4:	00000917          	auipc	s2,0x0
 5d8:	72c90913          	addi	s2,s2,1836 # d00 <putc_buf>
 5dc:	993e                	add	s2,s2,a5
 5de:	32092603          	lw	a2,800(s2)
 5e2:	85aa                	mv	a1,a0
 5e4:	8526                	mv	a0,s1
 5e6:	00000097          	auipc	ra,0x0
 5ea:	e94080e7          	jalr	-364(ra) # 47a <write>
    putc_index[fd] = 0;
 5ee:	32092023          	sw	zero,800(s2)
}
 5f2:	bfc9                	j	5c4 <putc+0x56>

00000000000005f4 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 5f4:	7139                	addi	sp,sp,-64
 5f6:	fc06                	sd	ra,56(sp)
 5f8:	f822                	sd	s0,48(sp)
 5fa:	f426                	sd	s1,40(sp)
 5fc:	f04a                	sd	s2,32(sp)
 5fe:	ec4e                	sd	s3,24(sp)
 600:	0080                	addi	s0,sp,64
 602:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 604:	c299                	beqz	a3,60a <printint+0x16>
 606:	0805c863          	bltz	a1,696 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 60a:	2581                	sext.w	a1,a1
  neg = 0;
 60c:	4881                	li	a7,0
 60e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 612:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 614:	2601                	sext.w	a2,a2
 616:	00000517          	auipc	a0,0x0
 61a:	4ca50513          	addi	a0,a0,1226 # ae0 <digits>
 61e:	883a                	mv	a6,a4
 620:	2705                	addiw	a4,a4,1
 622:	02c5f7bb          	remuw	a5,a1,a2
 626:	1782                	slli	a5,a5,0x20
 628:	9381                	srli	a5,a5,0x20
 62a:	97aa                	add	a5,a5,a0
 62c:	0007c783          	lbu	a5,0(a5) # 1000 <putc_buf+0x300>
 630:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 634:	0005879b          	sext.w	a5,a1
 638:	02c5d5bb          	divuw	a1,a1,a2
 63c:	0685                	addi	a3,a3,1
 63e:	fec7f0e3          	bgeu	a5,a2,61e <printint+0x2a>
  if(neg)
 642:	00088b63          	beqz	a7,658 <printint+0x64>
    buf[i++] = '-';
 646:	fd040793          	addi	a5,s0,-48
 64a:	973e                	add	a4,a4,a5
 64c:	02d00793          	li	a5,45
 650:	fef70823          	sb	a5,-16(a4)
 654:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 658:	02e05863          	blez	a4,688 <printint+0x94>
 65c:	fc040793          	addi	a5,s0,-64
 660:	00e78933          	add	s2,a5,a4
 664:	fff78993          	addi	s3,a5,-1
 668:	99ba                	add	s3,s3,a4
 66a:	377d                	addiw	a4,a4,-1
 66c:	1702                	slli	a4,a4,0x20
 66e:	9301                	srli	a4,a4,0x20
 670:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 674:	fff94583          	lbu	a1,-1(s2)
 678:	8526                	mv	a0,s1
 67a:	00000097          	auipc	ra,0x0
 67e:	ef4080e7          	jalr	-268(ra) # 56e <putc>
  while(--i >= 0)
 682:	197d                	addi	s2,s2,-1
 684:	ff3918e3          	bne	s2,s3,674 <printint+0x80>
}
 688:	70e2                	ld	ra,56(sp)
 68a:	7442                	ld	s0,48(sp)
 68c:	74a2                	ld	s1,40(sp)
 68e:	7902                	ld	s2,32(sp)
 690:	69e2                	ld	s3,24(sp)
 692:	6121                	addi	sp,sp,64
 694:	8082                	ret
    x = -xx;
 696:	40b005bb          	negw	a1,a1
    neg = 1;
 69a:	4885                	li	a7,1
    x = -xx;
 69c:	bf8d                	j	60e <printint+0x1a>

000000000000069e <fflush>:
void fflush(int fd){
 69e:	1101                	addi	sp,sp,-32
 6a0:	ec06                	sd	ra,24(sp)
 6a2:	e822                	sd	s0,16(sp)
 6a4:	e426                	sd	s1,8(sp)
 6a6:	e04a                	sd	s2,0(sp)
 6a8:	1000                	addi	s0,sp,32
 6aa:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 6ac:	00000097          	auipc	ra,0x0
 6b0:	e76080e7          	jalr	-394(ra) # 522 <get_putc_buf>
 6b4:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 6b6:	00291793          	slli	a5,s2,0x2
 6ba:	00000497          	auipc	s1,0x0
 6be:	64648493          	addi	s1,s1,1606 # d00 <putc_buf>
 6c2:	94be                	add	s1,s1,a5
 6c4:	3204a603          	lw	a2,800(s1)
 6c8:	854a                	mv	a0,s2
 6ca:	00000097          	auipc	ra,0x0
 6ce:	db0080e7          	jalr	-592(ra) # 47a <write>
  putc_index[fd] = 0;
 6d2:	3204a023          	sw	zero,800(s1)
}
 6d6:	60e2                	ld	ra,24(sp)
 6d8:	6442                	ld	s0,16(sp)
 6da:	64a2                	ld	s1,8(sp)
 6dc:	6902                	ld	s2,0(sp)
 6de:	6105                	addi	sp,sp,32
 6e0:	8082                	ret

00000000000006e2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6e2:	7119                	addi	sp,sp,-128
 6e4:	fc86                	sd	ra,120(sp)
 6e6:	f8a2                	sd	s0,112(sp)
 6e8:	f4a6                	sd	s1,104(sp)
 6ea:	f0ca                	sd	s2,96(sp)
 6ec:	ecce                	sd	s3,88(sp)
 6ee:	e8d2                	sd	s4,80(sp)
 6f0:	e4d6                	sd	s5,72(sp)
 6f2:	e0da                	sd	s6,64(sp)
 6f4:	fc5e                	sd	s7,56(sp)
 6f6:	f862                	sd	s8,48(sp)
 6f8:	f466                	sd	s9,40(sp)
 6fa:	f06a                	sd	s10,32(sp)
 6fc:	ec6e                	sd	s11,24(sp)
 6fe:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 700:	0005c903          	lbu	s2,0(a1)
 704:	18090f63          	beqz	s2,8a2 <vprintf+0x1c0>
 708:	8aaa                	mv	s5,a0
 70a:	8b32                	mv	s6,a2
 70c:	00158493          	addi	s1,a1,1
  state = 0;
 710:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 712:	02500a13          	li	s4,37
      if(c == 'd'){
 716:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 71a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 71e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 722:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 726:	00000b97          	auipc	s7,0x0
 72a:	3bab8b93          	addi	s7,s7,954 # ae0 <digits>
 72e:	a839                	j	74c <vprintf+0x6a>
        putc(fd, c);
 730:	85ca                	mv	a1,s2
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	e3a080e7          	jalr	-454(ra) # 56e <putc>
 73c:	a019                	j	742 <vprintf+0x60>
    } else if(state == '%'){
 73e:	01498f63          	beq	s3,s4,75c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 742:	0485                	addi	s1,s1,1
 744:	fff4c903          	lbu	s2,-1(s1)
 748:	14090d63          	beqz	s2,8a2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 74c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 750:	fe0997e3          	bnez	s3,73e <vprintf+0x5c>
      if(c == '%'){
 754:	fd479ee3          	bne	a5,s4,730 <vprintf+0x4e>
        state = '%';
 758:	89be                	mv	s3,a5
 75a:	b7e5                	j	742 <vprintf+0x60>
      if(c == 'd'){
 75c:	05878063          	beq	a5,s8,79c <vprintf+0xba>
      } else if(c == 'l') {
 760:	05978c63          	beq	a5,s9,7b8 <vprintf+0xd6>
      } else if(c == 'x') {
 764:	07a78863          	beq	a5,s10,7d4 <vprintf+0xf2>
      } else if(c == 'p') {
 768:	09b78463          	beq	a5,s11,7f0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 76c:	07300713          	li	a4,115
 770:	0ce78663          	beq	a5,a4,83c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 774:	06300713          	li	a4,99
 778:	0ee78e63          	beq	a5,a4,874 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 77c:	11478863          	beq	a5,s4,88c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 780:	85d2                	mv	a1,s4
 782:	8556                	mv	a0,s5
 784:	00000097          	auipc	ra,0x0
 788:	dea080e7          	jalr	-534(ra) # 56e <putc>
        putc(fd, c);
 78c:	85ca                	mv	a1,s2
 78e:	8556                	mv	a0,s5
 790:	00000097          	auipc	ra,0x0
 794:	dde080e7          	jalr	-546(ra) # 56e <putc>
      }
      state = 0;
 798:	4981                	li	s3,0
 79a:	b765                	j	742 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 79c:	008b0913          	addi	s2,s6,8
 7a0:	4685                	li	a3,1
 7a2:	4629                	li	a2,10
 7a4:	000b2583          	lw	a1,0(s6)
 7a8:	8556                	mv	a0,s5
 7aa:	00000097          	auipc	ra,0x0
 7ae:	e4a080e7          	jalr	-438(ra) # 5f4 <printint>
 7b2:	8b4a                	mv	s6,s2
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	b771                	j	742 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7b8:	008b0913          	addi	s2,s6,8
 7bc:	4681                	li	a3,0
 7be:	4629                	li	a2,10
 7c0:	000b2583          	lw	a1,0(s6)
 7c4:	8556                	mv	a0,s5
 7c6:	00000097          	auipc	ra,0x0
 7ca:	e2e080e7          	jalr	-466(ra) # 5f4 <printint>
 7ce:	8b4a                	mv	s6,s2
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	bf85                	j	742 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7d4:	008b0913          	addi	s2,s6,8
 7d8:	4681                	li	a3,0
 7da:	4641                	li	a2,16
 7dc:	000b2583          	lw	a1,0(s6)
 7e0:	8556                	mv	a0,s5
 7e2:	00000097          	auipc	ra,0x0
 7e6:	e12080e7          	jalr	-494(ra) # 5f4 <printint>
 7ea:	8b4a                	mv	s6,s2
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	bf91                	j	742 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7f0:	008b0793          	addi	a5,s6,8
 7f4:	f8f43423          	sd	a5,-120(s0)
 7f8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7fc:	03000593          	li	a1,48
 800:	8556                	mv	a0,s5
 802:	00000097          	auipc	ra,0x0
 806:	d6c080e7          	jalr	-660(ra) # 56e <putc>
  putc(fd, 'x');
 80a:	85ea                	mv	a1,s10
 80c:	8556                	mv	a0,s5
 80e:	00000097          	auipc	ra,0x0
 812:	d60080e7          	jalr	-672(ra) # 56e <putc>
 816:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 818:	03c9d793          	srli	a5,s3,0x3c
 81c:	97de                	add	a5,a5,s7
 81e:	0007c583          	lbu	a1,0(a5)
 822:	8556                	mv	a0,s5
 824:	00000097          	auipc	ra,0x0
 828:	d4a080e7          	jalr	-694(ra) # 56e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 82c:	0992                	slli	s3,s3,0x4
 82e:	397d                	addiw	s2,s2,-1
 830:	fe0914e3          	bnez	s2,818 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 834:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 838:	4981                	li	s3,0
 83a:	b721                	j	742 <vprintf+0x60>
        s = va_arg(ap, char*);
 83c:	008b0993          	addi	s3,s6,8
 840:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 844:	02090163          	beqz	s2,866 <vprintf+0x184>
        while(*s != 0){
 848:	00094583          	lbu	a1,0(s2)
 84c:	c9a1                	beqz	a1,89c <vprintf+0x1ba>
          putc(fd, *s);
 84e:	8556                	mv	a0,s5
 850:	00000097          	auipc	ra,0x0
 854:	d1e080e7          	jalr	-738(ra) # 56e <putc>
          s++;
 858:	0905                	addi	s2,s2,1
        while(*s != 0){
 85a:	00094583          	lbu	a1,0(s2)
 85e:	f9e5                	bnez	a1,84e <vprintf+0x16c>
        s = va_arg(ap, char*);
 860:	8b4e                	mv	s6,s3
      state = 0;
 862:	4981                	li	s3,0
 864:	bdf9                	j	742 <vprintf+0x60>
          s = "(null)";
 866:	00000917          	auipc	s2,0x0
 86a:	27290913          	addi	s2,s2,626 # ad8 <malloc+0x12c>
        while(*s != 0){
 86e:	02800593          	li	a1,40
 872:	bff1                	j	84e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 874:	008b0913          	addi	s2,s6,8
 878:	000b4583          	lbu	a1,0(s6)
 87c:	8556                	mv	a0,s5
 87e:	00000097          	auipc	ra,0x0
 882:	cf0080e7          	jalr	-784(ra) # 56e <putc>
 886:	8b4a                	mv	s6,s2
      state = 0;
 888:	4981                	li	s3,0
 88a:	bd65                	j	742 <vprintf+0x60>
        putc(fd, c);
 88c:	85d2                	mv	a1,s4
 88e:	8556                	mv	a0,s5
 890:	00000097          	auipc	ra,0x0
 894:	cde080e7          	jalr	-802(ra) # 56e <putc>
      state = 0;
 898:	4981                	li	s3,0
 89a:	b565                	j	742 <vprintf+0x60>
        s = va_arg(ap, char*);
 89c:	8b4e                	mv	s6,s3
      state = 0;
 89e:	4981                	li	s3,0
 8a0:	b54d                	j	742 <vprintf+0x60>
    }
  }
}
 8a2:	70e6                	ld	ra,120(sp)
 8a4:	7446                	ld	s0,112(sp)
 8a6:	74a6                	ld	s1,104(sp)
 8a8:	7906                	ld	s2,96(sp)
 8aa:	69e6                	ld	s3,88(sp)
 8ac:	6a46                	ld	s4,80(sp)
 8ae:	6aa6                	ld	s5,72(sp)
 8b0:	6b06                	ld	s6,64(sp)
 8b2:	7be2                	ld	s7,56(sp)
 8b4:	7c42                	ld	s8,48(sp)
 8b6:	7ca2                	ld	s9,40(sp)
 8b8:	7d02                	ld	s10,32(sp)
 8ba:	6de2                	ld	s11,24(sp)
 8bc:	6109                	addi	sp,sp,128
 8be:	8082                	ret

00000000000008c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8c0:	715d                	addi	sp,sp,-80
 8c2:	ec06                	sd	ra,24(sp)
 8c4:	e822                	sd	s0,16(sp)
 8c6:	1000                	addi	s0,sp,32
 8c8:	e010                	sd	a2,0(s0)
 8ca:	e414                	sd	a3,8(s0)
 8cc:	e818                	sd	a4,16(s0)
 8ce:	ec1c                	sd	a5,24(s0)
 8d0:	03043023          	sd	a6,32(s0)
 8d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8dc:	8622                	mv	a2,s0
 8de:	00000097          	auipc	ra,0x0
 8e2:	e04080e7          	jalr	-508(ra) # 6e2 <vprintf>
}
 8e6:	60e2                	ld	ra,24(sp)
 8e8:	6442                	ld	s0,16(sp)
 8ea:	6161                	addi	sp,sp,80
 8ec:	8082                	ret

00000000000008ee <printf>:

void
printf(const char *fmt, ...)
{
 8ee:	711d                	addi	sp,sp,-96
 8f0:	ec06                	sd	ra,24(sp)
 8f2:	e822                	sd	s0,16(sp)
 8f4:	1000                	addi	s0,sp,32
 8f6:	e40c                	sd	a1,8(s0)
 8f8:	e810                	sd	a2,16(s0)
 8fa:	ec14                	sd	a3,24(s0)
 8fc:	f018                	sd	a4,32(s0)
 8fe:	f41c                	sd	a5,40(s0)
 900:	03043823          	sd	a6,48(s0)
 904:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 908:	00840613          	addi	a2,s0,8
 90c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 910:	85aa                	mv	a1,a0
 912:	4505                	li	a0,1
 914:	00000097          	auipc	ra,0x0
 918:	dce080e7          	jalr	-562(ra) # 6e2 <vprintf>
}
 91c:	60e2                	ld	ra,24(sp)
 91e:	6442                	ld	s0,16(sp)
 920:	6125                	addi	sp,sp,96
 922:	8082                	ret

0000000000000924 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 924:	1141                	addi	sp,sp,-16
 926:	e422                	sd	s0,8(sp)
 928:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 92a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92e:	00000797          	auipc	a5,0x0
 932:	1ca7b783          	ld	a5,458(a5) # af8 <freep>
 936:	a805                	j	966 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 938:	4618                	lw	a4,8(a2)
 93a:	9db9                	addw	a1,a1,a4
 93c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 940:	6398                	ld	a4,0(a5)
 942:	6318                	ld	a4,0(a4)
 944:	fee53823          	sd	a4,-16(a0)
 948:	a091                	j	98c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 94a:	ff852703          	lw	a4,-8(a0)
 94e:	9e39                	addw	a2,a2,a4
 950:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 952:	ff053703          	ld	a4,-16(a0)
 956:	e398                	sd	a4,0(a5)
 958:	a099                	j	99e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 95a:	6398                	ld	a4,0(a5)
 95c:	00e7e463          	bltu	a5,a4,964 <free+0x40>
 960:	00e6ea63          	bltu	a3,a4,974 <free+0x50>
{
 964:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 966:	fed7fae3          	bgeu	a5,a3,95a <free+0x36>
 96a:	6398                	ld	a4,0(a5)
 96c:	00e6e463          	bltu	a3,a4,974 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 970:	fee7eae3          	bltu	a5,a4,964 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 974:	ff852583          	lw	a1,-8(a0)
 978:	6390                	ld	a2,0(a5)
 97a:	02059713          	slli	a4,a1,0x20
 97e:	9301                	srli	a4,a4,0x20
 980:	0712                	slli	a4,a4,0x4
 982:	9736                	add	a4,a4,a3
 984:	fae60ae3          	beq	a2,a4,938 <free+0x14>
    bp->s.ptr = p->s.ptr;
 988:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 98c:	4790                	lw	a2,8(a5)
 98e:	02061713          	slli	a4,a2,0x20
 992:	9301                	srli	a4,a4,0x20
 994:	0712                	slli	a4,a4,0x4
 996:	973e                	add	a4,a4,a5
 998:	fae689e3          	beq	a3,a4,94a <free+0x26>
  } else
    p->s.ptr = bp;
 99c:	e394                	sd	a3,0(a5)
  freep = p;
 99e:	00000717          	auipc	a4,0x0
 9a2:	14f73d23          	sd	a5,346(a4) # af8 <freep>
}
 9a6:	6422                	ld	s0,8(sp)
 9a8:	0141                	addi	sp,sp,16
 9aa:	8082                	ret

00000000000009ac <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ac:	7139                	addi	sp,sp,-64
 9ae:	fc06                	sd	ra,56(sp)
 9b0:	f822                	sd	s0,48(sp)
 9b2:	f426                	sd	s1,40(sp)
 9b4:	f04a                	sd	s2,32(sp)
 9b6:	ec4e                	sd	s3,24(sp)
 9b8:	e852                	sd	s4,16(sp)
 9ba:	e456                	sd	s5,8(sp)
 9bc:	e05a                	sd	s6,0(sp)
 9be:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9c0:	02051493          	slli	s1,a0,0x20
 9c4:	9081                	srli	s1,s1,0x20
 9c6:	04bd                	addi	s1,s1,15
 9c8:	8091                	srli	s1,s1,0x4
 9ca:	0014899b          	addiw	s3,s1,1
 9ce:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9d0:	00000517          	auipc	a0,0x0
 9d4:	12853503          	ld	a0,296(a0) # af8 <freep>
 9d8:	c515                	beqz	a0,a04 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9dc:	4798                	lw	a4,8(a5)
 9de:	02977f63          	bgeu	a4,s1,a1c <malloc+0x70>
 9e2:	8a4e                	mv	s4,s3
 9e4:	0009871b          	sext.w	a4,s3
 9e8:	6685                	lui	a3,0x1
 9ea:	00d77363          	bgeu	a4,a3,9f0 <malloc+0x44>
 9ee:	6a05                	lui	s4,0x1
 9f0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9f4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9f8:	00000917          	auipc	s2,0x0
 9fc:	10090913          	addi	s2,s2,256 # af8 <freep>
  if(p == (char*)-1)
 a00:	5afd                	li	s5,-1
 a02:	a88d                	j	a74 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a04:	00000797          	auipc	a5,0x0
 a08:	7ac78793          	addi	a5,a5,1964 # 11b0 <base>
 a0c:	00000717          	auipc	a4,0x0
 a10:	0ef73623          	sd	a5,236(a4) # af8 <freep>
 a14:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a16:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a1a:	b7e1                	j	9e2 <malloc+0x36>
      if(p->s.size == nunits)
 a1c:	02e48b63          	beq	s1,a4,a52 <malloc+0xa6>
        p->s.size -= nunits;
 a20:	4137073b          	subw	a4,a4,s3
 a24:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a26:	1702                	slli	a4,a4,0x20
 a28:	9301                	srli	a4,a4,0x20
 a2a:	0712                	slli	a4,a4,0x4
 a2c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a2e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a32:	00000717          	auipc	a4,0x0
 a36:	0ca73323          	sd	a0,198(a4) # af8 <freep>
      return (void*)(p + 1);
 a3a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a3e:	70e2                	ld	ra,56(sp)
 a40:	7442                	ld	s0,48(sp)
 a42:	74a2                	ld	s1,40(sp)
 a44:	7902                	ld	s2,32(sp)
 a46:	69e2                	ld	s3,24(sp)
 a48:	6a42                	ld	s4,16(sp)
 a4a:	6aa2                	ld	s5,8(sp)
 a4c:	6b02                	ld	s6,0(sp)
 a4e:	6121                	addi	sp,sp,64
 a50:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a52:	6398                	ld	a4,0(a5)
 a54:	e118                	sd	a4,0(a0)
 a56:	bff1                	j	a32 <malloc+0x86>
  hp->s.size = nu;
 a58:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a5c:	0541                	addi	a0,a0,16
 a5e:	00000097          	auipc	ra,0x0
 a62:	ec6080e7          	jalr	-314(ra) # 924 <free>
  return freep;
 a66:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a6a:	d971                	beqz	a0,a3e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a6c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a6e:	4798                	lw	a4,8(a5)
 a70:	fa9776e3          	bgeu	a4,s1,a1c <malloc+0x70>
    if(p == freep)
 a74:	00093703          	ld	a4,0(s2)
 a78:	853e                	mv	a0,a5
 a7a:	fef719e3          	bne	a4,a5,a6c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a7e:	8552                	mv	a0,s4
 a80:	00000097          	auipc	ra,0x0
 a84:	a62080e7          	jalr	-1438(ra) # 4e2 <sbrk>
  if(p == (char*)-1)
 a88:	fd5518e3          	bne	a0,s5,a58 <malloc+0xac>
        return 0;
 a8c:	4501                	li	a0,0
 a8e:	bf45                	j	a3e <malloc+0x92>
