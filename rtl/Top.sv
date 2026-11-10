`timescale 1ns / 1ps
module Top #(parameter NUM_THREADS = 5)(
        input logic clk, reset,
        input logic[NUM_THREADS - 1:0] irq
    );
    // 100 instructions per thread, for at least 5 (the test programs' slots).
    localparam IMEM_ADDR_WIDTH = $clog2(100 * (NUM_THREADS > 5 ? NUM_THREADS : 5));

    logic[31:0] InstructionAddr;
    logic[31:0] Instruction;
    logic[31:0] ReadData;
    logic[31:0] DataAddr;
    logic[31:0] WriteData;
    logic MemWrite;
    logic[3:0] ByteEnable;
    
    Rx32 #(.NUM_THREADS(NUM_THREADS)) Processor(
        .clk(clk), .reset(reset),
        .irq(irq),
        .PCF(InstructionAddr),
        .instrF(Instruction),
        .ReadDataM(ReadData),
        .MemWriteM(MemWrite),
        .ByteEnableM(ByteEnable),
        .ALUOutM(DataAddr),
        .WriteDataM(WriteData)
    );
    
    DMem DataMemory(
        .reset(reset),
        .clk(clk),
        .WE(MemWrite),
        .BE(ByteEnable),
        .A(DataAddr), 
        .WD(WriteData),
        .RD(ReadData)
    );
    
    IMem #(.ADDR_WIDTH(IMEM_ADDR_WIDTH)) InstructionMemory(
        .A(InstructionAddr[IMEM_ADDR_WIDTH + 1:2]),
        .RD(Instruction)
    );
    
endmodule
