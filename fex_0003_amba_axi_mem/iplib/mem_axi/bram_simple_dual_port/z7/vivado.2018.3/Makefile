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
export SOURCE_BRAM = vivado_ip_project_bram.tcl	
export WORK    = work
export MACRO   = MACRO
export DEVICE  = xc7z045ffg900-2
export MODULE  = 
export WIDTH   = 
export DEPTH   = 

#------------------------------------------------------------------
#DEPTH_ALL?=8 16 32 64 128 256 512
DEPTH_ALL?=8 16 32

#------------------------------------------------------------------
all:
	for D in $(DEPTH_ALL); do\
		(export MODULE=bram_simple_dual_port_32x$${D}KB;\
		export DEPTH=$$D;\
		$(VIVADO) -mode batch -source $(SOURCE_BRAM));\
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
	#for D in $(DEPTH_ALL); do\
	#	/bin/rm -fr bram_simple_dual_port_32x$${D}KB/doc;\
	#	/bin/rm -f  bram_simple_dual_port_32x$${D}KB/*_clocks.xdc;\
	#	/bin/rm -f  bram_simple_dual_port_32x$${D}KB/*_ooc.xdc;\
	#	/bin/rm -f  bram_simple_dual_port_32x$${D}KB/*_sim_netlist.vhdl;\
	#	/bin/rm -f  bram_simple_dual_port_32x$${D}KB/*_stub.vhdl;\
	#	/bin/rm -f  bram_simple_dual_port_32x$${D}KB/*.veo;\
	#	/bin/rm -f  bram_simple_dual_port_32x$${D}KB/*.vho;\
	#	/bin/rm -f  bram_simple_dual_port_32x$${D}KB/*.xdc;\
	#	/bin/rm -f  bram_simple_dual_port_32x$${D}KB/*.xml;\
	#	/bin/rm -f  bram_simple_dual_port_32x$${D}KB/*.log;\
	#	/bin/rm -fr bram_simple_dual_port_32x$${D}KB/misc;\
	#	/bin/rm -fr bram_simple_dual_port_32x$${D}KB/hdl;\
	#	/bin/rm -fr bram_simple_dual_port_32x$${D}KB/sim;\
	#	/bin/rm -fr bram_simple_dual_port_32x$${D}KB/simulation;\
	#	/bin/rm -fr bram_simple_dual_port_32x$${D}KB/synth;\
	#done

cleanupall: cleanup
	for D in $(DEPTH_ALL); do\
		/bin/rm -rf bram_simple_dual_port_32x$${D}KB;\
	done
