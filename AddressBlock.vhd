library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Package Types is
	type AddressOutType is array(0 to 7) of std_logic_vector(15 downto 0);
end Types;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;
entity AddressBlock is 
port(
	
	Ain: in std_logic_vector(15 downto 0);
	Sel: in std_logic_vector(7 downto 0);
	Aout: out AddressOutType);
end entity AddressBlock;


architecture arch of AddressBlock is
	signal AoutTemp: AddressOutType;
begin
	process(Ain,Sel,AoutTemp)
	begin
		if(Sel(0)='1') then AoutTemp(0)<=std_logic_vector(unsigned(Ain)+1);	else		AoutTemp(0)<=Ain; end if;
		if(Sel(1)='1') then AoutTemp(1)<=std_logic_vector(unsigned(AoutTemp(0))+1);	else		AoutTemp(1)<=AoutTemp(0); end if;
		if(Sel(2)='1') then AoutTemp(2)<=std_logic_vector(unsigned(AoutTemp(1))+1);	else		AoutTemp(2)<=AoutTemp(1); end if;
		if(Sel(3)='1') then	AoutTemp(3)<=std_logic_vector(unsigned(AoutTemp(2))+1);	else		AoutTemp(3)<=AoutTemp(2); end if;
		if(Sel(4)='1') then	AoutTemp(4)<=std_logic_vector(unsigned(AoutTemp(3))+1);	else		AoutTemp(4)<=AoutTemp(3); end if;
		if(Sel(5)='1') then	AoutTemp(5)<=std_logic_vector(unsigned(AoutTemp(4))+1);	else		AoutTemp(5)<=AoutTemp(4); end if;
		if(Sel(6)='1') then	AoutTemp(6)<=std_logic_vector(unsigned(AoutTemp(5))+1);	else		AoutTemp(6)<=AoutTemp(5); end if;
		if(Sel(7)='1') then	AoutTemp(7)<=std_logic_vector(unsigned(AoutTemp(6))+1);	else		AoutTemp(7)<=AoutTemp(6); end if;
		Aout<=AoutTemp;
	end process;
end arch;