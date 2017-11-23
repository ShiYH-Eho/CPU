library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Controller is
    port(
        commandIn : in std_logic_vector (15 downto 0);
        rst : in std_logic;
        ControllerOut : out std_logic_vector(19 downto 0) := x"00000";
        ALUOP : out std_logic_vector(3 downto 0) := "0000";
        choose_A : out std_logic_vector(2 downto 0) := "000"
        choose_B : out std_logic_vector(1 downto 0) := "00";
        choose_Dst : out std_logic_vector (2 downto 0) := "000";
        special_Reg : out std_logic_vector(1 downto 0) := "00"
        RegWrite , MemRead , MemWrite  ,MemtoReg : out std_logic := "0";
        branch , jump : out std_logic := "0";
        choose_data : out std_logic := "0"
    );
end Controller;

architecture Behavioral of Controller is
begin
    ALUOP <= ControllerOut(19 downto 16);
    choose_A <= ControllerOut(15 downto 13);
    choose_B <= ControllerOut(12 downto 11);
    choose_Dst <= ControllerOut(10 downto 8);
    special_Reg <= ControllerOut(7 downto 6);
    RegWrite <= ControllerOut(5);
    MemRead <= ControllerOut(4);
    MemWrite <= ControllerOut(3);
    MemtoReg <= ControllerOut(2);
    branch <= ControllerOut(1);
    jump <= ControllerOut(0);
    process(commandIn,rst)
    begin
        if (rst = "1") then
            ControllerOut <= x"00000";
        else
            case commandIn(15 downto 11) is
                when "01001" => --ADDIU
                    ControllerOut <= "00000011100100100000";
                when "01000" => --ADDIU3
                    ControllerOut <= "00000011101000100000";
                when "01100" => 
                    case commandIn(10 downto 8) is
                        when "011" => --ADDSP
                            ControllerOut <= "00000111110001100000";
                        when "000" => --BTEQZ
                            ControllerOut <= "00011100000011000010";
                        when "100" => --MTSP
                            ControllerOut <= "00000010010000100000";
                    end case ;
                when "11100" => 
                    case commandIn(1 downto 0) is
                        when "01" => --ADDU
                            ControllerOut <= "00000011001100100000";
                        when "11" => --SUBU
                            ControllerOut <= "00010011001100100000";
                    end case ;
                when "11101" =>
                    case commandIn(4 downto 0) is
                        when "01100" => --AND
                            ControllerOut <= "00100011000100100000";
                        when "01010" => --CMP
                            ControllerOut <= "10100011011000100000";
                        when "00000" =>
                            case commandIn(7 downto 5) is
                                when "000" => --JR
                                    ControllerOut <= "11110000000000000001";
                                when "010" => --MFPC
                                    ControllerOut <= "00001010000100100000";
                            end case ;
                        when "01101" => --OR
                            ControllerOut <= "00110011000100100000";
                        when "00010" => --SLT
                            ControllerOut <= "10000011011000100000";
                        when "00110" => --SRLV
                            ControllerOut <= "01100100101000100000";    
                        when "01111" => --NOT
                            ControllerOut <= "01110011000100100000";
                    end case;
                when "00010" => --B
                    ControllerOut <= "11110000000000000010";
                when "00100" => --BEQZ
                    ControllerOut <= "00010010000000000010";
                when "00101" => --BNEZ
                    ControllerOut <= "10010010000000000010";
                when "01101" => --LI
                    ControllerOut <= "00001110000100100000";
                when "10011" => --LW
                    ControllerOut <= "00000011101000110100";
                when "10010" => --LW_SP
                    ControllerOut <= "00000111100101110100";
                when "11110" => 
                    if (commandIn(0) = "0") then --MFIH
                        ControllerOut <= "00001000000110100000";
                    else --MTIH
                        ControllerOut <= "00000010010100100000";    
                    end if ;
                when "00001" => --NOP
                    ControllerOut <= "11110000000000000000";
                when "00110" => 
                    case commandIn(1 downto 0) is
                        when "00" => --SLL
                            ControllerOut <= "01000101100100100000";
                        when "11" => --SRA
                            ControllerOut <= "01010101100100100000";
                    end case ;
                when "11011" => --SW
                    ControllerOut <= "00000011100000001000";
                when "11010" => --SW_SP
                    ControllerOut <= "00000111100001001000";
                when "01111" => --MOVE
                    ControllerOut <= "00000100000100100000";
                when "01010" => --SLTI
                    ControllerOut <= "10000011111000100000";
                when others => --error
            end case ;
            if (commandIn(15 downto 11) = "11011") then
                choose_data <= "1";
            else
                choose_data <= "0";
            end if ;
        end if;
    end process;
end Behavioral;
