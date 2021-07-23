-------------------------------------------------------------------------
-- Registrador Set-Reset de 1 BIT
-------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.cleo.all;

entity reg_SR is
    port(clock, reset, set:in std_logic; 
	     Q:out std_logic );
end reg_SR;

architecture reg_SR of reg_SR is
begin
  process (clock, reset, set)
    begin
    if reset='1' then
         Q <= '0';
    elsif (clock'event and clock='0')then
        if set='1' then  Q <= '1';  end if;
    end if;
  end process;
end reg_SR;

