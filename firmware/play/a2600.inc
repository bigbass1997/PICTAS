; ===== Core A2600 Logic ===== ;
; This file is included/inserted in the main.asm file.

A2600Main:
    movlb   B'000000'
    
    call    TRIS_A2600
    setf    LATA
    setf    LATC
    
    call    FlashLoadConfig
    call    FlashLoadNextEvent
    call    FlashPrepareReadZero
    ;setf    LAST_USB_BYTE
    
    ; TODO: Probably reset console here, or somewhere at least.
    
    movffl  MCUCMD_HOST, U1TXB
    movlw   H'AE'
    movffl  WREG, U1TXB
    
    BANKSEL INTCON0
    bcf	    INTCON0, INT0EDG ; falling edge
    BANKSEL PIR0
    bcf	    PIR1, INT0IF
    bsf	    PIE1, INT0IE ; enable INT0
    
    ;movlw   D'4'
    ;movwf   PAUSE_TMP_0
A2600Main_Loop:
    call    FlashReadNextA2600
    
    movlb   0
    ;clrf    PAUSE_REG_0
    ;movlw   D'90'
    ;movwf   PAUSE_REG_1
    ;movlw   D'1'
    ;movwf   PAUSE_REG_2
    ;call    Pause3D
    
    ; Do stuff on controller ports here
    movffl  A2600_STATE_REG1, LATC
    movffl  A2600_STATE_REG2, LATA
    
    ;movffl  MCUCMD_HOST, U1TXB
    ;movffl  A2600_STATE_REG1, U1TXB
    ; Do stuff on console switches here
    
    ; relay state to input displays here
    
    ;movffl  LAST_USB_BYTE, LATC
    
    ;movffl  MCUCMD_HOST, U1TXB
    ;movffl  CUR_INPUT_LOW, U1TXB
    ;movffl  LAST_USB_BYTE, U1TXB
    
    call    IncrementCurInput
    
    bcf	    UTIL_FLAGS, 2
A2600Main_WaitVsync:
    movlb   B'000000'
    btfss   UTIL_FLAGS, 2
    goto    A2600Main_WaitVsync
    
    ;decfsz  PAUSE_TMP_0
    ;goto    A2600Main_Loop
    
    ;incf    PAUSE_TMP_0
    ;setf    LAST_USB_BYTE
    
    goto    A2600Main_Loop