-------------------------------------------------------------------------
-- Unidade lógico-aritmética (ALU)
-- A ALU possui duas entradas de dados (A_bus e B_bus) e 
-- uma saida de dados (C_bus), um sinal de controle de operação a executar
-- (alu_op) e quatro saídas com valores instantâneos computados para os
-- 4 qualificadores de estado (n_inst, z_inst, c_inst, v_inst).
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.cleo.all;

entity alu is
    port(A_bus, B_bus:in internal_bus; alu_op: in std_logic_vector(2 downto 0);
	C_Bus:out internal_bus; n_inst, z_inst, c_inst, v_inst: out std_logic);
end alu;

architecture alu of alu is
-- barramentos internos possuem um bit a mais para permitir cálculo dos flags
-- de vai-um e transbordo
signal A_bus_int, B_bus_int, C_bus_int : std_logic_vector(bus_size downto 0);

begin
	A_bus_int <= '0' & A_bus; -- zera-se o bit mais significativo dos
	B_bus_int <= '0' & B_bus; -- barramentos internos de entrada
	C_bus <= C_bus_int (bus_size-1 downto 0); -- toma n-1 bits menos significativos

	process(alu_op, A_bus_int, B_bus_int)
     begin
       case alu_op is
        when "000" => C_bus_int <= A_bus_int + B_bus_int; -- soma
        when "001" => C_bus_int <= A_bus_int + "000000001"; -- incremento
        when "010" => C_bus_int <= not A_bus_int; -- not
        when "100" => C_bus_int <= B_bus_int;	   -- passa B
        when "101" => C_bus_int <= A_bus_int or B_bus_int;	-- ou lógico
        when "110" => C_bus_int <= A_bus_int and B_bus_int;	-- e lógico
        when "111" => C_bus_int <= A_bus_int;	   -- passa A
        when others => C_bus_int <= A_bus_int;	   -- faz passa A;
       end case;
     end process;					  
	-- o bit menos significativo-1 é o valor instantâneo do qualificador n
    n_inst <= C_bus_int (bus_size-1);
	-- o qualificador z em 1 indica que o resultado da operação é o valor 0
    z_inst <= '1' 
      when (C_bus_int(bus_size-1 downto 0) = "00000000") 
      else '0';
	-- o bit menos significativo é o valor instantâneo do qualificador c
	c_inst <= C_bus_int (bus_size);
	-- o qualificador v vai para 1 se os operandos têm sinais iguais 
	-- e se este sinal é diferente do sinal do resultado
	v_inst <= '1' when (A_bus_int(bus_size-1)=B_bus_int(bus_size-1) and 
			A_bus_int(bus_size-1)/=C_bus_int(bus_size-1)) else '0';
    
end alu;