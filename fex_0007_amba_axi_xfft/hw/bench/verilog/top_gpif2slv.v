`ifndef TOP_GPIF2SLV_V
`define TOP_GPIF2SLV_V
//------------------------------------------------------------------------------
// Copyright (c) 2015 by Future Design Systems Co., Ltd.
// All right reserved
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// top_gpif2slv.v
//------------------------------------------------------------------------------
// VERSION: 2015.08.14.
//------------------------------------------------------------------------------
   //---------------------------------------------------------------------------
   wire         #(2.5) SL_RST_N   ; PULLUP u_rst (SL_RST_N);
   wire         #(3.5) SL_PCLK    ;
   wire         #(3.5) SL_CS_N    ;
   wire         #(3.5) SL_FLAGA   ; PULLUP u_a (SL_FLAGA);
   wire         #(3.5) SL_FLAGB   ; PULLUP u_b (SL_FLAGB);
   wire         #(3.5) SL_FLAGC   ; PULLUP u_c (SL_FLAGC);
   wire         #(3.5) SL_FLAGD   ; PULLUP u_d (SL_FLAGD);
   wire         #(3.5) SL_RD_N    ; PULLUP u_r (SL_RD_N );// IF_RD
   wire         #(3.5) SL_WR_N    ; PULLUP u_w (SL_WR_N );// IF_WR
   wire         #(3.5) SL_OE_N    ; PULLUP u_o (SL_OE_N );// IF_OE
   wire         #(3.5) SL_PKTEND_N; PULLUP u_p (SL_PKTEND_N);// IF_PKTEND
   wire  [ 1:0] #(3.5) SL_MODE    ;
   wire  [ 1:0] #(3.5) SL_AD      ; // IF_ADDR[1:0]
   wire  [31:0] #(3.5) SL_DT      ; // IF_DATA[15:0]
   //---------------------------------------------------------------------------
   gpif2slv #(.WIDTH_DT      (32)
             ,.DEPTH_FIFO_U2F(1024)
             ,.DEPTH_FIFO_F2U(1024)
             ,.NUM_WATERMARK (4))
   u_slv (
          .SL_RST_N      ( SL_RST_N    )
        , .SL_PCLK       ( SL_PCLK     )
        , .SL_CS_N       ( SL_CS_N     )
        , .SL_AD         ( SL_AD       )
        , .SL_FLAGA      ( SL_FLAGA    )
        , .SL_FLAGB      ( SL_FLAGB    )
        , .SL_FLAGC      ( SL_FLAGC    )
        , .SL_FLAGD      ( SL_FLAGD    )
        , .SL_RD_N       ( SL_RD_N     )
        , .SL_WR_N       ( SL_WR_N     )
        , .SL_DT         ( SL_DT       )
        , .SL_OE_N       ( SL_OE_N     )
        , .SL_PKTEND_N   ( SL_PKTEND_N )
        , .SL_MODE       ( SL_MODE     )
        , .READY         ( READY       )
   );
   //---------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Revision history:
//
// 2015.08.14: Started by Ando Ki
//------------------------------------------------------------------------------
`endif
