# Create libraries
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile SystemVerilog design and testbench files
vlog -work work -sv -stats=none ../../src/lib/flatten.sv
vlog -work work -sv -stats=none ../../src/lib/matrix_traverse.sv
vlog -work work -sv -stats=none ../../src/lib/memory.sv
vlog -work work -sv -stats=none ../../src/lib/memory_controller.sv
vlog -work work -sv -stats=none ../../src/task2.sv
vlog -work work -sv -stats=none ../testbench/task2_tb.sv

# Load design
vsim work.task2_tb

# Run simulation
run -all