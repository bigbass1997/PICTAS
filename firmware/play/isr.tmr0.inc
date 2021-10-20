; Timer0 ISR ; Used by the NES for latch/window filtering, and loads the next frame of input ;
    
TMR0ISR	    code	0x0500	;; Timer0 has completed	
    BANKSEL T0CON0
    bcf	    T0CON0, 7	; disable timer0
    
    movlb   0
    movlw   H'FF'
    call    FlashReadNextNES
    
    call    CheckResetNES
    
    movffl  MCUCMD_SHOW8_0, U1TXB
    movf    NES_STATE_REG1, 0
    xorlw   H'FF'
    movffl  WREG, U1TXB
    call    PauseInterUART
    call    PauseInterUART
    movffl  MCUCMD_SHOW8_1, U1TXB
    movf    NES_STATE_REG2, 0
    xorlw   H'FF'
    movffl  WREG, U1TXB
    
    incfsz  CUR_INPUT_LOW, 1
    goto    TMR0ISR_IncEnd
    
    incfsz  CUR_INPUT_MID, 1
    goto    TMR0ISR_IncEnd
    
    incf    CUR_INPUT_HIGH, 1
TMR0ISR_IncEnd:
    
    
    BANKSEL PIR3
    bcf	    PIR3, TMR0IF
    
    retfie
    