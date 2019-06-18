//------------------------------------------------------------------------------
// Copyright (c) 2018-2019 by Future Design Systems
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// fpag.v
//------------------------------------------------------------------------------
// VERSION: 201E9.06.10
//------------------------------------------------------------------------------
`include "defines_system.v"

`ifdef    BOARD_ZED
`include "fpga_zed.v"
`elsif    BOARD_ZC706
`include "fpga_zc706.v"
`elsif    BOARD_ZC702
`include "fpga_zc702.v"
`elsif    BOARD_ZCU102
`include "fpga_zcu102.v"
`elsif    BOARD_ZCU111
`include "fpga_zcu111.v"
`else
   `error   "No Board"
`endif
//------------------------------------------------------------------------------
// Revision history:
//
// 2019.06.10: 'zcu111' added
// 2018.08.15: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
