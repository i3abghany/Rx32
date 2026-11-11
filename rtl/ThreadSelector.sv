`timescale 1ns / 1ps

// Picks the next awake thread in round-robin order; valid is low if none is.
// Like BRCOUNT, it avoids threads with a control transfer in Decode or Execute.
// A WFI in Execute (sleep) puts its thread to sleep unless its irq line is
// high, and irq wakes it up.
module ThreadSelector #(parameter NUM_THREADS = 5,
                        localparam SEL_WIDTH = NUM_THREADS > 1 ? $clog2(NUM_THREADS) : 1) (
        input logic reset,
        input logic clk,
        input logic en,
        input logic[SEL_WIDTH - 1:0] selD,
        input logic controlD,    // Decode has a branch, jump or SYSTEM instruction (WFI).
        input logic sleep,
        input logic[SEL_WIDTH - 1:0] sel_sleep,
        input logic[NUM_THREADS - 1:0] irq,
        output logic[SEL_WIDTH - 1:0] sel,
        output logic valid
    );
    localparam logic[SEL_WIDTH - 1:0] LAST_THREAD = SEL_WIDTH'(NUM_THREADS - 1);

    logic[NUM_THREADS - 1:0] asleep;
    logic[NUM_THREADS - 1:0] riskyD, riskyE, risky;
    logic[SEL_WIDTH - 1:0] last;
    logic[SEL_WIDTH - 1:0] next, rr;

    always_comb begin
        // A fetch behind a control transfer in Decode or Execute is on the wrong path
        // if it redirects.
        riskyD = NUM_THREADS'(controlD) << selD;
        risky = riskyD | riskyE;

        valid = 1'b0;
        rr = last;
        next = last;
        for (int i = 0; i < NUM_THREADS; i++) begin
            next = (next == LAST_THREAD) ? '0 : next + SEL_WIDTH'(1);
            if (!valid && !asleep[next]) begin
                valid = 1'b1;
                rr = next;
            end
        end
        // Refetch the last thread if round-robin's pick is risky. Only two threads fit
        // in Decode and Execute, so with three or more awake, the pick isn't.
        sel = (risky[rr] && !risky[last] && !asleep[last]) ? last : rr;
    end 
    
    always_ff @(posedge clk, posedge reset)
    begin
        if (reset) begin
            last <= LAST_THREAD;
            asleep <= '0;
            riskyE <= '0;
        end else begin
            // Stalled fetches keep their turn.
            if (en && valid) last <= sel;
            asleep <= (asleep | (NUM_THREADS'(sleep) << sel_sleep)) & ~irq;
            riskyE <= riskyD;    // Pessimistic after flushes and stalls.
        end
    end
endmodule
