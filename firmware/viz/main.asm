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

#define	    PIN_UART_HOST	PORTB, 3

; === REGISTERS ===
; ACCESS BANK  (0x00 - 0x5F)
ZEROS_REG       equ H'00' ; Always 0x00
ONES_REG        equ H'01' ; Always 0xFF

UTIL_FLAGS      equ H'02' ; Utility Flags, initalized with 0x00
; <7> If set, a TAS replay is in progress
; <6:0> Unused

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

JUNK_REG        equ H'5F'

; BANK 0  (0x60 - 0xFF)
; Unused

; BANK 1
; This bank is used for buffering 256 bytes of data


; === CONSTANT BYTES ===
USB_CMD_PING        equ H'01'
USB_CMD_DUMP        equ H'02'
USB_CMD_RUN_N64     equ H'03'
USB_CMD_RUN_NES     equ H'04'
USB_CMD_DET_NES	    equ H'05'
USB_CMD_WRITE       equ H'AA'


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
    
    goto    Start
    
    
    
;;;;;================ INTERRUPT SUBROUTINES ================;;;;;
U1RXISR	    code	0x0200	; Byte recieved from USB  (high priority)
    BANKSEL PIR3
U1RXISR_Retry:
    
    ; TODO: Handle USB commands
    ;movffl  U1RXB, U1TXB ; temporary debug code, returns recieved byte back to host
    movffl  U1RXB, U2TXB ; relay bytes to MCU_Play
    
    wait D'32'
    btfsc   PIR3, U1RXIF
    goto    U1RXISR_Retry
    
    retfie  1
    
U2RXISR	    code	0x0400	; Byte recieved from MCU_Play  (low priority)
    BANKSEL PIR6
U2RXISR_Retry:
    btfsc   PIN_UART_HOST
    goto    U2RXISR_SendToHost
    
    movffl  U2RXB, WREG
    XORLW   H'FF'
    call    WriteSPI_BUS0
    
    setf    PAUSE_REG_0
    call    Pause2D
    
    movffl  U2RXB, WREG
    XORLW   H'FF'
    call    WriteSPI_BUS1
    
    goto    U2RXISR_EndTry
    
U2RXISR_SendToHost:
    movffl  U2RXB, U1TXB
    
U2RXISR_EndTry:
    
    wait D'12'
    btfsc   PIR6, U2RXIF
    goto    U2RXISR_Retry
    
    retfie  1
    
    end