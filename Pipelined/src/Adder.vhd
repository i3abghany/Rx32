library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD_UNSIGNED.all;

entity Adder is
    generic(WIDTH: integer := 32);
    port(
        A, B: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        Y: out std_logic_vector(width - 1 downto 0)
    );
end Adder;

architecture Behavioral of Adder is
begin
    Y <= A + B;
end Behavioral;
