# Execute Python script to generate test vectors
cd ../scripts
if {$tcl_platform(os) eq "Windows NT"} {
    exec python matrix_traverse_tb.py
} else {
    exec python3 matrix_traverse_tb.py
}

# Ensure you're in the build directory before compiling sources and running simulation
# Reason: ModelSim auto-generated files will be dumped here
cd ../build

# Create libraries
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile SystemVerilog design and testbench files
vlog -work work -sv -stats=none ../../src/lib/reshaper.sv
vlog -work work -sv -stats=none ../../src/lib/memory.sv
vlog -work work -sv -stats=none ../../src/lib/matrix_traverse.sv
vlog -work work -sv -stats=none ../testbench/matrix_traverse_tb.sv

# Load design
vsim work.matrix_traverse_tb

# Run simulation
run -all