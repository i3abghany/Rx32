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
	SIGNAL ControlSignals: STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000000000";
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
			when "001111" => ControlSignals <= "100000000100"; -- LUI   
			when "001000" | "001100" | "001101" | "001010" => ControlSignals <= "101000000000"; -- Itype
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
		ALUControl:    out STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
end ALUControlDecoder;

architecture Behavioral of ALUControlDecoder is 
begin
	process (all) begin
		case ALUOp is
			when "00" =>
				case opcode is 
					when "001000" => ALUControl <= "0010"; -- addi
					when "001100" => ALUControl <= "0000"; -- andi
                    when "001010" => ALUControl <= "0111"; -- slti.
					when "001101" => ALUControl <= "0001"; -- ori
					when "100011" => ALUControl <= "0010"; -- lw.
					when "101011" => ALUControl <= "0010"; -- sw.
					when "001111" => ALUControl <= "0010"; -- LUI.
					when "000011" => ALUControl <= "0010"; -- JAL.
					when others   => ALUControl <= "----"; -- illegal.
				end case;
			when "01" => ALUControl <= "0110"; -- Sub, for beq.
			when others => -- RTYPE
				case funct is 
					when "100000" => ALUControl <= "0010"; -- add.
					when "100010" => ALUControl <= "0110"; -- sub.
					when "100100" => ALUControl <= "0000"; -- and.
					when "100101" => ALUControl <= "0001"; -- or.
					when "101010" => ALUControl <= "0111"; -- slt.
					when "100111" => ALUControl <= "0101"; -- NOR.
					when "000000" => ALUControl <= "0100"; -- SLL
					when others   => ALUControl <= "----"; -- illegal.
				end case;
		end case;
	end process;
end Behavioral;
