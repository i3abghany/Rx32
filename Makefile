# Builds the Rx32 testbench with Verilator and runs it, e.g. `make sim`,
# `make sim MEM=rtl/hazard_test.mem` or `make sim THREADS=3`. MEM is the
# instruction memory image to run, built from programs/ for THREADS threads
# (see programs/Makefile). `make test` runs both test programs at each thread
# count in TEST_THREADS.

VERILATOR    ?= verilator
THREADS      ?= 5
TB           ?= Top_tb
OBJ_DIR      ?= obj_dir
TEST_THREADS ?= 1 2 3 4 5 6 7 8

# Each thread count builds in its own directory.
BUILD := $(OBJ_DIR)/threads$(THREADS)

# Only the 5-thread images are checked in.
ifeq ($(THREADS),5)
MEM ?= rtl/InstructionMemory.mem
else
MEM ?= $(BUILD)/rv32i_test.mem
endif

SRCS := $(filter-out %_tb.sv,$(wildcard rtl/*.sv)) rtl/$(TB).sv
BIN  := $(BUILD)/V$(TB)

# Only Top_tb has NUM_THREADS.
PARAMS := $(if $(filter Top_tb,$(TB)),-GNUM_THREADS=$(THREADS))

# Runs in rtl/, since IMem loads InstructionMemory.mem from the working directory.
sim: $(BIN) $(MEM)
	cd rtl && $(abspath $(BIN)) +program=$(abspath $(MEM))

$(BIN): $(SRCS)
	mkdir -p $(@D)
	$(VERILATOR) --binary -j 0 --top-module $(TB) $(PARAMS) --Mdir $(BUILD) $(SRCS)

# The image of programs/<name>.s for THREADS threads.
$(BUILD)/%.mem: programs/%.s FORCE
	mkdir -p $(@D)
	$(MAKE) -C programs PROGRAM=$* THREADS=$(THREADS) MEM=$(abspath $@)

test:
	for t in $(TEST_THREADS); do \
	    for p in rv32i_test hazard_test; do \
	        $(MAKE) sim THREADS=$$t MEM=$(OBJ_DIR)/threads$$t/$$p.mem || exit 1; \
	    done; \
	done

clean:
	rm -rf $(OBJ_DIR)

FORCE:

.PHONY: sim test clean FORCE
