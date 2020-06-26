#include "file_handling.h"
#include "classify.h"

int read_line(FILE* handle, char *buffer, size_t i) {
    char ch;
    bool leading_space = true;
    while ((ch = (char) fgetc(handle)) != '\n' && i < LINELENGTH && ch != EOF) {
        if (ch == '#') {
            while (fgetc(handle) != '\n');
            break;
        }
        if (leading_space && isspace(ch)) {
            continue;
        } else if (leading_space && !isspace(ch)) {
            leading_space = false;
        }
        buffer[i++] = ch;
    }
    buffer[i] = '\0';
    size_t z;
    for (z = strlen(buffer) - 1; buffer[z] == ' '; z--);
    buffer[z + 1] = '\0';
    if (buffer[z] == ':') {
        z = read_line(handle, buffer, z + 1);
    }
    return z;
}

int indexof(const char *line, char c) {
    for(int i = 0; line[i] != '\0'; i++) {
        if(line[i] == c) return i;
    }
    return -1;
}

bool read_file(const char* file_name, char **file_content, uint16_t *num_inst) {
    FILE *fp;
    fp = fopen(file_name, "r");
    if(fp == NULL) {
        return false;
    }
    for(int i = 0; i < MEMORYLENGTH; ) {
        if(feof(fp)) break;
        read_line(fp, file_content[i], 0);
        if(file_content[i][0] == '\0') continue;  // empty line.
        i++;
        (*num_inst)++;
    }
    strcpy(file_content[*num_inst], "ENDOFPROGRAM");
    fclose(fp);
    return true;
}

void print_content(char **content, size_t num) {
    for(size_t i = 0; i < num; i++) {
        printf("%s\n", content[i]);
    }
}

void print_mem(const char *file_name, uint32_t *mem, size_t num) {
    FILE *fp = fopen(file_name, "w");
    for(size_t i = 0; i < num; i++) {
        fprintf(fp, "0x%.8x\n", mem[i]);
    }
}

void substr(char *src, size_t start, size_t end, char *dst) {
    strncpy(dst, src + start, end - start + 1);
    dst[end - start + 1] = '\0';
}

void first_pass(char **content, symbol *table) {
    char token[64];
    for(size_t i = 0; strcmp(content[i], "ENDOFPROGRAM") != 0; i++) {
        substr(content[i], 0, 4, token);
        if(strcmp(token, ".data") == 0) {
            resolve_data_segment(content, i + 1);
        }
    }

    for(size_t i = 0; strcmp(content[i], "ENDOFPROGRAM") != 0; i++) {
        char *tmp;
        for (size_t j = 0; j < p_num; j++) {
            tmp = concat(2, p_instructions[j].name, " ");
            if (strstr(content[i], tmp) != NULL || strcmp(content[i], "nop") == 0 ) {
               substitute_psuedo(content, j, i);
                break;
            }
        }
    }
    for(size_t i = 0; strcmp(content[i], "ENDOFPROGRAM") != 0; i++) {
        substr(content[i], 0, 4, token);
        if(strcmp(token, ".text") == 0) {
            resolve_text_segment(content, i + 1);
        }
    }

    curr_pc = PC;
}

size_t curr_pc = PC;

bool segment_end(const char *line) {
    return strcmp(line, "ENDOFPROGRAM") == 0 || strcmp(line, ".text") == 0 || strcmp(line, ".data") == 0;
}

void resolve_text_segment(char **content, size_t start) {
    char token[64];
    for (size_t i = start; !segment_end(content[i]); i++) {
        if(content[i][0] == '.') continue;
        curr_pc += 4;
        char *instr = content[i];
        int idx = indexof(instr, ':');
        if(idx == -1) continue;
        memcpy(token, instr, idx);
        token[idx] = '\0';
        add_symbol(token, curr_pc - 4, 1);
    }
}

void shift_downwards(char **content, size_t idx) {
    char buffer[LINELENGTH];
    strcpy(buffer, content[idx]);
    size_t i;
    for(i = idx + 1; ; i++) {
        if(strcmp(content[i], "ENDOFPROGRAM") == 0) break;
        swap_lines(buffer, content[i]);
    }
    strcpy(content[i], buffer);
    strcpy(content[i + 1], "ENDOFPROGRAM");
}

void insert_line(char **content, char *line, size_t idx) {
    shift_downwards(content, idx);
    strcpy(content[idx + 1], line);
}

void swap_lines(char *str1, char *str2) {
    char buffer[LINELENGTH];
    strcpy(buffer,str1);
    strcpy(str1, str2);
    strcpy(str2, buffer);
}


char *get_half(char *num, char *inst, int which) {
    int rad = get_radix(num);
    if(rad == -1) {
        printf("Error at: %s\n", inst);
        exit(EXIT_FAILURE);
    }
    if(rad != 10) num = num + 2;
    int offset = strtol(num, NULL, rad);
    char *hi, *lo;
    if(which == 1) {
        hi = malloc(16);
        sprintf(hi, "%d", (offset & 0xFFFF0000) >> 16);
        return hi;
    }
    if(which == 0) {
        lo = malloc(16);
        sprintf(lo, "%d", offset & 0x0000FFFF);
        return lo;
    }
    return NULL;
}

void decode_psuedo(char *mem, char *line1, char *line2) {
    char **tokens = init_mem(4, LINELENGTH);
    char *token = malloc(LINELENGTH * sizeof(char));
    char *inst = strdup(mem);
    token = strtok(inst, " \t:,");
    strcpy(tokens[0], token);
    size_t z = 0;
    while (token) {
        strcpy(tokens[z++], token);
        token = strtok(NULL, ": ,\t");
    }
    char *inst1 = NULL, *inst2 = NULL;
    if(strcmp(tokens[0], "move") == 0) {
        strcpy(line1, concat(5, "or ", tokens[1], ", ", tokens[2], ", $zero"));
    } else if(strcmp(tokens[0], "clear") == 0) {
        line1 = concat(3, "or", tokens[1], ", $zero, $zero");
    } else if(strcmp(tokens[0], "li") == 0) {
        char *lo = get_half(tokens[2], mem, 0);
        char *hi = get_half(tokens[2], mem, 1);
        inst1 = concat(4, "lui, ", tokens[1], ", ", hi);
        inst2 = concat(6, "ori ", tokens[1], ", ", tokens[1], ", ", lo);
        strcpy(line1, inst1);
        strcpy(line2, inst2);
        free(lo), free(hi);
    } else if(strcmp(tokens[0], "la") == 0) {
        int addr = get_address(tokens[2]);
        if(addr == -1) {
            printf("Error at instruction: %s", mem);
            exit(EXIT_FAILURE);
        }
        char lo[64], hi[64];
        sprintf(lo, "%d", addr & 0x0000FFFF);
        sprintf(hi, "%d", addr & 0xFFFF0000);
        inst1 = concat(4, "lui ", tokens[1], ", ", hi);
        inst2 = concat(6, "ori ", tokens[1], ", ", tokens[1], ", ", lo);
        strcpy(line1, inst1);
        strcpy(line2, inst2);
    } else if(strcmp(tokens[0], "not") == 0) {
        inst1 = concat(4, "nor ", tokens[1], ", ", tokens[2], ", $zero");
        strcpy(line1, inst1);
    } else if(strcmp(tokens[0], "nop") == 0) {
        strcpy(line1, concat(1, "sll $zero, $zero, 0"));
    }
    free(inst1), free(inst2), free(inst), free(token);
    free_mem((void **)(tokens), 4);
}

void prepend(char *s, const char *t) {
    size_t len = strlen(t);
    memmove(s + len, s, strlen(s) + 1);
    memcpy(s, t, len);
}

void substitute_psuedo(char **content, int p_idx, int arr_idx) {
    char mnemonic[64], label[64];
    bool new_line = false;
    char *l1 = malloc(64), *l2 = malloc(64);

    strcpy(mnemonic, p_instructions[p_idx].name);
    new_line = (p_instructions[p_idx].num == 2);

    int colon = indexof(content[arr_idx], ':');
    bool is_labeled = colon != -1;
    if (is_labeled) {
        memcpy(label, content[arr_idx], colon + 1);
        label[colon + 1] = '\0';
        decode_psuedo((content[arr_idx] + colon + 1), l1, l2);
        prepend(l1, label);
    } else {
        label[0] = '\0';
        decode_psuedo(content[arr_idx], l1, l2);
    }
    if(!new_line) {
        strcpy(content[arr_idx], l1);
    } else {
        strcpy(content[arr_idx], l1);
        insert_line(content, l2, arr_idx);
    }

    free(l1), free(l2);
}

// TODO: support arrays and get the data of the symbols.
void resolve_data_segment(char **content, size_t start) {
    char *token;
    char **tokens = (char **) malloc(3 * sizeof(char *));
    for (int k = 0; k < 3; k++) {
        tokens[k] = (char *) malloc(LINELENGTH * sizeof(char));
    }
    for (int i = start; !segment_end(content[i]); i++) {

        token = strtok(content[i], " :\t");
        strcpy(tokens[0], token);
        if (sym_exist(tokens[0])) {
            printf("Error at data segment: Redefinition of %s", tokens[0]);
            exit(EXIT_FAILURE);
        }
        token = strtok(NULL, " :\t");
        strcpy(tokens[1], token);

        token = strtok(NULL, "\0");
        strcpy(tokens[2], token);

        uint32_t memory_address;
        size_t words_required = 1;
        if (strcmp(tokens[1], ".asciiz") == 0 ||
            strcmp(tokens[1], ".ascii") == 0) {   // every char takes one byte. (4 letters take one word.)
            tokens[2][strlen(tokens[2]) - 1] = '\0';
            tokens[2]++;
            words_required = ceil(1.0 * (double) strlen(tokens[2]) / 4.0);
            if (strlen(tokens[2]) % 4 == 0 && strcmp(tokens[1], ".asciiz") == 0) words_required++;
            tokens[2]--; // restore the pointer in order to deallocate it correctly.
        } else if (strcmp(tokens[1], ".word") == 0) {
            words_required = 1;
            // get the data into the symbol.
        } else if (strcmp(tokens[1], ".byte") == 0) {
            words_required = 1;
            // get the data into the symbol
        } else if (strcmp(tokens[1], ".space") == 0) {
            size_t bytes = atoi(tokens[2]);
            words_required = bytes / 4;
            if (bytes % 4 != 0) words_required++;
            // get the data into the symbol.
        } else if (strcmp(tokens[1], ".float") == 0) {
            words_required = 1;
            // get the data into the symbol.
        } else if (strcmp(tokens[1], ".double") == 0) {
            words_required = 2;
            // get the data into the symbol.
        } else {
            printf("Error at data segment: %s", content[i]);
            exit(EXIT_FAILURE);
        }

        if (sym_num == 0) {
            memory_address = GP;
        } else {
            memory_address = symbol_table[sym_num - 1].address + (symbol_table[sym_num - 1].num_words * 4);
        }
        add_symbol(tokens[0], memory_address, words_required);
        content[i][0] = '.'; // mark as a "DONE" line, second pass does not process "DONE" lines.
    }
    free_mem((void **) tokens, 3);
}

size_t effective_instructions(char **content, size_t line_num) {
    size_t instr_num = 0;
    for (size_t i = 0; i < line_num; i++) {
        if(content[i][0] != '.') instr_num++;
    }
    return instr_num;
}

const char *first_not_empty(const char *line) {
    for(int i = 0; line[i] != '\0'; i++) {
        if(line[i] != ' ') return &line[i];
    }
    return line;
}

char **trim(char **content, size_t line_num) {
    size_t instr_num = effective_instructions(content, line_num);
    char **stripped = init_mem(instr_num + 1, LINELENGTH);
    size_t curr_inst = 0, cursor;
    for(cursor = 0; cursor < line_num; cursor++) {
        if(content[cursor][0] == '.') {
            continue;
        }
        int colon_index = indexof(content[cursor], ':');
        bool is_labeled = colon_index != -1;
        if(is_labeled) {
            const char *effective_inst = first_not_empty(content[cursor] + colon_index + 1);
            strcpy(stripped[curr_inst], effective_inst);
        } else {
            strcpy(stripped[curr_inst], content[cursor]);
        }
        curr_inst++;
    }
    strcpy(stripped[curr_inst], "ENDOFPROGRAM");
    free_mem((void **)content, MEMORYLENGTH);
    return stripped;
}

int get_radix(const char *imm) {
    int res = -1;
    return strlen(imm) == 1 ? 10 : (!isalpha(imm[1]) ? 10 : (imm[1] == 'x' ? 16 : (imm[1] == 'b' ? 2 : -1)));
}

void second_pass(char **content, size_t num_instr, symbol *table, uint32_t *mem) {
    // the longest instruction line is in the form of:
    // OP TOK1, TOK2, TOK3
    char **tokens = init_mem(4, 64);
    char *token;
    for (size_t i = 0; i < num_instr; i++) {
        char *instr = strdup(content[i]);
        token = strtok(instr, ": ,\t");
        size_t z = 0;
        while (token) {
            strcpy(tokens[z++], token);
            token = strtok(NULL, ": ,\t");
        }
        if (is_r(tokens[0])) {
            uint32_t funct = code(tokens[0]);
	    if(funct == 12) {
		mem[i] = 0x0000000c;
		continue;
	    }
            int rd = reg_num(tokens[1]);
            int rs = reg_num(tokens[2]);
            int rt = reg_num(tokens[3]);
            if (rd == -1 || rs == -1 || rt == -1) {
                printf("Error in instruction: %s\n", content[i]);
                exit(EXIT_FAILURE);
            }
            mem[i] |= funct;
            mem[i] |= (rd << 11);
            mem[i] |= (rt << 16);
            mem[i] |= (rs << 21);
        } else if (is_i(tokens[0])) {
            uint32_t op = code(tokens[0]);
            uint32_t spec = spec_resolve(tokens[0]);
            if (op == 1 || op == 6 || op == 7) {
                int rs = reg_num(tokens[1]);
                uint32_t branch_addr = get_address(tokens[3]);
                if (branch_addr == -1) {
                    printf("Error: invalid label at %s", content[i]);
                    exit(EXIT_FAILURE);
                }
                uint16_t offset = (branch_addr - (curr_pc + 4)) / 4;
                mem[i] |= (offset);
                mem[i] |= (spec << 16);
                mem[i] |= (rs << 21);
                mem[i] |= (op << 26);
            } else {
                int rt = reg_num(tokens[1]);
                int rs = reg_num(tokens[2]);
                int radix = get_radix(tokens[3]);
                if(op == 15) {
                    rs = -2;
                    radix = get_radix(tokens[2]);
                }
                if (rs == -1 || rt == -1) {
                    printf("Error in instruction: %s\n", content[i]);
                    exit(EXIT_FAILURE);
                }
                uint16_t offset;
                if (op == 4 || op == 5) {
                    uint32_t branch_addr = get_address(tokens[3]);
                    if (branch_addr == -1) {
                        printf("Error: invalid label at %s", content[i]);
                        exit(EXIT_FAILURE);
                    }
                    int tmp;
                    tmp = rt;
                    rt = rs;
                    rs = tmp;
                    offset = (branch_addr - (curr_pc + 4)) / 4;
                }
                if (!(op == 4 || op == 5) && radix == -1) {
                    printf("Error: Invalid immediate. %s\n", content[i]);
                    exit(EXIT_FAILURE);
                }

                uint16_t imm;
                if (op == 15) {
                    imm = strtol(tokens[2], NULL, radix);
                } else {
                    imm = strtol(tokens[3], NULL, radix);
                }
                rt &= (0x0000001F);
                rs &= (0x0000001F);
                op &= (0x0000003F);
                mem[i] |= (op == 4 || op == 5) ? (offset) : (imm);
                mem[i] |= (rt << 16);
                mem[i] |= (rs << 21);
                mem[i] |= (op << 26);
            }
        } else if (is_j(tokens[0])) {
            uint32_t op = code(tokens[0]);
            if (op == 2 || op == 3) {  // j, jal.
                mem[i] |= (op << 26);
                int addr = get_address(tokens[1]);
                if (addr == -1) {
                    printf("Error at instruction: %s\n", content[i]);
                    exit(EXIT_FAILURE);
                }
                mem[i] |= (addr / 4);
            } else if (op == 8) {  // jr, jalr
                mem[i] |= op;
                int rs = reg_num(tokens[1]);
                if (rs == -1) {
                    printf("Error at instruction: %s\n", content[i]);
                    exit(EXIT_FAILURE);
                }
                mem[i] |= (rs << 21);
            } else if(op == 9) {
                mem[i] |= op;
                int rs = reg_num(tokens[1]);
                int rd = reg_num(tokens[2]);
                if(rs == -1 || rd == -1) {
                    printf("Error at instruction: %s\n", content[i]);
                    exit(EXIT_FAILURE);
                }
                mem[i] |= (rs << 21);
                mem[i] |= (rd << 11);
            }
        } else if (is_sh(tokens[0])) {
            uint32_t op = code(tokens[0]);
            if (op == 0 || op == 3 || op == 2) {  // SLL, SRA, SRL
                uint32_t rd = reg_num(tokens[1]);
                uint32_t rt = reg_num(tokens[2]);
                int radix = get_radix(tokens[3]);
                if (radix == -1) {
                    printf("Error: Invalid immediate. %s\n", content[i]);
                    exit(EXIT_FAILURE);
                }
                int h = strtol(tokens[3], NULL, radix);
                if (h > 32 || h < 0) {
                    printf("Error: invalid shift amount at: %s\n", content[i]);
                    exit(EXIT_FAILURE);
                }
                mem[i] |= op;
                mem[i] |= (h << 6);
                mem[i] |= (rd << 11);
                mem[i] |= (rt << 16);
            } else if (op == 4 || op == 6) {  // SLLV, SRLV
                uint32_t rd = reg_num(tokens[1]);
                uint32_t rt = reg_num(tokens[2]);
                uint32_t rs = reg_num(tokens[3]);
                if (rd == -1 || rs == -1 || rt == -1) {
                    printf("Error in instruction: %s\n", content[i]);
                    exit(EXIT_FAILURE);
                }
                mem[i] |= op;
                mem[i] |= (rd << 11);
                mem[i] |= (rt << 16);
                mem[i] |= (rs << 21);
            }
        } else if (is_d(tokens[0])) {
            uint32_t op = code(tokens[0]);
            int open_paren = indexof(tokens[2], '(');
            int close_paren = indexof(tokens[2], ')');
            if(open_paren == -1 || close_paren == -1) {
                printf("Error in instruction: %s\n", content[i]);
                exit(EXIT_FAILURE);
            }
            int rt = reg_num(tokens[1]);
            char rg2[32], off[32];
            substr(tokens[2], open_paren + 1, close_paren - 1, rg2);
            substr(tokens[2], 0, open_paren - 1, off);
            uint16_t offset = strtol(off, NULL, 10);
            int rs = reg_num(rg2);
            if(rt == -1 || rs == -1 || (offset == 0 && errno == EINVAL)) {
                printf("Error in instruction: %s\n", content[i]);
                exit(EXIT_FAILURE);
            }
            mem[i] |= (offset);
            mem[i] |= (rt << 16);
            mem[i] |= (rs << 21);
            mem[i] |= (op << 26);

        } else {
            printf("Unknown instruction. \"%s\"", tokens[0]);
            exit(EXIT_FAILURE);
        }
        free(instr);
        curr_pc += 4;
    }
    mem[(curr_pc - PC) / 4] = 0xFFFFFFFF;
    free_mem((void **) tokens, 4);
}
