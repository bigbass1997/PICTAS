ListenUSBCommands:
    call    GrabNextUSBRX
    BANKSEL JUNK_REG
    movwf   JUNK_REG
    
    
    xorlw   USB_CMD_PING
    btfsc   STATUS, Z
    goto    USBRX_Ping
    movf    JUNK_REG, 0
    
    xorlw   USB_CMD_DUMP
    btfsc   STATUS, Z
    goto    USBRX_Dump
    movf    JUNK_REG, 0
    
    xorlw   USB_CMD_RUN_N64
    btfsc   STATUS, Z
    goto    USBRX_Run_N64
    movf    JUNK_REG, 0
    
    xorlw   USB_CMD_RUN_NES
    btfsc   STATUS, Z
    goto    USBRX_Run_NES
    movf    JUNK_REG, 0
    
    xorlw   USB_CMD_WRITE
    btfsc   STATUS, Z
    goto    USBRX_Write
    movf    JUNK_REG, 0
    
    
    movlw   H'FF'
    movffl  WREG, U1TXB
    goto    ListenUSBCommands
    
    ;;;;==================================================================;;;;
USBRX_Ping: ; 0x01
    movlw   H'EE'
    movffl  WREG, U1TXB
    goto    ListenUSBCommands
    
    ;;;;==================================================================;;;;
USBRX_Dump: ; 0x02 ; This will dump the entire FLASH memory back to host, via USB
    call    FlashWaitBusy
    call    FlashPrepareRead
    BANKSEL ZEROS_REG
    clrf    FLASH_ADDR_HIGH
    clrf    FLASH_ADDR_MID
    clrf    FLASH_ADDR_LOW
    
USBRX_Dump_Loop:
    call    FlashReadNext
    movffl  WREG, U1TXB
    ;wait here
    wait D'255'
    wait D'63'
    
    infsnz  FLASH_ADDR_LOW
    goto    USBRX_Dump_IncLow
    goto    USBRX_Dump_Loop
    
USBRX_Dump_IncLow:
    infsnz  FLASH_ADDR_MID
    goto    USBRX_Dump_IncMid
    goto    USBRX_Dump_Loop
    
USBRX_Dump_IncMid:
    infsnz  FLASH_ADDR_HIGH
    goto    USBRX_Dump_End
    goto    USBRX_Dump_Loop
    
USBRX_Dump_End:
    call    FlashReadEnd
    
    goto    ListenUSBCommands
    
    ;;;;==================================================================;;;;
USBRX_Run_N64: ; 0x03
    movlw   H'DD'
    movffl  WREG, U1TXB
    goto    N64Main
    
USBRX_Run_NES: ; 0x04
    movlw   H'DD'
    movffl  WREG, U1TXB
    goto    NESMain
    
    ;;;;==================================================================;;;;
USBRX_Write: ; 0xAA
    clrf    FLASH_ADDR_HIGH
    clrf    FLASH_ADDR_MID
    clrf    FLASH_ADDR_LOW
    
USBRX_Write_SectorLoop:
    call    FlashWriteEnable
    call    FlashEraseSector
    call    FlashWaitBusy
    
    movlw   D'16'
    movwf   LOOP_COUNT_1
USBRX_Write_PageLoop:
    
    lfsr    1, H'0100'
    movlw   H'01'
    movffl  WREG, U1TXB ; Ask if another page available
    movlw   0
    call    GrabNextUSBRX
    xorlw   H'01'
    btfss   STATUS, Z
    goto    ListenUSBCommands ; if page not available, then return, else continue
    
USBRX_Write_ByteLoop:
    call    GrabNextUSBRX
    movffl  WREG, U1TXB
    movffl  WREG, POSTINC1
    tstfsz  FSR1L   ; skip next if FSR1L == zero
    goto    USBRX_Write_ByteLoop
    
    call    FlashWriteEnable
    call    FlashWritePage
    call    FlashWaitBusy
    ;;
    infsnz  FLASH_ADDR_MID  ; increase pointer to location of next page
    incf    FLASH_ADDR_HIGH ; 
    
    decfsz  LOOP_COUNT_1
    goto    USBRX_Write_PageLoop
    ; if 16 pages have been written, the next sector must be erased before continuing...
    
    goto    USBRX_Write_SectorLoop