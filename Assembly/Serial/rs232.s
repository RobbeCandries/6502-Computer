; A program that sends a Hello world message over the serial port
; It also echoes and prints anything sent over the serial port

PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %01000000
RW = %00100000
RS = %00010000

ACIA_DATA = $5000
ACIA_STATUS = $5001
ACIA_CMD = $5002
ACIA_CTRL = $5003

.org $8000

reset:
  ldx #$ff
  txs

  lda #%11111111   ; Set all pins on port B to output
  sta DDRB
  lda #%00000000   ; Set all pins on port A to input
  sta DDRA

  jsr lcd_init     ; Initialize lcd screen

  lda #$00
  sta ACIA_STATUS  ; Soft reset (value not important)
  lda #$1f         ; N-8-1, 19200 baud
  sta ACIA_CTRL
  lda #$0b         ; no parity, no echo, no interrupts
  sta ACIA_CMD

  ldx #$00
send_msg:
  lda message, x
  beq done
  jsr send_char
  inx
  jmp send_msg
done:


rx_wait:
  lda ACIA_STATUS
  and #$08         ; Check rx buffer status flag 
  beq rx_wait      ; Loop if rx buffer is empty

  lda ACIA_DATA    ; Read recieved byte
  jsr send_char    ; Echo
  jsr print_char
  jmp rx_wait

message: .asciiz "Hello, world!"


send_char:
  sta ACIA_DATA    ; Send data
  jsr tx_delay
  rts

tx_delay:
  phx
  ldx #100
tx_delay_1:
  dex
  bne tx_delay_1
  plx
  rts

lcd_wait:
  pha
  lda #%11110000   ; LCD data is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB        ; Read high nibble
  pha              ; and put on stack since it has the busy flag
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB        ; Read low nibble
  pla              ; Get high nibble off stack
  and #%00001000
  bne lcdbusy

  lda #RW
  sta PORTB
  lda #%11111111   ; LCD data is output
  sta DDRB
  pla
  rts

lcd_init:
  lda #%00000010   ; Set 4-bit mode
  jsr lcd_instruction
  lda #%00101000   ; Set 4-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110   ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110   ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001   ; Clear display
  jsr lcd_instruction
  rts

lcd_instruction:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr              ; Send high 4 bits
  sta PORTB
  ora #E           ; Set E bit to send instruction
  sta PORTB
  eor #E           ; Clear E bit
  sta PORTB
  pla
  and #%00001111   ; Send low 4 bits
  sta PORTB
  ora #E           ; Set E bit to send instruction
  sta PORTB
  eor #E           ; Clear E bit
  sta PORTB
  rts

print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr              ; Send high 4 bits
  ora #RS          ; Set RS
  sta PORTB
  ora #E           ; Set E bit to send instruction
  sta PORTB
  eor #E           ; Clear E bit
  sta PORTB
  pla
  and #%00001111   ; Send low 4 bits
  ora #RS          ; Set RS
  sta PORTB
  ora #E           ; Set E bit to send instruction
  sta PORTB
  eor #E           ; Clear E bit
  sta PORTB
  rts


irq:
  rti
  

.org $fffa
.word irq          ; Reset/IRQ vectors
.word reset
.word irq