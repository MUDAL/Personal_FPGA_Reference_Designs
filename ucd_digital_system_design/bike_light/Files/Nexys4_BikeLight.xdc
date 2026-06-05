# This file is a constraint file for the Nexys4 rev B board, 
# for use in the bicycle light design assignment.
# It only includes the signals that might be needed in that assignment.
# Signal names here must match the port names on the top-level module.

# In this file, # marks a comment line.  If you select a block of lines
# and un-comment them all, the lines with ## will remain as comments.


#These lines specify voltages used during configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#This line specifies generation of a compressed bitstream, for faster configuration
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

#==================================================================================

# Clock signal - from 100 MHz clock oscillator on the circuit board
#Bank = 35, Pin name = IO_L12P_T1_MRCC_35,					Sch name = CLK100MHZ
set_property PACKAGE_PIN E3 [get_ports clk100]
set_property IOSTANDARD LVCMOS33 [get_ports clk100]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk100]

#==================================================================================

# Buttons - pushbutton switches
# First is the red button marked CPU RESET.  Signal is active low.
#Bank = 15, Pin name = IO_L3P_T0_DQS_AD1P_15,				Sch name = CPU_RESET
set_property PACKAGE_PIN C12 [get_ports rstPBn]
set_property IOSTANDARD LVCMOS33 [get_ports rstPBn]

# Then one of the other 5 buttons, named as marked on the board. Signal is active high.
#Bank = CONFIG, Pin name = IO_L15N_T2_DQS_DOUT_CSO_B_14,	Sch name = BTNL
set_property PACKAGE_PIN T16 [get_ports btnL]
set_property IOSTANDARD LVCMOS33 [get_ports btnL]

#==================================================================================

# LEDs - these are 16 individual LEDs, just above the switches.
# Default signal names led[15] (on left), to led[0] (on right).
# logic 1 = ON, logic 0 = OFF.
# Only the three rightmost LEDs are uncommented here.

#Bank = 34, Pin name = IO_L24N_T3_34,						Sch name = LED0
set_property PACKAGE_PIN T8 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
#Bank = 34, Pin name = IO_L21N_T3_DQS_34,					Sch name = LED1
set_property PACKAGE_PIN V9 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
#Bank = 34, Pin name = IO_L24P_T3_34,						Sch name = LED2
set_property PACKAGE_PIN R8 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
##Bank = 34, Pin name = IO_L23N_T3_34,						Sch name = LED3
#set_property PACKAGE_PIN T6 [get_ports {led[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
##Bank = 34, Pin name = IO_L12P_T1_MRCC_34,					Sch name = LED4
#set_property PACKAGE_PIN T5 [get_ports {led[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
##Bank = 34, Pin name = IO_L12N_T1_MRCC_34,					Sch	name = LED5
#set_property PACKAGE_PIN T4 [get_ports {led[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
##Bank = 34, Pin name = IO_L22P_T3_34,						Sch name = LED6
#set_property PACKAGE_PIN U7 [get_ports {led[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
##Bank = 34, Pin name = IO_L22N_T3_34,						Sch name = LED7
#set_property PACKAGE_PIN U6 [get_ports {led[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
##Bank = 34, Pin name = IO_L10N_T1_34,						Sch name = LED8
#set_property PACKAGE_PIN V4 [get_ports {led[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]
##Bank = 34, Pin name = IO_L8N_T1_34,						Sch name = LED9
#set_property PACKAGE_PIN U3 [get_ports {led[9]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]
##Bank = 34, Pin name = IO_L7N_T1_34,						Sch name = LED10
#set_property PACKAGE_PIN V1 [get_ports {led[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
##Bank = 34, Pin name = IO_L17P_T2_34,						Sch name = LED11
#set_property PACKAGE_PIN R1 [get_ports {led[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
##Bank = 34, Pin name = IO_L13N_T2_MRCC_34,					Sch name = LED12
#set_property PACKAGE_PIN P5 [get_ports {led[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
##Bank = 34, Pin name = IO_L7P_T1_34,						Sch name = LED13
#set_property PACKAGE_PIN U1 [get_ports {led[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
##Bank = 34, Pin name = IO_L15N_T2_DQS_34,					Sch name = LED14
#set_property PACKAGE_PIN R2 [get_ports {led[14]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
##Bank = 34, Pin name = IO_L15P_T2_DQS_34,					Sch name = LED15
#set_property PACKAGE_PIN P2 [get_ports {led[15]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]

#==================================================================================

##Pmod Header JA, right side centre - for connecting external hardware
#Bank = 15, Pin name = IO_L1N_T0_AD0N_15,					Sch name = JA1
set_property PACKAGE_PIN B13 [get_ports {JA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[0]}]
#Bank = 15, Pin name = IO_L5N_T0_AD9N_15,					Sch name = JA2
set_property PACKAGE_PIN F14 [get_ports {JA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[1]}]
#Bank = 15, Pin name = IO_L16N_T2_A27_15,					Sch name = JA3
set_property PACKAGE_PIN D17 [get_ports {JA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[2]}]
#Bank = 15, Pin name = IO_L16P_T2_A28_15,					Sch name = JA4
set_property PACKAGE_PIN E17 [get_ports {JA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[3]}]
##Bank = 15, Pin name = IO_0_15,								Sch name = JA7
#set_property PACKAGE_PIN G13 [get_ports {JA[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[4]}]
##Bank = 15, Pin name = IO_L20N_T3_A19_15,					Sch name = JA8
#set_property PACKAGE_PIN C17 [get_ports {JA[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[5]}]
##Bank = 15, Pin name = IO_L21N_T3_A17_15,					Sch name = JA9
#set_property PACKAGE_PIN D18 [get_ports {JA[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[6]}]
##Bank = 15, Pin name = IO_L21P_T3_DQS_15,					Sch name = JA10
#set_property PACKAGE_PIN E18 [get_ports {JA[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {JA[7]}]
