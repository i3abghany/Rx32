`timescale 1 ns / 1 ps 

module SL2 (
	input logic[31:0] A,
	output logic[31:0] Y
    );
    
    assign Y = {A[29:0], 2'b00};
endmodule
