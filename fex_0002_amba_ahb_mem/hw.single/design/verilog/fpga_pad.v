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
`ifdef VCU108
    wire USER_CLK_IN;
    IBUFGDS #(.DIFF_TERM("TRUE")) u_sys_clk_ds(.I  (USER_CLK_IN_P)
                                              ,.IB (USER_CLK_IN_N)
                                              ,.O  (USER_CLK_IN));
`elsif ZC706
    wire USER_CLK_IN;
    IBUFGDS #(.DIFF_TERM("TRUE")) u_sys_clk_ds(.I  (USER_CLK_IN_P)
                                              ,.IB (USER_CLK_IN_N)
                                              ,.O  (USER_CLK_IN));
`elsif ZC702
    wire USER_CLK_IN;
    IBUFGDS #(.DIFF_TERM("TRUE")) u_sys_clk_ds(.I  (USER_CLK_IN_P)
                                              ,.IB (USER_CLK_IN_N)
                                              ,.O  (USER_CLK_IN));
`else
`endif


`endif
