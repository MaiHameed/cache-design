----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:31:44 10/30/2020 
-- Design Name: 
-- Module Name:    SDRAMController - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SDRAMController is
	Port ( 	clk 				: in  STD_LOGIC;
				reset				: in 	STD_LOGIC;
				mem_strb 		: in 	STD_LOGIC;
				wr_en				: in 	STD_LOGIC;
				addr_in			: in	STD_LOGIC_VECTOR (15 downto 0);
				d_in				: in  STD_LOGIC_VECTOR (7 downto 0);
				d_out				: out STD_LOGIC_VECTOR (7 downto 0));
end SDRAMController;

architecture Behavioral of SDRAMController is

	type ram_type is array (7 downto 0, 31 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
	signal SDRAM: ram_type;

begin

process (CLK)
begin
  if (CLK'event and CLK = '1') then		  
		if (mem_strb = '1') then
			if (wr_en = '1') then
				SDRAM(to_integer(unsigned(addr_in(7 downto 5))), to_integer(unsigned(addr_in(4 downto 0)))) <= d_in;    
			else
				d_out <= SDRAM(to_integer(unsigned(addr_in(7 downto 5))),to_integer(unsigned(addr_in(4 downto 0))));
			end if;
		end if;
  end if;
end process;
end Behavioral;