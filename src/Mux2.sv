`timescale 1ns / 1ps

module Mux2 #(parameter WIDTH = 32)
	(input logic[WIDTH - 1:0] d0, d1,
	 input logic s,
	 output logic[WIDTH - 1:0] Y
	);
    assign Y = s ? d1 : d0;
endmodule
