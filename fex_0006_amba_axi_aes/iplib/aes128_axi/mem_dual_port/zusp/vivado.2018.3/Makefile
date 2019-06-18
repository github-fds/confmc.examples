#------------------------------------------------------------------
# VIVADO Batch Mode 
#------------------------------------------------------------------
# Copyright (c) 2018 by Future Design Systems
# All right reserved.
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#------------------------------------------------------------------
ifndef XILINX_VIVADO
       $(warning XILINX_VIVADO environment variable not defined)
endif
#------------------------------------------------------------------
export VIVADO  = $(XILINX_VIVADO)/bin/vivado
export WORK    = work
export MACRO   = MACRO
export DEVICE  = xczu25dr-ffvg1517-2-e
export MODULE  = 
export WIDTH   = 
export DEPTH   = 

#------------------------------------------------------------------
all: bram sbox sibox

bram:
	(export MODULE=bram_dual_port_8x512;\
	$(VIVADO) -mode batch -source vivado_bram.tcl)

sbox:
	(export MODULE=sbox_dual_port_8x512;\
	$(VIVADO) -mode batch -source vivado_sbox.tcl)

sibox:
	(export MODULE=sibox_dual_port_8x512;\
	$(VIVADO) -mode batch -source vivado_sibox.tcl)

#------------------------------------------------------------------
clean:
	-@/bin/rm -rf ./.Xil
	-@/bin/rm -rf $(WORK)
	-@/bin/rm -f  ./*.html
	-@/bin/rm -f  ./*.xml
	-@/bin/rm -f  ./vivado*.jou
	-@/bin/rm -f  ./vivado*.log
	-@/bin/rm -f  ./*.backup.*
	-@/bin/rm -f  ./planAhead.*
	-@/bin/rm -f  fsm_encoding.os
	-@/bin/rm -rf ip_user_files
	-@/bin/rm -rf managed_ip_project

cleanup clobber: clean

cleanupall: cleanup
	/bin/rm -rf bram_dual_port_8x512
	/bin/rm -rf sbox_dual_port_8x512
	/bin/rm -rf sibox_dual_port_8x512
	/bin/rm -rf sbox_dual_port_5x512
	/bin/rm -rf sibox_dual_port_5x512
