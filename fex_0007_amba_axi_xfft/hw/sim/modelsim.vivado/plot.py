#!/usr/bin/env python

import matplotlib.pyplot as plt
import numpy as np
import sys, getopt

#-------------------------------------------------------------------------------
adc_file   ='adc.txt'
fft_file   ='fft.txt'
freq_sample=2000
num_samples=256
bit_width  =16
data_type  ='real';# 'real/float' for float, 'hex' for fixed, 'int' for integer
data_format='complex';# 'real' or 'complex'

#-------------------------------------------------------------------------------
try:
     opts, args = getopt.getopt(sys.argv[1:], "ha:f:s:n:x",
                  ["adc_file=","fft_file=","sample_freq=","sample_num"])
except:
     print sys.argv[0], '-a <adc-file> -f <fft-file>'
     sys.exit(2)
for opt, arg in opts:
    if opt in ("-h", "--help"):
       print sys.argv[0], '-a <adc-file> -f <fft-file> -s sample_freq -n sample_num -x'
       print sys.argv[0], '-a', adc_file, '-f', fft_file, '-i', ifft_file
       print sys.argv[0], '-s', freq_sample, '-n', num_samples
       print sys.argv[0], '-x  for hexadecimal'
       sys.exit()
    elif opt in ("-a", "--adc_file"):
         adc_file=arg
    elif opt in ("-f", "--fft_file"):
         fft_file=arg
    elif opt in ("-s", "--sample_freq"):
         freq_sample=float(arg)
    elif opt in ("-n", "--sample_num"):
         num_samples=int(arg)
    elif opt in ("-x", "--hex"):
         data_type='hex'

#-------------------------------------------------------------------------------
def hex2int(hstring, wid=16):
    """return a signed-decimal of 2's complement hexadecimal
       hstring: a hexadeciaml string 
       with: bit-width of each hexadecimal
       >>> h= '0xde66'
       >>> i = hex2int(h, wid=16)
       >>> print i
       -8602"""
    m = 1<<(wid-1)
    n = m - 1
    if int(hstring, 16)>=(1<<wid): print "overflow", hstring
    i = int(hstring, 16)
    j = -(i&m) | (i&n)
    return j

#-------------------------------------------------------------------------------
def hex_complex_to_int(hstring, wid=16):
    """return a complex number
       hstring: a complex number in hexadeciaml (0x02df+0xffdaj)
       with: bit-width of each hexadecimal
       >>> h= '0xde66+0xffdaj'
       >>> i = hex_complex_to_int(h, wid=16)
       >>> print i
       (-8602-38j)"""
    s = hstring.strip('j').split('+'); # no '-' since it is hexa
    sr = hex2int(s[0],wid)
    si = hex2int(s[1],wid)
    return sr+1j*si

#-------------------------------------------------------------------------------
def get_data(file_name):
    global freq_sample
    global num_sample
    global bit_width
    global data_format
    global data_type
    f = open(file_name); line = f.readline().rstrip().split(' '); f.close();
    for s in line:
        if s[0][0]!='#':
           part = s.split('=')
           if part[0]=="sample_freq": freq_sample = int(part[1])
           if part[0]=="sample_num": num_sample = int(part[1])
           if part[0]=="bit_width": bit_width = int(part[1])
           if part[0]=="data_format": data_format = part[1]
           if part[0]=="data_type": data_type = part[1]
    
    if data_format=='real':
       if data_type=='real' or data_type=='float':
          values = np.loadtxt(file_name, comments='#', dtype=float)
          da = values.flatten('C')
       elif data_type=='hex':
          # it has signness problem.
          values = np.loadtxt(file_name, comments='#', dtype=int,
                              converters={0:lambda s: hex2int(s, wid=bit_width)})
          da = values.flatten('C')
       else: print "something wong with data_type"
    elif data_format=='complex':
       if data_type=='real' or data_type=='float':
          values = np.loadtxt(file_name, comments='#', dtype=np.complex)
          da = values.flatten('C')/num_samples
       elif data_type=='hex':
          # it does not work yet
          values = np.loadtxt(file_name, comments='#', dtype=np.complex,
                              converters={0:lambda s: hex_complex_to_int(s, wid=bit_width)})
          da = values.flatten('C')
       else: print "something wong with data_type"
    else: print "something wrong with data_format"
    
    if num_samples!=len(da):
       print "sample number mis-match"

    return da

#-------------------------------------------------------------------------------
ad = get_data(adc_file)
fx = get_data(fft_file)

#-------------------------------------------------------------------------------
fig, ax = plt.subplots(6, 1)

intervals = np.arange(len(ad))
ax[0].plot(intervals, ad.real)
ax[0].set_xlabel("num")
ax[0].set_ylabel("value")
ax[0].set_xlim(0,len(ad))

intervals = np.arange(len(fx))
freq = intervals*(freq_sample/len(fx))
ax[1].bar(freq, fx.real, color='green')
ax[1].set_xlabel("Hz")
ax[1].set_ylabel("fft.real")

intervals = np.arange(len(fx))
freq = intervals*(freq_sample/len(fx))
ax[2].bar(freq, fx.imag)
ax[2].set_xlabel("Hz")
ax[2].set_ylabel("fft.imag")

intervals = np.arange(len(fx))
freq = intervals*(freq_sample/len(fx))
ax[3].bar(freq, abs(fx))
ax[3].set_xlabel("Hz")
ax[3].set_ylabel("fft.power")

intervals = np.arange(len(fx)/2)
freq = intervals*(freq_sample/len(fx))
Y=fx[intervals]
ax[4].bar(freq, abs(Y))
ax[4].set_xlabel("Hz")
ax[4].set_ylabel("fft.power")

intervals = np.arange(len(fx)/4)
freq = intervals*(freq_sample/len(fx))
Y=fx[intervals]
ax[5].bar(freq, abs(Y), color='red')
ax[5].set_xlabel("Hz")
ax[5].set_ylabel("fft.power")

plt.show()

#-------------------------------------------------------------------------------
# Revision history
#
# 2019.04.10: ifft removed
# 2019.04.05: 'get_data()' added
# 2019.04.01: handing first line of data file
# 2019.04.01: 'bit_width' variable added.
# 2019.04.01: added
#             hex2int(hstring, wid=16) and hex_complex_to_int(hstring, wid=16)
#-------------------------------------------------------------------------------
