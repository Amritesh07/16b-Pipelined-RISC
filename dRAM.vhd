library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity dRAM is
  port (
    clock   : in  std_logic;
    mem_ctr : in std_logic_vector(7 downto 0);
    di0mem  : in std_logic_vector(15 downto 0);
    di1mem  : in std_logic_vector(15 downto 0);
    di2mem  : in std_logic_vector(15 downto 0);
    di3mem  : in std_logic_vector(15 downto 0);
    di4mem  : in std_logic_vector(15 downto 0);
    di5mem	 : in std_logic_vector(15 downto 0);
    di6mem  : in std_logic_vector(15 downto 0);
    di7mem  : in std_logic_vector(15 downto 0);
    ai0mem  : in std_logic_vector(0 to 15);
    ai1mem  : in std_logic_vector(0 to 15);
    ai2mem  : in std_logic_vector(0 to 15);
    ai3mem  : in std_logic_vector(0 to 15);
    ai4mem  : in std_logic_vector(0 to 15);
    ai5mem	 : in std_logic_vector(0 to 15);
    ai6mem  : in std_logic_vector(0 to 15);
    ai7mem  : in std_logic_vector(0 to 15);
    do0mem  : out std_logic_vector(15 downto 0);
    do1mem  : out std_logic_vector(15 downto 0);
    do2mem  : out std_logic_vector(15 downto 0);
    do3mem  : out std_logic_vector(15 downto 0);
    do4mem  : out std_logic_vector(15 downto 0);
    do5mem	 : out std_logic_vector(15 downto 0);
    do6mem  : out std_logic_vector(15 downto 0);
    do7mem  : out std_logic_vector(15 downto 0);

    pathway: in bit;	-- 0-single, 1 Multiple
    writeEN: in bit;
    load_mem: in bit;
    mem_loaded: out bit;
    ai_mem: in std_logic_vector(0 to 15);
    di_mem: in std_logic_vector(15 downto 0);
    do_mem: out std_logic_vector(15 downto 0)


  );
end entity dRAM;

architecture dRTL of dRAM is

   type ram_type is array (0 to 511) of std_logic_vector(15 downto 0);
type hram_type is array (0 to 26) of std_logic_vector(15 downto 0);

   signal ram : ram_type;
   signal read_address : std_logic_vector(0 to 15);
   signal masking_vec : std_logic_vector(15 downto 0) := "0000000111111111";
   signal r_address,r0_address,r1_address,r2_address,r3_address,r4_address,r5_address,r6_address,r7_address:std_logic_vector(15 downto 0):="0000000000000000";
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
 signal in_array: hram_type:= (
"0011001000000010", --0
"0011010000000010", --1
"0011101000000010", --2
"0011011000000010", --3
"0100000010000001", --4
"0000000000100000", --5
"0100100101000010", --6
"0100000010000011", --7
"0000100100110001", --8
"0000001000011001", --9
"0000001000010010", --10
"0101000011000010", --11
"0100010011000010", --12
"0101011010000001", --13
"0110000000111111", --14
"0001111000011001", --15
"0001111111011001", --16
"0100100110000000", --17
"0010011110100001", --18
"0010101110001000", --19
"0000000000000000",--256,20
"0000000000000010",--257,21
"0000000000000110",--258,22
"0000000100000000",--259,23
"0000000000000101",--260,24
"0000000000000110",--261,25
"0000000100000000"--262 ,26
);

begin

	r_address <= ai_mem and masking_vec;
  r0_address <= ai0mem and masking_vec;
  r1_address <= ai1mem and masking_vec;
  r2_address <= ai2mem and masking_vec;
  r3_address <= ai3mem and masking_vec;
  r4_address <= ai4mem and masking_vec;
  r5_address <= ai5mem and masking_vec;
  r6_address <= ai6mem and masking_vec;
  r7_address <= ai7mem and masking_vec;
	do_mem <= ram(CONV_INTEGER(r_address));
  do0mem <= ram(CONV_INTEGER(r0_address));
  do1mem <= ram(CONV_INTEGER(r1_address));
  do2mem <= ram(CONV_INTEGER(r2_address));
  do3mem <= ram(CONV_INTEGER(r3_address));
  do4mem <= ram(CONV_INTEGER(r4_address));
  do5mem <= ram(CONV_INTEGER(r5_address));
  do6mem <= ram(CONV_INTEGER(r6_address));
  do7mem <= ram(CONV_INTEGER(r7_address));

  RamProc: process(clock,wr_flag) is
  variable address_in: integer:=0;
  variable address_in_r:integer:=0;
  begin
    if rising_edge(clock) then
      	if (writeEN = '1' and pathway ='1' )then
        	ram(CONV_INTEGER(ai_mem)) <= di_mem;
        elsif (writeEN = '1' and mem_ctr(0) ='1' )then
          ram(CONV_INTEGER(ai0mem)) <= di0mem;
        elsif (writeEN = '1' and mem_ctr(1) ='1' )then
            ram(CONV_INTEGER(ai1mem)) <= di1mem;
        elsif (writeEN = '1' and mem_ctr(2) ='1' )then
            ram(CONV_INTEGER(ai2mem)) <= di2mem;
        elsif (writeEN = '1' and mem_ctr(3) ='1' )then
            ram(CONV_INTEGER(ai3mem)) <= di3mem;
        elsif (writeEN = '1' and mem_ctr(4) ='1' )then
            ram(CONV_INTEGER(ai4mem)) <= di4mem;
        elsif (writeEN = '1' and mem_ctr(5) ='1' )then
            ram(CONV_INTEGER(ai5mem)) <= di5mem;
        elsif (writeEN = '1' and mem_ctr(6) ='1' )then
            ram(CONV_INTEGER(ai6mem)) <= di6mem;
        elsif (writeEN = '1' and mem_ctr(7) ='1' )then
            ram(CONV_INTEGER(ai7mem)) <= di7mem;
        end if;
  --dataout <= "0000000000000000";
	--else
	--dataout <= ram(CONV_INTEGER(address));

	end if;

	if((load_mem = '1') and (wr_flag='1')) then

		ram(address_in_r) <= in_array(address_in);
		if(address_in = 26) then mem_loaded <='1'; wr_flag<='0'; else mem_loaded<='0'; end if;
		if(address_in_r=19) then address_in_r:=256;
		else address_in_r:=address_in_r+1;
		end if;
		address_in:=address_in+1;


	end if;


  end process RamProc;



end architecture dRTL;
