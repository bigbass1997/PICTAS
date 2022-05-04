; ===== Core Genesis Logic ===== ;
; This file is included/inserted in the main.asm file.

GenesisMain:
    movlb   B'000000'
    
    call    TRIS_Genesis
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
    
GenesisMain_Loop:
    ;call    FlashReadNextGenesis
    
    movlb   0
    ;movffl  GEN_STATE_REG1, LATC
    ;movffl  GEN_STATE_REG2, LATA
    
    btfsc   PORTC, 6
    goto    GenesisMain_SelectHigh
    
    bcf	    LATC, 2
    bcf	    LATC, 3
    goto    GenesisMain_SelectEnd
GenesisMain_SelectHigh:
    bsf	    LATC, 2
    bsf	    LATC, 3
    
    
GenesisMain_SelectEnd:
    
    ;call    IncrementCurInput
    
    ;bcf	    UTIL_FLAGS, 2
GenesisMain_WaitVsync:
    ;movlb   B'000000'
    ;btfss   UTIL_FLAGS, 2
    ;goto    GenesisMain_WaitVsync
    
    
    
    goto    GenesisMain_Loop