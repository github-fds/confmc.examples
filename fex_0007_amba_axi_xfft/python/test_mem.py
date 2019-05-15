#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This file contains Python version of XFFT with CON-FMC AMBA AXI BFM.
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
__date__       = "2019.04.10"
__description__= "XFFT with CON-FMC AMBA AXI BFM"

#-------------------------------------------------------------------------------
import sys
import confmc.pyconfmc as confmc
import confmc.pyconbfmaxi as axi
#import pyconbfmaxi as axi

#-------------------------------------------------------------------------------
def mem_test(hdl):
    Wdata = [0x12345678, 0x87654321]
    Rdata = [0x0, 0x0]
    axi.BfmWrite(hdl, 0x10000000, Wdata, 4, 2, rigor=1)
    axi.BfmRead (hdl, 0x10000000, Rdata, 4, 2, rigor=1)
    print Wdata, ":", Rdata
    Wdata = [0x12345678, 0x87654321, 0x11111111, 0x22222222]
    Rdata = [0x0, 0x0, 0x0, 0x0]
    axi.BfmWriteFix(hdl, 0x20000000, Wdata, 4, 4, rigor=1)
    axi.BfmReadFix (hdl, 0x20000000, Rdata, 4, 4, rigor=1)
    print Wdata, ":", Rdata

    axi.MemTestAddRAW(hdl, 0x20000000, 0x100)
    axi.MemTestAdd(hdl, 0x20000000, 0x100)

    axi.MemTestRAW(hdl, 0x10000000, 0x100, size=4, rigor=1)
    axi.MemTestRAW(hdl, 0x20000000, 0x100, size=2, rigor=1)
    axi.MemTestRAW(hdl, 0x10000000, 0x100, size=1, rigor=1)
    axi.MemTest(hdl, 0x10000000, 0x100, size=4, rigor=1)
    axi.MemTest(hdl, 0x20000000, 0x100, size=2, rigor=1)
    axi.MemTest(hdl, 0x10000000, 0x100, size=1, rigor=1)
    axi.MemTestBurstRAW(hdl, 0x10000000, 0x200, leng=10, rigor=1)
    axi.MemTestBurst(hdl, 0x20000000, 0x200, leng=10, rigor=1)
    axi.MemTestBurst(hdl, 0x20000000, 0x400, 20)

#-------------------------------------------------------------------------------
def main(prog,argv):
    import getopt
    cid=0
    try: opts, args = getopt.getopt(argv, "hc:",['help','cid='])
    except getopt.GetoptError:
           print  prog+' -c <card_id>'
           sys.exit(2)
    for opt, arg in opts:
        if opt=='-h':
           print prog+' -c <card_id>'
           sys.exit()
        elif opt in ("-c", "--cid"):
             cid = int(arg)
        else: print "unknown options: "+str(opt); sys.exit(1)

    hdl=confmc.conInit()
    if not hdl: sys.exit(1)
    cid=confmc.conGetCid(hdl)
    if cid<0: sys.exit(1)

    print("CON-FMC: CID"+str(cid)+" found.")
    mem_test(hdl)

    confmc.conRelease(hdl)

if __name__ == '__main__':
   main(sys.argv[0],sys.argv[1:])

#===============================================================================
# Revision history:
#
# 2019.04.10: Started by Ando Ki (adki@future-ds.com)
#             - Not finished yet
#===============================================================================
