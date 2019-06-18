#ifndef AES128_API_H
#define AES128_API_H
//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems.
// All right reserved.
//------------------------------------------------------------------------------
// aes128_api.h
//------------------------------------------------------------------------------
// VERSION = 2018.06.12.
//------------------------------------------------------------------------------
#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

#define AES128_ENCRYPTION 1
#define AES128_DECRYPTION 0

extern int aes128_control( unsigned int enc_dec // 1=enc, 0=dec
                         , unsigned int go );
extern int aes128_key_set( uint8_t *key
                         , unsigned int enc_dec // 1=enc, 0=dec
                         , unsigned int go
                         , unsigned int timeout ); // 0=blocking
extern int aes128_cyper( unsigned int anum // num of 128-bit word
                       , uint8_t *textOut  // dst
                       , uint8_t *textIn   // src
                       , unsigned int timeout ); // 0=blocking
extern unsigned int aes128_burst_set( unsigned int burst );
extern int aes128_csr_check( void );

#ifdef __cplusplus
}
#endif
//------------------------------------------------------------------------------
// Revision History
//
// 2018.06.12: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
#endif
