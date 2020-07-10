`timescale 1ns/1ps

module RegFile (
	input logic clk,
	input logic WE3,
	input logic[4:0] RA1, RA2, WA3,
	input logic[31:0] WD3,
	output logic[31:0] RD1, RD2
    );
    logic [31:0] RF[31:0] = '{
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0, 
        32'b0
    };   // 32 entries, each of which is 32 bits.

    always_ff @(posedge clk)
	   if(WE3) RF[WA3] <= WD3;

    assign RD1 = (RA1 == 0) ? 0 : RF[RA1];
    assign RD2 = (RA2 == 0) ? 0 : RF[RA2];
endmodule 
