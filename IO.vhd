library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;


entity IO is
	port(
		rst : in std_logic;
		clk 			: in std_logic;
		MemWrite		: in std_logic;
		MemRead			: in std_logic;
		ram_data		: in std_logic_vector(15 downto 0);
		ram_addr		: in std_logic_vector(15 downto 0);
		ins_addr 		: in std_logic_vector(15 downto 0);
		data_out		: out std_logic_vector(15 downto 0);
		ins_out 		: out std_logic_vector(15 downto 0);
		uart_tbre			: in std_logic;
		uart_tsre			: in std_logic;
		uart_rdn 			: out std_logic;
		uart_wrn			: out std_logic;
		base_ram_ce_n 		: out std_logic;
		base_ram_oe_n			: out std_logic;
		base_ram_we_n			: out std_logic;
		base_ram_addr		: out std_logic_vector(19 downto 0);
		base_ram_data		: inout std_logic_vector(31 downto 0);
		ext_ram_ce_n			: out std_logic;
		ext_ram_oe_n			: out std_logic;
		ext_ram_we_n			: out std_logic;
		ext_ram_addr		: out std_logic_vector(19 downto 0);
		ext_ram_data		: inout std_logic_vector(31 downto 0);
		uart_dataready		: in std_logic
	);
end IO;


architecture Behavioral of IO is
	signal state : std_logic_vector(2 downto 0) := "000";
    signal rflag : std_logic := '0';
begin
ext_Ram_ce_n <= '0';
base_ram_ce_n <= '1';
base_ram_oe_n <= '1';
base_ram_we_n <= '1';
ext_ram_addr(19 downto 16) <= "0000";
base_ram_data(31 downto 8) <= (others =>'0');
ext_ram_data(31 downto 16) <= (others =>'0');

process(clk, rst)
begin
	if(rst = '1')then 
		ext_Ram_we_n <= '1';
		ext_Ram_oe_n <= '1';
		ins_out <= (others => '0');
		data_out <= (others => '0');
		state <= "000";
		uart_wrn <= '1';
		uart_rdn <= '1';
		rflag <= '0';
		ext_ram_addr <= (others => '0');
	elsif(clk'event and clk = '1')then
		case state is
			when "000" =>
				ext_Ram_data <= (others => 'Z');
				ext_Ram_addr(15 downto 0) <= ins_addr;
				uart_wrn <= '1';
				uart_rdn <= '1';
				ext_Ram_oe_n <= '0';
				state <= "001";
			when "001" =>
				ext_Ram_oe_n <= '1';
				ins_out <= ext_Ram_data(15 downto 0);
				if(MemWrite = '1')then
					rflag <= '0';
					if(ram_addr = x"BF00" or ram_addr = x"BF02")then
						base_ram_data(7 downto 0) <= ram_data(7 downto 0);
						uart_wrn <= '0';
					else
						ext_Ram_addr(15 downto 0) <= ram_addr;
						ext_Ram_data(15 downto 0) <= ram_data;
						ext_Ram_we_n <= '0';
					end if;
				elsif(Memread = '1')then
					if(ram_addr = x"BF01" or ram_addr = x"BF03")then
						data_out(15 downto 2) <= (others => '0');
						data_out(0) <= uart_tsre and uart_tbre;
						data_out(1) <= uart_dataready;
						if(rflag = '0')then
							base_ram_data <= (others => 'Z');
							rflag <= '1';
						end if;
					elsif(ram_addr = x"BF00" or ram_addr = x"BF02")then
						rflag <= '0';
						uart_rdn <= '0';
					else
						ext_Ram_data <= (others => 'Z');
						ext_Ram_addr(15 downto 0) <= ram_addr;
						ext_Ram_oe_n <= '0';
					end if;
				end if;
				state <= "010";
			when "010" =>
				if(MEMwrite = '1')then
					if(ram_addr = x"BF00" or ram_addr = x"BF02")then
						uart_wrn <= '1';
					else
						ext_Ram_we_n <= '1';
					end if;
				elsif(MEMread = '1')then
					if(ram_addr = x"BF01" or ram_addr = x"BF03")then
						null;
					elsif(ram_addr = x"BF00" or ram_addr = x"BF02")then 
						uart_rdn <= '1';
						data_out(15 downto 8) <= (others => '0');
						data_out(7 downto 0) <= base_ram_data(7 downto 0);
					else
						ext_Ram_oe_n <= '1';
						data_out <= ext_Ram_data(15 downto 0);
					end if;
				end if;
				state <= "000";
			when others => state <= "000";
		end case;
	end if;
end process;
end Behavioral;
