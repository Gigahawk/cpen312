from myhdl import block, Signal, always, instance, intbv, modbv
from math import log2, ceil


@block
def ring_counter(clk, rst, dout, din, ld, carry_out, min_val=0, max_val=9):
    val = Signal(modbv(min_val, min=min_val, max=2**ceil(log2(9))))

    @always(clk, rst, ld)
    def logic():
        carry_out.next = 0
        if not rst:
            val.next = min_val
        elif not ld:
            if din > max_val:
                val.next = max_val
            else:
                val.next = din
        elif clk:
            val.next = val + 1
            if val.next > max_val:
                val.next = min_val
                carry_out.next = 1

    @always(val)
    def set_output():
        dout.next = val

    return set_output, logic


def convert_inst(hdl):
    clk = Signal(bool(0))
    rst = Signal(bool(1))
    dout = Signal(intbv(0, min=0, max=16))
    din = Signal(intbv(0, min=0, max=16))
    ld = Signal(bool(1))
    carry_out = Signal(bool(0))

    inst = ring_counter(clk, rst, dout, din, ld, carry_out)

    inst.convert(hdl=hdl, name='ring_counter')


if __name__ == '__main__':
    convert_inst('Verilog')
    convert_inst('VHDL')
