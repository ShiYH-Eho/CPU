library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Clock is
	port(
		clkIn : in std_logic;
		clk_8 : out std_logic;
		clk_15 : out std_logic
	);
end Clock;

architecture Behavioral of Clock is
	signal clk_1,clk_2,clk_3,clk_4,clk_5 : std_logic;
	signal cnt15:natural range 0 to 15;
begin
	process (clkIn)
		begin
			if (clkIn'event and clkIn='1') then 
				clk_1<=not clk_1; 
				if (clk_1='1')then
					clk_2<=not clk_2; 
					if (clk_2='1')then
						clk_3<=not clk_3;
						if(clk_3='1')then
							clk_4<=not clk_4;
						end if;
					end if;
				end if;
				
				if(cnt15=14) then 
					cnt15<=0;
					clk_5<='1';
				else
					cnt15<=cnt15+1;
					clk_5<='0';
				end if;
				
			end if; 
			clk_8<=clk_3;
			clk_15<=clk_5;
		end process;

end Behavioral;

