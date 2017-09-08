; ************************************************************************
;
;	General equates and macros
;
; ************************************************************************

; Hardware
Kempston_Mouse_Buttons	equ	$FADF
Kempston_Mouse_X	equ	$FBDF
Kempston_Mouse_Y	equ	$FFDF
Mouse_LB		equ	1			; 0 = pressed
Mouse_RB		equ	2
Mouse_MB		equ	4
Mouse_Wheel		equ	$f0

SpriteReg		equ	$57
SpriteShape		equ	$5b



; memory locations
SpriteData	equ	$8000



LoadFile	macro
		ld	hl,\0
		ld	ix,\1
		call	Load
		endm
		
File		macro
		dw	Filesize(\0)
		db	\0
		db	0
		Message "file='",\0,"'  size=",Filesize(\0)
		endm




