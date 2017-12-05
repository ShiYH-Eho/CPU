library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ExMemRegisters is
	port(
			clk : in std_logic;
			rst : in std_logic;

			dataAIn : in std_logic_vector(15 downto 0);
			dataBIn : in std_logic_vector(15 downto 0);
			rdIn : in std_logic_vector(3 downto 0);
			PCIn : in std_logic_vector(15 downto 0);
			ansIn : in std_logic_vector(15 downto 0);
			branchIn : in std_logic;
			branchJudgeIn : in std_logic;
			jumpIn : in std_logic;
			
			WBIn : in std_logic;
			memReadIn : in std_logic;
			memWriteIn : in std_logic;
			memToRegIn : in std_logic;
			dataSrcIn : in std_logic;

			wbKeep : in std_logic;

			rdOut : out std_logic_vector(3 downto 0);
			PCOut : out std_logic_vector(15 downto 0);
			ansOut : out std_logic_vector(15 downto 0);
			branchOut : out std_logic;
			branchJudgeOut : out std_logic;
			jumpOut : out std_logic;
			
			WBOut : out std_logic;
			memReadOut : out std_logic;
			memWriteOut : out std_logic;
			memToRegOut : out std_logic;
			dataOut : out std_logic_vector(15 downto 0)
	);
end ExMemRegisters;

architecture Behavioral of ExMemRegisters is

begin
	process(rst,clk)
	begin
		if (rst = '1') then
			rdOut <= (others => '0');
			PCOut <= (others => '0');
			ansOut <= (others => '0');
			branchOut <= '0';
			branchJudgeOut <= '0';
			WBOut <= '0';
			memReadOut <= '0';
			memWriteOut <= '0';
			memToRegOut <= '0';
			dataOut <= (others => '0');
			jumpOut <= '0';
		elsif (clk'event and clk = '1') then
			if (wbkeep = '0') then
				rdOut <= rdIn;
				PCOut <= PCIn;
				ansOut <= ansIn;
				branchOut <= branchIn;
				memReadOut <= memReadIn;
				memToRegOut <= memToRegIn;
				
				if (dataSrcIn = '1') then
					dataOut <= dataBIn;
				else 
					dataOut <= dataAIn;
				end if;
				
				branchJudgeOut <= branchJudgeIn;
				memWriteOut <= memWriteIn;
				WBOut <= WBIn;
				jumpOut <= jumpIn;
			else
				rdOut <= (others => '0');
				PCOut <= (others => '0');
				ansOut <= (others => '0');
				branchOut <= '0';
				branchJudgeOut <= '0';
				WBOut <= '0';
				memReadOut <= '0';
				memWriteOut <= '0';
				memToRegOut <= '0';
				dataOut <= (others => '0');
				jumpOut <= '0';
			end if;
		end if;
	end process;
			

end Behavioral;

