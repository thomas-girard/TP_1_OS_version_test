
user/_rocky:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <freadint>:
#include "kernel/fcntl.h"
#include "user/user.h"

#define MAXLEN 20

int freadint(char * fname){
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
   e:	00000097          	auipc	ra,0x0
  12:	664080e7          	jalr	1636(ra) # 672 <open>
  16:	84aa                	mv	s1,a0
  if(read(fd, buf, MAXLEN) > 0){
  18:	4651                	li	a2,20
  1a:	fc840593          	addi	a1,s0,-56
  1e:	00000097          	auipc	ra,0x0
  22:	62c080e7          	jalr	1580(ra) # 64a <read>
  26:	02a05963          	blez	a0,58 <freadint+0x58>
    res = atoi(buf);
  2a:	fc840513          	addi	a0,s0,-56
  2e:	00000097          	auipc	ra,0x0
  32:	470080e7          	jalr	1136(ra) # 49e <atoi>
  36:	892a                	mv	s2,a0
  int res = -1;
  38:	020007b7          	lui	a5,0x2000
  }
  int j = 0;
  for(int i = 0; i < (1 << 25); i++)
  3c:	37fd                	addiw	a5,a5,-1
  3e:	fffd                	bnez	a5,3c <freadint+0x3c>
    j += i;
  close(fd);
  40:	8526                	mv	a0,s1
  42:	00000097          	auipc	ra,0x0
  46:	554080e7          	jalr	1364(ra) # 596 <close>
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
  5a:	bff9                	j	38 <freadint+0x38>

000000000000005c <fwriteint>:

void fwriteint(char* fname, int i){
  5c:	1101                	addi	sp,sp,-32
  5e:	ec06                	sd	ra,24(sp)
  60:	e822                	sd	s0,16(sp)
  62:	e426                	sd	s1,8(sp)
  64:	e04a                	sd	s2,0(sp)
  66:	1000                	addi	s0,sp,32
  68:	892e                	mv	s2,a1
  int fd = open(fname, O_CREATE | O_RDWR);
  6a:	20200593          	li	a1,514
  6e:	00000097          	auipc	ra,0x0
  72:	604080e7          	jalr	1540(ra) # 672 <open>
  76:	84aa                	mv	s1,a0
  fprintf(fd, "%d\n", i);
  78:	864a                	mv	a2,s2
  7a:	00001597          	auipc	a1,0x1
  7e:	c7e58593          	addi	a1,a1,-898 # cf8 <malloc+0x174>
  82:	00001097          	auipc	ra,0x1
  86:	a16080e7          	jalr	-1514(ra) # a98 <fprintf>
  8a:	020007b7          	lui	a5,0x2000
  int j = 0;
  for(int i = 0; i < (1 << 25); i++)
  8e:	37fd                	addiw	a5,a5,-1
  90:	fffd                	bnez	a5,8e <fwriteint+0x32>
    j += i;
  close(fd);
  92:	8526                	mv	a0,s1
  94:	00000097          	auipc	ra,0x0
  98:	502080e7          	jalr	1282(ra) # 596 <close>
}
  9c:	60e2                	ld	ra,24(sp)
  9e:	6442                	ld	s0,16(sp)
  a0:	64a2                	ld	s1,8(sp)
  a2:	6902                	ld	s2,0(sp)
  a4:	6105                	addi	sp,sp,32
  a6:	8082                	ret

00000000000000a8 <panic>:

void
panic(char *s)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e406                	sd	ra,8(sp)
  ac:	e022                	sd	s0,0(sp)
  ae:	0800                	addi	s0,sp,16
  b0:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
  b2:	00001597          	auipc	a1,0x1
  b6:	bb658593          	addi	a1,a1,-1098 # c68 <malloc+0xe4>
  ba:	4509                	li	a0,2
  bc:	00001097          	auipc	ra,0x1
  c0:	9dc080e7          	jalr	-1572(ra) # a98 <fprintf>
  exit(1);
  c4:	4505                	li	a0,1
  c6:	00000097          	auipc	ra,0x0
  ca:	56c080e7          	jalr	1388(ra) # 632 <exit>

00000000000000ce <fork1>:
}

int
fork1(void)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e406                	sd	ra,8(sp)
  d2:	e022                	sd	s0,0(sp)
  d4:	0800                	addi	s0,sp,16
  int pid;
  pid = fork();
  d6:	00000097          	auipc	ra,0x0
  da:	554080e7          	jalr	1364(ra) # 62a <fork>
  if(pid == -1)
  de:	57fd                	li	a5,-1
  e0:	00f50663          	beq	a0,a5,ec <fork1+0x1e>
    panic("fork");
  return pid;
}
  e4:	60a2                	ld	ra,8(sp)
  e6:	6402                	ld	s0,0(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret
    panic("fork");
  ec:	00001517          	auipc	a0,0x1
  f0:	b8450513          	addi	a0,a0,-1148 # c70 <malloc+0xec>
  f4:	00000097          	auipc	ra,0x0
  f8:	fb4080e7          	jalr	-76(ra) # a8 <panic>

00000000000000fc <get_weather>:

void get_weather(int mut){
  fc:	1101                	addi	sp,sp,-32
  fe:	ec06                	sd	ra,24(sp)
 100:	e822                	sd	s0,16(sp)
 102:	e426                	sd	s1,8(sp)
 104:	1000                	addi	s0,sp,32
 106:	84aa                	mv	s1,a0
  acquire_mutex(mut);
 108:	00000097          	auipc	ra,0x0
 10c:	5e2080e7          	jalr	1506(ra) # 6ea <acquire_mutex>
  printf("Getting weather\n");
 110:	00001517          	auipc	a0,0x1
 114:	b6850513          	addi	a0,a0,-1176 # c78 <malloc+0xf4>
 118:	00001097          	auipc	ra,0x1
 11c:	9ae080e7          	jalr	-1618(ra) # ac6 <printf>
  int w = freadint("donnees_meteo");
 120:	00001517          	auipc	a0,0x1
 124:	b7050513          	addi	a0,a0,-1168 # c90 <malloc+0x10c>
 128:	00000097          	auipc	ra,0x0
 12c:	ed8080e7          	jalr	-296(ra) # 0 <freadint>
 130:	85aa                	mv	a1,a0
  fwriteint("a_envoyer_a_la_terre", w);
 132:	00001517          	auipc	a0,0x1
 136:	b6e50513          	addi	a0,a0,-1170 # ca0 <malloc+0x11c>
 13a:	00000097          	auipc	ra,0x0
 13e:	f22080e7          	jalr	-222(ra) # 5c <fwriteint>
  release_mutex(mut);
 142:	8526                	mv	a0,s1
 144:	00000097          	auipc	ra,0x0
 148:	5ae080e7          	jalr	1454(ra) # 6f2 <release_mutex>
  printf("Exiting weather\n");
 14c:	00001517          	auipc	a0,0x1
 150:	b6c50513          	addi	a0,a0,-1172 # cb8 <malloc+0x134>
 154:	00001097          	auipc	ra,0x1
 158:	972080e7          	jalr	-1678(ra) # ac6 <printf>
  sleep(2);
 15c:	4509                	li	a0,2
 15e:	00000097          	auipc	ra,0x0
 162:	564080e7          	jalr	1380(ra) # 6c2 <sleep>
}
 166:	60e2                	ld	ra,24(sp)
 168:	6442                	ld	s0,16(sp)
 16a:	64a2                	ld	s1,8(sp)
 16c:	6105                	addi	sp,sp,32
 16e:	8082                	ret

0000000000000170 <watchdog>:

int lasttime = 0;
#define THRESHOLD 20
#define NITER 100
void watchdog(int mut, int watchdog_fd){
 170:	715d                	addi	sp,sp,-80
 172:	e486                	sd	ra,72(sp)
 174:	e0a2                	sd	s0,64(sp)
 176:	fc26                	sd	s1,56(sp)
 178:	f84a                	sd	s2,48(sp)
 17a:	f44e                	sd	s3,40(sp)
 17c:	f052                	sd	s4,32(sp)
 17e:	ec56                	sd	s5,24(sp)
 180:	0880                	addi	s0,sp,80
 182:	84aa                	mv	s1,a0
 184:	892e                	mv	s2,a1
  while(1){
    printf("Watchdog...\n");
 186:	00001a97          	auipc	s5,0x1
 18a:	b4aa8a93          	addi	s5,s5,-1206 # cd0 <malloc+0x14c>
    acquire_mutex(mut);
    char reset = 20;
 18e:	4a51                	li	s4,20
    int time_since_last_write = write(watchdog_fd, &reset, 1);
    printf("time_since_last_write = %d\n", time_since_last_write);
 190:	00001997          	auipc	s3,0x1
 194:	b5098993          	addi	s3,s3,-1200 # ce0 <malloc+0x15c>
    printf("Watchdog...\n");
 198:	8556                	mv	a0,s5
 19a:	00001097          	auipc	ra,0x1
 19e:	92c080e7          	jalr	-1748(ra) # ac6 <printf>
    acquire_mutex(mut);
 1a2:	8526                	mv	a0,s1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	546080e7          	jalr	1350(ra) # 6ea <acquire_mutex>
    char reset = 20;
 1ac:	fb440fa3          	sb	s4,-65(s0)
    int time_since_last_write = write(watchdog_fd, &reset, 1);
 1b0:	4605                	li	a2,1
 1b2:	fbf40593          	addi	a1,s0,-65
 1b6:	854a                	mv	a0,s2
 1b8:	00000097          	auipc	ra,0x0
 1bc:	49a080e7          	jalr	1178(ra) # 652 <write>
 1c0:	85aa                	mv	a1,a0
    printf("time_since_last_write = %d\n", time_since_last_write);
 1c2:	854e                	mv	a0,s3
 1c4:	00001097          	auipc	ra,0x1
 1c8:	902080e7          	jalr	-1790(ra) # ac6 <printf>
    release_mutex(mut);
 1cc:	8526                	mv	a0,s1
 1ce:	00000097          	auipc	ra,0x0
 1d2:	524080e7          	jalr	1316(ra) # 6f2 <release_mutex>
    sleep(15);
 1d6:	453d                	li	a0,15
 1d8:	00000097          	auipc	ra,0x0
 1dc:	4ea080e7          	jalr	1258(ra) # 6c2 <sleep>
  while(1){
 1e0:	bf65                	j	198 <watchdog+0x28>

00000000000001e2 <transmit_to_earth>:
  }
}

void transmit_to_earth(){
 1e2:	1141                	addi	sp,sp,-16
 1e4:	e406                	sd	ra,8(sp)
 1e6:	e022                	sd	s0,0(sp)
 1e8:	0800                	addi	s0,sp,16
  printf("Transmitting...\n");
 1ea:	00001517          	auipc	a0,0x1
 1ee:	b1650513          	addi	a0,a0,-1258 # d00 <malloc+0x17c>
 1f2:	00001097          	auipc	ra,0x1
 1f6:	8d4080e7          	jalr	-1836(ra) # ac6 <printf>
 1fa:	400007b7          	lui	a5,0x40000
  int j = 0;
  for(int i = 0; i < (1 << 30); i++)
 1fe:	37fd                	addiw	a5,a5,-1
 200:	fffd                	bnez	a5,1fe <transmit_to_earth+0x1c>
    j += i;
  printf("Done transmitting.\n");
 202:	00001517          	auipc	a0,0x1
 206:	b1650513          	addi	a0,a0,-1258 # d18 <malloc+0x194>
 20a:	00001097          	auipc	ra,0x1
 20e:	8bc080e7          	jalr	-1860(ra) # ac6 <printf>
  sleep(2);
 212:	4509                	li	a0,2
 214:	00000097          	auipc	ra,0x0
 218:	4ae080e7          	jalr	1198(ra) # 6c2 <sleep>
}
 21c:	60a2                	ld	ra,8(sp)
 21e:	6402                	ld	s0,0(sp)
 220:	0141                	addi	sp,sp,16
 222:	8082                	ret

0000000000000224 <main>:

int main(){
 224:	7179                	addi	sp,sp,-48
 226:	f406                	sd	ra,40(sp)
 228:	f022                	sd	s0,32(sp)
 22a:	ec26                	sd	s1,24(sp)
 22c:	e84a                	sd	s2,16(sp)
 22e:	e44e                	sd	s3,8(sp)
 230:	e052                	sd	s4,0(sp)
 232:	1800                	addi	s0,sp,48
  int watchdog_fd;
  if((watchdog_fd = open("/watchdog", O_WRONLY)) < 0){
 234:	4585                	li	a1,1
 236:	00001517          	auipc	a0,0x1
 23a:	afa50513          	addi	a0,a0,-1286 # d30 <malloc+0x1ac>
 23e:	00000097          	auipc	ra,0x0
 242:	434080e7          	jalr	1076(ra) # 672 <open>
 246:	84aa                	mv	s1,a0
 248:	06054163          	bltz	a0,2aa <main+0x86>
    mknod("/watchdog", 2, 0);
    watchdog_fd = open("/watchdog", O_WRONLY);
  }
  fwriteint("donnees_meteo", 12);
 24c:	45b1                	li	a1,12
 24e:	00001517          	auipc	a0,0x1
 252:	a4250513          	addi	a0,a0,-1470 # c90 <malloc+0x10c>
 256:	00000097          	auipc	ra,0x0
 25a:	e06080e7          	jalr	-506(ra) # 5c <fwriteint>
  int mut = create_mutex();
 25e:	00000097          	auipc	ra,0x0
 262:	484080e7          	jalr	1156(ra) # 6e2 <create_mutex>
 266:	892a                	mv	s2,a0
  int pid_get_weather;
  int pid_transmit_to_earth;
  int pid_watchdog;
  lasttime = uptime();
 268:	00000097          	auipc	ra,0x0
 26c:	462080e7          	jalr	1122(ra) # 6ca <uptime>
 270:	00001797          	auipc	a5,0x1
 274:	aea7a823          	sw	a0,-1296(a5) # d60 <lasttime>
  if((pid_get_weather = fork1()) == 0){
 278:	00000097          	auipc	ra,0x0
 27c:	e56080e7          	jalr	-426(ra) # ce <fork1>
 280:	89aa                	mv	s3,a0
 282:	e929                	bnez	a0,2d4 <main+0xb0>
		sleep(10);
 284:	4529                	li	a0,10
 286:	00000097          	auipc	ra,0x0
 28a:	43c080e7          	jalr	1084(ra) # 6c2 <sleep>
 28e:	06400493          	li	s1,100
		for(int i = 0; i < NITER; i++)
	    get_weather(mut);
 292:	854a                	mv	a0,s2
 294:	00000097          	auipc	ra,0x0
 298:	e68080e7          	jalr	-408(ra) # fc <get_weather>
		for(int i = 0; i < NITER; i++)
 29c:	34fd                	addiw	s1,s1,-1
 29e:	f8f5                	bnez	s1,292 <main+0x6e>
    exit(0);
 2a0:	4501                	li	a0,0
 2a2:	00000097          	auipc	ra,0x0
 2a6:	390080e7          	jalr	912(ra) # 632 <exit>
    mknod("/watchdog", 2, 0);
 2aa:	4601                	li	a2,0
 2ac:	4589                	li	a1,2
 2ae:	00001517          	auipc	a0,0x1
 2b2:	a8250513          	addi	a0,a0,-1406 # d30 <malloc+0x1ac>
 2b6:	00000097          	auipc	ra,0x0
 2ba:	3c4080e7          	jalr	964(ra) # 67a <mknod>
    watchdog_fd = open("/watchdog", O_WRONLY);
 2be:	4585                	li	a1,1
 2c0:	00001517          	auipc	a0,0x1
 2c4:	a7050513          	addi	a0,a0,-1424 # d30 <malloc+0x1ac>
 2c8:	00000097          	auipc	ra,0x0
 2cc:	3aa080e7          	jalr	938(ra) # 672 <open>
 2d0:	84aa                	mv	s1,a0
 2d2:	bfad                	j	24c <main+0x28>
  } else if((pid_transmit_to_earth = fork1()) == 0){
 2d4:	00000097          	auipc	ra,0x0
 2d8:	dfa080e7          	jalr	-518(ra) # ce <fork1>
 2dc:	8a2a                	mv	s4,a0
 2de:	e11d                	bnez	a0,304 <main+0xe0>
		sleep(10);
 2e0:	4529                	li	a0,10
 2e2:	00000097          	auipc	ra,0x0
 2e6:	3e0080e7          	jalr	992(ra) # 6c2 <sleep>
 2ea:	06400493          	li	s1,100
		for(int i = 0; i < NITER; i++)
	    transmit_to_earth();
 2ee:	00000097          	auipc	ra,0x0
 2f2:	ef4080e7          	jalr	-268(ra) # 1e2 <transmit_to_earth>
		for(int i = 0; i < NITER; i++)
 2f6:	34fd                	addiw	s1,s1,-1
 2f8:	f8fd                	bnez	s1,2ee <main+0xca>
    exit(0);
 2fa:	4501                	li	a0,0
 2fc:	00000097          	auipc	ra,0x0
 300:	336080e7          	jalr	822(ra) # 632 <exit>
  } else if((pid_watchdog = fork1()) == 0){
 304:	00000097          	auipc	ra,0x0
 308:	dca080e7          	jalr	-566(ra) # ce <fork1>
 30c:	ed01                	bnez	a0,324 <main+0x100>
		sleep(10);
 30e:	4529                	li	a0,10
 310:	00000097          	auipc	ra,0x0
 314:	3b2080e7          	jalr	946(ra) # 6c2 <sleep>
    watchdog(mut, watchdog_fd);
 318:	85a6                	mv	a1,s1
 31a:	854a                	mv	a0,s2
 31c:	00000097          	auipc	ra,0x0
 320:	e54080e7          	jalr	-428(ra) # 170 <watchdog>
    exit(0);
  } else {
    nice(pid_watchdog, 0);
 324:	4581                	li	a1,0
 326:	00000097          	auipc	ra,0x0
 32a:	3b4080e7          	jalr	948(ra) # 6da <nice>
    nice(pid_transmit_to_earth, 5);
 32e:	4595                	li	a1,5
 330:	8552                	mv	a0,s4
 332:	00000097          	auipc	ra,0x0
 336:	3a8080e7          	jalr	936(ra) # 6da <nice>
    nice(pid_get_weather, 9);
 33a:	45a5                	li	a1,9
 33c:	854e                	mv	a0,s3
 33e:	00000097          	auipc	ra,0x0
 342:	39c080e7          	jalr	924(ra) # 6da <nice>
    wait(0);
 346:	4501                	li	a0,0
 348:	00000097          	auipc	ra,0x0
 34c:	2f2080e7          	jalr	754(ra) # 63a <wait>
    wait(0);
 350:	4501                	li	a0,0
 352:	00000097          	auipc	ra,0x0
 356:	2e8080e7          	jalr	744(ra) # 63a <wait>
    wait(0);
 35a:	4501                	li	a0,0
 35c:	00000097          	auipc	ra,0x0
 360:	2de080e7          	jalr	734(ra) # 63a <wait>
    exit(0);
 364:	4501                	li	a0,0
 366:	00000097          	auipc	ra,0x0
 36a:	2cc080e7          	jalr	716(ra) # 632 <exit>

000000000000036e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 374:	87aa                	mv	a5,a0
 376:	0585                	addi	a1,a1,1
 378:	0785                	addi	a5,a5,1
 37a:	fff5c703          	lbu	a4,-1(a1)
 37e:	fee78fa3          	sb	a4,-1(a5)
 382:	fb75                	bnez	a4,376 <strcpy+0x8>
    ;
  return os;
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret

000000000000038a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 38a:	1141                	addi	sp,sp,-16
 38c:	e422                	sd	s0,8(sp)
 38e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 390:	00054783          	lbu	a5,0(a0)
 394:	cb91                	beqz	a5,3a8 <strcmp+0x1e>
 396:	0005c703          	lbu	a4,0(a1)
 39a:	00f71763          	bne	a4,a5,3a8 <strcmp+0x1e>
    p++, q++;
 39e:	0505                	addi	a0,a0,1
 3a0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3a2:	00054783          	lbu	a5,0(a0)
 3a6:	fbe5                	bnez	a5,396 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3a8:	0005c503          	lbu	a0,0(a1)
}
 3ac:	40a7853b          	subw	a0,a5,a0
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret

00000000000003b6 <strlen>:

uint
strlen(const char *s)
{
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e422                	sd	s0,8(sp)
 3ba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3bc:	00054783          	lbu	a5,0(a0)
 3c0:	cf91                	beqz	a5,3dc <strlen+0x26>
 3c2:	0505                	addi	a0,a0,1
 3c4:	87aa                	mv	a5,a0
 3c6:	4685                	li	a3,1
 3c8:	9e89                	subw	a3,a3,a0
 3ca:	00f6853b          	addw	a0,a3,a5
 3ce:	0785                	addi	a5,a5,1
 3d0:	fff7c703          	lbu	a4,-1(a5)
 3d4:	fb7d                	bnez	a4,3ca <strlen+0x14>
    ;
  return n;
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret
  for(n = 0; s[n]; n++)
 3dc:	4501                	li	a0,0
 3de:	bfe5                	j	3d6 <strlen+0x20>

00000000000003e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3e6:	ce09                	beqz	a2,400 <memset+0x20>
 3e8:	87aa                	mv	a5,a0
 3ea:	fff6071b          	addiw	a4,a2,-1
 3ee:	1702                	slli	a4,a4,0x20
 3f0:	9301                	srli	a4,a4,0x20
 3f2:	0705                	addi	a4,a4,1
 3f4:	972a                	add	a4,a4,a0
    cdst[i] = c;
 3f6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3fa:	0785                	addi	a5,a5,1
 3fc:	fee79de3          	bne	a5,a4,3f6 <memset+0x16>
  }
  return dst;
}
 400:	6422                	ld	s0,8(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret

0000000000000406 <strchr>:

char*
strchr(const char *s, char c)
{
 406:	1141                	addi	sp,sp,-16
 408:	e422                	sd	s0,8(sp)
 40a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 40c:	00054783          	lbu	a5,0(a0)
 410:	cb99                	beqz	a5,426 <strchr+0x20>
    if(*s == c)
 412:	00f58763          	beq	a1,a5,420 <strchr+0x1a>
  for(; *s; s++)
 416:	0505                	addi	a0,a0,1
 418:	00054783          	lbu	a5,0(a0)
 41c:	fbfd                	bnez	a5,412 <strchr+0xc>
      return (char*)s;
  return 0;
 41e:	4501                	li	a0,0
}
 420:	6422                	ld	s0,8(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret
  return 0;
 426:	4501                	li	a0,0
 428:	bfe5                	j	420 <strchr+0x1a>

000000000000042a <gets>:

char*
gets(char *buf, int max)
{
 42a:	711d                	addi	sp,sp,-96
 42c:	ec86                	sd	ra,88(sp)
 42e:	e8a2                	sd	s0,80(sp)
 430:	e4a6                	sd	s1,72(sp)
 432:	e0ca                	sd	s2,64(sp)
 434:	fc4e                	sd	s3,56(sp)
 436:	f852                	sd	s4,48(sp)
 438:	f456                	sd	s5,40(sp)
 43a:	f05a                	sd	s6,32(sp)
 43c:	ec5e                	sd	s7,24(sp)
 43e:	1080                	addi	s0,sp,96
 440:	8baa                	mv	s7,a0
 442:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 444:	892a                	mv	s2,a0
 446:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 448:	4aa9                	li	s5,10
 44a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 44c:	89a6                	mv	s3,s1
 44e:	2485                	addiw	s1,s1,1
 450:	0344d863          	bge	s1,s4,480 <gets+0x56>
    cc = read(0, &c, 1);
 454:	4605                	li	a2,1
 456:	faf40593          	addi	a1,s0,-81
 45a:	4501                	li	a0,0
 45c:	00000097          	auipc	ra,0x0
 460:	1ee080e7          	jalr	494(ra) # 64a <read>
    if(cc < 1)
 464:	00a05e63          	blez	a0,480 <gets+0x56>
    buf[i++] = c;
 468:	faf44783          	lbu	a5,-81(s0)
 46c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 470:	01578763          	beq	a5,s5,47e <gets+0x54>
 474:	0905                	addi	s2,s2,1
 476:	fd679be3          	bne	a5,s6,44c <gets+0x22>
  for(i=0; i+1 < max; ){
 47a:	89a6                	mv	s3,s1
 47c:	a011                	j	480 <gets+0x56>
 47e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 480:	99de                	add	s3,s3,s7
 482:	00098023          	sb	zero,0(s3)
  return buf;
}
 486:	855e                	mv	a0,s7
 488:	60e6                	ld	ra,88(sp)
 48a:	6446                	ld	s0,80(sp)
 48c:	64a6                	ld	s1,72(sp)
 48e:	6906                	ld	s2,64(sp)
 490:	79e2                	ld	s3,56(sp)
 492:	7a42                	ld	s4,48(sp)
 494:	7aa2                	ld	s5,40(sp)
 496:	7b02                	ld	s6,32(sp)
 498:	6be2                	ld	s7,24(sp)
 49a:	6125                	addi	sp,sp,96
 49c:	8082                	ret

000000000000049e <atoi>:
  return r;
}

int
atoi(const char *s)
{
 49e:	1141                	addi	sp,sp,-16
 4a0:	e422                	sd	s0,8(sp)
 4a2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4a4:	00054603          	lbu	a2,0(a0)
 4a8:	fd06079b          	addiw	a5,a2,-48
 4ac:	0ff7f793          	andi	a5,a5,255
 4b0:	4725                	li	a4,9
 4b2:	02f76963          	bltu	a4,a5,4e4 <atoi+0x46>
 4b6:	86aa                	mv	a3,a0
  n = 0;
 4b8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4ba:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4bc:	0685                	addi	a3,a3,1
 4be:	0025179b          	slliw	a5,a0,0x2
 4c2:	9fa9                	addw	a5,a5,a0
 4c4:	0017979b          	slliw	a5,a5,0x1
 4c8:	9fb1                	addw	a5,a5,a2
 4ca:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4ce:	0006c603          	lbu	a2,0(a3)
 4d2:	fd06071b          	addiw	a4,a2,-48
 4d6:	0ff77713          	andi	a4,a4,255
 4da:	fee5f1e3          	bgeu	a1,a4,4bc <atoi+0x1e>
  return n;
}
 4de:	6422                	ld	s0,8(sp)
 4e0:	0141                	addi	sp,sp,16
 4e2:	8082                	ret
  n = 0;
 4e4:	4501                	li	a0,0
 4e6:	bfe5                	j	4de <atoi+0x40>

00000000000004e8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4e8:	1141                	addi	sp,sp,-16
 4ea:	e422                	sd	s0,8(sp)
 4ec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4ee:	02b57663          	bgeu	a0,a1,51a <memmove+0x32>
    while(n-- > 0)
 4f2:	02c05163          	blez	a2,514 <memmove+0x2c>
 4f6:	fff6079b          	addiw	a5,a2,-1
 4fa:	1782                	slli	a5,a5,0x20
 4fc:	9381                	srli	a5,a5,0x20
 4fe:	0785                	addi	a5,a5,1
 500:	97aa                	add	a5,a5,a0
  dst = vdst;
 502:	872a                	mv	a4,a0
      *dst++ = *src++;
 504:	0585                	addi	a1,a1,1
 506:	0705                	addi	a4,a4,1
 508:	fff5c683          	lbu	a3,-1(a1)
 50c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 510:	fee79ae3          	bne	a5,a4,504 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 514:	6422                	ld	s0,8(sp)
 516:	0141                	addi	sp,sp,16
 518:	8082                	ret
    dst += n;
 51a:	00c50733          	add	a4,a0,a2
    src += n;
 51e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 520:	fec05ae3          	blez	a2,514 <memmove+0x2c>
 524:	fff6079b          	addiw	a5,a2,-1
 528:	1782                	slli	a5,a5,0x20
 52a:	9381                	srli	a5,a5,0x20
 52c:	fff7c793          	not	a5,a5
 530:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 532:	15fd                	addi	a1,a1,-1
 534:	177d                	addi	a4,a4,-1
 536:	0005c683          	lbu	a3,0(a1)
 53a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 53e:	fee79ae3          	bne	a5,a4,532 <memmove+0x4a>
 542:	bfc9                	j	514 <memmove+0x2c>

0000000000000544 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 544:	1141                	addi	sp,sp,-16
 546:	e422                	sd	s0,8(sp)
 548:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 54a:	ca05                	beqz	a2,57a <memcmp+0x36>
 54c:	fff6069b          	addiw	a3,a2,-1
 550:	1682                	slli	a3,a3,0x20
 552:	9281                	srli	a3,a3,0x20
 554:	0685                	addi	a3,a3,1
 556:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 558:	00054783          	lbu	a5,0(a0)
 55c:	0005c703          	lbu	a4,0(a1)
 560:	00e79863          	bne	a5,a4,570 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 564:	0505                	addi	a0,a0,1
    p2++;
 566:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 568:	fed518e3          	bne	a0,a3,558 <memcmp+0x14>
  }
  return 0;
 56c:	4501                	li	a0,0
 56e:	a019                	j	574 <memcmp+0x30>
      return *p1 - *p2;
 570:	40e7853b          	subw	a0,a5,a4
}
 574:	6422                	ld	s0,8(sp)
 576:	0141                	addi	sp,sp,16
 578:	8082                	ret
  return 0;
 57a:	4501                	li	a0,0
 57c:	bfe5                	j	574 <memcmp+0x30>

000000000000057e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 57e:	1141                	addi	sp,sp,-16
 580:	e406                	sd	ra,8(sp)
 582:	e022                	sd	s0,0(sp)
 584:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 586:	00000097          	auipc	ra,0x0
 58a:	f62080e7          	jalr	-158(ra) # 4e8 <memmove>
}
 58e:	60a2                	ld	ra,8(sp)
 590:	6402                	ld	s0,0(sp)
 592:	0141                	addi	sp,sp,16
 594:	8082                	ret

0000000000000596 <close>:

int close(int fd){
 596:	1101                	addi	sp,sp,-32
 598:	ec06                	sd	ra,24(sp)
 59a:	e822                	sd	s0,16(sp)
 59c:	e426                	sd	s1,8(sp)
 59e:	1000                	addi	s0,sp,32
 5a0:	84aa                	mv	s1,a0
  fflush(fd);
 5a2:	00000097          	auipc	ra,0x0
 5a6:	2d4080e7          	jalr	724(ra) # 876 <fflush>
  char* buf = get_putc_buf(fd);
 5aa:	8526                	mv	a0,s1
 5ac:	00000097          	auipc	ra,0x0
 5b0:	14e080e7          	jalr	334(ra) # 6fa <get_putc_buf>
  if(buf){
 5b4:	cd11                	beqz	a0,5d0 <close+0x3a>
    free(buf);
 5b6:	00000097          	auipc	ra,0x0
 5ba:	546080e7          	jalr	1350(ra) # afc <free>
    putc_buf[fd] = 0;
 5be:	00349713          	slli	a4,s1,0x3
 5c2:	00000797          	auipc	a5,0x0
 5c6:	7ae78793          	addi	a5,a5,1966 # d70 <putc_buf>
 5ca:	97ba                	add	a5,a5,a4
 5cc:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
 5d0:	8526                	mv	a0,s1
 5d2:	00000097          	auipc	ra,0x0
 5d6:	088080e7          	jalr	136(ra) # 65a <sclose>
}
 5da:	60e2                	ld	ra,24(sp)
 5dc:	6442                	ld	s0,16(sp)
 5de:	64a2                	ld	s1,8(sp)
 5e0:	6105                	addi	sp,sp,32
 5e2:	8082                	ret

00000000000005e4 <stat>:
{
 5e4:	1101                	addi	sp,sp,-32
 5e6:	ec06                	sd	ra,24(sp)
 5e8:	e822                	sd	s0,16(sp)
 5ea:	e426                	sd	s1,8(sp)
 5ec:	e04a                	sd	s2,0(sp)
 5ee:	1000                	addi	s0,sp,32
 5f0:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
 5f2:	4581                	li	a1,0
 5f4:	00000097          	auipc	ra,0x0
 5f8:	07e080e7          	jalr	126(ra) # 672 <open>
  if(fd < 0)
 5fc:	02054563          	bltz	a0,626 <stat+0x42>
 600:	84aa                	mv	s1,a0
  r = fstat(fd, st);
 602:	85ca                	mv	a1,s2
 604:	00000097          	auipc	ra,0x0
 608:	086080e7          	jalr	134(ra) # 68a <fstat>
 60c:	892a                	mv	s2,a0
  close(fd);
 60e:	8526                	mv	a0,s1
 610:	00000097          	auipc	ra,0x0
 614:	f86080e7          	jalr	-122(ra) # 596 <close>
}
 618:	854a                	mv	a0,s2
 61a:	60e2                	ld	ra,24(sp)
 61c:	6442                	ld	s0,16(sp)
 61e:	64a2                	ld	s1,8(sp)
 620:	6902                	ld	s2,0(sp)
 622:	6105                	addi	sp,sp,32
 624:	8082                	ret
    return -1;
 626:	597d                	li	s2,-1
 628:	bfc5                	j	618 <stat+0x34>

000000000000062a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 62a:	4885                	li	a7,1
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <exit>:
.global exit
exit:
 li a7, SYS_exit
 632:	4889                	li	a7,2
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <wait>:
.global wait
wait:
 li a7, SYS_wait
 63a:	488d                	li	a7,3
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 642:	4891                	li	a7,4
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <read>:
.global read
read:
 li a7, SYS_read
 64a:	4895                	li	a7,5
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <write>:
.global write
write:
 li a7, SYS_write
 652:	48c1                	li	a7,16
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <sclose>:
.global sclose
sclose:
 li a7, SYS_close
 65a:	48d5                	li	a7,21
 ecall
 65c:	00000073          	ecall
 ret
 660:	8082                	ret

0000000000000662 <kill>:
.global kill
kill:
 li a7, SYS_kill
 662:	4899                	li	a7,6
 ecall
 664:	00000073          	ecall
 ret
 668:	8082                	ret

000000000000066a <exec>:
.global exec
exec:
 li a7, SYS_exec
 66a:	489d                	li	a7,7
 ecall
 66c:	00000073          	ecall
 ret
 670:	8082                	ret

0000000000000672 <open>:
.global open
open:
 li a7, SYS_open
 672:	48bd                	li	a7,15
 ecall
 674:	00000073          	ecall
 ret
 678:	8082                	ret

000000000000067a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 67a:	48c5                	li	a7,17
 ecall
 67c:	00000073          	ecall
 ret
 680:	8082                	ret

0000000000000682 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 682:	48c9                	li	a7,18
 ecall
 684:	00000073          	ecall
 ret
 688:	8082                	ret

000000000000068a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 68a:	48a1                	li	a7,8
 ecall
 68c:	00000073          	ecall
 ret
 690:	8082                	ret

0000000000000692 <link>:
.global link
link:
 li a7, SYS_link
 692:	48cd                	li	a7,19
 ecall
 694:	00000073          	ecall
 ret
 698:	8082                	ret

000000000000069a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 69a:	48d1                	li	a7,20
 ecall
 69c:	00000073          	ecall
 ret
 6a0:	8082                	ret

00000000000006a2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6a2:	48a5                	li	a7,9
 ecall
 6a4:	00000073          	ecall
 ret
 6a8:	8082                	ret

00000000000006aa <dup>:
.global dup
dup:
 li a7, SYS_dup
 6aa:	48a9                	li	a7,10
 ecall
 6ac:	00000073          	ecall
 ret
 6b0:	8082                	ret

00000000000006b2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6b2:	48ad                	li	a7,11
 ecall
 6b4:	00000073          	ecall
 ret
 6b8:	8082                	ret

00000000000006ba <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 6ba:	48b1                	li	a7,12
 ecall
 6bc:	00000073          	ecall
 ret
 6c0:	8082                	ret

00000000000006c2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6c2:	48b5                	li	a7,13
 ecall
 6c4:	00000073          	ecall
 ret
 6c8:	8082                	ret

00000000000006ca <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6ca:	48b9                	li	a7,14
 ecall
 6cc:	00000073          	ecall
 ret
 6d0:	8082                	ret

00000000000006d2 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 6d2:	48d9                	li	a7,22
 ecall
 6d4:	00000073          	ecall
 ret
 6d8:	8082                	ret

00000000000006da <nice>:
.global nice
nice:
 li a7, SYS_nice
 6da:	48dd                	li	a7,23
 ecall
 6dc:	00000073          	ecall
 ret
 6e0:	8082                	ret

00000000000006e2 <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
 6e2:	48e1                	li	a7,24
 ecall
 6e4:	00000073          	ecall
 ret
 6e8:	8082                	ret

00000000000006ea <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
 6ea:	48e5                	li	a7,25
 ecall
 6ec:	00000073          	ecall
 ret
 6f0:	8082                	ret

00000000000006f2 <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
 6f2:	48e9                	li	a7,26
 ecall
 6f4:	00000073          	ecall
 ret
 6f8:	8082                	ret

00000000000006fa <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
 6fa:	1101                	addi	sp,sp,-32
 6fc:	ec06                	sd	ra,24(sp)
 6fe:	e822                	sd	s0,16(sp)
 700:	e426                	sd	s1,8(sp)
 702:	1000                	addi	s0,sp,32
 704:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
 706:	00351713          	slli	a4,a0,0x3
 70a:	00000797          	auipc	a5,0x0
 70e:	66678793          	addi	a5,a5,1638 # d70 <putc_buf>
 712:	97ba                	add	a5,a5,a4
 714:	6388                	ld	a0,0(a5)
  if(buf) {
 716:	c511                	beqz	a0,722 <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
 718:	60e2                	ld	ra,24(sp)
 71a:	6442                	ld	s0,16(sp)
 71c:	64a2                	ld	s1,8(sp)
 71e:	6105                	addi	sp,sp,32
 720:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
 722:	6505                	lui	a0,0x1
 724:	00000097          	auipc	ra,0x0
 728:	460080e7          	jalr	1120(ra) # b84 <malloc>
  putc_buf[fd] = buf;
 72c:	00000797          	auipc	a5,0x0
 730:	64478793          	addi	a5,a5,1604 # d70 <putc_buf>
 734:	00349713          	slli	a4,s1,0x3
 738:	973e                	add	a4,a4,a5
 73a:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
 73c:	048a                	slli	s1,s1,0x2
 73e:	94be                	add	s1,s1,a5
 740:	3204a023          	sw	zero,800(s1)
  return buf;
 744:	bfd1                	j	718 <get_putc_buf+0x1e>

0000000000000746 <putc>:

static void
putc(int fd, char c)
{
 746:	1101                	addi	sp,sp,-32
 748:	ec06                	sd	ra,24(sp)
 74a:	e822                	sd	s0,16(sp)
 74c:	e426                	sd	s1,8(sp)
 74e:	e04a                	sd	s2,0(sp)
 750:	1000                	addi	s0,sp,32
 752:	84aa                	mv	s1,a0
 754:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
 756:	00000097          	auipc	ra,0x0
 75a:	fa4080e7          	jalr	-92(ra) # 6fa <get_putc_buf>
  buf[putc_index[fd]++] = c;
 75e:	00249793          	slli	a5,s1,0x2
 762:	00000717          	auipc	a4,0x0
 766:	60e70713          	addi	a4,a4,1550 # d70 <putc_buf>
 76a:	973e                	add	a4,a4,a5
 76c:	32072783          	lw	a5,800(a4)
 770:	0017869b          	addiw	a3,a5,1
 774:	32d72023          	sw	a3,800(a4)
 778:	97aa                	add	a5,a5,a0
 77a:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
 77e:	47a9                	li	a5,10
 780:	02f90463          	beq	s2,a5,7a8 <putc+0x62>
 784:	00249713          	slli	a4,s1,0x2
 788:	00000797          	auipc	a5,0x0
 78c:	5e878793          	addi	a5,a5,1512 # d70 <putc_buf>
 790:	97ba                	add	a5,a5,a4
 792:	3207a703          	lw	a4,800(a5)
 796:	6785                	lui	a5,0x1
 798:	00f70863          	beq	a4,a5,7a8 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
 79c:	60e2                	ld	ra,24(sp)
 79e:	6442                	ld	s0,16(sp)
 7a0:	64a2                	ld	s1,8(sp)
 7a2:	6902                	ld	s2,0(sp)
 7a4:	6105                	addi	sp,sp,32
 7a6:	8082                	ret
    write(fd, buf, putc_index[fd]);
 7a8:	00249793          	slli	a5,s1,0x2
 7ac:	00000917          	auipc	s2,0x0
 7b0:	5c490913          	addi	s2,s2,1476 # d70 <putc_buf>
 7b4:	993e                	add	s2,s2,a5
 7b6:	32092603          	lw	a2,800(s2)
 7ba:	85aa                	mv	a1,a0
 7bc:	8526                	mv	a0,s1
 7be:	00000097          	auipc	ra,0x0
 7c2:	e94080e7          	jalr	-364(ra) # 652 <write>
    putc_index[fd] = 0;
 7c6:	32092023          	sw	zero,800(s2)
}
 7ca:	bfc9                	j	79c <putc+0x56>

00000000000007cc <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
 7cc:	7139                	addi	sp,sp,-64
 7ce:	fc06                	sd	ra,56(sp)
 7d0:	f822                	sd	s0,48(sp)
 7d2:	f426                	sd	s1,40(sp)
 7d4:	f04a                	sd	s2,32(sp)
 7d6:	ec4e                	sd	s3,24(sp)
 7d8:	0080                	addi	s0,sp,64
 7da:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7dc:	c299                	beqz	a3,7e2 <printint+0x16>
 7de:	0805c863          	bltz	a1,86e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7e2:	2581                	sext.w	a1,a1
  neg = 0;
 7e4:	4881                	li	a7,0
 7e6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7ea:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7ec:	2601                	sext.w	a2,a2
 7ee:	00000517          	auipc	a0,0x0
 7f2:	55a50513          	addi	a0,a0,1370 # d48 <digits>
 7f6:	883a                	mv	a6,a4
 7f8:	2705                	addiw	a4,a4,1
 7fa:	02c5f7bb          	remuw	a5,a1,a2
 7fe:	1782                	slli	a5,a5,0x20
 800:	9381                	srli	a5,a5,0x20
 802:	97aa                	add	a5,a5,a0
 804:	0007c783          	lbu	a5,0(a5) # 1000 <putc_buf+0x290>
 808:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 80c:	0005879b          	sext.w	a5,a1
 810:	02c5d5bb          	divuw	a1,a1,a2
 814:	0685                	addi	a3,a3,1
 816:	fec7f0e3          	bgeu	a5,a2,7f6 <printint+0x2a>
  if(neg)
 81a:	00088b63          	beqz	a7,830 <printint+0x64>
    buf[i++] = '-';
 81e:	fd040793          	addi	a5,s0,-48
 822:	973e                	add	a4,a4,a5
 824:	02d00793          	li	a5,45
 828:	fef70823          	sb	a5,-16(a4)
 82c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 830:	02e05863          	blez	a4,860 <printint+0x94>
 834:	fc040793          	addi	a5,s0,-64
 838:	00e78933          	add	s2,a5,a4
 83c:	fff78993          	addi	s3,a5,-1
 840:	99ba                	add	s3,s3,a4
 842:	377d                	addiw	a4,a4,-1
 844:	1702                	slli	a4,a4,0x20
 846:	9301                	srli	a4,a4,0x20
 848:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 84c:	fff94583          	lbu	a1,-1(s2)
 850:	8526                	mv	a0,s1
 852:	00000097          	auipc	ra,0x0
 856:	ef4080e7          	jalr	-268(ra) # 746 <putc>
  while(--i >= 0)
 85a:	197d                	addi	s2,s2,-1
 85c:	ff3918e3          	bne	s2,s3,84c <printint+0x80>
}
 860:	70e2                	ld	ra,56(sp)
 862:	7442                	ld	s0,48(sp)
 864:	74a2                	ld	s1,40(sp)
 866:	7902                	ld	s2,32(sp)
 868:	69e2                	ld	s3,24(sp)
 86a:	6121                	addi	sp,sp,64
 86c:	8082                	ret
    x = -xx;
 86e:	40b005bb          	negw	a1,a1
    neg = 1;
 872:	4885                	li	a7,1
    x = -xx;
 874:	bf8d                	j	7e6 <printint+0x1a>

0000000000000876 <fflush>:
void fflush(int fd){
 876:	1101                	addi	sp,sp,-32
 878:	ec06                	sd	ra,24(sp)
 87a:	e822                	sd	s0,16(sp)
 87c:	e426                	sd	s1,8(sp)
 87e:	e04a                	sd	s2,0(sp)
 880:	1000                	addi	s0,sp,32
 882:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
 884:	00000097          	auipc	ra,0x0
 888:	e76080e7          	jalr	-394(ra) # 6fa <get_putc_buf>
 88c:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
 88e:	00291793          	slli	a5,s2,0x2
 892:	00000497          	auipc	s1,0x0
 896:	4de48493          	addi	s1,s1,1246 # d70 <putc_buf>
 89a:	94be                	add	s1,s1,a5
 89c:	3204a603          	lw	a2,800(s1)
 8a0:	854a                	mv	a0,s2
 8a2:	00000097          	auipc	ra,0x0
 8a6:	db0080e7          	jalr	-592(ra) # 652 <write>
  putc_index[fd] = 0;
 8aa:	3204a023          	sw	zero,800(s1)
}
 8ae:	60e2                	ld	ra,24(sp)
 8b0:	6442                	ld	s0,16(sp)
 8b2:	64a2                	ld	s1,8(sp)
 8b4:	6902                	ld	s2,0(sp)
 8b6:	6105                	addi	sp,sp,32
 8b8:	8082                	ret

00000000000008ba <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8ba:	7119                	addi	sp,sp,-128
 8bc:	fc86                	sd	ra,120(sp)
 8be:	f8a2                	sd	s0,112(sp)
 8c0:	f4a6                	sd	s1,104(sp)
 8c2:	f0ca                	sd	s2,96(sp)
 8c4:	ecce                	sd	s3,88(sp)
 8c6:	e8d2                	sd	s4,80(sp)
 8c8:	e4d6                	sd	s5,72(sp)
 8ca:	e0da                	sd	s6,64(sp)
 8cc:	fc5e                	sd	s7,56(sp)
 8ce:	f862                	sd	s8,48(sp)
 8d0:	f466                	sd	s9,40(sp)
 8d2:	f06a                	sd	s10,32(sp)
 8d4:	ec6e                	sd	s11,24(sp)
 8d6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8d8:	0005c903          	lbu	s2,0(a1)
 8dc:	18090f63          	beqz	s2,a7a <vprintf+0x1c0>
 8e0:	8aaa                	mv	s5,a0
 8e2:	8b32                	mv	s6,a2
 8e4:	00158493          	addi	s1,a1,1
  state = 0;
 8e8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8ea:	02500a13          	li	s4,37
      if(c == 'd'){
 8ee:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 8f2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 8f6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 8fa:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8fe:	00000b97          	auipc	s7,0x0
 902:	44ab8b93          	addi	s7,s7,1098 # d48 <digits>
 906:	a839                	j	924 <vprintf+0x6a>
        putc(fd, c);
 908:	85ca                	mv	a1,s2
 90a:	8556                	mv	a0,s5
 90c:	00000097          	auipc	ra,0x0
 910:	e3a080e7          	jalr	-454(ra) # 746 <putc>
 914:	a019                	j	91a <vprintf+0x60>
    } else if(state == '%'){
 916:	01498f63          	beq	s3,s4,934 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 91a:	0485                	addi	s1,s1,1
 91c:	fff4c903          	lbu	s2,-1(s1)
 920:	14090d63          	beqz	s2,a7a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 924:	0009079b          	sext.w	a5,s2
    if(state == 0){
 928:	fe0997e3          	bnez	s3,916 <vprintf+0x5c>
      if(c == '%'){
 92c:	fd479ee3          	bne	a5,s4,908 <vprintf+0x4e>
        state = '%';
 930:	89be                	mv	s3,a5
 932:	b7e5                	j	91a <vprintf+0x60>
      if(c == 'd'){
 934:	05878063          	beq	a5,s8,974 <vprintf+0xba>
      } else if(c == 'l') {
 938:	05978c63          	beq	a5,s9,990 <vprintf+0xd6>
      } else if(c == 'x') {
 93c:	07a78863          	beq	a5,s10,9ac <vprintf+0xf2>
      } else if(c == 'p') {
 940:	09b78463          	beq	a5,s11,9c8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 944:	07300713          	li	a4,115
 948:	0ce78663          	beq	a5,a4,a14 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 94c:	06300713          	li	a4,99
 950:	0ee78e63          	beq	a5,a4,a4c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 954:	11478863          	beq	a5,s4,a64 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 958:	85d2                	mv	a1,s4
 95a:	8556                	mv	a0,s5
 95c:	00000097          	auipc	ra,0x0
 960:	dea080e7          	jalr	-534(ra) # 746 <putc>
        putc(fd, c);
 964:	85ca                	mv	a1,s2
 966:	8556                	mv	a0,s5
 968:	00000097          	auipc	ra,0x0
 96c:	dde080e7          	jalr	-546(ra) # 746 <putc>
      }
      state = 0;
 970:	4981                	li	s3,0
 972:	b765                	j	91a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 974:	008b0913          	addi	s2,s6,8
 978:	4685                	li	a3,1
 97a:	4629                	li	a2,10
 97c:	000b2583          	lw	a1,0(s6)
 980:	8556                	mv	a0,s5
 982:	00000097          	auipc	ra,0x0
 986:	e4a080e7          	jalr	-438(ra) # 7cc <printint>
 98a:	8b4a                	mv	s6,s2
      state = 0;
 98c:	4981                	li	s3,0
 98e:	b771                	j	91a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 990:	008b0913          	addi	s2,s6,8
 994:	4681                	li	a3,0
 996:	4629                	li	a2,10
 998:	000b2583          	lw	a1,0(s6)
 99c:	8556                	mv	a0,s5
 99e:	00000097          	auipc	ra,0x0
 9a2:	e2e080e7          	jalr	-466(ra) # 7cc <printint>
 9a6:	8b4a                	mv	s6,s2
      state = 0;
 9a8:	4981                	li	s3,0
 9aa:	bf85                	j	91a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9ac:	008b0913          	addi	s2,s6,8
 9b0:	4681                	li	a3,0
 9b2:	4641                	li	a2,16
 9b4:	000b2583          	lw	a1,0(s6)
 9b8:	8556                	mv	a0,s5
 9ba:	00000097          	auipc	ra,0x0
 9be:	e12080e7          	jalr	-494(ra) # 7cc <printint>
 9c2:	8b4a                	mv	s6,s2
      state = 0;
 9c4:	4981                	li	s3,0
 9c6:	bf91                	j	91a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 9c8:	008b0793          	addi	a5,s6,8
 9cc:	f8f43423          	sd	a5,-120(s0)
 9d0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 9d4:	03000593          	li	a1,48
 9d8:	8556                	mv	a0,s5
 9da:	00000097          	auipc	ra,0x0
 9de:	d6c080e7          	jalr	-660(ra) # 746 <putc>
  putc(fd, 'x');
 9e2:	85ea                	mv	a1,s10
 9e4:	8556                	mv	a0,s5
 9e6:	00000097          	auipc	ra,0x0
 9ea:	d60080e7          	jalr	-672(ra) # 746 <putc>
 9ee:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9f0:	03c9d793          	srli	a5,s3,0x3c
 9f4:	97de                	add	a5,a5,s7
 9f6:	0007c583          	lbu	a1,0(a5)
 9fa:	8556                	mv	a0,s5
 9fc:	00000097          	auipc	ra,0x0
 a00:	d4a080e7          	jalr	-694(ra) # 746 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a04:	0992                	slli	s3,s3,0x4
 a06:	397d                	addiw	s2,s2,-1
 a08:	fe0914e3          	bnez	s2,9f0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 a0c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a10:	4981                	li	s3,0
 a12:	b721                	j	91a <vprintf+0x60>
        s = va_arg(ap, char*);
 a14:	008b0993          	addi	s3,s6,8
 a18:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 a1c:	02090163          	beqz	s2,a3e <vprintf+0x184>
        while(*s != 0){
 a20:	00094583          	lbu	a1,0(s2)
 a24:	c9a1                	beqz	a1,a74 <vprintf+0x1ba>
          putc(fd, *s);
 a26:	8556                	mv	a0,s5
 a28:	00000097          	auipc	ra,0x0
 a2c:	d1e080e7          	jalr	-738(ra) # 746 <putc>
          s++;
 a30:	0905                	addi	s2,s2,1
        while(*s != 0){
 a32:	00094583          	lbu	a1,0(s2)
 a36:	f9e5                	bnez	a1,a26 <vprintf+0x16c>
        s = va_arg(ap, char*);
 a38:	8b4e                	mv	s6,s3
      state = 0;
 a3a:	4981                	li	s3,0
 a3c:	bdf9                	j	91a <vprintf+0x60>
          s = "(null)";
 a3e:	00000917          	auipc	s2,0x0
 a42:	30290913          	addi	s2,s2,770 # d40 <malloc+0x1bc>
        while(*s != 0){
 a46:	02800593          	li	a1,40
 a4a:	bff1                	j	a26 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a4c:	008b0913          	addi	s2,s6,8
 a50:	000b4583          	lbu	a1,0(s6)
 a54:	8556                	mv	a0,s5
 a56:	00000097          	auipc	ra,0x0
 a5a:	cf0080e7          	jalr	-784(ra) # 746 <putc>
 a5e:	8b4a                	mv	s6,s2
      state = 0;
 a60:	4981                	li	s3,0
 a62:	bd65                	j	91a <vprintf+0x60>
        putc(fd, c);
 a64:	85d2                	mv	a1,s4
 a66:	8556                	mv	a0,s5
 a68:	00000097          	auipc	ra,0x0
 a6c:	cde080e7          	jalr	-802(ra) # 746 <putc>
      state = 0;
 a70:	4981                	li	s3,0
 a72:	b565                	j	91a <vprintf+0x60>
        s = va_arg(ap, char*);
 a74:	8b4e                	mv	s6,s3
      state = 0;
 a76:	4981                	li	s3,0
 a78:	b54d                	j	91a <vprintf+0x60>
    }
  }
}
 a7a:	70e6                	ld	ra,120(sp)
 a7c:	7446                	ld	s0,112(sp)
 a7e:	74a6                	ld	s1,104(sp)
 a80:	7906                	ld	s2,96(sp)
 a82:	69e6                	ld	s3,88(sp)
 a84:	6a46                	ld	s4,80(sp)
 a86:	6aa6                	ld	s5,72(sp)
 a88:	6b06                	ld	s6,64(sp)
 a8a:	7be2                	ld	s7,56(sp)
 a8c:	7c42                	ld	s8,48(sp)
 a8e:	7ca2                	ld	s9,40(sp)
 a90:	7d02                	ld	s10,32(sp)
 a92:	6de2                	ld	s11,24(sp)
 a94:	6109                	addi	sp,sp,128
 a96:	8082                	ret

0000000000000a98 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a98:	715d                	addi	sp,sp,-80
 a9a:	ec06                	sd	ra,24(sp)
 a9c:	e822                	sd	s0,16(sp)
 a9e:	1000                	addi	s0,sp,32
 aa0:	e010                	sd	a2,0(s0)
 aa2:	e414                	sd	a3,8(s0)
 aa4:	e818                	sd	a4,16(s0)
 aa6:	ec1c                	sd	a5,24(s0)
 aa8:	03043023          	sd	a6,32(s0)
 aac:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ab0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ab4:	8622                	mv	a2,s0
 ab6:	00000097          	auipc	ra,0x0
 aba:	e04080e7          	jalr	-508(ra) # 8ba <vprintf>
}
 abe:	60e2                	ld	ra,24(sp)
 ac0:	6442                	ld	s0,16(sp)
 ac2:	6161                	addi	sp,sp,80
 ac4:	8082                	ret

0000000000000ac6 <printf>:

void
printf(const char *fmt, ...)
{
 ac6:	711d                	addi	sp,sp,-96
 ac8:	ec06                	sd	ra,24(sp)
 aca:	e822                	sd	s0,16(sp)
 acc:	1000                	addi	s0,sp,32
 ace:	e40c                	sd	a1,8(s0)
 ad0:	e810                	sd	a2,16(s0)
 ad2:	ec14                	sd	a3,24(s0)
 ad4:	f018                	sd	a4,32(s0)
 ad6:	f41c                	sd	a5,40(s0)
 ad8:	03043823          	sd	a6,48(s0)
 adc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ae0:	00840613          	addi	a2,s0,8
 ae4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ae8:	85aa                	mv	a1,a0
 aea:	4505                	li	a0,1
 aec:	00000097          	auipc	ra,0x0
 af0:	dce080e7          	jalr	-562(ra) # 8ba <vprintf>
}
 af4:	60e2                	ld	ra,24(sp)
 af6:	6442                	ld	s0,16(sp)
 af8:	6125                	addi	sp,sp,96
 afa:	8082                	ret

0000000000000afc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 afc:	1141                	addi	sp,sp,-16
 afe:	e422                	sd	s0,8(sp)
 b00:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b02:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b06:	00000797          	auipc	a5,0x0
 b0a:	2627b783          	ld	a5,610(a5) # d68 <freep>
 b0e:	a805                	j	b3e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b10:	4618                	lw	a4,8(a2)
 b12:	9db9                	addw	a1,a1,a4
 b14:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b18:	6398                	ld	a4,0(a5)
 b1a:	6318                	ld	a4,0(a4)
 b1c:	fee53823          	sd	a4,-16(a0)
 b20:	a091                	j	b64 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b22:	ff852703          	lw	a4,-8(a0)
 b26:	9e39                	addw	a2,a2,a4
 b28:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b2a:	ff053703          	ld	a4,-16(a0)
 b2e:	e398                	sd	a4,0(a5)
 b30:	a099                	j	b76 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b32:	6398                	ld	a4,0(a5)
 b34:	00e7e463          	bltu	a5,a4,b3c <free+0x40>
 b38:	00e6ea63          	bltu	a3,a4,b4c <free+0x50>
{
 b3c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b3e:	fed7fae3          	bgeu	a5,a3,b32 <free+0x36>
 b42:	6398                	ld	a4,0(a5)
 b44:	00e6e463          	bltu	a3,a4,b4c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b48:	fee7eae3          	bltu	a5,a4,b3c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b4c:	ff852583          	lw	a1,-8(a0)
 b50:	6390                	ld	a2,0(a5)
 b52:	02059713          	slli	a4,a1,0x20
 b56:	9301                	srli	a4,a4,0x20
 b58:	0712                	slli	a4,a4,0x4
 b5a:	9736                	add	a4,a4,a3
 b5c:	fae60ae3          	beq	a2,a4,b10 <free+0x14>
    bp->s.ptr = p->s.ptr;
 b60:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b64:	4790                	lw	a2,8(a5)
 b66:	02061713          	slli	a4,a2,0x20
 b6a:	9301                	srli	a4,a4,0x20
 b6c:	0712                	slli	a4,a4,0x4
 b6e:	973e                	add	a4,a4,a5
 b70:	fae689e3          	beq	a3,a4,b22 <free+0x26>
  } else
    p->s.ptr = bp;
 b74:	e394                	sd	a3,0(a5)
  freep = p;
 b76:	00000717          	auipc	a4,0x0
 b7a:	1ef73923          	sd	a5,498(a4) # d68 <freep>
}
 b7e:	6422                	ld	s0,8(sp)
 b80:	0141                	addi	sp,sp,16
 b82:	8082                	ret

0000000000000b84 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b84:	7139                	addi	sp,sp,-64
 b86:	fc06                	sd	ra,56(sp)
 b88:	f822                	sd	s0,48(sp)
 b8a:	f426                	sd	s1,40(sp)
 b8c:	f04a                	sd	s2,32(sp)
 b8e:	ec4e                	sd	s3,24(sp)
 b90:	e852                	sd	s4,16(sp)
 b92:	e456                	sd	s5,8(sp)
 b94:	e05a                	sd	s6,0(sp)
 b96:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b98:	02051493          	slli	s1,a0,0x20
 b9c:	9081                	srli	s1,s1,0x20
 b9e:	04bd                	addi	s1,s1,15
 ba0:	8091                	srli	s1,s1,0x4
 ba2:	0014899b          	addiw	s3,s1,1
 ba6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ba8:	00000517          	auipc	a0,0x0
 bac:	1c053503          	ld	a0,448(a0) # d68 <freep>
 bb0:	c515                	beqz	a0,bdc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bb2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bb4:	4798                	lw	a4,8(a5)
 bb6:	02977f63          	bgeu	a4,s1,bf4 <malloc+0x70>
 bba:	8a4e                	mv	s4,s3
 bbc:	0009871b          	sext.w	a4,s3
 bc0:	6685                	lui	a3,0x1
 bc2:	00d77363          	bgeu	a4,a3,bc8 <malloc+0x44>
 bc6:	6a05                	lui	s4,0x1
 bc8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bcc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bd0:	00000917          	auipc	s2,0x0
 bd4:	19890913          	addi	s2,s2,408 # d68 <freep>
  if(p == (char*)-1)
 bd8:	5afd                	li	s5,-1
 bda:	a88d                	j	c4c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 bdc:	00000797          	auipc	a5,0x0
 be0:	64478793          	addi	a5,a5,1604 # 1220 <base>
 be4:	00000717          	auipc	a4,0x0
 be8:	18f73223          	sd	a5,388(a4) # d68 <freep>
 bec:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bee:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bf2:	b7e1                	j	bba <malloc+0x36>
      if(p->s.size == nunits)
 bf4:	02e48b63          	beq	s1,a4,c2a <malloc+0xa6>
        p->s.size -= nunits;
 bf8:	4137073b          	subw	a4,a4,s3
 bfc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bfe:	1702                	slli	a4,a4,0x20
 c00:	9301                	srli	a4,a4,0x20
 c02:	0712                	slli	a4,a4,0x4
 c04:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c06:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c0a:	00000717          	auipc	a4,0x0
 c0e:	14a73f23          	sd	a0,350(a4) # d68 <freep>
      return (void*)(p + 1);
 c12:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c16:	70e2                	ld	ra,56(sp)
 c18:	7442                	ld	s0,48(sp)
 c1a:	74a2                	ld	s1,40(sp)
 c1c:	7902                	ld	s2,32(sp)
 c1e:	69e2                	ld	s3,24(sp)
 c20:	6a42                	ld	s4,16(sp)
 c22:	6aa2                	ld	s5,8(sp)
 c24:	6b02                	ld	s6,0(sp)
 c26:	6121                	addi	sp,sp,64
 c28:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c2a:	6398                	ld	a4,0(a5)
 c2c:	e118                	sd	a4,0(a0)
 c2e:	bff1                	j	c0a <malloc+0x86>
  hp->s.size = nu;
 c30:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c34:	0541                	addi	a0,a0,16
 c36:	00000097          	auipc	ra,0x0
 c3a:	ec6080e7          	jalr	-314(ra) # afc <free>
  return freep;
 c3e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c42:	d971                	beqz	a0,c16 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c44:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c46:	4798                	lw	a4,8(a5)
 c48:	fa9776e3          	bgeu	a4,s1,bf4 <malloc+0x70>
    if(p == freep)
 c4c:	00093703          	ld	a4,0(s2)
 c50:	853e                	mv	a0,a5
 c52:	fef719e3          	bne	a4,a5,c44 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c56:	8552                	mv	a0,s4
 c58:	00000097          	auipc	ra,0x0
 c5c:	a62080e7          	jalr	-1438(ra) # 6ba <sbrk>
  if(p == (char*)-1)
 c60:	fd5518e3          	bne	a0,s5,c30 <malloc+0xac>
        return 0;
 c64:	4501                	li	a0,0
 c66:	bf45                	j	c16 <malloc+0x92>
