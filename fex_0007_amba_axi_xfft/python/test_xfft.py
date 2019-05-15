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
import numpy as np
import ctypes
import ctypes.util
import confmc.pyconfmc as confmc
import confmc.pyconbfmaxi as axi
sys.path.insert(0, '../iplib/xfft_config/api/python')
import xfft_config_api as xfft_config
sys.path.insert(0, '../iplib/axi_mem2stream/api/python')
import axi_mem2stream_api as axi_m2s
sys.path.insert(0, '../iplib/axi_stream2mem/api/python')
import axi_stream2mem_api as axi_s2m

#-------------------------------------------------------------------------------
def degree2radian(d):
    """Degree to Radian"""
    return d*(np.pi/180)

def radian2degree(r):
    """Radian to Degree"""
    return r*(180/np.pi)

def frequency2angular(f):
    """(regular) frequency to angular frequency"""
    return 2*np.pi*f

def gen_signals(signals=[[100000,1.0,0]], sampleFreq=4000000, sampleNum=256):
    """It returns adc-values (real-part only) and time-vector.
       signals: an array of [freq,amplitude,initial_degree]
       sampleFreq: frequency of sampling, i.e., sampling rate
       sampleNum: num of samples"""
    sampleInterval   = 1.0/float(sampleFreq); # sampling interval
    sampleTime       = float(sampleNum)/sampleFreq;
    timeVector       = np.arange(0,sampleTime,sampleInterval) 
    sumAmplitude     = 0.0
    for i in range(len(signals)): sumAmplitude += signals[i][1]
    adcValues        = 0.0
    for i in range(len(signals)):
        angularFrequency = frequency2angular(signals[i][0])
        initialPhase     = degree2radian(signals[i][2])
        values           = np.sin(angularFrequency*timeVector+initialPhase)
        adcValues       += (values*signals[i][1])
    adcValues /= sumAmplitude # normalize
    return adcValues, timeVector

def get_signed(val, bits):
    x = 1<<(bits-1)
    y = 1<<bits
    if (val>x): return (y-val)*(-1)
    else: return val

def plot(signal_fixed, fft_fixed, sampleFreq=4000000, sampleNum=256):
    """signal_fixed: [{16-bit imag, 16-bit real] ...] in hex
       fft_fixed: [{32-bit imag, 32-bit real] ...] in hex
       sampleFreq: sampling frequency
       sampleNum: num of samples"""
    import scipy.fftpack as fftp
    import matplotlib.pyplot as plt

    sampleInterval   = 1.0/float(sampleFreq); # sampling interval
    sampleTime       = float(sampleNum)/sampleFreq;
    timeVector       = np.arange(0,sampleTime,sampleInterval) 
    freqVector       = np.arange(sampleNum)/(float(sampleNum)/float(sampleFreq))

    signal_fixed32 = np.zeros(sampleNum, dtype=np.complex)
    for i in range (sampleNum):
        real = get_signed((signal_fixed[i]&0xFFFF),16)
        imag = get_signed((signal_fixed[i]>>16),16)
        signal_fixed32[i] = np.complex(real, imag)

    fft_fixed32 = np.zeros(sampleNum, dtype=np.complex)
    for i in range (sampleNum):
        real = get_signed(fft_fixed[i*2],32)
        imag = get_signed(fft_fixed[i*2+1],32)
        fft_fixed32[i] = np.complex(real, imag)

    fig, ax = plt.subplots(2, 1)

    intervals = np.arange(len(signal_fixed32))
   #ax[0].plot(timeVector, signal_fixed32.real)
    ax[0].plot(intervals, signal_fixed32.real)
    ax[0].set_xlabel("num")
    ax[0].set_ylabel("value")
    ax[0].set_xlim(0, sampleNum)
    intervals = np.arange(len(fft_fixed32))
    freq = intervals*(sampleFreq/len(fft_fixed32))/1000000.0
    ax[1].plot(freq, abs(fft_fixed32))
    ax[1].set_xlabel("MHz")
    ax[1].set_ylabel("value")
   #ax[1].set_text(sampleFreq/3, 100, "sampling frequency: ", style='italic')
    string = 'sampling frequency '+str(sampleFreq/1000000)+'Mhz'
    ax[1].text(freq[sampleNum/3], max(abs(fft_fixed32))/2, string, style='italic')
    plt.show()

#-------------------------------------------------------------------------------
def main(prog,argv):
    import getopt
    cid=0
    sampleFreq=4000000
    sampleNum =256
    signals   = [] #[[freq, amplitude, initial-degree]]
    try: opts, args = getopt.getopt(argv, "hc:s:w:",['help','cid=','freq=','wave='])
    except getopt.GetoptError:
           print  prog+' -c <card_id> -s <sampling_freq> -w <f:a:p>'
           sys.exit(2)
    for opt, arg in opts:
        if opt=='-h':
           print prog+' -c <card_id> -s <sampling_freq> -w <freq:ampl:degree>'
           sys.exit()
        elif opt in ("-c", "--cid"):
             cid = int(arg)
        elif opt in ("-s", "--freq"):
             sampleFreq = int(arg)
        elif opt in ("-w", "--wave"):
             words = arg.split(':')
             wave = map(float, words)
             signals.append(wave)
        else: print "unknown options: "+str(opt); sys.exit(1)
    if len(signals)==0: signals = [[100000, 1.0, 0]]

    hdl=confmc.conInit()
    if not hdl: sys.exit(1)
    cid=confmc.conGetCid(hdl)
    if cid<0: sys.exit(1)

    print("CON-FMC: CID"+str(cid)+" found.")

    # prepare ADC values, which are all real values with no imainary values
    real_values,time_vector = gen_signals(signals
                                         ,sampleFreq
                                         ,sampleNum)
    signalFixed = [0] * sampleNum; # [{16-bit imag, 16-bit real}...]
    for i in range (0,sampleNum):
        int_val = int(real_values[i]*(1<<14))
        if int_val>0xFFFF: print "exceed ",i," ",int_val
        signalFixed[i] = int_val&0xFFFF;

    ADDR_APB_START     =0x00000000
    ADDR_MEM_M2S_START =0x10000000
    ADDR_MEM_S2M_START =0x20000000

    ADDR_XFFT_CONFIG_START   =(ADDR_APB_START)
    ADDR_AXI_MEM2STREAM_START=(ADDR_APB_START+0x10000)
    ADDR_AXI_STREAM2MEM_START=(ADDR_APB_START+0x20000)

    # prepare XFFT_CONFIG, MEM2STREAM, STREAM2MEM
    xc  = xfft_config.xfft_config(hdl, bfm=axi, addr=ADDR_XFFT_CONFIG_START); #xc.csr()
    m2s = axi_m2s.axi_mem2stream(hdl, bfm=axi, addr=ADDR_AXI_MEM2STREAM_START); #m2s.csr()
    s2m = axi_s2m.axi_stream2mem(hdl, bfm=axi, addr=ADDR_AXI_STREAM2MEM_START); #s2m.csr()

    xc.reset()
    xc.config(0x01, 0); # set Forwared-FFT, blocking

    axi.BfmWrite(hdl, ADDR_MEM_M2S_START, signalFixed, size=4, length=sampleNum, rigor=1)
    signal_fixed = [0] * sampleNum; # [{16-bit imag, 16-bit real}...]
    axi.BfmRead (hdl, ADDR_MEM_M2S_START, signal_fixed, size=4, length=sampleNum, rigor=1)
    error=0
    for i in range(sampleNum):
        if (signalFixed[i]!=signal_fixed[i]):
            error+=1
            print hex(signalFixed[i]),":",hex(signal_fixed[i])
    if (error==0): print "OK"

    s2m.enable(1, 0)
    s2m.set(ADDR_MEM_S2M_START,
                      sampleNum*4*2, # frame: each samples 32-bit imag, 32-bit real
                      sampleNum*4*2, # packet: each samples 32-bit imag, 32-bit real
                      4*16, # chunk
                      1, # cnum
                      0, # cont
                      1, # go
                      1); # time out
    m2s.enable(1, 0)
    m2s.set(ADDR_MEM_M2S_START,
                      sampleNum*2*2, # frame: each samples 16-bit imag, 16-bit real
                      sampleNum*2*2, # packet: each samples 16-bit imag, 16-bit real
                      4*16, # chunk
                      1, # cnum
                      0, # cont
                      1, # go
                      0); # time out

    fft_fixed = [0] * sampleNum * 2; # [{32-bit imag, 32-bit real}...]
    axi.BfmRead (hdl, ADDR_MEM_S2M_START, fft_fixed, size=4, length=(sampleNum*2), rigor=1)

    plot(signal_fixed, fft_fixed, sampleFreq=4000000, sampleNum=256)

    confmc.conRelease(hdl)

if __name__ == '__main__':
   main(sys.argv[0],sys.argv[1:])

#===============================================================================
# Revision history:
#
# 2019.04.10: Started by Ando Ki (adki@future-ds.com)
#             - Not finished yet
#===============================================================================
