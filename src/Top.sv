`timescale 1ns / 1ps
module Top(
        input logic clk, reset
    );
    logic[31:0] InstructionAddr;
    logic[31:0] Instruction;
    logic[31:0] ReadData;
    logic[31:0] DataAddr;
    logic[31:0] WriteData;
    logic MemWrite;
    
    Rx32 Processor(
        .clk(clk), .reset(reset),
        .PCF(InstructionAddr),
        .instrF(Instruction),
        .ReadDataM(ReadData),
        .MemWriteM(MemWrite),
        .ALUOutM(DataAddr),
        .WriteDataM(WriteData)
    );
    
    DMem DataMemory(
        .reset(reset),
        .clk(clk),
        .WE(MemWrite),
        .A(DataAddr), 
        .WD(WriteData),
        .RD(ReadData)
    );
    
    IMem InstructionMemory(
        .A(InstructionAddr[10:2]),
        .RD(Instruction)
    );
    
endmodule
