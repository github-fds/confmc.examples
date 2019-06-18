#-------------------------------------------------------------------------------
SHELL	=/bin/bash

#-------------------------------------------------------------------------------
export BOOTGEN = $(XILINX_SDK)/bin/bootgen
export PROG_FLASH = $(XILINX_SDK)/bin/program_flash
export BOOT_FILE = BOOT.bin
export BIF_FILE = zed_bd.bif
export FSBL_FILE = fsbl_0.elf
export WRAPPER_FILE = zed_bd_wrapper.bit
export BIT_FILE = ../fpga.bit

#-------------------------------------------------------------------------------
all: boot

boot: bif
	if [ ! -f ${BIF_FILE} ]; then echo "${BIF_FILE} not found"; exit; fi
	$(BOOTGEN) -image $(BIF_FILE) -arch zynq -o $(BOOT_FILE) -w on

bif: bit
	if [ ! -f ${WRAPPER_FILE} ]; then echo "${WRAPPER_FILE} not found"; exit; fi
	if [ -f ${BIF_FILE} ]; then /bin/rm -f ${BIF_FILE}; fi
	echo "//arch = zynq; split = false; format = BIN" >  ${BIF_FILE}
	echo "the_ROM_image:"                             >> ${BIF_FILE}
	echo "{"                                          >> ${BIF_FILE}
	echo "	[bootloader]./${FSBL_FILE}"               >> ${BIF_FILE}
	echo "	./${WRAPPER_FILE}"                        >> ${BIF_FILE}
	echo "}"                                          >> ${BIF_FILE}

bit:
	if [ ! -f ${BIT_FILE} ]; then echo "${BIT_FILE} not found"; exit; fi
	if [ -f ${WRAPPER_FILE} ]; then /bin/rm -f ${WRAPPER_FILE}; fi
	if [ -f ${BIT_FILE} ]; then /bin/cp ${BIT_FILE} ${WRAPPER_FILE}; fi

prog: $(BOOT_FILE)
	@if [ ! -f ${BOOT_FILE} ]; then echo "${BOOT_FILE} not found"; exit; fi
	@if [ ! -f ${FSBL_FILE} ]; then echo "${FSBL_FILE} not found"; exit; fi
	@$(PROG_FLASH) -f $(BOOT_FILE) -fsbl $(FSBL_FILE)\
		-flash_type qspi_single -verify\
		-cable type xilinx_tcf url TCP:127.0.0.1:3121


#-------------------------------------------------------------------------------
.PHONY: clean cleanup clobber cleanupall

clean:
	/bin/rm -f  $(BOOT_FILE)
	/bin/rm -f  vivado.log

cleanup clobber: clean
	/bin/rm -f zed_bd_wrapper.bit

cleanupall: cleanup
	/bin/rm -f $(BIF_FILE)

#-------------------------------------------------------------------------------
