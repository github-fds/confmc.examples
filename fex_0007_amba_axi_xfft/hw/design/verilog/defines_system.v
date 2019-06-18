`ifndef DEFINES_SYSTEM_V
`define DEFINES_SYSTEM_V
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// defines_system.v
//------------------------------------------------------------------------------
// VERSION: 2018.02.05.
//------------------------------------------------------------------------------
// define board type:
//`define BOARD_ML605
//`define BOARD_SP605
//`define BOARD_VCU108
//`devine BOARD_ZCU111

//------------------------------------------------------------------------------
`ifdef SIM
`include "sim_define.v"
`elsif SYN
`include "syn_define.v"
`endif

//------------------------------------------------------------------------------
`ifdef  ISE
`define IOB_DEF
`define DBG_DUT

`elsif  VIVADO
`define IOB_DEF        (* IOB="true" *)
`define DBG_DUT        (* mark_debug="true" *)

`endif

//------------------------------------------------------------------------------
`define AMBA_AXI4
`define AMBA_APB3
`define AMBA_APB4

//------------------------------------------------------------------------------
`ifndef SIZE_BRAM_MEM
`define SIZE_BRAM_MEM (16*1024)
`endif

`ifndef SIZE_PERI
`define SIZE_PERI (2*1024)
`endif

//------------------------------------------------------------------------------
`define ADDR_START_APB      32'h0000_0000
`define ADDR_START_MEM_M2S  32'h1000_0000
`define ADDR_START_MEM_S2M  32'h2000_0000

`define ADDR_SIZE_APB       (1024*1024)
`define ADDR_SIZE_MEM_M2S  `SIZE_BRAM_MEM
`define ADDR_SIZE_MEM_S2M  `SIZE_BRAM_MEM

`define ADDR_START_CONFIG   (`ADDR_START_APB+32'h0000_0000)
`define ADDR_START_M2S      (`ADDR_START_APB+32'h0001_0000)
`define ADDR_START_S2M      (`ADDR_START_APB+32'h0002_0000)

`define ADDR_SIZE_CONFIG   `SIZE_PERI
`define ADDR_SIZE_M2S      `SIZE_PERI
`define ADDR_SIZE_S2M      `SIZE_PERI

//------------------------------------------------------------------------------
// Revision history:
//
// 2018.02.05: Prepared by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
`endif
