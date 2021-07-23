---------------------------------------------------------------------------------------------------
--
-- Title       : Test Bench for control
-- Design      : cleopatra
-- Author      : Fernando
-- Company     : PUCRS
--
---------------------------------------------------------------------------------------------------
--
-- File        : $DSN\src\TestBench\control_TB.vhd
-- Generated   : 12/4/2005, 11:20
-- From        : $DSN\src\control_unit.vhd
-- By          : Active-HDL Built-in Test Bench Generator ver. 1.2s
--
---------------------------------------------------------------------------------------------------
--
-- Description : Automatically generated Test Bench for control_tb
--
---------------------------------------------------------------------------------------------------

library ieee;
use work.cleo.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity control_tb is
end control_tb;

architecture TB_ARCHITECTURE of control_tb is
	-- Component declaration of the tested unit
	component control
	port(
		reset : in std_logic;
		clock : in std_logic;
		hold : in std_logic;
		halt : out std_logic;
		ir : in internal_bus;
		n : in std_logic;
		z : in std_logic;
		c : in std_logic;
		v : in std_logic;
		uins : out microinstrucao );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal reset : std_logic;
	signal clock : std_logic;
	signal hold : std_logic;
	signal ir : internal_bus;
	signal n : std_logic;
	signal z : std_logic;
	signal c : std_logic;
	signal v : std_logic;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal halt : std_logic;
	signal uins : microinstrucao;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : control
		port map (
			reset => reset,
			clock => clock,
			hold => hold,
			halt => halt,
			ir => ir,
			n => n,
			z => z,
			c => c,
			v => v,
			uins => uins
		);

reset <= '1', '0' after 5ns;

process	
begin
	clock <= '1', '0' after 10ns;
	wait for 20ns;
end process;	  

hold <= '0';

ir <= x"00", x"4C" after 80ns;
n <= '0';
z <= '0';
c <= '0';
v <= '0';

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_control of control_tb is
	for TB_ARCHITECTURE
		for UUT : control
			use entity work.control(control);
		end for;
	end for;
end TESTBENCH_FOR_control;

