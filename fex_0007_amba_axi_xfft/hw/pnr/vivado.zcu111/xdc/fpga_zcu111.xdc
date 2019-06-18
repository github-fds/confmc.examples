set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design] 

# CLOCK
set_property PACKAGE_PIN AN15  [get_ports "BOARD_CLK_IN_N"] ;#"CLK_100_N" Bank  64 VCCO - VCC1V8   - IO_L11N_T1U_N9_GC_64
set_property IOSTANDARD  LVDS  [get_ports "BOARD_CLK_IN_N"] ;#"CLK_100_N" Bank  64 VCCO - VCC1V8   - IO_L11N_T1U_N9_GC_64
set_property PACKAGE_PIN AM15  [get_ports "BOARD_CLK_IN_P"] ;#"CLK_100_P" Bank  64 VCCO - VCC1V8   - IO_L11P_T1U_N8_GC_64
set_property IOSTANDARD  LVDS  [get_ports "BOARD_CLK_IN_P"] ;#"CLK_100_P" Bank  64 VCCO - VCC1V8   - IO_L11P_T1U_N8_GC_64

create_clock   -name BOARD_CLK_IN -period  10.0 [get_ports BOARD_CLK_IN_P]

# USER RESET
set_property PACKAGE_PIN AW5      [get_ports "BOARD_RST_SW"] ;#"GPIO_SW_C" Bank  84 VCCO - VCC1V8   - IO_L1N_AD11N_84
set_property IOSTANDARD  LVCMOS18 [get_ports "BOARD_RST_SW"] ;#"GPIO_SW_C" Bank  84 VCCO - VCC1V8   - IO_L1N_AD11N_84
set_input_delay 10 -clock [get_clocks BOARD_CLK_IN] [get_ports BOARD_RST_SW]
set_false_path -from [get_ports BOARD_RST_SW]

#set_property PACKAGE_PIN AW3      [get_ports "GPIO_SW_N"] ;# Bank  84 VCCO - VCC1V8   - IO_L2N_AD10N_84
#set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_SW_N"] ;# Bank  84 VCCO - VCC1V8   - IO_L2N_AD10N_84
#set_property PACKAGE_PIN AW4      [get_ports "GPIO_SW_E"] ;# Bank  84 VCCO - VCC1V8   - IO_L2P_AD10P_84
#set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_SW_E"] ;# Bank  84 VCCO - VCC1V8   - IO_L2P_AD10P_84
#set_property PACKAGE_PIN AW5      [get_ports "GPIO_SW_C"] ;# Bank  84 VCCO - VCC1V8   - IO_L1N_AD11N_84
#set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_SW_C"] ;# Bank  84 VCCO - VCC1V8   - IO_L1N_AD11N_84
#set_property PACKAGE_PIN AW6      [get_ports "GPIO_SW_W"] ;# Bank  84 VCCO - VCC1V8   - IO_L1P_AD11P_84
#set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_SW_W"] ;# Bank  84 VCCO - VCC1V8   - IO_L1P_AD11P_84
