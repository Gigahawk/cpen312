import unittest
from myhdl import Simulation, Signal, delay, intbv, bin
from bcd_decoder import bcd_decoder


class TestBCDDecoder(unittest.TestCase):
    def test_disp(self):
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

        def test(din, hex_disp):
            # Output doesn't seem to update until input is changed
            din.next = 1
            yield delay(10)

            print()
            print('din output expected_output')

            for i in range(13):
                din.next = i
                yield delay(10)
                exp_output = outputs[i] if i <= 9 else 0b1111111
                print(f'{din} {bin(hex_disp)} {bin(exp_output)}')
                if i >= 0 and i <= 9:
                    self.assertEqual(hex_disp, exp_output)
                else:
                    self.assertEqual(hex_disp, exp_output)

        self.run_test(test)

    def run_test(self, test):
        din = Signal(intbv(0)[4:])
        hex_disp = Signal(intbv(0)[7:])

        inst = bcd_decoder(din, hex_disp)
        check = test(din, hex_disp)
        sim = Simulation(inst, check)
        sim.run(quiet=1)


if __name__ == '__main__':
    unittest.main(verbosity=2)
