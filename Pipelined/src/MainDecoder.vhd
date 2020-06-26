library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MainDecoder is
    port(
        OPCode:   in STD_LOGIC_VECTOR(5 downto 0);
        MemToReg: out STD_LOGIC;
        MemWrite: out STD_LOGIC;
        branch:   out STD_LOGIC;
        ALUSrc:   out STD_LOGIC;
        RegDist:  out STD_LOGIC;
        RegWrite: out STD_LOGIC;
        jump:     out STD_LOGIC;
        ALUOp:    out STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
end MainDecoder;

architecture Behavioral of MainDecoder is
    SIGNAL ControlSignals: STD_LOGIC_VECTOR(8 DOWNTO 0);
begin
    process (all) begin
        case OPCode is
            when "000000" => ControlSignals <= "110000010"; -- RType instruction.
            when "100011" => ControlSignals <= "101001000"; -- LW
            when "101011" => ControlSignals <= "001010000"; -- SW
            when "000100" => ControlSignals <= "000100001"; -- BEQ
            when "001000" => ControlSignals <= "101000000"; -- ADDI
            when "001100" => ControlSignals <= "101000000"; -- ANDI
            when "000010" => ControlSignals <= "000000100"; -- J
            when others   => ControlSignals <= "---------";
        end case;
    end process;
    
    RegWrite <= ControlSignals(8);
    RegDist  <= ControlSignals(7);
    ALUSrc   <= ControlSignals(6);
    branch   <= ControlSignals(5);
    MemWrite <= ControlSignals(4);
    MemToReg <= ControlSignals(3);
    jump     <= ControlSignals(2);
    ALUOp    <= ControlSignals(1 downto 0);
end Behavioral;
