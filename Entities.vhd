
------------------------------COMPONENTS------------------------------


-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity DataRegister is
	generic (data_width:integer);
	port (Din: in std_logic_vector(data_width-1 downto 0);
	      Dout: out std_logic_vector(data_width-1 downto 0);
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
-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity padder is 
port ( I : in std_logic_vector(8 downto 0);
		 O : out std_logic_vector(15 downto 0));
end padder;
architecture arch of padder is
begin
O(15 downto 7)<=I(8 downto 0);
O(6 downto 0)<="0000000";
end arch;

-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity SignExtend_9 is
port( 	--- Input
		IN_9:in std_logic_vector(9 downto 1);
		OUT_16: out std_logic_vector(16 downto 1)
		);
end entity SignExtend_9;

architecture dataflow of SignExtend_9 is
begin
		OUT_16(8 downto 1)<=IN_9(8 downto 1); -- add the data 
		OUT_16(16 downto 9)<="11111111" when IN_9(9)='1' else "00000000";		-- add one to all places for twos complement representation
end dataflow;

-------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity SignExtend_6 is
port( 	--- Input
		IN_6:in std_logic_vector(6 downto 1);
		OUT_16: out std_logic_vector(16 downto 1)
		);
end entity SignExtend_6;

architecture dataflow of SignExtend_6 is
	begin
	OUT_16(5 downto 1)<=IN_6(5 downto 1); -- add the data 
		OUT_16(16 downto 6)<="11111111111" when IN_6(6)='1' else "00000000000";		-- add one to all places for twos complement representation
end dataflow;
-------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Add_1 is 
port(
	I: in std_logic_vector(15 downto 0);
	O: out std_logic_vector(15 downto 0)
	);
end entity Add_1;

architecture Dataflow of Add_1 is
begin
	O<= std_logic_vector(unsigned(I)+1);
end dataflow;
---------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Adder is 
port(
	I1,I2: in std_logic_vector(15 downto 0);
	O: out std_logic_vector(15 downto 0)
	);
end entity Adder;

architecture Dataflow of Adder is
begin
	O<= std_logic_vector(unsigned(I1)+unsigned(I2));
end dataflow;

---------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity isEqual is
port(I1,I2: in std_logic_vector(15 downto 0);
		O: out std_logic);
end entity isEqual;

architecture arch of isEqual is
begin
	O<='1' when I1=I2 else '0';
end arch;