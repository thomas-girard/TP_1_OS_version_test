
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	711d                	addi	sp,sp,-96
 11c:	ec86                	sd	ra,88(sp)
 11e:	e8a2                	sd	s0,80(sp)
 120:	e4a6                	sd	s1,72(sp)
 122:	e0ca                	sd	s2,64(sp)
 124:	fc4e                	sd	s3,56(sp)
 126:	f852                	sd	s4,48(sp)
 128:	f456                	sd	s5,40(sp)
 12a:	f05a                	sd	s6,32(sp)
 12c:	ec5e                	sd	s7,24(sp)
 12e:	e862                	sd	s8,16(sp)
 130:	e466                	sd	s9,8(sp)
 132:	e06a                	sd	s10,0(sp)
 134:	1080                	addi	s0,sp,96
 136:	89aa                	mv	s3,a0
 138:	8bae                	mv	s7,a1
  m = 0;
 13a:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 13c:	3ff00c13          	li	s8,1023
 140:	00001b17          	auipc	s6,0x1
 144:	ac8b0b13          	addi	s6,s6,-1336 # c08 <buf>
    p = buf;
 148:	8d5a                	mv	s10,s6
        *q = '\n';
 14a:	4aa9                	li	s5,10
    p = buf;
 14c:	8cda                	mv	s9,s6
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 14e:	a099                	j	194 <grep+0x7a>
        *q = '\n';
 150:	01548023          	sb	s5,0(s1)
        write(1, p, q+1 - p);
 154:	00148613          	addi	a2,s1,1
 158:	4126063b          	subw	a2,a2,s2
 15c:	85ca                	mv	a1,s2
 15e:	4505                	li	a0,1
 160:	00000097          	auipc	ra,0x0
 164:	432080e7          	jalr	1074(ra) # 592 <write>
      p = q+1;
 168:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 16c:	45a9                	li	a1,10
 16e:	854a                	mv	a0,s2
 170:	00000097          	auipc	ra,0x0
 174:	1d6080e7          	jalr	470(ra) # 346 <strchr>
 178:	84aa                	mv	s1,a0
 17a:	c919                	beqz	a0,190 <grep+0x76>
      *q = 0;
 17c:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 180:	85ca                	mv	a1,s2
 182:	854e                	mv	a0,s3
 184:	00000097          	auipc	ra,0x0
 188:	f48080e7          	jalr	-184(ra) # cc <match>
 18c:	dd71                	beqz	a0,168 <grep+0x4e>
 18e:	b7c9                	j	150 <grep+0x36>
    if(m > 0){
 190:	03404563          	bgtz	s4,1ba <grep+0xa0>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 194:	414c063b          	subw	a2,s8,s4
 198:	014b05b3          	add	a1,s6,s4
 19c:	855e                	mv	a0,s7
 19e:	00000097          	auipc	ra,0x0
 1a2:	3ec080e7          	jalr	1004(ra) # 58a <read>
 1a6:	02a05663          	blez	a0,1d2 <grep+0xb8>
    m += n;
 1aa:	00aa0a3b          	addw	s4,s4,a0
    buf[m] = '\0';
 1ae:	014b07b3          	add	a5,s6,s4
 1b2:	00078023          	sb	zero,0(a5)
    p = buf;
 1b6:	8966                	mv	s2,s9
    while((q = strchr(p, '\n')) != 0){
 1b8:	bf55                	j	16c <grep+0x52>
      m -= p - buf;
 1ba:	416907b3          	sub	a5,s2,s6
 1be:	40fa0a3b          	subw	s4,s4,a5
      memmove(buf, p, m);
 1c2:	8652                	mv	a2,s4
 1c4:	85ca                	mv	a1,s2
 1c6:	856a                	mv	a0,s10
 1c8:	00000097          	auipc	ra,0x0
 1cc:	260080e7          	jalr	608(ra) # 428 <memmove>
 1d0:	b7d1                	j	194 <grep+0x7a>
}
 1d2:	60e6                	ld	ra,88(sp)
 1d4:	6446                	ld	s0,80(sp)
 1d6:	64a6                	ld	s1,72(sp)
 1d8:	6906                	ld	s2,64(sp)
 1da:	79e2                	ld	s3,56(sp)
 1dc:	7a42                	ld	s4,48(sp)
 1de:	7aa2                	ld	s5,40(sp)
 1e0:	7b02                	ld	s6,32(sp)
 1e2:	6be2                	ld	s7,24(sp)
 1e4:	6c42                	ld	s8,16(sp)
 1e6:	6ca2                	ld	s9,8(sp)
 1e8:	6d02                	ld	s10,0(sp)
 1ea:	6125                	addi	sp,sp,96
 1ec:	8082                	ret

00000000000001ee <main>:
{
 1ee:	7139                	addi	sp,sp,-64
 1f0:	fc06                	sd	ra,56(sp)
 1f2:	f822                	sd	s0,48(sp)
 1f4:	f426                	sd	s1,40(sp)
 1f6:	f04a                	sd	s2,32(sp)
 1f8:	ec4e                	sd	s3,24(sp)
 1fa:	e852                	sd	s4,16(sp)
 1fc:	e456                	sd	s5,8(sp)
 1fe:	0080                	addi	s0,sp,64
  if(argc <= 1){
 200:	4785                	li	a5,1
 202:	04a7de63          	bge	a5,a0,25e <main+0x70>
  pattern = argv[1];
 206:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 20a:	4789                	li	a5,2
 20c:	06a7d763          	bge	a5,a0,27a <main+0x8c>
 210:	01058913          	addi	s2,a1,16
 214:	ffd5099b          	addiw	s3,a0,-3
 218:	1982                	slli	s3,s3,0x20
 21a:	0209d993          	srli	s3,s3,0x20
 21e:	098e                	slli	s3,s3,0x3
 220:	05e1                	addi	a1,a1,24
 222:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 224:	4581                	li	a1,0
 226:	00093503          	ld	a0,0(s2)
 22a:	00000097          	auipc	ra,0x0
 22e:	388080e7          	jalr	904(ra) # 5b2 <open>
 232:	84aa                	mv	s1,a0
 234:	04054e63          	bltz	a0,290 <main+0xa2>
    grep(pattern, fd);
 238:	85aa                	mv	a1,a0
 23a:	8552                	mv	a0,s4
 23c:	00000097          	auipc	ra,0x0
 240:	ede080e7          	jalr	-290(ra) # 11a <grep>
    close(fd);
 244:	8526                	mv	a0,s1
 246:	00000097          	auipc	ra,0x0
 24a:	290080e7          	jalr	656(ra) # 4d6 <close>
  for(i = 2; i < argc; i++){
 24e:	0921                	addi	s2,s2,8
 250:	fd391ae3          	bne	s2,s3,224 <main+0x36>
  exit(0);
 254:	4501                	li	a0,0
 256:	00000097          	auipc	ra,0x0
 25a:	31c080e7          	jalr	796(ra) # 572 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 25e:	00001597          	auipc	a1,0x1
 262:	94a58593          	addi	a1,a1,-1718 # ba8 <malloc+0xe4>
 266:	4509                	li	a0,2
 268:	00000097          	auipc	ra,0x0
 26c:	770080e7          	jalr	1904(ra) # 9d8 <fprintf>
    exit(1);
 270:	4505                	li	a0,1
 272:	00000097          	auipc	ra,0x0
 276:	300080e7          	jalr	768(ra) # 572 <exit>
    grep(pattern, 0);
 27a:	4581                	li	a1,0
 27c:	8552                	mv	a0,s4
 27e:	00000097          	auipc	ra,0x0
 282:	e9c080e7          	jalr	-356(ra) # 11a <grep>
    exit(0);
 286:	4501                	li	a0,0
 288:	00000097          	auipc	ra,0x0
 28c:	2ea080e7          	jalr	746(ra) # 572 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 290:	00093583          	ld	a1,0(s2)
 294:	00001517          	auipc	a0,0x1
 298:	93450513          	addi	a0,a0,-1740 # bc8 <malloc+0x104>
 29c:	00000097          	auipc	ra,0x0
 2a0:	76a080e7          	jalr	1898(ra) # a06 <printf>
      exit(1);
 2a4:	4505                	li	a0,1
 2a6:	00000097          	auipc	ra,0x0
 2aa:	2cc080e7          	jalr	716(ra) # 572 <exit>

00000000000002ae <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2b4:	87aa                	mv	a5,a0
 2b6:	0585                	addi	a1,a1,1
 2b8:	0785                	addi	a5,a5,1
 2ba:	fff5c703          	lbu	a4,-1(a1)
 2be:	fee78fa3          	sb	a4,-1(a5)
 2c2:	fb75                	bnez	a4,2b6 <strcpy+0x8>
    ;
  return os;
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret

00000000000002ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e422                	sd	s0,8(sp)
 2ce:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2d0:	00054783          	lbu	a5,0(a0)
 2d4:	cb91                	beqz	a5,2e8 <strcmp+0x1e>
 2d6:	0005c703          	lbu	a4,0(a1)
 2da:	00f71763          	bne	a4,a5,2e8 <strcmp+0x1e>
    p++, q++;
 2de:	0505                	addi	a0,a0,1
 2e0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2e2:	00054783          	lbu	a5,0(a0)
 2e6:	fbe5                	bnez	a5,2d6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2e8:	0005c503          	lbu	a0,0(a1)
}
 2ec:	40a7853b          	subw	a0,a5,a0
 2f0:	6422                	ld	s0,8(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret

00000000000002f6 <strlen>:

uint
strlen(const char *s)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2fc:	00054783          	lbu	a5,0(a0)
 300:	cf91                	beqz	a5,31c <strlen+0x26>
 302:	0505                	addi	a0,a0,1
 304:	87aa                	mv	a5,a0
 306:	4685                	li	a3,1
 308:	9e89                	subw	a3,a3,a0
 30a:	00f6853b          	addw	a0,a3,a5
 30e:	0785                	addi	a5,a5,1
 310:	fff7c703          	lbu	a4,-1(a5)
 314:	fb7d                	bnez	a4,30a <strlen+0x14>
    ;
  return n;
}
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret
  for(n = 0; s[n]; n++)
 31c:	4501                	li	a0,0
 31e:	bfe5                	j	316 <strlen+0x20>

0000000000000320 <memset>:

void*
memset(void *dst, int c, uint n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e422                	sd	s0,8(sp)
 324:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 326:	ce09                	beqz	a2,340 <memset+0x20>
 328:	87aa                	mv	a5,a0
 32a:	fff6071b          	addiw	a4,a2,-1
 32e:	1702                	slli	a4,a4,0x20
 330:	9301                	srli	a4,a4,0x20
 332:	0705                	addi	a4,a4,1
 334:	972a                	add	a4,a4,a0
    cdst[i] = c;
 336:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 33a:	0785                	addi	a5,a5,1
 33c:	fee79de3          	bne	a5,a4,336 <memset+0x16>
  }
  return dst;
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret

0000000000000346 <strchr>:

char*
strchr(const char *s, char c)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 34c:	00054783          	lbu	a5,0(a0)
 350:	cb99                	beqz	a5,366 <strchr+0x20>
    if(*s == c)
 352:	00f58763          	beq	a1,a5,360 <strchr+0x1a>
  for(; *s; s++)
 356:	0505                	addi	a0,a0,1
 358:	00054783          	lbu	a5,0(a0)
 35c:	fbfd                	bnez	a5,352 <strchr+0xc>
      return (char*)s;
  return 0;
 35e:	4501                	li	a0,0
}
 360:	6422                	ld	s0,8(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
  return 0;
 366:	4501                	li	a0,0
 368:	bfe5                	j	360 <strchr+0x1a>

000000000000036a <gets>:

char*
gets(char *buf, int max)
{
 36a:	711d                	addi	sp,sp,-96
 36c:	ec86                	sd	ra,88(sp)
 36e:	e8a2                	sd	s0,80(sp)
 370:	e4a6                	sd	s1,72(sp)
 372:	e0ca                	sd	s2,64(sp)
 374:	fc4e                	sd	s3,56(sp)
 376:	f852                	sd	s4,48(sp)
 378:	f456                	sd	s5,40(sp)
 37a:	f05a                	sd	s6,32(sp)
 37c:	ec5e                	sd	s7,24(sp)
 37e:	1080                	addi	s0,sp,96
 380:	8baa                	mv	s7,a0
 382:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 384:	892a                	mv	s2,a0
 386:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 388:	4aa9                	li	s5,10
 38a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 38c:	89a6                	mv	s3,s1
 38e:	2485                	addiw	s1,s1,1
 390:	0344d863          	bge	s1,s4,3c0 <gets+0x56>
    cc = read(0, &c, 1);
 394:	4605                	li	a2,1
 396:	faf40593          	addi	a1,s0,-81
 39a:	4501                	li	a0,0
 39c:	00000097          	auipc	ra,0x0
 3a0:	1ee080e7          	jalr	494(ra) # 58a <read>
    if(cc < 1)
 3a4:	00a05e63          	blez	a0,3c0 <gets+0x56>
    buf[i++] = c;
 3a8:	faf44783          	lbu	a5,-81(s0)
 3ac:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3b0:	01578763          	beq	a5,s5,3be <gets+0x54>
 3b4:	0905                	addi	s2,s2,1
 3b6:	fd679be3          	bne	a5,s6,38c <gets+0x22>
  for(i=0; i+1 < max; ){
 3ba:	89a6                	mv	s3,s1
 3bc:	a011                	j	3c0 <gets+0x56>
 3be:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3c0:	99de                	add	s3,s3,s7
 3c2:	00098023          	sb	zero,0(s3)
  return buf;
}
 3c6:	855e                	mv	a0,s7
 3c8:	60e6                	ld	ra,88(sp)
 3ca:	6446                	ld	s0,80(sp)
 3cc:	64a6                	ld	s1,72(sp)
 3ce:	6906                	ld	s2,64(sp)
 3d0:	79e2                	ld	s3,56(sp)
 3d2:	7a42                	ld	s4,48(sp)
 3d4:	7aa2                	ld	s5,40(sp)
 3d6:	7b02                	ld	s6,32(sp)
 3d8:	6be2                	ld	s7,24(sp)
 3da:	6125                	addi	sp,sp,96
 3dc:	8082                	ret

00000000000003de <atoi>:
  return r;
}

int
atoi(const char *s)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e4:	00054603          	lbu	a2,0(a0)
 3e8:	fd06079b          	addiw	a5,a2,-48
 3ec:	0ff7f793          	andi	a5,a5,255
 3f0:	4725                	li	a4,9
 3f2:	02f76963          	bltu	a4,a5,424 <atoi+0x46>
 3f6:	86aa                	mv	a3,a0
  n = 0;
 3f8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3fa:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3fc:	0685                	addi	a3,a3,1
 3fe:	0025179b          	slliw	a5,a0,0x2
 402:	9fa9                	addw	a5,a5,a0
 404:	0017979b          	slliw	a5,a5,0x1
 408:	9fb1                	addw	a5,a5,a2
 40a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40e:	0006c603          	lbu	a2,0(a3)
 412:	fd06071b          	addiw	a4,a2,-48
 416:	0ff77713          	andi	a4,a4,255
 41a:	fee5f1e3          	bgeu	a1,a4,3fc <atoi+0x1e>
  return n;
}
 41e:	6422                	ld	s0,8(sp)
 420:	0141                	addi	sp,sp,16
 422:	8082                	ret
  n = 0;
 424:	4501                	li	a0,0
 426:	bfe5                	j	41e <atoi+0x40>

0000000000000428 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 428:	1141                	addi	sp,sp,-16
 42a:	e422                	sd	s0,8(sp)
 42c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42e:	02b57663          	bgeu	a0,a1,45a <memmove+0x32>
    while(n-- > 0)
 432:	02c05163          	blez	a2,454 <memmove+0x2c>
 436:	fff6079b          	addiw	a5,a2,-1
 43a:	1782                	slli	a5,a5,0x20
 43c:	9381                	srli	a5,a5,0x20
 43e:	0785                	addi	a5,a5,1
 440:	97aa                	add	a5,a5,a0
  dst = vdst;
 442:	872a                	mv	a4,a0
      *dst++ = *src++;
 444:	0585                	addi	a1,a1,1
 446:	0705                	addi	a4,a4,1
 448:	fff5c683          	lbu	a3,-1(a1)
 44c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 450:	fee79ae3          	bne	a5,a4,444 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 454:	6422                	ld	s0,8(sp)
 456:	0141                	addi	sp,sp,16
 458:	8082                	ret
    dst += n;
 45a:	00c50733          	add	a4,a0,a2
    src += n;
 45e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 460:	fec05ae3          	blez	a2,454 <memmove+0x2c>
 464:	fff6079b          	addiw	a5,a2,-1
 468:	1782                	slli	a5,a5,0x20
 46a:	9381                	srli	a5,a5,0x20
 46c:	fff7c793          	not	a5,a5
 470:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 472:	15fd                	addi	a1,a1,-1
 474:	177d                	addi	a4,a4,-1
 476:	0005c683          	lbu	a3,0(a1)
 47a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 47e:	fee79ae3          	bne	a5,a4,472 <memmove+0x4a>
 482:	bfc9                	j	454 <memmove+0x2c>

0000000000000484 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 484:	1141                	addi	sp,sp,-16
 486:	e422                	sd	s0,8(sp)
 488:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 48a:	ca05                	beqz	a2,4ba <memcmp+0x36>
 48c:	fff6069b          	addiw	a3,a2,-1
 490:	1682                	slli	a3,a3,0x20
 492:	9281                	srli	a3,a3,0x20
 494:	0685                	addi	a3,a3,1
 496:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 498:	00054783          	lbu	a5,0(a0)
 49c:	0005c703          	lbu	a4,0(a1)
 4a0:	00e79863          	bne	a5,a4,4b0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4a4:	0505                	addi	a0,a0,1
    p2++;
 4a6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a8:	fed518e3          	bne	a0,a3,498 <memcmp+0x14>
  }
  return 0;
 4ac:	4501                	li	a0,0
 4ae:	a019                	j	4b4 <memcmp+0x30>
      return *p1 - *p2;
 4b0:	40e7853b          	subw	a0,a5,a4
}
 4b4:	6422                	ld	s0,8(sp)
 4b6:	0141                	addi	sp,sp,16
 4b8:	8082                	ret
  return 0;
 4ba:	4501                	li	a0,0
 4bc:	bfe5                	j	4b4 <memcmp+0x30>

00000000000004be <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4be:	1141                	addi	sp,sp,-16
 4c0:	e406                	sd	ra,8(sp)
 4c2:	e022                	sd	s0,0(sp)
 4c4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c6:	00000097          	auipc	ra,0x0
 4ca:	f62080e7          	jalr	-158(ra) # 428 <memmove>
}
 4ce:	60a2                	ld	ra,8(sp)
 4d0:	6402                	ld	s0,0(sp)
 4d2:	0141                	addi	sp,sp,16
 4d4:	8082                	ret

00000000000004d6 <close>:

int close(int fd){
 4d6:	1101                	addi	sp,sp,-32
 4d8:	ec06                	sd	ra,24(sp)
 4da:	e822                	sd	s0,16(sp)
 4dc:	e426                	sd	s1,8(sp)
 4de:	1000                	addi	s0,sp,32
 4e0:	84aa                	mv	s1,a0
  fflush(fd);
 4e2:	00000097          	auipc	ra,0x0
 4e6:	2d4080e7          	jalr	724(ra) # 7b6 <fflush>
  char* buf = get_putc_buf(fd);
 4ea:	8526                	mv	a0,s1
 4ec:	00000097          	auipc	ra,0x0
 4f0:	14e080e7          	jalr	334(ra) # 63a <get_putc_buf>
  if(buf){
 4f4:	cd11                	beqz	a0,510 <close+0x3a>
    free(buf);
 4f6:	00000097          	auipc	ra,0x0
 4fa:	546080e7          	jalr	1350(ra) # a3c <free>
    putc_buf[fd] = 0;
 4fe:	00349713          	slli	a4,s1,0x3
 502:	00001797          	auipc	a5,0x1
 506:	b0678793          	addi	a5,a5,-1274 # 1008 <putc_buf>
 50a:	97ba                	add	a5,a5,a4
 50c:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 510:	8526                	mv	a0,s1
 512:	00000097          	auipc	ra,0x0
 516:	088080e7          	jalr	136(ra) # 59a <sclose>
}
 51a:	60e2                	ld	ra,24(sp)
 51c:	6442                	ld	s0,16(sp)
 51e:	64a2                	ld	s1,8(sp)
 520:	6105                	addi	sp,sp,32
 522:	8082                	ret

0000000000000524 <stat>:
{
 524:	1101                	addi	sp,sp,-32
 526:	ec06                	sd	ra,24(sp)
 528:	e822                	sd	s0,16(sp)
 52a:	e426                	sd	s1,8(sp)
 52c:	e04a                	sd	s2,0(sp)
 52e:	1000                	addi	s0,sp,32
 530:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 532:	4581                	li	a1,0
 534:	00000097          	auipc	ra,0x0
 538:	07e080e7          	jalr	126(ra) # 5b2 <open>
  if(fd < 0)
 53c:	02054563          	bltz	a0,566 <stat+0x42>
 540:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 542:	85ca                	mv	a1,s2
 544:	00000097          	auipc	ra,0x0
 548:	086080e7          	jalr	134(ra) # 5ca <fstat>
 54c:	892a                	mv	s2,a0
  close(fd);
 54e:	8526                	mv	a0,s1
 550:	00000097          	auipc	ra,0x0
 554:	f86080e7          	jalr	-122(ra) # 4d6 <close>
}
 558:	854a                	mv	a0,s2
 55a:	60e2                	ld	ra,24(sp)
 55c:	6442                	ld	s0,16(sp)
 55e:	64a2                	ld	s1,8(sp)
 560:	6902                	ld	s2,0(sp)
 562:	6105                	addi	sp,sp,32
 564:	8082                	ret
    return -1;
 566:	597d                	li	s2,-1
 568:	bfc5                	j	558 <stat+0x34>

000000000000056a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 56a:	4885                	li	a7,1
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <exit>:
.global exit
exit:
 li a7, SYS_exit
 572:	4889                	li	a7,2
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <wait>:
.global wait
wait:
 li a7, SYS_wait
 57a:	488d                	li	a7,3
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 582:	4891                	li	a7,4
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <read>:
.global read
read:
 li a7, SYS_read
 58a:	4895                	li	a7,5
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <write>:
.global write
write:
 li a7, SYS_write
 592:	48c1                	li	a7,16
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 59a:	48d5                	li	a7,21
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5a2:	4899                	li	a7,6
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <exec>:
.global exec
exec:
 li a7, SYS_exec
 5aa:	489d                	li	a7,7
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <open>:
.global open
open:
 li a7, SYS_open
 5b2:	48bd                	li	a7,15
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5ba:	48c5                	li	a7,17
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5c2:	48c9                	li	a7,18
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5ca:	48a1                	li	a7,8
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <link>:
.global link
link:
 li a7, SYS_link
 5d2:	48cd                	li	a7,19
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5da:	48d1                	li	a7,20
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5e2:	48a5                	li	a7,9
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <dup>:
.global dup
dup:
 li a7, SYS_dup
 5ea:	48a9                	li	a7,10
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5f2:	48ad                	li	a7,11
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5fa:	48b1                	li	a7,12
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 602:	48b5                	li	a7,13
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 60a:	48b9                	li	a7,14
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 612:	48d9                	li	a7,22
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <nice>:
.global nice
nice:
 li a7, SYS_nice
 61a:	48dd                	li	a7,23
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 622:	48e1                	li	a7,24
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 62a:	48e5                	li	a7,25
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 632:	48e9                	li	a7,26
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 63a:	1101                	addi	sp,sp,-32
 63c:	ec06                	sd	ra,24(sp)
 63e:	e822                	sd	s0,16(sp)
 640:	e426                	sd	s1,8(sp)
 642:	1000                	addi	s0,sp,32
 644:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 646:	00351713          	slli	a4,a0,0x3
 64a:	00001797          	auipc	a5,0x1
 64e:	9be78793          	addi	a5,a5,-1602 # 1008 <putc_buf>
 652:	97ba                	add	a5,a5,a4
 654:	6388                	ld	a0,0(a5)
  if(buf) {
 656:	c511                	beqz	a0,662 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 658:	60e2                	ld	ra,24(sp)
 65a:	6442                	ld	s0,16(sp)
 65c:	64a2                	ld	s1,8(sp)
 65e:	6105                	addi	sp,sp,32
 660:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 662:	6505                	lui	a0,0x1
 664:	00000097          	auipc	ra,0x0
 668:	460080e7          	jalr	1120(ra) # ac4 <malloc>
  putc_buf[fd] = buf;
 66c:	00001797          	auipc	a5,0x1
 670:	99c78793          	addi	a5,a5,-1636 # 1008 <putc_buf>
 674:	00349713          	slli	a4,s1,0x3
 678:	973e                	add	a4,a4,a5
 67a:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 67c:	048a                	slli	s1,s1,0x2
 67e:	94be                	add	s1,s1,a5
 680:	3204a023          	sw	zero,800(s1)
  return buf;
 684:	bfd1                	j	658 <get_putc_buf+0x1e>

0000000000000686 <putc>:

static void
putc(int fd, char c)
{
 686:	1101                	addi	sp,sp,-32
 688:	ec06                	sd	ra,24(sp)
 68a:	e822                	sd	s0,16(sp)
 68c:	e426                	sd	s1,8(sp)
 68e:	e04a                	sd	s2,0(sp)
 690:	1000                	addi	s0,sp,32
 692:	84aa                	mv	s1,a0
 694:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 696:	00000097          	auipc	ra,0x0
 69a:	fa4080e7          	jalr	-92(ra) # 63a <get_putc_buf>
  buf[putc_index[fd]++] = c;
 69e:	00249793          	slli	a5,s1,0x2
 6a2:	00001717          	auipc	a4,0x1
 6a6:	96670713          	addi	a4,a4,-1690 # 1008 <putc_buf>
 6aa:	973e                	add	a4,a4,a5
 6ac:	32072783          	lw	a5,800(a4)
 6b0:	0017869b          	addiw	a3,a5,1
 6b4:	32d72023          	sw	a3,800(a4)
 6b8:	97aa                	add	a5,a5,a0
 6ba:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 6be:	47a9                	li	a5,10
 6c0:	02f90463          	beq	s2,a5,6e8 <putc+0x62>
 6c4:	00249713          	slli	a4,s1,0x2
 6c8:	00001797          	auipc	a5,0x1
 6cc:	94078793          	addi	a5,a5,-1728 # 1008 <putc_buf>
 6d0:	97ba                	add	a5,a5,a4
 6d2:	3207a703          	lw	a4,800(a5)
 6d6:	6785                	lui	a5,0x1
 6d8:	00f70863          	beq	a4,a5,6e8 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 6dc:	60e2                	ld	ra,24(sp)
 6de:	6442                	ld	s0,16(sp)
 6e0:	64a2                	ld	s1,8(sp)
 6e2:	6902                	ld	s2,0(sp)
 6e4:	6105                	addi	sp,sp,32
 6e6:	8082                	ret
    write(fd, buf, putc_index[fd]);
 6e8:	00249793          	slli	a5,s1,0x2
 6ec:	00001917          	auipc	s2,0x1
 6f0:	91c90913          	addi	s2,s2,-1764 # 1008 <putc_buf>
 6f4:	993e                	add	s2,s2,a5
 6f6:	32092603          	lw	a2,800(s2)
 6fa:	85aa                	mv	a1,a0
 6fc:	8526                	mv	a0,s1
 6fe:	00000097          	auipc	ra,0x0
 702:	e94080e7          	jalr	-364(ra) # 592 <write>
    putc_index[fd] = 0;
 706:	32092023          	sw	zero,800(s2)
}
 70a:	bfc9                	j	6dc <putc+0x56>

000000000000070c <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 70c:	7139                	addi	sp,sp,-64
 70e:	fc06                	sd	ra,56(sp)
 710:	f822                	sd	s0,48(sp)
 712:	f426                	sd	s1,40(sp)
 714:	f04a                	sd	s2,32(sp)
 716:	ec4e                	sd	s3,24(sp)
 718:	0080                	addi	s0,sp,64
 71a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 71c:	c299                	beqz	a3,722 <printint+0x16>
 71e:	0805c863          	bltz	a1,7ae <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 722:	2581                	sext.w	a1,a1
  neg = 0;
 724:	4881                	li	a7,0
 726:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 72a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 72c:	2601                	sext.w	a2,a2
 72e:	00000517          	auipc	a0,0x0
 732:	4ba50513          	addi	a0,a0,1210 # be8 <digits>
 736:	883a                	mv	a6,a4
 738:	2705                	addiw	a4,a4,1
 73a:	02c5f7bb          	remuw	a5,a1,a2
 73e:	1782                	slli	a5,a5,0x20
 740:	9381                	srli	a5,a5,0x20
 742:	97aa                	add	a5,a5,a0
 744:	0007c783          	lbu	a5,0(a5) # 1000 <buf+0x3f8>
 748:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 74c:	0005879b          	sext.w	a5,a1
 750:	02c5d5bb          	divuw	a1,a1,a2
 754:	0685                	addi	a3,a3,1
 756:	fec7f0e3          	bgeu	a5,a2,736 <printint+0x2a>
  if(neg)
 75a:	00088b63          	beqz	a7,770 <printint+0x64>
    buf[i++] = '-';
 75e:	fd040793          	addi	a5,s0,-48
 762:	973e                	add	a4,a4,a5
 764:	02d00793          	li	a5,45
 768:	fef70823          	sb	a5,-16(a4)
 76c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 770:	02e05863          	blez	a4,7a0 <printint+0x94>
 774:	fc040793          	addi	a5,s0,-64
 778:	00e78933          	add	s2,a5,a4
 77c:	fff78993          	addi	s3,a5,-1
 780:	99ba                	add	s3,s3,a4
 782:	377d                	addiw	a4,a4,-1
 784:	1702                	slli	a4,a4,0x20
 786:	9301                	srli	a4,a4,0x20
 788:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 78c:	fff94583          	lbu	a1,-1(s2)
 790:	8526                	mv	a0,s1
 792:	00000097          	auipc	ra,0x0
 796:	ef4080e7          	jalr	-268(ra) # 686 <putc>
  while(--i >= 0)
 79a:	197d                	addi	s2,s2,-1
 79c:	ff3918e3          	bne	s2,s3,78c <printint+0x80>
}
 7a0:	70e2                	ld	ra,56(sp)
 7a2:	7442                	ld	s0,48(sp)
 7a4:	74a2                	ld	s1,40(sp)
 7a6:	7902                	ld	s2,32(sp)
 7a8:	69e2                	ld	s3,24(sp)
 7aa:	6121                	addi	sp,sp,64
 7ac:	8082                	ret
    x = -xx;
 7ae:	40b005bb          	negw	a1,a1
    neg = 1;
 7b2:	4885                	li	a7,1
    x = -xx;
 7b4:	bf8d                	j	726 <printint+0x1a>

00000000000007b6 <fflush>:
void fflush(int fd){
 7b6:	1101                	addi	sp,sp,-32
 7b8:	ec06                	sd	ra,24(sp)
 7ba:	e822                	sd	s0,16(sp)
 7bc:	e426                	sd	s1,8(sp)
 7be:	e04a                	sd	s2,0(sp)
 7c0:	1000                	addi	s0,sp,32
 7c2:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 7c4:	00000097          	auipc	ra,0x0
 7c8:	e76080e7          	jalr	-394(ra) # 63a <get_putc_buf>
 7cc:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 7ce:	00291793          	slli	a5,s2,0x2
 7d2:	00001497          	auipc	s1,0x1
 7d6:	83648493          	addi	s1,s1,-1994 # 1008 <putc_buf>
 7da:	94be                	add	s1,s1,a5
 7dc:	3204a603          	lw	a2,800(s1)
 7e0:	854a                	mv	a0,s2
 7e2:	00000097          	auipc	ra,0x0
 7e6:	db0080e7          	jalr	-592(ra) # 592 <write>
  putc_index[fd] = 0;
 7ea:	3204a023          	sw	zero,800(s1)
}
 7ee:	60e2                	ld	ra,24(sp)
 7f0:	6442                	ld	s0,16(sp)
 7f2:	64a2                	ld	s1,8(sp)
 7f4:	6902                	ld	s2,0(sp)
 7f6:	6105                	addi	sp,sp,32
 7f8:	8082                	ret

00000000000007fa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7fa:	7119                	addi	sp,sp,-128
 7fc:	fc86                	sd	ra,120(sp)
 7fe:	f8a2                	sd	s0,112(sp)
 800:	f4a6                	sd	s1,104(sp)
 802:	f0ca                	sd	s2,96(sp)
 804:	ecce                	sd	s3,88(sp)
 806:	e8d2                	sd	s4,80(sp)
 808:	e4d6                	sd	s5,72(sp)
 80a:	e0da                	sd	s6,64(sp)
 80c:	fc5e                	sd	s7,56(sp)
 80e:	f862                	sd	s8,48(sp)
 810:	f466                	sd	s9,40(sp)
 812:	f06a                	sd	s10,32(sp)
 814:	ec6e                	sd	s11,24(sp)
 816:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 818:	0005c903          	lbu	s2,0(a1)
 81c:	18090f63          	beqz	s2,9ba <vprintf+0x1c0>
 820:	8aaa                	mv	s5,a0
 822:	8b32                	mv	s6,a2
 824:	00158493          	addi	s1,a1,1
  state = 0;
 828:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 82a:	02500a13          	li	s4,37
      if(c == 'd'){
 82e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 832:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 836:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 83a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 83e:	00000b97          	auipc	s7,0x0
 842:	3aab8b93          	addi	s7,s7,938 # be8 <digits>
 846:	a839                	j	864 <vprintf+0x6a>
        putc(fd, c);
 848:	85ca                	mv	a1,s2
 84a:	8556                	mv	a0,s5
 84c:	00000097          	auipc	ra,0x0
 850:	e3a080e7          	jalr	-454(ra) # 686 <putc>
 854:	a019                	j	85a <vprintf+0x60>
    } else if(state == '%'){
 856:	01498f63          	beq	s3,s4,874 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 85a:	0485                	addi	s1,s1,1
 85c:	fff4c903          	lbu	s2,-1(s1)
 860:	14090d63          	beqz	s2,9ba <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 864:	0009079b          	sext.w	a5,s2
    if(state == 0){
 868:	fe0997e3          	bnez	s3,856 <vprintf+0x5c>
      if(c == '%'){
 86c:	fd479ee3          	bne	a5,s4,848 <vprintf+0x4e>
        state = '%';
 870:	89be                	mv	s3,a5
 872:	b7e5                	j	85a <vprintf+0x60>
      if(c == 'd'){
 874:	05878063          	beq	a5,s8,8b4 <vprintf+0xba>
      } else if(c == 'l') {
 878:	05978c63          	beq	a5,s9,8d0 <vprintf+0xd6>
      } else if(c == 'x') {
 87c:	07a78863          	beq	a5,s10,8ec <vprintf+0xf2>
      } else if(c == 'p') {
 880:	09b78463          	beq	a5,s11,908 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 884:	07300713          	li	a4,115
 888:	0ce78663          	beq	a5,a4,954 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 88c:	06300713          	li	a4,99
 890:	0ee78e63          	beq	a5,a4,98c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 894:	11478863          	beq	a5,s4,9a4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 898:	85d2                	mv	a1,s4
 89a:	8556                	mv	a0,s5
 89c:	00000097          	auipc	ra,0x0
 8a0:	dea080e7          	jalr	-534(ra) # 686 <putc>
        putc(fd, c);
 8a4:	85ca                	mv	a1,s2
 8a6:	8556                	mv	a0,s5
 8a8:	00000097          	auipc	ra,0x0
 8ac:	dde080e7          	jalr	-546(ra) # 686 <putc>
      }
      state = 0;
 8b0:	4981                	li	s3,0
 8b2:	b765                	j	85a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 8b4:	008b0913          	addi	s2,s6,8
 8b8:	4685                	li	a3,1
 8ba:	4629                	li	a2,10
 8bc:	000b2583          	lw	a1,0(s6)
 8c0:	8556                	mv	a0,s5
 8c2:	00000097          	auipc	ra,0x0
 8c6:	e4a080e7          	jalr	-438(ra) # 70c <printint>
 8ca:	8b4a                	mv	s6,s2
      state = 0;
 8cc:	4981                	li	s3,0
 8ce:	b771                	j	85a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d0:	008b0913          	addi	s2,s6,8
 8d4:	4681                	li	a3,0
 8d6:	4629                	li	a2,10
 8d8:	000b2583          	lw	a1,0(s6)
 8dc:	8556                	mv	a0,s5
 8de:	00000097          	auipc	ra,0x0
 8e2:	e2e080e7          	jalr	-466(ra) # 70c <printint>
 8e6:	8b4a                	mv	s6,s2
      state = 0;
 8e8:	4981                	li	s3,0
 8ea:	bf85                	j	85a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 8ec:	008b0913          	addi	s2,s6,8
 8f0:	4681                	li	a3,0
 8f2:	4641                	li	a2,16
 8f4:	000b2583          	lw	a1,0(s6)
 8f8:	8556                	mv	a0,s5
 8fa:	00000097          	auipc	ra,0x0
 8fe:	e12080e7          	jalr	-494(ra) # 70c <printint>
 902:	8b4a                	mv	s6,s2
      state = 0;
 904:	4981                	li	s3,0
 906:	bf91                	j	85a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 908:	008b0793          	addi	a5,s6,8
 90c:	f8f43423          	sd	a5,-120(s0)
 910:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 914:	03000593          	li	a1,48
 918:	8556                	mv	a0,s5
 91a:	00000097          	auipc	ra,0x0
 91e:	d6c080e7          	jalr	-660(ra) # 686 <putc>
  putc(fd, 'x');
 922:	85ea                	mv	a1,s10
 924:	8556                	mv	a0,s5
 926:	00000097          	auipc	ra,0x0
 92a:	d60080e7          	jalr	-672(ra) # 686 <putc>
 92e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 930:	03c9d793          	srli	a5,s3,0x3c
 934:	97de                	add	a5,a5,s7
 936:	0007c583          	lbu	a1,0(a5)
 93a:	8556                	mv	a0,s5
 93c:	00000097          	auipc	ra,0x0
 940:	d4a080e7          	jalr	-694(ra) # 686 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 944:	0992                	slli	s3,s3,0x4
 946:	397d                	addiw	s2,s2,-1
 948:	fe0914e3          	bnez	s2,930 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 94c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 950:	4981                	li	s3,0
 952:	b721                	j	85a <vprintf+0x60>
        s = va_arg(ap, char*);
 954:	008b0993          	addi	s3,s6,8
 958:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 95c:	02090163          	beqz	s2,97e <vprintf+0x184>
        while(*s != 0){
 960:	00094583          	lbu	a1,0(s2)
 964:	c9a1                	beqz	a1,9b4 <vprintf+0x1ba>
          putc(fd, *s);
 966:	8556                	mv	a0,s5
 968:	00000097          	auipc	ra,0x0
 96c:	d1e080e7          	jalr	-738(ra) # 686 <putc>
          s++;
 970:	0905                	addi	s2,s2,1
        while(*s != 0){
 972:	00094583          	lbu	a1,0(s2)
 976:	f9e5                	bnez	a1,966 <vprintf+0x16c>
        s = va_arg(ap, char*);
 978:	8b4e                	mv	s6,s3
      state = 0;
 97a:	4981                	li	s3,0
 97c:	bdf9                	j	85a <vprintf+0x60>
          s = "(null)";
 97e:	00000917          	auipc	s2,0x0
 982:	26290913          	addi	s2,s2,610 # be0 <malloc+0x11c>
        while(*s != 0){
 986:	02800593          	li	a1,40
 98a:	bff1                	j	966 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 98c:	008b0913          	addi	s2,s6,8
 990:	000b4583          	lbu	a1,0(s6)
 994:	8556                	mv	a0,s5
 996:	00000097          	auipc	ra,0x0
 99a:	cf0080e7          	jalr	-784(ra) # 686 <putc>
 99e:	8b4a                	mv	s6,s2
      state = 0;
 9a0:	4981                	li	s3,0
 9a2:	bd65                	j	85a <vprintf+0x60>
        putc(fd, c);
 9a4:	85d2                	mv	a1,s4
 9a6:	8556                	mv	a0,s5
 9a8:	00000097          	auipc	ra,0x0
 9ac:	cde080e7          	jalr	-802(ra) # 686 <putc>
      state = 0;
 9b0:	4981                	li	s3,0
 9b2:	b565                	j	85a <vprintf+0x60>
        s = va_arg(ap, char*);
 9b4:	8b4e                	mv	s6,s3
      state = 0;
 9b6:	4981                	li	s3,0
 9b8:	b54d                	j	85a <vprintf+0x60>
    }
  }
}
 9ba:	70e6                	ld	ra,120(sp)
 9bc:	7446                	ld	s0,112(sp)
 9be:	74a6                	ld	s1,104(sp)
 9c0:	7906                	ld	s2,96(sp)
 9c2:	69e6                	ld	s3,88(sp)
 9c4:	6a46                	ld	s4,80(sp)
 9c6:	6aa6                	ld	s5,72(sp)
 9c8:	6b06                	ld	s6,64(sp)
 9ca:	7be2                	ld	s7,56(sp)
 9cc:	7c42                	ld	s8,48(sp)
 9ce:	7ca2                	ld	s9,40(sp)
 9d0:	7d02                	ld	s10,32(sp)
 9d2:	6de2                	ld	s11,24(sp)
 9d4:	6109                	addi	sp,sp,128
 9d6:	8082                	ret

00000000000009d8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9d8:	715d                	addi	sp,sp,-80
 9da:	ec06                	sd	ra,24(sp)
 9dc:	e822                	sd	s0,16(sp)
 9de:	1000                	addi	s0,sp,32
 9e0:	e010                	sd	a2,0(s0)
 9e2:	e414                	sd	a3,8(s0)
 9e4:	e818                	sd	a4,16(s0)
 9e6:	ec1c                	sd	a5,24(s0)
 9e8:	03043023          	sd	a6,32(s0)
 9ec:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9f0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9f4:	8622                	mv	a2,s0
 9f6:	00000097          	auipc	ra,0x0
 9fa:	e04080e7          	jalr	-508(ra) # 7fa <vprintf>
}
 9fe:	60e2                	ld	ra,24(sp)
 a00:	6442                	ld	s0,16(sp)
 a02:	6161                	addi	sp,sp,80
 a04:	8082                	ret

0000000000000a06 <printf>:

void
printf(const char *fmt, ...)
{
 a06:	711d                	addi	sp,sp,-96
 a08:	ec06                	sd	ra,24(sp)
 a0a:	e822                	sd	s0,16(sp)
 a0c:	1000                	addi	s0,sp,32
 a0e:	e40c                	sd	a1,8(s0)
 a10:	e810                	sd	a2,16(s0)
 a12:	ec14                	sd	a3,24(s0)
 a14:	f018                	sd	a4,32(s0)
 a16:	f41c                	sd	a5,40(s0)
 a18:	03043823          	sd	a6,48(s0)
 a1c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a20:	00840613          	addi	a2,s0,8
 a24:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a28:	85aa                	mv	a1,a0
 a2a:	4505                	li	a0,1
 a2c:	00000097          	auipc	ra,0x0
 a30:	dce080e7          	jalr	-562(ra) # 7fa <vprintf>
}
 a34:	60e2                	ld	ra,24(sp)
 a36:	6442                	ld	s0,16(sp)
 a38:	6125                	addi	sp,sp,96
 a3a:	8082                	ret

0000000000000a3c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a3c:	1141                	addi	sp,sp,-16
 a3e:	e422                	sd	s0,8(sp)
 a40:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a42:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a46:	00000797          	auipc	a5,0x0
 a4a:	1ba7b783          	ld	a5,442(a5) # c00 <freep>
 a4e:	a805                	j	a7e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a50:	4618                	lw	a4,8(a2)
 a52:	9db9                	addw	a1,a1,a4
 a54:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a58:	6398                	ld	a4,0(a5)
 a5a:	6318                	ld	a4,0(a4)
 a5c:	fee53823          	sd	a4,-16(a0)
 a60:	a091                	j	aa4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a62:	ff852703          	lw	a4,-8(a0)
 a66:	9e39                	addw	a2,a2,a4
 a68:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a6a:	ff053703          	ld	a4,-16(a0)
 a6e:	e398                	sd	a4,0(a5)
 a70:	a099                	j	ab6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a72:	6398                	ld	a4,0(a5)
 a74:	00e7e463          	bltu	a5,a4,a7c <free+0x40>
 a78:	00e6ea63          	bltu	a3,a4,a8c <free+0x50>
{
 a7c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a7e:	fed7fae3          	bgeu	a5,a3,a72 <free+0x36>
 a82:	6398                	ld	a4,0(a5)
 a84:	00e6e463          	bltu	a3,a4,a8c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a88:	fee7eae3          	bltu	a5,a4,a7c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a8c:	ff852583          	lw	a1,-8(a0)
 a90:	6390                	ld	a2,0(a5)
 a92:	02059713          	slli	a4,a1,0x20
 a96:	9301                	srli	a4,a4,0x20
 a98:	0712                	slli	a4,a4,0x4
 a9a:	9736                	add	a4,a4,a3
 a9c:	fae60ae3          	beq	a2,a4,a50 <free+0x14>
    bp->s.ptr = p->s.ptr;
 aa0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 aa4:	4790                	lw	a2,8(a5)
 aa6:	02061713          	slli	a4,a2,0x20
 aaa:	9301                	srli	a4,a4,0x20
 aac:	0712                	slli	a4,a4,0x4
 aae:	973e                	add	a4,a4,a5
 ab0:	fae689e3          	beq	a3,a4,a62 <free+0x26>
  } else
    p->s.ptr = bp;
 ab4:	e394                	sd	a3,0(a5)
  freep = p;
 ab6:	00000717          	auipc	a4,0x0
 aba:	14f73523          	sd	a5,330(a4) # c00 <freep>
}
 abe:	6422                	ld	s0,8(sp)
 ac0:	0141                	addi	sp,sp,16
 ac2:	8082                	ret

0000000000000ac4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ac4:	7139                	addi	sp,sp,-64
 ac6:	fc06                	sd	ra,56(sp)
 ac8:	f822                	sd	s0,48(sp)
 aca:	f426                	sd	s1,40(sp)
 acc:	f04a                	sd	s2,32(sp)
 ace:	ec4e                	sd	s3,24(sp)
 ad0:	e852                	sd	s4,16(sp)
 ad2:	e456                	sd	s5,8(sp)
 ad4:	e05a                	sd	s6,0(sp)
 ad6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ad8:	02051493          	slli	s1,a0,0x20
 adc:	9081                	srli	s1,s1,0x20
 ade:	04bd                	addi	s1,s1,15
 ae0:	8091                	srli	s1,s1,0x4
 ae2:	0014899b          	addiw	s3,s1,1
 ae6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ae8:	00000517          	auipc	a0,0x0
 aec:	11853503          	ld	a0,280(a0) # c00 <freep>
 af0:	c515                	beqz	a0,b1c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 af2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 af4:	4798                	lw	a4,8(a5)
 af6:	02977f63          	bgeu	a4,s1,b34 <malloc+0x70>
 afa:	8a4e                	mv	s4,s3
 afc:	0009871b          	sext.w	a4,s3
 b00:	6685                	lui	a3,0x1
 b02:	00d77363          	bgeu	a4,a3,b08 <malloc+0x44>
 b06:	6a05                	lui	s4,0x1
 b08:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b0c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b10:	00000917          	auipc	s2,0x0
 b14:	0f090913          	addi	s2,s2,240 # c00 <freep>
  if(p == (char*)-1)
 b18:	5afd                	li	s5,-1
 b1a:	a88d                	j	b8c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 b1c:	00001797          	auipc	a5,0x1
 b20:	99c78793          	addi	a5,a5,-1636 # 14b8 <base>
 b24:	00000717          	auipc	a4,0x0
 b28:	0cf73e23          	sd	a5,220(a4) # c00 <freep>
 b2c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b2e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b32:	b7e1                	j	afa <malloc+0x36>
      if(p->s.size == nunits)
 b34:	02e48b63          	beq	s1,a4,b6a <malloc+0xa6>
        p->s.size -= nunits;
 b38:	4137073b          	subw	a4,a4,s3
 b3c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b3e:	1702                	slli	a4,a4,0x20
 b40:	9301                	srli	a4,a4,0x20
 b42:	0712                	slli	a4,a4,0x4
 b44:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b46:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b4a:	00000717          	auipc	a4,0x0
 b4e:	0aa73b23          	sd	a0,182(a4) # c00 <freep>
      return (void*)(p + 1);
 b52:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b56:	70e2                	ld	ra,56(sp)
 b58:	7442                	ld	s0,48(sp)
 b5a:	74a2                	ld	s1,40(sp)
 b5c:	7902                	ld	s2,32(sp)
 b5e:	69e2                	ld	s3,24(sp)
 b60:	6a42                	ld	s4,16(sp)
 b62:	6aa2                	ld	s5,8(sp)
 b64:	6b02                	ld	s6,0(sp)
 b66:	6121                	addi	sp,sp,64
 b68:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b6a:	6398                	ld	a4,0(a5)
 b6c:	e118                	sd	a4,0(a0)
 b6e:	bff1                	j	b4a <malloc+0x86>
  hp->s.size = nu;
 b70:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b74:	0541                	addi	a0,a0,16
 b76:	00000097          	auipc	ra,0x0
 b7a:	ec6080e7          	jalr	-314(ra) # a3c <free>
  return freep;
 b7e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b82:	d971                	beqz	a0,b56 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b84:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b86:	4798                	lw	a4,8(a5)
 b88:	fa9776e3          	bgeu	a4,s1,b34 <malloc+0x70>
    if(p == freep)
 b8c:	00093703          	ld	a4,0(s2)
 b90:	853e                	mv	a0,a5
 b92:	fef719e3          	bne	a4,a5,b84 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 b96:	8552                	mv	a0,s4
 b98:	00000097          	auipc	ra,0x0
 b9c:	a62080e7          	jalr	-1438(ra) # 5fa <sbrk>
  if(p == (char*)-1)
 ba0:	fd5518e3          	bne	a0,s5,b70 <malloc+0xac>
        return 0;
 ba4:	4501                	li	a0,0
 ba6:	bf45                	j	b56 <malloc+0x92>
