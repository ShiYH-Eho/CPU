library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ConflictController is
	port(
			rst : in std_logic;
			
			IdExMemRead : in std_logic;
			IdExRd : in std_logic_vector(3 downto 0);
			
			IfIdRx : in std_logic_vector(2 downto 0);
			IfIdRy : in std_logic_vector(2 downto 0);
			IfIdASrc : in std_logic_vector(2 downto 0);
			IfIdBSrc : in std_logic_vector(1 downto 0);
			
			PCKeep : out std_logic;
			IfIdKeep : out std_logic;
			WriteKeep : out std_logic
	);
			
end ConflictController;

architecture Behavioral of ConflictController is

begin
	process(rst)
	begin 
		if (rst = '1') then 
			PCKeep <= '0';
			IfIdKeep <= '0';
			WriteKeep <= '0';
		elsif (IdExMemRead = '1') then
			if ((IfIdASrc = "001" or IfIdBSrc = "01") and IdExRd = '0' & IfIdRx) then
				PCKeep <= '1';
				IfIdKeep <= '1';
				WriteKeep <= '1';
			elsif ((IfIdASrc = "010" or IfIdBSrc = "10") and IdExRd = '0' & IfIdRy) then
				PCKeep <= '1';
				IfIdKeep <= '1';
				WriteKeep <= '1';
			else 
				PCKeep <= '0';
				IfIdKeep <= '0';
				WriteKeep <= '0';
			end if;
		else 
			PCKeep <= '0';
			IfIdKeep <= '0';
			WriteKeep <= '0';
		end if;
	end process;
end Behavioral;

