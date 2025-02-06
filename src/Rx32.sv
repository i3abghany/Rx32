`timescale 1ns / 1ps
module Rx32(
        input logic clk,   reset,
        input  logic[31:0] ReadDataM,
        input  logic[31:0] instrF,
        output logic[31:0] PCF, 
        output logic       MemWriteM,
        output logic[31:0] ALUOutM,
        output logic[31:0] WriteDataM 
    );
    logic[5:0] OPD, functD;
    logic RegDistE;
    logic ALUSrcE;
    logic PCSrcD;
    
    logic MemToRegW;
    
    logic RegWriteW;
    
    logic branchM;
    logic jumpM;
    logic[3:0] ALUControlE;
    
    ControlUnit CC(
        .OPCodeD(OPD), 
        .functD(functD),
        .clk(clk),
        .reset(reset),
        .branchM(branchM),
        .MemToRegW(MemToRegW),
        .MemWriteM(MemWriteM),
        .ALUSrcE(ALUSrcE), 
        .RegDistE(RegDistE),
        .RegWriteW(RegWriteW),
        .jumpM(jumpM),
        .ALUControlE(ALUControlE)
    );
    
    Datapath DP(
        .clk(clk), 
        .reset(reset), 
        .MemToRegW(MemToRegW), 
        .RegWriteW(RegWriteW),
        .RegDistE(RegDistE),
        .jumpM(jumpM), 
        .branchM(branchM),
        .ALUSrcE(ALUSrcE),
        .ALUControlE(ALUControlE),
        .instrF(instrF), 
        .ReadDataM(ReadDataM), 
        .OPD(OPD), .functD(functD),
        .PCF(PCF), .ALUOutM(ALUOutM),
        .WriteDataM(WriteDataM)
    );
    
endmodule
