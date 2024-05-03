; A small program that prints "Hello, world!" and listens for interrupts on the 65c22

PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600c
IFR = $600d
IER = $600e


E  = %10000000
RW = %01000000
RS = %00100000

.org $8000

reset:
  ldx $fff       ; Initialize stackpointer to 01ff
  txs
  cli            ; Enable interrupt request

  lda #$82       ; Set interrupt trigger for CA1
  sta IER
  lda #$00       ; Set CA1 interrupt trigger to falling edge
  sta PCR

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction


  ldx #0
print:
  lda message, x
  beq loop
  jsr print_char
  inx
  jmp print
  


loop:
  jmp loop

message: .asciiz "Hello, world!"


lcd_wait:
  pha
  lda #%00000000 ; Port B is input
  sta DDRB 
lcd_busy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcd_busy

  lda #RW
  sta PORTA
  lda #%11111111 ; Port B is output
  sta DDRB
  pla
  rts
  
lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait 
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
  sta PORTA 
  rts


nmi:
  rti

irq:
  pha             ; Push values of A & X registers to stack
  txa
  pha

  lda #"I"
  jsr print_char

  ldx #$ff
delay:
  dex
  bne delay

  bit PORTA

  pla             ; Pull values of A & X registers off stack
  tax
  pla
  rti

.org $fffa
.word nmi        ; Reset and IRQ Vectors
.word reset
.word irq