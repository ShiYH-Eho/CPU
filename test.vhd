library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
entity test is
    port(
        clk_in : in std_logic;
        clk_uart_in : in std_logic;
        touch_btn : in STD_LOGIC_VECTOR(5 downto 0);
        dip_sw : in std_logic_vector(31 downto 0);
        uart_tbre,uart_tsre,uart_dataready : in std_logic;
        uart_wrn,uart_rdn : out std_logic;
        base_ram_addr : out std_logic_vector(19 downto 0);
        base_ram_data : inout std_logic_vector(31 downto 0);
        base_ram_ce_n,base_ram_oe_n,base_ram_we_n : out std_logic;
        ext_ram_addr : out std_logic_vector(19 downto 0);
        ext_ram_data : inout std_logic_vector(31 downto 0);
        ext_ram_ce_n,ext_ram_oe_n,ext_ram_we_n : out std_logic;
        

        leds : out std_logic_vector(31 downto 0)
    );
end test;

architecture behavioral of test is
    component IO
    port(
            rst : in std_logic;
            clk             : in std_logic;
            MemWrite        : in std_logic;
            MemRead            : in std_logic;
            ram_data        : in std_logic_vector(15 downto 0);
            ram_addr        : in std_logic_vector(15 downto 0);
            ins_addr         : in std_logic_vector(15 downto 0);
            data_out        : out std_logic_vector(15 downto 0);
            ins_out         : out std_logic_vector(15 downto 0);
            uart_tbre            : in std_logic;
            uart_tsre            : in std_logic;
            uart_rdn             : out std_logic;
            uart_wrn            : out std_logic;
            base_ram_ce_n         : out std_logic;
            base_ram_oe_n            : out std_logic;
            base_ram_we_n            : out std_logic;
            base_ram_addr        : out std_logic_vector(19 downto 0);
            base_ram_data        : inout std_logic_vector(31 downto 0);
            ext_ram_ce_n            : out std_logic;
            ext_ram_oe_n            : out std_logic;
            ext_ram_we_n            : out std_logic;
            ext_ram_addr        : out std_logic_vector(19 downto 0);
            ext_ram_data        : inout std_logic_vector(31 downto 0);
            uart_dataready        : in std_logic
    );
    end component;
    signal data,addr : std_logic_vector(15 downto 0);
    signal data_out,ins_out : std_logic_vector(15 downto 0);
    signal ins_addr : std_logic_vector(15 downto 0) := x"0030";
begin
    data <= dip_sw(14 downto 0) & '0';
    addr <= dip_sw(30 downto 16) & '0';
    
    u1:IO
    port map(
                rst => touch_btn(5),
                clk => touch_btn(4),
                MemWrite => dip_sw(31),
                MemRead  => dip_sw(15),
                ram_data => data,
                ram_addr => addr,
                ins_addr => ins_addr,
                data_out => leds(15 downto 0),
                ins_out  => leds(31 downto 16),
                uart_tbre => uart_tbre,
                uart_tsre => uart_tsre,
                uart_rdn  => uart_rdn,
                uart_wrn  => uart_wrn,
                base_ram_ce_n => base_ram_ce_n,
                base_ram_oe_n => base_ram_oe_n,
                base_ram_we_n => base_ram_we_n,
                base_ram_addr => base_ram_addr,
                base_ram_data => base_ram_data,
                ext_ram_ce_n  => ext_ram_ce_n,
                ext_ram_oe_n  => ext_ram_oe_n,
                ext_ram_we_n  => ext_ram_we_n,
                ext_ram_addr  => ext_ram_addr,
                ext_ram_data => ext_ram_data,
                uart_dataready => uart_dataready
       );
 --      process(touch_btn(0))
   --    begin
     --   ins_addr <= ins_addr + 1;
     --  end process;
end behavioral;
