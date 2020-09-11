CONST
  MAXX = 280;
  MAXY = 229;
  MAXX1 = 320;
  MAXY1 = 269;
  MAXCOLOR = 15;
  PI  = 3.14;

TYPE
  WORD = 0..65535;
  STRING = ARRAY [1..38] OF CHAR;
VAR
  MODP    : INTEGER;
  IDENT,ANUM   : INTEGER;
  IDENT1,ANUM1 : INTEGER;
  CH      : CHAR;
  ERR     : INTEGER;
  AR      : ARETYP;
  SEED    : 0..65535;
  VW      : WINTYP;
  PAL     : PALTYP;
  PAL1    : PALTYP;
  KEYB      ORIGIN 177560B,
  KEYBUF    ORIGIN 177562B : INTEGER;
  COLOR   : CHAR;
 

FUNCTION KEYPRESSED : BOOLEAN;
BEGIN
  IF KEYB AND 200B <> 0 THEN
     KEYPRESSED:=TRUE
  ELSE KEYPRESSED:=FALSE
END;


FUNCTION RandOM (I:INTEGER) : INTEGER;
VAR
  TMP : INTEGER;
begin
{$C
	MOV	SEED(R5),R1
	MUL	#13077.,R1
	ADD	#12345.,R1
	MOV	R1,SEED(R5)
	CLR	R0
	DIV	I(SP),R0
	MOV	R1,TMP(SP)
}
  RANDOM:=TMP
end;

PROCEDURE BOX (IDENT,X1,Y1,X2,Y2 : INTEGER) ;
BEGIN
  GMOVE (IDENT, X1, Y1);
  GLINE (IDENT, X1, Y2);
  GLINE (IDENT, X2, Y2);
  GLINE (IDENT, X2, Y1);
  GLINE (IDENT, X1, Y1);
END;

PROCEDURE WINCLR (IDENT:INTEGER);
CONST
  DELTAX = 2;
  DELTAY = 2;
BEGIN
  GFGC (IDENT,15);
  GCLRR(IDENT);
  BOX (IDENT, 0, 0, MAXX1-10, MAXY1-2);
  BOX (IDENT,DELTAX , DELTAY, MAXX1-DELTAX-10, MAXY1-DELTAY-2);
  GMOVE (IDENT, 0, MAXY1-30);
  GLINE (IDENT, MAXX1-10, MAXY1-30);
  GMOVE (IDENT, 0, MAXY1-30-DELTAY);
  GLINE (IDENT, MAXX1-10, MAXY1-30-DELTAY);
END;

PROCEDURE INIT;
BEGIN
  PAL1.MODPAL := 0;
  PLSAV(PAL1);
  COLOR := PAL1.C[15];
  PAL1.C[15] := CHR(0);     
  PLMOD (PAL1);
  KEYB:=KEYB AND NOT 100B;
  MODP:=PL0+VM40;
  GCREA (MAXX, MAXY, MODP,IDENT, ANUM);
  GCREA (MAXX1, MAXY1, MODP,IDENT1, ANUM1);
  GWNDW (IDENT, 0,0, MAXX, MAXY);
   WITH VW DO
       BEGIN
	WNUM:=0;
	AREA:=ANUM1;
	ARY:=0;
	ARX:=0;
	SY1:=15;
	SY2:=MAXY1+10;
	SX1:=2;
	SX2:=26;
	DEN:=1002B
       END;     
   VWCRE (VW);
   WITH VW DO
    BEGIN
	WNUM:=0;
	AREA:=ANUM;
	ARY:=0;
	ARX:=0;
	SY1:=20;
	SY2:=MAXY+16;
	SX1:=3;
	SX2:=22;
	DEN:=1002B
     END;     
     VWCRE (VW);
     WINCLR(IDENT1);
     GROP(IDENT, 0);
END;

PROCEDURE MESSAGE (STR : STRING);
BEGIN
  STR[1]:=CHR(7B);
  STR[2]:=CHR(360B);
  STR[38]:=CHR(0);
  WPRINT (ANUM1, 3, MAXY1-27, STR[1]);
  STR:='  Press RETURN to continue            ';
  STR[1]:=CHR(7B);
  STR[2]:=CHR(360B);
  STR[38]:=CHR(0);
  WPRINT (ANUM1, 3, MAXY1-15, STR[1]);
END;


procedure PutPixelPlay;
const
  NumPts = 1000; { The number of pixels plotted }
var
  I, TMP : INTEGER;
  X, Y, Color : INTEGER;
begin
  MESSAGE ('  PutPixel / GetPixel demonstration   ');
  WHILE NOT KEYPRESSED DO
   BEGIN
    { Plot random pixels }
    {seed := 12345;}
     SEED:=1126;
    I := 0;
    while NOT KEYPRESSED AND (I < NumPts) do
    begin
      i:=succ(i);
      GFGC(IDENT, RANDOM(MAXCOLOR));
      GDOT (IDENT, Random(MaxX)+1, Random(MaxY)+1);
    end;
    PAL.MODPAL:=MODP;
    PLSAV (PAL);
    TMP:=ORD(PAL.C[1]);
    PAL.C[1]:=PAL.C[0];
    PLMOD(PAL);
    seed := 1126;
    I := 0;
    GFGC(IDENT, 1);
    while NOT KEYPRESSED AND (I < NumPts) do
    begin
      I:=SUCC(I);
      COLOR:=RANDOM(MAXCOLOR);
      X := Random(MaxX)+1;
      Y := Random(MaxY)+1;
        GDOT(IDENT, X, Y);
    end;
    GCLRR (IDENT);
    PAL.C[1]:=CHR(TMP);
    PLMOD(PAL)
  END;
  IF KEYBUF = 0 THEN
end; { PutPixelPlay }

procedure AspectRatioPlay;
var
  CenterX    : integer;
  CenterY    : integer;
  Radius     : INTEGER;
  Xasp, Yasp : INTEGER;
  i          : integer;
  RadiusStep : INTEGER;
begin
    message ('  AspectRatio demonstration           ');
    GFGC (IDENT, 15);    
    Radius := 2*(MAXY div 5);
    XASP:=RADIUS; YASP:=RADIUS;
    CenterX := MAXX div 2;
    CenterY := MAXY div 2;
  RadiusStep := (Radius div 20);
  GDOT (IDENT, CENTERX+RADIUS, CENTERY);
  GARCC (IDENT, CenterX, CenterY, CENTERX+RADIUS, CENTERY);
  for i := 1 to 20 do
  begin
    GASP (IDENT, XASP, YASP + I*(RADIUS DIV 15)+I*I*5); 
    GDOT (IDENT, CENTERX+RADIUS, CENTERY);
    GARCC (IDENT, CenterX, CenterY, CENTERX+RADIUS, CENTERY);
    RADIUS:=RADIUS-RADIUSSTEP;
  end;
  RADIUS:=RADIUS+RADIUSSTEP*20;
  for i := 1 to 20 do
  begin
    GASP (IDENT,XASP + I*(RADIUS DIV 15)+I*I*5, YASP); 
    if Radius > RadiusStep then
     RADIUS:=RADIUS-RADIUSSTEP;
    GDOT (IDENT, CENTERX, CENTERY+RADIUS);
    GARCC (IDENT, CenterX, CenterY, CENTERX, CENTERY+RADIUS);
  end;
  GASP (IDENT,XASP,YASP);
  REPEAT UNTIL KEYPRESSED;
  IF KEYBUF = 0 THEN
end; { AspectRatioPlay }


procedure PutImagePlay;
var
  Pausetime : INTEGER;
  Saucer    : ARRAY [0..300] OF INTEGER;
  X, Y      : integer;
  X1, Y1    : integer;
  STEPX,
  STEPY     : INTEGER;
  ulx1, uly1  : INTEGER;
  Ulx2, Uly2  : INTEGER;
  Size      : INTEGER;
  I         : INTEGER;
  KUKAN     : BOOLEAN;

CONST
  NUMPTS = 200;
  StartX = 100;
  StartY = 50;
  R     =  5;
  LBODY = 10;
  DXL   =  4;
  DYL   =  6;
  L1    =  2;
  DXH   =  3;
  DYH   =  5;
  DXF   =  2;
  DXU   =  3;
  DYU   =  7;

PROCEDURE DELAY (T : INTEGER);
BEGIN
  REPEAT T:=T-1 UNTIL T=0;
END;


procedure MoveSaucer(var X, Y : integer; Width, Height : integer);
begin
  X:=X+STEPX;
  IF (X+WIDTH > MAXX-1) OR (X < 0)  THEN BEGIN
     STEPX:=-STEPX;
     X := X + STEPX;
     Y := Y+STEPY;
     IF KEYPRESSED THEN BEGIN 
       KUKAN := TRUE;
       IF KEYBUF = 0 THEN;
    END;
  END;
  IF (Y + HEIGHT - 1 > MAXY) OR (Y < 0) THEN BEGIN
    STEPY := -STEPY;
    Y := Y + STEPY;
  END;
end; { MoveSaucer }

begin
  message ('  PutImage / GetImage demonstration   ');
  KUKAN := FALSE;
  GCLRR (IDENT);
  GROP  (IDENT,2);
    PAL.MODPAL:=MODP;
    PLSAV (PAL);
    I:=ORD(PAL.C[15]);
    PAL.C[15]:=PAL.C[0];
    PLMOD(PAL);
  GDOT (IDENT, STARTX, STARTY+r);
  GARCC (IDENT, startX, startY, startx, starty+r);
  GLINE (IDENT, STARTX, STARTY+R+LBODY); {DRAW BODY};
  GLINE (IDENT, STARTX-DXL, STARTY+R+LBODY+DYL); {DRAW LEFT LEG};
  GLINE (IDENT, STARTX-DXL-DXF, STARTY+R+LBODY+DYL); {DRAW LEFT LEG};
  GDOT (IDENT, STARTX, STARTY+r+LBODY);
  GLINE (IDENT, STARTX+DXL, STARTY+R+LBODY+DYL); {DRAW RIGHT LEG};
  GLINE (IDENT, STARTX+DXL+DXF, STARTY+R+LBODY+DYL); {DRAW LEFT LEG};
  GDOT (IDENT, STARTX, STARTY+r+L1);
  GLINE (IDENT, STARTX-DXH, STARTY+R+L1+DYH); {DRAW LEFT HAND};
  GDOT (IDENT, STARTX, STARTY+r+L1);
  GLINE (IDENT, STARTX+DXH, STARTY+R+L1+DYH); {DRAW RIGHT HAND};
  GDOT (IDENT, STARTX, STARTY-r);
  GLINE(IDENT,STARTX-DXU,STARTY-R-DYU);    
  GDOT (IDENT, STARTX, STARTY-r);
  GLINE(IDENT,STARTX+DXU,STARTY-R-DYU);    


  { ReadSaucerImage }
  ulx1 := StartX-DXL-DXF;
  uly1 := StartY-R-DYU;
  Ulx2 := StartX+DXL+DXF;
  Uly2 := StartY+R+LBODY+DYL;

  GVRR(IDENT,ulx1, uly1, Ulx2, Uly2, Saucer[0]);
  GRVR(IDENT,ulx1, uly1, Saucer[0]);

  PAL.C[15]:=CHR(I);
  PLMOD (PAL);
     SEED:=1126;
    I := 0;
    while I < NumPts do
    begin
      i:=succ(i);
      GFGC(IDENT, RANDOM(MAXCOLOR));
      GDOT (IDENT, Random(MaxX)+1, Random(MaxY)+1);
    end;

  X := 0;
  Y := 0;
  X1:= 0;
  Y1:= 0;
  STEPX := 1;
  STEPY := 15;
  PauseTime := 4000;
  repeat
    GRVR(IDENT,X, Y, Saucer[0]);
{    Delay(PauseTime);}
    MoveSaucer(X1, Y1, 2*(DXL+DXF) + 1, 2*R+LBODY+DYL + 1);
    GRVR(IDENT,x, y, Saucer[0]);
    X := X1; Y := Y1;
  until KUKAN;
end; { PutImagePlay }

procedure CirclePlay;
{ Draw random circles on the screen }
var
  MaxRadius : INTEGER;
  X, Y, RAD : INTEGER;
begin
  message ('  Random Circles demonstration        ');
  GCLRR (IDENT);
  GROP (IDENT,0);
  MaxRadius := MaxY div 10;
  SEED:=1126;  
  repeat
   GFGC(IDENT, RANDOM(MAXCOLOR));
   RAD:=RANDOM (MAXRADIUS);
   X:=RANDOM (MAXX-RAD);
   Y:=RANDOM (MAXY-RAD);
   IF RAD < 5 THEN RAD:=5;
   GDOT (IDENT,X+RAD, Y);
   GARCC (IDENT, X, Y, X+RAD, Y);
  until KeyPressed;
  IF KEYBUF = 0 THEN;
end; { CirclePlay }

procedure FillPatternPlay;
{ Display some user defined fill patterns }
TYPE
  ARR = ARRAY [0..200,0..1] OF INTEGER;
CONST
  XCON  = 0;
  YCON  = 1;
  MAXST = 11;
  A1 = 80;
  a2 = 10;
  MAXFILLINE = 18;
var
  Style    : INTEGER;
  Width    : INTEGER;
  Height   : INTEGER;
  X, Y     : INTEGER;
  I, J     : INTEGER;
  PATTERNS : ARRAY [0..MAXST, 1..MAXFILLINE] OF INTEGER;
  COUN1    : INTEGER;
  COUN2    : INTEGER;

  FIG1      : ARR;
  FIG2      : ARR;

PROCEDURE INITPAT;
VAR
  I, J : INTEGER;
BEGIN
  PATTERNS[0,1]:=8; PATTERNS[0,2]:=8;
  PATTERNS[0,3]:=0; PATTERNS[0,4]:=2;
  PATTERNS[0,5]:=0; PATTERNS[0,6]:=20B;
  PATTERNS[0,7]:=0; PATTERNS[0,8]:=1000B;
  PATTERNS[0,9]:=0; PATTERNS[0,10]:=20000B;
  PATTERNS[0,11]:=2; PATTERNS[0,12]:=0;
  PATTERNS[0,13]:=20B; PATTERNS[0,14]:=0;
  PATTERNS[0,15]:=1000B; PATTERNS[0,16]:=0;
  PATTERNS[0,17]:=20000B; PATTERNS[0,18]:=0;

  PATTERNS[1,1]:=8; PATTERNS[1,2]:=8;
  PATTERNS[1,3]:=20000B; PATTERNS[1,4]:=0;
  PATTERNS[1,5]:=1000B; PATTERNS[1,6]:=0;
  PATTERNS[1,7]:=20B; PATTERNS[1,8]:=0;
  PATTERNS[1,9]:=2; PATTERNS[1,10]:=0;
  PATTERNS[1,11]:=0; PATTERNS[1,12]:=20000B;
  PATTERNS[1,13]:=0; PATTERNS[1,14]:=1000B;
  PATTERNS[1,15]:=0; PATTERNS[1,16]:=20B;
  PATTERNS[1,17]:=0; PATTERNS[1,18]:=2;

  PATTERNS[2,1]:=8; PATTERNS[2,2]:=2;
  PATTERNS[2,3]:=52525B; PATTERNS[2,4]:=52525B;
  PATTERNS[2,5]:=0; PATTERNS[2,6]:=0;

  PATTERNS[3,1]:=4; PATTERNS[3,2]:=8;
  PATTERNS[3,3]:=70160B; PATTERNS[3,4]:=70160B;
  PATTERNS[3,5]:=70160B; PATTERNS[3,6]:=70160B;
  PATTERNS[3,7]:=70160B; PATTERNS[3,8]:=70160B;
  PATTERNS[3,9]:=70160B; PATTERNS[3,10]:=70160B;

  PATTERNS[4,1]:=4; PATTERNS[4,2]:=2;
  PATTERNS[4,3]:=110220B; PATTERNS[4,4]:=0;

  PATTERNS[5,1]:=4; PATTERNS[5,2]:=1;
  PATTERNS[5,3]:=125252B;

  PATTERNS[6,1]:=8; PATTERNS[6,2]:=8;
  PATTERNS[6,3]:=63146B; PATTERNS[6,4]:=63146B;
  PATTERNS[6,5]:=63146B; PATTERNS[6,6]:=63146B;
  PATTERNS[6,7]:=63146B; PATTERNS[6,8]:=63146B;
  PATTERNS[6,9]:=63153B; PATTERNS[6,10]:=63146B;
  PATTERNS[6,11]:=64144B; PATTERNS[6,12]:=64146B;
  PATTERNS[6,13]:=62144B; PATTERNS[6,14]:=62146B;
  PATTERNS[6,15]:=63105B; PATTERNS[6,16]:=43143B;
  PATTERNS[6,17]:=63144B; PATTERNS[6,18]:=63146B;

  PATTERNS[7,1]:=8; PATTERNS[7,2]:=8;
  PATTERNS[7,3]:=177777B; PATTERNS[7,4]:=167356B;
  PATTERNS[7,5]:=177777B; PATTERNS[7,6]:=167356B;
  PATTERNS[7,7]:=177777B; PATTERNS[7,8]:=167356B;
  PATTERNS[7,9]:=177777B; PATTERNS[7,10]:=167356B;
  PATTERNS[7,11]:=167356B; PATTERNS[7,12]:=177777B;
  PATTERNS[7,13]:=167356B; PATTERNS[7,14]:=177777B;
  PATTERNS[7,15]:=167356B; PATTERNS[7,16]:=177777B;
  PATTERNS[7,17]:=167356B; PATTERNS[7,18]:=177777B;

  PATTERNS[8,1]:=16; PATTERNS[8,2]:=1;
  PATTERNS[8,3]:=443B; PATTERNS[8,4]:=101547B;
  PATTERNS[8,5]:=104653B; PATTERNS[8,6]:=146757B;

  SEED:=1126;
  PATTERNS[9,1]:=8; PATTERNS[9,2]:=8;
  PATTERNS[9,3]:=RANDOM(177777B); PATTERNS[9,4]:=RANDOM(177777B);
  PATTERNS[9,5]:=RANDOM(177777B); PATTERNS[9,6]:=RANDOM(177777B);
  PATTERNS[9,7]:=RANDOM(177777B); PATTERNS[9,8]:=RANDOM(177777B);
  PATTERNS[9,9]:=RANDOM(177777B); PATTERNS[9,10]:=RANDOM(177777B);
  PATTERNS[9,11]:=RANDOM(177777B); PATTERNS[9,12]:=RANDOM(177777B);
  PATTERNS[9,13]:=RANDOM(177777B); PATTERNS[9,14]:=RANDOM(177777B);
  PATTERNS[9,15]:=RANDOM(177777B); PATTERNS[9,16]:=RANDOM(177777B);
  PATTERNS[9,17]:=RANDOM(177777B); PATTERNS[9,18]:=RANDOM(177777B);

  PATTERNS[10,1]:=8; PATTERNS[10,2]:=8;
  PATTERNS[10,3]:=27356B; PATTERNS[10,4]:=167342B;
  PATTERNS[10,5]:=161356B; PATTERNS[10,6]:=167056B;
  PATTERNS[10,7]:=167056B; PATTERNS[10,8]:=161356B;
  PATTERNS[10,9]:=167342B; PATTERNS[10,10]:=27356B;
  PATTERNS[10,11]:=167342B; PATTERNS[10,12]:=27356B;
  PATTERNS[10,13]:=167056B; PATTERNS[10,14]:=161356B;
  PATTERNS[10,15]:=161356B; PATTERNS[10,16]:=167056B;
  PATTERNS[10,17]:=27356B; PATTERNS[10,18]:=167342B;

  PATTERNS[11,1]:=4; PATTERNS[11,2]:=1;
  PATTERNS[11,3]:=177777B;
END;

procedure DrawBox(X, Y : word);
begin
  GPTRN (IDENT, PATTERNS[STYLE,1]);
  GDOT (IDENT, X, Y);
  GLINE (IDENT, X,Y+HEIGHT);
  GLINE (IDENT, X+WIDTH, Y+HEIGHT);
  GLINE (IDENT, X+WIDTH, Y);
  GLINE (IDENT, X, Y);
  GFILL (IDENT, X+10, Y+10);
  STYLE:=SUCC(STYLE)
end; { DrawBox }

PROCEDURE INITPICTURE (VAR I : INTEGER;VAR FIG : ARR; RL,rs : INTEGER);
CONST
  PI = 3.14;
  X  = 0;
  Y  = 1;  
VAR
  FI, 
  DELTAFI : REAL;
  XC, YC  : INTEGER;  
BEGIN
  FI := 0;
  DELTAFI := PI / 54;
  I := 0;
  XC := MAXX DIV 2;
  YC := MAXY DIV 2;
  REPEAT
    FIG [I,X] := XC+TRUNC((RL + rs)*COS(FI)-rs*COS((RL + rs)/rs*FI));
    FIG [I,Y] := YC+TRUNC((RL + rs)*SIN(FI)-rs*SIN((RL + rs)/rs*FI));
    I := SUCC(I);
    FI := FI + DELTAFI;
  UNTIL FI > 2*PI;  
  I := PRED (I);
END;

begin
  message ('  Fill Patterns demonstration         ');
  GCLRR (IDENT);
  GFGC(IDENT, 2);
  initpat;
  GROP(IDENT,0);
  Width := 2 * ((MAXX+1) div 13);
  Height := 2 * ((MAXY-10) div 10);
  X := Width div 2;
  Y := Height div 2;
  Style := 0;
  for J := 1 to 3 do
  begin
    for I := 1 to 4 do
    begin
      DrawBox(X, Y);
      X:=X+ (WIDTH DIV 2) * 3
    end;
    X := Width div 2;
    Y:=Y+ (HEIGHT DIV 2) * 3
  end;
  INITPICTURE (COUN1,FIG1,80,10);
  INITPICTURE (COUN2,FIG2,40,8);
  REPEAT UNTIL KEYPRESSED;
  IF KEYBUF = 0 THEN;

  GCLRR (IDENT);
  GMOVE (IDENT, FIG1[0,XCON],FIG1[0,YCON]); 
  FOR J := 1 TO COUN1 DO GLINE (IDENT, FIG1[J, XCON], FIG1[J, YCON]);
  GMOVE (IDENT, FIG2[0,XCON],FIG2[0,YCON]); 
  FOR J := 1 TO COUN2 DO GLINE (IDENT, FIG2[J, XCON], FIG2[J, YCON]);
  GPTRN (IDENT, PATTERNS [7,1]);
  GFILL (IDENT, MAXX DIV 2, MAXY DIV 2);
  GPTRN (IDENT, PATTERNS [5,1]);
  GFILL (IDENT, MAXX DIV 2 + 50, MAXY DIV 2 + 60);
  REPEAT UNTIL KEYPRESSED;
  IF KEYBUF = 0 THEN;
end; { FillPatternPlay }

procedure LineStylePlay;
{ Demonstrate the predefined line styles available }
TYPE
LINESTYLE = ARRAY [1..10] OF INTEGER;

var
  Style    : INTEGER;
  Step     : INTEGER;
  X, Y     : INTEGER;
  STYLEPAT : LINESTYLE;
  RADIUS   : INTEGER;
  DALFA    : REAL;
  I        : INTEGER;
  NUMPTS   : INTEGER;
  COLOR    : INTEGER;

PROCEDURE INITLINES;
BEGIN
  STYLEPAT[1]:=170360B;
  STYLEPAT[2]:=162344B;
  STYLEPAT[3]:=125252B;
  STYLEPAT[4]:=177777B;
  STYLEPAT[5]:=143614B;
  STYLEPAT[6]:= 55732B;
  STYLEPAT[7]:=174237B;
  STYLEPAT[8]:=177777B;
  STYLEPAT[9]:=171631B;
  STYLEPAT[10]:=162344B;
END;

begin
  message ('  Line Styles demonstration           ');
    INITLINES;
    GCLRR (IDENT);
    GROP (IDENT, 0);
    X := MAXX DIV 2;
    Y := MAXY DIV 2;
    NUMPTS := 12;
    RADIUS := 100;
    Step := 10;
    COLOR := 2;

    for Style := 1 to 10 do
    begin
      DALFA := 6.28 / NUMPTS;
      GTYPE (IDENT, STYLEPAT[STYLE]);
      GFGC (IDENT, COLOR);
      GMOVE (IDENT, X+ROUND(RADIUS*COS(DALFA)), Y+ROUND(RADIUS*SIN(DALFA)));
      FOR I:=2 TO NUMPTS+1 DO 
      GLINE (IDENT,X+ROUND(RADIUS*COS(I*DALFA)),Y+ROUND(RADIUS*SIN(I*DALFA)));
      RADIUS:=RADIUS-STEP;
      NUMPTS:=PRED(NUMPTS);
      COLOR := SUCC (COLOR);
    end;
    WHILE NOT KEYPRESSED DO;
    IF KEYBUF = 0 THEN
end; { LineStylePlay }

PROCEDURE GOODBYE;
BEGIN
  KEYB:=KEYB OR 100B;
  gclrr (ident);
  message ('                                      ');
  READLN (CH);
  PAL1.C[15]:=COLOR ;
  PLMOD (PAL1);
  GKILL (IDENT);
  GKILL (IDENT1);
{  TIMEUNLOCK;}
END;

BEGIN
  INIT;
  PUTPIXELPLAY;
  ASPECTRATIOPLAY;
  PutImagePlay;
  CIRCLEPLAY;
  FILLPATTERNPLAY;
  LINESTYLEPLAY;
  GOODBYE;
END.
