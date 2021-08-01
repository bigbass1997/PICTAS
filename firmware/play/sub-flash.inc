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
    wait D'16'
    
    movlw   H'9F'
    movffl  WREG, SPI1TXB
    movlw   0
    movffl  WREG, SPI1TXB
    wait D'255'
    nop
    nop
    movffl  SPI1RXB, U1TXB
    ;movffl  SPI1RXB, WREG
    ;xorlw   0xFF
    ;movffl  WREG, U1TXB
    movffl  SPI1RXB, U1TXB
    wait D'255'
    wait D'255'
    wait D'255'
    
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
FlashPrepareReadZero: ; Calling this label will start the read from FLASH address 0x000000
    movlb   0
    clrf    FLASH_ADDR_HIGH
    clrf    FLASH_ADDR_MID
    clrf    FLASH_ADDR_LOW
    
FlashPrepareRead: ; Calling this label will start the read from FLASH_ADDR_HIGH/MID/LOW
    bsf	    PIN_FLASH_CS
    movlb   0
    nop
    bcf	    PIN_FLASH_CS
    
    movlw   H'03'
    movffl  WREG, SPI1TXB
    movffl  FLASH_ADDR_HIGH, SPI1TXB
    wait D'35'
    movffl  SPI1RXB, JUNK_REG
    movffl  SPI1RXB, JUNK_REG
    
    movffl  FLASH_ADDR_MID, SPI1TXB
    movffl  FLASH_ADDR_LOW, SPI1TXB
    wait D'35'
    movffl  SPI1RXB, JUNK_REG
    movffl  SPI1RXB, JUNK_REG
    
    return
    
    
;
FlashReadNext:
    movffl  WREG, SPI1TXB
    wait D'15'
    movffl  SPI1RXB, WREG
    
    call    IncrementFlashLast
    
    return

;
FlashReadNextNES:
    movffl  WREG, SPI1TXB
    movffl  WREG, SPI1TXB
    wait D'42'
    movffl  SPI1RXB, NES_STATE_REG1
    nop
    nop
    movffl  SPI1RXB, NES_STATE_REG2
    
    call    IncrementFlashLast
    call    IncrementFlashLast
    
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
    
    
; Loads config from FLASH into bank 2
FlashLoadConfig:
    movlb   0
    setf    FLASH_ADDR_HIGH
    movlw   B'11110000'
    movwf   FLASH_ADDR_MID
    clrf    FLASH_ADDR_LOW
    
    lfsr    1, H'0200'	; set FSR1 to first address of bank 2
    
    call    FlashPrepareRead
    
    clrf    WREG
    BANKSEL FSR1L
FLC_Loop:
    movffl  WREG, SPI1TXB
    wait D'35'
    movffl  SPI1RXB, POSTINC1
    
    tstfsz  FSR1L, 1	; skip next if FSR1L == zero
    goto    FLC_Loop
    
    bsf	    PIN_FLASH_CS
    
    return
    
    
; Loads next scheduled event into CFG_EVENT_xxxx registers in bank 2
FlashLoadNextEvent:
    movlb   0
    setf    FLASH_ADDR_HIGH
    movff   FLASH_EVENT_MID, FLASH_ADDR_MID
    movff   FLASH_EVENT_LOW, FLASH_ADDR_LOW
    
    bcf	    UTIL_FLAGS, 4
    btfsc   PIN_FLASH_CS_RD
    bsf	    UTIL_FLAGS, 4
    
    call    FlashPrepareRead
    
    movffl  ZEROS_REG, SPI1TXB
    movffl  ZEROS_REG, SPI1TXB
    wait D'35'
    movffl  SPI1RXB, CFG_EVENT_HIGH
    movffl  SPI1RXB, CFG_EVENT_MID
    
    movffl  ZEROS_REG, SPI1TXB
    movffl  ZEROS_REG, SPI1TXB
    wait D'35'
    movffl  SPI1RXB, CFG_EVENT_LOW
    movffl  SPI1RXB, CFG_EVENT_CMD
    
    bsf	    PIN_FLASH_CS
    
    incf    FLASH_EVENT_LOW, 1
    incf    FLASH_EVENT_LOW, 1
    incf    FLASH_EVENT_LOW, 1
    infsnz  FLASH_EVENT_LOW, 1	; increment low address by 4
    incf    FLASH_EVENT_MID, 1	; if low rolls over, increment mid address by 1
    
    btfsc   UTIL_FLAGS, 4
    return
    
    ; restore previously ongoing input read
    movff   FLASH_LAST_HIGH, FLASH_ADDR_HIGH
    movff   FLASH_LAST_MID, FLASH_ADDR_MID
    movff   FLASH_LAST_LOW, FLASH_ADDR_LOW
    call    FlashPrepareRead
    
    return