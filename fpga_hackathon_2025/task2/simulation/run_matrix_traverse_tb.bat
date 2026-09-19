@echo off
mkdir build
cd build
echo:
echo =============================== Running Matrix Traverse Testbench ===============================
echo:
vsim -c -do "do ../scripts/matrix_traverse_tb.do"