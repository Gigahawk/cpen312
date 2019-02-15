from myhdl import block, Signal, always, intbv
from ring_counter import ring_counter


@block
def bcd_counter(clk, rst, dout0, dout1, din0, din1,
                ld, carry_out, min_val=0, max_val=59):
    carry = Signal(bool(0))
    one_rst = Signal(bool(1))
    one_rst_trigger = Signal(bool(1))
    din_0 = Signal(intbv(0, min=0, max=2**4))
    din_1 = Signal(intbv(0, min=0, max=2**4))
    dout_0 = Signal(intbv(0, min=0, max=2**4))
    dout_1 = Signal(intbv(0, min=0, max=2**4))


    @always(din0)
    def update_din_0():
        din_0.next = din0

    @always(din1)
    def update_din_1():
        din_1.next = din1

    @always(dout_0)
    def update_dout_0():
        dout0.next = dout_0

    @always(dout_1)
    def update_dout_1():
        dout1.next = dout_1

    @always(rst, one_rst_trigger)
    def internal_reset():
        one_rst.next = rst & one_rst_trigger

    @always(clk)
    def roll_counter():
        if clk:
            if ((dout1.val*10 - (max_val//10*10)) == 0 and
                    dout0.val == (max_val % 10)):
                one_rst_trigger.next = False
        else:
            one_rst_trigger.next = True

    counter0 = ring_counter(clk, one_rst, dout_0, din_0,
                            ld, carry, max_val=9)
    counter1 = ring_counter(carry, one_rst, dout_1, din_1,
                            ld, carry_out, max_val=max_val//10)

    return (counter0, counter1, roll_counter, internal_reset,
            update_din_0, update_din_1, update_dout_0, update_dout_1)


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
