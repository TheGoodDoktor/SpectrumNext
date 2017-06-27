; game object definitions & code

; null creation function
NullCreate:
ret

; test creation function
TestCreate:
	; set velocity
	ld (ix + 4), 1
	ld (ix + 6), 1
   
	; set update function
	ld hl, TestUpdate
	ld (ix + 8), l
	ld (ix + 9), h
	
	; set sprite image
	ld (ix+11), 2
ret

; test update function
TestUpdate:
ret

; controllable sprite
ControllableSpriteUpdate:
	; read controls & respond accordingly
	ld bc,0	; vel
	
	ld a,(gControlCurVal)
	bit 0,a	; right
	jr z, check_left
	ld bc, 16	; set xvel
check_left:
	bit 1,a	; left
	jr z, check_down
	ld bc, -16	; set xvel
check_down:

	; write in xvel
    ld (ix + 4),c
    ld (ix + 5),b
	ld bc, 0	; reset vel

	bit 2,a	; down
	jr z, check_up
	ld bc, 16
check_up:
	bit 3,a	; up
	jr z, check_fire
	ld bc, -16
check_fire:
	; write in yvel
    ld (ix + 6),c
    ld (ix + 7),b

ret

ControllableSpriteCreate:

	; set update function
	ld hl, ControllableSpriteUpdate
	ld (ix + 8), l
	ld (ix + 9), h

	; set sprite image
	ld (ix+11), 2

ret

; object creation table
; list of creation function pointers
gObjectCreateTable:
	dw NullCreate
	dw TestCreate
	dw ControllableSpriteCreate
	
	