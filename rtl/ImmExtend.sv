`timescale 1 ns / 1 ps

module ImmExtend(
	input logic[31:7] instr,
	input logic[2:0] ImmSrc,
	output logic[31:0] ImmExt
    );
    always_comb
        case (ImmSrc)
            3'b000:  ImmExt = { {20{instr[31]}}, instr[31:20] };                                // I-type
            3'b001:  ImmExt = { {20{instr[31]}}, instr[31:25], instr[11:7] };                   // S-type
            3'b010:  ImmExt = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };   // B-type
            3'b011:  ImmExt = { instr[31:12], 12'b0 };                                          // U-type
            3'b100:  ImmExt = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 }; // J-type
            default: ImmExt = { {32{1'b0}} };
        endcase
endmodule
