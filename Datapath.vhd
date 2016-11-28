library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.components.all;


entity Datapath is
port(clk: in std_logic;
	mem_ctr_out: out std_logic_vector(7 downto 0);
	din_mem_out: out matrix16(7 downto 0);
	dout_mem_in: in matrix16(7 downto 0);
	dram_addr_mem: out matrix16(7 downto 0);
	dram_pathway: out std_logic;
	dram_writeEN:out std_logic;
	dram_mem_loaded:in std_logic;
	dram_ai_mem:out std_logic_vector(15 downto 0);
	dram_di_mem:out std_logic_vector(15 downto 0);
	dram_do_mem:in std_logic_vector(15 downto 0);
	irom_mem_loaded:in std_logic;
	irom_address:out std_logic_vector(15 downto 0);
	irom_dataout:in std_logic_vector(15 downto 0)

	);
end Datapath;

architecture arch of Datapath is
--==================BEGIN====================
constant CZ_zero: std_logic_vector(1 downto 0):= "01";
constant CZ_carry: std_logic_vector(1 downto 0):= "10";
constant CZ_none : std_logic_vector(1 downto 0):= "00";
constant OP_AD:  Std_Logic_Vector(3 downto 0) := "0000";
constant OP_ADI: Std_Logic_Vector(3 downto 0) := "0001";
constant OP_ND:  Std_Logic_Vector(3 downto 0) := "0010";
constant OP_LHI: Std_Logic_Vector(3 downto 0) := "0011";
constant OP_LW:  Std_Logic_Vector(3 downto 0) := "0100";
constant OP_SW:  Std_Logic_Vector(3 downto 0) := "0101";
constant OP_LM:  Std_Logic_Vector(3 downto 0) := "0110";
constant OP_SM:  Std_Logic_Vector(3 downto 0) := "0111";
constant OP_BEQ: Std_Logic_Vector(3 downto 0) := "1100";
constant OP_JAL: Std_Logic_Vector(3 downto 0) := "1000";
constant OP_JLR: Std_Logic_Vector(3 downto 0) := "1001";

signal null16: std_logic_vector(15 downto 0):="0000000000000000";
signal done_sig: std_logic;
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
signal stallflag_sig: std_logic;
-- Multiplexer related signals
signal M1_out_sig, M3_out_sig, M4_out_sig, M5_out_sig, M6_out_sig, M7_out_sig: std_logic_vector(15 downto 0);
signal M1_sel_sig: std_logic_vector(0 downto 0);
-- condition code register related signals
signal ALU_C_sig, ALU_Z_sig: std_logic;
-- carry and zero register
signal zeroRegEn,carryRegEn,zeroRegDataIn: std_logic;
-- Miscellaneous signals
signal SE9_out: std_logic_vector(15 downto 0);
signal LW_zero: std_logic_vector(0 downto 0);
signal mem_loaded_sig,  I_mem_loaded_sig: std_logic;
signal HighZ16: std_logic_vector(15 downto 0):="ZZZZZZZZZZZZZZZZ";
signal isEqualFlag, PC_write_sig, RF_write_sig: std_logic;
signal regFileData_sig : matrix16(6 downto 0);
begin
----------- Pipeline Register
IF_ID : IF_ID_reg port map(Din => IF_ID_in_sig, Dout => IF_ID_out_sig, clk => clk, enable => pipeline_enable_sig(0));
ID_RR : ID_RR_reg port map(Din => ID_RR_in_sig, Dout => ID_RR_out_sig, clk => clk, enable => pipeline_enable_sig(1));
RR_EX : RR_EX_reg port map(Din => RR_EX_in_sig, Dout => RR_EX_out_sig, clk => clk, enable => pipeline_enable_sig(2));
EX_MEM : EX_MEM_reg port map(Din => EX_MEM_in_sig, Dout => EX_MEM_out_sig, clk => clk, enable => pipeline_enable_sig(3));
MEM_WB : MEM_WB_reg port map(Din => MEM_WB_in_sig, Dout => MEM_WB_out_sig, clk => clk, enable => pipeline_enable_sig(4));

Instruction_pipeline_sig(1) <= IF_ID_out_sig.I16;
ID_RR_in_sig.I16 <= Instr_out_sig(1);

Instruction_pipeline_sig(2) <= ID_RR_out_sig.I16;
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


Instruction_pipeline_sig(3) <= RR_EX_out_sig.I16;
EX_MEM_in_sig.PC_1 <= RR_EX_out_sig.PC_1;
EX_MEM_in_sig.Padder <= RR_EX_out_sig.Padder;
EX_MEM_in_sig.D1 <= RR_EX_out_sig.D1;
EX_MEM_in_sig.RF <= RR_EX_out_sig.RF;
EX_MEM_in_sig.DRAM <= RR_EX_out_sig.DRAM;
EX_MEM_in_sig.D_multiple <= RR_EX_out_sig.D_multiple;
EX_MEM_in_sig.M3_sel <= RR_EX_out_sig.M3_sel;
EX_MEM_in_sig.I16 <= Instr_out_sig(3);
EX_MEM_in_sig.Z_old<=ALU_Z_sig;

Instruction_pipeline_sig(4) <= EX_MEM_out_sig.I16;
MEM_WB_in_sig.PC_1 <= EX_MEM_out_sig.PC_1;
MEM_WB_in_sig.Padder <= EX_MEM_out_sig.Padder;
MEM_WB_in_sig.ALU_OUT <= EX_MEM_out_sig.ALU_OUT;
MEM_WB_in_sig.RF <= EX_MEM_out_sig.RF;
MEM_WB_in_sig.M3_sel <= EX_MEM_out_sig.M3_sel;
MEM_WB_in_sig.I16 <= Instr_out_sig(4);

---------------------------
PC_PROXY: DataRegister generic map(data_width => 16) port map(Din=> PC_val_sig,
 																													 Dout=> IF_ID_in_sig.PC,
																													 clk=> clk,
																													 enable=> PC_write_en_sig);
RF_write_sig <= '0' when
												(
														MEM_WB_out_sig.I16(15 downto 12) ="1111"
														or
														(
															( MEM_WB_out_sig.I16(15 downto 12)="0000" or MEM_WB_out_sig.I16(15 downto 12)="0001"	)
															and
															(
																		( MEM_WB_out_sig.I16(0)='1' and MEM_WB_out_sig.z_old='0')
																	or
																		( MEM_WB_out_sig.I16(1 downto 0)="10" and MEM_WB_out_sig.c_old='0')
															)
														)
											  )

 			else MEM_WB_out_sig.RF.rf_write;


PC_write_sig <= '0' when (
														MEM_WB_out_sig.I16(15 downto 12) ="1111"
														or
														(
														  ( MEM_WB_out_sig.I16(15 downto 12)=OP_AD or MEM_WB_out_sig.I16(15 downto 12)=OP_ND )
														   and
														  ( (MEM_WB_out_sig.I16(1 downto 0)=CZ_zero and MEM_WB_out_sig.z_old='0') or (MEM_WB_out_sig.I16(1 downto 0)=CZ_carry and MEM_WB_out_sig.c_old='0') )
														)
												 )

										else MEM_WB_out_sig.RF.r7_write;


RF : Regfile port map(
									done => done_sig,
									clk => clk,
									logic_in => MEM_WB_out_sig.RF.logic_in,
									Din_rf => MEM_WB_out_sig.D_multiple,
									Dout_rf(6 downto 0) => regFileData_sig(6 downto 0),
									Dout_rf(7) => HighZ16,
									a3rf => MEM_WB_out_sig.RF.a3rf,
									d3rf =>M3_out_sig,
									d4rf => MEM_WB_out_sig.PC_1,
									path_decider => MEM_WB_out_sig.RF.path_decider,
									rf_write => RF_write_sig,
									pc_write =>PC_write_sig
									);

FLogic: FwdCntrl port map(padder(0) => RR_EX_out_sig.Padder,	padder(1) => EX_MEM_out_sig.Padder,	padder(2) => MEM_WB_out_sig.Padder,
													PC_1(0) => RR_EX_out_sig.PC_1, PC_1(1) => EX_MEM_out_sig.PC_1, PC_1(2) => MEM_WB_out_sig.PC_1,
													aluop(0) => EX_MEM_in_sig.ALU_OUT,aluop(1) => EX_MEM_out_sig.PC_1,aluop(2) => MEM_WB_out_sig.PC_1,
													regDest(0) => RR_EX_out_sig.RF.a3rf,regDest(1) => EX_MEM_out_sig.RF.a3rf,regDest(2) => MEM_WB_out_sig.RF.a3rf,
													Iword(0)  =>  RR_EX_out_sig.I16,Iword(1) => EX_MEM_out_sig.I16,Iword(2) => MEM_WB_out_sig.I16,
													Lm_mem	=> MEM_WB_in_sig.D_multiple,  -- mem stage
													Lm_wb => MEM_WB_out_sig.D_multiple,   -- writeback stage ()
													mem_out(0) => MEM_WB_in_sig.mem_out,   -- 0 - mem , 1- writeback (single output)
													mem_out(1) => MEM_WB_out_sig.mem_out,
													Lm_sel(0) =>RR_EX_out_sig.DRAM.mem_ctr, Lm_sel(1) => EX_MEM_out_sig.DRAM.mem_ctr ,Lm_sel(2) => MEM_WB_out_sig.RF.logic_in ,   --0 - execute , 1- mem, 2- writeback (single output)
													regFiledata(6 downto 0)=> regFileData_sig(6 downto 0),-- regFiledata[7] has to be connected to PC brought by the pipeline register
													regFiledata(7)=> ID_RR_out_sig.PC,
													carry(0)=>EX_MEM_in_sig.C_old,carry(1)=>EX_MEM_out_sig.C_old, carry(2)=> MEM_WB_out_sig.C_old,
													zero(0)=>LW_zero(0),zero(1)=> EX_MEM_out_sig.z_old,zero(2)=>MEM_WB_in_sig.z_old,zero(3)=>MEM_WB_out_sig.z_old,
													regDataout => RR_EX_in_sig.D_multiple,
													stallflag => stallflag_sig
													);
ALU0 : ALU port map(I1 => M6_out_sig, I2 => M7_out_sig, Sel => RR_EX_out_sig.ALUsel, C => ALU_C_sig, Z =>ALU_Z_sig, O => EX_MEM_in_sig.ALU_OUT);



AddrBlock : AddressBlock port map(Ain => RR_EX_out_sig.D1, Sel => RR_EX_out_sig.DRAM.mem_ctr, Aout => EX_MEM_in_sig.A_multiple);

isEqu: isEqual port map(I1 => M4_out_sig, I2 => M5_out_sig, O =>isEqualFlag);
isNull: isEqual port map(I1=>MEM_WB_in_sig.mem_out, I2=>null16, O => LW_zero(0));
Add1 : Add_1 port map(I => IF_ID_in_sig.PC, O => IF_ID_in_sig.PC_1);

------------------------------ we need to re look at the mux select encodings ---------------------
M1: GenericMux generic map(seln => 1) port map(I(0) => SE9_out, I(1) => ID_RR_in_sig.SE6, S => M1_sel_sig, O => M1_out_sig);
M3: GenericMux generic map(seln => 2) port map(I(0) => MEM_WB_out_sig.Padder, I(1) => MEM_WB_out_sig.ALU_OUT, I(2) => MEM_WB_out_sig.mem_out, I(3) => MEM_WB_out_sig.PC_1, S => MEM_WB_out_sig.M3_sel, O => M3_out_sig);
M4: GenericMux generic map(seln => 3) port map(I => RR_EX_in_sig.D_multiple, S => ID_RR_out_sig.A1, O => RR_EX_in_sig.D1);
M5: GenericMux generic map(seln => 3) port map(I => RR_EX_in_sig.D_multiple, S => ID_RR_out_sig.A2, O => RR_EX_in_sig.D2);
M6: GenericMux generic map(seln => 1) port map(I(0) => RR_EX_out_sig.D1, I(1) => RR_EX_out_sig.SE6, S => RR_EX_out_sig.M6_sel, O => M6_out_sig);
M7: GenericMux generic map(seln => 1) port map(I(0) => RR_EX_out_sig.D2, I(1) => RR_EX_out_sig.SE6, S => RR_EX_out_sig.M7_sel, O => M7_out_sig);


Adder1: Adder port map(I1 => IF_ID_out_sig.PC, I2 => M1_out_sig, O => ID_RR_in_sig.PC_Imm6);

DEC: InstructionDecoder port map(
			I16 => IF_ID_out_sig.I16,
			RF => ID_RR_in_sig.RF,
			DRAM => ID_RR_in_sig.DRAM,
			M1_sel => M1_sel_sig,
			M6_sel => ID_RR_in_sig.M6_sel,
			M7_sel => ID_RR_in_sig.M7_sel,
			M3_sel => ID_RR_in_sig.M3_sel,
			M4_sel => ID_RR_in_sig.M4_sel,
			M5_sel => ID_RR_in_sig.M5_sel,
			ALUsel(0) => ID_RR_in_sig.ALUsel
);
SE6: SignExtend_6 port map(IN_6 => IF_ID_out_sig.I16(5 downto 0), OUT_16 => ID_RR_in_sig.SE6);
SE9: signExtend_9 port map(IN_9 => IF_ID_out_sig.I16(8 downto 0), OUT_16 => SE9_out);
Pad: Padder port map(I => IF_ID_out_sig.I16(8 downto 0), O => ID_RR_in_sig.Padder);
-- Carry and Zero Logic ( Embedded Here)-------------------
carryRegEn <= RR_EX_out_sig.RF.CarryEn
					when (
								(not (RR_EX_out_sig.I16(15 downto 12) = "1111"))
								or
								(EX_MEM_in_sig.C_old='1' and RR_EX_out_sig.I16(15 downto 12)=op_AD and RR_EX_out_sig.I16(1 downto 0)= CZ_carry)
							 )
						else	'0';
-- zero-- ** Correction Here
zeroRegEn <= EX_MEM_out_sig.RF.ZeroEn
					when (
								(
								 not(RR_EX_out_sig.I16(15 downto 12 )="1111")
								)
					 			or
								(
									(MEM_WB_in_sig.Z_old='1' and RR_EX_out_sig.I16(15 downto 12)=op_AD) and (RR_EX_out_sig.I16(1 downto 0)= CZ_zero)
								)
							 )
						else '0';
zeroRegDataIn <= LW_zero(0) when ( EX_MEM_out_sig.I16(15 downto 12)=OP_LW)
							else EX_MEM_out_sig.Z_old;
---------End of Carry and Zero Logic---------------------
CarryReg: DataRegister generic map(data_width => 1) port map(enable =>carryRegEn,
																														Din(0) => ALU_C_sig,
																														Dout(0) =>EX_MEM_in_sig.C_old,
																														clk =>clk
																														);
ZeroReg: DataRegister generic map(data_width => 1) port map(enable =>zeroRegEn,
																													Din(0) => zeroRegDataIn,
																													Dout(0) =>EX_MEM_in_sig.C_old,
																													clk =>clk
																													);
Hazard_Mitigation_Unit: HazardUnit port map (
							lw_out => MEM_WB_in_sig.mem_out,
							lm_out => MEM_WB_in_sig.D_multiple(7),
							aluop => EX_MEM_in_sig.ALU_OUT,
							JLRreg => M5_out_sig,
							Pc_Im6 => ID_RR_out_sig.PC_Imm6,
							Pc_Im9 => ID_RR_in_sig.PC_Imm6,
							padder => ID_RR_in_sig.Padder,
							-------------
							stallflag => stallflag_sig,
							Instruction_pipeline(0) => Instruction_pipeline_sig(0),
							Instruction_pipeline(1) => Instruction_pipeline_sig(1),
							Instruction_pipeline(2) => Instruction_pipeline_sig(2),
							Instruction_pipeline(3) => Instruction_pipeline_sig(3),
							Instruction_pipeline(4) => Instruction_pipeline_sig(4),
							 --  0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
							carry_ex => EX_MEM_in_sig.C_old,
							zero_ex(0)=>LW_zero(0), zero_ex(1)=> EX_MEM_out_sig.z_old, zero_ex(2)=>MEM_WB_in_sig.z_old,
							regDest(0) => ID_RR_in_sig.RF.a3rf,
							regDest(1) => ID_RR_out_sig.RF.a3rf,
							regDest(2) => RR_EX_out_sig.RF.a3rf,
							regDest(3) => EX_MEM_out_sig.RF.a3rf,
							Lm_sel_r7 => EX_MEM_out_sig.DRAM.mem_ctr(7),
							BEQequal => isEqualFlag,
							PCplus1 => IF_ID_in_sig.PC_1,
							Instr_out(0) => IF_ID_in_sig.I16,
							Instr_out(2) => RR_EX_out_sig.I16,
							Instr_out(1) => EX_MEM_out_sig.I16,
							Instr_out(3) => MEM_WB_out_sig.I16,
							Instr_out(4) => EX_MEM_out_sig.I16,
							pipeline_enable => pipeline_enable_sig,  --  0- for IF, 1-ID, 2-RR, 3-EX, 4-MEM
							PC_write_en => PC_write_en_sig,
							PCval => PC_val_sig);

							mem_ctr_out<=EX_MEM_out_sig.DRAM.mem_ctr;
							din_mem_out<=EX_MEM_out_sig.D_multiple;
							MEM_WB_in_sig.D_multiple<=dout_mem_in;
							dram_addr_mem<=EX_MEM_out_sig.A_multiple;
							dram_pathway<=EX_MEM_out_sig.DRAM.pathway;
							dram_writeEN<=EX_MEM_out_sig.DRAM.writeEN;
							mem_loaded_sig<=dram_mem_loaded;
							dram_ai_mem<=EX_MEM_out_sig.ALU_OUT;
							dram_di_mem<=EX_MEM_out_sig.D1;
							MEM_WB_in_sig.mem_out<=dram_do_mem;
							I_mem_loaded_sig<=irom_mem_loaded;
							irom_address<=IF_ID_in_sig.PC;
							Instruction_pipeline_sig(0)<=irom_dataout;

end arch;
