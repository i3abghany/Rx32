library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MainControlDecoder is 
	port(
		opcode:  in STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct:	 in STD_LOGIC_VECTOR(5 DOWNTO 0);
		ALUOp:  out STD_LOGIC_VECTOR(1 DOWNTO 0);
		LUIEnable:                 out STD_LOGIC;
		MemWrite, MemToReg: 	   out STD_LOGIC;
		RegDist, RegWrite:  	   out STD_LOGIC;
		ALUSrc, branch, jump:      out STD_LOGIC;
		jumpReg:		   out STD_LOGIC;
		jumpLink:		   out STD_LOGIC
	);
end MainControlDecoder;

architecture Behavioural of MainControlDecoder is 
	SIGNAL ControlSignals: STD_LOGIC_VECTOR(11 DOWNTO 0);
begin
	process(all) begin
		case opcode is 
			when "000000" => -- RTYPE or JR
				if (funct = "001000") then 
					ControlSignals <= "000000010000"; -- JR
				else 
					ControlSignals <= "110000000010"; -- RTYPE
				end if;
			when "100011" => ControlSignals <= "101001000000"; -- LW
			when "101011" => ControlSignals <= "001010000000"; -- SW
			when "000100" => ControlSignals <= "000100000001"; -- BEQ
			when "000010" => ControlSignals <= "000000100000"; -- J
			when "000011" => ControlSignals <= "000000101000"; -- JAL
			when "001111" => ControlSignals <= "110000000100"; -- LUI   
			when "001000" | "001100" | "001101" => ControlSignals <= "101000000000"; -- Itype
			when others =>   ControlSignals <= "------------"; -- illegal op
		end case;
	end process;
	(RegWrite, RegDist, ALUSrc, branch, MemWrite, MemToReg, jump, jumpReg, jumpLink, LUIEnable, ALUOp(1 DOWNTO 0)) <= ControlSignals;
end Behavioural;

-- ALU decoder.
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ALUControlDecoder is 
	port(
		opcode:        in STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct: 		   in STD_LOGIC_VECTOR(5 DOWNTO 0);
		ALUOp: 		   in STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUControl:    out STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
end ALUControlDecoder;

architecture Behavioral of ALUControlDecoder is 
begin
	process (all) begin
		case ALUOp is
			when "00" =>
				case opcode is 
					when "001000" => ALUControl <= "010"; -- addi
					when "001100" => ALUControl <= "000"; -- andi
					when "001101" => ALUControl <= "001"; -- ori
					when "100011" => ALUControl <= "010"; -- lw.
					when "101011" => ALUControl <= "010"; -- sw.
					when others   => ALUControl <= "---"; -- illegal.
				end case;
			when "01" => ALUControl <= "110"; -- Sub, for beq.
			when others => -- RTYPE
				case funct is 
					when "100000" => ALUControl <= "010"; -- add.
					when "100010" => ALUControl <= "110"; -- sub.
					when "100100" => ALUControl <= "000"; -- and.
					when "100101" => ALUControl <= "001"; -- or.
					when "101010" => ALUControl <= "111"; -- stl.
					when "100111" => ALUControl <= "101";-- nor.
					when others   => ALUControl <= "---"; -- illegal.
				end case;
		end case;
	end process;
end Behavioral;
