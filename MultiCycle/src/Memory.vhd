library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use STD.TEXTIO.all;

entity Memory is
    generic (CAPACITY: integer; WORDSIZE: integer);
    Port (
        clk:       in STD_LOGIC;
        WE:        in STD_LOGIC;
        WriteData: in STD_LOGIC_VECTOR(WORDSIZE - 1 DOWNTO 0);
        Addr:      in STD_LOGIC_VECTOR(WORDSIZE - 1 DOWNTO 0);
        ReadData:  out STD_LOGIC_VECTOR(WORDSIZE - 1 DOWNTO 0)
    );
end Memory;

architecture Behavioral of Memory is
    TYPE RamType is array (0 TO  CAPACITY) of STD_LOGIC_VECtOR(WORDSIZE - 1 DOWNTO 0);
    SIGNAL RAM: RamType := (0  => X"20020005",
                            1  => X"2003000c", 
                            2  => X"2067fff7",
                            3  => X"00e22025",
                            4  => X"00642824",
                            5  => X"00a42820",
                            6  => X"10a7000a",
                            7  => X"0064202a",
                            8  => X"10800001",
                            9  => X"20050000",
                            10 => X"00e2202a",
                            11 => X"00853820",
                            12 => X"00e23822",
                            13 => X"ac670044",
                            14 => X"8c020050",
                            15 => X"08000011",
                            16 => X"20020001",
                            17 => X"ac020054",
                            others => (others => '0'));
begin
    process(clk, Addr) begin
    if (rising_edge(clk)) then 
        if(WE = '1') then 
             RAM(CONV_INTEGER(Addr) / 4) <= WriteData;
        end if;
    end if;
    ReadData <= (RAM(CONV_INTEGER(Addr) / 4));
	end process;

end Behavioral;
