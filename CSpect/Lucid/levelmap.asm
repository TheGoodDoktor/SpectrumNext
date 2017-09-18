; mapping functions

; Map layout

; small tiles 2*2 characters
; 16*12 = 192 bytes per screen

; big tiles 4x3 small tiles (8x6 characters)
; 4 * 4 = 16 bytes per screen

; small (2x2 chars) tile def
; 4 bytes attr - so we can have different coloured tiles of same image
; 2 bytes tile image addr

; big tile (4x3 small tiles)
; 12 bytes small tile def

; screen def 
; 16 bytes big tile defs

; pointers to various data sources required for generating screens
gScreenDataPtr 		dw 0
gBigTileDataPtr 	dw 0	
gTileDataPtr 		dw 0
gTileImageDataPtr 	dw 0

; Macros for setting source data pointers
M_SetTileDataPtr MACRO 
	ld hl,/0
	ld (gTileDataPtr),hl
ENDM

M_SetBigTileDataPtr MACRO
	ld hl,/0
	ld (gBigTileDataPtr),hl
ENDM

M_SetTileImageDataPtr MACRO
	ld hl,/0
	ld (gTileImageDataPtr),hl
ENDM

M_SetScreenDataPtr MACRO
	ld hl,/0
	ld (gScreenDataPtr),hl
ENDM

gDrawTileXY dw 0	; temp store for tile drawing, TODO: try and use stack instead

; Draw a small tile at (B,C)
; A is tile number
DrawSmallTileXY:
	ld bc,(gDrawTileXY)
	
DrawSmallTile:
	; calculate tile image addr
	ld ix, (gTileDataPtr)	; make ix point to tile data ; todo: indirection?
	; add a * 8 (8 bytes per tile)
	ld d,0
	ld e,a
	rl e
	rl d
	rl e
	rl d
	rl e
	rl d
	add ix,de	; ix points to char def

;>>> begin macro
; arg 0 character no
; arg 1 offset x
; arg 2 offset y
M_DrawTileChar macro
	ld d, 0
	ld e,(ix + /0)	; get character index
	; add char number * 8
	rl e
	rl d
	rl e
	rl d
	rl e
	rl d
	
	; draw tile character (a) at (b,c)
	ld hl, (gTileImageDataPtr)	; todo: indirection?
	add hl,de	; add offset to image pointer
		
	push bc	; push coords
	; add screen offset
	ld a,/1
	add a,b
	ld b,a
	ld a,/2
	add a,c
	ld c,a
	; write attribute
	call SpecScreenAttrAddr
	ld a,(ix + /0 + 4)
	ld (de),a
	; write char
	call SpecScreenDrawChar
	
	pop bc	; pop coords
endm
; >>> end macro

	; draw the 4 chars of the tile
	;M_DrawTileChar 0,0,0
	;M_DrawTileChar 1,1,0
	;M_DrawTileChar 2,0,1
	;M_DrawTileChar 3,1,1	

ret

; draw a big tile 
; A: big tile index
gDrawBigTileXY dw 0

DrawBigTile:

	; store coords in memory
	ld bc, (gDrawBigTileXY)
	ld (gDrawTileXY),bc
		
	ld ix, (gBigTileDataPtr)
	
	; 12 bytes per big tile so shift by 8 & 4 and add
	; add a * 8 
	ld d,0
	ld e,a
	rl e
	rl d
	rl e
	rl d
	rl e
	rl d
	add ix,de	; ix points to char def
	; add a *4
	ld d,0
	ld e,a
	rl e
	rl d
	rl e
	rl d
	add ix,de	; ix points to char def

	ld b,3
	@bt_yloop:	; vertical tile loop
	
		push bc	; push y counter
		ld b,4
		@bt_xloop:	; horizontal tile loop
		
			ld a,(ix)	; load tile number
			
			push ix
			push bc
			call DrawSmallTileXY
			pop bc
			pop ix
			
			inc ix
			
			ld a,(gDrawTileXY)	; add 2 to x coord
			inc a
			inc a
			ld (gDrawTileXY),a
			
			djnz @bt_xloop
			
		ld a,(gDrawTileXY)	; reset x coord
		sub 8
		ld (gDrawTileXY),a
		ld a,(gDrawTileXY+1)
		inc a
		inc a
		ld (gDrawTileXY+1),a
				
		pop bc ; pop y counter
	djnz @bt_yloop

ret

; draw a screen made out of big tiles
; A contains screen number
; currently supports 256 screens per level which would use 4k
DrawScreen:
	ld bc,0
	ld (gDrawBigTileXY),bc
	
	ld ix, (gScreenDataPtr)
	
	; 16 bytes per screen
	; add a * 16 
	ld d,0
	ld e,a
	rl e
	rl d
	rl e
	rl d
	rl e
	rl d
	rl e
	rl d
	add ix,de	; ix points to char def
	
	ld b,4
	@scr_yloop:	; vertical big tile loop
	
		push bc	; push y counter
		ld b,4
		
		@scr_xloop:	; horizontal big tile loop
		
			ld a,(ix)	; load big tile number
			push ix
			push bc
			call DrawBigTile
			pop bc
			pop ix
			inc ix
			
			ld a,(gDrawBigTileXY)	; add 8 to x coord
			add a,8	
			ld (gDrawBigTileXY),a
			
			djnz @scr_xloop
		
		; reset x		
		xor a
		ld (gDrawBigTileXY),a
		
		; increase y
		ld a,(gDrawBigTileXY+1)
		add a,6
		ld (gDrawBigTileXY+1),a
				
		pop bc ; pop y counter
	djnz @scr_yloop
ret


