//------------------------------------------------------------------------------
//  Copyright (c) 2018 by Future Design Systems.
//  http://www.future-ds.com
//------------------------------------------------------------------------------
// bram_ahb.v
//------------------------------------------------------------------------------
// VERSION: 2018.06.27.
//------------------------------------------------------------------------------
// MACROS:
//        ENDIAN_BIG      - define if big-endian case
// PARAMETERS:
//        P_SIZE_IN_BYTES - size of memory in bytes
//------------------------------------------------------------------------------
`ifdef VIVADO
`ifdef SIM
`include "bram_simple_dual_port_32x8KB/bram_simple_dual_port_32x8KB_sim_netlist.v"
`include "bram_simple_dual_port_32x16KB/bram_simple_dual_port_32x16KB_sim_netlist.v"
`include "bram_simple_dual_port_32x32KB/bram_simple_dual_port_32x32KB_sim_netlist.v"
//`include "bram_simple_dual_port_32x64KB/bram_simple_dual_port_32x64KB_sim_netlist.v"
//`include "bram_simple_dual_port_32x128KB/bram_simple_dual_port_32x128KB_sim_netlist.v"
//`include "bram_simple_dual_port_32x256KB/bram_simple_dual_port_32x256KB_sim_netlist.v"
//`include "bram_simple_dual_port_32x512KB/bram_simple_dual_port_32x512KB_sim_netlist.v"
`else
`include "bram_simple_dual_port_32x8KB/bram_simple_dual_port_32x8KB_stub.v"
`include "bram_simple_dual_port_32x16KB/bram_simple_dual_port_32x16KB_stub.v"
`include "bram_simple_dual_port_32x32KB/bram_simple_dual_port_32x32KB_stub.v"
//`include "bram_simple_dual_port_32x64KB/bram_simple_dual_port_32x64KB_stub.v"
//`include "bram_simple_dual_port_32x128KB/bram_simple_dual_port_32x128KB_stub.v"
//`include "bram_simple_dual_port_32x256KB/bram_simple_dual_port_32x256KB_stub.v"
//`include "bram_simple_dual_port_32x512KB/bram_simple_dual_port_32x512KB_stub.v"
`endif
`else
`include "bram_simple_dual_port_32x8KB.v"
`include "bram_simple_dual_port_32x16KB.v"
`include "bram_simple_dual_port_32x32KB.v"
//`include "bram_simple_dual_port_32x64KB.v"
//`include "bram_simple_dual_port_32x128KB.v"
//`include "bram_simple_dual_port_32x256KB.v"
//`include "bram_simple_dual_port_32x512KB.v"
`endif

`ifdef VIVADO
`ifdef SYN
`define DBG_BRAM_AHB (* mark_debug="true" *)
`else
`define DBG_BRAM_AHB
`endif
`else
`define DBG_BRAM_AHB
`endif

module bram_ahb #(parameter P_SIZE_IN_BYTES=8*1024)
(
       input   wire         HRESETn
     , input   wire         HCLK
     , input   wire         HSEL
     , input   wire [31:0]  HADDR
     , input   wire [ 1:0]  HTRANS
     , input   wire         HWRITE
     , input   wire [ 2:0]  HSIZE
     , input   wire [ 2:0]  HBURST
     , input   wire [31:0]  HWDATA
     , output  reg  [31:0]  HRDATA
     , output  reg  [ 1:0]  HRESP=2'b0
     , input   wire         HREADYin
     , output  reg          HREADYout=1'b1
);
   //---------------------------------------------------------------------------
   localparam ADDR_LENGTH=clogb2(P_SIZE_IN_BYTES);
   //---------------------------------------------------------------------------
   reg  [ADDR_LENGTH-1:0] Twaddr={ADDR_LENGTH{1'b0}};
   reg                    Twen=1'b0;
   reg  [ 3:0]            Twstrb=4'h0;
   reg  [31:0]            Twdata;
   reg  [ADDR_LENGTH-1:0] Traddr;
   reg                    Tren;
   wire [31:0]            Trdata;
   //---------------------------------------------------------------------------
   always @ ( * ) begin
      Twdata = HWDATA;
      Traddr = HADDR[ADDR_LENGTH-1:0];
      Tren   = HSEL & HTRANS[1] & ~HWRITE & HREADYin;
      HRDATA = Trdata;
   end // always
   //---------------------------------------------------------------------------
   always @ (posedge HCLK or negedge HRESETn) begin
   if (HRESETn==0) begin
       Twaddr <= {ADDR_LENGTH{1'b0}};
       Twen   <= 1'b0;
       Twstrb <= 4'b0;
   end else begin
       Twaddr <= HADDR[ADDR_LENGTH-1:0];
       Twen   <= HSEL & HTRANS[1] & HWRITE & HREADYin;
       Twstrb <= byte_enable(HADDR[1:0], HSIZE, HWRITE);
   end // if
   end // always
   //---------------------------------------------------------------------------
   function [3:0] byte_enable;
       input [1:0] add;   // address offset
       input [2:0] size;  // transfer size
       input       wr;
       reg   [3:0] be;
       begin
          casex ({wr,size,add})
              `ifdef ENDIAN_BIG
              6'b1_010_00: be = 4'b1111; // word
              6'b1_001_00: be = 4'b1100; // halfword
              6'b1_001_10: be = 4'b0011; // halfword
              6'b1_000_00: be = 4'b1000; // byte
              6'b1_000_01: be = 4'b0100; // byte
              6'b1_000_10: be = 4'b0010; // byte
              6'b1_000_11: be = 4'b0001; // byte
              `else // little-endian -- default
              6'b1_010_00: be = 4'b1111; // word
              6'b1_001_00: be = 4'b0011; // halfword
              6'b1_001_10: be = 4'b1100; // halfword
              6'b1_000_00: be = 4'b0001; // byte
              6'b1_000_01: be = 4'b0010; // byte
              6'b1_000_10: be = 4'b0100; // byte
              6'b1_000_11: be = 4'b1000; // byte
              `endif
              6'b0_xxx_xx: be = 4'b0000;
              default: begin
                       be = 4'b0;
`ifdef RIGOR
// synopsys translate_off
$display($time,, "%m ERROR: undefined combination of HSIZE(%x) and HADDR[1:0](%x)",
                                    size, add);
// synopsys translate_on
`endif
                       end
          endcase
          byte_enable = be;
       end
   endfunction
   //---------------------------------------------------------------------------
   function integer clogb2;
   input [31:0] value;
   reg   [31:0] tmp;
   begin
      tmp = value - 1;
      for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1) tmp = tmp >> 1;
   end
   endfunction
   //---------------------------------------------------------------------------
   //         __    __    __    __    __    __
   // clk   _|  |__|  |__|  |__|  |__|  |__|  |__|
   //         _____       _____
   // en    _|     |_____|     |_______
   //         _____
   // we    _|     |____________________
   //         ______      ______
   // addr  XX__A___X----X__B___X--------
   //         ______
   // di    XX__DA__X--------------------
   //                           ______
   // do    -------------------X__DB__X--
   //
   //---------------------------------------------------------------------------
   `define BRAM_CON\
             .clka   ( HCLK   )\
           , .ena    ( Twen   )\
           , .addra  ( Twaddr[ADDR_LENGTH-1:2] )\
           , .wea    ( Twstrb )\
           , .dina   ( Twdata )\
           , .clkb   ( HCLK   )\
           , .enb    ( Tren   )\
           , .addrb  ( Traddr[ADDR_LENGTH-1:2] )\
           , .doutb  ( Trdata )
   //---------------------------------------------------------------------------
   generate
   if (P_SIZE_IN_BYTES==8*1024) begin : BLK_8KB
       bram_simple_dual_port_32x8KB u_bram( `BRAM_CON );
   end else if (P_SIZE_IN_BYTES==16*1024) begin : BLK_16KB
       bram_simple_dual_port_32x16KB u_bram( `BRAM_CON );
   end else if (P_SIZE_IN_BYTES==32*1024) begin : BLK_32KB
       bram_simple_dual_port_32x32KB u_bram( `BRAM_CON );
 //end else if (P_SIZE_IN_BYTES==64*1024) begin : BLK_64KB
 //    bram_simple_dual_port_32x64KB u_bram( `BRAM_CON );
 //end else if (P_SIZE_IN_BYTES==128*1024) begin : BLK_128KB
 //    bram_simple_dual_port_32x128KB u_bram( `BRAM_CON );
 //end else if (P_SIZE_IN_BYTES==256*1024) begin : BLK_256KB
 //    bram_simple_dual_port_32x256KB u_bram( `BRAM_CON );
 //end else if (P_SIZE_IN_BYTES==512*1024) begin : BLK_512KB
 //    bram_simple_dual_port_32x512KB u_bram( `BRAM_CON );
   end else begin
       // synthesis translate_off
       initial begin
           $display("%m ERROR %d-KByte not supported\n", P_SIZE_IN_BYTES);
           $stop;
       end
       // synthesis translate_on
   end
   endgenerate
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.27: VIVADo added
// 2018.06.24: 'bram_dual_port_...' ==> 'bram_simple_dual_port_...'
// 2018.04.28: Starting [adki]
//------------------------------------------------------------------------------
