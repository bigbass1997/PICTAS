; Prepares FLASH memory for reading sequentially.
; Because memory is only used for TAS replay, memory read
; always starts at address 0x000000.
FlashPrepareRead:
    bcf	    PIN_FLASH_CS
    
    movlw   H'03'
    movffl  WREG, SPI1TXB
    movlw   0
    movffl  WREG, SPI1TXB
    nop
    nop
    movffl  SPI1RXB, H'1B'
    movffl  SPI1RXB, H'1B'
    
    movffl  WREG, SPI1TXB
    movffl  WREG, SPI1TXB
    nop
    nop
    movffl  SPI1RXB, H'1B'
    movffl  SPI1RXB, H'1B'
    
    bsf	    PIN_FLASH_CS
    
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
    
    
    return
    
    
; Enables writing on the FLASH memory. This must be done before writing any data!
FlashWriteEnable:
    movlw   H'06'
    movffl  WREG, SPI1TXB
    nop
    nop
    nop
    nop
    BANKSEL SPI1STATUS
    bsf	    SPI1STATUS, CLRBF
    
    return
    
    
; Disables writing on the FLASH memory.
FlashWriteDisable:
    movlw   H'04'
    movffl  WREG, SPI1TXB
    nop
    nop
    nop
    nop
    BANKSEL SPI1STATUS
    bsf	    SPI1STATUS, CLRBF
    
    return
    
    
; Write 256 bytes to the FLASH memory page specified
; by FLASH_ADDR HIGH, MID, and LOW registers.
; The bytes that will be written are contained in BANK 1; these bytes
; should have already been set before calling this.
FlashWritePage:
    lfsr 1, H'0100'
    
    ; send instruction and 3 byte address
    BANKSEL FLASH_ADDR_HIGH
    movlw   H'02'
    movffl  WREG, SPI1TXB
    movffl  FLASH_ADDR_HIGH, SPI1TXB
    movffl  FLASH_ADDR_MID, SPI1TXB
    movffl  FLASH_ADDR_LOW, SPI1TXB
    
    clrf    WREG
    BANKSEL FSR1L
FWP_Loop:
    movffl  POSTINC1, SPI1TXB
    movf    SPI1RXB, 0, 1 ; Read dummy byte from RX FIFO to avoid overflows
    
    tstfsz  FSR1L, 1   ; skip next if FSR1L == zero
    goto    FWP_Loop
    
    return