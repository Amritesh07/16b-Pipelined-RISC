library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;

package ALU_Components is	
	
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


end ALU_Components;
