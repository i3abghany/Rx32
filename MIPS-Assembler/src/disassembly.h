#ifndef MIPS_ASSEMBLER_DISASSEMBLY_H
#define MIPS_ASSEMBLER_DISASSEMBLY_H

#include "classify.h"
#include "defs.h"
#include <stdlib.h>
#include <stdarg.h>


char* concat(size_t, ...);
char *disassemble_inst(uint32_t);

char *disassemble_j_al(int, const char *);
char *disassemble_jalr(uint8_t, uint8_t);
char *disassemble_jr(uint8_t);
char *disassemble_r(const char *, uint8_t, uint8_t, uint8_t);
char *disassemble_sh(const char *, uint8_t, uint8_t, uint8_t);
char *disassemble_i(const char *, uint8_t, uint8_t, int16_t);
char *disassemble_d(const char *, uint8_t, uint8_t, int16_t);
char *disassemble_shv(const char *, uint8_t, uint8_t, uint8_t);

#endif //MIPS_ASSEMBLER_DISASSEMBLY_H
