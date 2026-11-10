`timescale 1ns / 1ps

// Each thread's fetch PC. The fetched thread (sel_read) moves on to d_next and
// a redirected one (sel_redirect) to d_redirect, which wins if they're the same.
module PCRepository (input logic clk, reset,
                    input logic[2:0] sel_read,
                    input logic en_next,
                    input logic[31:0] d_next,
                    input logic[2:0] sel_redirect,
                    input logic en_redirect,
                    input logic[31:0] d_redirect,
                    output logic[31:0] q_g         
                );
    
    logic [31:0] PC_q [0:4];
    logic [4:0] next, redirect;

    assign next     = {4'b0, en_next} << sel_read;
    assign redirect = {4'b0, en_redirect} << sel_redirect;

    PCReg #(.WIDTH(32), .RESET_VAL(0)) PC0(.clk(clk), .reset(reset), .en(next[0] || redirect[0]), .clear(1'b0), .d(redirect[0] ? d_redirect : d_next), .q(PC_q[0]));
    PCReg #(.WIDTH(32), .RESET_VAL(400)) PC1(.clk(clk), .reset(reset), .en(next[1] || redirect[1]), .clear(1'b0), .d(redirect[1] ? d_redirect : d_next), .q(PC_q[1]));
    PCReg #(.WIDTH(32), .RESET_VAL(800)) PC2(.clk(clk), .reset(reset), .en(next[2] || redirect[2]), .clear(1'b0), .d(redirect[2] ? d_redirect : d_next), .q(PC_q[2]));
    PCReg #(.WIDTH(32), .RESET_VAL(1200)) PC3(.clk(clk), .reset(reset), .en(next[3] || redirect[3]), .clear(1'b0), .d(redirect[3] ? d_redirect : d_next), .q(PC_q[3]));
    PCReg #(.WIDTH(32), .RESET_VAL(1600)) PC4(.clk(clk), .reset(reset), .en(next[4] || redirect[4]), .clear(1'b0), .d(redirect[4] ? d_redirect : d_next), .q(PC_q[4]));
    
    Mux #(32, 5) PCSelectionMux(
        .data_in(PC_q),
        .sel(sel_read),
        .Y(q_g)
    );
endmodule
