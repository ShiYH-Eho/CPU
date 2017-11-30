----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:59:43 11/22/2015 
-- Design Name: 
-- Module Name:    MemWbRegisters - Behavioral 
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

entity MemWbRegisters is
	port(
			clk : in std_logic;
			rst : in std_logic;
			
			dataIn : in std_logic_vector(15 downto 0);
			ansIn : in std_logic_vector(15 downto 0);
			rdIn : in std_logic_vector(3 downto 0);
			
			WBIn : in std_logic;
			memToReg : in std_logic;
			
			rdOut : out std_logic_vector(3 downto 0);
			WBOut : out std_logic;
			dataToWB : out std_logic_vector(15 downto 0)
	);
end MemWbRegisters;

architecture Behavioral of MemWbRegisters is

begin
	process(clk, rst)
	begin
		if (rst = '0') then
			WBOut <= '0';
			rdOut <= (others => '0');
			dataToWB <= (others => '0');
		elsif (clk'event and clk = '1') then
			rdOut <= rdIn;
			WBOut <= WBIn;
			
			if (memToReg = '1') then
				dataToWB <= dataIn;
			else 
				dataToWB <= ansIn;
			end if;
		end if;
	end process;

end Behavioral;

