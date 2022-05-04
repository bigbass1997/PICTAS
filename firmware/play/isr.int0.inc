; External Interrupt ISR ;
; Currently only used by the A2600 ;
    
INT0ISR	    code	0x0300
    movlb   B'000000'
    bsf	    UTIL_FLAGS, 2 ; VSYNC occured
    
    BANKSEL PIR1
    bcf	    PIR1, INT0IF
    
    retfie
    