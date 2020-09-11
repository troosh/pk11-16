(*$T-*)
(*$A-*)


VAR
  A2W : RECORD CASE INTEGER OF
	1: (W : INTEGER);	
	2: (A : ^INTEGER);
	3: (AC : ^CHAR);
	END;


(*--------------------------------------------------------*)

PROCEDURE ARGET ( VAR AR :ARETYP);
VAR
  W : RECORD
	CODE	: INTEGER;
	ANUM	: INTEGER;
	LINS	: INTEGER;
	SLEN	: INTEGER;
	TAS	: ARRAY [1..300, 1..2] OF INTEGER;
      END;
  LINP, NPAGE, MMR, VADR, MODPAL, I,J,K : INTEGER;

BEGIN
  W.CODE := 0;
  W.ANUM := AR.ANUM;
  W.LINS := AR.LINS;
  W.SLEN := AR.SLEN;
  LINP := 8192 DIV W.SLEN;
  
  IF AR.AMMR=0 THEN
  BEGIN
  NPAGE := (W.LINS + LINP - 1) DIV LINP;
  AR.NPAGE := NPAGE;
    (*$C
	MOV	NPAGE(6),@#^O174200 ;GET8K
	NOP
	MOV	R0, MMR(6)
    *)
    AR.AMMR := MMR;
  END
  ELSE
    MMR := AR.AMMR;
  VADR := 0;
  MODPAL := AR.MODPAL;
  WITH W DO
  bEGIN
    FOR I := 1 TO LINS DO
    BEGIN
      TAS[I,1] := VADR;
      TAS[I,2] := MMR + MODPAL; 
      VADR := VADR + SLEN;
      IF VADR >= 10000B THEN
      BEGIN
        VADR := VADR AND 7777B;
        MMR := MMR + 20B;
      END;
      IF (I MOD LINP) = 0 THEN
      BEGIN
	VADR := 0;
	MMR := MMR + 20B;
      END;
    END;
    A2W.A := @CODE;
    WCSR := A2W.W;
    A2W.W := ANUM;
    AR.ANUM := ANUM;
  END; (* WITH W *)
  HBMOVE(AR.ANUM,VCV,0,AR.LINS,0,AR.SLEN,0,0,0);
END;

PROCEDURE ARFRE ( VAR AR :ARETYP);
VAR
  W : RECORD
       CODE : INTEGER;
       ANUM : INTEGER;
      END;
  LINP, NPAGE, MMR, I,J,K : INTEGER;

BEGIN
  WITH W DO
  BEGIN
    CODE := 2;
    ANUM := AR.ANUM;
    A2W.A := @CODE;
    WCSR := A2W.W;
  END;
  NPAGE := AR.NPAGE;
  MMR := AR.AMMR;
    (*$C
	MOV	MMR(6), R0
	MOV	NPAGE(6),@#^O174202 ; FREMEM
    *)
   AR.ANUM := 0;
   AR.AMMR := 0;
END;

(*--------------- MAIN DATA BASE -------------------------*)
const
  Gray = 216B;
  Blue = 002B;
var
  BGLine : array [1..26] of integer;
  BGAR, TXAR, RNAR, SHAR, VEAR, GOAR, SAAR, CAAR, MYAR : AreTyp;
  BGWN, TXWN, RNWN, SHWN, VEWN, GOWN, SAWN, CAWN, MYWN : WinTyp;
  TX1, TX2, TX3 : Str20;
(*---------------- MAIN PROCEDURES -----------------------*)
procedure Delay ( D :integer);
var
  I, J : integer;
begin
  for I := 1 to D do J := I + 8;
end;

procedure LDelay ( D :integer);
var
  I : integer;
begin
  for I := 1 to D do Delay(21425);
end;

procedure Rwprint( ANUM, COL, X, Y, N :integer; S : str20);
var
  W : array [1..25] of char;
  C, I : integer;
begin
  C := abs(COL);
  IF COL > 0 THEN W[1] := CHR(6) ELSE W[1] := CHR(5);
  W[2] := chr(7); W[3] := chr(C*16);
  for I := 1 to N do
  begin
    C := ord(S[I]); if C >= 64 then C := C + 112;
    W[3+I] := chr(C);
  end;
  W[N+4] := chr(0);
  Wprint(ANUM,X,Y,W[1]);
end;

procedure WHMove ( var WIN :WinTyp; D :integer);
var
  I,J,N : integer;
begin
  N := abs(D);
  J := N div D;
  for I := 1 to N do
  begin
    WIN.SX1 := WIN.SX1 + J;
    WIN.SX2 := WIN.SX2 + J;
(* $C
	mov	@#^O147040, r0
1$:
	cmp	@#^O147040, r0
	beq	1$
*)
    VWCRE(WIN);
  end;
end;

procedure WVMove ( var WIN :WinTyp; D :integer);
var
  I,J,N : integer;
begin
  I := D div 8;
  N := abs(I);
  J := (D div N);
  for I := 1 to N do
  begin
    WIN.SY1 := WIN.SY1 + J;
    WIN.SY2 := WIN.SY2 + J;
(* $C
	mov	@#^O147040, r0
1$:
	cmp	@#^O147040, r0
	beq	1$
*)
    VWCRE(WIN);
  end;
end;

procedure TXArea;
var
  PAL : PalTyp;
begin
  TXAR.ANUM := 0;
  TXAR.LINS := 160;
  TXAR.SLEN := 160;
  TXAR.MODPAL := VM40 + PL0;
  TXAR.AMMR := 0;
  ArGet(TXAR);
  with PAL do
  begin
   MODPAL := TXAR.MODPAL;
   C[ 0]:=chr(Gray); C[ 1]:=chr(034B); C[ 2]:=chr(374B); C[ 3]:=chr(334B);    
   C[ 4]:=chr(156B); C[ 5]:=chr(377B); C[ 6]:=chr(266B); C[ 7]:=chr(000B);    
   C[ 8]:=chr(034B); C[ 9]:=chr(376B); C[10]:=chr(151B); C[11]:=chr(236B);    
   C[12]:=chr(172B); C[13]:=chr(374B); C[14]:=chr(374B); C[15]:=chr(000B);    
  end;
  PlMod(PAL);
end;

PROCEDURE BGArea;
const
  blins = 300;
  bslen = 52;
VAR
  W : RECORD
	CODE	: INTEGER;
	ANUM	: INTEGER;
	LINS	: INTEGER;
	SLEN	: INTEGER;
	TAS	: ARRAY [1..300, 1..2] OF INTEGER;
      END;
  LINP, NPAGE, MMR, VADR, MODPAL, I,J,K : INTEGER;

BEGIN
  BGAR.lins := blins;
  BGAR.slen := bslen;
  BGAR.modpal := vm2 + pl3; 
  W.CODE := 0;
  W.ANUM := 0;
  W.LINS := bLINS;
  W.SLEN := bSLEN;
  (*$C
	mov	r5, r0
	add	#BGLine, r0
	mov	r0, vadr(6)
	ash	#-13., r0
	asl	r0
	mov	^O161220(r0), mmr(6)
  *)
  MMR := MMR + BGAR.MODPAL;
  WITH W DO
  BEGIN
    FOR I := 1 TO LINS DO
    BEGIN
      TAS[I,1] := VADR;
      TAS[I,2] := MMR; 
    END;
    A2W.A := @CODE;
    WCSR := A2W.W;
    A2W.W := ANUM;
    BGAR.ANUM := ANUM;
  END; (* WITH W *)
  WITH BGWN DO
  BEGIN
    AREA := BGAR.ANUM;
    WNUM := 0;
    DEN := 0;
    ARY := 0;
    ARX := 0;
  END;
END;

procedure BgCre(var W, B :WinTyp; N :integer);
begin
  with B do
  begin
    AREA := BGAR.ANUM;
    sy1 := W.sy1+12*N;
    sy2 := W.sy2+12*N;
    sx1 := W.sx1+1*N;
    sx2 := W.sx2+1*N;
    DEN := 0;
    ARX := 0;
    ARY := 0;
  end;
  VWCre(B);
end;

procedure HideVT( COL :integer);
var
  PAL : PalTyp;
  I : integer;
begin
  for I := 0 to 15 do
    PAL.C[I] := chr(COL);
  PAL.MODPAL := VM1 + PL0;
  PlMod(PAL);
  PAL.MODPAL := VM1 + PL1;
  PlMod(PAL);
end;

procedure ShowVT( COL :integer);
var
  PAL : PalTyp;
begin
  with PAL do
  begin
    C[0] := chr(COL);
    C[7] := chr(COL);
    C[11] := chr(COL);
    C[13] := chr(COL);
    C[14] := chr(COL);
    C[15] := chr(376B);
    MODPAL := VM1 + PL1;
  end;
  PlMod(PAL);
end;

procedure ClearTX;
begin
TX1 := '                    ';
TX2 := TX1;
TX3 := TX1;
end;

procedure OpenTX;
var
  I : integer;
  PAL : PalTyp;
begin
  HBMOVE(TXAR.ANUM,VCV,0,100,0,100,0,0,0);
  PAL.MODPAL := TXAR.MODPAL;
  PlSav(PAL);
  PAL.C[0] := chr(142B);
  PlMod(PAL);
  Rwprint(TXar.anum, 7, 5, 12, 20, TX1);
  Rwprint(TXar.anum,-2, 4, 10, 20, TX1);
  Rwprint(TXar.anum, 7, 5, 32, 20, TX2);
  Rwprint(TXar.anum,-2, 4, 30, 20, TX2);
  Rwprint(TXar.anum, 7, 5, 52, 20, TX3);
  Rwprint(TXar.anum,-2, 4, 50, 20, TX3);
  with TXWN do
  begin
    WNUM := 0;
    AREA := TXAR.ANUM;
    SY1 := 120;
    SY2 := 120;
    SX1 := 12;
    SX2 := 12;
    ARX := 40;
    ARY := 80;
    DEN := 258;
  end;
  bgCre(TXWN,BGWN,1);
  FOR I := 1 TO 5 DO
  BEGIN
    TXWN.SY1 := TXWN.SY1 - 16;
    TXWN.SY2 := TXWN.SY2 + 16;
    TXWN.SX1 := TXWN.SX1 - 1;
    TXWN.SX2 := TXWN.SX2 + 1;
    TXWN.ARY := TXWN.ARY - 16;
    TXWN.ARX := TXWN.ARX - 8;
    VWCRE(TXWN);
  END;
  bgCre(TXWN,BGWN,1);
end;

procedure CloseTX;
var
  I : integer;
begin
  VWkill(BGWN); 
  FOR I := 1 TO 5 DO
  BEGIN
    TXWN.SY1 := TXWN.SY1 + 16;
    TXWN.SY2 := TXWN.SY2 - 16;
    TXWN.SX1 := TXWN.SX1 + 1;
    TXWN.SX2 := TXWN.SX2 - 1;
    TXWN.ARY := TXWN.ARY + 16;
    TXWN.ARX := TXWN.ARX + 8;
    VWCRE(TXWN);
  END;
  VWKILL(TXWN);
END;

procedure ReadPic(name:STR20;Col :integer;  AR:AreTyp);
var
  PAL : PalTyp;
  I, J, K : integer;
  n : str20;
begin
  with PAL do
  begin
    C[0] := chr(COL);
    C[7] := chr(COL);
    C[11] := chr(COL);
    C[13] := chr(COL);
    C[14] := chr(COL);
    C[15] := chr(376B);
  end;
  Pal. modpal := ar.modpal;
  PlMod(PAL);
  n := name;
  n[20] := chr(0);
  for i := 1 to 16 do
  Wprint(ar.ANUM,1,i*11,n[1]);

end;

procedure Present;
var
  X,Y,I,J,K,L,M,N, ADR, CMD : integer;
  BG, VEWN : WinTyp;
  ST : STR20;
begin
  with TXWN do
  begin
    WNUM := 0;
    AREA := TXAR.ANUM;
    ARY := 0;
    ARX := 0;
    SY1 := 8;
    SY2 := 300;
    SX1 := 2;
    SX2 := 23;
    DEN := 257;
  end;
  VWCre(TXWN);
ST := ' Oepqnm`k|m`_ ]BL   '; ST[13] := chr(177B);
Rwprint(TXar.anum, 7, 11, 142, 17, st);
Rwprint(TXar.anum,-2, 10, 140, 17, st);
CMD := VVV + VBYTE ;
FOR J := 140 downto 2 DO
  HBMOVE(TXAR.ANUM,CMD, J-1, 14, 10, 72, TXAR.ANUM, J, 10);
ST := '    HNM-11/12       ';
Rwprint(TXar.anum, 7, 11, 142, 17, st);
Rwprint(TXar.anum,-2, 10, 140, 17, st);
CMD := VVV + VBYTE ;
FOR J := 140 downto 16 DO
  HBMOVE(TXAR.ANUM,CMD, J-1, 14, 10, 72, TXAR.ANUM, J, 10);

  LDelay(4);
  VWKill(TXWN);
end;

PROCEDURE Color64;
VAR
  W : RECORD
	CODE	: INTEGER;
	ANUM	: INTEGER;
	LINS	: INTEGER;
	SLEN	: INTEGER;
	TAS	: ARRAY [1..300, 1..2] OF INTEGER;
      END;
  MMR, VADR, D,RGB,I,J,K : INTEGER;
  CLINE : array [1..2, 0..16] of integer;
  PALAR : array [1..4] of integer;
  WIN,BG : WinTyp;
  PAL : PalTyp;
  AR : AreTyp;
BEGIN
  W.CODE := 0;
  W.ANUM := 0;
  W.LINS := 56;
  W.SLEN := 34;
  (*$C
	mov	sp, r0
	add	#CLINE, r0
	mov	r0, r1
	bic	#^O160000, R1
	mov	r1, vadr(6)
	ash	#-13., r0
	BIC	#^O177770, R0
	asl	r0
	add	#^O161220, r0
	mov	@r0, mmr(6)
  *)
      IF VADR >= 10000B THEN
      BEGIN
        VADR := VADR AND 7777B;
        MMR := MMR + 20B;
      END;
  PALAR[1] := VM40 + PL1;
  PALAR[2] := VM40 + PL2;
  PALAR[3] := VM40 + PL3;
  PALAR[4] := VM41 + PL3;
 
  WITH W DO
  BEGIN
    FOR I := 0 TO 3 DO
      for j := 1 to 14 do
      BEGIN
        TAS[I*14+J,1] := VADR + 34 * (J DIV 8);
        TAS[I*14+J,2] := MMR + PALAR[I+1]; 
      END;
    A2W.A := @CODE;
    WCSR := A2W.W;
    A2W.W := ANUM;
    AR.ANUM := ANUM;
  END;
  WITH WIN DO
  BEGIN
    AREA := W.ANUM;
    WNUM := 0;
    DEN := 0;
    ARY := 0; ARX := 0;
    SX1 := 5; SX2 := 20;
    SY1 := 32; SY2 := 32 + 220;
  END;
  for K := 1 to 4 do
  begin
    with PAL do
    begin
      J := 1+4*((k +1) mod 2); D := (K div 3) * 2;
      for i := 0 to 15 do
      begin
        RGB := D + ((I mod 4)*2+1)*4 + ((I div 8)*2+j)*32 + (I div 4) mod 2;
        C[I] := chr(RGB);
      end;
      MODPAL := PALAR[K];
    end;
    PlMod(PAL);
  end;
  for I := 1 to 2 do
    for j := 0 to 7 do
    begin
      K := J + (I-1)*8; K := K*16 + K;
      CLINE [I,J*2] := K*256+K; CLINE [I,J*2+1] := CLINE[I,J*2]; 
    end;
  BG.WNUM := 0;
  BgCre(WIN,BG,2);
  VWCre(WIN);
  Ldelay(6);
  TX1 := ' Ankee 128 vbernb   ';
  TX2 := ' m` }jp`me dhqoke_  '; TX2[18] := chr(177B);
  TX3 := ' ndmnbpelemmn       '; 
  OpenTX;
  Ldelay(5);
  CloseTX;
  ArKill(AR);
  VWKILL(BG);
END;

procedure Pictures;
var
  I,J : integer;
  BG : WinTyp;
begin
 
  VEAR.ANUM := 0;
  VEAR.LINS := 212;
  VEAR.SLEN := 32;
  VEAR.AMMR := 0;
 
  GOAR := VEAR;
  SAAR := VEAR;
  CAAR := VEAR;

  VEAR.MODPAL := VM1 + PL2;
  GOAR.MODPAL := VM1 + PL3;
  SAAR.MODPAL := VM1 + PL2;
  CAAR.MODPAL := VM1 + PL3;  
 
  ArGet(VEAR);
  ArGet(GOAR);
  ArGet(SAAR);
  ArGet(CAAR);

  with  VEWN do
  begin
    WNUM := 0;
    DEN := 2*256+2;
    SY1 := 20;
    SY2 := 216;
    SX1 := 6;
    SX2 := 21;
    ARY := 0;
    ARX := 0;
  end;

  GOWN := VEWN;
  SAWN := VEWN;
  CAWN := VEWN;
  VEWN.AREA := VEAR.ANUM;
  GOWN.AREA := GOAR.ANUM;
  SAWN.AREA := SAAR.ANUM;
  CAWN.AREA := CAAR.ANUM;

  VWCRE(CAWN);
  VWCRE(SAWN);
  VWCRE(GOWN);
  VWCRE(VEWN);
  readpic('Window 1   Window 1 ',3  ,VEAR);
  readpic('Window 2   Window 2 ',34B  ,goAR);
  readpic('Window 3   Window 3 ',3  ,saAR);
  readpic('Window 4   Window 4 ',34B  ,caAR);
  WVMove(VEWN,300);
  WVMove(GOWN,300);
  WVMove(SAWN,300);
  WVMove(CAWN,300);
  Ldelay(1);
end;

procedure WinExp;
var
  I,J,K,L,M,N : integer;
  WN : WinTyp;
  WIN : array [1..3] of WinTyp;

procedure PutWin(var WIN : WinTyp; X, Y : integer);
begin
  with WIN do
  begin
    SX2 := X + SX2 - SX1;
    SX1 := X;
    SY2 := Y + SY2 - SY1;
    SY1 := Y;
  end;
  VWCre(WIN);
end;

begin
  ShowVT(Gray);
(* Move Window on Screen *)
  WN := CAWN;
  TX1 := ' Njmn lnfmn         ';
  TX2 := ' oepeley`r|         ';
  TX3 := ' on }jp`ms          '; 
  OpenTX;
  Ldelay(3);
    PutWin(WN,27,0);
    WHMove(WN,-25);
    WVMove(WN,300);
    WVMove(WN,-300);
    VWFore(WN);
    WVMove(WN,300);
    WVMove(WN,-300);
    WHMove(WN,25);
  PutWin(WN,27,300);
  CloseTX;

(* Change Size of Window *)
  WN := VEWN;
  TX1 := ' Lnfmn hglemhr|     ';
  TX2 := ' p`glep             ';
  TX3 := ' njm`               '; 
  OpenTX;
  Ldelay(3);
  VWFore(WN);
  PutWin(WN,6,20);
  for i := 1 to 49 do
  begin
    WN.SY1 := WN.SY1 + 4;
    WN.ARY := WN.ARY + 4;
    VWCre(WN);
  end;
  for i := 1 to 49 do
  begin
    WN.SY1 := WN.SY1 - 4;
    WN.ARY := WN.ARY - 4;
    VWCre(WN);
  end;
  for i := 1 to 49 do
  begin
    WN.SY2 := WN.SY2 - 4;
    VWCre(WN);
  end;
  for i := 1 to 49 do
  begin
    WN.SY2 := WN.SY2 + 4;
    VWCre(WN);
  end;
  for i := 1 to 16 do
  begin
    WN.SX1 := WN.SX1 + 1;
    WN.ARX := WN.ARX + 8;
    VWCre(WN);
  end;
  for i := 1 to 16 do
  begin
    WN.SX1 := WN.SX1 - 1;
    WN.ARX := WN.ARX - 8;
    VWCre(WN);
  end;
  for i := 1 to 16 do
  begin
    WN.SX2 := WN.SX2 - 1;
    VWCre(WN);
  end;
  for i := 1 to 16 do
  begin
    WN.SX2 := WN.SX2 + 1;
    VWCre(WN);
  end;
  PutWin(WN,27,300);
  CloseTX;

(* Zoom Area in Window *)
  WN := GOWN;
  TX1 := ' Lnfmn hglemhr|     ';
  TX2 := ' l`qxr`a oknqjnqrh  ';
  TX3 := ' b njme             '; 
  OpenTX;
  Ldelay(3);
  VWFore(WN);
  PutWin(WN,6,20);
  for i := 2 downto 0 do
  for j := 2 downto 0 do
  begin
    if J = 2 then WN.ARX := 0 else WN.ARX := 44;
    if I = 2 then WN.ARY := 0 else WN.ARY := 72;
    WN.DEN := I * 256 + J;
    VWCre(WN);
    LDelay(2);
  end;
  PutWin(WN,27,300);
  CloseTX;

(* Move Area in Window *)
  WN := VEWN;
  TX1 := ' Lnfmn dbhc`r|      ';
  TX2 := ' oknqjnqr|          ';
  TX3 := ' b njme             '; 
  OpenTX;
  Ldelay(3);
  VWFore(WN);
  WN.DEN := 256 + 1;
  PutWin(WN,6,20);
  WN.ARY := 90;
  for I := 1 to 20 do
  begin
    WN.ARX := WN.ARX + 4;
    VWCre(WN);
    Delay(1800);
  end;
  for I := 1 to 20 do
  begin
    WN.ARX := WN.ARX - 4;
    VWCre(WN);
    Delay(1800);
  end;
  WN.ARY := 0;
  for I := 1 to 100 do
  begin
    WN.ARY := WN.ARY + 1;
    VWCre(WN);
  end;
  for I := 1 to 100 do
  begin
    WN.ARY := WN.ARY - 1;
    VWCre(WN);
  end;
  PutWin(WN,27,300);
  CloseTX;

(* Many Window for Area *)
  WN := SAWN;
  TX1 := ' Lnfmn nrjp{r|      ';
  TX2 := ' meqjnk|jn njnm     ';
  TX3 := ' m` ndms oknqjnqr|  '; 
  OpenTX;
  Ldelay(3);
  with WN do
  begin
    SX1 := SX1 + 2;
    SX2 := SX2 - 2;
    SY1 := SY1 + 16;
    SY2 := SY2 - 16;
    ARX := 16;
    ARY := 16;
  end;
  VWFore(WN);
  PutWin(WN,2,0);
  VWTake(WN);
  for i := 1 to 3 do
  begin
    WIN[I] := WN;
    WIN[I].WNUM := 0;
  end;
  WIN[1].Den := 256 + 1;
  WIN[2].Den := 256 + 0;
  WIN[3].Den := 0 + 0;

  VWCre(WIN[1]); WHMove(WIN[1],13);
  VWCre(WIN[2]); WVMove(WIN[2],180);
  VWCre(WIN[3]); WHMove(WIN[3],13); WVMove(WIN[3],180);
  LDelay(4);
  for i := 1 to 3 do VWKill(WIN[I]);
  PutWin(WN,27,300);
  CloseTX;
HideVT(Gray);
end;

procedure RainbowColors( var PAL :PalTyp);
begin
  with PAL do
  begin
   C[ 0]:=chr(000B); C[ 1]:=chr(036B); C[ 2]:=chr(034B); C[ 3]:=chr(234B);    
   C[ 4]:=chr(334B); C[ 5]:=chr(374B); C[ 6]:=chr(360B); C[ 7]:=chr(340B);    
   C[ 8]:=chr(342B); C[ 9]:=chr(343B); C[10]:=chr(303B); C[11]:=chr(203B);    
   C[12]:=chr(017B); C[13]:=chr(023B); C[14]:=chr(033B); C[15]:=chr(037B);    
  end;
  PlMod(PAL);
end;

procedure PalRot (var PAL :PalTyp;  CNT, DEL :integer);
var
  I, J : integer;
  T : char;
begin
  for J := 1 to CNT do
  begin
    Delay(DEL);
    with PAL do
    begin
      T := C[15];
      for I := 15 downto 2 do
        C[I] := C[I-1];
      C[1] := T;
    end;
    PlMod(PAL);
  end;
end;

PROCEDURE RAINBOW;
VAR
  PAL : PALTYP;
  LW, LY, Y, I, MX, C : INTEGER;
  RX, DX : REAL;
  T : CHAR; 
BEGIN
  RNAR.ANUM := 0;
  RNAR.LINS := 220;
  RNAR.SLEN := 160;
  RNAR.MODPAL := VM41+PL0;
  RNAR.AMMR := 0;
  ARGET(RNAR);
  PAL.MODPAL := RNAR.MODPAL;
  RainbowColors(PAL);
  PlMod(PAL);
  Rwprint(RNAR.ANUM,2,8,10,3  ,'BQE.................');
  Rwprint(RNAR.ANUM,3,8,25,5  ,'VBER@...............');
  Rwprint(RNAR.ANUM,4,8,40,6  ,'P@DSCH..............');
  Rwprint(RNAR.ANUM,5,8,55,2 ,'M@..................');
  Rwprint(RNAR.ANUM,6,8,70,6 ,']JP@ME..............');

  WITH RNWN DO
  BEGIN
    AREA := RNAR.ANUM;
    WNUM := 0;
    DEN := 1*256+0;
    SY1 := 20;
    SY2 := 240;
    SX1 := 3+23;
    SX2 := 23+23;
    ARY := 0;
    ARX := 0;
  END;
  WHMove(RNWN, -23);
  LDelay(2);
  RNWN.DEN := 2*256 + 2;
  VWCRE(RNWN);
  LDelay(2);
  HBMOVE(RNAR.ANUM,VCV,0,220,0,160,0,0,0);
  RX := 0.;
  MX := 152 - 36;
  DX := 6.28/MX;
  LY := 110+TRUNC(80.*SIN(DX));
  FOR I := 0 TO MX DO
  BEGIN
    Y := 110 + TRUNC (80.*SIN(RX));
    C := ((I DIV 2) MOD 15) + 1;
    C := (C*16 + C) * 256 + C*16 + C;
    HBMOVE(RNAR.ANUM,VCV,Y,ABS(Y-LY)+1,I,36,C,0,0);
    LY := Y;
    RX := RX + DX;
  END;
  PalRot (PAL,  100, 1700 );
end;

procedure RandWin;
var
  SEED : 0..65535;
  S256, S32, S01, I, J, K : integer;
  WIN : array [1..6] of WinTyp;
  TWIN : WinTyp;

procedure Rand;
begin
  seed := (seed * 13077 + 6925) mod 32768;
  s256 := (seed div 32) and 377B;
  s32  := seed  and 37B; IF S32 >26 THEN S32 := S32 - 20;
  S01  := (seed div 8192) and 1; 
end;

begin
  seed := 12345;
  TWIN.WNUM := 2;
  VWTake(TWIN);
  WIN[1] := TWIN;
  WIN[2] := VEWN;
  WIN[3] := GOWN;
  WIN[4] := SAWN;
  WIN[5] := CAWN;
  WIN[6] := RNWN;
  for I := 1 to 20 do
    for J := 1 to 6 do
    begin
      Rand;
      TWIN := WIN[J];
      if (I mod 20) < 1 then
      begin
        if S01=0 then
          WVMove(TWIN,200)
        else 
          WHMove(TWIN,19);
      end
      else
      begin 
        with TWIN do
        begin
          K := SX2 - SX1;
          SX1 := S32+2; SX2 := S32 + K;
          K := SY2 - SY1;
          SY1 :=  S256; SY2 := s256 + K; 
        end;
        VWCre(TWIN);
        if S01 = 0 then VWFore(TWIN);
      end;
    end;
  VWCre(WIN[1]);
end;

procedure AllFre;
begin
  ArFre(TXAR);
  ArFre(RNAR);
  ArFre(VEAR);
  ArFre(GOAR);
  ArFre(SAAR);
  ArFre(CAAR);
  ArKill(BGAR);
end;
(*---------------- MAIN PROGRAM --------------------------*)
BEGIN  (* MAIN *)
  TXArea;
  BGArea;
  HideVT( Gray );
  Present;
  color64;
  pictures;
  WinExp;
  RAINBOW;
  ShowVT( Blue);
  RandWin;
  ALLFRE;
END.

