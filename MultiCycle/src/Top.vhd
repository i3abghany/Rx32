library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Top is
    Port(
        clk, reset: in STD_LOGIC
    );
end Top;

architecture Behavioral of Top is
    component Mips 
        Port(
            clk, reset: in STD_LOGIC;
            ReadData:   in STD_LOGIC_VECTOR(31 DOWNTO 0);
            MemWrite:   out STD_LOGIC;
            WriteData:  inout STD_LOGIC_VECTOR(31 DOWNTO 0);
            InstrAddr:  out STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component Memory 
        generic (CAPACITY: integer; WORDSIZE: integer);
        port(
            clk: in STD_LOGIC;
            WE: in STD_LOGIC;
            Addr: in STD_LOGIC_VECTOR(WORDSIZE - 1 DOWNTO 0);
            WriteData: in STD_LOGIC_VECTOR(WORDSIZE - 1 DOWNTO 0);
            ReadData: out STD_LOGIC_VECTOR(WORDSIZE - 1 DOWNTO 0)
        );
    end component;
    SIGNAL ReadData: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MemWrite: STD_LOGIC;
    SIGNAL WriteData, InstrAddr: STD_LOGIC_VECTOR(31 DOWNTO 0);
begin
    Proc: Mips port map(
        clk => clk, reset => reset,
        ReadData => ReadData,
        MemWrite => MemWrite,
        WriteData => WriteData,
        InstrAddr => InstrAddr
    );
    
    Mem: Memory generic map(2048, 32) port map(
        clk => clk, WE => MemWrite,
        Addr => InstrAddr, 
        WriteData => WriteData,
        ReadData => ReadDAta
    );
end Behavioral;
