//------------------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// top.v
//------------------------------------------------------------------------------
// VERSION: 2019.02.12.
//------------------------------------------------------------------------------
`include "defines_system.v"
`timescale 1ns/1ps

module top;
   //---------------------------------------------------------------------------
   // Oscillators
   localparam real CLOCK_FREQ =100_000_000.0;
   localparam real CLOCK_HALF =(1_000_000_000.0/CLOCK_FREQ/2.0);
   //---------------------------------------------------------------------------
   reg        osc_clk  = 1'b0;
   always #(CLOCK_HALF) osc_clk <= ~osc_clk; // Oscillator clock 50MHz
   //---------------------------------------------------------------------------
   // User reset
   reg BOARD_RST_SW=1'b1; initial #55 BOARD_RST_SW=1'b0; // active-high
   //---------------------------------------------------------------------------
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
   wire  READY;
   //---------------------------------------------------------------------------
   fpga
   u_fpga (
          .BOARD_RST_SW    ( BOARD_RST_SW )
        , .BOARD_CLK_IN    ( osc_clk     )
        , .SL_RST_N        ( SL_RST_N    )
        , .SL_CS_N         ( SL_CS_N     )
        , .SL_PCLK         ( SL_PCLK     )
        , .SL_FLAGA        ( SL_FLAGA    )
        , .SL_FLAGB        ( SL_FLAGB    )
        , .SL_FLAGC        ( SL_FLAGC    )
        , .SL_FLAGD        ( SL_FLAGD    )
        , .SL_RD_N         ( SL_RD_N     )
        , .SL_WR_N         ( SL_WR_N     )
        , .SL_AD           ( SL_AD       )
        , .SL_DT           ( SL_DT       )
        , .SL_OE_N         ( SL_OE_N     )
        , .SL_PKTEND_N     ( SL_PKTEND_N )
        , .SL_MODE         ( SL_MODE     )
   );
   //---------------------------------------------------------------------------
   assign  READY=u_fpga.SYS_RST_N;
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
   reg  [31:0] sin_num;
   reg  [63:0] sampling_freq;
   reg  [63:0] sin_freq;
   integer idx;
   //---------------------------------------------------------------------------
//initial begin repeat (10000) @ (posedge osc_clk); $finish(2); end
   initial begin
           if (!$value$plusargs("num_sig=%d", sin_num)) sin_num = 1;
           if (!$value$plusargs("sampling_freq=%d", sampling_freq)) sampling_freq = 4000000;
           $display("%m num_sig=%d", sin_num);
           $display("%m sampling_freq=%d", sampling_freq);
           for (idx=0; idx<sin_num; idx=idx+1) begin
               if (!$value$plusargs("sin_freq=%d", sin_freq)) begin sin_freq=sampling_freq/10; idx=sin_num; end
               else $display("%m sin_freq=%d", sin_freq);
           end
           wait (SL_RST_N==1'b0);
           wait (SL_RST_N==1'b1);
           wait (u_slv.done==1'b1);
           repeat (30) @ (posedge SL_PCLK);
           $finish(2);
   end
   //---------------------------------------------------------------------------
    `ifdef VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0);
      //$dumpvars(3, u_slv);
      //$dumpvars(3, u_fpga);
      //$dumpvars(4, u_fpga.u_dut);
    end
    `endif
   //---------------------------------------------------------------------------
   file_writer_fixed #(.P_SAMPLE_NUM    (1) // num of samples in a stream (P_FIXED_WID-bit wise)
                      ,.P_FIXED_INT     (2)
                      ,.P_FIXED_FRAC    (14)
                      ,.P_FFT_NUM_SAMPLE(256)// num of samples for an FFT
                      ,.P_FILE_NAME_REAL ("data_float.txt")
                      ,.P_FILE_NAME_FIXED("data_fixed.txt")
                      ,.P_COMPLEX        (1)
                      )
   u_file_signal (
       .axis_reset_n ( u_fpga.u_dut.XFFT_ARESETn    )
     , .axis_clk     ( u_fpga.u_dut.AXIS_CLK        )
     , .axis_tvalid  ( u_fpga.u_dut.M2S_AXIS_TVALID )
     , .axis_tready  ( u_fpga.u_dut.M2S_AXIS_TREADY )
     , .axis_tlast   ( u_fpga.u_dut.M2S_AXIS_TLAST  )
     , .axis_tdata   ( u_fpga.u_dut.M2S_AXIS_TDATA  )
     , .sampling_freq( sampling_freq )
   );
   //---------------------------------------------------------------------------
   file_writer_fixed #(.P_SAMPLE_NUM    (1) // num of samples in a stream (P_FIXED_WID-bit wise)
                      ,.P_FIXED_INT     (2+16)
                      ,.P_FIXED_FRAC    (14)
                      ,.P_FFT_NUM_SAMPLE(256)// num of samples for an FFT
                      ,.P_FILE_NAME_REAL ("fft_float.txt")
                      ,.P_FILE_NAME_FIXED("fft_fixed.txt")
                      ,.P_COMPLEX        (1)
                      )
   u_file_fft (
       .axis_reset_n ( u_fpga.u_dut.XFFT_ARESETn    )
     , .axis_clk     ( u_fpga.u_dut.AXIS_CLK        )
     , .axis_tvalid  ( u_fpga.u_dut.S2M_AXIS_TVALID )
     , .axis_tready  ( u_fpga.u_dut.S2M_AXIS_TREADY )
     , .axis_tlast   ( u_fpga.u_dut.S2M_AXIS_TLAST  )
     , .axis_tdata   ( u_fpga.u_dut.S2M_AXIS_TDATA  )
     , .sampling_freq( sampling_freq )
   );
   //---------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision history:
//
// 2019.02.21: Started by Ando Ki
//------------------------------------------------------------------------------
