library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ForwardController is
	port(
			ExMemRd : in std_logic_vector(3 downto 0);
			MemWbRd : in std_logic_vector(3 downto 0);
			
			ExMemRegWrite : in std_logic;
			MemWbRegWrite : in std_logic;
			
			IdExAsrc : in std_logic_vector(2 downto 0);
			IdExBsrc : in std_logic_vector(1 downto 0);
			IdExRx : in std_logic_vector(2 downto 0);
			IdExRy : in std_logic_vector(2 downto 0);
			
			
			ForwardA : out std_logic_vector(1 downto 0);
			ForwardB : out std_logic_vector(1 downto 0);
			
			ForwardX : out std_logic_vector(1 downto 0);
			ForwardY : out std_logic_vector(1 downto 0)
	);
end ForwardController;

architecture Behavioral of ForwardController is
begin
	process(ExMemRd, MemWbRd, ExMemRegWrite, MemWbRegWrite, IdExRx, IdExRy)
	begin
		
		if (ExMemRegWrite = '1' and (IdExAsrc = "001" or IdExBsrc = "01") and ExMemRd = '0' & IdExRx) then--Ex 
			ForwardA <= "10";
		elsif (MemWbRegWrite = '1' -- and ExMemRd /= '0' & IdExRx--Mem
			and MemWbRd = '0' & IdExRx and (IdExAsrc = "001" or IdExBsrc = "01") ) then
			ForwardA <= "01";
		else
			case IdExAsrc is
				when "011" => --SP
					if (ExMemRegWrite = '1'  and ExMemRd = "1000") then--Ex 
						ForwardA <= "10";
					elsif (MemWbRegWrite = '1'--  and ExMemRd /= "1000"	--Mem
						and MemWbRd = "1000") then
						ForwardA <= "01";
					else 
						ForwardA <= "00";
					end if;
				when "100" => --IH
					if (ExMemRegWrite = '1'  and ExMemRd = "1001") then--Ex 
						ForwardA <= "10";
					elsif (MemWbRegWrite = '1'--  and ExMemRd /= "1001"	--Mem
						and MemWbRd = "1001") then
						ForwardA <= "01";
					else 
						ForwardA <= "00";
					end if;
				when "110" => --T
					if (ExMemRegWrite = '1'  and ExMemRd = "1010") then--Ex 
						ForwardA <= "10";
					elsif (MemWbRegWrite = '1'--  and ExMemRd /= "1010"	--Mem
						and MemWbRd = "1010") then
						ForwardA <= "01";
					else 
						ForwardA <= "00";
					end if;
				when others =>
					ForwardA <= "00";
			end case;
		end if;
		
		
		if (ExMemRegWrite = '1' and(IdExAsrc = "010" or IdExBsrc = "10") and ExMemRd = '0' & IdExRy) then
			ForwardB <= "10";
		elsif (MemWbRegWrite = '1'--  and ExMemRd /= '0' & IdExRy  
			and(IdExAsrc = "010" or IdExBsrc = "10") and MemWbRd = '0' & IdExRy) then
			ForwardB <= "01";
		else 
			ForwardB <= "00";
		end if;
		
		
		
		if (ExMemRegWrite = '1'  and ExMemRd /= "1111" and   ExMemRd = '0' & IdExRx) then--Ex 
			forwardX <= "10";
		elsif (MemWbRegWrite = '1'  and ExMemRd /= '0' & IdExRx--Mem
			and MemWbRd = '0' & IdExRx  ) then
			forwardX <= "01";
		else
			case IdExAsrc is
				when "011" => --SP
					if (ExMemRegWrite = '1'  and ExMemRd = "1000") then--Ex 
						forwardX <= "10";
					elsif (MemWbRegWrite = '1'  and ExMemRd /= "1000"	--Mem
						and MemWbRd = "1000") then
						forwardX <= "01";
					else 
						forwardX <= "00";
					end if;
				when "100" => --IH
					if (ExMemRegWrite = '1'  and ExMemRd = "1001") then--Ex 
						forwardX <= "10";
					elsif (MemWbRegWrite = '1'  and ExMemRd /= "1001"	--Mem
						and MemWbRd = "1001") then
						forwardX <= "01";
					else 
						forwardX <= "00";
					end if;
				when "110" => --T
					if (ExMemRegWrite = '1'  and ExMemRd = "1010") then--Ex 
						forwardX <= "10";
					elsif (MemWbRegWrite = '1'  and ExMemRd /= "1010"	--Mem
						and MemWbRd = "1010") then
						forwardX <= "01";
					else 
						forwardX <= "00";
					end if;
				when others =>
					forwardX <= "00";
			end case;
		end if;
		
		
		if (ExMemRegWrite = '1' and ExMemRd = '0' & IdExRy) then
			ForwardY <= "10";
		elsif (MemWbRegWrite = '1'  and ExMemRd /= '0' & IdExRy 
			and MemWbRd = '0' & IdExRy) then
			forwardy <= "01";
		else 
			forwardy <= "00";
		end if;
	end process;


end Behavioral;

