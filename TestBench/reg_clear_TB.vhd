---------------------------------------------------------------------------------------------------
--
-- Title       : Test Bench for reg_clear
-- Design      : cleopatra
-- Author      : Fernando
-- Company     : PUCRS
--
---------------------------------------------------------------------------------------------------
--
-- File        : $DSN\src\TestBench\reg_clear_TB.vhd
-- Generated   : 5/4/2005, 15:37
-- From        : $DSN\src\reg.vhd
-- By          : Active-HDL Built-in Test Bench Generator ver. 1.2s
--
---------------------------------------------------------------------------------------------------
--
-- Description : Automatically generated Test Bench for reg_clear_tb
--
---------------------------------------------------------------------------------------------------

library ieee;
use work.cleo.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity reg_clear_tb is
end reg_clear_tb;

architecture TB_ARCHITECTURE of reg_clear_tb is
	-- Component declaration of the tested unit
	component reg_clear
	port(
		clock : in std_logic;
		reset : in std_logic;
		ce : in std_logic;
		D : in internal_bus;
		Q : out internal_bus );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clock : std_logic;
	signal reset : std_logic;
	signal ce : std_logic;
	signal D : internal_bus;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Q : internal_bus;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : reg_clear
		port map (
			clock => clock,
			reset => reset,
			ce => ce,
			D => D,
			Q => Q
		);

	reset <= '1', '0' after 5ns;
	process
	begin
		clock <= '0', '1' after 10ns;
		wait for 20ns;
	end process;
	
	D <= x"03", x"ff" after 35ns; 
	
	ce <= '0', '1' after 15ns, '0' after 35ns;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_reg_clear of reg_clear_tb is
	for TB_ARCHITECTURE
		for UUT : reg_clear
			use entity work.reg_clear(reg_clear);
		end for;
	end for;
end TESTBENCH_FOR_reg_clear;

