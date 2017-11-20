library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Controller is
    port(
        commandIn : in std_logic_vector (15 downto 0);
        rst : in std_logic;
        ControllerOut : out std_logic_vector (19 downto 0) := x"00000"
    --ControllerOut is a mix of these signal followed in order
        --ALUOP : out std_logic_vector(3 downto 0) := "0000";
        --choose_A : out std_logic_vector(2 downto 0) := "000"
        --choose_B : out std_logic_vector(1 downto 0) := "00";
        --choose_Dst : out std_logic_vector (2 downto 0) := "000";
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
                    ControllerOut <= "000000111";
                when "01000" => --ADDIU3
                    ControllerOut <= "000000111";
                when "01100" => 
                    case commandIn(10 downto 8) is
                        when "011" => --ADDSP
                            ControllerOut <= "0000011";
                        when "000" => --BTEQZ
                            ControllerOut <= "0001";
                        when "100" => --MTSP
                            ControllerOut <= "0000";
                    end case ;
                when "11100" => 
                    case commandIn(1 downto 0) is
                        when "00" => --ADDU
                            ControllerOut <= "0000001";
                        when "11" => --SUBU
                            ControllerOut <= "0001";
                    end case ;
                when "11101" =>
                    case commandIn(4 downto 0) is
                        when "01100" => --AND
                            ControllerOut <= "0010";
                        when "01010" => --CMP
                            ControllerOut <= "1010";
                        when "00000" =>
                            case commandIn(7 downto 5) is
                                when "000" => --JR
                                    ControllerOut <= "1111";
                                when "010" => --MFPC
                                    ControllerOut <= "0000";
                            end case ;
                        when "01101" => --OR
                            ControllerOut <= "0011";
                        when "00010" => --SLT
                            ControllerOut <= "1000";
                        when "00110" => --SRLV
                            ControllerOut <= "0110";    
                        when "01111" => --NOT
                            ControllerOut <= "0111";
                    end case;
                when "00010" => --B
                    ControllerOut <= "1111";
                when "00100" => --BEQZ
                    ControllerOut <= "0001";
                when "00101" => --BNEZ
                    ControllerOut <= "1001";
                when "01101" => --LI
                    ControllerOut <= "0000";
                when "10011" => --LW
                    ControllerOut <= "0000";
                when "10010" => --LW_SP
                    ControllerOut <= "0000";
                when "11110" => 
                    if (commandIn(0) = "0") then --MFIH
                        ControllerOut <= "0000";
                    else --MTIH
                        ControllerOut <= "0000";    
                    end if ;
                when "00001" => --NOP
                    ControllerOut <= "1111";
                when "00110" => 
                    case commandIn(1 downto 0) is
                        when "00" => --SLL
                            ControllerOut <= "0100";
                        when "11" => --SRA
                            ControllerOut <= "0101";
                    end case ;
                when "11011" => --SW
                    ControllerOut <= "0000";
                when "11010" => --SW_SP
                    ControllerOut <= "0000";
                when "01111" => --MOVE
                    ControllerOut <= "0000";
                when "01010" => --SLTI
                    ControllerOut <= "1000";
                when others => --error
            end case ;
        end if;
    end process;
end Behavioral;
