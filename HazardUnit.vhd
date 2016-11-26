library ieee;
use ieee.std_logic_1164.all;
PACKAGE matrixType IS
        TYPE matrix16 IS ARRAY (NATURAL RANGE <>) OF std_logic_vector(15 downto 0);
        TYPE matrix3 IS ARRAY (NATURAL RANGE <>) OF std_logic_vector(2 downto 0);
END PACKAGE matrixType;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrixType.all;
library std;
use std.textio.all;

----------------------------- HARSHVARDHAN ---------------------------------
-----** --------------------HAZARD DETECTION LOGIC---------------------------
--  perform stall and flush
--  See cases where R7 is destination and perform flush
--  See whether stall has to be done
-----------------------------------------------------------------------------

entity HazardUnit is
port (
stallflag: in std_logic;
Instruction_pipeline: in matrix16(0 to 4); --  0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
carry_ex: in std_logic;
zero_ex: in std_logic;
regDest: in matrix3(0 to 4);               --0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
Lm_sel: in std_logic_vector(7 downto 0);
Instr_out: out matrix16(0 to 5);
pipeline_enable: out std_logic_vector(0 to 4)  --  0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
         ) ;
end HazardUnit ;
-----
architecture behave of HazardUnit is
signal Stalled_flushed_instr: matrix16(0 to 4);
signal pipeline_reg_enable : std_logic_vector(0 to 5);
begin
  process( Instruction_pipeline, Lm_sel, carry_ex, zero_ex, stallflag, regDest )
    variable var_instr_out: matrix16(0 to 4) := Instruction_pipeline;
    variable var_pipeline_reg_enable : std_logic_vector(0 to 5):="111111";
    begin
      ------
      if (stallflag='1') then
          var_instr_out(3)(15 downto 12) := "1111";    -- write in pipeline register of EX stage
          var_pipeline_reg_enable(2) := '0';            -- stall the RR stage
      end if;
      ------
      if ( (regDest(4)="111" and Instruction_pipeline(4)(15 downto 12)="0100") or (Lm_sel(7)=='1' and Instruction_pipeline(4)(15 downto 12)="0110" ) ) then    -- check for hazard in mem stage LOAD instr
          -- flush 4 stages
          var_instr_out(3)(15 downto 12) := "1111";
          var_instr_out(2)(15 downto 12) := "1111";
          var_instr_out(1)(15 downto 12) := "1111";
          var_instr_out(0)(15 downto 12) := "1111";
      elsif ( regDest(3)="111" and Instruction_pipeline(3)(15 downto 14)="00" and Instruction_pipeline(3)(15 downto 14) /= "11"  )----  R type
          if (( Instruction_pipeline(3)(13)='1' and carry_ex='1') or ( Instruction_pipeline(3)(12)='1' and zero_ex='1') or (Instruction_pipeline(3)(13 downto 12)="00")) then
              var_instr_out(2)(15 downto 12) := "1111";
              var_instr_out(1)(15 downto 12) := "1111";
              var_instr_out(0)(15 downto 12) := "1111";
          end if;
      elsif (Instruction_pipeline(2)(15 downto 12)="1100" or Instruction_pipeline(2)(15 downto 12)="1001") then --- BEQ or JLR
          var_instr_out(1)(15 downto 12) := "1111";
          var_instr_out(0)(15 downto 12) := "1111";
      elsif (Instruction_pipeline(1)(15 downto 12)="1000" or ( regDest(1)="111" and Instruction_pipeline(1)(15 downto 12)="0011")) then -- JAL or LHI\
          var_instr_out(0)(15 downto 12) := "1111";
      end if;
      Stalled_flushed_instr <= var_instr_out;
      pipeline_reg_enable <= var_pipeline_reg_enable;
  end process;
  Instr_out <= Stalled_flushed_instr;
  pipeline_enable <= pipeline_reg_enable;
end behave;
