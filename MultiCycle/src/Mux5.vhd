library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux5 is
    generic (WIDTH: integer);
    Port(d0, d1, d2, d3, d4  : in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
         s : in STD_LOGIC_VECTOR (2 downto 0);
         y : out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
end Mux5;

architecture Behavioral of Mux5 is
begin
    process (all) begin
        case s is
            when "000" => 
                y <= d0;
            when "001" => 
                y <= d1;
            when "010" => 
                y <= d2;
             when "011" =>
                y <= d3;
             when "100" =>
                y <= d4;
             when others =>
                y <= (others => '-');
        end case;
    end process;
end Behavioral;
