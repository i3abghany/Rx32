library IEEE;
use IEEE.STD_LOGIC_1164.all;
usE IEEE.NUMERIC_STD_UNSIGNED.all;

component ALU is 
	port(
		a, b: 	   in STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALUControl: in STD_LOGIC_VECTOR(2 DOWNTO 0);
		result:   out STD_LOGIC_VECTOR(31 DOWNTO 0);
		ZeroFlag:                     out STD_LOGIC
	);
end;

architecture Behavioral of ALU is 
begin
	case ALUControl is 
		when "010" => result <= a + b;
		when "110" => result <= a - b;
		when "000" => result <= a AND b;
		when "001" => result <= a OR b;
		when "111" => result <= X"00000001" when (a < b) else X"00000000";
		others     => result <= X"00000000";
end Behavioral;
