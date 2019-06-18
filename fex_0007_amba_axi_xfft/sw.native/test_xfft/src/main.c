//------------------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// VERSION = 2019.04.05.
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
#ifdef _MSC_VER
#pragma comment(lib, "legacy_stdio_definitions.lib")
#if (_MSC_VER >= 1900 )
//extern "C" {
FILE _iob[3];
FILE * __cdecl __iob_func(void) {
   _iob[0] = *stdin;
   _iob[1] = *stdout;
   _iob[2] = *stderr;
   return _iob;
}
//}
#endif
#endif

extern void sig_handle(int);
extern int  arg_parser(int, char **);
extern void test_bench(void);
extern void cleanup(void);
extern int  verbose;
unsigned int card_id=0;
con_Handle_t handle=NULL;

int main(int argc, char *argv[]) {

  if ((signal(SIGINT, sig_handle)==SIG_ERR)
       #if !defined(WIN32)&&!defined(_MSC_VER)
	  ||(signal(SIGQUIT, sig_handle)==SIG_ERR)
       #endif
	  ) {
        fprintf(stderr, "Error: signal error\n");
        exit(1);
  }

  if (arg_parser(argc, argv)) return 1;

  if ((handle=conInit(card_id, CON_MODE_CMD, CONAPI_LOG_LEVEL_INFO))==NULL) {
       printf("cannot initialize CON-FMC\n");
       return 0;
  }

if (verbose>1) {
    //--------------------------------------------------------------------------
    // Get USB related information
    struct _usb usb;
    conGetUsbInfo( handle, &usb);
    printf("USB information\n");
    printf("    DevSpeed         =%d%cbps\n", (usb.speed>10000) ? usb.speed/10000
                                                                : usb.speed/10
                                            , (usb.speed>10000) ? 'G' : 'M');
    printf("    BulkMaxPktSizeOut=%d\n", usb.bulk_max_pkt_size_out);
    printf("    BulkMaxPktSizeIn =%d\n", usb.bulk_max_pkt_size_in );
    printf("    IsoMaxPktSizeOut =%d\n", usb.iso_max_pkt_size_out );
    printf("    IsoMaxPktSizeIn  =%d\n", usb.iso_max_pkt_size_in  );
    fflush(stdout);
}

if (verbose>1) {
    //--------------------------------------------------------------------------
    // Get GPIF2MST information
    con_MasterInfo_t gpif2mst_info;
    if (conGetMasterInfo(handle, &gpif2mst_info)) {
        printf("cannot get gpif2mst info\n");
        return 0;
    }
    printf("gpif2mst information\n");
    printf("         version 0x%08X\n", gpif2mst_info.version);
    printf("         pclk_freq %d-Mhz (%s)\n", gpif2mst_info.clk_mhz
                                               , (gpif2mst_info.clk_inv)
                                               ? "inverted"
                                               : "not-inverted");
    printf("         DepthCu2f=%d, DepthDu2f=%d, DepthDf2u=%d\n"
                                 , gpif2mst_info.depth_cmd
                                 , gpif2mst_info.depth_u2f
                                 , gpif2mst_info.depth_f2u);
    fflush(stdout);
}

    //--------------------------------------------------------------------------
  test_bench();

  if (handle!=NULL) conRelease(handle);

  cleanup();
  return(0);
}
//------------------------------------------------------------------------------
// Revision history
//
// 2019.04.05: Started by Ando Ki.
//------------------------------------------------------------------------------
