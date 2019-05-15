#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This file contains Python version of XFFT_CONFIG with CON-FMC AMBA BFM.
"""
__author__     = "Ando Ki"
__copyright__  = "Copyright 2019, Future Design Systems"
__credits__    = ["none", "some"]
__license__    = "FUTURE DESIGN SYSTEMS SOFTWARE END-USER LICENSE AGREEMENT FOR CON-FMC."
__version__    = "1"
__revision__   = "0"
__maintainer__ = "Ando Ki"
__email__      = "contact@future-ds.com"
__status__     = "Development"
__date__       = "2019.04.15"
__description__= "AXI_STREAM2MEM with CON-FMC AMBA BFM"

#-------------------------------------------------------------------------------
class axi_stream2mem:
      # bit position
      S2M_ctl_en    =31
      S2M_ctl_ip    =1
      S2M_ctl_ie    =0
      
      S2M_num_go    =31
      S2M_num_busy  =30
      S2M_num_done  =29
      S2M_num_cont  =28
      S2M_num_chunk =16
      S2M_num_bnum  =0

      # bit mask
      S2M_ctl_en_MSK    =(1<<S2M_ctl_en)
      S2M_ctl_ip_MSK    =(1<<S2M_ctl_ip)
      S2M_ctl_ie_MSK    =(1<<S2M_ctl_ie)
      
      S2M_num_go_MSK    =(1<<S2M_num_go   )
      S2M_num_busy_MSK  =(1<<S2M_num_busy )
      S2M_num_done_MSK  =(1<<S2M_num_done )
      S2M_num_cont_MSK  =(1<<S2M_num_cont )
      S2M_num_chunk_MSK =(0xFF<<S2M_num_chunk)
      S2M_num_bnum_MSK  =(0xFFFF<<S2M_num_bnum )

      def __init__(self, hdl, bfm, addr=0x00020000):
          """hdl: con_Handle_t
             bfm: BFM modeule
             addr: starting address"""
          self._hdl   = hdl
          self._bfm   = bfm
          self._VERSION =addr+0x00
          self._CONTROL =addr+0x10
          self._START0  =addr+0x20
          self._START1  =addr+0x24
          self._END0    =addr+0x28
          self._END1    =addr+0x2C
          self._NUM     =addr+0x30
          self._CNT     =addr+0x40

      def csr( self ):
          value = [0]
          self._bfm.BfmRead(self._hdl, self._VERSION, value); print "_VERSION: ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._CONTROL, value); print "_CONTROL: ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._START0 , value); print "_START0 : ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._START1 , value); print "_START1 : ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._END0   , value); print "_END0   : ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._END1   , value); print "_END1   : ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._NUM    , value); print "_NUM    : ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._CNT    , value); print "_CNT    : ", hex(value[0])

      def enable( self, en, ie ):
          value = [0]
          if (en!=0): value[0] |= self.S2M_ctl_en_MSK
          if (ie!=0): value[0] |= self.S2M_ctl_ie_MSK
          return self._bfm.BfmWrite(self._hdl, self._CONTROL, value)

      def set( self
             , start
             , frame
             , packet
             , chunk
             , cnum
             , cont
             , go
             , time_out):
          """start   : starting address of a frame
             frame   : num of bytes of a frame
             packet  : num of bytes of a packet (TVALID & TLAST)
             chunk   : num of bytes of burst
             num     : num of iterations for continuous mode
             cont    : 0=single mode, 1=continuous mode
             go      : let go when 1
             time_out: 0=blocking"""
          value = [0]
          value[0] = start
          self._bfm.BfmWrite(self._hdl, self._START0, value)
          value[0] = start + frame # end
          self._bfm.BfmWrite(self._hdl, self._END0  , value  )
          value[0] = cnum
          self._bfm.BfmWrite(self._hdl, self._CNT   , value )
          value[0] = 0
          if (go  !=0): value[0] |= self.S2M_num_go_MSK
          if (cont!=0): value[0] |= self.S2M_num_cont_MSK
          value[0] |= (chunk<<self.S2M_num_chunk)&self.S2M_num_chunk_MSK
          value[0] |= (packet<<self.S2M_num_bnum)&self.S2M_num_bnum_MSK
          self._bfm.BfmWrite(self._hdl, self._NUM, value);
          if (cnum==0): return 0
          num=0;
          while True:
               self._bfm.BfmRead(self._hdl, self._NUM, value);
               if (value[0]&self.S2M_num_go_MSK)==0: break
               num += 1
               if (time_out!=0) and (num>=time_out): break
          if (time_out!=0) and (num>=time_out): return -1;
          return 0;

#===============================================================================
# Revision history:
#
# 2019.04.15: Started by Ando Ki (adki@future-ds.com)
#             - Not finished yet
#===============================================================================
