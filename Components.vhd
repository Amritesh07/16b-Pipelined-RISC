-- List of all components for Datapath
-- Instruction RAM	*
-- Instruction Decoder
-- Sign Extender 6	*
-- Sign Extender 9	*
-- Padder		*
-- Adder			*
-- Data Register *
-- Multiplexer Generic (16 bit) *
-- Register File	*
-- Forwarding  Logic	*
-- ALU				*
-- Data RAM			*
-- Register Generic *
-- Address Block	*

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.Types.all;
use work.matrix.all;
use work.Common.all;
use work.matrixType.all;
--======================
package components is
--======================
component DataRegister is
	generic (data_width:integer);
	port (Din: in std_logic_vector(data_width-1 downto 0);
	      Dout: out std_logic_vector(data_width-1 downto 0);
	      clk, enable: in std_logic);
end component;

component padder is
port ( I : in std_logic_vector(8 downto 0);
		 O : out std_logic_vector(15 downto 0));
end component;

component SignExtend_9 is
port( 	--- Input
		IN_9:in std_logic_vector(9 downto 1);
		OUT_16: out std_logic_vector(16 downto 1)
		);
end component;

component SignExtend_6 is
port( 	--- Input
		IN_6:in std_logic_vector(6 downto 1);
		OUT_16: out std_logic_vector(16 downto 1)
		);
end component;


component Add_1 is
port(
	I: in std_logic_vector(15 downto 0);
	O: out std_logic_vector(15 downto 0)
	);
end component;


component regfile is port(
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
end component;


component iRAM is
  port (
    clock   : in  std_logic;
    load_mem: in std_logic;
    mem_loaded : out std_logic;
    writeEN : in  std_logic;
    address : in  std_logic_vector(0 to 15);
    datain  : in  std_logic_vector(15 downto 0);
    dataout : out std_logic_vector(15 downto 0)
  );
end component;


component dRAM is
  port (
    clock   : in  std_logic;
    mem_ctr : in std_logic_vector(7 downto 0);
    di0mem  : in std_logic_vector(15 downto 0);
    di1mem  : in std_logic_vector(15 downto 0);
    di2mem  : in std_logic_vector(15 downto 0);
    di3mem  : in std_logic_vector(15 downto 0);
    di4mem  : in std_logic_vector(15 downto 0);
    di5mem	 : in std_logic_vector(15 downto 0);
    di6mem  : in std_logic_vector(15 downto 0);
    di7mem  : in std_logic_vector(15 downto 0);
    ai0mem  : in std_logic_vector(0 to 15);
    ai1mem  : in std_logic_vector(0 to 15);
    ai2mem  : in std_logic_vector(0 to 15);
    ai3mem  : in std_logic_vector(0 to 15);
    ai4mem  : in std_logic_vector(0 to 15);
    ai5mem	 : in std_logic_vector(0 to 15);
    ai6mem  : in std_logic_vector(0 to 15);
    ai7mem  : in std_logic_vector(0 to 15);
    do0mem  : out std_logic_vector(15 downto 0);
    do1mem  : out std_logic_vector(15 downto 0);
    do2mem  : out std_logic_vector(15 downto 0);
    do3mem  : out std_logic_vector(15 downto 0);
    do4mem  : out std_logic_vector(15 downto 0);
    do5mem	 : out std_logic_vector(15 downto 0);
    do6mem  : out std_logic_vector(15 downto 0);
    do7mem  : out std_logic_vector(15 downto 0);

    pathway: in bit;
    writeEN: in bit;
    load_mem: in bit;
    mem_loaded: out bit;
    ai_mem: in std_logic_vector(0 to 15);
    di_mem: in std_logic_vector(15 downto 0);
    do_mem: out std_logic_vector(15 downto 0)


  );
end component;


component AddressBlock is
port(
	Ain: in std_logic_vector(15 downto 0);
	Sel: in std_logic_vector(7 downto 0);
	Aout: out AddressOutType);
end component;

component GenericMux is

        generic (dataWidth : positive := 16;
						seln: positive := 2);
        port (  I : in matrix(2**seln - 1 downto 0);
                S : in std_logic_vector(seln - 1 downto 0);
                O : out std_logic_vector(dataWidth - 1 downto 0));
end component;

component Adder is
port(
	I1,I2: in std_logic_vector(15 downto 0);
	O: out std_logic_vector(15 downto 0)
	);
end component;
component FwdCntrl is
port (
padder:       in matrix16(2 downto 0);       -- 0 - execute  1 - mem -- 2- for writeback for all
PC_1:         in matrix16(2 downto 0);
aluop:        in matrix16(2 downto 0);
regDest:      in matrix3(2 downto 0) ;
Iword:        in matrix16(2 downto 0);
Lm_mem:       in matrix16(7 downto 0);  -- mem stage
Lm_wb:        in matrix16(7 downto 0);   -- writeback stage ()
mem_out:      in matrix16(1 downto 0);   -- 0 - mem , 1- writeback (single output)
Lm_sel:       in matrix16(1 downto 0);    --0 - mem , 1- writeback (single output)
RegFileCtrl:  in matrix16(7 downto 0);  -- RegFileCtrl[7] has to be connected to PC brought by the pipeline register
carry :       in std_logic_vector(2 downto 0);
zero:         in std_logic_vector(2 downto 0);
regDataout:   out matrix16(7 downto 0)
         ) ;
end component ;
component ALU is
port(
		I1,I2 : in std_logic_vector(15 downto 0);
		O: out std_logic_vector(15 downto 0);
		Sel: in std_logic;
		C,Z: out std_logic);
end component;

component InstructionDecoder is
port(
	 I16: in std_logic_vector(15 downto 0);
	 RF: out RegFileCtrl;
	 DRAM: out dramCtrl;
	 A1,A2: out std_logic_vector(2 downto 0);
	 M1_sel,M6_sel,M7_sel: out std_logic_vector(0 downto 0);
	 M3_sel,M8_sel: out std_logic_vector(1 downto 0);
	 M2_sel,M4_sel,M5_sel: out std_logic_vector(2 downto 0)
	 );

component Adder is
port(
	I1,I2: in std_logic_vector(15 downto 0);
	O: out std_logic_vector(15 downto 0)
	);
end component;

component isEqual is
port(I1,I2: in std_logic_vector(15 downto 0);
		O: out std_logic);
end component;
end component;
--==========
end package;
--==========
