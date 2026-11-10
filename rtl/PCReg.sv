`timescale 1 ns / 1 ps

module PCReg #(
    parameter WIDTH = 32,
    parameter RESET_VAL = 0
)(
	input logic reset, clear, clk,
	input logic en,
	input logic[WIDTH - 1:0] d,
	output logic[WIDTH - 1:0] q
    );

    always_ff @ (posedge clk, posedge reset, posedge clear)
    begin
        if (reset || clear)
            q <= RESET_VAL;
        else begin
            if (en) q <= d;
        end 
    end
endmodule
