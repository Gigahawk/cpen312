from myhdl import block, Signal, always, intbv, modbv
from math import log2, ceil


@block
def bcd_counter(clk, rst, dout0, dout1, din0, din1,
                ld, carry_out, min_val=0, max_val=59):

    val = Signal(modbv(min_val, min=0, max=2**ceil(log2(max_val))))

    @always(clk, rst, ld)
    def logic():
        carry_out.next = 0
        if not rst:
            val.next = min_val
        elif not ld:
            ld_val = din1*10 + din0
            if ld_val > max_val:
                ld_val = max_val
            val.next = ld_val
        elif clk:
            val.next = val + 1
            if val.next > max_val:
                val.next = min_val
                carry_out.next = 1

    @always(val)
    def set_output():
        dout0.next = val % 10
        dout1.next = val // 10

    return set_output, logic


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
    convert_inst('VHDL')
