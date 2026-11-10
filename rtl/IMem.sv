`timescale 1ns / 1ps

// Holds 2 ** ADDR_WIDTH instructions; Top sizes it.
module IMem #(parameter ADDR_WIDTH = 9)(
        input logic[ADDR_WIDTH - 1:0] A,
        output logic[31:0] RD
    );
    logic[31:0] RAM[2 ** ADDR_WIDTH - 1:0];
    initial $readmemh("InstructionMemory.mem", RAM);
    
    assign RD = RAM[A]; 
endmodule
