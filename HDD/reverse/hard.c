#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define	gotoyx(y,x)	printf("\033[%d;%df",y,x)
#define	vall(a)		itm[a].val
#define	E1		01000000L

//#define	hdcsr	(*(unsigned int*)0177130)
//#define	bhdcsr	(*(char *)0177130)

#include <termios.h>
#include <unistd.h>

int mygetch( ) {
struct termios oldt,
newt;
int ch;
tcgetattr( STDIN_FILENO, &oldt );
newt = oldt;
newt.c_lflag &= ~( ICANON | ECHO );
tcsetattr( STDIN_FILENO, TCSANOW, &newt );
ch = getchar();
tcsetattr( STDIN_FILENO, TCSANOW, &oldt );
return ch;
}

#define _puts(s) printf("%s", s);
#define _getchar mygetch
#define ttymode
#define msg(m) printf("%s", m);
#define swabi(x)  __builtin_bswap16(x)
#define fgetss fgets

void err(char * mesg);
void sspace(FILE * ff);
int menu(const char *mfile);
uint32_t comp(int i);


// номер 1─го цилиндра, принадлежащего диску + статус диска
struct	cbf {           
	int16_t	cb : 11; // номер 1─го цилиндра, принадлежащего диску
	int16_t	wb : 1; // признак диска с ОС (Warm─Boot)
	int16_t	nb : 1; // признак диска с ОС (Сold─Boot)
	int16_t	rw : 1; // признак разрешения доступа только по чтению
	int16_t	on : 1; // признак разрешения доступа к диску
	int16_t	sp : 1; // признак нулевого диска
};

// Для каждого из восьми  логических  дисков
struct partit {
	struct	cbf cb;  // номер 1─го цилиндра, принадлежащего диску + статус диска
	int16_t	cn;      // число цилиндров, принадлежащих диску
	int16_t	hb;      // номер первой головки
	int16_t	hn;      // количество головок
	int16_t	sb;      // номер первого сектора
	int16_t	sn;      // количество секторов
	int16_t	rll,rlh; // абсолютный номер 1─го сектора, принадлежащего диску
	int16_t	szl,szh; // емкость диска в секторах
};

uint16_t * ppp;

#define	EMPT		0520
struct {
    char	empty[EMPT];
    uint16_t	sec;          // количество секторов на дорожке
    uint16_t	head;         // количество головок
    uint16_t	track;        // количество цилиндров
    uint16_t	sizel,sizeh;  // емкость накопителя в секторах (блоках)
    uint16_t	pcm;
    uint16_t	gap3;
    struct partit 	prt[8];
    uint16_t	sign;
} partbl = { .sign=0123456 };

struct que {
	int16_t		blk;
	char		fun,dev;
	uint16_t	*buf;
	int16_t		cntw;
} qq;

char
	home[]="\033[1;1f",
	eras[]="\033[2J",
	erasl[]="\033[2K",
	curs[]="\033W",
	msg0[]="Error open menu file",
	msg1[]="Error menu file  format",
	msg2[]="Error: invallid item type",
	msg3[]="Error: invalid key",
	wm1[] ="Warning: sum of partition's size's exceed total",
	wm2[] ="Warning: invalid parameter in partition #";

#define	SPACE	1
#define	UP	2
#define	DO	3
#define	LE	4
#define	RI	5
#define	DIGIT	6
#define	LETTER	7
#define	DEL	8
#define	ESC	9
#define	FMT	10
#define	UPD	11
#define	WRITE	12
#define	SIZE	13
#define	VERIFY	14
#define	GET	15
#define	HELP	16
#define	ILL	17
#define	QUIT	0

char	ctype[128] = {
	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,
	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,
	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,
	ILL,	ILL,	ILL,	ESC,	ILL,	ILL,	ILL,	ILL,
	SPACE,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,
	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,
	DIGIT,	DIGIT,	DIGIT,	DIGIT,	DIGIT,	DIGIT,	DIGIT,	DIGIT,
	DIGIT,	DIGIT,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,

	ILL,	UP,	DO,	RI,	LE,	ILL,	FMT,	GET,
	HELP,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,
	ILL,	QUIT,	ILL,	SIZE,	ILL,	UPD,	VERIFY,	WRITE,
	ILL,	ILL,	ILL,	ESC,	ILL,	ILL,	ILL,	ILL,
	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	FMT,	GET,
	HELP,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,
	ILL,	QUIT,	ILL,	SIZE,	ILL,	UPD,	VERIFY,	WRITE,
	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	ILL,	DEL
};

char	inter[32*2]; // Разметка секторов (номер и признак bad)

struct item {
	int16_t	lin;
	int16_t	col;
	int16_t	wid;
	int16_t	typ;
	int32_t	val;
} itm[102];

int	vect[9*12];
int	y=9, x=12, cnt=102;


int main()
{
	int	a;
//	freopen("tt:","wwu",stdout);
	menu("hard.mnu");
/*	putchar(a); */
	return 0;
}

void err(char * mesg)
{
	msg(mesg);
	exit(0);
}

void sspace(FILE * ff)
{
	register a;
	while ((a=getc(ff)) == ' ');
	ungetc(a,ff);
}

int menu(const char * mfile)
{
	FILE * 	inf;
	char   	line[500];
	register i,j;
	int	k,tmp,fl=0;

	if ((inf=fopen(mfile,"r")) == NULL ) err(msg0);

	_puts(home); _puts(eras);
	_puts(curs);
	ttymode(1);

/*	Display text */
	fgetss(line,500,inf);
	do {
		msg(line);
		if (fgetss(line,500,inf) == 0) break;
	} while (line[0] != '%');
	if (line[0] != '%') err(msg1);

/*	Now read item's */
	for(i=0; i < cnt; i++) {
		fscanf(inf,"%d",&itm[i].lin);
		fscanf(inf,"%d",&itm[i].col);
		fscanf(inf,"%d",&itm[i].wid);
		sspace(inf); /* skip space's */
		itm[i].typ=tmp=getc(inf);
		switch(tmp){
				break;
		 case 'L':
		 case 'I':	fscanf(inf,"%ld",&itm[i].val);
				break;
		 case 'C':	sspace(inf);
				tmp=itm[i].val=getc(inf);
				break;
		 default:	err(msg2);
		}
	} /* for */
	
	fgetss(line,500,inf);
	fgetss(line,500,inf);

	if (line[0] != '$') err(msg1);

	for(i=0; i< x*y; i++) {
		fscanf(inf,"%d",&tmp);
		vect[i]= tmp-1;
	}

	get();
	if (partbl.sign == 0123456) unpack();		/* get part info */

	displ();

#if 1
	usize();
	help();
#endif

	pitm(0,1);
	i=0;
	while(ctype[tmp=_getchar()]) {
	 gotoyx(23,1);
	 _puts(erasl);
	 switch(ctype[tmp]) {
	  case ESC:	fl++;
			break;
	  case UP:	if (fl!=2) return(tmp);
			fl=0;
			i=next(-x,i);
			break;
	  case DO:	if (fl!=2) return(tmp);
			fl=0;
			i=next(x,i);
			break;
	  case LE:	if (fl!=2) return(tmp);
			fl=0;
			i=next(-1,i);
			break;
	  case RI:	if (fl!=2) return(tmp);
			fl=0;
			i=next(1,i);
			break;
	  case DIGIT:	switch(itm[i].typ) {
			 case 'C': break;
			 case 'I': 
			 case 'L':
			  itm[i].val=itm[i].val*10+tmp-'0';
			  comp(i);
			  break;
			}
			break;
	  case DEL:	if( itm[i].typ == 'C') break;
			itm[i].val=itm[i].val/10L;
			break;
	  case SPACE:	if( itm[i].typ != 'C') break;
			if( itm[i].val == '-')  itm[i].val = '+';
			else			itm[i].val = '-';
			break;

	  case SIZE:	pitm(i,0);
			usize();
			break;

	  case VERIFY:	pitm(i,0);
			i=verify();
			break;

	  case GET:	get();
			if( partbl.sign != 0123456 ){
				gotoyx(23,1);
				_puts("Invalid partition data");
				break;
			}
			unpack();
			displ();
			break;

	  case FMT:	if ((j=verify())==0) { format(i); break; }
			i=j;
			break;

	  case UPD:	if ((j=verify())) { i=j; break; }
			pack();
			update();
			gotoyx(23,1);
			_puts("Update coplete");
			break;

	  case WRITE:	if ((j=verify())) { i=j; break; }
			write_part();
			gotoyx(23,1);
			_puts("Write complete");
			break;

	  case HELP:	pitm(i,0);
			help();
			break;

	  default:	break;
	 }
	pitm(i,1);
	}
	_puts(curs);
	ttymode(0);
gotoyx(23,1);
}

help()
{
	gotoyx(20,1);
_puts(" U - Update (Занести таблицу в контроллер)    Q - Quit (Выход)\n\r");
_puts(" G - Get    (Взять таблицу из контроллера) \n\r");
_puts(" W - Write  (Записать таблицу на диск) \n\r");
_puts(" S - Size   (Вычислить размеры)           ←↓↑→  - Перемещение указателя\n\r");
_puts(" F - Format (Форматировать раздел)        Space - Измение состояния флага");
	_getchar();
	ttymode(2);
	//while(_getchar()) ;
	ttymode(1);
	gotoyx(20,1);
	_puts("\033[J");
}

usize()
{
	register j,k;
	itm[3].val  =(long)(	itm[0].val *
				itm[1].val *
				itm[2].val );
	pitm(3,0);
	for(k=0;k<8;k++) {
	 j=k*12+4;
	 itm[j+6].val=(long)(	itm[j+1].val *
				itm[j+3].val *
				itm[j+5].val );
	 pitm(j+6,0);
	}
}

verify(i)
{
	register j,k;
	if(itm[3].val <	(itm[10].val+itm[22].val+
		 itm[34].val+itm[46].val+
		 itm[58].val+itm[70].val+
		 itm[82].val+itm[94].val) ) {
		gotoyx(23,1);
		_puts(wm1);
		return(i);
	}
	for(j=0; j<8; j++)
	  if (k=tpbou(j)) {
		gotoyx(23,1);
		_puts(wm2);
		printf(" %1d",j);
		return(k);
	  }
	return(0);
}

write_part()
{
	qq.blk  = 0123456;
	qq.fun  = 0361;
	qq.dev  = 0;
	qq.buf  = (uint16_t *)&partbl;
	qq.cntw = -1;
	execute();
	return;
}

// Таблица разделов извлеченная из файла HARD.225
const uint16_t hard_225[] = {
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,
   18,      4,    615,  44280,      0,    100,     16,  49152,
   36,      0,      4,      0,     18,      0,      0,   2592,
    0,  20516,     18,      0,      4,     32,     18,      0,
    0,   1296,      0,  18486,     72,      0,      4,     64,
   18,      0,      0,   5184,      0,  16510,     18,      0,
    4,     96,     18,      0,      0,   1296,      0,  16528,
  200,      0,      2,    128,     18,      0,      0,   7200,
    0,  16528,    200,      2,      2,    160,     18,      0,
    0,   7200,      0,  16728,    271,      0,      2,    192,
   18,      0,      0,   9756,      0,  16728,    271,      2,
    2,    224,     18,      0,      0,   9756,      0,  42798,
};

get()
{
	qq.blk  = 0;
	qq.fun  = 0360;
	qq.dev  = 0;
	qq.buf  = (& partbl.sec);
	qq.cntw = 1;
	execute();
#if 0
    partbl.sign=0; // Эмитация, что таблицу разделов считали с ошибкой
#else
	memcpy((char *)&partbl, (const char *)hard_225, sizeof(partbl));
#endif
	return;
}

update()
{
	qq.blk  = 0;
	qq.fun  = 0360;
	qq.dev  = 0;
	qq.buf  = (& partbl.sec);
	qq.cntw = -1;
	execute();
	return;
}

format(i)
{
	register j,k;
	char *p;
	pack();
	update();
	if( (i<4) || (i >= (4+8*12)) ) {
		gotoyx(23,1);
		_puts("No Partition pointed");
		return;
	}
	k=(i-4)/12;			/* part#, dev# */
	i=k*12+4;
	gotoyx(23,1);
	_puts(curs);
	ttymode(0);
	printf("Partition #%1d format; Are you sure ? ",k);
	gets(inter);
	ttymode(1);
	_puts(curs);
	if ( (inter[0] & 0137) != 'Y') return;
	for(j=0,p=inter; j < partbl.sec; j++) {
		*p++=0; *p++=(j+k*040);
	}
	if ( vall(i+9) == '+' ) inter[1]=0377;	/* st1 -> -1 sect */
	qq.blk = 0;
	qq.fun = 0362;
	qq.dev = k;
	qq.buf = (uint16_t *)inter;
	qq.cntw= 0123456;

	for( j=0; j<vall(i+1)*vall(i+3); j++) {
		qq.blk=j;
		if(k=execute()) {
			gotoyx(23,1);
			_puts(erasl);
			printf("Formating error #%o",k);
			write_part();
			return;
		}
		inter[1]=qq.dev*040;
	}
	write_part();
	gotoyx(23,1);
	_puts(erasl);
	_puts("Format complete");
}

execute()
{
#if 0
	int	j,k=0;
	hdcsr   = (& qq.blk);
	j=k;
	while ( (hdcsr & 0200) == 0) ;
	return( swabi(hdcsr) & 0377 );
#else
 return -1; // Нет реального контроллера - выдаём ошибки
#endif
}

pack()
{
	register i,j,k;
	partbl.track = (unsigned)vall(0) ;	/* Cylinders */
	partbl.head  = (unsigned)vall(1) ;	/* Heads */
	partbl.sec   = (unsigned)vall(2) ;	/* Sectors */
	ppp = (uint16_t *) &itm[3].val;
	partbl.sizel = ppp[0];
	partbl.sizeh = ppp[1];
	partbl.pcm   = (unsigned)(vall(100)/ 4);	/* precomp */
	partbl.gap3  = (unsigned)vall(101) ;	/* GAP3 size */

	for(i=0; i<8; i++) {
	 k=i*12+4;
	 partbl.prt[i].cb.cb  = vall(k)   ;	/* cyl beg */
	 partbl.prt[i].cn	= vall(k+1);
	 partbl.prt[i].hb	= vall(k+2);
	 partbl.prt[i].hn	= vall(k+3);
	 partbl.prt[i].sb	= vall(k+4)+i*040;
	 partbl.prt[i].sn	= vall(k+5);
	 ppp = (uint16_t *) &itm[k+6].val;
	 partbl.prt[i].szl = ppp[0];
	 partbl.prt[i].szh = ppp[1];
	 if (vall(k+7) == '+')	partbl.prt[i].cb.on=1;
	 else			partbl.prt[i].cb.on=0;
	 if (vall(k+8) == '+')	partbl.prt[i].cb.rw=1;
	 else			partbl.prt[i].cb.rw=0;
	 if (vall(k+9) == '+')	partbl.prt[i].cb.sp=1;
	 else			partbl.prt[i].cb.sp=0;
	 if (vall(k+10) == '+')	partbl.prt[i].cb.nb=1;
	 else			partbl.prt[i].cb.nb=0;
	 if (vall(k+11) == '+')	partbl.prt[i].cb.wb=1;
	 else			partbl.prt[i].cb.wb=0;
	}
	partbl.sign = 0123456;
}

displ()
{
	register i;
	for (i=0; i<cnt; pitm(i++,0)) ;
}

unpack()
{
	register i,j,k;
	vall(0) = partbl.track;	/* Cylinders */
	vall(1) = partbl.head;		/* Heads */
	vall(2) = partbl.sec;		/* Sectors */
	ppp = (uint16_t *) &itm[3].val;
	ppp[0] = partbl.sizel;
	ppp[1] = partbl.sizeh;
	vall(100) = partbl.pcm*4;	/* precomp */
	vall(101) = partbl.gap3;	/* GAP3 size */

	for(i=0; i<8; i++) {
	 k=i*12+4;
	 vall(k)   = partbl.prt[i].cb.cb;	/* cyl beg */
	 vall(k+1) = partbl.prt[i].cn;
	 vall(k+2) = partbl.prt[i].hb;
	 vall(k+3) = partbl.prt[i].hn;
	 vall(k+4) = partbl.prt[i].sb-i*040;
	 vall(k+5) = partbl.prt[i].sn;
/*	 vall(k+6) = partbl.prt[i].szl+partbl.prt[i].szh*E1; */
	ppp = (uint16_t *) &itm[k+6].val;
	ppp[0] = partbl.prt[i].szl;
	ppp[1] = partbl.prt[i].szh; 

	 if (partbl.prt[i].cb.on)	vall(k+7) = '+';
	 else				vall(k+7) = '-';
	 if (partbl.prt[i].cb.rw)	vall(k+8) = '+';
	 else				vall(k+8) = '-';
	 if (partbl.prt[i].cb.sp)	vall(k+9) = '+';
	 else				vall(k+9) = '-';
	 if (partbl.prt[i].cb.nb)	vall(k+10) = '+';
	 else				vall(k+10) = '-';
	 if (partbl.prt[i].cb.wb)	vall(k+11) = '+';
	 else				vall(k+11) = '-';
	}
}

tpbou(i)
{
	register j,k,n;
	n=i*12+4;
	for(j=i+1;j<8;j++) {
	 k=j*12+4;
	 if(  itm[n].val < itm[k].val ) {			/* n -> k */
	  if(  itm[n].val+itm[n+1].val > itm[k].val )
	   if(  itm[n+2].val < itm[k+2].val ) {
	    if(  itm[n+2].val+itm[n+3].val > itm[k+2].val ) return(k);
	   } else {
	    if(  itm[k+2].val+itm[k+3].val > itm[n+2].val ) return(k);
	   }
	 } else {
	  if(	itm[k].val+itm[k+1].val > itm[n].val ) 
	   if(  itm[n+2].val < itm[k+2].val ) {
	    if(  itm[n+2].val+itm[n+3].val > itm[k+2].val ) return(k);
	   } else {
	    if(  itm[k+2].val+itm[k+3].val > itm[n+2].val ) return(k);
	   }
	 }
	}

	if( itm[n].val+itm[n+1].val > itm[0].val ) return(n+1);
	if( itm[n+2].val+itm[n+3].val > itm[1].val ) return(n+3);
	if( itm[n+4].val+itm[n+5].val > itm[2].val ) return(n+5);

	if( (itm[n+1].val * itm[n+3].val * itm[n+5].val) !=
		itm[n+6].val ) return(n+6);

	if( (itm[n].val == 0) && (itm[n+9].val != '+') ) return(n+9);
	return(0);
}

uint32_t comp(int i)
{
	uint32_t a=10L;
	register j=itm[i].wid;
	for( ; j>1; j--) a*=10L;
	if( itm[i].val >= a ) itm[i].val=itm[i].val/10L;
	return(a);
}

next(d,i)
int   d,i;
{
	register j=0;
	pitm(i,0);
	while (vect[j] != i) j++;

	while ( ((j+d) >= 0) && ((j+d) < (x*y))) {
	  if (vect[j+d] != i) {
	    i=vect[j+d];
	    return(i);
	  }
	  else j+=d;
	}
	return(i);
}

pitm(i,rev)
{
	char	str[20],*s=str;
	gotoyx(itm[i].lin,itm[i].col);
	if(rev) _puts("\033[7m");
	s=str;
	*s++='%';
	switch(itm[i].typ) {

	 case 'I':
	 case 'L':	sprintf(s++,"%1d",itm[i].wid);
			*s++='l'; *s++='d';
			break;
	 case 'C':	str[0]=itm[i].val;
			break;
	 default:	err(msg2);
	}
	*s++=0;
	printf(str,itm[i].val);
	_puts("\033[0m");
}
