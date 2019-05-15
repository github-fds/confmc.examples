//------------------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2019.04.05.
//------------------------------------------------------------------------------
#include "conapi.h"
#include "xfft_config_api.h"
#include "memory_map.h"
extern con_Handle_t handle;

//------------------------------------------------------------------------------
// Register access macros
#if defined(TRX_BFM)||defined(TRX_AXI)||defined(TRX_AHB)
#include <stdio.h>
#include "bfm_api.h"
#   define REGRD(A,B)         BfmRead(handle, (unsigned int)(A), (unsigned int*)&(B), 4, 1);
#   define REGWR(A,B)         BfmWrite(handle, (unsigned int)(A), (unsigned int*)&(B), 4, 1);
#	define   uart_put_string(x)  printf("%s", (x));
#	define   uart_put_hex(n)  printf("%x", (n));
#else
#include "uart_api.h"
#       define REGWR(A, B)   *(unsigned *)A = B;
#       define REGRD(A, B)    B = *(unsigned *)A;
#endif

//------------------------------------------------------------------------------
#ifndef ADDR_XFFT_CONFIG_START
#error  ADDR_XFFT_CONFIG_START should be defined
#endif

#define XFFT_CONFIG_VERSION (ADDR_XFFT_CONFIG_START+0x00)
#define XFFT_CONFIG_RESET   (ADDR_XFFT_CONFIG_START+0x10)
#define XFFT_CONFIG_CONFIG  (ADDR_XFFT_CONFIG_START+0x14)
#define XFFT_CONFIG_STATUS  (ADDR_XFFT_CONFIG_START+0x18)

//------------------------------------------------------------------------------
// writing 1 to bit 0  causes XFFT_ARESETn 0.
// writing 0 to bit 0  causes XFFT_ARESETn 1.
int xfft_config_reset(void)
{
     volatile uint32_t value = 1;
     REGWR(XFFT_CONFIG_RESET,value);
     value = 0;
     REGWR(XFFT_CONFIG_RESET,value);
     return 0;
}

//------------------------------------------------------------------------------
// status[3] = done
// status[2] = tvalid
// status[1] = tready
// status[0] = resetn
int xfft_config( unsigned int config, int time_out )
{
     volatile uint32_t value;
     REGWR(XFFT_CONFIG_CONFIG, config);
     int num=0;
     do { REGRD(XFFT_CONFIG_STATUS,value);
          if ((value&0x9)==0x9) break; // done & ~reset
          num++;
     } while ((time_out==0)||(num<time_out));
     if ((time_out!=0)&&(num>=time_out)) return -1;
     return 0;
}

//--------------------------------------------------------
#undef REGWR
#undef REGRD

//------------------------------------------------------------------------------
// Revision History
//
// 2019.04.05: started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
