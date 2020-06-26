library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Datapath is
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
end Datapath;

architecture Structural of Datapath is
    component HazardUnit
        port(
            RSD, RTD, RSE, RTE: in STD_LOGIC_VECTOR(4 DOWNTO 0);
            WriteRegE:          in STD_LOGIC_VECTOR(4 DOWNTO 0);
            WriteRegW:          in STD_LOGIC_VECTOR(4 downto 0);
            WriteRegM:          in STD_LOGIC_VECTOR(4 downto 0);
            RegWriteE:          in STD_LOGIC;
            RegWriteW:          in STD_LOGIC;
            RegWriteM:          in STD_LOGIC;
            MemToRegE:          in STD_LOGIC;
            MemToRegM:          in STD_LOGIC;
            branchD:            in STD_LOGIC;
            jumpD:              in STD_LOGIC;
            ForwardAD:          out STD_LOGIC;
            ForwardBD:          out STD_LOGIC;
            ForwardAE:          out STD_LOGIC_VECTOR(1 DOWNTO 0);
            ForwardBE:          out STD_LOGIC_VECTOR(1 DOWNTO 0);
            StallF:             out STD_LOGIC;
            StallD:             out STD_LOGIC;
            FlushE:             out STD_LOGIC
        );
    end component;
            
    component ALU
        port(
            A, B:       in  STD_LOGIC_VECTOR(31 downto 0);
            result:     out STD_LOGIC_VECTOR(31 downto 0);
            shamt:      in STD_LOGIC_VECTOR (4 DOWNTO 0);
            ALUControl: in  STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    component RegFile
        port(
            clk:         in  STD_LOGIC;
            WE3:         in  STD_LOGIC;
            A1, A2, WA3: in  STD_LOGIC_VECTOR(4 DOWNTO 0);
            WD3:         in  STD_LOGIC_VECTOR(31 DOWNTO 0);
            RD1, RD2:    out STD_LOGIC_VECTOR(31 DOWNTO 0)
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

    component Mux3
        generic (WIDTH: integer := 32);
        port(d0, d1, d2  : in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
             s : in STD_LOGIC_VECTOR (1 downto 0);
             y : out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    end component;
    
    component SL2 
        port(
            a:  in STD_LOGIC_VECTOR(31 DOWNTO 0);
            y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component SignExtend 
        port(
            a: in STD_LOGIC_VECTOR(15 DOWNTO 0);
            y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;
    
    component Adder 
        generic(WIDTH: integer := 32);
        port(
            A, B: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            Y: out std_logic_vector(width - 1 DOWNTO 0)
        );
    end component;
     
    component EqualityComp is
        port(
            A, B: in STD_LOGIC_VECTOR(31 DOWNTO 0);
            y: out STD_LOGIC
        );
    end component;
    
    component Mux2
        generic(WIDTH: integer := 32);
        port(
            d0, d1: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            s:      in std_logic;
            y:      out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    end component;
    
    SIGNAL ForwardAD:      STD_LOGIC := '0';
    SIGNAL ForwardBD:      STD_LOGIC := '0';
    SIGNAL StallF:         STD_LOGIC := '0';
    SIGNAL StallD:         STD_LOGIC := '0';
    SIGNAL CStallF:        STD_LOGIC := '0';
    SIGNAL CStallD:        STD_LOGIC := '0';
    SIGNAL FlushD:         STD_LOGIC := '0';
    SIGNAL ForwardAE:      STD_LOGIC_VECTOR (1 DOWNTO 0) := (others => '0');
    SIGNAL ForwardBE:      STD_LOGIC_VECTOR (1 DOWNTO 0) := (others => '0');
    SIGNAL RSD, RTD, RDD:  STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    SIGNAL RSE, RTE, RDE:  STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    SIGNAL WriteRegE:      STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    SIGNAL WriteRegM:      STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    SIGNAL WriteRegW:      STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    SIGNAL PCNextFD:       STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL PCNextBRFD:     STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL PCPlus4F:       STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL PCBranchD:      STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SignImmD:       STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SignImmF:       STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SignImmE:       STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SignImmShD:     STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SrcAD, SrcADz:  STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0'); -- z suffix indicates mux result (either regular or forwarded signal).
    SIGNAL SrcBD, SrcBDz:  STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SrcAE, SrcAEz:  STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0'); 
    SIGNAL SrcBE, SrcBEz1: STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL SrcBEz2:        STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL PCPlus4D:       STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL instrD:         STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL ALUOutW:        STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL ALUOutE:        STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL ReadDataW:      STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL ResultW:        STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL PCJump:         STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    SIGNAL ImmD:           STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
    SIGNAL shamtD:         STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
    SIGNAL shamtE:         STD_LOGIC_VECTOR (4 DOWNTO 0) := (others => '0');
begin

    -----------------------------------------------------
    -- Instructions fields.
    -----------------------------------------------------
    OPD    <= instrD(31 DOWNTO 26);
    functD <= instrD(5 DOWNTO 0);
    RSD    <= instrD(25 DOWNTO 21);
    RTD    <= instrD(20 DOWNTO 16);
    RDD    <= instrD(15 DOWNTO 11);
    ImmD   <= instrD(15 DOWNTO 0);
    shamtD  <= instrD(4 DOWNTO 0); 
    -----------------------------------------------------
    -- Next PC logic.
    -----------------------------------------------------
    PCJump <= PCPlus4D(31 DOWNTO 28) & instrD(25 DOWNTO 0) & "00";
    PCBranchMux: Mux2 generic map(32) port map(d0 => PCPlus4F, d1 => PCBranchD, s => PCSrcD, y => PCNextBRFD);
    PCJumpMux:   Mux2 generic map(32) port map(d0 => PCNextBRFD, d1 => PCJump, s => jumpD, y => PCNextFD);
    
    -----------------------------------------------------
    -- Register file.
    -----------------------------------------------------
    RF: RegFile port map(clk => clk, WE3 => RegWriteW, 
                         A1 => RSD, A2 => RTD, 
                         WA3 => WriteRegW, WD3 => ResultW, 
                         RD1 => SrcAD, RD2 => SrcBD);
                         
    -----------------------------------------------------
    -- Fetch stage (first stage out of five.)
    -----------------------------------------------------
    
    CStallF <= NOT StallF;
    CStallD <= NOT StallD;
    
    -- With no clear signal.
    PCReg: RegRCEn generic map(32)  port map(clk => clk, reset => reset,
                                             en => CStallF, d => PCNextFD,
                                             q => PCF, clear => '0');
    PCAdderF: Adder generic map(32) port map(A => PCF, B => X"00000004", y => PCPlus4F);
    
    -----------------------------------------------------
    -- Decode stage (second stage out of five.)
    -----------------------------------------------------
    
    -- PC pipeline register.
    PRegD1: RegRCEn generic map(32) port map(clk => clk, reset => reset, en => CStallD, d => PCPlus4F, q => PCPlus4D, clear => '0');
    
    -- instruction pipeline address.
    PRegD2: RegRCEn generic map(32) port map(clk => clk, reset => reset, en => CStallD, d => instrF, q => instrD, clear => flushD);
    
    -- Branching address calculation.
    ImmSignExtend: SignExtend port map(A => ImmD, Y => SignImmD);
    Shift2: SL2 port map(A => SignImmD, Y => SignImmShD);
    BranchAdder: Adder port map(A => SignImmShD, B => PCPlus4D, Y => PCBranchD);
    
    ForwardMuxAD: Mux2 generic map(32) port map(d0 => SrcAD, d1 => ALUOutM, s => ForwardAD, y => SrcADz);
    ForwardMuxBD: Mux2 generic map(32) port map(d0 => SrcBD, d1 => ALUOutM, s => ForwardBD, y => SrcBDz);
    
    BranchComp: EqualityComp port map(A => SrcADz, B => SrcBDz, y => equalD);
    
    -----------------------------------------------------
    -- Execute stage (third stage out of five.)
    -----------------------------------------------------
    
    -- RS pipeline register.
    PRegE1: RegRCEn generic map(5) port map(clk => clk, reset => reset, clear => FlushE, d => RSD, q => RSE, en => '1');
    
    -- RT pipeline register
    PRegE2: RegRCEn generic map(5) port map(clk => clk, reset => reset, clear => FlushE, d => RTD, q => RTE, en => '1');
    
    -- RE pipeline register
    PRegE3: RegRCEn generic map(5) port map(clk => clk, reset => reset, clear => FlushE, d => RDD, q => RDE, en => '1');
    
    -- Sign immediate pipeline register.
    PRegE4: RegRCEn generic map(32) port map(clk => clk, reset => reset, clear => FlushE, d => SignImmD, q => SignImmE, en => '1');
    
    -- SraA & SrcB pipeline register.
    PRegE5: RegRCEn generic map(32) port map(clk => clk, reset => reset, clear => FlushE, d => SrcAD, q => SrcAE, en => '1');
    PRegE6: RegRCEn generic map(32) port map(clk => clk, reset => reset, clear => FlushE, d => SrcBD, q => SrcBE, en => '1');
    
    -- Shamt pipeline register.
    PRegE7: RegRCEn generic map(5) port map(clk => clk, reset => reset, clear => FlushE, d => shamtD, q => shamtE, en => '1');
    
    -- WriteRegE Selection mux.
    WRMuxE: Mux2 generic map(5) port map(d0 => RTE, d1 => RDE, s => RegDistE, y => WriteRegE);
    
    -- Src A and Src B selection muxes.
    ForwardAEMux: Mux3 generic map(32) port map(d0 => SrcAE, d1 => ResultW, d2 => ALUOutM, s => ForwardAE, y => SrcAEz);
    ForwardBEMux: Mux3 generic map(32) port map(d0 => SrcBE, d1 => ResultW, d2 => ALUOutM, s => ForwardBE, y => SrcBEz1);
    
    ALUSrcBEMux:  Mux2 generic map(32) port map(d0 =>SrcBEz1, d1 => SignImmE, s => ALUSrcE, y => SrcBEz2);
    
    MainALU: ALU port map(A => SrcAEz, B => SrcBEz2, ALUControl => ALUControlE, result => ALUOutE, shamt => shamtE);
    
    -----------------------------------------------------
    -- Memory stage (fourth stage out of five.)
    -----------------------------------------------------
    
    -- WriteRegE pipeline register.
    PRegM1: RegRCEn generic map(5) port map(clk => clk, reset => reset, clear => '0', d => WriteRegE, q => WriteRegM, en => '1');
    
    -- ALUOut pipeline register
    PRegM2: RegRCEn generic map(32) port map(clk => clk, reset => reset, clear => '0', d => ALUOutE, q => ALUOutM, en => '1');
    
    -- WriteData pipeline register 
    PRegM3: RegRCEn generic map(32) port map(clk => clk, reset => reset, clear => '0', d => SrcBEz1, q => WriteDataM, en => '1');

    -----------------------------------------------------
    -- Register Writeback stage (fifth stage out of five.)
    -----------------------------------------------------
    
    -- ReadDataM pipeline register.
    PRegW1: RegRCEn generic map(32) port map(clk => clk, reset => reset, clear => '0', d => ReadDataM, q => ReadDataW, en => '1');
    
    -- ALUOutM pipeline register
    PRegW2: RegRCEn generic map(32) port map(clk => clk, reset => reset, clear => '0', d => ALUOutM, q => ALUOutW, en => '1');
    
    -- WriteRegM pipeline register
    PRegW3: RegRCEn generic map(5) port map(clk => clk, reset => reset, clear => '0', d => WriteRegM, q => WriteRegW, en => '1');
    
    -- Result Selection mux.
    ResultMux: Mux2 generic map(32) port map(d0 => ReadDataW, d1 => ALUOutW, s => MemToRegW, y => ResultW);
    
    
    -----------------------------------------------------
    -- Hazard Unit.
    -----------------------------------------------------
    
    HU: HazardUnit port map(
        RSD       => RSD,
        RTD       => RTD,
        RSE       => RSE,
        RTE       => RTE,
        WriteRegE => WriteRegE,         
        WriteRegW => WriteRegW,         
        WriteRegM => WriteRegM,         
        RegWriteE => RegWriteE,         
        RegWriteW => RegWriteW,         
        RegWriteM => RegWriteM,         
        MemToRegE => MemToRegE,         
        MemToRegM => MemToRegM,         
        branchD   => branchD,           
        jumpD     => jumpD,              
        ForwardAD => ForwardAD,       
        ForwardBD => ForwardBD,       
        ForwardAE => ForwardAE,       
        ForwardBE => ForwardBE,       
        StallF    => StallF,            
        StallD    => StallD,            
        FlushE    => FlushE          
    );
    
end Structural;
