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
end RegRCEn;

architecture Behavioral of RegRCEn is
begin
    process (clk, reset, clear, en) begin
        if(reset = '1') then
            q <= CONV_STD_LOGIC_VECTOR(0, WIDTH);
        else 
            if(en = '1') then
                if (rising_edge(clk)) then
                    if clear = '1' then
                        q <= CONV_STD_LOGIC_VECTOR(0, WIDTH);
                    elsif reset = '1' then
                        q <= CONV_STD_LOGIC_VECTOR(0, WIDTH);
                    else q <= d;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
