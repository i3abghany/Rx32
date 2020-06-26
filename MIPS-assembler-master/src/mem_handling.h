#ifndef MIPS_ASSEMBLER_MEM_HANDLING_H
#define MIPS_ASSEMBLER_MEM_HANDLING_H
#include "defs.h"
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
char** init_mem(size_t, size_t);
void free_mem(void **p, size_t);
size_t get_size(char **);
size_t get_memory_size(const uint32_t *);
#endif //MIPS_ASSEMBLER_MEM_HANDLING_H
