library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
		if (rst = '1') then
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

