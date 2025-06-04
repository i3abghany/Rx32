`timescale 1ns/1ps

module Mux #(parameter WIDTH = 32, parameter NUM_INPUTS = 2)
    (input logic[WIDTH - 1:0] data_in[NUM_INPUTS - 1:0],
     input logic[$clog2(NUM_INPUTS) - 1:0] sel,
     output logic[WIDTH - 1:0] Y
    );

    localparam SEL_WIDTH = $clog2(NUM_INPUTS);

    always_comb begin
        Y = data_in[sel];
    end

endmodule