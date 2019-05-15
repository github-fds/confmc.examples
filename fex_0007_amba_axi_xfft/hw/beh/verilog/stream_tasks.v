`ifndef STREAM_TASKS_V
`define STREAM_TASKS_V
//------------------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems.
// All right reserved.
//------------------------------------------------------------------------------
// stream_tasks.v
//------------------------------------------------------------------------------
// VERSION: 2019.04.05.
//------------------------------------------------------------------------------
   localparam CSRA_CONFIG_BASE    =32'h0000_0000;
   localparam CSRA_CONFIG_VERSION =(CSRA_CONFIG_BASE+8'h00)
            , CSRA_CONFIG_RESET   =(CSRA_CONFIG_BASE+8'h10)
            , CSRA_CONFIG_CONFIG  =(CSRA_CONFIG_BASE+8'h14)
            , CSRA_CONFIG_STATUS  =(CSRA_CONFIG_BASE+8'h18);
//------------------------------------------------------------------------------
task xfft_csr;
    reg [31:0] dataR;
begin
    axi_read(CSRA_CONFIG_VERSION, 4, dataR); $display("CONFIG_VERSION: 0x%08X", dataR);
    axi_read(CSRA_CONFIG_RESET  , 4, dataR); $display("CONFIG_RESET  : 0x%08X", dataR);
    axi_read(CSRA_CONFIG_CONFIG , 4, dataR); $display("CONFIG_CONFIG : 0x%08X", dataR);
    axi_read(CSRA_CONFIG_STATUS , 4, dataR); $display("CONFIG_STATUS : 0x%08X", dataR);
end
endtask
//------------------------------------------------------------------------------
task xfft_reset;
    reg [31:0] dataW;
begin
    dataW = 32'h1;
    axi_write(CSRA_CONFIG_RESET  , 4, dataW);
    dataW = 32'h0;
    axi_write(CSRA_CONFIG_RESET  , 4, dataW);
end
endtask
//------------------------------------------------------------------------------
task set_xfft;
     reg [31:0] dataW;
integer flag;
begin
      // XFFT_ARESETn
      dataW = 32'h1;
      axi_write(CSRA_CONFIG_RESET, 4, dataW);
      dataW = 32'h0;
      axi_write(CSRA_CONFIG_RESET, 4, dataW);

      // Set config by COFIG_AXIS_TVALID<=1'b1
      dataW = 32'h01;
      axi_write(CSRA_CONFIG_CONFIG, 4, dataW);
end
endtask
//------------------------------------------------------------------------------
   localparam CSRA_M2S_BASE    = 32'h0001_0000;
   localparam CSRA_M2S_VERSION = (CSRA_M2S_BASE+8'h00),
              CSRA_M2S_CONTROL = (CSRA_M2S_BASE+8'h10),
              CSRA_M2S_START0  = (CSRA_M2S_BASE+8'h20), // DMA area start (inclusive)
              CSRA_M2S_START1  = (CSRA_M2S_BASE+8'h24),
              CSRA_M2S_END0    = (CSRA_M2S_BASE+8'h28), // DMA area end (exclusive)
              CSRA_M2S_END1    = (CSRA_M2S_BASE+8'h2C),
              CSRA_M2S_NUM     = (CSRA_M2S_BASE+8'h30),
              CSRA_M2S_CNT     = (CSRA_M2S_BASE+8'h40); // count for continuous
//------------------------------------------------------------------------------
task m2s_set;
     input  [31:0] start ;
     input  [31:0] frame ;
     input  [15:0] packet;
     input  [ 7:0] chunk ;
     input  [31:0] cnum  ;
     input         cont  ;
     input         go    ;
     input  [31:0] time_out;
     reg [31:0] dataR, dataW;
     reg [31:0] value;
     integer num;
begin
    value = start + frame;
    axi_write(CSRA_M2S_START0, 4, start);
    axi_write(CSRA_M2S_END0  , 4, value);
    axi_write(CSRA_M2S_CNT   , 4, cnum );
    value = 0;
    value[31] = go;
    value[28] = cont;
    value[23:16] = chunk;
    value[15: 0] = packet;
    axi_write(CSRA_M2S_NUM, 4, value);
    if (cnum!=0) begin
        num = 0;
        while ((time_out==0)||(num<time_out)) begin
             axi_read(CSRA_M2S_NUM, 4, value);
             if (value[31]==1'b0) disable m2s_set; 
             num = num + 1;
        end
    end
end
endtask
//------------------------------------------------------------------------------
task m2s_get;
     output [31:0] start ;
     output [31:0] frame ;
     output [15:0] packet;
     output [ 7:0] chunk ;
     output        cont  ;
     reg [31:0] dataR;
begin
     axi_read(CSRA_M2S_START0, 4, dataR); start = dataR;
     axi_read(CSRA_M2S_END0, 4, dataR); frame = dataR - start;
     axi_read(CSRA_M2S_NUM, 4, dataR); packet = dataR[15:0];
                                       chunk = dataR[23:16];
                                       cont = dataR[28];
end
endtask
//------------------------------------------------------------------------------
task m2s_enable;
     input en;
     input ie;
     reg [31:0] dataW;
begin
     dataW = 32'h0;
     dataW[31] = (en) ? 1'b1 : 1'b0;
     dataW[ 0] = (ie) ? 1'b1 : 1'b0;
     axi_write(CSRA_M2S_CONTROL, 4, dataW);
end
endtask
//------------------------------------------------------------------------------
task m2s_csr;
    reg [31:0] dataR;
begin
    axi_read(CSRA_M2S_VERSION, 4, dataR); $display("M2S_VERSION: 0x%08X", dataR);
    axi_read(CSRA_M2S_CONTROL, 4, dataR); $display("M2S_CONTROL: 0x%08X", dataR);
    axi_read(CSRA_M2S_START0 , 4, dataR); $display("M2S_START0 : 0x%08X", dataR);
    axi_read(CSRA_M2S_START1 , 4, dataR); $display("M2S_START1 : 0x%08X", dataR);
    axi_read(CSRA_M2S_END0   , 4, dataR); $display("M2S_END0   : 0x%08X", dataR);
    axi_read(CSRA_M2S_END1   , 4, dataR); $display("M2S_END1   : 0x%08X", dataR);
    axi_read(CSRA_M2S_NUM    , 4, dataR); $display("M2S_NUM    : 0x%08X", dataR);
    axi_read(CSRA_M2S_CNT    , 4, dataR); $display("M2S_CNT    : 0x%08X", dataR);
end
endtask
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
   localparam CSRA_S2M_BASE    = 32'h0002_0000;
   localparam CSRA_S2M_VERSION =(CSRA_S2M_BASE+8'h00),
              CSRA_S2M_CONTROL =(CSRA_S2M_BASE+8'h10),
              CSRA_S2M_START0  =(CSRA_S2M_BASE+8'h20), // DMA area start (inclusive)
              CSRA_S2M_START1  =(CSRA_S2M_BASE+8'h24),
              CSRA_S2M_END0    =(CSRA_S2M_BASE+8'h28), // DMA area end (exclusive)
              CSRA_S2M_END1    =(CSRA_S2M_BASE+8'h2C),
              CSRA_S2M_NUM     =(CSRA_S2M_BASE+8'h30),
              CSRA_S2M_CNT     =(CSRA_S2M_BASE+8'h40); // count for continuous
//------------------------------------------------------------------------------
task s2m_set;
     input  [31:0] start ;
     input  [31:0] frame ;
     input  [15:0] packet;
     input  [ 7:0] chunk ;
     input  [31:0] cnum  ;
     input         cont  ;
     input         go    ;
     input  [31:0] time_out;
     reg [31:0] dataR, dataW;
     reg [31:0] value;
     integer num;
begin
    value = start + frame;
    axi_write(CSRA_S2M_START0, 4, start);
    axi_write(CSRA_S2M_END0  , 4, value);
    axi_write(CSRA_S2M_CNT   , 4, cnum );
    value = 0;
    value[31] = go;
    value[28] = cont;
    value[23:16] = chunk;
    value[15: 0] = packet;
    axi_write(CSRA_S2M_NUM, 4, value);
    if (cnum!=0) begin
        num = 0;
        while ((time_out==0)||(num<time_out)) begin
             axi_read(CSRA_S2M_NUM, 4, value);
             if (value[31]==1'b0) disable s2m_set; 
             num = num + 1;
        end
    end
end
endtask
//------------------------------------------------------------------------------
task s2m_get;
     output [31:0] start ;
     output [31:0] frame ;
     output [15:0] packet;
     output [ 7:0] chunk ;
     output        cont  ;
     reg [31:0] dataR;
begin
     axi_read(CSRA_S2M_START0, 4, dataR); start = dataR;
     axi_read(CSRA_S2M_END0, 4, dataR); frame = dataR - start;
     axi_read(CSRA_S2M_NUM, 4, dataR); packet = dataR[15:0];
                                       chunk = dataR[23:16];
                                       cont = dataR[28];
end
endtask
//------------------------------------------------------------------------------
task s2m_enable;
     input en;
     input ie;
     reg [31:0] dataW;
begin
     dataW = 32'h0;
     dataW[31] = (en) ? 1'b1 : 1'b0;
     dataW[ 0] = (ie) ? 1'b1 : 1'b0;
     axi_write(CSRA_S2M_CONTROL, 4, dataW);
end
endtask
//------------------------------------------------------------------------------
task s2m_csr;
    reg [31:0] dataR;
begin
    axi_read(CSRA_S2M_VERSION, 4, dataR); $display("S2M_VERSION: 0x%08X", dataR);
    axi_read(CSRA_S2M_CONTROL, 4, dataR); $display("S2M_CONTROL: 0x%08X", dataR);
    axi_read(CSRA_S2M_START0 , 4, dataR); $display("S2M_START0 : 0x%08X", dataR);
    axi_read(CSRA_S2M_START1 , 4, dataR); $display("S2M_START1 : 0x%08X", dataR);
    axi_read(CSRA_S2M_END0   , 4, dataR); $display("S2M_END0   : 0x%08X", dataR);
    axi_read(CSRA_S2M_END1   , 4, dataR); $display("S2M_END1   : 0x%08X", dataR);
    axi_read(CSRA_S2M_NUM    , 4, dataR); $display("S2M_NUM    : 0x%08X", dataR);
    axi_read(CSRA_S2M_CNT    , 4, dataR); $display("S2M_CNT    : 0x%08X", dataR);
end
endtask
//------------------------------------------------------------------------------
// Revision History
//
// 2019.04.05: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
`endif
