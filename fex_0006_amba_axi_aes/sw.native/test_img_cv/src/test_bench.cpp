//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2018.06.12.
//------------------------------------------------------------------------------
#include <cstdio>  // printf
#include <iostream>  // std:cout
#include <opencv2/core/core.hpp> // cv:Mat
#include <opencv2/highgui/highgui.hpp>   // cv:imread()
#include <sys/time.h>
#include "rijndael.h"
#include "aes128_api.h"

using namespace std;
using namespace cv;

//------------------------------------------------------------------------------
unsigned int     burst_leng=256;
unsigned int     hw_sw=0; // 2'b00=sw 2'b11=hw
unsigned int     check=0; // 1=compare
unsigned int     nodisplay=0; // 1=not display images
char    image_file[128]; // image file name
char    key_hex[]="14151617191A1B1C1E1F202123242526";
uint8_t key_bin[16]; // 128-bit key
uint8_t ekey[4 * 4 * 15] = {0}; /* round key: expended key */

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
   Mat imgOrg;
   imgOrg = imread( image_file, CV_LOAD_IMAGE_COLOR );
   if ( !imgOrg.data ) {
       printf("No image data: %s\n", image_file);
       return;
   }
   //---------------------------------------------------------------------------
   int rows  = imgOrg.rows; // num of lines per image
   int cols  = imgOrg.cols; // num of pixels per line
   int step  = imgOrg.step;
   int chan  = imgOrg.channels();
   int size  = rows*step; // num of bytes per image
   int bytes = imgOrg.total() * imgOrg.elemSize();
   if (size!=bytes) printf("image data size mis-match %d %d\n", size, bytes);
   if (bytes%16) printf("image data size is not a multiple of 128-bit\n");
   //---------------------------------------------------------------------------
   if (!nodisplay) {
       cvNamedWindow("Display Image Org", CV_WINDOW_AUTOSIZE );
       cvMoveWindow("Display Image Org", 50, 50);
       imshow("Display Image Org", imgOrg);
     //imwrite("result.png", imgOrg);
       printf("Enter on the image to encrypt: "); fflush(stdout); //getchar();
       cvWaitKey(0);
   }
   //---------------------------------------------------------------------------
   Mat imgEnc = imgOrg.clone();
   //---------------------------------------------------------------------------
   unsigned char *pixelOrg = (unsigned char *)imgOrg.data;
   unsigned char *pixelEnc = (unsigned char *)imgEnc.data;
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
   if (!nodisplay) {
       cvNamedWindow("Display Image Enc", CV_WINDOW_AUTOSIZE );
       cvMoveWindow("Display Image Enc", 50+cols, 50);
       imshow("Display Image Enc", imgEnc);
       printf("Enter on the image to decrypt: "); fflush(stdout); //getchar();
       cvWaitKey(0);
   }
   //---------------------------------------------------------------------------
   Mat imgDec = imgEnc.clone();
   //---------------------------------------------------------------------------
   unsigned char *pixelDec = (unsigned char *)imgDec.data;
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
   if (!nodisplay) {
       cvNamedWindow("Display Image Dec", CV_WINDOW_AUTOSIZE );
       cvMoveWindow("Display Image Dec", 50+cols, 50+rows);
       imshow("Display Image Dec", imgDec);
   }
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
   if (!nodisplay) {
       printf("Enter on the image to quit: "); fflush(stdout); //getchar();
       cvWaitKey(0);
   }
   //---------------------------------------------------------------------------
   if (!nodisplay) {
       cvDestroyWindow("Display Image Org");
       cvDestroyWindow("Display Image Enc");
       cvDestroyWindow("Display Image Dec");
   }
   imgOrg.release();
   imgEnc.release();
   imgDec.release();
   //---------------------------------------------------------------------------
}

//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
