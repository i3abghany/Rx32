`timescale 1ns / 1ps

module RegFileRepository #(parameter NUM_THREADS = 5,
                           localparam SEL_WIDTH = NUM_THREADS > 1 ? $clog2(NUM_THREADS) : 1)(
    input logic clk,
    input logic[SEL_WIDTH - 1:0] sel_write,
    input logic[SEL_WIDTH - 1:0] sel_read,
    input logic WE3_g,
    input logic[4:0] RA1_g, RA2_g, WA3_g,
    input logic[31:0] WD3_g,
    output logic[31:0] RD1_g, RD2_g
);

    // One register file per thread.
    logic[31:0] OP1s[0:NUM_THREADS - 1];
    logic[31:0] OP2s[0:NUM_THREADS - 1];
    for (genvar i = 0; i < NUM_THREADS; i++) begin : Thread
        RegFile Regs(.clk(clk), .WE3(WE3_g && sel_write == SEL_WIDTH'(i)), .RA1(RA1_g), .RA2(RA2_g), .WA3(WA3_g), .WD3(WD3_g), .RD1(OP1s[i]), .RD2(OP2s[i]));
    end
    
    logic[31:0] OP1;
    logic[31:0] OP2;

    // RD1 selection MUX:
    Mux #(32, NUM_THREADS) RD1_Mux(
        .data_in(OP1s),
        .sel(sel_read),
        .Y(OP1)
    );
    
    // RD2 selection MUX:
    Mux #(32, NUM_THREADS) RD2_Mux(
        .data_in(OP2s),
        .sel(sel_read),
        .Y(OP2)
    );

    // Pass through a register that the reading thread is writing back.
    assign RD1_g = (WE3_g && sel_write == sel_read && WA3_g == RA1_g && RA1_g != 0) ? WD3_g : OP1;
    assign RD2_g = (WE3_g && sel_write == sel_read && WA3_g == RA2_g && RA2_g != 0) ? WD3_g : OP2;
endmodule
