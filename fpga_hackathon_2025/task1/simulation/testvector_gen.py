# Author: Olaoluwa Raji
# Date modified: 06/06/2026
# Python script to generate random test vectors
import random

TESTCASES = 5000

# Open files for writing.
file_tests = open("tests.txt",'w')
file_max   = open("max.txt",'w')

# Array of test vectors to be written to files.
int_array = []
str_array = []

"""
    Brief: Create test vectors to be written to the files that'll
    be referenced by the SystemVerilog testbench.
    
    Parameter:
    - newline: If true, add a newline to the string version of the
    test vectors. Otherwise, ignore newlines. Newlines separate
    successive test vectors.
"""
def create_test_vector(newline:bool):
    data_int = random.randint(-pow(2,15),pow(2,15)-1)
    data_str = str(data_int)
    if(newline):
        data_str = data_str  + '\n'
    int_array.append(data_int)
    str_array.append(data_str)

for i in range(TESTCASES-1):
    create_test_vector(newline=True)
create_test_vector(newline=False)

int_array.sort(reverse=True)
max_str = str(int_array[0])

file_tests.writelines(str_array)
file_max.write(max_str)

# Close all files.
file_tests.close()
file_max.close()