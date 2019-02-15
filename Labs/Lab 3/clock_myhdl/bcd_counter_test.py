import unittest
from random import randint
from myhdl import Simulation, Signal, delay, intbv, bin
from bcd_counter import bcd_counter


class TestBCDCounter(unittest.TestCase):
    def test_increment(self):
        def test(clk, rst, dout0, dout1, din0, din1, ld, carry_out, max_val):
            print()
            print(f'max_val = {max_val}')
            print('clock dout0 dout1 expected_output')
            print(f'{int(clk)} {dout0} {dout1} 0')

            for i in range(150):
                clk.next = not clk
                yield delay(10)
                print(f'{int(clk)} {dout0} {dout1} {(i+1)//2 % (max_val+1)}')
                if not clk:
                    self.assertEqual((i+1)//2 % (max_val + 1),
                                     10*dout1 + dout0)

        self.run_test(test)

    def test_reset(self):
        def test(clk, rst, dout0, dout1, din0, din1, ld, carry_out, max_val):
            print()
            print(f'max_val = {max_val}')
            print('clock dout0 dout1 reset')
            print(f'{int(clk)} {dout0} {dout1} 0')
            for i in range(1000):
                clk.next = not clk
                if not randint(0, 10):
                    rst.next = not rst
                yield delay(10)
                print(f'{int(clk)} {dout0} {dout1} {int(rst)}')
                if not rst:
                    self.assertEqual(0, dout0)

        self.run_test(test)

    def run_test(self, test):
        clk = Signal(bool(0))
        rst = Signal(bool(1))
        dout = tuple([Signal(intbv(0, min=0, max=2**4)) for _ in range(2)])
        din = tuple([Signal(intbv(0, min=0, max=2**4)) for _ in range(2)])
        ld = Signal(bool(1))
        carry_out = Signal(bool(0))

        inst = bcd_counter(clk, rst, dout[0], dout[1], din[0], din[1],
                           ld, carry_out, max_val=59)
        check = test(clk, rst, dout[0], dout[1], din[0], din[1],
                     ld, carry_out, 59)
        sim = Simulation(inst, check)
        sim.run(quiet=1)

        inst = bcd_counter(clk, rst, dout[0], dout[1], din[0], din[1],
                           ld, carry_out, max_val=12)
        check = test(clk, rst, dout[0], dout[1], din[0], din[1],
                     ld, carry_out, 12)
        sim = Simulation(inst, check)
        sim.run(quiet=1)


if __name__ == '__main__':
    unittest.main(verbosity=2)
