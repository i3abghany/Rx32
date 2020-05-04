library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MainControlDecoder is 
	port(
		opcode:  in STD_LOGIC_VECTOR(5 DOWNTO 0);
		ALUOp:  out STD_LOGIC_VECTOR(1 DOWNTO 0);
		MemWrite, MemToReg: 	   out STD_LOGIC;
		RegDist, RegWrite:  	   out STD_LOGIC;
		ALUSrc, branch, jump   	   out STD_LOGIC
	);
end MainControlDecoder;

architecture Behavioural of MainControlDecoder is 
	SIGNAL ControlSignals: STD_LOGIC_VECTOR(8 DOWNTO 0);
begin
	process(all) begin
		case opcode is 
			when "000000" => ControlSignals <= "110000010"; –– RTYPE
			when "100011" => ControlSignals <= "101001000"; –– LW
			when "101011" => ControlSignals <= "001010000"; –– SW
			when "000100" => ControlSignals <= "000100001"; –– BEQ
			when "001000" => ControlSignals <= "101000000"; –– ADDI
			when "000010" => ControlSignals <= "000000100"; –– J
			when others =>   ControlSignals <= "–––––––––"; –– illegal op
		end case;	
	end process;
	(RegWrite, RegDist, ALUSrc, branch, MemWrite, MemToReg, jump, ALUOp(1 DOWNTO 0)) <= ControlSignals;
end Behavioural;

-- ALU decoder.

entity ALUControlDecoder is 
	port(
		funct: 		 in STD_LOGIC_VECTOR(31 DOWNTO 26);
		ALUOp: 		   in STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUControl:   out STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
end ALUControlDecoder;

architecture Behavioral of ALUControlDecoder is 
begin
	process (all) begin
		case ALUOp is
			when "00" => ALUControl <= "010"; -- Add, for load, store, andi
			when "01" => ALUControl <= "110"; -- Sub, for beq.
			when others => -- RTYPE
				case funct is 
					when "100000" => ALUControl <= "010" -- add.
					when "100001" => ALUControl <= "110" -- sub.
					when "100100" => ALUControl <= "000" -- and.
					when "100101" => ALUControl <= "001" -- or.
					when "101010" => ALUControl <= "111" -- stl.
					when others   => ALUControl <= "---" -- illegal.
				end case;
		end case;
	end process;
end Behavioral;
