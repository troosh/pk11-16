(**********************************************)
(*                                            *)
(*   pristykowaw  |tot  modulx  k    swoej    *)
(*   programme, wy  polu~ite   wozmovnostx    *)
(*   rabotatx s diskami po prqmymu dostupu    *)
(*                                            *)
(*   -------------------------------------    *)
(*                                            *)
(*   BY COMBINING  THIS MODULE  WITH  YOUR    *)
(*   PROGRAM  YOU WILL OBTAIN  THE  DIRECT    *)
(*   ACCESS     TO      DISK         FILES    *)
(*                                            *)
(**********************************************)

CONST
  DATALENG = 512;  (* LEN OF DATA IN BYTES *)
  DATANUMBER = 1;  (* NUMBER OF DATA RECORDS PER BUFFER *)

TYPE
  DATARECORD = ARRAY [0..255] OF INTEGER;

  RANFILE=RECORD
            CASE INTEGER OF
              1: (F : FILE OF DATARECORD);
              2: (POINT,MODE,BLOCK,BUFFER,WORDCOUNT,WAITFLAG,IOSTATUS:INTEGER);
            END;

  PROCEDURE RANIO(VAR RFILE:RANFILE;I:INTEGER);
    VAR  K:INTEGER;
  BEGIN
    RFILE.IOSTATUS := RFILE.IOSTATUS AND 077777B;
    K:=I DIV DATANUMBER;
    IF K#(RFILE.BLOCK-1) THEN BEGIN
      IF (RFILE.MODE AND 400B)#0  THEN BEGIN
        RFILE.BLOCK:=RFILE.BLOCK-1;
        RFILE.POINT:=RFILE.BUFFER+512;
        PUT(RFILE.F)
      END;
      RFILE.BLOCK:=K;
      RFILE.MODE:=RFILE.MODE AND 177377B;
      RFILE.POINT:=RFILE.BUFFER+512;
      GET(RFILE.F);
    END;
    RFILE.POINT:=RFILE.BUFFER+(I MOD DATANUMBER)*DATALENG
  END(*RANIO*);

  PROCEDURE SEEK(VAR RFILE:RANFILE;VAR R:DATARECORD;I:INTEGER);
  BEGIN
    RANIO(RFILE,I);
    R:=RFILE.F^
  END(*SEEK*);

  PROCEDURE DEPOSIT(VAR RFILE:RANFILE;VAR R:DATARECORD;I:INTEGER);
  BEGIN
    RANIO(RFILE,I);
    RFILE.F^:=R;
    RFILE.MODE:=RFILE.MODE OR 400B;
  END(*DEPOSIT*);

  PROCEDURE CLOSERANDOMFILE(VAR RFILE:RANFILE);
  BEGIN
    IF (RFILE.MODE AND 400B)#0  THEN BEGIN
      RFILE.POINT:=RFILE.BUFFER+512;
      RFILE.BLOCK:=RFILE.BLOCK-1;
      GET(RFILE.F);
      RFILE.MODE:=RFILE.MODE AND 177377B;
    END;
    CLOSE(RFILE.F)
  END(*CLOSERANDOMFILE*);
