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
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#------------------------------------------------------------------
ifndef XILINX_VIVADO
       $(warning XILINX_VIVADO environment variable not defined)
endif
ifndef CONFMC_HOME
       $(warning CONFMC_HOME environment variable not defined)
       export CONFMC_HOME=${HOME}/work/projects/ez-usb-fx3
endif
#------------------------------------------------------------------
ARCH	= $(shell uname)
MACH	= $(shell uname -m)
ifeq ($(ARCH),Linux)
  ifeq ($(MACH),x86_64)
        PLATFORM= linux64
  else
        PLATFORM= linux
  endif
else ifeq ($(findstring CYGWIN,$(ARCH)),CYGWIN)
  ifeq ($(MACH),x86_64)
        PLATFORM= cygwin64
  else
        PLATFORM= cygwin
  endif
else ifeq ($(findstring MINGW,$(ARCH)),MINGW)
  ifeq ($(MACH),x86_64)
        PLATFORM= mingw64
  else
        PLATFORM= mingw
  endif
else
  $(error un-supported platform $(ARCH))
endif
#--------------------------------------------------------
VLIB	= $(shell which vlib)
VLOG	= $(shell which vlog)
VSIM	= $(shell which vsim)
#--------------------------------------------------------
STR	= $(shell $(VSIM) -version)
VVER	= $(shell for S in $(STR); do\
		if [ "$${NN}" = "vsim" ]; then\
			echo $$S;\
		fi;\
		NN=$$S;\
	done)
MAJOR	= $(firstword $(subst ., , $(VVER)))
#--------------------------------------------------------
ifeq ($(shell test $(MAJOR) -ge 10; echo $$?),0)
	VOPT=-novopt -l transcript
else
	VOPT=-l transcript
endif
#--------------------------------------------------------
VIVADO_VERSION = $(shell vivado -version | sed -n 1p | cut -d" " -f 2 | cut -c 2-)
GCC_VERSION = $(shell gcc -dumpversion)
#--------------------------------------------------------
DEFINES=SIM+VCD
#--------------------------------------------------------
unexport PLIOBJS
DEFINES+=
export DIR_FIP=../../../iplib
#--------------------------------------------------------
WORK	= unisims_ver
#export FPGA_TYPE?=z7
export FPGA_TYPE?=zusp
export VIVADO=vivado.$(VIVADO_VERSION)
#--------------------------------------------------------
TOP	= top
OPTIONS = +num_sig=1 +sampling_freq=2000000 +sin_freq=100000
#--------------------------------------------------------
all: vlib compile simulate

vlib:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	($(VLIB) $(WORK) || exit 1) 2>&1 | tee compile.log

compile: vlib
	($(VLOG) -lint -work $(WORK)\
		+define+$(DEFINES)\
		+define+AMBA_AXI4\
		-f modelsim.args || exit 1) 2>&1 | tee -a compile.log

simulate: compile
	($(VSIM) $(VOPT) -c -do "run -all; quit"\
		$(OPTIONS)\
		-lib $(WORK) $(WORK).$(TOP) $(WORK).glbl) || exit -1

#--------------------------------------------------------
plot:
	if [ -f signal_data_fixed.txt ] && [ -f fft_result_fixed.txt ]; then\
		python plot.py -a signal_data_fixed.txt -f fft_result_fixed.txt;\
	else\
		echo "signal_data_fixed.txt fft_result_fixed.txt" not found;\
	fi

plot_data:
	if [ -f data_float.txt ]; then\
		sed --posix 's/\([0-9]\)\([-+][0-9]\)/\1  \2/g; s/j//g' data_float.txt > data_float_all.txt;\
		gnuplot -e "data_file='data_float_all.txt'" plot_data.plt;\
	else\
		echo "data_float.txt" not found;\
	fi

plot_fft:
	if [ -f fft_float.txt ]; then\
		sed --posix 's/\([0-9]\)\([-+][0-9]\)/\1  \2/g; s/j//g' fft_float.txt > fft_float_all.txt;\
		gnuplot -e "data_file='fft_float_all.txt'" plot_fft.plt;\
	else\
		echo "fft_float.txt" not found;\
	fi


plot_twiddle:
	if [ -f twiddle_table.txt ]; then\
		gnuplot -e "data_file='twiddle_table.txt'" plot_twiddle.plt;\
	else\
		echo "twiddle_table.txt" not found;\
	fi

#--------------------------------------------------------
clean:
	-@/bin/rm -rf $(WORK)
	-@/bin/rm -f  transcript
	-@/bin/rm -f  wave.vcd dump.vcd
	-@/bin/rm -f  vsim.wlf wave.wlf
	-@/bin/rm -f  vish_stacktrace.vstf
	-@/bin/rm -f  wlft*
	-@/bin/rm -f  compile.log
	-@/bin/rm -f  mem_Q256.vmf
	-@/bin/rm -f  sfdp.vmf
	-@/bin/rm -f  UserData.h
	-@/bin/rm -f  $(notdir ${MIF})

cleanup clobber: clean 
	/bin/rm -f twiddle_table.txt
	/bin/rm -f data_float.txt data_fixed.txt data_float_all.txt
	/bin/rm -f fft_float.txt fft_fixed.txt fft_float_all.txt
	/bin/rm -f signal_data_fixed.txt fft_result_fixed.txt

cleanupall: cleanup
