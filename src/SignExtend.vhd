library IEEE;
use IEEE.STD_LOGIC_VECTOR.all;

entity SignExtend is 
	port(
		a: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		y: out: STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
end SignExtend;

architecture Behavioral of SignExtend is 
begin
	y <= (X"FFFF" & a) when a(15) else ("0000" & a);
end Behavioral;

