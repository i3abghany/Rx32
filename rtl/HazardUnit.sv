`timescale 1ns / 1ps

// Resolves hazards like a single-threaded pipeline's hazard unit, but only
// between instructions of the same thread. They only occur when fewer than
// three threads are awake.
module HazardUnit #(parameter NUM_THREADS = 5,
                    localparam SEL_WIDTH = NUM_THREADS > 1 ? $clog2(NUM_THREADS) : 1)(
    input logic ValidF,
    input logic[SEL_WIDTH - 1:0] selF, selD, selE, selM, selW,
    input logic[4:0] Rs1D, Rs2D,
    input logic[4:0] Rs1E, Rs2E, RdE,
    input logic[4:0] RdM, RdW,
    input logic ResultSrcE0,
    input logic RedirectE,
    input logic RegWriteM, RegWriteW,
    output logic[1:0] ForwardAE, ForwardBE,
    output logic StallF, StallD,
    output logic FlushD, FlushE
);
    logic lwStall;

    // Forward from the thread's most recent writer of the register in Memory or
    // Writeback. In Memory, that is never a load (lwStall) or a jump (which
    // flushes the instructions after it), so ALUOutM is its result.
    always_comb begin
        if (RegWriteM && RdM != 0 && RdM == Rs1E && selM == selE)      ForwardAE = 2'b10;
        else if (RegWriteW && RdW != 0 && RdW == Rs1E && selW == selE) ForwardAE = 2'b01;
        else                                                           ForwardAE = 2'b00;

        if (RegWriteM && RdM != 0 && RdM == Rs2E && selM == selE)      ForwardBE = 2'b10;
        else if (RegWriteW && RdW != 0 && RdW == Rs2E && selW == selE) ForwardBE = 2'b01;
        else                                                           ForwardBE = 2'b00;
    end

    // The thread's next instruction waits a cycle in Decode if it reads a
    // load's result. ResultSrcE0 marks loads.
    assign lwStall = ResultSrcE0 && selE == selD && RdE != 0 && (RdE == Rs1D || RdE == Rs2D);
    assign StallF = lwStall;
    assign StallD = lwStall;

    // A taken branch, jump or WFI flushes the instructions its thread fetched
    // after it. Nothing is fetched while every thread is asleep.
    assign FlushD = (RedirectE && selF == selE) || !ValidF;
    assign FlushE = (RedirectE && selD == selE) || lwStall;
endmodule
