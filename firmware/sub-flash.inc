SPITransfer:
    BANKSEL SPI_IN
    movlw   D'8'
    movwf   LOOP_COUNT_0
    
    ; set output, pulse CLK, read input; repeat
    
SPIT_Loop:
    rlcf    SPI_OUT
    bsf	    PIN_SPI_OUT
    btfss   STATUS, C
    bcf	    PIN_SPI_OUT
    
    nop
    nop
    
    bsf	    PIN_SPI_CLK
    nop
    nop
    bcf	    PIN_SPI_OUT
    nop
    nop
    
    bsf	    STATUS, C
    btfss   PIN_SPI_IN
    bcf	    STATUS, C
    rlcf    SPI_IN
    
    bcf	    PIN_SPI_CLK
    
    decfsz  LOOP_COUNT_0
    goto    SPIT_Loop
    
    return
    
    
FlashReset:
    bcf	    PIN_FLASH_CS
    
    movlw   H'66'
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, U1TXB
    
    bsf	    PIN_FLASH_CS
    wait D'24'
    bcf	    PIN_FLASH_CS
    
    movlw   H'99'
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, U1TXB
    bsf	    PIN_FLASH_CS
    
    wait D'255'
    wait D'255'
    
    return
    
    
FlashReadJEDEC:
    bcf	    PIN_FLASH_CS
    
    movlw   H'9F'
    movffl  WREG, SPI1TXB
    movlw   0
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, U1TXB
    movffl  SPI1RXB, U1TXB
    
    movffl  WREG, SPI1TXB
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, U1TXB
    movffl  SPI1RXB, U1TXB
    
    bsf	    PIN_FLASH_CS
    
    return
    
    
FlashReadJEDECManual:
    BANKSEL SPI_IN
    
    bcf	    PIN_FLASH_CS
    clrf    SPI_OUT
    call    SPITransfer
    clrf    SPI_OUT
    call    SPITransfer
    clrf    SPI_OUT
    call    SPITransfer
    bsf	    PIN_FLASH_CS
    wait D'255'
    
    bcf	    PIN_FLASH_CS
    
    movlw   H'9F'
    movwf   SPI_OUT
    call    SPITransfer
    wait D'255'
    
    clrf    SPI_OUT
    call    SPITransfer
    movffl  SPI_IN, U1TXB
    clrf    SPI_OUT
    call    SPITransfer
    clrf    SPI_OUT
    call    SPITransfer
    clrf    SPI_OUT
    call    SPITransfer
    clrf    SPI_OUT
    call    SPITransfer
    clrf    SPI_OUT
    call    SPITransfer
    
    bsf	    PIN_FLASH_CS
    
    return
    
    
FlashReadStatus1:
    bcf	    PIN_FLASH_CS
    
    movlw   H'05'
    movffl  WREG, SPI1TXB
    movlw   0
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, H'1B'
    movffl  SPI1RXB, H'1B'
    
    bsf	    PIN_FLASH_CS
    
    return
    
    
; Queries the FLASH's BUSY bit. Waits until BUSY == 0.
FlashWaitBusy:
    bcf	    PIN_FLASH_CS
    
    movlw   H'05'
    movffl  WREG, SPI1TXB
    movlw   0
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, H'1B'
    movffl  SPI1RXB, WREG
    
    btfss   WREG, 0
    goto    FWB_End
    
FWB_Loop:
    movlw   0
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, WREG
    
    btfsc   WREG, 0
    goto    FWB_Loop
    
FWB_End:
    bsf	    PIN_FLASH_CS
    
    return
    
    
; Prepares FLASH memory for reading sequentially.
; Because memory is only used for TAS replay, memory read
; always starts at FLASH address 0x000000.
FlashPrepareRead:
    bcf	    PIN_FLASH_CS
    
    movlw   H'03'
    movffl  WREG, SPI1TXB
    movlw   0
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, H'1B'
    movffl  SPI1RXB, H'1B'
    
    movffl  WREG, SPI1TXB
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, H'1B'
    movffl  SPI1RXB, H'1B'
    
    ;bsf	    PIN_FLASH_CS
    
    return
    
    
;
FlashReadNext:
    ;; WARNING: Test to make sure that /CS going HIGH doesn't disrupt
    ;; this part of the communication. If the FLASH memory resets its
    ;; current operation due to this, /CS will need to be performed
    ;; manually, without the SPI module's help.
    ;; This wouldn't take up any extra pins, but SC Enable would need to
    ;; be disabled at bootup.
    
    ;; TODO: Read byte by sending dummy data via SPI.
    ;;	 
    
    bcf	    PIN_FLASH_CS
    
    movlb   B'000001'
    movlw   0
    movffl  WREG, SPI1TXB
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, H'04'
    movffl  SPI1RXB, H'05'
    
    movffl  WREG, SPI1TXB
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, H'06'
    movffl  SPI1RXB, H'07'
    
    bsf	    PIN_FLASH_CS
    
    return
    
    
; Enables writing on the FLASH memory. This must be done before writing any data!
FlashWriteEnable:
    bcf	    PIN_FLASH_CS
    
    movlw   H'06'
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    nop
    nop
    BANKSEL SPI1STATUS
    bsf	    SPI1STATUS, CLRBF
    
    bsf	    PIN_FLASH_CS
    
    return
    
    
; Disables writing on the FLASH memory.
FlashWriteDisable:
    bcf	    PIN_FLASH_CS
    
    movlw   H'04'
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    nop
    nop
    BANKSEL SPI1STATUS
    bsf	    SPI1STATUS, CLRBF
    
    bsf	    PIN_FLASH_CS
    
    return
    
    
; Write 256 bytes to the FLASH memory page specified
; by FLASH_ADDR HIGH, MID, and LOW registers.
; The bytes that will be written are contained in BANK 1; these bytes
; should have already been set before calling this.
FlashWritePage:
    bcf	    PIN_FLASH_CS
    
    lfsr 1, H'0100'
    
    ; send instruction and 3 byte address
    BANKSEL FLASH_ADDR_HIGH
    movlw   H'02'
    movffl  WREG, SPI1TXB
    movffl  FLASH_ADDR_HIGH, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, H'1B'
    movffl  SPI1RXB, H'1B'
    
    movffl  FLASH_ADDR_MID, SPI1TXB
    movffl  FLASH_ADDR_LOW, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, H'1B'
    movffl  SPI1RXB, H'1B'
    
    clrf    WREG
    BANKSEL FSR1L
FWP_Loop:
    movffl  POSTINC1, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, WREG ; Read dummy byte from RX FIFO to avoid overflows
    
    tstfsz  FSR1L, 1   ; skip next if FSR1L == zero
    goto    FWP_Loop
    
    bsf	    PIN_FLASH_CS
    
    return