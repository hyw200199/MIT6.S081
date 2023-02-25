
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sieve>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void sieve(int pleft[2]) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	0080                	addi	s0,sp,64
   c:	84aa                	mv	s1,a0
	int p;
	read(pleft[0], &p, sizeof(p));
   e:	4611                	li	a2,4
  10:	fdc40593          	addi	a1,s0,-36
  14:	4108                	lw	a0,0(a0)
  16:	00000097          	auipc	ra,0x0
  1a:	414080e7          	jalr	1044(ra) # 42a <read>
	if(p == -1) {
  1e:	fdc42583          	lw	a1,-36(s0)
  22:	57fd                	li	a5,-1
  24:	04f58c63          	beq	a1,a5,7c <sieve+0x7c>
		exit(0);
	}
	printf("prime %d\n", p);
  28:	00001517          	auipc	a0,0x1
  2c:	90850513          	addi	a0,a0,-1784 # 930 <malloc+0xe8>
  30:	00000097          	auipc	ra,0x0
  34:	75a080e7          	jalr	1882(ra) # 78a <printf>

	int pright[2];
	pipe(pright);
  38:	fd040513          	addi	a0,s0,-48
  3c:	00000097          	auipc	ra,0x0
  40:	3e6080e7          	jalr	998(ra) # 422 <pipe>
	if(fork() == 0) { // child
  44:	00000097          	auipc	ra,0x0
  48:	3c6080e7          	jalr	966(ra) # 40a <fork>
  4c:	ed0d                	bnez	a0,86 <sieve+0x86>
		close(pleft[0]);
  4e:	4088                	lw	a0,0(s1)
  50:	00000097          	auipc	ra,0x0
  54:	3ea080e7          	jalr	1002(ra) # 43a <close>
		close(pright[1]); // close unnecessary fd (every forked process has a copy of the fd, so it's important to reduce the amount of it)
  58:	fd442503          	lw	a0,-44(s0)
  5c:	00000097          	auipc	ra,0x0
  60:	3de080e7          	jalr	990(ra) # 43a <close>
		sieve(pright);	
  64:	fd040513          	addi	a0,s0,-48
  68:	00000097          	auipc	ra,0x0
  6c:	f98080e7          	jalr	-104(ra) # 0 <sieve>
		// printf("e%d\n",p);
		close(pleft[0]); // same as above
		wait(0);
		exit(0);
	}
}
  70:	70e2                	ld	ra,56(sp)
  72:	7442                	ld	s0,48(sp)
  74:	74a2                	ld	s1,40(sp)
  76:	7902                	ld	s2,32(sp)
  78:	6121                	addi	sp,sp,64
  7a:	8082                	ret
		exit(0);
  7c:	4501                	li	a0,0
  7e:	00000097          	auipc	ra,0x0
  82:	394080e7          	jalr	916(ra) # 412 <exit>
		close(pright[0]); // same as above
  86:	fd042503          	lw	a0,-48(s0)
  8a:	00000097          	auipc	ra,0x0
  8e:	3b0080e7          	jalr	944(ra) # 43a <close>
		while(read(pleft[0], &buf, sizeof(buf)) && buf != -1) {
  92:	597d                	li	s2,-1
  94:	4611                	li	a2,4
  96:	fcc40593          	addi	a1,s0,-52
  9a:	4088                	lw	a0,0(s1)
  9c:	00000097          	auipc	ra,0x0
  a0:	38e080e7          	jalr	910(ra) # 42a <read>
  a4:	c505                	beqz	a0,cc <sieve+0xcc>
  a6:	fcc42783          	lw	a5,-52(s0)
  aa:	03278163          	beq	a5,s2,cc <sieve+0xcc>
			if(buf % p != 0) {
  ae:	fdc42703          	lw	a4,-36(s0)
  b2:	02e7e7bb          	remw	a5,a5,a4
  b6:	dff9                	beqz	a5,94 <sieve+0x94>
				write(pright[1], &buf, sizeof(buf));
  b8:	4611                	li	a2,4
  ba:	fcc40593          	addi	a1,s0,-52
  be:	fd442503          	lw	a0,-44(s0)
  c2:	00000097          	auipc	ra,0x0
  c6:	370080e7          	jalr	880(ra) # 432 <write>
  ca:	b7e9                	j	94 <sieve+0x94>
		write(pright[1], &buf, sizeof(buf));
  cc:	4611                	li	a2,4
  ce:	fcc40593          	addi	a1,s0,-52
  d2:	fd442503          	lw	a0,-44(s0)
  d6:	00000097          	auipc	ra,0x0
  da:	35c080e7          	jalr	860(ra) # 432 <write>
		close(pleft[0]); // same as above
  de:	4088                	lw	a0,0(s1)
  e0:	00000097          	auipc	ra,0x0
  e4:	35a080e7          	jalr	858(ra) # 43a <close>
		wait(0);
  e8:	4501                	li	a0,0
  ea:	00000097          	auipc	ra,0x0
  ee:	330080e7          	jalr	816(ra) # 41a <wait>
		exit(0);
  f2:	4501                	li	a0,0
  f4:	00000097          	auipc	ra,0x0
  f8:	31e080e7          	jalr	798(ra) # 412 <exit>

00000000000000fc <main>:

int main(int argc, char **argv) {
  fc:	7179                	addi	sp,sp,-48
  fe:	f406                	sd	ra,40(sp)
 100:	f022                	sd	s0,32(sp)
 102:	ec26                	sd	s1,24(sp)
 104:	1800                	addi	s0,sp,48
	int input_pipe[2];
	pipe(input_pipe);
 106:	fd840513          	addi	a0,s0,-40
 10a:	00000097          	auipc	ra,0x0
 10e:	318080e7          	jalr	792(ra) # 422 <pipe>

	if(fork() == 0) { // child
 112:	00000097          	auipc	ra,0x0
 116:	2f8080e7          	jalr	760(ra) # 40a <fork>
 11a:	e115                	bnez	a0,13e <main+0x42>
		close(input_pipe[1]);
 11c:	fdc42503          	lw	a0,-36(s0)
 120:	00000097          	auipc	ra,0x0
 124:	31a080e7          	jalr	794(ra) # 43a <close>
		sieve(input_pipe);
 128:	fd840513          	addi	a0,s0,-40
 12c:	00000097          	auipc	ra,0x0
 130:	ed4080e7          	jalr	-300(ra) # 0 <sieve>
		exit(0);
 134:	4501                	li	a0,0
 136:	00000097          	auipc	ra,0x0
 13a:	2dc080e7          	jalr	732(ra) # 412 <exit>
	} else { // parent
		close(input_pipe[0]);
 13e:	fd842503          	lw	a0,-40(s0)
 142:	00000097          	auipc	ra,0x0
 146:	2f8080e7          	jalr	760(ra) # 43a <close>
		int i;
		for(i=2;i<=35;i++){
 14a:	4789                	li	a5,2
 14c:	fcf42a23          	sw	a5,-44(s0)
 150:	02300493          	li	s1,35
			write(input_pipe[1], &i, sizeof(i));
 154:	4611                	li	a2,4
 156:	fd440593          	addi	a1,s0,-44
 15a:	fdc42503          	lw	a0,-36(s0)
 15e:	00000097          	auipc	ra,0x0
 162:	2d4080e7          	jalr	724(ra) # 432 <write>
		for(i=2;i<=35;i++){
 166:	fd442783          	lw	a5,-44(s0)
 16a:	2785                	addiw	a5,a5,1
 16c:	0007871b          	sext.w	a4,a5
 170:	fcf42a23          	sw	a5,-44(s0)
 174:	fee4d0e3          	bge	s1,a4,154 <main+0x58>
		}
		i = -1;
 178:	57fd                	li	a5,-1
 17a:	fcf42a23          	sw	a5,-44(s0)
		write(input_pipe[1], &i, sizeof(i));
 17e:	4611                	li	a2,4
 180:	fd440593          	addi	a1,s0,-44
 184:	fdc42503          	lw	a0,-36(s0)
 188:	00000097          	auipc	ra,0x0
 18c:	2aa080e7          	jalr	682(ra) # 432 <write>
	}
	wait(0);
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	288080e7          	jalr	648(ra) # 41a <wait>
	exit(0);
 19a:	4501                	li	a0,0
 19c:	00000097          	auipc	ra,0x0
 1a0:	276080e7          	jalr	630(ra) # 412 <exit>

00000000000001a4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1aa:	87aa                	mv	a5,a0
 1ac:	0585                	addi	a1,a1,1
 1ae:	0785                	addi	a5,a5,1
 1b0:	fff5c703          	lbu	a4,-1(a1)
 1b4:	fee78fa3          	sb	a4,-1(a5)
 1b8:	fb75                	bnez	a4,1ac <strcpy+0x8>
    ;
  return os;
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	cb91                	beqz	a5,1de <strcmp+0x1e>
 1cc:	0005c703          	lbu	a4,0(a1)
 1d0:	00f71763          	bne	a4,a5,1de <strcmp+0x1e>
    p++, q++;
 1d4:	0505                	addi	a0,a0,1
 1d6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	fbe5                	bnez	a5,1cc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1de:	0005c503          	lbu	a0,0(a1)
}
 1e2:	40a7853b          	subw	a0,a5,a0
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret

00000000000001ec <strlen>:

uint
strlen(const char *s)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	cf91                	beqz	a5,212 <strlen+0x26>
 1f8:	0505                	addi	a0,a0,1
 1fa:	87aa                	mv	a5,a0
 1fc:	4685                	li	a3,1
 1fe:	9e89                	subw	a3,a3,a0
 200:	00f6853b          	addw	a0,a3,a5
 204:	0785                	addi	a5,a5,1
 206:	fff7c703          	lbu	a4,-1(a5)
 20a:	fb7d                	bnez	a4,200 <strlen+0x14>
    ;
  return n;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret
  for(n = 0; s[n]; n++)
 212:	4501                	li	a0,0
 214:	bfe5                	j	20c <strlen+0x20>

0000000000000216 <memset>:

void*
memset(void *dst, int c, uint n)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 21c:	ca19                	beqz	a2,232 <memset+0x1c>
 21e:	87aa                	mv	a5,a0
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 228:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 22c:	0785                	addi	a5,a5,1
 22e:	fee79de3          	bne	a5,a4,228 <memset+0x12>
  }
  return dst;
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret

0000000000000238 <strchr>:

char*
strchr(const char *s, char c)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 23e:	00054783          	lbu	a5,0(a0)
 242:	cb99                	beqz	a5,258 <strchr+0x20>
    if(*s == c)
 244:	00f58763          	beq	a1,a5,252 <strchr+0x1a>
  for(; *s; s++)
 248:	0505                	addi	a0,a0,1
 24a:	00054783          	lbu	a5,0(a0)
 24e:	fbfd                	bnez	a5,244 <strchr+0xc>
      return (char*)s;
  return 0;
 250:	4501                	li	a0,0
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  return 0;
 258:	4501                	li	a0,0
 25a:	bfe5                	j	252 <strchr+0x1a>

000000000000025c <gets>:

char*
gets(char *buf, int max)
{
 25c:	711d                	addi	sp,sp,-96
 25e:	ec86                	sd	ra,88(sp)
 260:	e8a2                	sd	s0,80(sp)
 262:	e4a6                	sd	s1,72(sp)
 264:	e0ca                	sd	s2,64(sp)
 266:	fc4e                	sd	s3,56(sp)
 268:	f852                	sd	s4,48(sp)
 26a:	f456                	sd	s5,40(sp)
 26c:	f05a                	sd	s6,32(sp)
 26e:	ec5e                	sd	s7,24(sp)
 270:	1080                	addi	s0,sp,96
 272:	8baa                	mv	s7,a0
 274:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 276:	892a                	mv	s2,a0
 278:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 27a:	4aa9                	li	s5,10
 27c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 27e:	89a6                	mv	s3,s1
 280:	2485                	addiw	s1,s1,1
 282:	0344d863          	bge	s1,s4,2b2 <gets+0x56>
    cc = read(0, &c, 1);
 286:	4605                	li	a2,1
 288:	faf40593          	addi	a1,s0,-81
 28c:	4501                	li	a0,0
 28e:	00000097          	auipc	ra,0x0
 292:	19c080e7          	jalr	412(ra) # 42a <read>
    if(cc < 1)
 296:	00a05e63          	blez	a0,2b2 <gets+0x56>
    buf[i++] = c;
 29a:	faf44783          	lbu	a5,-81(s0)
 29e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a2:	01578763          	beq	a5,s5,2b0 <gets+0x54>
 2a6:	0905                	addi	s2,s2,1
 2a8:	fd679be3          	bne	a5,s6,27e <gets+0x22>
  for(i=0; i+1 < max; ){
 2ac:	89a6                	mv	s3,s1
 2ae:	a011                	j	2b2 <gets+0x56>
 2b0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b2:	99de                	add	s3,s3,s7
 2b4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2b8:	855e                	mv	a0,s7
 2ba:	60e6                	ld	ra,88(sp)
 2bc:	6446                	ld	s0,80(sp)
 2be:	64a6                	ld	s1,72(sp)
 2c0:	6906                	ld	s2,64(sp)
 2c2:	79e2                	ld	s3,56(sp)
 2c4:	7a42                	ld	s4,48(sp)
 2c6:	7aa2                	ld	s5,40(sp)
 2c8:	7b02                	ld	s6,32(sp)
 2ca:	6be2                	ld	s7,24(sp)
 2cc:	6125                	addi	sp,sp,96
 2ce:	8082                	ret

00000000000002d0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d0:	1101                	addi	sp,sp,-32
 2d2:	ec06                	sd	ra,24(sp)
 2d4:	e822                	sd	s0,16(sp)
 2d6:	e426                	sd	s1,8(sp)
 2d8:	e04a                	sd	s2,0(sp)
 2da:	1000                	addi	s0,sp,32
 2dc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2de:	4581                	li	a1,0
 2e0:	00000097          	auipc	ra,0x0
 2e4:	172080e7          	jalr	370(ra) # 452 <open>
  if(fd < 0)
 2e8:	02054563          	bltz	a0,312 <stat+0x42>
 2ec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ee:	85ca                	mv	a1,s2
 2f0:	00000097          	auipc	ra,0x0
 2f4:	17a080e7          	jalr	378(ra) # 46a <fstat>
 2f8:	892a                	mv	s2,a0
  close(fd);
 2fa:	8526                	mv	a0,s1
 2fc:	00000097          	auipc	ra,0x0
 300:	13e080e7          	jalr	318(ra) # 43a <close>
  return r;
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

0000000000000316 <atoi>:

int
atoi(const char *s)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31c:	00054603          	lbu	a2,0(a0)
 320:	fd06079b          	addiw	a5,a2,-48
 324:	0ff7f793          	andi	a5,a5,255
 328:	4725                	li	a4,9
 32a:	02f76963          	bltu	a4,a5,35c <atoi+0x46>
 32e:	86aa                	mv	a3,a0
  n = 0;
 330:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 332:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 334:	0685                	addi	a3,a3,1
 336:	0025179b          	slliw	a5,a0,0x2
 33a:	9fa9                	addw	a5,a5,a0
 33c:	0017979b          	slliw	a5,a5,0x1
 340:	9fb1                	addw	a5,a5,a2
 342:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 346:	0006c603          	lbu	a2,0(a3)
 34a:	fd06071b          	addiw	a4,a2,-48
 34e:	0ff77713          	andi	a4,a4,255
 352:	fee5f1e3          	bgeu	a1,a4,334 <atoi+0x1e>
  return n;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret
  n = 0;
 35c:	4501                	li	a0,0
 35e:	bfe5                	j	356 <atoi+0x40>

0000000000000360 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 366:	02b57463          	bgeu	a0,a1,38e <memmove+0x2e>
    while(n-- > 0)
 36a:	00c05f63          	blez	a2,388 <memmove+0x28>
 36e:	1602                	slli	a2,a2,0x20
 370:	9201                	srli	a2,a2,0x20
 372:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 376:	872a                	mv	a4,a0
      *dst++ = *src++;
 378:	0585                	addi	a1,a1,1
 37a:	0705                	addi	a4,a4,1
 37c:	fff5c683          	lbu	a3,-1(a1)
 380:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 384:	fee79ae3          	bne	a5,a4,378 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 388:	6422                	ld	s0,8(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret
    dst += n;
 38e:	00c50733          	add	a4,a0,a2
    src += n;
 392:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 394:	fec05ae3          	blez	a2,388 <memmove+0x28>
 398:	fff6079b          	addiw	a5,a2,-1
 39c:	1782                	slli	a5,a5,0x20
 39e:	9381                	srli	a5,a5,0x20
 3a0:	fff7c793          	not	a5,a5
 3a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3a6:	15fd                	addi	a1,a1,-1
 3a8:	177d                	addi	a4,a4,-1
 3aa:	0005c683          	lbu	a3,0(a1)
 3ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3b2:	fee79ae3          	bne	a5,a4,3a6 <memmove+0x46>
 3b6:	bfc9                	j	388 <memmove+0x28>

00000000000003b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3b8:	1141                	addi	sp,sp,-16
 3ba:	e422                	sd	s0,8(sp)
 3bc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3be:	ca05                	beqz	a2,3ee <memcmp+0x36>
 3c0:	fff6069b          	addiw	a3,a2,-1
 3c4:	1682                	slli	a3,a3,0x20
 3c6:	9281                	srli	a3,a3,0x20
 3c8:	0685                	addi	a3,a3,1
 3ca:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3cc:	00054783          	lbu	a5,0(a0)
 3d0:	0005c703          	lbu	a4,0(a1)
 3d4:	00e79863          	bne	a5,a4,3e4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3d8:	0505                	addi	a0,a0,1
    p2++;
 3da:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3dc:	fed518e3          	bne	a0,a3,3cc <memcmp+0x14>
  }
  return 0;
 3e0:	4501                	li	a0,0
 3e2:	a019                	j	3e8 <memcmp+0x30>
      return *p1 - *p2;
 3e4:	40e7853b          	subw	a0,a5,a4
}
 3e8:	6422                	ld	s0,8(sp)
 3ea:	0141                	addi	sp,sp,16
 3ec:	8082                	ret
  return 0;
 3ee:	4501                	li	a0,0
 3f0:	bfe5                	j	3e8 <memcmp+0x30>

00000000000003f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3f2:	1141                	addi	sp,sp,-16
 3f4:	e406                	sd	ra,8(sp)
 3f6:	e022                	sd	s0,0(sp)
 3f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3fa:	00000097          	auipc	ra,0x0
 3fe:	f66080e7          	jalr	-154(ra) # 360 <memmove>
}
 402:	60a2                	ld	ra,8(sp)
 404:	6402                	ld	s0,0(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret

000000000000040a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 40a:	4885                	li	a7,1
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exit>:
.global exit
exit:
 li a7, SYS_exit
 412:	4889                	li	a7,2
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <wait>:
.global wait
wait:
 li a7, SYS_wait
 41a:	488d                	li	a7,3
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 422:	4891                	li	a7,4
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <read>:
.global read
read:
 li a7, SYS_read
 42a:	4895                	li	a7,5
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <write>:
.global write
write:
 li a7, SYS_write
 432:	48c1                	li	a7,16
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <close>:
.global close
close:
 li a7, SYS_close
 43a:	48d5                	li	a7,21
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <kill>:
.global kill
kill:
 li a7, SYS_kill
 442:	4899                	li	a7,6
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <exec>:
.global exec
exec:
 li a7, SYS_exec
 44a:	489d                	li	a7,7
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <open>:
.global open
open:
 li a7, SYS_open
 452:	48bd                	li	a7,15
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 45a:	48c5                	li	a7,17
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 462:	48c9                	li	a7,18
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 46a:	48a1                	li	a7,8
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <link>:
.global link
link:
 li a7, SYS_link
 472:	48cd                	li	a7,19
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 47a:	48d1                	li	a7,20
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 482:	48a5                	li	a7,9
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <dup>:
.global dup
dup:
 li a7, SYS_dup
 48a:	48a9                	li	a7,10
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 492:	48ad                	li	a7,11
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 49a:	48b1                	li	a7,12
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4a2:	48b5                	li	a7,13
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4aa:	48b9                	li	a7,14
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b2:	1101                	addi	sp,sp,-32
 4b4:	ec06                	sd	ra,24(sp)
 4b6:	e822                	sd	s0,16(sp)
 4b8:	1000                	addi	s0,sp,32
 4ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4be:	4605                	li	a2,1
 4c0:	fef40593          	addi	a1,s0,-17
 4c4:	00000097          	auipc	ra,0x0
 4c8:	f6e080e7          	jalr	-146(ra) # 432 <write>
}
 4cc:	60e2                	ld	ra,24(sp)
 4ce:	6442                	ld	s0,16(sp)
 4d0:	6105                	addi	sp,sp,32
 4d2:	8082                	ret

00000000000004d4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d4:	7139                	addi	sp,sp,-64
 4d6:	fc06                	sd	ra,56(sp)
 4d8:	f822                	sd	s0,48(sp)
 4da:	f426                	sd	s1,40(sp)
 4dc:	f04a                	sd	s2,32(sp)
 4de:	ec4e                	sd	s3,24(sp)
 4e0:	0080                	addi	s0,sp,64
 4e2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e4:	c299                	beqz	a3,4ea <printint+0x16>
 4e6:	0805c863          	bltz	a1,576 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ea:	2581                	sext.w	a1,a1
  neg = 0;
 4ec:	4881                	li	a7,0
 4ee:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f4:	2601                	sext.w	a2,a2
 4f6:	00000517          	auipc	a0,0x0
 4fa:	45250513          	addi	a0,a0,1106 # 948 <digits>
 4fe:	883a                	mv	a6,a4
 500:	2705                	addiw	a4,a4,1
 502:	02c5f7bb          	remuw	a5,a1,a2
 506:	1782                	slli	a5,a5,0x20
 508:	9381                	srli	a5,a5,0x20
 50a:	97aa                	add	a5,a5,a0
 50c:	0007c783          	lbu	a5,0(a5)
 510:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 514:	0005879b          	sext.w	a5,a1
 518:	02c5d5bb          	divuw	a1,a1,a2
 51c:	0685                	addi	a3,a3,1
 51e:	fec7f0e3          	bgeu	a5,a2,4fe <printint+0x2a>
  if(neg)
 522:	00088b63          	beqz	a7,538 <printint+0x64>
    buf[i++] = '-';
 526:	fd040793          	addi	a5,s0,-48
 52a:	973e                	add	a4,a4,a5
 52c:	02d00793          	li	a5,45
 530:	fef70823          	sb	a5,-16(a4)
 534:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 538:	02e05863          	blez	a4,568 <printint+0x94>
 53c:	fc040793          	addi	a5,s0,-64
 540:	00e78933          	add	s2,a5,a4
 544:	fff78993          	addi	s3,a5,-1
 548:	99ba                	add	s3,s3,a4
 54a:	377d                	addiw	a4,a4,-1
 54c:	1702                	slli	a4,a4,0x20
 54e:	9301                	srli	a4,a4,0x20
 550:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 554:	fff94583          	lbu	a1,-1(s2)
 558:	8526                	mv	a0,s1
 55a:	00000097          	auipc	ra,0x0
 55e:	f58080e7          	jalr	-168(ra) # 4b2 <putc>
  while(--i >= 0)
 562:	197d                	addi	s2,s2,-1
 564:	ff3918e3          	bne	s2,s3,554 <printint+0x80>
}
 568:	70e2                	ld	ra,56(sp)
 56a:	7442                	ld	s0,48(sp)
 56c:	74a2                	ld	s1,40(sp)
 56e:	7902                	ld	s2,32(sp)
 570:	69e2                	ld	s3,24(sp)
 572:	6121                	addi	sp,sp,64
 574:	8082                	ret
    x = -xx;
 576:	40b005bb          	negw	a1,a1
    neg = 1;
 57a:	4885                	li	a7,1
    x = -xx;
 57c:	bf8d                	j	4ee <printint+0x1a>

000000000000057e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57e:	7119                	addi	sp,sp,-128
 580:	fc86                	sd	ra,120(sp)
 582:	f8a2                	sd	s0,112(sp)
 584:	f4a6                	sd	s1,104(sp)
 586:	f0ca                	sd	s2,96(sp)
 588:	ecce                	sd	s3,88(sp)
 58a:	e8d2                	sd	s4,80(sp)
 58c:	e4d6                	sd	s5,72(sp)
 58e:	e0da                	sd	s6,64(sp)
 590:	fc5e                	sd	s7,56(sp)
 592:	f862                	sd	s8,48(sp)
 594:	f466                	sd	s9,40(sp)
 596:	f06a                	sd	s10,32(sp)
 598:	ec6e                	sd	s11,24(sp)
 59a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 59c:	0005c903          	lbu	s2,0(a1)
 5a0:	18090f63          	beqz	s2,73e <vprintf+0x1c0>
 5a4:	8aaa                	mv	s5,a0
 5a6:	8b32                	mv	s6,a2
 5a8:	00158493          	addi	s1,a1,1
  state = 0;
 5ac:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5ae:	02500a13          	li	s4,37
      if(c == 'd'){
 5b2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5b6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5ba:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5be:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5c2:	00000b97          	auipc	s7,0x0
 5c6:	386b8b93          	addi	s7,s7,902 # 948 <digits>
 5ca:	a839                	j	5e8 <vprintf+0x6a>
        putc(fd, c);
 5cc:	85ca                	mv	a1,s2
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	ee2080e7          	jalr	-286(ra) # 4b2 <putc>
 5d8:	a019                	j	5de <vprintf+0x60>
    } else if(state == '%'){
 5da:	01498f63          	beq	s3,s4,5f8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5de:	0485                	addi	s1,s1,1
 5e0:	fff4c903          	lbu	s2,-1(s1)
 5e4:	14090d63          	beqz	s2,73e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5e8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5ec:	fe0997e3          	bnez	s3,5da <vprintf+0x5c>
      if(c == '%'){
 5f0:	fd479ee3          	bne	a5,s4,5cc <vprintf+0x4e>
        state = '%';
 5f4:	89be                	mv	s3,a5
 5f6:	b7e5                	j	5de <vprintf+0x60>
      if(c == 'd'){
 5f8:	05878063          	beq	a5,s8,638 <vprintf+0xba>
      } else if(c == 'l') {
 5fc:	05978c63          	beq	a5,s9,654 <vprintf+0xd6>
      } else if(c == 'x') {
 600:	07a78863          	beq	a5,s10,670 <vprintf+0xf2>
      } else if(c == 'p') {
 604:	09b78463          	beq	a5,s11,68c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 608:	07300713          	li	a4,115
 60c:	0ce78663          	beq	a5,a4,6d8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 610:	06300713          	li	a4,99
 614:	0ee78e63          	beq	a5,a4,710 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 618:	11478863          	beq	a5,s4,728 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 61c:	85d2                	mv	a1,s4
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	e92080e7          	jalr	-366(ra) # 4b2 <putc>
        putc(fd, c);
 628:	85ca                	mv	a1,s2
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e86080e7          	jalr	-378(ra) # 4b2 <putc>
      }
      state = 0;
 634:	4981                	li	s3,0
 636:	b765                	j	5de <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 638:	008b0913          	addi	s2,s6,8
 63c:	4685                	li	a3,1
 63e:	4629                	li	a2,10
 640:	000b2583          	lw	a1,0(s6)
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	e8e080e7          	jalr	-370(ra) # 4d4 <printint>
 64e:	8b4a                	mv	s6,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	b771                	j	5de <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 654:	008b0913          	addi	s2,s6,8
 658:	4681                	li	a3,0
 65a:	4629                	li	a2,10
 65c:	000b2583          	lw	a1,0(s6)
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	e72080e7          	jalr	-398(ra) # 4d4 <printint>
 66a:	8b4a                	mv	s6,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	bf85                	j	5de <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 670:	008b0913          	addi	s2,s6,8
 674:	4681                	li	a3,0
 676:	4641                	li	a2,16
 678:	000b2583          	lw	a1,0(s6)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	e56080e7          	jalr	-426(ra) # 4d4 <printint>
 686:	8b4a                	mv	s6,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	bf91                	j	5de <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 68c:	008b0793          	addi	a5,s6,8
 690:	f8f43423          	sd	a5,-120(s0)
 694:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 698:	03000593          	li	a1,48
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	e14080e7          	jalr	-492(ra) # 4b2 <putc>
  putc(fd, 'x');
 6a6:	85ea                	mv	a1,s10
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	e08080e7          	jalr	-504(ra) # 4b2 <putc>
 6b2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b4:	03c9d793          	srli	a5,s3,0x3c
 6b8:	97de                	add	a5,a5,s7
 6ba:	0007c583          	lbu	a1,0(a5)
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	df2080e7          	jalr	-526(ra) # 4b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c8:	0992                	slli	s3,s3,0x4
 6ca:	397d                	addiw	s2,s2,-1
 6cc:	fe0914e3          	bnez	s2,6b4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6d0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b721                	j	5de <vprintf+0x60>
        s = va_arg(ap, char*);
 6d8:	008b0993          	addi	s3,s6,8
 6dc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6e0:	02090163          	beqz	s2,702 <vprintf+0x184>
        while(*s != 0){
 6e4:	00094583          	lbu	a1,0(s2)
 6e8:	c9a1                	beqz	a1,738 <vprintf+0x1ba>
          putc(fd, *s);
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	dc6080e7          	jalr	-570(ra) # 4b2 <putc>
          s++;
 6f4:	0905                	addi	s2,s2,1
        while(*s != 0){
 6f6:	00094583          	lbu	a1,0(s2)
 6fa:	f9e5                	bnez	a1,6ea <vprintf+0x16c>
        s = va_arg(ap, char*);
 6fc:	8b4e                	mv	s6,s3
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bdf9                	j	5de <vprintf+0x60>
          s = "(null)";
 702:	00000917          	auipc	s2,0x0
 706:	23e90913          	addi	s2,s2,574 # 940 <malloc+0xf8>
        while(*s != 0){
 70a:	02800593          	li	a1,40
 70e:	bff1                	j	6ea <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 710:	008b0913          	addi	s2,s6,8
 714:	000b4583          	lbu	a1,0(s6)
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	d98080e7          	jalr	-616(ra) # 4b2 <putc>
 722:	8b4a                	mv	s6,s2
      state = 0;
 724:	4981                	li	s3,0
 726:	bd65                	j	5de <vprintf+0x60>
        putc(fd, c);
 728:	85d2                	mv	a1,s4
 72a:	8556                	mv	a0,s5
 72c:	00000097          	auipc	ra,0x0
 730:	d86080e7          	jalr	-634(ra) # 4b2 <putc>
      state = 0;
 734:	4981                	li	s3,0
 736:	b565                	j	5de <vprintf+0x60>
        s = va_arg(ap, char*);
 738:	8b4e                	mv	s6,s3
      state = 0;
 73a:	4981                	li	s3,0
 73c:	b54d                	j	5de <vprintf+0x60>
    }
  }
}
 73e:	70e6                	ld	ra,120(sp)
 740:	7446                	ld	s0,112(sp)
 742:	74a6                	ld	s1,104(sp)
 744:	7906                	ld	s2,96(sp)
 746:	69e6                	ld	s3,88(sp)
 748:	6a46                	ld	s4,80(sp)
 74a:	6aa6                	ld	s5,72(sp)
 74c:	6b06                	ld	s6,64(sp)
 74e:	7be2                	ld	s7,56(sp)
 750:	7c42                	ld	s8,48(sp)
 752:	7ca2                	ld	s9,40(sp)
 754:	7d02                	ld	s10,32(sp)
 756:	6de2                	ld	s11,24(sp)
 758:	6109                	addi	sp,sp,128
 75a:	8082                	ret

000000000000075c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 75c:	715d                	addi	sp,sp,-80
 75e:	ec06                	sd	ra,24(sp)
 760:	e822                	sd	s0,16(sp)
 762:	1000                	addi	s0,sp,32
 764:	e010                	sd	a2,0(s0)
 766:	e414                	sd	a3,8(s0)
 768:	e818                	sd	a4,16(s0)
 76a:	ec1c                	sd	a5,24(s0)
 76c:	03043023          	sd	a6,32(s0)
 770:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 774:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 778:	8622                	mv	a2,s0
 77a:	00000097          	auipc	ra,0x0
 77e:	e04080e7          	jalr	-508(ra) # 57e <vprintf>
}
 782:	60e2                	ld	ra,24(sp)
 784:	6442                	ld	s0,16(sp)
 786:	6161                	addi	sp,sp,80
 788:	8082                	ret

000000000000078a <printf>:

void
printf(const char *fmt, ...)
{
 78a:	711d                	addi	sp,sp,-96
 78c:	ec06                	sd	ra,24(sp)
 78e:	e822                	sd	s0,16(sp)
 790:	1000                	addi	s0,sp,32
 792:	e40c                	sd	a1,8(s0)
 794:	e810                	sd	a2,16(s0)
 796:	ec14                	sd	a3,24(s0)
 798:	f018                	sd	a4,32(s0)
 79a:	f41c                	sd	a5,40(s0)
 79c:	03043823          	sd	a6,48(s0)
 7a0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a4:	00840613          	addi	a2,s0,8
 7a8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ac:	85aa                	mv	a1,a0
 7ae:	4505                	li	a0,1
 7b0:	00000097          	auipc	ra,0x0
 7b4:	dce080e7          	jalr	-562(ra) # 57e <vprintf>
}
 7b8:	60e2                	ld	ra,24(sp)
 7ba:	6442                	ld	s0,16(sp)
 7bc:	6125                	addi	sp,sp,96
 7be:	8082                	ret

00000000000007c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c0:	1141                	addi	sp,sp,-16
 7c2:	e422                	sd	s0,8(sp)
 7c4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ca:	00000797          	auipc	a5,0x0
 7ce:	1967b783          	ld	a5,406(a5) # 960 <freep>
 7d2:	a805                	j	802 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d4:	4618                	lw	a4,8(a2)
 7d6:	9db9                	addw	a1,a1,a4
 7d8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7dc:	6398                	ld	a4,0(a5)
 7de:	6318                	ld	a4,0(a4)
 7e0:	fee53823          	sd	a4,-16(a0)
 7e4:	a091                	j	828 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e6:	ff852703          	lw	a4,-8(a0)
 7ea:	9e39                	addw	a2,a2,a4
 7ec:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7ee:	ff053703          	ld	a4,-16(a0)
 7f2:	e398                	sd	a4,0(a5)
 7f4:	a099                	j	83a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	6398                	ld	a4,0(a5)
 7f8:	00e7e463          	bltu	a5,a4,800 <free+0x40>
 7fc:	00e6ea63          	bltu	a3,a4,810 <free+0x50>
{
 800:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 802:	fed7fae3          	bgeu	a5,a3,7f6 <free+0x36>
 806:	6398                	ld	a4,0(a5)
 808:	00e6e463          	bltu	a3,a4,810 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80c:	fee7eae3          	bltu	a5,a4,800 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 810:	ff852583          	lw	a1,-8(a0)
 814:	6390                	ld	a2,0(a5)
 816:	02059713          	slli	a4,a1,0x20
 81a:	9301                	srli	a4,a4,0x20
 81c:	0712                	slli	a4,a4,0x4
 81e:	9736                	add	a4,a4,a3
 820:	fae60ae3          	beq	a2,a4,7d4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 824:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 828:	4790                	lw	a2,8(a5)
 82a:	02061713          	slli	a4,a2,0x20
 82e:	9301                	srli	a4,a4,0x20
 830:	0712                	slli	a4,a4,0x4
 832:	973e                	add	a4,a4,a5
 834:	fae689e3          	beq	a3,a4,7e6 <free+0x26>
  } else
    p->s.ptr = bp;
 838:	e394                	sd	a3,0(a5)
  freep = p;
 83a:	00000717          	auipc	a4,0x0
 83e:	12f73323          	sd	a5,294(a4) # 960 <freep>
}
 842:	6422                	ld	s0,8(sp)
 844:	0141                	addi	sp,sp,16
 846:	8082                	ret

0000000000000848 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 848:	7139                	addi	sp,sp,-64
 84a:	fc06                	sd	ra,56(sp)
 84c:	f822                	sd	s0,48(sp)
 84e:	f426                	sd	s1,40(sp)
 850:	f04a                	sd	s2,32(sp)
 852:	ec4e                	sd	s3,24(sp)
 854:	e852                	sd	s4,16(sp)
 856:	e456                	sd	s5,8(sp)
 858:	e05a                	sd	s6,0(sp)
 85a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 85c:	02051493          	slli	s1,a0,0x20
 860:	9081                	srli	s1,s1,0x20
 862:	04bd                	addi	s1,s1,15
 864:	8091                	srli	s1,s1,0x4
 866:	0014899b          	addiw	s3,s1,1
 86a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 86c:	00000517          	auipc	a0,0x0
 870:	0f453503          	ld	a0,244(a0) # 960 <freep>
 874:	c515                	beqz	a0,8a0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 876:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 878:	4798                	lw	a4,8(a5)
 87a:	02977f63          	bgeu	a4,s1,8b8 <malloc+0x70>
 87e:	8a4e                	mv	s4,s3
 880:	0009871b          	sext.w	a4,s3
 884:	6685                	lui	a3,0x1
 886:	00d77363          	bgeu	a4,a3,88c <malloc+0x44>
 88a:	6a05                	lui	s4,0x1
 88c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 890:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 894:	00000917          	auipc	s2,0x0
 898:	0cc90913          	addi	s2,s2,204 # 960 <freep>
  if(p == (char*)-1)
 89c:	5afd                	li	s5,-1
 89e:	a88d                	j	910 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8a0:	00000797          	auipc	a5,0x0
 8a4:	0c878793          	addi	a5,a5,200 # 968 <base>
 8a8:	00000717          	auipc	a4,0x0
 8ac:	0af73c23          	sd	a5,184(a4) # 960 <freep>
 8b0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8b2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b6:	b7e1                	j	87e <malloc+0x36>
      if(p->s.size == nunits)
 8b8:	02e48b63          	beq	s1,a4,8ee <malloc+0xa6>
        p->s.size -= nunits;
 8bc:	4137073b          	subw	a4,a4,s3
 8c0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c2:	1702                	slli	a4,a4,0x20
 8c4:	9301                	srli	a4,a4,0x20
 8c6:	0712                	slli	a4,a4,0x4
 8c8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ca:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ce:	00000717          	auipc	a4,0x0
 8d2:	08a73923          	sd	a0,146(a4) # 960 <freep>
      return (void*)(p + 1);
 8d6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8da:	70e2                	ld	ra,56(sp)
 8dc:	7442                	ld	s0,48(sp)
 8de:	74a2                	ld	s1,40(sp)
 8e0:	7902                	ld	s2,32(sp)
 8e2:	69e2                	ld	s3,24(sp)
 8e4:	6a42                	ld	s4,16(sp)
 8e6:	6aa2                	ld	s5,8(sp)
 8e8:	6b02                	ld	s6,0(sp)
 8ea:	6121                	addi	sp,sp,64
 8ec:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ee:	6398                	ld	a4,0(a5)
 8f0:	e118                	sd	a4,0(a0)
 8f2:	bff1                	j	8ce <malloc+0x86>
  hp->s.size = nu;
 8f4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f8:	0541                	addi	a0,a0,16
 8fa:	00000097          	auipc	ra,0x0
 8fe:	ec6080e7          	jalr	-314(ra) # 7c0 <free>
  return freep;
 902:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 906:	d971                	beqz	a0,8da <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 908:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90a:	4798                	lw	a4,8(a5)
 90c:	fa9776e3          	bgeu	a4,s1,8b8 <malloc+0x70>
    if(p == freep)
 910:	00093703          	ld	a4,0(s2)
 914:	853e                	mv	a0,a5
 916:	fef719e3          	bne	a4,a5,908 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 91a:	8552                	mv	a0,s4
 91c:	00000097          	auipc	ra,0x0
 920:	b7e080e7          	jalr	-1154(ra) # 49a <sbrk>
  if(p == (char*)-1)
 924:	fd5518e3          	bne	a0,s5,8f4 <malloc+0xac>
        return 0;
 928:	4501                	li	a0,0
 92a:	bf45                	j	8da <malloc+0x92>
