
user/_find:     file format elf64-littleriscv


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
int matchhere(char *re, char *text) {
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
int match(char *re, char *text) {
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

000000000000011a <find>:

void find(char *path, char *target) {
 11a:	d8010113          	addi	sp,sp,-640
 11e:	26113c23          	sd	ra,632(sp)
 122:	26813823          	sd	s0,624(sp)
 126:	26913423          	sd	s1,616(sp)
 12a:	27213023          	sd	s2,608(sp)
 12e:	25313c23          	sd	s3,600(sp)
 132:	25413823          	sd	s4,592(sp)
 136:	25513423          	sd	s5,584(sp)
 13a:	25613023          	sd	s6,576(sp)
 13e:	23713c23          	sd	s7,568(sp)
 142:	0500                	addi	s0,sp,640
 144:	892a                	mv	s2,a0
 146:	89ae                	mv	s3,a1
	char buf[512], *p;
	int fd;
	struct dirent de;
	struct stat st;

	if((fd = open(path, 0)) < 0){
 148:	4581                	li	a1,0
 14a:	00000097          	auipc	ra,0x0
 14e:	4dc080e7          	jalr	1244(ra) # 626 <open>
 152:	06054663          	bltz	a0,1be <find+0xa4>
 156:	84aa                	mv	s1,a0
		fprintf(2, "find: cannot open %s\n", path);
		return;
	}

	if(fstat(fd, &st) < 0){
 158:	d8840593          	addi	a1,s0,-632
 15c:	00000097          	auipc	ra,0x0
 160:	4e2080e7          	jalr	1250(ra) # 63e <fstat>
 164:	06054863          	bltz	a0,1d4 <find+0xba>
		fprintf(2, "find: cannot stat %s\n", path);
		close(fd);
		return;
	}

	switch(st.type){
 168:	d9041783          	lh	a5,-624(s0)
 16c:	0007869b          	sext.w	a3,a5
 170:	4705                	li	a4,1
 172:	08e68b63          	beq	a3,a4,208 <find+0xee>
 176:	4709                	li	a4,2
 178:	00e69963          	bne	a3,a4,18a <find+0x70>
	case T_FILE:
		if(match(target, path)) {
 17c:	85ca                	mv	a1,s2
 17e:	854e                	mv	a0,s3
 180:	00000097          	auipc	ra,0x0
 184:	f4c080e7          	jalr	-180(ra) # cc <match>
 188:	e535                	bnez	a0,1f4 <find+0xda>
				find(buf, target);
			}
		}
		break;
	}
	close(fd);
 18a:	8526                	mv	a0,s1
 18c:	00000097          	auipc	ra,0x0
 190:	482080e7          	jalr	1154(ra) # 60e <close>
}
 194:	27813083          	ld	ra,632(sp)
 198:	27013403          	ld	s0,624(sp)
 19c:	26813483          	ld	s1,616(sp)
 1a0:	26013903          	ld	s2,608(sp)
 1a4:	25813983          	ld	s3,600(sp)
 1a8:	25013a03          	ld	s4,592(sp)
 1ac:	24813a83          	ld	s5,584(sp)
 1b0:	24013b03          	ld	s6,576(sp)
 1b4:	23813b83          	ld	s7,568(sp)
 1b8:	28010113          	addi	sp,sp,640
 1bc:	8082                	ret
		fprintf(2, "find: cannot open %s\n", path);
 1be:	864a                	mv	a2,s2
 1c0:	00001597          	auipc	a1,0x1
 1c4:	94058593          	addi	a1,a1,-1728 # b00 <malloc+0xe4>
 1c8:	4509                	li	a0,2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	766080e7          	jalr	1894(ra) # 930 <fprintf>
		return;
 1d2:	b7c9                	j	194 <find+0x7a>
		fprintf(2, "find: cannot stat %s\n", path);
 1d4:	864a                	mv	a2,s2
 1d6:	00001597          	auipc	a1,0x1
 1da:	94258593          	addi	a1,a1,-1726 # b18 <malloc+0xfc>
 1de:	4509                	li	a0,2
 1e0:	00000097          	auipc	ra,0x0
 1e4:	750080e7          	jalr	1872(ra) # 930 <fprintf>
		close(fd);
 1e8:	8526                	mv	a0,s1
 1ea:	00000097          	auipc	ra,0x0
 1ee:	424080e7          	jalr	1060(ra) # 60e <close>
		return;
 1f2:	b74d                	j	194 <find+0x7a>
			printf("%s\n", path);
 1f4:	85ca                	mv	a1,s2
 1f6:	00001517          	auipc	a0,0x1
 1fa:	93a50513          	addi	a0,a0,-1734 # b30 <malloc+0x114>
 1fe:	00000097          	auipc	ra,0x0
 202:	760080e7          	jalr	1888(ra) # 95e <printf>
 206:	b751                	j	18a <find+0x70>
		if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 208:	854a                	mv	a0,s2
 20a:	00000097          	auipc	ra,0x0
 20e:	1b6080e7          	jalr	438(ra) # 3c0 <strlen>
 212:	2541                	addiw	a0,a0,16
 214:	20000793          	li	a5,512
 218:	00a7fb63          	bgeu	a5,a0,22e <find+0x114>
			printf("find: path too long\n");
 21c:	00001517          	auipc	a0,0x1
 220:	91c50513          	addi	a0,a0,-1764 # b38 <malloc+0x11c>
 224:	00000097          	auipc	ra,0x0
 228:	73a080e7          	jalr	1850(ra) # 95e <printf>
			break;
 22c:	bfb9                	j	18a <find+0x70>
		strcpy(buf, path);
 22e:	85ca                	mv	a1,s2
 230:	db040513          	addi	a0,s0,-592
 234:	00000097          	auipc	ra,0x0
 238:	144080e7          	jalr	324(ra) # 378 <strcpy>
		p = buf+strlen(buf);
 23c:	db040513          	addi	a0,s0,-592
 240:	00000097          	auipc	ra,0x0
 244:	180080e7          	jalr	384(ra) # 3c0 <strlen>
 248:	02051913          	slli	s2,a0,0x20
 24c:	02095913          	srli	s2,s2,0x20
 250:	db040793          	addi	a5,s0,-592
 254:	993e                	add	s2,s2,a5
		*p++ = '/';
 256:	00190a13          	addi	s4,s2,1
 25a:	02f00793          	li	a5,47
 25e:	00f90023          	sb	a5,0(s2)
			if(strcmp(buf+strlen(buf)-2, "/.") != 0 && strcmp(buf+strlen(buf)-3, "/..") != 0) {
 262:	00001a97          	auipc	s5,0x1
 266:	8eea8a93          	addi	s5,s5,-1810 # b50 <malloc+0x134>
 26a:	00001b97          	auipc	s7,0x1
 26e:	8eeb8b93          	addi	s7,s7,-1810 # b58 <malloc+0x13c>
				printf("find: cannot stat %s\n", buf);
 272:	00001b17          	auipc	s6,0x1
 276:	8a6b0b13          	addi	s6,s6,-1882 # b18 <malloc+0xfc>
		while(read(fd, &de, sizeof(de)) == sizeof(de)){
 27a:	4641                	li	a2,16
 27c:	da040593          	addi	a1,s0,-608
 280:	8526                	mv	a0,s1
 282:	00000097          	auipc	ra,0x0
 286:	37c080e7          	jalr	892(ra) # 5fe <read>
 28a:	47c1                	li	a5,16
 28c:	eef51fe3          	bne	a0,a5,18a <find+0x70>
			if(de.inum == 0)
 290:	da045783          	lhu	a5,-608(s0)
 294:	d3fd                	beqz	a5,27a <find+0x160>
			memmove(p, de.name, DIRSIZ);
 296:	4639                	li	a2,14
 298:	da240593          	addi	a1,s0,-606
 29c:	8552                	mv	a0,s4
 29e:	00000097          	auipc	ra,0x0
 2a2:	296080e7          	jalr	662(ra) # 534 <memmove>
			p[DIRSIZ] = 0;
 2a6:	000907a3          	sb	zero,15(s2)
			if(stat(buf, &st) < 0){
 2aa:	d8840593          	addi	a1,s0,-632
 2ae:	db040513          	addi	a0,s0,-592
 2b2:	00000097          	auipc	ra,0x0
 2b6:	1f2080e7          	jalr	498(ra) # 4a4 <stat>
 2ba:	04054e63          	bltz	a0,316 <find+0x1fc>
			if(strcmp(buf+strlen(buf)-2, "/.") != 0 && strcmp(buf+strlen(buf)-3, "/..") != 0) {
 2be:	db040513          	addi	a0,s0,-592
 2c2:	00000097          	auipc	ra,0x0
 2c6:	0fe080e7          	jalr	254(ra) # 3c0 <strlen>
 2ca:	1502                	slli	a0,a0,0x20
 2cc:	9101                	srli	a0,a0,0x20
 2ce:	1579                	addi	a0,a0,-2
 2d0:	85d6                	mv	a1,s5
 2d2:	db040793          	addi	a5,s0,-592
 2d6:	953e                	add	a0,a0,a5
 2d8:	00000097          	auipc	ra,0x0
 2dc:	0bc080e7          	jalr	188(ra) # 394 <strcmp>
 2e0:	dd49                	beqz	a0,27a <find+0x160>
 2e2:	db040513          	addi	a0,s0,-592
 2e6:	00000097          	auipc	ra,0x0
 2ea:	0da080e7          	jalr	218(ra) # 3c0 <strlen>
 2ee:	1502                	slli	a0,a0,0x20
 2f0:	9101                	srli	a0,a0,0x20
 2f2:	1575                	addi	a0,a0,-3
 2f4:	85de                	mv	a1,s7
 2f6:	db040793          	addi	a5,s0,-592
 2fa:	953e                	add	a0,a0,a5
 2fc:	00000097          	auipc	ra,0x0
 300:	098080e7          	jalr	152(ra) # 394 <strcmp>
 304:	d93d                	beqz	a0,27a <find+0x160>
				find(buf, target);
 306:	85ce                	mv	a1,s3
 308:	db040513          	addi	a0,s0,-592
 30c:	00000097          	auipc	ra,0x0
 310:	e0e080e7          	jalr	-498(ra) # 11a <find>
 314:	b79d                	j	27a <find+0x160>
				printf("find: cannot stat %s\n", buf);
 316:	db040593          	addi	a1,s0,-592
 31a:	855a                	mv	a0,s6
 31c:	00000097          	auipc	ra,0x0
 320:	642080e7          	jalr	1602(ra) # 95e <printf>
				continue;
 324:	bf99                	j	27a <find+0x160>

0000000000000326 <main>:

int main(int argc, char *argv[])
{
 326:	de010113          	addi	sp,sp,-544
 32a:	20113c23          	sd	ra,536(sp)
 32e:	20813823          	sd	s0,528(sp)
 332:	20913423          	sd	s1,520(sp)
 336:	1400                	addi	s0,sp,544
	if(argc < 3){
 338:	4789                	li	a5,2
 33a:	00a7c763          	blt	a5,a0,348 <main+0x22>
		exit(0);
 33e:	4501                	li	a0,0
 340:	00000097          	auipc	ra,0x0
 344:	2a6080e7          	jalr	678(ra) # 5e6 <exit>
 348:	84ae                	mv	s1,a1
	}
	char target[512];
	target[0] = '/';
 34a:	02f00793          	li	a5,47
 34e:	def40023          	sb	a5,-544(s0)
	strcpy(target+1, argv[2]);
 352:	698c                	ld	a1,16(a1)
 354:	de140513          	addi	a0,s0,-543
 358:	00000097          	auipc	ra,0x0
 35c:	020080e7          	jalr	32(ra) # 378 <strcpy>
	find(argv[1], target);
 360:	de040593          	addi	a1,s0,-544
 364:	6488                	ld	a0,8(s1)
 366:	00000097          	auipc	ra,0x0
 36a:	db4080e7          	jalr	-588(ra) # 11a <find>
	exit(0);
 36e:	4501                	li	a0,0
 370:	00000097          	auipc	ra,0x0
 374:	276080e7          	jalr	630(ra) # 5e6 <exit>

0000000000000378 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 378:	1141                	addi	sp,sp,-16
 37a:	e422                	sd	s0,8(sp)
 37c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 37e:	87aa                	mv	a5,a0
 380:	0585                	addi	a1,a1,1
 382:	0785                	addi	a5,a5,1
 384:	fff5c703          	lbu	a4,-1(a1)
 388:	fee78fa3          	sb	a4,-1(a5)
 38c:	fb75                	bnez	a4,380 <strcpy+0x8>
    ;
  return os;
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret

0000000000000394 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 394:	1141                	addi	sp,sp,-16
 396:	e422                	sd	s0,8(sp)
 398:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 39a:	00054783          	lbu	a5,0(a0)
 39e:	cb91                	beqz	a5,3b2 <strcmp+0x1e>
 3a0:	0005c703          	lbu	a4,0(a1)
 3a4:	00f71763          	bne	a4,a5,3b2 <strcmp+0x1e>
    p++, q++;
 3a8:	0505                	addi	a0,a0,1
 3aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3ac:	00054783          	lbu	a5,0(a0)
 3b0:	fbe5                	bnez	a5,3a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3b2:	0005c503          	lbu	a0,0(a1)
}
 3b6:	40a7853b          	subw	a0,a5,a0
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret

00000000000003c0 <strlen>:

uint
strlen(const char *s)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e422                	sd	s0,8(sp)
 3c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3c6:	00054783          	lbu	a5,0(a0)
 3ca:	cf91                	beqz	a5,3e6 <strlen+0x26>
 3cc:	0505                	addi	a0,a0,1
 3ce:	87aa                	mv	a5,a0
 3d0:	4685                	li	a3,1
 3d2:	9e89                	subw	a3,a3,a0
 3d4:	00f6853b          	addw	a0,a3,a5
 3d8:	0785                	addi	a5,a5,1
 3da:	fff7c703          	lbu	a4,-1(a5)
 3de:	fb7d                	bnez	a4,3d4 <strlen+0x14>
    ;
  return n;
}
 3e0:	6422                	ld	s0,8(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret
  for(n = 0; s[n]; n++)
 3e6:	4501                	li	a0,0
 3e8:	bfe5                	j	3e0 <strlen+0x20>

00000000000003ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e422                	sd	s0,8(sp)
 3ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3f0:	ca19                	beqz	a2,406 <memset+0x1c>
 3f2:	87aa                	mv	a5,a0
 3f4:	1602                	slli	a2,a2,0x20
 3f6:	9201                	srli	a2,a2,0x20
 3f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 400:	0785                	addi	a5,a5,1
 402:	fee79de3          	bne	a5,a4,3fc <memset+0x12>
  }
  return dst;
}
 406:	6422                	ld	s0,8(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret

000000000000040c <strchr>:

char*
strchr(const char *s, char c)
{
 40c:	1141                	addi	sp,sp,-16
 40e:	e422                	sd	s0,8(sp)
 410:	0800                	addi	s0,sp,16
  for(; *s; s++)
 412:	00054783          	lbu	a5,0(a0)
 416:	cb99                	beqz	a5,42c <strchr+0x20>
    if(*s == c)
 418:	00f58763          	beq	a1,a5,426 <strchr+0x1a>
  for(; *s; s++)
 41c:	0505                	addi	a0,a0,1
 41e:	00054783          	lbu	a5,0(a0)
 422:	fbfd                	bnez	a5,418 <strchr+0xc>
      return (char*)s;
  return 0;
 424:	4501                	li	a0,0
}
 426:	6422                	ld	s0,8(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret
  return 0;
 42c:	4501                	li	a0,0
 42e:	bfe5                	j	426 <strchr+0x1a>

0000000000000430 <gets>:

char*
gets(char *buf, int max)
{
 430:	711d                	addi	sp,sp,-96
 432:	ec86                	sd	ra,88(sp)
 434:	e8a2                	sd	s0,80(sp)
 436:	e4a6                	sd	s1,72(sp)
 438:	e0ca                	sd	s2,64(sp)
 43a:	fc4e                	sd	s3,56(sp)
 43c:	f852                	sd	s4,48(sp)
 43e:	f456                	sd	s5,40(sp)
 440:	f05a                	sd	s6,32(sp)
 442:	ec5e                	sd	s7,24(sp)
 444:	1080                	addi	s0,sp,96
 446:	8baa                	mv	s7,a0
 448:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 44a:	892a                	mv	s2,a0
 44c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 44e:	4aa9                	li	s5,10
 450:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 452:	89a6                	mv	s3,s1
 454:	2485                	addiw	s1,s1,1
 456:	0344d863          	bge	s1,s4,486 <gets+0x56>
    cc = read(0, &c, 1);
 45a:	4605                	li	a2,1
 45c:	faf40593          	addi	a1,s0,-81
 460:	4501                	li	a0,0
 462:	00000097          	auipc	ra,0x0
 466:	19c080e7          	jalr	412(ra) # 5fe <read>
    if(cc < 1)
 46a:	00a05e63          	blez	a0,486 <gets+0x56>
    buf[i++] = c;
 46e:	faf44783          	lbu	a5,-81(s0)
 472:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 476:	01578763          	beq	a5,s5,484 <gets+0x54>
 47a:	0905                	addi	s2,s2,1
 47c:	fd679be3          	bne	a5,s6,452 <gets+0x22>
  for(i=0; i+1 < max; ){
 480:	89a6                	mv	s3,s1
 482:	a011                	j	486 <gets+0x56>
 484:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 486:	99de                	add	s3,s3,s7
 488:	00098023          	sb	zero,0(s3)
  return buf;
}
 48c:	855e                	mv	a0,s7
 48e:	60e6                	ld	ra,88(sp)
 490:	6446                	ld	s0,80(sp)
 492:	64a6                	ld	s1,72(sp)
 494:	6906                	ld	s2,64(sp)
 496:	79e2                	ld	s3,56(sp)
 498:	7a42                	ld	s4,48(sp)
 49a:	7aa2                	ld	s5,40(sp)
 49c:	7b02                	ld	s6,32(sp)
 49e:	6be2                	ld	s7,24(sp)
 4a0:	6125                	addi	sp,sp,96
 4a2:	8082                	ret

00000000000004a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 4a4:	1101                	addi	sp,sp,-32
 4a6:	ec06                	sd	ra,24(sp)
 4a8:	e822                	sd	s0,16(sp)
 4aa:	e426                	sd	s1,8(sp)
 4ac:	e04a                	sd	s2,0(sp)
 4ae:	1000                	addi	s0,sp,32
 4b0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4b2:	4581                	li	a1,0
 4b4:	00000097          	auipc	ra,0x0
 4b8:	172080e7          	jalr	370(ra) # 626 <open>
  if(fd < 0)
 4bc:	02054563          	bltz	a0,4e6 <stat+0x42>
 4c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4c2:	85ca                	mv	a1,s2
 4c4:	00000097          	auipc	ra,0x0
 4c8:	17a080e7          	jalr	378(ra) # 63e <fstat>
 4cc:	892a                	mv	s2,a0
  close(fd);
 4ce:	8526                	mv	a0,s1
 4d0:	00000097          	auipc	ra,0x0
 4d4:	13e080e7          	jalr	318(ra) # 60e <close>
  return r;
}
 4d8:	854a                	mv	a0,s2
 4da:	60e2                	ld	ra,24(sp)
 4dc:	6442                	ld	s0,16(sp)
 4de:	64a2                	ld	s1,8(sp)
 4e0:	6902                	ld	s2,0(sp)
 4e2:	6105                	addi	sp,sp,32
 4e4:	8082                	ret
    return -1;
 4e6:	597d                	li	s2,-1
 4e8:	bfc5                	j	4d8 <stat+0x34>

00000000000004ea <atoi>:

int
atoi(const char *s)
{
 4ea:	1141                	addi	sp,sp,-16
 4ec:	e422                	sd	s0,8(sp)
 4ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4f0:	00054603          	lbu	a2,0(a0)
 4f4:	fd06079b          	addiw	a5,a2,-48
 4f8:	0ff7f793          	andi	a5,a5,255
 4fc:	4725                	li	a4,9
 4fe:	02f76963          	bltu	a4,a5,530 <atoi+0x46>
 502:	86aa                	mv	a3,a0
  n = 0;
 504:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 506:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 508:	0685                	addi	a3,a3,1
 50a:	0025179b          	slliw	a5,a0,0x2
 50e:	9fa9                	addw	a5,a5,a0
 510:	0017979b          	slliw	a5,a5,0x1
 514:	9fb1                	addw	a5,a5,a2
 516:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 51a:	0006c603          	lbu	a2,0(a3)
 51e:	fd06071b          	addiw	a4,a2,-48
 522:	0ff77713          	andi	a4,a4,255
 526:	fee5f1e3          	bgeu	a1,a4,508 <atoi+0x1e>
  return n;
}
 52a:	6422                	ld	s0,8(sp)
 52c:	0141                	addi	sp,sp,16
 52e:	8082                	ret
  n = 0;
 530:	4501                	li	a0,0
 532:	bfe5                	j	52a <atoi+0x40>

0000000000000534 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 534:	1141                	addi	sp,sp,-16
 536:	e422                	sd	s0,8(sp)
 538:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 53a:	02b57463          	bgeu	a0,a1,562 <memmove+0x2e>
    while(n-- > 0)
 53e:	00c05f63          	blez	a2,55c <memmove+0x28>
 542:	1602                	slli	a2,a2,0x20
 544:	9201                	srli	a2,a2,0x20
 546:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 54a:	872a                	mv	a4,a0
      *dst++ = *src++;
 54c:	0585                	addi	a1,a1,1
 54e:	0705                	addi	a4,a4,1
 550:	fff5c683          	lbu	a3,-1(a1)
 554:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 558:	fee79ae3          	bne	a5,a4,54c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 55c:	6422                	ld	s0,8(sp)
 55e:	0141                	addi	sp,sp,16
 560:	8082                	ret
    dst += n;
 562:	00c50733          	add	a4,a0,a2
    src += n;
 566:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 568:	fec05ae3          	blez	a2,55c <memmove+0x28>
 56c:	fff6079b          	addiw	a5,a2,-1
 570:	1782                	slli	a5,a5,0x20
 572:	9381                	srli	a5,a5,0x20
 574:	fff7c793          	not	a5,a5
 578:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 57a:	15fd                	addi	a1,a1,-1
 57c:	177d                	addi	a4,a4,-1
 57e:	0005c683          	lbu	a3,0(a1)
 582:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 586:	fee79ae3          	bne	a5,a4,57a <memmove+0x46>
 58a:	bfc9                	j	55c <memmove+0x28>

000000000000058c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 58c:	1141                	addi	sp,sp,-16
 58e:	e422                	sd	s0,8(sp)
 590:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 592:	ca05                	beqz	a2,5c2 <memcmp+0x36>
 594:	fff6069b          	addiw	a3,a2,-1
 598:	1682                	slli	a3,a3,0x20
 59a:	9281                	srli	a3,a3,0x20
 59c:	0685                	addi	a3,a3,1
 59e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 5a0:	00054783          	lbu	a5,0(a0)
 5a4:	0005c703          	lbu	a4,0(a1)
 5a8:	00e79863          	bne	a5,a4,5b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 5ac:	0505                	addi	a0,a0,1
    p2++;
 5ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 5b0:	fed518e3          	bne	a0,a3,5a0 <memcmp+0x14>
  }
  return 0;
 5b4:	4501                	li	a0,0
 5b6:	a019                	j	5bc <memcmp+0x30>
      return *p1 - *p2;
 5b8:	40e7853b          	subw	a0,a5,a4
}
 5bc:	6422                	ld	s0,8(sp)
 5be:	0141                	addi	sp,sp,16
 5c0:	8082                	ret
  return 0;
 5c2:	4501                	li	a0,0
 5c4:	bfe5                	j	5bc <memcmp+0x30>

00000000000005c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5c6:	1141                	addi	sp,sp,-16
 5c8:	e406                	sd	ra,8(sp)
 5ca:	e022                	sd	s0,0(sp)
 5cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5ce:	00000097          	auipc	ra,0x0
 5d2:	f66080e7          	jalr	-154(ra) # 534 <memmove>
}
 5d6:	60a2                	ld	ra,8(sp)
 5d8:	6402                	ld	s0,0(sp)
 5da:	0141                	addi	sp,sp,16
 5dc:	8082                	ret

00000000000005de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5de:	4885                	li	a7,1
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5e6:	4889                	li	a7,2
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 5ee:	488d                	li	a7,3
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5f6:	4891                	li	a7,4
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <read>:
.global read
read:
 li a7, SYS_read
 5fe:	4895                	li	a7,5
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <write>:
.global write
write:
 li a7, SYS_write
 606:	48c1                	li	a7,16
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <close>:
.global close
close:
 li a7, SYS_close
 60e:	48d5                	li	a7,21
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <kill>:
.global kill
kill:
 li a7, SYS_kill
 616:	4899                	li	a7,6
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <exec>:
.global exec
exec:
 li a7, SYS_exec
 61e:	489d                	li	a7,7
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <open>:
.global open
open:
 li a7, SYS_open
 626:	48bd                	li	a7,15
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 62e:	48c5                	li	a7,17
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 636:	48c9                	li	a7,18
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 63e:	48a1                	li	a7,8
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <link>:
.global link
link:
 li a7, SYS_link
 646:	48cd                	li	a7,19
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 64e:	48d1                	li	a7,20
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 656:	48a5                	li	a7,9
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <dup>:
.global dup
dup:
 li a7, SYS_dup
 65e:	48a9                	li	a7,10
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 666:	48ad                	li	a7,11
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 66e:	48b1                	li	a7,12
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 676:	48b5                	li	a7,13
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 67e:	48b9                	li	a7,14
 ecall
 680:	00000073          	ecall
 ret
 684:	8082                	ret

0000000000000686 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 686:	1101                	addi	sp,sp,-32
 688:	ec06                	sd	ra,24(sp)
 68a:	e822                	sd	s0,16(sp)
 68c:	1000                	addi	s0,sp,32
 68e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 692:	4605                	li	a2,1
 694:	fef40593          	addi	a1,s0,-17
 698:	00000097          	auipc	ra,0x0
 69c:	f6e080e7          	jalr	-146(ra) # 606 <write>
}
 6a0:	60e2                	ld	ra,24(sp)
 6a2:	6442                	ld	s0,16(sp)
 6a4:	6105                	addi	sp,sp,32
 6a6:	8082                	ret

00000000000006a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6a8:	7139                	addi	sp,sp,-64
 6aa:	fc06                	sd	ra,56(sp)
 6ac:	f822                	sd	s0,48(sp)
 6ae:	f426                	sd	s1,40(sp)
 6b0:	f04a                	sd	s2,32(sp)
 6b2:	ec4e                	sd	s3,24(sp)
 6b4:	0080                	addi	s0,sp,64
 6b6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6b8:	c299                	beqz	a3,6be <printint+0x16>
 6ba:	0805c863          	bltz	a1,74a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6be:	2581                	sext.w	a1,a1
  neg = 0;
 6c0:	4881                	li	a7,0
 6c2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6c6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6c8:	2601                	sext.w	a2,a2
 6ca:	00000517          	auipc	a0,0x0
 6ce:	49e50513          	addi	a0,a0,1182 # b68 <digits>
 6d2:	883a                	mv	a6,a4
 6d4:	2705                	addiw	a4,a4,1
 6d6:	02c5f7bb          	remuw	a5,a1,a2
 6da:	1782                	slli	a5,a5,0x20
 6dc:	9381                	srli	a5,a5,0x20
 6de:	97aa                	add	a5,a5,a0
 6e0:	0007c783          	lbu	a5,0(a5)
 6e4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6e8:	0005879b          	sext.w	a5,a1
 6ec:	02c5d5bb          	divuw	a1,a1,a2
 6f0:	0685                	addi	a3,a3,1
 6f2:	fec7f0e3          	bgeu	a5,a2,6d2 <printint+0x2a>
  if(neg)
 6f6:	00088b63          	beqz	a7,70c <printint+0x64>
    buf[i++] = '-';
 6fa:	fd040793          	addi	a5,s0,-48
 6fe:	973e                	add	a4,a4,a5
 700:	02d00793          	li	a5,45
 704:	fef70823          	sb	a5,-16(a4)
 708:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 70c:	02e05863          	blez	a4,73c <printint+0x94>
 710:	fc040793          	addi	a5,s0,-64
 714:	00e78933          	add	s2,a5,a4
 718:	fff78993          	addi	s3,a5,-1
 71c:	99ba                	add	s3,s3,a4
 71e:	377d                	addiw	a4,a4,-1
 720:	1702                	slli	a4,a4,0x20
 722:	9301                	srli	a4,a4,0x20
 724:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 728:	fff94583          	lbu	a1,-1(s2)
 72c:	8526                	mv	a0,s1
 72e:	00000097          	auipc	ra,0x0
 732:	f58080e7          	jalr	-168(ra) # 686 <putc>
  while(--i >= 0)
 736:	197d                	addi	s2,s2,-1
 738:	ff3918e3          	bne	s2,s3,728 <printint+0x80>
}
 73c:	70e2                	ld	ra,56(sp)
 73e:	7442                	ld	s0,48(sp)
 740:	74a2                	ld	s1,40(sp)
 742:	7902                	ld	s2,32(sp)
 744:	69e2                	ld	s3,24(sp)
 746:	6121                	addi	sp,sp,64
 748:	8082                	ret
    x = -xx;
 74a:	40b005bb          	negw	a1,a1
    neg = 1;
 74e:	4885                	li	a7,1
    x = -xx;
 750:	bf8d                	j	6c2 <printint+0x1a>

0000000000000752 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 752:	7119                	addi	sp,sp,-128
 754:	fc86                	sd	ra,120(sp)
 756:	f8a2                	sd	s0,112(sp)
 758:	f4a6                	sd	s1,104(sp)
 75a:	f0ca                	sd	s2,96(sp)
 75c:	ecce                	sd	s3,88(sp)
 75e:	e8d2                	sd	s4,80(sp)
 760:	e4d6                	sd	s5,72(sp)
 762:	e0da                	sd	s6,64(sp)
 764:	fc5e                	sd	s7,56(sp)
 766:	f862                	sd	s8,48(sp)
 768:	f466                	sd	s9,40(sp)
 76a:	f06a                	sd	s10,32(sp)
 76c:	ec6e                	sd	s11,24(sp)
 76e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 770:	0005c903          	lbu	s2,0(a1)
 774:	18090f63          	beqz	s2,912 <vprintf+0x1c0>
 778:	8aaa                	mv	s5,a0
 77a:	8b32                	mv	s6,a2
 77c:	00158493          	addi	s1,a1,1
  state = 0;
 780:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 782:	02500a13          	li	s4,37
      if(c == 'd'){
 786:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 78a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 78e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 792:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 796:	00000b97          	auipc	s7,0x0
 79a:	3d2b8b93          	addi	s7,s7,978 # b68 <digits>
 79e:	a839                	j	7bc <vprintf+0x6a>
        putc(fd, c);
 7a0:	85ca                	mv	a1,s2
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	ee2080e7          	jalr	-286(ra) # 686 <putc>
 7ac:	a019                	j	7b2 <vprintf+0x60>
    } else if(state == '%'){
 7ae:	01498f63          	beq	s3,s4,7cc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 7b2:	0485                	addi	s1,s1,1
 7b4:	fff4c903          	lbu	s2,-1(s1)
 7b8:	14090d63          	beqz	s2,912 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 7bc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7c0:	fe0997e3          	bnez	s3,7ae <vprintf+0x5c>
      if(c == '%'){
 7c4:	fd479ee3          	bne	a5,s4,7a0 <vprintf+0x4e>
        state = '%';
 7c8:	89be                	mv	s3,a5
 7ca:	b7e5                	j	7b2 <vprintf+0x60>
      if(c == 'd'){
 7cc:	05878063          	beq	a5,s8,80c <vprintf+0xba>
      } else if(c == 'l') {
 7d0:	05978c63          	beq	a5,s9,828 <vprintf+0xd6>
      } else if(c == 'x') {
 7d4:	07a78863          	beq	a5,s10,844 <vprintf+0xf2>
      } else if(c == 'p') {
 7d8:	09b78463          	beq	a5,s11,860 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7dc:	07300713          	li	a4,115
 7e0:	0ce78663          	beq	a5,a4,8ac <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7e4:	06300713          	li	a4,99
 7e8:	0ee78e63          	beq	a5,a4,8e4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7ec:	11478863          	beq	a5,s4,8fc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7f0:	85d2                	mv	a1,s4
 7f2:	8556                	mv	a0,s5
 7f4:	00000097          	auipc	ra,0x0
 7f8:	e92080e7          	jalr	-366(ra) # 686 <putc>
        putc(fd, c);
 7fc:	85ca                	mv	a1,s2
 7fe:	8556                	mv	a0,s5
 800:	00000097          	auipc	ra,0x0
 804:	e86080e7          	jalr	-378(ra) # 686 <putc>
      }
      state = 0;
 808:	4981                	li	s3,0
 80a:	b765                	j	7b2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 80c:	008b0913          	addi	s2,s6,8
 810:	4685                	li	a3,1
 812:	4629                	li	a2,10
 814:	000b2583          	lw	a1,0(s6)
 818:	8556                	mv	a0,s5
 81a:	00000097          	auipc	ra,0x0
 81e:	e8e080e7          	jalr	-370(ra) # 6a8 <printint>
 822:	8b4a                	mv	s6,s2
      state = 0;
 824:	4981                	li	s3,0
 826:	b771                	j	7b2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 828:	008b0913          	addi	s2,s6,8
 82c:	4681                	li	a3,0
 82e:	4629                	li	a2,10
 830:	000b2583          	lw	a1,0(s6)
 834:	8556                	mv	a0,s5
 836:	00000097          	auipc	ra,0x0
 83a:	e72080e7          	jalr	-398(ra) # 6a8 <printint>
 83e:	8b4a                	mv	s6,s2
      state = 0;
 840:	4981                	li	s3,0
 842:	bf85                	j	7b2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 844:	008b0913          	addi	s2,s6,8
 848:	4681                	li	a3,0
 84a:	4641                	li	a2,16
 84c:	000b2583          	lw	a1,0(s6)
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	e56080e7          	jalr	-426(ra) # 6a8 <printint>
 85a:	8b4a                	mv	s6,s2
      state = 0;
 85c:	4981                	li	s3,0
 85e:	bf91                	j	7b2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 860:	008b0793          	addi	a5,s6,8
 864:	f8f43423          	sd	a5,-120(s0)
 868:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 86c:	03000593          	li	a1,48
 870:	8556                	mv	a0,s5
 872:	00000097          	auipc	ra,0x0
 876:	e14080e7          	jalr	-492(ra) # 686 <putc>
  putc(fd, 'x');
 87a:	85ea                	mv	a1,s10
 87c:	8556                	mv	a0,s5
 87e:	00000097          	auipc	ra,0x0
 882:	e08080e7          	jalr	-504(ra) # 686 <putc>
 886:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 888:	03c9d793          	srli	a5,s3,0x3c
 88c:	97de                	add	a5,a5,s7
 88e:	0007c583          	lbu	a1,0(a5)
 892:	8556                	mv	a0,s5
 894:	00000097          	auipc	ra,0x0
 898:	df2080e7          	jalr	-526(ra) # 686 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 89c:	0992                	slli	s3,s3,0x4
 89e:	397d                	addiw	s2,s2,-1
 8a0:	fe0914e3          	bnez	s2,888 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 8a4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 8a8:	4981                	li	s3,0
 8aa:	b721                	j	7b2 <vprintf+0x60>
        s = va_arg(ap, char*);
 8ac:	008b0993          	addi	s3,s6,8
 8b0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 8b4:	02090163          	beqz	s2,8d6 <vprintf+0x184>
        while(*s != 0){
 8b8:	00094583          	lbu	a1,0(s2)
 8bc:	c9a1                	beqz	a1,90c <vprintf+0x1ba>
          putc(fd, *s);
 8be:	8556                	mv	a0,s5
 8c0:	00000097          	auipc	ra,0x0
 8c4:	dc6080e7          	jalr	-570(ra) # 686 <putc>
          s++;
 8c8:	0905                	addi	s2,s2,1
        while(*s != 0){
 8ca:	00094583          	lbu	a1,0(s2)
 8ce:	f9e5                	bnez	a1,8be <vprintf+0x16c>
        s = va_arg(ap, char*);
 8d0:	8b4e                	mv	s6,s3
      state = 0;
 8d2:	4981                	li	s3,0
 8d4:	bdf9                	j	7b2 <vprintf+0x60>
          s = "(null)";
 8d6:	00000917          	auipc	s2,0x0
 8da:	28a90913          	addi	s2,s2,650 # b60 <malloc+0x144>
        while(*s != 0){
 8de:	02800593          	li	a1,40
 8e2:	bff1                	j	8be <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8e4:	008b0913          	addi	s2,s6,8
 8e8:	000b4583          	lbu	a1,0(s6)
 8ec:	8556                	mv	a0,s5
 8ee:	00000097          	auipc	ra,0x0
 8f2:	d98080e7          	jalr	-616(ra) # 686 <putc>
 8f6:	8b4a                	mv	s6,s2
      state = 0;
 8f8:	4981                	li	s3,0
 8fa:	bd65                	j	7b2 <vprintf+0x60>
        putc(fd, c);
 8fc:	85d2                	mv	a1,s4
 8fe:	8556                	mv	a0,s5
 900:	00000097          	auipc	ra,0x0
 904:	d86080e7          	jalr	-634(ra) # 686 <putc>
      state = 0;
 908:	4981                	li	s3,0
 90a:	b565                	j	7b2 <vprintf+0x60>
        s = va_arg(ap, char*);
 90c:	8b4e                	mv	s6,s3
      state = 0;
 90e:	4981                	li	s3,0
 910:	b54d                	j	7b2 <vprintf+0x60>
    }
  }
}
 912:	70e6                	ld	ra,120(sp)
 914:	7446                	ld	s0,112(sp)
 916:	74a6                	ld	s1,104(sp)
 918:	7906                	ld	s2,96(sp)
 91a:	69e6                	ld	s3,88(sp)
 91c:	6a46                	ld	s4,80(sp)
 91e:	6aa6                	ld	s5,72(sp)
 920:	6b06                	ld	s6,64(sp)
 922:	7be2                	ld	s7,56(sp)
 924:	7c42                	ld	s8,48(sp)
 926:	7ca2                	ld	s9,40(sp)
 928:	7d02                	ld	s10,32(sp)
 92a:	6de2                	ld	s11,24(sp)
 92c:	6109                	addi	sp,sp,128
 92e:	8082                	ret

0000000000000930 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 930:	715d                	addi	sp,sp,-80
 932:	ec06                	sd	ra,24(sp)
 934:	e822                	sd	s0,16(sp)
 936:	1000                	addi	s0,sp,32
 938:	e010                	sd	a2,0(s0)
 93a:	e414                	sd	a3,8(s0)
 93c:	e818                	sd	a4,16(s0)
 93e:	ec1c                	sd	a5,24(s0)
 940:	03043023          	sd	a6,32(s0)
 944:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 948:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 94c:	8622                	mv	a2,s0
 94e:	00000097          	auipc	ra,0x0
 952:	e04080e7          	jalr	-508(ra) # 752 <vprintf>
}
 956:	60e2                	ld	ra,24(sp)
 958:	6442                	ld	s0,16(sp)
 95a:	6161                	addi	sp,sp,80
 95c:	8082                	ret

000000000000095e <printf>:

void
printf(const char *fmt, ...)
{
 95e:	711d                	addi	sp,sp,-96
 960:	ec06                	sd	ra,24(sp)
 962:	e822                	sd	s0,16(sp)
 964:	1000                	addi	s0,sp,32
 966:	e40c                	sd	a1,8(s0)
 968:	e810                	sd	a2,16(s0)
 96a:	ec14                	sd	a3,24(s0)
 96c:	f018                	sd	a4,32(s0)
 96e:	f41c                	sd	a5,40(s0)
 970:	03043823          	sd	a6,48(s0)
 974:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 978:	00840613          	addi	a2,s0,8
 97c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 980:	85aa                	mv	a1,a0
 982:	4505                	li	a0,1
 984:	00000097          	auipc	ra,0x0
 988:	dce080e7          	jalr	-562(ra) # 752 <vprintf>
}
 98c:	60e2                	ld	ra,24(sp)
 98e:	6442                	ld	s0,16(sp)
 990:	6125                	addi	sp,sp,96
 992:	8082                	ret

0000000000000994 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 994:	1141                	addi	sp,sp,-16
 996:	e422                	sd	s0,8(sp)
 998:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 99a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99e:	00000797          	auipc	a5,0x0
 9a2:	1e27b783          	ld	a5,482(a5) # b80 <freep>
 9a6:	a805                	j	9d6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9a8:	4618                	lw	a4,8(a2)
 9aa:	9db9                	addw	a1,a1,a4
 9ac:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9b0:	6398                	ld	a4,0(a5)
 9b2:	6318                	ld	a4,0(a4)
 9b4:	fee53823          	sd	a4,-16(a0)
 9b8:	a091                	j	9fc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9ba:	ff852703          	lw	a4,-8(a0)
 9be:	9e39                	addw	a2,a2,a4
 9c0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9c2:	ff053703          	ld	a4,-16(a0)
 9c6:	e398                	sd	a4,0(a5)
 9c8:	a099                	j	a0e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ca:	6398                	ld	a4,0(a5)
 9cc:	00e7e463          	bltu	a5,a4,9d4 <free+0x40>
 9d0:	00e6ea63          	bltu	a3,a4,9e4 <free+0x50>
{
 9d4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d6:	fed7fae3          	bgeu	a5,a3,9ca <free+0x36>
 9da:	6398                	ld	a4,0(a5)
 9dc:	00e6e463          	bltu	a3,a4,9e4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e0:	fee7eae3          	bltu	a5,a4,9d4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9e4:	ff852583          	lw	a1,-8(a0)
 9e8:	6390                	ld	a2,0(a5)
 9ea:	02059713          	slli	a4,a1,0x20
 9ee:	9301                	srli	a4,a4,0x20
 9f0:	0712                	slli	a4,a4,0x4
 9f2:	9736                	add	a4,a4,a3
 9f4:	fae60ae3          	beq	a2,a4,9a8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9f8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9fc:	4790                	lw	a2,8(a5)
 9fe:	02061713          	slli	a4,a2,0x20
 a02:	9301                	srli	a4,a4,0x20
 a04:	0712                	slli	a4,a4,0x4
 a06:	973e                	add	a4,a4,a5
 a08:	fae689e3          	beq	a3,a4,9ba <free+0x26>
  } else
    p->s.ptr = bp;
 a0c:	e394                	sd	a3,0(a5)
  freep = p;
 a0e:	00000717          	auipc	a4,0x0
 a12:	16f73923          	sd	a5,370(a4) # b80 <freep>
}
 a16:	6422                	ld	s0,8(sp)
 a18:	0141                	addi	sp,sp,16
 a1a:	8082                	ret

0000000000000a1c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a1c:	7139                	addi	sp,sp,-64
 a1e:	fc06                	sd	ra,56(sp)
 a20:	f822                	sd	s0,48(sp)
 a22:	f426                	sd	s1,40(sp)
 a24:	f04a                	sd	s2,32(sp)
 a26:	ec4e                	sd	s3,24(sp)
 a28:	e852                	sd	s4,16(sp)
 a2a:	e456                	sd	s5,8(sp)
 a2c:	e05a                	sd	s6,0(sp)
 a2e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a30:	02051493          	slli	s1,a0,0x20
 a34:	9081                	srli	s1,s1,0x20
 a36:	04bd                	addi	s1,s1,15
 a38:	8091                	srli	s1,s1,0x4
 a3a:	0014899b          	addiw	s3,s1,1
 a3e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a40:	00000517          	auipc	a0,0x0
 a44:	14053503          	ld	a0,320(a0) # b80 <freep>
 a48:	c515                	beqz	a0,a74 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a4c:	4798                	lw	a4,8(a5)
 a4e:	02977f63          	bgeu	a4,s1,a8c <malloc+0x70>
 a52:	8a4e                	mv	s4,s3
 a54:	0009871b          	sext.w	a4,s3
 a58:	6685                	lui	a3,0x1
 a5a:	00d77363          	bgeu	a4,a3,a60 <malloc+0x44>
 a5e:	6a05                	lui	s4,0x1
 a60:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a64:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a68:	00000917          	auipc	s2,0x0
 a6c:	11890913          	addi	s2,s2,280 # b80 <freep>
  if(p == (char*)-1)
 a70:	5afd                	li	s5,-1
 a72:	a88d                	j	ae4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a74:	00000797          	auipc	a5,0x0
 a78:	11478793          	addi	a5,a5,276 # b88 <base>
 a7c:	00000717          	auipc	a4,0x0
 a80:	10f73223          	sd	a5,260(a4) # b80 <freep>
 a84:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a86:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a8a:	b7e1                	j	a52 <malloc+0x36>
      if(p->s.size == nunits)
 a8c:	02e48b63          	beq	s1,a4,ac2 <malloc+0xa6>
        p->s.size -= nunits;
 a90:	4137073b          	subw	a4,a4,s3
 a94:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a96:	1702                	slli	a4,a4,0x20
 a98:	9301                	srli	a4,a4,0x20
 a9a:	0712                	slli	a4,a4,0x4
 a9c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a9e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 aa2:	00000717          	auipc	a4,0x0
 aa6:	0ca73f23          	sd	a0,222(a4) # b80 <freep>
      return (void*)(p + 1);
 aaa:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 aae:	70e2                	ld	ra,56(sp)
 ab0:	7442                	ld	s0,48(sp)
 ab2:	74a2                	ld	s1,40(sp)
 ab4:	7902                	ld	s2,32(sp)
 ab6:	69e2                	ld	s3,24(sp)
 ab8:	6a42                	ld	s4,16(sp)
 aba:	6aa2                	ld	s5,8(sp)
 abc:	6b02                	ld	s6,0(sp)
 abe:	6121                	addi	sp,sp,64
 ac0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ac2:	6398                	ld	a4,0(a5)
 ac4:	e118                	sd	a4,0(a0)
 ac6:	bff1                	j	aa2 <malloc+0x86>
  hp->s.size = nu;
 ac8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 acc:	0541                	addi	a0,a0,16
 ace:	00000097          	auipc	ra,0x0
 ad2:	ec6080e7          	jalr	-314(ra) # 994 <free>
  return freep;
 ad6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ada:	d971                	beqz	a0,aae <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 adc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ade:	4798                	lw	a4,8(a5)
 ae0:	fa9776e3          	bgeu	a4,s1,a8c <malloc+0x70>
    if(p == freep)
 ae4:	00093703          	ld	a4,0(s2)
 ae8:	853e                	mv	a0,a5
 aea:	fef719e3          	bne	a4,a5,adc <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 aee:	8552                	mv	a0,s4
 af0:	00000097          	auipc	ra,0x0
 af4:	b7e080e7          	jalr	-1154(ra) # 66e <sbrk>
  if(p == (char*)-1)
 af8:	fd5518e3          	bne	a0,s5,ac8 <malloc+0xac>
        return 0;
 afc:	4501                	li	a0,0
 afe:	bf45                	j	aae <malloc+0x92>
