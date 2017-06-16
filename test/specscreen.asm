; Routine for manipulating the spectrum screen

org $8000
start:
call run_map_test
ret 

; used to store coords for functions
xcoord db 0
ycoord db 0

; get the spectrum screen address for a given coordinate & store in DE
get_spec_screen_addr:
	
	ld a,(ycoord)       ; fetch vertical coordinate.
    ld e,a              ; store that in e.

	; Find line within cell.
	and 7               ; line 0-7 within character square.
	add a,64            ; 64 * 256 = 16384 = start of screen display.
	ld d,a              ; line * 256.

	; Find which third of the screen we're in.
	ld a,e              ; restore the vertical.
	and 192             ; segment 0, 1 or 2 multiplied by 64.
	rrca                ; divide this by 8.
	rrca
	rrca                ; segment 0-2 multiplied by 8.
	add a,d             ; add to d give segment start address.
	ld d,a

	; Find character cell within segment.
	ld a,e              ; 8 character squares per segment.
	rlca                ; divide x by 8 and multiply by 32,
	rlca                ; net calculation: multiply by 4.
	and 224             ; mask off bits we don't want.
	ld e,a              ; vertical coordinate calculation done.

	; Add the horizontal element.
	ld a,(xcoord)       ; x coordinate.
	rrca                ; only need to divide by 8.
	rrca
	rrca
	and 31              ; squares 0 - 31 across screen.
	add a,e             ; add to total so far.
	ld e,a              ; de = address of screen.
	ret

; Return character cell address of block at (b, c) in DE.
; screen size in cells is 32x24
; B : Y Pos
; C	: X Pos
; return address in DE
spec_screen_char_addr:
	ld a,b              ; vertical position.
	and 24              ; which segment, 0, 1 or 2?
	add a,64            ; 64*256 = 16384, Spectrum's screen memory.
	ld d,a              ; this is our high byte.
	ld a,b              ; what was that vertical position again?
	and 7               ; which row within segment?
	rrca                ; multiply row by 32.
	rrca
	rrca
	ld e,a              ; low byte.
	ld a,c              ; add on x coordinate.
	add a,e             ; mix with low byte.
	ld e,a              ; address of screen position in de.
	ret

; Display character hl at (b, c).
; screen size in cells is 32x24
; B : Y Pos
; C	: X Pos
spec_screen_draw_char:
	call spec_screen_char_addr          ; find screen address for char.
	ld b,8              ; number of pixels high.
char0:
	ld a,(hl)           ; source graphic.
	ld (de),a           ; transfer to screen.
	inc hl              ; next piece of data.
	inc d               ; next pixel line.
	djnz char0          ; repeat
	ret

	
; Calculate address of attribute for character at (b, c).
; returns address in DE
; clobbers A,DE
spec_screen_attr_addr:
	ld a,b              ; x position.
	rrca                ; multiply by 32.
	rrca
	rrca
	ld e,a              ; store away in e.
	and 3               ; mask bits for high byte.
	add a,88            ; 88*256=22528, start of attributes.
	ld d,a              ; high byte done.
	ld a,e              ; get x*32 again.
	and 224             ; mask low byte.
	ld e,a              ; put in l.
	ld a,c              ; get y displacement.
	add a,e             ; add to low byte.
	ld e,a              ; hl=address of attributes.
	ret

; set screen attribute
; screen size in cells is 32x24
; B : Y Pos
; C	: X Pos

; Map layout
; screen

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

; Draw a small tile at (B,C)
; A is tile number
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

; draw a big tile at BC
; a big tile index
draw_big_tile:


ret

; >>>> TODO: move to a new file
	
; test function for the map code
run_map_test:

; set up pointers

ld hl,tile_data
ld (tile_data_ptr),hl

ld hl,bigtile_data
ld (bigtile_data_ptr),hl

ld hl,tile_char_images
ld (tile_image_data_ptr),hl

ld hl,screen_data
ld (screen_data_ptr),hl


ld b,10
ld c,10
;ld hl, tile_char_images
;call spec_screen_draw_char
ld a,1
call draw_small_tile

ret

; big tile data
; 4x3
big_tile_data:
	; big tile 0
	db 0,0,0,0
	db 1,1,1,1
	db 0,1,0,1
	
; screen data
; 4 * 4 big tiles
screen_data:
	; screen 0
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0

; tile character data
; array of 4 character lookups, 4 attributes
tile_data:
	; tile 0
	db 0,0,0,0	; empty tile
	db $38,$38,$38,$38	; black on white
	; tile 1
	db 1,2,2,1	; solid tile
	db $38,$04,$38,$0f	; black on white

; bitmap data of tile characters
tile_char_images:
	db 0,0,0,0,0,0,0,0	; empty character
	db $aa,$55,$aa,$55,$aa,$55,$aa,$55	; chessboard character
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	; solid character

end start
