`ifndef GPIF2SLV_AES_TASKS_V
`define GPIF2SLV_TASKS_V
//------------------------------------------------------------------------------
//  Copyright (c) 2018 by Ando Ki.
//  All right reserved.
//
//  andoki@gmail.com
//------------------------------------------------------------------------------
// gpif2if_aes_task.v
//------------------------------------------------------------------------------
// VERSION: 2018.06.12.
//------------------------------------------------------------------------------
// [NOTE]
//------------------------------------------------------------------------------
   localparam P_ADDR_START      = 32'hC000_0000;
   localparam CSRA_CONTROL      = P_ADDR_START+'h00,
              CSRA_STATUS       = P_ADDR_START+'h04,
              CSRA_KEY0         = P_ADDR_START+'h10, // [127:96]
              CSRA_KEY1         = P_ADDR_START+'h14, // [ 95:64]
              CSRA_KEY2         = P_ADDR_START+'h18, // [ 63:32]
              CSRA_KEY3         = P_ADDR_START+'h1C, // [ 31: 0]
              CSRA_DATAIN0      = P_ADDR_START+'h20, // [127:96] // write only
              CSRA_DATAIN1      = P_ADDR_START+'h24, // [ 95:64]
              CSRA_DATAIN2      = P_ADDR_START+'h28, // [ 63:32]
              CSRA_DATAIN3      = P_ADDR_START+'h2C, // [ 31: 0]
              CSRA_DATAOUT0     = P_ADDR_START+'h30, // [127:96] // read only
              CSRA_DATAOUT1     = P_ADDR_START+'h34, // [ 95:64]
              CSRA_DATAOUT2     = P_ADDR_START+'h38, // [ 63:32]
              CSRA_DATAOUT3     = P_ADDR_START+'h3C; // [ 31: 0]
//------------------------------------------------------------------------------
function [31:0] swap;
    input [31:0] data;
begin
    swap[31:24] = data[ 7: 0];
    swap[23:16] = data[15: 8];
    swap[15: 8] = data[23:16];
    swap[ 7: 0] = data[31:24];
end
endfunction
//------------------------------------------------------------------------------
`define CRD(A,D)\
        axi_read((A) , 4, dataR); $display("%10s: 0x%08X", (D), dataR)
task aes_csr_test;
     reg [31:0] dataR;
begin
    `CRD(CSRA_CONTROL , "CONTROL ");
    `CRD(CSRA_STATUS  , "STATUS  ");
    `CRD(CSRA_KEY0    , "KEY0    ");
    `CRD(CSRA_KEY1    , "KEY1    ");
    `CRD(CSRA_KEY2    , "KEY2    ");
    `CRD(CSRA_KEY3    , "KEY3    ");
    `CRD(CSRA_DATAIN0 , "DATAIN0 ");
    `CRD(CSRA_DATAIN1 , "DATAIN1 ");
    `CRD(CSRA_DATAIN2 , "DATAIN2 ");
    `CRD(CSRA_DATAIN3 , "DATAIN3 ");
    `CRD(CSRA_DATAOUT0, "DATAOUT0");
    `CRD(CSRA_DATAOUT1, "DATAOUT1");
    `CRD(CSRA_DATAOUT2, "DATAOUT2");
    `CRD(CSRA_DATAOUT3, "DATAOUT3");
end
endtask

//------------------------------------------------------------------------------
task aes_key_set;
     input         enc_dec; // 1=enc, 0=dec
     input [127:0] key;
     input         go;
     input         check;
     reg   [ 31:0] dataR, dataW;
     reg   [127:0] key_rd;
integer flag;
begin
flag=0;
     //-------------------------------------------------------------------------
     // assert aes_reset
     dataW = (enc_dec<<1) | 1'b1; 
     axi_write(CSRA_CONTROL, 4, dataW);
flag=1;
     //-------------------------------------------------------------------------
     // set key
     // little-endian access ==> AES core will swap it to big-endian
     burst_dataW[0][ 7: 0] = key[127:120];
     burst_dataW[0][15: 8] = key[119:112];
     burst_dataW[0][23:16] = key[111:104];
     burst_dataW[0][31:24] = key[103: 96]; 
     burst_dataW[1][ 7: 0] = key[ 95: 88];
     burst_dataW[1][15: 8] = key[ 87: 80];
     burst_dataW[1][23:16] = key[ 79: 72];
     burst_dataW[1][31:24] = key[ 71: 64]; 
     burst_dataW[2][ 7: 0] = key[ 63: 56];
     burst_dataW[2][15: 8] = key[ 55: 48];
     burst_dataW[2][23:16] = key[ 47: 40];
     burst_dataW[2][31:24] = key[ 39: 32]; 
     burst_dataW[3][ 7: 0] = key[ 31: 24];
     burst_dataW[3][15: 8] = key[ 23: 16];
     burst_dataW[3][23:16] = key[ 15:  8];
     burst_dataW[3][31:24] = key[  7:  0];
     axi_write_burst(CSRA_KEY0 // addr
                    ,4 // size
                    ,4 // leng
                    ,2'b01);// inc
flag=2;
     //-------------------------------------------------------------------------
     // de-assert aes_reset
     dataW = (enc_dec<<1) | 1'b0; 
     axi_write(CSRA_CONTROL, 4, dataW);
flag=3;
     //-------------------------------------------------------------------------
     // wait for aes_ready
     dataR = 32'h0;
     while ((dataR>>31)!==1'b1) begin // wait ready
             axi_read(CSRA_CONTROL, 4, dataR);
     end
flag=4;
     //-------------------------------------------------------------------------
     // wait for aes_ready
     if (go) begin
         dataW = (1'b1<<2) |(enc_dec<<1) | 1'b0; 
         axi_write(CSRA_CONTROL, 4, dataW);
     end
flag=5;
     //-------------------------------------------------------------------------
     // get key
     if (check) begin
         axi_read_burst(CSRA_KEY0 // addr
                       ,4 // size
                       ,4 // leng
                       ,2'b01); // inc
         key_rd[127:96] = swap(burst_dataR[0]);
         key_rd[ 95:64] = swap(burst_dataR[1]);
         key_rd[ 63:32] = swap(burst_dataR[2]);
         key_rd[ 31: 0] = swap(burst_dataR[3]);
         if (key!==key_rd) $display("%t %m key mis-match", $time);
         else              $display("%t %m key match", $time);
     end
flag=6;
end
endtask
//------------------------------------------------------------------------------
reg [7:0] text_in [0:1023];
reg [7:0] text_out[0:1023];
reg [7:0] text_rsl[0:1023];
reg [7:0] text_exp[0:1023];
//------------------------------------------------------------------------------
// It uses pre-set key and mode.
// aes-word=16-byte(128-bit)
// 4-words / aes-word
// 4-bytes / word
//
// Note that result will be a multiple of 128-bit (16-byte).
// Note 1-byte cyption results in 16-byte output.
task aes_crypt;
     input integer bnum; // num of bytes to crypt
     integer anum; // num of 16-byte words (128-bit)
     integer wnum; // num of 4-byte words (32-bit)
     integer idx, idy;
     reg [31:0] dataR;
begin
     if (bnum==0) begin
         $display("%t %m 0 num byte", $time);
         $stop(2);
     end
     //-------------------------------------------------------------------------
     anum = (bnum+15)/16; // num of aes-words to transfer
     wnum = anum*4; // num of words to transfer
     idy = 0;
     while ((wnum-256)>0) begin
         dataR = 0;
         while ((dataR&32'hFFFF)<256) axi_read(CSRA_STATUS, 4, dataR);
         for (idx=0; idx<256; idx=idx+1) begin
              burst_dataW[idx] = {text_in[idy+3]
                                 ,text_in[idy+2]
                                 ,text_in[idy+1]
                                 ,text_in[idy+0]};
              idy = idy + 4;
         end
         axi_write_burst(CSRA_DATAIN0 // addr
                        ,4    // size
                        ,256  // leng
                        ,2'b00);// fixed
         wnum = wnum - 256;
     end
     if (wnum>0) begin
         dataR = 0;
         while ((dataR&32'hFFFF)<wnum) axi_read(CSRA_STATUS, 4, dataR);
         for (idx=0; idx<wnum; idx=idx+1) begin
              burst_dataW[idx] = {text_in[idy+3]
                                 ,text_in[idy+2]
                                 ,text_in[idy+1]
                                 ,text_in[idy+0]};
              idy = idy + 4;
         end
         axi_write_burst(CSRA_DATAIN0 // addr
                        ,4    // size
                        ,wnum // leng
                        ,2'b00);// fixed
     end
     //-------------------------------------------------------------------------
     wnum = anum*4; // num of words to transfer
     idy = 0;
     while ((wnum-256)>0) begin
         dataR = 0;
         while ((dataR>>16)<256) axi_read(CSRA_STATUS, 4, dataR);
         axi_read_burst(CSRA_DATAOUT0 // addr
                       ,4    // size
                       ,256  // leng
                       ,2'b00);// fixed
         for (idx=0; idx<256; idx=idx+1) begin
              {text_out[idy+3]
              ,text_out[idy+2]
              ,text_out[idy+1]
              ,text_out[idy+0]} = burst_dataR[idx];
              idy = idy + 4;
         end
         wnum = wnum - 256;
     end
     if (wnum>0) begin
         dataR = 0;
         while ((dataR>>16)<wnum) axi_read(CSRA_STATUS, 4, dataR);
         axi_read_burst(CSRA_DATAOUT0 // addr
                       ,4    // size
                       ,wnum // leng
                       ,2'b00);// fixed
         for (idx=0; idx<wnum; idx=idx+1) begin
              {text_out[idy+3]
              ,text_out[idy+2]
              ,text_out[idy+1]
              ,text_out[idy+0]} = burst_dataR[idx];
              idy = idy + 4;
         end
     end
end
endtask
//------------------------------------------------------------------------------
// only handling one 128-bit data with corresponding key
task aes_one;
     input dir; // 1=encryption, 0=decryption
     input [127:0] key  ;
     input [127:0] plain;
     input [127:0] cyper;
     reg   [ 31:0] dataW, dataR;
     reg   [127:0] dataGet;
     output        ok;
begin
`ifdef xxyy00
     //-------------------------------------------------------------------------
     // assert aes_reset
     dataW = (dir<<1) | 1'b1; 
     axi_write(CSRA_CONTROL, 4, dataW);
     //-------------------------------------------------------------------------
     // set key
     burst_dataW[0] = swap(key[127:96]);
     burst_dataW[1] = swap(key[ 95:64]);
     burst_dataW[2] = swap(key[ 63:32]);
     burst_dataW[3] = swap(key[ 31: 0]);
     axi_write_burst(CSRA_KEY0 // addr
                    ,4 // size
                    ,4 // leng
                    ,2'b01);// inc
     //-------------------------------------------------------------------------
     // de-assert aes_reset
     dataW = (dir<<1) | 1'b0; 
     axi_write(CSRA_CONTROL, 4, dataW);
     //-------------------------------------------------------------------------
     // wait for aes_ready
     dataR = 32'h0;
     while ((dataR>>31)!==1'b1) begin // wait ready
             axi_read(CSRA_CONTROL, 4, dataR);
     end
     //-------------------------------------------------------------------------
     // let it go
     dataW = (1'b1<<2) |(dir<<1) | 1'b0; 
     axi_write(CSRA_CONTROL, 4, dataW);
`else
     aes_key_set(dir, key, 1'b1, 1'b0);
`endif
     //-------------------------------------------------------------------------
     // push data
     if (dir==1'b1) begin
         burst_dataW[0] = swap(plain[127:96]);
         burst_dataW[1] = swap(plain[ 95:64]);
         burst_dataW[2] = swap(plain[ 63:32]);
         burst_dataW[3] = swap(plain[ 31: 0]);
     end else begin
         burst_dataW[0] = swap(cyper[127:96]);
         burst_dataW[1] = swap(cyper[ 95:64]);
         burst_dataW[2] = swap(cyper[ 63:32]);
         burst_dataW[3] = swap(cyper[ 31: 0]);
     end
     axi_write_burst(CSRA_DATAIN0 // addr
                    ,4 // size
                    ,4 // leng
                    ,2'b00);// fixed
     //-------------------------------------------------------------------------
     // wait for done
     dataR = 32'h0;
     while ((dataR>>16)==1'b0) begin // wait ready
             axi_read(CSRA_STATUS, 4, dataR);
     end
     //-------------------------------------------------------------------------
     // read back
     axi_read_burst(CSRA_DATAOUT0 // addr
                   ,4 // size
                   ,4 // leng
                   ,2'b00); // fixed
     dataGet[127:96] = swap(burst_dataR[0]); 
     dataGet[ 95:64] = swap(burst_dataR[1]); 
     dataGet[ 63:32] = swap(burst_dataR[2]); 
     dataGet[ 31: 0] = swap(burst_dataR[3]); 
     //-------------------------------------------------------------------------
     // check
     if (dir==1'b1) begin
        if (dataGet!==cyper) ok = 1'b0;
         else ok = 1'b1;
     end else begin
        if (dataGet!== plain) ok = 1'b0;
         else ok = 1'b1;
     end
end
endtask
//------------------------------------------------------------------------------
`include "aes_kat128.v"
//------------------------------------------------------------------------------
task aes_kat128;
     input         dir; // 1=enc, 0=dec
     input integer num;
     integer idx;
     integer error;
     reg     ok;
begin
     error = 0;
     for (idx=0; idx<num; idx=idx+1) begin
          aes_one(dir, key[idx], plain[idx], cyper[idx], ok);
          if (ok==1'b0) error = error + 1;
          repeat (5) @ (posedge SL_PCLK);
     end
     if (error==0) $display("%m AES128 Known Answer %s Test OK %d",
                                (dir==1'b1) ? "Encryption" : "Decryption",
                                num);
     else          $display("%m AES128 Known Answer %s Test Missmatch %d out of %d",
                                (dir==1'b1) ? "Encryption" : "Decryption",
                                error, num);
end
endtask
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.12: Started by Ando Ki (andoki@gmail.com)
//------------------------------------------------------------------------------
`endif
