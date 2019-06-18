#ifndef AXI_MEM2STREAM_API_H
#define AXI_MEM2STREAM_API_H
//--------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------------------
// axi_mem2stream_api.h
//--------------------------------------------------------------------
// VERSION = 2019.04.05.
//--------------------------------------------------------------------
#include <stdint.h>

#if defined(_MSC_VER)
   #define AXI_MEM2STREAM_API
#else
   #if (defined(_WIN32)||defined(_WIN64))
      #ifdef BUILDING_DLL
         #define AXI_MEM2STREAM_API __declspec(dllexport)
      #else
         #ifdef BUILDING_STATIC
             #define AXI_MEM2STREAM_API
         #else
             #define AXI_MEM2STREAM_API __declspec(dllimport)
         #endif
      #endif
   #else
      #define AXI_MEM2STREAM_API
   #endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

AXI_MEM2STREAM_API int axi_mem2stream_set( uint32_t start
                             , uint32_t frame
                             , uint16_t packet
                             , uint8_t  chunk
                             , uint32_t cnum
                             , int cont
                             , int go
                             , int time_out);
AXI_MEM2STREAM_API int axi_mem2stream_get( uint32_t *start
                             , uint32_t *frame
                             , uint16_t *packet
                             , uint8_t  *chunk
                             , int *cont);
AXI_MEM2STREAM_API int axi_mem2stream_enable( int en, int ie );
AXI_MEM2STREAM_API int axi_mem2stream_clear( void );
AXI_MEM2STREAM_API int axi_mem2stream_csr( void );

#ifdef __cplusplus
}
#endif
//--------------------------------------------------------
// Revision History
//
// 2019.04.05: Start by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
#endif
