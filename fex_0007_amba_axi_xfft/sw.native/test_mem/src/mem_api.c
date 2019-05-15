//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems
// All right reserved.
// http://www.future-ds.com
//------------------------------------------------------------------------------
// mem_api.c
//------------------------------------------------------------------------------
// VERSION = 2018.04.27.
//------------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <assert.h>
#include <sys/types.h>
#ifdef WIN32
#	include <windows.h>
#endif
#include "trx_axi_api.h"
#include "mem_api.h"

#ifdef TRX_BFM
# include "conapi.h"
extern con_Handle_t handle;
#      define MEM_WRITE(A, B)        BfmWrite(handle, (unsigned int)(A), (unsigned int*)&(B), 4, 1)
#      define MEM_READ(A, B)         BfmRead (handle, (unsigned int)(A), (unsigned int*)&(B), 4, 1)
#      define MEM_WRITE_G(A,D,S,L)   BfmWrite(handle, (A), (D), (S), (L))
#      define MEM_READ_G(A,D,S,L)    BfmRead (handle, (A), (D), (S), (L))
#else
#      define MEM_WRITE(A, B)        *(unsigned *)A = B;
#      define MEM_READ(A, B)         B = *(unsigned *)A;
#endif

typedef unsigned int Uint;
static Uint my_rand(void);
static void my_srand(unsigned int seed);
static void rotating_cursor(int t);

void
mem_test(Uint saddr, Uint depth, int level) {
    Uint diff;
    Uint b;
    extern int MemTestRAW(Uint saddr, Uint depth, Uint size);
    extern int MemTestBurstRAW(Uint saddr, Uint depth, Uint leng);

    printf("Info: memory test from 0x%08X to 0x%08X\n", saddr, saddr+depth);
    fflush(stdout);

    if (level>=0) {
       MemTestAddRAW(saddr, depth);
    }
    if (level>0) {
       diff = MemTestRAW(saddr, depth, 4); // word test
       diff = MemTestRAW(saddr, depth, 2); // short test
       diff = MemTestRAW(saddr, depth, 1); // byte test
    }
    if (level>1) {
       b = 1;
       diff = MemTestBurstRAW(saddr, depth, b); // burst test
       b = 2;
       diff = MemTestBurstRAW(saddr, depth, b); // burst test
    }
    if (level>2) {
       for (b=4; b<=16; b+=4) {
           diff = MemTestBurstRAW(saddr, depth, b); // burst test
       }
    }
    if (level>3) {
       for (b=32; b<=256; b*=2) {
           diff = MemTestBurstRAW(saddr, depth, b); // burst test
       }
    }
    if (level>4) {
       for (b=256; b<=1024; b*=2) {
           diff = MemTestBurstRAW(saddr, depth, b); // burst test
       }
    }
    if (level>5) {
       for (b=1024; b<=2048; b*=2) {
           diff = MemTestBurstRAW(saddr, depth, b); // burst test
       }
    }
    if (level>6) {
       for (b=2048; b<=4096; b*=2) {
           diff = MemTestBurstRAW(saddr, depth, b); // burst test
       }
    }
}

int
MemTestAddWr(Uint saddr, Uint depth) {
   Uint i;
   Uint send = saddr+depth;
   printf("\nInfo: Address write test from 0x%x 0x%x \n", saddr, send);
   fflush(stdout);
   for (i=saddr; (i+4)<send; i+=4) {
       MEM_WRITE(i, i);
       rotating_cursor(i);
   }
   return 0;
}
int
MemTestAddRr(Uint saddr, Uint depth) {
   Uint i, d, err;
   Uint send = saddr+depth;
   printf("\nInfo: Address read test from 0x%x 0x%x \n", saddr, send);
   fflush(stdout);
   err = 0;
   for (i = saddr; (i+4)<send; i+=4) {
       MEM_READ(i, d);
       if (i!=d) {
           err++;
           printf("Mismatch 0x%x, but 0x%x expected\n", d, i);
       }
       rotating_cursor(i);
   }
   if (err==0) {printf("Address read-all-after-write-all OK\n"); return(0); }
   else { printf("Address read-all-after-write-all Fail\n"); return(1);}
}

int
MemTestAddRAW(unsigned saddr, unsigned depth) {
   Uint i, d, err;
   Uint send = saddr+depth;
   printf("\nInfo: Address read-after-write test from 0x%x 0x%x \n", saddr, send);
   fflush(stdout);
   err = 0;
   for (i=saddr; (i+4)<send; i+=4) {
       MEM_WRITE(i, i);
       MEM_READ (i, d);
       if (i!=d) {
           err++;
           printf("Mismatch 0x%x, but 0x%x expected\n", d, i);
printf("Enter: "); getchar();
       }
       rotating_cursor(i);
   }
   if (err==0) {printf("Address read-after-write OK\n"); return(0);}
   else { printf("Address read-after-write Fail\n"); return(1);}
}

int
MemTestRAW(Uint saddr, Uint depth, Uint size) {
   Uint i, wd, rd, ex, mask, err;
   Uint send;

   printf("Info: %d-byte  Test from 0x%08X 0x%08X ", size, saddr, saddr+depth);
   fflush(stdout);
   switch (size) {
     case 1:  mask = 0x000000ff; break;
     case 2:  mask = 0x0000ffff; break;
     case 4:
     default: mask = 0xffffffff; break;
   }
unsigned int value=0;
   my_srand(7);
   send = saddr+depth;
   for (i = saddr; (i+size)<send; i+=size) {
       wd = ++value&mask;//wd = my_rand()&mask;
       MEM_WRITE_G(i, &wd, size, 1);
       rotating_cursor(i);
   }
value=0;
   err = 0;
   my_srand(7);
   for (i = saddr; (i+size)<send; i+=size) {
       ex = ++value&mask; //ex = my_rand()&mask;
       MEM_READ_G(i, &rd, size, 1);
       rd = rd&mask;
       if (ex!=rd) {
           err++;
//           printf("mis-match at 0x%x, 0x%x read, but 0x%x expected\n",
//                   i, rd, ex);
       }
       rotating_cursor(i);
   }
   if (!err) printf(" OK\n");
   else      printf(" %d mis-match\n", err);
   fflush(stdout);
   return(err);
}

int
MemTestBurstRAW(Uint saddr, Uint depth, Uint leng) {
   Uint i, j, ex, err, size;
   Uint send;
   Uint *data;
   Uint wleng, rleng;

   printf("Info: Burst %d Test from 0x%x 0x%x ",
                       leng, saddr, saddr+depth);
   if ((saddr+depth)<(leng*4)) {
       printf("memory is smaller than required\n");
   }
   fflush(stdout);
   if ((saddr+depth)%leng) {
	   send = ((saddr+depth)/leng)*leng;
   } else {
           send = saddr+depth;
   }

   data = NULL;
   if ((data = (Uint*)malloc(leng*4))==NULL) {
      printf("cannot alloca memory\n");
   }
   size = 4;
  //------------------------------------------------
unsigned int value=0;
   wleng = leng;
   for (i = saddr; (i+wleng*4)<send; i+=(wleng*4)) {
      for (j = 0; j<wleng; j++) {
          data[j] = ++value; //i+j+1; //my_rand();
      }
      MEM_WRITE_G(i, data, size, wleng);
      rotating_cursor(i);
   }
  //------------------------------------------------
value=0;
   err = 0;
   my_srand(7);
   rleng = leng;
   //printf("read %d-------------------------------\n", rleng);
   for (i=saddr; (i+rleng*4)<send; i+=(rleng*4)) {
       MEM_READ_G(i, data, size, rleng);
       for (j = 0; j<rleng; j++) {
           ex = ++value; //i+j+1; //my_rand();
           if (data[j] != ex) {
              err++;
if (err<5) {
              printf("mis-match at 0x%x, 0x%x read, but 0x%x expected\n",
                   i+j*4, data[j], ex);
}
	   }
//else {
//printf("    match at 0x%x, 0x%x read\n", i+j*4, data[j]);
//}
       }
       rotating_cursor(i);
   }

   if (!err) printf(" OK\n");
   else     {printf(" %d mis-match\n", err);
              exit(0);
   }
   if (data!=NULL) free(data);
   fflush(stdout);
   return(err);
}

static void rotating_cursor(int t) {
   static char cnext = '|';
   static int next  = 0;
   if ((t%0xFF)==0) {
          putchar(cnext); fflush(stdout);
          switch (next) {
          case 0: cnext = '/';  next = 1; break;
          case 1: cnext = '-';  next = 2; break;
          case 2: cnext = 0x5C; next = 3; break;
          case 3: cnext = '|';  next = 0; break;
          }
          putchar('');
   }
   //putchar(''); fflush(stdout);
}

#define MY_RAND_MAX 0xFFFFFFFF
static unsigned long _Randseed = 1;

static Uint my_rand(void)
{
  _Randseed = _Randseed * 1103515245 + 12345;
  return((unsigned int)_Randseed);
}

static void my_srand(unsigned int seed)
{
  _Randseed = seed;
}
//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
