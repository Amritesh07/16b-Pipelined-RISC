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
	signal add_sig: std_logic_vector(16 downto 0);
	signal output_sig, nand_sig,g,w,x,y: std_logic_vector(15 downto 0);


	component OneBitAdder is
	  port (a,b,cin: in std_logic; s,cout: out std_logic);
	end component;



begin
	 x<=I1;
	 y<=I2;
   o2:  OneBitAdder port map(a=>x(1)  ,b=>y(1)  ,cin=>g(1)  ,s=>w(1)  ,cout=>g(2));
   o3:  OneBitAdder port map(a=>x(2)  ,b=>y(2)  ,cin=>g(2)  ,s=>w(2)  ,cout=>g(3));
	 o1:  OneBitAdder port map(a=>x(0)  ,b=>y(0)  ,cin=>'0'   ,s=>w(0)  ,cout=>g(1));
   o4:  OneBitAdder port map(a=>x(3)  ,b=>y(3)  ,cin=>g(3)  ,s=>w(3)  ,cout=>g(4));
   o5:  OneBitAdder port map(a=>x(4)  ,b=>y(4)  ,cin=>g(4)  ,s=>w(4)  ,cout=>g(5));
   o6:  OneBitAdder port map(a=>x(5)  ,b=>y(5)  ,cin=>g(5)  ,s=>w(5)  ,cout=>g(6));
   o7:  OneBitAdder port map(a=>x(6)  ,b=>y(6)  ,cin=>g(6)  ,s=>w(6)  ,cout=>g(7));
   o8:  OneBitAdder port map(a=>x(7)  ,b=>y(7)  ,cin=>g(7)  ,s=>w(7)  ,cout=>g(8));
   o9:  OneBitAdder port map(a=>x(8)  ,b=>y(8)  ,cin=>g(8)  ,s=>w(8)  ,cout=>g(9));
   o10: OneBitAdder port map(a=>x(9)  ,b=>y(9)  ,cin=>g(9)  ,s=>w(9)  ,cout=>g(10));
   o11: OneBitAdder port map(a=>x(10) ,b=>y(10) ,cin=>g(10) ,s=>w(10) ,cout=>g(11));
   o12: OneBitAdder port map(a=>x(11) ,b=>y(11) ,cin=>g(11) ,s=>w(11) ,cout=>g(12));
   o13: OneBitAdder port map(a=>x(12) ,b=>y(12) ,cin=>g(12) ,s=>w(12) ,cout=>g(13));
   o14: OneBitAdder port map(a=>x(13) ,b=>y(13) ,cin=>g(13) ,s=>w(13) ,cout=>g(14));
   o15: OneBitAdder port map(a=>x(14) ,b=>y(14) ,cin=>g(14) ,s=>w(14) ,cout=>g(15));
   o16: OneBitAdder port map(a=>x(15) ,b=>y(15) ,cin=>g(15) ,s=>w(15) ,cout=>add_sig(16) );  -- caary bit out here

	--add_sig<=to_stdlogicvec(to_int(operand1_sig)+to_int(operand2_sig));
	add_sig(15 downto 0)<=w;
	nand_sig<=I1 nand I2;
	output_sig <= nand_sig(15 downto 0) when sel ='1' else add_sig(15 downto 0);
	O<=output_sig;
	C<= not(sel) and add_sig(16);		-- 16th bit of addition is carry bit
	Z<= '1' when output_sig="0000000000000000" else '0';
end arch;

-------------------------------------------------supporting components-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity OneBitAdder is
  port (a,b,cin: in std_logic; s,cout: out std_logic);
end entity OneBitAdder;

architecture Behave of OneBitAdder is
begin
	-- s = (a xor b) xor cin
	s <= (a xor b) xor cin ;
	-- cout
	cout <= ( cin and (a xor b) ) or (a and b);
end Behave;
