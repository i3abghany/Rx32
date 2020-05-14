# 32-bit-MIPS-processor-VHDL-implementation
Single cycle architecture MIPS processor implementation in VHDL(WIP). 

# Synthesised schematic:
Available in Schematic.pdf

# Supported instructions:
add, sub, and, or, nor, stl, addi, andi, ori , lw, sw, j, jr, jal

# TODO: 
* Factor out the IMem entity to fetch the instruction from a separate file.
* Edit memory entites to support bytes.
* implement `lb`, `lh`, `sb`, `sh` instructions.
* test performance.
