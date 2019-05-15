`ifndef SIM_DEFINE_V
`define SIM_DEFINE_V
//-----------------------------------------------------------------------
// Copyright (c) 2017 by Ando Ki
// All rights reserved.
//
// This program is distributed in the hope that it
// will be useful to understand Ando Ki's work,
// BUT WITHOUT ANY WARRANTY.
//-----------------------------------------------------------------------
`define SIM      // define this for simulation case if you are not sure
`undef  SYN      // undefine this for simulation case
`define VCD      // define this for VCD waveform dump
`define DEBUG
`define RIGOR
//-----------------------------------------------------------------------
`define XILINX
//-----------------------------------------------------------------------
// define board type: ML605, ZC706, SP605, VCU108
`undef  SP605
`undef  ML605
`undef  VCU108
`undef  ZC706
`undef  ZC702
`define ZED

`ifdef  ML605
`define FPGA_FAMILY     "VIRTEX6"
`define ISE
`elsif  SP605
`define FPGA_FAMILY     "SPARTAN6"
`define ISE
`elsif  VCU108
`define FPGA_FAMILY     "VirtexUS"
`define VIVADO
`elsif ZC706
`define FPGA_FAMILY     "ZYNQ7000"
`define VIVADO
`elsif ZC702
`define FPGA_FAMILY     "ZYNQ7000"
`define VIVADO
`elsif ZED
`define FPGA_FAMILY     "ZYNQ7000"
`define VIVADO
`else
`define FPGA_FAMILY     "ARTIX7"
`define ISE
`endif
//-----------------------------------------------------------------------
// Set SYS_CLK (100Mhz) v.s. USR_CLK
`undef  TEST_CLK_MODE0 // USR_CLK(100)
`define TEST_CLK_MODE1 // USR_CLK(250)
`undef  TEST_CLK_MODE2 // USR_CLK( 50)
`undef  TEST_CLK_MODE3 // USR_CLK( 30)
//-----------------------------------------------------------------------
// HREADY delay in dut.mem_ahb_sim
`define MEM_DELAY 0
//-----------------------------------------------------------------------
// Test case sel
`define TEST_INFO      1
`define TEST_GPIN_OUT  1
`define TEST_SINGLE0   1
`define TEST_BURST1    1
`define TEST_BURST4    1
`define TEST_BURST8    1
`define TEST_BURST16   1
`define TEST_BURST_ALL 0
`define TEST_BURST_INC 0
`define TEST_ADD_RAW   0
//-----------------------------------------------------------------------
`define SIM_ALL
`define SL_PCLK_FREQ      80_000_000
`define PCLK_INV         1'b1
`define USR_CLK_FREQ      80_000_000
`define DEPTH_FIFO_CU2F  512 //64
`define DEPTH_FIFO_DU2F  512 //1024
`define DEPTH_FIFO_DF2U  512 //1024
`define DEPTH_FIFO       16384
`define MEM_SIZE        (8*1024)
//-----------------------------------------------------------------------
`endif
