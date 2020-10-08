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
	CONSTANT IRAM: RamType := (	     
            X"20020005",
            X"2003000c",
            X"2067fff7",
            X"00e22025",
            X"00642824",
            X"00a42820",
            X"10a7000a",
            X"0064202a",
            X"10800001",
            X"20050000",
            X"00e2202a",
            X"00853820",
            X"00e23822",
            X"ac670044",
            X"8c020050",
            X"08000011",
            X"20020001",
            X"ac020054",
            X"00000000",
            X"00000000",
            X"00000000",
            X"00000000",
            X"00000000",
            X"00000000",
            X"00000000",
            X"00000000",
            X"00000000",
            X"00000000",
            X"00000000",
            X"00000000",
            X"2A110009",
            X"00000000"
	);
	
begin 
	RD <= IRAM(TO_INTEGER(UNSIGNED(A)) / 4);
end Behavioral;
