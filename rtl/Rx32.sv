`timescale 1ns / 1ps

// irq[i] wakes thread i up from WFI (there are no traps).
module Rx32 #(parameter NUM_THREADS = 5,
              localparam SEL_WIDTH = NUM_THREADS > 1 ? $clog2(NUM_THREADS) : 1)(
        input logic clk,   reset,
        input  logic[NUM_THREADS - 1:0] irq,
        input  logic[31:0] ReadDataM,
        input  logic[31:0] instrF,
        output logic[31:0] PCF, 
        output logic       MemWriteM,
        output logic[3:0]  ByteEnableM,
        output logic[31:0] ALUOutM,
        output logic[31:0] WriteDataM 
    );
    logic[6:0] opD;
    logic[2:0] funct3D;
    logic funct7b5D;
    logic[11:0] funct12D;
    logic[2:0] ImmSrcD;
    logic[1:0] ALUSrcAE;
    logic ALUSrcBE;
    
    logic[1:0] ResultSrcW;
    logic ResultSrcE0;
    
    logic RegWriteM, RegWriteW;
    
    logic branchE;
    logic jumpE;
    logic wfiE;
    logic[3:0] ALUControlE;

    logic ValidF, RedirectE;
    logic[SEL_WIDTH - 1:0] selF, selD, selE, selM, selW;
    logic[4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
    logic StallF, StallD, FlushD, FlushE;
    logic[1:0] ForwardAE, ForwardBE;
    
    ControlUnit CC(
        .opD(opD),
        .funct3D(funct3D),
        .funct7b5D(funct7b5D),
        .funct12D(funct12D),
        .clk(clk),
        .reset(reset),
        .FlushE(FlushE),
        .ImmSrcD(ImmSrcD),
        .ALUSrcAE(ALUSrcAE),
        .ALUSrcBE(ALUSrcBE),
        .ALUControlE(ALUControlE),
        .branchE(branchE),
        .jumpE(jumpE),
        .wfiE(wfiE),
        .ResultSrcE0(ResultSrcE0),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW)
    );
    
    Datapath #(.NUM_THREADS(NUM_THREADS)) DP(
        .clk(clk), 
        .reset(reset), 
        .RegWriteW(RegWriteW),
        .jumpE(jumpE),
        .branchE(branchE),
        .wfiE(wfiE),
        .ResultSrcW(ResultSrcW),
        .ImmSrcD(ImmSrcD),
        .ALUSrcAE(ALUSrcAE),
        .ALUSrcBE(ALUSrcBE),
        .ALUControlE(ALUControlE),
        .instrF(instrF), 
        .ReadDataM(ReadDataM), 
        .irq(irq),
        .StallF(StallF), .StallD(StallD), .FlushD(FlushD), .FlushE(FlushE),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
        .opD(opD), .funct3D(funct3D), .funct7b5D(funct7b5D), .funct12D(funct12D),
        .ValidF(ValidF), .RedirectE(RedirectE),
        .selF(selF), .selD(selD), .selE(selE), .selM(selM), .selW(selW),
        .Rs1D(Rs1D), .Rs2D(Rs2D), .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE), .RdM(RdM), .RdW(RdW),
        .PCF(PCF), .ALUOutM(ALUOutM),
        .WriteDataM(WriteDataM),
        .ByteEnableM(ByteEnableM)
    );
    
    HazardUnit #(.NUM_THREADS(NUM_THREADS)) HU(
        .ValidF(ValidF),
        .selF(selF), .selD(selD), .selE(selE), .selM(selM), .selW(selW),
        .Rs1D(Rs1D), .Rs2D(Rs2D),
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
        .RdM(RdM), .RdW(RdW),
        .ResultSrcE0(ResultSrcE0),
        .RedirectE(RedirectE),
        .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
        .StallF(StallF), .StallD(StallD),
        .FlushD(FlushD), .FlushE(FlushE)
    );

endmodule
