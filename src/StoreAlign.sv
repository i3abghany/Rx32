`timescale 1 ns / 1 ps

// Places the stored byte or halfword in every lane of the word written to data
// memory, and enables only the lanes addressed by offset (the low address bits).
module StoreAlign(
	input logic[31:0] WD,
	input logic[1:0] offset,
	input logic[2:0] funct3,
	output logic[31:0] Y,
	output logic[3:0] BE
    );
    always_comb
        case (funct3)
            3'b000: begin // SB
                Y  = {4{WD[7:0]}};
                BE = 4'b0001 << offset;
            end
            3'b001: begin // SH
                Y  = {2{WD[15:0]}};
                BE = offset[1] ? 4'b1100 : 4'b0011;
            end
            default: begin // SW
                Y  = WD;
                BE = 4'b1111;
            end
        endcase
endmodule
