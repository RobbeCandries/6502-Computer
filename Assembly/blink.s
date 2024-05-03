; A small program that blinks LED's on the 65c22's port B

.org $8000

reset:
  lda #$ff
  sta $6002

  lda #$50
  sta $6000

loop:
  ror
  sta $6000

  jmp loop

  .org $fffc
  .word reset
  .word $0000
