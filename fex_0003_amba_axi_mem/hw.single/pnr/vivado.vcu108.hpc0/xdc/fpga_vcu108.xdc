#--------------------------------------------------------
# VCU108 R32

set_property IOSTANDARD LVDS    [get_ports {USER_CLK_IN_P}]
set_property LOC        BC9     [get_ports {USER_CLK_IN_P}]
set_property IOSTANDARD LVDS    [get_ports {USER_CLK_IN_N}]
set_property LOC        BC8     [get_ports {USER_CLK_IN_N}]

#--------------------------------------------------------
# VCU108 CPU_RESET
#set_property LOC         E36       [get_ports {USER_RST_SW}] ;# CPU_RESET
#set_property IOSTANDARD  LVCMOS12  [get_ports {USER_RST_SW}]

set_property PACKAGE_PIN AW27     [get_ports USER_RST_SW] ;# GPIO_SW_C
set_property IOSTANDARD  LVCMOS12 [get_ports USER_RST_SW]

#--------------------------------------------------------
set_false_path -reset_path       -from         [get_ports USER_RST_SW]
create_clock -name USER_CLK125MHZ_IN\
             -period 8          [get_ports USER_CLK_IN_P ]
