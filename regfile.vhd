LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.components.all;

ENTITY regfile is port(
	done : out std_logic;
	clk : in std_logic;
	logic_in : in std_logic_vector(7 downto 0);
	Din_rf: in DataInOutType;
	Dout_rf: out DataInOutType;
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

	Dout_rf(7)<=RF(7);
	Dout_rf(6)<=RF(6);
	Dout_rf(5)<=RF(5);
	Dout_rf(4)<=RF(4);
	Dout_rf(3)<=RF(3);
	Dout_rf(2)<=RF(2);
	Dout_rf(1)<=RF(1);
	Dout_rf(0)<=RF(0);

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

		if((logic_in(0)='1') and (path_decider='1') and (rf_write='1')) THEN
		RF(0) <= Din_rf(0);
		end if;

		if((logic_in(1)='1') and (path_decider='1')and (rf_write='1')) THEN
		RF(1) <= Din_rf(1);
		end if;

		if((logic_in(2)='1') and (path_decider='1') and (rf_write='1')) THEN
		RF(2) <= Din_rf(2);
		end if;

		if((logic_in(3)='1') and (path_decider='1') and (rf_write='1')) THEN
		RF(3) <= Din_rf(3);
		end if;

		if((logic_in(4)='1') and (path_decider='1') and (rf_write='1')) THEN
		RF(4) <= Din_rf(4);
		end if;

		if((logic_in(5)='1') and (path_decider='1') and (rf_write='1')) THEN
		RF(5) <= Din_rf(5);
		end if;

		if((logic_in(6)='1') and (path_decider='1') and (rf_write='1')) THEN
		RF(6) <= Din_rf(6);
		end if;

		if((logic_in(7)='1') and (path_decider='1') and (rf_write='1')) THEN
		RF(7) <= Din_rf(7);
		end if;

	end if;
	done_1<='1';
	end process;


	done <= done_1;
end Behavorial;
