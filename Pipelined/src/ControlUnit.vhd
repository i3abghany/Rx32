library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity ControlUnit is
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
end ControlUnit;

architecture Behavioral of ControlUnit is
    component MainDecoder 
        port(
            OPCode:   in STD_LOGIC_VECTOR(5 downto 0);
            MemToReg: out STD_LOGIC;
            MemWrite: out STD_LOGIC;
            branch:   out STD_LOGIC;
            ALUSrc:   out STD_LOGIC;
            RegDist:  out STD_LOGIC;
            RegWrite: out STD_LOGIC;
            jump:     out STD_LOGIC;
            ALUOp:    out STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    end component;
    
    component ALUDecoder 
    port(
        funct:      in STD_LOGIC_VECTOR (5 DOWNTO 0);
        op:         in STD_LOGIC_VECTOR (5 DOWNTO 0);
        ALUOp:      in STD_LOGIC_VECTOR (1 DOWNTO 0);
        ALUControl: out STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
    end component;
    
    component RegRCEn
        generic(WIDTH: integer := 32);
        port(
            clk, reset, clear, en: in STD_LOGIC;
            d: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            q: out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    end component;
    component FlipFlop
        port(
            clk, reset, clear, en: in STD_LOGIC;
            d: in STD_LOGIC;
            q: out STD_LOGIC
        );
    end component;
    SIGNAL ALUOpD: STD_LOGIC_VECTOR(1 downto 0);
    SIGNAL MemToRegD, MemWriteD, ALUSrcD: STD_LOGIC;
    SIGNAL RegDistD, RegWriteD: STD_LOGIC;
    SIGNAL ALUControlD: STD_LOGIC_VECTOR(3 downto 0);
    SIGNAL MemWriteE: STD_LOGIC;
begin
    
    MD: MainDecoder port map(
        OPCode   => opD,   
        MemToReg => MemToRegD,
        MemWrite => MemWriteD,
        branch   => branchD,
        ALUSrc   => ALUSrcD, 
        RegDist  => RegDistD,
        RegWrite => RegWriteD,
        jump     => jumpD,
        ALUOp    => ALUOpD   
    );
    
    AD: ALUDecoder port map(
        funct      => functD,
        op         => opD,
        ALUOp      => ALUOpD,     
        ALUControl => ALUControlD
    );
  
    -----------------------------------------------------
    -- Decode to Execute stages registers.
    -----------------------------------------------------
    FFDE1:   FlipFlop port map(clk => clk, reset => reset, clear => FlushE, d => RegWriteD, q => RegWriteE, en => '1');
    FFDE2:   FlipFlop port map(clk => clk, reset => reset, clear => FlushE, d => MemtoRegD, q => MemtoRegE, en => '1');
    FFDE3:   FlipFlop port map(clk => clk, reset => reset, clear => FlushE, d => MemWriteD, q => MemWriteE, en => '1');
    FFDE4:   FlipFlop port map(clk => clk, reset => reset, clear => FlushE, d => MemWriteD, q => MemWriteE, en => '1');
    PRegDE1: RegRCEn generic map(4) port map(clk => clk, reset => reset, clear => FlushE, d => ALUControlD, q => ALUControlE, en => '1');
    FFDE5:   FlipFlop port map(clk => clk, reset => reset, clear => FlushE, d => ALUSrcD, q =>  ALUSrcE, en => '1');
    FFDE6:   FlipFlop port map(clk => clk, reset => reset, clear => FlushE, d => RegDistD, q =>  RegDistE, en => '1');
    
    -----------------------------------------------------
    -- Execute to Memory stages registers.
    -----------------------------------------------------
    FFEM1: FlipFlop port map(clk => clk, reset => reset, clear => '0', d => RegWriteE, q => RegWriteM, en => '1');
    FFEM2: FlipFlop port map(clk => clk, reset => reset, clear => '0', d => MemtoRegE, q => MemtoRegM, en => '1');
    FFEM3: FlipFlop port map(clk => clk, reset => reset, clear => '0', d => MemWriteE, q => MemWriteM, en => '1');

    -----------------------------------------------------
    -- Memory to Writeback stages registers.
    -----------------------------------------------------
    FFMW1: FlipFlop port map(clk => clk, reset => reset, clear => '0', d => RegWriteM, q => RegWriteW, en => '1');
    FFMW2: FlipFlop port map(clk => clk, reset => reset, clear => '0', d => MemtoRegM, q => MemtoRegW, en => '1');
    

end Behavioral;
