//------------------------------------------------------------------------------
//  Copyright (c) 2018 by Future Design Systems.
//  http://www.future-ds.com
//------------------------------------------------------------------------------
// bram_axi.v
//------------------------------------------------------------------------------
// VERSION: 2018.06.12.
//------------------------------------------------------------------------------
// MACROS:
//    AMBA_AXI4                  - AMBA AXI4
//    BURST_TYPE_WRAPP_ENABLED   - Burst wrapping type enabled
// PARAMETERS:
//    P_SIZE_IN_BYTES - size of memory in bytes
//------------------------------------------------------------------------------
`ifdef VIVADO
`ifdef SIM
`include "bram_true_dual_port_32x16KB/bram_true_dual_port_32x16KB_sim_netlist.v"
`include "bram_true_dual_port_32x32KB/bram_true_dual_port_32x32KB_sim_netlist.v"
`include "bram_true_dual_port_32x64KB/bram_true_dual_port_32x64KB_sim_netlist.v"
`else
`include "bram_true_dual_port_32x16KB/bram_true_dual_port_32x16KB_stub.v"
`include "bram_true_dual_port_32x32KB/bram_true_dual_port_32x32KB_stub.v"
`include "bram_true_dual_port_32x64KB/bram_true_dual_port_32x64KB_stub.v"
`endif
`else
//`include "bram_true_dual_port_32x16KB.v"
//`include "bram_true_dual_port_32x32KB.v"
//`include "bram_true_dual_port_32x64KB.v"
`endif

module bram_axi_dual
     #(parameter AXI_WIDTH_CID= 4 // Channel ID width in bits
               , AXI_WIDTH_ID = 4 // ID width in bits
               , AXI_WIDTH_AD =32 // address width
               , AXI_WIDTH_DA =32 // data width
               , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)  // data strobe width
               , AXI_WIDTH_DSB=clogb2(AXI_WIDTH_DS) // data strobe width
               , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID)
               , P_SIZE_IN_BYTES=1024
               )
(
       input  wire                     ARESETn
     , input  wire                     ACLK
     , input  wire [AXI_WIDTH_SID-1:0] S0_AWID
     , input  wire [AXI_WIDTH_AD-1:0]  S0_AWADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              S0_AWLEN
     , input  wire                     S0_AWLOCK
     `else
     , input  wire [ 3:0]              S0_AWLEN
     , input  wire [ 1:0]              S0_AWLOCK
     `endif
     , input  wire [ 2:0]              S0_AWSIZE
     , input  wire [ 1:0]              S0_AWBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              S0_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              S0_AWPROT
     `endif
     , input  wire                     S0_AWVALID
     , output wire                     S0_AWREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              S0_AWQOS
     , input  wire [ 3:0]              S0_AWREGION
     `endif
     , input  wire [AXI_WIDTH_SID-1:0] S0_WID
     , input  wire [AXI_WIDTH_DA-1:0]  S0_WDATA
     , input  wire [AXI_WIDTH_DS-1:0]  S0_WSTRB
     , input  wire                     S0_WLAST
     , input  wire                     S0_WVALID
     , output wire                     S0_WREADY
     , output wire [AXI_WIDTH_SID-1:0] S0_BID
     , output wire [ 1:0]              S0_BRESP
     , output wire                     S0_BVALID
     , input  wire                     S0_BREADY
     , input  wire [AXI_WIDTH_SID-1:0] S0_ARID
     , input  wire [AXI_WIDTH_AD-1:0]  S0_ARADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              S0_ARLEN
     , input  wire                     S0_ARLOCK
     `else
     , input  wire [ 3:0]              S0_ARLEN
     , input  wire [ 1:0]              S0_ARLOCK
     `endif
     , input  wire [ 2:0]              S0_ARSIZE
     , input  wire [ 1:0]              S0_ARBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              S0_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              S0_ARPROT
     `endif
     , input  wire                     S0_ARVALID
     , output wire                     S0_ARREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              S0_ARQOS
     , input  wire [ 3:0]              S0_ARREGION
     `endif
     , output wire [AXI_WIDTH_SID-1:0] S0_RID
     , output wire [AXI_WIDTH_DA-1:0]  S0_RDATA
     , output wire [ 1:0]              S0_RRESP
     , output wire                     S0_RLAST
     , output wire                     S0_RVALID
     , input  wire                     S0_RREADY
     , input  wire [AXI_WIDTH_SID-1:0] S1_AWID
     , input  wire [AXI_WIDTH_AD-1:0]  S1_AWADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              S1_AWLEN
     , input  wire                     S1_AWLOCK
     `else
     , input  wire [ 3:0]              S1_AWLEN
     , input  wire [ 1:0]              S1_AWLOCK
     `endif
     , input  wire [ 2:0]              S1_AWSIZE
     , input  wire [ 1:0]              S1_AWBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              S1_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              S1_AWPROT
     `endif
     , input  wire                     S1_AWVALID
     , output wire                     S1_AWREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              S1_AWQOS
     , input  wire [ 3:0]              S1_AWREGION
     `endif
     , input  wire [AXI_WIDTH_SID-1:0] S1_WID
     , input  wire [AXI_WIDTH_DA-1:0]  S1_WDATA
     , input  wire [AXI_WIDTH_DS-1:0]  S1_WSTRB
     , input  wire                     S1_WLAST
     , input  wire                     S1_WVALID
     , output wire                     S1_WREADY
     , output wire [AXI_WIDTH_SID-1:0] S1_BID
     , output wire [ 1:0]              S1_BRESP
     , output wire                     S1_BVALID
     , input  wire                     S1_BREADY
     , input  wire [AXI_WIDTH_SID-1:0] S1_ARID
     , input  wire [AXI_WIDTH_AD-1:0]  S1_ARADDR
     `ifdef AMBA_AXI4
     , input  wire [ 7:0]              S1_ARLEN
     , input  wire                     S1_ARLOCK
     `else
     , input  wire [ 3:0]              S1_ARLEN
     , input  wire [ 1:0]              S1_ARLOCK
     `endif
     , input  wire [ 2:0]              S1_ARSIZE
     , input  wire [ 1:0]              S1_ARBURST
     `ifdef AMBA_AXI_CACHE
     , input  wire [ 3:0]              S1_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input  wire [ 2:0]              S1_ARPROT
     `endif
     , input  wire                     S1_ARVALID
     , output wire                     S1_ARREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              S1_ARQOS
     , input  wire [ 3:0]              S1_ARREGION
     `endif
     , output wire [AXI_WIDTH_SID-1:0] S1_RID
     , output wire [AXI_WIDTH_DA-1:0]  S1_RDATA
     , output wire [ 1:0]              S1_RRESP
     , output wire                     S1_RLAST
     , output wire                     S1_RVALID
     , input  wire                     S1_RREADY
);
     //-------------------------------------------------------------------------
     localparam ADDR_LENGTH=clogb2(P_SIZE_IN_BYTES);
     //-------------------------------------------------------------------------
     // sysnthesis attribute keep of TAwdata is "true";
     // sysnthesis attribute keep of TArdata is "true";
     // sysnthesis attribute keep of TAwstrb is "true";
     // sysnthesis attribute keep of TAwen   is "true";
     // sysnthesis attribute keep of TAren   is "true";
     wire [ADDR_LENGTH-1:0]  TAaddr ,TBaddr;
     wire [AXI_WIDTH_DA-1:0] TAwdata,TBwdata;
     wire [AXI_WIDTH_DS-1:0] TAwstrb,TBwstrb;
     wire                    TAwen  ,TBwen  ;
     wire [AXI_WIDTH_DA-1:0] TArdata,TBrdata;
     wire [AXI_WIDTH_DS-1:0] TArstrb,TBrstrb;
     wire                    TAren  ,TBren  ; // driven by stateR
     //-------------------------------------------------------------------------
     bram_axi_if #(.AXI_WIDTH_CID  (AXI_WIDTH_CID  )// Channel ID width in bits
                  ,.AXI_WIDTH_ID   (AXI_WIDTH_ID   )// ID width in bits
                  ,.AXI_WIDTH_AD   (AXI_WIDTH_AD   )// address width
                  ,.AXI_WIDTH_DA   (AXI_WIDTH_DA   )// data width
                  ,.P_SIZE_IN_BYTES(P_SIZE_IN_BYTES)
                  )
     u_axi_ifA (
            .ARESETn            ( ARESETn               )
          , .ACLK               ( ACLK                  )
          , .AWID               ( S0_AWID               )
          , .AWADDR             ( S0_AWADDR             )
          `ifdef AMBA_AXI4
          , .AWLEN              ( S0_AWLEN              )
          , .AWLOCK             ( S0_AWLOCK             )
          `else
          , .AWLEN              ( S0_AWLEN              )
          , .AWLOCK             ( S0_AWLOCK             )
          `endif
          , .AWSIZE             ( S0_AWSIZE             )
          , .AWBURST            ( S0_AWBURST            )
          `ifdef AMBA_AXI_CACHE
          , .AWCACHE            ( S0_AWCACHE            )
          `endif
          `ifdef AMBA_AXI_PROT
          , .AWPROT             ( S0_AWPROT             )
          `endif
          , .AWVALID            ( S0_AWVALID            )
          , .AWREADY            ( S0_AWREADY            )
          `ifdef AMBA_AXI4
          , .AWQOS              ( S0_AWQOS              )
          , .AWREGION           ( S0_AWREGION           )
          `endif
          , .WID                ( S0_WID                )
          , .WDATA              ( S0_WDATA              )
          , .WSTRB              ( S0_WSTRB              )
          , .WLAST              ( S0_WLAST              )
          , .WVALID             ( S0_WVALID             )
          , .WREADY             ( S0_WREADY             )
          , .BID                ( S0_BID                )
          , .BRESP              ( S0_BRESP              )
          , .BVALID             ( S0_BVALID             )
          , .BREADY             ( S0_BREADY             )
          , .ARID               ( S0_ARID               )
          , .ARADDR             ( S0_ARADDR             )
          `ifdef AMBA_AXI4
          , .ARLEN              ( S0_ARLEN              )
          , .ARLOCK             ( S0_ARLOCK             )
          `else
          , .ARLEN              ( S0_ARLEN              )
          , .ARLOCK             ( S0_ARLOCK             )
          `endif
          , .ARSIZE             ( S0_ARSIZE             )
          , .ARBURST            ( S0_ARBURST            )
          `ifdef AMBA_AXI_CACHE
          , .ARCACHE            ( S0_ARCACHE            )
          `endif
          `ifdef AMBA_AXI_PROT
          , .ARPROT             ( S0_ARPROT             )
          `endif
          , .ARVALID            ( S0_ARVALID            )
          , .ARREADY            ( S0_ARREADY            )
          `ifdef AMBA_AXI4
          , .ARQOS              ( S0_ARQOS              )
          , .ARREGION           ( S0_ARREGION           )
          `endif
          , .RID                ( S0_RID                )
          , .RDATA              ( S0_RDATA              )
          , .RRESP              ( S0_RRESP              )
          , .RLAST              ( S0_RLAST              )
          , .RVALID             ( S0_RVALID             )
          , .RREADY             ( S0_RREADY             )
          , .Taddr              ( TAaddr                )
          , .Twdata             ( TAwdata               )
          , .Twstrb             ( TAwstrb               )
          , .Twen               ( TAwen                 )
          , .Trdata             ( TArdata               )
          , .Trstrb             ( TArstrb               )
          , .Tren               ( TAren                 )
     );
     //-------------------------------------------------------------------------
     bram_axi_if #(.AXI_WIDTH_CID  (AXI_WIDTH_CID  )// Channel ID width in bits
                  ,.AXI_WIDTH_ID   (AXI_WIDTH_ID   )// ID width in bits
                  ,.AXI_WIDTH_AD   (AXI_WIDTH_AD   )// address width
                  ,.AXI_WIDTH_DA   (AXI_WIDTH_DA   )// data width
                  ,.P_SIZE_IN_BYTES(P_SIZE_IN_BYTES)
                  )
     u_axi_ifB (
            .ARESETn            ( ARESETn               )
          , .ACLK               ( ACLK                  )
          , .AWID               ( S1_AWID               )
          , .AWADDR             ( S1_AWADDR             )
          `ifdef AMBA_AXI4
          , .AWLEN              ( S1_AWLEN              )
          , .AWLOCK             ( S1_AWLOCK             )
          `else
          , .AWLEN              ( S1_AWLEN              )
          , .AWLOCK             ( S1_AWLOCK             )
          `endif
          , .AWSIZE             ( S1_AWSIZE             )
          , .AWBURST            ( S1_AWBURST            )
          `ifdef AMBA_AXI_CACHE
          , .AWCACHE            ( S1_AWCACHE            )
          `endif
          `ifdef AMBA_AXI_PROT
          , .AWPROT             ( S1_AWPROT             )
          `endif
          , .AWVALID            ( S1_AWVALID            )
          , .AWREADY            ( S1_AWREADY            )
          `ifdef AMBA_AXI4
          , .AWQOS              ( S1_AWQOS              )
          , .AWREGION           ( S1_AWREGION           )
          `endif
          , .WID                ( S1_WID                )
          , .WDATA              ( S1_WDATA              )
          , .WSTRB              ( S1_WSTRB              )
          , .WLAST              ( S1_WLAST              )
          , .WVALID             ( S1_WVALID             )
          , .WREADY             ( S1_WREADY             )
          , .BID                ( S1_BID                )
          , .BRESP              ( S1_BRESP              )
          , .BVALID             ( S1_BVALID             )
          , .BREADY             ( S1_BREADY             )
          , .ARID               ( S1_ARID               )
          , .ARADDR             ( S1_ARADDR             )
          `ifdef AMBA_AXI4
          , .ARLEN              ( S1_ARLEN              )
          , .ARLOCK             ( S1_ARLOCK             )
          `else
          , .ARLEN              ( S1_ARLEN              )
          , .ARLOCK             ( S1_ARLOCK             )
          `endif
          , .ARSIZE             ( S1_ARSIZE             )
          , .ARBURST            ( S1_ARBURST            )
          `ifdef AMBA_AXI_CACHE
          , .ARCACHE            ( S1_ARCACHE            )
          `endif
          `ifdef AMBA_AXI_PROT
          , .ARPROT             ( S1_ARPROT             )
          `endif
          , .ARVALID            ( S1_ARVALID            )
          , .ARREADY            ( S1_ARREADY            )
          `ifdef AMBA_AXI4
          , .ARQOS              ( S1_ARQOS              )
          , .ARREGION           ( S1_ARREGION           )
          `endif
          , .RID                ( S1_RID                )
          , .RDATA              ( S1_RDATA              )
          , .RRESP              ( S1_RRESP              )
          , .RLAST              ( S1_RLAST              )
          , .RVALID             ( S1_RVALID             )
          , .RREADY             ( S1_RREADY             )
          , .Taddr              ( TBaddr                )
          , .Twdata             ( TBwdata               )
          , .Twstrb             ( TBwstrb               )
          , .Twen               ( TBwen                 )
          , .Trdata             ( TBrdata               )
          , .Trstrb             ( TBrstrb               )
          , .Tren               ( TBren                 )
     );
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
     //-------------------------------------------------------------------------
   // synthesis attribute keep of TAen is "true";
   // synthesis attribute keep of TAwr is "true";
   // synthesis attribute keep of TBen is "true";
   // synthesis attribute keep of TBwr is "true";
   wire       TAen = TAren|TAwen;
   wire [3:0] TAwr = {4{TAwen}}&TAwstrb;
   wire       TBen = TBren|TBwen;
   wire [3:0] TBwr = {4{TBwen}}&TBwstrb;
     //-------------------------------------------------------------------------
   `define PORT_CON\
             .clka   ( ACLK   )\
           , .ena    ( TAen   )\
           , .wea    ( TAwr   )\
           , .addra  ( TAaddr[ADDR_LENGTH-1:2] )\
           , .dina   ( TAwdata)\
           , .douta  ( TArdata)\
           , .clkb   ( ACLK   )\
           , .enb    ( TBen   )\
           , .web    ( TBwr   )\
           , .addrb  ( TBaddr[ADDR_LENGTH-1:2] )\
           , .dinb   ( TBwdata)\
           , .doutb  ( TBrdata)
   generate
            if (P_SIZE_IN_BYTES==16*1024) begin : BLK_16KB
       bram_true_dual_port_32x16KB u_bram(
            `PORT_CON
       );
   end else if (P_SIZE_IN_BYTES==32*1024) begin : BLK_32KB
       bram_true_dual_port_32x32KB u_bram(
            `PORT_CON
       );
   end else if (P_SIZE_IN_BYTES==64*1024) begin : BLK_64KB
       bram_true_dual_port_32x64KB u_bram(
            `PORT_CON
       );
   end else begin
       // synthesis translate_off
       initial begin
           $display("%m ERROR %d-KByte not supported\n", P_SIZE_IN_BYTES);
           $stop;
       end
       // synthesis translate_on
   end
   endgenerate
     //-------------------------------------------------------------------------
     function integer clogb2;
     input [31:0] value;
     reg   [31:0] tmp;
     begin
        tmp = value - 1;
        for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1) tmp = tmp >> 1;
     end
     endfunction
     //-------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
module bram_axi_if
     #(parameter AXI_WIDTH_CID= 4 // Channel ID width in bits
               , AXI_WIDTH_ID = 4 // ID width in bits
               , AXI_WIDTH_AD =32 // address width
               , AXI_WIDTH_DA =32 // data width
               , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)  // data strobe width
               , AXI_WIDTH_DSB=clogb2(AXI_WIDTH_DS) // data strobe width
               , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID)
               , P_SIZE_IN_BYTES=1024
               , ADDR_LENGTH=clogb2(P_SIZE_IN_BYTES)
               )
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
     , output reg                      AWREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              AWQOS
     , input  wire [ 3:0]              AWREGION
     `endif
     , input  wire [AXI_WIDTH_SID-1:0] WID
     , input  wire [AXI_WIDTH_DA-1:0]  WDATA
     , input  wire [AXI_WIDTH_DS-1:0]  WSTRB
     , input  wire                     WLAST
     , input  wire                     WVALID
     , output reg                      WREADY
     , output reg  [AXI_WIDTH_SID-1:0] BID
     , output reg  [ 1:0]              BRESP
     , output reg                      BVALID
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
     , output reg                      ARREADY
     `ifdef AMBA_AXI4
     , input  wire [ 3:0]              ARQOS
     , input  wire [ 3:0]              ARREGION
     `endif
     , output reg  [AXI_WIDTH_SID-1:0] RID
     , output reg  [AXI_WIDTH_DA-1:0]  RDATA
     , output reg  [ 1:0]              RRESP
     , output reg                      RLAST
     , output reg                      RVALID
     , input  wire                     RREADY
     , output wire [ADDR_LENGTH-1:0]   Taddr
     , output reg  [AXI_WIDTH_DA-1:0]  Twdata='h0
     , output reg  [AXI_WIDTH_DS-1:0]  Twstrb='h0
     , output reg                      Twen=1'b0
     , input  wire [AXI_WIDTH_DA-1:0]  Trdata
     , output reg  [AXI_WIDTH_DS-1:0]  Trstrb='h0
     , output reg                      Tren=1'b0 // driven by stateR
);
     //-------------------------------------------------------------------------
     reg  trans_wr=1'b0;
     reg  trans_rd=1'b0;
     // synthesis translate_off
     always @ (posedge ACLK) if (trans_wr&trans_rd) $display("%t %m ERROR", $time);
     // synthesis translate_on
     //-------------------------------------------------------------------------
     // write case
     //-------------------------------------------------------------------------
     reg  [AXI_WIDTH_SID-1:0] AWID_reg   ;
     reg  [AXI_WIDTH_AD-1:0]  AWADDR_reg ;
     `ifdef AMBA_AXI4
     reg  [ 7:0]              AWLEN_reg  ;
     reg                      AWLOCK_reg ;
     `else
     reg  [ 3:0]              AWLEN_reg  ;
     reg  [ 1:0]              AWLOCK_reg ;
     `endif
     reg  [ 2:0]              AWSIZE_reg ;
     reg  [ 1:0]              AWBURST_reg;
     reg  [ 3:0]              AWCACHE_reg;
     reg  [ 2:0]              AWPROT_reg ;
     //-------------------------------------------------------------------------
     reg  [ADDR_LENGTH-1:0]   Traddr='h0;
     reg  [ADDR_LENGTH-1:0]   Twaddr='h0;
     assign Taddr = (trans_wr==1'b1) ? Twaddr : Traddr;
     //-------------------------------------------------------------------------
     reg  [ADDR_LENGTH-1:0] addrW; // address of each transfer within a burst
     `ifdef AMBA_AXI4
     reg  [ 7:0]            beatW; // keeps num of transfers within a burst
     `else
     reg  [ 3:0]            beatW; // keeps num of transfers within a burst
     `endif
     //-------------------------------------------------------------------------
     localparam STW_READY  = 'h0,
                STW_ARB    = 'h1,
                STW_WRITE0 = 'h2,
                STW_WRITE  = 'h3,
                STW_RSP    = 'h4;
     reg [2:0] stateW=STW_READY; // synthesis attribute keep of stateW is "true";
     always @ (posedge ACLK or negedge ARESETn) begin
     if (ARESETn==1'b0) begin
         AWID_reg    <= 'h0;
         AWADDR_reg  <= 'h0;
         AWLEN_reg   <= 'h0;
         AWSIZE_reg  <= 'b0;
         AWBURST_reg <= 'b0;
         AWLOCK_reg  <= 'b0;
         AWCACHE_reg <= 'h0;
         AWPROT_reg  <= 'b0;
         AWREADY     <= 1'b0;
         WREADY      <= 1'b0;
         BID         <=  'h0;
         BRESP       <= 2'b10; // SLAVE ERROR
         BVALID      <= 1'b0;
         addrW       <=  'h0;
         beatW       <=  'h0;
         Twaddr      <=  'h0;
         Twdata      <=  'h0;
         Twstrb      <=  'h0;
         Twen        <= 1'b0;
         trans_wr    <= 1'b0;
         stateW      <= STW_READY;
     end else begin
         case (stateW)
         STW_READY: begin
             trans_wr <= 1'b0;
             if ((AWVALID==1'b1)&&(AWREADY==1'b1)) begin
                  AWID_reg    <= AWID   ;
                  AWADDR_reg  <= AWADDR ;
                  AWLEN_reg   <= AWLEN  ;
                  AWSIZE_reg  <= AWSIZE ;
                  AWBURST_reg <= AWBURST;
                  AWLOCK_reg  <= AWLOCK ;
                  `ifdef AMBA_AXI_CACHE
                  AWCACHE_reg <= AWCACHE;
                  `else
                  AWCACHE_reg <= 'h0;
                  `endif
                  `ifdef AMBA_AXI_PROT
                  AWPROT_reg  <= AWPROT ;
                  `else
                  AWPROT_reg  <= 'h0;
                  `endif
                  AWREADY     <= 1'b0;
                  WREADY      <= 1'b1;
                  BRESP       <= 2'b00; // OKAY
                  addrW       <= AWADDR[ADDR_LENGTH-1:0];
                  beatW       <=  'h0;
                  if (trans_rd==1'b1) begin // write has higher priority
                      stateW   <= STW_ARB;
                  end else begin
                      trans_wr <= 1'b1;
                      stateW   <= STW_WRITE0;
                  end
             end else begin
                  AWREADY <= 1'b1;
             end
             end // STW_READY
         STW_ARB: begin
             if (trans_rd==1'b0) begin
                 trans_wr <= 1'b1;
                 stateW   <= STW_WRITE0;
             end
             end // STW_ARB
         STW_WRITE0: begin
             if (WVALID==1'b1) begin
                 Twaddr <= addrW;
                 Twdata <= WDATA;
                 Twstrb <= WSTRB;
                 Twen   <= 1'b1;
                 beatW  <= beatW + 1;
                 addrW  <= get_next_addr_wr(addrW,AWSIZE_reg
                                           ,AWBURST_reg,AWLEN_reg);
                 if (beatW>=AWLEN_reg) begin
                     WREADY <= 1'b0;
                     BVALID <= 1'b1;
                     BID    <= AWID_reg;
                     if (WLAST==1'b0) BRESP <= 2'b10; // SLVERR - missing last
                     stateW <= STW_RSP;
                 end else begin
                     stateW <= STW_WRITE;
                 end
                 if (WID!=AWID_reg)
                     BRESP <= 2'b10; // SLVERR - ID mis-match occured
             end else begin
                 Twen   <= 1'b0;
             end
             end // STW_WRITE0
         STW_WRITE: begin
             if (WVALID==1'b1) begin
                 Twaddr <= addrW;
                 Twdata <= WDATA;
                 Twstrb <= WSTRB;
                 Twen   <= 1'b1;
                 beatW  <= beatW + 1;
                 addrW  <= get_next_addr_wr(addrW,AWSIZE_reg
                                           ,AWBURST_reg,AWLEN_reg);
                 if (beatW>=AWLEN_reg) begin
                     WREADY <= 1'b0;
                     BVALID <= 1'b1;
                     BID    <= AWID_reg;
                     if (WLAST==1'b0) BRESP <= 2'b10; // SLVERR - missing last
                     stateW <= STW_RSP;
                 end
                 if (WID!=AWID_reg)
                     BRESP <= 2'b10; // SLVERR - ID mis-match occured
             end else begin
                 Twen   <= 1'b0;
             end
             end // STW_WRITE
         STW_RSP: begin
             Twen   <= 1'b0;
             if (BREADY==1'b1) begin
                 BVALID   <= 1'b0;
                 AWREADY  <= 1'b1;
                 trans_wr <= 1'b0;
                 stateW   <= STW_READY;
             end
             end // STW_RSP
         endcase
     end // if
     end // always
     //-------------------------------------------------------------------------
     // synthesis translate_off
     reg  [8*10-1:0] stateW_ascii = "READY";
     always @ (stateW) begin
     case (stateW)
         STW_READY : stateW_ascii="READY ";
         STW_ARB   : stateW_ascii="ARB   ";
         STW_WRITE0: stateW_ascii="WRITE0";
         STW_WRITE : stateW_ascii="WRITE ";
         STW_RSP   : stateW_ascii="RSP   ";
         default   : stateW_ascii="ERROR ";
     endcase
     end
     // synthesis translate_on
     //-------------------------------------------------------------------------
     // read case
     //-------------------------------------------------------------------------
     reg  [AXI_WIDTH_AD-1:0]  ARADDR_reg ;
     `ifdef AMBA_AXI4
     reg  [ 7:0]          ARLEN_reg  ;
     reg                  ARLOCK_reg ;
     `else
     reg  [ 3:0]          ARLEN_reg  ;
     reg  [ 1:0]          ARLOCK_reg ;
     `endif
     reg  [ 2:0]          ARSIZE_reg ;
     reg  [ 1:0]          ARBURST_reg;
     reg  [ 3:0]          ARCACHE_reg;
     reg  [ 2:0]          ARPROT_reg ;
     //-------------------------------------------------------------------------
     reg  [AXI_WIDTH_DA-1:0] dataR;
     reg  [ADDR_LENGTH-1:0]  addrR; // address of each transfer within a burst
     reg  [AXI_WIDTH_DS-1:0] strbR; // strobe
     `ifdef AMBA_AXI4
     reg  [ 7:0]             beatR; // keeps num of transfers within a burst
     `else
     reg  [ 3:0]             beatR; // keeps num of transfers within a burst
     `endif
     //-------------------------------------------------------------------------
     localparam STR_READY  = 'h0
              , STR_ARB    = 'h1
              , STR_READ0  = 'h2
              , STR_READ1  = 'h3
              , STR_READ2  = 'h4
              , STR_READ21 = 'h5
              , STR_READ22 = 'h6
              , STR_READ3  = 'h7
              , STR_READ31 = 'h8
              , STR_READ32 = 'h9
              , STR_READ33 = 'hA
              , STR_READ34 = 'hB
              , STR_END    = 'hC;
     reg [3:0] stateR=STR_READY; // synthesis attribute keep of stateR is "true";
     always @ (posedge ACLK or negedge ARESETn) begin
     if (ARESETn==1'b0) begin
         ARADDR_reg  <= 'h0;
         ARLEN_reg   <= 'h0;
         ARLOCK_reg  <= 'b0;
         ARSIZE_reg  <= 'b0;
         ARBURST_reg <= 'b0;
         ARCACHE_reg <= 'h0;
         ARPROT_reg  <= 'b0;
         ARREADY     <= 1'b0;
         RID         <=  'h0;
         RLAST       <= 1'b0;
         RRESP       <= 2'b10; // SLAERROR
         RDATA       <=  'h0;
         RVALID      <= 1'b0;
         dataR       <=  'h0;
         addrR       <=  'h0;
         strbR       <=  'h0;
         beatR       <=  'h0;
         Traddr      <=  'h0;
         Trstrb      <=  'h0;
         Tren        <= 1'b0;
         trans_rd    <= 1'b0;
         stateR      <= STR_READY;
     end else begin
         case (stateR)
         STR_READY: begin
             trans_rd <= 1'b0;
             if ((ARVALID==1'b1)&&(ARREADY==1'b1)) begin
                  ARADDR_reg  <= ARADDR ;
                  ARLEN_reg   <= ARLEN  ;
                  ARSIZE_reg  <= ARSIZE ;
                  ARBURST_reg <= ARBURST;
                  ARLOCK_reg  <= ARLOCK ;
                  `ifdef AMBA_AXI_CACHE
                  ARCACHE_reg <= ARCACHE;
                  `else
                  ARCACHE_reg <= 'h0;
                  `endif
                  `ifdef AMBA_AXI_PROT
                  ARPROT_reg  <= ARPROT ;
                  `else
                  ARPROT_reg  <= 'h0;
                  `endif
                  ARREADY     <= 1'b0;
                  RID         <= ARID;
                  addrR       <= get_next_addr_rd(ARADDR[ADDR_LENGTH-1:0]
                                                 ,ARSIZE,ARBURST,ARLEN);
                  beatR       <=  'h0;
                  Traddr      <= ARADDR[ADDR_LENGTH-1:0];
                  Trstrb      <= get_strb(ARADDR[ADDR_LENGTH-1:0],ARSIZE);
                  Tren        <= 1'b1;
                  if (((AWVALID==1'b1)&&(AWREADY==1'b1))||(trans_wr==1'b1)) begin
                      // write has higher priority
                      stateR      <= STR_ARB;
                  end else begin
                      trans_rd <= 1'b1;
                      stateR   <= STR_READ0;
                  end
             end else begin
                 ARREADY <= 1'b1;
             end
             end // STR_READY
         STR_ARB: begin
             if (trans_wr==1'b0) begin
                 trans_rd <= 1'b1;
                 stateR   <= STR_READ0;
             end
             end // STR_ARB
         STR_READ0: begin // address only
             if (ARLEN_reg=='h0) begin // single beat burst
                 Tren   <= 1'b0;
                 stateR <= STR_READ1;
             end else if (ARLEN_reg=='h1) begin // two-beat burst
                 Tren   <= 1'b1;
                 Traddr <= addrR;
                 Trstrb <= get_strb(addrR,ARSIZE_reg);
                 stateR <= STR_READ2;
             end else begin // three or more beat burst
                 Tren   <= 1'b1;
                 Traddr <= addrR;
                 Trstrb <= get_strb(addrR,ARSIZE_reg);
                 addrR  <= get_next_addr_rd(addrR,ARSIZE_reg
                                           ,ARBURST_reg,ARLEN_reg);
                 beatR  <= 1;
                 stateR <= STR_READ3;
             end
             end // STR_READ0
         STR_READ1: begin // data only
             Tren   <= 1'b0;
             RLAST  <= 1'b1;
             RDATA  <= Trdata;
             RRESP  <= 2'b00;
             RVALID <= 1'b1;
             stateR <= STR_END;
             end // STR_READ1
         STR_READ2: begin // two-beat burst
             Tren   <= 1'b0;
             RLAST  <= 1'b0;
             RDATA  <= Trdata;
             RRESP  <= 2'b00;
             RVALID <= 1'b1;
             stateR <= STR_READ21;
             end // STR_READ2;
         STR_READ21: begin // two-beat burst
             if (RREADY==1'b1) begin
                 Tren   <= 1'b0;
                 RLAST  <= 1'b1;
                 RDATA  <= Trdata;
                 RRESP  <= 2'b00;
                 RVALID <= 1'b1;
                 stateR <= STR_END;
             end else begin
                 dataR   <= Trdata;
                 stateR  <= STR_READ22;
             end
             end // STR_READ21
         STR_READ22: begin // two-beat burst
             if (RREADY==1'b1) begin
                 Tren   <= 1'b0;
                 RLAST  <= 1'b1;
                 RDATA  <= dataR ;
                 RRESP  <= 2'b00;
                 RVALID <= 1'b1;
                 stateR <= STR_END;
             end
             end // STR_READ22
         STR_READ3: begin // n-beat burst
             RLAST  <= 1'b0;
             RDATA  <= Trdata;
             RRESP  <= 2'b00;
             RVALID <= 1'b1;
             Tren   <= 1'b1;
             Traddr <= addrR;
             Trstrb <= get_strb(addrR,ARSIZE_reg);
             addrR  <= get_next_addr_rd(addrR,ARSIZE_reg
                                       ,ARBURST_reg,ARLEN_reg);
             beatR  <= beatR + 1;
             stateR <= STR_READ31;
             end // STR_READ3;
         STR_READ31: begin
             if (RREADY==1'b1) begin
                 RLAST  <= 1'b0;
                 RDATA  <= Trdata;
                 RRESP  <= 2'b00;
                 RVALID <= 1'b1;
                 if (beatR>=ARLEN_reg) begin
                    Tren   <= 1'b0; // updated 2018.06.12. adki
                    Traddr <= addrR;
                    stateR <= STR_READ33;
                 end else begin
                    Tren   <= 1'b1; // actually RREADY determines it
                    Traddr <= addrR;
                    Trstrb <= get_strb(addrR,ARSIZE_reg);
                    addrR  <= get_next_addr_rd(addrR,ARSIZE_reg
                                              ,ARBURST_reg,ARLEN_reg);
                 end
                 beatR  <= beatR + 1;
             end else begin
                 Tren   <= 1'b1; // actually RREADY determines it
                 dataR  <= Trdata;
                 stateR <= STR_READ32;
             end
             end // STR_READ31
         STR_READ32: begin
             if (RREADY==1'b1) begin
                 RLAST  <= 1'b0;
                 RDATA  <= dataR;
                 RRESP  <= 2'b00;
                 RVALID <= 1'b1;
                 dataR  <= Trdata;
                 if (beatR>=ARLEN_reg) begin
                    Tren   <= 1'b0;
                    stateR <= STR_READ33;
                 end else begin
                    Tren   <= 1'b1; // actually RREADY determines it
                    Traddr <= addrR;
                    Trstrb <= get_strb(addrR,ARSIZE_reg);
                    addrR  <= get_next_addr_rd(addrR,ARSIZE_reg
                                              ,ARBURST_reg,ARLEN_reg);
                    stateR <= STR_READ31;
                 end
                 beatR  <= beatR + 1;
             end
             end // STR_READ32
         STR_READ33: begin
             if (RREADY==1'b1) begin
                 Tren   <= 1'b0;
                 RLAST  <= 1'b1;
                 RDATA  <= Trdata;
                 RRESP  <= 2'b00;
                 RVALID <= 1'b1;
                 stateR <= STR_END;
             end else begin
                 Tren   <= 1'b0;
                 dataR  <= Trdata;
                 stateR <= STR_READ34;
             end
             end // STR_READ33
         STR_READ34: begin
             if (RREADY==1'b1) begin
                 Tren   <= 1'b0;
                 RLAST  <= 1'b1;
                 RDATA  <= dataR;
                 RRESP  <= 2'b00;
                 RVALID <= 1'b1;
                 stateR <= STR_END;
             end
             end // STR_READ34
         STR_END: begin // data only
             Tren <= 1'b0;
             if (RREADY==1'b1) begin
                 RDATA    <=  'h0;
                 RRESP    <= 2'b10; // SLVERR
                 RLAST    <= 1'b0;
                 RVALID   <= 1'b0;
                 ARREADY  <= 1'b1;
                 trans_rd <= 1'b0;
                 stateR   <= STR_READY;
             end
             end // STR_END
         endcase
     end // if
     end // always
     //-------------------------------------------------------------------------
     // synthesis translate_off
     reg  [8*10-1:0] stateR_ascii = "READY";
     always @ (stateR) begin
     case (stateR)
         STR_READY : stateR_ascii="READY ";
         STR_ARB   : stateR_ascii="ARB   ";
         STR_READ0 : stateR_ascii="READ0 ";
         STR_READ1 : stateR_ascii="READ1 ";
         STR_READ2 : stateR_ascii="READ2 ";
         STR_READ21: stateR_ascii="READ21";
         STR_READ22: stateR_ascii="READ22";
         STR_READ3 : stateR_ascii="READ3 ";
         STR_READ31: stateR_ascii="READ31";
         STR_READ32: stateR_ascii="READ32";
         STR_READ33: stateR_ascii="READ33";
         STR_READ34: stateR_ascii="READ34";
         STR_END   : stateR_ascii="END   ";
         default   : stateW_ascii="ERROR ";
     endcase
     end
     // synthesis translate_on
     //-------------------------------------------------------------------------
     function [7:0] get_bytes;
     input [2:0] size;
          get_bytes = 1<<size;
     endfunction
     //-------------------------------------------------------------------------
     function [AXI_WIDTH_DS-1:0] get_strb;
     input [ADDR_LENGTH-1:0] addr;
     input [ 2:0]            size;  // num. of byte to move: 0=1-byte, 1=2-byte
     reg   [AXI_WIDTH_DS-1:0]    offset;
     begin
          offset = addr[AXI_WIDTH_DSB-1:0]; //offset = addr%AXI_WIDTH_DS;
          case (size)
          3'b000: get_strb = {  1{1'b1}}<<offset;
          3'b001: get_strb = {  2{1'b1}}<<offset;
          3'b010: get_strb = {  4{1'b1}}<<offset;
          3'b011: get_strb = {  8{1'b1}}<<offset;
          3'b100: get_strb = { 16{1'b1}}<<offset;
          3'b101: get_strb = { 32{1'b1}}<<offset;
          3'b110: get_strb = { 64{1'b1}}<<offset;
          3'b111: get_strb = {128{1'b1}}<<offset;
          endcase
     end
     endfunction
     //-------------------------------------------------------------------------
     function [ADDR_LENGTH-1:0] get_next_addr_wr;
     input [ADDR_LENGTH-1:0] addr ;
     input [ 2:0]            size ;
     input [ 1:0]            burst; // burst type
     `ifdef AMBA_AXI4
     input [ 7:0]            len  ; // burst length
     `else
     input [ 3:0]            len  ; // burst length
     `endif
     reg   [ADDR_LENGTH-AXI_WIDTH_DSB-1:0] naddr;
     reg   [ADDR_LENGTH-1:0] mask ;
     begin
          case (burst)
          2'b00: get_next_addr_wr = addr;
          2'b01: begin
                 if ((1<<size)<AXI_WIDTH_DS) begin
                    get_next_addr_wr = addr + (1<<size);
                 end else begin
                     naddr = addr[ADDR_LENGTH-1:AXI_WIDTH_DSB];
                     naddr = naddr + 1;
                     get_next_addr_wr = {naddr,{AXI_WIDTH_DSB{1'b0}}};
                 end
                 end
          2'b10: begin
                 `ifdef BURST_TYPE_WRAPP_ENABLED
                 mask          = get_wrap_mask(size,len);
                 get_next_addr_wr = (addr&~mask)
                               | (((addr&mask)+(1<<size))&mask);
                 `else
                 // synopsys translate_off
                 $display($time,,"%m ERROR BURST WRAP not supported");
                 // synopsys translate_on
                 `endif
                 end
          2'b11: begin
                 get_next_addr_wr = addr;
                 // synopsys translate_off
                 $display($time,,"%m ERROR un-defined BURST %01x", burst);
                 // synopsys translate_on
                 end
          endcase
     end
     endfunction
     //-------------------------------------------------------------------------
     function [ADDR_LENGTH-1:0] get_next_addr_rd;
     input [ADDR_LENGTH-1:0] addr ;
     input [ 2:0]            size ;
     input [ 1:0]            burst; // burst type
     `ifdef AMBA_AXI4
     input [ 7:0]            len  ; // burst length
     `else
     input [ 3:0]            len  ; // burst length
     `endif
     reg   [ADDR_LENGTH-AXI_WIDTH_DSB-1:0] naddr;
     reg   [ADDR_LENGTH-1:0] mask ;
     begin
          case (burst)
          2'b00: get_next_addr_rd = addr;
          2'b01: begin
                 if ((1<<size)<AXI_WIDTH_DS) begin
                    get_next_addr_rd = addr + (1<<size);
                 end else begin
                     naddr = addr[ADDR_LENGTH-1:AXI_WIDTH_DSB];
                     naddr = naddr + 1;
                     get_next_addr_rd = {naddr,{AXI_WIDTH_DSB{1'b0}}};
                 end
                 end
          2'b10: begin
                 `ifdef BURST_TYPE_WRAPP_ENABLED
                 mask          = get_wrap_mask(size,len);
                 get_next_addr_rd = (addr&~mask)
                               | (((addr&mask)+(1<<size))&mask);
                 `else
                 // synopsys translate_off
                 $display($time,,"%m ERROR BURST WRAP not supported");
                 // synopsys translate_on
                 `endif
                 end
          2'b11: begin
                 get_next_addr_rd = addr;
                 // synopsys translate_off
                 $display($time,,"%m ERROR un-defined BURST %01x", burst);
                 // synopsys translate_on
                 end
          endcase
     end
     endfunction
     //-------------------------------------------------------------------------
     `ifdef BURST_TYPE_WRAPP_ENABLED
     function [ADDR_LENGTH-1:0] get_wrap_mask;
     input [ 2:0]      size ;
     `ifdef AMBA_AXI4
     input [ 7:0]      len  ; // burst length
     `else
     input [ 3:0]      len  ; // burst length
     `endif
     begin
          case (size)
          3'b000: get_wrap_mask = (    len)-1;
          3'b001: get_wrap_mask = (  2*len)-1;
          3'b010: get_wrap_mask = (  4*len)-1;
          3'b011: get_wrap_mask = (  8*len)-1;
          3'b100: get_wrap_mask = ( 16*len)-1;
          3'b101: get_wrap_mask = ( 32*len)-1;
          3'b110: get_wrap_mask = ( 64*len)-1;
          3'b111: get_wrap_mask = (128*len)-1;
          endcase
     end
     endfunction
     `endif
     //-------------------------------------------------------------------------
     function integer clogb2;
     input [31:0] value;
     reg   [31:0] tmp;
     begin
        tmp = value - 1;
        for (clogb2 = 0; tmp > 0; clogb2 = clogb2 + 1) tmp = tmp >> 1;
     end
     endfunction
     //-------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.12: Tren at 'STR_READ31' changed by Ando Ki.
// 2018.05.01: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
