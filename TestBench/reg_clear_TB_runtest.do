SetActiveLib -work
comp -include "D:\calazans\orgcomp\cleopatra/src/reg.vhd" 
comp -include "$DSN\src\TestBench\reg_clear_TB.vhd" 
asim TESTBENCH_FOR_reg_clear 
wave 
wave -noreg clock
wave -noreg reset
wave -noreg ce
wave -noreg D
wave -noreg Q
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$DSN\src\TestBench\reg_clear_TB_tim_cfg.vhd" 
# asim TIMING_FOR_reg_clear 
