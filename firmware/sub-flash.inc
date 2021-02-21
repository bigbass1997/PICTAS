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
    
    
FlashReadStatus1:
    BANKSEL ZEROS_REG
    bcf	    PIN_FLASH_CS
    
    movlw   H'05'
    movffl  WREG, SPI1TXB
    movlw   0
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, JUNK_REG
    movffl  SPI1RXB, JUNK_REG
    
    bsf	    PIN_FLASH_CS
    
    return
    
    
; Queries the FLASH's BUSY bit. Waits until BUSY == 0.
FlashWaitBusy:
    BANKSEL ZEROS_REG
    bcf	    PIN_FLASH_CS
    
    movlw   H'05'
    movffl  WREG, SPI1TXB
    movlw   0
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, JUNK_REG
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
    BANKSEL ZEROS_REG
    bcf	    PIN_FLASH_CS
    
    movlw   H'03'
    movffl  WREG, SPI1TXB
    movlw   0
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, JUNK_REG
    movffl  SPI1RXB, JUNK_REG
    
    movffl  WREG, SPI1TXB
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, JUNK_REG
    movffl  SPI1RXB, JUNK_REG
    
    ;bsf	    PIN_FLASH_CS
    
    return
    
    
;
FlashReadNext:
    movffl  WREG, SPI1TXB
    wait D'13'
    nop
    nop
    movffl  SPI1RXB, WREG
    
    return

;
FlashReadNextNES:
    movffl  WREG, SPI1TXB
    movffl  WREG, SPI1TXB
    wait D'22'
    nop
    nop
    movffl  SPI1RXB, NES_STATE_REG1
    nop
    nop
    nop
    nop
    movffl  SPI1RXB, NES_STATE_REG2
    
    return
;
FlashReadEnd:
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
; by FLASH_ADDR_HIGH, MID, and LOW registers.
; The bytes that will be written are contained in BANK 1; these bytes
; should have already been set before calling this.
; NOTE: Writing is only able to clear specific bits. To set bits to 1, you
; must erase bytes first!
FlashWritePage:
    bcf	    PIN_FLASH_CS
    
    lfsr    1, H'0100'
    
    ; send instruction and 3 byte address
    BANKSEL FLASH_ADDR_HIGH
    movlw   H'02'
    movffl  WREG, SPI1TXB
    movffl  FLASH_ADDR_HIGH, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, JUNK_REG
    movffl  SPI1RXB, JUNK_REG
    
    movffl  FLASH_ADDR_MID, SPI1TXB
    movffl  FLASH_ADDR_LOW, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, JUNK_REG
    movffl  SPI1RXB, JUNK_REG
    
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
    
    
; Erase 4,096 byte sector specified by FLASH_ADDR_HIGH, MID, and LOW registers.
; There are 16 pages in 1 sector.
FlashEraseSector:
    bcf	    PIN_FLASH_CS
    
    BANKSEL FLASH_ADDR_HIGH
    movlw   H'20'
    movffl  WREG, SPI1TXB
    movffl  FLASH_ADDR_HIGH, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, JUNK_REG
    movffl  SPI1RXB, JUNK_REG
    
    movffl  FLASH_ADDR_MID, SPI1TXB
    movffl  FLASH_ADDR_LOW, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, JUNK_REG
    movffl  SPI1RXB, JUNK_REG
    
    
    bsf	    PIN_FLASH_CS
    
    return