DIRS	= $(subst /,, $(dir $(wildcard */Makefile)))

all:

build:
	make -C hw.single/syn/xst.v6
	make -C hw.single/pnr/ise.ml605.lpc
	make -C hw.single/pnr/ise.ml605.hpc
	make -C hw.dual/syn/xst.v6
	make -C hw.dual/pnr/ise.ml605.dual

clean cleanup clobber cleanupall:
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done

.PHONY: all clean cleanup clobber cleanupall
