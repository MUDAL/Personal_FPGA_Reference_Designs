@echo off
mkdir build
cd build
echo:
echo =============================== Running Flatten Testbench ===============================
echo:
vsim -c -do "do ../scripts/flatten_tb.do"