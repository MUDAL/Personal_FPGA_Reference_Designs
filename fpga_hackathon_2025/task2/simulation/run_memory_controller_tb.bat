@echo off
mkdir build
cd build
echo:
echo =============================== Running Memory Controller Testbench ===============================
echo:
vsim -c -do "do ../scripts/memory_controller_tb.do"