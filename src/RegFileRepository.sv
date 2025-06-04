`timescale 1ns / 1ps

module RegFileRepository(
    input logic clk,
    input logic[2:0] sel_write,
    input logic[2:0] sel_read,
    input logic WE3_g,
    input logic[4:0] RA1_g, RA2_g, WA3_g,
    input logic[31:0] WD3_g,
    output logic[31:0] RD1_g, RD2_g
);

    logic[31:0] OP1_0;
    logic[31:0] OP2_0;
    RegFile RF0(.clk(clk), .WE3(WE3_g && sel_write == 0), .RA1(RA1_g), .RA2(RA2_g), .WA3(WA3_g), .WD3(WD3_g), .RD1(OP1_0), .RD2(OP2_0));
    
    logic[31:0] OP1_1;
    logic[31:0] OP2_1; 
    RegFile RF1(.clk(clk), .WE3(WE3_g && sel_write == 1), .RA1(RA1_g), .RA2(RA2_g), .WA3(WA3_g), .WD3(WD3_g), .RD1(OP1_1), .RD2(OP2_1)); 
    
    logic[31:0] OP1_2;
    logic[31:0] OP2_2;
    RegFile RF2(.clk(clk), .WE3(WE3_g && sel_write == 2), .RA1(RA1_g), .RA2(RA2_g), .WA3(WA3_g), .WD3(WD3_g), .RD1(OP1_2), .RD2(OP2_2)); 
    
    logic[31:0] OP1_3;
    logic[31:0] OP2_3;
    RegFile RF3(.clk(clk), .WE3(WE3_g && sel_write == 3), .RA1(RA1_g), .RA2(RA2_g), .WA3(WA3_g), .WD3(WD3_g), .RD1(OP1_3), .RD2(OP2_3)); 
    
    logic[31:0] OP1_4;
    logic[31:0] OP2_4;
    RegFile RF4(.clk(clk), .WE3(WE3_g && sel_write == 4), .RA1(RA1_g), .RA2(RA2_g), .WA3(WA3_g), .WD3(WD3_g), .RD1(OP1_4), .RD2(OP2_4)); 
    
    // RD1 selection MUZ:
    Mux #(32, 5) RD1_Mux(
        .data_in({OP1_0, OP1_1, OP1_2, OP1_3, OP1_4}),
        .sel(sel_read),
        .Y(RD1_g)
    );
    
    // RD2 selection MUX:
    Mux #(32, 5) RD2_Mux(
        .data_in({OP2_0, OP2_1, OP2_2, OP2_3, OP2_4}),
        .sel(sel_read),
        .Y(RD2_g)
    );
endmodule
