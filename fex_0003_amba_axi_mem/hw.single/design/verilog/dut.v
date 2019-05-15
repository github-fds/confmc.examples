//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems.
// All right reserved.
//------------------------------------------------------------------------------
// dut.v
//------------------------------------------------------------------------------
// VERSION: 2018.05.01.
//------------------------------------------------------------------------------
//      gpif2mast
//    +-----------+        +---------+        +----------+
//    |           |        |         |        |          |
//    |   CMD-FIFO+=======>|         |        |          |
//    |           |        |         |        |          |
//    |           |        |         |        |          |
//    |   U2F-FIFO+=======>| trx_axi |<======>| mem_axi  |
//    |           |        |         |        |(bram_axi)|
//    |           |        |         |        |          |
//    |   F2U-FIFO|<=======+         |        |          |
//    |           |        |         |        |          |
//    +-----------+        +---------+        +----------+
//------------------------------------------------------------------------------

module dut
     #(parameter DEPTH_FIFO_CU2F=128  // command-fifo 4-word unit (USB-to-FPGA)
               , DEPTH_FIFO_DU2F=2048 // data stream-in-fifo 4-word unit (USB-to-FPGA)
               , DEPTH_FIFO_DF2U=2048 // data stream-out-fifo 4-word unit (FPGA-to-USB)
               , PCLK_INV       =1'b1 // SL_PCLK=~SYS_CLK when 1
               , PCLK_FREQ      =100_000_000  // SL_PCLK frequency
               , FPGA_FAMILY    ="VIRTEX6" // SPARTAN6, VIRTEX4
               , MEM_SIZE       =8*1024 )
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
   parameter AXI_WIDTH_CID= 4 // Channel ID width in bits
           , AXI_WIDTH_ID = 4 // ID width in bits
           , AXI_WIDTH_AD =32 // address width
           , AXI_WIDTH_DA =32 // data width
           , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)  // data strobe width
           , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID);
   //--------------------------------------------
   wire                     BFM_ARESETn=SYS_RST_N;
   wire                     BFM_ACLK   =USR_CLK;
   wire [AXI_WIDTH_CID-1:0] BFM_MID    =AXI_MST_ID; // Master(BFM) drives its channel id
   wire [AXI_WIDTH_ID-1:0]  BFM_AWID   ; // note NOT AXI_WIDTH_SID
   wire [AXI_WIDTH_AD-1:0]  BFM_AWADDR;
   `ifdef AMBA_AXI4
   wire [ 7:0]              BFM_AWLEN;
   wire                     BFM_AWLOCK;
   `else
   wire [ 3:0]              BFM_AWLEN;
   wire [ 1:0]              BFM_AWLOCK;
   `endif
   wire [ 2:0]              BFM_AWSIZE;
   wire [ 1:0]              BFM_AWBURST;
   `ifdef AMBA_AXI_CACHE
   wire [ 3:0]              BFM_AWCACHE;
   `endif
   `ifdef AMBA_AXI_PROT
   wire [ 2:0]              BFM_AWPROT;
   `endif
   wire                     BFM_AWVALID;
   wire                     BFM_AWREADY;
   `ifdef AMBA_AXI4
   wire [ 3:0]              BFM_AWQOS;
   wire [ 3:0]              BFM_AWREGION;
   `endif
   wire [AXI_WIDTH_ID-1:0]  BFM_WID;
   wire [AXI_WIDTH_DA-1:0]  BFM_WDATA;
   wire [AXI_WIDTH_DS-1:0]  BFM_WSTRB;
   wire                     BFM_WLAST;
   wire                     BFM_WVALID;
   wire                     BFM_WREADY;
   wire [AXI_WIDTH_CID-1:0] BFM_MID_B;
   wire [AXI_WIDTH_SID-1:0] BFM_BID;
   wire [ 1:0]              BFM_BRESP;
   wire                     BFM_BVALID;
   wire                     BFM_BREADY;
   wire [AXI_WIDTH_ID-1:0]  BFM_ARID;
   wire [AXI_WIDTH_AD-1:0]  BFM_ARADDR;
   `ifdef AMBA_AXI4
   wire [ 7:0]              BFM_ARLEN;
   wire                     BFM_ARLOCK;
   `else
   wire [ 3:0]              BFM_ARLEN;
   wire [ 1:0]              BFM_ARLOCK;
   `endif
   wire [ 2:0]              BFM_ARSIZE;
   wire [ 1:0]              BFM_ARBURST;
   `ifdef AMBA_AXI_CACHE
   wire [ 3:0]              BFM_ARCACHE;
   `endif
   `ifdef AMBA_AXI_PROT
   wire [ 2:0]              BFM_ARPROT;
   `endif
   wire                     BFM_ARVALID;
   wire                     BFM_ARREADY;
   `ifdef AMBA_AXI4
   wire [ 3:0]              BFM_ARQOS;
   wire [ 3:0]              BFM_ARREGION;
   `endif
   wire [AXI_WIDTH_CID-1:0] BFM_MID_R;
   wire [AXI_WIDTH_SID-1:0] BFM_RID;
   wire [AXI_WIDTH_DA-1:0]  BFM_RDATA;
   wire [ 1:0]              BFM_RRESP;
   wire                     BFM_RLAST;
   wire                     BFM_RVALID;
   wire                     BFM_RREADY;
   wire [15:0]              GPOUT;
   //---------------------------------------------------------------------------
   bfm_axi
   u_bfm_axi (
          .SYS_CLK_STABLE  ( SYS_CLK_STABLE )
        , .SYS_CLK         ( SYS_CLK        )
        , .SYS_RST_N       ( SYS_RST_N      )
        , .SL_RST_N        ( SL_RST_N       )
        , .SL_CS_N         ( SL_CS_N        )
        , .SL_PCLK         ( SL_PCLK        )
        , .SL_AD           ( SL_AD          )
        , .SL_FLAGA        ( SL_FLAGA       )
        , .SL_FLAGB        ( SL_FLAGB       )
        , .SL_FLAGC        ( SL_FLAGC       )
        , .SL_FLAGD        ( SL_FLAGD       )
        , .SL_RD_N         ( SL_RD_N        )
        , .SL_WR_N         ( SL_WR_N        )
        , .SL_OE_N         ( SL_OE_N        )
        , .SL_PKTEND_N     ( SL_PKTEND_N    )
        , .SL_DT_I         ( SL_DT_I        )
        , .SL_DT_O         ( SL_DT_O        )
        , .SL_DT_T         ( SL_DT_T        )
        , .SL_MODE         ( SL_MODE        )
        , .ARESETn  ( BFM_ARESETn  )
        , .ACLK     ( BFM_ACLK     )
        , .MID      ( BFM_MID      )
        , .AWID     ( BFM_AWID     ) //[AXI_WIDTH_ID-1:0]
        , .AWADDR   ( BFM_AWADDR   )
        , .AWLEN    ( BFM_AWLEN    )
        , .AWLOCK   ( BFM_AWLOCK   )
        , .AWSIZE   ( BFM_AWSIZE   )
        , .AWBURST  ( BFM_AWBURST  )
        `ifdef AMBA_AXI_CACHE
        , .AWCACHE  ( BFM_AWCACHE  )
        `endif
        `ifdef AMBA_AXI_PROT
        , .AWPROT   ( BFM_AWPROT   )
        `endif
        , .AWVALID  ( BFM_AWVALID  )
        , .AWREADY  ( BFM_AWREADY  )
        `ifdef AMBA_AXI4
        , .AWQOS    ( BFM_AWQOS    )
        , .AWREGION ( BFM_AWREGION )
        `endif
        , .WID      ( BFM_WID      ) //[AXI_WIDTH_ID-1:0]
        , .WDATA    ( BFM_WDATA    )
        , .WSTRB    ( BFM_WSTRB    )
        , .WLAST    ( BFM_WLAST    )
        , .WVALID   ( BFM_WVALID   )
        , .WREADY   ( BFM_WREADY   )
        , .BID      ( BFM_BID[AXI_WIDTH_ID-1:0])
        , .BRESP    ( BFM_BRESP    )
        , .BVALID   ( BFM_BVALID   )
        , .BREADY   ( BFM_BREADY   )
        , .ARID     ( BFM_ARID     ) //[AXI_WIDTH_ID-1:0]
        , .ARADDR   ( BFM_ARADDR   )
        , .ARLEN    ( BFM_ARLEN    )
        , .ARLOCK   ( BFM_ARLOCK   )
        , .ARSIZE   ( BFM_ARSIZE   )
        , .ARBURST  ( BFM_ARBURST  )
        `ifdef AMBA_AXI_CACHE
        , .ARCACHE  ( BFM_ARCACHE  )
        `endif
        `ifdef AMBA_AXI_PROT
        , .ARPROT   ( BFM_ARPROT   )
        `endif
        , .ARVALID  ( BFM_ARVALID  )
        , .ARREADY  ( BFM_ARREADY  )
        `ifdef AMBA_AXI4
        , .ARQOS    ( BFM_ARQOS    )
        , .ARREGION ( BFM_ARREGION )
        `endif
        , .RID      ( BFM_RID[AXI_WIDTH_ID-1:0]) //[AXI_WIDTH_ID-1:0]
        , .RDATA    ( BFM_RDATA    )
        , .RRESP    ( BFM_RRESP    )
        , .RLAST    ( BFM_RLAST    )
        , .RVALID   ( BFM_RVALID   )
        , .RREADY   ( BFM_RREADY   )
        , .IRQ      ( 1'b0         )
        , .FIQ      ( 1'b0         )
        , .GPOUT    ( GPOUT    )
        , .GPIN     ( GPOUT    )
   );
`ifdef SIM_ALL
   defparam u_bfm_axi.DEPTH_FIFO_CU2F=DEPTH_FIFO_CU2F // command-fifo 4-word unit (USB-to-FPGA)
          , u_bfm_axi.DEPTH_FIFO_DU2F=DEPTH_FIFO_DU2F
          , u_bfm_axi.DEPTH_FIFO_DF2U=DEPTH_FIFO_DF2U // data stream-out-fifo 4-word unit (FPGA-to-USB)
          , u_bfm_axi.PCLK_INV       =PCLK_INV     
          , u_bfm_axi.PCLK_FREQ      =PCLK_FREQ    
          , u_bfm_axi.FPGA_FAMILY    =FPGA_FAMILY; // SPARTAN6, VIRTEX4
   defparam u_bfm_axi.TRANSACTOR_ID = 4'h0;
`endif
   //---------------------------------------------------------------------------
`ifdef SIMx
   mem_axi #(.AXI_WIDTH_CID(AXI_WIDTH_CID)// Channel ID width in bits
            ,.AXI_WIDTH_ID (AXI_WIDTH_ID )// ID width in bits
            ,.AXI_WIDTH_AD (AXI_WIDTH_AD )// address width
            ,.AXI_WIDTH_DA (AXI_WIDTH_DA )// data width
            ,.P_SIZE_IN_BYTES(1024*1024))
   u_mem_axi (
          .ARESETn            ( BFM_ARESETn    )
        , .ACLK               ( BFM_ACLK       )
        , .AWID               ({BFM_MID,BFM_AWID})
        , .AWADDR             ( BFM_AWADDR     )
        , .AWLEN              ( BFM_AWLEN      )
        , .AWLOCK             ( BFM_AWLOCK     )
        , .AWSIZE             ( BFM_AWSIZE     )
        , .AWBURST            ( BFM_AWBURST    )
        `ifdef AMBA_AXI_CACHE
        , .AWCACHE            ( BFM_AWCACHE    )
        `endif
        `ifdef AMBA_AXI_PROT  
        , .AWPROT             ( BFM_AWPROT     )
        `endif
        , .AWVALID            ( BFM_AWVALID    )
        , .AWREADY            ( BFM_AWREADY    )
        `ifdef AMBA_AXI4      
        , .AWQOS              ( BFM_AWQOS      )
        , .AWREGION           ( BFM_AWREGION   )
        `endif
        , .WID                ({BFM_MID,BFM_WID})
        , .WDATA              ( BFM_WDATA      )
        , .WSTRB              ( BFM_WSTRB      )
        , .WLAST              ( BFM_WLAST      )
        , .WVALID             ( BFM_WVALID     )
        , .WREADY             ( BFM_WREADY     )
        , .BID                ( BFM_BID        ) //[AXI_WIDTH_SID-1:0]
        , .BRESP              ( BFM_BRESP      )
        , .BVALID             ( BFM_BVALID     )
        , .BREADY             ( BFM_BREADY     )
        , .ARID               ({BFM_MID,BFM_ARID})
        , .ARADDR             ( BFM_ARADDR     )
        , .ARLEN              ( BFM_ARLEN      )
        , .ARLOCK             ( BFM_ARLOCK     )
        , .ARSIZE             ( BFM_ARSIZE     )
        , .ARBURST            ( BFM_ARBURST    )
        `ifdef AMBA_AXI_CACHE
        , .ARCACHE            ( BFM_ARCACHE    )
        `endif
        `ifdef AMBA_AXI_PROT
        , .ARPROT             ( BFM_ARPROT     )
        `endif
        , .ARVALID            ( BFM_ARVALID    )
        , .ARREADY            ( BFM_ARREADY    )
        `ifdef AMBA_AXI4     
        , .ARQOS              ( BFM_ARQOS      )
        , .ARREGION           ( BFM_ARREGION   )
        `endif
        , .RID                ( BFM_RID        ) //[AXI_WIDTH_SID-1:0]
        , .RDATA              ( BFM_RDATA      )
        , .RRESP              ( BFM_RRESP      )
        , .RLAST              ( BFM_RLAST      )
        , .RVALID             ( BFM_RVALID     )
        , .RREADY             ( BFM_RREADY     )
   );
`else
   bram_axi #(.AXI_WIDTH_CID(AXI_WIDTH_CID)// Channel ID width in bits
             ,.AXI_WIDTH_ID (AXI_WIDTH_ID )// ID width in bits
             ,.AXI_WIDTH_AD (AXI_WIDTH_AD )// address width
             ,.AXI_WIDTH_DA (AXI_WIDTH_DA )// data width
             ,.P_SIZE_IN_BYTES(MEM_SIZE))
   u_mem_axi (
          .ARESETn            ( BFM_ARESETn    )
        , .ACLK               ( BFM_ACLK       )
        , .AWID               ({BFM_MID,BFM_AWID})
        , .AWADDR             ( BFM_AWADDR     )
        , .AWLEN              ( BFM_AWLEN      )
        , .AWLOCK             ( BFM_AWLOCK     )
        , .AWSIZE             ( BFM_AWSIZE     )
        , .AWBURST            ( BFM_AWBURST    )
        `ifdef AMBA_AXI_CACHE
        , .AWCACHE            ( BFM_AWCACHE    )
        `endif
        `ifdef AMBA_AXI_PROT  
        , .AWPROT             ( BFM_AWPROT     )
        `endif
        , .AWVALID            ( BFM_AWVALID    )
        , .AWREADY            ( BFM_AWREADY    )
        `ifdef AMBA_AXI4      
        , .AWQOS              ( BFM_AWQOS      )
        , .AWREGION           ( BFM_AWREGION   )
        `endif
        , .WID                ({BFM_MID,BFM_WID})
        , .WDATA              ( BFM_WDATA      )
        , .WSTRB              ( BFM_WSTRB      )
        , .WLAST              ( BFM_WLAST      )
        , .WVALID             ( BFM_WVALID     )
        , .WREADY             ( BFM_WREADY     )
        , .BID                ( BFM_BID        ) //[AXI_WIDTH_SID-1:0]
        , .BRESP              ( BFM_BRESP      )
        , .BVALID             ( BFM_BVALID     )
        , .BREADY             ( BFM_BREADY     )
        , .ARID               ({BFM_MID,BFM_ARID})
        , .ARADDR             ( BFM_ARADDR     )
        , .ARLEN              ( BFM_ARLEN      )
        , .ARLOCK             ( BFM_ARLOCK     )
        , .ARSIZE             ( BFM_ARSIZE     )
        , .ARBURST            ( BFM_ARBURST    )
        `ifdef AMBA_AXI_CACHE
        , .ARCACHE            ( BFM_ARCACHE    )
        `endif
        `ifdef AMBA_AXI_PROT
        , .ARPROT             ( BFM_ARPROT     )
        `endif
        , .ARVALID            ( BFM_ARVALID    )
        , .ARREADY            ( BFM_ARREADY    )
        `ifdef AMBA_AXI4     
        , .ARQOS              ( BFM_ARQOS      )
        , .ARREGION           ( BFM_ARREGION   )
        `endif
        , .RID                ( BFM_RID        ) //[AXI_WIDTH_SID-1:0]
        , .RDATA              ( BFM_RDATA      )
        , .RRESP              ( BFM_RRESP      )
        , .RLAST              ( BFM_RLAST      )
        , .RVALID             ( BFM_RVALID     )
        , .RREADY             ( BFM_RREADY     )
   );
`endif
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.05.01: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
