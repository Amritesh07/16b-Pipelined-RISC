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
begin
        O<= I(to_integer(unsigned(S)));
end dataflow;
