library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity RegFile is 
	port(
		clk: in STD_LOGIC;
		WE3: in STD_LOGIC;
		A1, A2, WA3: in STD_LOGIC_VECTOR(4 DOWNTO 0);
		WD3: in STD_LOGIC_VECTOR(31 DOWNTO 0);
		RD1, RD2: out STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
end RegFile;

architecture Behavioral of RegFile is 
	TYPE   RamType is array (31 DOWNTO 0) of STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem: RamType;
begin 
	process(clk) begin
		if(rising_edge(clk)) then
			if (WE3 = '1') then 
				mem(CONV_INTEGER(WA3)) <= WD3;
			end if;
		end if;
	end process;
	
	process(all) begin
		if(A1 = "00000") then 
			RD1 <= X"00000000";
		else RD1 <= mem(CONV_INTEGER(A1));
		end if;
		
		if(A2 = "00000") then 
			RD2 <= X"00000000";
		else RD2 <= mem(CONV_INTEGER(A2));
		end if;
	end process;
end Behavioral;

