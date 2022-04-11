#ifndef MIPS_ASSEMBLER_CLASSIFY_H
#define MIPS_ASSEMBLER_CLASSIFY_H

#include <stdint.h>
#include <stdbool.h>
#include <string.h>

typedef struct {
    const char *name;
    uint8_t funct;
} r_type;

extern r_type r_instructions[];
extern size_t r_num;

typedef struct {
    const char *name;
    uint8_t opcode;
} i_type;

extern i_type i_instructions[];
extern size_t i_num;

typedef struct {
    const char *name;
    uint8_t funct;
} sh_type;

extern sh_type sh_instructions[];
extern size_t sh_num;

typedef struct {
    const char *name;
    uint8_t opcode;
} j_type;

extern j_type j_instructions[];
extern size_t j_num;

typedef struct {
    const char *name;
    uint8_t opcode;
} d_type;

extern d_type d_instructions[];
extern size_t d_num;

typedef struct {
    const char *name;
    uint8_t num;
} p_type;

extern p_type p_instructions[];
extern size_t p_num;


bool is_r(const char  *);
bool is_i(const char  *);
bool is_j(const char  *);
bool is_sh(const char *);
bool is_d(const char  *);
bool is_p(const char  *);

int  code(const char  *);

extern const char *regs[];
int reg_num(const char *);
int spec_resolve(const char *);


const char *get_mnemonic(uint32_t);
const char *get_mnemonic_funct(uint8_t);
const char *get_mnemonic_op(uint8_t);

uint8_t get_rs(uint32_t);
uint8_t get_rt(uint32_t);
uint8_t get_rd(uint32_t);

uint8_t get_op(uint32_t);
uint8_t get_funct(uint32_t);

uint8_t get_shamt(uint32_t);

int16_t get_imm(uint32_t);
uint32_t get_j_addr(uint32_t);

uint32_t get_masked_value(uint32_t, uint32_t);

bool is_nop(uint32_t);
#endif //MIPS_ASSEMBLER_CLASSIFY_H
