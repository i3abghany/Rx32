library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux2 is
    generic(WIDTH: integer := 32);
    port(
        d0, d1: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        s:      in std_logic;
        y:      out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
end Mux2;

architecture Behavioral of Mux2 is
begin
    y <= d1 when s = '0' else d0;
end Behavioral;
