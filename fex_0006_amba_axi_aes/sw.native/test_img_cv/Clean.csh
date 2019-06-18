#!/bin/csh -f

set PROG="Test"

if ( -e ${PROG}      ) rm -f  ${PROG}
if ( -e ${PROG}.exe  ) rm -f  ${PROG}.exe 
if ( -e ${PROG}.elf  ) rm -f  ${PROG}.elf 
if ( -e ${PROG}.bin  ) rm -f  ${PROG}.bin 
if ( -e ${PROG}.hex  ) rm -f  ${PROG}.hex 
if ( -e ${PROG}.hexa ) rm -f  ${PROG}.hexa
if ( -e ${PROG}.o    ) rm -f  ${PROG}.o   
if ( -e ${PROG}.map  ) rm -f  ${PROG}.map 
if ( -e ${PROG}.sym  ) rm -f  ${PROG}.sym 
if ( -e obj          ) rm -fr obj         
if ( -e result.png   ) rm -f  result.png

/bin/rm -f *.o

if ( -e CMakeCache.txt      ) \rm -f  CMakeCache.txt
if ( -d CMakeFiles          ) \rm -fr CMakeFiles
if ( -e cmake_install.cmake ) \rm -f  cmake_install.cmake
if ( -e Makefile            ) \rm -f  Makefile
if (- e result.png          ) \rm -f  result.png
if (- e result.jpg          ) \rm -f  result.jpg
if ( -e DisplayImage        ) \rm -f  DisplayImage
