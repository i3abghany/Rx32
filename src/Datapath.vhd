library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity Datapath is 
	port(
		clk, reset:                    		       in STD_LOGIC;
		MemToReg, PCSrc:               		       in STD_LOGIC;
		ALUSrc, RegDist:               		       in STD_LOGIC;
		RegWrite, jump:                		       in STD_LOGIC;
		ZeroFlag:                                 out STD_LOGIC;
		ALUControl: 			in STD_LOGIC_VECTOR(2 DOWNTO 0);
		instr:                 in STD_LOGIC_VECTOR(31 DOWNTO 0);
		ReadData: 			   in STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC:    			   buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALUOut, WriteData: buffer STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
end Datapath;

architecture Structural of Datapath is 
	component ALU is 
		port(
			a, b: 	   in STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUControl: in STD_LOGIC_VECTOR(1 DOWNTO 0);
			result:   out STD_LOGIC_VECTOR(31 DOWNTO 0);
			zero:    					  out STD_LOGIC
		);
	end component;
	
	component RegFile is 
		port(
			clk: in STD_LOGIC;
			WE3: in STD_LOGIC;
			A1, A2, WA3: in STD_LOGIC_VECTOR(4 DOWNTO 0);
			WD3: in STD_LOGIC_VECTOR(31 DOWNTO 0);
			RD1, RD2: out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
	component Adder is
		port(
			a:  in STD_LOGIC_VECTOR(31 DOWNTO 0);
			b:  in STD_LOGIC_VECTOR(31 DOWNTO 0);
			y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
	component SL2 is 
		port(
			a:  in STD_LOGIC_VECTOR(31 DOWNTO 0);
			y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
	component SignExtend is 
		port(
			a: in STD_LOGIC_VECTOR(15 DOWNTO 0);
			y: out: STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
	component Reg is 
		generic(WIDTH: integer := 32);
		port(
			clk, reset: in STD_LOGIC;
			d:  in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			q: out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
		);
	end component;
	
	component Mux2 is 
		generic(WIDTH: integer := 32);
		port(
			d0, d1: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			s: in STD_LOGIC;
			y: out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
		);
	end component;
	
	
	SIGNAL PCplus4, PCJump, PCNext: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SignImm:                    STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MulImm: 	                STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PCBranch:                STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WriteReg:				STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL Result:					STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SrcA, SrcBMux			STD_LOGIC_VECTOR(31 DOWNTO 0);
begin
	-- Next PC logic.
	PCAdder: Adder(PC, X"00000004", PCplus4);
	PCJump <= (PCplus4(31 DOWNTO 28) & instr(25 DOWNTO 0) & "00");
	PCReg:              Reg: generic map(32) port map(clk, reset, PCNext, PC);
	SS:                 SignExtend port map(instr(15 DOWNTO 0), SignImm);
	MulBy4:             SL2 port map(SignImm, MulImm);
	BranchAdder:        Adder port map(PCplus4, MulImm, PCBranch);
	BranchMux:          Mux2 generic map(32) port map(PCplus4, PCBranch, PCSrc, IsBranchPC);
	JumpMux:            Mux2 generic map(32) port map(IsBranchPC, PCJump, jump, PCNext);
	
	-- Register File Logic.
	Mux2 RegMux: generic map(5) port map(instr(20 DOWNTO 16), instr(15 DOWNTO 11), RegDist, WriteReg);
	Mux2 ResultMUX: generic map(31) port map(ALUOut, ReadData, MemToReg, Result); 
	RF: RegFile port map(clk, RegWrite, instr(25 DOWNTO 21), instr(21 DOWNTO 16), WriteReg, Result, SrcA, WriteData);
	
	-- ALU logic.
	SrcBMux: Mux2 generic map(32) port map(WriteData, SignImm, ALUSrc, SrcB);
	ALU: MainALU port map(SrcA, SrcB, ALUControl, ALUOut, ZeroFlag);
end Structural;
