import unittest
from myhdl import Simulation, Signal, delay, intbv, bin
from clock_counter import clock_counter


class TestClockCounter(unittest.TestCase):
    def print_clock(self,
                    hex_lsd_s, hex_msd_s,
                    hex_lsd_m, hex_msd_m,
                    hex_lsd_h, hex_msd_h):
        bcd_to_int = (
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

        dec_lsd_s = bcd_to_int.index(hex_lsd_s)
        dec_msd_s = bcd_to_int.index(hex_msd_s)

        dec_lsd_m = bcd_to_int.index(hex_lsd_m)
        dec_msd_m = bcd_to_int.index(hex_msd_m)

        dec_lsd_h = bcd_to_int.index(hex_lsd_h)
        dec_msd_h = bcd_to_int.index(hex_msd_h)

        print(f'{dec_msd_h}{dec_lsd_h}:{dec_msd_m}{dec_lsd_m}:{dec_msd_s}{dec_lsd_s}')

        return (dec_msd_s*10 + dec_lsd_s,
                dec_msd_m*10 + dec_lsd_m,
                dec_msd_h*10 + dec_lsd_h)

    def test_clock(self):
        def test(clk, rst, din0, din1, ld_s, ld_m, ld_h,
                 hex_disp0, hex_disp1, hex_disp2,
                 hex_disp3, hex_disp4, hex_disp5):

            print()
            print('din output expected_output')
            self.print_clock(
                    hex_disp0, hex_disp1,
                    hex_disp2, hex_disp3,
                    hex_disp4, hex_disp5)

            # Set initial state of clock
            din0.next = 1
            din1.next = 1
            yield delay(10)
            ld_s.next = 0
            ld_m.next = 0
            ld_h.next = 0
            yield delay(10)
            ld_s.next = 1
            ld_m.next = 1
            ld_h.next = 1
            yield delay(10)

            (val_s, val_m, val_h) = self.print_clock(
                                        hex_disp0, hex_disp1,
                                        hex_disp2, hex_disp3,
                                        hex_disp4, hex_disp5)

            for i in range(12*3600*2):
                clk.next = not clk
                yield delay(10)
                if clk:
                    (val_s_new, val_m_new, val_h_new) = self.print_clock(
                            hex_disp0, hex_disp1,
                            hex_disp2, hex_disp3,
                            hex_disp4, hex_disp5)
                    if val_s_new == 0:
                        self.assertEqual(59, val_s)
                        if val_m_new == 0:
                            self.assertEqual(59, val_m)
                            if val_h_new == 1:
                                self.assertEqual(12, val_h)
                            else:
                                self.assertEqual(val_h + 1, val_h_new)
                        else:
                            self.assertEqual(val_m + 1, val_m_new)
                    else:
                        self.assertEqual(val_s + 1, val_s_new)

                    (val_s, val_m, val_h) = (val_s_new, val_m_new, val_h_new)

        self.run_test(test)

    def run_test(self, test):
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

        check = test(clk, rst, din[0], din[1], ld_s, ld_m, ld_h,
                     hex_disp[0], hex_disp[1], hex_disp[2],
                     hex_disp[3], hex_disp[4], hex_disp[5])
        sim = Simulation(inst, check)
        sim.run(quiet=1)


if __name__ == '__main__':
    unittest.main(verbosity=2)
