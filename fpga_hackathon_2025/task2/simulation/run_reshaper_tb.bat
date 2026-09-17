@echo off
mkdir build
cd build
echo:
echo =============================== Running Reshaper Testbench ===============================
echo:
vsim -c -do "do ../scripts/reshaper_tb.do"