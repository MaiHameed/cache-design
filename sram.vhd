----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:29:29 11/06/2020 
-- Design Name: 
-- Module Name:    sram - Behavioral 
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

entity sram is
    Port ( clk : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (7 downto 0);
           d_in : in  STD_LOGIC_VECTOR (7 downto 0);
           d_out : out  STD_LOGIC_VECTOR (7 downto 0);
           wr_en : in  STD_LOGIC);
end sram;

architecture Behavioral of sram is

	type ram_type is array (7 downto 0, 31 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
	signal SRAM: ram_type;
	signal initializer : integer := 0;

begin

process (CLK)
begin
	if (CLK'event and CLK = '1') then
		
		if initializer = 0 then
			for I in 0 to 7 loop
				for J in 0 to 31 loop
					SRAM(i,j) <= "00000000";
				end loop;
			end loop;
			initializer <= 1;
		end if;
			
		
		if (wr_en = '1') then
			SRAM(to_integer(unsigned(addr(7 downto 5))), to_integer(unsigned(addr(4 downto 0)))) <= d_in;    
		else
			d_out <= SRAM(to_integer(unsigned(addr(7 downto 5))), to_integer(unsigned(addr(4 downto 0))));
		end if; 
		
	end if;
end process;
end Behavioral;
