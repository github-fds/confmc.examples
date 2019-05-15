//--------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------------------
// axi_mem2stream_api.c
//--------------------------------------------------------------------
// VERSION = 2019.04.05.
//--------------------------------------------------------------------
//#ifndef COMPACT_CODE
//#endif
//--------------------------------------------------------------------
#ifdef TRX_BFM
#	include <stdio.h>
#	include "bfm_api.h"
#	define   uart_put_string(x)  printf("%s", (x));
#	define   uart_put_hexn(n,m)  printf("%x", (n));
#else
#   if defined(RIGOR)
#	   include <small_libc.h>
#   endif
#	include "uart_api.h"
#endif
#include "axi_mem2stream_api.h"
#include "memory_map.h"

//--------------------------------------------------------------------
extern con_Handle_t handle;

//--------------------------------------------------------------------
// Register access macros
#ifdef TRX_BFM
#   define REGRD(A,B)         BfmRead(handle, (unsigned int)(A), (unsigned int*)&(B), 4, 1);
#   define REGWR(A,B)         BfmWrite(handle, (unsigned int)(A), (unsigned int*)&(B), 4, 1);
#   define MEM_WRITE_N(A,B,N) BfmWrite(handle, (unsigned int)(A), (unsigned int*)(B), 4, (N))
#   define MEM_READ_N(A,B,N)  BfmRead (handle, (unsigned int)(A), (unsigned int*)(B), 4, (N))
#else
#	define REGRD(add,val)      (val) = *((volatile uint32_t *)(add))
#	define REGWR(add,val)     *((volatile uint32_t *)(add)) = (val)
#   define MEM_WRITE_N(A,B,N)   memcpy((A), (B), (N)*4)
#   define MEM_READ_N(A,B,N)    memcpy((B), (A), (N)*4)
#endif

//--------------------------------------------------------------------
#ifndef ADDR_AXI_MEM2STREAM_START
#error  ADDR_AXI_MEM2STREAM_START should be defined
#endif

#define CSRA_M2S_VERSION (ADDR_AXI_MEM2STREAM_START+0x00)
#define CSRA_M2S_CONTROL (ADDR_AXI_MEM2STREAM_START+0x10)
#define CSRA_M2S_START0  (ADDR_AXI_MEM2STREAM_START+0x20)
#define CSRA_M2S_START1  (ADDR_AXI_MEM2STREAM_START+0x24)
#define CSRA_M2S_END0    (ADDR_AXI_MEM2STREAM_START+0x28)
#define CSRA_M2S_END1    (ADDR_AXI_MEM2STREAM_START+0x2C)
#define CSRA_M2S_NUM     (ADDR_AXI_MEM2STREAM_START+0x30)
#define CSRA_M2S_CNT     (ADDR_AXI_MEM2STREAM_START+0x40)

//--------------------------------------------------------------------
// bit position
#define M2S_ctl_en     31
#define M2S_ctl_ip     1
#define M2S_ctl_ie     0

#define M2S_num_go     31
#define M2S_num_busy   30
#define M2S_num_done   29
#define M2S_num_cont   28
#define M2S_num_chunk  16
#define M2S_num_bnum   0

//--------------------------------------------------------------------
// bit mask
#define M2S_ctl_en_MSK     (1<<M2S_ctl_en)
#define M2S_ctl_ip_MSK     (1<<M2S_ctl_ip)
#define M2S_ctl_ie_MSK     (1<<M2S_ctl_ie)

#define M2S_num_go_MSK     (1<<M2S_num_go   )
#define M2S_num_busy_MSK   (1<<M2S_num_busy )
#define M2S_num_done_MSK   (1<<M2S_num_done )
#define M2S_num_cont_MSK   (1<<M2S_num_cont )
#define M2S_num_chunk_MSK  (0xFF<<M2S_num_chunk)
#define M2S_num_bnum_MSK   (0xFFFF<<M2S_num_bnum )

//--------------------------------------------------------------------
//  start   : starting address of a frame
//  frame   : num of bytes of a frame
//  packet  : num of bytes of a packet (TVALID & TLAST)
//  chunk   : num of bytes of burst
//  num     : num of iterations for continuous mode
//  cont    : 0=single mode, 1=continuous mode
//  go      : let go when 1
//  time_out: 0=blocking
//
// "cnu=0 && cont=1 && time_out=1" ==> return and do conti
int axi_mem2stream_set( uint32_t start
                      , uint32_t frame
                      , uint16_t packet
                      , uint8_t  chunk
                      , uint32_t cnum
                      , int cont
                      , int go
                      , int time_out)
{
    volatile uint32_t end, value;
    end = start + frame;
    REGWR(CSRA_M2S_START0, start);
    REGWR(CSRA_M2S_END0  , end  );
    REGWR(CSRA_M2S_CNT   , cnum );
    value = 0;
    if (go  ) value |= M2S_num_go_MSK;
    if (cont) value |= M2S_num_cont_MSK;
    value |= (chunk<<M2S_num_chunk)&M2S_num_chunk_MSK;
    value |= (packet<<M2S_num_bnum)&M2S_num_bnum_MSK;
    REGWR(CSRA_M2S_NUM, value);
    if (cnum==0) return 0;
    int num=0;
    do { REGRD(CSRA_M2S_NUM, value);
         if (!(value&M2S_num_go_MSK)) break; 
         num++;
    } while ((time_out==0)||(num<time_out));
    if ((time_out!=0)&&(num>=time_out)) return -1;
    return 0;
}

//--------------------------------------------------------------------
int axi_mem2stream_get( uint32_t *start
                      , uint32_t *frame
                      , uint16_t *packet
                      , uint8_t  *chunk
                      , int *cont)
{
    volatile uint32_t valueA, valueB;
    REGRD(CSRA_M2S_START0, valueA);
    REGRD(CSRA_M2S_END0, valueB);
    if (start!=NULL) *start = valueA;
    if (frame!=NULL) *frame = valueB-valueA;
    REGRD(CSRA_M2S_NUM, valueA);
    if (packet!=NULL) *packet = (valueA&M2S_num_bnum_MSK)>>M2S_num_bnum;
    if (chunk!=NULL) *chunk = (valueA&M2S_num_chunk_MSK)>>M2S_num_chunk;
    if (cont!=NULL) *cont = (valueA&M2S_num_cont_MSK) ? 1 : 0;
    return 0;
}

//--------------------------------------------------------------------
// read control register
int axi_mem2stream_enable( int en, int ie )
{
    volatile uint32_t value;
    value = 0;
    if (en) value |= M2S_ctl_en_MSK;
    if (ie) value |= M2S_ctl_ie_MSK;
    REGWR(CSRA_M2S_CONTROL, value);
    return 0;
}

//--------------------------------------------------------------------
// clear interrupt
int axi_mem2stream_clear( void ) // interrupt clear
{
    volatile uint32_t value;
    REGRD(CSRA_M2S_CONTROL, value);
    value  |= M2S_ctl_ip_MSK;
    REGWR(CSRA_M2S_CONTROL, value);
    return 0;
}

//--------------------------------------------------------------------
int axi_mem2stream_csr( void )
{
    volatile uint32_t value;
    REGRD(CSRA_M2S_VERSION, value); printf("M2S_VERSION: 0x%08X\n", value);
    REGRD(CSRA_M2S_CONTROL, value); printf("M2S_CONTROL: 0x%08X\n", value);
    REGRD(CSRA_M2S_START0 , value); printf("M2S_START0 : 0x%08X\n", value);
    REGRD(CSRA_M2S_START1 , value); printf("M2S_START1 : 0x%08X\n", value);
    REGRD(CSRA_M2S_END0   , value); printf("M2S_END0   : 0x%08X\n", value);
    REGRD(CSRA_M2S_END1   , value); printf("M2S_END1   : 0x%08X\n", value);
    REGRD(CSRA_M2S_NUM    , value); printf("M2S_NUM    : 0x%08X\n", value);
    REGRD(CSRA_M2S_CNT    , value); printf("M2S_CNT    : 0x%08X\n", value);
    return 0;
}

//--------------------------------------------------------------------
// Revision History
//
// 2019.04.05: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------------------
