#-------------------------------------------------------------------------------
if {[info exists env(PART)] == 0} { 
     set PART xc7z020-clg484-1
} else {
     set PART $::env(PART)
}
if {[info exists env(MODULE)] == 0} { 
     set MODULE xftt_16bit256samples
} else { 
     set MODULE $::env(MODULE)
}
if {[info exists env(GUI)] == 0} { 
     set GUI 0
} else { 
     set GUI $::env(GUI)
}
if {[info exists env(EXAMPLE)] == 0} { 
     set EXAMPLE 0
} else { 
     set EXAMPLE $::env(EXAMPLE)
}

set_part ${PART}
#-------------------------------------------------------------------------------
create_project managed_ip_project managed_ip_project -part ${PART} -ip -force
set_property target_simulator XSim [current_project]
set_property simulator_language Mixed [current_project]
create_ip -name xfft -vendor xilinx.com -library ip -version 9.1\
          -module_name ${MODULE} -dir [pwd] -force
set_property -dict [list CONFIG.transform_length {256}\
                         CONFIG.target_clock_frequency {500}\
                         CONFIG.implementation_options {pipelined_streaming_io}\
                         CONFIG.data_format {fixed_point}\
                         CONFIG.input_width {16}\
                         CONFIG.phase_factor_width {16}\
                         CONFIG.scaling_options {unscaled}\
                         CONFIG.rounding_modes {truncation}\
                         CONFIG.output_ordering {natural_order}\
                         CONFIG.aresetn {true}\
                         CONFIG.throttle_scheme {nonrealtime}\
                         CONFIG.complex_mult_type {use_mults_performance}\
                         CONFIG.butterfly_type {use_luts}\
                         CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {1}\
                         CONFIG.memory_options_hybrid {false}\
                         CONFIG.xk_index {true}\
                   ] [get_ips ${MODULE}]
#                         CONFIG.ovflo {true} only for scaled arithmetic or single-precision floating point
#                         CONFIG.target_data_throughput {1000} nor for pipelined version
generate_target {instantiation_template} [get_files ${MODULE}.xci]
generate_target all [get_files  ${MODULE}.xci]
export_ip_user_files -of_objects [get_files ${MODULE}.xci] -no_script -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ${MODULE}.xci]
launch_run -jobs 4 ${MODULE}_synth_1
wait_on_run ${MODULE}_synth_1
export_simulation -of_objects [get_files ${MODULE}/${MODULE}.xci]\
                  -directory ip_user_files/sim_scripts -force -quiet
#-------------------------------------------------------------------------------
if {${GUI} == 0} {
  exit
}
#-------------------------------------------------------------------------------
