@echo off
mkdir build
cd build
echo:
echo =============================== Running Task2 Testbench ===============================
echo:
vsim -c -do "do ../scripts/task2_tb.do"