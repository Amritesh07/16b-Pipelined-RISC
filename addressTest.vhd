library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use work.Types.all;

entity addressTest is
end addressTest ;
architecture test of addressTest is
signal Ain: std_logic_vector(15 downto 0);
signal Sel: std_logic_vector(7 downto 0);
signal Aout: AddressOutType;
signal loc: integer;
function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin
      ret_val := lx;
      return(ret_val);
  end to_string;


function to_string_vec(x: std_logic_vector) return string is
      variable ret_var: string(x'length-1 downto 0);
      alias lx : std_logic_vector(x'length-1 downto 0) is x;
  begin
      for I in 0 to x'length-1 loop
        if(lx(I) = '1') then
           ret_var(I) :=  '1';
        else
           ret_var(I) :=  '0';
	end if;
     end loop;
	return(ret_var);
  end to_string_vec;

function to_string_bit(x: std_logic) return character is
      variable ret_val: character;
      alias lx : std_logic is x;
  begin
	if(lx ='1') then
      		ret_val := '1';
	else
		ret_val := '0';
	end if;
      return(ret_val);
  end to_string_bit;

component AddressBlock
port (
Ain: in std_logic_vector(15 downto 0);
Sel: in std_logic_vector(7 downto 0);
Aout: out AddressOutType);
end component ;
begin
process
variable Av : std_logic_vector(15 downto 0);
variable Sv : std_logic_vector(7 downto 0);
variable fail: integer range 0 to 255;
variable success: integer range 0 to 256;
FILE OUTFILE: text  open write_mode is "out.txt";
 	variable INPUT_LINE1,INPUT_LINE2: Line;
    	variable OUTPUT_LINE: Line;
  	variable LINE_COUNT: integer := 0;
begin

for i in 0 to 255 loop
Av := std_logic_vector ( to_unsigned (i ,16) );
Sv := "10010001";
wait for 0 ns ;
Ain<=Av;
Sel<=Sv;
wait for 30 ns;
 write(OUTPUT_LINE,to_string_vec(Av));
 write(OUTPUT_LINE,to_string("   "));
 write(OUTPUT_LINE,to_string_vec(Sv));
 writeline(OUTFILE, OUTPUT_LINE);
 write(OUTPUT_LINE,to_string_vec(Aout(0)));
 writeline(OUTFILE, OUTPUT_LINE);
 write(OUTPUT_LINE,to_string_vec(Aout(1)));
 writeline(OUTFILE, OUTPUT_LINE);
 write(OUTPUT_LINE,to_string_vec(Aout(2)));
 writeline(OUTFILE, OUTPUT_LINE);
 write(OUTPUT_LINE,to_string_vec(Aout(3)));
 writeline(OUTFILE, OUTPUT_LINE);
 write(OUTPUT_LINE,to_string_vec(Aout(4)));
 writeline(OUTFILE, OUTPUT_LINE);
 write(OUTPUT_LINE,to_string_vec(Aout(5)));
 writeline(OUTFILE, OUTPUT_LINE);
 write(OUTPUT_LINE,to_string_vec(Aout(6)));
 writeline(OUTFILE, OUTPUT_LINE);
 write(OUTPUT_LINE,to_string_vec(Aout(7)));
 writeline(OUTFILE, OUTPUT_LINE);
 writeline(OUTFILE, OUTPUT_LINE);
 wait for 5 ns;
end loop ;
end process ;

dut : AddressBlock
port map ( Ain=>Ain ,
Sel=>Sel ,Aout=>Aout ) ;
end test ;
