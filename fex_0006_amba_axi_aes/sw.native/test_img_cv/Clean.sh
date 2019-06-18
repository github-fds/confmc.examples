#!/bin/sh

PROG="Test"

if [ -f ${PROG}      ]; then /bin/rm -f  ${PROG}     ; fi
if [ -f ${PROG}.exe  ]; then /bin/rm -f  ${PROG}.exe ; fi
if [ -f ${PROG}.elf  ]; then /bin/rm -f  ${PROG}.elf ; fi
if [ -f ${PROG}.bin  ]; then /bin/rm -f  ${PROG}.bin ; fi
if [ -f ${PROG}.hex  ]; then /bin/rm -f  ${PROG}.hex ; fi
if [ -f ${PROG}.hexa ]; then /bin/rm -f  ${PROG}.hexa; fi
if [ -f ${PROG}.o    ]; then /bin/rm -f  ${PROG}.o   ; fi
if [ -f ${PROG}.map  ]; then /bin/rm -f  ${PROG}.map ; fi
if [ -f ${PROG}.sym  ]; then /bin/rm -f  ${PROG}.sym ; fi
if [ -d obj          ]; then /bin/rm -fr obj         ; fi
if [ -f result.png   ]; then /bin/rm -f  result.png  ; fi

/bin/rm -f *.o

if [ -f CMakeCache.txt      ]; then \rm -f  CMakeCache.txt     ; fi
if [ -d CMakeFiles          ]; then \rm -fr CMakeFiles         ; fi
if [ -f cmake_install.cmake ]; then \rm -f  cmake_install.cmake; fi
if [ -f Makefile            ]; then \rm -f  Makefile           ; fi
if [ -f result.png          ]; then \rm -f  result.png         ; fi
if [ -f result.jpg          ]; then \rm -f  result.jpg         ; fi
if [ -f DisplayImage        ]; then \rm -f  DisplayImage       ; fi

