# Builds the Rx32 testbench with Verilator and runs it, e.g. `make sim` or
# `make sim MEM=rtl/hazard_test.mem`. MEM is the instruction memory image to
# run, built from programs/ (see programs/Makefile).

VERILATOR ?= verilator
TB        ?= Top_tb
MEM       ?= rtl/InstructionMemory.mem
OBJ_DIR   ?= obj_dir

SRCS := $(filter-out %_tb.sv,$(wildcard rtl/*.sv)) rtl/$(TB).sv
BIN  := $(OBJ_DIR)/V$(TB)

# Runs in rtl/, since IMem loads InstructionMemory.mem from the working directory.
sim: $(BIN)
	cd rtl && $(abspath $(BIN)) +program=$(abspath $(MEM))

$(BIN): $(SRCS)
	$(VERILATOR) --binary -j 0 --top-module $(TB) --Mdir $(OBJ_DIR) $(SRCS)

clean:
	rm -rf $(OBJ_DIR)

.PHONY: sim clean
