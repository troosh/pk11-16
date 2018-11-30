const	max	= 15000;
	lx0	= 16;
	lx1	= 64;
	lx2	= 128;
	lx3	= 256;
	lx4	= 512;
	lx5	= 2048;
	lx6	= 8192;

type	word	= 0..65535;
	buf	= array[0..max]of word;

var inp,out:file of integer;
lst:text;
a,a0,b,c,d,e,i,j,k,l,m,n,s,w:integer;
mb,nb,fl,ip,wp,ex,ex0,mx,me:integer;
xl,xl0,xl1,xl2,xl3,xl4,xl5,xl6:integer;
xr,xr0,xr1,xr2,xr3,xr4,xr5,xr6,xr7:integer;
xa,xa0,xa1,xa2,xa3,xa4,xa5,xa6,xa7:integer;
xw0,xw1,xw2:integer;

r:real;
name:array[1..16]of char;
q:buf;
(*------------------------------------------------*)
procedure putx(n,w:word);
begin
if (n=0) or (n>16) then writeln('*****',n);
(*$C				;
.print q
.enabl lsb			;
	mov	n(sp),	r1	;
	mov	w(sp),	r0	;
	mov	#16,	1$	;
	sub	r1,	1$	;
	ash	(pc)+,	r0	;
1$:	.word	0		;
3$:				;
	rol	r0		;
	ror	(pc)+		;
5$:	.word	^O100000	;
	bcc	10$		;
	inc	wp(r5)		;
	mov	r0,	8$	;
	mov	r1,	9$	;
	mov	5$,	w(sp)	;
*)
	out^:=w;put(out);
(*$C
	mov	(pc)+,	r0	;
8$:	.word	0
	mov	(pc)+,	r1	;
9$:	.word	0
	mov	#^O100000,5$	;
10$:	sob	r1,	3$	;
.dsabl lsb			;
*)
end;

(*---------------------------------------------------*)
procedure fnd(a:word;var d,n:word);
begin
(*$C	;------------------------
	clr	@n(sp)		;
	mov	#q,	r0	;
	add	r5,	r0	;
	mov	r0,	12$	;
	add	a(sp),	r0	;
	add	a(sp),	r0	;
	mov	r0,	r1	;
	mov	r0,	r2	;
	mov	(r0),	r4	;
;--------------------------------
10$:
	cmp	r4,	-(r1)
	beq	15$
	cmp	r4,	-(r1)
	beq	15$
	cmp	r4,	-(r1)
	beq	15$
	cmp	r4,	-(r1)
	beq	15$
	cmp	(pc)+,	r1
12$:	.word	0
	bcs	10$
	br	99$

15$:
	cmp	12$,	r1
	bcc	99$
	mov	r1,	r3
18$:
	cmp	(r0)+,	(r1)+
	beq	18$
20$:
	sub	r2,	r0
	asr	r0
	dec	r0
	cmp	@n(sp), r0
	bcc	30$
	mov	r0,	@n(sp)
	mov	r2,	r0
	sub	r3,	r0
	asr	r0
	dec	r0
	mov	r0,	@d(sp)
30$:
	mov	r2,	r0
	mov	r3,	r1
	br	10$
99$:				;
;-------------------------------
*)
end;

(*---------------------------------------------------*)

procedure wa(a:word);
var n,c,m:integer;
begin
xa:=xa+1;
if a<lx0 then begin
 n:=2; c:=0;  m:=4;  xa0:=xa0+1 end else
if a<lx0+lx1 then begin
 n:=3; c:=2;  m:=6;  xa1:=xa1+1; a:=a-lx0 end else
if a<lx0+lx1+lx2 then begin
 n:=3; c:=3;  m:=7;  xa2:=xa2+1; a:=a-(lx0+lx1) end else
if a<lx0+lx1+lx2+lx3 then begin
 n:=3; c:=4;  m:=8;  xa3:=xa3+1; a:=a-(lx0+lx1+lx2) end else
if a<lx0+lx1+lx2+lx3+lx4 then begin
 n:=3; c:=5;  m:=9;  xa4:=xa4+1; a:=a-(lx0+lx1+lx2+lx3) end else
if a<lx0+lx1+lx2+lx3+lx4+lx5 then begin
 n:=3; c:=6;  m:=11; xa5:=xa5+1; a:=a-(lx0+lx1+lx2+lx3+lx4) end else
if a<lx0+lx1+lx2+lx3+lx4+lx5+lx6 then begin
 n:=3; c:=7;  m:=13; xa6:=xa6+1; a:=a-(lx0+lx1+lx2+lx3+lx4+lx5) end else
			writeln('***************',a);
 putx(n,c);putx(m,a)
end;
(*---------------------------------------------------*)
procedure wa0(a:word);
const	lx0	=    4;
	lx1	=   12;
	lx2	=  128;
	lx3	= 8192;
var n,c,m:integer;
begin
xa:=xa+1;
if a<lx0 then begin
 c:=0;	m:=2;  n:=1; xa0:=xa0+1
end else
if a<lx0+lx1 then begin
 c:=2;	m:=4;  n:=2; xa1:=xa1+1; a:=a-lx0;
end else
if a<lx0+lx1+lx2 then begin
 c:=6;	m:=7;  n:=3; xa2:=xa2+1; a:=a-(lx0+lx1)
end else
if a<lx0+lx1+lx2+lx3 then begin
 c:=7;	m:=13; n:=3; xa3:=xa3+1; a:=a-(lx0+lx1+lx2)
end else writeln('***************',a);
putx(n,c); putx(m,a);
end;
(*---------------------------------------------------*)
procedure rept0(n:integer);
begin
 xr:=xr+1;
 if n =1 then begin			  xr0:=xr0+1 end else
 if n =2 then begin wa0(0);		  xr1:=xr1+1 end else
 if n <6 then begin putx(6,41+n);	  xr2:=xr2+1 end else
	      begin putx(6,47); wa0(n-6); xr3:=xr3+1 end;
end;
(*---------------------------------------------------*)
procedure len(n:integer);
begin
 xl:=xl+1;
 if n =  2 then begin putx(4,     6);   xl0:=xl0+1 end else
 if n <  9 then begin putx(7,    53+n); xl1:=xl1+1 end else
 if n < 37 then begin putx(11,  983+n); xl2:=xl2+1 end else
 if n <101 then begin putx(15,16283+n); xl3:=xl3+1 end else
		writeln('>>>>>>',n);
end;
(*---------------------------------------------------*)
procedure stclr;
begin
xl:=0;xl0:=0;xl1:=0;xl2:=0;xl3:=0;xl4:=0;xl5:=0;xl6:=0;
xr:=0;xr0:=0;xr1:=0;xr2:=0;xr3:=0;xr4:=0;xr5:=0;xr6:=0;xr7:=0;
xa:=0;xa0:=0;xa1:=0;xa2:=0;xa3:=0;xa4:=0;xa5:=0;xa6:=0;xa7:=0;
xw0:=0;xw1:=0;xw2:=0;
end;
(*---------------------------------------------------*)
procedure stprn;
begin
writeln(ex,wp,xw0,xw1,xw2);
writeln(xl,' ---',xl0,xl1,xl2,xl3,xl4,xl5,xl6);
writeln(xr,' ---',xr0,xr1,xr2,xr3,xr4,xr5,xr6,xr7);
writeln(xa,' ---',xa0,xa1,xa2,xa3,xa4,xa5,xa6,xa7);
end;
(*---------------------------------------------------*)
procedure putw(w:word);
const
 mb13=160000B;
begin
if (w & mb13)=0 then  begin putx(3,2);putx(13,w);xw0:=xw0+1 end else
                      begin putx(2,0);putx(16,w);xw1:=xw1+1 end;
end;
(*---------------------------------------------------*)
(*---------------------------------------------------*)
(*---------------------------------------------------*)
begin
wp:=0;ex:=-1;
name:='t.t             ';
write(':: t.t ');
(*
  readln(name);
*)
reset(inp,name);
rewrite(out,'pl.tmp');
(*---------------------------------------------------*)
ex0:=0;
repeat
 if inp^<>0 then begin ex:=ex+1; q[ex]:=inp^ end;
 get(inp); ex0:=ex0+1;
until eof(inp);
close(inp);
stprn;
putx(16,ex0); putx(16,ex+1);
writeln(ex0,ex+1);
(*---------------------------------------------------*)
stclr;
ip:=0;
repeat
fnd(ip,d,n);
if n=0 then
begin  putw(q[ip]); ip:=ip+1; xl4:=xl4+1 end  else
 begin
  if n=1 then begin putx(1,1); wa(d); xl5:=xl5+1 end 
         else begin len(n);    wa(d); xl6:=xl6+n end;
  ip:= ip+n;
  if n>5 then writeln(ip,wp,d,n);
 end;
until ip>ex;
stprn;
(*---------------------------------------------------*)
reset(inp,name); ex:=-1; 
repeat
a:=ex;
while (not eof(inp)) & (inp^<>0) do
begin
 ex:=ex+1; q[ex]:=inp^ ; get(inp)
end;
a:=ex-a; n:=0;
while (not eof(inp)) & (inp^=0) do
begin
 n:=n+1; get(inp)
end;
if n<>0 then begin wa0(a); rept0(n) end;
write(ex,chr(15B));
until eof(inp);
close(inp);
stprn;
(*---------------------------------------------------*)
writeln('--------',ex0,me,wp,wp/ex0:10:4);
putx(16,0);
close(out);
reset(inp,'pl.tmp');
rewrite(lst,'p16prc.mac');

writeln(lst,'prc$$$::');
for i:=0 to wp do
begin
 if (i mod 8)=0 then write(lst,'.word');
 write(lst,chr(11B),inp^:-6);
 get(inp);
 if ((i mod 8)<7) and (i<>wp) then write(lst,',');
 if (i mod 8)=7 then writeln(lst);
end;
writeln(lst);
writeln(lst,'.print .-prc$$$');
writeln(lst,'.end');
close(lst);
end.




