library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ALUController is
    Port(
        funct:      in STD_LOGIC_VECTOR(5 DOWNTO 0);
        OPCode:     in STD_LOGIC_VECTOR(5 DOWNTO 0);
        ALUOp:      in STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALUControl: out STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
end ALUController;

architecture Behavioral of ALUController is
begin
    process (all) begin
        case ALUOp is
            when "00" =>
                case OPCode is 
                    when "001101" => ALUControl <= "0001"; -- ORI
                    when others => ALUControl <= "0010";
                end case; 
            when "01" => ALUControl <= "0110"; -- BEQ.
            when "11" => ALUControl <= "0111"; -- SLTI.
            when "10" =>  -- RType.
                case funct is 
                    when "100000" => ALUControl <= "0010"; -- ADD.
                    when "100010" => ALUControl <= "0110"; -- SUB.
                    when "100100" => ALUControl <= "0000"; -- AND.
                    when "100101" => ALUControl <= "0001"; -- OR.
                    when "101010" => ALUControl <= "0111"; -- SLT.
                    when "100111" => ALUControl <= "0101"; -- NOR.
                    when "000000" => ALUControl <= "0011"; -- SLL.
                    when "000010" => ALUControl <= "0100"; -- SRL.
                    when "000110" => ALUControl <= "1000"; -- SRLV.
                    when "001000" => ALUControl <= "0010"; -- JR.
                    when others   => ALUControl <= "----"; -- invalid / unknown.
                end case;
            when others => ALUControl <= "----";
        end case;
    end process;
end Behavioral;
