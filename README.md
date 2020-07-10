# Mips32
Implementation of Single-Cycle, Multi-Cycle, and a Pipelined microarchitecture which support a subset of the MIPS ISA.
For the Pipelined processor, build hardware dependencies resolution and also built an assembler that supports software-based interlocking.

The tradeoff made is that the resolution of dependencies could be simply run on the software, making the hardware design simpler and potentially increasing frequency, but also takes away forwarding between the different pipeline stages, therefore increases average cycles per instruction (CPI).

Also built a Fine-grained multi threaded microarchitecture, which tolerates dependencies by executing from 5 main threads in series, so no two instructions in the pipeline would ever be dependent. (assuming memory coherence). The tradeoff made with the FGMT microarchitecture is that it omits the Hazard unit (dependencies detection and resolution unit.) which might lead to better clock rate, with the same overall throughput, but reducing the single-thread performance. (Executing
one instruction per thread in the full pipeline.)
