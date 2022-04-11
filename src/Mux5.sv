`timescale 1ns / 1ps

module Mux5 #(parameter WIDTH = 32)(
        input logic[WIDTH - 1:0] d0, 
        input logic[WIDTH - 1:0] d1, 
        input logic[WIDTH - 1:0] d2, 
        input logic[WIDTH - 1:0] d3, 
        input logic[WIDTH - 1:0] d4,
        input logic[2:0] sel,
        output logic[WIDTH - 1:0] Y 
    );
    
    always_comb
       case (sel)
       3'b000: Y <= d0;
       3'b001: Y <= d1;
       3'b010: Y <= d2;
       3'b011: Y <= d3;
       3'b100: Y <= d4;
       default: Y <= { {WIDTH{1'bx}} };
    endcase

endmodule
