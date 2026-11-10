`timescale 1 ns / 1 ps

// Evaluates the condition of the branch whose funct3 is given on rs1 (A) and
// rs2 (B).
module BranchUnit(
	input logic[31:0] A, B,
	input logic[2:0] funct3,
	output logic taken
    );
    always_comb
        case (funct3)
            3'b000:  taken = (A == B);                    // BEQ
            3'b001:  taken = (A != B);                    // BNE
            3'b100:  taken = ($signed(A) < $signed(B));   // BLT
            3'b101:  taken = ($signed(A) >= $signed(B));  // BGE
            3'b110:  taken = (A < B);                     // BLTU
            3'b111:  taken = (A >= B);                    // BGEU
            default: taken = 1'b0;
        endcase
endmodule
