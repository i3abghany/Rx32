library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top is
    port(
        PC: out STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemoryReadData: out STD_LOGIC_VECTOR(31 DOWNTO 0); 
        InstructionDumOut: out STD_LOGIC;
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
    
    component blk_mem_gen_0 port(
            clka : IN STD_LOGIC;
            ena : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
         );
    end component;
    
    component ClkDivider port (
            reset: in STD_LOGIC;
            clk_in: in STD_LOGIC;
            clk_out: out STD_LOGIC
        );
    end component;
    
    SIGNAL MemWrite:        STD_LOGIC := '0';
    SIGNAL Instruction:     STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DataAddr:        STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WriteData:       STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ReadData:        STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL IMemClk:         STD_LOGIC;
    alias InstructionAddr is PC(7 DOWNTO 2);
    
    attribute noopt: boolean;
    attribute noopt of InstructionMemory: label is TRUE;
    
begin
    MemoryReadData <= ReadData;
    Processor: Mips port map(
        clk => clk, reset => reset,
        PCF => PC,
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
        A => PC,
        RD => Instruction
    );
    
    InstructionDumOut <= (XOR (PC)) AND (XOR Instruction);
end Behavioral;
