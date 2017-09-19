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
	
; particle struct - 10 bytes
; 0: xpos 8:8 FP
; 2: ypos 8:8 FP
; 4: dx 8:8 FP
; 6: dy 8:8 FP
; 8: life
; 9: flags
kParticleSize equ 10
kNoParticles equ 32

gParticleList:
	ds kParticleSize * kNoParticles
	
gFreeParticlePtr 	dw gParticleList	; pointer to free particle
	
; Initialise Particle System
InitParticles:
	ld ix,gParticleList
	ld hl,gParticleList	+ kParticleSize; point hl to next object
	ld b,kNoParticles - 1
	
@particle_init_loop;
	
	ld (ix+0),l	; point first 2 bytes of object to next one: 
	ld (ix+1),h
	
	ld a,1		; set flags of object to be 'killed'
	ld (ix+10),a
	
	ld de, kParticleSize	; skip to next object
	add hl,de
	add ix,de
	djnz @particle_init_loop
	
	; last particle points to NULL
	ld (ix+0),0
	ld (ix+1),0
	
	ld hl,gFreeParticlePtr
	ld (hl),gParticleList
ret

; Update Particle System
; Iterates through all particles and updates their position etc.
UpdateParticles:
	ld ix, gParticleList
	ld b, kNoParticles
@particleUpdateLoop:

	; skip dead objects
	ld a, (ix + 9)	; load flags
	bit 0,a	; skip particle if it's been killed
	jr nz, @next_particle
	
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
	
	; update life
	ld a, (ix + 8)
	dec a
	jnz next_particle
	
	; kill particle
	ld hl,(gFreeParticlePtr)

	ld (ix+0),l	; point first 2 bytes of object to old free pointer
	ld (ix+1),h

	ld a,1		; set flags of object to be 'killed'
	ld (ix+9),a

	; Update free object pointer
	ld (gFreeParticlePtr),ix
@next_particle
	ld de, kParticleSize	; point to next particle
	add ix,de
	djnz @particleUpdateLoop
	ret

; Draw Particles - does plot/unplot using XOR
DrawParticles:
ret

; Add a Particle - IX points to new particle
AddParticle:
	ld ix,(gFreeParticlePtr)
	
	;TODO: if free object is null we have run out of particles
	
	; update free pointer
	ld hl,gFreeParticlePtr
	ld a, (ix)
	ld (hl),a
	inc hl
	ld a, (ix+1)
	ld (hl),a
	ret
	
; Test Loop for Particle System
TestParticleLoop:

@particleLoop:
	call DrawParticles	; Erase old particles
	call UpdateParticles	; Update particle behaviour
	call DrawParticles
	jr @particleLoop
ret
	
ret