---------------------------------------------------------------------------------------------------
--
-- Title       : Test Bench for alu
-- Design      : cleopatra
-- Author      : Fernando
-- Company     : PUCRS
--
---------------------------------------------------------------------------------------------------
--
-- File        : $DSN\src\TestBench\alu_TB.vhd
-- Generated   : 5/4/2005, 15:18
-- From        : $DSN\src\alu.vhd
-- By          : Active-HDL Built-in Test Bench Generator ver. 1.2s
--
---------------------------------------------------------------------------------------------------
--
-- Description : Automatically generated Test Bench for alu_tb
--
---------------------------------------------------------------------------------------------------

library ieee;
use work.cleo.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity alu_tb is
end alu_tb;

architecture TB_ARCHITECTURE of alu_tb is
	-- Component declaration of the tested unit
	component alu
	port(
		A_bus : in internal_bus;
		B_bus : in internal_bus;
		alu_op : in std_logic_vector(2 downto 0);
		C_Bus : out internal_bus;
		n_inst : out std_logic;
		z_inst : out std_logic;
		c_inst : out std_logic;
		v_inst : out std_logic );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal A_bus : internal_bus;
	signal B_bus : internal_bus;
	signal alu_op : std_logic_vector(2 downto 0):="000";
	-- Observed signals - signals mapped to the output ports of tested entity
	signal C_Bus : internal_bus;
	signal n_inst : std_logic;
	signal z_inst : std_logic;
	signal c_inst : std_logic;
	signal v_inst : std_logic;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : alu
		port map (
			A_bus => A_bus,
			B_bus => B_bus,
			alu_op => alu_op,
			C_Bus => C_Bus,
			n_inst => n_inst,
			z_inst => z_inst,
			c_inst => c_inst,
			v_inst => v_inst
		);

	process
	begin
		alu_op <= alu_op+1;
		wait for 10ns;
	end process;
	
	A_BUS <="00000001";
	B_BUS <="00000010";
	
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_alu of alu_tb is
	for TB_ARCHITECTURE
		for UUT : alu
			use entity work.alu(alu);
		end for;
	end for;
end TESTBENCH_FOR_alu;

