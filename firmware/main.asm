    include "p18lf47k42.inc"
    include "macros.inc"
    processor 18lf47k42
    
    CONFIG WDTE = OFF
    CONFIG DEBUG = ON
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

#define     PIN_N64_DATAIN      PORTD, 1
#define     PIN_N64_DATAOUT     LATD,  1    ; LAT register is used for writing data out
#define     TRIS_N64_DATA       TRISD, 1

#define     PIN_FLASH_CS        LATD,  0

#define	    PIN_STAT_LED	LATE,  2    ; Status LED indicator


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
; <4:0> Unused

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

; NES Controller Data
NES_STATE_REG1	equ H'1B'
NES_STATE_REG2	equ H'1C'
NES_STATE_TMP1	equ H'1D'
NES_STATE_TMP2	equ H'1E'
NES_COUNT1	equ H'1F'
NES_COUNT2	equ H'20'

; 0x21 - 0x5E unused

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

; === CONSTANT BYTES ===
USB_CMD_PING        equ H'01'
USB_CMD_DUMP        equ H'02'
USB_CMD_RUN_N64     equ H'03'
USB_CMD_RUN_NES     equ H'04'
USB_CMD_DET_NES	    equ H'05'
USB_CMD_WRITE       equ H'AA'

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

Setup:
    include "startup.inc"
    
    movlb   B'000000'
    
    ;; debug start ;;
    ;call    FlashWriteEnable
    ;call    FlashEraseSector
    ;call    FlashWaitBusy
    ;call    FlashWriteEnable
    
    ;movlb   B'000001'
    ;movlw   H'AA'
    ;movwf   H'00'
    ;movlw   H'33'
    ;movwf   H'01'
    ;movlw   H'49'
    ;movwf   H'02'
    ;movlw   H'6A'
    ;movwf   H'03'
    
    ;call    FlashWritePage
    ;call    FlashWriteDisable
    ;call    FlashWaitBusy
    ;call    FlashPrepareRead
    ;call    FlashReadNext
    
    ;movffl  H'04', U1TXB
    ;movffl  H'05', U1TXB
    ;wait D'255'
    ;wait D'255'
    ;wait D'255'
    ;movffl  H'06', U1TXB
    ;movffl  H'07', U1TXB
    ;; debug end ;;
    
    
;;;;;====================== Main Loop Start ======================;;;;;
Start:
    ;goto    NESMain  ;; if uncommented, this bypasses USB commands ; useful for testing basic controller connection
    
    ; === (temporary) This included code will act as a start "menu".
    ; === Listening for certain command bytes and reacting as necessary.
    include "usb-handling.inc"
    
    
; SUBROUTINES ;
    include "sub-utilities.inc"
    include "sub-flash.inc"
    
    
;;;;;====================== N64 Main Logic ======================;;;;;
N64Main:
    ; Prepare first replay frame
    call    FlashPrepareRead
    call    RetrieveNextFrame_N64
N64MainLoop:
    call    ListenForN64
    
    goto    N64MainLoop
    
ListenForN64:
    bsf     TRIS_N64_DATA ; set to input
    
WaitForN64DataHigh:
    btfss   PIN_N64_DATAIN
    goto    WaitForN64DataHigh
    
ListenForN64Loop:
    btfsc   PIN_N64_DATAIN
    goto    ListenForN64Loop        ; wait until datapin goes LOW
    
    call    DetermineDataToByte2
    movff   N64_DATA_DETER, N64_CMD_REG
    
    lfsr    1, N64_DATA_TMP0
LFNL_DecodeLoop:
    btfsc   PIN_N64_DATAIN
    goto    LFNL_DecodeLoop         ; wait until datapin goes LOW, if not already
    
    call    DetermineDataToByte2    ; will have 11 cycles left over
    movffl  N64_DATA_DETER, POSTINC1
    nop
    btfss   UTIL_FLAGS, 7
    goto    LFNL_DecodeLoop         ; if not skipped, 7 cycles will have been consumed after jumping
    
    bcf     UTIL_FLAGS, 7
    
    lfsr    1, N64_DATA_TMP0        ; reset FSR for command usage as needed
    
    ; N64_CMD_REG is now set with command from N64 console
    ; Below is where N64_CMD_REG will be checked against each Protocol command
    ; (in order of most to least common command)
    
    bcf     TRIS_N64_DATA ; set to output
    bsf     PIN_N64_DATAOUT
    
    movf    N64_CMD_REG, 0
    xorlw   N64_CMD_STATE
    btfsc   STATUS, Z
    goto N64Loop01
    
    movf    N64_CMD_REG, 0
    xorlw   N64_CMD_INFO
    btfsc   STATUS, Z
    goto N64Loop00
    
    movf    N64_CMD_REG, 0
    xorlw   N64_CMD_RESET
    btfsc   STATUS, Z
    goto N64LoopFF
    
    ; if this point is reached, no commands were identified. Wait a short time in case of any additional data
    movlw   D'224'
    movwf   PAUSE_REG_0
    movlw   D'4'
    movwf   PAUSE_REG_1
    call    Pause2D
    return
    
N64LoopFF:  ; Do 0xFF (reset/info) command here
    BANKSEL ZEROS_REG
    ;clrf    N64_STATE_REG3 ; resets x-axis
    ;clrf    N64_STATE_REG4 ; resets y-axis
    
    ; continue to N64Loop00...
    
N64Loop00:  ; Do 0x00 (info) command here
    BANKSEL ZEROS_REG
    
    movlw   0x05
    movwf   TX_DATA
    nop
    call    SendN64Byte
    
    movlw   0x00
    movwf   TX_DATA
    nop
    call    SendN64Byte
    
    movlw   0x02
    movwf   TX_DATA
    nop
    call    SendN64Byte
    call    SendN64StopBit
    
    goto ContinueLFNL
    
N64Loop01:  ; Do 0x01 (state) command here
    BANKSEL ZEROS_REG
    
    ; Transmit bytes to console
    movff   N64_STATE_REG1, TX_DATA
    nop
    call    SendN64Byte
    movff   N64_STATE_REG2, TX_DATA
    nop
    call    SendN64Byte
    movff   N64_STATE_REG3, TX_DATA
    nop
    call    SendN64Byte
    movff   N64_STATE_REG4, TX_DATA
    nop
    call    SendN64Byte
    call    SendN64StopBit
    
    call    RetrieveNextFrame_N64
    
    goto ContinueLFNL
    
    
ContinueLFNL:
    return
    
    
;;;;;====================== NES Main Logic ======================;;;;;
NESMain:
    call    FlashPrepareRead
    
    BANKSEL INTCON0
    bcf	    INTCON0, GIE    ; Temporarily disable global interrupt bit
    
    BANKSEL IOCAP
    bsf	    IOCAP, 0	; Pos edge LATCH
    bsf	    IOCAN, 1	; Neg edge NES_CLK1
    bsf	    IOCAN, 3	; Neg edge NES_CLK2
    
    clrf    IOCAF	; safety clear IOC port A
    
    BANKSEL PIE0
    bsf	    PIE0, IOCIE	    ; Interrupt-on-Change enabled
    BANKSEL INTCON0
    bsf	    INTCON0, GIE    ; Re-enabling global interrupt bit
    
    BANKSEL TRISA
    movlw   B'00001011'
    movwf   TRISA
    
NESMain_Loop:
    ;; loop until interrupt breaks the loop or device resets
    bsf	    UTIL_FLAGS, 5
    
    goto    NESMain_Loop
    
    
; Continuously wait for LATCH to go LOW for significant time, then wait for HIGH edge,
; then start waiting for significant LOW again. Once significant LOW happens, jump to NESMain.
NESMain_EverdriveStart:
    BANKSEL TRISA
    bsf	    TRISA, 0 ; enable NES_LATCH input
    movlb   B'000000'
    bsf	    PIN_STAT_LED
    
    movlw   D'127'
    movwf   LOOP_COUNT_0
NESEDS_FirstCheck:	    ; wait until LATCH is LOW
    btfsc   PIN_NES_LATCH
    goto    NESEDS_FirstCheck
    
NESEDS_SecondCheck:
    btfsc   PIN_NES_LATCH	    ; if latch is still LOW, then continue
    goto    NESMain_EverdriveStart  ; otherwise, reset counter and restart procedure
    
    dcfsnz  LOOP_COUNT_0	    ; if we haven't reached zero, then continue
    goto    NESEDS_ThirdCheck	    ; otherwise, jump to ThirdCheck
    
    wait D'24' ; wait just under 2us
    goto    NESEDS_SecondCheck	; then go back to check again until counter reaches zero or HIGH which causes reset
    
NESEDS_ThirdCheck:	    ; sufficient first LOW has occured, now wait until HIGH
    btfss   PIN_NES_LATCH
    goto    NESEDS_ThirdCheck
    
NESEDS_FourthCheckReset:
    movlw   D'127'
    movwf   LOOP_COUNT_0
    wait D'70' ; wait for LATCH to go LOW again
NESEDS_FourthCheck:
    btfsc   PIN_NES_LATCH
    goto    NESEDS_FourthCheckReset
    
    dcfsnz  LOOP_COUNT_0
    goto    NESEDS_EndOfChecks
    
    wait D'24' ; wait just under 2us
    goto    NESEDS_FourthCheck
    
NESEDS_EndOfChecks:	    ; enough LOW checks have passed a second round, thus we must be starting the game shortly
    bcf	    PIN_STAT_LED
    goto    NESMain
    
    
; INTERRUPT SUBROUTINES ;

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
    movlw   H'FF'
    call FlashReadNextNES
    movff   NES_STATE_REG1, NES_STATE_TMP1
    movff   NES_STATE_REG2, NES_STATE_TMP2
    
    bsf	    STATUS, C
    rlcf    NES_STATE_REG1, 1
    bsf	    PIN_NES_DATA1
    btfss   STATUS, C
    bcf	    PIN_NES_DATA1
    
    bsf	    STATUS, C
    rlcf    NES_STATE_REG2, 1
    bsf	    PIN_NES_DATA2
    btfss   STATUS, C
    bcf	    PIN_NES_DATA2
    
    movlw   D'7'
    movwf   NES_COUNT1
    movwf   NES_COUNT2
    
    BANKSEL T0CON0
    bsf	    T0CON0, 7
    
    BANKSEL IOCAF
    bcf	    IOCAF, 0
    bcf	    IOCAP, 0
    return
    
IOCISR_AF1:
    movlb   0
    
    wait D'48'
    
    bsf	    STATUS, C
    rlcf    NES_STATE_REG1, 1
    bsf	    PIN_NES_DATA1
    btfss   STATUS, C
    bcf	    PIN_NES_DATA1
    
    dcfsnz  NES_COUNT1
    call    IOCISR_ResetCount1
    
    BANKSEL IOCAF
    bcf	    IOCAF, 1
    return
    
IOCISR_AF3:
    movlb   0
    
    wait D'48'
    
    bsf	    STATUS, C
    rlcf    NES_STATE_REG2, 1
    bsf	    PIN_NES_DATA2
    btfss   STATUS, C
    bcf	    PIN_NES_DATA2
    
    dcfsnz  NES_COUNT2
    call    IOCISR_ResetCount2
    
    BANKSEL IOCAF
    bcf	    IOCAF, 3
    return
    
IOCISR_End:
    BANKSEL IOCAF
    bcf	    IOCAF, 0
    bcf	    IOCAF, 1
    bcf	    IOCAF, 3
    retfie
    
IOCISR_ResetCount1:
    movffl  NES_STATE_TMP1, U1TXB
    movff   NES_STATE_TMP1, NES_STATE_REG1
    movlw   D'8'
    movwf   NES_COUNT1
    return
    
IOCISR_ResetCount2:
    movffl  NES_STATE_TMP2, U1TXB
    movff   NES_STATE_TMP2, NES_STATE_REG2
    movlw   D'8'
    movwf   NES_COUNT2
    return
    
    
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
    
INT0ISR_Start:	; START PROCEDURE ;
    BANKSEL TRISA
    movlw   B'00001011'
    movwf   TRISA
    movlb   B'000000'
    
    movlw   D'63'
    movwf   LOOP_COUNT_0
    bsf	    PIN_STAT_LED
INT0ISR_FirstCheck:
    btfss   PIN_NES_LATCH
    goto    INT0ISR_FirstCheck
    
    wait D'70' ; wait just over the expected latch time before checking again
    
INT0ISR_SecondCheck:
    btfss   PIN_NES_LATCH   ; if latch is still set, then continue
    goto    INT0ISR_Start   ; otherwise, reset counter and restart procedure
    
    dcfsnz  LOOP_COUNT_0    ; if we haven't reached zero, then continue
    goto    INT0ISR_EndOfChecks ; otherwise jump to end of checks
    
    wait D'70'
    goto    INT0ISR_SecondCheck ; wait, then go back to check again
    
INT0ISR_EndOfChecks: ; if reached, the console must have been in reset
    btfsc   PORTB, 5	    ; wait again just to make sure interrupt button is released
    goto    INT0ISR_EndOfChecks
    
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
    
    
TMR0ISR	    code	0x0500	;; Timer0 has completed	
    BANKSEL IOCAP
    bcf	    IOCAF, 0
    bsf	    IOCAP, 0
    
    BANKSEL T0CON0
    bcf	    T0CON0, 7
    
    BANKSEL PIR3
    bcf	    PIR3, TMR0IF
    
    retfie
    
    end