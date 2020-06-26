library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity ZeroExtend is
    Port(
        a: in STD_LOGIC_VECTOR(15 DOWNTO 0);
        y: out STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
end ZeroExtend;

architecture Behavioral of ZeroExtend is
begin
    y <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(a), 32));
end Behavioral;
