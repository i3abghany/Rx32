`timescale 1ns / 1ps

// capable of storing 256 instructions.
// Each thread will have 100 slots.
// Thread 0: 0   ->  99
// Thread 1: 100 -> 199
// Thread 2: 200 -> 299
// Thread 3: 300 -> 399
// Thread 4: 400 -> 499
 
module IMem(
        input logic[8:0] A,
        output logic[31:0] RD
    );
    logic[31:0] RAM[511:0];
    initial $readmemh("C:/Users/Mahmo/32-bit-Fine-Grained-Multithreaded-Mips-Processor/32-bit-Fine-Grained-Multithreaded-Mips-Processor.srcs/sources_1/new/InstructionMemory.mem", RAM); 
    
    assign RD = RAM[A]; 
endmodule
