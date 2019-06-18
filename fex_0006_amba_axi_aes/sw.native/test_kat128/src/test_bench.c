//------------------------------------------------------------------------------
// Copyright (c) 2011 by Future Design Systems Co., Ltd.
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2011.11.22.
//------------------------------------------------------------------------------
#include <stdio.h>
#include <memory.h>
#include "aes128_api.h"
#include "kat128.h"

//------------------------------------------------------------------------------
int entry_num=1;
unsigned char plain [16]; // 128-bit
unsigned char cyper [16];
unsigned char result[16];
unsigned char key   [16];

//------------------------------------------------------------------------------
// len: num of bytes
// hex: pointer to string containing hex-decimal
//      "00010203050607080A0B0C0D0F101112"
// bin: pointer to buffer to store value
void hex_to_bin(int len, char *hex, unsigned char *bin)
{
     int idx, idy;
     char chH, chL;
     unsigned char val;

     for (idx=0; idx<(len*2); idx+=2) {
          chH = hex[idx];
          chL = hex[idx+1];
          val = ((chH>='0')&&(chH<='9')) ? (chH-'0')<<4
              : ((chH>='a')&&(chH<='f')) ? (chH-'a'+10)<<4
              : ((chH>='A')&&(chH<='F')) ? (chH-'A'+10)<<4
              : 0;
          val += ((chL>='0')&&(chL<='9')) ? (chL-'0')
               : ((chL>='a')&&(chL<='f')) ? (chL-'a'+10)
               : ((chL>='A')&&(chL<='F')) ? (chL-'A'+10)
               : 0;
          bin[idx/2] = val;
     }
}

//------------------------------------------------------------------------------
void test_bench()
{
   int idx, idy;
   //---------------------------------------------------------------------------
   for (idx=0; idx<16; idx++) {
        plain [idx] = 0;
        cyper [idx] = 0;
        result[idx] = 0;
        key   [idx] = 0;
   }
   if (entry_num>128) entry_num = 128;
   //---------------------------------------------------------------------------
   for (idx=0; idx<entry_num; idx++) {
        hex_to_bin(16, kat128.entry[idx].key, key);
        aes128_key_set(key, AES128_ENCRYPTION, 1, 0);
        hex_to_bin(16, kat128.entry[idx].plain, plain);
        hex_to_bin(16, kat128.entry[idx].cyper, cyper);
        aes128_cyper(1, result, plain, 0); // 128-bit units
        int error = 0;
        for (idy=0; idy<16; idy++) {
             if (cyper[idy]!=result[idy]) error++;
        }
        if (error>0) printf("KAT128-%d Encryption %d error out of 16 bytes\n", idx, error);
        else         printf("KAT128-%d Encryption OK\n", idx);
   }
   //---------------------------------------------------------------------------
   for (idx=0; idx<entry_num; idx++) {
        hex_to_bin(16, kat128.entry[idx].key, key);
        aes128_key_set(key, AES128_DECRYPTION, 1, 0);
        hex_to_bin(16, kat128.entry[idx].plain, plain);
        hex_to_bin(16, kat128.entry[idx].cyper, cyper);
        aes128_cyper(1, result, cyper, 0);
        int error = 0;
        for (idy=0; idy<16; idy++) {
             if (plain[idy]!=result[idy]) error++;
        }
        if (error>0) printf("KAT128-%d Decryption %d error out of 16 bytes\n", idx, error);
        else         printf("KAT128-%d Decryption OK\n", idx);
   }
}

//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
