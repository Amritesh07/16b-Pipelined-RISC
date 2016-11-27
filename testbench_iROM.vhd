library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;
library work;
use work.components.all;

entity iROM_Test is
end entity;
architecture Behave of iROM_Test is

  signal clk   :  std_logic:='0';
  signal load_mem:  std_logic;
  signal mem_loaded:  std_logic;
  signal address:  std_logic_vector(0 to 15);
  signal dataout:  std_logic_vector(15 downto 0);
  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin
      ret_val := lx;
      return(ret_val);
  end to_string;

  function to_std_logic_vector(x: bit_vector) return std_logic_vector is
    alias lx: bit_vector(x'length-1 downto 0) is x;
    variable ret_var : std_logic_vector(x'length-1 downto 0);
  begin
     for I in 0 to x'length-1 loop
        if(lx(I) = '1') then
           ret_var(I) :=  '1';
        else
           ret_var(I) :=  '0';
	end if;
     end loop;
     return(ret_var);
  end to_std_logic_vector;

  function bit_to_string(x: bit_vector) return string is
    alias lx: bit_vector(1 to x'length) is x;
    variable ret_var : string(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
           ret_var(I) :=  '1';
        else
           ret_var(I) :=  '0';
	end if;
     end loop;
     return(ret_var);
  end bit_to_string;

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

function to_std_logic(x: bit) return std_logic is

    variable ret_var : std_logic;
    alias lx: bit is x;
  begin
        if(lx = '1') then
           ret_var :=  '1';
        else
           ret_var :=  '0';
  end if;
     return(ret_var);
  end to_std_logic;

begin

 clk <= not clk after 50 ns; -- assume 10ns clock.
  process
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "TRACEFILE_iROM.txt";
    FILE OUTFILE: text  open write_mode is "OUTPUTS_iROM.txt";

    ---------------------------------------------------
    -- edit the next few lines to customize


    variable load_mem_var: bit;
    variable address_var:  bit_vector(15 downto 0);


    ----------------------------------------------------
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;

  begin


  --wait until clk = '1';
    while not endfile(INFILE) loop
    	  report "it starts";

    LINE_COUNT := LINE_COUNT + 1;
	  readLine (INFILE, INPUT_LINE);
	        read (INPUT_LINE, load_mem_var);
          read (INPUT_LINE, address_var);
            --------------------------------------
          -- from input-vector to DUT inputs
	  load_mem <= to_std_logic(load_mem_var);
    address <= to_std_logic_vector(address_var);
	 wait until clk = '0';
          --------------------------------------
	     while (true) loop
          if(load_mem='1') then wait until mem_loaded='1';
        else
             wait until clk='1';
           end if;

		report "NOT HERE";
		--if(done='1') then
			exit;
		--end if;
    end loop;

               write(OUTPUT_LINE,to_string("Data Output: "));
		           write(OUTPUT_LINE,to_string_vec(dataout));

             writeline(OUTFILE, OUTPUT_LINE);
             err_flag := true;

          --------------------------------------
    end loop;

    assert (err_flag) report "SUCCESS, all tests passed." severity note;
    assert (not err_flag) report "FAILURE, some tests failed." severity error;

    wait;
  end process;

  dut:iROM port map (
  clock=> clk,
  load_mem=>load_mem,
  mem_loaded=>mem_loaded,
  address=>address,
  dataout=>dataout
	);

end Behave;
