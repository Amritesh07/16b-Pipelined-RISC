library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.components.all;

entity dRAM is
  port (
    clock   : in  std_logic;
    mem_ctr : in std_logic_vector(7 downto 0);
    Din_mem: in matrix16(7 downto 0);
    Dout_mem: out matrix16(7 downto 0);
    Addr_mem: in matrix16(7 downto 0);
    pathway: in std_logic;
    writeEN: in std_logic;
    load_mem: in std_logic;
    mem_loaded: out std_logic;
    ai_mem: in std_logic_vector(15 downto 0);
    di_mem: in std_logic_vector(15 downto 0);
    do_mem: out std_logic_vector(15 downto 0)
  );
end entity dRAM;

architecture dRTL of dRAM is

   type ram_type is array (0 to 511) of std_logic_vector(15 downto 0);

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
  type hram_type is array (0 to 32) of std_logic_vector(15 downto 0);

 signal in_array: hram_type:= (
 "1000000000011101",
 "0100100110000101",
 "0001000110111101",
 "0100110110000101",
 "0110000000000011",
 "0001010000000000",
 "0010011001000000",
 "0010011011011000",
 "0001011011000000",
 "0000100100010001",
 "0000000000000000",
 "0010110110110010",
 "1100110101111010",
 "0101100101010110",
 "0000000000000001",
 "1111111111100000",
 "0000000000000010",
 "0000000000000011",
 "0001011011000001",
 "0001110110010111",
 "0101000110000100",
 "0100000110000000",
 "0100001110000001",
 "1100101001001100",
 "0000010010000000",
 "0000100100011010",
 "0001001001111111",
 "0001111111111100",
 "0001000110000010",
 "0111000000010100",
 "0001011011111111",
 "0101011110000101",
 "0100111110000100"
);

begin

	r_address <= ai_mem and masking_vec;
  r0_address <= Addr_mem(0) and masking_vec;
  r1_address <= Addr_mem(1) and masking_vec;
  r2_address <= Addr_mem(2) and masking_vec;
  r3_address <= Addr_mem(3) and masking_vec;
  r4_address <= Addr_mem(4) and masking_vec;
  r5_address <= Addr_mem(5) and masking_vec;
  r6_address <= Addr_mem(6) and masking_vec;
  r7_address <= Addr_mem(7) and masking_vec;
	do_mem <= ram(CONV_INTEGER(r_address));
  Dout_mem(0) <= ram(CONV_INTEGER(r0_address));
  Dout_mem(1) <= ram(CONV_INTEGER(r1_address));
  Dout_mem(2) <= ram(CONV_INTEGER(r2_address));
  Dout_mem(3) <= ram(CONV_INTEGER(r3_address));
  Dout_mem(4) <= ram(CONV_INTEGER(r4_address));
  Dout_mem(5) <= ram(CONV_INTEGER(r5_address));
  Dout_mem(6) <= ram(CONV_INTEGER(r6_address));
  Dout_mem(7) <= ram(CONV_INTEGER(r7_address));


  RamProc: process(clock,wr_flag) is
  variable address_in: integer:=0;
  variable address_in_r:integer:=0;
  begin
    if rising_edge(clock) then
      	if (writeEN = '1' and pathway ='0' )then
        	ram(CONV_INTEGER(ai_mem)) <= di_mem;
        end if;
        if (writeEN = '1' and mem_ctr(0) ='1' and pathway='1')then
            ram(CONV_INTEGER(Addr_mem(0))) <= Din_mem(0);
        end if;
        if (writeEN = '1' and mem_ctr(1) ='1' and pathway='1')then
            ram(CONV_INTEGER(Addr_mem(1))) <= Din_mem(1);
        end if;
        if (writeEN = '1' and mem_ctr(2) ='1' and pathway='1')then
            ram(CONV_INTEGER(Addr_mem(2))) <= Din_mem(2);
        end if;
        if (writeEN = '1' and mem_ctr(3) ='1' and pathway='1')then
            ram(CONV_INTEGER(Addr_mem(3))) <= Din_mem(3);
        end if;
        if (writeEN = '1' and mem_ctr(4) ='1' and pathway='1')then
            ram(CONV_INTEGER(Addr_mem(4))) <= Din_mem(4);
        end if;
        if (writeEN = '1' and mem_ctr(5) ='1' and pathway='1')then
            ram(CONV_INTEGER(Addr_mem(5))) <= Din_mem(5);
        end if;
        if (writeEN = '1' and mem_ctr(6) ='1' and pathway='1')then
            ram(CONV_INTEGER(Addr_mem(6))) <= Din_mem(6);
        end if;
        if (writeEN = '1' and mem_ctr(7) ='1' and pathway='1')then
            ram(CONV_INTEGER(Addr_mem(7))) <= Din_mem(7);
        end if;
  --dataout <= "0000000000000000";
	--else
	--dataout <= ram(CONV_INTEGER(address));

	     if((load_mem = '1') and (wr_flag='1')) then

  		     --ram(address_in_r) <= in_array(address_in);
    		  --   if(address_in = 26) then
            --   mem_loaded <='1';
            --   wr_flag<='0';
            -- else
            --  mem_loaded<='0';
            --end if;
    		    --  if(address_in_r=19) then
            --    address_in_r:=256;
    		    --  else
            --    address_in_r:= address_in_r+1;
    		    --  end if;
	          --address_in:=address_in+1;
--
      --  end if;
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

end if;
  end process RamProc;



end architecture dRTL;
