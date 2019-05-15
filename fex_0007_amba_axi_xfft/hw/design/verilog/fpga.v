//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// fpag.v
//------------------------------------------------------------------------------
// VERSION: 2018.08.15.
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
`else
   `error   "No Board"
`endif
//------------------------------------------------------------------------------
// Revision history:
//
// 2018.08.15: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
