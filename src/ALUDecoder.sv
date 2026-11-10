`timescale 1 ns / 1 ps

module ALUDecoder(
            input logic[2:0] funct3,
            input logic funct7b5,
            input logic[1:0] ALUOp,
            output logic[3:0] ALUControl
        );
    always_comb begin
        case (ALUOp) 
            2'b10: // R-type: the ALU is encoded by {funct7[5], funct3}.
                ALUControl = {funct7b5, funct3};
            2'b11: // I-type: instr[30] is an immediate bit, except for SRAI.
                ALUControl = {funct7b5 && funct3 == 3'b101, funct3};
            default: // Add: addresses, branch and jump targets, LUI and AUIPC.
                ALUControl = 4'b0000;
        endcase
    end
endmodule
