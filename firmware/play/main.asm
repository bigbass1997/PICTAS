    include "p18f47k42.inc"
    include "macros.inc"
    processor 18f47k42
    
    CONFIG WDTE = OFF
   ; CONFIG DEBUG = ON
    CONFIG LVP = ON
    CONFIG MCLRE = EXTMCLR
    CONFIG MVECEN = ON ; Eanbles Interrupt Vector Table ; IVTBASE + 2*(vector number)
    
    CONFIG RSTOSC = HFINTOSC_64MHZ
    
    CONFIG XINST = ON
    
ResVec      code	0x0000
    goto    Setup
    
IOCVec	    code	0x0016	; (0x0008 + (2 * 7))
    dw	    (0x0100>>2)
    
INT0Vec	    code	0x0018	; (0x0008 + (2 * 8))
    dw	    (0x0300>>2)

TMR0Vec	    code	0x0046	; (0x0008 + (2 * 31))
    dw	    (0x0500>>2)
    
	    code	0x0600
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

#define     PIN_FLASH_CS        LATB,  0
#define	    PIN_FLASH_CS_RD	PORTB, 0    ; Used to check what the last set state was

#define	    PIN_UART_HOST	LATE,  2    ; Signal to MCU_Viz whether to write UART to host or not

#define     PIN_N64_DATAIN      PORTD, 4
#define     PIN_N64_DATAOUT     LATD,  4    ; LAT register is used for writing data out
#define     TRIS_N64_DATA       TRISD, 4

#define	    PIN_STAT_LED	LATD,  0    ; Status LED indicator
#define	    PIN_CON_RESET	LATD,  1


; === REGISTERS ===
; ACCESS BANK  (0x00 - 0x5F)
ZEROS_REG       equ H'00' ; Always 0x00
ONES_REG        equ H'01' ; Always 0xFF

N64_BIT_REG     equ H'02' ; This register is used to temporarily store 3-4us of data
                          ; to determine if the data recieved is a 0 or 1 or a stop bit.
N64_CMD_REG     equ H'03'

; 0x04 - 0x07 unused

N64_STATE_REG1  equ H'08' ; Buffer:  Button states
N64_STATE_REG2  equ H'09' ; Buffer:  Button states
N64_STATE_REG3  equ H'0A' ; Buffer:  Analog Stick X-Axis ; -127 to +128
N64_STATE_REG4  equ H'0B' ; Buffer:  Analog Stick Y-Axis ; -127 to +128

TX_DATA         equ H'0C' ; Alias for TX_DATA1
TX_DATA1        equ H'0C' ; Data to be transmitted to the console
TX_DATA2        equ H'0D' ; Data to be transmitted to the console, used as "double buffer"

UTIL_FLAGS      equ H'0E' ; Utility Flags, initalized with 0x00
; <7> If set, determined byte is invalid, decoding should halt
; <6> If set, no new NES latches should be accepted
; <5> If set, a TAS replay is in progress
; <4> Used by FlashLoadNextEvent to store previous PIN_FLASH_CS state
; <3> If set, reset NES on next latch
; <2:0> Unused

; Pause Clock
PAUSE_REG_0     equ H'10'
PAUSE_REG_1     equ H'11'
PAUSE_REG_2     equ H'12'

PAUSE_TMP_0     equ H'13'
PAUSE_TMP_1     equ H'14'
PAUSE_TMP_2     equ H'15'

; Auxillary Loop Counters
LOOP_COUNT_0    equ H'16'
LOOP_COUNT_1    equ H'17'

; FLASH Pointers
FLASH_ADDR_HIGH equ H'18'
FLASH_ADDR_MID  equ H'19'
FLASH_ADDR_LOW  equ H'1A'

FLASH_LAST_HIGH	equ H'1B'
FLASH_LAST_MID	equ H'1C'
FLASH_LAST_LOW	equ H'1D'

FLASH_EVENT_MID equ H'1E'
FLASH_EVENT_LOW equ H'1F'

; NES Controller Data
NES_STATE_REG1	equ H'20'
NES_STATE_REG2	equ H'21'
NES_STATE_TMP1	equ H'22'
NES_STATE_TMP2	equ H'23'

; 0x24 - 0x57 unused

CFG_EVENT_HIGH	equ H'58'
CFG_EVENT_MID	equ H'59'
CFG_EVENT_LOW	equ H'5A'
CFG_EVENT_CMD	equ H'5B'

CUR_INPUT_HIGH	equ H'5C'
CUR_INPUT_MID	equ H'5D'
CUR_INPUT_LOW	equ H'5E'   ; keeps track of the current input frame

JUNK_REG        equ H'5F'

; BANK 0  (0x60 - 0xFF)
; These bytes are used for temporary storage of data coming from or going to the N64 console.
; While only 4 addresses are defined, this whole section of memory is dedicated for this purpose.
; Remember to specify in every instruction to use the BSR instead of Access memory.
N64_DATA_DETER  equ H'60'
N64_DATA_TMP0   equ H'61'
N64_DATA_TMP1   equ H'62'
N64_DATA_TMP2   equ H'63'
N64_DATA_TMP3   equ H'64'

; BANK 1
; This bank is used when writing a 256 byte sector of data to the FLASH memory

; BANK 2
; Config options are stored here

; 0x00 - 0xFC unused

CFG_LASTF_HIGH	equ H'FD'
CFG_LASTF_MID	equ H'FE'
CFG_LASTF_LOW	equ H'FF'



; === CONSTANT BYTES ===
USB_CMD_PING        equ H'01'
USB_CMD_DUMP        equ H'02'
USB_CMD_RUN_N64     equ H'03'
USB_CMD_RUN_NES     equ H'04'
USB_CMD_RUNED_NES   equ H'05'
USB_CMD_RUNRST_NES  equ H'06'
USB_CMD_RUNMAN_NES  equ H'07'
USB_CMD_PROGTAS     equ H'AA'
USB_CMD_PROGCFG     equ H'AB'

N64_CMD_RESET       equ H'FF'
N64_CMD_INFO        equ H'00'
N64_CMD_STATE       equ H'01'
N64_CMD_READACCES   equ H'02' ; unimplemented
N64_CMD_WRITEACCES  equ H'03' ; unimplemented

; https://n64brew.dev/wiki/Joybus_Protocol
N64_BIT_ZERO    equ B'11110001'
N64_BIT_ONE     equ B'11110111'
N64_BIT_CONSSTP equ B'11110111' ; bit <0> is not technically used, but for ease of programming, it is set to 1
N64_BIT_CONTSTP equ B'11110011'

; COMMON SUBROUTINES (may also contain macros) ;
    include "sub-utilities.inc"
    include "sub-flash.inc"
    
; Initialize device ;
Setup:
    include "startup.inc"
    
    movlb   B'000000'
    
;;;;;====================== Main Loop Start ======================;;;;;
Start:
    ;goto    NESMain  ;; if uncommented, this bypasses USB commands ; useful for testing basic controller connection
    
    ; === (temporary) This included code will act as a start "menu".
    ; === (temporary) Eventually this will be replaced with a UART ISR.
    ; === (temporary) Listens for certain command bytes and reacts as directed.
    include "usb-handling.inc"
    
    goto    Start
    
    
;;;;;====================== N64 Main Logic ======================;;;;;
    include "n64.inc"
    
    
;;;;;====================== NES Main Logic ======================;;;;;
    include "nes.inc"
    
    
;;;;;====================== NES Main Logic ======================;;;;;
    include "a2600.inc"
    
    
;;;;;====================== NES Main Logic ======================;;;;;
    include "genesis.inc"
    
    
    
; INTERRUPT SUBROUTINES ; 

; Interrupt-on-Change ISR ; Currently only used by the NES ;

IOCISR	    code	0x0100	;; check all IOCxF flag bits
    BANKSEL IOCAF
    btfsc   IOCAF, 0
    call    IOCISR_AF0
    
    btfsc   IOCAF, 1
    call    IOCISR_AF1
    
    btfsc   IOCAF, 3
    call    IOCISR_AF3
    
    retfie
    
IOCISR_AF0:
    movlb   0
    
    btfss   UTIL_FLAGS, 3
    goto    IOCISR_AF0_ResetNotNeeded
    
    bcf	    UTIL_FLAGS, 3
    call    ResetNES
    
    movlw   H'FF'
    call    FlashReadNextNES
    
    call    CheckResetNES
    
    incfsz  CUR_INPUT_LOW, 1
    goto    IOCISR_AF0_IncEnd
    
    incfsz  CUR_INPUT_MID, 1
    goto    IOCISR_AF0_IncEnd
    
    incf    CUR_INPUT_HIGH, 1
IOCISR_AF0_IncEnd:
    
    BANKSEL IOCAF
    bcf	    IOCAF, 0
    bcf	    IOCAF, 1
    bcf	    IOCAF, 3
    retfie
    
IOCISR_AF0_ResetNotNeeded:
    movffl  NES_STATE_REG1, U1TXB
    movffl  NES_STATE_REG2, U1TXB
    
    movff   NES_STATE_REG1, NES_STATE_TMP1
    movff   NES_STATE_REG2, NES_STATE_TMP2
    
    bsf	    STATUS, C
    rlcf    NES_STATE_TMP1, 1
    bsf	    PIN_NES_DATA1
    btfss   STATUS, C
    bcf	    PIN_NES_DATA1
    
    bsf	    STATUS, C
    rlcf    NES_STATE_TMP2, 1
    bsf	    PIN_NES_DATA2
    btfss   STATUS, C
    bcf	    PIN_NES_DATA2
    
    BANKSEL T0CON0
    btfss   T0CON0, 7
    bsf	    T0CON0, 7
    
    BANKSEL IOCAF
    bcf	    IOCAF, 0
    
    return
    
IOCISR_AF1:
    movlb   0
    
    wait D'40'	; clock filter
    
    bsf	    STATUS, C	; overread
    rlcf    NES_STATE_TMP1, 1
    bsf	    PIN_NES_DATA1
    btfss   STATUS, C
    bcf	    PIN_NES_DATA1
    
    BANKSEL IOCAF
    bcf	    IOCAF, 1
    return
    
IOCISR_AF3:
    movlb   0
    
    wait D'40'	; clock filter
    
    bsf	    STATUS, C	; overread
    rlcf    NES_STATE_TMP2, 1
    bsf	    PIN_NES_DATA2
    btfss   STATUS, C
    bcf	    PIN_NES_DATA2
    
    BANKSEL IOCAF
    bcf	    IOCAF, 3
    return
    
IOCISR_End:
    BANKSEL IOCAF
    bcf	    IOCAF, 0
    bcf	    IOCAF, 1
    bcf	    IOCAF, 3
    retfie
    
    
; External Interrupt ISR ; Not used in current hardware design and is only compatible with the NES ;
    
INT0ISR	    code	0x0300	;; Start/stop TAS replay
    movlb   B'000000'
    ; The device must wait until NES_LATCH has stayed high for at least a couple seconds.
    ; This wait period is used to indicate that the console reset button is being pressed.
    
    ; In the future, this can be replaced with automatic console resetting which will allow this functionality
    ;   to become usable for other consoles (though each may operate slightly differently).
    ; This will also hopefully replace remote starting entirely, and will rely on
    ;   programmed configs for console selection.
    
INT0ISR_ButtonWait:
    btfsc   PORTB, 5	    ; Wait for interrupt button to be released
    goto    INT0ISR_ButtonWait
    
    btfsc   UTIL_FLAGS, 5
    goto    INT0ISR_Stop
    ; or continue to _Start
    
    call    WaitResetNES
    
    incf    STKPTR, F	    ; we want to return to NESMain, instead of where ever we were previously
    movlw   low	    NESMain ; so we need to manipulate the STACK with a new return address
    movwf   TOSL
    movlw   high    NESMain
    movwf   TOSH
    movlw   upper   NESMain
    movwf   TOSU
    
    bcf	    PIN_STAT_LED
    BANKSEL PIR1
    bcf	    PIR1, INT0IF
    
    retfie
    
INT0ISR_Stop:	; STOP PROCEDURE ;  ;!!!!! This should really just get replaced with a software reset !!!!!
				    ;!!!!!    Don't think this part of the code even works *shrug*    !!!!!
    bsf	    PIN_STAT_LED
    bcf	    UTIL_FLAGS, 5
    
INT0ISR_StopWait:
    btfsc   PORTB, 5	    ; wait for button to be released
    goto    INT0ISR_StopWait
    
    setf    PAUSE_REG_0
    clrf    PAUSE_REG_1
    call    Pause2D
    
    btfsc   PORTB, 5	    ; check again in case of input bounce
    goto    INT0ISR_StopWait
    
    incf    STKPTR, F	    ; we want to return to Start, instead of where ever we were previously
    movlw   low	    Start   ; so we need to manipulate the STACK with a new return address
    movwf   TOSL
    movlw   high    Start
    movwf   TOSH
    movlw   upper   Start
    movwf   TOSU
    
    
    
    bcf	    PIN_STAT_LED
    BANKSEL PIR1
    bcf	    PIR1, INT0IF
    
    retfie
    
    
; Timer0 ISR ; Used by the NES for latch/window filtering, and loads the next frame of input ;
    
TMR0ISR	    code	0x0500	;; Timer0 has completed	
    BANKSEL T0CON0
    bcf	    T0CON0, 7	; disable timer0
    
    movlb   0
    movlw   H'FF'
    call    FlashReadNextNES
    
    call    CheckResetNES
    
    incfsz  CUR_INPUT_LOW, 1
    goto    TMR0ISR_IncEnd
    
    incfsz  CUR_INPUT_MID, 1
    goto    TMR0ISR_IncEnd
    
    incf    CUR_INPUT_HIGH, 1
TMR0ISR_IncEnd:
    
    
    BANKSEL PIR3
    bcf	    PIR3, TMR0IF
    
    retfie
    
    end