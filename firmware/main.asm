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
    dw	    (0x0116>>2)
    
	    code	0x0400
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
; <6:0> Unused

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

NES_COUNTER1	equ H'1D' ; Counters are used to tell when an input is finished being relayed to the NES
NES_COUNTER2	equ H'1E'

; 0x1F - 0x5E unused

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
    movlb   B'00000000' ; sets current GPR bank to bank 0
    
    lfsr    2, 0x00 ; sets access bank start location to 0x00
    
    
    ; === Peripheral Pin Select ===
    movlb   B'111010'   ; Bank 58
    ;movlw   B'100000'
    ;movwf   RD0PPS      ; Set SPI1SS    to pin RD0
    movlw   B'011111'
    movwf   RC6PPS      ; Set SPI1SDO   to pin RC6
    movlw   B'011110'
    movwf   RC4PPS      ; Set SPI1SCK   to pin RC4
    movlw   B'010011'
    movwf   RC3PPS      ; Set U1TX      to pin RC3
    
    movlw   B'010010'
    movwf   U1RXPPS     ; Set U1RX      to pin RC2
    movlw   B'010101'
    movwf   SPI1SDIPPS  ; Set SPI1SDI   to pin RC5
    
    movlb   B'00000000'
    ; === Register Setup ===
    clrf    ZEROS_REG
    setf    ONES_REG
    clrf    UTIL_FLAGS
    clrf    FLASH_ADDR_HIGH
    clrf    FLASH_ADDR_MID
    clrf    FLASH_ADDR_LOW
    
    ; configure I/O ports ; refer to pinout spreadsheet/docs for how these are mapped
    
    ; enable digitial input buffers
    BANKSEL ANSELA
    clrf    ANSELA
    clrf    ANSELB
    clrf    ANSELC
    clrf    ANSELD
    clrf    ANSELE
    
    ; 0 is output, 1 is input
    movlw   B'00001011'
    movwf   TRISA
    
    movlw   B'00000000'
    movwf   TRISB
    
    movlw   B'00100100'
    movwf   TRISC
    
    movlw   B'00000010'
    movwf   TRISD
    
    movlw   B'00000000'
    movwf   TRISE
    
    bcf     SLRCONC, 6
    bcf     SLRCONC, 5
    bcf     SLRCONC, 4
    
    BANKSEL ZEROS_REG
    clrf    N64_STATE_REG1
    clrf    N64_STATE_REG2
    clrf    N64_STATE_REG3
    clrf    N64_STATE_REG4
    
    clrf    NES_STATE_REG1
    clrf    NES_STATE_REG2
    clrf    NES_COUNTER1
    clrf    NES_COUNTER2
    bsf	    PIN_NES_DATA1
    bsf	    PIN_NES_DATA2
    
    bsf     PIN_FLASH_CS
    
    ; === Enable SPI ===
    movlb   B'111101'   ; Bank 61
    clrf    SPI1TWIDTH
    movlw   D'4'
    movwf   SPI1BAUD        ; Set baud rate = ( 64000000 / (2 * (x + 1)) )
    bsf     SPI1CON0, MST
    bsf     SPI1CON0, BMODE
    bsf     SPI1CON1, CKE   ; Clock Edge Select (0 = output data changes on idle to active)
    bcf     SPI1CON1, CKP   ; Clock Polarity Select (0 = idle state of CLK is LOW)
    bcf     SPI1CON1, SDIP  ; SDI Polarity (0 = active-high)
    bcf     SPI1CON1, SDOP  ; SDO Polarity (0 = active-high)
    bsf     SPI1CON2, TXR   ; 1 = T1FIFO data is required for a transfer
    bsf     SPI1CON2, RXR   ; 1 = data transfer suspended if R1FIFO is full
    movlw   B'0001'
    movwf   SPI1CLK         ; Set to use internal HS clock for SPI CLK
    bsf     SPI1CON0, EN    ; Eanble SPI1
    
    
    ; === Enable UART ===
    BANKSEL U1CON0
    bsf     U1CON0, U1TXEN  ; enable TX
    bsf     U1CON0, U1RXEN  ; enable RX
                            ; MODE is 0000 by default, which sets UART to Async 8-bit
    bcf     U1CON0, U1BRGS  ; normal baud rate formula
    clrf    U1BRGH
    movlw   D'7'
    movwf   U1BRGL          ; set baud rate to 1,000,000
    bsf     U1CON1, U1ON    ; enable UART1
    
    wait D'16'
    
    
    ; === Enable Interrupts ===
    bcf	    INTCON0, IPEN_INTCON0   ; Priority is unnecessary, make sure it's left off
    
    bcf	    PIR0, IOCIF
    bsf	    PIE0, IOCIE	    ; Interrupt-on-Change enabled
    bsf	    INTCON0, GIE    ; Global Interrupt Enable bit
    
    ; Specific IOC pins are configured as needed.
    ; This is done to avoid accidental interrupts on irrelevant consoles.
    
    
    movlb   B'000000'
    
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
    
    ; === Begin Main Loop ===
Start:
    ;goto    NESMain  ;; if uncommented, this bypasses USB commands ; useful for testing basic controller connection
ListenUSBCommands:
    call    GrabNextUSBRX
    BANKSEL JUNK_REG
    movwf   JUNK_REG
    
    
    xorlw   USB_CMD_PING
    btfsc   STATUS, Z
    goto    USBRX_Ping
    movf    JUNK_REG, 0
    
    xorlw   USB_CMD_DUMP
    btfsc   STATUS, Z
    goto    USBRX_Dump
    movf    JUNK_REG, 0
    
    xorlw   USB_CMD_RUN_N64
    btfsc   STATUS, Z
    goto    USBRX_Run_N64
    movf    JUNK_REG, 0
    
    xorlw   USB_CMD_RUN_NES
    btfsc   STATUS, Z
    goto    USBRX_Run_NES
    movf    JUNK_REG, 0
    
    xorlw   USB_CMD_WRITE
    btfsc   STATUS, Z
    goto    USBRX_Write
    movf    JUNK_REG, 0
    
    
    movlw   H'FF'
    movffl  WREG, U1TXB
    goto    ListenUSBCommands
    
    ;;;;==================================================================;;;;
USBRX_Ping: ; 0x01
    movlw   H'EE'
    movffl  WREG, U1TXB
    goto    ListenUSBCommands
    
    ;;;;==================================================================;;;;
USBRX_Dump: ; 0x02 ; This will dump the entire FLASH memory back to host, via USB
    call    FlashWaitBusy
    call    FlashPrepareRead
    BANKSEL ZEROS_REG
    clrf    FLASH_ADDR_HIGH
    clrf    FLASH_ADDR_MID
    clrf    FLASH_ADDR_LOW
    
USBRX_Dump_Loop:
    call    FlashReadNext
    movffl  WREG, U1TXB
    ;wait here
    wait D'255'
    wait D'63'
    
    infsnz  FLASH_ADDR_LOW
    goto    USBRX_Dump_IncLow
    goto    USBRX_Dump_Loop
    
USBRX_Dump_IncLow:
    infsnz  FLASH_ADDR_MID
    goto    USBRX_Dump_IncMid
    goto    USBRX_Dump_Loop
    
USBRX_Dump_IncMid:
    infsnz  FLASH_ADDR_HIGH
    goto    USBRX_Dump_End
    goto    USBRX_Dump_Loop
    
USBRX_Dump_End:
    call    FlashReadEnd
    
    goto    ListenUSBCommands
    
    ;;;;==================================================================;;;;
USBRX_Run_N64: ; 0x03
    movlw   H'DD'
    movffl  WREG, U1TXB
    goto    N64Main
    
USBRX_Run_NES: ; 0x04
    movlw   H'DD'
    movffl  WREG, U1TXB
    goto    NESMain
    
    ;;;;==================================================================;;;;
USBRX_Write: ; 0xAA
    clrf    FLASH_ADDR_HIGH
    clrf    FLASH_ADDR_MID
    clrf    FLASH_ADDR_LOW
    
USBRX_Write_SectorLoop:
    call    FlashWriteEnable
    call    FlashEraseSector
    call    FlashWaitBusy
    
    movlw   D'16'
    movwf   LOOP_COUNT_1
USBRX_Write_PageLoop:
    
    lfsr    1, H'0100'
    movlw   H'01'
    movffl  WREG, U1TXB ; Ask if another page available
    movlw   0
    call    GrabNextUSBRX
    xorlw   H'01'
    btfss   STATUS, Z
    goto    ListenUSBCommands ; if page not available, then return, else continue
    
USBRX_Write_ByteLoop:
    call    GrabNextUSBRX
    movffl  WREG, U1TXB
    movffl  WREG, POSTINC1
    tstfsz  FSR1L   ; skip next if FSR1L == zero
    goto    USBRX_Write_ByteLoop
    
    call    FlashWriteEnable
    call    FlashWritePage
    call    FlashWaitBusy
    ;;
    infsnz  FLASH_ADDR_MID  ; increase pointer to location of next page
    incf    FLASH_ADDR_HIGH ; 
    
    decfsz  LOOP_COUNT_1
    goto    USBRX_Write_PageLoop
    ; if 16 pages have been written, the next sector must be erased before continuing...
    
    goto    USBRX_Write_SectorLoop
    
    
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
    
NESMain_Loop:
    ;; TODO loop to check counter register(s); if 8 loops completed, then reset and retrieve next frame
    
    goto    NESMain_Loop
    
; INTERRUPT SUBROUTINES ;

IOCISR	    code	0x0116	;; check all IOCxF flag bits
    BANKSEL IOCAF
    btfsc   IOCAF, 0
    call    IOCISR_AF0
    
    btfsc   IOCAF, 1
    call    IOCISR_AF1
    
    btfsc   IOCAF, 3
    call    IOCISR_AF3
    
    retfie
    
IOCISR_AF0:
    call    RetrieveNextFrame_NES
    movlb   0
    
    bcf	    STATUS, C
    rlcf    NES_STATE_REG1, 1
    bsf	    PIN_NES_DATA1
    btfss   STATUS, C
    bcf	    PIN_NES_DATA1
    
    bcf	    STATUS, C
    rlcf    NES_STATE_REG2, 1
    bsf	    PIN_NES_DATA2
    btfss   STATUS, C
    bcf	    PIN_NES_DATA2
    
    BANKSEL IOCAF
    bcf	    IOCAF, 0
    return
    
IOCISR_AF1:
    movlb   0
    bcf	    STATUS, C
    rlcf    NES_STATE_REG1, 1
    bsf	    PIN_NES_DATA1
    btfss   STATUS, C
    bcf	    PIN_NES_DATA1
    
    BANKSEL IOCAF
    bcf	    IOCAF, 1
    return
    
IOCISR_AF3:
    movlb   0
    bcf	    STATUS, C
    rlcf    NES_STATE_REG2, 1
    bsf	    PIN_NES_DATA2
    btfss   STATUS, C
    bcf	    PIN_NES_DATA2
    
    BANKSEL IOCAF
    bcf	    IOCAF, 3
    return
    
    end