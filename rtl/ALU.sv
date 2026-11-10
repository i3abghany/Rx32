`timescale 1ns / 1ps

// ALUControl is {funct7[5], funct3} of the R-type instruction for each
// operation. Shift amounts come from B[4:0].
module ALU(
	input logic[31:0] A, B,
	input logic[3:0] ALUControl,
	output logic[31:0] result
    );
    always_comb
	case (ALUControl)
	    4'b0000: result = A + B;                               // ADD
	    4'b1000: result = A - B;                               // SUB
	    4'b0001: result = A << B[4:0];                         // SLL
	    4'b0010: result = {31'b0, $signed(A) < $signed(B)};    // SLT
	    4'b0011: result = {31'b0, A < B};                      // SLTU
	    4'b0100: result = A ^ B;                               // XOR
	    4'b0101: result = A >> B[4:0];                         // SRL
	    4'b1101: result = $signed(A) >>> B[4:0];               // SRA
	    4'b0110: result = A | B;                               // OR
	    4'b0111: result = A & B;                               // AND
	    default: result = { {32{1'b0}} };
	endcase
endmodule
