
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <is_valid_identifier_char>:
  exit(0);
}

int script_fd = -1; // added by miigon as challenge for lab1

int is_valid_identifier_char(char c) { // used in tab completion
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
  return  (c >= 'A' && c <= 'Z') ||
          (c >= 'a' && c <= 'z') ||
          (c >= '0' && c <= '9') ||
          c == '_' || c == '.' || c == '-';
       6:	fdf57793          	andi	a5,a0,-33
       a:	fbf7879b          	addiw	a5,a5,-65
       e:	0ff7f793          	andi	a5,a5,255
      12:	4765                	li	a4,25
      14:	02f77863          	bgeu	a4,a5,44 <is_valid_identifier_char+0x44>
      18:	fd35051b          	addiw	a0,a0,-45
      1c:	0ff57513          	andi	a0,a0,255
      20:	03200713          	li	a4,50
      24:	4785                	li	a5,1
      26:	00a76c63          	bltu	a4,a0,3e <is_valid_identifier_char+0x3e>
      2a:	00002797          	auipc	a5,0x2
      2e:	8de7b783          	ld	a5,-1826(a5) # 1908 <__SDATA_BEGIN__>
      32:	00a7d533          	srl	a0,a5,a0
      36:	00154513          	xori	a0,a0,1
      3a:	00157793          	andi	a5,a0,1
      3e:	0017c513          	xori	a0,a5,1
      42:	a011                	j	46 <is_valid_identifier_char+0x46>
      44:	4505                	li	a0,1
}
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret

000000000000004c <find_last_word>:

char *find_last_word(char *buf) {
      4c:	1101                	addi	sp,sp,-32
      4e:	ec06                	sd	ra,24(sp)
      50:	e822                	sd	s0,16(sp)
      52:	e426                	sd	s1,8(sp)
      54:	e04a                	sd	s2,0(sp)
      56:	1000                	addi	s0,sp,32
      58:	892a                	mv	s2,a0
  char *word = buf + strlen(buf) - 1;
      5a:	00001097          	auipc	ra,0x1
      5e:	f74080e7          	jalr	-140(ra) # fce <strlen>
      62:	02051493          	slli	s1,a0,0x20
      66:	9081                	srli	s1,s1,0x20
      68:	14fd                	addi	s1,s1,-1
      6a:	94ca                	add	s1,s1,s2
  while(is_valid_identifier_char(*word) && word != buf-1) {
      6c:	197d                	addi	s2,s2,-1
      6e:	a011                	j	72 <find_last_word+0x26>
    word--;
      70:	14fd                	addi	s1,s1,-1
  while(is_valid_identifier_char(*word) && word != buf-1) {
      72:	0004c503          	lbu	a0,0(s1)
      76:	00000097          	auipc	ra,0x0
      7a:	f8a080e7          	jalr	-118(ra) # 0 <is_valid_identifier_char>
      7e:	c501                	beqz	a0,86 <find_last_word+0x3a>
      80:	ff2498e3          	bne	s1,s2,70 <find_last_word+0x24>
      84:	84ca                	mv	s1,s2
  }
  word++;
  return word;
}
      86:	00148513          	addi	a0,s1,1
      8a:	60e2                	ld	ra,24(sp)
      8c:	6442                	ld	s0,16(sp)
      8e:	64a2                	ld	s1,8(sp)
      90:	6902                	ld	s2,0(sp)
      92:	6105                	addi	sp,sp,32
      94:	8082                	ret

0000000000000096 <tab_completion>:

int tab_completion(char *cmdbuf) {
      96:	d8010113          	addi	sp,sp,-640
      9a:	26113c23          	sd	ra,632(sp)
      9e:	26813823          	sd	s0,624(sp)
      a2:	26913423          	sd	s1,616(sp)
      a6:	27213023          	sd	s2,608(sp)
      aa:	25313c23          	sd	s3,600(sp)
      ae:	25413823          	sd	s4,592(sp)
      b2:	25513423          	sd	s5,584(sp)
      b6:	25613023          	sd	s6,576(sp)
      ba:	23713c23          	sd	s7,568(sp)
      be:	23813823          	sd	s8,560(sp)
      c2:	0500                	addi	s0,sp,640
  char *last_word = find_last_word(cmdbuf);
      c4:	00000097          	auipc	ra,0x0
      c8:	f88080e7          	jalr	-120(ra) # 4c <find_last_word>
      cc:	892a                	mv	s2,a0
	int fd;
	struct dirent de;
	struct stat st;

  const char* path = ".";
	if((fd = open(path, 0)) < 0){
      ce:	4581                	li	a1,0
      d0:	00001517          	auipc	a0,0x1
      d4:	64050513          	addi	a0,a0,1600 # 1710 <malloc+0xe6>
      d8:	00001097          	auipc	ra,0x1
      dc:	15c080e7          	jalr	348(ra) # 1234 <open>
      e0:	04054e63          	bltz	a0,13c <tab_completion+0xa6>
      e4:	84aa                	mv	s1,a0
		fprintf(2, "auto-complete: cannot open %s\n", path);
		return 0;
	}

	if(fstat(fd, &st) < 0){
      e6:	d8840593          	addi	a1,s0,-632
      ea:	00001097          	auipc	ra,0x1
      ee:	162080e7          	jalr	354(ra) # 124c <fstat>
      f2:	06054463          	bltz	a0,15a <tab_completion+0xc4>
		close(fd);
		return 0;
	}
  
  int added_length = 0;
	switch(st.type){
      f6:	d9041703          	lh	a4,-624(s0)
      fa:	4785                	li	a5,1
  int added_length = 0;
      fc:	4981                	li	s3,0
	switch(st.type){
      fe:	08f70263          	beq	a4,a5,182 <tab_completion+0xec>
        }
			}
		}
		break;
	}
	close(fd);
     102:	8526                	mv	a0,s1
     104:	00001097          	auipc	ra,0x1
     108:	118080e7          	jalr	280(ra) # 121c <close>
  return added_length;
}
     10c:	854e                	mv	a0,s3
     10e:	27813083          	ld	ra,632(sp)
     112:	27013403          	ld	s0,624(sp)
     116:	26813483          	ld	s1,616(sp)
     11a:	26013903          	ld	s2,608(sp)
     11e:	25813983          	ld	s3,600(sp)
     122:	25013a03          	ld	s4,592(sp)
     126:	24813a83          	ld	s5,584(sp)
     12a:	24013b03          	ld	s6,576(sp)
     12e:	23813b83          	ld	s7,568(sp)
     132:	23013c03          	ld	s8,560(sp)
     136:	28010113          	addi	sp,sp,640
     13a:	8082                	ret
		fprintf(2, "auto-complete: cannot open %s\n", path);
     13c:	00001617          	auipc	a2,0x1
     140:	5d460613          	addi	a2,a2,1492 # 1710 <malloc+0xe6>
     144:	00001597          	auipc	a1,0x1
     148:	5d458593          	addi	a1,a1,1492 # 1718 <malloc+0xee>
     14c:	4509                	li	a0,2
     14e:	00001097          	auipc	ra,0x1
     152:	3f0080e7          	jalr	1008(ra) # 153e <fprintf>
		return 0;
     156:	4981                	li	s3,0
     158:	bf55                	j	10c <tab_completion+0x76>
		fprintf(2, "auto-complete: cannot stat %s\n", path);
     15a:	00001617          	auipc	a2,0x1
     15e:	5b660613          	addi	a2,a2,1462 # 1710 <malloc+0xe6>
     162:	00001597          	auipc	a1,0x1
     166:	5d658593          	addi	a1,a1,1494 # 1738 <malloc+0x10e>
     16a:	4509                	li	a0,2
     16c:	00001097          	auipc	ra,0x1
     170:	3d2080e7          	jalr	978(ra) # 153e <fprintf>
		close(fd);
     174:	8526                	mv	a0,s1
     176:	00001097          	auipc	ra,0x1
     17a:	0a6080e7          	jalr	166(ra) # 121c <close>
		return 0;
     17e:	4981                	li	s3,0
     180:	b771                	j	10c <tab_completion+0x76>
		if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
     182:	00001517          	auipc	a0,0x1
     186:	58e50513          	addi	a0,a0,1422 # 1710 <malloc+0xe6>
     18a:	00001097          	auipc	ra,0x1
     18e:	e44080e7          	jalr	-444(ra) # fce <strlen>
     192:	2541                	addiw	a0,a0,16
     194:	20000793          	li	a5,512
     198:	00a7fb63          	bgeu	a5,a0,1ae <tab_completion+0x118>
			printf("auto-complete: path too long\n");
     19c:	00001517          	auipc	a0,0x1
     1a0:	5bc50513          	addi	a0,a0,1468 # 1758 <malloc+0x12e>
     1a4:	00001097          	auipc	ra,0x1
     1a8:	3c8080e7          	jalr	968(ra) # 156c <printf>
			break;
     1ac:	bf99                	j	102 <tab_completion+0x6c>
		strcpy(buf, path);
     1ae:	00001597          	auipc	a1,0x1
     1b2:	56258593          	addi	a1,a1,1378 # 1710 <malloc+0xe6>
     1b6:	db040513          	addi	a0,s0,-592
     1ba:	00001097          	auipc	ra,0x1
     1be:	dcc080e7          	jalr	-564(ra) # f86 <strcpy>
		p = buf+strlen(buf);
     1c2:	db040513          	addi	a0,s0,-592
     1c6:	00001097          	auipc	ra,0x1
     1ca:	e08080e7          	jalr	-504(ra) # fce <strlen>
     1ce:	02051993          	slli	s3,a0,0x20
     1d2:	0209d993          	srli	s3,s3,0x20
     1d6:	db040793          	addi	a5,s0,-592
     1da:	99be                	add	s3,s3,a5
		*p++ = '/';
     1dc:	00198a13          	addi	s4,s3,1
     1e0:	02f00793          	li	a5,47
     1e4:	00f98023          	sb	a5,0(s3)
			if(strcmp(buf+strlen(buf)-2, "/.") != 0 && strcmp(buf+strlen(buf)-3, "/..") != 0) {
     1e8:	00001a97          	auipc	s5,0x1
     1ec:	590a8a93          	addi	s5,s5,1424 # 1778 <malloc+0x14e>
     1f0:	00001b97          	auipc	s7,0x1
     1f4:	590b8b93          	addi	s7,s7,1424 # 1780 <malloc+0x156>
				printf("auto-complete: cannot stat %s\n", buf);
     1f8:	00001b17          	auipc	s6,0x1
     1fc:	540b0b13          	addi	s6,s6,1344 # 1738 <malloc+0x10e>
		while(read(fd, &de, sizeof(de)) == sizeof(de)){
     200:	a801                	j	210 <tab_completion+0x17a>
				printf("auto-complete: cannot stat %s\n", buf);
     202:	db040593          	addi	a1,s0,-592
     206:	855a                	mv	a0,s6
     208:	00001097          	auipc	ra,0x1
     20c:	364080e7          	jalr	868(ra) # 156c <printf>
		while(read(fd, &de, sizeof(de)) == sizeof(de)){
     210:	4641                	li	a2,16
     212:	da040593          	addi	a1,s0,-608
     216:	8526                	mv	a0,s1
     218:	00001097          	auipc	ra,0x1
     21c:	ff4080e7          	jalr	-12(ra) # 120c <read>
     220:	47c1                	li	a5,16
     222:	0ef51063          	bne	a0,a5,302 <tab_completion+0x26c>
			if(de.inum == 0)
     226:	da045783          	lhu	a5,-608(s0)
     22a:	d3fd                	beqz	a5,210 <tab_completion+0x17a>
			memmove(p, de.name, DIRSIZ);
     22c:	4639                	li	a2,14
     22e:	da240593          	addi	a1,s0,-606
     232:	8552                	mv	a0,s4
     234:	00001097          	auipc	ra,0x1
     238:	f0e080e7          	jalr	-242(ra) # 1142 <memmove>
			p[DIRSIZ] = 0;
     23c:	000987a3          	sb	zero,15(s3)
			if(stat(buf, &st) < 0){
     240:	d8840593          	addi	a1,s0,-632
     244:	db040513          	addi	a0,s0,-592
     248:	00001097          	auipc	ra,0x1
     24c:	e6a080e7          	jalr	-406(ra) # 10b2 <stat>
     250:	fa0549e3          	bltz	a0,202 <tab_completion+0x16c>
			if(strcmp(buf+strlen(buf)-2, "/.") != 0 && strcmp(buf+strlen(buf)-3, "/..") != 0) {
     254:	db040513          	addi	a0,s0,-592
     258:	00001097          	auipc	ra,0x1
     25c:	d76080e7          	jalr	-650(ra) # fce <strlen>
     260:	1502                	slli	a0,a0,0x20
     262:	9101                	srli	a0,a0,0x20
     264:	1579                	addi	a0,a0,-2
     266:	85d6                	mv	a1,s5
     268:	db040793          	addi	a5,s0,-592
     26c:	953e                	add	a0,a0,a5
     26e:	00001097          	auipc	ra,0x1
     272:	d34080e7          	jalr	-716(ra) # fa2 <strcmp>
     276:	dd49                	beqz	a0,210 <tab_completion+0x17a>
     278:	db040513          	addi	a0,s0,-592
     27c:	00001097          	auipc	ra,0x1
     280:	d52080e7          	jalr	-686(ra) # fce <strlen>
     284:	1502                	slli	a0,a0,0x20
     286:	9101                	srli	a0,a0,0x20
     288:	1575                	addi	a0,a0,-3
     28a:	85de                	mv	a1,s7
     28c:	db040793          	addi	a5,s0,-592
     290:	953e                	add	a0,a0,a5
     292:	00001097          	auipc	ra,0x1
     296:	d10080e7          	jalr	-752(ra) # fa2 <strcmp>
     29a:	d93d                	beqz	a0,210 <tab_completion+0x17a>
				char *last_word_from_buf = find_last_word(buf);
     29c:	db040513          	addi	a0,s0,-592
     2a0:	00000097          	auipc	ra,0x0
     2a4:	dac080e7          	jalr	-596(ra) # 4c <find_last_word>
     2a8:	8c2a                	mv	s8,a0
        if(memcmp(last_word_from_buf, last_word, strlen(last_word)) == 0) {
     2aa:	854a                	mv	a0,s2
     2ac:	00001097          	auipc	ra,0x1
     2b0:	d22080e7          	jalr	-734(ra) # fce <strlen>
     2b4:	0005061b          	sext.w	a2,a0
     2b8:	85ca                	mv	a1,s2
     2ba:	8562                	mv	a0,s8
     2bc:	00001097          	auipc	ra,0x1
     2c0:	ede080e7          	jalr	-290(ra) # 119a <memcmp>
     2c4:	f531                	bnez	a0,210 <tab_completion+0x17a>
          printf("auto-completed: %s\n\n", last_word_from_buf);
     2c6:	85e2                	mv	a1,s8
     2c8:	00001517          	auipc	a0,0x1
     2cc:	4c050513          	addi	a0,a0,1216 # 1788 <malloc+0x15e>
     2d0:	00001097          	auipc	ra,0x1
     2d4:	29c080e7          	jalr	668(ra) # 156c <printf>
          added_length = strlen(last_word_from_buf) - strlen(last_word);
     2d8:	8562                	mv	a0,s8
     2da:	00001097          	auipc	ra,0x1
     2de:	cf4080e7          	jalr	-780(ra) # fce <strlen>
     2e2:	0005099b          	sext.w	s3,a0
     2e6:	854a                	mv	a0,s2
     2e8:	00001097          	auipc	ra,0x1
     2ec:	ce6080e7          	jalr	-794(ra) # fce <strlen>
     2f0:	40a989bb          	subw	s3,s3,a0
          strcpy(last_word, last_word_from_buf);
     2f4:	85e2                	mv	a1,s8
     2f6:	854a                	mv	a0,s2
     2f8:	00001097          	auipc	ra,0x1
     2fc:	c8e080e7          	jalr	-882(ra) # f86 <strcpy>
          break;
     300:	b509                	j	102 <tab_completion+0x6c>
  int added_length = 0;
     302:	4981                	li	s3,0
     304:	bbfd                	j	102 <tab_completion+0x6c>

0000000000000306 <get_oneline_of_cmd>:

int
get_oneline_of_cmd(char *buf, int nbuf)
{
     306:	7159                	addi	sp,sp,-112
     308:	f486                	sd	ra,104(sp)
     30a:	f0a2                	sd	s0,96(sp)
     30c:	eca6                	sd	s1,88(sp)
     30e:	e8ca                	sd	s2,80(sp)
     310:	e4ce                	sd	s3,72(sp)
     312:	e0d2                	sd	s4,64(sp)
     314:	fc56                	sd	s5,56(sp)
     316:	f85a                	sd	s6,48(sp)
     318:	f45e                	sd	s7,40(sp)
     31a:	f062                	sd	s8,32(sp)
     31c:	ec66                	sd	s9,24(sp)
     31e:	1880                	addi	s0,sp,112
     320:	89aa                	mv	s3,a0
     322:	8a2e                	mv	s4,a1
  if(script_fd == -1) {
     324:	00001717          	auipc	a4,0x1
     328:	5fc72703          	lw	a4,1532(a4) # 1920 <script_fd>
     32c:	57fd                	li	a5,-1
     32e:	02f70763          	beq	a4,a5,35c <get_oneline_of_cmd+0x56>
    fprintf(2, "$ ");
  }
  memset(buf, 0, nbuf);
     332:	8652                	mv	a2,s4
     334:	4581                	li	a1,0
     336:	854e                	mv	a0,s3
     338:	00001097          	auipc	ra,0x1
     33c:	cc0080e7          	jalr	-832(ra) # ff8 <memset>

  // copied & modified from gets() in ulib.c
  int i, cc;
  char c;

  for(i=0; i+1 < nbuf; ){
     340:	4785                	li	a5,1
     342:	0947d663          	bge	a5,s4,3ce <get_oneline_of_cmd+0xc8>
     346:	4481                	li	s1,0
     348:	4905                	li	s2,1
    if(script_fd == -1) {
     34a:	00001b17          	auipc	s6,0x1
     34e:	5d6b0b13          	addi	s6,s6,1494 # 1920 <script_fd>
     352:	5afd                	li	s5,-1
    } else {
      cc = read(script_fd, &c, 1);
    }
    if(cc < 1)
      break;
    if(c == '\t') { // added tab completion
     354:	4ba5                	li	s7,9
      i += tab_completion(buf);
    } else {
      buf[i++] = c;
      if(c == '\n' || c == '\r')
     356:	4c29                	li	s8,10
     358:	4cb5                	li	s9,13
     35a:	a0a9                	j	3a4 <get_oneline_of_cmd+0x9e>
    fprintf(2, "$ ");
     35c:	00001597          	auipc	a1,0x1
     360:	44458593          	addi	a1,a1,1092 # 17a0 <malloc+0x176>
     364:	4509                	li	a0,2
     366:	00001097          	auipc	ra,0x1
     36a:	1d8080e7          	jalr	472(ra) # 153e <fprintf>
     36e:	b7d1                	j	332 <get_oneline_of_cmd+0x2c>
      cc = read(0, &c, 1);
     370:	4605                	li	a2,1
     372:	f9f40593          	addi	a1,s0,-97
     376:	4501                	li	a0,0
     378:	00001097          	auipc	ra,0x1
     37c:	e94080e7          	jalr	-364(ra) # 120c <read>
    if(cc < 1)
     380:	04a05963          	blez	a0,3d2 <get_oneline_of_cmd+0xcc>
    if(c == '\t') { // added tab completion
     384:	f9f44783          	lbu	a5,-97(s0)
     388:	03778a63          	beq	a5,s7,3bc <get_oneline_of_cmd+0xb6>
      buf[i++] = c;
     38c:	94ce                	add	s1,s1,s3
     38e:	00f48023          	sb	a5,0(s1)
      if(c == '\n' || c == '\r')
     392:	05878163          	beq	a5,s8,3d4 <get_oneline_of_cmd+0xce>
     396:	03978f63          	beq	a5,s9,3d4 <get_oneline_of_cmd+0xce>
     39a:	84ca                	mv	s1,s2
  for(i=0; i+1 < nbuf; ){
     39c:	0014891b          	addiw	s2,s1,1
     3a0:	03495563          	bge	s2,s4,3ca <get_oneline_of_cmd+0xc4>
    if(script_fd == -1) {
     3a4:	000b2503          	lw	a0,0(s6)
     3a8:	fd5504e3          	beq	a0,s5,370 <get_oneline_of_cmd+0x6a>
      cc = read(script_fd, &c, 1);
     3ac:	4605                	li	a2,1
     3ae:	f9f40593          	addi	a1,s0,-97
     3b2:	00001097          	auipc	ra,0x1
     3b6:	e5a080e7          	jalr	-422(ra) # 120c <read>
     3ba:	b7d9                	j	380 <get_oneline_of_cmd+0x7a>
      i += tab_completion(buf);
     3bc:	854e                	mv	a0,s3
     3be:	00000097          	auipc	ra,0x0
     3c2:	cd8080e7          	jalr	-808(ra) # 96 <tab_completion>
     3c6:	9ca9                	addw	s1,s1,a0
     3c8:	bfd1                	j	39c <get_oneline_of_cmd+0x96>
     3ca:	8926                	mv	s2,s1
     3cc:	a021                	j	3d4 <get_oneline_of_cmd+0xce>
  for(i=0; i+1 < nbuf; ){
     3ce:	4901                	li	s2,0
     3d0:	a011                	j	3d4 <get_oneline_of_cmd+0xce>
     3d2:	8926                	mv	s2,s1
        break;
    }
  }
  buf[i] = '\0';
     3d4:	994e                	add	s2,s2,s3
     3d6:	00090023          	sb	zero,0(s2)

  if(buf[0] == 0) // EOF
     3da:	0009c503          	lbu	a0,0(s3)
     3de:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
     3e2:	40a00533          	neg	a0,a0
     3e6:	70a6                	ld	ra,104(sp)
     3e8:	7406                	ld	s0,96(sp)
     3ea:	64e6                	ld	s1,88(sp)
     3ec:	6946                	ld	s2,80(sp)
     3ee:	69a6                	ld	s3,72(sp)
     3f0:	6a06                	ld	s4,64(sp)
     3f2:	7ae2                	ld	s5,56(sp)
     3f4:	7b42                	ld	s6,48(sp)
     3f6:	7ba2                	ld	s7,40(sp)
     3f8:	7c02                	ld	s8,32(sp)
     3fa:	6ce2                	ld	s9,24(sp)
     3fc:	6165                	addi	sp,sp,112
     3fe:	8082                	ret

0000000000000400 <panic>:
  exit(0);
}

void
panic(char *s)
{
     400:	1141                	addi	sp,sp,-16
     402:	e406                	sd	ra,8(sp)
     404:	e022                	sd	s0,0(sp)
     406:	0800                	addi	s0,sp,16
     408:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
     40a:	00001597          	auipc	a1,0x1
     40e:	39e58593          	addi	a1,a1,926 # 17a8 <malloc+0x17e>
     412:	4509                	li	a0,2
     414:	00001097          	auipc	ra,0x1
     418:	12a080e7          	jalr	298(ra) # 153e <fprintf>
  exit(1);
     41c:	4505                	li	a0,1
     41e:	00001097          	auipc	ra,0x1
     422:	dd6080e7          	jalr	-554(ra) # 11f4 <exit>

0000000000000426 <fork1>:
}

int
fork1(void)
{
     426:	1141                	addi	sp,sp,-16
     428:	e406                	sd	ra,8(sp)
     42a:	e022                	sd	s0,0(sp)
     42c:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
     42e:	00001097          	auipc	ra,0x1
     432:	dbe080e7          	jalr	-578(ra) # 11ec <fork>
  if(pid == -1)
     436:	57fd                	li	a5,-1
     438:	00f50663          	beq	a0,a5,444 <fork1+0x1e>
    panic("fork");
  return pid;
}
     43c:	60a2                	ld	ra,8(sp)
     43e:	6402                	ld	s0,0(sp)
     440:	0141                	addi	sp,sp,16
     442:	8082                	ret
    panic("fork");
     444:	00001517          	auipc	a0,0x1
     448:	36c50513          	addi	a0,a0,876 # 17b0 <malloc+0x186>
     44c:	00000097          	auipc	ra,0x0
     450:	fb4080e7          	jalr	-76(ra) # 400 <panic>

0000000000000454 <runcmd>:
{
     454:	7179                	addi	sp,sp,-48
     456:	f406                	sd	ra,40(sp)
     458:	f022                	sd	s0,32(sp)
     45a:	ec26                	sd	s1,24(sp)
     45c:	1800                	addi	s0,sp,48
  if(cmd == 0)
     45e:	c10d                	beqz	a0,480 <runcmd+0x2c>
     460:	84aa                	mv	s1,a0
  switch(cmd->type){
     462:	4118                	lw	a4,0(a0)
     464:	4795                	li	a5,5
     466:	02e7e263          	bltu	a5,a4,48a <runcmd+0x36>
     46a:	00056783          	lwu	a5,0(a0)
     46e:	078a                	slli	a5,a5,0x2
     470:	00001717          	auipc	a4,0x1
     474:	44870713          	addi	a4,a4,1096 # 18b8 <malloc+0x28e>
     478:	97ba                	add	a5,a5,a4
     47a:	439c                	lw	a5,0(a5)
     47c:	97ba                	add	a5,a5,a4
     47e:	8782                	jr	a5
    exit(1);
     480:	4505                	li	a0,1
     482:	00001097          	auipc	ra,0x1
     486:	d72080e7          	jalr	-654(ra) # 11f4 <exit>
    panic("runcmd");
     48a:	00001517          	auipc	a0,0x1
     48e:	32e50513          	addi	a0,a0,814 # 17b8 <malloc+0x18e>
     492:	00000097          	auipc	ra,0x0
     496:	f6e080e7          	jalr	-146(ra) # 400 <panic>
    if(ecmd->argv[0] == 0)
     49a:	6508                	ld	a0,8(a0)
     49c:	c515                	beqz	a0,4c8 <runcmd+0x74>
    exec(ecmd->argv[0], ecmd->argv);
     49e:	00848593          	addi	a1,s1,8
     4a2:	00001097          	auipc	ra,0x1
     4a6:	d8a080e7          	jalr	-630(ra) # 122c <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     4aa:	6490                	ld	a2,8(s1)
     4ac:	00001597          	auipc	a1,0x1
     4b0:	31458593          	addi	a1,a1,788 # 17c0 <malloc+0x196>
     4b4:	4509                	li	a0,2
     4b6:	00001097          	auipc	ra,0x1
     4ba:	088080e7          	jalr	136(ra) # 153e <fprintf>
  exit(0);
     4be:	4501                	li	a0,0
     4c0:	00001097          	auipc	ra,0x1
     4c4:	d34080e7          	jalr	-716(ra) # 11f4 <exit>
      exit(1);
     4c8:	4505                	li	a0,1
     4ca:	00001097          	auipc	ra,0x1
     4ce:	d2a080e7          	jalr	-726(ra) # 11f4 <exit>
    close(rcmd->fd);
     4d2:	5148                	lw	a0,36(a0)
     4d4:	00001097          	auipc	ra,0x1
     4d8:	d48080e7          	jalr	-696(ra) # 121c <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     4dc:	508c                	lw	a1,32(s1)
     4de:	6888                	ld	a0,16(s1)
     4e0:	00001097          	auipc	ra,0x1
     4e4:	d54080e7          	jalr	-684(ra) # 1234 <open>
     4e8:	00054763          	bltz	a0,4f6 <runcmd+0xa2>
    runcmd(rcmd->cmd);
     4ec:	6488                	ld	a0,8(s1)
     4ee:	00000097          	auipc	ra,0x0
     4f2:	f66080e7          	jalr	-154(ra) # 454 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     4f6:	6890                	ld	a2,16(s1)
     4f8:	00001597          	auipc	a1,0x1
     4fc:	2d858593          	addi	a1,a1,728 # 17d0 <malloc+0x1a6>
     500:	4509                	li	a0,2
     502:	00001097          	auipc	ra,0x1
     506:	03c080e7          	jalr	60(ra) # 153e <fprintf>
      exit(1);
     50a:	4505                	li	a0,1
     50c:	00001097          	auipc	ra,0x1
     510:	ce8080e7          	jalr	-792(ra) # 11f4 <exit>
    if(fork1() == 0)
     514:	00000097          	auipc	ra,0x0
     518:	f12080e7          	jalr	-238(ra) # 426 <fork1>
     51c:	c919                	beqz	a0,532 <runcmd+0xde>
    wait(0);
     51e:	4501                	li	a0,0
     520:	00001097          	auipc	ra,0x1
     524:	cdc080e7          	jalr	-804(ra) # 11fc <wait>
    runcmd(lcmd->right);
     528:	6888                	ld	a0,16(s1)
     52a:	00000097          	auipc	ra,0x0
     52e:	f2a080e7          	jalr	-214(ra) # 454 <runcmd>
      runcmd(lcmd->left);
     532:	6488                	ld	a0,8(s1)
     534:	00000097          	auipc	ra,0x0
     538:	f20080e7          	jalr	-224(ra) # 454 <runcmd>
    if(pipe(p) < 0)
     53c:	fd840513          	addi	a0,s0,-40
     540:	00001097          	auipc	ra,0x1
     544:	cc4080e7          	jalr	-828(ra) # 1204 <pipe>
     548:	04054363          	bltz	a0,58e <runcmd+0x13a>
    if(fork1() == 0){
     54c:	00000097          	auipc	ra,0x0
     550:	eda080e7          	jalr	-294(ra) # 426 <fork1>
     554:	c529                	beqz	a0,59e <runcmd+0x14a>
    if(fork1() == 0){
     556:	00000097          	auipc	ra,0x0
     55a:	ed0080e7          	jalr	-304(ra) # 426 <fork1>
     55e:	cd25                	beqz	a0,5d6 <runcmd+0x182>
    close(p[0]);
     560:	fd842503          	lw	a0,-40(s0)
     564:	00001097          	auipc	ra,0x1
     568:	cb8080e7          	jalr	-840(ra) # 121c <close>
    close(p[1]);
     56c:	fdc42503          	lw	a0,-36(s0)
     570:	00001097          	auipc	ra,0x1
     574:	cac080e7          	jalr	-852(ra) # 121c <close>
    wait(0);
     578:	4501                	li	a0,0
     57a:	00001097          	auipc	ra,0x1
     57e:	c82080e7          	jalr	-894(ra) # 11fc <wait>
    wait(0);
     582:	4501                	li	a0,0
     584:	00001097          	auipc	ra,0x1
     588:	c78080e7          	jalr	-904(ra) # 11fc <wait>
    break;
     58c:	bf0d                	j	4be <runcmd+0x6a>
      panic("pipe");
     58e:	00001517          	auipc	a0,0x1
     592:	25250513          	addi	a0,a0,594 # 17e0 <malloc+0x1b6>
     596:	00000097          	auipc	ra,0x0
     59a:	e6a080e7          	jalr	-406(ra) # 400 <panic>
      close(1);
     59e:	4505                	li	a0,1
     5a0:	00001097          	auipc	ra,0x1
     5a4:	c7c080e7          	jalr	-900(ra) # 121c <close>
      dup(p[1]);
     5a8:	fdc42503          	lw	a0,-36(s0)
     5ac:	00001097          	auipc	ra,0x1
     5b0:	cc0080e7          	jalr	-832(ra) # 126c <dup>
      close(p[0]);
     5b4:	fd842503          	lw	a0,-40(s0)
     5b8:	00001097          	auipc	ra,0x1
     5bc:	c64080e7          	jalr	-924(ra) # 121c <close>
      close(p[1]);
     5c0:	fdc42503          	lw	a0,-36(s0)
     5c4:	00001097          	auipc	ra,0x1
     5c8:	c58080e7          	jalr	-936(ra) # 121c <close>
      runcmd(pcmd->left);
     5cc:	6488                	ld	a0,8(s1)
     5ce:	00000097          	auipc	ra,0x0
     5d2:	e86080e7          	jalr	-378(ra) # 454 <runcmd>
      close(0);
     5d6:	00001097          	auipc	ra,0x1
     5da:	c46080e7          	jalr	-954(ra) # 121c <close>
      dup(p[0]);
     5de:	fd842503          	lw	a0,-40(s0)
     5e2:	00001097          	auipc	ra,0x1
     5e6:	c8a080e7          	jalr	-886(ra) # 126c <dup>
      close(p[0]);
     5ea:	fd842503          	lw	a0,-40(s0)
     5ee:	00001097          	auipc	ra,0x1
     5f2:	c2e080e7          	jalr	-978(ra) # 121c <close>
      close(p[1]);
     5f6:	fdc42503          	lw	a0,-36(s0)
     5fa:	00001097          	auipc	ra,0x1
     5fe:	c22080e7          	jalr	-990(ra) # 121c <close>
      runcmd(pcmd->right);
     602:	6888                	ld	a0,16(s1)
     604:	00000097          	auipc	ra,0x0
     608:	e50080e7          	jalr	-432(ra) # 454 <runcmd>
    if(fork1() == 0)
     60c:	00000097          	auipc	ra,0x0
     610:	e1a080e7          	jalr	-486(ra) # 426 <fork1>
     614:	ea0515e3          	bnez	a0,4be <runcmd+0x6a>
      runcmd(bcmd->cmd);
     618:	6488                	ld	a0,8(s1)
     61a:	00000097          	auipc	ra,0x0
     61e:	e3a080e7          	jalr	-454(ra) # 454 <runcmd>

0000000000000622 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     622:	1101                	addi	sp,sp,-32
     624:	ec06                	sd	ra,24(sp)
     626:	e822                	sd	s0,16(sp)
     628:	e426                	sd	s1,8(sp)
     62a:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     62c:	0a800513          	li	a0,168
     630:	00001097          	auipc	ra,0x1
     634:	ffa080e7          	jalr	-6(ra) # 162a <malloc>
     638:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     63a:	0a800613          	li	a2,168
     63e:	4581                	li	a1,0
     640:	00001097          	auipc	ra,0x1
     644:	9b8080e7          	jalr	-1608(ra) # ff8 <memset>
  cmd->type = EXEC;
     648:	4785                	li	a5,1
     64a:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     64c:	8526                	mv	a0,s1
     64e:	60e2                	ld	ra,24(sp)
     650:	6442                	ld	s0,16(sp)
     652:	64a2                	ld	s1,8(sp)
     654:	6105                	addi	sp,sp,32
     656:	8082                	ret

0000000000000658 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     658:	7139                	addi	sp,sp,-64
     65a:	fc06                	sd	ra,56(sp)
     65c:	f822                	sd	s0,48(sp)
     65e:	f426                	sd	s1,40(sp)
     660:	f04a                	sd	s2,32(sp)
     662:	ec4e                	sd	s3,24(sp)
     664:	e852                	sd	s4,16(sp)
     666:	e456                	sd	s5,8(sp)
     668:	e05a                	sd	s6,0(sp)
     66a:	0080                	addi	s0,sp,64
     66c:	8b2a                	mv	s6,a0
     66e:	8aae                	mv	s5,a1
     670:	8a32                	mv	s4,a2
     672:	89b6                	mv	s3,a3
     674:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     676:	02800513          	li	a0,40
     67a:	00001097          	auipc	ra,0x1
     67e:	fb0080e7          	jalr	-80(ra) # 162a <malloc>
     682:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     684:	02800613          	li	a2,40
     688:	4581                	li	a1,0
     68a:	00001097          	auipc	ra,0x1
     68e:	96e080e7          	jalr	-1682(ra) # ff8 <memset>
  cmd->type = REDIR;
     692:	4789                	li	a5,2
     694:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     696:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     69a:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     69e:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     6a2:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     6a6:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     6aa:	8526                	mv	a0,s1
     6ac:	70e2                	ld	ra,56(sp)
     6ae:	7442                	ld	s0,48(sp)
     6b0:	74a2                	ld	s1,40(sp)
     6b2:	7902                	ld	s2,32(sp)
     6b4:	69e2                	ld	s3,24(sp)
     6b6:	6a42                	ld	s4,16(sp)
     6b8:	6aa2                	ld	s5,8(sp)
     6ba:	6b02                	ld	s6,0(sp)
     6bc:	6121                	addi	sp,sp,64
     6be:	8082                	ret

00000000000006c0 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     6c0:	7179                	addi	sp,sp,-48
     6c2:	f406                	sd	ra,40(sp)
     6c4:	f022                	sd	s0,32(sp)
     6c6:	ec26                	sd	s1,24(sp)
     6c8:	e84a                	sd	s2,16(sp)
     6ca:	e44e                	sd	s3,8(sp)
     6cc:	1800                	addi	s0,sp,48
     6ce:	89aa                	mv	s3,a0
     6d0:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     6d2:	4561                	li	a0,24
     6d4:	00001097          	auipc	ra,0x1
     6d8:	f56080e7          	jalr	-170(ra) # 162a <malloc>
     6dc:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     6de:	4661                	li	a2,24
     6e0:	4581                	li	a1,0
     6e2:	00001097          	auipc	ra,0x1
     6e6:	916080e7          	jalr	-1770(ra) # ff8 <memset>
  cmd->type = PIPE;
     6ea:	478d                	li	a5,3
     6ec:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     6ee:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     6f2:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     6f6:	8526                	mv	a0,s1
     6f8:	70a2                	ld	ra,40(sp)
     6fa:	7402                	ld	s0,32(sp)
     6fc:	64e2                	ld	s1,24(sp)
     6fe:	6942                	ld	s2,16(sp)
     700:	69a2                	ld	s3,8(sp)
     702:	6145                	addi	sp,sp,48
     704:	8082                	ret

0000000000000706 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     706:	7179                	addi	sp,sp,-48
     708:	f406                	sd	ra,40(sp)
     70a:	f022                	sd	s0,32(sp)
     70c:	ec26                	sd	s1,24(sp)
     70e:	e84a                	sd	s2,16(sp)
     710:	e44e                	sd	s3,8(sp)
     712:	1800                	addi	s0,sp,48
     714:	89aa                	mv	s3,a0
     716:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     718:	4561                	li	a0,24
     71a:	00001097          	auipc	ra,0x1
     71e:	f10080e7          	jalr	-240(ra) # 162a <malloc>
     722:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     724:	4661                	li	a2,24
     726:	4581                	li	a1,0
     728:	00001097          	auipc	ra,0x1
     72c:	8d0080e7          	jalr	-1840(ra) # ff8 <memset>
  cmd->type = LIST;
     730:	4791                	li	a5,4
     732:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     734:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     738:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     73c:	8526                	mv	a0,s1
     73e:	70a2                	ld	ra,40(sp)
     740:	7402                	ld	s0,32(sp)
     742:	64e2                	ld	s1,24(sp)
     744:	6942                	ld	s2,16(sp)
     746:	69a2                	ld	s3,8(sp)
     748:	6145                	addi	sp,sp,48
     74a:	8082                	ret

000000000000074c <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     74c:	1101                	addi	sp,sp,-32
     74e:	ec06                	sd	ra,24(sp)
     750:	e822                	sd	s0,16(sp)
     752:	e426                	sd	s1,8(sp)
     754:	e04a                	sd	s2,0(sp)
     756:	1000                	addi	s0,sp,32
     758:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     75a:	4541                	li	a0,16
     75c:	00001097          	auipc	ra,0x1
     760:	ece080e7          	jalr	-306(ra) # 162a <malloc>
     764:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     766:	4641                	li	a2,16
     768:	4581                	li	a1,0
     76a:	00001097          	auipc	ra,0x1
     76e:	88e080e7          	jalr	-1906(ra) # ff8 <memset>
  cmd->type = BACK;
     772:	4795                	li	a5,5
     774:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     776:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     77a:	8526                	mv	a0,s1
     77c:	60e2                	ld	ra,24(sp)
     77e:	6442                	ld	s0,16(sp)
     780:	64a2                	ld	s1,8(sp)
     782:	6902                	ld	s2,0(sp)
     784:	6105                	addi	sp,sp,32
     786:	8082                	ret

0000000000000788 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     788:	7139                	addi	sp,sp,-64
     78a:	fc06                	sd	ra,56(sp)
     78c:	f822                	sd	s0,48(sp)
     78e:	f426                	sd	s1,40(sp)
     790:	f04a                	sd	s2,32(sp)
     792:	ec4e                	sd	s3,24(sp)
     794:	e852                	sd	s4,16(sp)
     796:	e456                	sd	s5,8(sp)
     798:	e05a                	sd	s6,0(sp)
     79a:	0080                	addi	s0,sp,64
     79c:	8a2a                	mv	s4,a0
     79e:	892e                	mv	s2,a1
     7a0:	8ab2                	mv	s5,a2
     7a2:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     7a4:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     7a6:	00001997          	auipc	s3,0x1
     7aa:	17298993          	addi	s3,s3,370 # 1918 <whitespace>
     7ae:	00b4fd63          	bgeu	s1,a1,7c8 <gettoken+0x40>
     7b2:	0004c583          	lbu	a1,0(s1)
     7b6:	854e                	mv	a0,s3
     7b8:	00001097          	auipc	ra,0x1
     7bc:	862080e7          	jalr	-1950(ra) # 101a <strchr>
     7c0:	c501                	beqz	a0,7c8 <gettoken+0x40>
    s++;
     7c2:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     7c4:	fe9917e3          	bne	s2,s1,7b2 <gettoken+0x2a>
  if(q)
     7c8:	000a8463          	beqz	s5,7d0 <gettoken+0x48>
    *q = s;
     7cc:	009ab023          	sd	s1,0(s5)
  ret = *s;
     7d0:	0004c783          	lbu	a5,0(s1)
     7d4:	00078a9b          	sext.w	s5,a5
  switch(*s){
     7d8:	03c00713          	li	a4,60
     7dc:	06f76563          	bltu	a4,a5,846 <gettoken+0xbe>
     7e0:	03a00713          	li	a4,58
     7e4:	00f76e63          	bltu	a4,a5,800 <gettoken+0x78>
     7e8:	cf89                	beqz	a5,802 <gettoken+0x7a>
     7ea:	02600713          	li	a4,38
     7ee:	00e78963          	beq	a5,a4,800 <gettoken+0x78>
     7f2:	fd87879b          	addiw	a5,a5,-40
     7f6:	0ff7f793          	andi	a5,a5,255
     7fa:	4705                	li	a4,1
     7fc:	06f76c63          	bltu	a4,a5,874 <gettoken+0xec>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     800:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     802:	000b0463          	beqz	s6,80a <gettoken+0x82>
    *eq = s;
     806:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     80a:	00001997          	auipc	s3,0x1
     80e:	10e98993          	addi	s3,s3,270 # 1918 <whitespace>
     812:	0124fd63          	bgeu	s1,s2,82c <gettoken+0xa4>
     816:	0004c583          	lbu	a1,0(s1)
     81a:	854e                	mv	a0,s3
     81c:	00000097          	auipc	ra,0x0
     820:	7fe080e7          	jalr	2046(ra) # 101a <strchr>
     824:	c501                	beqz	a0,82c <gettoken+0xa4>
    s++;
     826:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     828:	fe9917e3          	bne	s2,s1,816 <gettoken+0x8e>
  *ps = s;
     82c:	009a3023          	sd	s1,0(s4)
  return ret;
}
     830:	8556                	mv	a0,s5
     832:	70e2                	ld	ra,56(sp)
     834:	7442                	ld	s0,48(sp)
     836:	74a2                	ld	s1,40(sp)
     838:	7902                	ld	s2,32(sp)
     83a:	69e2                	ld	s3,24(sp)
     83c:	6a42                	ld	s4,16(sp)
     83e:	6aa2                	ld	s5,8(sp)
     840:	6b02                	ld	s6,0(sp)
     842:	6121                	addi	sp,sp,64
     844:	8082                	ret
  switch(*s){
     846:	03e00713          	li	a4,62
     84a:	02e79163          	bne	a5,a4,86c <gettoken+0xe4>
    s++;
     84e:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     852:	0014c703          	lbu	a4,1(s1)
     856:	03e00793          	li	a5,62
      s++;
     85a:	0489                	addi	s1,s1,2
      ret = '+';
     85c:	02b00a93          	li	s5,43
    if(*s == '>'){
     860:	faf701e3          	beq	a4,a5,802 <gettoken+0x7a>
    s++;
     864:	84b6                	mv	s1,a3
  ret = *s;
     866:	03e00a93          	li	s5,62
     86a:	bf61                	j	802 <gettoken+0x7a>
  switch(*s){
     86c:	07c00713          	li	a4,124
     870:	f8e788e3          	beq	a5,a4,800 <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     874:	00001997          	auipc	s3,0x1
     878:	0a498993          	addi	s3,s3,164 # 1918 <whitespace>
     87c:	00001a97          	auipc	s5,0x1
     880:	094a8a93          	addi	s5,s5,148 # 1910 <symbols>
     884:	0324f563          	bgeu	s1,s2,8ae <gettoken+0x126>
     888:	0004c583          	lbu	a1,0(s1)
     88c:	854e                	mv	a0,s3
     88e:	00000097          	auipc	ra,0x0
     892:	78c080e7          	jalr	1932(ra) # 101a <strchr>
     896:	e505                	bnez	a0,8be <gettoken+0x136>
     898:	0004c583          	lbu	a1,0(s1)
     89c:	8556                	mv	a0,s5
     89e:	00000097          	auipc	ra,0x0
     8a2:	77c080e7          	jalr	1916(ra) # 101a <strchr>
     8a6:	e909                	bnez	a0,8b8 <gettoken+0x130>
      s++;
     8a8:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     8aa:	fc991fe3          	bne	s2,s1,888 <gettoken+0x100>
  if(eq)
     8ae:	06100a93          	li	s5,97
     8b2:	f40b1ae3          	bnez	s6,806 <gettoken+0x7e>
     8b6:	bf9d                	j	82c <gettoken+0xa4>
    ret = 'a';
     8b8:	06100a93          	li	s5,97
     8bc:	b799                	j	802 <gettoken+0x7a>
     8be:	06100a93          	li	s5,97
     8c2:	b781                	j	802 <gettoken+0x7a>

00000000000008c4 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     8c4:	7139                	addi	sp,sp,-64
     8c6:	fc06                	sd	ra,56(sp)
     8c8:	f822                	sd	s0,48(sp)
     8ca:	f426                	sd	s1,40(sp)
     8cc:	f04a                	sd	s2,32(sp)
     8ce:	ec4e                	sd	s3,24(sp)
     8d0:	e852                	sd	s4,16(sp)
     8d2:	e456                	sd	s5,8(sp)
     8d4:	0080                	addi	s0,sp,64
     8d6:	8a2a                	mv	s4,a0
     8d8:	892e                	mv	s2,a1
     8da:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     8dc:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     8de:	00001997          	auipc	s3,0x1
     8e2:	03a98993          	addi	s3,s3,58 # 1918 <whitespace>
     8e6:	00b4fd63          	bgeu	s1,a1,900 <peek+0x3c>
     8ea:	0004c583          	lbu	a1,0(s1)
     8ee:	854e                	mv	a0,s3
     8f0:	00000097          	auipc	ra,0x0
     8f4:	72a080e7          	jalr	1834(ra) # 101a <strchr>
     8f8:	c501                	beqz	a0,900 <peek+0x3c>
    s++;
     8fa:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     8fc:	fe9917e3          	bne	s2,s1,8ea <peek+0x26>
  *ps = s;
     900:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     904:	0004c583          	lbu	a1,0(s1)
     908:	4501                	li	a0,0
     90a:	e991                	bnez	a1,91e <peek+0x5a>
}
     90c:	70e2                	ld	ra,56(sp)
     90e:	7442                	ld	s0,48(sp)
     910:	74a2                	ld	s1,40(sp)
     912:	7902                	ld	s2,32(sp)
     914:	69e2                	ld	s3,24(sp)
     916:	6a42                	ld	s4,16(sp)
     918:	6aa2                	ld	s5,8(sp)
     91a:	6121                	addi	sp,sp,64
     91c:	8082                	ret
  return *s && strchr(toks, *s);
     91e:	8556                	mv	a0,s5
     920:	00000097          	auipc	ra,0x0
     924:	6fa080e7          	jalr	1786(ra) # 101a <strchr>
     928:	00a03533          	snez	a0,a0
     92c:	b7c5                	j	90c <peek+0x48>

000000000000092e <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     92e:	7159                	addi	sp,sp,-112
     930:	f486                	sd	ra,104(sp)
     932:	f0a2                	sd	s0,96(sp)
     934:	eca6                	sd	s1,88(sp)
     936:	e8ca                	sd	s2,80(sp)
     938:	e4ce                	sd	s3,72(sp)
     93a:	e0d2                	sd	s4,64(sp)
     93c:	fc56                	sd	s5,56(sp)
     93e:	f85a                	sd	s6,48(sp)
     940:	f45e                	sd	s7,40(sp)
     942:	f062                	sd	s8,32(sp)
     944:	ec66                	sd	s9,24(sp)
     946:	1880                	addi	s0,sp,112
     948:	8a2a                	mv	s4,a0
     94a:	89ae                	mv	s3,a1
     94c:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     94e:	00001b97          	auipc	s7,0x1
     952:	ebab8b93          	addi	s7,s7,-326 # 1808 <malloc+0x1de>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     956:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     95a:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     95e:	a02d                	j	988 <parseredirs+0x5a>
      panic("missing file for redirection");
     960:	00001517          	auipc	a0,0x1
     964:	e8850513          	addi	a0,a0,-376 # 17e8 <malloc+0x1be>
     968:	00000097          	auipc	ra,0x0
     96c:	a98080e7          	jalr	-1384(ra) # 400 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     970:	4701                	li	a4,0
     972:	4681                	li	a3,0
     974:	f9043603          	ld	a2,-112(s0)
     978:	f9843583          	ld	a1,-104(s0)
     97c:	8552                	mv	a0,s4
     97e:	00000097          	auipc	ra,0x0
     982:	cda080e7          	jalr	-806(ra) # 658 <redircmd>
     986:	8a2a                	mv	s4,a0
    switch(tok){
     988:	03e00b13          	li	s6,62
     98c:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     990:	865e                	mv	a2,s7
     992:	85ca                	mv	a1,s2
     994:	854e                	mv	a0,s3
     996:	00000097          	auipc	ra,0x0
     99a:	f2e080e7          	jalr	-210(ra) # 8c4 <peek>
     99e:	c925                	beqz	a0,a0e <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     9a0:	4681                	li	a3,0
     9a2:	4601                	li	a2,0
     9a4:	85ca                	mv	a1,s2
     9a6:	854e                	mv	a0,s3
     9a8:	00000097          	auipc	ra,0x0
     9ac:	de0080e7          	jalr	-544(ra) # 788 <gettoken>
     9b0:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     9b2:	f9040693          	addi	a3,s0,-112
     9b6:	f9840613          	addi	a2,s0,-104
     9ba:	85ca                	mv	a1,s2
     9bc:	854e                	mv	a0,s3
     9be:	00000097          	auipc	ra,0x0
     9c2:	dca080e7          	jalr	-566(ra) # 788 <gettoken>
     9c6:	f9851de3          	bne	a0,s8,960 <parseredirs+0x32>
    switch(tok){
     9ca:	fb9483e3          	beq	s1,s9,970 <parseredirs+0x42>
     9ce:	03648263          	beq	s1,s6,9f2 <parseredirs+0xc4>
     9d2:	fb549fe3          	bne	s1,s5,990 <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9d6:	4705                	li	a4,1
     9d8:	20100693          	li	a3,513
     9dc:	f9043603          	ld	a2,-112(s0)
     9e0:	f9843583          	ld	a1,-104(s0)
     9e4:	8552                	mv	a0,s4
     9e6:	00000097          	auipc	ra,0x0
     9ea:	c72080e7          	jalr	-910(ra) # 658 <redircmd>
     9ee:	8a2a                	mv	s4,a0
      break;
     9f0:	bf61                	j	988 <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     9f2:	4705                	li	a4,1
     9f4:	60100693          	li	a3,1537
     9f8:	f9043603          	ld	a2,-112(s0)
     9fc:	f9843583          	ld	a1,-104(s0)
     a00:	8552                	mv	a0,s4
     a02:	00000097          	auipc	ra,0x0
     a06:	c56080e7          	jalr	-938(ra) # 658 <redircmd>
     a0a:	8a2a                	mv	s4,a0
      break;
     a0c:	bfb5                	j	988 <parseredirs+0x5a>
    }
  }
  return cmd;
}
     a0e:	8552                	mv	a0,s4
     a10:	70a6                	ld	ra,104(sp)
     a12:	7406                	ld	s0,96(sp)
     a14:	64e6                	ld	s1,88(sp)
     a16:	6946                	ld	s2,80(sp)
     a18:	69a6                	ld	s3,72(sp)
     a1a:	6a06                	ld	s4,64(sp)
     a1c:	7ae2                	ld	s5,56(sp)
     a1e:	7b42                	ld	s6,48(sp)
     a20:	7ba2                	ld	s7,40(sp)
     a22:	7c02                	ld	s8,32(sp)
     a24:	6ce2                	ld	s9,24(sp)
     a26:	6165                	addi	sp,sp,112
     a28:	8082                	ret

0000000000000a2a <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     a2a:	7159                	addi	sp,sp,-112
     a2c:	f486                	sd	ra,104(sp)
     a2e:	f0a2                	sd	s0,96(sp)
     a30:	eca6                	sd	s1,88(sp)
     a32:	e8ca                	sd	s2,80(sp)
     a34:	e4ce                	sd	s3,72(sp)
     a36:	e0d2                	sd	s4,64(sp)
     a38:	fc56                	sd	s5,56(sp)
     a3a:	f85a                	sd	s6,48(sp)
     a3c:	f45e                	sd	s7,40(sp)
     a3e:	f062                	sd	s8,32(sp)
     a40:	ec66                	sd	s9,24(sp)
     a42:	1880                	addi	s0,sp,112
     a44:	8a2a                	mv	s4,a0
     a46:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     a48:	00001617          	auipc	a2,0x1
     a4c:	dc860613          	addi	a2,a2,-568 # 1810 <malloc+0x1e6>
     a50:	00000097          	auipc	ra,0x0
     a54:	e74080e7          	jalr	-396(ra) # 8c4 <peek>
     a58:	e905                	bnez	a0,a88 <parseexec+0x5e>
     a5a:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     a5c:	00000097          	auipc	ra,0x0
     a60:	bc6080e7          	jalr	-1082(ra) # 622 <execcmd>
     a64:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     a66:	8656                	mv	a2,s5
     a68:	85d2                	mv	a1,s4
     a6a:	00000097          	auipc	ra,0x0
     a6e:	ec4080e7          	jalr	-316(ra) # 92e <parseredirs>
     a72:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     a74:	008c0913          	addi	s2,s8,8
     a78:	00001b17          	auipc	s6,0x1
     a7c:	db8b0b13          	addi	s6,s6,-584 # 1830 <malloc+0x206>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     a80:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     a84:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     a86:	a0b1                	j	ad2 <parseexec+0xa8>
    return parseblock(ps, es);
     a88:	85d6                	mv	a1,s5
     a8a:	8552                	mv	a0,s4
     a8c:	00000097          	auipc	ra,0x0
     a90:	1bc080e7          	jalr	444(ra) # c48 <parseblock>
     a94:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     a96:	8526                	mv	a0,s1
     a98:	70a6                	ld	ra,104(sp)
     a9a:	7406                	ld	s0,96(sp)
     a9c:	64e6                	ld	s1,88(sp)
     a9e:	6946                	ld	s2,80(sp)
     aa0:	69a6                	ld	s3,72(sp)
     aa2:	6a06                	ld	s4,64(sp)
     aa4:	7ae2                	ld	s5,56(sp)
     aa6:	7b42                	ld	s6,48(sp)
     aa8:	7ba2                	ld	s7,40(sp)
     aaa:	7c02                	ld	s8,32(sp)
     aac:	6ce2                	ld	s9,24(sp)
     aae:	6165                	addi	sp,sp,112
     ab0:	8082                	ret
      panic("syntax");
     ab2:	00001517          	auipc	a0,0x1
     ab6:	d6650513          	addi	a0,a0,-666 # 1818 <malloc+0x1ee>
     aba:	00000097          	auipc	ra,0x0
     abe:	946080e7          	jalr	-1722(ra) # 400 <panic>
    ret = parseredirs(ret, ps, es);
     ac2:	8656                	mv	a2,s5
     ac4:	85d2                	mv	a1,s4
     ac6:	8526                	mv	a0,s1
     ac8:	00000097          	auipc	ra,0x0
     acc:	e66080e7          	jalr	-410(ra) # 92e <parseredirs>
     ad0:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     ad2:	865a                	mv	a2,s6
     ad4:	85d6                	mv	a1,s5
     ad6:	8552                	mv	a0,s4
     ad8:	00000097          	auipc	ra,0x0
     adc:	dec080e7          	jalr	-532(ra) # 8c4 <peek>
     ae0:	e131                	bnez	a0,b24 <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     ae2:	f9040693          	addi	a3,s0,-112
     ae6:	f9840613          	addi	a2,s0,-104
     aea:	85d6                	mv	a1,s5
     aec:	8552                	mv	a0,s4
     aee:	00000097          	auipc	ra,0x0
     af2:	c9a080e7          	jalr	-870(ra) # 788 <gettoken>
     af6:	c51d                	beqz	a0,b24 <parseexec+0xfa>
    if(tok != 'a')
     af8:	fb951de3          	bne	a0,s9,ab2 <parseexec+0x88>
    cmd->argv[argc] = q;
     afc:	f9843783          	ld	a5,-104(s0)
     b00:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     b04:	f9043783          	ld	a5,-112(s0)
     b08:	04f93823          	sd	a5,80(s2)
    argc++;
     b0c:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     b0e:	0921                	addi	s2,s2,8
     b10:	fb7999e3          	bne	s3,s7,ac2 <parseexec+0x98>
      panic("too many args");
     b14:	00001517          	auipc	a0,0x1
     b18:	d0c50513          	addi	a0,a0,-756 # 1820 <malloc+0x1f6>
     b1c:	00000097          	auipc	ra,0x0
     b20:	8e4080e7          	jalr	-1820(ra) # 400 <panic>
  cmd->argv[argc] = 0;
     b24:	098e                	slli	s3,s3,0x3
     b26:	99e2                	add	s3,s3,s8
     b28:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     b2c:	0409bc23          	sd	zero,88(s3)
  return ret;
     b30:	b79d                	j	a96 <parseexec+0x6c>

0000000000000b32 <parsepipe>:
{
     b32:	7179                	addi	sp,sp,-48
     b34:	f406                	sd	ra,40(sp)
     b36:	f022                	sd	s0,32(sp)
     b38:	ec26                	sd	s1,24(sp)
     b3a:	e84a                	sd	s2,16(sp)
     b3c:	e44e                	sd	s3,8(sp)
     b3e:	1800                	addi	s0,sp,48
     b40:	892a                	mv	s2,a0
     b42:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     b44:	00000097          	auipc	ra,0x0
     b48:	ee6080e7          	jalr	-282(ra) # a2a <parseexec>
     b4c:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     b4e:	00001617          	auipc	a2,0x1
     b52:	cea60613          	addi	a2,a2,-790 # 1838 <malloc+0x20e>
     b56:	85ce                	mv	a1,s3
     b58:	854a                	mv	a0,s2
     b5a:	00000097          	auipc	ra,0x0
     b5e:	d6a080e7          	jalr	-662(ra) # 8c4 <peek>
     b62:	e909                	bnez	a0,b74 <parsepipe+0x42>
}
     b64:	8526                	mv	a0,s1
     b66:	70a2                	ld	ra,40(sp)
     b68:	7402                	ld	s0,32(sp)
     b6a:	64e2                	ld	s1,24(sp)
     b6c:	6942                	ld	s2,16(sp)
     b6e:	69a2                	ld	s3,8(sp)
     b70:	6145                	addi	sp,sp,48
     b72:	8082                	ret
    gettoken(ps, es, 0, 0);
     b74:	4681                	li	a3,0
     b76:	4601                	li	a2,0
     b78:	85ce                	mv	a1,s3
     b7a:	854a                	mv	a0,s2
     b7c:	00000097          	auipc	ra,0x0
     b80:	c0c080e7          	jalr	-1012(ra) # 788 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     b84:	85ce                	mv	a1,s3
     b86:	854a                	mv	a0,s2
     b88:	00000097          	auipc	ra,0x0
     b8c:	faa080e7          	jalr	-86(ra) # b32 <parsepipe>
     b90:	85aa                	mv	a1,a0
     b92:	8526                	mv	a0,s1
     b94:	00000097          	auipc	ra,0x0
     b98:	b2c080e7          	jalr	-1236(ra) # 6c0 <pipecmd>
     b9c:	84aa                	mv	s1,a0
  return cmd;
     b9e:	b7d9                	j	b64 <parsepipe+0x32>

0000000000000ba0 <parseline>:
{
     ba0:	7179                	addi	sp,sp,-48
     ba2:	f406                	sd	ra,40(sp)
     ba4:	f022                	sd	s0,32(sp)
     ba6:	ec26                	sd	s1,24(sp)
     ba8:	e84a                	sd	s2,16(sp)
     baa:	e44e                	sd	s3,8(sp)
     bac:	e052                	sd	s4,0(sp)
     bae:	1800                	addi	s0,sp,48
     bb0:	892a                	mv	s2,a0
     bb2:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     bb4:	00000097          	auipc	ra,0x0
     bb8:	f7e080e7          	jalr	-130(ra) # b32 <parsepipe>
     bbc:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     bbe:	00001a17          	auipc	s4,0x1
     bc2:	c82a0a13          	addi	s4,s4,-894 # 1840 <malloc+0x216>
     bc6:	a839                	j	be4 <parseline+0x44>
    gettoken(ps, es, 0, 0);
     bc8:	4681                	li	a3,0
     bca:	4601                	li	a2,0
     bcc:	85ce                	mv	a1,s3
     bce:	854a                	mv	a0,s2
     bd0:	00000097          	auipc	ra,0x0
     bd4:	bb8080e7          	jalr	-1096(ra) # 788 <gettoken>
    cmd = backcmd(cmd);
     bd8:	8526                	mv	a0,s1
     bda:	00000097          	auipc	ra,0x0
     bde:	b72080e7          	jalr	-1166(ra) # 74c <backcmd>
     be2:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     be4:	8652                	mv	a2,s4
     be6:	85ce                	mv	a1,s3
     be8:	854a                	mv	a0,s2
     bea:	00000097          	auipc	ra,0x0
     bee:	cda080e7          	jalr	-806(ra) # 8c4 <peek>
     bf2:	f979                	bnez	a0,bc8 <parseline+0x28>
  if(peek(ps, es, ";")){
     bf4:	00001617          	auipc	a2,0x1
     bf8:	c5460613          	addi	a2,a2,-940 # 1848 <malloc+0x21e>
     bfc:	85ce                	mv	a1,s3
     bfe:	854a                	mv	a0,s2
     c00:	00000097          	auipc	ra,0x0
     c04:	cc4080e7          	jalr	-828(ra) # 8c4 <peek>
     c08:	e911                	bnez	a0,c1c <parseline+0x7c>
}
     c0a:	8526                	mv	a0,s1
     c0c:	70a2                	ld	ra,40(sp)
     c0e:	7402                	ld	s0,32(sp)
     c10:	64e2                	ld	s1,24(sp)
     c12:	6942                	ld	s2,16(sp)
     c14:	69a2                	ld	s3,8(sp)
     c16:	6a02                	ld	s4,0(sp)
     c18:	6145                	addi	sp,sp,48
     c1a:	8082                	ret
    gettoken(ps, es, 0, 0);
     c1c:	4681                	li	a3,0
     c1e:	4601                	li	a2,0
     c20:	85ce                	mv	a1,s3
     c22:	854a                	mv	a0,s2
     c24:	00000097          	auipc	ra,0x0
     c28:	b64080e7          	jalr	-1180(ra) # 788 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     c2c:	85ce                	mv	a1,s3
     c2e:	854a                	mv	a0,s2
     c30:	00000097          	auipc	ra,0x0
     c34:	f70080e7          	jalr	-144(ra) # ba0 <parseline>
     c38:	85aa                	mv	a1,a0
     c3a:	8526                	mv	a0,s1
     c3c:	00000097          	auipc	ra,0x0
     c40:	aca080e7          	jalr	-1334(ra) # 706 <listcmd>
     c44:	84aa                	mv	s1,a0
  return cmd;
     c46:	b7d1                	j	c0a <parseline+0x6a>

0000000000000c48 <parseblock>:
{
     c48:	7179                	addi	sp,sp,-48
     c4a:	f406                	sd	ra,40(sp)
     c4c:	f022                	sd	s0,32(sp)
     c4e:	ec26                	sd	s1,24(sp)
     c50:	e84a                	sd	s2,16(sp)
     c52:	e44e                	sd	s3,8(sp)
     c54:	1800                	addi	s0,sp,48
     c56:	84aa                	mv	s1,a0
     c58:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     c5a:	00001617          	auipc	a2,0x1
     c5e:	bb660613          	addi	a2,a2,-1098 # 1810 <malloc+0x1e6>
     c62:	00000097          	auipc	ra,0x0
     c66:	c62080e7          	jalr	-926(ra) # 8c4 <peek>
     c6a:	c12d                	beqz	a0,ccc <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     c6c:	4681                	li	a3,0
     c6e:	4601                	li	a2,0
     c70:	85ca                	mv	a1,s2
     c72:	8526                	mv	a0,s1
     c74:	00000097          	auipc	ra,0x0
     c78:	b14080e7          	jalr	-1260(ra) # 788 <gettoken>
  cmd = parseline(ps, es);
     c7c:	85ca                	mv	a1,s2
     c7e:	8526                	mv	a0,s1
     c80:	00000097          	auipc	ra,0x0
     c84:	f20080e7          	jalr	-224(ra) # ba0 <parseline>
     c88:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     c8a:	00001617          	auipc	a2,0x1
     c8e:	bd660613          	addi	a2,a2,-1066 # 1860 <malloc+0x236>
     c92:	85ca                	mv	a1,s2
     c94:	8526                	mv	a0,s1
     c96:	00000097          	auipc	ra,0x0
     c9a:	c2e080e7          	jalr	-978(ra) # 8c4 <peek>
     c9e:	cd1d                	beqz	a0,cdc <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     ca0:	4681                	li	a3,0
     ca2:	4601                	li	a2,0
     ca4:	85ca                	mv	a1,s2
     ca6:	8526                	mv	a0,s1
     ca8:	00000097          	auipc	ra,0x0
     cac:	ae0080e7          	jalr	-1312(ra) # 788 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     cb0:	864a                	mv	a2,s2
     cb2:	85a6                	mv	a1,s1
     cb4:	854e                	mv	a0,s3
     cb6:	00000097          	auipc	ra,0x0
     cba:	c78080e7          	jalr	-904(ra) # 92e <parseredirs>
}
     cbe:	70a2                	ld	ra,40(sp)
     cc0:	7402                	ld	s0,32(sp)
     cc2:	64e2                	ld	s1,24(sp)
     cc4:	6942                	ld	s2,16(sp)
     cc6:	69a2                	ld	s3,8(sp)
     cc8:	6145                	addi	sp,sp,48
     cca:	8082                	ret
    panic("parseblock");
     ccc:	00001517          	auipc	a0,0x1
     cd0:	b8450513          	addi	a0,a0,-1148 # 1850 <malloc+0x226>
     cd4:	fffff097          	auipc	ra,0xfffff
     cd8:	72c080e7          	jalr	1836(ra) # 400 <panic>
    panic("syntax - missing )");
     cdc:	00001517          	auipc	a0,0x1
     ce0:	b8c50513          	addi	a0,a0,-1140 # 1868 <malloc+0x23e>
     ce4:	fffff097          	auipc	ra,0xfffff
     ce8:	71c080e7          	jalr	1820(ra) # 400 <panic>

0000000000000cec <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     cec:	1101                	addi	sp,sp,-32
     cee:	ec06                	sd	ra,24(sp)
     cf0:	e822                	sd	s0,16(sp)
     cf2:	e426                	sd	s1,8(sp)
     cf4:	1000                	addi	s0,sp,32
     cf6:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     cf8:	c521                	beqz	a0,d40 <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     cfa:	4118                	lw	a4,0(a0)
     cfc:	4795                	li	a5,5
     cfe:	04e7e163          	bltu	a5,a4,d40 <nulterminate+0x54>
     d02:	00056783          	lwu	a5,0(a0)
     d06:	078a                	slli	a5,a5,0x2
     d08:	00001717          	auipc	a4,0x1
     d0c:	bc870713          	addi	a4,a4,-1080 # 18d0 <malloc+0x2a6>
     d10:	97ba                	add	a5,a5,a4
     d12:	439c                	lw	a5,0(a5)
     d14:	97ba                	add	a5,a5,a4
     d16:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     d18:	651c                	ld	a5,8(a0)
     d1a:	c39d                	beqz	a5,d40 <nulterminate+0x54>
     d1c:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     d20:	67b8                	ld	a4,72(a5)
     d22:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     d26:	07a1                	addi	a5,a5,8
     d28:	ff87b703          	ld	a4,-8(a5)
     d2c:	fb75                	bnez	a4,d20 <nulterminate+0x34>
     d2e:	a809                	j	d40 <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     d30:	6508                	ld	a0,8(a0)
     d32:	00000097          	auipc	ra,0x0
     d36:	fba080e7          	jalr	-70(ra) # cec <nulterminate>
    *rcmd->efile = 0;
     d3a:	6c9c                	ld	a5,24(s1)
     d3c:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     d40:	8526                	mv	a0,s1
     d42:	60e2                	ld	ra,24(sp)
     d44:	6442                	ld	s0,16(sp)
     d46:	64a2                	ld	s1,8(sp)
     d48:	6105                	addi	sp,sp,32
     d4a:	8082                	ret
    nulterminate(pcmd->left);
     d4c:	6508                	ld	a0,8(a0)
     d4e:	00000097          	auipc	ra,0x0
     d52:	f9e080e7          	jalr	-98(ra) # cec <nulterminate>
    nulterminate(pcmd->right);
     d56:	6888                	ld	a0,16(s1)
     d58:	00000097          	auipc	ra,0x0
     d5c:	f94080e7          	jalr	-108(ra) # cec <nulterminate>
    break;
     d60:	b7c5                	j	d40 <nulterminate+0x54>
    nulterminate(lcmd->left);
     d62:	6508                	ld	a0,8(a0)
     d64:	00000097          	auipc	ra,0x0
     d68:	f88080e7          	jalr	-120(ra) # cec <nulterminate>
    nulterminate(lcmd->right);
     d6c:	6888                	ld	a0,16(s1)
     d6e:	00000097          	auipc	ra,0x0
     d72:	f7e080e7          	jalr	-130(ra) # cec <nulterminate>
    break;
     d76:	b7e9                	j	d40 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     d78:	6508                	ld	a0,8(a0)
     d7a:	00000097          	auipc	ra,0x0
     d7e:	f72080e7          	jalr	-142(ra) # cec <nulterminate>
    break;
     d82:	bf7d                	j	d40 <nulterminate+0x54>

0000000000000d84 <parsecmd>:
{
     d84:	7179                	addi	sp,sp,-48
     d86:	f406                	sd	ra,40(sp)
     d88:	f022                	sd	s0,32(sp)
     d8a:	ec26                	sd	s1,24(sp)
     d8c:	e84a                	sd	s2,16(sp)
     d8e:	1800                	addi	s0,sp,48
     d90:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     d94:	84aa                	mv	s1,a0
     d96:	00000097          	auipc	ra,0x0
     d9a:	238080e7          	jalr	568(ra) # fce <strlen>
     d9e:	1502                	slli	a0,a0,0x20
     da0:	9101                	srli	a0,a0,0x20
     da2:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     da4:	85a6                	mv	a1,s1
     da6:	fd840513          	addi	a0,s0,-40
     daa:	00000097          	auipc	ra,0x0
     dae:	df6080e7          	jalr	-522(ra) # ba0 <parseline>
     db2:	892a                	mv	s2,a0
  peek(&s, es, "");
     db4:	00001617          	auipc	a2,0x1
     db8:	acc60613          	addi	a2,a2,-1332 # 1880 <malloc+0x256>
     dbc:	85a6                	mv	a1,s1
     dbe:	fd840513          	addi	a0,s0,-40
     dc2:	00000097          	auipc	ra,0x0
     dc6:	b02080e7          	jalr	-1278(ra) # 8c4 <peek>
  if(s != es){
     dca:	fd843603          	ld	a2,-40(s0)
     dce:	00961e63          	bne	a2,s1,dea <parsecmd+0x66>
  nulterminate(cmd);
     dd2:	854a                	mv	a0,s2
     dd4:	00000097          	auipc	ra,0x0
     dd8:	f18080e7          	jalr	-232(ra) # cec <nulterminate>
}
     ddc:	854a                	mv	a0,s2
     dde:	70a2                	ld	ra,40(sp)
     de0:	7402                	ld	s0,32(sp)
     de2:	64e2                	ld	s1,24(sp)
     de4:	6942                	ld	s2,16(sp)
     de6:	6145                	addi	sp,sp,48
     de8:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     dea:	00001597          	auipc	a1,0x1
     dee:	a9e58593          	addi	a1,a1,-1378 # 1888 <malloc+0x25e>
     df2:	4509                	li	a0,2
     df4:	00000097          	auipc	ra,0x0
     df8:	74a080e7          	jalr	1866(ra) # 153e <fprintf>
    panic("syntax");
     dfc:	00001517          	auipc	a0,0x1
     e00:	a1c50513          	addi	a0,a0,-1508 # 1818 <malloc+0x1ee>
     e04:	fffff097          	auipc	ra,0xfffff
     e08:	5fc080e7          	jalr	1532(ra) # 400 <panic>

0000000000000e0c <process_one_cmd>:
void process_one_cmd(char *buf) {
     e0c:	1101                	addi	sp,sp,-32
     e0e:	ec06                	sd	ra,24(sp)
     e10:	e822                	sd	s0,16(sp)
     e12:	e426                	sd	s1,8(sp)
     e14:	1000                	addi	s0,sp,32
     e16:	84aa                	mv	s1,a0
  if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     e18:	00054703          	lbu	a4,0(a0)
     e1c:	06300793          	li	a5,99
     e20:	00f71863          	bne	a4,a5,e30 <process_one_cmd+0x24>
     e24:	00154703          	lbu	a4,1(a0)
     e28:	06400793          	li	a5,100
     e2c:	02f70c63          	beq	a4,a5,e64 <process_one_cmd+0x58>
    if(memcmp(buf, "wait ", 5) == 0) {
     e30:	4615                	li	a2,5
     e32:	00001597          	auipc	a1,0x1
     e36:	a7658593          	addi	a1,a1,-1418 # 18a8 <malloc+0x27e>
     e3a:	8526                	mv	a0,s1
     e3c:	00000097          	auipc	ra,0x0
     e40:	35e080e7          	jalr	862(ra) # 119a <memcmp>
     e44:	c525                	beqz	a0,eac <process_one_cmd+0xa0>
    if(fork1() == 0)
     e46:	fffff097          	auipc	ra,0xfffff
     e4a:	5e0080e7          	jalr	1504(ra) # 426 <fork1>
     e4e:	c935                	beqz	a0,ec2 <process_one_cmd+0xb6>
    wait(0);
     e50:	4501                	li	a0,0
     e52:	00000097          	auipc	ra,0x0
     e56:	3aa080e7          	jalr	938(ra) # 11fc <wait>
}
     e5a:	60e2                	ld	ra,24(sp)
     e5c:	6442                	ld	s0,16(sp)
     e5e:	64a2                	ld	s1,8(sp)
     e60:	6105                	addi	sp,sp,32
     e62:	8082                	ret
  if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     e64:	00254703          	lbu	a4,2(a0)
     e68:	02000793          	li	a5,32
     e6c:	fcf712e3          	bne	a4,a5,e30 <process_one_cmd+0x24>
      buf[strlen(buf)-1] = 0;  // chop \n
     e70:	00000097          	auipc	ra,0x0
     e74:	15e080e7          	jalr	350(ra) # fce <strlen>
     e78:	fff5079b          	addiw	a5,a0,-1
     e7c:	1782                	slli	a5,a5,0x20
     e7e:	9381                	srli	a5,a5,0x20
     e80:	97a6                	add	a5,a5,s1
     e82:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     e86:	048d                	addi	s1,s1,3
     e88:	8526                	mv	a0,s1
     e8a:	00000097          	auipc	ra,0x0
     e8e:	3da080e7          	jalr	986(ra) # 1264 <chdir>
     e92:	fc0554e3          	bgez	a0,e5a <process_one_cmd+0x4e>
        fprintf(2, "cannot cd %s\n", buf+3);
     e96:	8626                	mv	a2,s1
     e98:	00001597          	auipc	a1,0x1
     e9c:	a0058593          	addi	a1,a1,-1536 # 1898 <malloc+0x26e>
     ea0:	4509                	li	a0,2
     ea2:	00000097          	auipc	ra,0x0
     ea6:	69c080e7          	jalr	1692(ra) # 153e <fprintf>
     eaa:	bf45                	j	e5a <process_one_cmd+0x4e>
      sleep(atoi(buf+5));
     eac:	00548513          	addi	a0,s1,5
     eb0:	00000097          	auipc	ra,0x0
     eb4:	248080e7          	jalr	584(ra) # 10f8 <atoi>
     eb8:	00000097          	auipc	ra,0x0
     ebc:	3cc080e7          	jalr	972(ra) # 1284 <sleep>
      return;
     ec0:	bf69                	j	e5a <process_one_cmd+0x4e>
      runcmd(parsecmd(buf));
     ec2:	8526                	mv	a0,s1
     ec4:	00000097          	auipc	ra,0x0
     ec8:	ec0080e7          	jalr	-320(ra) # d84 <parsecmd>
     ecc:	fffff097          	auipc	ra,0xfffff
     ed0:	588080e7          	jalr	1416(ra) # 454 <runcmd>

0000000000000ed4 <main>:
{
     ed4:	7179                	addi	sp,sp,-48
     ed6:	f406                	sd	ra,40(sp)
     ed8:	f022                	sd	s0,32(sp)
     eda:	ec26                	sd	s1,24(sp)
     edc:	e84a                	sd	s2,16(sp)
     ede:	e44e                	sd	s3,8(sp)
     ee0:	1800                	addi	s0,sp,48
  if(argc >= 2) { // miigon: added support for running script from a file
     ee2:	4705                	li	a4,1
     ee4:	02a74c63          	blt	a4,a0,f1c <main+0x48>
  while((fd = open("console", O_RDWR)) >= 0){
     ee8:	00001497          	auipc	s1,0x1
     eec:	9c848493          	addi	s1,s1,-1592 # 18b0 <malloc+0x286>
     ef0:	4589                	li	a1,2
     ef2:	8526                	mv	a0,s1
     ef4:	00000097          	auipc	ra,0x0
     ef8:	340080e7          	jalr	832(ra) # 1234 <open>
     efc:	00054963          	bltz	a0,f0e <main+0x3a>
    if(fd >= 3){
     f00:	4789                	li	a5,2
     f02:	fea7d7e3          	bge	a5,a0,ef0 <main+0x1c>
      close(fd);
     f06:	00000097          	auipc	ra,0x0
     f0a:	316080e7          	jalr	790(ra) # 121c <close>
  while(get_oneline_of_cmd(buf, sizeof(buf)) >= 0){
     f0e:	00001997          	auipc	s3,0x1
     f12:	a2298993          	addi	s3,s3,-1502 # 1930 <buf.0>
      if(*p == ';') {
     f16:	03b00913          	li	s2,59
     f1a:	a83d                	j	f58 <main+0x84>
     f1c:	87ae                	mv	a5,a1
    script_fd = open(argv[1], O_RDWR);
     f1e:	4589                	li	a1,2
     f20:	6788                	ld	a0,8(a5)
     f22:	00000097          	auipc	ra,0x0
     f26:	312080e7          	jalr	786(ra) # 1234 <open>
     f2a:	00001797          	auipc	a5,0x1
     f2e:	9ea7ab23          	sw	a0,-1546(a5) # 1920 <script_fd>
     f32:	bf5d                	j	ee8 <main+0x14>
    while(*p != '\0') {
     f34:	0485                	addi	s1,s1,1
     f36:	fff4c783          	lbu	a5,-1(s1)
     f3a:	cb99                	beqz	a5,f50 <main+0x7c>
      if(*p == ';') {
     f3c:	ff279ce3          	bne	a5,s2,f34 <main+0x60>
        *p = '\0';
     f40:	fe048fa3          	sb	zero,-1(s1)
        process_one_cmd(cmdstart);
     f44:	00000097          	auipc	ra,0x0
     f48:	ec8080e7          	jalr	-312(ra) # e0c <process_one_cmd>
        cmdstart = p+1;
     f4c:	8526                	mv	a0,s1
     f4e:	b7dd                	j	f34 <main+0x60>
    process_one_cmd(cmdstart);
     f50:	00000097          	auipc	ra,0x0
     f54:	ebc080e7          	jalr	-324(ra) # e0c <process_one_cmd>
  while(get_oneline_of_cmd(buf, sizeof(buf)) >= 0){
     f58:	06400593          	li	a1,100
     f5c:	854e                	mv	a0,s3
     f5e:	fffff097          	auipc	ra,0xfffff
     f62:	3a8080e7          	jalr	936(ra) # 306 <get_oneline_of_cmd>
     f66:	00054b63          	bltz	a0,f7c <main+0xa8>
    while(*p != '\0') {
     f6a:	0009c783          	lbu	a5,0(s3)
     f6e:	00001497          	auipc	s1,0x1
     f72:	9c348493          	addi	s1,s1,-1597 # 1931 <buf.0+0x1>
    char *cmdstart = buf; char *p = buf;
     f76:	854e                	mv	a0,s3
    while(*p != '\0') {
     f78:	f3f1                	bnez	a5,f3c <main+0x68>
     f7a:	bfd9                	j	f50 <main+0x7c>
  exit(0);
     f7c:	4501                	li	a0,0
     f7e:	00000097          	auipc	ra,0x0
     f82:	276080e7          	jalr	630(ra) # 11f4 <exit>

0000000000000f86 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     f86:	1141                	addi	sp,sp,-16
     f88:	e422                	sd	s0,8(sp)
     f8a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     f8c:	87aa                	mv	a5,a0
     f8e:	0585                	addi	a1,a1,1
     f90:	0785                	addi	a5,a5,1
     f92:	fff5c703          	lbu	a4,-1(a1)
     f96:	fee78fa3          	sb	a4,-1(a5)
     f9a:	fb75                	bnez	a4,f8e <strcpy+0x8>
    ;
  return os;
}
     f9c:	6422                	ld	s0,8(sp)
     f9e:	0141                	addi	sp,sp,16
     fa0:	8082                	ret

0000000000000fa2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     fa2:	1141                	addi	sp,sp,-16
     fa4:	e422                	sd	s0,8(sp)
     fa6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     fa8:	00054783          	lbu	a5,0(a0)
     fac:	cb91                	beqz	a5,fc0 <strcmp+0x1e>
     fae:	0005c703          	lbu	a4,0(a1)
     fb2:	00f71763          	bne	a4,a5,fc0 <strcmp+0x1e>
    p++, q++;
     fb6:	0505                	addi	a0,a0,1
     fb8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     fba:	00054783          	lbu	a5,0(a0)
     fbe:	fbe5                	bnez	a5,fae <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     fc0:	0005c503          	lbu	a0,0(a1)
}
     fc4:	40a7853b          	subw	a0,a5,a0
     fc8:	6422                	ld	s0,8(sp)
     fca:	0141                	addi	sp,sp,16
     fcc:	8082                	ret

0000000000000fce <strlen>:

uint
strlen(const char *s)
{
     fce:	1141                	addi	sp,sp,-16
     fd0:	e422                	sd	s0,8(sp)
     fd2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     fd4:	00054783          	lbu	a5,0(a0)
     fd8:	cf91                	beqz	a5,ff4 <strlen+0x26>
     fda:	0505                	addi	a0,a0,1
     fdc:	87aa                	mv	a5,a0
     fde:	4685                	li	a3,1
     fe0:	9e89                	subw	a3,a3,a0
     fe2:	00f6853b          	addw	a0,a3,a5
     fe6:	0785                	addi	a5,a5,1
     fe8:	fff7c703          	lbu	a4,-1(a5)
     fec:	fb7d                	bnez	a4,fe2 <strlen+0x14>
    ;
  return n;
}
     fee:	6422                	ld	s0,8(sp)
     ff0:	0141                	addi	sp,sp,16
     ff2:	8082                	ret
  for(n = 0; s[n]; n++)
     ff4:	4501                	li	a0,0
     ff6:	bfe5                	j	fee <strlen+0x20>

0000000000000ff8 <memset>:

void*
memset(void *dst, int c, uint n)
{
     ff8:	1141                	addi	sp,sp,-16
     ffa:	e422                	sd	s0,8(sp)
     ffc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     ffe:	ca19                	beqz	a2,1014 <memset+0x1c>
    1000:	87aa                	mv	a5,a0
    1002:	1602                	slli	a2,a2,0x20
    1004:	9201                	srli	a2,a2,0x20
    1006:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    100a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    100e:	0785                	addi	a5,a5,1
    1010:	fee79de3          	bne	a5,a4,100a <memset+0x12>
  }
  return dst;
}
    1014:	6422                	ld	s0,8(sp)
    1016:	0141                	addi	sp,sp,16
    1018:	8082                	ret

000000000000101a <strchr>:

char*
strchr(const char *s, char c)
{
    101a:	1141                	addi	sp,sp,-16
    101c:	e422                	sd	s0,8(sp)
    101e:	0800                	addi	s0,sp,16
  for(; *s; s++)
    1020:	00054783          	lbu	a5,0(a0)
    1024:	cb99                	beqz	a5,103a <strchr+0x20>
    if(*s == c)
    1026:	00f58763          	beq	a1,a5,1034 <strchr+0x1a>
  for(; *s; s++)
    102a:	0505                	addi	a0,a0,1
    102c:	00054783          	lbu	a5,0(a0)
    1030:	fbfd                	bnez	a5,1026 <strchr+0xc>
      return (char*)s;
  return 0;
    1032:	4501                	li	a0,0
}
    1034:	6422                	ld	s0,8(sp)
    1036:	0141                	addi	sp,sp,16
    1038:	8082                	ret
  return 0;
    103a:	4501                	li	a0,0
    103c:	bfe5                	j	1034 <strchr+0x1a>

000000000000103e <gets>:

char*
gets(char *buf, int max)
{
    103e:	711d                	addi	sp,sp,-96
    1040:	ec86                	sd	ra,88(sp)
    1042:	e8a2                	sd	s0,80(sp)
    1044:	e4a6                	sd	s1,72(sp)
    1046:	e0ca                	sd	s2,64(sp)
    1048:	fc4e                	sd	s3,56(sp)
    104a:	f852                	sd	s4,48(sp)
    104c:	f456                	sd	s5,40(sp)
    104e:	f05a                	sd	s6,32(sp)
    1050:	ec5e                	sd	s7,24(sp)
    1052:	1080                	addi	s0,sp,96
    1054:	8baa                	mv	s7,a0
    1056:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1058:	892a                	mv	s2,a0
    105a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    105c:	4aa9                	li	s5,10
    105e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    1060:	89a6                	mv	s3,s1
    1062:	2485                	addiw	s1,s1,1
    1064:	0344d863          	bge	s1,s4,1094 <gets+0x56>
    cc = read(0, &c, 1);
    1068:	4605                	li	a2,1
    106a:	faf40593          	addi	a1,s0,-81
    106e:	4501                	li	a0,0
    1070:	00000097          	auipc	ra,0x0
    1074:	19c080e7          	jalr	412(ra) # 120c <read>
    if(cc < 1)
    1078:	00a05e63          	blez	a0,1094 <gets+0x56>
    buf[i++] = c;
    107c:	faf44783          	lbu	a5,-81(s0)
    1080:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    1084:	01578763          	beq	a5,s5,1092 <gets+0x54>
    1088:	0905                	addi	s2,s2,1
    108a:	fd679be3          	bne	a5,s6,1060 <gets+0x22>
  for(i=0; i+1 < max; ){
    108e:	89a6                	mv	s3,s1
    1090:	a011                	j	1094 <gets+0x56>
    1092:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    1094:	99de                	add	s3,s3,s7
    1096:	00098023          	sb	zero,0(s3)
  return buf;
}
    109a:	855e                	mv	a0,s7
    109c:	60e6                	ld	ra,88(sp)
    109e:	6446                	ld	s0,80(sp)
    10a0:	64a6                	ld	s1,72(sp)
    10a2:	6906                	ld	s2,64(sp)
    10a4:	79e2                	ld	s3,56(sp)
    10a6:	7a42                	ld	s4,48(sp)
    10a8:	7aa2                	ld	s5,40(sp)
    10aa:	7b02                	ld	s6,32(sp)
    10ac:	6be2                	ld	s7,24(sp)
    10ae:	6125                	addi	sp,sp,96
    10b0:	8082                	ret

00000000000010b2 <stat>:

int
stat(const char *n, struct stat *st)
{
    10b2:	1101                	addi	sp,sp,-32
    10b4:	ec06                	sd	ra,24(sp)
    10b6:	e822                	sd	s0,16(sp)
    10b8:	e426                	sd	s1,8(sp)
    10ba:	e04a                	sd	s2,0(sp)
    10bc:	1000                	addi	s0,sp,32
    10be:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    10c0:	4581                	li	a1,0
    10c2:	00000097          	auipc	ra,0x0
    10c6:	172080e7          	jalr	370(ra) # 1234 <open>
  if(fd < 0)
    10ca:	02054563          	bltz	a0,10f4 <stat+0x42>
    10ce:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    10d0:	85ca                	mv	a1,s2
    10d2:	00000097          	auipc	ra,0x0
    10d6:	17a080e7          	jalr	378(ra) # 124c <fstat>
    10da:	892a                	mv	s2,a0
  close(fd);
    10dc:	8526                	mv	a0,s1
    10de:	00000097          	auipc	ra,0x0
    10e2:	13e080e7          	jalr	318(ra) # 121c <close>
  return r;
}
    10e6:	854a                	mv	a0,s2
    10e8:	60e2                	ld	ra,24(sp)
    10ea:	6442                	ld	s0,16(sp)
    10ec:	64a2                	ld	s1,8(sp)
    10ee:	6902                	ld	s2,0(sp)
    10f0:	6105                	addi	sp,sp,32
    10f2:	8082                	ret
    return -1;
    10f4:	597d                	li	s2,-1
    10f6:	bfc5                	j	10e6 <stat+0x34>

00000000000010f8 <atoi>:

int
atoi(const char *s)
{
    10f8:	1141                	addi	sp,sp,-16
    10fa:	e422                	sd	s0,8(sp)
    10fc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    10fe:	00054603          	lbu	a2,0(a0)
    1102:	fd06079b          	addiw	a5,a2,-48
    1106:	0ff7f793          	andi	a5,a5,255
    110a:	4725                	li	a4,9
    110c:	02f76963          	bltu	a4,a5,113e <atoi+0x46>
    1110:	86aa                	mv	a3,a0
  n = 0;
    1112:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    1114:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    1116:	0685                	addi	a3,a3,1
    1118:	0025179b          	slliw	a5,a0,0x2
    111c:	9fa9                	addw	a5,a5,a0
    111e:	0017979b          	slliw	a5,a5,0x1
    1122:	9fb1                	addw	a5,a5,a2
    1124:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    1128:	0006c603          	lbu	a2,0(a3)
    112c:	fd06071b          	addiw	a4,a2,-48
    1130:	0ff77713          	andi	a4,a4,255
    1134:	fee5f1e3          	bgeu	a1,a4,1116 <atoi+0x1e>
  return n;
}
    1138:	6422                	ld	s0,8(sp)
    113a:	0141                	addi	sp,sp,16
    113c:	8082                	ret
  n = 0;
    113e:	4501                	li	a0,0
    1140:	bfe5                	j	1138 <atoi+0x40>

0000000000001142 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    1142:	1141                	addi	sp,sp,-16
    1144:	e422                	sd	s0,8(sp)
    1146:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    1148:	02b57463          	bgeu	a0,a1,1170 <memmove+0x2e>
    while(n-- > 0)
    114c:	00c05f63          	blez	a2,116a <memmove+0x28>
    1150:	1602                	slli	a2,a2,0x20
    1152:	9201                	srli	a2,a2,0x20
    1154:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    1158:	872a                	mv	a4,a0
      *dst++ = *src++;
    115a:	0585                	addi	a1,a1,1
    115c:	0705                	addi	a4,a4,1
    115e:	fff5c683          	lbu	a3,-1(a1)
    1162:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    1166:	fee79ae3          	bne	a5,a4,115a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    116a:	6422                	ld	s0,8(sp)
    116c:	0141                	addi	sp,sp,16
    116e:	8082                	ret
    dst += n;
    1170:	00c50733          	add	a4,a0,a2
    src += n;
    1174:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    1176:	fec05ae3          	blez	a2,116a <memmove+0x28>
    117a:	fff6079b          	addiw	a5,a2,-1
    117e:	1782                	slli	a5,a5,0x20
    1180:	9381                	srli	a5,a5,0x20
    1182:	fff7c793          	not	a5,a5
    1186:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    1188:	15fd                	addi	a1,a1,-1
    118a:	177d                	addi	a4,a4,-1
    118c:	0005c683          	lbu	a3,0(a1)
    1190:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    1194:	fee79ae3          	bne	a5,a4,1188 <memmove+0x46>
    1198:	bfc9                	j	116a <memmove+0x28>

000000000000119a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    119a:	1141                	addi	sp,sp,-16
    119c:	e422                	sd	s0,8(sp)
    119e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    11a0:	ca05                	beqz	a2,11d0 <memcmp+0x36>
    11a2:	fff6069b          	addiw	a3,a2,-1
    11a6:	1682                	slli	a3,a3,0x20
    11a8:	9281                	srli	a3,a3,0x20
    11aa:	0685                	addi	a3,a3,1
    11ac:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    11ae:	00054783          	lbu	a5,0(a0)
    11b2:	0005c703          	lbu	a4,0(a1)
    11b6:	00e79863          	bne	a5,a4,11c6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    11ba:	0505                	addi	a0,a0,1
    p2++;
    11bc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    11be:	fed518e3          	bne	a0,a3,11ae <memcmp+0x14>
  }
  return 0;
    11c2:	4501                	li	a0,0
    11c4:	a019                	j	11ca <memcmp+0x30>
      return *p1 - *p2;
    11c6:	40e7853b          	subw	a0,a5,a4
}
    11ca:	6422                	ld	s0,8(sp)
    11cc:	0141                	addi	sp,sp,16
    11ce:	8082                	ret
  return 0;
    11d0:	4501                	li	a0,0
    11d2:	bfe5                	j	11ca <memcmp+0x30>

00000000000011d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    11d4:	1141                	addi	sp,sp,-16
    11d6:	e406                	sd	ra,8(sp)
    11d8:	e022                	sd	s0,0(sp)
    11da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    11dc:	00000097          	auipc	ra,0x0
    11e0:	f66080e7          	jalr	-154(ra) # 1142 <memmove>
}
    11e4:	60a2                	ld	ra,8(sp)
    11e6:	6402                	ld	s0,0(sp)
    11e8:	0141                	addi	sp,sp,16
    11ea:	8082                	ret

00000000000011ec <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    11ec:	4885                	li	a7,1
 ecall
    11ee:	00000073          	ecall
 ret
    11f2:	8082                	ret

00000000000011f4 <exit>:
.global exit
exit:
 li a7, SYS_exit
    11f4:	4889                	li	a7,2
 ecall
    11f6:	00000073          	ecall
 ret
    11fa:	8082                	ret

00000000000011fc <wait>:
.global wait
wait:
 li a7, SYS_wait
    11fc:	488d                	li	a7,3
 ecall
    11fe:	00000073          	ecall
 ret
    1202:	8082                	ret

0000000000001204 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    1204:	4891                	li	a7,4
 ecall
    1206:	00000073          	ecall
 ret
    120a:	8082                	ret

000000000000120c <read>:
.global read
read:
 li a7, SYS_read
    120c:	4895                	li	a7,5
 ecall
    120e:	00000073          	ecall
 ret
    1212:	8082                	ret

0000000000001214 <write>:
.global write
write:
 li a7, SYS_write
    1214:	48c1                	li	a7,16
 ecall
    1216:	00000073          	ecall
 ret
    121a:	8082                	ret

000000000000121c <close>:
.global close
close:
 li a7, SYS_close
    121c:	48d5                	li	a7,21
 ecall
    121e:	00000073          	ecall
 ret
    1222:	8082                	ret

0000000000001224 <kill>:
.global kill
kill:
 li a7, SYS_kill
    1224:	4899                	li	a7,6
 ecall
    1226:	00000073          	ecall
 ret
    122a:	8082                	ret

000000000000122c <exec>:
.global exec
exec:
 li a7, SYS_exec
    122c:	489d                	li	a7,7
 ecall
    122e:	00000073          	ecall
 ret
    1232:	8082                	ret

0000000000001234 <open>:
.global open
open:
 li a7, SYS_open
    1234:	48bd                	li	a7,15
 ecall
    1236:	00000073          	ecall
 ret
    123a:	8082                	ret

000000000000123c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    123c:	48c5                	li	a7,17
 ecall
    123e:	00000073          	ecall
 ret
    1242:	8082                	ret

0000000000001244 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    1244:	48c9                	li	a7,18
 ecall
    1246:	00000073          	ecall
 ret
    124a:	8082                	ret

000000000000124c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    124c:	48a1                	li	a7,8
 ecall
    124e:	00000073          	ecall
 ret
    1252:	8082                	ret

0000000000001254 <link>:
.global link
link:
 li a7, SYS_link
    1254:	48cd                	li	a7,19
 ecall
    1256:	00000073          	ecall
 ret
    125a:	8082                	ret

000000000000125c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    125c:	48d1                	li	a7,20
 ecall
    125e:	00000073          	ecall
 ret
    1262:	8082                	ret

0000000000001264 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    1264:	48a5                	li	a7,9
 ecall
    1266:	00000073          	ecall
 ret
    126a:	8082                	ret

000000000000126c <dup>:
.global dup
dup:
 li a7, SYS_dup
    126c:	48a9                	li	a7,10
 ecall
    126e:	00000073          	ecall
 ret
    1272:	8082                	ret

0000000000001274 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    1274:	48ad                	li	a7,11
 ecall
    1276:	00000073          	ecall
 ret
    127a:	8082                	ret

000000000000127c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    127c:	48b1                	li	a7,12
 ecall
    127e:	00000073          	ecall
 ret
    1282:	8082                	ret

0000000000001284 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    1284:	48b5                	li	a7,13
 ecall
    1286:	00000073          	ecall
 ret
    128a:	8082                	ret

000000000000128c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    128c:	48b9                	li	a7,14
 ecall
    128e:	00000073          	ecall
 ret
    1292:	8082                	ret

0000000000001294 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    1294:	1101                	addi	sp,sp,-32
    1296:	ec06                	sd	ra,24(sp)
    1298:	e822                	sd	s0,16(sp)
    129a:	1000                	addi	s0,sp,32
    129c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    12a0:	4605                	li	a2,1
    12a2:	fef40593          	addi	a1,s0,-17
    12a6:	00000097          	auipc	ra,0x0
    12aa:	f6e080e7          	jalr	-146(ra) # 1214 <write>
}
    12ae:	60e2                	ld	ra,24(sp)
    12b0:	6442                	ld	s0,16(sp)
    12b2:	6105                	addi	sp,sp,32
    12b4:	8082                	ret

00000000000012b6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    12b6:	7139                	addi	sp,sp,-64
    12b8:	fc06                	sd	ra,56(sp)
    12ba:	f822                	sd	s0,48(sp)
    12bc:	f426                	sd	s1,40(sp)
    12be:	f04a                	sd	s2,32(sp)
    12c0:	ec4e                	sd	s3,24(sp)
    12c2:	0080                	addi	s0,sp,64
    12c4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    12c6:	c299                	beqz	a3,12cc <printint+0x16>
    12c8:	0805c863          	bltz	a1,1358 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    12cc:	2581                	sext.w	a1,a1
  neg = 0;
    12ce:	4881                	li	a7,0
    12d0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    12d4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    12d6:	2601                	sext.w	a2,a2
    12d8:	00000517          	auipc	a0,0x0
    12dc:	61850513          	addi	a0,a0,1560 # 18f0 <digits>
    12e0:	883a                	mv	a6,a4
    12e2:	2705                	addiw	a4,a4,1
    12e4:	02c5f7bb          	remuw	a5,a1,a2
    12e8:	1782                	slli	a5,a5,0x20
    12ea:	9381                	srli	a5,a5,0x20
    12ec:	97aa                	add	a5,a5,a0
    12ee:	0007c783          	lbu	a5,0(a5)
    12f2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    12f6:	0005879b          	sext.w	a5,a1
    12fa:	02c5d5bb          	divuw	a1,a1,a2
    12fe:	0685                	addi	a3,a3,1
    1300:	fec7f0e3          	bgeu	a5,a2,12e0 <printint+0x2a>
  if(neg)
    1304:	00088b63          	beqz	a7,131a <printint+0x64>
    buf[i++] = '-';
    1308:	fd040793          	addi	a5,s0,-48
    130c:	973e                	add	a4,a4,a5
    130e:	02d00793          	li	a5,45
    1312:	fef70823          	sb	a5,-16(a4)
    1316:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    131a:	02e05863          	blez	a4,134a <printint+0x94>
    131e:	fc040793          	addi	a5,s0,-64
    1322:	00e78933          	add	s2,a5,a4
    1326:	fff78993          	addi	s3,a5,-1
    132a:	99ba                	add	s3,s3,a4
    132c:	377d                	addiw	a4,a4,-1
    132e:	1702                	slli	a4,a4,0x20
    1330:	9301                	srli	a4,a4,0x20
    1332:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1336:	fff94583          	lbu	a1,-1(s2)
    133a:	8526                	mv	a0,s1
    133c:	00000097          	auipc	ra,0x0
    1340:	f58080e7          	jalr	-168(ra) # 1294 <putc>
  while(--i >= 0)
    1344:	197d                	addi	s2,s2,-1
    1346:	ff3918e3          	bne	s2,s3,1336 <printint+0x80>
}
    134a:	70e2                	ld	ra,56(sp)
    134c:	7442                	ld	s0,48(sp)
    134e:	74a2                	ld	s1,40(sp)
    1350:	7902                	ld	s2,32(sp)
    1352:	69e2                	ld	s3,24(sp)
    1354:	6121                	addi	sp,sp,64
    1356:	8082                	ret
    x = -xx;
    1358:	40b005bb          	negw	a1,a1
    neg = 1;
    135c:	4885                	li	a7,1
    x = -xx;
    135e:	bf8d                	j	12d0 <printint+0x1a>

0000000000001360 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1360:	7119                	addi	sp,sp,-128
    1362:	fc86                	sd	ra,120(sp)
    1364:	f8a2                	sd	s0,112(sp)
    1366:	f4a6                	sd	s1,104(sp)
    1368:	f0ca                	sd	s2,96(sp)
    136a:	ecce                	sd	s3,88(sp)
    136c:	e8d2                	sd	s4,80(sp)
    136e:	e4d6                	sd	s5,72(sp)
    1370:	e0da                	sd	s6,64(sp)
    1372:	fc5e                	sd	s7,56(sp)
    1374:	f862                	sd	s8,48(sp)
    1376:	f466                	sd	s9,40(sp)
    1378:	f06a                	sd	s10,32(sp)
    137a:	ec6e                	sd	s11,24(sp)
    137c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    137e:	0005c903          	lbu	s2,0(a1)
    1382:	18090f63          	beqz	s2,1520 <vprintf+0x1c0>
    1386:	8aaa                	mv	s5,a0
    1388:	8b32                	mv	s6,a2
    138a:	00158493          	addi	s1,a1,1
  state = 0;
    138e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1390:	02500a13          	li	s4,37
      if(c == 'd'){
    1394:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1398:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    139c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    13a0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    13a4:	00000b97          	auipc	s7,0x0
    13a8:	54cb8b93          	addi	s7,s7,1356 # 18f0 <digits>
    13ac:	a839                	j	13ca <vprintf+0x6a>
        putc(fd, c);
    13ae:	85ca                	mv	a1,s2
    13b0:	8556                	mv	a0,s5
    13b2:	00000097          	auipc	ra,0x0
    13b6:	ee2080e7          	jalr	-286(ra) # 1294 <putc>
    13ba:	a019                	j	13c0 <vprintf+0x60>
    } else if(state == '%'){
    13bc:	01498f63          	beq	s3,s4,13da <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    13c0:	0485                	addi	s1,s1,1
    13c2:	fff4c903          	lbu	s2,-1(s1)
    13c6:	14090d63          	beqz	s2,1520 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    13ca:	0009079b          	sext.w	a5,s2
    if(state == 0){
    13ce:	fe0997e3          	bnez	s3,13bc <vprintf+0x5c>
      if(c == '%'){
    13d2:	fd479ee3          	bne	a5,s4,13ae <vprintf+0x4e>
        state = '%';
    13d6:	89be                	mv	s3,a5
    13d8:	b7e5                	j	13c0 <vprintf+0x60>
      if(c == 'd'){
    13da:	05878063          	beq	a5,s8,141a <vprintf+0xba>
      } else if(c == 'l') {
    13de:	05978c63          	beq	a5,s9,1436 <vprintf+0xd6>
      } else if(c == 'x') {
    13e2:	07a78863          	beq	a5,s10,1452 <vprintf+0xf2>
      } else if(c == 'p') {
    13e6:	09b78463          	beq	a5,s11,146e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    13ea:	07300713          	li	a4,115
    13ee:	0ce78663          	beq	a5,a4,14ba <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    13f2:	06300713          	li	a4,99
    13f6:	0ee78e63          	beq	a5,a4,14f2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    13fa:	11478863          	beq	a5,s4,150a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    13fe:	85d2                	mv	a1,s4
    1400:	8556                	mv	a0,s5
    1402:	00000097          	auipc	ra,0x0
    1406:	e92080e7          	jalr	-366(ra) # 1294 <putc>
        putc(fd, c);
    140a:	85ca                	mv	a1,s2
    140c:	8556                	mv	a0,s5
    140e:	00000097          	auipc	ra,0x0
    1412:	e86080e7          	jalr	-378(ra) # 1294 <putc>
      }
      state = 0;
    1416:	4981                	li	s3,0
    1418:	b765                	j	13c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    141a:	008b0913          	addi	s2,s6,8
    141e:	4685                	li	a3,1
    1420:	4629                	li	a2,10
    1422:	000b2583          	lw	a1,0(s6)
    1426:	8556                	mv	a0,s5
    1428:	00000097          	auipc	ra,0x0
    142c:	e8e080e7          	jalr	-370(ra) # 12b6 <printint>
    1430:	8b4a                	mv	s6,s2
      state = 0;
    1432:	4981                	li	s3,0
    1434:	b771                	j	13c0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1436:	008b0913          	addi	s2,s6,8
    143a:	4681                	li	a3,0
    143c:	4629                	li	a2,10
    143e:	000b2583          	lw	a1,0(s6)
    1442:	8556                	mv	a0,s5
    1444:	00000097          	auipc	ra,0x0
    1448:	e72080e7          	jalr	-398(ra) # 12b6 <printint>
    144c:	8b4a                	mv	s6,s2
      state = 0;
    144e:	4981                	li	s3,0
    1450:	bf85                	j	13c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1452:	008b0913          	addi	s2,s6,8
    1456:	4681                	li	a3,0
    1458:	4641                	li	a2,16
    145a:	000b2583          	lw	a1,0(s6)
    145e:	8556                	mv	a0,s5
    1460:	00000097          	auipc	ra,0x0
    1464:	e56080e7          	jalr	-426(ra) # 12b6 <printint>
    1468:	8b4a                	mv	s6,s2
      state = 0;
    146a:	4981                	li	s3,0
    146c:	bf91                	j	13c0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    146e:	008b0793          	addi	a5,s6,8
    1472:	f8f43423          	sd	a5,-120(s0)
    1476:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    147a:	03000593          	li	a1,48
    147e:	8556                	mv	a0,s5
    1480:	00000097          	auipc	ra,0x0
    1484:	e14080e7          	jalr	-492(ra) # 1294 <putc>
  putc(fd, 'x');
    1488:	85ea                	mv	a1,s10
    148a:	8556                	mv	a0,s5
    148c:	00000097          	auipc	ra,0x0
    1490:	e08080e7          	jalr	-504(ra) # 1294 <putc>
    1494:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1496:	03c9d793          	srli	a5,s3,0x3c
    149a:	97de                	add	a5,a5,s7
    149c:	0007c583          	lbu	a1,0(a5)
    14a0:	8556                	mv	a0,s5
    14a2:	00000097          	auipc	ra,0x0
    14a6:	df2080e7          	jalr	-526(ra) # 1294 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    14aa:	0992                	slli	s3,s3,0x4
    14ac:	397d                	addiw	s2,s2,-1
    14ae:	fe0914e3          	bnez	s2,1496 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    14b2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    14b6:	4981                	li	s3,0
    14b8:	b721                	j	13c0 <vprintf+0x60>
        s = va_arg(ap, char*);
    14ba:	008b0993          	addi	s3,s6,8
    14be:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    14c2:	02090163          	beqz	s2,14e4 <vprintf+0x184>
        while(*s != 0){
    14c6:	00094583          	lbu	a1,0(s2)
    14ca:	c9a1                	beqz	a1,151a <vprintf+0x1ba>
          putc(fd, *s);
    14cc:	8556                	mv	a0,s5
    14ce:	00000097          	auipc	ra,0x0
    14d2:	dc6080e7          	jalr	-570(ra) # 1294 <putc>
          s++;
    14d6:	0905                	addi	s2,s2,1
        while(*s != 0){
    14d8:	00094583          	lbu	a1,0(s2)
    14dc:	f9e5                	bnez	a1,14cc <vprintf+0x16c>
        s = va_arg(ap, char*);
    14de:	8b4e                	mv	s6,s3
      state = 0;
    14e0:	4981                	li	s3,0
    14e2:	bdf9                	j	13c0 <vprintf+0x60>
          s = "(null)";
    14e4:	00000917          	auipc	s2,0x0
    14e8:	40490913          	addi	s2,s2,1028 # 18e8 <malloc+0x2be>
        while(*s != 0){
    14ec:	02800593          	li	a1,40
    14f0:	bff1                	j	14cc <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    14f2:	008b0913          	addi	s2,s6,8
    14f6:	000b4583          	lbu	a1,0(s6)
    14fa:	8556                	mv	a0,s5
    14fc:	00000097          	auipc	ra,0x0
    1500:	d98080e7          	jalr	-616(ra) # 1294 <putc>
    1504:	8b4a                	mv	s6,s2
      state = 0;
    1506:	4981                	li	s3,0
    1508:	bd65                	j	13c0 <vprintf+0x60>
        putc(fd, c);
    150a:	85d2                	mv	a1,s4
    150c:	8556                	mv	a0,s5
    150e:	00000097          	auipc	ra,0x0
    1512:	d86080e7          	jalr	-634(ra) # 1294 <putc>
      state = 0;
    1516:	4981                	li	s3,0
    1518:	b565                	j	13c0 <vprintf+0x60>
        s = va_arg(ap, char*);
    151a:	8b4e                	mv	s6,s3
      state = 0;
    151c:	4981                	li	s3,0
    151e:	b54d                	j	13c0 <vprintf+0x60>
    }
  }
}
    1520:	70e6                	ld	ra,120(sp)
    1522:	7446                	ld	s0,112(sp)
    1524:	74a6                	ld	s1,104(sp)
    1526:	7906                	ld	s2,96(sp)
    1528:	69e6                	ld	s3,88(sp)
    152a:	6a46                	ld	s4,80(sp)
    152c:	6aa6                	ld	s5,72(sp)
    152e:	6b06                	ld	s6,64(sp)
    1530:	7be2                	ld	s7,56(sp)
    1532:	7c42                	ld	s8,48(sp)
    1534:	7ca2                	ld	s9,40(sp)
    1536:	7d02                	ld	s10,32(sp)
    1538:	6de2                	ld	s11,24(sp)
    153a:	6109                	addi	sp,sp,128
    153c:	8082                	ret

000000000000153e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    153e:	715d                	addi	sp,sp,-80
    1540:	ec06                	sd	ra,24(sp)
    1542:	e822                	sd	s0,16(sp)
    1544:	1000                	addi	s0,sp,32
    1546:	e010                	sd	a2,0(s0)
    1548:	e414                	sd	a3,8(s0)
    154a:	e818                	sd	a4,16(s0)
    154c:	ec1c                	sd	a5,24(s0)
    154e:	03043023          	sd	a6,32(s0)
    1552:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1556:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    155a:	8622                	mv	a2,s0
    155c:	00000097          	auipc	ra,0x0
    1560:	e04080e7          	jalr	-508(ra) # 1360 <vprintf>
}
    1564:	60e2                	ld	ra,24(sp)
    1566:	6442                	ld	s0,16(sp)
    1568:	6161                	addi	sp,sp,80
    156a:	8082                	ret

000000000000156c <printf>:

void
printf(const char *fmt, ...)
{
    156c:	711d                	addi	sp,sp,-96
    156e:	ec06                	sd	ra,24(sp)
    1570:	e822                	sd	s0,16(sp)
    1572:	1000                	addi	s0,sp,32
    1574:	e40c                	sd	a1,8(s0)
    1576:	e810                	sd	a2,16(s0)
    1578:	ec14                	sd	a3,24(s0)
    157a:	f018                	sd	a4,32(s0)
    157c:	f41c                	sd	a5,40(s0)
    157e:	03043823          	sd	a6,48(s0)
    1582:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1586:	00840613          	addi	a2,s0,8
    158a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    158e:	85aa                	mv	a1,a0
    1590:	4505                	li	a0,1
    1592:	00000097          	auipc	ra,0x0
    1596:	dce080e7          	jalr	-562(ra) # 1360 <vprintf>
}
    159a:	60e2                	ld	ra,24(sp)
    159c:	6442                	ld	s0,16(sp)
    159e:	6125                	addi	sp,sp,96
    15a0:	8082                	ret

00000000000015a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    15a2:	1141                	addi	sp,sp,-16
    15a4:	e422                	sd	s0,8(sp)
    15a6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    15a8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15ac:	00000797          	auipc	a5,0x0
    15b0:	37c7b783          	ld	a5,892(a5) # 1928 <freep>
    15b4:	a805                	j	15e4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    15b6:	4618                	lw	a4,8(a2)
    15b8:	9db9                	addw	a1,a1,a4
    15ba:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    15be:	6398                	ld	a4,0(a5)
    15c0:	6318                	ld	a4,0(a4)
    15c2:	fee53823          	sd	a4,-16(a0)
    15c6:	a091                	j	160a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    15c8:	ff852703          	lw	a4,-8(a0)
    15cc:	9e39                	addw	a2,a2,a4
    15ce:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    15d0:	ff053703          	ld	a4,-16(a0)
    15d4:	e398                	sd	a4,0(a5)
    15d6:	a099                	j	161c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15d8:	6398                	ld	a4,0(a5)
    15da:	00e7e463          	bltu	a5,a4,15e2 <free+0x40>
    15de:	00e6ea63          	bltu	a3,a4,15f2 <free+0x50>
{
    15e2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    15e4:	fed7fae3          	bgeu	a5,a3,15d8 <free+0x36>
    15e8:	6398                	ld	a4,0(a5)
    15ea:	00e6e463          	bltu	a3,a4,15f2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    15ee:	fee7eae3          	bltu	a5,a4,15e2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    15f2:	ff852583          	lw	a1,-8(a0)
    15f6:	6390                	ld	a2,0(a5)
    15f8:	02059713          	slli	a4,a1,0x20
    15fc:	9301                	srli	a4,a4,0x20
    15fe:	0712                	slli	a4,a4,0x4
    1600:	9736                	add	a4,a4,a3
    1602:	fae60ae3          	beq	a2,a4,15b6 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1606:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    160a:	4790                	lw	a2,8(a5)
    160c:	02061713          	slli	a4,a2,0x20
    1610:	9301                	srli	a4,a4,0x20
    1612:	0712                	slli	a4,a4,0x4
    1614:	973e                	add	a4,a4,a5
    1616:	fae689e3          	beq	a3,a4,15c8 <free+0x26>
  } else
    p->s.ptr = bp;
    161a:	e394                	sd	a3,0(a5)
  freep = p;
    161c:	00000717          	auipc	a4,0x0
    1620:	30f73623          	sd	a5,780(a4) # 1928 <freep>
}
    1624:	6422                	ld	s0,8(sp)
    1626:	0141                	addi	sp,sp,16
    1628:	8082                	ret

000000000000162a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    162a:	7139                	addi	sp,sp,-64
    162c:	fc06                	sd	ra,56(sp)
    162e:	f822                	sd	s0,48(sp)
    1630:	f426                	sd	s1,40(sp)
    1632:	f04a                	sd	s2,32(sp)
    1634:	ec4e                	sd	s3,24(sp)
    1636:	e852                	sd	s4,16(sp)
    1638:	e456                	sd	s5,8(sp)
    163a:	e05a                	sd	s6,0(sp)
    163c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    163e:	02051493          	slli	s1,a0,0x20
    1642:	9081                	srli	s1,s1,0x20
    1644:	04bd                	addi	s1,s1,15
    1646:	8091                	srli	s1,s1,0x4
    1648:	0014899b          	addiw	s3,s1,1
    164c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    164e:	00000517          	auipc	a0,0x0
    1652:	2da53503          	ld	a0,730(a0) # 1928 <freep>
    1656:	c515                	beqz	a0,1682 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1658:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    165a:	4798                	lw	a4,8(a5)
    165c:	02977f63          	bgeu	a4,s1,169a <malloc+0x70>
    1660:	8a4e                	mv	s4,s3
    1662:	0009871b          	sext.w	a4,s3
    1666:	6685                	lui	a3,0x1
    1668:	00d77363          	bgeu	a4,a3,166e <malloc+0x44>
    166c:	6a05                	lui	s4,0x1
    166e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1672:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1676:	00000917          	auipc	s2,0x0
    167a:	2b290913          	addi	s2,s2,690 # 1928 <freep>
  if(p == (char*)-1)
    167e:	5afd                	li	s5,-1
    1680:	a88d                	j	16f2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    1682:	00000797          	auipc	a5,0x0
    1686:	31678793          	addi	a5,a5,790 # 1998 <base>
    168a:	00000717          	auipc	a4,0x0
    168e:	28f73f23          	sd	a5,670(a4) # 1928 <freep>
    1692:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1694:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1698:	b7e1                	j	1660 <malloc+0x36>
      if(p->s.size == nunits)
    169a:	02e48b63          	beq	s1,a4,16d0 <malloc+0xa6>
        p->s.size -= nunits;
    169e:	4137073b          	subw	a4,a4,s3
    16a2:	c798                	sw	a4,8(a5)
        p += p->s.size;
    16a4:	1702                	slli	a4,a4,0x20
    16a6:	9301                	srli	a4,a4,0x20
    16a8:	0712                	slli	a4,a4,0x4
    16aa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    16ac:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    16b0:	00000717          	auipc	a4,0x0
    16b4:	26a73c23          	sd	a0,632(a4) # 1928 <freep>
      return (void*)(p + 1);
    16b8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    16bc:	70e2                	ld	ra,56(sp)
    16be:	7442                	ld	s0,48(sp)
    16c0:	74a2                	ld	s1,40(sp)
    16c2:	7902                	ld	s2,32(sp)
    16c4:	69e2                	ld	s3,24(sp)
    16c6:	6a42                	ld	s4,16(sp)
    16c8:	6aa2                	ld	s5,8(sp)
    16ca:	6b02                	ld	s6,0(sp)
    16cc:	6121                	addi	sp,sp,64
    16ce:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    16d0:	6398                	ld	a4,0(a5)
    16d2:	e118                	sd	a4,0(a0)
    16d4:	bff1                	j	16b0 <malloc+0x86>
  hp->s.size = nu;
    16d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    16da:	0541                	addi	a0,a0,16
    16dc:	00000097          	auipc	ra,0x0
    16e0:	ec6080e7          	jalr	-314(ra) # 15a2 <free>
  return freep;
    16e4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    16e8:	d971                	beqz	a0,16bc <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    16ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    16ec:	4798                	lw	a4,8(a5)
    16ee:	fa9776e3          	bgeu	a4,s1,169a <malloc+0x70>
    if(p == freep)
    16f2:	00093703          	ld	a4,0(s2)
    16f6:	853e                	mv	a0,a5
    16f8:	fef719e3          	bne	a4,a5,16ea <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    16fc:	8552                	mv	a0,s4
    16fe:	00000097          	auipc	ra,0x0
    1702:	b7e080e7          	jalr	-1154(ra) # 127c <sbrk>
  if(p == (char*)-1)
    1706:	fd5518e3          	bne	a0,s5,16d6 <malloc+0xac>
        return 0;
    170a:	4501                	li	a0,0
    170c:	bf45                	j	16bc <malloc+0x92>
