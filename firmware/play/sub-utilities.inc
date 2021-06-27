; uses PAUSE_REG_0 and PAUSE_REG_1 to set the intervals of each loop
; cycles = ((PAUSE_REG_0 * 3) - 1) + ?
Pause2D:
    BANKSEL PAUSE_REG_0
    movff   PAUSE_REG_0, PAUSE_TMP_0
    movff   PAUSE_REG_1, PAUSE_TMP_1
    
Pause2D_SecondLoop:
    movff   PAUSE_REG_0, PAUSE_TMP_0
    
Pause2D_FirstLoop:
    decfsz  PAUSE_TMP_0
    goto    Pause2D_FirstLoop
    
    decfsz  PAUSE_TMP_1
    goto    Pause2D_SecondLoop
    
    return
    
; Utilizes TX_DATA register and PIN_N64_DATAOUT
; 'BANKSEL TX_DATA' must be run BEFORE this subroutine!
; Provides 3 cycles of lead time (after considering the return and next call instructions)
SendN64Byte:
    lfsr    2, 0x00
    movlw   D'7'
    movwf   LOOP_COUNT_0
    
SNB_Loop:
    rlcf    [TX_DATA], 1
    btfsc   STATUS, C, ACCESS
    goto    SNB_One
    TransmitZeroBit PIN_N64_DATAOUT, 9
    goto    SNB_After
SNB_One:
    TransmitOneBit PIN_N64_DATAOUT, 7
SNB_After:
    decfsz  [LOOP_COUNT_0], 1
    goto    SNB_Loop
    
    ; last iteration has different timing to allow for another byte after
    rlcf    [TX_DATA], 1
    btfsc   STATUS, C, ACCESS
    goto    SNB_LastOne
    TransmitZeroBit PIN_N64_DATAOUT, 15
    goto    SNB_End
SNB_LastOne:
    TransmitOneBit PIN_N64_DATAOUT, 13
SNB_End:
    return
    
    
; Intended to be called immediately after the last `SendN64Byte` call
SendN64StopBit:
    wait D'9'
    bcf	    PIN_N64_DATAOUT
    wait D'31'
    bsf	    PIN_N64_DATAOUT
    return
    
    
; Has the same result as DetermineDataToByte but calculates it entirely differently
; Instead of sampling every 1us, it only checks the 1st and 3rd microsecond.
; If first sample is HIGH, the byte is invalid and reading should stop.
; If both are LOW, bit is Zero
; If first is LOW, second is HIGH, bit is One
DetermineDataToByte2:
    movlw   D'8'
    movwf   LOOP_COUNT_0
    
DDTB_BitLoop:
    ; 4/16
    setf    N64_BIT_REG		; 1, 5/16
    
    bsf	    STATUS, C		; 1, 6/16
    btfss   PIN_N64_DATAIN		; 1, 7/16
    bcf     STATUS, C
    rlcf    N64_BIT_REG, 1	; 1, 9/16
    
    wait    D'7'		; 1, 16/16
    wait    D'16'		; 2, 16/16
    wait    D'2'		; 3, 2/16
    
    bsf	    STATUS, C
    btfss   PIN_N64_DATAIN		; 3, 4/16
    bcf     STATUS, C
    rlcf    N64_BIT_REG, 1	; 3, 6/16
    
    btfsc   N64_BIT_REG, 1
    goto    DDTB_ByteInvalid
    ; 3, 8/16
    
    bsf	    STATUS, C
    btfss   N64_BIT_REG, 0
    bcf	    STATUS, C
    rlcf    N64_DATA_DETER	; 3, 12/16
    wait    D'4'		; 3, 16/16
    
    dcfsnz  LOOP_COUNT_0
    goto    DDTB_End
    ; 4, 2/16
    
    wait    D'15'
    goto    DDTB_BitLoop
    
DDTB_ByteInvalid:
    bsf	    UTIL_FLAGS, 7	; byte is invalid, no bit was detected
    
DDTB_End:
    return  ; If byte was valid, cycle should be: 4, 5/16, leaving 11 cycles free
    
    
; Retrieves the next frame from FLASH memory.
; Eventually this will support more than just one N64 controller
; worth of input.
RetrieveNextFrame_N64:
    movlw   0
    call FlashReadNext
    movffl  WREG, N64_STATE_REG1
    
    movlw   0
    call FlashReadNext
    movffl  WREG, N64_STATE_REG2
    
    movlw   0
    call FlashReadNext
    movffl  WREG, N64_STATE_REG3
    
    movlw   0
    call FlashReadNext
    movffl  WREG, N64_STATE_REG4
    
    return
    
    
GrabNextUSBRX:
    BANKSEL PIR3
GNUSB_Loop:
    movffl  PIR3, WREG
    btfss   PIR3, U1RXIF
    goto    GNUSB_Loop
    bcf     PIR3, U1RXIF
    movffl  U1RXB, WREG
    
    return
    
    
; Checks if the NES should be reset on the current latch.
; Used exclusively with IOC ISR for now.
CheckResetNES:
    
    movf    CUR_INPUT_LOW, 0
    xorwf   CFG_EVENT_LOW, 0
    btfss   STATUS, Z
    goto    IOCISR_AF0_CheckFailedCallback
    
    movf    CUR_INPUT_MID, 0
    xorwf   CFG_EVENT_MID, 0
    btfss   STATUS, Z
    goto    IOCISR_AF0_CheckFailedCallback
    
    movf    CUR_INPUT_HIGH, 0
    xorwf   CFG_EVENT_HIGH, 0
    btfss   STATUS, Z
    goto    IOCISR_AF0_CheckFailedCallback
    
    movlw   0x01
    xorwf   CFG_EVENT_CMD, 0
    btfss   STATUS, Z
    goto    IOCISR_AF0_CheckFailedCallback ; 27 after goto
    
    bsf	    PIN_CON_RESET
    call    FlashLoadNextEvent
    wait D'255'
    wait D'255'
    bcf	    PIN_CON_RESET
    
    goto    IOCISR_CheckSucceededCallback
    
    
; Wait for NES latch to be HIGH significantly longer than normal, indicating a reset.
WaitResetNES:
    BANKSEL TRISA
    movlw   B'00001011'
    movwf   TRISA
    movlb   B'000000'
    
    movlw   D'63'
    movwf   LOOP_COUNT_0
    bsf	    PIN_STAT_LED
WRNES_FirstCheck:
    btfss   PIN_NES_LATCH
    goto    WRNES_FirstCheck
    
    wait D'70' ; wait just over the expected latch time before checking again
    
WRNES_SecondCheck:
    btfss   PIN_NES_LATCH   ; if latch is still set, then continue
    goto    WaitResetNES    ; otherwise, reset counter and restart procedure
    
    dcfsnz  LOOP_COUNT_0    ; if we haven't reached zero, then continue
    goto    WRNES_EndOfChecks ; otherwise jump to end of checks
    
    wait D'70'
    goto    WRNES_SecondCheck ; wait, then go back to check again
    
WRNES_EndOfChecks: ; if reached, the console must have been in reset
    btfsc   PORTB, 5	    ; wait again just to make sure interrupt button is released
    goto    WRNES_EndOfChecks
    
    return
    
    
; Inc CUR_INPUT_xxxx registers
IncrementCurInput:
    Increment3Registers	CUR_INPUT_HIGH, CUR_INPUT_MID, CUR_INPUT_LOW
    
    return
    
    
; Inc FLASH_LAST_xxxx registers
IncrementFlashLast:
    Increment3Registers	FLASH_LAST_HIGH, FLASH_LAST_MID, FLASH_LAST_LOW
    
    return