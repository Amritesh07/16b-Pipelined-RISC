library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.components.all;
--Grand Entity
entity IITB_RISC_ppln is port(
	clk: in std_logic;
	clk_50: in std_logic;
  reset:in std_logic
);
end entity IITB_RISC_ppln;


architecture Struct of IITB_RISC_ppln is
   signal rst:std_logic;
   signal mem_ctr_sig:std_logic_vector(7 downto 0);
   signal din_mem_sig:matrix16(7 downto 0);
   signal dout_mem_sig:matrix16(7 downto 0);
   signal dram_addr_mem_sig:matrix16(7 downto 0);
   signal dram_pathway_sig:std_logic;
   signal dram_writeEN_sig:std_logic;
   signal dram_mem_loaded_sig:std_logic;
   signal dram_ai_mem_sig:std_logic_vector(15 downto 0);
   signal dram_di_mem_sig:std_logic_vector(15 downto 0);
   signal dram_do_mem_sig:std_logic_vector(15 downto 0);
   signal load_mem_sig:std_logic;
   signal irom_mem_loaded_sig:std_logic;
   signal irom_address_sig:std_logic_vector(15 downto 0);
   signal irom_dataout_sig:std_logic_vector(15 downto 0);
begin

	load_mem_sig <= not reset ;
	DP: Datapath port map(
    clk=>clk,
  	mem_ctr_out=>mem_ctr_sig,
  	din_mem_out=>din_mem_sig,
  	dout_mem_in=>dout_mem_sig,
  	dram_addr_mem=>dram_addr_mem_sig,
  	dram_pathway=>dram_pathway_sig,
  	dram_writeEN=>dram_writeEN_sig,
  	dram_load_mem=>load_mem_sig,
  	dram_mem_loaded=>dram_mem_loaded_sig,
  	dram_ai_mem=>dram_ai_mem_sig,
  	dram_di_mem=>dram_di_mem_sig,
  	dram_do_mem=>dram_do_mem_sig,
  	irom_load_mem=>load_mem_sig,
  	irom_mem_loaded=>irom_mem_loaded_sig,
  	irom_address=>irom_address_sig,
  	irom_dataout=>irom_dataout_sig
  	);

  DataMem: DRAM port map
  (clock => clk,
  mem_ctr => mem_ctr_sig,
  Din_mem => din_mem_sig,
  Dout_mem => dout_mem_sig,
  Addr_mem => dram_addr_mem_sig,
  pathway => dram_pathway_sig,
  writeEN => dram_writeEN_sig,
  load_mem => load_mem_sig,
  mem_loaded => dram_mem_loaded_sig,
  ai_mem => dram_ai_mem_sig,
  di_mem => dram_di_mem_sig,
  do_mem => dram_do_mem_sig);

  InstMem: iROM port map
  (clock => clk,
  load_mem => load_mem_sig,
  mem_loaded => irom_mem_loaded_sig,
  address => irom_address_sig,
  dataout => irom_dataout_sig);

end Struct;
