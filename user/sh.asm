
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
      14:	4a858593          	addi	a1,a1,1192 # 14b8 <malloc+0xe8>
      18:	4509                	li	a0,2
      1a:	00001097          	auipc	ra,0x1
      1e:	2ca080e7          	jalr	714(ra) # 12e4 <fprintf>
  fflush(2);
      22:	4509                	li	a0,2
      24:	00001097          	auipc	ra,0x1
      28:	09e080e7          	jalr	158(ra) # 10c2 <fflush>
  memset(buf, 0, nbuf);
      2c:	864a                	mv	a2,s2
      2e:	4581                	li	a1,0
      30:	8526                	mv	a0,s1
      32:	00001097          	auipc	ra,0x1
      36:	bfa080e7          	jalr	-1030(ra) # c2c <memset>
  gets(buf, nbuf);
      3a:	85ca                	mv	a1,s2
      3c:	8526                	mv	a0,s1
      3e:	00001097          	auipc	ra,0x1
      42:	c38080e7          	jalr	-968(ra) # c76 <gets>
  if(buf[0] == 0) // EOF
      46:	0004c503          	lbu	a0,0(s1)
      4a:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      4e:	40a00533          	neg	a0,a0
      52:	60e2                	ld	ra,24(sp)
      54:	6442                	ld	s0,16(sp)
      56:	64a2                	ld	s1,8(sp)
      58:	6902                	ld	s2,0(sp)
      5a:	6105                	addi	sp,sp,32
      5c:	8082                	ret

000000000000005e <panic>:
  exit(0);
}

void
panic(char *s)
{
      5e:	1141                	addi	sp,sp,-16
      60:	e406                	sd	ra,8(sp)
      62:	e022                	sd	s0,0(sp)
      64:	0800                	addi	s0,sp,16
      66:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      68:	00001597          	auipc	a1,0x1
      6c:	45858593          	addi	a1,a1,1112 # 14c0 <malloc+0xf0>
      70:	4509                	li	a0,2
      72:	00001097          	auipc	ra,0x1
      76:	272080e7          	jalr	626(ra) # 12e4 <fprintf>
  exit(1);
      7a:	4505                	li	a0,1
      7c:	00001097          	auipc	ra,0x1
      80:	e02080e7          	jalr	-510(ra) # e7e <exit>

0000000000000084 <fork1>:
}

int
fork1(void)
{
      84:	1141                	addi	sp,sp,-16
      86:	e406                	sd	ra,8(sp)
      88:	e022                	sd	s0,0(sp)
      8a:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      8c:	00001097          	auipc	ra,0x1
      90:	dea080e7          	jalr	-534(ra) # e76 <fork>
  if(pid == -1)
      94:	57fd                	li	a5,-1
      96:	00f50663          	beq	a0,a5,a2 <fork1+0x1e>
    panic("fork");
  return pid;
}
      9a:	60a2                	ld	ra,8(sp)
      9c:	6402                	ld	s0,0(sp)
      9e:	0141                	addi	sp,sp,16
      a0:	8082                	ret
    panic("fork");
      a2:	00001517          	auipc	a0,0x1
      a6:	42650513          	addi	a0,a0,1062 # 14c8 <malloc+0xf8>
      aa:	00000097          	auipc	ra,0x0
      ae:	fb4080e7          	jalr	-76(ra) # 5e <panic>

00000000000000b2 <runcmd>:
{
      b2:	7179                	addi	sp,sp,-48
      b4:	f406                	sd	ra,40(sp)
      b6:	f022                	sd	s0,32(sp)
      b8:	ec26                	sd	s1,24(sp)
      ba:	1800                	addi	s0,sp,48
  if(cmd == 0)
      bc:	c10d                	beqz	a0,de <runcmd+0x2c>
      be:	84aa                	mv	s1,a0
  switch(cmd->type){
      c0:	4118                	lw	a4,0(a0)
      c2:	4795                	li	a5,5
      c4:	02e7e263          	bltu	a5,a4,e8 <runcmd+0x36>
      c8:	00056783          	lwu	a5,0(a0)
      cc:	078a                	slli	a5,a5,0x2
      ce:	00001717          	auipc	a4,0x1
      d2:	52a70713          	addi	a4,a4,1322 # 15f8 <malloc+0x228>
      d6:	97ba                	add	a5,a5,a4
      d8:	439c                	lw	a5,0(a5)
      da:	97ba                	add	a5,a5,a4
      dc:	8782                	jr	a5
    exit(1);
      de:	4505                	li	a0,1
      e0:	00001097          	auipc	ra,0x1
      e4:	d9e080e7          	jalr	-610(ra) # e7e <exit>
    panic("runcmd");
      e8:	00001517          	auipc	a0,0x1
      ec:	3e850513          	addi	a0,a0,1000 # 14d0 <malloc+0x100>
      f0:	00000097          	auipc	ra,0x0
      f4:	f6e080e7          	jalr	-146(ra) # 5e <panic>
    if(ecmd->argv[0] == 0)
      f8:	6508                	ld	a0,8(a0)
      fa:	c515                	beqz	a0,126 <runcmd+0x74>
    exec(ecmd->argv[0], ecmd->argv);
      fc:	00848593          	addi	a1,s1,8
     100:	00001097          	auipc	ra,0x1
     104:	db6080e7          	jalr	-586(ra) # eb6 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     108:	6490                	ld	a2,8(s1)
     10a:	00001597          	auipc	a1,0x1
     10e:	3ce58593          	addi	a1,a1,974 # 14d8 <malloc+0x108>
     112:	4509                	li	a0,2
     114:	00001097          	auipc	ra,0x1
     118:	1d0080e7          	jalr	464(ra) # 12e4 <fprintf>
  exit(0);
     11c:	4501                	li	a0,0
     11e:	00001097          	auipc	ra,0x1
     122:	d60080e7          	jalr	-672(ra) # e7e <exit>
      exit(1);
     126:	4505                	li	a0,1
     128:	00001097          	auipc	ra,0x1
     12c:	d56080e7          	jalr	-682(ra) # e7e <exit>
    close(rcmd->fd);
     130:	5148                	lw	a0,36(a0)
     132:	00001097          	auipc	ra,0x1
     136:	cb0080e7          	jalr	-848(ra) # de2 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     13a:	508c                	lw	a1,32(s1)
     13c:	6888                	ld	a0,16(s1)
     13e:	00001097          	auipc	ra,0x1
     142:	d80080e7          	jalr	-640(ra) # ebe <open>
     146:	00054763          	bltz	a0,154 <runcmd+0xa2>
    runcmd(rcmd->cmd);
     14a:	6488                	ld	a0,8(s1)
     14c:	00000097          	auipc	ra,0x0
     150:	f66080e7          	jalr	-154(ra) # b2 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     154:	6890                	ld	a2,16(s1)
     156:	00001597          	auipc	a1,0x1
     15a:	39258593          	addi	a1,a1,914 # 14e8 <malloc+0x118>
     15e:	4509                	li	a0,2
     160:	00001097          	auipc	ra,0x1
     164:	184080e7          	jalr	388(ra) # 12e4 <fprintf>
      exit(1);
     168:	4505                	li	a0,1
     16a:	00001097          	auipc	ra,0x1
     16e:	d14080e7          	jalr	-748(ra) # e7e <exit>
    if(fork1() == 0)
     172:	00000097          	auipc	ra,0x0
     176:	f12080e7          	jalr	-238(ra) # 84 <fork1>
     17a:	c919                	beqz	a0,190 <runcmd+0xde>
    wait(0);
     17c:	4501                	li	a0,0
     17e:	00001097          	auipc	ra,0x1
     182:	d08080e7          	jalr	-760(ra) # e86 <wait>
    runcmd(lcmd->right);
     186:	6888                	ld	a0,16(s1)
     188:	00000097          	auipc	ra,0x0
     18c:	f2a080e7          	jalr	-214(ra) # b2 <runcmd>
      runcmd(lcmd->left);
     190:	6488                	ld	a0,8(s1)
     192:	00000097          	auipc	ra,0x0
     196:	f20080e7          	jalr	-224(ra) # b2 <runcmd>
    if(pipe(p) < 0)
     19a:	fd840513          	addi	a0,s0,-40
     19e:	00001097          	auipc	ra,0x1
     1a2:	cf0080e7          	jalr	-784(ra) # e8e <pipe>
     1a6:	04054363          	bltz	a0,1ec <runcmd+0x13a>
    if(fork1() == 0){
     1aa:	00000097          	auipc	ra,0x0
     1ae:	eda080e7          	jalr	-294(ra) # 84 <fork1>
     1b2:	c529                	beqz	a0,1fc <runcmd+0x14a>
    if(fork1() == 0){
     1b4:	00000097          	auipc	ra,0x0
     1b8:	ed0080e7          	jalr	-304(ra) # 84 <fork1>
     1bc:	cd25                	beqz	a0,234 <runcmd+0x182>
    close(p[0]);
     1be:	fd842503          	lw	a0,-40(s0)
     1c2:	00001097          	auipc	ra,0x1
     1c6:	c20080e7          	jalr	-992(ra) # de2 <close>
    close(p[1]);
     1ca:	fdc42503          	lw	a0,-36(s0)
     1ce:	00001097          	auipc	ra,0x1
     1d2:	c14080e7          	jalr	-1004(ra) # de2 <close>
    wait(0);
     1d6:	4501                	li	a0,0
     1d8:	00001097          	auipc	ra,0x1
     1dc:	cae080e7          	jalr	-850(ra) # e86 <wait>
    wait(0);
     1e0:	4501                	li	a0,0
     1e2:	00001097          	auipc	ra,0x1
     1e6:	ca4080e7          	jalr	-860(ra) # e86 <wait>
    break;
     1ea:	bf0d                	j	11c <runcmd+0x6a>
      panic("pipe");
     1ec:	00001517          	auipc	a0,0x1
     1f0:	30c50513          	addi	a0,a0,780 # 14f8 <malloc+0x128>
     1f4:	00000097          	auipc	ra,0x0
     1f8:	e6a080e7          	jalr	-406(ra) # 5e <panic>
      close(1);
     1fc:	4505                	li	a0,1
     1fe:	00001097          	auipc	ra,0x1
     202:	be4080e7          	jalr	-1052(ra) # de2 <close>
      dup(p[1]);
     206:	fdc42503          	lw	a0,-36(s0)
     20a:	00001097          	auipc	ra,0x1
     20e:	cec080e7          	jalr	-788(ra) # ef6 <dup>
      close(p[0]);
     212:	fd842503          	lw	a0,-40(s0)
     216:	00001097          	auipc	ra,0x1
     21a:	bcc080e7          	jalr	-1076(ra) # de2 <close>
      close(p[1]);
     21e:	fdc42503          	lw	a0,-36(s0)
     222:	00001097          	auipc	ra,0x1
     226:	bc0080e7          	jalr	-1088(ra) # de2 <close>
      runcmd(pcmd->left);
     22a:	6488                	ld	a0,8(s1)
     22c:	00000097          	auipc	ra,0x0
     230:	e86080e7          	jalr	-378(ra) # b2 <runcmd>
      close(0);
     234:	00001097          	auipc	ra,0x1
     238:	bae080e7          	jalr	-1106(ra) # de2 <close>
      dup(p[0]);
     23c:	fd842503          	lw	a0,-40(s0)
     240:	00001097          	auipc	ra,0x1
     244:	cb6080e7          	jalr	-842(ra) # ef6 <dup>
      close(p[0]);
     248:	fd842503          	lw	a0,-40(s0)
     24c:	00001097          	auipc	ra,0x1
     250:	b96080e7          	jalr	-1130(ra) # de2 <close>
      close(p[1]);
     254:	fdc42503          	lw	a0,-36(s0)
     258:	00001097          	auipc	ra,0x1
     25c:	b8a080e7          	jalr	-1142(ra) # de2 <close>
      runcmd(pcmd->right);
     260:	6888                	ld	a0,16(s1)
     262:	00000097          	auipc	ra,0x0
     266:	e50080e7          	jalr	-432(ra) # b2 <runcmd>
    if(fork1() == 0)
     26a:	00000097          	auipc	ra,0x0
     26e:	e1a080e7          	jalr	-486(ra) # 84 <fork1>
     272:	ea0515e3          	bnez	a0,11c <runcmd+0x6a>
      runcmd(bcmd->cmd);
     276:	6488                	ld	a0,8(s1)
     278:	00000097          	auipc	ra,0x0
     27c:	e3a080e7          	jalr	-454(ra) # b2 <runcmd>

0000000000000280 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     280:	1101                	addi	sp,sp,-32
     282:	ec06                	sd	ra,24(sp)
     284:	e822                	sd	s0,16(sp)
     286:	e426                	sd	s1,8(sp)
     288:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     28a:	0a800513          	li	a0,168
     28e:	00001097          	auipc	ra,0x1
     292:	142080e7          	jalr	322(ra) # 13d0 <malloc>
     296:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     298:	0a800613          	li	a2,168
     29c:	4581                	li	a1,0
     29e:	00001097          	auipc	ra,0x1
     2a2:	98e080e7          	jalr	-1650(ra) # c2c <memset>
  cmd->type = EXEC;
     2a6:	4785                	li	a5,1
     2a8:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     2aa:	8526                	mv	a0,s1
     2ac:	60e2                	ld	ra,24(sp)
     2ae:	6442                	ld	s0,16(sp)
     2b0:	64a2                	ld	s1,8(sp)
     2b2:	6105                	addi	sp,sp,32
     2b4:	8082                	ret

00000000000002b6 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2b6:	7139                	addi	sp,sp,-64
     2b8:	fc06                	sd	ra,56(sp)
     2ba:	f822                	sd	s0,48(sp)
     2bc:	f426                	sd	s1,40(sp)
     2be:	f04a                	sd	s2,32(sp)
     2c0:	ec4e                	sd	s3,24(sp)
     2c2:	e852                	sd	s4,16(sp)
     2c4:	e456                	sd	s5,8(sp)
     2c6:	e05a                	sd	s6,0(sp)
     2c8:	0080                	addi	s0,sp,64
     2ca:	8b2a                	mv	s6,a0
     2cc:	8aae                	mv	s5,a1
     2ce:	8a32                	mv	s4,a2
     2d0:	89b6                	mv	s3,a3
     2d2:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2d4:	02800513          	li	a0,40
     2d8:	00001097          	auipc	ra,0x1
     2dc:	0f8080e7          	jalr	248(ra) # 13d0 <malloc>
     2e0:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2e2:	02800613          	li	a2,40
     2e6:	4581                	li	a1,0
     2e8:	00001097          	auipc	ra,0x1
     2ec:	944080e7          	jalr	-1724(ra) # c2c <memset>
  cmd->type = REDIR;
     2f0:	4789                	li	a5,2
     2f2:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     2f4:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     2f8:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     2fc:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     300:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     304:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     308:	8526                	mv	a0,s1
     30a:	70e2                	ld	ra,56(sp)
     30c:	7442                	ld	s0,48(sp)
     30e:	74a2                	ld	s1,40(sp)
     310:	7902                	ld	s2,32(sp)
     312:	69e2                	ld	s3,24(sp)
     314:	6a42                	ld	s4,16(sp)
     316:	6aa2                	ld	s5,8(sp)
     318:	6b02                	ld	s6,0(sp)
     31a:	6121                	addi	sp,sp,64
     31c:	8082                	ret

000000000000031e <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     31e:	7179                	addi	sp,sp,-48
     320:	f406                	sd	ra,40(sp)
     322:	f022                	sd	s0,32(sp)
     324:	ec26                	sd	s1,24(sp)
     326:	e84a                	sd	s2,16(sp)
     328:	e44e                	sd	s3,8(sp)
     32a:	1800                	addi	s0,sp,48
     32c:	89aa                	mv	s3,a0
     32e:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     330:	4561                	li	a0,24
     332:	00001097          	auipc	ra,0x1
     336:	09e080e7          	jalr	158(ra) # 13d0 <malloc>
     33a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     33c:	4661                	li	a2,24
     33e:	4581                	li	a1,0
     340:	00001097          	auipc	ra,0x1
     344:	8ec080e7          	jalr	-1812(ra) # c2c <memset>
  cmd->type = PIPE;
     348:	478d                	li	a5,3
     34a:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     34c:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     350:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     354:	8526                	mv	a0,s1
     356:	70a2                	ld	ra,40(sp)
     358:	7402                	ld	s0,32(sp)
     35a:	64e2                	ld	s1,24(sp)
     35c:	6942                	ld	s2,16(sp)
     35e:	69a2                	ld	s3,8(sp)
     360:	6145                	addi	sp,sp,48
     362:	8082                	ret

0000000000000364 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     364:	7179                	addi	sp,sp,-48
     366:	f406                	sd	ra,40(sp)
     368:	f022                	sd	s0,32(sp)
     36a:	ec26                	sd	s1,24(sp)
     36c:	e84a                	sd	s2,16(sp)
     36e:	e44e                	sd	s3,8(sp)
     370:	1800                	addi	s0,sp,48
     372:	89aa                	mv	s3,a0
     374:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     376:	4561                	li	a0,24
     378:	00001097          	auipc	ra,0x1
     37c:	058080e7          	jalr	88(ra) # 13d0 <malloc>
     380:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     382:	4661                	li	a2,24
     384:	4581                	li	a1,0
     386:	00001097          	auipc	ra,0x1
     38a:	8a6080e7          	jalr	-1882(ra) # c2c <memset>
  cmd->type = LIST;
     38e:	4791                	li	a5,4
     390:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     392:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     396:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     39a:	8526                	mv	a0,s1
     39c:	70a2                	ld	ra,40(sp)
     39e:	7402                	ld	s0,32(sp)
     3a0:	64e2                	ld	s1,24(sp)
     3a2:	6942                	ld	s2,16(sp)
     3a4:	69a2                	ld	s3,8(sp)
     3a6:	6145                	addi	sp,sp,48
     3a8:	8082                	ret

00000000000003aa <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     3aa:	1101                	addi	sp,sp,-32
     3ac:	ec06                	sd	ra,24(sp)
     3ae:	e822                	sd	s0,16(sp)
     3b0:	e426                	sd	s1,8(sp)
     3b2:	e04a                	sd	s2,0(sp)
     3b4:	1000                	addi	s0,sp,32
     3b6:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3b8:	4541                	li	a0,16
     3ba:	00001097          	auipc	ra,0x1
     3be:	016080e7          	jalr	22(ra) # 13d0 <malloc>
     3c2:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3c4:	4641                	li	a2,16
     3c6:	4581                	li	a1,0
     3c8:	00001097          	auipc	ra,0x1
     3cc:	864080e7          	jalr	-1948(ra) # c2c <memset>
  cmd->type = BACK;
     3d0:	4795                	li	a5,5
     3d2:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3d4:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     3d8:	8526                	mv	a0,s1
     3da:	60e2                	ld	ra,24(sp)
     3dc:	6442                	ld	s0,16(sp)
     3de:	64a2                	ld	s1,8(sp)
     3e0:	6902                	ld	s2,0(sp)
     3e2:	6105                	addi	sp,sp,32
     3e4:	8082                	ret

00000000000003e6 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     3e6:	7139                	addi	sp,sp,-64
     3e8:	fc06                	sd	ra,56(sp)
     3ea:	f822                	sd	s0,48(sp)
     3ec:	f426                	sd	s1,40(sp)
     3ee:	f04a                	sd	s2,32(sp)
     3f0:	ec4e                	sd	s3,24(sp)
     3f2:	e852                	sd	s4,16(sp)
     3f4:	e456                	sd	s5,8(sp)
     3f6:	e05a                	sd	s6,0(sp)
     3f8:	0080                	addi	s0,sp,64
     3fa:	8a2a                	mv	s4,a0
     3fc:	892e                	mv	s2,a1
     3fe:	8ab2                	mv	s5,a2
     400:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     402:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     404:	00001997          	auipc	s3,0x1
     408:	24c98993          	addi	s3,s3,588 # 1650 <whitespace>
     40c:	00b4fd63          	bgeu	s1,a1,426 <gettoken+0x40>
     410:	0004c583          	lbu	a1,0(s1)
     414:	854e                	mv	a0,s3
     416:	00001097          	auipc	ra,0x1
     41a:	83c080e7          	jalr	-1988(ra) # c52 <strchr>
     41e:	c501                	beqz	a0,426 <gettoken+0x40>
    s++;
     420:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     422:	fe9917e3          	bne	s2,s1,410 <gettoken+0x2a>
  if(q)
     426:	000a8463          	beqz	s5,42e <gettoken+0x48>
    *q = s;
     42a:	009ab023          	sd	s1,0(s5)
  ret = *s;
     42e:	0004c783          	lbu	a5,0(s1)
     432:	00078a9b          	sext.w	s5,a5
  switch(*s){
     436:	03c00713          	li	a4,60
     43a:	06f76563          	bltu	a4,a5,4a4 <gettoken+0xbe>
     43e:	03a00713          	li	a4,58
     442:	00f76e63          	bltu	a4,a5,45e <gettoken+0x78>
     446:	cf89                	beqz	a5,460 <gettoken+0x7a>
     448:	02600713          	li	a4,38
     44c:	00e78963          	beq	a5,a4,45e <gettoken+0x78>
     450:	fd87879b          	addiw	a5,a5,-40
     454:	0ff7f793          	andi	a5,a5,255
     458:	4705                	li	a4,1
     45a:	06f76c63          	bltu	a4,a5,4d2 <gettoken+0xec>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     45e:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     460:	000b0463          	beqz	s6,468 <gettoken+0x82>
    *eq = s;
     464:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     468:	00001997          	auipc	s3,0x1
     46c:	1e898993          	addi	s3,s3,488 # 1650 <whitespace>
     470:	0124fd63          	bgeu	s1,s2,48a <gettoken+0xa4>
     474:	0004c583          	lbu	a1,0(s1)
     478:	854e                	mv	a0,s3
     47a:	00000097          	auipc	ra,0x0
     47e:	7d8080e7          	jalr	2008(ra) # c52 <strchr>
     482:	c501                	beqz	a0,48a <gettoken+0xa4>
    s++;
     484:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     486:	fe9917e3          	bne	s2,s1,474 <gettoken+0x8e>
  *ps = s;
     48a:	009a3023          	sd	s1,0(s4)
  return ret;
}
     48e:	8556                	mv	a0,s5
     490:	70e2                	ld	ra,56(sp)
     492:	7442                	ld	s0,48(sp)
     494:	74a2                	ld	s1,40(sp)
     496:	7902                	ld	s2,32(sp)
     498:	69e2                	ld	s3,24(sp)
     49a:	6a42                	ld	s4,16(sp)
     49c:	6aa2                	ld	s5,8(sp)
     49e:	6b02                	ld	s6,0(sp)
     4a0:	6121                	addi	sp,sp,64
     4a2:	8082                	ret
  switch(*s){
     4a4:	03e00713          	li	a4,62
     4a8:	02e79163          	bne	a5,a4,4ca <gettoken+0xe4>
    s++;
     4ac:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     4b0:	0014c703          	lbu	a4,1(s1)
     4b4:	03e00793          	li	a5,62
      s++;
     4b8:	0489                	addi	s1,s1,2
      ret = '+';
     4ba:	02b00a93          	li	s5,43
    if(*s == '>'){
     4be:	faf701e3          	beq	a4,a5,460 <gettoken+0x7a>
    s++;
     4c2:	84b6                	mv	s1,a3
  ret = *s;
     4c4:	03e00a93          	li	s5,62
     4c8:	bf61                	j	460 <gettoken+0x7a>
  switch(*s){
     4ca:	07c00713          	li	a4,124
     4ce:	f8e788e3          	beq	a5,a4,45e <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4d2:	00001997          	auipc	s3,0x1
     4d6:	17e98993          	addi	s3,s3,382 # 1650 <whitespace>
     4da:	00001a97          	auipc	s5,0x1
     4de:	16ea8a93          	addi	s5,s5,366 # 1648 <symbols>
     4e2:	0324f563          	bgeu	s1,s2,50c <gettoken+0x126>
     4e6:	0004c583          	lbu	a1,0(s1)
     4ea:	854e                	mv	a0,s3
     4ec:	00000097          	auipc	ra,0x0
     4f0:	766080e7          	jalr	1894(ra) # c52 <strchr>
     4f4:	e505                	bnez	a0,51c <gettoken+0x136>
     4f6:	0004c583          	lbu	a1,0(s1)
     4fa:	8556                	mv	a0,s5
     4fc:	00000097          	auipc	ra,0x0
     500:	756080e7          	jalr	1878(ra) # c52 <strchr>
     504:	e909                	bnez	a0,516 <gettoken+0x130>
      s++;
     506:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     508:	fc991fe3          	bne	s2,s1,4e6 <gettoken+0x100>
  if(eq)
     50c:	06100a93          	li	s5,97
     510:	f40b1ae3          	bnez	s6,464 <gettoken+0x7e>
     514:	bf9d                	j	48a <gettoken+0xa4>
    ret = 'a';
     516:	06100a93          	li	s5,97
     51a:	b799                	j	460 <gettoken+0x7a>
     51c:	06100a93          	li	s5,97
     520:	b781                	j	460 <gettoken+0x7a>

0000000000000522 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     522:	7139                	addi	sp,sp,-64
     524:	fc06                	sd	ra,56(sp)
     526:	f822                	sd	s0,48(sp)
     528:	f426                	sd	s1,40(sp)
     52a:	f04a                	sd	s2,32(sp)
     52c:	ec4e                	sd	s3,24(sp)
     52e:	e852                	sd	s4,16(sp)
     530:	e456                	sd	s5,8(sp)
     532:	0080                	addi	s0,sp,64
     534:	8a2a                	mv	s4,a0
     536:	892e                	mv	s2,a1
     538:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     53a:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     53c:	00001997          	auipc	s3,0x1
     540:	11498993          	addi	s3,s3,276 # 1650 <whitespace>
     544:	00b4fd63          	bgeu	s1,a1,55e <peek+0x3c>
     548:	0004c583          	lbu	a1,0(s1)
     54c:	854e                	mv	a0,s3
     54e:	00000097          	auipc	ra,0x0
     552:	704080e7          	jalr	1796(ra) # c52 <strchr>
     556:	c501                	beqz	a0,55e <peek+0x3c>
    s++;
     558:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     55a:	fe9917e3          	bne	s2,s1,548 <peek+0x26>
  *ps = s;
     55e:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     562:	0004c583          	lbu	a1,0(s1)
     566:	4501                	li	a0,0
     568:	e991                	bnez	a1,57c <peek+0x5a>
}
     56a:	70e2                	ld	ra,56(sp)
     56c:	7442                	ld	s0,48(sp)
     56e:	74a2                	ld	s1,40(sp)
     570:	7902                	ld	s2,32(sp)
     572:	69e2                	ld	s3,24(sp)
     574:	6a42                	ld	s4,16(sp)
     576:	6aa2                	ld	s5,8(sp)
     578:	6121                	addi	sp,sp,64
     57a:	8082                	ret
  return *s && strchr(toks, *s);
     57c:	8556                	mv	a0,s5
     57e:	00000097          	auipc	ra,0x0
     582:	6d4080e7          	jalr	1748(ra) # c52 <strchr>
     586:	00a03533          	snez	a0,a0
     58a:	b7c5                	j	56a <peek+0x48>

000000000000058c <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     58c:	7159                	addi	sp,sp,-112
     58e:	f486                	sd	ra,104(sp)
     590:	f0a2                	sd	s0,96(sp)
     592:	eca6                	sd	s1,88(sp)
     594:	e8ca                	sd	s2,80(sp)
     596:	e4ce                	sd	s3,72(sp)
     598:	e0d2                	sd	s4,64(sp)
     59a:	fc56                	sd	s5,56(sp)
     59c:	f85a                	sd	s6,48(sp)
     59e:	f45e                	sd	s7,40(sp)
     5a0:	f062                	sd	s8,32(sp)
     5a2:	ec66                	sd	s9,24(sp)
     5a4:	1880                	addi	s0,sp,112
     5a6:	8a2a                	mv	s4,a0
     5a8:	89ae                	mv	s3,a1
     5aa:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5ac:	00001b97          	auipc	s7,0x1
     5b0:	f74b8b93          	addi	s7,s7,-140 # 1520 <malloc+0x150>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     5b4:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     5b8:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     5bc:	a02d                	j	5e6 <parseredirs+0x5a>
      panic("missing file for redirection");
     5be:	00001517          	auipc	a0,0x1
     5c2:	f4250513          	addi	a0,a0,-190 # 1500 <malloc+0x130>
     5c6:	00000097          	auipc	ra,0x0
     5ca:	a98080e7          	jalr	-1384(ra) # 5e <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5ce:	4701                	li	a4,0
     5d0:	4681                	li	a3,0
     5d2:	f9043603          	ld	a2,-112(s0)
     5d6:	f9843583          	ld	a1,-104(s0)
     5da:	8552                	mv	a0,s4
     5dc:	00000097          	auipc	ra,0x0
     5e0:	cda080e7          	jalr	-806(ra) # 2b6 <redircmd>
     5e4:	8a2a                	mv	s4,a0
    switch(tok){
     5e6:	03e00b13          	li	s6,62
     5ea:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     5ee:	865e                	mv	a2,s7
     5f0:	85ca                	mv	a1,s2
     5f2:	854e                	mv	a0,s3
     5f4:	00000097          	auipc	ra,0x0
     5f8:	f2e080e7          	jalr	-210(ra) # 522 <peek>
     5fc:	c925                	beqz	a0,66c <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     5fe:	4681                	li	a3,0
     600:	4601                	li	a2,0
     602:	85ca                	mv	a1,s2
     604:	854e                	mv	a0,s3
     606:	00000097          	auipc	ra,0x0
     60a:	de0080e7          	jalr	-544(ra) # 3e6 <gettoken>
     60e:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     610:	f9040693          	addi	a3,s0,-112
     614:	f9840613          	addi	a2,s0,-104
     618:	85ca                	mv	a1,s2
     61a:	854e                	mv	a0,s3
     61c:	00000097          	auipc	ra,0x0
     620:	dca080e7          	jalr	-566(ra) # 3e6 <gettoken>
     624:	f9851de3          	bne	a0,s8,5be <parseredirs+0x32>
    switch(tok){
     628:	fb9483e3          	beq	s1,s9,5ce <parseredirs+0x42>
     62c:	03648263          	beq	s1,s6,650 <parseredirs+0xc4>
     630:	fb549fe3          	bne	s1,s5,5ee <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     634:	4705                	li	a4,1
     636:	20100693          	li	a3,513
     63a:	f9043603          	ld	a2,-112(s0)
     63e:	f9843583          	ld	a1,-104(s0)
     642:	8552                	mv	a0,s4
     644:	00000097          	auipc	ra,0x0
     648:	c72080e7          	jalr	-910(ra) # 2b6 <redircmd>
     64c:	8a2a                	mv	s4,a0
      break;
     64e:	bf61                	j	5e6 <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     650:	4705                	li	a4,1
     652:	20100693          	li	a3,513
     656:	f9043603          	ld	a2,-112(s0)
     65a:	f9843583          	ld	a1,-104(s0)
     65e:	8552                	mv	a0,s4
     660:	00000097          	auipc	ra,0x0
     664:	c56080e7          	jalr	-938(ra) # 2b6 <redircmd>
     668:	8a2a                	mv	s4,a0
      break;
     66a:	bfb5                	j	5e6 <parseredirs+0x5a>
    }
  }
  return cmd;
}
     66c:	8552                	mv	a0,s4
     66e:	70a6                	ld	ra,104(sp)
     670:	7406                	ld	s0,96(sp)
     672:	64e6                	ld	s1,88(sp)
     674:	6946                	ld	s2,80(sp)
     676:	69a6                	ld	s3,72(sp)
     678:	6a06                	ld	s4,64(sp)
     67a:	7ae2                	ld	s5,56(sp)
     67c:	7b42                	ld	s6,48(sp)
     67e:	7ba2                	ld	s7,40(sp)
     680:	7c02                	ld	s8,32(sp)
     682:	6ce2                	ld	s9,24(sp)
     684:	6165                	addi	sp,sp,112
     686:	8082                	ret

0000000000000688 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     688:	7159                	addi	sp,sp,-112
     68a:	f486                	sd	ra,104(sp)
     68c:	f0a2                	sd	s0,96(sp)
     68e:	eca6                	sd	s1,88(sp)
     690:	e8ca                	sd	s2,80(sp)
     692:	e4ce                	sd	s3,72(sp)
     694:	e0d2                	sd	s4,64(sp)
     696:	fc56                	sd	s5,56(sp)
     698:	f85a                	sd	s6,48(sp)
     69a:	f45e                	sd	s7,40(sp)
     69c:	f062                	sd	s8,32(sp)
     69e:	ec66                	sd	s9,24(sp)
     6a0:	1880                	addi	s0,sp,112
     6a2:	8a2a                	mv	s4,a0
     6a4:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6a6:	00001617          	auipc	a2,0x1
     6aa:	e8260613          	addi	a2,a2,-382 # 1528 <malloc+0x158>
     6ae:	00000097          	auipc	ra,0x0
     6b2:	e74080e7          	jalr	-396(ra) # 522 <peek>
     6b6:	e905                	bnez	a0,6e6 <parseexec+0x5e>
     6b8:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     6ba:	00000097          	auipc	ra,0x0
     6be:	bc6080e7          	jalr	-1082(ra) # 280 <execcmd>
     6c2:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     6c4:	8656                	mv	a2,s5
     6c6:	85d2                	mv	a1,s4
     6c8:	00000097          	auipc	ra,0x0
     6cc:	ec4080e7          	jalr	-316(ra) # 58c <parseredirs>
     6d0:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     6d2:	008c0913          	addi	s2,s8,8
     6d6:	00001b17          	auipc	s6,0x1
     6da:	e72b0b13          	addi	s6,s6,-398 # 1548 <malloc+0x178>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     6de:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     6e2:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     6e4:	a0b1                	j	730 <parseexec+0xa8>
    return parseblock(ps, es);
     6e6:	85d6                	mv	a1,s5
     6e8:	8552                	mv	a0,s4
     6ea:	00000097          	auipc	ra,0x0
     6ee:	1bc080e7          	jalr	444(ra) # 8a6 <parseblock>
     6f2:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     6f4:	8526                	mv	a0,s1
     6f6:	70a6                	ld	ra,104(sp)
     6f8:	7406                	ld	s0,96(sp)
     6fa:	64e6                	ld	s1,88(sp)
     6fc:	6946                	ld	s2,80(sp)
     6fe:	69a6                	ld	s3,72(sp)
     700:	6a06                	ld	s4,64(sp)
     702:	7ae2                	ld	s5,56(sp)
     704:	7b42                	ld	s6,48(sp)
     706:	7ba2                	ld	s7,40(sp)
     708:	7c02                	ld	s8,32(sp)
     70a:	6ce2                	ld	s9,24(sp)
     70c:	6165                	addi	sp,sp,112
     70e:	8082                	ret
      panic("syntax");
     710:	00001517          	auipc	a0,0x1
     714:	e2050513          	addi	a0,a0,-480 # 1530 <malloc+0x160>
     718:	00000097          	auipc	ra,0x0
     71c:	946080e7          	jalr	-1722(ra) # 5e <panic>
    ret = parseredirs(ret, ps, es);
     720:	8656                	mv	a2,s5
     722:	85d2                	mv	a1,s4
     724:	8526                	mv	a0,s1
     726:	00000097          	auipc	ra,0x0
     72a:	e66080e7          	jalr	-410(ra) # 58c <parseredirs>
     72e:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     730:	865a                	mv	a2,s6
     732:	85d6                	mv	a1,s5
     734:	8552                	mv	a0,s4
     736:	00000097          	auipc	ra,0x0
     73a:	dec080e7          	jalr	-532(ra) # 522 <peek>
     73e:	e131                	bnez	a0,782 <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     740:	f9040693          	addi	a3,s0,-112
     744:	f9840613          	addi	a2,s0,-104
     748:	85d6                	mv	a1,s5
     74a:	8552                	mv	a0,s4
     74c:	00000097          	auipc	ra,0x0
     750:	c9a080e7          	jalr	-870(ra) # 3e6 <gettoken>
     754:	c51d                	beqz	a0,782 <parseexec+0xfa>
    if(tok != 'a')
     756:	fb951de3          	bne	a0,s9,710 <parseexec+0x88>
    cmd->argv[argc] = q;
     75a:	f9843783          	ld	a5,-104(s0)
     75e:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     762:	f9043783          	ld	a5,-112(s0)
     766:	04f93823          	sd	a5,80(s2)
    argc++;
     76a:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     76c:	0921                	addi	s2,s2,8
     76e:	fb7999e3          	bne	s3,s7,720 <parseexec+0x98>
      panic("too many args");
     772:	00001517          	auipc	a0,0x1
     776:	dc650513          	addi	a0,a0,-570 # 1538 <malloc+0x168>
     77a:	00000097          	auipc	ra,0x0
     77e:	8e4080e7          	jalr	-1820(ra) # 5e <panic>
  cmd->argv[argc] = 0;
     782:	098e                	slli	s3,s3,0x3
     784:	99e2                	add	s3,s3,s8
     786:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     78a:	0409bc23          	sd	zero,88(s3)
  return ret;
     78e:	b79d                	j	6f4 <parseexec+0x6c>

0000000000000790 <parsepipe>:
{
     790:	7179                	addi	sp,sp,-48
     792:	f406                	sd	ra,40(sp)
     794:	f022                	sd	s0,32(sp)
     796:	ec26                	sd	s1,24(sp)
     798:	e84a                	sd	s2,16(sp)
     79a:	e44e                	sd	s3,8(sp)
     79c:	1800                	addi	s0,sp,48
     79e:	892a                	mv	s2,a0
     7a0:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     7a2:	00000097          	auipc	ra,0x0
     7a6:	ee6080e7          	jalr	-282(ra) # 688 <parseexec>
     7aa:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     7ac:	00001617          	auipc	a2,0x1
     7b0:	da460613          	addi	a2,a2,-604 # 1550 <malloc+0x180>
     7b4:	85ce                	mv	a1,s3
     7b6:	854a                	mv	a0,s2
     7b8:	00000097          	auipc	ra,0x0
     7bc:	d6a080e7          	jalr	-662(ra) # 522 <peek>
     7c0:	e909                	bnez	a0,7d2 <parsepipe+0x42>
}
     7c2:	8526                	mv	a0,s1
     7c4:	70a2                	ld	ra,40(sp)
     7c6:	7402                	ld	s0,32(sp)
     7c8:	64e2                	ld	s1,24(sp)
     7ca:	6942                	ld	s2,16(sp)
     7cc:	69a2                	ld	s3,8(sp)
     7ce:	6145                	addi	sp,sp,48
     7d0:	8082                	ret
    gettoken(ps, es, 0, 0);
     7d2:	4681                	li	a3,0
     7d4:	4601                	li	a2,0
     7d6:	85ce                	mv	a1,s3
     7d8:	854a                	mv	a0,s2
     7da:	00000097          	auipc	ra,0x0
     7de:	c0c080e7          	jalr	-1012(ra) # 3e6 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     7e2:	85ce                	mv	a1,s3
     7e4:	854a                	mv	a0,s2
     7e6:	00000097          	auipc	ra,0x0
     7ea:	faa080e7          	jalr	-86(ra) # 790 <parsepipe>
     7ee:	85aa                	mv	a1,a0
     7f0:	8526                	mv	a0,s1
     7f2:	00000097          	auipc	ra,0x0
     7f6:	b2c080e7          	jalr	-1236(ra) # 31e <pipecmd>
     7fa:	84aa                	mv	s1,a0
  return cmd;
     7fc:	b7d9                	j	7c2 <parsepipe+0x32>

00000000000007fe <parseline>:
{
     7fe:	7179                	addi	sp,sp,-48
     800:	f406                	sd	ra,40(sp)
     802:	f022                	sd	s0,32(sp)
     804:	ec26                	sd	s1,24(sp)
     806:	e84a                	sd	s2,16(sp)
     808:	e44e                	sd	s3,8(sp)
     80a:	e052                	sd	s4,0(sp)
     80c:	1800                	addi	s0,sp,48
     80e:	892a                	mv	s2,a0
     810:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     812:	00000097          	auipc	ra,0x0
     816:	f7e080e7          	jalr	-130(ra) # 790 <parsepipe>
     81a:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     81c:	00001a17          	auipc	s4,0x1
     820:	d3ca0a13          	addi	s4,s4,-708 # 1558 <malloc+0x188>
     824:	8652                	mv	a2,s4
     826:	85ce                	mv	a1,s3
     828:	854a                	mv	a0,s2
     82a:	00000097          	auipc	ra,0x0
     82e:	cf8080e7          	jalr	-776(ra) # 522 <peek>
     832:	c105                	beqz	a0,852 <parseline+0x54>
    gettoken(ps, es, 0, 0);
     834:	4681                	li	a3,0
     836:	4601                	li	a2,0
     838:	85ce                	mv	a1,s3
     83a:	854a                	mv	a0,s2
     83c:	00000097          	auipc	ra,0x0
     840:	baa080e7          	jalr	-1110(ra) # 3e6 <gettoken>
    cmd = backcmd(cmd);
     844:	8526                	mv	a0,s1
     846:	00000097          	auipc	ra,0x0
     84a:	b64080e7          	jalr	-1180(ra) # 3aa <backcmd>
     84e:	84aa                	mv	s1,a0
     850:	bfd1                	j	824 <parseline+0x26>
  if(peek(ps, es, ";")){
     852:	00001617          	auipc	a2,0x1
     856:	d0e60613          	addi	a2,a2,-754 # 1560 <malloc+0x190>
     85a:	85ce                	mv	a1,s3
     85c:	854a                	mv	a0,s2
     85e:	00000097          	auipc	ra,0x0
     862:	cc4080e7          	jalr	-828(ra) # 522 <peek>
     866:	e911                	bnez	a0,87a <parseline+0x7c>
}
     868:	8526                	mv	a0,s1
     86a:	70a2                	ld	ra,40(sp)
     86c:	7402                	ld	s0,32(sp)
     86e:	64e2                	ld	s1,24(sp)
     870:	6942                	ld	s2,16(sp)
     872:	69a2                	ld	s3,8(sp)
     874:	6a02                	ld	s4,0(sp)
     876:	6145                	addi	sp,sp,48
     878:	8082                	ret
    gettoken(ps, es, 0, 0);
     87a:	4681                	li	a3,0
     87c:	4601                	li	a2,0
     87e:	85ce                	mv	a1,s3
     880:	854a                	mv	a0,s2
     882:	00000097          	auipc	ra,0x0
     886:	b64080e7          	jalr	-1180(ra) # 3e6 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     88a:	85ce                	mv	a1,s3
     88c:	854a                	mv	a0,s2
     88e:	00000097          	auipc	ra,0x0
     892:	f70080e7          	jalr	-144(ra) # 7fe <parseline>
     896:	85aa                	mv	a1,a0
     898:	8526                	mv	a0,s1
     89a:	00000097          	auipc	ra,0x0
     89e:	aca080e7          	jalr	-1334(ra) # 364 <listcmd>
     8a2:	84aa                	mv	s1,a0
  return cmd;
     8a4:	b7d1                	j	868 <parseline+0x6a>

00000000000008a6 <parseblock>:
{
     8a6:	7179                	addi	sp,sp,-48
     8a8:	f406                	sd	ra,40(sp)
     8aa:	f022                	sd	s0,32(sp)
     8ac:	ec26                	sd	s1,24(sp)
     8ae:	e84a                	sd	s2,16(sp)
     8b0:	e44e                	sd	s3,8(sp)
     8b2:	1800                	addi	s0,sp,48
     8b4:	84aa                	mv	s1,a0
     8b6:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8b8:	00001617          	auipc	a2,0x1
     8bc:	c7060613          	addi	a2,a2,-912 # 1528 <malloc+0x158>
     8c0:	00000097          	auipc	ra,0x0
     8c4:	c62080e7          	jalr	-926(ra) # 522 <peek>
     8c8:	c12d                	beqz	a0,92a <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     8ca:	4681                	li	a3,0
     8cc:	4601                	li	a2,0
     8ce:	85ca                	mv	a1,s2
     8d0:	8526                	mv	a0,s1
     8d2:	00000097          	auipc	ra,0x0
     8d6:	b14080e7          	jalr	-1260(ra) # 3e6 <gettoken>
  cmd = parseline(ps, es);
     8da:	85ca                	mv	a1,s2
     8dc:	8526                	mv	a0,s1
     8de:	00000097          	auipc	ra,0x0
     8e2:	f20080e7          	jalr	-224(ra) # 7fe <parseline>
     8e6:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     8e8:	00001617          	auipc	a2,0x1
     8ec:	c9060613          	addi	a2,a2,-880 # 1578 <malloc+0x1a8>
     8f0:	85ca                	mv	a1,s2
     8f2:	8526                	mv	a0,s1
     8f4:	00000097          	auipc	ra,0x0
     8f8:	c2e080e7          	jalr	-978(ra) # 522 <peek>
     8fc:	cd1d                	beqz	a0,93a <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     8fe:	4681                	li	a3,0
     900:	4601                	li	a2,0
     902:	85ca                	mv	a1,s2
     904:	8526                	mv	a0,s1
     906:	00000097          	auipc	ra,0x0
     90a:	ae0080e7          	jalr	-1312(ra) # 3e6 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     90e:	864a                	mv	a2,s2
     910:	85a6                	mv	a1,s1
     912:	854e                	mv	a0,s3
     914:	00000097          	auipc	ra,0x0
     918:	c78080e7          	jalr	-904(ra) # 58c <parseredirs>
}
     91c:	70a2                	ld	ra,40(sp)
     91e:	7402                	ld	s0,32(sp)
     920:	64e2                	ld	s1,24(sp)
     922:	6942                	ld	s2,16(sp)
     924:	69a2                	ld	s3,8(sp)
     926:	6145                	addi	sp,sp,48
     928:	8082                	ret
    panic("parseblock");
     92a:	00001517          	auipc	a0,0x1
     92e:	c3e50513          	addi	a0,a0,-962 # 1568 <malloc+0x198>
     932:	fffff097          	auipc	ra,0xfffff
     936:	72c080e7          	jalr	1836(ra) # 5e <panic>
    panic("syntax - missing )");
     93a:	00001517          	auipc	a0,0x1
     93e:	c4650513          	addi	a0,a0,-954 # 1580 <malloc+0x1b0>
     942:	fffff097          	auipc	ra,0xfffff
     946:	71c080e7          	jalr	1820(ra) # 5e <panic>

000000000000094a <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     94a:	1101                	addi	sp,sp,-32
     94c:	ec06                	sd	ra,24(sp)
     94e:	e822                	sd	s0,16(sp)
     950:	e426                	sd	s1,8(sp)
     952:	1000                	addi	s0,sp,32
     954:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     956:	c521                	beqz	a0,99e <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     958:	4118                	lw	a4,0(a0)
     95a:	4795                	li	a5,5
     95c:	04e7e163          	bltu	a5,a4,99e <nulterminate+0x54>
     960:	00056783          	lwu	a5,0(a0)
     964:	078a                	slli	a5,a5,0x2
     966:	00001717          	auipc	a4,0x1
     96a:	caa70713          	addi	a4,a4,-854 # 1610 <malloc+0x240>
     96e:	97ba                	add	a5,a5,a4
     970:	439c                	lw	a5,0(a5)
     972:	97ba                	add	a5,a5,a4
     974:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     976:	651c                	ld	a5,8(a0)
     978:	c39d                	beqz	a5,99e <nulterminate+0x54>
     97a:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     97e:	67b8                	ld	a4,72(a5)
     980:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     984:	07a1                	addi	a5,a5,8
     986:	ff87b703          	ld	a4,-8(a5)
     98a:	fb75                	bnez	a4,97e <nulterminate+0x34>
     98c:	a809                	j	99e <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     98e:	6508                	ld	a0,8(a0)
     990:	00000097          	auipc	ra,0x0
     994:	fba080e7          	jalr	-70(ra) # 94a <nulterminate>
    *rcmd->efile = 0;
     998:	6c9c                	ld	a5,24(s1)
     99a:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     99e:	8526                	mv	a0,s1
     9a0:	60e2                	ld	ra,24(sp)
     9a2:	6442                	ld	s0,16(sp)
     9a4:	64a2                	ld	s1,8(sp)
     9a6:	6105                	addi	sp,sp,32
     9a8:	8082                	ret
    nulterminate(pcmd->left);
     9aa:	6508                	ld	a0,8(a0)
     9ac:	00000097          	auipc	ra,0x0
     9b0:	f9e080e7          	jalr	-98(ra) # 94a <nulterminate>
    nulterminate(pcmd->right);
     9b4:	6888                	ld	a0,16(s1)
     9b6:	00000097          	auipc	ra,0x0
     9ba:	f94080e7          	jalr	-108(ra) # 94a <nulterminate>
    break;
     9be:	b7c5                	j	99e <nulterminate+0x54>
    nulterminate(lcmd->left);
     9c0:	6508                	ld	a0,8(a0)
     9c2:	00000097          	auipc	ra,0x0
     9c6:	f88080e7          	jalr	-120(ra) # 94a <nulterminate>
    nulterminate(lcmd->right);
     9ca:	6888                	ld	a0,16(s1)
     9cc:	00000097          	auipc	ra,0x0
     9d0:	f7e080e7          	jalr	-130(ra) # 94a <nulterminate>
    break;
     9d4:	b7e9                	j	99e <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     9d6:	6508                	ld	a0,8(a0)
     9d8:	00000097          	auipc	ra,0x0
     9dc:	f72080e7          	jalr	-142(ra) # 94a <nulterminate>
    break;
     9e0:	bf7d                	j	99e <nulterminate+0x54>

00000000000009e2 <parsecmd>:
{
     9e2:	7179                	addi	sp,sp,-48
     9e4:	f406                	sd	ra,40(sp)
     9e6:	f022                	sd	s0,32(sp)
     9e8:	ec26                	sd	s1,24(sp)
     9ea:	e84a                	sd	s2,16(sp)
     9ec:	1800                	addi	s0,sp,48
     9ee:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     9f2:	84aa                	mv	s1,a0
     9f4:	00000097          	auipc	ra,0x0
     9f8:	20e080e7          	jalr	526(ra) # c02 <strlen>
     9fc:	1502                	slli	a0,a0,0x20
     9fe:	9101                	srli	a0,a0,0x20
     a00:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     a02:	85a6                	mv	a1,s1
     a04:	fd840513          	addi	a0,s0,-40
     a08:	00000097          	auipc	ra,0x0
     a0c:	df6080e7          	jalr	-522(ra) # 7fe <parseline>
     a10:	892a                	mv	s2,a0
  peek(&s, es, "");
     a12:	00001617          	auipc	a2,0x1
     a16:	b8660613          	addi	a2,a2,-1146 # 1598 <malloc+0x1c8>
     a1a:	85a6                	mv	a1,s1
     a1c:	fd840513          	addi	a0,s0,-40
     a20:	00000097          	auipc	ra,0x0
     a24:	b02080e7          	jalr	-1278(ra) # 522 <peek>
  if(s != es){
     a28:	fd843603          	ld	a2,-40(s0)
     a2c:	00961e63          	bne	a2,s1,a48 <parsecmd+0x66>
  nulterminate(cmd);
     a30:	854a                	mv	a0,s2
     a32:	00000097          	auipc	ra,0x0
     a36:	f18080e7          	jalr	-232(ra) # 94a <nulterminate>
}
     a3a:	854a                	mv	a0,s2
     a3c:	70a2                	ld	ra,40(sp)
     a3e:	7402                	ld	s0,32(sp)
     a40:	64e2                	ld	s1,24(sp)
     a42:	6942                	ld	s2,16(sp)
     a44:	6145                	addi	sp,sp,48
     a46:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a48:	00001597          	auipc	a1,0x1
     a4c:	b5858593          	addi	a1,a1,-1192 # 15a0 <malloc+0x1d0>
     a50:	4509                	li	a0,2
     a52:	00001097          	auipc	ra,0x1
     a56:	892080e7          	jalr	-1902(ra) # 12e4 <fprintf>
    panic("syntax");
     a5a:	00001517          	auipc	a0,0x1
     a5e:	ad650513          	addi	a0,a0,-1322 # 1530 <malloc+0x160>
     a62:	fffff097          	auipc	ra,0xfffff
     a66:	5fc080e7          	jalr	1532(ra) # 5e <panic>

0000000000000a6a <main>:
{
     a6a:	711d                	addi	sp,sp,-96
     a6c:	ec86                	sd	ra,88(sp)
     a6e:	e8a2                	sd	s0,80(sp)
     a70:	e4a6                	sd	s1,72(sp)
     a72:	e0ca                	sd	s2,64(sp)
     a74:	fc4e                	sd	s3,56(sp)
     a76:	f852                	sd	s4,48(sp)
     a78:	f456                	sd	s5,40(sp)
     a7a:	f05a                	sd	s6,32(sp)
     a7c:	ec5e                	sd	s7,24(sp)
     a7e:	1080                	addi	s0,sp,96
     a80:	84ae                	mv	s1,a1
  int lastretval = 0;
     a82:	fa042623          	sw	zero,-84(s0)
  if (argc < 2){
     a86:	4785                	li	a5,1
     a88:	04a7d563          	bge	a5,a0,ad2 <main+0x68>
  while((fd = open(argv[1], O_RDWR)) >= 0){
     a8c:	4589                	li	a1,2
     a8e:	6488                	ld	a0,8(s1)
     a90:	00000097          	auipc	ra,0x0
     a94:	42e080e7          	jalr	1070(ra) # ebe <open>
     a98:	00054963          	bltz	a0,aaa <main+0x40>
    if(fd >= 3){
     a9c:	4789                	li	a5,2
     a9e:	fea7d7e3          	bge	a5,a0,a8c <main+0x22>
      close(fd);
     aa2:	00000097          	auipc	ra,0x0
     aa6:	340080e7          	jalr	832(ra) # de2 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     aaa:	00001497          	auipc	s1,0x1
     aae:	bb648493          	addi	s1,s1,-1098 # 1660 <buf.1159>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ab2:	06300913          	li	s2,99
    if(buf[0] == 'r' && buf[1] == 'v' && buf[2] == '\n'){
     ab6:	07200993          	li	s3,114
     aba:	07600a13          	li	s4,118
     abe:	4aa9                	li	s5,10
      fprintf(2, "retval = %d\n", lastretval);
     ac0:	00001b17          	auipc	s6,0x1
     ac4:	b28b0b13          	addi	s6,s6,-1240 # 15e8 <malloc+0x218>
      if(chdir(buf+3) < 0)
     ac8:	00001b97          	auipc	s7,0x1
     acc:	b9bb8b93          	addi	s7,s7,-1125 # 1663 <buf.1159+0x3>
     ad0:	a081                	j	b10 <main+0xa6>
    printf("expected one argument, got argc=%d\n", argc);
     ad2:	85aa                	mv	a1,a0
     ad4:	00001517          	auipc	a0,0x1
     ad8:	adc50513          	addi	a0,a0,-1316 # 15b0 <malloc+0x1e0>
     adc:	00001097          	auipc	ra,0x1
     ae0:	836080e7          	jalr	-1994(ra) # 1312 <printf>
    exit(-1);
     ae4:	557d                	li	a0,-1
     ae6:	00000097          	auipc	ra,0x0
     aea:	398080e7          	jalr	920(ra) # e7e <exit>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     aee:	0014c703          	lbu	a4,1(s1)
     af2:	06400793          	li	a5,100
     af6:	04f70d63          	beq	a4,a5,b50 <main+0xe6>
    if(fork1() == 0)
     afa:	fffff097          	auipc	ra,0xfffff
     afe:	58a080e7          	jalr	1418(ra) # 84 <fork1>
     b02:	c959                	beqz	a0,b98 <main+0x12e>
    wait(&lastretval);
     b04:	fac40513          	addi	a0,s0,-84
     b08:	00000097          	auipc	ra,0x0
     b0c:	37e080e7          	jalr	894(ra) # e86 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     b10:	06400593          	li	a1,100
     b14:	8526                	mv	a0,s1
     b16:	fffff097          	auipc	ra,0xfffff
     b1a:	4ea080e7          	jalr	1258(ra) # 0 <getcmd>
     b1e:	08054963          	bltz	a0,bb0 <main+0x146>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b22:	0004c783          	lbu	a5,0(s1)
     b26:	fd2784e3          	beq	a5,s2,aee <main+0x84>
    if(buf[0] == 'r' && buf[1] == 'v' && buf[2] == '\n'){
     b2a:	fd3798e3          	bne	a5,s3,afa <main+0x90>
     b2e:	0014c783          	lbu	a5,1(s1)
     b32:	fd4794e3          	bne	a5,s4,afa <main+0x90>
     b36:	0024c783          	lbu	a5,2(s1)
     b3a:	fd5790e3          	bne	a5,s5,afa <main+0x90>
      fprintf(2, "retval = %d\n", lastretval);
     b3e:	fac42603          	lw	a2,-84(s0)
     b42:	85da                	mv	a1,s6
     b44:	4509                	li	a0,2
     b46:	00000097          	auipc	ra,0x0
     b4a:	79e080e7          	jalr	1950(ra) # 12e4 <fprintf>
      continue;
     b4e:	b7c9                	j	b10 <main+0xa6>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b50:	0024c703          	lbu	a4,2(s1)
     b54:	02000793          	li	a5,32
     b58:	faf711e3          	bne	a4,a5,afa <main+0x90>
      buf[strlen(buf)-1] = 0;  // chop \n
     b5c:	8526                	mv	a0,s1
     b5e:	00000097          	auipc	ra,0x0
     b62:	0a4080e7          	jalr	164(ra) # c02 <strlen>
     b66:	fff5079b          	addiw	a5,a0,-1
     b6a:	1782                	slli	a5,a5,0x20
     b6c:	9381                	srli	a5,a5,0x20
     b6e:	97a6                	add	a5,a5,s1
     b70:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     b74:	855e                	mv	a0,s7
     b76:	00000097          	auipc	ra,0x0
     b7a:	378080e7          	jalr	888(ra) # eee <chdir>
     b7e:	f80559e3          	bgez	a0,b10 <main+0xa6>
        fprintf(2, "cannot cd %s\n", buf+3);
     b82:	865e                	mv	a2,s7
     b84:	00001597          	auipc	a1,0x1
     b88:	a5458593          	addi	a1,a1,-1452 # 15d8 <malloc+0x208>
     b8c:	4509                	li	a0,2
     b8e:	00000097          	auipc	ra,0x0
     b92:	756080e7          	jalr	1878(ra) # 12e4 <fprintf>
     b96:	bfad                	j	b10 <main+0xa6>
      runcmd(parsecmd(buf));
     b98:	00001517          	auipc	a0,0x1
     b9c:	ac850513          	addi	a0,a0,-1336 # 1660 <buf.1159>
     ba0:	00000097          	auipc	ra,0x0
     ba4:	e42080e7          	jalr	-446(ra) # 9e2 <parsecmd>
     ba8:	fffff097          	auipc	ra,0xfffff
     bac:	50a080e7          	jalr	1290(ra) # b2 <runcmd>
  exit(0);
     bb0:	4501                	li	a0,0
     bb2:	00000097          	auipc	ra,0x0
     bb6:	2cc080e7          	jalr	716(ra) # e7e <exit>

0000000000000bba <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     bba:	1141                	addi	sp,sp,-16
     bbc:	e422                	sd	s0,8(sp)
     bbe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bc0:	87aa                	mv	a5,a0
     bc2:	0585                	addi	a1,a1,1
     bc4:	0785                	addi	a5,a5,1
     bc6:	fff5c703          	lbu	a4,-1(a1)
     bca:	fee78fa3          	sb	a4,-1(a5)
     bce:	fb75                	bnez	a4,bc2 <strcpy+0x8>
    ;
  return os;
}
     bd0:	6422                	ld	s0,8(sp)
     bd2:	0141                	addi	sp,sp,16
     bd4:	8082                	ret

0000000000000bd6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bd6:	1141                	addi	sp,sp,-16
     bd8:	e422                	sd	s0,8(sp)
     bda:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     bdc:	00054783          	lbu	a5,0(a0)
     be0:	cb91                	beqz	a5,bf4 <strcmp+0x1e>
     be2:	0005c703          	lbu	a4,0(a1)
     be6:	00f71763          	bne	a4,a5,bf4 <strcmp+0x1e>
    p++, q++;
     bea:	0505                	addi	a0,a0,1
     bec:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     bee:	00054783          	lbu	a5,0(a0)
     bf2:	fbe5                	bnez	a5,be2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     bf4:	0005c503          	lbu	a0,0(a1)
}
     bf8:	40a7853b          	subw	a0,a5,a0
     bfc:	6422                	ld	s0,8(sp)
     bfe:	0141                	addi	sp,sp,16
     c00:	8082                	ret

0000000000000c02 <strlen>:

uint
strlen(const char *s)
{
     c02:	1141                	addi	sp,sp,-16
     c04:	e422                	sd	s0,8(sp)
     c06:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c08:	00054783          	lbu	a5,0(a0)
     c0c:	cf91                	beqz	a5,c28 <strlen+0x26>
     c0e:	0505                	addi	a0,a0,1
     c10:	87aa                	mv	a5,a0
     c12:	4685                	li	a3,1
     c14:	9e89                	subw	a3,a3,a0
     c16:	00f6853b          	addw	a0,a3,a5
     c1a:	0785                	addi	a5,a5,1
     c1c:	fff7c703          	lbu	a4,-1(a5)
     c20:	fb7d                	bnez	a4,c16 <strlen+0x14>
    ;
  return n;
}
     c22:	6422                	ld	s0,8(sp)
     c24:	0141                	addi	sp,sp,16
     c26:	8082                	ret
  for(n = 0; s[n]; n++)
     c28:	4501                	li	a0,0
     c2a:	bfe5                	j	c22 <strlen+0x20>

0000000000000c2c <memset>:

void*
memset(void *dst, int c, uint n)
{
     c2c:	1141                	addi	sp,sp,-16
     c2e:	e422                	sd	s0,8(sp)
     c30:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c32:	ce09                	beqz	a2,c4c <memset+0x20>
     c34:	87aa                	mv	a5,a0
     c36:	fff6071b          	addiw	a4,a2,-1
     c3a:	1702                	slli	a4,a4,0x20
     c3c:	9301                	srli	a4,a4,0x20
     c3e:	0705                	addi	a4,a4,1
     c40:	972a                	add	a4,a4,a0
    cdst[i] = c;
     c42:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c46:	0785                	addi	a5,a5,1
     c48:	fee79de3          	bne	a5,a4,c42 <memset+0x16>
  }
  return dst;
}
     c4c:	6422                	ld	s0,8(sp)
     c4e:	0141                	addi	sp,sp,16
     c50:	8082                	ret

0000000000000c52 <strchr>:

char*
strchr(const char *s, char c)
{
     c52:	1141                	addi	sp,sp,-16
     c54:	e422                	sd	s0,8(sp)
     c56:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c58:	00054783          	lbu	a5,0(a0)
     c5c:	cb99                	beqz	a5,c72 <strchr+0x20>
    if(*s == c)
     c5e:	00f58763          	beq	a1,a5,c6c <strchr+0x1a>
  for(; *s; s++)
     c62:	0505                	addi	a0,a0,1
     c64:	00054783          	lbu	a5,0(a0)
     c68:	fbfd                	bnez	a5,c5e <strchr+0xc>
      return (char*)s;
  return 0;
     c6a:	4501                	li	a0,0
}
     c6c:	6422                	ld	s0,8(sp)
     c6e:	0141                	addi	sp,sp,16
     c70:	8082                	ret
  return 0;
     c72:	4501                	li	a0,0
     c74:	bfe5                	j	c6c <strchr+0x1a>

0000000000000c76 <gets>:

char*
gets(char *buf, int max)
{
     c76:	711d                	addi	sp,sp,-96
     c78:	ec86                	sd	ra,88(sp)
     c7a:	e8a2                	sd	s0,80(sp)
     c7c:	e4a6                	sd	s1,72(sp)
     c7e:	e0ca                	sd	s2,64(sp)
     c80:	fc4e                	sd	s3,56(sp)
     c82:	f852                	sd	s4,48(sp)
     c84:	f456                	sd	s5,40(sp)
     c86:	f05a                	sd	s6,32(sp)
     c88:	ec5e                	sd	s7,24(sp)
     c8a:	1080                	addi	s0,sp,96
     c8c:	8baa                	mv	s7,a0
     c8e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c90:	892a                	mv	s2,a0
     c92:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c94:	4aa9                	li	s5,10
     c96:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c98:	89a6                	mv	s3,s1
     c9a:	2485                	addiw	s1,s1,1
     c9c:	0344d863          	bge	s1,s4,ccc <gets+0x56>
    cc = read(0, &c, 1);
     ca0:	4605                	li	a2,1
     ca2:	faf40593          	addi	a1,s0,-81
     ca6:	4501                	li	a0,0
     ca8:	00000097          	auipc	ra,0x0
     cac:	1ee080e7          	jalr	494(ra) # e96 <read>
    if(cc < 1)
     cb0:	00a05e63          	blez	a0,ccc <gets+0x56>
    buf[i++] = c;
     cb4:	faf44783          	lbu	a5,-81(s0)
     cb8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cbc:	01578763          	beq	a5,s5,cca <gets+0x54>
     cc0:	0905                	addi	s2,s2,1
     cc2:	fd679be3          	bne	a5,s6,c98 <gets+0x22>
  for(i=0; i+1 < max; ){
     cc6:	89a6                	mv	s3,s1
     cc8:	a011                	j	ccc <gets+0x56>
     cca:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     ccc:	99de                	add	s3,s3,s7
     cce:	00098023          	sb	zero,0(s3)
  return buf;
}
     cd2:	855e                	mv	a0,s7
     cd4:	60e6                	ld	ra,88(sp)
     cd6:	6446                	ld	s0,80(sp)
     cd8:	64a6                	ld	s1,72(sp)
     cda:	6906                	ld	s2,64(sp)
     cdc:	79e2                	ld	s3,56(sp)
     cde:	7a42                	ld	s4,48(sp)
     ce0:	7aa2                	ld	s5,40(sp)
     ce2:	7b02                	ld	s6,32(sp)
     ce4:	6be2                	ld	s7,24(sp)
     ce6:	6125                	addi	sp,sp,96
     ce8:	8082                	ret

0000000000000cea <atoi>:
  return r;
}

int
atoi(const char *s)
{
     cea:	1141                	addi	sp,sp,-16
     cec:	e422                	sd	s0,8(sp)
     cee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     cf0:	00054603          	lbu	a2,0(a0)
     cf4:	fd06079b          	addiw	a5,a2,-48
     cf8:	0ff7f793          	andi	a5,a5,255
     cfc:	4725                	li	a4,9
     cfe:	02f76963          	bltu	a4,a5,d30 <atoi+0x46>
     d02:	86aa                	mv	a3,a0
  n = 0;
     d04:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d06:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d08:	0685                	addi	a3,a3,1
     d0a:	0025179b          	slliw	a5,a0,0x2
     d0e:	9fa9                	addw	a5,a5,a0
     d10:	0017979b          	slliw	a5,a5,0x1
     d14:	9fb1                	addw	a5,a5,a2
     d16:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d1a:	0006c603          	lbu	a2,0(a3)
     d1e:	fd06071b          	addiw	a4,a2,-48
     d22:	0ff77713          	andi	a4,a4,255
     d26:	fee5f1e3          	bgeu	a1,a4,d08 <atoi+0x1e>
  return n;
}
     d2a:	6422                	ld	s0,8(sp)
     d2c:	0141                	addi	sp,sp,16
     d2e:	8082                	ret
  n = 0;
     d30:	4501                	li	a0,0
     d32:	bfe5                	j	d2a <atoi+0x40>

0000000000000d34 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d34:	1141                	addi	sp,sp,-16
     d36:	e422                	sd	s0,8(sp)
     d38:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d3a:	02b57663          	bgeu	a0,a1,d66 <memmove+0x32>
    while(n-- > 0)
     d3e:	02c05163          	blez	a2,d60 <memmove+0x2c>
     d42:	fff6079b          	addiw	a5,a2,-1
     d46:	1782                	slli	a5,a5,0x20
     d48:	9381                	srli	a5,a5,0x20
     d4a:	0785                	addi	a5,a5,1
     d4c:	97aa                	add	a5,a5,a0
  dst = vdst;
     d4e:	872a                	mv	a4,a0
      *dst++ = *src++;
     d50:	0585                	addi	a1,a1,1
     d52:	0705                	addi	a4,a4,1
     d54:	fff5c683          	lbu	a3,-1(a1)
     d58:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     d5c:	fee79ae3          	bne	a5,a4,d50 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     d60:	6422                	ld	s0,8(sp)
     d62:	0141                	addi	sp,sp,16
     d64:	8082                	ret
    dst += n;
     d66:	00c50733          	add	a4,a0,a2
    src += n;
     d6a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     d6c:	fec05ae3          	blez	a2,d60 <memmove+0x2c>
     d70:	fff6079b          	addiw	a5,a2,-1
     d74:	1782                	slli	a5,a5,0x20
     d76:	9381                	srli	a5,a5,0x20
     d78:	fff7c793          	not	a5,a5
     d7c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     d7e:	15fd                	addi	a1,a1,-1
     d80:	177d                	addi	a4,a4,-1
     d82:	0005c683          	lbu	a3,0(a1)
     d86:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     d8a:	fee79ae3          	bne	a5,a4,d7e <memmove+0x4a>
     d8e:	bfc9                	j	d60 <memmove+0x2c>

0000000000000d90 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     d90:	1141                	addi	sp,sp,-16
     d92:	e422                	sd	s0,8(sp)
     d94:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     d96:	ca05                	beqz	a2,dc6 <memcmp+0x36>
     d98:	fff6069b          	addiw	a3,a2,-1
     d9c:	1682                	slli	a3,a3,0x20
     d9e:	9281                	srli	a3,a3,0x20
     da0:	0685                	addi	a3,a3,1
     da2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     da4:	00054783          	lbu	a5,0(a0)
     da8:	0005c703          	lbu	a4,0(a1)
     dac:	00e79863          	bne	a5,a4,dbc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     db0:	0505                	addi	a0,a0,1
    p2++;
     db2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     db4:	fed518e3          	bne	a0,a3,da4 <memcmp+0x14>
  }
  return 0;
     db8:	4501                	li	a0,0
     dba:	a019                	j	dc0 <memcmp+0x30>
      return *p1 - *p2;
     dbc:	40e7853b          	subw	a0,a5,a4
}
     dc0:	6422                	ld	s0,8(sp)
     dc2:	0141                	addi	sp,sp,16
     dc4:	8082                	ret
  return 0;
     dc6:	4501                	li	a0,0
     dc8:	bfe5                	j	dc0 <memcmp+0x30>

0000000000000dca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     dca:	1141                	addi	sp,sp,-16
     dcc:	e406                	sd	ra,8(sp)
     dce:	e022                	sd	s0,0(sp)
     dd0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     dd2:	00000097          	auipc	ra,0x0
     dd6:	f62080e7          	jalr	-158(ra) # d34 <memmove>
}
     dda:	60a2                	ld	ra,8(sp)
     ddc:	6402                	ld	s0,0(sp)
     dde:	0141                	addi	sp,sp,16
     de0:	8082                	ret

0000000000000de2 <close>:

int close(int fd){
     de2:	1101                	addi	sp,sp,-32
     de4:	ec06                	sd	ra,24(sp)
     de6:	e822                	sd	s0,16(sp)
     de8:	e426                	sd	s1,8(sp)
     dea:	1000                	addi	s0,sp,32
     dec:	84aa                	mv	s1,a0
  fflush(fd);
     dee:	00000097          	auipc	ra,0x0
     df2:	2d4080e7          	jalr	724(ra) # 10c2 <fflush>
  char* buf = get_putc_buf(fd);
     df6:	8526                	mv	a0,s1
     df8:	00000097          	auipc	ra,0x0
     dfc:	14e080e7          	jalr	334(ra) # f46 <get_putc_buf>
  if(buf){
     e00:	cd11                	beqz	a0,e1c <close+0x3a>
    free(buf);
     e02:	00000097          	auipc	ra,0x0
     e06:	546080e7          	jalr	1350(ra) # 1348 <free>
    putc_buf[fd] = 0;
     e0a:	00349713          	slli	a4,s1,0x3
     e0e:	00001797          	auipc	a5,0x1
     e12:	8ba78793          	addi	a5,a5,-1862 # 16c8 <putc_buf>
     e16:	97ba                	add	a5,a5,a4
     e18:	0007b023          	sd	zero,0(a5)
  }
  return sclose(fd);
     e1c:	8526                	mv	a0,s1
     e1e:	00000097          	auipc	ra,0x0
     e22:	088080e7          	jalr	136(ra) # ea6 <sclose>
}
     e26:	60e2                	ld	ra,24(sp)
     e28:	6442                	ld	s0,16(sp)
     e2a:	64a2                	ld	s1,8(sp)
     e2c:	6105                	addi	sp,sp,32
     e2e:	8082                	ret

0000000000000e30 <stat>:
{
     e30:	1101                	addi	sp,sp,-32
     e32:	ec06                	sd	ra,24(sp)
     e34:	e822                	sd	s0,16(sp)
     e36:	e426                	sd	s1,8(sp)
     e38:	e04a                	sd	s2,0(sp)
     e3a:	1000                	addi	s0,sp,32
     e3c:	892e                	mv	s2,a1
  fd = open(n, O_RDONLY);
     e3e:	4581                	li	a1,0
     e40:	00000097          	auipc	ra,0x0
     e44:	07e080e7          	jalr	126(ra) # ebe <open>
  if(fd < 0)
     e48:	02054563          	bltz	a0,e72 <stat+0x42>
     e4c:	84aa                	mv	s1,a0
  r = fstat(fd, st);
     e4e:	85ca                	mv	a1,s2
     e50:	00000097          	auipc	ra,0x0
     e54:	086080e7          	jalr	134(ra) # ed6 <fstat>
     e58:	892a                	mv	s2,a0
  close(fd);
     e5a:	8526                	mv	a0,s1
     e5c:	00000097          	auipc	ra,0x0
     e60:	f86080e7          	jalr	-122(ra) # de2 <close>
}
     e64:	854a                	mv	a0,s2
     e66:	60e2                	ld	ra,24(sp)
     e68:	6442                	ld	s0,16(sp)
     e6a:	64a2                	ld	s1,8(sp)
     e6c:	6902                	ld	s2,0(sp)
     e6e:	6105                	addi	sp,sp,32
     e70:	8082                	ret
    return -1;
     e72:	597d                	li	s2,-1
     e74:	bfc5                	j	e64 <stat+0x34>

0000000000000e76 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e76:	4885                	li	a7,1
 ecall
     e78:	00000073          	ecall
 ret
     e7c:	8082                	ret

0000000000000e7e <exit>:
.global exit
exit:
 li a7, SYS_exit
     e7e:	4889                	li	a7,2
 ecall
     e80:	00000073          	ecall
 ret
     e84:	8082                	ret

0000000000000e86 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e86:	488d                	li	a7,3
 ecall
     e88:	00000073          	ecall
 ret
     e8c:	8082                	ret

0000000000000e8e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e8e:	4891                	li	a7,4
 ecall
     e90:	00000073          	ecall
 ret
     e94:	8082                	ret

0000000000000e96 <read>:
.global read
read:
 li a7, SYS_read
     e96:	4895                	li	a7,5
 ecall
     e98:	00000073          	ecall
 ret
     e9c:	8082                	ret

0000000000000e9e <write>:
.global write
write:
 li a7, SYS_write
     e9e:	48c1                	li	a7,16
 ecall
     ea0:	00000073          	ecall
 ret
     ea4:	8082                	ret

0000000000000ea6 <sclose>:
.global sclose
sclose:
 li a7, SYS_close
     ea6:	48d5                	li	a7,21
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <kill>:
.global kill
kill:
 li a7, SYS_kill
     eae:	4899                	li	a7,6
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <exec>:
.global exec
exec:
 li a7, SYS_exec
     eb6:	489d                	li	a7,7
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <open>:
.global open
open:
 li a7, SYS_open
     ebe:	48bd                	li	a7,15
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ec6:	48c5                	li	a7,17
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ece:	48c9                	li	a7,18
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ed6:	48a1                	li	a7,8
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <link>:
.global link
link:
 li a7, SYS_link
     ede:	48cd                	li	a7,19
 ecall
     ee0:	00000073          	ecall
 ret
     ee4:	8082                	ret

0000000000000ee6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     ee6:	48d1                	li	a7,20
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     eee:	48a5                	li	a7,9
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ef6:	48a9                	li	a7,10
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     efe:	48ad                	li	a7,11
 ecall
     f00:	00000073          	ecall
 ret
     f04:	8082                	ret

0000000000000f06 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f06:	48b1                	li	a7,12
 ecall
     f08:	00000073          	ecall
 ret
     f0c:	8082                	ret

0000000000000f0e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f0e:	48b5                	li	a7,13
 ecall
     f10:	00000073          	ecall
 ret
     f14:	8082                	ret

0000000000000f16 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f16:	48b9                	li	a7,14
 ecall
     f18:	00000073          	ecall
 ret
     f1c:	8082                	ret

0000000000000f1e <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
     f1e:	48d9                	li	a7,22
 ecall
     f20:	00000073          	ecall
 ret
     f24:	8082                	ret

0000000000000f26 <nice>:
.global nice
nice:
 li a7, SYS_nice
     f26:	48dd                	li	a7,23
 ecall
     f28:	00000073          	ecall
 ret
     f2c:	8082                	ret

0000000000000f2e <create_mutex>:
.global create_mutex
create_mutex:
 li a7, SYS_create_mutex
     f2e:	48e1                	li	a7,24
 ecall
     f30:	00000073          	ecall
 ret
     f34:	8082                	ret

0000000000000f36 <acquire_mutex>:
.global acquire_mutex
acquire_mutex:
 li a7, SYS_acquire_mutex
     f36:	48e5                	li	a7,25
 ecall
     f38:	00000073          	ecall
 ret
     f3c:	8082                	ret

0000000000000f3e <release_mutex>:
.global release_mutex
release_mutex:
 li a7, SYS_release_mutex
     f3e:	48e9                	li	a7,26
 ecall
     f40:	00000073          	ecall
 ret
     f44:	8082                	ret

0000000000000f46 <get_putc_buf>:
static char digits[] = "0123456789ABCDEF";

char* putc_buf[NFILE];
int putc_index[NFILE];

char* get_putc_buf(int fd){
     f46:	1101                	addi	sp,sp,-32
     f48:	ec06                	sd	ra,24(sp)
     f4a:	e822                	sd	s0,16(sp)
     f4c:	e426                	sd	s1,8(sp)
     f4e:	1000                	addi	s0,sp,32
     f50:	84aa                	mv	s1,a0
  char* buf = putc_buf[fd];
     f52:	00351713          	slli	a4,a0,0x3
     f56:	00000797          	auipc	a5,0x0
     f5a:	77278793          	addi	a5,a5,1906 # 16c8 <putc_buf>
     f5e:	97ba                	add	a5,a5,a4
     f60:	6388                	ld	a0,0(a5)
  if(buf) {
     f62:	c511                	beqz	a0,f6e <get_putc_buf+0x28>
  }
  buf = malloc(PUTC_BUF_LEN);
  putc_buf[fd] = buf;
  putc_index[fd] = 0;
  return buf;
}
     f64:	60e2                	ld	ra,24(sp)
     f66:	6442                	ld	s0,16(sp)
     f68:	64a2                	ld	s1,8(sp)
     f6a:	6105                	addi	sp,sp,32
     f6c:	8082                	ret
  buf = malloc(PUTC_BUF_LEN);
     f6e:	6505                	lui	a0,0x1
     f70:	00000097          	auipc	ra,0x0
     f74:	460080e7          	jalr	1120(ra) # 13d0 <malloc>
  putc_buf[fd] = buf;
     f78:	00000797          	auipc	a5,0x0
     f7c:	75078793          	addi	a5,a5,1872 # 16c8 <putc_buf>
     f80:	00349713          	slli	a4,s1,0x3
     f84:	973e                	add	a4,a4,a5
     f86:	e308                	sd	a0,0(a4)
  putc_index[fd] = 0;
     f88:	048a                	slli	s1,s1,0x2
     f8a:	94be                	add	s1,s1,a5
     f8c:	3204a023          	sw	zero,800(s1)
  return buf;
     f90:	bfd1                	j	f64 <get_putc_buf+0x1e>

0000000000000f92 <putc>:

static void
putc(int fd, char c)
{
     f92:	1101                	addi	sp,sp,-32
     f94:	ec06                	sd	ra,24(sp)
     f96:	e822                	sd	s0,16(sp)
     f98:	e426                	sd	s1,8(sp)
     f9a:	e04a                	sd	s2,0(sp)
     f9c:	1000                	addi	s0,sp,32
     f9e:	84aa                	mv	s1,a0
     fa0:	892e                	mv	s2,a1
  char* buf = get_putc_buf(fd);
     fa2:	00000097          	auipc	ra,0x0
     fa6:	fa4080e7          	jalr	-92(ra) # f46 <get_putc_buf>
  buf[putc_index[fd]++] = c;
     faa:	00249793          	slli	a5,s1,0x2
     fae:	00000717          	auipc	a4,0x0
     fb2:	71a70713          	addi	a4,a4,1818 # 16c8 <putc_buf>
     fb6:	973e                	add	a4,a4,a5
     fb8:	32072783          	lw	a5,800(a4)
     fbc:	0017869b          	addiw	a3,a5,1
     fc0:	32d72023          	sw	a3,800(a4)
     fc4:	97aa                	add	a5,a5,a0
     fc6:	01278023          	sb	s2,0(a5)
  if(c == '\n' || putc_index[fd] == PUTC_BUF_LEN){
     fca:	47a9                	li	a5,10
     fcc:	02f90463          	beq	s2,a5,ff4 <putc+0x62>
     fd0:	00249713          	slli	a4,s1,0x2
     fd4:	00000797          	auipc	a5,0x0
     fd8:	6f478793          	addi	a5,a5,1780 # 16c8 <putc_buf>
     fdc:	97ba                	add	a5,a5,a4
     fde:	3207a703          	lw	a4,800(a5)
     fe2:	6785                	lui	a5,0x1
     fe4:	00f70863          	beq	a4,a5,ff4 <putc+0x62>
    write(fd, buf, putc_index[fd]);
    putc_index[fd] = 0;
  }
  //write(fd, &c, 1);
}
     fe8:	60e2                	ld	ra,24(sp)
     fea:	6442                	ld	s0,16(sp)
     fec:	64a2                	ld	s1,8(sp)
     fee:	6902                	ld	s2,0(sp)
     ff0:	6105                	addi	sp,sp,32
     ff2:	8082                	ret
    write(fd, buf, putc_index[fd]);
     ff4:	00249793          	slli	a5,s1,0x2
     ff8:	00000917          	auipc	s2,0x0
     ffc:	6d090913          	addi	s2,s2,1744 # 16c8 <putc_buf>
    1000:	993e                	add	s2,s2,a5
    1002:	32092603          	lw	a2,800(s2)
    1006:	85aa                	mv	a1,a0
    1008:	8526                	mv	a0,s1
    100a:	00000097          	auipc	ra,0x0
    100e:	e94080e7          	jalr	-364(ra) # e9e <write>
    putc_index[fd] = 0;
    1012:	32092023          	sw	zero,800(s2)
}
    1016:	bfc9                	j	fe8 <putc+0x56>

0000000000001018 <printint>:
  putc_index[fd] = 0;
}

static void
printint(int fd, int xx, int base, int sgn)
{
    1018:	7139                	addi	sp,sp,-64
    101a:	fc06                	sd	ra,56(sp)
    101c:	f822                	sd	s0,48(sp)
    101e:	f426                	sd	s1,40(sp)
    1020:	f04a                	sd	s2,32(sp)
    1022:	ec4e                	sd	s3,24(sp)
    1024:	0080                	addi	s0,sp,64
    1026:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    1028:	c299                	beqz	a3,102e <printint+0x16>
    102a:	0805c863          	bltz	a1,10ba <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    102e:	2581                	sext.w	a1,a1
  neg = 0;
    1030:	4881                	li	a7,0
    1032:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    1036:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    1038:	2601                	sext.w	a2,a2
    103a:	00000517          	auipc	a0,0x0
    103e:	5f650513          	addi	a0,a0,1526 # 1630 <digits>
    1042:	883a                	mv	a6,a4
    1044:	2705                	addiw	a4,a4,1
    1046:	02c5f7bb          	remuw	a5,a1,a2
    104a:	1782                	slli	a5,a5,0x20
    104c:	9381                	srli	a5,a5,0x20
    104e:	97aa                	add	a5,a5,a0
    1050:	0007c783          	lbu	a5,0(a5) # 1000 <putc+0x6e>
    1054:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    1058:	0005879b          	sext.w	a5,a1
    105c:	02c5d5bb          	divuw	a1,a1,a2
    1060:	0685                	addi	a3,a3,1
    1062:	fec7f0e3          	bgeu	a5,a2,1042 <printint+0x2a>
  if(neg)
    1066:	00088b63          	beqz	a7,107c <printint+0x64>
    buf[i++] = '-';
    106a:	fd040793          	addi	a5,s0,-48
    106e:	973e                	add	a4,a4,a5
    1070:	02d00793          	li	a5,45
    1074:	fef70823          	sb	a5,-16(a4)
    1078:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    107c:	02e05863          	blez	a4,10ac <printint+0x94>
    1080:	fc040793          	addi	a5,s0,-64
    1084:	00e78933          	add	s2,a5,a4
    1088:	fff78993          	addi	s3,a5,-1
    108c:	99ba                	add	s3,s3,a4
    108e:	377d                	addiw	a4,a4,-1
    1090:	1702                	slli	a4,a4,0x20
    1092:	9301                	srli	a4,a4,0x20
    1094:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1098:	fff94583          	lbu	a1,-1(s2)
    109c:	8526                	mv	a0,s1
    109e:	00000097          	auipc	ra,0x0
    10a2:	ef4080e7          	jalr	-268(ra) # f92 <putc>
  while(--i >= 0)
    10a6:	197d                	addi	s2,s2,-1
    10a8:	ff3918e3          	bne	s2,s3,1098 <printint+0x80>
}
    10ac:	70e2                	ld	ra,56(sp)
    10ae:	7442                	ld	s0,48(sp)
    10b0:	74a2                	ld	s1,40(sp)
    10b2:	7902                	ld	s2,32(sp)
    10b4:	69e2                	ld	s3,24(sp)
    10b6:	6121                	addi	sp,sp,64
    10b8:	8082                	ret
    x = -xx;
    10ba:	40b005bb          	negw	a1,a1
    neg = 1;
    10be:	4885                	li	a7,1
    x = -xx;
    10c0:	bf8d                	j	1032 <printint+0x1a>

00000000000010c2 <fflush>:
void fflush(int fd){
    10c2:	1101                	addi	sp,sp,-32
    10c4:	ec06                	sd	ra,24(sp)
    10c6:	e822                	sd	s0,16(sp)
    10c8:	e426                	sd	s1,8(sp)
    10ca:	e04a                	sd	s2,0(sp)
    10cc:	1000                	addi	s0,sp,32
    10ce:	892a                	mv	s2,a0
  char* buf = get_putc_buf(fd);
    10d0:	00000097          	auipc	ra,0x0
    10d4:	e76080e7          	jalr	-394(ra) # f46 <get_putc_buf>
    10d8:	85aa                	mv	a1,a0
  write(fd, buf, putc_index[fd]);
    10da:	00291793          	slli	a5,s2,0x2
    10de:	00000497          	auipc	s1,0x0
    10e2:	5ea48493          	addi	s1,s1,1514 # 16c8 <putc_buf>
    10e6:	94be                	add	s1,s1,a5
    10e8:	3204a603          	lw	a2,800(s1)
    10ec:	854a                	mv	a0,s2
    10ee:	00000097          	auipc	ra,0x0
    10f2:	db0080e7          	jalr	-592(ra) # e9e <write>
  putc_index[fd] = 0;
    10f6:	3204a023          	sw	zero,800(s1)
}
    10fa:	60e2                	ld	ra,24(sp)
    10fc:	6442                	ld	s0,16(sp)
    10fe:	64a2                	ld	s1,8(sp)
    1100:	6902                	ld	s2,0(sp)
    1102:	6105                	addi	sp,sp,32
    1104:	8082                	ret

0000000000001106 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1106:	7119                	addi	sp,sp,-128
    1108:	fc86                	sd	ra,120(sp)
    110a:	f8a2                	sd	s0,112(sp)
    110c:	f4a6                	sd	s1,104(sp)
    110e:	f0ca                	sd	s2,96(sp)
    1110:	ecce                	sd	s3,88(sp)
    1112:	e8d2                	sd	s4,80(sp)
    1114:	e4d6                	sd	s5,72(sp)
    1116:	e0da                	sd	s6,64(sp)
    1118:	fc5e                	sd	s7,56(sp)
    111a:	f862                	sd	s8,48(sp)
    111c:	f466                	sd	s9,40(sp)
    111e:	f06a                	sd	s10,32(sp)
    1120:	ec6e                	sd	s11,24(sp)
    1122:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1124:	0005c903          	lbu	s2,0(a1)
    1128:	18090f63          	beqz	s2,12c6 <vprintf+0x1c0>
    112c:	8aaa                	mv	s5,a0
    112e:	8b32                	mv	s6,a2
    1130:	00158493          	addi	s1,a1,1
  state = 0;
    1134:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1136:	02500a13          	li	s4,37
      if(c == 'd'){
    113a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    113e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1142:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    1146:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    114a:	00000b97          	auipc	s7,0x0
    114e:	4e6b8b93          	addi	s7,s7,1254 # 1630 <digits>
    1152:	a839                	j	1170 <vprintf+0x6a>
        putc(fd, c);
    1154:	85ca                	mv	a1,s2
    1156:	8556                	mv	a0,s5
    1158:	00000097          	auipc	ra,0x0
    115c:	e3a080e7          	jalr	-454(ra) # f92 <putc>
    1160:	a019                	j	1166 <vprintf+0x60>
    } else if(state == '%'){
    1162:	01498f63          	beq	s3,s4,1180 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1166:	0485                	addi	s1,s1,1
    1168:	fff4c903          	lbu	s2,-1(s1)
    116c:	14090d63          	beqz	s2,12c6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1170:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1174:	fe0997e3          	bnez	s3,1162 <vprintf+0x5c>
      if(c == '%'){
    1178:	fd479ee3          	bne	a5,s4,1154 <vprintf+0x4e>
        state = '%';
    117c:	89be                	mv	s3,a5
    117e:	b7e5                	j	1166 <vprintf+0x60>
      if(c == 'd'){
    1180:	05878063          	beq	a5,s8,11c0 <vprintf+0xba>
      } else if(c == 'l') {
    1184:	05978c63          	beq	a5,s9,11dc <vprintf+0xd6>
      } else if(c == 'x') {
    1188:	07a78863          	beq	a5,s10,11f8 <vprintf+0xf2>
      } else if(c == 'p') {
    118c:	09b78463          	beq	a5,s11,1214 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1190:	07300713          	li	a4,115
    1194:	0ce78663          	beq	a5,a4,1260 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1198:	06300713          	li	a4,99
    119c:	0ee78e63          	beq	a5,a4,1298 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    11a0:	11478863          	beq	a5,s4,12b0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    11a4:	85d2                	mv	a1,s4
    11a6:	8556                	mv	a0,s5
    11a8:	00000097          	auipc	ra,0x0
    11ac:	dea080e7          	jalr	-534(ra) # f92 <putc>
        putc(fd, c);
    11b0:	85ca                	mv	a1,s2
    11b2:	8556                	mv	a0,s5
    11b4:	00000097          	auipc	ra,0x0
    11b8:	dde080e7          	jalr	-546(ra) # f92 <putc>
      }
      state = 0;
    11bc:	4981                	li	s3,0
    11be:	b765                	j	1166 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    11c0:	008b0913          	addi	s2,s6,8
    11c4:	4685                	li	a3,1
    11c6:	4629                	li	a2,10
    11c8:	000b2583          	lw	a1,0(s6)
    11cc:	8556                	mv	a0,s5
    11ce:	00000097          	auipc	ra,0x0
    11d2:	e4a080e7          	jalr	-438(ra) # 1018 <printint>
    11d6:	8b4a                	mv	s6,s2
      state = 0;
    11d8:	4981                	li	s3,0
    11da:	b771                	j	1166 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    11dc:	008b0913          	addi	s2,s6,8
    11e0:	4681                	li	a3,0
    11e2:	4629                	li	a2,10
    11e4:	000b2583          	lw	a1,0(s6)
    11e8:	8556                	mv	a0,s5
    11ea:	00000097          	auipc	ra,0x0
    11ee:	e2e080e7          	jalr	-466(ra) # 1018 <printint>
    11f2:	8b4a                	mv	s6,s2
      state = 0;
    11f4:	4981                	li	s3,0
    11f6:	bf85                	j	1166 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    11f8:	008b0913          	addi	s2,s6,8
    11fc:	4681                	li	a3,0
    11fe:	4641                	li	a2,16
    1200:	000b2583          	lw	a1,0(s6)
    1204:	8556                	mv	a0,s5
    1206:	00000097          	auipc	ra,0x0
    120a:	e12080e7          	jalr	-494(ra) # 1018 <printint>
    120e:	8b4a                	mv	s6,s2
      state = 0;
    1210:	4981                	li	s3,0
    1212:	bf91                	j	1166 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1214:	008b0793          	addi	a5,s6,8
    1218:	f8f43423          	sd	a5,-120(s0)
    121c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1220:	03000593          	li	a1,48
    1224:	8556                	mv	a0,s5
    1226:	00000097          	auipc	ra,0x0
    122a:	d6c080e7          	jalr	-660(ra) # f92 <putc>
  putc(fd, 'x');
    122e:	85ea                	mv	a1,s10
    1230:	8556                	mv	a0,s5
    1232:	00000097          	auipc	ra,0x0
    1236:	d60080e7          	jalr	-672(ra) # f92 <putc>
    123a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    123c:	03c9d793          	srli	a5,s3,0x3c
    1240:	97de                	add	a5,a5,s7
    1242:	0007c583          	lbu	a1,0(a5)
    1246:	8556                	mv	a0,s5
    1248:	00000097          	auipc	ra,0x0
    124c:	d4a080e7          	jalr	-694(ra) # f92 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1250:	0992                	slli	s3,s3,0x4
    1252:	397d                	addiw	s2,s2,-1
    1254:	fe0914e3          	bnez	s2,123c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1258:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    125c:	4981                	li	s3,0
    125e:	b721                	j	1166 <vprintf+0x60>
        s = va_arg(ap, char*);
    1260:	008b0993          	addi	s3,s6,8
    1264:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    1268:	02090163          	beqz	s2,128a <vprintf+0x184>
        while(*s != 0){
    126c:	00094583          	lbu	a1,0(s2)
    1270:	c9a1                	beqz	a1,12c0 <vprintf+0x1ba>
          putc(fd, *s);
    1272:	8556                	mv	a0,s5
    1274:	00000097          	auipc	ra,0x0
    1278:	d1e080e7          	jalr	-738(ra) # f92 <putc>
          s++;
    127c:	0905                	addi	s2,s2,1
        while(*s != 0){
    127e:	00094583          	lbu	a1,0(s2)
    1282:	f9e5                	bnez	a1,1272 <vprintf+0x16c>
        s = va_arg(ap, char*);
    1284:	8b4e                	mv	s6,s3
      state = 0;
    1286:	4981                	li	s3,0
    1288:	bdf9                	j	1166 <vprintf+0x60>
          s = "(null)";
    128a:	00000917          	auipc	s2,0x0
    128e:	39e90913          	addi	s2,s2,926 # 1628 <malloc+0x258>
        while(*s != 0){
    1292:	02800593          	li	a1,40
    1296:	bff1                	j	1272 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    1298:	008b0913          	addi	s2,s6,8
    129c:	000b4583          	lbu	a1,0(s6)
    12a0:	8556                	mv	a0,s5
    12a2:	00000097          	auipc	ra,0x0
    12a6:	cf0080e7          	jalr	-784(ra) # f92 <putc>
    12aa:	8b4a                	mv	s6,s2
      state = 0;
    12ac:	4981                	li	s3,0
    12ae:	bd65                	j	1166 <vprintf+0x60>
        putc(fd, c);
    12b0:	85d2                	mv	a1,s4
    12b2:	8556                	mv	a0,s5
    12b4:	00000097          	auipc	ra,0x0
    12b8:	cde080e7          	jalr	-802(ra) # f92 <putc>
      state = 0;
    12bc:	4981                	li	s3,0
    12be:	b565                	j	1166 <vprintf+0x60>
        s = va_arg(ap, char*);
    12c0:	8b4e                	mv	s6,s3
      state = 0;
    12c2:	4981                	li	s3,0
    12c4:	b54d                	j	1166 <vprintf+0x60>
    }
  }
}
    12c6:	70e6                	ld	ra,120(sp)
    12c8:	7446                	ld	s0,112(sp)
    12ca:	74a6                	ld	s1,104(sp)
    12cc:	7906                	ld	s2,96(sp)
    12ce:	69e6                	ld	s3,88(sp)
    12d0:	6a46                	ld	s4,80(sp)
    12d2:	6aa6                	ld	s5,72(sp)
    12d4:	6b06                	ld	s6,64(sp)
    12d6:	7be2                	ld	s7,56(sp)
    12d8:	7c42                	ld	s8,48(sp)
    12da:	7ca2                	ld	s9,40(sp)
    12dc:	7d02                	ld	s10,32(sp)
    12de:	6de2                	ld	s11,24(sp)
    12e0:	6109                	addi	sp,sp,128
    12e2:	8082                	ret

00000000000012e4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    12e4:	715d                	addi	sp,sp,-80
    12e6:	ec06                	sd	ra,24(sp)
    12e8:	e822                	sd	s0,16(sp)
    12ea:	1000                	addi	s0,sp,32
    12ec:	e010                	sd	a2,0(s0)
    12ee:	e414                	sd	a3,8(s0)
    12f0:	e818                	sd	a4,16(s0)
    12f2:	ec1c                	sd	a5,24(s0)
    12f4:	03043023          	sd	a6,32(s0)
    12f8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    12fc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1300:	8622                	mv	a2,s0
    1302:	00000097          	auipc	ra,0x0
    1306:	e04080e7          	jalr	-508(ra) # 1106 <vprintf>
}
    130a:	60e2                	ld	ra,24(sp)
    130c:	6442                	ld	s0,16(sp)
    130e:	6161                	addi	sp,sp,80
    1310:	8082                	ret

0000000000001312 <printf>:

void
printf(const char *fmt, ...)
{
    1312:	711d                	addi	sp,sp,-96
    1314:	ec06                	sd	ra,24(sp)
    1316:	e822                	sd	s0,16(sp)
    1318:	1000                	addi	s0,sp,32
    131a:	e40c                	sd	a1,8(s0)
    131c:	e810                	sd	a2,16(s0)
    131e:	ec14                	sd	a3,24(s0)
    1320:	f018                	sd	a4,32(s0)
    1322:	f41c                	sd	a5,40(s0)
    1324:	03043823          	sd	a6,48(s0)
    1328:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    132c:	00840613          	addi	a2,s0,8
    1330:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1334:	85aa                	mv	a1,a0
    1336:	4505                	li	a0,1
    1338:	00000097          	auipc	ra,0x0
    133c:	dce080e7          	jalr	-562(ra) # 1106 <vprintf>
}
    1340:	60e2                	ld	ra,24(sp)
    1342:	6442                	ld	s0,16(sp)
    1344:	6125                	addi	sp,sp,96
    1346:	8082                	ret

0000000000001348 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1348:	1141                	addi	sp,sp,-16
    134a:	e422                	sd	s0,8(sp)
    134c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    134e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1352:	00000797          	auipc	a5,0x0
    1356:	3067b783          	ld	a5,774(a5) # 1658 <freep>
    135a:	a805                	j	138a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    135c:	4618                	lw	a4,8(a2)
    135e:	9db9                	addw	a1,a1,a4
    1360:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1364:	6398                	ld	a4,0(a5)
    1366:	6318                	ld	a4,0(a4)
    1368:	fee53823          	sd	a4,-16(a0)
    136c:	a091                	j	13b0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    136e:	ff852703          	lw	a4,-8(a0)
    1372:	9e39                	addw	a2,a2,a4
    1374:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1376:	ff053703          	ld	a4,-16(a0)
    137a:	e398                	sd	a4,0(a5)
    137c:	a099                	j	13c2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    137e:	6398                	ld	a4,0(a5)
    1380:	00e7e463          	bltu	a5,a4,1388 <free+0x40>
    1384:	00e6ea63          	bltu	a3,a4,1398 <free+0x50>
{
    1388:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    138a:	fed7fae3          	bgeu	a5,a3,137e <free+0x36>
    138e:	6398                	ld	a4,0(a5)
    1390:	00e6e463          	bltu	a3,a4,1398 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1394:	fee7eae3          	bltu	a5,a4,1388 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1398:	ff852583          	lw	a1,-8(a0)
    139c:	6390                	ld	a2,0(a5)
    139e:	02059713          	slli	a4,a1,0x20
    13a2:	9301                	srli	a4,a4,0x20
    13a4:	0712                	slli	a4,a4,0x4
    13a6:	9736                	add	a4,a4,a3
    13a8:	fae60ae3          	beq	a2,a4,135c <free+0x14>
    bp->s.ptr = p->s.ptr;
    13ac:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    13b0:	4790                	lw	a2,8(a5)
    13b2:	02061713          	slli	a4,a2,0x20
    13b6:	9301                	srli	a4,a4,0x20
    13b8:	0712                	slli	a4,a4,0x4
    13ba:	973e                	add	a4,a4,a5
    13bc:	fae689e3          	beq	a3,a4,136e <free+0x26>
  } else
    p->s.ptr = bp;
    13c0:	e394                	sd	a3,0(a5)
  freep = p;
    13c2:	00000717          	auipc	a4,0x0
    13c6:	28f73b23          	sd	a5,662(a4) # 1658 <freep>
}
    13ca:	6422                	ld	s0,8(sp)
    13cc:	0141                	addi	sp,sp,16
    13ce:	8082                	ret

00000000000013d0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    13d0:	7139                	addi	sp,sp,-64
    13d2:	fc06                	sd	ra,56(sp)
    13d4:	f822                	sd	s0,48(sp)
    13d6:	f426                	sd	s1,40(sp)
    13d8:	f04a                	sd	s2,32(sp)
    13da:	ec4e                	sd	s3,24(sp)
    13dc:	e852                	sd	s4,16(sp)
    13de:	e456                	sd	s5,8(sp)
    13e0:	e05a                	sd	s6,0(sp)
    13e2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    13e4:	02051493          	slli	s1,a0,0x20
    13e8:	9081                	srli	s1,s1,0x20
    13ea:	04bd                	addi	s1,s1,15
    13ec:	8091                	srli	s1,s1,0x4
    13ee:	0014899b          	addiw	s3,s1,1
    13f2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    13f4:	00000517          	auipc	a0,0x0
    13f8:	26453503          	ld	a0,612(a0) # 1658 <freep>
    13fc:	c515                	beqz	a0,1428 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1400:	4798                	lw	a4,8(a5)
    1402:	02977f63          	bgeu	a4,s1,1440 <malloc+0x70>
    1406:	8a4e                	mv	s4,s3
    1408:	0009871b          	sext.w	a4,s3
    140c:	6685                	lui	a3,0x1
    140e:	00d77363          	bgeu	a4,a3,1414 <malloc+0x44>
    1412:	6a05                	lui	s4,0x1
    1414:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1418:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    141c:	00000917          	auipc	s2,0x0
    1420:	23c90913          	addi	s2,s2,572 # 1658 <freep>
  if(p == (char*)-1)
    1424:	5afd                	li	s5,-1
    1426:	a88d                	j	1498 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    1428:	00000797          	auipc	a5,0x0
    142c:	75078793          	addi	a5,a5,1872 # 1b78 <base>
    1430:	00000717          	auipc	a4,0x0
    1434:	22f73423          	sd	a5,552(a4) # 1658 <freep>
    1438:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    143a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    143e:	b7e1                	j	1406 <malloc+0x36>
      if(p->s.size == nunits)
    1440:	02e48b63          	beq	s1,a4,1476 <malloc+0xa6>
        p->s.size -= nunits;
    1444:	4137073b          	subw	a4,a4,s3
    1448:	c798                	sw	a4,8(a5)
        p += p->s.size;
    144a:	1702                	slli	a4,a4,0x20
    144c:	9301                	srli	a4,a4,0x20
    144e:	0712                	slli	a4,a4,0x4
    1450:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1452:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1456:	00000717          	auipc	a4,0x0
    145a:	20a73123          	sd	a0,514(a4) # 1658 <freep>
      return (void*)(p + 1);
    145e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1462:	70e2                	ld	ra,56(sp)
    1464:	7442                	ld	s0,48(sp)
    1466:	74a2                	ld	s1,40(sp)
    1468:	7902                	ld	s2,32(sp)
    146a:	69e2                	ld	s3,24(sp)
    146c:	6a42                	ld	s4,16(sp)
    146e:	6aa2                	ld	s5,8(sp)
    1470:	6b02                	ld	s6,0(sp)
    1472:	6121                	addi	sp,sp,64
    1474:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1476:	6398                	ld	a4,0(a5)
    1478:	e118                	sd	a4,0(a0)
    147a:	bff1                	j	1456 <malloc+0x86>
  hp->s.size = nu;
    147c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1480:	0541                	addi	a0,a0,16
    1482:	00000097          	auipc	ra,0x0
    1486:	ec6080e7          	jalr	-314(ra) # 1348 <free>
  return freep;
    148a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    148e:	d971                	beqz	a0,1462 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1490:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1492:	4798                	lw	a4,8(a5)
    1494:	fa9776e3          	bgeu	a4,s1,1440 <malloc+0x70>
    if(p == freep)
    1498:	00093703          	ld	a4,0(s2)
    149c:	853e                	mv	a0,a5
    149e:	fef719e3          	bne	a4,a5,1490 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    14a2:	8552                	mv	a0,s4
    14a4:	00000097          	auipc	ra,0x0
    14a8:	a62080e7          	jalr	-1438(ra) # f06 <sbrk>
  if(p == (char*)-1)
    14ac:	fd5518e3          	bne	a0,s5,147c <malloc+0xac>
        return 0;
    14b0:	4501                	li	a0,0
    14b2:	bf45                	j	1462 <malloc+0x92>
