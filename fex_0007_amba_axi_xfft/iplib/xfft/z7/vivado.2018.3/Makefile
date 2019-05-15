#-------------------------------------------------------------------------------
# Copyright (c) 2019 by Future Design Systems
# All right reserved.
#-------------------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#-------------------------------------------------------------------------------
ifndef XILINX_VIVADO
       $(warning XILINX_VIVADO environment variable not defined)
endif
#-------------------------------------------------------------------------------
export VIVADO   = $(XILINX_VIVADO)/bin/vivado
export SOURCE   = vivado_ip.tcl	
export WORK     = work
export MACRO    = MACRO
export PART     = xc7z020-clg484-1
export MODULE   = xfft_16bit256samples
export EXAMPLE ?= 0
export GUI     ?= 0

#-------------------------------------------------------------------------------
all:
	if [ "$(GUI)" = "1" ]; then\
		$(VIVADO) -mode gui -source $(SOURCE);\
	else\
		$(VIVADO) -mode batch -source $(SOURCE);\
	fi

#-------------------------------------------------------------------------------
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
	#	/bin/rm -fr rfsoc_dc/doc;\
	#	/bin/rm -f  rfsoc_dc/*_clocks.xdc;\
	#	/bin/rm -f  rfsoc_dc/*_ooc.xdc;\
	#	/bin/rm -f  rfsoc_dc/*_sim_netlist.vhdl;\
	#	/bin/rm -f  rfsoc_dc/*_stub.vhdl;\
	#	/bin/rm -f  rfsoc_dc/*.veo;\
	#	/bin/rm -f  rfsoc_dc/*.vho;\
	#	/bin/rm -f  rfsoc_dc/*.xdc;\
	#	/bin/rm -f  rfsoc_dc/*.xml;\
	#	/bin/rm -f  rfsoc_dc/*.log;\
	#	/bin/rm -fr rfsoc_dc/misc;\
	#	/bin/rm -fr rfsoc_dc/hdl;\
	#	/bin/rm -fr rfsoc_dc/sim;\
	#	/bin/rm -fr rfsoc_dc/simulation;\
	#	/bin/rm -fr rfsoc_dc/synth;\
	#done

cleanupall: cleanup
	/bin/rm -rf ${MODULE}
	/bin/rm -rf ${MODULE}_ex
#-------------------------------------------------------------------------------
