--------------------------------------------------------------------------
-- Bloco de Controle do Processador Cleópatra (8 bits)
-- Solução hardwired, via máquina de estados 
--
--  03/03/2019 - Inclusão de:
--					-> Dois estados SINT1 e SINT2 para tratamento de IRQ;
--                  -> Mudança na máquina de estados para testar o sinal
--                     de IRQ em todos os demais estados;
--  19/08/2004 - troca de nome de alguns estados, coerência de língua (Calazans)
--  15/08/2004 - inserção do sinal hold e codificação estendida
--		para instruções not/sta (Moraes)
--  14/08/2004 - máquina de estados simplificada (15 estados) (Moraes)
--  1/08/2004 - revisão para síntese em hardware. trocar processo único
--  com muitos waits por estrutura de FSM convencional. (Calazans)
--------------------------------------------------------------------------
library IEEE; 
use IEEE.Std_Logic_1164.all;
use work.cleo.all;

entity control is
    port( reset, clock, hold, irq 	: in std_logic;
          halt, iack				: out std_logic;
          ir 						: in internal_bus;
          n, z, c, v				: in std_logic;
          uins 						: out microinstrucao
        ); 
end control;

architecture control of control is 

   type CleoStates_type is (
       SIDLE,                             -- estado dummy, apenas para garantir que borda de subida seguinte
                                          -- à desativação do reset é o que faz o processamento começar.
       FETCH0, FETCH1, FETCH2,            -- estados onde se faz busca de instrução
	   
	   SINT1, SINT2,					  -- estados para o tratamento de interrupção em HW
       
       Sop1a, Sop1b,                      --  busca do primeiro operando das demais instruções
       
       Sop2a, Sop2b, Sop3a, Sop3b, Salu,  -- estados para execução das instruções lógicas aritméticas 
          
       OP2jp1, OP2jp2, Sjump,            -- estados para execução dos saltos
       
       Sjsr
   );
   
   -- CODIFICAÇÃO DAS INSTRUCOES
   constant NOT1  : std_logic_vector(3 downto 0) :=  x"0";     -- duas codificações possíveis para o NOT
   constant NOT2  : std_logic_vector(3 downto 0) :=  x"1";   
   constant STA1  : std_logic_vector(3 downto 0) :=  x"2";     -- duas codificações possíveis para o STA
   constant STA2  : std_logic_vector(3 downto 0) :=  x"3";  
   constant LDA   : std_logic_vector(3 downto 0) :=  x"4";  
   constant ADD   : std_logic_vector(3 downto 0) :=  x"5";
   constant ORL   : std_logic_vector(3 downto 0) :=  x"6";
   constant ANDL  : std_logic_vector(3 downto 0) :=  x"7";
   constant JMP   : std_logic_vector(3 downto 0) :=  x"8";     
   constant JC    : std_logic_vector(3 downto 0) :=  x"9";     
   constant JN    : std_logic_vector(3 downto 0) :=  x"A";
   constant JZ    : std_logic_vector(3 downto 0) :=  x"B";
   constant JSR   : std_logic_vector(3 downto 0) :=  x"C";
   constant RTS   : std_logic_vector(3 downto 0) :=  x"D";
   constant JV    : std_logic_vector(3 downto 0) :=  x"E";
   constant HLT   : std_logic_vector(3 downto 0) :=  x"F";

   -- CODIFICAÇÃO DOS MODOS DE ENDEREÇAMENTO
   constant IM    : std_logic_vector(1 downto 0) :=  "00";
   constant DIR   : std_logic_vector(1 downto 0) :=  "01";    
   constant IND   : std_logic_vector(1 downto 0) :=  "10";
   constant REL   : std_logic_vector(1 downto 0) :=  "11";    

   --
   -- definicao das microinstrucoes em funcao dos registradores destino/origem
   --                                             alu    wr     rd    lnz lcv  ce  rw 
   constant mar_pc    		: microinstrucao := ("111", "000", "011", '0','0', '0','0');  -- mar <- pc  
   constant mar_mdr   		: microinstrucao := ("100", "000", "001", '0','0', '0','0');  -- mar <- mdr
   constant mdr_MmarP 		: microinstrucao := ("001", "110", "011", '0','0', '1','1');  -- mdr <- pmem(mar); pc++
   constant mdr_Mmar  		: microinstrucao := ("111", "001", "110", '0','0', '1','1');  -- mdr <- pmem(mar)
   constant mar_mdrpc 		: microinstrucao := ("000", "000", "111", '0','0', '0','0');  -- mar <- mdr+PC 
   constant ir_mdr    		: microinstrucao := ("100", "010", "001", '0','0', '0','0');  -- ir  <- mdr
   constant pc_mdr    		: microinstrucao := ("100", "011", "001", '0','0', '0','0');  -- pc  <- mdr
   constant pc_mdrpc  		: microinstrucao := ("000", "011", "111", '0','0', '0','0');  -- pc  <- mdr + pc
   constant rts_pc    		: microinstrucao := ("111", "101", "011", '0','0', '0','0');  -- rts <- pc
   constant nop       		: microinstrucao := ("111", "111", "110", '0','0', '0','0');  -- nao faz nada 
   constant rts_pc_pcminus1	: microinstrucao := ("111", "101", "111", '0','0', '0','0');  -- rts <- pc - 1
   constant pc_Mirq			: microinstrucao := ("111", "011", "111", '0','0', '0','0');  -- pc <- pmem(trat_sw) 

   alias i  : std_logic_vector(3 downto 0) is ir(7 downto 4);     -- pedaços do IR
   alias me : std_logic_vector(1 downto 0) is ir(3 downto 2);

   signal salta, logic_arith : std_logic;                         -- auxiliares

   signal EA, PE: CleoStates_type;                                -- estados da máquina de estado

begin
       
   salta <= '1'  when ((i=JC and c='1') or (i=JV and v='1') or (i=JN and n='1') or (i=JZ and z='1')) else
            '0';
             
   logic_arith <= '1' when  i=LDA or i=ADD or i=ORL or i=ANDL else
                  '0';
   
   -- processo para implementar registrador de estado 
   process (clock, reset)
    begin
         if reset='1' then
              EA  <= Sidle; -- Sidle is the state the machine stays while processor is being reset
              halt <= '0';
         elsif clock'event and clock='1' then
              if i=HLT then 
                  halt <= '1';        -- avisa que trancou
              elsif hold='0' then     -- processador pára com hold='0'
                  EA <= PE;           -- prossegue se hold='1'
              end if;  
         end if;
   end process;
  
  -- processo para implementar funções de saída e próximo estado
  process (hold, i, salta, EA, logic_arith, me)
  begin                  
     case EA is
          
       when SIDLE  => if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else	
						uins <= nop; 
                        PE <= FETCH0;                       -- não faz nada em SIDLE
						iack <= '0';						-- IACK <- 0
					  end if;

       --- 
       --- BUSCA DA INSTRUÇÃO
       ---             
       when FETCH0 => if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= mar_pc;                     -- MAR <- PC              primeiro ciclo da busca
                        PE <= FETCH1;
						iack <= '0';						-- IACK <- 0
					  end if;
                       
       when FETCH1 => if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= mdr_MmarP;                  -- MDR <- MEM(MAR); PC++  segundo ciclo da busca.
                        PE <= FETCH2;
					  end if;
              
       when FETCH2 => if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= ir_mdr;                     -- IR <- MDR              carga do ir
                  
                        case i is
                          when RTS | NOT1 | NOT2 | HLT =>  PE <=  Salu;
                          when others                  =>  PE <=  Sop1a;
                        end case; 
					  end if;
       --- 
       --- BUSCA DO OPERANDO DA INSTRUÇÃO
       ---  
       when Sop1a =>  if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= mar_pc;        -- MAR <- PC 
                        PE <=  Sop1b;
					  end if;
        
       when Sop1b =>  if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= mdr_MmarP;     -- MDR <- MEM(MAR); PC++
       
                        if logic_arith='1' and ME=IM then
                           PE <= Salu;
                        elsif  (logic_arith='1' and (ME=DIR or ME=IND or ME=REL)) or (i=STA1 or i=STA2) then
                           PE <= Sop2a;
                        elsif  (i=JMP  or salta='1') and (ME=IM or ME=DIR or ME=REL) then
                           PE <= Sjump;
                        elsif  (i=JMP  or salta='1') and  ME=IND then
                           PE <= OP2jp1;
                        elsif i=JSR then
                           PE <= Sjsr;
                        else
                           PE <= FETCH0;    -- volta para o FETCH, e.g., salto condicional com flag=0    
                        end if;
					  end if;
      --- 
      --- AÇÕES ESPECÍFICAS DAS INSTRUÇÕES LÓGICAS ARITMÉTICAS -- lda, and, or, add, not + STA + RTS
      ---
      when Sop2a =>   if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						case ME is
                            when REL    =>  uins <= mar_mdrpc;    -- MAR <- MDR + PC
                            when others =>  uins <= mar_mdr;      -- MAR <- MDR
                        end case;                                          
 
                        if (i=STA1 or i=STA2) and (ME=REL or ME=DIR) then
                                PE <= Salu;
                        else
                                PE <=  Sop2b;
                        end if;
					  end if;
                        
      when Sop2b =>   if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= mdr_Mmar;            -- MDR <- MEM(MAR)
                        
                        case ME is
                            when IND    =>  PE <=  Sop3a;
                            when others =>  PE <=  Salu;
                        end case;
					  end if;
					                                              
      when Sop3a =>   if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= mar_mdr;             -- MAR <- MDR

                        case i is
                            when STA1 | STA2 =>  PE <=  Salu;
                            when others      =>  PE <=  Sop3b;
                        end case;
					  end if;
           
      when Sop3b =>   if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= mdr_Mmar;            -- MDR <- MEM(MAR)
                        PE <=  Salu;
					  end if;
         
      when Salu  =>   if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						case i is 
    --                                               alu    wr     rd    lnz lcv  ce  rw 
                         when LDA         => uins <= ("100", "100", "001", '1','0', '0','0'); -- ac <- mdr; lnz
                         when ADD         => uins <= ("000", "100", "110", '1','1', '0','0'); -- ac <- ac + mdr;lnz;lcv
                         when ORL         => uins <= ("101", "100", "110", '1','0', '0','0'); -- ac <- ac or mdr; lnz
                         when ANDL        => uins <= ("110", "100", "110", '1','0', '0','0'); -- ac <- ac and mdr; lnz
                         when NOT1 | NOT2 => uins <= ("010", "100", "100", '1','0', '0','0'); -- ac <- not ac ; lnz
                         when RTS         => uins <= ("111", "011", "101", '0','0', '0','0'); -- pc <- rts
                         when STA1 | STA2 => uins <= ("111", "111", "100", '0','0', '1','0'); -- pmem(mar) <- ac
                         when others      => uins <= nop;                                   -- halt
                        end case;    
                      
                        PE <= FETCH0;
					  end if;
                    
      --- 
      --- AÇÕES ESPECÍFICAS DAS INSTRUÇÃO DE SALTO
      ---
      when Sjsr =>    if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= rts_pc;              -- RS <- PC

                        case ME is
                            when IND    =>  PE <=  OP2jp1;
                            when others =>  PE <=  Sjump;
                        end case;
					  end if;
            
      when OP2jp1  => if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= mar_mdr;             -- MAR <- MDR
                        PE <=  OP2jp2;
					  end if;
 
      when OP2jp2  => if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						uins <= mdr_Mmar;            -- MDR <- MEM(MAR)
                        PE <=  Sjump;
					  end if;
                        
      when Sjump =>  if irq='1' then
						PE <= SINT1;						-- Salta para tratamento de IRQ
					  else
						case ME is
                            when REL    =>  uins <= pc_mdrpc;      -- PC <- MDR + PC
                            when others =>  uins <= pc_mdr;        -- PC <- MDR
                        end case; 
                                            
                        PE <= FETCH0;
					  end if;
					  
      when SINT1 => uins <= rts_pc_pcminus1;     				   -- RS <- PC - 1
					iack <= '1';								   -- IACK <- 1
                    PE <= SINT2;								   -- Salta para o segundo estado da IRQ
					
	  when SINT2 => uins <= pc_Mirq;							   -- PC <- *(TRAT_SW)
					PE <= FETCH0;								   -- Vai para nova busca
     end case;
  end process; 
end control;
