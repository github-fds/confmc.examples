#-----------------------------------------------------------
if {[info exists env(DEVICE)] == 0} { 
     set DEVICE xczu25dr-ffvg1517-2-e
} else {
     set DEVICE $::env(DEVICE)
}
if {[info exists env(MODULE)] == 0} { 
     set MODULE fifo_32to128_512
} else { 
     set MODULE $::env(MODULE)
}
if {[info exists env(DEPTH)] == 0} { 
     set DEPTH 512
} else { 
     set DEPTH $::env(DEPTH)
}

set_part ${DEVICE}
#-----------------------------------------------------------
create_project managed_ip_project managed_ip_project -part ${DEVICE} -ip -force
set_property simulator_language Verilog [current_project]
set_property target_simulator Questa [current_project]
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2\
          -module_name ${MODULE} -dir [pwd] -force
set_property -dict [list CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}\
                         CONFIG.Performance_Options {First_Word_Fall_Through}\
                         CONFIG.asymmetric_port_width {true}\
                         CONFIG.Input_Data_Width {32}\
                         CONFIG.Input_Depth ${DEPTH}\
                         CONFIG.Output_Data_Width {128}\
                         CONFIG.Output_Depth [expr ${DEPTH}/4]\
                         CONFIG.Valid_Flag {true}\
                         CONFIG.Reset_Type {Asynchronous_Reset}\
                         CONFIG.Enable_Safety_Circuit {false}\
                         CONFIG.Use_Extra_Logic {true}\
                         CONFIG.Data_Count_Width [expr log(${DEPTH})/log(2)+1]\
                         CONFIG.Write_Data_Count {true}\
                         CONFIG.Write_Data_Count_Width [expr log(${DEPTH})/log(2)+1]\
                         CONFIG.Read_Data_Count {true}\
                         CONFIG.Read_Data_Count_Width [expr log(${DEPTH})/log(2)-1]\
                         CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}\
                         CONFIG.Full_Threshold_Assert_Value [expr ${DEPTH}-3]\
                         CONFIG.Full_Threshold_Negate_Value [expr ${DEPTH}-4]\
                         CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}\
                         CONFIG.Empty_Threshold_Assert_Value {4}\
                         CONFIG.Empty_Threshold_Negate_Value {5}\
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
