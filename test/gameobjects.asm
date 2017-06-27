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

; object creation table
; list of creation function pointers
gObjectCreateTable:
	dw NullCreate
	dw TestCreate
	
	