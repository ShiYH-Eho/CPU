----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:57:16 11/06/2015 
-- Design Name: 
-- Module Name:    chuan - Behavioral 
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
USE ieee.std_logic_signed.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity chuan is
    Port ( 
           touch_btn : in STD_LOGIC_VECTOR(5 downto 0);
           clk_uart_in : in STD_LOGIC;
           uart_dataready : in  STD_LOGIC;
           base_ram_data : inout  STD_LOGIC_VECTOR(7 downto 0);
           dip_sw : in  STD_LOGIC_VECTOR(15 downto 0);
			  leds : out STD_LOGIC_VECTOR(7 downto 0);
			  
			  uart_tbre:in STD_LOGIC;
			  uart_tsre:in STD_LOGIC;
			  uart_wrn:out STD_LOGIC;
			  uart_rdn:out STD_LOGIC;
			
			  base_ram_oe_n : out STD_LOGIC;
			  base_ram_we_n : out STD_LOGIC;
			  base_ram_ce_n : out STD_LOGIC
			  );
end chuan;

architecture Behavioral of chuan is
	shared variable state : integer range 0 to 13 := 0;
	shared variable tmp_data : std_logic_vector(7 downto 0) := "00000000";
begin
	process(clk_uart_in,touch_btn(4))
	begin
		if (touch_btn(4) = '1') then
			state:=1;
			leds <= "00000000";
			base_ram_ce_n <='1';
			base_ram_oe_n <='1';
			base_ram_we_n <='1';
		elsif (clk_uart_in' event and clk_uart_in = '1') then
				if (dip_sw(15 downto 14) = "00") then--write
					case state is
							when 0 =>
								uart_wrn<='1';
								base_ram_ce_n <='1';
								base_ram_oe_n <='1';
								base_ram_we_n<='1';
								state:=1;
							when 1 => 
								base_ram_data<=dip_sw(7 downto 0);
								uart_wrn<='0';
								state := 2;
							when 2 =>
								uart_wrn<='1';
								state := 3;
							when 3 =>
								if (uart_tbre = '1') then
									state := 4;
								end if;
							when 4 =>
								if (uart_tsre = '1') then 
									state := 0;	
								end if;
							when others=>
					end case;
				elsif (dip_sw(15 downto 14) = "01") then--read
					case state is
							when 0 =>
								base_ram_ce_n <='1';
								base_ram_oe_n <='1';
								base_ram_we_n<='1';
								state:=1;
							when 1 => 
								base_ram_data <="ZZZZZZZZ";
								uart_rdn<='1';
								state := 2;
							when 2 =>
								if (uart_dataready = '1') then
									uart_rdn <= '0';
									state := 3;
								elsif (uart_dataready = '0') then
									state := 1;
								end if;
							when 3 =>
								leds <= base_ram_data;
								state :=1;
							when others=>
					end case;
				elsif (dip_sw(15 downto 14) = "11") then--read and feedback
					case state is
						when 0 =>
							base_ram_ce_n <='1';
							base_ram_oe_n <='1';
							base_ram_we_n <='1';
							uart_wrn  <='1';
							state:=state+1;
						when 1 => 
							uart_rdn  <='1';
							base_ram_data <="ZZZZZZZZ";
							state:=state+1;
						when 2 =>
							if (uart_dataready = '1') then
								uart_rdn <= '0';
								state := 3;
							else
								state := 1;
							end if;
						when 3 =>
							leds <= base_ram_data;
							tmp_data:=base_ram_data;
							uart_rdn <= '1';
							uart_wrn<='1';
							state:=state+1;
						when 4 =>
							tmp_data := tmp_data+1;
							state:=state+1;
						when 5 => 
							uart_wrn<='0';
							base_ram_data<=tmp_data;
							leds<=tmp_data;
							state:=state+1;
						when 6 =>
							uart_wrn<='1';
							state:=state+1;
		
						when 7 =>
							if (uart_tbre = '1') then
								state:=state+1;

							end if;
						when 8 =>					
							if (uart_tsre = '1') then 
								state:=0;
								
							end if;
						when others=>
					end case;
				end if;
		     end if;
	end process;
end Behavioral;

