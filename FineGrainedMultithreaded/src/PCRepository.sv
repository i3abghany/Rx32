`timescale 1ns / 1ps

module PCRepository (input logic clk, reset,
                    input logic en, clear,
                    input logic[2:0] sel_read,
                    input logic[2:0] sel_write,
                    input logic[31:0] d_g,
                    output logic[31:0] q_g         
                );
    
    logic[31:0] PC0_q;
    PC0Reg PC0(.clk(clk), .reset(reset), .en(en && (sel_write == 0)), .clear(clear), .d(d_g), .q(PC0_q));

    logic[31:0] PC1_q;
    PC1Reg PC1(.clk(clk), .reset(reset), .en(en && (sel_write == 1)), .clear(clear), .d(d_g), .q(PC1_q));

    logic[31:0] PC2_q;
    PC2Reg PC2(.clk(clk), .reset(reset), .en(en && (sel_write == 2)), .clear(clear), .d(d_g), .q(PC2_q));

    logic[31:0] PC3_q;
    PC3Reg PC3(.clk(clk), .reset(reset), .en(en && (sel_write == 3)), .clear(clear), .d(d_g), .q(PC3_q));


    logic[31:0] PC4_q;
    PC4Reg PC4(.clk(clk), .reset(reset), .en(en && (sel_write == 4)), .clear(clear), .d(d_g), .q(PC4_q));
    
    Mux5 PCSelectionMux(.d0(PC0_q), .d1(PC1_q), .d2(PC2_q), .d3(PC3_q), .d4(PC4_q), .sel(sel_read), .Y(q_g));
endmodule
