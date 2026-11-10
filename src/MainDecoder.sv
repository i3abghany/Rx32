`timescale 1ns / 1ps
module MainDecoder(
        input logic[6:0] op,
        output logic RegWrite,
        output logic[2:0] ImmSrc,
        output logic[1:0] ALUSrcA,
        output logic ALUSrcB,
        MemWrite,             
        output logic[1:0] ResultSrc,
        output logic branch,
        jump, 
        output logic[1:0] ALUOp
    );
    // ImmSrc:    000 I, 001 S, 010 B, 011 U, 100 J.
    // ALUSrcA:   00 rs1, 01 PC, 10 zero.
    // ALUSrcB:   0 rs2, 1 immediate.
    // ResultSrc: 00 ALU, 01 data memory, 10 PC + 4.
    // ALUOp:     00 add, 10 R-type, 11 I-type.
    logic[13:0] ControlSignals;
    always_comb
        case (op)
            //                            RegWrite_ImmSrc_ALUSrcA_ALUSrcB_MemWrite_ResultSrc_branch_jump_ALUOp
            7'b0110011: ControlSignals = 14'b1_000_00_0_0_00_0_0_10; // R-type
            7'b0010011: ControlSignals = 14'b1_000_00_1_0_00_0_0_11; // I-type ALU
            7'b0000011: ControlSignals = 14'b1_000_00_1_0_01_0_0_00; // Loads
            7'b0100011: ControlSignals = 14'b0_001_00_1_1_00_0_0_00; // Stores
            7'b1100011: ControlSignals = 14'b0_010_01_1_0_00_1_0_00; // Branches
            7'b1101111: ControlSignals = 14'b1_100_01_1_0_10_0_1_00; // JAL
            7'b1100111: ControlSignals = 14'b1_000_00_1_0_10_0_1_00; // JALR
            7'b0110111: ControlSignals = 14'b1_011_10_1_0_00_0_0_00; // LUI
            7'b0010111: ControlSignals = 14'b1_011_01_1_0_00_0_0_00; // AUIPC
            // FENCE, ECALL, EBREAK, the all-zero pipeline bubbles and any
            // other opcode execute as NOPs.
            default:    ControlSignals = 14'b0_000_00_0_0_00_0_0_00;
        endcase
    assign { RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, branch, jump, ALUOp } = ControlSignals;
endmodule
