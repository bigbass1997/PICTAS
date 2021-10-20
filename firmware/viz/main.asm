    include "p18f27k42.inc"
    processor 18f27k42
    
    CONFIG WDTE = OFF
   ; CONFIG DEBUG = ON
    CONFIG LVP = ON
    CONFIG MCLRE = EXTMCLR
    CONFIG MVECEN = ON ; Eanbles Interrupt Vector Table ; IVTBASE + 2*(vector number)
    
    CONFIG RSTOSC = HFINTOSC_64MHZ
    
    CONFIG XINST = ON
    
ResVec      code	0x0000
    goto    Setup
    
U1RXVec	    code	0x003E	; (0x0008 + (2 * 27))
    dw	    (0x0200>>2)
    
U2RXVec	    code	0x006C	; (0x0008 + (2 * 50))
    dw	    (0x0400>>2)
    
	    code	0x0600
; === Look at bottom of file for ISR routines ===
    
; === DEFINE PINS (text substitutions) ===
; refer to pinout documentation for more information
; reminder: all button input pins should be pulled-DOWN (default state is cleared aka 0)
;           connect pin to power to set button to a "pressed" state
#define	    PIN_STROBE3		LATA,  5
#define	    PIN_STROBE2		LATA,  4
#define	    PIN_STROBE1		LATA,  3
#define	    PIN_STROBE0		LATA,  2

; === REGISTERS ===
; ACCESS BANK  (0x00 - 0x5F)
ZEROS_REG       equ H'00' ; Always 0x00
ONES_REG        equ H'01' ; Always 0xFF

UTIL_FLAGS      equ H'02' ; Utility Flags, initalized with 0x00
; <7:0> Unused

; Pause Clock
PAUSE_REG_0     equ H'03'
PAUSE_REG_1     equ H'04'
PAUSE_REG_2     equ H'05'

PAUSE_TMP_0     equ H'06'
PAUSE_TMP_1     equ H'07'
PAUSE_TMP_2     equ H'08'

; Auxillary Loop Counters
LOOP_COUNT_0    equ H'09'
LOOP_COUNT_1    equ H'0A'

; 0x0B - 0x5E unused

TEMP_REG        equ H'5F'

; BANK 0  (0x60 - 0xFF)
; Unused

; BANK 1
; MCU-Play FIFO Buffer
; Data received from MCU-Play will be stored here.
; FIFO is naive. It has a pointer and a size.
; If size > 255, it will wrap to zero. Buffer should never be this large though.


; === CONSTANT BYTES ===
MCUCMD_HOST	equ H'01'   ; Send the next byte to host

MCUCMD_SHOW8_BASE   equ H'D0'
MCUCMD_SHOW8_0	equ H'D0'   ; Send the next byte to SPI bus and strobe #0
MCUCMD_SHOW8_1	equ H'D1'   ; Send the next byte to SPI bus and strobe #1
MCUCMD_SHOW8_2	equ H'D2'   ; Send the next byte to SPI bus and strobe #2
MCUCMD_SHOW8_3	equ H'D3'   ; Send the next byte to SPI bus and strobe #3

; === SUBROUTINE & MACRO INCLUDES === ;
    include "macros.inc"
    include "sub-utilities.inc"

Setup:
    include "startup.inc"
    
    movlb   B'000000'
    
    ;; debug start ;;
    ;clrf    LOOP_COUNT_0
    ;setf    PAUSE_REG_0
;Debug_LoopSPI:
    ;movf    LOOP_COUNT_0, W
    ;call    WriteSPI_BUS0
    ;call    Pause2D
    
    ;incfsz  LOOP_COUNT_0
    ;goto    Debug_LoopSPI
    
    clrf    WREG
    call    WriteSPI_BUS0
    call    WriteSPI_BUS1
    call    WriteSPI_BUS2
    call    WriteSPI_BUS3
    ;; debug end ;;
    
    
;;;;;====================== MAIN LOOP ======================;;;;;
Start:
    include "cmd-buffer.inc"
    
    goto    Start
    
    
    
;;;;;================ INTERRUPT SUBROUTINES ================;;;;;
U1RXISR	    code	0x0200	; Byte recieved from USB  (high priority)
    BANKSEL PIR3
U1RXISR_Retry:
    movffl  U1RXB, U2TXB ; relay bytes to MCU_Play
    
    btfsc   PIR3, U1RXIF
    goto    U1RXISR_Retry
    
    retfie  1
    
U2RXISR	    code	0x0400	; Byte recieved from MCU_Play  (low priority)
    BANKSEL PIR6
U2RXISR_Retry:
    movffl  U2RXB, POSTINC0
    movlw   D'1'
    movwf   FSR0H
    
    btfsc   PIR6, U2RXIF
    goto    U2RXISR_Retry
    
    bsf	    SHADCON, SHADLO
    movffl  WREG_SHAD, WREG
    bcf	    SHADCON, SHADLO
    movlb   B'000000'
    retfie  0
    
    end