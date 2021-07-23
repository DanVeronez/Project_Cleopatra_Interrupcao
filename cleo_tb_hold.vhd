--------------------------------------------------------------------------
--------------------------------------------------------------------------
--  ARQUITETURA CLEOPATRA - Testbench para sinal Hold
--
--  Ney Calazans e Fernando Moraes
--
--  Inicio: 30/07/2004             Ultima modificação:  17/08/2004
--                                                                                                                                                 
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_unsigned.all; -- devido ao uso de conv_integer
use IEEE.Std_Logic_arith.all;    -- devido ao uso de conv_std_logic_vector
use STD.TEXTIO.all;
use work.cleo.all;

entity tb_hold is
end tb_hold;
        
architecture tb_hold of tb_hold is
        signal clock, reset, halt, hold, ce, rw, go: std_logic;
        signal address, data, datain, dataout : internal_bus;
        file INFILE : TEXT open READ_MODE is "testa.txt";
        signal memoria : ram; 
        signal ops, endereco : integer;
    
begin
   --
   -- inclui a Cleopatra no test_bench
   --
   cpu : entity work.cleopatra port map(reset=>reset, clock=>clock, 
           halt=>halt, hold=>hold, ce=>ce,rw=>rw, address=>address,
           datain=>datain, dataout=>dataout);
         
   -- gera o reset                  
   reset <= '1', '0' after 5ns;         
   -- gera o clock
   process
            begin
             clock <= '1', '0' after 10ns;
             wait for 20ns;
   end process;
   
   -- geração do sinal hold
   hold<='0', '1' after 42ns,  '0' after 122ns, 
              '1' after 462ns, '0' after 542ns,
              '1' after 725ns, '0' after 800ns,
			  '1' after 1505ns, '0' after 1565ns,
              '1' after 2013ns, '0' after 2132ns,
              '1' after 2967ns, '0' after 3205ns; 
   
   -- leitura da memória
   data         <= memoria(CONV_INTEGER(address)) 
           when ce='1' and rw='1' else (others=>'Z');
   -- converte barramento tristate para não-tristate na entrada da Cleópatra
   datain       <= data when ce='1' and rw='1' else (others=>'0');
   --
   -- Processo de controle de escrita na memória (síncrona) 
   --  Modificacao do dia 13/11/01 (Fernando Moraes) = ESCRITA NA RAM EM APENAS
   --  UM LUGAR. Se isto não for feito haverá valores indefinidos na simulação.
   --
   process(go, ce, rw, clock)
    begin
       if go'event and go='1' then
          if endereco>=0 and endereco <= 255 then
            memoria(endereco) <= conv_std_logic_vector(ops,8);
           end if;
       elsif clock'event and clock='0' and ce='1' and rw='0' then
                  if CONV_INTEGER(address)>=0 and CONV_INTEGER(address) <= 255 then
                    memoria(CONV_INTEGER(address)) <= dataout;
          end if;
       end if;
   end process;
   
   --
   -- Processo para realizar a carga na memoria quando acontece o reset
   --
   process
      variable IN_LINE : LINE;                  -- ponteiro para linha de caracteres
      variable linha : string(1 to 5);
      begin
       
       wait until reset = '1';

       while NOT( endfile(INFILE)) loop -- verificação de fim de arquivo
          readline(INFILE,IN_LINE);             -- lê uma linha de um arquivo
          read(IN_LINE, linha); 
           
          case linha(1) is  
           when '0' => endereco <= 0;
           when '1' => endereco <= 1;
           when '2' => endereco <= 2;
           when '3' => endereco <= 3;
           when '4' => endereco <= 4;
           when '5' => endereco <= 5;
           when '6' => endereco <= 6;
           when '7' => endereco <= 7;
           when '8' => endereco <= 8;
           when '9' => endereco <= 9;
           when 'A' => endereco <=10;
           when 'B' => endereco <=11;
           when 'C' => endereco <=12;
           when 'D' => endereco <=13;
           when 'E' => endereco <=14;
           when 'F' => endereco <=15;
           when others => null;
          end case;
     
          wait for 1 ps;
          
          case linha(2) is  
           when '0' => endereco <= endereco*16 + 0;
           when '1' => endereco <= endereco*16 + 1;
           when '2' => endereco <= endereco*16 + 2;
           when '3' => endereco <= endereco*16 + 3;
           when '4' => endereco <= endereco*16 + 4;
           when '5' => endereco <= endereco*16 + 5;
           when '6' => endereco <= endereco*16 + 6;
           when '7' => endereco <= endereco*16 + 7;
           when '8' => endereco <= endereco*16 + 8;
           when '9' => endereco <= endereco*16 + 9;
           when 'A' => endereco <= endereco*16 + 10;
           when 'B' => endereco <= endereco*16 + 11;
           when 'C' => endereco <= endereco*16 + 12;
           when 'D' => endereco <= endereco*16 + 13;
           when 'E' => endereco <= endereco*16 + 14;
           when 'F' => endereco <= endereco*16 + 15;
           when others => null;
          end case;
                    
          case linha(4) is  
           when '0' => ops <= 0;
           when '1' => ops <= 1;
           when '2' => ops <= 2;
           when '3' => ops <= 3;
           when '4' => ops <= 4;
           when '5' => ops <= 5;
           when '6' => ops <= 6;
           when '7' => ops <= 7;
           when '8' => ops <= 8;
           when '9' => ops <= 9;
           when 'A' => ops <=10;
           when 'B' => ops <=11;
           when 'C' => ops <=12;
           when 'D' => ops <=13;
           when 'E' => ops <=14;
           when 'F' => ops <=15;
           when others => null;
          end case;
     
          wait for 1ps;
          
          case linha(5) is  
           when '0' => ops <= ops*16 + 0;
           when '1' => ops <= ops*16 + 1;
           when '2' => ops <= ops*16 + 2;
           when '3' => ops <= ops*16 + 3;
           when '4' => ops <= ops*16 + 4;
           when '5' => ops <= ops*16 + 5;
           when '6' => ops <= ops*16 + 6;
           when '7' => ops <= ops*16 + 7;
           when '8' => ops <= ops*16 + 8;
           when '9' => ops <= ops*16 + 9;
           when 'A' => ops <= ops*16 + 10;
           when 'B' => ops <= ops*16 + 11;
           when 'C' => ops <= ops*16 + 12;
           when 'D' => ops <= ops*16 + 13;
           when 'E' => ops <= ops*16 + 14;
           when 'F' => ops <= ops*16 + 15;
           when others => null;
          end case;
          
          wait for 1ps;
          
          go <= '1';    -- este sinal de go habilita a escrita na memoria
          
          wait for 1 ps;
          
          go <= '0';    -- tira o go
          
         end loop;

   end process;
                                     
end tb_hold;
