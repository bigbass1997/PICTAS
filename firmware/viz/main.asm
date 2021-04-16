    include "p18lf45k50.inc"
    processor 18lf45k50
    
    CONFIG WDTEN = OFF
    CONFIG DEBUG = ON
    CONFIG LVP = ON
    CONFIG MCLRE = ON
    
    CONFIG PCLKEN = ON
    CONFIG FOSC = HSH
    CONFIG PLLSEL = PLL3X
    CONFIG CFGPLLEN = ON
    CONFIG CPUDIV = NOCLKDIV
    
    CONFIG XINST = ON
    
ResVec      code	0x0000
    goto    Setup
    
HighPriVec  code	0x0008
    goto    ISR_HP_Handle
    
LowPriVec   code	0x0018
    goto    ISR_LP_Handle
    
; === Look at bottom of file for ISR routines ===
    
; === DEFINE PINS (text substitutions) ===
; refer to pinout documentation for more information
; reminder: all button input pins should be pulled-DOWN (default state is cleared aka 0)
;           connect pin to power to set button to a "pressed" state
#define	    PIN_NES_DATA2	LATA,  4
#define	    PIN_NES_CLK2	PORTA, 3

#define	    PIN_NES_DATA1	LATA,  2
#define	    PIN_NES_CLK1	PORTA, 1

#define	    PIN_NES_LATCH	PORTA, 0    ; Latch pins for each controller are connected at console-level

#define     PIN_N64_DATAIN      PORTD, 1
#define     PIN_N64_DATAOUT     LATD,  1    ; LAT register is used for writing data out
#define     TRIS_N64_DATA       TRISD, 1

#define     PIN_FLASH_CS        LATD,  0

#define	    PIN_STAT_LED	LATE,  2    ; Status LED indicator
#define	    PIN_CON_RESET	LATE,  1


; === REGISTERS ===
; ACCESS BANK  (0x00 - 0x5F)
ZEROS_REG       equ H'00' ; Always 0x00
ONES_REG        equ H'01' ; Always 0xFF

UTIL_FLAGS      equ H'02' ; Utility Flags, initalized with 0x00
; <7> If set, determined byte is invalid, decoding should halt
; <6> If set, no new NES latches should be accepted
; <5> If set, a TAS replay is in progress
; <4:0> Unused

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
;FOOBAR		equ H'60'

; BANK 1
;FOOBAR

; === CONSTANT BYTES ===
;FOOBAR		equ H'01'


; SUBROUTINE & MACRO INCLUDES ;
    ;include "sub-foobar.inc"
    include "macros.inc"

Setup:
    include "startup.inc"
    
    movlb   B'000000'
    
    ;; debug start ;;
    
    ;; debug end ;;
    
    
;;;;;====================== MAIN LOOP ======================;;;;;
Start:
    
    
    
    
    goto    Start
    
    
    
;;;;;================ INTERRUPT SUBROUTINES ================;;;;;
ISR_HP_Handle:
    retfie
    
ISR_LP_Handle:
    retfie
    
    
    end