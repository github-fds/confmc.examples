`ifndef SYN_DEFINE_V
`define SYN_DEFINE_V

`undef  SIM
`define SYN
//-----------------------------------------------------------------------
`define XILINX
//-----------------------------------------------------------------------
// define board type: ML605, ZC706, SP605, VCU108
`undef  BOARD_SP605
`define BOARD_ML605
`undef  BOARD_VCU108
`undef  BOARD_ZC706

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
`else
`define FPGA_FAMILY     "ARTIX7"
`define ISE
`endif

//-----------------------------------------------------------------------
`define AMBA_AXI4
//-----------------------------------------------------------------------
`define SL_PCLK_FREQ      80_000_000
`define USR_CLK_FREQ      80_000_000
`define PCLK_INV         1'b1
`define DEPTH_FIFO_CU2F  512 // 64
`define DEPTH_FIFO_DU2F  512 // 1024
`define DEPTH_FIFO_DF2U  512 // 1024
`define MEM_SIZE        (512*1024)
//-----------------------------------------------------------------------
`endif
