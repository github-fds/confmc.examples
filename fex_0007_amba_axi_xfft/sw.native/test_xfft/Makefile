SHELL=/bin/sh

TARGET?=test

SRC     =\
        main.c\
        arg_parser.c\
        trx_axi_api.c\
        mem_api.c\
        axi_mem2stream_api.c\
        axi_stream2mem_api.c\
        xfft_config_api.c\
        fft.c\
        test_bench.c

all: pre $(TARGET)

run:
	./$(TARGET) -c 0 -v 0\
		--num_of_sample=256\
		--sampling_freq=2000000\
		--signal_spec="100000:1.0:0"\
		--signal_spec="200000:1.0:0"\
		--signal_spec="300000:1.0:0"\
		--data_file_float="data_float.txt"\
		--data_file_fixed="data_fixed.txt"\
		--fft_file_float="fft_float.txt"\
		--fft_file_fixed="fft_fixed.txt"

DIR_PLT=../../hw/sim/modelsim.vivado

plot:
	python ${DIR_PLT}/plot.py -a data_fixed.txt -f fft_fixed.txt

plot_data:
	if [ -f data_float.txt ]; then\
		sed --posix 's/\([0-9]\)\([-+][0-9]\)/\1  \2/g; s/j//g' data_float.txt > data_float_all.txt;\
		gnuplot -e "data_file='data_float_all.txt'" ${DIR_PLT}/plot_data.plt;\
	else\
		echo "data_float.txt" not found;\
	fi

plot_fft:
	if [ -f fft_float.txt ]; then\
		sed --posix 's/\([0-9]\)\([-+][0-9]\)/\1  \2/g; s/j//g' fft_float.txt > fft_float_all.txt;\
		gnuplot -e "data_file='fft_float_all.txt'" ${DIR_PLT}/plot_fft.plt;\
	else\
		echo "fft_float.txt" not found;\
	fi


include ../Makefile.in
