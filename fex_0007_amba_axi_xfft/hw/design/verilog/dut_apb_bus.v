//------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved
//
// http://www.future-ds.com
//------------------------------------------------------
// dut_apb_bus.v
//------------------------------------------------------
// VERSION: 2018.09.20.
//------------------------------------------------------

   //-------------------------------------------------
   localparam APB_WIDTH_PAD=32
            , APB_WIDTH_PDA=32
            , APB_WIDTH_PDS=APB_WIDTH_PDA/8;
   localparam PCLK_RATIO=2'b00;
   localparam APB_NUM_PSLAVE=3;
   //-------------------------------------------------
   localparam APB_ADDR_BASE0=P_ADDR_START_CONFIG,APB_LENGTH0=clogb2(P_SIZE_CONFIG)
            , APB_ADDR_BASE1=P_ADDR_START_M2S   ,APB_LENGTH1=clogb2(P_SIZE_M2S )
            , APB_ADDR_BASE2=P_ADDR_START_S2M   ,APB_LENGTH2=clogb2(P_SIZE_S2M )
            ;
   //-------------------------------------------------
   wire                      PRESETn  =ARESETn;
   wire                      PCLK     =ACLK;
   wire [APB_WIDTH_PAD-1:0]  PADDR    ;
   wire                      PENABLE  ;
   wire                      PWRITE   ;
   wire [APB_WIDTH_PDA-1:0]  PWDATA   ;
   wire [APB_NUM_PSLAVE-1:0] PSEL     ;
   wire [APB_WIDTH_PDA-1:0]  PRDATA   [0:APB_NUM_PSLAVE-1];
   `ifdef AMBA_APB3
   wire [APB_NUM_PSLAVE-1:0] PREADY   ;
   wire [APB_NUM_PSLAVE-1:0] PSLVERR  ;
   `endif
   `ifdef AMBA_APB4
   wire [APB_WIDTH_PDS-1:0]  PSTRB    ;
   wire [ 2:0]               PPROT    ;
   `endif
   //---------------------------------------------------------
   axi_to_apb_s3 #(.AXI_WIDTH_CID(AXI_WIDTH_CID )
                  ,.AXI_WIDTH_ID (AXI_WIDTH_ID  )
                  ,.AXI_WIDTH_AD (AXI_WIDTH_AD  )
                  ,.AXI_WIDTH_DA (AXI_WIDTH_DA  )
                  ,.NUM_PSLAVE   (APB_NUM_PSLAVE)
                  ,.WIDTH_PAD    (APB_WIDTH_PAD )
                  ,.WIDTH_PDA    (APB_WIDTH_PDA )
                  ,.ADDR_PBASE0  (APB_ADDR_BASE0),.ADDR_PLENGTH0 (APB_LENGTH0)
                  ,.ADDR_PBASE1  (APB_ADDR_BASE1),.ADDR_PLENGTH1 (APB_LENGTH1)
                  ,.ADDR_PBASE2  (APB_ADDR_BASE2),.ADDR_PLENGTH2 (APB_LENGTH2)
                  ,.CLOCK_RATIO  (PCLK_RATIO    )
                  )
   u_axi_to_apb (
       .ARESETn       (ARESETn     )
     , .ACLK          (ACLK        )
     , .AWID               ( S_AWID      [0])
     , .AWADDR             ( S_AWADDR    [0])
     , .AWLEN              ( S_AWLEN     [0])
     , .AWLOCK             ( S_AWLOCK    [0])
     , .AWSIZE             ( S_AWSIZE    [0])
     , .AWBURST            ( S_AWBURST   [0])
     `ifdef AMBA_AXI_CACHE
     , .AWCACHE            ( S_AWCACHE   [0])
     `endif
     `ifdef AMBA_AXI_PROT  
     , .AWPROT             ( S_AWPROT    [0])
     `endif
     , .AWVALID            ( S_AWVALID   [0])
     , .AWREADY            ( S_AWREADY   [0])
     `ifdef AMBA_AXI4      
     , .AWQOS              ( S_AWQOS     [0])
     , .AWREGION           ( S_AWREGION  [0])
     `endif
     , .WID                ( S_WID       [0])
     , .WDATA              ( S_WDATA     [0])
     , .WSTRB              ( S_WSTRB     [0])
     , .WLAST              ( S_WLAST     [0])
     , .WVALID             ( S_WVALID    [0])
     , .WREADY             ( S_WREADY    [0])
     , .BID                ( S_BID       [0]) //[AXI_WIDTH_SID-1:0]
     , .BRESP              ( S_BRESP     [0])
     , .BVALID             ( S_BVALID    [0])
     , .BREADY             ( S_BREADY    [0])
     , .ARID               ( S_ARID      [0])
     , .ARADDR             ( S_ARADDR    [0])
     , .ARLEN              ( S_ARLEN     [0])
     , .ARLOCK             ( S_ARLOCK    [0])
     , .ARSIZE             ( S_ARSIZE    [0])
     , .ARBURST            ( S_ARBURST   [0])
     `ifdef AMBA_AXI_CACHE
     , .ARCACHE            ( S_ARCACHE   [0])
     `endif
     `ifdef AMBA_AXI_PROT
     , .ARPROT             ( S_ARPROT    [0])
     `endif
     , .ARVALID            ( S_ARVALID   [0])
     , .ARREADY            ( S_ARREADY   [0])
     `ifdef AMBA_AXI4     
     , .ARQOS              ( S_ARQOS     [0])
     , .ARREGION           ( S_ARREGION  [0])
     `endif
     , .RID                ( S_RID       [0]) //[AXI_WIDTH_SID-1:0]
     , .RDATA              ( S_RDATA     [0])
     , .RRESP              ( S_RRESP     [0])
     , .RLAST              ( S_RLAST     [0])
     , .RVALID             ( S_RVALID    [0])
     , .RREADY             ( S_RREADY    [0])
     , .PRESETn       (PRESETn     )
     , .PCLK          (PCLK        )
     , .S_PADDR       (PADDR       )
     , .S_PENABLE     (PENABLE     )
     , .S_PWRITE      (PWRITE      )
     , .S_PWDATA      (PWDATA      )
     , .S0_PSEL       (PSEL    [0] )
     , .S1_PSEL       (PSEL    [1] )
     , .S2_PSEL       (PSEL    [2] )
     , .S0_PRDATA     (PRDATA  [0] )
     , .S1_PRDATA     (PRDATA  [1] )
     , .S2_PRDATA     (PRDATA  [2] )
     `ifdef AMBA_APB3
     , .S0_PREADY     (PREADY  [0] )
     , .S1_PREADY     (PREADY  [1] )
     , .S2_PREADY     (PREADY  [2] )
     , .S0_PSLVERR    (PSLVERR [0] )
     , .S1_PSLVERR    (PSLVERR [1] )
     , .S2_PSLVERR    (PSLVERR [2] )
     `endif
     `ifdef AMBA_APB4
     , .S_PSTRB       (PSTRB       )
     , .S_PPROT       (PPROT       )
     `endif
   );
   //--------------------------------------------------
//------------------------------------------------------
// Revision history:
//
// 2018.09.20: Prepared by Ando Ki (adki@future-ds.com)
//------------------------------------------------------
