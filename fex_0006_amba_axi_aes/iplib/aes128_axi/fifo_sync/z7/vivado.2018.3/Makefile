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
export DEVICE  = xc7z045ffg900-2
export MODULE  = 
export WIDTH   = 
export DEPTH   = 

DEPTH_ALL?=512

#------------------------------------------------------------------
all: all32to128 all128to32

all32to128:
	for D in $(DEPTH_ALL); do\
		(export MODULE=fifo_32to128_$${D};\
		export DEPTH=$$D;\
		$(VIVADO) -mode batch -source vivado_32to128.tcl);\
	done

all128to32:
	for D in $(DEPTH_ALL); do\
		(export MODULE=fifo_128to32_$${D};\
		export DEPTH=$$D;\
		$(VIVADO) -mode batch -source vivado_128to32.tcl);\
	done

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
	for D in $(DEPTH_ALL); do\
		/bin/rm -rf fifo_32to128_$${D};\
		/bin/rm -rf fifo_128to32_$${D};\
	done
