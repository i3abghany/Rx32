library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RegEn is
    generic (WIDTH: integer);
    Port (
        clk, reset, en: in STD_LOGIC;
        d:              in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        q:              out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
end RegEn;

architecture Behavioral of RegEn is
begin
    process (clk, reset) begin
        if(reset = '1') then
            q <= (others => '0');
        elsif (rising_edge(clk) AND en = '1') then 
            q <= d;
        end if;
    end process;
end Behavioral;
