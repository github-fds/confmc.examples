//------------------------------------------------------------------------------
// Copyright (c) 2018-2019 by Future Design Systems
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// fpga.v
//------------------------------------------------------------------------------
// VERSION: 2019.06.10.
//------------------------------------------------------------------------------
`include "defines_system.v"

`ifdef    BOARD_SP605
`include "top_sp605.v"
`elsif    BOARD_ML605
`include "top_ml605.v"
`elsif    BOARD_ZED
`include "top_zed.v"
`elsif    BOARD_VCU108
`include "top_vcu108.v"
`elsif    BOARD_ZCU111
`include "top_zcu111.v"
`else
`endif
//------------------------------------------------------------------------------
// Revision history:
//
// 2019.06.10: BOARD_ZCU111 added
// 2018.08.15: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
