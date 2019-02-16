from myhdl import block, Signal, always, intbv, modbv
from math import log2, ceil


@block
def clock_divider(clk, out, in_freq=50*10**6, out_freq=1):
    max_count = int(in_freq / (out_freq*2))
    count = Signal(modbv(0, min=0, max=2**ceil(log2(max_count))))

    @always(clk.posedge)
    def logic():
        count.next = count + 1
        if count.next > max_count:
            count.next = 0
            out.next = not out

    return logic


def convert_inst(hdl):
    clk = Signal(bool(0))
    out = Signal(bool(0))

    inst = clock_divider(clk, out)

    inst.convert(hdl=hdl, name='clock_divider')


if __name__ == '__main__':
    convert_inst('Verilog')
    convert_inst('VHDL')



