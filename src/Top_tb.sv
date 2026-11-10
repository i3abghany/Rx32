`timescale 1ns / 1ps

// Runs the program in InstructionMemory.mem (built from programs/rv32i_test.s)
// until every thread has stored its status word to data memory word i:
// 1 if all of the thread's checks passed, (n << 1) | 1 if check n failed.
module Top_tb();
    localparam THREADS = 5;
    localparam MAX_CYCLES = 20000;

    logic clk, reset;
    logic[31:0] status;
    logic failed;

    Top DUT(.clk(clk), .reset(reset));

    always #5 clk = ~clk;

    function automatic logic all_done();
        for (int i = 0; i < THREADS; i++)
            if (DUT.DataMemory.RAM[i] == 0) return 0;
        return 1;
    endfunction

    initial begin
        clk = 0;
        reset = 1;
        repeat (2) @(negedge clk);
        reset = 0;

        for (int cycle = 0; cycle < MAX_CYCLES && !all_done(); cycle++)
            @(negedge clk);

        failed = 0;
        for (int i = 0; i < THREADS; i++) begin
            status = DUT.DataMemory.RAM[i];
            if (status == 1)
                $display("Thread %0d: passed", i);
            else begin
                failed = 1;
                if (status == 0) $display("Thread %0d: FAILED, did not finish in %0d cycles", i, MAX_CYCLES);
                else             $display("Thread %0d: FAILED check %0d", i, status >> 1);
            end
        end
        if (failed) $fatal(1, "FAIL");
        $display("PASS");
        $finish;
    end
endmodule
