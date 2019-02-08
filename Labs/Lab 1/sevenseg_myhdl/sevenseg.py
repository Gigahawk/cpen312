from myhdl import block, always, Signal, intbv, toVHDL, toVerilog


@block
def sevenseg(keys, hex_display):

    wires = Signal(intbv(0)[8:])

    @always(keys)
    def gates():
        wires[0] = not (keys[0] & keys[1])
        wires[1] = not (wires[0] & wires[0])
        wires[2] = not (wires[4] & keys[1])
        wires[3] = not (wires[2] & wires[2])
        wires[4] = not (keys[0] & keys[0])
        wires[5] = not (wires[4] & wires[7])
        wires[6] = not (wires[5] & wires[5])
        wires[7] = not (keys[1] & keys[1])

        a = wires[3]
        b = wires[1]
        c = 0
        d = a
        e = wires[0]
        f = wires[6]
        g = 0

        hex_display[0] = a
        hex_display[1] = b
        hex_display[2] = c
        hex_display[3] = d
        hex_display[4] = e
        hex_display[5] = f
        hex_display[6] = g

    return gates


def convert_inst(hdl):
    keys = Signal(intbv(0)[2:])
    hex_display = Signal(intbv(0)[7:])

    inst = sevenseg(keys, hex_display)

    inst.convert(hdl=hdl, name='sevenseg')


convert_inst('Verilog')
convert_inst('VHDL')
