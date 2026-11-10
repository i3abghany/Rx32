`timescale 1ns / 1ps

// Each thread's fetch PC. The fetched thread (sel_read) moves on to d_next and
// a redirected one (sel_redirect) to d_redirect, which wins if they're the same.
module PCRepository #(parameter NUM_THREADS = 5,
                      localparam SEL_WIDTH = NUM_THREADS > 1 ? $clog2(NUM_THREADS) : 1)
                   (input logic clk, reset,
                    input logic[SEL_WIDTH - 1:0] sel_read,
                    input logic en_next,
                    input logic[31:0] d_next,
                    input logic[SEL_WIDTH - 1:0] sel_redirect,
                    input logic en_redirect,
                    input logic[31:0] d_redirect,
                    output logic[31:0] q_g         
                );
    
    logic [31:0] PC_q [0:NUM_THREADS - 1];
    logic [NUM_THREADS - 1:0] next, redirect;

    assign next     = NUM_THREADS'(en_next) << sel_read;
    assign redirect = NUM_THREADS'(en_redirect) << sel_redirect;

    // Thread i starts at 400 * i, giving each thread 100 instructions.
    for (genvar i = 0; i < NUM_THREADS; i++) begin : Thread
        PCReg #(.WIDTH(32), .RESET_VAL(400 * i)) PC(.clk(clk), .reset(reset), .en(next[i] || redirect[i]), .clear(1'b0), .d(redirect[i] ? d_redirect : d_next), .q(PC_q[i]));
    end
    
    Mux #(32, NUM_THREADS) PCSelectionMux(
        .data_in(PC_q),
        .sel(sel_read),
        .Y(q_g)
    );
endmodule
