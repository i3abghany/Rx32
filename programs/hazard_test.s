# Self-checking test of Rx32's WFI and hazard handling.
#
# Every thread sleeps in WFI as soon as it starts, and Top_tb wakes the threads
# one at a time, so each runs its checks alone, as on a single-threaded
# pipeline. Top_tb wakes each thread only once, so a thread that sleeps again
# before reporting never finishes.
#
# Slots, gp and status words are as in rv32i_test.s. The `nop`s space out
# dependent instructions so that the result comes from a given stage.

    .option norelax

    .ifndef DATA_BASE
    .equ DATA_BASE, 0x0
    .endif

    .equ RESULTS, DATA_BASE             # One status word per thread.
    .equ SCRATCH, DATA_BASE + 0x100     # 64 bytes per thread.
    .equ STACK,   DATA_BASE + 0x400     # Top of thread 4's stack.

    # Check \num fails unless \reg holds \val.
    .macro CHECK num, reg, val
        li   gp, \num
        li   t6, \val
        bne  \reg, t6, fail
    .endm

    .text
    .globl _start
_start:

############################################################################
# Thread 0: forwarding of ALU results to ALU instructions.
############################################################################
thread0:
    li   s1, RESULTS + 0
    li   s0, SCRATCH + 0x00
    wfi

    # From the Memory stage, to rs1 and rs2.
    li   a0, 5
    addi a1, a0, 1
    CHECK 1, a1, 6
    li   a0, 7
    sub  a1, zero, a0
    CHECK 2, a1, -7

    # From the Writeback stage.
    li   a0, 9
    nop
    addi a1, a0, 1
    CHECK 3, a1, 10
    li   a0, 11
    nop
    sub  a1, zero, a0
    CHECK 4, a1, -11

    # Through the register file as it is written.
    li   a0, 13
    nop
    nop
    addi a1, a0, 1
    CHECK 5, a1, 14
    li   a0, 15
    nop
    nop
    sub  a1, zero, a0
    CHECK 6, a1, -15

    # The most recent result (3, in Memory, over 1 in Writeback) wins.
    li   a0, 1
    addi a0, a0, 2
    addi a0, a0, 4
    CHECK 7, a0, 7

    # Both operands, from different stages or the same one.
    li   a0, 0x30
    li   a1, 0x0c
    or   a2, a0, a1
    CHECK 8, a2, 0x3c
    li   a0, 0x21
    add  a2, a0, a0
    CHECK 9, a2, 0x42

    # Writes to x0 are never forwarded.
    addi zero, zero, 1
    addi a1, zero, 0
    CHECK 10, a1, 0
    addi zero, zero, 1
    nop
    addi a1, zero, 0
    CHECK 11, a1, 0
    addi zero, zero, 1
    nop
    nop
    addi a1, zero, 0
    CHECK 12, a1, 0

    # LUI and AUIPC results.
    lui  a0, 0x12345
    srli a1, a0, 12
    CHECK 13, a1, 0x12345
    li   gp, 14
t0_auipc:
    auipc a0, 0
    addi a1, a0, 8
    lui  t6, %hi(t0_auipc + 8)
    addi t6, t6, %lo(t0_auipc + 8)
    bne  a1, t6, fail

    j    pass

############################################################################
# Thread 1: loads.
############################################################################
    .org 400
thread1:
    li   s1, RESULTS + 4
    li   s0, SCRATCH + 0x40
    wfi

    li   a0, 0x8001
    sw   a0, 0(s0)
    li   a0, 17
    sw   a0, 4(s0)
    sw   s0, 8(s0)              # A pointer to the data.

    # Read by the next instruction, which stalls, in rs1 and rs2.
    lw   a1, 0(s0)
    addi a2, a1, 1
    CHECK 1, a2, 0x8002
    lw   a1, 4(s0)
    sub  a2, zero, a1
    CHECK 2, a2, -17

    # From the Writeback stage, and through the register file.
    lw   a1, 4(s0)
    nop
    addi a2, a1, 1
    CHECK 3, a2, 18
    lw   a1, 4(s0)
    nop
    nop
    addi a2, a1, 1
    CHECK 4, a2, 18

    # As store data, store and load addresses.
    lw   a1, 4(s0)
    sw   a1, 12(s0)
    lw   a2, 12(s0)
    CHECK 5, a2, 17
    lw   t0, 8(s0)
    lw   a2, 4(t0)
    CHECK 6, a2, 17
    lw   t0, 8(s0)
    sw   a0, 16(t0)
    lw   a2, 16(s0)
    CHECK 7, a2, 17

    # As branch operands. The branch must be taken.
    li   gp, 8
    lw   a1, 4(s0)
    beq  a1, a0, 1f
    j    fail
1:

    # Extended bytes and halfwords.
    lb   a1, 1(s0)
    addi a2, a1, 0
    CHECK 9, a2, -128
    lhu  a1, 0(s0)
    addi a2, a1, 0
    CHECK 10, a2, 0x8001

    # Loads to x0 are not forwarded.
    lw   zero, 4(s0)
    addi a2, zero, 0
    CHECK 11, a2, 0

    # Two loads into one instruction's operands: it stalls for the second and
    # gets the first through the register file.
    lw   a1, 0(s0)
    lw   a2, 4(s0)
    add  a3, a1, a2
    CHECK 12, a3, 0x8012

    # Two loads into the same register: the second one wins.
    lw   a1, 0(s0)
    lw   a1, 4(s0)
    addi a2, a1, 0
    CHECK 13, a2, 17

    # Incrementing a word in memory: the store's data comes from Memory.
    lw   a1, 4(s0)
    addi a1, a1, 1
    sw   a1, 4(s0)
    lw   a2, 4(s0)
    CHECK 14, a2, 18
    j    pass

############################################################################
# Thread 2: branches and jumps.
############################################################################
    .org 800
thread2:
    li   s1, RESULTS + 8
    li   s0, SCRATCH + 0x80
    wfi

    # Taken branches flush the two instructions after them...
    li   gp, 1
    li   a0, 0
    beq  zero, zero, 1f
    addi a0, a0, 1
    addi a0, a0, 2
1:  bnez a0, fail

    # ...which do not store anything...
    li   gp, 2
    sw   zero, 0(s0)
    li   a0, 1
    beq  a0, a0, 1f
    sw   a0, 0(s0)
    sw   a0, 0(s0)
1:  lw   a1, 0(s0)
    bnez a1, fail

    # ...and branches that are not taken do not.
    li   gp, 3
    li   a0, 0
    bne  zero, zero, fail
    addi a0, a0, 1
    addi a0, a0, 2
    li   t6, 3
    bne  a0, t6, fail

    # JAL flushes too, and the instruction at its target reads the link.
    li   gp, 4
    li   a0, 0
    jal  ra, 1f
t2_jal_link:
    addi a0, a0, 1
    addi a0, a0, 2
1:  mv   a1, ra
    bnez a0, fail
    lui  t6, %hi(t2_jal_link)
    addi t6, t6, %lo(t2_jal_link)
    bne  a1, t6, fail

    # JALR, with its base from the Memory stage.
    li   gp, 5
    li   a0, 0
    lui  t0, %hi(1f)
    addi t0, t0, %lo(1f)
    jalr ra, 0(t0)
t2_jalr_link:
    addi a0, a0, 1
    addi a0, a0, 2
1:  bnez a0, fail
    lui  t6, %hi(t2_jalr_link)
    addi t6, t6, %lo(t2_jalr_link)
    bne  ra, t6, fail

    # JALR, with its base from a load.
    li   gp, 6
    lui  t0, %hi(1f)
    addi t0, t0, %lo(1f)
    sw   t0, 4(s0)
    lw   t1, 4(s0)
    jalr zero, 0(t1)
    j    fail
1:

    # A loop whose branch reads the previous instruction's result.
    li   a0, 0
    li   a1, 10
1:  add  a0, a0, a1
    addi a1, a1, -1
    bnez a1, 1b
    CHECK 7, a0, 55

    # Jumps and branches at each other's targets.
    li   gp, 8
    beq  zero, zero, 1f
    j    fail
1:  j    1f
    j    fail
1:  bne  zero, zero, fail
    beq  zero, zero, 1f
    j    fail
1:

    # A branch that stalls for a load, then flushes.
    li   gp, 9
    li   a0, 0
    sw   zero, 4(s0)
    lw   a1, 4(s0)
    beqz a1, 1f
    addi a0, a0, 1
    addi a0, a0, 2
1:  bnez a0, fail
    j    pass

############################################################################
# Thread 3: loops over memory.
############################################################################
    .org 1200
thread3:
    li   s1, RESULTS + 12
    li   s0, SCRATCH + 0xc0
    wfi

    # ECALL and EBREAK do not sleep.
    ecall
    ebreak

    # Store the first ten Fibonacci numbers, then add them up.
    li   a0, 0
    li   a1, 1
    mv   t0, s0
    li   t1, 10
1:  sw   a0, 0(t0)
    add  a2, a0, a1
    mv   a0, a1
    mv   a1, a2
    addi t0, t0, 4
    addi t1, t1, -1
    bnez t1, 1b

    li   a3, 0
    mv   t0, s0
    li   t1, 10
1:  lw   a4, 0(t0)
    add  a3, a3, a4
    addi t0, t0, 4
    addi t1, t1, -1
    bnez t1, 1b
    CHECK 1, a3, 88

    # Reverse their bytes in place; each load is stored right away.
    mv   t0, s0
    addi t1, s0, 39
1:  lbu  a0, 0(t0)
    lbu  a1, 0(t1)
    sb   a1, 0(t0)
    sb   a0, 0(t1)
    addi t0, t0, 1
    addi t1, t1, -1
    bltu t0, t1, 1b
    lw   a0, 0(s0)
    CHECK 2, a0, 0x22000000
    lw   a0, 4(s0)
    CHECK 3, a0, 0x15000000
    lw   a0, 32(s0)
    CHECK 4, a0, 0x01000000
    j    pass

############################################################################
# Thread 4: forwarding to stores and branches, and calls and returns.
############################################################################
    .org 1600
thread4:
    li   s1, RESULTS + 16
    li   s0, SCRATCH + 0x100
    li   sp, STACK
    wfi

    # A store's address from Memory and data from Writeback.
    li   a0, 0x5a
    addi t0, s0, 4
    sw   a0, 0(t0)
    lw   a1, 4(s0)
    CHECK 1, a1, 0x5a

    # Branch operands. The branches must be taken...
    li   gp, 2
    li   a0, 3
    li   a1, 3
    beq  a0, a1, 1f
    j    fail
1:  li   a1, 4
    bltu a0, a1, 1f
    j    fail
1:  li   a0, -1
    nop
    blt  a0, zero, 1f
    j    fail
1:
    # ...and these must not be.
    li   gp, 3
    li   a0, 3
    li   a1, 4
    beq  a0, a1, fail
    addi a1, a1, -1
    bne  a0, a1, fail

    # A(2, 2) = 7. Its returns load ra right before the JALR that reads it.
    li   a0, 2
    li   a1, 2
    jal  ra, ackermann
    CHECK 4, a0, 7
    CHECK 5, sp, STACK
    j    pass

# Ackermann's function A(m = a0, n = a1), returned in a0.
ackermann:
    addi sp, sp, -8
    sw   ra, 4(sp)
    sw   s2, 0(sp)
    bnez a0, 1f
    addi a0, a1, 1              # A(0, n) = n + 1
    j    3f
1:  bnez a1, 2f
    addi a0, a0, -1             # A(m, 0) = A(m - 1, 1)
    li   a1, 1
    jal  ra, ackermann
    j    3f
2:  mv   s2, a0                 # A(m, n) = A(m - 1, A(m, n - 1))
    addi a1, a1, -1
    jal  ra, ackermann
    mv   a1, a0
    addi a0, s2, -1
    jal  ra, ackermann
3:  lw   s2, 0(sp)
    addi sp, sp, 8
    lw   ra, -4(sp)
    jalr zero, 0(ra)

############################################################################
# Shared by all threads, in the words after thread 4's slot. s1 holds the
# address of the running thread's status word.
############################################################################
    .org 2000
pass:
    li   t6, 1
    sw   t6, 0(s1)
    # Top_tb never wakes a thread again after it reports, so the stores after
    # the WFI must be flushed. They would report check 100 as failed.
    li   t6, (100 << 1) | 1
    wfi
    sw   t6, 0(s1)
    sw   t6, 0(s1)

fail:
    slli gp, gp, 1
    ori  gp, gp, 1
    sw   gp, 0(s1)
1:  wfi
    j    1b
