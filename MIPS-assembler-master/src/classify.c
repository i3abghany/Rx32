#include "classify.h"
#include "defs.h"

i_type i_instructions[] = {
        {"addi",   8},
        {"addiu",  9},
        {"andi",  12},
        {"ori",   13},
        {"xori",  14},
        {"lui",   15},
        {"slti",  10},
        {"sltiu", 11},
        {"beq",    4},
        {"bne",    5},
        {"bgez",   1},
        {"bgezal", 1},
        {"bgtz",   7},
        {"blez",   6},
        {"bltz",   1},
        {"bltzal", 1},
};


sh_type sh_instructions[] = {
        {"sra",  3},
        {"srl",  2},
        {"srlv", 6},
        {"sll",  0},
        {"sllv", 4}
};

j_type j_instructions[] = {
        {"j",    2},
        {"jal",  3},
        {"jalr", 9},
        {"jr",   8},
};

r_type r_instructions[] = {
        {"add",     32},
        {"addu",    33},
        {"and",     36},
        {"div",     26},
        {"or",      37},
        {"sub",     34},
        {"subu",    35},
        {"xor",     38},
        {"nor",     39},
        {"slt",     42},
        {"sltu",    43},
        {"syscall", 12},
};

d_type d_instructions[] = {
        {"lw",  35},
        {"sw",  43},
        {"lb",  32},
        {"sb",  40},
        {"lbu", 36},
        {"lh",  33},
        {"sh",  41}
};

p_type p_instructions[] = {
        {"move",  1},
        {"clear", 1},
        {"li",    2},
        {"la",    2},
        {"not",   1},
        {"nop",   1}
};

size_t p_num  = sizeof(p_instructions) / sizeof(p_type);
size_t d_num  = sizeof(d_instructions) / sizeof(r_type);
size_t r_num  = sizeof(r_instructions) / sizeof(r_type);
size_t i_num  = sizeof(i_instructions) / sizeof(i_type);
size_t sh_num = sizeof(sh_instructions) / sizeof(sh_type);
size_t j_num  = sizeof(j_instructions) / sizeof(j_type);

bool is_i(const char *mnemonic) {
    for(uint8_t i = 0; i < i_num; i++) {
        if(strcmp(mnemonic, i_instructions[i].name) == 0) {
            return true;
        }
    }
    return false;
}

bool is_j(const char *mnemonic) {
    for(uint8_t i = 0; i < j_num; i++) {
        if(strcmp(mnemonic, j_instructions[i].name) == 0) {
            return true;
        }
    }
    return false;
}

bool is_r(const char *mnemonic) {
    for(uint8_t i = 0; i < r_num; i++) {
        if(strcmp(mnemonic, r_instructions[i].name) == 0) {
            return true;
        }
    }
    return false;
}

bool is_sh(const char *mnemonic) {
    for(uint8_t i = 0; i < sh_num; i++) {
        if(strcmp(mnemonic, sh_instructions[i].name) == 0) {
            return true;
        }
    }
    return false;
}

bool is_d(const char *mnemonic) {
    for(uint8_t i = 0; i < d_num; i++) {
        if(strcmp(mnemonic, d_instructions[i].name) == 0) {
            return true;
        }
    }
    return false;
}

bool is_p(const char *mnemonic) {
    for(uint8_t i = 0; i < p_num; i++) {
        if(strcmp(mnemonic, p_instructions[i].name) == 0) {
            return true;
        }
    }
    return false;
}

int code(const char *mnemonic) {
    for(uint8_t i = 0; i < sh_num; i++) {
        if(strcmp(mnemonic, sh_instructions[i].name) == 0) {
            return sh_instructions[i].funct;
        }
    }

    for(uint8_t i = 0; i < r_num; i++) {
        if(strcmp(mnemonic, r_instructions[i].name) == 0) {
            return r_instructions[i].funct;
        }
    }
    for(uint8_t i = 0; i < j_num; i++) {
        if(strcmp(mnemonic, j_instructions[i].name) == 0) {
            return j_instructions[i].opcode;
        }
    }

    for(uint8_t i = 0; i < i_num; i++) {
        if(strcmp(mnemonic, i_instructions[i].name) == 0) {
            return i_instructions[i].opcode;
        }
    }

    for(uint8_t i = 0; i < d_num; i++) {
        if(strcmp(mnemonic, d_instructions[i].name) == 0) {
            return d_instructions[i].opcode;
        }
    }
    return -1;
}

const char *regs[] = {
        "$zero", "$at", "$v0", "$v1", "$a0", "$a1", "$a2", "$a3",
        "$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7",
        "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7",
        "$t8", "$t9", "$k0", "$k1", "$gp", "$sp", "$fp", "$ra"
};

int reg_num(const char *name) {
    for(int i = 0; i < 32; i++) {
        if(strcmp(name, regs[i]) == 0) {
            return i;
        }
    }
    return -1;
}


int spec_resolve(const char *mnemonic) {
    if(strcmp(mnemonic, "bgtz") == 0 || strcmp(mnemonic, "blez") == 0 || strcmp(mnemonic, "bltz") == 0) {
        return 0;
    } else if(strcmp(mnemonic, "bgez") == 0) {
        return 1;
    } else if(strcmp(mnemonic, "bgezal") == 0) {
        return 0b10001;
    } else {
        return 0b10000;
    }
}


uint32_t get_masked_value(uint32_t inst, uint32_t mask) {
    return inst & mask;
}

uint8_t get_rs(uint32_t inst) {
    return (uint8_t)(get_masked_value(inst, (uint32_t)(SREGMASK)) >> 21U);
}

uint8_t get_rt(uint32_t inst) {
    return (uint8_t)(get_masked_value(inst, (uint32_t)(TREGMASK)) >> 16U);
}

uint8_t get_rd(uint32_t inst) {
    int x = get_masked_value(inst, (uint32_t)(DREGMASK));
    return (uint8_t)(x >> 11U);
}

uint8_t get_op(uint32_t inst) {
    return (uint8_t)(get_masked_value(inst, (uint32_t)(OPCODEMASK)) >> 26U);
}

uint8_t get_shamt(uint32_t inst) {
    return (uint8_t)(get_masked_value(inst, (uint32_t)(SHAMTMASK)) >> 6U);
}

uint8_t get_funct(uint32_t inst) {
    return (uint8_t)(get_masked_value(inst, (uint32_t)(FUNCTMASK)));
}

uint32_t get_j_addr(uint32_t inst) {
    return (uint32_t)(get_masked_value(inst, (uint32_t)(ADDRMASK)));
}

int16_t get_imm(uint32_t inst) {
    return (int16_t)(get_masked_value(inst, (uint32_t)(IMMMASK)));
}



const char *get_mnemonic(uint32_t inst) {
    uint8_t op = get_op(inst);
    uint8_t funct = get_funct(inst);

    if (op == 0) {
        return get_mnemonic_funct(funct);
    } else {
        return get_mnemonic_op(op);
    }
}

const char *get_mnemonic_funct(uint8_t funct) {
    for(int i = 0; i < r_num; i++) {
        if(r_instructions[i].funct == funct) {
            return r_instructions[i].name;
        }
    }
    for(int i = 0; i < sh_num; i++) {
        if(sh_instructions[i].funct == funct) {
            return sh_instructions[i].name;
        }
    }
    return NULL;
}

const char *get_mnemonic_op(uint8_t op) {
    for(int i = 0; i < i_num; i++) {
        if(i_instructions[i].opcode == op) {
            return i_instructions[i].name;
        }
    }
    for(int i = 0; i < d_num; i++) {
        if(d_instructions[i].opcode == op) {
            return d_instructions[i].name;
        }
    }
    for(int i = 0; i < j_num; i++) {
        if(j_instructions[i].opcode == op) {
            return j_instructions[i].name;
        }
    }

    return NULL;
}

bool is_nop(uint32_t inst) {
    return inst == 0x00000000;
}
