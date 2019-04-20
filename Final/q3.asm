; Each cycle is 30ns
gen_signal:
    setb P0.0 ; Pin goes high (First 2 cycles are before start of signal)
    nop       ; Wait 1 cycle
    clr P0.0  ; Pin goes low after 2 cycles
    nop       ; Wait 1 cycle
    setb P0.0 ; Pin goes high after 2 cycles
    clr P0.0  ; Pin goes low after 2 cycles
    nop       ; Wait 1 cycle
    nop       ; Wait 1 cycle
    setb P0.0 ; Pin goes high after 2 cycles
    nop       ; Wait 1 cycle
    clr P0.0  ; Pin goes low after 2 cycles
    ret       ; Return 3 cycles later
