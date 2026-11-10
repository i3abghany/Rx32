# Builds the instruction memory image read by IMem's $readmemh from a RISC-V
# assembly program, e.g. `make`, `make PROGRAM=myprog` or `make THREADS=3`.

CROSS   ?= riscv64-unknown-elf-
PROGRAM ?= rv32i_test
THREADS ?= 5
MEM     ?= ../rtl/InstructionMemory.mem

# IMem's size (see Top): 400 bytes per thread (at least 5), as a power of two.
IMEM_BYTES := $(shell b=2048; while [ $$b -lt $$((400 * $(THREADS))) ]; do b=$$((b * 2)); done; echo $$b)

all: $(MEM)

# Always rebuilt, as THREADS may have changed.
$(PROGRAM).elf: $(PROGRAM).s FORCE
	$(CROSS)as -march=rv32i -mabi=ilp32 --defsym THREADS=$(THREADS) -o $(PROGRAM).o $<
	$(CROSS)ld -m elf32lriscv --no-relax -Ttext=0 -o $@ $(PROGRAM).o

# One 32-bit word per entry, zero-padded to the size of IMem.
$(MEM): $(PROGRAM).elf
	$(CROSS)objcopy -O verilog --verilog-data-width=4 --gap-fill=0 --pad-to=$(IMEM_BYTES) $< $@

clean:
	rm -f $(PROGRAM).o $(PROGRAM).elf

FORCE:

.PHONY: all clean FORCE
