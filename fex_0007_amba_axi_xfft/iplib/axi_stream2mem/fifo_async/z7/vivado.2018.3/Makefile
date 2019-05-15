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
export SOURCE_FIFO = vivado_ip_project_fifo.tcl	
export WORK    = work
export MACRO   = MACRO
export DEVICE  = xc7z020clg484-1
export MOD     = axi_stream2mem
export WIDTH   = 

#------------------------------------------------------------------
DEPTH_ALL?=16
WIDTH_ALL?=34 66 130

#------------------------------------------------------------------
all:
	for D in $(DEPTH_ALL); do\
		for W in $(WIDTH_ALL); do\
			(export MODULE=${MOD}_fifo_async_$${W}x$${D};\
			export WIDTH=$$W;\
			export DEPTH=$$D;\
			$(VIVADO) -mode batch -source $(SOURCE_FIFO));\
		done;\
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
	for D in $(DEPTH36_ALL); do\
		/bin/rm -rf gig_eth_fifo_async_36x$${D};\
	done
	for D in $(DEPTH17_ALL); do\
		/bin/rm -rf gig_eth_fifo_async_17x$${D};\
	done
	for D in $(DEPTH_ALL); do\
		for W in $(WIDTH_ALL); do\
			/bin/rm -rf ${MOD}_fifo_async_$${W}x$${D};\
		done;\
	done
