//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2018.04.27.
//------------------------------------------------------------------------------
#define _USE_MATH_DEFINES
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

extern long long sampling_freq;
extern int       num_of_samples; // num of samples
extern int       signal_num;
extern long long signal_freq[];
extern double    signal_amplitude[];
extern int       signal_phase[];
extern char      file_name_signal[];
extern char      file_name_fft   [];

//------------------------------------------------------------------------------
static unsigned int bit_reverse(unsigned int numbits, unsigned int index)
{
   unsigned int result = 0;
   for (unsigned int i=0; i<numbits; i++) {
       result = (result<<1)|(index&0x1);
       index >>= 1;
   }
   return result;
}

//------------------------------------------------------------------------------
void bit_reverse_swap(int num, double dataR[], double dataI[])
{
   int numbits = (int)(log(num)/log(2));
   for (unsigned int n=0; n<(unsigned int)num; n++) {
        unsigned int result = bit_reverse(numbits, n);
        if (n<result) {
            double tmp = dataR[n];
            dataR[n] = dataR[result];
            dataR[result] = tmp;
            tmp = dataI[n];
            dataI[n] = dataI[result];
            dataI[result] = tmp;
       }
   }
}

//------------------------------------------------------------------------------
void gen_data(int     num_of_samples     // number of samples
             ,char    file_name_float[] // file name to write data
             ,double  floatR[]     // buffer for "real" part
             ,double  floatI[]     // buffer for "imaginary" part
             ,char    file_name_fixed[]    // file name to write data
             ,int16_t fixedR[] // buffer for "real" part (16-bit)
             ,int16_t fixedI[] // buffer for "imaginary" part (16-bit)
             ,int     bitInt   // bit-width of integer part for fixed-point
             ,int     bitFrac) // bit-width of fractional part for fixed-point
{
  double t;
  double a;
  double r;
  double v;

  double s=0.0;
  for (int k=0; k<signal_num; k++) s = s + signal_amplitude[k];
  t = 0.0;
  for (int i=0; i<num_of_samples; i++) {
    floatI[i] = 0.0;
    v = 0.0;
    for (int j=0; j<signal_num; j++) {
         a = 2 * M_PI * signal_freq[j];
         r = a*t+signal_phase[j];
         v = v + signal_amplitude[j] * (double)sin((double)r);
    }
    floatR[i] = v/s; // normalize
    t = t + 1.0/sampling_freq;
  }
  if (file_name_float!=NULL && file_name_float[0]!='\0') {
      FILE *fp;
      fp = fopen(file_name_float, "wb");
      if (fp==NULL) {
          printf("Cannot open %s\n", file_name_float);
          exit(1);
      }
      fprintf(fp, "# sample_freq=%lld sample_num=%d bit_width=%d data_type=%s data_format=%s\n",
                   sampling_freq, num_of_samples, bitInt+bitFrac, "real", "complex");
      for (int idx=0; idx<num_of_samples; idx++) {
#ifdef XXYY00XX
           if ((idx%4)!=0) fprintf(fp, " ");
           if (floatI[idx]<0) fprintf(fp, "%f%fj", floatR[idx], floatI[idx]);
           else               fprintf(fp, "%f+%fj", floatR[idx], floatI[idx]);
           if ((idx%4)==3) fprintf(fp, "\n");
#else
           if (floatI[idx]<0) fprintf(fp, "%f%fj\n", floatR[idx], floatI[idx]);
           else               fprintf(fp, "%f+%fj\n", floatR[idx], floatI[idx]);
#endif
      }
      fclose(fp);
  }
  double tt;
  for (int i=0; i<num_of_samples; i++) {
       tt = floatR[i]*(1<<bitFrac);
       fixedR[i] = (int16_t)tt;
       tt = floatI[i]*(1<<bitFrac);
       fixedI[i] = (int16_t)tt;
  }
  if (file_name_fixed!=NULL && file_name_fixed[0]!='\0') {
      FILE *fp;
      fp = fopen(file_name_fixed, "wb");
      if (fp==NULL) {
          printf("Cannot open %s\n", file_name_fixed);
          exit(1);
      }
      fprintf(fp, "# sample_freq=%lld sample_num=%d bit_width=%d data_type=%s data_format=%s\n",
                   sampling_freq, num_of_samples, bitInt+bitFrac, "hex", "complex");
      for (int idx=0; idx<num_of_samples; idx++) {
           fprintf(fp, "0x%04x+0x%04xj\n", (uint16_t)fixedR[idx], (uint16_t)fixedI[idx]);
      }
      fclose(fp);
  }
}

#if defined(_MSC_VER)||defined(_WIN32)||defined(_WIN64)
#include "getline.h"
#endif
//------------------------------------------------------------------------------
void get_data(int num, char file_name[], double dataR[], double dataI[])
{
  FILE *fp;
  fp = fopen(file_name, "rb");
  if (fp==NULL) {
      printf("Cannot open %s\n", file_name);
      exit(1);
  }
  char *line=NULL;
  size_t len=0;
  size_t nread;
  if ((nread = getline(&line, &len, fp))==-1) {
       // skip one line
       printf("cannot read line from %s\n", file_name);
       if (line!=NULL) free(line);
       line = NULL;
  } else {
    int idx=0;
    while (!feof(fp)) {
       fscanf(fp, "%lf+%lfj", &dataR[idx], &dataI[idx]);
       idx++;
    }
  }
  if (line!=NULL) free(line);
  fclose(fp);
}

//------------------------------------------------------------------------------
void put_data_fixed(int num_of_samples,  // num of samples
                    char file_name[],
                    int bit_width,
                    unsigned int dataR[], 
                    unsigned int dataI[])
{
  FILE *fp;
  fp = fopen(file_name, "wb");
  if (fp==NULL) {
      printf("Cannot open %s\n", file_name);
      exit(1);
  }
  fprintf(fp, "# sample_freq=%lld sample_num=%d bit_width=%d data_type=%s data_format=%s\n",
               sampling_freq, num_of_samples, bit_width, "hex", "complex");
  for (int idx=0; idx<num_of_samples; idx++) {
#ifdef XXYY00XX
       if ((idx%4)!=0) fprintf(fp, " ");
       fprintf(fp, "0x%X+0x%Xj", dataR[idx], dataI[idx]);
       if ((idx%4)==3) fprintf(fp, "\n");
#else
       fprintf(fp, "0x%X+0x%Xj\n", dataR[idx], dataI[idx]);
#endif
  }
  
  fclose(fp);
}

//------------------------------------------------------------------------------
void put_data_float(int num_of_samples,  // num of samples
                    char file_name[],
                    int bit_int,
                    int bit_frac,
                    unsigned int dataR[], 
                    unsigned int dataI[])
{
  FILE *fp;
  fp = fopen(file_name, "wb");
  if (fp==NULL) {
      printf("Cannot open %s\n", file_name);
      exit(1);
  }
  fprintf(fp, "# sample_freq=%lld sample_num=%d bit_width=%d data_type=%s data_format=%s\n",
               sampling_freq, num_of_samples, bit_int+bit_frac, "real", "complex");
  signed int iiR, iiI;
  double ttR, ttI;
  for (int idx=0; idx<num_of_samples; idx++) {
       iiR = (signed int)dataR[idx];
       iiI = (signed int)dataI[idx];
       ttR = (double)(iiR)/(double)(1<<bit_frac);
       ttI = (double)(iiI)/(double)(1<<bit_frac);
#ifdef XXYY00XX
       if ((idx%4)!=0) fprintf(fp, " ");
       if (ttI<0) fprintf(fp, "%f%fj", ttR, ttI);
       else       fprintf(fp, "%f+%fj", ttR, ttI);
       if ((idx%4)==3) fprintf(fp, "\n");
#else
       if (ttI<0) fprintf(fp, "%f%fj\n", ttR, ttI);
       else       fprintf(fp, "%f+%fj\n", ttR, ttI);
#endif
  }
  
  fclose(fp);
}

//------------------------------------------------------------------------------
void makeW(int num, int dir, // dir=1 (forward), 0 (backward)
           double _wR[], double _wI[])
{
   double theta;
   if (dir) theta =  2.0*M_PI/(double)num; // forward
   else     theta = -2.0*M_PI/(double)num; // inverse
   _wR[0] = 1.0;
   _wI[0] = 0.0;
   for (int i=1; i<num/2; i++) {
      double epsilon = theta*(double)i;
      _wR[i] =  cos(epsilon);
      _wI[i] = -sin(epsilon);
   }
   int index = num/4;
   _wR[index] = 0.0;
   if (dir) _wI[index] = -1.0; // forward
   else     _wI[index] =  1.0; // inverse
}

//------------------------------------------------------------------------------
void do_fft_dit_wtable(int num, int dir,
                       double dataR[], double dataI[],
                       double _wR[], double _wI[])
          // dir=1 (forward), 0 (backward)
{
    makeW(num, dir, _wR, _wI);
    bit_reverse_swap(num, dataR, dataI);
    for (int i = 2; i <= num; i *= 2) { /* log2(N) times loop */
       int h = i/2;
       for (int j=0; j < h; j++) {
          /* the j-th i-th root of unity */
          int windex = j*num/i;
          double wr = _wR[windex];
          double wi = _wI[windex];
          for (int k=j; k < num; k += i) {
             int m = k;
             int n = k+h;
             /* (a+ib)*(c+id) = (ac-bd)+i(ad+bc) */
             double tmpr  = wr*dataR[n] - wi*dataI[n];
             double tmpi  = wr*dataI[n] + wi*dataR[n];
             dataR[n] = (dataR[m] - tmpr);
             dataI[n] = (dataI[m] - tmpi);
             dataR[m] = (dataR[m] + tmpr);
             dataI[m] = (dataI[m] + tmpi);
//printf("i=%d j=%d k=%d h=%d w=%d (%d:%d)\n", i, j, k, h, windex, m, n);
          }
       }
    }
    if (dir==1) {
        for (int i=0; i<num; i++) {
             dataR[i] /= (double)num;
             dataI[i] /= (double)num;
        }
    }
}

//------------------------------------------------------------------------------
void do_fft_dit_embedded(int num, int dir, double dataR[], double dataI[])
          // dir=1 (forward), 0 (backward)
{
    bit_reverse_swap(num, dataR, dataI);
    for (int i = 2; i <= num; i *= 2) { /* log2(N) times loop */
       double theta = (dir) ? 2.0*M_PI/(double)i // forward
                            : -2.0*M_PI/(double)i;
       double wpr   = (double)cos((double)theta);
       double wpi   = (double)-sin((double)theta);
       double wr    = 1.0;
       double wi    = 0.0;
       int h = i/2;
       for (int j=0; j < h; j++) {
          /* the j-th i-th root of unity */
          for (int k=j; k < num; k += i) {
             int m = k;
             int n = m+h;
             /* (a+ib)*(c+id) = (ac-bd)+i(ad+bc) */
             double tmpr  = wr*dataR[n] - wi*dataI[n];
             double tmpi  = wr*dataI[n] + wi*dataR[n];
             dataR[n]   = dataR[m] - tmpr;
             dataI[n]   = dataI[m] - tmpi;
             dataR[m]  += tmpr;
             dataI[m]  += tmpi;
          }
          double wtmp = wr;
          wr = wtmp*wpr - wi*wpi;
          wi = wtmp*wpi + wi*wpr;
       }
    }
    if (dir==1) {
        for (int i=0; i<num; i++) {
             dataR[i] /= (double)num;
             dataI[i] /= (double)num;
        }
    }
}

//------------------------------------------------------------------------------
void do_fft_dif_wtable(int num, int dir,
                      double dataR[], double dataI[],
                      double _wR[], double _wI[])
          // dir=1 (forward), 0 (backward)
{
    makeW(num, dir, _wR, _wI);
    for (int i=num; i>0; i/=2) { /* log2(N) times loop */
       int h = i/2;
       for (int j=0; j<h; j++) {
          /* the j-th i-th root of unity */
          int windex = j*num/i;
          double wr = _wR[windex];
          double wi = _wI[windex];
          for (int k=j; k<num; k+=i) {
             int m = k;
             int n = k+h;
             /* (a+ib)*(c+id) = (ac-bd)+i(ad+bc) */
             double tmR = (dataR[m] + dataR[n]);
             double tmI = (dataI[m] + dataI[n]);
             double tnR = (dataR[m] - dataR[n]);
             double tnI = (dataI[m] - dataI[n]);
             dataR[m]  = tmR;
             dataI[m]  = tmI;
             dataR[n]  = wr*tnR - wi*tnI;
             dataI[n]  = wr*tnI + wi*tnR;
          }
       }
    }
    if (dir==1) {
        for (int i=0; i<num; i++) {
             dataR[i] /= (double)num;
             dataI[i] /= (double)num;
        }
    }
    bit_reverse_swap(num, dataR, dataI);
}

//------------------------------------------------------------------------------
void do_fft_dif_embedded(int num, int dir, double dataR[], double dataI[])
          // dir=1 (forward), 0 (backward)
{
    for (int i=num; i>0; i/=2) { /* log2(N) times loop */
       double theta = (dir) ? 2.0*M_PI/(double)i // forward
                            : -2.0*M_PI/(double)i;
       double wpr   = (double)cos((double)theta);
       double wpi   = (double)-sin((double)theta);
       double wr    = 1.0;
       double wi    = 0.0;
       int h = i/2;
       for (int j=0; j<h; j++) {
          /* the j-th i-th root of unity */
          for (int k=j; k<num; k+=i) {
             int m = k;
             int n = k+h;
             /* (a+ib)*(c+id) = (ac-bd)+i(ad+bc) */
             double tmR = (dataR[m] + dataR[n]);
             double tmI = (dataI[m] + dataI[n]);
             double tnR = (dataR[m] - dataR[n]);
             double tnI = (dataI[m] - dataI[n]);
             dataR[m]  = tmR;
             dataI[m]  = tmI;
             dataR[n]  = wr*tnR - wi*tnI;
             dataI[n]  = wr*tnI + wi*tnR;
          }
          double wtmp = wr;
          wr = wtmp*wpr - wi*wpi;
          wi = wtmp*wpi + wi*wpr;
       }
    }
    for (int i=0; i<num; i++) {
         dataR[i] /= (double)num;
         dataI[i] /= (double)num;
    }
    if (dir==1) {
        for (int i=0; i<num; i++) {
             dataR[i] /= (double)num;
             dataI[i] /= (double)num;
        }
    }
    bit_reverse_swap(num, dataR, dataI);
}
//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
