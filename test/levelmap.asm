; mapping functions

include "specscreen.asm"

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

; pointers to screen data
screen_data_ptr 	dw 0
bigtile_data_ptr 	dw 0	
tile_data_ptr 		dw 0
tile_image_data_ptr dw 0

draw_tile_xy dw 0

; Draw a small tile at (B,C)
; A is tile number
draw_small_tile_xy:
	ld bc,(draw_tile_xy)
	
draw_small_tile:
	; calculate tile image addr
	ld ix, (tile_data_ptr)	; make ix point to tile data ; todo: indirection?
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
draw_tile_char MACRO chrNo, offx, offy
	ld d, 0
	ld e,(ix + chrNo)	; get character index
	; add char number * 8
	rl e
	rl d
	rl e
	rl d
	rl e
	rl d
	
	; draw tile character (a) at (b,c)
	ld hl, (tile_image_data_ptr)	; todo: indirection?
	add hl,de	; add offset to image pointer
		
	push bc	; push coords
	; add screen offset
	ld a,offx
	add a,b
	ld b,a
	ld a,offy
	add a,c
	ld c,a
	; write attribute
	call spec_screen_attr_addr
	ld a,(ix + chrNo + 4)
	ld (de),a
	; write char
	call spec_screen_draw_char
	
	pop bc	; pop coords
ENDM
; >>> end macro

	; draw the 4 chars of the tile
	draw_tile_char 0,0,0
	draw_tile_char 1,1,0
	draw_tile_char 2,0,1
	draw_tile_char 3,1,1	

ret

; draw a big tile 
; A: big tile index
draw_big_tile_xy dw 0

draw_big_tile:

	; store coords in memory
	ld bc, (draw_big_tile_xy)
	ld (draw_tile_xy),bc
		
	ld ix, (bigtile_data_ptr)
	
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
	bt_yloop:	; vertical tile loop
	
		push bc	; push y counter
		ld b,4
		bt_xloop:	; horizontal tile loop
		
			ld a,(ix)	; load tile number
			
			push ix
			push bc
			call draw_small_tile_xy
			pop bc
			pop ix
			
			inc ix
			
			ld a,(draw_tile_xy)	; add 2 to x coord
			inc a
			inc a
			ld (draw_tile_xy),a
			
			djnz bt_xloop
			
		ld a,(draw_tile_xy)	; reset x coord
		sub 8
		ld (draw_tile_xy),a
		ld a,(draw_tile_xy+1)
		inc a
		inc a
		ld (draw_tile_xy+1),a
				
		pop bc ; pop y counter
	djnz bt_yloop

ret

; draw a screen made out of big tiles
; A contains screen number
; currently supports 256 screens per level which would use 4k
draw_screen:
	ld bc,0
	ld (draw_big_tile_xy),bc
	
	ld ix, (screen_data_ptr)
	
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
	scr_yloop:	; vertical big tile loop
	
		push bc	; push y counter
		ld b,4
		
		scr_xloop:	; horizontal big tile loop
		
			ld a,(ix)	; load big tile number
			push ix
			push bc
			call draw_big_tile
			pop bc
			pop ix
			inc ix
			
			ld a,(draw_big_tile_xy)	; add 8 to x coord
			add a,8	
			ld (draw_big_tile_xy),a
			
			djnz scr_xloop
		
		; reset x		
		xor a
		ld (draw_big_tile_xy),a
		
		; increase y
		ld a,(draw_big_tile_xy+1)
		add a,6
		ld (draw_big_tile_xy+1),a
				
		pop bc ; pop y counter
	djnz scr_yloop
ret
