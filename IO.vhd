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
		tbre			: in std_logic;
		tsre			: in std_logic;
		rdn 			: inout std_logic;
		wrn				: inout std_logic;
		ram1_en 		: out std_logic;
		ram1_oe			: out std_logic;
		ram1_we			: out std_logic;
		ram1_addr		: out std_logic_vector(17 downto 0);
		ram1_data		: inout std_logic_vector(15 downto 0);
		ram2_en			: out std_logic;
		ram2_oe			: out std_logic;
		ram2_we			: out std_logic;
		ram2_addr		: out std_logic_vector(17 downto 0);
		ram2_data		: inout std_logic_vector(15 downto 0);
		data_ready		: in std_logic
	);
end IO;


architecture Behavioral of IO is
	signal state : std_logic_vector(2 downto 0) := "000";
    signal rflag : std_logic := '0';
begin
Ram2_en <= '0';
Ram2_addr(17 downto 16) <= "00";
ram1_en <= '1';
ram1_oe <= '1';
ram1_we <= '1';

process(clk, rst)
begin
	if(rst = '1')then 
		Ram2_we <= '1';
		Ram2_oe <= '1';
		ins_out <= (others => '0');
		data_out <= (others => '0');
		state <= "000";
		wrn <= '1';
		rdn <= '1';
		rflag <= '0';
	elsif(clk'event and clk = '1')then
		case state is
			when "001" =>
				Ram2_data <= (others => 'Z');
				Ram2_addr(15 downto 0) <= ins_addr;
				wrn <= '1';
				rdn <= '1';
				Ram2_oe <= '0';
				state <= "010";
			when "010" =>
				Ram2_oe <= '1';
				ins_out <= Ram2_data;
				if(MemWrite = '1')then
					rflag <= '0';
					if(ram_addr = x"BF00" or ram_addr = x"BF02")then
						ram1_data <= ram_data;
						wrn <= '0';
					else
						Ram2_addr(15 downto 0) <= ram_addr;
						Ram2_data <= ram_data;
						Ram2_we <= '0';
					end if;
				elsif(Memread = '1')then
					if(ram_addr = x"BF01" or ram_addr = x"BF03")then
						data_out(15 downto 2) <= (others => '0');
						data_out(0) <= tsre and tbre;
						data_out(1) <= data_ready;
						if(rflag = '0')then
							ram1_data <= (others => 'Z');
							rflag <= '1';
						end if;
					elsif(ram_addr = x"BF00" or ram_addr = x"BF02")then
						rflag <= '0';
						rdn <= '0';
					else
						Ram2_data <= (others => 'Z');
						Ram2_addr(15 downto 0) <= ram_addr;
						Ram2_oe <= '0';
					end if;
				end if;
				state <= "011";
			when "011" =>
				if(MEMwrite = '1')then
					if(ram_addr = x"BF00" or ram_addr = x"BF02")then
						wrn <= '1';
					else
						Ram2_we <= '1';
					end if;
				elsif(MEMread = '1')then
					if(ram_addr = x"BF01" or ram_addr = x"BF03")then
						null;
					elsif(ram_addr = x"BF00" or ram_addr = x"BF02")then 
						rdn <= '1';
						data_out(15 downto 8) <= (others => '0');
						data_out(7 downto 0) <= ram1_data(7 downto 0);
					else
						Ram2_oe <= '1';
						data_out <= Ram2_data;
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
