library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EqualityComp is
    port(
        A, B: in STD_LOGIC_VECTOR(31 DOWNTO 0);
        y: out STD_LOGIC
    );
end EqualityComp;

architecture Behavioral of EqualityComp is

begin
    y <= '1' when (A = B) else '0';
end Behavioral;
