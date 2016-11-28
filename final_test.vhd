library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.components.all;

entity Grand_Testh is
end entity;
architecture Behave of Grand_Testh is

signal clk: std_logic:='0';
signal clk_50: std_logic:='0';
signal reset: std_logic:='0';

component Pilot is
port
(
reset: in std_logic;
clk: in std_logic;
clk_50: in std_logic

);
end component;
begin

 clk <= not clk after 50 ns; -- assume 50ns clock.
 clk_50 <= not clk_50 after 20 ns; --Logic Analyzer Clock
  process
  begin
  wait until clk = '0';
  reset <= '0';
  end process;

dut:
	Pilot port map (reset=>reset,clk => clk,clk_50 => clk_50);

end Behave;
