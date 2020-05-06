library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity IMem is 
	generic (
		DataWidth: integer := 32;
		Capacity:  integer := 256
	);
	port(
		A:   in STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		RD: out STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0)
	);
end IMem;

architecture Behavioral of IMem is 
	TYPE   RamType is array(0 TO Capacity - 1) of STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
	SIGNAL IRAM: RamType;
begin 
    process(all) begin
        for i in 0 to (Capacity - 1) loop
            IRAM(i) <= (others => '0');
        end loop;
	end process;
	
	RD <= IRAM(CONV_INTEGER(A));
end Behavioral;
