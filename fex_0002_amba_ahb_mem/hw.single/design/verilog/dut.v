//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems.
// All right reserved.
//------------------------------------------------------------------------------
// dut.v
//------------------------------------------------------------------------------
// VERSION: 2018.02.01.
//------------------------------------------------------------------------------
//      gpif2mast
//    +-----------+        +---------+        +----------+
//    |           |        |         |        |          |
//    |   CMD-FIFO+=======>|         |        |          |
//    |           |        |         |        |          |
//    |           |        |         |        |          |
//    |   U2F-FIFO+=======>| bfm_ahb |<======>| mem_ahb  |
//    |           |        |         |        |(bram_ahb)|
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
               , FPGA_FAMILY    ="SPARTAN6" // SPARTAN6, VIRTEX4
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
   wire [15:0]  GPOUT;
   //---------------------------------------------------------------------------
   wire         BFM_HRESETn  = SYS_RST_N;
   wire         BFM_HCLK     = USR_CLK  ;
   wire [31:0]  BFM_HADDR    ;
   wire [ 1:0]  BFM_HTRANS   ;
   wire         BFM_HWRITE   ;
   wire [ 2:0]  BFM_HSIZE    ;
   wire [ 2:0]  BFM_HBURST   ;
   wire [ 3:0]  BFM_HPROT    ;
   wire         BFM_HLOCK    ;
   wire [31:0]  BFM_HWDATA   ;
   wire [31:0]  BFM_HRDATA   ;
   wire [ 1:0]  BFM_HRESP    ;
   wire         BFM_HREADY   ;
   wire         BFM_HSEL     = BFM_HTRANS[1];
   wire         BFM_HBUSREQ  ;
   reg          BFM_HGRANT=1'b0; always @ (posedge BFM_HCLK) BFM_HGRANT <= BFM_HBUSREQ;
   //---------------------------------------------------------------------------
   bfm_ahb
   u_bfm_ahb (
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
        , .HRESETn    ( BFM_HRESETn   )
        , .HCLK       ( BFM_HCLK      )
        , .HBUSREQ    ( BFM_HBUSREQ   )
        , .HGRANT     ( BFM_HGRANT    )
        , .HADDR      ( BFM_HADDR     )
        , .HPROT      ( BFM_HPROT     )
        , .HTRANS     ( BFM_HTRANS    )
        , .HWRITE     ( BFM_HWRITE    )
        , .HSIZE      ( BFM_HSIZE     )
        , .HBURST     ( BFM_HBURST    )
        , .HLOCK      ( BFM_HLOCK     )
        , .HWDATA     ( BFM_HWDATA    )
        , .HRDATA     ( BFM_HRDATA    )
        , .HRESP      ( BFM_HRESP     )
        , .HREADY     ( BFM_HREADY    )
        , .IRQ        ( 1'b0      )
        , .FIQ        ( 1'b0      )
        , .GPOUT      ( GPOUT     )
        , .GPIN       ( GPOUT     )
   );
`ifdef SIM_ALL
   defparam u_bfm_ahb.DEPTH_FIFO_CU2F=DEPTH_FIFO_CU2F // command-fifo 4-word unit (USB-to-FPGA)
          , u_bfm_ahb.DEPTH_FIFO_DU2F=DEPTH_FIFO_DU2F
          , u_bfm_ahb.DEPTH_FIFO_DF2U=DEPTH_FIFO_DF2U // data stream-out-fifo 4-word unit (FPGA-to-USB)
          , u_bfm_ahb.PCLK_INV       =PCLK_INV     
          , u_bfm_ahb.PCLK_FREQ      =PCLK_FREQ    
          , u_bfm_ahb.FPGA_FAMILY    =FPGA_FAMILY; // SPARTAN6, VIRTEX4
   defparam u_bfm_ahb.TRANSACTOR_ID = 4'h0;
`endif
   //---------------------------------------------------------------------------
   `ifdef SIMx
   mem_ahb_sim #(.P_SIZE_IN_BYTES(MEM_SIZE)//size of memory in bytes
                ,.P_DELAY(`MEM_DELAY) // the num of clocks until HREADy
                ,.P_INIT(0)) // initialize when 1
   u_mem_ahb (
          .HRESETn   ( BFM_HRESETn )
        , .HCLK      ( BFM_HCLK    )
        , .HSEL      ( BFM_HSEL    )
        , .HADDR     ( BFM_HADDR   )
        , .HTRANS    ( BFM_HTRANS  )
        , .HWRITE    ( BFM_HWRITE  )
        , .HSIZE     ( BFM_HSIZE   )
        , .HBURST    ( BFM_HBURST  )
        , .HWDATA    ( BFM_HWDATA  )
        , .HRDATA    ( BFM_HRDATA  )
        , .HRESP     ( BFM_HRESP   )
        , .HREADYin  ( BFM_HREADY  )
        , .HREADYout ( BFM_HREADY  )
   ); 
   `else
   bram_ahb #(.P_SIZE_IN_BYTES(MEM_SIZE))
   u_mem_ahb (
          .HRESETn   ( BFM_HRESETn )
        , .HCLK      ( BFM_HCLK    )
        , .HSEL      ( BFM_HSEL    )
        , .HADDR     ( BFM_HADDR   )
        , .HTRANS    ( BFM_HTRANS  )
        , .HWRITE    ( BFM_HWRITE  )
        , .HSIZE     ( BFM_HSIZE   )
        , .HBURST    ( BFM_HBURST  )
        , .HWDATA    ( BFM_HWDATA  )
        , .HRDATA    ( BFM_HRDATA  )
        , .HRESP     ( BFM_HRESP   )
        , .HREADYin  ( BFM_HREADY  )
        , .HREADYout ( BFM_HREADY  )
   );
   `endif
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.24: stream-loopback added.
// 2018.03.07: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
