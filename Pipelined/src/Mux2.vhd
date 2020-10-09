library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux2 is
    generic(WIDTH: integer := 32);
    port(
        d0, d1: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        s:      in std_logic;
        y:      out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
    attribute dont_touch : string;
    attribute dont_touch of Mux2: entity is "true|yes";
end Mux2;

architecture Behavioral of Mux2 is
begin
    with s select
    y <= d1 when '1',
         d0 when others;
end Behavioral;
