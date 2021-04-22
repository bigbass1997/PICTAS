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
    
    
; macro used for the following WriteSPI subroutines
WriteSPI_BUSx macro strobe_port, strobe_bit
    movffl  WREG, SPI1TXB
    wait D'24'
    bsf	    strobe_port, strobe_bit
    bcf	    strobe_port, strobe_bit
    endm
    
; Writes WREG to SPI bus and strobes port 0
WriteSPI_BUS0:
    WriteSPI_BUSx   PIN_STROBE0
    return
    
; Writes WREG to SPI bus and strobes port 1
WriteSPI_BUS1:
    WriteSPI_BUSx   PIN_STROBE1
    return
    
; Writes WREG to SPI bus and strobes port 2
WriteSPI_BUS2:
    WriteSPI_BUSx   PIN_STROBE2
    return
    
; Writes WREG to SPI bus and strobes port 3
WriteSPI_BUS3:
    WriteSPI_BUSx   PIN_STROBE3
    return
    
    
;
GrabNextUSBRX:
    BANKSEL PIR3
GNUSB_Loop:
    movffl  PIR3, WREG
    btfss   PIR3, U1RXIF
    goto    GNUSB_Loop
    bcf     PIR3, U1RXIF
    movffl  U1RXB, WREG
    
    return
    