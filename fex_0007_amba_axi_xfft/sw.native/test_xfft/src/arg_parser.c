//------------------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2019.04.05.
//------------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <ctype.h>
#include <assert.h>
#include <sys/types.h>
#include <fcntl.h>
#if defined(_MSC_VER)
#include "my_getopt.h"
#else
#include <getopt.h>
#endif
#ifdef WIN32
#	include <windows.h>
#	include <io.h>
#endif
#include "conapi.h"

const char version[] = "V0.0";
const char date[]    = "2019-04-05";
int verbose = 0;

extern int  help(int, char **);
extern unsigned int card_id;

extern int       dir;
extern long long sampling_freq;
extern int       num_of_samples; // num of samples
extern int       signal_num;
extern long long signal_freq[];
extern double    signal_amplitude[];
extern int       signal_phase[];
extern char      file_name_signal_float[];
extern char      file_name_signal_fixed[];
extern char      file_name_fft_fixed[];
extern char      file_name_fft_float[];

//------------------------------------------------------------------------------
int arg_parser(int argc, char **argv)
{
   int   opt;
   opterr = 0; // in order to use '?'
   optind = 1; // make re-enterant
   extern int help(int argc, char *argv[]);

   static struct option long_options[] = {
          {"direction"      , required_argument, 0, 'A'},
          {"sampling_freq"  , required_argument, 0, 'B'},
          {"num_of_samples" , required_argument, 0, 'C'},
          {"signal_spec"    , required_argument, 0, 'D'},
          {"data_file_float", required_argument, 0, 'E'},
          {"data_file_fixed", required_argument, 0, 'F'},
          {"fft_file_float" , required_argument, 0, 'G'},
          {"fft_file_fixed" , required_argument, 0, 'H'},

          {"cid"            , required_argument, 0, 'c'},
          {"verbose"        , required_argument, 0, 'v'},
          {"help"           , no_argument      , 0, 'h'},
          {0                , 0                , 0,  0 }
   };

   int long_index = 0;
   while ((opt=getopt_long(argc, argv, "hc:v:A:B:C:D:E:F:G:H:",
                           long_options, &long_index))!=-1) {
        switch (opt) {
        case 'h': help(argc, argv); return -1;
        case 'c': card_id = (unsigned int)strtoul(optarg, NULL, 0); break;
        case 'v': verbose = (int)strtoul(optarg, NULL, 0); break;
        case '?': if (optopt=='c') {
                      printf("%c requires an argument.\n", optopt);
                  } else if (isprint(optopt)) {
                      printf("%c unknown\n", optopt);
                  } else {
                      printf("0x%x unknown character\n", optopt);
                  }
                  break;
        case 'A': if (!strcmp(optarg,"forward")) dir=1;
                  else if (!strcmp(optarg,"inverse")) dir=0;
                  else printf("%s unknown value for option %s\n", optarg, "direction");
                  break;
        case 'B': sampling_freq=(long long)strtoul(optarg, NULL, 0); break;
        case 'C': num_of_samples=(unsigned int )strtoul(optarg, NULL, 0); break;
        case 'D': { char *token = strtok(optarg,":");
                    while (token!=NULL) {
                           signal_freq[signal_num]      = (long long)strtoul(token, NULL, 0);
                           token = strtok(NULL,":");
                           signal_amplitude[signal_num] = atof(token);
                           token = strtok(NULL,":");
                           signal_phase[signal_num]     = (int)strtoul(token, NULL, 0);
                           token = strtok(NULL,":");
                           signal_num++;
                    }
                  }
                  break;
        case 'E': strcpy(file_name_signal_float, optarg); break;
        case 'F': strcpy(file_name_signal_fixed, optarg); break;
        case 'G': strcpy(file_name_fft_float, optarg); break;
        case 'H': strcpy(file_name_fft_fixed, optarg); break;

        default: printf("unknown option %c\n", opt);
        }
   }
   if (signal_num==0) signal_num=1;
   return 0;
}

//------------------------------------------------------------------------------
int help(int argc, char **argv)
{
    printf("[Usage] %s [options]\n", argv[0]);
    printf("   -A,--direction      forward|inverse    FFT forward\n");
    printf("   -B,--sampling_freq  numHz       Sampling frequency (default: %lldHz (%.2lfMHz))\n",
                                               sampling_freq, (double)sampling_freq/1000000.0);
    printf("   -C,--num_of_samples num         Number of samples (default: %ums)\n", num_of_samples);
    printf("   -D,--signal_spec  \"f:a:p\"       Signal spec freq:amplitude:phase\n");
    printf("                                   . freq in integer\n");
    printf("                                   . amplitude in floating-point (peak amplitude, i.e., 1/2 of peak-to-peak)\n");
    printf("                                   . phase offset in degree\n");
    printf("   -E,--data_file_float file_name  Filename for signal data in float\n");
    printf("   -F,--data_file_fixed file_name  Filename for signal result in fixed\n");
    printf("   -G,--fft_file_float  file_name  Filename for fft result in float\n");
    printf("   -H,--fft_file_fixed  file_name  Filename for fft result in fixed\n");
    printf("\n");
    printf("   -c,--cid  num                   Card ID (%d)\n", card_id);
    printf("   -v,--verbose level              Verbose level (%d)\n", verbose);
    printf("   -h,--help                       Print help\n");
    printf("\n");
    return 0;
}

void sig_handle(int sig) {
  extern void cleanup();
  switch (sig) {
  case SIGINT:
  #if !defined(WIN32)&&!defined(_MSC_VER)
  case SIGQUIT:
  #endif
       cleanup();
       exit(0);
       break;
  }
}

void cleanup(void) {
  fflush(stdout); fflush(stderr);
}

//------------------------------------------------------------------------------
// Revision History
//
// 2019.04.05: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
