//--------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------------------
// axi_stream2mem_api.c
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
#include "axi_stream2mem_api.h"
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
#ifndef ADDR_AXI_STREAM2MEM_START
#error  ADDR_AXI_STREAM2MEM_START should be defined
#endif

#define CSRA_S2M_VERSION (ADDR_AXI_STREAM2MEM_START+0x00)
#define CSRA_S2M_CONTROL (ADDR_AXI_STREAM2MEM_START+0x10)
#define CSRA_S2M_START0  (ADDR_AXI_STREAM2MEM_START+0x20)
#define CSRA_S2M_START1  (ADDR_AXI_STREAM2MEM_START+0x24)
#define CSRA_S2M_END0    (ADDR_AXI_STREAM2MEM_START+0x28)
#define CSRA_S2M_END1    (ADDR_AXI_STREAM2MEM_START+0x2C)
#define CSRA_S2M_NUM     (ADDR_AXI_STREAM2MEM_START+0x30)
#define CSRA_S2M_CNT     (ADDR_AXI_STREAM2MEM_START+0x40)

//--------------------------------------------------------------------
// bit position
#define S2M_ctl_en     31
#define S2M_ctl_ip     1
#define S2M_ctl_ie     0

#define S2M_num_go     31
#define S2M_num_busy   30
#define S2M_num_done   29
#define S2M_num_cont   28
#define S2M_num_chunk  16
#define S2M_num_bnum   0

//--------------------------------------------------------------------
// bit mask
#define S2M_ctl_en_MSK     (1<<S2M_ctl_en   )
#define S2M_ctl_ip_MSK     (1<<S2M_ctl_ip   )
#define S2M_ctl_ie_MSK     (1<<S2M_ctl_ie   )

#define S2M_num_go_MSK     (1<<S2M_num_go   )
#define S2M_num_busy_MSK   (1<<S2M_num_busy )
#define S2M_num_done_MSK   (1<<S2M_num_done )
#define S2M_num_cont_MSK   (1<<S2M_num_cont )
#define S2M_num_chunk_MSK  (0xFF<<S2M_num_chunk)
#define S2M_num_bnum_MSK   (0xFFFF<<S2M_num_bnum )

//--------------------------------------------------------------------
//  start   : starting address of a frame
//  frame   : num of bytes of a frame
//  packet  : num of bytes of a packet (TVALID & TLAST)
//  chunk   : num of bytes of burst
//  cnum    : num of iteration for continous mode
//  cont    : 0=single mode, 1=continuous mode
//  go      : let go when 1
//  time_out: 0=blocking
//
// "cnu=0 && cont=1 && time_out=1" ==> return and do conti
int axi_stream2mem_set( uint32_t start
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
    REGWR(CSRA_S2M_START0, start);
    REGWR(CSRA_S2M_END0  , end  );
    REGWR(CSRA_S2M_CNT   , cnum );
    value = 0;
    if (go  ) value |= S2M_num_go_MSK;
    if (cont) value |= S2M_num_cont_MSK;
    value |= (chunk<<S2M_num_chunk)&S2M_num_chunk_MSK;
    value |= (packet<<S2M_num_bnum)&S2M_num_bnum_MSK;
    REGWR(CSRA_S2M_NUM, value);
    if (cnum==0) return 0;
    int num = 0;
    do { REGRD(CSRA_S2M_NUM, value);
         if (!(value&S2M_num_go_MSK)) break; 
         num++;
    } while ((time_out==0)||(num<time_out));
    if ((time_out!=0)&&(num>=time_out)) return -1;
    return 0;
}

//--------------------------------------------------------------------
int axi_stream2mem_get( uint32_t *start
                      , uint32_t *frame
                      , uint16_t *packet
                      , uint8_t  *chunk
                      , int *cont)
{
    volatile uint32_t valueA, valueB;
    REGRD(CSRA_S2M_START0, valueA);
    REGRD(CSRA_S2M_END0, valueB);
    if (start!=NULL) *start = valueA;
    if (frame!=NULL) *frame = valueB-valueA;
    REGRD(CSRA_S2M_NUM, valueA);
    if (packet!=NULL) *packet = (valueA&S2M_num_bnum_MSK)>>S2M_num_bnum;
    if (chunk!=NULL) *chunk = (valueA&S2M_num_chunk_MSK)>>S2M_num_chunk;
    if (cont!=NULL) *cont = (valueA&S2M_num_cont_MSK) ? 1 : 0;
    return 0;
}

//--------------------------------------------------------------------
// read control register
int axi_stream2mem_enable( int en, int ie )
{
    volatile uint32_t value;
    value = 0;
    if (en) value |= S2M_ctl_en_MSK;
    if (ie) value |= S2M_ctl_ie_MSK;
    REGWR(CSRA_S2M_CONTROL, value);
    return 0;
}

//--------------------------------------------------------------------
// clear interrupt
int axi_stream2mem_clear( void ) // interrupt clear
{
    volatile uint32_t value;
    REGRD(CSRA_S2M_CONTROL, value);
    value  |= S2M_ctl_ip_MSK;
    REGWR(CSRA_S2M_CONTROL, value);
    return 0;
}

//--------------------------------------------------------------------
// clear interrupt
int axi_stream2mem_csr( void ) // interrupt clear
{
    volatile uint32_t value;
    REGRD(CSRA_S2M_VERSION, value); printf("S2M_VERSION: 0x%08X\n", value);
    REGRD(CSRA_S2M_CONTROL, value); printf("S2M_CONTROL: 0x%08X\n", value);
    REGRD(CSRA_S2M_START0 , value); printf("S2M_START0 : 0x%08X\n", value);
    REGRD(CSRA_S2M_START1 , value); printf("S2M_START1 : 0x%08X\n", value);
    REGRD(CSRA_S2M_END0   , value); printf("S2M_END0   : 0x%08X\n", value);
    REGRD(CSRA_S2M_END1   , value); printf("S2M_END1   : 0x%08X\n", value);
    REGRD(CSRA_S2M_NUM    , value); printf("S2M_NUM    : 0x%08X\n", value);
    REGRD(CSRA_S2M_CNT    , value); printf("S2M_CNT    : 0x%08X\n", value);
    return 0;
}

//--------------------------------------------------------------------
// Revision History
//
// 2019.04.05: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------------------
