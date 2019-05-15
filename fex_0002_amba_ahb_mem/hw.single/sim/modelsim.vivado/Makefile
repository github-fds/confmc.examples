#------------------------------------------------------------------
# Copyright (c) 2018 by Ando Ki.
# All right reserved.
#
# This code is distributed in the hope that it will
# be useful to understand Ando Ki's work,
# but WITHOUT ANY WARRANTY.
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
else ifeq ($(findstring CYGWIN_NT,$(ARCH)),CYGWIN_NT)
  ifeq ($(MACH),x86_64)
        PLATFORM= cygwin64
  else
        PLATFORM= cygwin
  endif
else ifeq ($(findstring MINGW32_NT,$(ARCH)),MINGW32_NT)
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
ifeq ($(findstring Sim-64,$(STR)),Sim-64)
     WIDTH= 64
else
     WIDTH= 32
endif
#--------------------------------------------------------
ifeq ($(shell test $(MAJOR) -ge 10; echo $$?),0)
	VOPT=-novopt -l transcript
else
	VOPT=-l transcript
endif
#--------------------------------------------------------
VIVADO_VERSION = $(shell vivado -version | sed -n 1p | cut -d" " -f 2 | cut -c 2-)
#--------------------------------------------------------
DEFINES=SIM+VCD
#--------------------------------------------------------
unexport PLIOBJS
DEFINES+=
#--------------------------------------------------------
WORK	= unisims_ver
export FPGA_TYPE=z7
export VIVADO=vivado.$(VIVADO_VERSION)
#--------------------------------------------------------
TOP	= top
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
		-lib $(WORK) $(WORK).$(TOP) $(WORK).glbl) || exit -1

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

cleanup: clean

clobber: cleanup

cleanupall: cleanup
#--------------------------------------------------------
