----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:37:06 11/20/2015 
-- Design Name: 
-- Module Name:    IfIdRegisters - Behavioral 
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

entity IfIdRegisters is
	port(
			rst : in std_logic;
			clk : in std_logic;
			commandIn : in std_logic_vector(15 downto 0);
			PCIn : in std_logic_vector(15 downto 0); 
			IfIdKeep : in std_logic;
			
			rx : out std_logic_vector(2 downto 0);
			ry : out std_logic_vector(2 downto 0);
			rz : out std_logic_vector(2 downto 0);
			imm_10_0 : out std_logic_vector(10 downto 0);
			
			
			commandOut : out std_logic_vector(15 downto 0);
			PCOut : out std_logic_vector(15 downto 0)
			);
end IfIdRegisters;

architecture Behavioral of IfIdRegisters is
	signal tmpRx : std_logic_vector(2 downto 0);
	signal tmpRy : std_logic_vector(2 downto 0);
	signal tmpRz : std_logic_vector(2 downto 0);
	signal tmpImm : std_logic_vector(10 downto 0);
	signal tmpCommand : std_logic_vector(15 downto 0);
	signal tmpPC : std_logic_vector(15 downto 0);
begin

	rx <= tmpRx;
	ry <= tmpRy;
	rz <= tmpRz;
	imm_10_0 <= tmpImm;
	commandOut <= tmpCommand;
	PCOut <= tmpPC;
	process(rst, clk, commandIn, PCIn)
	begin 
		if (rst = '0') then
			tmpRx <= (others => '0');
			tmpRy <= (others => '0');
			tmpRz <= (others => '0');
			tmpImm <= (others => '0');
			tmpCommand <= (others => '0');
			tmpPC <= (others => '0');
		elsif (clk'event and clk = '1' and IfIdKeep = '0')then
			tmpRx <= commandIn(10 downto 8);
			tmpRy <= commandIn(7 downto 5);
			tmpRz <= commandIn(4 downto 2);
			tmpImm <= commandIn(10 downto 0);
			
			tmpCommand<= commandIn;
			tmpPC <= PCIn;
		end if;
	end process;
end Behavioral;

