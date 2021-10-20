;; This file is inserted/included inside the main loop. End of file is exit for code. ;;

CMD_BUFFER_START:
    movlb   B'000000'
    movf    FSR1L, 0	; move read pointer into WREG
    xorwf   FSR0L, 0	; XOR WREG with FSR0L, store value in WREG
    btfsc   STATUS, Z
    goto    CMD_BUFFER_END  ; branch to end if FSR0 == FSR1
    
    movffl  POSTINC1, TEMP_REG
    movlw   D'1'
    movwf   FSR1H
    
    movf    TEMP_REG, 0
    xorlw   MCUCMD_HOST
    bz	    CMD_BUFFER_HOST
    
    movf    TEMP_REG, 0
    andlw   MCUCMD_SHOW8_BASE
    xorlw   MCUCMD_SHOW8_BASE
    bz	    CMD_BUFFER_SHOW8
    
    
    goto    CMD_BUFFER_END
    
    ;;;;==================================================================;;;;
CMD_BUFFER_HOST:
    movf    FSR1L, 0
    xorwf   FSR0L, 0
    bz	    CMD_BUFFER_HOST  ; wait until another byte is available
    
    movffl  POSTINC1, U1TXB
    movlw   D'1'
    movwf   FSR1H
    
    call    PauseInterUART
    
    goto    CMD_BUFFER_END
    
    ;;;;==================================================================;;;;
CMD_BUFFER_SHOW8:
    movf    FSR1L, 0
    xorwf   FSR0L, 0
    bz	    CMD_BUFFER_SHOW8  ; wait until another byte is available
    
    movf    TEMP_REG, 0
    xorlw   MCUCMD_SHOW8_0
    bz	    CMD_BUFFER_SHOW8_0
    
    movf    TEMP_REG, 0
    xorlw   MCUCMD_SHOW8_1
    bz	    CMD_BUFFER_SHOW8_1
    
    movf    TEMP_REG, 0
    xorlw   MCUCMD_SHOW8_2
    bz	    CMD_BUFFER_SHOW8_2
    
    movf    TEMP_REG, 0
    xorlw   MCUCMD_SHOW8_3
    bz	    CMD_BUFFER_SHOW8_3
    
    goto    CMD_BUFFER_END
    
CMD_BUFFER_SHOW8_0:
    WriteSPI_BUSx   POSTINC1, PIN_STROBE0
    goto    CMD_BUFFER_SHOW8_END
    
CMD_BUFFER_SHOW8_1:
    WriteSPI_BUSx   POSTINC1, PIN_STROBE1
    goto    CMD_BUFFER_SHOW8_END
    
CMD_BUFFER_SHOW8_2:
    WriteSPI_BUSx   POSTINC1, PIN_STROBE2
    goto    CMD_BUFFER_SHOW8_END
    
CMD_BUFFER_SHOW8_3:
    WriteSPI_BUSx   POSTINC1, PIN_STROBE3
    
CMD_BUFFER_SHOW8_END:
    movlw   D'1'
    movwf   FSR1H
    
    ;;;;==================================================================;;;;
CMD_BUFFER_END: