library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IdExRegisters is
	port(
			clk : in std_logic;
			rst : in std_logic;
			
			IdExFlush : in std_logic;

			PCIn : in std_logic_vector(15 downto 0);
			rdIn : in std_logic_vector(3 downto 0);
			rxIn : in std_logic_vector(2 downto 0);
			ryIn : in std_logic_vector(2 downto 0);
			ASrcIn : in std_logic_vector(2 downto 0);
			BSrcIn : in std_logic_vector(1 downto 0);
			
			dataAIn : in std_logic_vector(15 downto 0);
			dataBIn : in std_logic_vector(15 downto 0);			
			dataTIn : in std_logic_vector(15 downto 0);
			dataIHIn : in std_logic_vector(15 downto 0);
			dataSPIn : in std_logic_vector(15 downto 0);
			immIn : in std_logic_vector(15 downto 0);
			
			WriteKeep : in std_logic;
			
			WBIn : in std_logic;
			memWriteIn : in std_logic;
			memReadIn : in std_logic;
			memToRegIn : in std_logic;
			branchIn : in std_logic;
			jumpIn : in std_logic;
			ALUOpIn : in std_logic_vector(3 downto 0);
			dataSrcIn : in std_logic;
		
			PCOut : out std_logic_vector(15 downto 0);
			rdOut : out std_logic_vector(3 downto 0);
			rxOut : out std_logic_vector(2 downto 0);
			ryOut : out std_logic_vector(2 downto 0);
			ASrcOut : out std_logic_vector(2 downto 0);
			BSrcOut : out std_logic_vector(1 downto 0);
			
			dataAOut : out std_logic_vector(15 downto 0);
			dataBOut : out std_logic_vector(15 downto 0);			
			dataTOut : out std_logic_vector(15 downto 0);
			dataIHOut : out std_logic_vector(15 downto 0);
			dataSPOut : out std_logic_vector(15 downto 0);
			immOut : out std_logic_vector(15 downto 0);
			
			WBOut : out std_logic;
			memWriteOut : out std_logic;
			memReadOut : out std_logic;
			memToRegOut : out std_logic;
			branchOut : out std_logic;
			jumpOut : out std_logic;
			ALUOpOut : out std_logic_vector(3 downto 0);
			dataSrcOut : out std_logic
	);
end IdExRegisters;

architecture Behavioral of IdExRegisters is
begin
	process(clk, rst,IdExFlush)
	begin		
		if (rst = '1' or IdExFlush = '1') then
			PCOut <= (others => '0');
			rdOut <= (others => '0');
			rxOut <= (others => '0');
			ryOut <= (others => '0');
			ASrcOut <= (others => '0');
			BSrcOut <= (others => '0');
			
			dataAOut <= (others => '0');
			dataBOut <= (others => '0');
			dataTOut <= (others => '0');
			dataIHOut <= (others => '0');
			dataSPOut <= (others => '0');
			immOut <= (others => '0');
			
			WBOut <= '0';
			memWriteOut <= '0';
			memReadOut <= '0';
			memToRegOut <= '0';
			branchout <= '0';
			jumpOut <= '0';
			ALUOpOut <= "0000";
			dataSrcOut <= '0';
		elsif (clk'event and clk = '1') then
			if (IdExFlush = '0') then 
				PCOut <= PCIn;
				rdOut <= rdIn;
				rxOut <= rxIn;
				ryOut <= ryIn;
				ASrcOut <= ASrcIn;
				BSrcOut <= BSrcIn;
				
				dataAOut <= dataAIn;
				dataBOut <= dataBIn;
				dataTOut <= dataTIn;
				dataIHOut <= dataIHIn;
				dataSPOut <= dataSPIn;
				immOut <= immIn;
				
				if (WriteKeep = '1') then 
					WBOut <= '0';
					memWriteOut <= '0';
				else 
					WBOut <= WBIn;
					memWriteOut <= memWriteIn;
				end if;
				memReadOut <= memReadIn;
				memToRegOut <= memToRegIn;
				jumpOut <= jumpIn;
				branchOut <= branchIn;
				ALUOpOut <= ALUOpIn;		
				dataSrcOut <= dataSrcIn;
			else 
				PCOut <= (others => '0');
				rdOut <= (others => '0');
				rxOut <= (others => '0');
				ryOut <= (others => '1');
				ASrcOut <= (others => '0');
				BSrcOut <= (others => '0');
				
				dataAOut <= (others => '0');
				dataBOut <= (others => '0');
				dataTOut <= (others => '0');
				dataIHOut <= (others => '0');
				dataSPOut <= (others => '0');
				immOut <= (others => '0');
				
				WBOut <= '0';
				memWriteOut <= '0';
				memReadOut <= '0';
				memToRegOut <= '0';
				branchout <= '0';
				jumpOut <= '0';
				ALUOpOut <= "0000";
				dataSrcOut <= '0';
			end if;
		end if;
	end process;
end Behavioral;

