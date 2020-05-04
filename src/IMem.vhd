library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity IMem is 
	generic (
		DataWidth: integer := 32,
		Capacity:  integer := 256
	);
	port(
		A:   in STD_LOGIC_VECTOR(31 DOWNTO 0);
		RD: out STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
end IMem;

architecture Behavioral of IMem is 
	TYPE   RamType is array(0 TO Capacity - 1) of STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
	SIGNAL IRAM: RamType;
begin 
	ResetState: for i in 0 to Capacity - 1 begin
		IRAM(i) <= (others => '0');
	end ResetState;
	RD <= IRAM(TO_INTEGER(A));
end Behavioral;