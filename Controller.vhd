library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Controller is
    port(
        commandIn : in std_logic_vector (15 downto 0);
        rst : in std_logic;
        ControllerOut : out std_logic_vector (19 downto 0) := x"00000"
    --ControllerOut is a mix of these signal followed in order
        --ALUOP : out std_logic_vector(3 downto 0) := "0000";
        --choose_A,choose_B,choose_Dst : out std_logic_vector(1 downto 0) := "00";
        --special_Reg : out std_logic_vector(1 downto 0) := "00"
        --RegWrite , MemWrite , MemRead : out std_logic := "0";
        --branch , jump : out std_logic := "0";
        --MemtoReg , RegtoMem : out std_logic := "0"
    );
end Controller;

architecture Behavioral of Controller is
begin
    process(commandIn,rst)
    begin
        if (rst = "1") then
            ControllerOut <= x"00000";
        else
            case commandIn(15 downto 11) is
                when "01001" => --ADDIU
                when "01000" => --ADDIU3
                when "01100" => 
                    case commandIn(10 downto 8) is
                        when "011" => --ADDSP
                        when "000" => --BTEQZ
                        when "100" => --MTSP
                    
                    end case ;
                when "11100" => 
                    case commandIn(1 downto 0) is
                        when "00" => --ADDU
                        when "11" => --SUBU
                    end case ;--ADDU
                when "11101" =>
                    case commandIn(4 downto 0) is
                        when "01100" => --AND
                        when "01010" => --CMP
                        when "00000" =>
                            case commandIn(7 downto 5) is
                                when "000" => --JR
                                when "010" => --MFPC
                            end case ;
                        when "01101" => --OR
                        when "00010" => --SLT
                        when "00110" => --SRLV
                        when "01111" => --NOT
                    end case;
                when "00010" => --B
                when "00100" => --BEQZ
                when "00101" => --BNEZ
                when "01101" => --LI
                when "10011" => --LW
                when "10010" => --LW_SP
                when "11110" => 
                    if (commandIn(0) = "0") then --MFIH
                    else --MTIH
                    end if ;
                when "00001" => --NOP
                when "00110" => 
                    case commandIn(1 downto 0) is
                        when "00" => --SLL
                        when "11" => --SRA
                    end case ;
                when "11011" => --SW
                when "11010" => --SW_SP
                when "01111" => --MOVE
                when "01010" => --SLTI
                when others => --error
            end case ;
        end if;
    end process;
end Behavioral;
