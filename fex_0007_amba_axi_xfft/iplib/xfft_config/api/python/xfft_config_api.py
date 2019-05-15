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
__description__= "XFFT_CONFIG with CON-FMC AMBA BFM"

#-------------------------------------------------------------------------------
class xfft_config:
      def __init__(self, hdl, bfm, addr=0x00000000):
          self._hdl   = hdl
          self._bfm   = bfm
          self._VERSION=(addr+0x00)
          self._RESET  =(addr+0x10)
          self._CONFIG =(addr+0x14)
          self._STATUS =(addr+0x18)

      def csr( self ):
          value = [0]
          self._bfm.BfmRead(self._hdl, self._VERSION, value); print "_VERSION: ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._RESET  , value); print "_RESET  : ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._CONFIG , value); print "_CONFIG : ", hex(value[0])
          self._bfm.BfmRead(self._hdl, self._STATUS , value); print "_STATUS : ", hex(value[0])

      def reset( self ):
          """writing 1 to bit 0  causes XFFT_ARESETn 0.
             writing 0 to bit 0  causes XFFT_ARESETn 1."""
          self._bfm.BfmWrite(self._hdl, self._RESET,[0x1])
          self._bfm.BfmWrite(self._hdl, self._RESET,[0x0])
          return 0

      def config( self, config, time_out ):
          """status[3] = done
             status[2] = tvalid
             status[1] = tready
             status[0] = resetn"""
          value = [config]
          self._bfm.BfmWrite(self._hdl, self._CONFIG, value)
          num=0
          value = [0]
          while True:
                self._bfm.BfmRead(self._hdl, self._STATUS, value);
                if ((value[0]&0x9)==0x9): break # done & ~reset
                num += 1
                if ((time_out!=0) and (num>=time_out)): break
          if (time_out!=0) and (num>=time_out): return -1;
          return 0;

#===============================================================================
# Revision history:
#
# 2019.04.15: Started by Ando Ki (adki@future-ds.com)
#             - Not finished yet
#===============================================================================
