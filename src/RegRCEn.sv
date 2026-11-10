`timescale 1 ns / 1 ps

// Synchronous clear, which takes priority over en.
module RegRCEn #(parameter WIDTH = 32)(
	input logic reset, clear, clk,
	input logic en,
	input logic[WIDTH - 1:0] d,
	output logic[WIDTH - 1:0] q
    );

    always_ff @ (posedge clk, posedge reset)
    begin
        if (reset)
            q <= 0;
        else if (clear)
            q <= 0;
        else begin
            if (en) q <= d;
        end 
    end
endmodule
