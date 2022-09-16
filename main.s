.segment "HEADER"

INES_MAPPER = 0
INES_MIRROR = 1
INES_SRAM   = 0

PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
OAMADDR = $2003
OAMDATA = $2004
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007
OAMDMA = $4014

JOYPAD = $4016

BUTTON_A      = 1 << 7
BUTTON_B      = 1 << 6
BUTTON_SELECT = 1 << 5
BUTTON_START  = 1 << 4
BUTTON_UP     = 1 << 3
BUTTON_DOWN   = 1 << 2
BUTTON_LEFT   = 1 << 1
BUTTON_RIGHT  = 1 << 0

.byte 'N', 'E', 'S', $1A
.byte $02
.byte $01
.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << 4)
.byte (INES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0


.segment "TILES"
.incbin "background.chr"
.incbin "sprite.chr"


.segment "VECTORS"
.word $0
.word setup
.word $0

.segment "RODATA"
palette:
  .byte $0d, $30, $16, $06
  .byte $0d, $16, $16, $06
  .byte $0d, $1a, $16, $06
title:
  .byte $0E, $05, $13, $00, $01, $15, $14, $08, $00, $13, $19, $13, $14, $05, $0D

box_top:
  .byte $1F, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $20
box_mid:
  .byte $1D, $1B, $1B, $1B, $1B, $1B, $1B, $23, $1D
box_bot:
  .byte $22, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $21

pass:
  .byte BUTTON_A, BUTTON_B, BUTTON_UP, BUTTON_DOWN, BUTTON_LEFT, BUTTON_RIGHT

.segment "ZEROPAGE"
lastbutton: .res 1
button: .res 1
pressed: .res 1
buffer: .res 6
addr_temp: .res 1
out: .res 1

.segment "CODE"
readjoy:
  lda button
  sta lastbutton
  lda #1
  sta button
  sta JOYPAD
  lda #0
  sta JOYPAD
  :
    lda JOYPAD
    lsr a
    rol button
    bcc :-
  lda lastbutton
  eor #%11111111
  and button
  sta pressed
  rts

procbuttons:
  proc_a:  ; test for a
    lda pressed
    and #BUTTON_A
    cmp #BUTTON_A
    bne proc_b
    cpx #6
    beq @end
    sta buffer, x
    lda #%10000000
    jsr add_chr
    inx
    jmp proc_b
  @end:
    rts
  proc_b:  ; test for b
    lda pressed
    and #BUTTON_B
    cmp #BUTTON_B
    bne proc_up
    cpx #6
    beq proc_end
    sta buffer, x
    lda #%10000000
    jsr add_chr
    inx
  proc_up:  ; test for up
    lda pressed
    and #BUTTON_UP
    cmp #BUTTON_UP
    bne proc_down
    cpx #6
    beq proc_end
    sta buffer, x
    lda #%10000000
    jsr add_chr
    inx
  proc_down:  ; test for down
    lda pressed
    and #BUTTON_DOWN
    cmp #BUTTON_DOWN
    bne proc_left
    cpx #6
    beq proc_end
    sta buffer, x
    lda #%10000000
    jsr add_chr
    inx
  proc_left:  ; test for left
    lda pressed
    and #BUTTON_LEFT
    cmp #BUTTON_LEFT
    bne proc_right
    cpx #6
    beq proc_end
    sta buffer, x
    lda #%10000000
    jsr add_chr
    inx
  proc_right:  ; test for right
    lda pressed
    and #BUTTON_RIGHT
    cmp #BUTTON_RIGHT
    bne proc_end
    cpx #6
    beq proc_end
    sta buffer, x
    lda #%10000000
    jsr add_chr
    inx
  proc_end:
    rts

  add_chr:
    jsr vblankwaitproc
    lda #$21
    sta PPUADDR
    stx addr_temp
    lda #$cc
    adc addr_temp
    sta PPUADDR
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    lda #$1c
    sta PPUDATA
    rts

  vblankwaitproc:
    bit $2002
    bpl vblankwaitproc
    rts


setup:
  sei
  cld
  ldx #$40
  stx $4017
  ldx #$ff
  txs
  inx
  stx $2000
  stx $2001
  stx $4010

  bit $2002

@vblankwait1:
  bit $2002
  bpl @vblankwait1
  txa
@clrmem:
  sta $000,x
  sta $100,x
  sta $200,x
  sta $300,x
  sta $400,x
  sta $500,x
  sta $600,x
  sta $700,x
  inx
  bne @clrmem
@vblankwait2:
  bit $2002
  bpl @vblankwait2

ppu:
  ; fill palettes
  bit PPUSTATUS
  lda #$3f
  sta PPUADDR
  lda #$00
  sta PPUADDR
  ldx #0
  :
    lda palette, x
    sta PPUDATA
    inx
    cpx #12
    bcc :-

  ; load title
  lda #$20
  sta PPUADDR
  lda #$68
  sta PPUADDR
  ldx #0
  :
    lda title, x
    sta PPUDATA
    inx
    cpx #15
    bcc :-

  ; load box
  lda #$21
  sta PPUADDR
  lda #$ab
  sta PPUADDR
  ldx #0
  :
    lda box_top, x
    sta PPUDATA
    inx
    cpx #9
    bcc :-
  lda #$21
  sta PPUADDR
  lda #$cb
  sta PPUADDR
  ldx #0
  :
    lda box_mid, x
    sta PPUDATA
    inx
    cpx #9
    bcc :-
  lda #$21
  sta PPUADDR
  lda #$eb
  sta PPUADDR
  ldx #0
  :
    lda box_bot, x
    sta PPUDATA
    inx
    cpx #9
    bcc :-
  lda #$23
  sta PPUADDR
  lda #$da
  sta PPUADDR
  lda #$00
  sta PPUDATA
  sta PPUDATA
  sta PPUDATA

  ; reset scroll positions
  lda #0
  sta PPUSCROLL
  sta PPUSCROLL

  ; reenable background rendering
  lda PPUMASK
  ora #$08
  sta PPUMASK
  jmp main

wrong:
@vblankwait1:
  bit $2002
  bpl @vblankwait1
  lda #$21
  sta PPUADDR
  lda #$d2
  sta PPUADDR
  lda #$24
  sta PPUDATA
  lda #$23
  sta PPUADDR
  lda #$da
  sta PPUADDR
  lda #$55
  sta PPUDATA
  sta PPUDATA
  sta PPUDATA
  lda #0
  sta PPUSCROLL
  sta PPUSCROLL
  ldx #50
  :
    @vblankwait2:
      bit $2002
      bpl @vblankwait2
    dex
    cpx #0
    bne :-
  jmp setup
check:
  ldx #0
  :
    lda buffer, x
    cmp pass, x
    bne wrong
    inx
    cpx #6
    bne :-
  jmp correct
correct:
@vblankwait:
  bit $2002
  bpl @vblankwait
  lda #$21
  sta PPUADDR
  lda #$d2
  sta PPUADDR
  lda #$25
  sta PPUDATA
  lda #$23
  sta PPUADDR
  lda #$da
  sta PPUADDR
  lda #$aa
  sta PPUDATA
  sta PPUDATA
  sta PPUDATA
  lda #0
  sta PPUSCROLL
  sta PPUSCROLL
  ldx #50
  :
    @vblankwait2:
      bit $2002
      bpl @vblankwait2
    dex
    cpx #0
    bne :-
  lda #$FF
  sta out

main:
  ldx #$00
  lda #$21
  sta PPUADDR
  lda #$cc
  sta PPUADDR
  lda #0
  sta PPUSCROLL
  sta PPUSCROLL
loop:
  jsr readjoy
  jsr procbuttons
  cpx #6
  beq check
  jmp loop

.segment "OAM"
oam:  .res 256
