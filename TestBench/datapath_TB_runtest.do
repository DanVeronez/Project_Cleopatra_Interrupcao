SetActiveLib -work
comp -include "D:\calazans\orgcomp\cleopatra/src/datapath.vhd" 
comp -include "$DSN\src\TestBench\datapath_TB.vhd" 
asim TESTBENCH_FOR_datapath 
wave 
wave -noreg clock
wave -noreg reset
wave -noreg hold
wave -noreg address
wave -noreg ir
wave -noreg datain
wave -noreg dataout
wave -noreg uins
wave -noreg n
wave -noreg z
wave -noreg c
wave -noreg v
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$DSN\src\TestBench\datapath_TB_tim_cfg.vhd" 
# asim TIMING_FOR_datapath 
