library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Datapath is
  Port ( 
    clk, reset: in STD_LOGIC;
    PCEnable:   in STD_LOGIC;
    IRWrite:    in STD_LOGIC;
    RegWrite:   in STD_LOGIC;
    ALUSrcA:    in STD_LOGIC;
    IorD:       in STD_LOGIC;
    MemToReg:   in STD_LOGIC;
    RegDist:    in STD_LOGIC;
    ALUSrcB:    in STD_LOGIC_VECTOR(2 DOWNTO 0);
    PCSrc:      in STD_LOGIC_VECTOR(1 DOWNTO 0);
    ALUControl: in STD_LOGIC_VECTOR(3 DOWNTO 0);
    ReadData:   in STD_LOGIC_VECTOR(31 DOWNTO 0);
    InstrAddr:  out STD_LOGIC_VECTOR(31 DOWNTO 0);
    WriteData:  out STD_LOGIC_VECTOR(31 DOWNTO 0);
    ZeroFlag:   out STD_LOGIC;
    OPCode:     out STD_LOGIC_VECTOR(5 DOWNTO 0);
    funct:      out STD_LOGIC_VECTOR(5 DOWNTO 0) 
  );
end Datapath;
architecture Behavioral of Datapath is
    component ALU 
        port (
            A, B:       in STD_LOGIC_VECTOR(31 DOWNTO 0);
            shamt:      in STD_LOGIC_VECTOR(4 DOWNTO 0);
            ALUControl: in STD_LOGIC_VECTOR(3 DOWNTO 0);
            result:     out STD_LOGIC_VECTOR(31 DOWNTO 0);
            ZeroFlag:   out STD_LOGIC
        );
    end component;
    
    component RegFile 
    port (
        clk:         in STD_LOGIC;
        we3:         in STD_LOGIC; -- write enable.
        A1, A2, WA3: in STD_LOGIC_VECTOR(4 DOWNTO 0);
        WD3:         in STD_LOGIC_VECTOR(31 DOWNTO 0);
        RD1, RD2:    out STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    end component;
    
    component Adder
        port( 
            A, B:  in STD_LOGIC_VECTOR(31 DOWNTO 0);
            y:     out STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component SL2
        port(
            A: in STD_LOGIC_VECTOR(31 DOWNTO 0);
            y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component SignExtend
        port(
            A: in STD_LOGIC_VECTOR(15 DOWNTO 0);
            Y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component Reg 
        generic (WIDTH: integer);
        port(
            clk, reset: in STD_LOGIC;
            d:          in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            q:          out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    end component;
    
    component RegEn
        generic (WIDTH: integer);
        port(
            clk, reset, en: in STD_LOGIC;
            d:              in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            q:              out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    end component;
    
    component Mux2 
        generic(WIDTH: integer);
        port(
            d0, d1: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            s:      in STD_LOGIC;
            y:      out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    end component;
    
    component Mux3 
        generic(WIDTH: integer);
        port(
            d0, d1, d2: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            s:          in STD_LOGIC_VECTOR(1 DOWNTO 0);
            y:          out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    end component;
    
    component Mux4
        generic(WIDTH: integer);
        port(
            d0, d1, d2, d3: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            s:              in STD_LOGIC_VECTOR(1 DOWNTO 0);
            y:              out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    end component;
    
    component Mux5 is
        generic (WIDTH: integer);
        Port(d0, d1, d2, d3, d4  : in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
             s : in STD_LOGIC_VECTOR (2 downto 0);
             y : out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
            );
    end component;
    
    component ZeroExtend
        Port(
            a: in STD_LOGIC_VECTOR(15 DOWNTO 0);
            y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    SIGNAL instr:         STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL PC:            STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL PCNext:        STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL PCJump:        STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL ALUOut:        STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL data:          STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL WD3:           STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL RD1, RD2:      STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SignImm:       STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL BranchAddr:    STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL DataA:         STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SrcA:          STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SrcB:          STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL ALUResult:     STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL WriteReg:      STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    SIGNAL shamt:         STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    SIGNAL ZeroExtended:  STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL ConstFour:     STD_LOGIC_VECTOR(31 DOWNTO 0) :=     X"00000004";
    
begin
    OPCode <= instr(31 DOWNTO 26);
    funct  <= instr(5 DOWNTO 0);    
    shamt  <= instr(10 DOWNTO 6);
    PCR:    RegEn generic map(32) port map(clk => clk, reset => reset, en => PCEnable, d => PCNext, q => PC);
    AdrMux: Mux2  generic map(32) port map(d0 => PC, d1 => ALUOut, s => IorD, y => InstrAddr);
    IR:     RegEn generic map(32) port map(clk => clk, reset => reset, en => IRWrite, d => ReadData, q => instr);
    
    DataReg: Reg generic map(32) port map(clk => clk, reset => reset, d => ReadData, q => data);
    WDMux:   Mux2 generic map(32) port map(d0 => ALUOut, d1 => data, s => MemToReg, y => WD3);
    
    RegDistMux: Mux2  generic map(5) port map(d0 => instr(20 DOWNTO 16), d1 => instr(15 DOWNTO 11), s => RegDist, y => WriteReg);
    
    RF: RegFile port map(clk => clk, WE3 => RegWrite, 
                         A1 => instr(25 DOWNTO 21), 
                         A2 => instr(20 DOWNTO 16),
                         WA3 => WriteReg,
                         WD3 => WD3, RD1 => RD1,
                         RD2 => RD2);
                         
    SignEx: SignExtend port map(a => instr(15 DOWNTO 0), y => SignImm); 
    
    
    BranchShifter: SL2 port map(a => SignImm, y => BranchAddr);
    
    AReg: Reg generic map(32) port map(clk => clk, reset => reset, d => RD1, q => DataA);
    BReg: Reg generic map(32) port map(clk => clk, reset => reset, d => RD2, q => WriteData);
    ALUSrcAMux: Mux2 generic map(32) port map(d0 => PC, d1 => DataA, s => ALUSrcA, y => SrcA);
    ZeroEx:     ZeroExtend port map(a => instr(15 DOWNTO 0), y => ZeroExtended);
    ALUSrcBMux: Mux5 generic map(32) port map(d0 => WriteData, d1 => ConstFour,
                                              d2 => SignImm, d3 => BranchAddr, 
                                              d4 => ZeroExtended,
                                              s => ALUSrcB, y => SrcB);
    MainALU: ALU port map(a => SrcA, b => SrcB, ALUControl => ALUControl, shamt => shamt, ZeroFlag => ZeroFlag, result => ALUResult);
    ALUReg: Reg generic map(32) port map(clk => clk, reset => reset, d => ALUResult, q => ALUOut);
    PCJump <= (PC(31 DOWNTO 28) & instr(25 DOWNTO 0) & "00");
    PCSrcMux: Mux3 generic map(32) port map(d0 => ALUResult, d1 => ALUOut, d2 => PCJump, s => PCSrc, y => PCNext);
end Behavioral;
