-------------------------------------------------------------------------
-- Biestáveis de estado
-- Este registrador de estado armazena quatro bits referentes aos 4
-- valores instantâneos dos qualificadores de estado
-- (n_inst, z_inst, c_inst, v_inst) quando os sinais de controle 
-- (lnz e lcv) indicam que isto deva ocorrer, na borda correta do sinal de
-- relógio (clock). O sinal reset inicializa todos os qualificadores com 0.
--
-- 17/08/2004 - por questões de coerência com o funcionamento dos
-- 	registradores, sinal de hold acrescentado na interface deste módulo
--	(Calazans)
-------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.cleo.all;

entity status_flags is
    port(clock, reset, hold, 
	n_inst, z_inst, c_inst, v_inst, lnz, lcv :in std_logic;
	n, z, c, v: out std_logic);
end status_flags;

architecture status_flags of status_flags is
begin
    process(clock,reset)
    begin
        if (reset='1') then
          n <= '0';
          z <= '0';
          c <= '0';    
          v <= '0';    
        elsif clock'event and clock='0' then
          if (lcv='1' and hold='0') then
					c <= c_inst;
					v <= v_inst;
          end if;
          if (lnz='1' and hold='0') then
			 		n <= n_inst;
					z <= z_inst;
          end if;
        end if;
    end process;		   
end status_flags;
