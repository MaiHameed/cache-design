----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:15:19 10/23/2020 
-- Design Name: 
-- Module Name:    d_in_mux - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity d_in_mux is
	Port ( selector 	: in  	STD_LOGIC;
           d_in_0 	: in  	STD_LOGIC_VECTOR (7 downto 0);
           d_in_1 	: in  	STD_LOGIC_VECTOR (7 downto 0);
           d_out 		: out  	STD_LOGIC_VECTOR (7 downto 0)
	);
end d_in_mux;

architecture Behavioral of d_in_mux is

begin
	d_out <= d_in_0 when selector = '0' else d_in_1;
end Behavioral;
