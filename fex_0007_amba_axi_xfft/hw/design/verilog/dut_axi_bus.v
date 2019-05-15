`ifndef DUT_AXI_BUS_V
`define DUT_AXI_BUS_V
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// dut_axi_bus.v
//------------------------------------------------------------------------------
// VERSION = 2018.06.25.
//------------------------------------------------------------------------------
// Macros
//------------------------------------------------------------------------------
// Note:
//------------------------------------------------------------------------------
   parameter AXI_WIDTH_CID= 4 // Channel ID width in bits
           , AXI_WIDTH_ID = 4 // ID width in bits
           , AXI_WIDTH_AD =32 // address width
           , AXI_WIDTH_DA =32 // data width
           , AXI_WIDTH_DS =(AXI_WIDTH_DA/8)  // data strobe width
           , AXI_WIDTH_SID=(AXI_WIDTH_CID+AXI_WIDTH_ID);
   //---------------------------------------------------------------------------
   localparam NUM_MASTER  = 2 
            , NUM_SLAVE   = 3;
   localparam AXI_ADDR_BASE0  =       P_ADDR_START_APB
            , AXI_ADDR_LENGTH0=clogb2(P_SIZE_APB)
            , AXI_ADDR_BASE1  =       P_ADDR_START_MEM_M2S
            , AXI_ADDR_LENGTH1=clogb2(P_SIZE_MEM_M2S)
            , AXI_ADDR_BASE2  =       P_ADDR_START_MEM_S2M
            , AXI_ADDR_LENGTH2=clogb2(P_SIZE_MEM_S2M)
            ;
   //---------------------------------------------------------------------------
   `ifdef SIM
   `define BUS_DELAY  #(1)
   `else
   `define BUS_DELAY
   `endif
   //---------------------------------------------------------------------------
   wire  ACLK=USR_CLK;
   wire  ARESETn=SYS_RST_N;
   //---------------------------------------------------------------------------
   wire  [AXI_WIDTH_CID-1:0]    `BUS_DELAY  M_MID        [0:NUM_MASTER-1];
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY  M_AWID       [0:NUM_MASTER-1];
   wire  [AXI_WIDTH_AD-1:0]     `BUS_DELAY  M_AWADDR     [0:NUM_MASTER-1];
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 `BUS_DELAY  M_AWLEN      [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_AWLOCK     [0:NUM_MASTER-1];
   `else
   wire  [ 3:0]                 `BUS_DELAY  M_AWLEN      [0:NUM_MASTER-1];
   wire  [ 1:0]                 `BUS_DELAY  M_AWLOCK     [0:NUM_MASTER-1];
   `endif
   wire  [ 2:0]                 `BUS_DELAY  M_AWSIZE     [0:NUM_MASTER-1];
   wire  [ 1:0]                 `BUS_DELAY  M_AWBURST    [0:NUM_MASTER-1];
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 `BUS_DELAY  M_AWCACHE    [0:NUM_MASTER-1];
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 `BUS_DELAY  M_AWPROT     [0:NUM_MASTER-1];
   `endif
   wire                         `BUS_DELAY  M_AWVALID    [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_AWREADY    [0:NUM_MASTER-1];
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 `BUS_DELAY  M_AWQOS      [0:NUM_MASTER-1];
   wire  [ 3:0]                 `BUS_DELAY  M_AWREGION   [0:NUM_MASTER-1];
   `endif
   `ifdef AMBA_AXI_AWUSER
   wire  [AXI_WIDTH_AWUSER-1:0] `BUS_DELAY  M_AWUSER     [0:NUM_MASTER-1];
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY  M_WID        [0:NUM_MASTER-1];
   wire  [AXI_WIDTH_DA-1:0]     `BUS_DELAY  M_WDATA      [0:NUM_MASTER-1];
   wire  [AXI_WIDTH_DS-1:0]     `BUS_DELAY  M_WSTRB      [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_WLAST      [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_WVALID     [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_WREADY     [0:NUM_MASTER-1];
   `ifdef AMBA_AXI_WUSER
   wire  [AXI_WIDTH_WUSER-1:0]  `BUS_DELAY  M_WUSER      [0:NUM_MASTER-1];
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY  M_BID        [0:NUM_MASTER-1];
   wire  [ 1:0]                 `BUS_DELAY  M_BRESP      [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_BVALID     [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_BREADY     [0:NUM_MASTER-1];
   `ifdef AMBA_AXI_BUSER
   wire  [AXI_WIDTH_BUSER-1:0]  `BUS_DELAY  M_BUSER      [0:NUM_MASTER-1];
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY  M_ARID       [0:NUM_MASTER-1];
   wire  [AXI_WIDTH_AD-1:0]     `BUS_DELAY  M_ARADDR     [0:NUM_MASTER-1];
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 `BUS_DELAY  M_ARLEN      [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_ARLOCK     [0:NUM_MASTER-1];
   `else
   wire  [ 3:0]                 `BUS_DELAY  M_ARLEN      [0:NUM_MASTER-1];
   wire  [ 1:0]                 `BUS_DELAY  M_ARLOCK     [0:NUM_MASTER-1];
   `endif
   wire  [ 2:0]                 `BUS_DELAY  M_ARSIZE     [0:NUM_MASTER-1];
   wire  [ 1:0]                 `BUS_DELAY  M_ARBURST    [0:NUM_MASTER-1];
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 `BUS_DELAY  M_ARCACHE    [0:NUM_MASTER-1];
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 `BUS_DELAY  M_ARPROT     [0:NUM_MASTER-1];
   `endif
   wire                         `BUS_DELAY  M_ARVALID    [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_ARREADY    [0:NUM_MASTER-1];
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 `BUS_DELAY  M_ARQOS      [0:NUM_MASTER-1];
   wire  [ 3:0]                 `BUS_DELAY  M_ARREGION   [0:NUM_MASTER-1];
   `endif
   `ifdef AMBA_AXI_ARUSER
   wire  [AXI_WIDTH_ARUSER-1:0] `BUS_DELAY  M_ARUSER     [0:NUM_MASTER-1];
   `endif
   wire  [AXI_WIDTH_ID-1:0]     `BUS_DELAY  M_RID        [0:NUM_MASTER-1];
   wire  [AXI_WIDTH_DA-1:0]     `BUS_DELAY  M_RDATA      [0:NUM_MASTER-1];
   wire  [ 1:0]                 `BUS_DELAY  M_RRESP      [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_RLAST      [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_RVALID     [0:NUM_MASTER-1];
   wire                         `BUS_DELAY  M_RREADY     [0:NUM_MASTER-1];
   `ifdef AMBA_AXI_RUSER
   wire  [AXI_WIDTH_RUSER-1:0]  `BUS_DELAY  M_RUSER      [0:NUM_MASTER-1];
   `endif
   //--------------------------------------------------------------------------
   wire  [AXI_WIDTH_SID-1:0]    `BUS_DELAY  S_AWID       [0:NUM_SLAVE-1];
   wire  [AXI_WIDTH_AD-1:0]     `BUS_DELAY  S_AWADDR     [0:NUM_SLAVE-1];
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 `BUS_DELAY  S_AWLEN      [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_AWLOCK     [0:NUM_SLAVE-1];
   `else
   wire  [ 3:0]                 `BUS_DELAY  S_AWLEN      [0:NUM_SLAVE-1];
   wire  [ 1:0]                 `BUS_DELAY  S_AWLOCK     [0:NUM_SLAVE-1];
   `endif
   wire  [ 2:0]                 `BUS_DELAY  S_AWSIZE     [0:NUM_SLAVE-1];
   wire  [ 1:0]                 `BUS_DELAY  S_AWBURST    [0:NUM_SLAVE-1];
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 `BUS_DELAY  S_AWCACHE    [0:NUM_SLAVE-1];
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 `BUS_DELAY  S_AWPROT     [0:NUM_SLAVE-1];
   `endif
   wire                         `BUS_DELAY  S_AWVALID    [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_AWREADY    [0:NUM_SLAVE-1];
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 `BUS_DELAY  S_AWQOS      [0:NUM_SLAVE-1];
   wire  [ 3:0]                 `BUS_DELAY  S_AWREGION   [0:NUM_SLAVE-1];
   `endif
   `ifdef AMBA_AXI_AWUSER
   wire  [AXI_WIDTH_AWUSER-1:0] `BUS_DELAY  S_AWUSER     [0:NUM_SLAVE-1];
   `endif
   wire  [AXI_WIDTH_SID-1:0]    `BUS_DELAY  S_WID        [0:NUM_SLAVE-1];
   wire  [AXI_WIDTH_DA-1:0]     `BUS_DELAY  S_WDATA      [0:NUM_SLAVE-1];
   wire  [AXI_WIDTH_DS-1:0]     `BUS_DELAY  S_WSTRB      [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_WLAST      [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_WVALID     [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_WREADY     [0:NUM_SLAVE-1];
   `ifdef AMBA_AXI_WUSER
   wire  [AXI_WIDTH_WUSER-1:0]  `BUS_DELAY  S_WUSER      [0:NUM_SLAVE-1];
   `endif
   wire  [AXI_WIDTH_SID-1:0]    `BUS_DELAY  S_BID        [0:NUM_SLAVE-1];
   wire  [ 1:0]                 `BUS_DELAY  S_BRESP      [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_BVALID     [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_BREADY     [0:NUM_SLAVE-1];
   `ifdef AMBA_AXI_BUSER
   wire  [AXI_WIDTH_BUSER-1:0]  `BUS_DELAY  S_BUSER      [0:NUM_SLAVE-1];
   `endif
   wire  [AXI_WIDTH_SID-1:0]    `BUS_DELAY  S_ARID       [0:NUM_SLAVE-1];
   wire  [AXI_WIDTH_AD-1:0]     `BUS_DELAY  S_ARADDR     [0:NUM_SLAVE-1];
   `ifdef AMBA_AXI4
   wire  [ 7:0]                 `BUS_DELAY  S_ARLEN      [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_ARLOCK     [0:NUM_SLAVE-1];
   `else
   wire  [ 3:0]                 `BUS_DELAY  S_ARLEN      [0:NUM_SLAVE-1];
   wire  [ 1:0]                 `BUS_DELAY  S_ARLOCK     [0:NUM_SLAVE-1];
   `endif
   wire  [ 2:0]                 `BUS_DELAY  S_ARSIZE     [0:NUM_SLAVE-1];
   wire  [ 1:0]                 `BUS_DELAY  S_ARBURST    [0:NUM_SLAVE-1];
   `ifdef AMBA_AXI_CACHE
   wire  [ 3:0]                 `BUS_DELAY  S_ARCACHE    [0:NUM_SLAVE-1];
   `endif
   `ifdef AMBA_AXI_PROT
   wire  [ 2:0]                 `BUS_DELAY  S_ARPROT     [0:NUM_SLAVE-1];
   `endif
   wire                         `BUS_DELAY  S_ARVALID    [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_ARREADY    [0:NUM_SLAVE-1];
   `ifdef AMBA_AXI4
   wire  [ 3:0]                 `BUS_DELAY  S_ARQOS      [0:NUM_SLAVE-1];
   wire  [ 3:0]                 `BUS_DELAY  S_ARREGION   [0:NUM_SLAVE-1];
   `endif
   `ifdef AMBA_AXI_ARUSER
   wire  [AXI_WIDTH_ARUSER-1:0] `BUS_DELAY  S_ARUSER     [0:NUM_SLAVE-1];
   `endif
   wire  [AXI_WIDTH_SID-1:0]    `BUS_DELAY  S_RID        [0:NUM_SLAVE-1];
   wire  [AXI_WIDTH_DA-1:0]     `BUS_DELAY  S_RDATA      [0:NUM_SLAVE-1];
   wire  [ 1:0]                 `BUS_DELAY  S_RRESP      [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_RLAST      [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_RVALID     [0:NUM_SLAVE-1];
   wire                         `BUS_DELAY  S_RREADY     [0:NUM_SLAVE-1];
   `ifdef AMBA_AXI_RUSER
   wire  [AXI_WIDTH_RUSER-1:0]  `BUS_DELAY  S_RUSER      [0:NUM_SLAVE-1];
   `endif
   //---------------------------------------------------------------------------
   amba_axi_m2s3
       #(.WIDTH_CID   (AXI_WIDTH_CID   )
        ,.WIDTH_ID    (AXI_WIDTH_ID    )
        ,.WIDTH_AD    (AXI_WIDTH_AD    )
        ,.WIDTH_DA    (AXI_WIDTH_DA    )
        ,.WIDTH_DS    (AXI_WIDTH_DS    )
        ,.WIDTH_SID   (AXI_WIDTH_SID   )
      //,.WIDTH_AWUSER(AXI_WIDTH_AWUSER)
      //,.WIDTH_WUSER (AXI_WIDTH_WUSER )
      //,.WIDTH_BUSER (AXI_WIDTH_BUSER )
      //,.WIDTH_ARUSER(AXI_WIDTH_ARUSER)
      //,.WIDTH_RUSER (AXI_WIDTH_RUSER )
        ,.ADDR_BASE0  (AXI_ADDR_BASE0  )
        ,.ADDR_LENGTH0(AXI_ADDR_LENGTH0)
        ,.ADDR_BASE1  (AXI_ADDR_BASE1  )
        ,.ADDR_LENGTH1(AXI_ADDR_LENGTH1)
        ,.ADDR_BASE2  (AXI_ADDR_BASE2  )
        ,.ADDR_LENGTH2(AXI_ADDR_LENGTH2)
        )
   u_axi (
          .ARESETn              (ARESETn      )
        , .ACLK                 (ACLK         )
        , .M0_MID               (M_MID     [0])
        , .M0_AWID              (M_AWID    [0])
        , .M0_AWADDR            (M_AWADDR  [0])
        , .M0_AWLEN             (M_AWLEN   [0])
        , .M0_AWLOCK            (M_AWLOCK  [0])
        , .M0_AWSIZE            (M_AWSIZE  [0])
        , .M0_AWBURST           (M_AWBURST [0])
        `ifdef AMBA_AXI_CACHE
        , .M0_AWCACHE           (M_AWCACHE [0])
        `endif
        `ifdef AMBA_AXI_PROT
        , .M0_AWPROT            (M_AWPROT  [0])
        `endif
        , .M0_AWVALID           (M_AWVALID [0])
        , .M0_AWREADY           (M_AWREADY [0])
        `ifdef AMBA_AXI4
        , .M0_AWQOS             (M_AWQOS   [0])
        , .M0_AWREGION          (M_AWREGION[0])
        `endif
        `ifdef AMBA_AXI_AWUSER
        , .M0_AWUSER            (M_AWUSER  [0])
        `endif
        , .M0_WID               (M_WID     [0])
        , .M0_WDATA             (M_WDATA   [0])
        , .M0_WSTRB             (M_WSTRB   [0])
        , .M0_WLAST             (M_WLAST   [0])
        , .M0_WVALID            (M_WVALID  [0])
        , .M0_WREADY            (M_WREADY  [0])
        `ifdef AMBA_AXI_WUSER
        , .M0_WUSER             (M_WUSER   [0])
        `endif
        , .M0_BID               (M_BID     [0])
        , .M0_BRESP             (M_BRESP   [0])
        , .M0_BVALID            (M_BVALID  [0])
        , .M0_BREADY            (M_BREADY  [0])
        `ifdef AMBA_AXI_BUSER
        , .M0_BUSER             (M_BUSER   [0])
        `endif
        , .M0_ARID              (M_ARID    [0])
        , .M0_ARADDR            (M_ARADDR  [0])
        , .M0_ARLEN             (M_ARLEN   [0])
        , .M0_ARLOCK            (M_ARLOCK  [0])
        , .M0_ARSIZE            (M_ARSIZE  [0])
        , .M0_ARBURST           (M_ARBURST [0])
        `ifdef AMBA_AXI_CACHE
        , .M0_ARCACHE           (M_ARCACHE [0])
        `endif
        `ifdef AMBA_AXI_PROT
        , .M0_ARPROT            (M_ARPROT  [0])
        `endif
        , .M0_ARVALID           (M_ARVALID [0])
        , .M0_ARREADY           (M_ARREADY [0])
        `ifdef AMBA_AXI4
        , .M0_ARQOS             (M_ARQOS   [0])
        , .M0_ARREGION          (M_ARREGION[0])
        `endif
        `ifdef AMBA_AXI_ARUSER
        , .M0_ARUSER            (M_ARUSER  [0])
        `endif
        , .M0_RID               (M_RID     [0])
        , .M0_RDATA             (M_RDATA   [0])
        , .M0_RRESP             (M_RRESP   [0])
        , .M0_RLAST             (M_RLAST   [0])
        , .M0_RVALID            (M_RVALID  [0])
        , .M0_RREADY            (M_RREADY  [0])
        `ifdef AMBA_AXI_RUSER
        , .M0_RUSER             (M_RUSER   [0])
        `endif
        , .M1_MID               (M_MID     [1])
        , .M1_AWID              (M_AWID    [1])
        , .M1_AWADDR            (M_AWADDR  [1])
        , .M1_AWLEN             (M_AWLEN   [1])
        , .M1_AWLOCK            (M_AWLOCK  [1])
        , .M1_AWSIZE            (M_AWSIZE  [1])
        , .M1_AWBURST           (M_AWBURST [1])
        `ifdef AMBA_AXI_CACHE
        , .M1_AWCACHE           (M_AWCACHE [1])
        `endif
        `ifdef AMBA_AXI_PROT
        , .M1_AWPROT            (M_AWPROT  [1])
        `endif
        , .M1_AWVALID           (M_AWVALID [1])
        , .M1_AWREADY           (M_AWREADY [1])
        `ifdef AMBA_AXI4
        , .M1_AWQOS             (M_AWQOS   [1])
        , .M1_AWREGION          (M_AWREGION[1])
        `endif
        `ifdef AMBA_AXI_AWUSER
        , .M1_AWUSER            (M_AWUSER  [1])
        `endif
        , .M1_WID               (M_WID     [1])
        , .M1_WDATA             (M_WDATA   [1])
        , .M1_WSTRB             (M_WSTRB   [1])
        , .M1_WLAST             (M_WLAST   [1])
        , .M1_WVALID            (M_WVALID  [1])
        , .M1_WREADY            (M_WREADY  [1])
        `ifdef AMBA_AXI_WUSER
        , .M1_WUSER             (M_WUSER   [1])
        `endif
        , .M1_BID               (M_BID     [1])
        , .M1_BRESP             (M_BRESP   [1])
        , .M1_BVALID            (M_BVALID  [1])
        , .M1_BREADY            (M_BREADY  [1])
        `ifdef AMBA_AXI_BUSER
        , .M1_BUSER             (M_BUSER   [1])
        `endif
        , .M1_ARID              (M_ARID    [1])
        , .M1_ARADDR            (M_ARADDR  [1])
        , .M1_ARLEN             (M_ARLEN   [1])
        , .M1_ARLOCK            (M_ARLOCK  [1])
        , .M1_ARSIZE            (M_ARSIZE  [1])
        , .M1_ARBURST           (M_ARBURST [1])
        `ifdef AMBA_AXI_CACHE
        , .M1_ARCACHE           (M_ARCACHE [1])
        `endif
        `ifdef AMBA_AXI_PROT
        , .M1_ARPROT            (M_ARPROT  [1])
        `endif
        , .M1_ARVALID           (M_ARVALID [1])
        , .M1_ARREADY           (M_ARREADY [1])
        `ifdef AMBA_AXI4
        , .M1_ARQOS             (M_ARQOS   [1])
        , .M1_ARREGION          (M_ARREGION[1])
        `endif
        `ifdef AMBA_AXI_ARUSER
        , .M1_ARUSER            (M_ARUSER  [1])
        `endif
        , .M1_RID               (M_RID     [1])
        , .M1_RDATA             (M_RDATA   [1])
        , .M1_RRESP             (M_RRESP   [1])
        , .M1_RLAST             (M_RLAST   [1])
        , .M1_RVALID            (M_RVALID  [1])
        , .M1_RREADY            (M_RREADY  [1])
        `ifdef AMBA_AXI_RUSER
        , .M1_RUSER             (M_RUSER   [1])
        `endif
        , .S0_AWID              (S_AWID    [0])
        , .S0_AWADDR            (S_AWADDR  [0])
        , .S0_AWLEN             (S_AWLEN   [0])
        , .S0_AWLOCK            (S_AWLOCK  [0])
        , .S0_AWSIZE            (S_AWSIZE  [0])
        , .S0_AWBURST           (S_AWBURST [0])
        `ifdef AMBA_AXI_CACHE
        , .S0_AWCACHE           (S_AWCACHE [0])
        `endif
        `ifdef AMBA_AXI_PROT
        , .S0_AWPROT            (S_AWPROT  [0])
        `endif
        , .S0_AWVALID           (S_AWVALID [0])
        , .S0_AWREADY           (S_AWREADY [0])
        `ifdef AMBA_AXI4
        , .S0_AWQOS             (S_AWQOS   [0])
        , .S0_AWREGION          (S_AWREGION[0])
        `endif
        `ifdef AMBA_AXI_AWUSER
        , .S0_AWUSER            (S_AWUSER  [0])
        `endif
        , .S0_WID               (S_WID     [0])
        , .S0_WDATA             (S_WDATA   [0])
        , .S0_WSTRB             (S_WSTRB   [0])
        , .S0_WLAST             (S_WLAST   [0])
        , .S0_WVALID            (S_WVALID  [0])
        , .S0_WREADY            (S_WREADY  [0])
        `ifdef AMBA_AXI_WUSER
        , .S0_WUSER             (S_WUSER   [0])
        `endif
        , .S0_BID               (S_BID     [0])
        , .S0_BRESP             (S_BRESP   [0])
        , .S0_BVALID            (S_BVALID  [0])
        , .S0_BREADY            (S_BREADY  [0])
        `ifdef AMBA_AXI_BUSER
        , .S0_BUSER             (S_BUSER   [0])
        `endif
        , .S0_ARID              (S_ARID    [0])
        , .S0_ARADDR            (S_ARADDR  [0])
        , .S0_ARLEN             (S_ARLEN   [0])
        , .S0_ARLOCK            (S_ARLOCK  [0])
        , .S0_ARSIZE            (S_ARSIZE  [0])
        , .S0_ARBURST           (S_ARBURST [0])
        `ifdef AMBA_AXI_CACHE
        , .S0_ARCACHE           (S_ARCACHE [0])
        `endif
        `ifdef AMBA_AXI_PROT
        , .S0_ARPROT            (S_ARPROT  [0])
        `endif
        , .S0_ARVALID           (S_ARVALID [0])
        , .S0_ARREADY           (S_ARREADY [0])
        `ifdef AMBA_AXI4
        , .S0_ARQOS             (S_ARQOS   [0])
        , .S0_ARREGION          (S_ARREGION[0])
        `endif
        `ifdef AMBA_AXI_ARUSER
        , .S0_ARUSER            (S_ARUSER  [0])
        `endif
        , .S0_RID               (S_RID     [0])
        , .S0_RDATA             (S_RDATA   [0])
        , .S0_RRESP             (S_RRESP   [0])
        , .S0_RLAST             (S_RLAST   [0])
        , .S0_RVALID            (S_RVALID  [0])
        , .S0_RREADY            (S_RREADY  [0])
        `ifdef AMBA_AXI_RUSER
        , .S0_RUSER             (S_RUSER   [0])
        `endif
        , .S1_AWID              (S_AWID    [1])
        , .S1_AWADDR            (S_AWADDR  [1])
        , .S1_AWLEN             (S_AWLEN   [1])
        , .S1_AWLOCK            (S_AWLOCK  [1])
        , .S1_AWSIZE            (S_AWSIZE  [1])
        , .S1_AWBURST           (S_AWBURST [1])
        `ifdef AMBA_AXI_CACHE
        , .S1_AWCACHE           (S_AWCACHE [1])
        `endif
        `ifdef AMBA_AXI_PROT
        , .S1_AWPROT            (S_AWPROT  [1])
        `endif
        , .S1_AWVALID           (S_AWVALID [1])
        , .S1_AWREADY           (S_AWREADY [1])
        `ifdef AMBA_AXI4                      
        , .S1_AWQOS             (S_AWQOS   [1])
        , .S1_AWREGION          (S_AWREGION[1])
        `endif                                
        `ifdef AMBA_AXI_AWUSER                
        , .S1_AWUSER            (S_AWUSER  [1])
        `endif                                
        , .S1_WID               (S_WID     [1])
        , .S1_WDATA             (S_WDATA   [1])
        , .S1_WSTRB             (S_WSTRB   [1])
        , .S1_WLAST             (S_WLAST   [1])
        , .S1_WVALID            (S_WVALID  [1])
        , .S1_WREADY            (S_WREADY  [1])
        `ifdef AMBA_AXI_WUSER                 
        , .S1_WUSER             (S_WUSER   [1])
        `endif                                
        , .S1_BID               (S_BID     [1])
        , .S1_BRESP             (S_BRESP   [1])
        , .S1_BVALID            (S_BVALID  [1])
        , .S1_BREADY            (S_BREADY  [1])
        `ifdef AMBA_AXI_BUSER                 
        , .S1_BUSER             (S_BUSER   [1])
        `endif                                
        , .S1_ARID              (S_ARID    [1])
        , .S1_ARADDR            (S_ARADDR  [1])
        , .S1_ARLEN             (S_ARLEN   [1])
        , .S1_ARLOCK            (S_ARLOCK  [1])
        , .S1_ARSIZE            (S_ARSIZE  [1])
        , .S1_ARBURST           (S_ARBURST [1])
        `ifdef AMBA_AXI_CACHE
        , .S1_ARCACHE           (S_ARCACHE [1])
        `endif
        `ifdef AMBA_AXI_PROT
        , .S1_ARPROT            (S_ARPROT  [1])
        `endif
        , .S1_ARVALID           (S_ARVALID [1])
        , .S1_ARREADY           (S_ARREADY [1])
        `ifdef AMBA_AXI4                      
        , .S1_ARQOS             (S_ARQOS   [1])
        , .S1_ARREGION          (S_ARREGION[1])
        `endif                                
        `ifdef AMBA_AXI_ARUSER                
        , .S1_ARUSER            (S_ARUSER  [1])
        `endif                                
        , .S1_RID               (S_RID     [1])
        , .S1_RDATA             (S_RDATA   [1])
        , .S1_RRESP             (S_RRESP   [1])
        , .S1_RLAST             (S_RLAST   [1])
        , .S1_RVALID            (S_RVALID  [1])
        , .S1_RREADY            (S_RREADY  [1])
        `ifdef AMBA_AXI_RUSER                 
        , .S1_RUSER             (S_RUSER   [1])
        `endif
        , .S2_AWID              (S_AWID    [2])
        , .S2_AWADDR            (S_AWADDR  [2])
        , .S2_AWLEN             (S_AWLEN   [2])
        , .S2_AWLOCK            (S_AWLOCK  [2])
        , .S2_AWSIZE            (S_AWSIZE  [2])
        , .S2_AWBURST           (S_AWBURST [2])
        `ifdef AMBA_AXI_CACHE
        , .S2_AWCACHE           (S_AWCACHE [2])
        `endif
        `ifdef AMBA_AXI_PROT
        , .S2_AWPROT            (S_AWPROT  [2])
        `endif
        , .S2_AWVALID           (S_AWVALID [2])
        , .S2_AWREADY           (S_AWREADY [2])
        `ifdef AMBA_AXI4
        , .S2_AWQOS             (S_AWQOS   [2])
        , .S2_AWREGION          (S_AWREGION[2])
        `endif
        `ifdef AMBA_AXI_AWUSER
        , .S2_AWUSER            (S_AWUSER  [2])
        `endif
        , .S2_WID               (S_WID     [2])
        , .S2_WDATA             (S_WDATA   [2])
        , .S2_WSTRB             (S_WSTRB   [2])
        , .S2_WLAST             (S_WLAST   [2])
        , .S2_WVALID            (S_WVALID  [2])
        , .S2_WREADY            (S_WREADY  [2])
        `ifdef AMBA_AXI_WUSER
        , .S2_WUSER             (S_WUSER   [2])
        `endif
        , .S2_BID               (S_BID     [2])
        , .S2_BRESP             (S_BRESP   [2])
        , .S2_BVALID            (S_BVALID  [2])
        , .S2_BREADY            (S_BREADY  [2])
        `ifdef AMBA_AXI_BUSER
        , .S2_BUSER             (S_BUSER   [2])
        `endif
        , .S2_ARID              (S_ARID    [2])
        , .S2_ARADDR            (S_ARADDR  [2])
        , .S2_ARLEN             (S_ARLEN   [2])
        , .S2_ARLOCK            (S_ARLOCK  [2])
        , .S2_ARSIZE            (S_ARSIZE  [2])
        , .S2_ARBURST           (S_ARBURST [2])
        `ifdef AMBA_AXI_CACHE
        , .S2_ARCACHE           (S_ARCACHE [2])
        `endif
        `ifdef AMBA_AXI_PROT
        , .S2_ARPROT            (S_ARPROT  [2])
        `endif
        , .S2_ARVALID           (S_ARVALID [2])
        , .S2_ARREADY           (S_ARREADY [2])
        `ifdef AMBA_AXI4
        , .S2_ARQOS             (S_ARQOS   [2])
        , .S2_ARREGION          (S_ARREGION[2])
        `endif
        `ifdef AMBA_AXI_ARUSER
        , .S2_ARUSER            (S_ARUSER  [2])
        `endif
        , .S2_RID               (S_RID     [2])
        , .S2_RDATA             (S_RDATA   [2])
        , .S2_RRESP             (S_RRESP   [2])
        , .S2_RLAST             (S_RLAST   [2])
        , .S2_RVALID            (S_RVALID  [2])
        , .S2_RREADY            (S_RREADY  [2])
        `ifdef AMBA_AXI_RUSER
        , .S2_RUSER             (S_RUSER   [2])
        `endif
   );
   //---------------------------------------------------------------------------
     assign M_MID             [1] =~'h0;
     assign M_AWID            [1] = 'h0;
     assign M_AWADDR          [1] = 'h0;
     `ifdef AMBA_AXI4
     assign M_AWLEN           [1] = 'h0;
     assign M_AWLOCK          [1] = 'h0;
     `else
     assign M_AWLEN           [1] = 'h0;
     assign M_AWLOCK          [1] = 'h0;
     `endif
     assign M_AWSIZE          [1] = 'h0;
     assign M_AWBURST         [1] = 'h0;
     `ifdef AMBA_AXI_CACHE
     assign M_AWCACHE         [1] = 'h0;
     `endif
     `ifdef AMBA_AXI_PROT
     assign M_AWPROT          [1] = 'h0;
     `endif
     assign M_AWVALID         [1] = 'h0;
   //assign M_AWREADY         [1] = 'h0;
     `ifdef AMBA_AXI4
     assign M_AWQOS           [1] = 'h0;
     assign M_AWREGION        [1] = 'h0;
     `endif
     assign M_WID             [1] = 'h0;
     assign M_WDATA           [1] = 'h0;
     assign M_WSTRB           [1] = 'h0;
     assign M_WLAST           [1] = 'h0;
     assign M_WVALID          [1] = 'h0;
   //assign M_WREADY          [1] = 'h0;
   //assign M_BID             [1] = 'h0;
   //assign M_BRESP           [1] = 'h0;
   //assign M_BVALID          [1] = 'h0;
     assign M_BREADY          [1] = 'h1;
     assign M_ARID            [1] = 'h0;
     assign M_ARADDR          [1] = 'h0;
     `ifdef AMBA_AXI4
     assign M_ARLEN           [1] = 'h0;
     assign M_ARLOCK          [1] = 'h0;
     `else
     assign M_ARLEN           [1] = 'h0;
     assign M_ARLOCK          [1] = 'h0;
     `endif
     assign M_ARSIZE          [1] = 'h0;
     assign M_ARBURST         [1] = 'h0;
     `ifdef AMBA_AXI_CACHE
     assign M_ARCACHE         [1] = 'h0;
     `endif
     `ifdef AMBA_AXI_PROT
     assign M_ARPROT          [1] = 'h0;
     `endif
     assign M_ARVALID         [1] = 'h0;
   //assign M_ARREADY         [1] = 'h0;
     `ifdef AMBA_AXI4
     assign M_ARQOS           [1] = 'h0;
     assign M_ARREGION        [1] = 'h0;
     `endif
   //assign M_RID             [1] = 'h0;
   //assign M_RDATA           [1] = 'h0;
   //assign M_RRESP           [1] = 'h0;
   //assign M_RLAST           [1] = 'h0;
   //assign M_RVALID          [1] = 'h0;
     assign M_RREADY          [1] = 'h1;
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.25: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
`endif
