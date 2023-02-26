
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
    80000060:	c7478793          	addi	a5,a5,-908 # 80005cd0 <timervec>
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
    800000aa:	e5a78793          	addi	a5,a5,-422 # 80000f00 <main>
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
    8000011e:	b3c080e7          	jalr	-1220(ra) # 80000c56 <acquire>
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
    80000138:	3ba080e7          	jalr	954(ra) # 800024ee <either_copyin>
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
    80000160:	bae080e7          	jalr	-1106(ra) # 80000d0a <release>

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
    800001ae:	aac080e7          	jalr	-1364(ra) # 80000c56 <acquire>
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
    800001dc:	84a080e7          	jalr	-1974(ra) # 80001a22 <myproc>
    800001e0:	591c                	lw	a5,48(a0)
    800001e2:	e7b5                	bnez	a5,8000024e <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001e4:	85a6                	mv	a1,s1
    800001e6:	854a                	mv	a0,s2
    800001e8:	00002097          	auipc	ra,0x2
    800001ec:	056080e7          	jalr	86(ra) # 8000223e <sleep>
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
    80000228:	274080e7          	jalr	628(ra) # 80002498 <either_copyout>
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
    80000244:	aca080e7          	jalr	-1334(ra) # 80000d0a <release>

  return target - n;
    80000248:	413b053b          	subw	a0,s6,s3
    8000024c:	a811                	j	80000260 <consoleread+0xe4>
        release(&cons.lock);
    8000024e:	00011517          	auipc	a0,0x11
    80000252:	5e250513          	addi	a0,a0,1506 # 80011830 <cons>
    80000256:	00001097          	auipc	ra,0x1
    8000025a:	ab4080e7          	jalr	-1356(ra) # 80000d0a <release>
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
    800002ea:	970080e7          	jalr	-1680(ra) # 80000c56 <acquire>

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
    80000308:	240080e7          	jalr	576(ra) # 80002544 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030c:	00011517          	auipc	a0,0x11
    80000310:	52450513          	addi	a0,a0,1316 # 80011830 <cons>
    80000314:	00001097          	auipc	ra,0x1
    80000318:	9f6080e7          	jalr	-1546(ra) # 80000d0a <release>
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
    8000045c:	f66080e7          	jalr	-154(ra) # 800023be <wakeup>
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
    8000047e:	74c080e7          	jalr	1868(ra) # 80000bc6 <initlock>

  uartinit();
    80000482:	00000097          	auipc	ra,0x0
    80000486:	32a080e7          	jalr	810(ra) # 800007ac <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000048a:	00021797          	auipc	a5,0x21
    8000048e:	72678793          	addi	a5,a5,1830 # 80021bb0 <devsw>
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
    80000616:	644080e7          	jalr	1604(ra) # 80000c56 <acquire>
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
    80000774:	59a080e7          	jalr	1434(ra) # 80000d0a <release>
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
    8000079a:	430080e7          	jalr	1072(ra) # 80000bc6 <initlock>
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
    800007f0:	3da080e7          	jalr	986(ra) # 80000bc6 <initlock>
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
    8000080c:	402080e7          	jalr	1026(ra) # 80000c0a <push_off>

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
    8000083a:	474080e7          	jalr	1140(ra) # 80000caa <pop_off>
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
    800008b4:	b0e080e7          	jalr	-1266(ra) # 800023be <wakeup>
    
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
    800008f8:	362080e7          	jalr	866(ra) # 80000c56 <acquire>
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
    8000094e:	8f4080e7          	jalr	-1804(ra) # 8000223e <sleep>
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
    80000994:	37a080e7          	jalr	890(ra) # 80000d0a <release>
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
    80000a00:	25a080e7          	jalr	602(ra) # 80000c56 <acquire>
  uartstart();
    80000a04:	00000097          	auipc	ra,0x0
    80000a08:	e44080e7          	jalr	-444(ra) # 80000848 <uartstart>
  release(&uart_tx_lock);
    80000a0c:	8526                	mv	a0,s1
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	2fc080e7          	jalr	764(ra) # 80000d0a <release>
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
    80000a50:	306080e7          	jalr	774(ra) # 80000d52 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a54:	00011917          	auipc	s2,0x11
    80000a58:	edc90913          	addi	s2,s2,-292 # 80011930 <kmem>
    80000a5c:	854a                	mv	a0,s2
    80000a5e:	00000097          	auipc	ra,0x0
    80000a62:	1f8080e7          	jalr	504(ra) # 80000c56 <acquire>
  r->next = kmem.freelist;
    80000a66:	01893783          	ld	a5,24(s2)
    80000a6a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a6c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a70:	854a                	mv	a0,s2
    80000a72:	00000097          	auipc	ra,0x0
    80000a76:	298080e7          	jalr	664(ra) # 80000d0a <release>
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
    80000afc:	0ce080e7          	jalr	206(ra) # 80000bc6 <initlock>
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
    80000b34:	126080e7          	jalr	294(ra) # 80000c56 <acquire>
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
    80000b4c:	1c2080e7          	jalr	450(ra) # 80000d0a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	1fc080e7          	jalr	508(ra) # 80000d52 <memset>
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
    80000b76:	198080e7          	jalr	408(ra) # 80000d0a <release>
  if(r)
    80000b7a:	b7d5                	j	80000b5e <kalloc+0x42>

0000000080000b7c <count_free_mem>:

uint64
count_free_mem(void) // added for counting free memory in bytes (lab2)
{
    80000b7c:	1101                	addi	sp,sp,-32
    80000b7e:	ec06                	sd	ra,24(sp)
    80000b80:	e822                	sd	s0,16(sp)
    80000b82:	e426                	sd	s1,8(sp)
    80000b84:	1000                	addi	s0,sp,32
  acquire(&kmem.lock);
    80000b86:	00011497          	auipc	s1,0x11
    80000b8a:	daa48493          	addi	s1,s1,-598 # 80011930 <kmem>
    80000b8e:	8526                	mv	a0,s1
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	0c6080e7          	jalr	198(ra) # 80000c56 <acquire>
  uint64 mem_bytes = 0;
  struct run *r = kmem.freelist;
    80000b98:	6c9c                	ld	a5,24(s1)
  while(r){
    80000b9a:	c785                	beqz	a5,80000bc2 <count_free_mem+0x46>
  uint64 mem_bytes = 0;
    80000b9c:	4481                	li	s1,0
    mem_bytes += PGSIZE;
    80000b9e:	6705                	lui	a4,0x1
    80000ba0:	94ba                	add	s1,s1,a4
    r = r->next;
    80000ba2:	639c                	ld	a5,0(a5)
  while(r){
    80000ba4:	fff5                	bnez	a5,80000ba0 <count_free_mem+0x24>
  }
  release(&kmem.lock);
    80000ba6:	00011517          	auipc	a0,0x11
    80000baa:	d8a50513          	addi	a0,a0,-630 # 80011930 <kmem>
    80000bae:	00000097          	auipc	ra,0x0
    80000bb2:	15c080e7          	jalr	348(ra) # 80000d0a <release>
  return mem_bytes;
    80000bb6:	8526                	mv	a0,s1
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
  uint64 mem_bytes = 0;
    80000bc2:	4481                	li	s1,0
    80000bc4:	b7cd                	j	80000ba6 <count_free_mem+0x2a>

0000000080000bc6 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bc6:	1141                	addi	sp,sp,-16
    80000bc8:	e422                	sd	s0,8(sp)
    80000bca:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bcc:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bce:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bd2:	00053823          	sd	zero,16(a0)
}
    80000bd6:	6422                	ld	s0,8(sp)
    80000bd8:	0141                	addi	sp,sp,16
    80000bda:	8082                	ret

0000000080000bdc <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bdc:	411c                	lw	a5,0(a0)
    80000bde:	e399                	bnez	a5,80000be4 <holding+0x8>
    80000be0:	4501                	li	a0,0
  return r;
}
    80000be2:	8082                	ret
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bee:	6904                	ld	s1,16(a0)
    80000bf0:	00001097          	auipc	ra,0x1
    80000bf4:	e16080e7          	jalr	-490(ra) # 80001a06 <mycpu>
    80000bf8:	40a48533          	sub	a0,s1,a0
    80000bfc:	00153513          	seqz	a0,a0
}
    80000c00:	60e2                	ld	ra,24(sp)
    80000c02:	6442                	ld	s0,16(sp)
    80000c04:	64a2                	ld	s1,8(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret

0000000080000c0a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c0a:	1101                	addi	sp,sp,-32
    80000c0c:	ec06                	sd	ra,24(sp)
    80000c0e:	e822                	sd	s0,16(sp)
    80000c10:	e426                	sd	s1,8(sp)
    80000c12:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c14:	100024f3          	csrr	s1,sstatus
    80000c18:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c1c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c1e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c22:	00001097          	auipc	ra,0x1
    80000c26:	de4080e7          	jalr	-540(ra) # 80001a06 <mycpu>
    80000c2a:	5d3c                	lw	a5,120(a0)
    80000c2c:	cf89                	beqz	a5,80000c46 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	dd8080e7          	jalr	-552(ra) # 80001a06 <mycpu>
    80000c36:	5d3c                	lw	a5,120(a0)
    80000c38:	2785                	addiw	a5,a5,1
    80000c3a:	dd3c                	sw	a5,120(a0)
}
    80000c3c:	60e2                	ld	ra,24(sp)
    80000c3e:	6442                	ld	s0,16(sp)
    80000c40:	64a2                	ld	s1,8(sp)
    80000c42:	6105                	addi	sp,sp,32
    80000c44:	8082                	ret
    mycpu()->intena = old;
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	dc0080e7          	jalr	-576(ra) # 80001a06 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c4e:	8085                	srli	s1,s1,0x1
    80000c50:	8885                	andi	s1,s1,1
    80000c52:	dd64                	sw	s1,124(a0)
    80000c54:	bfe9                	j	80000c2e <push_off+0x24>

0000000080000c56 <acquire>:
{
    80000c56:	1101                	addi	sp,sp,-32
    80000c58:	ec06                	sd	ra,24(sp)
    80000c5a:	e822                	sd	s0,16(sp)
    80000c5c:	e426                	sd	s1,8(sp)
    80000c5e:	1000                	addi	s0,sp,32
    80000c60:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c62:	00000097          	auipc	ra,0x0
    80000c66:	fa8080e7          	jalr	-88(ra) # 80000c0a <push_off>
  if(holding(lk))
    80000c6a:	8526                	mv	a0,s1
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	f70080e7          	jalr	-144(ra) # 80000bdc <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c74:	4705                	li	a4,1
  if(holding(lk))
    80000c76:	e115                	bnez	a0,80000c9a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c78:	87ba                	mv	a5,a4
    80000c7a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c7e:	2781                	sext.w	a5,a5
    80000c80:	ffe5                	bnez	a5,80000c78 <acquire+0x22>
  __sync_synchronize();
    80000c82:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c86:	00001097          	auipc	ra,0x1
    80000c8a:	d80080e7          	jalr	-640(ra) # 80001a06 <mycpu>
    80000c8e:	e888                	sd	a0,16(s1)
}
    80000c90:	60e2                	ld	ra,24(sp)
    80000c92:	6442                	ld	s0,16(sp)
    80000c94:	64a2                	ld	s1,8(sp)
    80000c96:	6105                	addi	sp,sp,32
    80000c98:	8082                	ret
    panic("acquire");
    80000c9a:	00007517          	auipc	a0,0x7
    80000c9e:	3d650513          	addi	a0,a0,982 # 80008070 <digits+0x30>
    80000ca2:	00000097          	auipc	ra,0x0
    80000ca6:	8ae080e7          	jalr	-1874(ra) # 80000550 <panic>

0000000080000caa <pop_off>:

void
pop_off(void)
{
    80000caa:	1141                	addi	sp,sp,-16
    80000cac:	e406                	sd	ra,8(sp)
    80000cae:	e022                	sd	s0,0(sp)
    80000cb0:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cb2:	00001097          	auipc	ra,0x1
    80000cb6:	d54080e7          	jalr	-684(ra) # 80001a06 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cbe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cc0:	e78d                	bnez	a5,80000cea <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cc2:	5d3c                	lw	a5,120(a0)
    80000cc4:	02f05b63          	blez	a5,80000cfa <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cc8:	37fd                	addiw	a5,a5,-1
    80000cca:	0007871b          	sext.w	a4,a5
    80000cce:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cd0:	eb09                	bnez	a4,80000ce2 <pop_off+0x38>
    80000cd2:	5d7c                	lw	a5,124(a0)
    80000cd4:	c799                	beqz	a5,80000ce2 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cda:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cde:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ce2:	60a2                	ld	ra,8(sp)
    80000ce4:	6402                	ld	s0,0(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret
    panic("pop_off - interruptible");
    80000cea:	00007517          	auipc	a0,0x7
    80000cee:	38e50513          	addi	a0,a0,910 # 80008078 <digits+0x38>
    80000cf2:	00000097          	auipc	ra,0x0
    80000cf6:	85e080e7          	jalr	-1954(ra) # 80000550 <panic>
    panic("pop_off");
    80000cfa:	00007517          	auipc	a0,0x7
    80000cfe:	39650513          	addi	a0,a0,918 # 80008090 <digits+0x50>
    80000d02:	00000097          	auipc	ra,0x0
    80000d06:	84e080e7          	jalr	-1970(ra) # 80000550 <panic>

0000000080000d0a <release>:
{
    80000d0a:	1101                	addi	sp,sp,-32
    80000d0c:	ec06                	sd	ra,24(sp)
    80000d0e:	e822                	sd	s0,16(sp)
    80000d10:	e426                	sd	s1,8(sp)
    80000d12:	1000                	addi	s0,sp,32
    80000d14:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d16:	00000097          	auipc	ra,0x0
    80000d1a:	ec6080e7          	jalr	-314(ra) # 80000bdc <holding>
    80000d1e:	c115                	beqz	a0,80000d42 <release+0x38>
  lk->cpu = 0;
    80000d20:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d24:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d28:	0f50000f          	fence	iorw,ow
    80000d2c:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d30:	00000097          	auipc	ra,0x0
    80000d34:	f7a080e7          	jalr	-134(ra) # 80000caa <pop_off>
}
    80000d38:	60e2                	ld	ra,24(sp)
    80000d3a:	6442                	ld	s0,16(sp)
    80000d3c:	64a2                	ld	s1,8(sp)
    80000d3e:	6105                	addi	sp,sp,32
    80000d40:	8082                	ret
    panic("release");
    80000d42:	00007517          	auipc	a0,0x7
    80000d46:	35650513          	addi	a0,a0,854 # 80008098 <digits+0x58>
    80000d4a:	00000097          	auipc	ra,0x0
    80000d4e:	806080e7          	jalr	-2042(ra) # 80000550 <panic>

0000000080000d52 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d52:	1141                	addi	sp,sp,-16
    80000d54:	e422                	sd	s0,8(sp)
    80000d56:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d58:	ca19                	beqz	a2,80000d6e <memset+0x1c>
    80000d5a:	87aa                	mv	a5,a0
    80000d5c:	1602                	slli	a2,a2,0x20
    80000d5e:	9201                	srli	a2,a2,0x20
    80000d60:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d64:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d68:	0785                	addi	a5,a5,1
    80000d6a:	fee79de3          	bne	a5,a4,80000d64 <memset+0x12>
  }
  return dst;
}
    80000d6e:	6422                	ld	s0,8(sp)
    80000d70:	0141                	addi	sp,sp,16
    80000d72:	8082                	ret

0000000080000d74 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d74:	1141                	addi	sp,sp,-16
    80000d76:	e422                	sd	s0,8(sp)
    80000d78:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d7a:	ca05                	beqz	a2,80000daa <memcmp+0x36>
    80000d7c:	fff6069b          	addiw	a3,a2,-1
    80000d80:	1682                	slli	a3,a3,0x20
    80000d82:	9281                	srli	a3,a3,0x20
    80000d84:	0685                	addi	a3,a3,1
    80000d86:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d88:	00054783          	lbu	a5,0(a0)
    80000d8c:	0005c703          	lbu	a4,0(a1)
    80000d90:	00e79863          	bne	a5,a4,80000da0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d94:	0505                	addi	a0,a0,1
    80000d96:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d98:	fed518e3          	bne	a0,a3,80000d88 <memcmp+0x14>
  }

  return 0;
    80000d9c:	4501                	li	a0,0
    80000d9e:	a019                	j	80000da4 <memcmp+0x30>
      return *s1 - *s2;
    80000da0:	40e7853b          	subw	a0,a5,a4
}
    80000da4:	6422                	ld	s0,8(sp)
    80000da6:	0141                	addi	sp,sp,16
    80000da8:	8082                	ret
  return 0;
    80000daa:	4501                	li	a0,0
    80000dac:	bfe5                	j	80000da4 <memcmp+0x30>

0000000080000dae <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dae:	1141                	addi	sp,sp,-16
    80000db0:	e422                	sd	s0,8(sp)
    80000db2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000db4:	02a5e563          	bltu	a1,a0,80000dde <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000db8:	fff6069b          	addiw	a3,a2,-1
    80000dbc:	ce11                	beqz	a2,80000dd8 <memmove+0x2a>
    80000dbe:	1682                	slli	a3,a3,0x20
    80000dc0:	9281                	srli	a3,a3,0x20
    80000dc2:	0685                	addi	a3,a3,1
    80000dc4:	96ae                	add	a3,a3,a1
    80000dc6:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000dc8:	0585                	addi	a1,a1,1
    80000dca:	0785                	addi	a5,a5,1
    80000dcc:	fff5c703          	lbu	a4,-1(a1)
    80000dd0:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dd4:	fed59ae3          	bne	a1,a3,80000dc8 <memmove+0x1a>

  return dst;
}
    80000dd8:	6422                	ld	s0,8(sp)
    80000dda:	0141                	addi	sp,sp,16
    80000ddc:	8082                	ret
  if(s < d && s + n > d){
    80000dde:	02061713          	slli	a4,a2,0x20
    80000de2:	9301                	srli	a4,a4,0x20
    80000de4:	00e587b3          	add	a5,a1,a4
    80000de8:	fcf578e3          	bgeu	a0,a5,80000db8 <memmove+0xa>
    d += n;
    80000dec:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000dee:	fff6069b          	addiw	a3,a2,-1
    80000df2:	d27d                	beqz	a2,80000dd8 <memmove+0x2a>
    80000df4:	02069613          	slli	a2,a3,0x20
    80000df8:	9201                	srli	a2,a2,0x20
    80000dfa:	fff64613          	not	a2,a2
    80000dfe:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e00:	17fd                	addi	a5,a5,-1
    80000e02:	177d                	addi	a4,a4,-1
    80000e04:	0007c683          	lbu	a3,0(a5)
    80000e08:	00d70023          	sb	a3,0(a4) # 1000 <_entry-0x7ffff000>
    while(n-- > 0)
    80000e0c:	fef61ae3          	bne	a2,a5,80000e00 <memmove+0x52>
    80000e10:	b7e1                	j	80000dd8 <memmove+0x2a>

0000000080000e12 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e406                	sd	ra,8(sp)
    80000e16:	e022                	sd	s0,0(sp)
    80000e18:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e1a:	00000097          	auipc	ra,0x0
    80000e1e:	f94080e7          	jalr	-108(ra) # 80000dae <memmove>
}
    80000e22:	60a2                	ld	ra,8(sp)
    80000e24:	6402                	ld	s0,0(sp)
    80000e26:	0141                	addi	sp,sp,16
    80000e28:	8082                	ret

0000000080000e2a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e2a:	1141                	addi	sp,sp,-16
    80000e2c:	e422                	sd	s0,8(sp)
    80000e2e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e30:	ce11                	beqz	a2,80000e4c <strncmp+0x22>
    80000e32:	00054783          	lbu	a5,0(a0)
    80000e36:	cf89                	beqz	a5,80000e50 <strncmp+0x26>
    80000e38:	0005c703          	lbu	a4,0(a1)
    80000e3c:	00f71a63          	bne	a4,a5,80000e50 <strncmp+0x26>
    n--, p++, q++;
    80000e40:	367d                	addiw	a2,a2,-1
    80000e42:	0505                	addi	a0,a0,1
    80000e44:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e46:	f675                	bnez	a2,80000e32 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e48:	4501                	li	a0,0
    80000e4a:	a809                	j	80000e5c <strncmp+0x32>
    80000e4c:	4501                	li	a0,0
    80000e4e:	a039                	j	80000e5c <strncmp+0x32>
  if(n == 0)
    80000e50:	ca09                	beqz	a2,80000e62 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e52:	00054503          	lbu	a0,0(a0)
    80000e56:	0005c783          	lbu	a5,0(a1)
    80000e5a:	9d1d                	subw	a0,a0,a5
}
    80000e5c:	6422                	ld	s0,8(sp)
    80000e5e:	0141                	addi	sp,sp,16
    80000e60:	8082                	ret
    return 0;
    80000e62:	4501                	li	a0,0
    80000e64:	bfe5                	j	80000e5c <strncmp+0x32>

0000000080000e66 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e66:	1141                	addi	sp,sp,-16
    80000e68:	e422                	sd	s0,8(sp)
    80000e6a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e6c:	872a                	mv	a4,a0
    80000e6e:	8832                	mv	a6,a2
    80000e70:	367d                	addiw	a2,a2,-1
    80000e72:	01005963          	blez	a6,80000e84 <strncpy+0x1e>
    80000e76:	0705                	addi	a4,a4,1
    80000e78:	0005c783          	lbu	a5,0(a1)
    80000e7c:	fef70fa3          	sb	a5,-1(a4)
    80000e80:	0585                	addi	a1,a1,1
    80000e82:	f7f5                	bnez	a5,80000e6e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e84:	86ba                	mv	a3,a4
    80000e86:	00c05c63          	blez	a2,80000e9e <strncpy+0x38>
    *s++ = 0;
    80000e8a:	0685                	addi	a3,a3,1
    80000e8c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e90:	fff6c793          	not	a5,a3
    80000e94:	9fb9                	addw	a5,a5,a4
    80000e96:	010787bb          	addw	a5,a5,a6
    80000e9a:	fef048e3          	bgtz	a5,80000e8a <strncpy+0x24>
  return os;
}
    80000e9e:	6422                	ld	s0,8(sp)
    80000ea0:	0141                	addi	sp,sp,16
    80000ea2:	8082                	ret

0000000080000ea4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ea4:	1141                	addi	sp,sp,-16
    80000ea6:	e422                	sd	s0,8(sp)
    80000ea8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eaa:	02c05363          	blez	a2,80000ed0 <safestrcpy+0x2c>
    80000eae:	fff6069b          	addiw	a3,a2,-1
    80000eb2:	1682                	slli	a3,a3,0x20
    80000eb4:	9281                	srli	a3,a3,0x20
    80000eb6:	96ae                	add	a3,a3,a1
    80000eb8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000eba:	00d58963          	beq	a1,a3,80000ecc <safestrcpy+0x28>
    80000ebe:	0585                	addi	a1,a1,1
    80000ec0:	0785                	addi	a5,a5,1
    80000ec2:	fff5c703          	lbu	a4,-1(a1)
    80000ec6:	fee78fa3          	sb	a4,-1(a5)
    80000eca:	fb65                	bnez	a4,80000eba <safestrcpy+0x16>
    ;
  *s = 0;
    80000ecc:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ed0:	6422                	ld	s0,8(sp)
    80000ed2:	0141                	addi	sp,sp,16
    80000ed4:	8082                	ret

0000000080000ed6 <strlen>:

int
strlen(const char *s)
{
    80000ed6:	1141                	addi	sp,sp,-16
    80000ed8:	e422                	sd	s0,8(sp)
    80000eda:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000edc:	00054783          	lbu	a5,0(a0)
    80000ee0:	cf91                	beqz	a5,80000efc <strlen+0x26>
    80000ee2:	0505                	addi	a0,a0,1
    80000ee4:	87aa                	mv	a5,a0
    80000ee6:	4685                	li	a3,1
    80000ee8:	9e89                	subw	a3,a3,a0
    80000eea:	00f6853b          	addw	a0,a3,a5
    80000eee:	0785                	addi	a5,a5,1
    80000ef0:	fff7c703          	lbu	a4,-1(a5)
    80000ef4:	fb7d                	bnez	a4,80000eea <strlen+0x14>
    ;
  return n;
}
    80000ef6:	6422                	ld	s0,8(sp)
    80000ef8:	0141                	addi	sp,sp,16
    80000efa:	8082                	ret
  for(n = 0; s[n]; n++)
    80000efc:	4501                	li	a0,0
    80000efe:	bfe5                	j	80000ef6 <strlen+0x20>

0000000080000f00 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f00:	1141                	addi	sp,sp,-16
    80000f02:	e406                	sd	ra,8(sp)
    80000f04:	e022                	sd	s0,0(sp)
    80000f06:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f08:	00001097          	auipc	ra,0x1
    80000f0c:	aee080e7          	jalr	-1298(ra) # 800019f6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f10:	00008717          	auipc	a4,0x8
    80000f14:	0fc70713          	addi	a4,a4,252 # 8000900c <started>
  if(cpuid() == 0){
    80000f18:	c139                	beqz	a0,80000f5e <main+0x5e>
    while(started == 0)
    80000f1a:	431c                	lw	a5,0(a4)
    80000f1c:	2781                	sext.w	a5,a5
    80000f1e:	dff5                	beqz	a5,80000f1a <main+0x1a>
      ;
    __sync_synchronize();
    80000f20:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f24:	00001097          	auipc	ra,0x1
    80000f28:	ad2080e7          	jalr	-1326(ra) # 800019f6 <cpuid>
    80000f2c:	85aa                	mv	a1,a0
    80000f2e:	00007517          	auipc	a0,0x7
    80000f32:	18a50513          	addi	a0,a0,394 # 800080b8 <digits+0x78>
    80000f36:	fffff097          	auipc	ra,0xfffff
    80000f3a:	664080e7          	jalr	1636(ra) # 8000059a <printf>
    kvminithart();    // turn on paging
    80000f3e:	00000097          	auipc	ra,0x0
    80000f42:	0d8080e7          	jalr	216(ra) # 80001016 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	76c080e7          	jalr	1900(ra) # 800026b2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	dde080e7          	jalr	-546(ra) # 80005d2c <plicinithart>
  }

  scheduler();        
    80000f56:	00001097          	auipc	ra,0x1
    80000f5a:	00c080e7          	jalr	12(ra) # 80001f62 <scheduler>
    consoleinit();
    80000f5e:	fffff097          	auipc	ra,0xfffff
    80000f62:	504080e7          	jalr	1284(ra) # 80000462 <consoleinit>
    printfinit();
    80000f66:	00000097          	auipc	ra,0x0
    80000f6a:	814080e7          	jalr	-2028(ra) # 8000077a <printfinit>
    printf("\n");
    80000f6e:	00007517          	auipc	a0,0x7
    80000f72:	15a50513          	addi	a0,a0,346 # 800080c8 <digits+0x88>
    80000f76:	fffff097          	auipc	ra,0xfffff
    80000f7a:	624080e7          	jalr	1572(ra) # 8000059a <printf>
    printf("xv6 kernel is booting\n");
    80000f7e:	00007517          	auipc	a0,0x7
    80000f82:	12250513          	addi	a0,a0,290 # 800080a0 <digits+0x60>
    80000f86:	fffff097          	auipc	ra,0xfffff
    80000f8a:	614080e7          	jalr	1556(ra) # 8000059a <printf>
    printf("\n");
    80000f8e:	00007517          	auipc	a0,0x7
    80000f92:	13a50513          	addi	a0,a0,314 # 800080c8 <digits+0x88>
    80000f96:	fffff097          	auipc	ra,0xfffff
    80000f9a:	604080e7          	jalr	1540(ra) # 8000059a <printf>
    kinit();         // physical page allocator
    80000f9e:	00000097          	auipc	ra,0x0
    80000fa2:	b42080e7          	jalr	-1214(ra) # 80000ae0 <kinit>
    kvminit();       // create kernel page table
    80000fa6:	00000097          	auipc	ra,0x0
    80000faa:	2a0080e7          	jalr	672(ra) # 80001246 <kvminit>
    kvminithart();   // turn on paging
    80000fae:	00000097          	auipc	ra,0x0
    80000fb2:	068080e7          	jalr	104(ra) # 80001016 <kvminithart>
    procinit();      // process table
    80000fb6:	00001097          	auipc	ra,0x1
    80000fba:	970080e7          	jalr	-1680(ra) # 80001926 <procinit>
    trapinit();      // trap vectors
    80000fbe:	00001097          	auipc	ra,0x1
    80000fc2:	6cc080e7          	jalr	1740(ra) # 8000268a <trapinit>
    trapinithart();  // install kernel trap vector
    80000fc6:	00001097          	auipc	ra,0x1
    80000fca:	6ec080e7          	jalr	1772(ra) # 800026b2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fce:	00005097          	auipc	ra,0x5
    80000fd2:	d48080e7          	jalr	-696(ra) # 80005d16 <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fd6:	00005097          	auipc	ra,0x5
    80000fda:	d56080e7          	jalr	-682(ra) # 80005d2c <plicinithart>
    binit();         // buffer cache
    80000fde:	00002097          	auipc	ra,0x2
    80000fe2:	ee4080e7          	jalr	-284(ra) # 80002ec2 <binit>
    iinit();         // inode cache
    80000fe6:	00002097          	auipc	ra,0x2
    80000fea:	574080e7          	jalr	1396(ra) # 8000355a <iinit>
    fileinit();      // file table
    80000fee:	00003097          	auipc	ra,0x3
    80000ff2:	50e080e7          	jalr	1294(ra) # 800044fc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ff6:	00005097          	auipc	ra,0x5
    80000ffa:	e3e080e7          	jalr	-450(ra) # 80005e34 <virtio_disk_init>
    userinit();      // first user process
    80000ffe:	00001097          	auipc	ra,0x1
    80001002:	cf2080e7          	jalr	-782(ra) # 80001cf0 <userinit>
    __sync_synchronize();
    80001006:	0ff0000f          	fence
    started = 1;
    8000100a:	4785                	li	a5,1
    8000100c:	00008717          	auipc	a4,0x8
    80001010:	00f72023          	sw	a5,0(a4) # 8000900c <started>
    80001014:	b789                	j	80000f56 <main+0x56>

0000000080001016 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001016:	1141                	addi	sp,sp,-16
    80001018:	e422                	sd	s0,8(sp)
    8000101a:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000101c:	00008797          	auipc	a5,0x8
    80001020:	ff47b783          	ld	a5,-12(a5) # 80009010 <kernel_pagetable>
    80001024:	83b1                	srli	a5,a5,0xc
    80001026:	577d                	li	a4,-1
    80001028:	177e                	slli	a4,a4,0x3f
    8000102a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000102c:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001030:	12000073          	sfence.vma
  sfence_vma();
}
    80001034:	6422                	ld	s0,8(sp)
    80001036:	0141                	addi	sp,sp,16
    80001038:	8082                	ret

000000008000103a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000103a:	7139                	addi	sp,sp,-64
    8000103c:	fc06                	sd	ra,56(sp)
    8000103e:	f822                	sd	s0,48(sp)
    80001040:	f426                	sd	s1,40(sp)
    80001042:	f04a                	sd	s2,32(sp)
    80001044:	ec4e                	sd	s3,24(sp)
    80001046:	e852                	sd	s4,16(sp)
    80001048:	e456                	sd	s5,8(sp)
    8000104a:	e05a                	sd	s6,0(sp)
    8000104c:	0080                	addi	s0,sp,64
    8000104e:	84aa                	mv	s1,a0
    80001050:	89ae                	mv	s3,a1
    80001052:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001054:	57fd                	li	a5,-1
    80001056:	83e9                	srli	a5,a5,0x1a
    80001058:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000105a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000105c:	04b7f263          	bgeu	a5,a1,800010a0 <walk+0x66>
    panic("walk");
    80001060:	00007517          	auipc	a0,0x7
    80001064:	07050513          	addi	a0,a0,112 # 800080d0 <digits+0x90>
    80001068:	fffff097          	auipc	ra,0xfffff
    8000106c:	4e8080e7          	jalr	1256(ra) # 80000550 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001070:	060a8663          	beqz	s5,800010dc <walk+0xa2>
    80001074:	00000097          	auipc	ra,0x0
    80001078:	aa8080e7          	jalr	-1368(ra) # 80000b1c <kalloc>
    8000107c:	84aa                	mv	s1,a0
    8000107e:	c529                	beqz	a0,800010c8 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001080:	6605                	lui	a2,0x1
    80001082:	4581                	li	a1,0
    80001084:	00000097          	auipc	ra,0x0
    80001088:	cce080e7          	jalr	-818(ra) # 80000d52 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000108c:	00c4d793          	srli	a5,s1,0xc
    80001090:	07aa                	slli	a5,a5,0xa
    80001092:	0017e793          	ori	a5,a5,1
    80001096:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000109a:	3a5d                	addiw	s4,s4,-9
    8000109c:	036a0063          	beq	s4,s6,800010bc <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010a0:	0149d933          	srl	s2,s3,s4
    800010a4:	1ff97913          	andi	s2,s2,511
    800010a8:	090e                	slli	s2,s2,0x3
    800010aa:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010ac:	00093483          	ld	s1,0(s2)
    800010b0:	0014f793          	andi	a5,s1,1
    800010b4:	dfd5                	beqz	a5,80001070 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010b6:	80a9                	srli	s1,s1,0xa
    800010b8:	04b2                	slli	s1,s1,0xc
    800010ba:	b7c5                	j	8000109a <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010bc:	00c9d513          	srli	a0,s3,0xc
    800010c0:	1ff57513          	andi	a0,a0,511
    800010c4:	050e                	slli	a0,a0,0x3
    800010c6:	9526                	add	a0,a0,s1
}
    800010c8:	70e2                	ld	ra,56(sp)
    800010ca:	7442                	ld	s0,48(sp)
    800010cc:	74a2                	ld	s1,40(sp)
    800010ce:	7902                	ld	s2,32(sp)
    800010d0:	69e2                	ld	s3,24(sp)
    800010d2:	6a42                	ld	s4,16(sp)
    800010d4:	6aa2                	ld	s5,8(sp)
    800010d6:	6b02                	ld	s6,0(sp)
    800010d8:	6121                	addi	sp,sp,64
    800010da:	8082                	ret
        return 0;
    800010dc:	4501                	li	a0,0
    800010de:	b7ed                	j	800010c8 <walk+0x8e>

00000000800010e0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010e0:	57fd                	li	a5,-1
    800010e2:	83e9                	srli	a5,a5,0x1a
    800010e4:	00b7f463          	bgeu	a5,a1,800010ec <walkaddr+0xc>
    return 0;
    800010e8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010ea:	8082                	ret
{
    800010ec:	1141                	addi	sp,sp,-16
    800010ee:	e406                	sd	ra,8(sp)
    800010f0:	e022                	sd	s0,0(sp)
    800010f2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010f4:	4601                	li	a2,0
    800010f6:	00000097          	auipc	ra,0x0
    800010fa:	f44080e7          	jalr	-188(ra) # 8000103a <walk>
  if(pte == 0)
    800010fe:	c105                	beqz	a0,8000111e <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001100:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001102:	0117f693          	andi	a3,a5,17
    80001106:	4745                	li	a4,17
    return 0;
    80001108:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000110a:	00e68663          	beq	a3,a4,80001116 <walkaddr+0x36>
}
    8000110e:	60a2                	ld	ra,8(sp)
    80001110:	6402                	ld	s0,0(sp)
    80001112:	0141                	addi	sp,sp,16
    80001114:	8082                	ret
  pa = PTE2PA(*pte);
    80001116:	00a7d513          	srli	a0,a5,0xa
    8000111a:	0532                	slli	a0,a0,0xc
  return pa;
    8000111c:	bfcd                	j	8000110e <walkaddr+0x2e>
    return 0;
    8000111e:	4501                	li	a0,0
    80001120:	b7fd                	j	8000110e <walkaddr+0x2e>

0000000080001122 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001122:	1101                	addi	sp,sp,-32
    80001124:	ec06                	sd	ra,24(sp)
    80001126:	e822                	sd	s0,16(sp)
    80001128:	e426                	sd	s1,8(sp)
    8000112a:	1000                	addi	s0,sp,32
    8000112c:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    8000112e:	1552                	slli	a0,a0,0x34
    80001130:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001134:	4601                	li	a2,0
    80001136:	00008517          	auipc	a0,0x8
    8000113a:	eda53503          	ld	a0,-294(a0) # 80009010 <kernel_pagetable>
    8000113e:	00000097          	auipc	ra,0x0
    80001142:	efc080e7          	jalr	-260(ra) # 8000103a <walk>
  if(pte == 0)
    80001146:	cd09                	beqz	a0,80001160 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001148:	6108                	ld	a0,0(a0)
    8000114a:	00157793          	andi	a5,a0,1
    8000114e:	c38d                	beqz	a5,80001170 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001150:	8129                	srli	a0,a0,0xa
    80001152:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001154:	9526                	add	a0,a0,s1
    80001156:	60e2                	ld	ra,24(sp)
    80001158:	6442                	ld	s0,16(sp)
    8000115a:	64a2                	ld	s1,8(sp)
    8000115c:	6105                	addi	sp,sp,32
    8000115e:	8082                	ret
    panic("kvmpa");
    80001160:	00007517          	auipc	a0,0x7
    80001164:	f7850513          	addi	a0,a0,-136 # 800080d8 <digits+0x98>
    80001168:	fffff097          	auipc	ra,0xfffff
    8000116c:	3e8080e7          	jalr	1000(ra) # 80000550 <panic>
    panic("kvmpa");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	f6850513          	addi	a0,a0,-152 # 800080d8 <digits+0x98>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	3d8080e7          	jalr	984(ra) # 80000550 <panic>

0000000080001180 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001180:	715d                	addi	sp,sp,-80
    80001182:	e486                	sd	ra,72(sp)
    80001184:	e0a2                	sd	s0,64(sp)
    80001186:	fc26                	sd	s1,56(sp)
    80001188:	f84a                	sd	s2,48(sp)
    8000118a:	f44e                	sd	s3,40(sp)
    8000118c:	f052                	sd	s4,32(sp)
    8000118e:	ec56                	sd	s5,24(sp)
    80001190:	e85a                	sd	s6,16(sp)
    80001192:	e45e                	sd	s7,8(sp)
    80001194:	0880                	addi	s0,sp,80
    80001196:	8aaa                	mv	s5,a0
    80001198:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000119a:	777d                	lui	a4,0xfffff
    8000119c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011a0:	167d                	addi	a2,a2,-1
    800011a2:	00b609b3          	add	s3,a2,a1
    800011a6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011aa:	893e                	mv	s2,a5
    800011ac:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011b0:	6b85                	lui	s7,0x1
    800011b2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011b6:	4605                	li	a2,1
    800011b8:	85ca                	mv	a1,s2
    800011ba:	8556                	mv	a0,s5
    800011bc:	00000097          	auipc	ra,0x0
    800011c0:	e7e080e7          	jalr	-386(ra) # 8000103a <walk>
    800011c4:	c51d                	beqz	a0,800011f2 <mappages+0x72>
    if(*pte & PTE_V)
    800011c6:	611c                	ld	a5,0(a0)
    800011c8:	8b85                	andi	a5,a5,1
    800011ca:	ef81                	bnez	a5,800011e2 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011cc:	80b1                	srli	s1,s1,0xc
    800011ce:	04aa                	slli	s1,s1,0xa
    800011d0:	0164e4b3          	or	s1,s1,s6
    800011d4:	0014e493          	ori	s1,s1,1
    800011d8:	e104                	sd	s1,0(a0)
    if(a == last)
    800011da:	03390863          	beq	s2,s3,8000120a <mappages+0x8a>
    a += PGSIZE;
    800011de:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011e0:	bfc9                	j	800011b2 <mappages+0x32>
      panic("remap");
    800011e2:	00007517          	auipc	a0,0x7
    800011e6:	efe50513          	addi	a0,a0,-258 # 800080e0 <digits+0xa0>
    800011ea:	fffff097          	auipc	ra,0xfffff
    800011ee:	366080e7          	jalr	870(ra) # 80000550 <panic>
      return -1;
    800011f2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011f4:	60a6                	ld	ra,72(sp)
    800011f6:	6406                	ld	s0,64(sp)
    800011f8:	74e2                	ld	s1,56(sp)
    800011fa:	7942                	ld	s2,48(sp)
    800011fc:	79a2                	ld	s3,40(sp)
    800011fe:	7a02                	ld	s4,32(sp)
    80001200:	6ae2                	ld	s5,24(sp)
    80001202:	6b42                	ld	s6,16(sp)
    80001204:	6ba2                	ld	s7,8(sp)
    80001206:	6161                	addi	sp,sp,80
    80001208:	8082                	ret
  return 0;
    8000120a:	4501                	li	a0,0
    8000120c:	b7e5                	j	800011f4 <mappages+0x74>

000000008000120e <kvmmap>:
{
    8000120e:	1141                	addi	sp,sp,-16
    80001210:	e406                	sd	ra,8(sp)
    80001212:	e022                	sd	s0,0(sp)
    80001214:	0800                	addi	s0,sp,16
    80001216:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001218:	86ae                	mv	a3,a1
    8000121a:	85aa                	mv	a1,a0
    8000121c:	00008517          	auipc	a0,0x8
    80001220:	df453503          	ld	a0,-524(a0) # 80009010 <kernel_pagetable>
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f5c080e7          	jalr	-164(ra) # 80001180 <mappages>
    8000122c:	e509                	bnez	a0,80001236 <kvmmap+0x28>
}
    8000122e:	60a2                	ld	ra,8(sp)
    80001230:	6402                	ld	s0,0(sp)
    80001232:	0141                	addi	sp,sp,16
    80001234:	8082                	ret
    panic("kvmmap");
    80001236:	00007517          	auipc	a0,0x7
    8000123a:	eb250513          	addi	a0,a0,-334 # 800080e8 <digits+0xa8>
    8000123e:	fffff097          	auipc	ra,0xfffff
    80001242:	312080e7          	jalr	786(ra) # 80000550 <panic>

0000000080001246 <kvminit>:
{
    80001246:	1101                	addi	sp,sp,-32
    80001248:	ec06                	sd	ra,24(sp)
    8000124a:	e822                	sd	s0,16(sp)
    8000124c:	e426                	sd	s1,8(sp)
    8000124e:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001250:	00000097          	auipc	ra,0x0
    80001254:	8cc080e7          	jalr	-1844(ra) # 80000b1c <kalloc>
    80001258:	00008797          	auipc	a5,0x8
    8000125c:	daa7bc23          	sd	a0,-584(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001260:	6605                	lui	a2,0x1
    80001262:	4581                	li	a1,0
    80001264:	00000097          	auipc	ra,0x0
    80001268:	aee080e7          	jalr	-1298(ra) # 80000d52 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000126c:	4699                	li	a3,6
    8000126e:	6605                	lui	a2,0x1
    80001270:	100005b7          	lui	a1,0x10000
    80001274:	10000537          	lui	a0,0x10000
    80001278:	00000097          	auipc	ra,0x0
    8000127c:	f96080e7          	jalr	-106(ra) # 8000120e <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001280:	4699                	li	a3,6
    80001282:	6605                	lui	a2,0x1
    80001284:	100015b7          	lui	a1,0x10001
    80001288:	10001537          	lui	a0,0x10001
    8000128c:	00000097          	auipc	ra,0x0
    80001290:	f82080e7          	jalr	-126(ra) # 8000120e <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001294:	4699                	li	a3,6
    80001296:	6641                	lui	a2,0x10
    80001298:	020005b7          	lui	a1,0x2000
    8000129c:	02000537          	lui	a0,0x2000
    800012a0:	00000097          	auipc	ra,0x0
    800012a4:	f6e080e7          	jalr	-146(ra) # 8000120e <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012a8:	4699                	li	a3,6
    800012aa:	00400637          	lui	a2,0x400
    800012ae:	0c0005b7          	lui	a1,0xc000
    800012b2:	0c000537          	lui	a0,0xc000
    800012b6:	00000097          	auipc	ra,0x0
    800012ba:	f58080e7          	jalr	-168(ra) # 8000120e <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012be:	00007497          	auipc	s1,0x7
    800012c2:	d4248493          	addi	s1,s1,-702 # 80008000 <etext>
    800012c6:	46a9                	li	a3,10
    800012c8:	80007617          	auipc	a2,0x80007
    800012cc:	d3860613          	addi	a2,a2,-712 # 8000 <_entry-0x7fff8000>
    800012d0:	4585                	li	a1,1
    800012d2:	05fe                	slli	a1,a1,0x1f
    800012d4:	852e                	mv	a0,a1
    800012d6:	00000097          	auipc	ra,0x0
    800012da:	f38080e7          	jalr	-200(ra) # 8000120e <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012de:	4699                	li	a3,6
    800012e0:	4645                	li	a2,17
    800012e2:	066e                	slli	a2,a2,0x1b
    800012e4:	8e05                	sub	a2,a2,s1
    800012e6:	85a6                	mv	a1,s1
    800012e8:	8526                	mv	a0,s1
    800012ea:	00000097          	auipc	ra,0x0
    800012ee:	f24080e7          	jalr	-220(ra) # 8000120e <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012f2:	46a9                	li	a3,10
    800012f4:	6605                	lui	a2,0x1
    800012f6:	00006597          	auipc	a1,0x6
    800012fa:	d0a58593          	addi	a1,a1,-758 # 80007000 <_trampoline>
    800012fe:	04000537          	lui	a0,0x4000
    80001302:	157d                	addi	a0,a0,-1
    80001304:	0532                	slli	a0,a0,0xc
    80001306:	00000097          	auipc	ra,0x0
    8000130a:	f08080e7          	jalr	-248(ra) # 8000120e <kvmmap>
}
    8000130e:	60e2                	ld	ra,24(sp)
    80001310:	6442                	ld	s0,16(sp)
    80001312:	64a2                	ld	s1,8(sp)
    80001314:	6105                	addi	sp,sp,32
    80001316:	8082                	ret

0000000080001318 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001318:	715d                	addi	sp,sp,-80
    8000131a:	e486                	sd	ra,72(sp)
    8000131c:	e0a2                	sd	s0,64(sp)
    8000131e:	fc26                	sd	s1,56(sp)
    80001320:	f84a                	sd	s2,48(sp)
    80001322:	f44e                	sd	s3,40(sp)
    80001324:	f052                	sd	s4,32(sp)
    80001326:	ec56                	sd	s5,24(sp)
    80001328:	e85a                	sd	s6,16(sp)
    8000132a:	e45e                	sd	s7,8(sp)
    8000132c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000132e:	03459793          	slli	a5,a1,0x34
    80001332:	e795                	bnez	a5,8000135e <uvmunmap+0x46>
    80001334:	8a2a                	mv	s4,a0
    80001336:	892e                	mv	s2,a1
    80001338:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000133a:	0632                	slli	a2,a2,0xc
    8000133c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001340:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001342:	6b05                	lui	s6,0x1
    80001344:	0735e263          	bltu	a1,s3,800013a8 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001348:	60a6                	ld	ra,72(sp)
    8000134a:	6406                	ld	s0,64(sp)
    8000134c:	74e2                	ld	s1,56(sp)
    8000134e:	7942                	ld	s2,48(sp)
    80001350:	79a2                	ld	s3,40(sp)
    80001352:	7a02                	ld	s4,32(sp)
    80001354:	6ae2                	ld	s5,24(sp)
    80001356:	6b42                	ld	s6,16(sp)
    80001358:	6ba2                	ld	s7,8(sp)
    8000135a:	6161                	addi	sp,sp,80
    8000135c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000135e:	00007517          	auipc	a0,0x7
    80001362:	d9250513          	addi	a0,a0,-622 # 800080f0 <digits+0xb0>
    80001366:	fffff097          	auipc	ra,0xfffff
    8000136a:	1ea080e7          	jalr	490(ra) # 80000550 <panic>
      panic("uvmunmap: walk");
    8000136e:	00007517          	auipc	a0,0x7
    80001372:	d9a50513          	addi	a0,a0,-614 # 80008108 <digits+0xc8>
    80001376:	fffff097          	auipc	ra,0xfffff
    8000137a:	1da080e7          	jalr	474(ra) # 80000550 <panic>
      panic("uvmunmap: not mapped");
    8000137e:	00007517          	auipc	a0,0x7
    80001382:	d9a50513          	addi	a0,a0,-614 # 80008118 <digits+0xd8>
    80001386:	fffff097          	auipc	ra,0xfffff
    8000138a:	1ca080e7          	jalr	458(ra) # 80000550 <panic>
      panic("uvmunmap: not a leaf");
    8000138e:	00007517          	auipc	a0,0x7
    80001392:	da250513          	addi	a0,a0,-606 # 80008130 <digits+0xf0>
    80001396:	fffff097          	auipc	ra,0xfffff
    8000139a:	1ba080e7          	jalr	442(ra) # 80000550 <panic>
    *pte = 0;
    8000139e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013a2:	995a                	add	s2,s2,s6
    800013a4:	fb3972e3          	bgeu	s2,s3,80001348 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013a8:	4601                	li	a2,0
    800013aa:	85ca                	mv	a1,s2
    800013ac:	8552                	mv	a0,s4
    800013ae:	00000097          	auipc	ra,0x0
    800013b2:	c8c080e7          	jalr	-884(ra) # 8000103a <walk>
    800013b6:	84aa                	mv	s1,a0
    800013b8:	d95d                	beqz	a0,8000136e <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013ba:	6108                	ld	a0,0(a0)
    800013bc:	00157793          	andi	a5,a0,1
    800013c0:	dfdd                	beqz	a5,8000137e <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013c2:	3ff57793          	andi	a5,a0,1023
    800013c6:	fd7784e3          	beq	a5,s7,8000138e <uvmunmap+0x76>
    if(do_free){
    800013ca:	fc0a8ae3          	beqz	s5,8000139e <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013ce:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013d0:	0532                	slli	a0,a0,0xc
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	64e080e7          	jalr	1614(ra) # 80000a20 <kfree>
    800013da:	b7d1                	j	8000139e <uvmunmap+0x86>

00000000800013dc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013dc:	1101                	addi	sp,sp,-32
    800013de:	ec06                	sd	ra,24(sp)
    800013e0:	e822                	sd	s0,16(sp)
    800013e2:	e426                	sd	s1,8(sp)
    800013e4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013e6:	fffff097          	auipc	ra,0xfffff
    800013ea:	736080e7          	jalr	1846(ra) # 80000b1c <kalloc>
    800013ee:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013f0:	c519                	beqz	a0,800013fe <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013f2:	6605                	lui	a2,0x1
    800013f4:	4581                	li	a1,0
    800013f6:	00000097          	auipc	ra,0x0
    800013fa:	95c080e7          	jalr	-1700(ra) # 80000d52 <memset>
  return pagetable;
}
    800013fe:	8526                	mv	a0,s1
    80001400:	60e2                	ld	ra,24(sp)
    80001402:	6442                	ld	s0,16(sp)
    80001404:	64a2                	ld	s1,8(sp)
    80001406:	6105                	addi	sp,sp,32
    80001408:	8082                	ret

000000008000140a <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000140a:	7179                	addi	sp,sp,-48
    8000140c:	f406                	sd	ra,40(sp)
    8000140e:	f022                	sd	s0,32(sp)
    80001410:	ec26                	sd	s1,24(sp)
    80001412:	e84a                	sd	s2,16(sp)
    80001414:	e44e                	sd	s3,8(sp)
    80001416:	e052                	sd	s4,0(sp)
    80001418:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000141a:	6785                	lui	a5,0x1
    8000141c:	04f67863          	bgeu	a2,a5,8000146c <uvminit+0x62>
    80001420:	8a2a                	mv	s4,a0
    80001422:	89ae                	mv	s3,a1
    80001424:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001426:	fffff097          	auipc	ra,0xfffff
    8000142a:	6f6080e7          	jalr	1782(ra) # 80000b1c <kalloc>
    8000142e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001430:	6605                	lui	a2,0x1
    80001432:	4581                	li	a1,0
    80001434:	00000097          	auipc	ra,0x0
    80001438:	91e080e7          	jalr	-1762(ra) # 80000d52 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000143c:	4779                	li	a4,30
    8000143e:	86ca                	mv	a3,s2
    80001440:	6605                	lui	a2,0x1
    80001442:	4581                	li	a1,0
    80001444:	8552                	mv	a0,s4
    80001446:	00000097          	auipc	ra,0x0
    8000144a:	d3a080e7          	jalr	-710(ra) # 80001180 <mappages>
  memmove(mem, src, sz);
    8000144e:	8626                	mv	a2,s1
    80001450:	85ce                	mv	a1,s3
    80001452:	854a                	mv	a0,s2
    80001454:	00000097          	auipc	ra,0x0
    80001458:	95a080e7          	jalr	-1702(ra) # 80000dae <memmove>
}
    8000145c:	70a2                	ld	ra,40(sp)
    8000145e:	7402                	ld	s0,32(sp)
    80001460:	64e2                	ld	s1,24(sp)
    80001462:	6942                	ld	s2,16(sp)
    80001464:	69a2                	ld	s3,8(sp)
    80001466:	6a02                	ld	s4,0(sp)
    80001468:	6145                	addi	sp,sp,48
    8000146a:	8082                	ret
    panic("inituvm: more than a page");
    8000146c:	00007517          	auipc	a0,0x7
    80001470:	cdc50513          	addi	a0,a0,-804 # 80008148 <digits+0x108>
    80001474:	fffff097          	auipc	ra,0xfffff
    80001478:	0dc080e7          	jalr	220(ra) # 80000550 <panic>

000000008000147c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000147c:	1101                	addi	sp,sp,-32
    8000147e:	ec06                	sd	ra,24(sp)
    80001480:	e822                	sd	s0,16(sp)
    80001482:	e426                	sd	s1,8(sp)
    80001484:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001486:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001488:	00b67d63          	bgeu	a2,a1,800014a2 <uvmdealloc+0x26>
    8000148c:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000148e:	6785                	lui	a5,0x1
    80001490:	17fd                	addi	a5,a5,-1
    80001492:	00f60733          	add	a4,a2,a5
    80001496:	767d                	lui	a2,0xfffff
    80001498:	8f71                	and	a4,a4,a2
    8000149a:	97ae                	add	a5,a5,a1
    8000149c:	8ff1                	and	a5,a5,a2
    8000149e:	00f76863          	bltu	a4,a5,800014ae <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014a2:	8526                	mv	a0,s1
    800014a4:	60e2                	ld	ra,24(sp)
    800014a6:	6442                	ld	s0,16(sp)
    800014a8:	64a2                	ld	s1,8(sp)
    800014aa:	6105                	addi	sp,sp,32
    800014ac:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014ae:	8f99                	sub	a5,a5,a4
    800014b0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014b2:	4685                	li	a3,1
    800014b4:	0007861b          	sext.w	a2,a5
    800014b8:	85ba                	mv	a1,a4
    800014ba:	00000097          	auipc	ra,0x0
    800014be:	e5e080e7          	jalr	-418(ra) # 80001318 <uvmunmap>
    800014c2:	b7c5                	j	800014a2 <uvmdealloc+0x26>

00000000800014c4 <uvmalloc>:
  if(newsz < oldsz)
    800014c4:	0ab66163          	bltu	a2,a1,80001566 <uvmalloc+0xa2>
{
    800014c8:	7139                	addi	sp,sp,-64
    800014ca:	fc06                	sd	ra,56(sp)
    800014cc:	f822                	sd	s0,48(sp)
    800014ce:	f426                	sd	s1,40(sp)
    800014d0:	f04a                	sd	s2,32(sp)
    800014d2:	ec4e                	sd	s3,24(sp)
    800014d4:	e852                	sd	s4,16(sp)
    800014d6:	e456                	sd	s5,8(sp)
    800014d8:	0080                	addi	s0,sp,64
    800014da:	8aaa                	mv	s5,a0
    800014dc:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014de:	6985                	lui	s3,0x1
    800014e0:	19fd                	addi	s3,s3,-1
    800014e2:	95ce                	add	a1,a1,s3
    800014e4:	79fd                	lui	s3,0xfffff
    800014e6:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ea:	08c9f063          	bgeu	s3,a2,8000156a <uvmalloc+0xa6>
    800014ee:	894e                	mv	s2,s3
    mem = kalloc();
    800014f0:	fffff097          	auipc	ra,0xfffff
    800014f4:	62c080e7          	jalr	1580(ra) # 80000b1c <kalloc>
    800014f8:	84aa                	mv	s1,a0
    if(mem == 0){
    800014fa:	c51d                	beqz	a0,80001528 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014fc:	6605                	lui	a2,0x1
    800014fe:	4581                	li	a1,0
    80001500:	00000097          	auipc	ra,0x0
    80001504:	852080e7          	jalr	-1966(ra) # 80000d52 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001508:	4779                	li	a4,30
    8000150a:	86a6                	mv	a3,s1
    8000150c:	6605                	lui	a2,0x1
    8000150e:	85ca                	mv	a1,s2
    80001510:	8556                	mv	a0,s5
    80001512:	00000097          	auipc	ra,0x0
    80001516:	c6e080e7          	jalr	-914(ra) # 80001180 <mappages>
    8000151a:	e905                	bnez	a0,8000154a <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000151c:	6785                	lui	a5,0x1
    8000151e:	993e                	add	s2,s2,a5
    80001520:	fd4968e3          	bltu	s2,s4,800014f0 <uvmalloc+0x2c>
  return newsz;
    80001524:	8552                	mv	a0,s4
    80001526:	a809                	j	80001538 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001528:	864e                	mv	a2,s3
    8000152a:	85ca                	mv	a1,s2
    8000152c:	8556                	mv	a0,s5
    8000152e:	00000097          	auipc	ra,0x0
    80001532:	f4e080e7          	jalr	-178(ra) # 8000147c <uvmdealloc>
      return 0;
    80001536:	4501                	li	a0,0
}
    80001538:	70e2                	ld	ra,56(sp)
    8000153a:	7442                	ld	s0,48(sp)
    8000153c:	74a2                	ld	s1,40(sp)
    8000153e:	7902                	ld	s2,32(sp)
    80001540:	69e2                	ld	s3,24(sp)
    80001542:	6a42                	ld	s4,16(sp)
    80001544:	6aa2                	ld	s5,8(sp)
    80001546:	6121                	addi	sp,sp,64
    80001548:	8082                	ret
      kfree(mem);
    8000154a:	8526                	mv	a0,s1
    8000154c:	fffff097          	auipc	ra,0xfffff
    80001550:	4d4080e7          	jalr	1236(ra) # 80000a20 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001554:	864e                	mv	a2,s3
    80001556:	85ca                	mv	a1,s2
    80001558:	8556                	mv	a0,s5
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	f22080e7          	jalr	-222(ra) # 8000147c <uvmdealloc>
      return 0;
    80001562:	4501                	li	a0,0
    80001564:	bfd1                	j	80001538 <uvmalloc+0x74>
    return oldsz;
    80001566:	852e                	mv	a0,a1
}
    80001568:	8082                	ret
  return newsz;
    8000156a:	8532                	mv	a0,a2
    8000156c:	b7f1                	j	80001538 <uvmalloc+0x74>

000000008000156e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000156e:	7179                	addi	sp,sp,-48
    80001570:	f406                	sd	ra,40(sp)
    80001572:	f022                	sd	s0,32(sp)
    80001574:	ec26                	sd	s1,24(sp)
    80001576:	e84a                	sd	s2,16(sp)
    80001578:	e44e                	sd	s3,8(sp)
    8000157a:	e052                	sd	s4,0(sp)
    8000157c:	1800                	addi	s0,sp,48
    8000157e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001580:	84aa                	mv	s1,a0
    80001582:	6905                	lui	s2,0x1
    80001584:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001586:	4985                	li	s3,1
    80001588:	a821                	j	800015a0 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000158a:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000158c:	0532                	slli	a0,a0,0xc
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	fe0080e7          	jalr	-32(ra) # 8000156e <freewalk>
      pagetable[i] = 0;
    80001596:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000159a:	04a1                	addi	s1,s1,8
    8000159c:	03248163          	beq	s1,s2,800015be <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015a0:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a2:	00f57793          	andi	a5,a0,15
    800015a6:	ff3782e3          	beq	a5,s3,8000158a <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015aa:	8905                	andi	a0,a0,1
    800015ac:	d57d                	beqz	a0,8000159a <freewalk+0x2c>
      panic("freewalk: leaf");
    800015ae:	00007517          	auipc	a0,0x7
    800015b2:	bba50513          	addi	a0,a0,-1094 # 80008168 <digits+0x128>
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	f9a080e7          	jalr	-102(ra) # 80000550 <panic>
    }
  }
  kfree((void*)pagetable);
    800015be:	8552                	mv	a0,s4
    800015c0:	fffff097          	auipc	ra,0xfffff
    800015c4:	460080e7          	jalr	1120(ra) # 80000a20 <kfree>
}
    800015c8:	70a2                	ld	ra,40(sp)
    800015ca:	7402                	ld	s0,32(sp)
    800015cc:	64e2                	ld	s1,24(sp)
    800015ce:	6942                	ld	s2,16(sp)
    800015d0:	69a2                	ld	s3,8(sp)
    800015d2:	6a02                	ld	s4,0(sp)
    800015d4:	6145                	addi	sp,sp,48
    800015d6:	8082                	ret

00000000800015d8 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015d8:	1101                	addi	sp,sp,-32
    800015da:	ec06                	sd	ra,24(sp)
    800015dc:	e822                	sd	s0,16(sp)
    800015de:	e426                	sd	s1,8(sp)
    800015e0:	1000                	addi	s0,sp,32
    800015e2:	84aa                	mv	s1,a0
  if(sz > 0)
    800015e4:	e999                	bnez	a1,800015fa <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015e6:	8526                	mv	a0,s1
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	f86080e7          	jalr	-122(ra) # 8000156e <freewalk>
}
    800015f0:	60e2                	ld	ra,24(sp)
    800015f2:	6442                	ld	s0,16(sp)
    800015f4:	64a2                	ld	s1,8(sp)
    800015f6:	6105                	addi	sp,sp,32
    800015f8:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015fa:	6605                	lui	a2,0x1
    800015fc:	167d                	addi	a2,a2,-1
    800015fe:	962e                	add	a2,a2,a1
    80001600:	4685                	li	a3,1
    80001602:	8231                	srli	a2,a2,0xc
    80001604:	4581                	li	a1,0
    80001606:	00000097          	auipc	ra,0x0
    8000160a:	d12080e7          	jalr	-750(ra) # 80001318 <uvmunmap>
    8000160e:	bfe1                	j	800015e6 <uvmfree+0xe>

0000000080001610 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001610:	c679                	beqz	a2,800016de <uvmcopy+0xce>
{
    80001612:	715d                	addi	sp,sp,-80
    80001614:	e486                	sd	ra,72(sp)
    80001616:	e0a2                	sd	s0,64(sp)
    80001618:	fc26                	sd	s1,56(sp)
    8000161a:	f84a                	sd	s2,48(sp)
    8000161c:	f44e                	sd	s3,40(sp)
    8000161e:	f052                	sd	s4,32(sp)
    80001620:	ec56                	sd	s5,24(sp)
    80001622:	e85a                	sd	s6,16(sp)
    80001624:	e45e                	sd	s7,8(sp)
    80001626:	0880                	addi	s0,sp,80
    80001628:	8b2a                	mv	s6,a0
    8000162a:	8aae                	mv	s5,a1
    8000162c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000162e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001630:	4601                	li	a2,0
    80001632:	85ce                	mv	a1,s3
    80001634:	855a                	mv	a0,s6
    80001636:	00000097          	auipc	ra,0x0
    8000163a:	a04080e7          	jalr	-1532(ra) # 8000103a <walk>
    8000163e:	c531                	beqz	a0,8000168a <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001640:	6118                	ld	a4,0(a0)
    80001642:	00177793          	andi	a5,a4,1
    80001646:	cbb1                	beqz	a5,8000169a <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001648:	00a75593          	srli	a1,a4,0xa
    8000164c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001650:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001654:	fffff097          	auipc	ra,0xfffff
    80001658:	4c8080e7          	jalr	1224(ra) # 80000b1c <kalloc>
    8000165c:	892a                	mv	s2,a0
    8000165e:	c939                	beqz	a0,800016b4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001660:	6605                	lui	a2,0x1
    80001662:	85de                	mv	a1,s7
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	74a080e7          	jalr	1866(ra) # 80000dae <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000166c:	8726                	mv	a4,s1
    8000166e:	86ca                	mv	a3,s2
    80001670:	6605                	lui	a2,0x1
    80001672:	85ce                	mv	a1,s3
    80001674:	8556                	mv	a0,s5
    80001676:	00000097          	auipc	ra,0x0
    8000167a:	b0a080e7          	jalr	-1270(ra) # 80001180 <mappages>
    8000167e:	e515                	bnez	a0,800016aa <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001680:	6785                	lui	a5,0x1
    80001682:	99be                	add	s3,s3,a5
    80001684:	fb49e6e3          	bltu	s3,s4,80001630 <uvmcopy+0x20>
    80001688:	a081                	j	800016c8 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000168a:	00007517          	auipc	a0,0x7
    8000168e:	aee50513          	addi	a0,a0,-1298 # 80008178 <digits+0x138>
    80001692:	fffff097          	auipc	ra,0xfffff
    80001696:	ebe080e7          	jalr	-322(ra) # 80000550 <panic>
      panic("uvmcopy: page not present");
    8000169a:	00007517          	auipc	a0,0x7
    8000169e:	afe50513          	addi	a0,a0,-1282 # 80008198 <digits+0x158>
    800016a2:	fffff097          	auipc	ra,0xfffff
    800016a6:	eae080e7          	jalr	-338(ra) # 80000550 <panic>
      kfree(mem);
    800016aa:	854a                	mv	a0,s2
    800016ac:	fffff097          	auipc	ra,0xfffff
    800016b0:	374080e7          	jalr	884(ra) # 80000a20 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016b4:	4685                	li	a3,1
    800016b6:	00c9d613          	srli	a2,s3,0xc
    800016ba:	4581                	li	a1,0
    800016bc:	8556                	mv	a0,s5
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	c5a080e7          	jalr	-934(ra) # 80001318 <uvmunmap>
  return -1;
    800016c6:	557d                	li	a0,-1
}
    800016c8:	60a6                	ld	ra,72(sp)
    800016ca:	6406                	ld	s0,64(sp)
    800016cc:	74e2                	ld	s1,56(sp)
    800016ce:	7942                	ld	s2,48(sp)
    800016d0:	79a2                	ld	s3,40(sp)
    800016d2:	7a02                	ld	s4,32(sp)
    800016d4:	6ae2                	ld	s5,24(sp)
    800016d6:	6b42                	ld	s6,16(sp)
    800016d8:	6ba2                	ld	s7,8(sp)
    800016da:	6161                	addi	sp,sp,80
    800016dc:	8082                	ret
  return 0;
    800016de:	4501                	li	a0,0
}
    800016e0:	8082                	ret

00000000800016e2 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016e2:	1141                	addi	sp,sp,-16
    800016e4:	e406                	sd	ra,8(sp)
    800016e6:	e022                	sd	s0,0(sp)
    800016e8:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016ea:	4601                	li	a2,0
    800016ec:	00000097          	auipc	ra,0x0
    800016f0:	94e080e7          	jalr	-1714(ra) # 8000103a <walk>
  if(pte == 0)
    800016f4:	c901                	beqz	a0,80001704 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016f6:	611c                	ld	a5,0(a0)
    800016f8:	9bbd                	andi	a5,a5,-17
    800016fa:	e11c                	sd	a5,0(a0)
}
    800016fc:	60a2                	ld	ra,8(sp)
    800016fe:	6402                	ld	s0,0(sp)
    80001700:	0141                	addi	sp,sp,16
    80001702:	8082                	ret
    panic("uvmclear");
    80001704:	00007517          	auipc	a0,0x7
    80001708:	ab450513          	addi	a0,a0,-1356 # 800081b8 <digits+0x178>
    8000170c:	fffff097          	auipc	ra,0xfffff
    80001710:	e44080e7          	jalr	-444(ra) # 80000550 <panic>

0000000080001714 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001714:	c6bd                	beqz	a3,80001782 <copyout+0x6e>
{
    80001716:	715d                	addi	sp,sp,-80
    80001718:	e486                	sd	ra,72(sp)
    8000171a:	e0a2                	sd	s0,64(sp)
    8000171c:	fc26                	sd	s1,56(sp)
    8000171e:	f84a                	sd	s2,48(sp)
    80001720:	f44e                	sd	s3,40(sp)
    80001722:	f052                	sd	s4,32(sp)
    80001724:	ec56                	sd	s5,24(sp)
    80001726:	e85a                	sd	s6,16(sp)
    80001728:	e45e                	sd	s7,8(sp)
    8000172a:	e062                	sd	s8,0(sp)
    8000172c:	0880                	addi	s0,sp,80
    8000172e:	8b2a                	mv	s6,a0
    80001730:	8c2e                	mv	s8,a1
    80001732:	8a32                	mv	s4,a2
    80001734:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001736:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001738:	6a85                	lui	s5,0x1
    8000173a:	a015                	j	8000175e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000173c:	9562                	add	a0,a0,s8
    8000173e:	0004861b          	sext.w	a2,s1
    80001742:	85d2                	mv	a1,s4
    80001744:	41250533          	sub	a0,a0,s2
    80001748:	fffff097          	auipc	ra,0xfffff
    8000174c:	666080e7          	jalr	1638(ra) # 80000dae <memmove>

    len -= n;
    80001750:	409989b3          	sub	s3,s3,s1
    src += n;
    80001754:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001756:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000175a:	02098263          	beqz	s3,8000177e <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000175e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001762:	85ca                	mv	a1,s2
    80001764:	855a                	mv	a0,s6
    80001766:	00000097          	auipc	ra,0x0
    8000176a:	97a080e7          	jalr	-1670(ra) # 800010e0 <walkaddr>
    if(pa0 == 0)
    8000176e:	cd01                	beqz	a0,80001786 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001770:	418904b3          	sub	s1,s2,s8
    80001774:	94d6                	add	s1,s1,s5
    if(n > len)
    80001776:	fc99f3e3          	bgeu	s3,s1,8000173c <copyout+0x28>
    8000177a:	84ce                	mv	s1,s3
    8000177c:	b7c1                	j	8000173c <copyout+0x28>
  }
  return 0;
    8000177e:	4501                	li	a0,0
    80001780:	a021                	j	80001788 <copyout+0x74>
    80001782:	4501                	li	a0,0
}
    80001784:	8082                	ret
      return -1;
    80001786:	557d                	li	a0,-1
}
    80001788:	60a6                	ld	ra,72(sp)
    8000178a:	6406                	ld	s0,64(sp)
    8000178c:	74e2                	ld	s1,56(sp)
    8000178e:	7942                	ld	s2,48(sp)
    80001790:	79a2                	ld	s3,40(sp)
    80001792:	7a02                	ld	s4,32(sp)
    80001794:	6ae2                	ld	s5,24(sp)
    80001796:	6b42                	ld	s6,16(sp)
    80001798:	6ba2                	ld	s7,8(sp)
    8000179a:	6c02                	ld	s8,0(sp)
    8000179c:	6161                	addi	sp,sp,80
    8000179e:	8082                	ret

00000000800017a0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017a0:	caa5                	beqz	a3,80001810 <copyin+0x70>
{
    800017a2:	715d                	addi	sp,sp,-80
    800017a4:	e486                	sd	ra,72(sp)
    800017a6:	e0a2                	sd	s0,64(sp)
    800017a8:	fc26                	sd	s1,56(sp)
    800017aa:	f84a                	sd	s2,48(sp)
    800017ac:	f44e                	sd	s3,40(sp)
    800017ae:	f052                	sd	s4,32(sp)
    800017b0:	ec56                	sd	s5,24(sp)
    800017b2:	e85a                	sd	s6,16(sp)
    800017b4:	e45e                	sd	s7,8(sp)
    800017b6:	e062                	sd	s8,0(sp)
    800017b8:	0880                	addi	s0,sp,80
    800017ba:	8b2a                	mv	s6,a0
    800017bc:	8a2e                	mv	s4,a1
    800017be:	8c32                	mv	s8,a2
    800017c0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017c2:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c4:	6a85                	lui	s5,0x1
    800017c6:	a01d                	j	800017ec <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017c8:	018505b3          	add	a1,a0,s8
    800017cc:	0004861b          	sext.w	a2,s1
    800017d0:	412585b3          	sub	a1,a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	fffff097          	auipc	ra,0xfffff
    800017da:	5d8080e7          	jalr	1496(ra) # 80000dae <memmove>

    len -= n;
    800017de:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017e2:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017e4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017e8:	02098263          	beqz	s3,8000180c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017ec:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017f0:	85ca                	mv	a1,s2
    800017f2:	855a                	mv	a0,s6
    800017f4:	00000097          	auipc	ra,0x0
    800017f8:	8ec080e7          	jalr	-1812(ra) # 800010e0 <walkaddr>
    if(pa0 == 0)
    800017fc:	cd01                	beqz	a0,80001814 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017fe:	418904b3          	sub	s1,s2,s8
    80001802:	94d6                	add	s1,s1,s5
    if(n > len)
    80001804:	fc99f2e3          	bgeu	s3,s1,800017c8 <copyin+0x28>
    80001808:	84ce                	mv	s1,s3
    8000180a:	bf7d                	j	800017c8 <copyin+0x28>
  }
  return 0;
    8000180c:	4501                	li	a0,0
    8000180e:	a021                	j	80001816 <copyin+0x76>
    80001810:	4501                	li	a0,0
}
    80001812:	8082                	ret
      return -1;
    80001814:	557d                	li	a0,-1
}
    80001816:	60a6                	ld	ra,72(sp)
    80001818:	6406                	ld	s0,64(sp)
    8000181a:	74e2                	ld	s1,56(sp)
    8000181c:	7942                	ld	s2,48(sp)
    8000181e:	79a2                	ld	s3,40(sp)
    80001820:	7a02                	ld	s4,32(sp)
    80001822:	6ae2                	ld	s5,24(sp)
    80001824:	6b42                	ld	s6,16(sp)
    80001826:	6ba2                	ld	s7,8(sp)
    80001828:	6c02                	ld	s8,0(sp)
    8000182a:	6161                	addi	sp,sp,80
    8000182c:	8082                	ret

000000008000182e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000182e:	c6c5                	beqz	a3,800018d6 <copyinstr+0xa8>
{
    80001830:	715d                	addi	sp,sp,-80
    80001832:	e486                	sd	ra,72(sp)
    80001834:	e0a2                	sd	s0,64(sp)
    80001836:	fc26                	sd	s1,56(sp)
    80001838:	f84a                	sd	s2,48(sp)
    8000183a:	f44e                	sd	s3,40(sp)
    8000183c:	f052                	sd	s4,32(sp)
    8000183e:	ec56                	sd	s5,24(sp)
    80001840:	e85a                	sd	s6,16(sp)
    80001842:	e45e                	sd	s7,8(sp)
    80001844:	0880                	addi	s0,sp,80
    80001846:	8a2a                	mv	s4,a0
    80001848:	8b2e                	mv	s6,a1
    8000184a:	8bb2                	mv	s7,a2
    8000184c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000184e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001850:	6985                	lui	s3,0x1
    80001852:	a035                	j	8000187e <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001854:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001858:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000185a:	0017b793          	seqz	a5,a5
    8000185e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001862:	60a6                	ld	ra,72(sp)
    80001864:	6406                	ld	s0,64(sp)
    80001866:	74e2                	ld	s1,56(sp)
    80001868:	7942                	ld	s2,48(sp)
    8000186a:	79a2                	ld	s3,40(sp)
    8000186c:	7a02                	ld	s4,32(sp)
    8000186e:	6ae2                	ld	s5,24(sp)
    80001870:	6b42                	ld	s6,16(sp)
    80001872:	6ba2                	ld	s7,8(sp)
    80001874:	6161                	addi	sp,sp,80
    80001876:	8082                	ret
    srcva = va0 + PGSIZE;
    80001878:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000187c:	c8a9                	beqz	s1,800018ce <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000187e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001882:	85ca                	mv	a1,s2
    80001884:	8552                	mv	a0,s4
    80001886:	00000097          	auipc	ra,0x0
    8000188a:	85a080e7          	jalr	-1958(ra) # 800010e0 <walkaddr>
    if(pa0 == 0)
    8000188e:	c131                	beqz	a0,800018d2 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001890:	41790833          	sub	a6,s2,s7
    80001894:	984e                	add	a6,a6,s3
    if(n > max)
    80001896:	0104f363          	bgeu	s1,a6,8000189c <copyinstr+0x6e>
    8000189a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000189c:	955e                	add	a0,a0,s7
    8000189e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018a2:	fc080be3          	beqz	a6,80001878 <copyinstr+0x4a>
    800018a6:	985a                	add	a6,a6,s6
    800018a8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018aa:	41650633          	sub	a2,a0,s6
    800018ae:	14fd                	addi	s1,s1,-1
    800018b0:	9b26                	add	s6,s6,s1
    800018b2:	00f60733          	add	a4,a2,a5
    800018b6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800018ba:	df49                	beqz	a4,80001854 <copyinstr+0x26>
        *dst = *p;
    800018bc:	00e78023          	sb	a4,0(a5)
      --max;
    800018c0:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018c4:	0785                	addi	a5,a5,1
    while(n > 0){
    800018c6:	ff0796e3          	bne	a5,a6,800018b2 <copyinstr+0x84>
      dst++;
    800018ca:	8b42                	mv	s6,a6
    800018cc:	b775                	j	80001878 <copyinstr+0x4a>
    800018ce:	4781                	li	a5,0
    800018d0:	b769                	j	8000185a <copyinstr+0x2c>
      return -1;
    800018d2:	557d                	li	a0,-1
    800018d4:	b779                	j	80001862 <copyinstr+0x34>
  int got_null = 0;
    800018d6:	4781                	li	a5,0
  if(got_null){
    800018d8:	0017b793          	seqz	a5,a5
    800018dc:	40f00533          	neg	a0,a5
}
    800018e0:	8082                	ret

00000000800018e2 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018e2:	1101                	addi	sp,sp,-32
    800018e4:	ec06                	sd	ra,24(sp)
    800018e6:	e822                	sd	s0,16(sp)
    800018e8:	e426                	sd	s1,8(sp)
    800018ea:	1000                	addi	s0,sp,32
    800018ec:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018ee:	fffff097          	auipc	ra,0xfffff
    800018f2:	2ee080e7          	jalr	750(ra) # 80000bdc <holding>
    800018f6:	c909                	beqz	a0,80001908 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018f8:	749c                	ld	a5,40(s1)
    800018fa:	00978f63          	beq	a5,s1,80001918 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018fe:	60e2                	ld	ra,24(sp)
    80001900:	6442                	ld	s0,16(sp)
    80001902:	64a2                	ld	s1,8(sp)
    80001904:	6105                	addi	sp,sp,32
    80001906:	8082                	ret
    panic("wakeup1");
    80001908:	00007517          	auipc	a0,0x7
    8000190c:	8c050513          	addi	a0,a0,-1856 # 800081c8 <digits+0x188>
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	c40080e7          	jalr	-960(ra) # 80000550 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001918:	4c98                	lw	a4,24(s1)
    8000191a:	4785                	li	a5,1
    8000191c:	fef711e3          	bne	a4,a5,800018fe <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001920:	4789                	li	a5,2
    80001922:	cc9c                	sw	a5,24(s1)
}
    80001924:	bfe9                	j	800018fe <wakeup1+0x1c>

0000000080001926 <procinit>:
{
    80001926:	715d                	addi	sp,sp,-80
    80001928:	e486                	sd	ra,72(sp)
    8000192a:	e0a2                	sd	s0,64(sp)
    8000192c:	fc26                	sd	s1,56(sp)
    8000192e:	f84a                	sd	s2,48(sp)
    80001930:	f44e                	sd	s3,40(sp)
    80001932:	f052                	sd	s4,32(sp)
    80001934:	ec56                	sd	s5,24(sp)
    80001936:	e85a                	sd	s6,16(sp)
    80001938:	e45e                	sd	s7,8(sp)
    8000193a:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    8000193c:	00007597          	auipc	a1,0x7
    80001940:	89458593          	addi	a1,a1,-1900 # 800081d0 <digits+0x190>
    80001944:	00010517          	auipc	a0,0x10
    80001948:	00c50513          	addi	a0,a0,12 # 80011950 <pid_lock>
    8000194c:	fffff097          	auipc	ra,0xfffff
    80001950:	27a080e7          	jalr	634(ra) # 80000bc6 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001954:	00010917          	auipc	s2,0x10
    80001958:	41490913          	addi	s2,s2,1044 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    8000195c:	00007b97          	auipc	s7,0x7
    80001960:	87cb8b93          	addi	s7,s7,-1924 # 800081d8 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    80001964:	8b4a                	mv	s6,s2
    80001966:	00006a97          	auipc	s5,0x6
    8000196a:	69aa8a93          	addi	s5,s5,1690 # 80008000 <etext>
    8000196e:	040009b7          	lui	s3,0x4000
    80001972:	19fd                	addi	s3,s3,-1
    80001974:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001976:	00016a17          	auipc	s4,0x16
    8000197a:	ff2a0a13          	addi	s4,s4,-14 # 80017968 <tickslock>
      initlock(&p->lock, "proc");
    8000197e:	85de                	mv	a1,s7
    80001980:	854a                	mv	a0,s2
    80001982:	fffff097          	auipc	ra,0xfffff
    80001986:	244080e7          	jalr	580(ra) # 80000bc6 <initlock>
      char *pa = kalloc();
    8000198a:	fffff097          	auipc	ra,0xfffff
    8000198e:	192080e7          	jalr	402(ra) # 80000b1c <kalloc>
    80001992:	85aa                	mv	a1,a0
      if(pa == 0)
    80001994:	c929                	beqz	a0,800019e6 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001996:	416904b3          	sub	s1,s2,s6
    8000199a:	8491                	srai	s1,s1,0x4
    8000199c:	000ab783          	ld	a5,0(s5)
    800019a0:	02f484b3          	mul	s1,s1,a5
    800019a4:	2485                	addiw	s1,s1,1
    800019a6:	00d4949b          	slliw	s1,s1,0xd
    800019aa:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019ae:	4699                	li	a3,6
    800019b0:	6605                	lui	a2,0x1
    800019b2:	8526                	mv	a0,s1
    800019b4:	00000097          	auipc	ra,0x0
    800019b8:	85a080e7          	jalr	-1958(ra) # 8000120e <kvmmap>
      p->kstack = va;
    800019bc:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019c0:	17090913          	addi	s2,s2,368
    800019c4:	fb491de3          	bne	s2,s4,8000197e <procinit+0x58>
  kvminithart();
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	64e080e7          	jalr	1614(ra) # 80001016 <kvminithart>
}
    800019d0:	60a6                	ld	ra,72(sp)
    800019d2:	6406                	ld	s0,64(sp)
    800019d4:	74e2                	ld	s1,56(sp)
    800019d6:	7942                	ld	s2,48(sp)
    800019d8:	79a2                	ld	s3,40(sp)
    800019da:	7a02                	ld	s4,32(sp)
    800019dc:	6ae2                	ld	s5,24(sp)
    800019de:	6b42                	ld	s6,16(sp)
    800019e0:	6ba2                	ld	s7,8(sp)
    800019e2:	6161                	addi	sp,sp,80
    800019e4:	8082                	ret
        panic("kalloc");
    800019e6:	00006517          	auipc	a0,0x6
    800019ea:	7fa50513          	addi	a0,a0,2042 # 800081e0 <digits+0x1a0>
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	b62080e7          	jalr	-1182(ra) # 80000550 <panic>

00000000800019f6 <cpuid>:
{
    800019f6:	1141                	addi	sp,sp,-16
    800019f8:	e422                	sd	s0,8(sp)
    800019fa:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019fc:	8512                	mv	a0,tp
}
    800019fe:	2501                	sext.w	a0,a0
    80001a00:	6422                	ld	s0,8(sp)
    80001a02:	0141                	addi	sp,sp,16
    80001a04:	8082                	ret

0000000080001a06 <mycpu>:
mycpu(void) {
    80001a06:	1141                	addi	sp,sp,-16
    80001a08:	e422                	sd	s0,8(sp)
    80001a0a:	0800                	addi	s0,sp,16
    80001a0c:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a0e:	2781                	sext.w	a5,a5
    80001a10:	079e                	slli	a5,a5,0x7
}
    80001a12:	00010517          	auipc	a0,0x10
    80001a16:	f5650513          	addi	a0,a0,-170 # 80011968 <cpus>
    80001a1a:	953e                	add	a0,a0,a5
    80001a1c:	6422                	ld	s0,8(sp)
    80001a1e:	0141                	addi	sp,sp,16
    80001a20:	8082                	ret

0000000080001a22 <myproc>:
myproc(void) {
    80001a22:	1101                	addi	sp,sp,-32
    80001a24:	ec06                	sd	ra,24(sp)
    80001a26:	e822                	sd	s0,16(sp)
    80001a28:	e426                	sd	s1,8(sp)
    80001a2a:	1000                	addi	s0,sp,32
  push_off();
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	1de080e7          	jalr	478(ra) # 80000c0a <push_off>
    80001a34:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a36:	2781                	sext.w	a5,a5
    80001a38:	079e                	slli	a5,a5,0x7
    80001a3a:	00010717          	auipc	a4,0x10
    80001a3e:	f1670713          	addi	a4,a4,-234 # 80011950 <pid_lock>
    80001a42:	97ba                	add	a5,a5,a4
    80001a44:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a46:	fffff097          	auipc	ra,0xfffff
    80001a4a:	264080e7          	jalr	612(ra) # 80000caa <pop_off>
}
    80001a4e:	8526                	mv	a0,s1
    80001a50:	60e2                	ld	ra,24(sp)
    80001a52:	6442                	ld	s0,16(sp)
    80001a54:	64a2                	ld	s1,8(sp)
    80001a56:	6105                	addi	sp,sp,32
    80001a58:	8082                	ret

0000000080001a5a <forkret>:
{
    80001a5a:	1141                	addi	sp,sp,-16
    80001a5c:	e406                	sd	ra,8(sp)
    80001a5e:	e022                	sd	s0,0(sp)
    80001a60:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a62:	00000097          	auipc	ra,0x0
    80001a66:	fc0080e7          	jalr	-64(ra) # 80001a22 <myproc>
    80001a6a:	fffff097          	auipc	ra,0xfffff
    80001a6e:	2a0080e7          	jalr	672(ra) # 80000d0a <release>
  if (first) {
    80001a72:	00007797          	auipc	a5,0x7
    80001a76:	e6e7a783          	lw	a5,-402(a5) # 800088e0 <first.1>
    80001a7a:	eb89                	bnez	a5,80001a8c <forkret+0x32>
  usertrapret();
    80001a7c:	00001097          	auipc	ra,0x1
    80001a80:	c4e080e7          	jalr	-946(ra) # 800026ca <usertrapret>
}
    80001a84:	60a2                	ld	ra,8(sp)
    80001a86:	6402                	ld	s0,0(sp)
    80001a88:	0141                	addi	sp,sp,16
    80001a8a:	8082                	ret
    first = 0;
    80001a8c:	00007797          	auipc	a5,0x7
    80001a90:	e407aa23          	sw	zero,-428(a5) # 800088e0 <first.1>
    fsinit(ROOTDEV);
    80001a94:	4505                	li	a0,1
    80001a96:	00002097          	auipc	ra,0x2
    80001a9a:	a44080e7          	jalr	-1468(ra) # 800034da <fsinit>
    80001a9e:	bff9                	j	80001a7c <forkret+0x22>

0000000080001aa0 <allocpid>:
allocpid() {
    80001aa0:	1101                	addi	sp,sp,-32
    80001aa2:	ec06                	sd	ra,24(sp)
    80001aa4:	e822                	sd	s0,16(sp)
    80001aa6:	e426                	sd	s1,8(sp)
    80001aa8:	e04a                	sd	s2,0(sp)
    80001aaa:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aac:	00010917          	auipc	s2,0x10
    80001ab0:	ea490913          	addi	s2,s2,-348 # 80011950 <pid_lock>
    80001ab4:	854a                	mv	a0,s2
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	1a0080e7          	jalr	416(ra) # 80000c56 <acquire>
  pid = nextpid;
    80001abe:	00007797          	auipc	a5,0x7
    80001ac2:	e2678793          	addi	a5,a5,-474 # 800088e4 <nextpid>
    80001ac6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ac8:	0014871b          	addiw	a4,s1,1
    80001acc:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ace:	854a                	mv	a0,s2
    80001ad0:	fffff097          	auipc	ra,0xfffff
    80001ad4:	23a080e7          	jalr	570(ra) # 80000d0a <release>
}
    80001ad8:	8526                	mv	a0,s1
    80001ada:	60e2                	ld	ra,24(sp)
    80001adc:	6442                	ld	s0,16(sp)
    80001ade:	64a2                	ld	s1,8(sp)
    80001ae0:	6902                	ld	s2,0(sp)
    80001ae2:	6105                	addi	sp,sp,32
    80001ae4:	8082                	ret

0000000080001ae6 <proc_pagetable>:
{
    80001ae6:	1101                	addi	sp,sp,-32
    80001ae8:	ec06                	sd	ra,24(sp)
    80001aea:	e822                	sd	s0,16(sp)
    80001aec:	e426                	sd	s1,8(sp)
    80001aee:	e04a                	sd	s2,0(sp)
    80001af0:	1000                	addi	s0,sp,32
    80001af2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001af4:	00000097          	auipc	ra,0x0
    80001af8:	8e8080e7          	jalr	-1816(ra) # 800013dc <uvmcreate>
    80001afc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001afe:	c121                	beqz	a0,80001b3e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b00:	4729                	li	a4,10
    80001b02:	00005697          	auipc	a3,0x5
    80001b06:	4fe68693          	addi	a3,a3,1278 # 80007000 <_trampoline>
    80001b0a:	6605                	lui	a2,0x1
    80001b0c:	040005b7          	lui	a1,0x4000
    80001b10:	15fd                	addi	a1,a1,-1
    80001b12:	05b2                	slli	a1,a1,0xc
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	66c080e7          	jalr	1644(ra) # 80001180 <mappages>
    80001b1c:	02054863          	bltz	a0,80001b4c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b20:	4719                	li	a4,6
    80001b22:	05893683          	ld	a3,88(s2)
    80001b26:	6605                	lui	a2,0x1
    80001b28:	020005b7          	lui	a1,0x2000
    80001b2c:	15fd                	addi	a1,a1,-1
    80001b2e:	05b6                	slli	a1,a1,0xd
    80001b30:	8526                	mv	a0,s1
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	64e080e7          	jalr	1614(ra) # 80001180 <mappages>
    80001b3a:	02054163          	bltz	a0,80001b5c <proc_pagetable+0x76>
}
    80001b3e:	8526                	mv	a0,s1
    80001b40:	60e2                	ld	ra,24(sp)
    80001b42:	6442                	ld	s0,16(sp)
    80001b44:	64a2                	ld	s1,8(sp)
    80001b46:	6902                	ld	s2,0(sp)
    80001b48:	6105                	addi	sp,sp,32
    80001b4a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b4c:	4581                	li	a1,0
    80001b4e:	8526                	mv	a0,s1
    80001b50:	00000097          	auipc	ra,0x0
    80001b54:	a88080e7          	jalr	-1400(ra) # 800015d8 <uvmfree>
    return 0;
    80001b58:	4481                	li	s1,0
    80001b5a:	b7d5                	j	80001b3e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b5c:	4681                	li	a3,0
    80001b5e:	4605                	li	a2,1
    80001b60:	040005b7          	lui	a1,0x4000
    80001b64:	15fd                	addi	a1,a1,-1
    80001b66:	05b2                	slli	a1,a1,0xc
    80001b68:	8526                	mv	a0,s1
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	7ae080e7          	jalr	1966(ra) # 80001318 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b72:	4581                	li	a1,0
    80001b74:	8526                	mv	a0,s1
    80001b76:	00000097          	auipc	ra,0x0
    80001b7a:	a62080e7          	jalr	-1438(ra) # 800015d8 <uvmfree>
    return 0;
    80001b7e:	4481                	li	s1,0
    80001b80:	bf7d                	j	80001b3e <proc_pagetable+0x58>

0000000080001b82 <proc_freepagetable>:
{
    80001b82:	1101                	addi	sp,sp,-32
    80001b84:	ec06                	sd	ra,24(sp)
    80001b86:	e822                	sd	s0,16(sp)
    80001b88:	e426                	sd	s1,8(sp)
    80001b8a:	e04a                	sd	s2,0(sp)
    80001b8c:	1000                	addi	s0,sp,32
    80001b8e:	84aa                	mv	s1,a0
    80001b90:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b92:	4681                	li	a3,0
    80001b94:	4605                	li	a2,1
    80001b96:	040005b7          	lui	a1,0x4000
    80001b9a:	15fd                	addi	a1,a1,-1
    80001b9c:	05b2                	slli	a1,a1,0xc
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	77a080e7          	jalr	1914(ra) # 80001318 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ba6:	4681                	li	a3,0
    80001ba8:	4605                	li	a2,1
    80001baa:	020005b7          	lui	a1,0x2000
    80001bae:	15fd                	addi	a1,a1,-1
    80001bb0:	05b6                	slli	a1,a1,0xd
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	764080e7          	jalr	1892(ra) # 80001318 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bbc:	85ca                	mv	a1,s2
    80001bbe:	8526                	mv	a0,s1
    80001bc0:	00000097          	auipc	ra,0x0
    80001bc4:	a18080e7          	jalr	-1512(ra) # 800015d8 <uvmfree>
}
    80001bc8:	60e2                	ld	ra,24(sp)
    80001bca:	6442                	ld	s0,16(sp)
    80001bcc:	64a2                	ld	s1,8(sp)
    80001bce:	6902                	ld	s2,0(sp)
    80001bd0:	6105                	addi	sp,sp,32
    80001bd2:	8082                	ret

0000000080001bd4 <freeproc>:
{
    80001bd4:	1101                	addi	sp,sp,-32
    80001bd6:	ec06                	sd	ra,24(sp)
    80001bd8:	e822                	sd	s0,16(sp)
    80001bda:	e426                	sd	s1,8(sp)
    80001bdc:	1000                	addi	s0,sp,32
    80001bde:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001be0:	6d28                	ld	a0,88(a0)
    80001be2:	c509                	beqz	a0,80001bec <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	e3c080e7          	jalr	-452(ra) # 80000a20 <kfree>
  p->trapframe = 0;
    80001bec:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bf0:	68a8                	ld	a0,80(s1)
    80001bf2:	c511                	beqz	a0,80001bfe <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bf4:	64ac                	ld	a1,72(s1)
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	f8c080e7          	jalr	-116(ra) # 80001b82 <proc_freepagetable>
  p->pagetable = 0;
    80001bfe:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c02:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c06:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c0a:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c0e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c12:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c16:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c1a:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c1e:	0004ac23          	sw	zero,24(s1)
}
    80001c22:	60e2                	ld	ra,24(sp)
    80001c24:	6442                	ld	s0,16(sp)
    80001c26:	64a2                	ld	s1,8(sp)
    80001c28:	6105                	addi	sp,sp,32
    80001c2a:	8082                	ret

0000000080001c2c <allocproc>:
{
    80001c2c:	1101                	addi	sp,sp,-32
    80001c2e:	ec06                	sd	ra,24(sp)
    80001c30:	e822                	sd	s0,16(sp)
    80001c32:	e426                	sd	s1,8(sp)
    80001c34:	e04a                	sd	s2,0(sp)
    80001c36:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c38:	00010497          	auipc	s1,0x10
    80001c3c:	13048493          	addi	s1,s1,304 # 80011d68 <proc>
    80001c40:	00016917          	auipc	s2,0x16
    80001c44:	d2890913          	addi	s2,s2,-728 # 80017968 <tickslock>
    acquire(&p->lock);
    80001c48:	8526                	mv	a0,s1
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	00c080e7          	jalr	12(ra) # 80000c56 <acquire>
    if(p->state == UNUSED) {
    80001c52:	4c9c                	lw	a5,24(s1)
    80001c54:	cf81                	beqz	a5,80001c6c <allocproc+0x40>
      release(&p->lock);
    80001c56:	8526                	mv	a0,s1
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	0b2080e7          	jalr	178(ra) # 80000d0a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	17048493          	addi	s1,s1,368
    80001c64:	ff2492e3          	bne	s1,s2,80001c48 <allocproc+0x1c>
  return 0;
    80001c68:	4481                	li	s1,0
    80001c6a:	a889                	j	80001cbc <allocproc+0x90>
  p->pid = allocpid();
    80001c6c:	00000097          	auipc	ra,0x0
    80001c70:	e34080e7          	jalr	-460(ra) # 80001aa0 <allocpid>
    80001c74:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c76:	fffff097          	auipc	ra,0xfffff
    80001c7a:	ea6080e7          	jalr	-346(ra) # 80000b1c <kalloc>
    80001c7e:	892a                	mv	s2,a0
    80001c80:	eca8                	sd	a0,88(s1)
    80001c82:	c521                	beqz	a0,80001cca <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c84:	8526                	mv	a0,s1
    80001c86:	00000097          	auipc	ra,0x0
    80001c8a:	e60080e7          	jalr	-416(ra) # 80001ae6 <proc_pagetable>
    80001c8e:	892a                	mv	s2,a0
    80001c90:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c92:	c139                	beqz	a0,80001cd8 <allocproc+0xac>
  memset(&p->context, 0, sizeof(p->context));
    80001c94:	07000613          	li	a2,112
    80001c98:	4581                	li	a1,0
    80001c9a:	06048513          	addi	a0,s1,96
    80001c9e:	fffff097          	auipc	ra,0xfffff
    80001ca2:	0b4080e7          	jalr	180(ra) # 80000d52 <memset>
  p->context.ra = (uint64)forkret;
    80001ca6:	00000797          	auipc	a5,0x0
    80001caa:	db478793          	addi	a5,a5,-588 # 80001a5a <forkret>
    80001cae:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cb0:	60bc                	ld	a5,64(s1)
    80001cb2:	6705                	lui	a4,0x1
    80001cb4:	97ba                	add	a5,a5,a4
    80001cb6:	f4bc                	sd	a5,104(s1)
  p->syscall_trace = 0;
    80001cb8:	1604b423          	sd	zero,360(s1)
}
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	60e2                	ld	ra,24(sp)
    80001cc0:	6442                	ld	s0,16(sp)
    80001cc2:	64a2                	ld	s1,8(sp)
    80001cc4:	6902                	ld	s2,0(sp)
    80001cc6:	6105                	addi	sp,sp,32
    80001cc8:	8082                	ret
    release(&p->lock);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	03e080e7          	jalr	62(ra) # 80000d0a <release>
    return 0;
    80001cd4:	84ca                	mv	s1,s2
    80001cd6:	b7dd                	j	80001cbc <allocproc+0x90>
    freeproc(p);
    80001cd8:	8526                	mv	a0,s1
    80001cda:	00000097          	auipc	ra,0x0
    80001cde:	efa080e7          	jalr	-262(ra) # 80001bd4 <freeproc>
    release(&p->lock);
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	026080e7          	jalr	38(ra) # 80000d0a <release>
    return 0;
    80001cec:	84ca                	mv	s1,s2
    80001cee:	b7f9                	j	80001cbc <allocproc+0x90>

0000000080001cf0 <userinit>:
{
    80001cf0:	1101                	addi	sp,sp,-32
    80001cf2:	ec06                	sd	ra,24(sp)
    80001cf4:	e822                	sd	s0,16(sp)
    80001cf6:	e426                	sd	s1,8(sp)
    80001cf8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cfa:	00000097          	auipc	ra,0x0
    80001cfe:	f32080e7          	jalr	-206(ra) # 80001c2c <allocproc>
    80001d02:	84aa                	mv	s1,a0
  initproc = p;
    80001d04:	00007797          	auipc	a5,0x7
    80001d08:	30a7ba23          	sd	a0,788(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d0c:	03400613          	li	a2,52
    80001d10:	00007597          	auipc	a1,0x7
    80001d14:	be058593          	addi	a1,a1,-1056 # 800088f0 <initcode>
    80001d18:	6928                	ld	a0,80(a0)
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	6f0080e7          	jalr	1776(ra) # 8000140a <uvminit>
  p->sz = PGSIZE;
    80001d22:	6785                	lui	a5,0x1
    80001d24:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d26:	6cb8                	ld	a4,88(s1)
    80001d28:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d2c:	6cb8                	ld	a4,88(s1)
    80001d2e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d30:	4641                	li	a2,16
    80001d32:	00006597          	auipc	a1,0x6
    80001d36:	4b658593          	addi	a1,a1,1206 # 800081e8 <digits+0x1a8>
    80001d3a:	15848513          	addi	a0,s1,344
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	166080e7          	jalr	358(ra) # 80000ea4 <safestrcpy>
  p->cwd = namei("/");
    80001d46:	00006517          	auipc	a0,0x6
    80001d4a:	4b250513          	addi	a0,a0,1202 # 800081f8 <digits+0x1b8>
    80001d4e:	00002097          	auipc	ra,0x2
    80001d52:	1b4080e7          	jalr	436(ra) # 80003f02 <namei>
    80001d56:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d5a:	4789                	li	a5,2
    80001d5c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d5e:	8526                	mv	a0,s1
    80001d60:	fffff097          	auipc	ra,0xfffff
    80001d64:	faa080e7          	jalr	-86(ra) # 80000d0a <release>
}
    80001d68:	60e2                	ld	ra,24(sp)
    80001d6a:	6442                	ld	s0,16(sp)
    80001d6c:	64a2                	ld	s1,8(sp)
    80001d6e:	6105                	addi	sp,sp,32
    80001d70:	8082                	ret

0000000080001d72 <growproc>:
{
    80001d72:	1101                	addi	sp,sp,-32
    80001d74:	ec06                	sd	ra,24(sp)
    80001d76:	e822                	sd	s0,16(sp)
    80001d78:	e426                	sd	s1,8(sp)
    80001d7a:	e04a                	sd	s2,0(sp)
    80001d7c:	1000                	addi	s0,sp,32
    80001d7e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d80:	00000097          	auipc	ra,0x0
    80001d84:	ca2080e7          	jalr	-862(ra) # 80001a22 <myproc>
    80001d88:	892a                	mv	s2,a0
  sz = p->sz;
    80001d8a:	652c                	ld	a1,72(a0)
    80001d8c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d90:	00904f63          	bgtz	s1,80001dae <growproc+0x3c>
  } else if(n < 0){
    80001d94:	0204cc63          	bltz	s1,80001dcc <growproc+0x5a>
  p->sz = sz;
    80001d98:	1602                	slli	a2,a2,0x20
    80001d9a:	9201                	srli	a2,a2,0x20
    80001d9c:	04c93423          	sd	a2,72(s2)
  return 0;
    80001da0:	4501                	li	a0,0
}
    80001da2:	60e2                	ld	ra,24(sp)
    80001da4:	6442                	ld	s0,16(sp)
    80001da6:	64a2                	ld	s1,8(sp)
    80001da8:	6902                	ld	s2,0(sp)
    80001daa:	6105                	addi	sp,sp,32
    80001dac:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dae:	9e25                	addw	a2,a2,s1
    80001db0:	1602                	slli	a2,a2,0x20
    80001db2:	9201                	srli	a2,a2,0x20
    80001db4:	1582                	slli	a1,a1,0x20
    80001db6:	9181                	srli	a1,a1,0x20
    80001db8:	6928                	ld	a0,80(a0)
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	70a080e7          	jalr	1802(ra) # 800014c4 <uvmalloc>
    80001dc2:	0005061b          	sext.w	a2,a0
    80001dc6:	fa69                	bnez	a2,80001d98 <growproc+0x26>
      return -1;
    80001dc8:	557d                	li	a0,-1
    80001dca:	bfe1                	j	80001da2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dcc:	9e25                	addw	a2,a2,s1
    80001dce:	1602                	slli	a2,a2,0x20
    80001dd0:	9201                	srli	a2,a2,0x20
    80001dd2:	1582                	slli	a1,a1,0x20
    80001dd4:	9181                	srli	a1,a1,0x20
    80001dd6:	6928                	ld	a0,80(a0)
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	6a4080e7          	jalr	1700(ra) # 8000147c <uvmdealloc>
    80001de0:	0005061b          	sext.w	a2,a0
    80001de4:	bf55                	j	80001d98 <growproc+0x26>

0000000080001de6 <fork>:
{
    80001de6:	7139                	addi	sp,sp,-64
    80001de8:	fc06                	sd	ra,56(sp)
    80001dea:	f822                	sd	s0,48(sp)
    80001dec:	f426                	sd	s1,40(sp)
    80001dee:	f04a                	sd	s2,32(sp)
    80001df0:	ec4e                	sd	s3,24(sp)
    80001df2:	e852                	sd	s4,16(sp)
    80001df4:	e456                	sd	s5,8(sp)
    80001df6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001df8:	00000097          	auipc	ra,0x0
    80001dfc:	c2a080e7          	jalr	-982(ra) # 80001a22 <myproc>
    80001e00:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e02:	00000097          	auipc	ra,0x0
    80001e06:	e2a080e7          	jalr	-470(ra) # 80001c2c <allocproc>
    80001e0a:	c57d                	beqz	a0,80001ef8 <fork+0x112>
    80001e0c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e0e:	048ab603          	ld	a2,72(s5)
    80001e12:	692c                	ld	a1,80(a0)
    80001e14:	050ab503          	ld	a0,80(s5)
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	7f8080e7          	jalr	2040(ra) # 80001610 <uvmcopy>
    80001e20:	04054a63          	bltz	a0,80001e74 <fork+0x8e>
  np->sz = p->sz;
    80001e24:	048ab783          	ld	a5,72(s5)
    80001e28:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001e2c:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e30:	058ab683          	ld	a3,88(s5)
    80001e34:	87b6                	mv	a5,a3
    80001e36:	058a3703          	ld	a4,88(s4)
    80001e3a:	12068693          	addi	a3,a3,288
    80001e3e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e42:	6788                	ld	a0,8(a5)
    80001e44:	6b8c                	ld	a1,16(a5)
    80001e46:	6f90                	ld	a2,24(a5)
    80001e48:	01073023          	sd	a6,0(a4)
    80001e4c:	e708                	sd	a0,8(a4)
    80001e4e:	eb0c                	sd	a1,16(a4)
    80001e50:	ef10                	sd	a2,24(a4)
    80001e52:	02078793          	addi	a5,a5,32
    80001e56:	02070713          	addi	a4,a4,32
    80001e5a:	fed792e3          	bne	a5,a3,80001e3e <fork+0x58>
  np->trapframe->a0 = 0;
    80001e5e:	058a3783          	ld	a5,88(s4)
    80001e62:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e66:	0d0a8493          	addi	s1,s5,208
    80001e6a:	0d0a0913          	addi	s2,s4,208
    80001e6e:	150a8993          	addi	s3,s5,336
    80001e72:	a00d                	j	80001e94 <fork+0xae>
    freeproc(np);
    80001e74:	8552                	mv	a0,s4
    80001e76:	00000097          	auipc	ra,0x0
    80001e7a:	d5e080e7          	jalr	-674(ra) # 80001bd4 <freeproc>
    release(&np->lock);
    80001e7e:	8552                	mv	a0,s4
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	e8a080e7          	jalr	-374(ra) # 80000d0a <release>
    return -1;
    80001e88:	54fd                	li	s1,-1
    80001e8a:	a8a9                	j	80001ee4 <fork+0xfe>
  for(i = 0; i < NOFILE; i++)
    80001e8c:	04a1                	addi	s1,s1,8
    80001e8e:	0921                	addi	s2,s2,8
    80001e90:	01348b63          	beq	s1,s3,80001ea6 <fork+0xc0>
    if(p->ofile[i])
    80001e94:	6088                	ld	a0,0(s1)
    80001e96:	d97d                	beqz	a0,80001e8c <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e98:	00002097          	auipc	ra,0x2
    80001e9c:	6f6080e7          	jalr	1782(ra) # 8000458e <filedup>
    80001ea0:	00a93023          	sd	a0,0(s2)
    80001ea4:	b7e5                	j	80001e8c <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ea6:	150ab503          	ld	a0,336(s5)
    80001eaa:	00002097          	auipc	ra,0x2
    80001eae:	86a080e7          	jalr	-1942(ra) # 80003714 <idup>
    80001eb2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eb6:	4641                	li	a2,16
    80001eb8:	158a8593          	addi	a1,s5,344
    80001ebc:	158a0513          	addi	a0,s4,344
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	fe4080e7          	jalr	-28(ra) # 80000ea4 <safestrcpy>
  np->syscall_trace = p->syscall_trace;
    80001ec8:	168ab783          	ld	a5,360(s5)
    80001ecc:	16fa3423          	sd	a5,360(s4)
  pid = np->pid;
    80001ed0:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001ed4:	4789                	li	a5,2
    80001ed6:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eda:	8552                	mv	a0,s4
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	e2e080e7          	jalr	-466(ra) # 80000d0a <release>
}
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	70e2                	ld	ra,56(sp)
    80001ee8:	7442                	ld	s0,48(sp)
    80001eea:	74a2                	ld	s1,40(sp)
    80001eec:	7902                	ld	s2,32(sp)
    80001eee:	69e2                	ld	s3,24(sp)
    80001ef0:	6a42                	ld	s4,16(sp)
    80001ef2:	6aa2                	ld	s5,8(sp)
    80001ef4:	6121                	addi	sp,sp,64
    80001ef6:	8082                	ret
    return -1;
    80001ef8:	54fd                	li	s1,-1
    80001efa:	b7ed                	j	80001ee4 <fork+0xfe>

0000000080001efc <reparent>:
{
    80001efc:	7179                	addi	sp,sp,-48
    80001efe:	f406                	sd	ra,40(sp)
    80001f00:	f022                	sd	s0,32(sp)
    80001f02:	ec26                	sd	s1,24(sp)
    80001f04:	e84a                	sd	s2,16(sp)
    80001f06:	e44e                	sd	s3,8(sp)
    80001f08:	e052                	sd	s4,0(sp)
    80001f0a:	1800                	addi	s0,sp,48
    80001f0c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f0e:	00010497          	auipc	s1,0x10
    80001f12:	e5a48493          	addi	s1,s1,-422 # 80011d68 <proc>
      pp->parent = initproc;
    80001f16:	00007a17          	auipc	s4,0x7
    80001f1a:	102a0a13          	addi	s4,s4,258 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f1e:	00016997          	auipc	s3,0x16
    80001f22:	a4a98993          	addi	s3,s3,-1462 # 80017968 <tickslock>
    80001f26:	a029                	j	80001f30 <reparent+0x34>
    80001f28:	17048493          	addi	s1,s1,368
    80001f2c:	03348363          	beq	s1,s3,80001f52 <reparent+0x56>
    if(pp->parent == p){
    80001f30:	709c                	ld	a5,32(s1)
    80001f32:	ff279be3          	bne	a5,s2,80001f28 <reparent+0x2c>
      acquire(&pp->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	d1e080e7          	jalr	-738(ra) # 80000c56 <acquire>
      pp->parent = initproc;
    80001f40:	000a3783          	ld	a5,0(s4)
    80001f44:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f46:	8526                	mv	a0,s1
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	dc2080e7          	jalr	-574(ra) # 80000d0a <release>
    80001f50:	bfe1                	j	80001f28 <reparent+0x2c>
}
    80001f52:	70a2                	ld	ra,40(sp)
    80001f54:	7402                	ld	s0,32(sp)
    80001f56:	64e2                	ld	s1,24(sp)
    80001f58:	6942                	ld	s2,16(sp)
    80001f5a:	69a2                	ld	s3,8(sp)
    80001f5c:	6a02                	ld	s4,0(sp)
    80001f5e:	6145                	addi	sp,sp,48
    80001f60:	8082                	ret

0000000080001f62 <scheduler>:
{
    80001f62:	715d                	addi	sp,sp,-80
    80001f64:	e486                	sd	ra,72(sp)
    80001f66:	e0a2                	sd	s0,64(sp)
    80001f68:	fc26                	sd	s1,56(sp)
    80001f6a:	f84a                	sd	s2,48(sp)
    80001f6c:	f44e                	sd	s3,40(sp)
    80001f6e:	f052                	sd	s4,32(sp)
    80001f70:	ec56                	sd	s5,24(sp)
    80001f72:	e85a                	sd	s6,16(sp)
    80001f74:	e45e                	sd	s7,8(sp)
    80001f76:	e062                	sd	s8,0(sp)
    80001f78:	0880                	addi	s0,sp,80
    80001f7a:	8792                	mv	a5,tp
  int id = r_tp();
    80001f7c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f7e:	00779b13          	slli	s6,a5,0x7
    80001f82:	00010717          	auipc	a4,0x10
    80001f86:	9ce70713          	addi	a4,a4,-1586 # 80011950 <pid_lock>
    80001f8a:	975a                	add	a4,a4,s6
    80001f8c:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f90:	00010717          	auipc	a4,0x10
    80001f94:	9e070713          	addi	a4,a4,-1568 # 80011970 <cpus+0x8>
    80001f98:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f9a:	4c0d                	li	s8,3
        c->proc = p;
    80001f9c:	079e                	slli	a5,a5,0x7
    80001f9e:	00010a17          	auipc	s4,0x10
    80001fa2:	9b2a0a13          	addi	s4,s4,-1614 # 80011950 <pid_lock>
    80001fa6:	9a3e                	add	s4,s4,a5
        found = 1;
    80001fa8:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001faa:	00016997          	auipc	s3,0x16
    80001fae:	9be98993          	addi	s3,s3,-1602 # 80017968 <tickslock>
    80001fb2:	a899                	j	80002008 <scheduler+0xa6>
      release(&p->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	d54080e7          	jalr	-684(ra) # 80000d0a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fbe:	17048493          	addi	s1,s1,368
    80001fc2:	03348963          	beq	s1,s3,80001ff4 <scheduler+0x92>
      acquire(&p->lock);
    80001fc6:	8526                	mv	a0,s1
    80001fc8:	fffff097          	auipc	ra,0xfffff
    80001fcc:	c8e080e7          	jalr	-882(ra) # 80000c56 <acquire>
      if(p->state == RUNNABLE) {
    80001fd0:	4c9c                	lw	a5,24(s1)
    80001fd2:	ff2791e3          	bne	a5,s2,80001fb4 <scheduler+0x52>
        p->state = RUNNING;
    80001fd6:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fda:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80001fde:	06048593          	addi	a1,s1,96
    80001fe2:	855a                	mv	a0,s6
    80001fe4:	00000097          	auipc	ra,0x0
    80001fe8:	63c080e7          	jalr	1596(ra) # 80002620 <swtch>
        c->proc = 0;
    80001fec:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001ff0:	8ade                	mv	s5,s7
    80001ff2:	b7c9                	j	80001fb4 <scheduler+0x52>
    if(found == 0) {
    80001ff4:	000a9a63          	bnez	s5,80002008 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ff8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ffc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002000:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002004:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002008:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000200c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002010:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002014:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002016:	00010497          	auipc	s1,0x10
    8000201a:	d5248493          	addi	s1,s1,-686 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    8000201e:	4909                	li	s2,2
    80002020:	b75d                	j	80001fc6 <scheduler+0x64>

0000000080002022 <sched>:
{
    80002022:	7179                	addi	sp,sp,-48
    80002024:	f406                	sd	ra,40(sp)
    80002026:	f022                	sd	s0,32(sp)
    80002028:	ec26                	sd	s1,24(sp)
    8000202a:	e84a                	sd	s2,16(sp)
    8000202c:	e44e                	sd	s3,8(sp)
    8000202e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002030:	00000097          	auipc	ra,0x0
    80002034:	9f2080e7          	jalr	-1550(ra) # 80001a22 <myproc>
    80002038:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000203a:	fffff097          	auipc	ra,0xfffff
    8000203e:	ba2080e7          	jalr	-1118(ra) # 80000bdc <holding>
    80002042:	c93d                	beqz	a0,800020b8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002044:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002046:	2781                	sext.w	a5,a5
    80002048:	079e                	slli	a5,a5,0x7
    8000204a:	00010717          	auipc	a4,0x10
    8000204e:	90670713          	addi	a4,a4,-1786 # 80011950 <pid_lock>
    80002052:	97ba                	add	a5,a5,a4
    80002054:	0907a703          	lw	a4,144(a5)
    80002058:	4785                	li	a5,1
    8000205a:	06f71763          	bne	a4,a5,800020c8 <sched+0xa6>
  if(p->state == RUNNING)
    8000205e:	4c98                	lw	a4,24(s1)
    80002060:	478d                	li	a5,3
    80002062:	06f70b63          	beq	a4,a5,800020d8 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002066:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000206a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000206c:	efb5                	bnez	a5,800020e8 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000206e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002070:	00010917          	auipc	s2,0x10
    80002074:	8e090913          	addi	s2,s2,-1824 # 80011950 <pid_lock>
    80002078:	2781                	sext.w	a5,a5
    8000207a:	079e                	slli	a5,a5,0x7
    8000207c:	97ca                	add	a5,a5,s2
    8000207e:	0947a983          	lw	s3,148(a5)
    80002082:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002084:	2781                	sext.w	a5,a5
    80002086:	079e                	slli	a5,a5,0x7
    80002088:	00010597          	auipc	a1,0x10
    8000208c:	8e858593          	addi	a1,a1,-1816 # 80011970 <cpus+0x8>
    80002090:	95be                	add	a1,a1,a5
    80002092:	06048513          	addi	a0,s1,96
    80002096:	00000097          	auipc	ra,0x0
    8000209a:	58a080e7          	jalr	1418(ra) # 80002620 <swtch>
    8000209e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020a0:	2781                	sext.w	a5,a5
    800020a2:	079e                	slli	a5,a5,0x7
    800020a4:	97ca                	add	a5,a5,s2
    800020a6:	0937aa23          	sw	s3,148(a5)
}
    800020aa:	70a2                	ld	ra,40(sp)
    800020ac:	7402                	ld	s0,32(sp)
    800020ae:	64e2                	ld	s1,24(sp)
    800020b0:	6942                	ld	s2,16(sp)
    800020b2:	69a2                	ld	s3,8(sp)
    800020b4:	6145                	addi	sp,sp,48
    800020b6:	8082                	ret
    panic("sched p->lock");
    800020b8:	00006517          	auipc	a0,0x6
    800020bc:	14850513          	addi	a0,a0,328 # 80008200 <digits+0x1c0>
    800020c0:	ffffe097          	auipc	ra,0xffffe
    800020c4:	490080e7          	jalr	1168(ra) # 80000550 <panic>
    panic("sched locks");
    800020c8:	00006517          	auipc	a0,0x6
    800020cc:	14850513          	addi	a0,a0,328 # 80008210 <digits+0x1d0>
    800020d0:	ffffe097          	auipc	ra,0xffffe
    800020d4:	480080e7          	jalr	1152(ra) # 80000550 <panic>
    panic("sched running");
    800020d8:	00006517          	auipc	a0,0x6
    800020dc:	14850513          	addi	a0,a0,328 # 80008220 <digits+0x1e0>
    800020e0:	ffffe097          	auipc	ra,0xffffe
    800020e4:	470080e7          	jalr	1136(ra) # 80000550 <panic>
    panic("sched interruptible");
    800020e8:	00006517          	auipc	a0,0x6
    800020ec:	14850513          	addi	a0,a0,328 # 80008230 <digits+0x1f0>
    800020f0:	ffffe097          	auipc	ra,0xffffe
    800020f4:	460080e7          	jalr	1120(ra) # 80000550 <panic>

00000000800020f8 <exit>:
{
    800020f8:	7179                	addi	sp,sp,-48
    800020fa:	f406                	sd	ra,40(sp)
    800020fc:	f022                	sd	s0,32(sp)
    800020fe:	ec26                	sd	s1,24(sp)
    80002100:	e84a                	sd	s2,16(sp)
    80002102:	e44e                	sd	s3,8(sp)
    80002104:	e052                	sd	s4,0(sp)
    80002106:	1800                	addi	s0,sp,48
    80002108:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000210a:	00000097          	auipc	ra,0x0
    8000210e:	918080e7          	jalr	-1768(ra) # 80001a22 <myproc>
    80002112:	89aa                	mv	s3,a0
  if(p == initproc)
    80002114:	00007797          	auipc	a5,0x7
    80002118:	f047b783          	ld	a5,-252(a5) # 80009018 <initproc>
    8000211c:	0d050493          	addi	s1,a0,208
    80002120:	15050913          	addi	s2,a0,336
    80002124:	02a79363          	bne	a5,a0,8000214a <exit+0x52>
    panic("init exiting");
    80002128:	00006517          	auipc	a0,0x6
    8000212c:	12050513          	addi	a0,a0,288 # 80008248 <digits+0x208>
    80002130:	ffffe097          	auipc	ra,0xffffe
    80002134:	420080e7          	jalr	1056(ra) # 80000550 <panic>
      fileclose(f);
    80002138:	00002097          	auipc	ra,0x2
    8000213c:	4a8080e7          	jalr	1192(ra) # 800045e0 <fileclose>
      p->ofile[fd] = 0;
    80002140:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002144:	04a1                	addi	s1,s1,8
    80002146:	01248563          	beq	s1,s2,80002150 <exit+0x58>
    if(p->ofile[fd]){
    8000214a:	6088                	ld	a0,0(s1)
    8000214c:	f575                	bnez	a0,80002138 <exit+0x40>
    8000214e:	bfdd                	j	80002144 <exit+0x4c>
  begin_op();
    80002150:	00002097          	auipc	ra,0x2
    80002154:	fbe080e7          	jalr	-66(ra) # 8000410e <begin_op>
  iput(p->cwd);
    80002158:	1509b503          	ld	a0,336(s3)
    8000215c:	00001097          	auipc	ra,0x1
    80002160:	7b0080e7          	jalr	1968(ra) # 8000390c <iput>
  end_op();
    80002164:	00002097          	auipc	ra,0x2
    80002168:	02a080e7          	jalr	42(ra) # 8000418e <end_op>
  p->cwd = 0;
    8000216c:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002170:	00007497          	auipc	s1,0x7
    80002174:	ea848493          	addi	s1,s1,-344 # 80009018 <initproc>
    80002178:	6088                	ld	a0,0(s1)
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	adc080e7          	jalr	-1316(ra) # 80000c56 <acquire>
  wakeup1(initproc);
    80002182:	6088                	ld	a0,0(s1)
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	75e080e7          	jalr	1886(ra) # 800018e2 <wakeup1>
  release(&initproc->lock);
    8000218c:	6088                	ld	a0,0(s1)
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	b7c080e7          	jalr	-1156(ra) # 80000d0a <release>
  acquire(&p->lock);
    80002196:	854e                	mv	a0,s3
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	abe080e7          	jalr	-1346(ra) # 80000c56 <acquire>
  struct proc *original_parent = p->parent;
    800021a0:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800021a4:	854e                	mv	a0,s3
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	b64080e7          	jalr	-1180(ra) # 80000d0a <release>
  acquire(&original_parent->lock);
    800021ae:	8526                	mv	a0,s1
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	aa6080e7          	jalr	-1370(ra) # 80000c56 <acquire>
  acquire(&p->lock);
    800021b8:	854e                	mv	a0,s3
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	a9c080e7          	jalr	-1380(ra) # 80000c56 <acquire>
  reparent(p);
    800021c2:	854e                	mv	a0,s3
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	d38080e7          	jalr	-712(ra) # 80001efc <reparent>
  wakeup1(original_parent);
    800021cc:	8526                	mv	a0,s1
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	714080e7          	jalr	1812(ra) # 800018e2 <wakeup1>
  p->xstate = status;
    800021d6:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021da:	4791                	li	a5,4
    800021dc:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800021e0:	8526                	mv	a0,s1
    800021e2:	fffff097          	auipc	ra,0xfffff
    800021e6:	b28080e7          	jalr	-1240(ra) # 80000d0a <release>
  sched();
    800021ea:	00000097          	auipc	ra,0x0
    800021ee:	e38080e7          	jalr	-456(ra) # 80002022 <sched>
  panic("zombie exit");
    800021f2:	00006517          	auipc	a0,0x6
    800021f6:	06650513          	addi	a0,a0,102 # 80008258 <digits+0x218>
    800021fa:	ffffe097          	auipc	ra,0xffffe
    800021fe:	356080e7          	jalr	854(ra) # 80000550 <panic>

0000000080002202 <yield>:
{
    80002202:	1101                	addi	sp,sp,-32
    80002204:	ec06                	sd	ra,24(sp)
    80002206:	e822                	sd	s0,16(sp)
    80002208:	e426                	sd	s1,8(sp)
    8000220a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000220c:	00000097          	auipc	ra,0x0
    80002210:	816080e7          	jalr	-2026(ra) # 80001a22 <myproc>
    80002214:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	a40080e7          	jalr	-1472(ra) # 80000c56 <acquire>
  p->state = RUNNABLE;
    8000221e:	4789                	li	a5,2
    80002220:	cc9c                	sw	a5,24(s1)
  sched();
    80002222:	00000097          	auipc	ra,0x0
    80002226:	e00080e7          	jalr	-512(ra) # 80002022 <sched>
  release(&p->lock);
    8000222a:	8526                	mv	a0,s1
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	ade080e7          	jalr	-1314(ra) # 80000d0a <release>
}
    80002234:	60e2                	ld	ra,24(sp)
    80002236:	6442                	ld	s0,16(sp)
    80002238:	64a2                	ld	s1,8(sp)
    8000223a:	6105                	addi	sp,sp,32
    8000223c:	8082                	ret

000000008000223e <sleep>:
{
    8000223e:	7179                	addi	sp,sp,-48
    80002240:	f406                	sd	ra,40(sp)
    80002242:	f022                	sd	s0,32(sp)
    80002244:	ec26                	sd	s1,24(sp)
    80002246:	e84a                	sd	s2,16(sp)
    80002248:	e44e                	sd	s3,8(sp)
    8000224a:	1800                	addi	s0,sp,48
    8000224c:	89aa                	mv	s3,a0
    8000224e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	7d2080e7          	jalr	2002(ra) # 80001a22 <myproc>
    80002258:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000225a:	05250663          	beq	a0,s2,800022a6 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	9f8080e7          	jalr	-1544(ra) # 80000c56 <acquire>
    release(lk);
    80002266:	854a                	mv	a0,s2
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	aa2080e7          	jalr	-1374(ra) # 80000d0a <release>
  p->chan = chan;
    80002270:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002274:	4785                	li	a5,1
    80002276:	cc9c                	sw	a5,24(s1)
  sched();
    80002278:	00000097          	auipc	ra,0x0
    8000227c:	daa080e7          	jalr	-598(ra) # 80002022 <sched>
  p->chan = 0;
    80002280:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	a84080e7          	jalr	-1404(ra) # 80000d0a <release>
    acquire(lk);
    8000228e:	854a                	mv	a0,s2
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	9c6080e7          	jalr	-1594(ra) # 80000c56 <acquire>
}
    80002298:	70a2                	ld	ra,40(sp)
    8000229a:	7402                	ld	s0,32(sp)
    8000229c:	64e2                	ld	s1,24(sp)
    8000229e:	6942                	ld	s2,16(sp)
    800022a0:	69a2                	ld	s3,8(sp)
    800022a2:	6145                	addi	sp,sp,48
    800022a4:	8082                	ret
  p->chan = chan;
    800022a6:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800022aa:	4785                	li	a5,1
    800022ac:	cd1c                	sw	a5,24(a0)
  sched();
    800022ae:	00000097          	auipc	ra,0x0
    800022b2:	d74080e7          	jalr	-652(ra) # 80002022 <sched>
  p->chan = 0;
    800022b6:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022ba:	bff9                	j	80002298 <sleep+0x5a>

00000000800022bc <wait>:
{
    800022bc:	715d                	addi	sp,sp,-80
    800022be:	e486                	sd	ra,72(sp)
    800022c0:	e0a2                	sd	s0,64(sp)
    800022c2:	fc26                	sd	s1,56(sp)
    800022c4:	f84a                	sd	s2,48(sp)
    800022c6:	f44e                	sd	s3,40(sp)
    800022c8:	f052                	sd	s4,32(sp)
    800022ca:	ec56                	sd	s5,24(sp)
    800022cc:	e85a                	sd	s6,16(sp)
    800022ce:	e45e                	sd	s7,8(sp)
    800022d0:	0880                	addi	s0,sp,80
    800022d2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022d4:	fffff097          	auipc	ra,0xfffff
    800022d8:	74e080e7          	jalr	1870(ra) # 80001a22 <myproc>
    800022dc:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	978080e7          	jalr	-1672(ra) # 80000c56 <acquire>
    havekids = 0;
    800022e6:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022e8:	4a11                	li	s4,4
        havekids = 1;
    800022ea:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800022ec:	00015997          	auipc	s3,0x15
    800022f0:	67c98993          	addi	s3,s3,1660 # 80017968 <tickslock>
    havekids = 0;
    800022f4:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022f6:	00010497          	auipc	s1,0x10
    800022fa:	a7248493          	addi	s1,s1,-1422 # 80011d68 <proc>
    800022fe:	a08d                	j	80002360 <wait+0xa4>
          pid = np->pid;
    80002300:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002304:	000b0e63          	beqz	s6,80002320 <wait+0x64>
    80002308:	4691                	li	a3,4
    8000230a:	03448613          	addi	a2,s1,52
    8000230e:	85da                	mv	a1,s6
    80002310:	05093503          	ld	a0,80(s2)
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	400080e7          	jalr	1024(ra) # 80001714 <copyout>
    8000231c:	02054263          	bltz	a0,80002340 <wait+0x84>
          freeproc(np);
    80002320:	8526                	mv	a0,s1
    80002322:	00000097          	auipc	ra,0x0
    80002326:	8b2080e7          	jalr	-1870(ra) # 80001bd4 <freeproc>
          release(&np->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	9de080e7          	jalr	-1570(ra) # 80000d0a <release>
          release(&p->lock);
    80002334:	854a                	mv	a0,s2
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	9d4080e7          	jalr	-1580(ra) # 80000d0a <release>
          return pid;
    8000233e:	a8a9                	j	80002398 <wait+0xdc>
            release(&np->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	9c8080e7          	jalr	-1592(ra) # 80000d0a <release>
            release(&p->lock);
    8000234a:	854a                	mv	a0,s2
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	9be080e7          	jalr	-1602(ra) # 80000d0a <release>
            return -1;
    80002354:	59fd                	li	s3,-1
    80002356:	a089                	j	80002398 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002358:	17048493          	addi	s1,s1,368
    8000235c:	03348463          	beq	s1,s3,80002384 <wait+0xc8>
      if(np->parent == p){
    80002360:	709c                	ld	a5,32(s1)
    80002362:	ff279be3          	bne	a5,s2,80002358 <wait+0x9c>
        acquire(&np->lock);
    80002366:	8526                	mv	a0,s1
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	8ee080e7          	jalr	-1810(ra) # 80000c56 <acquire>
        if(np->state == ZOMBIE){
    80002370:	4c9c                	lw	a5,24(s1)
    80002372:	f94787e3          	beq	a5,s4,80002300 <wait+0x44>
        release(&np->lock);
    80002376:	8526                	mv	a0,s1
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	992080e7          	jalr	-1646(ra) # 80000d0a <release>
        havekids = 1;
    80002380:	8756                	mv	a4,s5
    80002382:	bfd9                	j	80002358 <wait+0x9c>
    if(!havekids || p->killed){
    80002384:	c701                	beqz	a4,8000238c <wait+0xd0>
    80002386:	03092783          	lw	a5,48(s2)
    8000238a:	c39d                	beqz	a5,800023b0 <wait+0xf4>
      release(&p->lock);
    8000238c:	854a                	mv	a0,s2
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	97c080e7          	jalr	-1668(ra) # 80000d0a <release>
      return -1;
    80002396:	59fd                	li	s3,-1
}
    80002398:	854e                	mv	a0,s3
    8000239a:	60a6                	ld	ra,72(sp)
    8000239c:	6406                	ld	s0,64(sp)
    8000239e:	74e2                	ld	s1,56(sp)
    800023a0:	7942                	ld	s2,48(sp)
    800023a2:	79a2                	ld	s3,40(sp)
    800023a4:	7a02                	ld	s4,32(sp)
    800023a6:	6ae2                	ld	s5,24(sp)
    800023a8:	6b42                	ld	s6,16(sp)
    800023aa:	6ba2                	ld	s7,8(sp)
    800023ac:	6161                	addi	sp,sp,80
    800023ae:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023b0:	85ca                	mv	a1,s2
    800023b2:	854a                	mv	a0,s2
    800023b4:	00000097          	auipc	ra,0x0
    800023b8:	e8a080e7          	jalr	-374(ra) # 8000223e <sleep>
    havekids = 0;
    800023bc:	bf25                	j	800022f4 <wait+0x38>

00000000800023be <wakeup>:
{
    800023be:	7139                	addi	sp,sp,-64
    800023c0:	fc06                	sd	ra,56(sp)
    800023c2:	f822                	sd	s0,48(sp)
    800023c4:	f426                	sd	s1,40(sp)
    800023c6:	f04a                	sd	s2,32(sp)
    800023c8:	ec4e                	sd	s3,24(sp)
    800023ca:	e852                	sd	s4,16(sp)
    800023cc:	e456                	sd	s5,8(sp)
    800023ce:	0080                	addi	s0,sp,64
    800023d0:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023d2:	00010497          	auipc	s1,0x10
    800023d6:	99648493          	addi	s1,s1,-1642 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023da:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023dc:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023de:	00015917          	auipc	s2,0x15
    800023e2:	58a90913          	addi	s2,s2,1418 # 80017968 <tickslock>
    800023e6:	a811                	j	800023fa <wakeup+0x3c>
    release(&p->lock);
    800023e8:	8526                	mv	a0,s1
    800023ea:	fffff097          	auipc	ra,0xfffff
    800023ee:	920080e7          	jalr	-1760(ra) # 80000d0a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023f2:	17048493          	addi	s1,s1,368
    800023f6:	03248063          	beq	s1,s2,80002416 <wakeup+0x58>
    acquire(&p->lock);
    800023fa:	8526                	mv	a0,s1
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	85a080e7          	jalr	-1958(ra) # 80000c56 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002404:	4c9c                	lw	a5,24(s1)
    80002406:	ff3791e3          	bne	a5,s3,800023e8 <wakeup+0x2a>
    8000240a:	749c                	ld	a5,40(s1)
    8000240c:	fd479ee3          	bne	a5,s4,800023e8 <wakeup+0x2a>
      p->state = RUNNABLE;
    80002410:	0154ac23          	sw	s5,24(s1)
    80002414:	bfd1                	j	800023e8 <wakeup+0x2a>
}
    80002416:	70e2                	ld	ra,56(sp)
    80002418:	7442                	ld	s0,48(sp)
    8000241a:	74a2                	ld	s1,40(sp)
    8000241c:	7902                	ld	s2,32(sp)
    8000241e:	69e2                	ld	s3,24(sp)
    80002420:	6a42                	ld	s4,16(sp)
    80002422:	6aa2                	ld	s5,8(sp)
    80002424:	6121                	addi	sp,sp,64
    80002426:	8082                	ret

0000000080002428 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002428:	7179                	addi	sp,sp,-48
    8000242a:	f406                	sd	ra,40(sp)
    8000242c:	f022                	sd	s0,32(sp)
    8000242e:	ec26                	sd	s1,24(sp)
    80002430:	e84a                	sd	s2,16(sp)
    80002432:	e44e                	sd	s3,8(sp)
    80002434:	1800                	addi	s0,sp,48
    80002436:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002438:	00010497          	auipc	s1,0x10
    8000243c:	93048493          	addi	s1,s1,-1744 # 80011d68 <proc>
    80002440:	00015997          	auipc	s3,0x15
    80002444:	52898993          	addi	s3,s3,1320 # 80017968 <tickslock>
    acquire(&p->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	80c080e7          	jalr	-2036(ra) # 80000c56 <acquire>
    if(p->pid == pid){
    80002452:	5c9c                	lw	a5,56(s1)
    80002454:	01278d63          	beq	a5,s2,8000246e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	8b0080e7          	jalr	-1872(ra) # 80000d0a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002462:	17048493          	addi	s1,s1,368
    80002466:	ff3491e3          	bne	s1,s3,80002448 <kill+0x20>
  }
  return -1;
    8000246a:	557d                	li	a0,-1
    8000246c:	a821                	j	80002484 <kill+0x5c>
      p->killed = 1;
    8000246e:	4785                	li	a5,1
    80002470:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002472:	4c98                	lw	a4,24(s1)
    80002474:	00f70f63          	beq	a4,a5,80002492 <kill+0x6a>
      release(&p->lock);
    80002478:	8526                	mv	a0,s1
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	890080e7          	jalr	-1904(ra) # 80000d0a <release>
      return 0;
    80002482:	4501                	li	a0,0
}
    80002484:	70a2                	ld	ra,40(sp)
    80002486:	7402                	ld	s0,32(sp)
    80002488:	64e2                	ld	s1,24(sp)
    8000248a:	6942                	ld	s2,16(sp)
    8000248c:	69a2                	ld	s3,8(sp)
    8000248e:	6145                	addi	sp,sp,48
    80002490:	8082                	ret
        p->state = RUNNABLE;
    80002492:	4789                	li	a5,2
    80002494:	cc9c                	sw	a5,24(s1)
    80002496:	b7cd                	j	80002478 <kill+0x50>

0000000080002498 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002498:	7179                	addi	sp,sp,-48
    8000249a:	f406                	sd	ra,40(sp)
    8000249c:	f022                	sd	s0,32(sp)
    8000249e:	ec26                	sd	s1,24(sp)
    800024a0:	e84a                	sd	s2,16(sp)
    800024a2:	e44e                	sd	s3,8(sp)
    800024a4:	e052                	sd	s4,0(sp)
    800024a6:	1800                	addi	s0,sp,48
    800024a8:	84aa                	mv	s1,a0
    800024aa:	892e                	mv	s2,a1
    800024ac:	89b2                	mv	s3,a2
    800024ae:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	572080e7          	jalr	1394(ra) # 80001a22 <myproc>
  if(user_dst){
    800024b8:	c08d                	beqz	s1,800024da <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024ba:	86d2                	mv	a3,s4
    800024bc:	864e                	mv	a2,s3
    800024be:	85ca                	mv	a1,s2
    800024c0:	6928                	ld	a0,80(a0)
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	252080e7          	jalr	594(ra) # 80001714 <copyout>
  } else {
    memmove((char *)dst, src, len);
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
    memmove((char *)dst, src, len);
    800024da:	000a061b          	sext.w	a2,s4
    800024de:	85ce                	mv	a1,s3
    800024e0:	854a                	mv	a0,s2
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	8cc080e7          	jalr	-1844(ra) # 80000dae <memmove>
    return 0;
    800024ea:	8526                	mv	a0,s1
    800024ec:	bff9                	j	800024ca <either_copyout+0x32>

00000000800024ee <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024ee:	7179                	addi	sp,sp,-48
    800024f0:	f406                	sd	ra,40(sp)
    800024f2:	f022                	sd	s0,32(sp)
    800024f4:	ec26                	sd	s1,24(sp)
    800024f6:	e84a                	sd	s2,16(sp)
    800024f8:	e44e                	sd	s3,8(sp)
    800024fa:	e052                	sd	s4,0(sp)
    800024fc:	1800                	addi	s0,sp,48
    800024fe:	892a                	mv	s2,a0
    80002500:	84ae                	mv	s1,a1
    80002502:	89b2                	mv	s3,a2
    80002504:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	51c080e7          	jalr	1308(ra) # 80001a22 <myproc>
  if(user_src){
    8000250e:	c08d                	beqz	s1,80002530 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002510:	86d2                	mv	a3,s4
    80002512:	864e                	mv	a2,s3
    80002514:	85ca                	mv	a1,s2
    80002516:	6928                	ld	a0,80(a0)
    80002518:	fffff097          	auipc	ra,0xfffff
    8000251c:	288080e7          	jalr	648(ra) # 800017a0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002520:	70a2                	ld	ra,40(sp)
    80002522:	7402                	ld	s0,32(sp)
    80002524:	64e2                	ld	s1,24(sp)
    80002526:	6942                	ld	s2,16(sp)
    80002528:	69a2                	ld	s3,8(sp)
    8000252a:	6a02                	ld	s4,0(sp)
    8000252c:	6145                	addi	sp,sp,48
    8000252e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002530:	000a061b          	sext.w	a2,s4
    80002534:	85ce                	mv	a1,s3
    80002536:	854a                	mv	a0,s2
    80002538:	fffff097          	auipc	ra,0xfffff
    8000253c:	876080e7          	jalr	-1930(ra) # 80000dae <memmove>
    return 0;
    80002540:	8526                	mv	a0,s1
    80002542:	bff9                	j	80002520 <either_copyin+0x32>

0000000080002544 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002544:	715d                	addi	sp,sp,-80
    80002546:	e486                	sd	ra,72(sp)
    80002548:	e0a2                	sd	s0,64(sp)
    8000254a:	fc26                	sd	s1,56(sp)
    8000254c:	f84a                	sd	s2,48(sp)
    8000254e:	f44e                	sd	s3,40(sp)
    80002550:	f052                	sd	s4,32(sp)
    80002552:	ec56                	sd	s5,24(sp)
    80002554:	e85a                	sd	s6,16(sp)
    80002556:	e45e                	sd	s7,8(sp)
    80002558:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000255a:	00006517          	auipc	a0,0x6
    8000255e:	b6e50513          	addi	a0,a0,-1170 # 800080c8 <digits+0x88>
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	038080e7          	jalr	56(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000256a:	00010497          	auipc	s1,0x10
    8000256e:	95648493          	addi	s1,s1,-1706 # 80011ec0 <proc+0x158>
    80002572:	00015917          	auipc	s2,0x15
    80002576:	54e90913          	addi	s2,s2,1358 # 80017ac0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000257a:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000257c:	00006997          	auipc	s3,0x6
    80002580:	cec98993          	addi	s3,s3,-788 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    80002584:	00006a97          	auipc	s5,0x6
    80002588:	ceca8a93          	addi	s5,s5,-788 # 80008270 <digits+0x230>
    printf("\n");
    8000258c:	00006a17          	auipc	s4,0x6
    80002590:	b3ca0a13          	addi	s4,s4,-1220 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002594:	00006b97          	auipc	s7,0x6
    80002598:	d14b8b93          	addi	s7,s7,-748 # 800082a8 <states.0>
    8000259c:	a00d                	j	800025be <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000259e:	ee06a583          	lw	a1,-288(a3)
    800025a2:	8556                	mv	a0,s5
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	ff6080e7          	jalr	-10(ra) # 8000059a <printf>
    printf("\n");
    800025ac:	8552                	mv	a0,s4
    800025ae:	ffffe097          	auipc	ra,0xffffe
    800025b2:	fec080e7          	jalr	-20(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025b6:	17048493          	addi	s1,s1,368
    800025ba:	03248163          	beq	s1,s2,800025dc <procdump+0x98>
    if(p->state == UNUSED)
    800025be:	86a6                	mv	a3,s1
    800025c0:	ec04a783          	lw	a5,-320(s1)
    800025c4:	dbed                	beqz	a5,800025b6 <procdump+0x72>
      state = "???";
    800025c6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025c8:	fcfb6be3          	bltu	s6,a5,8000259e <procdump+0x5a>
    800025cc:	1782                	slli	a5,a5,0x20
    800025ce:	9381                	srli	a5,a5,0x20
    800025d0:	078e                	slli	a5,a5,0x3
    800025d2:	97de                	add	a5,a5,s7
    800025d4:	6390                	ld	a2,0(a5)
    800025d6:	f661                	bnez	a2,8000259e <procdump+0x5a>
      state = "???";
    800025d8:	864e                	mv	a2,s3
    800025da:	b7d1                	j	8000259e <procdump+0x5a>
  }
}
    800025dc:	60a6                	ld	ra,72(sp)
    800025de:	6406                	ld	s0,64(sp)
    800025e0:	74e2                	ld	s1,56(sp)
    800025e2:	7942                	ld	s2,48(sp)
    800025e4:	79a2                	ld	s3,40(sp)
    800025e6:	7a02                	ld	s4,32(sp)
    800025e8:	6ae2                	ld	s5,24(sp)
    800025ea:	6b42                	ld	s6,16(sp)
    800025ec:	6ba2                	ld	s7,8(sp)
    800025ee:	6161                	addi	sp,sp,80
    800025f0:	8082                	ret

00000000800025f2 <count_process>:

uint64
count_process(void) { // added function for counting used process slots (lab2)
    800025f2:	1141                	addi	sp,sp,-16
    800025f4:	e422                	sd	s0,8(sp)
    800025f6:	0800                	addi	s0,sp,16
  uint64 cnt = 0;
  for(struct proc *p = proc; p < &proc[NPROC]; p++) {
    800025f8:	0000f797          	auipc	a5,0xf
    800025fc:	77078793          	addi	a5,a5,1904 # 80011d68 <proc>
  uint64 cnt = 0;
    80002600:	4501                	li	a0,0
  for(struct proc *p = proc; p < &proc[NPROC]; p++) {
    80002602:	00015697          	auipc	a3,0x15
    80002606:	36668693          	addi	a3,a3,870 # 80017968 <tickslock>
    // acquire(&p->lock);
    // no need to lock since all we do is reading, no writing will be done to the proc.
    if(p->state != UNUSED) {
    8000260a:	4f98                	lw	a4,24(a5)
      cnt++;
    8000260c:	00e03733          	snez	a4,a4
    80002610:	953a                	add	a0,a0,a4
  for(struct proc *p = proc; p < &proc[NPROC]; p++) {
    80002612:	17078793          	addi	a5,a5,368
    80002616:	fed79ae3          	bne	a5,a3,8000260a <count_process+0x18>
    }
  }
  return cnt;
    8000261a:	6422                	ld	s0,8(sp)
    8000261c:	0141                	addi	sp,sp,16
    8000261e:	8082                	ret

0000000080002620 <swtch>:
    80002620:	00153023          	sd	ra,0(a0)
    80002624:	00253423          	sd	sp,8(a0)
    80002628:	e900                	sd	s0,16(a0)
    8000262a:	ed04                	sd	s1,24(a0)
    8000262c:	03253023          	sd	s2,32(a0)
    80002630:	03353423          	sd	s3,40(a0)
    80002634:	03453823          	sd	s4,48(a0)
    80002638:	03553c23          	sd	s5,56(a0)
    8000263c:	05653023          	sd	s6,64(a0)
    80002640:	05753423          	sd	s7,72(a0)
    80002644:	05853823          	sd	s8,80(a0)
    80002648:	05953c23          	sd	s9,88(a0)
    8000264c:	07a53023          	sd	s10,96(a0)
    80002650:	07b53423          	sd	s11,104(a0)
    80002654:	0005b083          	ld	ra,0(a1)
    80002658:	0085b103          	ld	sp,8(a1)
    8000265c:	6980                	ld	s0,16(a1)
    8000265e:	6d84                	ld	s1,24(a1)
    80002660:	0205b903          	ld	s2,32(a1)
    80002664:	0285b983          	ld	s3,40(a1)
    80002668:	0305ba03          	ld	s4,48(a1)
    8000266c:	0385ba83          	ld	s5,56(a1)
    80002670:	0405bb03          	ld	s6,64(a1)
    80002674:	0485bb83          	ld	s7,72(a1)
    80002678:	0505bc03          	ld	s8,80(a1)
    8000267c:	0585bc83          	ld	s9,88(a1)
    80002680:	0605bd03          	ld	s10,96(a1)
    80002684:	0685bd83          	ld	s11,104(a1)
    80002688:	8082                	ret

000000008000268a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000268a:	1141                	addi	sp,sp,-16
    8000268c:	e406                	sd	ra,8(sp)
    8000268e:	e022                	sd	s0,0(sp)
    80002690:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002692:	00006597          	auipc	a1,0x6
    80002696:	c3e58593          	addi	a1,a1,-962 # 800082d0 <states.0+0x28>
    8000269a:	00015517          	auipc	a0,0x15
    8000269e:	2ce50513          	addi	a0,a0,718 # 80017968 <tickslock>
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	524080e7          	jalr	1316(ra) # 80000bc6 <initlock>
}
    800026aa:	60a2                	ld	ra,8(sp)
    800026ac:	6402                	ld	s0,0(sp)
    800026ae:	0141                	addi	sp,sp,16
    800026b0:	8082                	ret

00000000800026b2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026b2:	1141                	addi	sp,sp,-16
    800026b4:	e422                	sd	s0,8(sp)
    800026b6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026b8:	00003797          	auipc	a5,0x3
    800026bc:	58878793          	addi	a5,a5,1416 # 80005c40 <kernelvec>
    800026c0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026c4:	6422                	ld	s0,8(sp)
    800026c6:	0141                	addi	sp,sp,16
    800026c8:	8082                	ret

00000000800026ca <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026ca:	1141                	addi	sp,sp,-16
    800026cc:	e406                	sd	ra,8(sp)
    800026ce:	e022                	sd	s0,0(sp)
    800026d0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	350080e7          	jalr	848(ra) # 80001a22 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026da:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026de:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026e4:	00005617          	auipc	a2,0x5
    800026e8:	91c60613          	addi	a2,a2,-1764 # 80007000 <_trampoline>
    800026ec:	00005697          	auipc	a3,0x5
    800026f0:	91468693          	addi	a3,a3,-1772 # 80007000 <_trampoline>
    800026f4:	8e91                	sub	a3,a3,a2
    800026f6:	040007b7          	lui	a5,0x4000
    800026fa:	17fd                	addi	a5,a5,-1
    800026fc:	07b2                	slli	a5,a5,0xc
    800026fe:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002700:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002704:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002706:	180026f3          	csrr	a3,satp
    8000270a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000270c:	6d38                	ld	a4,88(a0)
    8000270e:	6134                	ld	a3,64(a0)
    80002710:	6585                	lui	a1,0x1
    80002712:	96ae                	add	a3,a3,a1
    80002714:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002716:	6d38                	ld	a4,88(a0)
    80002718:	00000697          	auipc	a3,0x0
    8000271c:	13868693          	addi	a3,a3,312 # 80002850 <usertrap>
    80002720:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002722:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002724:	8692                	mv	a3,tp
    80002726:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002728:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000272c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002730:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002734:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002738:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000273a:	6f18                	ld	a4,24(a4)
    8000273c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002740:	692c                	ld	a1,80(a0)
    80002742:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002744:	00005717          	auipc	a4,0x5
    80002748:	94c70713          	addi	a4,a4,-1716 # 80007090 <userret>
    8000274c:	8f11                	sub	a4,a4,a2
    8000274e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002750:	577d                	li	a4,-1
    80002752:	177e                	slli	a4,a4,0x3f
    80002754:	8dd9                	or	a1,a1,a4
    80002756:	02000537          	lui	a0,0x2000
    8000275a:	157d                	addi	a0,a0,-1
    8000275c:	0536                	slli	a0,a0,0xd
    8000275e:	9782                	jalr	a5
}
    80002760:	60a2                	ld	ra,8(sp)
    80002762:	6402                	ld	s0,0(sp)
    80002764:	0141                	addi	sp,sp,16
    80002766:	8082                	ret

0000000080002768 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002768:	1101                	addi	sp,sp,-32
    8000276a:	ec06                	sd	ra,24(sp)
    8000276c:	e822                	sd	s0,16(sp)
    8000276e:	e426                	sd	s1,8(sp)
    80002770:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002772:	00015497          	auipc	s1,0x15
    80002776:	1f648493          	addi	s1,s1,502 # 80017968 <tickslock>
    8000277a:	8526                	mv	a0,s1
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	4da080e7          	jalr	1242(ra) # 80000c56 <acquire>
  ticks++;
    80002784:	00007517          	auipc	a0,0x7
    80002788:	89c50513          	addi	a0,a0,-1892 # 80009020 <ticks>
    8000278c:	411c                	lw	a5,0(a0)
    8000278e:	2785                	addiw	a5,a5,1
    80002790:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002792:	00000097          	auipc	ra,0x0
    80002796:	c2c080e7          	jalr	-980(ra) # 800023be <wakeup>
  release(&tickslock);
    8000279a:	8526                	mv	a0,s1
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	56e080e7          	jalr	1390(ra) # 80000d0a <release>
}
    800027a4:	60e2                	ld	ra,24(sp)
    800027a6:	6442                	ld	s0,16(sp)
    800027a8:	64a2                	ld	s1,8(sp)
    800027aa:	6105                	addi	sp,sp,32
    800027ac:	8082                	ret

00000000800027ae <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027ae:	1101                	addi	sp,sp,-32
    800027b0:	ec06                	sd	ra,24(sp)
    800027b2:	e822                	sd	s0,16(sp)
    800027b4:	e426                	sd	s1,8(sp)
    800027b6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027b8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027bc:	00074d63          	bltz	a4,800027d6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027c0:	57fd                	li	a5,-1
    800027c2:	17fe                	slli	a5,a5,0x3f
    800027c4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027c6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027c8:	06f70363          	beq	a4,a5,8000282e <devintr+0x80>
  }
}
    800027cc:	60e2                	ld	ra,24(sp)
    800027ce:	6442                	ld	s0,16(sp)
    800027d0:	64a2                	ld	s1,8(sp)
    800027d2:	6105                	addi	sp,sp,32
    800027d4:	8082                	ret
     (scause & 0xff) == 9){
    800027d6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027da:	46a5                	li	a3,9
    800027dc:	fed792e3          	bne	a5,a3,800027c0 <devintr+0x12>
    int irq = plic_claim();
    800027e0:	00003097          	auipc	ra,0x3
    800027e4:	584080e7          	jalr	1412(ra) # 80005d64 <plic_claim>
    800027e8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027ea:	47a9                	li	a5,10
    800027ec:	02f50763          	beq	a0,a5,8000281a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027f0:	4785                	li	a5,1
    800027f2:	02f50963          	beq	a0,a5,80002824 <devintr+0x76>
    return 1;
    800027f6:	4505                	li	a0,1
    } else if(irq){
    800027f8:	d8f1                	beqz	s1,800027cc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027fa:	85a6                	mv	a1,s1
    800027fc:	00006517          	auipc	a0,0x6
    80002800:	adc50513          	addi	a0,a0,-1316 # 800082d8 <states.0+0x30>
    80002804:	ffffe097          	auipc	ra,0xffffe
    80002808:	d96080e7          	jalr	-618(ra) # 8000059a <printf>
      plic_complete(irq);
    8000280c:	8526                	mv	a0,s1
    8000280e:	00003097          	auipc	ra,0x3
    80002812:	57a080e7          	jalr	1402(ra) # 80005d88 <plic_complete>
    return 1;
    80002816:	4505                	li	a0,1
    80002818:	bf55                	j	800027cc <devintr+0x1e>
      uartintr();
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	1b6080e7          	jalr	438(ra) # 800009d0 <uartintr>
    80002822:	b7ed                	j	8000280c <devintr+0x5e>
      virtio_disk_intr();
    80002824:	00004097          	auipc	ra,0x4
    80002828:	9de080e7          	jalr	-1570(ra) # 80006202 <virtio_disk_intr>
    8000282c:	b7c5                	j	8000280c <devintr+0x5e>
    if(cpuid() == 0){
    8000282e:	fffff097          	auipc	ra,0xfffff
    80002832:	1c8080e7          	jalr	456(ra) # 800019f6 <cpuid>
    80002836:	c901                	beqz	a0,80002846 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002838:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000283c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000283e:	14479073          	csrw	sip,a5
    return 2;
    80002842:	4509                	li	a0,2
    80002844:	b761                	j	800027cc <devintr+0x1e>
      clockintr();
    80002846:	00000097          	auipc	ra,0x0
    8000284a:	f22080e7          	jalr	-222(ra) # 80002768 <clockintr>
    8000284e:	b7ed                	j	80002838 <devintr+0x8a>

0000000080002850 <usertrap>:
{
    80002850:	1101                	addi	sp,sp,-32
    80002852:	ec06                	sd	ra,24(sp)
    80002854:	e822                	sd	s0,16(sp)
    80002856:	e426                	sd	s1,8(sp)
    80002858:	e04a                	sd	s2,0(sp)
    8000285a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000285c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002860:	1007f793          	andi	a5,a5,256
    80002864:	e3ad                	bnez	a5,800028c6 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002866:	00003797          	auipc	a5,0x3
    8000286a:	3da78793          	addi	a5,a5,986 # 80005c40 <kernelvec>
    8000286e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002872:	fffff097          	auipc	ra,0xfffff
    80002876:	1b0080e7          	jalr	432(ra) # 80001a22 <myproc>
    8000287a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000287c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000287e:	14102773          	csrr	a4,sepc
    80002882:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002884:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002888:	47a1                	li	a5,8
    8000288a:	04f71c63          	bne	a4,a5,800028e2 <usertrap+0x92>
    if(p->killed)
    8000288e:	591c                	lw	a5,48(a0)
    80002890:	e3b9                	bnez	a5,800028d6 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002892:	6cb8                	ld	a4,88(s1)
    80002894:	6f1c                	ld	a5,24(a4)
    80002896:	0791                	addi	a5,a5,4
    80002898:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000289a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000289e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028a2:	10079073          	csrw	sstatus,a5
    syscall();
    800028a6:	00000097          	auipc	ra,0x0
    800028aa:	2e0080e7          	jalr	736(ra) # 80002b86 <syscall>
  if(p->killed)
    800028ae:	589c                	lw	a5,48(s1)
    800028b0:	ebc1                	bnez	a5,80002940 <usertrap+0xf0>
  usertrapret();
    800028b2:	00000097          	auipc	ra,0x0
    800028b6:	e18080e7          	jalr	-488(ra) # 800026ca <usertrapret>
}
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	6902                	ld	s2,0(sp)
    800028c2:	6105                	addi	sp,sp,32
    800028c4:	8082                	ret
    panic("usertrap: not from user mode");
    800028c6:	00006517          	auipc	a0,0x6
    800028ca:	a3250513          	addi	a0,a0,-1486 # 800082f8 <states.0+0x50>
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	c82080e7          	jalr	-894(ra) # 80000550 <panic>
      exit(-1);
    800028d6:	557d                	li	a0,-1
    800028d8:	00000097          	auipc	ra,0x0
    800028dc:	820080e7          	jalr	-2016(ra) # 800020f8 <exit>
    800028e0:	bf4d                	j	80002892 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	ecc080e7          	jalr	-308(ra) # 800027ae <devintr>
    800028ea:	892a                	mv	s2,a0
    800028ec:	c501                	beqz	a0,800028f4 <usertrap+0xa4>
  if(p->killed)
    800028ee:	589c                	lw	a5,48(s1)
    800028f0:	c3a1                	beqz	a5,80002930 <usertrap+0xe0>
    800028f2:	a815                	j	80002926 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028f8:	5c90                	lw	a2,56(s1)
    800028fa:	00006517          	auipc	a0,0x6
    800028fe:	a1e50513          	addi	a0,a0,-1506 # 80008318 <states.0+0x70>
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	c98080e7          	jalr	-872(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000290a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000290e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002912:	00006517          	auipc	a0,0x6
    80002916:	a3650513          	addi	a0,a0,-1482 # 80008348 <states.0+0xa0>
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	c80080e7          	jalr	-896(ra) # 8000059a <printf>
    p->killed = 1;
    80002922:	4785                	li	a5,1
    80002924:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002926:	557d                	li	a0,-1
    80002928:	fffff097          	auipc	ra,0xfffff
    8000292c:	7d0080e7          	jalr	2000(ra) # 800020f8 <exit>
  if(which_dev == 2)
    80002930:	4789                	li	a5,2
    80002932:	f8f910e3          	bne	s2,a5,800028b2 <usertrap+0x62>
    yield();
    80002936:	00000097          	auipc	ra,0x0
    8000293a:	8cc080e7          	jalr	-1844(ra) # 80002202 <yield>
    8000293e:	bf95                	j	800028b2 <usertrap+0x62>
  int which_dev = 0;
    80002940:	4901                	li	s2,0
    80002942:	b7d5                	j	80002926 <usertrap+0xd6>

0000000080002944 <kerneltrap>:
{
    80002944:	7179                	addi	sp,sp,-48
    80002946:	f406                	sd	ra,40(sp)
    80002948:	f022                	sd	s0,32(sp)
    8000294a:	ec26                	sd	s1,24(sp)
    8000294c:	e84a                	sd	s2,16(sp)
    8000294e:	e44e                	sd	s3,8(sp)
    80002950:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002952:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002956:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000295a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000295e:	1004f793          	andi	a5,s1,256
    80002962:	cb85                	beqz	a5,80002992 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002964:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002968:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000296a:	ef85                	bnez	a5,800029a2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000296c:	00000097          	auipc	ra,0x0
    80002970:	e42080e7          	jalr	-446(ra) # 800027ae <devintr>
    80002974:	cd1d                	beqz	a0,800029b2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002976:	4789                	li	a5,2
    80002978:	06f50a63          	beq	a0,a5,800029ec <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000297c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002980:	10049073          	csrw	sstatus,s1
}
    80002984:	70a2                	ld	ra,40(sp)
    80002986:	7402                	ld	s0,32(sp)
    80002988:	64e2                	ld	s1,24(sp)
    8000298a:	6942                	ld	s2,16(sp)
    8000298c:	69a2                	ld	s3,8(sp)
    8000298e:	6145                	addi	sp,sp,48
    80002990:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002992:	00006517          	auipc	a0,0x6
    80002996:	9d650513          	addi	a0,a0,-1578 # 80008368 <states.0+0xc0>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	bb6080e7          	jalr	-1098(ra) # 80000550 <panic>
    panic("kerneltrap: interrupts enabled");
    800029a2:	00006517          	auipc	a0,0x6
    800029a6:	9ee50513          	addi	a0,a0,-1554 # 80008390 <states.0+0xe8>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	ba6080e7          	jalr	-1114(ra) # 80000550 <panic>
    printf("scause %p\n", scause);
    800029b2:	85ce                	mv	a1,s3
    800029b4:	00006517          	auipc	a0,0x6
    800029b8:	9fc50513          	addi	a0,a0,-1540 # 800083b0 <states.0+0x108>
    800029bc:	ffffe097          	auipc	ra,0xffffe
    800029c0:	bde080e7          	jalr	-1058(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029c4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029c8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029cc:	00006517          	auipc	a0,0x6
    800029d0:	9f450513          	addi	a0,a0,-1548 # 800083c0 <states.0+0x118>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	bc6080e7          	jalr	-1082(ra) # 8000059a <printf>
    panic("kerneltrap");
    800029dc:	00006517          	auipc	a0,0x6
    800029e0:	9fc50513          	addi	a0,a0,-1540 # 800083d8 <states.0+0x130>
    800029e4:	ffffe097          	auipc	ra,0xffffe
    800029e8:	b6c080e7          	jalr	-1172(ra) # 80000550 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029ec:	fffff097          	auipc	ra,0xfffff
    800029f0:	036080e7          	jalr	54(ra) # 80001a22 <myproc>
    800029f4:	d541                	beqz	a0,8000297c <kerneltrap+0x38>
    800029f6:	fffff097          	auipc	ra,0xfffff
    800029fa:	02c080e7          	jalr	44(ra) # 80001a22 <myproc>
    800029fe:	4d18                	lw	a4,24(a0)
    80002a00:	478d                	li	a5,3
    80002a02:	f6f71de3          	bne	a4,a5,8000297c <kerneltrap+0x38>
    yield();
    80002a06:	fffff097          	auipc	ra,0xfffff
    80002a0a:	7fc080e7          	jalr	2044(ra) # 80002202 <yield>
    80002a0e:	b7bd                	j	8000297c <kerneltrap+0x38>

0000000080002a10 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a10:	1101                	addi	sp,sp,-32
    80002a12:	ec06                	sd	ra,24(sp)
    80002a14:	e822                	sd	s0,16(sp)
    80002a16:	e426                	sd	s1,8(sp)
    80002a18:	1000                	addi	s0,sp,32
    80002a1a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a1c:	fffff097          	auipc	ra,0xfffff
    80002a20:	006080e7          	jalr	6(ra) # 80001a22 <myproc>
  switch (n) {
    80002a24:	4795                	li	a5,5
    80002a26:	0497e163          	bltu	a5,s1,80002a68 <argraw+0x58>
    80002a2a:	048a                	slli	s1,s1,0x2
    80002a2c:	00006717          	auipc	a4,0x6
    80002a30:	aac70713          	addi	a4,a4,-1364 # 800084d8 <states.0+0x230>
    80002a34:	94ba                	add	s1,s1,a4
    80002a36:	409c                	lw	a5,0(s1)
    80002a38:	97ba                	add	a5,a5,a4
    80002a3a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a3c:	6d3c                	ld	a5,88(a0)
    80002a3e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a40:	60e2                	ld	ra,24(sp)
    80002a42:	6442                	ld	s0,16(sp)
    80002a44:	64a2                	ld	s1,8(sp)
    80002a46:	6105                	addi	sp,sp,32
    80002a48:	8082                	ret
    return p->trapframe->a1;
    80002a4a:	6d3c                	ld	a5,88(a0)
    80002a4c:	7fa8                	ld	a0,120(a5)
    80002a4e:	bfcd                	j	80002a40 <argraw+0x30>
    return p->trapframe->a2;
    80002a50:	6d3c                	ld	a5,88(a0)
    80002a52:	63c8                	ld	a0,128(a5)
    80002a54:	b7f5                	j	80002a40 <argraw+0x30>
    return p->trapframe->a3;
    80002a56:	6d3c                	ld	a5,88(a0)
    80002a58:	67c8                	ld	a0,136(a5)
    80002a5a:	b7dd                	j	80002a40 <argraw+0x30>
    return p->trapframe->a4;
    80002a5c:	6d3c                	ld	a5,88(a0)
    80002a5e:	6bc8                	ld	a0,144(a5)
    80002a60:	b7c5                	j	80002a40 <argraw+0x30>
    return p->trapframe->a5;
    80002a62:	6d3c                	ld	a5,88(a0)
    80002a64:	6fc8                	ld	a0,152(a5)
    80002a66:	bfe9                	j	80002a40 <argraw+0x30>
  panic("argraw");
    80002a68:	00006517          	auipc	a0,0x6
    80002a6c:	98050513          	addi	a0,a0,-1664 # 800083e8 <states.0+0x140>
    80002a70:	ffffe097          	auipc	ra,0xffffe
    80002a74:	ae0080e7          	jalr	-1312(ra) # 80000550 <panic>

0000000080002a78 <fetchaddr>:
{
    80002a78:	1101                	addi	sp,sp,-32
    80002a7a:	ec06                	sd	ra,24(sp)
    80002a7c:	e822                	sd	s0,16(sp)
    80002a7e:	e426                	sd	s1,8(sp)
    80002a80:	e04a                	sd	s2,0(sp)
    80002a82:	1000                	addi	s0,sp,32
    80002a84:	84aa                	mv	s1,a0
    80002a86:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a88:	fffff097          	auipc	ra,0xfffff
    80002a8c:	f9a080e7          	jalr	-102(ra) # 80001a22 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a90:	653c                	ld	a5,72(a0)
    80002a92:	02f4f863          	bgeu	s1,a5,80002ac2 <fetchaddr+0x4a>
    80002a96:	00848713          	addi	a4,s1,8
    80002a9a:	02e7e663          	bltu	a5,a4,80002ac6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a9e:	46a1                	li	a3,8
    80002aa0:	8626                	mv	a2,s1
    80002aa2:	85ca                	mv	a1,s2
    80002aa4:	6928                	ld	a0,80(a0)
    80002aa6:	fffff097          	auipc	ra,0xfffff
    80002aaa:	cfa080e7          	jalr	-774(ra) # 800017a0 <copyin>
    80002aae:	00a03533          	snez	a0,a0
    80002ab2:	40a00533          	neg	a0,a0
}
    80002ab6:	60e2                	ld	ra,24(sp)
    80002ab8:	6442                	ld	s0,16(sp)
    80002aba:	64a2                	ld	s1,8(sp)
    80002abc:	6902                	ld	s2,0(sp)
    80002abe:	6105                	addi	sp,sp,32
    80002ac0:	8082                	ret
    return -1;
    80002ac2:	557d                	li	a0,-1
    80002ac4:	bfcd                	j	80002ab6 <fetchaddr+0x3e>
    80002ac6:	557d                	li	a0,-1
    80002ac8:	b7fd                	j	80002ab6 <fetchaddr+0x3e>

0000000080002aca <fetchstr>:
{
    80002aca:	7179                	addi	sp,sp,-48
    80002acc:	f406                	sd	ra,40(sp)
    80002ace:	f022                	sd	s0,32(sp)
    80002ad0:	ec26                	sd	s1,24(sp)
    80002ad2:	e84a                	sd	s2,16(sp)
    80002ad4:	e44e                	sd	s3,8(sp)
    80002ad6:	1800                	addi	s0,sp,48
    80002ad8:	892a                	mv	s2,a0
    80002ada:	84ae                	mv	s1,a1
    80002adc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ade:	fffff097          	auipc	ra,0xfffff
    80002ae2:	f44080e7          	jalr	-188(ra) # 80001a22 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ae6:	86ce                	mv	a3,s3
    80002ae8:	864a                	mv	a2,s2
    80002aea:	85a6                	mv	a1,s1
    80002aec:	6928                	ld	a0,80(a0)
    80002aee:	fffff097          	auipc	ra,0xfffff
    80002af2:	d40080e7          	jalr	-704(ra) # 8000182e <copyinstr>
  if(err < 0)
    80002af6:	00054763          	bltz	a0,80002b04 <fetchstr+0x3a>
  return strlen(buf);
    80002afa:	8526                	mv	a0,s1
    80002afc:	ffffe097          	auipc	ra,0xffffe
    80002b00:	3da080e7          	jalr	986(ra) # 80000ed6 <strlen>
}
    80002b04:	70a2                	ld	ra,40(sp)
    80002b06:	7402                	ld	s0,32(sp)
    80002b08:	64e2                	ld	s1,24(sp)
    80002b0a:	6942                	ld	s2,16(sp)
    80002b0c:	69a2                	ld	s3,8(sp)
    80002b0e:	6145                	addi	sp,sp,48
    80002b10:	8082                	ret

0000000080002b12 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b12:	1101                	addi	sp,sp,-32
    80002b14:	ec06                	sd	ra,24(sp)
    80002b16:	e822                	sd	s0,16(sp)
    80002b18:	e426                	sd	s1,8(sp)
    80002b1a:	1000                	addi	s0,sp,32
    80002b1c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b1e:	00000097          	auipc	ra,0x0
    80002b22:	ef2080e7          	jalr	-270(ra) # 80002a10 <argraw>
    80002b26:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b28:	4501                	li	a0,0
    80002b2a:	60e2                	ld	ra,24(sp)
    80002b2c:	6442                	ld	s0,16(sp)
    80002b2e:	64a2                	ld	s1,8(sp)
    80002b30:	6105                	addi	sp,sp,32
    80002b32:	8082                	ret

0000000080002b34 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b34:	1101                	addi	sp,sp,-32
    80002b36:	ec06                	sd	ra,24(sp)
    80002b38:	e822                	sd	s0,16(sp)
    80002b3a:	e426                	sd	s1,8(sp)
    80002b3c:	1000                	addi	s0,sp,32
    80002b3e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b40:	00000097          	auipc	ra,0x0
    80002b44:	ed0080e7          	jalr	-304(ra) # 80002a10 <argraw>
    80002b48:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b4a:	4501                	li	a0,0
    80002b4c:	60e2                	ld	ra,24(sp)
    80002b4e:	6442                	ld	s0,16(sp)
    80002b50:	64a2                	ld	s1,8(sp)
    80002b52:	6105                	addi	sp,sp,32
    80002b54:	8082                	ret

0000000080002b56 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b56:	1101                	addi	sp,sp,-32
    80002b58:	ec06                	sd	ra,24(sp)
    80002b5a:	e822                	sd	s0,16(sp)
    80002b5c:	e426                	sd	s1,8(sp)
    80002b5e:	e04a                	sd	s2,0(sp)
    80002b60:	1000                	addi	s0,sp,32
    80002b62:	84ae                	mv	s1,a1
    80002b64:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b66:	00000097          	auipc	ra,0x0
    80002b6a:	eaa080e7          	jalr	-342(ra) # 80002a10 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b6e:	864a                	mv	a2,s2
    80002b70:	85a6                	mv	a1,s1
    80002b72:	00000097          	auipc	ra,0x0
    80002b76:	f58080e7          	jalr	-168(ra) # 80002aca <fetchstr>
}
    80002b7a:	60e2                	ld	ra,24(sp)
    80002b7c:	6442                	ld	s0,16(sp)
    80002b7e:	64a2                	ld	s1,8(sp)
    80002b80:	6902                	ld	s2,0(sp)
    80002b82:	6105                	addi	sp,sp,32
    80002b84:	8082                	ret

0000000080002b86 <syscall>:
[SYS_sysinfo]   "sysinfo",
};

void
syscall(void)
{
    80002b86:	7179                	addi	sp,sp,-48
    80002b88:	f406                	sd	ra,40(sp)
    80002b8a:	f022                	sd	s0,32(sp)
    80002b8c:	ec26                	sd	s1,24(sp)
    80002b8e:	e84a                	sd	s2,16(sp)
    80002b90:	e44e                	sd	s3,8(sp)
    80002b92:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002b94:	fffff097          	auipc	ra,0xfffff
    80002b98:	e8e080e7          	jalr	-370(ra) # 80001a22 <myproc>
    80002b9c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b9e:	05853903          	ld	s2,88(a0)
    80002ba2:	0a893783          	ld	a5,168(s2)
    80002ba6:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002baa:	37fd                	addiw	a5,a5,-1
    80002bac:	4759                	li	a4,22
    80002bae:	04f76863          	bltu	a4,a5,80002bfe <syscall+0x78>
    80002bb2:	00399713          	slli	a4,s3,0x3
    80002bb6:	00006797          	auipc	a5,0x6
    80002bba:	93a78793          	addi	a5,a5,-1734 # 800084f0 <syscalls>
    80002bbe:	97ba                	add	a5,a5,a4
    80002bc0:	639c                	ld	a5,0(a5)
    80002bc2:	cf95                	beqz	a5,80002bfe <syscall+0x78>
    p->trapframe->a0 = syscalls[num]();
    80002bc4:	9782                	jalr	a5
    80002bc6:	06a93823          	sd	a0,112(s2)
    if((p->syscall_trace >> num) & 1) {
    80002bca:	1684b783          	ld	a5,360(s1)
    80002bce:	0137d7b3          	srl	a5,a5,s3
    80002bd2:	8b85                	andi	a5,a5,1
    80002bd4:	c7a1                	beqz	a5,80002c1c <syscall+0x96>
      printf("%d: syscall %s -> %d\n",p->pid, syscall_names[num], p->trapframe->a0);
    80002bd6:	6cb8                	ld	a4,88(s1)
    80002bd8:	098e                	slli	s3,s3,0x3
    80002bda:	00006797          	auipc	a5,0x6
    80002bde:	d4e78793          	addi	a5,a5,-690 # 80008928 <syscall_names>
    80002be2:	99be                	add	s3,s3,a5
    80002be4:	7b34                	ld	a3,112(a4)
    80002be6:	0009b603          	ld	a2,0(s3)
    80002bea:	5c8c                	lw	a1,56(s1)
    80002bec:	00006517          	auipc	a0,0x6
    80002bf0:	80450513          	addi	a0,a0,-2044 # 800083f0 <states.0+0x148>
    80002bf4:	ffffe097          	auipc	ra,0xffffe
    80002bf8:	9a6080e7          	jalr	-1626(ra) # 8000059a <printf>
    80002bfc:	a005                	j	80002c1c <syscall+0x96>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bfe:	86ce                	mv	a3,s3
    80002c00:	15848613          	addi	a2,s1,344
    80002c04:	5c8c                	lw	a1,56(s1)
    80002c06:	00006517          	auipc	a0,0x6
    80002c0a:	80250513          	addi	a0,a0,-2046 # 80008408 <states.0+0x160>
    80002c0e:	ffffe097          	auipc	ra,0xffffe
    80002c12:	98c080e7          	jalr	-1652(ra) # 8000059a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c16:	6cbc                	ld	a5,88(s1)
    80002c18:	577d                	li	a4,-1
    80002c1a:	fbb8                	sd	a4,112(a5)
  }
}
    80002c1c:	70a2                	ld	ra,40(sp)
    80002c1e:	7402                	ld	s0,32(sp)
    80002c20:	64e2                	ld	s1,24(sp)
    80002c22:	6942                	ld	s2,16(sp)
    80002c24:	69a2                	ld	s3,8(sp)
    80002c26:	6145                	addi	sp,sp,48
    80002c28:	8082                	ret

0000000080002c2a <sys_exit>:
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
    80002c2a:	1101                	addi	sp,sp,-32
    80002c2c:	ec06                	sd	ra,24(sp)
    80002c2e:	e822                	sd	s0,16(sp)
    80002c30:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c32:	fec40593          	addi	a1,s0,-20
    80002c36:	4501                	li	a0,0
    80002c38:	00000097          	auipc	ra,0x0
    80002c3c:	eda080e7          	jalr	-294(ra) # 80002b12 <argint>
    return -1;
    80002c40:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c42:	00054963          	bltz	a0,80002c54 <sys_exit+0x2a>
  exit(n);
    80002c46:	fec42503          	lw	a0,-20(s0)
    80002c4a:	fffff097          	auipc	ra,0xfffff
    80002c4e:	4ae080e7          	jalr	1198(ra) # 800020f8 <exit>
  return 0;  // not reached
    80002c52:	4781                	li	a5,0
}
    80002c54:	853e                	mv	a0,a5
    80002c56:	60e2                	ld	ra,24(sp)
    80002c58:	6442                	ld	s0,16(sp)
    80002c5a:	6105                	addi	sp,sp,32
    80002c5c:	8082                	ret

0000000080002c5e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c5e:	1141                	addi	sp,sp,-16
    80002c60:	e406                	sd	ra,8(sp)
    80002c62:	e022                	sd	s0,0(sp)
    80002c64:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c66:	fffff097          	auipc	ra,0xfffff
    80002c6a:	dbc080e7          	jalr	-580(ra) # 80001a22 <myproc>
}
    80002c6e:	5d08                	lw	a0,56(a0)
    80002c70:	60a2                	ld	ra,8(sp)
    80002c72:	6402                	ld	s0,0(sp)
    80002c74:	0141                	addi	sp,sp,16
    80002c76:	8082                	ret

0000000080002c78 <sys_fork>:

uint64
sys_fork(void)
{
    80002c78:	1141                	addi	sp,sp,-16
    80002c7a:	e406                	sd	ra,8(sp)
    80002c7c:	e022                	sd	s0,0(sp)
    80002c7e:	0800                	addi	s0,sp,16
  return fork();
    80002c80:	fffff097          	auipc	ra,0xfffff
    80002c84:	166080e7          	jalr	358(ra) # 80001de6 <fork>
}
    80002c88:	60a2                	ld	ra,8(sp)
    80002c8a:	6402                	ld	s0,0(sp)
    80002c8c:	0141                	addi	sp,sp,16
    80002c8e:	8082                	ret

0000000080002c90 <sys_wait>:

uint64
sys_wait(void)
{
    80002c90:	1101                	addi	sp,sp,-32
    80002c92:	ec06                	sd	ra,24(sp)
    80002c94:	e822                	sd	s0,16(sp)
    80002c96:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c98:	fe840593          	addi	a1,s0,-24
    80002c9c:	4501                	li	a0,0
    80002c9e:	00000097          	auipc	ra,0x0
    80002ca2:	e96080e7          	jalr	-362(ra) # 80002b34 <argaddr>
    80002ca6:	87aa                	mv	a5,a0
    return -1;
    80002ca8:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002caa:	0007c863          	bltz	a5,80002cba <sys_wait+0x2a>
  return wait(p);
    80002cae:	fe843503          	ld	a0,-24(s0)
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	60a080e7          	jalr	1546(ra) # 800022bc <wait>
}
    80002cba:	60e2                	ld	ra,24(sp)
    80002cbc:	6442                	ld	s0,16(sp)
    80002cbe:	6105                	addi	sp,sp,32
    80002cc0:	8082                	ret

0000000080002cc2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cc2:	7179                	addi	sp,sp,-48
    80002cc4:	f406                	sd	ra,40(sp)
    80002cc6:	f022                	sd	s0,32(sp)
    80002cc8:	ec26                	sd	s1,24(sp)
    80002cca:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002ccc:	fdc40593          	addi	a1,s0,-36
    80002cd0:	4501                	li	a0,0
    80002cd2:	00000097          	auipc	ra,0x0
    80002cd6:	e40080e7          	jalr	-448(ra) # 80002b12 <argint>
    return -1;
    80002cda:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002cdc:	00054f63          	bltz	a0,80002cfa <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002ce0:	fffff097          	auipc	ra,0xfffff
    80002ce4:	d42080e7          	jalr	-702(ra) # 80001a22 <myproc>
    80002ce8:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002cea:	fdc42503          	lw	a0,-36(s0)
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	084080e7          	jalr	132(ra) # 80001d72 <growproc>
    80002cf6:	00054863          	bltz	a0,80002d06 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002cfa:	8526                	mv	a0,s1
    80002cfc:	70a2                	ld	ra,40(sp)
    80002cfe:	7402                	ld	s0,32(sp)
    80002d00:	64e2                	ld	s1,24(sp)
    80002d02:	6145                	addi	sp,sp,48
    80002d04:	8082                	ret
    return -1;
    80002d06:	54fd                	li	s1,-1
    80002d08:	bfcd                	j	80002cfa <sys_sbrk+0x38>

0000000080002d0a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d0a:	7139                	addi	sp,sp,-64
    80002d0c:	fc06                	sd	ra,56(sp)
    80002d0e:	f822                	sd	s0,48(sp)
    80002d10:	f426                	sd	s1,40(sp)
    80002d12:	f04a                	sd	s2,32(sp)
    80002d14:	ec4e                	sd	s3,24(sp)
    80002d16:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d18:	fcc40593          	addi	a1,s0,-52
    80002d1c:	4501                	li	a0,0
    80002d1e:	00000097          	auipc	ra,0x0
    80002d22:	df4080e7          	jalr	-524(ra) # 80002b12 <argint>
    return -1;
    80002d26:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d28:	06054563          	bltz	a0,80002d92 <sys_sleep+0x88>
  acquire(&tickslock);
    80002d2c:	00015517          	auipc	a0,0x15
    80002d30:	c3c50513          	addi	a0,a0,-964 # 80017968 <tickslock>
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	f22080e7          	jalr	-222(ra) # 80000c56 <acquire>
  ticks0 = ticks;
    80002d3c:	00006917          	auipc	s2,0x6
    80002d40:	2e492903          	lw	s2,740(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002d44:	fcc42783          	lw	a5,-52(s0)
    80002d48:	cf85                	beqz	a5,80002d80 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d4a:	00015997          	auipc	s3,0x15
    80002d4e:	c1e98993          	addi	s3,s3,-994 # 80017968 <tickslock>
    80002d52:	00006497          	auipc	s1,0x6
    80002d56:	2ce48493          	addi	s1,s1,718 # 80009020 <ticks>
    if(myproc()->killed){
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	cc8080e7          	jalr	-824(ra) # 80001a22 <myproc>
    80002d62:	591c                	lw	a5,48(a0)
    80002d64:	ef9d                	bnez	a5,80002da2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d66:	85ce                	mv	a1,s3
    80002d68:	8526                	mv	a0,s1
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	4d4080e7          	jalr	1236(ra) # 8000223e <sleep>
  while(ticks - ticks0 < n){
    80002d72:	409c                	lw	a5,0(s1)
    80002d74:	412787bb          	subw	a5,a5,s2
    80002d78:	fcc42703          	lw	a4,-52(s0)
    80002d7c:	fce7efe3          	bltu	a5,a4,80002d5a <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d80:	00015517          	auipc	a0,0x15
    80002d84:	be850513          	addi	a0,a0,-1048 # 80017968 <tickslock>
    80002d88:	ffffe097          	auipc	ra,0xffffe
    80002d8c:	f82080e7          	jalr	-126(ra) # 80000d0a <release>
  return 0;
    80002d90:	4781                	li	a5,0
}
    80002d92:	853e                	mv	a0,a5
    80002d94:	70e2                	ld	ra,56(sp)
    80002d96:	7442                	ld	s0,48(sp)
    80002d98:	74a2                	ld	s1,40(sp)
    80002d9a:	7902                	ld	s2,32(sp)
    80002d9c:	69e2                	ld	s3,24(sp)
    80002d9e:	6121                	addi	sp,sp,64
    80002da0:	8082                	ret
      release(&tickslock);
    80002da2:	00015517          	auipc	a0,0x15
    80002da6:	bc650513          	addi	a0,a0,-1082 # 80017968 <tickslock>
    80002daa:	ffffe097          	auipc	ra,0xffffe
    80002dae:	f60080e7          	jalr	-160(ra) # 80000d0a <release>
      return -1;
    80002db2:	57fd                	li	a5,-1
    80002db4:	bff9                	j	80002d92 <sys_sleep+0x88>

0000000080002db6 <sys_kill>:

uint64
sys_kill(void)
{
    80002db6:	1101                	addi	sp,sp,-32
    80002db8:	ec06                	sd	ra,24(sp)
    80002dba:	e822                	sd	s0,16(sp)
    80002dbc:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002dbe:	fec40593          	addi	a1,s0,-20
    80002dc2:	4501                	li	a0,0
    80002dc4:	00000097          	auipc	ra,0x0
    80002dc8:	d4e080e7          	jalr	-690(ra) # 80002b12 <argint>
    80002dcc:	87aa                	mv	a5,a0
    return -1;
    80002dce:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002dd0:	0007c863          	bltz	a5,80002de0 <sys_kill+0x2a>
  return kill(pid);
    80002dd4:	fec42503          	lw	a0,-20(s0)
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	650080e7          	jalr	1616(ra) # 80002428 <kill>
}
    80002de0:	60e2                	ld	ra,24(sp)
    80002de2:	6442                	ld	s0,16(sp)
    80002de4:	6105                	addi	sp,sp,32
    80002de6:	8082                	ret

0000000080002de8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002de8:	1101                	addi	sp,sp,-32
    80002dea:	ec06                	sd	ra,24(sp)
    80002dec:	e822                	sd	s0,16(sp)
    80002dee:	e426                	sd	s1,8(sp)
    80002df0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002df2:	00015517          	auipc	a0,0x15
    80002df6:	b7650513          	addi	a0,a0,-1162 # 80017968 <tickslock>
    80002dfa:	ffffe097          	auipc	ra,0xffffe
    80002dfe:	e5c080e7          	jalr	-420(ra) # 80000c56 <acquire>
  xticks = ticks;
    80002e02:	00006497          	auipc	s1,0x6
    80002e06:	21e4a483          	lw	s1,542(s1) # 80009020 <ticks>
  release(&tickslock);
    80002e0a:	00015517          	auipc	a0,0x15
    80002e0e:	b5e50513          	addi	a0,a0,-1186 # 80017968 <tickslock>
    80002e12:	ffffe097          	auipc	ra,0xffffe
    80002e16:	ef8080e7          	jalr	-264(ra) # 80000d0a <release>
  return xticks;
}
    80002e1a:	02049513          	slli	a0,s1,0x20
    80002e1e:	9101                	srli	a0,a0,0x20
    80002e20:	60e2                	ld	ra,24(sp)
    80002e22:	6442                	ld	s0,16(sp)
    80002e24:	64a2                	ld	s1,8(sp)
    80002e26:	6105                	addi	sp,sp,32
    80002e28:	8082                	ret

0000000080002e2a <sys_trace>:

uint64
sys_trace(void)
{
    80002e2a:	7179                	addi	sp,sp,-48
    80002e2c:	f406                	sd	ra,40(sp)
    80002e2e:	f022                	sd	s0,32(sp)
    80002e30:	ec26                	sd	s1,24(sp)
    80002e32:	1800                	addi	s0,sp,48
  int mask;

  if(argint(0, &mask) < 0)
    80002e34:	fdc40593          	addi	a1,s0,-36
    80002e38:	4501                	li	a0,0
    80002e3a:	00000097          	auipc	ra,0x0
    80002e3e:	cd8080e7          	jalr	-808(ra) # 80002b12 <argint>
    return -1;
    80002e42:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0)
    80002e44:	00054b63          	bltz	a0,80002e5a <sys_trace+0x30>
  
  myproc()->syscall_trace = mask;
    80002e48:	fdc42483          	lw	s1,-36(s0)
    80002e4c:	fffff097          	auipc	ra,0xfffff
    80002e50:	bd6080e7          	jalr	-1066(ra) # 80001a22 <myproc>
    80002e54:	16953423          	sd	s1,360(a0)
  return 0;
    80002e58:	4781                	li	a5,0
}
    80002e5a:	853e                	mv	a0,a5
    80002e5c:	70a2                	ld	ra,40(sp)
    80002e5e:	7402                	ld	s0,32(sp)
    80002e60:	64e2                	ld	s1,24(sp)
    80002e62:	6145                	addi	sp,sp,48
    80002e64:	8082                	ret

0000000080002e66 <sys_sysinfo>:

uint64
sys_sysinfo(void)
{
    80002e66:	7179                	addi	sp,sp,-48
    80002e68:	f406                	sd	ra,40(sp)
    80002e6a:	f022                	sd	s0,32(sp)
    80002e6c:	1800                	addi	s0,sp,48
  uint64 addr;

  if(argaddr(0, &addr) < 0)
    80002e6e:	fe840593          	addi	a1,s0,-24
    80002e72:	4501                	li	a0,0
    80002e74:	00000097          	auipc	ra,0x0
    80002e78:	cc0080e7          	jalr	-832(ra) # 80002b34 <argaddr>
    80002e7c:	87aa                	mv	a5,a0
    return -1;
    80002e7e:	557d                	li	a0,-1
  if(argaddr(0, &addr) < 0)
    80002e80:	0207cd63          	bltz	a5,80002eba <sys_sysinfo+0x54>
  
  struct sysinfo sinfo;
  sinfo.freemem = count_free_mem(); // kalloc.c
    80002e84:	ffffe097          	auipc	ra,0xffffe
    80002e88:	cf8080e7          	jalr	-776(ra) # 80000b7c <count_free_mem>
    80002e8c:	fca43c23          	sd	a0,-40(s0)
  sinfo.nproc = count_process(); // proc.c
    80002e90:	fffff097          	auipc	ra,0xfffff
    80002e94:	762080e7          	jalr	1890(ra) # 800025f2 <count_process>
    80002e98:	fea43023          	sd	a0,-32(s0)
  
  // copy sysinfo to user space
  if(copyout(myproc()->pagetable, addr, (char *)&sinfo, sizeof(sinfo)) < 0)
    80002e9c:	fffff097          	auipc	ra,0xfffff
    80002ea0:	b86080e7          	jalr	-1146(ra) # 80001a22 <myproc>
    80002ea4:	46c1                	li	a3,16
    80002ea6:	fd840613          	addi	a2,s0,-40
    80002eaa:	fe843583          	ld	a1,-24(s0)
    80002eae:	6928                	ld	a0,80(a0)
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	864080e7          	jalr	-1948(ra) # 80001714 <copyout>
    80002eb8:	957d                	srai	a0,a0,0x3f
    return -1;
  return 0;
    80002eba:	70a2                	ld	ra,40(sp)
    80002ebc:	7402                	ld	s0,32(sp)
    80002ebe:	6145                	addi	sp,sp,48
    80002ec0:	8082                	ret

0000000080002ec2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ec2:	7179                	addi	sp,sp,-48
    80002ec4:	f406                	sd	ra,40(sp)
    80002ec6:	f022                	sd	s0,32(sp)
    80002ec8:	ec26                	sd	s1,24(sp)
    80002eca:	e84a                	sd	s2,16(sp)
    80002ecc:	e44e                	sd	s3,8(sp)
    80002ece:	e052                	sd	s4,0(sp)
    80002ed0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ed2:	00005597          	auipc	a1,0x5
    80002ed6:	6de58593          	addi	a1,a1,1758 # 800085b0 <syscalls+0xc0>
    80002eda:	00015517          	auipc	a0,0x15
    80002ede:	aa650513          	addi	a0,a0,-1370 # 80017980 <bcache>
    80002ee2:	ffffe097          	auipc	ra,0xffffe
    80002ee6:	ce4080e7          	jalr	-796(ra) # 80000bc6 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002eea:	0001d797          	auipc	a5,0x1d
    80002eee:	a9678793          	addi	a5,a5,-1386 # 8001f980 <bcache+0x8000>
    80002ef2:	0001d717          	auipc	a4,0x1d
    80002ef6:	cf670713          	addi	a4,a4,-778 # 8001fbe8 <bcache+0x8268>
    80002efa:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002efe:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f02:	00015497          	auipc	s1,0x15
    80002f06:	a9648493          	addi	s1,s1,-1386 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    80002f0a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f0c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f0e:	00005a17          	auipc	s4,0x5
    80002f12:	6aaa0a13          	addi	s4,s4,1706 # 800085b8 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002f16:	2b893783          	ld	a5,696(s2)
    80002f1a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f1c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f20:	85d2                	mv	a1,s4
    80002f22:	01048513          	addi	a0,s1,16
    80002f26:	00001097          	auipc	ra,0x1
    80002f2a:	4ac080e7          	jalr	1196(ra) # 800043d2 <initsleeplock>
    bcache.head.next->prev = b;
    80002f2e:	2b893783          	ld	a5,696(s2)
    80002f32:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f34:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f38:	45848493          	addi	s1,s1,1112
    80002f3c:	fd349de3          	bne	s1,s3,80002f16 <binit+0x54>
  }
}
    80002f40:	70a2                	ld	ra,40(sp)
    80002f42:	7402                	ld	s0,32(sp)
    80002f44:	64e2                	ld	s1,24(sp)
    80002f46:	6942                	ld	s2,16(sp)
    80002f48:	69a2                	ld	s3,8(sp)
    80002f4a:	6a02                	ld	s4,0(sp)
    80002f4c:	6145                	addi	sp,sp,48
    80002f4e:	8082                	ret

0000000080002f50 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f50:	7179                	addi	sp,sp,-48
    80002f52:	f406                	sd	ra,40(sp)
    80002f54:	f022                	sd	s0,32(sp)
    80002f56:	ec26                	sd	s1,24(sp)
    80002f58:	e84a                	sd	s2,16(sp)
    80002f5a:	e44e                	sd	s3,8(sp)
    80002f5c:	1800                	addi	s0,sp,48
    80002f5e:	892a                	mv	s2,a0
    80002f60:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f62:	00015517          	auipc	a0,0x15
    80002f66:	a1e50513          	addi	a0,a0,-1506 # 80017980 <bcache>
    80002f6a:	ffffe097          	auipc	ra,0xffffe
    80002f6e:	cec080e7          	jalr	-788(ra) # 80000c56 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f72:	0001d497          	auipc	s1,0x1d
    80002f76:	cc64b483          	ld	s1,-826(s1) # 8001fc38 <bcache+0x82b8>
    80002f7a:	0001d797          	auipc	a5,0x1d
    80002f7e:	c6e78793          	addi	a5,a5,-914 # 8001fbe8 <bcache+0x8268>
    80002f82:	02f48f63          	beq	s1,a5,80002fc0 <bread+0x70>
    80002f86:	873e                	mv	a4,a5
    80002f88:	a021                	j	80002f90 <bread+0x40>
    80002f8a:	68a4                	ld	s1,80(s1)
    80002f8c:	02e48a63          	beq	s1,a4,80002fc0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f90:	449c                	lw	a5,8(s1)
    80002f92:	ff279ce3          	bne	a5,s2,80002f8a <bread+0x3a>
    80002f96:	44dc                	lw	a5,12(s1)
    80002f98:	ff3799e3          	bne	a5,s3,80002f8a <bread+0x3a>
      b->refcnt++;
    80002f9c:	40bc                	lw	a5,64(s1)
    80002f9e:	2785                	addiw	a5,a5,1
    80002fa0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fa2:	00015517          	auipc	a0,0x15
    80002fa6:	9de50513          	addi	a0,a0,-1570 # 80017980 <bcache>
    80002faa:	ffffe097          	auipc	ra,0xffffe
    80002fae:	d60080e7          	jalr	-672(ra) # 80000d0a <release>
      acquiresleep(&b->lock);
    80002fb2:	01048513          	addi	a0,s1,16
    80002fb6:	00001097          	auipc	ra,0x1
    80002fba:	456080e7          	jalr	1110(ra) # 8000440c <acquiresleep>
      return b;
    80002fbe:	a8b9                	j	8000301c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fc0:	0001d497          	auipc	s1,0x1d
    80002fc4:	c704b483          	ld	s1,-912(s1) # 8001fc30 <bcache+0x82b0>
    80002fc8:	0001d797          	auipc	a5,0x1d
    80002fcc:	c2078793          	addi	a5,a5,-992 # 8001fbe8 <bcache+0x8268>
    80002fd0:	00f48863          	beq	s1,a5,80002fe0 <bread+0x90>
    80002fd4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fd6:	40bc                	lw	a5,64(s1)
    80002fd8:	cf81                	beqz	a5,80002ff0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fda:	64a4                	ld	s1,72(s1)
    80002fdc:	fee49de3          	bne	s1,a4,80002fd6 <bread+0x86>
  panic("bget: no buffers");
    80002fe0:	00005517          	auipc	a0,0x5
    80002fe4:	5e050513          	addi	a0,a0,1504 # 800085c0 <syscalls+0xd0>
    80002fe8:	ffffd097          	auipc	ra,0xffffd
    80002fec:	568080e7          	jalr	1384(ra) # 80000550 <panic>
      b->dev = dev;
    80002ff0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ff4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ff8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ffc:	4785                	li	a5,1
    80002ffe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003000:	00015517          	auipc	a0,0x15
    80003004:	98050513          	addi	a0,a0,-1664 # 80017980 <bcache>
    80003008:	ffffe097          	auipc	ra,0xffffe
    8000300c:	d02080e7          	jalr	-766(ra) # 80000d0a <release>
      acquiresleep(&b->lock);
    80003010:	01048513          	addi	a0,s1,16
    80003014:	00001097          	auipc	ra,0x1
    80003018:	3f8080e7          	jalr	1016(ra) # 8000440c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000301c:	409c                	lw	a5,0(s1)
    8000301e:	cb89                	beqz	a5,80003030 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003020:	8526                	mv	a0,s1
    80003022:	70a2                	ld	ra,40(sp)
    80003024:	7402                	ld	s0,32(sp)
    80003026:	64e2                	ld	s1,24(sp)
    80003028:	6942                	ld	s2,16(sp)
    8000302a:	69a2                	ld	s3,8(sp)
    8000302c:	6145                	addi	sp,sp,48
    8000302e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003030:	4581                	li	a1,0
    80003032:	8526                	mv	a0,s1
    80003034:	00003097          	auipc	ra,0x3
    80003038:	f44080e7          	jalr	-188(ra) # 80005f78 <virtio_disk_rw>
    b->valid = 1;
    8000303c:	4785                	li	a5,1
    8000303e:	c09c                	sw	a5,0(s1)
  return b;
    80003040:	b7c5                	j	80003020 <bread+0xd0>

0000000080003042 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003042:	1101                	addi	sp,sp,-32
    80003044:	ec06                	sd	ra,24(sp)
    80003046:	e822                	sd	s0,16(sp)
    80003048:	e426                	sd	s1,8(sp)
    8000304a:	1000                	addi	s0,sp,32
    8000304c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000304e:	0541                	addi	a0,a0,16
    80003050:	00001097          	auipc	ra,0x1
    80003054:	456080e7          	jalr	1110(ra) # 800044a6 <holdingsleep>
    80003058:	cd01                	beqz	a0,80003070 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000305a:	4585                	li	a1,1
    8000305c:	8526                	mv	a0,s1
    8000305e:	00003097          	auipc	ra,0x3
    80003062:	f1a080e7          	jalr	-230(ra) # 80005f78 <virtio_disk_rw>
}
    80003066:	60e2                	ld	ra,24(sp)
    80003068:	6442                	ld	s0,16(sp)
    8000306a:	64a2                	ld	s1,8(sp)
    8000306c:	6105                	addi	sp,sp,32
    8000306e:	8082                	ret
    panic("bwrite");
    80003070:	00005517          	auipc	a0,0x5
    80003074:	56850513          	addi	a0,a0,1384 # 800085d8 <syscalls+0xe8>
    80003078:	ffffd097          	auipc	ra,0xffffd
    8000307c:	4d8080e7          	jalr	1240(ra) # 80000550 <panic>

0000000080003080 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003080:	1101                	addi	sp,sp,-32
    80003082:	ec06                	sd	ra,24(sp)
    80003084:	e822                	sd	s0,16(sp)
    80003086:	e426                	sd	s1,8(sp)
    80003088:	e04a                	sd	s2,0(sp)
    8000308a:	1000                	addi	s0,sp,32
    8000308c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000308e:	01050913          	addi	s2,a0,16
    80003092:	854a                	mv	a0,s2
    80003094:	00001097          	auipc	ra,0x1
    80003098:	412080e7          	jalr	1042(ra) # 800044a6 <holdingsleep>
    8000309c:	c92d                	beqz	a0,8000310e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000309e:	854a                	mv	a0,s2
    800030a0:	00001097          	auipc	ra,0x1
    800030a4:	3c2080e7          	jalr	962(ra) # 80004462 <releasesleep>

  acquire(&bcache.lock);
    800030a8:	00015517          	auipc	a0,0x15
    800030ac:	8d850513          	addi	a0,a0,-1832 # 80017980 <bcache>
    800030b0:	ffffe097          	auipc	ra,0xffffe
    800030b4:	ba6080e7          	jalr	-1114(ra) # 80000c56 <acquire>
  b->refcnt--;
    800030b8:	40bc                	lw	a5,64(s1)
    800030ba:	37fd                	addiw	a5,a5,-1
    800030bc:	0007871b          	sext.w	a4,a5
    800030c0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030c2:	eb05                	bnez	a4,800030f2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030c4:	68bc                	ld	a5,80(s1)
    800030c6:	64b8                	ld	a4,72(s1)
    800030c8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800030ca:	64bc                	ld	a5,72(s1)
    800030cc:	68b8                	ld	a4,80(s1)
    800030ce:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030d0:	0001d797          	auipc	a5,0x1d
    800030d4:	8b078793          	addi	a5,a5,-1872 # 8001f980 <bcache+0x8000>
    800030d8:	2b87b703          	ld	a4,696(a5)
    800030dc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030de:	0001d717          	auipc	a4,0x1d
    800030e2:	b0a70713          	addi	a4,a4,-1270 # 8001fbe8 <bcache+0x8268>
    800030e6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030e8:	2b87b703          	ld	a4,696(a5)
    800030ec:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030ee:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030f2:	00015517          	auipc	a0,0x15
    800030f6:	88e50513          	addi	a0,a0,-1906 # 80017980 <bcache>
    800030fa:	ffffe097          	auipc	ra,0xffffe
    800030fe:	c10080e7          	jalr	-1008(ra) # 80000d0a <release>
}
    80003102:	60e2                	ld	ra,24(sp)
    80003104:	6442                	ld	s0,16(sp)
    80003106:	64a2                	ld	s1,8(sp)
    80003108:	6902                	ld	s2,0(sp)
    8000310a:	6105                	addi	sp,sp,32
    8000310c:	8082                	ret
    panic("brelse");
    8000310e:	00005517          	auipc	a0,0x5
    80003112:	4d250513          	addi	a0,a0,1234 # 800085e0 <syscalls+0xf0>
    80003116:	ffffd097          	auipc	ra,0xffffd
    8000311a:	43a080e7          	jalr	1082(ra) # 80000550 <panic>

000000008000311e <bpin>:

void
bpin(struct buf *b) {
    8000311e:	1101                	addi	sp,sp,-32
    80003120:	ec06                	sd	ra,24(sp)
    80003122:	e822                	sd	s0,16(sp)
    80003124:	e426                	sd	s1,8(sp)
    80003126:	1000                	addi	s0,sp,32
    80003128:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000312a:	00015517          	auipc	a0,0x15
    8000312e:	85650513          	addi	a0,a0,-1962 # 80017980 <bcache>
    80003132:	ffffe097          	auipc	ra,0xffffe
    80003136:	b24080e7          	jalr	-1244(ra) # 80000c56 <acquire>
  b->refcnt++;
    8000313a:	40bc                	lw	a5,64(s1)
    8000313c:	2785                	addiw	a5,a5,1
    8000313e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003140:	00015517          	auipc	a0,0x15
    80003144:	84050513          	addi	a0,a0,-1984 # 80017980 <bcache>
    80003148:	ffffe097          	auipc	ra,0xffffe
    8000314c:	bc2080e7          	jalr	-1086(ra) # 80000d0a <release>
}
    80003150:	60e2                	ld	ra,24(sp)
    80003152:	6442                	ld	s0,16(sp)
    80003154:	64a2                	ld	s1,8(sp)
    80003156:	6105                	addi	sp,sp,32
    80003158:	8082                	ret

000000008000315a <bunpin>:

void
bunpin(struct buf *b) {
    8000315a:	1101                	addi	sp,sp,-32
    8000315c:	ec06                	sd	ra,24(sp)
    8000315e:	e822                	sd	s0,16(sp)
    80003160:	e426                	sd	s1,8(sp)
    80003162:	1000                	addi	s0,sp,32
    80003164:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003166:	00015517          	auipc	a0,0x15
    8000316a:	81a50513          	addi	a0,a0,-2022 # 80017980 <bcache>
    8000316e:	ffffe097          	auipc	ra,0xffffe
    80003172:	ae8080e7          	jalr	-1304(ra) # 80000c56 <acquire>
  b->refcnt--;
    80003176:	40bc                	lw	a5,64(s1)
    80003178:	37fd                	addiw	a5,a5,-1
    8000317a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000317c:	00015517          	auipc	a0,0x15
    80003180:	80450513          	addi	a0,a0,-2044 # 80017980 <bcache>
    80003184:	ffffe097          	auipc	ra,0xffffe
    80003188:	b86080e7          	jalr	-1146(ra) # 80000d0a <release>
}
    8000318c:	60e2                	ld	ra,24(sp)
    8000318e:	6442                	ld	s0,16(sp)
    80003190:	64a2                	ld	s1,8(sp)
    80003192:	6105                	addi	sp,sp,32
    80003194:	8082                	ret

0000000080003196 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003196:	1101                	addi	sp,sp,-32
    80003198:	ec06                	sd	ra,24(sp)
    8000319a:	e822                	sd	s0,16(sp)
    8000319c:	e426                	sd	s1,8(sp)
    8000319e:	e04a                	sd	s2,0(sp)
    800031a0:	1000                	addi	s0,sp,32
    800031a2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031a4:	00d5d59b          	srliw	a1,a1,0xd
    800031a8:	0001d797          	auipc	a5,0x1d
    800031ac:	eb47a783          	lw	a5,-332(a5) # 8002005c <sb+0x1c>
    800031b0:	9dbd                	addw	a1,a1,a5
    800031b2:	00000097          	auipc	ra,0x0
    800031b6:	d9e080e7          	jalr	-610(ra) # 80002f50 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031ba:	0074f713          	andi	a4,s1,7
    800031be:	4785                	li	a5,1
    800031c0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031c4:	14ce                	slli	s1,s1,0x33
    800031c6:	90d9                	srli	s1,s1,0x36
    800031c8:	00950733          	add	a4,a0,s1
    800031cc:	05874703          	lbu	a4,88(a4)
    800031d0:	00e7f6b3          	and	a3,a5,a4
    800031d4:	c69d                	beqz	a3,80003202 <bfree+0x6c>
    800031d6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031d8:	94aa                	add	s1,s1,a0
    800031da:	fff7c793          	not	a5,a5
    800031de:	8ff9                	and	a5,a5,a4
    800031e0:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800031e4:	00001097          	auipc	ra,0x1
    800031e8:	100080e7          	jalr	256(ra) # 800042e4 <log_write>
  brelse(bp);
    800031ec:	854a                	mv	a0,s2
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	e92080e7          	jalr	-366(ra) # 80003080 <brelse>
}
    800031f6:	60e2                	ld	ra,24(sp)
    800031f8:	6442                	ld	s0,16(sp)
    800031fa:	64a2                	ld	s1,8(sp)
    800031fc:	6902                	ld	s2,0(sp)
    800031fe:	6105                	addi	sp,sp,32
    80003200:	8082                	ret
    panic("freeing free block");
    80003202:	00005517          	auipc	a0,0x5
    80003206:	3e650513          	addi	a0,a0,998 # 800085e8 <syscalls+0xf8>
    8000320a:	ffffd097          	auipc	ra,0xffffd
    8000320e:	346080e7          	jalr	838(ra) # 80000550 <panic>

0000000080003212 <balloc>:
{
    80003212:	711d                	addi	sp,sp,-96
    80003214:	ec86                	sd	ra,88(sp)
    80003216:	e8a2                	sd	s0,80(sp)
    80003218:	e4a6                	sd	s1,72(sp)
    8000321a:	e0ca                	sd	s2,64(sp)
    8000321c:	fc4e                	sd	s3,56(sp)
    8000321e:	f852                	sd	s4,48(sp)
    80003220:	f456                	sd	s5,40(sp)
    80003222:	f05a                	sd	s6,32(sp)
    80003224:	ec5e                	sd	s7,24(sp)
    80003226:	e862                	sd	s8,16(sp)
    80003228:	e466                	sd	s9,8(sp)
    8000322a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000322c:	0001d797          	auipc	a5,0x1d
    80003230:	e187a783          	lw	a5,-488(a5) # 80020044 <sb+0x4>
    80003234:	cbd1                	beqz	a5,800032c8 <balloc+0xb6>
    80003236:	8baa                	mv	s7,a0
    80003238:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000323a:	0001db17          	auipc	s6,0x1d
    8000323e:	e06b0b13          	addi	s6,s6,-506 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003242:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003244:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003246:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003248:	6c89                	lui	s9,0x2
    8000324a:	a831                	j	80003266 <balloc+0x54>
    brelse(bp);
    8000324c:	854a                	mv	a0,s2
    8000324e:	00000097          	auipc	ra,0x0
    80003252:	e32080e7          	jalr	-462(ra) # 80003080 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003256:	015c87bb          	addw	a5,s9,s5
    8000325a:	00078a9b          	sext.w	s5,a5
    8000325e:	004b2703          	lw	a4,4(s6)
    80003262:	06eaf363          	bgeu	s5,a4,800032c8 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003266:	41fad79b          	sraiw	a5,s5,0x1f
    8000326a:	0137d79b          	srliw	a5,a5,0x13
    8000326e:	015787bb          	addw	a5,a5,s5
    80003272:	40d7d79b          	sraiw	a5,a5,0xd
    80003276:	01cb2583          	lw	a1,28(s6)
    8000327a:	9dbd                	addw	a1,a1,a5
    8000327c:	855e                	mv	a0,s7
    8000327e:	00000097          	auipc	ra,0x0
    80003282:	cd2080e7          	jalr	-814(ra) # 80002f50 <bread>
    80003286:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003288:	004b2503          	lw	a0,4(s6)
    8000328c:	000a849b          	sext.w	s1,s5
    80003290:	8662                	mv	a2,s8
    80003292:	faa4fde3          	bgeu	s1,a0,8000324c <balloc+0x3a>
      m = 1 << (bi % 8);
    80003296:	41f6579b          	sraiw	a5,a2,0x1f
    8000329a:	01d7d69b          	srliw	a3,a5,0x1d
    8000329e:	00c6873b          	addw	a4,a3,a2
    800032a2:	00777793          	andi	a5,a4,7
    800032a6:	9f95                	subw	a5,a5,a3
    800032a8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032ac:	4037571b          	sraiw	a4,a4,0x3
    800032b0:	00e906b3          	add	a3,s2,a4
    800032b4:	0586c683          	lbu	a3,88(a3)
    800032b8:	00d7f5b3          	and	a1,a5,a3
    800032bc:	cd91                	beqz	a1,800032d8 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032be:	2605                	addiw	a2,a2,1
    800032c0:	2485                	addiw	s1,s1,1
    800032c2:	fd4618e3          	bne	a2,s4,80003292 <balloc+0x80>
    800032c6:	b759                	j	8000324c <balloc+0x3a>
  panic("balloc: out of blocks");
    800032c8:	00005517          	auipc	a0,0x5
    800032cc:	33850513          	addi	a0,a0,824 # 80008600 <syscalls+0x110>
    800032d0:	ffffd097          	auipc	ra,0xffffd
    800032d4:	280080e7          	jalr	640(ra) # 80000550 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032d8:	974a                	add	a4,a4,s2
    800032da:	8fd5                	or	a5,a5,a3
    800032dc:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800032e0:	854a                	mv	a0,s2
    800032e2:	00001097          	auipc	ra,0x1
    800032e6:	002080e7          	jalr	2(ra) # 800042e4 <log_write>
        brelse(bp);
    800032ea:	854a                	mv	a0,s2
    800032ec:	00000097          	auipc	ra,0x0
    800032f0:	d94080e7          	jalr	-620(ra) # 80003080 <brelse>
  bp = bread(dev, bno);
    800032f4:	85a6                	mv	a1,s1
    800032f6:	855e                	mv	a0,s7
    800032f8:	00000097          	auipc	ra,0x0
    800032fc:	c58080e7          	jalr	-936(ra) # 80002f50 <bread>
    80003300:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003302:	40000613          	li	a2,1024
    80003306:	4581                	li	a1,0
    80003308:	05850513          	addi	a0,a0,88
    8000330c:	ffffe097          	auipc	ra,0xffffe
    80003310:	a46080e7          	jalr	-1466(ra) # 80000d52 <memset>
  log_write(bp);
    80003314:	854a                	mv	a0,s2
    80003316:	00001097          	auipc	ra,0x1
    8000331a:	fce080e7          	jalr	-50(ra) # 800042e4 <log_write>
  brelse(bp);
    8000331e:	854a                	mv	a0,s2
    80003320:	00000097          	auipc	ra,0x0
    80003324:	d60080e7          	jalr	-672(ra) # 80003080 <brelse>
}
    80003328:	8526                	mv	a0,s1
    8000332a:	60e6                	ld	ra,88(sp)
    8000332c:	6446                	ld	s0,80(sp)
    8000332e:	64a6                	ld	s1,72(sp)
    80003330:	6906                	ld	s2,64(sp)
    80003332:	79e2                	ld	s3,56(sp)
    80003334:	7a42                	ld	s4,48(sp)
    80003336:	7aa2                	ld	s5,40(sp)
    80003338:	7b02                	ld	s6,32(sp)
    8000333a:	6be2                	ld	s7,24(sp)
    8000333c:	6c42                	ld	s8,16(sp)
    8000333e:	6ca2                	ld	s9,8(sp)
    80003340:	6125                	addi	sp,sp,96
    80003342:	8082                	ret

0000000080003344 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003344:	7179                	addi	sp,sp,-48
    80003346:	f406                	sd	ra,40(sp)
    80003348:	f022                	sd	s0,32(sp)
    8000334a:	ec26                	sd	s1,24(sp)
    8000334c:	e84a                	sd	s2,16(sp)
    8000334e:	e44e                	sd	s3,8(sp)
    80003350:	e052                	sd	s4,0(sp)
    80003352:	1800                	addi	s0,sp,48
    80003354:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003356:	47ad                	li	a5,11
    80003358:	04b7fe63          	bgeu	a5,a1,800033b4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000335c:	ff45849b          	addiw	s1,a1,-12
    80003360:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003364:	0ff00793          	li	a5,255
    80003368:	0ae7e363          	bltu	a5,a4,8000340e <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000336c:	08052583          	lw	a1,128(a0)
    80003370:	c5ad                	beqz	a1,800033da <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003372:	00092503          	lw	a0,0(s2)
    80003376:	00000097          	auipc	ra,0x0
    8000337a:	bda080e7          	jalr	-1062(ra) # 80002f50 <bread>
    8000337e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003380:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003384:	02049593          	slli	a1,s1,0x20
    80003388:	9181                	srli	a1,a1,0x20
    8000338a:	058a                	slli	a1,a1,0x2
    8000338c:	00b784b3          	add	s1,a5,a1
    80003390:	0004a983          	lw	s3,0(s1)
    80003394:	04098d63          	beqz	s3,800033ee <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003398:	8552                	mv	a0,s4
    8000339a:	00000097          	auipc	ra,0x0
    8000339e:	ce6080e7          	jalr	-794(ra) # 80003080 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033a2:	854e                	mv	a0,s3
    800033a4:	70a2                	ld	ra,40(sp)
    800033a6:	7402                	ld	s0,32(sp)
    800033a8:	64e2                	ld	s1,24(sp)
    800033aa:	6942                	ld	s2,16(sp)
    800033ac:	69a2                	ld	s3,8(sp)
    800033ae:	6a02                	ld	s4,0(sp)
    800033b0:	6145                	addi	sp,sp,48
    800033b2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033b4:	02059493          	slli	s1,a1,0x20
    800033b8:	9081                	srli	s1,s1,0x20
    800033ba:	048a                	slli	s1,s1,0x2
    800033bc:	94aa                	add	s1,s1,a0
    800033be:	0504a983          	lw	s3,80(s1)
    800033c2:	fe0990e3          	bnez	s3,800033a2 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033c6:	4108                	lw	a0,0(a0)
    800033c8:	00000097          	auipc	ra,0x0
    800033cc:	e4a080e7          	jalr	-438(ra) # 80003212 <balloc>
    800033d0:	0005099b          	sext.w	s3,a0
    800033d4:	0534a823          	sw	s3,80(s1)
    800033d8:	b7e9                	j	800033a2 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033da:	4108                	lw	a0,0(a0)
    800033dc:	00000097          	auipc	ra,0x0
    800033e0:	e36080e7          	jalr	-458(ra) # 80003212 <balloc>
    800033e4:	0005059b          	sext.w	a1,a0
    800033e8:	08b92023          	sw	a1,128(s2)
    800033ec:	b759                	j	80003372 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800033ee:	00092503          	lw	a0,0(s2)
    800033f2:	00000097          	auipc	ra,0x0
    800033f6:	e20080e7          	jalr	-480(ra) # 80003212 <balloc>
    800033fa:	0005099b          	sext.w	s3,a0
    800033fe:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003402:	8552                	mv	a0,s4
    80003404:	00001097          	auipc	ra,0x1
    80003408:	ee0080e7          	jalr	-288(ra) # 800042e4 <log_write>
    8000340c:	b771                	j	80003398 <bmap+0x54>
  panic("bmap: out of range");
    8000340e:	00005517          	auipc	a0,0x5
    80003412:	20a50513          	addi	a0,a0,522 # 80008618 <syscalls+0x128>
    80003416:	ffffd097          	auipc	ra,0xffffd
    8000341a:	13a080e7          	jalr	314(ra) # 80000550 <panic>

000000008000341e <iget>:
{
    8000341e:	7179                	addi	sp,sp,-48
    80003420:	f406                	sd	ra,40(sp)
    80003422:	f022                	sd	s0,32(sp)
    80003424:	ec26                	sd	s1,24(sp)
    80003426:	e84a                	sd	s2,16(sp)
    80003428:	e44e                	sd	s3,8(sp)
    8000342a:	e052                	sd	s4,0(sp)
    8000342c:	1800                	addi	s0,sp,48
    8000342e:	89aa                	mv	s3,a0
    80003430:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003432:	0001d517          	auipc	a0,0x1d
    80003436:	c2e50513          	addi	a0,a0,-978 # 80020060 <icache>
    8000343a:	ffffe097          	auipc	ra,0xffffe
    8000343e:	81c080e7          	jalr	-2020(ra) # 80000c56 <acquire>
  empty = 0;
    80003442:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003444:	0001d497          	auipc	s1,0x1d
    80003448:	c3448493          	addi	s1,s1,-972 # 80020078 <icache+0x18>
    8000344c:	0001e697          	auipc	a3,0x1e
    80003450:	6bc68693          	addi	a3,a3,1724 # 80021b08 <log>
    80003454:	a039                	j	80003462 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003456:	02090b63          	beqz	s2,8000348c <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000345a:	08848493          	addi	s1,s1,136
    8000345e:	02d48a63          	beq	s1,a3,80003492 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003462:	449c                	lw	a5,8(s1)
    80003464:	fef059e3          	blez	a5,80003456 <iget+0x38>
    80003468:	4098                	lw	a4,0(s1)
    8000346a:	ff3716e3          	bne	a4,s3,80003456 <iget+0x38>
    8000346e:	40d8                	lw	a4,4(s1)
    80003470:	ff4713e3          	bne	a4,s4,80003456 <iget+0x38>
      ip->ref++;
    80003474:	2785                	addiw	a5,a5,1
    80003476:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003478:	0001d517          	auipc	a0,0x1d
    8000347c:	be850513          	addi	a0,a0,-1048 # 80020060 <icache>
    80003480:	ffffe097          	auipc	ra,0xffffe
    80003484:	88a080e7          	jalr	-1910(ra) # 80000d0a <release>
      return ip;
    80003488:	8926                	mv	s2,s1
    8000348a:	a03d                	j	800034b8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000348c:	f7f9                	bnez	a5,8000345a <iget+0x3c>
    8000348e:	8926                	mv	s2,s1
    80003490:	b7e9                	j	8000345a <iget+0x3c>
  if(empty == 0)
    80003492:	02090c63          	beqz	s2,800034ca <iget+0xac>
  ip->dev = dev;
    80003496:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000349a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000349e:	4785                	li	a5,1
    800034a0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034a4:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800034a8:	0001d517          	auipc	a0,0x1d
    800034ac:	bb850513          	addi	a0,a0,-1096 # 80020060 <icache>
    800034b0:	ffffe097          	auipc	ra,0xffffe
    800034b4:	85a080e7          	jalr	-1958(ra) # 80000d0a <release>
}
    800034b8:	854a                	mv	a0,s2
    800034ba:	70a2                	ld	ra,40(sp)
    800034bc:	7402                	ld	s0,32(sp)
    800034be:	64e2                	ld	s1,24(sp)
    800034c0:	6942                	ld	s2,16(sp)
    800034c2:	69a2                	ld	s3,8(sp)
    800034c4:	6a02                	ld	s4,0(sp)
    800034c6:	6145                	addi	sp,sp,48
    800034c8:	8082                	ret
    panic("iget: no inodes");
    800034ca:	00005517          	auipc	a0,0x5
    800034ce:	16650513          	addi	a0,a0,358 # 80008630 <syscalls+0x140>
    800034d2:	ffffd097          	auipc	ra,0xffffd
    800034d6:	07e080e7          	jalr	126(ra) # 80000550 <panic>

00000000800034da <fsinit>:
fsinit(int dev) {
    800034da:	7179                	addi	sp,sp,-48
    800034dc:	f406                	sd	ra,40(sp)
    800034de:	f022                	sd	s0,32(sp)
    800034e0:	ec26                	sd	s1,24(sp)
    800034e2:	e84a                	sd	s2,16(sp)
    800034e4:	e44e                	sd	s3,8(sp)
    800034e6:	1800                	addi	s0,sp,48
    800034e8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034ea:	4585                	li	a1,1
    800034ec:	00000097          	auipc	ra,0x0
    800034f0:	a64080e7          	jalr	-1436(ra) # 80002f50 <bread>
    800034f4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034f6:	0001d997          	auipc	s3,0x1d
    800034fa:	b4a98993          	addi	s3,s3,-1206 # 80020040 <sb>
    800034fe:	02000613          	li	a2,32
    80003502:	05850593          	addi	a1,a0,88
    80003506:	854e                	mv	a0,s3
    80003508:	ffffe097          	auipc	ra,0xffffe
    8000350c:	8a6080e7          	jalr	-1882(ra) # 80000dae <memmove>
  brelse(bp);
    80003510:	8526                	mv	a0,s1
    80003512:	00000097          	auipc	ra,0x0
    80003516:	b6e080e7          	jalr	-1170(ra) # 80003080 <brelse>
  if(sb.magic != FSMAGIC)
    8000351a:	0009a703          	lw	a4,0(s3)
    8000351e:	102037b7          	lui	a5,0x10203
    80003522:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003526:	02f71263          	bne	a4,a5,8000354a <fsinit+0x70>
  initlog(dev, &sb);
    8000352a:	0001d597          	auipc	a1,0x1d
    8000352e:	b1658593          	addi	a1,a1,-1258 # 80020040 <sb>
    80003532:	854a                	mv	a0,s2
    80003534:	00001097          	auipc	ra,0x1
    80003538:	b38080e7          	jalr	-1224(ra) # 8000406c <initlog>
}
    8000353c:	70a2                	ld	ra,40(sp)
    8000353e:	7402                	ld	s0,32(sp)
    80003540:	64e2                	ld	s1,24(sp)
    80003542:	6942                	ld	s2,16(sp)
    80003544:	69a2                	ld	s3,8(sp)
    80003546:	6145                	addi	sp,sp,48
    80003548:	8082                	ret
    panic("invalid file system");
    8000354a:	00005517          	auipc	a0,0x5
    8000354e:	0f650513          	addi	a0,a0,246 # 80008640 <syscalls+0x150>
    80003552:	ffffd097          	auipc	ra,0xffffd
    80003556:	ffe080e7          	jalr	-2(ra) # 80000550 <panic>

000000008000355a <iinit>:
{
    8000355a:	7179                	addi	sp,sp,-48
    8000355c:	f406                	sd	ra,40(sp)
    8000355e:	f022                	sd	s0,32(sp)
    80003560:	ec26                	sd	s1,24(sp)
    80003562:	e84a                	sd	s2,16(sp)
    80003564:	e44e                	sd	s3,8(sp)
    80003566:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003568:	00005597          	auipc	a1,0x5
    8000356c:	0f058593          	addi	a1,a1,240 # 80008658 <syscalls+0x168>
    80003570:	0001d517          	auipc	a0,0x1d
    80003574:	af050513          	addi	a0,a0,-1296 # 80020060 <icache>
    80003578:	ffffd097          	auipc	ra,0xffffd
    8000357c:	64e080e7          	jalr	1614(ra) # 80000bc6 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003580:	0001d497          	auipc	s1,0x1d
    80003584:	b0848493          	addi	s1,s1,-1272 # 80020088 <icache+0x28>
    80003588:	0001e997          	auipc	s3,0x1e
    8000358c:	59098993          	addi	s3,s3,1424 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003590:	00005917          	auipc	s2,0x5
    80003594:	0d090913          	addi	s2,s2,208 # 80008660 <syscalls+0x170>
    80003598:	85ca                	mv	a1,s2
    8000359a:	8526                	mv	a0,s1
    8000359c:	00001097          	auipc	ra,0x1
    800035a0:	e36080e7          	jalr	-458(ra) # 800043d2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035a4:	08848493          	addi	s1,s1,136
    800035a8:	ff3498e3          	bne	s1,s3,80003598 <iinit+0x3e>
}
    800035ac:	70a2                	ld	ra,40(sp)
    800035ae:	7402                	ld	s0,32(sp)
    800035b0:	64e2                	ld	s1,24(sp)
    800035b2:	6942                	ld	s2,16(sp)
    800035b4:	69a2                	ld	s3,8(sp)
    800035b6:	6145                	addi	sp,sp,48
    800035b8:	8082                	ret

00000000800035ba <ialloc>:
{
    800035ba:	715d                	addi	sp,sp,-80
    800035bc:	e486                	sd	ra,72(sp)
    800035be:	e0a2                	sd	s0,64(sp)
    800035c0:	fc26                	sd	s1,56(sp)
    800035c2:	f84a                	sd	s2,48(sp)
    800035c4:	f44e                	sd	s3,40(sp)
    800035c6:	f052                	sd	s4,32(sp)
    800035c8:	ec56                	sd	s5,24(sp)
    800035ca:	e85a                	sd	s6,16(sp)
    800035cc:	e45e                	sd	s7,8(sp)
    800035ce:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035d0:	0001d717          	auipc	a4,0x1d
    800035d4:	a7c72703          	lw	a4,-1412(a4) # 8002004c <sb+0xc>
    800035d8:	4785                	li	a5,1
    800035da:	04e7fa63          	bgeu	a5,a4,8000362e <ialloc+0x74>
    800035de:	8aaa                	mv	s5,a0
    800035e0:	8bae                	mv	s7,a1
    800035e2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035e4:	0001da17          	auipc	s4,0x1d
    800035e8:	a5ca0a13          	addi	s4,s4,-1444 # 80020040 <sb>
    800035ec:	00048b1b          	sext.w	s6,s1
    800035f0:	0044d793          	srli	a5,s1,0x4
    800035f4:	018a2583          	lw	a1,24(s4)
    800035f8:	9dbd                	addw	a1,a1,a5
    800035fa:	8556                	mv	a0,s5
    800035fc:	00000097          	auipc	ra,0x0
    80003600:	954080e7          	jalr	-1708(ra) # 80002f50 <bread>
    80003604:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003606:	05850993          	addi	s3,a0,88
    8000360a:	00f4f793          	andi	a5,s1,15
    8000360e:	079a                	slli	a5,a5,0x6
    80003610:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003612:	00099783          	lh	a5,0(s3)
    80003616:	c785                	beqz	a5,8000363e <ialloc+0x84>
    brelse(bp);
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	a68080e7          	jalr	-1432(ra) # 80003080 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003620:	0485                	addi	s1,s1,1
    80003622:	00ca2703          	lw	a4,12(s4)
    80003626:	0004879b          	sext.w	a5,s1
    8000362a:	fce7e1e3          	bltu	a5,a4,800035ec <ialloc+0x32>
  panic("ialloc: no inodes");
    8000362e:	00005517          	auipc	a0,0x5
    80003632:	03a50513          	addi	a0,a0,58 # 80008668 <syscalls+0x178>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	f1a080e7          	jalr	-230(ra) # 80000550 <panic>
      memset(dip, 0, sizeof(*dip));
    8000363e:	04000613          	li	a2,64
    80003642:	4581                	li	a1,0
    80003644:	854e                	mv	a0,s3
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	70c080e7          	jalr	1804(ra) # 80000d52 <memset>
      dip->type = type;
    8000364e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003652:	854a                	mv	a0,s2
    80003654:	00001097          	auipc	ra,0x1
    80003658:	c90080e7          	jalr	-880(ra) # 800042e4 <log_write>
      brelse(bp);
    8000365c:	854a                	mv	a0,s2
    8000365e:	00000097          	auipc	ra,0x0
    80003662:	a22080e7          	jalr	-1502(ra) # 80003080 <brelse>
      return iget(dev, inum);
    80003666:	85da                	mv	a1,s6
    80003668:	8556                	mv	a0,s5
    8000366a:	00000097          	auipc	ra,0x0
    8000366e:	db4080e7          	jalr	-588(ra) # 8000341e <iget>
}
    80003672:	60a6                	ld	ra,72(sp)
    80003674:	6406                	ld	s0,64(sp)
    80003676:	74e2                	ld	s1,56(sp)
    80003678:	7942                	ld	s2,48(sp)
    8000367a:	79a2                	ld	s3,40(sp)
    8000367c:	7a02                	ld	s4,32(sp)
    8000367e:	6ae2                	ld	s5,24(sp)
    80003680:	6b42                	ld	s6,16(sp)
    80003682:	6ba2                	ld	s7,8(sp)
    80003684:	6161                	addi	sp,sp,80
    80003686:	8082                	ret

0000000080003688 <iupdate>:
{
    80003688:	1101                	addi	sp,sp,-32
    8000368a:	ec06                	sd	ra,24(sp)
    8000368c:	e822                	sd	s0,16(sp)
    8000368e:	e426                	sd	s1,8(sp)
    80003690:	e04a                	sd	s2,0(sp)
    80003692:	1000                	addi	s0,sp,32
    80003694:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003696:	415c                	lw	a5,4(a0)
    80003698:	0047d79b          	srliw	a5,a5,0x4
    8000369c:	0001d597          	auipc	a1,0x1d
    800036a0:	9bc5a583          	lw	a1,-1604(a1) # 80020058 <sb+0x18>
    800036a4:	9dbd                	addw	a1,a1,a5
    800036a6:	4108                	lw	a0,0(a0)
    800036a8:	00000097          	auipc	ra,0x0
    800036ac:	8a8080e7          	jalr	-1880(ra) # 80002f50 <bread>
    800036b0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036b2:	05850793          	addi	a5,a0,88
    800036b6:	40c8                	lw	a0,4(s1)
    800036b8:	893d                	andi	a0,a0,15
    800036ba:	051a                	slli	a0,a0,0x6
    800036bc:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800036be:	04449703          	lh	a4,68(s1)
    800036c2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800036c6:	04649703          	lh	a4,70(s1)
    800036ca:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800036ce:	04849703          	lh	a4,72(s1)
    800036d2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800036d6:	04a49703          	lh	a4,74(s1)
    800036da:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800036de:	44f8                	lw	a4,76(s1)
    800036e0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036e2:	03400613          	li	a2,52
    800036e6:	05048593          	addi	a1,s1,80
    800036ea:	0531                	addi	a0,a0,12
    800036ec:	ffffd097          	auipc	ra,0xffffd
    800036f0:	6c2080e7          	jalr	1730(ra) # 80000dae <memmove>
  log_write(bp);
    800036f4:	854a                	mv	a0,s2
    800036f6:	00001097          	auipc	ra,0x1
    800036fa:	bee080e7          	jalr	-1042(ra) # 800042e4 <log_write>
  brelse(bp);
    800036fe:	854a                	mv	a0,s2
    80003700:	00000097          	auipc	ra,0x0
    80003704:	980080e7          	jalr	-1664(ra) # 80003080 <brelse>
}
    80003708:	60e2                	ld	ra,24(sp)
    8000370a:	6442                	ld	s0,16(sp)
    8000370c:	64a2                	ld	s1,8(sp)
    8000370e:	6902                	ld	s2,0(sp)
    80003710:	6105                	addi	sp,sp,32
    80003712:	8082                	ret

0000000080003714 <idup>:
{
    80003714:	1101                	addi	sp,sp,-32
    80003716:	ec06                	sd	ra,24(sp)
    80003718:	e822                	sd	s0,16(sp)
    8000371a:	e426                	sd	s1,8(sp)
    8000371c:	1000                	addi	s0,sp,32
    8000371e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003720:	0001d517          	auipc	a0,0x1d
    80003724:	94050513          	addi	a0,a0,-1728 # 80020060 <icache>
    80003728:	ffffd097          	auipc	ra,0xffffd
    8000372c:	52e080e7          	jalr	1326(ra) # 80000c56 <acquire>
  ip->ref++;
    80003730:	449c                	lw	a5,8(s1)
    80003732:	2785                	addiw	a5,a5,1
    80003734:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003736:	0001d517          	auipc	a0,0x1d
    8000373a:	92a50513          	addi	a0,a0,-1750 # 80020060 <icache>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	5cc080e7          	jalr	1484(ra) # 80000d0a <release>
}
    80003746:	8526                	mv	a0,s1
    80003748:	60e2                	ld	ra,24(sp)
    8000374a:	6442                	ld	s0,16(sp)
    8000374c:	64a2                	ld	s1,8(sp)
    8000374e:	6105                	addi	sp,sp,32
    80003750:	8082                	ret

0000000080003752 <ilock>:
{
    80003752:	1101                	addi	sp,sp,-32
    80003754:	ec06                	sd	ra,24(sp)
    80003756:	e822                	sd	s0,16(sp)
    80003758:	e426                	sd	s1,8(sp)
    8000375a:	e04a                	sd	s2,0(sp)
    8000375c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000375e:	c115                	beqz	a0,80003782 <ilock+0x30>
    80003760:	84aa                	mv	s1,a0
    80003762:	451c                	lw	a5,8(a0)
    80003764:	00f05f63          	blez	a5,80003782 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003768:	0541                	addi	a0,a0,16
    8000376a:	00001097          	auipc	ra,0x1
    8000376e:	ca2080e7          	jalr	-862(ra) # 8000440c <acquiresleep>
  if(ip->valid == 0){
    80003772:	40bc                	lw	a5,64(s1)
    80003774:	cf99                	beqz	a5,80003792 <ilock+0x40>
}
    80003776:	60e2                	ld	ra,24(sp)
    80003778:	6442                	ld	s0,16(sp)
    8000377a:	64a2                	ld	s1,8(sp)
    8000377c:	6902                	ld	s2,0(sp)
    8000377e:	6105                	addi	sp,sp,32
    80003780:	8082                	ret
    panic("ilock");
    80003782:	00005517          	auipc	a0,0x5
    80003786:	efe50513          	addi	a0,a0,-258 # 80008680 <syscalls+0x190>
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	dc6080e7          	jalr	-570(ra) # 80000550 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003792:	40dc                	lw	a5,4(s1)
    80003794:	0047d79b          	srliw	a5,a5,0x4
    80003798:	0001d597          	auipc	a1,0x1d
    8000379c:	8c05a583          	lw	a1,-1856(a1) # 80020058 <sb+0x18>
    800037a0:	9dbd                	addw	a1,a1,a5
    800037a2:	4088                	lw	a0,0(s1)
    800037a4:	fffff097          	auipc	ra,0xfffff
    800037a8:	7ac080e7          	jalr	1964(ra) # 80002f50 <bread>
    800037ac:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037ae:	05850593          	addi	a1,a0,88
    800037b2:	40dc                	lw	a5,4(s1)
    800037b4:	8bbd                	andi	a5,a5,15
    800037b6:	079a                	slli	a5,a5,0x6
    800037b8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037ba:	00059783          	lh	a5,0(a1)
    800037be:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037c2:	00259783          	lh	a5,2(a1)
    800037c6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037ca:	00459783          	lh	a5,4(a1)
    800037ce:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037d2:	00659783          	lh	a5,6(a1)
    800037d6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037da:	459c                	lw	a5,8(a1)
    800037dc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037de:	03400613          	li	a2,52
    800037e2:	05b1                	addi	a1,a1,12
    800037e4:	05048513          	addi	a0,s1,80
    800037e8:	ffffd097          	auipc	ra,0xffffd
    800037ec:	5c6080e7          	jalr	1478(ra) # 80000dae <memmove>
    brelse(bp);
    800037f0:	854a                	mv	a0,s2
    800037f2:	00000097          	auipc	ra,0x0
    800037f6:	88e080e7          	jalr	-1906(ra) # 80003080 <brelse>
    ip->valid = 1;
    800037fa:	4785                	li	a5,1
    800037fc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037fe:	04449783          	lh	a5,68(s1)
    80003802:	fbb5                	bnez	a5,80003776 <ilock+0x24>
      panic("ilock: no type");
    80003804:	00005517          	auipc	a0,0x5
    80003808:	e8450513          	addi	a0,a0,-380 # 80008688 <syscalls+0x198>
    8000380c:	ffffd097          	auipc	ra,0xffffd
    80003810:	d44080e7          	jalr	-700(ra) # 80000550 <panic>

0000000080003814 <iunlock>:
{
    80003814:	1101                	addi	sp,sp,-32
    80003816:	ec06                	sd	ra,24(sp)
    80003818:	e822                	sd	s0,16(sp)
    8000381a:	e426                	sd	s1,8(sp)
    8000381c:	e04a                	sd	s2,0(sp)
    8000381e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003820:	c905                	beqz	a0,80003850 <iunlock+0x3c>
    80003822:	84aa                	mv	s1,a0
    80003824:	01050913          	addi	s2,a0,16
    80003828:	854a                	mv	a0,s2
    8000382a:	00001097          	auipc	ra,0x1
    8000382e:	c7c080e7          	jalr	-900(ra) # 800044a6 <holdingsleep>
    80003832:	cd19                	beqz	a0,80003850 <iunlock+0x3c>
    80003834:	449c                	lw	a5,8(s1)
    80003836:	00f05d63          	blez	a5,80003850 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000383a:	854a                	mv	a0,s2
    8000383c:	00001097          	auipc	ra,0x1
    80003840:	c26080e7          	jalr	-986(ra) # 80004462 <releasesleep>
}
    80003844:	60e2                	ld	ra,24(sp)
    80003846:	6442                	ld	s0,16(sp)
    80003848:	64a2                	ld	s1,8(sp)
    8000384a:	6902                	ld	s2,0(sp)
    8000384c:	6105                	addi	sp,sp,32
    8000384e:	8082                	ret
    panic("iunlock");
    80003850:	00005517          	auipc	a0,0x5
    80003854:	e4850513          	addi	a0,a0,-440 # 80008698 <syscalls+0x1a8>
    80003858:	ffffd097          	auipc	ra,0xffffd
    8000385c:	cf8080e7          	jalr	-776(ra) # 80000550 <panic>

0000000080003860 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003860:	7179                	addi	sp,sp,-48
    80003862:	f406                	sd	ra,40(sp)
    80003864:	f022                	sd	s0,32(sp)
    80003866:	ec26                	sd	s1,24(sp)
    80003868:	e84a                	sd	s2,16(sp)
    8000386a:	e44e                	sd	s3,8(sp)
    8000386c:	e052                	sd	s4,0(sp)
    8000386e:	1800                	addi	s0,sp,48
    80003870:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003872:	05050493          	addi	s1,a0,80
    80003876:	08050913          	addi	s2,a0,128
    8000387a:	a021                	j	80003882 <itrunc+0x22>
    8000387c:	0491                	addi	s1,s1,4
    8000387e:	01248d63          	beq	s1,s2,80003898 <itrunc+0x38>
    if(ip->addrs[i]){
    80003882:	408c                	lw	a1,0(s1)
    80003884:	dde5                	beqz	a1,8000387c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003886:	0009a503          	lw	a0,0(s3)
    8000388a:	00000097          	auipc	ra,0x0
    8000388e:	90c080e7          	jalr	-1780(ra) # 80003196 <bfree>
      ip->addrs[i] = 0;
    80003892:	0004a023          	sw	zero,0(s1)
    80003896:	b7dd                	j	8000387c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003898:	0809a583          	lw	a1,128(s3)
    8000389c:	e185                	bnez	a1,800038bc <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000389e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038a2:	854e                	mv	a0,s3
    800038a4:	00000097          	auipc	ra,0x0
    800038a8:	de4080e7          	jalr	-540(ra) # 80003688 <iupdate>
}
    800038ac:	70a2                	ld	ra,40(sp)
    800038ae:	7402                	ld	s0,32(sp)
    800038b0:	64e2                	ld	s1,24(sp)
    800038b2:	6942                	ld	s2,16(sp)
    800038b4:	69a2                	ld	s3,8(sp)
    800038b6:	6a02                	ld	s4,0(sp)
    800038b8:	6145                	addi	sp,sp,48
    800038ba:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038bc:	0009a503          	lw	a0,0(s3)
    800038c0:	fffff097          	auipc	ra,0xfffff
    800038c4:	690080e7          	jalr	1680(ra) # 80002f50 <bread>
    800038c8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038ca:	05850493          	addi	s1,a0,88
    800038ce:	45850913          	addi	s2,a0,1112
    800038d2:	a021                	j	800038da <itrunc+0x7a>
    800038d4:	0491                	addi	s1,s1,4
    800038d6:	01248b63          	beq	s1,s2,800038ec <itrunc+0x8c>
      if(a[j])
    800038da:	408c                	lw	a1,0(s1)
    800038dc:	dde5                	beqz	a1,800038d4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800038de:	0009a503          	lw	a0,0(s3)
    800038e2:	00000097          	auipc	ra,0x0
    800038e6:	8b4080e7          	jalr	-1868(ra) # 80003196 <bfree>
    800038ea:	b7ed                	j	800038d4 <itrunc+0x74>
    brelse(bp);
    800038ec:	8552                	mv	a0,s4
    800038ee:	fffff097          	auipc	ra,0xfffff
    800038f2:	792080e7          	jalr	1938(ra) # 80003080 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038f6:	0809a583          	lw	a1,128(s3)
    800038fa:	0009a503          	lw	a0,0(s3)
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	898080e7          	jalr	-1896(ra) # 80003196 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003906:	0809a023          	sw	zero,128(s3)
    8000390a:	bf51                	j	8000389e <itrunc+0x3e>

000000008000390c <iput>:
{
    8000390c:	1101                	addi	sp,sp,-32
    8000390e:	ec06                	sd	ra,24(sp)
    80003910:	e822                	sd	s0,16(sp)
    80003912:	e426                	sd	s1,8(sp)
    80003914:	e04a                	sd	s2,0(sp)
    80003916:	1000                	addi	s0,sp,32
    80003918:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000391a:	0001c517          	auipc	a0,0x1c
    8000391e:	74650513          	addi	a0,a0,1862 # 80020060 <icache>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	334080e7          	jalr	820(ra) # 80000c56 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000392a:	4498                	lw	a4,8(s1)
    8000392c:	4785                	li	a5,1
    8000392e:	02f70363          	beq	a4,a5,80003954 <iput+0x48>
  ip->ref--;
    80003932:	449c                	lw	a5,8(s1)
    80003934:	37fd                	addiw	a5,a5,-1
    80003936:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003938:	0001c517          	auipc	a0,0x1c
    8000393c:	72850513          	addi	a0,a0,1832 # 80020060 <icache>
    80003940:	ffffd097          	auipc	ra,0xffffd
    80003944:	3ca080e7          	jalr	970(ra) # 80000d0a <release>
}
    80003948:	60e2                	ld	ra,24(sp)
    8000394a:	6442                	ld	s0,16(sp)
    8000394c:	64a2                	ld	s1,8(sp)
    8000394e:	6902                	ld	s2,0(sp)
    80003950:	6105                	addi	sp,sp,32
    80003952:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003954:	40bc                	lw	a5,64(s1)
    80003956:	dff1                	beqz	a5,80003932 <iput+0x26>
    80003958:	04a49783          	lh	a5,74(s1)
    8000395c:	fbf9                	bnez	a5,80003932 <iput+0x26>
    acquiresleep(&ip->lock);
    8000395e:	01048913          	addi	s2,s1,16
    80003962:	854a                	mv	a0,s2
    80003964:	00001097          	auipc	ra,0x1
    80003968:	aa8080e7          	jalr	-1368(ra) # 8000440c <acquiresleep>
    release(&icache.lock);
    8000396c:	0001c517          	auipc	a0,0x1c
    80003970:	6f450513          	addi	a0,a0,1780 # 80020060 <icache>
    80003974:	ffffd097          	auipc	ra,0xffffd
    80003978:	396080e7          	jalr	918(ra) # 80000d0a <release>
    itrunc(ip);
    8000397c:	8526                	mv	a0,s1
    8000397e:	00000097          	auipc	ra,0x0
    80003982:	ee2080e7          	jalr	-286(ra) # 80003860 <itrunc>
    ip->type = 0;
    80003986:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000398a:	8526                	mv	a0,s1
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	cfc080e7          	jalr	-772(ra) # 80003688 <iupdate>
    ip->valid = 0;
    80003994:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003998:	854a                	mv	a0,s2
    8000399a:	00001097          	auipc	ra,0x1
    8000399e:	ac8080e7          	jalr	-1336(ra) # 80004462 <releasesleep>
    acquire(&icache.lock);
    800039a2:	0001c517          	auipc	a0,0x1c
    800039a6:	6be50513          	addi	a0,a0,1726 # 80020060 <icache>
    800039aa:	ffffd097          	auipc	ra,0xffffd
    800039ae:	2ac080e7          	jalr	684(ra) # 80000c56 <acquire>
    800039b2:	b741                	j	80003932 <iput+0x26>

00000000800039b4 <iunlockput>:
{
    800039b4:	1101                	addi	sp,sp,-32
    800039b6:	ec06                	sd	ra,24(sp)
    800039b8:	e822                	sd	s0,16(sp)
    800039ba:	e426                	sd	s1,8(sp)
    800039bc:	1000                	addi	s0,sp,32
    800039be:	84aa                	mv	s1,a0
  iunlock(ip);
    800039c0:	00000097          	auipc	ra,0x0
    800039c4:	e54080e7          	jalr	-428(ra) # 80003814 <iunlock>
  iput(ip);
    800039c8:	8526                	mv	a0,s1
    800039ca:	00000097          	auipc	ra,0x0
    800039ce:	f42080e7          	jalr	-190(ra) # 8000390c <iput>
}
    800039d2:	60e2                	ld	ra,24(sp)
    800039d4:	6442                	ld	s0,16(sp)
    800039d6:	64a2                	ld	s1,8(sp)
    800039d8:	6105                	addi	sp,sp,32
    800039da:	8082                	ret

00000000800039dc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039dc:	1141                	addi	sp,sp,-16
    800039de:	e422                	sd	s0,8(sp)
    800039e0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039e2:	411c                	lw	a5,0(a0)
    800039e4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039e6:	415c                	lw	a5,4(a0)
    800039e8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039ea:	04451783          	lh	a5,68(a0)
    800039ee:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039f2:	04a51783          	lh	a5,74(a0)
    800039f6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039fa:	04c56783          	lwu	a5,76(a0)
    800039fe:	e99c                	sd	a5,16(a1)
}
    80003a00:	6422                	ld	s0,8(sp)
    80003a02:	0141                	addi	sp,sp,16
    80003a04:	8082                	ret

0000000080003a06 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a06:	457c                	lw	a5,76(a0)
    80003a08:	0ed7e863          	bltu	a5,a3,80003af8 <readi+0xf2>
{
    80003a0c:	7159                	addi	sp,sp,-112
    80003a0e:	f486                	sd	ra,104(sp)
    80003a10:	f0a2                	sd	s0,96(sp)
    80003a12:	eca6                	sd	s1,88(sp)
    80003a14:	e8ca                	sd	s2,80(sp)
    80003a16:	e4ce                	sd	s3,72(sp)
    80003a18:	e0d2                	sd	s4,64(sp)
    80003a1a:	fc56                	sd	s5,56(sp)
    80003a1c:	f85a                	sd	s6,48(sp)
    80003a1e:	f45e                	sd	s7,40(sp)
    80003a20:	f062                	sd	s8,32(sp)
    80003a22:	ec66                	sd	s9,24(sp)
    80003a24:	e86a                	sd	s10,16(sp)
    80003a26:	e46e                	sd	s11,8(sp)
    80003a28:	1880                	addi	s0,sp,112
    80003a2a:	8baa                	mv	s7,a0
    80003a2c:	8c2e                	mv	s8,a1
    80003a2e:	8ab2                	mv	s5,a2
    80003a30:	84b6                	mv	s1,a3
    80003a32:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a34:	9f35                	addw	a4,a4,a3
    return 0;
    80003a36:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a38:	08d76f63          	bltu	a4,a3,80003ad6 <readi+0xd0>
  if(off + n > ip->size)
    80003a3c:	00e7f463          	bgeu	a5,a4,80003a44 <readi+0x3e>
    n = ip->size - off;
    80003a40:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a44:	0a0b0863          	beqz	s6,80003af4 <readi+0xee>
    80003a48:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a4a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a4e:	5cfd                	li	s9,-1
    80003a50:	a82d                	j	80003a8a <readi+0x84>
    80003a52:	020a1d93          	slli	s11,s4,0x20
    80003a56:	020ddd93          	srli	s11,s11,0x20
    80003a5a:	05890793          	addi	a5,s2,88
    80003a5e:	86ee                	mv	a3,s11
    80003a60:	963e                	add	a2,a2,a5
    80003a62:	85d6                	mv	a1,s5
    80003a64:	8562                	mv	a0,s8
    80003a66:	fffff097          	auipc	ra,0xfffff
    80003a6a:	a32080e7          	jalr	-1486(ra) # 80002498 <either_copyout>
    80003a6e:	05950d63          	beq	a0,s9,80003ac8 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003a72:	854a                	mv	a0,s2
    80003a74:	fffff097          	auipc	ra,0xfffff
    80003a78:	60c080e7          	jalr	1548(ra) # 80003080 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a7c:	013a09bb          	addw	s3,s4,s3
    80003a80:	009a04bb          	addw	s1,s4,s1
    80003a84:	9aee                	add	s5,s5,s11
    80003a86:	0569f663          	bgeu	s3,s6,80003ad2 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a8a:	000ba903          	lw	s2,0(s7)
    80003a8e:	00a4d59b          	srliw	a1,s1,0xa
    80003a92:	855e                	mv	a0,s7
    80003a94:	00000097          	auipc	ra,0x0
    80003a98:	8b0080e7          	jalr	-1872(ra) # 80003344 <bmap>
    80003a9c:	0005059b          	sext.w	a1,a0
    80003aa0:	854a                	mv	a0,s2
    80003aa2:	fffff097          	auipc	ra,0xfffff
    80003aa6:	4ae080e7          	jalr	1198(ra) # 80002f50 <bread>
    80003aaa:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aac:	3ff4f613          	andi	a2,s1,1023
    80003ab0:	40cd07bb          	subw	a5,s10,a2
    80003ab4:	413b073b          	subw	a4,s6,s3
    80003ab8:	8a3e                	mv	s4,a5
    80003aba:	2781                	sext.w	a5,a5
    80003abc:	0007069b          	sext.w	a3,a4
    80003ac0:	f8f6f9e3          	bgeu	a3,a5,80003a52 <readi+0x4c>
    80003ac4:	8a3a                	mv	s4,a4
    80003ac6:	b771                	j	80003a52 <readi+0x4c>
      brelse(bp);
    80003ac8:	854a                	mv	a0,s2
    80003aca:	fffff097          	auipc	ra,0xfffff
    80003ace:	5b6080e7          	jalr	1462(ra) # 80003080 <brelse>
  }
  return tot;
    80003ad2:	0009851b          	sext.w	a0,s3
}
    80003ad6:	70a6                	ld	ra,104(sp)
    80003ad8:	7406                	ld	s0,96(sp)
    80003ada:	64e6                	ld	s1,88(sp)
    80003adc:	6946                	ld	s2,80(sp)
    80003ade:	69a6                	ld	s3,72(sp)
    80003ae0:	6a06                	ld	s4,64(sp)
    80003ae2:	7ae2                	ld	s5,56(sp)
    80003ae4:	7b42                	ld	s6,48(sp)
    80003ae6:	7ba2                	ld	s7,40(sp)
    80003ae8:	7c02                	ld	s8,32(sp)
    80003aea:	6ce2                	ld	s9,24(sp)
    80003aec:	6d42                	ld	s10,16(sp)
    80003aee:	6da2                	ld	s11,8(sp)
    80003af0:	6165                	addi	sp,sp,112
    80003af2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003af4:	89da                	mv	s3,s6
    80003af6:	bff1                	j	80003ad2 <readi+0xcc>
    return 0;
    80003af8:	4501                	li	a0,0
}
    80003afa:	8082                	ret

0000000080003afc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003afc:	457c                	lw	a5,76(a0)
    80003afe:	10d7e663          	bltu	a5,a3,80003c0a <writei+0x10e>
{
    80003b02:	7159                	addi	sp,sp,-112
    80003b04:	f486                	sd	ra,104(sp)
    80003b06:	f0a2                	sd	s0,96(sp)
    80003b08:	eca6                	sd	s1,88(sp)
    80003b0a:	e8ca                	sd	s2,80(sp)
    80003b0c:	e4ce                	sd	s3,72(sp)
    80003b0e:	e0d2                	sd	s4,64(sp)
    80003b10:	fc56                	sd	s5,56(sp)
    80003b12:	f85a                	sd	s6,48(sp)
    80003b14:	f45e                	sd	s7,40(sp)
    80003b16:	f062                	sd	s8,32(sp)
    80003b18:	ec66                	sd	s9,24(sp)
    80003b1a:	e86a                	sd	s10,16(sp)
    80003b1c:	e46e                	sd	s11,8(sp)
    80003b1e:	1880                	addi	s0,sp,112
    80003b20:	8baa                	mv	s7,a0
    80003b22:	8c2e                	mv	s8,a1
    80003b24:	8ab2                	mv	s5,a2
    80003b26:	8936                	mv	s2,a3
    80003b28:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b2a:	00e687bb          	addw	a5,a3,a4
    80003b2e:	0ed7e063          	bltu	a5,a3,80003c0e <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b32:	00043737          	lui	a4,0x43
    80003b36:	0cf76e63          	bltu	a4,a5,80003c12 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b3a:	0a0b0763          	beqz	s6,80003be8 <writei+0xec>
    80003b3e:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b40:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b44:	5cfd                	li	s9,-1
    80003b46:	a091                	j	80003b8a <writei+0x8e>
    80003b48:	02099d93          	slli	s11,s3,0x20
    80003b4c:	020ddd93          	srli	s11,s11,0x20
    80003b50:	05848793          	addi	a5,s1,88
    80003b54:	86ee                	mv	a3,s11
    80003b56:	8656                	mv	a2,s5
    80003b58:	85e2                	mv	a1,s8
    80003b5a:	953e                	add	a0,a0,a5
    80003b5c:	fffff097          	auipc	ra,0xfffff
    80003b60:	992080e7          	jalr	-1646(ra) # 800024ee <either_copyin>
    80003b64:	07950263          	beq	a0,s9,80003bc8 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b68:	8526                	mv	a0,s1
    80003b6a:	00000097          	auipc	ra,0x0
    80003b6e:	77a080e7          	jalr	1914(ra) # 800042e4 <log_write>
    brelse(bp);
    80003b72:	8526                	mv	a0,s1
    80003b74:	fffff097          	auipc	ra,0xfffff
    80003b78:	50c080e7          	jalr	1292(ra) # 80003080 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b7c:	01498a3b          	addw	s4,s3,s4
    80003b80:	0129893b          	addw	s2,s3,s2
    80003b84:	9aee                	add	s5,s5,s11
    80003b86:	056a7663          	bgeu	s4,s6,80003bd2 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b8a:	000ba483          	lw	s1,0(s7)
    80003b8e:	00a9559b          	srliw	a1,s2,0xa
    80003b92:	855e                	mv	a0,s7
    80003b94:	fffff097          	auipc	ra,0xfffff
    80003b98:	7b0080e7          	jalr	1968(ra) # 80003344 <bmap>
    80003b9c:	0005059b          	sext.w	a1,a0
    80003ba0:	8526                	mv	a0,s1
    80003ba2:	fffff097          	auipc	ra,0xfffff
    80003ba6:	3ae080e7          	jalr	942(ra) # 80002f50 <bread>
    80003baa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bac:	3ff97513          	andi	a0,s2,1023
    80003bb0:	40ad07bb          	subw	a5,s10,a0
    80003bb4:	414b073b          	subw	a4,s6,s4
    80003bb8:	89be                	mv	s3,a5
    80003bba:	2781                	sext.w	a5,a5
    80003bbc:	0007069b          	sext.w	a3,a4
    80003bc0:	f8f6f4e3          	bgeu	a3,a5,80003b48 <writei+0x4c>
    80003bc4:	89ba                	mv	s3,a4
    80003bc6:	b749                	j	80003b48 <writei+0x4c>
      brelse(bp);
    80003bc8:	8526                	mv	a0,s1
    80003bca:	fffff097          	auipc	ra,0xfffff
    80003bce:	4b6080e7          	jalr	1206(ra) # 80003080 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003bd2:	04cba783          	lw	a5,76(s7)
    80003bd6:	0127f463          	bgeu	a5,s2,80003bde <writei+0xe2>
      ip->size = off;
    80003bda:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003bde:	855e                	mv	a0,s7
    80003be0:	00000097          	auipc	ra,0x0
    80003be4:	aa8080e7          	jalr	-1368(ra) # 80003688 <iupdate>
  }

  return n;
    80003be8:	000b051b          	sext.w	a0,s6
}
    80003bec:	70a6                	ld	ra,104(sp)
    80003bee:	7406                	ld	s0,96(sp)
    80003bf0:	64e6                	ld	s1,88(sp)
    80003bf2:	6946                	ld	s2,80(sp)
    80003bf4:	69a6                	ld	s3,72(sp)
    80003bf6:	6a06                	ld	s4,64(sp)
    80003bf8:	7ae2                	ld	s5,56(sp)
    80003bfa:	7b42                	ld	s6,48(sp)
    80003bfc:	7ba2                	ld	s7,40(sp)
    80003bfe:	7c02                	ld	s8,32(sp)
    80003c00:	6ce2                	ld	s9,24(sp)
    80003c02:	6d42                	ld	s10,16(sp)
    80003c04:	6da2                	ld	s11,8(sp)
    80003c06:	6165                	addi	sp,sp,112
    80003c08:	8082                	ret
    return -1;
    80003c0a:	557d                	li	a0,-1
}
    80003c0c:	8082                	ret
    return -1;
    80003c0e:	557d                	li	a0,-1
    80003c10:	bff1                	j	80003bec <writei+0xf0>
    return -1;
    80003c12:	557d                	li	a0,-1
    80003c14:	bfe1                	j	80003bec <writei+0xf0>

0000000080003c16 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c16:	1141                	addi	sp,sp,-16
    80003c18:	e406                	sd	ra,8(sp)
    80003c1a:	e022                	sd	s0,0(sp)
    80003c1c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c1e:	4639                	li	a2,14
    80003c20:	ffffd097          	auipc	ra,0xffffd
    80003c24:	20a080e7          	jalr	522(ra) # 80000e2a <strncmp>
}
    80003c28:	60a2                	ld	ra,8(sp)
    80003c2a:	6402                	ld	s0,0(sp)
    80003c2c:	0141                	addi	sp,sp,16
    80003c2e:	8082                	ret

0000000080003c30 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c30:	7139                	addi	sp,sp,-64
    80003c32:	fc06                	sd	ra,56(sp)
    80003c34:	f822                	sd	s0,48(sp)
    80003c36:	f426                	sd	s1,40(sp)
    80003c38:	f04a                	sd	s2,32(sp)
    80003c3a:	ec4e                	sd	s3,24(sp)
    80003c3c:	e852                	sd	s4,16(sp)
    80003c3e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c40:	04451703          	lh	a4,68(a0)
    80003c44:	4785                	li	a5,1
    80003c46:	00f71a63          	bne	a4,a5,80003c5a <dirlookup+0x2a>
    80003c4a:	892a                	mv	s2,a0
    80003c4c:	89ae                	mv	s3,a1
    80003c4e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c50:	457c                	lw	a5,76(a0)
    80003c52:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c54:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c56:	e79d                	bnez	a5,80003c84 <dirlookup+0x54>
    80003c58:	a8a5                	j	80003cd0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c5a:	00005517          	auipc	a0,0x5
    80003c5e:	a4650513          	addi	a0,a0,-1466 # 800086a0 <syscalls+0x1b0>
    80003c62:	ffffd097          	auipc	ra,0xffffd
    80003c66:	8ee080e7          	jalr	-1810(ra) # 80000550 <panic>
      panic("dirlookup read");
    80003c6a:	00005517          	auipc	a0,0x5
    80003c6e:	a4e50513          	addi	a0,a0,-1458 # 800086b8 <syscalls+0x1c8>
    80003c72:	ffffd097          	auipc	ra,0xffffd
    80003c76:	8de080e7          	jalr	-1826(ra) # 80000550 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c7a:	24c1                	addiw	s1,s1,16
    80003c7c:	04c92783          	lw	a5,76(s2)
    80003c80:	04f4f763          	bgeu	s1,a5,80003cce <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c84:	4741                	li	a4,16
    80003c86:	86a6                	mv	a3,s1
    80003c88:	fc040613          	addi	a2,s0,-64
    80003c8c:	4581                	li	a1,0
    80003c8e:	854a                	mv	a0,s2
    80003c90:	00000097          	auipc	ra,0x0
    80003c94:	d76080e7          	jalr	-650(ra) # 80003a06 <readi>
    80003c98:	47c1                	li	a5,16
    80003c9a:	fcf518e3          	bne	a0,a5,80003c6a <dirlookup+0x3a>
    if(de.inum == 0)
    80003c9e:	fc045783          	lhu	a5,-64(s0)
    80003ca2:	dfe1                	beqz	a5,80003c7a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ca4:	fc240593          	addi	a1,s0,-62
    80003ca8:	854e                	mv	a0,s3
    80003caa:	00000097          	auipc	ra,0x0
    80003cae:	f6c080e7          	jalr	-148(ra) # 80003c16 <namecmp>
    80003cb2:	f561                	bnez	a0,80003c7a <dirlookup+0x4a>
      if(poff)
    80003cb4:	000a0463          	beqz	s4,80003cbc <dirlookup+0x8c>
        *poff = off;
    80003cb8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cbc:	fc045583          	lhu	a1,-64(s0)
    80003cc0:	00092503          	lw	a0,0(s2)
    80003cc4:	fffff097          	auipc	ra,0xfffff
    80003cc8:	75a080e7          	jalr	1882(ra) # 8000341e <iget>
    80003ccc:	a011                	j	80003cd0 <dirlookup+0xa0>
  return 0;
    80003cce:	4501                	li	a0,0
}
    80003cd0:	70e2                	ld	ra,56(sp)
    80003cd2:	7442                	ld	s0,48(sp)
    80003cd4:	74a2                	ld	s1,40(sp)
    80003cd6:	7902                	ld	s2,32(sp)
    80003cd8:	69e2                	ld	s3,24(sp)
    80003cda:	6a42                	ld	s4,16(sp)
    80003cdc:	6121                	addi	sp,sp,64
    80003cde:	8082                	ret

0000000080003ce0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ce0:	711d                	addi	sp,sp,-96
    80003ce2:	ec86                	sd	ra,88(sp)
    80003ce4:	e8a2                	sd	s0,80(sp)
    80003ce6:	e4a6                	sd	s1,72(sp)
    80003ce8:	e0ca                	sd	s2,64(sp)
    80003cea:	fc4e                	sd	s3,56(sp)
    80003cec:	f852                	sd	s4,48(sp)
    80003cee:	f456                	sd	s5,40(sp)
    80003cf0:	f05a                	sd	s6,32(sp)
    80003cf2:	ec5e                	sd	s7,24(sp)
    80003cf4:	e862                	sd	s8,16(sp)
    80003cf6:	e466                	sd	s9,8(sp)
    80003cf8:	1080                	addi	s0,sp,96
    80003cfa:	84aa                	mv	s1,a0
    80003cfc:	8aae                	mv	s5,a1
    80003cfe:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d00:	00054703          	lbu	a4,0(a0)
    80003d04:	02f00793          	li	a5,47
    80003d08:	02f70363          	beq	a4,a5,80003d2e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d0c:	ffffe097          	auipc	ra,0xffffe
    80003d10:	d16080e7          	jalr	-746(ra) # 80001a22 <myproc>
    80003d14:	15053503          	ld	a0,336(a0)
    80003d18:	00000097          	auipc	ra,0x0
    80003d1c:	9fc080e7          	jalr	-1540(ra) # 80003714 <idup>
    80003d20:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d22:	02f00913          	li	s2,47
  len = path - s;
    80003d26:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003d28:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d2a:	4b85                	li	s7,1
    80003d2c:	a865                	j	80003de4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003d2e:	4585                	li	a1,1
    80003d30:	4505                	li	a0,1
    80003d32:	fffff097          	auipc	ra,0xfffff
    80003d36:	6ec080e7          	jalr	1772(ra) # 8000341e <iget>
    80003d3a:	89aa                	mv	s3,a0
    80003d3c:	b7dd                	j	80003d22 <namex+0x42>
      iunlockput(ip);
    80003d3e:	854e                	mv	a0,s3
    80003d40:	00000097          	auipc	ra,0x0
    80003d44:	c74080e7          	jalr	-908(ra) # 800039b4 <iunlockput>
      return 0;
    80003d48:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d4a:	854e                	mv	a0,s3
    80003d4c:	60e6                	ld	ra,88(sp)
    80003d4e:	6446                	ld	s0,80(sp)
    80003d50:	64a6                	ld	s1,72(sp)
    80003d52:	6906                	ld	s2,64(sp)
    80003d54:	79e2                	ld	s3,56(sp)
    80003d56:	7a42                	ld	s4,48(sp)
    80003d58:	7aa2                	ld	s5,40(sp)
    80003d5a:	7b02                	ld	s6,32(sp)
    80003d5c:	6be2                	ld	s7,24(sp)
    80003d5e:	6c42                	ld	s8,16(sp)
    80003d60:	6ca2                	ld	s9,8(sp)
    80003d62:	6125                	addi	sp,sp,96
    80003d64:	8082                	ret
      iunlock(ip);
    80003d66:	854e                	mv	a0,s3
    80003d68:	00000097          	auipc	ra,0x0
    80003d6c:	aac080e7          	jalr	-1364(ra) # 80003814 <iunlock>
      return ip;
    80003d70:	bfe9                	j	80003d4a <namex+0x6a>
      iunlockput(ip);
    80003d72:	854e                	mv	a0,s3
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	c40080e7          	jalr	-960(ra) # 800039b4 <iunlockput>
      return 0;
    80003d7c:	89e6                	mv	s3,s9
    80003d7e:	b7f1                	j	80003d4a <namex+0x6a>
  len = path - s;
    80003d80:	40b48633          	sub	a2,s1,a1
    80003d84:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d88:	099c5463          	bge	s8,s9,80003e10 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d8c:	4639                	li	a2,14
    80003d8e:	8552                	mv	a0,s4
    80003d90:	ffffd097          	auipc	ra,0xffffd
    80003d94:	01e080e7          	jalr	30(ra) # 80000dae <memmove>
  while(*path == '/')
    80003d98:	0004c783          	lbu	a5,0(s1)
    80003d9c:	01279763          	bne	a5,s2,80003daa <namex+0xca>
    path++;
    80003da0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003da2:	0004c783          	lbu	a5,0(s1)
    80003da6:	ff278de3          	beq	a5,s2,80003da0 <namex+0xc0>
    ilock(ip);
    80003daa:	854e                	mv	a0,s3
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	9a6080e7          	jalr	-1626(ra) # 80003752 <ilock>
    if(ip->type != T_DIR){
    80003db4:	04499783          	lh	a5,68(s3)
    80003db8:	f97793e3          	bne	a5,s7,80003d3e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003dbc:	000a8563          	beqz	s5,80003dc6 <namex+0xe6>
    80003dc0:	0004c783          	lbu	a5,0(s1)
    80003dc4:	d3cd                	beqz	a5,80003d66 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dc6:	865a                	mv	a2,s6
    80003dc8:	85d2                	mv	a1,s4
    80003dca:	854e                	mv	a0,s3
    80003dcc:	00000097          	auipc	ra,0x0
    80003dd0:	e64080e7          	jalr	-412(ra) # 80003c30 <dirlookup>
    80003dd4:	8caa                	mv	s9,a0
    80003dd6:	dd51                	beqz	a0,80003d72 <namex+0x92>
    iunlockput(ip);
    80003dd8:	854e                	mv	a0,s3
    80003dda:	00000097          	auipc	ra,0x0
    80003dde:	bda080e7          	jalr	-1062(ra) # 800039b4 <iunlockput>
    ip = next;
    80003de2:	89e6                	mv	s3,s9
  while(*path == '/')
    80003de4:	0004c783          	lbu	a5,0(s1)
    80003de8:	05279763          	bne	a5,s2,80003e36 <namex+0x156>
    path++;
    80003dec:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dee:	0004c783          	lbu	a5,0(s1)
    80003df2:	ff278de3          	beq	a5,s2,80003dec <namex+0x10c>
  if(*path == 0)
    80003df6:	c79d                	beqz	a5,80003e24 <namex+0x144>
    path++;
    80003df8:	85a6                	mv	a1,s1
  len = path - s;
    80003dfa:	8cda                	mv	s9,s6
    80003dfc:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003dfe:	01278963          	beq	a5,s2,80003e10 <namex+0x130>
    80003e02:	dfbd                	beqz	a5,80003d80 <namex+0xa0>
    path++;
    80003e04:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003e06:	0004c783          	lbu	a5,0(s1)
    80003e0a:	ff279ce3          	bne	a5,s2,80003e02 <namex+0x122>
    80003e0e:	bf8d                	j	80003d80 <namex+0xa0>
    memmove(name, s, len);
    80003e10:	2601                	sext.w	a2,a2
    80003e12:	8552                	mv	a0,s4
    80003e14:	ffffd097          	auipc	ra,0xffffd
    80003e18:	f9a080e7          	jalr	-102(ra) # 80000dae <memmove>
    name[len] = 0;
    80003e1c:	9cd2                	add	s9,s9,s4
    80003e1e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e22:	bf9d                	j	80003d98 <namex+0xb8>
  if(nameiparent){
    80003e24:	f20a83e3          	beqz	s5,80003d4a <namex+0x6a>
    iput(ip);
    80003e28:	854e                	mv	a0,s3
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	ae2080e7          	jalr	-1310(ra) # 8000390c <iput>
    return 0;
    80003e32:	4981                	li	s3,0
    80003e34:	bf19                	j	80003d4a <namex+0x6a>
  if(*path == 0)
    80003e36:	d7fd                	beqz	a5,80003e24 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e38:	0004c783          	lbu	a5,0(s1)
    80003e3c:	85a6                	mv	a1,s1
    80003e3e:	b7d1                	j	80003e02 <namex+0x122>

0000000080003e40 <dirlink>:
{
    80003e40:	7139                	addi	sp,sp,-64
    80003e42:	fc06                	sd	ra,56(sp)
    80003e44:	f822                	sd	s0,48(sp)
    80003e46:	f426                	sd	s1,40(sp)
    80003e48:	f04a                	sd	s2,32(sp)
    80003e4a:	ec4e                	sd	s3,24(sp)
    80003e4c:	e852                	sd	s4,16(sp)
    80003e4e:	0080                	addi	s0,sp,64
    80003e50:	892a                	mv	s2,a0
    80003e52:	8a2e                	mv	s4,a1
    80003e54:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e56:	4601                	li	a2,0
    80003e58:	00000097          	auipc	ra,0x0
    80003e5c:	dd8080e7          	jalr	-552(ra) # 80003c30 <dirlookup>
    80003e60:	e93d                	bnez	a0,80003ed6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e62:	04c92483          	lw	s1,76(s2)
    80003e66:	c49d                	beqz	s1,80003e94 <dirlink+0x54>
    80003e68:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e6a:	4741                	li	a4,16
    80003e6c:	86a6                	mv	a3,s1
    80003e6e:	fc040613          	addi	a2,s0,-64
    80003e72:	4581                	li	a1,0
    80003e74:	854a                	mv	a0,s2
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	b90080e7          	jalr	-1136(ra) # 80003a06 <readi>
    80003e7e:	47c1                	li	a5,16
    80003e80:	06f51163          	bne	a0,a5,80003ee2 <dirlink+0xa2>
    if(de.inum == 0)
    80003e84:	fc045783          	lhu	a5,-64(s0)
    80003e88:	c791                	beqz	a5,80003e94 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e8a:	24c1                	addiw	s1,s1,16
    80003e8c:	04c92783          	lw	a5,76(s2)
    80003e90:	fcf4ede3          	bltu	s1,a5,80003e6a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e94:	4639                	li	a2,14
    80003e96:	85d2                	mv	a1,s4
    80003e98:	fc240513          	addi	a0,s0,-62
    80003e9c:	ffffd097          	auipc	ra,0xffffd
    80003ea0:	fca080e7          	jalr	-54(ra) # 80000e66 <strncpy>
  de.inum = inum;
    80003ea4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ea8:	4741                	li	a4,16
    80003eaa:	86a6                	mv	a3,s1
    80003eac:	fc040613          	addi	a2,s0,-64
    80003eb0:	4581                	li	a1,0
    80003eb2:	854a                	mv	a0,s2
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	c48080e7          	jalr	-952(ra) # 80003afc <writei>
    80003ebc:	872a                	mv	a4,a0
    80003ebe:	47c1                	li	a5,16
  return 0;
    80003ec0:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ec2:	02f71863          	bne	a4,a5,80003ef2 <dirlink+0xb2>
}
    80003ec6:	70e2                	ld	ra,56(sp)
    80003ec8:	7442                	ld	s0,48(sp)
    80003eca:	74a2                	ld	s1,40(sp)
    80003ecc:	7902                	ld	s2,32(sp)
    80003ece:	69e2                	ld	s3,24(sp)
    80003ed0:	6a42                	ld	s4,16(sp)
    80003ed2:	6121                	addi	sp,sp,64
    80003ed4:	8082                	ret
    iput(ip);
    80003ed6:	00000097          	auipc	ra,0x0
    80003eda:	a36080e7          	jalr	-1482(ra) # 8000390c <iput>
    return -1;
    80003ede:	557d                	li	a0,-1
    80003ee0:	b7dd                	j	80003ec6 <dirlink+0x86>
      panic("dirlink read");
    80003ee2:	00004517          	auipc	a0,0x4
    80003ee6:	7e650513          	addi	a0,a0,2022 # 800086c8 <syscalls+0x1d8>
    80003eea:	ffffc097          	auipc	ra,0xffffc
    80003eee:	666080e7          	jalr	1638(ra) # 80000550 <panic>
    panic("dirlink");
    80003ef2:	00005517          	auipc	a0,0x5
    80003ef6:	8ee50513          	addi	a0,a0,-1810 # 800087e0 <syscalls+0x2f0>
    80003efa:	ffffc097          	auipc	ra,0xffffc
    80003efe:	656080e7          	jalr	1622(ra) # 80000550 <panic>

0000000080003f02 <namei>:

struct inode*
namei(char *path)
{
    80003f02:	1101                	addi	sp,sp,-32
    80003f04:	ec06                	sd	ra,24(sp)
    80003f06:	e822                	sd	s0,16(sp)
    80003f08:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f0a:	fe040613          	addi	a2,s0,-32
    80003f0e:	4581                	li	a1,0
    80003f10:	00000097          	auipc	ra,0x0
    80003f14:	dd0080e7          	jalr	-560(ra) # 80003ce0 <namex>
}
    80003f18:	60e2                	ld	ra,24(sp)
    80003f1a:	6442                	ld	s0,16(sp)
    80003f1c:	6105                	addi	sp,sp,32
    80003f1e:	8082                	ret

0000000080003f20 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f20:	1141                	addi	sp,sp,-16
    80003f22:	e406                	sd	ra,8(sp)
    80003f24:	e022                	sd	s0,0(sp)
    80003f26:	0800                	addi	s0,sp,16
    80003f28:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f2a:	4585                	li	a1,1
    80003f2c:	00000097          	auipc	ra,0x0
    80003f30:	db4080e7          	jalr	-588(ra) # 80003ce0 <namex>
}
    80003f34:	60a2                	ld	ra,8(sp)
    80003f36:	6402                	ld	s0,0(sp)
    80003f38:	0141                	addi	sp,sp,16
    80003f3a:	8082                	ret

0000000080003f3c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f3c:	1101                	addi	sp,sp,-32
    80003f3e:	ec06                	sd	ra,24(sp)
    80003f40:	e822                	sd	s0,16(sp)
    80003f42:	e426                	sd	s1,8(sp)
    80003f44:	e04a                	sd	s2,0(sp)
    80003f46:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f48:	0001e917          	auipc	s2,0x1e
    80003f4c:	bc090913          	addi	s2,s2,-1088 # 80021b08 <log>
    80003f50:	01892583          	lw	a1,24(s2)
    80003f54:	02892503          	lw	a0,40(s2)
    80003f58:	fffff097          	auipc	ra,0xfffff
    80003f5c:	ff8080e7          	jalr	-8(ra) # 80002f50 <bread>
    80003f60:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f62:	02c92683          	lw	a3,44(s2)
    80003f66:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f68:	02d05763          	blez	a3,80003f96 <write_head+0x5a>
    80003f6c:	0001e797          	auipc	a5,0x1e
    80003f70:	bcc78793          	addi	a5,a5,-1076 # 80021b38 <log+0x30>
    80003f74:	05c50713          	addi	a4,a0,92
    80003f78:	36fd                	addiw	a3,a3,-1
    80003f7a:	1682                	slli	a3,a3,0x20
    80003f7c:	9281                	srli	a3,a3,0x20
    80003f7e:	068a                	slli	a3,a3,0x2
    80003f80:	0001e617          	auipc	a2,0x1e
    80003f84:	bbc60613          	addi	a2,a2,-1092 # 80021b3c <log+0x34>
    80003f88:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f8a:	4390                	lw	a2,0(a5)
    80003f8c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f8e:	0791                	addi	a5,a5,4
    80003f90:	0711                	addi	a4,a4,4
    80003f92:	fed79ce3          	bne	a5,a3,80003f8a <write_head+0x4e>
  }
  bwrite(buf);
    80003f96:	8526                	mv	a0,s1
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	0aa080e7          	jalr	170(ra) # 80003042 <bwrite>
  brelse(buf);
    80003fa0:	8526                	mv	a0,s1
    80003fa2:	fffff097          	auipc	ra,0xfffff
    80003fa6:	0de080e7          	jalr	222(ra) # 80003080 <brelse>
}
    80003faa:	60e2                	ld	ra,24(sp)
    80003fac:	6442                	ld	s0,16(sp)
    80003fae:	64a2                	ld	s1,8(sp)
    80003fb0:	6902                	ld	s2,0(sp)
    80003fb2:	6105                	addi	sp,sp,32
    80003fb4:	8082                	ret

0000000080003fb6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fb6:	0001e797          	auipc	a5,0x1e
    80003fba:	b7e7a783          	lw	a5,-1154(a5) # 80021b34 <log+0x2c>
    80003fbe:	0af05663          	blez	a5,8000406a <install_trans+0xb4>
{
    80003fc2:	7139                	addi	sp,sp,-64
    80003fc4:	fc06                	sd	ra,56(sp)
    80003fc6:	f822                	sd	s0,48(sp)
    80003fc8:	f426                	sd	s1,40(sp)
    80003fca:	f04a                	sd	s2,32(sp)
    80003fcc:	ec4e                	sd	s3,24(sp)
    80003fce:	e852                	sd	s4,16(sp)
    80003fd0:	e456                	sd	s5,8(sp)
    80003fd2:	0080                	addi	s0,sp,64
    80003fd4:	0001ea97          	auipc	s5,0x1e
    80003fd8:	b64a8a93          	addi	s5,s5,-1180 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fdc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fde:	0001e997          	auipc	s3,0x1e
    80003fe2:	b2a98993          	addi	s3,s3,-1238 # 80021b08 <log>
    80003fe6:	0189a583          	lw	a1,24(s3)
    80003fea:	014585bb          	addw	a1,a1,s4
    80003fee:	2585                	addiw	a1,a1,1
    80003ff0:	0289a503          	lw	a0,40(s3)
    80003ff4:	fffff097          	auipc	ra,0xfffff
    80003ff8:	f5c080e7          	jalr	-164(ra) # 80002f50 <bread>
    80003ffc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ffe:	000aa583          	lw	a1,0(s5)
    80004002:	0289a503          	lw	a0,40(s3)
    80004006:	fffff097          	auipc	ra,0xfffff
    8000400a:	f4a080e7          	jalr	-182(ra) # 80002f50 <bread>
    8000400e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004010:	40000613          	li	a2,1024
    80004014:	05890593          	addi	a1,s2,88
    80004018:	05850513          	addi	a0,a0,88
    8000401c:	ffffd097          	auipc	ra,0xffffd
    80004020:	d92080e7          	jalr	-622(ra) # 80000dae <memmove>
    bwrite(dbuf);  // write dst to disk
    80004024:	8526                	mv	a0,s1
    80004026:	fffff097          	auipc	ra,0xfffff
    8000402a:	01c080e7          	jalr	28(ra) # 80003042 <bwrite>
    bunpin(dbuf);
    8000402e:	8526                	mv	a0,s1
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	12a080e7          	jalr	298(ra) # 8000315a <bunpin>
    brelse(lbuf);
    80004038:	854a                	mv	a0,s2
    8000403a:	fffff097          	auipc	ra,0xfffff
    8000403e:	046080e7          	jalr	70(ra) # 80003080 <brelse>
    brelse(dbuf);
    80004042:	8526                	mv	a0,s1
    80004044:	fffff097          	auipc	ra,0xfffff
    80004048:	03c080e7          	jalr	60(ra) # 80003080 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000404c:	2a05                	addiw	s4,s4,1
    8000404e:	0a91                	addi	s5,s5,4
    80004050:	02c9a783          	lw	a5,44(s3)
    80004054:	f8fa49e3          	blt	s4,a5,80003fe6 <install_trans+0x30>
}
    80004058:	70e2                	ld	ra,56(sp)
    8000405a:	7442                	ld	s0,48(sp)
    8000405c:	74a2                	ld	s1,40(sp)
    8000405e:	7902                	ld	s2,32(sp)
    80004060:	69e2                	ld	s3,24(sp)
    80004062:	6a42                	ld	s4,16(sp)
    80004064:	6aa2                	ld	s5,8(sp)
    80004066:	6121                	addi	sp,sp,64
    80004068:	8082                	ret
    8000406a:	8082                	ret

000000008000406c <initlog>:
{
    8000406c:	7179                	addi	sp,sp,-48
    8000406e:	f406                	sd	ra,40(sp)
    80004070:	f022                	sd	s0,32(sp)
    80004072:	ec26                	sd	s1,24(sp)
    80004074:	e84a                	sd	s2,16(sp)
    80004076:	e44e                	sd	s3,8(sp)
    80004078:	1800                	addi	s0,sp,48
    8000407a:	892a                	mv	s2,a0
    8000407c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000407e:	0001e497          	auipc	s1,0x1e
    80004082:	a8a48493          	addi	s1,s1,-1398 # 80021b08 <log>
    80004086:	00004597          	auipc	a1,0x4
    8000408a:	65258593          	addi	a1,a1,1618 # 800086d8 <syscalls+0x1e8>
    8000408e:	8526                	mv	a0,s1
    80004090:	ffffd097          	auipc	ra,0xffffd
    80004094:	b36080e7          	jalr	-1226(ra) # 80000bc6 <initlock>
  log.start = sb->logstart;
    80004098:	0149a583          	lw	a1,20(s3)
    8000409c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000409e:	0109a783          	lw	a5,16(s3)
    800040a2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040a4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040a8:	854a                	mv	a0,s2
    800040aa:	fffff097          	auipc	ra,0xfffff
    800040ae:	ea6080e7          	jalr	-346(ra) # 80002f50 <bread>
  log.lh.n = lh->n;
    800040b2:	4d34                	lw	a3,88(a0)
    800040b4:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040b6:	02d05563          	blez	a3,800040e0 <initlog+0x74>
    800040ba:	05c50793          	addi	a5,a0,92
    800040be:	0001e717          	auipc	a4,0x1e
    800040c2:	a7a70713          	addi	a4,a4,-1414 # 80021b38 <log+0x30>
    800040c6:	36fd                	addiw	a3,a3,-1
    800040c8:	1682                	slli	a3,a3,0x20
    800040ca:	9281                	srli	a3,a3,0x20
    800040cc:	068a                	slli	a3,a3,0x2
    800040ce:	06050613          	addi	a2,a0,96
    800040d2:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800040d4:	4390                	lw	a2,0(a5)
    800040d6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040d8:	0791                	addi	a5,a5,4
    800040da:	0711                	addi	a4,a4,4
    800040dc:	fed79ce3          	bne	a5,a3,800040d4 <initlog+0x68>
  brelse(buf);
    800040e0:	fffff097          	auipc	ra,0xfffff
    800040e4:	fa0080e7          	jalr	-96(ra) # 80003080 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	ece080e7          	jalr	-306(ra) # 80003fb6 <install_trans>
  log.lh.n = 0;
    800040f0:	0001e797          	auipc	a5,0x1e
    800040f4:	a407a223          	sw	zero,-1468(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    800040f8:	00000097          	auipc	ra,0x0
    800040fc:	e44080e7          	jalr	-444(ra) # 80003f3c <write_head>
}
    80004100:	70a2                	ld	ra,40(sp)
    80004102:	7402                	ld	s0,32(sp)
    80004104:	64e2                	ld	s1,24(sp)
    80004106:	6942                	ld	s2,16(sp)
    80004108:	69a2                	ld	s3,8(sp)
    8000410a:	6145                	addi	sp,sp,48
    8000410c:	8082                	ret

000000008000410e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000410e:	1101                	addi	sp,sp,-32
    80004110:	ec06                	sd	ra,24(sp)
    80004112:	e822                	sd	s0,16(sp)
    80004114:	e426                	sd	s1,8(sp)
    80004116:	e04a                	sd	s2,0(sp)
    80004118:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000411a:	0001e517          	auipc	a0,0x1e
    8000411e:	9ee50513          	addi	a0,a0,-1554 # 80021b08 <log>
    80004122:	ffffd097          	auipc	ra,0xffffd
    80004126:	b34080e7          	jalr	-1228(ra) # 80000c56 <acquire>
  while(1){
    if(log.committing){
    8000412a:	0001e497          	auipc	s1,0x1e
    8000412e:	9de48493          	addi	s1,s1,-1570 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004132:	4979                	li	s2,30
    80004134:	a039                	j	80004142 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004136:	85a6                	mv	a1,s1
    80004138:	8526                	mv	a0,s1
    8000413a:	ffffe097          	auipc	ra,0xffffe
    8000413e:	104080e7          	jalr	260(ra) # 8000223e <sleep>
    if(log.committing){
    80004142:	50dc                	lw	a5,36(s1)
    80004144:	fbed                	bnez	a5,80004136 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004146:	509c                	lw	a5,32(s1)
    80004148:	0017871b          	addiw	a4,a5,1
    8000414c:	0007069b          	sext.w	a3,a4
    80004150:	0027179b          	slliw	a5,a4,0x2
    80004154:	9fb9                	addw	a5,a5,a4
    80004156:	0017979b          	slliw	a5,a5,0x1
    8000415a:	54d8                	lw	a4,44(s1)
    8000415c:	9fb9                	addw	a5,a5,a4
    8000415e:	00f95963          	bge	s2,a5,80004170 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004162:	85a6                	mv	a1,s1
    80004164:	8526                	mv	a0,s1
    80004166:	ffffe097          	auipc	ra,0xffffe
    8000416a:	0d8080e7          	jalr	216(ra) # 8000223e <sleep>
    8000416e:	bfd1                	j	80004142 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004170:	0001e517          	auipc	a0,0x1e
    80004174:	99850513          	addi	a0,a0,-1640 # 80021b08 <log>
    80004178:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000417a:	ffffd097          	auipc	ra,0xffffd
    8000417e:	b90080e7          	jalr	-1136(ra) # 80000d0a <release>
      break;
    }
  }
}
    80004182:	60e2                	ld	ra,24(sp)
    80004184:	6442                	ld	s0,16(sp)
    80004186:	64a2                	ld	s1,8(sp)
    80004188:	6902                	ld	s2,0(sp)
    8000418a:	6105                	addi	sp,sp,32
    8000418c:	8082                	ret

000000008000418e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000418e:	7139                	addi	sp,sp,-64
    80004190:	fc06                	sd	ra,56(sp)
    80004192:	f822                	sd	s0,48(sp)
    80004194:	f426                	sd	s1,40(sp)
    80004196:	f04a                	sd	s2,32(sp)
    80004198:	ec4e                	sd	s3,24(sp)
    8000419a:	e852                	sd	s4,16(sp)
    8000419c:	e456                	sd	s5,8(sp)
    8000419e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041a0:	0001e497          	auipc	s1,0x1e
    800041a4:	96848493          	addi	s1,s1,-1688 # 80021b08 <log>
    800041a8:	8526                	mv	a0,s1
    800041aa:	ffffd097          	auipc	ra,0xffffd
    800041ae:	aac080e7          	jalr	-1364(ra) # 80000c56 <acquire>
  log.outstanding -= 1;
    800041b2:	509c                	lw	a5,32(s1)
    800041b4:	37fd                	addiw	a5,a5,-1
    800041b6:	0007891b          	sext.w	s2,a5
    800041ba:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041bc:	50dc                	lw	a5,36(s1)
    800041be:	e7b9                	bnez	a5,8000420c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041c0:	04091e63          	bnez	s2,8000421c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041c4:	0001e497          	auipc	s1,0x1e
    800041c8:	94448493          	addi	s1,s1,-1724 # 80021b08 <log>
    800041cc:	4785                	li	a5,1
    800041ce:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041d0:	8526                	mv	a0,s1
    800041d2:	ffffd097          	auipc	ra,0xffffd
    800041d6:	b38080e7          	jalr	-1224(ra) # 80000d0a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041da:	54dc                	lw	a5,44(s1)
    800041dc:	06f04763          	bgtz	a5,8000424a <end_op+0xbc>
    acquire(&log.lock);
    800041e0:	0001e497          	auipc	s1,0x1e
    800041e4:	92848493          	addi	s1,s1,-1752 # 80021b08 <log>
    800041e8:	8526                	mv	a0,s1
    800041ea:	ffffd097          	auipc	ra,0xffffd
    800041ee:	a6c080e7          	jalr	-1428(ra) # 80000c56 <acquire>
    log.committing = 0;
    800041f2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041f6:	8526                	mv	a0,s1
    800041f8:	ffffe097          	auipc	ra,0xffffe
    800041fc:	1c6080e7          	jalr	454(ra) # 800023be <wakeup>
    release(&log.lock);
    80004200:	8526                	mv	a0,s1
    80004202:	ffffd097          	auipc	ra,0xffffd
    80004206:	b08080e7          	jalr	-1272(ra) # 80000d0a <release>
}
    8000420a:	a03d                	j	80004238 <end_op+0xaa>
    panic("log.committing");
    8000420c:	00004517          	auipc	a0,0x4
    80004210:	4d450513          	addi	a0,a0,1236 # 800086e0 <syscalls+0x1f0>
    80004214:	ffffc097          	auipc	ra,0xffffc
    80004218:	33c080e7          	jalr	828(ra) # 80000550 <panic>
    wakeup(&log);
    8000421c:	0001e497          	auipc	s1,0x1e
    80004220:	8ec48493          	addi	s1,s1,-1812 # 80021b08 <log>
    80004224:	8526                	mv	a0,s1
    80004226:	ffffe097          	auipc	ra,0xffffe
    8000422a:	198080e7          	jalr	408(ra) # 800023be <wakeup>
  release(&log.lock);
    8000422e:	8526                	mv	a0,s1
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	ada080e7          	jalr	-1318(ra) # 80000d0a <release>
}
    80004238:	70e2                	ld	ra,56(sp)
    8000423a:	7442                	ld	s0,48(sp)
    8000423c:	74a2                	ld	s1,40(sp)
    8000423e:	7902                	ld	s2,32(sp)
    80004240:	69e2                	ld	s3,24(sp)
    80004242:	6a42                	ld	s4,16(sp)
    80004244:	6aa2                	ld	s5,8(sp)
    80004246:	6121                	addi	sp,sp,64
    80004248:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000424a:	0001ea97          	auipc	s5,0x1e
    8000424e:	8eea8a93          	addi	s5,s5,-1810 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004252:	0001ea17          	auipc	s4,0x1e
    80004256:	8b6a0a13          	addi	s4,s4,-1866 # 80021b08 <log>
    8000425a:	018a2583          	lw	a1,24(s4)
    8000425e:	012585bb          	addw	a1,a1,s2
    80004262:	2585                	addiw	a1,a1,1
    80004264:	028a2503          	lw	a0,40(s4)
    80004268:	fffff097          	auipc	ra,0xfffff
    8000426c:	ce8080e7          	jalr	-792(ra) # 80002f50 <bread>
    80004270:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004272:	000aa583          	lw	a1,0(s5)
    80004276:	028a2503          	lw	a0,40(s4)
    8000427a:	fffff097          	auipc	ra,0xfffff
    8000427e:	cd6080e7          	jalr	-810(ra) # 80002f50 <bread>
    80004282:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004284:	40000613          	li	a2,1024
    80004288:	05850593          	addi	a1,a0,88
    8000428c:	05848513          	addi	a0,s1,88
    80004290:	ffffd097          	auipc	ra,0xffffd
    80004294:	b1e080e7          	jalr	-1250(ra) # 80000dae <memmove>
    bwrite(to);  // write the log
    80004298:	8526                	mv	a0,s1
    8000429a:	fffff097          	auipc	ra,0xfffff
    8000429e:	da8080e7          	jalr	-600(ra) # 80003042 <bwrite>
    brelse(from);
    800042a2:	854e                	mv	a0,s3
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	ddc080e7          	jalr	-548(ra) # 80003080 <brelse>
    brelse(to);
    800042ac:	8526                	mv	a0,s1
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	dd2080e7          	jalr	-558(ra) # 80003080 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042b6:	2905                	addiw	s2,s2,1
    800042b8:	0a91                	addi	s5,s5,4
    800042ba:	02ca2783          	lw	a5,44(s4)
    800042be:	f8f94ee3          	blt	s2,a5,8000425a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042c2:	00000097          	auipc	ra,0x0
    800042c6:	c7a080e7          	jalr	-902(ra) # 80003f3c <write_head>
    install_trans(); // Now install writes to home locations
    800042ca:	00000097          	auipc	ra,0x0
    800042ce:	cec080e7          	jalr	-788(ra) # 80003fb6 <install_trans>
    log.lh.n = 0;
    800042d2:	0001e797          	auipc	a5,0x1e
    800042d6:	8607a123          	sw	zero,-1950(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042da:	00000097          	auipc	ra,0x0
    800042de:	c62080e7          	jalr	-926(ra) # 80003f3c <write_head>
    800042e2:	bdfd                	j	800041e0 <end_op+0x52>

00000000800042e4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042e4:	1101                	addi	sp,sp,-32
    800042e6:	ec06                	sd	ra,24(sp)
    800042e8:	e822                	sd	s0,16(sp)
    800042ea:	e426                	sd	s1,8(sp)
    800042ec:	e04a                	sd	s2,0(sp)
    800042ee:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042f0:	0001e717          	auipc	a4,0x1e
    800042f4:	84472703          	lw	a4,-1980(a4) # 80021b34 <log+0x2c>
    800042f8:	47f5                	li	a5,29
    800042fa:	08e7c063          	blt	a5,a4,8000437a <log_write+0x96>
    800042fe:	84aa                	mv	s1,a0
    80004300:	0001e797          	auipc	a5,0x1e
    80004304:	8247a783          	lw	a5,-2012(a5) # 80021b24 <log+0x1c>
    80004308:	37fd                	addiw	a5,a5,-1
    8000430a:	06f75863          	bge	a4,a5,8000437a <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000430e:	0001e797          	auipc	a5,0x1e
    80004312:	81a7a783          	lw	a5,-2022(a5) # 80021b28 <log+0x20>
    80004316:	06f05a63          	blez	a5,8000438a <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000431a:	0001d917          	auipc	s2,0x1d
    8000431e:	7ee90913          	addi	s2,s2,2030 # 80021b08 <log>
    80004322:	854a                	mv	a0,s2
    80004324:	ffffd097          	auipc	ra,0xffffd
    80004328:	932080e7          	jalr	-1742(ra) # 80000c56 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    8000432c:	02c92603          	lw	a2,44(s2)
    80004330:	06c05563          	blez	a2,8000439a <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004334:	44cc                	lw	a1,12(s1)
    80004336:	0001e717          	auipc	a4,0x1e
    8000433a:	80270713          	addi	a4,a4,-2046 # 80021b38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000433e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004340:	4314                	lw	a3,0(a4)
    80004342:	04b68d63          	beq	a3,a1,8000439c <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004346:	2785                	addiw	a5,a5,1
    80004348:	0711                	addi	a4,a4,4
    8000434a:	fec79be3          	bne	a5,a2,80004340 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000434e:	0621                	addi	a2,a2,8
    80004350:	060a                	slli	a2,a2,0x2
    80004352:	0001d797          	auipc	a5,0x1d
    80004356:	7b678793          	addi	a5,a5,1974 # 80021b08 <log>
    8000435a:	963e                	add	a2,a2,a5
    8000435c:	44dc                	lw	a5,12(s1)
    8000435e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004360:	8526                	mv	a0,s1
    80004362:	fffff097          	auipc	ra,0xfffff
    80004366:	dbc080e7          	jalr	-580(ra) # 8000311e <bpin>
    log.lh.n++;
    8000436a:	0001d717          	auipc	a4,0x1d
    8000436e:	79e70713          	addi	a4,a4,1950 # 80021b08 <log>
    80004372:	575c                	lw	a5,44(a4)
    80004374:	2785                	addiw	a5,a5,1
    80004376:	d75c                	sw	a5,44(a4)
    80004378:	a83d                	j	800043b6 <log_write+0xd2>
    panic("too big a transaction");
    8000437a:	00004517          	auipc	a0,0x4
    8000437e:	37650513          	addi	a0,a0,886 # 800086f0 <syscalls+0x200>
    80004382:	ffffc097          	auipc	ra,0xffffc
    80004386:	1ce080e7          	jalr	462(ra) # 80000550 <panic>
    panic("log_write outside of trans");
    8000438a:	00004517          	auipc	a0,0x4
    8000438e:	37e50513          	addi	a0,a0,894 # 80008708 <syscalls+0x218>
    80004392:	ffffc097          	auipc	ra,0xffffc
    80004396:	1be080e7          	jalr	446(ra) # 80000550 <panic>
  for (i = 0; i < log.lh.n; i++) {
    8000439a:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    8000439c:	00878713          	addi	a4,a5,8
    800043a0:	00271693          	slli	a3,a4,0x2
    800043a4:	0001d717          	auipc	a4,0x1d
    800043a8:	76470713          	addi	a4,a4,1892 # 80021b08 <log>
    800043ac:	9736                	add	a4,a4,a3
    800043ae:	44d4                	lw	a3,12(s1)
    800043b0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043b2:	faf607e3          	beq	a2,a5,80004360 <log_write+0x7c>
  }
  release(&log.lock);
    800043b6:	0001d517          	auipc	a0,0x1d
    800043ba:	75250513          	addi	a0,a0,1874 # 80021b08 <log>
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	94c080e7          	jalr	-1716(ra) # 80000d0a <release>
}
    800043c6:	60e2                	ld	ra,24(sp)
    800043c8:	6442                	ld	s0,16(sp)
    800043ca:	64a2                	ld	s1,8(sp)
    800043cc:	6902                	ld	s2,0(sp)
    800043ce:	6105                	addi	sp,sp,32
    800043d0:	8082                	ret

00000000800043d2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043d2:	1101                	addi	sp,sp,-32
    800043d4:	ec06                	sd	ra,24(sp)
    800043d6:	e822                	sd	s0,16(sp)
    800043d8:	e426                	sd	s1,8(sp)
    800043da:	e04a                	sd	s2,0(sp)
    800043dc:	1000                	addi	s0,sp,32
    800043de:	84aa                	mv	s1,a0
    800043e0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043e2:	00004597          	auipc	a1,0x4
    800043e6:	34658593          	addi	a1,a1,838 # 80008728 <syscalls+0x238>
    800043ea:	0521                	addi	a0,a0,8
    800043ec:	ffffc097          	auipc	ra,0xffffc
    800043f0:	7da080e7          	jalr	2010(ra) # 80000bc6 <initlock>
  lk->name = name;
    800043f4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043f8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043fc:	0204a423          	sw	zero,40(s1)
}
    80004400:	60e2                	ld	ra,24(sp)
    80004402:	6442                	ld	s0,16(sp)
    80004404:	64a2                	ld	s1,8(sp)
    80004406:	6902                	ld	s2,0(sp)
    80004408:	6105                	addi	sp,sp,32
    8000440a:	8082                	ret

000000008000440c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000440c:	1101                	addi	sp,sp,-32
    8000440e:	ec06                	sd	ra,24(sp)
    80004410:	e822                	sd	s0,16(sp)
    80004412:	e426                	sd	s1,8(sp)
    80004414:	e04a                	sd	s2,0(sp)
    80004416:	1000                	addi	s0,sp,32
    80004418:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000441a:	00850913          	addi	s2,a0,8
    8000441e:	854a                	mv	a0,s2
    80004420:	ffffd097          	auipc	ra,0xffffd
    80004424:	836080e7          	jalr	-1994(ra) # 80000c56 <acquire>
  while (lk->locked) {
    80004428:	409c                	lw	a5,0(s1)
    8000442a:	cb89                	beqz	a5,8000443c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000442c:	85ca                	mv	a1,s2
    8000442e:	8526                	mv	a0,s1
    80004430:	ffffe097          	auipc	ra,0xffffe
    80004434:	e0e080e7          	jalr	-498(ra) # 8000223e <sleep>
  while (lk->locked) {
    80004438:	409c                	lw	a5,0(s1)
    8000443a:	fbed                	bnez	a5,8000442c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000443c:	4785                	li	a5,1
    8000443e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004440:	ffffd097          	auipc	ra,0xffffd
    80004444:	5e2080e7          	jalr	1506(ra) # 80001a22 <myproc>
    80004448:	5d1c                	lw	a5,56(a0)
    8000444a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000444c:	854a                	mv	a0,s2
    8000444e:	ffffd097          	auipc	ra,0xffffd
    80004452:	8bc080e7          	jalr	-1860(ra) # 80000d0a <release>
}
    80004456:	60e2                	ld	ra,24(sp)
    80004458:	6442                	ld	s0,16(sp)
    8000445a:	64a2                	ld	s1,8(sp)
    8000445c:	6902                	ld	s2,0(sp)
    8000445e:	6105                	addi	sp,sp,32
    80004460:	8082                	ret

0000000080004462 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004462:	1101                	addi	sp,sp,-32
    80004464:	ec06                	sd	ra,24(sp)
    80004466:	e822                	sd	s0,16(sp)
    80004468:	e426                	sd	s1,8(sp)
    8000446a:	e04a                	sd	s2,0(sp)
    8000446c:	1000                	addi	s0,sp,32
    8000446e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004470:	00850913          	addi	s2,a0,8
    80004474:	854a                	mv	a0,s2
    80004476:	ffffc097          	auipc	ra,0xffffc
    8000447a:	7e0080e7          	jalr	2016(ra) # 80000c56 <acquire>
  lk->locked = 0;
    8000447e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004482:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004486:	8526                	mv	a0,s1
    80004488:	ffffe097          	auipc	ra,0xffffe
    8000448c:	f36080e7          	jalr	-202(ra) # 800023be <wakeup>
  release(&lk->lk);
    80004490:	854a                	mv	a0,s2
    80004492:	ffffd097          	auipc	ra,0xffffd
    80004496:	878080e7          	jalr	-1928(ra) # 80000d0a <release>
}
    8000449a:	60e2                	ld	ra,24(sp)
    8000449c:	6442                	ld	s0,16(sp)
    8000449e:	64a2                	ld	s1,8(sp)
    800044a0:	6902                	ld	s2,0(sp)
    800044a2:	6105                	addi	sp,sp,32
    800044a4:	8082                	ret

00000000800044a6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044a6:	7179                	addi	sp,sp,-48
    800044a8:	f406                	sd	ra,40(sp)
    800044aa:	f022                	sd	s0,32(sp)
    800044ac:	ec26                	sd	s1,24(sp)
    800044ae:	e84a                	sd	s2,16(sp)
    800044b0:	e44e                	sd	s3,8(sp)
    800044b2:	1800                	addi	s0,sp,48
    800044b4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044b6:	00850913          	addi	s2,a0,8
    800044ba:	854a                	mv	a0,s2
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	79a080e7          	jalr	1946(ra) # 80000c56 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044c4:	409c                	lw	a5,0(s1)
    800044c6:	ef99                	bnez	a5,800044e4 <holdingsleep+0x3e>
    800044c8:	4481                	li	s1,0
  release(&lk->lk);
    800044ca:	854a                	mv	a0,s2
    800044cc:	ffffd097          	auipc	ra,0xffffd
    800044d0:	83e080e7          	jalr	-1986(ra) # 80000d0a <release>
  return r;
}
    800044d4:	8526                	mv	a0,s1
    800044d6:	70a2                	ld	ra,40(sp)
    800044d8:	7402                	ld	s0,32(sp)
    800044da:	64e2                	ld	s1,24(sp)
    800044dc:	6942                	ld	s2,16(sp)
    800044de:	69a2                	ld	s3,8(sp)
    800044e0:	6145                	addi	sp,sp,48
    800044e2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044e4:	0284a983          	lw	s3,40(s1)
    800044e8:	ffffd097          	auipc	ra,0xffffd
    800044ec:	53a080e7          	jalr	1338(ra) # 80001a22 <myproc>
    800044f0:	5d04                	lw	s1,56(a0)
    800044f2:	413484b3          	sub	s1,s1,s3
    800044f6:	0014b493          	seqz	s1,s1
    800044fa:	bfc1                	j	800044ca <holdingsleep+0x24>

00000000800044fc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044fc:	1141                	addi	sp,sp,-16
    800044fe:	e406                	sd	ra,8(sp)
    80004500:	e022                	sd	s0,0(sp)
    80004502:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004504:	00004597          	auipc	a1,0x4
    80004508:	23458593          	addi	a1,a1,564 # 80008738 <syscalls+0x248>
    8000450c:	0001d517          	auipc	a0,0x1d
    80004510:	74450513          	addi	a0,a0,1860 # 80021c50 <ftable>
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	6b2080e7          	jalr	1714(ra) # 80000bc6 <initlock>
}
    8000451c:	60a2                	ld	ra,8(sp)
    8000451e:	6402                	ld	s0,0(sp)
    80004520:	0141                	addi	sp,sp,16
    80004522:	8082                	ret

0000000080004524 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004524:	1101                	addi	sp,sp,-32
    80004526:	ec06                	sd	ra,24(sp)
    80004528:	e822                	sd	s0,16(sp)
    8000452a:	e426                	sd	s1,8(sp)
    8000452c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000452e:	0001d517          	auipc	a0,0x1d
    80004532:	72250513          	addi	a0,a0,1826 # 80021c50 <ftable>
    80004536:	ffffc097          	auipc	ra,0xffffc
    8000453a:	720080e7          	jalr	1824(ra) # 80000c56 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000453e:	0001d497          	auipc	s1,0x1d
    80004542:	72a48493          	addi	s1,s1,1834 # 80021c68 <ftable+0x18>
    80004546:	0001e717          	auipc	a4,0x1e
    8000454a:	6c270713          	addi	a4,a4,1730 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    8000454e:	40dc                	lw	a5,4(s1)
    80004550:	cf99                	beqz	a5,8000456e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004552:	02848493          	addi	s1,s1,40
    80004556:	fee49ce3          	bne	s1,a4,8000454e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000455a:	0001d517          	auipc	a0,0x1d
    8000455e:	6f650513          	addi	a0,a0,1782 # 80021c50 <ftable>
    80004562:	ffffc097          	auipc	ra,0xffffc
    80004566:	7a8080e7          	jalr	1960(ra) # 80000d0a <release>
  return 0;
    8000456a:	4481                	li	s1,0
    8000456c:	a819                	j	80004582 <filealloc+0x5e>
      f->ref = 1;
    8000456e:	4785                	li	a5,1
    80004570:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004572:	0001d517          	auipc	a0,0x1d
    80004576:	6de50513          	addi	a0,a0,1758 # 80021c50 <ftable>
    8000457a:	ffffc097          	auipc	ra,0xffffc
    8000457e:	790080e7          	jalr	1936(ra) # 80000d0a <release>
}
    80004582:	8526                	mv	a0,s1
    80004584:	60e2                	ld	ra,24(sp)
    80004586:	6442                	ld	s0,16(sp)
    80004588:	64a2                	ld	s1,8(sp)
    8000458a:	6105                	addi	sp,sp,32
    8000458c:	8082                	ret

000000008000458e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000458e:	1101                	addi	sp,sp,-32
    80004590:	ec06                	sd	ra,24(sp)
    80004592:	e822                	sd	s0,16(sp)
    80004594:	e426                	sd	s1,8(sp)
    80004596:	1000                	addi	s0,sp,32
    80004598:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000459a:	0001d517          	auipc	a0,0x1d
    8000459e:	6b650513          	addi	a0,a0,1718 # 80021c50 <ftable>
    800045a2:	ffffc097          	auipc	ra,0xffffc
    800045a6:	6b4080e7          	jalr	1716(ra) # 80000c56 <acquire>
  if(f->ref < 1)
    800045aa:	40dc                	lw	a5,4(s1)
    800045ac:	02f05263          	blez	a5,800045d0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045b0:	2785                	addiw	a5,a5,1
    800045b2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045b4:	0001d517          	auipc	a0,0x1d
    800045b8:	69c50513          	addi	a0,a0,1692 # 80021c50 <ftable>
    800045bc:	ffffc097          	auipc	ra,0xffffc
    800045c0:	74e080e7          	jalr	1870(ra) # 80000d0a <release>
  return f;
}
    800045c4:	8526                	mv	a0,s1
    800045c6:	60e2                	ld	ra,24(sp)
    800045c8:	6442                	ld	s0,16(sp)
    800045ca:	64a2                	ld	s1,8(sp)
    800045cc:	6105                	addi	sp,sp,32
    800045ce:	8082                	ret
    panic("filedup");
    800045d0:	00004517          	auipc	a0,0x4
    800045d4:	17050513          	addi	a0,a0,368 # 80008740 <syscalls+0x250>
    800045d8:	ffffc097          	auipc	ra,0xffffc
    800045dc:	f78080e7          	jalr	-136(ra) # 80000550 <panic>

00000000800045e0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045e0:	7139                	addi	sp,sp,-64
    800045e2:	fc06                	sd	ra,56(sp)
    800045e4:	f822                	sd	s0,48(sp)
    800045e6:	f426                	sd	s1,40(sp)
    800045e8:	f04a                	sd	s2,32(sp)
    800045ea:	ec4e                	sd	s3,24(sp)
    800045ec:	e852                	sd	s4,16(sp)
    800045ee:	e456                	sd	s5,8(sp)
    800045f0:	0080                	addi	s0,sp,64
    800045f2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045f4:	0001d517          	auipc	a0,0x1d
    800045f8:	65c50513          	addi	a0,a0,1628 # 80021c50 <ftable>
    800045fc:	ffffc097          	auipc	ra,0xffffc
    80004600:	65a080e7          	jalr	1626(ra) # 80000c56 <acquire>
  if(f->ref < 1)
    80004604:	40dc                	lw	a5,4(s1)
    80004606:	06f05163          	blez	a5,80004668 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000460a:	37fd                	addiw	a5,a5,-1
    8000460c:	0007871b          	sext.w	a4,a5
    80004610:	c0dc                	sw	a5,4(s1)
    80004612:	06e04363          	bgtz	a4,80004678 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004616:	0004a903          	lw	s2,0(s1)
    8000461a:	0094ca83          	lbu	s5,9(s1)
    8000461e:	0104ba03          	ld	s4,16(s1)
    80004622:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004626:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000462a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000462e:	0001d517          	auipc	a0,0x1d
    80004632:	62250513          	addi	a0,a0,1570 # 80021c50 <ftable>
    80004636:	ffffc097          	auipc	ra,0xffffc
    8000463a:	6d4080e7          	jalr	1748(ra) # 80000d0a <release>

  if(ff.type == FD_PIPE){
    8000463e:	4785                	li	a5,1
    80004640:	04f90d63          	beq	s2,a5,8000469a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004644:	3979                	addiw	s2,s2,-2
    80004646:	4785                	li	a5,1
    80004648:	0527e063          	bltu	a5,s2,80004688 <fileclose+0xa8>
    begin_op();
    8000464c:	00000097          	auipc	ra,0x0
    80004650:	ac2080e7          	jalr	-1342(ra) # 8000410e <begin_op>
    iput(ff.ip);
    80004654:	854e                	mv	a0,s3
    80004656:	fffff097          	auipc	ra,0xfffff
    8000465a:	2b6080e7          	jalr	694(ra) # 8000390c <iput>
    end_op();
    8000465e:	00000097          	auipc	ra,0x0
    80004662:	b30080e7          	jalr	-1232(ra) # 8000418e <end_op>
    80004666:	a00d                	j	80004688 <fileclose+0xa8>
    panic("fileclose");
    80004668:	00004517          	auipc	a0,0x4
    8000466c:	0e050513          	addi	a0,a0,224 # 80008748 <syscalls+0x258>
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	ee0080e7          	jalr	-288(ra) # 80000550 <panic>
    release(&ftable.lock);
    80004678:	0001d517          	auipc	a0,0x1d
    8000467c:	5d850513          	addi	a0,a0,1496 # 80021c50 <ftable>
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	68a080e7          	jalr	1674(ra) # 80000d0a <release>
  }
}
    80004688:	70e2                	ld	ra,56(sp)
    8000468a:	7442                	ld	s0,48(sp)
    8000468c:	74a2                	ld	s1,40(sp)
    8000468e:	7902                	ld	s2,32(sp)
    80004690:	69e2                	ld	s3,24(sp)
    80004692:	6a42                	ld	s4,16(sp)
    80004694:	6aa2                	ld	s5,8(sp)
    80004696:	6121                	addi	sp,sp,64
    80004698:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000469a:	85d6                	mv	a1,s5
    8000469c:	8552                	mv	a0,s4
    8000469e:	00000097          	auipc	ra,0x0
    800046a2:	372080e7          	jalr	882(ra) # 80004a10 <pipeclose>
    800046a6:	b7cd                	j	80004688 <fileclose+0xa8>

00000000800046a8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046a8:	715d                	addi	sp,sp,-80
    800046aa:	e486                	sd	ra,72(sp)
    800046ac:	e0a2                	sd	s0,64(sp)
    800046ae:	fc26                	sd	s1,56(sp)
    800046b0:	f84a                	sd	s2,48(sp)
    800046b2:	f44e                	sd	s3,40(sp)
    800046b4:	0880                	addi	s0,sp,80
    800046b6:	84aa                	mv	s1,a0
    800046b8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046ba:	ffffd097          	auipc	ra,0xffffd
    800046be:	368080e7          	jalr	872(ra) # 80001a22 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046c2:	409c                	lw	a5,0(s1)
    800046c4:	37f9                	addiw	a5,a5,-2
    800046c6:	4705                	li	a4,1
    800046c8:	04f76763          	bltu	a4,a5,80004716 <filestat+0x6e>
    800046cc:	892a                	mv	s2,a0
    ilock(f->ip);
    800046ce:	6c88                	ld	a0,24(s1)
    800046d0:	fffff097          	auipc	ra,0xfffff
    800046d4:	082080e7          	jalr	130(ra) # 80003752 <ilock>
    stati(f->ip, &st);
    800046d8:	fb840593          	addi	a1,s0,-72
    800046dc:	6c88                	ld	a0,24(s1)
    800046de:	fffff097          	auipc	ra,0xfffff
    800046e2:	2fe080e7          	jalr	766(ra) # 800039dc <stati>
    iunlock(f->ip);
    800046e6:	6c88                	ld	a0,24(s1)
    800046e8:	fffff097          	auipc	ra,0xfffff
    800046ec:	12c080e7          	jalr	300(ra) # 80003814 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046f0:	46e1                	li	a3,24
    800046f2:	fb840613          	addi	a2,s0,-72
    800046f6:	85ce                	mv	a1,s3
    800046f8:	05093503          	ld	a0,80(s2)
    800046fc:	ffffd097          	auipc	ra,0xffffd
    80004700:	018080e7          	jalr	24(ra) # 80001714 <copyout>
    80004704:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004708:	60a6                	ld	ra,72(sp)
    8000470a:	6406                	ld	s0,64(sp)
    8000470c:	74e2                	ld	s1,56(sp)
    8000470e:	7942                	ld	s2,48(sp)
    80004710:	79a2                	ld	s3,40(sp)
    80004712:	6161                	addi	sp,sp,80
    80004714:	8082                	ret
  return -1;
    80004716:	557d                	li	a0,-1
    80004718:	bfc5                	j	80004708 <filestat+0x60>

000000008000471a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000471a:	7179                	addi	sp,sp,-48
    8000471c:	f406                	sd	ra,40(sp)
    8000471e:	f022                	sd	s0,32(sp)
    80004720:	ec26                	sd	s1,24(sp)
    80004722:	e84a                	sd	s2,16(sp)
    80004724:	e44e                	sd	s3,8(sp)
    80004726:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004728:	00854783          	lbu	a5,8(a0)
    8000472c:	c3d5                	beqz	a5,800047d0 <fileread+0xb6>
    8000472e:	84aa                	mv	s1,a0
    80004730:	89ae                	mv	s3,a1
    80004732:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004734:	411c                	lw	a5,0(a0)
    80004736:	4705                	li	a4,1
    80004738:	04e78963          	beq	a5,a4,8000478a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000473c:	470d                	li	a4,3
    8000473e:	04e78d63          	beq	a5,a4,80004798 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004742:	4709                	li	a4,2
    80004744:	06e79e63          	bne	a5,a4,800047c0 <fileread+0xa6>
    ilock(f->ip);
    80004748:	6d08                	ld	a0,24(a0)
    8000474a:	fffff097          	auipc	ra,0xfffff
    8000474e:	008080e7          	jalr	8(ra) # 80003752 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004752:	874a                	mv	a4,s2
    80004754:	5094                	lw	a3,32(s1)
    80004756:	864e                	mv	a2,s3
    80004758:	4585                	li	a1,1
    8000475a:	6c88                	ld	a0,24(s1)
    8000475c:	fffff097          	auipc	ra,0xfffff
    80004760:	2aa080e7          	jalr	682(ra) # 80003a06 <readi>
    80004764:	892a                	mv	s2,a0
    80004766:	00a05563          	blez	a0,80004770 <fileread+0x56>
      f->off += r;
    8000476a:	509c                	lw	a5,32(s1)
    8000476c:	9fa9                	addw	a5,a5,a0
    8000476e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004770:	6c88                	ld	a0,24(s1)
    80004772:	fffff097          	auipc	ra,0xfffff
    80004776:	0a2080e7          	jalr	162(ra) # 80003814 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000477a:	854a                	mv	a0,s2
    8000477c:	70a2                	ld	ra,40(sp)
    8000477e:	7402                	ld	s0,32(sp)
    80004780:	64e2                	ld	s1,24(sp)
    80004782:	6942                	ld	s2,16(sp)
    80004784:	69a2                	ld	s3,8(sp)
    80004786:	6145                	addi	sp,sp,48
    80004788:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000478a:	6908                	ld	a0,16(a0)
    8000478c:	00000097          	auipc	ra,0x0
    80004790:	3f4080e7          	jalr	1012(ra) # 80004b80 <piperead>
    80004794:	892a                	mv	s2,a0
    80004796:	b7d5                	j	8000477a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004798:	02451783          	lh	a5,36(a0)
    8000479c:	03079693          	slli	a3,a5,0x30
    800047a0:	92c1                	srli	a3,a3,0x30
    800047a2:	4725                	li	a4,9
    800047a4:	02d76863          	bltu	a4,a3,800047d4 <fileread+0xba>
    800047a8:	0792                	slli	a5,a5,0x4
    800047aa:	0001d717          	auipc	a4,0x1d
    800047ae:	40670713          	addi	a4,a4,1030 # 80021bb0 <devsw>
    800047b2:	97ba                	add	a5,a5,a4
    800047b4:	639c                	ld	a5,0(a5)
    800047b6:	c38d                	beqz	a5,800047d8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047b8:	4505                	li	a0,1
    800047ba:	9782                	jalr	a5
    800047bc:	892a                	mv	s2,a0
    800047be:	bf75                	j	8000477a <fileread+0x60>
    panic("fileread");
    800047c0:	00004517          	auipc	a0,0x4
    800047c4:	f9850513          	addi	a0,a0,-104 # 80008758 <syscalls+0x268>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	d88080e7          	jalr	-632(ra) # 80000550 <panic>
    return -1;
    800047d0:	597d                	li	s2,-1
    800047d2:	b765                	j	8000477a <fileread+0x60>
      return -1;
    800047d4:	597d                	li	s2,-1
    800047d6:	b755                	j	8000477a <fileread+0x60>
    800047d8:	597d                	li	s2,-1
    800047da:	b745                	j	8000477a <fileread+0x60>

00000000800047dc <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047dc:	00954783          	lbu	a5,9(a0)
    800047e0:	14078563          	beqz	a5,8000492a <filewrite+0x14e>
{
    800047e4:	715d                	addi	sp,sp,-80
    800047e6:	e486                	sd	ra,72(sp)
    800047e8:	e0a2                	sd	s0,64(sp)
    800047ea:	fc26                	sd	s1,56(sp)
    800047ec:	f84a                	sd	s2,48(sp)
    800047ee:	f44e                	sd	s3,40(sp)
    800047f0:	f052                	sd	s4,32(sp)
    800047f2:	ec56                	sd	s5,24(sp)
    800047f4:	e85a                	sd	s6,16(sp)
    800047f6:	e45e                	sd	s7,8(sp)
    800047f8:	e062                	sd	s8,0(sp)
    800047fa:	0880                	addi	s0,sp,80
    800047fc:	892a                	mv	s2,a0
    800047fe:	8aae                	mv	s5,a1
    80004800:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004802:	411c                	lw	a5,0(a0)
    80004804:	4705                	li	a4,1
    80004806:	02e78263          	beq	a5,a4,8000482a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000480a:	470d                	li	a4,3
    8000480c:	02e78563          	beq	a5,a4,80004836 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004810:	4709                	li	a4,2
    80004812:	10e79463          	bne	a5,a4,8000491a <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004816:	0ec05e63          	blez	a2,80004912 <filewrite+0x136>
    int i = 0;
    8000481a:	4981                	li	s3,0
    8000481c:	6b05                	lui	s6,0x1
    8000481e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004822:	6b85                	lui	s7,0x1
    80004824:	c00b8b9b          	addiw	s7,s7,-1024
    80004828:	a851                	j	800048bc <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000482a:	6908                	ld	a0,16(a0)
    8000482c:	00000097          	auipc	ra,0x0
    80004830:	254080e7          	jalr	596(ra) # 80004a80 <pipewrite>
    80004834:	a85d                	j	800048ea <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004836:	02451783          	lh	a5,36(a0)
    8000483a:	03079693          	slli	a3,a5,0x30
    8000483e:	92c1                	srli	a3,a3,0x30
    80004840:	4725                	li	a4,9
    80004842:	0ed76663          	bltu	a4,a3,8000492e <filewrite+0x152>
    80004846:	0792                	slli	a5,a5,0x4
    80004848:	0001d717          	auipc	a4,0x1d
    8000484c:	36870713          	addi	a4,a4,872 # 80021bb0 <devsw>
    80004850:	97ba                	add	a5,a5,a4
    80004852:	679c                	ld	a5,8(a5)
    80004854:	cff9                	beqz	a5,80004932 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004856:	4505                	li	a0,1
    80004858:	9782                	jalr	a5
    8000485a:	a841                	j	800048ea <filewrite+0x10e>
    8000485c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004860:	00000097          	auipc	ra,0x0
    80004864:	8ae080e7          	jalr	-1874(ra) # 8000410e <begin_op>
      ilock(f->ip);
    80004868:	01893503          	ld	a0,24(s2)
    8000486c:	fffff097          	auipc	ra,0xfffff
    80004870:	ee6080e7          	jalr	-282(ra) # 80003752 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004874:	8762                	mv	a4,s8
    80004876:	02092683          	lw	a3,32(s2)
    8000487a:	01598633          	add	a2,s3,s5
    8000487e:	4585                	li	a1,1
    80004880:	01893503          	ld	a0,24(s2)
    80004884:	fffff097          	auipc	ra,0xfffff
    80004888:	278080e7          	jalr	632(ra) # 80003afc <writei>
    8000488c:	84aa                	mv	s1,a0
    8000488e:	02a05f63          	blez	a0,800048cc <filewrite+0xf0>
        f->off += r;
    80004892:	02092783          	lw	a5,32(s2)
    80004896:	9fa9                	addw	a5,a5,a0
    80004898:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000489c:	01893503          	ld	a0,24(s2)
    800048a0:	fffff097          	auipc	ra,0xfffff
    800048a4:	f74080e7          	jalr	-140(ra) # 80003814 <iunlock>
      end_op();
    800048a8:	00000097          	auipc	ra,0x0
    800048ac:	8e6080e7          	jalr	-1818(ra) # 8000418e <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800048b0:	049c1963          	bne	s8,s1,80004902 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800048b4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048b8:	0349d663          	bge	s3,s4,800048e4 <filewrite+0x108>
      int n1 = n - i;
    800048bc:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800048c0:	84be                	mv	s1,a5
    800048c2:	2781                	sext.w	a5,a5
    800048c4:	f8fb5ce3          	bge	s6,a5,8000485c <filewrite+0x80>
    800048c8:	84de                	mv	s1,s7
    800048ca:	bf49                	j	8000485c <filewrite+0x80>
      iunlock(f->ip);
    800048cc:	01893503          	ld	a0,24(s2)
    800048d0:	fffff097          	auipc	ra,0xfffff
    800048d4:	f44080e7          	jalr	-188(ra) # 80003814 <iunlock>
      end_op();
    800048d8:	00000097          	auipc	ra,0x0
    800048dc:	8b6080e7          	jalr	-1866(ra) # 8000418e <end_op>
      if(r < 0)
    800048e0:	fc04d8e3          	bgez	s1,800048b0 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800048e4:	8552                	mv	a0,s4
    800048e6:	033a1863          	bne	s4,s3,80004916 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048ea:	60a6                	ld	ra,72(sp)
    800048ec:	6406                	ld	s0,64(sp)
    800048ee:	74e2                	ld	s1,56(sp)
    800048f0:	7942                	ld	s2,48(sp)
    800048f2:	79a2                	ld	s3,40(sp)
    800048f4:	7a02                	ld	s4,32(sp)
    800048f6:	6ae2                	ld	s5,24(sp)
    800048f8:	6b42                	ld	s6,16(sp)
    800048fa:	6ba2                	ld	s7,8(sp)
    800048fc:	6c02                	ld	s8,0(sp)
    800048fe:	6161                	addi	sp,sp,80
    80004900:	8082                	ret
        panic("short filewrite");
    80004902:	00004517          	auipc	a0,0x4
    80004906:	e6650513          	addi	a0,a0,-410 # 80008768 <syscalls+0x278>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	c46080e7          	jalr	-954(ra) # 80000550 <panic>
    int i = 0;
    80004912:	4981                	li	s3,0
    80004914:	bfc1                	j	800048e4 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004916:	557d                	li	a0,-1
    80004918:	bfc9                	j	800048ea <filewrite+0x10e>
    panic("filewrite");
    8000491a:	00004517          	auipc	a0,0x4
    8000491e:	e5e50513          	addi	a0,a0,-418 # 80008778 <syscalls+0x288>
    80004922:	ffffc097          	auipc	ra,0xffffc
    80004926:	c2e080e7          	jalr	-978(ra) # 80000550 <panic>
    return -1;
    8000492a:	557d                	li	a0,-1
}
    8000492c:	8082                	ret
      return -1;
    8000492e:	557d                	li	a0,-1
    80004930:	bf6d                	j	800048ea <filewrite+0x10e>
    80004932:	557d                	li	a0,-1
    80004934:	bf5d                	j	800048ea <filewrite+0x10e>

0000000080004936 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004936:	7179                	addi	sp,sp,-48
    80004938:	f406                	sd	ra,40(sp)
    8000493a:	f022                	sd	s0,32(sp)
    8000493c:	ec26                	sd	s1,24(sp)
    8000493e:	e84a                	sd	s2,16(sp)
    80004940:	e44e                	sd	s3,8(sp)
    80004942:	e052                	sd	s4,0(sp)
    80004944:	1800                	addi	s0,sp,48
    80004946:	84aa                	mv	s1,a0
    80004948:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000494a:	0005b023          	sd	zero,0(a1)
    8000494e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004952:	00000097          	auipc	ra,0x0
    80004956:	bd2080e7          	jalr	-1070(ra) # 80004524 <filealloc>
    8000495a:	e088                	sd	a0,0(s1)
    8000495c:	c551                	beqz	a0,800049e8 <pipealloc+0xb2>
    8000495e:	00000097          	auipc	ra,0x0
    80004962:	bc6080e7          	jalr	-1082(ra) # 80004524 <filealloc>
    80004966:	00aa3023          	sd	a0,0(s4)
    8000496a:	c92d                	beqz	a0,800049dc <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000496c:	ffffc097          	auipc	ra,0xffffc
    80004970:	1b0080e7          	jalr	432(ra) # 80000b1c <kalloc>
    80004974:	892a                	mv	s2,a0
    80004976:	c125                	beqz	a0,800049d6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004978:	4985                	li	s3,1
    8000497a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000497e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004982:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004986:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000498a:	00004597          	auipc	a1,0x4
    8000498e:	ab658593          	addi	a1,a1,-1354 # 80008440 <states.0+0x198>
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	234080e7          	jalr	564(ra) # 80000bc6 <initlock>
  (*f0)->type = FD_PIPE;
    8000499a:	609c                	ld	a5,0(s1)
    8000499c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049a0:	609c                	ld	a5,0(s1)
    800049a2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049a6:	609c                	ld	a5,0(s1)
    800049a8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049ac:	609c                	ld	a5,0(s1)
    800049ae:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049b2:	000a3783          	ld	a5,0(s4)
    800049b6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049ba:	000a3783          	ld	a5,0(s4)
    800049be:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049c2:	000a3783          	ld	a5,0(s4)
    800049c6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049ca:	000a3783          	ld	a5,0(s4)
    800049ce:	0127b823          	sd	s2,16(a5)
  return 0;
    800049d2:	4501                	li	a0,0
    800049d4:	a025                	j	800049fc <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049d6:	6088                	ld	a0,0(s1)
    800049d8:	e501                	bnez	a0,800049e0 <pipealloc+0xaa>
    800049da:	a039                	j	800049e8 <pipealloc+0xb2>
    800049dc:	6088                	ld	a0,0(s1)
    800049de:	c51d                	beqz	a0,80004a0c <pipealloc+0xd6>
    fileclose(*f0);
    800049e0:	00000097          	auipc	ra,0x0
    800049e4:	c00080e7          	jalr	-1024(ra) # 800045e0 <fileclose>
  if(*f1)
    800049e8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049ec:	557d                	li	a0,-1
  if(*f1)
    800049ee:	c799                	beqz	a5,800049fc <pipealloc+0xc6>
    fileclose(*f1);
    800049f0:	853e                	mv	a0,a5
    800049f2:	00000097          	auipc	ra,0x0
    800049f6:	bee080e7          	jalr	-1042(ra) # 800045e0 <fileclose>
  return -1;
    800049fa:	557d                	li	a0,-1
}
    800049fc:	70a2                	ld	ra,40(sp)
    800049fe:	7402                	ld	s0,32(sp)
    80004a00:	64e2                	ld	s1,24(sp)
    80004a02:	6942                	ld	s2,16(sp)
    80004a04:	69a2                	ld	s3,8(sp)
    80004a06:	6a02                	ld	s4,0(sp)
    80004a08:	6145                	addi	sp,sp,48
    80004a0a:	8082                	ret
  return -1;
    80004a0c:	557d                	li	a0,-1
    80004a0e:	b7fd                	j	800049fc <pipealloc+0xc6>

0000000080004a10 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a10:	1101                	addi	sp,sp,-32
    80004a12:	ec06                	sd	ra,24(sp)
    80004a14:	e822                	sd	s0,16(sp)
    80004a16:	e426                	sd	s1,8(sp)
    80004a18:	e04a                	sd	s2,0(sp)
    80004a1a:	1000                	addi	s0,sp,32
    80004a1c:	84aa                	mv	s1,a0
    80004a1e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	236080e7          	jalr	566(ra) # 80000c56 <acquire>
  if(writable){
    80004a28:	02090d63          	beqz	s2,80004a62 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a2c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a30:	21848513          	addi	a0,s1,536
    80004a34:	ffffe097          	auipc	ra,0xffffe
    80004a38:	98a080e7          	jalr	-1654(ra) # 800023be <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a3c:	2204b783          	ld	a5,544(s1)
    80004a40:	eb95                	bnez	a5,80004a74 <pipeclose+0x64>
    release(&pi->lock);
    80004a42:	8526                	mv	a0,s1
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	2c6080e7          	jalr	710(ra) # 80000d0a <release>
    kfree((char*)pi);
    80004a4c:	8526                	mv	a0,s1
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	fd2080e7          	jalr	-46(ra) # 80000a20 <kfree>
  } else
    release(&pi->lock);
}
    80004a56:	60e2                	ld	ra,24(sp)
    80004a58:	6442                	ld	s0,16(sp)
    80004a5a:	64a2                	ld	s1,8(sp)
    80004a5c:	6902                	ld	s2,0(sp)
    80004a5e:	6105                	addi	sp,sp,32
    80004a60:	8082                	ret
    pi->readopen = 0;
    80004a62:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a66:	21c48513          	addi	a0,s1,540
    80004a6a:	ffffe097          	auipc	ra,0xffffe
    80004a6e:	954080e7          	jalr	-1708(ra) # 800023be <wakeup>
    80004a72:	b7e9                	j	80004a3c <pipeclose+0x2c>
    release(&pi->lock);
    80004a74:	8526                	mv	a0,s1
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	294080e7          	jalr	660(ra) # 80000d0a <release>
}
    80004a7e:	bfe1                	j	80004a56 <pipeclose+0x46>

0000000080004a80 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a80:	711d                	addi	sp,sp,-96
    80004a82:	ec86                	sd	ra,88(sp)
    80004a84:	e8a2                	sd	s0,80(sp)
    80004a86:	e4a6                	sd	s1,72(sp)
    80004a88:	e0ca                	sd	s2,64(sp)
    80004a8a:	fc4e                	sd	s3,56(sp)
    80004a8c:	f852                	sd	s4,48(sp)
    80004a8e:	f456                	sd	s5,40(sp)
    80004a90:	f05a                	sd	s6,32(sp)
    80004a92:	ec5e                	sd	s7,24(sp)
    80004a94:	e862                	sd	s8,16(sp)
    80004a96:	1080                	addi	s0,sp,96
    80004a98:	84aa                	mv	s1,a0
    80004a9a:	8b2e                	mv	s6,a1
    80004a9c:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004a9e:	ffffd097          	auipc	ra,0xffffd
    80004aa2:	f84080e7          	jalr	-124(ra) # 80001a22 <myproc>
    80004aa6:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004aa8:	8526                	mv	a0,s1
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	1ac080e7          	jalr	428(ra) # 80000c56 <acquire>
  for(i = 0; i < n; i++){
    80004ab2:	09505763          	blez	s5,80004b40 <pipewrite+0xc0>
    80004ab6:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004ab8:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004abc:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ac0:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ac2:	2184a783          	lw	a5,536(s1)
    80004ac6:	21c4a703          	lw	a4,540(s1)
    80004aca:	2007879b          	addiw	a5,a5,512
    80004ace:	02f71b63          	bne	a4,a5,80004b04 <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004ad2:	2204a783          	lw	a5,544(s1)
    80004ad6:	c3d1                	beqz	a5,80004b5a <pipewrite+0xda>
    80004ad8:	03092783          	lw	a5,48(s2)
    80004adc:	efbd                	bnez	a5,80004b5a <pipewrite+0xda>
      wakeup(&pi->nread);
    80004ade:	8552                	mv	a0,s4
    80004ae0:	ffffe097          	auipc	ra,0xffffe
    80004ae4:	8de080e7          	jalr	-1826(ra) # 800023be <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ae8:	85a6                	mv	a1,s1
    80004aea:	854e                	mv	a0,s3
    80004aec:	ffffd097          	auipc	ra,0xffffd
    80004af0:	752080e7          	jalr	1874(ra) # 8000223e <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004af4:	2184a783          	lw	a5,536(s1)
    80004af8:	21c4a703          	lw	a4,540(s1)
    80004afc:	2007879b          	addiw	a5,a5,512
    80004b00:	fcf709e3          	beq	a4,a5,80004ad2 <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b04:	4685                	li	a3,1
    80004b06:	865a                	mv	a2,s6
    80004b08:	faf40593          	addi	a1,s0,-81
    80004b0c:	05093503          	ld	a0,80(s2)
    80004b10:	ffffd097          	auipc	ra,0xffffd
    80004b14:	c90080e7          	jalr	-880(ra) # 800017a0 <copyin>
    80004b18:	03850563          	beq	a0,s8,80004b42 <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b1c:	21c4a783          	lw	a5,540(s1)
    80004b20:	0017871b          	addiw	a4,a5,1
    80004b24:	20e4ae23          	sw	a4,540(s1)
    80004b28:	1ff7f793          	andi	a5,a5,511
    80004b2c:	97a6                	add	a5,a5,s1
    80004b2e:	faf44703          	lbu	a4,-81(s0)
    80004b32:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004b36:	2b85                	addiw	s7,s7,1
    80004b38:	0b05                	addi	s6,s6,1
    80004b3a:	f97a94e3          	bne	s5,s7,80004ac2 <pipewrite+0x42>
    80004b3e:	a011                	j	80004b42 <pipewrite+0xc2>
    80004b40:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004b42:	21848513          	addi	a0,s1,536
    80004b46:	ffffe097          	auipc	ra,0xffffe
    80004b4a:	878080e7          	jalr	-1928(ra) # 800023be <wakeup>
  release(&pi->lock);
    80004b4e:	8526                	mv	a0,s1
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	1ba080e7          	jalr	442(ra) # 80000d0a <release>
  return i;
    80004b58:	a039                	j	80004b66 <pipewrite+0xe6>
        release(&pi->lock);
    80004b5a:	8526                	mv	a0,s1
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	1ae080e7          	jalr	430(ra) # 80000d0a <release>
        return -1;
    80004b64:	5bfd                	li	s7,-1
}
    80004b66:	855e                	mv	a0,s7
    80004b68:	60e6                	ld	ra,88(sp)
    80004b6a:	6446                	ld	s0,80(sp)
    80004b6c:	64a6                	ld	s1,72(sp)
    80004b6e:	6906                	ld	s2,64(sp)
    80004b70:	79e2                	ld	s3,56(sp)
    80004b72:	7a42                	ld	s4,48(sp)
    80004b74:	7aa2                	ld	s5,40(sp)
    80004b76:	7b02                	ld	s6,32(sp)
    80004b78:	6be2                	ld	s7,24(sp)
    80004b7a:	6c42                	ld	s8,16(sp)
    80004b7c:	6125                	addi	sp,sp,96
    80004b7e:	8082                	ret

0000000080004b80 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b80:	715d                	addi	sp,sp,-80
    80004b82:	e486                	sd	ra,72(sp)
    80004b84:	e0a2                	sd	s0,64(sp)
    80004b86:	fc26                	sd	s1,56(sp)
    80004b88:	f84a                	sd	s2,48(sp)
    80004b8a:	f44e                	sd	s3,40(sp)
    80004b8c:	f052                	sd	s4,32(sp)
    80004b8e:	ec56                	sd	s5,24(sp)
    80004b90:	e85a                	sd	s6,16(sp)
    80004b92:	0880                	addi	s0,sp,80
    80004b94:	84aa                	mv	s1,a0
    80004b96:	892e                	mv	s2,a1
    80004b98:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b9a:	ffffd097          	auipc	ra,0xffffd
    80004b9e:	e88080e7          	jalr	-376(ra) # 80001a22 <myproc>
    80004ba2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	ffffc097          	auipc	ra,0xffffc
    80004baa:	0b0080e7          	jalr	176(ra) # 80000c56 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bae:	2184a703          	lw	a4,536(s1)
    80004bb2:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bb6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bba:	02f71463          	bne	a4,a5,80004be2 <piperead+0x62>
    80004bbe:	2244a783          	lw	a5,548(s1)
    80004bc2:	c385                	beqz	a5,80004be2 <piperead+0x62>
    if(pr->killed){
    80004bc4:	030a2783          	lw	a5,48(s4)
    80004bc8:	ebc1                	bnez	a5,80004c58 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bca:	85a6                	mv	a1,s1
    80004bcc:	854e                	mv	a0,s3
    80004bce:	ffffd097          	auipc	ra,0xffffd
    80004bd2:	670080e7          	jalr	1648(ra) # 8000223e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bd6:	2184a703          	lw	a4,536(s1)
    80004bda:	21c4a783          	lw	a5,540(s1)
    80004bde:	fef700e3          	beq	a4,a5,80004bbe <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004be2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004be4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004be6:	05505363          	blez	s5,80004c2c <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004bea:	2184a783          	lw	a5,536(s1)
    80004bee:	21c4a703          	lw	a4,540(s1)
    80004bf2:	02f70d63          	beq	a4,a5,80004c2c <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bf6:	0017871b          	addiw	a4,a5,1
    80004bfa:	20e4ac23          	sw	a4,536(s1)
    80004bfe:	1ff7f793          	andi	a5,a5,511
    80004c02:	97a6                	add	a5,a5,s1
    80004c04:	0187c783          	lbu	a5,24(a5)
    80004c08:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c0c:	4685                	li	a3,1
    80004c0e:	fbf40613          	addi	a2,s0,-65
    80004c12:	85ca                	mv	a1,s2
    80004c14:	050a3503          	ld	a0,80(s4)
    80004c18:	ffffd097          	auipc	ra,0xffffd
    80004c1c:	afc080e7          	jalr	-1284(ra) # 80001714 <copyout>
    80004c20:	01650663          	beq	a0,s6,80004c2c <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c24:	2985                	addiw	s3,s3,1
    80004c26:	0905                	addi	s2,s2,1
    80004c28:	fd3a91e3          	bne	s5,s3,80004bea <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c2c:	21c48513          	addi	a0,s1,540
    80004c30:	ffffd097          	auipc	ra,0xffffd
    80004c34:	78e080e7          	jalr	1934(ra) # 800023be <wakeup>
  release(&pi->lock);
    80004c38:	8526                	mv	a0,s1
    80004c3a:	ffffc097          	auipc	ra,0xffffc
    80004c3e:	0d0080e7          	jalr	208(ra) # 80000d0a <release>
  return i;
}
    80004c42:	854e                	mv	a0,s3
    80004c44:	60a6                	ld	ra,72(sp)
    80004c46:	6406                	ld	s0,64(sp)
    80004c48:	74e2                	ld	s1,56(sp)
    80004c4a:	7942                	ld	s2,48(sp)
    80004c4c:	79a2                	ld	s3,40(sp)
    80004c4e:	7a02                	ld	s4,32(sp)
    80004c50:	6ae2                	ld	s5,24(sp)
    80004c52:	6b42                	ld	s6,16(sp)
    80004c54:	6161                	addi	sp,sp,80
    80004c56:	8082                	ret
      release(&pi->lock);
    80004c58:	8526                	mv	a0,s1
    80004c5a:	ffffc097          	auipc	ra,0xffffc
    80004c5e:	0b0080e7          	jalr	176(ra) # 80000d0a <release>
      return -1;
    80004c62:	59fd                	li	s3,-1
    80004c64:	bff9                	j	80004c42 <piperead+0xc2>

0000000080004c66 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004c66:	de010113          	addi	sp,sp,-544
    80004c6a:	20113c23          	sd	ra,536(sp)
    80004c6e:	20813823          	sd	s0,528(sp)
    80004c72:	20913423          	sd	s1,520(sp)
    80004c76:	21213023          	sd	s2,512(sp)
    80004c7a:	ffce                	sd	s3,504(sp)
    80004c7c:	fbd2                	sd	s4,496(sp)
    80004c7e:	f7d6                	sd	s5,488(sp)
    80004c80:	f3da                	sd	s6,480(sp)
    80004c82:	efde                	sd	s7,472(sp)
    80004c84:	ebe2                	sd	s8,464(sp)
    80004c86:	e7e6                	sd	s9,456(sp)
    80004c88:	e3ea                	sd	s10,448(sp)
    80004c8a:	ff6e                	sd	s11,440(sp)
    80004c8c:	1400                	addi	s0,sp,544
    80004c8e:	892a                	mv	s2,a0
    80004c90:	dea43423          	sd	a0,-536(s0)
    80004c94:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c98:	ffffd097          	auipc	ra,0xffffd
    80004c9c:	d8a080e7          	jalr	-630(ra) # 80001a22 <myproc>
    80004ca0:	84aa                	mv	s1,a0

  begin_op();
    80004ca2:	fffff097          	auipc	ra,0xfffff
    80004ca6:	46c080e7          	jalr	1132(ra) # 8000410e <begin_op>

  if((ip = namei(path)) == 0){
    80004caa:	854a                	mv	a0,s2
    80004cac:	fffff097          	auipc	ra,0xfffff
    80004cb0:	256080e7          	jalr	598(ra) # 80003f02 <namei>
    80004cb4:	c93d                	beqz	a0,80004d2a <exec+0xc4>
    80004cb6:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cb8:	fffff097          	auipc	ra,0xfffff
    80004cbc:	a9a080e7          	jalr	-1382(ra) # 80003752 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cc0:	04000713          	li	a4,64
    80004cc4:	4681                	li	a3,0
    80004cc6:	e4840613          	addi	a2,s0,-440
    80004cca:	4581                	li	a1,0
    80004ccc:	8556                	mv	a0,s5
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	d38080e7          	jalr	-712(ra) # 80003a06 <readi>
    80004cd6:	04000793          	li	a5,64
    80004cda:	00f51a63          	bne	a0,a5,80004cee <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004cde:	e4842703          	lw	a4,-440(s0)
    80004ce2:	464c47b7          	lui	a5,0x464c4
    80004ce6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cea:	04f70663          	beq	a4,a5,80004d36 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cee:	8556                	mv	a0,s5
    80004cf0:	fffff097          	auipc	ra,0xfffff
    80004cf4:	cc4080e7          	jalr	-828(ra) # 800039b4 <iunlockput>
    end_op();
    80004cf8:	fffff097          	auipc	ra,0xfffff
    80004cfc:	496080e7          	jalr	1174(ra) # 8000418e <end_op>
  }
  return -1;
    80004d00:	557d                	li	a0,-1
}
    80004d02:	21813083          	ld	ra,536(sp)
    80004d06:	21013403          	ld	s0,528(sp)
    80004d0a:	20813483          	ld	s1,520(sp)
    80004d0e:	20013903          	ld	s2,512(sp)
    80004d12:	79fe                	ld	s3,504(sp)
    80004d14:	7a5e                	ld	s4,496(sp)
    80004d16:	7abe                	ld	s5,488(sp)
    80004d18:	7b1e                	ld	s6,480(sp)
    80004d1a:	6bfe                	ld	s7,472(sp)
    80004d1c:	6c5e                	ld	s8,464(sp)
    80004d1e:	6cbe                	ld	s9,456(sp)
    80004d20:	6d1e                	ld	s10,448(sp)
    80004d22:	7dfa                	ld	s11,440(sp)
    80004d24:	22010113          	addi	sp,sp,544
    80004d28:	8082                	ret
    end_op();
    80004d2a:	fffff097          	auipc	ra,0xfffff
    80004d2e:	464080e7          	jalr	1124(ra) # 8000418e <end_op>
    return -1;
    80004d32:	557d                	li	a0,-1
    80004d34:	b7f9                	j	80004d02 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffd097          	auipc	ra,0xffffd
    80004d3c:	dae080e7          	jalr	-594(ra) # 80001ae6 <proc_pagetable>
    80004d40:	8b2a                	mv	s6,a0
    80004d42:	d555                	beqz	a0,80004cee <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d44:	e6842783          	lw	a5,-408(s0)
    80004d48:	e8045703          	lhu	a4,-384(s0)
    80004d4c:	c735                	beqz	a4,80004db8 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d4e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d50:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004d54:	6a05                	lui	s4,0x1
    80004d56:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004d5a:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004d5e:	6d85                	lui	s11,0x1
    80004d60:	7d7d                	lui	s10,0xfffff
    80004d62:	ac1d                	j	80004f98 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d64:	00004517          	auipc	a0,0x4
    80004d68:	a2450513          	addi	a0,a0,-1500 # 80008788 <syscalls+0x298>
    80004d6c:	ffffb097          	auipc	ra,0xffffb
    80004d70:	7e4080e7          	jalr	2020(ra) # 80000550 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d74:	874a                	mv	a4,s2
    80004d76:	009c86bb          	addw	a3,s9,s1
    80004d7a:	4581                	li	a1,0
    80004d7c:	8556                	mv	a0,s5
    80004d7e:	fffff097          	auipc	ra,0xfffff
    80004d82:	c88080e7          	jalr	-888(ra) # 80003a06 <readi>
    80004d86:	2501                	sext.w	a0,a0
    80004d88:	1aa91863          	bne	s2,a0,80004f38 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004d8c:	009d84bb          	addw	s1,s11,s1
    80004d90:	013d09bb          	addw	s3,s10,s3
    80004d94:	1f74f263          	bgeu	s1,s7,80004f78 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004d98:	02049593          	slli	a1,s1,0x20
    80004d9c:	9181                	srli	a1,a1,0x20
    80004d9e:	95e2                	add	a1,a1,s8
    80004da0:	855a                	mv	a0,s6
    80004da2:	ffffc097          	auipc	ra,0xffffc
    80004da6:	33e080e7          	jalr	830(ra) # 800010e0 <walkaddr>
    80004daa:	862a                	mv	a2,a0
    if(pa == 0)
    80004dac:	dd45                	beqz	a0,80004d64 <exec+0xfe>
      n = PGSIZE;
    80004dae:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004db0:	fd49f2e3          	bgeu	s3,s4,80004d74 <exec+0x10e>
      n = sz - i;
    80004db4:	894e                	mv	s2,s3
    80004db6:	bf7d                	j	80004d74 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004db8:	4481                	li	s1,0
  iunlockput(ip);
    80004dba:	8556                	mv	a0,s5
    80004dbc:	fffff097          	auipc	ra,0xfffff
    80004dc0:	bf8080e7          	jalr	-1032(ra) # 800039b4 <iunlockput>
  end_op();
    80004dc4:	fffff097          	auipc	ra,0xfffff
    80004dc8:	3ca080e7          	jalr	970(ra) # 8000418e <end_op>
  p = myproc();
    80004dcc:	ffffd097          	auipc	ra,0xffffd
    80004dd0:	c56080e7          	jalr	-938(ra) # 80001a22 <myproc>
    80004dd4:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004dd6:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004dda:	6785                	lui	a5,0x1
    80004ddc:	17fd                	addi	a5,a5,-1
    80004dde:	94be                	add	s1,s1,a5
    80004de0:	77fd                	lui	a5,0xfffff
    80004de2:	8fe5                	and	a5,a5,s1
    80004de4:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004de8:	6609                	lui	a2,0x2
    80004dea:	963e                	add	a2,a2,a5
    80004dec:	85be                	mv	a1,a5
    80004dee:	855a                	mv	a0,s6
    80004df0:	ffffc097          	auipc	ra,0xffffc
    80004df4:	6d4080e7          	jalr	1748(ra) # 800014c4 <uvmalloc>
    80004df8:	8c2a                	mv	s8,a0
  ip = 0;
    80004dfa:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dfc:	12050e63          	beqz	a0,80004f38 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e00:	75f9                	lui	a1,0xffffe
    80004e02:	95aa                	add	a1,a1,a0
    80004e04:	855a                	mv	a0,s6
    80004e06:	ffffd097          	auipc	ra,0xffffd
    80004e0a:	8dc080e7          	jalr	-1828(ra) # 800016e2 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e0e:	7afd                	lui	s5,0xfffff
    80004e10:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e12:	df043783          	ld	a5,-528(s0)
    80004e16:	6388                	ld	a0,0(a5)
    80004e18:	c925                	beqz	a0,80004e88 <exec+0x222>
    80004e1a:	e8840993          	addi	s3,s0,-376
    80004e1e:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004e22:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e24:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004e26:	ffffc097          	auipc	ra,0xffffc
    80004e2a:	0b0080e7          	jalr	176(ra) # 80000ed6 <strlen>
    80004e2e:	0015079b          	addiw	a5,a0,1
    80004e32:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e36:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e3a:	13596363          	bltu	s2,s5,80004f60 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e3e:	df043d83          	ld	s11,-528(s0)
    80004e42:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004e46:	8552                	mv	a0,s4
    80004e48:	ffffc097          	auipc	ra,0xffffc
    80004e4c:	08e080e7          	jalr	142(ra) # 80000ed6 <strlen>
    80004e50:	0015069b          	addiw	a3,a0,1
    80004e54:	8652                	mv	a2,s4
    80004e56:	85ca                	mv	a1,s2
    80004e58:	855a                	mv	a0,s6
    80004e5a:	ffffd097          	auipc	ra,0xffffd
    80004e5e:	8ba080e7          	jalr	-1862(ra) # 80001714 <copyout>
    80004e62:	10054363          	bltz	a0,80004f68 <exec+0x302>
    ustack[argc] = sp;
    80004e66:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e6a:	0485                	addi	s1,s1,1
    80004e6c:	008d8793          	addi	a5,s11,8
    80004e70:	def43823          	sd	a5,-528(s0)
    80004e74:	008db503          	ld	a0,8(s11)
    80004e78:	c911                	beqz	a0,80004e8c <exec+0x226>
    if(argc >= MAXARG)
    80004e7a:	09a1                	addi	s3,s3,8
    80004e7c:	fb3c95e3          	bne	s9,s3,80004e26 <exec+0x1c0>
  sz = sz1;
    80004e80:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e84:	4a81                	li	s5,0
    80004e86:	a84d                	j	80004f38 <exec+0x2d2>
  sp = sz;
    80004e88:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e8a:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e8c:	00349793          	slli	a5,s1,0x3
    80004e90:	f9040713          	addi	a4,s0,-112
    80004e94:	97ba                	add	a5,a5,a4
    80004e96:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004e9a:	00148693          	addi	a3,s1,1
    80004e9e:	068e                	slli	a3,a3,0x3
    80004ea0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ea4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004ea8:	01597663          	bgeu	s2,s5,80004eb4 <exec+0x24e>
  sz = sz1;
    80004eac:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eb0:	4a81                	li	s5,0
    80004eb2:	a059                	j	80004f38 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004eb4:	e8840613          	addi	a2,s0,-376
    80004eb8:	85ca                	mv	a1,s2
    80004eba:	855a                	mv	a0,s6
    80004ebc:	ffffd097          	auipc	ra,0xffffd
    80004ec0:	858080e7          	jalr	-1960(ra) # 80001714 <copyout>
    80004ec4:	0a054663          	bltz	a0,80004f70 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004ec8:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004ecc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ed0:	de843783          	ld	a5,-536(s0)
    80004ed4:	0007c703          	lbu	a4,0(a5)
    80004ed8:	cf11                	beqz	a4,80004ef4 <exec+0x28e>
    80004eda:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004edc:	02f00693          	li	a3,47
    80004ee0:	a039                	j	80004eee <exec+0x288>
      last = s+1;
    80004ee2:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004ee6:	0785                	addi	a5,a5,1
    80004ee8:	fff7c703          	lbu	a4,-1(a5)
    80004eec:	c701                	beqz	a4,80004ef4 <exec+0x28e>
    if(*s == '/')
    80004eee:	fed71ce3          	bne	a4,a3,80004ee6 <exec+0x280>
    80004ef2:	bfc5                	j	80004ee2 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ef4:	4641                	li	a2,16
    80004ef6:	de843583          	ld	a1,-536(s0)
    80004efa:	158b8513          	addi	a0,s7,344
    80004efe:	ffffc097          	auipc	ra,0xffffc
    80004f02:	fa6080e7          	jalr	-90(ra) # 80000ea4 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f06:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004f0a:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004f0e:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f12:	058bb783          	ld	a5,88(s7)
    80004f16:	e6043703          	ld	a4,-416(s0)
    80004f1a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f1c:	058bb783          	ld	a5,88(s7)
    80004f20:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f24:	85ea                	mv	a1,s10
    80004f26:	ffffd097          	auipc	ra,0xffffd
    80004f2a:	c5c080e7          	jalr	-932(ra) # 80001b82 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f2e:	0004851b          	sext.w	a0,s1
    80004f32:	bbc1                	j	80004d02 <exec+0x9c>
    80004f34:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004f38:	df843583          	ld	a1,-520(s0)
    80004f3c:	855a                	mv	a0,s6
    80004f3e:	ffffd097          	auipc	ra,0xffffd
    80004f42:	c44080e7          	jalr	-956(ra) # 80001b82 <proc_freepagetable>
  if(ip){
    80004f46:	da0a94e3          	bnez	s5,80004cee <exec+0x88>
  return -1;
    80004f4a:	557d                	li	a0,-1
    80004f4c:	bb5d                	j	80004d02 <exec+0x9c>
    80004f4e:	de943c23          	sd	s1,-520(s0)
    80004f52:	b7dd                	j	80004f38 <exec+0x2d2>
    80004f54:	de943c23          	sd	s1,-520(s0)
    80004f58:	b7c5                	j	80004f38 <exec+0x2d2>
    80004f5a:	de943c23          	sd	s1,-520(s0)
    80004f5e:	bfe9                	j	80004f38 <exec+0x2d2>
  sz = sz1;
    80004f60:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f64:	4a81                	li	s5,0
    80004f66:	bfc9                	j	80004f38 <exec+0x2d2>
  sz = sz1;
    80004f68:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f6c:	4a81                	li	s5,0
    80004f6e:	b7e9                	j	80004f38 <exec+0x2d2>
  sz = sz1;
    80004f70:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f74:	4a81                	li	s5,0
    80004f76:	b7c9                	j	80004f38 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f78:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f7c:	e0843783          	ld	a5,-504(s0)
    80004f80:	0017869b          	addiw	a3,a5,1
    80004f84:	e0d43423          	sd	a3,-504(s0)
    80004f88:	e0043783          	ld	a5,-512(s0)
    80004f8c:	0387879b          	addiw	a5,a5,56
    80004f90:	e8045703          	lhu	a4,-384(s0)
    80004f94:	e2e6d3e3          	bge	a3,a4,80004dba <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f98:	2781                	sext.w	a5,a5
    80004f9a:	e0f43023          	sd	a5,-512(s0)
    80004f9e:	03800713          	li	a4,56
    80004fa2:	86be                	mv	a3,a5
    80004fa4:	e1040613          	addi	a2,s0,-496
    80004fa8:	4581                	li	a1,0
    80004faa:	8556                	mv	a0,s5
    80004fac:	fffff097          	auipc	ra,0xfffff
    80004fb0:	a5a080e7          	jalr	-1446(ra) # 80003a06 <readi>
    80004fb4:	03800793          	li	a5,56
    80004fb8:	f6f51ee3          	bne	a0,a5,80004f34 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004fbc:	e1042783          	lw	a5,-496(s0)
    80004fc0:	4705                	li	a4,1
    80004fc2:	fae79de3          	bne	a5,a4,80004f7c <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004fc6:	e3843603          	ld	a2,-456(s0)
    80004fca:	e3043783          	ld	a5,-464(s0)
    80004fce:	f8f660e3          	bltu	a2,a5,80004f4e <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fd2:	e2043783          	ld	a5,-480(s0)
    80004fd6:	963e                	add	a2,a2,a5
    80004fd8:	f6f66ee3          	bltu	a2,a5,80004f54 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fdc:	85a6                	mv	a1,s1
    80004fde:	855a                	mv	a0,s6
    80004fe0:	ffffc097          	auipc	ra,0xffffc
    80004fe4:	4e4080e7          	jalr	1252(ra) # 800014c4 <uvmalloc>
    80004fe8:	dea43c23          	sd	a0,-520(s0)
    80004fec:	d53d                	beqz	a0,80004f5a <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80004fee:	e2043c03          	ld	s8,-480(s0)
    80004ff2:	de043783          	ld	a5,-544(s0)
    80004ff6:	00fc77b3          	and	a5,s8,a5
    80004ffa:	ff9d                	bnez	a5,80004f38 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ffc:	e1842c83          	lw	s9,-488(s0)
    80005000:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005004:	f60b8ae3          	beqz	s7,80004f78 <exec+0x312>
    80005008:	89de                	mv	s3,s7
    8000500a:	4481                	li	s1,0
    8000500c:	b371                	j	80004d98 <exec+0x132>

000000008000500e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000500e:	7179                	addi	sp,sp,-48
    80005010:	f406                	sd	ra,40(sp)
    80005012:	f022                	sd	s0,32(sp)
    80005014:	ec26                	sd	s1,24(sp)
    80005016:	e84a                	sd	s2,16(sp)
    80005018:	1800                	addi	s0,sp,48
    8000501a:	892e                	mv	s2,a1
    8000501c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000501e:	fdc40593          	addi	a1,s0,-36
    80005022:	ffffe097          	auipc	ra,0xffffe
    80005026:	af0080e7          	jalr	-1296(ra) # 80002b12 <argint>
    8000502a:	04054063          	bltz	a0,8000506a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000502e:	fdc42703          	lw	a4,-36(s0)
    80005032:	47bd                	li	a5,15
    80005034:	02e7ed63          	bltu	a5,a4,8000506e <argfd+0x60>
    80005038:	ffffd097          	auipc	ra,0xffffd
    8000503c:	9ea080e7          	jalr	-1558(ra) # 80001a22 <myproc>
    80005040:	fdc42703          	lw	a4,-36(s0)
    80005044:	01a70793          	addi	a5,a4,26
    80005048:	078e                	slli	a5,a5,0x3
    8000504a:	953e                	add	a0,a0,a5
    8000504c:	611c                	ld	a5,0(a0)
    8000504e:	c395                	beqz	a5,80005072 <argfd+0x64>
    return -1;
  if(pfd)
    80005050:	00090463          	beqz	s2,80005058 <argfd+0x4a>
    *pfd = fd;
    80005054:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005058:	4501                	li	a0,0
  if(pf)
    8000505a:	c091                	beqz	s1,8000505e <argfd+0x50>
    *pf = f;
    8000505c:	e09c                	sd	a5,0(s1)
}
    8000505e:	70a2                	ld	ra,40(sp)
    80005060:	7402                	ld	s0,32(sp)
    80005062:	64e2                	ld	s1,24(sp)
    80005064:	6942                	ld	s2,16(sp)
    80005066:	6145                	addi	sp,sp,48
    80005068:	8082                	ret
    return -1;
    8000506a:	557d                	li	a0,-1
    8000506c:	bfcd                	j	8000505e <argfd+0x50>
    return -1;
    8000506e:	557d                	li	a0,-1
    80005070:	b7fd                	j	8000505e <argfd+0x50>
    80005072:	557d                	li	a0,-1
    80005074:	b7ed                	j	8000505e <argfd+0x50>

0000000080005076 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005076:	1101                	addi	sp,sp,-32
    80005078:	ec06                	sd	ra,24(sp)
    8000507a:	e822                	sd	s0,16(sp)
    8000507c:	e426                	sd	s1,8(sp)
    8000507e:	1000                	addi	s0,sp,32
    80005080:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005082:	ffffd097          	auipc	ra,0xffffd
    80005086:	9a0080e7          	jalr	-1632(ra) # 80001a22 <myproc>
    8000508a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000508c:	0d050793          	addi	a5,a0,208
    80005090:	4501                	li	a0,0
    80005092:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005094:	6398                	ld	a4,0(a5)
    80005096:	cb19                	beqz	a4,800050ac <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005098:	2505                	addiw	a0,a0,1
    8000509a:	07a1                	addi	a5,a5,8
    8000509c:	fed51ce3          	bne	a0,a3,80005094 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050a0:	557d                	li	a0,-1
}
    800050a2:	60e2                	ld	ra,24(sp)
    800050a4:	6442                	ld	s0,16(sp)
    800050a6:	64a2                	ld	s1,8(sp)
    800050a8:	6105                	addi	sp,sp,32
    800050aa:	8082                	ret
      p->ofile[fd] = f;
    800050ac:	01a50793          	addi	a5,a0,26
    800050b0:	078e                	slli	a5,a5,0x3
    800050b2:	963e                	add	a2,a2,a5
    800050b4:	e204                	sd	s1,0(a2)
      return fd;
    800050b6:	b7f5                	j	800050a2 <fdalloc+0x2c>

00000000800050b8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050b8:	715d                	addi	sp,sp,-80
    800050ba:	e486                	sd	ra,72(sp)
    800050bc:	e0a2                	sd	s0,64(sp)
    800050be:	fc26                	sd	s1,56(sp)
    800050c0:	f84a                	sd	s2,48(sp)
    800050c2:	f44e                	sd	s3,40(sp)
    800050c4:	f052                	sd	s4,32(sp)
    800050c6:	ec56                	sd	s5,24(sp)
    800050c8:	0880                	addi	s0,sp,80
    800050ca:	89ae                	mv	s3,a1
    800050cc:	8ab2                	mv	s5,a2
    800050ce:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050d0:	fb040593          	addi	a1,s0,-80
    800050d4:	fffff097          	auipc	ra,0xfffff
    800050d8:	e4c080e7          	jalr	-436(ra) # 80003f20 <nameiparent>
    800050dc:	892a                	mv	s2,a0
    800050de:	12050e63          	beqz	a0,8000521a <create+0x162>
    return 0;

  ilock(dp);
    800050e2:	ffffe097          	auipc	ra,0xffffe
    800050e6:	670080e7          	jalr	1648(ra) # 80003752 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050ea:	4601                	li	a2,0
    800050ec:	fb040593          	addi	a1,s0,-80
    800050f0:	854a                	mv	a0,s2
    800050f2:	fffff097          	auipc	ra,0xfffff
    800050f6:	b3e080e7          	jalr	-1218(ra) # 80003c30 <dirlookup>
    800050fa:	84aa                	mv	s1,a0
    800050fc:	c921                	beqz	a0,8000514c <create+0x94>
    iunlockput(dp);
    800050fe:	854a                	mv	a0,s2
    80005100:	fffff097          	auipc	ra,0xfffff
    80005104:	8b4080e7          	jalr	-1868(ra) # 800039b4 <iunlockput>
    ilock(ip);
    80005108:	8526                	mv	a0,s1
    8000510a:	ffffe097          	auipc	ra,0xffffe
    8000510e:	648080e7          	jalr	1608(ra) # 80003752 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005112:	2981                	sext.w	s3,s3
    80005114:	4789                	li	a5,2
    80005116:	02f99463          	bne	s3,a5,8000513e <create+0x86>
    8000511a:	0444d783          	lhu	a5,68(s1)
    8000511e:	37f9                	addiw	a5,a5,-2
    80005120:	17c2                	slli	a5,a5,0x30
    80005122:	93c1                	srli	a5,a5,0x30
    80005124:	4705                	li	a4,1
    80005126:	00f76c63          	bltu	a4,a5,8000513e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000512a:	8526                	mv	a0,s1
    8000512c:	60a6                	ld	ra,72(sp)
    8000512e:	6406                	ld	s0,64(sp)
    80005130:	74e2                	ld	s1,56(sp)
    80005132:	7942                	ld	s2,48(sp)
    80005134:	79a2                	ld	s3,40(sp)
    80005136:	7a02                	ld	s4,32(sp)
    80005138:	6ae2                	ld	s5,24(sp)
    8000513a:	6161                	addi	sp,sp,80
    8000513c:	8082                	ret
    iunlockput(ip);
    8000513e:	8526                	mv	a0,s1
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	874080e7          	jalr	-1932(ra) # 800039b4 <iunlockput>
    return 0;
    80005148:	4481                	li	s1,0
    8000514a:	b7c5                	j	8000512a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000514c:	85ce                	mv	a1,s3
    8000514e:	00092503          	lw	a0,0(s2)
    80005152:	ffffe097          	auipc	ra,0xffffe
    80005156:	468080e7          	jalr	1128(ra) # 800035ba <ialloc>
    8000515a:	84aa                	mv	s1,a0
    8000515c:	c521                	beqz	a0,800051a4 <create+0xec>
  ilock(ip);
    8000515e:	ffffe097          	auipc	ra,0xffffe
    80005162:	5f4080e7          	jalr	1524(ra) # 80003752 <ilock>
  ip->major = major;
    80005166:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000516a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000516e:	4a05                	li	s4,1
    80005170:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005174:	8526                	mv	a0,s1
    80005176:	ffffe097          	auipc	ra,0xffffe
    8000517a:	512080e7          	jalr	1298(ra) # 80003688 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000517e:	2981                	sext.w	s3,s3
    80005180:	03498a63          	beq	s3,s4,800051b4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005184:	40d0                	lw	a2,4(s1)
    80005186:	fb040593          	addi	a1,s0,-80
    8000518a:	854a                	mv	a0,s2
    8000518c:	fffff097          	auipc	ra,0xfffff
    80005190:	cb4080e7          	jalr	-844(ra) # 80003e40 <dirlink>
    80005194:	06054b63          	bltz	a0,8000520a <create+0x152>
  iunlockput(dp);
    80005198:	854a                	mv	a0,s2
    8000519a:	fffff097          	auipc	ra,0xfffff
    8000519e:	81a080e7          	jalr	-2022(ra) # 800039b4 <iunlockput>
  return ip;
    800051a2:	b761                	j	8000512a <create+0x72>
    panic("create: ialloc");
    800051a4:	00003517          	auipc	a0,0x3
    800051a8:	60450513          	addi	a0,a0,1540 # 800087a8 <syscalls+0x2b8>
    800051ac:	ffffb097          	auipc	ra,0xffffb
    800051b0:	3a4080e7          	jalr	932(ra) # 80000550 <panic>
    dp->nlink++;  // for ".."
    800051b4:	04a95783          	lhu	a5,74(s2)
    800051b8:	2785                	addiw	a5,a5,1
    800051ba:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800051be:	854a                	mv	a0,s2
    800051c0:	ffffe097          	auipc	ra,0xffffe
    800051c4:	4c8080e7          	jalr	1224(ra) # 80003688 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051c8:	40d0                	lw	a2,4(s1)
    800051ca:	00003597          	auipc	a1,0x3
    800051ce:	5ee58593          	addi	a1,a1,1518 # 800087b8 <syscalls+0x2c8>
    800051d2:	8526                	mv	a0,s1
    800051d4:	fffff097          	auipc	ra,0xfffff
    800051d8:	c6c080e7          	jalr	-916(ra) # 80003e40 <dirlink>
    800051dc:	00054f63          	bltz	a0,800051fa <create+0x142>
    800051e0:	00492603          	lw	a2,4(s2)
    800051e4:	00003597          	auipc	a1,0x3
    800051e8:	5dc58593          	addi	a1,a1,1500 # 800087c0 <syscalls+0x2d0>
    800051ec:	8526                	mv	a0,s1
    800051ee:	fffff097          	auipc	ra,0xfffff
    800051f2:	c52080e7          	jalr	-942(ra) # 80003e40 <dirlink>
    800051f6:	f80557e3          	bgez	a0,80005184 <create+0xcc>
      panic("create dots");
    800051fa:	00003517          	auipc	a0,0x3
    800051fe:	5ce50513          	addi	a0,a0,1486 # 800087c8 <syscalls+0x2d8>
    80005202:	ffffb097          	auipc	ra,0xffffb
    80005206:	34e080e7          	jalr	846(ra) # 80000550 <panic>
    panic("create: dirlink");
    8000520a:	00003517          	auipc	a0,0x3
    8000520e:	5ce50513          	addi	a0,a0,1486 # 800087d8 <syscalls+0x2e8>
    80005212:	ffffb097          	auipc	ra,0xffffb
    80005216:	33e080e7          	jalr	830(ra) # 80000550 <panic>
    return 0;
    8000521a:	84aa                	mv	s1,a0
    8000521c:	b739                	j	8000512a <create+0x72>

000000008000521e <sys_dup>:
{
    8000521e:	7179                	addi	sp,sp,-48
    80005220:	f406                	sd	ra,40(sp)
    80005222:	f022                	sd	s0,32(sp)
    80005224:	ec26                	sd	s1,24(sp)
    80005226:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005228:	fd840613          	addi	a2,s0,-40
    8000522c:	4581                	li	a1,0
    8000522e:	4501                	li	a0,0
    80005230:	00000097          	auipc	ra,0x0
    80005234:	dde080e7          	jalr	-546(ra) # 8000500e <argfd>
    return -1;
    80005238:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000523a:	02054363          	bltz	a0,80005260 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000523e:	fd843503          	ld	a0,-40(s0)
    80005242:	00000097          	auipc	ra,0x0
    80005246:	e34080e7          	jalr	-460(ra) # 80005076 <fdalloc>
    8000524a:	84aa                	mv	s1,a0
    return -1;
    8000524c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000524e:	00054963          	bltz	a0,80005260 <sys_dup+0x42>
  filedup(f);
    80005252:	fd843503          	ld	a0,-40(s0)
    80005256:	fffff097          	auipc	ra,0xfffff
    8000525a:	338080e7          	jalr	824(ra) # 8000458e <filedup>
  return fd;
    8000525e:	87a6                	mv	a5,s1
}
    80005260:	853e                	mv	a0,a5
    80005262:	70a2                	ld	ra,40(sp)
    80005264:	7402                	ld	s0,32(sp)
    80005266:	64e2                	ld	s1,24(sp)
    80005268:	6145                	addi	sp,sp,48
    8000526a:	8082                	ret

000000008000526c <sys_read>:
{
    8000526c:	7179                	addi	sp,sp,-48
    8000526e:	f406                	sd	ra,40(sp)
    80005270:	f022                	sd	s0,32(sp)
    80005272:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005274:	fe840613          	addi	a2,s0,-24
    80005278:	4581                	li	a1,0
    8000527a:	4501                	li	a0,0
    8000527c:	00000097          	auipc	ra,0x0
    80005280:	d92080e7          	jalr	-622(ra) # 8000500e <argfd>
    return -1;
    80005284:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005286:	04054163          	bltz	a0,800052c8 <sys_read+0x5c>
    8000528a:	fe440593          	addi	a1,s0,-28
    8000528e:	4509                	li	a0,2
    80005290:	ffffe097          	auipc	ra,0xffffe
    80005294:	882080e7          	jalr	-1918(ra) # 80002b12 <argint>
    return -1;
    80005298:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000529a:	02054763          	bltz	a0,800052c8 <sys_read+0x5c>
    8000529e:	fd840593          	addi	a1,s0,-40
    800052a2:	4505                	li	a0,1
    800052a4:	ffffe097          	auipc	ra,0xffffe
    800052a8:	890080e7          	jalr	-1904(ra) # 80002b34 <argaddr>
    return -1;
    800052ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052ae:	00054d63          	bltz	a0,800052c8 <sys_read+0x5c>
  return fileread(f, p, n);
    800052b2:	fe442603          	lw	a2,-28(s0)
    800052b6:	fd843583          	ld	a1,-40(s0)
    800052ba:	fe843503          	ld	a0,-24(s0)
    800052be:	fffff097          	auipc	ra,0xfffff
    800052c2:	45c080e7          	jalr	1116(ra) # 8000471a <fileread>
    800052c6:	87aa                	mv	a5,a0
}
    800052c8:	853e                	mv	a0,a5
    800052ca:	70a2                	ld	ra,40(sp)
    800052cc:	7402                	ld	s0,32(sp)
    800052ce:	6145                	addi	sp,sp,48
    800052d0:	8082                	ret

00000000800052d2 <sys_write>:
{
    800052d2:	7179                	addi	sp,sp,-48
    800052d4:	f406                	sd	ra,40(sp)
    800052d6:	f022                	sd	s0,32(sp)
    800052d8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052da:	fe840613          	addi	a2,s0,-24
    800052de:	4581                	li	a1,0
    800052e0:	4501                	li	a0,0
    800052e2:	00000097          	auipc	ra,0x0
    800052e6:	d2c080e7          	jalr	-724(ra) # 8000500e <argfd>
    return -1;
    800052ea:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052ec:	04054163          	bltz	a0,8000532e <sys_write+0x5c>
    800052f0:	fe440593          	addi	a1,s0,-28
    800052f4:	4509                	li	a0,2
    800052f6:	ffffe097          	auipc	ra,0xffffe
    800052fa:	81c080e7          	jalr	-2020(ra) # 80002b12 <argint>
    return -1;
    800052fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005300:	02054763          	bltz	a0,8000532e <sys_write+0x5c>
    80005304:	fd840593          	addi	a1,s0,-40
    80005308:	4505                	li	a0,1
    8000530a:	ffffe097          	auipc	ra,0xffffe
    8000530e:	82a080e7          	jalr	-2006(ra) # 80002b34 <argaddr>
    return -1;
    80005312:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005314:	00054d63          	bltz	a0,8000532e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005318:	fe442603          	lw	a2,-28(s0)
    8000531c:	fd843583          	ld	a1,-40(s0)
    80005320:	fe843503          	ld	a0,-24(s0)
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	4b8080e7          	jalr	1208(ra) # 800047dc <filewrite>
    8000532c:	87aa                	mv	a5,a0
}
    8000532e:	853e                	mv	a0,a5
    80005330:	70a2                	ld	ra,40(sp)
    80005332:	7402                	ld	s0,32(sp)
    80005334:	6145                	addi	sp,sp,48
    80005336:	8082                	ret

0000000080005338 <sys_close>:
{
    80005338:	1101                	addi	sp,sp,-32
    8000533a:	ec06                	sd	ra,24(sp)
    8000533c:	e822                	sd	s0,16(sp)
    8000533e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005340:	fe040613          	addi	a2,s0,-32
    80005344:	fec40593          	addi	a1,s0,-20
    80005348:	4501                	li	a0,0
    8000534a:	00000097          	auipc	ra,0x0
    8000534e:	cc4080e7          	jalr	-828(ra) # 8000500e <argfd>
    return -1;
    80005352:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005354:	02054463          	bltz	a0,8000537c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005358:	ffffc097          	auipc	ra,0xffffc
    8000535c:	6ca080e7          	jalr	1738(ra) # 80001a22 <myproc>
    80005360:	fec42783          	lw	a5,-20(s0)
    80005364:	07e9                	addi	a5,a5,26
    80005366:	078e                	slli	a5,a5,0x3
    80005368:	97aa                	add	a5,a5,a0
    8000536a:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000536e:	fe043503          	ld	a0,-32(s0)
    80005372:	fffff097          	auipc	ra,0xfffff
    80005376:	26e080e7          	jalr	622(ra) # 800045e0 <fileclose>
  return 0;
    8000537a:	4781                	li	a5,0
}
    8000537c:	853e                	mv	a0,a5
    8000537e:	60e2                	ld	ra,24(sp)
    80005380:	6442                	ld	s0,16(sp)
    80005382:	6105                	addi	sp,sp,32
    80005384:	8082                	ret

0000000080005386 <sys_fstat>:
{
    80005386:	1101                	addi	sp,sp,-32
    80005388:	ec06                	sd	ra,24(sp)
    8000538a:	e822                	sd	s0,16(sp)
    8000538c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000538e:	fe840613          	addi	a2,s0,-24
    80005392:	4581                	li	a1,0
    80005394:	4501                	li	a0,0
    80005396:	00000097          	auipc	ra,0x0
    8000539a:	c78080e7          	jalr	-904(ra) # 8000500e <argfd>
    return -1;
    8000539e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053a0:	02054563          	bltz	a0,800053ca <sys_fstat+0x44>
    800053a4:	fe040593          	addi	a1,s0,-32
    800053a8:	4505                	li	a0,1
    800053aa:	ffffd097          	auipc	ra,0xffffd
    800053ae:	78a080e7          	jalr	1930(ra) # 80002b34 <argaddr>
    return -1;
    800053b2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053b4:	00054b63          	bltz	a0,800053ca <sys_fstat+0x44>
  return filestat(f, st);
    800053b8:	fe043583          	ld	a1,-32(s0)
    800053bc:	fe843503          	ld	a0,-24(s0)
    800053c0:	fffff097          	auipc	ra,0xfffff
    800053c4:	2e8080e7          	jalr	744(ra) # 800046a8 <filestat>
    800053c8:	87aa                	mv	a5,a0
}
    800053ca:	853e                	mv	a0,a5
    800053cc:	60e2                	ld	ra,24(sp)
    800053ce:	6442                	ld	s0,16(sp)
    800053d0:	6105                	addi	sp,sp,32
    800053d2:	8082                	ret

00000000800053d4 <sys_link>:
{
    800053d4:	7169                	addi	sp,sp,-304
    800053d6:	f606                	sd	ra,296(sp)
    800053d8:	f222                	sd	s0,288(sp)
    800053da:	ee26                	sd	s1,280(sp)
    800053dc:	ea4a                	sd	s2,272(sp)
    800053de:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053e0:	08000613          	li	a2,128
    800053e4:	ed040593          	addi	a1,s0,-304
    800053e8:	4501                	li	a0,0
    800053ea:	ffffd097          	auipc	ra,0xffffd
    800053ee:	76c080e7          	jalr	1900(ra) # 80002b56 <argstr>
    return -1;
    800053f2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053f4:	10054e63          	bltz	a0,80005510 <sys_link+0x13c>
    800053f8:	08000613          	li	a2,128
    800053fc:	f5040593          	addi	a1,s0,-176
    80005400:	4505                	li	a0,1
    80005402:	ffffd097          	auipc	ra,0xffffd
    80005406:	754080e7          	jalr	1876(ra) # 80002b56 <argstr>
    return -1;
    8000540a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000540c:	10054263          	bltz	a0,80005510 <sys_link+0x13c>
  begin_op();
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	cfe080e7          	jalr	-770(ra) # 8000410e <begin_op>
  if((ip = namei(old)) == 0){
    80005418:	ed040513          	addi	a0,s0,-304
    8000541c:	fffff097          	auipc	ra,0xfffff
    80005420:	ae6080e7          	jalr	-1306(ra) # 80003f02 <namei>
    80005424:	84aa                	mv	s1,a0
    80005426:	c551                	beqz	a0,800054b2 <sys_link+0xde>
  ilock(ip);
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	32a080e7          	jalr	810(ra) # 80003752 <ilock>
  if(ip->type == T_DIR){
    80005430:	04449703          	lh	a4,68(s1)
    80005434:	4785                	li	a5,1
    80005436:	08f70463          	beq	a4,a5,800054be <sys_link+0xea>
  ip->nlink++;
    8000543a:	04a4d783          	lhu	a5,74(s1)
    8000543e:	2785                	addiw	a5,a5,1
    80005440:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005444:	8526                	mv	a0,s1
    80005446:	ffffe097          	auipc	ra,0xffffe
    8000544a:	242080e7          	jalr	578(ra) # 80003688 <iupdate>
  iunlock(ip);
    8000544e:	8526                	mv	a0,s1
    80005450:	ffffe097          	auipc	ra,0xffffe
    80005454:	3c4080e7          	jalr	964(ra) # 80003814 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005458:	fd040593          	addi	a1,s0,-48
    8000545c:	f5040513          	addi	a0,s0,-176
    80005460:	fffff097          	auipc	ra,0xfffff
    80005464:	ac0080e7          	jalr	-1344(ra) # 80003f20 <nameiparent>
    80005468:	892a                	mv	s2,a0
    8000546a:	c935                	beqz	a0,800054de <sys_link+0x10a>
  ilock(dp);
    8000546c:	ffffe097          	auipc	ra,0xffffe
    80005470:	2e6080e7          	jalr	742(ra) # 80003752 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005474:	00092703          	lw	a4,0(s2)
    80005478:	409c                	lw	a5,0(s1)
    8000547a:	04f71d63          	bne	a4,a5,800054d4 <sys_link+0x100>
    8000547e:	40d0                	lw	a2,4(s1)
    80005480:	fd040593          	addi	a1,s0,-48
    80005484:	854a                	mv	a0,s2
    80005486:	fffff097          	auipc	ra,0xfffff
    8000548a:	9ba080e7          	jalr	-1606(ra) # 80003e40 <dirlink>
    8000548e:	04054363          	bltz	a0,800054d4 <sys_link+0x100>
  iunlockput(dp);
    80005492:	854a                	mv	a0,s2
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	520080e7          	jalr	1312(ra) # 800039b4 <iunlockput>
  iput(ip);
    8000549c:	8526                	mv	a0,s1
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	46e080e7          	jalr	1134(ra) # 8000390c <iput>
  end_op();
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	ce8080e7          	jalr	-792(ra) # 8000418e <end_op>
  return 0;
    800054ae:	4781                	li	a5,0
    800054b0:	a085                	j	80005510 <sys_link+0x13c>
    end_op();
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	cdc080e7          	jalr	-804(ra) # 8000418e <end_op>
    return -1;
    800054ba:	57fd                	li	a5,-1
    800054bc:	a891                	j	80005510 <sys_link+0x13c>
    iunlockput(ip);
    800054be:	8526                	mv	a0,s1
    800054c0:	ffffe097          	auipc	ra,0xffffe
    800054c4:	4f4080e7          	jalr	1268(ra) # 800039b4 <iunlockput>
    end_op();
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	cc6080e7          	jalr	-826(ra) # 8000418e <end_op>
    return -1;
    800054d0:	57fd                	li	a5,-1
    800054d2:	a83d                	j	80005510 <sys_link+0x13c>
    iunlockput(dp);
    800054d4:	854a                	mv	a0,s2
    800054d6:	ffffe097          	auipc	ra,0xffffe
    800054da:	4de080e7          	jalr	1246(ra) # 800039b4 <iunlockput>
  ilock(ip);
    800054de:	8526                	mv	a0,s1
    800054e0:	ffffe097          	auipc	ra,0xffffe
    800054e4:	272080e7          	jalr	626(ra) # 80003752 <ilock>
  ip->nlink--;
    800054e8:	04a4d783          	lhu	a5,74(s1)
    800054ec:	37fd                	addiw	a5,a5,-1
    800054ee:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054f2:	8526                	mv	a0,s1
    800054f4:	ffffe097          	auipc	ra,0xffffe
    800054f8:	194080e7          	jalr	404(ra) # 80003688 <iupdate>
  iunlockput(ip);
    800054fc:	8526                	mv	a0,s1
    800054fe:	ffffe097          	auipc	ra,0xffffe
    80005502:	4b6080e7          	jalr	1206(ra) # 800039b4 <iunlockput>
  end_op();
    80005506:	fffff097          	auipc	ra,0xfffff
    8000550a:	c88080e7          	jalr	-888(ra) # 8000418e <end_op>
  return -1;
    8000550e:	57fd                	li	a5,-1
}
    80005510:	853e                	mv	a0,a5
    80005512:	70b2                	ld	ra,296(sp)
    80005514:	7412                	ld	s0,288(sp)
    80005516:	64f2                	ld	s1,280(sp)
    80005518:	6952                	ld	s2,272(sp)
    8000551a:	6155                	addi	sp,sp,304
    8000551c:	8082                	ret

000000008000551e <sys_unlink>:
{
    8000551e:	7151                	addi	sp,sp,-240
    80005520:	f586                	sd	ra,232(sp)
    80005522:	f1a2                	sd	s0,224(sp)
    80005524:	eda6                	sd	s1,216(sp)
    80005526:	e9ca                	sd	s2,208(sp)
    80005528:	e5ce                	sd	s3,200(sp)
    8000552a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000552c:	08000613          	li	a2,128
    80005530:	f3040593          	addi	a1,s0,-208
    80005534:	4501                	li	a0,0
    80005536:	ffffd097          	auipc	ra,0xffffd
    8000553a:	620080e7          	jalr	1568(ra) # 80002b56 <argstr>
    8000553e:	18054163          	bltz	a0,800056c0 <sys_unlink+0x1a2>
  begin_op();
    80005542:	fffff097          	auipc	ra,0xfffff
    80005546:	bcc080e7          	jalr	-1076(ra) # 8000410e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000554a:	fb040593          	addi	a1,s0,-80
    8000554e:	f3040513          	addi	a0,s0,-208
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	9ce080e7          	jalr	-1586(ra) # 80003f20 <nameiparent>
    8000555a:	84aa                	mv	s1,a0
    8000555c:	c979                	beqz	a0,80005632 <sys_unlink+0x114>
  ilock(dp);
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	1f4080e7          	jalr	500(ra) # 80003752 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005566:	00003597          	auipc	a1,0x3
    8000556a:	25258593          	addi	a1,a1,594 # 800087b8 <syscalls+0x2c8>
    8000556e:	fb040513          	addi	a0,s0,-80
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	6a4080e7          	jalr	1700(ra) # 80003c16 <namecmp>
    8000557a:	14050a63          	beqz	a0,800056ce <sys_unlink+0x1b0>
    8000557e:	00003597          	auipc	a1,0x3
    80005582:	24258593          	addi	a1,a1,578 # 800087c0 <syscalls+0x2d0>
    80005586:	fb040513          	addi	a0,s0,-80
    8000558a:	ffffe097          	auipc	ra,0xffffe
    8000558e:	68c080e7          	jalr	1676(ra) # 80003c16 <namecmp>
    80005592:	12050e63          	beqz	a0,800056ce <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005596:	f2c40613          	addi	a2,s0,-212
    8000559a:	fb040593          	addi	a1,s0,-80
    8000559e:	8526                	mv	a0,s1
    800055a0:	ffffe097          	auipc	ra,0xffffe
    800055a4:	690080e7          	jalr	1680(ra) # 80003c30 <dirlookup>
    800055a8:	892a                	mv	s2,a0
    800055aa:	12050263          	beqz	a0,800056ce <sys_unlink+0x1b0>
  ilock(ip);
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	1a4080e7          	jalr	420(ra) # 80003752 <ilock>
  if(ip->nlink < 1)
    800055b6:	04a91783          	lh	a5,74(s2)
    800055ba:	08f05263          	blez	a5,8000563e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055be:	04491703          	lh	a4,68(s2)
    800055c2:	4785                	li	a5,1
    800055c4:	08f70563          	beq	a4,a5,8000564e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055c8:	4641                	li	a2,16
    800055ca:	4581                	li	a1,0
    800055cc:	fc040513          	addi	a0,s0,-64
    800055d0:	ffffb097          	auipc	ra,0xffffb
    800055d4:	782080e7          	jalr	1922(ra) # 80000d52 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055d8:	4741                	li	a4,16
    800055da:	f2c42683          	lw	a3,-212(s0)
    800055de:	fc040613          	addi	a2,s0,-64
    800055e2:	4581                	li	a1,0
    800055e4:	8526                	mv	a0,s1
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	516080e7          	jalr	1302(ra) # 80003afc <writei>
    800055ee:	47c1                	li	a5,16
    800055f0:	0af51563          	bne	a0,a5,8000569a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055f4:	04491703          	lh	a4,68(s2)
    800055f8:	4785                	li	a5,1
    800055fa:	0af70863          	beq	a4,a5,800056aa <sys_unlink+0x18c>
  iunlockput(dp);
    800055fe:	8526                	mv	a0,s1
    80005600:	ffffe097          	auipc	ra,0xffffe
    80005604:	3b4080e7          	jalr	948(ra) # 800039b4 <iunlockput>
  ip->nlink--;
    80005608:	04a95783          	lhu	a5,74(s2)
    8000560c:	37fd                	addiw	a5,a5,-1
    8000560e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005612:	854a                	mv	a0,s2
    80005614:	ffffe097          	auipc	ra,0xffffe
    80005618:	074080e7          	jalr	116(ra) # 80003688 <iupdate>
  iunlockput(ip);
    8000561c:	854a                	mv	a0,s2
    8000561e:	ffffe097          	auipc	ra,0xffffe
    80005622:	396080e7          	jalr	918(ra) # 800039b4 <iunlockput>
  end_op();
    80005626:	fffff097          	auipc	ra,0xfffff
    8000562a:	b68080e7          	jalr	-1176(ra) # 8000418e <end_op>
  return 0;
    8000562e:	4501                	li	a0,0
    80005630:	a84d                	j	800056e2 <sys_unlink+0x1c4>
    end_op();
    80005632:	fffff097          	auipc	ra,0xfffff
    80005636:	b5c080e7          	jalr	-1188(ra) # 8000418e <end_op>
    return -1;
    8000563a:	557d                	li	a0,-1
    8000563c:	a05d                	j	800056e2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000563e:	00003517          	auipc	a0,0x3
    80005642:	1aa50513          	addi	a0,a0,426 # 800087e8 <syscalls+0x2f8>
    80005646:	ffffb097          	auipc	ra,0xffffb
    8000564a:	f0a080e7          	jalr	-246(ra) # 80000550 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000564e:	04c92703          	lw	a4,76(s2)
    80005652:	02000793          	li	a5,32
    80005656:	f6e7f9e3          	bgeu	a5,a4,800055c8 <sys_unlink+0xaa>
    8000565a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000565e:	4741                	li	a4,16
    80005660:	86ce                	mv	a3,s3
    80005662:	f1840613          	addi	a2,s0,-232
    80005666:	4581                	li	a1,0
    80005668:	854a                	mv	a0,s2
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	39c080e7          	jalr	924(ra) # 80003a06 <readi>
    80005672:	47c1                	li	a5,16
    80005674:	00f51b63          	bne	a0,a5,8000568a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005678:	f1845783          	lhu	a5,-232(s0)
    8000567c:	e7a1                	bnez	a5,800056c4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000567e:	29c1                	addiw	s3,s3,16
    80005680:	04c92783          	lw	a5,76(s2)
    80005684:	fcf9ede3          	bltu	s3,a5,8000565e <sys_unlink+0x140>
    80005688:	b781                	j	800055c8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000568a:	00003517          	auipc	a0,0x3
    8000568e:	17650513          	addi	a0,a0,374 # 80008800 <syscalls+0x310>
    80005692:	ffffb097          	auipc	ra,0xffffb
    80005696:	ebe080e7          	jalr	-322(ra) # 80000550 <panic>
    panic("unlink: writei");
    8000569a:	00003517          	auipc	a0,0x3
    8000569e:	17e50513          	addi	a0,a0,382 # 80008818 <syscalls+0x328>
    800056a2:	ffffb097          	auipc	ra,0xffffb
    800056a6:	eae080e7          	jalr	-338(ra) # 80000550 <panic>
    dp->nlink--;
    800056aa:	04a4d783          	lhu	a5,74(s1)
    800056ae:	37fd                	addiw	a5,a5,-1
    800056b0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056b4:	8526                	mv	a0,s1
    800056b6:	ffffe097          	auipc	ra,0xffffe
    800056ba:	fd2080e7          	jalr	-46(ra) # 80003688 <iupdate>
    800056be:	b781                	j	800055fe <sys_unlink+0xe0>
    return -1;
    800056c0:	557d                	li	a0,-1
    800056c2:	a005                	j	800056e2 <sys_unlink+0x1c4>
    iunlockput(ip);
    800056c4:	854a                	mv	a0,s2
    800056c6:	ffffe097          	auipc	ra,0xffffe
    800056ca:	2ee080e7          	jalr	750(ra) # 800039b4 <iunlockput>
  iunlockput(dp);
    800056ce:	8526                	mv	a0,s1
    800056d0:	ffffe097          	auipc	ra,0xffffe
    800056d4:	2e4080e7          	jalr	740(ra) # 800039b4 <iunlockput>
  end_op();
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	ab6080e7          	jalr	-1354(ra) # 8000418e <end_op>
  return -1;
    800056e0:	557d                	li	a0,-1
}
    800056e2:	70ae                	ld	ra,232(sp)
    800056e4:	740e                	ld	s0,224(sp)
    800056e6:	64ee                	ld	s1,216(sp)
    800056e8:	694e                	ld	s2,208(sp)
    800056ea:	69ae                	ld	s3,200(sp)
    800056ec:	616d                	addi	sp,sp,240
    800056ee:	8082                	ret

00000000800056f0 <sys_open>:

uint64
sys_open(void)
{
    800056f0:	7131                	addi	sp,sp,-192
    800056f2:	fd06                	sd	ra,184(sp)
    800056f4:	f922                	sd	s0,176(sp)
    800056f6:	f526                	sd	s1,168(sp)
    800056f8:	f14a                	sd	s2,160(sp)
    800056fa:	ed4e                	sd	s3,152(sp)
    800056fc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800056fe:	08000613          	li	a2,128
    80005702:	f5040593          	addi	a1,s0,-176
    80005706:	4501                	li	a0,0
    80005708:	ffffd097          	auipc	ra,0xffffd
    8000570c:	44e080e7          	jalr	1102(ra) # 80002b56 <argstr>
    return -1;
    80005710:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005712:	0c054163          	bltz	a0,800057d4 <sys_open+0xe4>
    80005716:	f4c40593          	addi	a1,s0,-180
    8000571a:	4505                	li	a0,1
    8000571c:	ffffd097          	auipc	ra,0xffffd
    80005720:	3f6080e7          	jalr	1014(ra) # 80002b12 <argint>
    80005724:	0a054863          	bltz	a0,800057d4 <sys_open+0xe4>

  begin_op();
    80005728:	fffff097          	auipc	ra,0xfffff
    8000572c:	9e6080e7          	jalr	-1562(ra) # 8000410e <begin_op>

  if(omode & O_CREATE){
    80005730:	f4c42783          	lw	a5,-180(s0)
    80005734:	2007f793          	andi	a5,a5,512
    80005738:	cbdd                	beqz	a5,800057ee <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000573a:	4681                	li	a3,0
    8000573c:	4601                	li	a2,0
    8000573e:	4589                	li	a1,2
    80005740:	f5040513          	addi	a0,s0,-176
    80005744:	00000097          	auipc	ra,0x0
    80005748:	974080e7          	jalr	-1676(ra) # 800050b8 <create>
    8000574c:	892a                	mv	s2,a0
    if(ip == 0){
    8000574e:	c959                	beqz	a0,800057e4 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005750:	04491703          	lh	a4,68(s2)
    80005754:	478d                	li	a5,3
    80005756:	00f71763          	bne	a4,a5,80005764 <sys_open+0x74>
    8000575a:	04695703          	lhu	a4,70(s2)
    8000575e:	47a5                	li	a5,9
    80005760:	0ce7ec63          	bltu	a5,a4,80005838 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	dc0080e7          	jalr	-576(ra) # 80004524 <filealloc>
    8000576c:	89aa                	mv	s3,a0
    8000576e:	10050263          	beqz	a0,80005872 <sys_open+0x182>
    80005772:	00000097          	auipc	ra,0x0
    80005776:	904080e7          	jalr	-1788(ra) # 80005076 <fdalloc>
    8000577a:	84aa                	mv	s1,a0
    8000577c:	0e054663          	bltz	a0,80005868 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005780:	04491703          	lh	a4,68(s2)
    80005784:	478d                	li	a5,3
    80005786:	0cf70463          	beq	a4,a5,8000584e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000578a:	4789                	li	a5,2
    8000578c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005790:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005794:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005798:	f4c42783          	lw	a5,-180(s0)
    8000579c:	0017c713          	xori	a4,a5,1
    800057a0:	8b05                	andi	a4,a4,1
    800057a2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057a6:	0037f713          	andi	a4,a5,3
    800057aa:	00e03733          	snez	a4,a4
    800057ae:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057b2:	4007f793          	andi	a5,a5,1024
    800057b6:	c791                	beqz	a5,800057c2 <sys_open+0xd2>
    800057b8:	04491703          	lh	a4,68(s2)
    800057bc:	4789                	li	a5,2
    800057be:	08f70f63          	beq	a4,a5,8000585c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800057c2:	854a                	mv	a0,s2
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	050080e7          	jalr	80(ra) # 80003814 <iunlock>
  end_op();
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	9c2080e7          	jalr	-1598(ra) # 8000418e <end_op>

  return fd;
}
    800057d4:	8526                	mv	a0,s1
    800057d6:	70ea                	ld	ra,184(sp)
    800057d8:	744a                	ld	s0,176(sp)
    800057da:	74aa                	ld	s1,168(sp)
    800057dc:	790a                	ld	s2,160(sp)
    800057de:	69ea                	ld	s3,152(sp)
    800057e0:	6129                	addi	sp,sp,192
    800057e2:	8082                	ret
      end_op();
    800057e4:	fffff097          	auipc	ra,0xfffff
    800057e8:	9aa080e7          	jalr	-1622(ra) # 8000418e <end_op>
      return -1;
    800057ec:	b7e5                	j	800057d4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800057ee:	f5040513          	addi	a0,s0,-176
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	710080e7          	jalr	1808(ra) # 80003f02 <namei>
    800057fa:	892a                	mv	s2,a0
    800057fc:	c905                	beqz	a0,8000582c <sys_open+0x13c>
    ilock(ip);
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	f54080e7          	jalr	-172(ra) # 80003752 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005806:	04491703          	lh	a4,68(s2)
    8000580a:	4785                	li	a5,1
    8000580c:	f4f712e3          	bne	a4,a5,80005750 <sys_open+0x60>
    80005810:	f4c42783          	lw	a5,-180(s0)
    80005814:	dba1                	beqz	a5,80005764 <sys_open+0x74>
      iunlockput(ip);
    80005816:	854a                	mv	a0,s2
    80005818:	ffffe097          	auipc	ra,0xffffe
    8000581c:	19c080e7          	jalr	412(ra) # 800039b4 <iunlockput>
      end_op();
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	96e080e7          	jalr	-1682(ra) # 8000418e <end_op>
      return -1;
    80005828:	54fd                	li	s1,-1
    8000582a:	b76d                	j	800057d4 <sys_open+0xe4>
      end_op();
    8000582c:	fffff097          	auipc	ra,0xfffff
    80005830:	962080e7          	jalr	-1694(ra) # 8000418e <end_op>
      return -1;
    80005834:	54fd                	li	s1,-1
    80005836:	bf79                	j	800057d4 <sys_open+0xe4>
    iunlockput(ip);
    80005838:	854a                	mv	a0,s2
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	17a080e7          	jalr	378(ra) # 800039b4 <iunlockput>
    end_op();
    80005842:	fffff097          	auipc	ra,0xfffff
    80005846:	94c080e7          	jalr	-1716(ra) # 8000418e <end_op>
    return -1;
    8000584a:	54fd                	li	s1,-1
    8000584c:	b761                	j	800057d4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000584e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005852:	04691783          	lh	a5,70(s2)
    80005856:	02f99223          	sh	a5,36(s3)
    8000585a:	bf2d                	j	80005794 <sys_open+0xa4>
    itrunc(ip);
    8000585c:	854a                	mv	a0,s2
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	002080e7          	jalr	2(ra) # 80003860 <itrunc>
    80005866:	bfb1                	j	800057c2 <sys_open+0xd2>
      fileclose(f);
    80005868:	854e                	mv	a0,s3
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	d76080e7          	jalr	-650(ra) # 800045e0 <fileclose>
    iunlockput(ip);
    80005872:	854a                	mv	a0,s2
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	140080e7          	jalr	320(ra) # 800039b4 <iunlockput>
    end_op();
    8000587c:	fffff097          	auipc	ra,0xfffff
    80005880:	912080e7          	jalr	-1774(ra) # 8000418e <end_op>
    return -1;
    80005884:	54fd                	li	s1,-1
    80005886:	b7b9                	j	800057d4 <sys_open+0xe4>

0000000080005888 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005888:	7175                	addi	sp,sp,-144
    8000588a:	e506                	sd	ra,136(sp)
    8000588c:	e122                	sd	s0,128(sp)
    8000588e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	87e080e7          	jalr	-1922(ra) # 8000410e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005898:	08000613          	li	a2,128
    8000589c:	f7040593          	addi	a1,s0,-144
    800058a0:	4501                	li	a0,0
    800058a2:	ffffd097          	auipc	ra,0xffffd
    800058a6:	2b4080e7          	jalr	692(ra) # 80002b56 <argstr>
    800058aa:	02054963          	bltz	a0,800058dc <sys_mkdir+0x54>
    800058ae:	4681                	li	a3,0
    800058b0:	4601                	li	a2,0
    800058b2:	4585                	li	a1,1
    800058b4:	f7040513          	addi	a0,s0,-144
    800058b8:	00000097          	auipc	ra,0x0
    800058bc:	800080e7          	jalr	-2048(ra) # 800050b8 <create>
    800058c0:	cd11                	beqz	a0,800058dc <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	0f2080e7          	jalr	242(ra) # 800039b4 <iunlockput>
  end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	8c4080e7          	jalr	-1852(ra) # 8000418e <end_op>
  return 0;
    800058d2:	4501                	li	a0,0
}
    800058d4:	60aa                	ld	ra,136(sp)
    800058d6:	640a                	ld	s0,128(sp)
    800058d8:	6149                	addi	sp,sp,144
    800058da:	8082                	ret
    end_op();
    800058dc:	fffff097          	auipc	ra,0xfffff
    800058e0:	8b2080e7          	jalr	-1870(ra) # 8000418e <end_op>
    return -1;
    800058e4:	557d                	li	a0,-1
    800058e6:	b7fd                	j	800058d4 <sys_mkdir+0x4c>

00000000800058e8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058e8:	7135                	addi	sp,sp,-160
    800058ea:	ed06                	sd	ra,152(sp)
    800058ec:	e922                	sd	s0,144(sp)
    800058ee:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058f0:	fffff097          	auipc	ra,0xfffff
    800058f4:	81e080e7          	jalr	-2018(ra) # 8000410e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058f8:	08000613          	li	a2,128
    800058fc:	f7040593          	addi	a1,s0,-144
    80005900:	4501                	li	a0,0
    80005902:	ffffd097          	auipc	ra,0xffffd
    80005906:	254080e7          	jalr	596(ra) # 80002b56 <argstr>
    8000590a:	04054a63          	bltz	a0,8000595e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000590e:	f6c40593          	addi	a1,s0,-148
    80005912:	4505                	li	a0,1
    80005914:	ffffd097          	auipc	ra,0xffffd
    80005918:	1fe080e7          	jalr	510(ra) # 80002b12 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000591c:	04054163          	bltz	a0,8000595e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005920:	f6840593          	addi	a1,s0,-152
    80005924:	4509                	li	a0,2
    80005926:	ffffd097          	auipc	ra,0xffffd
    8000592a:	1ec080e7          	jalr	492(ra) # 80002b12 <argint>
     argint(1, &major) < 0 ||
    8000592e:	02054863          	bltz	a0,8000595e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005932:	f6841683          	lh	a3,-152(s0)
    80005936:	f6c41603          	lh	a2,-148(s0)
    8000593a:	458d                	li	a1,3
    8000593c:	f7040513          	addi	a0,s0,-144
    80005940:	fffff097          	auipc	ra,0xfffff
    80005944:	778080e7          	jalr	1912(ra) # 800050b8 <create>
     argint(2, &minor) < 0 ||
    80005948:	c919                	beqz	a0,8000595e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	06a080e7          	jalr	106(ra) # 800039b4 <iunlockput>
  end_op();
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	83c080e7          	jalr	-1988(ra) # 8000418e <end_op>
  return 0;
    8000595a:	4501                	li	a0,0
    8000595c:	a031                	j	80005968 <sys_mknod+0x80>
    end_op();
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	830080e7          	jalr	-2000(ra) # 8000418e <end_op>
    return -1;
    80005966:	557d                	li	a0,-1
}
    80005968:	60ea                	ld	ra,152(sp)
    8000596a:	644a                	ld	s0,144(sp)
    8000596c:	610d                	addi	sp,sp,160
    8000596e:	8082                	ret

0000000080005970 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005970:	7135                	addi	sp,sp,-160
    80005972:	ed06                	sd	ra,152(sp)
    80005974:	e922                	sd	s0,144(sp)
    80005976:	e526                	sd	s1,136(sp)
    80005978:	e14a                	sd	s2,128(sp)
    8000597a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000597c:	ffffc097          	auipc	ra,0xffffc
    80005980:	0a6080e7          	jalr	166(ra) # 80001a22 <myproc>
    80005984:	892a                	mv	s2,a0
  
  begin_op();
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	788080e7          	jalr	1928(ra) # 8000410e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000598e:	08000613          	li	a2,128
    80005992:	f6040593          	addi	a1,s0,-160
    80005996:	4501                	li	a0,0
    80005998:	ffffd097          	auipc	ra,0xffffd
    8000599c:	1be080e7          	jalr	446(ra) # 80002b56 <argstr>
    800059a0:	04054b63          	bltz	a0,800059f6 <sys_chdir+0x86>
    800059a4:	f6040513          	addi	a0,s0,-160
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	55a080e7          	jalr	1370(ra) # 80003f02 <namei>
    800059b0:	84aa                	mv	s1,a0
    800059b2:	c131                	beqz	a0,800059f6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	d9e080e7          	jalr	-610(ra) # 80003752 <ilock>
  if(ip->type != T_DIR){
    800059bc:	04449703          	lh	a4,68(s1)
    800059c0:	4785                	li	a5,1
    800059c2:	04f71063          	bne	a4,a5,80005a02 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059c6:	8526                	mv	a0,s1
    800059c8:	ffffe097          	auipc	ra,0xffffe
    800059cc:	e4c080e7          	jalr	-436(ra) # 80003814 <iunlock>
  iput(p->cwd);
    800059d0:	15093503          	ld	a0,336(s2)
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	f38080e7          	jalr	-200(ra) # 8000390c <iput>
  end_op();
    800059dc:	ffffe097          	auipc	ra,0xffffe
    800059e0:	7b2080e7          	jalr	1970(ra) # 8000418e <end_op>
  p->cwd = ip;
    800059e4:	14993823          	sd	s1,336(s2)
  return 0;
    800059e8:	4501                	li	a0,0
}
    800059ea:	60ea                	ld	ra,152(sp)
    800059ec:	644a                	ld	s0,144(sp)
    800059ee:	64aa                	ld	s1,136(sp)
    800059f0:	690a                	ld	s2,128(sp)
    800059f2:	610d                	addi	sp,sp,160
    800059f4:	8082                	ret
    end_op();
    800059f6:	ffffe097          	auipc	ra,0xffffe
    800059fa:	798080e7          	jalr	1944(ra) # 8000418e <end_op>
    return -1;
    800059fe:	557d                	li	a0,-1
    80005a00:	b7ed                	j	800059ea <sys_chdir+0x7a>
    iunlockput(ip);
    80005a02:	8526                	mv	a0,s1
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	fb0080e7          	jalr	-80(ra) # 800039b4 <iunlockput>
    end_op();
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	782080e7          	jalr	1922(ra) # 8000418e <end_op>
    return -1;
    80005a14:	557d                	li	a0,-1
    80005a16:	bfd1                	j	800059ea <sys_chdir+0x7a>

0000000080005a18 <sys_exec>:

uint64
sys_exec(void)
{
    80005a18:	7145                	addi	sp,sp,-464
    80005a1a:	e786                	sd	ra,456(sp)
    80005a1c:	e3a2                	sd	s0,448(sp)
    80005a1e:	ff26                	sd	s1,440(sp)
    80005a20:	fb4a                	sd	s2,432(sp)
    80005a22:	f74e                	sd	s3,424(sp)
    80005a24:	f352                	sd	s4,416(sp)
    80005a26:	ef56                	sd	s5,408(sp)
    80005a28:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a2a:	08000613          	li	a2,128
    80005a2e:	f4040593          	addi	a1,s0,-192
    80005a32:	4501                	li	a0,0
    80005a34:	ffffd097          	auipc	ra,0xffffd
    80005a38:	122080e7          	jalr	290(ra) # 80002b56 <argstr>
    return -1;
    80005a3c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a3e:	0c054a63          	bltz	a0,80005b12 <sys_exec+0xfa>
    80005a42:	e3840593          	addi	a1,s0,-456
    80005a46:	4505                	li	a0,1
    80005a48:	ffffd097          	auipc	ra,0xffffd
    80005a4c:	0ec080e7          	jalr	236(ra) # 80002b34 <argaddr>
    80005a50:	0c054163          	bltz	a0,80005b12 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005a54:	10000613          	li	a2,256
    80005a58:	4581                	li	a1,0
    80005a5a:	e4040513          	addi	a0,s0,-448
    80005a5e:	ffffb097          	auipc	ra,0xffffb
    80005a62:	2f4080e7          	jalr	756(ra) # 80000d52 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a66:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a6a:	89a6                	mv	s3,s1
    80005a6c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a6e:	02000a13          	li	s4,32
    80005a72:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a76:	00391793          	slli	a5,s2,0x3
    80005a7a:	e3040593          	addi	a1,s0,-464
    80005a7e:	e3843503          	ld	a0,-456(s0)
    80005a82:	953e                	add	a0,a0,a5
    80005a84:	ffffd097          	auipc	ra,0xffffd
    80005a88:	ff4080e7          	jalr	-12(ra) # 80002a78 <fetchaddr>
    80005a8c:	02054a63          	bltz	a0,80005ac0 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005a90:	e3043783          	ld	a5,-464(s0)
    80005a94:	c3b9                	beqz	a5,80005ada <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a96:	ffffb097          	auipc	ra,0xffffb
    80005a9a:	086080e7          	jalr	134(ra) # 80000b1c <kalloc>
    80005a9e:	85aa                	mv	a1,a0
    80005aa0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005aa4:	cd11                	beqz	a0,80005ac0 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005aa6:	6605                	lui	a2,0x1
    80005aa8:	e3043503          	ld	a0,-464(s0)
    80005aac:	ffffd097          	auipc	ra,0xffffd
    80005ab0:	01e080e7          	jalr	30(ra) # 80002aca <fetchstr>
    80005ab4:	00054663          	bltz	a0,80005ac0 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005ab8:	0905                	addi	s2,s2,1
    80005aba:	09a1                	addi	s3,s3,8
    80005abc:	fb491be3          	bne	s2,s4,80005a72 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ac0:	10048913          	addi	s2,s1,256
    80005ac4:	6088                	ld	a0,0(s1)
    80005ac6:	c529                	beqz	a0,80005b10 <sys_exec+0xf8>
    kfree(argv[i]);
    80005ac8:	ffffb097          	auipc	ra,0xffffb
    80005acc:	f58080e7          	jalr	-168(ra) # 80000a20 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ad0:	04a1                	addi	s1,s1,8
    80005ad2:	ff2499e3          	bne	s1,s2,80005ac4 <sys_exec+0xac>
  return -1;
    80005ad6:	597d                	li	s2,-1
    80005ad8:	a82d                	j	80005b12 <sys_exec+0xfa>
      argv[i] = 0;
    80005ada:	0a8e                	slli	s5,s5,0x3
    80005adc:	fc040793          	addi	a5,s0,-64
    80005ae0:	9abe                	add	s5,s5,a5
    80005ae2:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80005ae6:	e4040593          	addi	a1,s0,-448
    80005aea:	f4040513          	addi	a0,s0,-192
    80005aee:	fffff097          	auipc	ra,0xfffff
    80005af2:	178080e7          	jalr	376(ra) # 80004c66 <exec>
    80005af6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005af8:	10048993          	addi	s3,s1,256
    80005afc:	6088                	ld	a0,0(s1)
    80005afe:	c911                	beqz	a0,80005b12 <sys_exec+0xfa>
    kfree(argv[i]);
    80005b00:	ffffb097          	auipc	ra,0xffffb
    80005b04:	f20080e7          	jalr	-224(ra) # 80000a20 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b08:	04a1                	addi	s1,s1,8
    80005b0a:	ff3499e3          	bne	s1,s3,80005afc <sys_exec+0xe4>
    80005b0e:	a011                	j	80005b12 <sys_exec+0xfa>
  return -1;
    80005b10:	597d                	li	s2,-1
}
    80005b12:	854a                	mv	a0,s2
    80005b14:	60be                	ld	ra,456(sp)
    80005b16:	641e                	ld	s0,448(sp)
    80005b18:	74fa                	ld	s1,440(sp)
    80005b1a:	795a                	ld	s2,432(sp)
    80005b1c:	79ba                	ld	s3,424(sp)
    80005b1e:	7a1a                	ld	s4,416(sp)
    80005b20:	6afa                	ld	s5,408(sp)
    80005b22:	6179                	addi	sp,sp,464
    80005b24:	8082                	ret

0000000080005b26 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b26:	7139                	addi	sp,sp,-64
    80005b28:	fc06                	sd	ra,56(sp)
    80005b2a:	f822                	sd	s0,48(sp)
    80005b2c:	f426                	sd	s1,40(sp)
    80005b2e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b30:	ffffc097          	auipc	ra,0xffffc
    80005b34:	ef2080e7          	jalr	-270(ra) # 80001a22 <myproc>
    80005b38:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b3a:	fd840593          	addi	a1,s0,-40
    80005b3e:	4501                	li	a0,0
    80005b40:	ffffd097          	auipc	ra,0xffffd
    80005b44:	ff4080e7          	jalr	-12(ra) # 80002b34 <argaddr>
    return -1;
    80005b48:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b4a:	0e054063          	bltz	a0,80005c2a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b4e:	fc840593          	addi	a1,s0,-56
    80005b52:	fd040513          	addi	a0,s0,-48
    80005b56:	fffff097          	auipc	ra,0xfffff
    80005b5a:	de0080e7          	jalr	-544(ra) # 80004936 <pipealloc>
    return -1;
    80005b5e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b60:	0c054563          	bltz	a0,80005c2a <sys_pipe+0x104>
  fd0 = -1;
    80005b64:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b68:	fd043503          	ld	a0,-48(s0)
    80005b6c:	fffff097          	auipc	ra,0xfffff
    80005b70:	50a080e7          	jalr	1290(ra) # 80005076 <fdalloc>
    80005b74:	fca42223          	sw	a0,-60(s0)
    80005b78:	08054c63          	bltz	a0,80005c10 <sys_pipe+0xea>
    80005b7c:	fc843503          	ld	a0,-56(s0)
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	4f6080e7          	jalr	1270(ra) # 80005076 <fdalloc>
    80005b88:	fca42023          	sw	a0,-64(s0)
    80005b8c:	06054863          	bltz	a0,80005bfc <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b90:	4691                	li	a3,4
    80005b92:	fc440613          	addi	a2,s0,-60
    80005b96:	fd843583          	ld	a1,-40(s0)
    80005b9a:	68a8                	ld	a0,80(s1)
    80005b9c:	ffffc097          	auipc	ra,0xffffc
    80005ba0:	b78080e7          	jalr	-1160(ra) # 80001714 <copyout>
    80005ba4:	02054063          	bltz	a0,80005bc4 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ba8:	4691                	li	a3,4
    80005baa:	fc040613          	addi	a2,s0,-64
    80005bae:	fd843583          	ld	a1,-40(s0)
    80005bb2:	0591                	addi	a1,a1,4
    80005bb4:	68a8                	ld	a0,80(s1)
    80005bb6:	ffffc097          	auipc	ra,0xffffc
    80005bba:	b5e080e7          	jalr	-1186(ra) # 80001714 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bbe:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bc0:	06055563          	bgez	a0,80005c2a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005bc4:	fc442783          	lw	a5,-60(s0)
    80005bc8:	07e9                	addi	a5,a5,26
    80005bca:	078e                	slli	a5,a5,0x3
    80005bcc:	97a6                	add	a5,a5,s1
    80005bce:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bd2:	fc042503          	lw	a0,-64(s0)
    80005bd6:	0569                	addi	a0,a0,26
    80005bd8:	050e                	slli	a0,a0,0x3
    80005bda:	9526                	add	a0,a0,s1
    80005bdc:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005be0:	fd043503          	ld	a0,-48(s0)
    80005be4:	fffff097          	auipc	ra,0xfffff
    80005be8:	9fc080e7          	jalr	-1540(ra) # 800045e0 <fileclose>
    fileclose(wf);
    80005bec:	fc843503          	ld	a0,-56(s0)
    80005bf0:	fffff097          	auipc	ra,0xfffff
    80005bf4:	9f0080e7          	jalr	-1552(ra) # 800045e0 <fileclose>
    return -1;
    80005bf8:	57fd                	li	a5,-1
    80005bfa:	a805                	j	80005c2a <sys_pipe+0x104>
    if(fd0 >= 0)
    80005bfc:	fc442783          	lw	a5,-60(s0)
    80005c00:	0007c863          	bltz	a5,80005c10 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c04:	01a78513          	addi	a0,a5,26
    80005c08:	050e                	slli	a0,a0,0x3
    80005c0a:	9526                	add	a0,a0,s1
    80005c0c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c10:	fd043503          	ld	a0,-48(s0)
    80005c14:	fffff097          	auipc	ra,0xfffff
    80005c18:	9cc080e7          	jalr	-1588(ra) # 800045e0 <fileclose>
    fileclose(wf);
    80005c1c:	fc843503          	ld	a0,-56(s0)
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	9c0080e7          	jalr	-1600(ra) # 800045e0 <fileclose>
    return -1;
    80005c28:	57fd                	li	a5,-1
}
    80005c2a:	853e                	mv	a0,a5
    80005c2c:	70e2                	ld	ra,56(sp)
    80005c2e:	7442                	ld	s0,48(sp)
    80005c30:	74a2                	ld	s1,40(sp)
    80005c32:	6121                	addi	sp,sp,64
    80005c34:	8082                	ret
	...

0000000080005c40 <kernelvec>:
    80005c40:	7111                	addi	sp,sp,-256
    80005c42:	e006                	sd	ra,0(sp)
    80005c44:	e40a                	sd	sp,8(sp)
    80005c46:	e80e                	sd	gp,16(sp)
    80005c48:	ec12                	sd	tp,24(sp)
    80005c4a:	f016                	sd	t0,32(sp)
    80005c4c:	f41a                	sd	t1,40(sp)
    80005c4e:	f81e                	sd	t2,48(sp)
    80005c50:	fc22                	sd	s0,56(sp)
    80005c52:	e0a6                	sd	s1,64(sp)
    80005c54:	e4aa                	sd	a0,72(sp)
    80005c56:	e8ae                	sd	a1,80(sp)
    80005c58:	ecb2                	sd	a2,88(sp)
    80005c5a:	f0b6                	sd	a3,96(sp)
    80005c5c:	f4ba                	sd	a4,104(sp)
    80005c5e:	f8be                	sd	a5,112(sp)
    80005c60:	fcc2                	sd	a6,120(sp)
    80005c62:	e146                	sd	a7,128(sp)
    80005c64:	e54a                	sd	s2,136(sp)
    80005c66:	e94e                	sd	s3,144(sp)
    80005c68:	ed52                	sd	s4,152(sp)
    80005c6a:	f156                	sd	s5,160(sp)
    80005c6c:	f55a                	sd	s6,168(sp)
    80005c6e:	f95e                	sd	s7,176(sp)
    80005c70:	fd62                	sd	s8,184(sp)
    80005c72:	e1e6                	sd	s9,192(sp)
    80005c74:	e5ea                	sd	s10,200(sp)
    80005c76:	e9ee                	sd	s11,208(sp)
    80005c78:	edf2                	sd	t3,216(sp)
    80005c7a:	f1f6                	sd	t4,224(sp)
    80005c7c:	f5fa                	sd	t5,232(sp)
    80005c7e:	f9fe                	sd	t6,240(sp)
    80005c80:	cc5fc0ef          	jal	ra,80002944 <kerneltrap>
    80005c84:	6082                	ld	ra,0(sp)
    80005c86:	6122                	ld	sp,8(sp)
    80005c88:	61c2                	ld	gp,16(sp)
    80005c8a:	7282                	ld	t0,32(sp)
    80005c8c:	7322                	ld	t1,40(sp)
    80005c8e:	73c2                	ld	t2,48(sp)
    80005c90:	7462                	ld	s0,56(sp)
    80005c92:	6486                	ld	s1,64(sp)
    80005c94:	6526                	ld	a0,72(sp)
    80005c96:	65c6                	ld	a1,80(sp)
    80005c98:	6666                	ld	a2,88(sp)
    80005c9a:	7686                	ld	a3,96(sp)
    80005c9c:	7726                	ld	a4,104(sp)
    80005c9e:	77c6                	ld	a5,112(sp)
    80005ca0:	7866                	ld	a6,120(sp)
    80005ca2:	688a                	ld	a7,128(sp)
    80005ca4:	692a                	ld	s2,136(sp)
    80005ca6:	69ca                	ld	s3,144(sp)
    80005ca8:	6a6a                	ld	s4,152(sp)
    80005caa:	7a8a                	ld	s5,160(sp)
    80005cac:	7b2a                	ld	s6,168(sp)
    80005cae:	7bca                	ld	s7,176(sp)
    80005cb0:	7c6a                	ld	s8,184(sp)
    80005cb2:	6c8e                	ld	s9,192(sp)
    80005cb4:	6d2e                	ld	s10,200(sp)
    80005cb6:	6dce                	ld	s11,208(sp)
    80005cb8:	6e6e                	ld	t3,216(sp)
    80005cba:	7e8e                	ld	t4,224(sp)
    80005cbc:	7f2e                	ld	t5,232(sp)
    80005cbe:	7fce                	ld	t6,240(sp)
    80005cc0:	6111                	addi	sp,sp,256
    80005cc2:	10200073          	sret

0000000080005cc6 <unexpected_exc>:
    80005cc6:	a001                	j	80005cc6 <unexpected_exc>

0000000080005cc8 <unexpected_int>:
    80005cc8:	a001                	j	80005cc8 <unexpected_int>
    80005cca:	00000013          	nop
    80005cce:	0001                	nop

0000000080005cd0 <timervec>:
    80005cd0:	34051573          	csrrw	a0,mscratch,a0
    80005cd4:	e10c                	sd	a1,0(a0)
    80005cd6:	e510                	sd	a2,8(a0)
    80005cd8:	e914                	sd	a3,16(a0)
    80005cda:	342025f3          	csrr	a1,mcause
    80005cde:	fe05d4e3          	bgez	a1,80005cc6 <unexpected_exc>
    80005ce2:	fff0061b          	addiw	a2,zero,-1
    80005ce6:	167e                	slli	a2,a2,0x3f
    80005ce8:	061d                	addi	a2,a2,7
    80005cea:	fcc59fe3          	bne	a1,a2,80005cc8 <unexpected_int>
    80005cee:	710c                	ld	a1,32(a0)
    80005cf0:	7510                	ld	a2,40(a0)
    80005cf2:	6194                	ld	a3,0(a1)
    80005cf4:	96b2                	add	a3,a3,a2
    80005cf6:	e194                	sd	a3,0(a1)
    80005cf8:	4589                	li	a1,2
    80005cfa:	14459073          	csrw	sip,a1
    80005cfe:	6914                	ld	a3,16(a0)
    80005d00:	6510                	ld	a2,8(a0)
    80005d02:	610c                	ld	a1,0(a0)
    80005d04:	34051573          	csrrw	a0,mscratch,a0
    80005d08:	30200073          	mret
	...

0000000080005d16 <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d16:	1141                	addi	sp,sp,-16
    80005d18:	e422                	sd	s0,8(sp)
    80005d1a:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d1c:	0c0007b7          	lui	a5,0xc000
    80005d20:	4705                	li	a4,1
    80005d22:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d24:	c3d8                	sw	a4,4(a5)
}
    80005d26:	6422                	ld	s0,8(sp)
    80005d28:	0141                	addi	sp,sp,16
    80005d2a:	8082                	ret

0000000080005d2c <plicinithart>:

void
plicinithart(void)
{
    80005d2c:	1141                	addi	sp,sp,-16
    80005d2e:	e406                	sd	ra,8(sp)
    80005d30:	e022                	sd	s0,0(sp)
    80005d32:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d34:	ffffc097          	auipc	ra,0xffffc
    80005d38:	cc2080e7          	jalr	-830(ra) # 800019f6 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d3c:	0085171b          	slliw	a4,a0,0x8
    80005d40:	0c0027b7          	lui	a5,0xc002
    80005d44:	97ba                	add	a5,a5,a4
    80005d46:	40200713          	li	a4,1026
    80005d4a:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d4e:	00d5151b          	slliw	a0,a0,0xd
    80005d52:	0c2017b7          	lui	a5,0xc201
    80005d56:	953e                	add	a0,a0,a5
    80005d58:	00052023          	sw	zero,0(a0)
}
    80005d5c:	60a2                	ld	ra,8(sp)
    80005d5e:	6402                	ld	s0,0(sp)
    80005d60:	0141                	addi	sp,sp,16
    80005d62:	8082                	ret

0000000080005d64 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d64:	1141                	addi	sp,sp,-16
    80005d66:	e406                	sd	ra,8(sp)
    80005d68:	e022                	sd	s0,0(sp)
    80005d6a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d6c:	ffffc097          	auipc	ra,0xffffc
    80005d70:	c8a080e7          	jalr	-886(ra) # 800019f6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d74:	00d5179b          	slliw	a5,a0,0xd
    80005d78:	0c201537          	lui	a0,0xc201
    80005d7c:	953e                	add	a0,a0,a5
  return irq;
}
    80005d7e:	4148                	lw	a0,4(a0)
    80005d80:	60a2                	ld	ra,8(sp)
    80005d82:	6402                	ld	s0,0(sp)
    80005d84:	0141                	addi	sp,sp,16
    80005d86:	8082                	ret

0000000080005d88 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d88:	1101                	addi	sp,sp,-32
    80005d8a:	ec06                	sd	ra,24(sp)
    80005d8c:	e822                	sd	s0,16(sp)
    80005d8e:	e426                	sd	s1,8(sp)
    80005d90:	1000                	addi	s0,sp,32
    80005d92:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d94:	ffffc097          	auipc	ra,0xffffc
    80005d98:	c62080e7          	jalr	-926(ra) # 800019f6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d9c:	00d5151b          	slliw	a0,a0,0xd
    80005da0:	0c2017b7          	lui	a5,0xc201
    80005da4:	97aa                	add	a5,a5,a0
    80005da6:	c3c4                	sw	s1,4(a5)
}
    80005da8:	60e2                	ld	ra,24(sp)
    80005daa:	6442                	ld	s0,16(sp)
    80005dac:	64a2                	ld	s1,8(sp)
    80005dae:	6105                	addi	sp,sp,32
    80005db0:	8082                	ret

0000000080005db2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005db2:	1141                	addi	sp,sp,-16
    80005db4:	e406                	sd	ra,8(sp)
    80005db6:	e022                	sd	s0,0(sp)
    80005db8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dba:	479d                	li	a5,7
    80005dbc:	04a7cc63          	blt	a5,a0,80005e14 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005dc0:	0001d797          	auipc	a5,0x1d
    80005dc4:	24078793          	addi	a5,a5,576 # 80023000 <disk>
    80005dc8:	00a78733          	add	a4,a5,a0
    80005dcc:	6789                	lui	a5,0x2
    80005dce:	97ba                	add	a5,a5,a4
    80005dd0:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005dd4:	eba1                	bnez	a5,80005e24 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005dd6:	00451713          	slli	a4,a0,0x4
    80005dda:	0001f797          	auipc	a5,0x1f
    80005dde:	2267b783          	ld	a5,550(a5) # 80025000 <disk+0x2000>
    80005de2:	97ba                	add	a5,a5,a4
    80005de4:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005de8:	0001d797          	auipc	a5,0x1d
    80005dec:	21878793          	addi	a5,a5,536 # 80023000 <disk>
    80005df0:	97aa                	add	a5,a5,a0
    80005df2:	6509                	lui	a0,0x2
    80005df4:	953e                	add	a0,a0,a5
    80005df6:	4785                	li	a5,1
    80005df8:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005dfc:	0001f517          	auipc	a0,0x1f
    80005e00:	21c50513          	addi	a0,a0,540 # 80025018 <disk+0x2018>
    80005e04:	ffffc097          	auipc	ra,0xffffc
    80005e08:	5ba080e7          	jalr	1466(ra) # 800023be <wakeup>
}
    80005e0c:	60a2                	ld	ra,8(sp)
    80005e0e:	6402                	ld	s0,0(sp)
    80005e10:	0141                	addi	sp,sp,16
    80005e12:	8082                	ret
    panic("virtio_disk_intr 1");
    80005e14:	00003517          	auipc	a0,0x3
    80005e18:	a1450513          	addi	a0,a0,-1516 # 80008828 <syscalls+0x338>
    80005e1c:	ffffa097          	auipc	ra,0xffffa
    80005e20:	734080e7          	jalr	1844(ra) # 80000550 <panic>
    panic("virtio_disk_intr 2");
    80005e24:	00003517          	auipc	a0,0x3
    80005e28:	a1c50513          	addi	a0,a0,-1508 # 80008840 <syscalls+0x350>
    80005e2c:	ffffa097          	auipc	ra,0xffffa
    80005e30:	724080e7          	jalr	1828(ra) # 80000550 <panic>

0000000080005e34 <virtio_disk_init>:
{
    80005e34:	1101                	addi	sp,sp,-32
    80005e36:	ec06                	sd	ra,24(sp)
    80005e38:	e822                	sd	s0,16(sp)
    80005e3a:	e426                	sd	s1,8(sp)
    80005e3c:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e3e:	00003597          	auipc	a1,0x3
    80005e42:	a1a58593          	addi	a1,a1,-1510 # 80008858 <syscalls+0x368>
    80005e46:	0001f517          	auipc	a0,0x1f
    80005e4a:	26250513          	addi	a0,a0,610 # 800250a8 <disk+0x20a8>
    80005e4e:	ffffb097          	auipc	ra,0xffffb
    80005e52:	d78080e7          	jalr	-648(ra) # 80000bc6 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e56:	100017b7          	lui	a5,0x10001
    80005e5a:	4398                	lw	a4,0(a5)
    80005e5c:	2701                	sext.w	a4,a4
    80005e5e:	747277b7          	lui	a5,0x74727
    80005e62:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e66:	0ef71163          	bne	a4,a5,80005f48 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e6a:	100017b7          	lui	a5,0x10001
    80005e6e:	43dc                	lw	a5,4(a5)
    80005e70:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e72:	4705                	li	a4,1
    80005e74:	0ce79a63          	bne	a5,a4,80005f48 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e78:	100017b7          	lui	a5,0x10001
    80005e7c:	479c                	lw	a5,8(a5)
    80005e7e:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e80:	4709                	li	a4,2
    80005e82:	0ce79363          	bne	a5,a4,80005f48 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e86:	100017b7          	lui	a5,0x10001
    80005e8a:	47d8                	lw	a4,12(a5)
    80005e8c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e8e:	554d47b7          	lui	a5,0x554d4
    80005e92:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e96:	0af71963          	bne	a4,a5,80005f48 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e9a:	100017b7          	lui	a5,0x10001
    80005e9e:	4705                	li	a4,1
    80005ea0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ea2:	470d                	li	a4,3
    80005ea4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005ea6:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005ea8:	c7ffe737          	lui	a4,0xc7ffe
    80005eac:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005eb0:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005eb2:	2701                	sext.w	a4,a4
    80005eb4:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eb6:	472d                	li	a4,11
    80005eb8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eba:	473d                	li	a4,15
    80005ebc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005ebe:	6705                	lui	a4,0x1
    80005ec0:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ec2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ec6:	5bdc                	lw	a5,52(a5)
    80005ec8:	2781                	sext.w	a5,a5
  if(max == 0)
    80005eca:	c7d9                	beqz	a5,80005f58 <virtio_disk_init+0x124>
  if(max < NUM)
    80005ecc:	471d                	li	a4,7
    80005ece:	08f77d63          	bgeu	a4,a5,80005f68 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ed2:	100014b7          	lui	s1,0x10001
    80005ed6:	47a1                	li	a5,8
    80005ed8:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005eda:	6609                	lui	a2,0x2
    80005edc:	4581                	li	a1,0
    80005ede:	0001d517          	auipc	a0,0x1d
    80005ee2:	12250513          	addi	a0,a0,290 # 80023000 <disk>
    80005ee6:	ffffb097          	auipc	ra,0xffffb
    80005eea:	e6c080e7          	jalr	-404(ra) # 80000d52 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005eee:	0001d717          	auipc	a4,0x1d
    80005ef2:	11270713          	addi	a4,a4,274 # 80023000 <disk>
    80005ef6:	00c75793          	srli	a5,a4,0xc
    80005efa:	2781                	sext.w	a5,a5
    80005efc:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005efe:	0001f797          	auipc	a5,0x1f
    80005f02:	10278793          	addi	a5,a5,258 # 80025000 <disk+0x2000>
    80005f06:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005f08:	0001d717          	auipc	a4,0x1d
    80005f0c:	17870713          	addi	a4,a4,376 # 80023080 <disk+0x80>
    80005f10:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005f12:	0001e717          	auipc	a4,0x1e
    80005f16:	0ee70713          	addi	a4,a4,238 # 80024000 <disk+0x1000>
    80005f1a:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005f1c:	4705                	li	a4,1
    80005f1e:	00e78c23          	sb	a4,24(a5)
    80005f22:	00e78ca3          	sb	a4,25(a5)
    80005f26:	00e78d23          	sb	a4,26(a5)
    80005f2a:	00e78da3          	sb	a4,27(a5)
    80005f2e:	00e78e23          	sb	a4,28(a5)
    80005f32:	00e78ea3          	sb	a4,29(a5)
    80005f36:	00e78f23          	sb	a4,30(a5)
    80005f3a:	00e78fa3          	sb	a4,31(a5)
}
    80005f3e:	60e2                	ld	ra,24(sp)
    80005f40:	6442                	ld	s0,16(sp)
    80005f42:	64a2                	ld	s1,8(sp)
    80005f44:	6105                	addi	sp,sp,32
    80005f46:	8082                	ret
    panic("could not find virtio disk");
    80005f48:	00003517          	auipc	a0,0x3
    80005f4c:	92050513          	addi	a0,a0,-1760 # 80008868 <syscalls+0x378>
    80005f50:	ffffa097          	auipc	ra,0xffffa
    80005f54:	600080e7          	jalr	1536(ra) # 80000550 <panic>
    panic("virtio disk has no queue 0");
    80005f58:	00003517          	auipc	a0,0x3
    80005f5c:	93050513          	addi	a0,a0,-1744 # 80008888 <syscalls+0x398>
    80005f60:	ffffa097          	auipc	ra,0xffffa
    80005f64:	5f0080e7          	jalr	1520(ra) # 80000550 <panic>
    panic("virtio disk max queue too short");
    80005f68:	00003517          	auipc	a0,0x3
    80005f6c:	94050513          	addi	a0,a0,-1728 # 800088a8 <syscalls+0x3b8>
    80005f70:	ffffa097          	auipc	ra,0xffffa
    80005f74:	5e0080e7          	jalr	1504(ra) # 80000550 <panic>

0000000080005f78 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f78:	7175                	addi	sp,sp,-144
    80005f7a:	e506                	sd	ra,136(sp)
    80005f7c:	e122                	sd	s0,128(sp)
    80005f7e:	fca6                	sd	s1,120(sp)
    80005f80:	f8ca                	sd	s2,112(sp)
    80005f82:	f4ce                	sd	s3,104(sp)
    80005f84:	f0d2                	sd	s4,96(sp)
    80005f86:	ecd6                	sd	s5,88(sp)
    80005f88:	e8da                	sd	s6,80(sp)
    80005f8a:	e4de                	sd	s7,72(sp)
    80005f8c:	e0e2                	sd	s8,64(sp)
    80005f8e:	fc66                	sd	s9,56(sp)
    80005f90:	f86a                	sd	s10,48(sp)
    80005f92:	f46e                	sd	s11,40(sp)
    80005f94:	0900                	addi	s0,sp,144
    80005f96:	8aaa                	mv	s5,a0
    80005f98:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f9a:	00c52c83          	lw	s9,12(a0)
    80005f9e:	001c9c9b          	slliw	s9,s9,0x1
    80005fa2:	1c82                	slli	s9,s9,0x20
    80005fa4:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005fa8:	0001f517          	auipc	a0,0x1f
    80005fac:	10050513          	addi	a0,a0,256 # 800250a8 <disk+0x20a8>
    80005fb0:	ffffb097          	auipc	ra,0xffffb
    80005fb4:	ca6080e7          	jalr	-858(ra) # 80000c56 <acquire>
  for(int i = 0; i < 3; i++){
    80005fb8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fba:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fbc:	0001dc17          	auipc	s8,0x1d
    80005fc0:	044c0c13          	addi	s8,s8,68 # 80023000 <disk>
    80005fc4:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005fc6:	4b0d                	li	s6,3
    80005fc8:	a0ad                	j	80006032 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005fca:	00fc0733          	add	a4,s8,a5
    80005fce:	975e                	add	a4,a4,s7
    80005fd0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005fd4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005fd6:	0207c563          	bltz	a5,80006000 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005fda:	2905                	addiw	s2,s2,1
    80005fdc:	0611                	addi	a2,a2,4
    80005fde:	19690d63          	beq	s2,s6,80006178 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80005fe2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005fe4:	0001f717          	auipc	a4,0x1f
    80005fe8:	03470713          	addi	a4,a4,52 # 80025018 <disk+0x2018>
    80005fec:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005fee:	00074683          	lbu	a3,0(a4)
    80005ff2:	fee1                	bnez	a3,80005fca <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005ff4:	2785                	addiw	a5,a5,1
    80005ff6:	0705                	addi	a4,a4,1
    80005ff8:	fe979be3          	bne	a5,s1,80005fee <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005ffc:	57fd                	li	a5,-1
    80005ffe:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006000:	01205d63          	blez	s2,8000601a <virtio_disk_rw+0xa2>
    80006004:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006006:	000a2503          	lw	a0,0(s4)
    8000600a:	00000097          	auipc	ra,0x0
    8000600e:	da8080e7          	jalr	-600(ra) # 80005db2 <free_desc>
      for(int j = 0; j < i; j++)
    80006012:	2d85                	addiw	s11,s11,1
    80006014:	0a11                	addi	s4,s4,4
    80006016:	ffb918e3          	bne	s2,s11,80006006 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000601a:	0001f597          	auipc	a1,0x1f
    8000601e:	08e58593          	addi	a1,a1,142 # 800250a8 <disk+0x20a8>
    80006022:	0001f517          	auipc	a0,0x1f
    80006026:	ff650513          	addi	a0,a0,-10 # 80025018 <disk+0x2018>
    8000602a:	ffffc097          	auipc	ra,0xffffc
    8000602e:	214080e7          	jalr	532(ra) # 8000223e <sleep>
  for(int i = 0; i < 3; i++){
    80006032:	f8040a13          	addi	s4,s0,-128
{
    80006036:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006038:	894e                	mv	s2,s3
    8000603a:	b765                	j	80005fe2 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000603c:	0001f717          	auipc	a4,0x1f
    80006040:	fc473703          	ld	a4,-60(a4) # 80025000 <disk+0x2000>
    80006044:	973e                	add	a4,a4,a5
    80006046:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000604a:	0001d517          	auipc	a0,0x1d
    8000604e:	fb650513          	addi	a0,a0,-74 # 80023000 <disk>
    80006052:	0001f717          	auipc	a4,0x1f
    80006056:	fae70713          	addi	a4,a4,-82 # 80025000 <disk+0x2000>
    8000605a:	6314                	ld	a3,0(a4)
    8000605c:	96be                	add	a3,a3,a5
    8000605e:	00c6d603          	lhu	a2,12(a3)
    80006062:	00166613          	ori	a2,a2,1
    80006066:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000606a:	f8842683          	lw	a3,-120(s0)
    8000606e:	6310                	ld	a2,0(a4)
    80006070:	97b2                	add	a5,a5,a2
    80006072:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    80006076:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    8000607a:	0612                	slli	a2,a2,0x4
    8000607c:	962a                	add	a2,a2,a0
    8000607e:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006082:	00469793          	slli	a5,a3,0x4
    80006086:	630c                	ld	a1,0(a4)
    80006088:	95be                	add	a1,a1,a5
    8000608a:	6689                	lui	a3,0x2
    8000608c:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006090:	96ca                	add	a3,a3,s2
    80006092:	96aa                	add	a3,a3,a0
    80006094:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    80006096:	6314                	ld	a3,0(a4)
    80006098:	96be                	add	a3,a3,a5
    8000609a:	4585                	li	a1,1
    8000609c:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000609e:	6314                	ld	a3,0(a4)
    800060a0:	96be                	add	a3,a3,a5
    800060a2:	4509                	li	a0,2
    800060a4:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800060a8:	6314                	ld	a3,0(a4)
    800060aa:	97b6                	add	a5,a5,a3
    800060ac:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060b0:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800060b4:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800060b8:	6714                	ld	a3,8(a4)
    800060ba:	0026d783          	lhu	a5,2(a3)
    800060be:	8b9d                	andi	a5,a5,7
    800060c0:	0789                	addi	a5,a5,2
    800060c2:	0786                	slli	a5,a5,0x1
    800060c4:	97b6                	add	a5,a5,a3
    800060c6:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800060ca:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800060ce:	6718                	ld	a4,8(a4)
    800060d0:	00275783          	lhu	a5,2(a4)
    800060d4:	2785                	addiw	a5,a5,1
    800060d6:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060da:	100017b7          	lui	a5,0x10001
    800060de:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060e2:	004aa783          	lw	a5,4(s5)
    800060e6:	02b79163          	bne	a5,a1,80006108 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800060ea:	0001f917          	auipc	s2,0x1f
    800060ee:	fbe90913          	addi	s2,s2,-66 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800060f2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800060f4:	85ca                	mv	a1,s2
    800060f6:	8556                	mv	a0,s5
    800060f8:	ffffc097          	auipc	ra,0xffffc
    800060fc:	146080e7          	jalr	326(ra) # 8000223e <sleep>
  while(b->disk == 1) {
    80006100:	004aa783          	lw	a5,4(s5)
    80006104:	fe9788e3          	beq	a5,s1,800060f4 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006108:	f8042483          	lw	s1,-128(s0)
    8000610c:	20048793          	addi	a5,s1,512
    80006110:	00479713          	slli	a4,a5,0x4
    80006114:	0001d797          	auipc	a5,0x1d
    80006118:	eec78793          	addi	a5,a5,-276 # 80023000 <disk>
    8000611c:	97ba                	add	a5,a5,a4
    8000611e:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006122:	0001f917          	auipc	s2,0x1f
    80006126:	ede90913          	addi	s2,s2,-290 # 80025000 <disk+0x2000>
    8000612a:	a019                	j	80006130 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    8000612c:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80006130:	8526                	mv	a0,s1
    80006132:	00000097          	auipc	ra,0x0
    80006136:	c80080e7          	jalr	-896(ra) # 80005db2 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    8000613a:	0492                	slli	s1,s1,0x4
    8000613c:	00093783          	ld	a5,0(s2)
    80006140:	94be                	add	s1,s1,a5
    80006142:	00c4d783          	lhu	a5,12(s1)
    80006146:	8b85                	andi	a5,a5,1
    80006148:	f3f5                	bnez	a5,8000612c <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000614a:	0001f517          	auipc	a0,0x1f
    8000614e:	f5e50513          	addi	a0,a0,-162 # 800250a8 <disk+0x20a8>
    80006152:	ffffb097          	auipc	ra,0xffffb
    80006156:	bb8080e7          	jalr	-1096(ra) # 80000d0a <release>
}
    8000615a:	60aa                	ld	ra,136(sp)
    8000615c:	640a                	ld	s0,128(sp)
    8000615e:	74e6                	ld	s1,120(sp)
    80006160:	7946                	ld	s2,112(sp)
    80006162:	79a6                	ld	s3,104(sp)
    80006164:	7a06                	ld	s4,96(sp)
    80006166:	6ae6                	ld	s5,88(sp)
    80006168:	6b46                	ld	s6,80(sp)
    8000616a:	6ba6                	ld	s7,72(sp)
    8000616c:	6c06                	ld	s8,64(sp)
    8000616e:	7ce2                	ld	s9,56(sp)
    80006170:	7d42                	ld	s10,48(sp)
    80006172:	7da2                	ld	s11,40(sp)
    80006174:	6149                	addi	sp,sp,144
    80006176:	8082                	ret
  if(write)
    80006178:	01a037b3          	snez	a5,s10
    8000617c:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006180:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006184:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006188:	f8042483          	lw	s1,-128(s0)
    8000618c:	00449913          	slli	s2,s1,0x4
    80006190:	0001f997          	auipc	s3,0x1f
    80006194:	e7098993          	addi	s3,s3,-400 # 80025000 <disk+0x2000>
    80006198:	0009ba03          	ld	s4,0(s3)
    8000619c:	9a4a                	add	s4,s4,s2
    8000619e:	f7040513          	addi	a0,s0,-144
    800061a2:	ffffb097          	auipc	ra,0xffffb
    800061a6:	f80080e7          	jalr	-128(ra) # 80001122 <kvmpa>
    800061aa:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    800061ae:	0009b783          	ld	a5,0(s3)
    800061b2:	97ca                	add	a5,a5,s2
    800061b4:	4741                	li	a4,16
    800061b6:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061b8:	0009b783          	ld	a5,0(s3)
    800061bc:	97ca                	add	a5,a5,s2
    800061be:	4705                	li	a4,1
    800061c0:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800061c4:	f8442783          	lw	a5,-124(s0)
    800061c8:	0009b703          	ld	a4,0(s3)
    800061cc:	974a                	add	a4,a4,s2
    800061ce:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800061d2:	0792                	slli	a5,a5,0x4
    800061d4:	0009b703          	ld	a4,0(s3)
    800061d8:	973e                	add	a4,a4,a5
    800061da:	058a8693          	addi	a3,s5,88
    800061de:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    800061e0:	0009b703          	ld	a4,0(s3)
    800061e4:	973e                	add	a4,a4,a5
    800061e6:	40000693          	li	a3,1024
    800061ea:	c714                	sw	a3,8(a4)
  if(write)
    800061ec:	e40d18e3          	bnez	s10,8000603c <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800061f0:	0001f717          	auipc	a4,0x1f
    800061f4:	e1073703          	ld	a4,-496(a4) # 80025000 <disk+0x2000>
    800061f8:	973e                	add	a4,a4,a5
    800061fa:	4689                	li	a3,2
    800061fc:	00d71623          	sh	a3,12(a4)
    80006200:	b5a9                	j	8000604a <virtio_disk_rw+0xd2>

0000000080006202 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006202:	1101                	addi	sp,sp,-32
    80006204:	ec06                	sd	ra,24(sp)
    80006206:	e822                	sd	s0,16(sp)
    80006208:	e426                	sd	s1,8(sp)
    8000620a:	e04a                	sd	s2,0(sp)
    8000620c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000620e:	0001f517          	auipc	a0,0x1f
    80006212:	e9a50513          	addi	a0,a0,-358 # 800250a8 <disk+0x20a8>
    80006216:	ffffb097          	auipc	ra,0xffffb
    8000621a:	a40080e7          	jalr	-1472(ra) # 80000c56 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    8000621e:	0001f717          	auipc	a4,0x1f
    80006222:	de270713          	addi	a4,a4,-542 # 80025000 <disk+0x2000>
    80006226:	02075783          	lhu	a5,32(a4)
    8000622a:	6b18                	ld	a4,16(a4)
    8000622c:	00275683          	lhu	a3,2(a4)
    80006230:	8ebd                	xor	a3,a3,a5
    80006232:	8a9d                	andi	a3,a3,7
    80006234:	cab9                	beqz	a3,8000628a <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    80006236:	0001d917          	auipc	s2,0x1d
    8000623a:	dca90913          	addi	s2,s2,-566 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    8000623e:	0001f497          	auipc	s1,0x1f
    80006242:	dc248493          	addi	s1,s1,-574 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    80006246:	078e                	slli	a5,a5,0x3
    80006248:	97ba                	add	a5,a5,a4
    8000624a:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    8000624c:	20078713          	addi	a4,a5,512
    80006250:	0712                	slli	a4,a4,0x4
    80006252:	974a                	add	a4,a4,s2
    80006254:	03074703          	lbu	a4,48(a4)
    80006258:	ef21                	bnez	a4,800062b0 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000625a:	20078793          	addi	a5,a5,512
    8000625e:	0792                	slli	a5,a5,0x4
    80006260:	97ca                	add	a5,a5,s2
    80006262:	7798                	ld	a4,40(a5)
    80006264:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006268:	7788                	ld	a0,40(a5)
    8000626a:	ffffc097          	auipc	ra,0xffffc
    8000626e:	154080e7          	jalr	340(ra) # 800023be <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006272:	0204d783          	lhu	a5,32(s1)
    80006276:	2785                	addiw	a5,a5,1
    80006278:	8b9d                	andi	a5,a5,7
    8000627a:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    8000627e:	6898                	ld	a4,16(s1)
    80006280:	00275683          	lhu	a3,2(a4)
    80006284:	8a9d                	andi	a3,a3,7
    80006286:	fcf690e3          	bne	a3,a5,80006246 <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000628a:	10001737          	lui	a4,0x10001
    8000628e:	533c                	lw	a5,96(a4)
    80006290:	8b8d                	andi	a5,a5,3
    80006292:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006294:	0001f517          	auipc	a0,0x1f
    80006298:	e1450513          	addi	a0,a0,-492 # 800250a8 <disk+0x20a8>
    8000629c:	ffffb097          	auipc	ra,0xffffb
    800062a0:	a6e080e7          	jalr	-1426(ra) # 80000d0a <release>
}
    800062a4:	60e2                	ld	ra,24(sp)
    800062a6:	6442                	ld	s0,16(sp)
    800062a8:	64a2                	ld	s1,8(sp)
    800062aa:	6902                	ld	s2,0(sp)
    800062ac:	6105                	addi	sp,sp,32
    800062ae:	8082                	ret
      panic("virtio_disk_intr status");
    800062b0:	00002517          	auipc	a0,0x2
    800062b4:	61850513          	addi	a0,a0,1560 # 800088c8 <syscalls+0x3d8>
    800062b8:	ffffa097          	auipc	ra,0xffffa
    800062bc:	298080e7          	jalr	664(ra) # 80000550 <panic>
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
