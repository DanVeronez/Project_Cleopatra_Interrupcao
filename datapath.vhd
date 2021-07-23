--------------------------------------------------------------------------
-- Bloco de Dados
-- Descricao estrutural do bloco de dados do processador Cleópatra,
-- pela interconexão de várias de suas partes e criação do Mux que
-- gera entrada para o MDR e dos três barramentos internos
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use ieee.numeric_std_unsigned.all;
use work.cleo.all;

entity datapath is
    port(clock, reset, hold	: in std_logic;
         address, ir	: out internal_bus;
         datain			: in internal_bus;
         dataout		: out internal_bus;
 		 uins			: in microinstrucao;
		 n, z, c, v		: out std_logic
        ); 
end datapath;

architecture datapath of datapath is
signal	r_mdr,r_ir,r_pc,r_ac,r_rs,
		w_mar,w_mdr,w_ir,w_pc,w_ac,w_rs,
		n_inst, z_inst, c_inst, v_inst : std_logic; 
signal 	outmux, mdr, ir_int, pc, ac, rs, rs_mux, pc_mux,
		busA, busB, busC : internal_bus;
 
begin  

    ir <= ir_int;    -- instrucao corrente, a ser utilizada no bloco de controle
	
	--
	-- barramento de saída do processador é sempre a saída a ALU
	--
    dataout <= busC;
    
	--
	-- cria multiplexador que gera entrada para o registrador MDR e seu controle
	--
    outmux <= busC  when (uins.ce and uins.rw)='0' else datain;
		
    --
	-- cria multiplexador que gera a entrada para o registrador RS e seu controle
	--
	rs_mux <= pc-2 when (uins.u="111" and uins.w="101" and uins.r="111") else busC;
	--
	-- cria multiplexador que gera a entrada para o registrador PC e seu controle
	--
	pc_mux <= x"15" when (uins.u="111" and uins.w="011" and uins.r="111") else busC;
	--
    -- cria registradores de dados (mar, mdr, ir, pc, ac, rs),
	-- instancia-os e conecta-os 
    --
    REG_MAR: entity work.reg_clear port map (clock=>clock, reset=>reset,
		ce=>w_mar, D=>busC, Q=>address);
    REG_MDR: entity work.reg_clear port map (clock=>clock, reset=>reset,
		ce=>w_mdr, D=>outmux,  Q=>mdr);
    REG_IR: entity work.reg_clear port map (clock=>clock, reset=>reset,
		ce=>w_ir,  D=>busC, Q=>ir_int);
    REG_PC: entity work.reg_clear port map (clock=>clock, reset=>reset,
		ce=>w_pc,  D=>pc_mux, Q=>pc);
    REG_AC: entity work.reg_clear port map (clock=>clock, reset=>reset,
		ce=>w_ac,  D=>busC, Q=>ac);
    REG_RS: entity work.reg_clear port map (clock=>clock, reset=>reset,
		ce=>w_rs,  D=>rs_mux, Q=>rs);
  
	--
	-- instancia decodificador de escrita e conecta com habilitações de
	-- escrita dos registradores
	--
    W_DECOD: entity work.write_decoder port map(write_reg=>uins.w, 
		hold=>hold,
		w_mar=>w_mar, w_mdr=>w_mdr, w_ir=>w_ir,
		w_pc=>w_pc, w_ac=>w_ac, w_rs=>w_rs);
    
	--
	-- instancia decodificador de leitura e conecta com habilitações de
	-- tristates que controlam o que vai para barramentos busA e busB
	--
    R_DECOD: entity work.read_decoder port map(read_reg=>uins.r,
		r_mdr=>r_mdr, r_ir=>r_ir, r_pc=>r_pc, r_ac=>r_ac, r_rs=>r_rs);
		
    --
    -- cria tristates para jogar o valor de 1 ou 2 registradores
	-- nos barramentos de entrada da ALU, busA e busB
    --
    busB <= mdr     when r_mdr='1' else (others=>'Z');
    busB <= ir_int  when r_ir='1'  else (others=>'Z');
    busA <= pc      when r_pc='1'  else (others=>'Z');
    busA <= ac      when r_ac='1'  else (others=>'Z');
    busA <= rs      when r_rs='1'  else (others=>'Z');
    
	--
	-- instancia ALU e a conecta com barramentos busA, busB e busC,
	-- bem como com a entrada de controle e o registrador de estado
	--
    ALU: entity work.alu port map(A_bus=>busA, B_bus=>busB, C_bus=>busC,
		alu_op=>uins.u, n_inst=>n_inst, z_inst=>z_inst,
		c_inst=>c_inst, v_inst=>v_inst);

	--
	-- instancia o registrador de estado e conecta-o à ALU e a pinos da 
	-- interface com o bloco de controle
	--
    REG_STATUS: entity work.status_flags port map(clock=>clock,
		reset=>reset, hold=>hold, n_inst=>n_inst, z_inst=>z_inst,
		c_inst=>c_inst, v_inst=>v_inst, lnz=>uins.lnz,
		lcv=>uins.lcv,  n=>n, z=>z, c=>c, v=>v);

end datapath;
