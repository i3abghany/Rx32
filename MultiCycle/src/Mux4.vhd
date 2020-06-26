library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux4 is
    generic (WIDTH: integer);
    Port(d0, d1, d2, d3  : in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
         s : in STD_LOGIC_VECTOR (1 downto 0);
         y : out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
end Mux4;

architecture Behavioral of Mux4 is
begin
    process (all) begin
        case s is
            when "00" => 
                y <= d0;
            when "01" => 
                y <= d1;
            when "10" => 
                y <= d2;
             when "11" =>
                y <= d3;
             when others =>
                y <= (others => '-');
        end case;
    end process;
end Behavioral;
