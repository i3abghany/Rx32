#include "interlock.h"

bool is_RAW_hazard(uint8_t rs, uint8_t rt, uint8_t rd) {
    return (rs != 0 && (rd == rs)) || (rt != 0 && (rd == rt));
}

void insert_nop(uint32_t *mem, size_t idx) {
    mem[idx] = 0x00000000;
}

uint32_t *resolve_dep(uint32_t *mem, size_t size) {
    uint32_t *imem = resolve_control_hazards(mem, size);
    size_t s = get_memory_size(mem);
    uint32_t *imem2 = resolve_data_hazards(imem, s);
    free(imem);
    return imem2;
}

uint32_t *resolve_control_hazards(const uint32_t *mem, size_t size) {
    uint32_t inst;
    uint32_t *imem = calloc(2 * size + 1, sizeof(uint32_t)); // interlock-free instructions.
    int j = 0;
    for (int i = 0; i < size; i++) {
        inst = mem[i];
        const char *mnemonic = get_mnemonic(inst);
        imem[j] = inst;
        if (control_hazardous_inst(mnemonic)) {
            insert_nop(imem, j + 1);
            j++;
        }
        j++;
    }
    imem[j] = 0xFFFFFFFF; // mark the end of the array.
    return imem;
}

uint32_t *resolve_data_hazards(const uint32_t *mem, size_t size) {
    uint32_t inst;
    uint32_t *imem = calloc(3 * size + 3, sizeof(*imem));
    int j = 0;
    for (int i = 0; i < size; i++) {
        inst = mem[i];
        imem[j] = inst;
        const char *m = get_mnemonic(inst);
        if(is_nop(inst)) continue;
        if (data_hazardous_inst(m) && !is_i(m) && !is_d(m)) {
            uint32_t inst1 = mem[i + 1], inst2 = mem[i + 2];
            if (inst1 == 0xFFFFFFFF) break;

            if (RAW_resolve_r(inst, inst1)) {
                insert_nop(imem, j + 1);
                insert_nop(imem, j + 1);
                j += 2;
            } else if (RAW_resolve_r(inst, inst2)) {
                insert_nop(imem, j + 1);
                j += 1;
            }
        } else if (data_hazardous_inst(m) && (is_i(m) || is_d(m))) {
            uint32_t inst1 = mem[i + 1], inst2 = mem[i + 2];
            if (inst1 == 0xFFFFFFFF) break;

            if (RAW_resolve_i(inst, inst1)) {
                insert_nop(imem, j + 1);
                insert_nop(imem, j + 1);
                j += 2;
            } else if (RAW_resolve_i(inst, inst2)) {
                insert_nop(imem, j + 1);
                j += 1;
            }
        }
        j++;
    }
    imem[j + 1] = 0xFFFFFFFF;
    return imem;
}

bool data_hazardous_inst(const char *mnemonic) {
    return (is_i(mnemonic) && mnemonic[0] != 'b')||
           is_sh(mnemonic) ||
           (is_r(mnemonic) && strcmp(mnemonic, "syscall") != 0) ||
           (is_j(mnemonic) && (strcmp(mnemonic, "jr") == 0 || strcmp(mnemonic, "jalr") == 0)) ||
           is_d(mnemonic);
}

bool control_hazardous_inst(const char *mnemonic) {
    return  is_j(mnemonic) && (strcmp(mnemonic, "j") == 0 || strcmp(mnemonic, "jal") == 0) ||
            (is_i(mnemonic) && mnemonic[0] == 'b');
}

bool RAW_resolve_r(uint32_t a, uint32_t b) {
    uint8_t rd = get_rd(a);
    uint8_t rs = get_rs(b);
    uint8_t rt = get_rt(b);
    return is_RAW_hazard(rs, rt, rd);
}

bool RAW_resolve_i(uint32_t a, uint32_t b) {
    uint8_t rti = get_rt(a);
    uint8_t rs = get_rs(b);
    uint8_t rt = get_rt(b);
    return is_RAW_hazard(rs, rt, rti);
}

