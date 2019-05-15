#-------------------------------------------------------------------------------
# Copyright (c) 2018 by Ando Ki.
# All rights reserved.
#-------------------------------------------------------------------------------
SHELL	= /bin/sh
MAKEFILE= Makefile
#-------------------------------------------------------------------------------
SIZES=8 16 32

all:
	for P in $(SIZES); do\
		if [ -f bram_simple_dual_port_32x$${P}KB.xco ]; then\
			coregen -r -p coregen.cgp -b bram_simple_dual_port_32x$${P}KB.xco;\
		fi;\
	done

clean:
	@if [ -f coregen.cgc           ]; then /bin/rm -f  coregen.cgc ; fi
	@if [ -f coregen.log           ]; then /bin/rm -f  coregen.log ; fi
	@if [ -f ngc2edif.log          ]; then /bin/rm -f  ngc2edif.log ; fi
	@if [ -d tmp                   ]; then /bin/rm -fr tmp ; fi
	@if [ -d _xmsgs                ]; then /bin/rm -fr _xmsgs ; fi
	@if [ -d xlnx_auto_0_xdb       ]; then /bin/rm -fr xlnx_auto_0_xdb; fi
	@if [ -f .lso                  ]; then /bin/rm -rf .lso; fi
	@if [ -f xil_*.in              ]; then /bin/rm -f  xil_*.in; fi
	@if [ -f xil_*.out             ]; then /bin/rm -f  xil_*.out; fi
	@if [ -f get_initp_pfile.tmp   ]; then /bin/rm -f  get_initp_pfile.tmp; fi
	@if [ -f summary.log           ]; then /bin/rm -f  summary.log; fi
	for P in $(SIZES); do\
		if [ -d bram_simple_dual_port_32x$${P}KB            ]; then /bin/rm -fr bram_simple_dual_port_32x$${P}KB; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB.edn        ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB.edn ; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB.gise       ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB.gise ; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB.ise        ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB.ise ; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB.veo        ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB.veo ; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB.xise       ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB.xise ; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB.xncf       ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB.xncf ; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB.asy        ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB.asy ; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB_flist.txt  ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB_flist.txt ; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB_readme.txt ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB_readme.txt ; fi;\
		if [ -f bram_simple_dual_port_32x$${P}KB_xmdf.tcl   ]; then /bin/rm -f  bram_simple_dual_port_32x$${P}KB_xmdf.tcl ; fi  ;\
		if [ -d bram_simple_dual_port_32x$${P}KB_xdb        ]; then /bin/rm -fr bram_simple_dual_port_32x$${P}KB_xdb ; fi;\
	done

cleanup clobber: clean
	for P in $(SIZES); do\
		/bin/rm -f  bram_simple_dual_port_32x$${P}KB.coe;\
		/bin/rm -f  bram_simple_dual_port_32x$${P}KB.mif;\
		/bin/rm -f  bram_simple_dual_port_32x$${P}KB.ngc;\
		/bin/rm -f  bram_simple_dual_port_32x$${P}KB.v;\
	done
	/bin/rm -fr demo_tb

cleanupall: cleanup
#-------------------------------------------------------------------------------
