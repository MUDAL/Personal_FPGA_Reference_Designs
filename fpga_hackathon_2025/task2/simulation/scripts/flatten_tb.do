# Create libraries
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile SystemVerilog design and testbench files
vlog -work work -sv -stats=none ../../src/lib/flatten.sv
vlog -work work -sv -stats=none ../testbench/flatten_tb.sv

# Load design
vsim work.flatten_tb

# Run simulation
run -all