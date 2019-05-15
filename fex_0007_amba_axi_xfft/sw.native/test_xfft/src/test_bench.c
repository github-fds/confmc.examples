//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2018.04.27.
//------------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "conapi.h"
#include "axi_mem2stream_api.h"
#include "axi_stream2mem_api.h"
#include "xfft_config_api.h"
#include "mem_api.h"
#include "fft.h"
#include "memory_map.h"

//------------------------------------------------------------------------------
int       dir=1; // 1=forward, 0=backward (not used this version)
long long sampling_freq=4000000000;
int       num_of_samples=256; // num of samples
int       signal_num=0;
long long signal_freq[16]     ={100000000};
double    signal_amplitude[16]={1.0  };
int       signal_phase[16]    ={0    }; // degree
char      file_name_signal_float[256]="data_float.txt";
char      file_name_signal_fixed[256]="data_fixed.txt";
char      file_name_fft_fixed   [256]="fft_fixed.txt";
char      file_name_fft_float   [256]="fft_float.txt";
double   *signalFloatR=NULL;
double   *signalFloatI=NULL;
int16_t  *signalFixedR=NULL; // 16-bit
int16_t  *signalFixedI=NULL; // 16-bit
int32_t  *fftR=NULL;
int32_t  *fftI=NULL;

unsigned int *signal_data=NULL; // two samples in a pack
unsigned int *signal_tmp=NULL;
unsigned int *signal_fft=NULL; // 32-bit imag, 32-bit real

//------------------------------------------------------------------------------
void test_bench( void )
{
   //printf("test_bench()\n"); fflush(stdout);

   //---------------------------------------------------------------------------
#if 0
   axi_mem2stream_csr();
   axi_stream2mem_csr();
#endif

   //---------------------------------------------------------------------------
   // set mem2stream and stream2mem enabled
   axi_mem2stream_enable(1, 0);
   axi_stream2mem_enable(1, 0);

   //---------------------------------------------------------------------------
   // set XFFT
   xfft_config_reset();
   xfft_config(0x01, 0);

   //---------------------------------------------------------------------------
   // prepare buffer
   // Note that input signal will be {16-bit imag,16-bit real}
   //           output signal will be {32-bit imag,32-bit real}
   signalFloatR = (double*)malloc(num_of_samples*sizeof(double));
   signalFloatI = (double*)malloc(num_of_samples*sizeof(double));
   signalFixedR = (int16_t*)malloc(num_of_samples*sizeof(int16_t));
   signalFixedI = (int16_t*)malloc(num_of_samples*sizeof(int16_t));
   if (signalFloatR==NULL || signalFloatI==NULL || signalFixedR==NULL || signalFixedI==NULL) {
       printf("malloc error\n"); return;
   }

   //---------------------------------------------------------------------------
   // prepare signal data
   gen_data(num_of_samples, file_name_signal_float, signalFloatR, signalFloatI,
                            file_name_signal_fixed, signalFixedR, signalFixedI,
                            2, 14);
   signal_data = (uint32_t*)malloc(num_of_samples*sizeof(uint32_t)); // {16-bit imag, 16-bit real}
   signal_tmp  = (uint32_t*)malloc(num_of_samples*sizeof(uint32_t)); // {16-bit imag, 16-bit real}
   if (signal_data==NULL || signal_tmp==NULL) {
       printf("malloc error\n"); return;
   }
   for (int idx=0; idx<num_of_samples; idx++) {
        signal_data[idx] = (uint32_t)(signalFixedR[idx]&0xFFFF); // zero for all imaginary
   }
   //---------------------------------------------------------------------------
   // write data to the memory and then check its contents
   write_burst(ADDR_MEM_M2S_START, signal_data, 4, num_of_samples);
   read_burst (ADDR_MEM_M2S_START, signal_tmp, 4, num_of_samples);
   int err=0;
   for (int idx=0; idx<num_of_samples; idx++) {
        if ((signalFixedR[idx])!=(int16_t)(signal_tmp[idx]&0x0000FFFF)) {
            err++;
            printf("%d-real: 0x%02X:0x%02X\n", idx, signalFixedR[idx], (int16_t)(signal_tmp[idx]&0xFFFF));
        }
        if ((signalFixedI[idx])!=(int16_t)(signal_tmp[idx]>>16)) {
            err++;
            printf("%d-imag: 0x%02X:0x%02X\n", idx, signalFixedI[idx], (int16_t)(signal_tmp[idx]>>16));
        }
   }
   if (err>0) printf("signal data mis-match %d/%d\n", err, num_of_samples);

   //---------------------------------------------------------------------------
   axi_stream2mem_set(ADDR_MEM_S2M_START,
                      num_of_samples*4*2, // frame: each samples 32-bit imag, 32-bit real
                      num_of_samples*4*2, // packet: each samples 32-bit imag, 32-bit real
                      4*16, // chunk
                      1, // cnum
                      0, // cont
                      1, // go
                      1); // time out
   axi_mem2stream_set(ADDR_MEM_M2S_START,
                      num_of_samples*2*2, // frame: each samples 16-bit imag, 16-bit real
                      num_of_samples*2*2, // packet: each samples 16-bit imag, 16-bit real
                      4*16, // chunk
                      1, // cnum
                      0, // cont
                      1, // go
                      0); // time out

   //---------------------------------------------------------------------------
   // prepare buffer
   // Note that input signal will be {16-bit imag,16-bit real}
   //           output signal will be {32-bit imag,32-bit real}
   fftR = (uint32_t*)malloc(num_of_samples*sizeof(uint32_t));
   fftI = (uint32_t*)malloc(num_of_samples*sizeof(uint32_t));
   signal_fft = (uint32_t*)malloc(num_of_samples*2*sizeof(uint32_t));
   if (fftR==NULL || fftI==NULL || signal_fft==NULL) {
       printf("malloc error\n"); return;
   }
   //---------------------------------------------------------------------------
   // get data
   read_burst(ADDR_MEM_S2M_START, signal_fft, 4, num_of_samples*2);
   for (int idx=0; idx<num_of_samples; idx++) {
        fftR[idx] = signal_fft[idx*2];
        fftI[idx] = signal_fft[idx*2+1];
   }
   //---------------------------------------------------------------------------
   // put data into file
   put_data_fixed(num_of_samples, file_name_fft_fixed, 32, fftR, fftI);
   put_data_float(num_of_samples, file_name_fft_float, 18, 14, fftR, fftI);
}

//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
