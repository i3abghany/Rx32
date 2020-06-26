library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Mips is
    Port(
        clk, reset: in STD_LOGIC;
        ReadData:  in STD_LOGIC_VECTOR(31 DOWNTO 0);
        MemWrite:  out STD_LOGIC;
        WriteData: inout STD_LOGIC_VECTOR(31 DOWNTO 0);
        InstrAddr: out STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
end Mips;

architecture Behavioural of Mips is
    component Datapath
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
    end component;
    component Controller
        Port(
            clk, reset: in STD_LOGIC;
            OPCode, funct:  in STD_LOGIC_VECTOR(5 DOWNTO 0);
            ZeroFlag:        in STD_LOGIC; 
            PCEnable:       out STD_LOGIC;
            MemWrite:       out STD_LOGIC;
            IRWrite:        out STD_LOGIC;
            RegWrite:       out STD_LOGIC;
            ALUSrcA:        out STD_LOGIC;
            IorD:           out STD_LOGIC;
            MemToReg:       out STD_LOGIC;
            RegDist:        out STD_LOGIC;
            ALUSrcB:        out STD_LOGIC_VECTOR(2 DOWNTO 0);
            PCSrc:          out STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALUControl:     out STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    end component;
    SIGNAL PCEnable, IRWrite, RegWrite, ALUSrcA, IorD, MemToReg, RegDist: STD_LOGIC;
    SIGNAL ZeroFlag:      STD_LOGIC;
    SIGNAL ALUSrcB:       STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL PCsrc:         STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ALUControl:    STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL OPCode, funct: STD_LOGIC_VECTOR(5 DOWNTO 0); 
begin

    MainDatapath: Datapath port map(
        clk => clk, reset => reset,
        PCEnable   => PCEnable,
        IRWrite    => IRWrite,
        RegWrite   => RegWrite,
        ALUSrcA    => ALUSrcA,
        IorD       => IorD,
        MemToReg   => MemToReg,
        RegDist    => RegDist,
        ALUSrcB    => ALUSrcB, 
        PCSrc      => PCsrc,
        ALUControl => ALUControl,
        ReadData   => ReadData,
        InstrAddr  => InstrAddr,
        WriteData  => WriteData,
        ZeroFlag   => ZeroFlag,
        OPCode     => OPCode,
        funct      => funct
    );
    
    ControlUnit: Controller port map(
        clk        => clk,
        reset      => reset,
        OPCode     => OPCode,
        funct      => funct,
        ZeroFlag   => ZeroFlag,
        PCEnable   => PCEnable,
        MemWrite   => MemWrite,
        IRWrite    => IRWrite,
        RegWrite   => RegWrite,
        ALUSrcA    => ALUSrcA,
        IorD       => IorD,     
        MemToReg   => MemToReg,       
        RegDist    => RegDist,        
        ALUSrcB    => ALUSrcB,        
        PCSrc      => PCSrc,      
        ALUControl => ALUControl
    );
    
end Behavioural;
