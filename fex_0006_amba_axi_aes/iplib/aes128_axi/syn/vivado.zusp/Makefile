#------------------------------------------------------------------
# VIVADO Batch Mode 
#------------------------------------------------------------------
# Copyright (c) 2018 by Future Design Systems
# All right reserved.
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#------------------------------------------------------------------
export VIVADO             = $(XILINX_VIVADO)/bin/vivado
export VIVADO_VER         = vivado.$(shell vivado -version | grep Vivado | cut -d" " -f2 | cut -d"v" -f2 | cut -d"." -f1-2)
export PROJECT_DIR        = project_1
export PROJECT_NAME       = project_1
export WORK               = work
export FPGA_TYPE          = zusp
export MODULE             = aes128_axi
export RIGOR              = 1
export SYNTH_ONLY         = 1
#------------------------------------------------------------------
export SOURCE             =vivado_syn.tcl
#------------------------------------------------------------------
all: vivado

vivado:
	$(VIVADO) -mode tcl -source $(SOURCE)

install: ${MODULE}.dcp ${MODULE}.edif ${MODULE}.vm ${MODULE}_stub.v
	if [ -f ${MODULE}.vm ]; then\
		cp ${MODULE}.vm ../../rtl/verilog/${MODULE}_vivado.vm;\
	fi

#------------------------------------------------------------------
DIRS    = $(subst /,, $(dir $(wildcard */Makefile)))

clean:
	-/bin/rm -f  *.log
	-/bin/rm -fr .cache
	-/bin/rm -rf .Xil
	-/bin/rm -f  *.html
	-/bin/rm -f  *.xml
	-/bin/rm -f  *.jou
	-/bin/rm -f  *.backup*
	-/bin/rm -f  planAhead.*
	-/bin/rm -f  vivado.log
	-/bin/rm -f  vivado_pid*.str  vivado_pid*.debug
	-/bin/rm -f  fsm_encoding.os
	-/bin/rm -f  hw_ila_data_*btree
	-/bin/rm -rf $(WORK)
	-/bin/rm -f  sbox_dual_port_8x512.mif  sibox_dual_port_8x512.mif

	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done

cleanup clobber: clean
	-@/bin/rm -rf $(MODULE).vm
	-@/bin/rm -rf $(MODULE)_vivado.vm
	-@/bin/rm -rf $(MODULE)_stub.v
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done

cleanupall: cleanup
	-@/bin/rm -f  $(MODULE).xdc
	-@/bin/rm -rf $(MODULE).dcp
	-@/bin/rm -rf $(MODULE).edn
	-@/bin/rm -rf $(MODULE).edif
	-@/bin/rm -rf $(MODULE).vm
	-@/bin/rm -rf $(MODULE)_vivado.vm
	-@/bin/rm -rf $(MODULE)_stub.v
	-@/bin/rm -rf project_*
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done
#------------------------------------------------------------------
