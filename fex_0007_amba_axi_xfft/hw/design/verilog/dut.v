//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems.
// All right reserved.
//------------------------------------------------------------------------------
// dut.v
//------------------------------------------------------------------------------
// VERSION: 2018.05.01.
//------------------------------------------------------------------------------
//  
// +---------+     +------+                                    +----------+
// |         |     |      |                                    |          |
// |         |     |      |                                    | Dual-port|
// |         |     |    S1|<==================================>| memory   |
// |         |     |      |                                    |          |
// | trx_axi |<===>| AMBA |                                    +----------+
// |         |     | AXI  |                                         ||
// |         |     | BUS  |     +----------+                   +----------+
// |         |     |      |     |          |                   |          |
// |         |     |      |     |        P1|<=================>|mem2stream|
// +---------+     |      |     |          |                   |          |
//                 |      |     |          |                   +----------+
//                 |      |     |          |                        ||
//                 |      |     |          |    +--------+     +----------+   
//                 |      |     |          |    |        |     |          |   
//                 |    S0|<===>|AXI2APB P0|<==>| CONFIG |<===>| xfft     |   
//                 |      |     |          |    |        |     |          |   
//                 |      |     |          |    +--------+     +----------+   
//                 |      |     |          |                        ||
//                 |      |     |          |                   +----------+   
//                 |      |     |          |                   |          |   
//                 |      |     |        P2|<=================>|stream2mem|   
//                 |      |     |          |                   |          |   
//                 |      |     +----------+                   +----------+
//                 |      |                                         ||
//                 |      |                                    +----------+                        
//                 |      |                                    |          |                        
//                 |    S2|<==================================>| Dual-port|                        
//                 |      |                                    | memory   |                        
//                 |      |                                    |          |                        
//                 +------+                                    +----------+
//------------------------------------------------------------------------------

module dut
     #(parameter SL_PCLK_FREQ   =80_000_000  // SL_PCLK frequency
               , SL_PCLK_INV    =1'b1 // SL_PCLK=~SYS_CLK when 1
               , FPGA_FAMILY    ="VIRTEX6" // SPARTAN6, VIRTEX4
               , P_ADDR_START_APB    =32'h0000_0000
               , P_ADDR_START_MEM_M2S=32'h1000_0000
               , P_ADDR_START_MEM_S2M=32'h2000_0000
               , P_SIZE_APB          =(1024*1024)
               , P_SIZE_MEM_M2S      =(16*1024)
               , P_SIZE_MEM_S2M      =(16*1024)
               , P_ADDR_START_CONFIG =32'h0000_0000
               , P_ADDR_START_M2S    =32'h0001_0000
               , P_ADDR_START_S2M    =32'h0002_0000
               , P_SIZE_CONFIG       =(2*1024)
               , P_SIZE_M2S          =(2*1024)
               , P_SIZE_S2M          =(2*1024)
               )
(
     input  wire                SYS_CLK_STABLE
   , input  wire                SYS_CLK   // master clock and goes to SL_PCLK
   , output wire                SYS_RST_N // by-pass of SL_RST_N
   , input  wire                SL_RST_N
   , output wire                SL_CS_N
   , output wire                SL_PCLK   // by-pass of SYS_CLK after phase shift
   , output wire [ 1:0]         SL_AD
   , input  wire                SL_FLAGA // active-low empty (U2F)
   , input  wire                SL_FLAGB // active-low almost-empty
   , input  wire                SL_FLAGC // active-low full (F2U)
   , input  wire                SL_FLAGD // active-low almost-full
   , output wire                SL_RD_N
   , output wire                SL_WR_N
   , output wire                SL_OE_N // when low, let FX3 drive data through SL_DT_I
   , output wire                SL_PKTEND_N
   , inout  wire [31:0]         SL_DT
   , input  wire [ 1:0]         SL_MODE
   , input  wire                USR_CLK
   , input  wire                SERIAL_CLK
);
   //---------------------------------------------------------------------------
   // synthesis attribute IOB of SL_DT is "TRUE";
   wire [31:0]  SL_DT_I;
   wire [31:0]  SL_DT_O;
   wire         SL_DT_T;
   assign SL_DT_I = SL_DT;
   assign SL_DT   = (SL_DT_T==1'b0) ? SL_DT_O : 32'hZ;
   //---------------------------------------------------------------------------
   parameter AXI_MST_ID   = 1;
   //--------------------------------------------
   `include "dut_axi_bus.v"
   `include "dut_apb_bus.v"
   `include "dut_axi_peri.v"
   //---------------------------------------------------------------------------
   function [31:0] clogb2;
   input [31:0] value;
   reg   [31:0] tmp;
   begin
      tmp = value - 1;
      for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1) tmp = tmp >> 1;
   end
   endfunction
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.05.01: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
