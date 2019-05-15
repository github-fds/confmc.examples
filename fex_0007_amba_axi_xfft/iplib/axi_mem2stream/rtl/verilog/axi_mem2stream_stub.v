// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Sat May 11 12:33:02 2019
// Host        : AndoUbuntu running 64-bit Ubuntu 16.04.6 LTS
// Command     : write_verilog -force -mode synth_stub axi_mem2stream_stub.v
// Design      : axi_mem2stream
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module axi_mem2stream(ARESETn, ACLK, M_MID, M_AWID, M_AWADDR, M_AWLEN, 
  M_AWLOCK, M_AWSIZE, M_AWBURST, M_AWVALID, M_AWREADY, M_AWQOS, M_AWREGION, M_WID, M_WDATA, M_WSTRB, 
  M_WLAST, M_WVALID, M_WREADY, M_BID, M_BRESP, M_BVALID, M_BREADY, M_ARID, M_ARADDR, M_ARLEN, M_ARLOCK, 
  M_ARSIZE, M_ARBURST, M_ARVALID, M_ARREADY, M_ARQOS, M_ARREGION, M_RID, M_RDATA, M_RRESP, M_RLAST, 
  M_RVALID, M_RREADY, AXIS_CLK, AXIS_TREADY, AXIS_TVALID, AXIS_TDATA, AXIS_TSTRB, AXIS_TLAST, 
  AXIS_TSTART, PRESETn, PCLK, PSEL, PENABLE, PADDR, PWRITE, PRDATA, PWDATA, PREADY, PSLVERR, PSTRB, PPROT, 
  IRQ)
/* synthesis syn_black_box black_box_pad_pin="ARESETn,ACLK,M_MID[3:0],M_AWID[3:0],M_AWADDR[31:0],M_AWLEN[7:0],M_AWLOCK,M_AWSIZE[2:0],M_AWBURST[1:0],M_AWVALID,M_AWREADY,M_AWQOS[3:0],M_AWREGION[3:0],M_WID[3:0],M_WDATA[31:0],M_WSTRB[3:0],M_WLAST,M_WVALID,M_WREADY,M_BID[3:0],M_BRESP[1:0],M_BVALID,M_BREADY,M_ARID[3:0],M_ARADDR[31:0],M_ARLEN[7:0],M_ARLOCK,M_ARSIZE[2:0],M_ARBURST[1:0],M_ARVALID,M_ARREADY,M_ARQOS[3:0],M_ARREGION[3:0],M_RID[3:0],M_RDATA[31:0],M_RRESP[1:0],M_RLAST,M_RVALID,M_RREADY,AXIS_CLK,AXIS_TREADY,AXIS_TVALID,AXIS_TDATA[31:0],AXIS_TSTRB[3:0],AXIS_TLAST,AXIS_TSTART,PRESETn,PCLK,PSEL,PENABLE,PADDR[31:0],PWRITE,PRDATA[31:0],PWDATA[31:0],PREADY,PSLVERR,PSTRB[3:0],PPROT[2:0],IRQ" */;
  input ARESETn;
  input ACLK;
  output [3:0]M_MID;
  output [3:0]M_AWID;
  output [31:0]M_AWADDR;
  output [7:0]M_AWLEN;
  output M_AWLOCK;
  output [2:0]M_AWSIZE;
  output [1:0]M_AWBURST;
  output M_AWVALID;
  input M_AWREADY;
  output [3:0]M_AWQOS;
  output [3:0]M_AWREGION;
  output [3:0]M_WID;
  output [31:0]M_WDATA;
  output [3:0]M_WSTRB;
  output M_WLAST;
  output M_WVALID;
  input M_WREADY;
  input [3:0]M_BID;
  input [1:0]M_BRESP;
  input M_BVALID;
  output M_BREADY;
  output [3:0]M_ARID;
  output [31:0]M_ARADDR;
  output [7:0]M_ARLEN;
  output M_ARLOCK;
  output [2:0]M_ARSIZE;
  output [1:0]M_ARBURST;
  output M_ARVALID;
  input M_ARREADY;
  output [3:0]M_ARQOS;
  output [3:0]M_ARREGION;
  input [3:0]M_RID;
  input [31:0]M_RDATA;
  input [1:0]M_RRESP;
  input M_RLAST;
  input M_RVALID;
  output M_RREADY;
  input AXIS_CLK;
  input AXIS_TREADY;
  output AXIS_TVALID;
  output [31:0]AXIS_TDATA;
  output [3:0]AXIS_TSTRB;
  output AXIS_TLAST;
  output AXIS_TSTART;
  input PRESETn;
  input PCLK;
  input PSEL;
  input PENABLE;
  input [31:0]PADDR;
  input PWRITE;
  output [31:0]PRDATA;
  input [31:0]PWDATA;
  output PREADY;
  output PSLVERR;
  input [3:0]PSTRB;
  input [2:0]PPROT;
  output IRQ;
endmodule
