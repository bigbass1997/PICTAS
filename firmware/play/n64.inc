; ===== Core N64 Logic ===== ;
; This file is included/inserted in the main.asm file.
    
N64Main:
    ; Prepare first replay frame
    call    FlashPrepareReadZero
    call    RetrieveNextFrame_N64
N64MainLoop:
    call    ListenForN64
    
    goto    N64MainLoop
    
ListenForN64:
    bsf     TRIS_N64_DATA ; set to input
    
WaitForN64DataHigh:
    btfss   PIN_N64_DATAIN
    goto    WaitForN64DataHigh
    
ListenForN64Loop:
    btfsc   PIN_N64_DATAIN
    goto    ListenForN64Loop        ; wait until datapin goes LOW
    
    call    DetermineDataToByte2
    movff   N64_DATA_DETER, N64_CMD_REG
    
    lfsr    1, N64_DATA_TMP0
LFNL_DecodeLoop:
    btfsc   PIN_N64_DATAIN
    goto    LFNL_DecodeLoop         ; wait until datapin goes LOW, if not already
    
    call    DetermineDataToByte2    ; will have 11 cycles left over
    movffl  N64_DATA_DETER, POSTINC1
    nop
    btfss   UTIL_FLAGS, 7
    goto    LFNL_DecodeLoop         ; if not skipped, 7 cycles will have been consumed after jumping
    
    bcf     UTIL_FLAGS, 7
    
    lfsr    1, N64_DATA_TMP0        ; reset FSR for command usage as needed
    
    ; N64_CMD_REG is now set with command from N64 console
    ; Below is where N64_CMD_REG will be checked against each Protocol command
    ; (in order of most to least common command)
    
    bcf     TRIS_N64_DATA ; set to output
    bsf     PIN_N64_DATAOUT
    
    movf    N64_CMD_REG, 0
    xorlw   N64_CMD_STATE
    btfsc   STATUS, Z
    goto N64Loop01
    
    movf    N64_CMD_REG, 0
    xorlw   N64_CMD_INFO
    btfsc   STATUS, Z
    goto N64Loop00
    
    movf    N64_CMD_REG, 0
    xorlw   N64_CMD_RESET
    btfsc   STATUS, Z
    goto N64LoopFF
    
    ; if this point is reached, no commands were identified. Wait a short time in case of any additional data
    movlw   D'224'
    movwf   PAUSE_REG_0
    movlw   D'4'
    movwf   PAUSE_REG_1
    call    Pause2D
    return
    
N64LoopFF:  ; Do 0xFF (reset/info) command here
    BANKSEL ZEROS_REG
    ;clrf    N64_STATE_REG3 ; resets x-axis
    ;clrf    N64_STATE_REG4 ; resets y-axis
    
    ; continue to N64Loop00...
    
N64Loop00:  ; Do 0x00 (info) command here
    BANKSEL ZEROS_REG
    
    movlw   0x05
    movwf   TX_DATA
    nop
    call    SendN64Byte
    
    movlw   0x00
    movwf   TX_DATA
    nop
    call    SendN64Byte
    
    movlw   0x02
    movwf   TX_DATA
    nop
    call    SendN64Byte
    call    SendN64StopBit
    
    goto ContinueLFNL
    
N64Loop01:  ; Do 0x01 (state) command here
    BANKSEL ZEROS_REG
    
    ; Transmit bytes to console
    movff   N64_STATE_REG1, TX_DATA
    nop
    call    SendN64Byte
    movff   N64_STATE_REG2, TX_DATA
    nop
    call    SendN64Byte
    movff   N64_STATE_REG3, TX_DATA
    nop
    call    SendN64Byte
    movff   N64_STATE_REG4, TX_DATA
    nop
    call    SendN64Byte
    call    SendN64StopBit
    
    call    RetrieveNextFrame_N64
    
    goto ContinueLFNL
    
    
ContinueLFNL:
    return
    