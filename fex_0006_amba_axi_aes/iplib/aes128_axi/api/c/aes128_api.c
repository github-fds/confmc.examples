//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//------------------------------------------------------------------------------
// aes128_api.c
//------------------------------------------------------------------------------
// VERSION = 2018.06.12.
//------------------------------------------------------------------------------
#include <stdio.h>
#include <stdint.h>
#include "aes128_api.h"
#include "bfm_api.h"

extern con_Handle_t handle;
static unsigned int burst_leng=256;

//------------------------------------------------------------------------------
// Register access macros
#if defined(TRX_BFM) || defined(BFM_AXI) || defined(BFM_AHB)
  #define REGR(A,B)  BfmRead(handle, (unsigned int)(A), (unsigned int*)&(B), 4, 1)
  #define REGW(A,B)  BfmWrite(handle, (unsigned int)(A), (unsigned int*)&(B), 4, 1)
  #define REGRP(A,P) BfmRead(handle, (unsigned int)(A), (unsigned int*)(P), 4, 1)
  #define REGWP(A,P) BfmWrite(handle, (unsigned int)(A), (unsigned int*)(P), 4, 1)
  #define MEM_WRITE_G(A,D,S,L)   BfmWrite(handle, (A), (D), (S), (L)) // inc
  #define MEM_WRITE_F(A,D,S,L)   BfmWriteFix(handle, (A), (D), (S), (L)) // fixed
  #define MEM_READ_G(A,D,S,L)    BfmRead(handle, (A), (D), (S), (L)) // inc
  #define MEM_READ_F(A,D,S,L)    BfmReadFix(handle, (A), (D), (S), (L)) // fixed
#else
  #define REG32(add)      *((volatile uint32_t *)(add))
  #define REG32R(add,dat) (dat) = *((volatile uint32_t *)(add))
  #define REG32W(add,dat) *((volatile uint32_t *)(add)) = (dat)
  #define REG(add)        REG32(add)
  #define REGR(add,dat)   REG32R(add,dat)
  #define REGW(add,dat)   REG32W(add,dat)
#endif

//------------------------------------------------------------------------------
#ifndef ADDR_AES128_START
#define ADDR_AES128_START 0xC0000000
#endif

#define CSRA_CONTROL     (ADDR_AES128_START+0x00)
#define CSRA_STATUS      (ADDR_AES128_START+0x04)
#define CSRA_KEY0        (ADDR_AES128_START+0x10) // [127:96]
#define CSRA_KEY1        (ADDR_AES128_START+0x14) // [ 95:64]
#define CSRA_KEY2        (ADDR_AES128_START+0x18) // [ 63:32]
#define CSRA_KEY3        (ADDR_AES128_START+0x1C) // [ 31: 0]
#define CSRA_DATAIN0     (ADDR_AES128_START+0x20) // [127:96] // write only
#define CSRA_DATAIN1     (ADDR_AES128_START+0x24) // [ 95:64]
#define CSRA_DATAIN2     (ADDR_AES128_START+0x28) // [ 63:32]
#define CSRA_DATAIN3     (ADDR_AES128_START+0x2C) // [ 31: 0]
#define CSRA_DATAOUT0    (ADDR_AES128_START+0x30) // [127:96] // read only
#define CSRA_DATAOUT1    (ADDR_AES128_START+0x34) // [ 95:64]
#define CSRA_DATAOUT2    (ADDR_AES128_START+0x38) // [ 63:32]
#define CSRA_DATAOUT3    (ADDR_AES128_START+0x3C) // [ 31: 0]

//------------------------------------------------------------------------------
// [31] ready (RO)
// [ 2] go
// [ 1] enc_dec
// [ 0] init
// return 0 on success, otherwize !=0
int aes128_control ( unsigned int enc_dec
                   , unsigned int go )
{
    uint32_t dataW, dataR;
    REGR(CSRA_CONTROL, dataR);
    if (go) dataW = dataR| (0x1<<2);
    else    dataW = dataR&~(0x1<<2);
    if (enc_dec) dataW = dataW| (0x1<<1);
    else         dataW = dataW&~(0x1<<1);
    REGW(CSRA_CONTROL, dataW);
}
//------------------------------------------------------------------------------
// It set key.
// 128'h1122_3344_5566_7788_99AA_BBCC_DDEE_FF00
// key_or_data[127:120] = 8'h11
// key_or_data[119:112] = 8'h22
// key_or_data[111:104] = 8'h33
// key_or_data[103: 96] = 8'h44 
// key_or_data[ 95: 88] = 8'h55
// key_or_data[ 87: 80] = 8'h66
// key_or_data[ 79: 72] = 8'h77
// key_or_data[ 71: 64] = 8'h88 
// key_or_data[ 63: 56] = 8'h99
// key_or_data[ 55: 48] = 8'hAA
// key_or_data[ 47: 40] = 8'hBB
// key_or_data[ 39: 32] = 8'hCC 
// key_or_data[ 31: 24] = 8'hDD
// key_or_data[ 23: 16] = 8'hEE
// key_or_data[ 15:  8] = 8'hFF
// key_or_data[  7:  0] = 8'h00
//
//          +0  +1  +2  +3  +4  +5  +6
//         +---+---+---+---+---+---+---+---+
// key --> |11 |22 |33 |44 |55 |66 |77 |88 |...
//         +---+---+---+---+---+---+---+---+
//
// 'key' is byte-stream in binary, not character hex
// 'key' should be seen as big-endian fashion.
//
// When 'key' is sent to the AES128 HW in a 4-byte items as little-endain format,
// the AES128 HW swaps 4-byte in to big-endian.
//
// key    : pointer to a byte array containing
//          key[0] will be MSByte at HW
// enc_dec: 1 for encryption
//          0 for decryption
// go     : let AES start when 1
// timeout: 0 for blocking
//
// return 0 on success, otherwize !=0
int aes128_key_set ( uint8_t *key
                   , unsigned int enc_dec
                   , unsigned int go
                   , unsigned int timeout )
{
#if defined(RIGOR)
    if (key==NULL) return 1;
#endif
    uint32_t dataW, dataR;
    //--------------------------------------------------------------------------
    // assert reset
    // note that fifo for palin and cyper will be clear when reset.
    dataW = ((enc_dec&0x1)<<1 ) | 0x1;
    REGW(CSRA_CONTROL, dataW);
    //--------------------------------------------------------------------------
    // set key
    MEM_WRITE_G(CSRA_KEY0,(unsigned int*)key,4,4); // 4-byte 4-beat
    //--------------------------------------------------------------------------
    // deassert reset and let it go
    dataW = ((go&0x1)<<2) | ((enc_dec&0x1)<<1);
    REGW(CSRA_CONTROL, dataW);
    //--------------------------------------------------------------------------
    // wait for ready
    unsigned int acc=0;
    do { REGR(CSRA_CONTROL, dataR);
         acc++;
    } while (((dataR>>31)==0)&&((timeout==0)||(timeout>acc)));
    //--------------------------------------------------------------------------
#if 0
uint8_t key_rd[16];
MEM_READ_G(CSRA_KEY0,(unsigned int*)key_rd,4,4); // 4-byte 4-beat
int idx;
for (idx=0; idx<16; idx++) printf("%d 0x%02X:%02X\n", idx, key[idx], key_rd[idx]);
#endif
    //--------------------------------------------------------------------------
    return (dataR&0x80000000) ? 0 : 1;
}

//------------------------------------------------------------------------------
// 'textIn' and 'textOut' uses little-endian data fashion,
// but AES128 HW swaps 4-byte in to big-endian.
//
// 'textIn' will be divided into 128-bit items.
// 0 will be padded for less than 128-bit.
//
// when 'textIn' is less than 16-byte (128-bit), 16-byte will be feed.
//
// timeout: 0 for blocking
int aes128_cyper( unsigned int anum // num of 128-bit word
                , uint8_t *textOut  // dst: should be 16-byte length at least
                , uint8_t *textIn   // src: should be 16-byte length at least
                , unsigned int timeout )
{
#if defined(RIGOR)
    if (textIn==NULL) return 1;
    if (textOut==NULL) return 1;
    if (anum==0) return 1;
#endif
    uint32_t dataR;
    unsigned int acc;
    unsigned int wnum = anum*4; // num of 4-byte words
    //--------------------------------------------------------------------------
    // AMBA AXI4 support upto 256-beat burst
    unsigned int burst=burst_leng;
    while (wnum>=burst) {
           //-------------------------------------------------------------------
           // check for rooms
           acc = 0;
           do { REGR(CSRA_STATUS, dataR);
                acc++;
           } while (((dataR&0xFFFF)<burst)&&((timeout==0)||(timeout>acc)));
           if ((dataR&0xFFFF)<burst) return 1;
           //-------------------------------------------------------------------
           MEM_WRITE_F(CSRA_DATAIN0,(unsigned int*)textIn,4,burst); // 128-bit num items
           //-------------------------------------------------------------------
           // check for items
           do { REGR(CSRA_STATUS, dataR);
                acc++;
           acc = 0;
           } while (((dataR>>16)<burst)&&((timeout==0)||(timeout>acc)));
           if ((dataR>>16)<burst) return 1;
           //-------------------------------------------------------------------
           // get results
           MEM_READ_F(CSRA_DATAOUT0,(unsigned int*)textOut,4,burst); // 128-bit num items
           //-------------------------------------------------------------------
           wnum -= burst;
           textIn  += (burst*4);
           textOut += (burst*4);
    }
    if (wnum>0) {
        //--------------------------------------------------------------------------
        // check for rooms
        acc = 0;
        do { REGR(CSRA_STATUS, dataR);
             acc++;
        } while (((dataR&0xFFFF)<wnum)&&((timeout==0)||(timeout>acc)));
        if ((dataR&0xFFFF)<wnum) return 1;
        //--------------------------------------------------------------------------
        MEM_WRITE_F(CSRA_DATAIN0,(unsigned int*)textIn,4,wnum); // 128-bit num items
        //--------------------------------------------------------------------------
        // check for items
        do { REGR(CSRA_STATUS, dataR);
             acc++;
        acc = 0;
        } while (((dataR>>16)<wnum)&&((timeout==0)||(timeout>acc)));
        if ((dataR>>16)<wnum) return 1;
        //--------------------------------------------------------------------------
        // get results
        MEM_READ_F(CSRA_DATAOUT0,(unsigned int*)textOut,4,wnum); // 128-bit num items
    }
    return 0;
}
int aes128_cyper_old( unsigned int anum // num of 128-bit word
                , uint8_t *textOut  // dst: should be 16-byte length at least
                , uint8_t *textIn   // src: should be 16-byte length at least
                , unsigned int timeout )
{
#if defined(RIGOR)
    if (textIn==NULL) return 1;
    if (textOut==NULL) return 1;
    if (anum==0) return 1;
#endif
    uint32_t dataR;
    unsigned int acc;
    unsigned int wnum = anum*4; // num of 4-byte words
    //--------------------------------------------------------------------------
    // check for rooms
    acc = 0;
    do { REGR(CSRA_STATUS, dataR);
         acc++;
    } while (((dataR&0xFFFF)<wnum)&&((timeout==0)||(timeout>acc)));
    if ((dataR&0xFFFF)<wnum) return 1;
    //--------------------------------------------------------------------------
    MEM_WRITE_F(CSRA_DATAIN0,(unsigned int*)textIn,4,wnum); // 128-bit num items
    //--------------------------------------------------------------------------
    // check for items
    do { REGR(CSRA_STATUS, dataR);
         acc++;
    acc = 0;
    } while (((dataR>>16)<wnum)&&((timeout==0)||(timeout>acc)));
    if ((dataR>>16)<wnum) return 1;
    //--------------------------------------------------------------------------
    // get results
    MEM_READ_F(CSRA_DATAOUT0,(unsigned int*)textOut,4,wnum); // 128-bit num items
    return 0;
}

//------------------------------------------------------------------------------
// burst>0 , burst<=256
// when 0, it retursn current value.
unsigned int aes128_burst_set( unsigned int burst )
{
    if (burst==0) return burst_leng;
#if 1
    burst_leng = (burst>256) ? 256 : burst;
#else
    burst_leng = burst; // It may not work if burs is larger than 256
                        // due to FIFO between CSR and AES128_CORE
                        // Even it causes deadlock.
#endif
    return burst_leng;
}

//------------------------------------------------------------------------------
#define CSR_RD(A,D,S)\
    REGR((A), (D));\
    printf("%10s A=0x%08X D=0x%08X\n", (S), (A), (D))
//------------------------------------------------------------------------------
int aes128_csr_check(void)
{
    unsigned int dataR;
    CSR_RD(CSRA_CONTROL , dataR, "CONTROL ");
    CSR_RD(CSRA_STATUS  , dataR, "STATUS  ");
    CSR_RD(CSRA_KEY0    , dataR, "KEY0    ");
    CSR_RD(CSRA_KEY1    , dataR, "KEY1    ");
    CSR_RD(CSRA_KEY2    , dataR, "KEY2    ");
    CSR_RD(CSRA_KEY3    , dataR, "KEY3    ");
  //CSR_RD(CSRA_DATAIN0 , dataR, "DATAIN0 "); // write-only
  //CSR_RD(CSRA_DATAIN1 , dataR, "DATAIN1 "); // write-only
  //CSR_RD(CSRA_DATAIN2 , dataR, "DATAIN2 "); // write-only
  //CSR_RD(CSRA_DATAIN3 , dataR, "DATAIN3 "); // write-only
  //CSR_RD(CSRA_DATAOUT0, dataR, "DATAOUT0"); // read-only (caluse side-effect)
  //CSR_RD(CSRA_DATAOUT1, dataR, "DATAOUT1"); // read-only (caluse side-effect)
  //CSR_RD(CSRA_DATAOUT2, dataR, "DATAOUT2"); // read-only (caluse side-effect)
  //CSR_RD(CSRA_DATAOUT3, dataR, "DATAOUT3"); // read-only (caluse side-effect)
    return 0;
}

//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.12: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
