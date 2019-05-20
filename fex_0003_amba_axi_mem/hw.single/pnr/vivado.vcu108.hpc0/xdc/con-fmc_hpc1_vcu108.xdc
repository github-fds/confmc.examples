########################################################
## USB Host Interface Signal
########################################################
#// FMC_HPC1
set_property PACKAGE_PIN T33  [get_ports "SL_DT[0]"]         
set_property PACKAGE_PIN R33  [get_ports "SL_DT[1]"]         
set_property PACKAGE_PIN P35  [get_ports "SL_DT[2]"]         
set_property PACKAGE_PIN P36  [get_ports "SL_DT[3]"]         
set_property PACKAGE_PIN N33  [get_ports "SL_DT[4]"]         
set_property PACKAGE_PIN M33  [get_ports "SL_DT[5]"]         
set_property PACKAGE_PIN N34  [get_ports "SL_DT[6]"]         
set_property PACKAGE_PIN N35  [get_ports "SL_DT[7]"]         
set_property PACKAGE_PIN M37  [get_ports "SL_DT[8]"]         
set_property PACKAGE_PIN L38  [get_ports "SL_DT[9]"]         
set_property PACKAGE_PIN N38  [get_ports "SL_DT[10]"]        
set_property PACKAGE_PIN M38  [get_ports "SL_DT[11]"]        
set_property PACKAGE_PIN P37  [get_ports "SL_DT[12]"]        
set_property PACKAGE_PIN N37  [get_ports "SL_DT[13]"]        
set_property PACKAGE_PIN L34  [get_ports "SL_DT[14]"]        
set_property PACKAGE_PIN K34  [get_ports "SL_DT[15]"]        
set_property PACKAGE_PIN T34  [get_ports "SL_DT[16]"]        
set_property PACKAGE_PIN T35  [get_ports "SL_DT[17]"]        
set_property PACKAGE_PIN U31  [get_ports "SL_DT[18]"]        
set_property PACKAGE_PIN U32  [get_ports "SL_DT[19]"]        
set_property PACKAGE_PIN AJ32 [get_ports "SL_DT[20]"]        
set_property PACKAGE_PIN AK32 [get_ports "SL_DT[21]"]        
set_property PACKAGE_PIN AL32 [get_ports "SL_DT[22]"]        
set_property PACKAGE_PIN AM32 [get_ports "SL_DT[23]"]        
set_property PACKAGE_PIN AT39 [get_ports "SL_DT[24]"]        
set_property PACKAGE_PIN AT40 [get_ports "SL_DT[25]"]        
set_property PACKAGE_PIN AR37 [get_ports "SL_DT[26]"]        
set_property PACKAGE_PIN AT37 [get_ports "SL_DT[27]"]        
set_property PACKAGE_PIN AT36 [get_ports "SL_DT[28]"]        
set_property PACKAGE_PIN AL30  [get_ports "SL_DT[29]"]        
set_property PACKAGE_PIN AL31  [get_ports "SL_DT[30]"]        
set_property PACKAGE_PIN AN33  [get_ports "SL_DT[31]"]        

set_property PACKAGE_PIN M35  [get_ports "SL_PCLK"]       
set_property PACKAGE_PIN L35  [get_ports "SL_CS_N"]       
set_property PACKAGE_PIN M36  [get_ports "SL_WR_N"]          
set_property PACKAGE_PIN L36  [get_ports "SL_OE_N"]          
set_property PACKAGE_PIN N32  [get_ports "SL_RD_N"]          

set_property PACKAGE_PIN M32  [get_ports "SL_FLAGA"]     
set_property PACKAGE_PIN Y31  [get_ports "SL_FLAGB"]       
set_property PACKAGE_PIN W31  [get_ports "SL_FLAGC"]       
set_property PACKAGE_PIN P31  [get_ports "SL_FLAGD"]       

set_property PACKAGE_PIN R31  [get_ports "SL_PKTEND_N"]      
set_property PACKAGE_PIN T30  [get_ports "SL_RST_N"]      

set_property PACKAGE_PIN L33  [get_ports "SL_AD[1]"]        
set_property PACKAGE_PIN K33  [get_ports "SL_AD[0]"]        

set_property PACKAGE_PIN T31  [get_ports "SL_MODE[0]"] ;# LA13_N
set_property PACKAGE_PIN AT35 [get_ports "SL_MODE[1]"] ;# LA21_P

set_property IOSTANDARD LVCMOS18    [get_ports {SL_*}]
set_property SLEW       FAST        [get_ports {SL_*}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets SL_MODE_IBUF[0]_inst/O]

set_property IOB TRUE  [get_cells {u_dut/u_master/SL_DT_O_reg*}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_RD_N_reg}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_WR_N_reg}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_OE_N_reg}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_PKTEND_N_reg}]
set_property IOB TRUE  [get_cells {u_dut/u_master/SL_AD_reg*}]
