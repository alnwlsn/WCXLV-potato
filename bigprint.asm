org 0x6000
start1:
    call beep2
	ld bc,0x3d02 
	ld de,S2
	call bigPrint
	ld bc,0x3e02 
	ld de,S3
	call bigPrint
	ld bc,0x3f02 
	ld de,S4
	call bigPrint
	ret

start2: ;call from BASIC (use USR(stringlocation))
	call 0x0a7f
	ld bc,0x3d82 ;SCREEN CENTER
	ld d,h
	ld e,l
	push de
	push bc
	call beep2
	pop bc
	pop de
	call bigPrint
	ret

start3:
	call beep
	ret

bigPrint: ;prints a string at de to screen at bc. String must be null terminated.
	ld a,(de)
	cp 0
	jr z,bigPrintLoopEnd
	push bc
	pop hl
	call letter
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc bc
	inc de
	jr bigPrint
	bigPrintLoopEnd:	
		ret
	
letter: ;at position hl on screen, print character a in big font, using graphics characters
	push bc
	push de
	ld (destination),hl
	and 0b00111111 ;a is now 0-63
	ld hl,font
	ld b,h
	ld c,l
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl ;bc = 8*a
	add hl,bc ;hl = font+8*a 
	dec hl
	ld (fontpointer),hl
	ld b,3
	nineLines:
		ld hl,(fontpointer) ;got it backwards, so a hacky fix
		inc hl
		inc hl
		inc hl
		ld (fontpointer),hl
		push bc
		ld b,3
		gcloop: ;loop 3 times down loop for one graphics char
			push bc ;loop counter
			ld hl,(fontpointer)
			call lineOrer
			pop bc ;loop counter
			ld hl,(fontpointer)
			dec hl
			ld (fontpointer),hl
			djnz gcloop
		pop bc
		push bc
		ld a,1
		cp b
		jr nz, line3skip
			ld hl,scratchpad
			ld b,6
			gcloop3: ;clear out the 9th line, we aren't using it
				ld a,0x0f
				and (hl)
				ld (hl),a
				inc hl
				djnz gcloop3
		line3skip:
		ld hl,(fontpointer)
		inc hl
		inc hl
		inc hl
		ld (fontpointer),hl
		call scratch2Screen
		pop bc
		djnz nineLines
	call scratch2Screen
	pop de
	pop bc
	ret

lineOrer: ;shifts graphics blocks down char, then copies line info at HL to top of char cell, for one line (6 chars)
	ld a,(hl)
	rlca
	ld d,a
	ld hl,scratchpad
	ld b,6
	lineloop:
	ld a,d ;font info
	and 1
	ld c,a 
	add a,a
	add a,c
	ld c,a
	ld a,(hl)
	add a,a
	add a,a
	add a,c
	ld (hl),a
	inc hl
	ld a,d
	rlca
	ld d,a
	djnz lineloop
	ret

scratch2Screen: ;copy scratchpad to screen; increment screen pointer down a char
	ld hl,scratchpad
	ld b,6
	lineloop4:
	ld a,0x80
	or (hl)
	ld (hl),a
	inc hl
	djnz lineloop4
	ld hl,(destination)
	ld d,h
	ld e,l
	ld hl,scratchpad
	ld bc,0x0006
	ldir
	ld hl,(destination)
	ld a,64 ;add 64 to go down a line
	add a,l ;A = A+L ;add a to hl
	ld l,a  ;L = A+L
	adc a,h ;A = A+L+H+carry
	sub l   ;A = H+carry
	ld  h,a ;H = H+carry
	ld (destination),hl
	;scratchpadZero:
	ld hl,scratchpad
	ld b,6
	scratchpadZeroLoop:
	xor a
	ld (hl),a
	inc hl
	djnz scratchpadZeroLoop
	ret

beep: ;1KHz short beep
	ld de,200
	beeplooploop: ;26
		ld a,2;
		out (0xff),a
		call beepwavwait
		ld a,1
		out (0xff),a
		call beepwavwait
		dec de
		ld a,d
		or e
		jr nz,beeplooploop
	ld a,0
	out (0xff),a
	ret
	beepwavwait: ;waits for 1/2 1khz cycle
		ld b,136
		beepwavwaitloop:
			djnz beepwavwaitloop ;13
		ret

beep2: ;2KHz short beep
	ld de,400
	beeplooploop2: ;26
		ld a,2
		out (0xff),a
		call beepwavwait2
		ld a,1
		out (0xff),a
		call beepwavwait2
		dec de
		ld a,d
		or e
		jr nz,beeplooploop2
	ld a,0
	out (0xff),a
	ret
	beepwavwait2: ;waits for 1/2 1khz cycle
		ld b,68
		beepwavwaitloop2:
			djnz beepwavwaitloop2 ;13
		ret
	

font:
db 0x38, 0x44, 0x04, 0x34, 0x54, 0x54, 0x38, 0x00, 0x10, 0x28, 0x44, 0x44, 0x7C, 0x44, 0x44, 0x00, 0x78, 0x24, 0x24, 0x38, 0x24, 0x24, 0x78, 0x00, 0x38, 0x44, 0x40, 0x40, 0x40, 0x44, 0x38, 0x00, 0x78, 0x24, 0x24, 0x24, 0x24, 0x24, 0x78, 0x00, 0x7C, 0x40, 0x40, 0x78, 0x40, 0x40, 0x7C, 0x00, 0x7C, 0x40, 0x40, 0x78, 0x40, 0x40, 0x40, 0x00, 0x3C, 0x40, 0x40, 0x4C, 0x44, 0x44, 0x3C, 0x00, 0x44, 0x44, 0x44, 0x7C, 0x44, 0x44, 0x44, 0x00, 0x7C, 0x10, 0x10, 0x10, 0x10, 0x10, 0x7C, 0x00, 0x04, 0x04, 0x04, 0x04, 0x04, 0x44, 0x38, 0x00, 0x44, 0x48, 0x50, 0x60, 0x50, 0x48, 0x44, 0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x7C, 0x00, 0x44, 0x6C, 0x54, 0x54, 0x44, 0x44, 0x44, 0x00, 0x44, 0x64, 0x54, 0x4C, 0x44, 0x44, 0x44, 0x00, 0x38, 0x44, 0x44, 0x44, 0x44, 0x44, 0x38, 0x00, 0x78, 0x44, 0x44, 0x78, 0x40, 0x40, 0x40, 0x00, 0x38, 0x44, 0x44, 0x44, 0x54, 0x48, 0x34, 0x00, 0x78, 0x44, 0x44, 0x78, 0x50, 0x48, 0x44, 0x00, 0x38, 0x44, 0x40, 0x38, 0x04, 0x44, 0x38, 0x00, 0x7C, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x38, 0x00, 0x44, 0x44, 0x44, 0x28, 0x28, 0x10, 0x10, 0x00, 0x44, 0x44, 0x44, 0x54, 0x54, 0x6C, 0x44, 0x00, 0x44, 0x44, 0x28, 0x10, 0x28, 0x44, 0x44, 0x00, 0x44, 0x44, 0x28, 0x10, 0x10, 0x10, 0x10, 0x00, 0x7C, 0x04, 0x08, 0x10, 0x20, 0x40, 0x7C, 0x00, 0x10, 0x38, 0x54, 0x10, 0x10, 0x10, 0x10, 0x00, 0x10, 0x10, 0x10, 0x10, 0x54, 0x38, 0x10, 0x00, 0x00, 0x10, 0x20, 0x7C, 0x20, 0x10, 0x00, 0x00, 0x00, 0x10, 0x08, 0x7C, 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x10, 0x00, 0x28, 0x28, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x28, 0x7C, 0x28, 0x7C, 0x28, 0x28, 0x00, 0x10, 0x3C, 0x50, 0x38, 0x14, 0x78, 0x10, 0x00, 0x60, 0x64, 0x08, 0x10, 0x20, 0x4C, 0x0C, 0x00, 0x20, 0x50, 0x50, 0x20, 0x54, 0x48, 0x34, 0x00, 0x0C, 0x0C, 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x08, 0x10, 0x20, 0x20, 0x20, 0x10, 0x08, 0x00, 0x20, 0x10, 0x08, 0x08, 0x08, 0x10, 0x20, 0x00, 0x10, 0x54, 0x38, 0x7C, 0x38, 0x54, 0x10, 0x00, 0x00, 0x10, 0x10, 0x7C, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18, 0x10, 0x00, 0x00, 0x00, 0x7C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18, 0x00, 0x00, 0x04, 0x08, 0x10, 0x20, 0x40, 0x00, 0x00, 0x38, 0x44, 0x4C, 0x54, 0x64, 0x44, 0x38, 0x00, 0x10, 0x30, 0x10, 0x10, 0x10, 0x10, 0x38, 0x00, 0x38, 0x44, 0x04, 0x38, 0x40, 0x40, 0x7C, 0x00, 0x38, 0x04, 0x04, 0x18, 0x04, 0x04, 0x38, 0x00, 0x08, 0x18, 0x28, 0x48, 0x7C, 0x08, 0x08, 0x00, 0x7C, 0x40, 0x78, 0x04, 0x04, 0x44, 0x38, 0x00, 0x18, 0x20, 0x40, 0x78, 0x44, 0x44, 0x38, 0x00, 0x7C, 0x04, 0x08, 0x10, 0x20, 0x40, 0x40, 0x00, 0x38, 0x44, 0x44, 0x38, 0x44, 0x44, 0x38, 0x00, 0x38, 0x44, 0x44, 0x3C, 0x04, 0x08, 0x30, 0x00, 0x00, 0x30, 0x30, 0x00, 0x30, 0x30, 0x00, 0x00, 0x00, 0x30, 0x30, 0x00, 0x30, 0x30, 0x20, 0x40, 0x08, 0x10, 0x20, 0x40, 0x20, 0x10, 0x08, 0x00, 0x00, 0x00, 0x7C, 0x00, 0x7C, 0x00, 0x00, 0x00, 0x40, 0x20, 0x10, 0x08, 0x10, 0x20, 0x40, 0x00, 0x38, 0x44, 0x04, 0x08, 0x10, 0x00, 0x10, 0x00
;db 0x38, 0x44, 0x04, 0x34, 0x54, 0x54, 0x38, 0x00, 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0xf0, 0x0f, 0x78, 0x24, 0x24, 0x38, 0x24, 0x24, 0x78, 0x00, 0x38, 0x44, 0x40, 0x40, 0x40, 0x44, 0x38, 0x00, 0x78, 0x24, 0x24, 0x24, 0x24, 0x24, 0x78, 0x00, 0x7C, 0x40, 0x40, 0x78, 0x40, 0x40, 0x7C, 0x00, 0x7C, 0x40, 0x40, 0x78, 0x40, 0x40, 0x40, 0x00, 0x3C, 0x40, 0x40, 0x4C, 0x44, 0x44, 0x3C, 0x00, 0x44, 0x44, 0x44, 0x7C, 0x44, 0x44, 0x44, 0x00, 0x7C, 0x10, 0x10, 0x10, 0x10, 0x10, 0x7C, 0x00, 0x04, 0x04, 0x04, 0x04, 0x04, 0x44, 0x38, 0x00, 0x44, 0x48, 0x50, 0x60, 0x50, 0x48, 0x44, 0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x7C, 0x00, 0x44, 0x6C, 0x54, 0x54, 0x44, 0x44, 0x44, 0x00, 0x44, 0x64, 0x54, 0x4C, 0x44, 0x44, 0x44, 0x00, 0x38, 0x44, 0x44, 0x44, 0x44, 0x44, 0x38, 0x00, 0x78, 0x44, 0x44, 0x78, 0x40, 0x40, 0x40, 0x00, 0x38, 0x44, 0x44, 0x44, 0x54, 0x48, 0x34, 0x00, 0x78, 0x44, 0x44, 0x78, 0x50, 0x48, 0x44, 0x00, 0x38, 0x44, 0x40, 0x38, 0x04, 0x44, 0x38, 0x00, 0x7C, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x38, 0x00, 0x44, 0x44, 0x44, 0x28, 0x28, 0x10, 0x10, 0x00, 0x44, 0x44, 0x44, 0x54, 0x54, 0x6C, 0x44, 0x00, 0x44, 0x44, 0x28, 0x10, 0x28, 0x44, 0x44, 0x00, 0x44, 0x44, 0x28, 0x10, 0x10, 0x10, 0x10, 0x00, 0x7C, 0x04, 0x08, 0x10, 0x20, 0x40, 0x7C, 0x00, 0x10, 0x38, 0x54, 0x10, 0x10, 0x10, 0x10, 0x00, 0x10, 0x10, 0x10, 0x10, 0x54, 0x38, 0x10, 0x00, 0x00, 0x10, 0x20, 0x7C, 0x20, 0x10, 0x00, 0x00, 0x00, 0x10, 0x08, 0x7C, 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x00, 0x10, 0x00, 0x28, 0x28, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x28, 0x7C, 0x28, 0x7C, 0x28, 0x28, 0x00, 0x10, 0x3C, 0x50, 0x38, 0x14, 0x78, 0x10, 0x00, 0x60, 0x64, 0x08, 0x10, 0x20, 0x4C, 0x0C, 0x00, 0x20, 0x50, 0x50, 0x20, 0x54, 0x48, 0x34, 0x00, 0x0C, 0x0C, 0x08, 0x10, 0x00, 0x00, 0x00, 0x00, 0x08, 0x10, 0x20, 0x20, 0x20, 0x10, 0x08, 0x00, 0x20, 0x10, 0x08, 0x08, 0x08, 0x10, 0x20, 0x00, 0x10, 0x54, 0x38, 0x7C, 0x38, 0x54, 0x10, 0x00, 0x00, 0x10, 0x10, 0x7C, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18, 0x10, 0x00, 0x00, 0x00, 0x7C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18, 0x00, 0x00, 0x04, 0x08, 0x10, 0x20, 0x40, 0x00, 0x00, 0x38, 0x44, 0x4C, 0x54, 0x64, 0x44, 0x38, 0x00, 0x10, 0x30, 0x10, 0x10, 0x10, 0x10, 0x38, 0x00, 0x38, 0x44, 0x04, 0x38, 0x40, 0x40, 0x7C, 0x00, 0x38, 0x04, 0x04, 0x18, 0x04, 0x04, 0x38, 0x00, 0x08, 0x18, 0x28, 0x48, 0x7C, 0x08, 0x08, 0x00, 0x7C, 0x40, 0x78, 0x04, 0x04, 0x44, 0x38, 0x00, 0x18, 0x20, 0x40, 0x78, 0x44, 0x44, 0x38, 0x00, 0x7C, 0x04, 0x08, 0x10, 0x20, 0x40, 0x40, 0x00, 0x38, 0x44, 0x44, 0x38, 0x44, 0x44, 0x38, 0x00, 0x38, 0x44, 0x44, 0x3C, 0x04, 0x08, 0x30, 0x00, 0x00, 0x30, 0x30, 0x00, 0x30, 0x30, 0x00, 0x00, 0x00, 0x30, 0x30, 0x00, 0x30, 0x30, 0x20, 0x40, 0x08, 0x10, 0x20, 0x40, 0x20, 0x10, 0x08, 0x00, 0x00, 0x00, 0x7C, 0x00, 0x7C, 0x00, 0x00, 0x00, 0x40, 0x20, 0x10, 0x08, 0x10, 0x20, 0x40, 0x00, 0x38, 0x44, 0x04, 0x08, 0x10, 0x00, 0x10, 0x00
scratchpad:
db 0,0,0,0,0,0
destination:
db 0,0
fontpointer:
db 0,0

S2: db "WELCOME TO",0
S3: db "  WINTER  ",0
S4: db " CAMP XLV ",0
