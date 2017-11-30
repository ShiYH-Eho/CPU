----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:51:23 11/15/2015 
-- Design Name: 
-- Module Name:    PCRegister - Behavioral 
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

entity PCRegister is
	port(	rst,clk : in std_logic;
			PCKeep : in std_logic;
			PCIn : in std_logic_vector(15 downto 0);
			PCOut : out std_logic_vector(15 downto 0)
			);
end PCRegister;

architecture Behavioral of PCRegister is

begin
	process(clk,rst)
	begin
		if (rst = '0') then 
			--PCOut <= "0000000010101100";
			PCOut <= "0000000000000000";
			--PCOut <= "0000000001011101";
			--PCOut <= "0000000001011101";
		elsif clk'event and clk = '1'then
				if PCKeep = '0' then
					PCOut <= PCIn;
				end if;
		end if;
	end process;
end Behavioral;

