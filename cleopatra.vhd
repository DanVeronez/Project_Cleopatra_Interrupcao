--------------------------------------------------------------------------
-------------------------------------------------------------------------
--  CONSTRUÇÃO DA ARQUITETURA CLEÓPATRA COMPLETA
--
--  Fernando Moraes
--  Ney Calazans
--  Guilherme Guindani
--
--  Início: 11/maio/1998             Ultima modificação:  03/Março/2019
--
--  03/03/2019 - Incluído o mecanismo de interrupção básico.
--  17/08/2004 - sincronização do sinal externo hold na subida do sinal
--		externo de relógio e geração da versão 3.0 de distribuição da
--  	arquitetura (Calazans)
--  02/08/2004 - mudança da Unidade de Controle para máquina de estados
--		(Calazans)
--  30/07/2004 - revisão para separar barramento bidirecional de dados
--		em dois barramentos unidirecionais e acrescentar um sinal de
--		hold na interface externa do processador. Estas são as primeiras
-- 		alterações visando a prototipação em hardware. (Calazans)
--  28/07/2004 - revisão para modularizar implementação - (Calazans)
--  06/06/2003 - revisão do código - (Calazans/Moraes)
--  04/08/2002 - inserção do flag de overflow e decorrências - (Calazans)
--  15/10/2001 - simplificação da Unidade de Controle e correção dos
--		jumps indiretos - (Moraes)
--
--  CPU: união do bloco de dados com o bloco de controle
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.cleo.all;

entity cleopatra is
	port(clock, reset, hold, irq, set, ce_reg	: in std_logic;
		 halt, iack								: out std_logic;
         ce, rw, Q								: out std_logic; 
         address								: out internal_bus;
         datain, D	 							: in internal_bus;
		 dataout, Q_reg							: out internal_bus
		); 

end cleopatra;
    
architecture cleopatra of cleopatra is
   signal uins : microinstrucao; 
   signal n,z,c,v : std_logic;
   signal ir : internal_bus;
   SIGNAL hold_int : std_logic; -- hold interno
   signal dataout_int: internal_bus;
   signal datain_int, datain_mux, mux1: internal_bus;
   signal address_int: internal_bus;
   signal port1_int, iack_int: std_logic;
   signal trap: std_logic;
   signal port2_int: std_logic; 
begin
   ce <= uins.ce;
   rw <= uins.rw;
   dataout <=dataout_int;
   address <= address_int;
   
   datain_mux <= datain_int when (address_int = x"FF" and uins.ce = '1' and uins.rw = '1') else datain;
   mux1 <= '1' when (address_int = x"FF" and uins.ce = '1' and uins.rw = '0') else '0';
   port1_int <= iack_int or reset;
   port2_int <= irq or trap; 
   
   -- processo para registrar, e assim sincronizar, o sinal externo hold
   -- na borda de subida do relógio
   process (clock, reset)
   begin
	   if reset='1' then
		   hold_int <='0';   
	   elsif clock'event and clock='1' then
		   hold_int <= hold;
	   end if;
   end process;
	   
   DP: entity work.datapath port map (clock=>clock, reset=>reset,
	   hold=>hold_int, address=>address_int, datain=>datain_mux, dataout=>dataout_int,
	   ir=>ir, uins=>uins, n=>n, z=>z, c=>c, v=>v);  
                           
   CU: entity work.control port map (clock=>clock, reset=>reset,
	   hold=>hold_int, halt=>halt, ir=>ir, uins=>uins,
	   n=>n, z=>z, c=>c, v=>v, irq=>port2_int, iack=>iack_int);
	   
   IRQ_REG: entity work.reg_clear port map (clock=>clock, reset=>reset,
	   ce_reg=>mux1,D=>dataout_int,Q=>datain_int);
	   
   REG_SR: entity work.reg_SR port map (clock=>clock, 
   reset=>port1_int, set=>mux1, Q_reg=>trap);   
   
end cleopatra;
