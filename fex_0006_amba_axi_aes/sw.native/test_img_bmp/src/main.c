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
#include <string.h>
#include <signal.h>
#include <assert.h>
#include <sys/types.h>
#ifdef WIN32
#	include <windows.h>
#endif
#include "conapi.h"

extern int  arg_parser(int, char **);
extern void test_bench(void);

unsigned int card_id=0;
con_Handle_t handle=NULL;

int main(int argc, char *argv[]) {

  arg_parser(argc, argv);

  if ((handle=conInit(card_id, CON_MODE_CMD, CONAPI_LOG_LEVEL_INFO))==NULL) {
       printf("cannot initialize CON-FMC\n");
       return 0;
  }

  //----------------------------------------------------------------------------
  test_bench();

  if (handle!=NULL) conRelease(handle);

  return(0);
}
//------------------------------------------------------------------------------
// Revision history
//
// 2018.04.27: Started by Ando Ki.
//------------------------------------------------------------------------------
