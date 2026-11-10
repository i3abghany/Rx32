`timescale 1ns / 1ps

module ALU_tb();
    logic[31:0] A, B, result;
    logic[3:0] ALUControl;
    
    ALU DUT(
        .A(A), .B(B), .result(result),
        .ALUControl(ALUControl)    
    );
    
     logic[31:0] A_t, B_t; 
    
    initial begin
        A_t = 13;
        B_t = 15;
        
        apply_op(4'b0000, A_t, B_t, 28);                  // ADD.
        apply_op(4'b1000, A_t, B_t, 13 - 15);             // SUB.
        apply_op(4'b0111, A_t, B_t, 13 & 15);             // AND.
        apply_op(4'b0110, A_t, B_t, 13 | 15);             // OR.
        apply_op(4'b0100, A_t, B_t, 13 ^ 15);             // XOR.
        apply_op(4'b0010, A_t, B_t, 1);                   // SLT.
        apply_op(4'b0011, A_t, B_t, 1);                   // SLTU.
        apply_op(4'b0001, A_t, B_t, 13 << 15);            // SLL.
        apply_op(4'b0101, B_t, 2, 15 >> 2);               // SRL.
        apply_op(4'b1101, B_t, 2, 15 >> 2);               // SRA.
        
        // SLT and SRA treat A as signed, SLTU and SRL do not.
        A_t = -16;
        B_t = 2;

        apply_op(4'b0010, A_t, B_t, 1);                   // SLT.
        apply_op(4'b0011, A_t, B_t, 0);                   // SLTU.
        apply_op(4'b1101, A_t, B_t, -4);                  // SRA.
        apply_op(4'b0101, A_t, B_t, 32'h3ffffffc);        // SRL.
        
        // Shifts only use B[4:0].
        apply_op(4'b0001, A_t, 32'h00000021, -32);        // SLL.
        $finish;
    end    
    
    task apply_op(input  logic[3:0]  ALUControl_t, 
                  input  logic[31:0] A_t, B_t,
                  input logic[31:0] result_t);
        A = A_t;
        B = B_t;
        ALUControl = ALUControl_t;
        #1;
        assert(result_t == result)
        else $error("Error in ALUControl = %b, result_t = %d, result = %d", ALUControl_t, result_t, result);
    endtask

endmodule
