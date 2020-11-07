library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Cache is
    Port ( 	clk 				: in  STD_LOGIC;
				reset				: in 	STD_LOGIC;
				cs 				: in 	STD_LOGIC;
				cpu_wr_en		: in 	STD_LOGIC;
				addr_in			: in	STD_LOGIC_VECTOR (15 downto 0);
				cpu_d_in			: in 	STD_LOGIC_VECTOR (7 downto 0);
				sdram_d_in		: in 	STD_LOGIC_VECTOR (7 downto 0);
				cpu_d_out		: out STD_LOGIC_VECTOR (7 downto 0);
				sdram_d_out		: out STD_LOGIC_VECTOR (7 downto 0);
				addr_out 		: out	STD_LOGIC_VECTOR (15 downto 0); -- To SDRAM controller
				wr_en				: out STD_LOGIC; -- SDRAM write enable
				mem_strb 		: out STD_LOGIC;
				rdy 				: out STD_LOGIC);
end Cache;

architecture Behavioral of Cache is
	
	-- Declaring internal signals of the cache that connect between the
	-- Cache Controller and Cache SRAM
	signal tmp_addr		: STD_LOGIC_VECTOR (7 downto 0);
	signal tmp_wr_en		: STD_LOGIC;
	
	-- Internal signals to connect the data in mux to SDRAM and Cache Controller
	signal tmp_mux_in_selector		: STD_LOGIC;
	signal tmp_mux_in_output		: STD_LOGIC_VECTOR (7 downto 0);
	
	-- Internal signals to connect the data out mux to SDRAM and Cache Controller
	signal tmp_mux_out_selector		: STD_LOGIC;
	signal tmp_mux_out_input			: STD_LOGIC_VECTOR (7 downto 0);
	

begin
	-- Instantiating the data in mux to determine which input (CPU
	-- or SDRAM) will be sent to SRAM
	d_in_mux: entity work.d_in_mux PORT MAP(
		selector => tmp_mux_in_selector,
		d_in_0 => cpu_d_in,
		d_in_1 => sdram_d_in,
		d_out => tmp_mux_in_output
	);
	
	-- Instantiating the data out mux to determine which output (CPU
	-- or SDRAM) will the SRAM data be sent to
	d_out_mux: entity work.d_out_mux PORT MAP(
		selector 	=> tmp_mux_out_selector,
		d_in 			=> tmp_mux_out_input,
		d_out_0 		=> sdram_d_out,
		d_out_1 		=> cpu_d_out
	);
	
	-- Instantiating the CacheController
	CacheController: entity work.CacheController PORT MAP(
		clk 					=> clk,
		reset 				=> reset,
		cs 					=> cs,
		cpu_wr_en			=> cpu_wr_en,
		addr_in 				=> addr_in,
		addr_out_16 		=> addr_out,
		addr_out_8 			=> tmp_addr,
		sdram_wr_en 		=> wr_en,
		sram_wr_en 			=> tmp_wr_en,
		mem_strb 			=> mem_strb,
		d_in_selector 		=> tmp_mux_in_selector,
		d_out_selector 	=> tmp_mux_out_selector,
		rdy 					=> rdy
	);
	
	-- Instantiating the SRAM
	sram : entity work.sram PORT MAP (
    clk 			=> clk,
    wr_en 		=> tmp_wr_en,
    addr 		=> tmp_addr,
    d_in 		=> tmp_mux_in_output,
    d_out 		=> tmp_mux_out_input
	);

end Behavioral;
