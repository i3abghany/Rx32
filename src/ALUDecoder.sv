`timescale 1 ns / 1 ps

module ALUDecoder(
            input logic[5:0] OPCode, funct,
            input logic[1:0] ALUOp,
            output logic[3:0] ALUControl
        );
    always_comb begin
        case (ALUOp) 
            2'b00:
                case (OPCode)
                    6'b001000: ALUControl <= 4'b0010; // Addi
                    6'b001100: ALUControl <= 4'b0000; // Andi
                    6'b100011: ALUControl <= 4'b0010; // LW
                    6'b101011: ALUControl <= 4'b0010; // SW
                    default:   ALUControl <= 4'bxxxx;
                endcase
            2'b01:
                ALUControl <= 4'b0110; // Sub
            default:
                case (funct)
                    6'b100000: ALUControl <= 4'b0010; // Add
                    6'b100010: ALUControl <= 4'b0110; // Sub
                    6'b100100: ALUControl <= 4'b0000; // And
                    6'b100101: ALUControl <= 4'b0001; // Or
                    6'b101010: ALUControl <= 4'b0111; // SLT
                    6'b100111: ALUControl <= 4'b0101; // NOR
                    6'b000000: ALUControl <= 4'b0100; // SLLI
                    6'b000100: ALUControl <= 4'b1000; // SLL
                    6'b000110: ALUControl <= 4'b1001; // SRL
                    6'b000111: ALUControl <= 4'b1010; // SRA
                    default:   ALUControl <= 4'bxxxx;
                endcase
        endcase
    end
endmodule