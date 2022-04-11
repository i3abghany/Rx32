`timescale 1ns / 1ps
module Mux3 #(parameter WIDTH = 32)(
        input logic[WIDTH - 1:0] d0, d1, d2,
        input logic[1:0] sel,
        output logic[WIDTH - 1:0] Y
    );
    
    always_comb 
        case(sel)
            2'b00: Y <= d0;
            2'b01: Y <= d1;
            2'b10: Y <= d2;
            default: Y <= {{WIDTH{1'bx}}};
        endcase
endmodule
