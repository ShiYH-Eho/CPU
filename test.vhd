library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test is
    port(
        clk_in : in std_logic;
        clk_uart_in : in std_logic;
        touch_btn : in STD_LOGIC_VECTOR(5 downto 0);
        dip_sw : in std_logic_vector(31 downto 0);
        uart_tbre,uart_tsre,uart_dataready : in std_logic;
        uart_wrn,uart_rdn : inout std_logic;
        base_ram_addr : out std_logic_vector(19 downto 0);
        base_ram_be_n : in std_logic_vector(3 downto 0);
        base_ram_data : inout std_logic_vector(31 downto 0);
        base_ram_ce_n,base_ram_oe_n,base_ram_we_n : out std_logic;
        ext_ram_addr : out std_logic_vector(19 downto 0);
        ext_ram_be_n : in std_logic_vector(3 downto 0);
        ext_ram_data : inout std_logic_vector(31 downto 0);
        ext_ram_ce_n,ext_ram_oe_n,ext_ram_we_n : out std_logic;
        

        leds : out std_logic_vector(31 downto 0)
    );
end test;

architecture behavioral of test is
    component io
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
    end component;
    signal state : std_logic_vector(3 downto 0) := "0000";
    signal data_in,data_out,addr,ins : std_logic_vector(15 downto 0);
    signal read,write : std_logic;
    signal ins_addr : std_logic_vector(15 downto 0) := x"0001";

begin
    addr <= '0' & dip_sw(30 downto 16);
    data_in <= '0' & dip_sw(14 downto 0);
    u1: io
    port map(
        rst => touch_btn(4),
        clk => touch_btn(5),
        MemWrite => dip_sw(31),
        MemRead => dip_sw(15),
        ram_data => data_in,
        ram_addr =>  addr,
        ins_addr => ins_addr,
        data_out => data_out,
        ins_out => ins,
        tbre => uart_tbre,
        tsre => uart_tsre,
        rdn => uart_rdn,
        wrn => uart_wrn,
        ram1_en => base_ram_ce_n,
        ram1_oe => base_ram_oe_n,
        ram1_we => base_ram_we_n,
        ram1_addr => base_ram_addr(17 downto 0),
        ram1_data => base_ram_data(15 downto 0),
        ram2_en => ext_ram_ce_n,
        ram2_oe => ext_ram_oe_n,
        ram2_we => ext_ram_we_n,
        ram2_addr => ext_ram_addr(17 downto 0),
        ram2_data => ext_ram_data(15 downto 0),
        data_ready => uart_dataready
    );
    process(touch_btn(5),touch_btn(4))
    begin
        if (touch_btn(4) = '1') then
            leds <= (others => '0');
        elsif (touch_btn(5)'event and touch_btn(5) = '1') then
            leds(31 downto 16) <= ins;
            leds(15 downto 0) <= data_out;
        else
        end if;
    end process;
--    component cpu
--    port
--    (
--        rst : in std_logic; --reset
--        clkIn : in std_logic; --时钟�????  默认�????50M  可以通过修改绑定管教来改�????
                
--                --串口
--        dataReady : in std_logic;   
--        tbre : in std_logic;
--        tsre : in std_logic;
--        rdn : inout std_logic;
--        wrn : inout std_logic;
--        ram1En : out std_logic;
--        ram1We : out std_logic;
--        ram1Oe : out std_logic;
--        ram1Data : inout std_logic_vector(15 downto 0);
--        ram1Addr : out std_logic_vector(15 downto 0);
--        ram2En : out std_logic;
--        ram2We : out std_logic;
--        ram2Oe : out std_logic;
--        ram2Data : inout std_logic_vector(15 downto 0);
--        ram2Addr : out std_logic_vector(15 downto 0);
--        digit1 : out std_logic_vector(6 downto 0);
--        digit2 : out std_logic_vector(6 downto 0);
--        led : out std_logic_vector(15 downto 0)
--    );
--    end component;
--    signal A : std_logic_vector(15 downto 0);
--    signal B : std_logic_vector(15 downto 0);
--    signal ALUop : std_logic_vector(3 downto 0);
--    signal result : std_logic_vector(15 downto 0);
--    signal branch : std_logic;
--    type state is (s1,s2,s3,s4);
--    signal s : state := s1;
--begin
--    u1 : cpu
--    port map(
--            rst => touch_btn(5),
--            clkIn => clk_in, --时钟�????  默认�????50M  可以通过修改绑定管教来改�????
                    
--                    --串口
--            dataReady => uart_dataready,   
--            tbre => uart_tbre,
--            tsre => uart_tsre,
--            rdn => uart_rdn,
--            wrn => uart_wrn,
--            ram1En => base_ram_ce_n,
--            ram1We => base_ram_we_n,
--            ram1Oe => base_ram_oe_n,
--            ram1Data => base_ram_data(15 downto 0),
--            ram1Addr => base_ram_addr(15 downto 0),
--            ram2En => ext_ram_ce_n,
--            ram2We => ext_ram_we_n,
--            ram2Oe => ext_ram_oe_n,
--            ram2Data => ext_ram_data(15 downto 0),
--            ram2Addr => ext_ram_addr(15 downto 0),
--            digit1 => leds(31 downto 25),
--            digit2 => leds(23 downto 17),
--            led => leds(15 downto 0)
--    );
end behavioral;
