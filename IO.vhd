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
		ram1_addr		: out std_logic_vector(15 downto 0);
		ram1_data		: inout std_logic_vector(15 downto 0);
		ram2_en			: out std_logic;
		ram2_oe			: out std_logic;
		ram2_we			: out std_logic;
		ram2_addr		: out std_logic_vector(15 downto 0);
		ram2_data		: inout std_logic_vector(15 downto 0);
		data_ready		: in std_logic
	);
end IO;


architecture Behavioral of IO is
	signal state1 : std_logic_vector(3 downto 0) := "0000";
	signal state2 : std_logic_vector(3 downto 0) := "0000";
	signal t1 : std_logic_vector(15 downto 0):= x"0000";
	signal t2 : std_logic_vector(15 downto 0):= x"0000";
	
	
begin

	process(clk,t1,t2)
	begin 
		if (ram_addr(15 downto 0) <= x"7FFF" and ram_addr(15 downto 0) >= x"4000") then
			data_out <= t2;
		else
			data_out <= t1;
		end if;
	end process;
	
	process(clk, rst)
	begin
		if rst = '0' then
			ins_out <= (others => '0');
		elsif clk'event and clk = '1' then
			ram2_en <= '0';
			case state1 is
				when "0000" =>
					if ram_addr(15 downto 0) <= x"7FFF" and ram_addr(15 downto 0) >= x"4000" then
						state1 <= "0001";
					else
						state1 <= "1001";
					end if;
				when "0001" =>
					if MemWrite = '1' then
						state1 <= "0010";
					elsif MemRead = '1' then
						state1 <= "0101";
					else 
						state1 <= "1001";
					end if;
					
				when "0010" =>
					ram2_oe <= '1';
					ram2_we <= '1';
					ram2_data <= ram_data;
					ram2_addr <= ram_addr;
					state1 <= "0011";
				when "0011" =>
					ram2_oe <= '1';
					ram2_we <= '0';
					ram2_data <= ram_data;
					ram2_addr <= ram_addr;
					state1 <= "0100";
				when "0100" =>
					ram2_oe <= '1';
					ram2_we <= '1';
					ram2_data <= ram_data;
					ram2_addr <= ram_addr;
					state1 <= "0101";
					
				when "0101" =>
					ram2_oe <= '1';
					ram2_we <= '1';
					ram2_data <= "ZZZZZZZZZZZZZZZZ";
					state1 <= "0110";
				when "0110" =>
					ram2_oe <= '0';
					ram2_we <= '1';
					ram2_data <= "ZZZZZZZZZZZZZZZZ";
					state1 <= "0111";
				when "0111" =>
					ram2_oe <= '0';
					ram2_we <= '1';
					ram2_addr <= ram_addr;
					state1 <= "1000";
				when "1000" =>
					ram2_addr <= ram_addr;
					t2 <= ram2_data;
					state1 <= "1001";
					
				when "1001" =>
					ram2_oe <= '1';
					ram2_we <= '1';
					ram2_data <= "ZZZZZZZZZZZZZZZZ";
					state1 <= "1010";
				when "1010" =>
					ram2_oe <= '0';
					ram2_we <= '1';
					ram2_data <= "ZZZZZZZZZZZZZZZZ";
					state1 <= "1011";
				when "1011" =>
					ram2_addr <= ins_addr;
					state1 <= "1100";
				when "1100" =>
					ins_out <= ram2_data;
					state1 <= "1101";
				when "1101" =>
					state1 <= "0000";
				when others =>
					state1 <= "0000";
			end case;
		end if;
	end process;
	
	process(clk, rst)
	begin
		if rst = '0' then
			--data_out <= (others => '0');
		elsif clk'event and clk = '1' then 
			if MemRead = '1' then
				if (ram_addr(15 downto 0) = x"BF00" or ram_addr(15 downto 0) = x"BF02") then 
					ram1_en <= '1';
					case state2 is
						when "0000" =>
							rdn <= '1';
							wrn <= '1';
							ram1_data(7 downto 0) <= "ZZZZZZZZ";
							state2 <= "0001";
						when "0001" =>
							if data_ready = '1' then
								wrn <= '1';
								rdn <= '0';
								state2 <= "0010";
							end if;
							--ram1_data(7 downto 0) <= "ZZZZZZZZ";
						when "0010" =>
							rdn <= '1';
							t1(7 downto 0) <= ram1_data(7 downto 0);
							state2 <= "0011";
						when others =>
							state2 <= state2;
					end case;
				elsif (ram_addr(15 downto 0) = x"BF01" or ram_addr(15 downto 0) = x"BF03") then
					--data_out <= x"0000";
					t1(0) <= tbre and tsre;
					t1(15 downto 5) <= "00000000000";
					t1(1) <= data_ready;
					t1(2) <= tsre;
					t1(4 downto 3) <= "00";
				elsif ((ram_addr(15 downto 0) <= x"FFFF" and ram_addr(15 downto 0) >= x"BF04") or (ram_addr(15 downto 0)>= x"8000" and ram_addr(15 downto 0) <= x"BEFF")) then
					ram1_en <= '0';
					rdn <= '1';
					wrn <= '1';
					case state2 is 
						when "0000" =>
							ram1_oe <= '1';
							ram1_we <= '1';
							ram1_data <= "ZZZZZZZZZZZZZZZZ";
							state2 <= "0001";
						when "0001" =>
							ram1_oe <= '0';
							ram1_we <= '1';
							ram1_data <= "ZZZZZZZZZZZZZZZZ";
							state2 <= "0010";
						when "0010" =>
							ram1_addr <= ram_addr;
							state2 <= "0011";
						when "0011" =>
							t1 <= ram1_data;
							state2 <= "0100";
						when others=>
							state2 <= "0000";
					end case;
				end if;
			elsif MemWrite = '1' then
				if ( ram_addr(15 downto 0) = x"BF00" or ram_addr(15 downto 0) = x"BF02" ) then
					ram1_en <= '1';
					ram1_oe <= '1';
					ram1_we <= '1';
					case state2 is 
						when "0000"=>
							wrn <= '1';
							rdn <= '1';
							ram1_data(7 downto 0) <= ram_data(7 downto 0);
							state2 <= "0001";
						when "0001" =>
							wrn <= '0';
							rdn <= '1';
							ram1_data(7 downto 0) <= ram_data(7 downto 0);
							state2 <= "0010";
						when "0010" =>
							wrn <= '1';
							ram1_data(7 downto 0) <= ram_data(7 downto 0);
							state2 <= "0011";
						when "0011" =>
							if tbre = '1' then
								state2 <= "0100";
							end if;
						when "0100" =>
							if tsre = '1' then
								state2 <= "0101";
								wrn <= '1';
								rdn <= '1';
							end if;
						when others =>
							state2 <= state2;
					end case;
				elsif ((ram_addr(15 downto 0) <= x"FFFF" and ram_addr(15 downto 0) >= x"BF04") or (ram_addr(15 downto 0)>= x"8000" and ram_addr(15 downto 0) <= x"BEFF")) then
					ram1_en <= '0';
					rdn <= '1';
					wrn <= '1';
					case state2 is 
						when "0000" =>
							ram1_oe <= '1';
							ram1_we <= '1';
							ram1_data <= ram_data;
							ram1_addr <= ram_addr;
							state2 <= "0001";
						when "0001" =>
							ram1_we <= '0';
							state2 <= "0010";
						when "0010" =>
							ram1_oe <= '1';
							ram1_we <= '1';
							state2 <= "0011";
						when others =>
							state2 <= "0000";
					end case;
				else
					NULL;
				end if;
			else
				state2 <= "0000";
			end if;
		end if;
	end process;
end Behavioral;
