library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;
use work.components.all;

entity regFileTest is
end entity;
architecture Behave of regFileTest is

  signal clk,done : std_logic:='0';
  signal logic_in : std_logic_vector(7 downto 0);
  signal Din_rf:  DataInOutType;
  signal Dout_rf:  DataInOutType;
  signal a3rf :  std_logic_vector(2 downto 0);
  signal d3rf :  std_logic_vector(15 downto 0);
  signal d4rf :  std_logic_vector(15 downto 0);
  signal path_decider :  std_logic;
  signal rf_write:  std_logic;
  signal pc_write :  std_logic;

  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin
      ret_val := lx;
      return(ret_val);
  end to_string;

  function to_std_logic_vector(x: bit_vector) return std_logic_vector is

    variable ret_var : std_logic_vector(x'length-1 downto 0);
    alias lx: bit_vector(x'length-1 downto 0) is x;
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

  variable do0rf_var  : bit_vector(15 downto 0);
	variable do1rf_var  :  bit_vector(15 downto 0);
	variable do2rf_var  :  bit_vector(15 downto 0);
	variable do3rf_var  :  bit_vector(15 downto 0);
	variable do4rf_var  :  bit_vector(15 downto 0);
	variable do5rf_var  :  bit_vector(15 downto 0);
	variable do6rf_var  :  bit_vector(15 downto 0);
	variable do7rf_var  :  bit_vector(15 downto 0);

	variable a3rf_var :  bit_vector(2 downto 0);
	variable d3rf_var :  bit_vector(15 downto 0);
	variable d4rf_var : bit_vector(15 downto 0);
  variable ctr_var: bit_vector(2 downto 0);
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
	  read (INPUT_LINE, a3rf_var);
	  read (INPUT_LINE, d3rf_var);
	  read (INPUT_LINE, d4rf_var);
    LINE_COUNT := LINE_COUNT + 1;
    readLine (INFILE, INPUT_LINE);
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


	  a3rf <= to_std_logic_vector(a3rf_var);
	  d3rf <= to_std_logic_vector(d3rf_var);
	  d4rf <= to_std_logic_vector(d4rf_var);
    Din_rf(0) <= to_std_logic_vector(di0rf_var);
    Din_rf(1) <= to_std_logic_vector(di1rf_var);
    Din_rf(2) <= to_std_logic_vector(di2rf_var);
    Din_rf(3) <= to_std_logic_vector(di3rf_var);
    Din_rf(4) <= to_std_logic_vector(di4rf_var);
    Din_rf(5) <= to_std_logic_vector(di5rf_var);
    Din_rf(6) <= to_std_logic_vector(di6rf_var);
    Din_rf(7) <= to_std_logic_vector(di7rf_var);
    path_decider<=to_std_logic(ctr_var(2));
    rf_write<=to_std_logic(ctr_var(1));
    pc_write<=to_std_logic(ctr_var(0));
    logic_in<=to_std_logic_vector(logic_in_var);
          --------------------------------------
	     while (true) loop
             wait until clk='1';
		           report "not_done";
		             if(done='1') then
			                exit;
		                  end if;
        end loop;
	--wait for 5 ns;
  write(OUTPUT_LINE,to_string("D0RF: "));
   write(OUTPUT_LINE,to_string_vec(Dout_rf(0)));

   write(OUTPUT_LINE,to_string(" D1RF: "));
    write(OUTPUT_LINE,to_string_vec(Dout_rf(1)));

    write(OUTPUT_LINE,to_string(" D2RF: "));
     write(OUTPUT_LINE,to_string_vec(Dout_rf(2)));

     write(OUTPUT_LINE,to_string(" D3RF: "));
      write(OUTPUT_LINE,to_string_vec(Dout_rf(3)));

      write(OUTPUT_LINE,to_string(" D4RF: "));
       write(OUTPUT_LINE,to_string_vec(Dout_rf(4)));

       write(OUTPUT_LINE,to_string(" D5RF: "));
        write(OUTPUT_LINE,to_string_vec(Dout_rf(5)));

        write(OUTPUT_LINE,to_string(" D6RF: "));
         write(OUTPUT_LINE,to_string_vec(Dout_rf(6)));

         write(OUTPUT_LINE,to_string(" D7RF: "));
          write(OUTPUT_LINE,to_string_vec(Dout_rf(7)));



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
     done => done,
     clk => clk,
     logic_in => logic_in,
     Din_rf => Din_rf,
     Dout_rf=> Dout_rf,
     a3rf=>a3rf,
     d3rf=>d3rf,
     d4rf=>d4rf,
     path_decider=>path_decider,
     rf_write=>rf_write,
     pc_write=>pc_write

);

end Behave;
