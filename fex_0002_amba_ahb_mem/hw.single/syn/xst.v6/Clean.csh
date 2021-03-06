#!/bin/csh -f
if ( -d xst             ) /bin/rm -rf xst
if ( -d _xmsgs          ) /bin/rm -rf _xmsgs
if ( -e compile.log     ) /bin/rm -f compile.log
if ( -e ngc2edif.log    ) /bin/rm -f ngc2edif.log
if ( -e compile.ngc     ) /bin/rm -f compile.ngc
if ( -e xilinx.log      ) /bin/rm -f xilinx.log
if ( -e *.edif          ) /bin/rm -f *.edif
if ( -e *.xncf          ) /bin/rm -f *.xncf
if ( -e *.lso           ) /bin/rm -f *.lso
if ( -e *.ngc           ) /bin/rm -f *.ngc
if ( -e *.ngr           ) /bin/rm -f *.ngr
if ( -e *.log           ) /bin/rm -f *.log
if ( -e *.blc           ) /bin/rm -f *.blc
if ( -e *.xrpt          ) /bin/rm -f *.xrpt
if ( -e ../*.ngc        ) /bin/rm -f ../*.ngc
if ( -e ../*.edif       ) /bin/rm -f ../*.edif
if ( -d xlnx_auto_0_xdb ) /bin/rm -rf xlnx_auto_0_xdb
if ( -e xlnx_auto_0.ise ) /bin/rm -f xlnx_auto_0.ise
if ( -e x_list.txt      ) /bin/rm -f x_list.txt
if ( -e xx_list.txt     ) /bin/rm -f xx_list.txt
