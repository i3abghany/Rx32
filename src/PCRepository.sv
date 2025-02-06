`timescale 1ns / 1ps

module PCRepository (input logic clk, reset,
                    input logic en, clear,
                    input logic[2:0] sel_read,
                    input logic[2:0] sel_write,
                    input logic[31:0] d_g,
                    output logic[31:0] q_g         
                );
    
    logic [31:0] PC_q [4:0];

    PCReg #(.WIDTH(32), .RESET_VAL(0)) PC0(.clk(clk), .reset(reset), .en(en && (sel_write == 0)), .clear(clear), .d(d_g), .q(PC_q[0]));
    PCReg #(.WIDTH(32), .RESET_VAL(400)) PC1(.clk(clk), .reset(reset), .en(en && (sel_write == 1)), .clear(clear), .d(d_g), .q(PC_q[1]));
    PCReg #(.WIDTH(32), .RESET_VAL(800)) PC2(.clk(clk), .reset(reset), .en(en && (sel_write == 2)), .clear(clear), .d(d_g), .q(PC_q[2]));
    PCReg #(.WIDTH(32), .RESET_VAL(1200)) PC3(.clk(clk), .reset(reset), .en(en && (sel_write == 3)), .clear(clear), .d(d_g), .q(PC_q[3]));
    PCReg #(.WIDTH(32), .RESET_VAL(1600)) PC4(.clk(clk), .reset(reset), .en(en && (sel_write == 4)), .clear(clear), .d(d_g), .q(PC_q[4]));
    
    Mux5 PCSelectionMux(.d0(PC0_q), .d1(PC1_q), .d2(PC2_q), .d3(PC3_q), .d4(PC4_q), .sel(sel_read), .Y(q_g));
endmodule
