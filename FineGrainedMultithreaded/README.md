# Mips-FGMT

A fine-grained multithreaded, five-stage pipelined microarchitecture implementation.
It deals with hazards by filling the pipeline with instructions from 5 separate programs. With this setup, it assures no dependencies, assuming memory coherence.
This design improves throughput, as it requires no stalls. Also, it can improve clock frequency because it removes the forwarding paths that lengthened the stages in a typical pipelined design. Also, it gives the ability to remove the hazard detection unit which also lengthens the critical paths.
The downside is that it reduces the single-program throughput to one instruction per the full pipeline and it consumes more hardware(The program counter repository and the register file repository.)