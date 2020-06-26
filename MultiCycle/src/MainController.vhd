library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MainController is
    Port (
        clk, reset: in STD_LOGIC;
        OPCode:     in STD_LOGIC_VECTOR(5 DOWNTO 0);
        funct:      in STD_LOGIC_VECTOR(5 DOWNTO 0);
        PCWrite:    out STD_LOGIC;
        MemWrite:   out STD_LOGIC;
        IRWrite:    out STD_LOGIC;
        RegWrite:   out STD_LOGIC;
        ALUSrcA:    out STD_LOGIC;
        branch:     out STD_LOGIC;
        IorD:       out STD_LOGIC;
        MemToReg:   out STD_LOGIC;
        RegDist:    out STD_LOGIC;
        ALUSrcB:    out STD_LOGIC_VECTOR(2 DOWNTO 0);
        PCSrc:      out STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALUOp:      out STD_LOGIC_VECTOR(1 DOWNTO 0) 
    );
end MainController;

architecture Behavioral of MainController is
    TYPE StateType is (FETCH, DECODE, MEMADR, MEMRD, MEMWB, MEMWR, REXEC, RWB, BEQEXEC, ADDIEXEC, IWB, JEX, ORIEXEC, JRWB);
    SIGNAL CurrentState, NextState: StateType;
    SIGNAL ControlSignals: STD_LOGIC_VECTOR(15 DOWNTO 0);
begin
    process (clk, reset) begin
        if reset = '1' then
            CurrentState <= FETCH;
        elsif rising_edge(clk) then
            CurrentState <= NextState;
        end if;
    end process;
    
    process (all) begin
        case CurrentState is
            when FETCH  => NextState <= DECODE;
            when DECODE => 
                case OPCode is
                    when "100011" | "101011" => NextState <= MEMADR;  -- lw, sw.
                    when "000000" => NextState <= REXEC;              -- R type.
                    when "000100" => NextState <= BEQEXEC;            -- BEQ.
                    when "001000" => NextState <= ADDIEXEC;           -- ADDI.
                    when "000010" => NextState <= JEX;                -- Jump.
                    when "001101" => NextState <= ORIEXEC;            -- ORI.
                    when others   => NextState <= FETCH;              -- WRONG.
                end case;
            when MEMADR => 
                case OPCode is 
                    when "100011" => NextState <= MEMRD;
                    when "101011" => NextState <= MEMWR;
                    when others   => NextState <= FETCH;
                end case;
            when MEMRD    => NextState <= MEMWB;
            when MEMWB    => NextState <= FETCH;
            when MEMWR    => NextState <= FETCH;
            when REXEC =>
                case funct is 
                    when "001000" => NextState <= JRWB;
                    when others   => NextState <= RWB;
                end case;
            when JRWB     => Nextstate <= FETCH;
            when RWB      => NextState <= FETCH;
            when BEQEXEC  => NextState <= FETCH;
            when ADDIEXEC => NextState <= IWB;
            when IWB      => NextState <= FETCH;
            when JEX      => NextState <= FETCH;
            when ORIEXEC  => NextState <= IWB;
            when others   => NextState <= FETCH;
        end case;
    end process;
    
    -- Control output logic.
    process (all) begin
        case CurrentState is
            when FETCH    => ControlSignals <= "1010000000010000";
            when DECODE   => ControlSignals <= "0000000000110000";
            when MEMADR   => ControlSignals <= "0000100000100000";
            when MEMRD    => ControlSignals <= "0000001000000000";
            when MEMWB    => ControlSignals <= "0001000100000000";
            when MEMWR    => ControlSignals <= "0100001000000000";
            when REXEC    => ControlSignals <= "0000100000000010";
            when RWB      => ControlSignals <= "0001000010000000";
            when BEQEXEC  => ControlSignals <= "0000110000000101";
            when ADDIEXEC => ControlSignals <= "0000100000100000";
            when IWB      => ControlSignals <= "0001000000000000";
            when ORIEXEC  => ControlSignals <= "0000100001000000";
            when JEX      => ControlSignals <= "1000000000001000";
            when JRWB     => ControlSignals <= "1000000000000100";
            when others   => ControlSignals <= "----------------";
        end case;
    end process;
    
    PCWrite   <= ControlSignals(15);
    MemWrite  <= ControlSignals(14);
    IRWrite   <= ControlSignals(13);
    RegWrite  <= ControlSignals(12);
    ALUSrcA   <= ControlSignals(11);
    branch    <= ControlSignals(10);
    IorD      <= ControlSignals(9);
    MemToReg  <= ControlSignals(8);
    RegDist   <= ControlSignals(7);
    ALUSrcB   <= ControlSignals(6 DOWNTO 4);
    PCSrc     <= ControlSignals(3 DOWNTO 2);
    ALUOp     <= ControlSignals(1 DOWNTO 0);
end Behavioral;
