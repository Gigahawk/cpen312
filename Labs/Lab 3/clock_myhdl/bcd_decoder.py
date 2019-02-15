from myhdl import block, always, Signal, intbv


@block
def bcd_decoder(bcd, hex_disp):
    outputs = (
        0b1000000,
        0b1111001,
        0b0100100,
        0b0110000,
        0b0011001,
        0b0010010,
        0b0000010,
        0b1111000,
        0b0000000,
        0b0010000
    )

    @always(bcd)
    def display():
        if bcd >= 0 and bcd <= 9:
            hex_disp.next = outputs[bcd]
        else:
            hex_disp.next = 0b1111111

    return display


def convert_inst(hdl):
    din = Signal(intbv(0)[4:])
    hex_disp = Signal(intbv(0)[7:])

    inst = bcd_decoder(din, hex_disp)

    inst.convert(hdl=hdl, name='bcd_decoder')


if __name__ == '__main__':
    convert_inst('Verilog')
    convert_inst('VHDL')
