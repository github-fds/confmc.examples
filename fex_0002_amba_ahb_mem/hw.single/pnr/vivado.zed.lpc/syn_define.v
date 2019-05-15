`ifndef _SYN_DEFINE_V_
`define _SYN_DEFNE_V_

`undef  SIM
`define SYN
//-----------------------------------------------------------------------
`define XILINX
//-----------------------------------------------------------------------
// define board type: ML605, ZC706, SP605, VCU108
`undef  SP605
`undef  ML605
`undef  VCU108
`undef  ZC706
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
`elsif ZED
`define FPGA_FAMILY     "ZYNQ7000"
`define VIVADO
`else
`define FPGA_FAMILY     "ARTIX7"
`define ISE
`endif
//-----------------------------------------------------------------------
`define SL_PCLK_FREQ      80_000_000
`define PCLK_FREQ         80_000_000
`define PCLK_INV         1'b1
`define DEPTH_FIFO_CU2F  512 //64
`define DEPTH_FIFO_DU2F  512 //1024
`define DEPTH_FIFO_DF2U  512 //1024
`define MEM_SIZE        (8*1024)
//-----------------------------------------------------------------------

`endif
