# Create libraries
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile SystemVerilog design and testbench files
vlog -work work -sv -stats=none ../../src/lib/memory_controller.sv
vlog -work work -sv -stats=none ../testbench/memory_controller_tb.sv

# Load design
vsim work.memory_controller_tb

# Run simulation
run -all