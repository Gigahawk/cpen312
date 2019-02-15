import unittest
from random import randint
from myhdl import Simulation, Signal, delay, intbv, bin
from ring_counter import ring_counter


class TestRingCounter(unittest.TestCase):
    def test_increment(self):
        def test(clk, rst, dout, din, ld):
            compare = int(dout.val)
            print()
            print('Clock dOut compare')
            print(f'{int(clk)} {dout} {compare}')
            for i in range(30):
                clk.next = not clk
                compare = int(dout.val)
                # Make compare wrap around
                if compare == 9:
                    compare = -1
                yield delay(10)
                print(f'{int(clk)} {dout} {compare}')
                if clk:
                    self.assertEqual(compare + 1, dout)

        self.run_test(test)

    def test_reset(self):
        def test(clk, rst, dout, din, ld):
            print()
            print('Clock dOut reset')
            print(f'{int(clk)} {dout} {rst}')
            for i in range(100):
                clk.next = not clk
                if randint(0, 3):
                    rst.next = not rst
                yield delay(10)
                print(f'{int(clk)} {dout} {rst}')
                if not rst:
                    self.assertEqual(0, dout)

        self.run_test(test)

    def test_load(self):
        def test(clk, rst, dout, din, ld):
            rand = randint(0, 9)
            print()
            print('Clock dOut ld rand')
            print(f'{int(clk)} {dout} {int(ld)} {rand}')
            for i in range(100):
                rand = randint(0, 9)
                din.next = rand
                clk.next = not clk
                if not randint(0, 5):
                    ld.next = not ld
                yield delay(10)
                print(f'{int(clk)} {dout} {int(ld)} {rand}')
                if not ld:
                    self.assertEqual(rand, dout)

        self.run_test(test)

    def run_test(self, test):
        clk = Signal(bool(0))
        rst = Signal(bool(1))
        dout = Signal(intbv(0, min=0, max=10))
        din = Signal(intbv(0, min=0, max=10))
        ld = Signal(bool(1))

        inst = ring_counter(clk, rst, dout, din, ld)
        check = test(clk, rst, dout, din, ld)
        sim = Simulation(inst, check)
        sim.run(quiet=1)


if __name__ == '__main__':
    unittest.main(verbosity=2)
