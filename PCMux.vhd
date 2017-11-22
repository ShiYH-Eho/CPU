library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

