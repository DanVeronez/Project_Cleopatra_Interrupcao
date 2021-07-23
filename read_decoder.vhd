-------------------------------------------------------------------------
-- Decodificador de Leitura
-- Este bloco combinacional gera sinais de habilitação de dispositivos
-- tristate interpostos entre os registradores e barramentos.
-------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.cleo.all;

entity read_decoder is
    port(read_reg:in std_logic_vector(2 downto 0);
	r_mdr, r_ir, r_pc, r_ac, r_rs: out std_logic);
end read_decoder;

architecture read_decoder of read_decoder is
begin
    ---
    --- Códigos de leitura nos registradores (codificação de leitura):
    --- 1 MDR, 2 IR, 3 PC, 4 AC, 5 RS, 6 MDR/AC, 7 MDR/PC
    ---
    r_mdr <= '1' when read_reg="001" or read_reg="110" or read_reg="111" else '0';
    r_ir  <= '1' when read_reg="010"                                		else '0'; 
    r_pc  <= '1' when read_reg="011" or read_reg="111"                 	else '0';
    r_ac  <= '1' when read_reg="100" or read_reg="110"                 	else '0';  
    r_rs  <= '1' when read_reg="101"                                 	else '0';
end read_decoder;																	 
