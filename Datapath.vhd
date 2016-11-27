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

	component HazardUnit is
	port (
	------------------------
	lw_out: in std_logic_vector(15 downto 0);
	lm_out: in std_logic_vector(15 downto 0);
	aluop: in std_logic_vector(15 downto 0);
	JLRreg:in std_logic_vector(15 downto 0);
	Pc_Im6:in std_logic_vector(15 downto 0);
	Pc_Im9:in std_logic_vector(15 downto 0);
	padder:in std_logic_vector(15 downto 0);
	-------------
	stallflag: in std_logic;
	Instruction_pipeline: in matrix16(0 to 4); --  0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
	carry_ex: in std_logic;
	zero_ex: in std_logic;
	regDest: in matrix3(0 to 4);               --0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
	Lm_sel_r7: in std_logic;
	BEQequal: in std_logic;
	PCplus1 : in std_logic_vector(15 downto 0);
	Instr_out: out matrix16(0 to 4);
	pipeline_enable: out std_logic_vector(0 to 4);  --  0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
	PC_write_en: out std_logic;
	PCval: out std_logic_vector(15 downto 0)
	         ) ;
	end component ;
--==================BEGIN====================
signal null16: std_logic_vector(15 downto 0):="0000000000000000";
-- pipeline related signals
signal IF_ID_in_sig, IF_ID_out_sig: IF_ID_type;
signal ID_RR_in_sig, ID_RR_out_sig: ID_RR_type;
signal RR_EX_in_sig, RR_EX_out_sig: RR_EX_type;
signal EX_MEM_in_sig, EX_MEM_out_sig : EX_MEM_type;
signal MEM_WB_in_sig, MEM_WB_out_sig : MEM_WB_type;
-- Hazard Unit signals
signal PC_val_sig: std_logic_vector(15 downto 0);
signal pipeline_enable_sig: std_logic_vector(0 to 4);
signal PC_write_en_sig: std_logic;
signal Instruction_pipeline_sig, Instr_out_sig: matrix16(0 to 4);
-- Multiplexer related signals
signal M1_out_sig, M3_out_sig, M4_out_sig, M5_out_sig, M6_out_sig, M7_out_sig, M9_out_sig,: std_logic_vector(15 downto 0);
signal M1_sel_sig: std_logic;
-- Miscellaneous signals
signal SE9_out: std_logic_vector(15 dowto 0);
signal isEqualFlag, LW_zero: std_logic;
begin
----------- Pipeline Register
IF_ID : IF_ID_reg port map(Din => IF_ID_in_sig, Dout => IF_ID_out_sig, clk => clk, enable => pipeline_enable_sig(0));
ID_RR : ID_RR_reg port map(Din => ID_RR_in_sig, Dout => ID_RR_out_sig, clk => clk, enable => pipeline_enable_sig(1));
RR_EX : RR_EX_reg port map(Din => RR_EX_in_sig, Dout => RR_EX_out_sig, clk => clk, enable => pipeline_enable_sig(2));
EX_MEM : EX_MEM_reg port map(Din => EX_MEM_in_sig, Dout => EX_MEM_out_sig, clk => clk, enable => pipeline_enable_sig(3));
MEM_WB : MEM_WB_reg port map(Din => MEM_WB_in_sig, Dout => MEM_WB_out_sig, clk => clk, enable => pipeline_enable_sig(4));

Instruction_pipeline_sig(0) <= IF_ID_out_sig.I16;
ID_RR_in_sig.I16 <= Instr_out_sig(1);

Instruction_pipeline_sig(1) <= ID_RR_out_sig.I16;
RR_EX_in_sig.SE6 <= ID_RR_out_sig.SE6;
RR_EX_in_sig.Padder <= ID_RR_out_sig.Padder;
RR_EX_in_sig.PC_1 <= ID_RR_out_sig.PC_1;
RR_EX_in_sig.RF <= ID_RR_out_sig.RF;
RR_EX_in_sig.DRAM <= ID_RR_out_sig.DRAM;
RR_EX_in_sig.ALUsel <= ID_RR_out_sig.ALUsel;
RR_EX_in_sig.M6_sel <= ID_RR_out_sig.M6_sel;
RR_EX_in_sig.M7_sel <= ID_RR_out_sig.M7_sel;
RR_EX_in_sig.M3_sel <= ID_RR_out_sig.M3_sel;
RR_EX_in_sig.I16 <= Instr_out_sig(2);


Instruction_pipeline_sig(2) <= RR_EX_out_sig.I16;
EX_MEM_in_sig.PC_1 <= RR_EX_out_sig.PC_1;
EX_MEM_in_sig.Padder <= RR_EX_out_sig.Padder;
EX_MEM_in_sig.ALU_OUT <= RR_EX_out_sig.ALU_OUT;
EX_MEM_in_sig.D1 <= RR_EX_out_sig.D1;
EX_MEM_in_sig.RF <= RR_EX_out_sig.RF;
EX_MEM_in_sig.DRAM <= RR_EX_out_sig.DRAM;
EX_MEM_in_sig.D_multiple <= RR_EX_out_sig.D_multiple;
EX_MEM_in_sig.M3_sel <= RR_EX_out_sig.M3_sel;
EX_MEM_in_sig.I16 <= Instr_out_sig(3);

Instruction_pipeline_sig(3) <= EX_MEM_out_sig.I16;
MEM_WB_in_sig.PC_1 <= EX_MEM_out_sig.PC_1;
MEM_WB_in_sig.Padder <= EX_MEM_out_sig.Padder;
MEM_WB_in_sig.ALU_OUT <= EX_MEM_out_sig.ALU_OUT;
MEM_WB_in_sig.RF <= EX_MEM_out_sig.RF;
MEM_WB_in_sig.M3_sel <= EX_MEM_out_sig.M3_sel;
MEM_in_sig.I16 <= Instr_out_sig(4);

---------------------------


PC_PROXY: DataRegister generic map(data_width=16) port map(Din=> PC_val_sig, Dout=> IF_ID_in_sig.PC, clk=> clk, enable=> PC_write_en_sig);

RF : Regfile port map();
FLogic: FwdCntrl port map(padder(0) => RR_EX_out_sig.Padder, padder(1) => EX_MEM_out_sig.Padder, padder(2) => MEM_WB_out_sig.Padder,
													PC_1(0) => RR_EX_out_sig.PC_1, PC_1(1) => EX_MEM_out_sig.PC_1, PC_1(2)) => MEM_WB_out_sig.PC_1,
													aluop(0) => EX_MEM_in_sig.ALU_OUT, aluop(1) => EX_MEM_out_sig.PC_1, aluop(2)) => MEM_WB_out_sig.PC_1,
													);
ALU0 : ALU port map(I1 => M6_out_sig, I2 => M7_out_sig, Sel => RR_EX_out_sig.ALUsel, C => EX_MEM_in_sig.C_new, Z => EX_MEM_in_sig.Z_new);

DataMem: DRAM port map(clock => clk, mem_ctr => EX_MEM_out_sig.DRAM.mem_ctr, Din_mem => EX_MEM_out_sig.D_multiple, Dout_mem => MEM_WB_in_sig.D_multiple
												Addr_mem => EX_MEM_out_sig.A_multiple, pathway => EX_MEM_out_sig.DRAM.pathway, );
InstMem: IRAM port map(dataout=>IF_ID.);

AddrBlock : AddressBlock port map(Ain => RR_EX_out_sig.D1, Sel => RR_EX_out_sig.DRAM.mem_ctr, Aout => EX_MEM_in_sig.A_multiple);

isEqu: isEqual port map(I1 => M4_out_sig, I2 => M5_out_sig, O =>isEqualFlag);
isNull: isEqual port map(I1=>, I2=>null16, O => LW_zero);
Add1 : Add_1 port map(I => PC_sig, O => IF_ID_in_sig.PC_1);

------------------------------ we need to re look at the mux select encodings ---------------------
M1: GenericMux generic map(seln = 1) port map(I(0) => SE9_out, I(1) => ID_RR_in_sig.SE6, S => M1_sel_sig, O => M1_out_sig);
M3: GenericMux generic map(seln = 2) port map(I(0) => MEM_WB_out_sig.Padder, I(1) => MEM_WB_out_sig.ALU_OUT, I(2) => MEM_WB_out_sig.mem_out, I(3) => MEM_WB_out_sig.PC_1, S => MEM_WB_out_sig.M3_sel, O => M3_out_sig);
M4: GenericMux generic map(seln = 3) port map(I => RR_EX_in_sig.D_multiple, S => ID_RR_out_sig.A1, O => RR_EX_in_sig.D1);
M5: GenericMux generic map(seln = 3) port map(I => RR_EX_in_sig.D_multiple, S => ID_RR_out_sig.A2, O => RR_EX_in_sig.D2);
M6: GenericMux generic map(seln = 1) port map(I(0) => RR_EX_out_sig.D1, I(1) => RR_EX_out_sig.SE6, S => RR_EX_out_sig.M6_sel, O => M6_out_sig);
M7: GenericMux generic map(seln = 1) port map(I(0) => RR_EX_out_sig.D2, I(1) => RR_EX_out_sig.SE6, S => RR_EX_out_sig.M7_sel, O => M7_out_sig);


Adder1: Adder port map(I1 => IF_ID_out_sig.PC, I2 => M1_out_sig, O => ID_RR_in_sig.PC_Imm6);

DEC: InstructionDecoder port map();
SE6: SignExtend_6 port map(IN_6 => IF_ID_out_sig.I16(5 downto 0), OUT_16 => ID_RR_in_sig.SE6);
SE9: signExtend_9 port map(IN_9 => IF_ID_out_sig.I16(8 downto 0), OUT_16 => SE9_out);
Pad: Padder port map(I => IF_ID_out_sig.I16(8 downto 0), O => ID_RR_in_sig.Padder);
CarryReg: DataRegister generic map(data_width = 1) port map();
ZeroReg: DataRegister generic map(data_width = 1) port map();

Hazard_Mitigation_Unit: HazardUnit

end arch;
