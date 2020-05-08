# 32-bit-MIPS-processor-VHDL-implementation
Single cycle architecture MIPS processor implementation in VHDL(WIP). 

# processor components:
![Components](/proc.jpg)

# Synthesised schematic:
Available in Schematic.pdf

# Supported instructions:
add, sub, and, or, nor, stl, addi, andi, ori , lw, sw, j, jr, jal

# TODO: 
a. Factor out the IMem entity to fetch the instruction from a separate file.
b. Edit memory entites to support bytes.
c. implement `lb`, `lh`, `sb`, `sh` instructions.
d. test performance.
