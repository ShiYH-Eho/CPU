library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ConflictController is
	port(
			rst : in std_logic;
			clk : in std_logic;
			
			branch : in std_logic;
			branchJudge : in std_logic;
			jump : in std_logic;
			
			IdExMemRead : in std_logic;
			IdExRd : in std_logic_vector(3 downto 0);
			
			IfIdRx : in std_logic_vector(2 downto 0);
			IfIdRy : in std_logic_vector(2 downto 0);
			IfIdASrc : in std_logic_vector(2 downto 0);
			IfIdBSrc : in std_logic_vector(1 downto 0);
			IfIdMemWrite : in std_logic;
			
			PCKeep : out std_logic;
			IfIdKeep : out std_logic;
			IfIdFlush : out std_logic;
			IdExFlush : out std_logic;
			WriteKeep : out std_logic;
			ExMemFlush : out std_logic
	);
			
end ConflictController;

architecture Behavioral of ConflictController is

begin
process
begin
		if (rst = '1') then 
			PCKeep <= '0';
			IfIdKeep <= '0';
			IfIdFlush <= '0';
			WriteKeep <= '0';
			IdExFlush <= '0';
			ExMemFlush <= '0';
		end if;
			--elsif (clk'event and clk = '1') then
		if (IdExMemRead = '1') then
			if ((IfIdASrc = "001" or IfIdBSrc = "01") and IdExRd = '0' & IfIdRx) then
				PCKeep <= '1';
				IfIdKeep <= '1';
				IfIdFlush <= '0';
				IdExFlush <= '1';
				WriteKeep <= '1';
				ExMemFlush <= '0';
			elsif ((IfIdASrc = "010" or IfIdBSrc = "10") and IdExRd = '0' & IfIdRy) then
				PCKeep <= '1';
				IfIdKeep <= '1';
				IfIdFlush <= '0';
				IdExFlush <= '1';
				WriteKeep <= '1';
				ExMemFlush <= '0';
			--elsif ((IdExRd = '0' & IfIdRy or IdExrd = '0' & IfIdRx) and IfIdMemWrite = '1') then
			--	PCKeep <= '1';
			--	IfIdKeep <= '1';
			--	IfIdFlush <= '0';
			--	IdExFlush <= '1';
			--	WriteKeep <= '1';
			--	ExMemFlush <= '0';
			else 
				PCKeep <= '0';
				IfIdKeep <= '0';
				WriteKeep <= '0';
				IdExFlush <= '0';
				IfIdFlush <= '0';
				ExMemFlush <= '0';
			end if;
		elsif ((branch = '1' and branchJudge = '1' )or (jump = '1')) then 
			PCKeep <= '0';
			IfIdKeep <= '0';
			WriteKeep <= '1';
			IfIdFlush <= '1';
			IdExFlush <= '1';
			ExMemFlush <= '1';
		else 
			PCKeep <= '0';
			IfIdKeep <= '0';
			WriteKeep <= '0';
			IfIdFlush <= '0';
			IdExFlush <= '0';
			ExMemFlush <= '0';
		end if;
end process;
--	end if;
end Behavioral;

