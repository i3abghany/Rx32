`timescale 1ns / 1ps

// Picks the next awake thread in round-robin order; valid is low if none is.
// A WFI in Execute (sleep) puts its thread to sleep unless its irq line is
// high, and irq wakes it up.
module ThreadSelector (
        input logic reset,
        input logic clk,
        input logic en,
        input logic sleep,
        input logic[2:0] sel_sleep,
        input logic[4:0] irq,
        output logic[2:0] sel,
        output logic valid
    );
    logic[4:0] asleep;
    logic[2:0] last;
    logic[2:0] next;

    always_comb begin
        valid = 1'b0;
        sel = last;
        next = last;
        for (int i = 0; i < 5; i++) begin
            next = (next == 3'd4) ? 3'd0 : next + 3'd1;
            if (!valid && !asleep[next]) begin
                valid = 1'b1;
                sel = next;
            end
        end
    end 
    
    always_ff @(posedge clk, posedge reset)
    begin
        if (reset) begin
            last <= 3'd4;
            asleep <= 5'b0;
        end else begin
            // Stalled fetches keep their turn.
            if (en && valid) last <= sel;
            asleep <= (asleep | ({4'b0, sleep} << sel_sleep)) & ~irq;
        end
    end
endmodule
