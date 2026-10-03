@echo off
mkdir build
cd build
echo:
echo =============================== Running Task1 Testbench ===============================
echo:
vsim -c -do "do ../task1_tb.do"