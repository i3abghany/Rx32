#ifndef MIPS_ASSEMBLER_DEFS_H
#define MIPS_ASSEMBLER_DEFS_H
#include <stdint.h>
#include <math.h>

#define TINYMIPS            0
#define INSTRUCTIONLENGTH   32
#define MEMORYLENGTH        2048
#define GP                  0x10008000
#define SP                  0x7FFFFFFC

#if TINYMIPS
    #define PC                  0x00000000
#else
    #define PC                  0x00400000
#endif

#define HIGH 1
#define LOW 0

#define LINELENGTH          128
#define SYMBOLTABLESIZE     1024

#define SHAMTMASK  0x000007C0
#define OPCODEMASK 0xFC000000
#define SREGMASK   0x03E00000
#define TREGMASK   0x001F0000
#define DREGMASK   0x0000F800
#define FUNCTMASK  0x0000003F

#define IMMMASK    0x0000FFFF
#define ADDRMASK   0x03FFFFFF

#endif //MIPS_ASSEMBLER_DEFS_H
