----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:01:58 11/22/2015 
-- Design Name: 
-- Module Name:    ExMemRegisters - Behavioral 
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
		if (rst = '0') then
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
		elsif (clk'event and clk = '1') then
			rdOut <= rdIn;
			PCOut <= PCIn;
			ansOut <= ansIn;
			branchOut <= branchIn;
		
			memReadOut <= memReadIn;
			memToRegOut <= memToRegIn;
			
			if (wbkeep = '1' ) then
				WbOut <= '0';
				branchJudgeOut <= '0';
				memWriteOut <= '0';
			else 
				branchJudgeOut <= branchJudgeIn;
				memWriteOut <= memWriteIn;
				WBOut <= WBIn;
			end if;
			if (dataSrcIn = '1') then
				dataOut <= dataBIn;
			else 
				dataOut <= dataAIn;
			end if;
		end if;
	end process;
			

end Behavioral;

