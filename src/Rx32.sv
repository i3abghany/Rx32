`timescale 1ns / 1ps
module Rx32(
        input logic clk,   reset,
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
    logic[2:0] ImmSrcD;
    logic[1:0] ALUSrcAE;
    logic ALUSrcBE;
    
    logic[1:0] ResultSrcW;
    
    logic RegWriteW;
    
    logic branchM;
    logic jumpM;
    logic[3:0] ALUControlE;
    
    ControlUnit CC(
        .opD(opD),
        .funct3D(funct3D),
        .funct7b5D(funct7b5D),
        .clk(clk),
        .reset(reset),
        .ImmSrcD(ImmSrcD),
        .ALUSrcAE(ALUSrcAE),
        .ALUSrcBE(ALUSrcBE),
        .ALUControlE(ALUControlE),
        .branchM(branchM),
        .jumpM(jumpM),
        .MemWriteM(MemWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW)
    );
    
    Datapath DP(
        .clk(clk), 
        .reset(reset), 
        .RegWriteW(RegWriteW),
        .jumpM(jumpM), 
        .branchM(branchM),
        .ResultSrcW(ResultSrcW),
        .ImmSrcD(ImmSrcD),
        .ALUSrcAE(ALUSrcAE),
        .ALUSrcBE(ALUSrcBE),
        .ALUControlE(ALUControlE),
        .instrF(instrF), 
        .ReadDataM(ReadDataM), 
        .opD(opD), .funct3D(funct3D), .funct7b5D(funct7b5D),
        .PCF(PCF), .ALUOutM(ALUOutM),
        .WriteDataM(WriteDataM),
        .ByteEnableM(ByteEnableM)
    );
    
endmodule
