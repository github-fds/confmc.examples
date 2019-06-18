//------------------------------------------------------------------------------
//  Copyright (c) 2018 by Future Design Systems.
//  http://www.future-ds.com
//------------------------------------------------------------------------------
// aes128_axi.v
//------------------------------------------------------------------------------
// VERSION: 2018.05.01.
//------------------------------------------------------------------------------
`ifndef AMBA_AXI4
`define AMBA_AXI4
`endif
module aes128_axi
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     , input  wire [AXI_WIDTH_SID-1:0] AWID
     , input  wire [AXI_WIDTH_AD-1:0]  AWADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              AWLEN
     , input  wire                     AWLOCK
     `else
     , input  wire [ 3:0]              AWLEN
     , input  wire [ 1:0]              AWLOCK
     `endif
     , input  wire [ 2:0]              AWSIZE
     , input  wire [ 1:0]              AWBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              AWPROT
     `endif
     , input  wire                     AWVALID
     , output wire                     AWREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              AWQOS
     , input  wire [ 3:0]              AWREGION
     `endif
     , input  wire [AXI_WIDTH_SID-1:0] WID
     , input  wire [AXI_WIDTH_DA-1:0]  WDATA
     , input  wire [AXI_WIDTH_DS-1:0]  WSTRB
     , input  wire                     WLAST
     , input  wire                     WVALID
     , output wire                     WREADY
     , output wire [AXI_WIDTH_SID-1:0] BID
     , output wire [ 1:0]              BRESP
     , output wire                     BVALID
     , input  wire                     BREADY
     , input  wire [AXI_WIDTH_SID-1:0] ARID
     , input  wire [AXI_WIDTH_AD-1:0]  ARADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              ARLEN
     , input  wire                     ARLOCK
     `else
     , input  wire [ 3:0]              ARLEN
     , input  wire [ 1:0]              ARLOCK
     `endif
     , input  wire [ 2:0]              ARSIZE
     , input  wire [ 1:0]              ARBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              ARPROT
     `endif
     , input  wire                     ARVALID
     , output wire                     ARREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              ARQOS
     , input  wire [ 3:0]              ARREGION
     `endif
     , output wire [AXI_WIDTH_SID-1:0] RID
     , output wire [AXI_WIDTH_DA-1:0]  RDATA
     , output wire [ 1:0]              RRESP
     , output wire                     RLAST
     , output wire                     RVALID
     , input  wire                     RREADY
);
     parameter AXI_WIDTH_CID= 4 // Channel ID width in bits
             , AXI_WIDTH_ID = 4 // ID width in bits
             , AXI_WIDTH_AD =32 // address width
             , AXI_WIDTH_DA =32 // data width
             , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)  // data strobe width
             , AXI_WIDTH_DSB=4 // data strobe width
             , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID)
             , P_FIFO_DEPTH=512 // use 512 in order to support 256-beat burst
             ;
     //-------------------------------------------------------------------------
     // synthesis attribute box_type ase128_axi "black_box"
     //-------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.05.01: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
