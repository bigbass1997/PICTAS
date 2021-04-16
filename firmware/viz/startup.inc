    movlb   B'000000' ; sets current GPR bank to bank 0
    lfsr    2, 0x00 ; sets access bank start location to 0x00
    
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
    clrf    ANSELD
    clrf    ANSELE
    
    ; 0 is output, 1 is input
    movlw   B'00000000' ; Only <3,1-0> are used for NES inputs, but the others are cleared when a TAS begins
    movwf   TRISA
    
    movlw   B'00000000'
    movwf   TRISB
    
    movlw   B'11000000'
    movwf   TRISC
    
    movlw   B'00000000'
    movwf   TRISD
    
    movlw   B'00000000'
    movwf   TRISE
    
    BANKSEL ZEROS_REG
    ; set/clear register for default values
    ;
    ;
    
    ; === Enable SPI ===
    ;movlb   B'111101'   ; Bank 61
    ;clrf    SPI1TWIDTH
    ;movlw   D'2'
    ;movwf   SPI1BAUD        ; Set baud rate = ( 64000000 / (2 * (x + 1)) )
    ;bsf     SPI1CON0, MST
    ;bsf     SPI1CON0, BMODE
    ;bsf     SPI1CON1, CKE   ; Clock Edge Select (0 = output data changes on idle to active)
    ;bcf     SPI1CON1, CKP   ; Clock Polarity Select (0 = idle state of CLK is LOW)
    ;bcf     SPI1CON1, SDIP  ; SDI Polarity (0 = active-high)
    ;bcf     SPI1CON1, SDOP  ; SDO Polarity (0 = active-high)
    ;bsf     SPI1CON2, TXR   ; 1 = T1FIFO data is required for a transfer
    ;bsf     SPI1CON2, RXR   ; 1 = data transfer suspended if R1FIFO is full
    ;movlw   B'0001'
    ;movwf   SPI1CLK         ; Set to use internal HS clock for SPI CLK
    ;bsf     SPI1CON0, EN    ; Eanble SPI1
    
    
    ; === Enable UART ===
    BANKSEL BAUDCON
    bsf	    BAUDCON, BRG16
    BANKSEL SPBRGH
    clrf    SPBRGH
    movlw   D'2'
    movwf   SPBRG
    
    BANKSEL TXSTA
    bcf	    TXSTA, SYNC
    bsf	    TXSTA, BRGH
    bsf	    TXSTA, TXEN
    BANKSEL RCSTA
    bsf	    RCSTA, SPEN
    bsf	    RCSTA, CREN
    
    wait D'128'
    
    BANKSEL TXREG
    clrf    TXREG
    
    wait D'36'
    
    ; === Enable USB ===
    BANKSEL UCFG
    bsf	    UCFG, UPUEN
    bsf	    UCFG, FSEN
    bcf	    UCFG, PPB1
    bcf	    UCFG, PPB0
    
    ; ENDPOINT 0
    BANKSEL UEP0
    bsf	    UEP0, EPHSHK
    bcf	    UEP0, EPCONDIS
    bsf	    UEP0, EPOUTEN
    bsf	    UEP0, EPINEN
    
    BANKSEL H'400'
    clrf    H'400'  ; configure BD0STAT
    movlw   H'80'
    movwf   H'401'  ; set block size to 128 bytes
    
    movlw   H'80'   ;
    movwf   H'402'  ;
    movlw   H'04'   ;
    movwf   H'403'  ; set start address to 0x0480
    
    ; ENDPOINT 1
    BANKSEL UEP1
    bsf	    UEP1, UPUEN
    bsf	    UEP1, EPCONDIS
    bsf	    UEP1, EPOUTEN
    bsf	    UEP1, EPINEN
    
    BANKSEL H'404'
    movlw   B'00000001'
    movwf   H'404'  ; configure BD0STAT and set block size to 256 bytes
    clrf    H'405'  ; ^
    
    movlw   H'00'   ;
    movwf   H'406'  ;
    movlw   H'05'   ;
    movwf   H'407'  ; set start address to 0x0500
    
    bsf	    UCON, USBEN
    
    ; === Enable Interrupts ===
    ;BANKSEL INTCON0
    ;bsf	    INTCON0, GIE    ; Global Interrupt Enable bit
    