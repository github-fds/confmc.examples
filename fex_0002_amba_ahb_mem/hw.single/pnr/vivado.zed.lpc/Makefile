#------------------------------------------------------------------
# VIVADO Batch Mode 
#------------------------------------------------------------------
# Copyright (c) 2018 by Future Design Systems
# All right reserved.
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#-------------------------------------------------------------------------------
ifndef XILINX_VIVADO
       $(warning XILINX_VIVADO environment variable not defined)
else
export VIVADO_VERSION = $(shell vivado -version | sed -n 1p | cut -d" " -f 2 | cut -c 2-)
export VIVADO_VER=vivado.$(VIVADO_VERSION)
endif
ifndef CONFMC_HOME
       $(warning CONFMC_HOME environment variable not defined)
       export CONFMC_HOME=${HOME}/work/projects/ez-usb-fx3
endif
#------------------------------------------------------------------
export VIVADO = $(XILINX_VIVADO)/bin/vivado
export PROJECT_DIR = project_1
export PROJECT_NAME = project_1
export SOURCE = vivado_run.tcl
export WORK   = work
export DEVICE = xc7z020-clg484-1
export MODULE = fpga
export BOARD  = ZED
export RIGOR  = 1
BFM_AXI=${CONFMC_HOME}/hwlib/trx_ahb
ifeq ("$(wildcard ${BFM_AXI}/syn/vivado.z7/bfm_ahb.edif)","")
     $(warning "${BFM_AXI}/syn/vivado.z7/bfm_ahb.edif not found.")
     ifeq ("$(wildcard ${BFM_AXI}/syn/vivado/bfm_ahb.edif)","")
          $(error "${BFM_AXI}/syn/vivado/bfm_ahb.edif not found.")
     else
          export DIR_BFM_EDIF=${BFM_AXI}/syn/vivado
     endif
else
     export DIR_BFM_EDIF=${BFM_AXI}/syn/vivado.z7
endif

FLOG	= $(MODULE)
#------------------------------------------------------------------
all: vivado 

vivado:
	$(VIVADO) -mode batch -source $(SOURCE)

#------------------------------------------------------------------
DIRS    = $(subst /,, $(dir $(wildcard */Makefile)))

clean:
	-@/bin/rm -rf .Xil
	-@/bin/rm -rf work .cache
	-@/bin/rm -f  *.html
	-@/bin/rm -f  *.xml
	-@/bin/rm -f  *.jou
	-@/bin/rm -f  *.backup*
	-@/bin/rm -f  planAhead.*
	-@/bin/rm -f  vivado.log
	-@/bin/rm -f  vivado_pid*.str  vivado_pid*.debug
	-@/bin/rm -f  fsm_encoding.os
	-@/bin/rm -f  impact_impact.xwbt  impact.xsl webtalk.log
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done

cleanup: clean
	-@/bin/rm -f  ./*.log
	-@/bin/rm -f  $(MODULE).ucf
	-@/bin/rm -f  $(MODULE).ut
	-@/bin/rm -f  $(MODULE).tcf
	-@/bin/rm -rf work
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done

clobber: cleanup

cleanupall: cleanup
	-@/bin/rm -rf $(WORK)
	-@/bin/rm -rf $(MODULE).edn
	-@/bin/rm -rf $(MODULE).edif
	-@/bin/rm -rf $(MODULE).bit
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done
