library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity iROM is
  port (
    clock   : in  std_logic;
    load_mem: in std_logic;
    mem_loaded : out std_logic;
    address : in  std_logic_vector(15 downto 0);
    dataout : out std_logic_vector(15 downto 0)
  );
end entity iROM;

architecture iRTL of iROM is

   type ram_type is array (0 to 511) of std_logic_vector(15 downto 0);


   signal ram : ram_type;
   signal read_address : std_logic_vector(15 downto 0);
   signal masking_vec : std_logic_vector(15 downto 0) := "0000000111111111";
   signal r_address:std_logic_vector(15 downto 0):="0000000000000000";
function CONV_INTEGER(x: std_logic_vector) return integer is
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
  end CONV_INTEGER;
  signal ram_data: std_logic_vector(15 downto 0);
  signal wr_flag:std_logic:='1';
  type hram_type is array (0 to 32) of std_logic_vector(15 downto 0);
 signal in_array: hram_type:= (
 --"0001110111000100",  -- ADI R7<-( R6) 4
 --"0011001000000001",  --LHI R1,00000001
 --"0001011010000001",  --ADI R3,R2,00001
 --"0101010100000010",  -- SW R2,R4,00010
 --"0011101000000001",  -- LHI R5,0000001
 --"0011011000000001"  --LHI R3,00000001
 --"0011000111111111", -- LHI R0, 111111111 -> FF80h
 --"0000000000001000", -- ADD R1<=R0+R0
 --"1111000000000000",
 --"1111000000000000",
 --"0000001010010010",  -- ADC R2=R1+rR
 --"0000001001011010"   -- ADC R3<=R1+R1
 "1000000000011101",
 "0100100110000101",
 "0001110000111101",
 "0100110110000101",
 "0110000000000011",
 "0001000010000000",
 "0010000001011000",
 "0010011011011000",
 "0001011011000000",
 "0000100010100001",
 "0000000000000000",
 "0010110110110010",
 "1100110101111010",
 "0101100101010110",
 "0000000000000011",
 "0000000000000000",
 "0000000000000010",
 "0000000000000011",
 "0001011011000001",
 "0001110110010111",
 "0101000110000100",
 "0100000110000000",
 "0100001110000001",
 "1100101001001100",
 "0000010000010000",
 "0000100011100010",
 "0001001001111111",
 "0001111111111100",
 "0001110000000010",
 "0111000000010100",
 "0001011011111111",
 "0101011110000101",
 "0100111110000100"

);

begin
	r_address <= address and masking_vec;
	dataout <= ram(CONV_INTEGER(r_address));
  RamProc: process(clock,wr_flag) is
  variable address_in: integer:=0;
  variable address_in_r:integer:=0;
  begin
    if (rising_edge(clock) and ((load_mem = '1') and (wr_flag='1'))) then
      ram(address_in_r) <= in_array(address_in);
    if(address_in = 32) then mem_loaded <='1'; 			wr_flag<='0'; else mem_loaded<='0'; end if;
    if(address_in_r=13) then address_in_r:=20;
    elsif(address_in_r=21) then address_in_r:=23;
    elsif(address_in_r=24) then address_in_r:=29;
    elsif(address_in_r=38) then address_in_r:=46;
    else address_in_r:=address_in_r+1;
    end if;
    address_in:=address_in+1;

    end if;


  end process RamProc;



end architecture iRTL;
