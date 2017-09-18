; Copied from Mike Daily's code 

                opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
                opt             Z80                                                     ; Set z80 mode
                opt             ZXNEXT                                                  ; enable zx next opcodes
               
StackEnd:
                ds      127
StackStart:     db      0

                org     $6100


StartAddress:
	call InitParticles
	call TestParticleLoop
	ret
	
; particle struct - 8 bytes
; 0: xpos 12:4 FP
; 2: ypos 12:4 FP
; 4: dx 4:4 FP
; 5: dy 4:4 FP
; 6: life
; 7: flags
kParticleSize equ 8
kNoParticles equ 32

gParticleList:
	ds kParticleSize * kNoParticles

; Particle update funtion
; Iterates through all particles and updates their position etc.
UpdateParticles:
	ld ix, gParticleList
	ld b, kNoParticles
@particleUpdateLoop:
	; update X position
	ld e, (ix + 0)
    ld d, (ix + 1)
    ld l, (ix + 4)
    ld h, 0
    add hl,de
    ld (ix + 0),l	; write new x pos back
	ld (ix + 1),h
    
	; update Y position
    ld e, (ix + 2)
    ld d, (ix + 3)
    ld l, (ix + 5)
    ld h, 0
    add hl,de
    ld (ix + 2),l	; write new y pos back
	ld (ix + 3),h
	

	ld de, kParticleSize	; point to next particle
	add ix,de
	djnz @particleUpdateLoop
	ret

DrawParticles:
ret

