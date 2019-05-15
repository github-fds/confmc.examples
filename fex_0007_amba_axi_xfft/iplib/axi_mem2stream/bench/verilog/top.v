//------------------------------------------------------------------------------
//  Copyright (c) 2019 by Ando Ki.
//  All right reserved.
//  http://www.future-ds.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//------------------------------------------------------------------------------
// top.v
//------------------------------------------------------------------------------
// VERSION: 2019.04.05.
//------------------------------------------------------------------------------
`timescale 1ns/1ns

`ifndef WIDTH_AD
`define WIDTH_AD   32 // address width
`endif
`ifndef WIDTH_DA
`define WIDTH_DA   64 // data width
`endif
`ifndef STREAM_WIDTH_DA
`define STREAM_WIDTH_DA WIDTH_DA
`endif

module top ;
   //---------------------------------------------------------
   localparam WIDTH_CID   = 2    // Channel ID width in bits; it should be 0 since no AXI matrix
            , WIDTH_ID    = 4    // ID width in bits for master
            , WIDTH_AD    =`WIDTH_AD    // address width
            , WIDTH_DA    =`WIDTH_DA    // data width
            , WIDTH_DS    =(WIDTH_DA/8)  // data strobe width
            , WIDTH_SID   =WIDTH_CID+WIDTH_ID // ID for slave
            , WIDTH_AWUSER=1  // Write-address user path
            , WIDTH_WUSER =1  // Write-data user path
            , WIDTH_BUSER =1  // Write-response user path
            , WIDTH_ARUSER=1  // read-address user path
            , WIDTH_RUSER =1; // read-data user path
   localparam STREAM_WIDTH_DATA=`STREAM_WIDTH_DA
            , STREAM_WIDTH_DS=(STREAM_WIDTH_DATA/8);
   localparam APB_AW=32
            , APB_DW=32
            , APB_DS=(APB_DW/8);
   //---------------------------------------------------------
   initial begin
      $display("%m AXI_WIDTH_DATA(%0d) %s AXIS_WIDTH_DATA(%0d)",
                WIDTH_DA,
                (WIDTH_DA==STREAM_WIDTH_DATA) ? "="  :
                (WIDTH_DA< STREAM_WIDTH_DATA) ? "<"  : ">",
                STREAM_WIDTH_DATA);
   end
   //---------------------------------------------------------
   reg  ACLK    =1'b1; always #5 ACLK    = ~ACLK;
   reg  AXIS_CLK=1'b1; always #56  AXIS_CLK= ~AXIS_CLK;
   //---------------------------------------------------------
   reg  ARESETn=1'b0; initial begin #55; ARESETn=1'b1; end
   //--------------------------------------------------------------
   wire  [WIDTH_CID-1:0]                   MEM_MID     ;
   wire  [WIDTH_SID-1:0]                   MEM_AWID    ;
   wire  [WIDTH_AD-1:0]                    MEM_AWADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]                            MEM_AWLEN   ;
   wire                                    MEM_AWLOCK  ;
   `else
   wire  [ 3:0]                            MEM_AWLEN   ;
   wire  [ 1:0]                            MEM_AWLOCK  ;
   `endif
   wire  [ 2:0]                            MEM_AWSIZE  ;
   wire  [ 1:0]                            MEM_AWBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                            MEM_AWCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                            MEM_AWPROT  ;
   `endif
   wire                                    MEM_AWVALID ;
   wire                                    MEM_AWREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]                            MEM_AWQOS   ;
   wire  [ 3:0]                            MEM_AWREGION;
   `endif
   `ifdef AMBA_AXI_AWUSER
   wire  [WIDTH_AWUSER-1:0]                MEM_AWUSER  ;
   `endif
   wire  [WIDTH_SID-1:0]                   MEM_WID     ;
   wire  [WIDTH_DA-1:0]                    MEM_WDATA   ;
   wire  [WIDTH_DS-1:0]                    MEM_WSTRB   ;
   wire                                    MEM_WLAST   ;
   wire                                    MEM_WVALID  ;
   wire                                    MEM_WREADY  ;
   `ifdef AMBA_AXI_WUSER
   wire  [WIDTH_WUSER-1:0]                 MEM_WUSER   ;
   `endif
   wire  [WIDTH_SID-1:0]                   MEM_BID     ;
   wire  [ 1:0]                            MEM_BRESP   ;
   wire                                    MEM_BVALID  ;
   wire                                    MEM_BREADY  ;
   `ifdef AMBA_AXI_BUSER
   wire  [WIDTH_BUSER-1:0]                 MEM_BUSER   ;
   `endif
   wire  [WIDTH_SID-1:0]                   MEM_ARID    ;
   wire  [WIDTH_AD-1:0]                    MEM_ARADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]                            MEM_ARLEN   ;
   wire                                    MEM_ARLOCK  ;
   `else
   wire  [ 3:0]                            MEM_ARLEN   ;
   wire  [ 1:0]                            MEM_ARLOCK  ;
   `endif
   wire  [ 2:0]                            MEM_ARSIZE  ;
   wire  [ 1:0]                            MEM_ARBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                            MEM_ARCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                            MEM_ARPROT  ;
   `endif
   wire                                    MEM_ARVALID ;
   wire                                    MEM_ARREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]                            MEM_ARQOS   ;
   wire  [ 3:0]                            MEM_ARREGION;
   `endif
   `ifdef AMBA_AXI_ARUSER
   wire  [WIDTH_ARUSER-1:0]                MEM_ARUSER  ;
   `endif
   wire  [WIDTH_SID-1:0]                   MEM_RID     ;
   wire  [WIDTH_DA-1:0]                    MEM_RDATA   ;
   wire  [ 1:0]                            MEM_RRESP   ;
   wire                                    MEM_RLAST   ;
   wire                                    MEM_RVALID  ;
   wire                                    MEM_RREADY  ;
   `ifdef AMBA_AXI_RUSER
   wire  [WIDTH_RUSER-1:0]                 MEM_RUSER   ;
   `endif
   //---------------------------------------------------------
   // AXI-Stream Port
   wire                           AXIS_TREADY;
   wire                           AXIS_TVALID;
   wire  [STREAM_WIDTH_DATA-1:0]  AXIS_TDATA ;
   wire  [STREAM_WIDTH_DS-1:0]    AXIS_TSTRB ;
   wire                           AXIS_TLAST ;
   wire                           AXIS_TSTART;
   //---------------------------------------------------------
   // APB Slave Port for CSR
   wire              PRESETn=ARESETn;
   wire              PCLK   =ACLK;
   wire              PSEL   ;
   wire              PENABLE;
   wire [APB_AW-1:0] PADDR  ;
   wire              PWRITE ;
   wire [APB_DW-1:0] PRDATA ;
   wire [APB_DW-1:0] PWDATA ;
   wire              PREADY ;
   wire              PSLVERR;
   wire [APB_DS-1:0] PSTRB  ;
   wire [2:0]        PPROT  ;
   wire              IRQ    ;
   //---------------------------------------------------------
   axi_mem2stream #(.AXI_MST_ID   (1        ) // Master ID
                   ,.AXI_WIDTH_CID(WIDTH_CID)
                   ,.AXI_WIDTH_ID (WIDTH_ID ) // ID width in bits
                   ,.AXI_WIDTH_AD (WIDTH_AD ) // address width
                   ,.AXI_WIDTH_DA (WIDTH_DA ) // data width
                   ,.AXIS_WIDTH_DATA(STREAM_WIDTH_DATA)
                   ,.AXIS_WIDTH_DS  (STREAM_WIDTH_DS))
   u_mem2stream (
         .ARESETn     (ARESETn           )
       , .ACLK        (ACLK              )
       , .M_MID       (MEM_MID           )
       , .M_AWID      (MEM_AWID[WIDTH_ID-1:0])
       , .M_AWADDR    (MEM_AWADDR        )
       , .M_AWLEN     (MEM_AWLEN         )
       , .M_AWLOCK    (MEM_AWLOCK        )
       , .M_AWSIZE    (MEM_AWSIZE        )
       , .M_AWBURST   (MEM_AWBURST       )
       `ifdef AMBA_AXI_CACHE
       , .M_AWCACHE   (MEM_AWCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .M_AWPROT    (MEM_AWPROT      )
       `endif
       , .M_AWVALID   (MEM_AWVALID     )
       , .M_AWREADY   (MEM_AWREADY     )
       `ifdef AMBA_AXI4
       , .M_AWQOS     (MEM_AWQOS       )
       , .M_AWREGION  (MEM_AWREGION    )
       `endif
       , .M_WID       (MEM_WID[WIDTH_ID-1:0])
       , .M_WDATA     (MEM_WDATA       )
       , .M_WSTRB     (MEM_WSTRB       )
       , .M_WLAST     (MEM_WLAST       )
       , .M_WVALID    (MEM_WVALID      )
       , .M_WREADY    (MEM_WREADY      )
       , .M_BID       (MEM_BID[WIDTH_ID-1:0])
       , .M_BRESP     (MEM_BRESP       )
       , .M_BVALID    (MEM_BVALID      )
       , .M_BREADY    (MEM_BREADY      )
       , .M_ARID      (MEM_ARID[WIDTH_ID-1:0])
       , .M_ARADDR    (MEM_ARADDR      )
       , .M_ARLEN     (MEM_ARLEN       )
       , .M_ARLOCK    (MEM_ARLOCK      )
       , .M_ARSIZE    (MEM_ARSIZE      )
       , .M_ARBURST   (MEM_ARBURST     )
       `ifdef AMBA_AXI_CACHE
       , .M_ARCACHE   (MEM_ARCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .M_ARPROT    (MEM_ARPROT      )
       `endif
       , .M_ARVALID   (MEM_ARVALID     )
       , .M_ARREADY   (MEM_ARREADY     )
       `ifdef AMBA_AXI4
       , .M_ARQOS     (MEM_ARQOS       )
       , .M_ARREGION  (MEM_ARREGION    )
       `endif
       , .M_RID       (MEM_RID[WIDTH_ID-1:0])
       , .M_RDATA     (MEM_RDATA       )
       , .M_RRESP     (MEM_RRESP       )
       , .M_RLAST     (MEM_RLAST       )
       , .M_RVALID    (MEM_RVALID      )
       , .M_RREADY    (MEM_RREADY      )
       , .AXIS_CLK    (AXIS_CLK     )
       , .AXIS_TREADY (AXIS_TREADY  )
       , .AXIS_TVALID (AXIS_TVALID  )
       , .AXIS_TDATA  (AXIS_TDATA   )
       , .AXIS_TSTRB  (AXIS_TSTRB   )
       , .AXIS_TLAST  (AXIS_TLAST   )
       , .AXIS_TSTART (AXIS_TSTART  )
       , .PRESETn     (PRESETn   )
       , .PCLK        (PCLK      )
       , .PSEL        (PSEL      )
       , .PENABLE     (PENABLE   )
       , .PADDR       (PADDR     )
       , .PWRITE      (PWRITE    )
       , .PRDATA      (PRDATA    )
       , .PWDATA      (PWDATA    )
       , .PREADY      (PREADY    )
       , .PSLVERR     (PSLVERR   )
       , .PSTRB       (PSTRB     )
       , .PPROT       (PPROT     )
       , .IRQ         (IRQ       )
   );
   assign MEM_AWID[WIDTH_SID-1:WIDTH_ID] = MEM_MID;
   assign MEM_WID [WIDTH_SID-1:WIDTH_ID] = MEM_MID;
   assign MEM_ARID[WIDTH_SID-1:WIDTH_ID] = MEM_MID;
   //---------------------------------------------------------
   bfm_apb    #(.APB_AW(APB_AW)
               ,.APB_DW(APB_DW)
               ,.AXIS_WIDTH_DATA(STREAM_WIDTH_DATA)
               ,.AXIS_WIDTH_DS  (STREAM_WIDTH_DS  )
               ,.AXI_WIDTH_AD   (WIDTH_AD     )
               ,.AXI_WIDTH_DA   (WIDTH_DA     ))
   u_bfm(
        .PRESETn ( PRESETn )
      , .PCLK    ( PCLK    )
      , .PSEL    ( PSEL    )
      , .PENABLE ( PENABLE )
      , .PADDR   ( PADDR   )
      , .PWRITE  ( PWRITE  )
      , .PRDATA  ( PRDATA  )
      , .PWDATA  ( PWDATA  )
      , .PREADY  ( PREADY  )
      , .PSLVERR ( PSLVERR )
      , .PSTRB   ( PSTRB   )
      , .PPROT   ( PPROT   )
      , .IRQ     ( IRQ     )
      , .ARESETn     (ARESETn      )
      , .AXIS_CLK    (AXIS_CLK     )
      , .AXIS_TREADY (AXIS_TREADY  )
      , .AXIS_TVALID (AXIS_TVALID  )
      , .AXIS_TDATA  (AXIS_TDATA   )
      , .AXIS_TSTRB  (AXIS_TSTRB   )
      , .AXIS_TLAST  (AXIS_TLAST   )
      , .AXIS_TSTART (AXIS_TSTART  )
   );
   //---------------------------------------------------------
   mem_axi   #(.AXI_WIDTH_CID  (WIDTH_CID)// Channel ID width in bits
              ,.AXI_WIDTH_ID   (WIDTH_ID )// ID width in bits
              ,.AXI_WIDTH_AD   (WIDTH_AD )// address width
              ,.AXI_WIDTH_DA   (WIDTH_DA )// data width
              ,.AXI_WIDTH_DS   (WIDTH_DS )// data strobe width
              ,.ADDR_LENGTH    (12) // effective addre bits
             )
   u_mem  (
          .ARESETn  (ARESETn           )
        , .ACLK     (ACLK              )
        , .AWID     (MEM_AWID          )
        , .AWADDR   (MEM_AWADDR        )
        , .AWLEN    (MEM_AWLEN         )
        , .AWLOCK   (MEM_AWLOCK        )
        , .AWSIZE   (MEM_AWSIZE        )
        , .AWBURST  (MEM_AWBURST       )
        `ifdef AMBA_AXI_CACHE
        , .AWCACHE  (MEM_AWCACHE       )
        `endif
        `ifdef AMBA_AXI_PROT
        , .AWPROT   (MEM_AWPROT        )
        `endif
        , .AWVALID  (MEM_AWVALID       )
        , .AWREADY  (MEM_AWREADY       )
        `ifdef AMBA_AXI4
        , .AWQOS    (MEM_AWQOS         )
        , .AWREGION (MEM_AWREGION      )
        `endif
        , .WID      (MEM_WID           )
        , .WDATA    (MEM_WDATA         )
        , .WSTRB    (MEM_WSTRB         )
        , .WLAST    (MEM_WLAST         )
        , .WVALID   (MEM_WVALID        )
        , .WREADY   (MEM_WREADY        )
        , .BID      (MEM_BID           )
        , .BRESP    (MEM_BRESP         )
        , .BVALID   (MEM_BVALID        )
        , .BREADY   (MEM_BREADY        )
        , .ARID     (MEM_ARID          )
        , .ARADDR   (MEM_ARADDR        )
        , .ARLEN    (MEM_ARLEN         )
        , .ARLOCK   (MEM_ARLOCK        )
        , .ARSIZE   (MEM_ARSIZE        )
        , .ARBURST  (MEM_ARBURST       )
        `ifdef AMBA_AXI_CACHE
        , .ARCACHE  (MEM_ARCACHE       )
        `endif
        `ifdef AMBA_AXI_PROT
        , .ARPROT   (MEM_ARPROT        )
        `endif
        , .ARVALID  (MEM_ARVALID       )
        , .ARREADY  (MEM_ARREADY       )
        `ifdef AMBA_AXI4
        , .ARQOS    (MEM_ARQOS         )
        , .ARREGION (MEM_ARREGION      )
        `endif
        , .RID      (MEM_RID           )
        , .RDATA    (MEM_RDATA         )
        , .RRESP    (MEM_RRESP         )
        , .RLAST    (MEM_RLAST         )
        , .RVALID   (MEM_RVALID        )
        , .RREADY   (MEM_RREADY        )
        , .CSYSREQ  (1'b1              )
        , .CSYSACK  ()
        , .CACTIVE  ()
   );
   //---------------------------------------------------------
   initial begin
       wait (ARESETn==1'b0);
       wait (ARESETn==1'b1);
       repeat (5) @ (posedge ACLK);
       wait(u_bfm.done==1'b1);
       repeat (5) @ (posedge ACLK);
       repeat (50) @ (posedge ACLK);
       $finish(2);
   end
   //---------------------------------------------------------
   `ifdef VCD
   initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0);
   end
   `endif
   //---------------------------------------------------------
endmodule
//----------------------------------------------------------------
// Revision History
//
// 2015.07.12: Started by Ando Ki (adki@future-ds.com)
//----------------------------------------------------------------
