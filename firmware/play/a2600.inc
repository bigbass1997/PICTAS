; ===== Core A2600 Logic ===== ;
; This file is included/inserted in the main.asm file.

A2600Main:
    movlb   B'000000'
A2600Main_Loop:
    btfsc   PORTA, 7
    bsf	    LATD, 0
    
    btfss   PORTA, 7
    bcf	    LATD, 0
    
    goto    A2600Main_Loop