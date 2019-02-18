import unittest
from random import randint
from myhdl import Simulation, Signal, delay, intbv, bin
from bcd_counter import bcd_counter


class TestBCDCounter(unittest.TestCase):
    def test_increment(self):
        def test(clk, rst, dout0, dout1, din0, din1, ld, carry_out, min_val, max_val):
            print()
            print(f'min_val = {min_val}, max_val = {max_val}')
            print('clock dout0 dout1 expected_output')
            print(f'{int(clk)} {dout0} {dout1} 0')

            for i in range(150):
                clk.next = not clk
                yield delay(10)
                print(f'{int(clk)} {dout0} {dout1} {(i+1)//2 % (max_val - min_val +1) + min_val}')
                if not clk:
                    self.assertEqual((i+1)//2 % (max_val - min_val + 1) + min_val,
                                     10*dout1 + dout0)

        self.run_test(test)

    def test_reset(self):
        def test(clk, rst, dout0, dout1, din0, din1, ld, carry_out, min_val, max_val):
            print()
            print(f'min_val = {min_val}, max_val = {max_val}')
            print('clock dout0 dout1 reset')
            print(f'{int(clk)} {dout0} {dout1} 0')
            for i in range(1000):
                clk.next = not clk
                if not randint(0, 10):
                    rst.next = not rst
                yield delay(10)
                print(f'{int(clk)} {dout0} {dout1} {int(rst)}')
                if not rst:
                    self.assertEqual(min_val % 10, dout0)
                    self.assertEqual(min_val // 10, dout1)

        self.run_test(test)

    def test_load(self):
        def test(clk, rst, dout0, dout1, din0, din1, ld, carry_out, min_val, max_val):
            print()
            print(f'min_val = {min_val}, max_val = {max_val}')
            print('clock dout0 dout1 din0 din1 load expected ld_in')
            print(f'{int(clk)} {dout0} {dout1} {din0} {din1} 0 0 0')
            for i in range(1000):
                ld_in = randint(0, 99)
                if ld_in < min_val:
                    expected = min_val
                elif ld_in > max_val:
                    expected = max_val
                else:
                    expected = ld_in

                din0.next = ld_in % 10
                din1.next = ld_in // 10
                yield delay(10)
                clk.next = not clk
                if not randint(0, 10):
                    ld.next = not ld
                yield delay(10)
                print(f'{int(clk)} {dout0} {dout1} {din0} {din1} {int(ld)} {expected} {ld_in}')
                if not ld:
                    self.assertEqual(expected, dout0 + dout1*10)

        self.run_test(test)

    def run_test(self, test):
        clk = Signal(bool(0))
        rst = Signal(bool(1))
        dout = tuple([Signal(intbv(0, min=0, max=2**4)) for _ in range(2)])
        din = tuple([Signal(intbv(0, min=0, max=2**4)) for _ in range(2)])
        ld = Signal(bool(1))
        carry_out = Signal(bool(0))

        inst = bcd_counter(clk, rst, dout[0], dout[1], din[0], din[1],
                           ld, carry_out, min_val=0, max_val=59)
        check = test(clk, rst, dout[0], dout[1], din[0], din[1],
                     ld, carry_out, 0, 59)
        sim = Simulation(inst, check)
        sim.run(quiet=1)

        inst = bcd_counter(clk, rst, dout[0], dout[1], din[0], din[1],
                           ld, carry_out, min_val=1, max_val=12)
        check = test(clk, rst, dout[0], dout[1], din[0], din[1],
                     ld, carry_out, 1, 12)
        sim = Simulation(inst, check)
        sim.run(quiet=1)


if __name__ == '__main__':
    unittest.main(verbosity=2)
