//------------------------------------------------------------------------------
// Copyright (c) 2018 by Future Design Systems Co., Ltd.
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2018.04.27.
//------------------------------------------------------------------------------
#include <stdio.h>
#include "mem_api.h"
#include "memory_map.h"
//------------------------------------------------------
int test_memory = 0;
unsigned int mem_start  = ADDR_MEM_M2S_START;
unsigned int mem_length = 0x100;
int level=0;

// -----------------------------------------------------
void test_bench( void )
{
   printf("test_bench()\n"); fflush(stdout);

   unsigned int n, m;
   char c;
   printf("Enter number to test (0 for infinite loop): "); fflush(stdout);
   scanf("%d", &n);

   if (n==0) m = 1;
   else      m = n;
   while (m--) {
       if (test_memory) mem_test(mem_start, mem_length, level);
       if (n==0) m = 1;
   }
}
//------------------------------------------------------------------------------
// Revision History
//
// 2018.04.27: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
