library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
port(
		I1,I2 : in std_logic_vector(15 downto 0);
		O: out std_logic_vector(15 downto 0);
		Sel: in std_logic;
		C,Z: out std_logic);
end ALU;

architecture arch of ALU is
	signal add_sig,nand_sig: std_logic_vector(16 downto 0);
	signal output_sig: std_logic_vector(15 downto 0);
begin
	add_sig<=std_logic_vector(unsigned(I1)+unsigned(I2));
	nand_sig<=I1 nand I2;
	output_sig <= nand_sig(15  downto 0) when sel ='1' else add_sig(15 downto 0);
	O<=output_sig;
	C<= not(sel) and add_sig(16);		-- 16th bit of addition is carry bit
	Z<= '1' when output_sig="0000000000000000" else '0';
end arch;
