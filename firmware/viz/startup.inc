    movlb   B'00000000' ; sets current GPR bank to bank 0
    
    lfsr    0, H'0100'	; FIFO write pointer
    lfsr    1, H'0100'	; FIFO read pointer
    lfsr    2, H'0000'	; sets access bank start location to 0x00
    
    
    ; === Peripheral Pin Select ===
    movlb   B'111010'   ; Bank 58
    movlw   B'011111'
    movwf   RC0PPS      ; Set SPI1SDO   to pin RC0
    movlw   B'011110'
    movwf   RC1PPS      ; Set SPI1SCK   to pin RC1
    movlw   B'010011'
    movwf   RC3PPS      ; Set U1TX      to pin RC3
    movlw   B'010110'
    movwf   RB4PPS      ; Set U2TX      to pin RB4
    
    movlw   B'010010'
    movwf   U1RXPPS     ; Set U1RX      to pin RC2
    movlw   B'001101'
    movwf   U2RXPPS     ; Set U2RX      to pin RB5
    ;movlw   B'010101'
    ;movwf   SPI1SDIPPS  ; Set SPI1SDI   to pin RC5
    
    movlb   B'00000000'
    ; === Register Setup ===
    clrf    ZEROS_REG
    setf    ONES_REG
    clrf    UTIL_FLAGS
    
    ; configure I/O ports ; refer to pinout spreadsheet/docs for how these are mapped
    
    ; enable digitial input buffers
    BANKSEL ANSELA
    clrf    ANSELA
    clrf    ANSELB
    clrf    ANSELC
    
    ; 0 is output, 1 is input
    movlw   B'00000000'
    movwf   TRISA
    
    movlw   B'00101000'
    movwf   TRISB
    
    movlw   B'00000100'
    movwf   TRISC
    
    clrf    SLRCONA
    clrf    SLRCONB
    clrf    SLRCONC
    
    clrf    LATA
    clrf    LATB
    clrf    LATC
    
    ; === Enable SPI ===
    movlb   B'111101'   ; Bank 61
    clrf    SPI1TWIDTH
    movlw   D'3'
    movwf   SPI1BAUD        ; Set baud rate = ( 64000000 / (2 * (x + 1)) )
    bsf     SPI1CON0, MST
    bsf     SPI1CON0, BMODE
    bsf     SPI1CON1, CKE   ; Clock Edge Select (0 = output data changes on idle to active)
    bcf     SPI1CON1, CKP   ; Clock Polarity Select (0 = idle state of CLK is LOW)
    bcf     SPI1CON1, SDIP  ; SDI Polarity (0 = active-high)
    bcf     SPI1CON1, SDOP  ; SDO Polarity (0 = active-high)
    bsf     SPI1CON2, TXR   ; 1 = T1FIFO data is required for a transfer
    bcf     SPI1CON2, RXR   ; 0 = Recieved data is not stored in FIFO (is ignored)
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
    movwf   U1BRGL          ; set baud rate to 500,000
    bsf     U1CON1, U1ON    ; enable UART1
    
    BANKSEL U2CON0
    bsf     U2CON0, U2TXEN  ; enable TX
    bsf     U2CON0, U2RXEN  ; enable RX
                            ; MODE is 0000 by default, which sets UART to Async 8-bit
    bcf     U2CON0, U2BRGS  ; normal baud rate formula
    clrf    U2BRGH
    movlw   D'1'
    movwf   U2BRGL          ; set baud rate to 2,000,000
    bsf     U2CON1, U2ON    ; enable UART2
    
    wait D'16'
    
    
    ; === Enable Interrupts ===
    BANKSEL INTCON0
    bsf	    INTCON0, IPEN_INTCON0   ; Enables interrupt priority feature
    
    BANKSEL PIR0
    bsf	    IPR3, U1RXIP
    bsf	    PIE3, U1RXIE    ; UART1 RX Interrupt enabled (high priority)
    bcf	    IPR6, U2RXIP
    bsf	    PIE6, U2RXIE    ; UART2 RX Interrupt enabled (low priority)
    
    BANKSEL INTCON0
    bsf	    INTCON0, GIEL    ; Global Low-Priority Interrupt Enable bit
    bsf	    INTCON0, GIEH    ; Global/High-Priority Interrupt Enable bit
    