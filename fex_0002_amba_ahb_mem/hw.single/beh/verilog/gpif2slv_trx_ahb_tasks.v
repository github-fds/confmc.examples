`ifndef GPIF2SLV_TRX_AHB_TASKS_V
`define GPIF2SLV_TRX_AHB_TASKS_V
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems.
// All right reserved.
//------------------------------------------------------------------------------
// gpif2slv_ahb_tasks.v
//------------------------------------------------------------------------------
// VERSION: 2018.04.30.
//------------------------------------------------------------------------------
function [31:0] trx_cmd;
     input [3:0]   prot;
     input integer bleng;
     input [1:0]   lock;
     input integer size; // 1=byte, 2=short, 4=word
     input         write; // 1 for write, 0 for read
begin
     trx_cmd[   31] = 1'b0; // 0 for external, 1 for internal
     trx_cmd[   30] = write;
     trx_cmd[29:28] = lock; // lock
     trx_cmd[27:26] = (size==1) ? 2'b00
                    : (size==2) ? 2'b01
                    : (size==4) ? 2'b10 : 2'b00;
     trx_cmd[25:23] = (bleng== 1) ? 3'b000 // single
                    : (bleng== 4) ? 3'b011 // inc4
                    : (bleng== 8) ? 3'b101 // inc8
                    : (bleng==16) ? 3'b111 // inc16
                    :  3'b001;// incremental
     trx_cmd[22:19] = prot; // protection
     trx_cmd[18:16] = 3'h0; // internal addr
     trx_cmd[15:12] = 4'h0; // internal addr
     trx_cmd[11: 0] = bleng-1; // burst length for un-deterministic incremental
end
endfunction
//------------------------------------------------------------------------------
task ahb_write;
     input [31:0] addr;
     input [ 2:0] size; // num of bytes: 1, 2, 4
     input [31:0] data;
begin
     u2f_data[0] = data;
     gpif2_u2f_dat_core(4'b0100, 4'b0000, 16'h1, 0);
     u2f_data[0] = trx_cmd(4'h0, 10'h1, 2'b00, size, 1);
     u2f_data[1] = addr;
     gpif2_u2f_cmd_core(4'b0010, 4'b0000, 16'h2, 0);
end
endtask
//------------------------------------------------------------------------------
task ahb_read;
     input  [31:0] addr;
     input  [ 2:0] size; // num of bytes: 1, 2, 4
     output [31:0] data;
begin
     u2f_data[0] = trx_cmd(4'h0, 10'h1, 2'b00, size, 0);
     u2f_data[1] = addr;
     gpif2_u2f_cmd_core(4'b0010, 4'b0000, 16'h2, 0);
     gpif2_f2u_dat_core(4'b0000, 16'h1, 0);
     data = f2u_data[0];
end
endtask
//------------------------------------------------------------------------------
reg [31:0] burst_dataW[0:1023];
reg [31:0] burst_dataR[0:1023];
//------------------------------------------------------------------------------
task ahb_write_burst;
     input [31:0] addr;
     input [ 2:0] size; // num of bytes: 1, 2, 4
     input [15:0] bleng; // 1, 4, 8, 16
     integer idx;
begin
     u2f_data[0] = trx_cmd(4'h0, bleng[9:0], 2'b00, size, 1);
     u2f_data[1] = addr;
     gpif2_u2f_cmd_core(4'b0010, 4'b0000, 16'h2, 0);

     for (idx=0; idx<bleng; idx=idx+1) begin
          u2f_data[idx] = burst_dataW[idx];
     end
     gpif2_u2f_dat_core(4'b0100, 4'b0000, bleng, 0);
end
endtask
//------------------------------------------------------------------------------
task ahb_read_burst;
     input  [31:0] addr;
     input  [ 2:0] size; // num of bytes: 1, 2, 4
     input  [15:0] bleng; // 1, 4, 8, 16
     integer idx;
begin
     u2f_data[0] = trx_cmd(4'h0, bleng[10:0], 2'b00, size, 0);
     u2f_data[1] = addr;
     gpif2_u2f_cmd_core(4'b0010, 4'b0000, 16'h2, 0);

     gpif2_f2u_dat_core(4'b0000, bleng, 0);
     for (idx=0; idx<bleng; idx=idx+1) begin
          burst_dataR[idx] = f2u_data[idx];
     end
end
endtask
//------------------------------------------------------------------------------
// It drives GPOUT of trx_ahb.
task ahb_write_gpout;
     input [15:0] gpout;
begin
     u2f_data[0][   31] =  1'b1; // 0 for external, 1 for internal
     u2f_data[0][   30] =  1'b1; // write
     u2f_data[0][29:16] = 14'h0;
     u2f_data[0][15: 0] = gpout;
     gpif2_u2f_cmd_core(4'b0010, 4'b0000, 16'h1, 0);
end
endtask
//------------------------------------------------------------------------------
// It reads GPIN of trx_ahb.
task ahb_read_gpin;
     output        fiq; // active-high
     output        irq; // active-high
     output [15:0] gpin;
begin
     u2f_data[0][   31] =  1'b1; // 0 for external, 1 for internal
     u2f_data[0][   30] =  1'b0; // read
     gpif2_u2f_cmd_core(4'b0010, 4'b0000, 16'h1, 0);
     gpif2_f2u_dat_core(4'b0000, 16'h1, 0);
     fiq  = f2u_data[0][31];
     irq  = f2u_data[0][30];
     gpin = f2u_data[0][15:0];
end
endtask
//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.27: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
`endif
