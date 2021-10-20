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
    
    incf    STKPTR, F	    ; we want to return to MainLoop, instead of where ever we were previously
    movlw   low	    MainLoop   ; so we need to manipulate the STACK with a new return address
    movwf   TOSL
    movlw   high    MainLoop
    movwf   TOSH
    movlw   upper   MainLoop
    movwf   TOSU
    
    
    
    bcf	    PIN_STAT_LED
    BANKSEL PIR1
    bcf	    PIR1, INT0IF
    
    retfie
    