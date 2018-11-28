! From P16BOT.COM
mac p16+p16bot/obj
! From P16RST.COM
mac p16+p16rst/obj
! From P16KBE.COM
mac p16+p16kbe/obj
! From P16HDC.COM
mac p16+p16hdc/obj

! From ??
mac wd
lin wd/map

! From ??
mac vt
lin vt/map

! From P16HLT.COM
mac p16+p16ini+p16hlt/obj

! From P16CAL.COM
mac p16+p16sub+p16cal/obj

! From P16FIS.COM
mac p16+p16fis/obj

! From P16CLK.COM
mac p16+p16clk/obj

! From P16VDC.COM
mac p16+p16vdc/obj

! From P16DBG.COM
mac p16+p16dbg/obj

! From ???
mac p16unp/obj

! ------------------------------------

! From P16P.COM
lin/map:p16p/exe:p16p/prompt
p16bot
p16rst
p16kbe
p16hdc
//
cop/con p16p.sav,wd.sav,vt.sav t.t
ru pl
!del/noq t.t,pl.tmp,p16p.sav
mac p16prc/obj:p16prc
!del p16prc.mac
!@p16b

! From P16B.COM
lin/map:p16/exe:p16/prompt
p16hlt
p16cal
p16fis
p16clk
p16vdc
p16dbg
p16unp
p16prc
//
ty p16.map
