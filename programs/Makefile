# Builds the instruction memory image read by IMem's $readmemh from a RISC-V
# assembly program, e.g. `make` or `make PROGRAM=myprog`.

CROSS   ?= riscv64-unknown-elf-
PROGRAM ?= rv32i_test
MEM     ?= ../rtl/InstructionMemory.mem

all: $(MEM)

$(PROGRAM).elf: $(PROGRAM).s
	$(CROSS)as -march=rv32i -mabi=ilp32 -o $(PROGRAM).o $<
	$(CROSS)ld -m elf32lriscv --no-relax -Ttext=0 -o $@ $(PROGRAM).o

# One 32-bit word per entry, zero-padded to the 512 words of the memory.
$(MEM): $(PROGRAM).elf
	$(CROSS)objcopy -O verilog --verilog-data-width=4 --gap-fill=0 --pad-to=2048 $< $@

clean:
	rm -f $(PROGRAM).o $(PROGRAM).elf

.PHONY: all clean
