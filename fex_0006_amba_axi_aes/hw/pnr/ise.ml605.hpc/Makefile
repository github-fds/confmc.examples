#------------------------------------------------------------------
# Copyright (c) 2015 by Future Design Systems
# All right reserved.
#------------------------------------------------------------------
# iMPRESS 
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile

#------------------------------------------------------------------
MODULE	= fpga
DEVICE	= xc6vlx240tff1156-1
FLOG	= $(MODULE)
#------------------------------------------------------------------
NGC_FILE= ../../syn/xst.v6/$(MODULE).ngc
UCF_FILE= ../ise.ml605.lpc/ucf/fpga_ml605.ucf\
          ../ise.ml605.lpc/ucf/con-fmc_hpc_ml605.ucf

#------------------------------------------------------------------
NGDBUILD	= ngdbuild
MAP		= map
PAR		= par
TRCE		= trce
BITGEN		= bitgen

#------------------------------------------------------------------
all: ngdbuild map par bitgen

#------------------------------------------------------------------
ngdbuild: NGCx UCFx
	@echo $(NGDBUILD)
	@($(NGDBUILD)  -intstyle ise -nt timestamp\
		-p $(DEVICE) -sd . -uc $(MODULE).ucf\
		-dd . $(MODULE) $(MODULE).ngd || exit 1) 2>&1\
		> $(FLOG)_ngdbuild.log

map:
	@echo $(MAP)
	@($(MAP) -p $(DEVICE) -w -ol high -pr b -timing\
		-ignore_keep_hierarchy\
		$(MODULE)\
		-o $(MODULE)_map.ncd\
		$(MODULE).pcf\
		|| exit 1) 2>&1 > $(FLOG)_map.log

par:
	@echo $(PAR)
	@($(PAR) -ol high -xe n -w $(MODULE)_map.ncd\
		$(MODULE).ncd $(MODULE).pcf || exit 1) 2>&1\
		> $(FLOG)_par.log

trce:
	@echo $(TRCE)
	@($(TRCE) -o $(MODULE).twr $(MODULE).ncd\
		$(MODULE).pcf || exit 1) 2>&1\
		> $(FLOG)_trce.log

bitgen: ut
	@echo $(BITGEN)
	@($(BITGEN) $(MODULE).ncd -d -b -w -g compress\
		-f $(MODULE).ut || exit 1) 2>&1 > $(FLOG)_bitgen.log

#------------------------------------------------------------------
# iCON3.0
tcfgen:
	@echo $(RBT2TCF)
	@($(RBT2TCF) -b 1.00 -i $(MODULE).rbt -o $(MODULE).tcf\
		-f FL -t iMPRESS -n USB || exit 1) 2>&1 > $(FLOG)_rbt2tcf.log

eifgen: mit
	@echo $(EIFGEN)
	@($(EIFGEN) -c 0 -m $(MODULE).mit -t $(MODULE).tcf\
		-o $(MODULE).eif || exit 1) 2>&1 > $(FLOG)_eifgen.log

mit:
	@if [ -f $(MODULE).mit ]; then /bin/rm -f $(MODULE).mit; fi
	@if [ ! -f $(MODULE).mit ]; then \
		echo "0 dut PRIMARY" > $(MODULE).mit;\
	fi
#------------------------------------------------------------------
NGCx:
	@if [ -f $(MODULE).ngc ]; then /bin/rm -f $(MODULE).ngc; fi
	@if [ -f $(NGC_FILE) ]; then\
		cp $(NGC_FILE) .;\
	else\
		echo $(NGCFILE) not found.;\
		exit 1;\
	fi

#------------------------------------------------------------------
UCFx:
	@if [ -f $(MODULE).ucf ]; then /bin/rm -f $(MODULE).ucf; fi
	@echo "# $(UCF_FILE)" > $(MODULE).ucf
	@for U in $(UCF_FILE); do\
		if [ -f $$U ]; then\
			cat $$U >> $(MODULE).ucf;\
		fi;\
	done

#------------------------------------------------------------------
ifeq ($(SPI_MODE),)
ut:
	@if [ -f $(MODULE).ut ]; then /bin/rm -f $(MODULE).ut; fi
	@echo; echo "\t#### SPI MODE IS X1 ####";
	@if [ ! -f $(MODULE).ut ]; then\
		echo "-g DebugBitstream:No " >  $(MODULE).ut;\
		echo "-g Binary:no         " >> $(MODULE).ut;\
		echo "-g CRC:Enable        " >> $(MODULE).ut;\
		echo "-g M2Pin:PullUp      " >> $(MODULE).ut;\
		echo "-g ProgPin:PullUp    " >> $(MODULE).ut;\
		echo "-g DonePin:PullUp    " >> $(MODULE).ut;\
		echo "-g TckPin:PullUp     " >> $(MODULE).ut;\
		echo "-g TdiPin:PullUp     " >> $(MODULE).ut;\
		echo "-g TdoPin:PullUp     " >> $(MODULE).ut;\
		echo "-g TmsPin:PullUp     " >> $(MODULE).ut;\
		echo "-g UnusedPin:PullNone" >> $(MODULE).ut;\
		echo "-g UserID:0xFFFFFFFF " >> $(MODULE).ut;\
		echo "-g StartUpClk:CClk   " >> $(MODULE).ut;\
		echo "-g DONE_cycle:4      " >> $(MODULE).ut;\
		echo "-g GTS_cycle:5       " >> $(MODULE).ut;\
		echo "-g GWE_cycle:6       " >> $(MODULE).ut;\
		echo "-g LCK_cycle:NoWait  " >> $(MODULE).ut;\
		echo "-g Security:None     " >> $(MODULE).ut;\
		echo "-g DonePipe:No       " >> $(MODULE).ut;\
		echo "-g DriveDone:No      " >> $(MODULE).ut;\
		echo "-g ConfigRate:6      " >> $(MODULE).ut;\
	fi
else
ut:
	@if [ -f $(MODULE).ut ]; then /bin/rm -f $(MODULE).ut; fi
	@echo; echo "\t#### SPI MODE IS X4 ####";
	@if [ ! -f $(MODULE).ut ]; then\
		echo "-g DebugBitstream:No " >  $(MODULE).ut;\
		echo "-g Binary:no         " >> $(MODULE).ut;\
		echo "-g CRC:Enable        " >> $(MODULE).ut;\
		echo "-g M2Pin:PullUp      " >> $(MODULE).ut;\
		echo "-g ProgPin:PullUp    " >> $(MODULE).ut;\
		echo "-g DonePin:PullUp    " >> $(MODULE).ut;\
		echo "-g TckPin:PullUp     " >> $(MODULE).ut;\
		echo "-g TdiPin:PullUp     " >> $(MODULE).ut;\
		echo "-g TdoPin:PullUp     " >> $(MODULE).ut;\
		echo "-g TmsPin:PullUp     " >> $(MODULE).ut;\
		echo "-g UnusedPin:PullNone" >> $(MODULE).ut;\
		echo "-g UserID:0xFFFFFFFF " >> $(MODULE).ut;\
		echo "-g StartUpClk:CClk   " >> $(MODULE).ut;\
		echo "-g DONE_cycle:4      " >> $(MODULE).ut;\
		echo "-g GTS_cycle:5       " >> $(MODULE).ut;\
		echo "-g GWE_cycle:6       " >> $(MODULE).ut;\
		echo "-g LCK_cycle:NoWait  " >> $(MODULE).ut;\
		echo "-g Security:None     " >> $(MODULE).ut;\
		echo "-g DonePipe:No       " >> $(MODULE).ut;\
		echo "-g DriveDone:No      " >> $(MODULE).ut;\
		echo "-g ConfigRate:16     " >> $(MODULE).ut;\
		echo "-g spi_buswidth:4    " >> $(MODULE).ut;\
	fi
endif


#------------------------------------------------------------------
clean:
	@/bin/rm -f *.tcf *.rbt *.ncd *.ngd *.ngc *.ngm *.ptwx *.ngo
	@/bin/rm -f *.lso *.ise *.twr *.xrpt
	@/bin/rm -f netlist.lst
	@/bin/rm -rf xlnx_auto_0_xdb xst _xmsgs .cache .Xil
	@/bin/rm -f $(MODULE).ucf $(MODULE).ut $(MODULE).mit
	@/bin/rm -f $(FLOG).log $(FLOG)_ngdbuild.log $(FLOG)_map.log
	@/bin/rm -f $(FLOG)_par.log $(FLOG)_bitgen.log
	@/bin/rm -f $(FLOG)_rbt2tcf.log $(FLOG)_eifgen.log
	@/bin/rm -f *.pad *.bgn *.bld *.drc *.mrp *.par *.pcf *.xpi *_pad.csv *_pad.txt
	@/bin/rm -f *.unroutes *_usage.xml *_summary.xml *.map
	@/bin/rm -f  par_usage_statistics.html
	@/bin/rm -f  *.xwbt
	@/bin/rm -f  webtalk.log
	@/bin/rm -f  usage_statistics_webtalk.html
	@/bin/rm -f  xilinx_device_details.xml
	@/bin/rm -f  fpga_*.*
	if [ -f chipscope/Makefile ] ; then\
		make -C chipscope -s $@;\
	fi
	if [ -f impact/Makefile ] ; then\
		make -C impact -s $@;\
	fi
	if [ -f impact_spi/Makefile ] ; then\
		make -C impact_spi -s $@;\
	fi

cleanup clober: clean
	if [ -f chipscope/Makefile ] ; then\
		make -C chipscope -s $@;\
	fi
	if [ -f impact/Makefile ] ; then\
		make -C impact -s $@;\
	fi
	if [ -f impact_spi/Makefile ] ; then\
		make -C impact_spi -s $@;\
	fi

cleanupall: cleanup
	@/bin/rm -f $(MODULE).bit $(MODULE).eif
#------------------------------------------------------------------
