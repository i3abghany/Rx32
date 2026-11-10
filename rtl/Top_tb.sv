`timescale 1ns / 1ps

// Runs InstructionMemory.mem (built from programs/rv32i_test.s), or the image
// given with +program=<file>, until every thread has stored its status word to
// data memory word i: 1 if all of the thread's checks passed, (n << 1) | 1 if
// check n failed. Each thread must then be asleep in WFI. The image must be
// built for NUM_THREADS threads.
//
// Threads that sleep before reporting are woken one at a time, in order
// (hazard_test.s relies on this).
module Top_tb #(parameter NUM_THREADS = 5)();
    localparam MAX_CYCLES = 20000;

    logic clk, reset;
    logic[NUM_THREADS - 1:0] irq;
    logic[NUM_THREADS - 1:0] reported, asleep;
    logic[31:0] status;
    logic failed;
    string image;
    int cycle;

    Top #(.NUM_THREADS(NUM_THREADS)) DUT(.clk(clk), .reset(reset), .irq(irq));

    always #5 clk = ~clk;

    always_comb
        for (int i = 0; i < NUM_THREADS; i++)
            reported[i] = DUT.DataMemory.RAM[i] != 0;
    assign asleep = DUT.Processor.DP.TS.asleep;

    task automatic step();
        @(negedge clk);
        cycle++;
    endtask

    initial begin
        clk = 0;
        reset = 1;
        irq = 0;
        cycle = 0;
        // After IMem has loaded InstructionMemory.mem.
        @(negedge clk);
        if ($value$plusargs("program=%s", image))
            $readmemh(image, DUT.InstructionMemory.RAM);
        @(negedge clk);
        reset = 0;

        for (int i = 0; i < NUM_THREADS; i++) begin
            while (cycle < MAX_CYCLES && !reported[i] && !asleep[i])
                step();
            if (!reported[i] && asleep[i]) begin
                irq[i] = 1;
                step();
                irq[i] = 0;
            end
            while (cycle < MAX_CYCLES && !reported[i])
                step();
        end
        // Let the last thread go to sleep.
        repeat (20) step();

        failed = 0;
        for (int i = 0; i < NUM_THREADS; i++) begin
            status = DUT.DataMemory.RAM[i];
            if (status == 1 && asleep[i])
                $display("Thread %0d: passed", i);
            else begin
                failed = 1;
                if (status == 0)      $display("Thread %0d: FAILED, did not finish in %0d cycles", i, MAX_CYCLES);
                else if (status != 1) $display("Thread %0d: FAILED check %0d", i, status >> 1);
                else                  $display("Thread %0d: FAILED, not asleep after reporting", i);
            end
        end
        if (failed) $fatal(1, "FAIL");
        $display("PASS");
        $finish;
    end
endmodule
