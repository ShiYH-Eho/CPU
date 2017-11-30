----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:23:57 11/23/2015 
-- Design Name: 
-- Module Name:    ConflictController - Behavioral 
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

entity ConflictController is
	port(
			rst : in std_logic;
			clk : in std_logic;
			
			branch : in std_logic;
			branchJudge : in std_logic;
			
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
	process(rst)
	begin 
		if (rst = '0') then 
			PCKeep <= '0';
			IfIdKeep <= '0';
			IfIdFlush <= '0';
			WriteKeep <= '0';
			IdExFlush <= '0';
			ExMemFlush <= '0';
		elsif (clk'event and clk = '0') then
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
			elsif ((IdExRd = '0' & IfIdRy) and IfIdMemWrite = '1') then
				PCKeep <= '1';
				IfIdKeep <= '1';
				IfIdFlush <= '0';
				IdExFlush <= '1';
				WriteKeep <= '1';
				ExMemFlush <= '0';
			else 
				PCKeep <= '0';
				IfIdKeep <= '0';
				WriteKeep <= '0';
				IdExFlush <= '0';
				IfIdFlush <= '0';
				ExMemFlush <= '0';
			end if;
		elsif (branch = '1' and branchJudge = '1') then 
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
	end if;
	end process;
end Behavioral;

