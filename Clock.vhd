----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:20:05 11/24/2015 
-- Design Name: 
-- Module Name:    Clock - Behavioral 
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

entity Clock is
	port(
		rst : in std_logic;
		clkIn : in std_logic;
		
		clk_8 : out std_logic;
		clk_15 : out std_logic
	);
end Clock;

architecture Behavioral of Clock is
	signal clk_1,clk_2,clk_3,clk_4,clk_5 ,clk_t: std_logic;
	signal cnt15,cnt4:natural range 0 to 15;
begin
	process (clkIn,rst)
		begin
			if (rst = '0') then
			 cnt15 <= 0;
			 cnt4 <= 0;
			elsif (clkIn'event and clkIn='1') then 
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
				
				if(cnt15=5) then 
					cnt15<=0;
					clk_5<='1';
				else
					cnt15<=cnt15+1;
					clk_5<='0';
				end if;
				
				if (cnt4 = 0) then
					clk_t <= not clk_t;
					cnt4 <= 1;
				else
					cnt4 <= 0;
				end if;
			end if; 
			clk_8<=clk_t;
			clk_15<=clk_5;
		end process;

end Behavioral;

