`timescale 1ns / 1ps

module DMem (
        input reset,
        input logic clk, WE,
        input logic[31:0]   A,
        input logic[31:0]  WD, 
        output logic[31:0] RD
    );
    logic[31:0] RAM[255:0];
    assign RD = RAM[A[9:2]];
    
    always_ff @ (posedge clk, posedge reset) begin
        if (reset) RAM <= '{default: {32{1'b0}}};
        else if (WE) RAM[A[9:2]] <= WD;
    end
endmodule
