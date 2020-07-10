`timescale 1ns / 1ps
module MainDecoder(
        input logic[5:0] OPCode,
        output logic RegWrite,
        RegDist,
        ALUSrc,  
        branch,
        MemWrite,             
        MemToReg, 
        jump, 
        output logic[1:0] ALUOp
    );
    logic[8:0] ControlSignals;
    always_comb
        case (OPCode)
            6'b000000: ControlSignals <= 9'b110000010; // RType instruction.
            6'b100011: ControlSignals <= 9'b101001000; // LW
            6'b101011: ControlSignals <= 9'b001010000; // SW
            6'b000100: ControlSignals <= 9'b000100001; // BEQ
            6'b001000: ControlSignals <= 9'b101000000; // ADDI
            6'b001100: ControlSignals <= 9'b101000000; // ANDI
            6'b000010: ControlSignals <= 9'b000000100; // J
            default:   ControlSignals <= 9'bxxxxxxxxx;
        endcase
    assign { RegWrite, RegDist, ALUSrc, branch, MemWrite, MemToReg, jump, ALUOp } = ControlSignals;
endmodule
