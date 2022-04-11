`timescale 1ns / 1ps

module ALU(
	input logic[31:0] A, B,
	output logic ZeroFlag,
	input logic[4:0] shamt,
	input logic[3:0] ALUControl,
	output logic[31:0] result
    );
    always_comb
	case (ALUControl)
	    4'b0010: result <= A + B;                      // ADD
	    4'b0110: result <= A - B;                      // SUB
	    4'b0000: result <= A & B;                      // AND
	    4'b0001: result <= A | B;                      // OR
	    4'b0111: result <= (A < B) ? 1 : 0;            // SLT
	    4'b0101: result <= ~(A | B);                   // NOR
	    4'b0100: result <= (B << shamt);               // SLL
	    4'b1100: result <= (B >> shamt);               // SRL
	    4'b1110: result <= (B >>> shamt);              // SRA
	    4'b1000: result <= (B >> A[4:0]);              // SRLV
	    4'b1001: result <= (B << A[4:0]);              // SLLV
	    4'b1010: result <= (B >>> A[4:0]);             // SRAV
	    default: result <= { {32{1'b0}} };
	endcase
	assign ZeroFlag = (result == 0);
endmodule
