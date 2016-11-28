
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.components.all;

entity InstructionDecoder is
port(
	 I16: in std_logic_vector(15 downto 0);
	 RF: out RegFileCtrl;
	 DRAM: out dramCtrl;
	 M1_sel,M6_sel,M7_sel: out std_logic_vector(0 downto 0);
	 M3_sel: out std_logic_vector(1 downto 0);
	 M4_sel,M5_sel: out std_logic_vector(2 downto 0);
	 ALUsel: out std_logic_vector(0 downto 0)
	 );
end entity;

architecture arch of instructionDecoder is
	signal opcode: std_logic_vector(3 downto 0);
	signal RA,RB,RC: std_logic_vector(2 downto 0);
	signal Imm6 : std_logic_vector(5 downto 0);
	signal Imm9 : std_logic_vector(8 downto 0);
	signal CZ 	: std_logic_vector(1 downto 0);
	signal Rsel : std_logic_vector(7 downto 0);
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
	signal RF_sig: RegFileCtrl;
	signal DRAM_sig: dramCtrl;
	signal null16:std_logic_vector(15 downto 0):="0000000000000000";
	signal M1_sel_sig,M6_sel_sig,M7_sel_sig:  std_logic_vector(0 downto 0);
	signal M3_sel_sig: std_logic_vector(1 downto 0);
	signal M4_sel_sig,M5_sel_sig: std_logic_vector(2 downto 0);
	signal A1_sig,A2_sig: std_logic_vector(2 downto 0);
	signal ALUsel_sig: std_logic_vector(0 downto 0);


begin
	opcode<=I16(15 downto 12);
	RA<=I16(11 downto 9);
	RB<=I16(8 downto 6);
	RC<=I16(5 downto 3);
	Imm6<=I16(5 downto 0);
	Imm9<=I16(8 downto 0);
	Rsel<=I16(7 downto 0);
	CZ<=I16(1 downto 0);


	-- Default Instruction decoded output
	A1_sig<=RA;
	A2_sig<=RB;


	process(I16,opcode,CZ,RC,A1_sig,A2_sig,RA,RB,Rsel)
		variable RF_var: RegFileCtrl;
		variable DRAM_var: dramCtrl;
		variable ALUsel_var: std_logic_vector(0 downto 0);
		variable M1_sel_var,M6_sel_var,M7_sel_var: std_logic_vector(0 downto 0);
		variable M3_sel_var: std_logic_vector(1 downto 0);
		variable M4_sel_var,M5_sel_var: std_logic_vector(2 downto 0);

	begin
			RF_var.a3rf := "000";
			RF_var.path_decider := '0';
			RF_var.rf_write := '0';
			RF_var.r7_write := '0';
			RF_var.logic_in := "00000000";
			RF_var.CarryEn := '0';
			RF_var.zeroEN := '0';

			DRAM_var.mem_ctr := "00000000";
			DRAM_var.pathway := '0';
			DRAM_var.writeEN := '0';
			DRAM_var.load_mem := '0';

			ALUsel_var := "0";
			M1_sel_var := "0";
			M6_sel_var := "0";
			M7_sel_var := "0";
			M3_sel_var := "00";
			M4_sel_var := "000";
			M5_sel_var := "000";

			--ADD=====================================================
			if(opcode=OP_AD and CZ=CZ_none) then		-- ADD instruction
				RF_var.a3rf:=RC;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';
				RF_var.lOgic_in:="00000000";
				if(RF_var.a3rf="111") then
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="0";
				RF_var.carryEN:='1';
				RF_var.zeroEN:='1';

				DRAM_var.mem_ctr:="00000000";
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="01";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="0";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="0";

			end if;
			--ADC=================================================
			if(opcode=op_AD and CZ=CZ_carry) then
				RF_var.a3rf:=RC;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';				--***
				RF_var.lOgic_in:="00000000";
				if(RF_var.a3rf="111" ) then
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="0";
				RF_var.carryEN:='1';
				RF_var.zeroEN:='1';

				DRAM_var.mem_ctr:="00000000";
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="01";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="0";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="0";
			end if;
			--ADZ================
			if(opcode=op_AD and CZ=CZ_zero) then
				RF_var.a3rf:=RC;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';			--***
				RF_var.lOgic_in:="00000000";
				if(RF_var.a3rf="111" ) then
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="0";
				RF_var.carryEN:='1';
				RF_var.zeroEN:='1';

				DRAM_var.mem_ctr:="00000000";
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="01";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="0";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="0"; --1
			end if;
			--ADI============================================================
			if(opcode=op_ADI) then
				RF_var.a3rf:=RB;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';				--***
				RF_var.lOgic_in:="00000000";

				if(RF_var.a3rf="111") then
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="0";
				RF_var.carryEN:='1';
				RF_var.zeroEN:='1';

				DRAM_var.mem_ctr:="00000000";
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="01";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="0";--1
				M7_sel_var:="1";--1				Input from SE6
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="0"; --1
			end if;

			--NAND===========================================================
			if(opcode=op_ND and CZ=CZ_carry) then
				RF_var.a3rf:=RC;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';				--***
				RF_var.lOgic_in:="00000000";
				if(RF_var.a3rf="111") then
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="1";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='1';

				DRAM_var.mem_ctr:="00000000";
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="01";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="0";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="0"; --1
			end if;
			--NDZ
			if(opcode=op_ND and CZ=CZ_zero) then
				RF_var.a3rf:=RC;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';				--***
				RF_var.logic_in:="00000000";
				if(RF_var.a3rf="111") then
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="1";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='1';

				DRAM_var.mem_ctr:="00000000";
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="01";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="0";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="0"; --1
			end if;

			--LHI=============================================================
			if(opcode=OP_LHI) then
				RF_var.a3rf:=RA;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';				--***
				RF_var.logic_in:="00000000";
				if(RF_var.a3rf="111") then
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="0";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='1';

				DRAM_var.mem_ctr:="00000000";
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="00";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="0";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="0"; --1
			end if;

			--LW==============================================================
			if(opcode=OP_LW) then
				RF_var.a3rf:=RA;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';				--***
				RF_var.logic_in:="00000000";
				if(RF_var.a3rf="111") then
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="0";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='1';

				DRAM_var.mem_ctr:="00000000";
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="00";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="0";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="1"; --1
			end if;
			--SW==============================================================
			if(opcode=OP_SW) then
				RF_var.a3rf:=RA;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='0';				--***
				RF_var.logic_in:="00000000";
				RF_var.r7_write:='1';



				AluSel_var:="0";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='0';

				DRAM_var.mem_ctr:="00000000";
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='1';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="00";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="1";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="1"; --
			end if;
			--LM==============================================================
			if(opcode=OP_LM) then
				RF_var.a3rf:=RA;
				RF_var.path_decider:='1';		--
				RF_var.rf_write:='1';				--***
				RF_var.logic_in:=Rsel;
				if(Rsel(7)='1') then
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="0";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='0';

				DRAM_var.mem_ctr:=Rsel;
				-- Address  Block gets Rsel from Datapath Direct ( ^ can be reduced)
				DRAM_var.pathway:='1';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="00";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="1";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="1"; --
			end if;
			--SM==============================================================
			if(opcode=OP_SM) then
					RF_var.a3rf:=RA;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='0';				--***
				RF_var.logic_in:=Rsel;
				RF_var.r7_write:='1';



				AluSel_var:="0";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='0';

				DRAM_var.mem_ctr:=Rsel;
				-- Address  Block gets Rsel from Datapath Direct ( ^ can be reduced)
				DRAM_var.pathway:='1';
				DRAM_var.writeEN:='1';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="X";--1

				M3_sel_var:="00";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="1";--1
				M7_sel_var:="0";--1
				--**
				--"001";--3			 PC<(PC)+1
				--:="000";--3
				--:="1"; --
			end if;
			--BEQ==============================================================
			if(opcode=OP_BEQ) then
				RF_var.a3rf:=RA;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='0';				--***
				RF_var.logic_in:="00000000";
				RF_var.r7_write:='1';

				AluSel_var:="0";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='0';

				DRAM_var.mem_ctr:="00000000";
				-- Address  Block gets Rsel from Datapath Direct ( ^ can be reduced)
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="0";--1

				M3_sel_var:="00";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="1";--1
				M7_sel_var:="0";--1
				--**
				--"000";--3			 PC<(PC)+1
				--:="000";--3
				--:="1"; --
			end if;
			--JAL=============================================================
			if(opcode=OP_JAL) then
				RF_var.a3rf:=RA;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';				--***
				RF_var.logic_in:="00000000";

				if(RF_var.a3rf="111") then		-- ambigious case !!
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="0";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='0';

				DRAM_var.mem_ctr:="00000000";
				-- Address  Block gets Rsel from Datapath Direct ( ^ can be reduced)
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';



				M1_sel_var:="1";--1

				M3_sel_var:="11";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="1";--1
				M7_sel_var:="0";--1
				--**
				--"000";--3			 PC<(PC)+1
				--:="000";--3
				--:="1"; --1
			end if;
			--JLR==============================================================
			if(opcode=OP_JLR) then
				RF_var.a3rf:=RA;
				RF_var.path_decider:='0';		--
				RF_var.rf_write:='1';				--***
				RF_var.logic_in:="00000000";

				if(RF_var.a3rf="111") then		-- ambigious case !!
					RF_var.r7_write:='0';

				else
					RF_var.r7_write:='1';
				end if;


				AluSel_var:="0";
				RF_var.carryEN:='0';
				RF_var.zeroEN:='0';

				DRAM_var.mem_ctr:="00000000";
				-- Address  Block gets Rsel from Datapath Direct ( ^ can be reduced)
				DRAM_var.pathway:='0';
				DRAM_var.writeEN:='0';
				DRAM_var.load_mem:='0';

				-- := '1';

				M1_sel_var:="1";--1
				M3_sel_var:="11";--2
				M4_sel_var:=A1_sig;--3
				M5_sel_var:=A2_sig;--3
				M6_sel_var:="1";--1
				M7_sel_var:="0";--1
				--**
				--"010";--3			 PC<(PC)+1
				--:="000";--3
				--:="1"; --1
			end if;


				RF_sig<=RF_var;
				DRAM_sig<=DRAM_var;
				M1_sel_sig<=M1_sel_var;
				M6_sel_sig<=M6_sel_var;
				M7_sel_sig<=M7_sel_var;
				M3_sel_sig<=M3_sel_var;
				M4_sel_sig<=M4_sel_var;
				M5_sel_sig<=M5_sel_var;
				ALUsel_sig<=ALUsel_var;


	end process;
	RF<=RF_sig;
	DRAM<=DRAM_sig;
	M1_sel<=M1_sel_sig;
	M6_sel<=M6_sel_sig;
	M7_sel<=M7_sel_sig;
	M3_sel<=M3_sel_sig;
	M4_sel<=M4_sel_sig;
	M5_sel<=M5_sel_sig;
	ALUsel<=ALUsel_sig;

end arch;
