""" Script to generate VHDL Look-Up Table (LUT) code for sigmoid function """

from __future__ import division
import math

# Input size
N_BIT_IN_INT = 5    # [bit] integer part of the input
N_BIT_IN_DEC = 8    # [bit] decimal part of the input
N_BIT_IN = N_BIT_IN_INT + N_BIT_IN_DEC

# Output size
N_BIT_OUT = 10      # [bit]

# File
LUT_FILE_NAME = 'lut.txt'
LUT_OPT_FILE_NAME = 'lut_optimized.txt'


def sigmoid(x):
    return 1 / (1 + math.exp(-x))


# Returns true if the given number (in two's complement) is negative
def is_neg_ctwo(x):
    return True if x[0] == '1' else False


# Two's complement representation to corresponding integer
def ctwo_to_int(x):
    if is_neg_ctwo(x):
        return -(2**(len(x)-1) - int(x[1:], 2))
    else:
        return int(x[1:], 2)


def lut_in_to_out(x, n_bit_in, optimized=False):
    in_bit = format(x, "0%db" % n_bit_in)
    in_int = ctwo_to_int(in_bit)
    in_real = in_int / (1 << N_BIT_IN_DEC)
    out_real = sigmoid(in_real)
    if optimized:
        out_real -= 0.5
    out_int = int(round(out_real * (1 << N_BIT_OUT)))
    return out_int


def generate_lut(n_bit_in):

    fout = open(LUT_FILE_NAME, 'w+')
    fout.write('Elements: ' + str(1 << n_bit_in) + '\n\n')

    lut = [lut_in_to_out(i, n_bit_in) for i in range(1 << n_bit_in)]
    fout.write(','.join(map(str, lut)))


def generate_lut_optimized(n_bit_in):

    fout = open(LUT_OPT_FILE_NAME, 'w+')
    fout.write('Elements: ' + str(1 << n_bit_in-1) + '\n\n')

    lut_opt = [lut_in_to_out(i, n_bit_in, True) for i in range(1 << n_bit_in-1)]
    fout.write(','.join(map(str, lut_opt)))


if __name__ == "__main__":
    generate_lut(N_BIT_IN)
    generate_lut_optimized(N_BIT_IN)
