lorom
arch 65816

incsrc "register.inc"
incsrc "snes-init-macro.asm"
incsrc "header.inc"
incsrc "graphics-data-includes.asm"


org $008000
; game entry point
MainEntryPoint:
	clc
	xce					; set native mode
	%SnesInit()

	jmp AfterInit

incsrc "snes-init.asm"

AfterInit:
	rep #$10
	sep #$20

	jsr LoadTiles
	jsr LoadPalettes

	; bg setup
	lda #$01
	sta $2105
	lda #$40
	sta $2107


	lda #$80
	sta $2115			; vram control => $80, auto increment by 1 word on write high
	ldx #$4000
	stx $2116			; destination address => $8000

	ldx #$0040
	.Loop {
		cpx #$0040
		bne .NotFirst

		jsr FillTileMapAllSand
		jsr FillTileMapSandAndWater
		dex
		bra .Loop

		.NotFirst
		jsr FillTileMapSandAndGrass
		jsr FillTileMapSandAndWater
		dex
		bne .Loop
	}


	lda #$0f
	sta $2100			; turn on screen, full brightness

	lda #$80
	sta $4200			; enable NMI

	lda #$00
	sta $7f0064
	sta $7f0065

forever:
	wai
	wai

	lda $7f0064
	clc
	adc #$01
	sta $7f0064

	lda $7f0065
	clc
	adc #$01
	sta $7f0065

	jmp forever


VBlank:
	pha
	phx
	phy
	phd
	phb
	php

	rep #$10
	sep #$20

	lda $7f0064
	sta $210d
	lda #$00
	sta $210d

	lda $7f0065
	sta $210e
	lda #$00
	sta $210e

	lda $4210			; clear NMI flag

	plp
	plb
	pld
	ply
	plx
	pla
	rti



FillTileMapAllSand:
	lda #$10
	.Loop6 {
		ldy #$0808
		sty $2118
		ldy #$0809
		sty $2118
		dec
		bne .Loop6
	}
	lda #$10
	.Loop7 {
		ldy #$080a
		sty $2118
		ldy #$080b
		sty $2118
		dec
		bne .Loop7
	}
	rts

FillTileMapSandAndGrass:
	ldy #$0808
	sty $2118
	ldy #$0809
	sty $2118

	lda #$0f
	.Loop2 {
		ldy #$0000
		sty $2118
		ldy #$0001
		sty $2118
		dec
		bne .Loop2
	}

	ldy #$080a
	sty $2118
	ldy #$080b
	sty $2118

	lda #$0f
	.Loop3 {
		ldy #$0002
		sty $2118
		ldy #$0003
		sty $2118
		dec
		bne .Loop3
	}
	rts




FillTileMapSandAndWater:
	ldy #$0808
	sty $2118
	ldy #$0809
	sty $2118

	lda #$0f
	.Loop4 {
		ldy #$0404
		sty $2118
		ldy #$0405
		sty $2118
		dec
		bne .Loop4
	}

	ldy #$080a
	sty $2118
	ldy #$080b
	sty $2118

	lda #$0f
	.Loop5 {
		ldy #$0406
		sty $2118
		ldy #$0407
		sty $2118
		dec
		bne .Loop5
	}
	rts




LoadTiles:
	lda #$80
	sta $2115			; vram control => $80, auto increment by 1 word on write high
	ldx #$0000
	stx $2116			; destination address => $0000
	ldy #$1801
	sty $4300			; dma control and destination => $1800
	ldx #gGrassTile
	stx $4302			; source offset => $9000
	lda #$04
	sta $4304			; source bank => $04
	ldx #$0180
	stx $4305			; transfer size $180
	lda #$01
	sta $420b			; start dma transfer on channel 0
	rts					; exit routine

LoadPalettes:
	stz $2121			; color index => $00
	ldy #$2200			; dma control => $00, auto increment, write twice
	sty $4300			; dma destination => $22, CGRAM
	ldy #gGrassPalette
	sty $4302			; source offset => 
	lda #$04
	sta $4304			; source bank => $04
	ldy #$0060
	sty $4305			; dma transfer size => #$0060
	lda #$01
	sta $420b			; start dma transfer on channel 0
	rts					; exit routine






org $0ffffe
	brk


