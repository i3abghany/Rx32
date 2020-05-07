library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity top is 
	port(
		clk, reset: in STD_LOGIC;
	    WriteData, DataAddr: out STD_LOGIC_VECTOR(31 downto 0);
		MemWrite: buffer STD_LOGIC
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
			DataWidth: integer := 32;
			Capacity: integer := 256
		);
		port(
			clk, WE: in STD_LOGIC;
			A, WD: in STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
			RD: out STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0)
		);
	end component;
	component IMem is 
		generic (
			DataWidth: integer := 32;
			Capacity:  integer := 256
		);
		port(
			A:   in STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
			RD: out STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0)
		);
	end component;
	SIGNAL PC, instr, ReadData: STD_LOGIC_VECTOR(31 DOWNTO 0);

begin
	Processor:   Mips port map(clk => clk, reset => reset, PC => PC, 
	                           instr => instr, MemWrite => MemWrite, 
	                           ALUOut => DataAddr, WriteData => WriteData,
	                           ReadData => ReadData);
	DataMemory:  DMem generic map(32, 256) port map(clk => clk, WE => MemWrite, A => DataAddr, 
	                                                WD => WriteData, RD => ReadData);
	InstrMemory: IMem generic map(32, 32) port map(A => PC, RD => instr);
end test;
