library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.components.all;
entity AddressBlock is
port(

	Ain: in std_logic_vector(15 downto 0);
	Sel: in std_logic_vector(7 downto 0);
	Aout: out matrix16(7 downto 0));
end entity AddressBlock;


architecture arch of AddressBlock is
	signal AoutTemp: matrix16(7 downto 0);

begin
	process(Ain,Sel)
	variable temp_var: std_logic_vector(15 downto 0);
	begin

		if(Sel(0)='1') then AoutTemp(0)<=Ain;	temp_var :=std_logic_vector(unsigned(Ain)+1); else		AoutTemp(0)<=Ain; temp_var:=Ain; end if;
		if(Sel(1)='1') then AoutTemp(1)<=temp_var; temp_var:=std_logic_vector(unsigned(temp_var)+1); 	else	AoutTemp(1)<=temp_var; end if;
		if(Sel(2)='1') then AoutTemp(2)<=temp_var; temp_var:=std_logic_vector(unsigned(temp_var)+1); 	else	AoutTemp(2)<=temp_var; end if;
		if(Sel(3)='1') then AoutTemp(3)<=temp_var; temp_var:=std_logic_vector(unsigned(temp_var)+1); 	else	AoutTemp(3)<=temp_var; end if;
		if(Sel(4)='1') then AoutTemp(4)<=temp_var; temp_var:=std_logic_vector(unsigned(temp_var)+1); 	else	AoutTemp(4)<=temp_var; end if;
		if(Sel(5)='1') then AoutTemp(5)<=temp_var; temp_var:=std_logic_vector(unsigned(temp_var)+1); 	else	AoutTemp(5)<=temp_var; end if;
		if(Sel(6)='1') then AoutTemp(6)<=temp_var; temp_var:=std_logic_vector(unsigned(temp_var)+1); 	else	AoutTemp(6)<=temp_var; end if;
	  AoutTemp(7)<=temp_var;


	end process;
Aout<=AoutTemp;
end arch;
