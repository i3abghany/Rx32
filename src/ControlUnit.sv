`timescale 1ns / 1ps

module ControlUnit(
    input logic[6:0] opD,
    input logic[2:0] funct3D,
    input logic funct7b5D,
    input logic reset, clk,
    output logic[2:0] ImmSrcD,
    output logic[1:0] ALUSrcAE,
    output logic ALUSrcBE,
    output logic[3:0] ALUControlE,
    output logic branchM, jumpM,
    MemWriteM, RegWriteW,
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
    logic RegWriteM;
    logic[1:0] ResultSrcM;
    logic branchD;
    logic branchE;
    logic jumpD;
    logic jumpE;
    
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
    
    // Decode to Execute Stage propagation registers.
    FlipFlop FFDE1(.reset(reset), .clk(clk), .d(RegWriteD),  .q(RegWriteE), .en(1'b1));
    FlipFlop FFDE2(.reset(reset), .clk(clk), .d(MemWriteD),  .q(MemWriteE), .en(1'b1));
    FlipFlop FFDE3(.reset(reset), .clk(clk), .d(ALUSrcBD),   .q(ALUSrcBE),  .en(1'b1));
    FlipFlop FFDE4(.reset(reset), .clk(clk), .d(jumpD),      .q(jumpE),     .en(1'b1));
    FlipFlop FFDE5(.reset(reset), .clk(clk), .d(branchD),    .q(branchE),   .en(1'b1));
    RegRCEn #(4) RegDE1(.reset(reset), .clk(clk), .clear(1'b0), .d(ALUControlD), .q(ALUControlE), .en(1'b1));
    RegRCEn #(2) RegDE2(.reset(reset), .clk(clk), .clear(1'b0), .d(ALUSrcAD),    .q(ALUSrcAE),    .en(1'b1));
    RegRCEn #(2) RegDE3(.reset(reset), .clk(clk), .clear(1'b0), .d(ResultSrcD),  .q(ResultSrcE),  .en(1'b1));
    
    // Execute to Memory Stage propagation registers.
    FlipFlop FFEM1(.reset(reset), .clk(clk), .d(RegWriteE), .q(RegWriteM), .en(1'b1));
    FlipFlop FFEM2(.reset(reset), .clk(clk), .d(MemWriteE), .q(MemWriteM), .en(1'b1));
    FlipFlop FFEM3(.reset(reset), .clk(clk), .d(branchE),   .q(branchM),   .en(1'b1));
    FlipFlop FFEM4(.reset(reset), .clk(clk), .d(jumpE),     .q(jumpM),     .en(1'b1));
    RegRCEn #(2) RegEM1(.reset(reset), .clk(clk), .clear(1'b0), .d(ResultSrcE), .q(ResultSrcM), .en(1'b1));
    
    // Memory to Writeback Stage propagation registers.
    FlipFlop FFMW1(.reset(reset), .clk(clk), .d(RegWriteM), .q(RegWriteW), .en(1'b1));
    RegRCEn #(2) RegMW1(.reset(reset), .clk(clk), .clear(1'b0), .d(ResultSrcM), .q(ResultSrcW), .en(1'b1));
endmodule
