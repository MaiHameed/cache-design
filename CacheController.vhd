----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:45:18 10/20/2020 
-- Design Name: 
-- Module Name:    CacheController - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CacheController is
    Port ( 	clk 				: in  STD_LOGIC;
				reset				: in 	STD_LOGIC;
				cs 				: in 	STD_LOGIC;
				cpu_wr_en		: in 	STD_LOGIC;
				addr_in			: in	STD_LOGIC_VECTOR (15 downto 0);
				addr_out_16 	: out	STD_LOGIC_VECTOR (15 downto 0);
				addr_out_8		: out STD_LOGIC_VECTOR (7 downto 0);
				sdram_wr_en		: out STD_LOGIC;
				sram_wr_en		: out STD_LOGIC;
				mem_strb 		: out STD_LOGIC;
				d_in_selector	: out STD_LOGIC;
				d_out_selector	: out STD_LOGIC;
				rdy 				: out STD_LOGIC);
end CacheController;

architecture Behavioral of CacheController is
	
	-- States
	-- 0: 000: Idle state
	-- 1: 001: Write a word to cache from CPU [hit]
	-- 2: 010: Read a word from cache to CPU [hit]
	-- 3: 011: [miss] and dirty bit (d_bit) is 1 - perform block replacement + run state 4
	-- 4: 100: [miss] and dirty bit (d_bit) is 0 - read in from SDRAM (main memory) to SRAM 
	--																+ run state 1 or 2 based on the CPU instruction
	-- 5: 101: When cs is triggered, check if hit or miss
	
	signal state		: STD_LOGIC_VECTOR(2 downto 0) 	:= "000";
	
	-- Address word register
	signal cpu_tag		: STD_LOGIC_VECTOR(7 downto 0) 	:= "00000000";
	signal cpu_index	: STD_LOGIC_VECTOR(2 downto 0) 	:= "000";
	signal cpu_offset	: STD_LOGIC_VECTOR(4 downto 0) 	:= "00000";
	
	signal vbit 		: STD_LOGIC_VECTOR(7 downto 0) 	:= "00000000"; -- Represents array of vbits (valid bits), 1 per block (total 8 blocks)
	signal dbit 		: STD_LOGIC_VECTOR(7 downto 0) 	:= "00000000"; -- Dirty bit(s)
	
	-- Build the tag register block, 8 addresses of  8 bit tags will be stored
	type typeRAM is array (7 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
	signal memTAG : typeRAM := ((others => (others => '0')));
	
begin
	process(clk)
	
	-- To loop from 0-31 to load/read/write each element in a whole block
	VARIABLE counter : integer := 0;
	
	begin
		if (clk'EVENT and clk='1') then
			case state is
				when "000" => -- IDLE
					rdy 			<= '1';
					sdram_wr_en <= '0';
					sram_wr_en 	<= '0';
					
					-- Set next state
					if (cs = '1') then
						-- CPU strobed, meaning an instruction is coming in
						
						-- Save the CPU address into it's parts for reference
						cpu_tag 		<= addr_in(15 downto 8);
						cpu_index 	<= addr_in(7 downto 5);
						cpu_offset 	<= addr_in(4 downto 0);  				
						
						state <= "101";
					end if;
				when "001" => -- WRITE WORD TO CACHE FROM CPU
					sram_wr_en 								<= '1';
					sdram_wr_en								<= '0';
					addr_out_8(7 downto 5)				<= cpu_index(2 downto 0);
					addr_out_8(4 downto 0)  			<= cpu_offset(4 downto 0);
					d_in_selector							<= '0';
					dbit(to_integer(unsigned(cpu_index))) 	<= '1';
					
					state <= "000";
				when "010" => -- READ WORD TO CPU FROM CACHE
					sdram_wr_en					<= '0';
					sram_wr_en					<= '0';
					addr_out_8(7 downto 5)	<= cpu_index(2 downto 0);
					addr_out_8(4 downto 0)  <= cpu_offset(4 downto 0);
					d_out_selector				<= '1';
					
					state <= "000";
				when "011" => -- BLOCK REPLACEMENT, THEN STATE 4 (LOAD BLOCK FROM MAIN MEMORY)
					vbit(to_integer(unsigned(cpu_index))) 	<= '0';
					
					state <= "100";
				when "100" => -- LOAD BLOCK FROM MAIN MEMORY
					vbit(to_integer(unsigned(cpu_index))) 	<= '0';
					d_in_selector	<= '1';
					sdram_wr_en		<= '0';
					mem_strb			<= '1';
					sram_wr_en		<= '1';	
					
					-- Load 1 block, one word at a time
					-- Sets the address of the main memory to the block location with offset from 0-31 to grab whole block
					addr_out_16(15 downto 8)	<= cpu_tag(7 downto 0);
					addr_out_16(7 downto 5)		<= cpu_index(2 downto 0);
					addr_out_16(4 downto 0)		<= STD_LOGIC_VECTOR(to_unsigned(counter, 5));
					-- Sets the address of the SRAM to the index location to write in the data from main memory
					addr_out_8(7 downto 5)		<= cpu_index(2 downto 0);
					addr_out_8(4 downto 0)		<= STD_LOGIC_VECTOR(to_unsigned(counter, 5));
					
					-- Countes up one to load the next word on next clock cycle
					counter := counter + 1;
					if(counter = 32) then
						counter := 0;
						mem_strb			<= '0';
						sram_wr_en		<= '0';
						memTAG(to_integer(unsigned(cpu_index)))	<= cpu_tag(7 downto 0);
						vbit(to_integer(unsigned(cpu_index))) 		<= '1';			
						if (cpu_wr_en = '1') then
							state <= "001";
						else
							state <= "010";
						end if;
					end if;
				when "101" => -- CHECK CPU INSTRUCTION
					rdy	<= '0';
					sdram_wr_en	<= '0';
					sram_wr_en	<= '0';
					
					-- Check if it's a HIT or MISS
					-- Check to see if it's a hit or miss by going to the tag memory block at address [cpu_index]
					--   and comparing it with the [cpu_tag] to see if they match
					if (memTAG(to_integer(unsigned(cpu_index))) = cpu_tag) then
						-- HIT
						-- Check if it's a write or read instruction
						if (cpu_wr_en = '1') then
							-- HIT-WRITE instruction
							state <= "001";
						else
							-- HIT-READ instruction
							-- Check if v-bit = 1
							if (vbit(to_integer(unsigned(cpu_index))) = '1') then
								-- Valid data was found in cache, it's a READ-HIT-VALID instruction
								state <= "010";
							else
								-- Valid data not found in cache, need to read in from main memory
								-- Check if d-bit = 1, aka if we need to perform a block replacement
								if (dbit(to_integer(unsigned(cpu_index))) = '1') then
									-- Perform block replacement, then read in cpu address memory block from main memory
									state <= "011";
								else
									-- No block replacement, just read in cpu address memory block from main memory
									state <= "100";
								end if;
							end if;
						end if;
					else
						-- MISS, need to read in from the main memory to cache
						-- Check if d-bit = 1 to see if cache needs to perform block replacement (write to main mem from cache)
						if (dbit(to_integer(unsigned(cpu_index))) = '1') then
							-- Perform block replacement, then read in cpu address memory block from main memory
							state <= "011";
						else
							-- No block replacement, just read in cpu address memory block from main memory
							state <= "100";
						end if;
					end if;
				when others =>
			end case;
		end if;
	end process;
	
end Behavioral;
