`timescale 1ns / 1ps

module ControlUnit(
    input logic[6:0] opD,
    input logic[2:0] funct3D,
    input logic funct7b5D,
    input logic[11:0] funct12D,
    input logic reset, clk,
    input logic FlushE,
    output logic[2:0] ImmSrcD,
    output logic[1:0] ALUSrcAE,
    output logic ALUSrcBE,
    output logic[3:0] ALUControlE,
    output logic branchE, jumpE, wfiE,
    ResultSrcE0,
    RegWriteM, MemWriteM, RegWriteW,
    output logic[1:0] ResultSrcW
);

    logic RegWriteD, ALUSrcBD, MemWriteD;
    logic[1:0] ALUSrcAD;
    logic[1:0] ResultSrcD;
    logic[1:0] ALUOpD;
    logic[3:0] ALUControlD;
    logic RegWriteE;
    logic[1:0] ResultSrcE;
    logic MemWriteE;
    logic[1:0] ResultSrcM;
    logic branchD;
    logic jumpD;
    logic wfiD;
    
    MainDecoder MD(
        .op(opD),
        .RegWrite(RegWriteD), 
        .ImmSrc(ImmSrcD),
        .ALUSrcA(ALUSrcAD),
        .ALUSrcB(ALUSrcBD),
        .MemWrite(MemWriteD),
        .ResultSrc(ResultSrcD),
        .branch(branchD), 
        .jump(jumpD),
        .ALUOp(ALUOpD)
    );
    
    ALUDecoder ALUD(
        .funct3(funct3D), .funct7b5(funct7b5D), .ALUOp(ALUOpD), .ALUControl(ALUControlD)
    );
    
    // WFI: SYSTEM with funct3 0 and funct12 0x105 (a NOP to the main decoder).
    assign wfiD = (opD == 7'b1110011) && (funct3D == 3'b000) && (funct12D == 12'h105);

    // Decode to Execute Stage propagation registers.
    FlipFlop FFDE1(.reset(reset), .clear(FlushE), .clk(clk), .d(RegWriteD),  .q(RegWriteE), .en(1'b1));
    FlipFlop FFDE2(.reset(reset), .clear(FlushE), .clk(clk), .d(MemWriteD),  .q(MemWriteE), .en(1'b1));
    FlipFlop FFDE3(.reset(reset), .clear(FlushE), .clk(clk), .d(ALUSrcBD),   .q(ALUSrcBE),  .en(1'b1));
    FlipFlop FFDE4(.reset(reset), .clear(FlushE), .clk(clk), .d(jumpD),      .q(jumpE),     .en(1'b1));
    FlipFlop FFDE5(.reset(reset), .clear(FlushE), .clk(clk), .d(branchD),    .q(branchE),   .en(1'b1));
    FlipFlop FFDE6(.reset(reset), .clear(FlushE), .clk(clk), .d(wfiD),       .q(wfiE),      .en(1'b1));
    RegRCEn #(4) RegDE1(.reset(reset), .clk(clk), .clear(FlushE), .d(ALUControlD), .q(ALUControlE), .en(1'b1));
    RegRCEn #(2) RegDE2(.reset(reset), .clk(clk), .clear(FlushE), .d(ALUSrcAD),    .q(ALUSrcAE),    .en(1'b1));
    RegRCEn #(2) RegDE3(.reset(reset), .clk(clk), .clear(FlushE), .d(ResultSrcD),  .q(ResultSrcE),  .en(1'b1));

    assign ResultSrcE0 = ResultSrcE[0];
    
    // Execute to Memory Stage propagation registers.
    FlipFlop FFEM1(.reset(reset), .clear(1'b0), .clk(clk), .d(RegWriteE), .q(RegWriteM), .en(1'b1));
    FlipFlop FFEM2(.reset(reset), .clear(1'b0), .clk(clk), .d(MemWriteE), .q(MemWriteM), .en(1'b1));
    RegRCEn #(2) RegEM1(.reset(reset), .clk(clk), .clear(1'b0), .d(ResultSrcE), .q(ResultSrcM), .en(1'b1));
    
    // Memory to Writeback Stage propagation registers.
    FlipFlop FFMW1(.reset(reset), .clear(1'b0), .clk(clk), .d(RegWriteM), .q(RegWriteW), .en(1'b1));
    RegRCEn #(2) RegMW1(.reset(reset), .clk(clk), .clear(1'b0), .d(ResultSrcM), .q(ResultSrcW), .en(1'b1));
endmodule
