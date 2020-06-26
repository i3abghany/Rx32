library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD_UNSIGNED.all;

entity Adder is 
	port(
		a:  in STD_LOGIC_VECTOR(31 DOWNTO 0);
		b:  in STD_LOGIC_VECTOR(31 DOWNTO 0);
		y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
end Adder;

architecture Behavioral of Adder is 
begin
	y <= a + b;
end Behavioral;

