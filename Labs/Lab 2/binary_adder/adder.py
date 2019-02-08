from myhdl import block, always, Signal, intbv, toVHDL, toVerilog


@block
def adder(num, key_A, key_B, sw_add, leds):
    reg_A = Signal(intbv(0)[8:])
    reg_B = Signal(intbv(0)[8:])

    @always(key_A.negedge)
    def latch_A():
        reg_A.next = num

    @always(key_B.negedge)
    def latch_B():
        reg_B.next = num

    @always(reg_A, reg_B, sw_add)
    def logic():
        if(sw_add):
            leds.next = reg_A + reg_B
        else:
            leds.next = reg_A - reg_B

    return logic, latch_A, latch_B


def convert_inst(hdl):
    num = Signal(intbv(0)[8:])
    key_A = Signal(intbv(0)[1:])
    key_B = Signal(intbv(0)[1:])
    sw_add = Signal(intbv(0)[1:])
    leds = Signal(intbv(0)[9:])

    inst = adder(num, key_A, key_B, sw_add, leds)

    inst.convert(hdl=hdl, name='adder')


convert_inst('Verilog')
convert_inst('VHDL')

