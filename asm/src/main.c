#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "file_handling.h"

int main(int argc, char **argv) {
    if(argc < 2) {
        printf("Specify the file name as an argument.");
        return EXIT_FAILURE;
    }
    if(argc < 3) {
        printf("Specify the name of the output file.");
        return EXIT_FAILURE;
    }
    if(argc == 4 && strcmp(argv[3], "-O") != 0) {
        printf("Invalid option {%s}.\n", argv[3]);
        return EXIT_FAILURE;
    }
    if(argc == 4 && strcmp(argv[3], "-O") == 0) {
        printf("Specify the name of the interlock-free output file.");
        return EXIT_FAILURE;
    }
    char **content = NULL;
    content = init_mem(MEMORYLENGTH, LINELENGTH);
    if(content == NULL) {
        printf("Could not initialize memory.\n");
        return EXIT_FAILURE;
    }
    uint16_t num_lines = 0;
    if (!read_file(argv[1], content, &num_lines)) {
        printf("Invalid file name.\n");
        return EXIT_FAILURE;
    }

    first_pass(content, symbol_table);
    size_t instr_num = effective_instructions(content, get_size(content));
    char **stripped =  trim(content, get_size(content));
    uint32_t *mem = calloc(MEMORYLENGTH, sizeof(uint32_t));
    second_pass(stripped, instr_num, symbol_table, mem);

    uint32_t *imem = resolve_dep(mem, instr_num); // interlocking.
    print_mem(argv[2], mem, instr_num);
    print_mem(argv[4], imem, get_memory_size(imem));
    free(mem); free_mem((void **) stripped, instr_num);
    free(imem);
    return 0;
}
