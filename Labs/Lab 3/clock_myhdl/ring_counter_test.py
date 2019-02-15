import unittest
from random import randint
from myhdl import Simulation, Signal, delay, intbv, bin
from ring_counter import ring_counter


class TestRingCounter(unittest.TestCase):
    def test_increment(self):
        def test(clk, rst, dout, din, ld, carry_out, max_val):
            compare = int(dout.val)
            print()
            print(f'max_val = {max_val}')
            print('Clock dOut compare carry_out')
            print(f'{int(clk)} {dout} {compare} {int(carry_out)}')
            for i in range(30):
                clk.next = not clk
                compare = int(dout.val)
                # Make compare wrap around
                if compare == max_val:
                    compare = -1
                yield delay(10)
                print(f'{int(clk)} {dout} {compare} {int(carry_out)}')
                if clk:
                    self.assertEqual(compare + 1, dout)
                    if compare == -1:
                        self.assertEqual(1, carry_out)

        self.run_test(test)

    def test_reset(self):
        def test(clk, rst, dout, din, ld, carry_out, max_val):
            print()
            print('Clock dOut reset')
            print(f'{int(clk)} {dout} {rst}')
            for i in range(100):
                clk.next = not clk
                if randint(0, 3):
                    rst.next = not rst
                yield delay(10)
                print(f'{int(clk)} {dout} {int(rst)}')
                if not rst:
                    self.assertEqual(0, dout)

        self.run_test(test)

    def test_load(self):
        def test(clk, rst, dout, din, ld, carry_out, max_val):
            rand = randint(0, 9)
            compare = rand if rand <= max_val else max_val
            print()
            print(f'max_val = {max_val}')
            print('Clock dOut ld rand compare')
            print(f'{int(clk)} {dout} {int(ld)} {rand} {compare}')
            for i in range(100):
                rand = randint(0, max_val+3)
                compare = rand if rand <= max_val else max_val
                din.next = rand
                clk.next = not clk
                if not randint(0, 5):
                    ld.next = not ld
                yield delay(10)
                print(f'{int(clk)} {dout} {int(ld)} {rand} {compare}')
                if not ld:
                    self.assertEqual(compare, dout)

        self.run_test(test)

    def run_test(self, test):
        clk = Signal(bool(0))
        rst = Signal(bool(1))
        dout = Signal(intbv(0, min=0, max=16))
        din = Signal(intbv(0, min=0, max=16))
        ld = Signal(bool(1))
        carry_out = Signal(bool(0))

        inst = ring_counter(clk, rst, dout, din, ld, carry_out)
        check = test(clk, rst, dout, din, ld, carry_out, 9)
        sim = Simulation(inst, check)
        sim.run(quiet=1)
        inst = ring_counter(clk, rst, dout, din, ld, carry_out, max_val=5)
        check = test(clk, rst, dout, din, ld, carry_out, 5)
        sim = Simulation(inst, check)
        sim.run(quiet=1)


if __name__ == '__main__':
    unittest.main(verbosity=2)
