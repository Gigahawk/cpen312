from myhdl import block, Signal, always, intbv, modbv, toVerilog, instance, delay
from math import log2, ceil


@block
def bcd_counter(clk, rst, dout0, dout1, din0, din1,
                ld, carry_out, min_val=0, max_val=59):

    val0 = Signal(modbv(min_val % 10, min=0, max=2**ceil(log2(9))))
    val1 = Signal(modbv(min_val // 10, min=0, max=2**ceil(log2(9))))
    din0_constrain = Signal(intbv(0)[4:])
    din1_constrain = Signal(intbv(0)[4:])

    ld_val0 = Signal(intbv(0)[4:])
    ld_val1 = Signal(intbv(0)[4:])

    @always(din0, din1)
    def constrain_din():
        din0_constrain.next = din0 if din0 < 9 else 9
        din1_constrain.next = din1 if din1 < 9 else 9
    
    @always(din0_constrain, din1_constrain)
    def set_load_val():
        if din1_constrain > intbv(max_val // 10)[4:]:
            ld_val0.next = intbv(max_val % 10)[4:]
            ld_val1.next = intbv(max_val // 10)[4:]
        elif din1_constrain == intbv(max_val // 10)[4:] and din0_constrain >= intbv(max_val % 10)[4:]:
            ld_val0.next = intbv(max_val % 10)[4:]
            ld_val1.next = intbv(max_val // 10)[4:]
        elif din1_constrain < intbv(min_val // 10)[4:]:
            ld_val0.next = intbv(min_val % 10)[4:]
            ld_val1.next = intbv(min_val // 10)[4:]
        elif din1_constrain == intbv(min_val // 10)[4:] and din0_constrain <= intbv(min_val % 10)[4:]:
            ld_val0.next = intbv(min_val % 10)[4:]
            ld_val1.next = intbv(min_val // 10)[4:]
        else:
            ld_val0.next = din0_constrain
            ld_val1.next = din1_constrain

    @always(clk.negedge, ld.negedge, rst.negedge)
    def logic():
        if not rst:
            carry_out.next = 1
            val0.next = intbv(min_val % 10)[4:]
            val1.next = intbv(min_val // 10)[4:]
        elif not ld:
            carry_out.next = 1
            val0.next = ld_val0
            val1.next = ld_val1
        else:
            val0.next = val0 + intbv(1)[4:]
            if val1.next >= intbv(max_val // 10)[4:] and val0.next >= intbv(max_val % 10)[4:]:
                carry_out.next = 0
                val0.next = intbv(min_val % 10)[4:]
                val1.next = intbv(min_val // 10)[4:]
            elif val0.next >= 9:
                val0.next = 0
                val1.next = val1 + intbv(1)[4:]
            else:
                carry_out.next = 1

    @always(val0, val1)
    def set_output():
        dout0.next = val0
        dout1.next = val1

    return set_output, logic, set_load_val, constrain_din


def convert_inst(hdl):
    clk = Signal(bool(0))
    rst = Signal(bool(1))
    dout = tuple([Signal(intbv(0, min=0, max=2**4)) for _ in range(2)])
    din = tuple([Signal(intbv(0, min=0, max=2**4)) for _ in range(2)])
    ld = Signal(bool(1))
    carry_out = Signal(bool(0))

    inst = bcd_counter(clk, rst, dout[0], dout[1], din[0], din[1],
                       ld, carry_out)

    inst.convert(hdl=hdl, name='bcd_counter')


if __name__ == '__main__':
    convert_inst('Verilog')
