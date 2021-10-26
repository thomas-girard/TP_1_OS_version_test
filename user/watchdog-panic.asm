
user/_watchdog-panic:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "user/user.h"

int main(){
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
  int watchdog_fd;
  if((watchdog_fd = open("watchdog", O_WRONLY)) < 0){
   e:	4585                	li	a1,1
  10:	00001517          	auipc	a0,0x1
  14:	97050513          	addi	a0,a0,-1680 # 980 <malloc+0xe6>
  18:	00000097          	auipc	ra,0x0
  1c:	370080e7          	jalr	880(ra) # 388 <open>
  20:	84aa                	mv	s1,a0
  22:	02054c63          	bltz	a0,5a <main+0x5a>
    mknod("watchdog", 2, 1);
    watchdog_fd = open("watchdog", O_WRONLY);
  }
  while(1){
    printf("Watchdog...\n");
  26:	00001997          	auipc	s3,0x1
  2a:	96a98993          	addi	s3,s3,-1686 # 990 <malloc+0xf6>
    char reset = 13;
  2e:	4935                	li	s2,13
    printf("Watchdog...\n");
  30:	854e                	mv	a0,s3
  32:	00000097          	auipc	ra,0x0
  36:	7aa080e7          	jalr	1962(ra) # 7dc <printf>
    char reset = 13;
  3a:	fd2407a3          	sb	s2,-49(s0)
    write(watchdog_fd, &reset, 1);
  3e:	4605                	li	a2,1
  40:	fcf40593          	addi	a1,s0,-49
  44:	8526                	mv	a0,s1
  46:	00000097          	auipc	ra,0x0
  4a:	322080e7          	jalr	802(ra) # 368 <write>
    sleep(15);
  4e:	453d                	li	a0,15
  50:	00000097          	auipc	ra,0x0
  54:	388080e7          	jalr	904(ra) # 3d8 <sleep>
  while(1){
  58:	bfe1                	j	30 <main+0x30>
    mknod("watchdog", 2, 1);
  5a:	4605                	li	a2,1
  5c:	4589                	li	a1,2
  5e:	00001517          	auipc	a0,0x1
  62:	92250513          	addi	a0,a0,-1758 # 980 <malloc+0xe6>
  66:	00000097          	auipc	ra,0x0
  6a:	32a080e7          	jalr	810(ra) # 390 <mknod>
    watchdog_fd = open("watchdog", O_WRONLY);
  6e:	4585                	li	a1,1
  70:	00001517          	auipc	a0,0x1
  74:	91050513          	addi	a0,a0,-1776 # 980 <malloc+0xe6>
  78:	00000097          	auipc	ra,0x0
  7c:	310080e7          	jalr	784(ra) # 388 <open>
  80:	84aa                	mv	s1,a0
  82:	b755                	j	26 <main+0x26>

0000000000000084 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8a:	87aa                	mv	a5,a0
  8c:	0585                	addi	a1,a1,1
  8e:	0785                	addi	a5,a5,1
  90:	fff5c703          	lbu	a4,-1(a1)
  94:	fee78fa3          	sb	a4,-1(a5)
  98:	fb75                	bnez	a4,8c <strcpy+0x8>
    ;
  return os;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cb91                	beqz	a5,be <strcmp+0x1e>
  ac:	0005c703          	lbu	a4,0(a1)
  b0:	00f71763          	bne	a4,a5,be <strcmp+0x1e>
    p++, q++;
  b4:	0505                	addi	a0,a0,1
  b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	fbe5                	bnez	a5,ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  be:	0005c503          	lbu	a0,0(a1)
}
  c2:	40a7853b          	subw	a0,a5,a0
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strlen>:

uint
strlen(const char *s)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	cf91                	beqz	a5,f2 <strlen+0x26>
  d8:	0505                	addi	a0,a0,1
  da:	87aa                	mv	a5,a0
  dc:	4685                	li	a3,1
  de:	9e89                	subw	a3,a3,a0
  e0:	00f6853b          	addw	a0,a3,a5
  e4:	0785                	addi	a5,a5,1
  e6:	fff7c703          	lbu	a4,-1(a5)
  ea:	fb7d                	bnez	a4,e0 <strlen+0x14>
    ;
  return n;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  for(n = 0; s[n]; n++)
  f2:	4501                	li	a0,0
  f4:	bfe5                	j	ec <strlen+0x20>

00000000000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fc:	ce09                	beqz	a2,116 <memset+0x20>
  fe:	87aa                	mv	a5,a0
 100:	fff6071b          	addiw	a4,a2,-1
 104:	1702                	slli	a4,a4,0x20
 106:	9301                	srli	a4,a4,0x20
 108:	0705                	addi	a4,a4,1
 10a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 10c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 110:	0785                	addi	a5,a5,1
 112:	fee79de3          	bne	a5,a4,10c <memset+0x16>
  }
  return dst;
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strchr>:

char*
strchr(const char *s, char c)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  for(; *s; s++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cb99                	beqz	a5,13c <strchr+0x20>
    if(*s == c)
 128:	00f58763          	beq	a1,a5,136 <strchr+0x1a>
  for(; *s; s++)
 12c:	0505                	addi	a0,a0,1
 12e:	00054783          	lbu	a5,0(a0)
 132:	fbfd                	bnez	a5,128 <strchr+0xc>
      return (char*)s;
  return 0;
 134:	4501                	li	a0,0
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret
  return 0;
 13c:	4501                	li	a0,0
 13e:	bfe5                	j	136 <strchr+0x1a>

0000000000000140 <gets>:

char*
gets(char *buf, int max)
{
 140:	711d                	addi	sp,sp,-96
 142:	ec86                	sd	ra,88(sp)
 144:	e8a2                	sd	s0,80(sp)
 146:	e4a6                	sd	s1,72(sp)
 148:	e0ca                	sd	s2,64(sp)
 14a:	fc4e                	sd	s3,56(sp)
 14c:	f852                	sd	s4,48(sp)
 14e:	f456                	sd	s5,40(sp)
 150:	f05a                	sd	s6,32(sp)
 152:	ec5e                	sd	s7,24(sp)
 154:	1080                	addi	s0,sp,96
 156:	8baa                	mv	s7,a0
 158:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15a:	892a                	mv	s2,a0
 15c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15e:	4aa9                	li	s5,10
 160:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 162:	89a6                	mv	s3,s1
 164:	2485                	addiw	s1,s1,1
 166:	0344d863          	bge	s1,s4,196 <gets+0x56>
    cc = read(0, &c, 1);
 16a:	4605                	li	a2,1
 16c:	faf40593          	addi	a1,s0,-81
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	1ee080e7          	jalr	494(ra) # 360 <read>
    if(cc < 1)
 17a:	00a05e63          	blez	a0,196 <gets+0x56>
    buf[i++] = c;
 17e:	faf44783          	lbu	a5,-81(s0)
 182:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 186:	01578763          	beq	a5,s5,194 <gets+0x54>
 18a:	0905                	addi	s2,s2,1
 18c:	fd679be3          	bne	a5,s6,162 <gets+0x22>
  for(i=0; i+1 < max; ){
 190:	89a6                	mv	s3,s1
 192:	a011                	j	196 <gets+0x56>
 194:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 196:	99de                	add	s3,s3,s7
 198:	00098023          	sb	zero,0(s3)
  return buf;
}
 19c:	855e                	mv	a0,s7
 19e:	60e6                	ld	ra,88(sp)
 1a0:	6446                	ld	s0,80(sp)
 1a2:	64a6                	ld	s1,72(sp)
 1a4:	6906                	ld	s2,64(sp)
 1a6:	79e2                	ld	s3,56(sp)
 1a8:	7a42                	ld	s4,48(sp)
 1aa:	7aa2                	ld	s5,40(sp)
 1ac:	7b02                	ld	s6,32(sp)
 1ae:	6be2                	ld	s7,24(sp)
 1b0:	6125                	addi	sp,sp,96
 1b2:	8082                	ret

00000000000001b4 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ba:	00054603          	lbu	a2,0(a0)
 1be:	fd06079b          	addiw	a5,a2,-48
 1c2:	0ff7f793          	andi	a5,a5,255
 1c6:	4725                	li	a4,9
 1c8:	02f76963          	bltu	a4,a5,1fa <atoi+0x46>
 1cc:	86aa                	mv	a3,a0
  n = 0;
 1ce:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1d0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1d2:	0685                	addi	a3,a3,1
 1d4:	0025179b          	slliw	a5,a0,0x2
 1d8:	9fa9                	addw	a5,a5,a0
 1da:	0017979b          	slliw	a5,a5,0x1
 1de:	9fb1                	addw	a5,a5,a2
 1e0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e4:	0006c603          	lbu	a2,0(a3)
 1e8:	fd06071b          	addiw	a4,a2,-48
 1ec:	0ff77713          	andi	a4,a4,255
 1f0:	fee5f1e3          	bgeu	a1,a4,1d2 <atoi+0x1e>
  return n;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret
  n = 0;
 1fa:	4501                	li	a0,0
 1fc:	bfe5                	j	1f4 <atoi+0x40>

00000000000001fe <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1fe:	1141                	addi	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 204:	02b57663          	bgeu	a0,a1,230 <memmove+0x32>
    while(n-- > 0)
 208:	02c05163          	blez	a2,22a <memmove+0x2c>
 20c:	fff6079b          	addiw	a5,a2,-1
 210:	1782                	slli	a5,a5,0x20
 212:	9381                	srli	a5,a5,0x20
 214:	0785                	addi	a5,a5,1
 216:	97aa                	add	a5,a5,a0
  dst = vdst;
 218:	872a                	mv	a4,a0
      *dst++ = *src++;
 21a:	0585                	addi	a1,a1,1
 21c:	0705                	addi	a4,a4,1
 21e:	fff5c683          	lbu	a3,-1(a1)
 222:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 226:	fee79ae3          	bne	a5,a4,21a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
    dst += n;
 230:	00c50733          	add	a4,a0,a2
    src += n;
 234:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 236:	fec05ae3          	blez	a2,22a <memmove+0x2c>
 23a:	fff6079b          	addiw	a5,a2,-1
 23e:	1782                	slli	a5,a5,0x20
 240:	9381                	srli	a5,a5,0x20
 242:	fff7c793          	not	a5,a5
 246:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 248:	15fd                	addi	a1,a1,-1
 24a:	177d                	addi	a4,a4,-1
 24c:	0005c683          	lbu	a3,0(a1)
 250:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 254:	fee79ae3          	bne	a5,a4,248 <memmove+0x4a>
 258:	bfc9                	j	22a <memmove+0x2c>

000000000000025a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 260:	ca05                	beqz	a2,290 <memcmp+0x36>
 262:	fff6069b          	addiw	a3,a2,-1
 266:	1682                	slli	a3,a3,0x20
 268:	9281                	srli	a3,a3,0x20
 26a:	0685                	addi	a3,a3,1
 26c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 26e:	00054783          	lbu	a5,0(a0)
 272:	0005c703          	lbu	a4,0(a1)
 276:	00e79863          	bne	a5,a4,286 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 27a:	0505                	addi	a0,a0,1
    p2++;
 27c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 27e:	fed518e3          	bne	a0,a3,26e <memcmp+0x14>
  }
  return 0;
 282:	4501                	li	a0,0
 284:	a019                	j	28a <memcmp+0x30>
      return *p1 - *p2;
 286:	40e7853b          	subw	a0,a5,a4
}
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
  return 0;
 290:	4501                	li	a0,0
 292:	bfe5                	j	28a <memcmp+0x30>

0000000000000294 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e406                	sd	ra,8(sp)
 298:	e022                	sd	s0,0(sp)
 29a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 29c:	00000097          	auipc	ra,0x0
 2a0:	f62080e7          	jalr	-158(ra) # 1fe <memmove>
}
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret

00000000000002ac <close>:

int close(int fd){
 2ac:	1101                	addi	sp,sp,-32
 2ae:	ec06                	sd	ra,24(sp)
 2b0:	e822                	sd	s0,16(sp)
 2b2:	e426                	sd	s1,8(sp)
 2b4:	1000                	addi	s0,sp,32
 2b6:	84aa                	mv	s1,a0
  fflush(fd);
 2b8:	00000097          	auipc	ra,0x0
 2bc:	2d4080e7          	jalr	724(ra) # 58c <fflush>
  char* buf = get_putc_buf(fd);
 2c0:	8526                	mv	a0,s1
 2c2:	00000097          	auipc	ra,0x0
 2c6:	14e080e7          	jalr	334(ra) # 410 <get_putc_buf>
  if(buf){
 2ca:	cd11                	beqz	a0,2e6 <close+0x3a>
    free(buf);
 2cc:	00000097          	auipc	ra,0x0
 2d0:	546080e7          	jalr	1350(ra) # 812 <free>
    putc_buf[fd] = 0;
 2d4:	00349713          	slli	a4,s1,0x3
 2d8:	00000797          	auipc	a5,0x0
 2dc:	6f078793          	addi	a5,a5,1776 # 9c8 <putc_buf>
 2e0:	97ba                	add	a5,a5,a4
 2e2:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 2e6:	8526                	mv	a0,s1
 2e8:	00000097          	auipc	ra,0x0
 2ec:	088080e7          	jalr	136(ra) # 370 <sclose>
}
 2f0:	60e2                	ld	ra,24(sp)
 2f2:	6442                	ld	s0,16(sp)
 2f4:	64a2                	ld	s1,8(sp)
 2f6:	6105                	addi	sp,sp,32
 2f8:	8082                	ret

00000000000002fa <stat>:
{
 2fa:	1101                	addi	sp,sp,-32
 2fc:	ec06                	sd	ra,24(sp)
 2fe:	e822                	sd	s0,16(sp)
 300:	e426                	sd	s1,8(sp)
 302:	e04a                	sd	s2,0(sp)
 304:	1000                	addi	s0,sp,32
 306:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 308:	4581                	li	a1,0
 30a:	00000097          	auipc	ra,0x0
 30e:	07e080e7          	jalr	126(ra) # 388 <open>
  if(fd < 0)
 312:	02054563          	bltz	a0,33c <stat+0x42>
 316:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 318:	85ca                	mv	a1,s2
 31a:	00000097          	auipc	ra,0x0
 31e:	086080e7          	jalr	134(ra) # 3a0 <fstat>
 322:	892a                	mv	s2,a0
  close(fd);
 324:	8526                	mv	a0,s1
 326:	00000097          	auipc	ra,0x0
 32a:	f86080e7          	jalr	-122(ra) # 2ac <close>
}
 32e:	854a                	mv	a0,s2
 330:	60e2                	ld	ra,24(sp)
 332:	6442                	ld	s0,16(sp)
 334:	64a2                	ld	s1,8(sp)
 336:	6902                	ld	s2,0(sp)
 338:	6105                	addi	sp,sp,32
 33a:	8082                	ret
    return -1;
 33c:	597d                	li	s2,-1
 33e:	bfc5                	j	32e <stat+0x34>

0000000000000340 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 340:	4885                	li	a7,1
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <exit>:
.global exit
exit:
 li a7, SYS_exit
 348:	4889                	li	a7,2
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <wait>:
.global wait
wait:
 li a7, SYS_wait
 350:	488d                	li	a7,3
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 358:	4891                	li	a7,4
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <read>:
.global read
read:
 li a7, SYS_read
 360:	4895                	li	a7,5
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <write>:
.global write
write:
 li a7, SYS_write
 368:	48c1                	li	a7,16
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 370:	48d5                	li	a7,21
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <kill>:
.global kill
kill:
 li a7, SYS_kill
 378:	4899                	li	a7,6
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <exec>:
.global exec
exec:
 li a7, SYS_exec
 380:	489d                	li	a7,7
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <open>:
.global open
open:
 li a7, SYS_open
 388:	48bd                	li	a7,15
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 390:	48c5                	li	a7,17
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 398:	48c9                	li	a7,18
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a0:	48a1                	li	a7,8
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <link>:
.global link
link:
 li a7, SYS_link
 3a8:	48cd                	li	a7,19
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b0:	48d1                	li	a7,20
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b8:	48a5                	li	a7,9
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c0:	48a9                	li	a7,10
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c8:	48ad                	li	a7,11
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3d0:	48b1                	li	a7,12
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d8:	48b5                	li	a7,13
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e0:	48b9                	li	a7,14
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 3e8:	48d9                	li	a7,22
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <nice>:
.global nice
nice:
 li a7, SYS_nice
 3f0:	48dd                	li	a7,23
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 3f8:	48e1                	li	a7,24
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 400:	48e5                	li	a7,25
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 408:	48e9                	li	a7,26
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 410:	1101                	addi	sp,sp,-32
 412:	ec06                	sd	ra,24(sp)
 414:	e822                	sd	s0,16(sp)
 416:	e426                	sd	s1,8(sp)
 418:	1000                	addi	s0,sp,32
 41a:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 41c:	00351713          	slli	a4,a0,0x3
 420:	00000797          	auipc	a5,0x0
 424:	5a878793          	addi	a5,a5,1448 # 9c8 <putc_buf>
 428:	97ba                	add	a5,a5,a4
 42a:	6388                	ld	a0,0(a5)
  if(buf) {
 42c:	c511                	beqz	a0,438 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 42e:	60e2                	ld	ra,24(sp)
 430:	6442                	ld	s0,16(sp)
 432:	64a2                	ld	s1,8(sp)
 434:	6105                	addi	sp,sp,32
 436:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 438:	6505                	lui	a0,0x1
 43a:	00000097          	auipc	ra,0x0
 43e:	460080e7          	jalr	1120(ra) # 89a <malloc>
  putc_buf[fd] = buf;
 442:	00000797          	auipc	a5,0x0
 446:	58678793          	addi	a5,a5,1414 # 9c8 <putc_buf>
 44a:	00349713          	slli	a4,s1,0x3
 44e:	973e                	add	a4,a4,a5
 450:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 452:	048a                	slli	s1,s1,0x2
 454:	94be                	add	s1,s1,a5
 456:	3204a023          	sw	zero,800(s1)
  return buf;
 45a:	bfd1                	j	42e <get_putc_buf+0x1e>

000000000000045c <putc>:

static void
putc(int fd, char c)
{
 45c:	1101                	addi	sp,sp,-32
 45e:	ec06                	sd	ra,24(sp)
 460:	e822                	sd	s0,16(sp)
 462:	e426                	sd	s1,8(sp)
 464:	e04a                	sd	s2,0(sp)
 466:	1000                	addi	s0,sp,32
 468:	84aa                	mv	s1,a0
 46a:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 46c:	00000097          	auipc	ra,0x0
 470:	fa4080e7          	jalr	-92(ra) # 410 <get_putc_buf>
  buf[putc_index[fd]++] = c;
 474:	00249793          	slli	a5,s1,0x2
 478:	00000717          	auipc	a4,0x0
 47c:	55070713          	addi	a4,a4,1360 # 9c8 <putc_buf>
 480:	973e                	add	a4,a4,a5
 482:	32072783          	lw	a5,800(a4)
 486:	0017869b          	addiw	a3,a5,1
 48a:	32d72023          	sw	a3,800(a4)
 48e:	97aa                	add	a5,a5,a0
 490:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 494:	47a9                	li	a5,10
 496:	02f90463          	beq	s2,a5,4be <putc+0x62>
 49a:	00249713          	slli	a4,s1,0x2
 49e:	00000797          	auipc	a5,0x0
 4a2:	52a78793          	addi	a5,a5,1322 # 9c8 <putc_buf>
 4a6:	97ba                	add	a5,a5,a4
 4a8:	3207a703          	lw	a4,800(a5)
 4ac:	6785                	lui	a5,0x1
 4ae:	00f70863          	beq	a4,a5,4be <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 4b2:	60e2                	ld	ra,24(sp)
 4b4:	6442                	ld	s0,16(sp)
 4b6:	64a2                	ld	s1,8(sp)
 4b8:	6902                	ld	s2,0(sp)
 4ba:	6105                	addi	sp,sp,32
 4bc:	8082                	ret
    write(fd, buf, putc_index[fd]);
 4be:	00249793          	slli	a5,s1,0x2
 4c2:	00000917          	auipc	s2,0x0
 4c6:	50690913          	addi	s2,s2,1286 # 9c8 <putc_buf>
 4ca:	993e                	add	s2,s2,a5
 4cc:	32092603          	lw	a2,800(s2)
 4d0:	85aa                	mv	a1,a0
 4d2:	8526                	mv	a0,s1
 4d4:	00000097          	auipc	ra,0x0
 4d8:	e94080e7          	jalr	-364(ra) # 368 <write>
    putc_index[fd] = 0;
 4dc:	32092023          	sw	zero,800(s2)
}
 4e0:	bfc9                	j	4b2 <putc+0x56>

00000000000004e2 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 4e2:	7139                	addi	sp,sp,-64
 4e4:	fc06                	sd	ra,56(sp)
 4e6:	f822                	sd	s0,48(sp)
 4e8:	f426                	sd	s1,40(sp)
 4ea:	f04a                	sd	s2,32(sp)
 4ec:	ec4e                	sd	s3,24(sp)
 4ee:	0080                	addi	s0,sp,64
 4f0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4f2:	c299                	beqz	a3,4f8 <printint+0x16>
 4f4:	0805c863          	bltz	a1,584 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4f8:	2581                	sext.w	a1,a1
  neg = 0;
 4fa:	4881                	li	a7,0
 4fc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 500:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 502:	2601                	sext.w	a2,a2
 504:	00000517          	auipc	a0,0x0
 508:	4a450513          	addi	a0,a0,1188 # 9a8 <digits>
 50c:	883a                	mv	a6,a4
 50e:	2705                	addiw	a4,a4,1
 510:	02c5f7bb          	remuw	a5,a1,a2
 514:	1782                	slli	a5,a5,0x20
 516:	9381                	srli	a5,a5,0x20
 518:	97aa                	add	a5,a5,a0
 51a:	0007c783          	lbu	a5,0(a5) # 1000 <__BSS_END__+0x178>
 51e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 522:	0005879b          	sext.w	a5,a1
 526:	02c5d5bb          	divuw	a1,a1,a2
 52a:	0685                	addi	a3,a3,1
 52c:	fec7f0e3          	bgeu	a5,a2,50c <printint+0x2a>
  if(neg)
 530:	00088b63          	beqz	a7,546 <printint+0x64>
    buf[i++] = '-';
 534:	fd040793          	addi	a5,s0,-48
 538:	973e                	add	a4,a4,a5
 53a:	02d00793          	li	a5,45
 53e:	fef70823          	sb	a5,-16(a4)
 542:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 546:	02e05863          	blez	a4,576 <printint+0x94>
 54a:	fc040793          	addi	a5,s0,-64
 54e:	00e78933          	add	s2,a5,a4
 552:	fff78993          	addi	s3,a5,-1
 556:	99ba                	add	s3,s3,a4
 558:	377d                	addiw	a4,a4,-1
 55a:	1702                	slli	a4,a4,0x20
 55c:	9301                	srli	a4,a4,0x20
 55e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 562:	fff94583          	lbu	a1,-1(s2)
 566:	8526                	mv	a0,s1
 568:	00000097          	auipc	ra,0x0
 56c:	ef4080e7          	jalr	-268(ra) # 45c <putc>
  while(--i >= 0)
 570:	197d                	addi	s2,s2,-1
 572:	ff3918e3          	bne	s2,s3,562 <printint+0x80>
}
 576:	70e2                	ld	ra,56(sp)
 578:	7442                	ld	s0,48(sp)
 57a:	74a2                	ld	s1,40(sp)
 57c:	7902                	ld	s2,32(sp)
 57e:	69e2                	ld	s3,24(sp)
 580:	6121                	addi	sp,sp,64
 582:	8082                	ret
    x = -xx;
 584:	40b005bb          	negw	a1,a1
    neg = 1;
 588:	4885                	li	a7,1
    x = -xx;
 58a:	bf8d                	j	4fc <printint+0x1a>

000000000000058c <fflush>:
void fflush(int fd){
 58c:	1101                	addi	sp,sp,-32
 58e:	ec06                	sd	ra,24(sp)
 590:	e822                	sd	s0,16(sp)
 592:	e426                	sd	s1,8(sp)
 594:	e04a                	sd	s2,0(sp)
 596:	1000                	addi	s0,sp,32
 598:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 59a:	00000097          	auipc	ra,0x0
 59e:	e76080e7          	jalr	-394(ra) # 410 <get_putc_buf>
 5a2:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 5a4:	00291793          	slli	a5,s2,0x2
 5a8:	00000497          	auipc	s1,0x0
 5ac:	42048493          	addi	s1,s1,1056 # 9c8 <putc_buf>
 5b0:	94be                	add	s1,s1,a5
 5b2:	3204a603          	lw	a2,800(s1)
 5b6:	854a                	mv	a0,s2
 5b8:	00000097          	auipc	ra,0x0
 5bc:	db0080e7          	jalr	-592(ra) # 368 <write>
  putc_index[fd] = 0;
 5c0:	3204a023          	sw	zero,800(s1)
}
 5c4:	60e2                	ld	ra,24(sp)
 5c6:	6442                	ld	s0,16(sp)
 5c8:	64a2                	ld	s1,8(sp)
 5ca:	6902                	ld	s2,0(sp)
 5cc:	6105                	addi	sp,sp,32
 5ce:	8082                	ret

00000000000005d0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d0:	7119                	addi	sp,sp,-128
 5d2:	fc86                	sd	ra,120(sp)
 5d4:	f8a2                	sd	s0,112(sp)
 5d6:	f4a6                	sd	s1,104(sp)
 5d8:	f0ca                	sd	s2,96(sp)
 5da:	ecce                	sd	s3,88(sp)
 5dc:	e8d2                	sd	s4,80(sp)
 5de:	e4d6                	sd	s5,72(sp)
 5e0:	e0da                	sd	s6,64(sp)
 5e2:	fc5e                	sd	s7,56(sp)
 5e4:	f862                	sd	s8,48(sp)
 5e6:	f466                	sd	s9,40(sp)
 5e8:	f06a                	sd	s10,32(sp)
 5ea:	ec6e                	sd	s11,24(sp)
 5ec:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ee:	0005c903          	lbu	s2,0(a1)
 5f2:	18090f63          	beqz	s2,790 <vprintf+0x1c0>
 5f6:	8aaa                	mv	s5,a0
 5f8:	8b32                	mv	s6,a2
 5fa:	00158493          	addi	s1,a1,1
  state = 0;
 5fe:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 600:	02500a13          	li	s4,37
      if(c == 'd'){
 604:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 608:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 60c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 610:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 614:	00000b97          	auipc	s7,0x0
 618:	394b8b93          	addi	s7,s7,916 # 9a8 <digits>
 61c:	a839                	j	63a <vprintf+0x6a>
        putc(fd, c);
 61e:	85ca                	mv	a1,s2
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	e3a080e7          	jalr	-454(ra) # 45c <putc>
 62a:	a019                	j	630 <vprintf+0x60>
    } else if(state == '%'){
 62c:	01498f63          	beq	s3,s4,64a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 630:	0485                	addi	s1,s1,1
 632:	fff4c903          	lbu	s2,-1(s1)
 636:	14090d63          	beqz	s2,790 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 63a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 63e:	fe0997e3          	bnez	s3,62c <vprintf+0x5c>
      if(c == '%'){
 642:	fd479ee3          	bne	a5,s4,61e <vprintf+0x4e>
        state = '%';
 646:	89be                	mv	s3,a5
 648:	b7e5                	j	630 <vprintf+0x60>
      if(c == 'd'){
 64a:	05878063          	beq	a5,s8,68a <vprintf+0xba>
      } else if(c == 'l') {
 64e:	05978c63          	beq	a5,s9,6a6 <vprintf+0xd6>
      } else if(c == 'x') {
 652:	07a78863          	beq	a5,s10,6c2 <vprintf+0xf2>
      } else if(c == 'p') {
 656:	09b78463          	beq	a5,s11,6de <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 65a:	07300713          	li	a4,115
 65e:	0ce78663          	beq	a5,a4,72a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 662:	06300713          	li	a4,99
 666:	0ee78e63          	beq	a5,a4,762 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 66a:	11478863          	beq	a5,s4,77a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 66e:	85d2                	mv	a1,s4
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	dea080e7          	jalr	-534(ra) # 45c <putc>
        putc(fd, c);
 67a:	85ca                	mv	a1,s2
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	dde080e7          	jalr	-546(ra) # 45c <putc>
      }
      state = 0;
 686:	4981                	li	s3,0
 688:	b765                	j	630 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 68a:	008b0913          	addi	s2,s6,8
 68e:	4685                	li	a3,1
 690:	4629                	li	a2,10
 692:	000b2583          	lw	a1,0(s6)
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	e4a080e7          	jalr	-438(ra) # 4e2 <printint>
 6a0:	8b4a                	mv	s6,s2
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b771                	j	630 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	008b0913          	addi	s2,s6,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000b2583          	lw	a1,0(s6)
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e2e080e7          	jalr	-466(ra) # 4e2 <printint>
 6bc:	8b4a                	mv	s6,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bf85                	j	630 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6c2:	008b0913          	addi	s2,s6,8
 6c6:	4681                	li	a3,0
 6c8:	4641                	li	a2,16
 6ca:	000b2583          	lw	a1,0(s6)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e12080e7          	jalr	-494(ra) # 4e2 <printint>
 6d8:	8b4a                	mv	s6,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bf91                	j	630 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6de:	008b0793          	addi	a5,s6,8
 6e2:	f8f43423          	sd	a5,-120(s0)
 6e6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6ea:	03000593          	li	a1,48
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	d6c080e7          	jalr	-660(ra) # 45c <putc>
  putc(fd, 'x');
 6f8:	85ea                	mv	a1,s10
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	d60080e7          	jalr	-672(ra) # 45c <putc>
 704:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 706:	03c9d793          	srli	a5,s3,0x3c
 70a:	97de                	add	a5,a5,s7
 70c:	0007c583          	lbu	a1,0(a5)
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	d4a080e7          	jalr	-694(ra) # 45c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71a:	0992                	slli	s3,s3,0x4
 71c:	397d                	addiw	s2,s2,-1
 71e:	fe0914e3          	bnez	s2,706 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 722:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 726:	4981                	li	s3,0
 728:	b721                	j	630 <vprintf+0x60>
        s = va_arg(ap, char*);
 72a:	008b0993          	addi	s3,s6,8
 72e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 732:	02090163          	beqz	s2,754 <vprintf+0x184>
        while(*s != 0){
 736:	00094583          	lbu	a1,0(s2)
 73a:	c9a1                	beqz	a1,78a <vprintf+0x1ba>
          putc(fd, *s);
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	d1e080e7          	jalr	-738(ra) # 45c <putc>
          s++;
 746:	0905                	addi	s2,s2,1
        while(*s != 0){
 748:	00094583          	lbu	a1,0(s2)
 74c:	f9e5                	bnez	a1,73c <vprintf+0x16c>
        s = va_arg(ap, char*);
 74e:	8b4e                	mv	s6,s3
      state = 0;
 750:	4981                	li	s3,0
 752:	bdf9                	j	630 <vprintf+0x60>
          s = "(null)";
 754:	00000917          	auipc	s2,0x0
 758:	24c90913          	addi	s2,s2,588 # 9a0 <malloc+0x106>
        while(*s != 0){
 75c:	02800593          	li	a1,40
 760:	bff1                	j	73c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 762:	008b0913          	addi	s2,s6,8
 766:	000b4583          	lbu	a1,0(s6)
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	cf0080e7          	jalr	-784(ra) # 45c <putc>
 774:	8b4a                	mv	s6,s2
      state = 0;
 776:	4981                	li	s3,0
 778:	bd65                	j	630 <vprintf+0x60>
        putc(fd, c);
 77a:	85d2                	mv	a1,s4
 77c:	8556                	mv	a0,s5
 77e:	00000097          	auipc	ra,0x0
 782:	cde080e7          	jalr	-802(ra) # 45c <putc>
      state = 0;
 786:	4981                	li	s3,0
 788:	b565                	j	630 <vprintf+0x60>
        s = va_arg(ap, char*);
 78a:	8b4e                	mv	s6,s3
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b54d                	j	630 <vprintf+0x60>
    }
  }
}
 790:	70e6                	ld	ra,120(sp)
 792:	7446                	ld	s0,112(sp)
 794:	74a6                	ld	s1,104(sp)
 796:	7906                	ld	s2,96(sp)
 798:	69e6                	ld	s3,88(sp)
 79a:	6a46                	ld	s4,80(sp)
 79c:	6aa6                	ld	s5,72(sp)
 79e:	6b06                	ld	s6,64(sp)
 7a0:	7be2                	ld	s7,56(sp)
 7a2:	7c42                	ld	s8,48(sp)
 7a4:	7ca2                	ld	s9,40(sp)
 7a6:	7d02                	ld	s10,32(sp)
 7a8:	6de2                	ld	s11,24(sp)
 7aa:	6109                	addi	sp,sp,128
 7ac:	8082                	ret

00000000000007ae <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ae:	715d                	addi	sp,sp,-80
 7b0:	ec06                	sd	ra,24(sp)
 7b2:	e822                	sd	s0,16(sp)
 7b4:	1000                	addi	s0,sp,32
 7b6:	e010                	sd	a2,0(s0)
 7b8:	e414                	sd	a3,8(s0)
 7ba:	e818                	sd	a4,16(s0)
 7bc:	ec1c                	sd	a5,24(s0)
 7be:	03043023          	sd	a6,32(s0)
 7c2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ca:	8622                	mv	a2,s0
 7cc:	00000097          	auipc	ra,0x0
 7d0:	e04080e7          	jalr	-508(ra) # 5d0 <vprintf>
}
 7d4:	60e2                	ld	ra,24(sp)
 7d6:	6442                	ld	s0,16(sp)
 7d8:	6161                	addi	sp,sp,80
 7da:	8082                	ret

00000000000007dc <printf>:

void
printf(const char *fmt, ...)
{
 7dc:	711d                	addi	sp,sp,-96
 7de:	ec06                	sd	ra,24(sp)
 7e0:	e822                	sd	s0,16(sp)
 7e2:	1000                	addi	s0,sp,32
 7e4:	e40c                	sd	a1,8(s0)
 7e6:	e810                	sd	a2,16(s0)
 7e8:	ec14                	sd	a3,24(s0)
 7ea:	f018                	sd	a4,32(s0)
 7ec:	f41c                	sd	a5,40(s0)
 7ee:	03043823          	sd	a6,48(s0)
 7f2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f6:	00840613          	addi	a2,s0,8
 7fa:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7fe:	85aa                	mv	a1,a0
 800:	4505                	li	a0,1
 802:	00000097          	auipc	ra,0x0
 806:	dce080e7          	jalr	-562(ra) # 5d0 <vprintf>
}
 80a:	60e2                	ld	ra,24(sp)
 80c:	6442                	ld	s0,16(sp)
 80e:	6125                	addi	sp,sp,96
 810:	8082                	ret

0000000000000812 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 812:	1141                	addi	sp,sp,-16
 814:	e422                	sd	s0,8(sp)
 816:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 818:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81c:	00000797          	auipc	a5,0x0
 820:	1a47b783          	ld	a5,420(a5) # 9c0 <freep>
 824:	a805                	j	854 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 826:	4618                	lw	a4,8(a2)
 828:	9db9                	addw	a1,a1,a4
 82a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 82e:	6398                	ld	a4,0(a5)
 830:	6318                	ld	a4,0(a4)
 832:	fee53823          	sd	a4,-16(a0)
 836:	a091                	j	87a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 838:	ff852703          	lw	a4,-8(a0)
 83c:	9e39                	addw	a2,a2,a4
 83e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 840:	ff053703          	ld	a4,-16(a0)
 844:	e398                	sd	a4,0(a5)
 846:	a099                	j	88c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 848:	6398                	ld	a4,0(a5)
 84a:	00e7e463          	bltu	a5,a4,852 <free+0x40>
 84e:	00e6ea63          	bltu	a3,a4,862 <free+0x50>
{
 852:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 854:	fed7fae3          	bgeu	a5,a3,848 <free+0x36>
 858:	6398                	ld	a4,0(a5)
 85a:	00e6e463          	bltu	a3,a4,862 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85e:	fee7eae3          	bltu	a5,a4,852 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 862:	ff852583          	lw	a1,-8(a0)
 866:	6390                	ld	a2,0(a5)
 868:	02059713          	slli	a4,a1,0x20
 86c:	9301                	srli	a4,a4,0x20
 86e:	0712                	slli	a4,a4,0x4
 870:	9736                	add	a4,a4,a3
 872:	fae60ae3          	beq	a2,a4,826 <free+0x14>
    bp->s.ptr = p->s.ptr;
 876:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 87a:	4790                	lw	a2,8(a5)
 87c:	02061713          	slli	a4,a2,0x20
 880:	9301                	srli	a4,a4,0x20
 882:	0712                	slli	a4,a4,0x4
 884:	973e                	add	a4,a4,a5
 886:	fae689e3          	beq	a3,a4,838 <free+0x26>
  } else
    p->s.ptr = bp;
 88a:	e394                	sd	a3,0(a5)
  freep = p;
 88c:	00000717          	auipc	a4,0x0
 890:	12f73a23          	sd	a5,308(a4) # 9c0 <freep>
}
 894:	6422                	ld	s0,8(sp)
 896:	0141                	addi	sp,sp,16
 898:	8082                	ret

000000000000089a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 89a:	7139                	addi	sp,sp,-64
 89c:	fc06                	sd	ra,56(sp)
 89e:	f822                	sd	s0,48(sp)
 8a0:	f426                	sd	s1,40(sp)
 8a2:	f04a                	sd	s2,32(sp)
 8a4:	ec4e                	sd	s3,24(sp)
 8a6:	e852                	sd	s4,16(sp)
 8a8:	e456                	sd	s5,8(sp)
 8aa:	e05a                	sd	s6,0(sp)
 8ac:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ae:	02051493          	slli	s1,a0,0x20
 8b2:	9081                	srli	s1,s1,0x20
 8b4:	04bd                	addi	s1,s1,15
 8b6:	8091                	srli	s1,s1,0x4
 8b8:	0014899b          	addiw	s3,s1,1
 8bc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8be:	00000517          	auipc	a0,0x0
 8c2:	10253503          	ld	a0,258(a0) # 9c0 <freep>
 8c6:	c515                	beqz	a0,8f2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ca:	4798                	lw	a4,8(a5)
 8cc:	02977f63          	bgeu	a4,s1,90a <malloc+0x70>
 8d0:	8a4e                	mv	s4,s3
 8d2:	0009871b          	sext.w	a4,s3
 8d6:	6685                	lui	a3,0x1
 8d8:	00d77363          	bgeu	a4,a3,8de <malloc+0x44>
 8dc:	6a05                	lui	s4,0x1
 8de:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e6:	00000917          	auipc	s2,0x0
 8ea:	0da90913          	addi	s2,s2,218 # 9c0 <freep>
  if(p == (char*)-1)
 8ee:	5afd                	li	s5,-1
 8f0:	a88d                	j	962 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8f2:	00000797          	auipc	a5,0x0
 8f6:	58678793          	addi	a5,a5,1414 # e78 <base>
 8fa:	00000717          	auipc	a4,0x0
 8fe:	0cf73323          	sd	a5,198(a4) # 9c0 <freep>
 902:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 904:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 908:	b7e1                	j	8d0 <malloc+0x36>
      if(p->s.size == nunits)
 90a:	02e48b63          	beq	s1,a4,940 <malloc+0xa6>
        p->s.size -= nunits;
 90e:	4137073b          	subw	a4,a4,s3
 912:	c798                	sw	a4,8(a5)
        p += p->s.size;
 914:	1702                	slli	a4,a4,0x20
 916:	9301                	srli	a4,a4,0x20
 918:	0712                	slli	a4,a4,0x4
 91a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 920:	00000717          	auipc	a4,0x0
 924:	0aa73023          	sd	a0,160(a4) # 9c0 <freep>
      return (void*)(p + 1);
 928:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 92c:	70e2                	ld	ra,56(sp)
 92e:	7442                	ld	s0,48(sp)
 930:	74a2                	ld	s1,40(sp)
 932:	7902                	ld	s2,32(sp)
 934:	69e2                	ld	s3,24(sp)
 936:	6a42                	ld	s4,16(sp)
 938:	6aa2                	ld	s5,8(sp)
 93a:	6b02                	ld	s6,0(sp)
 93c:	6121                	addi	sp,sp,64
 93e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 940:	6398                	ld	a4,0(a5)
 942:	e118                	sd	a4,0(a0)
 944:	bff1                	j	920 <malloc+0x86>
  hp->s.size = nu;
 946:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 94a:	0541                	addi	a0,a0,16
 94c:	00000097          	auipc	ra,0x0
 950:	ec6080e7          	jalr	-314(ra) # 812 <free>
  return freep;
 954:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 958:	d971                	beqz	a0,92c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95c:	4798                	lw	a4,8(a5)
 95e:	fa9776e3          	bgeu	a4,s1,90a <malloc+0x70>
    if(p == freep)
 962:	00093703          	ld	a4,0(s2)
 966:	853e                	mv	a0,a5
 968:	fef719e3          	bne	a4,a5,95a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 96c:	8552                	mv	a0,s4
 96e:	00000097          	auipc	ra,0x0
 972:	a62080e7          	jalr	-1438(ra) # 3d0 <sbrk>
  if(p == (char*)-1)
 976:	fd5518e3          	bne	a0,s5,946 <malloc+0xac>
        return 0;
 97a:	4501                	li	a0,0
 97c:	bf45                	j	92c <malloc+0x92>
