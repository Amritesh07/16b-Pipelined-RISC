LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


package IITB_RISC_Components is

--Grand Entity
component IITB_RISC is port(
	start_mc: in std_logic;
	reset: in std_logic;
	clk: in std_logic;
	instr_data_in: in std_logic_vector(15 downto 0);
	addr_wr: in std_logic_vector(15 downto 0);
	mem_bit: in std_logic
);
end component;


component ControlPath is
	port (
		T_arr: out std_logic_vector(0 to 31);
		P: in std_logic_vector(4 downto 0);
		IR_val: in std_logic_vector(15 downto 0);
		start_state: in std_logic;
		done_state : out std_logic;
		clk, reset: in std_logic
	     );
end component;

component datapath is
port(T: in std_logic_vector(31 downto 0);
	  P: out std_logic_vector(4 downto 0);
	  Mem_Dout: in std_logic_vector(15 downto 0);  -- data output from memory 
	  Mem_Din,Mem_Ain: out std_logic_vector(15 downto 0);    -- data and address input to memory
	  CLK : in std_logic;
	  IR_val:out std_logic_vector(15 downto 0)
	  );
end component;


component regfile is port(
	done : out std_logic;
	clk : in std_logic;
	pc_wr : in std_logic;
	rf_wr : in std_logic;
	a1rf  : in std_logic_vector(2 downto 0);
	a2rf  : in std_logic_vector(2 downto 0);
	a3rf  : in std_logic_vector(2 downto 0);
	d1rf  : out std_logic_vector(15 downto 0);
	d2rf  : out std_logic_vector(15 downto 0);
	d3rf  : in std_logic_vector(15 downto 0);
	d4rf  : in std_logic_vector(15 downto 0);
	d5rf  : out std_logic_vector(15 downto 0));
end component;

component PriorityEncoder is
port ( x : in std_logic_vector(15 downto 0);
	s : out std_logic_vector(2 downto 0);	
	d: out std_logic_vector(15 downto 0);
	err_flag: out std_logic	 ) ;
end component;


component RAM is
  port (
    clock   : in  std_logic;
    writeEN : in  std_logic;
    address : in  std_logic_vector;
    datain  : in  std_logic_vector;
    dataout : out std_logic_vector
  );
end component;

--Babbajji ke ALU ke kamaal
component OneBitAdder is
		port (a, b, cin: in std_logic; s,cout : out std_logic);
	end component;
	
	component b16_conditional_repeater is
	port (  
			input: in std_logic_vector(15 downto 0);            -- operand 1
			output: out std_logic_vector(15 downto 0);			-- operand 2
			
			carry_in: in std_logic;							
			zero_in: in std_logic;							
			carry_out: out std_logic;							
			zero_out: out std_logic;							
			-- opcode
			op: in std_logic						-- (00)add, (01)nand, (1x) xor
			);
	end component;
	
	component b16_adder is
	port (  
			x: in std_logic_vector(15 downto 0);            -- operand 1
			y: in std_logic_vector(15 downto 0);			-- operand 2
			s: out std_logic_vector(15 downto 0);		
			carry_out: out std_logic;							
			zero_out: out std_logic							
			);
	end component;

	component b16_nander is
	port (  
			x: in std_logic_vector(15 downto 0);            -- operand 1
			y: in std_logic_vector(15 downto 0);			-- operand 2
			s: out std_logic_vector(15 downto 0);
			carry_out: out std_logic;							
			zero_out: out std_logic							
			);
	end component;

	component b16_xorer is
	port (  
			x: in std_logic_vector(15 downto 0);            -- operand 1
			y: in std_logic_vector(15 downto 0);			-- operand 2
			s: out std_logic_vector(15 downto 0);
			carry_out: out std_logic;							
			zero_out: out std_logic							
			);
	end component;

	
	component ALU is 
	port (  -- operands and result
			alu_a: in std_logic_vector(15 downto 0);            -- operand 1
			alu_b: in std_logic_vector(15 downto 0);			-- operand 2
			alu_out: out std_logic_vector(15 downto 0);			-- output
			-- to and fro communication with Condition code registers
			alu_c_out: out std_logic;							-- input to carry register
			alu_z_out: out std_logic;							-- input to zero register
			-- opcode
			op_code: in std_logic_vector(1 downto 0)						-- (00)add, (01)nand, (1x) xor
			);
	end component;

end package;
