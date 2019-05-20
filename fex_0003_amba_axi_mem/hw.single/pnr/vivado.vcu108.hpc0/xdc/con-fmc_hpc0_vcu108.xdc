########################################################
## USB Host Interface Signal
########################################################
#// FMC_HPC0
set_property PACKAGE_PIN AY9  [get_ports "SL_DT[0]"]        
set_property PACKAGE_PIN BA9  [get_ports "SL_DT[1]"]        
set_property PACKAGE_PIN BC10 [get_ports "SL_DT[2]"]        
set_property PACKAGE_PIN BD10 [get_ports "SL_DT[3]"]        
set_property PACKAGE_PIN BA7  [get_ports "SL_DT[4]"]        
set_property PACKAGE_PIN BB7  [get_ports "SL_DT[5]"]        
set_property PACKAGE_PIN BD8  [get_ports "SL_DT[6]"]        
set_property PACKAGE_PIN BD7  [get_ports "SL_DT[7]"]        
set_property PACKAGE_PIN BE8  [get_ports "SL_DT[8]"]        
set_property PACKAGE_PIN BE7  [get_ports "SL_DT[9]"]        
set_property PACKAGE_PIN BF12 [get_ports "SL_DT[10]"]       
set_property PACKAGE_PIN BF11 [get_ports "SL_DT[11]"]       
set_property PACKAGE_PIN BE10 [get_ports "SL_DT[12]"]       
set_property PACKAGE_PIN BE9  [get_ports "SL_DT[13]"]       
set_property PACKAGE_PIN BD12 [get_ports "SL_DT[14]"]       
set_property PACKAGE_PIN BE12 [get_ports "SL_DT[15]"]       
set_property PACKAGE_PIN AV9  [get_ports "SL_DT[16]"]        
set_property PACKAGE_PIN AV8  [get_ports "SL_DT[17]"]        
set_property PACKAGE_PIN AY8  [get_ports "SL_DT[18]"]        
set_property PACKAGE_PIN AY7  [get_ports "SL_DT[19]"]        
set_property PACKAGE_PIN AV14 [get_ports "SL_DT[20]"]        
set_property PACKAGE_PIN AV13 [get_ports "SL_DT[21]"]        
set_property PACKAGE_PIN AP13 [get_ports "SL_DT[22]"]        
set_property PACKAGE_PIN AR13 [get_ports "SL_DT[23]"]        
set_property PACKAGE_PIN AV15 [get_ports "SL_DT[24]"]        
set_property PACKAGE_PIN AW15 [get_ports "SL_DT[25]"]        
set_property PACKAGE_PIN AY15 [get_ports "SL_DT[26]"]        
set_property PACKAGE_PIN AY14 [get_ports "SL_DT[27]"]        
set_property PACKAGE_PIN AP16 [get_ports "SL_DT[28]"]        
set_property PACKAGE_PIN AN15 [get_ports "SL_DT[29]"]        
set_property PACKAGE_PIN AP15 [get_ports "SL_DT[30]"]        
set_property PACKAGE_PIN AT16 [get_ports "SL_DT[31]"]        

set_property PACKAGE_PIN BF10 [get_ports "SL_PCLK"]      
set_property PACKAGE_PIN BF9  [get_ports "SL_CS_N"]        
set_property PACKAGE_PIN BD13 [get_ports "SL_WR_N"]         
set_property PACKAGE_PIN BE13 [get_ports "SL_OE_N"]         
set_property PACKAGE_PIN BE14 [get_ports "SL_RD_N"]         

set_property PACKAGE_PIN BF14 [get_ports "SL_FLAGA"]      
set_property PACKAGE_PIN BC11 [get_ports "SL_FLAGB"]   
set_property PACKAGE_PIN BD11 [get_ports "SL_FLAGC"]      
set_property PACKAGE_PIN BF15 [get_ports "SL_FLAGD"]   

set_property PACKAGE_PIN BE15 [get_ports "SL_PKTEND_N"]     
set_property PACKAGE_PIN BA14 [get_ports "SL_RST_N"]        
set_property PACKAGE_PIN BB13 [get_ports "SL_AD[1]"]       
set_property PACKAGE_PIN BB12 [get_ports "SL_AD[0]"]       

set_property PACKAGE_PIN BB14 [get_ports "SL_MODE[0]"] ;# LA13_N
set_property PACKAGE_PIN AN16 [get_ports "SL_MODE[1]"] ;# LA21_P

set_property IOSTANDARD LVCMOS18    [get_ports {SL_*}]
set_property SLEW       FAST        [get_ports {SL_*}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets SL_MODE_IBUF[0]_inst/O]

set_property IOB TRUE  [get_cells {u_dut/u_master/SL_DT_O_reg*}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_RD_N_reg}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_WR_N_reg}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_OE_N_reg}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_PKTEND_N_reg}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_AD_reg*}]
