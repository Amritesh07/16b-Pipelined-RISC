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
  type hram_type is array (0 to 2) of std_logic_vector(15 downto 0);
 signal in_array: hram_type:= (
 "0011001000000001",
 "0001010011000001",
 "0101010100000000"
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
		    if(address_in = 2) then
          mem_loaded <='1';
          wr_flag<='0';
        else mem_loaded<='0';
        end if;

      address_in_r:=address_in_r+1;
		  address_in:=address_in+1;

    end if;


  end process RamProc;



end architecture iRTL;
