----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:25:41 10/23/2020 
-- Design Name: 
-- Module Name:    d_out_mux - Behavioral 
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

entity d_out_mux is
    Port ( selector 	: in  STD_LOGIC;
			  d_in 		: in  STD_LOGIC_VECTOR (7 downto 0);
           d_out_0 	: out  STD_LOGIC_VECTOR (7 downto 0);
           d_out_1 	: out  STD_LOGIC_VECTOR (7 downto 0)
			 );
end d_out_mux;

architecture Behavioral of d_out_mux is

begin


end Behavioral;
