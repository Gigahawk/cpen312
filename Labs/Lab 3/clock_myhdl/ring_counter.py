from myhdl import block, Signal, always, instance, intbv, modbv


@block
def ring_counter(clk, rst, dout, din, ld, min_val=0, max_val=9):
    val = Signal(modbv(min_val, min=min_val, max=2**4))

    @always(clk, rst, ld)
    def logic():
        if not rst:
            val.next = min_val
        elif not ld:
            val.next = din
        elif clk:
            val.next = val + 1
            if val.next > max_val:
                val.next = min_val


    @always(val)
    def set_output():
        dout.next = val

    return set_output, logic


def convert_inst(hdl):
    clk = Signal(bool(0))
    rst = Signal(bool(1))
    dout = Signal(intbv(0, min=0, max=10))
    din = Signal(intbv(0, min=0, max=10))
    ld = Signal(bool(1))

    inst = ring_counter(clk, rst, dout, din, ld)

    inst.convert(hdl=hdl, name='ring_counter')


if __name__ == '__main__':
    convert_inst('Verilog')
    convert_inst('VHDL')




