## Generated SDC file "AVC1READER.sdc"

## Copyright (C) 2019  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 19.1.0 Build 670 09/22/2019 SJ Standard Edition"

## DATE    "Thu May 27 16:19:35 2021"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {I_CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {I_CLOCK_50}]
create_clock -name {userctrl:userctrl|R_RESET} -period 100000.000 -waveform { 50000.000 100000.000 } [get_keepers {userctrl:userctrl|R_RESET}]
create_clock -name {R_ST_FS.USER_WAIT_START} -period 1000000.000 -waveform { 500000.000 1000000.000 } [get_nets {R_ST_FS.USER_WAIT_START}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {USER_CLK} -source [get_ports {I_CLOCK_50}] -multiply_by 1 -divide_by 5000 -master_clock {I_CLOCK_50} [get_nets {avcpll|altpll_component|auto_generated|wire_pll1_clk[2]}] 
create_generated_clock -name {SDCLK} -source [get_ports {I_CLOCK_50}] -multiply_by 2 -divide_by 5 -master_clock {I_CLOCK_50} [get_pins { avcpll|altpll_component|auto_generated|pll1|clk[0] }] 
create_generated_clock -name {SDRAMCLK} -source [get_ports {I_CLOCK_50}] -multiply_by 8 -divide_by 5 -master_clock {I_CLOCK_50} [get_pins { avcpll|altpll_component|auto_generated|pll1|clk[1] }] 
create_generated_clock -name {DQFIFOCLK} -source [get_ports {I_CLOCK_50}] -multiply_by 16 -divide_by 5 -master_clock {I_CLOCK_50} [get_pins { avcpll|altpll_component|auto_generated|pll1|clk[3] }] 

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {SDRAMCLK}] -rise_to [get_clocks {SDRAMCLK}]  1.000  
set_clock_uncertainty -rise_from [get_clocks {SDRAMCLK}] -fall_to [get_clocks {SDRAMCLK}]  1.000  
set_clock_uncertainty -rise_from [get_clocks {SDRAMCLK}] -rise_to [get_clocks {SDCLK}]  2.000  
set_clock_uncertainty -rise_from [get_clocks {SDRAMCLK}] -fall_to [get_clocks {SDCLK}]  2.000  
set_clock_uncertainty -fall_from [get_clocks {SDRAMCLK}] -rise_to [get_clocks {SDRAMCLK}]  1.000  
set_clock_uncertainty -fall_from [get_clocks {SDRAMCLK}] -fall_to [get_clocks {SDRAMCLK}]  1.000  
set_clock_uncertainty -fall_from [get_clocks {SDRAMCLK}] -rise_to [get_clocks {SDCLK}]  2.000  
set_clock_uncertainty -fall_from [get_clocks {SDRAMCLK}] -fall_to [get_clocks {SDCLK}]  2.000  
set_clock_uncertainty -rise_from [get_clocks {SDCLK}] -rise_to [get_clocks {SDRAMCLK}]  2.000  
set_clock_uncertainty -rise_from [get_clocks {SDCLK}] -fall_to [get_clocks {SDRAMCLK}]  2.000  
set_clock_uncertainty -rise_from [get_clocks {SDCLK}] -rise_to [get_clocks {SDCLK}]  4.000  
set_clock_uncertainty -rise_from [get_clocks {SDCLK}] -fall_to [get_clocks {SDCLK}]  4.000  
set_clock_uncertainty -fall_from [get_clocks {SDCLK}] -rise_to [get_clocks {SDRAMCLK}]  2.000  
set_clock_uncertainty -fall_from [get_clocks {SDCLK}] -fall_to [get_clocks {SDRAMCLK}]  2.000  
set_clock_uncertainty -fall_from [get_clocks {SDCLK}] -rise_to [get_clocks {SDCLK}]  4.000  
set_clock_uncertainty -fall_from [get_clocks {SDCLK}] -fall_to [get_clocks {SDCLK}]  4.000  
set_clock_uncertainty -rise_from [get_clocks {USER_CLK}] -rise_to [get_clocks {USER_CLK}]  10000.000  
set_clock_uncertainty -rise_from [get_clocks {USER_CLK}] -fall_to [get_clocks {USER_CLK}]  10000.000  
set_clock_uncertainty -fall_from [get_clocks {USER_CLK}] -rise_to [get_clocks {USER_CLK}]  10000.000  
set_clock_uncertainty -fall_from [get_clocks {USER_CLK}] -fall_to [get_clocks {USER_CLK}]  10000.000  
set_clock_uncertainty -rise_from [get_clocks {R_ST_FS.USER_WAIT_START}] -rise_to [get_clocks {R_ST_FS.USER_WAIT_START}]  10000.000  
set_clock_uncertainty -rise_from [get_clocks {R_ST_FS.USER_WAIT_START}] -fall_to [get_clocks {R_ST_FS.USER_WAIT_START}]  10000.000  
set_clock_uncertainty -fall_from [get_clocks {R_ST_FS.USER_WAIT_START}] -rise_to [get_clocks {R_ST_FS.USER_WAIT_START}]  10000.000  
set_clock_uncertainty -fall_from [get_clocks {R_ST_FS.USER_WAIT_START}] -fall_to [get_clocks {R_ST_FS.USER_WAIT_START}]  10000.000  
set_clock_uncertainty -rise_from [get_clocks {userctrl:userctrl|R_RESET}] -rise_to [get_clocks {userctrl:userctrl|R_RESET}]  10000.000  
set_clock_uncertainty -rise_from [get_clocks {userctrl:userctrl|R_RESET}] -fall_to [get_clocks {userctrl:userctrl|R_RESET}]  10000.000  
set_clock_uncertainty -fall_from [get_clocks {userctrl:userctrl|R_RESET}] -rise_to [get_clocks {userctrl:userctrl|R_RESET}]  10000.000  
set_clock_uncertainty -fall_from [get_clocks {userctrl:userctrl|R_RESET}] -fall_to [get_clocks {userctrl:userctrl|R_RESET}]  10000.000  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[0]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[1]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[2]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[3]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[4]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[5]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[6]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[7]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[8]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[9]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[10]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[11]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[12]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[13]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[14]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[15]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[16]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[17]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[18]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[19]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[20]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[21]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[22]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[23]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[24]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[25]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[26]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[27]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[28]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[29]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[30]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[31]}]
set_input_delay -add_delay  -clock [get_clocks {I_CLOCK_50}]  0.000 [get_ports {I_CLOCK_50}]
set_input_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {I_READ}]
set_input_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {I_RESET}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_CMD}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_DAT[0]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_DAT[1]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_DAT[2]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_DAT[3]}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {SDCLK}]  0.000 [get_ports {_I_SD_WP}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[0]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[1]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[2]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[3]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[4]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[5]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[6]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[7]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[8]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[9]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[10]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[11]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[12]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[13]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[14]}]
set_input_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL[15]}]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[0]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[1]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[2]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[3]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[4]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[5]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[6]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[7]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[8]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[9]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[10]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[11]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[12]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[13]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[14]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[15]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[16]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[17]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[18]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[19]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[20]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[21]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[22]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[23]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[24]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[25]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[26]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[27]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[28]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[29]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[30]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {DQ[31]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[0]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[1]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[2]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[3]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[4]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[5]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[6]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[7]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[8]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[9]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[10]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[11]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_A[12]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_BA[0]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_BA[1]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_CKE}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_DQM[0]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_DQM[1]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_DQM[2]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_DQM[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX0[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX0[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX0[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX0[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX0[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX0[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX0[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX1[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX1[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX1[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX1[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX1[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX1[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX1[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX2[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX2[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX2[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX2[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX2[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX2[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX2[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX3[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX3[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX3[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX3[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX3[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX3[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX3[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX4[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX4[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX4[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX4[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX4[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX4[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX4[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX5[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX5[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX5[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX5[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX5[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX5[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX5[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX6[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX6[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX6[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX6[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX6[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX6[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX6[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX7[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX7[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX7[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX7[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX7[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX7[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_HEX7[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_BLON}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_DATA[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_DATA[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_DATA[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_DATA[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_DATA[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_DATA[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_DATA[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_DATA[7]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_EN}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_ON}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_RS}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LCD_RW}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_LEDONE}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {O_SDR_CLK}]
set_output_delay -add_delay  -clock [get_clocks {SDCLK}]  0.000 [get_ports {O_SD_CLK}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDG[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDG[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDG[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDG[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDG[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDG[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDG[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDG[7]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[0]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[1]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[2]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[3]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[4]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[5]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[6]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[7]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[8]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[9]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[10]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[11]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[12]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[13]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[14]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[15]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[16]}]
set_output_delay -add_delay  -clock [get_clocks {USER_CLK}]  0.000 [get_ports {O_TESTLEDR[17]}]
set_output_delay -add_delay  -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_CMD}]
set_output_delay -add_delay  -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_DAT[0]}]
set_output_delay -add_delay  -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_DAT[1]}]
set_output_delay -add_delay  -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_DAT[2]}]
set_output_delay -add_delay  -clock [get_clocks {SDCLK}]  0.000 [get_ports {SD_DAT[3]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[0]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[1]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[2]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[3]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[4]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[5]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[6]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[7]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[8]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[9]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[10]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[11]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[12]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[13]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[14]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {SGNL[15]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[0]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[1]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[2]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[3]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[4]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[5]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[6]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[7]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[8]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[9]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[10]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[11]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[12]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[13]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[14]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  3.000 [get_ports {SGNL_OUT[15]}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {_O_CAS}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {_O_CS}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {_O_RAS}]
set_output_delay -add_delay  -clock [get_clocks {SDRAMCLK}]  0.000 [get_ports {_O_WE}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path  -from  [get_clocks {userctrl:userctrl|R_RESET}]  -to  [get_clocks {SDRAMCLK}]
set_false_path  -from  [get_clocks {R_ST_FS.USER_WAIT_START}]  -to  [get_clocks {SDRAMCLK}]
set_false_path  -from  [get_clocks {R_ST_FS.USER_WAIT_START}]  -to  [get_clocks {SDCLK}]
set_false_path  -from  [get_clocks {userctrl:userctrl|R_RESET}]  -to  [get_clocks {SDCLK}]
set_false_path  -from  [get_clocks {USER_CLK}]  -to  [get_clocks {SDCLK}]
set_false_path  -from  [get_clocks {USER_CLK}]  -to  [get_clocks {SDRAMCLK}]
set_false_path  -from  [get_clocks {DQFIFOCLK}]  -to  [get_clocks {SDRAMCLK}]
set_false_path  -from  [get_clocks {userctrl:userctrl|R_RESET}]  -to  [get_clocks {DQFIFOCLK}]
set_false_path  -from  [get_clocks {SDRAMCLK}]  -to  [get_clocks {R_ST_FS.USER_WAIT_START}]
set_false_path  -from  [get_clocks {SDRAMCLK}]  -to  [get_clocks {USER_CLK}]
set_false_path  -from  [get_clocks {SDRAMCLK}]  -to  [get_clocks {userctrl:userctrl|R_RESET}]
set_false_path  -from  [get_clocks {SDCLK}]  -to  [get_clocks {R_ST_FS.USER_WAIT_START}]
set_false_path  -from  [get_clocks {SDCLK}]  -to  [get_clocks {USER_CLK}]
set_false_path  -from  [get_clocks {SDCLK}]  -to  [get_clocks {userctrl:userctrl|R_RESET}]
set_false_path  -from  [get_clocks {USER_CLK}]  -to  [get_clocks {userctrl:userctrl|R_RESET}]
set_false_path  -from  [get_clocks {userctrl:userctrl|R_RESET}]  -to  [get_clocks {USER_CLK}]
set_false_path  -from  [get_clocks {R_ST_FS.USER_WAIT_START}]  -to  [get_clocks {USER_CLK}]
set_false_path -from [get_pins {avcpll|altpll_component|auto_generated|pll1|clk[1]}] -to [get_keepers {O_SDR_CLK}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|delayed_wrptr_g[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|delayed_wrptr_g[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|delayed_wrptr_g[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_g[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|altsyncram_2l31:fifo_ram|ram_block*}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_g[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|altsyncram_2l31:fifo_ram|ram_block*}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_g[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|altsyncram_2l31:fifo_ram|ram_block*}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_b[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|altsyncram_2l31:fifo_ram|ram_block*}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_b[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|altsyncram_2l31:fifo_ram|ram_block*}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_b[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|altsyncram_2l31:fifo_ram|ram_block*}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|altsyncram_2l31:fifo_ram|ram_block*}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|altsyncram_2l31:fifo_ram|ram_block*}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|altsyncram_2l31:fifo_ram|ram_block*}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_g[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|wrptr_g[*]}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|a_graycounter_5lc:wrptr_g1p|sub_parity8a[*]}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|a_graycounter_5lc:wrptr_g1p|parity7}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_g[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|a_graycounter_5lc:wrptr_g1p|counter6a0}]
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}] -to [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|wrptr_g[*]}]
set_false_path -from [get_registers {R_ST_FS.AVC_SEND_VECTOR}] 
set_false_path -from [get_registers {userctrl:userctrl|R_READ[0]}] 
set_false_path -from [get_registers {userctrl:userctrl|R_READ[1]}] 
set_false_path -from [get_registers {avcparser:avcparser|R_PARSEDONE}] 
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_g[*]}] 
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_b[*]}] 
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_g[*]}] 
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_b[*]}] 
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_g[*]}] 
set_false_path -from [get_registers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdptr_b[*]}] 
set_false_path -from [get_keepers {sdramrx:sdramrx|R_PARDOUT0[*]}] -to [get_keepers {SGNL[*]}]
set_false_path -from [get_keepers {sdramrx:sdramrx|R_PARDOUT1[*]}] -to [get_keepers {SGNL[*]}]
set_false_path -from [get_keepers {sdramrx:sdramrx|R_DATAIN[*]}] -to [get_keepers {SGNL_OUT[*]}]
set_false_path -from [get_keepers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|delayed_wrptr_g[*]}] -to [get_keepers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdemp_eq_comp_msb_aeb}]
set_false_path -from [get_keepers {avcparser:avcparser|paralsfifo:hlvecbufs|dcfifo:dcfifo_component|dcfifo_u1q1:auto_generated|rdptr_g[*]}] -to [get_keepers {avcparser:avcparser|paralsfifo:hlvecbufs|dcfifo:dcfifo_component|dcfifo_u1q1:auto_generated|wrfull_eq_comp_lsb_mux_reg}]
set_false_path -from [get_keepers {avcparser:avcparser|paralsfifo:errvec|dcfifo:dcfifo_component|dcfifo_u1q1:auto_generated|delayed_wrptr_g[*]}] -to [get_keepers {avcparser:avcparser|paralsfifo:errvec|dcfifo:dcfifo_component|dcfifo_u1q1:auto_generated|rdemp_eq_comp_msb_aeb}]
set_false_path -from [get_keepers {avcparser:avcparser|paralsfifo:hlvecbufs|dcfifo:dcfifo_component|dcfifo_u1q1:auto_generated|rdptr_g[*]}] -to [get_keepers {avcparser:avcparser|paralsfifo:hlvecbufs|dcfifo:dcfifo_component|dcfifo_u1q1:auto_generated|wrfull_eq_comp_msb_mux_reg}]
set_false_path -from [get_keepers {avcparser:avcparser|paralsfifo:errvec|dcfifo:dcfifo_component|dcfifo_u1q1:auto_generated|delayed_wrptr_g[*]}] -to [get_keepers {avcparser:avcparser|paralsfifo:errvec|dcfifo:dcfifo_component|dcfifo_u1q1:auto_generated|rdemp_eq_comp_lsb_aeb}]
set_false_path -from [get_keepers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|delayed_wrptr_g[*]}] -to [get_keepers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdemp_eq_comp_lsb_aeb}]
set_false_path -from [get_keepers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|delayed_wrptr_g[*]}] -to [get_keepers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdemp_eq_comp_msb_aeb}]
set_false_path -from [get_keepers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|delayed_wrptr_g[*]}] -to [get_keepers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|rdemp_eq_comp_lsb_aeb}]
set_false_path -from [get_keepers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}] 
set_false_path -from [get_keepers {avcparser:avcparser|parserfifo:errwsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}] 
set_false_path -from [get_keepers {avcparser:avcparser|parserfifo:errtsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe1|dffe2a[*]}] 
set_false_path -from [get_keepers {avcparser:avcparser|paralsfifo:errvec|dcfifo:dcfifo_component|dcfifo_u1q1:auto_generated|rdptr_g[*]}] 
set_false_path -from [get_keepers {avcparser:avcparser|parserfifo:errgsgnl|dcfifo_mixed_widths:dcfifo_mixed_widths_component|dcfifo_n9l1:auto_generated|alt_synch_pipe_2e8:rs_dgwp|dffpipe_se9:dffpipe10|dffe11a[*]}]

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

