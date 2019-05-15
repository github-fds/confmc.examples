SHELL=/bin/sh
ARCH=$(shell uname -s)
ifeq ($(findstring MINGW,$(ARCH)),MINGW)
      PLATFORM=mingw
else ifeq ($(findstring CYGWIN,$(ARCH)),CYGWIN)
      PLATFORM=cygwin
else ifeq ($(findstring Linux,$(ARCH)),Linux)
      PLATFORM=linux
endif
MACH:=$(shell uname -m)
PROCESSOR:=$(uname -p)

ifndef CONFMC_HOME
       ifeq ($(PLATFORM),linux)
         export CONFMC_HOME=${HOME}/work/projects/ez-usb-fx3
       else
         export CONFMC_HOME=/z/work/projects/ez-usb-fx3
       endif
       ifdef PATH
         export PATH=$(CONFMC_HOME)/bin:$(shell printenv PATH)
       else
         export PATH=$(CONFMC_HOME)/bin
       endif
       ifdef LD_LIBRARY_PATH
         export LD_LIBRARY_PATH=$(CONFMC_HOME)/lib/$(PLATFORM)_$(MACH):$(shell printenv LD_LIBRARY_PATH)
       else
         export LD_LIBRARY_PATH=$(CONFMC_HOME)/lib/$(PLATFORM)_$(MACH)
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
         export PYTHONPATH=$(CONFMC_HOME)/python/$(PLATFORM)_$(MACH):$(shell printenv PYTHONPATH)
       else
         export PYTHONPATH=$(CONFMC_HOME)/python/$(PLATFORM)_$(MACH)
       endif
endif
       
all:
	echo CONFMC_HOME $(CONFMC_HOME)
	echo PLATFORM    $(PLATFORM)
	echo PYTHONPATH  $(PYTHONPATH)
	python test_mem.py
