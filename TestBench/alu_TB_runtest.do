SetActiveLib -work
comp -include "D:\calazans\orgcomp\cleopatra/src/alu.vhd" 
comp -include "$DSN\src\TestBench\alu_TB.vhd" 
asim TESTBENCH_FOR_alu 
wave 
wave -noreg A_bus
wave -noreg B_bus
wave -noreg alu_op
wave -noreg C_Bus
wave -noreg n_inst
wave -noreg z_inst
wave -noreg c_inst
wave -noreg v_inst
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$DSN\src\TestBench\alu_TB_tim_cfg.vhd" 
# asim TIMING_FOR_alu 
