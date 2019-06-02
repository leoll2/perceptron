from __future__ import division
from string import maketrans
import numpy as np
import math
import os


ARITH_TB = 'arith_tb/'
LUT_TB = 'lut_tb/'
NEURON_TB = 'neuron_tb'

complement_tt = maketrans('01', '10')


def is_neg_ctwo(x):
    """ Returns true if the given number (in two's complement) is negative """
    return True if x[0] == '1' else False


def ctwo_to_int(x):
    """ Returns the integer value corresponding to a given input represented in two's complement """
    if is_neg_ctwo(x):
        return -(2**(len(x)-1) - int(x[1:], 2))
    else:
        return int(x[1:], 2)


def int_to_ctwo(x, n_bit):
    """ Returns the two's complement (string) representation of the given integer """
    return format(x if x >= 0 else (1 << n_bit) + x, '0%db' % n_bit)


def sigmoid(x):
    """ Compute value of logistic (sigmoid) function for the given input """
    return 1 / (1 + math.exp(-x))


class ArithmeticUnit:

    def __init__(self):
        self.dim = 0
        self.x = []
        self.w = []
        self.b = 0

    def set_dim(self, dim):
        self.dim = dim

    def set_inputs(self, x_list):
        assert len(x_list) == self.dim
        self.x = [ctwo_to_int(x_ctwo) for x_ctwo in x_list]

    def set_weights(self, w_list):
        assert len(w_list) == self.dim
        self.w = [ctwo_to_int(w_ctwo) for w_ctwo in w_list]

    def set_bias(self, b):
        self.b = ctwo_to_int(b)

    def get_dim(self):
        return self.dim

    def get_inputs(self):
        return self.x

    def get_weights(self):
        return self.w

    def get_bias(self):
        return self.b

    def compute_output_integer(self):
        a = np.array(self.x)
        b = np.array(self.w)
        return np.dot(a, b) + 128 * self.b  # bias has to be extended with 7 zeros to the right, due to decimal point

    def compute_output_ctwo(self, n_bit, n_trunc=0):
        """ Compute the unit output as two's complement string with n_bit, truncating last n_trunc """
        out = int_to_ctwo(self.compute_output_integer(), n_bit)
        if n_trunc > 0:
            return out[0:-n_trunc]
        else:
            return out

    def arith_test(self):

        print 'Arithmetic unit tests'
        print 'Test \t| OutInt \t| OutCTwo \t\t\t\t| OutTrunc \t\t\t| OutTruncInt'
        print '-----------------------------------------------------------------------------'

        test_files = sorted(os.listdir(ARITH_TB))
        for filename in test_files:
            if filename.endswith(".txt"):
                test_path = os.path.join(ARITH_TB, filename)

                with open(test_path, "r") as f:
                    # Read dimension
                    dim = int(f.readline().rstrip('\n'))
                    # print 'dim ' + str(dim)
                    # Read blank line
                    assert f.readline() in ['\n', '\r\n']
                    # Read inputs
                    x = [f.readline().rstrip('\n') for _ in range(dim)]
                    # print 'x ' + str(x)
                    assert f.readline() in ['\n', '\r\n']
                    # Read weights
                    w = [f.readline().rstrip('\n') for _ in range(dim)]
                    # print 'w ' + str(w)
                    # Read blank line
                    assert f.readline() in ['\n', '\r\n']
                    # Read bias
                    b = f.readline().rstrip('\n')
                    # print 'b ' + str(b)
                    self.set_dim(dim)
                    self.set_inputs(x)
                    self.set_weights(w)
                    self.set_bias(b)
                    out_int = self.compute_output_integer()
                    out_ctwo = self.compute_output_ctwo(20)
                    out_trunc = self.compute_output_ctwo(20, 6)
                    print filename.rstrip('.txt') + ' \t| ' + str(out_int).ljust(8) + ' \t| ' + str(out_ctwo) + ' \t| ' + str(out_trunc) + ' \t| ' + str(ctwo_to_int(out_trunc))


class SigmoidLUT:

    def __init__(self, lut_addr_size, in_size, out_size):
        self.lut_addr_size = lut_addr_size
        self.in_size = in_size
        self.out_size = out_size

    def get_lut_output(self, x_str):
        """ Given input in two's complement string, find the corresponding sigmoid LUT output """
        in_int = int(x_str, 2)  # index is unsigned
        in_real = 8 * in_int / (1 << self.lut_addr_size)
        out_real = sigmoid(in_real)
        out_real -= 0.5
        out_int = int(math.floor(out_real * (1 << self.out_size)))
        out_str = format(out_int, "0%db" % (self.out_size-1))   # output is unsigned
        return out_str

    def in_to_out(self, addr_in_str):
        assert len(addr_in_str) == self.in_size

        r_most_bit = int(addr_in_str[0])
        r_most_bit_2 = int(addr_in_str[1])

        is_saturated = bool(r_most_bit) ^ bool(r_most_bit_2)
        is_second_region = bool(r_most_bit) and bool(r_most_bit_2)
        is_negative = bool(r_most_bit)

        out_mux_1 = addr_in_str[2:] if not is_saturated else format((1 << self.lut_addr_size)-1, "0%db" % self.lut_addr_size)
        out_mux_2 = out_mux_1 if not is_second_region else out_mux_1.translate(complement_tt)
        out_lut = '1' + self.get_lut_output(out_mux_2)
        out = out_lut if not is_negative else out_lut.translate(complement_tt)

        return out

    def lut_test(self):

        print 'LUT circuit tests'
        print 'Test \t| Input (5Q9) \t\t| Output (0Q11)'
        print '------------------------------------------'

        test_files = sorted(os.listdir(LUT_TB))
        for filename in test_files:
            if filename.endswith(".txt"):
                test_path = os.path.join(LUT_TB, filename)

                with open(test_path, "r") as f:
                    # Read input
                    lut_input = f.readline().rstrip('\n')
                    lut_output = self.in_to_out(lut_input)
                    print filename.rstrip('.txt') + ' \t| ' + lut_input + ' \t| ' + lut_output


class Perceptron:

    def __init__(self, lut_addr_size, in_size, out_size):
        self.arith = ArithmeticUnit()
        self.lut = SigmoidLUT(lut_addr_size, in_size, out_size)

    def produce_output(self):
        out_arith = self.arith.compute_output_ctwo(20, 6)
        out_lut = self.lut.in_to_out(out_arith)
        return out_lut + '00000'    # Extend to 16 bit

    def perceptron_test(self):
        print 'Perceptron neuron tests'
        print 'Test \t| Out (0Q16) \t\t| Out (raw) | Out (balanced)'
        print '--------------------------------------------------------'

        test_files = sorted(os.listdir(NEURON_TB))
        for filename in test_files:
            if filename.endswith(".txt"):
                test_path = os.path.join(NEURON_TB, filename)

                with open(test_path, "r") as f:
                    # Read dimension
                    dim = int(f.readline().rstrip('\n'))
                    # Read blank line
                    assert f.readline() in ['\n', '\r\n']
                    # Read inputs
                    x = [f.readline().rstrip('\n') for _ in range(dim)]
                    # print 'x ' + str(x)
                    assert f.readline() in ['\n', '\r\n']
                    # Read weights
                    w = [f.readline().rstrip('\n') for _ in range(dim)]
                    # print 'w ' + str(w)
                    # Read blank line
                    assert f.readline() in ['\n', '\r\n']
                    # Read bias
                    b = f.readline().rstrip('\n')
                    # print 'b ' + str(b)
                    self.arith.set_dim(dim)
                    self.arith.set_inputs(x)
                    self.arith.set_weights(w)
                    self.arith.set_bias(b)
                    out = self.produce_output()
                    out_real = int(out, 2) / (1 << 16)   # output is unsigned
                    out_shifted = out_real + 2**-12      # output + LSB/2
                    print filename.rstrip('.txt') + ' \t| ' + out + ' \t| ' + '{0:.4f}'.format(out_real) + ' \t|' + '{0:.4f}'.format(out_shifted)


if __name__ == "__main__":

    # Arithmetic
    arith = ArithmeticUnit()
    arith.arith_test()

    # Sigmoid LUT
    lut = SigmoidLUT(12, 14, 11)
    lut.lut_test()

    # Perceptron neuron
    neuron = Perceptron(12, 14, 11)
    neuron.perceptron_test()