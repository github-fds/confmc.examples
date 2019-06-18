`ifndef SIM_DEFINE_V
`define SIM_DEFINE_V
//-----------------------------------------------------------------------
`undef  SYN      // undefine this for simulation case
`undef  DEBUG
`define RIGOR
//-----------------------------------------------------------------------
`define XILINX
//-----------------------------------------------------------------------
// define board type: ML605, ZC706, SP605, VCU108, ZCU111
`undef  BOARD_SP605
`undef  BOARD_ML605
`undef  BOARD_VCU108
`undef  BOARD_ZC706
`undef  BOARD_ZC702
`define BOARD_ZED
`undef  BOARD_ZCU111

`ifdef  BOARD_ML605
`define FPGA_FAMILY     "VIRTEX6"
`define FPGA_TYPE       v6
`define ISE
`elsif  BOARD_SP605
`define FPGA_FAMILY     "SPARTAN6"
`define FPGA_TYPE       s6
`define ISE
`elsif  BOARD_VCU108
`define FPGA_FAMILY     "VirtexUS"
`define FPGA_TYPE       vus
`define VIVADO
`elsif  BOARD_ZC706
`define FPGA_FAMILY     "ZYNQ7000"
`define FPGA_TYPE       z7
`define VIVADO
`elsif  BOARD_ZC702
`define FPGA_FAMILY     "ZYNQ7000"
`define FPGA_TYPE       z7
`define VIVADO
`elsif  BOARD_ZED
`define FPGA_FAMILY     "ZYNQ7000"
`define FPGA_TYPE       z7
`define VIVADO
`elsif  BOARD_ZCU111
`define FPGA_FAMILY     "ZynqUSP"
`define FPGA_TYPE       zusp
`define VIVADO
`else
`error BOARD_??? not defined.
`endif
//-----------------------------------------------------------------------
`define AMBA_AXI4
//-----------------------------------------------------------------------
// Test case sel
//-----------------------------------------------------------------------
`undef  TEST_INFO
`undef  TEST_GPIN_OUT
`undef  TEST_SINGLE0
`undef  TEST_BURST1
`undef  TEST_BURST4
`undef  TEST_BURST8
`undef  TEST_BURST16
`undef  TEST_BURST_ALL
`undef  TEST_BURST_LONG
`undef  TEST_RAW
`undef  TEST_RAWA
`undef  TEST_RAWA2
`undef  TEST_ADD_RAW
`undef  XFFT_CONFIG
`undef  XFFT_RESET
`undef  XFFT_CSR
`undef  XFFT_SINGLE_PATTERN
`define XFFT_SINGLE_SIN
//-----------------------------------------------------------------------
`endif
