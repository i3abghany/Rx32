`timescale 1ns / 1ps

// Synchronous clear, like RegRCEn.
module FlipFlop(
        input logic reset, clear, clk,
        input logic d,
        input logic en,
        output logic q
    );
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) q <= 0;
        else if (clear) q <= 0;
        else begin
            if (en) begin
                q <= d;
            end
        end
    end
endmodule
