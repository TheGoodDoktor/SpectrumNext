; ************************************************************************
;
; 	Utils file - keep all utils variables in this file
;
; ************************************************************************


; ************************************************************************
;
;	Function:	Set current bank **** WILL CHANGE ****
;			This banks in memory from the 2MB Ram to the top bank
;	In:		A = bank to set, paged into $c000
;
; ************************************************************************
SetBank:	push	bc
		ld	bc,$3ffd		; banking port  ***** WILL CHANGE ****
		out	(c),a
		pop	bc
		ret


; ************************************************************************
;
;	Function:	Clear the 256 colour screen to a set colour
;	In:		A = colour to clear to ($E3 makes it transparent)
;
; ************************************************************************
Cls256:
		push	bc
		push	de
		push	hl

		ld	d,a			; byte to clear to
                ld	e,3			; number of blocks
                ld	a,1			; first bank... (bank 0 with write enable bit set)
                
                ld      bc, $123b                
@LoadAll:	out	(c),a			; bank in first bank
                push	af
                
                                
                ; Fill lower 16K with the desired byte
                ld	hl,0
@ClearLoop:	ld	(hl),d
                inc	l
                jr	nz,@ClearLoop
                inc	h
                ld	a,h
                cp	$40
                jr	nz,@ClearLoop

                pop	af			; get block back
                add	a,$40
                dec	e			; loops 3 times
                jr	nz,@LoadAll

                ld      bc, $123b		; switch off background (should probably do an IN to get the original value)
                ld	a,0
                out	(c),a     

                pop	hl
                pop	de
                pop	bc
                ret                          


; ************************************************************************
;
;	Function:	Clear the spectrum attribute screen
;	In:		A = attribute
;
; ************************************************************************
ClsATTR:
		push	hl
		push	bc
		push	de

	        ;ld      a,7
                ld      ($5800),a
                ld      hl,$5800
                ld      de,$5801
                ld      bc,1000
                ldir

                pop	de
                pop	bc
                pop	hl
                ret


; ************************************************************************
;
;	Function:	clear the normal spectrum screen
;
; ************************************************************************
Cls:
		push	hl
		push	bc
		push	de

		xor	a
                ld      ($4000),a
                ld      hl,$4000
                ld      de,$4001
                ld      bc,6143
                ldir

                pop	de
                pop	bc
                pop	hl
                ret



; ************************************************************************
;
;	Function:	Enable the 256 colour Layer 2 bitmap
;
; ************************************************************************
BitmapOn:
                ld      bc, $123b
                ld	a,2
                out	(c),a     
                ret                          

               	
; ************************************************************************
;
;	Function:	Disable the 256 colour Layer 2 bitmap
;
; ************************************************************************
BitmapOff:
                ld      bc, $123b
                ld	a,0
                out	(c),a     
                ret          





; ******************************************************************************
;
;	A  = hex value tp print
;	DE= address to print to (normal specturm screen)
;
; ******************************************************************************
PrintHex:	
		push	bc
		push	hl
		push	af
		ld	bc,HexCharset

		srl	a
		srl	a
		srl	a
		srl	a	
		call	DrawHexCharacter

		pop	af
		and	$f	
		call	DrawHexCharacter
		pop	hl
		pop	bc
		ret


;
; A= hex value to print
;
DrawHexCharacter:	
		ld	h,0
		ld	l,a
		add	hl,hl	;*8
		add	hl,hl
		add	hl,hl
		add	hl,bc	; add on base of character wet

		push	de
		push	bc
		ld	b,8
@lp1:		ld	a,(hl)
		ld	(de),a
		inc	hl		; cab't be sure it's on a 256 byte boundary
		inc	d		; next line down
		djnz	@lp1
		pop	bc
		pop	de
		inc	e
		ret


HexCharset:
		db %00000000	;char30  '0'
		db %00111100
		db %01000110
		db %01001010
		db %01010010
		db %01100010
		db %00111100
		db %00000000
		db %00000000	;char31	'1'
		db %00011000
		db %00101000
		db %00001000
		db %00001000
		db %00001000
		db %00111110
		db %00000000
		db %00000000	;char32	'2'
		db %00111100
		db %01000010
		db %00000010
		db %00111100
		db %01000000
		db %01111110
		db %00000000
		db %00000000	;char33	'3'
		db %00111100
		db %01000010
		db %00001100
		db %00000010
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char34	'4'
		db %00001000
		db %00011000
		db %00101000
		db %01001000
		db %01111110
		db %00001000
		db %00000000
		db %00000000	;char35	'5'
		db %01111110
		db %01000000
		db %01111100
		db %00000010
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char36	'6'
		db %00111100
		db %01000000
		db %01111100
		db %01000010
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char37	'7'
		db %01111110
		db %00000010
		db %00000100
		db %00001000
		db %00010000
		db %00010000
		db %00000000
		db %00000000	;char38	'8'
		db %00111100
		db %01000010
		db %00111100
		db %01000010
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char39	'9'
		db %00111100
		db %01000010
		db %01000010
		db %00111110
		db %00000010
		db %00111100
		db %00000000
		db %00000000	;char41	'A'
		db %00111100
		db %01000010
		db %01000010
		db %01111110
		db %01000010
		db %01000010
		db %00000000
		db %00000000	;char42	'B'
		db %01111100
		db %01000010
		db %01111100
		db %01000010
		db %01000010
		db %01111100
		db %00000000
		db %00000000	;char43	'C'
		db %00111100
		db %01000010
		db %01000000
		db %01000000
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char44	'D'
		db %01111000
		db %01000100
		db %01000010
		db %01000010
		db %01000100
		db %01111000
		db %00000000
		db %00000000	;char45	'E'
		db %01111110
		db %01000000
		db %01111100
		db %01000000
		db %01000000
		db %01111110
		db %00000000
		db %00000000	;char46	'F'
		db %01111110
		db %01000000
		db %01111100
		db %01000000
		db %01000000
		db %01000000
		db %00000000






; ******************************************************************************
; 
; Function:	ReadMouse  ***** Not verified on real machine yet *****
;		This is probably wrong, but I'll need it on a real machine 
;		to test - along with a PS2 mouse....err...
;
;		uses bc,a
; ******************************************************************************
ReadMouse:
		ld	bc,Kempston_Mouse_Buttons
		in	a,(c)
		ld	(MouseButtons),a

		ld	bc,Kempston_Mouse_X
		in	a,(c)
		ld	(MouseX),a

		ld	bc,Kempston_Mouse_Y
		in	a,(c)
		ld	(MouseY),a

		ret

MouseButtons	db	0
MouseX		db	0
MouseY		db	0



; ******************************************************************************
; 
; Function:	Upload a set of sprites
; In:		E = sprite shapre to start at
;		D = number of sprites
;		HL = shape data
;
; ******************************************************************************
UploadSprites
		; Upload sprite graphics
                ld      a,e		; get start shape
                ld	e,0		; each pattern is 256 bytes
@AllSprites:               
                ; select pattern 2
                ld      bc, $303B
                out     (c),a

                ; upload ALL sprite sprite image data
                ld      bc, SpriteShape
@UpLoadSprite:           
                ;ld      a,(hl)		; 7
                ;out     (c),a		; 12
                ;inc     hl		; 4 = 23                
                outi			; port=(hl), hl++, b--
                inc	b		; 4 = 20

                dec     de
                ld      a,d
                or      e               
                jr      nz, @UpLoadSprite

                ret

