library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;


entity regFileTest is
end entity;
architecture Behave of regFileTest is

  done : out std_logic;
	clk : in std_logic;
	logic_in : in std_logic_vector(7 downto 0);
	di0rf  : in std_logic_vector(15 downto 0);
	di1rf  : in std_logic_vector(15 downto 0);
	di2rf  : in std_logic_vector(15 downto 0);
	di3rf  : in std_logic_vector(15 downto 0);
	di4rf  : in std_logic_vector(15 downto 0);
	di5rf	 : in std_logic_vector(15 downto 0);
	di6rf  : in std_logic_vector(15 downto 0);
	di7rf  : in std_logic_vector(15 downto 0);

	do0rf  : out std_logic_vector(15 downto 0);
	do1rf  : out std_logic_vector(15 downto 0);
	do2rf  : out std_logic_vector(15 downto 0);
	do3rf  : out std_logic_vector(15 downto 0);
	do4rf  : out std_logic_vector(15 downto 0);
	do5rf  : out std_logic_vector(15 downto 0);
	do6rf  : out std_logic_vector(15 downto 0);
	do7rf  : out std_logic_vector(15 downto 0);

	a1rf : in std_logic_vector(2 downto 0);
	a2rf : in std_logic_vector(2 downto 0);
	d1rf : out std_logic_vector(15 downto 0);
	d2rf : out std_logic_vector(15 downto 0);
	a3rf : in std_logic_vector(2 downto 0);
	d3rf : in std_logic_vector(15 downto 0);
	d4rf : in std_logic_vector(15 downto 0);
	path_decider : in std_logic;
	rf_write: in std_logic;
	pc_write : in std_logic


  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin
      ret_val := lx;
      return(ret_val);
  end to_string;

  function to_std_logic_vector(x: bit_vector) return std_logic_vector is
    alias lx: bit_vector(x'length-1 downto 0) is x;done : out std_logic;

  	clk : std_logic:='0';
  	logic_in : std_logic_vector(7 downto 0);
  	di0rf  : std_logic_vector(15 downto 0);
  	di1rf  :  std_logic_vector(15 downto 0);
  	di2rf  :  std_logic_vector(15 downto 0);
  	di3rf  :  std_logic_vector(15 downto 0);
  	di4rf  :  std_logic_vector(15 downto 0);
  	di5rf	 :  std_logic_vector(15 downto 0);
  	di6rf  :  std_logic_vector(15 downto 0);
  	di7rf  :  std_logic_vector(15 downto 0);

  	do0rf  :  std_logic_vector(15 downto 0);
  	do1rf  :  std_logic_vector(15 downto 0);
  	do2rf  :  std_logic_vector(15 downto 0);
  	do3rf  :  std_logic_vector(15 downto 0);
  	do4rf  :  std_logic_vector(15 downto 0);
  	do5rf  :  std_logic_vector(15 downto 0);
  	do6rf  :  std_logic_vector(15 downto 0);
  	do7rf  :  std_logic_vector(15 downto 0);

  	a1rf :  std_logic_vector(2 downto 0);
  	a2rf :  std_logic_vector(2 downto 0);
  	d1rf :  std_logic_vector(15 downto 0);
  	d2rf :  std_logic_vector(15 downto 0);
  	a3rf :  std_logic_vector(2 downto 0);
  	d3rf :  std_logic_vector(15 downto 0);
  	d4rf :  std_logic_vector(15 downto 0);
  	path_decider :  std_logic;
  	rf_write:  std_logic;
  	pc_write :  std_logic

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
  end bit_to_String;

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

component regfile
port(
done : out std_logic;
clk : in std_logic;
logic_in : in std_logic_vector(7 downto 0);
di0rf  : in std_logic_vector(15 downto 0);
di1rf  : in std_logic_vector(15 downto 0);
di2rf  : in std_logic_vector(15 downto 0);
di3rf  : in std_logic_vector(15 downto 0);
di4rf  : in std_logic_vector(15 downto 0);
di5rf	 : in std_logic_vector(15 downto 0);
di6rf  : in std_logic_vector(15 downto 0);
di7rf  : in std_logic_vector(15 downto 0);

do0rf  : out std_logic_vector(15 downto 0);
do1rf  : out std_logic_vector(15 downto 0);
do2rf  : out std_logic_vector(15 downto 0);
do3rf  : out std_logic_vector(15 downto 0);
do4rf  : out std_logic_vector(15 downto 0);
do5rf  : out std_logic_vector(15 downto 0);
do6rf  : out std_logic_vector(15 downto 0);
do7rf  : out std_logic_vector(15 downto 0);

a1rf : in std_logic_vector(2 downto 0);
a2rf : in std_logic_vector(2 downto 0);
d1rf : out std_logic_vector(15 downto 0);
d2rf : out std_logic_vector(15 downto 0);
a3rf : in std_logic_vector(2 downto 0);
d3rf : in std_logic_vector(15 downto 0);
d4rf : in std_logic_vector(15 downto 0);
path_decider : in std_logic;
rf_write: in std_logic;
pc_write : in std_logic
  );
end component;

begin

 clk <= not clk after 50 ns; -- assume 10ns clock.
  process
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "TRACEFILE_RF.txt";
    FILE OUTFILE: text  open write_mode is "OUTPUTS.txt";

    ---------------------------------------------------
    -- edit the next few lines to customize
  variable logic_in_var : bit_vector(7 downto 0);
	variable di0rf_var  : bit_vector(15 downto 0);
	variable di1rf_var  : bit_vector(15 downto 0);
	variable di2rf_var  : bit_vector(15 downto 0);
	variable di3rf_var  : bit_vector(15 downto 0);
	variable di4rf_var  : bit_vector(15 downto 0);
	variable di5rf_var  : bit_vector(15 downto 0);
	variable di6rf_var  : bit_vector(15 downto 0);
	variable di7rf_var  : bit_vector(15 downto 0);

  variable do0rf_var  : std_logic_vector(15 downto 0);
	variable do1rf_var  :  std_logic_vector(15 downto 0);
	variable do2rf_var  :  std_logic_vector(15 downto 0);
	variable do3rf_var  :  std_logic_vector(15 downto 0);
	variable do4rf_var  :  std_logic_vector(15 downto 0);
	variable do5rf_var  :  std_logic_vector(15 downto 0);
	variable do6rf_var  :  std_logic_vector(15 downto 0);
	variable do7rf_var  :  std_logic_vector(15 downto 0);

	variable a1rf_var :  std_logic_vector(2 downto 0);
	variable a2rf_var :  std_logic_vector(2 downto 0);
	variable d1rf_var :  std_logic_vector(15 downto 0);
	variable d2rf_var :  std_logic_vector(15 downto 0);
	variable a3rf_var :  std_logic_vector(2 downto 0);
	variable d3rf_var :  std_logic_vector(15 downto 0);
	variable d4rf : std_logic_vector(15 downto 0);
  variable ctr_var: std_logic_vector(2 downto 0);
    ----------------------------------------------------
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;

  begin
	report "it starts";
  wait until clk = '1';
	report "ENTERING FILE READ LOOP";
    while not endfile(INFILE) loop

	wait until clk = '0';
          LINE_COUNT := LINE_COUNT + 1;

	  readLine (INFILE, INPUT_LINE);
    read (INPUT_LINE, ctr_var);
    read (INPUT_LINE, logic_in_var);
    read (INPUT_LINE, a1rf_var);
	  read (INPUT_LINE, a2rf_var);
	  read (INPUT_LINE, a3rf_var);
	  read (INPUT_LINE, d1rf_var);
	  read (INPUT_LINE, d2rf_var);
	  read (INPUT_LINE, d3rf_var);
	  read (INPUT_LINE, d4rf_var);
    read (INPUT_LINE, di0rf_var);
    read (INPUT_LINE, di1rf_var);
    read (INPUT_LINE, di2rf_var);
    read (INPUT_LINE, di3rf_var);
    read (INPUT_LINE, di4rf_var);
    read (INPUT_LINE, di5rf_var);
    read (INPUT_LINE, di6rf_var);
    read (INPUT_LINE, di7rf_var);

          --------------------------------------
          -- from input-vector to DUT inputs

	  write_ctr <= to_std_logic_vector(ctr_var1);
	  a1rf <= to_std_logic_vector(a1rf_var);
    a2rf <= to_std_logic_vector(a2rf_var);
	  a3rf <= to_std_logic_vector(a3rf_var);
	  d3rf <= to_std_logic_vector(d3rf_var);
	  d4rf <= to_std_logic_vector(d4rf_var);
    di0rf <= to_std_logic_vector(di0rf_var);
    di1rf <= to_std_logic_vector(di1rf_var);
    di2rf <= to_std_logic_vector(di2rf_var);
    di3rf <= to_std_logic_vector(di3rf_var);
    di4rf <= to_std_logic_vector(di4rf_var);
    di5rf <= to_std_logic_vector(di5rf_var);
    di6rf <= to_std_logic_vector(di6rf_var);
    di7rf <= to_std_logic_vector(di7rf_var);
          --------------------------------------
	     while (true) loop
             wait until clk='1';
		report "not_done";
		if(done='1') then
			exit;
		end if;
             end loop;
	--wait for 5 ns;
	report "NEW INPUT READ";
             write(OUTPUT_LINE,to_string("D1RF: "));
		write(OUTPUT_LINE,to_string_vec(d1rf));

         write(OUTPUT_LINE,to_string("  D2RF: "));
		write(OUTPUT_LINE,to_string_vec(d2rf));

          write(OUTPUT_LINE,to_string("    D5RF: "));
		write(OUTPUT_LINE,to_string_vec(d5rf));


             writeline(OUTFILE, OUTPUT_LINE);
             err_flag := true;

          --------------------------------------
    end loop;

    assert (err_flag) report "SUCCESS, all tests passed." severity note;
    assert (not err_flag) report "FAILURE, some tests failed." severity error;

    wait;
  end process;

  dut: regfile
     port map(
     done=> done,
   	clk=> clk,
   	logic_in=> logic_in,
   	di0rf  => di0rf,
   	di1rf  => di1rf,
   	di2rf  => di2rf,
   	di3rf  => di3rf,
   	di4rf  => di4rf,
   	di5rf	 => di5rf,
   	di6rf  => di6rf,
   	di7rf  => di7rf,
   	do0rf  => do0rf,
   	do1rf  => do1rf,
   	do2rf  => do2rf,
   	do3rf  => do3rf,
   	do4rf  => do4rf,
   	do5rf  => do5rf,
   	do6rf  => do6rf,
   	do7rf  => do7rf,
   	a1rf => a1rf,
   	a2rf => a2rf,
   	d1rf => d1rf,
   	d2rf => d2rf,
   	a3rf => a3rf,
   	d3rf => d3rf,
   	d4rf => d4rf,
   	path_decider => path_decider,
    rf_write=> rf_write,
   	pc_write=> pc_write

);

end Behave;
