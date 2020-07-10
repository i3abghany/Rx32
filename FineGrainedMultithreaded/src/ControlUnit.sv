`timescale 1ns / 1ps

module ControlUnit(
    input logic[5:0] OPCodeD, functD,
    input logic reset, clk,
    output logic branchM,
    MemToRegW, MemWriteM, 
    ALUSrcE, RegDistE,
    RegWriteW, jumpM,
    output logic[3:0] ALUControlE
);

    logic RegWriteD, RegDistD, ALUSrcD, MemWriteD, MemToRegD;
    logic[1:0] ALUOpD;
    logic[3:0] ALUControlD;
    logic RegWriteE;
    logic MemToRegE;
    logic MemWriteE;
    logic RegWriteM;
    logic MemToRegM;
    logic branchD;
    logic branchE;
    logic jumpD;
    logic jumpE;
    
    MainDecoder MD(
        .OPCode(OPCodeD), 
        .RegWrite(RegWriteD), 
        .RegDist(RegDistD), 
        .ALUSrc(ALUSrcD), 
        .branch(branchD), 
        .MemWrite(MemWriteD), 
        .MemToReg(MemToRegD),
        .jump(jumpD),
        .ALUOp(ALUOpD)
    );
    
    ALUDecoder ALUD(
        .OPCode(OPCodeD), .funct(functD), .ALUOp(ALUOpD), .ALUControl(ALUControlD)
    );
    
    // Decode to Execute Stage propagation registers.
    FlipFlop FFDE1(.reset(reset), .clk(clk), .d(RegWriteD),  .q(RegWriteE), .en(1'b1));
    FlipFlop FFDE2(.reset(reset), .clk(clk), .d(MemToRegD),  .q(MemToRegE), .en(1'b1));
    FlipFlop FFDE3(.reset(reset), .clk(clk), .d(MemWriteD),  .q(MemWriteE), .en(1'b1));
    FlipFlop FFDE4(.reset(reset), .clk(clk), .d(ALUSrcD),    .q(ALUSrcE),   .en(1'b1));
    FlipFlop FFDE5(.reset(reset), .clk(clk), .d(RegDistD),   .q(RegDistE),  .en(1'b1));
    FlipFlop FFDE6(.reset(reset), .clk(clk), .d(jumpD),      .q(jumpE),     .en(1'b1));
    FlipFlop FFDE7(.reset(reset), .clk(clk), .d(branchD),    .q(branchE),   .en(1'b1));
    RegRCEn #(4) RegDE1(.reset(reset), .clk(clk), .clear(1'b0), .d(ALUControlD), .q(ALUControlE), .en(1'b1));
    
    // Execute to Memory Stage propagation registers.
    FlipFlop FFEM1(.reset(reset), .clk(clk), .d(RegWriteE), .q(RegWriteM), .en(1'b1));
    FlipFlop FFEM2(.reset(reset), .clk(clk), .d(MemToRegE), .q(MemToRegM), .en(1'b1));
    FlipFlop FFEM3(.reset(reset), .clk(clk), .d(MemWriteE), .q(MemWriteM), .en(1'b1));
    FlipFlop FFEM4(.reset(reset), .clk(clk), .d(branchE),   .q(branchM),   .en(1'b1));
    FlipFlop FFEM5(.reset(reset), .clk(clk), .d(jumpE),     .q(jumpM),     .en(1'b1));
    
    // Memory to Writeback Stage propagation registers.
    FlipFlop FFMW1(.reset(reset), .clk(clk), .d(RegWriteM), .q(RegWriteW), .en(1'b1));
    FlipFlop FFMW2(.reset(reset), .clk(clk), .d(MemToRegM), .q(MemToRegW), .en(1'b1));
endmodule
