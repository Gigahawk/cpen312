from myhdl import block, Signal, always, intbv
from bcd_counter import bcd_counter
from bcd_decoder import bcd_decoder


@block
def clock_counter(clk, rst, din0, din1, ld_s, ld_m, ld_h,
                  hex_disp0, hex_disp1, hex_disp2,
                  hex_disp3, hex_disp4, hex_disp5):

    LSD_s = Signal(intbv(0, min=0, max=2**4))
    MSD_s = Signal(intbv(0, min=0, max=2**4))
    LSD_m = Signal(intbv(0, min=0, max=2**4))
    MSD_m = Signal(intbv(0, min=0, max=2**4))
    LSD_h = Signal(intbv(0, min=0, max=2**4))
    MSD_h = Signal(intbv(0, min=0, max=2**4))

    carry_sm = Signal(bool(0))
    carry_mh = Signal(bool(0))

    counter_s = bcd_counter(clk, rst, LSD_s, MSD_s, din0, din1,
                            ld_s, carry_sm)
    counter_m = bcd_counter(carry_sm, rst, LSD_m, MSD_m, din0, din1,
                            ld_m, carry_mh)
    counter_h = bcd_counter(carry_mh, rst, LSD_h, MSD_h, din0, din1,
                            ld_h, Signal(bool(0)), min_val=1, max_val=12)

    hex_LSD_s = bcd_decoder(LSD_s, hex_disp0)
    hex_MSD_s = bcd_decoder(MSD_s, hex_disp1)
    hex_LSD_m = bcd_decoder(LSD_m, hex_disp2)
    hex_MSD_m = bcd_decoder(MSD_m, hex_disp3)
    hex_LSD_h = bcd_decoder(LSD_h, hex_disp4)
    hex_MSD_h = bcd_decoder(MSD_h, hex_disp5)

    return (counter_s, counter_m, counter_h,
            hex_LSD_s, hex_MSD_s,
            hex_LSD_m, hex_MSD_m,
            hex_LSD_h, hex_MSD_h)

def convert_inst(hdl):
    clk = Signal(bool(0))
    rst = Signal(bool(1))
    din = tuple([Signal(intbv(0, min=0, max=2**4)) for _ in range(2)])
    ld_s = Signal(bool(1))
    ld_m = Signal(bool(1))
    ld_h = Signal(bool(1))
    hex_disp = tuple([Signal(intbv(0)[7:]) for _ in range(6)])

    inst = clock_counter(clk, rst, din[0], din[1], ld_s, ld_m, ld_h,
                         hex_disp[0], hex_disp[1], hex_disp[2],
                         hex_disp[3], hex_disp[4], hex_disp[5])

    inst.convert(hdl=hdl, name='clock_counter')

if __name__ == '__main__':
    convert_inst('Verilog')
