; Game Object Code
INCLUDE "specnext.asm"

; Game Object

kNoGameObjects EQU 16	

kGameObjectSize EQU 18	; 18 bytes per object

game_objects:
REPT kNoGameObjects
; Object is 18 bytes
dw 0    ; +0 : 16 bits X (12:4 fixed point)
dw 0    ; +2 : 16 bits Y
dw 0    ; +4 : 16 bits XVel
dw 0    ; +6 : 16 bits YVel
dw NullUpdate    ; +8 : 16 bits update function pointer
db $80    ; +10 :  flags  
	; bit 7 is visible flag
	; bit 3 is X mirror 
	; bit 2 is Y mirror
	; bit 1 is rotate flag 
	; - to match sprite flags
db 2	; +11 sprite image number
db 0,0,0,0,0,0    ; +12 : 6 bytes state data (TBD)

; db user flags
; db state enum
; dw user pointer
; bd misc byte 1
; bd misc byte 2

ENDM

; null update function - does nothing
NullUpdate:
ret

; Function to iterate through game objects & update them
; first update function is executed then velocity is applied
UpdateGameObjects:

ld b, kNoGameObjects
ld ix, game_objects

gobject_update_loop:

    ; call update function
    ld l, (ix + 8)
	ld h, (ix + 9)
	ld de, return_point
	push de
    jp (hl)
	return_point:

	; Apply velocity to game object
    ; update X position
    ld e, (ix + 0)
    ld d, (ix + 1)
    ld l, (ix + 4)
    ld h, (ix + 5)
    add hl,de
    ld (ix + 0),l	; write new x pos back
	ld (ix + 1),h
    
	; update Y position
    ld e, (ix + 2)
    ld d, (ix + 3)
    ld l, (ix + 6)
    ld h, (ix + 7)
    add hl,de
    ld (ix + 2),l	; write new y pos back
	ld (ix + 3),h
	   
    ld de, kGameObjectSize	; jump to next game object
    add ix,de

    djnz gobject_update_loop
RET
	
; function to update the hardware sprites using the game object sprites
UpdateGameObjectSprites:
	
	SelectSprite 0
	ld h, kNoGameObjects
	ld ix, game_objects
	ld bc, kSpriteAttribPort		; write to sprite attribs
gobject_sprite_loop:

	ld e, (ix + 0)	; load 16 bit X into DE
	ld d, (ix + 1)
	; shift DE right 4 places
	rr e
	rr d
	rr e
	rr d
	rr e
	rr d
	rr e
	rr d
	ld a,e	; put shifted down X into A
	out(c), a	; x
	push de
	
	ld e, (ix + 2)	; load 16 bit Y into DE
	ld d, (ix + 3)
	; shift DE right 4 places
	rr e
	rr d
	rr e
	rr d
	rr e
	rr d
	rr e
	rr d
	ld a,e	; put shifted down Y into A
	out(c), a	; y
	
	pop de	; Get X MSB
	ld a,d
	and 1
	ld d,a 	; store back in d
	
	ld a, (ix + 10)	; load flags
	and %10001110	; mask out sprite related flags
	or d		; OR in X MSB
	out(c), a	
	
	ld a, (ix + 11)	; load sprite image number
	and $3F			; mask out bottom 6 bits
	or $80			; make visible
	out(c), a	
	
    ld de, kGameObjectSize	; jump to next game object
    add ix,de

	
	dec h
	jr nz, gobject_sprite_loop

ret

; function to test game object system
GameObjectTest:
	
	SetNextRegister kRegSpriteSystem, 3
	
gobject_test_loop:

	call UpdateGameObjects
	
	halt	; wait for vertical refresh
	call UpdateGameObjectSprites

	; check for space
	ld a,$7F
	in a,($FE)
	rra
	JP C,gobject_test_loop
ret