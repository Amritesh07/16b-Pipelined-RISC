library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package matrix is
        type matrix is array(natural range <>) of std_logic_vector(15 downto 0);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix.all;

entity GenericMux is
        generic (dataWidth : positive := 16;
						seln: positive := 2);
        port (  I : in matrix(2**seln - 1 downto 0);
                S : in std_logic_vector(seln - 1 downto 0);
                O : out std_logic_vector(dataWidth - 1 downto 0));
end GenericMux;

architecture dataflow of GenericMux is
begin
        O<= I(to_integer(unsigned(S)));
end dataflow;