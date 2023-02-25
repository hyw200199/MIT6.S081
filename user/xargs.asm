
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

void run(char *program, char **args) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84aa                	mv	s1,a0
   e:	892e                	mv	s2,a1
	// for(int i=0;i<argc; i++) {
	// 	printf("i: %s\n", args[i]);
	// }
	if(fork() == 0) { // child exec
  10:	00000097          	auipc	ra,0x0
  14:	3c8080e7          	jalr	968(ra) # 3d8 <fork>
  18:	c519                	beqz	a0,26 <run+0x26>
		exec(program, args);
		exit(0);
	}
	return; // parent return
}
  1a:	60e2                	ld	ra,24(sp)
  1c:	6442                	ld	s0,16(sp)
  1e:	64a2                	ld	s1,8(sp)
  20:	6902                	ld	s2,0(sp)
  22:	6105                	addi	sp,sp,32
  24:	8082                	ret
		exec(program, args);
  26:	85ca                	mv	a1,s2
  28:	8526                	mv	a0,s1
  2a:	00000097          	auipc	ra,0x0
  2e:	3ee080e7          	jalr	1006(ra) # 418 <exec>
		exit(0);
  32:	4501                	li	a0,0
  34:	00000097          	auipc	ra,0x0
  38:	3ac080e7          	jalr	940(ra) # 3e0 <exit>

000000000000003c <main>:

int main(int argc, char *argv[]){
  3c:	81010113          	addi	sp,sp,-2032
  40:	7e113423          	sd	ra,2024(sp)
  44:	7e813023          	sd	s0,2016(sp)
  48:	7c913c23          	sd	s1,2008(sp)
  4c:	7d213823          	sd	s2,2000(sp)
  50:	7d313423          	sd	s3,1992(sp)
  54:	7d413023          	sd	s4,1984(sp)
  58:	7b513c23          	sd	s5,1976(sp)
  5c:	7b613823          	sd	s6,1968(sp)
  60:	7b713423          	sd	s7,1960(sp)
  64:	7b813023          	sd	s8,1952(sp)
  68:	79913c23          	sd	s9,1944(sp)
  6c:	79a13823          	sd	s10,1936(sp)
  70:	7f010413          	addi	s0,sp,2032
  74:	b9010113          	addi	sp,sp,-1136
  78:	8aae                	mv	s5,a1
	char buf[2048]; char *p = buf, *last_p = buf;
	char *argsbuf[128]; char **args = argsbuf;
	for(int i=1;i<argc;i++) {
  7a:	4785                	li	a5,1
  7c:	04a7dc63          	bge	a5,a0,d4 <main+0x98>
  80:	00858713          	addi	a4,a1,8
  84:	77fd                	lui	a5,0xfffff
  86:	40078793          	addi	a5,a5,1024 # fffffffffffff400 <__global_pointer$+0xffffffffffffe2e7>
  8a:	fa040693          	addi	a3,s0,-96
  8e:	97b6                	add	a5,a5,a3
  90:	fff5091b          	addiw	s2,a0,-1
  94:	1902                	slli	s2,s2,0x20
  96:	02095913          	srli	s2,s2,0x20
  9a:	090e                	slli	s2,s2,0x3
  9c:	993e                	add	s2,s2,a5
		*args = argv[i];
  9e:	6314                	ld	a3,0(a4)
  a0:	e394                	sd	a3,0(a5)
		args++;
  a2:	07a1                	addi	a5,a5,8
	for(int i=1;i<argc;i++) {
  a4:	0721                	addi	a4,a4,8
  a6:	ff279ce3          	bne	a5,s2,9e <main+0x62>
  aa:	77fd                	lui	a5,0xfffff
  ac:	7a178713          	addi	a4,a5,1953 # fffffffffffff7a1 <__global_pointer$+0xffffffffffffe688>
  b0:	00e404b3          	add	s1,s0,a4
			*(pa++) = last_p; // save argument
			last_p = p+1;
		} else if (*p == '\n') {
			*p = '\0';
			*(pa++) = last_p;
			last_p = p+1;
  b4:	8a4a                	mv	s4,s2
	char buf[2048]; char *p = buf, *last_p = buf;
  b6:	7a078793          	addi	a5,a5,1952
  ba:	00f40b33          	add	s6,s0,a5
		if(*p == ' ') {
  be:	02000b93          	li	s7,32
		} else if (*p == '\n') {
  c2:	4c29                	li	s8,10
			*pa = 0; // null-terminated list
			run(argv[1], argsbuf);
  c4:	7cfd                	lui	s9,0xfffff
  c6:	400c8c93          	addi	s9,s9,1024 # fffffffffffff400 <__global_pointer$+0xffffffffffffe2e7>
  ca:	fa040793          	addi	a5,s0,-96
  ce:	9cbe                	add	s9,s9,a5
  d0:	8d4a                	mv	s10,s2
  d2:	a839                	j	f0 <main+0xb4>
	char *argsbuf[128]; char **args = argsbuf;
  d4:	797d                	lui	s2,0xfffff
  d6:	40090913          	addi	s2,s2,1024 # fffffffffffff400 <__global_pointer$+0xffffffffffffe2e7>
  da:	fa040793          	addi	a5,s0,-96
  de:	993e                	add	s2,s2,a5
  e0:	b7e9                	j	aa <main+0x6e>
			*p = '\0';
  e2:	fe048fa3          	sb	zero,-1(s1)
			*(pa++) = last_p; // save argument
  e6:	016a3023          	sd	s6,0(s4)
  ea:	0a21                	addi	s4,s4,8
			last_p = p+1;
  ec:	8b26                	mv	s6,s1
			pa = args; // reset
		}
		p++;
  ee:	0485                	addi	s1,s1,1
  f0:	fff48993          	addi	s3,s1,-1
	while(read(0, p, 1) != 0) {
  f4:	4605                	li	a2,1
  f6:	85ce                	mv	a1,s3
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	2fe080e7          	jalr	766(ra) # 3f8 <read>
 102:	c51d                	beqz	a0,130 <main+0xf4>
		if(*p == ' ') {
 104:	fff4c783          	lbu	a5,-1(s1)
 108:	fd778de3          	beq	a5,s7,e2 <main+0xa6>
		} else if (*p == '\n') {
 10c:	ff8791e3          	bne	a5,s8,ee <main+0xb2>
			*p = '\0';
 110:	fe048fa3          	sb	zero,-1(s1)
			*(pa++) = last_p;
 114:	016a3023          	sd	s6,0(s4)
			*pa = 0; // null-terminated list
 118:	000a3423          	sd	zero,8(s4)
			run(argv[1], argsbuf);
 11c:	85e6                	mv	a1,s9
 11e:	008ab503          	ld	a0,8(s5)
 122:	00000097          	auipc	ra,0x0
 126:	ede080e7          	jalr	-290(ra) # 0 <run>
 12a:	8a6a                	mv	s4,s10
			last_p = p+1;
 12c:	8b26                	mv	s6,s1
 12e:	b7c1                	j	ee <main+0xb2>
	}
	if(pa != args) { // has one line left
 130:	032a0463          	beq	s4,s2,158 <main+0x11c>
		*p = '\0';
 134:	00098023          	sb	zero,0(s3)
		*(pa++) = last_p;
 138:	016a3023          	sd	s6,0(s4)
		*pa = 0; // null-terminated list
 13c:	000a3423          	sd	zero,8(s4)
		run(argv[1], argsbuf);
 140:	75fd                	lui	a1,0xfffff
 142:	40058593          	addi	a1,a1,1024 # fffffffffffff400 <__global_pointer$+0xffffffffffffe2e7>
 146:	fa040793          	addi	a5,s0,-96
 14a:	95be                	add	a1,a1,a5
 14c:	008ab503          	ld	a0,8(s5)
 150:	00000097          	auipc	ra,0x0
 154:	eb0080e7          	jalr	-336(ra) # 0 <run>
	}
	while(wait(0) != -1) {};
 158:	54fd                	li	s1,-1
 15a:	4501                	li	a0,0
 15c:	00000097          	auipc	ra,0x0
 160:	28c080e7          	jalr	652(ra) # 3e8 <wait>
 164:	fe951be3          	bne	a0,s1,15a <main+0x11e>
	exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	276080e7          	jalr	630(ra) # 3e0 <exit>

0000000000000172 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 178:	87aa                	mv	a5,a0
 17a:	0585                	addi	a1,a1,1
 17c:	0785                	addi	a5,a5,1
 17e:	fff5c703          	lbu	a4,-1(a1)
 182:	fee78fa3          	sb	a4,-1(a5)
 186:	fb75                	bnez	a4,17a <strcpy+0x8>
    ;
  return os;
}
 188:	6422                	ld	s0,8(sp)
 18a:	0141                	addi	sp,sp,16
 18c:	8082                	ret

000000000000018e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e422                	sd	s0,8(sp)
 192:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	cb91                	beqz	a5,1ac <strcmp+0x1e>
 19a:	0005c703          	lbu	a4,0(a1)
 19e:	00f71763          	bne	a4,a5,1ac <strcmp+0x1e>
    p++, q++;
 1a2:	0505                	addi	a0,a0,1
 1a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	fbe5                	bnez	a5,19a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ac:	0005c503          	lbu	a0,0(a1)
}
 1b0:	40a7853b          	subw	a0,a5,a0
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strlen>:

uint
strlen(const char *s)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cf91                	beqz	a5,1e0 <strlen+0x26>
 1c6:	0505                	addi	a0,a0,1
 1c8:	87aa                	mv	a5,a0
 1ca:	4685                	li	a3,1
 1cc:	9e89                	subw	a3,a3,a0
 1ce:	00f6853b          	addw	a0,a3,a5
 1d2:	0785                	addi	a5,a5,1
 1d4:	fff7c703          	lbu	a4,-1(a5)
 1d8:	fb7d                	bnez	a4,1ce <strlen+0x14>
    ;
  return n;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret
  for(n = 0; s[n]; n++)
 1e0:	4501                	li	a0,0
 1e2:	bfe5                	j	1da <strlen+0x20>

00000000000001e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ea:	ca19                	beqz	a2,200 <memset+0x1c>
 1ec:	87aa                	mv	a5,a0
 1ee:	1602                	slli	a2,a2,0x20
 1f0:	9201                	srli	a2,a2,0x20
 1f2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1fa:	0785                	addi	a5,a5,1
 1fc:	fee79de3          	bne	a5,a4,1f6 <memset+0x12>
  }
  return dst;
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret

0000000000000206 <strchr>:

char*
strchr(const char *s, char c)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 20c:	00054783          	lbu	a5,0(a0)
 210:	cb99                	beqz	a5,226 <strchr+0x20>
    if(*s == c)
 212:	00f58763          	beq	a1,a5,220 <strchr+0x1a>
  for(; *s; s++)
 216:	0505                	addi	a0,a0,1
 218:	00054783          	lbu	a5,0(a0)
 21c:	fbfd                	bnez	a5,212 <strchr+0xc>
      return (char*)s;
  return 0;
 21e:	4501                	li	a0,0
}
 220:	6422                	ld	s0,8(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret
  return 0;
 226:	4501                	li	a0,0
 228:	bfe5                	j	220 <strchr+0x1a>

000000000000022a <gets>:

char*
gets(char *buf, int max)
{
 22a:	711d                	addi	sp,sp,-96
 22c:	ec86                	sd	ra,88(sp)
 22e:	e8a2                	sd	s0,80(sp)
 230:	e4a6                	sd	s1,72(sp)
 232:	e0ca                	sd	s2,64(sp)
 234:	fc4e                	sd	s3,56(sp)
 236:	f852                	sd	s4,48(sp)
 238:	f456                	sd	s5,40(sp)
 23a:	f05a                	sd	s6,32(sp)
 23c:	ec5e                	sd	s7,24(sp)
 23e:	1080                	addi	s0,sp,96
 240:	8baa                	mv	s7,a0
 242:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 244:	892a                	mv	s2,a0
 246:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 248:	4aa9                	li	s5,10
 24a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 24c:	89a6                	mv	s3,s1
 24e:	2485                	addiw	s1,s1,1
 250:	0344d863          	bge	s1,s4,280 <gets+0x56>
    cc = read(0, &c, 1);
 254:	4605                	li	a2,1
 256:	faf40593          	addi	a1,s0,-81
 25a:	4501                	li	a0,0
 25c:	00000097          	auipc	ra,0x0
 260:	19c080e7          	jalr	412(ra) # 3f8 <read>
    if(cc < 1)
 264:	00a05e63          	blez	a0,280 <gets+0x56>
    buf[i++] = c;
 268:	faf44783          	lbu	a5,-81(s0)
 26c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 270:	01578763          	beq	a5,s5,27e <gets+0x54>
 274:	0905                	addi	s2,s2,1
 276:	fd679be3          	bne	a5,s6,24c <gets+0x22>
  for(i=0; i+1 < max; ){
 27a:	89a6                	mv	s3,s1
 27c:	a011                	j	280 <gets+0x56>
 27e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 280:	99de                	add	s3,s3,s7
 282:	00098023          	sb	zero,0(s3)
  return buf;
}
 286:	855e                	mv	a0,s7
 288:	60e6                	ld	ra,88(sp)
 28a:	6446                	ld	s0,80(sp)
 28c:	64a6                	ld	s1,72(sp)
 28e:	6906                	ld	s2,64(sp)
 290:	79e2                	ld	s3,56(sp)
 292:	7a42                	ld	s4,48(sp)
 294:	7aa2                	ld	s5,40(sp)
 296:	7b02                	ld	s6,32(sp)
 298:	6be2                	ld	s7,24(sp)
 29a:	6125                	addi	sp,sp,96
 29c:	8082                	ret

000000000000029e <stat>:

int
stat(const char *n, struct stat *st)
{
 29e:	1101                	addi	sp,sp,-32
 2a0:	ec06                	sd	ra,24(sp)
 2a2:	e822                	sd	s0,16(sp)
 2a4:	e426                	sd	s1,8(sp)
 2a6:	e04a                	sd	s2,0(sp)
 2a8:	1000                	addi	s0,sp,32
 2aa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ac:	4581                	li	a1,0
 2ae:	00000097          	auipc	ra,0x0
 2b2:	172080e7          	jalr	370(ra) # 420 <open>
  if(fd < 0)
 2b6:	02054563          	bltz	a0,2e0 <stat+0x42>
 2ba:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2bc:	85ca                	mv	a1,s2
 2be:	00000097          	auipc	ra,0x0
 2c2:	17a080e7          	jalr	378(ra) # 438 <fstat>
 2c6:	892a                	mv	s2,a0
  close(fd);
 2c8:	8526                	mv	a0,s1
 2ca:	00000097          	auipc	ra,0x0
 2ce:	13e080e7          	jalr	318(ra) # 408 <close>
  return r;
}
 2d2:	854a                	mv	a0,s2
 2d4:	60e2                	ld	ra,24(sp)
 2d6:	6442                	ld	s0,16(sp)
 2d8:	64a2                	ld	s1,8(sp)
 2da:	6902                	ld	s2,0(sp)
 2dc:	6105                	addi	sp,sp,32
 2de:	8082                	ret
    return -1;
 2e0:	597d                	li	s2,-1
 2e2:	bfc5                	j	2d2 <stat+0x34>

00000000000002e4 <atoi>:

int
atoi(const char *s)
{
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e422                	sd	s0,8(sp)
 2e8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ea:	00054603          	lbu	a2,0(a0)
 2ee:	fd06079b          	addiw	a5,a2,-48
 2f2:	0ff7f793          	andi	a5,a5,255
 2f6:	4725                	li	a4,9
 2f8:	02f76963          	bltu	a4,a5,32a <atoi+0x46>
 2fc:	86aa                	mv	a3,a0
  n = 0;
 2fe:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 300:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 302:	0685                	addi	a3,a3,1
 304:	0025179b          	slliw	a5,a0,0x2
 308:	9fa9                	addw	a5,a5,a0
 30a:	0017979b          	slliw	a5,a5,0x1
 30e:	9fb1                	addw	a5,a5,a2
 310:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 314:	0006c603          	lbu	a2,0(a3)
 318:	fd06071b          	addiw	a4,a2,-48
 31c:	0ff77713          	andi	a4,a4,255
 320:	fee5f1e3          	bgeu	a1,a4,302 <atoi+0x1e>
  return n;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
  n = 0;
 32a:	4501                	li	a0,0
 32c:	bfe5                	j	324 <atoi+0x40>

000000000000032e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 334:	02b57463          	bgeu	a0,a1,35c <memmove+0x2e>
    while(n-- > 0)
 338:	00c05f63          	blez	a2,356 <memmove+0x28>
 33c:	1602                	slli	a2,a2,0x20
 33e:	9201                	srli	a2,a2,0x20
 340:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 344:	872a                	mv	a4,a0
      *dst++ = *src++;
 346:	0585                	addi	a1,a1,1
 348:	0705                	addi	a4,a4,1
 34a:	fff5c683          	lbu	a3,-1(a1)
 34e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 352:	fee79ae3          	bne	a5,a4,346 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret
    dst += n;
 35c:	00c50733          	add	a4,a0,a2
    src += n;
 360:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 362:	fec05ae3          	blez	a2,356 <memmove+0x28>
 366:	fff6079b          	addiw	a5,a2,-1
 36a:	1782                	slli	a5,a5,0x20
 36c:	9381                	srli	a5,a5,0x20
 36e:	fff7c793          	not	a5,a5
 372:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 374:	15fd                	addi	a1,a1,-1
 376:	177d                	addi	a4,a4,-1
 378:	0005c683          	lbu	a3,0(a1)
 37c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 380:	fee79ae3          	bne	a5,a4,374 <memmove+0x46>
 384:	bfc9                	j	356 <memmove+0x28>

0000000000000386 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e422                	sd	s0,8(sp)
 38a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38c:	ca05                	beqz	a2,3bc <memcmp+0x36>
 38e:	fff6069b          	addiw	a3,a2,-1
 392:	1682                	slli	a3,a3,0x20
 394:	9281                	srli	a3,a3,0x20
 396:	0685                	addi	a3,a3,1
 398:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 39a:	00054783          	lbu	a5,0(a0)
 39e:	0005c703          	lbu	a4,0(a1)
 3a2:	00e79863          	bne	a5,a4,3b2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a6:	0505                	addi	a0,a0,1
    p2++;
 3a8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3aa:	fed518e3          	bne	a0,a3,39a <memcmp+0x14>
  }
  return 0;
 3ae:	4501                	li	a0,0
 3b0:	a019                	j	3b6 <memcmp+0x30>
      return *p1 - *p2;
 3b2:	40e7853b          	subw	a0,a5,a4
}
 3b6:	6422                	ld	s0,8(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
  return 0;
 3bc:	4501                	li	a0,0
 3be:	bfe5                	j	3b6 <memcmp+0x30>

00000000000003c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c8:	00000097          	auipc	ra,0x0
 3cc:	f66080e7          	jalr	-154(ra) # 32e <memmove>
}
 3d0:	60a2                	ld	ra,8(sp)
 3d2:	6402                	ld	s0,0(sp)
 3d4:	0141                	addi	sp,sp,16
 3d6:	8082                	ret

00000000000003d8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d8:	4885                	li	a7,1
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e0:	4889                	li	a7,2
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e8:	488d                	li	a7,3
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f0:	4891                	li	a7,4
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <read>:
.global read
read:
 li a7, SYS_read
 3f8:	4895                	li	a7,5
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <write>:
.global write
write:
 li a7, SYS_write
 400:	48c1                	li	a7,16
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <close>:
.global close
close:
 li a7, SYS_close
 408:	48d5                	li	a7,21
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <kill>:
.global kill
kill:
 li a7, SYS_kill
 410:	4899                	li	a7,6
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <exec>:
.global exec
exec:
 li a7, SYS_exec
 418:	489d                	li	a7,7
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <open>:
.global open
open:
 li a7, SYS_open
 420:	48bd                	li	a7,15
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 428:	48c5                	li	a7,17
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 430:	48c9                	li	a7,18
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 438:	48a1                	li	a7,8
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <link>:
.global link
link:
 li a7, SYS_link
 440:	48cd                	li	a7,19
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 448:	48d1                	li	a7,20
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 450:	48a5                	li	a7,9
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <dup>:
.global dup
dup:
 li a7, SYS_dup
 458:	48a9                	li	a7,10
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 460:	48ad                	li	a7,11
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 468:	48b1                	li	a7,12
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 470:	48b5                	li	a7,13
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 478:	48b9                	li	a7,14
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 480:	1101                	addi	sp,sp,-32
 482:	ec06                	sd	ra,24(sp)
 484:	e822                	sd	s0,16(sp)
 486:	1000                	addi	s0,sp,32
 488:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48c:	4605                	li	a2,1
 48e:	fef40593          	addi	a1,s0,-17
 492:	00000097          	auipc	ra,0x0
 496:	f6e080e7          	jalr	-146(ra) # 400 <write>
}
 49a:	60e2                	ld	ra,24(sp)
 49c:	6442                	ld	s0,16(sp)
 49e:	6105                	addi	sp,sp,32
 4a0:	8082                	ret

00000000000004a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a2:	7139                	addi	sp,sp,-64
 4a4:	fc06                	sd	ra,56(sp)
 4a6:	f822                	sd	s0,48(sp)
 4a8:	f426                	sd	s1,40(sp)
 4aa:	f04a                	sd	s2,32(sp)
 4ac:	ec4e                	sd	s3,24(sp)
 4ae:	0080                	addi	s0,sp,64
 4b0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b2:	c299                	beqz	a3,4b8 <printint+0x16>
 4b4:	0805c863          	bltz	a1,544 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b8:	2581                	sext.w	a1,a1
  neg = 0;
 4ba:	4881                	li	a7,0
 4bc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4c0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c2:	2601                	sext.w	a2,a2
 4c4:	00000517          	auipc	a0,0x0
 4c8:	44450513          	addi	a0,a0,1092 # 908 <digits>
 4cc:	883a                	mv	a6,a4
 4ce:	2705                	addiw	a4,a4,1
 4d0:	02c5f7bb          	remuw	a5,a1,a2
 4d4:	1782                	slli	a5,a5,0x20
 4d6:	9381                	srli	a5,a5,0x20
 4d8:	97aa                	add	a5,a5,a0
 4da:	0007c783          	lbu	a5,0(a5)
 4de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e2:	0005879b          	sext.w	a5,a1
 4e6:	02c5d5bb          	divuw	a1,a1,a2
 4ea:	0685                	addi	a3,a3,1
 4ec:	fec7f0e3          	bgeu	a5,a2,4cc <printint+0x2a>
  if(neg)
 4f0:	00088b63          	beqz	a7,506 <printint+0x64>
    buf[i++] = '-';
 4f4:	fd040793          	addi	a5,s0,-48
 4f8:	973e                	add	a4,a4,a5
 4fa:	02d00793          	li	a5,45
 4fe:	fef70823          	sb	a5,-16(a4)
 502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 506:	02e05863          	blez	a4,536 <printint+0x94>
 50a:	fc040793          	addi	a5,s0,-64
 50e:	00e78933          	add	s2,a5,a4
 512:	fff78993          	addi	s3,a5,-1
 516:	99ba                	add	s3,s3,a4
 518:	377d                	addiw	a4,a4,-1
 51a:	1702                	slli	a4,a4,0x20
 51c:	9301                	srli	a4,a4,0x20
 51e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 522:	fff94583          	lbu	a1,-1(s2)
 526:	8526                	mv	a0,s1
 528:	00000097          	auipc	ra,0x0
 52c:	f58080e7          	jalr	-168(ra) # 480 <putc>
  while(--i >= 0)
 530:	197d                	addi	s2,s2,-1
 532:	ff3918e3          	bne	s2,s3,522 <printint+0x80>
}
 536:	70e2                	ld	ra,56(sp)
 538:	7442                	ld	s0,48(sp)
 53a:	74a2                	ld	s1,40(sp)
 53c:	7902                	ld	s2,32(sp)
 53e:	69e2                	ld	s3,24(sp)
 540:	6121                	addi	sp,sp,64
 542:	8082                	ret
    x = -xx;
 544:	40b005bb          	negw	a1,a1
    neg = 1;
 548:	4885                	li	a7,1
    x = -xx;
 54a:	bf8d                	j	4bc <printint+0x1a>

000000000000054c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54c:	7119                	addi	sp,sp,-128
 54e:	fc86                	sd	ra,120(sp)
 550:	f8a2                	sd	s0,112(sp)
 552:	f4a6                	sd	s1,104(sp)
 554:	f0ca                	sd	s2,96(sp)
 556:	ecce                	sd	s3,88(sp)
 558:	e8d2                	sd	s4,80(sp)
 55a:	e4d6                	sd	s5,72(sp)
 55c:	e0da                	sd	s6,64(sp)
 55e:	fc5e                	sd	s7,56(sp)
 560:	f862                	sd	s8,48(sp)
 562:	f466                	sd	s9,40(sp)
 564:	f06a                	sd	s10,32(sp)
 566:	ec6e                	sd	s11,24(sp)
 568:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 56a:	0005c903          	lbu	s2,0(a1)
 56e:	18090f63          	beqz	s2,70c <vprintf+0x1c0>
 572:	8aaa                	mv	s5,a0
 574:	8b32                	mv	s6,a2
 576:	00158493          	addi	s1,a1,1
  state = 0;
 57a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 57c:	02500a13          	li	s4,37
      if(c == 'd'){
 580:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 584:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 588:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 58c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 590:	00000b97          	auipc	s7,0x0
 594:	378b8b93          	addi	s7,s7,888 # 908 <digits>
 598:	a839                	j	5b6 <vprintf+0x6a>
        putc(fd, c);
 59a:	85ca                	mv	a1,s2
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	ee2080e7          	jalr	-286(ra) # 480 <putc>
 5a6:	a019                	j	5ac <vprintf+0x60>
    } else if(state == '%'){
 5a8:	01498f63          	beq	s3,s4,5c6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5ac:	0485                	addi	s1,s1,1
 5ae:	fff4c903          	lbu	s2,-1(s1)
 5b2:	14090d63          	beqz	s2,70c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5b6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5ba:	fe0997e3          	bnez	s3,5a8 <vprintf+0x5c>
      if(c == '%'){
 5be:	fd479ee3          	bne	a5,s4,59a <vprintf+0x4e>
        state = '%';
 5c2:	89be                	mv	s3,a5
 5c4:	b7e5                	j	5ac <vprintf+0x60>
      if(c == 'd'){
 5c6:	05878063          	beq	a5,s8,606 <vprintf+0xba>
      } else if(c == 'l') {
 5ca:	05978c63          	beq	a5,s9,622 <vprintf+0xd6>
      } else if(c == 'x') {
 5ce:	07a78863          	beq	a5,s10,63e <vprintf+0xf2>
      } else if(c == 'p') {
 5d2:	09b78463          	beq	a5,s11,65a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5d6:	07300713          	li	a4,115
 5da:	0ce78663          	beq	a5,a4,6a6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5de:	06300713          	li	a4,99
 5e2:	0ee78e63          	beq	a5,a4,6de <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5e6:	11478863          	beq	a5,s4,6f6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ea:	85d2                	mv	a1,s4
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e92080e7          	jalr	-366(ra) # 480 <putc>
        putc(fd, c);
 5f6:	85ca                	mv	a1,s2
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e86080e7          	jalr	-378(ra) # 480 <putc>
      }
      state = 0;
 602:	4981                	li	s3,0
 604:	b765                	j	5ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 606:	008b0913          	addi	s2,s6,8
 60a:	4685                	li	a3,1
 60c:	4629                	li	a2,10
 60e:	000b2583          	lw	a1,0(s6)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	e8e080e7          	jalr	-370(ra) # 4a2 <printint>
 61c:	8b4a                	mv	s6,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	b771                	j	5ac <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 622:	008b0913          	addi	s2,s6,8
 626:	4681                	li	a3,0
 628:	4629                	li	a2,10
 62a:	000b2583          	lw	a1,0(s6)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	e72080e7          	jalr	-398(ra) # 4a2 <printint>
 638:	8b4a                	mv	s6,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bf85                	j	5ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 63e:	008b0913          	addi	s2,s6,8
 642:	4681                	li	a3,0
 644:	4641                	li	a2,16
 646:	000b2583          	lw	a1,0(s6)
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	e56080e7          	jalr	-426(ra) # 4a2 <printint>
 654:	8b4a                	mv	s6,s2
      state = 0;
 656:	4981                	li	s3,0
 658:	bf91                	j	5ac <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 65a:	008b0793          	addi	a5,s6,8
 65e:	f8f43423          	sd	a5,-120(s0)
 662:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 666:	03000593          	li	a1,48
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	e14080e7          	jalr	-492(ra) # 480 <putc>
  putc(fd, 'x');
 674:	85ea                	mv	a1,s10
 676:	8556                	mv	a0,s5
 678:	00000097          	auipc	ra,0x0
 67c:	e08080e7          	jalr	-504(ra) # 480 <putc>
 680:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 682:	03c9d793          	srli	a5,s3,0x3c
 686:	97de                	add	a5,a5,s7
 688:	0007c583          	lbu	a1,0(a5)
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	df2080e7          	jalr	-526(ra) # 480 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 696:	0992                	slli	s3,s3,0x4
 698:	397d                	addiw	s2,s2,-1
 69a:	fe0914e3          	bnez	s2,682 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 69e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b721                	j	5ac <vprintf+0x60>
        s = va_arg(ap, char*);
 6a6:	008b0993          	addi	s3,s6,8
 6aa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6ae:	02090163          	beqz	s2,6d0 <vprintf+0x184>
        while(*s != 0){
 6b2:	00094583          	lbu	a1,0(s2)
 6b6:	c9a1                	beqz	a1,706 <vprintf+0x1ba>
          putc(fd, *s);
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	dc6080e7          	jalr	-570(ra) # 480 <putc>
          s++;
 6c2:	0905                	addi	s2,s2,1
        while(*s != 0){
 6c4:	00094583          	lbu	a1,0(s2)
 6c8:	f9e5                	bnez	a1,6b8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6ca:	8b4e                	mv	s6,s3
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	bdf9                	j	5ac <vprintf+0x60>
          s = "(null)";
 6d0:	00000917          	auipc	s2,0x0
 6d4:	23090913          	addi	s2,s2,560 # 900 <malloc+0xea>
        while(*s != 0){
 6d8:	02800593          	li	a1,40
 6dc:	bff1                	j	6b8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6de:	008b0913          	addi	s2,s6,8
 6e2:	000b4583          	lbu	a1,0(s6)
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	d98080e7          	jalr	-616(ra) # 480 <putc>
 6f0:	8b4a                	mv	s6,s2
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	bd65                	j	5ac <vprintf+0x60>
        putc(fd, c);
 6f6:	85d2                	mv	a1,s4
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	d86080e7          	jalr	-634(ra) # 480 <putc>
      state = 0;
 702:	4981                	li	s3,0
 704:	b565                	j	5ac <vprintf+0x60>
        s = va_arg(ap, char*);
 706:	8b4e                	mv	s6,s3
      state = 0;
 708:	4981                	li	s3,0
 70a:	b54d                	j	5ac <vprintf+0x60>
    }
  }
}
 70c:	70e6                	ld	ra,120(sp)
 70e:	7446                	ld	s0,112(sp)
 710:	74a6                	ld	s1,104(sp)
 712:	7906                	ld	s2,96(sp)
 714:	69e6                	ld	s3,88(sp)
 716:	6a46                	ld	s4,80(sp)
 718:	6aa6                	ld	s5,72(sp)
 71a:	6b06                	ld	s6,64(sp)
 71c:	7be2                	ld	s7,56(sp)
 71e:	7c42                	ld	s8,48(sp)
 720:	7ca2                	ld	s9,40(sp)
 722:	7d02                	ld	s10,32(sp)
 724:	6de2                	ld	s11,24(sp)
 726:	6109                	addi	sp,sp,128
 728:	8082                	ret

000000000000072a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 72a:	715d                	addi	sp,sp,-80
 72c:	ec06                	sd	ra,24(sp)
 72e:	e822                	sd	s0,16(sp)
 730:	1000                	addi	s0,sp,32
 732:	e010                	sd	a2,0(s0)
 734:	e414                	sd	a3,8(s0)
 736:	e818                	sd	a4,16(s0)
 738:	ec1c                	sd	a5,24(s0)
 73a:	03043023          	sd	a6,32(s0)
 73e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 742:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 746:	8622                	mv	a2,s0
 748:	00000097          	auipc	ra,0x0
 74c:	e04080e7          	jalr	-508(ra) # 54c <vprintf>
}
 750:	60e2                	ld	ra,24(sp)
 752:	6442                	ld	s0,16(sp)
 754:	6161                	addi	sp,sp,80
 756:	8082                	ret

0000000000000758 <printf>:

void
printf(const char *fmt, ...)
{
 758:	711d                	addi	sp,sp,-96
 75a:	ec06                	sd	ra,24(sp)
 75c:	e822                	sd	s0,16(sp)
 75e:	1000                	addi	s0,sp,32
 760:	e40c                	sd	a1,8(s0)
 762:	e810                	sd	a2,16(s0)
 764:	ec14                	sd	a3,24(s0)
 766:	f018                	sd	a4,32(s0)
 768:	f41c                	sd	a5,40(s0)
 76a:	03043823          	sd	a6,48(s0)
 76e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 772:	00840613          	addi	a2,s0,8
 776:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 77a:	85aa                	mv	a1,a0
 77c:	4505                	li	a0,1
 77e:	00000097          	auipc	ra,0x0
 782:	dce080e7          	jalr	-562(ra) # 54c <vprintf>
}
 786:	60e2                	ld	ra,24(sp)
 788:	6442                	ld	s0,16(sp)
 78a:	6125                	addi	sp,sp,96
 78c:	8082                	ret

000000000000078e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78e:	1141                	addi	sp,sp,-16
 790:	e422                	sd	s0,8(sp)
 792:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 794:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 798:	00000797          	auipc	a5,0x0
 79c:	1887b783          	ld	a5,392(a5) # 920 <freep>
 7a0:	a805                	j	7d0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a2:	4618                	lw	a4,8(a2)
 7a4:	9db9                	addw	a1,a1,a4
 7a6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7aa:	6398                	ld	a4,0(a5)
 7ac:	6318                	ld	a4,0(a4)
 7ae:	fee53823          	sd	a4,-16(a0)
 7b2:	a091                	j	7f6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7b4:	ff852703          	lw	a4,-8(a0)
 7b8:	9e39                	addw	a2,a2,a4
 7ba:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7bc:	ff053703          	ld	a4,-16(a0)
 7c0:	e398                	sd	a4,0(a5)
 7c2:	a099                	j	808 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c4:	6398                	ld	a4,0(a5)
 7c6:	00e7e463          	bltu	a5,a4,7ce <free+0x40>
 7ca:	00e6ea63          	bltu	a3,a4,7de <free+0x50>
{
 7ce:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d0:	fed7fae3          	bgeu	a5,a3,7c4 <free+0x36>
 7d4:	6398                	ld	a4,0(a5)
 7d6:	00e6e463          	bltu	a3,a4,7de <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7da:	fee7eae3          	bltu	a5,a4,7ce <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7de:	ff852583          	lw	a1,-8(a0)
 7e2:	6390                	ld	a2,0(a5)
 7e4:	02059713          	slli	a4,a1,0x20
 7e8:	9301                	srli	a4,a4,0x20
 7ea:	0712                	slli	a4,a4,0x4
 7ec:	9736                	add	a4,a4,a3
 7ee:	fae60ae3          	beq	a2,a4,7a2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7f2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f6:	4790                	lw	a2,8(a5)
 7f8:	02061713          	slli	a4,a2,0x20
 7fc:	9301                	srli	a4,a4,0x20
 7fe:	0712                	slli	a4,a4,0x4
 800:	973e                	add	a4,a4,a5
 802:	fae689e3          	beq	a3,a4,7b4 <free+0x26>
  } else
    p->s.ptr = bp;
 806:	e394                	sd	a3,0(a5)
  freep = p;
 808:	00000717          	auipc	a4,0x0
 80c:	10f73c23          	sd	a5,280(a4) # 920 <freep>
}
 810:	6422                	ld	s0,8(sp)
 812:	0141                	addi	sp,sp,16
 814:	8082                	ret

0000000000000816 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 816:	7139                	addi	sp,sp,-64
 818:	fc06                	sd	ra,56(sp)
 81a:	f822                	sd	s0,48(sp)
 81c:	f426                	sd	s1,40(sp)
 81e:	f04a                	sd	s2,32(sp)
 820:	ec4e                	sd	s3,24(sp)
 822:	e852                	sd	s4,16(sp)
 824:	e456                	sd	s5,8(sp)
 826:	e05a                	sd	s6,0(sp)
 828:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82a:	02051493          	slli	s1,a0,0x20
 82e:	9081                	srli	s1,s1,0x20
 830:	04bd                	addi	s1,s1,15
 832:	8091                	srli	s1,s1,0x4
 834:	0014899b          	addiw	s3,s1,1
 838:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 83a:	00000517          	auipc	a0,0x0
 83e:	0e653503          	ld	a0,230(a0) # 920 <freep>
 842:	c515                	beqz	a0,86e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 844:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 846:	4798                	lw	a4,8(a5)
 848:	02977f63          	bgeu	a4,s1,886 <malloc+0x70>
 84c:	8a4e                	mv	s4,s3
 84e:	0009871b          	sext.w	a4,s3
 852:	6685                	lui	a3,0x1
 854:	00d77363          	bgeu	a4,a3,85a <malloc+0x44>
 858:	6a05                	lui	s4,0x1
 85a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 85e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 862:	00000917          	auipc	s2,0x0
 866:	0be90913          	addi	s2,s2,190 # 920 <freep>
  if(p == (char*)-1)
 86a:	5afd                	li	s5,-1
 86c:	a88d                	j	8de <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 86e:	00000797          	auipc	a5,0x0
 872:	0ba78793          	addi	a5,a5,186 # 928 <base>
 876:	00000717          	auipc	a4,0x0
 87a:	0af73523          	sd	a5,170(a4) # 920 <freep>
 87e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 880:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 884:	b7e1                	j	84c <malloc+0x36>
      if(p->s.size == nunits)
 886:	02e48b63          	beq	s1,a4,8bc <malloc+0xa6>
        p->s.size -= nunits;
 88a:	4137073b          	subw	a4,a4,s3
 88e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 890:	1702                	slli	a4,a4,0x20
 892:	9301                	srli	a4,a4,0x20
 894:	0712                	slli	a4,a4,0x4
 896:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 898:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 89c:	00000717          	auipc	a4,0x0
 8a0:	08a73223          	sd	a0,132(a4) # 920 <freep>
      return (void*)(p + 1);
 8a4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a8:	70e2                	ld	ra,56(sp)
 8aa:	7442                	ld	s0,48(sp)
 8ac:	74a2                	ld	s1,40(sp)
 8ae:	7902                	ld	s2,32(sp)
 8b0:	69e2                	ld	s3,24(sp)
 8b2:	6a42                	ld	s4,16(sp)
 8b4:	6aa2                	ld	s5,8(sp)
 8b6:	6b02                	ld	s6,0(sp)
 8b8:	6121                	addi	sp,sp,64
 8ba:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8bc:	6398                	ld	a4,0(a5)
 8be:	e118                	sd	a4,0(a0)
 8c0:	bff1                	j	89c <malloc+0x86>
  hp->s.size = nu;
 8c2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c6:	0541                	addi	a0,a0,16
 8c8:	00000097          	auipc	ra,0x0
 8cc:	ec6080e7          	jalr	-314(ra) # 78e <free>
  return freep;
 8d0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d4:	d971                	beqz	a0,8a8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d8:	4798                	lw	a4,8(a5)
 8da:	fa9776e3          	bgeu	a4,s1,886 <malloc+0x70>
    if(p == freep)
 8de:	00093703          	ld	a4,0(s2)
 8e2:	853e                	mv	a0,a5
 8e4:	fef719e3          	bne	a4,a5,8d6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8e8:	8552                	mv	a0,s4
 8ea:	00000097          	auipc	ra,0x0
 8ee:	b7e080e7          	jalr	-1154(ra) # 468 <sbrk>
  if(p == (char*)-1)
 8f2:	fd5518e3          	bne	a0,s5,8c2 <malloc+0xac>
        return 0;
 8f6:	4501                	li	a0,0
 8f8:	bf45                	j	8a8 <malloc+0x92>
