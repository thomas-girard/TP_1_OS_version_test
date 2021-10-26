
user/_print:     file format elf64-littleriscv


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
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892e                	mv	s2,a1
  if(argc < 2){
  12:	4785                	li	a5,1
    printf("print: not enough arguments\n");
    exit(1);
  }
  int i = 0;
  14:	4481                	li	s1,0
  while (1){
    printf("%s %d\n", argv[1], i);
  16:	00001a17          	auipc	s4,0x1
  1a:	962a0a13          	addi	s4,s4,-1694 # 978 <malloc+0x108>
  1e:	008009b7          	lui	s3,0x800
  if(argc < 2){
  22:	02a7c063          	blt	a5,a0,42 <main+0x42>
    printf("print: not enough arguments\n");
  26:	00001517          	auipc	a0,0x1
  2a:	93250513          	addi	a0,a0,-1742 # 958 <malloc+0xe8>
  2e:	00000097          	auipc	ra,0x0
  32:	784080e7          	jalr	1924(ra) # 7b2 <printf>
    exit(1);
  36:	4505                	li	a0,1
  38:	00000097          	auipc	ra,0x0
  3c:	2e6080e7          	jalr	742(ra) # 31e <exit>
    for(int j = 0; j < (1 << 23); j++);
    i++;
  40:	2485                	addiw	s1,s1,1
    printf("%s %d\n", argv[1], i);
  42:	8626                	mv	a2,s1
  44:	00893583          	ld	a1,8(s2)
  48:	8552                	mv	a0,s4
  4a:	00000097          	auipc	ra,0x0
  4e:	768080e7          	jalr	1896(ra) # 7b2 <printf>
  52:	87ce                	mv	a5,s3
    for(int j = 0; j < (1 << 23); j++);
  54:	37fd                	addiw	a5,a5,-1
  56:	fffd                	bnez	a5,54 <main+0x54>
  58:	b7e5                	j	40 <main+0x40>

000000000000005a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  5a:	1141                	addi	sp,sp,-16
  5c:	e422                	sd	s0,8(sp)
  5e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  60:	87aa                	mv	a5,a0
  62:	0585                	addi	a1,a1,1
  64:	0785                	addi	a5,a5,1
  66:	fff5c703          	lbu	a4,-1(a1)
  6a:	fee78fa3          	sb	a4,-1(a5)
  6e:	fb75                	bnez	a4,62 <strcpy+0x8>
    ;
  return os;
}
  70:	6422                	ld	s0,8(sp)
  72:	0141                	addi	sp,sp,16
  74:	8082                	ret

0000000000000076 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  76:	1141                	addi	sp,sp,-16
  78:	e422                	sd	s0,8(sp)
  7a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  7c:	00054783          	lbu	a5,0(a0)
  80:	cb91                	beqz	a5,94 <strcmp+0x1e>
  82:	0005c703          	lbu	a4,0(a1)
  86:	00f71763          	bne	a4,a5,94 <strcmp+0x1e>
    p++, q++;
  8a:	0505                	addi	a0,a0,1
  8c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  8e:	00054783          	lbu	a5,0(a0)
  92:	fbe5                	bnez	a5,82 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  94:	0005c503          	lbu	a0,0(a1)
}
  98:	40a7853b          	subw	a0,a5,a0
  9c:	6422                	ld	s0,8(sp)
  9e:	0141                	addi	sp,sp,16
  a0:	8082                	ret

00000000000000a2 <strlen>:

uint
strlen(const char *s)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e422                	sd	s0,8(sp)
  a6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a8:	00054783          	lbu	a5,0(a0)
  ac:	cf91                	beqz	a5,c8 <strlen+0x26>
  ae:	0505                	addi	a0,a0,1
  b0:	87aa                	mv	a5,a0
  b2:	4685                	li	a3,1
  b4:	9e89                	subw	a3,a3,a0
  b6:	00f6853b          	addw	a0,a3,a5
  ba:	0785                	addi	a5,a5,1
  bc:	fff7c703          	lbu	a4,-1(a5)
  c0:	fb7d                	bnez	a4,b6 <strlen+0x14>
    ;
  return n;
}
  c2:	6422                	ld	s0,8(sp)
  c4:	0141                	addi	sp,sp,16
  c6:	8082                	ret
  for(n = 0; s[n]; n++)
  c8:	4501                	li	a0,0
  ca:	bfe5                	j	c2 <strlen+0x20>

00000000000000cc <memset>:

void*
memset(void *dst, int c, uint n)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d2:	ce09                	beqz	a2,ec <memset+0x20>
  d4:	87aa                	mv	a5,a0
  d6:	fff6071b          	addiw	a4,a2,-1
  da:	1702                	slli	a4,a4,0x20
  dc:	9301                	srli	a4,a4,0x20
  de:	0705                	addi	a4,a4,1
  e0:	972a                	add	a4,a4,a0
    cdst[i] = c;
  e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e6:	0785                	addi	a5,a5,1
  e8:	fee79de3          	bne	a5,a4,e2 <memset+0x16>
  }
  return dst;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strchr>:

char*
strchr(const char *s, char c)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cb99                	beqz	a5,112 <strchr+0x20>
    if(*s == c)
  fe:	00f58763          	beq	a1,a5,10c <strchr+0x1a>
  for(; *s; s++)
 102:	0505                	addi	a0,a0,1
 104:	00054783          	lbu	a5,0(a0)
 108:	fbfd                	bnez	a5,fe <strchr+0xc>
      return (char*)s;
  return 0;
 10a:	4501                	li	a0,0
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret
  return 0;
 112:	4501                	li	a0,0
 114:	bfe5                	j	10c <strchr+0x1a>

0000000000000116 <gets>:

char*
gets(char *buf, int max)
{
 116:	711d                	addi	sp,sp,-96
 118:	ec86                	sd	ra,88(sp)
 11a:	e8a2                	sd	s0,80(sp)
 11c:	e4a6                	sd	s1,72(sp)
 11e:	e0ca                	sd	s2,64(sp)
 120:	fc4e                	sd	s3,56(sp)
 122:	f852                	sd	s4,48(sp)
 124:	f456                	sd	s5,40(sp)
 126:	f05a                	sd	s6,32(sp)
 128:	ec5e                	sd	s7,24(sp)
 12a:	1080                	addi	s0,sp,96
 12c:	8baa                	mv	s7,a0
 12e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 130:	892a                	mv	s2,a0
 132:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 134:	4aa9                	li	s5,10
 136:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 138:	89a6                	mv	s3,s1
 13a:	2485                	addiw	s1,s1,1
 13c:	0344d863          	bge	s1,s4,16c <gets+0x56>
    cc = read(0, &c, 1);
 140:	4605                	li	a2,1
 142:	faf40593          	addi	a1,s0,-81
 146:	4501                	li	a0,0
 148:	00000097          	auipc	ra,0x0
 14c:	1ee080e7          	jalr	494(ra) # 336 <read>
    if(cc < 1)
 150:	00a05e63          	blez	a0,16c <gets+0x56>
    buf[i++] = c;
 154:	faf44783          	lbu	a5,-81(s0)
 158:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15c:	01578763          	beq	a5,s5,16a <gets+0x54>
 160:	0905                	addi	s2,s2,1
 162:	fd679be3          	bne	a5,s6,138 <gets+0x22>
  for(i=0; i+1 < max; ){
 166:	89a6                	mv	s3,s1
 168:	a011                	j	16c <gets+0x56>
 16a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16c:	99de                	add	s3,s3,s7
 16e:	00098023          	sb	zero,0(s3) # 800000 <__global_pointer$+0x7fee67>
  return buf;
}
 172:	855e                	mv	a0,s7
 174:	60e6                	ld	ra,88(sp)
 176:	6446                	ld	s0,80(sp)
 178:	64a6                	ld	s1,72(sp)
 17a:	6906                	ld	s2,64(sp)
 17c:	79e2                	ld	s3,56(sp)
 17e:	7a42                	ld	s4,48(sp)
 180:	7aa2                	ld	s5,40(sp)
 182:	7b02                	ld	s6,32(sp)
 184:	6be2                	ld	s7,24(sp)
 186:	6125                	addi	sp,sp,96
 188:	8082                	ret

000000000000018a <atoi>:
  return r;
}

int
atoi(const char *s)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 190:	00054603          	lbu	a2,0(a0)
 194:	fd06079b          	addiw	a5,a2,-48
 198:	0ff7f793          	andi	a5,a5,255
 19c:	4725                	li	a4,9
 19e:	02f76963          	bltu	a4,a5,1d0 <atoi+0x46>
 1a2:	86aa                	mv	a3,a0
  n = 0;
 1a4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1a6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1a8:	0685                	addi	a3,a3,1
 1aa:	0025179b          	slliw	a5,a0,0x2
 1ae:	9fa9                	addw	a5,a5,a0
 1b0:	0017979b          	slliw	a5,a5,0x1
 1b4:	9fb1                	addw	a5,a5,a2
 1b6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ba:	0006c603          	lbu	a2,0(a3)
 1be:	fd06071b          	addiw	a4,a2,-48
 1c2:	0ff77713          	andi	a4,a4,255
 1c6:	fee5f1e3          	bgeu	a1,a4,1a8 <atoi+0x1e>
  return n;
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret
  n = 0;
 1d0:	4501                	li	a0,0
 1d2:	bfe5                	j	1ca <atoi+0x40>

00000000000001d4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1da:	02b57663          	bgeu	a0,a1,206 <memmove+0x32>
    while(n-- > 0)
 1de:	02c05163          	blez	a2,200 <memmove+0x2c>
 1e2:	fff6079b          	addiw	a5,a2,-1
 1e6:	1782                	slli	a5,a5,0x20
 1e8:	9381                	srli	a5,a5,0x20
 1ea:	0785                	addi	a5,a5,1
 1ec:	97aa                	add	a5,a5,a0
  dst = vdst;
 1ee:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f0:	0585                	addi	a1,a1,1
 1f2:	0705                	addi	a4,a4,1
 1f4:	fff5c683          	lbu	a3,-1(a1)
 1f8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1fc:	fee79ae3          	bne	a5,a4,1f0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret
    dst += n;
 206:	00c50733          	add	a4,a0,a2
    src += n;
 20a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 20c:	fec05ae3          	blez	a2,200 <memmove+0x2c>
 210:	fff6079b          	addiw	a5,a2,-1
 214:	1782                	slli	a5,a5,0x20
 216:	9381                	srli	a5,a5,0x20
 218:	fff7c793          	not	a5,a5
 21c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 21e:	15fd                	addi	a1,a1,-1
 220:	177d                	addi	a4,a4,-1
 222:	0005c683          	lbu	a3,0(a1)
 226:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 22a:	fee79ae3          	bne	a5,a4,21e <memmove+0x4a>
 22e:	bfc9                	j	200 <memmove+0x2c>

0000000000000230 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 236:	ca05                	beqz	a2,266 <memcmp+0x36>
 238:	fff6069b          	addiw	a3,a2,-1
 23c:	1682                	slli	a3,a3,0x20
 23e:	9281                	srli	a3,a3,0x20
 240:	0685                	addi	a3,a3,1
 242:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 244:	00054783          	lbu	a5,0(a0)
 248:	0005c703          	lbu	a4,0(a1)
 24c:	00e79863          	bne	a5,a4,25c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 250:	0505                	addi	a0,a0,1
    p2++;
 252:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 254:	fed518e3          	bne	a0,a3,244 <memcmp+0x14>
  }
  return 0;
 258:	4501                	li	a0,0
 25a:	a019                	j	260 <memcmp+0x30>
      return *p1 - *p2;
 25c:	40e7853b          	subw	a0,a5,a4
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
  return 0;
 266:	4501                	li	a0,0
 268:	bfe5                	j	260 <memcmp+0x30>

000000000000026a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e406                	sd	ra,8(sp)
 26e:	e022                	sd	s0,0(sp)
 270:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 272:	00000097          	auipc	ra,0x0
 276:	f62080e7          	jalr	-158(ra) # 1d4 <memmove>
}
 27a:	60a2                	ld	ra,8(sp)
 27c:	6402                	ld	s0,0(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret

0000000000000282 <close>:

int close(int fd){
 282:	1101                	addi	sp,sp,-32
 284:	ec06                	sd	ra,24(sp)
 286:	e822                	sd	s0,16(sp)
 288:	e426                	sd	s1,8(sp)
 28a:	1000                	addi	s0,sp,32
 28c:	84aa                	mv	s1,a0
  fflush(fd);
 28e:	00000097          	auipc	ra,0x0
 292:	2d4080e7          	jalr	724(ra) # 562 <fflush>
  char* buf = get_putc_buf(fd);
 296:	8526                	mv	a0,s1
 298:	00000097          	auipc	ra,0x0
 29c:	14e080e7          	jalr	334(ra) # 3e6 <get_putc_buf>
  if(buf){
 2a0:	cd11                	beqz	a0,2bc <close+0x3a>
    free(buf);
 2a2:	00000097          	auipc	ra,0x0
 2a6:	546080e7          	jalr	1350(ra) # 7e8 <free>
    putc_buf[fd] = 0;
 2aa:	00349713          	slli	a4,s1,0x3
 2ae:	00000797          	auipc	a5,0x0
 2b2:	6fa78793          	addi	a5,a5,1786 # 9a8 <putc_buf>
 2b6:	97ba                	add	a5,a5,a4
 2b8:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 2bc:	8526                	mv	a0,s1
 2be:	00000097          	auipc	ra,0x0
 2c2:	088080e7          	jalr	136(ra) # 346 <sclose>
}
 2c6:	60e2                	ld	ra,24(sp)
 2c8:	6442                	ld	s0,16(sp)
 2ca:	64a2                	ld	s1,8(sp)
 2cc:	6105                	addi	sp,sp,32
 2ce:	8082                	ret

00000000000002d0 <stat>:
{
 2d0:	1101                	addi	sp,sp,-32
 2d2:	ec06                	sd	ra,24(sp)
 2d4:	e822                	sd	s0,16(sp)
 2d6:	e426                	sd	s1,8(sp)
 2d8:	e04a                	sd	s2,0(sp)
 2da:	1000                	addi	s0,sp,32
 2dc:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 2de:	4581                	li	a1,0
 2e0:	00000097          	auipc	ra,0x0
 2e4:	07e080e7          	jalr	126(ra) # 35e <open>
  if(fd < 0)
 2e8:	02054563          	bltz	a0,312 <stat+0x42>
 2ec:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 2ee:	85ca                	mv	a1,s2
 2f0:	00000097          	auipc	ra,0x0
 2f4:	086080e7          	jalr	134(ra) # 376 <fstat>
 2f8:	892a                	mv	s2,a0
  close(fd);
 2fa:	8526                	mv	a0,s1
 2fc:	00000097          	auipc	ra,0x0
 300:	f86080e7          	jalr	-122(ra) # 282 <close>
}
 304:	854a                	mv	a0,s2
 306:	60e2                	ld	ra,24(sp)
 308:	6442                	ld	s0,16(sp)
 30a:	64a2                	ld	s1,8(sp)
 30c:	6902                	ld	s2,0(sp)
 30e:	6105                	addi	sp,sp,32
 310:	8082                	ret
    return -1;
 312:	597d                	li	s2,-1
 314:	bfc5                	j	304 <stat+0x34>

0000000000000316 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 316:	4885                	li	a7,1
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <exit>:
.global exit
exit:
 li a7, SYS_exit
 31e:	4889                	li	a7,2
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <wait>:
.global wait
wait:
 li a7, SYS_wait
 326:	488d                	li	a7,3
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 32e:	4891                	li	a7,4
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <read>:
.global read
read:
 li a7, SYS_read
 336:	4895                	li	a7,5
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <write>:
.global write
write:
 li a7, SYS_write
 33e:	48c1                	li	a7,16
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 346:	48d5                	li	a7,21
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <kill>:
.global kill
kill:
 li a7, SYS_kill
 34e:	4899                	li	a7,6
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <exec>:
.global exec
exec:
 li a7, SYS_exec
 356:	489d                	li	a7,7
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <open>:
.global open
open:
 li a7, SYS_open
 35e:	48bd                	li	a7,15
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 366:	48c5                	li	a7,17
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 36e:	48c9                	li	a7,18
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 376:	48a1                	li	a7,8
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <link>:
.global link
link:
 li a7, SYS_link
 37e:	48cd                	li	a7,19
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 386:	48d1                	li	a7,20
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 38e:	48a5                	li	a7,9
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <dup>:
.global dup
dup:
 li a7, SYS_dup
 396:	48a9                	li	a7,10
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 39e:	48ad                	li	a7,11
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3a6:	48b1                	li	a7,12
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ae:	48b5                	li	a7,13
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b6:	48b9                	li	a7,14
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 3be:	48d9                	li	a7,22
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <nice>:
.global nice
nice:
 li a7, SYS_nice
 3c6:	48dd                	li	a7,23
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 3ce:	48e1                	li	a7,24
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 3d6:	48e5                	li	a7,25
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 3de:	48e9                	li	a7,26
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 3e6:	1101                	addi	sp,sp,-32
 3e8:	ec06                	sd	ra,24(sp)
 3ea:	e822                	sd	s0,16(sp)
 3ec:	e426                	sd	s1,8(sp)
 3ee:	1000                	addi	s0,sp,32
 3f0:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 3f2:	00351713          	slli	a4,a0,0x3
 3f6:	00000797          	auipc	a5,0x0
 3fa:	5b278793          	addi	a5,a5,1458 # 9a8 <putc_buf>
 3fe:	97ba                	add	a5,a5,a4
 400:	6388                	ld	a0,0(a5)
  if(buf) {
 402:	c511                	beqz	a0,40e <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 404:	60e2                	ld	ra,24(sp)
 406:	6442                	ld	s0,16(sp)
 408:	64a2                	ld	s1,8(sp)
 40a:	6105                	addi	sp,sp,32
 40c:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 40e:	6505                	lui	a0,0x1
 410:	00000097          	auipc	ra,0x0
 414:	460080e7          	jalr	1120(ra) # 870 <malloc>
  putc_buf[fd] = buf;
 418:	00000797          	auipc	a5,0x0
 41c:	59078793          	addi	a5,a5,1424 # 9a8 <putc_buf>
 420:	00349713          	slli	a4,s1,0x3
 424:	973e                	add	a4,a4,a5
 426:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 428:	048a                	slli	s1,s1,0x2
 42a:	94be                	add	s1,s1,a5
 42c:	3204a023          	sw	zero,800(s1)
  return buf;
 430:	bfd1                	j	404 <get_putc_buf+0x1e>

0000000000000432 <putc>:

static void
putc(int fd, char c)
{
 432:	1101                	addi	sp,sp,-32
 434:	ec06                	sd	ra,24(sp)
 436:	e822                	sd	s0,16(sp)
 438:	e426                	sd	s1,8(sp)
 43a:	e04a                	sd	s2,0(sp)
 43c:	1000                	addi	s0,sp,32
 43e:	84aa                	mv	s1,a0
 440:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 442:	00000097          	auipc	ra,0x0
 446:	fa4080e7          	jalr	-92(ra) # 3e6 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 44a:	00249793          	slli	a5,s1,0x2
 44e:	00000717          	auipc	a4,0x0
 452:	55a70713          	addi	a4,a4,1370 # 9a8 <putc_buf>
 456:	973e                	add	a4,a4,a5
 458:	32072783          	lw	a5,800(a4)
 45c:	0017869b          	addiw	a3,a5,1
 460:	32d72023          	sw	a3,800(a4)
 464:	97aa                	add	a5,a5,a0
 466:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 46a:	47a9                	li	a5,10
 46c:	02f90463          	beq	s2,a5,494 <putc+0x62>
 470:	00249713          	slli	a4,s1,0x2
 474:	00000797          	auipc	a5,0x0
 478:	53478793          	addi	a5,a5,1332 # 9a8 <putc_buf>
 47c:	97ba                	add	a5,a5,a4
 47e:	3207a703          	lw	a4,800(a5)
 482:	6785                	lui	a5,0x1
 484:	00f70863          	beq	a4,a5,494 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 488:	60e2                	ld	ra,24(sp)
 48a:	6442                	ld	s0,16(sp)
 48c:	64a2                	ld	s1,8(sp)
 48e:	6902                	ld	s2,0(sp)
 490:	6105                	addi	sp,sp,32
 492:	8082                	ret
    write(fd, buf, putc_index[fd]);
 494:	00249793          	slli	a5,s1,0x2
 498:	00000917          	auipc	s2,0x0
 49c:	51090913          	addi	s2,s2,1296 # 9a8 <putc_buf>
 4a0:	993e                	add	s2,s2,a5
 4a2:	32092603          	lw	a2,800(s2)
 4a6:	85aa                	mv	a1,a0
 4a8:	8526                	mv	a0,s1
 4aa:	00000097          	auipc	ra,0x0
 4ae:	e94080e7          	jalr	-364(ra) # 33e <write>
    putc_index[fd] = 0;
 4b2:	32092023          	sw	zero,800(s2)
}
 4b6:	bfc9                	j	488 <putc+0x56>

00000000000004b8 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4b8:	7139                	addi	sp,sp,-64
 4ba:	fc06                	sd	ra,56(sp)
 4bc:	f822                	sd	s0,48(sp)
 4be:	f426                	sd	s1,40(sp)
 4c0:	f04a                	sd	s2,32(sp)
 4c2:	ec4e                	sd	s3,24(sp)
 4c4:	0080                	addi	s0,sp,64
 4c6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c8:	c299                	beqz	a3,4ce <printint+0x16>
 4ca:	0805c863          	bltz	a1,55a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ce:	2581                	sext.w	a1,a1
  neg = 0;
 4d0:	4881                	li	a7,0
 4d2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d8:	2601                	sext.w	a2,a2
 4da:	00000517          	auipc	a0,0x0
 4de:	4ae50513          	addi	a0,a0,1198 # 988 <digits>
 4e2:	883a                	mv	a6,a4
 4e4:	2705                	addiw	a4,a4,1
 4e6:	02c5f7bb          	remuw	a5,a1,a2
 4ea:	1782                	slli	a5,a5,0x20
 4ec:	9381                	srli	a5,a5,0x20
 4ee:	97aa                	add	a5,a5,a0
 4f0:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x198>
 4f4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f8:	0005879b          	sext.w	a5,a1
 4fc:	02c5d5bb          	divuw	a1,a1,a2
 500:	0685                	addi	a3,a3,1
 502:	fec7f0e3          	bgeu	a5,a2,4e2 <printint+0x2a>
  if(neg)
 506:	00088b63          	beqz	a7,51c <printint+0x64>
    buf[i++] = '-';
 50a:	fd040793          	addi	a5,s0,-48
 50e:	973e                	add	a4,a4,a5
 510:	02d00793          	li	a5,45
 514:	fef70823          	sb	a5,-16(a4)
 518:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 51c:	02e05863          	blez	a4,54c <printint+0x94>
 520:	fc040793          	addi	a5,s0,-64
 524:	00e78933          	add	s2,a5,a4
 528:	fff78993          	addi	s3,a5,-1
 52c:	99ba                	add	s3,s3,a4
 52e:	377d                	addiw	a4,a4,-1
 530:	1702                	slli	a4,a4,0x20
 532:	9301                	srli	a4,a4,0x20
 534:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 538:	fff94583          	lbu	a1,-1(s2)
 53c:	8526                	mv	a0,s1
 53e:	00000097          	auipc	ra,0x0
 542:	ef4080e7          	jalr	-268(ra) # 432 <putc>
  while(--i >= 0)
 546:	197d                	addi	s2,s2,-1
 548:	ff3918e3          	bne	s2,s3,538 <printint+0x80>
}
 54c:	70e2                	ld	ra,56(sp)
 54e:	7442                	ld	s0,48(sp)
 550:	74a2                	ld	s1,40(sp)
 552:	7902                	ld	s2,32(sp)
 554:	69e2                	ld	s3,24(sp)
 556:	6121                	addi	sp,sp,64
 558:	8082                	ret
    x = -xx;
 55a:	40b005bb          	negw	a1,a1
    neg = 1;
 55e:	4885                	li	a7,1
    x = -xx;
 560:	bf8d                	j	4d2 <printint+0x1a>

0000000000000562 <fflush>:
void fflush(int fd){
 562:	1101                	addi	sp,sp,-32
 564:	ec06                	sd	ra,24(sp)
 566:	e822                	sd	s0,16(sp)
 568:	e426                	sd	s1,8(sp)
 56a:	e04a                	sd	s2,0(sp)
 56c:	1000                	addi	s0,sp,32
 56e:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 570:	00000097          	auipc	ra,0x0
 574:	e76080e7          	jalr	-394(ra) # 3e6 <get_putc_buf>
 578:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 57a:	00291793          	slli	a5,s2,0x2
 57e:	00000497          	auipc	s1,0x0
 582:	42a48493          	addi	s1,s1,1066 # 9a8 <putc_buf>
 586:	94be                	add	s1,s1,a5
 588:	3204a603          	lw	a2,800(s1)
 58c:	854a                	mv	a0,s2
 58e:	00000097          	auipc	ra,0x0
 592:	db0080e7          	jalr	-592(ra) # 33e <write>
  putc_index[fd] = 0;
 596:	3204a023          	sw	zero,800(s1)
}
 59a:	60e2                	ld	ra,24(sp)
 59c:	6442                	ld	s0,16(sp)
 59e:	64a2                	ld	s1,8(sp)
 5a0:	6902                	ld	s2,0(sp)
 5a2:	6105                	addi	sp,sp,32
 5a4:	8082                	ret

00000000000005a6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5a6:	7119                	addi	sp,sp,-128
 5a8:	fc86                	sd	ra,120(sp)
 5aa:	f8a2                	sd	s0,112(sp)
 5ac:	f4a6                	sd	s1,104(sp)
 5ae:	f0ca                	sd	s2,96(sp)
 5b0:	ecce                	sd	s3,88(sp)
 5b2:	e8d2                	sd	s4,80(sp)
 5b4:	e4d6                	sd	s5,72(sp)
 5b6:	e0da                	sd	s6,64(sp)
 5b8:	fc5e                	sd	s7,56(sp)
 5ba:	f862                	sd	s8,48(sp)
 5bc:	f466                	sd	s9,40(sp)
 5be:	f06a                	sd	s10,32(sp)
 5c0:	ec6e                	sd	s11,24(sp)
 5c2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5c4:	0005c903          	lbu	s2,0(a1)
 5c8:	18090f63          	beqz	s2,766 <vprintf+0x1c0>
 5cc:	8aaa                	mv	s5,a0
 5ce:	8b32                	mv	s6,a2
 5d0:	00158493          	addi	s1,a1,1
  state = 0;
 5d4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5d6:	02500a13          	li	s4,37
      if(c == 'd'){
 5da:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5de:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5e2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5e6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ea:	00000b97          	auipc	s7,0x0
 5ee:	39eb8b93          	addi	s7,s7,926 # 988 <digits>
 5f2:	a839                	j	610 <vprintf+0x6a>
        putc(fd, c);
 5f4:	85ca                	mv	a1,s2
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e3a080e7          	jalr	-454(ra) # 432 <putc>
 600:	a019                	j	606 <vprintf+0x60>
    } else if(state == '%'){
 602:	01498f63          	beq	s3,s4,620 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 606:	0485                	addi	s1,s1,1
 608:	fff4c903          	lbu	s2,-1(s1)
 60c:	14090d63          	beqz	s2,766 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 610:	0009079b          	sext.w	a5,s2
    if(state == 0){
 614:	fe0997e3          	bnez	s3,602 <vprintf+0x5c>
      if(c == '%'){
 618:	fd479ee3          	bne	a5,s4,5f4 <vprintf+0x4e>
        state = '%';
 61c:	89be                	mv	s3,a5
 61e:	b7e5                	j	606 <vprintf+0x60>
      if(c == 'd'){
 620:	05878063          	beq	a5,s8,660 <vprintf+0xba>
      } else if(c == 'l') {
 624:	05978c63          	beq	a5,s9,67c <vprintf+0xd6>
      } else if(c == 'x') {
 628:	07a78863          	beq	a5,s10,698 <vprintf+0xf2>
      } else if(c == 'p') {
 62c:	09b78463          	beq	a5,s11,6b4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 630:	07300713          	li	a4,115
 634:	0ce78663          	beq	a5,a4,700 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 638:	06300713          	li	a4,99
 63c:	0ee78e63          	beq	a5,a4,738 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 640:	11478863          	beq	a5,s4,750 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 644:	85d2                	mv	a1,s4
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	dea080e7          	jalr	-534(ra) # 432 <putc>
        putc(fd, c);
 650:	85ca                	mv	a1,s2
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	dde080e7          	jalr	-546(ra) # 432 <putc>
      }
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b765                	j	606 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 660:	008b0913          	addi	s2,s6,8
 664:	4685                	li	a3,1
 666:	4629                	li	a2,10
 668:	000b2583          	lw	a1,0(s6)
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	e4a080e7          	jalr	-438(ra) # 4b8 <printint>
 676:	8b4a                	mv	s6,s2
      state = 0;
 678:	4981                	li	s3,0
 67a:	b771                	j	606 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 67c:	008b0913          	addi	s2,s6,8
 680:	4681                	li	a3,0
 682:	4629                	li	a2,10
 684:	000b2583          	lw	a1,0(s6)
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	e2e080e7          	jalr	-466(ra) # 4b8 <printint>
 692:	8b4a                	mv	s6,s2
      state = 0;
 694:	4981                	li	s3,0
 696:	bf85                	j	606 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 698:	008b0913          	addi	s2,s6,8
 69c:	4681                	li	a3,0
 69e:	4641                	li	a2,16
 6a0:	000b2583          	lw	a1,0(s6)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e12080e7          	jalr	-494(ra) # 4b8 <printint>
 6ae:	8b4a                	mv	s6,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bf91                	j	606 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6b4:	008b0793          	addi	a5,s6,8
 6b8:	f8f43423          	sd	a5,-120(s0)
 6bc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6c0:	03000593          	li	a1,48
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	d6c080e7          	jalr	-660(ra) # 432 <putc>
  putc(fd, 'x');
 6ce:	85ea                	mv	a1,s10
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	d60080e7          	jalr	-672(ra) # 432 <putc>
 6da:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6dc:	03c9d793          	srli	a5,s3,0x3c
 6e0:	97de                	add	a5,a5,s7
 6e2:	0007c583          	lbu	a1,0(a5)
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	d4a080e7          	jalr	-694(ra) # 432 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6f0:	0992                	slli	s3,s3,0x4
 6f2:	397d                	addiw	s2,s2,-1
 6f4:	fe0914e3          	bnez	s2,6dc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6f8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	b721                	j	606 <vprintf+0x60>
        s = va_arg(ap, char*);
 700:	008b0993          	addi	s3,s6,8
 704:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 708:	02090163          	beqz	s2,72a <vprintf+0x184>
        while(*s != 0){
 70c:	00094583          	lbu	a1,0(s2)
 710:	c9a1                	beqz	a1,760 <vprintf+0x1ba>
          putc(fd, *s);
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	d1e080e7          	jalr	-738(ra) # 432 <putc>
          s++;
 71c:	0905                	addi	s2,s2,1
        while(*s != 0){
 71e:	00094583          	lbu	a1,0(s2)
 722:	f9e5                	bnez	a1,712 <vprintf+0x16c>
        s = va_arg(ap, char*);
 724:	8b4e                	mv	s6,s3
      state = 0;
 726:	4981                	li	s3,0
 728:	bdf9                	j	606 <vprintf+0x60>
          s = "(null)";
 72a:	00000917          	auipc	s2,0x0
 72e:	25690913          	addi	s2,s2,598 # 980 <malloc+0x110>
        while(*s != 0){
 732:	02800593          	li	a1,40
 736:	bff1                	j	712 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 738:	008b0913          	addi	s2,s6,8
 73c:	000b4583          	lbu	a1,0(s6)
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	cf0080e7          	jalr	-784(ra) # 432 <putc>
 74a:	8b4a                	mv	s6,s2
      state = 0;
 74c:	4981                	li	s3,0
 74e:	bd65                	j	606 <vprintf+0x60>
        putc(fd, c);
 750:	85d2                	mv	a1,s4
 752:	8556                	mv	a0,s5
 754:	00000097          	auipc	ra,0x0
 758:	cde080e7          	jalr	-802(ra) # 432 <putc>
      state = 0;
 75c:	4981                	li	s3,0
 75e:	b565                	j	606 <vprintf+0x60>
        s = va_arg(ap, char*);
 760:	8b4e                	mv	s6,s3
      state = 0;
 762:	4981                	li	s3,0
 764:	b54d                	j	606 <vprintf+0x60>
    }
  }
}
 766:	70e6                	ld	ra,120(sp)
 768:	7446                	ld	s0,112(sp)
 76a:	74a6                	ld	s1,104(sp)
 76c:	7906                	ld	s2,96(sp)
 76e:	69e6                	ld	s3,88(sp)
 770:	6a46                	ld	s4,80(sp)
 772:	6aa6                	ld	s5,72(sp)
 774:	6b06                	ld	s6,64(sp)
 776:	7be2                	ld	s7,56(sp)
 778:	7c42                	ld	s8,48(sp)
 77a:	7ca2                	ld	s9,40(sp)
 77c:	7d02                	ld	s10,32(sp)
 77e:	6de2                	ld	s11,24(sp)
 780:	6109                	addi	sp,sp,128
 782:	8082                	ret

0000000000000784 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 784:	715d                	addi	sp,sp,-80
 786:	ec06                	sd	ra,24(sp)
 788:	e822                	sd	s0,16(sp)
 78a:	1000                	addi	s0,sp,32
 78c:	e010                	sd	a2,0(s0)
 78e:	e414                	sd	a3,8(s0)
 790:	e818                	sd	a4,16(s0)
 792:	ec1c                	sd	a5,24(s0)
 794:	03043023          	sd	a6,32(s0)
 798:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 79c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7a0:	8622                	mv	a2,s0
 7a2:	00000097          	auipc	ra,0x0
 7a6:	e04080e7          	jalr	-508(ra) # 5a6 <vprintf>
}
 7aa:	60e2                	ld	ra,24(sp)
 7ac:	6442                	ld	s0,16(sp)
 7ae:	6161                	addi	sp,sp,80
 7b0:	8082                	ret

00000000000007b2 <printf>:

void
printf(const char *fmt, ...)
{
 7b2:	711d                	addi	sp,sp,-96
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	1000                	addi	s0,sp,32
 7ba:	e40c                	sd	a1,8(s0)
 7bc:	e810                	sd	a2,16(s0)
 7be:	ec14                	sd	a3,24(s0)
 7c0:	f018                	sd	a4,32(s0)
 7c2:	f41c                	sd	a5,40(s0)
 7c4:	03043823          	sd	a6,48(s0)
 7c8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7cc:	00840613          	addi	a2,s0,8
 7d0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7d4:	85aa                	mv	a1,a0
 7d6:	4505                	li	a0,1
 7d8:	00000097          	auipc	ra,0x0
 7dc:	dce080e7          	jalr	-562(ra) # 5a6 <vprintf>
}
 7e0:	60e2                	ld	ra,24(sp)
 7e2:	6442                	ld	s0,16(sp)
 7e4:	6125                	addi	sp,sp,96
 7e6:	8082                	ret

00000000000007e8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e8:	1141                	addi	sp,sp,-16
 7ea:	e422                	sd	s0,8(sp)
 7ec:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ee:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7f2:	00000797          	auipc	a5,0x0
 7f6:	1ae7b783          	ld	a5,430(a5) # 9a0 <freep>
 7fa:	a805                	j	82a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7fc:	4618                	lw	a4,8(a2)
 7fe:	9db9                	addw	a1,a1,a4
 800:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 804:	6398                	ld	a4,0(a5)
 806:	6318                	ld	a4,0(a4)
 808:	fee53823          	sd	a4,-16(a0)
 80c:	a091                	j	850 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 80e:	ff852703          	lw	a4,-8(a0)
 812:	9e39                	addw	a2,a2,a4
 814:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 816:	ff053703          	ld	a4,-16(a0)
 81a:	e398                	sd	a4,0(a5)
 81c:	a099                	j	862 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81e:	6398                	ld	a4,0(a5)
 820:	00e7e463          	bltu	a5,a4,828 <free+0x40>
 824:	00e6ea63          	bltu	a3,a4,838 <free+0x50>
{
 828:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82a:	fed7fae3          	bgeu	a5,a3,81e <free+0x36>
 82e:	6398                	ld	a4,0(a5)
 830:	00e6e463          	bltu	a3,a4,838 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 834:	fee7eae3          	bltu	a5,a4,828 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 838:	ff852583          	lw	a1,-8(a0)
 83c:	6390                	ld	a2,0(a5)
 83e:	02059713          	slli	a4,a1,0x20
 842:	9301                	srli	a4,a4,0x20
 844:	0712                	slli	a4,a4,0x4
 846:	9736                	add	a4,a4,a3
 848:	fae60ae3          	beq	a2,a4,7fc <free+0x14>
    bp->s.ptr = p->s.ptr;
 84c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 850:	4790                	lw	a2,8(a5)
 852:	02061713          	slli	a4,a2,0x20
 856:	9301                	srli	a4,a4,0x20
 858:	0712                	slli	a4,a4,0x4
 85a:	973e                	add	a4,a4,a5
 85c:	fae689e3          	beq	a3,a4,80e <free+0x26>
  } else
    p->s.ptr = bp;
 860:	e394                	sd	a3,0(a5)
  freep = p;
 862:	00000717          	auipc	a4,0x0
 866:	12f73f23          	sd	a5,318(a4) # 9a0 <freep>
}
 86a:	6422                	ld	s0,8(sp)
 86c:	0141                	addi	sp,sp,16
 86e:	8082                	ret

0000000000000870 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 870:	7139                	addi	sp,sp,-64
 872:	fc06                	sd	ra,56(sp)
 874:	f822                	sd	s0,48(sp)
 876:	f426                	sd	s1,40(sp)
 878:	f04a                	sd	s2,32(sp)
 87a:	ec4e                	sd	s3,24(sp)
 87c:	e852                	sd	s4,16(sp)
 87e:	e456                	sd	s5,8(sp)
 880:	e05a                	sd	s6,0(sp)
 882:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 884:	02051493          	slli	s1,a0,0x20
 888:	9081                	srli	s1,s1,0x20
 88a:	04bd                	addi	s1,s1,15
 88c:	8091                	srli	s1,s1,0x4
 88e:	0014899b          	addiw	s3,s1,1
 892:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 894:	00000517          	auipc	a0,0x0
 898:	10c53503          	ld	a0,268(a0) # 9a0 <freep>
 89c:	c515                	beqz	a0,8c8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a0:	4798                	lw	a4,8(a5)
 8a2:	02977f63          	bgeu	a4,s1,8e0 <malloc+0x70>
 8a6:	8a4e                	mv	s4,s3
 8a8:	0009871b          	sext.w	a4,s3
 8ac:	6685                	lui	a3,0x1
 8ae:	00d77363          	bgeu	a4,a3,8b4 <malloc+0x44>
 8b2:	6a05                	lui	s4,0x1
 8b4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8b8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8bc:	00000917          	auipc	s2,0x0
 8c0:	0e490913          	addi	s2,s2,228 # 9a0 <freep>
  if(p == (char*)-1)
 8c4:	5afd                	li	s5,-1
 8c6:	a88d                	j	938 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8c8:	00000797          	auipc	a5,0x0
 8cc:	59078793          	addi	a5,a5,1424 # e58 <base>
 8d0:	00000717          	auipc	a4,0x0
 8d4:	0cf73823          	sd	a5,208(a4) # 9a0 <freep>
 8d8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8da:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8de:	b7e1                	j	8a6 <malloc+0x36>
      if(p->s.size == nunits)
 8e0:	02e48b63          	beq	s1,a4,916 <malloc+0xa6>
        p->s.size -= nunits;
 8e4:	4137073b          	subw	a4,a4,s3
 8e8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ea:	1702                	slli	a4,a4,0x20
 8ec:	9301                	srli	a4,a4,0x20
 8ee:	0712                	slli	a4,a4,0x4
 8f0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f6:	00000717          	auipc	a4,0x0
 8fa:	0aa73523          	sd	a0,170(a4) # 9a0 <freep>
      return (void*)(p + 1);
 8fe:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 902:	70e2                	ld	ra,56(sp)
 904:	7442                	ld	s0,48(sp)
 906:	74a2                	ld	s1,40(sp)
 908:	7902                	ld	s2,32(sp)
 90a:	69e2                	ld	s3,24(sp)
 90c:	6a42                	ld	s4,16(sp)
 90e:	6aa2                	ld	s5,8(sp)
 910:	6b02                	ld	s6,0(sp)
 912:	6121                	addi	sp,sp,64
 914:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 916:	6398                	ld	a4,0(a5)
 918:	e118                	sd	a4,0(a0)
 91a:	bff1                	j	8f6 <malloc+0x86>
  hp->s.size = nu;
 91c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 920:	0541                	addi	a0,a0,16
 922:	00000097          	auipc	ra,0x0
 926:	ec6080e7          	jalr	-314(ra) # 7e8 <free>
  return freep;
 92a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 92e:	d971                	beqz	a0,902 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 930:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 932:	4798                	lw	a4,8(a5)
 934:	fa9776e3          	bgeu	a4,s1,8e0 <malloc+0x70>
    if(p == freep)
 938:	00093703          	ld	a4,0(s2)
 93c:	853e                	mv	a0,a5
 93e:	fef719e3          	bne	a4,a5,930 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 942:	8552                	mv	a0,s4
 944:	00000097          	auipc	ra,0x0
 948:	a62080e7          	jalr	-1438(ra) # 3a6 <sbrk>
  if(p == (char*)-1)
 94c:	fd5518e3          	bne	a0,s5,91c <malloc+0xac>
        return 0;
 950:	4501                	li	a0,0
 952:	bf45                	j	902 <malloc+0x92>
