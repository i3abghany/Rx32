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
			ALUControl:   out STD_LOGIC_VECTOR(2 DOWNTO 0);
			ZeroFlag:                         in STD_LOGIC;
			MemWrite, MemToReg:              out STD_LOGIC; 
			RegWrite, RegDist:               out STD_LOGIC;
			ALUSrc, PCSrc:                   out STD_LOGIC;
			jump:                            out STD_LOGIC;
			jumpReg:			             out STD_LOGIC;
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
			ZeroFlag:                                         out STD_LOGIC;
			ALUControl: 	                in STD_LOGIC_VECTOR(2 DOWNTO 0);
			instr:                         in STD_LOGIC_VECTOR(31 DOWNTO 0);
			ReadData: 		       in STD_LOGIC_VECTOR(31 DOWNTO 0);
			PC:    			   out STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUOut, WriteData:         out STD_LOGIC_VECTOR(31 DOWNTO 0)
			);
	end component;
	
	SIGNAL ZeroFlag, MemToReg, RegWrite, RegDist, ALUSrc, PCSrc, jump, jumpReg, jumpLink, LUIEnable: STD_LOGIC;
	SIGNAL ALUControl: STD_LOGIC_VECTOR(2 DOWNTO 0);
begin
	ControlUnit: Controller port map(
            opcode => instr(31 DOWNTO 26), funct => instr(5 DOWNTO 0), ALUControl => ALUControl,
            ZeroFlag => ZeroFlag, MemWrite => MemWrite, MemToReg => MemToReg, RegWrite => RegWrite, 
            RegDist => RegDist, ALUSrc => ALUSrc, PCSrc => PCSrc, jump => jump, jumpReg => jumpReg,
            jumpLink => jumpLink, LUIEnable => LUIEnable
		);
	MainDataPath: Datapath port map(
            clk => clk, reset => reset, MemToReg => MemToReg, PCSrc => PCSrc, ALUSrc => ALUSrc, 
            RegDist => RegDist, RegWrite => RegWrite, jump => jump, jumpReg => jumpReg, jumpLink => jumpLink,
            LUIEnable => LUIEnable, ZeroFlag => ZeroFlag, ALUControl => ALUControl, instr => instr, 
            ReadData => ReadData, PC => PC, ALUOut => ALUOut, WriteData => WriteData 
	);
end SingleCycleStructural;
