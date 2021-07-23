SetActiveLib -work
comp -include "d:\calazans\orgcomp\cleopatra/src/control_unit.vhd" 
comp -include "$DSN\src\TestBench\control_TB.vhd" 
asim TESTBENCH_FOR_control 
wave 
wave -noreg reset
wave -noreg clock
wave -noreg hold
wave -noreg halt
wave -noreg ir
wave -noreg n
wave -noreg z
wave -noreg c
wave -noreg v
wave -noreg uins
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$DSN\src\TestBench\control_TB_tim_cfg.vhd" 
# asim TIMING_FOR_control 
