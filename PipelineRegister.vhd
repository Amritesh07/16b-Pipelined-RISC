library ieee;
use ieee.std_logic_1164.all;
use work.components.all;
entity IF_ID_reg is
	port (Din: in IF_ID_type;
	      Dout: out IF_ID_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of IF_ID_reg is
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
use work.components.all;
entity ID_RR_reg is
	port (Din: in ID_RR_type;
	      Dout: out ID_RR_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of ID_RR_reg is
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
use work.components.all;
entity RR_EX_reg is
	port (Din: in RR_EX_type;
	      Dout: out RR_EX_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of RR_EX_reg is
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
use work.components.all;
entity EX_MEM_reg is
	port (Din: in EX_MEM_type;
	      Dout: out EX_MEM_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of EX_MEM_reg is
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
use work.components.all;
entity  MEM_WB_reg is
	port (Din: in MEM_WB_type;
	      Dout: out MEM_WB_type;
	      clk, enable: in std_logic);
end entity;
architecture Behave of MEM_WB_reg is
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
