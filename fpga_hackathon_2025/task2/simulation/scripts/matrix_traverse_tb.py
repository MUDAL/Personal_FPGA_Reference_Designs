# Author: Olaoluwa Raji
# Date:   17/08/2026

###############################################################################

import numpy as np
from   enum  import Enum

NUM_ROWS = 4
NUM_COLS = 8

index_arr:   np.ndarray = np.arange(NUM_ROWS*NUM_COLS, dtype=np.uint32)
index_arr2d: np.ndarray = index_arr.reshape((NUM_ROWS,NUM_COLS))

rows,cols = index_arr2d.shape

left_column  = index_arr2d[:,0]
right_column = index_arr2d[:,cols-1]
top_row      = index_arr2d[0,:]
bottom_row   = index_arr2d[rows-1,:]

###############################################################################

## Traversing the data array

# States
class State(Enum):
    HORIZONTAL = 1
    DIAGONAL   = 2
    VERTICAL   = 3
    END        = 4

curr_state: State      = State.HORIZONTAL
prev_state: State      = State.HORIZONTAL
diag_incr:  bool       =   False
i_data:     int        =     0
i_trav:     int        =     0
data_arr:   np.ndarray = np.arange(NUM_ROWS*NUM_COLS, dtype=np.uint32)
trav_arr:   np.ndarray = np.zeros( NUM_ROWS*NUM_COLS, dtype=np.uint32)

def change_state_to(state: State) -> None:
    global prev_state, curr_state
    prev_state = curr_state
    curr_state = state

# FSM
while True:
    if curr_state == State.HORIZONTAL:
        trav_arr[i_trav] = data_arr[i_data]
        i_trav           = i_trav + 1
        i_data           = i_data + 1
        diag_incr        = i_data in top_row
        if i_data == (NUM_ROWS*NUM_COLS-1) and i_trav == (NUM_ROWS*NUM_COLS-1):
            change_state_to(State.END)
        else:
            change_state_to(State.DIAGONAL)

    elif curr_state == State.DIAGONAL:  
        if prev_state == State.HORIZONTAL or prev_state == State.VERTICAL:
            if diag_incr:
                trav_arr[i_trav] = data_arr[i_data]
                i_trav           = i_trav + 1
                i_data           = i_data + NUM_COLS - 1
                if i_data in bottom_row and i_data != bottom_row[-1]:
                    change_state_to(State.HORIZONTAL)
                elif i_data in left_column and i_data != left_column[-1]:
                    change_state_to(State.VERTICAL)
            else:
                trav_arr[i_trav] = data_arr[i_data]
                i_trav           = i_trav + 1
                i_data           = i_data - (NUM_COLS - 1)
                if i_data in top_row and i_data != top_row[-1]:
                    change_state_to(State.HORIZONTAL)
                elif i_data in right_column and i_data != right_column[-1]:
                    change_state_to(State.VERTICAL)

    elif curr_state == State.VERTICAL:
        trav_arr[i_trav] = data_arr[i_data]
        i_trav           = i_trav + 1
        i_data           = i_data + NUM_COLS
        diag_incr        = i_data in right_column
        if i_data == (NUM_ROWS*NUM_COLS-1) and i_trav == (NUM_ROWS*NUM_COLS-1):
            change_state_to(State.END)
        else:
            change_state_to(State.DIAGONAL)

    else:
        trav_arr[i_trav] = data_arr[i_data]
        break

###############################################################################

## Input and Output Files

# Requirements:
# 1. The input file should contain the following:
# a. Number of columns in the matrix.
# b. Number of rows in the matrix.
# c. Matrix elements.

# 2. The output file should contain the traversed matrix elements.

input_data:  np.ndarray = np.zeros(NUM_ROWS*NUM_COLS+2, dtype=np.uint32)
output_data: np.ndarray = np.zeros(NUM_ROWS*NUM_COLS)
input_data[0]  = NUM_COLS
input_data[1]  = NUM_ROWS
input_data[2:] = data_arr
output_data    = trav_arr

# References for converting elements of Numpy arrays into characters/strings: 
# 1. https://stackoverflow.com/a/9966572
# 2. https://numpy.org/doc/stable/reference/generated/numpy.char.mod.html

with open("matrix_traverse_inputs.txt", "w") as f_input:
    f_input.writelines(np.strings.mod("%d\n", input_data))

with open("matrix_traverse_outputs.txt", "w") as f_output:
    f_output.writelines(np.strings.mod("%d\n", output_data))