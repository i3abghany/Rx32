library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HazardUnit is
    port(
        RSD, RTD, RSE, RTE: in STD_LOGIC_VECTOR(4 DOWNTO 0);
        WriteRegE:          in STD_LOGIC_VECTOR(4 DOWNTO 0);
        WriteRegW:          in STD_LOGIC_VECTOR(4 downto 0);
        WriteRegM:          in STD_LOGIC_VECTOR(4 downto 0);
        RegWriteE:          in STD_LOGIC;
        RegWriteW:          in STD_LOGIC;
        RegWriteM:          in STD_LOGIC;
        MemToRegE:          in STD_LOGIC;
        MemToRegM:          in STD_LOGIC;
        branchD:            in STD_LOGIC;
        jumpD:              in STD_LOGIC;
        ForwardAD:          out STD_LOGIC;
        ForwardBD:          out STD_LOGIC;  
        ForwardAE:          out STD_LOGIC_VECTOR(1 DOWNTO 0);
        ForwardBE:          out STD_LOGIC_VECTOR(1 DOWNTO 0);
        StallF:             out STD_LOGIC;
        StallD:             out STD_LOGIC;
        FlushE:             out STD_LOGIC
    );
end HazardUnit;

architecture Behavioral of HazardUnit is
    SIGNAL LWStallD:     STD_LOGIC;
    SIGNAL BranchStallD: STD_LOGIC;
begin
    -- Decode stage forwarding signals.
    ForwardAD <= '1' when ((RSD /= "00000") AND (RSD = WriteRegM) AND (RegWriteM = '1'))
            else '0';
    ForwardBD <= '1' when ((RTD /= "00000") AND (RTD = WriteRegM) AND (RegWriteM = '1'))
            else '0';

    -- Execute stage forwarding signals.
    process(all) begin
        ForwardAE <= "00"; ForwardBE <= "00";
        if (RSE /= "00000") then
            if ((RSE = WriteRegM) and (RegWriteM = '1')) then
                ForwardAE <= "10";
            elsif ((RSE = WriteRegW) and (RegWriteW = '1')) then
                ForwardAE <= "01";
            end if;
        end if;
        
        if (RTE /= "00000") then
            if ((RTE = writeregM) and (RegWriteM = '1')) then
                ForwardBE <= "10";
            elsif ((RTE = WriteRegW) and (RegWriteW = '1')) then
                ForwardBE <= "01";
            end if;
        end if;
    end process;
                 
    -- Stall signals.
    LWStallD <= '1' when ((MemToRegE = '1') AND ((RTE = RSD) OR (RTD = RTE)))
                else '0';
                
    BranchStallD <= '1' when ((branchD = '1') AND (((RegWriteE = '1') AND ((WriteRegE = rsD) OR (writeregE = rtD))) OR ((MemToRegM = '1') AND ((WriteRegM = rsD) OR (WriteRegM = rtD)))))
                    else '0';
    StallD <= (LWStallD OR BranchStallD) after 1 ns;
    StallF <= StallD after 1 ns;
    FlushE <= StallD or jumpD after 1 ns;
end Behavioral;

