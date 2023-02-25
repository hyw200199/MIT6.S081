
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	83010113          	addi	sp,sp,-2000 # 80009830 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	b2478793          	addi	a5,a5,-1244 # 80005b80 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e1078793          	addi	a5,a5,-496 # 80000eb6 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000e0:	57fd                	li	a5,-1
    800000e2:	83a9                	srli	a5,a5,0xa
    800000e4:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e8:	47fd                	li	a5,31
    800000ea:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("mret");
    800000ee:	30200073          	mret
}
    800000f2:	60a2                	ld	ra,8(sp)
    800000f4:	6402                	ld	s0,0(sp)
    800000f6:	0141                	addi	sp,sp,16
    800000f8:	8082                	ret

00000000800000fa <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000fa:	715d                	addi	sp,sp,-80
    800000fc:	e486                	sd	ra,72(sp)
    800000fe:	e0a2                	sd	s0,64(sp)
    80000100:	fc26                	sd	s1,56(sp)
    80000102:	f84a                	sd	s2,48(sp)
    80000104:	f44e                	sd	s3,40(sp)
    80000106:	f052                	sd	s4,32(sp)
    80000108:	ec56                	sd	s5,24(sp)
    8000010a:	0880                	addi	s0,sp,80
    8000010c:	8a2a                	mv	s4,a0
    8000010e:	84ae                	mv	s1,a1
    80000110:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000112:	00011517          	auipc	a0,0x11
    80000116:	71e50513          	addi	a0,a0,1822 # 80011830 <cons>
    8000011a:	00001097          	auipc	ra,0x1
    8000011e:	af2080e7          	jalr	-1294(ra) # 80000c0c <acquire>
  for(i = 0; i < n; i++){
    80000122:	05305b63          	blez	s3,80000178 <consolewrite+0x7e>
    80000126:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000128:	5afd                	li	s5,-1
    8000012a:	4685                	li	a3,1
    8000012c:	8626                	mv	a2,s1
    8000012e:	85d2                	mv	a1,s4
    80000130:	fbf40513          	addi	a0,s0,-65
    80000134:	00002097          	auipc	ra,0x2
    80000138:	364080e7          	jalr	868(ra) # 80002498 <either_copyin>
    8000013c:	01550c63          	beq	a0,s5,80000154 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000140:	fbf44503          	lbu	a0,-65(s0)
    80000144:	00000097          	auipc	ra,0x0
    80000148:	796080e7          	jalr	1942(ra) # 800008da <uartputc>
  for(i = 0; i < n; i++){
    8000014c:	2905                	addiw	s2,s2,1
    8000014e:	0485                	addi	s1,s1,1
    80000150:	fd299de3          	bne	s3,s2,8000012a <consolewrite+0x30>
  }
  release(&cons.lock);
    80000154:	00011517          	auipc	a0,0x11
    80000158:	6dc50513          	addi	a0,a0,1756 # 80011830 <cons>
    8000015c:	00001097          	auipc	ra,0x1
    80000160:	b64080e7          	jalr	-1180(ra) # 80000cc0 <release>

  return i;
}
    80000164:	854a                	mv	a0,s2
    80000166:	60a6                	ld	ra,72(sp)
    80000168:	6406                	ld	s0,64(sp)
    8000016a:	74e2                	ld	s1,56(sp)
    8000016c:	7942                	ld	s2,48(sp)
    8000016e:	79a2                	ld	s3,40(sp)
    80000170:	7a02                	ld	s4,32(sp)
    80000172:	6ae2                	ld	s5,24(sp)
    80000174:	6161                	addi	sp,sp,80
    80000176:	8082                	ret
  for(i = 0; i < n; i++){
    80000178:	4901                	li	s2,0
    8000017a:	bfe9                	j	80000154 <consolewrite+0x5a>

000000008000017c <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000017c:	7159                	addi	sp,sp,-112
    8000017e:	f486                	sd	ra,104(sp)
    80000180:	f0a2                	sd	s0,96(sp)
    80000182:	eca6                	sd	s1,88(sp)
    80000184:	e8ca                	sd	s2,80(sp)
    80000186:	e4ce                	sd	s3,72(sp)
    80000188:	e0d2                	sd	s4,64(sp)
    8000018a:	fc56                	sd	s5,56(sp)
    8000018c:	f85a                	sd	s6,48(sp)
    8000018e:	f45e                	sd	s7,40(sp)
    80000190:	f062                	sd	s8,32(sp)
    80000192:	ec66                	sd	s9,24(sp)
    80000194:	e86a                	sd	s10,16(sp)
    80000196:	1880                	addi	s0,sp,112
    80000198:	8aaa                	mv	s5,a0
    8000019a:	8a2e                	mv	s4,a1
    8000019c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000019e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    800001a2:	00011517          	auipc	a0,0x11
    800001a6:	68e50513          	addi	a0,a0,1678 # 80011830 <cons>
    800001aa:	00001097          	auipc	ra,0x1
    800001ae:	a62080e7          	jalr	-1438(ra) # 80000c0c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001b2:	00011497          	auipc	s1,0x11
    800001b6:	67e48493          	addi	s1,s1,1662 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ba:	00011917          	auipc	s2,0x11
    800001be:	70e90913          	addi	s2,s2,1806 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001c2:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c4:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001c6:	4ca9                	li	s9,10
  while(n > 0){
    800001c8:	07305863          	blez	s3,80000238 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001cc:	0984a783          	lw	a5,152(s1)
    800001d0:	09c4a703          	lw	a4,156(s1)
    800001d4:	02f71463          	bne	a4,a5,800001fc <consoleread+0x80>
      if(myproc()->killed){
    800001d8:	00002097          	auipc	ra,0x2
    800001dc:	800080e7          	jalr	-2048(ra) # 800019d8 <myproc>
    800001e0:	591c                	lw	a5,48(a0)
    800001e2:	e7b5                	bnez	a5,8000024e <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001e4:	85a6                	mv	a1,s1
    800001e6:	854a                	mv	a0,s2
    800001e8:	00002097          	auipc	ra,0x2
    800001ec:	000080e7          	jalr	ra # 800021e8 <sleep>
    while(cons.r == cons.w){
    800001f0:	0984a783          	lw	a5,152(s1)
    800001f4:	09c4a703          	lw	a4,156(s1)
    800001f8:	fef700e3          	beq	a4,a5,800001d8 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001fc:	0017871b          	addiw	a4,a5,1
    80000200:	08e4ac23          	sw	a4,152(s1)
    80000204:	07f7f713          	andi	a4,a5,127
    80000208:	9726                	add	a4,a4,s1
    8000020a:	01874703          	lbu	a4,24(a4)
    8000020e:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000212:	077d0563          	beq	s10,s7,8000027c <consoleread+0x100>
    cbuf = c;
    80000216:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000021a:	4685                	li	a3,1
    8000021c:	f9f40613          	addi	a2,s0,-97
    80000220:	85d2                	mv	a1,s4
    80000222:	8556                	mv	a0,s5
    80000224:	00002097          	auipc	ra,0x2
    80000228:	21e080e7          	jalr	542(ra) # 80002442 <either_copyout>
    8000022c:	01850663          	beq	a0,s8,80000238 <consoleread+0xbc>
    dst++;
    80000230:	0a05                	addi	s4,s4,1
    --n;
    80000232:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000234:	f99d1ae3          	bne	s10,s9,800001c8 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000238:	00011517          	auipc	a0,0x11
    8000023c:	5f850513          	addi	a0,a0,1528 # 80011830 <cons>
    80000240:	00001097          	auipc	ra,0x1
    80000244:	a80080e7          	jalr	-1408(ra) # 80000cc0 <release>

  return target - n;
    80000248:	413b053b          	subw	a0,s6,s3
    8000024c:	a811                	j	80000260 <consoleread+0xe4>
        release(&cons.lock);
    8000024e:	00011517          	auipc	a0,0x11
    80000252:	5e250513          	addi	a0,a0,1506 # 80011830 <cons>
    80000256:	00001097          	auipc	ra,0x1
    8000025a:	a6a080e7          	jalr	-1430(ra) # 80000cc0 <release>
        return -1;
    8000025e:	557d                	li	a0,-1
}
    80000260:	70a6                	ld	ra,104(sp)
    80000262:	7406                	ld	s0,96(sp)
    80000264:	64e6                	ld	s1,88(sp)
    80000266:	6946                	ld	s2,80(sp)
    80000268:	69a6                	ld	s3,72(sp)
    8000026a:	6a06                	ld	s4,64(sp)
    8000026c:	7ae2                	ld	s5,56(sp)
    8000026e:	7b42                	ld	s6,48(sp)
    80000270:	7ba2                	ld	s7,40(sp)
    80000272:	7c02                	ld	s8,32(sp)
    80000274:	6ce2                	ld	s9,24(sp)
    80000276:	6d42                	ld	s10,16(sp)
    80000278:	6165                	addi	sp,sp,112
    8000027a:	8082                	ret
      if(n < target){
    8000027c:	0009871b          	sext.w	a4,s3
    80000280:	fb677ce3          	bgeu	a4,s6,80000238 <consoleread+0xbc>
        cons.r--;
    80000284:	00011717          	auipc	a4,0x11
    80000288:	64f72223          	sw	a5,1604(a4) # 800118c8 <cons+0x98>
    8000028c:	b775                	j	80000238 <consoleread+0xbc>

000000008000028e <consputc>:
{
    8000028e:	1141                	addi	sp,sp,-16
    80000290:	e406                	sd	ra,8(sp)
    80000292:	e022                	sd	s0,0(sp)
    80000294:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000296:	10000793          	li	a5,256
    8000029a:	00f50a63          	beq	a0,a5,800002ae <consputc+0x20>
    uartputc_sync(c);
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	55e080e7          	jalr	1374(ra) # 800007fc <uartputc_sync>
}
    800002a6:	60a2                	ld	ra,8(sp)
    800002a8:	6402                	ld	s0,0(sp)
    800002aa:	0141                	addi	sp,sp,16
    800002ac:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	54c080e7          	jalr	1356(ra) # 800007fc <uartputc_sync>
    800002b8:	02000513          	li	a0,32
    800002bc:	00000097          	auipc	ra,0x0
    800002c0:	540080e7          	jalr	1344(ra) # 800007fc <uartputc_sync>
    800002c4:	4521                	li	a0,8
    800002c6:	00000097          	auipc	ra,0x0
    800002ca:	536080e7          	jalr	1334(ra) # 800007fc <uartputc_sync>
    800002ce:	bfe1                	j	800002a6 <consputc+0x18>

00000000800002d0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d0:	1101                	addi	sp,sp,-32
    800002d2:	ec06                	sd	ra,24(sp)
    800002d4:	e822                	sd	s0,16(sp)
    800002d6:	e426                	sd	s1,8(sp)
    800002d8:	e04a                	sd	s2,0(sp)
    800002da:	1000                	addi	s0,sp,32
    800002dc:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002de:	00011517          	auipc	a0,0x11
    800002e2:	55250513          	addi	a0,a0,1362 # 80011830 <cons>
    800002e6:	00001097          	auipc	ra,0x1
    800002ea:	926080e7          	jalr	-1754(ra) # 80000c0c <acquire>

  switch(c){
    800002ee:	47d5                	li	a5,21
    800002f0:	0af48663          	beq	s1,a5,8000039c <consoleintr+0xcc>
    800002f4:	0297ca63          	blt	a5,s1,80000328 <consoleintr+0x58>
    800002f8:	47a1                	li	a5,8
    800002fa:	0ef48763          	beq	s1,a5,800003e8 <consoleintr+0x118>
    800002fe:	47c1                	li	a5,16
    80000300:	10f49a63          	bne	s1,a5,80000414 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80000304:	00002097          	auipc	ra,0x2
    80000308:	1ea080e7          	jalr	490(ra) # 800024ee <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030c:	00011517          	auipc	a0,0x11
    80000310:	52450513          	addi	a0,a0,1316 # 80011830 <cons>
    80000314:	00001097          	auipc	ra,0x1
    80000318:	9ac080e7          	jalr	-1620(ra) # 80000cc0 <release>
}
    8000031c:	60e2                	ld	ra,24(sp)
    8000031e:	6442                	ld	s0,16(sp)
    80000320:	64a2                	ld	s1,8(sp)
    80000322:	6902                	ld	s2,0(sp)
    80000324:	6105                	addi	sp,sp,32
    80000326:	8082                	ret
  switch(c){
    80000328:	07f00793          	li	a5,127
    8000032c:	0af48e63          	beq	s1,a5,800003e8 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000330:	00011717          	auipc	a4,0x11
    80000334:	50070713          	addi	a4,a4,1280 # 80011830 <cons>
    80000338:	0a072783          	lw	a5,160(a4)
    8000033c:	09872703          	lw	a4,152(a4)
    80000340:	9f99                	subw	a5,a5,a4
    80000342:	07f00713          	li	a4,127
    80000346:	fcf763e3          	bltu	a4,a5,8000030c <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000034a:	47b5                	li	a5,13
    8000034c:	0cf48763          	beq	s1,a5,8000041a <consoleintr+0x14a>
      consputc(c);
    80000350:	8526                	mv	a0,s1
    80000352:	00000097          	auipc	ra,0x0
    80000356:	f3c080e7          	jalr	-196(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000035a:	00011797          	auipc	a5,0x11
    8000035e:	4d678793          	addi	a5,a5,1238 # 80011830 <cons>
    80000362:	0a07a703          	lw	a4,160(a5)
    80000366:	0017069b          	addiw	a3,a4,1
    8000036a:	0006861b          	sext.w	a2,a3
    8000036e:	0ad7a023          	sw	a3,160(a5)
    80000372:	07f77713          	andi	a4,a4,127
    80000376:	97ba                	add	a5,a5,a4
    80000378:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000037c:	47a9                	li	a5,10
    8000037e:	0cf48563          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000382:	4791                	li	a5,4
    80000384:	0cf48263          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000388:	00011797          	auipc	a5,0x11
    8000038c:	5407a783          	lw	a5,1344(a5) # 800118c8 <cons+0x98>
    80000390:	0807879b          	addiw	a5,a5,128
    80000394:	f6f61ce3          	bne	a2,a5,8000030c <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000398:	863e                	mv	a2,a5
    8000039a:	a07d                	j	80000448 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000039c:	00011717          	auipc	a4,0x11
    800003a0:	49470713          	addi	a4,a4,1172 # 80011830 <cons>
    800003a4:	0a072783          	lw	a5,160(a4)
    800003a8:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ac:	00011497          	auipc	s1,0x11
    800003b0:	48448493          	addi	s1,s1,1156 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003b4:	4929                	li	s2,10
    800003b6:	f4f70be3          	beq	a4,a5,8000030c <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ba:	37fd                	addiw	a5,a5,-1
    800003bc:	07f7f713          	andi	a4,a5,127
    800003c0:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c2:	01874703          	lbu	a4,24(a4)
    800003c6:	f52703e3          	beq	a4,s2,8000030c <consoleintr+0x3c>
      cons.e--;
    800003ca:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003ce:	10000513          	li	a0,256
    800003d2:	00000097          	auipc	ra,0x0
    800003d6:	ebc080e7          	jalr	-324(ra) # 8000028e <consputc>
    while(cons.e != cons.w &&
    800003da:	0a04a783          	lw	a5,160(s1)
    800003de:	09c4a703          	lw	a4,156(s1)
    800003e2:	fcf71ce3          	bne	a4,a5,800003ba <consoleintr+0xea>
    800003e6:	b71d                	j	8000030c <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	44870713          	addi	a4,a4,1096 # 80011830 <cons>
    800003f0:	0a072783          	lw	a5,160(a4)
    800003f4:	09c72703          	lw	a4,156(a4)
    800003f8:	f0f70ae3          	beq	a4,a5,8000030c <consoleintr+0x3c>
      cons.e--;
    800003fc:	37fd                	addiw	a5,a5,-1
    800003fe:	00011717          	auipc	a4,0x11
    80000402:	4cf72923          	sw	a5,1234(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    80000406:	10000513          	li	a0,256
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e84080e7          	jalr	-380(ra) # 8000028e <consputc>
    80000412:	bded                	j	8000030c <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000414:	ee048ce3          	beqz	s1,8000030c <consoleintr+0x3c>
    80000418:	bf21                	j	80000330 <consoleintr+0x60>
      consputc(c);
    8000041a:	4529                	li	a0,10
    8000041c:	00000097          	auipc	ra,0x0
    80000420:	e72080e7          	jalr	-398(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000424:	00011797          	auipc	a5,0x11
    80000428:	40c78793          	addi	a5,a5,1036 # 80011830 <cons>
    8000042c:	0a07a703          	lw	a4,160(a5)
    80000430:	0017069b          	addiw	a3,a4,1
    80000434:	0006861b          	sext.w	a2,a3
    80000438:	0ad7a023          	sw	a3,160(a5)
    8000043c:	07f77713          	andi	a4,a4,127
    80000440:	97ba                	add	a5,a5,a4
    80000442:	4729                	li	a4,10
    80000444:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000448:	00011797          	auipc	a5,0x11
    8000044c:	48c7a223          	sw	a2,1156(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000450:	00011517          	auipc	a0,0x11
    80000454:	47850513          	addi	a0,a0,1144 # 800118c8 <cons+0x98>
    80000458:	00002097          	auipc	ra,0x2
    8000045c:	f10080e7          	jalr	-240(ra) # 80002368 <wakeup>
    80000460:	b575                	j	8000030c <consoleintr+0x3c>

0000000080000462 <consoleinit>:

void
consoleinit(void)
{
    80000462:	1141                	addi	sp,sp,-16
    80000464:	e406                	sd	ra,8(sp)
    80000466:	e022                	sd	s0,0(sp)
    80000468:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000046a:	00008597          	auipc	a1,0x8
    8000046e:	ba658593          	addi	a1,a1,-1114 # 80008010 <etext+0x10>
    80000472:	00011517          	auipc	a0,0x11
    80000476:	3be50513          	addi	a0,a0,958 # 80011830 <cons>
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	702080e7          	jalr	1794(ra) # 80000b7c <initlock>

  uartinit();
    80000482:	00000097          	auipc	ra,0x0
    80000486:	32a080e7          	jalr	810(ra) # 800007ac <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000048a:	00021797          	auipc	a5,0x21
    8000048e:	52678793          	addi	a5,a5,1318 # 800219b0 <devsw>
    80000492:	00000717          	auipc	a4,0x0
    80000496:	cea70713          	addi	a4,a4,-790 # 8000017c <consoleread>
    8000049a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000049c:	00000717          	auipc	a4,0x0
    800004a0:	c5e70713          	addi	a4,a4,-930 # 800000fa <consolewrite>
    800004a4:	ef98                	sd	a4,24(a5)
}
    800004a6:	60a2                	ld	ra,8(sp)
    800004a8:	6402                	ld	s0,0(sp)
    800004aa:	0141                	addi	sp,sp,16
    800004ac:	8082                	ret

00000000800004ae <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ae:	7179                	addi	sp,sp,-48
    800004b0:	f406                	sd	ra,40(sp)
    800004b2:	f022                	sd	s0,32(sp)
    800004b4:	ec26                	sd	s1,24(sp)
    800004b6:	e84a                	sd	s2,16(sp)
    800004b8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ba:	c219                	beqz	a2,800004c0 <printint+0x12>
    800004bc:	08054663          	bltz	a0,80000548 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004c0:	2501                	sext.w	a0,a0
    800004c2:	4881                	li	a7,0
    800004c4:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004ca:	2581                	sext.w	a1,a1
    800004cc:	00008617          	auipc	a2,0x8
    800004d0:	b7460613          	addi	a2,a2,-1164 # 80008040 <digits>
    800004d4:	883a                	mv	a6,a4
    800004d6:	2705                	addiw	a4,a4,1
    800004d8:	02b577bb          	remuw	a5,a0,a1
    800004dc:	1782                	slli	a5,a5,0x20
    800004de:	9381                	srli	a5,a5,0x20
    800004e0:	97b2                	add	a5,a5,a2
    800004e2:	0007c783          	lbu	a5,0(a5)
    800004e6:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004ea:	0005079b          	sext.w	a5,a0
    800004ee:	02b5553b          	divuw	a0,a0,a1
    800004f2:	0685                	addi	a3,a3,1
    800004f4:	feb7f0e3          	bgeu	a5,a1,800004d4 <printint+0x26>

  if(sign)
    800004f8:	00088b63          	beqz	a7,8000050e <printint+0x60>
    buf[i++] = '-';
    800004fc:	fe040793          	addi	a5,s0,-32
    80000500:	973e                	add	a4,a4,a5
    80000502:	02d00793          	li	a5,45
    80000506:	fef70823          	sb	a5,-16(a4)
    8000050a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000050e:	02e05763          	blez	a4,8000053c <printint+0x8e>
    80000512:	fd040793          	addi	a5,s0,-48
    80000516:	00e784b3          	add	s1,a5,a4
    8000051a:	fff78913          	addi	s2,a5,-1
    8000051e:	993a                	add	s2,s2,a4
    80000520:	377d                	addiw	a4,a4,-1
    80000522:	1702                	slli	a4,a4,0x20
    80000524:	9301                	srli	a4,a4,0x20
    80000526:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000052a:	fff4c503          	lbu	a0,-1(s1)
    8000052e:	00000097          	auipc	ra,0x0
    80000532:	d60080e7          	jalr	-672(ra) # 8000028e <consputc>
  while(--i >= 0)
    80000536:	14fd                	addi	s1,s1,-1
    80000538:	ff2499e3          	bne	s1,s2,8000052a <printint+0x7c>
}
    8000053c:	70a2                	ld	ra,40(sp)
    8000053e:	7402                	ld	s0,32(sp)
    80000540:	64e2                	ld	s1,24(sp)
    80000542:	6942                	ld	s2,16(sp)
    80000544:	6145                	addi	sp,sp,48
    80000546:	8082                	ret
    x = -xx;
    80000548:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000054c:	4885                	li	a7,1
    x = -xx;
    8000054e:	bf9d                	j	800004c4 <printint+0x16>

0000000080000550 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000550:	1101                	addi	sp,sp,-32
    80000552:	ec06                	sd	ra,24(sp)
    80000554:	e822                	sd	s0,16(sp)
    80000556:	e426                	sd	s1,8(sp)
    80000558:	1000                	addi	s0,sp,32
    8000055a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000055c:	00011797          	auipc	a5,0x11
    80000560:	3807aa23          	sw	zero,916(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    80000564:	00008517          	auipc	a0,0x8
    80000568:	ab450513          	addi	a0,a0,-1356 # 80008018 <etext+0x18>
    8000056c:	00000097          	auipc	ra,0x0
    80000570:	02e080e7          	jalr	46(ra) # 8000059a <printf>
  printf(s);
    80000574:	8526                	mv	a0,s1
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	024080e7          	jalr	36(ra) # 8000059a <printf>
  printf("\n");
    8000057e:	00008517          	auipc	a0,0x8
    80000582:	b4a50513          	addi	a0,a0,-1206 # 800080c8 <digits+0x88>
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	014080e7          	jalr	20(ra) # 8000059a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000058e:	4785                	li	a5,1
    80000590:	00009717          	auipc	a4,0x9
    80000594:	a6f72823          	sw	a5,-1424(a4) # 80009000 <panicked>
  for(;;)
    80000598:	a001                	j	80000598 <panic+0x48>

000000008000059a <printf>:
{
    8000059a:	7131                	addi	sp,sp,-192
    8000059c:	fc86                	sd	ra,120(sp)
    8000059e:	f8a2                	sd	s0,112(sp)
    800005a0:	f4a6                	sd	s1,104(sp)
    800005a2:	f0ca                	sd	s2,96(sp)
    800005a4:	ecce                	sd	s3,88(sp)
    800005a6:	e8d2                	sd	s4,80(sp)
    800005a8:	e4d6                	sd	s5,72(sp)
    800005aa:	e0da                	sd	s6,64(sp)
    800005ac:	fc5e                	sd	s7,56(sp)
    800005ae:	f862                	sd	s8,48(sp)
    800005b0:	f466                	sd	s9,40(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	ec6e                	sd	s11,24(sp)
    800005b6:	0100                	addi	s0,sp,128
    800005b8:	8a2a                	mv	s4,a0
    800005ba:	e40c                	sd	a1,8(s0)
    800005bc:	e810                	sd	a2,16(s0)
    800005be:	ec14                	sd	a3,24(s0)
    800005c0:	f018                	sd	a4,32(s0)
    800005c2:	f41c                	sd	a5,40(s0)
    800005c4:	03043823          	sd	a6,48(s0)
    800005c8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005cc:	00011d97          	auipc	s11,0x11
    800005d0:	324dad83          	lw	s11,804(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005d4:	020d9b63          	bnez	s11,8000060a <printf+0x70>
  if (fmt == 0)
    800005d8:	040a0263          	beqz	s4,8000061c <printf+0x82>
  va_start(ap, fmt);
    800005dc:	00840793          	addi	a5,s0,8
    800005e0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e4:	000a4503          	lbu	a0,0(s4)
    800005e8:	14050f63          	beqz	a0,80000746 <printf+0x1ac>
    800005ec:	4981                	li	s3,0
    if(c != '%'){
    800005ee:	02500a93          	li	s5,37
    switch(c){
    800005f2:	07000b93          	li	s7,112
  consputc('x');
    800005f6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f8:	00008b17          	auipc	s6,0x8
    800005fc:	a48b0b13          	addi	s6,s6,-1464 # 80008040 <digits>
    switch(c){
    80000600:	07300c93          	li	s9,115
    80000604:	06400c13          	li	s8,100
    80000608:	a82d                	j	80000642 <printf+0xa8>
    acquire(&pr.lock);
    8000060a:	00011517          	auipc	a0,0x11
    8000060e:	2ce50513          	addi	a0,a0,718 # 800118d8 <pr>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	5fa080e7          	jalr	1530(ra) # 80000c0c <acquire>
    8000061a:	bf7d                	j	800005d8 <printf+0x3e>
    panic("null fmt");
    8000061c:	00008517          	auipc	a0,0x8
    80000620:	a0c50513          	addi	a0,a0,-1524 # 80008028 <etext+0x28>
    80000624:	00000097          	auipc	ra,0x0
    80000628:	f2c080e7          	jalr	-212(ra) # 80000550 <panic>
      consputc(c);
    8000062c:	00000097          	auipc	ra,0x0
    80000630:	c62080e7          	jalr	-926(ra) # 8000028e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c503          	lbu	a0,0(a5)
    8000063e:	10050463          	beqz	a0,80000746 <printf+0x1ac>
    if(c != '%'){
    80000642:	ff5515e3          	bne	a0,s5,8000062c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000646:	2985                	addiw	s3,s3,1
    80000648:	013a07b3          	add	a5,s4,s3
    8000064c:	0007c783          	lbu	a5,0(a5)
    80000650:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000654:	cbed                	beqz	a5,80000746 <printf+0x1ac>
    switch(c){
    80000656:	05778a63          	beq	a5,s7,800006aa <printf+0x110>
    8000065a:	02fbf663          	bgeu	s7,a5,80000686 <printf+0xec>
    8000065e:	09978863          	beq	a5,s9,800006ee <printf+0x154>
    80000662:	07800713          	li	a4,120
    80000666:	0ce79563          	bne	a5,a4,80000730 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000066a:	f8843783          	ld	a5,-120(s0)
    8000066e:	00878713          	addi	a4,a5,8
    80000672:	f8e43423          	sd	a4,-120(s0)
    80000676:	4605                	li	a2,1
    80000678:	85ea                	mv	a1,s10
    8000067a:	4388                	lw	a0,0(a5)
    8000067c:	00000097          	auipc	ra,0x0
    80000680:	e32080e7          	jalr	-462(ra) # 800004ae <printint>
      break;
    80000684:	bf45                	j	80000634 <printf+0x9a>
    switch(c){
    80000686:	09578f63          	beq	a5,s5,80000724 <printf+0x18a>
    8000068a:	0b879363          	bne	a5,s8,80000730 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	45a9                	li	a1,10
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e0e080e7          	jalr	-498(ra) # 800004ae <printint>
      break;
    800006a8:	b771                	j	80000634 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006aa:	f8843783          	ld	a5,-120(s0)
    800006ae:	00878713          	addi	a4,a5,8
    800006b2:	f8e43423          	sd	a4,-120(s0)
    800006b6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006ba:	03000513          	li	a0,48
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bd0080e7          	jalr	-1072(ra) # 8000028e <consputc>
  consputc('x');
    800006c6:	07800513          	li	a0,120
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bc4080e7          	jalr	-1084(ra) # 8000028e <consputc>
    800006d2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d4:	03c95793          	srli	a5,s2,0x3c
    800006d8:	97da                	add	a5,a5,s6
    800006da:	0007c503          	lbu	a0,0(a5)
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	bb0080e7          	jalr	-1104(ra) # 8000028e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e6:	0912                	slli	s2,s2,0x4
    800006e8:	34fd                	addiw	s1,s1,-1
    800006ea:	f4ed                	bnez	s1,800006d4 <printf+0x13a>
    800006ec:	b7a1                	j	80000634 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006ee:	f8843783          	ld	a5,-120(s0)
    800006f2:	00878713          	addi	a4,a5,8
    800006f6:	f8e43423          	sd	a4,-120(s0)
    800006fa:	6384                	ld	s1,0(a5)
    800006fc:	cc89                	beqz	s1,80000716 <printf+0x17c>
      for(; *s; s++)
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	d90d                	beqz	a0,80000634 <printf+0x9a>
        consputc(*s);
    80000704:	00000097          	auipc	ra,0x0
    80000708:	b8a080e7          	jalr	-1142(ra) # 8000028e <consputc>
      for(; *s; s++)
    8000070c:	0485                	addi	s1,s1,1
    8000070e:	0004c503          	lbu	a0,0(s1)
    80000712:	f96d                	bnez	a0,80000704 <printf+0x16a>
    80000714:	b705                	j	80000634 <printf+0x9a>
        s = "(null)";
    80000716:	00008497          	auipc	s1,0x8
    8000071a:	90a48493          	addi	s1,s1,-1782 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000071e:	02800513          	li	a0,40
    80000722:	b7cd                	j	80000704 <printf+0x16a>
      consputc('%');
    80000724:	8556                	mv	a0,s5
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b68080e7          	jalr	-1176(ra) # 8000028e <consputc>
      break;
    8000072e:	b719                	j	80000634 <printf+0x9a>
      consputc('%');
    80000730:	8556                	mv	a0,s5
    80000732:	00000097          	auipc	ra,0x0
    80000736:	b5c080e7          	jalr	-1188(ra) # 8000028e <consputc>
      consputc(c);
    8000073a:	8526                	mv	a0,s1
    8000073c:	00000097          	auipc	ra,0x0
    80000740:	b52080e7          	jalr	-1198(ra) # 8000028e <consputc>
      break;
    80000744:	bdc5                	j	80000634 <printf+0x9a>
  if(locking)
    80000746:	020d9163          	bnez	s11,80000768 <printf+0x1ce>
}
    8000074a:	70e6                	ld	ra,120(sp)
    8000074c:	7446                	ld	s0,112(sp)
    8000074e:	74a6                	ld	s1,104(sp)
    80000750:	7906                	ld	s2,96(sp)
    80000752:	69e6                	ld	s3,88(sp)
    80000754:	6a46                	ld	s4,80(sp)
    80000756:	6aa6                	ld	s5,72(sp)
    80000758:	6b06                	ld	s6,64(sp)
    8000075a:	7be2                	ld	s7,56(sp)
    8000075c:	7c42                	ld	s8,48(sp)
    8000075e:	7ca2                	ld	s9,40(sp)
    80000760:	7d02                	ld	s10,32(sp)
    80000762:	6de2                	ld	s11,24(sp)
    80000764:	6129                	addi	sp,sp,192
    80000766:	8082                	ret
    release(&pr.lock);
    80000768:	00011517          	auipc	a0,0x11
    8000076c:	17050513          	addi	a0,a0,368 # 800118d8 <pr>
    80000770:	00000097          	auipc	ra,0x0
    80000774:	550080e7          	jalr	1360(ra) # 80000cc0 <release>
}
    80000778:	bfc9                	j	8000074a <printf+0x1b0>

000000008000077a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000077a:	1101                	addi	sp,sp,-32
    8000077c:	ec06                	sd	ra,24(sp)
    8000077e:	e822                	sd	s0,16(sp)
    80000780:	e426                	sd	s1,8(sp)
    80000782:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000784:	00011497          	auipc	s1,0x11
    80000788:	15448493          	addi	s1,s1,340 # 800118d8 <pr>
    8000078c:	00008597          	auipc	a1,0x8
    80000790:	8ac58593          	addi	a1,a1,-1876 # 80008038 <etext+0x38>
    80000794:	8526                	mv	a0,s1
    80000796:	00000097          	auipc	ra,0x0
    8000079a:	3e6080e7          	jalr	998(ra) # 80000b7c <initlock>
  pr.locking = 1;
    8000079e:	4785                	li	a5,1
    800007a0:	cc9c                	sw	a5,24(s1)
}
    800007a2:	60e2                	ld	ra,24(sp)
    800007a4:	6442                	ld	s0,16(sp)
    800007a6:	64a2                	ld	s1,8(sp)
    800007a8:	6105                	addi	sp,sp,32
    800007aa:	8082                	ret

00000000800007ac <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007ac:	1141                	addi	sp,sp,-16
    800007ae:	e406                	sd	ra,8(sp)
    800007b0:	e022                	sd	s0,0(sp)
    800007b2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b4:	100007b7          	lui	a5,0x10000
    800007b8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007bc:	f8000713          	li	a4,-128
    800007c0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c4:	470d                	li	a4,3
    800007c6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ca:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ce:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d2:	469d                	li	a3,7
    800007d4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007dc:	00008597          	auipc	a1,0x8
    800007e0:	87c58593          	addi	a1,a1,-1924 # 80008058 <digits+0x18>
    800007e4:	00011517          	auipc	a0,0x11
    800007e8:	11450513          	addi	a0,a0,276 # 800118f8 <uart_tx_lock>
    800007ec:	00000097          	auipc	ra,0x0
    800007f0:	390080e7          	jalr	912(ra) # 80000b7c <initlock>
}
    800007f4:	60a2                	ld	ra,8(sp)
    800007f6:	6402                	ld	s0,0(sp)
    800007f8:	0141                	addi	sp,sp,16
    800007fa:	8082                	ret

00000000800007fc <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fc:	1101                	addi	sp,sp,-32
    800007fe:	ec06                	sd	ra,24(sp)
    80000800:	e822                	sd	s0,16(sp)
    80000802:	e426                	sd	s1,8(sp)
    80000804:	1000                	addi	s0,sp,32
    80000806:	84aa                	mv	s1,a0
  push_off();
    80000808:	00000097          	auipc	ra,0x0
    8000080c:	3b8080e7          	jalr	952(ra) # 80000bc0 <push_off>

  if(panicked){
    80000810:	00008797          	auipc	a5,0x8
    80000814:	7f07a783          	lw	a5,2032(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000818:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081c:	c391                	beqz	a5,80000820 <uartputc_sync+0x24>
    for(;;)
    8000081e:	a001                	j	8000081e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000820:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000824:	0207f793          	andi	a5,a5,32
    80000828:	dfe5                	beqz	a5,80000820 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082a:	0ff4f513          	andi	a0,s1,255
    8000082e:	100007b7          	lui	a5,0x10000
    80000832:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000836:	00000097          	auipc	ra,0x0
    8000083a:	42a080e7          	jalr	1066(ra) # 80000c60 <pop_off>
}
    8000083e:	60e2                	ld	ra,24(sp)
    80000840:	6442                	ld	s0,16(sp)
    80000842:	64a2                	ld	s1,8(sp)
    80000844:	6105                	addi	sp,sp,32
    80000846:	8082                	ret

0000000080000848 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000848:	00008797          	auipc	a5,0x8
    8000084c:	7bc7a783          	lw	a5,1980(a5) # 80009004 <uart_tx_r>
    80000850:	00008717          	auipc	a4,0x8
    80000854:	7b872703          	lw	a4,1976(a4) # 80009008 <uart_tx_w>
    80000858:	08f70063          	beq	a4,a5,800008d8 <uartstart+0x90>
{
    8000085c:	7139                	addi	sp,sp,-64
    8000085e:	fc06                	sd	ra,56(sp)
    80000860:	f822                	sd	s0,48(sp)
    80000862:	f426                	sd	s1,40(sp)
    80000864:	f04a                	sd	s2,32(sp)
    80000866:	ec4e                	sd	s3,24(sp)
    80000868:	e852                	sd	s4,16(sp)
    8000086a:	e456                	sd	s5,8(sp)
    8000086c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000086e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000872:	00011a97          	auipc	s5,0x11
    80000876:	086a8a93          	addi	s5,s5,134 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000087a:	00008497          	auipc	s1,0x8
    8000087e:	78a48493          	addi	s1,s1,1930 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000882:	00008a17          	auipc	s4,0x8
    80000886:	786a0a13          	addi	s4,s4,1926 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000088e:	02077713          	andi	a4,a4,32
    80000892:	cb15                	beqz	a4,800008c6 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    80000894:	00fa8733          	add	a4,s5,a5
    80000898:	01874983          	lbu	s3,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000089c:	2785                	addiw	a5,a5,1
    8000089e:	41f7d71b          	sraiw	a4,a5,0x1f
    800008a2:	01b7571b          	srliw	a4,a4,0x1b
    800008a6:	9fb9                	addw	a5,a5,a4
    800008a8:	8bfd                	andi	a5,a5,31
    800008aa:	9f99                	subw	a5,a5,a4
    800008ac:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008ae:	8526                	mv	a0,s1
    800008b0:	00002097          	auipc	ra,0x2
    800008b4:	ab8080e7          	jalr	-1352(ra) # 80002368 <wakeup>
    
    WriteReg(THR, c);
    800008b8:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008bc:	409c                	lw	a5,0(s1)
    800008be:	000a2703          	lw	a4,0(s4)
    800008c2:	fcf714e3          	bne	a4,a5,8000088a <uartstart+0x42>
  }
}
    800008c6:	70e2                	ld	ra,56(sp)
    800008c8:	7442                	ld	s0,48(sp)
    800008ca:	74a2                	ld	s1,40(sp)
    800008cc:	7902                	ld	s2,32(sp)
    800008ce:	69e2                	ld	s3,24(sp)
    800008d0:	6a42                	ld	s4,16(sp)
    800008d2:	6aa2                	ld	s5,8(sp)
    800008d4:	6121                	addi	sp,sp,64
    800008d6:	8082                	ret
    800008d8:	8082                	ret

00000000800008da <uartputc>:
{
    800008da:	7179                	addi	sp,sp,-48
    800008dc:	f406                	sd	ra,40(sp)
    800008de:	f022                	sd	s0,32(sp)
    800008e0:	ec26                	sd	s1,24(sp)
    800008e2:	e84a                	sd	s2,16(sp)
    800008e4:	e44e                	sd	s3,8(sp)
    800008e6:	e052                	sd	s4,0(sp)
    800008e8:	1800                	addi	s0,sp,48
    800008ea:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    800008ec:	00011517          	auipc	a0,0x11
    800008f0:	00c50513          	addi	a0,a0,12 # 800118f8 <uart_tx_lock>
    800008f4:	00000097          	auipc	ra,0x0
    800008f8:	318080e7          	jalr	792(ra) # 80000c0c <acquire>
  if(panicked){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	7047a783          	lw	a5,1796(a5) # 80009000 <panicked>
    80000904:	c391                	beqz	a5,80000908 <uartputc+0x2e>
    for(;;)
    80000906:	a001                	j	80000906 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000908:	00008697          	auipc	a3,0x8
    8000090c:	7006a683          	lw	a3,1792(a3) # 80009008 <uart_tx_w>
    80000910:	0016879b          	addiw	a5,a3,1
    80000914:	41f7d71b          	sraiw	a4,a5,0x1f
    80000918:	01b7571b          	srliw	a4,a4,0x1b
    8000091c:	9fb9                	addw	a5,a5,a4
    8000091e:	8bfd                	andi	a5,a5,31
    80000920:	9f99                	subw	a5,a5,a4
    80000922:	00008717          	auipc	a4,0x8
    80000926:	6e272703          	lw	a4,1762(a4) # 80009004 <uart_tx_r>
    8000092a:	04f71363          	bne	a4,a5,80000970 <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000092e:	00011a17          	auipc	s4,0x11
    80000932:	fcaa0a13          	addi	s4,s4,-54 # 800118f8 <uart_tx_lock>
    80000936:	00008917          	auipc	s2,0x8
    8000093a:	6ce90913          	addi	s2,s2,1742 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000093e:	00008997          	auipc	s3,0x8
    80000942:	6ca98993          	addi	s3,s3,1738 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000946:	85d2                	mv	a1,s4
    80000948:	854a                	mv	a0,s2
    8000094a:	00002097          	auipc	ra,0x2
    8000094e:	89e080e7          	jalr	-1890(ra) # 800021e8 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000952:	0009a683          	lw	a3,0(s3)
    80000956:	0016879b          	addiw	a5,a3,1
    8000095a:	41f7d71b          	sraiw	a4,a5,0x1f
    8000095e:	01b7571b          	srliw	a4,a4,0x1b
    80000962:	9fb9                	addw	a5,a5,a4
    80000964:	8bfd                	andi	a5,a5,31
    80000966:	9f99                	subw	a5,a5,a4
    80000968:	00092703          	lw	a4,0(s2)
    8000096c:	fcf70de3          	beq	a4,a5,80000946 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000970:	00011917          	auipc	s2,0x11
    80000974:	f8890913          	addi	s2,s2,-120 # 800118f8 <uart_tx_lock>
    80000978:	96ca                	add	a3,a3,s2
    8000097a:	00968c23          	sb	s1,24(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    8000097e:	00008717          	auipc	a4,0x8
    80000982:	68f72523          	sw	a5,1674(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000986:	00000097          	auipc	ra,0x0
    8000098a:	ec2080e7          	jalr	-318(ra) # 80000848 <uartstart>
      release(&uart_tx_lock);
    8000098e:	854a                	mv	a0,s2
    80000990:	00000097          	auipc	ra,0x0
    80000994:	330080e7          	jalr	816(ra) # 80000cc0 <release>
}
    80000998:	70a2                	ld	ra,40(sp)
    8000099a:	7402                	ld	s0,32(sp)
    8000099c:	64e2                	ld	s1,24(sp)
    8000099e:	6942                	ld	s2,16(sp)
    800009a0:	69a2                	ld	s3,8(sp)
    800009a2:	6a02                	ld	s4,0(sp)
    800009a4:	6145                	addi	sp,sp,48
    800009a6:	8082                	ret

00000000800009a8 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009a8:	1141                	addi	sp,sp,-16
    800009aa:	e422                	sd	s0,8(sp)
    800009ac:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ae:	100007b7          	lui	a5,0x10000
    800009b2:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009b6:	8b85                	andi	a5,a5,1
    800009b8:	cb91                	beqz	a5,800009cc <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009c2:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009c6:	6422                	ld	s0,8(sp)
    800009c8:	0141                	addi	sp,sp,16
    800009ca:	8082                	ret
    return -1;
    800009cc:	557d                	li	a0,-1
    800009ce:	bfe5                	j	800009c6 <uartgetc+0x1e>

00000000800009d0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009d0:	1101                	addi	sp,sp,-32
    800009d2:	ec06                	sd	ra,24(sp)
    800009d4:	e822                	sd	s0,16(sp)
    800009d6:	e426                	sd	s1,8(sp)
    800009d8:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009da:	54fd                	li	s1,-1
    800009dc:	a029                	j	800009e6 <uartintr+0x16>
      break;
    consoleintr(c);
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	8f2080e7          	jalr	-1806(ra) # 800002d0 <consoleintr>
    int c = uartgetc();
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	fc2080e7          	jalr	-62(ra) # 800009a8 <uartgetc>
    if(c == -1)
    800009ee:	fe9518e3          	bne	a0,s1,800009de <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009f2:	00011497          	auipc	s1,0x11
    800009f6:	f0648493          	addi	s1,s1,-250 # 800118f8 <uart_tx_lock>
    800009fa:	8526                	mv	a0,s1
    800009fc:	00000097          	auipc	ra,0x0
    80000a00:	210080e7          	jalr	528(ra) # 80000c0c <acquire>
  uartstart();
    80000a04:	00000097          	auipc	ra,0x0
    80000a08:	e44080e7          	jalr	-444(ra) # 80000848 <uartstart>
  release(&uart_tx_lock);
    80000a0c:	8526                	mv	a0,s1
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	2b2080e7          	jalr	690(ra) # 80000cc0 <release>
}
    80000a16:	60e2                	ld	ra,24(sp)
    80000a18:	6442                	ld	s0,16(sp)
    80000a1a:	64a2                	ld	s1,8(sp)
    80000a1c:	6105                	addi	sp,sp,32
    80000a1e:	8082                	ret

0000000080000a20 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a20:	1101                	addi	sp,sp,-32
    80000a22:	ec06                	sd	ra,24(sp)
    80000a24:	e822                	sd	s0,16(sp)
    80000a26:	e426                	sd	s1,8(sp)
    80000a28:	e04a                	sd	s2,0(sp)
    80000a2a:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a2c:	03451793          	slli	a5,a0,0x34
    80000a30:	ebb9                	bnez	a5,80000a86 <kfree+0x66>
    80000a32:	84aa                	mv	s1,a0
    80000a34:	00025797          	auipc	a5,0x25
    80000a38:	5cc78793          	addi	a5,a5,1484 # 80026000 <end>
    80000a3c:	04f56563          	bltu	a0,a5,80000a86 <kfree+0x66>
    80000a40:	47c5                	li	a5,17
    80000a42:	07ee                	slli	a5,a5,0x1b
    80000a44:	04f57163          	bgeu	a0,a5,80000a86 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a48:	6605                	lui	a2,0x1
    80000a4a:	4585                	li	a1,1
    80000a4c:	00000097          	auipc	ra,0x0
    80000a50:	2bc080e7          	jalr	700(ra) # 80000d08 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a54:	00011917          	auipc	s2,0x11
    80000a58:	edc90913          	addi	s2,s2,-292 # 80011930 <kmem>
    80000a5c:	854a                	mv	a0,s2
    80000a5e:	00000097          	auipc	ra,0x0
    80000a62:	1ae080e7          	jalr	430(ra) # 80000c0c <acquire>
  r->next = kmem.freelist;
    80000a66:	01893783          	ld	a5,24(s2)
    80000a6a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a6c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a70:	854a                	mv	a0,s2
    80000a72:	00000097          	auipc	ra,0x0
    80000a76:	24e080e7          	jalr	590(ra) # 80000cc0 <release>
}
    80000a7a:	60e2                	ld	ra,24(sp)
    80000a7c:	6442                	ld	s0,16(sp)
    80000a7e:	64a2                	ld	s1,8(sp)
    80000a80:	6902                	ld	s2,0(sp)
    80000a82:	6105                	addi	sp,sp,32
    80000a84:	8082                	ret
    panic("kfree");
    80000a86:	00007517          	auipc	a0,0x7
    80000a8a:	5da50513          	addi	a0,a0,1498 # 80008060 <digits+0x20>
    80000a8e:	00000097          	auipc	ra,0x0
    80000a92:	ac2080e7          	jalr	-1342(ra) # 80000550 <panic>

0000000080000a96 <freerange>:
{
    80000a96:	7179                	addi	sp,sp,-48
    80000a98:	f406                	sd	ra,40(sp)
    80000a9a:	f022                	sd	s0,32(sp)
    80000a9c:	ec26                	sd	s1,24(sp)
    80000a9e:	e84a                	sd	s2,16(sp)
    80000aa0:	e44e                	sd	s3,8(sp)
    80000aa2:	e052                	sd	s4,0(sp)
    80000aa4:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aa6:	6785                	lui	a5,0x1
    80000aa8:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000aac:	94aa                	add	s1,s1,a0
    80000aae:	757d                	lui	a0,0xfffff
    80000ab0:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab2:	94be                	add	s1,s1,a5
    80000ab4:	0095ee63          	bltu	a1,s1,80000ad0 <freerange+0x3a>
    80000ab8:	892e                	mv	s2,a1
    kfree(p);
    80000aba:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000abc:	6985                	lui	s3,0x1
    kfree(p);
    80000abe:	01448533          	add	a0,s1,s4
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f5e080e7          	jalr	-162(ra) # 80000a20 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aca:	94ce                	add	s1,s1,s3
    80000acc:	fe9979e3          	bgeu	s2,s1,80000abe <freerange+0x28>
}
    80000ad0:	70a2                	ld	ra,40(sp)
    80000ad2:	7402                	ld	s0,32(sp)
    80000ad4:	64e2                	ld	s1,24(sp)
    80000ad6:	6942                	ld	s2,16(sp)
    80000ad8:	69a2                	ld	s3,8(sp)
    80000ada:	6a02                	ld	s4,0(sp)
    80000adc:	6145                	addi	sp,sp,48
    80000ade:	8082                	ret

0000000080000ae0 <kinit>:
{
    80000ae0:	1141                	addi	sp,sp,-16
    80000ae2:	e406                	sd	ra,8(sp)
    80000ae4:	e022                	sd	s0,0(sp)
    80000ae6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ae8:	00007597          	auipc	a1,0x7
    80000aec:	58058593          	addi	a1,a1,1408 # 80008068 <digits+0x28>
    80000af0:	00011517          	auipc	a0,0x11
    80000af4:	e4050513          	addi	a0,a0,-448 # 80011930 <kmem>
    80000af8:	00000097          	auipc	ra,0x0
    80000afc:	084080e7          	jalr	132(ra) # 80000b7c <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b00:	45c5                	li	a1,17
    80000b02:	05ee                	slli	a1,a1,0x1b
    80000b04:	00025517          	auipc	a0,0x25
    80000b08:	4fc50513          	addi	a0,a0,1276 # 80026000 <end>
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	f8a080e7          	jalr	-118(ra) # 80000a96 <freerange>
}
    80000b14:	60a2                	ld	ra,8(sp)
    80000b16:	6402                	ld	s0,0(sp)
    80000b18:	0141                	addi	sp,sp,16
    80000b1a:	8082                	ret

0000000080000b1c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b1c:	1101                	addi	sp,sp,-32
    80000b1e:	ec06                	sd	ra,24(sp)
    80000b20:	e822                	sd	s0,16(sp)
    80000b22:	e426                	sd	s1,8(sp)
    80000b24:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b26:	00011497          	auipc	s1,0x11
    80000b2a:	e0a48493          	addi	s1,s1,-502 # 80011930 <kmem>
    80000b2e:	8526                	mv	a0,s1
    80000b30:	00000097          	auipc	ra,0x0
    80000b34:	0dc080e7          	jalr	220(ra) # 80000c0c <acquire>
  r = kmem.freelist;
    80000b38:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3a:	c885                	beqz	s1,80000b6a <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b3c:	609c                	ld	a5,0(s1)
    80000b3e:	00011517          	auipc	a0,0x11
    80000b42:	df250513          	addi	a0,a0,-526 # 80011930 <kmem>
    80000b46:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	178080e7          	jalr	376(ra) # 80000cc0 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	1b2080e7          	jalr	434(ra) # 80000d08 <memset>
  return (void*)r;
}
    80000b5e:	8526                	mv	a0,s1
    80000b60:	60e2                	ld	ra,24(sp)
    80000b62:	6442                	ld	s0,16(sp)
    80000b64:	64a2                	ld	s1,8(sp)
    80000b66:	6105                	addi	sp,sp,32
    80000b68:	8082                	ret
  release(&kmem.lock);
    80000b6a:	00011517          	auipc	a0,0x11
    80000b6e:	dc650513          	addi	a0,a0,-570 # 80011930 <kmem>
    80000b72:	00000097          	auipc	ra,0x0
    80000b76:	14e080e7          	jalr	334(ra) # 80000cc0 <release>
  if(r)
    80000b7a:	b7d5                	j	80000b5e <kalloc+0x42>

0000000080000b7c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b7c:	1141                	addi	sp,sp,-16
    80000b7e:	e422                	sd	s0,8(sp)
    80000b80:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b82:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b84:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b88:	00053823          	sd	zero,16(a0)
}
    80000b8c:	6422                	ld	s0,8(sp)
    80000b8e:	0141                	addi	sp,sp,16
    80000b90:	8082                	ret

0000000080000b92 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b92:	411c                	lw	a5,0(a0)
    80000b94:	e399                	bnez	a5,80000b9a <holding+0x8>
    80000b96:	4501                	li	a0,0
  return r;
}
    80000b98:	8082                	ret
{
    80000b9a:	1101                	addi	sp,sp,-32
    80000b9c:	ec06                	sd	ra,24(sp)
    80000b9e:	e822                	sd	s0,16(sp)
    80000ba0:	e426                	sd	s1,8(sp)
    80000ba2:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba4:	6904                	ld	s1,16(a0)
    80000ba6:	00001097          	auipc	ra,0x1
    80000baa:	e16080e7          	jalr	-490(ra) # 800019bc <mycpu>
    80000bae:	40a48533          	sub	a0,s1,a0
    80000bb2:	00153513          	seqz	a0,a0
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret

0000000080000bc0 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bca:	100024f3          	csrr	s1,sstatus
    80000bce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd4:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bd8:	00001097          	auipc	ra,0x1
    80000bdc:	de4080e7          	jalr	-540(ra) # 800019bc <mycpu>
    80000be0:	5d3c                	lw	a5,120(a0)
    80000be2:	cf89                	beqz	a5,80000bfc <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000be4:	00001097          	auipc	ra,0x1
    80000be8:	dd8080e7          	jalr	-552(ra) # 800019bc <mycpu>
    80000bec:	5d3c                	lw	a5,120(a0)
    80000bee:	2785                	addiw	a5,a5,1
    80000bf0:	dd3c                	sw	a5,120(a0)
}
    80000bf2:	60e2                	ld	ra,24(sp)
    80000bf4:	6442                	ld	s0,16(sp)
    80000bf6:	64a2                	ld	s1,8(sp)
    80000bf8:	6105                	addi	sp,sp,32
    80000bfa:	8082                	ret
    mycpu()->intena = old;
    80000bfc:	00001097          	auipc	ra,0x1
    80000c00:	dc0080e7          	jalr	-576(ra) # 800019bc <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c04:	8085                	srli	s1,s1,0x1
    80000c06:	8885                	andi	s1,s1,1
    80000c08:	dd64                	sw	s1,124(a0)
    80000c0a:	bfe9                	j	80000be4 <push_off+0x24>

0000000080000c0c <acquire>:
{
    80000c0c:	1101                	addi	sp,sp,-32
    80000c0e:	ec06                	sd	ra,24(sp)
    80000c10:	e822                	sd	s0,16(sp)
    80000c12:	e426                	sd	s1,8(sp)
    80000c14:	1000                	addi	s0,sp,32
    80000c16:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c18:	00000097          	auipc	ra,0x0
    80000c1c:	fa8080e7          	jalr	-88(ra) # 80000bc0 <push_off>
  if(holding(lk))
    80000c20:	8526                	mv	a0,s1
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	f70080e7          	jalr	-144(ra) # 80000b92 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c2a:	4705                	li	a4,1
  if(holding(lk))
    80000c2c:	e115                	bnez	a0,80000c50 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c2e:	87ba                	mv	a5,a4
    80000c30:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c34:	2781                	sext.w	a5,a5
    80000c36:	ffe5                	bnez	a5,80000c2e <acquire+0x22>
  __sync_synchronize();
    80000c38:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c3c:	00001097          	auipc	ra,0x1
    80000c40:	d80080e7          	jalr	-640(ra) # 800019bc <mycpu>
    80000c44:	e888                	sd	a0,16(s1)
}
    80000c46:	60e2                	ld	ra,24(sp)
    80000c48:	6442                	ld	s0,16(sp)
    80000c4a:	64a2                	ld	s1,8(sp)
    80000c4c:	6105                	addi	sp,sp,32
    80000c4e:	8082                	ret
    panic("acquire");
    80000c50:	00007517          	auipc	a0,0x7
    80000c54:	42050513          	addi	a0,a0,1056 # 80008070 <digits+0x30>
    80000c58:	00000097          	auipc	ra,0x0
    80000c5c:	8f8080e7          	jalr	-1800(ra) # 80000550 <panic>

0000000080000c60 <pop_off>:

void
pop_off(void)
{
    80000c60:	1141                	addi	sp,sp,-16
    80000c62:	e406                	sd	ra,8(sp)
    80000c64:	e022                	sd	s0,0(sp)
    80000c66:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	d54080e7          	jalr	-684(ra) # 800019bc <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c70:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c74:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c76:	e78d                	bnez	a5,80000ca0 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c78:	5d3c                	lw	a5,120(a0)
    80000c7a:	02f05b63          	blez	a5,80000cb0 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c7e:	37fd                	addiw	a5,a5,-1
    80000c80:	0007871b          	sext.w	a4,a5
    80000c84:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c86:	eb09                	bnez	a4,80000c98 <pop_off+0x38>
    80000c88:	5d7c                	lw	a5,124(a0)
    80000c8a:	c799                	beqz	a5,80000c98 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c8c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c90:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c94:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c98:	60a2                	ld	ra,8(sp)
    80000c9a:	6402                	ld	s0,0(sp)
    80000c9c:	0141                	addi	sp,sp,16
    80000c9e:	8082                	ret
    panic("pop_off - interruptible");
    80000ca0:	00007517          	auipc	a0,0x7
    80000ca4:	3d850513          	addi	a0,a0,984 # 80008078 <digits+0x38>
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	8a8080e7          	jalr	-1880(ra) # 80000550 <panic>
    panic("pop_off");
    80000cb0:	00007517          	auipc	a0,0x7
    80000cb4:	3e050513          	addi	a0,a0,992 # 80008090 <digits+0x50>
    80000cb8:	00000097          	auipc	ra,0x0
    80000cbc:	898080e7          	jalr	-1896(ra) # 80000550 <panic>

0000000080000cc0 <release>:
{
    80000cc0:	1101                	addi	sp,sp,-32
    80000cc2:	ec06                	sd	ra,24(sp)
    80000cc4:	e822                	sd	s0,16(sp)
    80000cc6:	e426                	sd	s1,8(sp)
    80000cc8:	1000                	addi	s0,sp,32
    80000cca:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ccc:	00000097          	auipc	ra,0x0
    80000cd0:	ec6080e7          	jalr	-314(ra) # 80000b92 <holding>
    80000cd4:	c115                	beqz	a0,80000cf8 <release+0x38>
  lk->cpu = 0;
    80000cd6:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cda:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cde:	0f50000f          	fence	iorw,ow
    80000ce2:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ce6:	00000097          	auipc	ra,0x0
    80000cea:	f7a080e7          	jalr	-134(ra) # 80000c60 <pop_off>
}
    80000cee:	60e2                	ld	ra,24(sp)
    80000cf0:	6442                	ld	s0,16(sp)
    80000cf2:	64a2                	ld	s1,8(sp)
    80000cf4:	6105                	addi	sp,sp,32
    80000cf6:	8082                	ret
    panic("release");
    80000cf8:	00007517          	auipc	a0,0x7
    80000cfc:	3a050513          	addi	a0,a0,928 # 80008098 <digits+0x58>
    80000d00:	00000097          	auipc	ra,0x0
    80000d04:	850080e7          	jalr	-1968(ra) # 80000550 <panic>

0000000080000d08 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d08:	1141                	addi	sp,sp,-16
    80000d0a:	e422                	sd	s0,8(sp)
    80000d0c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d0e:	ca19                	beqz	a2,80000d24 <memset+0x1c>
    80000d10:	87aa                	mv	a5,a0
    80000d12:	1602                	slli	a2,a2,0x20
    80000d14:	9201                	srli	a2,a2,0x20
    80000d16:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d1a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d1e:	0785                	addi	a5,a5,1
    80000d20:	fee79de3          	bne	a5,a4,80000d1a <memset+0x12>
  }
  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret

0000000080000d2a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d30:	ca05                	beqz	a2,80000d60 <memcmp+0x36>
    80000d32:	fff6069b          	addiw	a3,a2,-1
    80000d36:	1682                	slli	a3,a3,0x20
    80000d38:	9281                	srli	a3,a3,0x20
    80000d3a:	0685                	addi	a3,a3,1
    80000d3c:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d3e:	00054783          	lbu	a5,0(a0)
    80000d42:	0005c703          	lbu	a4,0(a1)
    80000d46:	00e79863          	bne	a5,a4,80000d56 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d4a:	0505                	addi	a0,a0,1
    80000d4c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d4e:	fed518e3          	bne	a0,a3,80000d3e <memcmp+0x14>
  }

  return 0;
    80000d52:	4501                	li	a0,0
    80000d54:	a019                	j	80000d5a <memcmp+0x30>
      return *s1 - *s2;
    80000d56:	40e7853b          	subw	a0,a5,a4
}
    80000d5a:	6422                	ld	s0,8(sp)
    80000d5c:	0141                	addi	sp,sp,16
    80000d5e:	8082                	ret
  return 0;
    80000d60:	4501                	li	a0,0
    80000d62:	bfe5                	j	80000d5a <memcmp+0x30>

0000000080000d64 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d64:	1141                	addi	sp,sp,-16
    80000d66:	e422                	sd	s0,8(sp)
    80000d68:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d6a:	02a5e563          	bltu	a1,a0,80000d94 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d6e:	fff6069b          	addiw	a3,a2,-1
    80000d72:	ce11                	beqz	a2,80000d8e <memmove+0x2a>
    80000d74:	1682                	slli	a3,a3,0x20
    80000d76:	9281                	srli	a3,a3,0x20
    80000d78:	0685                	addi	a3,a3,1
    80000d7a:	96ae                	add	a3,a3,a1
    80000d7c:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d7e:	0585                	addi	a1,a1,1
    80000d80:	0785                	addi	a5,a5,1
    80000d82:	fff5c703          	lbu	a4,-1(a1)
    80000d86:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d8a:	fed59ae3          	bne	a1,a3,80000d7e <memmove+0x1a>

  return dst;
}
    80000d8e:	6422                	ld	s0,8(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret
  if(s < d && s + n > d){
    80000d94:	02061713          	slli	a4,a2,0x20
    80000d98:	9301                	srli	a4,a4,0x20
    80000d9a:	00e587b3          	add	a5,a1,a4
    80000d9e:	fcf578e3          	bgeu	a0,a5,80000d6e <memmove+0xa>
    d += n;
    80000da2:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000da4:	fff6069b          	addiw	a3,a2,-1
    80000da8:	d27d                	beqz	a2,80000d8e <memmove+0x2a>
    80000daa:	02069613          	slli	a2,a3,0x20
    80000dae:	9201                	srli	a2,a2,0x20
    80000db0:	fff64613          	not	a2,a2
    80000db4:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000db6:	17fd                	addi	a5,a5,-1
    80000db8:	177d                	addi	a4,a4,-1
    80000dba:	0007c683          	lbu	a3,0(a5)
    80000dbe:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000dc2:	fef61ae3          	bne	a2,a5,80000db6 <memmove+0x52>
    80000dc6:	b7e1                	j	80000d8e <memmove+0x2a>

0000000080000dc8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dc8:	1141                	addi	sp,sp,-16
    80000dca:	e406                	sd	ra,8(sp)
    80000dcc:	e022                	sd	s0,0(sp)
    80000dce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dd0:	00000097          	auipc	ra,0x0
    80000dd4:	f94080e7          	jalr	-108(ra) # 80000d64 <memmove>
}
    80000dd8:	60a2                	ld	ra,8(sp)
    80000dda:	6402                	ld	s0,0(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000de6:	ce11                	beqz	a2,80000e02 <strncmp+0x22>
    80000de8:	00054783          	lbu	a5,0(a0)
    80000dec:	cf89                	beqz	a5,80000e06 <strncmp+0x26>
    80000dee:	0005c703          	lbu	a4,0(a1)
    80000df2:	00f71a63          	bne	a4,a5,80000e06 <strncmp+0x26>
    n--, p++, q++;
    80000df6:	367d                	addiw	a2,a2,-1
    80000df8:	0505                	addi	a0,a0,1
    80000dfa:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dfc:	f675                	bnez	a2,80000de8 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dfe:	4501                	li	a0,0
    80000e00:	a809                	j	80000e12 <strncmp+0x32>
    80000e02:	4501                	li	a0,0
    80000e04:	a039                	j	80000e12 <strncmp+0x32>
  if(n == 0)
    80000e06:	ca09                	beqz	a2,80000e18 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e08:	00054503          	lbu	a0,0(a0)
    80000e0c:	0005c783          	lbu	a5,0(a1)
    80000e10:	9d1d                	subw	a0,a0,a5
}
    80000e12:	6422                	ld	s0,8(sp)
    80000e14:	0141                	addi	sp,sp,16
    80000e16:	8082                	ret
    return 0;
    80000e18:	4501                	li	a0,0
    80000e1a:	bfe5                	j	80000e12 <strncmp+0x32>

0000000080000e1c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e22:	872a                	mv	a4,a0
    80000e24:	8832                	mv	a6,a2
    80000e26:	367d                	addiw	a2,a2,-1
    80000e28:	01005963          	blez	a6,80000e3a <strncpy+0x1e>
    80000e2c:	0705                	addi	a4,a4,1
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	fef70fa3          	sb	a5,-1(a4)
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	f7f5                	bnez	a5,80000e24 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e3a:	86ba                	mv	a3,a4
    80000e3c:	00c05c63          	blez	a2,80000e54 <strncpy+0x38>
    *s++ = 0;
    80000e40:	0685                	addi	a3,a3,1
    80000e42:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e46:	fff6c793          	not	a5,a3
    80000e4a:	9fb9                	addw	a5,a5,a4
    80000e4c:	010787bb          	addw	a5,a5,a6
    80000e50:	fef048e3          	bgtz	a5,80000e40 <strncpy+0x24>
  return os;
}
    80000e54:	6422                	ld	s0,8(sp)
    80000e56:	0141                	addi	sp,sp,16
    80000e58:	8082                	ret

0000000080000e5a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e5a:	1141                	addi	sp,sp,-16
    80000e5c:	e422                	sd	s0,8(sp)
    80000e5e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e60:	02c05363          	blez	a2,80000e86 <safestrcpy+0x2c>
    80000e64:	fff6069b          	addiw	a3,a2,-1
    80000e68:	1682                	slli	a3,a3,0x20
    80000e6a:	9281                	srli	a3,a3,0x20
    80000e6c:	96ae                	add	a3,a3,a1
    80000e6e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e70:	00d58963          	beq	a1,a3,80000e82 <safestrcpy+0x28>
    80000e74:	0585                	addi	a1,a1,1
    80000e76:	0785                	addi	a5,a5,1
    80000e78:	fff5c703          	lbu	a4,-1(a1)
    80000e7c:	fee78fa3          	sb	a4,-1(a5)
    80000e80:	fb65                	bnez	a4,80000e70 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e82:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e86:	6422                	ld	s0,8(sp)
    80000e88:	0141                	addi	sp,sp,16
    80000e8a:	8082                	ret

0000000080000e8c <strlen>:

int
strlen(const char *s)
{
    80000e8c:	1141                	addi	sp,sp,-16
    80000e8e:	e422                	sd	s0,8(sp)
    80000e90:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e92:	00054783          	lbu	a5,0(a0)
    80000e96:	cf91                	beqz	a5,80000eb2 <strlen+0x26>
    80000e98:	0505                	addi	a0,a0,1
    80000e9a:	87aa                	mv	a5,a0
    80000e9c:	4685                	li	a3,1
    80000e9e:	9e89                	subw	a3,a3,a0
    80000ea0:	00f6853b          	addw	a0,a3,a5
    80000ea4:	0785                	addi	a5,a5,1
    80000ea6:	fff7c703          	lbu	a4,-1(a5)
    80000eaa:	fb7d                	bnez	a4,80000ea0 <strlen+0x14>
    ;
  return n;
}
    80000eac:	6422                	ld	s0,8(sp)
    80000eae:	0141                	addi	sp,sp,16
    80000eb0:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eb2:	4501                	li	a0,0
    80000eb4:	bfe5                	j	80000eac <strlen+0x20>

0000000080000eb6 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eb6:	1141                	addi	sp,sp,-16
    80000eb8:	e406                	sd	ra,8(sp)
    80000eba:	e022                	sd	s0,0(sp)
    80000ebc:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	aee080e7          	jalr	-1298(ra) # 800019ac <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ec6:	00008717          	auipc	a4,0x8
    80000eca:	14670713          	addi	a4,a4,326 # 8000900c <started>
  if(cpuid() == 0){
    80000ece:	c139                	beqz	a0,80000f14 <main+0x5e>
    while(started == 0)
    80000ed0:	431c                	lw	a5,0(a4)
    80000ed2:	2781                	sext.w	a5,a5
    80000ed4:	dff5                	beqz	a5,80000ed0 <main+0x1a>
      ;
    __sync_synchronize();
    80000ed6:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	ad2080e7          	jalr	-1326(ra) # 800019ac <cpuid>
    80000ee2:	85aa                	mv	a1,a0
    80000ee4:	00007517          	auipc	a0,0x7
    80000ee8:	1d450513          	addi	a0,a0,468 # 800080b8 <digits+0x78>
    80000eec:	fffff097          	auipc	ra,0xfffff
    80000ef0:	6ae080e7          	jalr	1710(ra) # 8000059a <printf>
    kvminithart();    // turn on paging
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	0d8080e7          	jalr	216(ra) # 80000fcc <kvminithart>
    trapinithart();   // install kernel trap vector
    80000efc:	00001097          	auipc	ra,0x1
    80000f00:	732080e7          	jalr	1842(ra) # 8000262e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f04:	00005097          	auipc	ra,0x5
    80000f08:	cd8080e7          	jalr	-808(ra) # 80005bdc <plicinithart>
  }

  scheduler();        
    80000f0c:	00001097          	auipc	ra,0x1
    80000f10:	000080e7          	jalr	ra # 80001f0c <scheduler>
    consoleinit();
    80000f14:	fffff097          	auipc	ra,0xfffff
    80000f18:	54e080e7          	jalr	1358(ra) # 80000462 <consoleinit>
    printfinit();
    80000f1c:	00000097          	auipc	ra,0x0
    80000f20:	85e080e7          	jalr	-1954(ra) # 8000077a <printfinit>
    printf("\n");
    80000f24:	00007517          	auipc	a0,0x7
    80000f28:	1a450513          	addi	a0,a0,420 # 800080c8 <digits+0x88>
    80000f2c:	fffff097          	auipc	ra,0xfffff
    80000f30:	66e080e7          	jalr	1646(ra) # 8000059a <printf>
    printf("xv6 kernel is booting\n");
    80000f34:	00007517          	auipc	a0,0x7
    80000f38:	16c50513          	addi	a0,a0,364 # 800080a0 <digits+0x60>
    80000f3c:	fffff097          	auipc	ra,0xfffff
    80000f40:	65e080e7          	jalr	1630(ra) # 8000059a <printf>
    printf("\n");
    80000f44:	00007517          	auipc	a0,0x7
    80000f48:	18450513          	addi	a0,a0,388 # 800080c8 <digits+0x88>
    80000f4c:	fffff097          	auipc	ra,0xfffff
    80000f50:	64e080e7          	jalr	1614(ra) # 8000059a <printf>
    kinit();         // physical page allocator
    80000f54:	00000097          	auipc	ra,0x0
    80000f58:	b8c080e7          	jalr	-1140(ra) # 80000ae0 <kinit>
    kvminit();       // create kernel page table
    80000f5c:	00000097          	auipc	ra,0x0
    80000f60:	2a0080e7          	jalr	672(ra) # 800011fc <kvminit>
    kvminithart();   // turn on paging
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	068080e7          	jalr	104(ra) # 80000fcc <kvminithart>
    procinit();      // process table
    80000f6c:	00001097          	auipc	ra,0x1
    80000f70:	970080e7          	jalr	-1680(ra) # 800018dc <procinit>
    trapinit();      // trap vectors
    80000f74:	00001097          	auipc	ra,0x1
    80000f78:	692080e7          	jalr	1682(ra) # 80002606 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f7c:	00001097          	auipc	ra,0x1
    80000f80:	6b2080e7          	jalr	1714(ra) # 8000262e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	c42080e7          	jalr	-958(ra) # 80005bc6 <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f8c:	00005097          	auipc	ra,0x5
    80000f90:	c50080e7          	jalr	-944(ra) # 80005bdc <plicinithart>
    binit();         // buffer cache
    80000f94:	00002097          	auipc	ra,0x2
    80000f98:	dda080e7          	jalr	-550(ra) # 80002d6e <binit>
    iinit();         // inode cache
    80000f9c:	00002097          	auipc	ra,0x2
    80000fa0:	46a080e7          	jalr	1130(ra) # 80003406 <iinit>
    fileinit();      // file table
    80000fa4:	00003097          	auipc	ra,0x3
    80000fa8:	404080e7          	jalr	1028(ra) # 800043a8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fac:	00005097          	auipc	ra,0x5
    80000fb0:	d38080e7          	jalr	-712(ra) # 80005ce4 <virtio_disk_init>
    userinit();      // first user process
    80000fb4:	00001097          	auipc	ra,0x1
    80000fb8:	cee080e7          	jalr	-786(ra) # 80001ca2 <userinit>
    __sync_synchronize();
    80000fbc:	0ff0000f          	fence
    started = 1;
    80000fc0:	4785                	li	a5,1
    80000fc2:	00008717          	auipc	a4,0x8
    80000fc6:	04f72523          	sw	a5,74(a4) # 8000900c <started>
    80000fca:	b789                	j	80000f0c <main+0x56>

0000000080000fcc <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fcc:	1141                	addi	sp,sp,-16
    80000fce:	e422                	sd	s0,8(sp)
    80000fd0:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fd2:	00008797          	auipc	a5,0x8
    80000fd6:	03e7b783          	ld	a5,62(a5) # 80009010 <kernel_pagetable>
    80000fda:	83b1                	srli	a5,a5,0xc
    80000fdc:	577d                	li	a4,-1
    80000fde:	177e                	slli	a4,a4,0x3f
    80000fe0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fe2:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fe6:	12000073          	sfence.vma
  sfence_vma();
}
    80000fea:	6422                	ld	s0,8(sp)
    80000fec:	0141                	addi	sp,sp,16
    80000fee:	8082                	ret

0000000080000ff0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ff0:	7139                	addi	sp,sp,-64
    80000ff2:	fc06                	sd	ra,56(sp)
    80000ff4:	f822                	sd	s0,48(sp)
    80000ff6:	f426                	sd	s1,40(sp)
    80000ff8:	f04a                	sd	s2,32(sp)
    80000ffa:	ec4e                	sd	s3,24(sp)
    80000ffc:	e852                	sd	s4,16(sp)
    80000ffe:	e456                	sd	s5,8(sp)
    80001000:	e05a                	sd	s6,0(sp)
    80001002:	0080                	addi	s0,sp,64
    80001004:	84aa                	mv	s1,a0
    80001006:	89ae                	mv	s3,a1
    80001008:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000100a:	57fd                	li	a5,-1
    8000100c:	83e9                	srli	a5,a5,0x1a
    8000100e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001010:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001012:	04b7f263          	bgeu	a5,a1,80001056 <walk+0x66>
    panic("walk");
    80001016:	00007517          	auipc	a0,0x7
    8000101a:	0ba50513          	addi	a0,a0,186 # 800080d0 <digits+0x90>
    8000101e:	fffff097          	auipc	ra,0xfffff
    80001022:	532080e7          	jalr	1330(ra) # 80000550 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001026:	060a8663          	beqz	s5,80001092 <walk+0xa2>
    8000102a:	00000097          	auipc	ra,0x0
    8000102e:	af2080e7          	jalr	-1294(ra) # 80000b1c <kalloc>
    80001032:	84aa                	mv	s1,a0
    80001034:	c529                	beqz	a0,8000107e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001036:	6605                	lui	a2,0x1
    80001038:	4581                	li	a1,0
    8000103a:	00000097          	auipc	ra,0x0
    8000103e:	cce080e7          	jalr	-818(ra) # 80000d08 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001042:	00c4d793          	srli	a5,s1,0xc
    80001046:	07aa                	slli	a5,a5,0xa
    80001048:	0017e793          	ori	a5,a5,1
    8000104c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001050:	3a5d                	addiw	s4,s4,-9
    80001052:	036a0063          	beq	s4,s6,80001072 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001056:	0149d933          	srl	s2,s3,s4
    8000105a:	1ff97913          	andi	s2,s2,511
    8000105e:	090e                	slli	s2,s2,0x3
    80001060:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001062:	00093483          	ld	s1,0(s2)
    80001066:	0014f793          	andi	a5,s1,1
    8000106a:	dfd5                	beqz	a5,80001026 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000106c:	80a9                	srli	s1,s1,0xa
    8000106e:	04b2                	slli	s1,s1,0xc
    80001070:	b7c5                	j	80001050 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001072:	00c9d513          	srli	a0,s3,0xc
    80001076:	1ff57513          	andi	a0,a0,511
    8000107a:	050e                	slli	a0,a0,0x3
    8000107c:	9526                	add	a0,a0,s1
}
    8000107e:	70e2                	ld	ra,56(sp)
    80001080:	7442                	ld	s0,48(sp)
    80001082:	74a2                	ld	s1,40(sp)
    80001084:	7902                	ld	s2,32(sp)
    80001086:	69e2                	ld	s3,24(sp)
    80001088:	6a42                	ld	s4,16(sp)
    8000108a:	6aa2                	ld	s5,8(sp)
    8000108c:	6b02                	ld	s6,0(sp)
    8000108e:	6121                	addi	sp,sp,64
    80001090:	8082                	ret
        return 0;
    80001092:	4501                	li	a0,0
    80001094:	b7ed                	j	8000107e <walk+0x8e>

0000000080001096 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001096:	57fd                	li	a5,-1
    80001098:	83e9                	srli	a5,a5,0x1a
    8000109a:	00b7f463          	bgeu	a5,a1,800010a2 <walkaddr+0xc>
    return 0;
    8000109e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010a0:	8082                	ret
{
    800010a2:	1141                	addi	sp,sp,-16
    800010a4:	e406                	sd	ra,8(sp)
    800010a6:	e022                	sd	s0,0(sp)
    800010a8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010aa:	4601                	li	a2,0
    800010ac:	00000097          	auipc	ra,0x0
    800010b0:	f44080e7          	jalr	-188(ra) # 80000ff0 <walk>
  if(pte == 0)
    800010b4:	c105                	beqz	a0,800010d4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010b6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010b8:	0117f693          	andi	a3,a5,17
    800010bc:	4745                	li	a4,17
    return 0;
    800010be:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010c0:	00e68663          	beq	a3,a4,800010cc <walkaddr+0x36>
}
    800010c4:	60a2                	ld	ra,8(sp)
    800010c6:	6402                	ld	s0,0(sp)
    800010c8:	0141                	addi	sp,sp,16
    800010ca:	8082                	ret
  pa = PTE2PA(*pte);
    800010cc:	00a7d513          	srli	a0,a5,0xa
    800010d0:	0532                	slli	a0,a0,0xc
  return pa;
    800010d2:	bfcd                	j	800010c4 <walkaddr+0x2e>
    return 0;
    800010d4:	4501                	li	a0,0
    800010d6:	b7fd                	j	800010c4 <walkaddr+0x2e>

00000000800010d8 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800010d8:	1101                	addi	sp,sp,-32
    800010da:	ec06                	sd	ra,24(sp)
    800010dc:	e822                	sd	s0,16(sp)
    800010de:	e426                	sd	s1,8(sp)
    800010e0:	1000                	addi	s0,sp,32
    800010e2:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800010e4:	1552                	slli	a0,a0,0x34
    800010e6:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800010ea:	4601                	li	a2,0
    800010ec:	00008517          	auipc	a0,0x8
    800010f0:	f2453503          	ld	a0,-220(a0) # 80009010 <kernel_pagetable>
    800010f4:	00000097          	auipc	ra,0x0
    800010f8:	efc080e7          	jalr	-260(ra) # 80000ff0 <walk>
  if(pte == 0)
    800010fc:	cd09                	beqz	a0,80001116 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800010fe:	6108                	ld	a0,0(a0)
    80001100:	00157793          	andi	a5,a0,1
    80001104:	c38d                	beqz	a5,80001126 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001106:	8129                	srli	a0,a0,0xa
    80001108:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000110a:	9526                	add	a0,a0,s1
    8000110c:	60e2                	ld	ra,24(sp)
    8000110e:	6442                	ld	s0,16(sp)
    80001110:	64a2                	ld	s1,8(sp)
    80001112:	6105                	addi	sp,sp,32
    80001114:	8082                	ret
    panic("kvmpa");
    80001116:	00007517          	auipc	a0,0x7
    8000111a:	fc250513          	addi	a0,a0,-62 # 800080d8 <digits+0x98>
    8000111e:	fffff097          	auipc	ra,0xfffff
    80001122:	432080e7          	jalr	1074(ra) # 80000550 <panic>
    panic("kvmpa");
    80001126:	00007517          	auipc	a0,0x7
    8000112a:	fb250513          	addi	a0,a0,-78 # 800080d8 <digits+0x98>
    8000112e:	fffff097          	auipc	ra,0xfffff
    80001132:	422080e7          	jalr	1058(ra) # 80000550 <panic>

0000000080001136 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001136:	715d                	addi	sp,sp,-80
    80001138:	e486                	sd	ra,72(sp)
    8000113a:	e0a2                	sd	s0,64(sp)
    8000113c:	fc26                	sd	s1,56(sp)
    8000113e:	f84a                	sd	s2,48(sp)
    80001140:	f44e                	sd	s3,40(sp)
    80001142:	f052                	sd	s4,32(sp)
    80001144:	ec56                	sd	s5,24(sp)
    80001146:	e85a                	sd	s6,16(sp)
    80001148:	e45e                	sd	s7,8(sp)
    8000114a:	0880                	addi	s0,sp,80
    8000114c:	8aaa                	mv	s5,a0
    8000114e:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001150:	777d                	lui	a4,0xfffff
    80001152:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001156:	167d                	addi	a2,a2,-1
    80001158:	00b609b3          	add	s3,a2,a1
    8000115c:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001160:	893e                	mv	s2,a5
    80001162:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001166:	6b85                	lui	s7,0x1
    80001168:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000116c:	4605                	li	a2,1
    8000116e:	85ca                	mv	a1,s2
    80001170:	8556                	mv	a0,s5
    80001172:	00000097          	auipc	ra,0x0
    80001176:	e7e080e7          	jalr	-386(ra) # 80000ff0 <walk>
    8000117a:	c51d                	beqz	a0,800011a8 <mappages+0x72>
    if(*pte & PTE_V)
    8000117c:	611c                	ld	a5,0(a0)
    8000117e:	8b85                	andi	a5,a5,1
    80001180:	ef81                	bnez	a5,80001198 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001182:	80b1                	srli	s1,s1,0xc
    80001184:	04aa                	slli	s1,s1,0xa
    80001186:	0164e4b3          	or	s1,s1,s6
    8000118a:	0014e493          	ori	s1,s1,1
    8000118e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001190:	03390863          	beq	s2,s3,800011c0 <mappages+0x8a>
    a += PGSIZE;
    80001194:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001196:	bfc9                	j	80001168 <mappages+0x32>
      panic("remap");
    80001198:	00007517          	auipc	a0,0x7
    8000119c:	f4850513          	addi	a0,a0,-184 # 800080e0 <digits+0xa0>
    800011a0:	fffff097          	auipc	ra,0xfffff
    800011a4:	3b0080e7          	jalr	944(ra) # 80000550 <panic>
      return -1;
    800011a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011aa:	60a6                	ld	ra,72(sp)
    800011ac:	6406                	ld	s0,64(sp)
    800011ae:	74e2                	ld	s1,56(sp)
    800011b0:	7942                	ld	s2,48(sp)
    800011b2:	79a2                	ld	s3,40(sp)
    800011b4:	7a02                	ld	s4,32(sp)
    800011b6:	6ae2                	ld	s5,24(sp)
    800011b8:	6b42                	ld	s6,16(sp)
    800011ba:	6ba2                	ld	s7,8(sp)
    800011bc:	6161                	addi	sp,sp,80
    800011be:	8082                	ret
  return 0;
    800011c0:	4501                	li	a0,0
    800011c2:	b7e5                	j	800011aa <mappages+0x74>

00000000800011c4 <kvmmap>:
{
    800011c4:	1141                	addi	sp,sp,-16
    800011c6:	e406                	sd	ra,8(sp)
    800011c8:	e022                	sd	s0,0(sp)
    800011ca:	0800                	addi	s0,sp,16
    800011cc:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800011ce:	86ae                	mv	a3,a1
    800011d0:	85aa                	mv	a1,a0
    800011d2:	00008517          	auipc	a0,0x8
    800011d6:	e3e53503          	ld	a0,-450(a0) # 80009010 <kernel_pagetable>
    800011da:	00000097          	auipc	ra,0x0
    800011de:	f5c080e7          	jalr	-164(ra) # 80001136 <mappages>
    800011e2:	e509                	bnez	a0,800011ec <kvmmap+0x28>
}
    800011e4:	60a2                	ld	ra,8(sp)
    800011e6:	6402                	ld	s0,0(sp)
    800011e8:	0141                	addi	sp,sp,16
    800011ea:	8082                	ret
    panic("kvmmap");
    800011ec:	00007517          	auipc	a0,0x7
    800011f0:	efc50513          	addi	a0,a0,-260 # 800080e8 <digits+0xa8>
    800011f4:	fffff097          	auipc	ra,0xfffff
    800011f8:	35c080e7          	jalr	860(ra) # 80000550 <panic>

00000000800011fc <kvminit>:
{
    800011fc:	1101                	addi	sp,sp,-32
    800011fe:	ec06                	sd	ra,24(sp)
    80001200:	e822                	sd	s0,16(sp)
    80001202:	e426                	sd	s1,8(sp)
    80001204:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	916080e7          	jalr	-1770(ra) # 80000b1c <kalloc>
    8000120e:	00008797          	auipc	a5,0x8
    80001212:	e0a7b123          	sd	a0,-510(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001216:	6605                	lui	a2,0x1
    80001218:	4581                	li	a1,0
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	aee080e7          	jalr	-1298(ra) # 80000d08 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001222:	4699                	li	a3,6
    80001224:	6605                	lui	a2,0x1
    80001226:	100005b7          	lui	a1,0x10000
    8000122a:	10000537          	lui	a0,0x10000
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	f96080e7          	jalr	-106(ra) # 800011c4 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001236:	4699                	li	a3,6
    80001238:	6605                	lui	a2,0x1
    8000123a:	100015b7          	lui	a1,0x10001
    8000123e:	10001537          	lui	a0,0x10001
    80001242:	00000097          	auipc	ra,0x0
    80001246:	f82080e7          	jalr	-126(ra) # 800011c4 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000124a:	4699                	li	a3,6
    8000124c:	6641                	lui	a2,0x10
    8000124e:	020005b7          	lui	a1,0x2000
    80001252:	02000537          	lui	a0,0x2000
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	f6e080e7          	jalr	-146(ra) # 800011c4 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000125e:	4699                	li	a3,6
    80001260:	00400637          	lui	a2,0x400
    80001264:	0c0005b7          	lui	a1,0xc000
    80001268:	0c000537          	lui	a0,0xc000
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	f58080e7          	jalr	-168(ra) # 800011c4 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001274:	00007497          	auipc	s1,0x7
    80001278:	d8c48493          	addi	s1,s1,-628 # 80008000 <etext>
    8000127c:	46a9                	li	a3,10
    8000127e:	80007617          	auipc	a2,0x80007
    80001282:	d8260613          	addi	a2,a2,-638 # 8000 <_entry-0x7fff8000>
    80001286:	4585                	li	a1,1
    80001288:	05fe                	slli	a1,a1,0x1f
    8000128a:	852e                	mv	a0,a1
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	f38080e7          	jalr	-200(ra) # 800011c4 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001294:	4699                	li	a3,6
    80001296:	4645                	li	a2,17
    80001298:	066e                	slli	a2,a2,0x1b
    8000129a:	8e05                	sub	a2,a2,s1
    8000129c:	85a6                	mv	a1,s1
    8000129e:	8526                	mv	a0,s1
    800012a0:	00000097          	auipc	ra,0x0
    800012a4:	f24080e7          	jalr	-220(ra) # 800011c4 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012a8:	46a9                	li	a3,10
    800012aa:	6605                	lui	a2,0x1
    800012ac:	00006597          	auipc	a1,0x6
    800012b0:	d5458593          	addi	a1,a1,-684 # 80007000 <_trampoline>
    800012b4:	04000537          	lui	a0,0x4000
    800012b8:	157d                	addi	a0,a0,-1
    800012ba:	0532                	slli	a0,a0,0xc
    800012bc:	00000097          	auipc	ra,0x0
    800012c0:	f08080e7          	jalr	-248(ra) # 800011c4 <kvmmap>
}
    800012c4:	60e2                	ld	ra,24(sp)
    800012c6:	6442                	ld	s0,16(sp)
    800012c8:	64a2                	ld	s1,8(sp)
    800012ca:	6105                	addi	sp,sp,32
    800012cc:	8082                	ret

00000000800012ce <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012ce:	715d                	addi	sp,sp,-80
    800012d0:	e486                	sd	ra,72(sp)
    800012d2:	e0a2                	sd	s0,64(sp)
    800012d4:	fc26                	sd	s1,56(sp)
    800012d6:	f84a                	sd	s2,48(sp)
    800012d8:	f44e                	sd	s3,40(sp)
    800012da:	f052                	sd	s4,32(sp)
    800012dc:	ec56                	sd	s5,24(sp)
    800012de:	e85a                	sd	s6,16(sp)
    800012e0:	e45e                	sd	s7,8(sp)
    800012e2:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012e4:	03459793          	slli	a5,a1,0x34
    800012e8:	e795                	bnez	a5,80001314 <uvmunmap+0x46>
    800012ea:	8a2a                	mv	s4,a0
    800012ec:	892e                	mv	s2,a1
    800012ee:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f0:	0632                	slli	a2,a2,0xc
    800012f2:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012f6:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f8:	6b05                	lui	s6,0x1
    800012fa:	0735e263          	bltu	a1,s3,8000135e <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012fe:	60a6                	ld	ra,72(sp)
    80001300:	6406                	ld	s0,64(sp)
    80001302:	74e2                	ld	s1,56(sp)
    80001304:	7942                	ld	s2,48(sp)
    80001306:	79a2                	ld	s3,40(sp)
    80001308:	7a02                	ld	s4,32(sp)
    8000130a:	6ae2                	ld	s5,24(sp)
    8000130c:	6b42                	ld	s6,16(sp)
    8000130e:	6ba2                	ld	s7,8(sp)
    80001310:	6161                	addi	sp,sp,80
    80001312:	8082                	ret
    panic("uvmunmap: not aligned");
    80001314:	00007517          	auipc	a0,0x7
    80001318:	ddc50513          	addi	a0,a0,-548 # 800080f0 <digits+0xb0>
    8000131c:	fffff097          	auipc	ra,0xfffff
    80001320:	234080e7          	jalr	564(ra) # 80000550 <panic>
      panic("uvmunmap: walk");
    80001324:	00007517          	auipc	a0,0x7
    80001328:	de450513          	addi	a0,a0,-540 # 80008108 <digits+0xc8>
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	224080e7          	jalr	548(ra) # 80000550 <panic>
      panic("uvmunmap: not mapped");
    80001334:	00007517          	auipc	a0,0x7
    80001338:	de450513          	addi	a0,a0,-540 # 80008118 <digits+0xd8>
    8000133c:	fffff097          	auipc	ra,0xfffff
    80001340:	214080e7          	jalr	532(ra) # 80000550 <panic>
      panic("uvmunmap: not a leaf");
    80001344:	00007517          	auipc	a0,0x7
    80001348:	dec50513          	addi	a0,a0,-532 # 80008130 <digits+0xf0>
    8000134c:	fffff097          	auipc	ra,0xfffff
    80001350:	204080e7          	jalr	516(ra) # 80000550 <panic>
    *pte = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001358:	995a                	add	s2,s2,s6
    8000135a:	fb3972e3          	bgeu	s2,s3,800012fe <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000135e:	4601                	li	a2,0
    80001360:	85ca                	mv	a1,s2
    80001362:	8552                	mv	a0,s4
    80001364:	00000097          	auipc	ra,0x0
    80001368:	c8c080e7          	jalr	-884(ra) # 80000ff0 <walk>
    8000136c:	84aa                	mv	s1,a0
    8000136e:	d95d                	beqz	a0,80001324 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001370:	6108                	ld	a0,0(a0)
    80001372:	00157793          	andi	a5,a0,1
    80001376:	dfdd                	beqz	a5,80001334 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001378:	3ff57793          	andi	a5,a0,1023
    8000137c:	fd7784e3          	beq	a5,s7,80001344 <uvmunmap+0x76>
    if(do_free){
    80001380:	fc0a8ae3          	beqz	s5,80001354 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001384:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001386:	0532                	slli	a0,a0,0xc
    80001388:	fffff097          	auipc	ra,0xfffff
    8000138c:	698080e7          	jalr	1688(ra) # 80000a20 <kfree>
    80001390:	b7d1                	j	80001354 <uvmunmap+0x86>

0000000080001392 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001392:	1101                	addi	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	780080e7          	jalr	1920(ra) # 80000b1c <kalloc>
    800013a4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a6:	c519                	beqz	a0,800013b4 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	95c080e7          	jalr	-1700(ra) # 80000d08 <memset>
  return pagetable;
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	addi	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c0:	7179                	addi	sp,sp,-48
    800013c2:	f406                	sd	ra,40(sp)
    800013c4:	f022                	sd	s0,32(sp)
    800013c6:	ec26                	sd	s1,24(sp)
    800013c8:	e84a                	sd	s2,16(sp)
    800013ca:	e44e                	sd	s3,8(sp)
    800013cc:	e052                	sd	s4,0(sp)
    800013ce:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d0:	6785                	lui	a5,0x1
    800013d2:	04f67863          	bgeu	a2,a5,80001422 <uvminit+0x62>
    800013d6:	8a2a                	mv	s4,a0
    800013d8:	89ae                	mv	s3,a1
    800013da:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	740080e7          	jalr	1856(ra) # 80000b1c <kalloc>
    800013e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	91e080e7          	jalr	-1762(ra) # 80000d08 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f2:	4779                	li	a4,30
    800013f4:	86ca                	mv	a3,s2
    800013f6:	6605                	lui	a2,0x1
    800013f8:	4581                	li	a1,0
    800013fa:	8552                	mv	a0,s4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	d3a080e7          	jalr	-710(ra) # 80001136 <mappages>
  memmove(mem, src, sz);
    80001404:	8626                	mv	a2,s1
    80001406:	85ce                	mv	a1,s3
    80001408:	854a                	mv	a0,s2
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	95a080e7          	jalr	-1702(ra) # 80000d64 <memmove>
}
    80001412:	70a2                	ld	ra,40(sp)
    80001414:	7402                	ld	s0,32(sp)
    80001416:	64e2                	ld	s1,24(sp)
    80001418:	6942                	ld	s2,16(sp)
    8000141a:	69a2                	ld	s3,8(sp)
    8000141c:	6a02                	ld	s4,0(sp)
    8000141e:	6145                	addi	sp,sp,48
    80001420:	8082                	ret
    panic("inituvm: more than a page");
    80001422:	00007517          	auipc	a0,0x7
    80001426:	d2650513          	addi	a0,a0,-730 # 80008148 <digits+0x108>
    8000142a:	fffff097          	auipc	ra,0xfffff
    8000142e:	126080e7          	jalr	294(ra) # 80000550 <panic>

0000000080001432 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001432:	1101                	addi	sp,sp,-32
    80001434:	ec06                	sd	ra,24(sp)
    80001436:	e822                	sd	s0,16(sp)
    80001438:	e426                	sd	s1,8(sp)
    8000143a:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143e:	00b67d63          	bgeu	a2,a1,80001458 <uvmdealloc+0x26>
    80001442:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001444:	6785                	lui	a5,0x1
    80001446:	17fd                	addi	a5,a5,-1
    80001448:	00f60733          	add	a4,a2,a5
    8000144c:	767d                	lui	a2,0xfffff
    8000144e:	8f71                	and	a4,a4,a2
    80001450:	97ae                	add	a5,a5,a1
    80001452:	8ff1                	and	a5,a5,a2
    80001454:	00f76863          	bltu	a4,a5,80001464 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001458:	8526                	mv	a0,s1
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	addi	sp,sp,32
    80001462:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001464:	8f99                	sub	a5,a5,a4
    80001466:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001468:	4685                	li	a3,1
    8000146a:	0007861b          	sext.w	a2,a5
    8000146e:	85ba                	mv	a1,a4
    80001470:	00000097          	auipc	ra,0x0
    80001474:	e5e080e7          	jalr	-418(ra) # 800012ce <uvmunmap>
    80001478:	b7c5                	j	80001458 <uvmdealloc+0x26>

000000008000147a <uvmalloc>:
  if(newsz < oldsz)
    8000147a:	0ab66163          	bltu	a2,a1,8000151c <uvmalloc+0xa2>
{
    8000147e:	7139                	addi	sp,sp,-64
    80001480:	fc06                	sd	ra,56(sp)
    80001482:	f822                	sd	s0,48(sp)
    80001484:	f426                	sd	s1,40(sp)
    80001486:	f04a                	sd	s2,32(sp)
    80001488:	ec4e                	sd	s3,24(sp)
    8000148a:	e852                	sd	s4,16(sp)
    8000148c:	e456                	sd	s5,8(sp)
    8000148e:	0080                	addi	s0,sp,64
    80001490:	8aaa                	mv	s5,a0
    80001492:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001494:	6985                	lui	s3,0x1
    80001496:	19fd                	addi	s3,s3,-1
    80001498:	95ce                	add	a1,a1,s3
    8000149a:	79fd                	lui	s3,0xfffff
    8000149c:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014a0:	08c9f063          	bgeu	s3,a2,80001520 <uvmalloc+0xa6>
    800014a4:	894e                	mv	s2,s3
    mem = kalloc();
    800014a6:	fffff097          	auipc	ra,0xfffff
    800014aa:	676080e7          	jalr	1654(ra) # 80000b1c <kalloc>
    800014ae:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b0:	c51d                	beqz	a0,800014de <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014b2:	6605                	lui	a2,0x1
    800014b4:	4581                	li	a1,0
    800014b6:	00000097          	auipc	ra,0x0
    800014ba:	852080e7          	jalr	-1966(ra) # 80000d08 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014be:	4779                	li	a4,30
    800014c0:	86a6                	mv	a3,s1
    800014c2:	6605                	lui	a2,0x1
    800014c4:	85ca                	mv	a1,s2
    800014c6:	8556                	mv	a0,s5
    800014c8:	00000097          	auipc	ra,0x0
    800014cc:	c6e080e7          	jalr	-914(ra) # 80001136 <mappages>
    800014d0:	e905                	bnez	a0,80001500 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d2:	6785                	lui	a5,0x1
    800014d4:	993e                	add	s2,s2,a5
    800014d6:	fd4968e3          	bltu	s2,s4,800014a6 <uvmalloc+0x2c>
  return newsz;
    800014da:	8552                	mv	a0,s4
    800014dc:	a809                	j	800014ee <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014de:	864e                	mv	a2,s3
    800014e0:	85ca                	mv	a1,s2
    800014e2:	8556                	mv	a0,s5
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	f4e080e7          	jalr	-178(ra) # 80001432 <uvmdealloc>
      return 0;
    800014ec:	4501                	li	a0,0
}
    800014ee:	70e2                	ld	ra,56(sp)
    800014f0:	7442                	ld	s0,48(sp)
    800014f2:	74a2                	ld	s1,40(sp)
    800014f4:	7902                	ld	s2,32(sp)
    800014f6:	69e2                	ld	s3,24(sp)
    800014f8:	6a42                	ld	s4,16(sp)
    800014fa:	6aa2                	ld	s5,8(sp)
    800014fc:	6121                	addi	sp,sp,64
    800014fe:	8082                	ret
      kfree(mem);
    80001500:	8526                	mv	a0,s1
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	51e080e7          	jalr	1310(ra) # 80000a20 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000150a:	864e                	mv	a2,s3
    8000150c:	85ca                	mv	a1,s2
    8000150e:	8556                	mv	a0,s5
    80001510:	00000097          	auipc	ra,0x0
    80001514:	f22080e7          	jalr	-222(ra) # 80001432 <uvmdealloc>
      return 0;
    80001518:	4501                	li	a0,0
    8000151a:	bfd1                	j	800014ee <uvmalloc+0x74>
    return oldsz;
    8000151c:	852e                	mv	a0,a1
}
    8000151e:	8082                	ret
  return newsz;
    80001520:	8532                	mv	a0,a2
    80001522:	b7f1                	j	800014ee <uvmalloc+0x74>

0000000080001524 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001524:	7179                	addi	sp,sp,-48
    80001526:	f406                	sd	ra,40(sp)
    80001528:	f022                	sd	s0,32(sp)
    8000152a:	ec26                	sd	s1,24(sp)
    8000152c:	e84a                	sd	s2,16(sp)
    8000152e:	e44e                	sd	s3,8(sp)
    80001530:	e052                	sd	s4,0(sp)
    80001532:	1800                	addi	s0,sp,48
    80001534:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001536:	84aa                	mv	s1,a0
    80001538:	6905                	lui	s2,0x1
    8000153a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000153c:	4985                	li	s3,1
    8000153e:	a821                	j	80001556 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001540:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001542:	0532                	slli	a0,a0,0xc
    80001544:	00000097          	auipc	ra,0x0
    80001548:	fe0080e7          	jalr	-32(ra) # 80001524 <freewalk>
      pagetable[i] = 0;
    8000154c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001550:	04a1                	addi	s1,s1,8
    80001552:	03248163          	beq	s1,s2,80001574 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001556:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001558:	00f57793          	andi	a5,a0,15
    8000155c:	ff3782e3          	beq	a5,s3,80001540 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001560:	8905                	andi	a0,a0,1
    80001562:	d57d                	beqz	a0,80001550 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001564:	00007517          	auipc	a0,0x7
    80001568:	c0450513          	addi	a0,a0,-1020 # 80008168 <digits+0x128>
    8000156c:	fffff097          	auipc	ra,0xfffff
    80001570:	fe4080e7          	jalr	-28(ra) # 80000550 <panic>
    }
  }
  kfree((void*)pagetable);
    80001574:	8552                	mv	a0,s4
    80001576:	fffff097          	auipc	ra,0xfffff
    8000157a:	4aa080e7          	jalr	1194(ra) # 80000a20 <kfree>
}
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	6942                	ld	s2,16(sp)
    80001586:	69a2                	ld	s3,8(sp)
    80001588:	6a02                	ld	s4,0(sp)
    8000158a:	6145                	addi	sp,sp,48
    8000158c:	8082                	ret

000000008000158e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000158e:	1101                	addi	sp,sp,-32
    80001590:	ec06                	sd	ra,24(sp)
    80001592:	e822                	sd	s0,16(sp)
    80001594:	e426                	sd	s1,8(sp)
    80001596:	1000                	addi	s0,sp,32
    80001598:	84aa                	mv	s1,a0
  if(sz > 0)
    8000159a:	e999                	bnez	a1,800015b0 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000159c:	8526                	mv	a0,s1
    8000159e:	00000097          	auipc	ra,0x0
    800015a2:	f86080e7          	jalr	-122(ra) # 80001524 <freewalk>
}
    800015a6:	60e2                	ld	ra,24(sp)
    800015a8:	6442                	ld	s0,16(sp)
    800015aa:	64a2                	ld	s1,8(sp)
    800015ac:	6105                	addi	sp,sp,32
    800015ae:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015b0:	6605                	lui	a2,0x1
    800015b2:	167d                	addi	a2,a2,-1
    800015b4:	962e                	add	a2,a2,a1
    800015b6:	4685                	li	a3,1
    800015b8:	8231                	srli	a2,a2,0xc
    800015ba:	4581                	li	a1,0
    800015bc:	00000097          	auipc	ra,0x0
    800015c0:	d12080e7          	jalr	-750(ra) # 800012ce <uvmunmap>
    800015c4:	bfe1                	j	8000159c <uvmfree+0xe>

00000000800015c6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015c6:	c679                	beqz	a2,80001694 <uvmcopy+0xce>
{
    800015c8:	715d                	addi	sp,sp,-80
    800015ca:	e486                	sd	ra,72(sp)
    800015cc:	e0a2                	sd	s0,64(sp)
    800015ce:	fc26                	sd	s1,56(sp)
    800015d0:	f84a                	sd	s2,48(sp)
    800015d2:	f44e                	sd	s3,40(sp)
    800015d4:	f052                	sd	s4,32(sp)
    800015d6:	ec56                	sd	s5,24(sp)
    800015d8:	e85a                	sd	s6,16(sp)
    800015da:	e45e                	sd	s7,8(sp)
    800015dc:	0880                	addi	s0,sp,80
    800015de:	8b2a                	mv	s6,a0
    800015e0:	8aae                	mv	s5,a1
    800015e2:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015e4:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015e6:	4601                	li	a2,0
    800015e8:	85ce                	mv	a1,s3
    800015ea:	855a                	mv	a0,s6
    800015ec:	00000097          	auipc	ra,0x0
    800015f0:	a04080e7          	jalr	-1532(ra) # 80000ff0 <walk>
    800015f4:	c531                	beqz	a0,80001640 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015f6:	6118                	ld	a4,0(a0)
    800015f8:	00177793          	andi	a5,a4,1
    800015fc:	cbb1                	beqz	a5,80001650 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015fe:	00a75593          	srli	a1,a4,0xa
    80001602:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001606:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	512080e7          	jalr	1298(ra) # 80000b1c <kalloc>
    80001612:	892a                	mv	s2,a0
    80001614:	c939                	beqz	a0,8000166a <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001616:	6605                	lui	a2,0x1
    80001618:	85de                	mv	a1,s7
    8000161a:	fffff097          	auipc	ra,0xfffff
    8000161e:	74a080e7          	jalr	1866(ra) # 80000d64 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001622:	8726                	mv	a4,s1
    80001624:	86ca                	mv	a3,s2
    80001626:	6605                	lui	a2,0x1
    80001628:	85ce                	mv	a1,s3
    8000162a:	8556                	mv	a0,s5
    8000162c:	00000097          	auipc	ra,0x0
    80001630:	b0a080e7          	jalr	-1270(ra) # 80001136 <mappages>
    80001634:	e515                	bnez	a0,80001660 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001636:	6785                	lui	a5,0x1
    80001638:	99be                	add	s3,s3,a5
    8000163a:	fb49e6e3          	bltu	s3,s4,800015e6 <uvmcopy+0x20>
    8000163e:	a081                	j	8000167e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001640:	00007517          	auipc	a0,0x7
    80001644:	b3850513          	addi	a0,a0,-1224 # 80008178 <digits+0x138>
    80001648:	fffff097          	auipc	ra,0xfffff
    8000164c:	f08080e7          	jalr	-248(ra) # 80000550 <panic>
      panic("uvmcopy: page not present");
    80001650:	00007517          	auipc	a0,0x7
    80001654:	b4850513          	addi	a0,a0,-1208 # 80008198 <digits+0x158>
    80001658:	fffff097          	auipc	ra,0xfffff
    8000165c:	ef8080e7          	jalr	-264(ra) # 80000550 <panic>
      kfree(mem);
    80001660:	854a                	mv	a0,s2
    80001662:	fffff097          	auipc	ra,0xfffff
    80001666:	3be080e7          	jalr	958(ra) # 80000a20 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000166a:	4685                	li	a3,1
    8000166c:	00c9d613          	srli	a2,s3,0xc
    80001670:	4581                	li	a1,0
    80001672:	8556                	mv	a0,s5
    80001674:	00000097          	auipc	ra,0x0
    80001678:	c5a080e7          	jalr	-934(ra) # 800012ce <uvmunmap>
  return -1;
    8000167c:	557d                	li	a0,-1
}
    8000167e:	60a6                	ld	ra,72(sp)
    80001680:	6406                	ld	s0,64(sp)
    80001682:	74e2                	ld	s1,56(sp)
    80001684:	7942                	ld	s2,48(sp)
    80001686:	79a2                	ld	s3,40(sp)
    80001688:	7a02                	ld	s4,32(sp)
    8000168a:	6ae2                	ld	s5,24(sp)
    8000168c:	6b42                	ld	s6,16(sp)
    8000168e:	6ba2                	ld	s7,8(sp)
    80001690:	6161                	addi	sp,sp,80
    80001692:	8082                	ret
  return 0;
    80001694:	4501                	li	a0,0
}
    80001696:	8082                	ret

0000000080001698 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001698:	1141                	addi	sp,sp,-16
    8000169a:	e406                	sd	ra,8(sp)
    8000169c:	e022                	sd	s0,0(sp)
    8000169e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016a0:	4601                	li	a2,0
    800016a2:	00000097          	auipc	ra,0x0
    800016a6:	94e080e7          	jalr	-1714(ra) # 80000ff0 <walk>
  if(pte == 0)
    800016aa:	c901                	beqz	a0,800016ba <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016ac:	611c                	ld	a5,0(a0)
    800016ae:	9bbd                	andi	a5,a5,-17
    800016b0:	e11c                	sd	a5,0(a0)
}
    800016b2:	60a2                	ld	ra,8(sp)
    800016b4:	6402                	ld	s0,0(sp)
    800016b6:	0141                	addi	sp,sp,16
    800016b8:	8082                	ret
    panic("uvmclear");
    800016ba:	00007517          	auipc	a0,0x7
    800016be:	afe50513          	addi	a0,a0,-1282 # 800081b8 <digits+0x178>
    800016c2:	fffff097          	auipc	ra,0xfffff
    800016c6:	e8e080e7          	jalr	-370(ra) # 80000550 <panic>

00000000800016ca <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ca:	c6bd                	beqz	a3,80001738 <copyout+0x6e>
{
    800016cc:	715d                	addi	sp,sp,-80
    800016ce:	e486                	sd	ra,72(sp)
    800016d0:	e0a2                	sd	s0,64(sp)
    800016d2:	fc26                	sd	s1,56(sp)
    800016d4:	f84a                	sd	s2,48(sp)
    800016d6:	f44e                	sd	s3,40(sp)
    800016d8:	f052                	sd	s4,32(sp)
    800016da:	ec56                	sd	s5,24(sp)
    800016dc:	e85a                	sd	s6,16(sp)
    800016de:	e45e                	sd	s7,8(sp)
    800016e0:	e062                	sd	s8,0(sp)
    800016e2:	0880                	addi	s0,sp,80
    800016e4:	8b2a                	mv	s6,a0
    800016e6:	8c2e                	mv	s8,a1
    800016e8:	8a32                	mv	s4,a2
    800016ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016ec:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016ee:	6a85                	lui	s5,0x1
    800016f0:	a015                	j	80001714 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016f2:	9562                	add	a0,a0,s8
    800016f4:	0004861b          	sext.w	a2,s1
    800016f8:	85d2                	mv	a1,s4
    800016fa:	41250533          	sub	a0,a0,s2
    800016fe:	fffff097          	auipc	ra,0xfffff
    80001702:	666080e7          	jalr	1638(ra) # 80000d64 <memmove>

    len -= n;
    80001706:	409989b3          	sub	s3,s3,s1
    src += n;
    8000170a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000170c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001710:	02098263          	beqz	s3,80001734 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001714:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001718:	85ca                	mv	a1,s2
    8000171a:	855a                	mv	a0,s6
    8000171c:	00000097          	auipc	ra,0x0
    80001720:	97a080e7          	jalr	-1670(ra) # 80001096 <walkaddr>
    if(pa0 == 0)
    80001724:	cd01                	beqz	a0,8000173c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001726:	418904b3          	sub	s1,s2,s8
    8000172a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000172c:	fc99f3e3          	bgeu	s3,s1,800016f2 <copyout+0x28>
    80001730:	84ce                	mv	s1,s3
    80001732:	b7c1                	j	800016f2 <copyout+0x28>
  }
  return 0;
    80001734:	4501                	li	a0,0
    80001736:	a021                	j	8000173e <copyout+0x74>
    80001738:	4501                	li	a0,0
}
    8000173a:	8082                	ret
      return -1;
    8000173c:	557d                	li	a0,-1
}
    8000173e:	60a6                	ld	ra,72(sp)
    80001740:	6406                	ld	s0,64(sp)
    80001742:	74e2                	ld	s1,56(sp)
    80001744:	7942                	ld	s2,48(sp)
    80001746:	79a2                	ld	s3,40(sp)
    80001748:	7a02                	ld	s4,32(sp)
    8000174a:	6ae2                	ld	s5,24(sp)
    8000174c:	6b42                	ld	s6,16(sp)
    8000174e:	6ba2                	ld	s7,8(sp)
    80001750:	6c02                	ld	s8,0(sp)
    80001752:	6161                	addi	sp,sp,80
    80001754:	8082                	ret

0000000080001756 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001756:	caa5                	beqz	a3,800017c6 <copyin+0x70>
{
    80001758:	715d                	addi	sp,sp,-80
    8000175a:	e486                	sd	ra,72(sp)
    8000175c:	e0a2                	sd	s0,64(sp)
    8000175e:	fc26                	sd	s1,56(sp)
    80001760:	f84a                	sd	s2,48(sp)
    80001762:	f44e                	sd	s3,40(sp)
    80001764:	f052                	sd	s4,32(sp)
    80001766:	ec56                	sd	s5,24(sp)
    80001768:	e85a                	sd	s6,16(sp)
    8000176a:	e45e                	sd	s7,8(sp)
    8000176c:	e062                	sd	s8,0(sp)
    8000176e:	0880                	addi	s0,sp,80
    80001770:	8b2a                	mv	s6,a0
    80001772:	8a2e                	mv	s4,a1
    80001774:	8c32                	mv	s8,a2
    80001776:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001778:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000177a:	6a85                	lui	s5,0x1
    8000177c:	a01d                	j	800017a2 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000177e:	018505b3          	add	a1,a0,s8
    80001782:	0004861b          	sext.w	a2,s1
    80001786:	412585b3          	sub	a1,a1,s2
    8000178a:	8552                	mv	a0,s4
    8000178c:	fffff097          	auipc	ra,0xfffff
    80001790:	5d8080e7          	jalr	1496(ra) # 80000d64 <memmove>

    len -= n;
    80001794:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001798:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000179a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000179e:	02098263          	beqz	s3,800017c2 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017a2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017a6:	85ca                	mv	a1,s2
    800017a8:	855a                	mv	a0,s6
    800017aa:	00000097          	auipc	ra,0x0
    800017ae:	8ec080e7          	jalr	-1812(ra) # 80001096 <walkaddr>
    if(pa0 == 0)
    800017b2:	cd01                	beqz	a0,800017ca <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017b4:	418904b3          	sub	s1,s2,s8
    800017b8:	94d6                	add	s1,s1,s5
    if(n > len)
    800017ba:	fc99f2e3          	bgeu	s3,s1,8000177e <copyin+0x28>
    800017be:	84ce                	mv	s1,s3
    800017c0:	bf7d                	j	8000177e <copyin+0x28>
  }
  return 0;
    800017c2:	4501                	li	a0,0
    800017c4:	a021                	j	800017cc <copyin+0x76>
    800017c6:	4501                	li	a0,0
}
    800017c8:	8082                	ret
      return -1;
    800017ca:	557d                	li	a0,-1
}
    800017cc:	60a6                	ld	ra,72(sp)
    800017ce:	6406                	ld	s0,64(sp)
    800017d0:	74e2                	ld	s1,56(sp)
    800017d2:	7942                	ld	s2,48(sp)
    800017d4:	79a2                	ld	s3,40(sp)
    800017d6:	7a02                	ld	s4,32(sp)
    800017d8:	6ae2                	ld	s5,24(sp)
    800017da:	6b42                	ld	s6,16(sp)
    800017dc:	6ba2                	ld	s7,8(sp)
    800017de:	6c02                	ld	s8,0(sp)
    800017e0:	6161                	addi	sp,sp,80
    800017e2:	8082                	ret

00000000800017e4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017e4:	c6c5                	beqz	a3,8000188c <copyinstr+0xa8>
{
    800017e6:	715d                	addi	sp,sp,-80
    800017e8:	e486                	sd	ra,72(sp)
    800017ea:	e0a2                	sd	s0,64(sp)
    800017ec:	fc26                	sd	s1,56(sp)
    800017ee:	f84a                	sd	s2,48(sp)
    800017f0:	f44e                	sd	s3,40(sp)
    800017f2:	f052                	sd	s4,32(sp)
    800017f4:	ec56                	sd	s5,24(sp)
    800017f6:	e85a                	sd	s6,16(sp)
    800017f8:	e45e                	sd	s7,8(sp)
    800017fa:	0880                	addi	s0,sp,80
    800017fc:	8a2a                	mv	s4,a0
    800017fe:	8b2e                	mv	s6,a1
    80001800:	8bb2                	mv	s7,a2
    80001802:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001804:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001806:	6985                	lui	s3,0x1
    80001808:	a035                	j	80001834 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000180a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000180e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001810:	0017b793          	seqz	a5,a5
    80001814:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001818:	60a6                	ld	ra,72(sp)
    8000181a:	6406                	ld	s0,64(sp)
    8000181c:	74e2                	ld	s1,56(sp)
    8000181e:	7942                	ld	s2,48(sp)
    80001820:	79a2                	ld	s3,40(sp)
    80001822:	7a02                	ld	s4,32(sp)
    80001824:	6ae2                	ld	s5,24(sp)
    80001826:	6b42                	ld	s6,16(sp)
    80001828:	6ba2                	ld	s7,8(sp)
    8000182a:	6161                	addi	sp,sp,80
    8000182c:	8082                	ret
    srcva = va0 + PGSIZE;
    8000182e:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001832:	c8a9                	beqz	s1,80001884 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001834:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001838:	85ca                	mv	a1,s2
    8000183a:	8552                	mv	a0,s4
    8000183c:	00000097          	auipc	ra,0x0
    80001840:	85a080e7          	jalr	-1958(ra) # 80001096 <walkaddr>
    if(pa0 == 0)
    80001844:	c131                	beqz	a0,80001888 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001846:	41790833          	sub	a6,s2,s7
    8000184a:	984e                	add	a6,a6,s3
    if(n > max)
    8000184c:	0104f363          	bgeu	s1,a6,80001852 <copyinstr+0x6e>
    80001850:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001852:	955e                	add	a0,a0,s7
    80001854:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001858:	fc080be3          	beqz	a6,8000182e <copyinstr+0x4a>
    8000185c:	985a                	add	a6,a6,s6
    8000185e:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001860:	41650633          	sub	a2,a0,s6
    80001864:	14fd                	addi	s1,s1,-1
    80001866:	9b26                	add	s6,s6,s1
    80001868:	00f60733          	add	a4,a2,a5
    8000186c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80001870:	df49                	beqz	a4,8000180a <copyinstr+0x26>
        *dst = *p;
    80001872:	00e78023          	sb	a4,0(a5)
      --max;
    80001876:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000187a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000187c:	ff0796e3          	bne	a5,a6,80001868 <copyinstr+0x84>
      dst++;
    80001880:	8b42                	mv	s6,a6
    80001882:	b775                	j	8000182e <copyinstr+0x4a>
    80001884:	4781                	li	a5,0
    80001886:	b769                	j	80001810 <copyinstr+0x2c>
      return -1;
    80001888:	557d                	li	a0,-1
    8000188a:	b779                	j	80001818 <copyinstr+0x34>
  int got_null = 0;
    8000188c:	4781                	li	a5,0
  if(got_null){
    8000188e:	0017b793          	seqz	a5,a5
    80001892:	40f00533          	neg	a0,a5
}
    80001896:	8082                	ret

0000000080001898 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001898:	1101                	addi	sp,sp,-32
    8000189a:	ec06                	sd	ra,24(sp)
    8000189c:	e822                	sd	s0,16(sp)
    8000189e:	e426                	sd	s1,8(sp)
    800018a0:	1000                	addi	s0,sp,32
    800018a2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018a4:	fffff097          	auipc	ra,0xfffff
    800018a8:	2ee080e7          	jalr	750(ra) # 80000b92 <holding>
    800018ac:	c909                	beqz	a0,800018be <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018ae:	749c                	ld	a5,40(s1)
    800018b0:	00978f63          	beq	a5,s1,800018ce <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018b4:	60e2                	ld	ra,24(sp)
    800018b6:	6442                	ld	s0,16(sp)
    800018b8:	64a2                	ld	s1,8(sp)
    800018ba:	6105                	addi	sp,sp,32
    800018bc:	8082                	ret
    panic("wakeup1");
    800018be:	00007517          	auipc	a0,0x7
    800018c2:	90a50513          	addi	a0,a0,-1782 # 800081c8 <digits+0x188>
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	c8a080e7          	jalr	-886(ra) # 80000550 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800018ce:	4c98                	lw	a4,24(s1)
    800018d0:	4785                	li	a5,1
    800018d2:	fef711e3          	bne	a4,a5,800018b4 <wakeup1+0x1c>
    p->state = RUNNABLE;
    800018d6:	4789                	li	a5,2
    800018d8:	cc9c                	sw	a5,24(s1)
}
    800018da:	bfe9                	j	800018b4 <wakeup1+0x1c>

00000000800018dc <procinit>:
{
    800018dc:	715d                	addi	sp,sp,-80
    800018de:	e486                	sd	ra,72(sp)
    800018e0:	e0a2                	sd	s0,64(sp)
    800018e2:	fc26                	sd	s1,56(sp)
    800018e4:	f84a                	sd	s2,48(sp)
    800018e6:	f44e                	sd	s3,40(sp)
    800018e8:	f052                	sd	s4,32(sp)
    800018ea:	ec56                	sd	s5,24(sp)
    800018ec:	e85a                	sd	s6,16(sp)
    800018ee:	e45e                	sd	s7,8(sp)
    800018f0:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8de58593          	addi	a1,a1,-1826 # 800081d0 <digits+0x190>
    800018fa:	00010517          	auipc	a0,0x10
    800018fe:	05650513          	addi	a0,a0,86 # 80011950 <pid_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	27a080e7          	jalr	634(ra) # 80000b7c <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	00010917          	auipc	s2,0x10
    8000190e:	45e90913          	addi	s2,s2,1118 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001912:	00007b97          	auipc	s7,0x7
    80001916:	8c6b8b93          	addi	s7,s7,-1850 # 800081d8 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    8000191a:	8b4a                	mv	s6,s2
    8000191c:	00006a97          	auipc	s5,0x6
    80001920:	6e4a8a93          	addi	s5,s5,1764 # 80008000 <etext>
    80001924:	040009b7          	lui	s3,0x4000
    80001928:	19fd                	addi	s3,s3,-1
    8000192a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192c:	00016a17          	auipc	s4,0x16
    80001930:	e3ca0a13          	addi	s4,s4,-452 # 80017768 <tickslock>
      initlock(&p->lock, "proc");
    80001934:	85de                	mv	a1,s7
    80001936:	854a                	mv	a0,s2
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	244080e7          	jalr	580(ra) # 80000b7c <initlock>
      char *pa = kalloc();
    80001940:	fffff097          	auipc	ra,0xfffff
    80001944:	1dc080e7          	jalr	476(ra) # 80000b1c <kalloc>
    80001948:	85aa                	mv	a1,a0
      if(pa == 0)
    8000194a:	c929                	beqz	a0,8000199c <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    8000194c:	416904b3          	sub	s1,s2,s6
    80001950:	848d                	srai	s1,s1,0x3
    80001952:	000ab783          	ld	a5,0(s5)
    80001956:	02f484b3          	mul	s1,s1,a5
    8000195a:	2485                	addiw	s1,s1,1
    8000195c:	00d4949b          	slliw	s1,s1,0xd
    80001960:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001964:	4699                	li	a3,6
    80001966:	6605                	lui	a2,0x1
    80001968:	8526                	mv	a0,s1
    8000196a:	00000097          	auipc	ra,0x0
    8000196e:	85a080e7          	jalr	-1958(ra) # 800011c4 <kvmmap>
      p->kstack = va;
    80001972:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001976:	16890913          	addi	s2,s2,360
    8000197a:	fb491de3          	bne	s2,s4,80001934 <procinit+0x58>
  kvminithart();
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	64e080e7          	jalr	1614(ra) # 80000fcc <kvminithart>
}
    80001986:	60a6                	ld	ra,72(sp)
    80001988:	6406                	ld	s0,64(sp)
    8000198a:	74e2                	ld	s1,56(sp)
    8000198c:	7942                	ld	s2,48(sp)
    8000198e:	79a2                	ld	s3,40(sp)
    80001990:	7a02                	ld	s4,32(sp)
    80001992:	6ae2                	ld	s5,24(sp)
    80001994:	6b42                	ld	s6,16(sp)
    80001996:	6ba2                	ld	s7,8(sp)
    80001998:	6161                	addi	sp,sp,80
    8000199a:	8082                	ret
        panic("kalloc");
    8000199c:	00007517          	auipc	a0,0x7
    800019a0:	84450513          	addi	a0,a0,-1980 # 800081e0 <digits+0x1a0>
    800019a4:	fffff097          	auipc	ra,0xfffff
    800019a8:	bac080e7          	jalr	-1108(ra) # 80000550 <panic>

00000000800019ac <cpuid>:
{
    800019ac:	1141                	addi	sp,sp,-16
    800019ae:	e422                	sd	s0,8(sp)
    800019b0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019b2:	8512                	mv	a0,tp
}
    800019b4:	2501                	sext.w	a0,a0
    800019b6:	6422                	ld	s0,8(sp)
    800019b8:	0141                	addi	sp,sp,16
    800019ba:	8082                	ret

00000000800019bc <mycpu>:
mycpu(void) {
    800019bc:	1141                	addi	sp,sp,-16
    800019be:	e422                	sd	s0,8(sp)
    800019c0:	0800                	addi	s0,sp,16
    800019c2:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    800019c4:	2781                	sext.w	a5,a5
    800019c6:	079e                	slli	a5,a5,0x7
}
    800019c8:	00010517          	auipc	a0,0x10
    800019cc:	fa050513          	addi	a0,a0,-96 # 80011968 <cpus>
    800019d0:	953e                	add	a0,a0,a5
    800019d2:	6422                	ld	s0,8(sp)
    800019d4:	0141                	addi	sp,sp,16
    800019d6:	8082                	ret

00000000800019d8 <myproc>:
myproc(void) {
    800019d8:	1101                	addi	sp,sp,-32
    800019da:	ec06                	sd	ra,24(sp)
    800019dc:	e822                	sd	s0,16(sp)
    800019de:	e426                	sd	s1,8(sp)
    800019e0:	1000                	addi	s0,sp,32
  push_off();
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	1de080e7          	jalr	478(ra) # 80000bc0 <push_off>
    800019ea:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    800019ec:	2781                	sext.w	a5,a5
    800019ee:	079e                	slli	a5,a5,0x7
    800019f0:	00010717          	auipc	a4,0x10
    800019f4:	f6070713          	addi	a4,a4,-160 # 80011950 <pid_lock>
    800019f8:	97ba                	add	a5,a5,a4
    800019fa:	6f84                	ld	s1,24(a5)
  pop_off();
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	264080e7          	jalr	612(ra) # 80000c60 <pop_off>
}
    80001a04:	8526                	mv	a0,s1
    80001a06:	60e2                	ld	ra,24(sp)
    80001a08:	6442                	ld	s0,16(sp)
    80001a0a:	64a2                	ld	s1,8(sp)
    80001a0c:	6105                	addi	sp,sp,32
    80001a0e:	8082                	ret

0000000080001a10 <forkret>:
{
    80001a10:	1141                	addi	sp,sp,-16
    80001a12:	e406                	sd	ra,8(sp)
    80001a14:	e022                	sd	s0,0(sp)
    80001a16:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a18:	00000097          	auipc	ra,0x0
    80001a1c:	fc0080e7          	jalr	-64(ra) # 800019d8 <myproc>
    80001a20:	fffff097          	auipc	ra,0xfffff
    80001a24:	2a0080e7          	jalr	672(ra) # 80000cc0 <release>
  if (first) {
    80001a28:	00007797          	auipc	a5,0x7
    80001a2c:	de87a783          	lw	a5,-536(a5) # 80008810 <first.1>
    80001a30:	eb89                	bnez	a5,80001a42 <forkret+0x32>
  usertrapret();
    80001a32:	00001097          	auipc	ra,0x1
    80001a36:	c14080e7          	jalr	-1004(ra) # 80002646 <usertrapret>
}
    80001a3a:	60a2                	ld	ra,8(sp)
    80001a3c:	6402                	ld	s0,0(sp)
    80001a3e:	0141                	addi	sp,sp,16
    80001a40:	8082                	ret
    first = 0;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	dc07a723          	sw	zero,-562(a5) # 80008810 <first.1>
    fsinit(ROOTDEV);
    80001a4a:	4505                	li	a0,1
    80001a4c:	00002097          	auipc	ra,0x2
    80001a50:	93a080e7          	jalr	-1734(ra) # 80003386 <fsinit>
    80001a54:	bff9                	j	80001a32 <forkret+0x22>

0000000080001a56 <allocpid>:
allocpid() {
    80001a56:	1101                	addi	sp,sp,-32
    80001a58:	ec06                	sd	ra,24(sp)
    80001a5a:	e822                	sd	s0,16(sp)
    80001a5c:	e426                	sd	s1,8(sp)
    80001a5e:	e04a                	sd	s2,0(sp)
    80001a60:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a62:	00010917          	auipc	s2,0x10
    80001a66:	eee90913          	addi	s2,s2,-274 # 80011950 <pid_lock>
    80001a6a:	854a                	mv	a0,s2
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	1a0080e7          	jalr	416(ra) # 80000c0c <acquire>
  pid = nextpid;
    80001a74:	00007797          	auipc	a5,0x7
    80001a78:	da078793          	addi	a5,a5,-608 # 80008814 <nextpid>
    80001a7c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a7e:	0014871b          	addiw	a4,s1,1
    80001a82:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a84:	854a                	mv	a0,s2
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	23a080e7          	jalr	570(ra) # 80000cc0 <release>
}
    80001a8e:	8526                	mv	a0,s1
    80001a90:	60e2                	ld	ra,24(sp)
    80001a92:	6442                	ld	s0,16(sp)
    80001a94:	64a2                	ld	s1,8(sp)
    80001a96:	6902                	ld	s2,0(sp)
    80001a98:	6105                	addi	sp,sp,32
    80001a9a:	8082                	ret

0000000080001a9c <proc_pagetable>:
{
    80001a9c:	1101                	addi	sp,sp,-32
    80001a9e:	ec06                	sd	ra,24(sp)
    80001aa0:	e822                	sd	s0,16(sp)
    80001aa2:	e426                	sd	s1,8(sp)
    80001aa4:	e04a                	sd	s2,0(sp)
    80001aa6:	1000                	addi	s0,sp,32
    80001aa8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aaa:	00000097          	auipc	ra,0x0
    80001aae:	8e8080e7          	jalr	-1816(ra) # 80001392 <uvmcreate>
    80001ab2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ab4:	c121                	beqz	a0,80001af4 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ab6:	4729                	li	a4,10
    80001ab8:	00005697          	auipc	a3,0x5
    80001abc:	54868693          	addi	a3,a3,1352 # 80007000 <_trampoline>
    80001ac0:	6605                	lui	a2,0x1
    80001ac2:	040005b7          	lui	a1,0x4000
    80001ac6:	15fd                	addi	a1,a1,-1
    80001ac8:	05b2                	slli	a1,a1,0xc
    80001aca:	fffff097          	auipc	ra,0xfffff
    80001ace:	66c080e7          	jalr	1644(ra) # 80001136 <mappages>
    80001ad2:	02054863          	bltz	a0,80001b02 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ad6:	4719                	li	a4,6
    80001ad8:	05893683          	ld	a3,88(s2)
    80001adc:	6605                	lui	a2,0x1
    80001ade:	020005b7          	lui	a1,0x2000
    80001ae2:	15fd                	addi	a1,a1,-1
    80001ae4:	05b6                	slli	a1,a1,0xd
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	fffff097          	auipc	ra,0xfffff
    80001aec:	64e080e7          	jalr	1614(ra) # 80001136 <mappages>
    80001af0:	02054163          	bltz	a0,80001b12 <proc_pagetable+0x76>
}
    80001af4:	8526                	mv	a0,s1
    80001af6:	60e2                	ld	ra,24(sp)
    80001af8:	6442                	ld	s0,16(sp)
    80001afa:	64a2                	ld	s1,8(sp)
    80001afc:	6902                	ld	s2,0(sp)
    80001afe:	6105                	addi	sp,sp,32
    80001b00:	8082                	ret
    uvmfree(pagetable, 0);
    80001b02:	4581                	li	a1,0
    80001b04:	8526                	mv	a0,s1
    80001b06:	00000097          	auipc	ra,0x0
    80001b0a:	a88080e7          	jalr	-1400(ra) # 8000158e <uvmfree>
    return 0;
    80001b0e:	4481                	li	s1,0
    80001b10:	b7d5                	j	80001af4 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b12:	4681                	li	a3,0
    80001b14:	4605                	li	a2,1
    80001b16:	040005b7          	lui	a1,0x4000
    80001b1a:	15fd                	addi	a1,a1,-1
    80001b1c:	05b2                	slli	a1,a1,0xc
    80001b1e:	8526                	mv	a0,s1
    80001b20:	fffff097          	auipc	ra,0xfffff
    80001b24:	7ae080e7          	jalr	1966(ra) # 800012ce <uvmunmap>
    uvmfree(pagetable, 0);
    80001b28:	4581                	li	a1,0
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	00000097          	auipc	ra,0x0
    80001b30:	a62080e7          	jalr	-1438(ra) # 8000158e <uvmfree>
    return 0;
    80001b34:	4481                	li	s1,0
    80001b36:	bf7d                	j	80001af4 <proc_pagetable+0x58>

0000000080001b38 <proc_freepagetable>:
{
    80001b38:	1101                	addi	sp,sp,-32
    80001b3a:	ec06                	sd	ra,24(sp)
    80001b3c:	e822                	sd	s0,16(sp)
    80001b3e:	e426                	sd	s1,8(sp)
    80001b40:	e04a                	sd	s2,0(sp)
    80001b42:	1000                	addi	s0,sp,32
    80001b44:	84aa                	mv	s1,a0
    80001b46:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b48:	4681                	li	a3,0
    80001b4a:	4605                	li	a2,1
    80001b4c:	040005b7          	lui	a1,0x4000
    80001b50:	15fd                	addi	a1,a1,-1
    80001b52:	05b2                	slli	a1,a1,0xc
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	77a080e7          	jalr	1914(ra) # 800012ce <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b5c:	4681                	li	a3,0
    80001b5e:	4605                	li	a2,1
    80001b60:	020005b7          	lui	a1,0x2000
    80001b64:	15fd                	addi	a1,a1,-1
    80001b66:	05b6                	slli	a1,a1,0xd
    80001b68:	8526                	mv	a0,s1
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	764080e7          	jalr	1892(ra) # 800012ce <uvmunmap>
  uvmfree(pagetable, sz);
    80001b72:	85ca                	mv	a1,s2
    80001b74:	8526                	mv	a0,s1
    80001b76:	00000097          	auipc	ra,0x0
    80001b7a:	a18080e7          	jalr	-1512(ra) # 8000158e <uvmfree>
}
    80001b7e:	60e2                	ld	ra,24(sp)
    80001b80:	6442                	ld	s0,16(sp)
    80001b82:	64a2                	ld	s1,8(sp)
    80001b84:	6902                	ld	s2,0(sp)
    80001b86:	6105                	addi	sp,sp,32
    80001b88:	8082                	ret

0000000080001b8a <freeproc>:
{
    80001b8a:	1101                	addi	sp,sp,-32
    80001b8c:	ec06                	sd	ra,24(sp)
    80001b8e:	e822                	sd	s0,16(sp)
    80001b90:	e426                	sd	s1,8(sp)
    80001b92:	1000                	addi	s0,sp,32
    80001b94:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b96:	6d28                	ld	a0,88(a0)
    80001b98:	c509                	beqz	a0,80001ba2 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b9a:	fffff097          	auipc	ra,0xfffff
    80001b9e:	e86080e7          	jalr	-378(ra) # 80000a20 <kfree>
  p->trapframe = 0;
    80001ba2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ba6:	68a8                	ld	a0,80(s1)
    80001ba8:	c511                	beqz	a0,80001bb4 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001baa:	64ac                	ld	a1,72(s1)
    80001bac:	00000097          	auipc	ra,0x0
    80001bb0:	f8c080e7          	jalr	-116(ra) # 80001b38 <proc_freepagetable>
  p->pagetable = 0;
    80001bb4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bb8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bbc:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001bc0:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001bc4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bc8:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001bcc:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001bd0:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001bd4:	0004ac23          	sw	zero,24(s1)
}
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6105                	addi	sp,sp,32
    80001be0:	8082                	ret

0000000080001be2 <allocproc>:
{
    80001be2:	1101                	addi	sp,sp,-32
    80001be4:	ec06                	sd	ra,24(sp)
    80001be6:	e822                	sd	s0,16(sp)
    80001be8:	e426                	sd	s1,8(sp)
    80001bea:	e04a                	sd	s2,0(sp)
    80001bec:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bee:	00010497          	auipc	s1,0x10
    80001bf2:	17a48493          	addi	s1,s1,378 # 80011d68 <proc>
    80001bf6:	00016917          	auipc	s2,0x16
    80001bfa:	b7290913          	addi	s2,s2,-1166 # 80017768 <tickslock>
    acquire(&p->lock);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	00c080e7          	jalr	12(ra) # 80000c0c <acquire>
    if(p->state == UNUSED) {
    80001c08:	4c9c                	lw	a5,24(s1)
    80001c0a:	cf81                	beqz	a5,80001c22 <allocproc+0x40>
      release(&p->lock);
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	0b2080e7          	jalr	178(ra) # 80000cc0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c16:	16848493          	addi	s1,s1,360
    80001c1a:	ff2492e3          	bne	s1,s2,80001bfe <allocproc+0x1c>
  return 0;
    80001c1e:	4481                	li	s1,0
    80001c20:	a0b9                	j	80001c6e <allocproc+0x8c>
  p->pid = allocpid();
    80001c22:	00000097          	auipc	ra,0x0
    80001c26:	e34080e7          	jalr	-460(ra) # 80001a56 <allocpid>
    80001c2a:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	ef0080e7          	jalr	-272(ra) # 80000b1c <kalloc>
    80001c34:	892a                	mv	s2,a0
    80001c36:	eca8                	sd	a0,88(s1)
    80001c38:	c131                	beqz	a0,80001c7c <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001c3a:	8526                	mv	a0,s1
    80001c3c:	00000097          	auipc	ra,0x0
    80001c40:	e60080e7          	jalr	-416(ra) # 80001a9c <proc_pagetable>
    80001c44:	892a                	mv	s2,a0
    80001c46:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c48:	c129                	beqz	a0,80001c8a <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001c4a:	07000613          	li	a2,112
    80001c4e:	4581                	li	a1,0
    80001c50:	06048513          	addi	a0,s1,96
    80001c54:	fffff097          	auipc	ra,0xfffff
    80001c58:	0b4080e7          	jalr	180(ra) # 80000d08 <memset>
  p->context.ra = (uint64)forkret;
    80001c5c:	00000797          	auipc	a5,0x0
    80001c60:	db478793          	addi	a5,a5,-588 # 80001a10 <forkret>
    80001c64:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c66:	60bc                	ld	a5,64(s1)
    80001c68:	6705                	lui	a4,0x1
    80001c6a:	97ba                	add	a5,a5,a4
    80001c6c:	f4bc                	sd	a5,104(s1)
}
    80001c6e:	8526                	mv	a0,s1
    80001c70:	60e2                	ld	ra,24(sp)
    80001c72:	6442                	ld	s0,16(sp)
    80001c74:	64a2                	ld	s1,8(sp)
    80001c76:	6902                	ld	s2,0(sp)
    80001c78:	6105                	addi	sp,sp,32
    80001c7a:	8082                	ret
    release(&p->lock);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	042080e7          	jalr	66(ra) # 80000cc0 <release>
    return 0;
    80001c86:	84ca                	mv	s1,s2
    80001c88:	b7dd                	j	80001c6e <allocproc+0x8c>
    freeproc(p);
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	efe080e7          	jalr	-258(ra) # 80001b8a <freeproc>
    release(&p->lock);
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	02a080e7          	jalr	42(ra) # 80000cc0 <release>
    return 0;
    80001c9e:	84ca                	mv	s1,s2
    80001ca0:	b7f9                	j	80001c6e <allocproc+0x8c>

0000000080001ca2 <userinit>:
{
    80001ca2:	1101                	addi	sp,sp,-32
    80001ca4:	ec06                	sd	ra,24(sp)
    80001ca6:	e822                	sd	s0,16(sp)
    80001ca8:	e426                	sd	s1,8(sp)
    80001caa:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	f36080e7          	jalr	-202(ra) # 80001be2 <allocproc>
    80001cb4:	84aa                	mv	s1,a0
  initproc = p;
    80001cb6:	00007797          	auipc	a5,0x7
    80001cba:	36a7b123          	sd	a0,866(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cbe:	03400613          	li	a2,52
    80001cc2:	00007597          	auipc	a1,0x7
    80001cc6:	b5e58593          	addi	a1,a1,-1186 # 80008820 <initcode>
    80001cca:	6928                	ld	a0,80(a0)
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	6f4080e7          	jalr	1780(ra) # 800013c0 <uvminit>
  p->sz = PGSIZE;
    80001cd4:	6785                	lui	a5,0x1
    80001cd6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd8:	6cb8                	ld	a4,88(s1)
    80001cda:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cde:	6cb8                	ld	a4,88(s1)
    80001ce0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce2:	4641                	li	a2,16
    80001ce4:	00006597          	auipc	a1,0x6
    80001ce8:	50458593          	addi	a1,a1,1284 # 800081e8 <digits+0x1a8>
    80001cec:	15848513          	addi	a0,s1,344
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	16a080e7          	jalr	362(ra) # 80000e5a <safestrcpy>
  p->cwd = namei("/");
    80001cf8:	00006517          	auipc	a0,0x6
    80001cfc:	50050513          	addi	a0,a0,1280 # 800081f8 <digits+0x1b8>
    80001d00:	00002097          	auipc	ra,0x2
    80001d04:	0ae080e7          	jalr	174(ra) # 80003dae <namei>
    80001d08:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d0c:	4789                	li	a5,2
    80001d0e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	fae080e7          	jalr	-82(ra) # 80000cc0 <release>
}
    80001d1a:	60e2                	ld	ra,24(sp)
    80001d1c:	6442                	ld	s0,16(sp)
    80001d1e:	64a2                	ld	s1,8(sp)
    80001d20:	6105                	addi	sp,sp,32
    80001d22:	8082                	ret

0000000080001d24 <growproc>:
{
    80001d24:	1101                	addi	sp,sp,-32
    80001d26:	ec06                	sd	ra,24(sp)
    80001d28:	e822                	sd	s0,16(sp)
    80001d2a:	e426                	sd	s1,8(sp)
    80001d2c:	e04a                	sd	s2,0(sp)
    80001d2e:	1000                	addi	s0,sp,32
    80001d30:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d32:	00000097          	auipc	ra,0x0
    80001d36:	ca6080e7          	jalr	-858(ra) # 800019d8 <myproc>
    80001d3a:	892a                	mv	s2,a0
  sz = p->sz;
    80001d3c:	652c                	ld	a1,72(a0)
    80001d3e:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d42:	00904f63          	bgtz	s1,80001d60 <growproc+0x3c>
  } else if(n < 0){
    80001d46:	0204cc63          	bltz	s1,80001d7e <growproc+0x5a>
  p->sz = sz;
    80001d4a:	1602                	slli	a2,a2,0x20
    80001d4c:	9201                	srli	a2,a2,0x20
    80001d4e:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d52:	4501                	li	a0,0
}
    80001d54:	60e2                	ld	ra,24(sp)
    80001d56:	6442                	ld	s0,16(sp)
    80001d58:	64a2                	ld	s1,8(sp)
    80001d5a:	6902                	ld	s2,0(sp)
    80001d5c:	6105                	addi	sp,sp,32
    80001d5e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d60:	9e25                	addw	a2,a2,s1
    80001d62:	1602                	slli	a2,a2,0x20
    80001d64:	9201                	srli	a2,a2,0x20
    80001d66:	1582                	slli	a1,a1,0x20
    80001d68:	9181                	srli	a1,a1,0x20
    80001d6a:	6928                	ld	a0,80(a0)
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	70e080e7          	jalr	1806(ra) # 8000147a <uvmalloc>
    80001d74:	0005061b          	sext.w	a2,a0
    80001d78:	fa69                	bnez	a2,80001d4a <growproc+0x26>
      return -1;
    80001d7a:	557d                	li	a0,-1
    80001d7c:	bfe1                	j	80001d54 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d7e:	9e25                	addw	a2,a2,s1
    80001d80:	1602                	slli	a2,a2,0x20
    80001d82:	9201                	srli	a2,a2,0x20
    80001d84:	1582                	slli	a1,a1,0x20
    80001d86:	9181                	srli	a1,a1,0x20
    80001d88:	6928                	ld	a0,80(a0)
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	6a8080e7          	jalr	1704(ra) # 80001432 <uvmdealloc>
    80001d92:	0005061b          	sext.w	a2,a0
    80001d96:	bf55                	j	80001d4a <growproc+0x26>

0000000080001d98 <fork>:
{
    80001d98:	7139                	addi	sp,sp,-64
    80001d9a:	fc06                	sd	ra,56(sp)
    80001d9c:	f822                	sd	s0,48(sp)
    80001d9e:	f426                	sd	s1,40(sp)
    80001da0:	f04a                	sd	s2,32(sp)
    80001da2:	ec4e                	sd	s3,24(sp)
    80001da4:	e852                	sd	s4,16(sp)
    80001da6:	e456                	sd	s5,8(sp)
    80001da8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001daa:	00000097          	auipc	ra,0x0
    80001dae:	c2e080e7          	jalr	-978(ra) # 800019d8 <myproc>
    80001db2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001db4:	00000097          	auipc	ra,0x0
    80001db8:	e2e080e7          	jalr	-466(ra) # 80001be2 <allocproc>
    80001dbc:	c17d                	beqz	a0,80001ea2 <fork+0x10a>
    80001dbe:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dc0:	048ab603          	ld	a2,72(s5)
    80001dc4:	692c                	ld	a1,80(a0)
    80001dc6:	050ab503          	ld	a0,80(s5)
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	7fc080e7          	jalr	2044(ra) # 800015c6 <uvmcopy>
    80001dd2:	04054a63          	bltz	a0,80001e26 <fork+0x8e>
  np->sz = p->sz;
    80001dd6:	048ab783          	ld	a5,72(s5)
    80001dda:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001dde:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001de2:	058ab683          	ld	a3,88(s5)
    80001de6:	87b6                	mv	a5,a3
    80001de8:	058a3703          	ld	a4,88(s4)
    80001dec:	12068693          	addi	a3,a3,288
    80001df0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001df4:	6788                	ld	a0,8(a5)
    80001df6:	6b8c                	ld	a1,16(a5)
    80001df8:	6f90                	ld	a2,24(a5)
    80001dfa:	01073023          	sd	a6,0(a4)
    80001dfe:	e708                	sd	a0,8(a4)
    80001e00:	eb0c                	sd	a1,16(a4)
    80001e02:	ef10                	sd	a2,24(a4)
    80001e04:	02078793          	addi	a5,a5,32
    80001e08:	02070713          	addi	a4,a4,32
    80001e0c:	fed792e3          	bne	a5,a3,80001df0 <fork+0x58>
  np->trapframe->a0 = 0;
    80001e10:	058a3783          	ld	a5,88(s4)
    80001e14:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e18:	0d0a8493          	addi	s1,s5,208
    80001e1c:	0d0a0913          	addi	s2,s4,208
    80001e20:	150a8993          	addi	s3,s5,336
    80001e24:	a00d                	j	80001e46 <fork+0xae>
    freeproc(np);
    80001e26:	8552                	mv	a0,s4
    80001e28:	00000097          	auipc	ra,0x0
    80001e2c:	d62080e7          	jalr	-670(ra) # 80001b8a <freeproc>
    release(&np->lock);
    80001e30:	8552                	mv	a0,s4
    80001e32:	fffff097          	auipc	ra,0xfffff
    80001e36:	e8e080e7          	jalr	-370(ra) # 80000cc0 <release>
    return -1;
    80001e3a:	54fd                	li	s1,-1
    80001e3c:	a889                	j	80001e8e <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001e3e:	04a1                	addi	s1,s1,8
    80001e40:	0921                	addi	s2,s2,8
    80001e42:	01348b63          	beq	s1,s3,80001e58 <fork+0xc0>
    if(p->ofile[i])
    80001e46:	6088                	ld	a0,0(s1)
    80001e48:	d97d                	beqz	a0,80001e3e <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e4a:	00002097          	auipc	ra,0x2
    80001e4e:	5f0080e7          	jalr	1520(ra) # 8000443a <filedup>
    80001e52:	00a93023          	sd	a0,0(s2)
    80001e56:	b7e5                	j	80001e3e <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001e58:	150ab503          	ld	a0,336(s5)
    80001e5c:	00001097          	auipc	ra,0x1
    80001e60:	764080e7          	jalr	1892(ra) # 800035c0 <idup>
    80001e64:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e68:	4641                	li	a2,16
    80001e6a:	158a8593          	addi	a1,s5,344
    80001e6e:	158a0513          	addi	a0,s4,344
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	fe8080e7          	jalr	-24(ra) # 80000e5a <safestrcpy>
  pid = np->pid;
    80001e7a:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001e7e:	4789                	li	a5,2
    80001e80:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e84:	8552                	mv	a0,s4
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	e3a080e7          	jalr	-454(ra) # 80000cc0 <release>
}
    80001e8e:	8526                	mv	a0,s1
    80001e90:	70e2                	ld	ra,56(sp)
    80001e92:	7442                	ld	s0,48(sp)
    80001e94:	74a2                	ld	s1,40(sp)
    80001e96:	7902                	ld	s2,32(sp)
    80001e98:	69e2                	ld	s3,24(sp)
    80001e9a:	6a42                	ld	s4,16(sp)
    80001e9c:	6aa2                	ld	s5,8(sp)
    80001e9e:	6121                	addi	sp,sp,64
    80001ea0:	8082                	ret
    return -1;
    80001ea2:	54fd                	li	s1,-1
    80001ea4:	b7ed                	j	80001e8e <fork+0xf6>

0000000080001ea6 <reparent>:
{
    80001ea6:	7179                	addi	sp,sp,-48
    80001ea8:	f406                	sd	ra,40(sp)
    80001eaa:	f022                	sd	s0,32(sp)
    80001eac:	ec26                	sd	s1,24(sp)
    80001eae:	e84a                	sd	s2,16(sp)
    80001eb0:	e44e                	sd	s3,8(sp)
    80001eb2:	e052                	sd	s4,0(sp)
    80001eb4:	1800                	addi	s0,sp,48
    80001eb6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001eb8:	00010497          	auipc	s1,0x10
    80001ebc:	eb048493          	addi	s1,s1,-336 # 80011d68 <proc>
      pp->parent = initproc;
    80001ec0:	00007a17          	auipc	s4,0x7
    80001ec4:	158a0a13          	addi	s4,s4,344 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ec8:	00016997          	auipc	s3,0x16
    80001ecc:	8a098993          	addi	s3,s3,-1888 # 80017768 <tickslock>
    80001ed0:	a029                	j	80001eda <reparent+0x34>
    80001ed2:	16848493          	addi	s1,s1,360
    80001ed6:	03348363          	beq	s1,s3,80001efc <reparent+0x56>
    if(pp->parent == p){
    80001eda:	709c                	ld	a5,32(s1)
    80001edc:	ff279be3          	bne	a5,s2,80001ed2 <reparent+0x2c>
      acquire(&pp->lock);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	fffff097          	auipc	ra,0xfffff
    80001ee6:	d2a080e7          	jalr	-726(ra) # 80000c0c <acquire>
      pp->parent = initproc;
    80001eea:	000a3783          	ld	a5,0(s4)
    80001eee:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	fffff097          	auipc	ra,0xfffff
    80001ef6:	dce080e7          	jalr	-562(ra) # 80000cc0 <release>
    80001efa:	bfe1                	j	80001ed2 <reparent+0x2c>
}
    80001efc:	70a2                	ld	ra,40(sp)
    80001efe:	7402                	ld	s0,32(sp)
    80001f00:	64e2                	ld	s1,24(sp)
    80001f02:	6942                	ld	s2,16(sp)
    80001f04:	69a2                	ld	s3,8(sp)
    80001f06:	6a02                	ld	s4,0(sp)
    80001f08:	6145                	addi	sp,sp,48
    80001f0a:	8082                	ret

0000000080001f0c <scheduler>:
{
    80001f0c:	715d                	addi	sp,sp,-80
    80001f0e:	e486                	sd	ra,72(sp)
    80001f10:	e0a2                	sd	s0,64(sp)
    80001f12:	fc26                	sd	s1,56(sp)
    80001f14:	f84a                	sd	s2,48(sp)
    80001f16:	f44e                	sd	s3,40(sp)
    80001f18:	f052                	sd	s4,32(sp)
    80001f1a:	ec56                	sd	s5,24(sp)
    80001f1c:	e85a                	sd	s6,16(sp)
    80001f1e:	e45e                	sd	s7,8(sp)
    80001f20:	e062                	sd	s8,0(sp)
    80001f22:	0880                	addi	s0,sp,80
    80001f24:	8792                	mv	a5,tp
  int id = r_tp();
    80001f26:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f28:	00779b13          	slli	s6,a5,0x7
    80001f2c:	00010717          	auipc	a4,0x10
    80001f30:	a2470713          	addi	a4,a4,-1500 # 80011950 <pid_lock>
    80001f34:	975a                	add	a4,a4,s6
    80001f36:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f3a:	00010717          	auipc	a4,0x10
    80001f3e:	a3670713          	addi	a4,a4,-1482 # 80011970 <cpus+0x8>
    80001f42:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f44:	4c0d                	li	s8,3
        c->proc = p;
    80001f46:	079e                	slli	a5,a5,0x7
    80001f48:	00010a17          	auipc	s4,0x10
    80001f4c:	a08a0a13          	addi	s4,s4,-1528 # 80011950 <pid_lock>
    80001f50:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f52:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f54:	00016997          	auipc	s3,0x16
    80001f58:	81498993          	addi	s3,s3,-2028 # 80017768 <tickslock>
    80001f5c:	a899                	j	80001fb2 <scheduler+0xa6>
      release(&p->lock);
    80001f5e:	8526                	mv	a0,s1
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	d60080e7          	jalr	-672(ra) # 80000cc0 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f68:	16848493          	addi	s1,s1,360
    80001f6c:	03348963          	beq	s1,s3,80001f9e <scheduler+0x92>
      acquire(&p->lock);
    80001f70:	8526                	mv	a0,s1
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	c9a080e7          	jalr	-870(ra) # 80000c0c <acquire>
      if(p->state == RUNNABLE) {
    80001f7a:	4c9c                	lw	a5,24(s1)
    80001f7c:	ff2791e3          	bne	a5,s2,80001f5e <scheduler+0x52>
        p->state = RUNNING;
    80001f80:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f84:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80001f88:	06048593          	addi	a1,s1,96
    80001f8c:	855a                	mv	a0,s6
    80001f8e:	00000097          	auipc	ra,0x0
    80001f92:	60e080e7          	jalr	1550(ra) # 8000259c <swtch>
        c->proc = 0;
    80001f96:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001f9a:	8ade                	mv	s5,s7
    80001f9c:	b7c9                	j	80001f5e <scheduler+0x52>
    if(found == 0) {
    80001f9e:	000a9a63          	bnez	s5,80001fb2 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001faa:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001fae:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fb2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fb6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fba:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001fbe:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc0:	00010497          	auipc	s1,0x10
    80001fc4:	da848493          	addi	s1,s1,-600 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80001fc8:	4909                	li	s2,2
    80001fca:	b75d                	j	80001f70 <scheduler+0x64>

0000000080001fcc <sched>:
{
    80001fcc:	7179                	addi	sp,sp,-48
    80001fce:	f406                	sd	ra,40(sp)
    80001fd0:	f022                	sd	s0,32(sp)
    80001fd2:	ec26                	sd	s1,24(sp)
    80001fd4:	e84a                	sd	s2,16(sp)
    80001fd6:	e44e                	sd	s3,8(sp)
    80001fd8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fda:	00000097          	auipc	ra,0x0
    80001fde:	9fe080e7          	jalr	-1538(ra) # 800019d8 <myproc>
    80001fe2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	bae080e7          	jalr	-1106(ra) # 80000b92 <holding>
    80001fec:	c93d                	beqz	a0,80002062 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fee:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ff0:	2781                	sext.w	a5,a5
    80001ff2:	079e                	slli	a5,a5,0x7
    80001ff4:	00010717          	auipc	a4,0x10
    80001ff8:	95c70713          	addi	a4,a4,-1700 # 80011950 <pid_lock>
    80001ffc:	97ba                	add	a5,a5,a4
    80001ffe:	0907a703          	lw	a4,144(a5)
    80002002:	4785                	li	a5,1
    80002004:	06f71763          	bne	a4,a5,80002072 <sched+0xa6>
  if(p->state == RUNNING)
    80002008:	4c98                	lw	a4,24(s1)
    8000200a:	478d                	li	a5,3
    8000200c:	06f70b63          	beq	a4,a5,80002082 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002010:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002014:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002016:	efb5                	bnez	a5,80002092 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002018:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000201a:	00010917          	auipc	s2,0x10
    8000201e:	93690913          	addi	s2,s2,-1738 # 80011950 <pid_lock>
    80002022:	2781                	sext.w	a5,a5
    80002024:	079e                	slli	a5,a5,0x7
    80002026:	97ca                	add	a5,a5,s2
    80002028:	0947a983          	lw	s3,148(a5)
    8000202c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000202e:	2781                	sext.w	a5,a5
    80002030:	079e                	slli	a5,a5,0x7
    80002032:	00010597          	auipc	a1,0x10
    80002036:	93e58593          	addi	a1,a1,-1730 # 80011970 <cpus+0x8>
    8000203a:	95be                	add	a1,a1,a5
    8000203c:	06048513          	addi	a0,s1,96
    80002040:	00000097          	auipc	ra,0x0
    80002044:	55c080e7          	jalr	1372(ra) # 8000259c <swtch>
    80002048:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000204a:	2781                	sext.w	a5,a5
    8000204c:	079e                	slli	a5,a5,0x7
    8000204e:	97ca                	add	a5,a5,s2
    80002050:	0937aa23          	sw	s3,148(a5)
}
    80002054:	70a2                	ld	ra,40(sp)
    80002056:	7402                	ld	s0,32(sp)
    80002058:	64e2                	ld	s1,24(sp)
    8000205a:	6942                	ld	s2,16(sp)
    8000205c:	69a2                	ld	s3,8(sp)
    8000205e:	6145                	addi	sp,sp,48
    80002060:	8082                	ret
    panic("sched p->lock");
    80002062:	00006517          	auipc	a0,0x6
    80002066:	19e50513          	addi	a0,a0,414 # 80008200 <digits+0x1c0>
    8000206a:	ffffe097          	auipc	ra,0xffffe
    8000206e:	4e6080e7          	jalr	1254(ra) # 80000550 <panic>
    panic("sched locks");
    80002072:	00006517          	auipc	a0,0x6
    80002076:	19e50513          	addi	a0,a0,414 # 80008210 <digits+0x1d0>
    8000207a:	ffffe097          	auipc	ra,0xffffe
    8000207e:	4d6080e7          	jalr	1238(ra) # 80000550 <panic>
    panic("sched running");
    80002082:	00006517          	auipc	a0,0x6
    80002086:	19e50513          	addi	a0,a0,414 # 80008220 <digits+0x1e0>
    8000208a:	ffffe097          	auipc	ra,0xffffe
    8000208e:	4c6080e7          	jalr	1222(ra) # 80000550 <panic>
    panic("sched interruptible");
    80002092:	00006517          	auipc	a0,0x6
    80002096:	19e50513          	addi	a0,a0,414 # 80008230 <digits+0x1f0>
    8000209a:	ffffe097          	auipc	ra,0xffffe
    8000209e:	4b6080e7          	jalr	1206(ra) # 80000550 <panic>

00000000800020a2 <exit>:
{
    800020a2:	7179                	addi	sp,sp,-48
    800020a4:	f406                	sd	ra,40(sp)
    800020a6:	f022                	sd	s0,32(sp)
    800020a8:	ec26                	sd	s1,24(sp)
    800020aa:	e84a                	sd	s2,16(sp)
    800020ac:	e44e                	sd	s3,8(sp)
    800020ae:	e052                	sd	s4,0(sp)
    800020b0:	1800                	addi	s0,sp,48
    800020b2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020b4:	00000097          	auipc	ra,0x0
    800020b8:	924080e7          	jalr	-1756(ra) # 800019d8 <myproc>
    800020bc:	89aa                	mv	s3,a0
  if(p == initproc)
    800020be:	00007797          	auipc	a5,0x7
    800020c2:	f5a7b783          	ld	a5,-166(a5) # 80009018 <initproc>
    800020c6:	0d050493          	addi	s1,a0,208
    800020ca:	15050913          	addi	s2,a0,336
    800020ce:	02a79363          	bne	a5,a0,800020f4 <exit+0x52>
    panic("init exiting");
    800020d2:	00006517          	auipc	a0,0x6
    800020d6:	17650513          	addi	a0,a0,374 # 80008248 <digits+0x208>
    800020da:	ffffe097          	auipc	ra,0xffffe
    800020de:	476080e7          	jalr	1142(ra) # 80000550 <panic>
      fileclose(f);
    800020e2:	00002097          	auipc	ra,0x2
    800020e6:	3aa080e7          	jalr	938(ra) # 8000448c <fileclose>
      p->ofile[fd] = 0;
    800020ea:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800020ee:	04a1                	addi	s1,s1,8
    800020f0:	01248563          	beq	s1,s2,800020fa <exit+0x58>
    if(p->ofile[fd]){
    800020f4:	6088                	ld	a0,0(s1)
    800020f6:	f575                	bnez	a0,800020e2 <exit+0x40>
    800020f8:	bfdd                	j	800020ee <exit+0x4c>
  begin_op();
    800020fa:	00002097          	auipc	ra,0x2
    800020fe:	ec0080e7          	jalr	-320(ra) # 80003fba <begin_op>
  iput(p->cwd);
    80002102:	1509b503          	ld	a0,336(s3)
    80002106:	00001097          	auipc	ra,0x1
    8000210a:	6b2080e7          	jalr	1714(ra) # 800037b8 <iput>
  end_op();
    8000210e:	00002097          	auipc	ra,0x2
    80002112:	f2c080e7          	jalr	-212(ra) # 8000403a <end_op>
  p->cwd = 0;
    80002116:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000211a:	00007497          	auipc	s1,0x7
    8000211e:	efe48493          	addi	s1,s1,-258 # 80009018 <initproc>
    80002122:	6088                	ld	a0,0(s1)
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	ae8080e7          	jalr	-1304(ra) # 80000c0c <acquire>
  wakeup1(initproc);
    8000212c:	6088                	ld	a0,0(s1)
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	76a080e7          	jalr	1898(ra) # 80001898 <wakeup1>
  release(&initproc->lock);
    80002136:	6088                	ld	a0,0(s1)
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	b88080e7          	jalr	-1144(ra) # 80000cc0 <release>
  acquire(&p->lock);
    80002140:	854e                	mv	a0,s3
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	aca080e7          	jalr	-1334(ra) # 80000c0c <acquire>
  struct proc *original_parent = p->parent;
    8000214a:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    8000214e:	854e                	mv	a0,s3
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	b70080e7          	jalr	-1168(ra) # 80000cc0 <release>
  acquire(&original_parent->lock);
    80002158:	8526                	mv	a0,s1
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	ab2080e7          	jalr	-1358(ra) # 80000c0c <acquire>
  acquire(&p->lock);
    80002162:	854e                	mv	a0,s3
    80002164:	fffff097          	auipc	ra,0xfffff
    80002168:	aa8080e7          	jalr	-1368(ra) # 80000c0c <acquire>
  reparent(p);
    8000216c:	854e                	mv	a0,s3
    8000216e:	00000097          	auipc	ra,0x0
    80002172:	d38080e7          	jalr	-712(ra) # 80001ea6 <reparent>
  wakeup1(original_parent);
    80002176:	8526                	mv	a0,s1
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	720080e7          	jalr	1824(ra) # 80001898 <wakeup1>
  p->xstate = status;
    80002180:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002184:	4791                	li	a5,4
    80002186:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000218a:	8526                	mv	a0,s1
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	b34080e7          	jalr	-1228(ra) # 80000cc0 <release>
  sched();
    80002194:	00000097          	auipc	ra,0x0
    80002198:	e38080e7          	jalr	-456(ra) # 80001fcc <sched>
  panic("zombie exit");
    8000219c:	00006517          	auipc	a0,0x6
    800021a0:	0bc50513          	addi	a0,a0,188 # 80008258 <digits+0x218>
    800021a4:	ffffe097          	auipc	ra,0xffffe
    800021a8:	3ac080e7          	jalr	940(ra) # 80000550 <panic>

00000000800021ac <yield>:
{
    800021ac:	1101                	addi	sp,sp,-32
    800021ae:	ec06                	sd	ra,24(sp)
    800021b0:	e822                	sd	s0,16(sp)
    800021b2:	e426                	sd	s1,8(sp)
    800021b4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021b6:	00000097          	auipc	ra,0x0
    800021ba:	822080e7          	jalr	-2014(ra) # 800019d8 <myproc>
    800021be:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	a4c080e7          	jalr	-1460(ra) # 80000c0c <acquire>
  p->state = RUNNABLE;
    800021c8:	4789                	li	a5,2
    800021ca:	cc9c                	sw	a5,24(s1)
  sched();
    800021cc:	00000097          	auipc	ra,0x0
    800021d0:	e00080e7          	jalr	-512(ra) # 80001fcc <sched>
  release(&p->lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	aea080e7          	jalr	-1302(ra) # 80000cc0 <release>
}
    800021de:	60e2                	ld	ra,24(sp)
    800021e0:	6442                	ld	s0,16(sp)
    800021e2:	64a2                	ld	s1,8(sp)
    800021e4:	6105                	addi	sp,sp,32
    800021e6:	8082                	ret

00000000800021e8 <sleep>:
{
    800021e8:	7179                	addi	sp,sp,-48
    800021ea:	f406                	sd	ra,40(sp)
    800021ec:	f022                	sd	s0,32(sp)
    800021ee:	ec26                	sd	s1,24(sp)
    800021f0:	e84a                	sd	s2,16(sp)
    800021f2:	e44e                	sd	s3,8(sp)
    800021f4:	1800                	addi	s0,sp,48
    800021f6:	89aa                	mv	s3,a0
    800021f8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	7de080e7          	jalr	2014(ra) # 800019d8 <myproc>
    80002202:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002204:	05250663          	beq	a0,s2,80002250 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	a04080e7          	jalr	-1532(ra) # 80000c0c <acquire>
    release(lk);
    80002210:	854a                	mv	a0,s2
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	aae080e7          	jalr	-1362(ra) # 80000cc0 <release>
  p->chan = chan;
    8000221a:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000221e:	4785                	li	a5,1
    80002220:	cc9c                	sw	a5,24(s1)
  sched();
    80002222:	00000097          	auipc	ra,0x0
    80002226:	daa080e7          	jalr	-598(ra) # 80001fcc <sched>
  p->chan = 0;
    8000222a:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	a90080e7          	jalr	-1392(ra) # 80000cc0 <release>
    acquire(lk);
    80002238:	854a                	mv	a0,s2
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	9d2080e7          	jalr	-1582(ra) # 80000c0c <acquire>
}
    80002242:	70a2                	ld	ra,40(sp)
    80002244:	7402                	ld	s0,32(sp)
    80002246:	64e2                	ld	s1,24(sp)
    80002248:	6942                	ld	s2,16(sp)
    8000224a:	69a2                	ld	s3,8(sp)
    8000224c:	6145                	addi	sp,sp,48
    8000224e:	8082                	ret
  p->chan = chan;
    80002250:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002254:	4785                	li	a5,1
    80002256:	cd1c                	sw	a5,24(a0)
  sched();
    80002258:	00000097          	auipc	ra,0x0
    8000225c:	d74080e7          	jalr	-652(ra) # 80001fcc <sched>
  p->chan = 0;
    80002260:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002264:	bff9                	j	80002242 <sleep+0x5a>

0000000080002266 <wait>:
{
    80002266:	715d                	addi	sp,sp,-80
    80002268:	e486                	sd	ra,72(sp)
    8000226a:	e0a2                	sd	s0,64(sp)
    8000226c:	fc26                	sd	s1,56(sp)
    8000226e:	f84a                	sd	s2,48(sp)
    80002270:	f44e                	sd	s3,40(sp)
    80002272:	f052                	sd	s4,32(sp)
    80002274:	ec56                	sd	s5,24(sp)
    80002276:	e85a                	sd	s6,16(sp)
    80002278:	e45e                	sd	s7,8(sp)
    8000227a:	0880                	addi	s0,sp,80
    8000227c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	75a080e7          	jalr	1882(ra) # 800019d8 <myproc>
    80002286:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	984080e7          	jalr	-1660(ra) # 80000c0c <acquire>
    havekids = 0;
    80002290:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002292:	4a11                	li	s4,4
        havekids = 1;
    80002294:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002296:	00015997          	auipc	s3,0x15
    8000229a:	4d298993          	addi	s3,s3,1234 # 80017768 <tickslock>
    havekids = 0;
    8000229e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022a0:	00010497          	auipc	s1,0x10
    800022a4:	ac848493          	addi	s1,s1,-1336 # 80011d68 <proc>
    800022a8:	a08d                	j	8000230a <wait+0xa4>
          pid = np->pid;
    800022aa:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022ae:	000b0e63          	beqz	s6,800022ca <wait+0x64>
    800022b2:	4691                	li	a3,4
    800022b4:	03448613          	addi	a2,s1,52
    800022b8:	85da                	mv	a1,s6
    800022ba:	05093503          	ld	a0,80(s2)
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	40c080e7          	jalr	1036(ra) # 800016ca <copyout>
    800022c6:	02054263          	bltz	a0,800022ea <wait+0x84>
          freeproc(np);
    800022ca:	8526                	mv	a0,s1
    800022cc:	00000097          	auipc	ra,0x0
    800022d0:	8be080e7          	jalr	-1858(ra) # 80001b8a <freeproc>
          release(&np->lock);
    800022d4:	8526                	mv	a0,s1
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	9ea080e7          	jalr	-1558(ra) # 80000cc0 <release>
          release(&p->lock);
    800022de:	854a                	mv	a0,s2
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	9e0080e7          	jalr	-1568(ra) # 80000cc0 <release>
          return pid;
    800022e8:	a8a9                	j	80002342 <wait+0xdc>
            release(&np->lock);
    800022ea:	8526                	mv	a0,s1
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	9d4080e7          	jalr	-1580(ra) # 80000cc0 <release>
            release(&p->lock);
    800022f4:	854a                	mv	a0,s2
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	9ca080e7          	jalr	-1590(ra) # 80000cc0 <release>
            return -1;
    800022fe:	59fd                	li	s3,-1
    80002300:	a089                	j	80002342 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002302:	16848493          	addi	s1,s1,360
    80002306:	03348463          	beq	s1,s3,8000232e <wait+0xc8>
      if(np->parent == p){
    8000230a:	709c                	ld	a5,32(s1)
    8000230c:	ff279be3          	bne	a5,s2,80002302 <wait+0x9c>
        acquire(&np->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	8fa080e7          	jalr	-1798(ra) # 80000c0c <acquire>
        if(np->state == ZOMBIE){
    8000231a:	4c9c                	lw	a5,24(s1)
    8000231c:	f94787e3          	beq	a5,s4,800022aa <wait+0x44>
        release(&np->lock);
    80002320:	8526                	mv	a0,s1
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	99e080e7          	jalr	-1634(ra) # 80000cc0 <release>
        havekids = 1;
    8000232a:	8756                	mv	a4,s5
    8000232c:	bfd9                	j	80002302 <wait+0x9c>
    if(!havekids || p->killed){
    8000232e:	c701                	beqz	a4,80002336 <wait+0xd0>
    80002330:	03092783          	lw	a5,48(s2)
    80002334:	c39d                	beqz	a5,8000235a <wait+0xf4>
      release(&p->lock);
    80002336:	854a                	mv	a0,s2
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	988080e7          	jalr	-1656(ra) # 80000cc0 <release>
      return -1;
    80002340:	59fd                	li	s3,-1
}
    80002342:	854e                	mv	a0,s3
    80002344:	60a6                	ld	ra,72(sp)
    80002346:	6406                	ld	s0,64(sp)
    80002348:	74e2                	ld	s1,56(sp)
    8000234a:	7942                	ld	s2,48(sp)
    8000234c:	79a2                	ld	s3,40(sp)
    8000234e:	7a02                	ld	s4,32(sp)
    80002350:	6ae2                	ld	s5,24(sp)
    80002352:	6b42                	ld	s6,16(sp)
    80002354:	6ba2                	ld	s7,8(sp)
    80002356:	6161                	addi	sp,sp,80
    80002358:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000235a:	85ca                	mv	a1,s2
    8000235c:	854a                	mv	a0,s2
    8000235e:	00000097          	auipc	ra,0x0
    80002362:	e8a080e7          	jalr	-374(ra) # 800021e8 <sleep>
    havekids = 0;
    80002366:	bf25                	j	8000229e <wait+0x38>

0000000080002368 <wakeup>:
{
    80002368:	7139                	addi	sp,sp,-64
    8000236a:	fc06                	sd	ra,56(sp)
    8000236c:	f822                	sd	s0,48(sp)
    8000236e:	f426                	sd	s1,40(sp)
    80002370:	f04a                	sd	s2,32(sp)
    80002372:	ec4e                	sd	s3,24(sp)
    80002374:	e852                	sd	s4,16(sp)
    80002376:	e456                	sd	s5,8(sp)
    80002378:	0080                	addi	s0,sp,64
    8000237a:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000237c:	00010497          	auipc	s1,0x10
    80002380:	9ec48493          	addi	s1,s1,-1556 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002384:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002386:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002388:	00015917          	auipc	s2,0x15
    8000238c:	3e090913          	addi	s2,s2,992 # 80017768 <tickslock>
    80002390:	a811                	j	800023a4 <wakeup+0x3c>
    release(&p->lock);
    80002392:	8526                	mv	a0,s1
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	92c080e7          	jalr	-1748(ra) # 80000cc0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000239c:	16848493          	addi	s1,s1,360
    800023a0:	03248063          	beq	s1,s2,800023c0 <wakeup+0x58>
    acquire(&p->lock);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	866080e7          	jalr	-1946(ra) # 80000c0c <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023ae:	4c9c                	lw	a5,24(s1)
    800023b0:	ff3791e3          	bne	a5,s3,80002392 <wakeup+0x2a>
    800023b4:	749c                	ld	a5,40(s1)
    800023b6:	fd479ee3          	bne	a5,s4,80002392 <wakeup+0x2a>
      p->state = RUNNABLE;
    800023ba:	0154ac23          	sw	s5,24(s1)
    800023be:	bfd1                	j	80002392 <wakeup+0x2a>
}
    800023c0:	70e2                	ld	ra,56(sp)
    800023c2:	7442                	ld	s0,48(sp)
    800023c4:	74a2                	ld	s1,40(sp)
    800023c6:	7902                	ld	s2,32(sp)
    800023c8:	69e2                	ld	s3,24(sp)
    800023ca:	6a42                	ld	s4,16(sp)
    800023cc:	6aa2                	ld	s5,8(sp)
    800023ce:	6121                	addi	sp,sp,64
    800023d0:	8082                	ret

00000000800023d2 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023d2:	7179                	addi	sp,sp,-48
    800023d4:	f406                	sd	ra,40(sp)
    800023d6:	f022                	sd	s0,32(sp)
    800023d8:	ec26                	sd	s1,24(sp)
    800023da:	e84a                	sd	s2,16(sp)
    800023dc:	e44e                	sd	s3,8(sp)
    800023de:	1800                	addi	s0,sp,48
    800023e0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023e2:	00010497          	auipc	s1,0x10
    800023e6:	98648493          	addi	s1,s1,-1658 # 80011d68 <proc>
    800023ea:	00015997          	auipc	s3,0x15
    800023ee:	37e98993          	addi	s3,s3,894 # 80017768 <tickslock>
    acquire(&p->lock);
    800023f2:	8526                	mv	a0,s1
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	818080e7          	jalr	-2024(ra) # 80000c0c <acquire>
    if(p->pid == pid){
    800023fc:	5c9c                	lw	a5,56(s1)
    800023fe:	01278d63          	beq	a5,s2,80002418 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002402:	8526                	mv	a0,s1
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	8bc080e7          	jalr	-1860(ra) # 80000cc0 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000240c:	16848493          	addi	s1,s1,360
    80002410:	ff3491e3          	bne	s1,s3,800023f2 <kill+0x20>
  }
  return -1;
    80002414:	557d                	li	a0,-1
    80002416:	a821                	j	8000242e <kill+0x5c>
      p->killed = 1;
    80002418:	4785                	li	a5,1
    8000241a:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000241c:	4c98                	lw	a4,24(s1)
    8000241e:	00f70f63          	beq	a4,a5,8000243c <kill+0x6a>
      release(&p->lock);
    80002422:	8526                	mv	a0,s1
    80002424:	fffff097          	auipc	ra,0xfffff
    80002428:	89c080e7          	jalr	-1892(ra) # 80000cc0 <release>
      return 0;
    8000242c:	4501                	li	a0,0
}
    8000242e:	70a2                	ld	ra,40(sp)
    80002430:	7402                	ld	s0,32(sp)
    80002432:	64e2                	ld	s1,24(sp)
    80002434:	6942                	ld	s2,16(sp)
    80002436:	69a2                	ld	s3,8(sp)
    80002438:	6145                	addi	sp,sp,48
    8000243a:	8082                	ret
        p->state = RUNNABLE;
    8000243c:	4789                	li	a5,2
    8000243e:	cc9c                	sw	a5,24(s1)
    80002440:	b7cd                	j	80002422 <kill+0x50>

0000000080002442 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002442:	7179                	addi	sp,sp,-48
    80002444:	f406                	sd	ra,40(sp)
    80002446:	f022                	sd	s0,32(sp)
    80002448:	ec26                	sd	s1,24(sp)
    8000244a:	e84a                	sd	s2,16(sp)
    8000244c:	e44e                	sd	s3,8(sp)
    8000244e:	e052                	sd	s4,0(sp)
    80002450:	1800                	addi	s0,sp,48
    80002452:	84aa                	mv	s1,a0
    80002454:	892e                	mv	s2,a1
    80002456:	89b2                	mv	s3,a2
    80002458:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	57e080e7          	jalr	1406(ra) # 800019d8 <myproc>
  if(user_dst){
    80002462:	c08d                	beqz	s1,80002484 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002464:	86d2                	mv	a3,s4
    80002466:	864e                	mv	a2,s3
    80002468:	85ca                	mv	a1,s2
    8000246a:	6928                	ld	a0,80(a0)
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	25e080e7          	jalr	606(ra) # 800016ca <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002474:	70a2                	ld	ra,40(sp)
    80002476:	7402                	ld	s0,32(sp)
    80002478:	64e2                	ld	s1,24(sp)
    8000247a:	6942                	ld	s2,16(sp)
    8000247c:	69a2                	ld	s3,8(sp)
    8000247e:	6a02                	ld	s4,0(sp)
    80002480:	6145                	addi	sp,sp,48
    80002482:	8082                	ret
    memmove((char *)dst, src, len);
    80002484:	000a061b          	sext.w	a2,s4
    80002488:	85ce                	mv	a1,s3
    8000248a:	854a                	mv	a0,s2
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	8d8080e7          	jalr	-1832(ra) # 80000d64 <memmove>
    return 0;
    80002494:	8526                	mv	a0,s1
    80002496:	bff9                	j	80002474 <either_copyout+0x32>

0000000080002498 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002498:	7179                	addi	sp,sp,-48
    8000249a:	f406                	sd	ra,40(sp)
    8000249c:	f022                	sd	s0,32(sp)
    8000249e:	ec26                	sd	s1,24(sp)
    800024a0:	e84a                	sd	s2,16(sp)
    800024a2:	e44e                	sd	s3,8(sp)
    800024a4:	e052                	sd	s4,0(sp)
    800024a6:	1800                	addi	s0,sp,48
    800024a8:	892a                	mv	s2,a0
    800024aa:	84ae                	mv	s1,a1
    800024ac:	89b2                	mv	s3,a2
    800024ae:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	528080e7          	jalr	1320(ra) # 800019d8 <myproc>
  if(user_src){
    800024b8:	c08d                	beqz	s1,800024da <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024ba:	86d2                	mv	a3,s4
    800024bc:	864e                	mv	a2,s3
    800024be:	85ca                	mv	a1,s2
    800024c0:	6928                	ld	a0,80(a0)
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	294080e7          	jalr	660(ra) # 80001756 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ca:	70a2                	ld	ra,40(sp)
    800024cc:	7402                	ld	s0,32(sp)
    800024ce:	64e2                	ld	s1,24(sp)
    800024d0:	6942                	ld	s2,16(sp)
    800024d2:	69a2                	ld	s3,8(sp)
    800024d4:	6a02                	ld	s4,0(sp)
    800024d6:	6145                	addi	sp,sp,48
    800024d8:	8082                	ret
    memmove(dst, (char*)src, len);
    800024da:	000a061b          	sext.w	a2,s4
    800024de:	85ce                	mv	a1,s3
    800024e0:	854a                	mv	a0,s2
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	882080e7          	jalr	-1918(ra) # 80000d64 <memmove>
    return 0;
    800024ea:	8526                	mv	a0,s1
    800024ec:	bff9                	j	800024ca <either_copyin+0x32>

00000000800024ee <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024ee:	715d                	addi	sp,sp,-80
    800024f0:	e486                	sd	ra,72(sp)
    800024f2:	e0a2                	sd	s0,64(sp)
    800024f4:	fc26                	sd	s1,56(sp)
    800024f6:	f84a                	sd	s2,48(sp)
    800024f8:	f44e                	sd	s3,40(sp)
    800024fa:	f052                	sd	s4,32(sp)
    800024fc:	ec56                	sd	s5,24(sp)
    800024fe:	e85a                	sd	s6,16(sp)
    80002500:	e45e                	sd	s7,8(sp)
    80002502:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002504:	00006517          	auipc	a0,0x6
    80002508:	bc450513          	addi	a0,a0,-1084 # 800080c8 <digits+0x88>
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	08e080e7          	jalr	142(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002514:	00010497          	auipc	s1,0x10
    80002518:	9ac48493          	addi	s1,s1,-1620 # 80011ec0 <proc+0x158>
    8000251c:	00015917          	auipc	s2,0x15
    80002520:	3a490913          	addi	s2,s2,932 # 800178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002524:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002526:	00006997          	auipc	s3,0x6
    8000252a:	d4298993          	addi	s3,s3,-702 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    8000252e:	00006a97          	auipc	s5,0x6
    80002532:	d42a8a93          	addi	s5,s5,-702 # 80008270 <digits+0x230>
    printf("\n");
    80002536:	00006a17          	auipc	s4,0x6
    8000253a:	b92a0a13          	addi	s4,s4,-1134 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000253e:	00006b97          	auipc	s7,0x6
    80002542:	d6ab8b93          	addi	s7,s7,-662 # 800082a8 <states.0>
    80002546:	a00d                	j	80002568 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002548:	ee06a583          	lw	a1,-288(a3)
    8000254c:	8556                	mv	a0,s5
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	04c080e7          	jalr	76(ra) # 8000059a <printf>
    printf("\n");
    80002556:	8552                	mv	a0,s4
    80002558:	ffffe097          	auipc	ra,0xffffe
    8000255c:	042080e7          	jalr	66(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002560:	16848493          	addi	s1,s1,360
    80002564:	03248163          	beq	s1,s2,80002586 <procdump+0x98>
    if(p->state == UNUSED)
    80002568:	86a6                	mv	a3,s1
    8000256a:	ec04a783          	lw	a5,-320(s1)
    8000256e:	dbed                	beqz	a5,80002560 <procdump+0x72>
      state = "???";
    80002570:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002572:	fcfb6be3          	bltu	s6,a5,80002548 <procdump+0x5a>
    80002576:	1782                	slli	a5,a5,0x20
    80002578:	9381                	srli	a5,a5,0x20
    8000257a:	078e                	slli	a5,a5,0x3
    8000257c:	97de                	add	a5,a5,s7
    8000257e:	6390                	ld	a2,0(a5)
    80002580:	f661                	bnez	a2,80002548 <procdump+0x5a>
      state = "???";
    80002582:	864e                	mv	a2,s3
    80002584:	b7d1                	j	80002548 <procdump+0x5a>
  }
}
    80002586:	60a6                	ld	ra,72(sp)
    80002588:	6406                	ld	s0,64(sp)
    8000258a:	74e2                	ld	s1,56(sp)
    8000258c:	7942                	ld	s2,48(sp)
    8000258e:	79a2                	ld	s3,40(sp)
    80002590:	7a02                	ld	s4,32(sp)
    80002592:	6ae2                	ld	s5,24(sp)
    80002594:	6b42                	ld	s6,16(sp)
    80002596:	6ba2                	ld	s7,8(sp)
    80002598:	6161                	addi	sp,sp,80
    8000259a:	8082                	ret

000000008000259c <swtch>:
    8000259c:	00153023          	sd	ra,0(a0)
    800025a0:	00253423          	sd	sp,8(a0)
    800025a4:	e900                	sd	s0,16(a0)
    800025a6:	ed04                	sd	s1,24(a0)
    800025a8:	03253023          	sd	s2,32(a0)
    800025ac:	03353423          	sd	s3,40(a0)
    800025b0:	03453823          	sd	s4,48(a0)
    800025b4:	03553c23          	sd	s5,56(a0)
    800025b8:	05653023          	sd	s6,64(a0)
    800025bc:	05753423          	sd	s7,72(a0)
    800025c0:	05853823          	sd	s8,80(a0)
    800025c4:	05953c23          	sd	s9,88(a0)
    800025c8:	07a53023          	sd	s10,96(a0)
    800025cc:	07b53423          	sd	s11,104(a0)
    800025d0:	0005b083          	ld	ra,0(a1)
    800025d4:	0085b103          	ld	sp,8(a1)
    800025d8:	6980                	ld	s0,16(a1)
    800025da:	6d84                	ld	s1,24(a1)
    800025dc:	0205b903          	ld	s2,32(a1)
    800025e0:	0285b983          	ld	s3,40(a1)
    800025e4:	0305ba03          	ld	s4,48(a1)
    800025e8:	0385ba83          	ld	s5,56(a1)
    800025ec:	0405bb03          	ld	s6,64(a1)
    800025f0:	0485bb83          	ld	s7,72(a1)
    800025f4:	0505bc03          	ld	s8,80(a1)
    800025f8:	0585bc83          	ld	s9,88(a1)
    800025fc:	0605bd03          	ld	s10,96(a1)
    80002600:	0685bd83          	ld	s11,104(a1)
    80002604:	8082                	ret

0000000080002606 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002606:	1141                	addi	sp,sp,-16
    80002608:	e406                	sd	ra,8(sp)
    8000260a:	e022                	sd	s0,0(sp)
    8000260c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000260e:	00006597          	auipc	a1,0x6
    80002612:	cc258593          	addi	a1,a1,-830 # 800082d0 <states.0+0x28>
    80002616:	00015517          	auipc	a0,0x15
    8000261a:	15250513          	addi	a0,a0,338 # 80017768 <tickslock>
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	55e080e7          	jalr	1374(ra) # 80000b7c <initlock>
}
    80002626:	60a2                	ld	ra,8(sp)
    80002628:	6402                	ld	s0,0(sp)
    8000262a:	0141                	addi	sp,sp,16
    8000262c:	8082                	ret

000000008000262e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000262e:	1141                	addi	sp,sp,-16
    80002630:	e422                	sd	s0,8(sp)
    80002632:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002634:	00003797          	auipc	a5,0x3
    80002638:	4bc78793          	addi	a5,a5,1212 # 80005af0 <kernelvec>
    8000263c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002640:	6422                	ld	s0,8(sp)
    80002642:	0141                	addi	sp,sp,16
    80002644:	8082                	ret

0000000080002646 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002646:	1141                	addi	sp,sp,-16
    80002648:	e406                	sd	ra,8(sp)
    8000264a:	e022                	sd	s0,0(sp)
    8000264c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000264e:	fffff097          	auipc	ra,0xfffff
    80002652:	38a080e7          	jalr	906(ra) # 800019d8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002656:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000265a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000265c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002660:	00005617          	auipc	a2,0x5
    80002664:	9a060613          	addi	a2,a2,-1632 # 80007000 <_trampoline>
    80002668:	00005697          	auipc	a3,0x5
    8000266c:	99868693          	addi	a3,a3,-1640 # 80007000 <_trampoline>
    80002670:	8e91                	sub	a3,a3,a2
    80002672:	040007b7          	lui	a5,0x4000
    80002676:	17fd                	addi	a5,a5,-1
    80002678:	07b2                	slli	a5,a5,0xc
    8000267a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000267c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002680:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002682:	180026f3          	csrr	a3,satp
    80002686:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002688:	6d38                	ld	a4,88(a0)
    8000268a:	6134                	ld	a3,64(a0)
    8000268c:	6585                	lui	a1,0x1
    8000268e:	96ae                	add	a3,a3,a1
    80002690:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002692:	6d38                	ld	a4,88(a0)
    80002694:	00000697          	auipc	a3,0x0
    80002698:	13868693          	addi	a3,a3,312 # 800027cc <usertrap>
    8000269c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000269e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026a0:	8692                	mv	a3,tp
    800026a2:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a4:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026a8:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ac:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026b0:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026b4:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026b6:	6f18                	ld	a4,24(a4)
    800026b8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026bc:	692c                	ld	a1,80(a0)
    800026be:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800026c0:	00005717          	auipc	a4,0x5
    800026c4:	9d070713          	addi	a4,a4,-1584 # 80007090 <userret>
    800026c8:	8f11                	sub	a4,a4,a2
    800026ca:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800026cc:	577d                	li	a4,-1
    800026ce:	177e                	slli	a4,a4,0x3f
    800026d0:	8dd9                	or	a1,a1,a4
    800026d2:	02000537          	lui	a0,0x2000
    800026d6:	157d                	addi	a0,a0,-1
    800026d8:	0536                	slli	a0,a0,0xd
    800026da:	9782                	jalr	a5
}
    800026dc:	60a2                	ld	ra,8(sp)
    800026de:	6402                	ld	s0,0(sp)
    800026e0:	0141                	addi	sp,sp,16
    800026e2:	8082                	ret

00000000800026e4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026e4:	1101                	addi	sp,sp,-32
    800026e6:	ec06                	sd	ra,24(sp)
    800026e8:	e822                	sd	s0,16(sp)
    800026ea:	e426                	sd	s1,8(sp)
    800026ec:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800026ee:	00015497          	auipc	s1,0x15
    800026f2:	07a48493          	addi	s1,s1,122 # 80017768 <tickslock>
    800026f6:	8526                	mv	a0,s1
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	514080e7          	jalr	1300(ra) # 80000c0c <acquire>
  ticks++;
    80002700:	00007517          	auipc	a0,0x7
    80002704:	92050513          	addi	a0,a0,-1760 # 80009020 <ticks>
    80002708:	411c                	lw	a5,0(a0)
    8000270a:	2785                	addiw	a5,a5,1
    8000270c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000270e:	00000097          	auipc	ra,0x0
    80002712:	c5a080e7          	jalr	-934(ra) # 80002368 <wakeup>
  release(&tickslock);
    80002716:	8526                	mv	a0,s1
    80002718:	ffffe097          	auipc	ra,0xffffe
    8000271c:	5a8080e7          	jalr	1448(ra) # 80000cc0 <release>
}
    80002720:	60e2                	ld	ra,24(sp)
    80002722:	6442                	ld	s0,16(sp)
    80002724:	64a2                	ld	s1,8(sp)
    80002726:	6105                	addi	sp,sp,32
    80002728:	8082                	ret

000000008000272a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000272a:	1101                	addi	sp,sp,-32
    8000272c:	ec06                	sd	ra,24(sp)
    8000272e:	e822                	sd	s0,16(sp)
    80002730:	e426                	sd	s1,8(sp)
    80002732:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002734:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002738:	00074d63          	bltz	a4,80002752 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000273c:	57fd                	li	a5,-1
    8000273e:	17fe                	slli	a5,a5,0x3f
    80002740:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002742:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002744:	06f70363          	beq	a4,a5,800027aa <devintr+0x80>
  }
}
    80002748:	60e2                	ld	ra,24(sp)
    8000274a:	6442                	ld	s0,16(sp)
    8000274c:	64a2                	ld	s1,8(sp)
    8000274e:	6105                	addi	sp,sp,32
    80002750:	8082                	ret
     (scause & 0xff) == 9){
    80002752:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002756:	46a5                	li	a3,9
    80002758:	fed792e3          	bne	a5,a3,8000273c <devintr+0x12>
    int irq = plic_claim();
    8000275c:	00003097          	auipc	ra,0x3
    80002760:	4b8080e7          	jalr	1208(ra) # 80005c14 <plic_claim>
    80002764:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002766:	47a9                	li	a5,10
    80002768:	02f50763          	beq	a0,a5,80002796 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000276c:	4785                	li	a5,1
    8000276e:	02f50963          	beq	a0,a5,800027a0 <devintr+0x76>
    return 1;
    80002772:	4505                	li	a0,1
    } else if(irq){
    80002774:	d8f1                	beqz	s1,80002748 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002776:	85a6                	mv	a1,s1
    80002778:	00006517          	auipc	a0,0x6
    8000277c:	b6050513          	addi	a0,a0,-1184 # 800082d8 <states.0+0x30>
    80002780:	ffffe097          	auipc	ra,0xffffe
    80002784:	e1a080e7          	jalr	-486(ra) # 8000059a <printf>
      plic_complete(irq);
    80002788:	8526                	mv	a0,s1
    8000278a:	00003097          	auipc	ra,0x3
    8000278e:	4ae080e7          	jalr	1198(ra) # 80005c38 <plic_complete>
    return 1;
    80002792:	4505                	li	a0,1
    80002794:	bf55                	j	80002748 <devintr+0x1e>
      uartintr();
    80002796:	ffffe097          	auipc	ra,0xffffe
    8000279a:	23a080e7          	jalr	570(ra) # 800009d0 <uartintr>
    8000279e:	b7ed                	j	80002788 <devintr+0x5e>
      virtio_disk_intr();
    800027a0:	00004097          	auipc	ra,0x4
    800027a4:	912080e7          	jalr	-1774(ra) # 800060b2 <virtio_disk_intr>
    800027a8:	b7c5                	j	80002788 <devintr+0x5e>
    if(cpuid() == 0){
    800027aa:	fffff097          	auipc	ra,0xfffff
    800027ae:	202080e7          	jalr	514(ra) # 800019ac <cpuid>
    800027b2:	c901                	beqz	a0,800027c2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027b4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027b8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027ba:	14479073          	csrw	sip,a5
    return 2;
    800027be:	4509                	li	a0,2
    800027c0:	b761                	j	80002748 <devintr+0x1e>
      clockintr();
    800027c2:	00000097          	auipc	ra,0x0
    800027c6:	f22080e7          	jalr	-222(ra) # 800026e4 <clockintr>
    800027ca:	b7ed                	j	800027b4 <devintr+0x8a>

00000000800027cc <usertrap>:
{
    800027cc:	1101                	addi	sp,sp,-32
    800027ce:	ec06                	sd	ra,24(sp)
    800027d0:	e822                	sd	s0,16(sp)
    800027d2:	e426                	sd	s1,8(sp)
    800027d4:	e04a                	sd	s2,0(sp)
    800027d6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027d8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027dc:	1007f793          	andi	a5,a5,256
    800027e0:	e3ad                	bnez	a5,80002842 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027e2:	00003797          	auipc	a5,0x3
    800027e6:	30e78793          	addi	a5,a5,782 # 80005af0 <kernelvec>
    800027ea:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027ee:	fffff097          	auipc	ra,0xfffff
    800027f2:	1ea080e7          	jalr	490(ra) # 800019d8 <myproc>
    800027f6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027f8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027fa:	14102773          	csrr	a4,sepc
    800027fe:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002800:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002804:	47a1                	li	a5,8
    80002806:	04f71c63          	bne	a4,a5,8000285e <usertrap+0x92>
    if(p->killed)
    8000280a:	591c                	lw	a5,48(a0)
    8000280c:	e3b9                	bnez	a5,80002852 <usertrap+0x86>
    p->trapframe->epc += 4;
    8000280e:	6cb8                	ld	a4,88(s1)
    80002810:	6f1c                	ld	a5,24(a4)
    80002812:	0791                	addi	a5,a5,4
    80002814:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002816:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000281a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000281e:	10079073          	csrw	sstatus,a5
    syscall();
    80002822:	00000097          	auipc	ra,0x0
    80002826:	2e0080e7          	jalr	736(ra) # 80002b02 <syscall>
  if(p->killed)
    8000282a:	589c                	lw	a5,48(s1)
    8000282c:	ebc1                	bnez	a5,800028bc <usertrap+0xf0>
  usertrapret();
    8000282e:	00000097          	auipc	ra,0x0
    80002832:	e18080e7          	jalr	-488(ra) # 80002646 <usertrapret>
}
    80002836:	60e2                	ld	ra,24(sp)
    80002838:	6442                	ld	s0,16(sp)
    8000283a:	64a2                	ld	s1,8(sp)
    8000283c:	6902                	ld	s2,0(sp)
    8000283e:	6105                	addi	sp,sp,32
    80002840:	8082                	ret
    panic("usertrap: not from user mode");
    80002842:	00006517          	auipc	a0,0x6
    80002846:	ab650513          	addi	a0,a0,-1354 # 800082f8 <states.0+0x50>
    8000284a:	ffffe097          	auipc	ra,0xffffe
    8000284e:	d06080e7          	jalr	-762(ra) # 80000550 <panic>
      exit(-1);
    80002852:	557d                	li	a0,-1
    80002854:	00000097          	auipc	ra,0x0
    80002858:	84e080e7          	jalr	-1970(ra) # 800020a2 <exit>
    8000285c:	bf4d                	j	8000280e <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    8000285e:	00000097          	auipc	ra,0x0
    80002862:	ecc080e7          	jalr	-308(ra) # 8000272a <devintr>
    80002866:	892a                	mv	s2,a0
    80002868:	c501                	beqz	a0,80002870 <usertrap+0xa4>
  if(p->killed)
    8000286a:	589c                	lw	a5,48(s1)
    8000286c:	c3a1                	beqz	a5,800028ac <usertrap+0xe0>
    8000286e:	a815                	j	800028a2 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002870:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002874:	5c90                	lw	a2,56(s1)
    80002876:	00006517          	auipc	a0,0x6
    8000287a:	aa250513          	addi	a0,a0,-1374 # 80008318 <states.0+0x70>
    8000287e:	ffffe097          	auipc	ra,0xffffe
    80002882:	d1c080e7          	jalr	-740(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002886:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000288a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000288e:	00006517          	auipc	a0,0x6
    80002892:	aba50513          	addi	a0,a0,-1350 # 80008348 <states.0+0xa0>
    80002896:	ffffe097          	auipc	ra,0xffffe
    8000289a:	d04080e7          	jalr	-764(ra) # 8000059a <printf>
    p->killed = 1;
    8000289e:	4785                	li	a5,1
    800028a0:	d89c                	sw	a5,48(s1)
    exit(-1);
    800028a2:	557d                	li	a0,-1
    800028a4:	fffff097          	auipc	ra,0xfffff
    800028a8:	7fe080e7          	jalr	2046(ra) # 800020a2 <exit>
  if(which_dev == 2)
    800028ac:	4789                	li	a5,2
    800028ae:	f8f910e3          	bne	s2,a5,8000282e <usertrap+0x62>
    yield();
    800028b2:	00000097          	auipc	ra,0x0
    800028b6:	8fa080e7          	jalr	-1798(ra) # 800021ac <yield>
    800028ba:	bf95                	j	8000282e <usertrap+0x62>
  int which_dev = 0;
    800028bc:	4901                	li	s2,0
    800028be:	b7d5                	j	800028a2 <usertrap+0xd6>

00000000800028c0 <kerneltrap>:
{
    800028c0:	7179                	addi	sp,sp,-48
    800028c2:	f406                	sd	ra,40(sp)
    800028c4:	f022                	sd	s0,32(sp)
    800028c6:	ec26                	sd	s1,24(sp)
    800028c8:	e84a                	sd	s2,16(sp)
    800028ca:	e44e                	sd	s3,8(sp)
    800028cc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ce:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028da:	1004f793          	andi	a5,s1,256
    800028de:	cb85                	beqz	a5,8000290e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028e0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028e4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028e6:	ef85                	bnez	a5,8000291e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800028e8:	00000097          	auipc	ra,0x0
    800028ec:	e42080e7          	jalr	-446(ra) # 8000272a <devintr>
    800028f0:	cd1d                	beqz	a0,8000292e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800028f2:	4789                	li	a5,2
    800028f4:	06f50a63          	beq	a0,a5,80002968 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028f8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028fc:	10049073          	csrw	sstatus,s1
}
    80002900:	70a2                	ld	ra,40(sp)
    80002902:	7402                	ld	s0,32(sp)
    80002904:	64e2                	ld	s1,24(sp)
    80002906:	6942                	ld	s2,16(sp)
    80002908:	69a2                	ld	s3,8(sp)
    8000290a:	6145                	addi	sp,sp,48
    8000290c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000290e:	00006517          	auipc	a0,0x6
    80002912:	a5a50513          	addi	a0,a0,-1446 # 80008368 <states.0+0xc0>
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	c3a080e7          	jalr	-966(ra) # 80000550 <panic>
    panic("kerneltrap: interrupts enabled");
    8000291e:	00006517          	auipc	a0,0x6
    80002922:	a7250513          	addi	a0,a0,-1422 # 80008390 <states.0+0xe8>
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	c2a080e7          	jalr	-982(ra) # 80000550 <panic>
    printf("scause %p\n", scause);
    8000292e:	85ce                	mv	a1,s3
    80002930:	00006517          	auipc	a0,0x6
    80002934:	a8050513          	addi	a0,a0,-1408 # 800083b0 <states.0+0x108>
    80002938:	ffffe097          	auipc	ra,0xffffe
    8000293c:	c62080e7          	jalr	-926(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002940:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002944:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002948:	00006517          	auipc	a0,0x6
    8000294c:	a7850513          	addi	a0,a0,-1416 # 800083c0 <states.0+0x118>
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	c4a080e7          	jalr	-950(ra) # 8000059a <printf>
    panic("kerneltrap");
    80002958:	00006517          	auipc	a0,0x6
    8000295c:	a8050513          	addi	a0,a0,-1408 # 800083d8 <states.0+0x130>
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	bf0080e7          	jalr	-1040(ra) # 80000550 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002968:	fffff097          	auipc	ra,0xfffff
    8000296c:	070080e7          	jalr	112(ra) # 800019d8 <myproc>
    80002970:	d541                	beqz	a0,800028f8 <kerneltrap+0x38>
    80002972:	fffff097          	auipc	ra,0xfffff
    80002976:	066080e7          	jalr	102(ra) # 800019d8 <myproc>
    8000297a:	4d18                	lw	a4,24(a0)
    8000297c:	478d                	li	a5,3
    8000297e:	f6f71de3          	bne	a4,a5,800028f8 <kerneltrap+0x38>
    yield();
    80002982:	00000097          	auipc	ra,0x0
    80002986:	82a080e7          	jalr	-2006(ra) # 800021ac <yield>
    8000298a:	b7bd                	j	800028f8 <kerneltrap+0x38>

000000008000298c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000298c:	1101                	addi	sp,sp,-32
    8000298e:	ec06                	sd	ra,24(sp)
    80002990:	e822                	sd	s0,16(sp)
    80002992:	e426                	sd	s1,8(sp)
    80002994:	1000                	addi	s0,sp,32
    80002996:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002998:	fffff097          	auipc	ra,0xfffff
    8000299c:	040080e7          	jalr	64(ra) # 800019d8 <myproc>
  switch (n) {
    800029a0:	4795                	li	a5,5
    800029a2:	0497e163          	bltu	a5,s1,800029e4 <argraw+0x58>
    800029a6:	048a                	slli	s1,s1,0x2
    800029a8:	00006717          	auipc	a4,0x6
    800029ac:	a6870713          	addi	a4,a4,-1432 # 80008410 <states.0+0x168>
    800029b0:	94ba                	add	s1,s1,a4
    800029b2:	409c                	lw	a5,0(s1)
    800029b4:	97ba                	add	a5,a5,a4
    800029b6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029b8:	6d3c                	ld	a5,88(a0)
    800029ba:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029bc:	60e2                	ld	ra,24(sp)
    800029be:	6442                	ld	s0,16(sp)
    800029c0:	64a2                	ld	s1,8(sp)
    800029c2:	6105                	addi	sp,sp,32
    800029c4:	8082                	ret
    return p->trapframe->a1;
    800029c6:	6d3c                	ld	a5,88(a0)
    800029c8:	7fa8                	ld	a0,120(a5)
    800029ca:	bfcd                	j	800029bc <argraw+0x30>
    return p->trapframe->a2;
    800029cc:	6d3c                	ld	a5,88(a0)
    800029ce:	63c8                	ld	a0,128(a5)
    800029d0:	b7f5                	j	800029bc <argraw+0x30>
    return p->trapframe->a3;
    800029d2:	6d3c                	ld	a5,88(a0)
    800029d4:	67c8                	ld	a0,136(a5)
    800029d6:	b7dd                	j	800029bc <argraw+0x30>
    return p->trapframe->a4;
    800029d8:	6d3c                	ld	a5,88(a0)
    800029da:	6bc8                	ld	a0,144(a5)
    800029dc:	b7c5                	j	800029bc <argraw+0x30>
    return p->trapframe->a5;
    800029de:	6d3c                	ld	a5,88(a0)
    800029e0:	6fc8                	ld	a0,152(a5)
    800029e2:	bfe9                	j	800029bc <argraw+0x30>
  panic("argraw");
    800029e4:	00006517          	auipc	a0,0x6
    800029e8:	a0450513          	addi	a0,a0,-1532 # 800083e8 <states.0+0x140>
    800029ec:	ffffe097          	auipc	ra,0xffffe
    800029f0:	b64080e7          	jalr	-1180(ra) # 80000550 <panic>

00000000800029f4 <fetchaddr>:
{
    800029f4:	1101                	addi	sp,sp,-32
    800029f6:	ec06                	sd	ra,24(sp)
    800029f8:	e822                	sd	s0,16(sp)
    800029fa:	e426                	sd	s1,8(sp)
    800029fc:	e04a                	sd	s2,0(sp)
    800029fe:	1000                	addi	s0,sp,32
    80002a00:	84aa                	mv	s1,a0
    80002a02:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a04:	fffff097          	auipc	ra,0xfffff
    80002a08:	fd4080e7          	jalr	-44(ra) # 800019d8 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a0c:	653c                	ld	a5,72(a0)
    80002a0e:	02f4f863          	bgeu	s1,a5,80002a3e <fetchaddr+0x4a>
    80002a12:	00848713          	addi	a4,s1,8
    80002a16:	02e7e663          	bltu	a5,a4,80002a42 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a1a:	46a1                	li	a3,8
    80002a1c:	8626                	mv	a2,s1
    80002a1e:	85ca                	mv	a1,s2
    80002a20:	6928                	ld	a0,80(a0)
    80002a22:	fffff097          	auipc	ra,0xfffff
    80002a26:	d34080e7          	jalr	-716(ra) # 80001756 <copyin>
    80002a2a:	00a03533          	snez	a0,a0
    80002a2e:	40a00533          	neg	a0,a0
}
    80002a32:	60e2                	ld	ra,24(sp)
    80002a34:	6442                	ld	s0,16(sp)
    80002a36:	64a2                	ld	s1,8(sp)
    80002a38:	6902                	ld	s2,0(sp)
    80002a3a:	6105                	addi	sp,sp,32
    80002a3c:	8082                	ret
    return -1;
    80002a3e:	557d                	li	a0,-1
    80002a40:	bfcd                	j	80002a32 <fetchaddr+0x3e>
    80002a42:	557d                	li	a0,-1
    80002a44:	b7fd                	j	80002a32 <fetchaddr+0x3e>

0000000080002a46 <fetchstr>:
{
    80002a46:	7179                	addi	sp,sp,-48
    80002a48:	f406                	sd	ra,40(sp)
    80002a4a:	f022                	sd	s0,32(sp)
    80002a4c:	ec26                	sd	s1,24(sp)
    80002a4e:	e84a                	sd	s2,16(sp)
    80002a50:	e44e                	sd	s3,8(sp)
    80002a52:	1800                	addi	s0,sp,48
    80002a54:	892a                	mv	s2,a0
    80002a56:	84ae                	mv	s1,a1
    80002a58:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	f7e080e7          	jalr	-130(ra) # 800019d8 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002a62:	86ce                	mv	a3,s3
    80002a64:	864a                	mv	a2,s2
    80002a66:	85a6                	mv	a1,s1
    80002a68:	6928                	ld	a0,80(a0)
    80002a6a:	fffff097          	auipc	ra,0xfffff
    80002a6e:	d7a080e7          	jalr	-646(ra) # 800017e4 <copyinstr>
  if(err < 0)
    80002a72:	00054763          	bltz	a0,80002a80 <fetchstr+0x3a>
  return strlen(buf);
    80002a76:	8526                	mv	a0,s1
    80002a78:	ffffe097          	auipc	ra,0xffffe
    80002a7c:	414080e7          	jalr	1044(ra) # 80000e8c <strlen>
}
    80002a80:	70a2                	ld	ra,40(sp)
    80002a82:	7402                	ld	s0,32(sp)
    80002a84:	64e2                	ld	s1,24(sp)
    80002a86:	6942                	ld	s2,16(sp)
    80002a88:	69a2                	ld	s3,8(sp)
    80002a8a:	6145                	addi	sp,sp,48
    80002a8c:	8082                	ret

0000000080002a8e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002a8e:	1101                	addi	sp,sp,-32
    80002a90:	ec06                	sd	ra,24(sp)
    80002a92:	e822                	sd	s0,16(sp)
    80002a94:	e426                	sd	s1,8(sp)
    80002a96:	1000                	addi	s0,sp,32
    80002a98:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a9a:	00000097          	auipc	ra,0x0
    80002a9e:	ef2080e7          	jalr	-270(ra) # 8000298c <argraw>
    80002aa2:	c088                	sw	a0,0(s1)
  return 0;
}
    80002aa4:	4501                	li	a0,0
    80002aa6:	60e2                	ld	ra,24(sp)
    80002aa8:	6442                	ld	s0,16(sp)
    80002aaa:	64a2                	ld	s1,8(sp)
    80002aac:	6105                	addi	sp,sp,32
    80002aae:	8082                	ret

0000000080002ab0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002ab0:	1101                	addi	sp,sp,-32
    80002ab2:	ec06                	sd	ra,24(sp)
    80002ab4:	e822                	sd	s0,16(sp)
    80002ab6:	e426                	sd	s1,8(sp)
    80002ab8:	1000                	addi	s0,sp,32
    80002aba:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002abc:	00000097          	auipc	ra,0x0
    80002ac0:	ed0080e7          	jalr	-304(ra) # 8000298c <argraw>
    80002ac4:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ac6:	4501                	li	a0,0
    80002ac8:	60e2                	ld	ra,24(sp)
    80002aca:	6442                	ld	s0,16(sp)
    80002acc:	64a2                	ld	s1,8(sp)
    80002ace:	6105                	addi	sp,sp,32
    80002ad0:	8082                	ret

0000000080002ad2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ad2:	1101                	addi	sp,sp,-32
    80002ad4:	ec06                	sd	ra,24(sp)
    80002ad6:	e822                	sd	s0,16(sp)
    80002ad8:	e426                	sd	s1,8(sp)
    80002ada:	e04a                	sd	s2,0(sp)
    80002adc:	1000                	addi	s0,sp,32
    80002ade:	84ae                	mv	s1,a1
    80002ae0:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002ae2:	00000097          	auipc	ra,0x0
    80002ae6:	eaa080e7          	jalr	-342(ra) # 8000298c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002aea:	864a                	mv	a2,s2
    80002aec:	85a6                	mv	a1,s1
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	f58080e7          	jalr	-168(ra) # 80002a46 <fetchstr>
}
    80002af6:	60e2                	ld	ra,24(sp)
    80002af8:	6442                	ld	s0,16(sp)
    80002afa:	64a2                	ld	s1,8(sp)
    80002afc:	6902                	ld	s2,0(sp)
    80002afe:	6105                	addi	sp,sp,32
    80002b00:	8082                	ret

0000000080002b02 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002b02:	1101                	addi	sp,sp,-32
    80002b04:	ec06                	sd	ra,24(sp)
    80002b06:	e822                	sd	s0,16(sp)
    80002b08:	e426                	sd	s1,8(sp)
    80002b0a:	e04a                	sd	s2,0(sp)
    80002b0c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b0e:	fffff097          	auipc	ra,0xfffff
    80002b12:	eca080e7          	jalr	-310(ra) # 800019d8 <myproc>
    80002b16:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b18:	05853903          	ld	s2,88(a0)
    80002b1c:	0a893783          	ld	a5,168(s2)
    80002b20:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b24:	37fd                	addiw	a5,a5,-1
    80002b26:	4751                	li	a4,20
    80002b28:	00f76f63          	bltu	a4,a5,80002b46 <syscall+0x44>
    80002b2c:	00369713          	slli	a4,a3,0x3
    80002b30:	00006797          	auipc	a5,0x6
    80002b34:	8f878793          	addi	a5,a5,-1800 # 80008428 <syscalls>
    80002b38:	97ba                	add	a5,a5,a4
    80002b3a:	639c                	ld	a5,0(a5)
    80002b3c:	c789                	beqz	a5,80002b46 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002b3e:	9782                	jalr	a5
    80002b40:	06a93823          	sd	a0,112(s2)
    80002b44:	a839                	j	80002b62 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b46:	15848613          	addi	a2,s1,344
    80002b4a:	5c8c                	lw	a1,56(s1)
    80002b4c:	00006517          	auipc	a0,0x6
    80002b50:	8a450513          	addi	a0,a0,-1884 # 800083f0 <states.0+0x148>
    80002b54:	ffffe097          	auipc	ra,0xffffe
    80002b58:	a46080e7          	jalr	-1466(ra) # 8000059a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b5c:	6cbc                	ld	a5,88(s1)
    80002b5e:	577d                	li	a4,-1
    80002b60:	fbb8                	sd	a4,112(a5)
  }
}
    80002b62:	60e2                	ld	ra,24(sp)
    80002b64:	6442                	ld	s0,16(sp)
    80002b66:	64a2                	ld	s1,8(sp)
    80002b68:	6902                	ld	s2,0(sp)
    80002b6a:	6105                	addi	sp,sp,32
    80002b6c:	8082                	ret

0000000080002b6e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002b6e:	1101                	addi	sp,sp,-32
    80002b70:	ec06                	sd	ra,24(sp)
    80002b72:	e822                	sd	s0,16(sp)
    80002b74:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002b76:	fec40593          	addi	a1,s0,-20
    80002b7a:	4501                	li	a0,0
    80002b7c:	00000097          	auipc	ra,0x0
    80002b80:	f12080e7          	jalr	-238(ra) # 80002a8e <argint>
    return -1;
    80002b84:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002b86:	00054963          	bltz	a0,80002b98 <sys_exit+0x2a>
  exit(n);
    80002b8a:	fec42503          	lw	a0,-20(s0)
    80002b8e:	fffff097          	auipc	ra,0xfffff
    80002b92:	514080e7          	jalr	1300(ra) # 800020a2 <exit>
  return 0;  // not reached
    80002b96:	4781                	li	a5,0
}
    80002b98:	853e                	mv	a0,a5
    80002b9a:	60e2                	ld	ra,24(sp)
    80002b9c:	6442                	ld	s0,16(sp)
    80002b9e:	6105                	addi	sp,sp,32
    80002ba0:	8082                	ret

0000000080002ba2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ba2:	1141                	addi	sp,sp,-16
    80002ba4:	e406                	sd	ra,8(sp)
    80002ba6:	e022                	sd	s0,0(sp)
    80002ba8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	e2e080e7          	jalr	-466(ra) # 800019d8 <myproc>
}
    80002bb2:	5d08                	lw	a0,56(a0)
    80002bb4:	60a2                	ld	ra,8(sp)
    80002bb6:	6402                	ld	s0,0(sp)
    80002bb8:	0141                	addi	sp,sp,16
    80002bba:	8082                	ret

0000000080002bbc <sys_fork>:

uint64
sys_fork(void)
{
    80002bbc:	1141                	addi	sp,sp,-16
    80002bbe:	e406                	sd	ra,8(sp)
    80002bc0:	e022                	sd	s0,0(sp)
    80002bc2:	0800                	addi	s0,sp,16
  return fork();
    80002bc4:	fffff097          	auipc	ra,0xfffff
    80002bc8:	1d4080e7          	jalr	468(ra) # 80001d98 <fork>
}
    80002bcc:	60a2                	ld	ra,8(sp)
    80002bce:	6402                	ld	s0,0(sp)
    80002bd0:	0141                	addi	sp,sp,16
    80002bd2:	8082                	ret

0000000080002bd4 <sys_wait>:

uint64
sys_wait(void)
{
    80002bd4:	1101                	addi	sp,sp,-32
    80002bd6:	ec06                	sd	ra,24(sp)
    80002bd8:	e822                	sd	s0,16(sp)
    80002bda:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002bdc:	fe840593          	addi	a1,s0,-24
    80002be0:	4501                	li	a0,0
    80002be2:	00000097          	auipc	ra,0x0
    80002be6:	ece080e7          	jalr	-306(ra) # 80002ab0 <argaddr>
    80002bea:	87aa                	mv	a5,a0
    return -1;
    80002bec:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002bee:	0007c863          	bltz	a5,80002bfe <sys_wait+0x2a>
  return wait(p);
    80002bf2:	fe843503          	ld	a0,-24(s0)
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	670080e7          	jalr	1648(ra) # 80002266 <wait>
}
    80002bfe:	60e2                	ld	ra,24(sp)
    80002c00:	6442                	ld	s0,16(sp)
    80002c02:	6105                	addi	sp,sp,32
    80002c04:	8082                	ret

0000000080002c06 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c06:	7179                	addi	sp,sp,-48
    80002c08:	f406                	sd	ra,40(sp)
    80002c0a:	f022                	sd	s0,32(sp)
    80002c0c:	ec26                	sd	s1,24(sp)
    80002c0e:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c10:	fdc40593          	addi	a1,s0,-36
    80002c14:	4501                	li	a0,0
    80002c16:	00000097          	auipc	ra,0x0
    80002c1a:	e78080e7          	jalr	-392(ra) # 80002a8e <argint>
    return -1;
    80002c1e:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002c20:	00054f63          	bltz	a0,80002c3e <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	db4080e7          	jalr	-588(ra) # 800019d8 <myproc>
    80002c2c:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002c2e:	fdc42503          	lw	a0,-36(s0)
    80002c32:	fffff097          	auipc	ra,0xfffff
    80002c36:	0f2080e7          	jalr	242(ra) # 80001d24 <growproc>
    80002c3a:	00054863          	bltz	a0,80002c4a <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002c3e:	8526                	mv	a0,s1
    80002c40:	70a2                	ld	ra,40(sp)
    80002c42:	7402                	ld	s0,32(sp)
    80002c44:	64e2                	ld	s1,24(sp)
    80002c46:	6145                	addi	sp,sp,48
    80002c48:	8082                	ret
    return -1;
    80002c4a:	54fd                	li	s1,-1
    80002c4c:	bfcd                	j	80002c3e <sys_sbrk+0x38>

0000000080002c4e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c4e:	7139                	addi	sp,sp,-64
    80002c50:	fc06                	sd	ra,56(sp)
    80002c52:	f822                	sd	s0,48(sp)
    80002c54:	f426                	sd	s1,40(sp)
    80002c56:	f04a                	sd	s2,32(sp)
    80002c58:	ec4e                	sd	s3,24(sp)
    80002c5a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c5c:	fcc40593          	addi	a1,s0,-52
    80002c60:	4501                	li	a0,0
    80002c62:	00000097          	auipc	ra,0x0
    80002c66:	e2c080e7          	jalr	-468(ra) # 80002a8e <argint>
    return -1;
    80002c6a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c6c:	06054563          	bltz	a0,80002cd6 <sys_sleep+0x88>
  acquire(&tickslock);
    80002c70:	00015517          	auipc	a0,0x15
    80002c74:	af850513          	addi	a0,a0,-1288 # 80017768 <tickslock>
    80002c78:	ffffe097          	auipc	ra,0xffffe
    80002c7c:	f94080e7          	jalr	-108(ra) # 80000c0c <acquire>
  ticks0 = ticks;
    80002c80:	00006917          	auipc	s2,0x6
    80002c84:	3a092903          	lw	s2,928(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002c88:	fcc42783          	lw	a5,-52(s0)
    80002c8c:	cf85                	beqz	a5,80002cc4 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c8e:	00015997          	auipc	s3,0x15
    80002c92:	ada98993          	addi	s3,s3,-1318 # 80017768 <tickslock>
    80002c96:	00006497          	auipc	s1,0x6
    80002c9a:	38a48493          	addi	s1,s1,906 # 80009020 <ticks>
    if(myproc()->killed){
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	d3a080e7          	jalr	-710(ra) # 800019d8 <myproc>
    80002ca6:	591c                	lw	a5,48(a0)
    80002ca8:	ef9d                	bnez	a5,80002ce6 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002caa:	85ce                	mv	a1,s3
    80002cac:	8526                	mv	a0,s1
    80002cae:	fffff097          	auipc	ra,0xfffff
    80002cb2:	53a080e7          	jalr	1338(ra) # 800021e8 <sleep>
  while(ticks - ticks0 < n){
    80002cb6:	409c                	lw	a5,0(s1)
    80002cb8:	412787bb          	subw	a5,a5,s2
    80002cbc:	fcc42703          	lw	a4,-52(s0)
    80002cc0:	fce7efe3          	bltu	a5,a4,80002c9e <sys_sleep+0x50>
  }
  release(&tickslock);
    80002cc4:	00015517          	auipc	a0,0x15
    80002cc8:	aa450513          	addi	a0,a0,-1372 # 80017768 <tickslock>
    80002ccc:	ffffe097          	auipc	ra,0xffffe
    80002cd0:	ff4080e7          	jalr	-12(ra) # 80000cc0 <release>
  return 0;
    80002cd4:	4781                	li	a5,0
}
    80002cd6:	853e                	mv	a0,a5
    80002cd8:	70e2                	ld	ra,56(sp)
    80002cda:	7442                	ld	s0,48(sp)
    80002cdc:	74a2                	ld	s1,40(sp)
    80002cde:	7902                	ld	s2,32(sp)
    80002ce0:	69e2                	ld	s3,24(sp)
    80002ce2:	6121                	addi	sp,sp,64
    80002ce4:	8082                	ret
      release(&tickslock);
    80002ce6:	00015517          	auipc	a0,0x15
    80002cea:	a8250513          	addi	a0,a0,-1406 # 80017768 <tickslock>
    80002cee:	ffffe097          	auipc	ra,0xffffe
    80002cf2:	fd2080e7          	jalr	-46(ra) # 80000cc0 <release>
      return -1;
    80002cf6:	57fd                	li	a5,-1
    80002cf8:	bff9                	j	80002cd6 <sys_sleep+0x88>

0000000080002cfa <sys_kill>:

uint64
sys_kill(void)
{
    80002cfa:	1101                	addi	sp,sp,-32
    80002cfc:	ec06                	sd	ra,24(sp)
    80002cfe:	e822                	sd	s0,16(sp)
    80002d00:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d02:	fec40593          	addi	a1,s0,-20
    80002d06:	4501                	li	a0,0
    80002d08:	00000097          	auipc	ra,0x0
    80002d0c:	d86080e7          	jalr	-634(ra) # 80002a8e <argint>
    80002d10:	87aa                	mv	a5,a0
    return -1;
    80002d12:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d14:	0007c863          	bltz	a5,80002d24 <sys_kill+0x2a>
  return kill(pid);
    80002d18:	fec42503          	lw	a0,-20(s0)
    80002d1c:	fffff097          	auipc	ra,0xfffff
    80002d20:	6b6080e7          	jalr	1718(ra) # 800023d2 <kill>
}
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	6105                	addi	sp,sp,32
    80002d2a:	8082                	ret

0000000080002d2c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d2c:	1101                	addi	sp,sp,-32
    80002d2e:	ec06                	sd	ra,24(sp)
    80002d30:	e822                	sd	s0,16(sp)
    80002d32:	e426                	sd	s1,8(sp)
    80002d34:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d36:	00015517          	auipc	a0,0x15
    80002d3a:	a3250513          	addi	a0,a0,-1486 # 80017768 <tickslock>
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	ece080e7          	jalr	-306(ra) # 80000c0c <acquire>
  xticks = ticks;
    80002d46:	00006497          	auipc	s1,0x6
    80002d4a:	2da4a483          	lw	s1,730(s1) # 80009020 <ticks>
  release(&tickslock);
    80002d4e:	00015517          	auipc	a0,0x15
    80002d52:	a1a50513          	addi	a0,a0,-1510 # 80017768 <tickslock>
    80002d56:	ffffe097          	auipc	ra,0xffffe
    80002d5a:	f6a080e7          	jalr	-150(ra) # 80000cc0 <release>
  return xticks;
}
    80002d5e:	02049513          	slli	a0,s1,0x20
    80002d62:	9101                	srli	a0,a0,0x20
    80002d64:	60e2                	ld	ra,24(sp)
    80002d66:	6442                	ld	s0,16(sp)
    80002d68:	64a2                	ld	s1,8(sp)
    80002d6a:	6105                	addi	sp,sp,32
    80002d6c:	8082                	ret

0000000080002d6e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d6e:	7179                	addi	sp,sp,-48
    80002d70:	f406                	sd	ra,40(sp)
    80002d72:	f022                	sd	s0,32(sp)
    80002d74:	ec26                	sd	s1,24(sp)
    80002d76:	e84a                	sd	s2,16(sp)
    80002d78:	e44e                	sd	s3,8(sp)
    80002d7a:	e052                	sd	s4,0(sp)
    80002d7c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d7e:	00005597          	auipc	a1,0x5
    80002d82:	75a58593          	addi	a1,a1,1882 # 800084d8 <syscalls+0xb0>
    80002d86:	00015517          	auipc	a0,0x15
    80002d8a:	9fa50513          	addi	a0,a0,-1542 # 80017780 <bcache>
    80002d8e:	ffffe097          	auipc	ra,0xffffe
    80002d92:	dee080e7          	jalr	-530(ra) # 80000b7c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d96:	0001d797          	auipc	a5,0x1d
    80002d9a:	9ea78793          	addi	a5,a5,-1558 # 8001f780 <bcache+0x8000>
    80002d9e:	0001d717          	auipc	a4,0x1d
    80002da2:	c4a70713          	addi	a4,a4,-950 # 8001f9e8 <bcache+0x8268>
    80002da6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002daa:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dae:	00015497          	auipc	s1,0x15
    80002db2:	9ea48493          	addi	s1,s1,-1558 # 80017798 <bcache+0x18>
    b->next = bcache.head.next;
    80002db6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002db8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dba:	00005a17          	auipc	s4,0x5
    80002dbe:	726a0a13          	addi	s4,s4,1830 # 800084e0 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002dc2:	2b893783          	ld	a5,696(s2)
    80002dc6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dc8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002dcc:	85d2                	mv	a1,s4
    80002dce:	01048513          	addi	a0,s1,16
    80002dd2:	00001097          	auipc	ra,0x1
    80002dd6:	4ac080e7          	jalr	1196(ra) # 8000427e <initsleeplock>
    bcache.head.next->prev = b;
    80002dda:	2b893783          	ld	a5,696(s2)
    80002dde:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002de0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002de4:	45848493          	addi	s1,s1,1112
    80002de8:	fd349de3          	bne	s1,s3,80002dc2 <binit+0x54>
  }
}
    80002dec:	70a2                	ld	ra,40(sp)
    80002dee:	7402                	ld	s0,32(sp)
    80002df0:	64e2                	ld	s1,24(sp)
    80002df2:	6942                	ld	s2,16(sp)
    80002df4:	69a2                	ld	s3,8(sp)
    80002df6:	6a02                	ld	s4,0(sp)
    80002df8:	6145                	addi	sp,sp,48
    80002dfa:	8082                	ret

0000000080002dfc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002dfc:	7179                	addi	sp,sp,-48
    80002dfe:	f406                	sd	ra,40(sp)
    80002e00:	f022                	sd	s0,32(sp)
    80002e02:	ec26                	sd	s1,24(sp)
    80002e04:	e84a                	sd	s2,16(sp)
    80002e06:	e44e                	sd	s3,8(sp)
    80002e08:	1800                	addi	s0,sp,48
    80002e0a:	892a                	mv	s2,a0
    80002e0c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e0e:	00015517          	auipc	a0,0x15
    80002e12:	97250513          	addi	a0,a0,-1678 # 80017780 <bcache>
    80002e16:	ffffe097          	auipc	ra,0xffffe
    80002e1a:	df6080e7          	jalr	-522(ra) # 80000c0c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e1e:	0001d497          	auipc	s1,0x1d
    80002e22:	c1a4b483          	ld	s1,-998(s1) # 8001fa38 <bcache+0x82b8>
    80002e26:	0001d797          	auipc	a5,0x1d
    80002e2a:	bc278793          	addi	a5,a5,-1086 # 8001f9e8 <bcache+0x8268>
    80002e2e:	02f48f63          	beq	s1,a5,80002e6c <bread+0x70>
    80002e32:	873e                	mv	a4,a5
    80002e34:	a021                	j	80002e3c <bread+0x40>
    80002e36:	68a4                	ld	s1,80(s1)
    80002e38:	02e48a63          	beq	s1,a4,80002e6c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e3c:	449c                	lw	a5,8(s1)
    80002e3e:	ff279ce3          	bne	a5,s2,80002e36 <bread+0x3a>
    80002e42:	44dc                	lw	a5,12(s1)
    80002e44:	ff3799e3          	bne	a5,s3,80002e36 <bread+0x3a>
      b->refcnt++;
    80002e48:	40bc                	lw	a5,64(s1)
    80002e4a:	2785                	addiw	a5,a5,1
    80002e4c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e4e:	00015517          	auipc	a0,0x15
    80002e52:	93250513          	addi	a0,a0,-1742 # 80017780 <bcache>
    80002e56:	ffffe097          	auipc	ra,0xffffe
    80002e5a:	e6a080e7          	jalr	-406(ra) # 80000cc0 <release>
      acquiresleep(&b->lock);
    80002e5e:	01048513          	addi	a0,s1,16
    80002e62:	00001097          	auipc	ra,0x1
    80002e66:	456080e7          	jalr	1110(ra) # 800042b8 <acquiresleep>
      return b;
    80002e6a:	a8b9                	j	80002ec8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e6c:	0001d497          	auipc	s1,0x1d
    80002e70:	bc44b483          	ld	s1,-1084(s1) # 8001fa30 <bcache+0x82b0>
    80002e74:	0001d797          	auipc	a5,0x1d
    80002e78:	b7478793          	addi	a5,a5,-1164 # 8001f9e8 <bcache+0x8268>
    80002e7c:	00f48863          	beq	s1,a5,80002e8c <bread+0x90>
    80002e80:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e82:	40bc                	lw	a5,64(s1)
    80002e84:	cf81                	beqz	a5,80002e9c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e86:	64a4                	ld	s1,72(s1)
    80002e88:	fee49de3          	bne	s1,a4,80002e82 <bread+0x86>
  panic("bget: no buffers");
    80002e8c:	00005517          	auipc	a0,0x5
    80002e90:	65c50513          	addi	a0,a0,1628 # 800084e8 <syscalls+0xc0>
    80002e94:	ffffd097          	auipc	ra,0xffffd
    80002e98:	6bc080e7          	jalr	1724(ra) # 80000550 <panic>
      b->dev = dev;
    80002e9c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ea0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ea4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ea8:	4785                	li	a5,1
    80002eaa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002eac:	00015517          	auipc	a0,0x15
    80002eb0:	8d450513          	addi	a0,a0,-1836 # 80017780 <bcache>
    80002eb4:	ffffe097          	auipc	ra,0xffffe
    80002eb8:	e0c080e7          	jalr	-500(ra) # 80000cc0 <release>
      acquiresleep(&b->lock);
    80002ebc:	01048513          	addi	a0,s1,16
    80002ec0:	00001097          	auipc	ra,0x1
    80002ec4:	3f8080e7          	jalr	1016(ra) # 800042b8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ec8:	409c                	lw	a5,0(s1)
    80002eca:	cb89                	beqz	a5,80002edc <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ecc:	8526                	mv	a0,s1
    80002ece:	70a2                	ld	ra,40(sp)
    80002ed0:	7402                	ld	s0,32(sp)
    80002ed2:	64e2                	ld	s1,24(sp)
    80002ed4:	6942                	ld	s2,16(sp)
    80002ed6:	69a2                	ld	s3,8(sp)
    80002ed8:	6145                	addi	sp,sp,48
    80002eda:	8082                	ret
    virtio_disk_rw(b, 0);
    80002edc:	4581                	li	a1,0
    80002ede:	8526                	mv	a0,s1
    80002ee0:	00003097          	auipc	ra,0x3
    80002ee4:	f48080e7          	jalr	-184(ra) # 80005e28 <virtio_disk_rw>
    b->valid = 1;
    80002ee8:	4785                	li	a5,1
    80002eea:	c09c                	sw	a5,0(s1)
  return b;
    80002eec:	b7c5                	j	80002ecc <bread+0xd0>

0000000080002eee <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002eee:	1101                	addi	sp,sp,-32
    80002ef0:	ec06                	sd	ra,24(sp)
    80002ef2:	e822                	sd	s0,16(sp)
    80002ef4:	e426                	sd	s1,8(sp)
    80002ef6:	1000                	addi	s0,sp,32
    80002ef8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002efa:	0541                	addi	a0,a0,16
    80002efc:	00001097          	auipc	ra,0x1
    80002f00:	456080e7          	jalr	1110(ra) # 80004352 <holdingsleep>
    80002f04:	cd01                	beqz	a0,80002f1c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f06:	4585                	li	a1,1
    80002f08:	8526                	mv	a0,s1
    80002f0a:	00003097          	auipc	ra,0x3
    80002f0e:	f1e080e7          	jalr	-226(ra) # 80005e28 <virtio_disk_rw>
}
    80002f12:	60e2                	ld	ra,24(sp)
    80002f14:	6442                	ld	s0,16(sp)
    80002f16:	64a2                	ld	s1,8(sp)
    80002f18:	6105                	addi	sp,sp,32
    80002f1a:	8082                	ret
    panic("bwrite");
    80002f1c:	00005517          	auipc	a0,0x5
    80002f20:	5e450513          	addi	a0,a0,1508 # 80008500 <syscalls+0xd8>
    80002f24:	ffffd097          	auipc	ra,0xffffd
    80002f28:	62c080e7          	jalr	1580(ra) # 80000550 <panic>

0000000080002f2c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f2c:	1101                	addi	sp,sp,-32
    80002f2e:	ec06                	sd	ra,24(sp)
    80002f30:	e822                	sd	s0,16(sp)
    80002f32:	e426                	sd	s1,8(sp)
    80002f34:	e04a                	sd	s2,0(sp)
    80002f36:	1000                	addi	s0,sp,32
    80002f38:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f3a:	01050913          	addi	s2,a0,16
    80002f3e:	854a                	mv	a0,s2
    80002f40:	00001097          	auipc	ra,0x1
    80002f44:	412080e7          	jalr	1042(ra) # 80004352 <holdingsleep>
    80002f48:	c92d                	beqz	a0,80002fba <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f4a:	854a                	mv	a0,s2
    80002f4c:	00001097          	auipc	ra,0x1
    80002f50:	3c2080e7          	jalr	962(ra) # 8000430e <releasesleep>

  acquire(&bcache.lock);
    80002f54:	00015517          	auipc	a0,0x15
    80002f58:	82c50513          	addi	a0,a0,-2004 # 80017780 <bcache>
    80002f5c:	ffffe097          	auipc	ra,0xffffe
    80002f60:	cb0080e7          	jalr	-848(ra) # 80000c0c <acquire>
  b->refcnt--;
    80002f64:	40bc                	lw	a5,64(s1)
    80002f66:	37fd                	addiw	a5,a5,-1
    80002f68:	0007871b          	sext.w	a4,a5
    80002f6c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f6e:	eb05                	bnez	a4,80002f9e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f70:	68bc                	ld	a5,80(s1)
    80002f72:	64b8                	ld	a4,72(s1)
    80002f74:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002f76:	64bc                	ld	a5,72(s1)
    80002f78:	68b8                	ld	a4,80(s1)
    80002f7a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f7c:	0001d797          	auipc	a5,0x1d
    80002f80:	80478793          	addi	a5,a5,-2044 # 8001f780 <bcache+0x8000>
    80002f84:	2b87b703          	ld	a4,696(a5)
    80002f88:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f8a:	0001d717          	auipc	a4,0x1d
    80002f8e:	a5e70713          	addi	a4,a4,-1442 # 8001f9e8 <bcache+0x8268>
    80002f92:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f94:	2b87b703          	ld	a4,696(a5)
    80002f98:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f9a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f9e:	00014517          	auipc	a0,0x14
    80002fa2:	7e250513          	addi	a0,a0,2018 # 80017780 <bcache>
    80002fa6:	ffffe097          	auipc	ra,0xffffe
    80002faa:	d1a080e7          	jalr	-742(ra) # 80000cc0 <release>
}
    80002fae:	60e2                	ld	ra,24(sp)
    80002fb0:	6442                	ld	s0,16(sp)
    80002fb2:	64a2                	ld	s1,8(sp)
    80002fb4:	6902                	ld	s2,0(sp)
    80002fb6:	6105                	addi	sp,sp,32
    80002fb8:	8082                	ret
    panic("brelse");
    80002fba:	00005517          	auipc	a0,0x5
    80002fbe:	54e50513          	addi	a0,a0,1358 # 80008508 <syscalls+0xe0>
    80002fc2:	ffffd097          	auipc	ra,0xffffd
    80002fc6:	58e080e7          	jalr	1422(ra) # 80000550 <panic>

0000000080002fca <bpin>:

void
bpin(struct buf *b) {
    80002fca:	1101                	addi	sp,sp,-32
    80002fcc:	ec06                	sd	ra,24(sp)
    80002fce:	e822                	sd	s0,16(sp)
    80002fd0:	e426                	sd	s1,8(sp)
    80002fd2:	1000                	addi	s0,sp,32
    80002fd4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fd6:	00014517          	auipc	a0,0x14
    80002fda:	7aa50513          	addi	a0,a0,1962 # 80017780 <bcache>
    80002fde:	ffffe097          	auipc	ra,0xffffe
    80002fe2:	c2e080e7          	jalr	-978(ra) # 80000c0c <acquire>
  b->refcnt++;
    80002fe6:	40bc                	lw	a5,64(s1)
    80002fe8:	2785                	addiw	a5,a5,1
    80002fea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fec:	00014517          	auipc	a0,0x14
    80002ff0:	79450513          	addi	a0,a0,1940 # 80017780 <bcache>
    80002ff4:	ffffe097          	auipc	ra,0xffffe
    80002ff8:	ccc080e7          	jalr	-820(ra) # 80000cc0 <release>
}
    80002ffc:	60e2                	ld	ra,24(sp)
    80002ffe:	6442                	ld	s0,16(sp)
    80003000:	64a2                	ld	s1,8(sp)
    80003002:	6105                	addi	sp,sp,32
    80003004:	8082                	ret

0000000080003006 <bunpin>:

void
bunpin(struct buf *b) {
    80003006:	1101                	addi	sp,sp,-32
    80003008:	ec06                	sd	ra,24(sp)
    8000300a:	e822                	sd	s0,16(sp)
    8000300c:	e426                	sd	s1,8(sp)
    8000300e:	1000                	addi	s0,sp,32
    80003010:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003012:	00014517          	auipc	a0,0x14
    80003016:	76e50513          	addi	a0,a0,1902 # 80017780 <bcache>
    8000301a:	ffffe097          	auipc	ra,0xffffe
    8000301e:	bf2080e7          	jalr	-1038(ra) # 80000c0c <acquire>
  b->refcnt--;
    80003022:	40bc                	lw	a5,64(s1)
    80003024:	37fd                	addiw	a5,a5,-1
    80003026:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003028:	00014517          	auipc	a0,0x14
    8000302c:	75850513          	addi	a0,a0,1880 # 80017780 <bcache>
    80003030:	ffffe097          	auipc	ra,0xffffe
    80003034:	c90080e7          	jalr	-880(ra) # 80000cc0 <release>
}
    80003038:	60e2                	ld	ra,24(sp)
    8000303a:	6442                	ld	s0,16(sp)
    8000303c:	64a2                	ld	s1,8(sp)
    8000303e:	6105                	addi	sp,sp,32
    80003040:	8082                	ret

0000000080003042 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003042:	1101                	addi	sp,sp,-32
    80003044:	ec06                	sd	ra,24(sp)
    80003046:	e822                	sd	s0,16(sp)
    80003048:	e426                	sd	s1,8(sp)
    8000304a:	e04a                	sd	s2,0(sp)
    8000304c:	1000                	addi	s0,sp,32
    8000304e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003050:	00d5d59b          	srliw	a1,a1,0xd
    80003054:	0001d797          	auipc	a5,0x1d
    80003058:	e087a783          	lw	a5,-504(a5) # 8001fe5c <sb+0x1c>
    8000305c:	9dbd                	addw	a1,a1,a5
    8000305e:	00000097          	auipc	ra,0x0
    80003062:	d9e080e7          	jalr	-610(ra) # 80002dfc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003066:	0074f713          	andi	a4,s1,7
    8000306a:	4785                	li	a5,1
    8000306c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003070:	14ce                	slli	s1,s1,0x33
    80003072:	90d9                	srli	s1,s1,0x36
    80003074:	00950733          	add	a4,a0,s1
    80003078:	05874703          	lbu	a4,88(a4)
    8000307c:	00e7f6b3          	and	a3,a5,a4
    80003080:	c69d                	beqz	a3,800030ae <bfree+0x6c>
    80003082:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003084:	94aa                	add	s1,s1,a0
    80003086:	fff7c793          	not	a5,a5
    8000308a:	8ff9                	and	a5,a5,a4
    8000308c:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003090:	00001097          	auipc	ra,0x1
    80003094:	100080e7          	jalr	256(ra) # 80004190 <log_write>
  brelse(bp);
    80003098:	854a                	mv	a0,s2
    8000309a:	00000097          	auipc	ra,0x0
    8000309e:	e92080e7          	jalr	-366(ra) # 80002f2c <brelse>
}
    800030a2:	60e2                	ld	ra,24(sp)
    800030a4:	6442                	ld	s0,16(sp)
    800030a6:	64a2                	ld	s1,8(sp)
    800030a8:	6902                	ld	s2,0(sp)
    800030aa:	6105                	addi	sp,sp,32
    800030ac:	8082                	ret
    panic("freeing free block");
    800030ae:	00005517          	auipc	a0,0x5
    800030b2:	46250513          	addi	a0,a0,1122 # 80008510 <syscalls+0xe8>
    800030b6:	ffffd097          	auipc	ra,0xffffd
    800030ba:	49a080e7          	jalr	1178(ra) # 80000550 <panic>

00000000800030be <balloc>:
{
    800030be:	711d                	addi	sp,sp,-96
    800030c0:	ec86                	sd	ra,88(sp)
    800030c2:	e8a2                	sd	s0,80(sp)
    800030c4:	e4a6                	sd	s1,72(sp)
    800030c6:	e0ca                	sd	s2,64(sp)
    800030c8:	fc4e                	sd	s3,56(sp)
    800030ca:	f852                	sd	s4,48(sp)
    800030cc:	f456                	sd	s5,40(sp)
    800030ce:	f05a                	sd	s6,32(sp)
    800030d0:	ec5e                	sd	s7,24(sp)
    800030d2:	e862                	sd	s8,16(sp)
    800030d4:	e466                	sd	s9,8(sp)
    800030d6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030d8:	0001d797          	auipc	a5,0x1d
    800030dc:	d6c7a783          	lw	a5,-660(a5) # 8001fe44 <sb+0x4>
    800030e0:	cbd1                	beqz	a5,80003174 <balloc+0xb6>
    800030e2:	8baa                	mv	s7,a0
    800030e4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030e6:	0001db17          	auipc	s6,0x1d
    800030ea:	d5ab0b13          	addi	s6,s6,-678 # 8001fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030ee:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800030f0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030f2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800030f4:	6c89                	lui	s9,0x2
    800030f6:	a831                	j	80003112 <balloc+0x54>
    brelse(bp);
    800030f8:	854a                	mv	a0,s2
    800030fa:	00000097          	auipc	ra,0x0
    800030fe:	e32080e7          	jalr	-462(ra) # 80002f2c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003102:	015c87bb          	addw	a5,s9,s5
    80003106:	00078a9b          	sext.w	s5,a5
    8000310a:	004b2703          	lw	a4,4(s6)
    8000310e:	06eaf363          	bgeu	s5,a4,80003174 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003112:	41fad79b          	sraiw	a5,s5,0x1f
    80003116:	0137d79b          	srliw	a5,a5,0x13
    8000311a:	015787bb          	addw	a5,a5,s5
    8000311e:	40d7d79b          	sraiw	a5,a5,0xd
    80003122:	01cb2583          	lw	a1,28(s6)
    80003126:	9dbd                	addw	a1,a1,a5
    80003128:	855e                	mv	a0,s7
    8000312a:	00000097          	auipc	ra,0x0
    8000312e:	cd2080e7          	jalr	-814(ra) # 80002dfc <bread>
    80003132:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003134:	004b2503          	lw	a0,4(s6)
    80003138:	000a849b          	sext.w	s1,s5
    8000313c:	8662                	mv	a2,s8
    8000313e:	faa4fde3          	bgeu	s1,a0,800030f8 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003142:	41f6579b          	sraiw	a5,a2,0x1f
    80003146:	01d7d69b          	srliw	a3,a5,0x1d
    8000314a:	00c6873b          	addw	a4,a3,a2
    8000314e:	00777793          	andi	a5,a4,7
    80003152:	9f95                	subw	a5,a5,a3
    80003154:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003158:	4037571b          	sraiw	a4,a4,0x3
    8000315c:	00e906b3          	add	a3,s2,a4
    80003160:	0586c683          	lbu	a3,88(a3)
    80003164:	00d7f5b3          	and	a1,a5,a3
    80003168:	cd91                	beqz	a1,80003184 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000316a:	2605                	addiw	a2,a2,1
    8000316c:	2485                	addiw	s1,s1,1
    8000316e:	fd4618e3          	bne	a2,s4,8000313e <balloc+0x80>
    80003172:	b759                	j	800030f8 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003174:	00005517          	auipc	a0,0x5
    80003178:	3b450513          	addi	a0,a0,948 # 80008528 <syscalls+0x100>
    8000317c:	ffffd097          	auipc	ra,0xffffd
    80003180:	3d4080e7          	jalr	980(ra) # 80000550 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003184:	974a                	add	a4,a4,s2
    80003186:	8fd5                	or	a5,a5,a3
    80003188:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000318c:	854a                	mv	a0,s2
    8000318e:	00001097          	auipc	ra,0x1
    80003192:	002080e7          	jalr	2(ra) # 80004190 <log_write>
        brelse(bp);
    80003196:	854a                	mv	a0,s2
    80003198:	00000097          	auipc	ra,0x0
    8000319c:	d94080e7          	jalr	-620(ra) # 80002f2c <brelse>
  bp = bread(dev, bno);
    800031a0:	85a6                	mv	a1,s1
    800031a2:	855e                	mv	a0,s7
    800031a4:	00000097          	auipc	ra,0x0
    800031a8:	c58080e7          	jalr	-936(ra) # 80002dfc <bread>
    800031ac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031ae:	40000613          	li	a2,1024
    800031b2:	4581                	li	a1,0
    800031b4:	05850513          	addi	a0,a0,88
    800031b8:	ffffe097          	auipc	ra,0xffffe
    800031bc:	b50080e7          	jalr	-1200(ra) # 80000d08 <memset>
  log_write(bp);
    800031c0:	854a                	mv	a0,s2
    800031c2:	00001097          	auipc	ra,0x1
    800031c6:	fce080e7          	jalr	-50(ra) # 80004190 <log_write>
  brelse(bp);
    800031ca:	854a                	mv	a0,s2
    800031cc:	00000097          	auipc	ra,0x0
    800031d0:	d60080e7          	jalr	-672(ra) # 80002f2c <brelse>
}
    800031d4:	8526                	mv	a0,s1
    800031d6:	60e6                	ld	ra,88(sp)
    800031d8:	6446                	ld	s0,80(sp)
    800031da:	64a6                	ld	s1,72(sp)
    800031dc:	6906                	ld	s2,64(sp)
    800031de:	79e2                	ld	s3,56(sp)
    800031e0:	7a42                	ld	s4,48(sp)
    800031e2:	7aa2                	ld	s5,40(sp)
    800031e4:	7b02                	ld	s6,32(sp)
    800031e6:	6be2                	ld	s7,24(sp)
    800031e8:	6c42                	ld	s8,16(sp)
    800031ea:	6ca2                	ld	s9,8(sp)
    800031ec:	6125                	addi	sp,sp,96
    800031ee:	8082                	ret

00000000800031f0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800031f0:	7179                	addi	sp,sp,-48
    800031f2:	f406                	sd	ra,40(sp)
    800031f4:	f022                	sd	s0,32(sp)
    800031f6:	ec26                	sd	s1,24(sp)
    800031f8:	e84a                	sd	s2,16(sp)
    800031fa:	e44e                	sd	s3,8(sp)
    800031fc:	e052                	sd	s4,0(sp)
    800031fe:	1800                	addi	s0,sp,48
    80003200:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003202:	47ad                	li	a5,11
    80003204:	04b7fe63          	bgeu	a5,a1,80003260 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003208:	ff45849b          	addiw	s1,a1,-12
    8000320c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003210:	0ff00793          	li	a5,255
    80003214:	0ae7e363          	bltu	a5,a4,800032ba <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003218:	08052583          	lw	a1,128(a0)
    8000321c:	c5ad                	beqz	a1,80003286 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000321e:	00092503          	lw	a0,0(s2)
    80003222:	00000097          	auipc	ra,0x0
    80003226:	bda080e7          	jalr	-1062(ra) # 80002dfc <bread>
    8000322a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000322c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003230:	02049593          	slli	a1,s1,0x20
    80003234:	9181                	srli	a1,a1,0x20
    80003236:	058a                	slli	a1,a1,0x2
    80003238:	00b784b3          	add	s1,a5,a1
    8000323c:	0004a983          	lw	s3,0(s1)
    80003240:	04098d63          	beqz	s3,8000329a <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003244:	8552                	mv	a0,s4
    80003246:	00000097          	auipc	ra,0x0
    8000324a:	ce6080e7          	jalr	-794(ra) # 80002f2c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000324e:	854e                	mv	a0,s3
    80003250:	70a2                	ld	ra,40(sp)
    80003252:	7402                	ld	s0,32(sp)
    80003254:	64e2                	ld	s1,24(sp)
    80003256:	6942                	ld	s2,16(sp)
    80003258:	69a2                	ld	s3,8(sp)
    8000325a:	6a02                	ld	s4,0(sp)
    8000325c:	6145                	addi	sp,sp,48
    8000325e:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003260:	02059493          	slli	s1,a1,0x20
    80003264:	9081                	srli	s1,s1,0x20
    80003266:	048a                	slli	s1,s1,0x2
    80003268:	94aa                	add	s1,s1,a0
    8000326a:	0504a983          	lw	s3,80(s1)
    8000326e:	fe0990e3          	bnez	s3,8000324e <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003272:	4108                	lw	a0,0(a0)
    80003274:	00000097          	auipc	ra,0x0
    80003278:	e4a080e7          	jalr	-438(ra) # 800030be <balloc>
    8000327c:	0005099b          	sext.w	s3,a0
    80003280:	0534a823          	sw	s3,80(s1)
    80003284:	b7e9                	j	8000324e <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003286:	4108                	lw	a0,0(a0)
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	e36080e7          	jalr	-458(ra) # 800030be <balloc>
    80003290:	0005059b          	sext.w	a1,a0
    80003294:	08b92023          	sw	a1,128(s2)
    80003298:	b759                	j	8000321e <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000329a:	00092503          	lw	a0,0(s2)
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	e20080e7          	jalr	-480(ra) # 800030be <balloc>
    800032a6:	0005099b          	sext.w	s3,a0
    800032aa:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800032ae:	8552                	mv	a0,s4
    800032b0:	00001097          	auipc	ra,0x1
    800032b4:	ee0080e7          	jalr	-288(ra) # 80004190 <log_write>
    800032b8:	b771                	j	80003244 <bmap+0x54>
  panic("bmap: out of range");
    800032ba:	00005517          	auipc	a0,0x5
    800032be:	28650513          	addi	a0,a0,646 # 80008540 <syscalls+0x118>
    800032c2:	ffffd097          	auipc	ra,0xffffd
    800032c6:	28e080e7          	jalr	654(ra) # 80000550 <panic>

00000000800032ca <iget>:
{
    800032ca:	7179                	addi	sp,sp,-48
    800032cc:	f406                	sd	ra,40(sp)
    800032ce:	f022                	sd	s0,32(sp)
    800032d0:	ec26                	sd	s1,24(sp)
    800032d2:	e84a                	sd	s2,16(sp)
    800032d4:	e44e                	sd	s3,8(sp)
    800032d6:	e052                	sd	s4,0(sp)
    800032d8:	1800                	addi	s0,sp,48
    800032da:	89aa                	mv	s3,a0
    800032dc:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800032de:	0001d517          	auipc	a0,0x1d
    800032e2:	b8250513          	addi	a0,a0,-1150 # 8001fe60 <icache>
    800032e6:	ffffe097          	auipc	ra,0xffffe
    800032ea:	926080e7          	jalr	-1754(ra) # 80000c0c <acquire>
  empty = 0;
    800032ee:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800032f0:	0001d497          	auipc	s1,0x1d
    800032f4:	b8848493          	addi	s1,s1,-1144 # 8001fe78 <icache+0x18>
    800032f8:	0001e697          	auipc	a3,0x1e
    800032fc:	61068693          	addi	a3,a3,1552 # 80021908 <log>
    80003300:	a039                	j	8000330e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003302:	02090b63          	beqz	s2,80003338 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003306:	08848493          	addi	s1,s1,136
    8000330a:	02d48a63          	beq	s1,a3,8000333e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000330e:	449c                	lw	a5,8(s1)
    80003310:	fef059e3          	blez	a5,80003302 <iget+0x38>
    80003314:	4098                	lw	a4,0(s1)
    80003316:	ff3716e3          	bne	a4,s3,80003302 <iget+0x38>
    8000331a:	40d8                	lw	a4,4(s1)
    8000331c:	ff4713e3          	bne	a4,s4,80003302 <iget+0x38>
      ip->ref++;
    80003320:	2785                	addiw	a5,a5,1
    80003322:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003324:	0001d517          	auipc	a0,0x1d
    80003328:	b3c50513          	addi	a0,a0,-1220 # 8001fe60 <icache>
    8000332c:	ffffe097          	auipc	ra,0xffffe
    80003330:	994080e7          	jalr	-1644(ra) # 80000cc0 <release>
      return ip;
    80003334:	8926                	mv	s2,s1
    80003336:	a03d                	j	80003364 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003338:	f7f9                	bnez	a5,80003306 <iget+0x3c>
    8000333a:	8926                	mv	s2,s1
    8000333c:	b7e9                	j	80003306 <iget+0x3c>
  if(empty == 0)
    8000333e:	02090c63          	beqz	s2,80003376 <iget+0xac>
  ip->dev = dev;
    80003342:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003346:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000334a:	4785                	li	a5,1
    8000334c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003350:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003354:	0001d517          	auipc	a0,0x1d
    80003358:	b0c50513          	addi	a0,a0,-1268 # 8001fe60 <icache>
    8000335c:	ffffe097          	auipc	ra,0xffffe
    80003360:	964080e7          	jalr	-1692(ra) # 80000cc0 <release>
}
    80003364:	854a                	mv	a0,s2
    80003366:	70a2                	ld	ra,40(sp)
    80003368:	7402                	ld	s0,32(sp)
    8000336a:	64e2                	ld	s1,24(sp)
    8000336c:	6942                	ld	s2,16(sp)
    8000336e:	69a2                	ld	s3,8(sp)
    80003370:	6a02                	ld	s4,0(sp)
    80003372:	6145                	addi	sp,sp,48
    80003374:	8082                	ret
    panic("iget: no inodes");
    80003376:	00005517          	auipc	a0,0x5
    8000337a:	1e250513          	addi	a0,a0,482 # 80008558 <syscalls+0x130>
    8000337e:	ffffd097          	auipc	ra,0xffffd
    80003382:	1d2080e7          	jalr	466(ra) # 80000550 <panic>

0000000080003386 <fsinit>:
fsinit(int dev) {
    80003386:	7179                	addi	sp,sp,-48
    80003388:	f406                	sd	ra,40(sp)
    8000338a:	f022                	sd	s0,32(sp)
    8000338c:	ec26                	sd	s1,24(sp)
    8000338e:	e84a                	sd	s2,16(sp)
    80003390:	e44e                	sd	s3,8(sp)
    80003392:	1800                	addi	s0,sp,48
    80003394:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003396:	4585                	li	a1,1
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	a64080e7          	jalr	-1436(ra) # 80002dfc <bread>
    800033a0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033a2:	0001d997          	auipc	s3,0x1d
    800033a6:	a9e98993          	addi	s3,s3,-1378 # 8001fe40 <sb>
    800033aa:	02000613          	li	a2,32
    800033ae:	05850593          	addi	a1,a0,88
    800033b2:	854e                	mv	a0,s3
    800033b4:	ffffe097          	auipc	ra,0xffffe
    800033b8:	9b0080e7          	jalr	-1616(ra) # 80000d64 <memmove>
  brelse(bp);
    800033bc:	8526                	mv	a0,s1
    800033be:	00000097          	auipc	ra,0x0
    800033c2:	b6e080e7          	jalr	-1170(ra) # 80002f2c <brelse>
  if(sb.magic != FSMAGIC)
    800033c6:	0009a703          	lw	a4,0(s3)
    800033ca:	102037b7          	lui	a5,0x10203
    800033ce:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800033d2:	02f71263          	bne	a4,a5,800033f6 <fsinit+0x70>
  initlog(dev, &sb);
    800033d6:	0001d597          	auipc	a1,0x1d
    800033da:	a6a58593          	addi	a1,a1,-1430 # 8001fe40 <sb>
    800033de:	854a                	mv	a0,s2
    800033e0:	00001097          	auipc	ra,0x1
    800033e4:	b38080e7          	jalr	-1224(ra) # 80003f18 <initlog>
}
    800033e8:	70a2                	ld	ra,40(sp)
    800033ea:	7402                	ld	s0,32(sp)
    800033ec:	64e2                	ld	s1,24(sp)
    800033ee:	6942                	ld	s2,16(sp)
    800033f0:	69a2                	ld	s3,8(sp)
    800033f2:	6145                	addi	sp,sp,48
    800033f4:	8082                	ret
    panic("invalid file system");
    800033f6:	00005517          	auipc	a0,0x5
    800033fa:	17250513          	addi	a0,a0,370 # 80008568 <syscalls+0x140>
    800033fe:	ffffd097          	auipc	ra,0xffffd
    80003402:	152080e7          	jalr	338(ra) # 80000550 <panic>

0000000080003406 <iinit>:
{
    80003406:	7179                	addi	sp,sp,-48
    80003408:	f406                	sd	ra,40(sp)
    8000340a:	f022                	sd	s0,32(sp)
    8000340c:	ec26                	sd	s1,24(sp)
    8000340e:	e84a                	sd	s2,16(sp)
    80003410:	e44e                	sd	s3,8(sp)
    80003412:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003414:	00005597          	auipc	a1,0x5
    80003418:	16c58593          	addi	a1,a1,364 # 80008580 <syscalls+0x158>
    8000341c:	0001d517          	auipc	a0,0x1d
    80003420:	a4450513          	addi	a0,a0,-1468 # 8001fe60 <icache>
    80003424:	ffffd097          	auipc	ra,0xffffd
    80003428:	758080e7          	jalr	1880(ra) # 80000b7c <initlock>
  for(i = 0; i < NINODE; i++) {
    8000342c:	0001d497          	auipc	s1,0x1d
    80003430:	a5c48493          	addi	s1,s1,-1444 # 8001fe88 <icache+0x28>
    80003434:	0001e997          	auipc	s3,0x1e
    80003438:	4e498993          	addi	s3,s3,1252 # 80021918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000343c:	00005917          	auipc	s2,0x5
    80003440:	14c90913          	addi	s2,s2,332 # 80008588 <syscalls+0x160>
    80003444:	85ca                	mv	a1,s2
    80003446:	8526                	mv	a0,s1
    80003448:	00001097          	auipc	ra,0x1
    8000344c:	e36080e7          	jalr	-458(ra) # 8000427e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003450:	08848493          	addi	s1,s1,136
    80003454:	ff3498e3          	bne	s1,s3,80003444 <iinit+0x3e>
}
    80003458:	70a2                	ld	ra,40(sp)
    8000345a:	7402                	ld	s0,32(sp)
    8000345c:	64e2                	ld	s1,24(sp)
    8000345e:	6942                	ld	s2,16(sp)
    80003460:	69a2                	ld	s3,8(sp)
    80003462:	6145                	addi	sp,sp,48
    80003464:	8082                	ret

0000000080003466 <ialloc>:
{
    80003466:	715d                	addi	sp,sp,-80
    80003468:	e486                	sd	ra,72(sp)
    8000346a:	e0a2                	sd	s0,64(sp)
    8000346c:	fc26                	sd	s1,56(sp)
    8000346e:	f84a                	sd	s2,48(sp)
    80003470:	f44e                	sd	s3,40(sp)
    80003472:	f052                	sd	s4,32(sp)
    80003474:	ec56                	sd	s5,24(sp)
    80003476:	e85a                	sd	s6,16(sp)
    80003478:	e45e                	sd	s7,8(sp)
    8000347a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000347c:	0001d717          	auipc	a4,0x1d
    80003480:	9d072703          	lw	a4,-1584(a4) # 8001fe4c <sb+0xc>
    80003484:	4785                	li	a5,1
    80003486:	04e7fa63          	bgeu	a5,a4,800034da <ialloc+0x74>
    8000348a:	8aaa                	mv	s5,a0
    8000348c:	8bae                	mv	s7,a1
    8000348e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003490:	0001da17          	auipc	s4,0x1d
    80003494:	9b0a0a13          	addi	s4,s4,-1616 # 8001fe40 <sb>
    80003498:	00048b1b          	sext.w	s6,s1
    8000349c:	0044d793          	srli	a5,s1,0x4
    800034a0:	018a2583          	lw	a1,24(s4)
    800034a4:	9dbd                	addw	a1,a1,a5
    800034a6:	8556                	mv	a0,s5
    800034a8:	00000097          	auipc	ra,0x0
    800034ac:	954080e7          	jalr	-1708(ra) # 80002dfc <bread>
    800034b0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034b2:	05850993          	addi	s3,a0,88
    800034b6:	00f4f793          	andi	a5,s1,15
    800034ba:	079a                	slli	a5,a5,0x6
    800034bc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034be:	00099783          	lh	a5,0(s3)
    800034c2:	c785                	beqz	a5,800034ea <ialloc+0x84>
    brelse(bp);
    800034c4:	00000097          	auipc	ra,0x0
    800034c8:	a68080e7          	jalr	-1432(ra) # 80002f2c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800034cc:	0485                	addi	s1,s1,1
    800034ce:	00ca2703          	lw	a4,12(s4)
    800034d2:	0004879b          	sext.w	a5,s1
    800034d6:	fce7e1e3          	bltu	a5,a4,80003498 <ialloc+0x32>
  panic("ialloc: no inodes");
    800034da:	00005517          	auipc	a0,0x5
    800034de:	0b650513          	addi	a0,a0,182 # 80008590 <syscalls+0x168>
    800034e2:	ffffd097          	auipc	ra,0xffffd
    800034e6:	06e080e7          	jalr	110(ra) # 80000550 <panic>
      memset(dip, 0, sizeof(*dip));
    800034ea:	04000613          	li	a2,64
    800034ee:	4581                	li	a1,0
    800034f0:	854e                	mv	a0,s3
    800034f2:	ffffe097          	auipc	ra,0xffffe
    800034f6:	816080e7          	jalr	-2026(ra) # 80000d08 <memset>
      dip->type = type;
    800034fa:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800034fe:	854a                	mv	a0,s2
    80003500:	00001097          	auipc	ra,0x1
    80003504:	c90080e7          	jalr	-880(ra) # 80004190 <log_write>
      brelse(bp);
    80003508:	854a                	mv	a0,s2
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	a22080e7          	jalr	-1502(ra) # 80002f2c <brelse>
      return iget(dev, inum);
    80003512:	85da                	mv	a1,s6
    80003514:	8556                	mv	a0,s5
    80003516:	00000097          	auipc	ra,0x0
    8000351a:	db4080e7          	jalr	-588(ra) # 800032ca <iget>
}
    8000351e:	60a6                	ld	ra,72(sp)
    80003520:	6406                	ld	s0,64(sp)
    80003522:	74e2                	ld	s1,56(sp)
    80003524:	7942                	ld	s2,48(sp)
    80003526:	79a2                	ld	s3,40(sp)
    80003528:	7a02                	ld	s4,32(sp)
    8000352a:	6ae2                	ld	s5,24(sp)
    8000352c:	6b42                	ld	s6,16(sp)
    8000352e:	6ba2                	ld	s7,8(sp)
    80003530:	6161                	addi	sp,sp,80
    80003532:	8082                	ret

0000000080003534 <iupdate>:
{
    80003534:	1101                	addi	sp,sp,-32
    80003536:	ec06                	sd	ra,24(sp)
    80003538:	e822                	sd	s0,16(sp)
    8000353a:	e426                	sd	s1,8(sp)
    8000353c:	e04a                	sd	s2,0(sp)
    8000353e:	1000                	addi	s0,sp,32
    80003540:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003542:	415c                	lw	a5,4(a0)
    80003544:	0047d79b          	srliw	a5,a5,0x4
    80003548:	0001d597          	auipc	a1,0x1d
    8000354c:	9105a583          	lw	a1,-1776(a1) # 8001fe58 <sb+0x18>
    80003550:	9dbd                	addw	a1,a1,a5
    80003552:	4108                	lw	a0,0(a0)
    80003554:	00000097          	auipc	ra,0x0
    80003558:	8a8080e7          	jalr	-1880(ra) # 80002dfc <bread>
    8000355c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000355e:	05850793          	addi	a5,a0,88
    80003562:	40c8                	lw	a0,4(s1)
    80003564:	893d                	andi	a0,a0,15
    80003566:	051a                	slli	a0,a0,0x6
    80003568:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000356a:	04449703          	lh	a4,68(s1)
    8000356e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003572:	04649703          	lh	a4,70(s1)
    80003576:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000357a:	04849703          	lh	a4,72(s1)
    8000357e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003582:	04a49703          	lh	a4,74(s1)
    80003586:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000358a:	44f8                	lw	a4,76(s1)
    8000358c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000358e:	03400613          	li	a2,52
    80003592:	05048593          	addi	a1,s1,80
    80003596:	0531                	addi	a0,a0,12
    80003598:	ffffd097          	auipc	ra,0xffffd
    8000359c:	7cc080e7          	jalr	1996(ra) # 80000d64 <memmove>
  log_write(bp);
    800035a0:	854a                	mv	a0,s2
    800035a2:	00001097          	auipc	ra,0x1
    800035a6:	bee080e7          	jalr	-1042(ra) # 80004190 <log_write>
  brelse(bp);
    800035aa:	854a                	mv	a0,s2
    800035ac:	00000097          	auipc	ra,0x0
    800035b0:	980080e7          	jalr	-1664(ra) # 80002f2c <brelse>
}
    800035b4:	60e2                	ld	ra,24(sp)
    800035b6:	6442                	ld	s0,16(sp)
    800035b8:	64a2                	ld	s1,8(sp)
    800035ba:	6902                	ld	s2,0(sp)
    800035bc:	6105                	addi	sp,sp,32
    800035be:	8082                	ret

00000000800035c0 <idup>:
{
    800035c0:	1101                	addi	sp,sp,-32
    800035c2:	ec06                	sd	ra,24(sp)
    800035c4:	e822                	sd	s0,16(sp)
    800035c6:	e426                	sd	s1,8(sp)
    800035c8:	1000                	addi	s0,sp,32
    800035ca:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800035cc:	0001d517          	auipc	a0,0x1d
    800035d0:	89450513          	addi	a0,a0,-1900 # 8001fe60 <icache>
    800035d4:	ffffd097          	auipc	ra,0xffffd
    800035d8:	638080e7          	jalr	1592(ra) # 80000c0c <acquire>
  ip->ref++;
    800035dc:	449c                	lw	a5,8(s1)
    800035de:	2785                	addiw	a5,a5,1
    800035e0:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800035e2:	0001d517          	auipc	a0,0x1d
    800035e6:	87e50513          	addi	a0,a0,-1922 # 8001fe60 <icache>
    800035ea:	ffffd097          	auipc	ra,0xffffd
    800035ee:	6d6080e7          	jalr	1750(ra) # 80000cc0 <release>
}
    800035f2:	8526                	mv	a0,s1
    800035f4:	60e2                	ld	ra,24(sp)
    800035f6:	6442                	ld	s0,16(sp)
    800035f8:	64a2                	ld	s1,8(sp)
    800035fa:	6105                	addi	sp,sp,32
    800035fc:	8082                	ret

00000000800035fe <ilock>:
{
    800035fe:	1101                	addi	sp,sp,-32
    80003600:	ec06                	sd	ra,24(sp)
    80003602:	e822                	sd	s0,16(sp)
    80003604:	e426                	sd	s1,8(sp)
    80003606:	e04a                	sd	s2,0(sp)
    80003608:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000360a:	c115                	beqz	a0,8000362e <ilock+0x30>
    8000360c:	84aa                	mv	s1,a0
    8000360e:	451c                	lw	a5,8(a0)
    80003610:	00f05f63          	blez	a5,8000362e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003614:	0541                	addi	a0,a0,16
    80003616:	00001097          	auipc	ra,0x1
    8000361a:	ca2080e7          	jalr	-862(ra) # 800042b8 <acquiresleep>
  if(ip->valid == 0){
    8000361e:	40bc                	lw	a5,64(s1)
    80003620:	cf99                	beqz	a5,8000363e <ilock+0x40>
}
    80003622:	60e2                	ld	ra,24(sp)
    80003624:	6442                	ld	s0,16(sp)
    80003626:	64a2                	ld	s1,8(sp)
    80003628:	6902                	ld	s2,0(sp)
    8000362a:	6105                	addi	sp,sp,32
    8000362c:	8082                	ret
    panic("ilock");
    8000362e:	00005517          	auipc	a0,0x5
    80003632:	f7a50513          	addi	a0,a0,-134 # 800085a8 <syscalls+0x180>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	f1a080e7          	jalr	-230(ra) # 80000550 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000363e:	40dc                	lw	a5,4(s1)
    80003640:	0047d79b          	srliw	a5,a5,0x4
    80003644:	0001d597          	auipc	a1,0x1d
    80003648:	8145a583          	lw	a1,-2028(a1) # 8001fe58 <sb+0x18>
    8000364c:	9dbd                	addw	a1,a1,a5
    8000364e:	4088                	lw	a0,0(s1)
    80003650:	fffff097          	auipc	ra,0xfffff
    80003654:	7ac080e7          	jalr	1964(ra) # 80002dfc <bread>
    80003658:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000365a:	05850593          	addi	a1,a0,88
    8000365e:	40dc                	lw	a5,4(s1)
    80003660:	8bbd                	andi	a5,a5,15
    80003662:	079a                	slli	a5,a5,0x6
    80003664:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003666:	00059783          	lh	a5,0(a1)
    8000366a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000366e:	00259783          	lh	a5,2(a1)
    80003672:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003676:	00459783          	lh	a5,4(a1)
    8000367a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000367e:	00659783          	lh	a5,6(a1)
    80003682:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003686:	459c                	lw	a5,8(a1)
    80003688:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000368a:	03400613          	li	a2,52
    8000368e:	05b1                	addi	a1,a1,12
    80003690:	05048513          	addi	a0,s1,80
    80003694:	ffffd097          	auipc	ra,0xffffd
    80003698:	6d0080e7          	jalr	1744(ra) # 80000d64 <memmove>
    brelse(bp);
    8000369c:	854a                	mv	a0,s2
    8000369e:	00000097          	auipc	ra,0x0
    800036a2:	88e080e7          	jalr	-1906(ra) # 80002f2c <brelse>
    ip->valid = 1;
    800036a6:	4785                	li	a5,1
    800036a8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036aa:	04449783          	lh	a5,68(s1)
    800036ae:	fbb5                	bnez	a5,80003622 <ilock+0x24>
      panic("ilock: no type");
    800036b0:	00005517          	auipc	a0,0x5
    800036b4:	f0050513          	addi	a0,a0,-256 # 800085b0 <syscalls+0x188>
    800036b8:	ffffd097          	auipc	ra,0xffffd
    800036bc:	e98080e7          	jalr	-360(ra) # 80000550 <panic>

00000000800036c0 <iunlock>:
{
    800036c0:	1101                	addi	sp,sp,-32
    800036c2:	ec06                	sd	ra,24(sp)
    800036c4:	e822                	sd	s0,16(sp)
    800036c6:	e426                	sd	s1,8(sp)
    800036c8:	e04a                	sd	s2,0(sp)
    800036ca:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800036cc:	c905                	beqz	a0,800036fc <iunlock+0x3c>
    800036ce:	84aa                	mv	s1,a0
    800036d0:	01050913          	addi	s2,a0,16
    800036d4:	854a                	mv	a0,s2
    800036d6:	00001097          	auipc	ra,0x1
    800036da:	c7c080e7          	jalr	-900(ra) # 80004352 <holdingsleep>
    800036de:	cd19                	beqz	a0,800036fc <iunlock+0x3c>
    800036e0:	449c                	lw	a5,8(s1)
    800036e2:	00f05d63          	blez	a5,800036fc <iunlock+0x3c>
  releasesleep(&ip->lock);
    800036e6:	854a                	mv	a0,s2
    800036e8:	00001097          	auipc	ra,0x1
    800036ec:	c26080e7          	jalr	-986(ra) # 8000430e <releasesleep>
}
    800036f0:	60e2                	ld	ra,24(sp)
    800036f2:	6442                	ld	s0,16(sp)
    800036f4:	64a2                	ld	s1,8(sp)
    800036f6:	6902                	ld	s2,0(sp)
    800036f8:	6105                	addi	sp,sp,32
    800036fa:	8082                	ret
    panic("iunlock");
    800036fc:	00005517          	auipc	a0,0x5
    80003700:	ec450513          	addi	a0,a0,-316 # 800085c0 <syscalls+0x198>
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	e4c080e7          	jalr	-436(ra) # 80000550 <panic>

000000008000370c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000370c:	7179                	addi	sp,sp,-48
    8000370e:	f406                	sd	ra,40(sp)
    80003710:	f022                	sd	s0,32(sp)
    80003712:	ec26                	sd	s1,24(sp)
    80003714:	e84a                	sd	s2,16(sp)
    80003716:	e44e                	sd	s3,8(sp)
    80003718:	e052                	sd	s4,0(sp)
    8000371a:	1800                	addi	s0,sp,48
    8000371c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000371e:	05050493          	addi	s1,a0,80
    80003722:	08050913          	addi	s2,a0,128
    80003726:	a021                	j	8000372e <itrunc+0x22>
    80003728:	0491                	addi	s1,s1,4
    8000372a:	01248d63          	beq	s1,s2,80003744 <itrunc+0x38>
    if(ip->addrs[i]){
    8000372e:	408c                	lw	a1,0(s1)
    80003730:	dde5                	beqz	a1,80003728 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003732:	0009a503          	lw	a0,0(s3)
    80003736:	00000097          	auipc	ra,0x0
    8000373a:	90c080e7          	jalr	-1780(ra) # 80003042 <bfree>
      ip->addrs[i] = 0;
    8000373e:	0004a023          	sw	zero,0(s1)
    80003742:	b7dd                	j	80003728 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003744:	0809a583          	lw	a1,128(s3)
    80003748:	e185                	bnez	a1,80003768 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000374a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000374e:	854e                	mv	a0,s3
    80003750:	00000097          	auipc	ra,0x0
    80003754:	de4080e7          	jalr	-540(ra) # 80003534 <iupdate>
}
    80003758:	70a2                	ld	ra,40(sp)
    8000375a:	7402                	ld	s0,32(sp)
    8000375c:	64e2                	ld	s1,24(sp)
    8000375e:	6942                	ld	s2,16(sp)
    80003760:	69a2                	ld	s3,8(sp)
    80003762:	6a02                	ld	s4,0(sp)
    80003764:	6145                	addi	sp,sp,48
    80003766:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003768:	0009a503          	lw	a0,0(s3)
    8000376c:	fffff097          	auipc	ra,0xfffff
    80003770:	690080e7          	jalr	1680(ra) # 80002dfc <bread>
    80003774:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003776:	05850493          	addi	s1,a0,88
    8000377a:	45850913          	addi	s2,a0,1112
    8000377e:	a021                	j	80003786 <itrunc+0x7a>
    80003780:	0491                	addi	s1,s1,4
    80003782:	01248b63          	beq	s1,s2,80003798 <itrunc+0x8c>
      if(a[j])
    80003786:	408c                	lw	a1,0(s1)
    80003788:	dde5                	beqz	a1,80003780 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000378a:	0009a503          	lw	a0,0(s3)
    8000378e:	00000097          	auipc	ra,0x0
    80003792:	8b4080e7          	jalr	-1868(ra) # 80003042 <bfree>
    80003796:	b7ed                	j	80003780 <itrunc+0x74>
    brelse(bp);
    80003798:	8552                	mv	a0,s4
    8000379a:	fffff097          	auipc	ra,0xfffff
    8000379e:	792080e7          	jalr	1938(ra) # 80002f2c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037a2:	0809a583          	lw	a1,128(s3)
    800037a6:	0009a503          	lw	a0,0(s3)
    800037aa:	00000097          	auipc	ra,0x0
    800037ae:	898080e7          	jalr	-1896(ra) # 80003042 <bfree>
    ip->addrs[NDIRECT] = 0;
    800037b2:	0809a023          	sw	zero,128(s3)
    800037b6:	bf51                	j	8000374a <itrunc+0x3e>

00000000800037b8 <iput>:
{
    800037b8:	1101                	addi	sp,sp,-32
    800037ba:	ec06                	sd	ra,24(sp)
    800037bc:	e822                	sd	s0,16(sp)
    800037be:	e426                	sd	s1,8(sp)
    800037c0:	e04a                	sd	s2,0(sp)
    800037c2:	1000                	addi	s0,sp,32
    800037c4:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800037c6:	0001c517          	auipc	a0,0x1c
    800037ca:	69a50513          	addi	a0,a0,1690 # 8001fe60 <icache>
    800037ce:	ffffd097          	auipc	ra,0xffffd
    800037d2:	43e080e7          	jalr	1086(ra) # 80000c0c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037d6:	4498                	lw	a4,8(s1)
    800037d8:	4785                	li	a5,1
    800037da:	02f70363          	beq	a4,a5,80003800 <iput+0x48>
  ip->ref--;
    800037de:	449c                	lw	a5,8(s1)
    800037e0:	37fd                	addiw	a5,a5,-1
    800037e2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800037e4:	0001c517          	auipc	a0,0x1c
    800037e8:	67c50513          	addi	a0,a0,1660 # 8001fe60 <icache>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	4d4080e7          	jalr	1236(ra) # 80000cc0 <release>
}
    800037f4:	60e2                	ld	ra,24(sp)
    800037f6:	6442                	ld	s0,16(sp)
    800037f8:	64a2                	ld	s1,8(sp)
    800037fa:	6902                	ld	s2,0(sp)
    800037fc:	6105                	addi	sp,sp,32
    800037fe:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003800:	40bc                	lw	a5,64(s1)
    80003802:	dff1                	beqz	a5,800037de <iput+0x26>
    80003804:	04a49783          	lh	a5,74(s1)
    80003808:	fbf9                	bnez	a5,800037de <iput+0x26>
    acquiresleep(&ip->lock);
    8000380a:	01048913          	addi	s2,s1,16
    8000380e:	854a                	mv	a0,s2
    80003810:	00001097          	auipc	ra,0x1
    80003814:	aa8080e7          	jalr	-1368(ra) # 800042b8 <acquiresleep>
    release(&icache.lock);
    80003818:	0001c517          	auipc	a0,0x1c
    8000381c:	64850513          	addi	a0,a0,1608 # 8001fe60 <icache>
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	4a0080e7          	jalr	1184(ra) # 80000cc0 <release>
    itrunc(ip);
    80003828:	8526                	mv	a0,s1
    8000382a:	00000097          	auipc	ra,0x0
    8000382e:	ee2080e7          	jalr	-286(ra) # 8000370c <itrunc>
    ip->type = 0;
    80003832:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003836:	8526                	mv	a0,s1
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	cfc080e7          	jalr	-772(ra) # 80003534 <iupdate>
    ip->valid = 0;
    80003840:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003844:	854a                	mv	a0,s2
    80003846:	00001097          	auipc	ra,0x1
    8000384a:	ac8080e7          	jalr	-1336(ra) # 8000430e <releasesleep>
    acquire(&icache.lock);
    8000384e:	0001c517          	auipc	a0,0x1c
    80003852:	61250513          	addi	a0,a0,1554 # 8001fe60 <icache>
    80003856:	ffffd097          	auipc	ra,0xffffd
    8000385a:	3b6080e7          	jalr	950(ra) # 80000c0c <acquire>
    8000385e:	b741                	j	800037de <iput+0x26>

0000000080003860 <iunlockput>:
{
    80003860:	1101                	addi	sp,sp,-32
    80003862:	ec06                	sd	ra,24(sp)
    80003864:	e822                	sd	s0,16(sp)
    80003866:	e426                	sd	s1,8(sp)
    80003868:	1000                	addi	s0,sp,32
    8000386a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000386c:	00000097          	auipc	ra,0x0
    80003870:	e54080e7          	jalr	-428(ra) # 800036c0 <iunlock>
  iput(ip);
    80003874:	8526                	mv	a0,s1
    80003876:	00000097          	auipc	ra,0x0
    8000387a:	f42080e7          	jalr	-190(ra) # 800037b8 <iput>
}
    8000387e:	60e2                	ld	ra,24(sp)
    80003880:	6442                	ld	s0,16(sp)
    80003882:	64a2                	ld	s1,8(sp)
    80003884:	6105                	addi	sp,sp,32
    80003886:	8082                	ret

0000000080003888 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003888:	1141                	addi	sp,sp,-16
    8000388a:	e422                	sd	s0,8(sp)
    8000388c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000388e:	411c                	lw	a5,0(a0)
    80003890:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003892:	415c                	lw	a5,4(a0)
    80003894:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003896:	04451783          	lh	a5,68(a0)
    8000389a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000389e:	04a51783          	lh	a5,74(a0)
    800038a2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038a6:	04c56783          	lwu	a5,76(a0)
    800038aa:	e99c                	sd	a5,16(a1)
}
    800038ac:	6422                	ld	s0,8(sp)
    800038ae:	0141                	addi	sp,sp,16
    800038b0:	8082                	ret

00000000800038b2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038b2:	457c                	lw	a5,76(a0)
    800038b4:	0ed7e863          	bltu	a5,a3,800039a4 <readi+0xf2>
{
    800038b8:	7159                	addi	sp,sp,-112
    800038ba:	f486                	sd	ra,104(sp)
    800038bc:	f0a2                	sd	s0,96(sp)
    800038be:	eca6                	sd	s1,88(sp)
    800038c0:	e8ca                	sd	s2,80(sp)
    800038c2:	e4ce                	sd	s3,72(sp)
    800038c4:	e0d2                	sd	s4,64(sp)
    800038c6:	fc56                	sd	s5,56(sp)
    800038c8:	f85a                	sd	s6,48(sp)
    800038ca:	f45e                	sd	s7,40(sp)
    800038cc:	f062                	sd	s8,32(sp)
    800038ce:	ec66                	sd	s9,24(sp)
    800038d0:	e86a                	sd	s10,16(sp)
    800038d2:	e46e                	sd	s11,8(sp)
    800038d4:	1880                	addi	s0,sp,112
    800038d6:	8baa                	mv	s7,a0
    800038d8:	8c2e                	mv	s8,a1
    800038da:	8ab2                	mv	s5,a2
    800038dc:	84b6                	mv	s1,a3
    800038de:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038e0:	9f35                	addw	a4,a4,a3
    return 0;
    800038e2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800038e4:	08d76f63          	bltu	a4,a3,80003982 <readi+0xd0>
  if(off + n > ip->size)
    800038e8:	00e7f463          	bgeu	a5,a4,800038f0 <readi+0x3e>
    n = ip->size - off;
    800038ec:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038f0:	0a0b0863          	beqz	s6,800039a0 <readi+0xee>
    800038f4:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800038f6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038fa:	5cfd                	li	s9,-1
    800038fc:	a82d                	j	80003936 <readi+0x84>
    800038fe:	020a1d93          	slli	s11,s4,0x20
    80003902:	020ddd93          	srli	s11,s11,0x20
    80003906:	05890793          	addi	a5,s2,88
    8000390a:	86ee                	mv	a3,s11
    8000390c:	963e                	add	a2,a2,a5
    8000390e:	85d6                	mv	a1,s5
    80003910:	8562                	mv	a0,s8
    80003912:	fffff097          	auipc	ra,0xfffff
    80003916:	b30080e7          	jalr	-1232(ra) # 80002442 <either_copyout>
    8000391a:	05950d63          	beq	a0,s9,80003974 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    8000391e:	854a                	mv	a0,s2
    80003920:	fffff097          	auipc	ra,0xfffff
    80003924:	60c080e7          	jalr	1548(ra) # 80002f2c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003928:	013a09bb          	addw	s3,s4,s3
    8000392c:	009a04bb          	addw	s1,s4,s1
    80003930:	9aee                	add	s5,s5,s11
    80003932:	0569f663          	bgeu	s3,s6,8000397e <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003936:	000ba903          	lw	s2,0(s7)
    8000393a:	00a4d59b          	srliw	a1,s1,0xa
    8000393e:	855e                	mv	a0,s7
    80003940:	00000097          	auipc	ra,0x0
    80003944:	8b0080e7          	jalr	-1872(ra) # 800031f0 <bmap>
    80003948:	0005059b          	sext.w	a1,a0
    8000394c:	854a                	mv	a0,s2
    8000394e:	fffff097          	auipc	ra,0xfffff
    80003952:	4ae080e7          	jalr	1198(ra) # 80002dfc <bread>
    80003956:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003958:	3ff4f613          	andi	a2,s1,1023
    8000395c:	40cd07bb          	subw	a5,s10,a2
    80003960:	413b073b          	subw	a4,s6,s3
    80003964:	8a3e                	mv	s4,a5
    80003966:	2781                	sext.w	a5,a5
    80003968:	0007069b          	sext.w	a3,a4
    8000396c:	f8f6f9e3          	bgeu	a3,a5,800038fe <readi+0x4c>
    80003970:	8a3a                	mv	s4,a4
    80003972:	b771                	j	800038fe <readi+0x4c>
      brelse(bp);
    80003974:	854a                	mv	a0,s2
    80003976:	fffff097          	auipc	ra,0xfffff
    8000397a:	5b6080e7          	jalr	1462(ra) # 80002f2c <brelse>
  }
  return tot;
    8000397e:	0009851b          	sext.w	a0,s3
}
    80003982:	70a6                	ld	ra,104(sp)
    80003984:	7406                	ld	s0,96(sp)
    80003986:	64e6                	ld	s1,88(sp)
    80003988:	6946                	ld	s2,80(sp)
    8000398a:	69a6                	ld	s3,72(sp)
    8000398c:	6a06                	ld	s4,64(sp)
    8000398e:	7ae2                	ld	s5,56(sp)
    80003990:	7b42                	ld	s6,48(sp)
    80003992:	7ba2                	ld	s7,40(sp)
    80003994:	7c02                	ld	s8,32(sp)
    80003996:	6ce2                	ld	s9,24(sp)
    80003998:	6d42                	ld	s10,16(sp)
    8000399a:	6da2                	ld	s11,8(sp)
    8000399c:	6165                	addi	sp,sp,112
    8000399e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039a0:	89da                	mv	s3,s6
    800039a2:	bff1                	j	8000397e <readi+0xcc>
    return 0;
    800039a4:	4501                	li	a0,0
}
    800039a6:	8082                	ret

00000000800039a8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039a8:	457c                	lw	a5,76(a0)
    800039aa:	10d7e663          	bltu	a5,a3,80003ab6 <writei+0x10e>
{
    800039ae:	7159                	addi	sp,sp,-112
    800039b0:	f486                	sd	ra,104(sp)
    800039b2:	f0a2                	sd	s0,96(sp)
    800039b4:	eca6                	sd	s1,88(sp)
    800039b6:	e8ca                	sd	s2,80(sp)
    800039b8:	e4ce                	sd	s3,72(sp)
    800039ba:	e0d2                	sd	s4,64(sp)
    800039bc:	fc56                	sd	s5,56(sp)
    800039be:	f85a                	sd	s6,48(sp)
    800039c0:	f45e                	sd	s7,40(sp)
    800039c2:	f062                	sd	s8,32(sp)
    800039c4:	ec66                	sd	s9,24(sp)
    800039c6:	e86a                	sd	s10,16(sp)
    800039c8:	e46e                	sd	s11,8(sp)
    800039ca:	1880                	addi	s0,sp,112
    800039cc:	8baa                	mv	s7,a0
    800039ce:	8c2e                	mv	s8,a1
    800039d0:	8ab2                	mv	s5,a2
    800039d2:	8936                	mv	s2,a3
    800039d4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039d6:	00e687bb          	addw	a5,a3,a4
    800039da:	0ed7e063          	bltu	a5,a3,80003aba <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800039de:	00043737          	lui	a4,0x43
    800039e2:	0cf76e63          	bltu	a4,a5,80003abe <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039e6:	0a0b0763          	beqz	s6,80003a94 <writei+0xec>
    800039ea:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ec:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800039f0:	5cfd                	li	s9,-1
    800039f2:	a091                	j	80003a36 <writei+0x8e>
    800039f4:	02099d93          	slli	s11,s3,0x20
    800039f8:	020ddd93          	srli	s11,s11,0x20
    800039fc:	05848793          	addi	a5,s1,88
    80003a00:	86ee                	mv	a3,s11
    80003a02:	8656                	mv	a2,s5
    80003a04:	85e2                	mv	a1,s8
    80003a06:	953e                	add	a0,a0,a5
    80003a08:	fffff097          	auipc	ra,0xfffff
    80003a0c:	a90080e7          	jalr	-1392(ra) # 80002498 <either_copyin>
    80003a10:	07950263          	beq	a0,s9,80003a74 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a14:	8526                	mv	a0,s1
    80003a16:	00000097          	auipc	ra,0x0
    80003a1a:	77a080e7          	jalr	1914(ra) # 80004190 <log_write>
    brelse(bp);
    80003a1e:	8526                	mv	a0,s1
    80003a20:	fffff097          	auipc	ra,0xfffff
    80003a24:	50c080e7          	jalr	1292(ra) # 80002f2c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a28:	01498a3b          	addw	s4,s3,s4
    80003a2c:	0129893b          	addw	s2,s3,s2
    80003a30:	9aee                	add	s5,s5,s11
    80003a32:	056a7663          	bgeu	s4,s6,80003a7e <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a36:	000ba483          	lw	s1,0(s7)
    80003a3a:	00a9559b          	srliw	a1,s2,0xa
    80003a3e:	855e                	mv	a0,s7
    80003a40:	fffff097          	auipc	ra,0xfffff
    80003a44:	7b0080e7          	jalr	1968(ra) # 800031f0 <bmap>
    80003a48:	0005059b          	sext.w	a1,a0
    80003a4c:	8526                	mv	a0,s1
    80003a4e:	fffff097          	auipc	ra,0xfffff
    80003a52:	3ae080e7          	jalr	942(ra) # 80002dfc <bread>
    80003a56:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a58:	3ff97513          	andi	a0,s2,1023
    80003a5c:	40ad07bb          	subw	a5,s10,a0
    80003a60:	414b073b          	subw	a4,s6,s4
    80003a64:	89be                	mv	s3,a5
    80003a66:	2781                	sext.w	a5,a5
    80003a68:	0007069b          	sext.w	a3,a4
    80003a6c:	f8f6f4e3          	bgeu	a3,a5,800039f4 <writei+0x4c>
    80003a70:	89ba                	mv	s3,a4
    80003a72:	b749                	j	800039f4 <writei+0x4c>
      brelse(bp);
    80003a74:	8526                	mv	a0,s1
    80003a76:	fffff097          	auipc	ra,0xfffff
    80003a7a:	4b6080e7          	jalr	1206(ra) # 80002f2c <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003a7e:	04cba783          	lw	a5,76(s7)
    80003a82:	0127f463          	bgeu	a5,s2,80003a8a <writei+0xe2>
      ip->size = off;
    80003a86:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003a8a:	855e                	mv	a0,s7
    80003a8c:	00000097          	auipc	ra,0x0
    80003a90:	aa8080e7          	jalr	-1368(ra) # 80003534 <iupdate>
  }

  return n;
    80003a94:	000b051b          	sext.w	a0,s6
}
    80003a98:	70a6                	ld	ra,104(sp)
    80003a9a:	7406                	ld	s0,96(sp)
    80003a9c:	64e6                	ld	s1,88(sp)
    80003a9e:	6946                	ld	s2,80(sp)
    80003aa0:	69a6                	ld	s3,72(sp)
    80003aa2:	6a06                	ld	s4,64(sp)
    80003aa4:	7ae2                	ld	s5,56(sp)
    80003aa6:	7b42                	ld	s6,48(sp)
    80003aa8:	7ba2                	ld	s7,40(sp)
    80003aaa:	7c02                	ld	s8,32(sp)
    80003aac:	6ce2                	ld	s9,24(sp)
    80003aae:	6d42                	ld	s10,16(sp)
    80003ab0:	6da2                	ld	s11,8(sp)
    80003ab2:	6165                	addi	sp,sp,112
    80003ab4:	8082                	ret
    return -1;
    80003ab6:	557d                	li	a0,-1
}
    80003ab8:	8082                	ret
    return -1;
    80003aba:	557d                	li	a0,-1
    80003abc:	bff1                	j	80003a98 <writei+0xf0>
    return -1;
    80003abe:	557d                	li	a0,-1
    80003ac0:	bfe1                	j	80003a98 <writei+0xf0>

0000000080003ac2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ac2:	1141                	addi	sp,sp,-16
    80003ac4:	e406                	sd	ra,8(sp)
    80003ac6:	e022                	sd	s0,0(sp)
    80003ac8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003aca:	4639                	li	a2,14
    80003acc:	ffffd097          	auipc	ra,0xffffd
    80003ad0:	314080e7          	jalr	788(ra) # 80000de0 <strncmp>
}
    80003ad4:	60a2                	ld	ra,8(sp)
    80003ad6:	6402                	ld	s0,0(sp)
    80003ad8:	0141                	addi	sp,sp,16
    80003ada:	8082                	ret

0000000080003adc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003adc:	7139                	addi	sp,sp,-64
    80003ade:	fc06                	sd	ra,56(sp)
    80003ae0:	f822                	sd	s0,48(sp)
    80003ae2:	f426                	sd	s1,40(sp)
    80003ae4:	f04a                	sd	s2,32(sp)
    80003ae6:	ec4e                	sd	s3,24(sp)
    80003ae8:	e852                	sd	s4,16(sp)
    80003aea:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003aec:	04451703          	lh	a4,68(a0)
    80003af0:	4785                	li	a5,1
    80003af2:	00f71a63          	bne	a4,a5,80003b06 <dirlookup+0x2a>
    80003af6:	892a                	mv	s2,a0
    80003af8:	89ae                	mv	s3,a1
    80003afa:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003afc:	457c                	lw	a5,76(a0)
    80003afe:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b00:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b02:	e79d                	bnez	a5,80003b30 <dirlookup+0x54>
    80003b04:	a8a5                	j	80003b7c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b06:	00005517          	auipc	a0,0x5
    80003b0a:	ac250513          	addi	a0,a0,-1342 # 800085c8 <syscalls+0x1a0>
    80003b0e:	ffffd097          	auipc	ra,0xffffd
    80003b12:	a42080e7          	jalr	-1470(ra) # 80000550 <panic>
      panic("dirlookup read");
    80003b16:	00005517          	auipc	a0,0x5
    80003b1a:	aca50513          	addi	a0,a0,-1334 # 800085e0 <syscalls+0x1b8>
    80003b1e:	ffffd097          	auipc	ra,0xffffd
    80003b22:	a32080e7          	jalr	-1486(ra) # 80000550 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b26:	24c1                	addiw	s1,s1,16
    80003b28:	04c92783          	lw	a5,76(s2)
    80003b2c:	04f4f763          	bgeu	s1,a5,80003b7a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b30:	4741                	li	a4,16
    80003b32:	86a6                	mv	a3,s1
    80003b34:	fc040613          	addi	a2,s0,-64
    80003b38:	4581                	li	a1,0
    80003b3a:	854a                	mv	a0,s2
    80003b3c:	00000097          	auipc	ra,0x0
    80003b40:	d76080e7          	jalr	-650(ra) # 800038b2 <readi>
    80003b44:	47c1                	li	a5,16
    80003b46:	fcf518e3          	bne	a0,a5,80003b16 <dirlookup+0x3a>
    if(de.inum == 0)
    80003b4a:	fc045783          	lhu	a5,-64(s0)
    80003b4e:	dfe1                	beqz	a5,80003b26 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003b50:	fc240593          	addi	a1,s0,-62
    80003b54:	854e                	mv	a0,s3
    80003b56:	00000097          	auipc	ra,0x0
    80003b5a:	f6c080e7          	jalr	-148(ra) # 80003ac2 <namecmp>
    80003b5e:	f561                	bnez	a0,80003b26 <dirlookup+0x4a>
      if(poff)
    80003b60:	000a0463          	beqz	s4,80003b68 <dirlookup+0x8c>
        *poff = off;
    80003b64:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b68:	fc045583          	lhu	a1,-64(s0)
    80003b6c:	00092503          	lw	a0,0(s2)
    80003b70:	fffff097          	auipc	ra,0xfffff
    80003b74:	75a080e7          	jalr	1882(ra) # 800032ca <iget>
    80003b78:	a011                	j	80003b7c <dirlookup+0xa0>
  return 0;
    80003b7a:	4501                	li	a0,0
}
    80003b7c:	70e2                	ld	ra,56(sp)
    80003b7e:	7442                	ld	s0,48(sp)
    80003b80:	74a2                	ld	s1,40(sp)
    80003b82:	7902                	ld	s2,32(sp)
    80003b84:	69e2                	ld	s3,24(sp)
    80003b86:	6a42                	ld	s4,16(sp)
    80003b88:	6121                	addi	sp,sp,64
    80003b8a:	8082                	ret

0000000080003b8c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b8c:	711d                	addi	sp,sp,-96
    80003b8e:	ec86                	sd	ra,88(sp)
    80003b90:	e8a2                	sd	s0,80(sp)
    80003b92:	e4a6                	sd	s1,72(sp)
    80003b94:	e0ca                	sd	s2,64(sp)
    80003b96:	fc4e                	sd	s3,56(sp)
    80003b98:	f852                	sd	s4,48(sp)
    80003b9a:	f456                	sd	s5,40(sp)
    80003b9c:	f05a                	sd	s6,32(sp)
    80003b9e:	ec5e                	sd	s7,24(sp)
    80003ba0:	e862                	sd	s8,16(sp)
    80003ba2:	e466                	sd	s9,8(sp)
    80003ba4:	1080                	addi	s0,sp,96
    80003ba6:	84aa                	mv	s1,a0
    80003ba8:	8aae                	mv	s5,a1
    80003baa:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003bac:	00054703          	lbu	a4,0(a0)
    80003bb0:	02f00793          	li	a5,47
    80003bb4:	02f70363          	beq	a4,a5,80003bda <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bb8:	ffffe097          	auipc	ra,0xffffe
    80003bbc:	e20080e7          	jalr	-480(ra) # 800019d8 <myproc>
    80003bc0:	15053503          	ld	a0,336(a0)
    80003bc4:	00000097          	auipc	ra,0x0
    80003bc8:	9fc080e7          	jalr	-1540(ra) # 800035c0 <idup>
    80003bcc:	89aa                	mv	s3,a0
  while(*path == '/')
    80003bce:	02f00913          	li	s2,47
  len = path - s;
    80003bd2:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003bd4:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003bd6:	4b85                	li	s7,1
    80003bd8:	a865                	j	80003c90 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003bda:	4585                	li	a1,1
    80003bdc:	4505                	li	a0,1
    80003bde:	fffff097          	auipc	ra,0xfffff
    80003be2:	6ec080e7          	jalr	1772(ra) # 800032ca <iget>
    80003be6:	89aa                	mv	s3,a0
    80003be8:	b7dd                	j	80003bce <namex+0x42>
      iunlockput(ip);
    80003bea:	854e                	mv	a0,s3
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	c74080e7          	jalr	-908(ra) # 80003860 <iunlockput>
      return 0;
    80003bf4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003bf6:	854e                	mv	a0,s3
    80003bf8:	60e6                	ld	ra,88(sp)
    80003bfa:	6446                	ld	s0,80(sp)
    80003bfc:	64a6                	ld	s1,72(sp)
    80003bfe:	6906                	ld	s2,64(sp)
    80003c00:	79e2                	ld	s3,56(sp)
    80003c02:	7a42                	ld	s4,48(sp)
    80003c04:	7aa2                	ld	s5,40(sp)
    80003c06:	7b02                	ld	s6,32(sp)
    80003c08:	6be2                	ld	s7,24(sp)
    80003c0a:	6c42                	ld	s8,16(sp)
    80003c0c:	6ca2                	ld	s9,8(sp)
    80003c0e:	6125                	addi	sp,sp,96
    80003c10:	8082                	ret
      iunlock(ip);
    80003c12:	854e                	mv	a0,s3
    80003c14:	00000097          	auipc	ra,0x0
    80003c18:	aac080e7          	jalr	-1364(ra) # 800036c0 <iunlock>
      return ip;
    80003c1c:	bfe9                	j	80003bf6 <namex+0x6a>
      iunlockput(ip);
    80003c1e:	854e                	mv	a0,s3
    80003c20:	00000097          	auipc	ra,0x0
    80003c24:	c40080e7          	jalr	-960(ra) # 80003860 <iunlockput>
      return 0;
    80003c28:	89e6                	mv	s3,s9
    80003c2a:	b7f1                	j	80003bf6 <namex+0x6a>
  len = path - s;
    80003c2c:	40b48633          	sub	a2,s1,a1
    80003c30:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c34:	099c5463          	bge	s8,s9,80003cbc <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003c38:	4639                	li	a2,14
    80003c3a:	8552                	mv	a0,s4
    80003c3c:	ffffd097          	auipc	ra,0xffffd
    80003c40:	128080e7          	jalr	296(ra) # 80000d64 <memmove>
  while(*path == '/')
    80003c44:	0004c783          	lbu	a5,0(s1)
    80003c48:	01279763          	bne	a5,s2,80003c56 <namex+0xca>
    path++;
    80003c4c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c4e:	0004c783          	lbu	a5,0(s1)
    80003c52:	ff278de3          	beq	a5,s2,80003c4c <namex+0xc0>
    ilock(ip);
    80003c56:	854e                	mv	a0,s3
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	9a6080e7          	jalr	-1626(ra) # 800035fe <ilock>
    if(ip->type != T_DIR){
    80003c60:	04499783          	lh	a5,68(s3)
    80003c64:	f97793e3          	bne	a5,s7,80003bea <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003c68:	000a8563          	beqz	s5,80003c72 <namex+0xe6>
    80003c6c:	0004c783          	lbu	a5,0(s1)
    80003c70:	d3cd                	beqz	a5,80003c12 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c72:	865a                	mv	a2,s6
    80003c74:	85d2                	mv	a1,s4
    80003c76:	854e                	mv	a0,s3
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	e64080e7          	jalr	-412(ra) # 80003adc <dirlookup>
    80003c80:	8caa                	mv	s9,a0
    80003c82:	dd51                	beqz	a0,80003c1e <namex+0x92>
    iunlockput(ip);
    80003c84:	854e                	mv	a0,s3
    80003c86:	00000097          	auipc	ra,0x0
    80003c8a:	bda080e7          	jalr	-1062(ra) # 80003860 <iunlockput>
    ip = next;
    80003c8e:	89e6                	mv	s3,s9
  while(*path == '/')
    80003c90:	0004c783          	lbu	a5,0(s1)
    80003c94:	05279763          	bne	a5,s2,80003ce2 <namex+0x156>
    path++;
    80003c98:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c9a:	0004c783          	lbu	a5,0(s1)
    80003c9e:	ff278de3          	beq	a5,s2,80003c98 <namex+0x10c>
  if(*path == 0)
    80003ca2:	c79d                	beqz	a5,80003cd0 <namex+0x144>
    path++;
    80003ca4:	85a6                	mv	a1,s1
  len = path - s;
    80003ca6:	8cda                	mv	s9,s6
    80003ca8:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003caa:	01278963          	beq	a5,s2,80003cbc <namex+0x130>
    80003cae:	dfbd                	beqz	a5,80003c2c <namex+0xa0>
    path++;
    80003cb0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003cb2:	0004c783          	lbu	a5,0(s1)
    80003cb6:	ff279ce3          	bne	a5,s2,80003cae <namex+0x122>
    80003cba:	bf8d                	j	80003c2c <namex+0xa0>
    memmove(name, s, len);
    80003cbc:	2601                	sext.w	a2,a2
    80003cbe:	8552                	mv	a0,s4
    80003cc0:	ffffd097          	auipc	ra,0xffffd
    80003cc4:	0a4080e7          	jalr	164(ra) # 80000d64 <memmove>
    name[len] = 0;
    80003cc8:	9cd2                	add	s9,s9,s4
    80003cca:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003cce:	bf9d                	j	80003c44 <namex+0xb8>
  if(nameiparent){
    80003cd0:	f20a83e3          	beqz	s5,80003bf6 <namex+0x6a>
    iput(ip);
    80003cd4:	854e                	mv	a0,s3
    80003cd6:	00000097          	auipc	ra,0x0
    80003cda:	ae2080e7          	jalr	-1310(ra) # 800037b8 <iput>
    return 0;
    80003cde:	4981                	li	s3,0
    80003ce0:	bf19                	j	80003bf6 <namex+0x6a>
  if(*path == 0)
    80003ce2:	d7fd                	beqz	a5,80003cd0 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003ce4:	0004c783          	lbu	a5,0(s1)
    80003ce8:	85a6                	mv	a1,s1
    80003cea:	b7d1                	j	80003cae <namex+0x122>

0000000080003cec <dirlink>:
{
    80003cec:	7139                	addi	sp,sp,-64
    80003cee:	fc06                	sd	ra,56(sp)
    80003cf0:	f822                	sd	s0,48(sp)
    80003cf2:	f426                	sd	s1,40(sp)
    80003cf4:	f04a                	sd	s2,32(sp)
    80003cf6:	ec4e                	sd	s3,24(sp)
    80003cf8:	e852                	sd	s4,16(sp)
    80003cfa:	0080                	addi	s0,sp,64
    80003cfc:	892a                	mv	s2,a0
    80003cfe:	8a2e                	mv	s4,a1
    80003d00:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d02:	4601                	li	a2,0
    80003d04:	00000097          	auipc	ra,0x0
    80003d08:	dd8080e7          	jalr	-552(ra) # 80003adc <dirlookup>
    80003d0c:	e93d                	bnez	a0,80003d82 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d0e:	04c92483          	lw	s1,76(s2)
    80003d12:	c49d                	beqz	s1,80003d40 <dirlink+0x54>
    80003d14:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d16:	4741                	li	a4,16
    80003d18:	86a6                	mv	a3,s1
    80003d1a:	fc040613          	addi	a2,s0,-64
    80003d1e:	4581                	li	a1,0
    80003d20:	854a                	mv	a0,s2
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	b90080e7          	jalr	-1136(ra) # 800038b2 <readi>
    80003d2a:	47c1                	li	a5,16
    80003d2c:	06f51163          	bne	a0,a5,80003d8e <dirlink+0xa2>
    if(de.inum == 0)
    80003d30:	fc045783          	lhu	a5,-64(s0)
    80003d34:	c791                	beqz	a5,80003d40 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d36:	24c1                	addiw	s1,s1,16
    80003d38:	04c92783          	lw	a5,76(s2)
    80003d3c:	fcf4ede3          	bltu	s1,a5,80003d16 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d40:	4639                	li	a2,14
    80003d42:	85d2                	mv	a1,s4
    80003d44:	fc240513          	addi	a0,s0,-62
    80003d48:	ffffd097          	auipc	ra,0xffffd
    80003d4c:	0d4080e7          	jalr	212(ra) # 80000e1c <strncpy>
  de.inum = inum;
    80003d50:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d54:	4741                	li	a4,16
    80003d56:	86a6                	mv	a3,s1
    80003d58:	fc040613          	addi	a2,s0,-64
    80003d5c:	4581                	li	a1,0
    80003d5e:	854a                	mv	a0,s2
    80003d60:	00000097          	auipc	ra,0x0
    80003d64:	c48080e7          	jalr	-952(ra) # 800039a8 <writei>
    80003d68:	872a                	mv	a4,a0
    80003d6a:	47c1                	li	a5,16
  return 0;
    80003d6c:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d6e:	02f71863          	bne	a4,a5,80003d9e <dirlink+0xb2>
}
    80003d72:	70e2                	ld	ra,56(sp)
    80003d74:	7442                	ld	s0,48(sp)
    80003d76:	74a2                	ld	s1,40(sp)
    80003d78:	7902                	ld	s2,32(sp)
    80003d7a:	69e2                	ld	s3,24(sp)
    80003d7c:	6a42                	ld	s4,16(sp)
    80003d7e:	6121                	addi	sp,sp,64
    80003d80:	8082                	ret
    iput(ip);
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	a36080e7          	jalr	-1482(ra) # 800037b8 <iput>
    return -1;
    80003d8a:	557d                	li	a0,-1
    80003d8c:	b7dd                	j	80003d72 <dirlink+0x86>
      panic("dirlink read");
    80003d8e:	00005517          	auipc	a0,0x5
    80003d92:	86250513          	addi	a0,a0,-1950 # 800085f0 <syscalls+0x1c8>
    80003d96:	ffffc097          	auipc	ra,0xffffc
    80003d9a:	7ba080e7          	jalr	1978(ra) # 80000550 <panic>
    panic("dirlink");
    80003d9e:	00005517          	auipc	a0,0x5
    80003da2:	97250513          	addi	a0,a0,-1678 # 80008710 <syscalls+0x2e8>
    80003da6:	ffffc097          	auipc	ra,0xffffc
    80003daa:	7aa080e7          	jalr	1962(ra) # 80000550 <panic>

0000000080003dae <namei>:

struct inode*
namei(char *path)
{
    80003dae:	1101                	addi	sp,sp,-32
    80003db0:	ec06                	sd	ra,24(sp)
    80003db2:	e822                	sd	s0,16(sp)
    80003db4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003db6:	fe040613          	addi	a2,s0,-32
    80003dba:	4581                	li	a1,0
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	dd0080e7          	jalr	-560(ra) # 80003b8c <namex>
}
    80003dc4:	60e2                	ld	ra,24(sp)
    80003dc6:	6442                	ld	s0,16(sp)
    80003dc8:	6105                	addi	sp,sp,32
    80003dca:	8082                	ret

0000000080003dcc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003dcc:	1141                	addi	sp,sp,-16
    80003dce:	e406                	sd	ra,8(sp)
    80003dd0:	e022                	sd	s0,0(sp)
    80003dd2:	0800                	addi	s0,sp,16
    80003dd4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003dd6:	4585                	li	a1,1
    80003dd8:	00000097          	auipc	ra,0x0
    80003ddc:	db4080e7          	jalr	-588(ra) # 80003b8c <namex>
}
    80003de0:	60a2                	ld	ra,8(sp)
    80003de2:	6402                	ld	s0,0(sp)
    80003de4:	0141                	addi	sp,sp,16
    80003de6:	8082                	ret

0000000080003de8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003de8:	1101                	addi	sp,sp,-32
    80003dea:	ec06                	sd	ra,24(sp)
    80003dec:	e822                	sd	s0,16(sp)
    80003dee:	e426                	sd	s1,8(sp)
    80003df0:	e04a                	sd	s2,0(sp)
    80003df2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003df4:	0001e917          	auipc	s2,0x1e
    80003df8:	b1490913          	addi	s2,s2,-1260 # 80021908 <log>
    80003dfc:	01892583          	lw	a1,24(s2)
    80003e00:	02892503          	lw	a0,40(s2)
    80003e04:	fffff097          	auipc	ra,0xfffff
    80003e08:	ff8080e7          	jalr	-8(ra) # 80002dfc <bread>
    80003e0c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e0e:	02c92683          	lw	a3,44(s2)
    80003e12:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e14:	02d05763          	blez	a3,80003e42 <write_head+0x5a>
    80003e18:	0001e797          	auipc	a5,0x1e
    80003e1c:	b2078793          	addi	a5,a5,-1248 # 80021938 <log+0x30>
    80003e20:	05c50713          	addi	a4,a0,92
    80003e24:	36fd                	addiw	a3,a3,-1
    80003e26:	1682                	slli	a3,a3,0x20
    80003e28:	9281                	srli	a3,a3,0x20
    80003e2a:	068a                	slli	a3,a3,0x2
    80003e2c:	0001e617          	auipc	a2,0x1e
    80003e30:	b1060613          	addi	a2,a2,-1264 # 8002193c <log+0x34>
    80003e34:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003e36:	4390                	lw	a2,0(a5)
    80003e38:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e3a:	0791                	addi	a5,a5,4
    80003e3c:	0711                	addi	a4,a4,4
    80003e3e:	fed79ce3          	bne	a5,a3,80003e36 <write_head+0x4e>
  }
  bwrite(buf);
    80003e42:	8526                	mv	a0,s1
    80003e44:	fffff097          	auipc	ra,0xfffff
    80003e48:	0aa080e7          	jalr	170(ra) # 80002eee <bwrite>
  brelse(buf);
    80003e4c:	8526                	mv	a0,s1
    80003e4e:	fffff097          	auipc	ra,0xfffff
    80003e52:	0de080e7          	jalr	222(ra) # 80002f2c <brelse>
}
    80003e56:	60e2                	ld	ra,24(sp)
    80003e58:	6442                	ld	s0,16(sp)
    80003e5a:	64a2                	ld	s1,8(sp)
    80003e5c:	6902                	ld	s2,0(sp)
    80003e5e:	6105                	addi	sp,sp,32
    80003e60:	8082                	ret

0000000080003e62 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e62:	0001e797          	auipc	a5,0x1e
    80003e66:	ad27a783          	lw	a5,-1326(a5) # 80021934 <log+0x2c>
    80003e6a:	0af05663          	blez	a5,80003f16 <install_trans+0xb4>
{
    80003e6e:	7139                	addi	sp,sp,-64
    80003e70:	fc06                	sd	ra,56(sp)
    80003e72:	f822                	sd	s0,48(sp)
    80003e74:	f426                	sd	s1,40(sp)
    80003e76:	f04a                	sd	s2,32(sp)
    80003e78:	ec4e                	sd	s3,24(sp)
    80003e7a:	e852                	sd	s4,16(sp)
    80003e7c:	e456                	sd	s5,8(sp)
    80003e7e:	0080                	addi	s0,sp,64
    80003e80:	0001ea97          	auipc	s5,0x1e
    80003e84:	ab8a8a93          	addi	s5,s5,-1352 # 80021938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e88:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e8a:	0001e997          	auipc	s3,0x1e
    80003e8e:	a7e98993          	addi	s3,s3,-1410 # 80021908 <log>
    80003e92:	0189a583          	lw	a1,24(s3)
    80003e96:	014585bb          	addw	a1,a1,s4
    80003e9a:	2585                	addiw	a1,a1,1
    80003e9c:	0289a503          	lw	a0,40(s3)
    80003ea0:	fffff097          	auipc	ra,0xfffff
    80003ea4:	f5c080e7          	jalr	-164(ra) # 80002dfc <bread>
    80003ea8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003eaa:	000aa583          	lw	a1,0(s5)
    80003eae:	0289a503          	lw	a0,40(s3)
    80003eb2:	fffff097          	auipc	ra,0xfffff
    80003eb6:	f4a080e7          	jalr	-182(ra) # 80002dfc <bread>
    80003eba:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ebc:	40000613          	li	a2,1024
    80003ec0:	05890593          	addi	a1,s2,88
    80003ec4:	05850513          	addi	a0,a0,88
    80003ec8:	ffffd097          	auipc	ra,0xffffd
    80003ecc:	e9c080e7          	jalr	-356(ra) # 80000d64 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ed0:	8526                	mv	a0,s1
    80003ed2:	fffff097          	auipc	ra,0xfffff
    80003ed6:	01c080e7          	jalr	28(ra) # 80002eee <bwrite>
    bunpin(dbuf);
    80003eda:	8526                	mv	a0,s1
    80003edc:	fffff097          	auipc	ra,0xfffff
    80003ee0:	12a080e7          	jalr	298(ra) # 80003006 <bunpin>
    brelse(lbuf);
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	fffff097          	auipc	ra,0xfffff
    80003eea:	046080e7          	jalr	70(ra) # 80002f2c <brelse>
    brelse(dbuf);
    80003eee:	8526                	mv	a0,s1
    80003ef0:	fffff097          	auipc	ra,0xfffff
    80003ef4:	03c080e7          	jalr	60(ra) # 80002f2c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ef8:	2a05                	addiw	s4,s4,1
    80003efa:	0a91                	addi	s5,s5,4
    80003efc:	02c9a783          	lw	a5,44(s3)
    80003f00:	f8fa49e3          	blt	s4,a5,80003e92 <install_trans+0x30>
}
    80003f04:	70e2                	ld	ra,56(sp)
    80003f06:	7442                	ld	s0,48(sp)
    80003f08:	74a2                	ld	s1,40(sp)
    80003f0a:	7902                	ld	s2,32(sp)
    80003f0c:	69e2                	ld	s3,24(sp)
    80003f0e:	6a42                	ld	s4,16(sp)
    80003f10:	6aa2                	ld	s5,8(sp)
    80003f12:	6121                	addi	sp,sp,64
    80003f14:	8082                	ret
    80003f16:	8082                	ret

0000000080003f18 <initlog>:
{
    80003f18:	7179                	addi	sp,sp,-48
    80003f1a:	f406                	sd	ra,40(sp)
    80003f1c:	f022                	sd	s0,32(sp)
    80003f1e:	ec26                	sd	s1,24(sp)
    80003f20:	e84a                	sd	s2,16(sp)
    80003f22:	e44e                	sd	s3,8(sp)
    80003f24:	1800                	addi	s0,sp,48
    80003f26:	892a                	mv	s2,a0
    80003f28:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f2a:	0001e497          	auipc	s1,0x1e
    80003f2e:	9de48493          	addi	s1,s1,-1570 # 80021908 <log>
    80003f32:	00004597          	auipc	a1,0x4
    80003f36:	6ce58593          	addi	a1,a1,1742 # 80008600 <syscalls+0x1d8>
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	ffffd097          	auipc	ra,0xffffd
    80003f40:	c40080e7          	jalr	-960(ra) # 80000b7c <initlock>
  log.start = sb->logstart;
    80003f44:	0149a583          	lw	a1,20(s3)
    80003f48:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f4a:	0109a783          	lw	a5,16(s3)
    80003f4e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f50:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f54:	854a                	mv	a0,s2
    80003f56:	fffff097          	auipc	ra,0xfffff
    80003f5a:	ea6080e7          	jalr	-346(ra) # 80002dfc <bread>
  log.lh.n = lh->n;
    80003f5e:	4d34                	lw	a3,88(a0)
    80003f60:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f62:	02d05563          	blez	a3,80003f8c <initlog+0x74>
    80003f66:	05c50793          	addi	a5,a0,92
    80003f6a:	0001e717          	auipc	a4,0x1e
    80003f6e:	9ce70713          	addi	a4,a4,-1586 # 80021938 <log+0x30>
    80003f72:	36fd                	addiw	a3,a3,-1
    80003f74:	1682                	slli	a3,a3,0x20
    80003f76:	9281                	srli	a3,a3,0x20
    80003f78:	068a                	slli	a3,a3,0x2
    80003f7a:	06050613          	addi	a2,a0,96
    80003f7e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003f80:	4390                	lw	a2,0(a5)
    80003f82:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f84:	0791                	addi	a5,a5,4
    80003f86:	0711                	addi	a4,a4,4
    80003f88:	fed79ce3          	bne	a5,a3,80003f80 <initlog+0x68>
  brelse(buf);
    80003f8c:	fffff097          	auipc	ra,0xfffff
    80003f90:	fa0080e7          	jalr	-96(ra) # 80002f2c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80003f94:	00000097          	auipc	ra,0x0
    80003f98:	ece080e7          	jalr	-306(ra) # 80003e62 <install_trans>
  log.lh.n = 0;
    80003f9c:	0001e797          	auipc	a5,0x1e
    80003fa0:	9807ac23          	sw	zero,-1640(a5) # 80021934 <log+0x2c>
  write_head(); // clear the log
    80003fa4:	00000097          	auipc	ra,0x0
    80003fa8:	e44080e7          	jalr	-444(ra) # 80003de8 <write_head>
}
    80003fac:	70a2                	ld	ra,40(sp)
    80003fae:	7402                	ld	s0,32(sp)
    80003fb0:	64e2                	ld	s1,24(sp)
    80003fb2:	6942                	ld	s2,16(sp)
    80003fb4:	69a2                	ld	s3,8(sp)
    80003fb6:	6145                	addi	sp,sp,48
    80003fb8:	8082                	ret

0000000080003fba <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003fba:	1101                	addi	sp,sp,-32
    80003fbc:	ec06                	sd	ra,24(sp)
    80003fbe:	e822                	sd	s0,16(sp)
    80003fc0:	e426                	sd	s1,8(sp)
    80003fc2:	e04a                	sd	s2,0(sp)
    80003fc4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003fc6:	0001e517          	auipc	a0,0x1e
    80003fca:	94250513          	addi	a0,a0,-1726 # 80021908 <log>
    80003fce:	ffffd097          	auipc	ra,0xffffd
    80003fd2:	c3e080e7          	jalr	-962(ra) # 80000c0c <acquire>
  while(1){
    if(log.committing){
    80003fd6:	0001e497          	auipc	s1,0x1e
    80003fda:	93248493          	addi	s1,s1,-1742 # 80021908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003fde:	4979                	li	s2,30
    80003fe0:	a039                	j	80003fee <begin_op+0x34>
      sleep(&log, &log.lock);
    80003fe2:	85a6                	mv	a1,s1
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	ffffe097          	auipc	ra,0xffffe
    80003fea:	202080e7          	jalr	514(ra) # 800021e8 <sleep>
    if(log.committing){
    80003fee:	50dc                	lw	a5,36(s1)
    80003ff0:	fbed                	bnez	a5,80003fe2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ff2:	509c                	lw	a5,32(s1)
    80003ff4:	0017871b          	addiw	a4,a5,1
    80003ff8:	0007069b          	sext.w	a3,a4
    80003ffc:	0027179b          	slliw	a5,a4,0x2
    80004000:	9fb9                	addw	a5,a5,a4
    80004002:	0017979b          	slliw	a5,a5,0x1
    80004006:	54d8                	lw	a4,44(s1)
    80004008:	9fb9                	addw	a5,a5,a4
    8000400a:	00f95963          	bge	s2,a5,8000401c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000400e:	85a6                	mv	a1,s1
    80004010:	8526                	mv	a0,s1
    80004012:	ffffe097          	auipc	ra,0xffffe
    80004016:	1d6080e7          	jalr	470(ra) # 800021e8 <sleep>
    8000401a:	bfd1                	j	80003fee <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000401c:	0001e517          	auipc	a0,0x1e
    80004020:	8ec50513          	addi	a0,a0,-1812 # 80021908 <log>
    80004024:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004026:	ffffd097          	auipc	ra,0xffffd
    8000402a:	c9a080e7          	jalr	-870(ra) # 80000cc0 <release>
      break;
    }
  }
}
    8000402e:	60e2                	ld	ra,24(sp)
    80004030:	6442                	ld	s0,16(sp)
    80004032:	64a2                	ld	s1,8(sp)
    80004034:	6902                	ld	s2,0(sp)
    80004036:	6105                	addi	sp,sp,32
    80004038:	8082                	ret

000000008000403a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000403a:	7139                	addi	sp,sp,-64
    8000403c:	fc06                	sd	ra,56(sp)
    8000403e:	f822                	sd	s0,48(sp)
    80004040:	f426                	sd	s1,40(sp)
    80004042:	f04a                	sd	s2,32(sp)
    80004044:	ec4e                	sd	s3,24(sp)
    80004046:	e852                	sd	s4,16(sp)
    80004048:	e456                	sd	s5,8(sp)
    8000404a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000404c:	0001e497          	auipc	s1,0x1e
    80004050:	8bc48493          	addi	s1,s1,-1860 # 80021908 <log>
    80004054:	8526                	mv	a0,s1
    80004056:	ffffd097          	auipc	ra,0xffffd
    8000405a:	bb6080e7          	jalr	-1098(ra) # 80000c0c <acquire>
  log.outstanding -= 1;
    8000405e:	509c                	lw	a5,32(s1)
    80004060:	37fd                	addiw	a5,a5,-1
    80004062:	0007891b          	sext.w	s2,a5
    80004066:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004068:	50dc                	lw	a5,36(s1)
    8000406a:	e7b9                	bnez	a5,800040b8 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000406c:	04091e63          	bnez	s2,800040c8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004070:	0001e497          	auipc	s1,0x1e
    80004074:	89848493          	addi	s1,s1,-1896 # 80021908 <log>
    80004078:	4785                	li	a5,1
    8000407a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000407c:	8526                	mv	a0,s1
    8000407e:	ffffd097          	auipc	ra,0xffffd
    80004082:	c42080e7          	jalr	-958(ra) # 80000cc0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004086:	54dc                	lw	a5,44(s1)
    80004088:	06f04763          	bgtz	a5,800040f6 <end_op+0xbc>
    acquire(&log.lock);
    8000408c:	0001e497          	auipc	s1,0x1e
    80004090:	87c48493          	addi	s1,s1,-1924 # 80021908 <log>
    80004094:	8526                	mv	a0,s1
    80004096:	ffffd097          	auipc	ra,0xffffd
    8000409a:	b76080e7          	jalr	-1162(ra) # 80000c0c <acquire>
    log.committing = 0;
    8000409e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800040a2:	8526                	mv	a0,s1
    800040a4:	ffffe097          	auipc	ra,0xffffe
    800040a8:	2c4080e7          	jalr	708(ra) # 80002368 <wakeup>
    release(&log.lock);
    800040ac:	8526                	mv	a0,s1
    800040ae:	ffffd097          	auipc	ra,0xffffd
    800040b2:	c12080e7          	jalr	-1006(ra) # 80000cc0 <release>
}
    800040b6:	a03d                	j	800040e4 <end_op+0xaa>
    panic("log.committing");
    800040b8:	00004517          	auipc	a0,0x4
    800040bc:	55050513          	addi	a0,a0,1360 # 80008608 <syscalls+0x1e0>
    800040c0:	ffffc097          	auipc	ra,0xffffc
    800040c4:	490080e7          	jalr	1168(ra) # 80000550 <panic>
    wakeup(&log);
    800040c8:	0001e497          	auipc	s1,0x1e
    800040cc:	84048493          	addi	s1,s1,-1984 # 80021908 <log>
    800040d0:	8526                	mv	a0,s1
    800040d2:	ffffe097          	auipc	ra,0xffffe
    800040d6:	296080e7          	jalr	662(ra) # 80002368 <wakeup>
  release(&log.lock);
    800040da:	8526                	mv	a0,s1
    800040dc:	ffffd097          	auipc	ra,0xffffd
    800040e0:	be4080e7          	jalr	-1052(ra) # 80000cc0 <release>
}
    800040e4:	70e2                	ld	ra,56(sp)
    800040e6:	7442                	ld	s0,48(sp)
    800040e8:	74a2                	ld	s1,40(sp)
    800040ea:	7902                	ld	s2,32(sp)
    800040ec:	69e2                	ld	s3,24(sp)
    800040ee:	6a42                	ld	s4,16(sp)
    800040f0:	6aa2                	ld	s5,8(sp)
    800040f2:	6121                	addi	sp,sp,64
    800040f4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800040f6:	0001ea97          	auipc	s5,0x1e
    800040fa:	842a8a93          	addi	s5,s5,-1982 # 80021938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800040fe:	0001ea17          	auipc	s4,0x1e
    80004102:	80aa0a13          	addi	s4,s4,-2038 # 80021908 <log>
    80004106:	018a2583          	lw	a1,24(s4)
    8000410a:	012585bb          	addw	a1,a1,s2
    8000410e:	2585                	addiw	a1,a1,1
    80004110:	028a2503          	lw	a0,40(s4)
    80004114:	fffff097          	auipc	ra,0xfffff
    80004118:	ce8080e7          	jalr	-792(ra) # 80002dfc <bread>
    8000411c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000411e:	000aa583          	lw	a1,0(s5)
    80004122:	028a2503          	lw	a0,40(s4)
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	cd6080e7          	jalr	-810(ra) # 80002dfc <bread>
    8000412e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004130:	40000613          	li	a2,1024
    80004134:	05850593          	addi	a1,a0,88
    80004138:	05848513          	addi	a0,s1,88
    8000413c:	ffffd097          	auipc	ra,0xffffd
    80004140:	c28080e7          	jalr	-984(ra) # 80000d64 <memmove>
    bwrite(to);  // write the log
    80004144:	8526                	mv	a0,s1
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	da8080e7          	jalr	-600(ra) # 80002eee <bwrite>
    brelse(from);
    8000414e:	854e                	mv	a0,s3
    80004150:	fffff097          	auipc	ra,0xfffff
    80004154:	ddc080e7          	jalr	-548(ra) # 80002f2c <brelse>
    brelse(to);
    80004158:	8526                	mv	a0,s1
    8000415a:	fffff097          	auipc	ra,0xfffff
    8000415e:	dd2080e7          	jalr	-558(ra) # 80002f2c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004162:	2905                	addiw	s2,s2,1
    80004164:	0a91                	addi	s5,s5,4
    80004166:	02ca2783          	lw	a5,44(s4)
    8000416a:	f8f94ee3          	blt	s2,a5,80004106 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	c7a080e7          	jalr	-902(ra) # 80003de8 <write_head>
    install_trans(); // Now install writes to home locations
    80004176:	00000097          	auipc	ra,0x0
    8000417a:	cec080e7          	jalr	-788(ra) # 80003e62 <install_trans>
    log.lh.n = 0;
    8000417e:	0001d797          	auipc	a5,0x1d
    80004182:	7a07ab23          	sw	zero,1974(a5) # 80021934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004186:	00000097          	auipc	ra,0x0
    8000418a:	c62080e7          	jalr	-926(ra) # 80003de8 <write_head>
    8000418e:	bdfd                	j	8000408c <end_op+0x52>

0000000080004190 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004190:	1101                	addi	sp,sp,-32
    80004192:	ec06                	sd	ra,24(sp)
    80004194:	e822                	sd	s0,16(sp)
    80004196:	e426                	sd	s1,8(sp)
    80004198:	e04a                	sd	s2,0(sp)
    8000419a:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000419c:	0001d717          	auipc	a4,0x1d
    800041a0:	79872703          	lw	a4,1944(a4) # 80021934 <log+0x2c>
    800041a4:	47f5                	li	a5,29
    800041a6:	08e7c063          	blt	a5,a4,80004226 <log_write+0x96>
    800041aa:	84aa                	mv	s1,a0
    800041ac:	0001d797          	auipc	a5,0x1d
    800041b0:	7787a783          	lw	a5,1912(a5) # 80021924 <log+0x1c>
    800041b4:	37fd                	addiw	a5,a5,-1
    800041b6:	06f75863          	bge	a4,a5,80004226 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041ba:	0001d797          	auipc	a5,0x1d
    800041be:	76e7a783          	lw	a5,1902(a5) # 80021928 <log+0x20>
    800041c2:	06f05a63          	blez	a5,80004236 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800041c6:	0001d917          	auipc	s2,0x1d
    800041ca:	74290913          	addi	s2,s2,1858 # 80021908 <log>
    800041ce:	854a                	mv	a0,s2
    800041d0:	ffffd097          	auipc	ra,0xffffd
    800041d4:	a3c080e7          	jalr	-1476(ra) # 80000c0c <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800041d8:	02c92603          	lw	a2,44(s2)
    800041dc:	06c05563          	blez	a2,80004246 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800041e0:	44cc                	lw	a1,12(s1)
    800041e2:	0001d717          	auipc	a4,0x1d
    800041e6:	75670713          	addi	a4,a4,1878 # 80021938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041ea:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800041ec:	4314                	lw	a3,0(a4)
    800041ee:	04b68d63          	beq	a3,a1,80004248 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800041f2:	2785                	addiw	a5,a5,1
    800041f4:	0711                	addi	a4,a4,4
    800041f6:	fec79be3          	bne	a5,a2,800041ec <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041fa:	0621                	addi	a2,a2,8
    800041fc:	060a                	slli	a2,a2,0x2
    800041fe:	0001d797          	auipc	a5,0x1d
    80004202:	70a78793          	addi	a5,a5,1802 # 80021908 <log>
    80004206:	963e                	add	a2,a2,a5
    80004208:	44dc                	lw	a5,12(s1)
    8000420a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000420c:	8526                	mv	a0,s1
    8000420e:	fffff097          	auipc	ra,0xfffff
    80004212:	dbc080e7          	jalr	-580(ra) # 80002fca <bpin>
    log.lh.n++;
    80004216:	0001d717          	auipc	a4,0x1d
    8000421a:	6f270713          	addi	a4,a4,1778 # 80021908 <log>
    8000421e:	575c                	lw	a5,44(a4)
    80004220:	2785                	addiw	a5,a5,1
    80004222:	d75c                	sw	a5,44(a4)
    80004224:	a83d                	j	80004262 <log_write+0xd2>
    panic("too big a transaction");
    80004226:	00004517          	auipc	a0,0x4
    8000422a:	3f250513          	addi	a0,a0,1010 # 80008618 <syscalls+0x1f0>
    8000422e:	ffffc097          	auipc	ra,0xffffc
    80004232:	322080e7          	jalr	802(ra) # 80000550 <panic>
    panic("log_write outside of trans");
    80004236:	00004517          	auipc	a0,0x4
    8000423a:	3fa50513          	addi	a0,a0,1018 # 80008630 <syscalls+0x208>
    8000423e:	ffffc097          	auipc	ra,0xffffc
    80004242:	312080e7          	jalr	786(ra) # 80000550 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004246:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004248:	00878713          	addi	a4,a5,8
    8000424c:	00271693          	slli	a3,a4,0x2
    80004250:	0001d717          	auipc	a4,0x1d
    80004254:	6b870713          	addi	a4,a4,1720 # 80021908 <log>
    80004258:	9736                	add	a4,a4,a3
    8000425a:	44d4                	lw	a3,12(s1)
    8000425c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000425e:	faf607e3          	beq	a2,a5,8000420c <log_write+0x7c>
  }
  release(&log.lock);
    80004262:	0001d517          	auipc	a0,0x1d
    80004266:	6a650513          	addi	a0,a0,1702 # 80021908 <log>
    8000426a:	ffffd097          	auipc	ra,0xffffd
    8000426e:	a56080e7          	jalr	-1450(ra) # 80000cc0 <release>
}
    80004272:	60e2                	ld	ra,24(sp)
    80004274:	6442                	ld	s0,16(sp)
    80004276:	64a2                	ld	s1,8(sp)
    80004278:	6902                	ld	s2,0(sp)
    8000427a:	6105                	addi	sp,sp,32
    8000427c:	8082                	ret

000000008000427e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000427e:	1101                	addi	sp,sp,-32
    80004280:	ec06                	sd	ra,24(sp)
    80004282:	e822                	sd	s0,16(sp)
    80004284:	e426                	sd	s1,8(sp)
    80004286:	e04a                	sd	s2,0(sp)
    80004288:	1000                	addi	s0,sp,32
    8000428a:	84aa                	mv	s1,a0
    8000428c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000428e:	00004597          	auipc	a1,0x4
    80004292:	3c258593          	addi	a1,a1,962 # 80008650 <syscalls+0x228>
    80004296:	0521                	addi	a0,a0,8
    80004298:	ffffd097          	auipc	ra,0xffffd
    8000429c:	8e4080e7          	jalr	-1820(ra) # 80000b7c <initlock>
  lk->name = name;
    800042a0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042a8:	0204a423          	sw	zero,40(s1)
}
    800042ac:	60e2                	ld	ra,24(sp)
    800042ae:	6442                	ld	s0,16(sp)
    800042b0:	64a2                	ld	s1,8(sp)
    800042b2:	6902                	ld	s2,0(sp)
    800042b4:	6105                	addi	sp,sp,32
    800042b6:	8082                	ret

00000000800042b8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042b8:	1101                	addi	sp,sp,-32
    800042ba:	ec06                	sd	ra,24(sp)
    800042bc:	e822                	sd	s0,16(sp)
    800042be:	e426                	sd	s1,8(sp)
    800042c0:	e04a                	sd	s2,0(sp)
    800042c2:	1000                	addi	s0,sp,32
    800042c4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042c6:	00850913          	addi	s2,a0,8
    800042ca:	854a                	mv	a0,s2
    800042cc:	ffffd097          	auipc	ra,0xffffd
    800042d0:	940080e7          	jalr	-1728(ra) # 80000c0c <acquire>
  while (lk->locked) {
    800042d4:	409c                	lw	a5,0(s1)
    800042d6:	cb89                	beqz	a5,800042e8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800042d8:	85ca                	mv	a1,s2
    800042da:	8526                	mv	a0,s1
    800042dc:	ffffe097          	auipc	ra,0xffffe
    800042e0:	f0c080e7          	jalr	-244(ra) # 800021e8 <sleep>
  while (lk->locked) {
    800042e4:	409c                	lw	a5,0(s1)
    800042e6:	fbed                	bnez	a5,800042d8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800042e8:	4785                	li	a5,1
    800042ea:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800042ec:	ffffd097          	auipc	ra,0xffffd
    800042f0:	6ec080e7          	jalr	1772(ra) # 800019d8 <myproc>
    800042f4:	5d1c                	lw	a5,56(a0)
    800042f6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800042f8:	854a                	mv	a0,s2
    800042fa:	ffffd097          	auipc	ra,0xffffd
    800042fe:	9c6080e7          	jalr	-1594(ra) # 80000cc0 <release>
}
    80004302:	60e2                	ld	ra,24(sp)
    80004304:	6442                	ld	s0,16(sp)
    80004306:	64a2                	ld	s1,8(sp)
    80004308:	6902                	ld	s2,0(sp)
    8000430a:	6105                	addi	sp,sp,32
    8000430c:	8082                	ret

000000008000430e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000430e:	1101                	addi	sp,sp,-32
    80004310:	ec06                	sd	ra,24(sp)
    80004312:	e822                	sd	s0,16(sp)
    80004314:	e426                	sd	s1,8(sp)
    80004316:	e04a                	sd	s2,0(sp)
    80004318:	1000                	addi	s0,sp,32
    8000431a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000431c:	00850913          	addi	s2,a0,8
    80004320:	854a                	mv	a0,s2
    80004322:	ffffd097          	auipc	ra,0xffffd
    80004326:	8ea080e7          	jalr	-1814(ra) # 80000c0c <acquire>
  lk->locked = 0;
    8000432a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000432e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004332:	8526                	mv	a0,s1
    80004334:	ffffe097          	auipc	ra,0xffffe
    80004338:	034080e7          	jalr	52(ra) # 80002368 <wakeup>
  release(&lk->lk);
    8000433c:	854a                	mv	a0,s2
    8000433e:	ffffd097          	auipc	ra,0xffffd
    80004342:	982080e7          	jalr	-1662(ra) # 80000cc0 <release>
}
    80004346:	60e2                	ld	ra,24(sp)
    80004348:	6442                	ld	s0,16(sp)
    8000434a:	64a2                	ld	s1,8(sp)
    8000434c:	6902                	ld	s2,0(sp)
    8000434e:	6105                	addi	sp,sp,32
    80004350:	8082                	ret

0000000080004352 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004352:	7179                	addi	sp,sp,-48
    80004354:	f406                	sd	ra,40(sp)
    80004356:	f022                	sd	s0,32(sp)
    80004358:	ec26                	sd	s1,24(sp)
    8000435a:	e84a                	sd	s2,16(sp)
    8000435c:	e44e                	sd	s3,8(sp)
    8000435e:	1800                	addi	s0,sp,48
    80004360:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004362:	00850913          	addi	s2,a0,8
    80004366:	854a                	mv	a0,s2
    80004368:	ffffd097          	auipc	ra,0xffffd
    8000436c:	8a4080e7          	jalr	-1884(ra) # 80000c0c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004370:	409c                	lw	a5,0(s1)
    80004372:	ef99                	bnez	a5,80004390 <holdingsleep+0x3e>
    80004374:	4481                	li	s1,0
  release(&lk->lk);
    80004376:	854a                	mv	a0,s2
    80004378:	ffffd097          	auipc	ra,0xffffd
    8000437c:	948080e7          	jalr	-1720(ra) # 80000cc0 <release>
  return r;
}
    80004380:	8526                	mv	a0,s1
    80004382:	70a2                	ld	ra,40(sp)
    80004384:	7402                	ld	s0,32(sp)
    80004386:	64e2                	ld	s1,24(sp)
    80004388:	6942                	ld	s2,16(sp)
    8000438a:	69a2                	ld	s3,8(sp)
    8000438c:	6145                	addi	sp,sp,48
    8000438e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004390:	0284a983          	lw	s3,40(s1)
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	644080e7          	jalr	1604(ra) # 800019d8 <myproc>
    8000439c:	5d04                	lw	s1,56(a0)
    8000439e:	413484b3          	sub	s1,s1,s3
    800043a2:	0014b493          	seqz	s1,s1
    800043a6:	bfc1                	j	80004376 <holdingsleep+0x24>

00000000800043a8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043a8:	1141                	addi	sp,sp,-16
    800043aa:	e406                	sd	ra,8(sp)
    800043ac:	e022                	sd	s0,0(sp)
    800043ae:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043b0:	00004597          	auipc	a1,0x4
    800043b4:	2b058593          	addi	a1,a1,688 # 80008660 <syscalls+0x238>
    800043b8:	0001d517          	auipc	a0,0x1d
    800043bc:	69850513          	addi	a0,a0,1688 # 80021a50 <ftable>
    800043c0:	ffffc097          	auipc	ra,0xffffc
    800043c4:	7bc080e7          	jalr	1980(ra) # 80000b7c <initlock>
}
    800043c8:	60a2                	ld	ra,8(sp)
    800043ca:	6402                	ld	s0,0(sp)
    800043cc:	0141                	addi	sp,sp,16
    800043ce:	8082                	ret

00000000800043d0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800043d0:	1101                	addi	sp,sp,-32
    800043d2:	ec06                	sd	ra,24(sp)
    800043d4:	e822                	sd	s0,16(sp)
    800043d6:	e426                	sd	s1,8(sp)
    800043d8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800043da:	0001d517          	auipc	a0,0x1d
    800043de:	67650513          	addi	a0,a0,1654 # 80021a50 <ftable>
    800043e2:	ffffd097          	auipc	ra,0xffffd
    800043e6:	82a080e7          	jalr	-2006(ra) # 80000c0c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043ea:	0001d497          	auipc	s1,0x1d
    800043ee:	67e48493          	addi	s1,s1,1662 # 80021a68 <ftable+0x18>
    800043f2:	0001e717          	auipc	a4,0x1e
    800043f6:	61670713          	addi	a4,a4,1558 # 80022a08 <ftable+0xfb8>
    if(f->ref == 0){
    800043fa:	40dc                	lw	a5,4(s1)
    800043fc:	cf99                	beqz	a5,8000441a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043fe:	02848493          	addi	s1,s1,40
    80004402:	fee49ce3          	bne	s1,a4,800043fa <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004406:	0001d517          	auipc	a0,0x1d
    8000440a:	64a50513          	addi	a0,a0,1610 # 80021a50 <ftable>
    8000440e:	ffffd097          	auipc	ra,0xffffd
    80004412:	8b2080e7          	jalr	-1870(ra) # 80000cc0 <release>
  return 0;
    80004416:	4481                	li	s1,0
    80004418:	a819                	j	8000442e <filealloc+0x5e>
      f->ref = 1;
    8000441a:	4785                	li	a5,1
    8000441c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000441e:	0001d517          	auipc	a0,0x1d
    80004422:	63250513          	addi	a0,a0,1586 # 80021a50 <ftable>
    80004426:	ffffd097          	auipc	ra,0xffffd
    8000442a:	89a080e7          	jalr	-1894(ra) # 80000cc0 <release>
}
    8000442e:	8526                	mv	a0,s1
    80004430:	60e2                	ld	ra,24(sp)
    80004432:	6442                	ld	s0,16(sp)
    80004434:	64a2                	ld	s1,8(sp)
    80004436:	6105                	addi	sp,sp,32
    80004438:	8082                	ret

000000008000443a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000443a:	1101                	addi	sp,sp,-32
    8000443c:	ec06                	sd	ra,24(sp)
    8000443e:	e822                	sd	s0,16(sp)
    80004440:	e426                	sd	s1,8(sp)
    80004442:	1000                	addi	s0,sp,32
    80004444:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004446:	0001d517          	auipc	a0,0x1d
    8000444a:	60a50513          	addi	a0,a0,1546 # 80021a50 <ftable>
    8000444e:	ffffc097          	auipc	ra,0xffffc
    80004452:	7be080e7          	jalr	1982(ra) # 80000c0c <acquire>
  if(f->ref < 1)
    80004456:	40dc                	lw	a5,4(s1)
    80004458:	02f05263          	blez	a5,8000447c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000445c:	2785                	addiw	a5,a5,1
    8000445e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004460:	0001d517          	auipc	a0,0x1d
    80004464:	5f050513          	addi	a0,a0,1520 # 80021a50 <ftable>
    80004468:	ffffd097          	auipc	ra,0xffffd
    8000446c:	858080e7          	jalr	-1960(ra) # 80000cc0 <release>
  return f;
}
    80004470:	8526                	mv	a0,s1
    80004472:	60e2                	ld	ra,24(sp)
    80004474:	6442                	ld	s0,16(sp)
    80004476:	64a2                	ld	s1,8(sp)
    80004478:	6105                	addi	sp,sp,32
    8000447a:	8082                	ret
    panic("filedup");
    8000447c:	00004517          	auipc	a0,0x4
    80004480:	1ec50513          	addi	a0,a0,492 # 80008668 <syscalls+0x240>
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	0cc080e7          	jalr	204(ra) # 80000550 <panic>

000000008000448c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000448c:	7139                	addi	sp,sp,-64
    8000448e:	fc06                	sd	ra,56(sp)
    80004490:	f822                	sd	s0,48(sp)
    80004492:	f426                	sd	s1,40(sp)
    80004494:	f04a                	sd	s2,32(sp)
    80004496:	ec4e                	sd	s3,24(sp)
    80004498:	e852                	sd	s4,16(sp)
    8000449a:	e456                	sd	s5,8(sp)
    8000449c:	0080                	addi	s0,sp,64
    8000449e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044a0:	0001d517          	auipc	a0,0x1d
    800044a4:	5b050513          	addi	a0,a0,1456 # 80021a50 <ftable>
    800044a8:	ffffc097          	auipc	ra,0xffffc
    800044ac:	764080e7          	jalr	1892(ra) # 80000c0c <acquire>
  if(f->ref < 1)
    800044b0:	40dc                	lw	a5,4(s1)
    800044b2:	06f05163          	blez	a5,80004514 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800044b6:	37fd                	addiw	a5,a5,-1
    800044b8:	0007871b          	sext.w	a4,a5
    800044bc:	c0dc                	sw	a5,4(s1)
    800044be:	06e04363          	bgtz	a4,80004524 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044c2:	0004a903          	lw	s2,0(s1)
    800044c6:	0094ca83          	lbu	s5,9(s1)
    800044ca:	0104ba03          	ld	s4,16(s1)
    800044ce:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800044d2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800044d6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800044da:	0001d517          	auipc	a0,0x1d
    800044de:	57650513          	addi	a0,a0,1398 # 80021a50 <ftable>
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	7de080e7          	jalr	2014(ra) # 80000cc0 <release>

  if(ff.type == FD_PIPE){
    800044ea:	4785                	li	a5,1
    800044ec:	04f90d63          	beq	s2,a5,80004546 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800044f0:	3979                	addiw	s2,s2,-2
    800044f2:	4785                	li	a5,1
    800044f4:	0527e063          	bltu	a5,s2,80004534 <fileclose+0xa8>
    begin_op();
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	ac2080e7          	jalr	-1342(ra) # 80003fba <begin_op>
    iput(ff.ip);
    80004500:	854e                	mv	a0,s3
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	2b6080e7          	jalr	694(ra) # 800037b8 <iput>
    end_op();
    8000450a:	00000097          	auipc	ra,0x0
    8000450e:	b30080e7          	jalr	-1232(ra) # 8000403a <end_op>
    80004512:	a00d                	j	80004534 <fileclose+0xa8>
    panic("fileclose");
    80004514:	00004517          	auipc	a0,0x4
    80004518:	15c50513          	addi	a0,a0,348 # 80008670 <syscalls+0x248>
    8000451c:	ffffc097          	auipc	ra,0xffffc
    80004520:	034080e7          	jalr	52(ra) # 80000550 <panic>
    release(&ftable.lock);
    80004524:	0001d517          	auipc	a0,0x1d
    80004528:	52c50513          	addi	a0,a0,1324 # 80021a50 <ftable>
    8000452c:	ffffc097          	auipc	ra,0xffffc
    80004530:	794080e7          	jalr	1940(ra) # 80000cc0 <release>
  }
}
    80004534:	70e2                	ld	ra,56(sp)
    80004536:	7442                	ld	s0,48(sp)
    80004538:	74a2                	ld	s1,40(sp)
    8000453a:	7902                	ld	s2,32(sp)
    8000453c:	69e2                	ld	s3,24(sp)
    8000453e:	6a42                	ld	s4,16(sp)
    80004540:	6aa2                	ld	s5,8(sp)
    80004542:	6121                	addi	sp,sp,64
    80004544:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004546:	85d6                	mv	a1,s5
    80004548:	8552                	mv	a0,s4
    8000454a:	00000097          	auipc	ra,0x0
    8000454e:	372080e7          	jalr	882(ra) # 800048bc <pipeclose>
    80004552:	b7cd                	j	80004534 <fileclose+0xa8>

0000000080004554 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004554:	715d                	addi	sp,sp,-80
    80004556:	e486                	sd	ra,72(sp)
    80004558:	e0a2                	sd	s0,64(sp)
    8000455a:	fc26                	sd	s1,56(sp)
    8000455c:	f84a                	sd	s2,48(sp)
    8000455e:	f44e                	sd	s3,40(sp)
    80004560:	0880                	addi	s0,sp,80
    80004562:	84aa                	mv	s1,a0
    80004564:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004566:	ffffd097          	auipc	ra,0xffffd
    8000456a:	472080e7          	jalr	1138(ra) # 800019d8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000456e:	409c                	lw	a5,0(s1)
    80004570:	37f9                	addiw	a5,a5,-2
    80004572:	4705                	li	a4,1
    80004574:	04f76763          	bltu	a4,a5,800045c2 <filestat+0x6e>
    80004578:	892a                	mv	s2,a0
    ilock(f->ip);
    8000457a:	6c88                	ld	a0,24(s1)
    8000457c:	fffff097          	auipc	ra,0xfffff
    80004580:	082080e7          	jalr	130(ra) # 800035fe <ilock>
    stati(f->ip, &st);
    80004584:	fb840593          	addi	a1,s0,-72
    80004588:	6c88                	ld	a0,24(s1)
    8000458a:	fffff097          	auipc	ra,0xfffff
    8000458e:	2fe080e7          	jalr	766(ra) # 80003888 <stati>
    iunlock(f->ip);
    80004592:	6c88                	ld	a0,24(s1)
    80004594:	fffff097          	auipc	ra,0xfffff
    80004598:	12c080e7          	jalr	300(ra) # 800036c0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000459c:	46e1                	li	a3,24
    8000459e:	fb840613          	addi	a2,s0,-72
    800045a2:	85ce                	mv	a1,s3
    800045a4:	05093503          	ld	a0,80(s2)
    800045a8:	ffffd097          	auipc	ra,0xffffd
    800045ac:	122080e7          	jalr	290(ra) # 800016ca <copyout>
    800045b0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045b4:	60a6                	ld	ra,72(sp)
    800045b6:	6406                	ld	s0,64(sp)
    800045b8:	74e2                	ld	s1,56(sp)
    800045ba:	7942                	ld	s2,48(sp)
    800045bc:	79a2                	ld	s3,40(sp)
    800045be:	6161                	addi	sp,sp,80
    800045c0:	8082                	ret
  return -1;
    800045c2:	557d                	li	a0,-1
    800045c4:	bfc5                	j	800045b4 <filestat+0x60>

00000000800045c6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045c6:	7179                	addi	sp,sp,-48
    800045c8:	f406                	sd	ra,40(sp)
    800045ca:	f022                	sd	s0,32(sp)
    800045cc:	ec26                	sd	s1,24(sp)
    800045ce:	e84a                	sd	s2,16(sp)
    800045d0:	e44e                	sd	s3,8(sp)
    800045d2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800045d4:	00854783          	lbu	a5,8(a0)
    800045d8:	c3d5                	beqz	a5,8000467c <fileread+0xb6>
    800045da:	84aa                	mv	s1,a0
    800045dc:	89ae                	mv	s3,a1
    800045de:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800045e0:	411c                	lw	a5,0(a0)
    800045e2:	4705                	li	a4,1
    800045e4:	04e78963          	beq	a5,a4,80004636 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045e8:	470d                	li	a4,3
    800045ea:	04e78d63          	beq	a5,a4,80004644 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800045ee:	4709                	li	a4,2
    800045f0:	06e79e63          	bne	a5,a4,8000466c <fileread+0xa6>
    ilock(f->ip);
    800045f4:	6d08                	ld	a0,24(a0)
    800045f6:	fffff097          	auipc	ra,0xfffff
    800045fa:	008080e7          	jalr	8(ra) # 800035fe <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800045fe:	874a                	mv	a4,s2
    80004600:	5094                	lw	a3,32(s1)
    80004602:	864e                	mv	a2,s3
    80004604:	4585                	li	a1,1
    80004606:	6c88                	ld	a0,24(s1)
    80004608:	fffff097          	auipc	ra,0xfffff
    8000460c:	2aa080e7          	jalr	682(ra) # 800038b2 <readi>
    80004610:	892a                	mv	s2,a0
    80004612:	00a05563          	blez	a0,8000461c <fileread+0x56>
      f->off += r;
    80004616:	509c                	lw	a5,32(s1)
    80004618:	9fa9                	addw	a5,a5,a0
    8000461a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000461c:	6c88                	ld	a0,24(s1)
    8000461e:	fffff097          	auipc	ra,0xfffff
    80004622:	0a2080e7          	jalr	162(ra) # 800036c0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004626:	854a                	mv	a0,s2
    80004628:	70a2                	ld	ra,40(sp)
    8000462a:	7402                	ld	s0,32(sp)
    8000462c:	64e2                	ld	s1,24(sp)
    8000462e:	6942                	ld	s2,16(sp)
    80004630:	69a2                	ld	s3,8(sp)
    80004632:	6145                	addi	sp,sp,48
    80004634:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004636:	6908                	ld	a0,16(a0)
    80004638:	00000097          	auipc	ra,0x0
    8000463c:	3f4080e7          	jalr	1012(ra) # 80004a2c <piperead>
    80004640:	892a                	mv	s2,a0
    80004642:	b7d5                	j	80004626 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004644:	02451783          	lh	a5,36(a0)
    80004648:	03079693          	slli	a3,a5,0x30
    8000464c:	92c1                	srli	a3,a3,0x30
    8000464e:	4725                	li	a4,9
    80004650:	02d76863          	bltu	a4,a3,80004680 <fileread+0xba>
    80004654:	0792                	slli	a5,a5,0x4
    80004656:	0001d717          	auipc	a4,0x1d
    8000465a:	35a70713          	addi	a4,a4,858 # 800219b0 <devsw>
    8000465e:	97ba                	add	a5,a5,a4
    80004660:	639c                	ld	a5,0(a5)
    80004662:	c38d                	beqz	a5,80004684 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004664:	4505                	li	a0,1
    80004666:	9782                	jalr	a5
    80004668:	892a                	mv	s2,a0
    8000466a:	bf75                	j	80004626 <fileread+0x60>
    panic("fileread");
    8000466c:	00004517          	auipc	a0,0x4
    80004670:	01450513          	addi	a0,a0,20 # 80008680 <syscalls+0x258>
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	edc080e7          	jalr	-292(ra) # 80000550 <panic>
    return -1;
    8000467c:	597d                	li	s2,-1
    8000467e:	b765                	j	80004626 <fileread+0x60>
      return -1;
    80004680:	597d                	li	s2,-1
    80004682:	b755                	j	80004626 <fileread+0x60>
    80004684:	597d                	li	s2,-1
    80004686:	b745                	j	80004626 <fileread+0x60>

0000000080004688 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004688:	00954783          	lbu	a5,9(a0)
    8000468c:	14078563          	beqz	a5,800047d6 <filewrite+0x14e>
{
    80004690:	715d                	addi	sp,sp,-80
    80004692:	e486                	sd	ra,72(sp)
    80004694:	e0a2                	sd	s0,64(sp)
    80004696:	fc26                	sd	s1,56(sp)
    80004698:	f84a                	sd	s2,48(sp)
    8000469a:	f44e                	sd	s3,40(sp)
    8000469c:	f052                	sd	s4,32(sp)
    8000469e:	ec56                	sd	s5,24(sp)
    800046a0:	e85a                	sd	s6,16(sp)
    800046a2:	e45e                	sd	s7,8(sp)
    800046a4:	e062                	sd	s8,0(sp)
    800046a6:	0880                	addi	s0,sp,80
    800046a8:	892a                	mv	s2,a0
    800046aa:	8aae                	mv	s5,a1
    800046ac:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046ae:	411c                	lw	a5,0(a0)
    800046b0:	4705                	li	a4,1
    800046b2:	02e78263          	beq	a5,a4,800046d6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046b6:	470d                	li	a4,3
    800046b8:	02e78563          	beq	a5,a4,800046e2 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046bc:	4709                	li	a4,2
    800046be:	10e79463          	bne	a5,a4,800047c6 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800046c2:	0ec05e63          	blez	a2,800047be <filewrite+0x136>
    int i = 0;
    800046c6:	4981                	li	s3,0
    800046c8:	6b05                	lui	s6,0x1
    800046ca:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800046ce:	6b85                	lui	s7,0x1
    800046d0:	c00b8b9b          	addiw	s7,s7,-1024
    800046d4:	a851                	j	80004768 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800046d6:	6908                	ld	a0,16(a0)
    800046d8:	00000097          	auipc	ra,0x0
    800046dc:	254080e7          	jalr	596(ra) # 8000492c <pipewrite>
    800046e0:	a85d                	j	80004796 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800046e2:	02451783          	lh	a5,36(a0)
    800046e6:	03079693          	slli	a3,a5,0x30
    800046ea:	92c1                	srli	a3,a3,0x30
    800046ec:	4725                	li	a4,9
    800046ee:	0ed76663          	bltu	a4,a3,800047da <filewrite+0x152>
    800046f2:	0792                	slli	a5,a5,0x4
    800046f4:	0001d717          	auipc	a4,0x1d
    800046f8:	2bc70713          	addi	a4,a4,700 # 800219b0 <devsw>
    800046fc:	97ba                	add	a5,a5,a4
    800046fe:	679c                	ld	a5,8(a5)
    80004700:	cff9                	beqz	a5,800047de <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004702:	4505                	li	a0,1
    80004704:	9782                	jalr	a5
    80004706:	a841                	j	80004796 <filewrite+0x10e>
    80004708:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000470c:	00000097          	auipc	ra,0x0
    80004710:	8ae080e7          	jalr	-1874(ra) # 80003fba <begin_op>
      ilock(f->ip);
    80004714:	01893503          	ld	a0,24(s2)
    80004718:	fffff097          	auipc	ra,0xfffff
    8000471c:	ee6080e7          	jalr	-282(ra) # 800035fe <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004720:	8762                	mv	a4,s8
    80004722:	02092683          	lw	a3,32(s2)
    80004726:	01598633          	add	a2,s3,s5
    8000472a:	4585                	li	a1,1
    8000472c:	01893503          	ld	a0,24(s2)
    80004730:	fffff097          	auipc	ra,0xfffff
    80004734:	278080e7          	jalr	632(ra) # 800039a8 <writei>
    80004738:	84aa                	mv	s1,a0
    8000473a:	02a05f63          	blez	a0,80004778 <filewrite+0xf0>
        f->off += r;
    8000473e:	02092783          	lw	a5,32(s2)
    80004742:	9fa9                	addw	a5,a5,a0
    80004744:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004748:	01893503          	ld	a0,24(s2)
    8000474c:	fffff097          	auipc	ra,0xfffff
    80004750:	f74080e7          	jalr	-140(ra) # 800036c0 <iunlock>
      end_op();
    80004754:	00000097          	auipc	ra,0x0
    80004758:	8e6080e7          	jalr	-1818(ra) # 8000403a <end_op>

      if(r < 0)
        break;
      if(r != n1)
    8000475c:	049c1963          	bne	s8,s1,800047ae <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004760:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004764:	0349d663          	bge	s3,s4,80004790 <filewrite+0x108>
      int n1 = n - i;
    80004768:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000476c:	84be                	mv	s1,a5
    8000476e:	2781                	sext.w	a5,a5
    80004770:	f8fb5ce3          	bge	s6,a5,80004708 <filewrite+0x80>
    80004774:	84de                	mv	s1,s7
    80004776:	bf49                	j	80004708 <filewrite+0x80>
      iunlock(f->ip);
    80004778:	01893503          	ld	a0,24(s2)
    8000477c:	fffff097          	auipc	ra,0xfffff
    80004780:	f44080e7          	jalr	-188(ra) # 800036c0 <iunlock>
      end_op();
    80004784:	00000097          	auipc	ra,0x0
    80004788:	8b6080e7          	jalr	-1866(ra) # 8000403a <end_op>
      if(r < 0)
    8000478c:	fc04d8e3          	bgez	s1,8000475c <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004790:	8552                	mv	a0,s4
    80004792:	033a1863          	bne	s4,s3,800047c2 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004796:	60a6                	ld	ra,72(sp)
    80004798:	6406                	ld	s0,64(sp)
    8000479a:	74e2                	ld	s1,56(sp)
    8000479c:	7942                	ld	s2,48(sp)
    8000479e:	79a2                	ld	s3,40(sp)
    800047a0:	7a02                	ld	s4,32(sp)
    800047a2:	6ae2                	ld	s5,24(sp)
    800047a4:	6b42                	ld	s6,16(sp)
    800047a6:	6ba2                	ld	s7,8(sp)
    800047a8:	6c02                	ld	s8,0(sp)
    800047aa:	6161                	addi	sp,sp,80
    800047ac:	8082                	ret
        panic("short filewrite");
    800047ae:	00004517          	auipc	a0,0x4
    800047b2:	ee250513          	addi	a0,a0,-286 # 80008690 <syscalls+0x268>
    800047b6:	ffffc097          	auipc	ra,0xffffc
    800047ba:	d9a080e7          	jalr	-614(ra) # 80000550 <panic>
    int i = 0;
    800047be:	4981                	li	s3,0
    800047c0:	bfc1                	j	80004790 <filewrite+0x108>
    ret = (i == n ? n : -1);
    800047c2:	557d                	li	a0,-1
    800047c4:	bfc9                	j	80004796 <filewrite+0x10e>
    panic("filewrite");
    800047c6:	00004517          	auipc	a0,0x4
    800047ca:	eda50513          	addi	a0,a0,-294 # 800086a0 <syscalls+0x278>
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	d82080e7          	jalr	-638(ra) # 80000550 <panic>
    return -1;
    800047d6:	557d                	li	a0,-1
}
    800047d8:	8082                	ret
      return -1;
    800047da:	557d                	li	a0,-1
    800047dc:	bf6d                	j	80004796 <filewrite+0x10e>
    800047de:	557d                	li	a0,-1
    800047e0:	bf5d                	j	80004796 <filewrite+0x10e>

00000000800047e2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800047e2:	7179                	addi	sp,sp,-48
    800047e4:	f406                	sd	ra,40(sp)
    800047e6:	f022                	sd	s0,32(sp)
    800047e8:	ec26                	sd	s1,24(sp)
    800047ea:	e84a                	sd	s2,16(sp)
    800047ec:	e44e                	sd	s3,8(sp)
    800047ee:	e052                	sd	s4,0(sp)
    800047f0:	1800                	addi	s0,sp,48
    800047f2:	84aa                	mv	s1,a0
    800047f4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800047f6:	0005b023          	sd	zero,0(a1)
    800047fa:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800047fe:	00000097          	auipc	ra,0x0
    80004802:	bd2080e7          	jalr	-1070(ra) # 800043d0 <filealloc>
    80004806:	e088                	sd	a0,0(s1)
    80004808:	c551                	beqz	a0,80004894 <pipealloc+0xb2>
    8000480a:	00000097          	auipc	ra,0x0
    8000480e:	bc6080e7          	jalr	-1082(ra) # 800043d0 <filealloc>
    80004812:	00aa3023          	sd	a0,0(s4)
    80004816:	c92d                	beqz	a0,80004888 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	304080e7          	jalr	772(ra) # 80000b1c <kalloc>
    80004820:	892a                	mv	s2,a0
    80004822:	c125                	beqz	a0,80004882 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004824:	4985                	li	s3,1
    80004826:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000482a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000482e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004832:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004836:	00004597          	auipc	a1,0x4
    8000483a:	e7a58593          	addi	a1,a1,-390 # 800086b0 <syscalls+0x288>
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	33e080e7          	jalr	830(ra) # 80000b7c <initlock>
  (*f0)->type = FD_PIPE;
    80004846:	609c                	ld	a5,0(s1)
    80004848:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000484c:	609c                	ld	a5,0(s1)
    8000484e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004852:	609c                	ld	a5,0(s1)
    80004854:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004858:	609c                	ld	a5,0(s1)
    8000485a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000485e:	000a3783          	ld	a5,0(s4)
    80004862:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004866:	000a3783          	ld	a5,0(s4)
    8000486a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000486e:	000a3783          	ld	a5,0(s4)
    80004872:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004876:	000a3783          	ld	a5,0(s4)
    8000487a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000487e:	4501                	li	a0,0
    80004880:	a025                	j	800048a8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004882:	6088                	ld	a0,0(s1)
    80004884:	e501                	bnez	a0,8000488c <pipealloc+0xaa>
    80004886:	a039                	j	80004894 <pipealloc+0xb2>
    80004888:	6088                	ld	a0,0(s1)
    8000488a:	c51d                	beqz	a0,800048b8 <pipealloc+0xd6>
    fileclose(*f0);
    8000488c:	00000097          	auipc	ra,0x0
    80004890:	c00080e7          	jalr	-1024(ra) # 8000448c <fileclose>
  if(*f1)
    80004894:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004898:	557d                	li	a0,-1
  if(*f1)
    8000489a:	c799                	beqz	a5,800048a8 <pipealloc+0xc6>
    fileclose(*f1);
    8000489c:	853e                	mv	a0,a5
    8000489e:	00000097          	auipc	ra,0x0
    800048a2:	bee080e7          	jalr	-1042(ra) # 8000448c <fileclose>
  return -1;
    800048a6:	557d                	li	a0,-1
}
    800048a8:	70a2                	ld	ra,40(sp)
    800048aa:	7402                	ld	s0,32(sp)
    800048ac:	64e2                	ld	s1,24(sp)
    800048ae:	6942                	ld	s2,16(sp)
    800048b0:	69a2                	ld	s3,8(sp)
    800048b2:	6a02                	ld	s4,0(sp)
    800048b4:	6145                	addi	sp,sp,48
    800048b6:	8082                	ret
  return -1;
    800048b8:	557d                	li	a0,-1
    800048ba:	b7fd                	j	800048a8 <pipealloc+0xc6>

00000000800048bc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048bc:	1101                	addi	sp,sp,-32
    800048be:	ec06                	sd	ra,24(sp)
    800048c0:	e822                	sd	s0,16(sp)
    800048c2:	e426                	sd	s1,8(sp)
    800048c4:	e04a                	sd	s2,0(sp)
    800048c6:	1000                	addi	s0,sp,32
    800048c8:	84aa                	mv	s1,a0
    800048ca:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048cc:	ffffc097          	auipc	ra,0xffffc
    800048d0:	340080e7          	jalr	832(ra) # 80000c0c <acquire>
  if(writable){
    800048d4:	02090d63          	beqz	s2,8000490e <pipeclose+0x52>
    pi->writeopen = 0;
    800048d8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048dc:	21848513          	addi	a0,s1,536
    800048e0:	ffffe097          	auipc	ra,0xffffe
    800048e4:	a88080e7          	jalr	-1400(ra) # 80002368 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800048e8:	2204b783          	ld	a5,544(s1)
    800048ec:	eb95                	bnez	a5,80004920 <pipeclose+0x64>
    release(&pi->lock);
    800048ee:	8526                	mv	a0,s1
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	3d0080e7          	jalr	976(ra) # 80000cc0 <release>
    kfree((char*)pi);
    800048f8:	8526                	mv	a0,s1
    800048fa:	ffffc097          	auipc	ra,0xffffc
    800048fe:	126080e7          	jalr	294(ra) # 80000a20 <kfree>
  } else
    release(&pi->lock);
}
    80004902:	60e2                	ld	ra,24(sp)
    80004904:	6442                	ld	s0,16(sp)
    80004906:	64a2                	ld	s1,8(sp)
    80004908:	6902                	ld	s2,0(sp)
    8000490a:	6105                	addi	sp,sp,32
    8000490c:	8082                	ret
    pi->readopen = 0;
    8000490e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004912:	21c48513          	addi	a0,s1,540
    80004916:	ffffe097          	auipc	ra,0xffffe
    8000491a:	a52080e7          	jalr	-1454(ra) # 80002368 <wakeup>
    8000491e:	b7e9                	j	800048e8 <pipeclose+0x2c>
    release(&pi->lock);
    80004920:	8526                	mv	a0,s1
    80004922:	ffffc097          	auipc	ra,0xffffc
    80004926:	39e080e7          	jalr	926(ra) # 80000cc0 <release>
}
    8000492a:	bfe1                	j	80004902 <pipeclose+0x46>

000000008000492c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000492c:	711d                	addi	sp,sp,-96
    8000492e:	ec86                	sd	ra,88(sp)
    80004930:	e8a2                	sd	s0,80(sp)
    80004932:	e4a6                	sd	s1,72(sp)
    80004934:	e0ca                	sd	s2,64(sp)
    80004936:	fc4e                	sd	s3,56(sp)
    80004938:	f852                	sd	s4,48(sp)
    8000493a:	f456                	sd	s5,40(sp)
    8000493c:	f05a                	sd	s6,32(sp)
    8000493e:	ec5e                	sd	s7,24(sp)
    80004940:	e862                	sd	s8,16(sp)
    80004942:	1080                	addi	s0,sp,96
    80004944:	84aa                	mv	s1,a0
    80004946:	8b2e                	mv	s6,a1
    80004948:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    8000494a:	ffffd097          	auipc	ra,0xffffd
    8000494e:	08e080e7          	jalr	142(ra) # 800019d8 <myproc>
    80004952:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004954:	8526                	mv	a0,s1
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	2b6080e7          	jalr	694(ra) # 80000c0c <acquire>
  for(i = 0; i < n; i++){
    8000495e:	09505763          	blez	s5,800049ec <pipewrite+0xc0>
    80004962:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004964:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004968:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000496c:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    8000496e:	2184a783          	lw	a5,536(s1)
    80004972:	21c4a703          	lw	a4,540(s1)
    80004976:	2007879b          	addiw	a5,a5,512
    8000497a:	02f71b63          	bne	a4,a5,800049b0 <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    8000497e:	2204a783          	lw	a5,544(s1)
    80004982:	c3d1                	beqz	a5,80004a06 <pipewrite+0xda>
    80004984:	03092783          	lw	a5,48(s2)
    80004988:	efbd                	bnez	a5,80004a06 <pipewrite+0xda>
      wakeup(&pi->nread);
    8000498a:	8552                	mv	a0,s4
    8000498c:	ffffe097          	auipc	ra,0xffffe
    80004990:	9dc080e7          	jalr	-1572(ra) # 80002368 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004994:	85a6                	mv	a1,s1
    80004996:	854e                	mv	a0,s3
    80004998:	ffffe097          	auipc	ra,0xffffe
    8000499c:	850080e7          	jalr	-1968(ra) # 800021e8 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800049a0:	2184a783          	lw	a5,536(s1)
    800049a4:	21c4a703          	lw	a4,540(s1)
    800049a8:	2007879b          	addiw	a5,a5,512
    800049ac:	fcf709e3          	beq	a4,a5,8000497e <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049b0:	4685                	li	a3,1
    800049b2:	865a                	mv	a2,s6
    800049b4:	faf40593          	addi	a1,s0,-81
    800049b8:	05093503          	ld	a0,80(s2)
    800049bc:	ffffd097          	auipc	ra,0xffffd
    800049c0:	d9a080e7          	jalr	-614(ra) # 80001756 <copyin>
    800049c4:	03850563          	beq	a0,s8,800049ee <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800049c8:	21c4a783          	lw	a5,540(s1)
    800049cc:	0017871b          	addiw	a4,a5,1
    800049d0:	20e4ae23          	sw	a4,540(s1)
    800049d4:	1ff7f793          	andi	a5,a5,511
    800049d8:	97a6                	add	a5,a5,s1
    800049da:	faf44703          	lbu	a4,-81(s0)
    800049de:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    800049e2:	2b85                	addiw	s7,s7,1
    800049e4:	0b05                	addi	s6,s6,1
    800049e6:	f97a94e3          	bne	s5,s7,8000496e <pipewrite+0x42>
    800049ea:	a011                	j	800049ee <pipewrite+0xc2>
    800049ec:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    800049ee:	21848513          	addi	a0,s1,536
    800049f2:	ffffe097          	auipc	ra,0xffffe
    800049f6:	976080e7          	jalr	-1674(ra) # 80002368 <wakeup>
  release(&pi->lock);
    800049fa:	8526                	mv	a0,s1
    800049fc:	ffffc097          	auipc	ra,0xffffc
    80004a00:	2c4080e7          	jalr	708(ra) # 80000cc0 <release>
  return i;
    80004a04:	a039                	j	80004a12 <pipewrite+0xe6>
        release(&pi->lock);
    80004a06:	8526                	mv	a0,s1
    80004a08:	ffffc097          	auipc	ra,0xffffc
    80004a0c:	2b8080e7          	jalr	696(ra) # 80000cc0 <release>
        return -1;
    80004a10:	5bfd                	li	s7,-1
}
    80004a12:	855e                	mv	a0,s7
    80004a14:	60e6                	ld	ra,88(sp)
    80004a16:	6446                	ld	s0,80(sp)
    80004a18:	64a6                	ld	s1,72(sp)
    80004a1a:	6906                	ld	s2,64(sp)
    80004a1c:	79e2                	ld	s3,56(sp)
    80004a1e:	7a42                	ld	s4,48(sp)
    80004a20:	7aa2                	ld	s5,40(sp)
    80004a22:	7b02                	ld	s6,32(sp)
    80004a24:	6be2                	ld	s7,24(sp)
    80004a26:	6c42                	ld	s8,16(sp)
    80004a28:	6125                	addi	sp,sp,96
    80004a2a:	8082                	ret

0000000080004a2c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a2c:	715d                	addi	sp,sp,-80
    80004a2e:	e486                	sd	ra,72(sp)
    80004a30:	e0a2                	sd	s0,64(sp)
    80004a32:	fc26                	sd	s1,56(sp)
    80004a34:	f84a                	sd	s2,48(sp)
    80004a36:	f44e                	sd	s3,40(sp)
    80004a38:	f052                	sd	s4,32(sp)
    80004a3a:	ec56                	sd	s5,24(sp)
    80004a3c:	e85a                	sd	s6,16(sp)
    80004a3e:	0880                	addi	s0,sp,80
    80004a40:	84aa                	mv	s1,a0
    80004a42:	892e                	mv	s2,a1
    80004a44:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a46:	ffffd097          	auipc	ra,0xffffd
    80004a4a:	f92080e7          	jalr	-110(ra) # 800019d8 <myproc>
    80004a4e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a50:	8526                	mv	a0,s1
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	1ba080e7          	jalr	442(ra) # 80000c0c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a5a:	2184a703          	lw	a4,536(s1)
    80004a5e:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a62:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a66:	02f71463          	bne	a4,a5,80004a8e <piperead+0x62>
    80004a6a:	2244a783          	lw	a5,548(s1)
    80004a6e:	c385                	beqz	a5,80004a8e <piperead+0x62>
    if(pr->killed){
    80004a70:	030a2783          	lw	a5,48(s4)
    80004a74:	ebc1                	bnez	a5,80004b04 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a76:	85a6                	mv	a1,s1
    80004a78:	854e                	mv	a0,s3
    80004a7a:	ffffd097          	auipc	ra,0xffffd
    80004a7e:	76e080e7          	jalr	1902(ra) # 800021e8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a82:	2184a703          	lw	a4,536(s1)
    80004a86:	21c4a783          	lw	a5,540(s1)
    80004a8a:	fef700e3          	beq	a4,a5,80004a6a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a8e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a90:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a92:	05505363          	blez	s5,80004ad8 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004a96:	2184a783          	lw	a5,536(s1)
    80004a9a:	21c4a703          	lw	a4,540(s1)
    80004a9e:	02f70d63          	beq	a4,a5,80004ad8 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004aa2:	0017871b          	addiw	a4,a5,1
    80004aa6:	20e4ac23          	sw	a4,536(s1)
    80004aaa:	1ff7f793          	andi	a5,a5,511
    80004aae:	97a6                	add	a5,a5,s1
    80004ab0:	0187c783          	lbu	a5,24(a5)
    80004ab4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ab8:	4685                	li	a3,1
    80004aba:	fbf40613          	addi	a2,s0,-65
    80004abe:	85ca                	mv	a1,s2
    80004ac0:	050a3503          	ld	a0,80(s4)
    80004ac4:	ffffd097          	auipc	ra,0xffffd
    80004ac8:	c06080e7          	jalr	-1018(ra) # 800016ca <copyout>
    80004acc:	01650663          	beq	a0,s6,80004ad8 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ad0:	2985                	addiw	s3,s3,1
    80004ad2:	0905                	addi	s2,s2,1
    80004ad4:	fd3a91e3          	bne	s5,s3,80004a96 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ad8:	21c48513          	addi	a0,s1,540
    80004adc:	ffffe097          	auipc	ra,0xffffe
    80004ae0:	88c080e7          	jalr	-1908(ra) # 80002368 <wakeup>
  release(&pi->lock);
    80004ae4:	8526                	mv	a0,s1
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	1da080e7          	jalr	474(ra) # 80000cc0 <release>
  return i;
}
    80004aee:	854e                	mv	a0,s3
    80004af0:	60a6                	ld	ra,72(sp)
    80004af2:	6406                	ld	s0,64(sp)
    80004af4:	74e2                	ld	s1,56(sp)
    80004af6:	7942                	ld	s2,48(sp)
    80004af8:	79a2                	ld	s3,40(sp)
    80004afa:	7a02                	ld	s4,32(sp)
    80004afc:	6ae2                	ld	s5,24(sp)
    80004afe:	6b42                	ld	s6,16(sp)
    80004b00:	6161                	addi	sp,sp,80
    80004b02:	8082                	ret
      release(&pi->lock);
    80004b04:	8526                	mv	a0,s1
    80004b06:	ffffc097          	auipc	ra,0xffffc
    80004b0a:	1ba080e7          	jalr	442(ra) # 80000cc0 <release>
      return -1;
    80004b0e:	59fd                	li	s3,-1
    80004b10:	bff9                	j	80004aee <piperead+0xc2>

0000000080004b12 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004b12:	de010113          	addi	sp,sp,-544
    80004b16:	20113c23          	sd	ra,536(sp)
    80004b1a:	20813823          	sd	s0,528(sp)
    80004b1e:	20913423          	sd	s1,520(sp)
    80004b22:	21213023          	sd	s2,512(sp)
    80004b26:	ffce                	sd	s3,504(sp)
    80004b28:	fbd2                	sd	s4,496(sp)
    80004b2a:	f7d6                	sd	s5,488(sp)
    80004b2c:	f3da                	sd	s6,480(sp)
    80004b2e:	efde                	sd	s7,472(sp)
    80004b30:	ebe2                	sd	s8,464(sp)
    80004b32:	e7e6                	sd	s9,456(sp)
    80004b34:	e3ea                	sd	s10,448(sp)
    80004b36:	ff6e                	sd	s11,440(sp)
    80004b38:	1400                	addi	s0,sp,544
    80004b3a:	892a                	mv	s2,a0
    80004b3c:	dea43423          	sd	a0,-536(s0)
    80004b40:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b44:	ffffd097          	auipc	ra,0xffffd
    80004b48:	e94080e7          	jalr	-364(ra) # 800019d8 <myproc>
    80004b4c:	84aa                	mv	s1,a0

  begin_op();
    80004b4e:	fffff097          	auipc	ra,0xfffff
    80004b52:	46c080e7          	jalr	1132(ra) # 80003fba <begin_op>

  if((ip = namei(path)) == 0){
    80004b56:	854a                	mv	a0,s2
    80004b58:	fffff097          	auipc	ra,0xfffff
    80004b5c:	256080e7          	jalr	598(ra) # 80003dae <namei>
    80004b60:	c93d                	beqz	a0,80004bd6 <exec+0xc4>
    80004b62:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004b64:	fffff097          	auipc	ra,0xfffff
    80004b68:	a9a080e7          	jalr	-1382(ra) # 800035fe <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b6c:	04000713          	li	a4,64
    80004b70:	4681                	li	a3,0
    80004b72:	e4840613          	addi	a2,s0,-440
    80004b76:	4581                	li	a1,0
    80004b78:	8556                	mv	a0,s5
    80004b7a:	fffff097          	auipc	ra,0xfffff
    80004b7e:	d38080e7          	jalr	-712(ra) # 800038b2 <readi>
    80004b82:	04000793          	li	a5,64
    80004b86:	00f51a63          	bne	a0,a5,80004b9a <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004b8a:	e4842703          	lw	a4,-440(s0)
    80004b8e:	464c47b7          	lui	a5,0x464c4
    80004b92:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004b96:	04f70663          	beq	a4,a5,80004be2 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004b9a:	8556                	mv	a0,s5
    80004b9c:	fffff097          	auipc	ra,0xfffff
    80004ba0:	cc4080e7          	jalr	-828(ra) # 80003860 <iunlockput>
    end_op();
    80004ba4:	fffff097          	auipc	ra,0xfffff
    80004ba8:	496080e7          	jalr	1174(ra) # 8000403a <end_op>
  }
  return -1;
    80004bac:	557d                	li	a0,-1
}
    80004bae:	21813083          	ld	ra,536(sp)
    80004bb2:	21013403          	ld	s0,528(sp)
    80004bb6:	20813483          	ld	s1,520(sp)
    80004bba:	20013903          	ld	s2,512(sp)
    80004bbe:	79fe                	ld	s3,504(sp)
    80004bc0:	7a5e                	ld	s4,496(sp)
    80004bc2:	7abe                	ld	s5,488(sp)
    80004bc4:	7b1e                	ld	s6,480(sp)
    80004bc6:	6bfe                	ld	s7,472(sp)
    80004bc8:	6c5e                	ld	s8,464(sp)
    80004bca:	6cbe                	ld	s9,456(sp)
    80004bcc:	6d1e                	ld	s10,448(sp)
    80004bce:	7dfa                	ld	s11,440(sp)
    80004bd0:	22010113          	addi	sp,sp,544
    80004bd4:	8082                	ret
    end_op();
    80004bd6:	fffff097          	auipc	ra,0xfffff
    80004bda:	464080e7          	jalr	1124(ra) # 8000403a <end_op>
    return -1;
    80004bde:	557d                	li	a0,-1
    80004be0:	b7f9                	j	80004bae <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004be2:	8526                	mv	a0,s1
    80004be4:	ffffd097          	auipc	ra,0xffffd
    80004be8:	eb8080e7          	jalr	-328(ra) # 80001a9c <proc_pagetable>
    80004bec:	8b2a                	mv	s6,a0
    80004bee:	d555                	beqz	a0,80004b9a <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bf0:	e6842783          	lw	a5,-408(s0)
    80004bf4:	e8045703          	lhu	a4,-384(s0)
    80004bf8:	c735                	beqz	a4,80004c64 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004bfa:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bfc:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004c00:	6a05                	lui	s4,0x1
    80004c02:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c06:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004c0a:	6d85                	lui	s11,0x1
    80004c0c:	7d7d                	lui	s10,0xfffff
    80004c0e:	ac1d                	j	80004e44 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c10:	00004517          	auipc	a0,0x4
    80004c14:	aa850513          	addi	a0,a0,-1368 # 800086b8 <syscalls+0x290>
    80004c18:	ffffc097          	auipc	ra,0xffffc
    80004c1c:	938080e7          	jalr	-1736(ra) # 80000550 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c20:	874a                	mv	a4,s2
    80004c22:	009c86bb          	addw	a3,s9,s1
    80004c26:	4581                	li	a1,0
    80004c28:	8556                	mv	a0,s5
    80004c2a:	fffff097          	auipc	ra,0xfffff
    80004c2e:	c88080e7          	jalr	-888(ra) # 800038b2 <readi>
    80004c32:	2501                	sext.w	a0,a0
    80004c34:	1aa91863          	bne	s2,a0,80004de4 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004c38:	009d84bb          	addw	s1,s11,s1
    80004c3c:	013d09bb          	addw	s3,s10,s3
    80004c40:	1f74f263          	bgeu	s1,s7,80004e24 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004c44:	02049593          	slli	a1,s1,0x20
    80004c48:	9181                	srli	a1,a1,0x20
    80004c4a:	95e2                	add	a1,a1,s8
    80004c4c:	855a                	mv	a0,s6
    80004c4e:	ffffc097          	auipc	ra,0xffffc
    80004c52:	448080e7          	jalr	1096(ra) # 80001096 <walkaddr>
    80004c56:	862a                	mv	a2,a0
    if(pa == 0)
    80004c58:	dd45                	beqz	a0,80004c10 <exec+0xfe>
      n = PGSIZE;
    80004c5a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004c5c:	fd49f2e3          	bgeu	s3,s4,80004c20 <exec+0x10e>
      n = sz - i;
    80004c60:	894e                	mv	s2,s3
    80004c62:	bf7d                	j	80004c20 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004c64:	4481                	li	s1,0
  iunlockput(ip);
    80004c66:	8556                	mv	a0,s5
    80004c68:	fffff097          	auipc	ra,0xfffff
    80004c6c:	bf8080e7          	jalr	-1032(ra) # 80003860 <iunlockput>
  end_op();
    80004c70:	fffff097          	auipc	ra,0xfffff
    80004c74:	3ca080e7          	jalr	970(ra) # 8000403a <end_op>
  p = myproc();
    80004c78:	ffffd097          	auipc	ra,0xffffd
    80004c7c:	d60080e7          	jalr	-672(ra) # 800019d8 <myproc>
    80004c80:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004c82:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004c86:	6785                	lui	a5,0x1
    80004c88:	17fd                	addi	a5,a5,-1
    80004c8a:	94be                	add	s1,s1,a5
    80004c8c:	77fd                	lui	a5,0xfffff
    80004c8e:	8fe5                	and	a5,a5,s1
    80004c90:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004c94:	6609                	lui	a2,0x2
    80004c96:	963e                	add	a2,a2,a5
    80004c98:	85be                	mv	a1,a5
    80004c9a:	855a                	mv	a0,s6
    80004c9c:	ffffc097          	auipc	ra,0xffffc
    80004ca0:	7de080e7          	jalr	2014(ra) # 8000147a <uvmalloc>
    80004ca4:	8c2a                	mv	s8,a0
  ip = 0;
    80004ca6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004ca8:	12050e63          	beqz	a0,80004de4 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004cac:	75f9                	lui	a1,0xffffe
    80004cae:	95aa                	add	a1,a1,a0
    80004cb0:	855a                	mv	a0,s6
    80004cb2:	ffffd097          	auipc	ra,0xffffd
    80004cb6:	9e6080e7          	jalr	-1562(ra) # 80001698 <uvmclear>
  stackbase = sp - PGSIZE;
    80004cba:	7afd                	lui	s5,0xfffff
    80004cbc:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004cbe:	df043783          	ld	a5,-528(s0)
    80004cc2:	6388                	ld	a0,0(a5)
    80004cc4:	c925                	beqz	a0,80004d34 <exec+0x222>
    80004cc6:	e8840993          	addi	s3,s0,-376
    80004cca:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004cce:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004cd0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004cd2:	ffffc097          	auipc	ra,0xffffc
    80004cd6:	1ba080e7          	jalr	442(ra) # 80000e8c <strlen>
    80004cda:	0015079b          	addiw	a5,a0,1
    80004cde:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ce2:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004ce6:	13596363          	bltu	s2,s5,80004e0c <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004cea:	df043d83          	ld	s11,-528(s0)
    80004cee:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004cf2:	8552                	mv	a0,s4
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	198080e7          	jalr	408(ra) # 80000e8c <strlen>
    80004cfc:	0015069b          	addiw	a3,a0,1
    80004d00:	8652                	mv	a2,s4
    80004d02:	85ca                	mv	a1,s2
    80004d04:	855a                	mv	a0,s6
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	9c4080e7          	jalr	-1596(ra) # 800016ca <copyout>
    80004d0e:	10054363          	bltz	a0,80004e14 <exec+0x302>
    ustack[argc] = sp;
    80004d12:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d16:	0485                	addi	s1,s1,1
    80004d18:	008d8793          	addi	a5,s11,8
    80004d1c:	def43823          	sd	a5,-528(s0)
    80004d20:	008db503          	ld	a0,8(s11)
    80004d24:	c911                	beqz	a0,80004d38 <exec+0x226>
    if(argc >= MAXARG)
    80004d26:	09a1                	addi	s3,s3,8
    80004d28:	fb3c95e3          	bne	s9,s3,80004cd2 <exec+0x1c0>
  sz = sz1;
    80004d2c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d30:	4a81                	li	s5,0
    80004d32:	a84d                	j	80004de4 <exec+0x2d2>
  sp = sz;
    80004d34:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d36:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d38:	00349793          	slli	a5,s1,0x3
    80004d3c:	f9040713          	addi	a4,s0,-112
    80004d40:	97ba                	add	a5,a5,a4
    80004d42:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004d46:	00148693          	addi	a3,s1,1
    80004d4a:	068e                	slli	a3,a3,0x3
    80004d4c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d50:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004d54:	01597663          	bgeu	s2,s5,80004d60 <exec+0x24e>
  sz = sz1;
    80004d58:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d5c:	4a81                	li	s5,0
    80004d5e:	a059                	j	80004de4 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d60:	e8840613          	addi	a2,s0,-376
    80004d64:	85ca                	mv	a1,s2
    80004d66:	855a                	mv	a0,s6
    80004d68:	ffffd097          	auipc	ra,0xffffd
    80004d6c:	962080e7          	jalr	-1694(ra) # 800016ca <copyout>
    80004d70:	0a054663          	bltz	a0,80004e1c <exec+0x30a>
  p->trapframe->a1 = sp;
    80004d74:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004d78:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004d7c:	de843783          	ld	a5,-536(s0)
    80004d80:	0007c703          	lbu	a4,0(a5)
    80004d84:	cf11                	beqz	a4,80004da0 <exec+0x28e>
    80004d86:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004d88:	02f00693          	li	a3,47
    80004d8c:	a039                	j	80004d9a <exec+0x288>
      last = s+1;
    80004d8e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004d92:	0785                	addi	a5,a5,1
    80004d94:	fff7c703          	lbu	a4,-1(a5)
    80004d98:	c701                	beqz	a4,80004da0 <exec+0x28e>
    if(*s == '/')
    80004d9a:	fed71ce3          	bne	a4,a3,80004d92 <exec+0x280>
    80004d9e:	bfc5                	j	80004d8e <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004da0:	4641                	li	a2,16
    80004da2:	de843583          	ld	a1,-536(s0)
    80004da6:	158b8513          	addi	a0,s7,344
    80004daa:	ffffc097          	auipc	ra,0xffffc
    80004dae:	0b0080e7          	jalr	176(ra) # 80000e5a <safestrcpy>
  oldpagetable = p->pagetable;
    80004db2:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004db6:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004dba:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004dbe:	058bb783          	ld	a5,88(s7)
    80004dc2:	e6043703          	ld	a4,-416(s0)
    80004dc6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004dc8:	058bb783          	ld	a5,88(s7)
    80004dcc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004dd0:	85ea                	mv	a1,s10
    80004dd2:	ffffd097          	auipc	ra,0xffffd
    80004dd6:	d66080e7          	jalr	-666(ra) # 80001b38 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004dda:	0004851b          	sext.w	a0,s1
    80004dde:	bbc1                	j	80004bae <exec+0x9c>
    80004de0:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004de4:	df843583          	ld	a1,-520(s0)
    80004de8:	855a                	mv	a0,s6
    80004dea:	ffffd097          	auipc	ra,0xffffd
    80004dee:	d4e080e7          	jalr	-690(ra) # 80001b38 <proc_freepagetable>
  if(ip){
    80004df2:	da0a94e3          	bnez	s5,80004b9a <exec+0x88>
  return -1;
    80004df6:	557d                	li	a0,-1
    80004df8:	bb5d                	j	80004bae <exec+0x9c>
    80004dfa:	de943c23          	sd	s1,-520(s0)
    80004dfe:	b7dd                	j	80004de4 <exec+0x2d2>
    80004e00:	de943c23          	sd	s1,-520(s0)
    80004e04:	b7c5                	j	80004de4 <exec+0x2d2>
    80004e06:	de943c23          	sd	s1,-520(s0)
    80004e0a:	bfe9                	j	80004de4 <exec+0x2d2>
  sz = sz1;
    80004e0c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e10:	4a81                	li	s5,0
    80004e12:	bfc9                	j	80004de4 <exec+0x2d2>
  sz = sz1;
    80004e14:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e18:	4a81                	li	s5,0
    80004e1a:	b7e9                	j	80004de4 <exec+0x2d2>
  sz = sz1;
    80004e1c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e20:	4a81                	li	s5,0
    80004e22:	b7c9                	j	80004de4 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e24:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e28:	e0843783          	ld	a5,-504(s0)
    80004e2c:	0017869b          	addiw	a3,a5,1
    80004e30:	e0d43423          	sd	a3,-504(s0)
    80004e34:	e0043783          	ld	a5,-512(s0)
    80004e38:	0387879b          	addiw	a5,a5,56
    80004e3c:	e8045703          	lhu	a4,-384(s0)
    80004e40:	e2e6d3e3          	bge	a3,a4,80004c66 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e44:	2781                	sext.w	a5,a5
    80004e46:	e0f43023          	sd	a5,-512(s0)
    80004e4a:	03800713          	li	a4,56
    80004e4e:	86be                	mv	a3,a5
    80004e50:	e1040613          	addi	a2,s0,-496
    80004e54:	4581                	li	a1,0
    80004e56:	8556                	mv	a0,s5
    80004e58:	fffff097          	auipc	ra,0xfffff
    80004e5c:	a5a080e7          	jalr	-1446(ra) # 800038b2 <readi>
    80004e60:	03800793          	li	a5,56
    80004e64:	f6f51ee3          	bne	a0,a5,80004de0 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004e68:	e1042783          	lw	a5,-496(s0)
    80004e6c:	4705                	li	a4,1
    80004e6e:	fae79de3          	bne	a5,a4,80004e28 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004e72:	e3843603          	ld	a2,-456(s0)
    80004e76:	e3043783          	ld	a5,-464(s0)
    80004e7a:	f8f660e3          	bltu	a2,a5,80004dfa <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e7e:	e2043783          	ld	a5,-480(s0)
    80004e82:	963e                	add	a2,a2,a5
    80004e84:	f6f66ee3          	bltu	a2,a5,80004e00 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e88:	85a6                	mv	a1,s1
    80004e8a:	855a                	mv	a0,s6
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	5ee080e7          	jalr	1518(ra) # 8000147a <uvmalloc>
    80004e94:	dea43c23          	sd	a0,-520(s0)
    80004e98:	d53d                	beqz	a0,80004e06 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80004e9a:	e2043c03          	ld	s8,-480(s0)
    80004e9e:	de043783          	ld	a5,-544(s0)
    80004ea2:	00fc77b3          	and	a5,s8,a5
    80004ea6:	ff9d                	bnez	a5,80004de4 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ea8:	e1842c83          	lw	s9,-488(s0)
    80004eac:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004eb0:	f60b8ae3          	beqz	s7,80004e24 <exec+0x312>
    80004eb4:	89de                	mv	s3,s7
    80004eb6:	4481                	li	s1,0
    80004eb8:	b371                	j	80004c44 <exec+0x132>

0000000080004eba <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004eba:	7179                	addi	sp,sp,-48
    80004ebc:	f406                	sd	ra,40(sp)
    80004ebe:	f022                	sd	s0,32(sp)
    80004ec0:	ec26                	sd	s1,24(sp)
    80004ec2:	e84a                	sd	s2,16(sp)
    80004ec4:	1800                	addi	s0,sp,48
    80004ec6:	892e                	mv	s2,a1
    80004ec8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004eca:	fdc40593          	addi	a1,s0,-36
    80004ece:	ffffe097          	auipc	ra,0xffffe
    80004ed2:	bc0080e7          	jalr	-1088(ra) # 80002a8e <argint>
    80004ed6:	04054063          	bltz	a0,80004f16 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004eda:	fdc42703          	lw	a4,-36(s0)
    80004ede:	47bd                	li	a5,15
    80004ee0:	02e7ed63          	bltu	a5,a4,80004f1a <argfd+0x60>
    80004ee4:	ffffd097          	auipc	ra,0xffffd
    80004ee8:	af4080e7          	jalr	-1292(ra) # 800019d8 <myproc>
    80004eec:	fdc42703          	lw	a4,-36(s0)
    80004ef0:	01a70793          	addi	a5,a4,26
    80004ef4:	078e                	slli	a5,a5,0x3
    80004ef6:	953e                	add	a0,a0,a5
    80004ef8:	611c                	ld	a5,0(a0)
    80004efa:	c395                	beqz	a5,80004f1e <argfd+0x64>
    return -1;
  if(pfd)
    80004efc:	00090463          	beqz	s2,80004f04 <argfd+0x4a>
    *pfd = fd;
    80004f00:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f04:	4501                	li	a0,0
  if(pf)
    80004f06:	c091                	beqz	s1,80004f0a <argfd+0x50>
    *pf = f;
    80004f08:	e09c                	sd	a5,0(s1)
}
    80004f0a:	70a2                	ld	ra,40(sp)
    80004f0c:	7402                	ld	s0,32(sp)
    80004f0e:	64e2                	ld	s1,24(sp)
    80004f10:	6942                	ld	s2,16(sp)
    80004f12:	6145                	addi	sp,sp,48
    80004f14:	8082                	ret
    return -1;
    80004f16:	557d                	li	a0,-1
    80004f18:	bfcd                	j	80004f0a <argfd+0x50>
    return -1;
    80004f1a:	557d                	li	a0,-1
    80004f1c:	b7fd                	j	80004f0a <argfd+0x50>
    80004f1e:	557d                	li	a0,-1
    80004f20:	b7ed                	j	80004f0a <argfd+0x50>

0000000080004f22 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f22:	1101                	addi	sp,sp,-32
    80004f24:	ec06                	sd	ra,24(sp)
    80004f26:	e822                	sd	s0,16(sp)
    80004f28:	e426                	sd	s1,8(sp)
    80004f2a:	1000                	addi	s0,sp,32
    80004f2c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f2e:	ffffd097          	auipc	ra,0xffffd
    80004f32:	aaa080e7          	jalr	-1366(ra) # 800019d8 <myproc>
    80004f36:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f38:	0d050793          	addi	a5,a0,208
    80004f3c:	4501                	li	a0,0
    80004f3e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f40:	6398                	ld	a4,0(a5)
    80004f42:	cb19                	beqz	a4,80004f58 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f44:	2505                	addiw	a0,a0,1
    80004f46:	07a1                	addi	a5,a5,8
    80004f48:	fed51ce3          	bne	a0,a3,80004f40 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f4c:	557d                	li	a0,-1
}
    80004f4e:	60e2                	ld	ra,24(sp)
    80004f50:	6442                	ld	s0,16(sp)
    80004f52:	64a2                	ld	s1,8(sp)
    80004f54:	6105                	addi	sp,sp,32
    80004f56:	8082                	ret
      p->ofile[fd] = f;
    80004f58:	01a50793          	addi	a5,a0,26
    80004f5c:	078e                	slli	a5,a5,0x3
    80004f5e:	963e                	add	a2,a2,a5
    80004f60:	e204                	sd	s1,0(a2)
      return fd;
    80004f62:	b7f5                	j	80004f4e <fdalloc+0x2c>

0000000080004f64 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f64:	715d                	addi	sp,sp,-80
    80004f66:	e486                	sd	ra,72(sp)
    80004f68:	e0a2                	sd	s0,64(sp)
    80004f6a:	fc26                	sd	s1,56(sp)
    80004f6c:	f84a                	sd	s2,48(sp)
    80004f6e:	f44e                	sd	s3,40(sp)
    80004f70:	f052                	sd	s4,32(sp)
    80004f72:	ec56                	sd	s5,24(sp)
    80004f74:	0880                	addi	s0,sp,80
    80004f76:	89ae                	mv	s3,a1
    80004f78:	8ab2                	mv	s5,a2
    80004f7a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004f7c:	fb040593          	addi	a1,s0,-80
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	e4c080e7          	jalr	-436(ra) # 80003dcc <nameiparent>
    80004f88:	892a                	mv	s2,a0
    80004f8a:	12050e63          	beqz	a0,800050c6 <create+0x162>
    return 0;

  ilock(dp);
    80004f8e:	ffffe097          	auipc	ra,0xffffe
    80004f92:	670080e7          	jalr	1648(ra) # 800035fe <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f96:	4601                	li	a2,0
    80004f98:	fb040593          	addi	a1,s0,-80
    80004f9c:	854a                	mv	a0,s2
    80004f9e:	fffff097          	auipc	ra,0xfffff
    80004fa2:	b3e080e7          	jalr	-1218(ra) # 80003adc <dirlookup>
    80004fa6:	84aa                	mv	s1,a0
    80004fa8:	c921                	beqz	a0,80004ff8 <create+0x94>
    iunlockput(dp);
    80004faa:	854a                	mv	a0,s2
    80004fac:	fffff097          	auipc	ra,0xfffff
    80004fb0:	8b4080e7          	jalr	-1868(ra) # 80003860 <iunlockput>
    ilock(ip);
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	ffffe097          	auipc	ra,0xffffe
    80004fba:	648080e7          	jalr	1608(ra) # 800035fe <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fbe:	2981                	sext.w	s3,s3
    80004fc0:	4789                	li	a5,2
    80004fc2:	02f99463          	bne	s3,a5,80004fea <create+0x86>
    80004fc6:	0444d783          	lhu	a5,68(s1)
    80004fca:	37f9                	addiw	a5,a5,-2
    80004fcc:	17c2                	slli	a5,a5,0x30
    80004fce:	93c1                	srli	a5,a5,0x30
    80004fd0:	4705                	li	a4,1
    80004fd2:	00f76c63          	bltu	a4,a5,80004fea <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004fd6:	8526                	mv	a0,s1
    80004fd8:	60a6                	ld	ra,72(sp)
    80004fda:	6406                	ld	s0,64(sp)
    80004fdc:	74e2                	ld	s1,56(sp)
    80004fde:	7942                	ld	s2,48(sp)
    80004fe0:	79a2                	ld	s3,40(sp)
    80004fe2:	7a02                	ld	s4,32(sp)
    80004fe4:	6ae2                	ld	s5,24(sp)
    80004fe6:	6161                	addi	sp,sp,80
    80004fe8:	8082                	ret
    iunlockput(ip);
    80004fea:	8526                	mv	a0,s1
    80004fec:	fffff097          	auipc	ra,0xfffff
    80004ff0:	874080e7          	jalr	-1932(ra) # 80003860 <iunlockput>
    return 0;
    80004ff4:	4481                	li	s1,0
    80004ff6:	b7c5                	j	80004fd6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004ff8:	85ce                	mv	a1,s3
    80004ffa:	00092503          	lw	a0,0(s2)
    80004ffe:	ffffe097          	auipc	ra,0xffffe
    80005002:	468080e7          	jalr	1128(ra) # 80003466 <ialloc>
    80005006:	84aa                	mv	s1,a0
    80005008:	c521                	beqz	a0,80005050 <create+0xec>
  ilock(ip);
    8000500a:	ffffe097          	auipc	ra,0xffffe
    8000500e:	5f4080e7          	jalr	1524(ra) # 800035fe <ilock>
  ip->major = major;
    80005012:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005016:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000501a:	4a05                	li	s4,1
    8000501c:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005020:	8526                	mv	a0,s1
    80005022:	ffffe097          	auipc	ra,0xffffe
    80005026:	512080e7          	jalr	1298(ra) # 80003534 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000502a:	2981                	sext.w	s3,s3
    8000502c:	03498a63          	beq	s3,s4,80005060 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005030:	40d0                	lw	a2,4(s1)
    80005032:	fb040593          	addi	a1,s0,-80
    80005036:	854a                	mv	a0,s2
    80005038:	fffff097          	auipc	ra,0xfffff
    8000503c:	cb4080e7          	jalr	-844(ra) # 80003cec <dirlink>
    80005040:	06054b63          	bltz	a0,800050b6 <create+0x152>
  iunlockput(dp);
    80005044:	854a                	mv	a0,s2
    80005046:	fffff097          	auipc	ra,0xfffff
    8000504a:	81a080e7          	jalr	-2022(ra) # 80003860 <iunlockput>
  return ip;
    8000504e:	b761                	j	80004fd6 <create+0x72>
    panic("create: ialloc");
    80005050:	00003517          	auipc	a0,0x3
    80005054:	68850513          	addi	a0,a0,1672 # 800086d8 <syscalls+0x2b0>
    80005058:	ffffb097          	auipc	ra,0xffffb
    8000505c:	4f8080e7          	jalr	1272(ra) # 80000550 <panic>
    dp->nlink++;  // for ".."
    80005060:	04a95783          	lhu	a5,74(s2)
    80005064:	2785                	addiw	a5,a5,1
    80005066:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000506a:	854a                	mv	a0,s2
    8000506c:	ffffe097          	auipc	ra,0xffffe
    80005070:	4c8080e7          	jalr	1224(ra) # 80003534 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005074:	40d0                	lw	a2,4(s1)
    80005076:	00003597          	auipc	a1,0x3
    8000507a:	67258593          	addi	a1,a1,1650 # 800086e8 <syscalls+0x2c0>
    8000507e:	8526                	mv	a0,s1
    80005080:	fffff097          	auipc	ra,0xfffff
    80005084:	c6c080e7          	jalr	-916(ra) # 80003cec <dirlink>
    80005088:	00054f63          	bltz	a0,800050a6 <create+0x142>
    8000508c:	00492603          	lw	a2,4(s2)
    80005090:	00003597          	auipc	a1,0x3
    80005094:	66058593          	addi	a1,a1,1632 # 800086f0 <syscalls+0x2c8>
    80005098:	8526                	mv	a0,s1
    8000509a:	fffff097          	auipc	ra,0xfffff
    8000509e:	c52080e7          	jalr	-942(ra) # 80003cec <dirlink>
    800050a2:	f80557e3          	bgez	a0,80005030 <create+0xcc>
      panic("create dots");
    800050a6:	00003517          	auipc	a0,0x3
    800050aa:	65250513          	addi	a0,a0,1618 # 800086f8 <syscalls+0x2d0>
    800050ae:	ffffb097          	auipc	ra,0xffffb
    800050b2:	4a2080e7          	jalr	1186(ra) # 80000550 <panic>
    panic("create: dirlink");
    800050b6:	00003517          	auipc	a0,0x3
    800050ba:	65250513          	addi	a0,a0,1618 # 80008708 <syscalls+0x2e0>
    800050be:	ffffb097          	auipc	ra,0xffffb
    800050c2:	492080e7          	jalr	1170(ra) # 80000550 <panic>
    return 0;
    800050c6:	84aa                	mv	s1,a0
    800050c8:	b739                	j	80004fd6 <create+0x72>

00000000800050ca <sys_dup>:
{
    800050ca:	7179                	addi	sp,sp,-48
    800050cc:	f406                	sd	ra,40(sp)
    800050ce:	f022                	sd	s0,32(sp)
    800050d0:	ec26                	sd	s1,24(sp)
    800050d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800050d4:	fd840613          	addi	a2,s0,-40
    800050d8:	4581                	li	a1,0
    800050da:	4501                	li	a0,0
    800050dc:	00000097          	auipc	ra,0x0
    800050e0:	dde080e7          	jalr	-546(ra) # 80004eba <argfd>
    return -1;
    800050e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800050e6:	02054363          	bltz	a0,8000510c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800050ea:	fd843503          	ld	a0,-40(s0)
    800050ee:	00000097          	auipc	ra,0x0
    800050f2:	e34080e7          	jalr	-460(ra) # 80004f22 <fdalloc>
    800050f6:	84aa                	mv	s1,a0
    return -1;
    800050f8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800050fa:	00054963          	bltz	a0,8000510c <sys_dup+0x42>
  filedup(f);
    800050fe:	fd843503          	ld	a0,-40(s0)
    80005102:	fffff097          	auipc	ra,0xfffff
    80005106:	338080e7          	jalr	824(ra) # 8000443a <filedup>
  return fd;
    8000510a:	87a6                	mv	a5,s1
}
    8000510c:	853e                	mv	a0,a5
    8000510e:	70a2                	ld	ra,40(sp)
    80005110:	7402                	ld	s0,32(sp)
    80005112:	64e2                	ld	s1,24(sp)
    80005114:	6145                	addi	sp,sp,48
    80005116:	8082                	ret

0000000080005118 <sys_read>:
{
    80005118:	7179                	addi	sp,sp,-48
    8000511a:	f406                	sd	ra,40(sp)
    8000511c:	f022                	sd	s0,32(sp)
    8000511e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005120:	fe840613          	addi	a2,s0,-24
    80005124:	4581                	li	a1,0
    80005126:	4501                	li	a0,0
    80005128:	00000097          	auipc	ra,0x0
    8000512c:	d92080e7          	jalr	-622(ra) # 80004eba <argfd>
    return -1;
    80005130:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005132:	04054163          	bltz	a0,80005174 <sys_read+0x5c>
    80005136:	fe440593          	addi	a1,s0,-28
    8000513a:	4509                	li	a0,2
    8000513c:	ffffe097          	auipc	ra,0xffffe
    80005140:	952080e7          	jalr	-1710(ra) # 80002a8e <argint>
    return -1;
    80005144:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005146:	02054763          	bltz	a0,80005174 <sys_read+0x5c>
    8000514a:	fd840593          	addi	a1,s0,-40
    8000514e:	4505                	li	a0,1
    80005150:	ffffe097          	auipc	ra,0xffffe
    80005154:	960080e7          	jalr	-1696(ra) # 80002ab0 <argaddr>
    return -1;
    80005158:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000515a:	00054d63          	bltz	a0,80005174 <sys_read+0x5c>
  return fileread(f, p, n);
    8000515e:	fe442603          	lw	a2,-28(s0)
    80005162:	fd843583          	ld	a1,-40(s0)
    80005166:	fe843503          	ld	a0,-24(s0)
    8000516a:	fffff097          	auipc	ra,0xfffff
    8000516e:	45c080e7          	jalr	1116(ra) # 800045c6 <fileread>
    80005172:	87aa                	mv	a5,a0
}
    80005174:	853e                	mv	a0,a5
    80005176:	70a2                	ld	ra,40(sp)
    80005178:	7402                	ld	s0,32(sp)
    8000517a:	6145                	addi	sp,sp,48
    8000517c:	8082                	ret

000000008000517e <sys_write>:
{
    8000517e:	7179                	addi	sp,sp,-48
    80005180:	f406                	sd	ra,40(sp)
    80005182:	f022                	sd	s0,32(sp)
    80005184:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005186:	fe840613          	addi	a2,s0,-24
    8000518a:	4581                	li	a1,0
    8000518c:	4501                	li	a0,0
    8000518e:	00000097          	auipc	ra,0x0
    80005192:	d2c080e7          	jalr	-724(ra) # 80004eba <argfd>
    return -1;
    80005196:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005198:	04054163          	bltz	a0,800051da <sys_write+0x5c>
    8000519c:	fe440593          	addi	a1,s0,-28
    800051a0:	4509                	li	a0,2
    800051a2:	ffffe097          	auipc	ra,0xffffe
    800051a6:	8ec080e7          	jalr	-1812(ra) # 80002a8e <argint>
    return -1;
    800051aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051ac:	02054763          	bltz	a0,800051da <sys_write+0x5c>
    800051b0:	fd840593          	addi	a1,s0,-40
    800051b4:	4505                	li	a0,1
    800051b6:	ffffe097          	auipc	ra,0xffffe
    800051ba:	8fa080e7          	jalr	-1798(ra) # 80002ab0 <argaddr>
    return -1;
    800051be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051c0:	00054d63          	bltz	a0,800051da <sys_write+0x5c>
  return filewrite(f, p, n);
    800051c4:	fe442603          	lw	a2,-28(s0)
    800051c8:	fd843583          	ld	a1,-40(s0)
    800051cc:	fe843503          	ld	a0,-24(s0)
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	4b8080e7          	jalr	1208(ra) # 80004688 <filewrite>
    800051d8:	87aa                	mv	a5,a0
}
    800051da:	853e                	mv	a0,a5
    800051dc:	70a2                	ld	ra,40(sp)
    800051de:	7402                	ld	s0,32(sp)
    800051e0:	6145                	addi	sp,sp,48
    800051e2:	8082                	ret

00000000800051e4 <sys_close>:
{
    800051e4:	1101                	addi	sp,sp,-32
    800051e6:	ec06                	sd	ra,24(sp)
    800051e8:	e822                	sd	s0,16(sp)
    800051ea:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800051ec:	fe040613          	addi	a2,s0,-32
    800051f0:	fec40593          	addi	a1,s0,-20
    800051f4:	4501                	li	a0,0
    800051f6:	00000097          	auipc	ra,0x0
    800051fa:	cc4080e7          	jalr	-828(ra) # 80004eba <argfd>
    return -1;
    800051fe:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005200:	02054463          	bltz	a0,80005228 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005204:	ffffc097          	auipc	ra,0xffffc
    80005208:	7d4080e7          	jalr	2004(ra) # 800019d8 <myproc>
    8000520c:	fec42783          	lw	a5,-20(s0)
    80005210:	07e9                	addi	a5,a5,26
    80005212:	078e                	slli	a5,a5,0x3
    80005214:	97aa                	add	a5,a5,a0
    80005216:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000521a:	fe043503          	ld	a0,-32(s0)
    8000521e:	fffff097          	auipc	ra,0xfffff
    80005222:	26e080e7          	jalr	622(ra) # 8000448c <fileclose>
  return 0;
    80005226:	4781                	li	a5,0
}
    80005228:	853e                	mv	a0,a5
    8000522a:	60e2                	ld	ra,24(sp)
    8000522c:	6442                	ld	s0,16(sp)
    8000522e:	6105                	addi	sp,sp,32
    80005230:	8082                	ret

0000000080005232 <sys_fstat>:
{
    80005232:	1101                	addi	sp,sp,-32
    80005234:	ec06                	sd	ra,24(sp)
    80005236:	e822                	sd	s0,16(sp)
    80005238:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000523a:	fe840613          	addi	a2,s0,-24
    8000523e:	4581                	li	a1,0
    80005240:	4501                	li	a0,0
    80005242:	00000097          	auipc	ra,0x0
    80005246:	c78080e7          	jalr	-904(ra) # 80004eba <argfd>
    return -1;
    8000524a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000524c:	02054563          	bltz	a0,80005276 <sys_fstat+0x44>
    80005250:	fe040593          	addi	a1,s0,-32
    80005254:	4505                	li	a0,1
    80005256:	ffffe097          	auipc	ra,0xffffe
    8000525a:	85a080e7          	jalr	-1958(ra) # 80002ab0 <argaddr>
    return -1;
    8000525e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005260:	00054b63          	bltz	a0,80005276 <sys_fstat+0x44>
  return filestat(f, st);
    80005264:	fe043583          	ld	a1,-32(s0)
    80005268:	fe843503          	ld	a0,-24(s0)
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	2e8080e7          	jalr	744(ra) # 80004554 <filestat>
    80005274:	87aa                	mv	a5,a0
}
    80005276:	853e                	mv	a0,a5
    80005278:	60e2                	ld	ra,24(sp)
    8000527a:	6442                	ld	s0,16(sp)
    8000527c:	6105                	addi	sp,sp,32
    8000527e:	8082                	ret

0000000080005280 <sys_link>:
{
    80005280:	7169                	addi	sp,sp,-304
    80005282:	f606                	sd	ra,296(sp)
    80005284:	f222                	sd	s0,288(sp)
    80005286:	ee26                	sd	s1,280(sp)
    80005288:	ea4a                	sd	s2,272(sp)
    8000528a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000528c:	08000613          	li	a2,128
    80005290:	ed040593          	addi	a1,s0,-304
    80005294:	4501                	li	a0,0
    80005296:	ffffe097          	auipc	ra,0xffffe
    8000529a:	83c080e7          	jalr	-1988(ra) # 80002ad2 <argstr>
    return -1;
    8000529e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052a0:	10054e63          	bltz	a0,800053bc <sys_link+0x13c>
    800052a4:	08000613          	li	a2,128
    800052a8:	f5040593          	addi	a1,s0,-176
    800052ac:	4505                	li	a0,1
    800052ae:	ffffe097          	auipc	ra,0xffffe
    800052b2:	824080e7          	jalr	-2012(ra) # 80002ad2 <argstr>
    return -1;
    800052b6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052b8:	10054263          	bltz	a0,800053bc <sys_link+0x13c>
  begin_op();
    800052bc:	fffff097          	auipc	ra,0xfffff
    800052c0:	cfe080e7          	jalr	-770(ra) # 80003fba <begin_op>
  if((ip = namei(old)) == 0){
    800052c4:	ed040513          	addi	a0,s0,-304
    800052c8:	fffff097          	auipc	ra,0xfffff
    800052cc:	ae6080e7          	jalr	-1306(ra) # 80003dae <namei>
    800052d0:	84aa                	mv	s1,a0
    800052d2:	c551                	beqz	a0,8000535e <sys_link+0xde>
  ilock(ip);
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	32a080e7          	jalr	810(ra) # 800035fe <ilock>
  if(ip->type == T_DIR){
    800052dc:	04449703          	lh	a4,68(s1)
    800052e0:	4785                	li	a5,1
    800052e2:	08f70463          	beq	a4,a5,8000536a <sys_link+0xea>
  ip->nlink++;
    800052e6:	04a4d783          	lhu	a5,74(s1)
    800052ea:	2785                	addiw	a5,a5,1
    800052ec:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052f0:	8526                	mv	a0,s1
    800052f2:	ffffe097          	auipc	ra,0xffffe
    800052f6:	242080e7          	jalr	578(ra) # 80003534 <iupdate>
  iunlock(ip);
    800052fa:	8526                	mv	a0,s1
    800052fc:	ffffe097          	auipc	ra,0xffffe
    80005300:	3c4080e7          	jalr	964(ra) # 800036c0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005304:	fd040593          	addi	a1,s0,-48
    80005308:	f5040513          	addi	a0,s0,-176
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	ac0080e7          	jalr	-1344(ra) # 80003dcc <nameiparent>
    80005314:	892a                	mv	s2,a0
    80005316:	c935                	beqz	a0,8000538a <sys_link+0x10a>
  ilock(dp);
    80005318:	ffffe097          	auipc	ra,0xffffe
    8000531c:	2e6080e7          	jalr	742(ra) # 800035fe <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005320:	00092703          	lw	a4,0(s2)
    80005324:	409c                	lw	a5,0(s1)
    80005326:	04f71d63          	bne	a4,a5,80005380 <sys_link+0x100>
    8000532a:	40d0                	lw	a2,4(s1)
    8000532c:	fd040593          	addi	a1,s0,-48
    80005330:	854a                	mv	a0,s2
    80005332:	fffff097          	auipc	ra,0xfffff
    80005336:	9ba080e7          	jalr	-1606(ra) # 80003cec <dirlink>
    8000533a:	04054363          	bltz	a0,80005380 <sys_link+0x100>
  iunlockput(dp);
    8000533e:	854a                	mv	a0,s2
    80005340:	ffffe097          	auipc	ra,0xffffe
    80005344:	520080e7          	jalr	1312(ra) # 80003860 <iunlockput>
  iput(ip);
    80005348:	8526                	mv	a0,s1
    8000534a:	ffffe097          	auipc	ra,0xffffe
    8000534e:	46e080e7          	jalr	1134(ra) # 800037b8 <iput>
  end_op();
    80005352:	fffff097          	auipc	ra,0xfffff
    80005356:	ce8080e7          	jalr	-792(ra) # 8000403a <end_op>
  return 0;
    8000535a:	4781                	li	a5,0
    8000535c:	a085                	j	800053bc <sys_link+0x13c>
    end_op();
    8000535e:	fffff097          	auipc	ra,0xfffff
    80005362:	cdc080e7          	jalr	-804(ra) # 8000403a <end_op>
    return -1;
    80005366:	57fd                	li	a5,-1
    80005368:	a891                	j	800053bc <sys_link+0x13c>
    iunlockput(ip);
    8000536a:	8526                	mv	a0,s1
    8000536c:	ffffe097          	auipc	ra,0xffffe
    80005370:	4f4080e7          	jalr	1268(ra) # 80003860 <iunlockput>
    end_op();
    80005374:	fffff097          	auipc	ra,0xfffff
    80005378:	cc6080e7          	jalr	-826(ra) # 8000403a <end_op>
    return -1;
    8000537c:	57fd                	li	a5,-1
    8000537e:	a83d                	j	800053bc <sys_link+0x13c>
    iunlockput(dp);
    80005380:	854a                	mv	a0,s2
    80005382:	ffffe097          	auipc	ra,0xffffe
    80005386:	4de080e7          	jalr	1246(ra) # 80003860 <iunlockput>
  ilock(ip);
    8000538a:	8526                	mv	a0,s1
    8000538c:	ffffe097          	auipc	ra,0xffffe
    80005390:	272080e7          	jalr	626(ra) # 800035fe <ilock>
  ip->nlink--;
    80005394:	04a4d783          	lhu	a5,74(s1)
    80005398:	37fd                	addiw	a5,a5,-1
    8000539a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000539e:	8526                	mv	a0,s1
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	194080e7          	jalr	404(ra) # 80003534 <iupdate>
  iunlockput(ip);
    800053a8:	8526                	mv	a0,s1
    800053aa:	ffffe097          	auipc	ra,0xffffe
    800053ae:	4b6080e7          	jalr	1206(ra) # 80003860 <iunlockput>
  end_op();
    800053b2:	fffff097          	auipc	ra,0xfffff
    800053b6:	c88080e7          	jalr	-888(ra) # 8000403a <end_op>
  return -1;
    800053ba:	57fd                	li	a5,-1
}
    800053bc:	853e                	mv	a0,a5
    800053be:	70b2                	ld	ra,296(sp)
    800053c0:	7412                	ld	s0,288(sp)
    800053c2:	64f2                	ld	s1,280(sp)
    800053c4:	6952                	ld	s2,272(sp)
    800053c6:	6155                	addi	sp,sp,304
    800053c8:	8082                	ret

00000000800053ca <sys_unlink>:
{
    800053ca:	7151                	addi	sp,sp,-240
    800053cc:	f586                	sd	ra,232(sp)
    800053ce:	f1a2                	sd	s0,224(sp)
    800053d0:	eda6                	sd	s1,216(sp)
    800053d2:	e9ca                	sd	s2,208(sp)
    800053d4:	e5ce                	sd	s3,200(sp)
    800053d6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053d8:	08000613          	li	a2,128
    800053dc:	f3040593          	addi	a1,s0,-208
    800053e0:	4501                	li	a0,0
    800053e2:	ffffd097          	auipc	ra,0xffffd
    800053e6:	6f0080e7          	jalr	1776(ra) # 80002ad2 <argstr>
    800053ea:	18054163          	bltz	a0,8000556c <sys_unlink+0x1a2>
  begin_op();
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	bcc080e7          	jalr	-1076(ra) # 80003fba <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053f6:	fb040593          	addi	a1,s0,-80
    800053fa:	f3040513          	addi	a0,s0,-208
    800053fe:	fffff097          	auipc	ra,0xfffff
    80005402:	9ce080e7          	jalr	-1586(ra) # 80003dcc <nameiparent>
    80005406:	84aa                	mv	s1,a0
    80005408:	c979                	beqz	a0,800054de <sys_unlink+0x114>
  ilock(dp);
    8000540a:	ffffe097          	auipc	ra,0xffffe
    8000540e:	1f4080e7          	jalr	500(ra) # 800035fe <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005412:	00003597          	auipc	a1,0x3
    80005416:	2d658593          	addi	a1,a1,726 # 800086e8 <syscalls+0x2c0>
    8000541a:	fb040513          	addi	a0,s0,-80
    8000541e:	ffffe097          	auipc	ra,0xffffe
    80005422:	6a4080e7          	jalr	1700(ra) # 80003ac2 <namecmp>
    80005426:	14050a63          	beqz	a0,8000557a <sys_unlink+0x1b0>
    8000542a:	00003597          	auipc	a1,0x3
    8000542e:	2c658593          	addi	a1,a1,710 # 800086f0 <syscalls+0x2c8>
    80005432:	fb040513          	addi	a0,s0,-80
    80005436:	ffffe097          	auipc	ra,0xffffe
    8000543a:	68c080e7          	jalr	1676(ra) # 80003ac2 <namecmp>
    8000543e:	12050e63          	beqz	a0,8000557a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005442:	f2c40613          	addi	a2,s0,-212
    80005446:	fb040593          	addi	a1,s0,-80
    8000544a:	8526                	mv	a0,s1
    8000544c:	ffffe097          	auipc	ra,0xffffe
    80005450:	690080e7          	jalr	1680(ra) # 80003adc <dirlookup>
    80005454:	892a                	mv	s2,a0
    80005456:	12050263          	beqz	a0,8000557a <sys_unlink+0x1b0>
  ilock(ip);
    8000545a:	ffffe097          	auipc	ra,0xffffe
    8000545e:	1a4080e7          	jalr	420(ra) # 800035fe <ilock>
  if(ip->nlink < 1)
    80005462:	04a91783          	lh	a5,74(s2)
    80005466:	08f05263          	blez	a5,800054ea <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000546a:	04491703          	lh	a4,68(s2)
    8000546e:	4785                	li	a5,1
    80005470:	08f70563          	beq	a4,a5,800054fa <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005474:	4641                	li	a2,16
    80005476:	4581                	li	a1,0
    80005478:	fc040513          	addi	a0,s0,-64
    8000547c:	ffffc097          	auipc	ra,0xffffc
    80005480:	88c080e7          	jalr	-1908(ra) # 80000d08 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005484:	4741                	li	a4,16
    80005486:	f2c42683          	lw	a3,-212(s0)
    8000548a:	fc040613          	addi	a2,s0,-64
    8000548e:	4581                	li	a1,0
    80005490:	8526                	mv	a0,s1
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	516080e7          	jalr	1302(ra) # 800039a8 <writei>
    8000549a:	47c1                	li	a5,16
    8000549c:	0af51563          	bne	a0,a5,80005546 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054a0:	04491703          	lh	a4,68(s2)
    800054a4:	4785                	li	a5,1
    800054a6:	0af70863          	beq	a4,a5,80005556 <sys_unlink+0x18c>
  iunlockput(dp);
    800054aa:	8526                	mv	a0,s1
    800054ac:	ffffe097          	auipc	ra,0xffffe
    800054b0:	3b4080e7          	jalr	948(ra) # 80003860 <iunlockput>
  ip->nlink--;
    800054b4:	04a95783          	lhu	a5,74(s2)
    800054b8:	37fd                	addiw	a5,a5,-1
    800054ba:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054be:	854a                	mv	a0,s2
    800054c0:	ffffe097          	auipc	ra,0xffffe
    800054c4:	074080e7          	jalr	116(ra) # 80003534 <iupdate>
  iunlockput(ip);
    800054c8:	854a                	mv	a0,s2
    800054ca:	ffffe097          	auipc	ra,0xffffe
    800054ce:	396080e7          	jalr	918(ra) # 80003860 <iunlockput>
  end_op();
    800054d2:	fffff097          	auipc	ra,0xfffff
    800054d6:	b68080e7          	jalr	-1176(ra) # 8000403a <end_op>
  return 0;
    800054da:	4501                	li	a0,0
    800054dc:	a84d                	j	8000558e <sys_unlink+0x1c4>
    end_op();
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	b5c080e7          	jalr	-1188(ra) # 8000403a <end_op>
    return -1;
    800054e6:	557d                	li	a0,-1
    800054e8:	a05d                	j	8000558e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800054ea:	00003517          	auipc	a0,0x3
    800054ee:	22e50513          	addi	a0,a0,558 # 80008718 <syscalls+0x2f0>
    800054f2:	ffffb097          	auipc	ra,0xffffb
    800054f6:	05e080e7          	jalr	94(ra) # 80000550 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054fa:	04c92703          	lw	a4,76(s2)
    800054fe:	02000793          	li	a5,32
    80005502:	f6e7f9e3          	bgeu	a5,a4,80005474 <sys_unlink+0xaa>
    80005506:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000550a:	4741                	li	a4,16
    8000550c:	86ce                	mv	a3,s3
    8000550e:	f1840613          	addi	a2,s0,-232
    80005512:	4581                	li	a1,0
    80005514:	854a                	mv	a0,s2
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	39c080e7          	jalr	924(ra) # 800038b2 <readi>
    8000551e:	47c1                	li	a5,16
    80005520:	00f51b63          	bne	a0,a5,80005536 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005524:	f1845783          	lhu	a5,-232(s0)
    80005528:	e7a1                	bnez	a5,80005570 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000552a:	29c1                	addiw	s3,s3,16
    8000552c:	04c92783          	lw	a5,76(s2)
    80005530:	fcf9ede3          	bltu	s3,a5,8000550a <sys_unlink+0x140>
    80005534:	b781                	j	80005474 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005536:	00003517          	auipc	a0,0x3
    8000553a:	1fa50513          	addi	a0,a0,506 # 80008730 <syscalls+0x308>
    8000553e:	ffffb097          	auipc	ra,0xffffb
    80005542:	012080e7          	jalr	18(ra) # 80000550 <panic>
    panic("unlink: writei");
    80005546:	00003517          	auipc	a0,0x3
    8000554a:	20250513          	addi	a0,a0,514 # 80008748 <syscalls+0x320>
    8000554e:	ffffb097          	auipc	ra,0xffffb
    80005552:	002080e7          	jalr	2(ra) # 80000550 <panic>
    dp->nlink--;
    80005556:	04a4d783          	lhu	a5,74(s1)
    8000555a:	37fd                	addiw	a5,a5,-1
    8000555c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005560:	8526                	mv	a0,s1
    80005562:	ffffe097          	auipc	ra,0xffffe
    80005566:	fd2080e7          	jalr	-46(ra) # 80003534 <iupdate>
    8000556a:	b781                	j	800054aa <sys_unlink+0xe0>
    return -1;
    8000556c:	557d                	li	a0,-1
    8000556e:	a005                	j	8000558e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005570:	854a                	mv	a0,s2
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	2ee080e7          	jalr	750(ra) # 80003860 <iunlockput>
  iunlockput(dp);
    8000557a:	8526                	mv	a0,s1
    8000557c:	ffffe097          	auipc	ra,0xffffe
    80005580:	2e4080e7          	jalr	740(ra) # 80003860 <iunlockput>
  end_op();
    80005584:	fffff097          	auipc	ra,0xfffff
    80005588:	ab6080e7          	jalr	-1354(ra) # 8000403a <end_op>
  return -1;
    8000558c:	557d                	li	a0,-1
}
    8000558e:	70ae                	ld	ra,232(sp)
    80005590:	740e                	ld	s0,224(sp)
    80005592:	64ee                	ld	s1,216(sp)
    80005594:	694e                	ld	s2,208(sp)
    80005596:	69ae                	ld	s3,200(sp)
    80005598:	616d                	addi	sp,sp,240
    8000559a:	8082                	ret

000000008000559c <sys_open>:

uint64
sys_open(void)
{
    8000559c:	7131                	addi	sp,sp,-192
    8000559e:	fd06                	sd	ra,184(sp)
    800055a0:	f922                	sd	s0,176(sp)
    800055a2:	f526                	sd	s1,168(sp)
    800055a4:	f14a                	sd	s2,160(sp)
    800055a6:	ed4e                	sd	s3,152(sp)
    800055a8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800055aa:	08000613          	li	a2,128
    800055ae:	f5040593          	addi	a1,s0,-176
    800055b2:	4501                	li	a0,0
    800055b4:	ffffd097          	auipc	ra,0xffffd
    800055b8:	51e080e7          	jalr	1310(ra) # 80002ad2 <argstr>
    return -1;
    800055bc:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800055be:	0c054163          	bltz	a0,80005680 <sys_open+0xe4>
    800055c2:	f4c40593          	addi	a1,s0,-180
    800055c6:	4505                	li	a0,1
    800055c8:	ffffd097          	auipc	ra,0xffffd
    800055cc:	4c6080e7          	jalr	1222(ra) # 80002a8e <argint>
    800055d0:	0a054863          	bltz	a0,80005680 <sys_open+0xe4>

  begin_op();
    800055d4:	fffff097          	auipc	ra,0xfffff
    800055d8:	9e6080e7          	jalr	-1562(ra) # 80003fba <begin_op>

  if(omode & O_CREATE){
    800055dc:	f4c42783          	lw	a5,-180(s0)
    800055e0:	2007f793          	andi	a5,a5,512
    800055e4:	cbdd                	beqz	a5,8000569a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800055e6:	4681                	li	a3,0
    800055e8:	4601                	li	a2,0
    800055ea:	4589                	li	a1,2
    800055ec:	f5040513          	addi	a0,s0,-176
    800055f0:	00000097          	auipc	ra,0x0
    800055f4:	974080e7          	jalr	-1676(ra) # 80004f64 <create>
    800055f8:	892a                	mv	s2,a0
    if(ip == 0){
    800055fa:	c959                	beqz	a0,80005690 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055fc:	04491703          	lh	a4,68(s2)
    80005600:	478d                	li	a5,3
    80005602:	00f71763          	bne	a4,a5,80005610 <sys_open+0x74>
    80005606:	04695703          	lhu	a4,70(s2)
    8000560a:	47a5                	li	a5,9
    8000560c:	0ce7ec63          	bltu	a5,a4,800056e4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005610:	fffff097          	auipc	ra,0xfffff
    80005614:	dc0080e7          	jalr	-576(ra) # 800043d0 <filealloc>
    80005618:	89aa                	mv	s3,a0
    8000561a:	10050263          	beqz	a0,8000571e <sys_open+0x182>
    8000561e:	00000097          	auipc	ra,0x0
    80005622:	904080e7          	jalr	-1788(ra) # 80004f22 <fdalloc>
    80005626:	84aa                	mv	s1,a0
    80005628:	0e054663          	bltz	a0,80005714 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000562c:	04491703          	lh	a4,68(s2)
    80005630:	478d                	li	a5,3
    80005632:	0cf70463          	beq	a4,a5,800056fa <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005636:	4789                	li	a5,2
    80005638:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000563c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005640:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005644:	f4c42783          	lw	a5,-180(s0)
    80005648:	0017c713          	xori	a4,a5,1
    8000564c:	8b05                	andi	a4,a4,1
    8000564e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005652:	0037f713          	andi	a4,a5,3
    80005656:	00e03733          	snez	a4,a4
    8000565a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000565e:	4007f793          	andi	a5,a5,1024
    80005662:	c791                	beqz	a5,8000566e <sys_open+0xd2>
    80005664:	04491703          	lh	a4,68(s2)
    80005668:	4789                	li	a5,2
    8000566a:	08f70f63          	beq	a4,a5,80005708 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000566e:	854a                	mv	a0,s2
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	050080e7          	jalr	80(ra) # 800036c0 <iunlock>
  end_op();
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	9c2080e7          	jalr	-1598(ra) # 8000403a <end_op>

  return fd;
}
    80005680:	8526                	mv	a0,s1
    80005682:	70ea                	ld	ra,184(sp)
    80005684:	744a                	ld	s0,176(sp)
    80005686:	74aa                	ld	s1,168(sp)
    80005688:	790a                	ld	s2,160(sp)
    8000568a:	69ea                	ld	s3,152(sp)
    8000568c:	6129                	addi	sp,sp,192
    8000568e:	8082                	ret
      end_op();
    80005690:	fffff097          	auipc	ra,0xfffff
    80005694:	9aa080e7          	jalr	-1622(ra) # 8000403a <end_op>
      return -1;
    80005698:	b7e5                	j	80005680 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000569a:	f5040513          	addi	a0,s0,-176
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	710080e7          	jalr	1808(ra) # 80003dae <namei>
    800056a6:	892a                	mv	s2,a0
    800056a8:	c905                	beqz	a0,800056d8 <sys_open+0x13c>
    ilock(ip);
    800056aa:	ffffe097          	auipc	ra,0xffffe
    800056ae:	f54080e7          	jalr	-172(ra) # 800035fe <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056b2:	04491703          	lh	a4,68(s2)
    800056b6:	4785                	li	a5,1
    800056b8:	f4f712e3          	bne	a4,a5,800055fc <sys_open+0x60>
    800056bc:	f4c42783          	lw	a5,-180(s0)
    800056c0:	dba1                	beqz	a5,80005610 <sys_open+0x74>
      iunlockput(ip);
    800056c2:	854a                	mv	a0,s2
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	19c080e7          	jalr	412(ra) # 80003860 <iunlockput>
      end_op();
    800056cc:	fffff097          	auipc	ra,0xfffff
    800056d0:	96e080e7          	jalr	-1682(ra) # 8000403a <end_op>
      return -1;
    800056d4:	54fd                	li	s1,-1
    800056d6:	b76d                	j	80005680 <sys_open+0xe4>
      end_op();
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	962080e7          	jalr	-1694(ra) # 8000403a <end_op>
      return -1;
    800056e0:	54fd                	li	s1,-1
    800056e2:	bf79                	j	80005680 <sys_open+0xe4>
    iunlockput(ip);
    800056e4:	854a                	mv	a0,s2
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	17a080e7          	jalr	378(ra) # 80003860 <iunlockput>
    end_op();
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	94c080e7          	jalr	-1716(ra) # 8000403a <end_op>
    return -1;
    800056f6:	54fd                	li	s1,-1
    800056f8:	b761                	j	80005680 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800056fa:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800056fe:	04691783          	lh	a5,70(s2)
    80005702:	02f99223          	sh	a5,36(s3)
    80005706:	bf2d                	j	80005640 <sys_open+0xa4>
    itrunc(ip);
    80005708:	854a                	mv	a0,s2
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	002080e7          	jalr	2(ra) # 8000370c <itrunc>
    80005712:	bfb1                	j	8000566e <sys_open+0xd2>
      fileclose(f);
    80005714:	854e                	mv	a0,s3
    80005716:	fffff097          	auipc	ra,0xfffff
    8000571a:	d76080e7          	jalr	-650(ra) # 8000448c <fileclose>
    iunlockput(ip);
    8000571e:	854a                	mv	a0,s2
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	140080e7          	jalr	320(ra) # 80003860 <iunlockput>
    end_op();
    80005728:	fffff097          	auipc	ra,0xfffff
    8000572c:	912080e7          	jalr	-1774(ra) # 8000403a <end_op>
    return -1;
    80005730:	54fd                	li	s1,-1
    80005732:	b7b9                	j	80005680 <sys_open+0xe4>

0000000080005734 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005734:	7175                	addi	sp,sp,-144
    80005736:	e506                	sd	ra,136(sp)
    80005738:	e122                	sd	s0,128(sp)
    8000573a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000573c:	fffff097          	auipc	ra,0xfffff
    80005740:	87e080e7          	jalr	-1922(ra) # 80003fba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005744:	08000613          	li	a2,128
    80005748:	f7040593          	addi	a1,s0,-144
    8000574c:	4501                	li	a0,0
    8000574e:	ffffd097          	auipc	ra,0xffffd
    80005752:	384080e7          	jalr	900(ra) # 80002ad2 <argstr>
    80005756:	02054963          	bltz	a0,80005788 <sys_mkdir+0x54>
    8000575a:	4681                	li	a3,0
    8000575c:	4601                	li	a2,0
    8000575e:	4585                	li	a1,1
    80005760:	f7040513          	addi	a0,s0,-144
    80005764:	00000097          	auipc	ra,0x0
    80005768:	800080e7          	jalr	-2048(ra) # 80004f64 <create>
    8000576c:	cd11                	beqz	a0,80005788 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	0f2080e7          	jalr	242(ra) # 80003860 <iunlockput>
  end_op();
    80005776:	fffff097          	auipc	ra,0xfffff
    8000577a:	8c4080e7          	jalr	-1852(ra) # 8000403a <end_op>
  return 0;
    8000577e:	4501                	li	a0,0
}
    80005780:	60aa                	ld	ra,136(sp)
    80005782:	640a                	ld	s0,128(sp)
    80005784:	6149                	addi	sp,sp,144
    80005786:	8082                	ret
    end_op();
    80005788:	fffff097          	auipc	ra,0xfffff
    8000578c:	8b2080e7          	jalr	-1870(ra) # 8000403a <end_op>
    return -1;
    80005790:	557d                	li	a0,-1
    80005792:	b7fd                	j	80005780 <sys_mkdir+0x4c>

0000000080005794 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005794:	7135                	addi	sp,sp,-160
    80005796:	ed06                	sd	ra,152(sp)
    80005798:	e922                	sd	s0,144(sp)
    8000579a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000579c:	fffff097          	auipc	ra,0xfffff
    800057a0:	81e080e7          	jalr	-2018(ra) # 80003fba <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057a4:	08000613          	li	a2,128
    800057a8:	f7040593          	addi	a1,s0,-144
    800057ac:	4501                	li	a0,0
    800057ae:	ffffd097          	auipc	ra,0xffffd
    800057b2:	324080e7          	jalr	804(ra) # 80002ad2 <argstr>
    800057b6:	04054a63          	bltz	a0,8000580a <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800057ba:	f6c40593          	addi	a1,s0,-148
    800057be:	4505                	li	a0,1
    800057c0:	ffffd097          	auipc	ra,0xffffd
    800057c4:	2ce080e7          	jalr	718(ra) # 80002a8e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057c8:	04054163          	bltz	a0,8000580a <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800057cc:	f6840593          	addi	a1,s0,-152
    800057d0:	4509                	li	a0,2
    800057d2:	ffffd097          	auipc	ra,0xffffd
    800057d6:	2bc080e7          	jalr	700(ra) # 80002a8e <argint>
     argint(1, &major) < 0 ||
    800057da:	02054863          	bltz	a0,8000580a <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800057de:	f6841683          	lh	a3,-152(s0)
    800057e2:	f6c41603          	lh	a2,-148(s0)
    800057e6:	458d                	li	a1,3
    800057e8:	f7040513          	addi	a0,s0,-144
    800057ec:	fffff097          	auipc	ra,0xfffff
    800057f0:	778080e7          	jalr	1912(ra) # 80004f64 <create>
     argint(2, &minor) < 0 ||
    800057f4:	c919                	beqz	a0,8000580a <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	06a080e7          	jalr	106(ra) # 80003860 <iunlockput>
  end_op();
    800057fe:	fffff097          	auipc	ra,0xfffff
    80005802:	83c080e7          	jalr	-1988(ra) # 8000403a <end_op>
  return 0;
    80005806:	4501                	li	a0,0
    80005808:	a031                	j	80005814 <sys_mknod+0x80>
    end_op();
    8000580a:	fffff097          	auipc	ra,0xfffff
    8000580e:	830080e7          	jalr	-2000(ra) # 8000403a <end_op>
    return -1;
    80005812:	557d                	li	a0,-1
}
    80005814:	60ea                	ld	ra,152(sp)
    80005816:	644a                	ld	s0,144(sp)
    80005818:	610d                	addi	sp,sp,160
    8000581a:	8082                	ret

000000008000581c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000581c:	7135                	addi	sp,sp,-160
    8000581e:	ed06                	sd	ra,152(sp)
    80005820:	e922                	sd	s0,144(sp)
    80005822:	e526                	sd	s1,136(sp)
    80005824:	e14a                	sd	s2,128(sp)
    80005826:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005828:	ffffc097          	auipc	ra,0xffffc
    8000582c:	1b0080e7          	jalr	432(ra) # 800019d8 <myproc>
    80005830:	892a                	mv	s2,a0
  
  begin_op();
    80005832:	ffffe097          	auipc	ra,0xffffe
    80005836:	788080e7          	jalr	1928(ra) # 80003fba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000583a:	08000613          	li	a2,128
    8000583e:	f6040593          	addi	a1,s0,-160
    80005842:	4501                	li	a0,0
    80005844:	ffffd097          	auipc	ra,0xffffd
    80005848:	28e080e7          	jalr	654(ra) # 80002ad2 <argstr>
    8000584c:	04054b63          	bltz	a0,800058a2 <sys_chdir+0x86>
    80005850:	f6040513          	addi	a0,s0,-160
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	55a080e7          	jalr	1370(ra) # 80003dae <namei>
    8000585c:	84aa                	mv	s1,a0
    8000585e:	c131                	beqz	a0,800058a2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005860:	ffffe097          	auipc	ra,0xffffe
    80005864:	d9e080e7          	jalr	-610(ra) # 800035fe <ilock>
  if(ip->type != T_DIR){
    80005868:	04449703          	lh	a4,68(s1)
    8000586c:	4785                	li	a5,1
    8000586e:	04f71063          	bne	a4,a5,800058ae <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005872:	8526                	mv	a0,s1
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	e4c080e7          	jalr	-436(ra) # 800036c0 <iunlock>
  iput(p->cwd);
    8000587c:	15093503          	ld	a0,336(s2)
    80005880:	ffffe097          	auipc	ra,0xffffe
    80005884:	f38080e7          	jalr	-200(ra) # 800037b8 <iput>
  end_op();
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	7b2080e7          	jalr	1970(ra) # 8000403a <end_op>
  p->cwd = ip;
    80005890:	14993823          	sd	s1,336(s2)
  return 0;
    80005894:	4501                	li	a0,0
}
    80005896:	60ea                	ld	ra,152(sp)
    80005898:	644a                	ld	s0,144(sp)
    8000589a:	64aa                	ld	s1,136(sp)
    8000589c:	690a                	ld	s2,128(sp)
    8000589e:	610d                	addi	sp,sp,160
    800058a0:	8082                	ret
    end_op();
    800058a2:	ffffe097          	auipc	ra,0xffffe
    800058a6:	798080e7          	jalr	1944(ra) # 8000403a <end_op>
    return -1;
    800058aa:	557d                	li	a0,-1
    800058ac:	b7ed                	j	80005896 <sys_chdir+0x7a>
    iunlockput(ip);
    800058ae:	8526                	mv	a0,s1
    800058b0:	ffffe097          	auipc	ra,0xffffe
    800058b4:	fb0080e7          	jalr	-80(ra) # 80003860 <iunlockput>
    end_op();
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	782080e7          	jalr	1922(ra) # 8000403a <end_op>
    return -1;
    800058c0:	557d                	li	a0,-1
    800058c2:	bfd1                	j	80005896 <sys_chdir+0x7a>

00000000800058c4 <sys_exec>:

uint64
sys_exec(void)
{
    800058c4:	7145                	addi	sp,sp,-464
    800058c6:	e786                	sd	ra,456(sp)
    800058c8:	e3a2                	sd	s0,448(sp)
    800058ca:	ff26                	sd	s1,440(sp)
    800058cc:	fb4a                	sd	s2,432(sp)
    800058ce:	f74e                	sd	s3,424(sp)
    800058d0:	f352                	sd	s4,416(sp)
    800058d2:	ef56                	sd	s5,408(sp)
    800058d4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800058d6:	08000613          	li	a2,128
    800058da:	f4040593          	addi	a1,s0,-192
    800058de:	4501                	li	a0,0
    800058e0:	ffffd097          	auipc	ra,0xffffd
    800058e4:	1f2080e7          	jalr	498(ra) # 80002ad2 <argstr>
    return -1;
    800058e8:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800058ea:	0c054a63          	bltz	a0,800059be <sys_exec+0xfa>
    800058ee:	e3840593          	addi	a1,s0,-456
    800058f2:	4505                	li	a0,1
    800058f4:	ffffd097          	auipc	ra,0xffffd
    800058f8:	1bc080e7          	jalr	444(ra) # 80002ab0 <argaddr>
    800058fc:	0c054163          	bltz	a0,800059be <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005900:	10000613          	li	a2,256
    80005904:	4581                	li	a1,0
    80005906:	e4040513          	addi	a0,s0,-448
    8000590a:	ffffb097          	auipc	ra,0xffffb
    8000590e:	3fe080e7          	jalr	1022(ra) # 80000d08 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005912:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005916:	89a6                	mv	s3,s1
    80005918:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000591a:	02000a13          	li	s4,32
    8000591e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005922:	00391793          	slli	a5,s2,0x3
    80005926:	e3040593          	addi	a1,s0,-464
    8000592a:	e3843503          	ld	a0,-456(s0)
    8000592e:	953e                	add	a0,a0,a5
    80005930:	ffffd097          	auipc	ra,0xffffd
    80005934:	0c4080e7          	jalr	196(ra) # 800029f4 <fetchaddr>
    80005938:	02054a63          	bltz	a0,8000596c <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    8000593c:	e3043783          	ld	a5,-464(s0)
    80005940:	c3b9                	beqz	a5,80005986 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005942:	ffffb097          	auipc	ra,0xffffb
    80005946:	1da080e7          	jalr	474(ra) # 80000b1c <kalloc>
    8000594a:	85aa                	mv	a1,a0
    8000594c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005950:	cd11                	beqz	a0,8000596c <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005952:	6605                	lui	a2,0x1
    80005954:	e3043503          	ld	a0,-464(s0)
    80005958:	ffffd097          	auipc	ra,0xffffd
    8000595c:	0ee080e7          	jalr	238(ra) # 80002a46 <fetchstr>
    80005960:	00054663          	bltz	a0,8000596c <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005964:	0905                	addi	s2,s2,1
    80005966:	09a1                	addi	s3,s3,8
    80005968:	fb491be3          	bne	s2,s4,8000591e <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000596c:	10048913          	addi	s2,s1,256
    80005970:	6088                	ld	a0,0(s1)
    80005972:	c529                	beqz	a0,800059bc <sys_exec+0xf8>
    kfree(argv[i]);
    80005974:	ffffb097          	auipc	ra,0xffffb
    80005978:	0ac080e7          	jalr	172(ra) # 80000a20 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000597c:	04a1                	addi	s1,s1,8
    8000597e:	ff2499e3          	bne	s1,s2,80005970 <sys_exec+0xac>
  return -1;
    80005982:	597d                	li	s2,-1
    80005984:	a82d                	j	800059be <sys_exec+0xfa>
      argv[i] = 0;
    80005986:	0a8e                	slli	s5,s5,0x3
    80005988:	fc040793          	addi	a5,s0,-64
    8000598c:	9abe                	add	s5,s5,a5
    8000598e:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80005992:	e4040593          	addi	a1,s0,-448
    80005996:	f4040513          	addi	a0,s0,-192
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	178080e7          	jalr	376(ra) # 80004b12 <exec>
    800059a2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059a4:	10048993          	addi	s3,s1,256
    800059a8:	6088                	ld	a0,0(s1)
    800059aa:	c911                	beqz	a0,800059be <sys_exec+0xfa>
    kfree(argv[i]);
    800059ac:	ffffb097          	auipc	ra,0xffffb
    800059b0:	074080e7          	jalr	116(ra) # 80000a20 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059b4:	04a1                	addi	s1,s1,8
    800059b6:	ff3499e3          	bne	s1,s3,800059a8 <sys_exec+0xe4>
    800059ba:	a011                	j	800059be <sys_exec+0xfa>
  return -1;
    800059bc:	597d                	li	s2,-1
}
    800059be:	854a                	mv	a0,s2
    800059c0:	60be                	ld	ra,456(sp)
    800059c2:	641e                	ld	s0,448(sp)
    800059c4:	74fa                	ld	s1,440(sp)
    800059c6:	795a                	ld	s2,432(sp)
    800059c8:	79ba                	ld	s3,424(sp)
    800059ca:	7a1a                	ld	s4,416(sp)
    800059cc:	6afa                	ld	s5,408(sp)
    800059ce:	6179                	addi	sp,sp,464
    800059d0:	8082                	ret

00000000800059d2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800059d2:	7139                	addi	sp,sp,-64
    800059d4:	fc06                	sd	ra,56(sp)
    800059d6:	f822                	sd	s0,48(sp)
    800059d8:	f426                	sd	s1,40(sp)
    800059da:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800059dc:	ffffc097          	auipc	ra,0xffffc
    800059e0:	ffc080e7          	jalr	-4(ra) # 800019d8 <myproc>
    800059e4:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800059e6:	fd840593          	addi	a1,s0,-40
    800059ea:	4501                	li	a0,0
    800059ec:	ffffd097          	auipc	ra,0xffffd
    800059f0:	0c4080e7          	jalr	196(ra) # 80002ab0 <argaddr>
    return -1;
    800059f4:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800059f6:	0e054063          	bltz	a0,80005ad6 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800059fa:	fc840593          	addi	a1,s0,-56
    800059fe:	fd040513          	addi	a0,s0,-48
    80005a02:	fffff097          	auipc	ra,0xfffff
    80005a06:	de0080e7          	jalr	-544(ra) # 800047e2 <pipealloc>
    return -1;
    80005a0a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a0c:	0c054563          	bltz	a0,80005ad6 <sys_pipe+0x104>
  fd0 = -1;
    80005a10:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a14:	fd043503          	ld	a0,-48(s0)
    80005a18:	fffff097          	auipc	ra,0xfffff
    80005a1c:	50a080e7          	jalr	1290(ra) # 80004f22 <fdalloc>
    80005a20:	fca42223          	sw	a0,-60(s0)
    80005a24:	08054c63          	bltz	a0,80005abc <sys_pipe+0xea>
    80005a28:	fc843503          	ld	a0,-56(s0)
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	4f6080e7          	jalr	1270(ra) # 80004f22 <fdalloc>
    80005a34:	fca42023          	sw	a0,-64(s0)
    80005a38:	06054863          	bltz	a0,80005aa8 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a3c:	4691                	li	a3,4
    80005a3e:	fc440613          	addi	a2,s0,-60
    80005a42:	fd843583          	ld	a1,-40(s0)
    80005a46:	68a8                	ld	a0,80(s1)
    80005a48:	ffffc097          	auipc	ra,0xffffc
    80005a4c:	c82080e7          	jalr	-894(ra) # 800016ca <copyout>
    80005a50:	02054063          	bltz	a0,80005a70 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a54:	4691                	li	a3,4
    80005a56:	fc040613          	addi	a2,s0,-64
    80005a5a:	fd843583          	ld	a1,-40(s0)
    80005a5e:	0591                	addi	a1,a1,4
    80005a60:	68a8                	ld	a0,80(s1)
    80005a62:	ffffc097          	auipc	ra,0xffffc
    80005a66:	c68080e7          	jalr	-920(ra) # 800016ca <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a6a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a6c:	06055563          	bgez	a0,80005ad6 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005a70:	fc442783          	lw	a5,-60(s0)
    80005a74:	07e9                	addi	a5,a5,26
    80005a76:	078e                	slli	a5,a5,0x3
    80005a78:	97a6                	add	a5,a5,s1
    80005a7a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005a7e:	fc042503          	lw	a0,-64(s0)
    80005a82:	0569                	addi	a0,a0,26
    80005a84:	050e                	slli	a0,a0,0x3
    80005a86:	9526                	add	a0,a0,s1
    80005a88:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005a8c:	fd043503          	ld	a0,-48(s0)
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	9fc080e7          	jalr	-1540(ra) # 8000448c <fileclose>
    fileclose(wf);
    80005a98:	fc843503          	ld	a0,-56(s0)
    80005a9c:	fffff097          	auipc	ra,0xfffff
    80005aa0:	9f0080e7          	jalr	-1552(ra) # 8000448c <fileclose>
    return -1;
    80005aa4:	57fd                	li	a5,-1
    80005aa6:	a805                	j	80005ad6 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005aa8:	fc442783          	lw	a5,-60(s0)
    80005aac:	0007c863          	bltz	a5,80005abc <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005ab0:	01a78513          	addi	a0,a5,26
    80005ab4:	050e                	slli	a0,a0,0x3
    80005ab6:	9526                	add	a0,a0,s1
    80005ab8:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005abc:	fd043503          	ld	a0,-48(s0)
    80005ac0:	fffff097          	auipc	ra,0xfffff
    80005ac4:	9cc080e7          	jalr	-1588(ra) # 8000448c <fileclose>
    fileclose(wf);
    80005ac8:	fc843503          	ld	a0,-56(s0)
    80005acc:	fffff097          	auipc	ra,0xfffff
    80005ad0:	9c0080e7          	jalr	-1600(ra) # 8000448c <fileclose>
    return -1;
    80005ad4:	57fd                	li	a5,-1
}
    80005ad6:	853e                	mv	a0,a5
    80005ad8:	70e2                	ld	ra,56(sp)
    80005ada:	7442                	ld	s0,48(sp)
    80005adc:	74a2                	ld	s1,40(sp)
    80005ade:	6121                	addi	sp,sp,64
    80005ae0:	8082                	ret
	...

0000000080005af0 <kernelvec>:
    80005af0:	7111                	addi	sp,sp,-256
    80005af2:	e006                	sd	ra,0(sp)
    80005af4:	e40a                	sd	sp,8(sp)
    80005af6:	e80e                	sd	gp,16(sp)
    80005af8:	ec12                	sd	tp,24(sp)
    80005afa:	f016                	sd	t0,32(sp)
    80005afc:	f41a                	sd	t1,40(sp)
    80005afe:	f81e                	sd	t2,48(sp)
    80005b00:	fc22                	sd	s0,56(sp)
    80005b02:	e0a6                	sd	s1,64(sp)
    80005b04:	e4aa                	sd	a0,72(sp)
    80005b06:	e8ae                	sd	a1,80(sp)
    80005b08:	ecb2                	sd	a2,88(sp)
    80005b0a:	f0b6                	sd	a3,96(sp)
    80005b0c:	f4ba                	sd	a4,104(sp)
    80005b0e:	f8be                	sd	a5,112(sp)
    80005b10:	fcc2                	sd	a6,120(sp)
    80005b12:	e146                	sd	a7,128(sp)
    80005b14:	e54a                	sd	s2,136(sp)
    80005b16:	e94e                	sd	s3,144(sp)
    80005b18:	ed52                	sd	s4,152(sp)
    80005b1a:	f156                	sd	s5,160(sp)
    80005b1c:	f55a                	sd	s6,168(sp)
    80005b1e:	f95e                	sd	s7,176(sp)
    80005b20:	fd62                	sd	s8,184(sp)
    80005b22:	e1e6                	sd	s9,192(sp)
    80005b24:	e5ea                	sd	s10,200(sp)
    80005b26:	e9ee                	sd	s11,208(sp)
    80005b28:	edf2                	sd	t3,216(sp)
    80005b2a:	f1f6                	sd	t4,224(sp)
    80005b2c:	f5fa                	sd	t5,232(sp)
    80005b2e:	f9fe                	sd	t6,240(sp)
    80005b30:	d91fc0ef          	jal	ra,800028c0 <kerneltrap>
    80005b34:	6082                	ld	ra,0(sp)
    80005b36:	6122                	ld	sp,8(sp)
    80005b38:	61c2                	ld	gp,16(sp)
    80005b3a:	7282                	ld	t0,32(sp)
    80005b3c:	7322                	ld	t1,40(sp)
    80005b3e:	73c2                	ld	t2,48(sp)
    80005b40:	7462                	ld	s0,56(sp)
    80005b42:	6486                	ld	s1,64(sp)
    80005b44:	6526                	ld	a0,72(sp)
    80005b46:	65c6                	ld	a1,80(sp)
    80005b48:	6666                	ld	a2,88(sp)
    80005b4a:	7686                	ld	a3,96(sp)
    80005b4c:	7726                	ld	a4,104(sp)
    80005b4e:	77c6                	ld	a5,112(sp)
    80005b50:	7866                	ld	a6,120(sp)
    80005b52:	688a                	ld	a7,128(sp)
    80005b54:	692a                	ld	s2,136(sp)
    80005b56:	69ca                	ld	s3,144(sp)
    80005b58:	6a6a                	ld	s4,152(sp)
    80005b5a:	7a8a                	ld	s5,160(sp)
    80005b5c:	7b2a                	ld	s6,168(sp)
    80005b5e:	7bca                	ld	s7,176(sp)
    80005b60:	7c6a                	ld	s8,184(sp)
    80005b62:	6c8e                	ld	s9,192(sp)
    80005b64:	6d2e                	ld	s10,200(sp)
    80005b66:	6dce                	ld	s11,208(sp)
    80005b68:	6e6e                	ld	t3,216(sp)
    80005b6a:	7e8e                	ld	t4,224(sp)
    80005b6c:	7f2e                	ld	t5,232(sp)
    80005b6e:	7fce                	ld	t6,240(sp)
    80005b70:	6111                	addi	sp,sp,256
    80005b72:	10200073          	sret

0000000080005b76 <unexpected_exc>:
    80005b76:	a001                	j	80005b76 <unexpected_exc>

0000000080005b78 <unexpected_int>:
    80005b78:	a001                	j	80005b78 <unexpected_int>
    80005b7a:	00000013          	nop
    80005b7e:	0001                	nop

0000000080005b80 <timervec>:
    80005b80:	34051573          	csrrw	a0,mscratch,a0
    80005b84:	e10c                	sd	a1,0(a0)
    80005b86:	e510                	sd	a2,8(a0)
    80005b88:	e914                	sd	a3,16(a0)
    80005b8a:	342025f3          	csrr	a1,mcause
    80005b8e:	fe05d4e3          	bgez	a1,80005b76 <unexpected_exc>
    80005b92:	fff0061b          	addiw	a2,zero,-1
    80005b96:	167e                	slli	a2,a2,0x3f
    80005b98:	061d                	addi	a2,a2,7
    80005b9a:	fcc59fe3          	bne	a1,a2,80005b78 <unexpected_int>
    80005b9e:	710c                	ld	a1,32(a0)
    80005ba0:	7510                	ld	a2,40(a0)
    80005ba2:	6194                	ld	a3,0(a1)
    80005ba4:	96b2                	add	a3,a3,a2
    80005ba6:	e194                	sd	a3,0(a1)
    80005ba8:	4589                	li	a1,2
    80005baa:	14459073          	csrw	sip,a1
    80005bae:	6914                	ld	a3,16(a0)
    80005bb0:	6510                	ld	a2,8(a0)
    80005bb2:	610c                	ld	a1,0(a0)
    80005bb4:	34051573          	csrrw	a0,mscratch,a0
    80005bb8:	30200073          	mret
	...

0000000080005bc6 <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bc6:	1141                	addi	sp,sp,-16
    80005bc8:	e422                	sd	s0,8(sp)
    80005bca:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005bcc:	0c0007b7          	lui	a5,0xc000
    80005bd0:	4705                	li	a4,1
    80005bd2:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005bd4:	c3d8                	sw	a4,4(a5)
}
    80005bd6:	6422                	ld	s0,8(sp)
    80005bd8:	0141                	addi	sp,sp,16
    80005bda:	8082                	ret

0000000080005bdc <plicinithart>:

void
plicinithart(void)
{
    80005bdc:	1141                	addi	sp,sp,-16
    80005bde:	e406                	sd	ra,8(sp)
    80005be0:	e022                	sd	s0,0(sp)
    80005be2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005be4:	ffffc097          	auipc	ra,0xffffc
    80005be8:	dc8080e7          	jalr	-568(ra) # 800019ac <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005bec:	0085171b          	slliw	a4,a0,0x8
    80005bf0:	0c0027b7          	lui	a5,0xc002
    80005bf4:	97ba                	add	a5,a5,a4
    80005bf6:	40200713          	li	a4,1026
    80005bfa:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005bfe:	00d5151b          	slliw	a0,a0,0xd
    80005c02:	0c2017b7          	lui	a5,0xc201
    80005c06:	953e                	add	a0,a0,a5
    80005c08:	00052023          	sw	zero,0(a0)
}
    80005c0c:	60a2                	ld	ra,8(sp)
    80005c0e:	6402                	ld	s0,0(sp)
    80005c10:	0141                	addi	sp,sp,16
    80005c12:	8082                	ret

0000000080005c14 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c14:	1141                	addi	sp,sp,-16
    80005c16:	e406                	sd	ra,8(sp)
    80005c18:	e022                	sd	s0,0(sp)
    80005c1a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c1c:	ffffc097          	auipc	ra,0xffffc
    80005c20:	d90080e7          	jalr	-624(ra) # 800019ac <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c24:	00d5179b          	slliw	a5,a0,0xd
    80005c28:	0c201537          	lui	a0,0xc201
    80005c2c:	953e                	add	a0,a0,a5
  return irq;
}
    80005c2e:	4148                	lw	a0,4(a0)
    80005c30:	60a2                	ld	ra,8(sp)
    80005c32:	6402                	ld	s0,0(sp)
    80005c34:	0141                	addi	sp,sp,16
    80005c36:	8082                	ret

0000000080005c38 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c38:	1101                	addi	sp,sp,-32
    80005c3a:	ec06                	sd	ra,24(sp)
    80005c3c:	e822                	sd	s0,16(sp)
    80005c3e:	e426                	sd	s1,8(sp)
    80005c40:	1000                	addi	s0,sp,32
    80005c42:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c44:	ffffc097          	auipc	ra,0xffffc
    80005c48:	d68080e7          	jalr	-664(ra) # 800019ac <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c4c:	00d5151b          	slliw	a0,a0,0xd
    80005c50:	0c2017b7          	lui	a5,0xc201
    80005c54:	97aa                	add	a5,a5,a0
    80005c56:	c3c4                	sw	s1,4(a5)
}
    80005c58:	60e2                	ld	ra,24(sp)
    80005c5a:	6442                	ld	s0,16(sp)
    80005c5c:	64a2                	ld	s1,8(sp)
    80005c5e:	6105                	addi	sp,sp,32
    80005c60:	8082                	ret

0000000080005c62 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c62:	1141                	addi	sp,sp,-16
    80005c64:	e406                	sd	ra,8(sp)
    80005c66:	e022                	sd	s0,0(sp)
    80005c68:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c6a:	479d                	li	a5,7
    80005c6c:	04a7cc63          	blt	a5,a0,80005cc4 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005c70:	0001d797          	auipc	a5,0x1d
    80005c74:	39078793          	addi	a5,a5,912 # 80023000 <disk>
    80005c78:	00a78733          	add	a4,a5,a0
    80005c7c:	6789                	lui	a5,0x2
    80005c7e:	97ba                	add	a5,a5,a4
    80005c80:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005c84:	eba1                	bnez	a5,80005cd4 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005c86:	00451713          	slli	a4,a0,0x4
    80005c8a:	0001f797          	auipc	a5,0x1f
    80005c8e:	3767b783          	ld	a5,886(a5) # 80025000 <disk+0x2000>
    80005c92:	97ba                	add	a5,a5,a4
    80005c94:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005c98:	0001d797          	auipc	a5,0x1d
    80005c9c:	36878793          	addi	a5,a5,872 # 80023000 <disk>
    80005ca0:	97aa                	add	a5,a5,a0
    80005ca2:	6509                	lui	a0,0x2
    80005ca4:	953e                	add	a0,a0,a5
    80005ca6:	4785                	li	a5,1
    80005ca8:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005cac:	0001f517          	auipc	a0,0x1f
    80005cb0:	36c50513          	addi	a0,a0,876 # 80025018 <disk+0x2018>
    80005cb4:	ffffc097          	auipc	ra,0xffffc
    80005cb8:	6b4080e7          	jalr	1716(ra) # 80002368 <wakeup>
}
    80005cbc:	60a2                	ld	ra,8(sp)
    80005cbe:	6402                	ld	s0,0(sp)
    80005cc0:	0141                	addi	sp,sp,16
    80005cc2:	8082                	ret
    panic("virtio_disk_intr 1");
    80005cc4:	00003517          	auipc	a0,0x3
    80005cc8:	a9450513          	addi	a0,a0,-1388 # 80008758 <syscalls+0x330>
    80005ccc:	ffffb097          	auipc	ra,0xffffb
    80005cd0:	884080e7          	jalr	-1916(ra) # 80000550 <panic>
    panic("virtio_disk_intr 2");
    80005cd4:	00003517          	auipc	a0,0x3
    80005cd8:	a9c50513          	addi	a0,a0,-1380 # 80008770 <syscalls+0x348>
    80005cdc:	ffffb097          	auipc	ra,0xffffb
    80005ce0:	874080e7          	jalr	-1932(ra) # 80000550 <panic>

0000000080005ce4 <virtio_disk_init>:
{
    80005ce4:	1101                	addi	sp,sp,-32
    80005ce6:	ec06                	sd	ra,24(sp)
    80005ce8:	e822                	sd	s0,16(sp)
    80005cea:	e426                	sd	s1,8(sp)
    80005cec:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005cee:	00003597          	auipc	a1,0x3
    80005cf2:	a9a58593          	addi	a1,a1,-1382 # 80008788 <syscalls+0x360>
    80005cf6:	0001f517          	auipc	a0,0x1f
    80005cfa:	3b250513          	addi	a0,a0,946 # 800250a8 <disk+0x20a8>
    80005cfe:	ffffb097          	auipc	ra,0xffffb
    80005d02:	e7e080e7          	jalr	-386(ra) # 80000b7c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d06:	100017b7          	lui	a5,0x10001
    80005d0a:	4398                	lw	a4,0(a5)
    80005d0c:	2701                	sext.w	a4,a4
    80005d0e:	747277b7          	lui	a5,0x74727
    80005d12:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d16:	0ef71163          	bne	a4,a5,80005df8 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d1a:	100017b7          	lui	a5,0x10001
    80005d1e:	43dc                	lw	a5,4(a5)
    80005d20:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d22:	4705                	li	a4,1
    80005d24:	0ce79a63          	bne	a5,a4,80005df8 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d28:	100017b7          	lui	a5,0x10001
    80005d2c:	479c                	lw	a5,8(a5)
    80005d2e:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d30:	4709                	li	a4,2
    80005d32:	0ce79363          	bne	a5,a4,80005df8 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d36:	100017b7          	lui	a5,0x10001
    80005d3a:	47d8                	lw	a4,12(a5)
    80005d3c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d3e:	554d47b7          	lui	a5,0x554d4
    80005d42:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d46:	0af71963          	bne	a4,a5,80005df8 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d4a:	100017b7          	lui	a5,0x10001
    80005d4e:	4705                	li	a4,1
    80005d50:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d52:	470d                	li	a4,3
    80005d54:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d56:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005d58:	c7ffe737          	lui	a4,0xc7ffe
    80005d5c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005d60:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d62:	2701                	sext.w	a4,a4
    80005d64:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d66:	472d                	li	a4,11
    80005d68:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d6a:	473d                	li	a4,15
    80005d6c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005d6e:	6705                	lui	a4,0x1
    80005d70:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d72:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d76:	5bdc                	lw	a5,52(a5)
    80005d78:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d7a:	c7d9                	beqz	a5,80005e08 <virtio_disk_init+0x124>
  if(max < NUM)
    80005d7c:	471d                	li	a4,7
    80005d7e:	08f77d63          	bgeu	a4,a5,80005e18 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005d82:	100014b7          	lui	s1,0x10001
    80005d86:	47a1                	li	a5,8
    80005d88:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005d8a:	6609                	lui	a2,0x2
    80005d8c:	4581                	li	a1,0
    80005d8e:	0001d517          	auipc	a0,0x1d
    80005d92:	27250513          	addi	a0,a0,626 # 80023000 <disk>
    80005d96:	ffffb097          	auipc	ra,0xffffb
    80005d9a:	f72080e7          	jalr	-142(ra) # 80000d08 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005d9e:	0001d717          	auipc	a4,0x1d
    80005da2:	26270713          	addi	a4,a4,610 # 80023000 <disk>
    80005da6:	00c75793          	srli	a5,a4,0xc
    80005daa:	2781                	sext.w	a5,a5
    80005dac:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005dae:	0001f797          	auipc	a5,0x1f
    80005db2:	25278793          	addi	a5,a5,594 # 80025000 <disk+0x2000>
    80005db6:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005db8:	0001d717          	auipc	a4,0x1d
    80005dbc:	2c870713          	addi	a4,a4,712 # 80023080 <disk+0x80>
    80005dc0:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005dc2:	0001e717          	auipc	a4,0x1e
    80005dc6:	23e70713          	addi	a4,a4,574 # 80024000 <disk+0x1000>
    80005dca:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005dcc:	4705                	li	a4,1
    80005dce:	00e78c23          	sb	a4,24(a5)
    80005dd2:	00e78ca3          	sb	a4,25(a5)
    80005dd6:	00e78d23          	sb	a4,26(a5)
    80005dda:	00e78da3          	sb	a4,27(a5)
    80005dde:	00e78e23          	sb	a4,28(a5)
    80005de2:	00e78ea3          	sb	a4,29(a5)
    80005de6:	00e78f23          	sb	a4,30(a5)
    80005dea:	00e78fa3          	sb	a4,31(a5)
}
    80005dee:	60e2                	ld	ra,24(sp)
    80005df0:	6442                	ld	s0,16(sp)
    80005df2:	64a2                	ld	s1,8(sp)
    80005df4:	6105                	addi	sp,sp,32
    80005df6:	8082                	ret
    panic("could not find virtio disk");
    80005df8:	00003517          	auipc	a0,0x3
    80005dfc:	9a050513          	addi	a0,a0,-1632 # 80008798 <syscalls+0x370>
    80005e00:	ffffa097          	auipc	ra,0xffffa
    80005e04:	750080e7          	jalr	1872(ra) # 80000550 <panic>
    panic("virtio disk has no queue 0");
    80005e08:	00003517          	auipc	a0,0x3
    80005e0c:	9b050513          	addi	a0,a0,-1616 # 800087b8 <syscalls+0x390>
    80005e10:	ffffa097          	auipc	ra,0xffffa
    80005e14:	740080e7          	jalr	1856(ra) # 80000550 <panic>
    panic("virtio disk max queue too short");
    80005e18:	00003517          	auipc	a0,0x3
    80005e1c:	9c050513          	addi	a0,a0,-1600 # 800087d8 <syscalls+0x3b0>
    80005e20:	ffffa097          	auipc	ra,0xffffa
    80005e24:	730080e7          	jalr	1840(ra) # 80000550 <panic>

0000000080005e28 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005e28:	7175                	addi	sp,sp,-144
    80005e2a:	e506                	sd	ra,136(sp)
    80005e2c:	e122                	sd	s0,128(sp)
    80005e2e:	fca6                	sd	s1,120(sp)
    80005e30:	f8ca                	sd	s2,112(sp)
    80005e32:	f4ce                	sd	s3,104(sp)
    80005e34:	f0d2                	sd	s4,96(sp)
    80005e36:	ecd6                	sd	s5,88(sp)
    80005e38:	e8da                	sd	s6,80(sp)
    80005e3a:	e4de                	sd	s7,72(sp)
    80005e3c:	e0e2                	sd	s8,64(sp)
    80005e3e:	fc66                	sd	s9,56(sp)
    80005e40:	f86a                	sd	s10,48(sp)
    80005e42:	f46e                	sd	s11,40(sp)
    80005e44:	0900                	addi	s0,sp,144
    80005e46:	8aaa                	mv	s5,a0
    80005e48:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e4a:	00c52c83          	lw	s9,12(a0)
    80005e4e:	001c9c9b          	slliw	s9,s9,0x1
    80005e52:	1c82                	slli	s9,s9,0x20
    80005e54:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005e58:	0001f517          	auipc	a0,0x1f
    80005e5c:	25050513          	addi	a0,a0,592 # 800250a8 <disk+0x20a8>
    80005e60:	ffffb097          	auipc	ra,0xffffb
    80005e64:	dac080e7          	jalr	-596(ra) # 80000c0c <acquire>
  for(int i = 0; i < 3; i++){
    80005e68:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005e6a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005e6c:	0001dc17          	auipc	s8,0x1d
    80005e70:	194c0c13          	addi	s8,s8,404 # 80023000 <disk>
    80005e74:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005e76:	4b0d                	li	s6,3
    80005e78:	a0ad                	j	80005ee2 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005e7a:	00fc0733          	add	a4,s8,a5
    80005e7e:	975e                	add	a4,a4,s7
    80005e80:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005e84:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005e86:	0207c563          	bltz	a5,80005eb0 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005e8a:	2905                	addiw	s2,s2,1
    80005e8c:	0611                	addi	a2,a2,4
    80005e8e:	19690d63          	beq	s2,s6,80006028 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80005e92:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005e94:	0001f717          	auipc	a4,0x1f
    80005e98:	18470713          	addi	a4,a4,388 # 80025018 <disk+0x2018>
    80005e9c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005e9e:	00074683          	lbu	a3,0(a4)
    80005ea2:	fee1                	bnez	a3,80005e7a <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005ea4:	2785                	addiw	a5,a5,1
    80005ea6:	0705                	addi	a4,a4,1
    80005ea8:	fe979be3          	bne	a5,s1,80005e9e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005eac:	57fd                	li	a5,-1
    80005eae:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005eb0:	01205d63          	blez	s2,80005eca <virtio_disk_rw+0xa2>
    80005eb4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005eb6:	000a2503          	lw	a0,0(s4)
    80005eba:	00000097          	auipc	ra,0x0
    80005ebe:	da8080e7          	jalr	-600(ra) # 80005c62 <free_desc>
      for(int j = 0; j < i; j++)
    80005ec2:	2d85                	addiw	s11,s11,1
    80005ec4:	0a11                	addi	s4,s4,4
    80005ec6:	ffb918e3          	bne	s2,s11,80005eb6 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005eca:	0001f597          	auipc	a1,0x1f
    80005ece:	1de58593          	addi	a1,a1,478 # 800250a8 <disk+0x20a8>
    80005ed2:	0001f517          	auipc	a0,0x1f
    80005ed6:	14650513          	addi	a0,a0,326 # 80025018 <disk+0x2018>
    80005eda:	ffffc097          	auipc	ra,0xffffc
    80005ede:	30e080e7          	jalr	782(ra) # 800021e8 <sleep>
  for(int i = 0; i < 3; i++){
    80005ee2:	f8040a13          	addi	s4,s0,-128
{
    80005ee6:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005ee8:	894e                	mv	s2,s3
    80005eea:	b765                	j	80005e92 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005eec:	0001f717          	auipc	a4,0x1f
    80005ef0:	11473703          	ld	a4,276(a4) # 80025000 <disk+0x2000>
    80005ef4:	973e                	add	a4,a4,a5
    80005ef6:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005efa:	0001d517          	auipc	a0,0x1d
    80005efe:	10650513          	addi	a0,a0,262 # 80023000 <disk>
    80005f02:	0001f717          	auipc	a4,0x1f
    80005f06:	0fe70713          	addi	a4,a4,254 # 80025000 <disk+0x2000>
    80005f0a:	6314                	ld	a3,0(a4)
    80005f0c:	96be                	add	a3,a3,a5
    80005f0e:	00c6d603          	lhu	a2,12(a3)
    80005f12:	00166613          	ori	a2,a2,1
    80005f16:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005f1a:	f8842683          	lw	a3,-120(s0)
    80005f1e:	6310                	ld	a2,0(a4)
    80005f20:	97b2                	add	a5,a5,a2
    80005f22:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    80005f26:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    80005f2a:	0612                	slli	a2,a2,0x4
    80005f2c:	962a                	add	a2,a2,a0
    80005f2e:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005f32:	00469793          	slli	a5,a3,0x4
    80005f36:	630c                	ld	a1,0(a4)
    80005f38:	95be                	add	a1,a1,a5
    80005f3a:	6689                	lui	a3,0x2
    80005f3c:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80005f40:	96ca                	add	a3,a3,s2
    80005f42:	96aa                	add	a3,a3,a0
    80005f44:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    80005f46:	6314                	ld	a3,0(a4)
    80005f48:	96be                	add	a3,a3,a5
    80005f4a:	4585                	li	a1,1
    80005f4c:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f4e:	6314                	ld	a3,0(a4)
    80005f50:	96be                	add	a3,a3,a5
    80005f52:	4509                	li	a0,2
    80005f54:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    80005f58:	6314                	ld	a3,0(a4)
    80005f5a:	97b6                	add	a5,a5,a3
    80005f5c:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005f60:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005f64:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80005f68:	6714                	ld	a3,8(a4)
    80005f6a:	0026d783          	lhu	a5,2(a3)
    80005f6e:	8b9d                	andi	a5,a5,7
    80005f70:	0789                	addi	a5,a5,2
    80005f72:	0786                	slli	a5,a5,0x1
    80005f74:	97b6                	add	a5,a5,a3
    80005f76:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80005f7a:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80005f7e:	6718                	ld	a4,8(a4)
    80005f80:	00275783          	lhu	a5,2(a4)
    80005f84:	2785                	addiw	a5,a5,1
    80005f86:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005f8a:	100017b7          	lui	a5,0x10001
    80005f8e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005f92:	004aa783          	lw	a5,4(s5)
    80005f96:	02b79163          	bne	a5,a1,80005fb8 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80005f9a:	0001f917          	auipc	s2,0x1f
    80005f9e:	10e90913          	addi	s2,s2,270 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80005fa2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005fa4:	85ca                	mv	a1,s2
    80005fa6:	8556                	mv	a0,s5
    80005fa8:	ffffc097          	auipc	ra,0xffffc
    80005fac:	240080e7          	jalr	576(ra) # 800021e8 <sleep>
  while(b->disk == 1) {
    80005fb0:	004aa783          	lw	a5,4(s5)
    80005fb4:	fe9788e3          	beq	a5,s1,80005fa4 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80005fb8:	f8042483          	lw	s1,-128(s0)
    80005fbc:	20048793          	addi	a5,s1,512
    80005fc0:	00479713          	slli	a4,a5,0x4
    80005fc4:	0001d797          	auipc	a5,0x1d
    80005fc8:	03c78793          	addi	a5,a5,60 # 80023000 <disk>
    80005fcc:	97ba                	add	a5,a5,a4
    80005fce:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80005fd2:	0001f917          	auipc	s2,0x1f
    80005fd6:	02e90913          	addi	s2,s2,46 # 80025000 <disk+0x2000>
    80005fda:	a019                	j	80005fe0 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    80005fdc:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80005fe0:	8526                	mv	a0,s1
    80005fe2:	00000097          	auipc	ra,0x0
    80005fe6:	c80080e7          	jalr	-896(ra) # 80005c62 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80005fea:	0492                	slli	s1,s1,0x4
    80005fec:	00093783          	ld	a5,0(s2)
    80005ff0:	94be                	add	s1,s1,a5
    80005ff2:	00c4d783          	lhu	a5,12(s1)
    80005ff6:	8b85                	andi	a5,a5,1
    80005ff8:	f3f5                	bnez	a5,80005fdc <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005ffa:	0001f517          	auipc	a0,0x1f
    80005ffe:	0ae50513          	addi	a0,a0,174 # 800250a8 <disk+0x20a8>
    80006002:	ffffb097          	auipc	ra,0xffffb
    80006006:	cbe080e7          	jalr	-834(ra) # 80000cc0 <release>
}
    8000600a:	60aa                	ld	ra,136(sp)
    8000600c:	640a                	ld	s0,128(sp)
    8000600e:	74e6                	ld	s1,120(sp)
    80006010:	7946                	ld	s2,112(sp)
    80006012:	79a6                	ld	s3,104(sp)
    80006014:	7a06                	ld	s4,96(sp)
    80006016:	6ae6                	ld	s5,88(sp)
    80006018:	6b46                	ld	s6,80(sp)
    8000601a:	6ba6                	ld	s7,72(sp)
    8000601c:	6c06                	ld	s8,64(sp)
    8000601e:	7ce2                	ld	s9,56(sp)
    80006020:	7d42                	ld	s10,48(sp)
    80006022:	7da2                	ld	s11,40(sp)
    80006024:	6149                	addi	sp,sp,144
    80006026:	8082                	ret
  if(write)
    80006028:	01a037b3          	snez	a5,s10
    8000602c:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006030:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006034:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006038:	f8042483          	lw	s1,-128(s0)
    8000603c:	00449913          	slli	s2,s1,0x4
    80006040:	0001f997          	auipc	s3,0x1f
    80006044:	fc098993          	addi	s3,s3,-64 # 80025000 <disk+0x2000>
    80006048:	0009ba03          	ld	s4,0(s3)
    8000604c:	9a4a                	add	s4,s4,s2
    8000604e:	f7040513          	addi	a0,s0,-144
    80006052:	ffffb097          	auipc	ra,0xffffb
    80006056:	086080e7          	jalr	134(ra) # 800010d8 <kvmpa>
    8000605a:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000605e:	0009b783          	ld	a5,0(s3)
    80006062:	97ca                	add	a5,a5,s2
    80006064:	4741                	li	a4,16
    80006066:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006068:	0009b783          	ld	a5,0(s3)
    8000606c:	97ca                	add	a5,a5,s2
    8000606e:	4705                	li	a4,1
    80006070:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006074:	f8442783          	lw	a5,-124(s0)
    80006078:	0009b703          	ld	a4,0(s3)
    8000607c:	974a                	add	a4,a4,s2
    8000607e:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006082:	0792                	slli	a5,a5,0x4
    80006084:	0009b703          	ld	a4,0(s3)
    80006088:	973e                	add	a4,a4,a5
    8000608a:	058a8693          	addi	a3,s5,88
    8000608e:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    80006090:	0009b703          	ld	a4,0(s3)
    80006094:	973e                	add	a4,a4,a5
    80006096:	40000693          	li	a3,1024
    8000609a:	c714                	sw	a3,8(a4)
  if(write)
    8000609c:	e40d18e3          	bnez	s10,80005eec <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800060a0:	0001f717          	auipc	a4,0x1f
    800060a4:	f6073703          	ld	a4,-160(a4) # 80025000 <disk+0x2000>
    800060a8:	973e                	add	a4,a4,a5
    800060aa:	4689                	li	a3,2
    800060ac:	00d71623          	sh	a3,12(a4)
    800060b0:	b5a9                	j	80005efa <virtio_disk_rw+0xd2>

00000000800060b2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800060b2:	1101                	addi	sp,sp,-32
    800060b4:	ec06                	sd	ra,24(sp)
    800060b6:	e822                	sd	s0,16(sp)
    800060b8:	e426                	sd	s1,8(sp)
    800060ba:	e04a                	sd	s2,0(sp)
    800060bc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800060be:	0001f517          	auipc	a0,0x1f
    800060c2:	fea50513          	addi	a0,a0,-22 # 800250a8 <disk+0x20a8>
    800060c6:	ffffb097          	auipc	ra,0xffffb
    800060ca:	b46080e7          	jalr	-1210(ra) # 80000c0c <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800060ce:	0001f717          	auipc	a4,0x1f
    800060d2:	f3270713          	addi	a4,a4,-206 # 80025000 <disk+0x2000>
    800060d6:	02075783          	lhu	a5,32(a4)
    800060da:	6b18                	ld	a4,16(a4)
    800060dc:	00275683          	lhu	a3,2(a4)
    800060e0:	8ebd                	xor	a3,a3,a5
    800060e2:	8a9d                	andi	a3,a3,7
    800060e4:	cab9                	beqz	a3,8000613a <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800060e6:	0001d917          	auipc	s2,0x1d
    800060ea:	f1a90913          	addi	s2,s2,-230 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800060ee:	0001f497          	auipc	s1,0x1f
    800060f2:	f1248493          	addi	s1,s1,-238 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800060f6:	078e                	slli	a5,a5,0x3
    800060f8:	97ba                	add	a5,a5,a4
    800060fa:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800060fc:	20078713          	addi	a4,a5,512
    80006100:	0712                	slli	a4,a4,0x4
    80006102:	974a                	add	a4,a4,s2
    80006104:	03074703          	lbu	a4,48(a4)
    80006108:	ef21                	bnez	a4,80006160 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000610a:	20078793          	addi	a5,a5,512
    8000610e:	0792                	slli	a5,a5,0x4
    80006110:	97ca                	add	a5,a5,s2
    80006112:	7798                	ld	a4,40(a5)
    80006114:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006118:	7788                	ld	a0,40(a5)
    8000611a:	ffffc097          	auipc	ra,0xffffc
    8000611e:	24e080e7          	jalr	590(ra) # 80002368 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006122:	0204d783          	lhu	a5,32(s1)
    80006126:	2785                	addiw	a5,a5,1
    80006128:	8b9d                	andi	a5,a5,7
    8000612a:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    8000612e:	6898                	ld	a4,16(s1)
    80006130:	00275683          	lhu	a3,2(a4)
    80006134:	8a9d                	andi	a3,a3,7
    80006136:	fcf690e3          	bne	a3,a5,800060f6 <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000613a:	10001737          	lui	a4,0x10001
    8000613e:	533c                	lw	a5,96(a4)
    80006140:	8b8d                	andi	a5,a5,3
    80006142:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006144:	0001f517          	auipc	a0,0x1f
    80006148:	f6450513          	addi	a0,a0,-156 # 800250a8 <disk+0x20a8>
    8000614c:	ffffb097          	auipc	ra,0xffffb
    80006150:	b74080e7          	jalr	-1164(ra) # 80000cc0 <release>
}
    80006154:	60e2                	ld	ra,24(sp)
    80006156:	6442                	ld	s0,16(sp)
    80006158:	64a2                	ld	s1,8(sp)
    8000615a:	6902                	ld	s2,0(sp)
    8000615c:	6105                	addi	sp,sp,32
    8000615e:	8082                	ret
      panic("virtio_disk_intr status");
    80006160:	00002517          	auipc	a0,0x2
    80006164:	69850513          	addi	a0,a0,1688 # 800087f8 <syscalls+0x3d0>
    80006168:	ffffa097          	auipc	ra,0xffffa
    8000616c:	3e8080e7          	jalr	1000(ra) # 80000550 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
