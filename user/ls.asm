
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	30c080e7          	jalr	780(ra) # 31c <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	2e0080e7          	jalr	736(ra) # 31c <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	2be080e7          	jalr	702(ra) # 31c <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	c0298993          	addi	s3,s3,-1022 # c68 <buf.1132>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	3d8080e7          	jalr	984(ra) # 44e <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	29c080e7          	jalr	668(ra) # 31c <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	28e080e7          	jalr	654(ra) # 31c <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	29e080e7          	jalr	670(ra) # 346 <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	addi	s0,sp,624
  d6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  d8:	4581                	li	a1,0
  da:	00000097          	auipc	ra,0x0
  de:	4fe080e7          	jalr	1278(ra) # 5d8 <open>
  e2:	06054f63          	bltz	a0,160 <ls+0xac>
  e6:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  e8:	d9840593          	addi	a1,s0,-616
  ec:	00000097          	auipc	ra,0x0
  f0:	504080e7          	jalr	1284(ra) # 5f0 <fstat>
  f4:	08054163          	bltz	a0,176 <ls+0xc2>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  f8:	da041783          	lh	a5,-608(s0)
  fc:	0007869b          	sext.w	a3,a5
 100:	4705                	li	a4,1
 102:	08e68a63          	beq	a3,a4,196 <ls+0xe2>
 106:	4709                	li	a4,2
 108:	02e69663          	bne	a3,a4,134 <ls+0x80>
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 10c:	854a                	mv	a0,s2
 10e:	00000097          	auipc	ra,0x0
 112:	ef2080e7          	jalr	-270(ra) # 0 <fmtname>
 116:	85aa                	mv	a1,a0
 118:	da843703          	ld	a4,-600(s0)
 11c:	d9c42683          	lw	a3,-612(s0)
 120:	da041603          	lh	a2,-608(s0)
 124:	00001517          	auipc	a0,0x1
 128:	adc50513          	addi	a0,a0,-1316 # c00 <malloc+0x116>
 12c:	00001097          	auipc	ra,0x1
 130:	900080e7          	jalr	-1792(ra) # a2c <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 134:	8526                	mv	a0,s1
 136:	00000097          	auipc	ra,0x0
 13a:	3c6080e7          	jalr	966(ra) # 4fc <close>
}
 13e:	26813083          	ld	ra,616(sp)
 142:	26013403          	ld	s0,608(sp)
 146:	25813483          	ld	s1,600(sp)
 14a:	25013903          	ld	s2,592(sp)
 14e:	24813983          	ld	s3,584(sp)
 152:	24013a03          	ld	s4,576(sp)
 156:	23813a83          	ld	s5,568(sp)
 15a:	27010113          	addi	sp,sp,624
 15e:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 160:	864a                	mv	a2,s2
 162:	00001597          	auipc	a1,0x1
 166:	a6e58593          	addi	a1,a1,-1426 # bd0 <malloc+0xe6>
 16a:	4509                	li	a0,2
 16c:	00001097          	auipc	ra,0x1
 170:	892080e7          	jalr	-1902(ra) # 9fe <fprintf>
    return;
 174:	b7e9                	j	13e <ls+0x8a>
    fprintf(2, "ls: cannot stat %s\n", path);
 176:	864a                	mv	a2,s2
 178:	00001597          	auipc	a1,0x1
 17c:	a7058593          	addi	a1,a1,-1424 # be8 <malloc+0xfe>
 180:	4509                	li	a0,2
 182:	00001097          	auipc	ra,0x1
 186:	87c080e7          	jalr	-1924(ra) # 9fe <fprintf>
    close(fd);
 18a:	8526                	mv	a0,s1
 18c:	00000097          	auipc	ra,0x0
 190:	370080e7          	jalr	880(ra) # 4fc <close>
    return;
 194:	b76d                	j	13e <ls+0x8a>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 196:	854a                	mv	a0,s2
 198:	00000097          	auipc	ra,0x0
 19c:	184080e7          	jalr	388(ra) # 31c <strlen>
 1a0:	2541                	addiw	a0,a0,16
 1a2:	20000793          	li	a5,512
 1a6:	00a7fb63          	bgeu	a5,a0,1bc <ls+0x108>
      printf("ls: path too long\n");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	a6650513          	addi	a0,a0,-1434 # c10 <malloc+0x126>
 1b2:	00001097          	auipc	ra,0x1
 1b6:	87a080e7          	jalr	-1926(ra) # a2c <printf>
      break;
 1ba:	bfad                	j	134 <ls+0x80>
    strcpy(buf, path);
 1bc:	85ca                	mv	a1,s2
 1be:	dc040513          	addi	a0,s0,-576
 1c2:	00000097          	auipc	ra,0x0
 1c6:	112080e7          	jalr	274(ra) # 2d4 <strcpy>
    p = buf+strlen(buf);
 1ca:	dc040513          	addi	a0,s0,-576
 1ce:	00000097          	auipc	ra,0x0
 1d2:	14e080e7          	jalr	334(ra) # 31c <strlen>
 1d6:	02051913          	slli	s2,a0,0x20
 1da:	02095913          	srli	s2,s2,0x20
 1de:	dc040793          	addi	a5,s0,-576
 1e2:	993e                	add	s2,s2,a5
    *p++ = '/';
 1e4:	00190993          	addi	s3,s2,1
 1e8:	02f00793          	li	a5,47
 1ec:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 1f0:	00001a17          	auipc	s4,0x1
 1f4:	a38a0a13          	addi	s4,s4,-1480 # c28 <malloc+0x13e>
        printf("ls: cannot stat %s\n", buf);
 1f8:	00001a97          	auipc	s5,0x1
 1fc:	9f0a8a93          	addi	s5,s5,-1552 # be8 <malloc+0xfe>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 200:	a801                	j	210 <ls+0x15c>
        printf("ls: cannot stat %s\n", buf);
 202:	dc040593          	addi	a1,s0,-576
 206:	8556                	mv	a0,s5
 208:	00001097          	auipc	ra,0x1
 20c:	824080e7          	jalr	-2012(ra) # a2c <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 210:	4641                	li	a2,16
 212:	db040593          	addi	a1,s0,-592
 216:	8526                	mv	a0,s1
 218:	00000097          	auipc	ra,0x0
 21c:	398080e7          	jalr	920(ra) # 5b0 <read>
 220:	47c1                	li	a5,16
 222:	f0f519e3          	bne	a0,a5,134 <ls+0x80>
      if(de.inum == 0)
 226:	db045783          	lhu	a5,-592(s0)
 22a:	d3fd                	beqz	a5,210 <ls+0x15c>
      memmove(p, de.name, DIRSIZ);
 22c:	4639                	li	a2,14
 22e:	db240593          	addi	a1,s0,-590
 232:	854e                	mv	a0,s3
 234:	00000097          	auipc	ra,0x0
 238:	21a080e7          	jalr	538(ra) # 44e <memmove>
      p[DIRSIZ] = 0;
 23c:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 240:	d9840593          	addi	a1,s0,-616
 244:	dc040513          	addi	a0,s0,-576
 248:	00000097          	auipc	ra,0x0
 24c:	302080e7          	jalr	770(ra) # 54a <stat>
 250:	fa0549e3          	bltz	a0,202 <ls+0x14e>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 254:	dc040513          	addi	a0,s0,-576
 258:	00000097          	auipc	ra,0x0
 25c:	da8080e7          	jalr	-600(ra) # 0 <fmtname>
 260:	85aa                	mv	a1,a0
 262:	da843703          	ld	a4,-600(s0)
 266:	d9c42683          	lw	a3,-612(s0)
 26a:	da041603          	lh	a2,-608(s0)
 26e:	8552                	mv	a0,s4
 270:	00000097          	auipc	ra,0x0
 274:	7bc080e7          	jalr	1980(ra) # a2c <printf>
 278:	bf61                	j	210 <ls+0x15c>

000000000000027a <main>:

int
main(int argc, char *argv[])
{
 27a:	1101                	addi	sp,sp,-32
 27c:	ec06                	sd	ra,24(sp)
 27e:	e822                	sd	s0,16(sp)
 280:	e426                	sd	s1,8(sp)
 282:	e04a                	sd	s2,0(sp)
 284:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 286:	4785                	li	a5,1
 288:	02a7d963          	bge	a5,a0,2ba <main+0x40>
 28c:	00858493          	addi	s1,a1,8
 290:	ffe5091b          	addiw	s2,a0,-2
 294:	1902                	slli	s2,s2,0x20
 296:	02095913          	srli	s2,s2,0x20
 29a:	090e                	slli	s2,s2,0x3
 29c:	05c1                	addi	a1,a1,16
 29e:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 2a0:	6088                	ld	a0,0(s1)
 2a2:	00000097          	auipc	ra,0x0
 2a6:	e12080e7          	jalr	-494(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 2aa:	04a1                	addi	s1,s1,8
 2ac:	ff249ae3          	bne	s1,s2,2a0 <main+0x26>
  exit(0);
 2b0:	4501                	li	a0,0
 2b2:	00000097          	auipc	ra,0x0
 2b6:	2e6080e7          	jalr	742(ra) # 598 <exit>
    ls(".");
 2ba:	00001517          	auipc	a0,0x1
 2be:	97e50513          	addi	a0,a0,-1666 # c38 <malloc+0x14e>
 2c2:	00000097          	auipc	ra,0x0
 2c6:	df2080e7          	jalr	-526(ra) # b4 <ls>
    exit(0);
 2ca:	4501                	li	a0,0
 2cc:	00000097          	auipc	ra,0x0
 2d0:	2cc080e7          	jalr	716(ra) # 598 <exit>

00000000000002d4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2da:	87aa                	mv	a5,a0
 2dc:	0585                	addi	a1,a1,1
 2de:	0785                	addi	a5,a5,1
 2e0:	fff5c703          	lbu	a4,-1(a1)
 2e4:	fee78fa3          	sb	a4,-1(a5)
 2e8:	fb75                	bnez	a4,2dc <strcpy+0x8>
    ;
  return os;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2f6:	00054783          	lbu	a5,0(a0)
 2fa:	cb91                	beqz	a5,30e <strcmp+0x1e>
 2fc:	0005c703          	lbu	a4,0(a1)
 300:	00f71763          	bne	a4,a5,30e <strcmp+0x1e>
    p++, q++;
 304:	0505                	addi	a0,a0,1
 306:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 308:	00054783          	lbu	a5,0(a0)
 30c:	fbe5                	bnez	a5,2fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 30e:	0005c503          	lbu	a0,0(a1)
}
 312:	40a7853b          	subw	a0,a5,a0
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <strlen>:

uint
strlen(const char *s)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e422                	sd	s0,8(sp)
 320:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 322:	00054783          	lbu	a5,0(a0)
 326:	cf91                	beqz	a5,342 <strlen+0x26>
 328:	0505                	addi	a0,a0,1
 32a:	87aa                	mv	a5,a0
 32c:	4685                	li	a3,1
 32e:	9e89                	subw	a3,a3,a0
 330:	00f6853b          	addw	a0,a3,a5
 334:	0785                	addi	a5,a5,1
 336:	fff7c703          	lbu	a4,-1(a5)
 33a:	fb7d                	bnez	a4,330 <strlen+0x14>
    ;
  return n;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  for(n = 0; s[n]; n++)
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <strlen+0x20>

0000000000000346 <memset>:

void*
memset(void *dst, int c, uint n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 34c:	ce09                	beqz	a2,366 <memset+0x20>
 34e:	87aa                	mv	a5,a0
 350:	fff6071b          	addiw	a4,a2,-1
 354:	1702                	slli	a4,a4,0x20
 356:	9301                	srli	a4,a4,0x20
 358:	0705                	addi	a4,a4,1
 35a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 35c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 360:	0785                	addi	a5,a5,1
 362:	fee79de3          	bne	a5,a4,35c <memset+0x16>
  }
  return dst;
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <strchr>:

char*
strchr(const char *s, char c)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  for(; *s; s++)
 372:	00054783          	lbu	a5,0(a0)
 376:	cb99                	beqz	a5,38c <strchr+0x20>
    if(*s == c)
 378:	00f58763          	beq	a1,a5,386 <strchr+0x1a>
  for(; *s; s++)
 37c:	0505                	addi	a0,a0,1
 37e:	00054783          	lbu	a5,0(a0)
 382:	fbfd                	bnez	a5,378 <strchr+0xc>
      return (char*)s;
  return 0;
 384:	4501                	li	a0,0
}
 386:	6422                	ld	s0,8(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret
  return 0;
 38c:	4501                	li	a0,0
 38e:	bfe5                	j	386 <strchr+0x1a>

0000000000000390 <gets>:

char*
gets(char *buf, int max)
{
 390:	711d                	addi	sp,sp,-96
 392:	ec86                	sd	ra,88(sp)
 394:	e8a2                	sd	s0,80(sp)
 396:	e4a6                	sd	s1,72(sp)
 398:	e0ca                	sd	s2,64(sp)
 39a:	fc4e                	sd	s3,56(sp)
 39c:	f852                	sd	s4,48(sp)
 39e:	f456                	sd	s5,40(sp)
 3a0:	f05a                	sd	s6,32(sp)
 3a2:	ec5e                	sd	s7,24(sp)
 3a4:	1080                	addi	s0,sp,96
 3a6:	8baa                	mv	s7,a0
 3a8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3aa:	892a                	mv	s2,a0
 3ac:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ae:	4aa9                	li	s5,10
 3b0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3b2:	89a6                	mv	s3,s1
 3b4:	2485                	addiw	s1,s1,1
 3b6:	0344d863          	bge	s1,s4,3e6 <gets+0x56>
    cc = read(0, &c, 1);
 3ba:	4605                	li	a2,1
 3bc:	faf40593          	addi	a1,s0,-81
 3c0:	4501                	li	a0,0
 3c2:	00000097          	auipc	ra,0x0
 3c6:	1ee080e7          	jalr	494(ra) # 5b0 <read>
    if(cc < 1)
 3ca:	00a05e63          	blez	a0,3e6 <gets+0x56>
    buf[i++] = c;
 3ce:	faf44783          	lbu	a5,-81(s0)
 3d2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3d6:	01578763          	beq	a5,s5,3e4 <gets+0x54>
 3da:	0905                	addi	s2,s2,1
 3dc:	fd679be3          	bne	a5,s6,3b2 <gets+0x22>
  for(i=0; i+1 < max; ){
 3e0:	89a6                	mv	s3,s1
 3e2:	a011                	j	3e6 <gets+0x56>
 3e4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3e6:	99de                	add	s3,s3,s7
 3e8:	00098023          	sb	zero,0(s3)
  return buf;
}
 3ec:	855e                	mv	a0,s7
 3ee:	60e6                	ld	ra,88(sp)
 3f0:	6446                	ld	s0,80(sp)
 3f2:	64a6                	ld	s1,72(sp)
 3f4:	6906                	ld	s2,64(sp)
 3f6:	79e2                	ld	s3,56(sp)
 3f8:	7a42                	ld	s4,48(sp)
 3fa:	7aa2                	ld	s5,40(sp)
 3fc:	7b02                	ld	s6,32(sp)
 3fe:	6be2                	ld	s7,24(sp)
 400:	6125                	addi	sp,sp,96
 402:	8082                	ret

0000000000000404 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 404:	1141                	addi	sp,sp,-16
 406:	e422                	sd	s0,8(sp)
 408:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 40a:	00054603          	lbu	a2,0(a0)
 40e:	fd06079b          	addiw	a5,a2,-48
 412:	0ff7f793          	andi	a5,a5,255
 416:	4725                	li	a4,9
 418:	02f76963          	bltu	a4,a5,44a <atoi+0x46>
 41c:	86aa                	mv	a3,a0
  n = 0;
 41e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 420:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 422:	0685                	addi	a3,a3,1
 424:	0025179b          	slliw	a5,a0,0x2
 428:	9fa9                	addw	a5,a5,a0
 42a:	0017979b          	slliw	a5,a5,0x1
 42e:	9fb1                	addw	a5,a5,a2
 430:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 434:	0006c603          	lbu	a2,0(a3)
 438:	fd06071b          	addiw	a4,a2,-48
 43c:	0ff77713          	andi	a4,a4,255
 440:	fee5f1e3          	bgeu	a1,a4,422 <atoi+0x1e>
  return n;
}
 444:	6422                	ld	s0,8(sp)
 446:	0141                	addi	sp,sp,16
 448:	8082                	ret
  n = 0;
 44a:	4501                	li	a0,0
 44c:	bfe5                	j	444 <atoi+0x40>

000000000000044e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 44e:	1141                	addi	sp,sp,-16
 450:	e422                	sd	s0,8(sp)
 452:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 454:	02b57663          	bgeu	a0,a1,480 <memmove+0x32>
    while(n-- > 0)
 458:	02c05163          	blez	a2,47a <memmove+0x2c>
 45c:	fff6079b          	addiw	a5,a2,-1
 460:	1782                	slli	a5,a5,0x20
 462:	9381                	srli	a5,a5,0x20
 464:	0785                	addi	a5,a5,1
 466:	97aa                	add	a5,a5,a0
  dst = vdst;
 468:	872a                	mv	a4,a0
      *dst++ = *src++;
 46a:	0585                	addi	a1,a1,1
 46c:	0705                	addi	a4,a4,1
 46e:	fff5c683          	lbu	a3,-1(a1)
 472:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 476:	fee79ae3          	bne	a5,a4,46a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 47a:	6422                	ld	s0,8(sp)
 47c:	0141                	addi	sp,sp,16
 47e:	8082                	ret
    dst += n;
 480:	00c50733          	add	a4,a0,a2
    src += n;
 484:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 486:	fec05ae3          	blez	a2,47a <memmove+0x2c>
 48a:	fff6079b          	addiw	a5,a2,-1
 48e:	1782                	slli	a5,a5,0x20
 490:	9381                	srli	a5,a5,0x20
 492:	fff7c793          	not	a5,a5
 496:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 498:	15fd                	addi	a1,a1,-1
 49a:	177d                	addi	a4,a4,-1
 49c:	0005c683          	lbu	a3,0(a1)
 4a0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4a4:	fee79ae3          	bne	a5,a4,498 <memmove+0x4a>
 4a8:	bfc9                	j	47a <memmove+0x2c>

00000000000004aa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4aa:	1141                	addi	sp,sp,-16
 4ac:	e422                	sd	s0,8(sp)
 4ae:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4b0:	ca05                	beqz	a2,4e0 <memcmp+0x36>
 4b2:	fff6069b          	addiw	a3,a2,-1
 4b6:	1682                	slli	a3,a3,0x20
 4b8:	9281                	srli	a3,a3,0x20
 4ba:	0685                	addi	a3,a3,1
 4bc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4be:	00054783          	lbu	a5,0(a0)
 4c2:	0005c703          	lbu	a4,0(a1)
 4c6:	00e79863          	bne	a5,a4,4d6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4ca:	0505                	addi	a0,a0,1
    p2++;
 4cc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4ce:	fed518e3          	bne	a0,a3,4be <memcmp+0x14>
  }
  return 0;
 4d2:	4501                	li	a0,0
 4d4:	a019                	j	4da <memcmp+0x30>
      return *p1 - *p2;
 4d6:	40e7853b          	subw	a0,a5,a4
}
 4da:	6422                	ld	s0,8(sp)
 4dc:	0141                	addi	sp,sp,16
 4de:	8082                	ret
  return 0;
 4e0:	4501                	li	a0,0
 4e2:	bfe5                	j	4da <memcmp+0x30>

00000000000004e4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4e4:	1141                	addi	sp,sp,-16
 4e6:	e406                	sd	ra,8(sp)
 4e8:	e022                	sd	s0,0(sp)
 4ea:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4ec:	00000097          	auipc	ra,0x0
 4f0:	f62080e7          	jalr	-158(ra) # 44e <memmove>
}
 4f4:	60a2                	ld	ra,8(sp)
 4f6:	6402                	ld	s0,0(sp)
 4f8:	0141                	addi	sp,sp,16
 4fa:	8082                	ret

00000000000004fc <close>:

int close(int fd){
 4fc:	1101                	addi	sp,sp,-32
 4fe:	ec06                	sd	ra,24(sp)
 500:	e822                	sd	s0,16(sp)
 502:	e426                	sd	s1,8(sp)
 504:	1000                	addi	s0,sp,32
 506:	84aa                	mv	s1,a0
  fflush(fd);
 508:	00000097          	auipc	ra,0x0
 50c:	2d4080e7          	jalr	724(ra) # 7dc <fflush>
  char* buf = get_putc_buf(fd);
 510:	8526                	mv	a0,s1
 512:	00000097          	auipc	ra,0x0
 516:	14e080e7          	jalr	334(ra) # 660 <get_putc_buf>
  if(buf){
 51a:	cd11                	beqz	a0,536 <close+0x3a>
    free(buf);
 51c:	00000097          	auipc	ra,0x0
 520:	546080e7          	jalr	1350(ra) # a62 <free>
    putc_buf[fd] = 0;
 524:	00349713          	slli	a4,s1,0x3
 528:	00000797          	auipc	a5,0x0
 52c:	75078793          	addi	a5,a5,1872 # c78 <putc_buf>
 530:	97ba                	add	a5,a5,a4
 532:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 536:	8526                	mv	a0,s1
 538:	00000097          	auipc	ra,0x0
 53c:	088080e7          	jalr	136(ra) # 5c0 <sclose>
}
 540:	60e2                	ld	ra,24(sp)
 542:	6442                	ld	s0,16(sp)
 544:	64a2                	ld	s1,8(sp)
 546:	6105                	addi	sp,sp,32
 548:	8082                	ret

000000000000054a <stat>:
{
 54a:	1101                	addi	sp,sp,-32
 54c:	ec06                	sd	ra,24(sp)
 54e:	e822                	sd	s0,16(sp)
 550:	e426                	sd	s1,8(sp)
 552:	e04a                	sd	s2,0(sp)
 554:	1000                	addi	s0,sp,32
 556:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 558:	4581                	li	a1,0
 55a:	00000097          	auipc	ra,0x0
 55e:	07e080e7          	jalr	126(ra) # 5d8 <open>
  if(fd < 0)
 562:	02054563          	bltz	a0,58c <stat+0x42>
 566:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 568:	85ca                	mv	a1,s2
 56a:	00000097          	auipc	ra,0x0
 56e:	086080e7          	jalr	134(ra) # 5f0 <fstat>
 572:	892a                	mv	s2,a0
  close(fd);
 574:	8526                	mv	a0,s1
 576:	00000097          	auipc	ra,0x0
 57a:	f86080e7          	jalr	-122(ra) # 4fc <close>
}
 57e:	854a                	mv	a0,s2
 580:	60e2                	ld	ra,24(sp)
 582:	6442                	ld	s0,16(sp)
 584:	64a2                	ld	s1,8(sp)
 586:	6902                	ld	s2,0(sp)
 588:	6105                	addi	sp,sp,32
 58a:	8082                	ret
    return -1;
 58c:	597d                	li	s2,-1
 58e:	bfc5                	j	57e <stat+0x34>

0000000000000590 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 590:	4885                	li	a7,1
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <exit>:
.global exit
exit:
 li a7, SYS_exit
 598:	4889                	li	a7,2
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5a0:	488d                	li	a7,3
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5a8:	4891                	li	a7,4
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <read>:
.global read
read:
 li a7, SYS_read
 5b0:	4895                	li	a7,5
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <write>:
.global write
write:
 li a7, SYS_write
 5b8:	48c1                	li	a7,16
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 5c0:	48d5                	li	a7,21
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5c8:	4899                	li	a7,6
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5d0:	489d                	li	a7,7
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <open>:
.global open
open:
 li a7, SYS_open
 5d8:	48bd                	li	a7,15
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5e0:	48c5                	li	a7,17
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5e8:	48c9                	li	a7,18
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5f0:	48a1                	li	a7,8
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <link>:
.global link
link:
 li a7, SYS_link
 5f8:	48cd                	li	a7,19
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 600:	48d1                	li	a7,20
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 608:	48a5                	li	a7,9
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <dup>:
.global dup
dup:
 li a7, SYS_dup
 610:	48a9                	li	a7,10
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 618:	48ad                	li	a7,11
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 620:	48b1                	li	a7,12
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 628:	48b5                	li	a7,13
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 630:	48b9                	li	a7,14
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 638:	48d9                	li	a7,22
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <nice>:
.global nice
nice:
 li a7, SYS_nice
 640:	48dd                	li	a7,23
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 648:	48e1                	li	a7,24
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 650:	48e5                	li	a7,25
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 658:	48e9                	li	a7,26
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 660:	1101                	addi	sp,sp,-32
 662:	ec06                	sd	ra,24(sp)
 664:	e822                	sd	s0,16(sp)
 666:	e426                	sd	s1,8(sp)
 668:	1000                	addi	s0,sp,32
 66a:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 66c:	00351713          	slli	a4,a0,0x3
 670:	00000797          	auipc	a5,0x0
 674:	60878793          	addi	a5,a5,1544 # c78 <putc_buf>
 678:	97ba                	add	a5,a5,a4
 67a:	6388                	ld	a0,0(a5)
  if(buf) {
 67c:	c511                	beqz	a0,688 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 67e:	60e2                	ld	ra,24(sp)
 680:	6442                	ld	s0,16(sp)
 682:	64a2                	ld	s1,8(sp)
 684:	6105                	addi	sp,sp,32
 686:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 688:	6505                	lui	a0,0x1
 68a:	00000097          	auipc	ra,0x0
 68e:	460080e7          	jalr	1120(ra) # aea <malloc>
  putc_buf[fd] = buf;
 692:	00000797          	auipc	a5,0x0
 696:	5e678793          	addi	a5,a5,1510 # c78 <putc_buf>
 69a:	00349713          	slli	a4,s1,0x3
 69e:	973e                	add	a4,a4,a5
 6a0:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 6a2:	048a                	slli	s1,s1,0x2
 6a4:	94be                	add	s1,s1,a5
 6a6:	3204a023          	sw	zero,800(s1)
  return buf;
 6aa:	bfd1                	j	67e <get_putc_buf+0x1e>

00000000000006ac <putc>:

static void
putc(int fd, char c)
{
 6ac:	1101                	addi	sp,sp,-32
 6ae:	ec06                	sd	ra,24(sp)
 6b0:	e822                	sd	s0,16(sp)
 6b2:	e426                	sd	s1,8(sp)
 6b4:	e04a                	sd	s2,0(sp)
 6b6:	1000                	addi	s0,sp,32
 6b8:	84aa                	mv	s1,a0
 6ba:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 6bc:	00000097          	auipc	ra,0x0
 6c0:	fa4080e7          	jalr	-92(ra) # 660 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 6c4:	00249793          	slli	a5,s1,0x2
 6c8:	00000717          	auipc	a4,0x0
 6cc:	5b070713          	addi	a4,a4,1456 # c78 <putc_buf>
 6d0:	973e                	add	a4,a4,a5
 6d2:	32072783          	lw	a5,800(a4)
 6d6:	0017869b          	addiw	a3,a5,1
 6da:	32d72023          	sw	a3,800(a4)
 6de:	97aa                	add	a5,a5,a0
 6e0:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 6e4:	47a9                	li	a5,10
 6e6:	02f90463          	beq	s2,a5,70e <putc+0x62>
 6ea:	00249713          	slli	a4,s1,0x2
 6ee:	00000797          	auipc	a5,0x0
 6f2:	58a78793          	addi	a5,a5,1418 # c78 <putc_buf>
 6f6:	97ba                	add	a5,a5,a4
 6f8:	3207a703          	lw	a4,800(a5)
 6fc:	6785                	lui	a5,0x1
 6fe:	00f70863          	beq	a4,a5,70e <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 702:	60e2                	ld	ra,24(sp)
 704:	6442                	ld	s0,16(sp)
 706:	64a2                	ld	s1,8(sp)
 708:	6902                	ld	s2,0(sp)
 70a:	6105                	addi	sp,sp,32
 70c:	8082                	ret
    write(fd, buf, putc_index[fd]);
 70e:	00249793          	slli	a5,s1,0x2
 712:	00000917          	auipc	s2,0x0
 716:	56690913          	addi	s2,s2,1382 # c78 <putc_buf>
 71a:	993e                	add	s2,s2,a5
 71c:	32092603          	lw	a2,800(s2)
 720:	85aa                	mv	a1,a0
 722:	8526                	mv	a0,s1
 724:	00000097          	auipc	ra,0x0
 728:	e94080e7          	jalr	-364(ra) # 5b8 <write>
    putc_index[fd] = 0;
 72c:	32092023          	sw	zero,800(s2)
}
 730:	bfc9                	j	702 <putc+0x56>

0000000000000732 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 732:	7139                	addi	sp,sp,-64
 734:	fc06                	sd	ra,56(sp)
 736:	f822                	sd	s0,48(sp)
 738:	f426                	sd	s1,40(sp)
 73a:	f04a                	sd	s2,32(sp)
 73c:	ec4e                	sd	s3,24(sp)
 73e:	0080                	addi	s0,sp,64
 740:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 742:	c299                	beqz	a3,748 <printint+0x16>
 744:	0805c863          	bltz	a1,7d4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 748:	2581                	sext.w	a1,a1
  neg = 0;
 74a:	4881                	li	a7,0
 74c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 750:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 752:	2601                	sext.w	a2,a2
 754:	00000517          	auipc	a0,0x0
 758:	4f450513          	addi	a0,a0,1268 # c48 <digits>
 75c:	883a                	mv	a6,a4
 75e:	2705                	addiw	a4,a4,1
 760:	02c5f7bb          	remuw	a5,a1,a2
 764:	1782                	slli	a5,a5,0x20
 766:	9381                	srli	a5,a5,0x20
 768:	97aa                	add	a5,a5,a0
 76a:	0007c783          	lbu	a5,0(a5) # 1000 <putc_index+0x68>
 76e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 772:	0005879b          	sext.w	a5,a1
 776:	02c5d5bb          	divuw	a1,a1,a2
 77a:	0685                	addi	a3,a3,1
 77c:	fec7f0e3          	bgeu	a5,a2,75c <printint+0x2a>
  if(neg)
 780:	00088b63          	beqz	a7,796 <printint+0x64>
    buf[i++] = '-';
 784:	fd040793          	addi	a5,s0,-48
 788:	973e                	add	a4,a4,a5
 78a:	02d00793          	li	a5,45
 78e:	fef70823          	sb	a5,-16(a4)
 792:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 796:	02e05863          	blez	a4,7c6 <printint+0x94>
 79a:	fc040793          	addi	a5,s0,-64
 79e:	00e78933          	add	s2,a5,a4
 7a2:	fff78993          	addi	s3,a5,-1
 7a6:	99ba                	add	s3,s3,a4
 7a8:	377d                	addiw	a4,a4,-1
 7aa:	1702                	slli	a4,a4,0x20
 7ac:	9301                	srli	a4,a4,0x20
 7ae:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 7b2:	fff94583          	lbu	a1,-1(s2)
 7b6:	8526                	mv	a0,s1
 7b8:	00000097          	auipc	ra,0x0
 7bc:	ef4080e7          	jalr	-268(ra) # 6ac <putc>
  while(--i >= 0)
 7c0:	197d                	addi	s2,s2,-1
 7c2:	ff3918e3          	bne	s2,s3,7b2 <printint+0x80>
}
 7c6:	70e2                	ld	ra,56(sp)
 7c8:	7442                	ld	s0,48(sp)
 7ca:	74a2                	ld	s1,40(sp)
 7cc:	7902                	ld	s2,32(sp)
 7ce:	69e2                	ld	s3,24(sp)
 7d0:	6121                	addi	sp,sp,64
 7d2:	8082                	ret
    x = -xx;
 7d4:	40b005bb          	negw	a1,a1
    neg = 1;
 7d8:	4885                	li	a7,1
    x = -xx;
 7da:	bf8d                	j	74c <printint+0x1a>

00000000000007dc <fflush>:
void fflush(int fd){
 7dc:	1101                	addi	sp,sp,-32
 7de:	ec06                	sd	ra,24(sp)
 7e0:	e822                	sd	s0,16(sp)
 7e2:	e426                	sd	s1,8(sp)
 7e4:	e04a                	sd	s2,0(sp)
 7e6:	1000                	addi	s0,sp,32
 7e8:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 7ea:	00000097          	auipc	ra,0x0
 7ee:	e76080e7          	jalr	-394(ra) # 660 <get_putc_buf>
 7f2:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 7f4:	00291793          	slli	a5,s2,0x2
 7f8:	00000497          	auipc	s1,0x0
 7fc:	48048493          	addi	s1,s1,1152 # c78 <putc_buf>
 800:	94be                	add	s1,s1,a5
 802:	3204a603          	lw	a2,800(s1)
 806:	854a                	mv	a0,s2
 808:	00000097          	auipc	ra,0x0
 80c:	db0080e7          	jalr	-592(ra) # 5b8 <write>
  putc_index[fd] = 0;
 810:	3204a023          	sw	zero,800(s1)
}
 814:	60e2                	ld	ra,24(sp)
 816:	6442                	ld	s0,16(sp)
 818:	64a2                	ld	s1,8(sp)
 81a:	6902                	ld	s2,0(sp)
 81c:	6105                	addi	sp,sp,32
 81e:	8082                	ret

0000000000000820 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 820:	7119                	addi	sp,sp,-128
 822:	fc86                	sd	ra,120(sp)
 824:	f8a2                	sd	s0,112(sp)
 826:	f4a6                	sd	s1,104(sp)
 828:	f0ca                	sd	s2,96(sp)
 82a:	ecce                	sd	s3,88(sp)
 82c:	e8d2                	sd	s4,80(sp)
 82e:	e4d6                	sd	s5,72(sp)
 830:	e0da                	sd	s6,64(sp)
 832:	fc5e                	sd	s7,56(sp)
 834:	f862                	sd	s8,48(sp)
 836:	f466                	sd	s9,40(sp)
 838:	f06a                	sd	s10,32(sp)
 83a:	ec6e                	sd	s11,24(sp)
 83c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 83e:	0005c903          	lbu	s2,0(a1)
 842:	18090f63          	beqz	s2,9e0 <vprintf+0x1c0>
 846:	8aaa                	mv	s5,a0
 848:	8b32                	mv	s6,a2
 84a:	00158493          	addi	s1,a1,1
  state = 0;
 84e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 850:	02500a13          	li	s4,37
      if(c == 'd'){
 854:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 858:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 85c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 860:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 864:	00000b97          	auipc	s7,0x0
 868:	3e4b8b93          	addi	s7,s7,996 # c48 <digits>
 86c:	a839                	j	88a <vprintf+0x6a>
        putc(fd, c);
 86e:	85ca                	mv	a1,s2
 870:	8556                	mv	a0,s5
 872:	00000097          	auipc	ra,0x0
 876:	e3a080e7          	jalr	-454(ra) # 6ac <putc>
 87a:	a019                	j	880 <vprintf+0x60>
    } else if(state == '%'){
 87c:	01498f63          	beq	s3,s4,89a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 880:	0485                	addi	s1,s1,1
 882:	fff4c903          	lbu	s2,-1(s1)
 886:	14090d63          	beqz	s2,9e0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 88a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 88e:	fe0997e3          	bnez	s3,87c <vprintf+0x5c>
      if(c == '%'){
 892:	fd479ee3          	bne	a5,s4,86e <vprintf+0x4e>
        state = '%';
 896:	89be                	mv	s3,a5
 898:	b7e5                	j	880 <vprintf+0x60>
      if(c == 'd'){
 89a:	05878063          	beq	a5,s8,8da <vprintf+0xba>
      } else if(c == 'l') {
 89e:	05978c63          	beq	a5,s9,8f6 <vprintf+0xd6>
      } else if(c == 'x') {
 8a2:	07a78863          	beq	a5,s10,912 <vprintf+0xf2>
      } else if(c == 'p') {
 8a6:	09b78463          	beq	a5,s11,92e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 8aa:	07300713          	li	a4,115
 8ae:	0ce78663          	beq	a5,a4,97a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8b2:	06300713          	li	a4,99
 8b6:	0ee78e63          	beq	a5,a4,9b2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 8ba:	11478863          	beq	a5,s4,9ca <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8be:	85d2                	mv	a1,s4
 8c0:	8556                	mv	a0,s5
 8c2:	00000097          	auipc	ra,0x0
 8c6:	dea080e7          	jalr	-534(ra) # 6ac <putc>
        putc(fd, c);
 8ca:	85ca                	mv	a1,s2
 8cc:	8556                	mv	a0,s5
 8ce:	00000097          	auipc	ra,0x0
 8d2:	dde080e7          	jalr	-546(ra) # 6ac <putc>
      }
      state = 0;
 8d6:	4981                	li	s3,0
 8d8:	b765                	j	880 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 8da:	008b0913          	addi	s2,s6,8
 8de:	4685                	li	a3,1
 8e0:	4629                	li	a2,10
 8e2:	000b2583          	lw	a1,0(s6)
 8e6:	8556                	mv	a0,s5
 8e8:	00000097          	auipc	ra,0x0
 8ec:	e4a080e7          	jalr	-438(ra) # 732 <printint>
 8f0:	8b4a                	mv	s6,s2
      state = 0;
 8f2:	4981                	li	s3,0
 8f4:	b771                	j	880 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8f6:	008b0913          	addi	s2,s6,8
 8fa:	4681                	li	a3,0
 8fc:	4629                	li	a2,10
 8fe:	000b2583          	lw	a1,0(s6)
 902:	8556                	mv	a0,s5
 904:	00000097          	auipc	ra,0x0
 908:	e2e080e7          	jalr	-466(ra) # 732 <printint>
 90c:	8b4a                	mv	s6,s2
      state = 0;
 90e:	4981                	li	s3,0
 910:	bf85                	j	880 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 912:	008b0913          	addi	s2,s6,8
 916:	4681                	li	a3,0
 918:	4641                	li	a2,16
 91a:	000b2583          	lw	a1,0(s6)
 91e:	8556                	mv	a0,s5
 920:	00000097          	auipc	ra,0x0
 924:	e12080e7          	jalr	-494(ra) # 732 <printint>
 928:	8b4a                	mv	s6,s2
      state = 0;
 92a:	4981                	li	s3,0
 92c:	bf91                	j	880 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 92e:	008b0793          	addi	a5,s6,8
 932:	f8f43423          	sd	a5,-120(s0)
 936:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 93a:	03000593          	li	a1,48
 93e:	8556                	mv	a0,s5
 940:	00000097          	auipc	ra,0x0
 944:	d6c080e7          	jalr	-660(ra) # 6ac <putc>
  putc(fd, 'x');
 948:	85ea                	mv	a1,s10
 94a:	8556                	mv	a0,s5
 94c:	00000097          	auipc	ra,0x0
 950:	d60080e7          	jalr	-672(ra) # 6ac <putc>
 954:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 956:	03c9d793          	srli	a5,s3,0x3c
 95a:	97de                	add	a5,a5,s7
 95c:	0007c583          	lbu	a1,0(a5)
 960:	8556                	mv	a0,s5
 962:	00000097          	auipc	ra,0x0
 966:	d4a080e7          	jalr	-694(ra) # 6ac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 96a:	0992                	slli	s3,s3,0x4
 96c:	397d                	addiw	s2,s2,-1
 96e:	fe0914e3          	bnez	s2,956 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 972:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 976:	4981                	li	s3,0
 978:	b721                	j	880 <vprintf+0x60>
        s = va_arg(ap, char*);
 97a:	008b0993          	addi	s3,s6,8
 97e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 982:	02090163          	beqz	s2,9a4 <vprintf+0x184>
        while(*s != 0){
 986:	00094583          	lbu	a1,0(s2)
 98a:	c9a1                	beqz	a1,9da <vprintf+0x1ba>
          putc(fd, *s);
 98c:	8556                	mv	a0,s5
 98e:	00000097          	auipc	ra,0x0
 992:	d1e080e7          	jalr	-738(ra) # 6ac <putc>
          s++;
 996:	0905                	addi	s2,s2,1
        while(*s != 0){
 998:	00094583          	lbu	a1,0(s2)
 99c:	f9e5                	bnez	a1,98c <vprintf+0x16c>
        s = va_arg(ap, char*);
 99e:	8b4e                	mv	s6,s3
      state = 0;
 9a0:	4981                	li	s3,0
 9a2:	bdf9                	j	880 <vprintf+0x60>
          s = "(null)";
 9a4:	00000917          	auipc	s2,0x0
 9a8:	29c90913          	addi	s2,s2,668 # c40 <malloc+0x156>
        while(*s != 0){
 9ac:	02800593          	li	a1,40
 9b0:	bff1                	j	98c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 9b2:	008b0913          	addi	s2,s6,8
 9b6:	000b4583          	lbu	a1,0(s6)
 9ba:	8556                	mv	a0,s5
 9bc:	00000097          	auipc	ra,0x0
 9c0:	cf0080e7          	jalr	-784(ra) # 6ac <putc>
 9c4:	8b4a                	mv	s6,s2
      state = 0;
 9c6:	4981                	li	s3,0
 9c8:	bd65                	j	880 <vprintf+0x60>
        putc(fd, c);
 9ca:	85d2                	mv	a1,s4
 9cc:	8556                	mv	a0,s5
 9ce:	00000097          	auipc	ra,0x0
 9d2:	cde080e7          	jalr	-802(ra) # 6ac <putc>
      state = 0;
 9d6:	4981                	li	s3,0
 9d8:	b565                	j	880 <vprintf+0x60>
        s = va_arg(ap, char*);
 9da:	8b4e                	mv	s6,s3
      state = 0;
 9dc:	4981                	li	s3,0
 9de:	b54d                	j	880 <vprintf+0x60>
    }
  }
}
 9e0:	70e6                	ld	ra,120(sp)
 9e2:	7446                	ld	s0,112(sp)
 9e4:	74a6                	ld	s1,104(sp)
 9e6:	7906                	ld	s2,96(sp)
 9e8:	69e6                	ld	s3,88(sp)
 9ea:	6a46                	ld	s4,80(sp)
 9ec:	6aa6                	ld	s5,72(sp)
 9ee:	6b06                	ld	s6,64(sp)
 9f0:	7be2                	ld	s7,56(sp)
 9f2:	7c42                	ld	s8,48(sp)
 9f4:	7ca2                	ld	s9,40(sp)
 9f6:	7d02                	ld	s10,32(sp)
 9f8:	6de2                	ld	s11,24(sp)
 9fa:	6109                	addi	sp,sp,128
 9fc:	8082                	ret

00000000000009fe <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9fe:	715d                	addi	sp,sp,-80
 a00:	ec06                	sd	ra,24(sp)
 a02:	e822                	sd	s0,16(sp)
 a04:	1000                	addi	s0,sp,32
 a06:	e010                	sd	a2,0(s0)
 a08:	e414                	sd	a3,8(s0)
 a0a:	e818                	sd	a4,16(s0)
 a0c:	ec1c                	sd	a5,24(s0)
 a0e:	03043023          	sd	a6,32(s0)
 a12:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a16:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a1a:	8622                	mv	a2,s0
 a1c:	00000097          	auipc	ra,0x0
 a20:	e04080e7          	jalr	-508(ra) # 820 <vprintf>
}
 a24:	60e2                	ld	ra,24(sp)
 a26:	6442                	ld	s0,16(sp)
 a28:	6161                	addi	sp,sp,80
 a2a:	8082                	ret

0000000000000a2c <printf>:

void
printf(const char *fmt, ...)
{
 a2c:	711d                	addi	sp,sp,-96
 a2e:	ec06                	sd	ra,24(sp)
 a30:	e822                	sd	s0,16(sp)
 a32:	1000                	addi	s0,sp,32
 a34:	e40c                	sd	a1,8(s0)
 a36:	e810                	sd	a2,16(s0)
 a38:	ec14                	sd	a3,24(s0)
 a3a:	f018                	sd	a4,32(s0)
 a3c:	f41c                	sd	a5,40(s0)
 a3e:	03043823          	sd	a6,48(s0)
 a42:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a46:	00840613          	addi	a2,s0,8
 a4a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a4e:	85aa                	mv	a1,a0
 a50:	4505                	li	a0,1
 a52:	00000097          	auipc	ra,0x0
 a56:	dce080e7          	jalr	-562(ra) # 820 <vprintf>
}
 a5a:	60e2                	ld	ra,24(sp)
 a5c:	6442                	ld	s0,16(sp)
 a5e:	6125                	addi	sp,sp,96
 a60:	8082                	ret

0000000000000a62 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a62:	1141                	addi	sp,sp,-16
 a64:	e422                	sd	s0,8(sp)
 a66:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a68:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a6c:	00000797          	auipc	a5,0x0
 a70:	1f47b783          	ld	a5,500(a5) # c60 <freep>
 a74:	a805                	j	aa4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a76:	4618                	lw	a4,8(a2)
 a78:	9db9                	addw	a1,a1,a4
 a7a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a7e:	6398                	ld	a4,0(a5)
 a80:	6318                	ld	a4,0(a4)
 a82:	fee53823          	sd	a4,-16(a0)
 a86:	a091                	j	aca <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a88:	ff852703          	lw	a4,-8(a0)
 a8c:	9e39                	addw	a2,a2,a4
 a8e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a90:	ff053703          	ld	a4,-16(a0)
 a94:	e398                	sd	a4,0(a5)
 a96:	a099                	j	adc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a98:	6398                	ld	a4,0(a5)
 a9a:	00e7e463          	bltu	a5,a4,aa2 <free+0x40>
 a9e:	00e6ea63          	bltu	a3,a4,ab2 <free+0x50>
{
 aa2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aa4:	fed7fae3          	bgeu	a5,a3,a98 <free+0x36>
 aa8:	6398                	ld	a4,0(a5)
 aaa:	00e6e463          	bltu	a3,a4,ab2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aae:	fee7eae3          	bltu	a5,a4,aa2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 ab2:	ff852583          	lw	a1,-8(a0)
 ab6:	6390                	ld	a2,0(a5)
 ab8:	02059713          	slli	a4,a1,0x20
 abc:	9301                	srli	a4,a4,0x20
 abe:	0712                	slli	a4,a4,0x4
 ac0:	9736                	add	a4,a4,a3
 ac2:	fae60ae3          	beq	a2,a4,a76 <free+0x14>
    bp->s.ptr = p->s.ptr;
 ac6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 aca:	4790                	lw	a2,8(a5)
 acc:	02061713          	slli	a4,a2,0x20
 ad0:	9301                	srli	a4,a4,0x20
 ad2:	0712                	slli	a4,a4,0x4
 ad4:	973e                	add	a4,a4,a5
 ad6:	fae689e3          	beq	a3,a4,a88 <free+0x26>
  } else
    p->s.ptr = bp;
 ada:	e394                	sd	a3,0(a5)
  freep = p;
 adc:	00000717          	auipc	a4,0x0
 ae0:	18f73223          	sd	a5,388(a4) # c60 <freep>
}
 ae4:	6422                	ld	s0,8(sp)
 ae6:	0141                	addi	sp,sp,16
 ae8:	8082                	ret

0000000000000aea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 aea:	7139                	addi	sp,sp,-64
 aec:	fc06                	sd	ra,56(sp)
 aee:	f822                	sd	s0,48(sp)
 af0:	f426                	sd	s1,40(sp)
 af2:	f04a                	sd	s2,32(sp)
 af4:	ec4e                	sd	s3,24(sp)
 af6:	e852                	sd	s4,16(sp)
 af8:	e456                	sd	s5,8(sp)
 afa:	e05a                	sd	s6,0(sp)
 afc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 afe:	02051493          	slli	s1,a0,0x20
 b02:	9081                	srli	s1,s1,0x20
 b04:	04bd                	addi	s1,s1,15
 b06:	8091                	srli	s1,s1,0x4
 b08:	0014899b          	addiw	s3,s1,1
 b0c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b0e:	00000517          	auipc	a0,0x0
 b12:	15253503          	ld	a0,338(a0) # c60 <freep>
 b16:	c515                	beqz	a0,b42 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b18:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b1a:	4798                	lw	a4,8(a5)
 b1c:	02977f63          	bgeu	a4,s1,b5a <malloc+0x70>
 b20:	8a4e                	mv	s4,s3
 b22:	0009871b          	sext.w	a4,s3
 b26:	6685                	lui	a3,0x1
 b28:	00d77363          	bgeu	a4,a3,b2e <malloc+0x44>
 b2c:	6a05                	lui	s4,0x1
 b2e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b32:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b36:	00000917          	auipc	s2,0x0
 b3a:	12a90913          	addi	s2,s2,298 # c60 <freep>
  if(p == (char*)-1)
 b3e:	5afd                	li	s5,-1
 b40:	a88d                	j	bb2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 b42:	00000797          	auipc	a5,0x0
 b46:	5e678793          	addi	a5,a5,1510 # 1128 <base>
 b4a:	00000717          	auipc	a4,0x0
 b4e:	10f73b23          	sd	a5,278(a4) # c60 <freep>
 b52:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b54:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b58:	b7e1                	j	b20 <malloc+0x36>
      if(p->s.size == nunits)
 b5a:	02e48b63          	beq	s1,a4,b90 <malloc+0xa6>
        p->s.size -= nunits;
 b5e:	4137073b          	subw	a4,a4,s3
 b62:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b64:	1702                	slli	a4,a4,0x20
 b66:	9301                	srli	a4,a4,0x20
 b68:	0712                	slli	a4,a4,0x4
 b6a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b6c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b70:	00000717          	auipc	a4,0x0
 b74:	0ea73823          	sd	a0,240(a4) # c60 <freep>
      return (void*)(p + 1);
 b78:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b7c:	70e2                	ld	ra,56(sp)
 b7e:	7442                	ld	s0,48(sp)
 b80:	74a2                	ld	s1,40(sp)
 b82:	7902                	ld	s2,32(sp)
 b84:	69e2                	ld	s3,24(sp)
 b86:	6a42                	ld	s4,16(sp)
 b88:	6aa2                	ld	s5,8(sp)
 b8a:	6b02                	ld	s6,0(sp)
 b8c:	6121                	addi	sp,sp,64
 b8e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b90:	6398                	ld	a4,0(a5)
 b92:	e118                	sd	a4,0(a0)
 b94:	bff1                	j	b70 <malloc+0x86>
  hp->s.size = nu;
 b96:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b9a:	0541                	addi	a0,a0,16
 b9c:	00000097          	auipc	ra,0x0
 ba0:	ec6080e7          	jalr	-314(ra) # a62 <free>
  return freep;
 ba4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ba8:	d971                	beqz	a0,b7c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 baa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bac:	4798                	lw	a4,8(a5)
 bae:	fa9776e3          	bgeu	a4,s1,b5a <malloc+0x70>
    if(p == freep)
 bb2:	00093703          	ld	a4,0(s2)
 bb6:	853e                	mv	a0,a5
 bb8:	fef719e3          	bne	a4,a5,baa <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 bbc:	8552                	mv	a0,s4
 bbe:	00000097          	auipc	ra,0x0
 bc2:	a62080e7          	jalr	-1438(ra) # 620 <sbrk>
  if(p == (char*)-1)
 bc6:	fd5518e3          	bne	a0,s5,b96 <malloc+0xac>
        return 0;
 bca:	4501                	li	a0,0
 bcc:	bf45                	j	b7c <malloc+0x92>
