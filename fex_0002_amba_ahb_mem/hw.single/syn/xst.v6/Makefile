#-------------------------------------------------------------------------------
# Copyright (c) 2018 by Future Design Systems
# All right reserved.
# 
SHELL		= /bin/sh
MAKEFILE	= Makefile
#-------------------------------------------------------------------------------
ifndef XILINX
       $(warning XILINX environment variable not defined)
endif
ifndef CONFMC_HOME
       $(warning CONFMC_HOME environment variable not defined)
       export CONFMC_HOME=${HOME}/work/projects/ez-usb-fx3
endif
#--------------------------------------------------------
XST	= $(shell which xst)
NGCB	= $(shell which ngcbuild)
NGCE	= $(shell which ngc2edif)
NETG	= $(shell which netgen)
WORK	= work
DEV     = XC6VLX240T-1FF1156
#--------------------------------------------------------
TOP	= fpga
BRAM    = ../../../iplib/mem_ahb/bram_simple_dual_port/v6/ise14
BFM_AHB	= ${CONFMC_HOME}/hwlib/trx_ahb
#--------------------------------------------------------
INCD	= "../../design/verilog\
           ${BRAM}\
           ../../../iplib/mem_ahb/rtl/verilog\
           ${BFM_AHB}/rtl/verilog\
           "
#--------------------------------------------------------
ifeq ("$(wildcard ${BFM_AHB}/syn/xst.v6/bfm_ahb.ngc)","")
     $(warning "${BFM_AHB}/syn/xst.v6/bfm_ahb.ngc not found.")
     ifeq ("$(wildcard ${BFM_AHB}/syn/xst/bfm_ahb.ngc)","")
          $(error "${BFM_AHB}/syn/xst/bfm_ahb.ngc not found.")
     else
     BFM_AHB_NGC=${BFM_AHB}/syn/xst
     endif
else
BFM_AHB_NGC=${BFM_AHB}/syn/xst.v6
endif
#--------------------------------------------------------

all: synthesis merge

synthesis:
	cat xst_list.txt > x.txt
	echo "verilog work ${BFM_AHB}/rtl/verilog/bfm_ahb_stub.v" >> x.txt
	(export dev_name=$(DEV);\
	export top_name=$(TOP);\
	export inc_dir=$(INCD);\
	export design=x.txt;\
	$(XST) -ifn xst_option_v6.txt -ofn ${TOP}.log;)

merge:
	@if [ -f ${TOP}.ngc ]; then\
		mv ${TOP}.ngc ${TOP}T.ngc;\
		($(NGCB)\
		    -sd ${BRAM}\
		    -sd ${BFM_AHB_NGC}\
		    -i -insert_keep_hierarchy\
		    ${TOP}T.ngc ${TOP}.ngc || exit 1) 2>&1 | tee -a ${TOP}.log;\
		if [ -f ${TOP}T.ngc ]; then /bin/rm -f ${TOP}T.ngc; fi;\
	else\
		echo "first ${TOP}.ngc not found";\
	fi


edif: ${TOP}.ngc
	@if [ -f ${TOP}.ngc ]; then\
		$(NGCE) -bd angle -w ${TOP}.ngc ${TOP}.edif || exit 1;\
	else\
		echo "second ${TOP}.ngc not found";\
	fi;\

clean:
	-@/bin/rm -f compile.log
	-@/bin/rm -f ngc2edif.log
	-@/bin/rm -f x.txt
	-@/bin/rm -rf ./xst
	-@/bin/rm -rf ./_xmsgs
	-@/bin/rm -f compile.ngc
	-@/bin/rm -f $(TOP).xncf
	-@/bin/rm -f $(TOP).log
	-@/bin/rm -f $(TOP).edif
	-@/bin/rm -f $(TOP).lso
	-@/bin/rm -f $(TOP).blc
	-@/bin/rm -f $(TOP).ngr
	-@/bin/rm -rf xlnx_auto_0_xdb
	-@/bin/rm -f *_xst.xrpt
	-@/bin/rm -f xlnx_auto_0.ise
	-@/bin/rm -f x_list.txt xx_list.txt

cleanup: clean
	-@/bin/rm -f $(TOP).edf
	-@/bin/rm -f $(TOP).edif

clobber: cleanup

cleanupall: cleanup
	-@/bin/rm -f $(TOP).ngc

#-------------------------------------------------------------------------------
