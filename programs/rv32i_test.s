# Self-checking RV32I test program for Rx32.
#
# Each of the five hardware threads runs its own program out of a 400-byte
# (100-instruction) slot of the instruction memory, since PCRepository resets
# thread i's PC to 400 * i. `.org` places each program at the start of its slot,
# and fails the build if the program before it overflowed its slot.
#
# Each thread keeps the number of its current check in gp. When it is done, it
# stores its status word to RESULTS + 4 * i and spins: 1 if all of its checks
# passed, (n << 1) | 1 if check n failed.

    .option norelax

    .ifndef DATA_BASE
    .equ DATA_BASE, 0x0
    .endif

    .equ RESULTS, DATA_BASE             # One status word per thread.
    .equ SCRATCH, DATA_BASE + 0x100     # Thread 2's load/store area.
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
# Thread 0: register-register ALU instructions.
############################################################################
thread0:
    li   s1, RESULTS + 0
    li   a0, 0x87654321
    li   a1, 0x0f0f0f24         # Shifts by a1 use only a1[4:0] = 4.
    li   a3, 31

    add  a2, a0, a1
    CHECK 1, a2, 0x96745245
    sub  a2, a0, a1
    CHECK 2, a2, 0x785633fd
    sll  a2, a0, a1
    CHECK 3, a2, 0x76543210
    slt  a2, a0, a1
    CHECK 4, a2, 1
    slt  a2, a1, a0
    CHECK 5, a2, 0
    sltu a2, a0, a1
    CHECK 6, a2, 0
    sltu a2, a1, a0
    CHECK 7, a2, 1
    xor  a2, a0, a1
    CHECK 8, a2, 0x886a4c05
    srl  a2, a0, a1
    CHECK 9, a2, 0x08765432
    sra  a2, a0, a1
    CHECK 10, a2, 0xf8765432
    or   a2, a0, a1
    CHECK 11, a2, 0x8f6f4f25
    and  a2, a0, a1
    CHECK 12, a2, 0x07050320
    sra  a2, a0, a3
    CHECK 13, a2, 0xffffffff
    srl  a2, a0, a3
    CHECK 14, a2, 1
    sub  a2, a0, a0
    CHECK 15, a2, 0
    slt  a2, a0, a0
    CHECK 16, a2, 0
    add  zero, a0, a1           # Writes to x0 are discarded.
    CHECK 17, zero, 0
    j    pass

############################################################################
# Thread 1: register-immediate ALU instructions, LUI and AUIPC.
############################################################################
    .org 400
thread1:
    li   s1, RESULTS + 4
    li   a0, 0xfedcba98
    li   a1, 0x123

    addi a2, a0, 2047
    CHECK 1, a2, 0xfedcc297
    addi a2, a0, -2048
    CHECK 2, a2, 0xfedcb298
    slti a2, a0, -1
    CHECK 3, a2, 1
    slti a2, a1, 0x123
    CHECK 4, a2, 0
    slti a2, a1, 0x124
    CHECK 5, a2, 1
    sltiu a2, a0, -1            # The immediate is sign-extended to 0xffffffff.
    CHECK 6, a2, 1
    sltiu a2, a0, 2047
    CHECK 7, a2, 0
    xori a2, a0, -1
    CHECK 8, a2, 0x01234567
    ori  a2, a0, 0x0f0
    CHECK 9, a2, 0xfedcbaf8
    andi a2, a0, 0x7f0
    CHECK 10, a2, 0x00000290
    andi a2, a0, -16
    CHECK 11, a2, 0xfedcba90
    slli a2, a0, 3
    CHECK 12, a2, 0xf6e5d4c0
    srli a2, a0, 28
    CHECK 13, a2, 0x0000000f
    srai a2, a0, 28
    CHECK 14, a2, 0xffffffff
    srai a2, a1, 4
    CHECK 15, a2, 0x00000012
    lui  a2, 0xfffff
    CHECK 16, a2, 0xfffff000
    lui  a2, 0x12345
    CHECK 17, a2, 0x12345000

    li   gp, 18
t1_auipc0:
    auipc a2, 0
    lui  t6, %hi(t1_auipc0)
    addi t6, t6, %lo(t1_auipc0)
    bne  a2, t6, fail

    li   gp, 19
t1_auipc1:
    auipc a2, 1
    lui  t6, %hi(t1_auipc1 + 0x1000)
    addi t6, t6, %lo(t1_auipc1 + 0x1000)
    bne  a2, t6, fail
    j    pass

############################################################################
# Thread 2: loads and stores of bytes, halfwords and words.
############################################################################
    .org 800
thread2:
    li   s1, RESULTS + 8
    li   s0, SCRATCH + 0x20
    li   a0, 0xf0e17f80         # Bytes 0x80, 0x7f, 0xe1, 0xf0 from address 0.
    li   a1, 0x1234a55a
    sw   a0, 0(s0)

    lw   a2, 0(s0)
    CHECK 1, a2, 0xf0e17f80
    lb   a2, 0(s0)
    CHECK 2, a2, 0xffffff80
    lbu  a2, 0(s0)
    CHECK 3, a2, 0x00000080
    lb   a2, 1(s0)
    CHECK 4, a2, 0x0000007f
    lb   a2, 2(s0)
    CHECK 5, a2, 0xffffffe1
    lbu  a2, 3(s0)
    CHECK 6, a2, 0x000000f0
    lh   a2, 0(s0)
    CHECK 7, a2, 0x00007f80
    lh   a2, 2(s0)
    CHECK 8, a2, 0xfffff0e1
    lhu  a2, 2(s0)
    CHECK 9, a2, 0x0000f0e1

    # Partial stores into the zeroed word at 4(s0) leave the other bytes alone.
    sb   a0, 5(s0)
    lw   a2, 4(s0)
    CHECK 10, a2, 0x00008000
    sh   a0, 6(s0)
    lw   a2, 4(s0)
    CHECK 11, a2, 0x7f808000
    sb   a1, 4(s0)
    lw   a2, 4(s0)
    CHECK 12, a2, 0x7f80805a
    sb   a1, 7(s0)
    lw   a2, 4(s0)
    CHECK 13, a2, 0x5a80805a
    sh   a1, 4(s0)
    lw   a2, 4(s0)
    CHECK 14, a2, 0x5a80a55a

    sw   a1, -4(s0)
    lw   a2, -4(s0)
    CHECK 15, a2, 0x1234a55a
    lw   a2, 0(s0)
    CHECK 16, a2, 0xf0e17f80
    j    pass

############################################################################
# Thread 3: conditional branches.
############################################################################
    .org 1200
thread3:
    li   s1, RESULTS + 12
    li   a0, 0x80000000         # Below a1 when signed, above it when unsigned.
    li   a1, 0x7fffffff

    # Taken branches skip the jump to fail.
    li   gp, 1
    beq  a0, a0, 1f
    j    fail
1:  li   gp, 2
    bne  a0, a1, 1f
    j    fail
1:  li   gp, 3
    blt  a0, a1, 1f
    j    fail
1:  li   gp, 4
    bge  a1, a0, 1f
    j    fail
1:  li   gp, 5
    bge  a0, a0, 1f
    j    fail
1:  li   gp, 6
    bltu a1, a0, 1f
    j    fail
1:  li   gp, 7
    bgeu a0, a1, 1f
    j    fail
1:  li   gp, 8
    bgeu a1, a1, 1f
    j    fail
1:

    # Branches that are not taken fall through.
    li   gp, 9
    beq  a0, a1, fail
    li   gp, 10
    bne  a0, a0, fail
    li   gp, 11
    blt  a1, a0, fail
    li   gp, 12
    blt  a0, a0, fail
    li   gp, 13
    bge  a0, a1, fail
    li   gp, 14
    bltu a0, a1, fail
    li   gp, 15
    bltu a0, a0, fail
    li   gp, 16
    bgeu a1, a0, fail

    # A loop that branches backwards.
    li   a2, 10
    li   a3, 0
1:  addi a3, a3, 3
    addi a2, a2, -1
    bnez a2, 1b
    CHECK 17, a3, 30
    j    pass

############################################################################
# Thread 4: JAL, JALR and a recursive function.
############################################################################
    .org 1600
thread4:
    li   s1, RESULTS + 16
    li   sp, STACK

    # JAL jumps to its target and links the address after it.
    li   gp, 1
    jal  ra, t4_jal_target
t4_jal_link:
    j    fail
t4_jal_target:
    lui  t6, %hi(t4_jal_link)
    addi t6, t6, %lo(t4_jal_link)
    bne  ra, t6, fail

    # JALR jumps to rs1 + imm with bit 0 cleared.
    li   gp, 2
    lui  t0, %hi(t4_jalr_target - 7)
    addi t0, t0, %lo(t4_jalr_target - 7)
    jalr ra, 8(t0)
t4_jalr_link:
    j    fail
t4_jalr_target:
    lui  t6, %hi(t4_jalr_link)
    addi t6, t6, %lo(t4_jalr_link)
    bne  ra, t6, fail

    # JALR reads rs1 before writing rd when they are the same register.
    li   gp, 3
    lui  t0, %hi(t4_jalr_same_target)
    addi t0, t0, %lo(t4_jalr_same_target)
    jalr t0, 0(t0)
t4_jalr_same_link:
    j    fail
t4_jalr_same_target:
    lui  t6, %hi(t4_jalr_same_link)
    addi t6, t6, %lo(t4_jalr_same_link)
    bne  t0, t6, fail

    li   a0, 2
    li   a1, 3
    jal  ra, ackermann
    CHECK 4, a0, 9
    CHECK 5, sp, STACK
    j    pass

# Ackermann's function A(m = a0, n = a1), returned in a0.
ackermann:
    addi sp, sp, -8
    sw   ra, 4(sp)
    sw   s0, 0(sp)
    bnez a0, 1f
    addi a0, a1, 1              # A(0, n) = n + 1
    j    3f
1:  bnez a1, 2f
    addi a0, a0, -1             # A(m, 0) = A(m - 1, 1)
    li   a1, 1
    jal  ra, ackermann
    j    3f
2:  mv   s0, a0                 # A(m, n) = A(m - 1, A(m, n - 1))
    addi a1, a1, -1
    jal  ra, ackermann
    mv   a1, a0
    addi a0, s0, -1
    jal  ra, ackermann
3:  lw   s0, 0(sp)
    lw   ra, 4(sp)
    addi sp, sp, 8
    ret

############################################################################
# Shared by all threads, in the words after thread 4's slot. s1 holds the
# address of the running thread's status word.
############################################################################
    .org 2000
pass:
    li   t6, 1
    sw   t6, 0(s1)
1:  j    1b

fail:
    slli gp, gp, 1
    ori  gp, gp, 1
    sw   gp, 0(s1)
1:  j    1b
