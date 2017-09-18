; Copied from Mike Daily's code 

                opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
                opt             Z80                                                     ; Set z80 mode
                opt             ZXNEXT                                                  ; enable zx next opcodes
               
StackEnd:
                ds      127
StackStart:     db      0

                org     $6100


StartAddress:
; test program to test the various systems
;org $8000
;start:
call RunMapTest
ret 

; system includes
include "specnext.asm"
include "specscreen.asm"
include "controls.asm"
include "levelmap.asm"
include "gameobject.asm"

; game include
include "gameobjects.asm"

; test data includes
include "testmapdata.asm"

; test sprite
gTreeSpriteData:
incbin "tree.spr"

; test function for the map code
RunMapTest:

	; set up pointers to screen
	M_SetTileDataPtr gTestTileData
	M_SetBigTileDataPtr gTestBigTileData
	M_SetTileImageDataPtr gTestTileCharImages
	M_SetScreenDataPtr gTestScreenData

	; Init & play music
	;ld a,2
	;call InitMusic
	
	; upload a sprite
	ld a, 2
	ld hl, gTreeSpriteData
	call UploadSpritePattern
	
	; setup object creation table & initialise game object system
	ld hl, gObjectCreateTable
	call InitGameObjectSystem
	
	; create some test objects
	M_CreateGameObjectAt 2,128,128
	M_CreateGameObjectAt 1,80,80
	
	M_SetNextRegister kRegSpriteSystem, 3	; make sprites visible

	; draw screen 0
	ld a,0
	call DrawScreen
	
	; frame update loop
update_loop:

	call UpdateControls
	call UpdateGameObjects
	
	halt	; wait for vertical refresh
	call UpdateGameObjectSprites

	; check for space pressed
	ld a,$7F
	in a,($FE)
	rra
	jp c,update_loop
	
	; clear up music player - not working
	;ld a,0
	;call InitMusic
ret

; other includes for relocated data (org'ed to other locations)
include "musictest.asm"

end start

