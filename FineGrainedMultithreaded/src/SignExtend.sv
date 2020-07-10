`timescale 1 ns / 1 ps

module SignExtend(
	input logic[15:0] A,
	output logic[31:0] Y
    );
    assign Y = { {16{ A[15] } }, A };
endmodule 
