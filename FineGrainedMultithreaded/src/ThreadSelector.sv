`timescale 1ns / 1ps
module ThreadSelector (
        input logic reset,
        input logic clk,
        output logic[2:0] sel
    );
    always @(posedge clk, posedge reset)
    begin
        if (reset || (sel == 4)) sel <= 0;
        else sel <= sel + 1;
    end 
    
endmodule
