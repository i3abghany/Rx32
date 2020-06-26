library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Controller is
    Port(
        clk, reset: in STD_LOGIC;
        OPCode, funct:  in STD_LOGIC_VECTOR(5 DOWNTO 0);
        ZeroFlag:       in STD_LOGIC; 
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
end Controller;

architecture Behavioral of Controller is
    component MainController 
        Port (
            clk, reset: in STD_LOGIC;
            OPCode:     in STD_LOGIC_VECTOR(5 DOWNTO 0);
            funct:      in STD_LOGIC_VECTOR(5 DOWNTO 0);
            PCWrite:    out STD_LOGIC;
            MemWrite:   out STD_LOGIC;
            IRWrite:    out STD_LOGIC;
            RegWrite:   out STD_LOGIC;
            ALUSrcA:    out STD_LOGIC;
            branch:     out STD_LOGIC;
            IorD:       out STD_LOGIC;
            MemToReg:   out STD_LOGIC;
            RegDist:    out STD_LOGIC;
            ALUSrcB:    out STD_LOGIC_VECTOR(2 DOWNTO 0);
            PCSrc:      out STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALUOp:      out STD_LOGIC_VECTOR(1 DOWNTO 0) 
        );
    end component;
    
    component ALUController
        Port(
            funct:      in STD_LOGIC_VECTOR(5 DOWNTO 0);
            OPCode:     in STD_LOGIC_VECTOR(5 DOWNTO 0);
            ALUOp:      in STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALUControl: out STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    end component;
    SIGNAL ALUOp:   STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL PCWrite: STD_LOGIC;
    SIGNAL branch:  STD_LOGIC;
begin
    MainDecoder: MainController port map(
        clk => clk, reset => reset,
        funct => funct,
        OPCode => OPCode, PCWrite => PCWrite, 
        MemWrite => MemWrite, IRWrite => IRWrite, 
        RegWrite => RegWrite, ALUSrcA => ALUSrcA,
        branch => branch, IorD => IorD,
        MemToReg => MemToReg, RegDist => RegDist,
        ALUSrcB => ALUSrcB, PCSrc => PCSrc, 
        ALUOp => ALUOp
    );
    
    ALUDecoder: ALUController port map(
        funct => funct, OPCode => OPCode, ALUOp => ALUOp, ALUControl => ALUControl
    );
    
    PCEnable <= PCWrite OR (branch AND ZeroFlag);
end Behavioral;
