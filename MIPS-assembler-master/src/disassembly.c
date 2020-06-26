#include "disassembly.h"


char* concat(size_t num, ...) {
    va_list ap;
    size_t len = 1;
    va_start(ap, num);
    for(size_t i = 0; i < num; i++) {
        len += strlen(va_arg(ap, char *));
    }
    va_end(ap);

    char *result = calloc(len, sizeof(char));
    int null_pos = 0;

    va_start(ap, num);
    for(size_t i = 0; i < num; i++) {
        char *z = va_arg(ap, char *);
        strcpy(result + null_pos, z);
        null_pos += strlen(z);
    }
    va_end(ap);
    return result;
}

char *disassemble_inst(uint32_t inst) {
    const char *mnemonic = get_mnemonic(inst);
    if (strcmp(mnemonic, "j") == 0 || strcmp(mnemonic, "jal") == 0)
        return disassemble_j_al(get_j_addr(inst), mnemonic);
    else if (strcmp(mnemonic, "jalr") == 0) return disassemble_jalr(get_rs(inst), get_rd(inst));
    else if (strcmp(mnemonic, "jr") == 0) return disassemble_jr(get_rs(inst));
    else if (is_r(mnemonic)) return disassemble_r(mnemonic, get_rs(inst), get_rt(inst), get_rd(inst));
    if (strcmp(mnemonic, "sllv") == 0 || strcmp(mnemonic, "srlv") == 0)
        return disassemble_shv(mnemonic, get_rs(inst), get_rt(inst), get_rd(inst));
    else if (is_sh(mnemonic)) return disassemble_sh(mnemonic, get_shamt(inst), get_rt(inst), get_rd(inst));
    else if (is_i(mnemonic)) return disassemble_i(mnemonic, get_rt(inst), get_rs(inst), get_imm(inst));
    else if (is_d(mnemonic)) return disassemble_d(mnemonic, get_rt(inst), get_rs(inst), get_imm(inst));
    return NULL;
}

char *disassemble_j_al(int addr, const char *m) {
    char addr_s[32]; itoa(addr * 4, addr_s, 16);
    return concat(3, m, " ", addr_s);
}

char *disassemble_jalr(uint8_t rs, uint8_t rd) {
    return concat(4, "jalr ", regs[rs], ", ", regs[rd]);
}

char *disassemble_jr(uint8_t rs) {
    return concat(2, "jr ", regs[rs]);
}

char *disassemble_d(const char *m, uint8_t rt, uint8_t rs, int16_t imm) {
    char arr[32]; itoa(imm, arr, 10);
    return concat(8, m, " ", regs[rt], ", ", arr, "(", regs[rs], ")");
}

char *disassemble_i(const char *m, uint8_t rt, uint8_t rs, int16_t imm) {
    char ddd [32]; itoa(imm, ddd, 10);
    return concat(7, m, " ", regs[rt], ", ", regs[rs], ", ", ddd);
}

char *disassemble_sh(const char *m, uint8_t shamt, uint8_t rt, uint8_t rd) {
    char shamt_s[32]; itoa(shamt, shamt_s, 10);
    return concat(4, m, " ", regs[rd], ", ", regs[rt], ", ", shamt);
}

char *disassemble_shv(const char *m, uint8_t rs, uint8_t rt, uint8_t rd) {
    return concat(4, m, " ", regs[rd], ", ", regs[rt], ", ", regs[rs]);
}

char *disassemble_r(const char *m, uint8_t rs, uint8_t rt, uint8_t rd) {
    return concat(7, m, " ", regs[rd], ", ", regs[rs], ", ", regs[rt]);
}


