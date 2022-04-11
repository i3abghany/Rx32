#ifndef MIPS_ASSEMBLER_INTERLOCK_H
#define MIPS_ASSEMBLER_INTERLOCK_H
#include "classify.h"
#include "mem_handling.h"
#include <stdlib.h>
#include "defs.h"


uint32_t *resolve_dep(uint32_t *mem, size_t size);
bool is_RAW_hazard(uint8_t rs, uint8_t rt, uint8_t rd);
void insert_nop(uint32_t *mem, size_t idx);
uint32_t *resolve_control_hazards(const uint32_t *mem, size_t size);
uint32_t *resolve_data_hazards(const uint32_t *mem, size_t size);
bool data_hazardous_inst(const char *mnemonic);
bool control_hazardous_inst(const char *mnemonic);
bool RAW_resolve_i(uint32_t, uint32_t);
bool RAW_resolve_r(uint32_t, uint32_t);
bool RAW_resolve_d(uint32_t, uint32_t);

#endif //MIPS_ASSEMBLER_INTERLOCK_H
