library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity SignExtend is 
	port(
		a: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
    attribute dont_touch : string;
    attribute dont_touch of SignExtend: entity is "true|yes";
end SignExtend;

architecture Behavioral of SignExtend is 
begin
	 y <= STD_LOGIC_VECTOR(RESIZE(SIGNED(a), y'length));
end Behavioral;
