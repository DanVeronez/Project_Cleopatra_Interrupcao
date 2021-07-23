-------------------------------------------------------------------------
-- Registrador Básico
-- Com reset assíncrono e habilitação de escrita
-------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.cleo.all;

entity reg_clear is
    port(clock, reset, ce:in std_logic; 
	D:in internal_bus; Q:out internal_bus );
end reg_clear;

architecture reg_clear of reg_clear is
begin
  process (clock, reset)
    begin
    if reset='1' then
         Q <= (others=>'0');
    elsif (clock'event and clock='0')then
        if ce='1' then  Q <= D;  end if;
    end if;
  end process;
end reg_clear;

