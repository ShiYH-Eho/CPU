----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:03:37 11/20/2015 
-- Design Name: 
-- Module Name:    ImmExtend - Behavioral 
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

entity ImmExtend is
	port(
			 immIn : in std_logic_vector(10 downto 0);
			 immSele : in std_logic_vector(2 downto 0);
			 
			 immOut : out std_logic_vector(15 downto 0)
		);
end ImmExtend;
architecture Behavioral of ImmExtend is
	shared variable sign : std_logic;
	shared variable tmpOut : std_logic_vector(15 downto 0);
begin
	process(immIn, immSele)
	begin
		case immSele is
			when "001" => sign := immIn(10);--sign extend 10-0
			when "100" => sign := '0';--zero extend 4-2
			when others =>
				if (immSele(2) = '1') then
					case immSele(1 downto 0) is
						when "11" => --7-0
							sign := immIn(7);
						when "10" => --4-0
							sign := immIn(4);
						when "01" => --3-0
							sign := immIn(3);
						when "00" => --4-2
							sign := immIn(4);
						when others =>
					end case;
				else
					sign := '0'; --zero extend
				end if;
		end case;
		tmpOut := (others => sign);
		
		case immSele is
			when "001" =>
				immOut <= tmpOut(15 downto 11) & immIn(10 downto 0);
			when "100" =>
				immOut <= tmpOut(15 downto 3) & immIn(4 downto 2);
			when others =>
				case immSele(1 downto 0) is
					when "11" =>
						immOut <= tmpOut(15 downto 8) & immIn(7 downto 0);
					when "10" =>
						immOut <= tmpOut(15 downto 5) & immIn(4 downto 0);
					when "01" =>
						immOut <= tmpOut(15 downto 4) & immIn(3 downto 0);
					when "00" =>
						immOut <= tmpOut(15 downto 3) & immIn(4 downto 2);
					when others =>
				end case;
		end case;
	end process;
end Behavioral;

