#------------------------------------------------------------------
# Copyright (c) 2019 by Ando Ki.
# All right reserved.
#------------------------------------------------------------------
# simulation
# $ make
#
# plot signal & fft-result in the memory using Python
# $ make plot
#
# plot data & fft-rsult on the AXIS bus using GNUPLOT
# $ make plot_data
# $ make plot_fft
#
# plot twiddle factor
# $ make plot_twiddle
ifndef XILINX_VIVADO
       $(warning XILINX_VIVADO environment variable not defined)
endif
ifndef CONFMC_HOME
       $(warning CONFMC_HOME environment variable not defined)
       export CONFMC_HOME=${HOME}/work/projects/ez-usb-fx3
endif

VIVADO_VERSION = $(shell vivado -version | sed -n 1p | cut -d" " -f 2 | cut -c 2-)
export FPGA_TYPE=z7
export VIVADO=vivado.$(VIVADO_VERSION)
export DIR_FIP=../../../iplib

all: elab sim

elab:
	xelab -prj xsim.prj -debug typical -L secureip -L unisims_ver -L unimacro_ver top glbl -s top

#        -L UNISIMS_VER\
#        -L UNIMACRO_VER\
#        -L UNIFAST_VER\
#        -L SIMPRIMS_VER\
#        -L SECUREIP_VER\
#        -L XPM\

sim:
	xsim top -testplusarg num_sig=1\
		-testplusarg sampling_freq=2000000\
		-testplusarg sin_freq=100000\
		-t xsim_run.tcl
#	xsim top -gui -t xsim_run.tcl

#--------------------------------------------------------
plot:
	@if [ -f signal_data_fixed.txt ] && [ -f fft_result_fixed.txt ]; then\
		python ../modelsim.vivado/plot.py -a signal_data_fixed.txt -f fft_result_fixed.txt;\
	else\
		echo "signal_data_fixed.txt fft_result_fixed.txt" not found;\
	fi

plot_data:
	@if [ -f data_float.txt ]; then\
		sed --posix 's/\([0-9]\)\([-+][0-9]\)/\1  \2/g; s/j//g' data_float.txt > data_float_all.txt;\
		gnuplot -e "data_file='data_float_all.txt'" ../modelsim.vivado/plot_data.plt;\
	else\
		echo "data_float.txt" not found;\
	fi

plot_fft:
	@if [ -f fft_float.txt ]; then\
		sed --posix 's/\([0-9]\)\([-+][0-9]\)/\1  \2/g; s/j//g' fft_float.txt > fft_float_all.txt;\
		gnuplot -e "data_file='fft_float_all.txt'" ../modelsim.vivado/plot_fft.plt;\
	else\
		echo "fft_float.txt" not found;\
	fi


plot_twiddle:
	@if [ -f twiddle_table.txt ]; then\
		gnuplot -e "data_file='twiddle_table.txt'" ../modelsim.vivado/plot_twiddle.plt;\
	else\
		echo "twiddle_table.txt" not found;\
	fi

#all:
#	xvlog ${XILINX_VIVADO}/data/verilog/src/glbl.v
#	xelab -debug typical -L secureip -L unisims_ver -L unimacro_ver top glbl -s top_sim 
#
#all:
#	xvlog file1.v
#	xvhdl file2.vhd
#	xvlog top.v
#	xelab -debug typical top -s top
#	xsim top -t xsim_run.tcl

clean:
	/bin/rm -f  top.wdb
	/bin/rm -f  wave.vcd
	/bin/rm -f  webtalk_*.backup.jou
	/bin/rm -f  webtalk_*.backup.log
	/bin/rm -f  webtalk.jou
	/bin/rm -f  webtalk.log
	/bin/rm -f  xelab.log
	/bin/rm -f  xelab.pb
	/bin/rm -fr .Xil/
	/bin/rm -f  xsim_*.backup.jou
	/bin/rm -f  xsim_*.backup.log
	/bin/rm -fr xsim.dir/
	/bin/rm -f  xsim.jou
	/bin/rm -f  xsim.log
	/bin/rm -f  xvlog.log
	/bin/rm -f  xvlog.pb
	/bin/rm -f  data_fixed.txt  data_float.txt  fft_fixed.txt  fft_float.txt
	/bin/rm -f  ifft_fixed.txt  ifft_float.txt
	/bin/rm -f  twiddle_table.txt signal_data_fixed.txt fft_result_fixed.txt

cleanup: clean

cleanupall: cleanup
