----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:18:15 11/22/2015 
-- Design Name: 
-- Module Name:    BMux - Behavioral 
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

entity BMux is
	port(
			forwardA : in std_logic_vector(1 downto 0);
			forwardB : in std_logic_vector(1 downto 0);
			BSrc : in std_logic_vector(1 downto 0);
			
			dataA : in std_logic_vector(15 downto 0);
			dataB : in std_logic_vector(15 downto 0);
			imm : in std_logic_vector(15 downto 0);
			
			dataEx : in std_logic_vector(15 downto 0);
			dataMem : in std_logic_vector(15 downto 0);
			
			BsrcOut : out std_logic_vector(15 downto 0)
	);	
end BMux;

architecture Behavioral of BMux is
	
begin
	process
	begin 
		case BSrc is 
			when "00" => 
				BsrcOut <= (others => '0');
			when "01" => --rx
				case forwardA is 
					when "00" => --from regs 
						BsrcOut <= dataA;
					when "10" => --from last ex
						BsrcOut <= dataEx;
					when "01" => --from last last mem
						BsrcOut <= dataMem;
					when others =>
				end case;
			when  "10" => --ry
				case forwardB is 
					when "00" =>
						BsrcOut <= dataB;
					when  "10" => 
						BsrcOut <= dataEx;
					when "01" =>
						BsrcOut <= dataMem;
					when others => 
				end case ;
			when "11" =>
				BsrcOut <= imm;
			when others => --error
		end case;
	end process;
--	process 
--	begin 
--		case forwardB is 
--			when "00" => --registers
--				case BSrc is
--					when "00" => 
--						BSrcOut <= (others => '0');
--					when "01" => 
--						BSrcOut <= dataA;
--					when "10" =>
--						BSrcOut <= dataB;
--					when "11" => 
--						BSrcOut <= imm;
--					when others =>
--				end case;
--			when "01" => --last Ex
--				BSrcOut <= dataEx;
--			when "11" => --last last Mem
--				BSrcOut <= dataMem;
--			when others => --error
--		end case;
--	end process;
end Behavioral;

