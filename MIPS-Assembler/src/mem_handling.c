#include "mem_handling.h"

char **init_mem(size_t len, size_t width) {
    char **p = malloc(len * sizeof(char*));
    if(p == NULL) return NULL;
    for (size_t i = 0; i < len; i++) {
        p[i] = malloc(width * sizeof(char));
        if(p[i] == NULL) return NULL;
    }
    return p;
}

void free_mem(void **p, size_t num) {
    for(size_t i = 0; i < num; i++) {
        free(p[i]);
    }
    free(p);
}

size_t get_size(char **content) {
    int r = 0;
    for(int i = 0; strcmp(content[i], "ENDOFPROGRAM") != 0; i++)
        r++;

    return r;
}

size_t get_memory_size(const uint32_t *mem) {
    int r = 0;
    for(int i = 0; mem[i] != 0xFFFFFFFF; i++)
        r++;

    return r;
}

