# Mips32
Implementation of Single-Cycle, Multi-Cycle, and a Pipelined microarchitecture which support a subset of the MIPS ISA.
For the Pipelined processor, build hardware dependencies resolution and also built an assembler that supports software-based interlocking.

The tradeoff made is that the resolution of dependencies could be simply run on the software, making the hardware design simpler and potentially increasing frequency, but also takes away forwarding between the different pipeline stages, therefore increases average cycles per instruction (CPI).

## TODO: 
- Support Exceptions
- Implement Fine-Grained Multithreading(FGMT) support.
