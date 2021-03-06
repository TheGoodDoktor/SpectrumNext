; Game Object Code

; constants
kNoGameObjects 	EQU 16	
kGameObjectSize EQU 18	; 18 bytes per object

; Globals
;activeGameObjects db 0	; number of active game objects
gFreeGameObjectPtr 	dw gGameObjects	; pointer to free game object
gObjectCreatePtr 	dw 0			; pointer to object creation table

;Game object list
; Uses macro to repeat the data structure
gGameObjects:
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
	; bit 0 is kill flag
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

ld b,kNoGameObjects
ld ix, gGameObjects

gobject_update_loop:

	ld a, (ix + 10)
	bit 0,a	; skip object if it's been killed
	jr nz, skip_object
	
    ; call update function
    ld l, (ix + 8)
	ld h, (ix + 9)
	ld de, return_point
	push bc
	push de	; return point for ret to jump to
    jp (hl)
	return_point:
	pop bc

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
	 	
	skip_object:
	
    ld de, kGameObjectSize	; jump to next game object
    add ix,de

    djnz gobject_update_loop
ret
	
; function to update the hardware sprites using the game object sprites
UpdateGameObjectSprites:
	
	M_SelectSprite 0

	ld h,kNoGameObjects	; counter
	ld ix, gGameObjects
	ld bc, kSpriteAttribPort		; write to sprite attribs
gobject_sprite_loop:

	; skip dead objects
	ld a, (ix + 10)	; load flags
	bit 0,a	; skip object if it's been killed
	jr nz, dead_sprite

	ld e, (ix + 0)	; load 16 bit X into DE
	ld d, (ix + 1)
	; shift DE right 4 places
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	ld a,e	; put shifted down X into A
	out(c), a	; x
	push de
	
	ld e, (ix + 2)	; load 16 bit Y into DE
	ld d, (ix + 3)
	; shift DE right 4 places
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
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
	jr next_sprite
	
dead_sprite:	; clear dead sprites - make invisible
	
	ld a,0
	out(c), a
	out(c), a
	out(c), a
	out(c), a
	
next_sprite:
    ld de, kGameObjectSize	; jump to next game object
    add ix,de

	dec h
	jr nz, gobject_sprite_loop

ret


; Create Object at
; A object type
; BC position (integer)
; object handle is activeGameObjects-1
CreateGameObject:
	
	push af
	
	ld ix,(gFreeGameObjectPtr)
	
	;TODO: if free object is null we have run out of game objects
	
	; update free pointer
	ld hl,gFreeGameObjectPtr
	ld a, (ix)
	ld (hl),a
	inc hl
	ld a, (ix+1)
	ld (hl),a
	
	; Setup coordinates
	
	; X Position
	ld d,0
	ld e,b	; put X into E
	; shift up 4 to shift integer into 12:4 fixed point
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld (ix + 0),e	; store in X coord
	ld (ix + 1),d
	ld (ix + 4),0	; reset velocity
	ld (ix + 5),0
	
	; Y Position
	ld d,0
	ld e,c	; put Y into E
	; shift up 4 to shift integer into 12:4 fixed point
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld (ix + 2),e	; store in X coord
	ld (ix + 3),d
	ld (ix + 6),0	; reset velocity
	ld (ix + 7),0
	
	; set default flags
	ld a,$80
	ld (ix+10),a
	
	; call creation function
	; creation function must have ret instruction at the end
	pop af
	add a,a	; double A to get offset in jump table
	ld d,0
	ld e,a
	push ix
	ld ix,(gObjectCreatePtr)
	add ix,de	; HL points to table entry
	ld l, (ix+0)	; extract pointer into DE
	ld h, (ix+1)
	pop ix
	jp (hl)		; jump to pointer address
ret

; IX points to object
KillGameObject:

	ld hl,(gFreeGameObjectPtr)

	ld (ix+0),l	; point first 2 bytes of object to old free pointer
	ld (ix+1),h

	ld a,1		; set flags of object to be 'killed'
	ld (ix+10),a

	; Update free object pointer
	ld (gFreeGameObjectPtr),ix

ret

; Initialise game object system
; hl points to creation table
InitGameObjectSystem:

	ld (gObjectCreatePtr),hl
	ld ix,gGameObjects
	ld hl,gGameObjects	; point hl to next object
	ld de, kGameObjectSize
	add hl,de
	ld b,kNoGameObjects
	
object_init_loop;
	
	ld (ix+0),l	; point first 2 bytes of object to next one
	ld (ix+1),h
	
	ld a,1		; set flags of object to be 'killed'
	ld (ix+10),a
	
	ld de, kGameObjectSize	; skip to next object
	add hl,de
	add ix,de
	djnz object_init_loop
	
	ld hl,gFreeGameObjectPtr
	ld (hl),gGameObjects
ret

; helper macro to create a game object at a specific position
M_CreateGameObjectAt MACRO _type,_x,_y
	ld a,_type
	ld b,_x
	ld c,_y
	call CreateGameObject
ENDM
