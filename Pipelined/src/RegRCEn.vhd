library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity RegRCEn is
    generic(WIDTH: integer := 32);
    port(
        clk, reset, clear, en: in STD_LOGIC;
        d: in STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        q: out STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
    
    attribute dont_touch : string;
    attribute dont_touch of RegRCEn: entity is "true|yes";
end RegRCEn;

architecture Behavioral of RegRCEn is
begin
    process(clk, reset, clear, en) begin
        if reset = '1' then q <= CONV_STD_LOGIC_VECTOR(0, width);
        else 
            if rising_edge(clk) then
                if clear = '1' then q <= CONV_STD_LOGIC_VECTOR(0, width);
                elsif en = '1' then q <= d;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
