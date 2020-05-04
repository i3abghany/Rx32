library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity top is 
	port(
		clk, reset: in std_logic;
	    WriteData, DataAddr buffer std_logic_vector(31 downto 0);
		MemWrite: buffer std_logic
	);
end top;

architecture test of top is 
	component Mips is 
		port(
			clk, reset: in STD_LOGIC;
			PC: 	   out STD_LOGIC_VECTOR(31 DOWNTO 0);
			instr:      in STD_LOGIC_VECTOR(31 DOWNTO 0);
			MemWrite:  out STD_LOGIC;
			ALUOut:    out STD_LOGIC_VECTOR(31 DOWNTO 0);
			WriteData: out STD_LOGIC_VECTOR(31 DOWNTO 0);
			ReadData:   in STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	component DMem is 
		generic (
			width: integer := 32,
			Capacity: integer := 256
		);
		port(
			clk, WE: in STD_LOGIC;
			A, WD: in STD_LOGIC_VECTOR(width - 1 DOWNTO 0);
			RD: out STD_LOGIC_VECTOR(width - 1 DOWNTO 0)
		);
	end component;
	component IMem is 
		generic (
			DataWidth: integer := 32,
			Capacity:  integer := 256
		);
		port(
			A:   in STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
			RD: out STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0)
		);
	end component;
	signal PC, instr, ReadData: STD_LOGIC_VECTOR(31 DOWNTO 0);
begin
	Processor:   Mips port map(clk, reset, PC, instr, MemWrite, DataAddr, WriteData, ReadData);
	DataMemory:  DMem generic map(32, 256) port map(clk, MemWrite, DataAddr, WriteData, ReadData);
	InstrMemory: IMem generic map(32, 256) port map(PC(9 DOWNTO 2), instr);
end test;
