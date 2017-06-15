; Routine for manipulating the spectrum screen

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

; tile character data
; array of 4 character lookups
tile_char_data:
	db 0,0,0,0	; empty tile
	db 1,1,1,1	; solid tile

; bitmap data of tile characters
tile_char_images:
	db 0,0,0,0,0,0,0,0	; empty character
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff	; solid character
	
; Draw a small tile at (B,C)
; A is tile number
draw_small_tile_image:
	; calculate tile image addr
	ld hl, tile_char_data	; make hl point to tile data
	; add a * 4 (4 bytes per tile)
	ld e,0
	ld d,a
	rl d
	rl e
	rl d
	rl e
	add hl,de	; hl points to char def
	push hl		; push tile def

;>>> begin macro
	pop hl		; pop tile def
	ld b,(hl)	; get character index
	inc hl		; inc pointer to tile
	push hl		; push tile def
	
	; draw tile character (a) at (b,c)
	ld hl, tile_char_images
	; add char number * 8
	ld e,0
	ld d,a
	rl d
	rl e
	rl d
	rl e
	rl d
	rl e
	add hl,de	; add offset to image pointer
		
	push bc	; push coords
	push af
	; add screen offset
	ld a,0
	add a,b
	ld b,a
	ld a,0
	add a,c
	ld c,a
	call spec_screen_draw_char
	pop af
	pop bc	; pop coords
; >>> end macro

	ret

