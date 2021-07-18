    movlb   B'00000000' ; sets current GPR bank to bank 0
    
    lfsr    2, 0x00 ; sets access bank start location to 0x00
    
    
    ; === Peripheral Pin Select ===
    movlb   B'111010'   ; Bank 58
    movlw   B'011111'
    movwf   RC6PPS      ; Set SPI1SDO   to pin RC6
    movlw   B'011110'
    movwf   RC4PPS      ; Set SPI1SCK   to pin RC4
    movlw   B'010011'
    movwf   RC3PPS      ; Set U1TX      to pin RC3
    
    movlw   B'010010'
    movwf   U1RXPPS     ; Set U1RX      to pin RC2
    movlw   B'010101'
    movwf   SPI1SDIPPS  ; Set SPI1SDI   to pin RC5
    movlw   B'001101'
    movwf   INT0PPS	; Set INT0	to pin RB5
    
    movlb   B'00000000'
    ; === Register Setup ===
    clrf    ZEROS_REG
    setf    ONES_REG
    clrf    UTIL_FLAGS
    clrf    FLASH_ADDR_HIGH
    clrf    FLASH_ADDR_MID
    clrf    FLASH_ADDR_LOW
    movlw   B'11110001'
    movwf   FLASH_EVENT_MID
    clrf    FLASH_EVENT_LOW
    clrf    CUR_INPUT_HIGH
    clrf    CUR_INPUT_MID
    clrf    CUR_INPUT_LOW
    clrf    FLASH_LAST_HIGH
    clrf    FLASH_LAST_MID
    clrf    FLASH_LAST_LOW
    
    ; configure I/O ports ; refer to pinout spreadsheet/docs for how these are mapped
    
    ; enable digitial input buffers
    BANKSEL ANSELA
    clrf    ANSELA
    clrf    ANSELB
    clrf    ANSELC
    clrf    ANSELD
    clrf    ANSELE
    
    ; 0 is output, 1 is input
    movlw   B'11111111' ; Only <3,1-0> are used for NES inputs, but the others are cleared when a TAS begins
    movwf   TRISA
    
    movlw   B'00100000'
    movwf   TRISB
    
    movlw   B'00100100'
    movwf   TRISC
    
    movlw   B'00000010'
    movwf   TRISD
    
    movlw   B'00000000'
    movwf   TRISE
    
    bcf     SLRCONC, 6
    bcf     SLRCONC, 5
    bcf     SLRCONC, 4
    
    clrf    LATA
    
    BANKSEL ZEROS_REG
    clrf    N64_STATE_REG1
    clrf    N64_STATE_REG2
    clrf    N64_STATE_REG3
    clrf    N64_STATE_REG4
    
    setf    NES_STATE_REG1
    setf    NES_STATE_REG2
    bsf	    PIN_NES_DATA1
    bsf	    PIN_NES_DATA2
    
    bsf	    PIN_UART_HOST
    bsf     PIN_FLASH_CS
    bcf	    PIN_STAT_LED
    bcf	    PIN_CON_RESET
    bsf	    PIN_UART_HOST
    
    ; === Enable SPI ===
    movlb   B'111101'   ; Bank 61
    clrf    SPI1TWIDTH
    movlw   D'2'
    movwf   SPI1BAUD        ; Set baud rate = ( 64000000 / (2 * (x + 1)) )
    bsf     SPI1CON0, MST
    bsf     SPI1CON0, BMODE
    bsf     SPI1CON1, CKE   ; Clock Edge Select (0 = output data changes on idle to active)
    bcf     SPI1CON1, CKP   ; Clock Polarity Select (0 = idle state of CLK is LOW)
    bcf     SPI1CON1, SDIP  ; SDI Polarity (0 = active-high)
    bcf     SPI1CON1, SDOP  ; SDO Polarity (0 = active-high)
    bsf     SPI1CON2, TXR   ; 1 = T1FIFO data is required for a transfer
    bsf     SPI1CON2, RXR   ; 1 = data transfer suspended if R1FIFO is full
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
    movwf   U1BRGL          ; set baud rate to 1,000,000
    bsf     U1CON1, U1ON    ; enable UART1
    
    wait D'16'
    
    ; === Setup Timer0 ===
    BANKSEL T0CON1
    movlw   B'01111011'
    movwf   T0CON1
    ; <7:5> sets clock source to HFINTOSC
    ;   <4> syncs timer to system clock (4 * instruction cycle clock)
    ; <3:0> sets prescaler to 1:2048 ratio ; (2048 / 4 = 512 instructions for 1 count)
					   ; (512 / 16 =  32 microSeconds for 1 count)
    
    movlw   D'250'
    movwf   TMR0H	    ; sets timer period to 250 counts ; (250 * (32us/count) = 8ms)
    ; enable when ready to start ; bsf T0CON0, 7 ;
    
    
    ; === Enable Interrupts ===
    BANKSEL INTCON0
    bcf	    INTCON0, IPEN_INTCON0   ; Priority is unnecessary, make sure it's left off
    bsf	    INTCON0, INT0EDG	    ; Set External INT0 to detect rising edge
    
    BANKSEL PIR0
    bcf	    PIR0, IOCIF
    bsf	    PIE0, IOCIE	    ; Interrupt-on-Change enabled
    bcf	    PIR1, INT0IF
    ;bsf	    PIE1, INT0IE    ; External INT0 enabled
    bcf	    PIR3, TMR0IF
    bsf	    PIE3, TMR0IE    ; Timer0 Interrupt enabled
    BANKSEL INTCON0
    bsf	    INTCON0, GIE    ; Global Interrupt Enable bit
    
    ; Specific IOC pins are configured as needed.
    ; This is done to avoid accidental interrupts on irrelevant consoles.
    
    
    
    
    
    
    ; ====== End ======