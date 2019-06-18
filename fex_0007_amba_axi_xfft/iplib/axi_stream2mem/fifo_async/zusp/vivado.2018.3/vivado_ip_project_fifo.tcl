#-----------------------------------------------------------
if {[info exists env(DEVICE)] == 0} { 
     set DEVICE xczu28dr-ffvg1517-2-e
} else {
     set DEVICE $::env(DEVICE)
}
if {[info exists env(MODULE)] == 0} { 
     set MODULE axi_stream2mem_fifo_async_34x16
} else { 
     set MODULE $::env(MODULE)
}
if {[info exists env(DEPTH)] == 0} { 
     set DEPTH 16
} else { 
     set DEPTH $::env(DEPTH)
}
if {[info exists env(WIDTH)] == 0} { 
     set WIDTH 34
} else { 
     set WIDTH $::env(WIDTH)
}
#puts "SIZE=${SIZE}"
#exit
set_part ${DEVICE}
#-----------------------------------------------------------
create_project managed_ip_project managed_ip_project -part ${DEVICE} -ip -force
set_property simulator_language Verilog [current_project]
set_property target_simulator Questa [current_project]
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2\
          -module_name ${MODULE}\
          -dir [pwd] -force

set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM}\
                         CONFIG.Performance_Options {First_Word_Fall_Through}\
                         CONFIG.Input_Data_Width ${WIDTH}\
                         CONFIG.Input_Depth ${DEPTH}\
                         CONFIG.Output_Data_Width ${WIDTH}\
                         CONFIG.Output_Depth ${DEPTH}\
                         CONFIG.Enable_Reset_Synchronization {true}\
                         CONFIG.Reset_Type {Asynchronous_Reset}\
                         CONFIG.Full_Flags_Reset_Value {1}\
                         CONFIG.Almost_Full_Flag {true}\
                         CONFIG.Valid_Flag {true}\
                         CONFIG.Use_Extra_Logic {true}\
                         CONFIG.Data_Count_Width [expr {log(${DEPTH})/log(2)}]\
                         CONFIG.Write_Data_Count {true}\
                         CONFIG.Write_Data_Count_Width [expr {log(${DEPTH})/log(2)} + 1]\
                         CONFIG.Read_Data_Count {true}\
                         CONFIG.Read_Data_Count_Width [expr {log(${DEPTH})/log(2)} + 1]\
                         CONFIG.Full_Threshold_Assert_Value [expr ${DEPTH} - 1]\
                         CONFIG.Full_Threshold_Negate_Value [expr ${DEPTH} - 2]\
                         CONFIG.Empty_Threshold_Assert_Value {4}\
                         CONFIG.Empty_Threshold_Negate_Value {5}\
                         CONFIG.Enable_Safety_Circuit {false}\
                   ] [get_ips ${MODULE}]
generate_target {instantiation_template} [get_files ${MODULE}.xci]
generate_target all [get_files  ${MODULE}.xci]
export_ip_user_files -of_objects [get_files ${MODULE}.xci] -no_script -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ${MODULE}.xci]
launch_run -jobs 4 ${MODULE}_synth_1
wait_on_run ${MODULE}_synth_1
export_simulation -of_objects [get_files ${MODULE}/${MODULE}.xci]\
                  -directory ip_user_files/sim_scripts -force -quiet
exit
