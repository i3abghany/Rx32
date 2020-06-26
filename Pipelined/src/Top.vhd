library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top is
    port(
        clk, reset: in STD_LOGIC
    );
end Top;

architecture Behavioral of Top is
    component Mips port(
        clk, reset: in STD_LOGIC;
        PCF:        out STD_LOGIC_VECTOR(31 DOWNTO 0);
        instrF:     in STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemWriteM:  out STD_LOGIC;
        ALUOutM:    out STD_LOGIC_VECTOR(31 DOWNTO 0);
        WriteDataM: out STD_LOGIC_VECTOR(31 DOWNTO 0);
        ReadDataM:  in STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    end component;
    
    component DMem
        generic (
            DataWidth:    integer := 32;
            Capacity:     integer := 256
        );
        port(
            clk, WE: in STD_LOGIC;
            A, WD: in STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
            RD: out STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0)
        );
    end component;
    
    component IMem
        generic (
            DataWidth: integer := 32;
            Capacity:  integer := 256
        );
        port(
            A:   in STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
            RD: out STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0)
        );
    end component;
    SIGNAL MemWrite:        STD_LOGIC := '0';
    SIGNAL InstructionAddr: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL Instruction:     STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL DataAddr:        STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL WriteData:       STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL ReadData:        STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
begin

    Processor: Mips port map(
        clk => clk, reset => reset,
        PCF => InstructionAddr,
        instrF => Instruction,
        MemWriteM => MemWrite,
        ALUOutM   => DataAddr,
        WriteDataM => WriteData,
        ReadDataM  => ReadData
    );
    
    DataMemory: DMem generic map(DataWidth => 32, Capacity => 256) port map(
        clk => clk,
        WE => MemWrite, 
        A => DataAddr, 
        WD => WriteData,
        RD => ReadData
    );
    
    InstructionMemory: IMem generic map(DataWidth => 32, Capacity => 32) port map(
        A => InstructionAddr,
        RD => Instruction
    );

end Behavioral;
