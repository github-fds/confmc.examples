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

   assign M_MID             [0] =4'h0;
   wire [15:0] GPOUT;
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
        ,                  .ARESETn  ( ARESETn      )
        ,                  .ACLK     ( ACLK         )
        ,                  .MID      ( M_MID     [0])
        ,                  .AWID     ( M_AWID    [0]) //[AXI_WIDTH_ID-1:0]
        ,                  .AWADDR   ( M_AWADDR  [0])
        ,                  .AWLEN    ( M_AWLEN   [0])
        ,                  .AWLOCK   ( M_AWLOCK  [0])
        ,                  .AWSIZE   ( M_AWSIZE  [0])
        ,                  .AWBURST  ( M_AWBURST [0])
        `ifdef AMBA_AXI_CACHE
        ,                  .AWCACHE  ( M_AWCACHE [0])
        `endif
        `ifdef AMBA_AXI_PROT
        ,                  .AWPROT   ( M_AWPROT  [0])
        `endif
        ,                  .AWVALID  ( M_AWVALID [0])
        ,                  .AWREADY  ( M_AWREADY [0])
        `ifdef AMBA_AXI4
        ,                  .AWQOS    ( M_AWQOS   [0])
        ,                  .AWREGION ( M_AWREGION[0])
        `endif
        ,                  .WID      ( M_WID     [0]) //[AXI_WIDTH_ID-1:0]
        ,                  .WDATA    ( M_WDATA   [0])
        ,                  .WSTRB    ( M_WSTRB   [0])
        ,                  .WLAST    ( M_WLAST   [0])
        ,                  .WVALID   ( M_WVALID  [0])
        ,                  .WREADY   ( M_WREADY  [0])
        ,                  .BID      ( M_BID     [0][AXI_WIDTH_ID-1:0])
        ,                  .BRESP    ( M_BRESP   [0])
        ,                  .BVALID   ( M_BVALID  [0])
        ,                  .BREADY   ( M_BREADY  [0])
        ,                  .ARID     ( M_ARID    [0]) //[AXI_WIDTH_ID-1:0]
        ,                  .ARADDR   ( M_ARADDR  [0])
        ,                  .ARLEN    ( M_ARLEN   [0])
        ,                  .ARLOCK   ( M_ARLOCK  [0])
        ,                  .ARSIZE   ( M_ARSIZE  [0])
        ,                  .ARBURST  ( M_ARBURST [0])
        `ifdef AMBA_AXI_CACHE
        ,                  .ARCACHE  ( M_ARCACHE [0])
        `endif
        `ifdef AMBA_AXI_PROT
        ,                  .ARPROT   ( M_ARPROT  [0])
        `endif
        ,                  .ARVALID  ( M_ARVALID [0])
        ,                  .ARREADY  ( M_ARREADY [0])
        `ifdef AMBA_AXI4
        ,                  .ARQOS    ( M_ARQOS   [0])
        ,                  .ARREGION ( M_ARREGION[0])
        `endif
        ,                  .RID      ( M_RID     [0][AXI_WIDTH_ID-1:0]) //[AXI_WIDTH_ID-1:0]
        ,                  .RDATA    ( M_RDATA   [0])
        ,                  .RRESP    ( M_RRESP   [0])
        ,                  .RLAST    ( M_RLAST   [0])
        ,                  .RVALID   ( M_RVALID  [0])
        ,                  .RREADY   ( M_RREADY  [0])
        , .IRQ      ( 1'b0     )
        , .FIQ      ( 1'b0     )
        , .GPOUT    ( GPOUT    )
        , .GPIN     ( GPOUT    )
   );
   //---------------------------------------------------------------------------
   `ifdef SIM
   `define BUS_DELAY  #(1)
   `else
   `define BUS_DELAY
   `endif
   //---------------------------------------------------------------------------
   wire  [AXI_WIDTH_CID-1:0]    `BUS_DELAY M2S_MID     , S2M_MID     ;
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY M2S_AWID    , S2M_AWID    ;
   wire  [AXI_WIDTH_AD-1:0]     `BUS_DELAY M2S_AWADDR  , S2M_AWADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 `BUS_DELAY M2S_AWLEN   , S2M_AWLEN   ;
   wire                         `BUS_DELAY M2S_AWLOCK  , S2M_AWLOCK  ;
   `else
   wire  [ 3:0]                 `BUS_DELAY M2S_AWLEN   , S2M_AWLEN   ;
   wire  [ 1:0]                 `BUS_DELAY M2S_AWLOCK  , S2M_AWLOCK  ;
   `endif
   wire  [ 2:0]                 `BUS_DELAY M2S_AWSIZE  , S2M_AWSIZE  ;
   wire  [ 1:0]                 `BUS_DELAY M2S_AWBURST , S2M_AWBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 `BUS_DELAY M2S_AWCACHE , S2M_AWCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 `BUS_DELAY M2S_AWPROT  , S2M_AWPROT  ;
   `endif
   wire                         `BUS_DELAY M2S_AWVALID , S2M_AWVALID ;
   wire                         `BUS_DELAY M2S_AWREADY , S2M_AWREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 `BUS_DELAY M2S_AWQOS   , S2M_AWQOS   ;
   wire  [ 3:0]                 `BUS_DELAY M2S_AWREGION, S2M_AWREGION;
   `endif
   `ifdef AMBA_AXI_AWUSER
   wire  [AXI_WIDTH_AWUSER-1:0] `BUS_DELAY M2S_AWUSER  , S2M_AWUSER  ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY M2S_WID     , S2M_WID     ;
   wire  [AXI_WIDTH_DA-1:0]     `BUS_DELAY M2S_WDATA   , S2M_WDATA   ;
   wire  [AXI_WIDTH_DS-1:0]     `BUS_DELAY M2S_WSTRB   , S2M_WSTRB   ;
   wire                         `BUS_DELAY M2S_WLAST   , S2M_WLAST   ;
   wire                         `BUS_DELAY M2S_WVALID  , S2M_WVALID  ;
   wire                         `BUS_DELAY M2S_WREADY  , S2M_WREADY  ;
   `ifdef AMBA_AXI_WUSER
   wire  [AXI_WIDTH_WUSER-1:0]  `BUS_DELAY M2S_WUSER   , S2M_WUSER   ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY M2S_BID     , S2M_BID     ; wire [AXI_WIDTH_CID-1:0] M2S_BID_tmp, S2M_BID_tmp;
   wire  [ 1:0]                 `BUS_DELAY M2S_BRESP   , S2M_BRESP   ;
   wire                         `BUS_DELAY M2S_BVALID  , S2M_BVALID  ;
   wire                         `BUS_DELAY M2S_BREADY  , S2M_BREADY  ;
   `ifdef AMBA_AXI_BUSER
   wire  [AXI_WIDTH_BUSER-1:0]  `BUS_DELAY M2S_BUSER   , S2M_BUSER   ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY M2S_ARID    , S2M_ARID    ;
   wire  [AXI_WIDTH_AD-1:0]     `BUS_DELAY M2S_ARADDR  , S2M_ARADDR  ;
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 `BUS_DELAY M2S_ARLEN   , S2M_ARLEN   ;
   wire                         `BUS_DELAY M2S_ARLOCK  , S2M_ARLOCK  ;
   `else
   wire  [ 3:0]                 `BUS_DELAY M2S_ARLEN   , S2M_ARLEN   ;
   wire  [ 1:0]                 `BUS_DELAY M2S_ARLOCK  , S2M_ARLOCK  ;
   `endif
   wire  [ 2:0]                 `BUS_DELAY M2S_ARSIZE  , S2M_ARSIZE  ;
   wire  [ 1:0]                 `BUS_DELAY M2S_ARBURST , S2M_ARBURST ;
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 `BUS_DELAY M2S_ARCACHE , S2M_ARCACHE ;
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 `BUS_DELAY M2S_ARPROT  , S2M_ARPROT  ;
   `endif
   wire                         `BUS_DELAY M2S_ARVALID , S2M_ARVALID ;
   wire                         `BUS_DELAY M2S_ARREADY , S2M_ARREADY ;
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 `BUS_DELAY M2S_ARQOS   , S2M_ARQOS   ;
   wire  [ 3:0]                 `BUS_DELAY M2S_ARREGION, S2M_ARREGION;
   `endif
   `ifdef AMBA_AXI_ARUSER
   wire  [AXI_WIDTH_ARUSER-1:0] `BUS_DELAY M2S_ARUSER  , S2M_ARUSER  ;
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY M2S_RID     , S2M_RID     ; wire [AXI_WIDTH_CID-1:0] M2S_RID_tmp, S2M_RID_tmp;
   wire  [AXI_WIDTH_DA-1:0]     `BUS_DELAY M2S_RDATA   , S2M_RDATA   ;
   wire  [ 1:0]                 `BUS_DELAY M2S_RRESP   , S2M_RRESP   ;
   wire                         `BUS_DELAY M2S_RLAST   , S2M_RLAST   ;
   wire                         `BUS_DELAY M2S_RVALID  , S2M_RVALID  ;
   wire                         `BUS_DELAY M2S_RREADY  , S2M_RREADY  ;
   `ifdef AMBA_AXI_RUSER
   wire  [AXI_WIDTH_RUSER-1:0]  `BUS_DELAY M2S_RUSER   , S2M_RUSER   ;
   `endif
   //---------------------------------------------------------------------------
   bram_axi_dual #(.AXI_WIDTH_CID  (AXI_WIDTH_CID  )// Channel ID width in bits
                  ,.AXI_WIDTH_ID   (AXI_WIDTH_ID   )// ID width in bits
                  ,.AXI_WIDTH_AD   (AXI_WIDTH_AD   )// address width
                  ,.AXI_WIDTH_DA   (AXI_WIDTH_DA   )// data width
                  ,.P_SIZE_IN_BYTES(P_SIZE_MEM_M2S )
               )
   u_bram_m2s (
       .ARESETn            ( ARESETn             )
     , .ACLK               ( ACLK                )
     , .S0_AWID            ( S_AWID           [1])
     , .S0_AWADDR          ( S_AWADDR         [1])
     `ifdef AMBA_AXI4
     , .S0_AWLEN           ( S_AWLEN          [1])
     , .S0_AWLOCK          ( S_AWLOCK         [1])
     `else
     , .S0_AWLEN           ( S_AWLEN          [1])
     , .S0_AWLOCK          ( S_AWLOCK         [1])
     `endif
     , .S0_AWSIZE          ( S_AWSIZE         [1])
     , .S0_AWBURST         ( S_AWBURST        [1])
     `ifdef AMBA_AXI_CACHE
     , .S0_AWCACHE         ( S_AWCACHE        [1])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_AWPROT          ( S_AWPROT         [1])
     `endif
     , .S0_AWVALID         ( S_AWVALID        [1])
     , .S0_AWREADY         ( S_AWREADY        [1])
     `ifdef AMBA_AXI4
     , .S0_AWQOS           ( S_AWQOS          [1])
     , .S0_AWREGION        ( S_AWREGION       [1])
     `endif
     , .S0_WID             ( S_WID            [1])
     , .S0_WDATA           ( S_WDATA          [1])
     , .S0_WSTRB           ( S_WSTRB          [1])
     , .S0_WLAST           ( S_WLAST          [1])
     , .S0_WVALID          ( S_WVALID         [1])
     , .S0_WREADY          ( S_WREADY         [1])
     , .S0_BID             ( S_BID            [1])
     , .S0_BRESP           ( S_BRESP          [1])
     , .S0_BVALID          ( S_BVALID         [1])
     , .S0_BREADY          ( S_BREADY         [1])
     , .S0_ARID            ( S_ARID           [1])
     , .S0_ARADDR          ( S_ARADDR         [1])
     `ifdef AMBA_AXI4
     , .S0_ARLEN           ( S_ARLEN          [1])
     , .S0_ARLOCK          ( S_ARLOCK         [1])
     `else
     , .S0_ARLEN           ( S_ARLEN          [1])
     , .S0_ARLOCK          ( S_ARLOCK         [1])
     `endif
     , .S0_ARSIZE          ( S_ARSIZE         [1])
     , .S0_ARBURST         ( S_ARBURST        [1])
     `ifdef AMBA_AXI_CACHE
     , .S0_ARCACHE         ( S_ARCACHE        [1])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_ARPROT          ( S_ARPROT         [1])
     `endif
     , .S0_ARVALID         ( S_ARVALID        [1])
     , .S0_ARREADY         ( S_ARREADY        [1])
     `ifdef AMBA_AXI4
     , .S0_ARQOS           ( S_ARQOS          [1])
     , .S0_ARREGION        ( S_ARREGION       [1])
     `endif
     , .S0_RID             ( S_RID            [1])
     , .S0_RDATA           ( S_RDATA          [1])
     , .S0_RRESP           ( S_RRESP          [1])
     , .S0_RLAST           ( S_RLAST          [1])
     , .S0_RVALID          ( S_RVALID         [1])
     , .S0_RREADY          ( S_RREADY         [1])
     , .S1_AWID            ({{AXI_WIDTH_CID{1'b0}},M2S_AWID})
     , .S1_AWADDR          ( M2S_AWADDR   )
     `ifdef AMBA_AXI4
     , .S1_AWLEN           ( M2S_AWLEN    )
     , .S1_AWLOCK          ( M2S_AWLOCK   )
     `else
     , .S1_AWLEN           ( M2S_AWLEN    )
     , .S1_AWLOCK          ( M2S_AWLOCK   )
     `endif
     , .S1_AWSIZE          ( M2S_AWSIZE   )
     , .S1_AWBURST         ( M2S_AWBURST  )
     `ifdef AMBA_AXI_CACHE
     , .S1_AWCACHE         ( M2S_AWCACHE  )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_AWPROT          ( M2S_AWPROT   )
     `endif
     , .S1_AWVALID         ( M2S_AWVALID  )
     , .S1_AWREADY         ( M2S_AWREADY  )
     `ifdef AMBA_AXI4
     , .S1_AWQOS           ( M2S_AWQOS    )
     , .S1_AWREGION        ( M2S_AWREGION )
     `endif
     , .S1_WID             ({{AXI_WIDTH_CID{1'b0}},M2S_WID})
     , .S1_WDATA           ( M2S_WDATA    )
     , .S1_WSTRB           ( M2S_WSTRB    )
     , .S1_WLAST           ( M2S_WLAST    )
     , .S1_WVALID          ( M2S_WVALID   )
     , .S1_WREADY          ( M2S_WREADY   )
     , .S1_BID             ({M2S_BID_tmp,M2S_BID})
     , .S1_BRESP           ( M2S_BRESP    )
     , .S1_BVALID          ( M2S_BVALID   )
     , .S1_BREADY          ( M2S_BREADY   )
     , .S1_ARID            ({{AXI_WIDTH_CID{1'b0}},M2S_ARID})
     , .S1_ARADDR          ( M2S_ARADDR   )
     `ifdef AMBA_AXI4
     , .S1_ARLEN           ( M2S_ARLEN    )
     , .S1_ARLOCK          ( M2S_ARLOCK   )
     `else
     , .S1_ARLEN           ( M2S_ARLEN    )
     , .S1_ARLOCK          ( M2S_ARLOCK   )
     `endif
     , .S1_ARSIZE          ( M2S_ARSIZE   )
     , .S1_ARBURST         ( M2S_ARBURST  )
     `ifdef AMBA_AXI_CACHE   M2S          
     , .S1_ARCACHE         ( M2S_ARCACHE  )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_ARPROT          ( M2S_ARPROT   )
     `endif
     , .S1_ARVALID         ( M2S_ARVALID  )
     , .S1_ARREADY         ( M2S_ARREADY  )
     `ifdef AMBA_AXI4
     , .S1_ARQOS           ( M2S_ARQOS    )
     , .S1_ARREGION        ( M2S_ARREGION )
     `endif
     , .S1_RID             ({M2S_RID_tmp,M2S_RID})
     , .S1_RDATA           ( M2S_RDATA    )
     , .S1_RRESP           ( M2S_RRESP    )
     , .S1_RLAST           ( M2S_RLAST    )
     , .S1_RVALID          ( M2S_RVALID   )
     , .S1_RREADY          ( M2S_RREADY   )
   );
   //---------------------------------------------------------------------------
   bram_axi_dual #(.AXI_WIDTH_CID  (AXI_WIDTH_CID  )// Channel ID width in bits
                  ,.AXI_WIDTH_ID   (AXI_WIDTH_ID   )// ID width in bits
                  ,.AXI_WIDTH_AD   (AXI_WIDTH_AD   )// address width
                  ,.AXI_WIDTH_DA   (AXI_WIDTH_DA   )// data width
                  ,.P_SIZE_IN_BYTES(P_SIZE_MEM_S2M )
               )
   u_bram_s2m(
       .ARESETn            ( ARESETn             )
     , .ACLK               ( ACLK                )
     , .S0_AWID            ( S_AWID           [2])
     , .S0_AWADDR          ( S_AWADDR         [2])
     `ifdef AMBA_AXI4
     , .S0_AWLEN           ( S_AWLEN          [2])
     , .S0_AWLOCK          ( S_AWLOCK         [2])
     `else
     , .S0_AWLEN           ( S_AWLEN          [2])
     , .S0_AWLOCK          ( S_AWLOCK         [2])
     `endif
     , .S0_AWSIZE          ( S_AWSIZE         [2])
     , .S0_AWBURST         ( S_AWBURST        [2])
     `ifdef AMBA_AXI_CACHE
     , .S0_AWCACHE         ( S_AWCACHE        [2])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_AWPROT          ( S_AWPROT         [2])
     `endif
     , .S0_AWVALID         ( S_AWVALID        [2])
     , .S0_AWREADY         ( S_AWREADY        [2])
     `ifdef AMBA_AXI4
     , .S0_AWQOS           ( S_AWQOS          [2])
     , .S0_AWREGION        ( S_AWREGION       [2])
     `endif
     , .S0_WID             ( S_WID            [2])
     , .S0_WDATA           ( S_WDATA          [2])
     , .S0_WSTRB           ( S_WSTRB          [2])
     , .S0_WLAST           ( S_WLAST          [2])
     , .S0_WVALID          ( S_WVALID         [2])
     , .S0_WREADY          ( S_WREADY         [2])
     , .S0_BID             ( S_BID            [2])
     , .S0_BRESP           ( S_BRESP          [2])
     , .S0_BVALID          ( S_BVALID         [2])
     , .S0_BREADY          ( S_BREADY         [2])
     , .S0_ARID            ( S_ARID           [2])
     , .S0_ARADDR          ( S_ARADDR         [2])
     `ifdef AMBA_AXI4
     , .S0_ARLEN           ( S_ARLEN          [2])
     , .S0_ARLOCK          ( S_ARLOCK         [2])
     `else
     , .S0_ARLEN           ( S_ARLEN          [2])
     , .S0_ARLOCK          ( S_ARLOCK         [2])
     `endif
     , .S0_ARSIZE          ( S_ARSIZE         [2])
     , .S0_ARBURST         ( S_ARBURST        [2])
     `ifdef AMBA_AXI_CACHE
     , .S0_ARCACHE         ( S_ARCACHE        [2])
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_ARPROT          ( S_ARPROT         [2])
     `endif
     , .S0_ARVALID         ( S_ARVALID        [2])
     , .S0_ARREADY         ( S_ARREADY        [2])
     `ifdef AMBA_AXI4
     , .S0_ARQOS           ( S_ARQOS          [2])
     , .S0_ARREGION        ( S_ARREGION       [2])
     `endif
     , .S0_RID             ( S_RID            [2])
     , .S0_RDATA           ( S_RDATA          [2])
     , .S0_RRESP           ( S_RRESP          [2])
     , .S0_RLAST           ( S_RLAST          [2])
     , .S0_RVALID          ( S_RVALID         [2])
     , .S0_RREADY          ( S_RREADY         [2])
     , .S1_AWID            ({{AXI_WIDTH_CID{1'b0}},S2M_AWID})
     , .S1_AWADDR          ( S2M_AWADDR   )
     `ifdef AMBA_AXI4
     , .S1_AWLEN           ( S2M_AWLEN    )
     , .S1_AWLOCK          ( S2M_AWLOCK   )
     `else
     , .S1_AWLEN           ( S2M_AWLEN    )
     , .S1_AWLOCK          ( S2M_AWLOCK   )
     `endif
     , .S1_AWSIZE          ( S2M_AWSIZE   )
     , .S1_AWBURST         ( S2M_AWBURST  )
     `ifdef AMBA_AXI_CACHE
     , .S1_AWCACHE         ( S2M_AWCACHE  )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_AWPROT          ( S2M_AWPROT   )
     `endif
     , .S1_AWVALID         ( S2M_AWVALID  )
     , .S1_AWREADY         ( S2M_AWREADY  )
     `ifdef AMBA_AXI4
     , .S1_AWQOS           ( S2M_AWQOS    )
     , .S1_AWREGION        ( S2M_AWREGION )
     `endif
     , .S1_WID             ({{AXI_WIDTH_CID{1'b0}},S2M_WID})
     , .S1_WDATA           ( S2M_WDATA    )
     , .S1_WSTRB           ( S2M_WSTRB    )
     , .S1_WLAST           ( S2M_WLAST    )
     , .S1_WVALID          ( S2M_WVALID   )
     , .S1_WREADY          ( S2M_WREADY   )
     , .S1_BID             ({S2M_BID_tmp,S2M_BID})
     , .S1_BRESP           ( S2M_BRESP    )
     , .S1_BVALID          ( S2M_BVALID   )
     , .S1_BREADY          ( S2M_BREADY   )
     , .S1_ARID            ({{AXI_WIDTH_CID{1'b0}},S2M_ARID})
     , .S1_ARADDR          ( S2M_ARADDR   )
     `ifdef AMBA_AXI4
     , .S1_ARLEN           ( S2M_ARLEN    )
     , .S1_ARLOCK          ( S2M_ARLOCK   )
     `else
     , .S1_ARLEN           ( S2M_ARLEN    )
     , .S1_ARLOCK          ( S2M_ARLOCK   )
     `endif
     , .S1_ARSIZE          ( S2M_ARSIZE   )
     , .S1_ARBURST         ( S2M_ARBURST  )
     `ifdef AMBA_AXI_CACHE   S2M          
     , .S1_ARCACHE         ( S2M_ARCACHE  )
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_ARPROT          ( S2M_ARPROT   )
     `endif
     , .S1_ARVALID         ( S2M_ARVALID  )
     , .S1_ARREADY         ( S2M_ARREADY  )
     `ifdef AMBA_AXI4
     , .S1_ARQOS           ( S2M_ARQOS    )
     , .S1_ARREGION        ( S2M_ARREGION )
     `endif
     , .S1_RID             ({S2M_RID_tmp,S2M_RID})
     , .S1_RDATA           ( S2M_RDATA    )
     , .S1_RRESP           ( S2M_RRESP    )
     , .S1_RLAST           ( S2M_RLAST    )
     , .S1_RVALID          ( S2M_RVALID   )
     , .S1_RREADY          ( S2M_RREADY   )
   );
   //---------------------------------------------------------
   // AXI-Stream Port
   // M2S stream port carries {16-bit image, 16-bit real}
   localparam STREAM_WIDTH_DATA_M2S=32
            , STREAM_WIDTH_DS_M2S=(STREAM_WIDTH_DATA_M2S/8);
   wire              AXIS_CLK   = SERIAL_CLK;
   wire                               M2S_AXIS_TREADY;
   wire                               M2S_AXIS_TVALID;
   wire  [STREAM_WIDTH_DATA_M2S-1:0]  M2S_AXIS_TDATA ; // {16-bit imag,16-bit real}
   wire  [STREAM_WIDTH_DS_M2S-1:0]    M2S_AXIS_TSTRB ;
   wire                               M2S_AXIS_TLAST ;
   wire                               M2S_AXIS_TSTART;
   //---------------------------------------------------------------------------
   axi_mem2stream
                 `ifdef SIM
                  #(.AXI_MST_ID   (1        ) // Master ID
                   ,.AXI_WIDTH_CID(AXI_WIDTH_CID)
                   ,.AXI_WIDTH_ID (AXI_WIDTH_ID ) // ID width in bits
                   ,.AXI_WIDTH_AD (AXI_WIDTH_AD ) // address width
                   ,.AXI_WIDTH_DA (AXI_WIDTH_DA ) // data width
                   ,.AXIS_WIDTH_DATA(STREAM_WIDTH_DATA_M2S)
                   ,.AXIS_WIDTH_DS  (STREAM_WIDTH_DS_M2S  ))
                   `endif
   u_mem2stream (
         .ARESETn           (ARESETn           )
       , .ACLK              (ACLK              )
       , .M_MID             (M2S_MID           )
       , .M_AWID            (M2S_AWID[AXI_WIDTH_ID-1:0])
       , .M_AWADDR          (M2S_AWADDR        )
       , .M_AWLEN           (M2S_AWLEN         )
       , .M_AWLOCK          (M2S_AWLOCK        )
       , .M_AWSIZE          (M2S_AWSIZE        )
       , .M_AWBURST         (M2S_AWBURST       )
       `ifdef AMBA_AXI_CACHE
       , .M_AWCACHE         (M2S_AWCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .M_AWPROT          (M2S_AWPROT      )
       `endif
       , .M_AWVALID         (M2S_AWVALID     )
       , .M_AWREADY         (M2S_AWREADY     )
       `ifdef AMBA_AXI4
       , .M_AWQOS           (M2S_AWQOS       )
       , .M_AWREGION        (M2S_AWREGION    )
       `endif
       , .M_WID             (M2S_WID[AXI_WIDTH_ID-1:0])
       , .M_WDATA           (M2S_WDATA       )
       , .M_WSTRB           (M2S_WSTRB       )
       , .M_WLAST           (M2S_WLAST       )
       , .M_WVALID          (M2S_WVALID      )
       , .M_WREADY          (M2S_WREADY      )
       , .M_BID             (M2S_BID[AXI_WIDTH_ID-1:0])
       , .M_BRESP           (M2S_BRESP       )
       , .M_BVALID          (M2S_BVALID      )
       , .M_BREADY          (M2S_BREADY      )
       , .M_ARID            (M2S_ARID[AXI_WIDTH_ID-1:0])
       , .M_ARADDR          (M2S_ARADDR      )
       , .M_ARLEN           (M2S_ARLEN       )
       , .M_ARLOCK          (M2S_ARLOCK      )
       , .M_ARSIZE          (M2S_ARSIZE      )
       , .M_ARBURST         (M2S_ARBURST     )
       `ifdef AMBA_AXI_CACHE
       , .M_ARCACHE         (M2S_ARCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .M_ARPROT          (M2S_ARPROT      )
       `endif
       , .M_ARVALID         (M2S_ARVALID     )
       , .M_ARREADY         (M2S_ARREADY     )
       `ifdef AMBA_AXI4
       , .M_ARQOS           (M2S_ARQOS       )
       , .M_ARREGION        (M2S_ARREGION    )
       `endif
       , .M_RID             (M2S_RID[AXI_WIDTH_ID-1:0])
       , .M_RDATA           (M2S_RDATA       )
       , .M_RRESP           (M2S_RRESP       )
       , .M_RLAST           (M2S_RLAST       )
       , .M_RVALID          (M2S_RVALID      )
       , .M_RREADY          (M2S_RREADY      )
       , .AXIS_CLK          (    AXIS_CLK     )
       , .AXIS_TREADY       (M2S_AXIS_TREADY  )
       , .AXIS_TVALID       (M2S_AXIS_TVALID  )
       , .AXIS_TDATA        (M2S_AXIS_TDATA   )
       , .AXIS_TSTRB        (M2S_AXIS_TSTRB   )
       , .AXIS_TLAST        (M2S_AXIS_TLAST   )
       , .AXIS_TSTART       (M2S_AXIS_TSTART  )
       , .PRESETn           (PRESETn      )
       , .PCLK              (PCLK         )
       , .PSEL              (PSEL      [1])
       , .PENABLE           (PENABLE      )
       , .PADDR             (PADDR        )
       , .PWRITE            (PWRITE       )
       , .PRDATA            (PRDATA    [1])
       , .PWDATA            (PWDATA       )
       , .PREADY            (PREADY    [1])
       , .PSLVERR           (PSLVERR   [1])
       , .PSTRB             (PSTRB        )
       , .PPROT             (PPROT        )
       , .IRQ               (             )
   );
   //---------------------------------------------------------
   // AXI-Stream Port
   // S2M stream port carries {32-bit image, 32-bit real}
   localparam STREAM_WIDTH_DATA_S2M=64
            , STREAM_WIDTH_DS_S2M=(STREAM_WIDTH_DATA_S2M/8);
   wire                              S2M_AXIS_TREADY;
   wire                              S2M_AXIS_TVALID;
   wire  [STREAM_WIDTH_DATA_S2M-1:0] S2M_AXIS_TDATA ; // {32-bit imag,3216-bit real}
   wire  [STREAM_WIDTH_DS_S2M-1:0]   S2M_AXIS_TSTRB ={STREAM_WIDTH_DS_S2M{1'b1}};
   wire                              S2M_AXIS_TLAST ;
   wire                              S2M_AXIS_TSTART=1'b0;
   wire  [ 7:0]                      S2M_AXIS_TUSER ;
   //---------------------------------------------------------------------------
   axi_stream2mem 
                 `ifdef SIM
                  #(.AXI_MST_ID   (1        ) // Master ID
                   ,.AXI_WIDTH_CID(AXI_WIDTH_CID)
                   ,.AXI_WIDTH_ID (AXI_WIDTH_ID ) // ID width in bits
                   ,.AXI_WIDTH_AD (AXI_WIDTH_AD ) // address width
                   ,.AXI_WIDTH_DA (AXI_WIDTH_DA ) // data width
                   ,.AXIS_WIDTH_DATA(STREAM_WIDTH_DATA_S2M)
                   ,.AXIS_WIDTH_DS  (STREAM_WIDTH_DS_S2M  ))
                  `endif
   u_stream2mem (
         .ARESETn           (ARESETn           )
       , .ACLK              (ACLK              )
       , .M_MID             (S2M_MID           )
       , .M_AWID            (S2M_AWID[AXI_WIDTH_ID-1:0])
       , .M_AWADDR          (S2M_AWADDR        )
       , .M_AWLEN           (S2M_AWLEN         )
       , .M_AWLOCK          (S2M_AWLOCK        )
       , .M_AWSIZE          (S2M_AWSIZE        )
       , .M_AWBURST         (S2M_AWBURST       )
       `ifdef AMBA_AXI_CACHE
       , .M_AWCACHE         (S2M_AWCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .M_AWPROT          (S2M_AWPROT      )
       `endif
       , .M_AWVALID         (S2M_AWVALID     )
       , .M_AWREADY         (S2M_AWREADY     )
       `ifdef AMBA_AXI4
       , .M_AWQOS           (S2M_AWQOS       )
       , .M_AWREGION        (S2M_AWREGION    )
       `endif
       , .M_WID             (S2M_WID[AXI_WIDTH_ID-1:0])
       , .M_WDATA           (S2M_WDATA       )
       , .M_WSTRB           (S2M_WSTRB       )
       , .M_WLAST           (S2M_WLAST       )
       , .M_WVALID          (S2M_WVALID      )
       , .M_WREADY          (S2M_WREADY      )
       , .M_BID             (S2M_BID[AXI_WIDTH_ID-1:0])
       , .M_BRESP           (S2M_BRESP       )
       , .M_BVALID          (S2M_BVALID      )
       , .M_BREADY          (S2M_BREADY      )
       , .M_ARID            (S2M_ARID[AXI_WIDTH_ID-1:0])
       , .M_ARADDR          (S2M_ARADDR      )
       , .M_ARLEN           (S2M_ARLEN       )
       , .M_ARLOCK          (S2M_ARLOCK      )
       , .M_ARSIZE          (S2M_ARSIZE      )
       , .M_ARBURST         (S2M_ARBURST     )
       `ifdef AMBA_AXI_CACHE
       , .M_ARCACHE         (S2M_ARCACHE     )
       `endif
       `ifdef AMBA_AXI_PROT
       , .M_ARPROT          (S2M_ARPROT      )
       `endif
       , .M_ARVALID         (S2M_ARVALID     )
       , .M_ARREADY         (S2M_ARREADY     )
       `ifdef AMBA_AXI4
       , .M_ARQOS           (S2M_ARQOS       )
       , .M_ARREGION        (S2M_ARREGION    )
       `endif
       , .M_RID             (S2M_RID[AXI_WIDTH_ID-1:0])
       , .M_RDATA           (S2M_RDATA       )
       , .M_RRESP           (S2M_RRESP       )
       , .M_RLAST           (S2M_RLAST       )
       , .M_RVALID          (S2M_RVALID      )
       , .M_RREADY          (S2M_RREADY      )
       , .AXIS_CLK          (    AXIS_CLK     )
       , .AXIS_TREADY       (S2M_AXIS_TREADY  )
       , .AXIS_TVALID       (S2M_AXIS_TVALID  )
       , .AXIS_TDATA        (S2M_AXIS_TDATA   )
       , .AXIS_TSTRB        (S2M_AXIS_TSTRB   )
       , .AXIS_TLAST        (S2M_AXIS_TLAST   )
       , .AXIS_TSTART       (S2M_AXIS_TSTART  )
       , .PRESETn           (PRESETn      )
       , .PCLK              (PCLK         )
       , .PSEL              (PSEL      [2])
       , .PENABLE           (PENABLE      )
       , .PADDR             (PADDR        )
       , .PWRITE            (PWRITE       )
       , .PRDATA            (PRDATA    [2])
       , .PWDATA            (PWDATA       )
       , .PREADY            (PREADY    [2])
       , .PSLVERR           (PSLVERR   [2])
       , .PSTRB             (PSTRB        )
       , .PPROT             (PPROT        )
       , .IRQ               (             )
   );
   //---------------------------------------------------------------------------
   `DBG_DUT wire       XFFT_ARESETn      ;
   `DBG_DUT wire       CONFIG_AXIS_TREADY;
   `DBG_DUT wire       CONFIG_AXIS_TVALID;
   `DBG_DUT wire [7:0] CONFIG_AXIS_TDATA ;
   //---------------------------------------------------------------------------
   xfft_config
               `ifdef SIM
               #(.AXIS_WIDTH(8))
               `endif
   u_config (
        .PRESETn ( PRESETn    )
      , .PCLK    ( PCLK       )
      , .PENABLE ( PENABLE    )
      , .PADDR   ( PADDR      )
      , .PWRITE  ( PWRITE     )
      , .PWDATA  ( PWDATA     )
      , .PSEL    ( PSEL    [0])
      , .PRDATA  ( PRDATA  [0])
      , .axis_clk           ( AXIS_CLK           )
      , .axis_config_resetn ( XFFT_ARESETn       )
      , .axis_config_tready ( CONFIG_AXIS_TREADY )
      , .axis_config_tvalid ( CONFIG_AXIS_TVALID )
      , .axis_config_tdata  ( CONFIG_AXIS_TDATA  )
   );
   `ifdef AMBA_APB3
   assign PREADY [0]=1'b1;
   assign PSLVERR[0]=1'b0;
   `endif
   //---------------------------------------------------------------------------
   wire event_frame_started;
   wire event_tlast_unexpected;
   wire event_tlast_missing;
   wire event_status_channel_halt;
   wire event_data_in_channel_halt;
   wire event_data_out_channel_halt;
   //---------------------------------------------------------------------------
   // set "CONFIG.xk_index {false}" to remove 'm_axis_data_tuser'
   xfft_16bit256samples
   u_xfft (
         .aclk                       ( AXIS_CLK           )//input         aclk
       , .aresetn                    ( XFFT_ARESETn       )//input         aresetn
       , .s_axis_config_tdata        ( CONFIG_AXIS_TDATA  )//input  [ 7:0] s_axis_config_tdata
       , .s_axis_config_tvalid       ( CONFIG_AXIS_TVALID )//input         s_axis_config_tvalid
       , .s_axis_config_tready       ( CONFIG_AXIS_TREADY )//output        s_axis_config_tready
       , .s_axis_data_tdata          ( M2S_AXIS_TDATA     )//input  [31:0] s_axis_data_tdata
       , .s_axis_data_tvalid         ( M2S_AXIS_TVALID    )//input         s_axis_data_tvalid
       , .s_axis_data_tready         ( M2S_AXIS_TREADY    )//output        s_axis_data_tready
       , .s_axis_data_tlast          ( M2S_AXIS_TLAST     )//input         s_axis_data_tlast
       , .m_axis_data_tdata          ( S2M_AXIS_TDATA     )//output [63:0] m_axis_data_tdata
       , .m_axis_data_tuser          ( S2M_AXIS_TUSER     )//output [ 7:0] m_axis_data_tuser
       , .m_axis_data_tvalid         ( S2M_AXIS_TVALID    )//output        m_axis_data_tvalid
       , .m_axis_data_tready         ( S2M_AXIS_TREADY    )//input         m_axis_data_tready
       , .m_axis_data_tlast          ( S2M_AXIS_TLAST     )//output        m_axis_data_tlast
       , .event_frame_started        ( event_frame_started         )//output        event_frame_started
       , .event_tlast_unexpected     ( event_tlast_unexpected      )//output        event_tlast_unexpected
       , .event_tlast_missing        ( event_tlast_missing         )//output        event_tlast_missing
       , .event_status_channel_halt  ( event_status_channel_halt   )//output        event_status_channel_halt
       , .event_data_in_channel_halt ( event_data_in_channel_halt  )//output        event_data_in_channel_halt
       , .event_data_out_channel_halt( event_data_out_channel_halt )//output        event_data_out_channel_halt
   );
   //---------------------------------------------------------------------------
   // synthesis translate_off
  //localparam P_SAMPLING_FREQ=64'd4_000_000_000
  //         , P_SAMPLE_NUM   =1;
  //file_writer_fixed #(.P_SAMPLE_NUM    (P_SAMPLE_NUM) // num of samples in a stream (P_FIXED_WID-bit wise)
  //                   ,.P_SAMPLING_FREQ (P_SAMPLING_FREQ)// 4Ghz
  //                   ,.P_STREAM_FREQ   (P_SAMPLING_FREQ/P_SAMPLE_NUM)// axis_clk
  //                   ,.P_FIXED_INT     (2)
  //                   ,.P_FIXED_FRAC    (14)
  //                   ,.P_FFT_NUM_SAMPLE(256)// num of samples for an FFT
  //                   ,.P_FILE_NAME_REAL ("data_float.txt")
  //                   ,.P_FILE_NAME_FIXED("data_fixed.txt")
  //                   ,.P_COMPLEX        (1)
  //                   )
  //u_file_signal (
  //    .axis_reset_n ( XFFT_ARESETn    )
  //  , .axis_clk     ( AXIS_CLK        )
  //  , .axis_tvalid  ( M2S_AXIS_TVALID )
  //  , .axis_tready  ( M2S_AXIS_TREADY )
  //  , .axis_tlast   ( M2S_AXIS_TLAST  )
  //  , .axis_tdata   ( M2S_AXIS_TDATA  )
  //);
  //file_writer_fixed #(.P_SAMPLE_NUM    (P_SAMPLE_NUM) // num of samples in a stream (P_FIXED_WID-bit wise)
  //                   ,.P_SAMPLING_FREQ (P_SAMPLING_FREQ)// 4Ghz
  //                   ,.P_STREAM_FREQ   (P_SAMPLING_FREQ/P_SAMPLE_NUM)// axis_clk
  //                   ,.P_FIXED_INT     (2+16)
  //                   ,.P_FIXED_FRAC    (14)
  //                   ,.P_FFT_NUM_SAMPLE(256)// num of samples for an FFT
  //                   ,.P_FILE_NAME_REAL ("fft_float.txt")
  //                   ,.P_FILE_NAME_FIXED("fft_fixed.txt")
  //                   ,.P_COMPLEX        (1)
  //                   )
  //u_file_fft (
  //    .axis_reset_n ( XFFT_ARESETn    )
  //  , .axis_clk     ( AXIS_CLK        )
  //  , .axis_tvalid  ( S2M_AXIS_TVALID )
  //  , .axis_tready  ( S2M_AXIS_TREADY )
  //  , .axis_tlast   ( S2M_AXIS_TLAST  )
  //  , .axis_tdata   ( S2M_AXIS_TDATA  )
  //);
   // synthesis translate_on
   //---------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Revision History
//
// 2018.05.01: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
