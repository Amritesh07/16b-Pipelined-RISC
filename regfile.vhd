LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY regfile is port(
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


	a3rf : in std_logic_vector(2 downto 0);
	d3rf : in std_logic_vector(15 downto 0);
	d4rf : in std_logic_vector(15 downto 0);
	path_decider : in std_logic;
	rf_write: in std_logic;
	pc_write : in std_logic

	);
end regfile;

ARCHITECTURE Behavorial of regfile IS
	type registerFile is array(0 to 7) of std_logic_vector(15 downto 0);
	SIGNAL RF:registerFile:= (others=>(others => '0'));
	SIGNAL done_1:std_logic := '0';

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
BEGIN

	do7rf <= RF(7);
	do6rf <= RF(6);
	do5rf <= RF(5);
	do4rf <= RF(4);
	do3rf <= RF(3);
	do2rf <= RF(2);
	do1rf <= RF(1);
	do0rf <= RF(0);

	RF_PC_Write:Process(clk)
	BEGIN
	done_1 <= '0';
	if(clk'EVENT and clk = '1') THEN
		if((path_decider='0') and (rf_write='1')) THEN
			RF(CONV_INTEGER(a3rf)) <= d3rf;
		--report "yo1";
		end if;

		if((path_decider='0') and (pc_write= '1')) THEN
			RF(7) <= d4rf;
		--report "yo2";
		end if;

		if((logic_in(0)='1') and (path_decider='1')) THEN
		RF(0) <= di0rf;
		end if;

		if((logic_in(1)='1') and (path_decider='1')) THEN
		RF(1) <= di1rf;
		end if;

		if((logic_in(2)='1') and (path_decider='1')) THEN
		RF(2) <= di2rf;
		end if;

		if((logic_in(3)='1') and (path_decider='1')) THEN
		RF(3) <= di3rf;
		end if;

		if((logic_in(4)='1') and (path_decider='1')) THEN
		RF(4) <= di4rf;
		end if;

		if((logic_in(5)='1') and (path_decider='1')) THEN
		RF(5) <= di5rf;
		end if;

		if((logic_in(6)='1') and (path_decider='1')) THEN
		RF(6) <= di6rf;
		end if;

		if((logic_in(7)='1') and (path_decider='1')) THEN
		RF(7) <= di7rf;
		end if;

	end if;
	done_1<='1';
	end process;


	done <= done_1;
end Behavorial;
