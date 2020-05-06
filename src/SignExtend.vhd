library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity SignExtend is 
	port(
		a: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
end SignExtend;

architecture Behavioral of SignExtend is 
begin
	y <= STD_LOGIC_VECTOR(RESIZE(SIGNED(a), y'length));
end Behavioral;

