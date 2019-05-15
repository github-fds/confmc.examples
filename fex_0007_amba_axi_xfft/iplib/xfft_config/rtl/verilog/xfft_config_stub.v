// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Sat May 11 23:37:33 2019
// Host        : AndoUbuntu running 64-bit Ubuntu 16.04.6 LTS
// Command     : write_verilog -force -mode synth_stub xfft_config_stub.v
// Design      : xfft_config
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module xfft_config(PRESETn, PCLK, PSEL, PENABLE, PADDR, PWRITE, PRDATA, 
  PWDATA, axis_clk, axis_config_resetn, axis_config_tready, axis_config_tvalid, 
  axis_config_tdata)
/* synthesis syn_black_box black_box_pad_pin="PRESETn,PCLK,PSEL,PENABLE,PADDR[31:0],PWRITE,PRDATA[31:0],PWDATA[31:0],axis_clk,axis_config_resetn,axis_config_tready,axis_config_tvalid,axis_config_tdata[7:0]" */;
  input PRESETn;
  input PCLK;
  input PSEL;
  input PENABLE;
  input [31:0]PADDR;
  input PWRITE;
  output [31:0]PRDATA;
  input [31:0]PWDATA;
  input axis_clk;
  output axis_config_resetn;
  input axis_config_tready;
  output axis_config_tvalid;
  output [7:0]axis_config_tdata;
endmodule
