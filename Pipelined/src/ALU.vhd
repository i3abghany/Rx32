library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity ALU is
    port(
        A, B:       in STD_LOGIC_VECTOR(31 DOWNTO 0);
        ALUControl: in STD_LOGIC_VECTOR (3 DOWNTO 0);
        shamt:      in STD_LOGIC_VECTOR (4 DOWNTO 0);
        result:     out STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
end ALU;

architecture Behavioral of ALU is
begin
    process (all) begin
        case ALUControl is 
            when "0010" =>
                result  <= a + b;
            when "0110" => 
                result  <= a - b;
            when "0000" => 
                result  <= a AND b;
            when "0001" => 
                result  <= a OR b;
            when "0111" => 
                if (a < b) then result <= X"00000001"; else result <= X"00000000"; end if;
            when "0101" => result <= a NOR b;
            when "0100" => result <= STD_LOGIC_VECTOR(SHIFT_LEFT (UNSIGNED(b), CONV_INTEGER(shamt)));          -- SLL
            when "1100" => result <= STD_LOGIC_VECTOR(SHIFT_RIGHT(UNSIGNED(b), CONV_INTEGER(shamt)));         -- SRL
            when "1000" => result <= STD_LOGIC_VECTOR(SHIFT_LEFT (UNSIGNED(b), CONV_INTEGER(a(4 DOWNTO 0))));  -- SLLV
            when "1001" => result <= STD_LOGIC_VECTOR(SHIFT_RIGHT(UNSIGNED(b), CONV_INTEGER(a(4 DOWNTO 0)))); -- SRLV
            when "1010" => result <= STD_LOGIC_VECTOR(SHIFT_RIGHT  (SIGNED(b), CONV_INTEGER(a(4 DOWNTO 0))));   -- SRAV
            when others => 
                result <= X"--------";
        end case;
    end process;
end Behavioral;
