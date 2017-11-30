----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:48:17 11/16/2015 
-- Design Name: 
-- Module Name:    Controller - Behavioral 
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

entity Controller is
	port(	commandIn : in std_logic_vector(15 downto 0);
			rst : in std_logic;
			imm : out std_logic_vector(2 downto 0);
			controllerOut :  out std_logic_vector(20 downto 0) 
			-- RegWrite(1)	SpeReg(2) RegDst(3) Asrc(3) Bsrc(2) ALUOP(4) 
			-- MemRead(1) MemWrite(1) MemToReg(1)  branch(1) jump(1) dataSrc(1)
			);
end Controller;

architecture Behavioral of Controller is
--signal tmp : std_logic_vector(20 downto 0);
begin
	process(rst, commandIn)
	begin
		if rst = '0' then
			controllerOut <= (others => '0');
			imm <= (others => '0');
		else
			case commandIn(15 downto 11) is
				when "11101" =>
					
					case commandIn(4 downto 0) is
						when "01100" =>--AND
							imm <= "000";
							controllerOut <= "100001001100010000000";
						when "01010" =>--CMP 
							imm <= "000";
							controllerOut <= "100110001101101000000";
						when "00000" =>
							if (commandIn(7 downto 0) = "00000000") then --JR
								imm <= "000";
								controllerOut <= "000000000001111000110";
							elsif (commandIn(7 downto 0) = "01000000") then--MFPC
								imm <= "000";
								controllerOut <= "100001101000000000000";
							end if;
						when "01101" => --OR
							imm <= "000";
							controllerOut <= "100001001100011000000";
						when "00100" => --SLLV
							imm <= "000";
							controllerOut <= "100010010010110000000";
						when "00111" => --SRAV
							imm <= "000";
							controllerOut <= "100010010011100000000";
						when others =>--error	
					end case;
				when "01001" => --ADDIU
					imm <= "111";
					controllerOut <= "100001001110000000000";
				when "01000" => --ADDIU3
					imm <= "101";
					controllerOut <= "100010001110000000000";
				when "01100" =>
					case commandIn(10 downto 8) is 
						when "011" => --ADDSP
							imm <= "111";
							controllerOut <= "101100011110000000000";
						when "000" => --BTEQZ
							imm <= "111";
							controllerOut <= "011000110000001000100";
						when "100" => --MTSP
							imm <= "000";
							controllerOut <= "100100010000000000000";
						when others => --error
					end case;
				when "00010" => --B
					imm <= "001";
					controllerOut <= "000000000001111000100";
				when "11100" =>
					if (commandIn(1 downto 0) = "01") then--ADDU
						imm <= "000";
						controllerOut <= "100011001100000000000";
					elsif (commandIn(1 downto 0) = "11") then --SUBU
						imm <= "000";
						controllerOut <= "100011001100001000000";
					end if;
				when "00100" => --BEQZ
					imm <= "111";
					controllerOut <= "000000001000001000100";
				when "00101" => --BNEZ
					imm <= "111";
					controllerOut <= "000000001001001000100";
				when "01101" => --LI
					imm <= "011";
					controllerOut <= "100001111000000000000";
				when "10011" => --LW
					imm <= "110";
					controllerOut <= "100010001110000101000";
				when "10010" => --LW_SP
					imm <= "111";
					controllerOut <= "101001011110000101000";
				when "11110" =>
					if (commandIn(0) = '0') then --MFIH
						imm <= "000";
						controllerOut <= "110001100000000000000";
					else --MTIH
						imm <= "000";
						controllerOut <= "100101001000000000000";
					end if;
				when "00110" =>
					if (commandIn(1 downto 0) = "00") then --SLL
						imm <= "100";
						controllerOut <= "100001010110111000000";
					elsif (commandIn(1 downto 0) = "11") then --SRA
						imm <= "100";
						controllerOut <= "100001010111000000000";
					end if;
				when "11011" => --SW
					imm <= "110";
					controllerOut <= "000000001110000010001";
				when "11010" => --SW_SP
					imm <= "111";
					controllerOut <= "001000011110000010000";
				when "01110" => --CMPI
					imm <= "111";
					controllerOut <= "100110001111010000000";
				when "01111" => --MOVE
					imm <= "000";
					controllerOut <= "100001010000000000000";
				when "01011" => --SLTI
					imm <= "011";
					controllerOut <= "100110001111011000000"; 
				when others => --error or NOP
					imm <= "000";
					controllerOut <= "000000000001111000000";
			end case;
		end if;
	end process;
end Behavioral;

