--------------------------------------------------------------------------
-------------------------------------------------------------------------
--  CONSTRU��O DA ARQUITETURA CLE�PATRA COMPLETA
--
--  Fernando Moraes
--  Ney Calazans
--  Guilherme Guindani
--
--  In�cio: 11/maio/1998             Ultima modifica��o:  03/Mar�o/2019
--
--  03/03/2019 - Inclu�do o mecanismo de interrup��o b�sico.
--  17/08/2004 - sincroniza��o do sinal externo hold na subida do sinal
--		externo de rel�gio e gera��o da vers�o 3.0 de distribui��o da
--  	arquitetura (Calazans)
--  02/08/2004 - mudan�a da Unidade de Controle para m�quina de estados
--		(Calazans)
--  30/07/2004 - revis�o para separar barramento bidirecional de dados
--		em dois barramentos unidirecionais e acrescentar um sinal de
--		hold na interface externa do processador. Estas s�o as primeiras
-- 		altera��es visando a prototipa��o em hardware. (Calazans)
--  28/07/2004 - revis�o para modularizar implementa��o - (Calazans)
--  06/06/2003 - revis�o do c�digo - (Calazans/Moraes)
--  04/08/2002 - inser��o do flag de overflow e decorr�ncias - (Calazans)
--  15/10/2001 - simplifica��o da Unidade de Controle e corre��o dos
--		jumps indiretos - (Moraes)
--
--  CPU: uni�o do bloco de dados com o bloco de controle
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
   -- na borda de subida do rel�gio
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
