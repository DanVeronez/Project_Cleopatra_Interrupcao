---------------------------------------------------------------------------------------------------
--
-- Title       : Test Bench for datapath
-- Design      : cleopatra
-- Author      : Fernando
-- Company     : PUCRS
--
---------------------------------------------------------------------------------------------------
--
-- File        : $DSN\src\TestBench\datapath_TB.vhd
-- Generated   : 7/4/2005, 14:57
-- From        : $DSN\src\datapath.vhd
-- By          : Active-HDL Built-in Test Bench Generator ver. 1.2s
--
---------------------------------------------------------------------------------------------------
--
-- Description : Automatically generated Test Bench for datapath_tb
--
---------------------------------------------------------------------------------------------------

library ieee;
use work.cleo.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity datapath_tb is
end datapath_tb;

architecture TB_ARCHITECTURE of datapath_tb is
	-- Component declaration of the tested unit
	component datapath
	port(
		clock : in std_logic;
		reset : in std_logic;
		hold : in std_logic;
		address : out internal_bus;
		ir : out internal_bus;
		datain : in internal_bus;
		dataout : out internal_bus;
		uins : in microinstrucao;
		n : out std_logic;
		z : out std_logic;
		c : out std_logic;
		v : out std_logic );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clock : std_logic;
	signal reset : std_logic;
	signal hold : std_logic;
	signal datain : internal_bus;
	signal uins : microinstrucao;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal address : internal_bus;
	signal ir : internal_bus;
	signal dataout : internal_bus;
	signal n : std_logic;
	signal z : std_logic;
	signal c : std_logic;
	signal v : std_logic;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : datapath
		port map (
			clock => clock,
			reset => reset,
			hold => hold,
			address => address,
			ir => ir,
			datain => datain,
			dataout => dataout,
			uins => uins,
			n => n,
			z => z,
			c => c,
			v => v
		);

reset <= '1', '0' after 5ns;

process	
begin
	clock <= '1', '0' after 10ns;
	wait for 20ns;
end process;	  

hold <= '0';

uins <= 
("111", "000", "011", '0', '0', '0', '0'), 
("001", "110", "011", '0', '0', '1', '1') after 20ns, 
("100", "010", "001", '0', '0', '0', '0') after 40ns, 
("111", "000", "011", '0', '0', '0', '0') after 60ns, 
("001", "110", "011", '0', '0', '1', '1') after 80ns, 
("100", "100", "001", '1', '0', '0', '0') after 100ns; 

datain <= x"00", x"40" after 20ns, x"33" after 80ns;
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_datapath of datapath_tb is
	for TB_ARCHITECTURE
		for UUT : datapath
			use entity work.datapath(datapath);
		end for;
	end for;
end TESTBENCH_FOR_datapath;

