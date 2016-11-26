library IEEE;
use IEEE.STD_LOGIC_1164.all;
package Common is
	type RegFileData is Record	
		a3rf :  std_logic_vector(2 downto 0);
		path_decider :  std_logic;
		rf_write:  std_logic;
		pc_write :  std_logic;
		logic_in :  std_logic_vector(7 downto 0);
	end record;
	type dramData is Record
		mem_ctr : std_logic_vector(7 downto 0);
		pathway : bit;
		writeEN : bit;
		load_mem : bit;
	 end Record;
end package;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.Common.all; 
entity InstructionDecoder is
port(
	 I16: in std_logic_vector(15 downto 0);
	 RF: out RegFileData;
	 DRAM: out DramData;
	 A1,A2: out std_logic_vector(2 downto 0)
	 	);
end entity;

architecture arch of instructionDecoder is
	signal opcode: std_logic_vector(3 downto 0);
	signal RA,RB,RC: std_logic_vector(2 downto 0);
	signal Imm6 : std_logic_vector(5 downto 0);
	signal Imm9 : std_logic_vector(8 downto 0);
	signal CZ 	: std_logic_vector(1 downto 0);
	
	
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
	
	signal RFvar: regFileData;
	signal DRAMvar: DRAmData;
	
	
begin
	opcode<=I16(15 downto 12);
	RA<=I16(11 downto 9);
	RB<=I16(8 downto 6);
	RC<=I16(5 downto 3);
	Imm6<=I16(5 downto 0);
	Imm9<=I16(8 downto 0);
	CZ<=I16(1 downto 0);
	
	
	-- Default Instruction decoded output
	A1<=RA;
	A2<=RB;
	
	process(I16)
		signal RFvar: regFileData;
		signal DRAMvar: DRAmData;
	begin
			--ADD=====================================================
			if(opcode=OP_AD and CZ=CZ_none) then		-- ADD instruction
				RFvar.a3rf<=RC;					
				RFvar.path_decider<='0';
				RFvar.rf_write<='1';
				RFvar.pc_write<='0';
				RFvar.lOgic_in<="0000000";
				
				DRAMvar.mem_ctr<="00000000";
				DRAMvar.pathway<='0';
				DRAMvar.writeEN<='0';
				DRAMvar.load_mem<='0';
				
			end if;
			--
			if(opcode=op_AD and CZ=CZ_carry) then
				RFvar.a3rf<=RC;					
			end if;
			--
			if(opcode=op_AD and CZ=CZ_zero) then
				RFvar.a3rf<=RC;					
			end if;
			--
			if(opcode=op_ADI) then
				RFvar.a3rf<=RC;					
			end if;
			
			--NAND===========================================================
			if(opcode=op_ND and CZ=CZ_none) then			-- NAND Instruction
				RFvar.a3rf<=RC;					
			end if;
			--
			if(opcode=op_ND and CZ=CZ_carry) then
				RFvar.a3rf<=RC;					
			end if;
			--
			if(opcode=op_ND and CZ=CZ_zero) then
				RFvar.a3rf<=RC;					
			end if;
			
			--LHI=============================================================
			if(opcode=OP_LHI) then
				RFvar.a3rf<=RC;					
			end if;
			
			--LW==============================================================
			if(opcode=OP_LW) then
				RFvar.a3rf<=RC;					
			end if;
			--SW==============================================================
			if(opcode=OP_SW) then
									
			end if;
			--LM==============================================================
			if(opcode=OP_LM) then
									
			end if;
			--SM==============================================================
			if(opcode=OP_SM) then
			end if;
			--BEQ==============================================================
			if(opcode=OP_BEQ) then
			end if;
			--JAL=============================================================
			if(opcode=OP_JAL) then
				RFvar.a3rf<=RC;					
			end if;
			--JLR==============================================================
			if(opcode=OP_JLR) then
				RFvar.a3rf<=RC;					
			end if;
			
			
	end process;
	


end arch;
