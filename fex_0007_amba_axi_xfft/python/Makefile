SHELL=/bin/sh
ARCH=$(shell uname -s)
ifeq ($(findstring MINGW32,$(ARCH)),MINGW32)
      KERN=mingw
else ifeq ($(findstring CYGWIN,$(ARCH)),CYGWIN)
      KERN=cygwin
else ifeq ($(findstring Linux,$(ARCH)),Linux)
      KERN=linux
endif
MACH:=$(shell uname -m)
PROCESSOR:=$(uname -p)

ifndef CONFMC_HOME
       $(warning CONFMC_HOME environment variable not defined)
       export CONFMC_HOME=$(HOME)/work/projects/ez-usb-fx3
       ifdef PATH
         export PATH=$(CONFMC_HOME)/bin:$(shell printenv PATH)
       else
         export PATH=$(CONFMC_HOME)/bin
       endif
       ifdef LD_LIBRARY_PATH
         export LD_LIBRARY_PATH=$(CONFMC_HOME)/lib/$(KERN)_$(MACH):$(shell printenv LD_LIBRARY_PATH)
       else
         export LD_LIBRARY_PATH=$(CONFMC_HOME)/lib/$(KERN)_$(MACH)
       endif
       ifdef C_INCLUDE_PATH
         export C_INCLUDE_PATH=$(CONFMC_HOME)/include:$(shell printenv C_INCLUDE_PATH)
       else
         export C_INCLUDE_PATH=$(CONFMC_HOME)/include
       endif
       ifdef CPLUS_INCLUDE_PATH
         export CPLUS_INCLUDE_PATH=$(CONFMC_HOME)/include:$(shell printenv CPLUS_INCLUDE_PATH)
       else
         export CPLUS_INCLUDE_PATH=$(CONFMC_HOME)/include
       endif
       ifdef PYTHONPATH
         export PYTHONPATH=$(CONFMC_HOME)/conapi/python/${KERN}_${MACH}:$(shell printenv PYTHONPATH)
       else
         export PYTHONPATH=$(CONFMC_HOME)/conapi/python/${KERN}_${MACH}
       endif
endif
       
all:
	python test_xfft.py
	python test_xfft.py -s 4000000 -w 100000:1.0:0
	python test_xfft.py -s 4000000 -w 100000:1.0:0 -w 200000:1.0:0
	python test_xfft.py -s 4000000 -w 100000:1.0:0 -w 200000:1.0:0 -w 300000:1.0:0
	python test_xfft.py -s 4000000 -w 100000:1.0:0 -w 200000:1.0:0 -w 300000:1.0:0 -w 400000:1.0:0
	python test_xfft.py -s 4000000 -w 100000:1.0:0 -w 200000:1.0:0 -w 300000:1.0:0 -w 400000:1.0:0 -w 500000:1.0:0

mem_test test_mem:
	python test_mem.py
