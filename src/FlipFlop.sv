`timescale 1ns / 1ps
module FlipFlop(
        input logic reset, clk,
        input logic d,
        input logic en,
        output logic q
    );
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) q <= 0;
        else begin
            if (en) begin
                q <= d;
            end
        end
    end
endmodule
