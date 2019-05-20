#
# NOTE:  typical usage would be "vivado -mode tcl -source run.tcl" 

#########################################################################
# Define output directory area.
#########################################################################
puts $::env(XILINX_VIVADO)
puts $::env(BITFILE)

#########################################################################
open_hw
if { $::env(JTAG_ID) == 1 } {
  connect_hw_server -url localhost:3121
  current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210251A0498E]
  set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210251A0498E]
} elseif { $::env(JTAG_ID) == 2 } {
  connect_hw_server -url localhost:3121
  current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210251A04992]
  set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210251A04992]
} else {
  connect_hw_server
}
open_hw_target
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
set_property PROBES.FILE {} [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE "$::env(BITFILE)" [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]

#########################################################################
