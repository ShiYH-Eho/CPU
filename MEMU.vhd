----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:17:24 11/23/2015 
-- Design Name: 
-- Module Name:    MEMU - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL ;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEMU is
    Port ( clk 			:	in 	STD_LOGIC;
           rst 			: 	in  STD_LOGIC;
           MEMdata_i	:	in 	STD_LOGIC_VECTOR(15 downto 0);
           MEMaddr 		:	in 	STD_LOGIC_VECTOR(15 downto 0);
           MEMwe 		:	in 	STD_LOGIC;
           MEMre		:	in 	STD_LOGIC;
           IFce			:	in 	STD_LOGIC;
           IFaddr		:	in 	STD_LOGIC_VECTOR(15 downto 0);
			  data_ready :	in STD_LOGIC;
			  tbre		:	in STD_LOGIC;
			  tsre 		:	in STD_LOGIC;

           Ramoe		:	out STD_LOGIC;
           Ramwe		:	out STD_LOGIC;
           Ramen		:	out STD_LOGIC;
           Ramaddr		:	out STD_LOGIC_VECTOR(17 downto 0);
           IFdata_o		:	out STD_LOGIC_VECTOR(15 downto 0);
           MEMdata_o 	:	out STD_LOGIC_VECTOR(15 downto 0);
			  ram1oe			:	out STD_LOGIC;
			  ram1we			:	out STD_LOGIC;
			  ram1en 		:	out STD_LOGIC;
			  ram1data		:	inout STD_LOGIC_VECTOR(7 downto 0);
			  wrn 			:	out STD_LOGIC;
			  rdn 			:	out STD_LOGIC;
           Ramdata		:	inout STD_LOGIC_VECTOR(15 downto 0)
        );
end MEMU;
 
architecture Behavioral of MEMU is
signal state : std_logic_vector(2 downto 0) := "000";
signal rflag : std_logic := '0';
begin
Ramen <= '0';
Ramaddr(16) <= '0';
Ramaddr(17) <= '0';
ram1en <= '1';
ram1oe <= '1';
ram1we <= '1';

process(clk, rst)
begin
	if(rst = '0')then 
		Ramwe <= '1';
		Ramoe <= '1';
		IFdata_o <= (others => '0');
		MEMdata_o <= (others => '0');
		state <= "000";
		wrn <= '1';
		rdn <= '1';
		rflag <= '0';
	elsif(clk'event and clk = '1')then
		case state is
			when "001" =>
				Ramdata <= (others => 'Z');
				Ramaddr(15 downto 0) <= IFaddr;
				wrn <= '1';
				rdn <= '1';
				Ramoe <= '0';
				state <= "010";
			when "010" =>
				Ramoe <= '1';
				IFdata_o <= Ramdata;
				if(MEMwe = '1')then
					rflag <= '0';
					if(MEMaddr = x"BF00")then
						ram1data <= MEMdata_i(7 downto 0);
						wrn <= '0';
					else
						Ramaddr(15 downto 0) <= MEMaddr;
						Ramdata <= MEMdata_i;
						Ramwe <= '0';
					end if;
				elsif(MEMre = '1')then
					if(MEMaddr = x"BF01")then
						MEMdata_o(15 downto 2) <= (others => '0');
						MEMdata_o(0) <= tsre and tbre;
						MEMdata_o(1) <= data_ready;
						if(rflag = '0')then
							ram1data <= (others => 'Z');
							rflag <= '1';
						end if;
					elsif(MEMaddr = x"BF00")then
						rflag <= '0';
						rdn <= '0';
					else
						Ramdata <= (others => 'Z');
						Ramaddr(15 downto 0) <= MEMaddr;
						Ramoe <= '0';
					end if;
				end if;
				state <= "011";
			when "011" =>
				if(MEMwe = '1')then
					if(MEMaddr = x"BF00")then
						wrn <= '1';
					else
						Ramwe <= '1';
					end if;
				elsif(MEMre = '1')then
					if(MEMaddr = x"BF01")then
						null;
					elsif(MEMaddr = x"BF00")then 
						rdn <= '1';
						MEMdata_o(15 downto 8) <= (others => '0');
						MEMdata_o(7 downto 0) <= ram1data;
					else
						Ramoe <= '1';
						MEMdata_o <= Ramdata;
					end if;
				end if;
				state <= "000";
			when "100" => 
				state  <= "101";
			when "101" => 
				state <= "000";
			when "000" =>
				state <= "001";
			when others => state <= "000";
		end case;
	end if;
end process;

end Behavioral;



