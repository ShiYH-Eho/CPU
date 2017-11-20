library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ALU is
	port(
		Asrc       :  in STD_LOGIC_VECTOR(15 downto 0);
		Bsrc       :  in STD_LOGIC_VECTOR(15 downto 0);
		ALUop		  :  in STD_LOGIC_VECTOR(3 downto 0);
		ALUresult  :  out STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000"; -- Ĭ����Ϊȫ0
		branchJudge : out std_logic
	);
end ALU;

architecture Behavioral of ALU is
	shared variable tmp : std_logic_vector(15 downto 0);
begin
	process(Asrc , Bsrc , ALUop)
	begin
		case ALUop is 
			when "0000" => --  +
				ALUresult <= Asrc + Bsrc;
				branchJudge <= '1';
			when "0001" => --  -
				ALUresult <= Asrc - Bsrc; -- A-B
				if (Asrc = Bsrc) then 
					branchJudge <= '1';
				else 
					branchJudge <= '0';
				end if;
			when "1010" => -- cmp
				if (Asrc = Bsrc) then 
					ALUresult <= "0000000000000000";
				else 
					ALUresult <= "0000000000000001";
				end if;
				branchJudge <= '1';
			when "0010" => --  AND
				ALUresult <= Asrc and Bsrc;
				branchJudge <= '1';
			when "0011" => --  OR
				ALUresult <= Asrc or Bsrc;
				branchJudge <= '1';
			when "0110" => --  SRLV
				ALUresult <= to_stdlogicvector(to_bitvector(Asrc) srl conv_integer(Bsrc));
				branchJudge <= '1';
			when "0100" => --SLL
				tmp := Asrc(15 downto 0);
				if (Bsrc = "0000000000000000") then 
					ALUresult(15 downto 0) <= to_stdlogicvector(to_bitvector(tmp) sll 8);--left 8
				else 
					ALUresult <= to_stdlogicvector(to_bitvector(Asrc) sll conv_integer(Bsrc));
				end if;
				branchJudge <= '1';
			when "0101" => --  SRA
				tmp := Asrc(15 downto 0);
				if (Bsrc = "0000000000000000") then 
					ALUresult(15 downto 0) <= to_stdlogicvector(to_bitvector(tmp) sra 8);--left 8
				else 
					ALUresult <= to_stdlogicvector(to_bitvector(Asrc) sra conv_integer(Bsrc));
				end if;
			when "0111" => --NOT
				ALUresult <= not Asrc;
				branchJudge <= "1";
			when "1001" => --special sub for BNEZ
				ALUresult  <= Asrc - Bsrc; 
				if (Asrc = Bsrc) then
					branchJudge <= '0';
				else 
					branchJudge <= '1';
				end if;
			when "1010" => -- special for CMP
				if (Asrc = Bsrc) then
					ALUresult <= (others => '0');
				else 
					ALUresult <= "0000000000000001";
				end if;
				branchJudge <= '1';
			when "1000" => --for SLT
				if (Asrc < Bsrc) then
					ALUresult <= "0000000000000001";
				else 
					ALUresult <= (others => '0');
				end if;
				branchJudge <= '1';
		end case;
	end process;

end Behavioral;

