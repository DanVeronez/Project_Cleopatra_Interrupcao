--------------------------------------------------------------------------
-- Package cleo
-- Com tipos básicos e codificação de instruções
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;

package cleo is
    constant bus_size: integer :=8;
    subtype opcode  is std_logic_vector(2 downto 0);
    subtype internal_bus is std_logic_vector(bus_size-1 downto 0);
    type ram is array (0 to 255) of internal_bus;
    
    type microinstrucao is record 
               u, w, r : opcode;
               lnz, lcv, ce, rw : std_logic;
    end record;
      
end cleo;
