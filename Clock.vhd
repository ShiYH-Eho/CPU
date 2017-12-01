library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity Clock is
	port(
		rst : in std_logic;
		clkIn : in std_logic;
		clk_2 : out std_logic;
		clk_4 : out std_logic;
		clk_6 : out std_logic
	);
end Clock;

architecture Behavioral of Clock is
	signal cnt6,cnt4,cnt2:natural range 0 to 15;
	signal ck6,ck4,ck2 : std_logic := '1';
begin
	process (clkIn,rst)
		begin
			if (rst = '1') then
			 cnt6 <= 0;
			 cnt4 <= 0;
			elsif (clkIn'event and clkIn='1') then
				cnt6 <= cnt6 + 1;
				cnt4 <= cnt4 + 1;
				if (cnt6 = 2) then
					ck6 <= not ck6;
					cnt6 <= 0;
				end if;
				if (cnt4 = 1) then 
					ck4 <= not ck4;
					cnt4 <= 0;
				end if;
				ck2 <= not ck2;
			end if;
			clk_6 <= ck6;
			clk_4 <= ck4;
			clk_2 <= ck2; 
		end process;

end Behavioral;

