----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:22:12 11/22/2015 
-- Design Name: 
-- Module Name:    ExAdderAndBranchMux - Behavioral 
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
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ExAdderAndBranchMux is
	port(
			PCIn : in std_logic_vector(15 downto 0);
			imm : in std_logic_vector(15 downto 0);
			dataA : in std_logic_vector(15 downto 0);
			
			jump : in std_logic;
			
			PCOut : out std_logic_vector(15 downto 0)
	);
end ExAdderAndBranchMux;

architecture Behavioral of ExAdderAndBranchMux is
	signal tmpPC : std_logic_vector(15 downto 0);
begin
	process(PCIn, imm)
	begin
		tmpPC <= PCIn + imm;
	end process;
	
	process(tmpPC)
	begin
		if (jump = '1') then--choose rx
			PCOut <= dataA ;
			--PCOut <= "0000000000000000";
		else --choose pc + imm 
			PCOut <= tmpPC;
		end if;
	end process;
end Behavioral;

