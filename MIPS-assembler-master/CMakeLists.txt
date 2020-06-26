cmake_minimum_required(VERSION 3.16)
project(MIPS_Assembler C)

set(CMAKE_C_STANDARD 11)

add_executable(MIPS_Assembler src/main.c src/file_handling.c src/file_handling.h src/defs.h src/mem_handling.c src/mem_handling.h src/classify.c src/classify.h src/symbol_table.c src/symbol_table.h src/disassembly.c src/disassembly.h src/interlock.c src/interlock.h)