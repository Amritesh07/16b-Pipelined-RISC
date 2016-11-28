library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.components.all;

entity GenericMux is
        generic (dataWidth : positive := 16;
						seln: positive := 2);
        port (  I : in matrix16(2**seln - 1 downto 0);
                S : in std_logic_vector(seln - 1 downto 0);
                O : out std_logic_vector(dataWidth - 1 downto 0));
end GenericMux;

architecture dataflow of GenericMux is
  function to_int(x: std_logic_vector) return integer is
      variable ret_val: integer:=0;
      alias lx : std_logic_vector (x'length-1 downto 0) is x;
	variable pow: integer:=1;
  begin
	for I in 0 to x'length-1 loop
		if (lx(I) = '1') then
      			ret_val := ret_val + pow;
		end if;
		pow:=pow*2;
	end loop;
      return(ret_val);
  end to_int;
begin
        O<= I(to_int((S)));
end dataflow;
