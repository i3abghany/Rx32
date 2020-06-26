#ifndef MIPS_ASSEMBLER_SYMBOL_TABLE_H
#define MIPS_ASSEMBLER_SYMBOL_TABLE_H

#include <stdint.h>
#include <stdlib.h>
#include "defs.h"
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
typedef struct {
    char name[64];
    uint32_t address, num_words;
} symbol;

extern uint16_t sym_num;
symbol symbol_table[SYMBOLTABLESIZE];

void add_symbol(const char *, uint32_t, uint32_t);
bool sym_exist(const char *);
void resolve_symbols(char **, uint32_t *mem);
void print_table();

int get_address(const char *);

#endif //MIPS_ASSEMBLER_SYMBOL_TABLE_H
