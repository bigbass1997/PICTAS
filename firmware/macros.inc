wait macro cycles
    local three = cycles / 3
    local two = (cycles % 3) / 2
    local one = (cycles % 3) % 2

    while three > 0
        goto $+2
three--
    endw

    if two
        goto $+4
    endif

    if one
        nop
    endif
    endm
    
; 4 cycles
CopyRegBitToRegBit  macro fromPort, fromBit, toPort, toBit
    btfsc   fromPort, fromBit
    bsf     toPort, toBit
    btfss   fromPort, fromBit
    bcf     toPort, toBit
    endm
    
; same as CopyRegBitToRegBit, except that it inverts the output ; 1 -> 0, 0 -> 1
CopyRegBitToInvertRegBit  macro fromPort, fromBit, toPort, toBit
    btfsc   fromPort, fromBit
    bcf     toPort, toBit
    btfss   fromPort, fromBit
    bsf     toPort, toBit
    endm
    
; LOW, LOW, LOW, HIGH
TransmitZeroBit	macro port, bit, cutOvertime
    local overtime = D'15' - cutOvertime
    
    bcf	    port, bit
    wait D'47'
    bsf	    port, bit
    wait overtime
    endm
    
; LOW, HIGH, HIGH, HIGH
TransmitOneBit	macro port, bit, cutOvertime
    local overtime = D'47' - cutOvertime
    
    bcf	    port, bit
    wait D'15'
    bsf	    port, bit
    wait overtime
    endm
    
; LOW, LOW, HIGH, HIGH
TransmitContStopBit macro port, bit, cutOvertime
    local overtime = D'31' - cutOvertime
    
    bcf	    port, bit
    wait D'31'
    bsf	    port, bit
    wait overtime
    endm
    
; temporary macro to transmit literals to console
TXByTmp	    macro lit
    movlw   lit
    movwf   TX_DATA
    nop
    call    SendN64Byte
    
    endm
    