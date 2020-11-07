library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Project1 is
    Port ( 	clk 				: in  STD_LOGIC;
				reset				: in 	STD_LOGIC
			);
end Project1;

architecture Behavioral of Project1 is
	
	-- Signals from Cache to CPU
	signal tmp_cpu_rdy 		: STD_LOGIC;
	signal tmp_cpu_d_in		: STD_LOGIC_VECTOR(7 downto 0);
	
	-- Signals from CPU to Cache
	signal tmp_cache_addr_in	: STD_LOGIC_VECTOR(15 downto 0);
	signal tmp_cache_wr_en		: STD_LOGIC;
	signal tmp_cache_cs			: STD_LOGIC;
	signal tmp_cache_mux_in		: STD_LOGIC_VECTOR(7 downto 0);
	
	-- Signals from Cache to SDRAM Controller
	signal tmp_sdram_addr_in	: STD_LOGIC_VECTOR(15 downto 0);
	signal tmp_sdram_wr_en		: STD_LOGIC;
	signal tmp_sdram_memstrb	: STD_LOGIC;
	signal tmp_sdram_d_in		: STD_LOGIC_VECTOR(7 downto 0);
	
	-- Signals from SDRAM Controller to Cache
	signal tmp_cache_sdram_mux_in		:STD_LOGIC_VECTOR(7 downto 0);

begin
	
	-- Instantiating the CPU
	CPU_gen: entity work.CPU_gen PORT MAP(
		clk => clk,
		rst => reset,
		trig => tmp_cpu_rdy,
		Address => tmp_cache_addr_in,
		wr_rd => tmp_cache_wr_en,
		cs => tmp_cache_cs,
		DOut => tmp_cache_mux_in
	);
	
	-- Instantiating the Cache
	Cache: entity work.Cache PORT MAP(
		clk => clk,
		reset => reset,
		cs => tmp_cache_cs,
		cpu_wr_en => tmp_cache_wr_en,
		addr_in => tmp_cache_addr_in,
		cpu_d_in => tmp_cache_mux_in,
		sdram_d_in => tmp_cache_sdram_mux_in,
		cpu_d_out => tmp_cpu_d_in,
		sdram_d_out => tmp_sdram_d_in,
		addr_out => tmp_sdram_addr_in,
		wr_en => tmp_sdram_wr_en,
		mem_strb => tmp_sdram_memstrb,
		rdy => tmp_cpu_rdy
	);
	
	-- Instantiating the SDRAMController
	SDRAMController: entity work.SDRAMController PORT MAP(
		clk => clk,
		reset => reset,
		mem_strb => tmp_sdram_memstrb,
		wr_en => tmp_sdram_wr_en,
		addr_in => tmp_sdram_addr_in,
		d_in => tmp_sdram_d_in,
		d_out => tmp_cache_sdram_mux_in
	);

end Behavioral;
