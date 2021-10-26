
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  fprintf(2, "$ ");
      10:	00001597          	auipc	a1,0x1
      14:	50058593          	addi	a1,a1,1280 # 1510 <malloc+0x11c>
      18:	4509                	li	a0,2
      1a:	00001097          	auipc	ra,0x1
      1e:	2ec080e7          	jalr	748(ra) # 1306 <fprintf>
  fflush(2);
      22:	4509                	li	a0,2
      24:	00001097          	auipc	ra,0x1
      28:	0c4080e7          	jalr	196(ra) # 10e8 <fflush>
  memset(buf, 0, nbuf);
      2c:	864a                	mv	a2,s2
      2e:	4581                	li	a1,0
      30:	8526                	mv	a0,s1
      32:	00001097          	auipc	ra,0x1
      36:	c08080e7          	jalr	-1016(ra) # c3a <memset>
  gets(buf, nbuf);
      3a:	85ca                	mv	a1,s2
      3c:	8526                	mv	a0,s1
      3e:	00001097          	auipc	ra,0x1
      42:	c4c080e7          	jalr	-948(ra) # c8a <gets>
  if(buf[0] == 0) // EOF
      46:	0004c503          	lbu	a0,0(s1)
      4a:	00153513          	seqz	a0,a0
      4e:	40a0053b          	negw	a0,a0
    return -1;
  return 0;
}
      52:	2501                	sext.w	a0,a0
      54:	60e2                	ld	ra,24(sp)
      56:	6442                	ld	s0,16(sp)
      58:	64a2                	ld	s1,8(sp)
      5a:	6902                	ld	s2,0(sp)
      5c:	6105                	addi	sp,sp,32
      5e:	8082                	ret

0000000000000060 <panic>:
  exit(0);
}

void
panic(char *s)
{
      60:	1141                	addi	sp,sp,-16
      62:	e406                	sd	ra,8(sp)
      64:	e022                	sd	s0,0(sp)
      66:	0800                	addi	s0,sp,16
  fprintf(2, "%s\n", s);
      68:	862a                	mv	a2,a0
      6a:	00001597          	auipc	a1,0x1
      6e:	4ae58593          	addi	a1,a1,1198 # 1518 <malloc+0x124>
      72:	4509                	li	a0,2
      74:	00001097          	auipc	ra,0x1
      78:	292080e7          	jalr	658(ra) # 1306 <fprintf>
  exit(1);
      7c:	4505                	li	a0,1
      7e:	00001097          	auipc	ra,0x1
      82:	e20080e7          	jalr	-480(ra) # e9e <exit>

0000000000000086 <fork1>:
}

int
fork1(void)
{
      86:	1141                	addi	sp,sp,-16
      88:	e406                	sd	ra,8(sp)
      8a:	e022                	sd	s0,0(sp)
      8c:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      8e:	00001097          	auipc	ra,0x1
      92:	e08080e7          	jalr	-504(ra) # e96 <fork>
  if(pid == -1)
      96:	57fd                	li	a5,-1
      98:	00f50663          	beq	a0,a5,a4 <fork1+0x1e>
    panic("fork");
  return pid;
}
      9c:	60a2                	ld	ra,8(sp)
      9e:	6402                	ld	s0,0(sp)
      a0:	0141                	addi	sp,sp,16
      a2:	8082                	ret
    panic("fork");
      a4:	00001517          	auipc	a0,0x1
      a8:	47c50513          	addi	a0,a0,1148 # 1520 <malloc+0x12c>
      ac:	00000097          	auipc	ra,0x0
      b0:	fb4080e7          	jalr	-76(ra) # 60 <panic>

00000000000000b4 <runcmd>:
{
      b4:	7179                	addi	sp,sp,-48
      b6:	f406                	sd	ra,40(sp)
      b8:	f022                	sd	s0,32(sp)
      ba:	ec26                	sd	s1,24(sp)
      bc:	1800                	addi	s0,sp,48
  if(cmd == 0)
      be:	c10d                	beqz	a0,e0 <runcmd+0x2c>
      c0:	84aa                	mv	s1,a0
  switch(cmd->type){
      c2:	4118                	lw	a4,0(a0)
      c4:	4795                	li	a5,5
      c6:	02e7e263          	bltu	a5,a4,ea <runcmd+0x36>
      ca:	00056783          	lwu	a5,0(a0)
      ce:	078a                	slli	a5,a5,0x2
      d0:	00001717          	auipc	a4,0x1
      d4:	41070713          	addi	a4,a4,1040 # 14e0 <malloc+0xec>
      d8:	97ba                	add	a5,a5,a4
      da:	439c                	lw	a5,0(a5)
      dc:	97ba                	add	a5,a5,a4
      de:	8782                	jr	a5
    exit(1);
      e0:	4505                	li	a0,1
      e2:	00001097          	auipc	ra,0x1
      e6:	dbc080e7          	jalr	-580(ra) # e9e <exit>
    panic("runcmd");
      ea:	00001517          	auipc	a0,0x1
      ee:	43e50513          	addi	a0,a0,1086 # 1528 <malloc+0x134>
      f2:	00000097          	auipc	ra,0x0
      f6:	f6e080e7          	jalr	-146(ra) # 60 <panic>
    if(ecmd->argv[0] == 0)
      fa:	6508                	ld	a0,8(a0)
      fc:	c515                	beqz	a0,128 <runcmd+0x74>
    exec(ecmd->argv[0], ecmd->argv);
      fe:	00848593          	addi	a1,s1,8
     102:	00001097          	auipc	ra,0x1
     106:	dd4080e7          	jalr	-556(ra) # ed6 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     10a:	6490                	ld	a2,8(s1)
     10c:	00001597          	auipc	a1,0x1
     110:	42458593          	addi	a1,a1,1060 # 1530 <malloc+0x13c>
     114:	4509                	li	a0,2
     116:	00001097          	auipc	ra,0x1
     11a:	1f0080e7          	jalr	496(ra) # 1306 <fprintf>
  exit(0);
     11e:	4501                	li	a0,0
     120:	00001097          	auipc	ra,0x1
     124:	d7e080e7          	jalr	-642(ra) # e9e <exit>
      exit(1);
     128:	4505                	li	a0,1
     12a:	00001097          	auipc	ra,0x1
     12e:	d74080e7          	jalr	-652(ra) # e9e <exit>
    close(rcmd->fd);
     132:	5148                	lw	a0,36(a0)
     134:	00001097          	auipc	ra,0x1
     138:	cce080e7          	jalr	-818(ra) # e02 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     13c:	508c                	lw	a1,32(s1)
     13e:	6888                	ld	a0,16(s1)
     140:	00001097          	auipc	ra,0x1
     144:	d9e080e7          	jalr	-610(ra) # ede <open>
     148:	00054763          	bltz	a0,156 <runcmd+0xa2>
    runcmd(rcmd->cmd);
     14c:	6488                	ld	a0,8(s1)
     14e:	00000097          	auipc	ra,0x0
     152:	f66080e7          	jalr	-154(ra) # b4 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     156:	6890                	ld	a2,16(s1)
     158:	00001597          	auipc	a1,0x1
     15c:	3e858593          	addi	a1,a1,1000 # 1540 <malloc+0x14c>
     160:	4509                	li	a0,2
     162:	00001097          	auipc	ra,0x1
     166:	1a4080e7          	jalr	420(ra) # 1306 <fprintf>
      exit(1);
     16a:	4505                	li	a0,1
     16c:	00001097          	auipc	ra,0x1
     170:	d32080e7          	jalr	-718(ra) # e9e <exit>
    if(fork1() == 0)
     174:	00000097          	auipc	ra,0x0
     178:	f12080e7          	jalr	-238(ra) # 86 <fork1>
     17c:	c919                	beqz	a0,192 <runcmd+0xde>
    wait(0);
     17e:	4501                	li	a0,0
     180:	00001097          	auipc	ra,0x1
     184:	d26080e7          	jalr	-730(ra) # ea6 <wait>
    runcmd(lcmd->right);
     188:	6888                	ld	a0,16(s1)
     18a:	00000097          	auipc	ra,0x0
     18e:	f2a080e7          	jalr	-214(ra) # b4 <runcmd>
      runcmd(lcmd->left);
     192:	6488                	ld	a0,8(s1)
     194:	00000097          	auipc	ra,0x0
     198:	f20080e7          	jalr	-224(ra) # b4 <runcmd>
    if(pipe(p) < 0)
     19c:	fd840513          	addi	a0,s0,-40
     1a0:	00001097          	auipc	ra,0x1
     1a4:	d0e080e7          	jalr	-754(ra) # eae <pipe>
     1a8:	04054363          	bltz	a0,1ee <runcmd+0x13a>
    if(fork1() == 0){
     1ac:	00000097          	auipc	ra,0x0
     1b0:	eda080e7          	jalr	-294(ra) # 86 <fork1>
     1b4:	c529                	beqz	a0,1fe <runcmd+0x14a>
    if(fork1() == 0){
     1b6:	00000097          	auipc	ra,0x0
     1ba:	ed0080e7          	jalr	-304(ra) # 86 <fork1>
     1be:	cd25                	beqz	a0,236 <runcmd+0x182>
    close(p[0]);
     1c0:	fd842503          	lw	a0,-40(s0)
     1c4:	00001097          	auipc	ra,0x1
     1c8:	c3e080e7          	jalr	-962(ra) # e02 <close>
    close(p[1]);
     1cc:	fdc42503          	lw	a0,-36(s0)
     1d0:	00001097          	auipc	ra,0x1
     1d4:	c32080e7          	jalr	-974(ra) # e02 <close>
    wait(0);
     1d8:	4501                	li	a0,0
     1da:	00001097          	auipc	ra,0x1
     1de:	ccc080e7          	jalr	-820(ra) # ea6 <wait>
    wait(0);
     1e2:	4501                	li	a0,0
     1e4:	00001097          	auipc	ra,0x1
     1e8:	cc2080e7          	jalr	-830(ra) # ea6 <wait>
    break;
     1ec:	bf0d                	j	11e <runcmd+0x6a>
      panic("pipe");
     1ee:	00001517          	auipc	a0,0x1
     1f2:	36250513          	addi	a0,a0,866 # 1550 <malloc+0x15c>
     1f6:	00000097          	auipc	ra,0x0
     1fa:	e6a080e7          	jalr	-406(ra) # 60 <panic>
      close(1);
     1fe:	4505                	li	a0,1
     200:	00001097          	auipc	ra,0x1
     204:	c02080e7          	jalr	-1022(ra) # e02 <close>
      dup(p[1]);
     208:	fdc42503          	lw	a0,-36(s0)
     20c:	00001097          	auipc	ra,0x1
     210:	d0a080e7          	jalr	-758(ra) # f16 <dup>
      close(p[0]);
     214:	fd842503          	lw	a0,-40(s0)
     218:	00001097          	auipc	ra,0x1
     21c:	bea080e7          	jalr	-1046(ra) # e02 <close>
      close(p[1]);
     220:	fdc42503          	lw	a0,-36(s0)
     224:	00001097          	auipc	ra,0x1
     228:	bde080e7          	jalr	-1058(ra) # e02 <close>
      runcmd(pcmd->left);
     22c:	6488                	ld	a0,8(s1)
     22e:	00000097          	auipc	ra,0x0
     232:	e86080e7          	jalr	-378(ra) # b4 <runcmd>
      close(0);
     236:	00001097          	auipc	ra,0x1
     23a:	bcc080e7          	jalr	-1076(ra) # e02 <close>
      dup(p[0]);
     23e:	fd842503          	lw	a0,-40(s0)
     242:	00001097          	auipc	ra,0x1
     246:	cd4080e7          	jalr	-812(ra) # f16 <dup>
      close(p[0]);
     24a:	fd842503          	lw	a0,-40(s0)
     24e:	00001097          	auipc	ra,0x1
     252:	bb4080e7          	jalr	-1100(ra) # e02 <close>
      close(p[1]);
     256:	fdc42503          	lw	a0,-36(s0)
     25a:	00001097          	auipc	ra,0x1
     25e:	ba8080e7          	jalr	-1112(ra) # e02 <close>
      runcmd(pcmd->right);
     262:	6888                	ld	a0,16(s1)
     264:	00000097          	auipc	ra,0x0
     268:	e50080e7          	jalr	-432(ra) # b4 <runcmd>
    if(fork1() == 0)
     26c:	00000097          	auipc	ra,0x0
     270:	e1a080e7          	jalr	-486(ra) # 86 <fork1>
     274:	ea0515e3          	bnez	a0,11e <runcmd+0x6a>
      runcmd(bcmd->cmd);
     278:	6488                	ld	a0,8(s1)
     27a:	00000097          	auipc	ra,0x0
     27e:	e3a080e7          	jalr	-454(ra) # b4 <runcmd>

0000000000000282 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     282:	1101                	addi	sp,sp,-32
     284:	ec06                	sd	ra,24(sp)
     286:	e822                	sd	s0,16(sp)
     288:	e426                	sd	s1,8(sp)
     28a:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     28c:	0a800513          	li	a0,168
     290:	00001097          	auipc	ra,0x1
     294:	164080e7          	jalr	356(ra) # 13f4 <malloc>
     298:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     29a:	0a800613          	li	a2,168
     29e:	4581                	li	a1,0
     2a0:	00001097          	auipc	ra,0x1
     2a4:	99a080e7          	jalr	-1638(ra) # c3a <memset>
  cmd->type = EXEC;
     2a8:	4785                	li	a5,1
     2aa:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     2ac:	8526                	mv	a0,s1
     2ae:	60e2                	ld	ra,24(sp)
     2b0:	6442                	ld	s0,16(sp)
     2b2:	64a2                	ld	s1,8(sp)
     2b4:	6105                	addi	sp,sp,32
     2b6:	8082                	ret

00000000000002b8 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2b8:	7139                	addi	sp,sp,-64
     2ba:	fc06                	sd	ra,56(sp)
     2bc:	f822                	sd	s0,48(sp)
     2be:	f426                	sd	s1,40(sp)
     2c0:	f04a                	sd	s2,32(sp)
     2c2:	ec4e                	sd	s3,24(sp)
     2c4:	e852                	sd	s4,16(sp)
     2c6:	e456                	sd	s5,8(sp)
     2c8:	e05a                	sd	s6,0(sp)
     2ca:	0080                	addi	s0,sp,64
     2cc:	8b2a                	mv	s6,a0
     2ce:	8aae                	mv	s5,a1
     2d0:	8a32                	mv	s4,a2
     2d2:	89b6                	mv	s3,a3
     2d4:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2d6:	02800513          	li	a0,40
     2da:	00001097          	auipc	ra,0x1
     2de:	11a080e7          	jalr	282(ra) # 13f4 <malloc>
     2e2:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2e4:	02800613          	li	a2,40
     2e8:	4581                	li	a1,0
     2ea:	00001097          	auipc	ra,0x1
     2ee:	950080e7          	jalr	-1712(ra) # c3a <memset>
  cmd->type = REDIR;
     2f2:	4789                	li	a5,2
     2f4:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     2f6:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     2fa:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     2fe:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     302:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     306:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     30a:	8526                	mv	a0,s1
     30c:	70e2                	ld	ra,56(sp)
     30e:	7442                	ld	s0,48(sp)
     310:	74a2                	ld	s1,40(sp)
     312:	7902                	ld	s2,32(sp)
     314:	69e2                	ld	s3,24(sp)
     316:	6a42                	ld	s4,16(sp)
     318:	6aa2                	ld	s5,8(sp)
     31a:	6b02                	ld	s6,0(sp)
     31c:	6121                	addi	sp,sp,64
     31e:	8082                	ret

0000000000000320 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     320:	7179                	addi	sp,sp,-48
     322:	f406                	sd	ra,40(sp)
     324:	f022                	sd	s0,32(sp)
     326:	ec26                	sd	s1,24(sp)
     328:	e84a                	sd	s2,16(sp)
     32a:	e44e                	sd	s3,8(sp)
     32c:	1800                	addi	s0,sp,48
     32e:	89aa                	mv	s3,a0
     330:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     332:	4561                	li	a0,24
     334:	00001097          	auipc	ra,0x1
     338:	0c0080e7          	jalr	192(ra) # 13f4 <malloc>
     33c:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     33e:	4661                	li	a2,24
     340:	4581                	li	a1,0
     342:	00001097          	auipc	ra,0x1
     346:	8f8080e7          	jalr	-1800(ra) # c3a <memset>
  cmd->type = PIPE;
     34a:	478d                	li	a5,3
     34c:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     34e:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     352:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     356:	8526                	mv	a0,s1
     358:	70a2                	ld	ra,40(sp)
     35a:	7402                	ld	s0,32(sp)
     35c:	64e2                	ld	s1,24(sp)
     35e:	6942                	ld	s2,16(sp)
     360:	69a2                	ld	s3,8(sp)
     362:	6145                	addi	sp,sp,48
     364:	8082                	ret

0000000000000366 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     366:	7179                	addi	sp,sp,-48
     368:	f406                	sd	ra,40(sp)
     36a:	f022                	sd	s0,32(sp)
     36c:	ec26                	sd	s1,24(sp)
     36e:	e84a                	sd	s2,16(sp)
     370:	e44e                	sd	s3,8(sp)
     372:	1800                	addi	s0,sp,48
     374:	89aa                	mv	s3,a0
     376:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     378:	4561                	li	a0,24
     37a:	00001097          	auipc	ra,0x1
     37e:	07a080e7          	jalr	122(ra) # 13f4 <malloc>
     382:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     384:	4661                	li	a2,24
     386:	4581                	li	a1,0
     388:	00001097          	auipc	ra,0x1
     38c:	8b2080e7          	jalr	-1870(ra) # c3a <memset>
  cmd->type = LIST;
     390:	4791                	li	a5,4
     392:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     394:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     398:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     39c:	8526                	mv	a0,s1
     39e:	70a2                	ld	ra,40(sp)
     3a0:	7402                	ld	s0,32(sp)
     3a2:	64e2                	ld	s1,24(sp)
     3a4:	6942                	ld	s2,16(sp)
     3a6:	69a2                	ld	s3,8(sp)
     3a8:	6145                	addi	sp,sp,48
     3aa:	8082                	ret

00000000000003ac <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     3ac:	1101                	addi	sp,sp,-32
     3ae:	ec06                	sd	ra,24(sp)
     3b0:	e822                	sd	s0,16(sp)
     3b2:	e426                	sd	s1,8(sp)
     3b4:	e04a                	sd	s2,0(sp)
     3b6:	1000                	addi	s0,sp,32
     3b8:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3ba:	4541                	li	a0,16
     3bc:	00001097          	auipc	ra,0x1
     3c0:	038080e7          	jalr	56(ra) # 13f4 <malloc>
     3c4:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3c6:	4641                	li	a2,16
     3c8:	4581                	li	a1,0
     3ca:	00001097          	auipc	ra,0x1
     3ce:	870080e7          	jalr	-1936(ra) # c3a <memset>
  cmd->type = BACK;
     3d2:	4795                	li	a5,5
     3d4:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3d6:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     3da:	8526                	mv	a0,s1
     3dc:	60e2                	ld	ra,24(sp)
     3de:	6442                	ld	s0,16(sp)
     3e0:	64a2                	ld	s1,8(sp)
     3e2:	6902                	ld	s2,0(sp)
     3e4:	6105                	addi	sp,sp,32
     3e6:	8082                	ret

00000000000003e8 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     3e8:	7139                	addi	sp,sp,-64
     3ea:	fc06                	sd	ra,56(sp)
     3ec:	f822                	sd	s0,48(sp)
     3ee:	f426                	sd	s1,40(sp)
     3f0:	f04a                	sd	s2,32(sp)
     3f2:	ec4e                	sd	s3,24(sp)
     3f4:	e852                	sd	s4,16(sp)
     3f6:	e456                	sd	s5,8(sp)
     3f8:	e05a                	sd	s6,0(sp)
     3fa:	0080                	addi	s0,sp,64
     3fc:	8a2a                	mv	s4,a0
     3fe:	892e                	mv	s2,a1
     400:	8ab2                	mv	s5,a2
     402:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     404:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     406:	00001997          	auipc	s3,0x1
     40a:	27298993          	addi	s3,s3,626 # 1678 <whitespace>
     40e:	00b4fd63          	bleu	a1,s1,428 <gettoken+0x40>
     412:	0004c583          	lbu	a1,0(s1)
     416:	854e                	mv	a0,s3
     418:	00001097          	auipc	ra,0x1
     41c:	848080e7          	jalr	-1976(ra) # c60 <strchr>
     420:	c501                	beqz	a0,428 <gettoken+0x40>
    s++;
     422:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     424:	fe9917e3          	bne	s2,s1,412 <gettoken+0x2a>
  if(q)
     428:	000a8463          	beqz	s5,430 <gettoken+0x48>
    *q = s;
     42c:	009ab023          	sd	s1,0(s5)
  ret = *s;
     430:	0004c783          	lbu	a5,0(s1)
     434:	00078a9b          	sext.w	s5,a5
  switch(*s){
     438:	02900713          	li	a4,41
     43c:	08f76f63          	bltu	a4,a5,4da <gettoken+0xf2>
     440:	02800713          	li	a4,40
     444:	0ae7f863          	bleu	a4,a5,4f4 <gettoken+0x10c>
     448:	e3b9                	bnez	a5,48e <gettoken+0xa6>
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     44a:	000b0463          	beqz	s6,452 <gettoken+0x6a>
    *eq = s;
     44e:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     452:	00001997          	auipc	s3,0x1
     456:	22698993          	addi	s3,s3,550 # 1678 <whitespace>
     45a:	0124fd63          	bleu	s2,s1,474 <gettoken+0x8c>
     45e:	0004c583          	lbu	a1,0(s1)
     462:	854e                	mv	a0,s3
     464:	00000097          	auipc	ra,0x0
     468:	7fc080e7          	jalr	2044(ra) # c60 <strchr>
     46c:	c501                	beqz	a0,474 <gettoken+0x8c>
    s++;
     46e:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     470:	fe9917e3          	bne	s2,s1,45e <gettoken+0x76>
  *ps = s;
     474:	009a3023          	sd	s1,0(s4)
  return ret;
}
     478:	8556                	mv	a0,s5
     47a:	70e2                	ld	ra,56(sp)
     47c:	7442                	ld	s0,48(sp)
     47e:	74a2                	ld	s1,40(sp)
     480:	7902                	ld	s2,32(sp)
     482:	69e2                	ld	s3,24(sp)
     484:	6a42                	ld	s4,16(sp)
     486:	6aa2                	ld	s5,8(sp)
     488:	6b02                	ld	s6,0(sp)
     48a:	6121                	addi	sp,sp,64
     48c:	8082                	ret
  switch(*s){
     48e:	02600713          	li	a4,38
     492:	06e78163          	beq	a5,a4,4f4 <gettoken+0x10c>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     496:	00001997          	auipc	s3,0x1
     49a:	1e298993          	addi	s3,s3,482 # 1678 <whitespace>
     49e:	00001a97          	auipc	s5,0x1
     4a2:	1d2a8a93          	addi	s5,s5,466 # 1670 <symbols>
     4a6:	0324f563          	bleu	s2,s1,4d0 <gettoken+0xe8>
     4aa:	0004c583          	lbu	a1,0(s1)
     4ae:	854e                	mv	a0,s3
     4b0:	00000097          	auipc	ra,0x0
     4b4:	7b0080e7          	jalr	1968(ra) # c60 <strchr>
     4b8:	e53d                	bnez	a0,526 <gettoken+0x13e>
     4ba:	0004c583          	lbu	a1,0(s1)
     4be:	8556                	mv	a0,s5
     4c0:	00000097          	auipc	ra,0x0
     4c4:	7a0080e7          	jalr	1952(ra) # c60 <strchr>
     4c8:	ed21                	bnez	a0,520 <gettoken+0x138>
      s++;
     4ca:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4cc:	fc991fe3          	bne	s2,s1,4aa <gettoken+0xc2>
  if(eq)
     4d0:	06100a93          	li	s5,97
     4d4:	f60b1de3          	bnez	s6,44e <gettoken+0x66>
     4d8:	bf71                	j	474 <gettoken+0x8c>
  switch(*s){
     4da:	03e00713          	li	a4,62
     4de:	02e78263          	beq	a5,a4,502 <gettoken+0x11a>
     4e2:	00f76b63          	bltu	a4,a5,4f8 <gettoken+0x110>
     4e6:	fc57879b          	addiw	a5,a5,-59
     4ea:	0ff7f793          	andi	a5,a5,255
     4ee:	4705                	li	a4,1
     4f0:	faf763e3          	bltu	a4,a5,496 <gettoken+0xae>
    s++;
     4f4:	0485                	addi	s1,s1,1
    break;
     4f6:	bf91                	j	44a <gettoken+0x62>
  switch(*s){
     4f8:	07c00713          	li	a4,124
     4fc:	fee78ce3          	beq	a5,a4,4f4 <gettoken+0x10c>
     500:	bf59                	j	496 <gettoken+0xae>
    s++;
     502:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     506:	0014c703          	lbu	a4,1(s1)
     50a:	03e00793          	li	a5,62
      s++;
     50e:	0489                	addi	s1,s1,2
      ret = '+';
     510:	02b00a93          	li	s5,43
    if(*s == '>'){
     514:	f2f70be3          	beq	a4,a5,44a <gettoken+0x62>
    s++;
     518:	84b6                	mv	s1,a3
  ret = *s;
     51a:	03e00a93          	li	s5,62
     51e:	b735                	j	44a <gettoken+0x62>
    ret = 'a';
     520:	06100a93          	li	s5,97
     524:	b71d                	j	44a <gettoken+0x62>
     526:	06100a93          	li	s5,97
     52a:	b705                	j	44a <gettoken+0x62>

000000000000052c <peek>:

int
peek(char **ps, char *es, char *toks)
{
     52c:	7139                	addi	sp,sp,-64
     52e:	fc06                	sd	ra,56(sp)
     530:	f822                	sd	s0,48(sp)
     532:	f426                	sd	s1,40(sp)
     534:	f04a                	sd	s2,32(sp)
     536:	ec4e                	sd	s3,24(sp)
     538:	e852                	sd	s4,16(sp)
     53a:	e456                	sd	s5,8(sp)
     53c:	0080                	addi	s0,sp,64
     53e:	8a2a                	mv	s4,a0
     540:	892e                	mv	s2,a1
     542:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     544:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     546:	00001997          	auipc	s3,0x1
     54a:	13298993          	addi	s3,s3,306 # 1678 <whitespace>
     54e:	00b4fd63          	bleu	a1,s1,568 <peek+0x3c>
     552:	0004c583          	lbu	a1,0(s1)
     556:	854e                	mv	a0,s3
     558:	00000097          	auipc	ra,0x0
     55c:	708080e7          	jalr	1800(ra) # c60 <strchr>
     560:	c501                	beqz	a0,568 <peek+0x3c>
    s++;
     562:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     564:	fe9917e3          	bne	s2,s1,552 <peek+0x26>
  *ps = s;
     568:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     56c:	0004c583          	lbu	a1,0(s1)
     570:	4501                	li	a0,0
     572:	e991                	bnez	a1,586 <peek+0x5a>
}
     574:	70e2                	ld	ra,56(sp)
     576:	7442                	ld	s0,48(sp)
     578:	74a2                	ld	s1,40(sp)
     57a:	7902                	ld	s2,32(sp)
     57c:	69e2                	ld	s3,24(sp)
     57e:	6a42                	ld	s4,16(sp)
     580:	6aa2                	ld	s5,8(sp)
     582:	6121                	addi	sp,sp,64
     584:	8082                	ret
  return *s && strchr(toks, *s);
     586:	8556                	mv	a0,s5
     588:	00000097          	auipc	ra,0x0
     58c:	6d8080e7          	jalr	1752(ra) # c60 <strchr>
     590:	00a03533          	snez	a0,a0
     594:	b7c5                	j	574 <peek+0x48>

0000000000000596 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     596:	7159                	addi	sp,sp,-112
     598:	f486                	sd	ra,104(sp)
     59a:	f0a2                	sd	s0,96(sp)
     59c:	eca6                	sd	s1,88(sp)
     59e:	e8ca                	sd	s2,80(sp)
     5a0:	e4ce                	sd	s3,72(sp)
     5a2:	e0d2                	sd	s4,64(sp)
     5a4:	fc56                	sd	s5,56(sp)
     5a6:	f85a                	sd	s6,48(sp)
     5a8:	f45e                	sd	s7,40(sp)
     5aa:	f062                	sd	s8,32(sp)
     5ac:	ec66                	sd	s9,24(sp)
     5ae:	1880                	addi	s0,sp,112
     5b0:	8b2a                	mv	s6,a0
     5b2:	89ae                	mv	s3,a1
     5b4:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5b6:	00001b97          	auipc	s7,0x1
     5ba:	fc2b8b93          	addi	s7,s7,-62 # 1578 <malloc+0x184>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     5be:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     5c2:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     5c6:	a02d                	j	5f0 <parseredirs+0x5a>
      panic("missing file for redirection");
     5c8:	00001517          	auipc	a0,0x1
     5cc:	f9050513          	addi	a0,a0,-112 # 1558 <malloc+0x164>
     5d0:	00000097          	auipc	ra,0x0
     5d4:	a90080e7          	jalr	-1392(ra) # 60 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5d8:	4701                	li	a4,0
     5da:	4681                	li	a3,0
     5dc:	f9043603          	ld	a2,-112(s0)
     5e0:	f9843583          	ld	a1,-104(s0)
     5e4:	855a                	mv	a0,s6
     5e6:	00000097          	auipc	ra,0x0
     5ea:	cd2080e7          	jalr	-814(ra) # 2b8 <redircmd>
     5ee:	8b2a                	mv	s6,a0
    switch(tok){
     5f0:	03e00a93          	li	s5,62
     5f4:	02b00a13          	li	s4,43
  while(peek(ps, es, "<>")){
     5f8:	865e                	mv	a2,s7
     5fa:	85ca                	mv	a1,s2
     5fc:	854e                	mv	a0,s3
     5fe:	00000097          	auipc	ra,0x0
     602:	f2e080e7          	jalr	-210(ra) # 52c <peek>
     606:	c925                	beqz	a0,676 <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     608:	4681                	li	a3,0
     60a:	4601                	li	a2,0
     60c:	85ca                	mv	a1,s2
     60e:	854e                	mv	a0,s3
     610:	00000097          	auipc	ra,0x0
     614:	dd8080e7          	jalr	-552(ra) # 3e8 <gettoken>
     618:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     61a:	f9040693          	addi	a3,s0,-112
     61e:	f9840613          	addi	a2,s0,-104
     622:	85ca                	mv	a1,s2
     624:	854e                	mv	a0,s3
     626:	00000097          	auipc	ra,0x0
     62a:	dc2080e7          	jalr	-574(ra) # 3e8 <gettoken>
     62e:	f9851de3          	bne	a0,s8,5c8 <parseredirs+0x32>
    switch(tok){
     632:	fb9483e3          	beq	s1,s9,5d8 <parseredirs+0x42>
     636:	03548263          	beq	s1,s5,65a <parseredirs+0xc4>
     63a:	fb449fe3          	bne	s1,s4,5f8 <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     63e:	4705                	li	a4,1
     640:	20100693          	li	a3,513
     644:	f9043603          	ld	a2,-112(s0)
     648:	f9843583          	ld	a1,-104(s0)
     64c:	855a                	mv	a0,s6
     64e:	00000097          	auipc	ra,0x0
     652:	c6a080e7          	jalr	-918(ra) # 2b8 <redircmd>
     656:	8b2a                	mv	s6,a0
      break;
     658:	bf61                	j	5f0 <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     65a:	4705                	li	a4,1
     65c:	20100693          	li	a3,513
     660:	f9043603          	ld	a2,-112(s0)
     664:	f9843583          	ld	a1,-104(s0)
     668:	855a                	mv	a0,s6
     66a:	00000097          	auipc	ra,0x0
     66e:	c4e080e7          	jalr	-946(ra) # 2b8 <redircmd>
     672:	8b2a                	mv	s6,a0
      break;
     674:	bfb5                	j	5f0 <parseredirs+0x5a>
    }
  }
  return cmd;
}
     676:	855a                	mv	a0,s6
     678:	70a6                	ld	ra,104(sp)
     67a:	7406                	ld	s0,96(sp)
     67c:	64e6                	ld	s1,88(sp)
     67e:	6946                	ld	s2,80(sp)
     680:	69a6                	ld	s3,72(sp)
     682:	6a06                	ld	s4,64(sp)
     684:	7ae2                	ld	s5,56(sp)
     686:	7b42                	ld	s6,48(sp)
     688:	7ba2                	ld	s7,40(sp)
     68a:	7c02                	ld	s8,32(sp)
     68c:	6ce2                	ld	s9,24(sp)
     68e:	6165                	addi	sp,sp,112
     690:	8082                	ret

0000000000000692 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     692:	7159                	addi	sp,sp,-112
     694:	f486                	sd	ra,104(sp)
     696:	f0a2                	sd	s0,96(sp)
     698:	eca6                	sd	s1,88(sp)
     69a:	e8ca                	sd	s2,80(sp)
     69c:	e4ce                	sd	s3,72(sp)
     69e:	e0d2                	sd	s4,64(sp)
     6a0:	fc56                	sd	s5,56(sp)
     6a2:	f85a                	sd	s6,48(sp)
     6a4:	f45e                	sd	s7,40(sp)
     6a6:	f062                	sd	s8,32(sp)
     6a8:	ec66                	sd	s9,24(sp)
     6aa:	1880                	addi	s0,sp,112
     6ac:	89aa                	mv	s3,a0
     6ae:	8a2e                	mv	s4,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6b0:	00001617          	auipc	a2,0x1
     6b4:	ed060613          	addi	a2,a2,-304 # 1580 <malloc+0x18c>
     6b8:	00000097          	auipc	ra,0x0
     6bc:	e74080e7          	jalr	-396(ra) # 52c <peek>
     6c0:	e905                	bnez	a0,6f0 <parseexec+0x5e>
     6c2:	892a                	mv	s2,a0
    return parseblock(ps, es);

  ret = execcmd();
     6c4:	00000097          	auipc	ra,0x0
     6c8:	bbe080e7          	jalr	-1090(ra) # 282 <execcmd>
     6cc:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     6ce:	8652                	mv	a2,s4
     6d0:	85ce                	mv	a1,s3
     6d2:	00000097          	auipc	ra,0x0
     6d6:	ec4080e7          	jalr	-316(ra) # 596 <parseredirs>
     6da:	8aaa                	mv	s5,a0
  while(!peek(ps, es, "|)&;")){
     6dc:	008c0493          	addi	s1,s8,8
     6e0:	00001b17          	auipc	s6,0x1
     6e4:	ec0b0b13          	addi	s6,s6,-320 # 15a0 <malloc+0x1ac>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     6e8:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     6ec:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     6ee:	a0b1                	j	73a <parseexec+0xa8>
    return parseblock(ps, es);
     6f0:	85d2                	mv	a1,s4
     6f2:	854e                	mv	a0,s3
     6f4:	00000097          	auipc	ra,0x0
     6f8:	1b8080e7          	jalr	440(ra) # 8ac <parseblock>
     6fc:	8aaa                	mv	s5,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     6fe:	8556                	mv	a0,s5
     700:	70a6                	ld	ra,104(sp)
     702:	7406                	ld	s0,96(sp)
     704:	64e6                	ld	s1,88(sp)
     706:	6946                	ld	s2,80(sp)
     708:	69a6                	ld	s3,72(sp)
     70a:	6a06                	ld	s4,64(sp)
     70c:	7ae2                	ld	s5,56(sp)
     70e:	7b42                	ld	s6,48(sp)
     710:	7ba2                	ld	s7,40(sp)
     712:	7c02                	ld	s8,32(sp)
     714:	6ce2                	ld	s9,24(sp)
     716:	6165                	addi	sp,sp,112
     718:	8082                	ret
      panic("syntax");
     71a:	00001517          	auipc	a0,0x1
     71e:	e6e50513          	addi	a0,a0,-402 # 1588 <malloc+0x194>
     722:	00000097          	auipc	ra,0x0
     726:	93e080e7          	jalr	-1730(ra) # 60 <panic>
    ret = parseredirs(ret, ps, es);
     72a:	8652                	mv	a2,s4
     72c:	85ce                	mv	a1,s3
     72e:	8556                	mv	a0,s5
     730:	00000097          	auipc	ra,0x0
     734:	e66080e7          	jalr	-410(ra) # 596 <parseredirs>
     738:	8aaa                	mv	s5,a0
  while(!peek(ps, es, "|)&;")){
     73a:	865a                	mv	a2,s6
     73c:	85d2                	mv	a1,s4
     73e:	854e                	mv	a0,s3
     740:	00000097          	auipc	ra,0x0
     744:	dec080e7          	jalr	-532(ra) # 52c <peek>
     748:	e121                	bnez	a0,788 <parseexec+0xf6>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     74a:	f9040693          	addi	a3,s0,-112
     74e:	f9840613          	addi	a2,s0,-104
     752:	85d2                	mv	a1,s4
     754:	854e                	mv	a0,s3
     756:	00000097          	auipc	ra,0x0
     75a:	c92080e7          	jalr	-878(ra) # 3e8 <gettoken>
     75e:	c50d                	beqz	a0,788 <parseexec+0xf6>
    if(tok != 'a')
     760:	fb951de3          	bne	a0,s9,71a <parseexec+0x88>
    cmd->argv[argc] = q;
     764:	f9843783          	ld	a5,-104(s0)
     768:	e09c                	sd	a5,0(s1)
    cmd->eargv[argc] = eq;
     76a:	f9043783          	ld	a5,-112(s0)
     76e:	e8bc                	sd	a5,80(s1)
    argc++;
     770:	2905                	addiw	s2,s2,1
    if(argc >= MAXARGS)
     772:	04a1                	addi	s1,s1,8
     774:	fb791be3          	bne	s2,s7,72a <parseexec+0x98>
      panic("too many args");
     778:	00001517          	auipc	a0,0x1
     77c:	e1850513          	addi	a0,a0,-488 # 1590 <malloc+0x19c>
     780:	00000097          	auipc	ra,0x0
     784:	8e0080e7          	jalr	-1824(ra) # 60 <panic>
  cmd->argv[argc] = 0;
     788:	090e                	slli	s2,s2,0x3
     78a:	9962                	add	s2,s2,s8
     78c:	00093423          	sd	zero,8(s2)
  cmd->eargv[argc] = 0;
     790:	04093c23          	sd	zero,88(s2)
  return ret;
     794:	b7ad                	j	6fe <parseexec+0x6c>

0000000000000796 <parsepipe>:
{
     796:	7179                	addi	sp,sp,-48
     798:	f406                	sd	ra,40(sp)
     79a:	f022                	sd	s0,32(sp)
     79c:	ec26                	sd	s1,24(sp)
     79e:	e84a                	sd	s2,16(sp)
     7a0:	e44e                	sd	s3,8(sp)
     7a2:	1800                	addi	s0,sp,48
     7a4:	892a                	mv	s2,a0
     7a6:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     7a8:	00000097          	auipc	ra,0x0
     7ac:	eea080e7          	jalr	-278(ra) # 692 <parseexec>
     7b0:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     7b2:	00001617          	auipc	a2,0x1
     7b6:	df660613          	addi	a2,a2,-522 # 15a8 <malloc+0x1b4>
     7ba:	85ce                	mv	a1,s3
     7bc:	854a                	mv	a0,s2
     7be:	00000097          	auipc	ra,0x0
     7c2:	d6e080e7          	jalr	-658(ra) # 52c <peek>
     7c6:	e909                	bnez	a0,7d8 <parsepipe+0x42>
}
     7c8:	8526                	mv	a0,s1
     7ca:	70a2                	ld	ra,40(sp)
     7cc:	7402                	ld	s0,32(sp)
     7ce:	64e2                	ld	s1,24(sp)
     7d0:	6942                	ld	s2,16(sp)
     7d2:	69a2                	ld	s3,8(sp)
     7d4:	6145                	addi	sp,sp,48
     7d6:	8082                	ret
    gettoken(ps, es, 0, 0);
     7d8:	4681                	li	a3,0
     7da:	4601                	li	a2,0
     7dc:	85ce                	mv	a1,s3
     7de:	854a                	mv	a0,s2
     7e0:	00000097          	auipc	ra,0x0
     7e4:	c08080e7          	jalr	-1016(ra) # 3e8 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     7e8:	85ce                	mv	a1,s3
     7ea:	854a                	mv	a0,s2
     7ec:	00000097          	auipc	ra,0x0
     7f0:	faa080e7          	jalr	-86(ra) # 796 <parsepipe>
     7f4:	85aa                	mv	a1,a0
     7f6:	8526                	mv	a0,s1
     7f8:	00000097          	auipc	ra,0x0
     7fc:	b28080e7          	jalr	-1240(ra) # 320 <pipecmd>
     800:	84aa                	mv	s1,a0
  return cmd;
     802:	b7d9                	j	7c8 <parsepipe+0x32>

0000000000000804 <parseline>:
{
     804:	7179                	addi	sp,sp,-48
     806:	f406                	sd	ra,40(sp)
     808:	f022                	sd	s0,32(sp)
     80a:	ec26                	sd	s1,24(sp)
     80c:	e84a                	sd	s2,16(sp)
     80e:	e44e                	sd	s3,8(sp)
     810:	e052                	sd	s4,0(sp)
     812:	1800                	addi	s0,sp,48
     814:	84aa                	mv	s1,a0
     816:	892e                	mv	s2,a1
  cmd = parsepipe(ps, es);
     818:	00000097          	auipc	ra,0x0
     81c:	f7e080e7          	jalr	-130(ra) # 796 <parsepipe>
     820:	89aa                	mv	s3,a0
  while(peek(ps, es, "&")){
     822:	00001a17          	auipc	s4,0x1
     826:	d8ea0a13          	addi	s4,s4,-626 # 15b0 <malloc+0x1bc>
     82a:	8652                	mv	a2,s4
     82c:	85ca                	mv	a1,s2
     82e:	8526                	mv	a0,s1
     830:	00000097          	auipc	ra,0x0
     834:	cfc080e7          	jalr	-772(ra) # 52c <peek>
     838:	c105                	beqz	a0,858 <parseline+0x54>
    gettoken(ps, es, 0, 0);
     83a:	4681                	li	a3,0
     83c:	4601                	li	a2,0
     83e:	85ca                	mv	a1,s2
     840:	8526                	mv	a0,s1
     842:	00000097          	auipc	ra,0x0
     846:	ba6080e7          	jalr	-1114(ra) # 3e8 <gettoken>
    cmd = backcmd(cmd);
     84a:	854e                	mv	a0,s3
     84c:	00000097          	auipc	ra,0x0
     850:	b60080e7          	jalr	-1184(ra) # 3ac <backcmd>
     854:	89aa                	mv	s3,a0
     856:	bfd1                	j	82a <parseline+0x26>
  if(peek(ps, es, ";")){
     858:	00001617          	auipc	a2,0x1
     85c:	d6060613          	addi	a2,a2,-672 # 15b8 <malloc+0x1c4>
     860:	85ca                	mv	a1,s2
     862:	8526                	mv	a0,s1
     864:	00000097          	auipc	ra,0x0
     868:	cc8080e7          	jalr	-824(ra) # 52c <peek>
     86c:	e911                	bnez	a0,880 <parseline+0x7c>
}
     86e:	854e                	mv	a0,s3
     870:	70a2                	ld	ra,40(sp)
     872:	7402                	ld	s0,32(sp)
     874:	64e2                	ld	s1,24(sp)
     876:	6942                	ld	s2,16(sp)
     878:	69a2                	ld	s3,8(sp)
     87a:	6a02                	ld	s4,0(sp)
     87c:	6145                	addi	sp,sp,48
     87e:	8082                	ret
    gettoken(ps, es, 0, 0);
     880:	4681                	li	a3,0
     882:	4601                	li	a2,0
     884:	85ca                	mv	a1,s2
     886:	8526                	mv	a0,s1
     888:	00000097          	auipc	ra,0x0
     88c:	b60080e7          	jalr	-1184(ra) # 3e8 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     890:	85ca                	mv	a1,s2
     892:	8526                	mv	a0,s1
     894:	00000097          	auipc	ra,0x0
     898:	f70080e7          	jalr	-144(ra) # 804 <parseline>
     89c:	85aa                	mv	a1,a0
     89e:	854e                	mv	a0,s3
     8a0:	00000097          	auipc	ra,0x0
     8a4:	ac6080e7          	jalr	-1338(ra) # 366 <listcmd>
     8a8:	89aa                	mv	s3,a0
  return cmd;
     8aa:	b7d1                	j	86e <parseline+0x6a>

00000000000008ac <parseblock>:
{
     8ac:	7179                	addi	sp,sp,-48
     8ae:	f406                	sd	ra,40(sp)
     8b0:	f022                	sd	s0,32(sp)
     8b2:	ec26                	sd	s1,24(sp)
     8b4:	e84a                	sd	s2,16(sp)
     8b6:	e44e                	sd	s3,8(sp)
     8b8:	1800                	addi	s0,sp,48
     8ba:	84aa                	mv	s1,a0
     8bc:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8be:	00001617          	auipc	a2,0x1
     8c2:	cc260613          	addi	a2,a2,-830 # 1580 <malloc+0x18c>
     8c6:	00000097          	auipc	ra,0x0
     8ca:	c66080e7          	jalr	-922(ra) # 52c <peek>
     8ce:	c12d                	beqz	a0,930 <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     8d0:	4681                	li	a3,0
     8d2:	4601                	li	a2,0
     8d4:	85ca                	mv	a1,s2
     8d6:	8526                	mv	a0,s1
     8d8:	00000097          	auipc	ra,0x0
     8dc:	b10080e7          	jalr	-1264(ra) # 3e8 <gettoken>
  cmd = parseline(ps, es);
     8e0:	85ca                	mv	a1,s2
     8e2:	8526                	mv	a0,s1
     8e4:	00000097          	auipc	ra,0x0
     8e8:	f20080e7          	jalr	-224(ra) # 804 <parseline>
     8ec:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     8ee:	00001617          	auipc	a2,0x1
     8f2:	ce260613          	addi	a2,a2,-798 # 15d0 <malloc+0x1dc>
     8f6:	85ca                	mv	a1,s2
     8f8:	8526                	mv	a0,s1
     8fa:	00000097          	auipc	ra,0x0
     8fe:	c32080e7          	jalr	-974(ra) # 52c <peek>
     902:	cd1d                	beqz	a0,940 <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     904:	4681                	li	a3,0
     906:	4601                	li	a2,0
     908:	85ca                	mv	a1,s2
     90a:	8526                	mv	a0,s1
     90c:	00000097          	auipc	ra,0x0
     910:	adc080e7          	jalr	-1316(ra) # 3e8 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     914:	864a                	mv	a2,s2
     916:	85a6                	mv	a1,s1
     918:	854e                	mv	a0,s3
     91a:	00000097          	auipc	ra,0x0
     91e:	c7c080e7          	jalr	-900(ra) # 596 <parseredirs>
}
     922:	70a2                	ld	ra,40(sp)
     924:	7402                	ld	s0,32(sp)
     926:	64e2                	ld	s1,24(sp)
     928:	6942                	ld	s2,16(sp)
     92a:	69a2                	ld	s3,8(sp)
     92c:	6145                	addi	sp,sp,48
     92e:	8082                	ret
    panic("parseblock");
     930:	00001517          	auipc	a0,0x1
     934:	c9050513          	addi	a0,a0,-880 # 15c0 <malloc+0x1cc>
     938:	fffff097          	auipc	ra,0xfffff
     93c:	728080e7          	jalr	1832(ra) # 60 <panic>
    panic("syntax - missing )");
     940:	00001517          	auipc	a0,0x1
     944:	c9850513          	addi	a0,a0,-872 # 15d8 <malloc+0x1e4>
     948:	fffff097          	auipc	ra,0xfffff
     94c:	718080e7          	jalr	1816(ra) # 60 <panic>

0000000000000950 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     950:	1101                	addi	sp,sp,-32
     952:	ec06                	sd	ra,24(sp)
     954:	e822                	sd	s0,16(sp)
     956:	e426                	sd	s1,8(sp)
     958:	1000                	addi	s0,sp,32
     95a:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     95c:	c521                	beqz	a0,9a4 <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     95e:	4118                	lw	a4,0(a0)
     960:	4795                	li	a5,5
     962:	04e7e163          	bltu	a5,a4,9a4 <nulterminate+0x54>
     966:	00056783          	lwu	a5,0(a0)
     96a:	078a                	slli	a5,a5,0x2
     96c:	00001717          	auipc	a4,0x1
     970:	b8c70713          	addi	a4,a4,-1140 # 14f8 <malloc+0x104>
     974:	97ba                	add	a5,a5,a4
     976:	439c                	lw	a5,0(a5)
     978:	97ba                	add	a5,a5,a4
     97a:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     97c:	651c                	ld	a5,8(a0)
     97e:	c39d                	beqz	a5,9a4 <nulterminate+0x54>
     980:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     984:	67b8                	ld	a4,72(a5)
     986:	00070023          	sb	zero,0(a4)
     98a:	07a1                	addi	a5,a5,8
    for(i=0; ecmd->argv[i]; i++)
     98c:	ff87b703          	ld	a4,-8(a5)
     990:	fb75                	bnez	a4,984 <nulterminate+0x34>
     992:	a809                	j	9a4 <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     994:	6508                	ld	a0,8(a0)
     996:	00000097          	auipc	ra,0x0
     99a:	fba080e7          	jalr	-70(ra) # 950 <nulterminate>
    *rcmd->efile = 0;
     99e:	6c9c                	ld	a5,24(s1)
     9a0:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     9a4:	8526                	mv	a0,s1
     9a6:	60e2                	ld	ra,24(sp)
     9a8:	6442                	ld	s0,16(sp)
     9aa:	64a2                	ld	s1,8(sp)
     9ac:	6105                	addi	sp,sp,32
     9ae:	8082                	ret
    nulterminate(pcmd->left);
     9b0:	6508                	ld	a0,8(a0)
     9b2:	00000097          	auipc	ra,0x0
     9b6:	f9e080e7          	jalr	-98(ra) # 950 <nulterminate>
    nulterminate(pcmd->right);
     9ba:	6888                	ld	a0,16(s1)
     9bc:	00000097          	auipc	ra,0x0
     9c0:	f94080e7          	jalr	-108(ra) # 950 <nulterminate>
    break;
     9c4:	b7c5                	j	9a4 <nulterminate+0x54>
    nulterminate(lcmd->left);
     9c6:	6508                	ld	a0,8(a0)
     9c8:	00000097          	auipc	ra,0x0
     9cc:	f88080e7          	jalr	-120(ra) # 950 <nulterminate>
    nulterminate(lcmd->right);
     9d0:	6888                	ld	a0,16(s1)
     9d2:	00000097          	auipc	ra,0x0
     9d6:	f7e080e7          	jalr	-130(ra) # 950 <nulterminate>
    break;
     9da:	b7e9                	j	9a4 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     9dc:	6508                	ld	a0,8(a0)
     9de:	00000097          	auipc	ra,0x0
     9e2:	f72080e7          	jalr	-142(ra) # 950 <nulterminate>
    break;
     9e6:	bf7d                	j	9a4 <nulterminate+0x54>

00000000000009e8 <parsecmd>:
{
     9e8:	7179                	addi	sp,sp,-48
     9ea:	f406                	sd	ra,40(sp)
     9ec:	f022                	sd	s0,32(sp)
     9ee:	ec26                	sd	s1,24(sp)
     9f0:	e84a                	sd	s2,16(sp)
     9f2:	1800                	addi	s0,sp,48
     9f4:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     9f8:	84aa                	mv	s1,a0
     9fa:	00000097          	auipc	ra,0x0
     9fe:	216080e7          	jalr	534(ra) # c10 <strlen>
     a02:	1502                	slli	a0,a0,0x20
     a04:	9101                	srli	a0,a0,0x20
     a06:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     a08:	85a6                	mv	a1,s1
     a0a:	fd840513          	addi	a0,s0,-40
     a0e:	00000097          	auipc	ra,0x0
     a12:	df6080e7          	jalr	-522(ra) # 804 <parseline>
     a16:	892a                	mv	s2,a0
  peek(&s, es, "");
     a18:	00001617          	auipc	a2,0x1
     a1c:	bd860613          	addi	a2,a2,-1064 # 15f0 <malloc+0x1fc>
     a20:	85a6                	mv	a1,s1
     a22:	fd840513          	addi	a0,s0,-40
     a26:	00000097          	auipc	ra,0x0
     a2a:	b06080e7          	jalr	-1274(ra) # 52c <peek>
  if(s != es){
     a2e:	fd843603          	ld	a2,-40(s0)
     a32:	00961e63          	bne	a2,s1,a4e <parsecmd+0x66>
  nulterminate(cmd);
     a36:	854a                	mv	a0,s2
     a38:	00000097          	auipc	ra,0x0
     a3c:	f18080e7          	jalr	-232(ra) # 950 <nulterminate>
}
     a40:	854a                	mv	a0,s2
     a42:	70a2                	ld	ra,40(sp)
     a44:	7402                	ld	s0,32(sp)
     a46:	64e2                	ld	s1,24(sp)
     a48:	6942                	ld	s2,16(sp)
     a4a:	6145                	addi	sp,sp,48
     a4c:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a4e:	00001597          	auipc	a1,0x1
     a52:	baa58593          	addi	a1,a1,-1110 # 15f8 <malloc+0x204>
     a56:	4509                	li	a0,2
     a58:	00001097          	auipc	ra,0x1
     a5c:	8ae080e7          	jalr	-1874(ra) # 1306 <fprintf>
    panic("syntax");
     a60:	00001517          	auipc	a0,0x1
     a64:	b2850513          	addi	a0,a0,-1240 # 1588 <malloc+0x194>
     a68:	fffff097          	auipc	ra,0xfffff
     a6c:	5f8080e7          	jalr	1528(ra) # 60 <panic>

0000000000000a70 <main>:
{
     a70:	711d                	addi	sp,sp,-96
     a72:	ec86                	sd	ra,88(sp)
     a74:	e8a2                	sd	s0,80(sp)
     a76:	e4a6                	sd	s1,72(sp)
     a78:	e0ca                	sd	s2,64(sp)
     a7a:	fc4e                	sd	s3,56(sp)
     a7c:	f852                	sd	s4,48(sp)
     a7e:	f456                	sd	s5,40(sp)
     a80:	f05a                	sd	s6,32(sp)
     a82:	ec5e                	sd	s7,24(sp)
     a84:	1080                	addi	s0,sp,96
     a86:	84ae                	mv	s1,a1
  int lastretval = 0;
     a88:	fa042623          	sw	zero,-84(s0)
  if (argc < 2){
     a8c:	4785                	li	a5,1
     a8e:	04a7d563          	ble	a0,a5,ad8 <main+0x68>
  while((fd = open(argv[1], O_RDWR)) >= 0){
     a92:	4589                	li	a1,2
     a94:	6488                	ld	a0,8(s1)
     a96:	00000097          	auipc	ra,0x0
     a9a:	448080e7          	jalr	1096(ra) # ede <open>
     a9e:	00054963          	bltz	a0,ab0 <main+0x40>
    if(fd >= 3){
     aa2:	4789                	li	a5,2
     aa4:	fea7d7e3          	ble	a0,a5,a92 <main+0x22>
      close(fd);
     aa8:	00000097          	auipc	ra,0x0
     aac:	35a080e7          	jalr	858(ra) # e02 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     ab0:	00001497          	auipc	s1,0x1
     ab4:	bd848493          	addi	s1,s1,-1064 # 1688 <buf.1179>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ab8:	06300913          	li	s2,99
    if(buf[0] == 'r' && buf[1] == 'v' && buf[2] == '\n'){
     abc:	07200993          	li	s3,114
     ac0:	07600a13          	li	s4,118
     ac4:	4aa9                	li	s5,10
      fprintf(2, "retval = %d\n", lastretval);
     ac6:	00001b17          	auipc	s6,0x1
     aca:	b7ab0b13          	addi	s6,s6,-1158 # 1640 <malloc+0x24c>
      if(chdir(buf+3) < 0)
     ace:	00001b97          	auipc	s7,0x1
     ad2:	bbdb8b93          	addi	s7,s7,-1091 # 168b <buf.1179+0x3>
     ad6:	a081                	j	b16 <main+0xa6>
    printf("expected one argument, got argc=%d\n", argc);
     ad8:	85aa                	mv	a1,a0
     ada:	00001517          	auipc	a0,0x1
     ade:	b2e50513          	addi	a0,a0,-1234 # 1608 <malloc+0x214>
     ae2:	00001097          	auipc	ra,0x1
     ae6:	852080e7          	jalr	-1966(ra) # 1334 <printf>
    exit(-1);
     aea:	557d                	li	a0,-1
     aec:	00000097          	auipc	ra,0x0
     af0:	3b2080e7          	jalr	946(ra) # e9e <exit>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     af4:	0014c703          	lbu	a4,1(s1)
     af8:	06400793          	li	a5,100
     afc:	04f70d63          	beq	a4,a5,b56 <main+0xe6>
    if(fork1() == 0)
     b00:	fffff097          	auipc	ra,0xfffff
     b04:	586080e7          	jalr	1414(ra) # 86 <fork1>
     b08:	c959                	beqz	a0,b9e <main+0x12e>
    wait(&lastretval);
     b0a:	fac40513          	addi	a0,s0,-84
     b0e:	00000097          	auipc	ra,0x0
     b12:	398080e7          	jalr	920(ra) # ea6 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     b16:	06400593          	li	a1,100
     b1a:	8526                	mv	a0,s1
     b1c:	fffff097          	auipc	ra,0xfffff
     b20:	4e4080e7          	jalr	1252(ra) # 0 <getcmd>
     b24:	08054963          	bltz	a0,bb6 <main+0x146>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b28:	0004c783          	lbu	a5,0(s1)
     b2c:	fd2784e3          	beq	a5,s2,af4 <main+0x84>
    if(buf[0] == 'r' && buf[1] == 'v' && buf[2] == '\n'){
     b30:	fd3798e3          	bne	a5,s3,b00 <main+0x90>
     b34:	0014c783          	lbu	a5,1(s1)
     b38:	fd4794e3          	bne	a5,s4,b00 <main+0x90>
     b3c:	0024c783          	lbu	a5,2(s1)
     b40:	fd5790e3          	bne	a5,s5,b00 <main+0x90>
      fprintf(2, "retval = %d\n", lastretval);
     b44:	fac42603          	lw	a2,-84(s0)
     b48:	85da                	mv	a1,s6
     b4a:	4509                	li	a0,2
     b4c:	00000097          	auipc	ra,0x0
     b50:	7ba080e7          	jalr	1978(ra) # 1306 <fprintf>
      continue;
     b54:	b7c9                	j	b16 <main+0xa6>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b56:	0024c703          	lbu	a4,2(s1)
     b5a:	02000793          	li	a5,32
     b5e:	faf711e3          	bne	a4,a5,b00 <main+0x90>
      buf[strlen(buf)-1] = 0;  // chop \n
     b62:	8526                	mv	a0,s1
     b64:	00000097          	auipc	ra,0x0
     b68:	0ac080e7          	jalr	172(ra) # c10 <strlen>
     b6c:	fff5079b          	addiw	a5,a0,-1
     b70:	1782                	slli	a5,a5,0x20
     b72:	9381                	srli	a5,a5,0x20
     b74:	97a6                	add	a5,a5,s1
     b76:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     b7a:	855e                	mv	a0,s7
     b7c:	00000097          	auipc	ra,0x0
     b80:	392080e7          	jalr	914(ra) # f0e <chdir>
     b84:	f80559e3          	bgez	a0,b16 <main+0xa6>
        fprintf(2, "cannot cd %s\n", buf+3);
     b88:	865e                	mv	a2,s7
     b8a:	00001597          	auipc	a1,0x1
     b8e:	aa658593          	addi	a1,a1,-1370 # 1630 <malloc+0x23c>
     b92:	4509                	li	a0,2
     b94:	00000097          	auipc	ra,0x0
     b98:	772080e7          	jalr	1906(ra) # 1306 <fprintf>
     b9c:	bfad                	j	b16 <main+0xa6>
      runcmd(parsecmd(buf));
     b9e:	00001517          	auipc	a0,0x1
     ba2:	aea50513          	addi	a0,a0,-1302 # 1688 <buf.1179>
     ba6:	00000097          	auipc	ra,0x0
     baa:	e42080e7          	jalr	-446(ra) # 9e8 <parsecmd>
     bae:	fffff097          	auipc	ra,0xfffff
     bb2:	506080e7          	jalr	1286(ra) # b4 <runcmd>
  exit(0);
     bb6:	4501                	li	a0,0
     bb8:	00000097          	auipc	ra,0x0
     bbc:	2e6080e7          	jalr	742(ra) # e9e <exit>

0000000000000bc0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     bc0:	1141                	addi	sp,sp,-16
     bc2:	e422                	sd	s0,8(sp)
     bc4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bc6:	87aa                	mv	a5,a0
     bc8:	0585                	addi	a1,a1,1
     bca:	0785                	addi	a5,a5,1
     bcc:	fff5c703          	lbu	a4,-1(a1)
     bd0:	fee78fa3          	sb	a4,-1(a5)
     bd4:	fb75                	bnez	a4,bc8 <strcpy+0x8>
    ;
  return os;
}
     bd6:	6422                	ld	s0,8(sp)
     bd8:	0141                	addi	sp,sp,16
     bda:	8082                	ret

0000000000000bdc <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bdc:	1141                	addi	sp,sp,-16
     bde:	e422                	sd	s0,8(sp)
     be0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     be2:	00054783          	lbu	a5,0(a0)
     be6:	cf91                	beqz	a5,c02 <strcmp+0x26>
     be8:	0005c703          	lbu	a4,0(a1)
     bec:	00f71b63          	bne	a4,a5,c02 <strcmp+0x26>
    p++, q++;
     bf0:	0505                	addi	a0,a0,1
     bf2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     bf4:	00054783          	lbu	a5,0(a0)
     bf8:	c789                	beqz	a5,c02 <strcmp+0x26>
     bfa:	0005c703          	lbu	a4,0(a1)
     bfe:	fef709e3          	beq	a4,a5,bf0 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
     c02:	0005c503          	lbu	a0,0(a1)
}
     c06:	40a7853b          	subw	a0,a5,a0
     c0a:	6422                	ld	s0,8(sp)
     c0c:	0141                	addi	sp,sp,16
     c0e:	8082                	ret

0000000000000c10 <strlen>:

uint
strlen(const char *s)
{
     c10:	1141                	addi	sp,sp,-16
     c12:	e422                	sd	s0,8(sp)
     c14:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c16:	00054783          	lbu	a5,0(a0)
     c1a:	cf91                	beqz	a5,c36 <strlen+0x26>
     c1c:	0505                	addi	a0,a0,1
     c1e:	87aa                	mv	a5,a0
     c20:	4685                	li	a3,1
     c22:	9e89                	subw	a3,a3,a0
    ;
     c24:	00f6853b          	addw	a0,a3,a5
     c28:	0785                	addi	a5,a5,1
  for(n = 0; s[n]; n++)
     c2a:	fff7c703          	lbu	a4,-1(a5)
     c2e:	fb7d                	bnez	a4,c24 <strlen+0x14>
  return n;
}
     c30:	6422                	ld	s0,8(sp)
     c32:	0141                	addi	sp,sp,16
     c34:	8082                	ret
  for(n = 0; s[n]; n++)
     c36:	4501                	li	a0,0
     c38:	bfe5                	j	c30 <strlen+0x20>

0000000000000c3a <memset>:

void*
memset(void *dst, int c, uint n)
{
     c3a:	1141                	addi	sp,sp,-16
     c3c:	e422                	sd	s0,8(sp)
     c3e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c40:	ce09                	beqz	a2,c5a <memset+0x20>
     c42:	87aa                	mv	a5,a0
     c44:	fff6071b          	addiw	a4,a2,-1
     c48:	1702                	slli	a4,a4,0x20
     c4a:	9301                	srli	a4,a4,0x20
     c4c:	0705                	addi	a4,a4,1
     c4e:	972a                	add	a4,a4,a0
    cdst[i] = c;
     c50:	00b78023          	sb	a1,0(a5)
     c54:	0785                	addi	a5,a5,1
  for(i = 0; i < n; i++){
     c56:	fee79de3          	bne	a5,a4,c50 <memset+0x16>
  }
  return dst;
}
     c5a:	6422                	ld	s0,8(sp)
     c5c:	0141                	addi	sp,sp,16
     c5e:	8082                	ret

0000000000000c60 <strchr>:

char*
strchr(const char *s, char c)
{
     c60:	1141                	addi	sp,sp,-16
     c62:	e422                	sd	s0,8(sp)
     c64:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c66:	00054783          	lbu	a5,0(a0)
     c6a:	cf91                	beqz	a5,c86 <strchr+0x26>
    if(*s == c)
     c6c:	00f58a63          	beq	a1,a5,c80 <strchr+0x20>
  for(; *s; s++)
     c70:	0505                	addi	a0,a0,1
     c72:	00054783          	lbu	a5,0(a0)
     c76:	c781                	beqz	a5,c7e <strchr+0x1e>
    if(*s == c)
     c78:	feb79ce3          	bne	a5,a1,c70 <strchr+0x10>
     c7c:	a011                	j	c80 <strchr+0x20>
      return (char*)s;
  return 0;
     c7e:	4501                	li	a0,0
}
     c80:	6422                	ld	s0,8(sp)
     c82:	0141                	addi	sp,sp,16
     c84:	8082                	ret
  return 0;
     c86:	4501                	li	a0,0
     c88:	bfe5                	j	c80 <strchr+0x20>

0000000000000c8a <gets>:

char*
gets(char *buf, int max)
{
     c8a:	711d                	addi	sp,sp,-96
     c8c:	ec86                	sd	ra,88(sp)
     c8e:	e8a2                	sd	s0,80(sp)
     c90:	e4a6                	sd	s1,72(sp)
     c92:	e0ca                	sd	s2,64(sp)
     c94:	fc4e                	sd	s3,56(sp)
     c96:	f852                	sd	s4,48(sp)
     c98:	f456                	sd	s5,40(sp)
     c9a:	f05a                	sd	s6,32(sp)
     c9c:	ec5e                	sd	s7,24(sp)
     c9e:	1080                	addi	s0,sp,96
     ca0:	8baa                	mv	s7,a0
     ca2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ca4:	892a                	mv	s2,a0
     ca6:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     ca8:	4aa9                	li	s5,10
     caa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     cac:	0019849b          	addiw	s1,s3,1
     cb0:	0344d863          	ble	s4,s1,ce0 <gets+0x56>
    cc = read(0, &c, 1);
     cb4:	4605                	li	a2,1
     cb6:	faf40593          	addi	a1,s0,-81
     cba:	4501                	li	a0,0
     cbc:	00000097          	auipc	ra,0x0
     cc0:	1fa080e7          	jalr	506(ra) # eb6 <read>
    if(cc < 1)
     cc4:	00a05e63          	blez	a0,ce0 <gets+0x56>
    buf[i++] = c;
     cc8:	faf44783          	lbu	a5,-81(s0)
     ccc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cd0:	01578763          	beq	a5,s5,cde <gets+0x54>
     cd4:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
     cd6:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
     cd8:	fd679ae3          	bne	a5,s6,cac <gets+0x22>
     cdc:	a011                	j	ce0 <gets+0x56>
  for(i=0; i+1 < max; ){
     cde:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     ce0:	99de                	add	s3,s3,s7
     ce2:	00098023          	sb	zero,0(s3)
  return buf;
}
     ce6:	855e                	mv	a0,s7
     ce8:	60e6                	ld	ra,88(sp)
     cea:	6446                	ld	s0,80(sp)
     cec:	64a6                	ld	s1,72(sp)
     cee:	6906                	ld	s2,64(sp)
     cf0:	79e2                	ld	s3,56(sp)
     cf2:	7a42                	ld	s4,48(sp)
     cf4:	7aa2                	ld	s5,40(sp)
     cf6:	7b02                	ld	s6,32(sp)
     cf8:	6be2                	ld	s7,24(sp)
     cfa:	6125                	addi	sp,sp,96
     cfc:	8082                	ret

0000000000000cfe <atoi>:
  return r;
}

int
atoi(const char *s)
{
     cfe:	1141                	addi	sp,sp,-16
     d00:	e422                	sd	s0,8(sp)
     d02:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d04:	00054683          	lbu	a3,0(a0)
     d08:	fd06879b          	addiw	a5,a3,-48
     d0c:	0ff7f793          	andi	a5,a5,255
     d10:	4725                	li	a4,9
     d12:	02f76963          	bltu	a4,a5,d44 <atoi+0x46>
     d16:	862a                	mv	a2,a0
  n = 0;
     d18:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d1a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d1c:	0605                	addi	a2,a2,1
     d1e:	0025179b          	slliw	a5,a0,0x2
     d22:	9fa9                	addw	a5,a5,a0
     d24:	0017979b          	slliw	a5,a5,0x1
     d28:	9fb5                	addw	a5,a5,a3
     d2a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d2e:	00064683          	lbu	a3,0(a2)
     d32:	fd06871b          	addiw	a4,a3,-48
     d36:	0ff77713          	andi	a4,a4,255
     d3a:	fee5f1e3          	bleu	a4,a1,d1c <atoi+0x1e>
  return n;
}
     d3e:	6422                	ld	s0,8(sp)
     d40:	0141                	addi	sp,sp,16
     d42:	8082                	ret
  n = 0;
     d44:	4501                	li	a0,0
     d46:	bfe5                	j	d3e <atoi+0x40>

0000000000000d48 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d48:	1141                	addi	sp,sp,-16
     d4a:	e422                	sd	s0,8(sp)
     d4c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d4e:	02b57663          	bleu	a1,a0,d7a <memmove+0x32>
    while(n-- > 0)
     d52:	02c05163          	blez	a2,d74 <memmove+0x2c>
     d56:	fff6079b          	addiw	a5,a2,-1
     d5a:	1782                	slli	a5,a5,0x20
     d5c:	9381                	srli	a5,a5,0x20
     d5e:	0785                	addi	a5,a5,1
     d60:	97aa                	add	a5,a5,a0
  dst = vdst;
     d62:	872a                	mv	a4,a0
      *dst++ = *src++;
     d64:	0585                	addi	a1,a1,1
     d66:	0705                	addi	a4,a4,1
     d68:	fff5c683          	lbu	a3,-1(a1)
     d6c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     d70:	fee79ae3          	bne	a5,a4,d64 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     d74:	6422                	ld	s0,8(sp)
     d76:	0141                	addi	sp,sp,16
     d78:	8082                	ret
    dst += n;
     d7a:	00c50733          	add	a4,a0,a2
    src += n;
     d7e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     d80:	fec05ae3          	blez	a2,d74 <memmove+0x2c>
     d84:	fff6079b          	addiw	a5,a2,-1
     d88:	1782                	slli	a5,a5,0x20
     d8a:	9381                	srli	a5,a5,0x20
     d8c:	fff7c793          	not	a5,a5
     d90:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     d92:	15fd                	addi	a1,a1,-1
     d94:	177d                	addi	a4,a4,-1
     d96:	0005c683          	lbu	a3,0(a1)
     d9a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     d9e:	fef71ae3          	bne	a4,a5,d92 <memmove+0x4a>
     da2:	bfc9                	j	d74 <memmove+0x2c>

0000000000000da4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     da4:	1141                	addi	sp,sp,-16
     da6:	e422                	sd	s0,8(sp)
     da8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     daa:	ce15                	beqz	a2,de6 <memcmp+0x42>
     dac:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
     db0:	00054783          	lbu	a5,0(a0)
     db4:	0005c703          	lbu	a4,0(a1)
     db8:	02e79063          	bne	a5,a4,dd8 <memcmp+0x34>
     dbc:	1682                	slli	a3,a3,0x20
     dbe:	9281                	srli	a3,a3,0x20
     dc0:	0685                	addi	a3,a3,1
     dc2:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
     dc4:	0505                	addi	a0,a0,1
    p2++;
     dc6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     dc8:	00d50d63          	beq	a0,a3,de2 <memcmp+0x3e>
    if (*p1 != *p2) {
     dcc:	00054783          	lbu	a5,0(a0)
     dd0:	0005c703          	lbu	a4,0(a1)
     dd4:	fee788e3          	beq	a5,a4,dc4 <memcmp+0x20>
      return *p1 - *p2;
     dd8:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
     ddc:	6422                	ld	s0,8(sp)
     dde:	0141                	addi	sp,sp,16
     de0:	8082                	ret
  return 0;
     de2:	4501                	li	a0,0
     de4:	bfe5                	j	ddc <memcmp+0x38>
     de6:	4501                	li	a0,0
     de8:	bfd5                	j	ddc <memcmp+0x38>

0000000000000dea <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     dea:	1141                	addi	sp,sp,-16
     dec:	e406                	sd	ra,8(sp)
     dee:	e022                	sd	s0,0(sp)
     df0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     df2:	00000097          	auipc	ra,0x0
     df6:	f56080e7          	jalr	-170(ra) # d48 <memmove>
}
     dfa:	60a2                	ld	ra,8(sp)
     dfc:	6402                	ld	s0,0(sp)
     dfe:	0141                	addi	sp,sp,16
     e00:	8082                	ret

0000000000000e02 <close>:

int close(int fd){
     e02:	1101                	addi	sp,sp,-32
     e04:	ec06                	sd	ra,24(sp)
     e06:	e822                	sd	s0,16(sp)
     e08:	e426                	sd	s1,8(sp)
     e0a:	1000                	addi	s0,sp,32
     e0c:	84aa                	mv	s1,a0
  fflush(fd);
     e0e:	00000097          	auipc	ra,0x0
     e12:	2da080e7          	jalr	730(ra) # 10e8 <fflush>
  char* buf = get_putc_buf(fd);
     e16:	8526                	mv	a0,s1
     e18:	00000097          	auipc	ra,0x0
     e1c:	14e080e7          	jalr	334(ra) # f66 <get_putc_buf>
  if(buf){
     e20:	cd11                	beqz	a0,e3c <close+0x3a>
    free(buf);
     e22:	00000097          	auipc	ra,0x0
     e26:	548080e7          	jalr	1352(ra) # 136a <free>
    putc_buf[fd] = 0;
     e2a:	00349713          	slli	a4,s1,0x3
     e2e:	00001797          	auipc	a5,0x1
     e32:	8c278793          	addi	a5,a5,-1854 # 16f0 <putc_buf>
     e36:	97ba                	add	a5,a5,a4
     e38:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
     e3c:	8526                	mv	a0,s1
     e3e:	00000097          	auipc	ra,0x0
     e42:	088080e7          	jalr	136(ra) # ec6 <sclose>
}
     e46:	60e2                	ld	ra,24(sp)
     e48:	6442                	ld	s0,16(sp)
     e4a:	64a2                	ld	s1,8(sp)
     e4c:	6105                	addi	sp,sp,32
     e4e:	8082                	ret

0000000000000e50 <stat>:
{
     e50:	1101                	addi	sp,sp,-32
     e52:	ec06                	sd	ra,24(sp)
     e54:	e822                	sd	s0,16(sp)
     e56:	e426                	sd	s1,8(sp)
     e58:	e04a                	sd	s2,0(sp)
     e5a:	1000                	addi	s0,sp,32
     e5c:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
     e5e:	4581                	li	a1,0
     e60:	00000097          	auipc	ra,0x0
     e64:	07e080e7          	jalr	126(ra) # ede <open>
  if(fd < 0)
     e68:	02054563          	bltz	a0,e92 <stat+0x42>
     e6c:	84aa                	mv	s1,a0
  r = fstat(fd, st);
     e6e:	85ca                	mv	a1,s2
     e70:	00000097          	auipc	ra,0x0
     e74:	086080e7          	jalr	134(ra) # ef6 <fstat>
     e78:	892a                	mv	s2,a0
  close(fd);
     e7a:	8526                	mv	a0,s1
     e7c:	00000097          	auipc	ra,0x0
     e80:	f86080e7          	jalr	-122(ra) # e02 <close>
}
     e84:	854a                	mv	a0,s2
     e86:	60e2                	ld	ra,24(sp)
     e88:	6442                	ld	s0,16(sp)
     e8a:	64a2                	ld	s1,8(sp)
     e8c:	6902                	ld	s2,0(sp)
     e8e:	6105                	addi	sp,sp,32
     e90:	8082                	ret
    return -1;
     e92:	597d                	li	s2,-1
     e94:	bfc5                	j	e84 <stat+0x34>

0000000000000e96 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e96:	4885                	li	a7,1
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <exit>:
.global exit
exit:
 li a7, SYS_exit
     e9e:	4889                	li	a7,2
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <wait>:
.global wait
wait:
 li a7, SYS_wait
     ea6:	488d                	li	a7,3
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     eae:	4891                	li	a7,4
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <read>:
.global read
read:
 li a7, SYS_read
     eb6:	4895                	li	a7,5
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <write>:
.global write
write:
 li a7, SYS_write
     ebe:	48c1                	li	a7,16
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
     ec6:	48d5                	li	a7,21
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <kill>:
.global kill
kill:
 li a7, SYS_kill
     ece:	4899                	li	a7,6
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <exec>:
.global exec
exec:
 li a7, SYS_exec
     ed6:	489d                	li	a7,7
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <open>:
.global open
open:
 li a7, SYS_open
     ede:	48bd                	li	a7,15
 ecall
     ee0:	00000073          	ecall
 ret
     ee4:	8082                	ret

0000000000000ee6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ee6:	48c5                	li	a7,17
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     eee:	48c9                	li	a7,18
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ef6:	48a1                	li	a7,8
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <link>:
.global link
link:
 li a7, SYS_link
     efe:	48cd                	li	a7,19
 ecall
     f00:	00000073          	ecall
 ret
     f04:	8082                	ret

0000000000000f06 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f06:	48d1                	li	a7,20
 ecall
     f08:	00000073          	ecall
 ret
     f0c:	8082                	ret

0000000000000f0e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f0e:	48a5                	li	a7,9
 ecall
     f10:	00000073          	ecall
 ret
     f14:	8082                	ret

0000000000000f16 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f16:	48a9                	li	a7,10
 ecall
     f18:	00000073          	ecall
 ret
     f1c:	8082                	ret

0000000000000f1e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f1e:	48ad                	li	a7,11
 ecall
     f20:	00000073          	ecall
 ret
     f24:	8082                	ret

0000000000000f26 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f26:	48b1                	li	a7,12
 ecall
     f28:	00000073          	ecall
 ret
     f2c:	8082                	ret

0000000000000f2e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f2e:	48b5                	li	a7,13
 ecall
     f30:	00000073          	ecall
 ret
     f34:	8082                	ret

0000000000000f36 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f36:	48b9                	li	a7,14
 ecall
     f38:	00000073          	ecall
 ret
     f3c:	8082                	ret

0000000000000f3e <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
     f3e:	48d9                	li	a7,22
 ecall
     f40:	00000073          	ecall
 ret
     f44:	8082                	ret

0000000000000f46 <nice>:
.global nice
nice:
 li a7, SYS_nice
     f46:	48dd                	li	a7,23
 ecall
     f48:	00000073          	ecall
 ret
     f4c:	8082                	ret

0000000000000f4e <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
     f4e:	48e1                	li	a7,24
 ecall
     f50:	00000073          	ecall
 ret
     f54:	8082                	ret

0000000000000f56 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
     f56:	48e5                	li	a7,25
 ecall
     f58:	00000073          	ecall
 ret
     f5c:	8082                	ret

0000000000000f5e <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
     f5e:	48e9                	li	a7,26
 ecall
     f60:	00000073          	ecall
 ret
     f64:	8082                	ret

0000000000000f66 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
     f66:	1101                	addi	sp,sp,-32
     f68:	ec06                	sd	ra,24(sp)
     f6a:	e822                	sd	s0,16(sp)
     f6c:	e426                	sd	s1,8(sp)
     f6e:	1000                	addi	s0,sp,32
     f70:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
     f72:	00351693          	slli	a3,a0,0x3
     f76:	00000797          	auipc	a5,0x0
     f7a:	77a78793          	addi	a5,a5,1914 # 16f0 <putc_buf>
     f7e:	97b6                	add	a5,a5,a3
     f80:	6388                	ld	a0,0(a5)
  if(buf) {
     f82:	c511                	beqz	a0,f8e <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
     f84:	60e2                	ld	ra,24(sp)
     f86:	6442                	ld	s0,16(sp)
     f88:	64a2                	ld	s1,8(sp)
     f8a:	6105                	addi	sp,sp,32
     f8c:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
     f8e:	6505                	lui	a0,0x1
     f90:	00000097          	auipc	ra,0x0
     f94:	464080e7          	jalr	1124(ra) # 13f4 <malloc>
  putc_buf[fd] = buf;
     f98:	00000797          	auipc	a5,0x0
     f9c:	75878793          	addi	a5,a5,1880 # 16f0 <putc_buf>
     fa0:	00349713          	slli	a4,s1,0x3
     fa4:	973e                	add	a4,a4,a5
     fa6:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
     fa8:	00249713          	slli	a4,s1,0x2
     fac:	973e                	add	a4,a4,a5
     fae:	32072023          	sw	zero,800(a4)
  return buf;
     fb2:	bfc9                	j	f84 <get_putc_buf+0x1e>

0000000000000fb4 <putc>:

static void
putc(int fd, char c)
{
     fb4:	1101                	addi	sp,sp,-32
     fb6:	ec06                	sd	ra,24(sp)
     fb8:	e822                	sd	s0,16(sp)
     fba:	e426                	sd	s1,8(sp)
     fbc:	e04a                	sd	s2,0(sp)
     fbe:	1000                	addi	s0,sp,32
     fc0:	84aa                	mv	s1,a0
     fc2:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
     fc4:	00000097          	auipc	ra,0x0
     fc8:	fa2080e7          	jalr	-94(ra) # f66 <get_putc_buf>
  buf[putc_index[fd]++] = c;
     fcc:	00249793          	slli	a5,s1,0x2
     fd0:	00000717          	auipc	a4,0x0
     fd4:	72070713          	addi	a4,a4,1824 # 16f0 <putc_buf>
     fd8:	973e                	add	a4,a4,a5
     fda:	32072783          	lw	a5,800(a4)
     fde:	0017869b          	addiw	a3,a5,1
     fe2:	32d72023          	sw	a3,800(a4)
     fe6:	97aa                	add	a5,a5,a0
     fe8:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
     fec:	47a9                	li	a5,10
     fee:	02f90463          	beq	s2,a5,1016 <putc+0x62>
     ff2:	00249713          	slli	a4,s1,0x2
     ff6:	00000797          	auipc	a5,0x0
     ffa:	6fa78793          	addi	a5,a5,1786 # 16f0 <putc_buf>
     ffe:	97ba                	add	a5,a5,a4
    1000:	3207a703          	lw	a4,800(a5)
    1004:	6785                	lui	a5,0x1
    1006:	00f70863          	beq	a4,a5,1016 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
    100a:	60e2                	ld	ra,24(sp)
    100c:	6442                	ld	s0,16(sp)
    100e:	64a2                	ld	s1,8(sp)
    1010:	6902                	ld	s2,0(sp)
    1012:	6105                	addi	sp,sp,32
    1014:	8082                	ret
    write(fd, buf, putc_index[fd]);
    1016:	00249793          	slli	a5,s1,0x2
    101a:	00000917          	auipc	s2,0x0
    101e:	6d690913          	addi	s2,s2,1750 # 16f0 <putc_buf>
    1022:	993e                	add	s2,s2,a5
    1024:	32092603          	lw	a2,800(s2)
    1028:	85aa                	mv	a1,a0
    102a:	8526                	mv	a0,s1
    102c:	00000097          	auipc	ra,0x0
    1030:	e92080e7          	jalr	-366(ra) # ebe <write>
    putc_index[fd] = 0;
    1034:	32092023          	sw	zero,800(s2)
}
    1038:	bfc9                	j	100a <putc+0x56>

000000000000103a <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
    103a:	7139                	addi	sp,sp,-64
    103c:	fc06                	sd	ra,56(sp)
    103e:	f822                	sd	s0,48(sp)
    1040:	f426                	sd	s1,40(sp)
    1042:	f04a                	sd	s2,32(sp)
    1044:	ec4e                	sd	s3,24(sp)
    1046:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    1048:	c299                	beqz	a3,104e <printint+0x14>
    104a:	0005cd63          	bltz	a1,1064 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    104e:	2581                	sext.w	a1,a1
  neg = 0;
    1050:	4301                	li	t1,0
    1052:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
    1056:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
    1058:	2601                	sext.w	a2,a2
    105a:	00000897          	auipc	a7,0x0
    105e:	5f688893          	addi	a7,a7,1526 # 1650 <digits>
    1062:	a801                	j	1072 <printint+0x38>
    x = -xx;
    1064:	40b005bb          	negw	a1,a1
    1068:	2581                	sext.w	a1,a1
    neg = 1;
    106a:	4305                	li	t1,1
    x = -xx;
    106c:	b7dd                	j	1052 <printint+0x18>
  }while((x /= base) != 0);
    106e:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
    1070:	8836                	mv	a6,a3
    1072:	0018069b          	addiw	a3,a6,1
    1076:	02c5f7bb          	remuw	a5,a1,a2
    107a:	1782                	slli	a5,a5,0x20
    107c:	9381                	srli	a5,a5,0x20
    107e:	97c6                	add	a5,a5,a7
    1080:	0007c783          	lbu	a5,0(a5) # 1000 <putc+0x4c>
    1084:	00f70023          	sb	a5,0(a4)
    1088:	0705                	addi	a4,a4,1
  }while((x /= base) != 0);
    108a:	02c5d7bb          	divuw	a5,a1,a2
    108e:	fec5f0e3          	bleu	a2,a1,106e <printint+0x34>
  if(neg)
    1092:	00030b63          	beqz	t1,10a8 <printint+0x6e>
    buf[i++] = '-';
    1096:	fd040793          	addi	a5,s0,-48
    109a:	96be                	add	a3,a3,a5
    109c:	02d00793          	li	a5,45
    10a0:	fef68823          	sb	a5,-16(a3)
    10a4:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
    10a8:	02d05963          	blez	a3,10da <printint+0xa0>
    10ac:	89aa                	mv	s3,a0
    10ae:	fc040793          	addi	a5,s0,-64
    10b2:	00d784b3          	add	s1,a5,a3
    10b6:	fff78913          	addi	s2,a5,-1
    10ba:	9936                	add	s2,s2,a3
    10bc:	36fd                	addiw	a3,a3,-1
    10be:	1682                	slli	a3,a3,0x20
    10c0:	9281                	srli	a3,a3,0x20
    10c2:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
    10c6:	fff4c583          	lbu	a1,-1(s1)
    10ca:	854e                	mv	a0,s3
    10cc:	00000097          	auipc	ra,0x0
    10d0:	ee8080e7          	jalr	-280(ra) # fb4 <putc>
    10d4:	14fd                	addi	s1,s1,-1
  while(--i >= 0)
    10d6:	ff2498e3          	bne	s1,s2,10c6 <printint+0x8c>
}
    10da:	70e2                	ld	ra,56(sp)
    10dc:	7442                	ld	s0,48(sp)
    10de:	74a2                	ld	s1,40(sp)
    10e0:	7902                	ld	s2,32(sp)
    10e2:	69e2                	ld	s3,24(sp)
    10e4:	6121                	addi	sp,sp,64
    10e6:	8082                	ret

00000000000010e8 <fflush>:
void fflush(int fd){
    10e8:	1101                	addi	sp,sp,-32
    10ea:	ec06                	sd	ra,24(sp)
    10ec:	e822                	sd	s0,16(sp)
    10ee:	e426                	sd	s1,8(sp)
    10f0:	e04a                	sd	s2,0(sp)
    10f2:	1000                	addi	s0,sp,32
    10f4:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
    10f6:	00000097          	auipc	ra,0x0
    10fa:	e70080e7          	jalr	-400(ra) # f66 <get_putc_buf>
  write(fd, buf, putc_index[fd]);
    10fe:	00291793          	slli	a5,s2,0x2
    1102:	00000497          	auipc	s1,0x0
    1106:	5ee48493          	addi	s1,s1,1518 # 16f0 <putc_buf>
    110a:	94be                	add	s1,s1,a5
    110c:	3204a603          	lw	a2,800(s1)
    1110:	85aa                	mv	a1,a0
    1112:	854a                	mv	a0,s2
    1114:	00000097          	auipc	ra,0x0
    1118:	daa080e7          	jalr	-598(ra) # ebe <write>
  putc_index[fd] = 0;
    111c:	3204a023          	sw	zero,800(s1)
}
    1120:	60e2                	ld	ra,24(sp)
    1122:	6442                	ld	s0,16(sp)
    1124:	64a2                	ld	s1,8(sp)
    1126:	6902                	ld	s2,0(sp)
    1128:	6105                	addi	sp,sp,32
    112a:	8082                	ret

000000000000112c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    112c:	7119                	addi	sp,sp,-128
    112e:	fc86                	sd	ra,120(sp)
    1130:	f8a2                	sd	s0,112(sp)
    1132:	f4a6                	sd	s1,104(sp)
    1134:	f0ca                	sd	s2,96(sp)
    1136:	ecce                	sd	s3,88(sp)
    1138:	e8d2                	sd	s4,80(sp)
    113a:	e4d6                	sd	s5,72(sp)
    113c:	e0da                	sd	s6,64(sp)
    113e:	fc5e                	sd	s7,56(sp)
    1140:	f862                	sd	s8,48(sp)
    1142:	f466                	sd	s9,40(sp)
    1144:	f06a                	sd	s10,32(sp)
    1146:	ec6e                	sd	s11,24(sp)
    1148:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    114a:	0005c483          	lbu	s1,0(a1)
    114e:	18048d63          	beqz	s1,12e8 <vprintf+0x1bc>
    1152:	8aaa                	mv	s5,a0
    1154:	8b32                	mv	s6,a2
    1156:	00158913          	addi	s2,a1,1
  state = 0;
    115a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    115c:	02500a13          	li	s4,37
      if(c == 'd'){
    1160:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1164:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1168:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    116c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1170:	00000b97          	auipc	s7,0x0
    1174:	4e0b8b93          	addi	s7,s7,1248 # 1650 <digits>
    1178:	a839                	j	1196 <vprintf+0x6a>
        putc(fd, c);
    117a:	85a6                	mv	a1,s1
    117c:	8556                	mv	a0,s5
    117e:	00000097          	auipc	ra,0x0
    1182:	e36080e7          	jalr	-458(ra) # fb4 <putc>
    1186:	a019                	j	118c <vprintf+0x60>
    } else if(state == '%'){
    1188:	01498f63          	beq	s3,s4,11a6 <vprintf+0x7a>
    118c:	0905                	addi	s2,s2,1
  for(i = 0; fmt[i]; i++){
    118e:	fff94483          	lbu	s1,-1(s2)
    1192:	14048b63          	beqz	s1,12e8 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
    1196:	0004879b          	sext.w	a5,s1
    if(state == 0){
    119a:	fe0997e3          	bnez	s3,1188 <vprintf+0x5c>
      if(c == '%'){
    119e:	fd479ee3          	bne	a5,s4,117a <vprintf+0x4e>
        state = '%';
    11a2:	89be                	mv	s3,a5
    11a4:	b7e5                	j	118c <vprintf+0x60>
      if(c == 'd'){
    11a6:	05878063          	beq	a5,s8,11e6 <vprintf+0xba>
      } else if(c == 'l') {
    11aa:	05978c63          	beq	a5,s9,1202 <vprintf+0xd6>
      } else if(c == 'x') {
    11ae:	07a78863          	beq	a5,s10,121e <vprintf+0xf2>
      } else if(c == 'p') {
    11b2:	09b78463          	beq	a5,s11,123a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    11b6:	07300713          	li	a4,115
    11ba:	0ce78563          	beq	a5,a4,1284 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    11be:	06300713          	li	a4,99
    11c2:	0ee78c63          	beq	a5,a4,12ba <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    11c6:	11478663          	beq	a5,s4,12d2 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    11ca:	85d2                	mv	a1,s4
    11cc:	8556                	mv	a0,s5
    11ce:	00000097          	auipc	ra,0x0
    11d2:	de6080e7          	jalr	-538(ra) # fb4 <putc>
        putc(fd, c);
    11d6:	85a6                	mv	a1,s1
    11d8:	8556                	mv	a0,s5
    11da:	00000097          	auipc	ra,0x0
    11de:	dda080e7          	jalr	-550(ra) # fb4 <putc>
      }
      state = 0;
    11e2:	4981                	li	s3,0
    11e4:	b765                	j	118c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    11e6:	008b0493          	addi	s1,s6,8
    11ea:	4685                	li	a3,1
    11ec:	4629                	li	a2,10
    11ee:	000b2583          	lw	a1,0(s6)
    11f2:	8556                	mv	a0,s5
    11f4:	00000097          	auipc	ra,0x0
    11f8:	e46080e7          	jalr	-442(ra) # 103a <printint>
    11fc:	8b26                	mv	s6,s1
      state = 0;
    11fe:	4981                	li	s3,0
    1200:	b771                	j	118c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1202:	008b0493          	addi	s1,s6,8
    1206:	4681                	li	a3,0
    1208:	4629                	li	a2,10
    120a:	000b2583          	lw	a1,0(s6)
    120e:	8556                	mv	a0,s5
    1210:	00000097          	auipc	ra,0x0
    1214:	e2a080e7          	jalr	-470(ra) # 103a <printint>
    1218:	8b26                	mv	s6,s1
      state = 0;
    121a:	4981                	li	s3,0
    121c:	bf85                	j	118c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    121e:	008b0493          	addi	s1,s6,8
    1222:	4681                	li	a3,0
    1224:	4641                	li	a2,16
    1226:	000b2583          	lw	a1,0(s6)
    122a:	8556                	mv	a0,s5
    122c:	00000097          	auipc	ra,0x0
    1230:	e0e080e7          	jalr	-498(ra) # 103a <printint>
    1234:	8b26                	mv	s6,s1
      state = 0;
    1236:	4981                	li	s3,0
    1238:	bf91                	j	118c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    123a:	008b0793          	addi	a5,s6,8
    123e:	f8f43423          	sd	a5,-120(s0)
    1242:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1246:	03000593          	li	a1,48
    124a:	8556                	mv	a0,s5
    124c:	00000097          	auipc	ra,0x0
    1250:	d68080e7          	jalr	-664(ra) # fb4 <putc>
  putc(fd, 'x');
    1254:	85ea                	mv	a1,s10
    1256:	8556                	mv	a0,s5
    1258:	00000097          	auipc	ra,0x0
    125c:	d5c080e7          	jalr	-676(ra) # fb4 <putc>
    1260:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1262:	03c9d793          	srli	a5,s3,0x3c
    1266:	97de                	add	a5,a5,s7
    1268:	0007c583          	lbu	a1,0(a5)
    126c:	8556                	mv	a0,s5
    126e:	00000097          	auipc	ra,0x0
    1272:	d46080e7          	jalr	-698(ra) # fb4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1276:	0992                	slli	s3,s3,0x4
    1278:	34fd                	addiw	s1,s1,-1
    127a:	f4e5                	bnez	s1,1262 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    127c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1280:	4981                	li	s3,0
    1282:	b729                	j	118c <vprintf+0x60>
        s = va_arg(ap, char*);
    1284:	008b0993          	addi	s3,s6,8
    1288:	000b3483          	ld	s1,0(s6)
        if(s == 0)
    128c:	c085                	beqz	s1,12ac <vprintf+0x180>
        while(*s != 0){
    128e:	0004c583          	lbu	a1,0(s1)
    1292:	c9a1                	beqz	a1,12e2 <vprintf+0x1b6>
          putc(fd, *s);
    1294:	8556                	mv	a0,s5
    1296:	00000097          	auipc	ra,0x0
    129a:	d1e080e7          	jalr	-738(ra) # fb4 <putc>
          s++;
    129e:	0485                	addi	s1,s1,1
        while(*s != 0){
    12a0:	0004c583          	lbu	a1,0(s1)
    12a4:	f9e5                	bnez	a1,1294 <vprintf+0x168>
        s = va_arg(ap, char*);
    12a6:	8b4e                	mv	s6,s3
      state = 0;
    12a8:	4981                	li	s3,0
    12aa:	b5cd                	j	118c <vprintf+0x60>
          s = "(null)";
    12ac:	00000497          	auipc	s1,0x0
    12b0:	3bc48493          	addi	s1,s1,956 # 1668 <digits+0x18>
        while(*s != 0){
    12b4:	02800593          	li	a1,40
    12b8:	bff1                	j	1294 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
    12ba:	008b0493          	addi	s1,s6,8
    12be:	000b4583          	lbu	a1,0(s6)
    12c2:	8556                	mv	a0,s5
    12c4:	00000097          	auipc	ra,0x0
    12c8:	cf0080e7          	jalr	-784(ra) # fb4 <putc>
    12cc:	8b26                	mv	s6,s1
      state = 0;
    12ce:	4981                	li	s3,0
    12d0:	bd75                	j	118c <vprintf+0x60>
        putc(fd, c);
    12d2:	85d2                	mv	a1,s4
    12d4:	8556                	mv	a0,s5
    12d6:	00000097          	auipc	ra,0x0
    12da:	cde080e7          	jalr	-802(ra) # fb4 <putc>
      state = 0;
    12de:	4981                	li	s3,0
    12e0:	b575                	j	118c <vprintf+0x60>
        s = va_arg(ap, char*);
    12e2:	8b4e                	mv	s6,s3
      state = 0;
    12e4:	4981                	li	s3,0
    12e6:	b55d                	j	118c <vprintf+0x60>
    }
  }
}
    12e8:	70e6                	ld	ra,120(sp)
    12ea:	7446                	ld	s0,112(sp)
    12ec:	74a6                	ld	s1,104(sp)
    12ee:	7906                	ld	s2,96(sp)
    12f0:	69e6                	ld	s3,88(sp)
    12f2:	6a46                	ld	s4,80(sp)
    12f4:	6aa6                	ld	s5,72(sp)
    12f6:	6b06                	ld	s6,64(sp)
    12f8:	7be2                	ld	s7,56(sp)
    12fa:	7c42                	ld	s8,48(sp)
    12fc:	7ca2                	ld	s9,40(sp)
    12fe:	7d02                	ld	s10,32(sp)
    1300:	6de2                	ld	s11,24(sp)
    1302:	6109                	addi	sp,sp,128
    1304:	8082                	ret

0000000000001306 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1306:	715d                	addi	sp,sp,-80
    1308:	ec06                	sd	ra,24(sp)
    130a:	e822                	sd	s0,16(sp)
    130c:	1000                	addi	s0,sp,32
    130e:	e010                	sd	a2,0(s0)
    1310:	e414                	sd	a3,8(s0)
    1312:	e818                	sd	a4,16(s0)
    1314:	ec1c                	sd	a5,24(s0)
    1316:	03043023          	sd	a6,32(s0)
    131a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    131e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1322:	8622                	mv	a2,s0
    1324:	00000097          	auipc	ra,0x0
    1328:	e08080e7          	jalr	-504(ra) # 112c <vprintf>
}
    132c:	60e2                	ld	ra,24(sp)
    132e:	6442                	ld	s0,16(sp)
    1330:	6161                	addi	sp,sp,80
    1332:	8082                	ret

0000000000001334 <printf>:

void
printf(const char *fmt, ...)
{
    1334:	711d                	addi	sp,sp,-96
    1336:	ec06                	sd	ra,24(sp)
    1338:	e822                	sd	s0,16(sp)
    133a:	1000                	addi	s0,sp,32
    133c:	e40c                	sd	a1,8(s0)
    133e:	e810                	sd	a2,16(s0)
    1340:	ec14                	sd	a3,24(s0)
    1342:	f018                	sd	a4,32(s0)
    1344:	f41c                	sd	a5,40(s0)
    1346:	03043823          	sd	a6,48(s0)
    134a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    134e:	00840613          	addi	a2,s0,8
    1352:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1356:	85aa                	mv	a1,a0
    1358:	4505                	li	a0,1
    135a:	00000097          	auipc	ra,0x0
    135e:	dd2080e7          	jalr	-558(ra) # 112c <vprintf>
}
    1362:	60e2                	ld	ra,24(sp)
    1364:	6442                	ld	s0,16(sp)
    1366:	6125                	addi	sp,sp,96
    1368:	8082                	ret

000000000000136a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    136a:	1141                	addi	sp,sp,-16
    136c:	e422                	sd	s0,8(sp)
    136e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1370:	ff050693          	addi	a3,a0,-16 # ff0 <putc+0x3c>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1374:	00000797          	auipc	a5,0x0
    1378:	30c78793          	addi	a5,a5,780 # 1680 <freep>
    137c:	639c                	ld	a5,0(a5)
    137e:	a805                	j	13ae <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1380:	4618                	lw	a4,8(a2)
    1382:	9db9                	addw	a1,a1,a4
    1384:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1388:	6398                	ld	a4,0(a5)
    138a:	6318                	ld	a4,0(a4)
    138c:	fee53823          	sd	a4,-16(a0)
    1390:	a091                	j	13d4 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1392:	ff852703          	lw	a4,-8(a0)
    1396:	9e39                	addw	a2,a2,a4
    1398:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    139a:	ff053703          	ld	a4,-16(a0)
    139e:	e398                	sd	a4,0(a5)
    13a0:	a099                	j	13e6 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    13a2:	6398                	ld	a4,0(a5)
    13a4:	00e7e463          	bltu	a5,a4,13ac <free+0x42>
    13a8:	00e6ea63          	bltu	a3,a4,13bc <free+0x52>
{
    13ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    13ae:	fed7fae3          	bleu	a3,a5,13a2 <free+0x38>
    13b2:	6398                	ld	a4,0(a5)
    13b4:	00e6e463          	bltu	a3,a4,13bc <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    13b8:	fee7eae3          	bltu	a5,a4,13ac <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
    13bc:	ff852583          	lw	a1,-8(a0)
    13c0:	6390                	ld	a2,0(a5)
    13c2:	02059713          	slli	a4,a1,0x20
    13c6:	9301                	srli	a4,a4,0x20
    13c8:	0712                	slli	a4,a4,0x4
    13ca:	9736                	add	a4,a4,a3
    13cc:	fae60ae3          	beq	a2,a4,1380 <free+0x16>
    bp->s.ptr = p->s.ptr;
    13d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    13d4:	4790                	lw	a2,8(a5)
    13d6:	02061713          	slli	a4,a2,0x20
    13da:	9301                	srli	a4,a4,0x20
    13dc:	0712                	slli	a4,a4,0x4
    13de:	973e                	add	a4,a4,a5
    13e0:	fae689e3          	beq	a3,a4,1392 <free+0x28>
  } else
    p->s.ptr = bp;
    13e4:	e394                	sd	a3,0(a5)
  freep = p;
    13e6:	00000717          	auipc	a4,0x0
    13ea:	28f73d23          	sd	a5,666(a4) # 1680 <freep>
}
    13ee:	6422                	ld	s0,8(sp)
    13f0:	0141                	addi	sp,sp,16
    13f2:	8082                	ret

00000000000013f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    13f4:	7139                	addi	sp,sp,-64
    13f6:	fc06                	sd	ra,56(sp)
    13f8:	f822                	sd	s0,48(sp)
    13fa:	f426                	sd	s1,40(sp)
    13fc:	f04a                	sd	s2,32(sp)
    13fe:	ec4e                	sd	s3,24(sp)
    1400:	e852                	sd	s4,16(sp)
    1402:	e456                	sd	s5,8(sp)
    1404:	e05a                	sd	s6,0(sp)
    1406:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1408:	02051993          	slli	s3,a0,0x20
    140c:	0209d993          	srli	s3,s3,0x20
    1410:	09bd                	addi	s3,s3,15
    1412:	0049d993          	srli	s3,s3,0x4
    1416:	2985                	addiw	s3,s3,1
    1418:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
    141c:	00000797          	auipc	a5,0x0
    1420:	26478793          	addi	a5,a5,612 # 1680 <freep>
    1424:	6388                	ld	a0,0(a5)
    1426:	c515                	beqz	a0,1452 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1428:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    142a:	4798                	lw	a4,8(a5)
    142c:	03277f63          	bleu	s2,a4,146a <malloc+0x76>
    1430:	8a4e                	mv	s4,s3
    1432:	0009871b          	sext.w	a4,s3
    1436:	6685                	lui	a3,0x1
    1438:	00d77363          	bleu	a3,a4,143e <malloc+0x4a>
    143c:	6a05                	lui	s4,0x1
    143e:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
    1442:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1446:	00000497          	auipc	s1,0x0
    144a:	23a48493          	addi	s1,s1,570 # 1680 <freep>
  if(p == (char*)-1)
    144e:	5b7d                	li	s6,-1
    1450:	a885                	j	14c0 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
    1452:	00000797          	auipc	a5,0x0
    1456:	74e78793          	addi	a5,a5,1870 # 1ba0 <base>
    145a:	00000717          	auipc	a4,0x0
    145e:	22f73323          	sd	a5,550(a4) # 1680 <freep>
    1462:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1464:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1468:	b7e1                	j	1430 <malloc+0x3c>
      if(p->s.size == nunits)
    146a:	02e90b63          	beq	s2,a4,14a0 <malloc+0xac>
        p->s.size -= nunits;
    146e:	4137073b          	subw	a4,a4,s3
    1472:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1474:	1702                	slli	a4,a4,0x20
    1476:	9301                	srli	a4,a4,0x20
    1478:	0712                	slli	a4,a4,0x4
    147a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    147c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1480:	00000717          	auipc	a4,0x0
    1484:	20a73023          	sd	a0,512(a4) # 1680 <freep>
      return (void*)(p + 1);
    1488:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    148c:	70e2                	ld	ra,56(sp)
    148e:	7442                	ld	s0,48(sp)
    1490:	74a2                	ld	s1,40(sp)
    1492:	7902                	ld	s2,32(sp)
    1494:	69e2                	ld	s3,24(sp)
    1496:	6a42                	ld	s4,16(sp)
    1498:	6aa2                	ld	s5,8(sp)
    149a:	6b02                	ld	s6,0(sp)
    149c:	6121                	addi	sp,sp,64
    149e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    14a0:	6398                	ld	a4,0(a5)
    14a2:	e118                	sd	a4,0(a0)
    14a4:	bff1                	j	1480 <malloc+0x8c>
  hp->s.size = nu;
    14a6:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
    14aa:	0541                	addi	a0,a0,16
    14ac:	00000097          	auipc	ra,0x0
    14b0:	ebe080e7          	jalr	-322(ra) # 136a <free>
  return freep;
    14b4:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    14b6:	d979                	beqz	a0,148c <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    14ba:	4798                	lw	a4,8(a5)
    14bc:	fb2777e3          	bleu	s2,a4,146a <malloc+0x76>
    if(p == freep)
    14c0:	6098                	ld	a4,0(s1)
    14c2:	853e                	mv	a0,a5
    14c4:	fef71ae3          	bne	a4,a5,14b8 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
    14c8:	8552                	mv	a0,s4
    14ca:	00000097          	auipc	ra,0x0
    14ce:	a5c080e7          	jalr	-1444(ra) # f26 <sbrk>
  if(p == (char*)-1)
    14d2:	fd651ae3          	bne	a0,s6,14a6 <malloc+0xb2>
        return 0;
    14d6:	4501                	li	a0,0
    14d8:	bf55                	j	148c <malloc+0x98>
