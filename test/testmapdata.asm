; map test data

; big tile data
; 4x3
gTestBigTileData:
	; big tile 0
	db 1,0,0,1
	db 0,1,1,0
	db 1,0,0,1
	
; screen data
; 4 * 4 big tiles
gTestScreenData:
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
gTestTileData:
	; tile 0
	db 0,0,0,0	; empty tile
	db $38,$38,$38,$38	; black on white
	; tile 1
	db 1,2,2,1	; solid tile
	db $38,$04,$38,$0f	; random

; bitmap data of tile characters
gTestTileCharImages:
	db 0,0,0,0,0,0,0,0	; empty character
	db $aa,$55,$aa,$55,$aa,$55,$aa,$55	; chessboard character
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	; solid character