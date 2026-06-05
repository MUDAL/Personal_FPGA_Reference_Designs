# Python script to generate random test vectors

import string
import random

TESTCASES = 100

# Hex codes for addition and multiplication operators.
MUL = 'A' # 0b1010
ADD = 'B' # 0b1011

# Open files for writing.
x_test_file  = open("x_test.txt",'w')
y_test_file  = open("y_test.txt",'w')
op_test_file = open("op_test.txt",'w')

# Array of test vectors to be written to files.
x_array  = []
y_array  = []
op_array = []

"""
    Brief: Create test vectors to be written to the files that'll
    be referenced by the Verilog testbench.
    
    Parameter:
    - newline: If true, add a newline to the string version of the
    test vectors. Otherwise, ignore newlines. Newlines separate
    successive test vectors.
"""
def create_test_vector(newline:bool):
    x_rand  = str(random.randint(0,99999))
    y_rand  = str(random.randint(0,99999))
    op_rand = str(random.choice([ADD,MUL]))

    if(newline):
        x_rand  = x_rand  + '\n'
        y_rand  = y_rand  + '\n'
        op_rand = op_rand + '\n'
        
    x_array.append(x_rand)
    y_array.append(y_rand)
    op_array.append(op_rand)

for i in range(TESTCASES-1):
    create_test_vector(newline=True)

create_test_vector(newline=False)

x_test_file.writelines(x_array)
y_test_file.writelines(y_array)
op_test_file.writelines(op_array)

# Close all files.
x_test_file.close()
y_test_file.close()
op_test_file.close()
