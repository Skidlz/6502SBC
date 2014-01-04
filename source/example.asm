;example serial and IO code
;based off of: http://6502.org/source/monitors/intelhex/intelhex.htm

.FEATURE c_comments ;enable block comments
.segment "VECTORS"
  .word NMI, RESET, IRQ

.segment "CODE"

NMI:
IRQ:
  rti
RESET:
  sei
  
  lda #SCTL_V ;baud
  sta SCTL
  lda #SCMD_V ;parity
  sta SCMD
  
  lda #$ff	;all output
  sta DDRB
  sta DDRA
  lda #$55	;test pattern
  sta PORTA

WRITE_INIT:
  ldx #0
WRITE:
  lda MSG,X
  beq WRITE_INIT
  sta SDR
  jsr WR  
  inx
  stx PORTB	;blink some leds
  jmp WRITE


WRS1:
  lda SSR     	; get status
  and #TX_RDY	; see if transmitter is busy
  beq WRS1    	; if it is, wait
  rts

MSG:
  .ASCIIZ "Hello World!"
  
VIA_BASE = $A000
PORTB = VIA_BASE
PORTA = VIA_BASE+1
DDRB = VIA_BASE+2
DDRA = VIA_BASE+3

ACIA_BASE = $C000	; This is where the 6551 ACIA starts
SDR = ACIA_BASE		; RX'ed bytes read, TX bytes written, here
SSR = ACIA_BASE+1	; Serial data status register. A write here
                    ; causes a programmed reset.
SCMD = ACIA_BASE+2	; Serial command reg. ()
SCTL = ACIA_BASE+3	; Serial control reg. ()

SCTL_V = %00011111	; 1 stop, 8 bits, 19200 baud
SCMD_V = %00001011	; No parity, no echo, no tx or rx IRQ, DTR*
TX_RDY = %00010000	; AND mask for transmitter ready