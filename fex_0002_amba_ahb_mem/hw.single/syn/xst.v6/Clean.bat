@ECHO OFF
if exist compile.log  del /Q compile.log
if exist ngc2edif.log del /Q ngc2edif.log
if exist compile.ngc  del /Q compile.ngc
if exist xilinx.log   del /Q xilinx.log
if exist xst          rmdir /S/Q xst
if exist _xmsgs       rmdir /S/Q _xmsgs
if exist *.edif       del /Q *.edif
if exist *.xncf       del /Q *.xncf
if exist *.lso        del /Q *.lso
if exist *.ngc        del /Q *.ngc
if exist *.ngr        del /Q *.ngr
if exist *.log        del /Q *.log
if exist *.blc        del /Q *.blc
if exist *.xrpt       del /Q *.xrpt
if exist ..\*.ngc     del /Q ..\*.ngc
if exist ..\*.edif    del /Q ..\*.edif
if exist xlnx_auto_0_xdb rmdir /S/Q xlnx_auto_0_xdb
if exist xlnx_auto_0.ise del   /Q   xlnx_auto_0.ise
if exist x_list.txt      del   /Q   x_list.txt
if exist xx_list.txt     del   /Q   xx_list.txt
