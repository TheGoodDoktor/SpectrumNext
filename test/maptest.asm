org $8000
start:
call run_map_test

; map test functions
include "levelmap.asm"
include "gameobject.asm"


ret 

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
ld a,0
call draw_screen
;ld a,1
;call draw_small_tile_xy
call GameObjectTest
ret

; big tile data
; 4x3
bigtile_data:
	; big tile 0
	db 1,0,0,1
	db 0,1,1,0
	db 1,0,0,1
	
; screen data
; 4 * 4 big tiles
screen_data:
	; screen 0
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0

; todo: 
; level data
; level width in screens
; level height in screens	
; level start screen no

; tile character data
; array of 4 character lookups, 4 attributes
tile_data:
	; tile 0
	db 0,0,0,0	; empty tile
	db $38,$38,$38,$38	; black on white
	; tile 1
	db 1,2,2,1	; solid tile
	db $38,$04,$38,$0f	; random

; bitmap data of tile characters
tile_char_images:
	db 0,0,0,0,0,0,0,0	; empty character
	db $aa,$55,$aa,$55,$aa,$55,$aa,$55	; chessboard character
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	; solid character

include "musictest.asm"
end start

