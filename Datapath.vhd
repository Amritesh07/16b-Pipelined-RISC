library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.components.all;

entity Datapath is
port(clk: in std_logic
	);
end Datapath;

architecture arch of Datapath is
--==================BEGIN====================
signal null16: std_logic_vector(15 downto 0):="0000000000000000";
begin
-- Pipeline Register
IF_ID : DataRegister generic map(data_width=100) port map(Din(0 to 15));
ID_RR : DataRegister generic map(data_width=100) port map();
RR_EX : DataRegister generic map(data_width=100) port map();
EX_MEM : DataRegister generic map(data_width=100) port map();
MEM_WB : DataRegister generic map(data_width=100) port map();

RF : Regfile port map();
FLogic: FwdCntrl port map();
ALU0 : ALU port map();

DataMem: DRAM port map();
InstMem: IRAM port map();

AddrBlock : AddressBlock port map();

isEqu: isEqual port map();
isNull: isEqual port map(I1=>, I2=>null16);
Add1 : Add_1 port map();


M1: GenericMux generic map(seln = 1) port map();
M2: GenericMux generic map(seln = 1) port map();
M3: GenericMux generic map(seln = 1) port map();
M4: GenericMux generic map(seln = 1) port map();
M5: GenericMux generic map(seln = 1) port map();
M6: GenericMux generic map(seln = 1) port map();
M7: GenericMux generic map(seln = 1) port map();
M8: GenericMux generic map(seln = 1) port map();
M9: GenericMux generic map(seln = 1) port map();

Adder1: Adder port map();


DEC: InstructionDecoder port map();
SE6: SignExtend_6 port map();
SE9: signExtend_9 port map();
Pad: Padder port map();
CarryReg: DataRegister generic map(data_width = 1) port map();
ZeroReg: DataRegister generic map(data_width = 1) port map();


end arch;
