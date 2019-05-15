//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
// http://www.future-ds.com
//------------------------------------------------------------------------------
// fpga.v
//------------------------------------------------------------------------------
// VERSION: 2018.08.15.
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
`else
`endif
//------------------------------------------------------------------------------
// Revision history:
//
// 2018.08.15: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
