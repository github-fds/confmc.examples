`ifndef SIM_DEFINE_V
`define SIM_DEFINE_V
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
`undef  BOARD_SP605
`undef  BOARD_ML605
`undef  BOARD_VCU108
`undef  BOARD_ZC706
`undef  BOARD_ZC702
`undef  BOARD_ZED
`define BOARD_ZCU111

`ifdef  BOARD_ML605
`define FPGA_FAMILY     "VIRTEX6"
`define ISE
`elsif  BOARD_SP605
`define FPGA_FAMILY     "SPARTAN6"
`define ISE
`elsif  BOARD_VCU108
`define FPGA_FAMILY     "VirtexUS"
`define VIVADO
`elsif  BOARD_ZC706
`define FPGA_FAMILY     "ZYNQ7000"
`define VIVADO
`elsif  BOARD_ZC702
`define FPGA_FAMILY     "ZYNQ7000"
`define VIVADO
`elsif  BOARD_ZED
`define FPGA_FAMILY     "ZYNQ7000"
`define VIVADO
`elsif  BOARD_ZCU111
`define FPGA_FAMILY     "ZynqUSP"
`define VIVADO
`else
`define FPGA_FAMILY     "ARTIX7"
`define ISE
`endif
//-----------------------------------------------------------------------
// Set SYS_CLK (100Mhz) v.s. USR_CLK
`define TEST_CLK_MODE0 // USR_CLK(100)
`undef  TEST_CLK_MODE1 // USR_CLK(250)
`undef  TEST_CLK_MODE2 // USR_CLK( 50)
`undef  TEST_CLK_MODE3 // USR_CLK( 30)
//-----------------------------------------------------------------------
`define AMBA_AXI4
//-----------------------------------------------------------------------
// Test case sel
`define TEST_INFO       0
`define TEST_GPIN_OUT   0
`define TEST_AES_CSR    0
`define TEST_AES_KEY    0
`define TEST_AES_KAT    1 // it takes long time
        `define KAT_NUM 3
`define TEST_AES_ALL    0
//-----------------------------------------------------------------------
`endif
