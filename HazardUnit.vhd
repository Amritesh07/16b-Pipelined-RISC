library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;
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
------------------------
lw_out: in std_logic_vector(15 downto 0);
lm_out: in std_logic_vector(15 downto 0);
aluop: in std_logic_vector(15 downto 0);
JLRreg:in std_logic_vector(15 downto 0);
Pc_Im6:in std_logic_vector(15 downto 0);
Pc_Im9:in std_logic_vector(15 downto 0);
padder:in std_logic_vector(15 downto 0);
-------------
stallflag: in std_logic;
Instruction_pipeline: in matrix16(0 to 4); --  0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
carry_ex: in std_logic;
zero_ex: in std_logic_vector(2 downto 0);  -- 0-LW_zero_sig, 1-ALU_zer_sig, 2-zero_sig
regDest: in matrix3(0 to 3);               -- 0-ID, 1-RR, 2-EX, 3-MEM
Lm_sel_r7: in std_logic;
BEQequal: in std_logic;
PCplus1 : in std_logic_vector(15 downto 0);
Instr_out: out matrix16(0 to 4):=(others=>(others=>'0'));
pipeline_enable: out std_logic_vector(0 to 4);  --  0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
PC_write_en: out std_logic;
PCval: out std_logic_vector(15 downto 0)
         ) ;
end HazardUnit ;
-----
architecture behave of HazardUnit is
signal Stalled_flushed_instr: matrix16(0 to 4):=(others=>(others=>'1'));
signal pipeline_reg_enable : std_logic_vector(0 to 4):=(others=>'1');
signal pcEn:std_logic:='1';
signal PC_sig:std_logic_vector(15 downto 0):=(others=>'0');
begin
  process( Instruction_pipeline, lw_out, lm_out, aluop, JLRreg, Pc_Im6, Pc_Im9, padder, PCplus1
          ,Lm_sel_r7, carry_ex, zero_ex, stallflag, regDest,  BEQequal
          )
    variable var_instr_out: matrix16(0 to 4) := Instruction_pipeline;
    variable var_pipeline_reg_enable : std_logic_vector(0 to 4):="11111";
    variable var_pc_en: std_logic:='1';
    variable zero_logic:std_logic:='1';
    variable PC_var:std_logic_vector(15 downto 0);
    begin
      ------
      var_instr_out := Instruction_pipeline;
      var_pc_en:='1';
      var_pipeline_reg_enable:="11111";
      if (stallflag='1') then
          var_instr_out(2)(15 downto 12) := "1111";    -- write in pipeline register of EX stage
          var_pipeline_reg_enable(0) := '0';            -- stall the IF stage
          var_pipeline_reg_enable(1) := '0';            -- stall the ID stage
          var_pc_en:='0';
      end if;
      ------
      PC_var:=PCplus1;

      if ( (regDest(3)="111" and Instruction_pipeline(4)(15 downto 12)="0100") or
      (Lm_sel_r7='1' and Instruction_pipeline(4)(15 downto 12)="0110" ) ) then    -- check for hazard in mem stage LOAD instr
          -- flush 4 stages
          var_instr_out(3)(15 downto 12) := "1111";
          var_instr_out(2)(15 downto 12) := "1111";
          var_instr_out(1)(15 downto 12) := "1111";
          var_instr_out(0)(15 downto 12) := "1111";
          if Instruction_pipeline(3)(13)='0' then
                PC_var:=lw_out;
          else
                PC_var:=lm_out;
          end if;

      elsif ( regDest(2)="111" and Instruction_pipeline(3)(15 downto 14)="00"
            and Instruction_pipeline(3)(15 downto 14) /= "11"  ) then----  R type

          if  ( (Instruction_pipeline(3)(15 downto 12)="0001")  --adi
              or  ( Instruction_pipeline(3)(1)='1' and carry_ex='1') or -- ADC
              ( Instruction_pipeline(3)(0)='1' and      -- ADZ
              ((Instruction_pipeline(4)(15 downto 12)="0100" and zero_ex(0)='1') or (zero_ex(1)='1' and Instruction_pipeline(4)(15 downto 14)="00" and Instruction_pipeline(4)(13 downto 12)/="11" )
              or (zero_ex(2)='1' and not(Instruction_pipeline(4)(15 downto 12)="0100") and not(Instruction_pipeline(4)(15 downto 14)="00" and Instruction_pipeline(4)(13 downto 12)/="11"))))
              or (Instruction_pipeline(3)(1 downto 0)="00")) then   -- ADD
              var_instr_out(2)(15 downto 12) := "1111";
              var_instr_out(1)(15 downto 12) := "1111";
              var_instr_out(0)(15 downto 12) := "1111";
              PC_var:=aluop;
          end if;
      elsif ( (Instruction_pipeline(2)(15 downto 12)="1100" and BEQequal='1')
            or Instruction_pipeline(2)(15 downto 12)="1001") then --- BEQ or JLR
          var_instr_out(1)(15 downto 12) := "1111";
          var_instr_out(0)(15 downto 12) := "1111";
          if Instruction_pipeline(2)(14)='1' then
              PC_var:=Pc_Im6;
          else
              PC_var:=JLRreg;
          end if;
      elsif (Instruction_pipeline(1)(15 downto 12)="1000" or
            ( regDest(0)="111" and Instruction_pipeline(1)(15 downto 12)="0011")) then -- JAL or LHI ------
          var_instr_out(0)(15 downto 12) := "1111";
          if Instruction_pipeline(1)(15)='1' then
              PC_var:=Pc_Im9;
          else
              PC_var:=padder;
          end if;
      end if;
      var_instr_out := Instruction_pipeline;
      PC_sig<=PC_var;
      Stalled_flushed_instr <= var_instr_out;
      pcEn<=var_pc_en;
      pipeline_reg_enable <= var_pipeline_reg_enable;
  end process;
 --Print_Proc:process begin report "I'm here"; end process;
  PCval<=PC_sig;
  PC_write_en<=pcEn;
  Instr_out <= Stalled_flushed_instr;
  pipeline_enable <= pipeline_reg_enable;
end behave;
