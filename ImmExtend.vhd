library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
		case immSele(2) is
			when '0' => -- zero
				sign := '0';
			when '1' => -- sign
				case immSele(1 downto 0) is
					when "00" => -- 3-0
						sign := immIn(3);
					when "01" => -- 4-0
						sign := immIn(4);
					when "10" => -- 7-0
						sign := immIn(7);
					when "11" => -- 10-0
						sign := immIn(10);
					when others =>
				end case ;
			when others =>
		end case;
		tmpOut := (others => sign);
		
		case immSele(2) is
			when '0' => -- zero
				case immSele(1 downto 0) is
					when "01" => -- 4-2
						immOut <= tmpOut(15 downto 3) & immIn(4 downto 2);
					when "10" => -- 7-0
						immOut <= tmpOut(15 downto 8) & immIn(7 downto 0);
					when others =>
				end case ;
			when '1' => -- sign
				case immSele(1 downto 0) is
					when "00" => -- 3-0
					   immOut <= tmpOut(15 downto 4) & immIn(3 downto 0);
					when "01" => -- 4-0
					   immOut <= tmpOut(15 downto 5) & immIn(4 downto 0);
					when "10" => -- 7-0
						immOut <= tmpOut(15 downto 8) & immIn(7 downto 0);
					when "11" => -- 10-0
						immOut <= tmpOut(15 downto 11) & immIn(10 downto 0);
					when others =>
				end case;
			when others =>	
		end case;
	end process;
end Behavioral;

