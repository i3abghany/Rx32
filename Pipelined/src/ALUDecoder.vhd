library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUDecoder is
    port(
        funct:      in STD_LOGIC_VECTOR (5 DOWNTO 0);
        op:         in STD_LOGIC_VECTOR (5 DOWNTO 0);
        ALUOp:      in STD_LOGIC_VECTOR (1 DOWNTO 0);
        ALUControl: out STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
end ALUDecoder;

architecture Behavioral of ALUDecoder is
begin
    process(all) begin
        case ALUOp is
            when "00" =>
                case op is
                    when "001000" => ALUControl <= "0010"; -- Addi
                    when "001100" => ALUControl <= "0000"; -- Andi
                    when "100011" => ALUControl <= "0010"; -- LW.
                    when "101011" => ALUControl <= "0010"; -- SW.
                    when others => ALUControl <= "----";
                end case;
            when "01" => ALUControl <= "0110"; -- Sub.
            when others =>
                case funct is
                    when "100000" => ALUControl <= "0010"; -- Add.
                    when "100010" => ALUControl <= "0110"; -- Sub.
                    when "100100" => ALUControl <= "0000"; -- And.
                    when "100101" => ALUControl <= "0001"; -- Or.
                    when "101010" => ALUControl <= "0111"; -- SLT.
                    when "100111" => ALUControl <= "0101"; -- NOR.
                    when "000000" => ALUControl <= "0100"; -- SLL.
                    when "000010" => ALUControl <= "1100"; -- SRL.
                    when "000100" => ALUControl <= "1000"; -- SLLV.
                    when "000110" => ALUControl <= "1001"; -- SRLV.
                    when "000111" => ALUControl <= "1010"; -- SRAV.
                    when others   => ALUControl <= "----"; -- illegal.
                end case;
        end case;
    end process;
end Behavioral;
