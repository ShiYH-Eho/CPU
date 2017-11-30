----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:28:16 11/15/2015 
-- Design Name: 
-- Module Name:    PCMux - Behavioral 
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

entity PCMux is
	port( branch : in std_logic;
			branchJudge : in std_logic;
			PCAdd : in std_logic_vector(15 downto 0);
			PCJump : in std_logic_vector(15 downto 0);
			
			PCNext : out std_logic_vector(15 downto 0)
			);
end PCMux;

architecture Behavioral of PCMux is
begin
	process(branch, branchJudge, PCAdd, PCJump)
	begin 
		if (branch = '0' or branchJudge = '0') then
			PCNext <= PCAdd;
		else
			PCNext <= PCJump;
		end if;
		--if (branch = '1') then 
		--	PCNext <= PCJump;
		--else PcNext <= PcAdd;
		--end if;
	end process;

end Behavioral;

