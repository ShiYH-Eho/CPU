library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AMux is
	port(
			forwardA : in std_logic_vector(1 downto 0);
			forwardB : in std_logic_vector(1 downto 0);
			ASrc : in std_logic_vector(2 downto 0);
			
			dataA : in std_logic_vector(15 downto 0);
			dataB : in std_logic_vector(15 downto 0);
			dataT : in std_logic_vector(15 downto 0);
			dataIH : in std_logic_vector(15 downto 0);
			dataSP : in std_logic_vector(15 downto 0);
			PCIn : in std_logic_vector(15 downto 0);
			imm : in std_logic_vector(15 downto 0);
			
			dataEx : in std_logic_vector(15 downto 0);
			dataMem : in std_logic_vector(15 downto 0);
			
			AsrcOut : out std_logic_vector(15 downto 0)
	);
end AMux;

architecture Behavioral of AMux is

begin
--	process
--	begin
--		case forwardA is
--			when "00" =>--from registers
--				case ASrc is 
--					when "000" =>
--						AsrcOut <= (others => '0');
--					when "001" => --rx
--						AsrcOut <= dataA;
--					when "010" => --ry
--						AsrcOut <= dataB;
--					when "011" => --SP
--						AsrcOut <= dataSP;
--					when "100" => --IH
--						AsrcOut <= dataIH;
--					when "101" => --PC
--						AsrcOut <= PCIn;
--					when "110" => --T
--						AsrcOut <= dataT;
--					when "111" => --IMM
--						AsrcOut <= imm;
--					when others =>
--				end case;
--			when "01" =>--from last Ex
--				AsrcOut <= dataEx;
--			when "11" =>--from last last Mem
--				AsrcOut <= dataMem;
--			when others =>
--		end case;
--	end process;
	process
	begin
		case ASrc is 
			when "000" => 
				AsrcOut <= (others => '0');
			when "001" => --rx
				case forwardA is 
					when "00" => --from regs
						AsrcOut <= dataA;
					when "10" => --from last Ex
						AsrcOut <= dataEx;
					when "01" => --from last last Mem
						AsrcOut <= dataMem;
					when others =>
				end case;
			when "010" => -- ry
				case forwardB is 
					when "00" =>
						AsrcOut <= dataB;
					when "10" => 
						AsrcOut <= dataEx;
					when "01" =>
						AsrcOut <= dataMem;
					when others=>
				end case;
			when "111" => --imm
				AsrcOut <= imm;
			when others =>
				case forwardA is 
					when "00" =>
						case ASrc is 
							when "011" => 
								AsrcOut <= dataSP;
							when "100" =>
								AsrcOut <= dataIH;
							when "101" => 
								AsrcOut <= PCIn;
							when "110" => 
								AsrcOut <= dataT;
							when others => 
						end case;
					when "10" =>
						AsrcOut <= dataEx;
					when "01" =>
						AsrcOut <= dataMem;
					when others =>
				end case;
		end case;
	end process;
end Behavioral;

