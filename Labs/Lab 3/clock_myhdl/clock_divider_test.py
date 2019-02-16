import unittest
from random import randint
from myhdl import Simulation, Signal, delay, intbv, bin
from clock_divider import clock_divider

class TestClockDivider(unittest.TestCase):
    def test_clock(self):
        
        def test(clk, out, in_freq, out_freq):
            cycles = randint(2, 5)
            count = 0
            val = 0

            print(f'Running {cycles} cycles')

            for i in range(cycles*in_freq):
                out_old = int(out.val)
                clk.next = not clk
                yield delay(10)
                if clk:
                    val += 1
                if out_old == 0 and int(out.val) == 1:
                    count += 1
                print(f'Count: {count}, val: {val}')

            self.assertEqual(cycles, count)

        self.run_test(test)
    
    def run_test(self, test):
        clk = Signal(bool(0))
        out = Signal(bool(0))

        inst = clock_divider(clk, out, in_freq=50, out_freq=2)
        check = test(clk, out, 50, 2)
        sim = Simulation(inst, check)
        sim.run(quiet=1)


if __name__ == '__main__':
    unittest.main(verbosity=2)
