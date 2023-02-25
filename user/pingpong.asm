
user/_pingpong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char **argv) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
	int pp2c[2], pc2p[2];
	pipe(pp2c);
   8:	fe840513          	addi	a0,s0,-24
   c:	00000097          	auipc	ra,0x0
  10:	332080e7          	jalr	818(ra) # 33e <pipe>
	pipe(pc2p);
  14:	fe040513          	addi	a0,s0,-32
  18:	00000097          	auipc	ra,0x0
  1c:	326080e7          	jalr	806(ra) # 33e <pipe>
	
	if(fork() == 0) { // child process
  20:	00000097          	auipc	ra,0x0
  24:	306080e7          	jalr	774(ra) # 326 <fork>
  28:	e529                	bnez	a0,72 <main+0x72>
		char buf;
		read(pp2c[0], &buf, 1);
  2a:	4605                	li	a2,1
  2c:	fdf40593          	addi	a1,s0,-33
  30:	fe842503          	lw	a0,-24(s0)
  34:	00000097          	auipc	ra,0x0
  38:	312080e7          	jalr	786(ra) # 346 <read>
		printf("%d: received ping\n", getpid());
  3c:	00000097          	auipc	ra,0x0
  40:	372080e7          	jalr	882(ra) # 3ae <getpid>
  44:	85aa                	mv	a1,a0
  46:	00001517          	auipc	a0,0x1
  4a:	80250513          	addi	a0,a0,-2046 # 848 <malloc+0xe4>
  4e:	00000097          	auipc	ra,0x0
  52:	658080e7          	jalr	1624(ra) # 6a6 <printf>
		write(pc2p[1], &buf, 1);
  56:	4605                	li	a2,1
  58:	fdf40593          	addi	a1,s0,-33
  5c:	fe442503          	lw	a0,-28(s0)
  60:	00000097          	auipc	ra,0x0
  64:	2ee080e7          	jalr	750(ra) # 34e <write>
		char buf;
		read(pc2p[0], &buf, 1);
		printf("%d: received pong\n", getpid());
		wait(0);
	}
	exit(0);
  68:	4501                	li	a0,0
  6a:	00000097          	auipc	ra,0x0
  6e:	2c4080e7          	jalr	708(ra) # 32e <exit>
		write(pp2c[1], "!", 1);
  72:	4605                	li	a2,1
  74:	00000597          	auipc	a1,0x0
  78:	7ec58593          	addi	a1,a1,2028 # 860 <malloc+0xfc>
  7c:	fec42503          	lw	a0,-20(s0)
  80:	00000097          	auipc	ra,0x0
  84:	2ce080e7          	jalr	718(ra) # 34e <write>
		read(pc2p[0], &buf, 1);
  88:	4605                	li	a2,1
  8a:	fdf40593          	addi	a1,s0,-33
  8e:	fe042503          	lw	a0,-32(s0)
  92:	00000097          	auipc	ra,0x0
  96:	2b4080e7          	jalr	692(ra) # 346 <read>
		printf("%d: received pong\n", getpid());
  9a:	00000097          	auipc	ra,0x0
  9e:	314080e7          	jalr	788(ra) # 3ae <getpid>
  a2:	85aa                	mv	a1,a0
  a4:	00000517          	auipc	a0,0x0
  a8:	7c450513          	addi	a0,a0,1988 # 868 <malloc+0x104>
  ac:	00000097          	auipc	ra,0x0
  b0:	5fa080e7          	jalr	1530(ra) # 6a6 <printf>
		wait(0);
  b4:	4501                	li	a0,0
  b6:	00000097          	auipc	ra,0x0
  ba:	280080e7          	jalr	640(ra) # 336 <wait>
  be:	b76d                	j	68 <main+0x68>

00000000000000c0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c6:	87aa                	mv	a5,a0
  c8:	0585                	addi	a1,a1,1
  ca:	0785                	addi	a5,a5,1
  cc:	fff5c703          	lbu	a4,-1(a1)
  d0:	fee78fa3          	sb	a4,-1(a5)
  d4:	fb75                	bnez	a4,c8 <strcpy+0x8>
    ;
  return os;
}
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e422                	sd	s0,8(sp)
  e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  e2:	00054783          	lbu	a5,0(a0)
  e6:	cb91                	beqz	a5,fa <strcmp+0x1e>
  e8:	0005c703          	lbu	a4,0(a1)
  ec:	00f71763          	bne	a4,a5,fa <strcmp+0x1e>
    p++, q++;
  f0:	0505                	addi	a0,a0,1
  f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	fbe5                	bnez	a5,e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  fa:	0005c503          	lbu	a0,0(a1)
}
  fe:	40a7853b          	subw	a0,a5,a0
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret

0000000000000108 <strlen>:

uint
strlen(const char *s)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10e:	00054783          	lbu	a5,0(a0)
 112:	cf91                	beqz	a5,12e <strlen+0x26>
 114:	0505                	addi	a0,a0,1
 116:	87aa                	mv	a5,a0
 118:	4685                	li	a3,1
 11a:	9e89                	subw	a3,a3,a0
 11c:	00f6853b          	addw	a0,a3,a5
 120:	0785                	addi	a5,a5,1
 122:	fff7c703          	lbu	a4,-1(a5)
 126:	fb7d                	bnez	a4,11c <strlen+0x14>
    ;
  return n;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret
  for(n = 0; s[n]; n++)
 12e:	4501                	li	a0,0
 130:	bfe5                	j	128 <strlen+0x20>

0000000000000132 <memset>:

void*
memset(void *dst, int c, uint n)
{
 132:	1141                	addi	sp,sp,-16
 134:	e422                	sd	s0,8(sp)
 136:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 138:	ca19                	beqz	a2,14e <memset+0x1c>
 13a:	87aa                	mv	a5,a0
 13c:	1602                	slli	a2,a2,0x20
 13e:	9201                	srli	a2,a2,0x20
 140:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 144:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 148:	0785                	addi	a5,a5,1
 14a:	fee79de3          	bne	a5,a4,144 <memset+0x12>
  }
  return dst;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strchr>:

char*
strchr(const char *s, char c)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  for(; *s; s++)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cb99                	beqz	a5,174 <strchr+0x20>
    if(*s == c)
 160:	00f58763          	beq	a1,a5,16e <strchr+0x1a>
  for(; *s; s++)
 164:	0505                	addi	a0,a0,1
 166:	00054783          	lbu	a5,0(a0)
 16a:	fbfd                	bnez	a5,160 <strchr+0xc>
      return (char*)s;
  return 0;
 16c:	4501                	li	a0,0
}
 16e:	6422                	ld	s0,8(sp)
 170:	0141                	addi	sp,sp,16
 172:	8082                	ret
  return 0;
 174:	4501                	li	a0,0
 176:	bfe5                	j	16e <strchr+0x1a>

0000000000000178 <gets>:

char*
gets(char *buf, int max)
{
 178:	711d                	addi	sp,sp,-96
 17a:	ec86                	sd	ra,88(sp)
 17c:	e8a2                	sd	s0,80(sp)
 17e:	e4a6                	sd	s1,72(sp)
 180:	e0ca                	sd	s2,64(sp)
 182:	fc4e                	sd	s3,56(sp)
 184:	f852                	sd	s4,48(sp)
 186:	f456                	sd	s5,40(sp)
 188:	f05a                	sd	s6,32(sp)
 18a:	ec5e                	sd	s7,24(sp)
 18c:	1080                	addi	s0,sp,96
 18e:	8baa                	mv	s7,a0
 190:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 192:	892a                	mv	s2,a0
 194:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 196:	4aa9                	li	s5,10
 198:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 19a:	89a6                	mv	s3,s1
 19c:	2485                	addiw	s1,s1,1
 19e:	0344d863          	bge	s1,s4,1ce <gets+0x56>
    cc = read(0, &c, 1);
 1a2:	4605                	li	a2,1
 1a4:	faf40593          	addi	a1,s0,-81
 1a8:	4501                	li	a0,0
 1aa:	00000097          	auipc	ra,0x0
 1ae:	19c080e7          	jalr	412(ra) # 346 <read>
    if(cc < 1)
 1b2:	00a05e63          	blez	a0,1ce <gets+0x56>
    buf[i++] = c;
 1b6:	faf44783          	lbu	a5,-81(s0)
 1ba:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1be:	01578763          	beq	a5,s5,1cc <gets+0x54>
 1c2:	0905                	addi	s2,s2,1
 1c4:	fd679be3          	bne	a5,s6,19a <gets+0x22>
  for(i=0; i+1 < max; ){
 1c8:	89a6                	mv	s3,s1
 1ca:	a011                	j	1ce <gets+0x56>
 1cc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ce:	99de                	add	s3,s3,s7
 1d0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d4:	855e                	mv	a0,s7
 1d6:	60e6                	ld	ra,88(sp)
 1d8:	6446                	ld	s0,80(sp)
 1da:	64a6                	ld	s1,72(sp)
 1dc:	6906                	ld	s2,64(sp)
 1de:	79e2                	ld	s3,56(sp)
 1e0:	7a42                	ld	s4,48(sp)
 1e2:	7aa2                	ld	s5,40(sp)
 1e4:	7b02                	ld	s6,32(sp)
 1e6:	6be2                	ld	s7,24(sp)
 1e8:	6125                	addi	sp,sp,96
 1ea:	8082                	ret

00000000000001ec <stat>:

int
stat(const char *n, struct stat *st)
{
 1ec:	1101                	addi	sp,sp,-32
 1ee:	ec06                	sd	ra,24(sp)
 1f0:	e822                	sd	s0,16(sp)
 1f2:	e426                	sd	s1,8(sp)
 1f4:	e04a                	sd	s2,0(sp)
 1f6:	1000                	addi	s0,sp,32
 1f8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fa:	4581                	li	a1,0
 1fc:	00000097          	auipc	ra,0x0
 200:	172080e7          	jalr	370(ra) # 36e <open>
  if(fd < 0)
 204:	02054563          	bltz	a0,22e <stat+0x42>
 208:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20a:	85ca                	mv	a1,s2
 20c:	00000097          	auipc	ra,0x0
 210:	17a080e7          	jalr	378(ra) # 386 <fstat>
 214:	892a                	mv	s2,a0
  close(fd);
 216:	8526                	mv	a0,s1
 218:	00000097          	auipc	ra,0x0
 21c:	13e080e7          	jalr	318(ra) # 356 <close>
  return r;
}
 220:	854a                	mv	a0,s2
 222:	60e2                	ld	ra,24(sp)
 224:	6442                	ld	s0,16(sp)
 226:	64a2                	ld	s1,8(sp)
 228:	6902                	ld	s2,0(sp)
 22a:	6105                	addi	sp,sp,32
 22c:	8082                	ret
    return -1;
 22e:	597d                	li	s2,-1
 230:	bfc5                	j	220 <stat+0x34>

0000000000000232 <atoi>:

int
atoi(const char *s)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 238:	00054603          	lbu	a2,0(a0)
 23c:	fd06079b          	addiw	a5,a2,-48
 240:	0ff7f793          	andi	a5,a5,255
 244:	4725                	li	a4,9
 246:	02f76963          	bltu	a4,a5,278 <atoi+0x46>
 24a:	86aa                	mv	a3,a0
  n = 0;
 24c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 24e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 250:	0685                	addi	a3,a3,1
 252:	0025179b          	slliw	a5,a0,0x2
 256:	9fa9                	addw	a5,a5,a0
 258:	0017979b          	slliw	a5,a5,0x1
 25c:	9fb1                	addw	a5,a5,a2
 25e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 262:	0006c603          	lbu	a2,0(a3)
 266:	fd06071b          	addiw	a4,a2,-48
 26a:	0ff77713          	andi	a4,a4,255
 26e:	fee5f1e3          	bgeu	a1,a4,250 <atoi+0x1e>
  return n;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  n = 0;
 278:	4501                	li	a0,0
 27a:	bfe5                	j	272 <atoi+0x40>

000000000000027c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 282:	02b57463          	bgeu	a0,a1,2aa <memmove+0x2e>
    while(n-- > 0)
 286:	00c05f63          	blez	a2,2a4 <memmove+0x28>
 28a:	1602                	slli	a2,a2,0x20
 28c:	9201                	srli	a2,a2,0x20
 28e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 292:	872a                	mv	a4,a0
      *dst++ = *src++;
 294:	0585                	addi	a1,a1,1
 296:	0705                	addi	a4,a4,1
 298:	fff5c683          	lbu	a3,-1(a1)
 29c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a0:	fee79ae3          	bne	a5,a4,294 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret
    dst += n;
 2aa:	00c50733          	add	a4,a0,a2
    src += n;
 2ae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b0:	fec05ae3          	blez	a2,2a4 <memmove+0x28>
 2b4:	fff6079b          	addiw	a5,a2,-1
 2b8:	1782                	slli	a5,a5,0x20
 2ba:	9381                	srli	a5,a5,0x20
 2bc:	fff7c793          	not	a5,a5
 2c0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c2:	15fd                	addi	a1,a1,-1
 2c4:	177d                	addi	a4,a4,-1
 2c6:	0005c683          	lbu	a3,0(a1)
 2ca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ce:	fee79ae3          	bne	a5,a4,2c2 <memmove+0x46>
 2d2:	bfc9                	j	2a4 <memmove+0x28>

00000000000002d4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2da:	ca05                	beqz	a2,30a <memcmp+0x36>
 2dc:	fff6069b          	addiw	a3,a2,-1
 2e0:	1682                	slli	a3,a3,0x20
 2e2:	9281                	srli	a3,a3,0x20
 2e4:	0685                	addi	a3,a3,1
 2e6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	0005c703          	lbu	a4,0(a1)
 2f0:	00e79863          	bne	a5,a4,300 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f4:	0505                	addi	a0,a0,1
    p2++;
 2f6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f8:	fed518e3          	bne	a0,a3,2e8 <memcmp+0x14>
  }
  return 0;
 2fc:	4501                	li	a0,0
 2fe:	a019                	j	304 <memcmp+0x30>
      return *p1 - *p2;
 300:	40e7853b          	subw	a0,a5,a4
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
  return 0;
 30a:	4501                	li	a0,0
 30c:	bfe5                	j	304 <memcmp+0x30>

000000000000030e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 316:	00000097          	auipc	ra,0x0
 31a:	f66080e7          	jalr	-154(ra) # 27c <memmove>
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 326:	4885                	li	a7,1
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <exit>:
.global exit
exit:
 li a7, SYS_exit
 32e:	4889                	li	a7,2
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <wait>:
.global wait
wait:
 li a7, SYS_wait
 336:	488d                	li	a7,3
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33e:	4891                	li	a7,4
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <read>:
.global read
read:
 li a7, SYS_read
 346:	4895                	li	a7,5
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <write>:
.global write
write:
 li a7, SYS_write
 34e:	48c1                	li	a7,16
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <close>:
.global close
close:
 li a7, SYS_close
 356:	48d5                	li	a7,21
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <kill>:
.global kill
kill:
 li a7, SYS_kill
 35e:	4899                	li	a7,6
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <exec>:
.global exec
exec:
 li a7, SYS_exec
 366:	489d                	li	a7,7
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <open>:
.global open
open:
 li a7, SYS_open
 36e:	48bd                	li	a7,15
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 376:	48c5                	li	a7,17
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37e:	48c9                	li	a7,18
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 386:	48a1                	li	a7,8
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <link>:
.global link
link:
 li a7, SYS_link
 38e:	48cd                	li	a7,19
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 396:	48d1                	li	a7,20
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39e:	48a5                	li	a7,9
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a6:	48a9                	li	a7,10
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ae:	48ad                	li	a7,11
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b6:	48b1                	li	a7,12
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3be:	48b5                	li	a7,13
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c6:	48b9                	li	a7,14
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ce:	1101                	addi	sp,sp,-32
 3d0:	ec06                	sd	ra,24(sp)
 3d2:	e822                	sd	s0,16(sp)
 3d4:	1000                	addi	s0,sp,32
 3d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3da:	4605                	li	a2,1
 3dc:	fef40593          	addi	a1,s0,-17
 3e0:	00000097          	auipc	ra,0x0
 3e4:	f6e080e7          	jalr	-146(ra) # 34e <write>
}
 3e8:	60e2                	ld	ra,24(sp)
 3ea:	6442                	ld	s0,16(sp)
 3ec:	6105                	addi	sp,sp,32
 3ee:	8082                	ret

00000000000003f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f0:	7139                	addi	sp,sp,-64
 3f2:	fc06                	sd	ra,56(sp)
 3f4:	f822                	sd	s0,48(sp)
 3f6:	f426                	sd	s1,40(sp)
 3f8:	f04a                	sd	s2,32(sp)
 3fa:	ec4e                	sd	s3,24(sp)
 3fc:	0080                	addi	s0,sp,64
 3fe:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 400:	c299                	beqz	a3,406 <printint+0x16>
 402:	0805c863          	bltz	a1,492 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 406:	2581                	sext.w	a1,a1
  neg = 0;
 408:	4881                	li	a7,0
 40a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 40e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 410:	2601                	sext.w	a2,a2
 412:	00000517          	auipc	a0,0x0
 416:	47650513          	addi	a0,a0,1142 # 888 <digits>
 41a:	883a                	mv	a6,a4
 41c:	2705                	addiw	a4,a4,1
 41e:	02c5f7bb          	remuw	a5,a1,a2
 422:	1782                	slli	a5,a5,0x20
 424:	9381                	srli	a5,a5,0x20
 426:	97aa                	add	a5,a5,a0
 428:	0007c783          	lbu	a5,0(a5)
 42c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 430:	0005879b          	sext.w	a5,a1
 434:	02c5d5bb          	divuw	a1,a1,a2
 438:	0685                	addi	a3,a3,1
 43a:	fec7f0e3          	bgeu	a5,a2,41a <printint+0x2a>
  if(neg)
 43e:	00088b63          	beqz	a7,454 <printint+0x64>
    buf[i++] = '-';
 442:	fd040793          	addi	a5,s0,-48
 446:	973e                	add	a4,a4,a5
 448:	02d00793          	li	a5,45
 44c:	fef70823          	sb	a5,-16(a4)
 450:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 454:	02e05863          	blez	a4,484 <printint+0x94>
 458:	fc040793          	addi	a5,s0,-64
 45c:	00e78933          	add	s2,a5,a4
 460:	fff78993          	addi	s3,a5,-1
 464:	99ba                	add	s3,s3,a4
 466:	377d                	addiw	a4,a4,-1
 468:	1702                	slli	a4,a4,0x20
 46a:	9301                	srli	a4,a4,0x20
 46c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 470:	fff94583          	lbu	a1,-1(s2)
 474:	8526                	mv	a0,s1
 476:	00000097          	auipc	ra,0x0
 47a:	f58080e7          	jalr	-168(ra) # 3ce <putc>
  while(--i >= 0)
 47e:	197d                	addi	s2,s2,-1
 480:	ff3918e3          	bne	s2,s3,470 <printint+0x80>
}
 484:	70e2                	ld	ra,56(sp)
 486:	7442                	ld	s0,48(sp)
 488:	74a2                	ld	s1,40(sp)
 48a:	7902                	ld	s2,32(sp)
 48c:	69e2                	ld	s3,24(sp)
 48e:	6121                	addi	sp,sp,64
 490:	8082                	ret
    x = -xx;
 492:	40b005bb          	negw	a1,a1
    neg = 1;
 496:	4885                	li	a7,1
    x = -xx;
 498:	bf8d                	j	40a <printint+0x1a>

000000000000049a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 49a:	7119                	addi	sp,sp,-128
 49c:	fc86                	sd	ra,120(sp)
 49e:	f8a2                	sd	s0,112(sp)
 4a0:	f4a6                	sd	s1,104(sp)
 4a2:	f0ca                	sd	s2,96(sp)
 4a4:	ecce                	sd	s3,88(sp)
 4a6:	e8d2                	sd	s4,80(sp)
 4a8:	e4d6                	sd	s5,72(sp)
 4aa:	e0da                	sd	s6,64(sp)
 4ac:	fc5e                	sd	s7,56(sp)
 4ae:	f862                	sd	s8,48(sp)
 4b0:	f466                	sd	s9,40(sp)
 4b2:	f06a                	sd	s10,32(sp)
 4b4:	ec6e                	sd	s11,24(sp)
 4b6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b8:	0005c903          	lbu	s2,0(a1)
 4bc:	18090f63          	beqz	s2,65a <vprintf+0x1c0>
 4c0:	8aaa                	mv	s5,a0
 4c2:	8b32                	mv	s6,a2
 4c4:	00158493          	addi	s1,a1,1
  state = 0;
 4c8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ca:	02500a13          	li	s4,37
      if(c == 'd'){
 4ce:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4d2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4d6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4da:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4de:	00000b97          	auipc	s7,0x0
 4e2:	3aab8b93          	addi	s7,s7,938 # 888 <digits>
 4e6:	a839                	j	504 <vprintf+0x6a>
        putc(fd, c);
 4e8:	85ca                	mv	a1,s2
 4ea:	8556                	mv	a0,s5
 4ec:	00000097          	auipc	ra,0x0
 4f0:	ee2080e7          	jalr	-286(ra) # 3ce <putc>
 4f4:	a019                	j	4fa <vprintf+0x60>
    } else if(state == '%'){
 4f6:	01498f63          	beq	s3,s4,514 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4fa:	0485                	addi	s1,s1,1
 4fc:	fff4c903          	lbu	s2,-1(s1)
 500:	14090d63          	beqz	s2,65a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 504:	0009079b          	sext.w	a5,s2
    if(state == 0){
 508:	fe0997e3          	bnez	s3,4f6 <vprintf+0x5c>
      if(c == '%'){
 50c:	fd479ee3          	bne	a5,s4,4e8 <vprintf+0x4e>
        state = '%';
 510:	89be                	mv	s3,a5
 512:	b7e5                	j	4fa <vprintf+0x60>
      if(c == 'd'){
 514:	05878063          	beq	a5,s8,554 <vprintf+0xba>
      } else if(c == 'l') {
 518:	05978c63          	beq	a5,s9,570 <vprintf+0xd6>
      } else if(c == 'x') {
 51c:	07a78863          	beq	a5,s10,58c <vprintf+0xf2>
      } else if(c == 'p') {
 520:	09b78463          	beq	a5,s11,5a8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 524:	07300713          	li	a4,115
 528:	0ce78663          	beq	a5,a4,5f4 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 52c:	06300713          	li	a4,99
 530:	0ee78e63          	beq	a5,a4,62c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 534:	11478863          	beq	a5,s4,644 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 538:	85d2                	mv	a1,s4
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	e92080e7          	jalr	-366(ra) # 3ce <putc>
        putc(fd, c);
 544:	85ca                	mv	a1,s2
 546:	8556                	mv	a0,s5
 548:	00000097          	auipc	ra,0x0
 54c:	e86080e7          	jalr	-378(ra) # 3ce <putc>
      }
      state = 0;
 550:	4981                	li	s3,0
 552:	b765                	j	4fa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 554:	008b0913          	addi	s2,s6,8
 558:	4685                	li	a3,1
 55a:	4629                	li	a2,10
 55c:	000b2583          	lw	a1,0(s6)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e8e080e7          	jalr	-370(ra) # 3f0 <printint>
 56a:	8b4a                	mv	s6,s2
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b771                	j	4fa <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 570:	008b0913          	addi	s2,s6,8
 574:	4681                	li	a3,0
 576:	4629                	li	a2,10
 578:	000b2583          	lw	a1,0(s6)
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	e72080e7          	jalr	-398(ra) # 3f0 <printint>
 586:	8b4a                	mv	s6,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	bf85                	j	4fa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 58c:	008b0913          	addi	s2,s6,8
 590:	4681                	li	a3,0
 592:	4641                	li	a2,16
 594:	000b2583          	lw	a1,0(s6)
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e56080e7          	jalr	-426(ra) # 3f0 <printint>
 5a2:	8b4a                	mv	s6,s2
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	bf91                	j	4fa <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5a8:	008b0793          	addi	a5,s6,8
 5ac:	f8f43423          	sd	a5,-120(s0)
 5b0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5b4:	03000593          	li	a1,48
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	e14080e7          	jalr	-492(ra) # 3ce <putc>
  putc(fd, 'x');
 5c2:	85ea                	mv	a1,s10
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e08080e7          	jalr	-504(ra) # 3ce <putc>
 5ce:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d0:	03c9d793          	srli	a5,s3,0x3c
 5d4:	97de                	add	a5,a5,s7
 5d6:	0007c583          	lbu	a1,0(a5)
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	df2080e7          	jalr	-526(ra) # 3ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5e4:	0992                	slli	s3,s3,0x4
 5e6:	397d                	addiw	s2,s2,-1
 5e8:	fe0914e3          	bnez	s2,5d0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5ec:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b721                	j	4fa <vprintf+0x60>
        s = va_arg(ap, char*);
 5f4:	008b0993          	addi	s3,s6,8
 5f8:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5fc:	02090163          	beqz	s2,61e <vprintf+0x184>
        while(*s != 0){
 600:	00094583          	lbu	a1,0(s2)
 604:	c9a1                	beqz	a1,654 <vprintf+0x1ba>
          putc(fd, *s);
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	dc6080e7          	jalr	-570(ra) # 3ce <putc>
          s++;
 610:	0905                	addi	s2,s2,1
        while(*s != 0){
 612:	00094583          	lbu	a1,0(s2)
 616:	f9e5                	bnez	a1,606 <vprintf+0x16c>
        s = va_arg(ap, char*);
 618:	8b4e                	mv	s6,s3
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bdf9                	j	4fa <vprintf+0x60>
          s = "(null)";
 61e:	00000917          	auipc	s2,0x0
 622:	26290913          	addi	s2,s2,610 # 880 <malloc+0x11c>
        while(*s != 0){
 626:	02800593          	li	a1,40
 62a:	bff1                	j	606 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 62c:	008b0913          	addi	s2,s6,8
 630:	000b4583          	lbu	a1,0(s6)
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	d98080e7          	jalr	-616(ra) # 3ce <putc>
 63e:	8b4a                	mv	s6,s2
      state = 0;
 640:	4981                	li	s3,0
 642:	bd65                	j	4fa <vprintf+0x60>
        putc(fd, c);
 644:	85d2                	mv	a1,s4
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	d86080e7          	jalr	-634(ra) # 3ce <putc>
      state = 0;
 650:	4981                	li	s3,0
 652:	b565                	j	4fa <vprintf+0x60>
        s = va_arg(ap, char*);
 654:	8b4e                	mv	s6,s3
      state = 0;
 656:	4981                	li	s3,0
 658:	b54d                	j	4fa <vprintf+0x60>
    }
  }
}
 65a:	70e6                	ld	ra,120(sp)
 65c:	7446                	ld	s0,112(sp)
 65e:	74a6                	ld	s1,104(sp)
 660:	7906                	ld	s2,96(sp)
 662:	69e6                	ld	s3,88(sp)
 664:	6a46                	ld	s4,80(sp)
 666:	6aa6                	ld	s5,72(sp)
 668:	6b06                	ld	s6,64(sp)
 66a:	7be2                	ld	s7,56(sp)
 66c:	7c42                	ld	s8,48(sp)
 66e:	7ca2                	ld	s9,40(sp)
 670:	7d02                	ld	s10,32(sp)
 672:	6de2                	ld	s11,24(sp)
 674:	6109                	addi	sp,sp,128
 676:	8082                	ret

0000000000000678 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 678:	715d                	addi	sp,sp,-80
 67a:	ec06                	sd	ra,24(sp)
 67c:	e822                	sd	s0,16(sp)
 67e:	1000                	addi	s0,sp,32
 680:	e010                	sd	a2,0(s0)
 682:	e414                	sd	a3,8(s0)
 684:	e818                	sd	a4,16(s0)
 686:	ec1c                	sd	a5,24(s0)
 688:	03043023          	sd	a6,32(s0)
 68c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 690:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 694:	8622                	mv	a2,s0
 696:	00000097          	auipc	ra,0x0
 69a:	e04080e7          	jalr	-508(ra) # 49a <vprintf>
}
 69e:	60e2                	ld	ra,24(sp)
 6a0:	6442                	ld	s0,16(sp)
 6a2:	6161                	addi	sp,sp,80
 6a4:	8082                	ret

00000000000006a6 <printf>:

void
printf(const char *fmt, ...)
{
 6a6:	711d                	addi	sp,sp,-96
 6a8:	ec06                	sd	ra,24(sp)
 6aa:	e822                	sd	s0,16(sp)
 6ac:	1000                	addi	s0,sp,32
 6ae:	e40c                	sd	a1,8(s0)
 6b0:	e810                	sd	a2,16(s0)
 6b2:	ec14                	sd	a3,24(s0)
 6b4:	f018                	sd	a4,32(s0)
 6b6:	f41c                	sd	a5,40(s0)
 6b8:	03043823          	sd	a6,48(s0)
 6bc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6c0:	00840613          	addi	a2,s0,8
 6c4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6c8:	85aa                	mv	a1,a0
 6ca:	4505                	li	a0,1
 6cc:	00000097          	auipc	ra,0x0
 6d0:	dce080e7          	jalr	-562(ra) # 49a <vprintf>
}
 6d4:	60e2                	ld	ra,24(sp)
 6d6:	6442                	ld	s0,16(sp)
 6d8:	6125                	addi	sp,sp,96
 6da:	8082                	ret

00000000000006dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6dc:	1141                	addi	sp,sp,-16
 6de:	e422                	sd	s0,8(sp)
 6e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e6:	00000797          	auipc	a5,0x0
 6ea:	1ba7b783          	ld	a5,442(a5) # 8a0 <freep>
 6ee:	a805                	j	71e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6f0:	4618                	lw	a4,8(a2)
 6f2:	9db9                	addw	a1,a1,a4
 6f4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f8:	6398                	ld	a4,0(a5)
 6fa:	6318                	ld	a4,0(a4)
 6fc:	fee53823          	sd	a4,-16(a0)
 700:	a091                	j	744 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 702:	ff852703          	lw	a4,-8(a0)
 706:	9e39                	addw	a2,a2,a4
 708:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 70a:	ff053703          	ld	a4,-16(a0)
 70e:	e398                	sd	a4,0(a5)
 710:	a099                	j	756 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 712:	6398                	ld	a4,0(a5)
 714:	00e7e463          	bltu	a5,a4,71c <free+0x40>
 718:	00e6ea63          	bltu	a3,a4,72c <free+0x50>
{
 71c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71e:	fed7fae3          	bgeu	a5,a3,712 <free+0x36>
 722:	6398                	ld	a4,0(a5)
 724:	00e6e463          	bltu	a3,a4,72c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 728:	fee7eae3          	bltu	a5,a4,71c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 72c:	ff852583          	lw	a1,-8(a0)
 730:	6390                	ld	a2,0(a5)
 732:	02059713          	slli	a4,a1,0x20
 736:	9301                	srli	a4,a4,0x20
 738:	0712                	slli	a4,a4,0x4
 73a:	9736                	add	a4,a4,a3
 73c:	fae60ae3          	beq	a2,a4,6f0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 740:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 744:	4790                	lw	a2,8(a5)
 746:	02061713          	slli	a4,a2,0x20
 74a:	9301                	srli	a4,a4,0x20
 74c:	0712                	slli	a4,a4,0x4
 74e:	973e                	add	a4,a4,a5
 750:	fae689e3          	beq	a3,a4,702 <free+0x26>
  } else
    p->s.ptr = bp;
 754:	e394                	sd	a3,0(a5)
  freep = p;
 756:	00000717          	auipc	a4,0x0
 75a:	14f73523          	sd	a5,330(a4) # 8a0 <freep>
}
 75e:	6422                	ld	s0,8(sp)
 760:	0141                	addi	sp,sp,16
 762:	8082                	ret

0000000000000764 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 764:	7139                	addi	sp,sp,-64
 766:	fc06                	sd	ra,56(sp)
 768:	f822                	sd	s0,48(sp)
 76a:	f426                	sd	s1,40(sp)
 76c:	f04a                	sd	s2,32(sp)
 76e:	ec4e                	sd	s3,24(sp)
 770:	e852                	sd	s4,16(sp)
 772:	e456                	sd	s5,8(sp)
 774:	e05a                	sd	s6,0(sp)
 776:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 778:	02051493          	slli	s1,a0,0x20
 77c:	9081                	srli	s1,s1,0x20
 77e:	04bd                	addi	s1,s1,15
 780:	8091                	srli	s1,s1,0x4
 782:	0014899b          	addiw	s3,s1,1
 786:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 788:	00000517          	auipc	a0,0x0
 78c:	11853503          	ld	a0,280(a0) # 8a0 <freep>
 790:	c515                	beqz	a0,7bc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 792:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 794:	4798                	lw	a4,8(a5)
 796:	02977f63          	bgeu	a4,s1,7d4 <malloc+0x70>
 79a:	8a4e                	mv	s4,s3
 79c:	0009871b          	sext.w	a4,s3
 7a0:	6685                	lui	a3,0x1
 7a2:	00d77363          	bgeu	a4,a3,7a8 <malloc+0x44>
 7a6:	6a05                	lui	s4,0x1
 7a8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ac:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7b0:	00000917          	auipc	s2,0x0
 7b4:	0f090913          	addi	s2,s2,240 # 8a0 <freep>
  if(p == (char*)-1)
 7b8:	5afd                	li	s5,-1
 7ba:	a88d                	j	82c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7bc:	00000797          	auipc	a5,0x0
 7c0:	0ec78793          	addi	a5,a5,236 # 8a8 <base>
 7c4:	00000717          	auipc	a4,0x0
 7c8:	0cf73e23          	sd	a5,220(a4) # 8a0 <freep>
 7cc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ce:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7d2:	b7e1                	j	79a <malloc+0x36>
      if(p->s.size == nunits)
 7d4:	02e48b63          	beq	s1,a4,80a <malloc+0xa6>
        p->s.size -= nunits;
 7d8:	4137073b          	subw	a4,a4,s3
 7dc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7de:	1702                	slli	a4,a4,0x20
 7e0:	9301                	srli	a4,a4,0x20
 7e2:	0712                	slli	a4,a4,0x4
 7e4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7e6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ea:	00000717          	auipc	a4,0x0
 7ee:	0aa73b23          	sd	a0,182(a4) # 8a0 <freep>
      return (void*)(p + 1);
 7f2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7f6:	70e2                	ld	ra,56(sp)
 7f8:	7442                	ld	s0,48(sp)
 7fa:	74a2                	ld	s1,40(sp)
 7fc:	7902                	ld	s2,32(sp)
 7fe:	69e2                	ld	s3,24(sp)
 800:	6a42                	ld	s4,16(sp)
 802:	6aa2                	ld	s5,8(sp)
 804:	6b02                	ld	s6,0(sp)
 806:	6121                	addi	sp,sp,64
 808:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 80a:	6398                	ld	a4,0(a5)
 80c:	e118                	sd	a4,0(a0)
 80e:	bff1                	j	7ea <malloc+0x86>
  hp->s.size = nu;
 810:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 814:	0541                	addi	a0,a0,16
 816:	00000097          	auipc	ra,0x0
 81a:	ec6080e7          	jalr	-314(ra) # 6dc <free>
  return freep;
 81e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 822:	d971                	beqz	a0,7f6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 824:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 826:	4798                	lw	a4,8(a5)
 828:	fa9776e3          	bgeu	a4,s1,7d4 <malloc+0x70>
    if(p == freep)
 82c:	00093703          	ld	a4,0(s2)
 830:	853e                	mv	a0,a5
 832:	fef719e3          	bne	a4,a5,824 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 836:	8552                	mv	a0,s4
 838:	00000097          	auipc	ra,0x0
 83c:	b7e080e7          	jalr	-1154(ra) # 3b6 <sbrk>
  if(p == (char*)-1)
 840:	fd5518e3          	bne	a0,s5,810 <malloc+0xac>
        return 0;
 844:	4501                	li	a0,0
 846:	bf45                	j	7f6 <malloc+0x92>
