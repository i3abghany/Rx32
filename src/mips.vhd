library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Mips is
	port(
		clk, reset: in STD_LOGIC;
		PC: 	   out STD_LOGIC_VECTOR(31 DOWNTO 0);
		instr:      in STD_LOGIC_VECTOR(31 DOWNTO 0);
		MemWrite:  out STD_LOGIC;
		ALUOut:    out STD_LOGIC_VECTOR(31 DOWNTO 0);
		WriteData: out STD_LOGIC_VECTOR(31 DOWNTO 0);
		ReadData:   in STD_LOGIC_VECTOR(31 DOWNTO 0)
 	);
end Mips;

architecture SingleCycleStructural of Mips is 
	component Controller is 
		port(
			opcode, funct: in STD_LOGIC_VECTOR(5 DOWNTO 0);
			ALUControl:   out STD_LOGIC_VECTOR(3 DOWNTO 0);
			ZeroFlag:                         in STD_LOGIC;
			MemWrite, MemToReg:              out STD_LOGIC; 
			RegWrite, RegDist:               out STD_LOGIC;
			ALUSrc, PCSrc:                   out STD_LOGIC;
			jump:                            out STD_LOGIC;
			jumpReg:			             out STD_LOGIC;
			LH:                              out STD_LOGIC;
			jumpLink:			             out STD_LOGIC;
			LUIEnable:                       out STD_LOGIC
		);
	end component;
	
	component Datapath is 
		port(
			clk, reset:                        	               in STD_LOGIC;
			MemToReg, PCSrc:                   	               in STD_LOGIC;
			ALUSrc, RegDist:                   	               in STD_LOGIC;
			RegWrite, jump:                    	               in STD_LOGIC;
			jumpReg:		 			                       in STD_LOGIC;
			jumpLink:                  	                       in STD_LOGIC;
			LUIEnable:                                         in STD_LOGIC;
			LH:                                                in STD_LOGIC;
			ZeroFlag:                                         out STD_LOGIC;
			ALUControl: 	                in STD_LOGIC_VECTOR(3 DOWNTO 0);
			instr:                         in STD_LOGIC_VECTOR(31 DOWNTO 0);
			ReadData: 		       in STD_LOGIC_VECTOR(31 DOWNTO 0);
			PC:    			   out STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUOut, WriteData:         out STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
	SIGNAL ZeroFlag:  STD_LOGIC := '0';
	SIGNAL MemToReg:  STD_LOGIC := '0';
	SIGNAL RegWrite:  STD_LOGIC := '0';
	SIGNAL RegDist:   STD_LOGIC := '0';
	SIGNAL ALUSrc:    STD_LOGIC := '0';
	SIGNAL PCSrc:     STD_LOGIC := '0';
	SIGNAL jump:      STD_LOGIC := '0';
	SIGNAL jumpReg:   STD_LOGIC := '0';
	SIGNAL jumpLink:  STD_LOGIC := '0';
	SIGNAL LUIEnable: STD_LOGIC := '0';
	SIGNAL LH:        STD_LOGIC := '0';
	
	SIGNAL ALUControl: STD_LOGIC_VECTOR(3 DOWNTO 0);
begin
	ControlUnit: Controller port map(
            opcode => instr(31 DOWNTO 26), funct => instr(5 DOWNTO 0), ALUControl => ALUControl,
            ZeroFlag => ZeroFlag, MemWrite => MemWrite, MemToReg => MemToReg, RegWrite => RegWrite, 
            RegDist => RegDist, ALUSrc => ALUSrc, PCSrc => PCSrc, jump => jump, jumpReg => jumpReg,
            jumpLink => jumpLink, LUIEnable => LUIEnable, LH => LH
		);
	MainDataPath: Datapath port map(
            clk => clk, reset => reset, MemToReg => MemToReg, PCSrc => PCSrc, ALUSrc => ALUSrc, 
            RegDist => RegDist, RegWrite => RegWrite, jump => jump, jumpReg => jumpReg, jumpLink => jumpLink,
            LUIEnable => LUIEnable, ZeroFlag => ZeroFlag, ALUControl => ALUControl, instr => instr, 
            ReadData => ReadData, PC => PC, ALUOut => ALUOut, WriteData => WriteData, LH => LH
	);
end SingleCycleStructural;
