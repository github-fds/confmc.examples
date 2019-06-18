#
# NOTE:  typical usage would be "vivado -mode tcl -source run.tcl" 

#########################################################################
# Define output directory area.
#########################################################################
puts $::env(XILINX_VIVADO)
puts $::env(BITFILE)
puts $::env(DEVICE)

#########################################################################
open_hw
connect_hw_server
open_hw_target
current_hw_device [get_hw_devices $::env(DEVICE)]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $::env(DEVICE)] 0]
set_property PROBES.FILE {} [get_hw_devices $::env(DEVICE)]
set_property FULL_PROBES.FILE {} [get_hw_devices $::env(DEVICE)]
set_property PROGRAM.FILE "$::env(BITFILE)" [get_hw_devices $::env(DEVICE)]
program_hw_devices [get_hw_devices $::env(DEVICE)]
refresh_hw_device [lindex [get_hw_devices $::env(DEVICE)] 0]
#########################################################################
