; ===== Core NES Logic ===== ;
; This file is included/inserted in the main.asm file.

NESMain:
    ; === Load TAS Config ===
    movlb   0
    call    FlashLoadConfig
    call    FlashLoadNextEvent
    
    bcf	    PIN_UART_HOST
    
    call    FlashPrepareReadZero
    
    movlw   H'FF'
    call    FlashReadNextNES
    movffl  NES_STATE_REG1, U1TXB
    movffl  NES_STATE_REG2, U1TXB
    
    call    CheckResetNES
    
    incfsz  CUR_INPUT_LOW, 1
    goto    NESMain_IncEnd
    
    incfsz  CUR_INPUT_MID, 1
    goto    NESMain_IncEnd
    
    incf    CUR_INPUT_HIGH, 1
NESMain_IncEnd:
    
    
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
    movlw   B'10001011'
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