library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Mips is
    port(
        clk, reset: in STD_LOGIC;
        PCF:        out STD_LOGIC_VECTOR(31 DOWNTO 0);
        instrF:     out STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemWriteM:  out STD_LOGIC;
        ALUOutM:    out STD_LOGIC_VECTOR(31 DOWNTO 0);
        WriteDataM: out STD_LOGIC_VECTOR(31 DOWNTO 0);
        ReadDataM:  out STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
end Mips;
    
architecture Behavioral of Mips is
    
    component Datapath
        port(
            clk, reset:  in  STD_LOGIC;
            MemToRegE:   in  STD_LOGIC;
            MemToRegM:   in  STD_LOGIC;
            MemToRegW:   in  STD_LOGIC;
            PCSrcD:      in  STD_LOGIC;
            branchD:     in  STD_LOGIC;
            ALUSrcE:     in  STD_LOGIC;
            RegDistE:    in  STD_LOGIC;
            RegWriteW:   in  STD_LOGIC;
            RegWriteM:   in  STD_LOGIC;
            RegWriteE:   in  STD_LOGIC;
            jumpD:       in  STD_LOGIC;
            ALUControlE: in  STD_LOGIC_VECTOR(3 downto 0);
            equalD:      out STD_LOGIC;
            PCF:         out STD_LOGIC_VECTOR(31 downto 0);
            instrF:      in  STD_LOGIC_VECTOR(31 downto 0);
            ALUOutM:     out STD_LOGIC_VECTOR(31 downto 0);
            WriteDataM:  out STD_LOGIC_VECTOR(31 downto 0);
            ReadDataM:   in  STD_LOGIC_VECTOR(31 downto 0);
            OPD, functD: out  STD_LOGIC_VECTOR(5 downto 0);
            flushE:      out STD_LOGIC
        );
    end component;
    component ControlUnit
        port(
            clk, reset:     in STD_LOGIC;
            opD, functD:    in STD_LOGIC_VECTOR(5 downto 0);
            flushE, equalD: in STD_LOGIC;
            branchD:        out STD_LOGIC;
            MemToRegE:      out STD_LOGIC;
            MemToRegM:      out STD_LOGIC;
            MemToRegW:      out STD_LOGIC;
            MemWriteM:      out STD_LOGIC;
            PCSrcD:         out STD_LOGIC;
            ALUSrcE:        out STD_LOGIC;
            RegDistE:       out STD_LOGIC;
            RegWriteE:      out STD_LOGIC;
            RegWriteM:      out STD_LOGIC;
            RegWriteW:      out STD_LOGIC;
            jumpD:          out STD_LOGIC;
            ALUControlE:    out STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    end component;
    SIGNAL OPD:         STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL functD:      STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL ALUControlE: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL flushE:      STD_LOGIC;
    SIGNAL equalD:      STD_LOGIC;
    SIGNAL branchD:     STD_LOGIC;
    SIGNAL MemToRegE:   STD_LOGIC;
    SIGNAL MemToRegM:   STD_LOGIC;
    SIGNAL MemToRegW:   STD_LOGIC;
    SIGNAL PCSrcD:      STD_LOGIC;
    SIGNAL ALUSrcE:     STD_LOGIC;
    SIGNAL RegDistE:    STD_LOGIC;
    SIGNAL RegWriteE:   STD_LOGIC;
    SIGNAL RegWriteM:   STD_LOGIC;
    SIGNAL RegWriteW:   STD_LOGIC;
    SIGNAL jumpD:       STD_LOGIC;
begin
    Controller: ControlUnit port map(
        clk       => clk,
        reset     => reset,
        opD       => opD,
        functD    => functD,
        flushE    => flushE,
        equalD    => equalD,
        branchD   => branchD,
        MemToRegE => MemToRegE,
        MemToRegM => MemToRegM,
        MemToRegW => MemToRegW,
        MemWriteM => MemWriteM,
        PCSrcD    => PCSrcD,
        ALUSrcE   => ALUSrcE,
        RegDistE  => RegDistE,
        RegWriteE => RegWriteE,
        RegWriteM => RegWriteM,
        RegWriteW => RegWriteW,
        jumpD     => jumpD, 
        ALUControlE => ALUControlE
    );
    
    DP: DataPath port map(
            clk         => clk,
            reset       => reset,
            MemToRegE   => MemToRegE,
            MemToRegM   => MemToRegM,
            MemToRegW   => MemToRegW,
            PCSrcD      => PCSrcD,
            branchD     => branchD,
            ALUSrcE     => ALUSrcE,
            RegDistE    => RegDistE,
            RegWriteW   => RegWriteW,
            RegWriteM   => RegWriteM,
            RegWriteE   => RegWriteE,
            jumpD       => jumpD,
            ALUControlE => ALUControlE,
            equalD      => equalD,
            PCF         => PCF,
            instrF      => instrF,
            ALUOutM     => ALUOutM,
            WriteDataM  => WriteDataM,
            ReadDataM   => ReadDataM,
            OPD         => OPD,
            functD      => functD,
            flushE      => flushE
        );

end Behavioral;
