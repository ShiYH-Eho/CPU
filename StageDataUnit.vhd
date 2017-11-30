----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:23:07 11/26/2015 
-- Design Name: 
-- Module Name:    StageDataUnit - Behavioral 
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

entity StageDataUnit is
	port(
			rst : in std_logic;
			
			dataAIn : in std_logic_vector(15 downto 0);
			dataBIn : in std_logic_vector(15 downto 0);
			
			forwardA : in std_logic_vector(1 downto 0);
			forwardB : in std_logic_vector(1 downto 0);
			
			dataEx : in std_logic_vector(15 downto 0);
			dataMem : in std_logic_vector(15 downto 0);
			
			dataAOut : out std_logic_vector(15 downto 0);
			dataBOut : out std_logic_vector(15 downto 0)
	);
end StageDataUnit;

architecture Behavioral of StageDataUnit is

begin
	process (rst)
	begin 
	--if (rst = '1') then
		--dataAOut <= (others => '0');
		--dataBOut <= (others => '0');
	--else 
		case forwardA is 
			when "00" => --regs
				dataAOut <= dataAIn;
			when "10" => 
				dataAOut <= dataEx;
			when "01" => 
				dataAOut <= dataMem;
			when others =>
		end case;
		
		case forwardB is 
			when "00" =>
				dataBOut <= dataBIn;
			when "10" => 
				dataBOut <= dataEx;
			when "01" => 
				dataBOut <= dataMem;
			when others =>
		end case;
		
		--dataAOut <= dataAIn;
		--dataBOut <= dataBIn;
	--end if;
	end process;
	
end Behavioral;

