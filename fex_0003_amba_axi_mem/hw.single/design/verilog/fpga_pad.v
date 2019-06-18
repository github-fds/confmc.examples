`ifndef FPGA_PAD_V
`define FPGA_PAD_V
//------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved
//
// http://www.future-ds.com
//------------------------------------------------------
// fpga_pad.v
//------------------------------------------------------
// VERSION: 2018.02.05.
//------------------------------------------------------

//------------------------------------------------------
// Revision history:
//
// 2018.02.05: Started by Ando Ki.
//------------------------------------------------------
`ifdef BOARD_VCU108
    wire BOARD_CLK_IN;
    IBUFGDS #(.DIFF_TERM("TRUE")) u_sys_clk_ds(.I  (BOARD_CLK_IN_P)
                                              ,.IB (BOARD_CLK_IN_N)
                                              ,.O  (BOARD_CLK_IN));
`elsif BOARD_ZC706
    wire BOARD_CLK_IN;
    IBUFGDS #(.DIFF_TERM("TRUE")) u_sys_clk_ds(.I  (BOARD_CLK_IN_P)
                                              ,.IB (BOARD_CLK_IN_N)
                                              ,.O  (BOARD_CLK_IN));
`elsif BOARD_ZC702
    wire BOARD_CLK_IN;
    IBUFGDS #(.DIFF_TERM("TRUE")) u_sys_clk_ds(.I  (BOARD_CLK_IN_P)
                                              ,.IB (BOARD_CLK_IN_N)
                                              ,.O  (BOARD_CLK_IN));
`elsif BOARD_ZCU111
    wire BOARD_CLK_IN;
    IBUFGDS #(.DIFF_TERM("TRUE")) u_sys_clk_ds(.I  (BOARD_CLK_IN_P)
                                              ,.IB (BOARD_CLK_IN_N)
                                              ,.O  (BOARD_CLK_IN));
`else
`endif


`endif
