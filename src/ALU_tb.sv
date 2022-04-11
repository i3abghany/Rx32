`timescale 1ns / 1ps

module ALU_tb();
    logic[31:0] A, B, result;
    logic ZeroRes;
    logic[4:0] shamt;
    logic[3:0] ALUControl;
    
    ALU DUT(
        .A(A), .B(B), .result(result),
        .ZeroFlag(ZeroRes), .shamt(shamt), 
        .ALUControl(ALUControl)    
    );
    
     logic[3:0]  ALUControl_t; 
     logic[31:0] A_t, B_t; 
     logic[31:0] result_t;
     logic[4:0] shamt_t;
    
    initial begin
        A_t = 13;
        B_t = 15;
        shamt_t = 2;
        
        ALUControl_t = 4'b0010;
        result_t = 28;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // ADD.
        
        ALUControl_t = 4'b0110;
        result_t = 13 - 15;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // SUB.

        ALUControl_t = 4'b0000;
        result_t = 13 & 15;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // AND.
        
        ALUControl_t = 4'b0001;
        result_t = 13 | 15;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // OR.

        ALUControl_t = 4'b0111;
        result_t = 1;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // SLT.

        ALUControl_t = 4'b0101;
        result_t = ~(13 | 15);
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // NOR.
        
        ALUControl_t = 4'b0100;
        result_t = 15 << 2;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // SRL.
        
        ALUControl_t = 4'b1100;
        result_t = 15 >> 2;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // SLL.
        
        ALUControl_t = 4'b1110;
        result_t = 15 >>> 2;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // SRA.
        
        ALUControl_t = 4'b1000;
        result_t = 15 >> 13;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // SRLV.
        
        ALUControl_t = 4'b1001;
        result_t = 15 << 13;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // SLLV.
        
        ALUControl_t = 4'b1010;
        result_t = 15 >>> 13;
        apply_op(ALUControl_t, A_t, B_t, shamt_t, result_t);         // SRAV.
        
    end    
    
    task apply_op(input  logic[3:0]  ALUControl_t, 
                  input  logic[31:0] A_t, B_t,
                  input  logic[4:0] shamt_t, 
                  input logic[31:0] result_t);
        A = A_t;
        B = B_t;
        ALUControl = ALUControl_t;
        shamt = shamt_t;
        #1;
        assert(result_t == result)
        else $error("Error in ALUControl = %b, result_t = %d, result = %d", ALUControl_t, result_t, result);
    endtask

endmodule
