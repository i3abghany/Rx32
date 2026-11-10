`timescale 1 ns / 1 ps 

module Adder(
	input logic[31:0] A, B,
	output logic[31:0] Y
    );
    assign Y = A + B;
endmodule
