`timescale 1ns / 1ps

module DMem (
        input reset,
        input logic clk, WE,
        input logic[31:0]   A,
        input logic[31:0]  WD, 
        output logic[31:0] RD
    );
    logic[31:0] RAM[255:0];
    assign RD = RAM[A[31:2]];
    
    always_ff @ (posedge clk) begin 
        if (reset) for(integer i = 0; i < 256; i++)
                        RAM[i] <= {32{1'b0}};
        if (WE) RAM[A[31:2]] <= WD;
    end
    
    always_ff @ (posedge reset) begin 
        for(integer i = 0; i < 256; i++)
            RAM[i] <= {32{1'b0}};
    end
endmodule
