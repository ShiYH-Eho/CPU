----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:59:09 11/20/2015 
-- Design Name: 
-- Module Name:    RdMux - Behavioral 
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

entity RdMux is
	port(
			rx : in std_logic_vector(2 downto 0);
			ry : in std_logic_vector(2 downto 0);
			rz : in std_logic_vector(2 downto 0);
			
			rdChoose : in std_logic_vector(2 downto 0);
			
			rdOut : out std_logic_vector(3 downto 0)
	);
end RdMux;

architecture Behavioral of RdMux is

begin

	process(rx, ry, rz, rdChoose)
	begin
		case rdChoose is
			when "001" =>--rx
				rdOut <= '0' & rx;
			when "010" =>--ry
				rdOut <= '0' & ry;
			when "011" =>--rz
				rdOut <= '0' & rz;
			when "100" =>--SP
				rdOut <= "1000";
			when "101" =>--IH
				rdOut <= "1001";
			when "110" =>--T
				rdOut <= "1010";
			when others =>
				rdOut <= "1111";
		end case;
	end process;
end Behavioral;

