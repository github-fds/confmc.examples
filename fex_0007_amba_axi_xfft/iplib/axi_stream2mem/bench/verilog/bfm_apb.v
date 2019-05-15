//------------------------------------------------------------------------------
//  Copyright (c) 2019 by Ando Ki.
//  All right reserved.
//  http://www.future-ds.com
//  All rights are reserved by Ando Ki.
//  Do not use in any means or/and methods without Ando Ki's permission.
//------------------------------------------------------------------------------
// bfm_apb.v
//------------------------------------------------------------------------------
// VERSION: 2019.04.05.
//------------------------------------------------------------------------------
//  [MACROS]
//------------------------------------------------------------------------------
`timescale 1ns/1ns

module bfm_apb
     #(parameter APB_AW=32
               , APB_DW=32
               , APB_DS=APB_DW/8
               , AXIS_WIDTH_DATA =32
               , AXIS_WIDTH_DS   =(AXIS_WIDTH_DATA/8)
               , AXI_WIDTH_AD    =32
               , AXI_WIDTH_DA    =32
               , AXI_WIDTH_DS    =(AXI_WIDTH_DA/8)
               )
(
        input   wire              PRESETn
      , input   wire              PCLK
      , output  reg               PSEL=1'b0
      , output  reg               PENABLE=1'b0
      , output  reg  [APB_AW-1:0] PADDR={APB_AW{1'b0}}
      , output  reg               PWRITE=1'b0
      , input   wire [APB_DW-1:0] PRDATA
      , output  reg  [APB_DW-1:0] PWDATA={APB_DW{1'b0}}
      , input   wire              PREADY
      , input   wire              PSLVERR
      , output  reg  [APB_DS-1:0] PSTRB={APB_DS{1'b0}}
      , output  reg  [2:0]        PPROT=3'h0
      , input   wire              IRQ
      , input   wire                         AXIS_CLK
      , input   wire                         ARESETn
      , input   wire                         AXIS_TREADY
      , output  reg                          AXIS_TVALID=1'b0
      , output  reg   [AXIS_WIDTH_DATA-1:0]  AXIS_TDATA={AXIS_WIDTH_DATA{1'b0}}
      , output  reg   [AXIS_WIDTH_DS-1:0]    AXIS_TSTRB={AXIS_WIDTH_DS{1'b0}}
      , output  reg                          AXIS_TLAST=1'b0
      , output  reg                          AXIS_TSTART=1'b0
);
     //-------------------------------------------------------------------------
     `include "apb_tasks.v"
     //-------------------------------------------------------------------------
     reg done=1'b0;
     //-------------------------------------------------------------------------
     localparam CSRA_BASE    = 32'h0000_0000;
     localparam CSRA_VERSION = (CSRA_BASE+8'h00),
                CSRA_CONTROL = (CSRA_BASE+8'h10),
                CSRA_START0  = (CSRA_BASE+8'h20), // DMA area start (inclusive)
                CSRA_START1  = (CSRA_BASE+8'h24),
                CSRA_END0    = (CSRA_BASE+8'h28), // DMA area end (exclusive)
                CSRA_END1    = (CSRA_BASE+8'h2C),
                CSRA_NUM     = (CSRA_BASE+8'h30),
                CSRA_CNT     = (CSRA_BASE+8'h40);
     //-------------------------------------------------------------------------
     reg [31:0] start;
     reg [31:0] frame;
     reg [15:0] packet;
     reg [15:0] chunk ;
     //-------------------------------------------------------------------------
     initial begin
         wait(PRESETn==1'b0);
         wait(PRESETn==1'b1);
         repeat (10) @ (posedge PCLK);
if (0) begin
         check_csr;
         repeat (10) @ (posedge PCLK);
end
if (1) begin
         start  = 32'h0000_0000;
         frame  = 32'h0000_0400;
         packet = 16'h0040;
         chunk  =  8'h10;
         single_test(frame, packet, chunk);
         check_memory(start, frame, packet, 1);
         repeat (10) @ (posedge PCLK);
end
if (1) begin
         start  = 32'h0001_0000;
         frame  = 32'h0000_0400;
         packet = 16'h0040;
         chunk  =  8'h20;
         conti_test(frame, packet, chunk, 3);
         check_memory(start, frame, packet, 3);
         repeat (10) @ (posedge PCLK);
end
         repeat (50) @ (posedge PCLK);
         done = 1'b1;
     end
     //-------------------------------------------------------------------------
     task check_csr;
          reg [31:0] dataR;
     begin
        apb_read(CSRA_VERSION, dataR); $display("VERSION 0x%08X", dataR);
        apb_read(CSRA_CONTROL, dataR); $display("CONTROL 0x%08X", dataR);
        apb_read(CSRA_START0 , dataR); $display("START0  0x%08X", dataR);
        apb_read(CSRA_START1 , dataR); $display("START1  0x%08X", dataR);
        apb_read(CSRA_END0   , dataR); $display("END0    0x%08X", dataR);
        apb_read(CSRA_END1   , dataR); $display("END1    0x%08X", dataR);
        apb_read(CSRA_NUM    , dataR); $display("NUM     0x%08X", dataR);
     end
     endtask
     //-------------------------------------------------------------------------
     task set_region;
          input [31:0] Astart;
          input [31:0] Aend ;
          reg   [31:0] dataR ;
     begin
        apb_write(CSRA_START0, Astart);
        apb_write(CSRA_END0  , Aend  );
        apb_read (CSRA_START0, dataR ); $display("START0  0x%08X", dataR);
        apb_read (CSRA_START1, dataR ); $display("START1  0x%08X", dataR);
        apb_read (CSRA_END0  , dataR ); $display("END0    0x%08X", dataR);
        apb_read (CSRA_END1  , dataR ); $display("END1    0x%08X", dataR);
     end
     endtask
     //-------------------------------------------------------------------------
     task push_stream;
          input [31:0] frame ;
          input [15:0] packet;
          input        rand; // insert random delay when 1
          reg [AXIS_WIDTH_DATA-1:0] data;
          integer idx, idy, idz;
          integer seed, delay;
     begin
          for (idz=0; idz<AXIS_WIDTH_DS; idz=idz+1) begin
               data[idz*8+:8] = idz;
          end
          seed=1;
          delay=0;
          for (idx=0; idx<frame; idx=idx+packet) begin
              for (idy=0; idy<packet; idy=idy+AXIS_WIDTH_DS) begin
                   AXIS_TVALID =1'b1;
                   AXIS_TDATA  =data;
                   AXIS_TSTRB  ={AXIS_WIDTH_DS{1'b1}};
                   AXIS_TLAST  =(idy==(packet-AXIS_WIDTH_DS));
                   AXIS_TSTART =(idy==0);
                   @ (posedge AXIS_CLK);
                   while (AXIS_TREADY==1'b0) @ (posedge AXIS_CLK);
                   delay = $random(seed)&32'h3;
                   if ((rand==1)&&(delay>0)) begin
                       AXIS_TVALID =1'b0;
                       AXIS_TLAST  =1'b0;
                       AXIS_TSTART =1'b0;
                       repeat (delay) @ (posedge AXIS_CLK);
                   end
                   for (idz=0; idz<AXIS_WIDTH_DS; idz=idz+1) begin
                        data[idz*8+:8] = data[idz*8+:8]+AXIS_WIDTH_DS;
                   end
              end
          end
          AXIS_TVALID=1'b0;
          AXIS_TLAST =1'b0;
     end
     endtask
     //-------------------------------------------------------------------------
     task check_memory;
          input [AXI_WIDTH_AD-1:0] start;
          input [31:0] frame ; // whole
          input [15:0] packet; // tlast
          input [ 7:0] num; // num of iterations
          reg [AXI_WIDTH_DA-1:0] data, expect;
          integer idx, idy, idz;
          integer addr, err;
     begin
         repeat (num) begin
            for (idz=0; idz<AXI_WIDTH_DS; idz=idz+1) begin
                 expect[idz*8+:8] = idz;
            end
            err = 0;
            addr = start;
            for (idx=0; idx<frame; idx=idx+packet) begin
                 for (idy=0; idy<packet; idy=idy+chunk) begin
                      u_mem.read(addr, data);
                      for (idz=0; idz<AXI_WIDTH_DS; idz=idz+1) begin
                           if (expect[idx*8+:8]!=data[idx*8+:8]) begin
                               $display("%0d 0x%02X:%02X", idz, expect[idz*8+:8], data[idz*8+:8]);
                               err = err + 1;
                           end
                      end
                      for (idz=0; idz<AXI_WIDTH_DS; idz=idz+1) begin
                           expect[idz*8+:8] = expect[idz*8+:8]+AXI_WIDTH_DS;
                      end
                      addr = addr + AXI_WIDTH_DS;
                 end
            end
            if (err>0) $display("%t %m mis-match %d", $time, err);
            else       $display("%t %m OK", $time);
         end
     end
     endtask
     //-------------------------------------------------------------------------
     // 1. fill known-pattern to the memory
     // 2. let the core run
     task single_test;
          input [31:0] frame ;
          input [15:0] packet;
          input [ 7:0] chunk ;
          reg [31:0] dataR, dataW;
     begin
         apb_write(CSRA_CONTROL, 32'h8000_0001); // en
         set_region(start, start+frame);
         dataW = 32'h0;
         dataW[31] = 1'b1; // go
         dataW[28] = 1'b0; // cont
         dataW[23:16] = chunk; // chunk
         dataW[15: 0] = packet; // num_byte
         apb_write(CSRA_NUM, dataW);
         dataR = dataW;
         fork
            while (dataR[31]==1'b1) apb_read(CSRA_NUM, dataR);
            push_stream(frame, packet, 1);
         join
     end
     endtask
     //-------------------------------------------------------------------------
     task conti_test;
          input [31:0] frame ;
          input [15:0] packet;
          input [ 7:0] chunk ;
          input [31:0] count ;
          reg [31:0] idx, idy;
          reg [31:0] dataR, dataW;
          reg [AXI_WIDTH_DA-1:0] dataM;
     begin
         apb_write(CSRA_CONTROL, 32'h8000_0001); // en
         set_region(start, start+frame);
         apb_write(CSRA_CNT, count);
         dataW = 32'h0;
         dataW[31] = 1'b1; // go
         dataW[28] = 1'b1; // cont
         dataW[23:16] = chunk; // chunk
         dataW[15: 0] = packet; // num_byte
         apb_write(CSRA_NUM, dataW);
         dataR = 32'h0;
         dataR = dataW;
         fork
            while (dataR[31]==1'b1) apb_read(CSRA_NUM, dataR);
            repeat (count) push_stream(frame, packet, 1);
         join
     end
     endtask
     //-------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2019.04.05: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
