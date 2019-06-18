//------------------------------------------------------------------------------
// Copyright (c) 2011 by Future Design Systems Co., Ltd.
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2011.11.22.
//------------------------------------------------------------------------------
#include <stdio.h>
#include "aes128_api.h"

//------------------------------------------------------------------------------
#define MAX_T    1024
#define MAX_BNUM 16*128
unsigned char plain [MAX_T][MAX_BNUM];
unsigned char cyper [MAX_T][MAX_BNUM];
unsigned char result[MAX_T][MAX_BNUM];
unsigned char key[16];
int tnum=10;

//------------------------------------------------------------------------------
void test_bench()
{
   if (tnum>=MAX_T) tnum = MAX_T;
   //---------------------------------------------------------------------------
   aes128_csr_check();
   //---------------------------------------------------------------------------
   int idx, idy, anum;
   //---------------------------------------------------------------------------
   for (idx=0; idx<MAX_T; idx++) {
   for (idy=0; idy<MAX_BNUM; idy++) {
        plain [idx][idy] = idx+idy+1;
        cyper [idx][idy] = 0;
        result[idx][idy] = 0;
   }
   }
   //---------------------------------------------------------------------------
   // fill key: note that "128'h1122_3344_5566_7788_99AA_BBCC_DDEE_FF00"
   //                      key[ 0] = 0x11 ==> key[127:120]
   //                      key[ 1] = 0x22 ==> key[119:112]
   //                      ... ...
   //                      key[14] = 0xFF ==> key[ 15:  8]
   //                      key[15] = 0x00 ==> key[  7:  0]
   // This is done by AES128 HW: converting little-endian to big-endian
   //                            for 4-byte word.
   for (idx=0; idx<16; idx++) {
        key[idx] = idx+1;
   }
   //---------------------------------------------------------------------------
   // Encryption test
   aes128_key_set(key, AES128_ENCRYPTION, 1, 0);
   for (idx=0; idx<tnum; idx++) {
        anum = ((idx+1)+15)/16; // 128-bit (16-byte) units
        aes128_cyper(anum, cyper[idx], plain[idx], 0);
   }
   //---------------------------------------------------------------------------
   // Decryption test
   aes128_key_set(key, AES128_DECRYPTION, 1, 0);
   for (idx=0; idx<tnum; idx++) {
        anum = ((idx+1)+15)/16; // 128-bit (16-byte) units
        aes128_cyper(anum, result[idx], cyper[idx], 0);
   }
   //---------------------------------------------------------------------------
   int werror=0;
   for (idx=0; idx<tnum; idx++) {
        int error=0;
        for (idy=0; idy<(idx+1); idy++) {
            if (plain[idx][idy]!=result[idx][idy]) error++;
        }
        if (error>0) werror++;
   }
   if (werror>0) printf("mis-matched %d out of %d\n", werror, tnum);
   else          printf("matched %d\n", tnum);
}

//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
