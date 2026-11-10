`timescale 1ns / 1ps

module DMem (
        input reset,
        input logic clk, WE,
        input logic[3:0]   BE,
        input logic[31:0]   A,
        input logic[31:0]  WD, 
        output logic[31:0] RD
    );
    logic[31:0] RAM[255:0];
    assign RD = RAM[A[9:2]];
    
    // Writes the bytes enabled by BE.
    always_ff @ (posedge clk, posedge reset) begin
        if (reset) RAM <= '{default: {32{1'b0}}};
        else if (WE) begin
            if (BE[0]) RAM[A[9:2]][7:0]   <= WD[7:0];
            if (BE[1]) RAM[A[9:2]][15:8]  <= WD[15:8];
            if (BE[2]) RAM[A[9:2]][23:16] <= WD[23:16];
            if (BE[3]) RAM[A[9:2]][31:24] <= WD[31:24];
        end
    end
endmodule
