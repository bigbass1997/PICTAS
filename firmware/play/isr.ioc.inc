; Interrupt-on-Change ISR ;

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
    