library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PCRegister is
	port(	rst,clk : in std_logic;
			PCKeep : in std_logic;
			PCIn : in std_logic_vector(15 downto 0);
			PCOut : out std_logic_vector(15 downto 0)
			);
end PCRegister;

architecture Behavioral of PCRegister is

begin
	process(clk,rst)
	begin
		if (rst = '1') then 
			PCOut <= "0000000000000001";
		elsif clk'event and clk = '1'then
				if PCKeep = '0' then
					PCOut <= PCIn;
				end if;
		end if;
	end process;
end Behavioral;

