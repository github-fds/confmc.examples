SHELL=/bin/sh

TARGET?=test

SRC     =\
        main.c\
        arg_parser.c\
        trx_ahb_api.c\
        mem_api.c\
        test_bench.c

all: pre $(TARGET)

run:
#	./$(TARGET) -c 0 -m 0:0x2000 -l 7 -v 3
#	./$(TARGET) -c 0 -m 0:0x2000 -l 7 -v 3
	./$(TARGET) -c 0 -m 0:0x2000 -l 2 -v 3

include ../Makefile.in
