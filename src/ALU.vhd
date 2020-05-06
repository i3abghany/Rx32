library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
usE IEEE.NUMERIC_STD.all;

entity ALU is 
	port(
		a, b: 	   in STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALUControl: in STD_LOGIC_VECTOR(2 DOWNTO 0);
		result:   out STD_LOGIC_VECTOR(31 DOWNTO 0);
		ZeroFlag:    	              out STD_LOGIC
	);
end ALU;

architecture Behavioral of ALU is 
begin
    process (all) begin
        case ALUControl is 
            when "010" =>
                result  <= a + b;
            when "110" => 
                result  <= a - b;
            when "000" => 
                result  <= a AND b;
            when "001" => 
                result  <= a OR b;
            when "111" => 
--                result  <= X"00000001" when ((a < b) = '1') else X"00000000";
                if (a < b) then result <= X"00000001"; else result <= X"00000000"; end if;
            when "101" => result <= a NOR b;
            when others =>
                result <= X"--------";
        end case;
    end process;
	ZeroFlag <= NOR result;
end Behavioral;
