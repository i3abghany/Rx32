`timescale 1ns / 1ps

// Picks the next awake thread in round-robin order; valid is low if none is.
// A WFI in Execute (sleep) puts its thread to sleep unless its irq line is
// high, and irq wakes it up.
module ThreadSelector #(parameter NUM_THREADS = 5,
                        localparam SEL_WIDTH = NUM_THREADS > 1 ? $clog2(NUM_THREADS) : 1) (
        input logic reset,
        input logic clk,
        input logic en,
        input logic sleep,
        input logic[SEL_WIDTH - 1:0] sel_sleep,
        input logic[NUM_THREADS - 1:0] irq,
        output logic[SEL_WIDTH - 1:0] sel,
        output logic valid
    );
    localparam logic[SEL_WIDTH - 1:0] LAST_THREAD = SEL_WIDTH'(NUM_THREADS - 1);

    logic[NUM_THREADS - 1:0] asleep;
    logic[SEL_WIDTH - 1:0] last;
    logic[SEL_WIDTH - 1:0] next;

    always_comb begin
        valid = 1'b0;
        sel = last;
        next = last;
        for (int i = 0; i < NUM_THREADS; i++) begin
            next = (next == LAST_THREAD) ? '0 : next + SEL_WIDTH'(1);
            if (!valid && !asleep[next]) begin
                valid = 1'b1;
                sel = next;
            end
        end
    end 
    
    always_ff @(posedge clk, posedge reset)
    begin
        if (reset) begin
            last <= LAST_THREAD;
            asleep <= '0;
        end else begin
            // Stalled fetches keep their turn.
            if (en && valid) last <= sel;
            asleep <= (asleep | (NUM_THREADS'(sleep) << sel_sleep)) & ~irq;
        end
    end
endmodule
