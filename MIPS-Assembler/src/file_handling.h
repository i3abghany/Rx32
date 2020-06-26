#ifndef MIPS_ASSEMBLER_FILE_HANDLING_H
#define MIPS_ASSEMBLER_FILE_HANDLING_H
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include "symbol_table.h"
#include "defs.h"
#include "mem_handling.h"
#include "classify.h"
#include "disassembly.h"
#include "interlock.h"

extern size_t curr_pc;

int read_line(FILE *, char *, size_t);
bool read_file(const char *, char **, uint16_t *);
void substr(char *, size_t start, size_t end, char *);
void prepend(char *, const char *);
int  indexof(const char *, char);
const char *first_not_empty(const char *);
int get_radix(const char *);

void print_content(char **, size_t);
void print_mem(const char *, uint32_t *, size_t);

char *get_half(char *, char *, int);

bool segment_end(const char *);

void first_pass(char **, symbol *);
void resolve_data_segment(char **, size_t);
void resolve_text_segment(char **, size_t);

void substitute_psuedo(char **, int, int);
void decode_psuedo(char *, char *, char *);
void insert_line(char **, char *, size_t);
void shift_downwards(char **, size_t);
void swap_lines(char *, char *);

size_t effective_instructions(char **, size_t);
char **trim(char **, size_t);
void second_pass(char **, size_t, symbol *, uint32_t *);

#endif //MIPS_ASSEMBLER_FILE_HANDLING_H
