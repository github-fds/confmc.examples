#--------------------------------------------------------
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]


set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property CONFIG_MODE BPI16 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

