DIR_FIP ?= ${HOME}/work/projects/FIP

all:

m2s:
	if [ -d axi_mem2stream ]; then\
		if [ -e axi_mem2stream/.git ]; then\
			(cd axi_mem2stream;\
			git fetch && git fetch --tags;\
			git checkout master);\
		else\
			(cd axi_mem2stream;\
			git clone ${DIR_FIP}/FIP_0201_axi_mem2stream .);\
		fi;\
	else\
		/bin/mkdir axi_mem2stream;\
		(cd axi_mem2stream;\
		git clone ${DIR_FIP}/FIP_0201_axi_mem2stream .);\
	fi

s2m:
	if [ -d axi_stream2mem ]; then\
		if [ -e axi_stream2mem/.git ]; then\
			(cd axi_stream2mem;\
			git fetch && git fetch --tags;\
			git checkout master);\
		else\
			(cd axi_stream2mem;\
			git clone ${DIR_FIP}/FIP_0202_axi_stream2mem .);\
		fi;\
	else\
		/bin/mkdir axi_stream2mem;\
		(cd axi_stream2mem;\
		git clone ${DIR_FIP}/FIP_0202_axi_stream2mem .);\
	fi

DIRS	= $(subst /,, $(dir $(wildcard */Makefile)))

clean cleanup clobber cleanupall:
	for D in $(DIRS); do\
		if [ -f $$D/Makefile ] ; then \
			echo "make -C $$D -s $@";\
			make -C $$D -s $@;\
		fi;\
	done

.PHONY: all clean cleanup clobber cleanupall
