`timescale 1 ns / 1 ps

// Extracts the byte or halfword addressed by offset (the low address bits)
// from the word read from data memory and extends it as the load in funct3
// requires.
module LoadExtend(
	input logic[31:0] RD,
	input logic[1:0] offset,
	input logic[2:0] funct3,
	output logic[31:0] Y
    );
    logic[7:0] ByteData;
    logic[15:0] HalfData;

    assign ByteData = RD[{offset, 3'b000} +: 8];
    assign HalfData = RD[{offset[1], 4'b0000} +: 16];

    always_comb
        case (funct3)
            3'b000:  Y = { {24{ByteData[7]}}, ByteData };   // LB
            3'b001:  Y = { {16{HalfData[15]}}, HalfData };  // LH
            3'b100:  Y = { 24'b0, ByteData };               // LBU
            3'b101:  Y = { 16'b0, HalfData };               // LHU
            default: Y = RD;                                // LW
        endcase
endmodule
