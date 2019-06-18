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

extern void sig_handle(int);
extern int  arg_parser(int, char **);
extern void test_bench(void);
extern void cleanup(void);
extern unsigned nodisplay;
unsigned int card_id=0;
con_Handle_t handle=NULL;

int main(int argc, char *argv[]) {

  if ((signal(SIGINT, sig_handle)==SIG_ERR)
       #ifndef WIN32
	  ||(signal(SIGQUIT, sig_handle)==SIG_ERR)
       #endif
	  ) {
        fprintf(stderr, "Error: signal error\n");
        exit(1);
  }

  arg_parser(argc, argv);

  if ((handle=conInit(card_id, CON_MODE_CMD, CONAPI_LOG_LEVEL_INFO))==NULL) {
       printf("cannot initialize CON-FMC\n");
       return 0;
  }

  //----------------------------------------------------------------------------
  if (!nodisplay) {
    // Get USB related information
#if 0
    struct libusb_device_handle *dev_handle;
    int DevSpeed;
    int BulkMaxPktSizeOut, BulkMaxPktSizeIn;
    int IsoMaxPktSizeOut, IsoMaxPktSizeIn;
    dev_handle = handle->usb.handle;
    conGetUsbInfo( dev_handle, &DevSpeed, &BulkMaxPktSizeOut, &BulkMaxPktSizeIn
                             , &IsoMaxPktSizeOut, &IsoMaxPktSizeIn);
    printf("USB infomation\n");
    printf("    DevSpeed         =%d%cbps\n", (DevSpeed>10000) ? DevSpeed/10000
                                                               : DevSpeed/10
                                            , (DevSpeed>10000) ? 'G' : 'M');
    printf("    BulkMaxPktSizeOut=%d\n", BulkMaxPktSizeOut);
    printf("    BulkMaxPktSizeIn =%d\n", BulkMaxPktSizeIn );
    printf("    IsoMaxPktSizeOut =%d\n", IsoMaxPktSizeOut );
    printf("    IsoMaxPktSizeIn  =%d\n", IsoMaxPktSizeIn  );
#else
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
#endif

    //--------------------------------------------------------------------------
    // Get GPIF2MST information
    con_MasterInfo_t gpif2mst_info;
    if (conGetMasterInfo(handle, &gpif2mst_info)) {
         printf("%d %s\n", conGetErrorConapi()
                         , conErrorMsgConapi(conGetErrorConapi()));
         return 0;
    }
    printf("gpif2mst infomation\n");
    printf("         version 0x%08X\n", gpif2mst_info.version);
    printf("         pclk_freq %d-Mhz (%s)\n", gpif2mst_info.clk_mhz
                                             , (gpif2mst_info.clk_inv)
                                             ? "inverted"
                                             : "not-inverted");
    printf("         DepthCu2f=%d, DepthDu2f=%d, DepthDf2u=%d\n"
                                 , gpif2mst_info.depth_cmd
                                 , gpif2mst_info.depth_u2f
                                 , gpif2mst_info.depth_f2u);

  }
  //----------------------------------------------------------------------------
  test_bench();

  if (handle!=NULL) conRelease(handle);

  cleanup();
  return(0);
}
//------------------------------------------------------------------------------
// Revision history
//
// 2018.04.27: Started by Ando Ki.
//------------------------------------------------------------------------------
