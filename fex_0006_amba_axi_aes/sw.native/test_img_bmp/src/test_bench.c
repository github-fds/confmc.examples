//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2018.06.12.
//------------------------------------------------------------------------------
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include "bmp_handle.h"
#include "rijndael.h"
#include "aes128_api.h"
#include "bfm_api.h"

extern con_Handle_t handle;
//------------------------------------------------------------------------------
unsigned int     burst_leng=256;
unsigned int     hw_sw=0; // 2'b00=sw 2'b11=hw
unsigned int     check=0; // 1=compare
char    bmp_file[128]; // image file name
char    key_hex[]="14151617191A1B1C1E1F202123242526";
uint8_t key_bin[16]; // 128-bit key
uint8_t ekey[4 * 4 * 15] = {0}; /* round key: expended key */

char    bmp_org[128]="bmp_org.bmp";
char    bmp_enc[128]="bmp_enc.bmp";
char    bmp_dec[128]="bmp_dec.bmp";

//------------------------------------------------------------------------------
// len: num of bytes
// hex: pointer to string containing hex-decimal
//      "00010203050607080A0B0C0D0F101112"
// bin: pointer to buffer to store value
static void hex_to_bin( int      len
                      , uint8_t *bin  // dst
                      , char    *hex )// src
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
static struct timeval ts, te, td;
#if !defined(timersub)
#define	timersub(tvp, uvp, vvp)						\
	do {								\
		(vvp)->tv_sec = (tvp)->tv_sec - (uvp)->tv_sec;		\
		(vvp)->tv_usec = (tvp)->tv_usec - (uvp)->tv_usec;	\
		if ((vvp)->tv_usec < 0) {				\
			(vvp)->tv_sec--;				\
			(vvp)->tv_usec += 1000000;			\
		}							\
	} while (0)
#endif

//------------------------------------------------------------------------------
void test_bench()
{
   //---------------------------------------------------------------------------
   image_info_t imgOrg; memset(&imgOrg, 0, sizeof(imgOrg));
   if (bmp_init(&imgOrg)) { return; }
   if (bmp_read( bmp_file, &imgOrg, 0)) { return; }
   //---------------------------------------------------------------------------
   int rows  = imgOrg.ImageHeight; // num of lines per image
   int cols  = imgOrg.ImageWidth; // num of pixels per line
   int bytes = imgOrg.ImageSize;
   if (bytes%16) printf("image data size is not a multiple of 128-bit\n");
   //---------------------------------------------------------------------------
   // cloning image
   image_info_t imgEnc; memset(&imgEnc, 0, sizeof(imgEnc));
   if (bmp_read( bmp_file, &imgEnc, 0)) { return; }
   //---------------------------------------------------------------------------
   unsigned char *pixelOrg = (unsigned char *)imgOrg.pBitMap;
   unsigned char *pixelEnc = (unsigned char *)imgEnc.pBitMap;
   //---------------------------------------------------------------------------
   hex_to_bin(16, key_bin, key_hex);
   if (hw_sw&0x1) {
       aes128_key_set(key_bin, AES128_ENCRYPTION, 1, 0);
       aes128_burst_set(burst_leng);
   } else {
       aes_key_expansion( AES_CYPHER_128
                        , key_bin
                        , ekey);
   }
   //---------------------------------------------------------------------------
   gettimeofday(&ts, NULL);
   if (hw_sw&0x1) {
       aes128_cyper( bytes/16
                   , (uint8_t *)pixelEnc
                   , (uint8_t *)pixelOrg
                   , 0 );
     //if (check) {
     //    image_info_t imgEncChk; memset(&imgEncChk, 0, sizeof(imgEncChk));
     //    if (bmp_read( bmp_file, &imgEncChk, 0)) { return; }
     //    unsigned char *pixelEncChk = (unsigned char *)imgEncChk.pBitMap;
     //    aes_key_expansion( AES_CYPHER_128
     //                     , key_bin
     //                     , ekey);
     //    aes_encrypt( AES_CYPHER_128
     //               , (uint8_t *)pixelEncChk
     //               , (uint8_t *)pixelOrg
     //               , bytes
     //               , ekey);
     //    int err=0;
     //    for (int i=0; i<imgEncChk.ImageSize; i++) {
     //         if (pixelEnc[i]!=pixelEncChk[i]) {
     //             err++;
     //         }
     //    }
     //    if (err>0) printf("error %d\n", err);
     //    else       printf("OK %d\n", imgEncChk.ImageSize);
     //}
   } else {
       aes_encrypt( AES_CYPHER_128
                  , (uint8_t *)pixelEnc
                  , (uint8_t *)pixelOrg
                  , bytes
                  , ekey);
   }
   gettimeofday(&te, NULL);
   timersub(&te, &ts, &td);
   double elapse = (double)(td.tv_sec)+(double)(td.tv_usec)/1000000.0;
   double speed  = (double)bytes/elapse;
   printf("Encryption (%s): %.3f secs [%.3f-%sbyte/sec of %d:%dx%d]\n",
           (hw_sw&0x1) ? "HW" : "SW",
           elapse,
           (speed>1000.0) ? speed/1000.0 : speed, (speed>1000.0) ? "K" : "",
           bytes, cols, rows);
   //---------------------------------------------------------------------------
   image_info_t imgDec; memset(&imgDec, 0, sizeof(imgDec));
   if (bmp_read( bmp_file, &imgDec, 0)) { return; }
   memset(imgDec.pBitMap, 0, imgDec.ImageSize);
   //---------------------------------------------------------------------------
   unsigned char *pixelDec = (unsigned char *)imgDec.pBitMap;
   //---------------------------------------------------------------------------
   if (hw_sw&0x2) {
       aes128_key_set(key_bin, AES128_DECRYPTION, 1, 0);
       aes128_burst_set(burst_leng);
   } else {
       // it is not required if it has been done before.
       aes_key_expansion( AES_CYPHER_128
                        , key_bin
                        , ekey);
   }
   //---------------------------------------------------------------------------
   gettimeofday(&ts, NULL);
   if (hw_sw&0x2) {
       aes128_cyper( bytes/16
                   , (uint8_t *)pixelDec
                   , (uint8_t *)pixelEnc
                   , 0 );
   } else {
       aes_decrypt( AES_CYPHER_128
                  , (uint8_t *)pixelDec
                  , (uint8_t *)pixelEnc
                  , bytes
                  , ekey);
   }
   gettimeofday(&te, NULL);
   timersub(&te, &ts, &td);
   elapse = (double)(td.tv_sec)+(double)(td.tv_usec)/1000000.0;
   speed  = (double)bytes/elapse;
   printf("Decryption (%s): %.3f secs [%.3f-%sbyte/sec of %d:%dx%d]\n",
           (hw_sw&0x2) ? "HW" : "SW",
           elapse,
           (speed>1000.0) ? speed/1000.0 : speed, (speed>1000.0) ? "K" : "",
           bytes, cols, rows);
   //---------------------------------------------------------------------------
   if (check) {
       int ret = memcmp(pixelDec, pixelOrg, bytes);
       if (ret) {
           printf("Fail on decryption after enctyption: %d\n", ret);
#if 1
           int idx;
           for (idx=0; idx<bytes; idx++) {
                if (pixelDec[idx]!=pixelOrg[idx]) {
                    printf("%04d 0x%02X:0x%02X\n", idx, pixelDec[idx], pixelOrg[idx]);
                }
           }
#endif
       } else {
           printf("Success on decryption after enctyption\n");
       }
   }
   //---------------------------------------------------------------------------
   bmp_write(bmp_org, &imgOrg, 0);
   bmp_write(bmp_enc, &imgEnc, 0);
   bmp_write(bmp_dec, &imgDec, 0);
   //---------------------------------------------------------------------------
   bmp_wrapup(&imgOrg);
   bmp_wrapup(&imgEnc);
   bmp_wrapup(&imgDec);
}

//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
