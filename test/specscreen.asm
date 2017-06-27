; Routine for manipulating the spectrum screen



; used to store coords for functions
gXCoord db 0
gYCoord db 0

; get the spectrum screen address for a given coordinate & store in DE
GetSpecScreenAddr:
	
	ld a,(gYCoord)       ; fetch vertical coordinate.
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
	ld a,(gXCoord)       ; x coordinate.
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
SpecScreenCharAddr:
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
SpecScreenDrawChar:
	call SpecScreenCharAddr          ; find screen address for char.
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
SpecScreenAttrAddr:
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

	
