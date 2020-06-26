library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity FlipFlop is
    port(
        clk, reset, clear, en: in STD_LOGIC;
        d:                     in STD_LOGIC;
        q:                    out STD_LOGIC
    );
end FlipFlop;

architecture Behavioral of FlipFlop is
begin
    process (clk, reset, clear, en) begin
        if(en = '1') then
            if (rising_edge(clk)) then
                if clear = '1' then
                    q <= '0';
                elsif reset = '1' then
                    q <= '0';
                else q <= d;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
