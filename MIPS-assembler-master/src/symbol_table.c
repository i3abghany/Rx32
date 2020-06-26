#include "symbol_table.h"

uint16_t sym_num = 0;

void add_symbol(const char *sym_name, uint32_t addr, uint32_t words) {
    symbol c;
    strcpy(c.name, sym_name);
    c.address = addr;
    c.num_words = words;
    symbol_table[sym_num++] = c;
}

void print_table() {
    for(int i = 0; i < sym_num; i++) {
        printf("%s 0x%.8x 0x%x\n", symbol_table[i].name, symbol_table[i].address, symbol_table[i].num_words);
    }
}

bool sym_exist(const char *name) {
    for(int i = 0; i < sym_num; i++) {
        if(strcmp(name, symbol_table[i].name) == 0) {
            return true;
        }
    }
    return false;
}

int get_address(const char *symb) {
    for(int i = 0; i < sym_num; i++) {
        if(strcmp(symb, symbol_table[i].name) == 0) {
            return symbol_table[i].address;
        }
    }
    return -1;
}

