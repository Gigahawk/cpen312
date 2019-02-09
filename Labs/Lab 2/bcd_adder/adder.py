from myhdl import block, always, Signal, intbv


@block
def bcd_latch(D1, D2, E, Q1, Q2):
    @always(E.negedge)
    def logic():
        Q1.next = D1
        Q2.next = D2

    return logic


@block
def bcd_to_hex(bcd, hex_disp):
    @always(bcd)
    def display():
        if bcd == 0:
            hex_disp.next = 0b1000000
        elif bcd == 1:
            hex_disp.next = 0b1111001
        elif bcd == 2:
            hex_disp.next = 0b0100100
        elif bcd == 3:
            hex_disp.next = 0b0110000
        elif bcd == 4:
            hex_disp.next = 0b0011001
        elif bcd == 5:
            hex_disp.next = 0b0010010
        elif bcd == 6:
            hex_disp.next = 0b0000010
        elif bcd == 7:
            hex_disp.next = 0b1111000
        elif bcd == 8:
            hex_disp.next = 0b0000000
        elif bcd == 9:
            hex_disp.next = 0b0010000
        else:
            hex_disp.next = 0b1111111

    return display


@block
def adder(MSD, LSD, key_A, key_B, sw_add, overflow,
          hex_disp0, hex_disp1, hex_disp2,
          hex_disp3, hex_disp4, hex_disp5):
    reg_A_MSD = Signal(intbv(0)[4:])
    reg_A_LSD = Signal(intbv(0)[4:])
    reg_B_MSD = Signal(intbv(0)[4:])
    reg_B_LSD = Signal(intbv(0)[4:])

    reg_in_LSD = Signal(intbv(0)[4:])
    reg_in_MSD = Signal(intbv(0)[4:])

    reg_sum_LSD = Signal(intbv(0)[4:])
    reg_sum_MSD = Signal(intbv(0)[4:])

    latch_A = bcd_latch(reg_in_MSD, reg_in_LSD, key_A, reg_A_MSD, reg_A_LSD)
    latch_B = bcd_latch(reg_in_MSD, reg_in_LSD, key_B, reg_B_MSD, reg_B_LSD)

    @always(MSD, LSD)
    def constrain():
        if MSD > 9:
            reg_in_MSD.next = 9
        else:
            reg_in_MSD.next = MSD

        if LSD > 9:
            reg_in_LSD.next = 9
        else:
            reg_in_LSD.next = LSD

    @always(reg_A_MSD, reg_A_LSD, reg_B_MSD, reg_B_LSD, sw_add)
    def logic():

        if(sw_add):
            lsd_sum = reg_A_LSD + reg_B_LSD
            msd_sum = reg_A_MSD + reg_B_MSD
            if(lsd_sum > 9):
                lsd_sum -= 10
                msd_sum += 1
            reg_sum_LSD.next = lsd_sum
            reg_sum_MSD.next = msd_sum
            if (msd_sum > 9):
                overflow.next = True
            else:
                overflow.next = False
        else:
            lsd_sum = reg_A_LSD - reg_B_LSD
            msd_sum = reg_A_MSD - reg_B_MSD
            if(lsd_sum < 0):
                lsd_sum += 10
                msd_sum -= 1
            reg_sum_LSD.next = lsd_sum
            reg_sum_MSD.next = msd_sum
            if (msd_sum < 0):
                overflow.next = True
            else:
                overflow.next = False

    bcd_to_hex5 = bcd_to_hex(reg_A_MSD, hex_disp5)
    bcd_to_hex4 = bcd_to_hex(reg_A_LSD, hex_disp4)
    bcd_to_hex3 = bcd_to_hex(reg_B_MSD, hex_disp3)
    bcd_to_hex2 = bcd_to_hex(reg_B_LSD, hex_disp2)
    bcd_to_hex1 = bcd_to_hex(reg_sum_MSD, hex_disp1)
    bcd_to_hex0 = bcd_to_hex(reg_sum_LSD, hex_disp0)

    return (logic, constrain, latch_A, latch_B,
            bcd_to_hex0, bcd_to_hex1, bcd_to_hex2,
            bcd_to_hex3, bcd_to_hex4, bcd_to_hex5)


def convert_inst(hdl):
    MSD = Signal(intbv(0)[4:])
    LSD = Signal(intbv(0)[4:])
    key_A = Signal(intbv(0)[1:])
    key_B = Signal(intbv(0)[1:])
    sw_add = Signal(intbv(0)[1:])
    overflow = Signal(intbv(0)[1:])
    hex_displays = tuple([Signal(intbv(0)[7:]) for _ in range(6)])

    inst = adder(MSD, LSD, key_A, key_B, sw_add, overflow,
                 hex_displays[0], hex_displays[1], hex_displays[2],
                 hex_displays[3], hex_displays[4], hex_displays[5])

    inst.convert(hdl=hdl, name='adder')


convert_inst('Verilog')
convert_inst('VHDL')

