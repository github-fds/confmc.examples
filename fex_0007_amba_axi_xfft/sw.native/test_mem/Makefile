SHELL=/bin/sh

TARGET?=test

SRC     =\
        main.c\
        arg_parser.c\
        trx_axi_api.c\
        mem_api.c\
        test_bench.c

all: pre $(TARGET)

run:
	./$(TARGET) -c 0 -m 0x10000000:0x100 -l 3 -v 3

include ../Makefile.in
