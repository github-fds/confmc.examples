#ifndef XFFT_CONFIG_API_H
#define XFFT_CONFIG_API_H
//--------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems Co., Ltd.
// All right reserved.
//
// http://www.future-ds.com
//--------------------------------------------------------
// VERSION = 2019.04.05.
//--------------------------------------------------------
#if defined(_MSC_VER)
   #define XFFT_CONFIG_API
#else
   #if (defined(_WIN32)||defined(_WIN64))
      #ifdef BUILDING_DLL
         #define XFFT_CONFIG_API __declspec(dllexport)
      #else
         #ifdef BUILDING_STATIC
             #define XFFT_CONFIG_API
         #else
             #define XFFT_CONFIG_API __declspec(dllimport)
         #endif
      #endif
   #else
      #define XFFT_CONFIG_API
   #endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

XFFT_CONFIG_API int  xfft_config_reset( void );
XFFT_CONFIG_API int  xfft_config( unsigned int config
                                , int time_out);

#ifdef __cplusplus
}
#endif
//--------------------------------------------------------
// Revision History
//
// 2019.04.10: started by Ando Ki (adki@future-ds.com)
//--------------------------------------------------------
#endif
