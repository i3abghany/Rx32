library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity Datapath is 
	port(
		clk, reset:                    		               in STD_LOGIC;
		MemToReg, PCSrc:               		               in STD_LOGIC;
		ALUSrc, RegDist:               		               in STD_LOGIC;
		RegWrite, jump:                		               in STD_LOGIC;
		jumpReg:		 			       in STD_LOGIC;
		jumpLink:                          in STD_LOGIC;
		LUIEnable:                        in STD_LOGIC;
		ZeroFlag:                                             out STD_LOGIC;
		ALUControl: 			   in STD_LOGIC_VECTOR( 2 DOWNTO 0);
		instr:                             in STD_LOGIC_VECTOR(31 DOWNTO 0);
		ReadData: 			   in STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC:    			       buffer STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALUOut, WriteData:             buffer STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
end Datapath;

architecture Structural of Datapath is 
	component ALU is 
		port(
			a, b: 	                  in STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUControl:                in STD_LOGIC_VECTOR(2 DOWNTO 0);
			result:                  out STD_LOGIC_VECTOR(31 DOWNTO 0);
			ZeroFlag:    	                             out STD_LOGIC
		);
	end component;
	
	component RegFile is 
		port(
			clk:                                         in STD_LOGIC;
			WE3:                                         in STD_LOGIC;
			A1, A2, WA3:              in STD_LOGIC_VECTOR(4 DOWNTO 0);
			WD3:                     in STD_LOGIC_VECTOR(31 DOWNTO 0);
			RD1, RD2:               out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
	component Adder is
		port(
			a:                       in STD_LOGIC_VECTOR(31 DOWNTO 0);
			b:                       in STD_LOGIC_VECTOR(31 DOWNTO 0);
			y:                      out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
	component SL2 is 
		port(
			a:                        in STD_LOGIC_VECTOR(31 DOWNTO 0);
			y:                       out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
	component SignExtend is 
		port(
			a:                       in STD_LOGIC_VECTOR(15 DOWNTO 0);
			y:                      out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
	component Reg is 
		generic(WIDTH: integer := 32);
		port(
			clk, reset:                                  in STD_LOGIC;
			d:                in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			q:               out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
		);
	end component;
	
	component Mux2 is 
		generic(WIDTH: integer := 32);
		port(
			d0, d1:           in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			s:                                           in STD_LOGIC;
			y:               out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
		);
	end component;
	
	
	SIGNAL PCplus4, PCJump, PCNext:             STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SignImm:                             STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MulImm: 	                            STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PCBranch:                            STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL WriteReg:              		    STD_LOGIC_VECTOR( 4 DOWNTO 0);
	SIGNAL Result:			       	    STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ResultToRegFile:             STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SrcA, SrcB:			        STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL IsBranchPC:			        STD_LOGIC_VECTOR(31 DOWNTO 0);      
	SIGNAL IsJumpPC:			        STD_LOGIC_VECTOR(31 DOWNTO 0);  
    SIGNAL WriteRegFinal:			    STD_LOGIC_VECTOR(4 DOWNTO 0);                   
	SIGNAL ReturnReg:					STD_LOGIC_VECTOR(4 DOWNTO 0) := "11111";
    SIGNAL LUIorResult:                 STD_LOGIC_VECTOR(31 DOWNTO 0);
begin
	-- Next PC logic.
	PCJump <= (PCplus4(31 DOWNTO 28) & instr(25 DOWNTO 0) & "00");
	PCReg:              Reg generic map(32) port map(clk => clk, reset => reset, d => PCNext, q => PC);
	PCAdder:            Adder  port map(a => PC, b => X"00000004", y => PCplus4);
	SS:                 SignExtend port map(a => instr(15 DOWNTO 0), y => SignImm);
	MulBy4:             SL2 port map(a => SignImm, y => MulImm);
	BranchAdder:        Adder port map(a => MulImm, b => PCplus4, y => PCBranch);
	BranchMux:          Mux2 generic map(32) port map(d0 => PCplus4, d1 => PCBranch, s => PCSrc, y => IsBranchPC);
	JumpMux:            Mux2 generic map(32) port map(d0 => IsBranchPC, d1 => PCJump, s => jump, y => IsJumpPC);
	JRMux:              Mux2 generic map(32) port map(d0 => IsJumpPC, d1 => SrcA, s => jumpReg, y => PCNext);
	
	-- Register File Logic.
	RegMux: Mux2 generic map(5)     port map(d0 => instr(20 DOWNTO 16), d1 => instr(15 DOWNTO 11), s => RegDist, y => WriteReg);
	JALAddMux: Mux2 generic map(5)  port map(d0 => WriteReg, d1 => ReturnReg, s => jumpLink, y => WriteRegFinal);
	ResultMUX: Mux2 generic map(32) port map(d0 => ALUOut, d1 => ReadData, s => MemToReg, y => Result); 
	JALMux:    Mux2 generic map(32) port map(d0 => Result, d1 => PCplus4, s => jumpLink, y => ResultToRegFile);
	LUIMux:    Mux2 generic map(32) port map(d0 => ResultToRegFile, d1 => SignImm, s => LUIEnable, y => LUIorResult);
	RF: RegFile port map(clk => clk, WE3 => RegWrite, A1 => instr(25 DOWNTO 21), 
	                     A2 => instr(20 DOWNTO 16), WA3 => WriteRegFinal, 
	                     WD3 => LUIorResult, RD1 => SrcA, RD2 => WriteData
                     );
	-- ALU logic.
	SrcBMux: Mux2 generic map(32) port map(d0 => WriteData, d1 => SignImm, s => ALUSrc, y => SrcB);
	MainALU: ALU port map(a => SrcA, b => SrcB, ALUControl => ALUControl, result => ALUOut, ZeroFlag => ZeroFlag);
end Structural;