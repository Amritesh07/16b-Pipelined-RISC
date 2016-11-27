library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.components.all;
use work.common.all;
package PipelineRegister is
	TYPE matrix16 IS ARRAY (NATURAL RANGE <>) OF std_logic_vector(15 downto 0);
	type IF_ID_type	is Record
		I16, PC, PC_1: std_logic_vector(15 downto 0);
	end Record;
	type ID_RR_type	is Record
		-- data to be forwarded
		I16, PC, PC_1, SE6, Padder, PC_Imm6: std_logic_vector(15 downto 0);
		-- contols to be forwarded
		A1, A2: std_logic_vector(2 downto 0);
		RF:  RegFileCtrl; -- A3 included here -- to be taken untill WB stage
 	  DRAM: dramCtrl;
    ALUsel: std_logic;
    M6_sel,M7_sel,M9_sel: std_logic_vector(0 downto 0);
 	  M3_sel: std_logic_vector(1 downto 0);
 	  M4_sel,M5_sel: std_logic_vector(2 downto 0);
	end Record;
	type RR_EX_type is Record
	  -- data to be forwarded
		I16, PC_1, SE6, Padder, D1, D2: std_logic_vector(15 downto 0);
		C_old, Z_old: std_logic;
		D_multiple: matrix16(7 downto 0);
    -- controls to be forwarded
    ALUsel: std_logic;
    RF:  RegFileCtrl; -- A3 included here -- to be taken untill WB stage
 	  DRAM:  dramCtrl;
 	  M6_sel, M7_sel, M9_sel: std_logic_vector(0 downto 0);
 	  M3_sel: std_logic_vector(1 downto 0);
	end Record;
	type EX_MEM_type is Record
	  -- data to be forwarded
		I16, PC_1, Padder, ALU_OUT, D1: std_logic_vector(15 downto 0);
		C_old, Z_old, C_new, Z_new: std_logic;
		-- controls to be forwarded
		RF:  RegFileCtrl; -- A3 included here -- to be taken untill WB stage
 	  DRAM:  dramCtrl;
 	  D_multiple, A_multiple: matrix16(7 downto 0);
		M9_sel: std_logic_vector(0 downto 0);
 	  M3_sel: std_logic_vector(1 downto 0);
	end Record;
	type MEM_WB_type is Record
	  -- data to be forwarded
		I16, PC_1, Padder, ALU_OUT: std_logic_vector(15 downto 0);
		C_old, Z_old, C_new, Z_new: std_logic;
		-- controls to be forwarded
		RF:  RegFileCtrl; -- A3 included here -- to be taken untill WB stage
    mem_out: std_logic_vector(15 downto 0);
    D_multiple: matrix16(7 downto 0);
		M3_sel: std_logic_vector(1 downto 0);
	end Record;
end package;


library ieee;
use ieee.std_logic_1164.all;
entity IF_ID_reg is;
	port (Din: in IF_ID_type;
	      Dout: out IF_ID_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of DataRegister is
begin
    process(clk)
    begin
       if(clk'event and (clk  = '1')) then
           if(enable = '1') then
               Dout <= Din;
           end if;
       end if;
    end process;
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity ID_RR_reg is
	port (Din: in ID_RR_type;
	      Dout: out ID_RR_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of DataRegister is
begin
    process(clk)
    begin
       if(clk'event and (clk  = '1')) then
           if(enable = '1') then
               Dout <= Din;
           end if;
       end if;
    end process;
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity RR_EX_reg is
	port (Din: in RR_EX_type;
	      Dout: out RR_EX_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of DataRegister is
begin
    process(clk)
    begin
       if(clk'event and (clk  = '1')) then
           if(enable = '1') then
               Dout <= Din;
           end if;
       end if;
    end process;
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity EX_MEM_reg is
	port (Din: in EX_MEM_type;
	      Dout: out EX_MEM_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of DataRegister is
begin
    process(clk)
    begin
       if(clk'event and (clk  = '1')) then
           if(enable = '1') then
               Dout <= Din;
           end if;
       end if;
    end process;
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity  MEM_WB_reg is
	port (Din: in MEM_WB_type;
	      Dout: out MEM_WB_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of DataRegister is
begin
    process(clk)
    begin
       if(clk'event and (clk  = '1')) then
           if(enable = '1') then
               Dout <= Din;
           end if;
       end if;
    end process;
end Behave;
