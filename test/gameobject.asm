; Game Object Code

; Game Object

kNoGameObjects EQU 16
kGameObjectSize EQU 18

game_objects:
REPT kNoGameObjects
; Object is 18 bytes
DEFW 0    ; +0 : 16 bits X (12:4 fixed point)
DEFW 0    ; +2 : 16 bits Y
DEFW 0    ; +4 : 16 bits XVel
DEFW 0    ; +6 : 16 bits YVel
DEFW NullUpdate    ; +8 : 16 bits update function pointer
DEFB 0    ; +10 :  flags
DEFB 0,0,0,0,0,0,0    ; +11 : 7 bytes state data (TBD)
ENDM

NullUpdate:
ret

UpdateGameObjects:
LD IX, kNoGameObjects
LD IX, game_objects
gobject_update_loop:

    ; call update function
    LD L, (IX + 8)
	LD H, (IX + 9)
	LD DE, return_point
	push DE
    JP (HL)
return_point:

    ; update X position
    LD DE, (IX + 0)
    LD HL, (IX + 4)
    ADD HL,DE

    ; update Y position
    LD DE, (IX + 2)
    LD HL, (IX + 6)
    ADD HL,DE
	
	; TODO: 
    
    LD HL, kGameObjectSize
    ADD IX,HL
    DJNZ gobject_update_loop
    RET



